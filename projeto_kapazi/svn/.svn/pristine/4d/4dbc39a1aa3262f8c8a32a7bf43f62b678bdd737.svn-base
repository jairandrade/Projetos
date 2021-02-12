#include "protheus.ch
#include "topconn.ch"

#Define ENTER chr(13)+chr(10)

/*
    Retorna se a tes movimenta estoque
*/
User Function KFATR23T(cTes)
    Local aArea := GetArea()
    Local lRet  := .F.

    SF4->( DbSetOrder(1) )
    If SF4->( MsSeek(xFilial("SF4")+cTes))
        lRet := SF4->F4_ESTOQUE == "S"
    Endif

    RestArea(aArea)
Return lRet


User Function KFATR23P(cProduto)
    Local aArea := GetArea()
    Local lRet  := .F.

    SB1->( DbSetOrder(1))
    If SB1->( MsSeek(xFilial("SB1")+cProduto))
        If SB1->(FieldPos("B1_XOPFLU")) > 0 
            lRet := SB1->B1_XOPFLU == "S" 
        Endif
    Endif

    RestArea(aArea)
Return lRet

User Function KFATR23(nOpc)
/*
	Local lAtivado 	:= GetMv("KA_RESATV",,.F.)
    Local cLocalRese:= GetMv("KA_RESLOC",,"01")
	Local aArea 	:= GetArea()
	Local nX		:= 0
	Local nPItem	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"	})
	Local nPProduto	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"	})
	Local nPTes		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES"		})
	Local nPQtd		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"	})
	Local nPBlq		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_BLQ"		})
	Local cItem		:= ""
	Local cProduto	:= ""
	Local cTes		:= ""
	Local nQtdVen	:= 0
	Local nQtdEnt	:= 0
	Local cBlq		:= ""
	Local cReserva	:= ""
    Local nSaldo    := 0
    Local cOrcamento:= ""
    Local nOpcRes   := 0
    Local aReserva  := {}
    Local aRet      := {}
    Local lRet      := .F.
	
	If !lAtivado .and. !(nOpc >= 3 .and. nOpc <= 5)
		Return lRet
	Endif

	If !M->C5_TIPO == "N"
		Return lRet
	Endif

    If !isBlind()
        ProcRegua(0)
        IncProc()
        IncProc()
        ProcRegua(Len(aCols))
    Endif
    nOpcRes := nOpc - 2

    Begin Transaction
        For nX := 1 to Len(aCols)
            lDeletado   := aCols[nX][Len(aCols[nx])]
            cItem	    := aCols[nX][nPItem		]
            cProduto    := aCols[nX][nPProduto	]
            cTes	    := aCols[nX][nPTes		]
            nQtdVen 	:= aCols[nX][nPQtd		]
            cBlq	    := aCols[nX][nPBlq		]
            nQtdEnt 	:= 0
            cReserva    := ""
            cOrcamento  := ""
            if !isBlind() 
                IncProc("Item "+cItem+" "+AllTrim(cProduto))
            Endif

            if lDeletado
                loop
            Endif

            SC6->( DbSetOrder(1))
            If SC6->( MsSeek(xFilial("SC6")+M->C5_NUM+cItem))
                nQtdEnt := SC6->C6_QTDENT
                cReserva:= SC6->C6_RESERVA
                cOrcamento:= SC6->C6_NUMORC
                If JaTransferiu(SC6->C6_NUM,SC6->C6_ITEM)
                    Loop
                Endif
            Endif

            nSaldo      := nQtdVen - nQtdEnt
            
            // residuo eliminado ou sem saldo
            If cBlq == "R" .or. nSaldo <= 0
                Loop
            Endif

            // tes nao movimenta estoque
            If !U_KFATR23T(cTes) .and. nOpcRes <> 3
                Loop
            Endif

            // produgo nao gera ordem de producao
            If !U_KFATR23P(cProduto) .and. !Empty(AllTrim(cOrcamento)) .and. nOpcRes <> 3
                Loop
            Endif
            
            nPos := aScan(aReserva,{|x| AllTrim(x[1])+AllTrim(x[2]) == AllTrim(cProduto)+AllTrim(cLocalRese)})
            if nPos == 0
                aItem := {}
                aadd(aItem,cProduto     )
                aadd(aItem,cLocalRese   )
                aadd(aItem,nSaldo       )
                aadd(aReserva,aItem     )
            Else
                aReserva[nPos][3] += nSaldo
            Endif
        Next

        For nX := 1 to Len(aReserva)
            cProduto    := aReserva[nX][1]
            cLocalRese  := aReserva[nX][2]
            nSaldo      := aReserva[nX][3]
            aRet        := Reserva(nOpcRes,cReserva,M->C5_NUM,cProduto,cLocalRese,nSaldo)
            if !aRet[1]
                if !isblind()
                    MsgStop("Não foi possível realizar a reserva do produto "+AllTrim(cProduto)+" - "+cValToChar(nSaldo))
                    exit
                Endif
            Endif
        Next

        ExcluirReservasQueNaoEstaonoPedido(M->C5_NUM,aReserva)

    End Transaction

	RestArea(aArea)
*/
Return .T.

