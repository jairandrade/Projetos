/*
+----------------------------------------------------------------------------+
!                          FICHA TECNICA DO PROGRAMA                         !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! WebService                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Financiero                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! WebService para enviar dados dos títulos a pagar!
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo G. Vieira                                          !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 17/07/2018                                              !
+------------------+---------------------------------------------------------+
!                               ATUALIZACOES                                 !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !  Nome do  ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

#include "PROTHEUS.CH"
#include "APWEBSRV.CH"
#include "APWEBEX.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

wsStruct StTitulos

	wsdata EMPRESA 	   as string 
	wsdata NOMEEMPRESA as string 
	wsdata FILIAL 	   as string 
	wsdata PREFIXO     as string 
	wsdata NUMERO      as string 
	wsdata PARCELA     as string 
	wsdata TIPO  	   as string 
	wsdata FORNECEDOR  as string 
	wsdata NOME  	   as string 
	wsdata RAZAO  	   as string 
	wsdata EMISSAO     as date 
	wsdata VENCIMENTO  as date 
	wsdata BANCO  	   as string 
	wsdata AGENCIA     as string 
	wsdata CONTA  	   as string 
	wsdata BORDERO     as string 
	wsdata CHEQUE  	   as string 
	wsdata ORIGEM  	   as string 
	wsdata NATUREZA    as string 
	wsdata NATUREZAING as string 
	wsdata RECORRENTE  as boolean Optional
	wsdata VALOR  	   as float 
	wsdata ACRESCIMO   as float 
	wsdata DECRESCIMO  as float 
	wsdata SALDO  	   as float 
	wsdata OBSERVACAO  as string 
	wsdata CHAVE  	   as string
	wsdata ULTIMO	   as boolean  


endWsStruct


wsStruct StTracker

	wsdata EMPRESA 	    as string 
	wsdata NOMEEMPRESA  as string 
	wsdata FILIAL 	    as string Optional 
	wsdata NOTAS	    as Array of StNota       Optional
	wsdata PEDIDOS	    as Array of StPedido     Optional
	wsdata COTACOES	    as Array of StCotacao    Optional
	wsdata SOLICITACOES as Array of StSolCompras Optional
	wsdata CONTRATOS    as Array of StContrato   Optional
	wsdata ANEXOS       as Array of StAnexo      Optional

endWsStruct


wsStruct StNota
	wsdata DOCUMENTO   as string 
	wsdata SERIE	   as string 
	wsdata FORNECEDOR  as string 
	wsdata NOME  	   as string 
	wsdata RAZAO  	   as string 
	wsdata EMISSAO	   as date 
	wsdata DIGITACAO   as date
	wsdata TIPO		   as string 
	wsdata ESPECIE	   as string 
	wsdata CONDPG      as string 
	wsdata ICMS        as float 
	wsdata IPI         as float 
	wsdata PIS         as float 
	wsdata COFINS      as float 
	wsdata ITENS       as Array of StItemNota 
endWsStruct

wsStruct StItemNota
	wsdata ITEM 	   as string 
	wsdata PRODUTO 	   as string 
	wsdata DESCRICAO   as string 
	wsdata QUANTIDADE  as float
	wsdata VALORUNIT   as float 
	wsdata VALORTOTAL  as float 
	wsdata CENTROCUSTO as string 
	wsdata CONTA       as string 
	wsdata PEDIDO      as string 
	wsdata ITEMPEDIDO  as string 
endWsStruct

wsStruct StPedido
	wsdata NUMERO      as string 
	wsdata EMISSAO	   as date 
	wsdata ITENS       as Array of StItemPedido 
	wsdata APROVADORES as Array of StAprovador Optional 
endWsStruct

wsStruct StItemPedido
	wsdata ITEM 	   as string 
	wsdata PRODUTO 	   as string 
	wsdata DESCRICAO   as string 
	wsdata QUANTIDADE  as float
	wsdata VALORUNIT   as float 
	wsdata VALORTOTAL  as float 
	wsdata CENTROCUSTO as string 
	wsdata CONTA       as string 
	wsdata ENTREGA     as date 
	wsdata SOLICITACAO as string 
	wsdata ITEMSOLIC   as string 

endWsStruct

wsStruct StAprovador
	wsdata DTAPROV     as date 
	wsdata NOME 	   as string 
	wsdata STATUS 	   as string 
	wsdata NIVEL 	   as integer  
endWsStruct


wsStruct StCotacao
	wsdata NUMERO      as string 
	wsdata FORNECEDOR  as string 
	wsdata NOME        as string
	wsdata RAZAO       as string
	wsdata EMISSAO     as DATE
	wsdata CONDPG      as string 
	wsdata ITENS       as Array of StItemCotacao
endWsStruct

wsStruct StItemCotacao
	wsdata ITEM 	   as string 
	wsdata PRODUTO 	   as string 
	wsdata SOLICITACAO as string 
	wsdata ITEMSOLIC   as string 
	wsdata DESCRICAO   as string 
	wsdata QUANTIDADE  as float
	wsdata VALORUNIT   as float 
	wsdata VALORTOTAL  as float  
	wsdata ENTREGA     as date 
	wsdata VENCEDORA   as boolean

endWsStruct


wsStruct StSolCompras
	wsdata NUMERO      as string 
	wsdata EMISSAO	   as date 
	wsdata ITENS       as Array of StItemSolicitacao
endWsStruct

wsStruct StItemSolicitacao
	wsdata ITEM 	   as string 
	wsdata PRODUTO 	   as string 
	wsdata DESCRICAO   as string 
	wsdata QUANTIDADE  as float
	wsdata ENTREGA     as date 
endWsStruct

wsStruct StContrato
	wsdata NUMERO      as string 
	wsdata DESCRICAO   as string 
	wsdata REVISAO     as string 
	wsdata VIGENCIA	   as INTEGER
	wsdata UNIDADEVIG  as string 
	wsdata VALORINI	   as float 
	wsdata VALORIATU   as float 
	wsdata SALDO	   as float
	wsdata ENTREGA	   as date
	wsdata TotalPagto  as float 
	wsdata PAGAMENTOS  as Array of StPgtoContrato Optional
endWsStruct

wsStruct StPgtoContrato
	wsdata DTPAGAMENTO as date 
	wsdata VALOR       as float 
endWsStruct

wsStruct StAnexo
	wsdata NOME    	   as string 
	wsdata CODIGO      as string 
	wsdata TIPO        as string 
endWsStruct

wsStruct StArquivo
	wsdata ARQUIVO   as string  
	wsdata PARTE     as INTEGER  
	wsdata QTDPARTES as INTEGER  
endWsStruct

WSSERVICE WsPagamentos  description "WebService para enviar dados dos títulos a pagar."

	// DECLARACAO DAS VARIVEIS GERAIS	
	wsdata Usuario 		 as string 	
	wsdata Senha 		 as string 	
	wsdata codEmpresa 	 as string 
	wsdata ApenasAbertos as boolean 
	wsdata Todos		 as boolean 

	wsdata codObjeto 	 as string
	wsdata nParte        as integer

	wsdata codFilial 	 as string  Optional
	wsdata Chave 		 as string  Optional
	wsdata VencimentoIni as date 	Optional
	wsdata VencimentoFim as date 	Optional

	// DECLARACAO DAS ESTRUTURAS DE RETORNO
	wsdata oStAnexos   as Array of StArquivo
	wsdata oStTitulos  as Array of StTitulos
	wsdata oStTracker  as Array of StTracker

	// DELCARACAO DO METODOS
	WSMETHOD TITULOS      description "Os títulos em aberto de um determinado período."
	WSMETHOD TRACKER      description "Retorna toda a estrutura que gerou o título, desde o contrato."
	WSMETHOD ANEXOS       description "Retorna o anexo solicitado."

endWSSERVICE

/*
+------------+---------------------------------------------------------------+
! Funcao     ! Metodo WS                                                     !
+------------+---------------------------------------------------------------+
! Autor      ! Eduardo G. Vieira                                              !
+------------+---------------------------------------------------------------+
! Descricao  ! Retorna os títulos em aberto!
+------------+---------------------------------------------------------------+
! Parametros !                                                               !
+------------+---------------------------------------------------------------+
*/
WSMETHOD TITULOS WSRECEIVE Usuario,Senha,codEmpresa ,Todos,ApenasAbertos,codFilial,Chave,VencimentoIni,VencimentoFim WSSEND oStTitulos WSSERVICE WsPagamentos

	Local cWhere 	:= '%'
	Local _cFil  	:= '01'
	Local lTodos    := ::Todos
	Local cCodEmp   := ::codEmpresa
	Local lAbertos  := ::ApenasAbertos
	Local cCodFil   := ::codFilial
	Local cChave    := ::Chave
	Local dVencIni  := ::VencimentoIni
	Local dVencFim  := ::VencimentoFim
	Local cTabela   := codEmpresa+'0'
	Local cTabE2    := '' 
	Local cTabED    := '' 
	//Fornecedores é utilizada a mesma tabela para todos
	Local cTabA2    := ''
	Local cTabEA    := ''
	Local cTabD1    := ''
	Local cTabC7    := ''
	Local nMeses    := 0 
	Local nNumNotas := 0 
	Local nLimTits  := 0 
	//Tipo ignorados
	Local cTpIgnor  := 0 
	//Sempre consulto 1 a mais, pois preciso saber se este é o último título da consulta ou não.
	Local cLimis    := ''
	Local nMesIni   := 0 
	Local nAnoIni   := 0 
	Local dDtIniF   := CTOD('//')
	Local aArrFor   := {}
	Local aArrRec   := {}
	Local nPosFor   := 0
	Local nCntRegs  := 0
	Local nNumRegs  := 0
	Local cOrigTit  := ''
	
	RpcClearEnv()
	RPCSetType(3)
	RpcSetEnv(cCodEmp,"01",,,"CFG")
	
	cTabE2    := '%' + FWSX2Util():GetFile( "SE2" ) + '%'
	cTabED    := '%' + FWSX2Util():GetFile( "SED" ) + '%'
	cTabA2    := '%' + FWSX2Util():GetFile( "SA2" ) + '%'
	cTabEA    := '%' + FWSX2Util():GetFile( "SEA" ) + '%'
	cTabD1    := '%' + FWSX2Util():GetFile( "SD1" ) + '%'
	cTabC7    := '%' + FWSX2Util():GetFile( "SC7" )+ '%'
	nMeses    := GetNewPar("TCP_FORMES",3)
	nNumNotas := GetNewPar("TCP_FORNOT",3)
	nLimTits  := GetNewPar("TCP_LIMTIT",500) 
	cTpIgnor  := GetNewPar("TCP_TPIGNO",'') 
	cLimis    := '%'+ALLTRIM(STR(nLimTits+ 1))+'%' 
	nMesIni   := IF(Month(dDatabase)-nMeses < 1 ,Month(dDatabase)-nMeses + 12,Month(dDatabase)-nMeses)
	nAnoIni   := IF(Month(dDatabase)-nMeses < 1 ,YEAR(dDatabase) - 1,YEAR(dDatabase))
	dDtIniF   := StrZero(nAnoIni,4)+StrZero(nMesIni,2)+'01'
	
	cErro := validaPar(::Usuario,::Senha,cCodEmp)

	if !empty(cErro)
		SetSoapFault("Consulta TITULOS",cErro)		 			
		Return .F.
	EndIf
	//oStTitulos := STARTJOB("U_WSTITULO()", GetEnvServer(), .T., ::codEmpresa,::ApenasAbertos,::codFilial,::Chave,::VencimentoIni,::VencimentoFim)


	IF(!EMPTY(cChave)) .AND. !lTodos
		cWhere += " AND E2_FILIAL||E2_PREFIXO||E2_NUM||E2_PARCELA||E2_TIPO||E2_FORNECE||E2_LOJA  = '"+ cChave +"'" 
	ELSE
		IF(!EMPTY(cCodFil))
			cWhere += " AND E2_FILIAL = '"+ cCodFil +"'" 
		ENDIF

		IF(!EMPTY(dVencIni))
			cWhere += " AND E2_VENCREA  >= '"+ DTOS(dVencIni) +"'" 
		ENDIF

		IF(!EMPTY(dVencFim))
			cWhere += " AND E2_VENCREA  <= '"+ DTOS(dVencFim) +"'" 
		ENDIF

		if(lTodos .AND. !EMPTY(cChave))
			cWhere += " AND E2_FILIAL||E2_PREFIXO||E2_NUM||E2_PARCELA||E2_TIPO||E2_FORNECE||E2_LOJA  > '"+ cChave +"'" 
		ENDIF

	ENDIF

	if lAbertos
		cWhere += " AND (E2_SALDO  > 0 OR E2_NUMBCO != ' ' )" 
	endif

	IF !EMPTY(cTpIgnor)	
		cWhere += " AND E2_PREFIXO NOT IN "+FormatIn(cTpIgnor,";") + " AND E2_TIPO NOT IN "+FormatIn(cTpIgnor,";")
	ENDIF

	cWhere += " AND ( ( E2_STATLIB = '03' AND E2_XCODPGM <> ' ' AND E2_ORIGEM IN ('FINA376','FINA378','FINA290','FINA870') ) OR ( ( E2_STATLIB IN ( '','01' ) AND E2_XCODPGM = ' ' ) ) OR ( ( E2_STATLIB IN ( '','01' ) AND E2_ORIGEM NOT IN ( 'FINA376','FINA378','FINA870' ) ) ) )"

	cWhere += '%'

	cAlias := getNextAlias()

	BeginSQL Alias cAlias

		SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,E2_EMISSAO,E2_VENCREA,E2_NUMBCO,
		ED_DESCRIC,ED_XDESCEN,E2_VALOR,E2_ACRESC,E2_DECRESC,E2_SALDO,E2_SDACRES,E2_SDDECRE,E2_HIST,A2_NOME,A2_NREDUZ,E2_ORIGEM,E2_NUMBOR,E2_BCOPAG, 
		E2_PORTADO,EA_AGEDEP,EA_NUMCON,C7_CONTRA,E2_TITPAI,E2_XORIGEM
		FROM %EXP:cTabE2% SE2
		INNER JOIN %EXP:cTabED% SED ON ED_CODIGO = E2_NATUREZ AND SED.%NotDel%
		INNER JOIN %EXP:cTabA2% SA2 ON E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA AND SA2.%NotDel%
		LEFT JOIN %EXP:cTabD1% SD1 ON D1_FILIAL = E2_FILIAL AND E2_NUM = D1_DOC AND E2_PREFIXO = D1_SERIE AND E2_FORNECE = D1_FORNECE AND E2_LOJA = D1_LOJA AND SD1.%NotDel%
		LEFT JOIN %EXP:cTabC7% SC7 ON C7_FILIAL = D1_FILIAL AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC AND SC7.%NotDel%
		LEFT JOIN %EXP:cTabEA% SEA ON EA_FILIAL = E2_FILIAL AND E2_NUMBOR = EA_NUMBOR AND EA_CART = 'P' AND E2_NUM = EA_NUM AND E2_PREFIXO = EA_PREFIXO AND E2_TIPO = EA_TIPO  AND E2_PARCELA = EA_PARCELA AND E2_FORNECE = EA_FORNECE AND E2_LOJA = EA_LOJA AND SEA.%NotDel%
		WHERE SE2.%NotDel%  %EXP:cWhere% 
		GROUP BY E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,E2_EMISSAO,E2_VENCREA,E2_NUMBCO,
		ED_DESCRIC,ED_XDESCEN,E2_VALOR,E2_ACRESC,E2_DECRESC,E2_SALDO,E2_SDACRES,E2_SDDECRE,E2_HIST,A2_NOME,A2_NREDUZ,E2_ORIGEM,E2_NUMBOR, E2_BCOPAG,
		E2_PORTADO,EA_AGEDEP,EA_NUMCON,C7_CONTRA,E2_TITPAI,E2_XORIGEM
		ORDER BY E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA
		OFFSET 0 ROWS FETCH NEXT %EXP:cLimis% ROWS ONLY  
	EndSQL
	//SEMPRE QUE USAR O COUNT, COLOCAR DBTOP DEPOIS	
	Count To nNumRegs
	(cAlias)->(DBGOTOP())

	while !(cAlias)->(Eof()) .AND. nLimTits > nCntRegs 

		nCntRegs++
		//Quando o título for do tipo taxa, 
		IF !(cAlias)->(Eof()) .AND. !EMPTY(ALLTRIM((cAlias)->E2_TITPAI))
			cAliasAx := getNextAlias()

			BeginSQL Alias cAliasAx

				SELECT E2_FILIAL,E2_NUM,E2_TIPO,E2_PREFIXO,E2_PARCELA, E2_FORNECE,E2_LOJA, C7_CONTRA,E2_ORIGEM,E2_XORIGEM
				FROM %EXP:cTabE2% SE2
				LEFT JOIN %EXP:cTabD1% SD1 ON D1_FILIAL = E2_FILIAL AND E2_NUM = D1_DOC AND E2_PREFIXO = D1_SERIE AND E2_FORNECE = D1_FORNECE AND E2_LOJA = D1_LOJA AND SD1.%NotDel%
				LEFT JOIN %EXP:cTabC7% SC7 ON C7_FILIAL = D1_FILIAL AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC AND SC7.%NotDel%
				WHERE SE2.%NotDel%  AND E2_FILIAL = %EXP:(cAlias)->E2_FILIAL% AND 
				E2_PREFIXO||E2_NUM||E2_PARCELA||E2_TIPO||E2_FORNECE||E2_LOJA = %EXP:(cAlias)->E2_TITPAI%

			EndSQL

			IF !(cAliasAx)->(Eof())
				cOrigTit := IF(!EMPTY(ALLTRIM((cAliasAx)->C7_CONTRA)),'Contract',GetSX3cBox("E2_XORIGEM",(cAliasAx)->E2_XORIGEM,"3")/*(IF(ALLTRIM((cAliasAx)->E2_ORIGEM) == 'MATA100','Pedido de Compra','Manual'))*/)
			ENDIF

			(cAliasAx)->(dbclosearea())
		ELSE
			cOrigTit := IF(!EMPTY(ALLTRIM((cAlias)->C7_CONTRA)),'Contract', GetSX3cBox("E2_XORIGEM",(cAlias)->E2_XORIGEM,"3")/*(IF(ALLTRIM((cAlias)->E2_ORIGEM) == 'MATA100','Pedido de Compra','Manual'))*/)
		endif

		/*Naão será mais enviado o campo recorrencia

		nPosFor := AScanX( aArrFor, (cAlias)->E2_FORNECE+(cAlias)->E2_LOJA)
		IF nPosFor <= 0
		cAliasFor := getNextAlias()

		BeginSQL Alias cAliasFor

		SELECT COUNT(*) AS NUMTIT
		FROM %EXP:cTabE2% SE2
		WHERE SE2.%NotDel%  AND E2_EMISSAO >= %EXP:dDtIniF% AND E2_FORNECE = %EXP:(cAlias)->E2_FORNECE% AND E2_LOJA = %EXP:(cAlias)->E2_LOJA%

		EndSQL

		IF !(cAlias)->(Eof())
		AADD(aArrFor,(cAlias)->E2_FORNECE+(cAlias)->E2_LOJA)
		AADD(aArrRec,IF((cAliasFor)->NUMTIT >= nNumNotas,.T.,.F.))
		nPosFor := LEN(aArrRec)
		ELSE
		AADD(aArrFor,(cAlias)->E2_FORNECE+(cAlias)->E2_LOJA)
		AADD(aArrRec,.F.)
		nPosFor := LEN(aArrRec)
		endif

		ENDIF
		*/
		AAdd(oStTitulos, WsClassNew("StTitulos"))
		oStTitulos[len(oStTitulos)]:EMPRESA    := cCodEmp
		oStTitulos[len(oStTitulos)]:NOMEEMPRESA:= Posicione("SM0",1,cCodEmp,"M0_NOMECOM")
		oStTitulos[len(oStTitulos)]:FILIAL     := (cAlias)->E2_FILIAL
		oStTitulos[len(oStTitulos)]:PREFIXO    := (cAlias)->E2_PREFIXO
		oStTitulos[len(oStTitulos)]:NUMERO     := (cAlias)->E2_NUM
		oStTitulos[len(oStTitulos)]:PARCELA    := (cAlias)->E2_PARCELA
		oStTitulos[len(oStTitulos)]:TIPO       := (cAlias)->E2_TIPO
		oStTitulos[len(oStTitulos)]:FORNECEDOR := (cAlias)->E2_FORNECE+(cAlias)->E2_LOJA
		oStTitulos[len(oStTitulos)]:NOME       := (cAlias)->A2_NREDUZ
		oStTitulos[len(oStTitulos)]:RAZAO      := (cAlias)->A2_NOME
		oStTitulos[len(oStTitulos)]:EMISSAO    := STOD((cAlias)->E2_EMISSAO)
		oStTitulos[len(oStTitulos)]:VENCIMENTO := STOD((cAlias)->E2_VENCREA) 
		oStTitulos[len(oStTitulos)]:BANCO      := (cAlias)->E2_PORTADO
		oStTitulos[len(oStTitulos)]:AGENCIA    := (cAlias)->EA_AGEDEP
		oStTitulos[len(oStTitulos)]:CONTA      := (cAlias)->EA_NUMCON
		oStTitulos[len(oStTitulos)]:BORDERO    := (cAlias)->E2_NUMBOR
		oStTitulos[len(oStTitulos)]:CHEQUE     := (cAlias)->E2_NUMBCO
		oStTitulos[len(oStTitulos)]:ORIGEM     := cOrigTit
		oStTitulos[len(oStTitulos)]:NATUREZA   := (cAlias)->ED_DESCRIC
		oStTitulos[len(oStTitulos)]:NATUREZAING:= (cAlias)->ED_XDESCEN
		//oStTitulos[len(oStTitulos)]:RECORRENTE := aArrRec[nPosFor]
		oStTitulos[len(oStTitulos)]:VALOR      := (cAlias)->E2_VALOR
		oStTitulos[len(oStTitulos)]:ACRESCIMO  := (cAlias)->E2_ACRESC
		oStTitulos[len(oStTitulos)]:DECRESCIMO := (cAlias)->E2_DECRESC
		oStTitulos[len(oStTitulos)]:SALDO      := IF(EMPTY(alltrim((cAlias)->E2_NUMBCO)),(cAlias)->E2_SALDO + (cAlias)->E2_SDACRES - (cAlias)->E2_SDDECRE,(cAlias)->E2_VALOR+(cAlias)->E2_ACRESC-(cAlias)->E2_DECRESC) 
		oStTitulos[len(oStTitulos)]:OBSERVACAO := (cAlias)->E2_HIST
		oStTitulos[len(oStTitulos)]:CHAVE      := (cAlias)->E2_FILIAL+(cAlias)->E2_PREFIXO+(cAlias)->E2_NUM+(cAlias)->E2_PARCELA+(cAlias)->E2_TIPO+(cAlias)->E2_FORNECE+(cAlias)->E2_LOJA
		//Quando eu consulto, eu busco o limite de registros+1, então sempre que for enviar o último registro encontrado, quer dizer que acabou
		oStTitulos[len(oStTitulos)]:ULTIMO     := if( nNumRegs == nCntRegs ,.T.,.F.)
		(cAlias)->(DbSkip())

	enddo 	

	(cAlias)->(dbclosearea()) 

