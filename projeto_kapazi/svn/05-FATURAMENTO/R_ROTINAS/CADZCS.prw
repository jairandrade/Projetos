#include 'protheus.ch'
#Include "FwMvcDef.ch"
#Include 'parmtype.ch'
#Include "tbiconn.ch"
#Include "TbiCode.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include 'TOTVS.CH'
//==================================================================================================//
//	Programa: CADZCS		|	Autor: Luis Paulo							|	Data: 09/02/2020	//
//==================================================================================================//
//	Descrição: Cadastro de canal x segmentos														//
//	-																								//
//==================================================================================================//
User Function CADZCS()
Local cAlias	:= "ZCS"
Local cDesc		:= "Cadastro de Canal x Segmentos"
Private oBrowse := FwMBrowse():New() 

oBrowse:SetAlias(cAlias)  			
oBrowse:SetDescripton(cDesc) 		
oBrowse:Activate()	

Return()


Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar' 		Action 'VIEWDEF.CADZCS' 	OPERATION 2 ACCESS 0 
ADD OPTION aRotina Title 'Incluir' 			Action 'VIEWDEF.CADZCS' 	OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar' 			Action 'VIEWDEF.CADZCS' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir' 			Action 'VIEWDEF.CADZCS' 	OPERATION 5 ACCESS 0

Return(aRotina)

Static Function ModelDef()
Local 	oModel 			

oModel 	:= MPFormModel():New("CADZCSP",/*Pre-Validacao*/, ,/*Commit*/,/*Cancel*/)
oStruct := FWFormStruct(1,"ZCS",/*Definir se usa o campo(Ret t ou f)*/ )
oModel:AddFields('Enchoice_ZCS', /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetPrimaryKey({ "ZCS_FILIAL", "ZCS_CANAL", "ZCS_SEGMEN"})
oModel:SetDescription( 'Modelo de Dados de Canal x Segmentos' )

cTexto := 'Formulario de Movimentos de Canal x Segmentos'
oModel:GetModel( 'Enchoice_ZCS' ):SetDescription( cTexto )

Return(oModel)

Static Function ViewDef()
Local oStruct
Local oModel
Local oView

oStruct	:=	FWFormStruct(2,"ZCS") 	
oModel	:=	FwLoadModel('CADZCS')	
oView	:=	FwFormView():New()      

oView:SetModel(oModel)
oView:AddField( 'VIEW_ZCS', oStruct, 'Enchoice_ZCS')
oView:CreateHorizontalBox("TELA",100)
oView:EnableTitleView('VIEW_ZCS', 'Movimentos de Canal x Segmentos' )
oView:SetOwnerView( 'VIEW_ZCS', 'TELA' )
//oView:SetCloseOnOk({||.T.})

Return(oView)