Static Function Reserva(nOpc,cReserva,cPedido,cProduto,cLocalRese,nSaldo,lProc)
    Local aArea     := GetArea()
    Local aOperacao := {}
    Local lRet      := .F.
    Local cRet      := ""
    Local aRet      := {lRet,cRet}
    Local cSolicit  := __cUserId
    Local nQtdRes   := 0

    Default cLocalRese  := GetMv("KA_RESLOC",,"01")
    Default cReserva    := ""
    Default nSaldo      := 0
    Default lProc       := .F.

    If lProc
        ProcRegua(0)
        IncProc()
        IncProc()
    Endif

    cSolicit  := __cUserId
    if Empty(AllTrim(cSolicit))
        cSolicit := "PORTAL"
    Endif

    cNumero     := Padr(cNumero     ,TamSx3("C0_NUM"    )[1])
    cProduto    := Padr(cProduto    ,TamSx3("C0_PRODUTO")[1])
    cLocalRese  := Padr(cLocalRese  ,TamSx3("C0_LOCAL"  )[1])

    aRetRes := QuantidadeReservada(cPedido,cLocalRese,cProduto)
    nQtdRes := aRetRes[1]
    cReserva:= aRetRes[2]

    if nOpc == 1 .and. nQtdRes > 0 
        if nQtdRes == nSaldo
            aRet[1] := .T.
            aRet[2] := aRetRes[2]
            Return aRet
        else
            nOpc    := 2
            cReserva:= aRetRes[2]
        Endif
    ElseIf nOpc == 2 .and. nQtdRes == 0
        nOpc := 1
    ElseIf nOpc == 3 .and. nQtdRes == 0
        Return aRet
    Endif

    aOperacao := {}
    aadd(aOperacao, nOpc            ) // Tipo da operação

    if nOpc == 1
        aadd(aOperacao, 'PD'            ) // Tipo da operação
        aadd(aOperacao, cPedido         ) // Numero do pedido
        aadd(aOperacao, cSolicit        ) // Usuário
        aadd(aOperacao, xFilial('SC6')  ) // Filial
    else
        SC0->(DbSetOrder(1))
        If SC0->(MsSeek(xFilial("SC0")+cReserva+cProduto+cLocalRese))
            aadd(aOperacao, SC0->C0_TIPO    ) // Tipo da operação
            aadd(aOperacao, SC0->C0_DOCRES  ) // Numero do pedido
            aadd(aOperacao, SC0->C0_SOLICIT ) // Usuário
            aadd(aOperacao, SC0->C0_FILRES  ) // Filial

            cProduto    := SC0->C0_PRODUTO
            cLocalRese  := SC0->C0_LOCAL

            if nOpc == 3
                nSaldo := SC0->C0_QUANT
            Endif
        Endif
    Endif

    if Len(aOperacao) == 5 .and. !Empty(AllTrim(cProduto)) .and. !Empty(AllTrim(cLocalRese)) .and. nSaldo > 0
        if IsInCallStack("A410Inclui") .or. IsInCallStack("A410Altera")
            M->C5_XSITLIB := "00"
        Endif
        Begin Transaction
            lRet := a430Reserv(aOperacao, cReserva, cProduto, cLocalRese, nSaldo,{'','','',''},,,)
        End Transaction
    Endif

    aRet[1] := lRet
    aRet[2] := cRet

    RestArea(aArea)
Return aRet

