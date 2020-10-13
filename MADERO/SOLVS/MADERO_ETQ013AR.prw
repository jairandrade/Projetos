#INCLUDE 'TOTVS.CH'

#DEFINE NEXT_LINE Chr(13)+Chr(10)
#DEFINE TITULO_JANELA   "ETQ013AR"

User Function ETQ013AR(nCopia,cImp,cType,lDocFis,lInspCust,cTipo)
    Local aArea     := GetArea()
    Local cModelo   :="" 
    Local lTipo     :=.F.
    Local nPortIP   :=0
    Local cServer   :=""
    Local cEnv      :=""
    Local cFila     :=""
    Local cPorta    :=Nil
    Local nx        :=0
    Local nPontoMM  :=0
    Local QRCODE    :="" 
    Local cCondTXt  :=""
    Local nQtde     := CB0->CB0_QTDE
    Local cCodSep   := NIL
    Local nCopias   := nCopia
    Local cNFEnt    := CB0->CB0_NFENT
    Local cSeriee   := CB0->CB0_SERIEE
    Local cFornec   := CB0->CB0_FORNEC
    Local cLojaFo   := CB0->CB0_LOJAFO
    Local cDescFor  := IF(.NOT. Empty(cFornec),Posicione("SA2",1,xFilial("SA2")+cFornec+cLojafo,"A2_NREDUZ"),"")
    //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
    Local dDigit    := CB0->CB0_DTNASC
    Local cLote     := CB0->CB0_LOTE
    Local dValid    := CB0->CB0_DTVLD

    IF Empty(dValid)
        dValid := STOD('')
    EndIF

    SB1->(dbSetOrder(1))
    SB1->(dbSeek(xFilial("SB1")+CB0->CB0_CODPRO))
    cTipo   := SB1->B1_TIPO
    IF(cTipo=="P")
        dDigit := STOD("")
    EndIF

    // -> Carrega dados da CB0, caso exista
    //cLocOri:=IF(cLocOri == cArmazem,""   ,cLocOri)
    nCopias:=IF(cType    $ "Pallet/Caixa",1,nQtde)
    cCodSep:=IF(cCodSep == NIL,"",cCodSep)

    // -> Verifica impressora
    cImp:=IIF(AllTrim(cImp)=="",GetMV("MV_IACD02"),cImp)
    IF .NOT. CB5->(dbSeek(xFilial("CB5")+cImp))
        MsgStop("Ops... A impressora "+cImp+" não foi encontrada na tabela CB5." + NEXT_LINE + "Verifique o cadastro de impressoras...",TITULO_JANELA)
        Return(.F.)
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
        
    nBuffer := CB5->CB5_BUFFER
    lDrvWin := (CB5->CB5_DRVWIN =="1")
                    
    // -> Inicia a geração da etiqueta
    MSCBPRINTER(cModelo,cPorta,,,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH))
    MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")
            
    cPrdRest:=U_ETQ013P(CB0->CB0_CODPRO)

    QRCODE := '(99)' + AllTrim(CB0->CB0_CODET2) + '(10)' + AllTrim(cLote) + '(01)' + AllTrim(SB1->B1_COD) + '(17)' + AllTrim(DtoS(dValid))  + '(90)' + AllTrim(cPrdRest) + '(91)' + AllTrim(SB1->B1_XCODEXT) + '(21)' + AllTrim(CB0->CB0_CODPRO)
                                    
    MSCBBEGIN(nCopia,6)
    MSCBModelo('DPL',cModelo,@nPontoMM)
                
    nXPixel:=nPontoMM *IF(15==NIL,0,15)
    nYPixel:=nPontoMM *IF(5==NIL,0,5)
    nXPixel:=StrZero(Val(Str(nXPixel,5,3))*100,4)
    nYPixel:=StrZero(Val(Str(nYPixel,5,3))*100,4)

    MSCBSAY(IF(Empty(cCondTXt),33,20),46,"MADERO","N","4","1,1")
    MSCBLineH(05,44,87,2,"B")

    aTexto:={}
    aAdd(aTexto,"<STX>KcDE300" +NEXT_LINE)
    aAdd(aTexto,"D11" +NEXT_LINE)
    IF nPontoMM == 0.03937008
        aAdd(aTexto,"1W1D55000"+nXPixel+nYPixel+"2HM,"+QRCODE+NEXT_LINE) //300DPI
    ELSE
        aAdd(aTexto,"1W1D33000"+nXPixel+nYPixel+"2HM,"+QRCODE+NEXT_LINE) //200DPI
    EndIF
    aAdd(aTexto,"E" +NEXT_LINE)

    MSCBLineH(05,10,87,2,"B")
    MSCBSAY(40,39,"LOTE: "+cLote,"N","3","1,1")
    MSCBSAY(40,34,"VALIDADE: "+DTOC(dValid),"N","3","1,1")
    MSCBSAY(40,29,"QTDE: "+ Transform(nQtde, PesqPict("SD1","D1_QUANT")),"N","3","1,1")
    MSCBSAY(40,24,"UN: "+SB1->B1_UM,"N","3","1,1")
    MSCBSAY(40,19,"FORN: "+AllTrim(cDescFor),"N","3","1,1")
    MSCBSAY(06,5,AllTrim(SB1->B1_COD)+"-"+SubStr(AllTrim(SB1->B1_DESC),1,35),"N","3","1,1")
    MSCBSAY(06,0,"DATA RECEB: "+DTOC(dDigit),"N","2","1,1")
    MSCBSAY(43,0,"No. NF: "+AllTrim(cNFEnt)+"/"+AllTrim(cSeriee),"N","2","1,1")

    For nx := 1 To Len(aTexto)
        MSCBWRITE(aTexto[nx])     
    Next nx

    MSCBEND() 
    MSCBCLOSEPRINTER()    

    RestArea(aArea)

Return()