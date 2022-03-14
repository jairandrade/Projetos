#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"

#Define ENTER chr(13)+chr(10)

User Function KFATR21()
    Local aPergs    := GetPergs()
    Local aRet      := {}
    Local lCentered	:= .T.
    Local lOk       := .T.
    Local cReimprime:= StaticCall(M521CART,TGetMv,"  ","KA_PACKALT","C","000000/000118/000423","KFAFTR21 - Usuarios que podem reimprimir o packing list." )
    Local lAltParam := RetCodUsr() $ cReimprime
    Local oReport    
    Private lReimpress := .F.
    Private _nQtdPv := 5

    //Reipressao fica com 5
    //Impressao fica liberado

    lAltParam := .T.

    if lAltParam
        lOk := ParamBox(aPergs,"Impressão de Packing List", @aRet,,,lCentered,,,,,.F.,.F.)
        if lOk
            if ValType(aRet[7]) == "N" 
                If aRet[7] == 1
                    aRet[7] := "Sim"
                else
                    aRet[7] := "Nao"
                Endif
            Endif
        Endif
    Else
        lOk := MsgYesNo("Imprimir packing lists pendentes?")
        aadd(aRet,Date()-3      ) // 1 data inicio
        aadd(aRet,Date()        ) // 2 data fim
        aadd(aRet,Space(6)      ) // 3 cliente de
        aadd(aRet,Padl("",6,"Z")) // 4 cliente ate
        aadd(aRet,Space(6)      ) // 5 pedido de
        aadd(aRet,Padl("",6,"Z")) // 6 pedido ate
        aadd(aRet,"Nao"         ) // 7 reimperssao
    Endif

    if lOk
        If Alltrim(aRet[7]) == "Sim" //Reimpressao
            
            If (Val(aRet[6]) - Val(aRet[5])) > _nQtdPv
                MsgAlert("Não é permitido imprimir mais de 05 pedidos de uma única vez(reimpressão), utilize uma sequencia menor!!!")
                return
            EndIf

        EndIf 

        oReport:= ReportDef(aRet)
        oReport:PrintDialog()
    Endif

Return

Static Function GetPergs()
    Local aPergs    := {}
    Local aItem     := {}
    Local cCampo    := ""

    aItem := {}

    cCampo    := "C9_DATALIB" // 1
    aadd(aItem,1                        ) // 1 Tipo
    aadd(aItem,"Data Inicio"            ) // 2 Descrição
    aadd(aItem,Date()-30                 ) // 3 String contendo o inicializador do campo
    aadd(aItem,PesqPict("SC9",cCampo)   ) // 4 String contendo a Picture do campo
    aadd(aItem,nil                      ) // 5 String contendo a validação
    aadd(aItem,nil                      ) // 6 Consulta F3
    aadd(aItem,nil                      ) // 7 String contendo a validação When
    aadd(aItem,fieldSize(cCampo)        ) // 8 Tamanho do MsGet
    aadd(aItem,.T.                      ) // 9 Flag .T./.F. Parâmetro Obrigatório ?
    aadd(aPergs,aItem)
    
    cCampo    := "C9_DATALIB" // 2
    aItem := {}
    aadd(aItem,1                        ) // 1 Tipo
    aadd(aItem,"Data Fim"               ) // 2 Descrição
    aadd(aItem,Date()                   ) // 3 String contendo o inicializador do campo
    aadd(aItem,PesqPict("SC9",cCampo)   ) // 4 String contendo a Picture do campo
    aadd(aItem,nil                      ) // 5 String contendo a validação
    aadd(aItem,nil                      ) // 6 Consulta F3
    aadd(aItem,nil                      ) // 7 String contendo a validação When
    aadd(aItem,fieldSize(cCampo)        ) // 8 Tamanho do MsGet
    aadd(aItem,.T.                      ) // 9 Flag .T./.F. Parâmetro Obrigatório ?
    aadd(aPergs,aItem)

    cCampo    := "A1_COD" // 3 
    aItem := {}
    aadd(aItem,1                        ) // 1 Tipo
    aadd(aItem,"Cliente Inicial"        ) // 2 Descrição
    aadd(aItem,Space(TamSx3(cCampo)[1]) ) // 3 String contendo o inicializador do campo
    aadd(aItem,PesqPict("SC9",cCampo)   ) // 4 String contendo a Picture do campo
    aadd(aItem,nil                      ) // 5 String contendo a validação
    aadd(aItem,"SA1"                    ) // 6 Consulta F3
    aadd(aItem,nil                      ) // 7 String contendo a validação When
    aadd(aItem,fieldSize(cCampo)        ) // 8 Tamanho do MsGet
    aadd(aItem,.F.                      ) // 9 Flag .T./.F. Parâmetro Obrigatório ?
    aadd(aPergs,aItem)

    cCampo    := "A1_COD" // 4
    aItem := {}
    aadd(aItem,1                        ) // 1 Tipo
    aadd(aItem,"Cliente Final"          ) // 2 Descrição
    aadd(aItem,Padl("",TamSx3(cCampo)[1],"Z") ) // 3 String contendo o inicializador do campo
    aadd(aItem,PesqPict("SC9",cCampo)   ) // 4 String contendo a Picture do campo
    aadd(aItem,nil                      ) // 5 String contendo a validação
    aadd(aItem,"SA1"                    ) // 6 Consulta F3
    aadd(aItem,nil                      ) // 7 String contendo a validação When
    aadd(aItem,fieldSize(cCampo)        ) // 8 Tamanho do MsGet
    aadd(aItem,.F.                      ) // 9 Flag .T./.F. Parâmetro Obrigatório ?
    aadd(aPergs,aItem)

    cCampo    := "C5_NUM" // 5
    aItem := {}
    aadd(aItem,1                        ) // 1 Tipo
    aadd(aItem,"Pedido Inicial"         ) // 2 Descrição
    //aadd(aItem,"302848") // 3 String contendo o inicializador do campo
    aadd(aItem,Space(TamSx3(cCampo)[1]) ) // 3 String contendo o inicializador do campo
    aadd(aItem,PesqPict("SC9",cCampo)   ) // 4 String contendo a Picture do campo
    aadd(aItem,nil                      ) // 5 String contendo a validação
    aadd(aItem,"SC5"                    ) // 6 Consulta F3
    aadd(aItem,nil                      ) // 7 String contendo a validação When
    aadd(aItem,fieldSize(cCampo)        ) // 8 Tamanho do MsGet
    aadd(aItem,.F.                      ) // 9 Flag .T./.F. Parâmetro Obrigatório ?
    aadd(aPergs,aItem)

    cCampo    := "C5_NUM" // 6 
    aItem := {}
    aadd(aItem,1                        ) // 1 Tipo
    aadd(aItem,"Pedido Final"         ) // 2 Descrição
    //aadd(aItem,"302848") // 3 String contendo o inicializador do campo
    aadd(aItem,Padl("",TamSx3(cCampo)[1],"Z")) // 3 String contendo o inicializador do campo
    aadd(aItem,PesqPict("SC9",cCampo)   ) // 4 String contendo a Picture do campo
    aadd(aItem,nil                      ) // 5 String contendo a validação
    aadd(aItem,"SC5"                    ) // 6 Consulta F3
    aadd(aItem,nil                      ) // 7 String contendo a validação When
    aadd(aItem,fieldSize(cCampo)        ) // 8 Tamanho do MsGet
    aadd(aItem,.F.                      ) // 9 Flag .T./.F. Parâmetro Obrigatório ?
    aadd(aPergs,aItem)

    aItem := {} // 7
    aadd(aItem,2                    )
    aadd(aItem,"Reimpressão?"       )
    aadd(aItem,2                    )
    aadd(aItem,{"Sim","Não"}        )
    aadd(aItem,fieldSize("C6_NUM")  )
    aadd(aItem,nil                  ) // String contendo a validação
    aadd(aItem,.T.                  ) // Flag .T./.F. Parâmetro Obrigatório ?
    aadd(aPergs,aItem)

