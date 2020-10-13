#Include 'Protheus.ch'


/*/{Protheus.doc} APCP004
//TODO Rptina para cadastrar os produtos de transformação
@author Mario L. B. Faria
@since 15/07/2018
@version 1.0
/*/
User Function APCP004()

	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZA3")
	oBrowse:SetDescription("Cadastro de Transformação")
	oBrowse:SetMenuDef("MADERO_APCP004")
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aAdd(aRotina,{'Visualizar'	,'VIEWDEF.MADERO_APCP004'	,0,2,0,NIL})
	aAdd(aRotina,{'Incluir'		,'VIEWDEF.MADERO_APCP004'	,0,3,0,NIL})
	aAdd(aRotina,{'Alterar'		,'VIEWDEF.MADERO_APCP004'	,0,4,0,NIL})
	aAdd(aRotina,{'Excluir'		,'VIEWDEF.MADERO_APCP004'	,0,5,0,NIL})
	aAdd(aRotina,{'Imprimir' 	,'VIEWDEF.MADERO_APCP004'	,0,8,0,NIL})
//	aAdd(aRotina,{'Copiar'		,'VIEWDEF.MADERO_APCP004'	,0,9,0,NIL})

Return( aRotina )


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Mario L. B. Faria

@since 15/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStr1:= FWFormStruct(1,'ZA3')
	Local oStr2:= FWFormStruct(1,'ZA4')
	
	oModel := MPFormModel():New('Tranformação')
	
	oStr1:AddTrigger( 'ZA3_PRODUT'	, 'ZA3_DESC'	, { || .T. }, {|oModel| Posicione("SB1",1,xFilial("SB1")+FWFldGet("ZA3_PRODUT"),"B1_DESC" ) } )
	oStr2:AddTrigger( 'ZA4_TRANFO'	, 'ZA4_DESC'	, { || .T. }, {|oModel| Posicione("SB1",1,xFilial("SB1")+FWFldGet("ZA4_TRANFO"),"B1_DESC" ) } )
	oStr2:AddTrigger( 'ZA4_PRDPI'	, 'ZA4_DESCPI'	, { || .T. }, {|oModel| Posicione("SB1",1,xFilial("SB1")+FWFldGet("ZA4_PRDPI"),"B1_DESC" ) } )
	
	oModel:addFields('MODEL_ZA3',,oStr1)
	oModel:addGrid('MODEL_ZA4','MODEL_ZA3',oStr2)
	oModel:GetModel('MODEL_ZA4'):SetUniqueLine( { 'ZA4_SEQ', 'ZA4_TRANFO' } )
	oModel:SetRelation('MODEL_ZA4', { { 'ZA4_FILIAL', 'xFilial("ZA3")' }, { 'ZA4_PRODUT', 'ZA3_PRODUT' } }, ZA4->(IndexKey(1)) )
	oModel:SetPrimaryKey({ 'ZA3_FILIAL', 'ZA3_PRODUT' })
	oModel:SetDescription('Tranformação')
	oModel:getModel('MODEL_ZA4'):SetDescription('Transformação')
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Mario L. B. Faria

@since 15/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStr1:= FWFormStruct(2, 'ZA3')
	Local oStr2:= FWFormStruct(2, 'ZA4')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_ZA3' , oStr1,'MODEL_ZA3' )
	oView:AddGrid('VIEW_ZA4' , oStr2,'MODEL_ZA4')  
	oView:CreateHorizontalBox( 'BOX_ZA3', 20)
	oView:CreateHorizontalBox( 'BOX_ZA4', 80)
	oView:SetOwnerView('VIEW_ZA4','BOX_ZA4')
	oView:SetOwnerView('VIEW_ZA3','BOX_ZA3')
	oView:AddIncrementField('VIEW_ZA4' , 'ZA4_SEQ' ) 
	
	oStr2:RemoveField('ZA4_PRODUT')

Return oView

/*/{Protheus.doc} APCP04G1
//TODO gatilho 01
@author Mario L. B. Faria
@since 15/07/2018
@version 1.0
/*/
User Function APCP04G1()
	Local oModel := FWModelActive()
Return Posicione("SB1",1,xFilial("SB1")+oModel:GetModel('MODEL_ZA3'):GetValue("ZA3_PRODUT"),"B1_DESC" )	

/*/{Protheus.doc} APCP04G2
//TODO gatilho 02
@author Mario L. B. Faria
@since 15/07/2018
@version 1.0
/*/
User Function APCP04G2()
	Local oModel := FWModelActive()
Return Posicione("SB1",1,xFilial("SB1")+oModel:GetModel('MODEL_ZA4'):GetValue("ZA4_TRANFO"),"B1_DESC" )	