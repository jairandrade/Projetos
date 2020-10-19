#include "Protheus.ch"
#include "apwebsrv.ch"

/*/{Protheus.doc} TCPNFSERVICO
Web services para inclusão/Alteração/Exclusão de NF Serviço.
@author  Luiz Fernando
@since   12/04/2016
/*/
wsService TCPNFServico description "Webservice integracao de NF de Serviço."

	wsData Documento as TCPDocumentoIncluir
	wsData Exclui	 as TCPDocumentoExcluir
	wsData Retorno	 as TCPDocumentoRetorno

	//Metodos
	wsMethod Incluir  description "Realiza a inclusão de NF no protheus."
	wsMethod Excluir  description "Realiza a exclusão da NF no protheus."

endWsService

/*/{Protheus.doc} TCPDocumentoAtualizar
Estrtuura de dados para Inclusão(Inclusão) de Documento de Saída.
@author  Luiz
@since   12/04/2016
/*/
wsStruct TCPDocumentoIncluir

	wsData Filial			as String
	wsData Doc			    as String 
	wsData Serie			as String
	wsData Cliente		    as String //Cliente+Loja
	//wsData Produto		    as String
	wsData Mensagem		    as String //Mensagem enviada na NF de Serviço como descricao do produto.
	//wsData Quantidade		as Float
	//wsData Preco		    as Float
	wsData Numos  		    as String
	wsData Itens			as array of TCPDocumentoItem

endWsStruct

/*/{Protheus.doc} TCPClienteExcluir
Estrutura para Exclusão.

@author  Luiz
@since   12/04/2016
/*/
wsStruct TCPDocumentoExcluir

	wsData Filial         as String
	wsData Doc 	          as String 
	wsData Serie          as String 
	wsData Cliente        as String

endWsStruct

/*/{Protheus.doc} TCPClienteRetorno
Estrutura de retorno para webservices.

@author  Luiz
@since   12/04/2016
/*/
wsStruct TCPDocumentoRetorno

//	wsData Status  as Boolean
	wsData STATUSRET   	as String	//TRUE or FALSE	
	wsData Msg          as String
	
endWsStruct

/*/{Protheus.doc} TCPDocumentoItem
Estrutura de itens para NF.
@author  Luiz
@since   21/06/2016
/*/
wsStruct TCPDocumentoItem

	wsData PRODUTO			as String
	wsData QUANTIDADE 		as Float
	wsData VALOR			as Float
	
endWsStruct


/*/{Protheus.doc} Incluir
Método utilizado para Incluir NF de Serviço
Obs: O Execauto tem particularidades percebidas nos testes:
1- Nao grava campos do SF2 customizadas e na tentativa de gravar com RecLock o serviço do WS trava. 
   Transferido os campos OS e Msg para os itens.
2- Necessário na inclusão, liberar os Locks e forçar o cache dos dados pra o banco na confirmação do ExecAuto.
@author  Luiz 
@since   14/04/2016
/*/
wsMethod Incluir wsReceive Documento  wsSend Retorno wsService TCPNFServico

	Local aDadosSF2   := {}
	Local aDadosSD2    := {}
	Local aLog          := {}
	Local cLog          := ''
	Local lRet          := .T.
	Local nOpcao        := 3
	Local n1            := 0
	Local cProcess      := "TCPNFServico.Incluir"
	Local cTES          := ""
	Local cCodCli       := ""
	Local cLojaCli      := ""
	Local nTamCliente 	:= TamSX3("A1_COD")[1]
	Local nTamLoja	 	:= TamSX3("A1_LOJA")[1]
	Local nTamDoc 		:= TamSX3("F2_DOC")[1]
	Local nTamSerie	 	:= TamSX3("F2_SERIE")[1]		
	LOCAL nTamItem      := TamSX3("D2_ITEM")[1]
	Local cOperacao     := GetNewPar("TCP_OPERS","01")
	LOCAL cEspNFWs      := GetNewPar("TCP_ESPNFW","NF")
	LOCAL cTesExt       := GetNewPar("TCP_TESEXT","513")
	Local _cGrpExp 		:= SuperGetMV("TCP_GRPEXC",,'002')
	Local _lExcFisc       := .F.
	LOCAL nAliq         := 0
	LOCAL cCdISS        := ""
	LOCAL nFor
	LOCAL cMsg1         := ""
	LOCAL cMsg2         := ""
	LOCAL cMsg3         := ""
	LOCAL cMsg4         := ""
	
	Local nX			:= 0
	Local cLogPrd		:= ""
	Local cLogQTd		:= ""
	Local cLocVal		:= ""
	
	Local cMsgAux		:= ""
	
	Private cRetError      := ''
	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	
	
