#include 'protheus.ch'
#Include "Totvs.ch"
#Include "FwMvcDef.ch"

//==================================================================================================//
//	Programa: CADZS3		|	Autor: Luis Paulo							|	Data: 25/08/2018	//
//==================================================================================================//
//	Descrição: Formulario PV supplier																//
//																									//
//==================================================================================================//
User function CADZS3()
Local cAlias	:= "ZS3"
Local cDesc		:= "Supplier Card - Envio de Pedidos"
Local lEnable	:= .T.
Private oBrowse := FwMBrowse():New() //usar a classe ao invez da função // Declaração da classe

If cEmpAnt <> '04' 
	MsgInfo("Esta rotina funciona apenas para informações da empresa 04 (Industria)","KAPAZI - PEDIDOS DE VENDA SUPPLIER CARD")
	Return
EndIf

oBrowse:SetAlias(cAlias)  			// Define o alias de trabalho
oBrowse:SetDescripton(cDesc) 		// Define a Descricao
oBrowse:SetAmbiente(lEnable) 		// habilita menu ambiente
oBrowse:SetWalkThru(lEnable) 		// habilita menu walkthru
oBrowse:DisableDetails()  		// Detalhes do browse

//Filtrar somente os titulos nao integrados

//oBrowse:SetFilterDefault("ZS3_STATUS=='07'")//Adiciona um filtro ao browse

oBrowse:AddLegend( "ZS3_STATUS=='1'", "YELLOW"	, "PENDENTE" )
oBrowse:AddLegend( "ZS3_STATUS=='2'", "GREEN" 	, "VALIDADO" )

oBrowse:Activate()					//Ativamos a classe
Return()


Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'  			Action 'PesqBrw'   			OPERATION 1 ACCESS 0 DISABLE MENU
ADD OPTION aRotina Title 'Visualizar' 			Action 'VIEWDEF.CADZS3' 	OPERATION 2 ACCESS 0 //ACCESS É O NÍVEL DE ACESSO DO USUARIO
//ADD OPTION aRotina Title 'Alterar' 				Action 'VIEWDEF.CADZS3' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir' 				Action 'VIEWDEF.CADZS3' 	OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Gerar Arquivo'		Action 'U_KP97PE02' 		Operation 2 ACCESS 0
ADD OPTION aRotina Title 'REEnviar p/ Supplier'	Action 'U_KP97PR03' 		Operation 2 ACCESS 0
//ADD OPTION aRotina Title 'REEnviar p/ Supplier'	Action 'U_KP97PR01' 		Operation 2 ACCESS 0

Return(aRotina)


Static Function ModelDef()
Local 	oModel 				// Modelo de dados que será construído

//Definindo o controller
oModel := MPFormModel():New("CADZS3C",/*Pre-Validacao*/,,/*Commit*/,/*Cancel*/)

//Definindo Estrutura
oStruct := FWFormStruct(1,"ZS3",/*Definir se usa o campo(Ret t ou f)*/ )

//Adiciona um modelo de Formulario de Cadastro Similar à Enchoice ou Msmget
oModel:AddFields('Enchoice_ZS3', /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//Definindo Chave Primaria do Master. Necessário quando não existe no X2_UNICO
oModel:SetPrimaryKey({ "ZS3_FILIAL","ZS3_ITEM" })


//Adiciona Descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados - Envio de Pedidos Supplier Card' )

//Adiciona Descricao do Componente do Modelo de Dados
cTexto := 'Formulario de Envio de Pedidos Supplier Card'
oModel:GetModel( 'Enchoice_ZS3' ):SetDescription( cTexto )

Return(oModel)

Static Function ViewDef()
Local oStruct
Local oModel
Local oView

oStruct	:=	FWFormStruct(2,"ZS3") 	//Retorna a Estrutura do Alias passado
oModel	:=	FwLoadModel('CADZS3')	//Retorna o Objeto do Modelo de Dados- nome do fonte de onde queremos obter o modelo de dados
oView	:=	FwFormView():New()      //Instancia do Objeto de Visualização

//Define o Modelo sobre qual a Visualizacao sera utilizada
oView:SetModel(oModel)

//Vincula o Objeto visual de Cadastro com o modelo
oView:AddField( 'VIEW_ZS3', oStruct, 'Enchoice_ZS3')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox("TELA",100)

//Colocando título do formulário
oView:EnableTitleView('VIEW_ZS3', 'Ped_Venda_Supplier-VIEW' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZS3', 'TELA' )

//Força o fechamento da janela na confirmação
oView:SetCloseOnOk({||.T.})

Return(oView)