Return aPergs

Static Function fieldSize(cCampo)
Return StaticCall(LISTBOX,fieldSize,cCampo)

Static Function FiltrarPed(aFiltro)
    Local aArea     := GetArea()
    Local cQuery    := ""
    Local cTemp     := GetNextAlias()
    Local lTela     := !isBlind()
    Local aItem     := {}
    Local aPedidos  := {} 
    Local dDtIni    := aFiltro[1]
    Local dDtFim    := aFiltro[2]
    Local cCLiIni   := aFiltro[3]
    Local cCLiFim   := aFiltro[4]
    Local cPedIni   := aFiltro[5] //"302725" //
    Local cPedFim   := aFiltro[6] // "302725" //
    Local cReimp    := aFiltro[7]
    
    lReimpress := cReimp == "Sim"
    nCount := 0

    // cria a tabela no banco
    DbSelectArea("Z03")

    if lTela
        ProcRegua(0)
        IncProc()
        IncProc()
    Endif

	cQuery += "SELECT DISTINCT "+ENTER
	cQuery += "    C9_FILIAL "+ENTER
	cQuery += "    ,C9_PEDIDO "+ENTER
	cQuery += "    ,C5_EMISSAO "+ENTER
	cQuery += "    ,C9_DATALIB "+ENTER
	cQuery += "    ,ISNULL(Z03_IMPRES,0) Z03_IMPRES "+ENTER
	cQuery += " "+ENTER
	cQuery += "FROM "+RetSqlName("SC9")+" SC9 "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SC5")+" SC5 ON SC5.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND C5_FILIAL = C9_FILIAL "+ENTER
	cQuery += "		AND C5_NUM = C9_PEDIDO "+ENTER
	cQuery += "		AND C5_EMISSAO >= '"+DtoS(dDtIni)+"' "+ENTER
	cQuery += "		AND C5_EMISSAO <= '"+DtoS(dDtFim)+"' "+ENTER
    cQuery += "	INNER JOIN "+RetSqlName("SC6")+" SC6 ON SC6.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND C6_FILIAL = C9_FILIAL "+ENTER
	cQuery += "		AND C6_NUM = C9_PEDIDO "+ENTER
	cQuery += "		AND C6_ITEM = C9_ITEM "+ENTER
	cQuery += "		AND C6_PRODUTO = C9_PRODUTO "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND F4_FILIAL = C6_FILIAL "+ENTER
	cQuery += "		AND F4_CODIGO = C6_TES "+ENTER
	cQuery += "		AND F4_ESTOQUE = 'S' "+ENTER
	cQuery += "	LEFT OUTER JOIN "+RetSqlName("Z03")+" Z03 ON Z03.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND Z03_FILIAL = C9_FILIAL "+ENTER
    cQuery += "		AND Z03_PEDIDO = C9_PEDIDO "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE "+ENTER
	cQuery += "		SC9.D_E_L_E_T_ <> '*' "+ENTER
	cQuery += "		AND C9_FILIAL = '"+xFilial("SC9")+"' "+ENTER
	cQuery += "		AND C9_NFISCAL = '' "+ENTER
	cQuery += "		AND C9_BLCRED = '' "+ENTER
	
	//Desconsidera Bloqueios de Estoque 
	//cQuery += "		AND C9_BLEST = '02' "+ENTER
    
    If !Empty(AllTrim(cPedIni))
        cQuery += "    AND C9_PEDIDO >= '"+cPedIni+"' "+ENTER
        cQuery += "    AND C9_PEDIDO <= '"+cPedFim+"' "+ENTER
    Endif
    If !Empty(AllTrim(cCLiIni))
        cQuery += "    AND C9_CLIENTE >= '"+cCLiIni+"' "+ENTER
        cQuery += "    AND C9_CLIENTE <= '"+cCLiFim+"' "+ENTER
    Endif
    
    if !lReimpress
        cQuery += "    AND ISNULL(Z03_IMPRES,0) = 0 "+ENTER
    Endif

    cQuery += "    AND 0 = (SELECT COUNT (*) FROM "+RetSqlName("SC9")+" SC9I WHERE SC9I.D_E_L_E_T_<>'*' "+ENTER
    cQuery += "    AND SC9I.C9_FILIAL = SC9.C9_FILIAL "+ENTER
    cQuery += "    AND SC9I.C9_PEDIDO = SC9.C9_PEDIDO "+ENTER
    cQuery += "    AND SC9I.C9_BLCRED <> '') "+ENTER
    cQuery += " "+ENTER
    cQuery += "ORDER BY C9_PEDIDO  "+ENTER
    
    If Select(cTemp) > 0
        (cTemp)->( DbCloseArea() )
    Endif
    
    TcQuery cQuery New Alias (cTemp)
    Count to nCount

    (cTemp)->( DbGoTop() )

    While !(cTemp)->(EOF())
        cPedido := (cTemp)->C9_PEDIDO
        If lTela
            IncProc("Carregando itens do pedido "+cPedido)
        Endif
        
        aItem := GetItens(cPedido)
        If !Empty(aItem)
            aadd(aPedidos,aItem)
        Endif
        
        (cTemp)->( DbSkip() )
    Enddo

    If Select(cTemp) > 0
        (cTemp)->( DbCloseArea() )
    Endif
    
    RestArea(aArea)