//	Self:Retorno:Status := .F.
    SM0->(dbSetOrder(1))
	if !SM0->(dbSeek(cEmpant+Self:Documento:Filial))
		cLog := '[TCPNFServico] - Inclusão - Filial incorreta: ' + cEmpant + "-" + Self:Documento:Filial
		U_WSGEN001(cProcess,cLog)
		Self:Retorno:STATUSRET := "FALSE"
		Self:Retorno:Msg       := cLog
		return .T.
	else

		cFilAnt := Self:Documento:Filial//Atribui a filial correta		
		
		//+----------------------------------------------------------------------------+
		//!Valida Cliente...                                                           !
		//+----------------------------------------------------------------------------+				
	    cCodCli  := Subs(PadR(Self:Documento:Cliente,(nTamCliente+nTamLoja)),1,nTamCliente)//Separa o código do cliente
	    cLojaCli := Subs(PadR(Self:Documento:Cliente,(nTamCliente+nTamLoja)),nTamCliente+1)//separa a loja do cliente
		DbSelectArea('SA1')
		DBSetOrder(01)
		If !SA1->(MSSeek(xFilial("SA1")+cCodCli+cLojaCli)).OR. Empty(cCodCli)
			cLog := '[TCPNFServico] - Inclusão - Código de cliente informado nao existe.' +cCodCli+cLojaCli
			U_WSGEN001(cProcess,cLog)
			Self:Retorno:STATUSRET := "FALSE"
			Self:Retorno:Msg       :=  cLog
			return .T.			             
		ElseIf SA1->A1_MSBLQL == '1'
				cLog := '[TCPNFServico] - Inclusão - Código de cliente bloqueado.' +cCodCli+cLojaCli
				U_WSGEN001(cProcess,cLog)			
				Self:Retorno:STATUSRET := "FALSE"
				Self:Retorno:Msg       := cLog
				return .T.	
		EndIf
		
		IF SA1->A1_GRPTRIB == _cGrpExp
			_lExcFisc     := .T.
		ENDIF
		
		If Empty(Self:Documento:DOC)
			cLog := "[TCPNFServico] - Inclusão - Numero do Documento Inválido" + Self:Documento:DOC
			Self:Retorno:STATUSRET := "FALSE"
			Self:Retorno:Msg       := cLog
			U_WSGEN001("WS_NFSERVICO.Incluir",cLog)
			return .T.				
		ElseIf Empty(Self:Documento:SERIE)
			cLog := "[TCPNFServico] - Inclusão - Série Inválida" + Self:Documento:SERIE
			Self:Retorno:STATUSRET := "FALSE"
			Self:Retorno:Msg       := cLog
			U_WSGEN001("WS_NFSERVICO.Incluir",cLog)
			return .T.	
		ElseIf Empty(Self:Documento:Numos)
			cLog := "[TCPNFServico] - Inclusão - Numos Inválido" + Self:Documento:Numos
			Self:Retorno:STATUSRET := "FALSE"
			Self:Retorno:Msg       := cLog
			U_WSGEN001("WS_NFSERVICO.Incluir",cLog)
			return .T.		
		EndIf
		
		//Valida Itens
		For nX := 1 to Len(Self:Documento:Itens)
			If Empty(Self:Documento:Itens[nX]:PRODUTO)
				If Empty(cLogPrd)
					cLogPrd := "[TCPNFServico] - Inclusão - Produto inválido. Item: "
				EndIf
				cLogPrd += StrZero(nX,2) + ", "
			EndIf
			
			If Self:Documento:Itens[nX]:QUANTIDADE <= 0
				If Empty(cLogQTd)
					cLogQTd := "[TCPNFServico] - Inclusão - Quantidade inválida. Item: "
				EndIf
				cLogQTd += StrZero(nX,2) + ", "
			EndIf	

			If Self:Documento:Itens[nX]:VALOR <= 0
				If Empty(cLocVal)
					cLocVal := "[TCPNFServico] - Inclusão - Valor inválido. Item: "
				EndIf
				cLocVal += StrZero(nX,2) + ", "
			EndIf
			
		Next nX
		
		cLog := cLogPrd + cLogQTd + cLocVal
		
		If !Empty(cLog)
			cLog := "[TCPNFServico] - Inclusão - " + SubStr(cLog,1,Len(cLog)-2)
			Self:Retorno:STATUSRET := "FALSE"
			Self:Retorno:Msg       := cLog
			U_WSGEN001("WS_NFSERVICO.Incluir",cLog)
			return .T.		
		EndIf

		//+----------------------------------------------------------------------------+
		//!Verifica se Documento ja cadastrado.                                       !
		//+----------------------------------------------------------------------------+		
		DBSelectArea("SF2")
	    DBSetOrder(02)//F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE
		If SF2->(MSSeek(xFilial("SF2")+SA1->(A1_COD+A1_LOJA)+PadR(Self:Documento:Doc,nTamDoc)+PadR(Self:Documento:Serie,nTamSerie)))
			cLog := '[TCPNFServico] - Inclusão - Nota já cadastrada anteriormente: ' + PadR(Self:Documento:Doc,nTamDoc)+PadR(Self:Documento:Serie,nTamSerie)
			U_WSGEN001(cProcess,cLog)	
			Self:Retorno:STATUSRET := "FALSE"		
			Self:Retorno:Msg := cLog
			return .T.			
		EndIf
		
		aDadosSF2:={;
						{"F2_DOC"		,Self:Documento:Doc		, Nil },;
						{"F2_SERIE   "	,Self:Documento:Serie	, Nil },;
						{"F2_CLIENTE "	,SA1->A1_COD			, Nil },;
						{"F2_LOJA    "	,SA1->A1_LOJA			, Nil },;
						{"F2_EMISSAO "	,Date()					, Nil },;
						{"F2_DTDIGIT"   ,Date()					, Nil },;
						{"F2_FRETE"	    ,0						, Nil },;
						{"F2_SEGURO"    ,0						, Nil },;
						{"F2_MOEDA"	    ,1						, Nil },;
						{"F2_TIPO"      ,"N"					, Nil },;
						{"F2_VALICM"	,0						, Nil },;
						{"F2_BASEICM"	,0						, Nil },;
						{"F2_DESCONT"   ,0						, Nil },;
						{"F2_DESPESA"   ,0						, Nil },;
						{"F2_VALIPI"	,0						, Nil },;
						{"F2_BASEIPI"	,0						, Nil },;			
						{"F2_ESPECIE"   ,cEspNFWs				, Nil },;
						{"F2_BASIMP5"	,0						, Nil },;
						{"F2_BASIMP6"	,0						, Nil },;
						{"F2_VALIMP5"	,0						, Nil },;
						{"F2_VALIMP6"	,0						, Nil },;
						{"F2_ICMSRET"	,0						, Nil },;
						{"F2_BRICMS"	,0						, Nil },;				
						{"F2_FORMUL"	,"S"					, Nil }}
