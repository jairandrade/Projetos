#include "protheus.ch"
#include "fwMVCdef.ch"

/*/{Protheus.doc} AFIN003
Cadastro de Integrações FLUIG
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/07/2020
/*/
user function AFIN003()

	local oBrowse

	oBrowse:= FwMBrowse():New()
	oBrowse:SetAlias("Z27")
	oBrowse:SetDescription( "Integrações FLUIG" )
    oBrowse:SetMenuDef("MADERO_AFIN003")
	oBrowse:AddLegend("Z27_STATUS == 'P'", "RED", "Pendente")
	oBrowse:AddLegend("Z27_STATUS == 'I'", "GREEN", "Integrado")
	oBrowse:Activate()

return

/*/{Protheus.doc} MenuDef
Definio das rotinas do browse principal
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/07/2020
@return array, Opes do menu
/*/
static function MenuDef()   

	local aRotina := {}

	AADD( aRotina, { 'Visualizar'  , 'VIEWDEF.MADERO_AFIN003', 0, 2, 0, Nil } )
    AADD( aRotina, { 'Incluir'     , 'VIEWDEF.MADERO_AFIN003', 0, 3, 0, Nil } )
    AADD( aRotina, { 'Alterar'     , 'VIEWDEF.MADERO_AFIN003', 0, 4, 0, Nil } )
    AADD( aRotina, { 'Excluir'     , 'VIEWDEF.MADERO_AFIN003', 0, 5, 0, Nil } )
    AADD( aRotina, { 'Re-Processar', 'U_AFIN003R'            , 0, 6, 0, Nil } )

return aRotina

/*/{Protheus.doc} ModelDef
Definio do modelo de dados
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/07/2020
@return object, Objeto MVC-Model
/*/
static function ModelDef()

	local oStrut := FWFormStruct( 1, 'Z27')
	local oModel := MPFormModel():New('AFIN003M')
	local oFluigInteg := FLGINTG():New()

    //inicializador padrão dos campos
    oStrut:SetProperty('Z27_DATA'  , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'Date()'))
    oStrut:SetProperty('Z27_HORA'  , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'Time()'))
    oStrut:SetProperty('Z27_STATUS', MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, '"P"'   ))

	oModel:AddFields( 'Z27MASTER',, oStrut )

	oModel:SetPrimaryKey( {"Z27_FILIAL", "Z27_PROCES", "Z27_SOLICI", "Z27_OPERAC"} ) //X2_UNICO

	oModel:InstallEvent("FLGINTG", , oFluigInteg)

return oModel

/*/{Protheus.doc} ViewDef
Definio da viso do modelo de dados
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/07/2020
@return object, Objeto MVC-View
/*/
static function ViewDef()

	local oView     := FWFormView():New()
	local oModel    := FWLoadModel( 'MADERO_AFIN003' ) // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	local oEnchoice := FWFormStruct( 2, 'Z27')// Cria a estrutura a ser acrescentada na View

	// Altera o Modelo de dados quer ser utilizado
	oView:SetModel( oModel )

	// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_Z27' , oEnchoice, 'Z27MASTER' )

	// Novos Boxes
	oView:CreateHorizontalBox( 'SUPERIOR' , 100 )

	// Relaciona o identificador (ID) da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_Z27' , 'SUPERIOR' )

Return oView 

/*/{Protheus.doc} AFIN003R
Re-processamento de registros não integrados
@type function
@version 12.1.0.25
@author fabricio.reche
@since 06/07/2020
/*/
user function AFIN003R()

	local oFluigInteg := FLGINTG():New()
	local oModel := Nil

	if Z27->Z27_STATUS == "I"
		if ! IsBlind()
			MsgInfo("Registro já integrado.", "Atenção")
		endIf
		return
	endIf

	oModel:= FwLoadModel( 'MADERO_AFIN003' )
	oModel:SetOperation(MODEL_OPERATION_VIEW)
	oModel:Activate()

	//faz a chamada do processo de integração novamente
	oFluigInteg:After(oModel:GetModel("Z27MASTER"), "Z27MASTER", "Z27", .F.)

return

/*/{Protheus.doc} AFIN003J
Job de re-processamento automático
@type function
@version 
@author fabricio.reche
@since 10/07/2020
/*/
user function AFIN003J(cdEmpresa, cdFilial)

	local _cAlias := ""
	local _cQuery := ""

	RpcSetType(3)
	RpcSetEnv(cdEmpresa, cdFilial)

	_cQuery += " select R_E_C_N_O_ REG " 
	_cQuery += " from " + RetSqlTab("Z27") 
	_cQuery += " where " + RetSqlCond("Z27") 
	_cQuery += "   and Z27_STATUS = 'P' " //busca registros pendentes
	
	_cAlias := MPSysOpenQuery(_cQuery)
	
	while (_cAlias)->( ! EoF() )

		Z27->( DbGoTo( (_cAlias)->REG ) )

		//reprocessa o registro posicionado
		U_AFIN003R()
	
		(_cAlias)->( DbSkip() )
	
	endDo
	
	(_cAlias)->( DbCloseArea() )

return