Return aPedidos 

Static Function ReportDef(aFiltro)
    Local oReport   := TReport():New("KFATR21","Packing List",nil,{|oReport| ReportPrin(oReport,aFiltro)},"")
    //FWMsPrinter():New(cFilePrintert,nDevice,lAdjustToLegacy,cPathInServer,lDisabeSetup,lTReport,@oPrintSetup,cPrinter,lServer,lPDFAsPNG,lRaw,lViewPDF,nQtdCopy)
    Local oCab      := TRSection():New(oReport,"",{})
    Local nFontSize := oReport:nFontBody
    Local nLineHei  := oReport:nLineHeight
    Local oItens    := TRSection():New(oReport,"",{}, /* <aOrder> */ ,;
	/* <.lLoadCells.> */ , , /* <cTotalText>  */, /* !<.lTotalInCol.>  */, /* <.lHeaderPage.>  */,;
	/* <.lHeaderBreak.> */, /* <.lPageBreak.>  */, /* <.lLineBreak.>  */, /* <nLeftMargin>  */,;
	/* <.lLineStyle.>  */, /* <nColSpace>  */,.T. /*<.lAutoSize.> */, /*<cSeparator> */,;
	/*<nLinesBefore>  */, /*<nCols>  */, /* <nClrBack> */, /* <nClrFore>  */)

    nFontSize   := 9
    nLineHei    := 42    

    oReport:HideParamPage()
    oReport:HideHeader()
    oReport:HideFooter()
    oReport:SetTotalInLine(.F.)
    oReport:DisableOrientation()
    oReport:oPage:nPaperSize := DMPAPER_A4 
    oReport:SetLandscape()
    oReport:nDevice          := IMP_SPOOL
    oReport:nFontBody        := nFontSize
    oReport:nLineHeight		 := nLineHei
    oReport:lBold := .T.	

  //TRCell():New(section,campo          ,tabel,titulo           ,picture                            ,tamanho    ,pixel  ,bloco   ,cAlign ,lBreakline )
  //TRCell():New(oSecPd, "COD_PRODUTO"	, Nil, "CODIGO"	        , PesqPict("SB1", "B1_COD")			,TamSX3("B1_COD")[1])
    
    TRCell():New(oItens ,"C9_ITEM"      ,"SC9","Item"           , PesqPict("SC9", "C9_ITEM")        ,(TamSX3("C9_ITEM")[1]  )+5 ,       ,,)
    TRCell():New(oItens ,"C9_PRODUTO"   ,"SC9","Código"         , PesqPict("SC9", "C9_PRODUTO")     ,TamSX3("C9_PRODUTO")[1]    ,       ,,)
    TRCell():New(oItens ,"BZ_XPICKIN"   ,"SBZ","Endereço"       , PesqPict("SBZ", "BZ_XPICKIN")     ,TamSX3("BZ_XPICKIN")[1]    ,       ,,)
    TRCell():New(oItens ,"C6_DESCRI"    ,"SC6","Descrição"      , PesqPict("SC6", "C6_DESCRI")      ,TamSX3("C6_DESCRI")[1]     ,       ,        ,       ,.T.        )
    TRCell():New(oItens ,"C9_QTDLIB"    ,"SC9","Quantidade"     , PesqPict("SC9", "C9_QTDLIB")      ,TamSX3("C9_QTDLIB")[1]     ,       ,,)
    TRCell():New(oItens ,"C6_UM"        ,"SC6","Unidade"        , PesqPict("SC6", "C6_UM")          ,TamSX3("C6_UM")[1]         ,       ,,)
    TRCell():New(oItens ,"B1_K_PESOB"   ,"SB1","Peso Un."       , PesqPict("SB1", "B1_K_PESOB")     ,TamSX3("B1_K_PESOB")[1]    ,       ,,)
    TRCell():New(oItens ,"B1_K_PESOL"   ,"SB1","Peso Tot"       , PesqPict("SB1", "B1_K_PESOL")     ,TamSX3("B1_K_PESOL")[1]    ,       ,,)
    TRCell():New(oItens ,"C9_PRCVEN"    ,"SC9","V. Unit"        , PesqPict("SC9", "C9_PRCVEN")      ,TamSX3("C9_PRCVEN")[1]     ,       ,,)
    TRCell():New(oItens ,"C6_VALOR"     ,"SC6","V. Total"       , PesqPict("SC6", "C6_VALOR")       ,TamSX3("C6_VALOR")[1]      ,       ,,)

    oItens:SetCellBorder("BOTTOM")