User Function KFATR23Z()
    Local	lEnv    := StaticCall(KAP_WF03,environmentActions,1,"04","01",,,"SIGAFAT",{"SB1"})
    Local   cTes    := "501"
    Local   cProduto:= "01990101       "
    Local   cPedido := "SEL305"
    Local   cLocal  := "01"
    Local   lRet    := .T.
    Local   nQtdVen := 6
    Local   lMovEst := .f.
    Local   lOP     := .f.
    Local   cReserva:= "003152"
    Local   aRet    := {lRet,cReserva}


    lMovEst := U_KFATR23T(cTes)
    lOP     := U_KFATR23P(cProduto)

    Begin Transaction
        // cria a reserva
        aRet := Reserva(1,cReserva,cPedido,cProduto,cLocal,nQtdVen)
        lRet := aRet[1]
        cReserva := aRet[2]

        // se criou a reserva
        if lRet .and. !Empty(AllTrim(cReserva))
            // altera reserva
            nQtdVen := 9
            aRet := Reserva(2,cReserva,cPedido,cProduto,cLocal,nQtdVen)
            // excluiu
            if lRet
                lRet := .T.
            Endif
        Endif
        
        // tentar reservar mais que o saldo
        if lRet .and. !Empty(AllTrim(cReserva))
            // altera reserva
            nQtdVen := 4500
            aRet := Reserva(2,cReserva,cPedido,cProduto,cLocal,nQtdVen)
            // excluiu
            if lRet
                lRet := .T.
            Endif
        Endif

        // se criou a reserva
        if lRet .and. !Empty(AllTrim(cReserva))
            // exclui a reserva
            aRet := Reserva(3,cReserva,cPedido,cProduto,cLocal,nQtdVen)
            // excluiu
            if lRet
                lRet := .T.
            Endif
        Endif
    End Transaction

	IF lEnv
		StaticCall(KAP_WF03,environmentActions,2)
	Endif
      
Return

Static Function QuantidadeReservada(cPedido,cLocal,cProduto)
    Local aArea     := GetArea()
    Local cQuery    := ""
    Local cTemp     := GetNextAlias() 
    Local aRet      := {0,""}

    cQuery += "SELECT "+ENTER
    cQuery += " C0_NUM "+ENTER
    cQuery += " ,ISNULL(SUM(C0_QUANT),0) QUANT "+ENTER
    cQuery += "FROM "+RetSqlName("SC0")+" "+ENTER
    cQuery += " "+ENTER
    cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER
    cQuery += "AND C0_FILIAL = '"+xFilial("SC0")    +"' "+ENTER
    cQuery += "AND C0_DOCRES = '"+cPedido           +"' "+ENTER
    cQuery += "AND C0_TIPO   = 'PD' "+ENTER
    cQuery += "AND C0_LOCAL  = '"+cLocal            +"' "+ENTER
    cQuery += "AND C0_PRODUTO= '"+cProduto          +"' "+ENTER
    cQuery += " "+ENTER
    cQuery += " GROUP BY C0_NUM "+ENTER

    If Select(cTemp) > 0
        (cTemp)->(DbCloseArea())
    Endif

    TcQuery cQuery New Alias (cTemp)
    If !(cTemp)->(EOF())
        aRet[1] := (cTemp)->QUANT
        aRet[2] := (cTemp)->C0_NUM
    Endif

    If Select(cTemp) > 0
        (cTemp)->(DbCloseArea())
    Endif

    RestArea(aArea)
Return aRet

Static Function ExcluirReservasQueNaoEstaonoPedido(cPedido,aReserva) 
    Local aArea     := GetArea()
    Local cTemp     := GetNextAlias()
    Local cQuery    := ""
    Local cProduto  := ""
    Local cLocal    := ""
    Local cReserva  := ""

    cQuery += "SELECT DISTINCT "+ENTER
    cQuery += "    C0_NUM "+ENTER
    cQuery += "    ,C0_PRODUTO "+ENTER
    cQuery += "    ,C0_LOCAL "+ENTER
    cQuery += "FROM "+RetSqlName("SC0")+" "+ENTER
    cQuery += " "+ENTER
    cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER
    cQuery += "AND C0_DOCRES = '"+cPedido+"' "+ENTER
    cQuery += " "+ENTER
    cQuery += "ORDER BY C0_PRODUTO "+ENTER

    If Select(cTemp) > 0
        (cTemp)->( DbCloseArea())
    Endif

    TcQuery cQuery New Alias (cTemp)

    While !(cTemp)->(EOF())
        cReserva:= (cTemp)->C0_NUM
        cProduto:= (cTemp)->C0_PRODUTO
        cLocal  := (cTemp)->C0_LOCAL
        nPos    := aScan(aReserva,{|x| AllTrim(x[1])+AllTrim(x[2]) == AllTrim(cProduto)+AllTrim(cLocal)})

        if nPos == 0
            Reserva(3,cReserva,cPedido,cProduto,cLocal)  
        Endif
        (cTemp)->(DbSkip())
    Enddo

    If Select(cTemp) > 0
        (cTemp)->( DbCloseArea())
    Endif

    RestArea(aArea)
