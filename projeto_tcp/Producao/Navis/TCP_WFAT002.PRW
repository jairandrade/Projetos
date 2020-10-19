#include "protheus.ch"
#include "apwebsrv.ch"
#include "apwebex.ch"
#include "rwmake.ch"
#include "topconn.ch"

WsService WsFAT002 description "Integração Titulos Contas a Receber"

    // DECLARACAO DAS VARIVEIS GERAIS
    wsdata sEmpresa  	as string
    wsdata sFilial  	as string
    wsdata sPortador  	as string
    wsdata sAgencia  	as string
    wsdata sConta  		as string
    wsdata sCliente  	as string
    wsdata sVencimento  as string
    wsdata nValor  		as float
    wsdata sNumOS  		as string
    wsdata sOperacao	as string
    wsdata sPrefixo		as string
    wsdata sNumero		as string
    wsdata sNID			as string
    wsData Results   	as Array of wfRFAT002

    // DELCARACAO DO METODOS
    wsmethod ProcTitCR description "Realiza a integração de título a receber."

endwsservice

wsStruct wfRFAT002

    wsData NUMID		as String
    wsData CLIENTE 		as String
    wsData NUMERO 		as String
    wsData NUMEROBANCO	as String 	//E1_NUMBCO
    wsData STATUSRET   	as String
//	wsData NUMOS		as String

EndWsStruct


wsmethod ProcTitCR wsreceive sFilial, sPortador, sNumero, sAgencia, sCliente, sConta, sVencimento, nValor, sNumOS, sOperacao, sPrefixo, sNID wssend Results wsservice WsFAT002
    local lRet 		:= .F.
    Local nValAdd 	:= 0
    LOCAL cBco   := PadR(sPortador,(TamSX3("A6_COD")[1]))
    LOCAL cAgenc := PadR(sAgencia,(TamSX3("A6_AGENCIA")[1]))
    LOCAL cContaC:= PadR(sConta,(TamSX3("A6_NUMCON")[1]))
    LOCAL nTamCliente 	:= TamSX3("A1_COD")[1]
    LOCAL nTamLoja	 	:= TamSX3("A1_LOJA")[1]
    LOCAL cCodCli       := Subs(PadR(sCliente,(nTamCliente+nTamLoja)),1,nTamCliente)//Separa o código do cliente
    LOCAL cLojaCli      := Subs(PadR(sCliente,(nTamCliente+nTamLoja)),nTamCliente+1)//separa a loja do cliente
    PRIVATE nRecEE
    PRIVATE nRecE1 := 0

