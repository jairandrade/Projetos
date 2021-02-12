#include 'protheus.ch'
#Include "Totvs.ch"
#Include "FwMvcDef.ch"
#include "tbiconn.ch"
#include "TbiCode.ch"
#include "TOPCONN.CH"

//==================================================================================================//
//	Programa: CADZAT		|	Autor: Luis Paulo							|	Data: 08/06/2019	//
//==================================================================================================//
//	Descrição: FWMBROWSER MODELO 1 CAD AMARRACAO UF X ATENDENTES									//
//																									//
//==================================================================================================//
User function CADZAT()
Local cAlias	:= "ZAT"
Local cDesc		:= "Cad UF x Atendente"
Local lEnable	:= .T.
Local lAtiva	:= .t.

Private oBrowse //:= FwMBrowse():New() //usar a classe ao invez da função // Declaração da classe

If !lAtiva
	MsgInfO("Rotina desativada!")
	Return
EndIf

oBrowse := FwMBrowse():New() //usar a classe ao invez da função // Declaração da classe
oBrowse:SetAlias(cAlias)  			// Define o alias de trabalho
oBrowse:SetDescripton(cDesc) 		// Define a Descricao
oBrowse:SetAmbiente(lEnable) 		// habilita menu ambiente
oBrowse:SetWalkThru(lEnable) 		// habilita menu walkthru
oBrowse:DisableDetails()  		// Detalhes do browse

