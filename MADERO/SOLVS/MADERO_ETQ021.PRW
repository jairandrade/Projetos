#INCLUDE "TOTVS.CH"

/*
Impress„o da etique 021
*/

User Function ETQ021(aETQAuto)
	Local  aArea 	:= GetArea()
	
	Local cPerg 					:= "ETQ021    "
	Local cOrdemProducao			:= ""
	Local cProduto					:= ""
	Local cTipoEtiqueta				:= "021" 
	Local cDescricaoProduto    		:= ""
	Local cIngredientes  			:= ""
	Local cInformacoesNutricionais	:= ""
	Local cConsumo   				:= ""
	Local cGluten  					:= ""
	Local cLote   					:= ""
	Local cPesoE    				:= ""
	Local cSIF						:= ""
	Local cInfComp1					:= "DESTINADO EXCLUSIVAMENTE AO USO INSTITUCIONAL"
	Local cInfComp2					:= "PROIBIDA A VENDA NO VAREJO"
	Local cInfComp3					:= "PROIBIDA A VENDA FRACIONADA"
	Local cInfComp4					:= "INDUSTRIA BRASILEIRA"
	Local cInfComp5					:= "PRODUZIDO POR: " + AllTrim(SM0->M0_NOMECOM)
	Local cInfComp6					:= "CNPJ "+Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC"))
	Local cInfComp7					:= AllTrim(SM0->M0_ENDENT)+", "+ AllTrim(SM0->M0_BAIRENT)+", "+ AllTrim(SM0->M0_CIDENT) + "/" + SM0->M0_ESTENT
	Local cInfComp8					:= "CEP: "+SM0->M0_CEPENT
	Local cLactose 					:= ""
	Local cPorta 					:= NIL
	Local cFila
	Local cEnv
	Local cServer
	Local cModelo
	
	Local dDataProducao
	Local dDataValidade
	
	Local nQuantidade	:= 0 
	Local nY
	Local nPortIP
	
	Local xImpressora	:= ""
	
	Local lRet	:= .T.
	Local lRImp	:= .F.
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
		MsgInfo("Etiqueta n„o Cadastrada para este Produto!!","ETQ021")
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
        dbSeek(xFilial("SB5")+cProduto)

		cDescricaoProduto    		:= IIF(Empty(SB5->B5_CEME),AllTrim(SB1->B1_DESC),AllTrim(SB5->B5_CEME))
		dDataProducao      			:= DTOC(dDataProducao)
		dDataValidade     			:= DTOC(dDataValidade)
		cIngredientes    			:= AllTrim(MSMM(SB1->B1_CODPROC))
		cInformacoesNutricionais	:= ""+SubStr(AllTrim(Posicione("SB1",1,xFilial("SB1")+SB1->B1_COD,"B1_XINFNUT")),1,800)
		cConsumo      				:= IIF(.NOT. Empty(SB1->B1_XCONS),AllTrim(Posicione("SX5",1,xFilial("SX5")+"W1"+SB1->B1_XCONS,"X5_DESCRI")),"")
		cGluten    				  	:= IIF(SB1->B1_XGLUT="1","CONT…M GLUTEN",IIF(SB1->B1_XGLUT="2","N√O CONT…M GLUTEN",""))
		cLote      					:= AllTrim(Str(Val(cLote)))
		cPesoE     					:= AllTrim(Transform(SB1->B1_XPEMB,PesqPict("SB1","B1_XPEMB"))) + SB1->B1_UM
		//cSIF       					:= "Registro no MinistÈrio da Agricultura SIF/DIPOA sob No." + SB1->B1_XRMAPA
		cSIF       				:= "Registro no MinistÈrio da Agricultura SIF/DIPOA sob No." + SB5->B5_DES
		cLactose 					:= IIF(SB1->B1_XLACTOS="1","CONT…M LACTOSE",IIF(SB1->B1_XLACTOS="2","N√O CONT…M LACTOSE",""))

		IF Empty(xImpressora)
			MsgInfo("Nenhuma impressora padr„o definida","ETQ021")
			Return .F.
		EndIF
		
		IF .NOT. CB5->(dbSeek(xFilial("CB5")+xImpressora))
			MsgInfo("Nenhuma impressora localizada na tabela CB5","ETQ021")
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
			cFila := AllTrim(Tabela("J3",CB5->CB5_FILA,.F.))
		EndIF

		nBuffer := CB5->CB5_BUFFER
		lDrvWin := (CB5->CB5_DRVWIN =="1")

		MSCBPRINTER(cModelo,cPorta,,,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH)+"\ETQ021")
		MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")

		MSCBLOADGRF("\images\logoetiqueta.bmp")

		MSCBBEGIN(nQuantidade,6)

		MSCBGRAFIC(5,46,"logoetiqueta")
		cProd 		:= AllTrim(cDescricaoProduto)
		cTamFontIn 	:= 4
		nLeft   := 5
		nRight  := 80
		nTop    := 45
		nBottom := 35
		IF (Len(cProd)*cTamFontIn) > nRight - nLeft
			nTamMax := (nRight - nLeft)/(cTamFontIn*0.5)
			nLin    := mlcount(cProd,nTamMax)
			nPos := nTop -1
			nPosIni := nPos
			For nY := 1 To nLin
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

		cIngr := AllTrim(cIngredientes)
		cTamFontIn := 1
		nLeft   := 5
		nRight  := 80		
		nTop	:= 35
		nBottom	:= 30
		IF (Len(cIngr)*cTamFontIn) > nRight - nLeft
			nTamMax := (nRight - nLeft)/(cTamFontIn*0.8)
			nLin    := mlcount(cIngr,nTamMax)
			nPos := nTop -1
			nPosIni := nPos
			For nY := 1 to nLin
				nPos := (nPos - (nPosIni - nBottom)/nLin)
				If nPos == nBottom
					MSCBSAY(nLeft,nPos,memoline(cIngr,nTamMax,nY)     ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
				Else
					MSCBSAY(nLeft,nPos,memoline(cIngr,nTamMax,nY)     ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
				EndIf
			Next
		Else
			nPos := nTop - 1
			MSCBSAY(nLeft,nPos,cIngr    ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
		EndIf

		MSCBSAY(5,27,"MODO DE CONSERVACAO: ","N","1","1,1")
		MSCBSAY(30,27,AllTrim(cConsumo),"N","1","1,1")

		MSCBSAY(5,25,AllTrim(cGluten),"N","1","1,1")
		MSCBSAY(45,25,AllTrim(cLactose),"N","1","1,1")

		MSCBSAY(5,22,"DATA FABRICACAO: ","N","2","1,1")
		MSCBSAY(28,22,dDataProducao,"N","2","1,1")

		MSCBSAY(5,19,"DATA VALIDADE: ","N","2","1,1")
		MSCBSAY(25,19,dDataValidade,"N","2","1,1")

		MSCBSAY(45,19,"LOTE: ","N","4","1,1")
		MSCBSAY(60,19,cLote,"N","4","1,1")

		MSCBSAY(20,14,cInfComp1,"N","1","1,1")
		MSCBSAY(30,12,cInfComp2,"N","1","1,1")
		MSCBSAY(28,10,cInfComp3,"N","1","1,1")
		MSCBSAY(32,8,cInfComp4,"N","1","1,1")
		MSCBSAY(20,6,cInfComp5,"N","1","1,1")
		MSCBSAY(32,4,cInfComp6,"N","1","1,1")
		MSCBSAY(22,2,cInfComp7,"N","1","1,1")
		MSCBSAY(35,0,cInfComp8,"N","1","1,1")

		MSCBEND()
		MSCBCLOSEPRINTER() //Finaliza a impress√£o

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

	aAdd(aSX1,{"ETQ021","01","Ordem de Producao?"	,""			,""		,"MV_CH1","C",TamSX3("D3_OP")[1]     ,0  ,0   ,"G" ,""  ,"MV_PAR01",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","","SC2ETQ"	,"S","","","",""})
	aAdd(aSX1,{"ETQ021","02","Produto?"	   			,""			,""		,"MV_CH2","C",TamSX3("D3_COD")[1],0  ,0   ,"G" ,""  ,"MV_PAR02",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","","SB1"	,"S","","","",""})
	aAdd(aSX1,{"ETQ021","03","Lote?"		   		,""			,""		,"MV_CH3","C",TamSX3("C2_XLOTE")[1]  ,0  ,0   ,"G" ,""  ,"MV_PAR03",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","",""		,"S","","","",""})
	aAdd(aSX1,{"ETQ021","04","Qtde Etiqueta?"		,""			,""		,"MV_CH4","N",04                     ,0  ,0   ,"G" ,""  ,"MV_PAR04",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","",""		,"S","","","",""})
	aAdd(aSX1,{"ETQ021","05","Impressora?"			,""			,""		,"MV_CH5","C",TamSX3("CB5_CODIGO")[1],0  ,0   ,"G" ,""  ,"MV_PAR05",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","","CB5"	,"S","","","",""})

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