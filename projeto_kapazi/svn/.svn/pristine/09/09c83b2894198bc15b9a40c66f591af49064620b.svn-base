#Include "rwmake.ch"
#Include "topconn.ch"
#Include "font.ch"
#Include "rwmake.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"
#Include 'protheus.ch'

User Function RFAT01()
    Local 	aArea	   :=	GetArea()
//    Local	aPergs     := {}

//    Private lExec      := .F.
//    Private cIndexName := ''
//    Private cIndexKey  := ''
//    Private cFilter    := ''
//    Private _cParcela  := ''
//    Private aArray     := {}
    Private nRow1	   := 0
    
    Static lteste      := .T.

    Tamanho            := "P"
	Titulo             := "Impressão da Pedido de Venda"
    cDesc1             := "Este programa irá imprimir Pedido de Venda."
    cDesc2             := "Utilização em impressoras laser."
    cDesc3             := ""
    cString            := "SC5"
    Wnrel              := "RFAT01"
    lEnd               := .F.
    cPerg              := "RFAT01"
    aReturn            := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
    nLastKey           := 0

    dbSelectArea('SC5')
    validperg()
    Pergunte(cPerg,.F.)

    Wnrel := SetPrint(cString,Wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,)
    If nLastKey = 27
        Set Filter to
        Return
    Endif

    SetDefault(aReturn,cString)

    If nLastKey = 27
        Set Filter to
        Return
    Endif

    Processa({|lEnd|MontaRel()})

    RestArea(aArea)
Return Nil

//--------------------------------------
//Inicia consulta dos dados - MONTAREL()
//--------------------------------------
Static Function MONTAREL()

    Local aArea		 :=	GetArea()
    Local 	cFiltro	 := "@ "
//    Private nLinha   := 0
//    Private lNovaPag := .T.
//    Private lRodape  := .T.
//    Private nPagina  := 0
//    Private cDataEmi := ""
//    Private cDataImp := ""
    private oFonAri8 := TFont():New("Arial", 8, 8, nil, .F., nil, nil, nil, .F., .F.)
    Private oFont14  := TFont():New("Arial",9,10 ,.T.,.F.,5,.T.,5,.T.,.F.)
    Private oFont14n := TFont():New("Arial",9,10 ,.T.,.T.,5,.T.,5,.T.,.F.)
    Private oFont16  := TFont():New("Arial",9,14 ,.T.,.F.,5,.T.,5,.T.,.F.)
    Private oFont16n := TFont():New("Arial",9,14 ,.T.,.T.,5,.T.,5,.T.,.F.)
    Private ntotal	 :=0
    Private _nTotIPI :=0
    Private TranspNM := ""
	//INCLUIDO
    Private _nTotSt	 :=0
