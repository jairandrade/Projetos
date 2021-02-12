#include 'protheus.ch'
#Include "Totvs.ch"
#Include "FwMvcDef.ch"

//==================================================================================================//
//	Programa: CADZCL		|	Autor: Luis Paulo							|	Data: 19/09/2018	//
//==================================================================================================//
//	Descrição: Cadastro de limites																	//
//																									//
//==================================================================================================//
User function CADZCL()
Local cAlias	:= "ZCL"
Local cDesc		:= "Movimentacoes Limites e Log"
Local lEnable	:= .T.
Private oBrowse := FwMBrowse():New() //usar a classe ao invez da função // Declaração da classe

If cEmpAnt <> '04' 
	MsgAlert("Esta rotina funciona apenas para informações da empresa 04 (Industria)","KAPAZI - SUPPLIER CARD")
	Return
EndIf

oBrowse:SetAlias(cAlias)  			// Define o alias de trabalho
oBrowse:SetDescripton(cDesc) 		// Define a Descricao
oBrowse:SetAmbiente(lEnable) 		// habilita menu ambiente
oBrowse:SetWalkThru(lEnable) 		// habilita menu walkthru
oBrowse:DisableDetails()  		// Detalhes do browse

//Filtrar somente os titulos nao integrados
//oBrowse:AddLegend( "ZCL_STATUS=='1'", "YELLOW"	, "PENDENTE" )
//oBrowse:AddLegend( "ZCL_STATUS=='2'", "GREEN" 	, "VALIDADO" )

oBrowse:Activate()					//Ativamos a classe
Return()


Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'  			Action 'PesqBrw'   			OPERATION 1 ACCESS 0 DISABLE MENU
ADD OPTION aRotina Title 'Visualizar' 			Action 'VIEWDEF.CADZCL' 	OPERATION 2 ACCESS 0 //ACCESS É O NÍVEL DE ACESSO DO USUARIO
ADD OPTION aRotina Title 'Alterar' 				Action 'VIEWDEF.CADZCL' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir' 				Action 'VIEWDEF.CADZCL' 	OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Incluir' 				Action 'VIEWDEF.CADZCL' 	OPERATION 3 ACCESS 0

Return(aRotina)


Static Function ModelDef()
Local 	oModel 				// Modelo de dados que será construído

//Definindo o controller
oModel := MPFormModel():New("CADZCLC",/*Pre-Validacao*/,,/*Commit*/,/*Cancel*/)

//Definindo Estrutura
oStruct := FWFormStruct(1,"ZCL",/*Definir se usa o campo(Ret t ou f)*/ )

//Adiciona um modelo de Formulario de Cadastro Similar à Enchoice ou Msmget
oModel:AddFields('Enchoice_ZCL', /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//Definindo Chave Primaria do Master. Necessário quando não existe no X2_UNICO
oModel:SetPrimaryKey({ "ZCL_FILIAL","ZCL_CODIGO" })


//Adiciona Descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados Limites' )

//Adiciona Descricao do Componente do Modelo de Dados
cTexto := 'Formulario Limites Supplier'
oModel:GetModel( 'Enchoice_ZCL' ):SetDescription( cTexto )

Return(oModel)

Static Function ViewDef()
Local oStruct
Local oModel
Local oView

oStruct	:=	FWFormStruct(2,"ZCL") 	//Retorna a Estrutura do Alias passado
oModel	:=	FwLoadModel('CADZCL')	//Retorna o Objeto do Modelo de Dados- nome do fonte de onde queremos obter o modelo de dados
oView	:=	FwFormView():New()      //Instancia do Objeto de Visualização

//Define o Modelo sobre qual a Visualizacao sera utilizada
oView:SetModel(oModel)

//Vincula o Objeto visual de Cadastro com o modelo
oView:AddField( 'VIEW_ZCL', oStruct, 'Enchoice_ZCL')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox("TELA",100)

//Colocando título do formulário
oView:EnableTitleView('VIEW_ZCL', 'Limites-VIEW' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZCL', 'TELA' )

//Força o fechamento da janela na confirmação
oView:SetCloseOnOk({||.T.})

Return(oView)