#include 'protheus.ch'
#Include "Totvs.ch"
#Include "FwMvcDef.ch"

//==================================================================================================//
//	Programa: CADZS5		|	Autor: Luis Paulo							|	Data: 07/08/2018	//
//==================================================================================================//
//	Descri��o: Formulario Ren Pre autorizacao														//
//																									//
//==================================================================================================//
User function CADZS5()
Local cAlias	:= "ZS5"
Local cDesc		:= "Supplier Card - Ren Pr� Aut Pedidos de Venda de pedidos"
Local lEnable	:= .T.
Private oBrowse := FwMBrowse():New() //usar a classe ao invez da fun��o // Declara��o da classe

If cEmpAnt <> '04' 
	MsgInfo("Esta rotina funciona apenas para informa��es da empresa 04 (Industria)","KAPAZI -  REN PR�-AUT PEDIDOS DE VENDA SUPPLIER CARD")
	Return
EndIf

oBrowse:SetAlias(cAlias)  			// Define o alias de trabalho
oBrowse:SetDescripton(cDesc) 		// Define a Descricao
oBrowse:SetAmbiente(lEnable) 		// habilita menu ambiente
oBrowse:SetWalkThru(lEnable) 		// habilita menu walkthru
oBrowse:DisableDetails()  		// Detalhes do browse

//Filtrar somente os titulos nao integrados

//oBrowse:SetFilterDefault("ZS5_STATUS=='07'")//Adiciona um filtro ao browse

oBrowse:AddLegend( "ZS5_STATUS=='1'", "YELLOW"	, "PENDENTE" )
oBrowse:AddLegend( "ZS5_STATUS=='2'", "GREEN" 	, "VALIDADO" )

oBrowse:Activate()					//Ativamos a classe
Return()


Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'  			Action 'PesqBrw'   			OPERATION 1 ACCESS 0 DISABLE MENU
ADD OPTION aRotina Title 'Visualizar' 			Action 'VIEWDEF.CADZS5' 	OPERATION 2 ACCESS 0 //ACCESS � O N�VEL DE ACESSO DO USUARIO
//ADD OPTION aRotina Title 'Alterar' 				Action 'VIEWDEF.CADZS5' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir' 				Action 'VIEWDEF.CADZS5' 	OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Gerar Arquivo'		Action 'U_KP97PE05' 		Operation 2 ACCESS 0
ADD OPTION aRotina Title 'REEnviar p/ Supplier'	Action 'U_KP97PR04' 		Operation 2 ACCESS 0

Return(aRotina)


Static Function ModelDef()
Local 	oModel 				// Modelo de dados que ser� constru�do

//Definindo o controller
oModel := MPFormModel():New("CADZS5C",/*Pre-Validacao*/,,/*Commit*/,/*Cancel*/)

//Definindo Estrutura
oStruct := FWFormStruct(1,"ZS5",/*Definir se usa o campo(Ret t ou f)*/ )

//Adiciona um modelo de Formulario de Cadastro Similar � Enchoice ou Msmget
oModel:AddFields('Enchoice_ZS5', /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//Definindo Chave Primaria do Master. Necess�rio quando n�o existe no X2_UNICO
oModel:SetPrimaryKey({ "ZS5_FILIAL","ZS5_ITEM" })


//Adiciona Descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados - Envio de Pedidos Supplier Card' )

//Adiciona Descricao do Componente do Modelo de Dados
cTexto := 'Formulario de Envio de Pedidos Supplier Card'
oModel:GetModel( 'Enchoice_ZS5' ):SetDescription( cTexto )

Return(oModel)

Static Function ViewDef()
Local oStruct
Local oModel
Local oView

oStruct	:=	FWFormStruct(2,"ZS5") 	//Retorna a Estrutura do Alias passado
oModel	:=	FwLoadModel('CADZS5')	//Retorna o Objeto do Modelo de Dados- nome do fonte de onde queremos obter o modelo de dados
oView	:=	FwFormView():New()      //Instancia do Objeto de Visualiza��o

//Define o Modelo sobre qual a Visualizacao sera utilizada
oView:SetModel(oModel)

//Vincula o Objeto visual de Cadastro com o modelo
oView:AddField( 'VIEW_ZS5', oStruct, 'Enchoice_ZS5')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox("TELA",100)

//Colocando t�tulo do formul�rio
oView:EnableTitleView('VIEW_ZS5', 'Ped_Venda_Supplier-VIEW' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZS5', 'TELA' )

//For�a o fechamento da janela na confirma��o
oView:SetCloseOnOk({||.T.})

Return(oView)