#Include "Totvs.ch"
#Include "ApWebSrv.ch"
#Include "TbiConn.ch"
#Include "TopConn.ch"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Anexo 1 : Estrutura WS Cliente  ³
//³---------------------------------³
//³ Campo			Tamanho	Tipo    ³
//³---------------------------------³
//³ CNPJ			14		char    ³
//³ RAZAOSOCIAL		160		char    ³
//³ NOMEFANTASIA	80		char    ³
//³ ESTADO 					int     ³
//³ TIPO 			5		char    ³
//³ INSESTADUAL		35		char    ³
//³ INSMUNICIPAL	35		char    ³
//³ DATANASC				date    ³
//³ HOMEPAGE 		120		char    ³
//³ DDD  			35		char    ³
//³ TELEFONE  		35		char    ³
//³ CEP 			9		char    ³
//³ EMAIL  			120		char    ³
//³ EMAILNFE  		120		char    ³
//³ ENDERECO		90		char    ³
//³ NUMERO  		60		char    ³
//³ BAIRRO  		100		char    ³
//³ COMPLEMENTO 	80		char    ³
//³ CODMUNICIPIO	20		char    ³
//³ OBSERVACAO 				text    ³
//³ VENDEDOR  		60		char    ³
//³ DATACADASTRO			date    ³
//³ SUFRAMA			80		char    ³
//³ INSRURAL		35		char    ³
//³ NUMERODW		60		char    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Contatos      ºAutor  ³ Welinton Martins  º Data ³ 20/12/17º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Encapsula a estrutura array em uma estrutura simples       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs.      ³ Nao e permitido o uso da instrução ARRAY OF quando         º±±
±±º          ³ declaramos dados utilizados para entrada de dados dentro   º±±
±±º          ³ da declaração do servico. Para tal, precisamos criar uma   º±±
±±º          ³ estrutura intermediaria para "encapsular" o array.         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ WebService Cliente                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSSTRUCT stWelContatos

	WSDATA Contatos	AS Array Of stContato	OPTIONAL
	
ENDWSSTRUCT

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ stContato     ºAutor  ³ Welinton Martins  º Data ³ 20/12/17º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Estrutura dos Contatos do Cliente                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObs.      ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ WebService Cliente                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSSTRUCT stContato

	WSDATA Nome			AS String
	WSDATA Telefone		AS String
	WSDATA Email		AS String
	WSDATA Cargo		AS String	OPTIONAL

ENDWSSTRUCT

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Empresa   ³ Welinton Martins (11) 99161-8225                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³Funcao    ³ U_WSFDV001³ Autor ³ Welinton Martins     ³ Data ³ 20/12/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Web Service Server, para integracao do sistema DW Forca de ³±±
±±³          ³ Vendas (Developweb X Protheus).                            ³±±
±±³          ³ Integracao Cliente.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.      ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ oWs := WSU_WSFDV001():New()                                ³±±
±±³          ³ oWs:AddCliente()                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE CONSTRUCAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Data      ³ Programador      ³ Manutencao efetuada                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  /  /    ³                  ³                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ WebService Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSSERVICE U_WSFDV001 DESCRIPTION "Integração Developweb X Protheus | Serviço de inclusão de Cliente" // NAMESPACE "http://"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campos utilizados pela aplicacao DWFDV ³
	//³ GET                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//--> Propriedades
	WSDATA CNPJ			 		AS String
	WSDATA RazaoSocial			AS String
	WSDATA NomeFantasia			AS String
	WSDATA Estado				AS String
	WSDATA Tipo					As String
	WSDATA InsEstadual			AS String
	WSDATA InsMunicipal			AS String OPTIONAL
	WSDATA DataNasc				AS Date
	WSDATA HomePage	   			AS String OPTIONAL
	WSDATA DDD		 			AS String
	WSDATA Telefone	  			AS String
	WSDATA CEP		 			AS String
	WSDATA Email	 			AS String
	WSDATA EmailNFe	 			AS String OPTIONAL
	WSDATA Endereco	 			AS String
	WSDATA Numero	 			AS String
	WSDATA Bairro				AS String
	WSDATA Complemento	  		AS String OPTIONAL
	WSDATA CodMunicipio			AS String
	WSDATA Observacao			AS String OPTIONAL
	WSDATA Vendedor				AS String
	WSDATA DataCadastro			AS Date
	WSDATA Suframa				AS String OPTIONAL
	WSDATA InsRural	   			AS String OPTIONAL
	WSDATA NumeroDW	   			AS String
	
	//--> Estruturas
	WSDATA ClienteContatos		AS stWelContatos OPTIONAL
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorno do WebService ³
	//³ RET                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	WSDATA RETORNO	   			AS String

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Metodos do WebService ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	WSMETHOD AddCliente		DESCRIPTION "Método de Inclusão de Cliente - SA1"