Return 


User function KFATR23S()
    Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
    Local cProduto  := IIF(nPProduto > 0,aCols[Len(aCols)][nPProduto],"")
    Local cLocal    := GetMv("KA_RESLOC",,"01")
    Local nSaldo    := 0

    if !Empty(AllTrim(cProduto)) .and. !Empty(Alltrim(cLocal))
        nSaldo := SaldoProduto(cProduto,cLocal)
    Endif

Return nSaldo

Static Function SaldoProduto(cProduto,cLocal)
    Local aArea := GetArea()
    Local nRet  := 0

    SB2->(DbSetOrder(1))
    If SB2->(MsSeek(xFilial("SB2")+cProduto+cLocal))
        nRet := SaldoSB2(,,,,,"SB2")
    Endif

    RestArea(aArea)
Return nRet

Static Function JaTransferiu(cPedido,cItem,cProduto)
    Local aArea := GetArea()
    Local cQuery:= ""
    Local cTemp := GetNextAlias()

    Default cItem    := ""
    Default cProduto := ""

    cQuery += "SELECT COUNT(*) CONTA "+ENTER 
    cQuery += "FROM "+RetSqlName("SD3")+"  "+ENTER
    cQuery += "WHERE D_E_L_E_T_<>'*'  "+ENTER
    cQuery += "AND D3_FILIAL='"+xFilial("SD3")+"' "+ENTER 
    cQuery += "AND D3_ESTORNO<>'S'  "+ENTER
    cQuery += "AND SUBSTRING(D3_OBSERVA,1,13) = 'KFATR17'+RTRIM('"+cPedido+"') "+ENTER
    if !Empty(AllTrim(cItem))
        cQuery += "AND SUBSTRING(D3_OBSERVA,14,16) LIKE '%'+RTRIM('"+cItem+"')+'%' "+ENTER
    Endif
    if !Empty(AllTrim(cProduto))
        cQuery += "AND D3_COD = '"+cProduto+"' "+ENTER
    Endif

    If Select(cTemp) > 0
        (cTemp)->( DbCloseArea() )
    Endif

    TcQuery cQuery New Alias (cTemp)

    lRet := (cTemp)->CONTA > 0

    If Select(cTemp) > 0
        (cTemp)->( DbCloseArea() )
    Endif

    RestArea(aArea)
Return lRet

User Function KFATR23R(cAlias,nRecno,nOpc)
    Local lRet  := .T.

    While lRet
        lRet := !TelaReserva(cAlias,nRecno,nOpc)
    Enddo

Return