Return oReport

Static Function ReportPrin(oReport,aFiltro)
    Local oItens    := oReport:Section(2)
    Local aItens    := {}
    Local nX        := 0
    Local nY        := 0
    Local cItem     := ""
    Local cProd     := ""
    Local cEnde     := ""
    Local cDesc     := ""
    Local cUM       := ""
    Local nPUni     := 0
    Local nPTot     := 0
    Local nQtd      := 0
    Local nPrc      := 0
    Local nTot      := 0
    Local aTotal    := {}
    Local nTotal    := 0
    Local nTotPes   := 0
    Local nPos      := 0
    Local aPed      := {}
    Local nItens    := 0    
    Private nCount  := 0
    Private dDtAtual:= DtoC(Date())
    Private cHrAtual:= Time()
    Private nPagina := 0
    Private nPrinted:= 0
    Private _aPed   := {}
    
    aPed := FiltrarPed(aFiltro)    
    oReport:SetMeter(nCount)

    If lReimpress
        If nCount > _nQtdPv //Nao imprimir quando for maior que 10
            MsgAlert("Não é permitido imprimir mais de 05 pedidos de uma única vez(reimpressão)!!!!!!!!!!!")
            return    
        EndIf
    EndIf

    For nX := 1 to Len(aPed)        
        _aPed := aPed[nX]
        oReport:onPageBreak( { || nPagina++ , nPrinted := 0 , PrnCab(oReport,aPed[nX]) })

        aItens  := aPed[nX][Len(aPed[nX])]
        nPagina := 0
        aTotal  := {}
        nTotal  := 0
        nTotPes := 0
        nItens  := 0
        dDtAtual:= DtoC(Date())
        cHrAtual:= Time()
        
        oItens :Init()
        For nY := 1 to Len(aItens)
            oReport:IncMeter()

            // If nItens >= nMaxItens .or. oReport:PageHeight() <= oReport:Row() 
            If oReport:PageHeight() <= oReport:Row() + (oReport:LineHeight() * 7)
                nPrinted := 0
                nItens   := 0
                oReport:SkipLine()
                oReport:PrintText("Continua na Proxima pagina ....",, 050 )
                oReport:EndPage()
            Endif

            cItem := StrZero(nY,2) 
            cProd := aItens[nY][01]
            cEnde := aItens[nY][02]
            cDesc := aItens[nY][03]
            cUM   := aItens[nY][04]
            nPUni := aItens[nY][05]
            nPTot := aItens[nY][06]
            nQtd  := aItens[nY][07]
            nPrc  := aItens[nY][08]
            nTot  := aItens[nY][09]

            nPos := aScan(aTotal,{|x| x[1] == cUM})
            if nPos == 0
                aadd(aTotal,{cUM,nQtd})
            else
                aTotal[nPos][2] += nQtd
            Endif

            nTotal += nTot
            nTotPes+= nPTot
            oItens:Cell("C9_ITEM"   ):SetValue(cItem    )
            oItens:Cell("C9_PRODUTO"):SetValue(cProd    )
            oItens:Cell("BZ_XPICKIN"):SetValue(cEnde    )
            oItens:Cell("C6_DESCRI" ):SetValue(cDesc    )
            oItens:Cell("C6_UM"     ):SetValue(cUM      )
            oItens:Cell("B1_K_PESOB"):SetValue(nPUni    )
            oItens:Cell("B1_K_PESOL"):SetValue(nPTot    )
            oItens:Cell("C9_QTDLIB" ):SetValue(nQtd     )
            oItens:Cell("C9_PRCVEN" ):SetValue(nPrc     )
            oItens:Cell("C6_VALOR"  ):SetValue(nTot     )
            oItens:PrintLine()

            nPrinted += 1
            nItens += 1

        Next

        oItens:Finish()
        PrnFooter(oReport,nTotal,nTotPes,aTotal)
        oReport:EndPage()

    Next

    Begin Transaction
        For nX := 1 to Len(aPed)
            U_KFATR21I(aPed[nX][1])
        Next
    End Transaction
    
Return