//						{"F2_YNUMOS "	,Self:Documento:Numos	, Nil },; O Num os e a MSg foi levado para o item pois o Execauto trava ao incluir campo customizado.
//						{"F2_YMSGNF "	,Self:Documento:Mensagem	, Nil }}		

		//+----------------------------------------------------------------------------+
		//!Busca MSg para NF e inclui somente no primeiro item.                        !
		//+----------------------------------------------------------------------------+
		cMsg1:= AllTrim(NoAcento(Self:Documento:Mensagem))
		If Len(AllTrim(Self:Documento:Mensagem)) > 254
		  	cMsg1:= Substr(AllTrim(NoAcento(Self:Documento:Mensagem)),1,254)
		  	cMsg2:= Substr(AllTrim(NoAcento(Self:Documento:Mensagem)),255,254)
		  	If Len(AllTrim(Self:Documento:Mensagem)) > 508
				cMsg3:= Substr(AllTrim(NoAcento(Self:Documento:Mensagem)),509,254)
			  	If Len(AllTrim(Self:Documento:Mensagem)) > 762
					cMsg4:= Substr(AllTrim(NoAcento(Self:Documento:Mensagem)),763,254)
				EndIf
			EndIf
		EndIf 
		
		DbSelectArea("SB1")
		DBSetOrder(01)
		For nFor := 1 to Len(Self:Documento:Itens)

			//+----------------------------------------------------------------------------+
			//!Busca TES pela Operacao...                                                  !
			//+----------------------------------------------------------------------------+
			SB1->(DBGoTop())		
			If !SB1->(MSSeek(xFilial("SB1")+Self:Documento:Itens[nFor]:PRODUTO))
				cLog := '[TCPNFServico] - Inclusão - Produto não localizado: ' +Self:Documento:Itens[nFor]:PRODUTO
				cLog += " OS "+Self:Documento:Numos
				U_WSGEN001(cProcess,cLog)	
				Self:Retorno:STATUSRET := "FALSE"		
				Self:Retorno:Msg := cLog
				return .T.					  
			EndIf
			
			//Valida se algum item tem Aliquota ou Cod de ISS diferente na NFS
			If nFor == 1
				nAliq := SB1->B1_ALIQISS
				cCdISS:= SB1->B1_CODISS			
			EndIf
			If	nAliq <> SB1->B1_ALIQISS .Or. cCdISS <> SB1->B1_CODISS
				cLog := '[TCPNFServico] - Inclusão - Aliquota de ISS ou Codigo do ISS diferente entre os itens da NF: ' +Self:Documento:Doc
				cLog += " OS "+Self:Documento:Numos
				cLog += " Produto: "+Self:Documento:Itens[nFor]:PRODUTO
				cLog += " Verifique o cadastro dos produtos no protheus."
				U_WSGEN001(cProcess,cLog)		
				Self:Retorno:STATUSRET := "FALSE"	
				Self:Retorno:Msg := cLog
				return .T.		
			EndIf						
			nAliq := SB1->B1_ALIQISS
			cCdISS:= SB1->B1_CODISS				

			//Busca pela TES padrao, caso nao exista, busca pela TES inteligente.
			cTES:= SB1->B1_TS
