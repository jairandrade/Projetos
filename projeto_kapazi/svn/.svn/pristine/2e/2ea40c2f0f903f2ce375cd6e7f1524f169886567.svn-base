#include "protheus.ch"
#include "topconn.ch"

#Define ENTER char(13)+char(10) 

User Function KESTR14A()
    Local	lEnv    := StaticCall(KAP_WF03,environmentActions,1,"04","01",,,"SIGAEST",{"SB1"})

    U_KESTR14()

	IF lEnv
		StaticCall(KAP_WF03,environmentActions,2)
	Endif

Return


User Function KESTR14()
    Local aArea := GetArea()
    Local aPergs:= GetPergs()
    Local aRet  := {}
    Local lCente:= .T.
    Local cAno  := ""
    Local cMes  := ""
    Local lSimul:= .T.

    If !ParamBox(aPergs,"Rateio de centro de custo Volante", @aRet,,,lCente,,,,,.F.,.F.)
        Return 
    Endif

    cAno    := aRet[1]
    cMes    := aRet[2]
    if ValType(aRet[3])=="N"
        lSimul  := aRet[3] == 1
    elseif ValType(aRet[3])=="C"
        lSimul  := aRet[3] == "Sim"
    Endif

    If !IsBlind()
        Processa({|| IniProc(cAno,cMes,lSimul)},"Aguarde...","Processando...")
    Else
        IniProc(cAno,cMes,lSimul)
    Endif

    RestArea(aArea)
Return 


Static Function IniProc(cAno,cMes,lSimul)
    Local   aArea   := GetArea()
    Local   dDtIni  := FirstDate(StoD(cAno+cMes+"02"))
    Local   dDtFim  := LastDate(Stod(cAno+cMes+"02"))
    Local   dBaseBkp:= dDataBase
    Local   cVolant := StaticCall(M521CART,TGetMv,"  ","KA_CCVOLAN","C","430010027","KPESTR14 - Centro de custo volante para rateio de mao de obra")
    Local   aSaldo  := GetCCSaldo(dDtIni,dDtFim,cVolant)
    Local   nHrTotal:= DEC_CREATE(Str(GetValue(dDtIni,dDtFim,.T.)),18,4)
    Local   aCCs    := GetValue(dDtIni,dDtFim)
    local 	nFator 	:= DEC_CREATE("0",18,4)
    Local   nCC     := DEC_CREATE("0",18,4)
    Local   nDecim  := TamSx3("CT2_VALOR")[2]
    Local   nX      := 0
    Local   nY      := 0
    Local   nZ      := 0
    Local   aItem   := {}
    Local   aMov    := {}
    Local   cTexto  := ""
    Local   nTotCC  := DEC_CREATE("0",18,4)
    Local   nVlr    := 0
    Local   nValor  := 0

    If Empty(aSaldo)
        MsgStop("O centro de custo volante não tem saldo a ser distribuido.")
        Return
    Endif

    If !IsBlind()
        ProcRegua(0)
        IncProc()
        IncProc()
    Endif

    dDataBase := dDtFim

    cTexto += "Conta Debito;"
    cTexto += "Conta Credito;"
    cTexto += "Conta Descrição;"
    cTexto += "CC Debito;"
    cTexto += "CC Credito;"
    cTexto += "CC Descrição;"
    cTexto += "Valor Lançamento;"
    cTexto += "Total CC Volante;"
    cTexto += "Total Hora CC;"
    cTexto += "Fator;"+ENTER

    For nY := 1 to Len(aSaldo)
        
        nSaldo := aSaldo[nY][2]

        nTotCC := DEC_CREATE(Str(nSaldo),18,4)
        for nX := 1 to Len(aCCs)
            nCC    := DEC_CREATE(Str(aCCs[nX][2]),18,4)
            
            nFator := DEC_DIV(nCC , nHrTotal)
            nValor := DEC_ROUND(DEC_MUL(nTotCC , nFator),nDecim)
            nVlr   := Round(Val(AllTrim(Str(nValor))),nDecim)

            if nVlr <> 0
                aItem := {}
                aadd(aItem,aSaldo[nY][1]    ) // 1 conta contabil debito
                aadd(aItem,aSaldo[nY][1]    ) // 2 conta contabil credito
                aadd(aItem,aSaldo[nY][3]    ) // 3 descricao conta

                If nVlr < 0
                    nVlr := nVlr * -1
                    aadd(aItem,cVolant          ) // 4 centro de custo debito 
                    aadd(aItem,aCCs[nX][1]      ) // 5 centro de custo credito
                Else
                    aadd(aItem,aCCs[nX][1]      ) // 4 centro de custo debito
                    aadd(aItem,cVolant          ) // 5 centro de custo credito
                Endif

                aadd(aItem,aCCs[nX][3]      ) // 6 centro de custo descricao
                aadd(aItem,nVlr             ) // 7 valor 
                aadd(aItem,nTotCC           ) // 8 total do volante
                aadd(aItem,aCCs[nX][2]      ) // 9 total de hora do cc
                aadd(aItem,nFator           ) // 10 fator 
                aadd(aMov,aItem)
            Endif

            For nZ :=  1 to Len(aItem)
                cTexto += AllTrim(cValToChar(aItem[nZ]))+";"
            Next

            cTexto += ENTER
        Next
    Next

    If !Empty(aMov) .and. !lSimul
        GeraLcto(aMov)
    Endif

    MemoWrite("\logs\kestr14_lacamento.csv",StrTran(cTexto,".",","))
    MemoWrite(GetTempPath()+"kestr14_lacamento.csv",StrTran(cTexto,".",","))
    
    shellExecute("Open", "kestr14_lacamento.csv", "", GetTempPath(), 1 )

    dDataBase := dBaseBkp

    RestArea(aArea)
