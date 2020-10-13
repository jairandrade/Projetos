#INCLUDE 'TOTVS.CH'

#DEFINE NEXT_LINE Chr(13)+Chr(10)
#DEFINE TITULO_JANELA   "ETQ013RI"

User Function ETQ013RI(cID,cType)
    Local aArea     := GetArea()
    Local nQtde     := 1
    Local cImp      := Posicione("ZIA",1,xFilial("ZIA")+"013","ZIA_IMPPAD")
    Local cModelo   := ""
    Local nXPixel   := 0
    Local nyPixel   := 0
    Local nX        := 0
    Local nPontoMM  := 0
    Local QRCODE    := "" 
    Local aTexto    := {}
    Local cCondTXt	:= ""
    Local cPrdRest  := ""
    Local cID       := ""

    //#TB20191203 Thiago Berna - Ajuste para verificar se imprimie o texto SIF
    Local lSIF      := .F.

    // -> Verifica impressora
    cImp:=IIF(AllTrim(cImp)=="",GetMV("MV_IACD02"),cImp)
    IF .NOT. CB5->(dbSeek(xFilial("CB5")+cImp))
        MsgStop("Ops... A impressora "+cImp+" não foi encontrada na tabela CB5." + NEXT_LINE + "Verifique o cadastro de impressoras...",TITULO_JANELA)
        Return(.F.)
    EndIF

	// -> Posiciona no fornecedor 
	SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial("SA2")+CB0->CB0_FORNEC+CB0->CB0_LOJAFO))
    IF .NOT. SA2->(Found())
	    MsgStop("Ops... Fornecedor não cadastrado na tabela SA2 -> " + CB0->CB0_FORNEC+CB0->CB0_LOJAFO + " !",TITULO_JANELA)
        Return(.F.)
    EndIF

	// -> Posiciona no produto
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+CB0->CB0_CODPRO))
	IF .NOT. SB1->(Found())
        MsgStop("Ops... Produto não cadastrado na tabela SB1 -> " + CB0->CB0_CODPRO + "!",TITULO_JANELA)
        Return(.F.)
	EndIF

    //#TB20191203 Thiago Berna - Ajuste para verificar se imprimie o texto SIF
    dbSelectArea('QE8')
    QE8->(dbSetOrder(1))
    IF QE8->(dbSeek(xFilial('QE8') + CB0->CB0_CODPRO))
        IF AllTrim(QE8->QE8_ENSAIO) == 'TP001' // FRIGORIFICO
            lSIF := .T.
        EndIF
    EndIF

    // -> Carrega dados da impressora
    cModelo :=Trim(CB5->CB5_MODELO)
    IF CB5->CB5_TIPO == '4'
        cPorta:= "IP"
    ELSE
        IF CB5->CB5_PORTA $ "12345"
            cPorta  :='COM'+CB5->CB5_PORTA+':'+CB5->CB5_SETSER
        EndIF
        IF CB5->CB5_LPT $ "12345"
            cPorta  :='LPT'+CB5->CB5_LPT
        EndIF
    EndIF

    lTipo   :=CB5->CB5_TIPO $ '12'
    nPortIP :=Val(CB5->CB5_PORTIP)
    cServer :=Trim(CB5->CB5_SERVER)
    cEnv    :=Trim(CB5->CB5_ENV)
    cFila   := NIL            
    IF CB5->CB5_TIPO=="3"
        cFila := Alltrim(Tabela("J3",CB5->CB5_FILA,.F.))
    EndIF
    cModelo :=Trim(CB5->CB5_MODELO)
    nBuffer := CB5->CB5_BUFFER
    lDrvWin := (CB5->CB5_DRVWIN =="1")
            
    // -> Inicia a geração da etiqueta
    MSCBPRINTER(cModelo,cPorta,,,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH))
    MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")

    // -> Busca codigo do produto restaurante
    cPrdRest:=U_ETQ013P(CB0->CB0_CODPRO)
    QRCODE  := '(99)' + AllTrim(CB0->CB0_CODET2) + '(10)' + AllTrim(CB0->CB0_LOTE) + '(01)' + AllTrim(CB0->CB0_CODPRO) + '(17)' + AllTrim(DtoS(CB0->CB0_DTVLD))  + '(90)' + AllTrim(cPrdRest) + '(91)' + AllTrim(SB1->B1_XCODEXT) + '(21)' + AllTrim(CB0->CB0_CODPRO)

    MSCBBEGIN(nQtde,6)
    MSCBModelo('DPL',cModelo,@nPontoMM)
    nXPixel    := nPontoMM *IF(15==NIL,0,15)
    nyPixel    := nPontoMM *IF(5==NIL,0,5)
    nXPixel    := Strzero(val(str(nXPixel,5,3))*100,4)
    nyPixel    := strzero(val(str(nyPixel,5,3))*100,4)

    aTexto:={}
    Do Case
        Case ZI3->ZI3_CONDIC=="R"
            cCondTXt := " - REPROVADO"
        Case ZI3->ZI3_CONDIC=="Q
            cCondTXt := " - QUARENTENA"
        Case ZI3->ZI3_CONDIC=="A"
            cCondTXt := " - APROVADO"
        OtherWise
            cCondTXt := ""
    EndCase

    MSCBSAY(IF(Empty(cCondTXt),33,20),46,"MADERO"+cCondTXt,"N","4","1,1")
    MSCBLineH(05,44,87,2,"B")

    aAdd(aTexto,"<STX>KcDE300" +NEXT_LINE)
    aAdd(aTexto,"D11" +NEXT_LINE)
    IF nPontoMM == 0.03937008
        aAdd(aTexto,"1W1D55000"+nXPixel+nyPixel+"2HM,"+QRCODE +NEXT_LINE) //300DPI
    ELSE
        aAdd(aTexto,"1W1D33000"+nXPixel+nyPixel+"2HM,"+QRCODE +NEXT_LINE) //200DPI
    EndIF
    aAdd(aTexto,"E" +NEXT_LINE)
    MSCBLineH(05,10,87,2,"B")
        
    IF lSIF
        dbSelectArea("ZI1")
        dbSetOrder(1)
        IF dbSeek(xFilial("ZI1")+CB0->CB0_NFENT+CB0->CB0_SERIEE+CB0->CB0_FORNEC+CB0->CB0_LOJAFO)
            cID := ZI1->ZI1_ID
            dbSelectArea("ZI4")
            dbSetOrder(1)
            IF dbSeek(xFilial("ZI4")+cID+CB0->CB0_CODPRO)    
                MSCBSAY(40,39,"SIF: "+ZI4->ZI4_SIF,"N","3","1,1")
            EndIF
        EndIF        
    EndIF
    MSCBSAY(40,34,"VALIDADE: "+DTOC(CB0->CB0_DTVLD),"N","3","1,1")
    MSCBSAY(40,29,"QTDE: "+Transform(CB0->CB0_QTDE,"@E 9,999,999.9999"/*PesqPict("CB0","CB0_QTDE")*/),"N","3","1,1")
    MSCBSAY(40,24,"UN: "+SB1->B1_UM,"N","3","1,1")
    MSCBSAY(40,19,"FORN: "+AllTrim(SA2->A2_NREDUZ),"N","3","1,1")
    MSCBSAY(40,14,"LOTE: ",CB0->CB0_LOTE,"3","1,1")
    MSCBSAY(3,5,AllTrim(SB1->B1_COD)+"-"+SubStr(AllTrim(SB1->B1_DESC),1,35),"N","3","1,1")
    MSCBSAY(3,0,"DATA RECEB: "+DTOC(CB0->CB0_DTNASC),"N","2","1,1")
    MSCBSAY(43,0,"N NF: "+AllTrim(CB0->CB0_NFENT)+"/"+AllTrim(CB0->CB0_SERIEE),"N","2","1,1")
        
    For nX := 1 To Len(aTexto)
        MSCBWRITE(aTexto[nX])     
    Next nX
        
    MSCBEND() 
    MSCBCLOSEPRINTER()

    RestArea(aArea)

Return()