#include 'protheus.ch'
#Include "Totvs.ch"
#Include "FwMvcDef.ch"
//==================================================================================================//
//	Programa: CADZS6		|	Autor: Luis Paulo							|	Data: 16/09/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel por processar os registro pendentes de envio para  supplier		//
//	NF Supplier																								//
//==================================================================================================//
User Function CADZS6()
Local cAlias	:= "ZS6"
Local cDesc		:= "Integracao Supplier - Faturamento"
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

//oBrowse:SetFilterDefault("ZS6_STATUS=='07'")//Adiciona um filtro ao browse

oBrowse:AddLegend( "ZS6_STATUS=='1'", "YELLOW"	, "PENDENTE" )
oBrowse:AddLegend( "ZS6_STATUS=='2'", "GREEN" 	, "VALIDADO" )

oBrowse:Activate()					//Ativamos a classe
Return()


Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'  			Action 'PesqBrw'   			OPERATION 1 ACCESS 0 DISABLE MENU
ADD OPTION aRotina Title 'Visualizar' 			Action 'VIEWDEF.CADZS6' 	OPERATION 2 ACCESS 0 //ACCESS É O NÍVEL DE ACESSO DO USUARIO
ADD OPTION aRotina Title 'Alterar' 				Action 'VIEWDEF.CADZS6' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir' 				Action 'VIEWDEF.CADZS6' 	OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Gerar Arquivo'		Action 'U_KP97PE06' 		Operation 2 ACCESS 0
ADD OPTION aRotina Title 'REEnviar p/ Supplier'	Action 'U_KP97PR05' 		Operation 2 ACCESS 0

Return(aRotina)


Static Function ModelDef()
Local 	oModel 				// Modelo de dados que será construído

//Definindo o controller
oModel := MPFormModel():New("CADZS6C",/*Pre-Validacao*/,,/*Commit*/,/*Cancel*/)

//Definindo Estrutura
oStruct := FWFormStruct(1,"ZS6",/*Definir se usa o campo(Ret t ou f)*/ )

//Adiciona um modelo de Formulario de Cadastro Similar à Enchoice ou Msmget
oModel:AddFields('Enchoice_ZS6', /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//Definindo Chave Primaria do Master. Necessário quando não existe no X2_UNICO
oModel:SetPrimaryKey({ "ZS6_FILIAL","ZS6_ITEM" })


//Adiciona Descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados Faturamento Supplier' )

//Adiciona Descricao do Componente do Modelo de Dados
cTexto := 'Formulario Faturamento supplier'
oModel:GetModel( 'Enchoice_ZS6' ):SetDescription( cTexto )

Return(oModel)

Static Function ViewDef()
Local oStruct
Local oModel
Local oView

oStruct	:=	FWFormStruct(2,"ZS6") 	//Retorna a Estrutura do Alias passado
oModel	:=	FwLoadModel('CADZS6')	//Retorna o Objeto do Modelo de Dados- nome do fonte de onde queremos obter o modelo de dados
oView	:=	FwFormView():New()      //Instancia do Objeto de Visualização

//Define o Modelo sobre qual a Visualizacao sera utilizada
oView:SetModel(oModel)

//Vincula o Objeto visual de Cadastro com o modelo
oView:AddField( 'VIEW_ZS6', oStruct, 'Enchoice_ZS6')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox("TELA",100)

//Colocando título do formulário
oView:EnableTitleView('VIEW_ZS6', 'Dados de Faturamento-VIEW' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZS6', 'TELA' )

//Força o fechamento da janela na confirmação
oView:SetCloseOnOk({||.T.})

Return(oView)