//    Private bSt      :=0
    Private aImp     := {}

    oPrint := TMSPrinter():New( "Pedido de Venda" )
    oPrint :SetPortrait() 								//ou SetLandscape()
    oPrint :StartPage()   								//inicia uma nova página

    dbGoTop()
    ProcRegua(RecCount())

    DbSelectArea("SC5")
    DbSeek(xFilial("SC5")+ mv_par01 )

    If Empty(alltrim(mv_par01))
        SC5->(MsSeek(xFilial("SC5")))
    EndIf

    cFiltro += "C5_FILIAL = '"+xFilial("SC5")+"' "
    cFiltro += "AND C5_NUM >= '"+mv_par01+"' "
    cFiltro += "AND C5_NUM <= '"+mv_par02+"' "
    cFiltro += "AND C5_CLIENTE >= '"+MV_PAR05+"'"
    cFiltro += "AND C5_CLIENTE <= '"+MV_PAR06+"'"
    cFiltro += "AND C5_EMISSAO >= '"+DtoS(MV_PAR03)+"'"
    cFiltro += "AND C5_EMISSAO <= '"+DtoS(MV_PAR04)+"'"

    SC5->( DBClearFilter())
    SC5->( DbSetFilter({|| .T.},cFiltro))
    SC5->( DbGoTop() )

    _nSitLib := mv_par09 // 1=Liberados;2=Bloqueados;3=Faturados;4=Todos
    _nSitLib := mv_par09 // 1=Liberados;2=Bloqueados;3=Faturados;4=Todos

    While !SC5->(Eof()) .and. SC5->C5_FILIAL == XFILIAL("SC5") .and.  SC5->C5_NUM <= mv_par02
        If _nSitLib == 4 .or. ; // Todos
            (_nSitLib==1 .and. sc5->c5_xsitlib == '6').or.; // Somente liberados
            (_nSitLib==2 .and. sc5->(c5_xsitlib <> '6' .and. c5_xsitlib <> '7')) .or. ; // Somente Bloqueados
            (_nSitLib==3 .and. sc5->c5_xsitlib == '7') // Somente Faturados

            If SC5->C5_EMISSAO >= MV_PAR03 .AND. SC5->C5_EMISSAO <= MV_PAR04  .and. SC5->C5_CLIENTE >= MV_PAR05 .AND. SC5->C5_CLIENTE <= MV_PAR06
                If MV_PAR07 == 1
                    If  !Empty(SC5->C5_LIBEROK) .And. Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_BLQ)
                        ImpCabe(oPrint)
                        impitens(oPrint)
                        Improda(oPrint)
                    EndIF
                Elseif MV_PAR07 == 2
                    If   Empty(SC5->C5_LIBEROK).And.Empty(SC5->C5_NOTA).And.Empty(SC5->C5_BLQ)//Status em verdeÃ
                        ImpCabe(oPrint)
                        impitens(oPrint)
                        Improda(oPrint)
                    EndIF
                Else
                    ImpCabe(oPrint)
                    impitens(oPrint)
                    Improda(oPrint)
                EndIF
            EndIf
        Endif

        SC5->(dbskip())
    EndDo
    
    SC5->( DBClearFilter())
    SC5->( DbGoTop() )
    
    oPrint:EndPage()     //finaliza a página
    oPrint:Preview()     //visualiza antes de imprimir

    RestArea(aArea)
Return nil

