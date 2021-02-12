#include 'protheus.ch'
#Include "FwMvcDef.ch"
#Include 'parmtype.ch'
#Include "tbiconn.ch"
#Include "TbiCode.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include 'TOTVS.CH'

//==================================================================================================//
//	Programa: CADSZ3		|	Autor: Luis Paulo							|	Data: 10/02/2020	//
//==================================================================================================//
//	Descrição: Cadastro de Bloqueios de Produtos													//
//	-																								//
//==================================================================================================//
//KPFATA02 - SZ3010
User Function CADSZ3()
Local cAlias	:= "SZ3"
Local cDesc		:= "Cadastro de Bloqueios de Produtos"
Local cPessoas  := SuperGetMV('KP_ACRBLPR',.F., '000470/000287/000062/000304/000167/000309/000045/000199/000373/000404')
Private oBrowse := FwMBrowse():New() 

If !(__cUserID $ Alltrim(cPessoas))
    MsgAlert("Você não tem acesso a esta rotina!!!","Kapazi")
    Return
EndIf

oBrowse:SetAlias(cAlias)  			
oBrowse:SetDescripton(cDesc) 		
oBrowse:Activate()	

Return()


Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar' 		Action 'VIEWDEF.CADSZ3' 	OPERATION 2 ACCESS 0 
ADD OPTION aRotina Title 'Incluir' 			Action 'VIEWDEF.CADSZ3' 	OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar' 			Action 'VIEWDEF.CADSZ3' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir' 			Action 'VIEWDEF.CADSZ3' 	OPERATION 5 ACCESS 0

Return(aRotina)

Static Function ModelDef()
Local 	oModel 			

oModel 	:= MPFormModel():New("CADSZ3P",/*Pre-Validacao*/, ,/*Commit*/,/*Cancel*/)
oStruct := FWFormStruct(1,"SZ3",/*Definir se usa o campo(Ret t ou f)*/ )
oModel:AddFields('Enchoice_SZ3', /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetPrimaryKey({ "SZ3_FILIAL", "SZ3_FUNDO", "SZ3_BANCO","SZ3_AGENCI","SZ3_CONTA" })
oModel:SetDescription( 'Modelo de Dados de Bloqueios de Produtos' )

cTexto := 'Formulario de Movimentos de Bloqueios de Produtos'
oModel:GetModel( 'Enchoice_SZ3' ):SetDescription( cTexto )

Return(oModel)

Static Function ViewDef()
Local oStruct
Local oModel
Local oView

oStruct	:=	FWFormStruct(2,"SZ3") 	
oModel	:=	FwLoadModel('CADSZ3')	
oView	:=	FwFormView():New()      

oView:SetModel(oModel)
oView:AddField( 'VIEW_SZ3', oStruct, 'Enchoice_SZ3')
oView:CreateHorizontalBox("TELA",100)
oView:EnableTitleView('VIEW_SZ3', 'Movimentos de Bloqueios de Produtos' )
oView:SetOwnerView( 'VIEW_SZ3', 'TELA' )
//oView:SetCloseOnOk({||.T.})

Return(oView)