Return


Static Function GetValue(dDtIni,dDtFim,lTotal)
    Local aArea   := GetArea()
    Local xRet  := 0
    Local cQuery:= ""
    Local cTemp := GetNextAlias()
    Local aItem := {}
    Local aRet  := {}

    Default lTotal := .F.

    cQuery += "SELECT "+ENTER
    if !lTotal
        cQuery += "	CC,CTT_DESC, "+ENTER
    Endif
	cQuery += "	SUM(D3_QUANT) QTD_HORAS "+ENTER
	cQuery += " "+ENTER
	cQuery += "FROM "+RetSqlName("SD3")+" SD3 "+ENTER
	cQuery += "	INNER JOIN (	SELECT DISTINCT  "+ENTER
	cQuery += "						D3_OP OP "+ENTER
	cQuery += "						,D3_GRUPO GRUPO "+ENTER
	cQuery += "						,D3_CC CC "+ENTER
	cQuery += "						,CTT_DESC01 CTT_DESC "+ENTER
	cQuery += "					FROM "+RetSqlName("SD3")+" SD3 "+ENTER
	cQuery += "						INNER JOIN "+RetSqlName("SBM")+" SBM ON SBM.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "							AND BM_FILIAL = '"+xFilial("SBM")+"' "+ENTER
    cQuery += "							AND BM_GRUPO = D3_GRUPO "+ENTER
	cQuery += "							AND BM_K_RVOLA = 'S' "+ENTER
	cQuery += " "+ENTER
    cQuery += "						LEFT OUTER JOIN "+RetSqlName("CTT")+" CTT ON CTT.D_E_L_E_T_<>'*' "+ENTER
    cQuery += "						    AND CTT_FILIAL = '"+xFilial("CTT")+"' "+ENTER
    cQuery += "						    AND CTT_CUSTO = D3_CC "+ENTER
	cQuery += " "+ENTER
	cQuery += "					WHERE  "+ENTER
	cQuery += "							SD3.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "						AND D3_FILIAL   = '"+xFilial("SD3") +"' "+ENTER
	cQuery += "						AND D3_EMISSAO >= '"+DtoS(dDtIni)   +"' "+ENTER
	cQuery += "						AND D3_EMISSAO <= '"+Dtos(dDtFim)   +"' "+ENTER
	cQuery += "						AND D3_CF = 'PR0' "+ENTER
	cQuery += "	                    AND D3_CC <> '' "+ENTER
	cQuery += "						 "+ENTER
	cQuery += "				) TAB ON D3_OP = OP "+ENTER
	cQuery += "WHERE  "+ENTER
	cQuery += "		D_E_L_E_T_<>'*' "+ENTER
	cQuery += "	AND D3_FILIAL   = '"+xFilial("SD3") +"' "+ENTER
	cQuery += "	AND D3_EMISSAO >= '"+DtoS(dDtIni)   +"' "+ENTER
	cQuery += "	AND D3_EMISSAO <= '"+Dtos(dDtFim)   +"' "+ENTER
    cQuery += "	AND SUBSTRING(D3_COD,1,3)='MOD' "+ENTER
    cQuery += " "+ENTER
    If !lTotal
        cQuery += "GROUP BY "+ENTER
        cQuery += "	CC,CTT_DESC "+ENTER
    Endif
	cQuery += "	 "+ENTER
    cQuery += "ORDER BY 1 "+ENTER
    
    If lTotal
        MemoWrite("c:\temp\kestr14_total_horas.sql",cQuery)
    Else
        MemoWrite("c:\temp\kestr14_horas_cc.sql",cQuery)
    Endif

    If Select(cTemp) > 0
        (cTemp)->(DbCloseArea())
    Endif

    TcQuery cQuery New Alias (cTemp)

    If !(cTemp)->( EOF() )
        If lTotal
            xRet := (cTemp)->QTD_HORAS
        Else
            While !(cTemp)->(EOF())
                aItem := {}
                aadd(aItem,(cTemp)->CC          )
                aadd(aItem,(cTemp)->QTD_HORAS   )
                aadd(aItem,(cTemp)->CTT_DESC    )
                aadd(aRet,aItem)
                (cTemp)->(DbSkip())
            Enddo
            xRet := aRet
        Endif
    Endif

    If Select(cTemp) > 0
        (cTemp)->(DbCloseArea())
    Endif

    RestArea(aArea)