return .T. /* fim do metodo  */


/*
+------------+---------------------------------------------------------------+
! Funcao     ! Metodo WS                                                     !
+------------+---------------------------------------------------------------+
! Autor      ! Eduardo G. Vieira                                              !
+------------+---------------------------------------------------------------+
! Descricao  ! Retorna os títulos em aberto!
+------------+---------------------------------------------------------------+
! Parametros !                                                               !
+------------+---------------------------------------------------------------+
*/
WSMETHOD TRACKER WSRECEIVE Usuario,Senha,codEmpresa, Chave WSSEND oStTracker WSSERVICE WsPagamentos

	Local cUsuario 	:= GetNewPar("TCP_WSPGUS",'tcp')
	Local cSenha 	:= GetNewPar("TCP_WSPGSN",'yTX27qkuwm')
	Local cWhere 	:= '%'
	Local _cFil  	:= '01'
	Local cCodEmp   := ::codEmpresa
	Local cChave    := ::Chave
	Local cTabela   := ::codEmpresa+'0'
	Local cTabE2    := '' //'%SE2'+cTabela+'%'
	Local cTabED    := '' //'%SED'+cTabela+'%'
	//Fornecedores é utilizada a mesma tabela para todos
	Local cTabA2    := ''//'%SA2020%'
	Local cTabEA    := ''//'%SEA'+cTabela+'%'
	Local cTabD1    := ''//'%SD1'+cTabela+'%'
	Local cTabF1    := ''//'%SF1'+cTabela+'%'
	Local cTabC7    := ''//'%SC7'+cTabela+'%'
	Local cTabE4    := ''//'%SE4'+cTabela+'%'
	Local cTabB1    := ''//'%SB1020%'
	Local cTabCR    := ''//'%SCR'+cTabela+'%'
	Local aItens 
	Local cAlias
	Local cAliasAx
	Local cAliasAx2
	Local cPedidos := ''
	Local cSolicit := ''
	Local cUltPed  := ''
	Local cContrat  := ''
	Local cErro
	Local cChaveAne := ''
	Local cCodMPayment := ""
	Local dEmissao	:= CTOD('//')

	RpcClearEnv()
	RPCSetType(3)
	RpcSetEnv(cCodEmp,"01",,,"CFG")
	
	cTabE2    := '%' + FWSX2Util():GetFile( "SE2" ) + '%'
	cTabED    := '%' + FWSX2Util():GetFile( "SED" ) + '%'
	cTabA2    := '%' + FWSX2Util():GetFile( "SA2" ) + '%'
	cTabEA    := '%' + FWSX2Util():GetFile( "SEA" ) + '%'
	cTabD1    := '%' + FWSX2Util():GetFile( "SD1" ) + '%'
	cTabC7    := '%' + FWSX2Util():GetFile( "SC7" ) + '%'
	cTabF1    := '%' + FWSX2Util():GetFile( "SF1" ) + '%'
	cTabE4    := '%' + FWSX2Util():GetFile( "SE4" ) + '%'
	cTabB1    := '%' + FWSX2Util():GetFile( "SB1" ) + '%'
	cTabCR    := '%' + FWSX2Util():GetFile( "SCR" ) + '%'

	cErro := validaPar(::Usuario,::Senha,cCodEmp)

	if !empty(cErro)
		SetSoapFault("Consulta TRACKER",cErro)		 			
		Return .F.
	EndIf

	If Empty(::Chave)
		SetSoapFault("Consulta TRACKER","Informe a chave do título.")		 			
		Return .F.
	EndIf

	cAlias := getNextAlias()

	BeginSQL Alias cAlias

		SELECT E2_FILIAL,E2_NUM,E2_TIPO,E2_PREFIXO,E2_PARCELA, E2_FORNECE,E2_LOJA,E2_TITPAI,E2_XCODPGM,E2_EMISSAO
		FROM %EXP:cTabE2% SE2
		WHERE SE2.%NotDel%  AND E2_FILIAL||E2_PREFIXO||E2_NUM||E2_PARCELA||E2_TIPO||E2_FORNECE||E2_LOJA = %EXP:cChave%

	EndSQL

	AAdd(oStTracker, WsClassNew("StTracker"))
	oStTracker[len(oStTracker)]:EMPRESA    := cCodEmp
	oStTracker[len(oStTracker)]:NOMEEMPRESA:= Posicione("SM0",1,cCodEmp,"M0_NOMECOM")     

	//Quando o título for do tipo taxa, 
	IF !(cAlias)->(Eof()) .AND. !EMPTY(ALLTRIM((cAlias)->E2_TITPAI))
		
		cAliasAx := getNextAlias()

		BeginSQL Alias cAliasAx

			SELECT E2_FILIAL,E2_NUM,E2_TIPO,E2_PREFIXO,E2_PARCELA, E2_FORNECE,E2_LOJA
			FROM %EXP:cTabE2% SE2
			WHERE SE2.%NotDel%  AND E2_FILIAL = %EXP:(cAlias)->E2_FILIAL% AND 
			E2_PREFIXO||E2_NUM||E2_PARCELA||E2_TIPO||E2_FORNECE||E2_LOJA = %EXP:(cAlias)->E2_TITPAI%

		EndSQL

		IF !(cAliasAx)->(Eof())
			cChave := (cAliasAx)->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
			cChaveAne := "'SE2"+ (cAliasAx)->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)+"'"
		ENDIF

		(cAliasAx)->(dbclosearea())
	ELSE
		cCodMPayment := (cAlias)->E2_XCODPGM
		dEmissao 	 := STOD((cAlias)->E2_EMISSAO)
		If( Empty(cCodMPayment) )
			cChaveAne 	 := "'SE2"+ (cAlias)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)+"'"
		Else
			cChaveAne 	 := "'ZA0"+(cAlias)->(E2_FILIAL)+cCodMPayment+"'"
			cChaveAne 	 += ",'SE2"+ (cAlias)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)+"'"
		EndIf
	endif
	
	cFornece := (cAlias)->E2_FORNECE
	cLoja	 := (cAlias)->E2_LOJA

	(cAlias)->(dbclosearea()) 
	
	//Se nao for solicitacao de pagamento
	If( Empty( cCodMPayment )  )

		cAlias := getNextAlias()

		BeginSQL Alias cAlias

			SELECT F1_FILIAL,F1_DOC, F1_SERIE,F1_TIPO, F1_EMISSAO, F1_DTDIGIT, F1_ESPECIE, E4_DESCRI, F1_VALICM, F1_VALIPI,F1_VALCOFI,F1_VALPIS, D1_COD,B1_DESC,
			D1_QUANT,D1_VUNIT,D1_TOTAL,D1_CONTA,D1_CC,F1_FORNECE,F1_LOJA,A2_NOME,A2_NREDUZ,D1_PEDIDO,D1_ITEMPC, D1_ITEM
			FROM %EXP:cTabE2% SE2
			INNER JOIN %EXP:cTabA2% SA2 ON E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA AND SA2.%NotDel%
			INNER JOIN %EXP:cTabF1% SF1 ON F1_FILIAL = E2_FILIAL AND E2_NUM = F1_DOC AND E2_PREFIXO = F1_SERIE AND E2_FORNECE = F1_FORNECE AND E2_LOJA = F1_LOJA AND SF1.%NotDel%
			INNER JOIN %EXP:cTabD1% SD1 ON D1_FILIAL = E2_FILIAL AND E2_NUM = D1_DOC AND E2_PREFIXO = D1_SERIE AND E2_FORNECE = D1_FORNECE AND E2_LOJA = D1_LOJA AND SD1.%NotDel%
			INNER JOIN %EXP:cTabB1% SB1 ON B1_COD = D1_COD AND SB1.%NotDel%
			LEFT JOIN %EXP:cTabE4% SE4 ON F1_COND = E4_CODIGO AND SE4.%NotDel%
			WHERE SE2.%NotDel%  AND E2_FILIAL||E2_PREFIXO||E2_NUM||E2_PARCELA||E2_TIPO||E2_FORNECE||E2_LOJA = %EXP:cChave%

		EndSQL

		IF !(cAlias)->(Eof())

			oStTracker[len(oStTracker)]:FILIAL     := (cAlias)->F1_FILIAL
			//--------NOTAS------------
			oStTracker[len(oStTracker)]:NOTAS := {}
			aadd(oStTracker[len(oStTracker)]:NOTAS, WSClassNew("StNota"))

			oStTracker[len(oStTracker)]:NOTAS[1]:DOCUMENTO := (cAlias)->F1_DOC
			oStTracker[len(oStTracker)]:NOTAS[1]:SERIE 	:= (cAlias)->F1_SERIE
			oStTracker[len(oStTracker)]:NOTAS[1]:FORNECEDOR:= (cAlias)->F1_FORNECE+(cAlias)->F1_LOJA
			oStTracker[len(oStTracker)]:NOTAS[1]:NOME 		:= (cAlias)->A2_NREDUZ
			oStTracker[len(oStTracker)]:NOTAS[1]:RAZAO 	:= (cAlias)->A2_NOME
			oStTracker[len(oStTracker)]:NOTAS[1]:EMISSAO 	:= STOD((cAlias)->F1_EMISSAO)
			oStTracker[len(oStTracker)]:NOTAS[1]:DIGITACAO := STOD((cAlias)->F1_DTDIGIT)
			oStTracker[len(oStTracker)]:NOTAS[1]:TIPO 		:= (cAlias)->F1_TIPO
			oStTracker[len(oStTracker)]:NOTAS[1]:ESPECIE 	:= (cAlias)->F1_ESPECIE
			oStTracker[len(oStTracker)]:NOTAS[1]:CONDPG 	:= (cAlias)->E4_DESCRI
			oStTracker[len(oStTracker)]:NOTAS[1]:ICMS 		:= (cAlias)->F1_VALICM
			oStTracker[len(oStTracker)]:NOTAS[1]:IPI 		:= (cAlias)->F1_VALIPI
			oStTracker[len(oStTracker)]:NOTAS[1]:PIS 		:= (cAlias)->F1_VALPIS
			oStTracker[len(oStTracker)]:NOTAS[1]:COFINS 	:= (cAlias)->F1_VALCOFI

			cChaveAne += ",'SF1"+(cAlias)->F1_DOC+(cAlias)->F1_SERIE+(cAlias)->F1_FORNECE+(cAlias)->F1_LOJA + "'"

			aItens := {}

			WHILE !(cAlias)->(Eof())

				aadd(aItens, WSClassNew("StItemNota"))
				aItens[len(aItens)]:ITEM	 	 := (cAlias)->D1_ITEM
				aItens[len(aItens)]:PRODUTO 	 := (cAlias)->D1_COD
				aItens[len(aItens)]:DESCRICAO 	 := (cAlias)->B1_DESC
				aItens[len(aItens)]:QUANTIDADE  := (cAlias)->D1_QUANT
				aItens[len(aItens)]:VALORUNIT 	 := (cAlias)->D1_VUNIT
				aItens[len(aItens)]:VALORTOTAL  := (cAlias)->D1_TOTAL
				aItens[len(aItens)]:CENTROCUSTO := (cAlias)->D1_CC
				aItens[len(aItens)]:CONTA 		 := (cAlias)->D1_CONTA
				aItens[len(aItens)]:PEDIDO 	 := (cAlias)->D1_PEDIDO
				aItens[len(aItens)]:ITEMPEDIDO	 := (cAlias)->D1_ITEMPC

				IF(!EMPTY(cPedidos))
					cPedidos += ','
				ENDIF

				IF(!EMPTY((cAlias)->D1_PEDIDO))
					cPedidos += "'"+(cAlias)->F1_FILIAL+(cAlias)->D1_PEDIDO+(cAlias)->D1_ITEMPC+"'"
				ENDIF
				(cAlias)->(DbSkip())
			ENDDO

			oStTracker[len(oStTracker)]:NOTAS[1]:ITENS := aItens

			//------------------------------FIM NOTA--------------------------//


			//----------------------------PEDIDO DE COMPRA--------------------//
			(cAlias)->(DBGOTOP())

			if(!EMPTY(cPedidos))
				aRet := retPedidos(cCodEmp,cPedidos,@oStTracker)
				cSolicit  := aRet[1]
				cContrat  := aRet[2]
				cChaveAne += aRet[3]
			ENDIF

			//------------------------------FIM PEDIDO--------------------------//


			//----------------------------COTACOES--------------------//
			(cAlias)->(DBGOTOP())

			if(!EMPTY(cSolicit))
				retCotacoes(cCodEmp,cSolicit,@oStTracker)
			ENDIF

			//------------------------------FIM COTACOES--------------------------//


			//----------------------------SOLICITAÇÃO DE COMPRA--------------------//
			(cAlias)->(DBGOTOP())

			if(!EMPTY(cSolicit))
				cChaveAne += retSolicitacoes(cCodEmp,cSolicit,@oStTracker)
			ENDIF

			//------------------------------FIM SOLICITAÇÃO--------------------------//


			//----------------------------CONTRATOS--------------------//
			(cAlias)->(DBGOTOP())

			if(!EMPTY(cContrat))
				cChaveAne += retContratos(cCodEmp,cContrat,@oStTracker)
			Else
				returnPaymentList(cFornece,cLoja,@oStTracker)
			ENDIF


			//------------------------------FIM CONTRATOS--------------------------//

		ENDIF 	

		IF(!EMPTY(cChaveAne))
			retAnexos(cCodEmp,cChaveAne,@oStTracker)
		ENDIF

		(cAlias)->(dbclosearea()) 
	Else
		oStTracker[len(oStTracker)]:PEDIDOS := {}
		aItens := {}
		aadd(aItens, WSClassNew("StItemPedido"))
		aItens[len(aItens)]:ITEM	 	 := ""
		aItens[len(aItens)]:PRODUTO 	 := ""
		aItens[len(aItens)]:DESCRICAO 	 := ""
		aItens[len(aItens)]:QUANTIDADE   := 0
		aItens[len(aItens)]:VALORUNIT 	 := 0
		aItens[len(aItens)]:VALORTOTAL   := 0
		aItens[len(aItens)]:CENTROCUSTO  := ""
		aItens[len(aItens)]:CONTA 		 := ""
		aItens[len(aItens)]:ENTREGA	 	 := CTOD("//")
		aItens[len(aItens)]:SOLICITACAO  := ""
		aItens[len(aItens)]:ITEMSOLIC	 := ""
		aadd(oStTracker[len(oStTracker)]:PEDIDOS, WSClassNew("StPedido"))
		oStTracker[len(oStTracker)]:PEDIDOS[len(oStTracker[len(oStTracker)]:PEDIDOS)]:NUMERO      := cCodMPayment
		oStTracker[len(oStTracker)]:PEDIDOS[len(oStTracker[len(oStTracker)]:PEDIDOS)]:EMISSAO     := dEmissao
		oStTracker[len(oStTracker)]:PEDIDOS[len(oStTracker[len(oStTracker)]:PEDIDOS)]:ITENS		  := aItens
		oStTracker[len(oStTracker)]:PEDIDOS[len(oStTracker[len(oStTracker)]:PEDIDOS)]:APROVADORES := retAprovadores(cCodEmp,cCodMPayment,'AP')
		IF(!EMPTY(cChaveAne))
			retAnexos(cCodEmp,cChaveAne,@oStTracker)
		ENDIF
		returnPaymentList(cFornece,cLoja,@oStTracker)
	EndIf

