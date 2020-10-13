#include 'protheus.ch'
#include 'parmtype.ch'



/*/{Protheus.doc} AWS001
//TODO Rotina para visualizar Amarração Produtos X Filiais
@author Mario L. B. Faria
@since 25/05/2018
@version 1.0
/*/
User Function AWS001()

	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("Z13")
	oBrowse:SetDescription("Produtos x Unidades")
	oBrowse:SetMenuDef("MADERO_AWS001")
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aAdd(aRotina,{'Visualizar'	,'VIEWDEF.MADERO_AWS001'	,0,2,0,NIL})
//	aAdd(aRotina,{'Incluir'		,'VIEWDEF.MADERO_AWS001'	,0,3,0,NIL})
//	aAdd(aRotina,{'Alterar'		,'VIEWDEF.MADERO_AWS001'	,0,4,0,NIL})
//	aAdd(aRotina,{'Excluir'		,'VIEWDEF.MADERO_AWS001'	,0,5,0,NIL})
//	aAdd(aRotina,{'Imprimir' 	,'VIEWDEF.MADERO_AWS001'	,0,8,0,NIL})
//	aAdd(aRotina,{'Copiar'		,'VIEWDEF.MADERO_AWS001'	,0,9,0,NIL})

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
	Local oStr1:= FWFormStruct(1,'Z13')
	
	oModel := MPFormModel():New('MAIN_AWS001')
	oModel:SetDescription("Produtos x Unidades")
	oModel:addFields('MODEL_Z13',,oStr1)
	oModel:SetPrimaryKey({ 'Z13_FILIAL', 'Z13_COD' })

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
	Local oStr1:= FWFormStruct(2, 'Z13')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_Z13' , oStr1,'MODEL_Z13' ) 
	oView:CreateHorizontalBox( 'BOX_Z13', 100)
	oView:SetOwnerView('VIEW_Z13','BOX_Z13')

Return oView
