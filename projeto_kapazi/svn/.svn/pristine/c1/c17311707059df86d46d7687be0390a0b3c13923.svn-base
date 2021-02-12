#include 'protheus.ch'
#Include "Totvs.ch"
#Include "FwMvcDef.ch"
#include "tbiconn.ch"
#include "TbiCode.ch"
#include "TOPCONN.CH"

//==================================================================================================//
//	Programa: CadZPV		|	Autor: Luis Paulo							|	Data: 29/12/2017	//
//==================================================================================================//
//	Descrição: FWMBROWSER MODELO 1 CAD AMARRACAO PROD X CLIENT X SERVIÇOS							//
//																									//
//==================================================================================================//
User function CadZPV()
Local cAlias	:= "ZPV"
Local cDesc		:= "Prod x Cli x Servicos"
Local lEnable	:= .T.
Private oBrowse //:= FwMBrowse():New() //usar a classe ao invez da função // Declaração da classe

If cEmpAnt <> '04'
	MsgAlert("Acesso somente pela empresa 04!!")
	Return
EndIf

oBrowse := FwMBrowse():New() //usar a classe ao invez da função // Declaração da classe
oBrowse:SetAlias(cAlias)  			// Define o alias de trabalho
oBrowse:SetDescripton(cDesc) 		// Define a Descricao
oBrowse:SetAmbiente(lEnable) 		// habilita menu ambiente
oBrowse:SetWalkThru(lEnable) 		// habilita menu walkthru
oBrowse:DisableDetails()  		// Detalhes do browse

oBrowse:AddLegend( "ZPV_STATUS=='1'", "GREEN"	, "ATIVO" )
oBrowse:AddLegend( "ZPV_STATUS=='2'", "RED"	`	, "INATIVO" )

oBrowse:Activate()					//Ativamos a classe

Return()


Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'  		Action 'PesqBrw'   				OPERATION 1 ACCESS 0 DISABLE MENU
ADD OPTION aRotina Title 'Visualizar' 		Action 'VIEWDEF.CadZPV' 		OPERATION 2 ACCESS 0 //ACCESS É O NÍVEL DE ACESSO DO USUARIO
ADD OPTION aRotina Title 'Incluir' 			Action 'VIEWDEF.CadZPV' 		OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar' 			Action 'VIEWDEF.CadZPV' 		OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Imprimir' 		Action 'VIEWDEF.CadZPV' 		OPERATION 8 ACCESS 0
ADD OPTION aRotina Title 'Excluir' 			Action 'VIEWDEF.CadZPV' 		OPERATION 5 ACCESS 0

Return(aRotina)


Static Function ModelDef()
Local 	oModel 				// Modelo de dados que será construído
Local 	aAux

//Definindo o controller
oModel := MPFormModel():New("CadZPVC",/*Pre-Validacao*/,{|oModel| ZPVTOK(oModel)},/*Commit*/,/*Cancel*/)

//Definindo Estrutura
oStruct := FWFormStruct(1,"ZPV",/*Definir se usa o campo(Ret t ou f)*/ )


//oStruct:aTriggers := {}

//oStruct:AddTrigger('ZPV_CLIENT' , 'ZPV_CLIDES', {|| .T. } ,   {|oModel|Posicione("SA1",1,xFilial("SA1") + oModel:GetValue("ZPV_CLIENT") + oModel:GetValue("ZPV_CLILOJ"),"A1_NOME")})      
/*
aAux := FwStruTrigger(;
				"ZPV_CLIENT", ;                                                     // [01] Id do campo de origem
				"ZPV_CLIDES" , ;                                                   // [02] Id do campo de destino
				'U_GTCLIZPV()')

oStruct:AddTrigger( ;
											aAux[1], ;                                                      // [01] Id do campo de origem
											aAux[2], ;                                                      // [02] Id do campo de destino
											aAux[3], ;                                                      // [03] Bloco de codigo de validação da execução do gatilho
											aAux[4] )                                                       // [04] Bloco de codigo de execução do gatilho
*/

oStruct:AddTrigger('ZPV_CLILOJ' , 'ZPV_CLIDES', {|| .T. } ,   {|oModel|Posicione("SA1",1,xFilial("SA1") + oModel:GetValue("ZPV_CLIENT") + oModel:GetValue("ZPV_CLILOJ"),"A1_NOME")})     
oStruct:AddTrigger('ZPV_PROD'  , 'ZPV_PRODDE', {|| .T. } ,   {|oModel|Posicione("SB1",1,xFilial("SB1") + oModel:GetValue("ZPV_PROD"),"B1_DESC")})     


//Adiciona um modelo de Formulario de Cadastro Similar à Enchoice ou Msmget
oModel:AddFields('Enchoice_ZPV', /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//Definindo Chave Primaria do Master. Necessário quando não existe no X2_UNICO
oModel:SetPrimaryKey({ "ZPV_FILIAL","ZPV_PROD","ZPV_PROD" })

//Adiciona Descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados - Cad Cli x Prod x Serv' )

//Adiciona Descricao do Componente do Modelo de Dados
cTexto := 'Formulario de Cadastro Cli x Prod x Serv'
oModel:GetModel( 'Enchoice_ZPV' ):SetDescription( cTexto )

Return(oModel)

Static Function ViewDef()
Local oStruct
Local oModel
Local oView

oStruct	:=	FWFormStruct(2,"ZPV") 	//Retorna a Estrutura do Alias passado
oModel	:=	FwLoadModel('CadZPV')	//Retorna o Objeto do Modelo de Dados- nome do fonte de onde queremos obter o modelo de dados
oView		:=	FwFormView():New()      //Instancia do Objeto de Visualização

//Define o Modelo sobre qual a Visualizacao sera utilizada
oView:SetModel(oModel)

//Vincula o Objeto visual de Cadastro com o modelo
oView:AddField( 'VIEW_ZPV', oStruct, 'Enchoice_ZPV')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox("TELA",100)

//Colocando título do formulário
oView:EnableTitleView('VIEW_ZPV', 'NF Mista' )

//Força o fechamento da janela na confirmação
//oView:SetCloseOnOk({||.T.})

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZPV', 'TELA' )

//Força o fechamento da janela na confirmação
oView:SetCloseOnOk({||.T.})

Return(oView)


/*Ponto de entrada da rotina*/
User Function CadZPVC()
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


Static Function ZPVTOK(oModel)
Local lRet				:= .T.
Local oModel 			:= FWModelActive()
Local oModelZPV 		:= oModel:GetModel( 'Enchoice_ZPV' )
Local cCodCL			:= oModel:GetValue( 'Enchoice_ZPV', 'ZPV_CLIENT' )
Local cCodLJ			:= oModel:GetValue( 'Enchoice_ZPV', 'ZPV_CLILOJ' )
Local nCodPO			:= oModel:GetValue( 'Enchoice_ZPV', 'ZPV_PORCPR' )
Local cCodPR			:= oModel:GetValue( 'Enchoice_ZPV', 'ZPV_PROD' )
Local cStatus			:= oModel:GetValue( 'Enchoice_ZPV', 'ZPV_STATUS' )
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
cQr	+= " FROM ZPV040
cQr	+= " WHERE D_E_L_E_T_ = ''
cQr	+= " AND ZPV_CLIENT = '"+cCodCL+"'
cQr	+= " AND ZPV_CLILOJ = '"+cCodLJ+"'
cQr	+= " AND ZPV_PROD   = '"+cCodPR+"'
cQr	+= " AND ZPV_STATUS = '1'

TcQuery cQr new alias "cAliasPV"
cAliasPV->(DbGoTop())

Return(cAliasPV->(EOF()))