Return xRet

Static Function GetCCSaldo(dDtIni,dDtFim,cCC)
    Local   aArea   := GetArea()
    Local   cQuery  := ""
    Local   cTemp   := GetNextAlias()
    Local   _cEmp   := cEmpAnt
    Local   aItem   := {}
    Local   aRet    := {}

    _cEmp   := cEmpAnt

	cQuery += "SELECT  "+ENTER
	cQuery += "    CT1_CONTA   "+ENTER
	cQuery += "    ,CT1_DESC01   "+ENTER
	cQuery += "    ,SUM(CT2_VALOR) CT2_VALOR   "+ENTER
	cQuery += "  "+ENTER
	cQuery += "FROM V_LANCAMENTOS_CONTABEIS_"+_cEmp+"  "+ENTER
	cQuery += "  "+ENTER
	cQuery += "WHERE   "+ENTER
	cQuery += "    CT2_FILIAL    = '"+xFilial("CT2")    +"'  "+ENTER
	cQuery += "    AND CT2_DATA >= '"+DtoS(dDtIni)      +"'  "+ENTER
	cQuery += "    AND CT2_DATA <= '"+DtoS(dDtFim)      +"'  "+ENTER
	cQuery += "    AND CT2_CCUSTO= '"+cCC               +"'  "+ENTER
	cQuery += "    AND UPPER(CT2_HIST) <> UPPER('Rateio Centro de custo volante') "+ENTER
	cQuery += "    AND CT2_ROTINA<>'KESTR14' "+ENTER
	cQuery += "    AND CT1_GRUPO <> '' "+ENTER
	cQuery += "     "+ENTER
	cQuery += "GROUP BY   "+ENTER
	cQuery += "	CT1_CONTA  "+ENTER
	cQuery += "	,CT1_DESC01   "+ENTER
	cQuery += "	 "+ENTER
	cQuery += "HAVING SUM(CT2_VALOR) <> 0 "+ENTER
	cQuery += "	 "+ENTER
	cQuery += "ORDER BY 2 "+ENTER
	cQuery += " "+ENTER

    MemoWrite("c:\temp\kestr14_saldovolante.sql",cQuery)

    If Select(cTemp) > 0
        (cTemp)->(DbCloseArea())
    Endif

    TcQuery cQuery New Alias (cTemp)

    While !(cTemp)->(EOF())
        aItem := {}
        aadd(aItem,AllTrim((cTemp)->CT1_CONTA))
        aadd(aItem,(cTemp)->CT2_VALOR   )
        aadd(aItem,(cTemp)->CT1_DESC01  )
        aadd(aRet,aItem)
        (cTemp)->(DbSkip())
    Enddo

    If Select(cTemp) > 0
        (cTemp)->(DbCloseArea())
    Endif

    RestArea(aArea)