Static Function GetItens(cPedido)
    Local aArea     := GetArea()
    Local cQuery    := ""
    Local cTemp     := GetNextAlias()
    Local aRet      := {}
    Local aItem     := {}
    Local cEndereco := 0
    Local nQuant    := 0
    Local aItens    := {}

    cQuery += "SELECT "+ENTER
	cQuery += "	C9_PEDIDO  "+ENTER
	cQuery += "	,C9_CLIENTE  "+ENTER
	cQuery += "	,C9_LOJA  "+ENTER
	cQuery += "	,C5_TIPO  "+ENTER
	cQuery += "	,C5_EMISSAO  "+ENTER
	cQuery += "	,C5_TPFRETE  "+ENTER
	cQuery += "	,C5_TRANSP "+ENTER
	cQuery += "	,A4_NOME  "+ENTER
	cQuery += "	,C5_VEND1  "+ENTER
	cQuery += "	,A3_NOME  "+ENTER
	cQuery += "	,C5_CONDPAG  "+ENTER
	cQuery += "	,E4_DESCRI  "+ENTER
	cQuery += "	,CASE  "+ENTER
	cQuery += "		WHEN C5_TIPO IN ('D','B') THEN A2_NOME "+ENTER
	cQuery += "		ELSE A1_NOME "+ENTER
	cQuery += "	END A1_NOME "+ENTER
	cQuery += "	,CASE "+ENTER
	cQuery += "		WHEN C5_TIPO IN ('D','B') THEN A2_MUN "+ENTER
	cQuery += "		ELSE A1_MUN "+ENTER
	cQuery += "	END A1_MUN "+ENTER
	cQuery += "	,CASE "+ENTER
	cQuery += "		WHEN C5_TIPO IN ('D','B') THEN A2_EST "+ENTER
	cQuery += "		ELSE A1_EST "+ENTER
	cQuery += "	END A1_EST "+ENTER
	cQuery += "	,C5_XTPPED  "+ENTER
	cQuery += "	,C9_PRODUTO  "+ENTER
	cQuery += "	,BZ_XPICKIN  "+ENTER
	cQuery += "	,C6_DESCRI  "+ENTER
	cQuery += "	,C6_UM  "+ENTER
	cQuery += "	,C9_PRCVEN  "+ENTER
	cQuery += "	,B1_K_PESOB  "+ENTER
	cQuery += "	,C9_QTDLIB * B1_K_PESOB PESBRUT "+ENTER
	cQuery += "	,C9_QTDLIB  "+ENTER
	cQuery += "	,C9_PRCVEN  "+ENTER
	cQuery += "	,C9_QTDLIB * C9_PRCVEN VLRTOTAL "+ENTER
    cQuery += " ,ISNULL(Z03_IMPRES,0) Z03_IMPRES "+ENTER
    cQuery += " ,Rtrim(ISNULL(ZE_DESCRIC,'')) ZE_DESCRIC "+ENTER
    cQuery += " ,ISNULL(RES.QUANTIDADE,0) QUANTIDADE "+ENTER
	cQuery += " ,ISNULL(RES.ENDERECO,'') ENDERECO "+ENTER
	cQuery += " ,A1_PESSOA "+ENTER		
	cQuery += " ,A1_CEP "+ENTER
	cQuery += " ,C5_FRETE "+ENTER
	cQuery += " ,A1_CGC "+ENTER
	cQuery += "	 "+ENTER
	cQuery += "FROM "+RetSqlName("SC9")+" SC9 "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND B1_FILIAL = '"+xFilial("SB1")+"' "+ENTER
	cQuery += "		AND B1_COD = C9_PRODUTO "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SC6")+" SC6 ON SC6.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND C6_FILIAL = C9_FILIAL "+ENTER
	cQuery += "		AND C6_NUM = C9_PEDIDO "+ENTER
	cQuery += "		AND C6_ITEM = C9_ITEM "+ENTER
	cQuery += "		AND C6_PRODUTO = C9_PRODUTO "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SC5")+" SC5 ON SC5.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND C5_FILIAL = C6_FILIAL "+ENTER
	cQuery += "		AND C5_NUM = C6_NUM "+ENTER
	cQuery += "	LEFT OUTER JOIN "+RetSqlName("SZE")+" SZE ON SZE.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND ZE_FILIAL = '"+xFilial("SZE")+"' "+ENTER
	cQuery += "		AND ZE_MODALID = C5_XTPPED"+ENTER
	cQuery += "	LEFT OUTER JOIN "+RetSqlName("SE4")+" SE4 ON SE4.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND E4_FILIAL = '"+xFilial("SE4")+"' "+ENTER
	cQuery += "		AND E4_CODIGO = C5_CONDPAG "+ENTER
	cQuery += "	LEFT OUTER JOIN "+RetSqlName("SA4")+" SA4 ON SA4.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND A4_FILIAL = '"+xFilial("SA4")+"' "+ENTER
	cQuery += "		AND A4_COD = C5_TRANSP "+ENTER
	cQuery += "	LEFT OUTER JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND BZ_FILIAL = C9_FILIAL "+ENTER
	cQuery += "		AND BZ_COD = C9_PRODUTO "+ENTER
	cQuery += "	LEFT OUTER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND A1_FILIAL = '"+xFilial("SA1")+"' "+ENTER
	cQuery += "		AND A1_COD = C9_CLIENTE "+ENTER
	cQuery += "		AND A1_LOJA = C9_LOJA "+ENTER
	cQuery += "	LEFT OUTER JOIN "+RetSqlName("SA2")+" SA2 ON SA2.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND A2_FILIAL = '"+xFilial("SA2")+"' "+ENTER
	cQuery += "		AND A2_COD = C9_CLIENTE "+ENTER
	cQuery += "		AND A2_LOJA = C9_LOJA "+ENTER
	cQuery += "	LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 ON SA3.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND A3_FILIAL = '"+xFilial("SA3")+"' "+ENTER
	cQuery += "		AND A3_COD = C5_VEND1 "+ENTER
	cQuery += " LEFT OUTER JOIN "+RetSqlName("Z03")+" Z03 ON Z03.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "     AND Z03_FILIAL = C9_FILIAL "+ENTER
    cQuery += "     AND Z03_PEDIDO = C9_PEDIDO "+ENTER
    cQuery += " LEFT OUTER JOIN (SELECT "+ENTER
	cQuery += " 					C0_FILIAL FILIAL "+ENTER
	cQuery += " 					,C0_DOCRES PEDIDO "+ENTER
	cQuery += " 					,C0_PRODUTO PRODUTO "+ENTER
	cQuery += " 					,DC_QUANT QUANTIDADE "+ENTER
	cQuery += " 					,DC_LOCALIZ ENDERECO "+ENTER
    cQuery += "  "+ENTER
	cQuery += " 				FROM "+RetSqlName("SC0")+" SC0 "+ENTER
	cQuery += " 					INNER JOIN "+RetSqlName("SDC")+" SDC ON SDC.D_E_L_E_T_<>'*' "+ENTER
	cQuery += " 						AND DC_FILIAL = C0_FILIAL "+ENTER
	cQuery += " 						AND DC_PEDIDO = C0_NUM "+ENTER
	cQuery += " 						and DC_PRODUTO = C0_PRODUTO "+ENTER
	cQuery += " 						and DC_LOCAL = C0_LOCAL "+ENTER
	cQuery += " 				WHERE  "+ENTER
	cQuery += " 						SC0.D_E_L_E_T_<>'*' "+ENTER
	cQuery += " 					AND C0_TIPO = 'PD' "+ENTER
	cQuery += " 				) RES ON RES.FILIAL = C9_FILIAL "+ENTER
	cQuery += " 					AND RES.PEDIDO = C9_PEDIDO "+ENTER
	cQuery += " 					AND RES.PRODUTO = C9_PRODUTO "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE "+ENTER
	cQuery += "    SC9.D_E_L_E_T_ <> '*' "+ENTER
	cQuery += "    AND C9_FILIAL = '"+xFilial("SC9")+"' "+ENTER
	cQuery += "    AND C9_PEDIDO = '"+cPedido+"' "+ENTER
	cQuery += "    AND C9_NFISCAL = '' "+ENTER	
	cQuery += "    AND C9_BLCRED = '' "+ENTER
	
	//Desconsidera Bloqueios de Estoque
	//cQuery += " AND C9_BLEST = '02' "+ENTER
	
	cQuery += " "+ENTER
	cQuery += "ORDER BY  "+ENTER
	cQuery += "	BZ_XPICKIN "+ENTER
    cQuery += "	,C9_PRODUTO "+ENTER
    
    if Select(cTemp) > 0
        (cTemp)->(DbCloseArea())
    Endif  
    
    TcQuery cQuery New Alias (cTemp)

    If !(cTemp)->(EOF())

        aadd(aRet,(cTemp)->C9_PEDIDO        ) // 1
        aadd(aRet,(cTemp)->C9_CLIENTE       ) // 2
        aadd(aRet,(cTemp)->C9_LOJA          ) // 3
        aadd(aRet,(cTemp)->C5_TIPO          ) // 4
        aadd(aRet,Stod((cTemp)->C5_EMISSAO) ) // 5
        aadd(aRet,(cTemp)->C5_TPFRETE       ) // 6
        aadd(aRet,(cTemp)->A4_NOME          ) // 7
        aadd(aRet,(cTemp)->C5_VEND1         ) // 8
        aadd(aRet,(cTemp)->A3_NOME          ) // 9
        aadd(aRet,(cTemp)->C5_CONDPAG       ) // 10
        aadd(aRet,(cTemp)->E4_DESCRI        ) // 11
        aadd(aRet,(cTemp)->A1_NOME          ) // 12
        aadd(aRet,(cTemp)->A1_MUN           ) // 13
        aadd(aRet,(cTemp)->A1_EST           ) // 14
        aadd(aRet,(cTemp)->C5_XTPPED        ) // 15
        aadd(aRet,(cTemp)->C5_TRANSP        ) // 16
        aadd(aRet,(cTemp)->Z03_IMPRES       ) // 17
        aadd(aRet,(cTemp)->ZE_DESCRIC       ) // 18        
        aadd(aRet,(cTemp)->A1_CEP      		) // 19
        aadd(aRet,(cTemp)->C5_FRETE         ) // 20
        aadd(aRet,Transform((cTemp)->A1_CGC, Iif((cTemp)->A1_PESSOA=="J", "@R 99.999.999/9999-99", "@R 999.999.999-99"))) // 21
        
        While !(cTemp)->(EOF())
        
            aItem := {}
            cEndereco   := (cTemp)->BZ_XPICKIN   
            nQuant      := (cTemp)->C9_QTDLIB

            If (cTemp)->QUANTIDADE > 0 .and. !Empty(AllTrim((cTemp)->ENDERECO)) 
                cEndereco   := (cTemp)->ENDERECO 
                if nQuant > (cTemp)->QUANTIDADE
                    nQuant      := (cTemp)->QUANTIDADE
                Endif
            Endif

            aadd(aItem,(cTemp)->C9_PRODUTO          ) // 1
            aadd(aItem,cEndereco                    ) // 2
            aadd(aItem,(cTemp)->C6_DESCRI           ) // 3 
            aadd(aItem,(cTemp)->C6_UM               ) // 4
            aadd(aItem,(cTemp)->B1_K_PESOB          ) // 5
            aadd(aItem,nQuant * (cTemp)->B1_K_PESOB ) // 6
            aadd(aItem,nQuant                       ) // 7
            aadd(aItem,(cTemp)->C9_PRCVEN           ) // 8
            aadd(aItem,(cTemp)->C9_PRCVEN*nQuant    ) // 9
            aadd(aItens,aItem)

            (cTemp)->(DbSkip())
        Enddo

        aadd(aRet,aItens)

    Endif

    if Select(cTemp) > 0
        (cTemp)->(DbCloseArea())
    Endif  

    RestArea(aArea)
