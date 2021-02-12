#Include "Totvs.ch"
#Include "ApWebSrv.ch"
#Include "TbiConn.ch"
#Include "TopConn.ch"

//���������������������������������Ŀ
//� Anexo 1 : Estrutura WS Cliente  �
//�---------------------------------�
//� Campo			Tamanho	Tipo    �
//�---------------------------------�
//� CNPJ			14		char    �
//� RAZAOSOCIAL		160		char    �
//� NOMEFANTASIA	80		char    �
//� ESTADO 					int     �
//� TIPO 			5		char    �
//� INSESTADUAL		35		char    �
//� INSMUNICIPAL	35		char    �
//� DATANASC				date    �
//� HOMEPAGE 		120		char    �
//� DDD  			35		char    �
//� TELEFONE  		35		char    �
//� CEP 			9		char    �
//� EMAIL  			120		char    �
//� EMAILNFE  		120		char    �
//� ENDERECO		90		char    �
//� NUMERO  		60		char    �
//� BAIRRO  		100		char    �
//� COMPLEMENTO 	80		char    �
//� CODMUNICIPIO	20		char    �
//� OBSERVACAO 				text    �
//� VENDEDOR  		60		char    �
//� DATACADASTRO			date    �
//� SUFRAMA			80		char    �
//� INSRURAL		35		char    �
//� NUMERODW		60		char    �
//�����������������������������������

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Contatos      �Autor  � Welinton Martins  � Data � 20/12/17���
�������������������������������������������������������������������������͹��
���Desc.     � Encapsula a estrutura array em uma estrutura simples       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Obs.      � Nao e permitido o uso da instru��o ARRAY OF quando         ���
���          � declaramos dados utilizados para entrada de dados dentro   ���
���          � da declara��o do servico. Para tal, precisamos criar uma   ���
���          � estrutura intermediaria para "encapsular" o array.         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � WebService Cliente                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
WSSTRUCT stWelContatos

	WSDATA Contatos	AS Array Of stContato	OPTIONAL
	
ENDWSSTRUCT

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � stContato     �Autor  � Welinton Martins  � Data � 20/12/17���
�������������������������������������������������������������������������͹��
���Desc.     � Estrutura dos Contatos do Cliente                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Obs.      �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � WebService Cliente                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
WSSTRUCT stContato

	WSDATA Nome			AS String
	WSDATA Telefone		AS String
	WSDATA Email		AS String
	WSDATA Cargo		AS String	OPTIONAL

ENDWSSTRUCT

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Empresa   � Welinton Martins (11) 99161-8225                           ���
�������������������������������������������������������������������������Ĵ��
���Funcao    � U_WSFDV001� Autor � Welinton Martins     � Data � 20/12/17 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Web Service Server, para integracao do sistema DW Forca de ���
���          � Vendas (Developweb X Protheus).                            ���
���          � Integracao Cliente.                                        ���
�������������������������������������������������������������������������Ĵ��
���Obs.      �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � oWs := WSU_WSFDV001():New()                                ���
���          � oWs:AddCliente()                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���             ATUALIZACOES SOFRIDAS DESDE CONSTRUCAO                    ���
�������������������������������������������������������������������������Ĵ��
���Data      � Programador      � Manutencao efetuada                     ���
�������������������������������������������������������������������������Ĵ��
���  /  /    �                  �                                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � WebService Cliente                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
WSSERVICE U_WSFDV001 DESCRIPTION "Integra��o Developweb X Protheus | Servi�o de inclus�o de Cliente" // NAMESPACE "http://"

	//����������������������������������������Ŀ
	//� Campos utilizados pela aplicacao DWFDV �
	//� GET                                    �
	//������������������������������������������

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
		
	//�����������������������Ŀ
	//� Retorno do WebService �
	//� RET                   �
	//�������������������������
	WSDATA RETORNO	   			AS String

	//�����������������������Ŀ
	//� Metodos do WebService �
	//�������������������������	
	WSMETHOD AddCliente		DESCRIPTION "M�todo de Inclus�o de Cliente - SA1"

ENDWSSERVICE

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Empresa   � Welinton Martins (11) 99161-8225                           ���
�������������������������������������������������������������������������Ĵ��
���Funcao    � AddCliente � Autor � Welinton Martins    � Data � 20/12/17 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Metodo para Inclusao do Cliente.                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Obs.      �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � oWS.AddCliente()                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Vide Anexo 1 : Estrutura WS Cliente.                       ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���             ATUALIZACOES SOFRIDAS DESDE CONSTRUCAO                    ���
�������������������������������������������������������������������������Ĵ��
���Data      � Programador      � Manutencao efetuada                     ���
�������������������������������������������������������������������������Ĵ��
���  /  /    �                  �                                         ���
���          �                  �                                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � WebService Cliente                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
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

	//�����������������������������������Ŀ
	//� Estabelece conexao com o Protheus �
	//�������������������������������������
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
		
	//��������������������������Ŀ
	//� Valida o Tipo do Cliente �
	//����������������������������
	If !(cTipo $ "FLRSX")
		cMsgErro 	:=	"[U_WSFDV001] Tipo do cliente nao esta dentro dos parametros esperados: F=Cons.Final;L=Produtor Rural;R=Revendedor;S=Solidario;X=Exportacao"
		cObsWS 		:=	U_xDatAt()+" [ERRO] "+CRLF
		cObsWS 		+=	cMsgErro
		SetSoapFault("Retorno",cObsWS)
		ConOut(cObsWS)
		
		::RETORNO := "Erro ao realizar a inclusao do cliente. " + cObsWS
		lRet := .F.
	EndIf

	//��������������������������������Ŀ
	//� Tratamento de variaveis locais �
	//����������������������������������
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
	
	//��������������������������������������������������
	//� Campos fixos utilizados pela rotina automatica �
	//��������������������������������������������������
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

	//��������������������������������������Ŀ
	//� Pesquisa se o CNPJ ja existe na base �
	//����������������������������������������
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

	//�������������������������������������������������������Ŀ
	//� Alimenta array utilizado na rotina automatica MATA030 �
	//���������������������������������������������������������
	If lRet
		//�������������������������������
		//� Formatacao de Codigo e Loja �
		//�������������������������������	
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
			
			//�����������������������������������������������Ŀ
			//� Verifica se o registro foi realmente incluido �
			//�������������������������������������������������
			SA1->(dbSetOrder(RetOrder("SA1","A1_FILIAL+A1_CGC")))
			If SA1->(dbSeek(xFilial("SA1")+cCNPJ))
				//��������������������������������������������������������Ŀ
				//� Alimenta Retorno do WS com o Codigo e Loja do Cliente. �
				//� Indicando que a integracao foi realizada com sucesso!  �
				//����������������������������������������������������������
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

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � FVldIE    � Autor � Welinton Martins   � Data � 20/12/2017 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Remove pontos e outros caracteres da inscricao.            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FVldIE(cInsc,lContr)                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cInsc  : Inscricao a ser avaliada                          ���
���          � lContr :                                                   ���
�������������������������������������������������������������������������Ĵ��
���Observacao�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � WebService Cliente                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
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