Return aRet

Static Function GeraLcto(aDados)
    Local   nX          := 0
    Local   aArea       := GetArea()
    Local   nDoc        := 1
    Local   lRet        := .T.
    Local   aCab        := {}
    Local   aItens      := {}
    Local   aItem       := {}
    Local   dDataLanc   := dDataBase
    // conta debito
    Local   nPCDeb      := 1
    // conta credito
    Local   nPCCre      := 2
    // centro de custo debito
    Local   nPCCDeb     := 4
    // centro de custo credito
    Local   nPCCCred    := 5
    // valor
    Local   nPValor     := 7
    Local   cSbLote     := GetSubLote(dDataLanc)

    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .T.
    Private CTF_LOCK    := 0
    Private lSubLote    := .T.

    lMsHelpAuto := .T.
    CTF_LOCK    := 0
    lSubLote    := .T.

    dDataLanc   := dDataBase

    If !IsBlind()
        ProcRegua(0)
        IncProc("Gerando lançamentos")
    Endif

    If !Empty(aDados)
        aCab := {}
        aAdd(aCab,{'DDATALANC'  ,dDataLanc      ,NIL} )
        aAdd(aCab,{'CLOTE'      ,'008890'       ,NIL} )
        aAdd(aCab,{'CSUBLOTE'   ,cSbLote        ,NIL} )
        aAdd(aCab,{'CDOC'       ,StrZero(nDoc,6),NIL} )
        aAdd(aCab,{'CPADRAO'    ,''             ,NIL} )
        aAdd(aCab,{'NTOTINF'    ,0              ,NIL} )
        aAdd(aCab,{'NTOTINFLOT' ,0              ,NIL} )

        For nX := 1 to Len(aDados)
            aItem := {}
            aadd(aItem,{"CT2_FILIAL",xFilial("CT2")                            ,Nil})
            aadd(aItem,{"CT2_LINHA" ,StrZero(nX,3)                             ,Nil})
            aadd(aItem,{"CT2_MOEDLC","01"                                      ,Nil})
            aadd(aItem,{"CT2_DC"    ,"3"                                       ,Nil})
            aadd(aItem,{"CT2_DEBITO",aDados[nX][nPCDeb]                        ,Nil})
            aadd(aItem,{"CT2_CREDIT",aDados[nX][nPCCre]                        ,Nil})
            aadd(aItem,{"CT2_VALOR" ,aDados[nX][nPValor]                       ,Nil})
            aadd(aItem,{"CT2_ROTINA","KESTR14"                                 ,Nil})
            aadd(aItem,{"CT2_HP"    ,""                                        ,Nil})
            aadd(aItem,{"CT2_HIST"  ,"Rateio Centro de custo volante KESTR14"  ,Nil})
            aadd(aItem,{"CT2_CCD"   ,aDados[nX][nPCCDeb]                       ,Nil})
            aadd(aItem,{"CT2_CCC"   ,aDados[nX][nPCCCred]                      ,Nil})
            aadd(aItens,aItem)
        Next

        If !Empty(aCab) .and. !Empty(aItens)
            Begin Transaction
                MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab ,aItens, 3)
                If lMsErroAuto
                    lRet := .F.
                    DisarmTransactions()
                    MostraErro()
                Endif
            End Transaction
        Endif
    Else
        lRet := .F.
    Endif
    
    RestArea(aArea)