//    _cCodLog := U_A0601LOG('Enviar Titulo',SE1->E1_FILIAL,SE1->E1_NUM,SE1->E1_PREFIXO,SE1->E1_PORTADO,SE1->E1_AGEDEP,SE1->E1_CONTA,SE1->E1_CLIENTE+SE1->E1_LOJA,SE1->E1_VENCREA,SE1->E1_VALOR,SE1->E1_XNUMOS,SE1->E1_XIDNAVI,'I',_cTit,'')

    DbSelectArea("SA1")
    SA1->(DbSetOrder(1))
    SA1->(DbGoTop())
    If !SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojaCli))
        aAdd(Self:Results,WsClassNew("wfRFAT002"))
        Self:Results[1]:NUMID := sNID
        Self:Results[1]:CLIENTE := sCliente
        Self:Results[1]:NUMERO:= " "
        Self:Results[1]:NUMEROBANCO:= "CLIENTE INEXISTENTE"
        Self:Results[1]:STATUSRET  := "FALSE"
        Return .T.
    Else
        If SA1->A1_MSBLQL == '1'
            aAdd(Self:Results,WsClassNew("wfRFAT002"))
            Self:Results[1]:NUMID := sNID
            Self:Results[1]:CLIENTE := sCliente
            Self:Results[1]:NUMERO:= " "
            Self:Results[1]:NUMEROBANCO:= "CLIENTE BLOQUEADO"
            Self:Results[1]:STATUSRET  := "FALSE"
            Return .T.
        EndIf
    EndIF


    DBSelectArea("SA6")
    DBSelectArea("SEE")
    SEE->(DBSetOrder(01))//EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
    SA6->(DBSetOrder(01))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
    If !SA6->(MSSeek(xFilial("SA6")+cBco+cAgenc+cContaC)).Or.;
            !SEE->(MSSeek(xFilial("SEE")+SA6->(A6_COD+A6_AGENCIA+A6_NUMCON)))
        aAdd(Self:Results,WsClassNew("wfRFAT002"))
        Self:Results[1]:NUMID := sNumOS
        Self:Results[1]:CLIENTE := sCliente
        Self:Results[1]:NUMERO:= " "
        Self:Results[1]:NUMEROBANCO:= "BANCO OU PARAMETRO DE BANCO INFORMADO NAO EXISTE: "+cBco+cAgenc+cContaC
        Self:Results[1]:STATUSRET  := "FALSE"
        Return .T.
    EndIf
    nRecEE := SEE->(Recno())



    cFilAnt := sFilial
    //Valida se o titulo ja foi incluido pela integração, ocorre que por algum motivo manda o mesmo titulo mais de uma vez
    //em momento nao identificado no ESB.
    If Alltrim(sOperacao) == 'I'
        cQuery := "SELECT E1_NUM,E1_NUMBCO  FROM "+RetSQLName("SE1")
        cQuery += " WHERE "
        cQuery += " D_E_L_E_T_ != '*' "
        cQuery += " AND E1_FILIAL = '"+xFilial("SE1")+"'"
        cQuery += " AND E1_CLIENTE = '"+SA1->A1_COD+"'"
        cQuery += " AND E1_LOJA = '"+SA1->A1_LOJA+"'"
        cQuery += " AND E1_PREFIXO = '"+sPrefixo+"'"
        //cQuery += " AND E1_NUM = '"+PadR(sNumero,TamSX3("E1_NUM")[1])+"' AND E1_XIDNAVI = '"+sNID+"'"
        cQuery += " AND E1_XIDNAVI = '"+sNID+"' "
        If Select("TRBXNV") <> 0
            DBSelectArea("TRBXNV")
            DBCloseArea()
        EndIf
        TCQuery cQuery New Alias "TRBXNV"
        If !TRBXNV->(Eof())
            aAdd(Self:Results,WsClassNew("wfRFAT002"))
            Self:Results[1]:NUMID := sNID
            Self:Results[1]:CLIENTE := sCliente
            Self:Results[1]:NUMERO:= TRBXNV->E1_NUM
            Self:Results[1]:NUMEROBANCO:= TRBXNV->E1_NUMBCO
            Self:Results[1]:STATUSRET  := "TRUE"
