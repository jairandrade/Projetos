#INCLUDE "TOTVS.CH"

#DEFINE PROXIMA_LINHA	CHR(13)+CHR(10)

/*
Impressão da etique 018
*/

User Function ETQ018(aETQAuto)	
	Local  aArea 		:= GetArea()

	Local cPerg 			:= "ETQ018    "
	Local cOrdemProducao	:= ""	
	Local cProduto			:= ""
	Local cTipoEtiqueta		:= "018"
	Local cDescricaoProduto := ''	
	Local cLote   			:= ''	
	Local cPeso   			:= ''
	Local cCodET2			
	Local cQRCODE			:= ""	
	Local cModelo
	Local cPorta 			:= NIL
	Local cFila 
	Local cEnv
	Local cServer

	Local dDataValidade
	Local dData1		:= FIRSTYDATE(dDataBase)
	Local dData2		:= dDataBase
	
	Local nSemana 		:= 0
	Local nDias			:= (dData2-dData1)+1
	Local nY	   		:= 0
	Local nPontoMM 		:= 0
	Local nX			:= 0 
	Local nQuantidade	:= 0
	Local nPortIP

	Local xImpressora	:= ""
	Local xQuant		:= ""
	
	Local lRet			:= .T.
	Local lSubProduto 	:= .F.	
	Local lTipo

	DEFAULT aETQAuto := NIL

	AjustaSX1()

	IF .NOT. aETQAuto == NIL
		cOrdemProducao  :=aETQAuto[1][1]
		cProduto  		:=aETQAuto[1][2]
		cLote  			:=aETQAuto[1][3]
		nQuantidade  	:=aETQAuto[1][4]
		xImpressora   	:=aETQAuto[1][5]
		lRImp  			:=aETQAuto[1][6]
        lSubProduto   	:=aETQAuto[1][7]
		dDataValidade	:=aETQAuto[1][8]
		cArmazem		:=aETQAuto[1][9]
        dDataProducao   :=aETQAuto[1][10]
	ELSE
		IF Pergunte(cPerg,.T.)
			cOrdemProducao  :=MV_PAR01
			cProduto		:=MV_PAR02
			cLote			:=MV_PAR03
			nQuantidade		:=MV_PAR04
			xImpressora 	:=MV_PAR05
		ELSE
			lRet:=.F.
		EndIF
	EndIF
	
    dbSelectArea("ZIB")
	dbSetOrder(1)
	ZIB->(dbSeek(xFilial("ZIB")+cProduto+cTipoEtiqueta))
	IF .NOT. ZIB->(Found())
		MsgInfo("Etiqueta não Cadastrada para este Produto!!","ETQ018")
		lRet:=.F.
	ELSEIF !lRImp
		IF Empty(nQuantidade)
			nQuantidade:=0
		EndIF
		nQuantidade:=nQuantidade*ZIB->ZIB_QTDE
	EndIF

	If lRet
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
			MsgInfo("Nenhuma impressora padrão definida","ETQ018")
			Return .F.
		EndIF         
		
		IF .NOT. CB5->(dbSeek(xFilial("CB5")+xImpressora))
			MsgInfo("Nenhuma impressora localizada na tabela CB5","ETQ018")
			Return .F.
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

		cCodigo := CBGrvEti('01',{cProduto,nQuantidade,,,,,,,,cArmazem,cOrdemProducao,,,,,cLote,,CTOD(dDataValidade),,,,,,,})

		dbSelectArea("CB0")
		CB0->(dbSetOrder(1))
		CB0->(dbSeek(xFilial("CB0")+cCodigo))
		cCodET2 := Upper(FWUUIDV4())

		RecLock("CB0", .F.)
		CB0->CB0_CODET2 := cCodET2
		CB0->(MsUnLock())

		IF .NOT. Empty(cOrdemProducao)
			cQRCODE := '(01)' + AllTrim(CB0->CB0_CODPRO) + '(10)' + AllTrim(cLote) + '(21)' + AllTrim(cProduto) + '(17)' + DTOS(CTOD(dDataValidade)) + '(90)' + AllTrim(cProduto) + '(91)' + SB1->B1_XCODEXT + '(99)' + AllTrim(cCodET2)
		EndIF

		For nX := 1 To nQuantidade 

			MSCBBEGIN(1,6)  

			MSCbModelo('DPL',cModelo,@nPontoMM)

			nXPixel	:= nPontoMM *if(25==NIL,0,20)
			nYPixel := nPontoMM *if(5==NIL,0,5)
			nXPixel := Strzero(val(str(nXPixel,5,3))*100,4)
			nYPixel := strzero(val(str(nYPixel,5,3))*100,4)

			TEXTO:={}

			aAdd(TEXTO,"<STX>KcDE300" +PROXIMA_LINHA)
			aAdd(TEXTO,"D11" +PROXIMA_LINHA)
			If nPontoMM == 0.03937008
				aAdd(TEXTO,"1W1D55000"+nXPixel+nYPixel+"2HM,"+cQRCODE+PROXIMA_LINHA) //300DPI
			Else
				aAdd(TEXTO,"1W1D33000"+nXPixel+nYPixel+"2HM,"+cQRCODE+PROXIMA_LINHA) //200DPI
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
			If (Len(cProd)*cTamFontIn) > nRight - nLeft
				nTamMax := (nRight - nLeft)/(cTamFontIn*0.45)
				nLin    := mlcount(cProd,nTamMax)
				nPos := nTop -1
				nPosIni := nPos
				For nY := 1 to nLin
					nPos := (nPos - (nPosIni - nBottom)/nLin)
					If nPos == nBottom
						MSCBSAY(nLeft,nPos,memoline(cProd,nTamMax,nY)     ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
					Else
						MSCBSAY(nLeft,nPos,memoline(cProd,nTamMax,nY)     ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
					EndIf
				Next
			Else
				nPos := nTop - 1
				MSCBSAY(nLeft,nPos,cProd    ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
			EndIf


			For nY := 1 To Len(TEXTO)
				MSCBWRITE(TEXTO[nY])     
			Next nY

			MSCBEND()  
		Next nX

		MSCBCLOSEPRINTER() //Finaliza a impressão
	Endif

	RestArea(aArea)

Return(NIL)

Static Function AjustaSX1()
	Local aSX1   := {}
	Local aEstrut:= {}

	Local nI     := 0
	Local nJ	 := 0

	Local lSX1	 := .F.

	aEstrut	:= 	{	"X1_GRUPO"  ,"X1_ORDEM"  ,"X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO"   ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL",;
					"X1_GSC"    ,"X1_VALID"  ,"X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01"  ,"X1_VAR02"  ,"X1_DEF02"  ,;
					"X1_DEFSPA2","X1_DEFENG2","X1_CNT02"  ,"X1_VAR03" ,"X1_DEF03"  ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03"  ,"X1_VAR04"  ,"X1_DEF04",;
					"X1_DEFSPA4","X1_DEFENG4","X1_CNT04"  ,"X1_VAR05" ,"X1_DEF05"  ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05"  ,"X1_F3"     ,"X1_PYME","X1_GRPSXG",;
					"X1_HELP","X1_PICTURE","X1_IDFIL"}

	aAdd(aSX1,{"ETQ018","01","Ordem de Producao?"	,""			,""		,"MV_CH1","C",TamSX3("D3_OP")[1]     ,0  ,0   ,"G" ,""  ,"MV_PAR01",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","","SC2ETQ"	,"S","","","",""})
	aAdd(aSX1,{"ETQ018","02","Produto?"	   			,""			,""		,"MV_CH2","C",TamSX3("D3_COD")[1],0  ,0   ,"G" ,""  ,"MV_PAR02",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","","SB1"	,"S","","","",""})
	aAdd(aSX1,{"ETQ018","03","Lote?"		   		,""			,""		,"MV_CH3","C",TamSX3("C2_XLOTE")[1]  ,0  ,0   ,"G" ,""  ,"MV_PAR03",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","",""		,"S","","","",""})
	aAdd(aSX1,{"ETQ018","04","Qtde Etiqueta?"		,""			,""		,"MV_CH4","N",04                     ,0  ,0   ,"G" ,""  ,"MV_PAR04",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","",""		,"S","","","",""})
	aAdd(aSX1,{"ETQ018","05","Impressora?"			,""			,""		,"MV_CH5","C",TamSX3("CB5_CODIGO")[1],0  ,0   ,"G" ,""  ,"MV_PAR05",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","","CB5"	,"S","","","",""})

	ProcRegua(Len(aSX1))

	dbSelectArea("SX1")
	dbSetOrder(1)
	For nI:= 1 To Len(aSX1)
		IF .NOT. Empty(aSX1[nI][1])

			IF .NOT. dbSeek( Padr( aSX1[nI,1] , Len( X1_GRUPO ) , ' ' ) + aSX1[nI,2] )

				lSX1 := .T.
				RecLock("SX1",.T.)

				For nJ:=1 To Len(aSX1[nI])
					IF .NOT. Empty(FieldName(FieldPos(aEstrut[nJ])))
						FieldPut(FieldPos(aEstrut[nJ]),aSX1[nI,nJ])
					EndIF
				Next nJ

				dbCommit()
				MsUnLock()
				IncProc("Atualizando Perguntas Etiquetas....")
			EndIF
		EndIF
	Next nI
Return