return .T. /* fim do metodo  */

static function retPedidos(cCodEmp,cPedidos,oStTracker)

	Local cTabela   := cCodEmp+'0'
	Local cTabE2    := '%' + FWSX2Util():GetFile( "SE2" ) + '%'
	Local cTabED    := '%' + FWSX2Util():GetFile( "SED" ) + '%'
	Local cTabA2    := '%' + FWSX2Util():GetFile( "SA2" ) + '%'
	Local cTabEA    := '%' + FWSX2Util():GetFile( "SEA" ) + '%'
	Local cTabD1    := '%' + FWSX2Util():GetFile( "SD1" ) + '%'
	Local cTabC7    := '%' + FWSX2Util():GetFile( "SC7" ) + '%'
	Local cTabF1    := '%' + FWSX2Util():GetFile( "SF1" ) + '%'
	Local cTabE4    := '%' + FWSX2Util():GetFile( "SE4" ) + '%'
	Local cTabB1    := '%' + FWSX2Util():GetFile( "SB1" ) + '%'
	Local cTabCR    := '%' + FWSX2Util():GetFile( "SCR" ) + '%'
	Local cSolicit  := ''
	Local cContrat  := ''
	Local cChaveAne := ''
	cPedidos := '%'+cPedidos+'%'

	cAliasAx := getNextAlias()

	BeginSQL Alias cAliasAx

		SELECT C7_FILIAL,C7_NUM, C7_PRODUTO, C7_DESCRI,C7_QUANT,C7_PRECO,C7_TOTAL,C7_DATPRF,C7_NUMSC,C7_CC,C7_CONTA,C7_EMISSAO,C7_NUMSC,C7_ITEM,
		C7_ITEMSC,C7_CONTRA,C7_CONTREV,C7_MEDICAO
		FROM %EXP:cTabC7% SC7
		WHERE SC7.%NotDel% AND C7_FILIAL||C7_NUM||C7_ITEM IN (%EXP:cPedidos%)
		ORDER BY C7_NUM

	EndSQL

	cUltPed := ''

	IF !(cAliasAx)->(Eof())

		oStTracker[len(oStTracker)]:PEDIDOS := {}
		aItens := {}

		WHILE !(cAliasAx)->(Eof())

			aadd(aItens, WSClassNew("StItemPedido"))
			aItens[len(aItens)]:ITEM	 	 := (cAliasAx)->C7_ITEM
			aItens[len(aItens)]:PRODUTO 	 := (cAliasAx)->C7_PRODUTO
			aItens[len(aItens)]:DESCRICAO 	 := (cAliasAx)->C7_DESCRI
			aItens[len(aItens)]:QUANTIDADE  := (cAliasAx)->C7_QUANT
			aItens[len(aItens)]:VALORUNIT 	 := (cAliasAx)->C7_PRECO
			aItens[len(aItens)]:VALORTOTAL  := (cAliasAx)->C7_TOTAL
			aItens[len(aItens)]:CENTROCUSTO := (cAliasAx)->C7_CC
			aItens[len(aItens)]:CONTA 		 := (cAliasAx)->C7_CONTA
			aItens[len(aItens)]:ENTREGA	 := STOD((cAliasAx)->C7_DATPRF)
			aItens[len(aItens)]:SOLICITACAO := (cAliasAx)->C7_CONTA
			aItens[len(aItens)]:ITEMSOLIC	 := (cAliasAx)->C7_ITEMSC

			IF(!EMPTY(cSolicit))
				cSolicit += ','
			ENDIF

			IF(!EMPTY((cAliasAx)->C7_NUMSC))
				cSolicit += "'"+(cAliasAx)->C7_FILIAL+(cAliasAx)->C7_NUMSC+(cAliasAx)->C7_ITEMSC+"'"
			ENDIF

			IF(!EMPTY(cContrat))
				cContrat += ','
			ENDIF

			IF(!EMPTY((cAliasAx)->C7_CONTRA))
				cContrat += "'"+(cAliasAx)->C7_FILIAL+(cAliasAx)->C7_CONTRA+(cAliasAx)->C7_CONTREV+"'"
			ENDIF


			cChaveAne += ",'SC7"+(cAliasAx)->C7_FILIAL+ (cAliasAx)->C7_NUM+(cAliasAx)->C7_ITEM + "'"
			cChaveAne += ",'CND"+(cAliasAx)->C7_FILIAL+(cAliasAx)->C7_CONTRA+(cAliasAx)->C7_CONTREV +(cAliasAx)->C7_MEDICAO+ "'"
			cChaveAne += ",'CND"+(cAliasAx)->C7_FILIAL+(cAliasAx)->C7_CONTRA+(cAliasAx)->C7_MEDICAO+ "'"

			cUltPed   := (cAliasAx)->C7_NUM
			cUltEmiss := (cAliasAx)->C7_EMISSAO

			(cAliasAx)->(DbSkip())

			//Despois do skip, verifico se trocou o pedido, ou acabou todos, e incluo no objeto
			IF((cAliasAx)->(Eof()) .OR. cUltPed != (cAliasAx)->C7_NUM)
				aadd(oStTracker[len(oStTracker)]:PEDIDOS, WSClassNew("StPedido"))

				oStTracker[len(oStTracker)]:PEDIDOS[len(oStTracker[len(oStTracker)]:PEDIDOS)]:NUMERO      := cUltPed
				oStTracker[len(oStTracker)]:PEDIDOS[len(oStTracker[len(oStTracker)]:PEDIDOS)]:EMISSAO     := STOD(cUltEmiss)
				oStTracker[len(oStTracker)]:PEDIDOS[len(oStTracker[len(oStTracker)]:PEDIDOS)]:ITENS		  := aItens
				oStTracker[len(oStTracker)]:PEDIDOS[len(oStTracker[len(oStTracker)]:PEDIDOS)]:APROVADORES := retAprovadores(cCodEmp,cUltPed,'PC')

				aItens := {}

			ENDIF
		ENDDO

	ENDIF
	(cAliasAx)->(dbclosearea())