Return lRet


Static Function GetPergs()
    Local aRet  := {}
    Local aItem := {}
    Local cAno  := cValToChar(Year2Str(Date()))
    Local cMes  := cValToChar(Month2Str(MonthSub(Date(),1)))

    aItem := {}
    aadd(aItem,1                        ) // 1 Tipo
    aadd(aItem,"Ano"                    ) // 2 Descrição
    aadd(aItem,cAno                     ) // 3 String contendo o inicializador do campo
    aadd(aItem,"@!"                     ) // 4 String contendo a Picture do campo
    aadd(aItem,nil                      ) // 5 String contendo a validação
    aadd(aItem,nil                      ) // 6 Consulta F3
    aadd(aItem,nil                      ) // 7 String contendo a validação When
    aadd(aItem,40                       ) // 8 Tamanho do MsGet
    aadd(aItem,.F.                      ) // 9 Flag .T./.F. Parâmetro Obrigatório ?
    aadd(aRet,aItem)

    aItem := {}
    aadd(aItem,1                        ) // 1 Tipo
    aadd(aItem,"Mes"                    ) // 2 Descrição
    aadd(aItem,cMes                     ) // 3 String contendo o inicializador do campo
    aadd(aItem,"@!"                     ) // 4 String contendo a Picture do campo
    aadd(aItem,nil                      ) // 5 String contendo a validação
    aadd(aItem,nil                      ) // 6 Consulta F3
    aadd(aItem,nil                      ) // 7 String contendo a validação When
    aadd(aItem,40                       ) // 8 Tamanho do MsGet
    aadd(aItem,.F.                      ) // 9 Flag .T./.F. Parâmetro Obrigatório ?
    aadd(aRet,aItem)

    aItem := {}
    aadd(aItem,2                        ) // 1 Tipo
    aadd(aItem,"Simulação?"             ) // 2 Descrição
    aadd(aItem,1                        ) // Numerico contendo a opcao inicial do combo
    aadd(aItem,{"Sim","Não"}            ) // Array contendo as opcoes do Combo
    aadd(aItem,40                       ) // Tamanho do Combo
    aadd(aItem,nil                      ) // Validacao
    aadd(aItem,.F.                      ) // Flag .T./.F. Parametro Obrigatorio ?
    aadd(aRet,aItem)

Return aRet

Static Function GetSubLote(dData)
    Local aArea := GetArea()
    Local cQuery:= ""
    Local cRet  := "000"
    Local cTemp := "TMPSBLOTE"
    Local nRet  := 0

	cQuery += "SELECT ISNULL(MAX(CT2_SBLOTE),'000') SBLOTE "+ENTER
	cQuery += "FROM "+RetSqlName("CT2")+" "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "AND CT2_FILIAL='"+xFilial("CT2")+"' "+ENTER
	cQuery += "AND CT2_LOTE='008890' "+ENTER
    cQuery += "AND CT2_DATA='"+DtoS(dData)+"' "+ENTER
    
    If Select(cTemp) > 0
        (cTemp)->( DbCloseArea())
    Endif
    
    TcQuery cQuery New Alias (cTemp)
    
    cRet := (cTemp)->SBLOTE
    nRet := Val(cRet)+1
    cRet := StrZero(nRet,3)

    If Select(cTemp) > 0
        (cTemp)->( DbCloseArea())
    Endif
    
    RestArea(aArea)
Return cRet