oBrowse:AddLegend( "ZAT_STATUS=='1'", "GREEN"	, "ATIVO" )
oBrowse:AddLegend( "ZAT_STATUS=='2'", "RED"	`	, "INATIVO" )

oBrowse:Activate()					//Ativamos a classe

Return()


Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'  		Action 'PesqBrw'   				OPERATION 1 ACCESS 0 DISABLE MENU
ADD OPTION aRotina Title 'Visualizar' 		Action 'VIEWDEF.CADZAT' 		OPERATION 2 ACCESS 0 //ACCESS É O NÍVEL DE ACESSO DO USUARIO
ADD OPTION aRotina Title 'Incluir' 			Action 'VIEWDEF.CADZAT' 		OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar' 			Action 'VIEWDEF.CADZAT' 		OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Imprimir' 		Action 'VIEWDEF.CADZAT' 		OPERATION 8 ACCESS 0
ADD OPTION aRotina Title 'Excluir' 			Action 'VIEWDEF.CADZAT' 		OPERATION 5 ACCESS 0

Return(aRotina)


Static Function ModelDef()
Local 	oModel 				// Modelo de dados que será construído
Local 	aAux

//Definindo o controller
//oModel := MPFormModel():New("CADZATC",/*Pre-Validacao*/,{|oModel| ZATTOK(oModel)},/*Commit*/,/*Cancel*/)
oModel := MPFormModel():New("CADZATC",/*Pre-Validacao*/,,/*Commit*/,/*Cancel*/)

//Definindo Estrutura
oStruct := FWFormStruct(1,"ZAT",/*Definir se usa o campo(Ret t ou f)*/ )

//Adiciona um modelo de Formulario de Cadastro Similar à Enchoice ou Msmget
oModel:AddFields('Enchoice_ZAT', /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//Definindo Chave Primaria do Master. Necessário quando não existe no X2_UNICO
oModel:SetPrimaryKey({ "ZAT_FILIAL","ZAT_UF","ZAT_CDATEN" })

//Adiciona Descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados - UF X ATENDENTES' )

//Adiciona Descricao do Componente do Modelo de Dados
cTexto := 'Formulario de Cadastro UF X ATENDENTES'
oModel:GetModel( 'Enchoice_ZAT' ):SetDescription( cTexto )

Return(oModel)

Static Function ViewDef()
Local oStruct
Local oModel
Local oView

oStruct	:=	FWFormStruct(2,"ZAT") 	//Retorna a Estrutura do Alias passado
oModel	:=	FwLoadModel('CADZAT')	//Retorna o Objeto do Modelo de Dados- nome do fonte de onde queremos obter o modelo de dados
oView		:=	FwFormView():New()      //Instancia do Objeto de Visualização

//Define o Modelo sobre qual a Visualizacao sera utilizada
oView:SetModel(oModel)

//Vincula o Objeto visual de Cadastro com o modelo
oView:AddField( 'VIEW_ZAT', oStruct, 'Enchoice_ZAT')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox("TELA",100)

//Colocando título do formulário
oView:EnableTitleView('VIEW_ZAT', 'UF X ATENDENTES' )

//Força o fechamento da janela na confirmação
//oView:SetCloseOnOk({||.T.})

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZAT', 'TELA' )

//Força o fechamento da janela na confirmação
oView:SetCloseOnOk({||.T.})

Return(oView)


/*Ponto de entrada da rotina*/
User Function CADZATC()
Local aParam	:=	PARAMIXB
Local oObj		:=	aParam[1]     // OBJETO
Local cIdPonto	:=	aParam[2]     // ID DO PONTO DE ENTRADA
Local cIdObj	:=	oObj:GetId()
Local cClasse   :=  oObj:ClassName()
Local nQtdLinhas:= 	0
Local nLinha    := 	0
Local xRet		:=	Nil

xRet	:= .t.
Return xRet


Static Function ZATTOK(oModel)
Local lRet				:= .T.
Local oModel 			:= FWModelActive()
Local oModelZAT 		:= oModel:GetModel( 'Enchoice_ZAT' )
Local cCodCL			:= oModel:GetValue( 'Enchoice_ZAT', 'ZAT_CLIENT' )
Local cCodLJ			:= oModel:GetValue( 'Enchoice_ZAT', 'ZAT_CLILOJ' )
Local nCodPO			:= oModel:GetValue( 'Enchoice_ZAT', 'ZAT_PORCPR' )
Local cCodPR			:= oModel:GetValue( 'Enchoice_ZAT', 'ZAT_PROD' )
Local cStatus			:= oModel:GetValue( 'Enchoice_ZAT', 'ZAT_STATUS' )
Local nOperation 		:= oModel:GetOperation()
Local aArea				:= GetArea()

/*
If oModel:Getoperation() == 4

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())
	If !SA1->(DbSeek(xFilial("SA1")+cCodCL+cCodLJ))
		Help( ,, 'Alteracao de dados',, 'Cliente não localizado, favor verificar o codigo e loja!', 1, 0 )
		lRet				:= .F.
	EndIf
	
	If Empty(nCodPO)
		Help( ,, 'Alteracao de dados',, 'Porcentagem do produto serviço nao informada!', 1, 0 )
		lRet				:= .F.
	EndIf
	
	If Empty(cCodPR)
		Help( ,, 'Alteracao de dados',, 'Informe o produto!', 1, 0 )
		lRet				:= .F.
	EndIf
	
	If !lBuscar(cCodCL,cCodLJ,cCodPR,cStatus)
			Help( ,, 'Alteracao de dados',, 'Já existe o cadastro desse cliente x prod!', 1, 0 )
			lRet				:= .F.
	EndIf
	
EndIf
*/
If oModel:GetOperation() == 3

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())
	If !SA1->(DbSeek(xFilial("SA1")+cCodCL+cCodLJ))
		Help( ,, 'Inclusao de dados',, 'Cliente não localizado, favor verificar o codigo e loja!', 1, 0 )
		lRet				:= .F.
	EndIf
	
	If Empty(nCodPO)
		Help( ,, 'Inclusao de dados',, 'Porcentagem do produto serviço nao informada!', 1, 0 )
		lRet				:= .F.
	EndIf
	
	If Empty(cCodPR)
		Help( ,, 'Alteracao de dados',, 'Informe o produto!', 1, 0 )
		lRet				:= .F.
	EndIf
	
	If !lBuscar(cCodCL,cCodLJ,cCodPR,cStatus)
			Help( ,, 'Inclusao de dados',, 'Já existe o cadastro desse cliente x prod!', 1, 0 )
			lRet				:= .F.
	EndIf
	
EndIf

RestArea(aArea)
Return(lRet)



Static Function lBuscar(cCodCL,cCodLJ,cCodPR,cStatus)
Local cQr 				:= ""
Local cAliasPV

If Select("cAliasPV") <> 0
	DBSelectArea("cAliasPV")
	cAliasPV->(DBCloseArea())
Endif

cAliasPV		:= GetNextAlias()

cQr	+= " SELECT *
cQr	+= " FROM ZAT040
cQr	+= " WHERE D_E_L_E_T_ = ''
cQr	+= " AND ZAT_CLIENT = '"+cCodCL+"'
cQr	+= " AND ZAT_CLILOJ = '"+cCodLJ+"'
cQr	+= " AND ZAT_PROD   = '"+cCodPR+"'
cQr	+= " AND ZAT_STATUS = '1'

TcQuery cQr new alias "cAliasPV"
cAliasPV->(DbGoTop())

Return(cAliasPV->(EOF()))