return {cSolicit,cContrat,cChaveAne}

static function retAprovadores(cCodEmp,cUltPed,cTipo)
	
	Local cAlias := getNextAlias()
	Local cTabela   := cCodEmp+'0'
	Local cTabCR    := '%' + FWSX2Util():GetFile( "SCR" ) + '%'
	Local cTabAK    := '%' + FWSX2Util():GetFile( "SAK" ) + '%'
	Local cStatus   := ''

	BeginSQL Alias cAlias
		SELECT CR_DATALIB,CR_NIVEL, AK_NOME,CR_STATUS,CR_USER
		FROM %EXP:cTabCR% SCR
		INNER JOIN %EXP:cTabAK% SAK ON AK_FILIAL = CR_FILIAL AND AK_COD = CR_APROV and SAK.%NotDel% 
		WHERE SCR.%NotDel%  AND CR_NUM = %EXP:cUltPed% AND CR_TIPO = %exp:cTipo%
		ORDER BY CR_NIVEL

	EndSQL

	cUltPed := ''

	aItens := {}

	WHILE !(cAlias)->(Eof())
		if (cAlias)->CR_STATUS== "01"
			cStatus := 'Aguardando outros níveis'
		elseif (cAlias)->CR_STATUS== "02"
			cStatus := 'Aguardando aprovação do usuário'
		elseif (cAlias)->CR_STATUS== "03"
			cStatus := 'Liberado'
		elseif (cAlias)->CR_STATUS== "04"
			cStatus := 'Bloqueado'
		elseif (cAlias)->CR_STATUS== "05"
			cStatus := 'Liberado'
		endif

		aadd(aItens, WSClassNew("StAprovador"))
		aItens[len(aItens)]:DTAPROV := STOD((cAlias)->CR_DATALIB)
		aItens[len(aItens)]:NOME 	 := RetNomFunc((cAlias)->CR_USER)
		aItens[len(aItens)]:STATUS	 := cStatus
		aItens[len(aItens)]:NIVEL 	 := VAL((cAlias)->CR_NIVEL)

		(cAlias)->(DbSkip())
	ENDDO

	(cAlias)->(dbclosearea())

