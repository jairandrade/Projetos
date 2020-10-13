#Include 'Protheus.ch'

User Function AEST001(aDtaZWE) 

	Local oBrowse	:= Nil
	Local cFiltro	:= ""

	Default aDtaZWE := {}

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZWE")
	oBrowse:SetDescription("Inconsistências integração de vendas")
	oBrowse:SetMenuDef("MADERO_AEST001")
	If IsInCallStack("MostraZWE")
		cFiltro := "@		ZWE_FILIAL = '" + xFilial("ZWE") + "' "
		cFiltro += "	AND ZWE_TIPO = 'E' "
		cFiltro += " 	AND ZWE_DATA >= '" + aDtaZWE[02] + "' "
		cFiltro += " 	AND ZWE_DATA <= '" + aDtaZWE[01] + "' "
		oBrowse:SetFilterDefault(cFiltro)
	EndIf
	oBrowse:Activate()



Return

Static Function MenuDef()

	Local aRotina := {}

	aAdd(aRotina,{'Visualizar'	,'VIEWDEF.MADERO_AEST001'	,0,2,0,NIL})
//	aAdd(aRotina,{'Incluir'		,'VIEWDEF.MADERO_AEST001'	,0,3,0,NIL})
//	aAdd(aRotina,{'Alterar'		,'VIEWDEF.MADERO_AEST001'	,0,4,0,NIL})
//	aAdd(aRotina,{'Excluir'		,'VIEWDEF.MADERO_AEST001'	,0,5,0,NIL})
	aAdd(aRotina,{'Imprimir' 	,'VIEWDEF.MADERO_AEST001'	,0,8,0,NIL})
//	aAdd(aRotina,{'Copiar'		,'VIEWDEF.MADERO_AEST001'	,0,9,0,NIL})

Return( aRotina )


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Mario L. B. Faria

@since 19/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStr1	:= FWFormStruct(1,'ZWE')
	
	oModel := MPFormModel():New('AEST001_MAIN', , )
	oModel:SetDescription('ZWE')
	oModel:addFields('MODEL_ZWE',,oStr1)
	oModel:SetPrimaryKey({ 'ZWE_FILIAL', 'ZWE_PROCES', 'ZWE_DATA', 'ZWE_ID', 'ZWE_ENTID' })
	oModel:getModel('MODEL_ZWE'):SetDescription('Inventário')
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Mario L. B. Faria

@since 19/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView
	Local oModel	:= ModelDef()
	Local oStr1		:= FWFormStruct(2, 'ZWE')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_ZWE' , oStr1,'MODEL_ZWE' ) 
	oView:CreateHorizontalBox( 'BOX_ZWE', 100)
	oView:SetOwnerView('VIEW_ZWE','BOX_ZWE')

Return oView