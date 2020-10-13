#INCLUDE "TOTVS.CH"

#DEFINE PROXIMA_LINHA	CHR(13)+CHR(10)
#DEFINE TITULO_JANELA   "ETQ018RI"

/*
Reimpressão da etique 018 e 012
*/

User Function ETQ018RI()	
	Local  aArea 		:= GetArea()

	Local cOrdemProducao	:= ""	
	Local cProduto			:= ""
	Local cDescricaoProduto := ''	
	Local cLote   			:= ''	
	Local cPeso   			:= ''
	Local cCodET2			
	Local QRCODE			:= ""	
	Local cModelo
	Local cPorta 			:= NIL
	Local cFila 
	Local cEnv
	Local cServer

	Local dDataValidade := CB0->CB0_DTVLD
	Local dData1		:= FIRSTYDATE(dDataBase)
	Local dData2		:= dDataBase
	
	Local nSemana 		:= 0
	Local nDias			:= (dData2-dData1)+1
	Local nY	   		:= 0
	Local nPontoMM 		:= 0
	Local nQuantidade	:= 0
	Local nPortIP

	Local xImpressora	:= ""
	Local xQuant		:= ""

	Local lSubProduto 	:= .F.	
	Local lTipo

	cOrdemProducao  := CB0->CB0_OP
	cProduto  		:= CB0->CB0_CODPRO
	cLote  			:= CB0->CB0_LOTE
	nQuantidade  	:= CB0->CB0_QTDE
	xImpressora   	:= Posicione("ZIA",1,xFilial("ZIA")+"013","ZIA_IMPPAD")
	lRImp  			:= .F.
    lSubProduto   	:= .F.
	lDataValidade	:= .F.
	cArmazem		:= CB0->CB0_LOCAL
    dDataProducao   := STOD("")

	dbSelectArea("SB1")
    dbSetOrder(1)
    dbSeek(xFilial("SB1")+cProduto)

	dbSelectArea("SB5")
	dbSetOrder(1)
	dbSeek(xfilial("SB5")+cProduto)

	cDescricaoProduto 	:= AllTrim(SB1->B1_DESC)
	dDataValidade  		:= DTOC(dDataValidade)
	cLote   			:= cLote
	cPeso   			:= StrZero(SB1->B1_XPEMB,4)
	xQuant				:= AllTrim(Transform(IIF(SB5->B5_QEI > 0 ,SB5->B5_QEI,1),PesqPict("SB5","B5_QEI")))

	IF Empty(xImpressora)
		MsgInfo("Nenhuma impressora padrão definida",TITULO_JANELA)
		Return(.F.)
	EndIF         
		
	IF .NOT. CB5->(dbSeek(xFilial("CB5")+xImpressora))
		MsgInfo("Nenhuma impressora localizada na tabela CB5",TITULO_JANELA)
		Return(.F.)
	EndIF
	cModelo :=Trim(CB5->CB5_MODELO)
	IF cPorta ==NIL
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
	
	//calculo semana
	IF (nDias/7)>int(nDias/7)
		nSemana:=int(nDias/7)+1
	ELSE
		nSemana:=int(nDias/7)
	EndIF
		
	TEXTO:={}
		
	//INICIO  
	IF xImpressora="000001" .OR. xImpressora="000002"  
		aAdd(TEXTO,"^JMB^FS"+PROXIMA_LINHA)    
	EndIF

	MSCBPRINTER(cModelo,cPorta,,,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH))
	MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")
       
	IF .NOT. Empty(cOrdemProducao)
		QRCODE := '(01)' + AllTrim(CB0->CB0_CODPRO) + '(10)' + AllTrim(cLote) + '(21)' + AllTrim(cProduto) + '(17)' + DTOS(CTOD(dDataValidade)) + '(90)' + AllTrim(cProduto) + '(91)' + SB1->B1_XCODEXT + '(99)' + AllTrim(CB0->CB0_CODET2)
	EndIF

	MSCBBEGIN(1,6)  
	MSCBModelo('DPL',cModelo,@nPontoMM)

	nXPixel	:= nPontoMM *IF(25==NIL,0,20)
	nYPixel := nPontoMM *IF(5==NIL,0,5)
	nXPixel := Strzero(val(str(nXPixel,5,3))*100,4)
	nYPixel := strzero(val(str(nYPixel,5,3))*100,4)

	TEXTO:={}

	aAdd(TEXTO,"<STX>KcDE300" +PROXIMA_LINHA)
	aAdd(TEXTO,"D11" +PROXIMA_LINHA)
	IF nPontoMM == 0.03937008
		aAdd(TEXTO,"1W1D55000"+nXPixel+nYPixel+"2HM,"+QRCODE+PROXIMA_LINHA) //300DPI
	ELSE
		aAdd(TEXTO,"1W1D33000"+nXPixel+nYPixel+"2HM,"+QRCODE+PROXIMA_LINHA) //200DPI
	EndIf
			
	aAdd(TEXTO,"E" +PROXIMA_LINHA)

	MSCBSAY(40,40,"LOTE: " 		+ cLote					,"N","3","1,1")
	MSCBSAY(40,35,"VALIDADE: " 	+ dDataValidade			,"N","3","1,1")
	MSCBSAY(40,30,"SEMANA: " 	+ AllTrim(Str(nSemana))	,"N","3","1,1")
	MSCBSAY(40,25,"QTDE: " 		+ xQuant				,"N","3","1,1")
	MSCBSAY(40,20,"COD.PROD.: " + AllTrim(cProduto)		,"N","3","1,1")

	cProd := AllTrim(cDescricaoProduto)
	cTamFontIn := 4
	nLeft   := 6
	nRight  := 75
	nTop    := 16
	nBottom := 2
	IF (Len(cProd)*cTamFontIn) > nRight - nLeft
		nTamMax := (nRight - nLeft)/(cTamFontIn*0.45)
	    nLin    := mlcount(cProd,nTamMax)
		nPos := nTop -1
		nPosIni := nPos
		For nY := 1 to nLin
			nPos := (nPos - (nPosIni - nBottom)/nLin)
			IF nPos == nBottom
				MSCBSAY(nLeft,nPos,memoline(cProd,nTamMax,nY)     ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
			ELSE
				MSCBSAY(nLeft,nPos,memoline(cProd,nTamMax,nY)     ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
			EndIF
		Next
	ELSE
		nPos := nTop - 1
		MSCBSAY(nLeft,nPos,cProd    ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
	EndIF

    For nY := 1 To Len(TEXTO)
		MSCBWRITE(TEXTO[nY])     
	Next nY

	MSCBEND()  

	MSCBCLOSEPRINTER() //Finaliza a impressão

	RestArea(aArea)

Return(NIL)