return aItens


STATIC FUNCTION RetNomFunc(cCodigo)
_cNomUsu := ''

IF(!EMPTY(cCodigo))
	_aRetUsu := FWSFALLUSERS({cCodigo})
	if(LEN(_aRetUsu) >= 1 .AND. LEN(_aRetUsu[1]) >= 4)
		_cNomUsu := ALLTRIM(_aRetUsu[1,4])
	ENDIF
endif

return _cNomUsu

static function retCotacoes(cCodEmp,cSolici,oStTracker)

	Local cTabela   := cCodEmp+'0'
	Local cTabC8    := '%' + FWSX2Util():GetFile( "SC8" ) + '%'
	Local cTabE4    := '%' + FWSX2Util():GetFile( "SE4" ) + '%'
	Local cTabB1    := '%' + FWSX2Util():GetFile( "SB1" ) + '%'
	//Fornecedores é utilizada a mesma tabela para todos
	Local cTabA2    := '%' + FWSX2Util():GetFile( "SA2" ) + '%'

	cSolici := '%'+cSolici+'%'

	cAliasAx := getNextAlias()

	BeginSQL Alias cAliasAx

		SELECT C8_NUM,C8_FORNECE,C8_LOJA,A2_NOME,A2_NREDUZ,C8_EMISSAO,E4_DESCRI,C8_ITEM,C8_PRODUTO, B1_DESC,C8_QUANT,C8_PRECO,C8_TOTAL,
		C8_DATPRF,C8_NUMPED,C8_NUMSC,C8_ITEMSC
		FROM %EXP:cTabC8% SC8
		INNER JOIN %EXP:cTabA2% SA2 ON C8_FORNECE = A2_COD AND A2_LOJA = C8_LOJA AND SA2.%NotDel%
		INNER JOIN %EXP:cTabB1% SB1 ON B1_COD = C8_PRODUTO AND SB1.%NotDel%
		LEFT JOIN %EXP:cTabE4% SE4 ON C8_FILIAL = E4_FILIAL AND C8_COND = E4_CODIGO AND SE4.%NotDel%
		WHERE SC8.%NotDel%  AND C8_FILIAL||C8_NUMSC||C8_ITEMSC IN (%EXP:cSolici%)
		ORDER BY C8_NUM,C8_FORNECE

	EndSQL

	cUltPed := ''

	aItens := {}

	oStTracker[len(oStTracker)]:COTACOES := {}
	WHILE !(cAliasAx)->(Eof())

		aadd(aItens, WSClassNew("StItemCotacao"))
		aItens[len(aItens)]:ITEM	 	 := (cAliasAx)->C8_ITEM
		aItens[len(aItens)]:SOLICITACAO := (cAliasAx)->C8_NUMSC
		aItens[len(aItens)]:ITEMSOLIC 	 := (cAliasAx)->C8_ITEMSC
		aItens[len(aItens)]:PRODUTO 	 := (cAliasAx)->C8_PRODUTO
		aItens[len(aItens)]:DESCRICAO 	 := (cAliasAx)->B1_DESC
		aItens[len(aItens)]:QUANTIDADE  := (cAliasAx)->C8_QUANT
		aItens[len(aItens)]:VALORUNIT	 := (cAliasAx)->C8_PRECO
		aItens[len(aItens)]:VALORTOTAL	 := (cAliasAx)->C8_TOTAL
		aItens[len(aItens)]:ENTREGA	 := STOD((cAliasAx)->C8_DATPRF)
		aItens[len(aItens)]:VENCEDORA	 := IF((cAliasAx)->C8_NUMPED == 'XXXXXX' .OR. EMPTY((cAliasAx)->C8_NUMPED),.F.,.T.)

		cUltCt    := (cAliasAx)->C8_NUM
		cUltEmiss := (cAliasAx)->C8_EMISSAO
		cUltFor   := (cAliasAx)->C8_FORNECE
		cUltRaz   := (cAliasAx)->A2_NOME
		cUltNome  := (cAliasAx)->A2_NREDUZ
		cUltCond  := (cAliasAx)->E4_DESCRI
		(cAliasAx)->(DbSkip())	 	
		//Despois do skip, verifico se trocou o pedido, ou acabou todos, e incluo no objeto
		IF((cAliasAx)->(Eof()) .OR. cUltCt != (cAliasAx)->C8_NUM .OR. cUltFor != (cAliasAx)->C8_FORNECE)
			aadd(oStTracker[len(oStTracker)]:COTACOES, WSClassNew("StCotacao"))

			oStTracker[len(oStTracker)]:COTACOES[len(oStTracker[len(oStTracker)]:COTACOES)]:NUMERO     := cUltCt
			oStTracker[len(oStTracker)]:COTACOES[len(oStTracker[len(oStTracker)]:COTACOES)]:FORNECEDOR := cUltFor
			oStTracker[len(oStTracker)]:COTACOES[len(oStTracker[len(oStTracker)]:COTACOES)]:NOME       := cUltNome
			oStTracker[len(oStTracker)]:COTACOES[len(oStTracker[len(oStTracker)]:COTACOES)]:RAZAO      := cUltRaz
			oStTracker[len(oStTracker)]:COTACOES[len(oStTracker[len(oStTracker)]:COTACOES)]:CONDPG     := cUltCond
			oStTracker[len(oStTracker)]:COTACOES[len(oStTracker[len(oStTracker)]:COTACOES)]:EMISSAO    := STOD(cUltEmiss)
			oStTracker[len(oStTracker)]:COTACOES[len(oStTracker[len(oStTracker)]:COTACOES)]:ITENS	  := aItens

			aItens := {}

		ENDIF
	ENDDO


	(cAliasAx)->(dbclosearea())
