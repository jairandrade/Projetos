#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} AWS004
//TODO Rotina para visualizar Produtos X Impostos
@author Mario L. B. Faria
@since 25/05/2018
@version 1.0
/*/
User Function AWS004()

	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("Z16")
	oBrowse:SetDescription("Produtos x Impostos x Unidades")
	oBrowse:SetMenuDef("MADERO_AWS004")
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aAdd(aRotina,{'Visualizar'	,'VIEWDEF.MADERO_AWS004'	,0,2,0,NIL})
//	aAdd(aRotina,{'Incluir'		,'VIEWDEF.MADERO_AWS004'	,0,3,0,NIL})
//	aAdd(aRotina,{'Alterar'		,'VIEWDEF.MADERO_AWS004'	,0,4,0,NIL})
//	aAdd(aRotina,{'Excluir'		,'VIEWDEF.MADERO_AWS004'	,0,5,0,NIL})
//	aAdd(aRotina,{'Imprimir' 	,'VIEWDEF.MADERO_AWS004'	,0,8,0,NIL})
//	aAdd(aRotina,{'Copiar'		,'VIEWDEF.MADERO_AWS004'	,0,9,0,NIL})

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
	Local oStr1:= FWFormStruct(1,'Z16')
	
	oModel := MPFormModel():New('MAIN_AWS004')
	oModel:SetDescription('Produtos x Impostos x Unidades')
	oModel:addFields('MODEL_Z16',,oStr1)
	oModel:SetPrimaryKey({ 'Z16_FILIAL', 'Z16_GRPTRI', 'Z16_COD' })

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
	Local oStr1:= FWFormStruct(2, 'Z16')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_Z16' , oStr1,'MODEL_Z16' ) 
	oView:CreateHorizontalBox( 'BOX_Z16', 100)
	oView:SetOwnerView('VIEW_Z16','BOX_Z16')

Return oView