ENDWSSERVICE

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Empresa   ³ Welinton Martins (11) 99161-8225                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³Funcao    ³ AddCliente ³ Autor ³ Welinton Martins    ³ Data ³ 20/12/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Metodo para Inclusao do Cliente.                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.      ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ oWS.AddCliente()                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Vide Anexo 1 : Estrutura WS Cliente.                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE CONSTRUCAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Data      ³ Programador      ³ Manutencao efetuada                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  /  /    ³                  ³                                         ³±±
±±³          ³                  ³                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ WebService Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD AddCliente WSRECEIVE CNPJ, RazaoSocial, NomeFantasia, Estado, Tipo, InsEstadual, InsMunicipal, DataNasc, HomePage, DDD, Telefone, CEP, Email, EmailNFe, Endereco, Numero, Bairro, Complemento, CodMunicipio, Observacao, Vendedor, DataCadastro, Suframa, InsRural, NumeroDW, ClienteContatos	WSSEND RETORNO WSSERVICE U_WSFDV001

	Local cCNPJ		:= U_UnMaskCNPJ(::CNPJ)
	Local cRazao	:= Upper(IIf(FindFunction("U_FRemAcento"),U_FRemAcento(::RazaoSocial),FwNoAccent(::RazaoSocial)))
	Local cNReduz	:= Upper(IIf(FindFunction("U_FRemAcento"),U_FRemAcento(::NomeFantasia),FwNoAccent(::NomeFantasia)))
	Local cEstado	:= Upper(AllTrim(::Estado))
	Local cTipo		:= Upper(AllTrim(::Tipo))			//-> F=Cons.Final;L=Produtor Rural;R=Revendedor;S=Solidario;X=Exportacao
	Local cInsc		:= Upper(FVldIE(::InsEstadual))
	Local cInscM	:= Upper(FVldIE(::InsMunicipal))
	Local cInsRural	:= Upper(FVldIE(::InsRural))
	Local cSuframa	:= Upper(FVldIE(::Suframa))
	Local dDataNasc	:= ::DataNasc
	Local cHPage	:= Lower(IIf(FindFunction("U_FRemAcento"),U_FRemAcento(::HomePage),FwNoAccent(::HomePage)))
	Local cDDD		:= IIf(FindFunction("U_FRetDigit"),U_FRetDigit(::DDD),AllTrim(::DDD))
	Local cTel		:= IIf(FindFunction("U_FRetDigit"),U_FRetDigit(::Telefone),AllTrim(::Telefone))
	Local cCep		:= IIf(FindFunction("U_FRetDigit"),U_FRetDigit(::CEP),AllTrim(::CEP))
	Local cEmail	:= Lower(IIf(FindFunction("U_FRemAcento"),U_FRemAcento(::Email),FwNoAccent(::Email)))
	Local cEmailNFe	:= Lower(IIf(FindFunction("U_FRemAcento"),U_FRemAcento(::EmailNFe),FwNoAccent(::EmailNFe)))
	Local cContato	:= ""
	Local cEnd		:= Upper(IIf(FindFunction("U_FRemAcento"),U_FRemAcento(::Endereco),FwNoAccent(::Endereco)))
	Local cNrEnd	:= ::Numero
	Local cBairro	:= Upper(IIf(FindFunction("U_FRemAcento"),U_FRemAcento(::Bairro),FwNoAccent(::Bairro)))
	Local cCompl	:= Upper(IIf(FindFunction("U_FRemAcento"),U_FRemAcento(::Complemento),FwNoAccent(::Complemento)))
	Local cCodMun	:= Upper(AllTrim(::CodMunicipio))
	Local cObs		:= Upper(IIf(FindFunction("U_FRemAcento"),U_FRemAcento(::Observacao),FwNoAccent(::Observacao)))
	Local cVend		:= Upper(AllTrim(::Vendedor))
	Local dDtCadas	:= ::DataCadastro
	Local cNumDW	:= AllTrim(::NumeroDW)

	Local aVetor	:= {}
	Local cCodigo	:= ""
	Local cLoja		:= ""
	
	Local cPessoa	:= ""
	Local cRaizCNPJ	:= ""
	Local cEmpWel	:= ""
	Local cFilWel	:= ""
	Local cMunicip	:= ""
	Local cTpFrete	:= ""
	Local cPaisBacen:= ""
	Local cContrib	:= ""
	Local cOptSimpN	:= ""
	Local cGrpTrib	:= ""
	Local cCondPag	:= ""
	Local cRisco	:= ""
	Local dVencLC	:= ""
	Local cGrpVen	:= ""
	Local cNaturez	:= ""
	Local cCanal	:= ""
	Local cTpPessoa	:= ""
	Local cDDI		:= ""
	Local cPais		:= ""
	Local nTamCdCli	:= 0
	Local nTamLjCli	:= 0
	Local nOpc		:= 0
	Local aContatos	:= {}
	Local nItem		:= 0

	Local cMsgErro	:= ""
	Local cObsWS	:= ""
	Local lRet		:= .T.
	
	Private lMsErroAuto		:=	.F.	// Variavel que define que o help deve ser gravado no arquivo de log e que as informacoes estao vindo a partir da rotina automatica
	Private lMsHelpAuto		:=	.T.	// Forca a gravacao das informacoes de erro em array para manipulacao da gravacao ao inves de gravar direto no arquivo temporario
	Private lAutoErrNoFile	:=	.T.
	
	Private aAutoErro		:= {}
	Private lAuto			:= .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estabelece conexao com o Protheus ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cEmpWel := "01"		//-> Empresa
	cFilWel := "01"		//-> Filial
	RpcSetType(3) //-> Nao consome licenca de uso
	If !RpcSetEnv(cEmpWel,cFilWel,,,"FAT",,{"SA1"},.F.,.F.)
		cMsgErro 	:=	"[U_WSFDV001] Erro ao tentar estabelecer conexao com a unidade: "+cEmpWel+cFilWel
		cObsWS 		:=	U_xDatAt()+" [ERRO] "+CRLF
		cObsWS 		+=	cMsgErro
		SetSoapFault("Retorno",cObsWS)
		ConOut(cObsWS)
		
		::RETORNO := "Erro ao realizar a inclusao do cliente. " + cObsWS
		lRet := .F.
	
		DelClassIntf() //-> Exclui todas classes de interface da thread
		RpcClearEnv()
		RESET ENVIRONMENT
		Return(lRet)
	Else
		lAuto	:=	.T.
	EndIf

	ConOut(Repl("-",80))
	ConOut("[U_WSFDV001] WebService Cliente")
	ConOut("[U_WSFDV001] Inicio: "+Time()+" Data: "+DtoC(Date()))
	ConOut("[U_WSFDV001] Iniciando Metodo ( "+ProcName()+" )")
	ConOut("[U_WSFDV001] Numero DW: "+cNumDW)
	ConOut("[U_WSFDV001] CNPJ Cliente "+Transform(cCNPJ,IIf(Len(cCNPJ)<14,"@R 999.999.999-99","@R 99.999.999/9999-99")))
	ConOut("[U_WSFDV001] UF Cliente "+cEstado)
	ConOut("[U_WSFDV001] Empresa Trabalho "+cEmpAnt)
	ConOut("[U_WSFDV001] Filial Trabalho "+cFilAnt)
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida o Tipo do Cliente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(cTipo $ "FLRSX")
		cMsgErro 	:=	"[U_WSFDV001] Tipo do cliente nao esta dentro dos parametros esperados: F=Cons.Final;L=Produtor Rural;R=Revendedor;S=Solidario;X=Exportacao"
		cObsWS 		:=	U_xDatAt()+" [ERRO] "+CRLF
		cObsWS 		+=	cMsgErro
		SetSoapFault("Retorno",cObsWS)
		ConOut(cObsWS)
		
		::RETORNO := "Erro ao realizar a inclusao do cliente. " + cObsWS
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento de variaveis locais ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPessoa		:=	IIf(Len(cCNPJ) < 14,"F","J") //-> F=Pessoa Fisica;J=Pessoa Juridica
	cRaizCNPJ	:=	SubStr(cCNPJ,1,8)
	nTamCdCli	:=	TamSX3("A1_COD")[1]
	nTamLjCli	:=	TamSX3("A1_LOJA")[1]
	cMunicip	:=	Posicione("CC2",1,xFilial("CC2")+cEstado+cCodMun,"CC2_MUN")
	aContatos	:=	::ClienteContatos:Contatos
	cNReduz		:=	IIf(Empty(cNReduz),cRazao,cNReduz)

	If Len(aContatos) > 0
		For nItem := 1 To 1 //Len(aContatos)
			cContato	:=	Upper(::ClienteContatos:Contatos[nItem]:NOME)
			//cCargoCont:=	::ClienteContatos:Contatos[nItem]:CARGO
			//cMailCont	:=	Lower(AllTrim(::ClienteContatos:Contatos[nItem]:EMAIL))
			//cTelCont	:=	::ClienteContatos:Contatos[nItem]:TELEFONE
		Next nItem
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campos fixos utilizados pela rotina automatica ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDDI		:=	"55"								//-> 55=Brasil
	cPais		:=	"105" 								//-> 105=Brasil
	cTpPessoa	:=	IIf(Len(cCNPJ) < 14,"PF","CI")		//-> CI=Comercio/Industria; PF=Pessoa Fisica; OS=Prestacao Servicos; EP=Empresa Publica
	cTpFrete	:=	"F"									//-> F=FOB; C=CIF
	cPaisBacen	:=	IIf(cEstado <> "EX","01058","")		//-> 01058=Brasil
	cContrib	:=	"1"									//-> 1=Sim; 2=Nao
	cOptSimpN	:=	"2"									//-> 1=Sim; 2=Nao
	cGrpTrib	:=	"201"								//-> Grupo Tributario Cliente
	cCondPag	:=	"001"								//-> 001=A VISTA
	cRisco		:=	"E"									//-> E=Risco E sempre ira bloquear no credito
	dVencLC		:=	CtoD("31/12/2049")					//-> Data de vencimento do limite de credito
	cGrpVen		:=	"000056"							//-> A Segmentar
	cCanal		:=	"000023"							//-> A Segmentar
	cNaturez	:=	"10101"								//-> 10101=Produtos; 10201=Servicos

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa se o CNPJ ja existe na base ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA1")
	SA1->(dbSetOrder(RetOrder("SA1","A1_FILIAL+A1_CGC")))
	If SA1->(dbSeek(xFilial("SA1")+cCNPJ))
		cMsgErro 	:= "[U_WSFDV001] Cliente ja existe na base de dados do Protheus."+CRLF
		cMsgErro	+= "CNPJ: " + Transform(cCNPJ,IIf(Len(cCNPJ)<14,"@R 999.999.999-99","@R 99.999.999/9999-99"))
		cObsWS 		:= U_xDatAt()+" [ERRO] "+CRLF
		cObsWS 		+= cMsgErro
		SetSoapFault("Retorno",cObsWS)
		ConOut(cObsWS)

		::RETORNO := "Erro ao realizar a inclusao do cliente. " + cObsWS
		lRet := .F.
	Else
		nOpc := 3 //-> 3=Inclusao; 4=Alteracao; 5=Exclusao
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alimenta array utilizado na rotina automatica MATA030 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Formatacao de Codigo e Loja ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		//cCodigo :=	GetSXENum("SA1","A1_COD")
		cLoja	:=	"01"
		
		aAdd(aVetor,{"A1_FILIAL"	,xFilial("SA1")										,Nil})
		//aAdd(aVetor,{"A1_COD"		,cCodigo											,Nil})
		aAdd(aVetor,{"A1_LOJA"		,cLoja												,Nil})
		aAdd(aVetor,{"A1_NOME"		,cRazao												,Nil})
		aAdd(aVetor,{"A1_NREDUZ"	,cNReduz	  										,Nil})
		aAdd(aVetor,{"A1_MSBLQL"	,"1"		  										,Nil})

		aAdd(aVetor,{"A1_EST"		,cEstado  											,Nil})
		aAdd(aVetor,{"A1_CEP"		,cCep	 											,Nil})
		aAdd(aVetor,{"A1_END"		,cEnd  												,Nil})
		aAdd(aVetor,{"A1_NR_END"	,cNrEnd												,Nil})
		aAdd(aVetor,{"A1_COMPLEM"	,cCompl												,Nil})
		aAdd(aVetor,{"A1_BAIRRO"	,cBairro	 										,Nil})
		aAdd(aVetor,{"A1_COD_MUN"	,cCodMun   											,Nil})
		
		aAdd(aVetor,{"A1_PESSOA"	,cPessoa  											,Nil})
		aAdd(aVetor,{"A1_TIPO"		,cTipo	  											,Nil})
		aAdd(aVetor,{"A1_CGC"		,cCNPJ	 											,Nil})
		aAdd(aVetor,{"A1_INSCR"		,cInsc	 											,Nil})
		aAdd(aVetor,{"A1_INSCRM"	,cInscM	  											,Nil})
		aAdd(aVetor,{"A1_INSCRUR"	,cInsRural											,Nil})
		aAdd(aVetor,{"A1_SUFRAMA"	,cSuframa								  			,Nil})
		                                                                        	
		aAdd(aVetor,{"A1_DDD"		,cDDD												,Nil})
		aAdd(aVetor,{"A1_DDI"		,cDDI												,Nil})
		aAdd(aVetor,{"A1_PAIS"		,cPais												,Nil})
		aAdd(aVetor,{"A1_TEL"		,cTel												,Nil})
		aAdd(aVetor,{"A1_EMAIL"		,AllTrim(cEmail)+IIf(!Empty(cEmailNFe) .And. ;
			!(AllTrim(cEmailNFe) $ AllTrim(cEmail)),";"+AllTrim(cEmailNFe),"")			,Nil})
		aAdd(aVetor,{"A1_CONTATO"	,cContato											,Nil})
		aAdd(aVetor,{"A1_HPAGE"		,cHPage												,Nil})
		aAdd(aVetor,{"A1_DTNASC"	,dDataNasc											,Nil})
		aAdd(aVetor,{"A1_DTINIV"	,dDtCadas											,Nil})
						
		aAdd(aVetor,{"A1_ESTC"		,cEstado											,Nil})
		aAdd(aVetor,{"A1_CEPC"		,cCep												,Nil})
		aAdd(aVetor,{"A1_ENDCOB"	,cEnd												,Nil})
		aAdd(aVetor,{"A1_COMPLC"	,cCompl												,Nil})
		aAdd(aVetor,{"A1_BAIRROC"	,cBairro											,Nil})
		aAdd(aVetor,{"A1_MUNC"		,cMunicip											,Nil})
		
		aAdd(aVetor,{"A1_ESTE"		,cEstado											,Nil})
		aAdd(aVetor,{"A1_CEPE"		,cCep												,Nil})
		aAdd(aVetor,{"A1_ENDENT"	,cEnd												,Nil})
		aAdd(aVetor,{"A1_COMPLE"	,cCompl	  											,Nil})
		aAdd(aVetor,{"A1_BAIRROE"	,cBairro 											,Nil})
		aAdd(aVetor,{"A1_MUNE"		,cMunicip 											,Nil})
		
		aAdd(aVetor,{"A1_VEND"		,cVend	  											,Nil})
		aAdd(aVetor,{"A1_TPESSOA"	,cTpPessoa											,Nil})
		aAdd(aVetor,{"A1_CODPAIS"	,cPaisBacen	 										,Nil})
		aAdd(aVetor,{"A1_CONTRIB"	,cContrib	  										,Nil})
		aAdd(aVetor,{"A1_SIMPNAC"	,cOptSimpN											,Nil})
		aAdd(aVetor,{"A1_TPFRET"	,cTpFrete											,Nil})
		aAdd(aVetor,{"A1_GRPTRIB"	,cGrpTrib	 										,Nil})
		aAdd(aVetor,{"A1_COND"		,cCondPag	 										,Nil})
		aAdd(aVetor,{"A1_RISCO"		,cRisco		 										,Nil})
		aAdd(aVetor,{"A1_VENCLC"	,dVencLC	 										,Nil})
		aAdd(aVetor,{"A1_GRPVEN"	,cGrpVen	 										,Nil})
		aAdd(aVetor,{"A1_NATUREZ"	,cNaturez	 										,Nil})
		If SA1->(FieldPos("A1_K_CANAL")) > 0
			aAdd(aVetor,{"A1_K_CANAL"	,cCanal		 	   								,Nil}) //-> Obs. Comercial. Campo customizado
		EndIf
		If SA1->(FieldPos("A1_OBS1")) > 0
			aAdd(aVetor,{"A1_OBS1"		,cObs 	   										,Nil}) //-> Obs. Comercial. Campo customizado
		EndIf
		If SA1->(FieldPos("A1_IDDW")) > 0
			aAdd(aVetor,{"A1_IDDW"		,cNumDW											,Nil}) //-> Numero de identificacao DW FDW. Campo customizado
		EndIf
		
		aVetor := WsAutoOpc(@aVetor)
		
		lMsErroAuto := .F.
		MSExecAuto({|x,y| MATA030(x,y)},aVetor,nOpc) //-> nOpc = 3=inclusao; 4=Alteracao; 5=Exclusao
		
		If lMsErroAuto
			//RollbackSXE()
			
			aAutoErro 	:= GetAutoGRLog()
			cObsWS 		:= "[U_WSFDV001] "+U_xDatAt()+" [ERRO] "
			cObsWS 		+= U_xConverrLog(aAutoErro)
			SetSoapFault("Retorno",cObsWS)
			ConOut(cObsWS)

			::RETORNO := "Erro ao realizar a inclusao do cliente. " + cObsWS
			lRet := .F.
		Else
			//ConfirmSX8()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o registro foi realmente incluido ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SA1->(dbSetOrder(RetOrder("SA1","A1_FILIAL+A1_CGC")))
			If SA1->(dbSeek(xFilial("SA1")+cCNPJ))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Alimenta Retorno do WS com o Codigo e Loja do Cliente. ³
				//³ Indicando que a integracao foi realizada com sucesso!  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				::RETORNO := SA1->A1_COD+SA1->A1_LOJA

				ConOut("[U_WSFDV001] Cliente "+IIf(nOpc==4,"alterado","incluido")+" com sucesso!")
				ConOut("[U_WSFDV001] Codigo: "+SA1->A1_COD+" Loja: "+SA1->A1_LOJA)
		
			Else

				cMsgErro 	:= "[U_WSFDV001] CNPJ nao localizado apos inclusao do cliente"+CRLF
				cMsgErro	+= "CNPJ: " + Transform(cCNPJ,IIf(Len(cCNPJ)<14,"@R 999.999.999-99","@R 99.999.999/9999-99"))
				cObsWS 		:= U_xDatAt()+" [ERRO] "+CRLF
				cObsWS 		+= cMsgErro
				SetSoapFault(ProcName(),cObsWS)
				ConOut(cObsWS)
				
				::RETORNO := "Erro ao realizar a inclusao do cliente. " + cObsWS
				lRet := .F.

			EndIf
		EndIf
	EndIf

	ConOut("[U_WSFDV001] Fim: "+Time()+" Data: "+DtoC(Date()))
	ConOut(Repl("-",80))
	
	If lAuto
		DelClassIntf() //-> Exclui todas classes de interface da thread
		RpcClearEnv()
		RESET ENVIRONMENT
	EndIf
	
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FVldIE    ³ Autor ³ Welinton Martins   ³ Data ³ 20/12/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Remove pontos e outros caracteres da inscricao.            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FVldIE(cInsc,lContr)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cInsc  : Inscricao a ser avaliada                          ³±±
±±³          ³ lContr :                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ WebService Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FVldIE(cInsc,lContr)

Local cRet	:=	""
Local nI	:=	0

DEFAULT lContr	:=	.T.

If !Empty(cInsc)
	
	For nI := 1 To Len(cInsc)
		If Isdigit(Subs(cInsc,nI,1)) .Or. IsAlpha(Subs(cInsc,nI,1))
			cRet += Subs(cInsc,nI,1)
		EndIf
	Next nI
	
	cRet := AllTrim(cRet)
	
	If "ISEN" $ Upper(cRet)
		cRet := ""
	EndIf
	
	If lContr .And. Empty(cRet)
		cRet := "ISENTO"
	EndIf
	
	If !lContr
		cRet := ""
	EndIf
	
EndIf    

Return(cRet)