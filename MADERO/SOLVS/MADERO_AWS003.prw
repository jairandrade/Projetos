#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} AWS003
//TODO Rotina para visualizar Ativa��o de Produtos
@author Mario L. B. Faria
@since 25/05/2018
@version 1.0
/*/
User Function AWS003()

	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("Z17")
	oBrowse:SetDescription("Ativa��o Produtos x Unidades")
	oBrowse:SetMenuDef("MADERO_AWS003")
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aAdd(aRotina,{'Visualizar'	,'VIEWDEF.MADERO_AWS003'	,0,2,0,NIL})
//	aAdd(aRotina,{'Incluir'		,'VIEWDEF.MADERO_AWS003'	,0,3,0,NIL})
//	aAdd(aRotina,{'Alterar'		,'VIEWDEF.MADERO_AWS003'	,0,4,0,NIL})
//	aAdd(aRotina,{'Excluir'		,'VIEWDEF.MADERO_AWS003'	,0,5,0,NIL})
//	aAdd(aRotina,{'Imprimir' 	,'VIEWDEF.MADERO_AWS003'	,0,8,0,NIL})
//	aAdd(aRotina,{'Copiar'		,'VIEWDEF.MADERO_AWS003'	,0,9,0,NIL})

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados

@author Mario L. B. Faria

@since 28/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel 
	Local oStr1:= FWFormStruct(1,'Z17')
	
	oModel := MPFormModel():New('MAIN_AWS003')
	oModel:SetDescription('Ativa��o Produtos x Unidades')
	oModel:addFields('MODEL_Z17',,oStr1)
	oModel:SetPrimaryKey({ 'Z17_FILIAL', 'Z17_COD' })

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do interface

@author Mario L. B. Faria

@since 28/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStr1:= FWFormStruct(2, 'Z17')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_Z17' , oStr1,'MODEL_Z17' ) 
	oView:CreateHorizontalBox( 'BOX_Z17', 100)
	oView:SetOwnerView('VIEW_Z17','BOX_Z17')

Return oView





