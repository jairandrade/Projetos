#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'


/*/{Protheus.doc} AWS008
//TODO Rotina para visualizar Condições de Pagamento
@author Mario L. B. Faria
@since 25/05/2018
@version 1.0
/*/
User Function AWS008()

	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("Z10")
	oBrowse:SetDescription("Condições de Pagamento")
	oBrowse:SetMenuDef("MADERO_AWS008")
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aAdd(aRotina,{'Visualizar'	,'VIEWDEF.MADERO_AWS008'	,0,2,0,NIL})
	// aAdd(aRotina,{'Incluir'		,'VIEWDEF.MADERO_AWS008'	,0,3,0,NIL})
	// aAdd(aRotina,{'Alterar'		,'VIEWDEF.MADERO_AWS008'	,0,4,0,NIL})
	// aAdd(aRotina,{'Excluir'		,'VIEWDEF.MADERO_AWS008'	,0,5,0,NIL})
//	aAdd(aRotina,{'Imprimir' 	,'VIEWDEF.MADERO_AWS008'	,0,8,0,NIL})
//	aAdd(aRotina,{'Copiar'		,'VIEWDEF.MADERO_AWS008'	,0,9,0,NIL})

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Mario L. B. Faria

@since 28/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel 
	Local oStr1:= FWFormStruct(1,'Z10')
	
	oModel := MPFormModel():New('MAIN_AWS008')
	oModel:SetDescription('Condições de Pagamento')
	
	oStr1:AddTrigger( 'Z10_CODIGO', 'Z10_DESC'	, { || .T. }, {|oModel| Posicione("SE4",1,xFilial("SE4") + FWFldGet("Z10_CODIGO"),"E4_DESCRI") } )
	oStr1:AddTrigger( 'Z10_CODIGO', 'Z10_XTPREC', { || .T. }, {|oModel| Posicione("SE4",1,xFilial("SE4") + FWFldGet("Z10_CODIGO"),"E4_TIPO") } )
	
	oModel:addFields('MODEL_Z10',,oStr1)
	oModel:SetPrimaryKey({ 'Z10_FILIAL', 'Z10_COD' })

	// oStr1:SetProperty( 'Z10_XEMP'	,MODEL_FIELD_INIT	,{|| U_INITEK("ADK_XEMP") })
	// oStr1:SetProperty( 'Z10_XFIL'	,MODEL_FIELD_INIT	,{|| U_INITEK("ADK_XFIL") })
	oStr1:SetProperty( 'Z10_XSTINT'	,MODEL_FIELD_INIT	,{|| "P" })
	oStr1:SetProperty( 'Z10_XEXC'	,MODEL_FIELD_INIT	,{|| "N"})
	
	// oStr1:SetProperty( 'Z10_XEMP'	,MODEL_FIELD_OBRIGAT,.T. )
	// oStr1:SetProperty( 'Z10_XFIL'	,MODEL_FIELD_OBRIGAT,.T. )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Mario L. B. Faria

@since 28/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStr1:= FWFormStruct(2, 'Z10')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_Z10' , oStr1,'MODEL_Z10' ) 
	oView:CreateHorizontalBox( 'BOX_Z10', 100)
	oView:SetOwnerView('VIEW_Z10','BOX_Z10')

Return oView




