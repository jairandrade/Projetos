#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} AWS008
//TODO Rotina para visualizar Credenciadoras de Cartão
@author Mario L. B. Faria
@since 25/05/2018
@version 1.0
/*/
User Function AWS009()

	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("Z31")
	oBrowse:SetDescription("Credenciadoras de Cartão")
	oBrowse:SetMenuDef("MADERO_AWS009")
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aAdd(aRotina,{'Visualizar'	,'VIEWDEF.MADERO_AWS009'	,0,2,0,NIL})
//	aAdd(aRotina,{'Incluir'		,'VIEWDEF.MADERO_AWS009'	,0,3,0,NIL})
//	aAdd(aRotina,{'Alterar'		,'VIEWDEF.MADERO_AWS009'	,0,4,0,NIL})
//	aAdd(aRotina,{'Excluir'		,'VIEWDEF.MADERO_AWS009'	,0,5,0,NIL})
//	aAdd(aRotina,{'Imprimir' 	,'VIEWDEF.MADERO_AWS009'	,0,8,0,NIL})
//	aAdd(aRotina,{'Copiar'		,'VIEWDEF.MADERO_AWS009'	,0,9,0,NIL})

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
	Local oStr1:= FWFormStruct(1,'Z31')
	
	oModel := MPFormModel():New('MAIN_AWS009')
	oModel:SetDescription('Credenciadoras de Cartão')
	oModel:addFields('MODEL_Z31',,oStr1)
	oModel:SetPrimaryKey({ 'Z31_FILIAL', 'Z31_CODIGO' })

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
	Local oStr1:= FWFormStruct(2, 'Z31')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_Z31' , oStr1,'MODEL_Z31' ) 
	oView:CreateHorizontalBox( 'BOX_Z31', 100)
	oView:SetOwnerView('VIEW_Z31','BOX_Z31')

Return oView