//			U_WSGEN001("WsFAT002.ProcTitCR","OS: "+sNumOS+" Titulo ja incluido para o ID informado."+sNID)	                               
            U_WSGEN001("WsFAT002.ProcTitCR","TITULO: "+sPrefixo+TRBXNV->E1_NUM+" Cliente: "+sCliente+" OS: "+sNumOS+" OPERCAO: "+sOperacao)
            RETURN .T.
        EndIf
        If Select("TRBXNV") <> 0
            DBSelectArea("TRBXNV")
            DBCloseArea()
        EndIf
    EndIf

    If Empty(sVencimento) .OR. (!EMPTY(sVencimento) .AND. StoD(sVencimento) < DATE())
        aAdd(Self:Results,WsClassNew("wfRFAT002"))
        Self:Results[1]:NUMID := sNID
        Self:Results[1]:CLIENTE := sCliente
        Self:Results[1]:NUMERO:= " "
        Self:Results[1]:NUMEROBANCO:= "OS: "+sNumOS+" Titulo "+sNumero+"Vencimento Invalido "+sVencimento
        Self:Results[1]:STATUSRET  := "FALSE"
        U_WSGEN001("WsFAT002.ProcTitCR","OS: "+sNumOS+" Titulo "+sNumero+"Vencimento Invalido "+sVencimento)
        RETURN .T.
    EndIf
    If SToD(sVencimento)< (Date()-(365*3))
        aAdd(Self:Results,WsClassNew("wfRFAT002"))
        Self:Results[1]:NUMID := sNID
        Self:Results[1]:CLIENTE := sCliente
        Self:Results[1]:NUMERO:= " "
        Self:Results[1]:NUMEROBANCO:= "OS: "+sNumOS+" Titulo "+sNumero+"Vencimento Invalido "+sVencimento
        Self:Results[1]:STATUSRET  := "FALSE"
        U_WSGEN001("WsFAT002.ProcTitCR","OS: "+sNumOS+" Titulo "+sNumero+"Vencimento Invalido "+sVencimento)
        RETURN .T.
    EndIf
    Begin Transaction
        cQuery := " SELECT SE1.R_E_C_N_O_ RECSA1, E1_NUM "
        cQuery += " FROM "+RetSqlName('SE1')+" SE1 "
        cQuery += "	WHERE E1_FILIAL = '"+xFilial('SE1')+"' "
        cQuery += " AND E1_CLIENTE = '"+SA1->A1_COD+"'"
        cQuery += " AND E1_LOJA = '"+SA1->A1_LOJA+"'"
        cQuery += " AND E1_PREFIXO = '"+sPrefixo+"'"
        cQuery += " AND E1_NUM = '"+PadR(sNumero,TamSX3("E1_NUM")[1])+"' AND E1_XIDNAVI = '"+sNID+"'"
        cQuery += " AND D_E_L_E_T_ != '*' "
        TCQUERY cQuery NEW ALIAS "QRYE1"
        DbSelectArea("QRYE1")
        QRYE1->(DbGoTop())

        IF QRYE1->(EOF())
            If (sOperacao $ "A,E")//Valida se mandou operavao VALIDA para o titulo
                aAdd(Self:Results,WsClassNew("wfRFAT002"))
                Self:Results[1]:NUMID := sNID
                Self:Results[1]:CLIENTE := sCliente
                Self:Results[1]:NUMERO:= " "
                Self:Results[1]:NUMEROBANCO:= "OS: "+sNumOS+" Titulo "+sNumero+"Enviado Operacao Inválida Enviado "+sOperacao+" - Esperado: I"
                Self:Results[1]:STATUSRET  := "FALSE"
                U_WSGEN001("WsFAT002.ProcTitCR","OS: "+sNumOS+" Titulo "+sNumero+"Enviado Operacao Inválida Enviado "+sOperacao+" - Esperado: I")
            Else

                cRet := ProcSE1()
                aAdd(Self:Results,WsClassNew("wfRFAT002"))
                Self:Results[1]:NUMID := sNID
                Self:Results[1]:CLIENTE := sCliente
                If cRet == "TRUE"
                    Self:Results[1]:NUMERO:= SE1->E1_NUM
                    Self:Results[1]:NUMEROBANCO:= SE1->E1_NUMBCO
                Else
                    Self:Results[1]:NUMERO:= " "
                    Self:Results[1]:NUMEROBANCO:= "ERRO NA INTEGRAÇÃO. FAVOR AVALIAR OS DADOS"
                EndIf
                Self:Results[1]:STATUSRET  := cRet
            EndIf
        Else
            nRecE1:= QRYE1->RECSA1
            DBSelectArea("SE1")
            SE1->(DBSetOrder(01))
            SE1->(DBGoTo(nRecE1))
            If !(sOperacao $ "A,E")//Valida se mandou operavao invalida para o titulo
                aAdd(Self:Results,WsClassNew("wfRFAT002"))
                Self:Results[1]:NUMID := sNID
                Self:Results[1]:CLIENTE := sCliente
                Self:Results[1]:NUMERO:= QRYE1->E1_NUM
                Self:Results[1]:NUMEROBANCO:= "Titulo Já Cadastrado"
                Self:Results[1]:STATUSRET  := "FALSE"
                U_WSGEN001("WsFAT002.ProcTitCR","OS: "+sNumOS+" Titulo "+sNumero+"Enviado Operacao Inválida Enviado "+sOperacao+" - Esperado:A ou E.")
            Else
                cRet := ProcSE1()
                aAdd(Self:Results,WsClassNew("wfRFAT002"))
                Self:Results[1]:NUMID := sNID
                Self:Results[1]:CLIENTE := sCliente
                If cRet == "TRUE"
                    Self:Results[1]:NUMERO:= SE1->E1_NUM
                    Self:Results[1]:NUMEROBANCO:= SE1->E1_NUMBCO
                Else
                    Self:Results[1]:NUMERO:= " "
                    Self:Results[1]:NUMEROBANCO:= "ERRO NA INTEGRAÇÃO. FAVOR AVALIAR OS DADOS"
                EndIf

                Self:Results[1]:STATUSRET  := cRet
            EndIf
        EndIF
        QRYE1->(DbCloseArea())
    End Transaction

