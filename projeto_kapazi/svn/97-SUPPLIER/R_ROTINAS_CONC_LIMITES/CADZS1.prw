#include 'protheus.ch'
#Include "Totvs.ch"
#Include "FwMvcDef.ch"

//==================================================================================================//
//	Programa: CADZS1		|	Autor: Luis Paulo							|	Data: 26/07/2018	//
//==================================================================================================//
//	Descri��o: Formulario concessao de limites														//
//																									//
//==================================================================================================//
User function CADZS1()
Local cAlias	:= "ZS1"
Local cDesc		:= "Integracao Supplier - Concess�o de Limites"
Local lEnable	:= .T.
Private oBrowse := FwMBrowse():New() //usar a classe ao invez da fun��o // Declara��o da classe

If cEmpAnt <> '04' 
	MsgAlert("Esta rotina funciona apenas para informa��es da empresa 04 (Industria)","KAPAZI - SUPPLIER CARD")
	Return
EndIf

oBrowse:SetAlias(cAlias)  			// Define o alias de trabalho
oBrowse:SetDescripton(cDesc) 		// Define a Descricao
oBrowse:SetAmbiente(lEnable) 		// habilita menu ambiente
oBrowse:SetWalkThru(lEnable) 		// habilita menu walkthru
oBrowse:DisableDetails()  		// Detalhes do browse

//Filtrar somente os titulos nao integrados

//oBrowse:SetFilterDefault("ZS1_STATUS=='07'")//Adiciona um filtro ao browse

oBrowse:AddLegend( "ZS1_STATUS=='1'", "YELLOW"	, "PENDENTE" )
oBrowse:AddLegend( "ZS1_STATUS=='2'", "GREEN" 	, "VALIDADO" )

oBrowse:Activate()					//Ativamos a classe
Return()


Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'  			Action 'PesqBrw'   			OPERATION 1 ACCESS 0 DISABLE MENU
ADD OPTION aRotina Title 'Visualizar' 			Action 'VIEWDEF.CADZS1' 	OPERATION 2 ACCESS 0 //ACCESS � O N�VEL DE ACESSO DO USUARIO
ADD OPTION aRotina Title 'Alterar' 				Action 'VIEWDEF.CADZS1' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir' 				Action 'VIEWDEF.CADZS1' 	OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Enviar p/ Supplier'	Action 'U_KP97PE00' 		Operation 2 ACCESS 0
ADD OPTION aRotina Title 'REEnviar p/ Supplier'	Action 'U_KP97PR00' 		Operation 2 ACCESS 0
ADD OPTION aRotina Title 'Atual dados Cliente'	Action 'U_KP97ATUD' 		Operation 4 ACCESS 0
ADD OPTION aRotina Title 'Log'					Action 'U_CADZL1' 			Operation 2 ACCESS 0


Return(aRotina)


Static Function ModelDef()
Local 	oModel 				// Modelo de dados que ser� constru�do

//Definindo o controller
oModel := MPFormModel():New("CADZS1C",/*Pre-Validacao*/,,/*Commit*/,/*Cancel*/)

//Definindo Estrutura
oStruct := FWFormStruct(1,"ZS1",/*Definir se usa o campo(Ret t ou f)*/ )

//Adiciona um modelo de Formulario de Cadastro Similar � Enchoice ou Msmget
oModel:AddFields('Enchoice_ZS1', /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//Definindo Chave Primaria do Master. Necess�rio quando n�o existe no X2_UNICO
oModel:SetPrimaryKey({ "ZS1_FILIAL","ZS1_ITEM" })


//Adiciona Descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados do Carga Inicial Supplier' )

//Adiciona Descricao do Componente do Modelo de Dados
cTexto := 'Formulario de carga inicial supplier'
oModel:GetModel( 'Enchoice_ZS1' ):SetDescription( cTexto )

Return(oModel)

Static Function ViewDef()
Local oStruct
Local oModel
Local oView

oStruct	:=	FWFormStruct(2,"ZS1") 	//Retorna a Estrutura do Alias passado
oModel	:=	FwLoadModel('CADZS1')	//Retorna o Objeto do Modelo de Dados- nome do fonte de onde queremos obter o modelo de dados
oView	:=	FwFormView():New()      //Instancia do Objeto de Visualiza��o

//Define o Modelo sobre qual a Visualizacao sera utilizada
oView:SetModel(oModel)

//Vincula o Objeto visual de Cadastro com o modelo
oView:AddField( 'VIEW_ZS1', oStruct, 'Enchoice_ZS1')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox("TELA",100)

//Colocando t�tulo do formul�rio
oView:EnableTitleView('VIEW_ZS1', 'Dados de senha-VIEW' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZS1', 'TELA' )

//For�a o fechamento da janela na confirma��o
oView:SetCloseOnOk({||.T.})

Return(oView)