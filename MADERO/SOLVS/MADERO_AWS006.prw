#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} AWS006
//TODO Rotina para visualizar Estrutura de Produtos
@author Mario L. B. Faria
@since 25/05/2018
@version 1.0
/*/
User Function AWS006()

	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("Z14")
	oBrowse:SetDescription("Estrutura Produtos x Unidades")
	oBrowse:SetMenuDef("MADERO_AWS006")
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aAdd(aRotina,{'Visualizar'	,'VIEWDEF.MADERO_AWS006'	,0,2,0,NIL})
//	aAdd(aRotina,{'Incluir'		,'VIEWDEF.MADERO_AWS006'	,0,3,0,NIL})
//	aAdd(aRotina,{'Alterar'		,'VIEWDEF.MADERO _AWS006'	,0,4,0,NIL})
//	aAdd(aRotina,{'Excluir'		,'VIEWDEF.MADERO_AWS006'	,0,5,0,NIL})
//	aAdd(aRotina,{'Imprimir' 	,'VIEWDEF.MADERO_AWS006'	,0,8,0,NIL})
//	aAdd(aRotina,{'Copiar'		,'VIEWDEF.MADERO_AWS006'	,0,9,0,NIL})

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
	Local oStr1:= FWFormStruct(1,'Z14')
	
	oModel := MPFormModel():New('MAIN_AWS006')
	oModel:SetDescription('Estrutura de Produtos x Unidades')
	oModel:addFields('MODEL_Z14',,oStr1)
	oModel:SetPrimaryKey({ 'Z14_FILIAL', 'Z14_COD' })

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
	Local oStr1:= FWFormStruct(2, 'Z14')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_Z14' , oStr1,'MODEL_Z14' ) 
	oView:CreateHorizontalBox( 'BOX_Z14', 100)
	oView:SetOwnerView('VIEW_Z14','BOX_Z14')

Return oView