return .T.

Static Function ProcSE1()
    Local aSE1	 := {}
    Local cRet	 := ""
    Local cNum	 := ""
    LOCAL cNatureza := GetNewPar("TCP_NATISS","6027")//Natureza.
    Local _cXBORDER := ""
    //como é enviado varios titulos ao mesmo tempo e não temos como bloquear a tabela, realizado este sleep para reduzir volume de problemas
    nTempo := Randomize( 1, 13 )*1000
    Sleep( nTempo )

    cQueryN := " SELECT MAX(E1_NUM) AS NUM FROM "+RetSqlName('SE1')+" "
    cQueryN += "	WHERE E1_FILIAL = '"+xFilial('SE1')+"' AND E1_PREFIXO = '"+sPrefixo+"' AND D_E_L_E_T_ != '*' "
    TCQUERY cQueryN NEW ALIAS "QRYE1NUM"

    DbSelectArea("QRYE1NUM")
    QRYE1NUM->(DbGoTop())

    IF QRYE1NUM->(EOF())
        cNum := Strzero(1,Len(SE1->E1_NUM))
    ElseIf Empty(Alltrim(QRYE1NUM->NUM))
        cNum := Strzero(1,Len(SE1->E1_NUM))
    Else
        cNum := Soma1(QRYE1NUM->NUM)
    EndIf
    QRYE1NUM->(DbCloseArea())

    Do Case
    Case sOperacao == 'A'
        aAdd( aSe1, {"E1_PREFIXO", SE1->E1_PREFIXO        	, nil} )
        aAdd( aSe1, {"E1_NUM"    , SE1->E1_NUM	    		, nil} )
        aAdd( aSe1, {"E1_PARCELA", SE1->E1_PARCELA				, nil} )
        aAdd( aSe1, {"E1_TIPO"   , SE1->E1_TIPO          	, nil} )
        aAdd( aSe1, {"E1_CLIENTE", SE1->E1_CLIENTE		, nil} )
        aAdd( aSe1, {"E1_LOJA"   , SE1->E1_LOJA		, nil} )
        aAdd( aSe1, {"E1_VENCTO" , StoD(sVencimento) , nil} )
        aAdd( aSe1, {"E1_VENCREA" ,StoD(sVencimento), nil} )
        aAdd( aSe1, {"E1_VALOR"  , nValor  			, nil} )

    Case sOperacao == 'E'
        aAdd( aSe1, {"E1_PREFIXO", SE1->E1_PREFIXO        	, nil} )
        aAdd( aSe1, {"E1_NUM"    , SE1->E1_NUM	    		, nil} )
        aAdd( aSe1, {"E1_PARCELA", SE1->E1_PARCELA				, nil} )
        aAdd( aSe1, {"E1_TIPO"   , SE1->E1_TIPO          	, nil} )
        aAdd( aSe1, {"E1_CLIENTE", SE1->E1_CLIENTE		, nil} )
        aAdd( aSe1, {"E1_LOJA"   , SE1->E1_LOJA		, nil} )

    OtherWise

        aAdd( aSe1, {"E1_PREFIXO", sPrefixo        	, nil} )
        aAdd( aSe1, {"E1_NUM"    , cNum	    		, nil} )
        aAdd( aSe1, {"E1_PARCELA", ' '				, nil} )
        aAdd( aSe1, {"E1_TIPO"   , "NF "          	, nil} )
        aAdd( aSe1, {"E1_NATUREZ", "6027      "    	, nil} )
        aAdd( aSe1, {"E1_CLIENTE", SA1->A1_COD		, nil} )
        aAdd( aSe1, {"E1_LOJA"   , SA1->A1_LOJA		, nil} )
        aAdd( aSe1, {"E1_EMISSAO", Date()		, nil} )
        aAdd( aSe1, {"E1_VENCTO" , StoD(sVencimento), nil} )
        aAdd( aSe1, {"E1_VALOR"  , nValor  			, nil} )
        aAdd( aSe1, {"E1_HIST"   , 'IMP OS '+Alltrim(sNumOS)   , nil} )
        aAdd( aSe1, {"E1_XNUMOS" , sNumOS 	, nil} )
        aAdd( aSe1, {"E1_XIDNAVI", sNID 	, nil} )

    EndCase


    lMSErroAuto := .F.

    If sOperacao == 'I'
        nOpera := 3
    ElseIf sOperacao == 'A'
        nOpera := 4
    ElseIf sOperacao == 'E'
        nOpera := 5
    Else
        Return "FALSE"
    EndIf

    MSExecAuto( {|x,y| fina040(x,y)}, aSE1, nOpera)

    If ( lMSErroAuto )
        //mostraErro()
