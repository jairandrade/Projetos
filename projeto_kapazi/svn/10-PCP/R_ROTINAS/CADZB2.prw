#include 'protheus.ch'
#Include "FwMvcDef.ch"
#Include 'parmtype.ch'
#Include "tbiconn.ch"
#Include "TbiCode.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include 'TOTVS.CH'
//==================================================================================================//
//	Programa: CADZB2		|	Autor: Luis Paulo							|	Data: 22/09/2020	//
//==================================================================================================//
//	Descricao: Configuracao de Sobras														        //
//	-																								//
//==================================================================================================//
User Function CADZB2()
Local cAlias	:= "ZB2"
Local cDesc		:= "Configuracao de Sobras/perdas de prod"
Private oBrowse := FwMBrowse():New() 

oBrowse:SetAlias(cAlias)  			
oBrowse:SetDescripton(cDesc) 		
oBrowse:Activate()	

Return()


Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar' 		Action 'VIEWDEF.CADZB2' 	OPERATION 2 ACCESS 0 
ADD OPTION aRotina Title 'Incluir' 			Action 'VIEWDEF.CADZB2' 	OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar' 			Action 'VIEWDEF.CADZB2' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir' 			Action 'VIEWDEF.CADZB2' 	OPERATION 5 ACCESS 0

Return(aRotina)

Static Function ModelDef()
Local 	oModel 			

oModel 	:= MPFormModel():New("CADZB2P",/*Pre-Validacao*/, ,/*Commit*/,/*Cancel*/)
oStruct := FWFormStruct(1,"ZB2",/*Definir se usa o campo(Ret t ou f)*/ )
oModel:AddFields('Enchoice_ZB2', /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetPrimaryKey({ "ZB2_FILIAL", "ZB2_COD", "ZB2_PROD"})
oModel:SetDescription( 'Modelo de Dados perdas' )

cTexto := 'Formulario de perdas'
oModel:GetModel( 'Enchoice_ZB2' ):SetDescription( cTexto )

Return(oModel)

Static Function ViewDef()
Local oStruct
Local oModel
Local oView

oStruct	:=	FWFormStruct(2,"ZB2") 	
oModel	:=	FwLoadModel('CADZB2')	
oView	:=	FwFormView():New()      

oView:SetModel(oModel)
oView:AddField( 'VIEW_ZB2', oStruct, 'Enchoice_ZB2')
oView:CreateHorizontalBox("TELA",100)
oView:EnableTitleView('VIEW_ZB2', 'Movimentos de perdas' )
oView:SetOwnerView( 'VIEW_ZB2', 'TELA' )
//oView:SetCloseOnOk({||.T.})

Return(oView)