//			If Empty(cTES)
//			cTES := MaTesInt(2,cOperacao,SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD)
//			EndIf

			if _lExcFisc
				cTES := cTesExt
			ENDIF

			AADD(aDadosSD2 	,{;
								{"D2_ITEM"		,StrZero(nFor,nTamItem), NIL},;
								{"D2_COD"   	, SB1->B1_COD, NIL},;
								{"D2_CLIENTE"	, SA1->A1_COD, NIL},;
								{"D2_LOJA"		, SA1->A1_LOJA, NIL},;
								{"D2_UM"     	, SB1->B1_UM, NIL},;
								{"D2_DOC"		, Self:Documento:Doc, NIL},;
								{"D2_SERIE"		, Self:Documento:Serie , NIL},;	
								{"D2_TIPO" 		, "N", NIL},;
								{"D2_TP" 		, SB1->B1_TIPO, NIL},;
								{"D2_EMISSAO"	, Date(), NIL},;
								{"D2_TES"   	, cTES, NIL},;
								{"D2_EST"  		, SA1->A1_EST, NIL},;
								{"D2_QUANT" 	, Self:Documento:Itens[nFor]:QUANTIDADE, NIL},;
								{"D2_PRCVEN"	, Self:Documento:Itens[nFor]:VALOR, NIL},;
								{"D2_TOTAL" 	, Self:Documento:Itens[nFor]:VALOR, NIL},;
								{"D2_YNUMOS "	, Self:Documento:Numos	, Nil },;
								{"D2_YMSGNF "	, cMsg1	, Nil },;
								{"D2_YMSGNF1"	, cMsg2	, Nil },;
								{"D2_YMSGNF2"	, cMsg3	, Nil },;
								{"D2_ORIGLAN"	, "LF"	, Nil },;
								{"D2_YMSGNF3"	, cMsg4	, Nil }})
								//D2_YMSGNF1
		
		  //Limpa variavel para enviar a msg da NF apenas no primeiro item. Pois, na rotina automaticao nao esta gravando
		  //campos customizados no cabeçalho.	
		  cMsg1:= ""
		  cMsg2:= ""
		  cMsg3:= ""
		  cMsg4:= ""			
		Next nFor

		If Len(aDadosSD2) <=0
		    cLog := "[TCPNFServico] - Inclusão - Não há itens para Inclusão de NF: "+Self:Documento:Doc+Self:Documento:Serie
			U_WSGEN001(cProcess,cLog)
			Self:Retorno:STATUSRET := "FALSE"				
			Self:Retorno:Msg := cLog
			return .T.	
		EndIf

		DBSelectArea("SF2")
		DBSelectArea("SD2")		
	    SF2->(DBSetOrder(01))
	    SD2->(DBSetOrder(01))		
		lMsHelpAuto := .T.
		lMsErroAuto := .F.
		MSExecAuto({|x,y,z|Mata920(x,y,z)},aDadosSF2,aDadosSD2,3 ) //3-Inclusão; 5-Exclusão

		IF lMsErroAuto
			cLog := "[TCPNFServico] - Inclusão - Erro ExecAuto: "
			aLog := GetAutoGRLog()
			For n1 := 1 to len(aLog)
				cLog += aLog[n1] +  CRLF
			Next n1
			U_WSGEN001(cProcess,cLog)				