return 

static function retSolicitacoes(cCodEmp,cSolici,oStTracker)

	Local cTabela   := cCodEmp+'0'
	Local cTabC1    := '%' + FWSX2Util():GetFile( "SC1" ) + '%'
	Local cChaveAne := ''
	cSolici := '%'+cSolici+'%'

	cAliasAx := getNextAlias()

	BeginSQL Alias cAliasAx

		SELECT C1_FILIAL,C1_NUM, C1_PRODUTO, C1_DESCRI,C1_QUANT,C1_DATPRF,C1_ITEM,C1_EMISSAO
		FROM %EXP:cTabC1% SC1
		WHERE SC1.%NotDel%  AND C1_FILIAL||C1_NUM||C1_ITEM IN (%EXP:cSolici%)
		ORDER BY C1_NUM

	EndSQL

	cUltPed := ''

	IF !(cAliasAx)->(Eof())
		oStTracker[len(oStTracker)]:SOLICITACOES := {}

		aItens := {}

		WHILE !(cAliasAx)->(Eof())

			aadd(aItens, WSClassNew("StItemSolicitacao"))
			aItens[len(aItens)]:ITEM	 	 := (cAliasAx)->C1_ITEM
			aItens[len(aItens)]:PRODUTO 	 := (cAliasAx)->C1_PRODUTO
			aItens[len(aItens)]:DESCRICAO 	 := (cAliasAx)->C1_DESCRI
			aItens[len(aItens)]:QUANTIDADE  := (cAliasAx)->C1_QUANT
			aItens[len(aItens)]:ENTREGA	 := STOD((cAliasAx)->C1_DATPRF)

			cChaveAne += ",'SC1"+(cAliasAx)->C1_FILIAL+(cAliasAx)->C1_NUM+(cAliasAx)->C1_ITEM + "'"

			cUltSc    := (cAliasAx)->C1_NUM
			cUltEmiss := (cAliasAx)->C1_EMISSAO

			(cAliasAx)->(DbSkip())

			//Despois do skip, verifico se trocou o pedido, ou acabou todos, e incluo no objeto
			IF((cAliasAx)->(Eof()) .OR. cUltSc != (cAliasAx)->C1_NUM)
				aadd(oStTracker[len(oStTracker)]:SOLICITACOES, WSClassNew("StSolCompras"))


				oStTracker[len(oStTracker)]:SOLICITACOES[len(oStTracker[len(oStTracker)]:SOLICITACOES)]:NUMERO      := cUltSc
				oStTracker[len(oStTracker)]:SOLICITACOES[len(oStTracker[len(oStTracker)]:SOLICITACOES)]:EMISSAO     := STOD(cUltEmiss)
				oStTracker[len(oStTracker)]:SOLICITACOES[len(oStTracker[len(oStTracker)]:SOLICITACOES)]:ITENS	   := aItens

				aItens := {}

			ENDIF
		ENDDO

	ENDIF
	(cAliasAx)->(dbclosearea())
