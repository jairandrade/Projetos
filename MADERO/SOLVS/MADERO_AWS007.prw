#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} AWS007
//TODO Rotina para visualizar Vendedores
@author Mario L. B. Faria
@since 25/05/2018
@version 1.0
/*/
User Function AWS007()

	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("Z15")
	oBrowse:SetDescription("Vendedores x Unidades")
	oBrowse:SetMenuDef("MADERO_AWS007")
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aAdd(aRotina,{'Visualizar'	,'VIEWDEF.MADERO_AWS007'	,0,2,0,NIL})
//	aAdd(aRotina,{'Incluir'		,'VIEWDEF.MADERO_AWS007'	,0,3,0,NIL})
//	aAdd(aRotina,{'Alterar'		,'VIEWDEF.MADERO_AWS007'	,0,4,0,NIL})
//	aAdd(aRotina,{'Excluir'		,'VIEWDEF.MADERO_AWS007'	,0,5,0,NIL})
//	aAdd(aRotina,{'Imprimir' 	,'VIEWDEF.MADERO_AWS007'	,0,8,0,NIL})
//	aAdd(aRotina,{'Copiar'		,'VIEWDEF.MADERO_AWS007'	,0,9,0,NIL})

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
	Local oStr1:= FWFormStruct(1,'Z15')
	
	oModel := MPFormModel():New('MAIN_AWS007')
	oModel:SetDescription('Vendedores x Unidades')
	oModel:addFields('MODEL_Z15',,oStr1)
	oModel:SetPrimaryKey({ 'Z15_FILIAL', 'Z15_COD' })

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
	Local oStr1:= FWFormStruct(2, 'Z15')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_Z15' , oStr1,'MODEL_Z15' ) 
	oView:CreateHorizontalBox( 'BOX_Z15', 100)
	oView:SetOwnerView('VIEW_Z15','BOX_Z15')

Return oView