Static Function TelaReserva(cAlias,nRecno,nOpc)
    Local aArea     := GetArea()
    Local cPed      := SC5->C5_NUM 
    Local _cSelect  := ""
    Local _cFrom    := ""
    Local _cTitulo  := "Reservas do pedido"
    Local _cCampos  := ""
    Local lHasMark  := .F.
    Local aDados    := nil
    Local _aCampos  := {}
    Local cLDblClick:= "{|| U_KFATR23C(oLbxObj,aLbxCols,oDlgAux) }"
    Local lMax      := .T.
    Local _lHasOk   := .F.
    Local aRet      := {}

    Private lR23RSai:= .F.

    aadd(_aCampos,CampoCabecalho("C6_NUM"       ))
    aadd(_aCampos,CampoCabecalho("C6_PRODUTO"   ))
    aadd(_aCampos,CampoCabecalho("B1_DESC"      ))
    aadd(_aCampos,CampoCabecalho("C6_QTDVEN"    ,"Qtd. Pedido"     ))
    aadd(_aCampos,CampoCabecalho("C0_QUANT"     ,"Qtd. Reservada"  ))

	_cSelect += "SELECT  "+ENTER
	_cSelect += "	C6_NUM "+ENTER
	_cSelect += "	,C6_PRODUTO "+ENTER
	_cSelect += "	,B1_DESC "+ENTER
	_cSelect += "	,SUM(C6_QTDVEN - C6_QTDENT) C6_QTDVEN "+ENTER
	_cSelect += "	,ISNULL((	SELECT SUM(C0_QUANT)  "+ENTER
	_cSelect += "				FROM "+RetSqlName("SC0")+"  "+ENTER
	_cSelect += "				WHERE  "+ENTER
	_cSelect += "					D_E_L_E_T_<>'*' "+ENTER
	_cSelect += "					AND C0_FILIAL  = C6_FILIAL "+ENTER
	_cSelect += " 					AND C0_TIPO    = 'PD' "+ENTER
	_cSelect += "					AND C0_DOCRES  = C6_NUM "+ENTER
	_cSelect += "					AND C0_PRODUTO = C6_PRODUTO) "+ENTER
	_cSelect += "			,0) C0_QUANT "+ENTER
	_cFrom += "FROM "+RetSqlName("SC6")+" SC6 "+ENTER
	_cFrom += "	INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_<>'*' "+ENTER
	_cFrom += "		AND B1_FILIAL = '"+xFilial("SB1")+"' "+ENTER
	_cFrom += "		AND B1_COD = C6_PRODUTO "+ENTER
	_cFrom += "	INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.D_E_L_E_T_<>'*' "+ENTER
	_cFrom += "		AND F4_FILIAL  = '"+xFilial("SF4")+"' "+ENTER
	_cFrom += "		AND F4_CODIGO  = C6_TES "+ENTER
	_cFrom += "		AND F4_ESTOQUE = 'S' "+ENTER
	_cFrom += "	  "+ENTER
	_cFrom += "WHERE  "+ENTER
	_cFrom += "	SC6.D_E_L_E_T_<>'*' "+ENTER
	_cFrom += "	AND C6_FILIAL='"+xFilial("SC6")+"' "+ENTER
	_cFrom += "	AND C6_NUM='"+cPed+"' "+ENTER
	_cFrom += "	AND C6_BLQ<>'R' "+ENTER
	_cFrom += "	AND C6_QTDVEN > C6_QTDENT "+ENTER
	_cFrom += " "+ENTER
	_cFrom += "GROUP BY  "+ENTER
	_cFrom += "	C6_FILIAL "+ENTER
	_cFrom += "	,C6_NUM "+ENTER
	_cFrom += "	,C6_PRODUTO "+ENTER
	_cFrom += "	,B1_DESC "+ENTER
	_cFrom += " "+ENTER
	_cFrom += "ORDER BY  "+ENTER
	_cFrom += "	1 DESC "+ENTER
	_cFrom += "	,2 "+ENTER

    aDados  := StaticCall(LISTBOX,QueryDados,_cSelect+_cFrom,_aCampos)

    aRet    := StaticCall(LISTBOX,dialogListBox,_cTitulo,_cCampos,"","",lHasMark,aDados,_aCampos,cLDblClick,lMax,_lHasOk)

    lR23RSai := !Empty(aRet)

    RestArea(aArea)
Return lR23RSai

User function KFATR23C(oLbx,aDados,oDlgAux)
    Local aArea     := GetArea()
    Local aHead     := olbx:aHeaders
    Local nAt       := olbx:nAt
    Local nPProduto := aScan(aHead,"Produto" )
    Local nPRes     := aScan(aHead,"Qtd. Reservada" )
    Local nPQtd     := aScan(aHead,"Qtd. Pedido"    )
    Local cProduto  := AllTrim(aDados[nAt][nPProduto])
    Local nQtdRes   := aDados[nAt][nPRes]
    Local nQtdPed   := aDados[nAt][nPQtd]
    Local aRet      := {}

    if JaTransferiu(SC5->C5_NUM,"",cProduto)
        MsgInfo("O produto já possui separação para faturamento e não podem haver alterções de reserva.")
    Else
        If nQtdRes == nQtdPed .and. MsgYesNo("O Produto "+cProduto+" ESTÁ com todas as reservas realiadas, deseja EXCLUIR As reservas para o produto?")
            Processa({|| aRet := Reserva(3,,SC5->C5_NUM,cProduto,,       ,.T.) }, "Excluindo Reservas...","Aguarde...")
        Endif
            
        If nQtdRes <> nQtdPed .and. MsgYesNo("O Produto "+cProduto+" NÃO ESTÁ Com todas as reservas realiadas, deseja GERAR as reservas para o produto?")
            Processa({|| aRet := Reserva(2,,SC5->C5_NUM,cProduto,,nQtdPed,.T.) },"Gerando Reservas...","Aguarde...")
        Endif

        if !Empty(aRet)
            if aRet[1]
                MsgInfo("Operação realizada com sucesso.")
                oDlgAux:End()
            else
                MsgInfo("Operação NÃO realizada.")
            Endif
        Endif
    Endif

    RestArea(aArea)
Return


Static Function CampoCabecalho(cCampo,cTitulo,nTam)
Return StaticCall(LISTBOX,CampoCabecalho,cCampo,cTitulo,nTam)