return cChaveAne

static function retContratos(cCodEmp,cContrat,oStTracker)

	Local cTabela   := cCodEmp+'0'
	Local cTabCN9   := '%' + FWSX2Util():GetFile( "CN9" ) + '%'
	Local cTabD1    := '%' + FWSX2Util():GetFile( "SD1" ) + '%'
	Local cTabE2    := '%' + FWSX2Util():GetFile( "SE2" ) + '%'
	Local cTabC7    := '%' + FWSX2Util():GetFile( "SC7" ) + '%'
	Local cTabCE    := '%' + FWSX2Util():GetFile( "CNE" ) + '%'
	Local cChaveAne := ''
	cContrat := '%'+cContrat+'%'

	cAliasAx := getNextAlias()

	BeginSQL Alias cAliasAx

		SELECT CN9_FILIAL,CN9_NUMERO,CN9_REVISA,CN9_DTFIM,CN9_VIGE,CN9_UNVIGE,CN9_VLINI,CN9_VLATU,CN9_SALDO,CN9_DESCRI, SUM(CNE_VLTOT) AS TOTMED
		FROM %EXP:cTabCN9% CN9
		LEFT JOIN %EXP:cTabCE% CNE ON CNE_CONTRA = CN9_NUMERO AND CNE.%NotDel% 
		WHERE CN9.%NotDel%  AND CN9_FILIAL||CN9_NUMERO||CN9_REVISA IN (%EXP:cContrat%)
		GROUP BY CN9_FILIAL,CN9_NUMERO,CN9_REVISA,CN9_DTFIM,CN9_VIGE,CN9_UNVIGE,CN9_VLINI,CN9_VLATU,CN9_SALDO,CN9_DESCRI
		ORDER BY CN9_NUMERO

	EndSQL

	aItens := {}

	WHILE !(cAliasAx)->(Eof())

		oStTracker[len(oStTracker)]:CONTRATOS := {}
		aadd(oStTracker[len(oStTracker)]:CONTRATOS, WSClassNew("StContrato"))

		oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:NUMERO     := (cAliasAx)->CN9_NUMERO
		oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:DESCRICAO  := (cAliasAx)->CN9_DESCRI
		oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:REVISAO    := (cAliasAx)->CN9_REVISA
		oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:VIGENCIA   := (cAliasAx)->CN9_VIGE

		cChaveAne += ",'CN9"+(cAliasAx)->CN9_NUMERO + "'"

		cVige := ''                                                                                         
		if (cAliasAx)->CN9_UNVIGE == '1'
			cVige := 'Dias'
		elseif (cAliasAx)->CN9_UNVIGE == '2'
			cVige := 'Meses'
		elseif (cAliasAx)->CN9_UNVIGE == '3'
			cVige := 'Anos'
		else
			cVige := 'Indeterminada'
		endif

		oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:UNIDADEVIG := cVige
		oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:VALORINI   := (cAliasAx)->CN9_VLINI
		oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:VALORIATU  := (cAliasAx)->CN9_VLATU
		//oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:SALDO	   := (cAliasAx)->CN9_SALDO
		//Regras passadas pela TI, de acordo com as regras utilizadas no módulo decontratos da TCP
		//oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:VALORIATU  := if( EMPTY((cAliasAx)->CN9_REVISA),(cAliasAx)->CN9_VLATU,(cAliasAx)->CN9_VLATU-(cAliasAx)->CN9_VLINI)
		oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:SALDO	   := oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:VALORIATU - (cAliasAx)->TOTMED 
		oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:ENTREGA	   := STOD((cAliasAx)->CN9_DTFIM)

		aItens := {}

		cAliasAx2 := getNextAlias()

		BeginSQL Alias cAliasAx2

			SELECT E2_BAIXA, E2_VALOR-E2_SALDO AS VLBAIXA
			FROM %EXP:cTabE2% SE2
			INNER JOIN %EXP:cTabD1% SD1 ON D1_FILIAL = E2_FILIAL AND E2_NUM = D1_DOC AND E2_PREFIXO = D1_SERIE AND E2_FORNECE = D1_FORNECE AND E2_LOJA = D1_LOJA AND SD1.%NotDel%
			INNER JOIN %EXP:cTabC7% SC7 ON C7_FILIAL = D1_FILIAL AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC AND SC7.%NotDel%
			WHERE SE2.%NotDel% AND E2_BAIXA != ' ' AND E2_VALOR != E2_SALDO AND  C7_CONTRA = %EXP:(cAliasAx)->CN9_NUMERO%
			AND  E2_TIPO ='NF ' AND E2_ORIGEM = 'MATA100 '
			ORDER BY E2_BAIXA DESC
			OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY 

		EndSQL

		WHILE !(cAliasAx2)->(Eof())

			aadd(aItens, WSClassNew("StPgtoContrato"))
			aItens[len(aItens)]:DTPAGAMENTO := STOD((cAliasAx2)->E2_BAIXA)
			aItens[len(aItens)]:VALOR 	 	 := (cAliasAx2)->VLBAIXA

			(cAliasAx2)->(DbSkip())

		ENDDO

		(cAliasAx2)->(dbclosearea())

		oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:PAGAMENTOS	   := aItens

		//Busca o total pago do contrato
		cAliasAx2 := getNextAlias()

		BeginSQL Alias cAliasAx2

			SELECT SUM(E2_VALOR-E2_SALDO) AS VLTOTAL
			FROM %EXP:cTabE2% SE2
			INNER JOIN %EXP:cTabD1% SD1 ON D1_FILIAL = E2_FILIAL AND E2_NUM = D1_DOC AND E2_PREFIXO = D1_SERIE AND E2_FORNECE = D1_FORNECE AND E2_LOJA = D1_LOJA AND SD1.%NotDel%
			INNER JOIN %EXP:cTabC7% SC7 ON C7_FILIAL = D1_FILIAL AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC AND SC7.%NotDel%
			WHERE SE2.%NotDel% AND E2_BAIXA != ' ' AND E2_VALOR != E2_SALDO AND  C7_CONTRA = %EXP:(cAliasAx)->CN9_NUMERO%
			AND  E2_TIPO ='NF ' AND E2_ORIGEM = 'MATA100 '

		EndSQL

		if !(cAliasAx2)->(Eof())
			oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:TotalPagto	   := (cAliasAx2)->VLTOTAL
		else
			oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:TotalPagto	   := 0
		endif

		(cAliasAx2)->(dbclosearea())

		(cAliasAx)->(DbSkip())

	ENDDO

	(cAliasAx)->(dbclosearea())

return cChaveAne

static function retAnexos(cCodEmp,cChaveAne,oStTracker)

	Local cTabela   := cCodEmp+'0'
	Local cTabC9    := '%' + FWSX2Util():GetFile( "AC9" ) + '%'
	Local cTabCB    := '%' + FWSX2Util():GetFile( "ACB" ) + '%'
	Local cTpEnti   := ''
	cAliasAx := getNextAlias()

	cChaveAne := '%' +cChaveAne+ '%'	   

	BeginSQL Alias cAliasAx

		SELECT AC9_CODOBJ,AC9_ENTIDA,ACB_OBJETO
		FROM %EXP:cTabC9% AC9
		INNER JOIN %EXP:cTabCB% ACB ON ACB_FILIAL = AC9_FILIAL AND AC9_CODOBJ = ACB_CODOBJ
		WHERE AC9.%NotDel%  AND AC9_ENTIDA||AC9_CODENT IN (%EXP:cChaveAne%)
		ORDER BY AC9_ENTIDA,AC9_CODENT

	EndSQL

	oStTracker[len(oStTracker)]:ANEXOS := {}
	WHILE !(cAliasAx)->(Eof())

		aadd(oStTracker[len(oStTracker)]:ANEXOS, WSClassNew("StAnexo"))

		IF (cAliasAx)->AC9_ENTIDA == 'SC1'
			cTpEnti := 'Solicitação'
		ELSEIF (cAliasAx)->AC9_ENTIDA == 'SC7'
			cTpEnti := 'Pedido de compra'
		ELSEIF (cAliasAx)->AC9_ENTIDA == 'SF1'
			cTpEnti := 'Nota Fiscal'
		ELSEIF (cAliasAx)->AC9_ENTIDA == 'CN9'
			cTpEnti := 'Contrato'
		ELSEIF (cAliasAx)->AC9_ENTIDA == 'CND'
			cTpEnti := 'Medição do Contrato'
		ELSEIF ( (cAliasAx)->AC9_ENTIDA == 'SE2' .Or. (cAliasAx)->AC9_ENTIDA == 'ZA0' )
			cTpEnti := 'Título financeiro'
		ENDIF

		oStTracker[len(oStTracker)]:ANEXOS[len(oStTracker[len(oStTracker)]:ANEXOS)]:NOME	 := (cAliasAx)->ACB_OBJETO
		oStTracker[len(oStTracker)]:ANEXOS[len(oStTracker[len(oStTracker)]:ANEXOS)]:CODIGO	 := (cAliasAx)->AC9_CODOBJ
		oStTracker[len(oStTracker)]:ANEXOS[len(oStTracker[len(oStTracker)]:ANEXOS)]:TIPO	 := cTpEnti

		(cAliasAx)->(DbSkip())

	ENDDO

	(cAliasAx)->(dbclosearea())