//			cLog := ''
//			aLog := GetAutoGRLog()
//			For n1 := 1 to len(aLog)
//				cLog += aLog[n1] +  CRLF
//			Next n1
        cTime := TIME()
        cNomeFile := dtos(dDatabase) + '_' + SUBSTR(cTime, 1, 2) + SUBSTR(cTime, 4, 2) + SUBSTR(cTime, 7, 2) + '_erroop.log'
//			"\SYSTEM\", cNomefile
        If (!IsBlind())
            _cTxtErro := MostraErro()
        Else
            _cTxtErro := MostraErro("/dirdoc", "error.log")
        EndIf

        DisarmTransaction()
        U_WSGEN001("WsFAT002.ProcTitCR","ERRO Operacao: "+sOperacao+" OS "+sNumOS+" ID "+sNID+" - CLIENTE "+sCliente+_cTxtErro)
        cRet := "FALSE"
    Else
        If sOperacao == 'I' .Or.sOperacao == 'A'

            DBSelectArea("SA1")
            SA1->(DBSetOrder(1))
            SA1->( dbSeek( xFilial("SA1") + SE1->E1_CLIENTE+SE1->E1_LOJA ) )

            //_cXBORDER := Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_XBORDER")

            If Empty(SE1->E1_NUMBCO) .AND. SA1->A1_XBORDER <> "N"
                SEE->(DBGoTo(nRecEE))//Forca o posicionamento caso, desposicione o EE
                RecLock("SEE",.F.)
                SEE->EE_FAXATU := Soma1(Alltrim(SEE->EE_FAXATU))
                SEE->( MsUnlock() )

                RecLock("SE1",.F.)
                SE1->E1_PORTADO:=  SEE->EE_CODIGO//Informacao do banco pode ser salva somente após gravar o título, ao contrato da erro de execauto.
                SE1->E1_AGEDEP :=  SEE->EE_AGENCIA
                SE1->E1_CONTA  :=  SEE->EE_CONTA
                SE1->E1_NUMBCO := StrZero(Val(SEE->EE_FAXATU),8)
                IF SA1->A1_EST != 'EX'
                    SE1->E1_G_STARE := '000'
                ENDIF
                SE1->(MsUnlock())

                if GetNewPar("TCP_INTBOL", .F.)
//					U_A0601('ROT',SE1->(Recno())) //CHAMADA PARA REGISTRO DO BOLETO NO BANCO ITAÚ.
                    STARTJOB("U_A0603", GetEnvServer(), .F., cEmpAnt, cFilAnt,SE1->(Recno()))
                endif
            EndIf
            U_WSGEN001("WsFAT002.ProcTitCR","TITULO: "+sPrefixo+SE1->E1_NUM+" Cliente: "+sCliente+" OS: "+sNumOS+" OPERCAO: "+sOperacao)
        Else
            U_WSGEN001("WsFAT002.ProcTitCR","EXCLUSAO TITULO: "+sPrefixo+cNum+" Cliente: "+sCliente+" OS: "+sNumOS)
        EndIf

        cRet := "TRUE"
    EndIf

Return cRet