Return aRet

Static Function PrnCab(oReport,aPedido)
    Local aArea     := GetArea()
    Local cObs      := ""
    Local cObsTemp  := ""
    Local cTipo     := aPedido[15] +" - "+aPedido[18]
    Local dLimite   := Stod("")
    Local oItens    := oReport:Section(2)
    Local cFonte	:= "Courier New"
    Local aObs      := {}
    Local nX        := 0
    Local nTamLinha := 140
    // Local nColObs   := 100
    // Local cObs1     := ""
    // Local cObs2     := ""
    Local aTpFrete  := x3CboxToArray("C5_TPFRETE")
    Local nPFrete   := aScan(aTpFrete[2],aPedido[6])
    Local cFrete    := StrTran(aTpFrete[1][nPFrete],aPedido[6]+" - ","")
    Local oFont10   := TFont():New("Courier new",,12    ,,.T.,,,,,.F.,.F.)
    Local oFont12   := TFont():New("Courier new",,14    ,,.T.,,,,,.F.,.F.)
    Local oFont13   := TFont():New("Courier new",,15    ,,.T.,,,,,.F.,.F.)
                     //TFont():New(cName        ,,nHeight,,lBold,,,,,lUnderline,lItalic)

    //linha e coluna do codigo de barras
    cTypeBar	:= "CODE128"        // tipo codigo de barras
    nRow		:= 0.4			    // Linha que será impresso o Código de Barra
    nCol		:= 20	            // Coluna que será impresso o Código de Barra
    cCode		:= aPedido[1]       // codigo de barrras	
    lCheck		:= .F.		        // calcula digito verificador
    nColor		:= Nil				// cor do codigo de barras
    lHort		:= .T.				// impressao horizontal
    nWidth	 	:= 0.025 * 1.2	    // Numero do Tamanho da barra. Default 0.025 limite de largura da etiqueta é 0.0164
    nHeigth   	:= 1.5   * 1.2       // Numero da Altura da barra. Default 1.5 --- limite de altura é 0.3
    lBanner		:= .T.				// Se imprime a linha com o código embaixo da barra. Default .T.
    cFont		:= cFonte			// fonte do codigo de barras
    cMode		:= "A"				// modo de impressao code 128 c = compacto
    lPrint		:= .f.				// utiliza print do objeto pai
    nPFWidth	:= nil				// Número do índice de ajuste da largura da fonte. Default 1
    nPFHeigth	:= nil				// Número do índice de ajuste da altura da fonte. Default 1

    // se a resolucao vertival maior que 4000 -> impressoras
    // se menor -> PDF
    If oReport:oPage:nVertRes > 4000
        // divide o posicionamento por 2
        nRow := nRow / 2
        // divide o posicionamento por 2
        nCol := nCol / 2
    Endif

    SC5->( DbSetOrder(1))
    If SC5->( MsSeek(xFilial("SC5")+aPedido[1]))
        cObs := SC5->C5_MSGCLI

        If !Empty(AllTrim(cObs))
            cObs := StrTran(cObs,chr(13)+chr(10)," ")
            
            nTam := MlCount(cObs,nTamLinha,,.T.)
            for nX := 1 to nTam
                cObsTemp := AllTrim(MemoLine(cObs, nTamLinha + 1, nX, 3,.T.))
                If !Empty(AllTrim(cObsTemp))
                    aadd(aObs,cObsTemp)
                Endif
            next 
        Endif
    Endif

    // imprime o codigo de barras
    MsBar3(cTypeBar,nRow,nCol,cCode,@oReport:oPrint,lCheck,nColor,lHort,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth)

    oReport:SkipLine()
    
    oReport:Say(oReport:Row(),oReport:Col(),"PACK LIST DE SEPARAÇÃO DO PEDIDO DE VENDA:",oFont12)
    oReport:Say(oReport:Row()-5,oReport:Col()+1150,aPedido[1],oFont13)
    oReport:Say(oReport:Row(),oItens:Cell("C6_VALOR"):ColPos(),"Pagina: "+cValToChar(nPagina),oFont12)

    oReport:SkipLine()

    oReport:SkipLine()
    oReport:Say(oReport:Row(),oReport:Col(),"Responsável "+UsrRetName(RetCodUsr())+", Via "+cValToChar(aPedido[17]+1)+"  "+dDtAtual+" "+cHrAtual,oFont10)

    oReport:SkipLine()
    oReport:Say(oReport:Row(),oReport:Col(),"Destinatário: "+AllTrim(aPedido[2])+"/"+AllTrim(aPedido[3])+" - "+Alltrim(aPedido[12])+;
    " - " + aPedido[21],oFont10)

    oReport:SkipLine()
    oReport:Say(oReport:Row(),oReport:Col(),"Cidade: "+AllTrim(aPedido[13]) + " - " + AllTrim(aPedido[14]) +;
    	" - Cep: " + AllTrim(Transform(aPedido[19], "@R 99.999-999")),oFont10)    
    oReport:SkipLine()
    If Empty(dLimite)
        oReport:Say(oReport:Row(),oReport:Col(),"Data Emissão: "+DtoC(aPedido[5]),oFont10)
    Else
        oReport:Say(oReport:Row(),oReport:Col(),"Data Emissão: "+DtoC(aPedido[5])+"      Data Limite Embarque: "+DtoC(Stod("")) ,oFont10)
    Endif
    oReport:SkipLine()

    oReport:Say(oReport:Row(),oReport:Col(),"Forma Pagamento: "+AllTrim(aPedido[10]+" - "+AllTrim(aPedido[11])),oFont10)
    oReport:SkipLine()

    oReport:Say(oReport:Row(),oReport:Col(),"Tipo do Pedido: "+Alltrim(cTipo),oFont10)
    oReport:SkipLine()

    oReport:Say(oReport:Row(),oReport:Col(),"Representante: "+Alltrim(aPedido[8])+" - "+Alltrim(aPedido[9]),oFont10)
    oReport:SkipLine()

    oReport:Say(oReport:Row(),oReport:Col(),"Frete: "+AllTrim(cFrete) + " - R$ " + AllTrim(Transform(aPedido[20], PesqPict("SC5", "C5_FRETE")))+;  
    	" - Transportadora: "+Alltrim(aPedido[16])+" - "+Alltrim(aPedido[7]),oFont10)
    	
    oReport:SkipLine()
    for nX := 1 to Len(aObs)
        If nX == 1
            cObsTemp := "Observações: "+aObs[nX]
        Else
            cObsTemp := "             "+aObs[nX]
        Endif
        oReport:Say(oReport:Row(),oReport:Col(),cObsTemp,oFont10)
        oReport:SkipLine()
    Next

    oReport:SkipLine()
    oReport:SkipLine()
    oReport:FatLine()
    oReport:SkipLine()

    RestArea(aArea)