//----------------------------
//imprime cabeçalho
//----------------------------
Static Function ImpCabe(oPrint)

    Local aArea		:=	GetArea()
    Local cTpPed	:= ""
    local cLogo 	:= '\system\kapazi_logo.bmp' //FisxLogo("1")
    // dados do codigo de barras linha e coluna do codigo de barras
    Local cTypeBar	:= "CODE128"        // tipo codigo de barras
    Local nRow		:= 2.3			    // Linha que será impresso o Código de Barra
    Local nCol		:= 16	            // Coluna que será impresso o Código de Barra
    Local cCode		:= SC5->C5_NUM      // codigo de barrras	
    Local lCheck	:= .F.		        // calcula digito verificador
    Local nColor	:= Nil				// cor do codigo de barras
    Local lHort		:= .T.				// impressao horizontal
    Local nWidth	:= 0.025 * 1.2	    // Numero do Tamanho da barra. Default 0.025 limite de largura da etiqueta é 0.0164
    Local nHeigth  	:= 1.5   * 1.2      // Numero da Altura da barra. Default 1.5 --- limite de altura é 0.3
    Local lBanner	:= .F.				// Se imprime a linha com o código embaixo da barra. Default .T.
    Local cFont	    := "Courier New"
    Local cMode		:= "A"				// modo de impressao code 128 c = compacto
    Local lPrint	:= .f.				// utiliza print do objeto pai
    Local nPFWidth	:= nil				// Número do índice de ajuste da largura da fonte. Default 1
    Local nPFHeigth	:= nil				// Número do índice de ajuste da altura da fonte. Default 1

    // se a resolucao vertival maior que 4000 -> impressoras
    // se menor -> PDF
    If oPrint:nVertRes() > 4000
        // divide o posicionamento por 2
        nRow := nRow / 2
        // divide o posicionamento por 2
        nCol := nCol / 2
    Endif

    // imprime o codigo de barras
    MsBar3(cTypeBar,nRow,nCol,cCode,@oPrint,lCheck,nColor,lHort,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth)
    
    // inicia uma nova página
    oPrint:StartPage()   

    nRow1 := 100

    //cabeçalho
    oPrint:SayBitmap(nRow1 ,0200,cLogo,0400,0136 )
    oPrint:Say  (nRow1,700,SM0->M0_NOMECOM,oFont16n)
    nRow1+=050
    oPrint:Say  (nRow1,700,alltrim(SM0->M0_ENDCOB)+" - "+alltrim(SM0->M0_BAIRCOB),oFont14)
    nRow1+=050
    oPrint:Say  (nRow1,700,TRANSFORM(SM0->M0_CEPCOB,"@R 99999-999")+"  "+AllTrim(SM0->M0_CIDCOB)+" - "+SM0->M0_ESTCOB,oFont14)
    nRow1+=050


    oPrint:Say  (nRow1,700,"Email: kapazi@kapazi.com.br",oFont14)
    nRow1+=050

    oPrint:Say  (nRow1,700,"Cnpj: " + TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99" ),oFont14)
    nRow1+=050
    oPrint:Say  (nRow1,700,"Site: www.kapazi.com.br",oFont14)

    dbSelectArea("SA1")
    DBSEEK(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)

    nRow1+=150
    oPrint:Say  (nRow1,100,"Destinatário/Remetente",oFont14)

    nRow1+=050
    oPrint:Say  (nRow1,100,alltrim(SA1->A1_NOME) +" - "+SC5->C5_CLIENTE+SC5->C5_LOJACLI,oFont14n)
    oPrint:Say  (nRow1,1900,"Pedido de Venda",oFont16)

    nRow1+=050
    oPrint:Say  (nRow1,100,alltrim(SA1->A1_END)+" - "+alltrim(SA1->A1_BAIRRO),oFont14n)
    oPrint:Say  (nRow1,1990,SC5->C5_NUM,oFont16n)

    // _cSitLib := u_fX3Cbox("C5_XSITLIB",sc5->c5_xsitlib)
    
    If !Empty(AllTrim(SC5->C5_XSITLIB))
        _cSitLib := Tabela("ZD",SC5->C5_XSITLIB)
    Else
        _cSitLib := ""
    Endif

    oPrint:Say  (nRow1+50,1990,_cSitLib,oFont16n)

    nRow1+=050
    oPrint:Say  (nRow1,100,TRANSFORM(SA1->A1_CEP,"@R 99999-999")+" - " + ALLTRIM(SA1->A1_MUN) + " - " + SA1->A1_EST,oFont14n)
    nRow1+=050

    If SA1->A1_PESSOA <> 'F'
        oPrint:Say  (nRow1,100,'CNPJ: '+TRANSFORM(SA1->A1_CGC,"@R 99.999.999/9999-99" )+" I.E: "+ALLTRIM(SA1->A1_INSCR) ,oFont14n)
    Else
        oPrint:Say  (nRow1,100,'CPF: '+TRANSFORM(SA1->A1_CGC,"@R 999.999.999-99" ),oFont14n)
    Endif

    nRow1+=050
    oPrint:Say  (nRow1,100,'E-mail: ' + SA1->A1_EMAIL,oFont14N)

    nRow1+=050
    oPrint:Say  (nRow1,100,"("+AllTrim(SA1->A1_DDD)+") "+TRANSFORM(SA1->A1_TEL,"@R 99999-9999"),oFont14N)


    nRow1+=050
    oPrint:Say  (nRow1,100,"Emissao:",oFont14)
    oPrint:Say  (nRow1,260,dTOc(SC5->C5_EMISSAO),oFont14N)
    nRow1+=050

    oPrint:Say  (nRow1,100,"Transp.:",oFont14)
    TranspNM := posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME")
    oPrint:Say  (nRow1,260,(SC5->C5_TRANSP +" - " +TranspNM),oFont14N)
    nRow1+=050

    cTpPed := ""
    If SC5->(FieldPos("C5_XTPPED")) > 0 .and. ChkFile("SZE") .and. !Empty(AllTrim(SC5->C5_XTPPED))
        SZE->(DbSetOrder(1))
        If SZE->( MsSeek(xFilial("SZE")+SC5->C5_XTPPED))
            cTpPed := AllTrim(SC5->C5_XTPPED)
            cTpPed += " - "+AllTrim(SZE->ZE_DESCRIC)
        Endif
    Endif
    If !Empty(Alltrim(cTpPed))
        oPrint:Say  (nRow1,100,"Tp Ped. Prazo:",oFont14)
        oPrint:Say  (nRow1,360,cTpPed,oFont14n)
        nRow1+=050
    Endif

    if !Empty(SC5->C5_DTALTER)
        oPrint:Say  (nRow1,100,"Alterado :                            pelo usuário: ",oFont14)
        oPrint:Say  (nRow1,330, DTOC(SC5->C5_DTALTER),oFont14N)
        oPrint:Say  (nRow1,760,ALLTRIM(SC5->C5_USER) ,oFont14N)
        nRow1+=050
    Endif

    nRow1+=050
    cPagto := posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_DESCRI")
    oPrint:Say  (nRow1,100,"Forma de pagamento:",oFont14)
    oPrint:Say  (nRow1,480,ALLTRIM(cPagto),oFont14N)

    nRow1+=050
    cRepr := posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME")
    oPrint:Say  (nRow1,100,"Representante: ",oFont14)
    oPrint:Say  (nRow1,400, ALLTRIM(cRepr),oFont14N)


    nRow1+=0100
    oPrint:Say  (nRow1,100,"Detalhamento dos Produtos",oFont14)
    nRow1+=050
	//oPrint:Line (nRow1  ,0100,nRow1  ,2300)
	//oPrint:Line (nRow1+5,0100,nRow1+5,2300)

    RestArea(aArea)
Return

//-------------------
//impressão dos itens
//-------------------
Static Function Impitens(oPrint)
    Local cEndPick	:= ""
    Local nColItem	:= 100 
    Local nColProd	:= 200 - 10 
    Local nColDesc	:= 650 - 100 - 10 - 30
    Local nColUnd	:= 1500 - 100 - 180 - 10 - 30
    Local nColQtde	:= 1600 - 100 - 180 - 10 - 30
    Local nColVUni	:= 1800 - 100 - 180 - 10 - 30
    Local nColTotal	:= 1950 - 100 - 180 - 10 - 30
    Local nColObs	:= 2200 - 100 - 180 - 40 - 30
    Local nColEnd	:= 2200 - 100 - 180 + 380 - 30 - 30
    Local aArea		:= GetArea()

    nRow1+=050
    oPrint:Say  (nRow1,nColItem ,"Item" 					,oFont14n)
    oPrint:Say  (nRow1,nColProd ,"Código" 					,oFont14n)
    oPrint:Say  (nRow1,nColDesc ,"Desrição do Produto" 		,oFont14n)
    oPrint:Say  (nRow1,nColUnd	,"Und." 					,oFont14n)
    oPrint:Say  (nRow1,nColQtde	,"Qtd." 					,oFont14n)
    IF MV_PAR08 == 1
        oPrint:Say  (nRow1,nColVUni	,"V.Unit."				,oFont14n)
        oPrint:Say  (nRow1,nColTotal,"V.Total"				,oFont14n)
        //oPrint:Say  (nRow1,2150 ,"IPI(%)" 					,oFont14n)
    EndIf
    oPrint:Say  (nRow1,nColObs ,"Obs.Produto"				,oFont14n)
    oPrint:Say  (nRow1,nColEnd ,"Endereço"      			,oFont14n)
    nItem  	:= 0
    nQtd   	:= 0
    nTotal  := 0
    _nTotIPI:= 0   //arfs
    //INCLUIDO
    _nTotSt	:= 0

    SC6->(dbSelectArea("SC6"))
    SC6->(DBSeek(xFilial("SC6")+SC5->C5_NUM))

    While !SC6->(eof()) .AND. SC6->C6_NUM == SC5->C5_NUM .and. SC6->C6_FILIAL == XFilial("SC6")

        cEndPick := ""

        If Localiza(SC6->C6_PRODUTO)
            SBZ->( DbSetOrder(1) )
            If SBZ->( MsSeek(xFilial("SBZ")+SC6->C6_PRODUTO))
                if !Empty(AllTrim(SBZ->BZ_XPICKIN))
                    cEndPick := AllTrim(SBZ->BZ_XPICKIN)
                Endif
            Endif
        Endif
        nRow1 	+= 050
        
        nItem ++
        cProd 	:= ALLTRIM(SC6->C6_DESCRI)
        cUm 	:= Posicione('SB1', 1, XFilial('SB1') + SC6->C6_PRODUTO, 'B1_UM')
        cSegUm 	:= Posicione('SB1', 1, XFilial('SB1') + SC6->C6_PÕRODUTO, 'B1_SEGUM')
        cTpConv := Posicione('SB1', 1,XFilial('SB1') + SC6->C6_PRODUTO, 'B1_TIPCONV')
        nConv 	:= Posicione('SB1', 1, XFilial('SB1') + SC6->C6_PRODUTO, 'B1_CONV')
        // define as larguras
        if !Empty(SC6->C6_XLARG) .and. !Empty(SC6->C6_XCOMPRI)
            cProd := AllTrim(cProd) + " " + AllTrim(Transform(SC6->C6_XLARG, "@E 9999.99")) + " X " + AllTrim(Transform(SC6->C6_XCOMPRI, "@E 9999.99"))
        endIf

        // verifica se o faturamento é pela quantidade de peças
        if SC6->C6_K_TPFAT == "2"
            // verifica se o produto possui 2ª UM cadastrada
            if Empty(ALLTRIM(cSegUm)) .or. ALLTRIM(cUm) == "M2"
                // produto não possui 2ª UM, aplica pela quantidade de peças
                nQtd1 	:= SC6->C6_XQTDPC
                nQtd 	+= nQtd1
                nValUnit:= (SC6->C6_VALOR / nQtd1)
                nValTot := SC6->C6_VALOR
                nTotal 	+= nValTot
                cUm 	:= cSegUm
            else
                // produto possui 2ª UM, faz a conversão
                if cTpConv == "M"
                    // aplica o fator multiplicação
                    nQtd1 	:= Round(SC6->C6_QTDVEN * nConv, 4)
                    nQtd 	+= nQtd1
                    nValUnit:= Round(SC6->C6_VALOR / nQtd1, 4)
                    nValTot := SC6->C6_VALOR
                    nTotal 	+= nValTot
                    cUm 	:= cSegUm
                else
                    // aplica o fator divisão
                    nQtd1 	:= Round(SC6->C6_QTDVEN / nConv, 4)
                    nQtd 	+= nQtd1
                    nValUnit:= Round(SC6->C6_VALOR / nQtd1, 4)
                    nValTot := SC6->C6_VALOR
                    nTotal 	+= nValTot
                    cUm 	:= cSegUm
                endIf
            endIf
        else
            // fatura pela 1ª UM
            nQtd1 	:= SC6->C6_QTDVEN
            nQtd 	+= SC6->C6_QTDVEN
            nValTot := SC6->C6_VALOR
            nValUnit:= SC6->C6_PRCVEN
            nTotal 	+= nValTot
        endIf

        oPrint:Say  (nRow1,nColItem ,SC6->C6_ITEM					,oFonAri8)
        oPrint:Say  (nRow1,nColProd ,SC6->C6_PRODUTO				,oFonAri8)

        oPrint:Say  (nRow1,nColUnd , cUm	,oFonAri8)
        oPrint:Say  (nRow1,nColQtde,Transform(nQtd1,"@E 999,999.99"),oFonAri8)

        IF MV_PAR08 == 1
            oPrint:Say  (nRow1,nColVUni,Transform(nValUnit,"@E 999,999.99")	,oFonAri8)
            oPrint:Say  (nRow1,nColTotal,Transform(nValTot,"@E 999,999.99")	,oFonAri8)
            //oPrint:Say  (nRow1,2150 ,TRANSFORM(Posicione('SBZ',1,xFilial('SBZ')+SC6->C6_PRODUTO,'BZ_IPI'),"@E 99.99"),oFonAri8)
        EndIf
        oPrint:Say(nRow1,nColObs ,ALLTRIM(SC6->C6_X_OBSPR)  		,oFonAri8)
//        oPrint:Say(nRow1,nColObs ,ALLTRIM(Substr(cProd,1,TamSx3("C6_X_OBSPR")[1]))		,oFonAri8)
        oPrint:Say(nRow1,nColEnd ,cEndPick             			    ,oFonAri8)

        // faz a quebra da descrição do produto
        cAux := cProd
        while !Empty(cAux)

            // imprime o texto do produto
            oPrint:Say(nRow1, nColDesc, SubStr(cAux, 1, SpaceAt(cAux, 35)), oFonAri8)
            cAux := AllTrim(Substr(cAux, SpaceAt(cAux, 35) + 1))

            // proxima linha
            if !Empty(cAux)
                // salta a linha
                nRow1 += 050
            endIf

            if nRow1 > 3000

                // quebra a página
                oPrint:EndPage()
                oPrint:StartPage()
                nRow1 := 200
                oPrint:Say  (nRow1,nColItem ,"Item" 					,oFont14n)
                oPrint:Say  (nRow1,nColProd ,"Código" 					,oFont14n)
                oPrint:Say  (nRow1,nColDesc ,"Desrição do Produto" 		,oFont14n)
                oPrint:Say  (nRow1,nColUnd  ,"Und." 					,oFont14n)
                oPrint:Say  (nRow1,nColQtde ,"Qtd." 					,oFont14n)
                IF MV_PAR08 == 1
                    oPrint:Say  (nRow1,nColVUni,"V.Unit."				,oFont14n)
                    oPrint:Say  (nRow1,nColTotal ,"V.Total"				,oFont14n)
                    //oPrint:Say  (nRow1,2150 ,"IPI(%)" 					,oFont14n)
                EndIf
                oPrint:Say  (nRow1,nColObs ,"Obs.Produto"				,oFont14n)
                oPrint:Say  (nRow1,nColEnd ,"Endereço"                  ,oFont14n)
            endIf
        endDo

        if nRow1 > 3000
            oPrint:EndPage()
            oPrint:StartPage()
            nRow1 := 100
            oPrint:Say  (nRow1,nColItem ,"Item" 					,oFont14n)
            oPrint:Say  (nRow1,nColProd ,"Código" 					,oFont14n)
            oPrint:Say  (nRow1,nColDesc ,"Desrição do Produto" 		,oFont14n)
            oPrint:Say  (nRow1,nColUnd  ,"Und." 					,oFont14n)
            oPrint:Say  (nRow1,nColQtde ,"Qtd." 					,oFont14n)
            IF MV_PAR08 == 1
                oPrint:Say  (nRow1,nColVUni ,"V.Unit."				,oFont14n)
                oPrint:Say  (nRow1,nColTotal,"V.Total"				,oFont14n)
                //oPrint:Say  (nRow1,2150 ,"IPI(%)" 					,oFont14n)
            EndIf
            oPrint:Say  (nRow1,nColObs ,"Obs.Produto"		    	,oFont14n)
            oPrint:Say  (nRow1,nColEnd ,"Endereço"                  ,oFont14n)
        EndIF
        SC6->(dbSkip())
    End
    nRow1+=200
    oPrint:Say  (nRow1,100 , CVALTOCHAR(nItem),oFont14n)
    oPrint:Say  (nRow1,200 , " Item(ns)" 		,oFont14)
    oPrint:Say  (nRow1,400 , CVALTOCHAR(nQtd) ,oFont14n)
    oPrint:Say  (nRow1,650 , " Peça(s)" 	    ,oFont14)
    IF MV_PAR08 == 1
        oPrint:Say  (nRow1,1700 ,'Total dos Produtos:' ,oFont14)
        oPrint:Say  (nRow1,2100 ,TRANSFORM(ntotal,"@E 999,999,999.99")		,oFont14n)
    EndIf

    RestArea(aArea)
Return

//----------------------------
//imprime rodapé
//----------------------------
Static Function Improda(oPrint)

    Local aArea		:=	GetArea()
    Local _nI		:= 0
    aImp := U_CalcImp(SC5->C5_NUM)


    IF MV_PAR08 == 1
        nRow1+=200
        oPrint:Say  (nRow1,100 , 'Totalizacao do Pedido:',oFont14n)
        oPrint:Say  (nRow1,1700 , 'Total dos Produtos: ',oFont14n)
        oPrint:Say  (nRow1,2100 ,  TRANSFORM(ntotal,"@E 999,999,999.99"),oFont14n)

        IF SC5->C5_FRETE >0
            nRow1+=050
            oPrint:Say  (nRow1,1700 , 'Frete: ',oFont14n)
            oPrint:Say  (nRow1,2100 ,  TRANSFORM(SC5->C5_FRETE,"@E 999,999,999.99"),oFont14n)
        EndIF

        IF aImp[2] >0
            nRow1+=050
            oPrint:Say  (nRow1,1700 , 'IPI: ',oFont14n)
            oPrint:Say  (nRow1,2100 ,  TRANSFORM(aImp[2],"@E 999,999,999.9999"),oFont14n)
        EndIF

        IF aImp[1] >0
            nRow1+=050
            oPrint:Say  (nRow1,1700 , 'ST: ',oFont14n)
            oPrint:Say  (nRow1,2100 ,  TRANSFORM(aImp[1],"@E 999,999,999.9999"),oFont14n)
        EndIF

        IF SC5->C5_DESPESA >0
            nRow1+=050
            oPrint:Say  (nRow1,1700 , 'Despesas: ',oFont14n)
            oPrint:Say  (nRow1,2100 ,  TRANSFORM(SC5->C5_DESPESA,"@E 999,999,999.99"),oFont14n)
        EndIF

        //nRow1+=050
        //oPrint:Say  (nRow1,2100 , TRANSFORM(aImp[3],"@E 999,999,999.9999"),oFont14n)
        //nRow1+=050
        //oPrint:Say  (nRow1,2100 ,  TRANSFORM(aImp[4],"@E 999,999,999.9999"),oFont14n)

        nRow1+=050
        ngeral:= ntotal+SC5->C5_FRETE+SC5->C5_SEGURO+SC5->C5_DESPESA + aImp[1] + aImp[2]

        oPrint:Say  (nRow1,1700 , 'Total Geral do pedido: ',oFont14n)
        oPrint:Say  (nRow1,2100 ,  TRANSFORM(ngeral,"@E 999,999,999.99"),oFont14n)
    EndIf
    nRow1+=200


    oPrint:Say  (nRow1,100 , 'Tipo de Frete: '+IF(SC5->C5_TPFRETE=='C','CIF',IF(SC5->C5_TPFRETE=='F','FOB','')),oFont14)
    nRow1+=050
    IF nRow1 > 3000
        oPrint:EndPage()
        oPrint:StartPage()
        nRow1:=100
    EndIF
    oPrint:Say  (nRow1,100 , 'Observações',oFont14)
    cmen := SC5->C5_MSGCLI
//nTam := MlCount(cmen,117)
    nTam := MlCount(cmen,80)
    for _nI := 1 to nTam
        nRow1+=050
        IF nRow1 > 3000
            oPrint:EndPage()
            oPrint:StartPage()
            nRow1:=100
        EndIF
//	oPrint:Say  (nRow1,100 , MemoLine(cmen, 117, _nI, 3),oFonAri8)
        oPrint:Say  (nRow1,100 , MemoLine(cmen, 81, _nI, 3),oFonAri8)
    next _nI
    IF nRow1 > 3000
        oPrint:EndPage()
        oPrint:StartPage()
        nRow1:=100
    EndIF
    nRow1+=050
    If !eMPTY(SA1->A1_SUFRAMA)
        oPrint:Say  (nRow1,100,'SUFRAMA: '+Alltrim(SA1->A1_SUFRAMA),oFont14)
        if SA1->A1_CALCSUF == 'S'
            oPrint:Say  (nRow1,100,'DESCONTO ICMS,PIS E COFINS',oFont14)
        EndIf
        if SA1->A1_CALCSUF == 'I'
            oPrint:Say  (nRow1,100,'DESCONTO ICMS',oFont14)
        EndIf
    EndIF
    IF MV_PAR08 == 1
        If !eMPTY(SC5->C5_NOTA)
            IF nRow1 > 3000
                oPrint:EndPage()
                oPrint:StartPage()
                nRow1:=100
            EndIF


            nRow1+=50
            oPrint:Say  (nRow1,100,'DADOS FATURAMENTO',oFont14N)
            nRow1+=50
            DBSELECTaREA('SF2')
            dbSeek(XFILIAL('SF2')+SC5->C5_NOTA+SC5->C5_SERIE)
            oPrint:Say  (nRow1,100,"Data: "+DTOC(SF2->F2_EMISSAO)+"                  Nun.NF:"+alltrim(SC5->C5_NOTA)+"   SERIE:"+SC5->C5_SERIE+"                   Valor: "+TRANSFORM(SF2->F2_VALFAT,"@E 999,999,999.99") ,oFont14)
        eNDiF
    EndIf
    oPrint:EndPage() 	//finaliza a página

    RestArea(aArea)
Return


    *----------------------------------------------------------------------------------
Static Function VALIDPERG()
    *----------------------------------------------------------------------------------
    local aRegs:={}

    *   1    2            3                4     5   6  7 8  9  10   11        12    13 14    15    16 17 18 19 20 21 22 23 24 25  26
    *+---------------------------------------------------------------------------------------------------------------------------------+
    *¦G    ¦ O  ¦ PERGUNT              ¦V       ¦T  ¦T ¦D¦P¦ G ¦V ¦V         ¦ D    ¦C ¦V ¦D       ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦F    ¦
    *¦ R   ¦ R  ¦                      ¦ A      ¦ I ¦A ¦E¦R¦ S ¦A ¦ A        ¦  E   ¦N ¦A ¦ E      ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦3    ¦
    *¦  U  ¦ D  ¦                      ¦  R     ¦  P¦MA¦C¦E¦ C ¦ L¦  R       ¦   F  ¦ T¦ R¦  F     ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦     ¦
    *¦   P ¦ E  ¦                      ¦   I    ¦  O¦NH¦ ¦S¦   ¦ I¦   0      ¦    0 ¦ 0¦ 0¦   0    ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦     ¦
    *¦    O¦ M  ¦                      ¦    AVL ¦   ¦ O¦ ¦E¦   ¦ D¦    1     ¦    1 ¦ 1¦ 2¦    2   ¦ 2¦3 ¦3 ¦ 3¦4 ¦4 ¦ 4¦5 ¦5 ¦ 5¦     ¦

    aadd(aRegs,{cPerg,"01","Pedido de                    :","mv_ch1","C",06,0,0,"G","","mv_par01","","12269","","","","","","","","","","","","","SC5"})
    aadd(aRegs,{cPerg,"02","Pedido até                   :","mv_ch2","C",06,0,0,"G","","mv_par02","","12269","","","","","","","","","","","","","SC5"})
    aadd(aRegs,{cPerg,"03","Emissao de                   :","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
    aadd(aRegs,{cPerg,"04","Emissao até                  :","mv_ch4","D",08,0,0,"G","","mv_par04","","20201230","","","","","","","","","","","","",""})
    aadd(aRegs,{cPerg,"05","Cliente de                   :","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SA1"})
    aadd(aRegs,{cPerg,"06","Cliente até                  :","mv_ch6","C",06,0,0,"G","","mv_par06","","ZZZZZZ","","","","","","","","","","","","","SA1"})
    aadd(aRegs,{cPerg,"07","Status                       :","mv_ch7","C",01,0,0,"C","","mv_par07","Liberado","","","Bloqueado","","","Ambos","","","","","","","",""})
    aadd(aRegs,{cPerg,"08","Imprime Valores              :","mv_ch8","C",01,0,0,"C","","mv_par08","Sim","","","Não","","","","","","","","","","",""})
    aadd(aRegs,{cPerg,"09","Lib Kapazi                   :","mv_ch9","C",01,0,0,"C","","mv_par09","Liberados","","","Bloqueados","","","Faturados","","","Todos","","","","",""})

    u__fAtuSx1(padr(cPerg,len(sx1->x1_grupo)),aRegs)
Return

static function SpaceAt( cTexto, nPosFim )

    // variaveis auxiliares
    local nResult := nPosFim
    local nPosAtu := 0

    // ajusta a posição fim
    if nPosFim > Len(cTexto)
        nResult := Len(cTexto)
        return nResult
    endIf

    nPosAtu := nPosFim
    while nPosAtu > 0

        // verifica se localizou o espaço
        if Substr(cTexto, nPosAtu, 1) == " "
            nResult := nPosAtu
            Exit
        endIf

        // decrementa a posicao atual
        nPosAtu--

    endDo

    if nPosAtu == 0
        nPosAtu := nPosFim
    endIf

return nResult