//			DisarmTransaction()
			Self:Retorno:STATUSRET := "FALSE"
			Self:Retorno:Msg := cLog
		Else
		 // nRecF2:= SF2->(RECNO())
		//DBCOMMITALL()
			//+----------------------------------------------------------------------------+
			//!Este execauto trava o WS foi necessario forcar o fim da transacao e liberar !
			//!os Locks e registros para o TOP.                                            !			
			//+----------------------------------------------------------------------------+	
            MsUnlockAll()
            DBCOMMITALL()

		
	    	cLog:= "[TCPNFServico] - Inclusão com Sucesso - Nf: " + Self:Documento:Doc + Self:Documento:Serie
			Self:Retorno:STATUSRET := "TRUE"
			Self:Retorno:Msg := cLog
			U_WSGEN001(cProcess,cLog)			
		EndIf
		
		//MsUnlockAll()
	EndIf

Return lRet

/*/{Protheus.doc} Excluir 
Exclusão de clientes
@author  Luiz 
@since   12/04/2016
@param Exclusão, Objeto, XML com documento para excluir estrurura.
@return  Retorno, Objeto, Retorna se conseguiu excluir a estrurura e o erro, caso ocorra.
/*/


wsMethod Excluir wsReceive Exclui wsSend Retorno wsService TCPNFServico

	Local aDadosSF2     := {}
	Local aDadosSD2     := {}
	Local aLog          := {}
	Local cLog          := ''
	Local lRet          := .T.
	Local n1            := 0
	Local nTamCliente 	:= TamSX3("A1_COD")[1]
	Local nTamLoja	 	:= TamSX3("A1_LOJA")[1]
	Local nTamDoc 		:= TamSX3("F2_DOC")[1]
	Local nTamSerie	 	:= TamSX3("F2_SERIE")[1]	
	Local cCodCli  		:= ""
	Local cLojaCli 		:= ""
	Local cProcess      := "TCPNFServico.Excluir"
	
	Private cRetError      := ''
	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.


	if !SM0->(dbSeek(cEmpant+Exclui:Filial))
		cLog:= '[TCPNFServico] - Exclusão - Filial incorreta!'+Exclui:Filial
	    U_WSGEN001("TCPCliente.Excluir",cLog)
		Self:Retorno:STATUSRET := "FALSE"
		Self:Retorno:Msg := cLog
		return .T.	
	EndIf
		cFilAnt := Exclui:Filial

		//+----------------------------------------------------------------------------+
		//!Valida Cliente...                                                           !
		//+----------------------------------------------------------------------------+		
	    cCodCli  := Subs(PadR(Self:Exclui:Cliente,(nTamCliente+nTamLoja)),1,nTamCliente)//Separa o código do cliente
	    cLojaCli := Subs(PadR(Self:Exclui:Cliente,(nTamCliente+nTamLoja)),nTamCliente+1)//separa a loja do cliente
		DbSelectArea('SA1')
		DBSetOrder(01)
		If !SA1->(MSSeek(xFilial("SA1")+cCodCli+cLojaCli)).And. Empty(cCodCli)
			cLog := '[TCPNFServico] - Exclusão - Código de cliente informado nao existe.' +cCodCli+cLojaCli
			U_WSGEN001(cProcess,cLog)
			Self:Retorno:STATUSRET := "FALSE"			
			Self:Retorno:Msg := cLog
			return .T.			
		EndIf

		//+----------------------------------------------------------------------------+
		//!Localiza documento original...                                             !
		//+----------------------------------------------------------------------------+		
		DBSelectArea("SF2")
	    DBSetOrder(02)//F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE
		If !SF2->(MSSeek(xFilial("SF2")+SA1->(A1_COD+A1_LOJA)+PadR(Self:Exclui:Doc,nTamDoc)+PadR(Self:Exclui:Serie,nTamSerie) ))
			cLog := '[TCPNFServico] - Exclusão - Nota Não localizada.' +PadR(Self:Exclui:Doc,nTamDoc)+PadR(Self:Exclui:Serie,nTamSerie)
			U_WSGEN001(cProcess,cLog)	
			Self:Retorno:STATUSRET := "FALSE"		
			Self:Retorno:Msg := cLog
			return .T.				
		EndIf

		aDadosSF2:={	{"F2_DOC"		,SF2->F2_DOC		, Nil },;
						{"F2_SERIE   "	,SF2->F2_SERIE		, Nil },;
						{"F2_CLIENTE "	,SF2->F2_CLIENTE	, Nil },;
						{"F2_LOJA    "	,SF2->F2_LOJA		, Nil },;
						{"F2_TIPO"      ,SF2->F2_TIPO		, Nil },;
						{"F2_ESPECIE"   ,SF2->F2_ESPECIE	, Nil }}
		
		DBSelectArea("SD2")
		SD2->(DBSetOrder(03))//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		If SD2->(MSSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
			Do While !SD2->(Eof()) .And. SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) ==;
										 SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)  
				AADD(aDadosSD2 	,{	{"D2_ITEM"		, SD2->D2_ITEM		, NIL},;
									{"D2_COD"   	, SD2->D2_COD		, NIL},;
									{"D2_CLIENTE"	, SD2->D2_CLIENTE	, NIL},;
									{"D2_LOJA"		, SD2->D2_LOJA		, NIL},;
									{"D2_UM"     	, SD2->D2_UM		, NIL},;
									{"D2_DOC"		, SD2->D2_DOC		, NIL},;
									{"D2_SERIE"		, SD2->D2_SERIE		, NIL}})
				
				SD2->(DBSkip())
			EndDo
		EndIf
		
		lMsHelpAuto := .T.
		lMsErroAuto := .F.
		
		MSExecAuto({|x,y,z|Mata920(x,y,z)},aDadosSF2,aDadosSD2,5 ) //3-Inclusão; 5-Exclusão			
		
		If lMsErroAuto
			cLog := " [TCPNFServico] - Exclusão - Erro ExecAuto: "
			aLog := GetAutoGRLog()
			For n1 := 1 to len(aLog)
				cLog += aLog[n1] +  CRLF
			Next n1
		
			U_WSGEN001(cProcess,cLog)			
			Self:Retorno:STATUSRET := "FALSE"		
			Self:Retorno:Msg := cLog
		Else	
			cLog:= "[TCPNFServico] - Exclusão: "+ SA1->(A1_COD+A1_LOJA)+"-"+PadR(Self:Exclui:Doc,nTamDoc)+PadR(Self:Exclui:Serie,nTamSerie)
			U_WSGEN001(cProcess,cCodCli+cLojaCli)
			Self:Retorno:STATUSRET := "TRUE"		
			Self:Retorno:Msg := cLog
		EndIf				
		//MsUnlockAll()

Return lRet