Return

/*
    Gravar que o packing list do pedido foi impresso
*/
User Function KFATR21I(cPedido)
    Local aArea := GetArea()
    Local nVia  := 0
    Local lExis := .F.

    SC5->( DbSetOrder(1))
    if SC5->(MsSeek(xFilial("SC5")+cPedido))
        
        If Empty(SC5->C5_NOTA) //Se nao gerou nota, deixa como em separacao = 9
            RecLock("SC5",.F.)
        	SC5->C5_XSITLIB := "9"
        	MsUnLock("SC5")
        EndIf
        /* Comentado em 10-02-21 conforme alinhado com o Rufini - Luis rsac
        If !lReimpress
        	RecLock("SC5",.F.)
        	SC5->C5_XSITLIB := "9"
        	MsUnLock("SC5")
        EndIf
        */
        Z03->( DbSetOrder(3) )
        lExis := Z03->( MsSeek(xFilial("Z03")+cPedido))

        If !lExis
            Z03->( DbGoTop() )
        Endif

        RecLock("Z03",!lExis)
            Z03->Z03_FILIAL := xFilial("Z03")
            Z03->Z03_PEDIDO := cPedido
            Z03->Z03_CLIENT := SC5->C5_CLIENTE
            Z03->Z03_LOJA   := SC5->C5_LOJACLI
            Z03->Z03_IMPRES += 1
            Z03->Z03_DTIMPR := Date()
            Z03->Z03_HRIMPR := Time()
            Z03->Z03_NUM    := Space(9)
            Z03->Z03_EMISSA := Date()
            Z03->Z03_USRCOD	:= RetCodUsr()
            Z03->Z03_USRNOM	:= UsrRetName(Z03->Z03_USRCOD)
        MsUnLock("Z03")
        
        nVia := Z03->Z03_IMPRES

        //grava status da Impressão
        U_KFATR15("18"      ,cPedido,nil    ,nil    ,nil    ,"Via Nº: "+cValToChar(nVia))        
    Endif

    RestArea(aArea)
Return nVia

Static Function PrnFooter(oReport,nTotal,nTotPes,aTotal)
    Local nY    := 0
    Local cTexto:= ""
    Local cPic  := PesqPict("SC6","C6_VALOR")

    oReport:SkipLine()
    oReport:PrintText("Total R$ "+AllTrim(Transform(nTotal,cPic)))
    oReport:PrintText("Peso Total: "+Alltrim(Transform(nTotPes,PesqPict("SB1","B1_K_PESOL"))))
    oReport:SkipLine()
    oReport:PrintText("Totais por Unidade de Medida: ")

    aSort(aTotal,,,{|x,y| x[1] < y[1]})

    For nY := 1 to Len(aTotal)
        If !Empty(AllTrim(cTexto))
            cTexto += ", "
        Endif
        cTexto += AllTrim(aTotal[nY][1])+": "+cValToChar(aTotal[nY][2])
    Next

    If !Empty(AllTrim(cTexto))
        oReport:PrintText(cTexto)
        oReport:SkipLine()
    Endif

Return