return

WSMETHOD ANEXOS WSRECEIVE Usuario,Senha,codEmpresa ,codObjeto,nParte WSSEND oStAnexos WSSERVICE WsPagamentos
	Local cCodEmp   := ::codEmpresa
	Local cTabela   := cCodEmp+'0'
	Local cTabC9    := '%' + FWSX2Util():GetFile( "AC9" ) + '%'
	Local cTabCB    := '%' + FWSX2Util():GetFile( "ACB" ) + '%'
	Local cTpEnti   := ''
	Local cAliasAx
	Local cObjeto := ::codObjeto
	Local _cCaminho := 'dirdoc\co'+cCodEmp+"\shared\"
	Local nMaxArq    := GetNewPar("TCP_MAXARQ",700000)
	Local cServidor  := GetNewPar("TCP_STVFTP",'10.41.4.39')
	Local cLogin    := GetNewPar("TCP_USUFTP",'usrwfpagamentos')
	Local cSenha    := GetNewPar("TCP_SENFTP",'ursinho@123')
	Local nTotPart   := 0
	Local nInicArq   := ::nParte * nMaxArq
	Local cArqEnv
	Local cTamanho   := 0
	Local cOrigem   := 'caminho\no\ftp'
	Local cDestino := '\'
	Local lRet      := .T.
	
	RpcClearEnv()
	RPCSetType(3)
	RpcSetEnv(cCodEmp,"01",,,"CFG")
	
	cTabC9    := '%' + FWSX2Util():GetFile( "AC9" ) + '%'
	cTabCB    := '%' + FWSX2Util():GetFile( "ACB" ) + '%'

	cErro := validaPar(::Usuario,::Senha,cCodEmp)

	if !empty(cErro)
		SetSoapFault("Consulta TITULOS",cErro)		 			
		Return .F.
	EndIf

	cAliasAx := getNextAlias()


	BeginSQL Alias cAliasAx

		SELECT ACB_OBJETO
		FROM %EXP:cTabCB% ACB

		WHERE ACB.%NotDel%  AND ACB_CODOBJ = %EXP:cObjeto%

	EndSQL


	IF !(cAliasAx)->(Eof())
		IF FILE(_cCaminho+alltrim(LOWER((cAliasAx)->ACB_OBJETO)))  

			nArq:=fOpen(_cCaminho+alltrim(LOWER((cAliasAx)->ACB_OBJETO))) 

			if nArq > -1 // abriu arquivo com sucesso          
				lRetCon = .F.
				nContCon = 0
				
				//Tenta conectar 5x ou até retornar sucesso.
				while !lRetCon .AND. nContCon < 20
					If FTPConnect( cServidor, 21,cLogin, cSenha )
						lRetCon := .T.
					ENDIF
					nContCon++
				ENDDO
				
				//FTPDisconnect()
				If !lRetCon
					SetSoapFault("Consulta TITULOS",'Não foi possível conectar ao FTP.')		 			
					Return .F.
				Else
					If FTPDirChange(cDestino)
						//aArqs := FTPDIRECTORY( cArqs )
						//nArqsCopy := Len(aArqs)
                        aRetDir := FTPDIRECTORY ( "*.*" , "D") 
                        
                       	If !FTPUPLOAD( _cCaminho+alltrim(LOWER((cAliasAx)->ACB_OBJETO) ),alltrim((cAliasAx)->ACB_OBJETO ))
						
							SetSoapFault("Consulta TITULOS",'Não foi possível copiar o arquivo para o FTP')		 			
							Return .F.       
						else
							AAdd(oStAnexos, WsClassNew("StArquivo"))
							oStAnexos[len(oStAnexos)]:ARQUIVO    := 'FTP://'+cServidor+'/'+alltrim((cAliasAx)->ACB_OBJETO)
							oStAnexos[len(oStAnexos)]:PARTE      := 1
							oStAnexos[len(oStAnexos)]:QTDPARTES  := 0
						EndIf
					else
						SetSoapFault("Consulta TITULOS",'Não foi possível alterar o diretório do FTP.')		 			
						Return .F.
					EndIf  
					FTPDISCONNECT ()
				EndIf
            else
				SetSoapFault("Consulta TITULOS",'Não foi possível abrir o arquivo.')		 			
				Return .F.
			endif                                                                  
		else
			SetSoapFault("Consulta TITULOS",'Arquivo não encontrado.')		 			
			Return .F.
		endif
    else
  		SetSoapFault("Consulta TITULOS",'Arquivo inválido.')		 			
		Return .F.
	ENDIF
	(cAliasAx)->(dbclosearea())

return .T.


static function validaPar(cUsuWs,cPassWs,cCodEmpWs)
	Local cErro := ''
	Local cUsuario 	:= GetNewPar("TCP_WSPGUS",'tcp')
	Local cSenha 	:= GetNewPar("TCP_WSPGSN",'yTX27qkuwm')

	If Empty(cUsuWs)
		cErro := "Informe o usuário."	
	EndIf

	If Empty(cPassWs)
		cErro := "Informe a senha."
	EndIf

	If ALLTRIM(cUsuWs) != cUsuario
		cErro := "Usuário inválido."
	EndIf

	If ALLTRIM(cPassWs) != cSenha
		cErro :="Senha inválida."
	EndIf

	If Empty(cCodEmpWs)
		cErro :="Informe a empresa."
	EndIf

	If VAL(cCodEmpWs) <=0
		cErro :="Empresa inválida."
	EndIf

return cErro

/*/{Protheus.doc} GetSX3cBox
Função criada para ler descrição de um campo a partir do codigo para um determinado campo.
@type function
@version 12.1.25
@author Kaique Mathias
@since 5/26/2020
@param cCampo, character, param_description
@param cValor, character, param_description
@param cIdioma, character, param_description
@return return_type, return_description
/*/

Static Function GetSX3cBox(cCampo, cValor, cIdioma )

	Default cIdioma := "1"

	cBox 	:= GetSx3Cache(cCampo,If(cIdioma=="1","X3_CBOX",If(cIdioma=="2","X3_CBOXSPA","X3_CBOXENG")))
	aCombo 	:= StrToKArr(cBox, ";")

Return( GetArVal(aCombo, cValor) )

/*/{Protheus.doc} GetArVal
Função criada para procurar um codigo em um array passado por parametro e retornar a descrição.
@type function
@version 12.1.25
@author Kaique Mathias
@since 5/26/2020
@param aArray, array, param_description
@param cValor, character, param_description
@return return_type, return_description
/*/

Static Function GetArVal(aArray, cValor)
	
	Local nInd

	For nInd := 1 To Len(aArray)
		If Substr(aArray[nInd], 1, At("=",aArray[nInd]) - 1) == cValor
			Return Substr(aArray[nInd], At("=",aArray[nInd]) + 1, Len(aArray[nInd]))
		EndIf
	Next nInd

Return( "" )

Static Function returnPaymentList(cFornece,cLoja,oStTracker)
	
	oStTracker[len(oStTracker)]:CONTRATOS := {}
	aadd(oStTracker[len(oStTracker)]:CONTRATOS, WSClassNew("StContrato"))

	oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:NUMERO     := ''
	oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:DESCRICAO  := Posicione('SA2',1,xFilial('SA2')+cFornece+cLoja,"A2_NOME")
	oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:REVISAO    := '' 
	oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:VIGENCIA   := 0
	oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:UNIDADEVIG := ''
	oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:VALORINI   := 0
	oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:VALORIATU  := 0
	oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:SALDO	   := 0
	oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:ENTREGA	   := CTOD('//')

	aItens := {}

	cAliasAx2 := getNextAlias()

	BeginSQL Alias cAliasAx2

		SELECT E2_BAIXA, E2_VALOR-E2_SALDO AS VLBAIXA
		FROM %table:SE2% SE2
		WHERE SE2.%NotDel% AND E2_BAIXA != ' ' AND SE2.E2_FORNECE = %EXP:cFornece% AND SE2.E2_LOJA=%EXP:cLoja% AND E2_VALOR != E2_SALDO
		ORDER BY E2_BAIXA DESC
		OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY 

	EndSQL

	WHILE !(cAliasAx2)->(Eof())

		aadd(aItens, WSClassNew("StPgtoContrato"))
		aItens[len(aItens)]:DTPAGAMENTO := STOD((cAliasAx2)->E2_BAIXA)
		aItens[len(aItens)]:VALOR 	 	 := (cAliasAx2)->VLBAIXA

		(cAliasAx2)->(DbSkip())

	ENDDO

	(cAliasAx2)->(dbclosearea())

	oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:PAGAMENTOS	   := aItens
	oStTracker[len(oStTracker)]:CONTRATOS[len(oStTracker)]:TotalPagto	   := 0
	
Return( Nil )
