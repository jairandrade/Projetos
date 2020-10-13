#INCLUDE "TOTVS.CH"

/*
Impressão da etique 019
*/

User Function ETQ019(aETQAuto)	
    Local aArea   		 := GetArea()

	Local cPerg			 		:= "ETQ019    "
	Local cOrdemProducao 		:= ""
	Local cProduto   	 		:= ""
	Local cTipoEtiqueta			:= "019"
	Local cDescricaoProduto 	:= ""
	Local cIngredientes			:= ""
	Local cAlergicos   			:= ""
	Local cGluten  				:= ""
	Local cLote    				:= ""
	Local cSIF     				:= ""
	Local cDescricaoCientifica  := ""
	Local cPesoE   				:= ""
	Local cRecomendacaoConsumo	:= ""
	Local cConsumo    			:= ""
	Local cModelo			 
	Local cServer
	Local cEnv
	Local cFila
	Local cPorta    			:= NIL
	local cArmazem				:= ""

	Local dDataValidade
	Local dDataProducao

	Local nQuantidade	:= 0
	Local nPortIP
	Local nI         	:= 0
	
	Local xImpressora := ""	
	
	Local lRet    	  := .T.
	Local lRImp   	  := .F.
    Local lSubProduto := .F.
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
		MsgInfo("Etiqueta não Cadastrada para este Produto!!","ETQ019")
		lRet:=.F.
	ELSEIF !lRImp
		IF Empty(nQuantidade)
			nQuantidade:=0
		EndIF
		nQuantidade:=nQuantidade*ZIB->ZIB_QTDE
	EndIF

	IF lRet
        dbSelectArea("SB1")
        dbSetOrder(1)
        dbSeek(xFilial("SB1")+cProduto)
		
		dbSelectArea("SB5")
		dbSetOrder(1)
		dbSeek(xfilial("SB5")+cProduto)
        
		cDescricaoProduto      	:= IIF(.NOT. Empty(SB1->B1_PACAMAP),AllTrim(Posicione("SX5",1,xFilial("SX5")+"Z6"+SB1->B1_PACAMAP,"X5_DESCRI")),SB1->B1_DESC)
		dDataProducao      		:= DTOC(dDataProducao)
		dDataValidade			:= DTOC(dDataValidade)
		cIngredientes			:= AllTrim(MSMM(SB1->B1_CODPROC))
		cConsumo      			:= IIF(.NOT. Empty(SB1->B1_XCONS),AllTrim(Posicione("SX5",1,xFilial("SX5")+"W1"+SB1->B1_XCONS,"X5_DESCRI")),"")
		cAlergicos     			:= IIF(.NOT. Empty(SB1->B1_XALERG),AllTrim(Posicione("SX5",1,xFilial("SX5")+"W2"+SB1->B1_XALERG,"X5_DESCRI")),"")
		cGluten    				:= IIF(SB1->B1_XGLUT="1","CONTÉM GLUTEN",IIF(SB1->B1_XGLUT="2","NÃO CONTÉM GLUTEN",""))
		cLote      				:= Alltrim(Str(Val(cLote)))
		cDescricaoCientifica    := AllTrim(SB5->B5_CEME)
		cSIF       				:= "Registro no Ministério da Agricultura SIF/DIPOA sob No." + SB5->B5_DES
		cPesoE     				:= AllTrim(Transform(SB1->B1_XPEMB,PesqPict("SB1","B1_XPEMB"))) + SB1->B1_UM
		cRecomendacaoConsumo	:= "Recomendações para consumo: Produto exclusivo para preparo nas filiais do " + AllTrim(SM0->M0_NOME) + ", conforme procedimentos operacionais padrão estabelecido para cada produto, respeitando tempo e temperatura."

		IF Empty(xImpressora)
			MsgInfo("Nenhuma impressora padrão definida","ETQ019")
			Return .F.
		EndIF         
		
		IF .NOT. CB5->(dbSeek(xFilial("CB5")+xImpressora))
			MsgInfo("Nenhuma impressora localizada na tabela CB5","ETQ019")
			Return .F.
		EndIf
		cModelo :=Trim(CB5->CB5_MODELO)
		IF cPorta ==NIL
			IF CB5->CB5_TIPO == "4"
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
		lTipo   := CB5->CB5_TIPO $ '12'
		nPortIP := Val(CB5->CB5_PORTIP)
		cServer := Trim(CB5->CB5_SERVER)
		cEnv    := Trim(CB5->CB5_ENV)
		cFila   := NIL

		IF CB5->CB5_TIPO == "3"
			cFila := Alltrim(Tabela("J3",CB5->CB5_FILA,.F.))
		EndIF   

		nBuffer := CB5->CB5_BUFFER
		lDrvWin := (CB5->CB5_DRVWIN =="1")

		TEXTO:={}

		MSCBPRINTER(cModelo,cPorta,,,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH)+"\ETQ002")
		MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")

		MSCBBEGIN(nQuantidade,6, 127.8)  

		/*---------------------------------BOX01---------------------------------------------*/     
		nLeft   := 05   //Margem em milímetros a esquerda
		nBottom := 110  //Margem em milímetros do topo
		nRight  := 95   //Margem em milímetros a direita
		nTop    := 120  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 2 //Tamanho Fonte Titulo

		cTitle          := AllTrim(cDescricaoProduto)    //String Titulo
		cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "CENTER") //Calcula posicao inicio titulo - CENTRO
		MSCBSAY(cInitTitle,115.5,cTitle     ,"N",cValToChar(nFTitle),"1,1")   //Imprime Titulo

		cTitle          := AllTrim(cDescricaoCientifica)                     //String Subtitulo
		cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "CENTER") //Calcula posicao inicio titulo - CENTRO
		MSCBSAY(cInitTitle,nBottom+1,cTitle     ,"N",cValToChar(nFTitle),"1,1")   //Subtitulo
		/*---------------------------------FIM BOX01-----------------------------------------*/      


		/*---------------------------------BOX02.01---------------------------------------------*/                        
		nLeft   := 05   //Margem em milímetros a esquerda
		nBottom := 100   //Margem em milímetros do topo
		nRight  := 45   //Margem em milímetros a direita
		nTop    := 109  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 3 //Tamanho Fonte Descricão

		cTitle			:= "DATA PRODUCAO/EMBALAGEM"     
		cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "CENTER")    //Calcula posicao inicio titulo - ESQUERDA

		nPos := (nTop - ((nTop - nBottom)/2))+1.5
		MSCBSAY(cInitTitle,nPos,cTitle,"N",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc 			:= AllTrim(dDataProducao)
		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "CENTER")
		nPos := nBottom + 1
		MSCBSAY(cInitTitle,nPos,cDesc,"N",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX03.01-----------------------------------------*/

		/*---------------------------------BOX02.02---------------------------------------------*/                        
		nLeft   := 46 //Margem em milímetros a esquerda
		nBottom := 100  //Margem em milímetros do topo
		nRight  := 74   //Margem em milímetros a direita
		nTop    := 109  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 3 //Tamanho Fonte Descricão

		cTitle 			:= "DATA DE VALIDADE:" 
		cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA

		nPos := (nTop - ((nTop - nBottom)/2))+1.5
		MSCBSAY(cInitTitle,nPos,cTitle     ,"N",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc 			:= AllTrim(dDataValidade)
		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "CENTER")
		nPos := nBottom + 1
		MSCBSAY(cInitTitle,nPos,cDesc     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX03.02-----------------------------------------*/

		/*---------------------------------BOX02.03---------------------------------------------*/                        
		nLeft   := 75   //Margem em milímetros a esquerda
		nBottom := 100  //Margem em milímetros do topo
		nRight  := 95   //Margem em milímetros a direita
		nTop    := 109  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 3 //Tamanho Fonte Descricão

		cTitle 			:= "LOTE:"
		cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "CENTER")    //Calcula posicao inicio titulo - ESQUERDA
		nPos := (nTop - ((nTop - nBottom)/2))+1.5
		MSCBSAY(cInitTitle,nPos,cTitle     ,"N",cValToChar(nFTitle),"1,1")     //Titulo


		cDesc 			:= AllTrim(cLote)
		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "CENTER")
		nPos := nBottom + 1
		MSCBSAY(cInitTitle,nPos,cDesc,"N",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX03.03-----------------------------------------*/

		/*---------------------------------BOX04.01---------------------------------------------*/                        
		nLeft   := 05   //Margem em milímetros a esquerda
		nBottom := 90  //Margem em milímetros do topo
		nRight  := 45   //Margem em milímetros a direita
		nTop    := 99  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 3 //Tamanho Fonte Descricão

		cTitle 			:= "PESO DA EMBALAGEM:"
		cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "CENTER")    //Calcula posicao inicio titulo - ESQUERDA

		nPos := (nTop - ((nTop - nBottom)/2))+1.5
		MSCBSAY(cInitTitle,nPos,cTitle,"N",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc 			:= AllTrim(cPesoE)
		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "CENTER")
		nPos := nBottom + 1
		MSCBSAY(cInitTitle,nPos,cDesc,"N",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX04.01-----------------------------------------*/

		/*---------------------------------BOX04.02---------------------------------------------*/                        
		nLeft   := 46  //Margem em milímetros a esquerda
		nBottom := 90  //Margem em milímetros do topo
		nRight  := 95   //Margem em milímetros a direita
		nTop    := 99  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 1 //Tamanho Fonte Descricão

		cTitle 			:= "MODO DE CONSERVACAO:"
		cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "CENTER")    //Calcula posicao inicio titulo - ESQUERDA

		nPos := (nTop - ((nTop - nBottom)/2))+1.5
		MSCBSAY(cInitTitle,nPos,cTitle     ,"N",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc 			:= AllTrim(cConsumo)
		cInitTitle      := CalcInit(cDesc,nFTitle,nLeft, nRight, "CENTER")    //Calcula posicao inicio titulo - ESQUERDA

		If (Len(cDesc)*nFDesc) > nRight - nLeft
			nTamMax := (nRight - nLeft)/(nFDesc*0.5)
			nLin    := mlcount(cDesc,nTamMax)
			nPosIni := nPos
			For nI := 1 to nLin
				nPos := (nPos - (nPosIni - nBottom)/nLin)
				If nPos == nBottom 
					MSCBSAY(cInitTitle,nPos+1,memoline(cDesc,nTamMax,nI)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
				Else
					MSCBSAY(cInitTitle,nPos,memoline(cDesc,nTamMax,nI)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
				EndIf
			Next
		Else
			nPos := nBottom + 1
			MSCBSAY(cInitTitle,nPos,cDesc    ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
		EndIf

		/*---------------------------------FIM BOX04.02-----------------------------------------*/

		/*---------------------------------BOX05---------------------------------------------*/                        
		nLeft   := 05   //Margem em milímetros a esquerda
		nBottom := 77  //Margem em milímetros do topo
		nRight  := 95   //Margem em milímetros a direita
		nTop    := 89  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFDesc          := 2 //Tamanho Fonte Descricão

		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA

		cDesc := AllTrim(cRecomendacaoConsumo)

		If (Len(cDesc)*nFDesc) > nRight - nLeft
			nTamMax := (nRight - nLeft)/(nFDesc*0.6)
			nLin    := mlcount(cDesc,nTamMax)
			nPos    := nTop
			For nI := 1 to nLin
				nPos := (nPos - (nTop - nBottom)/nLin)
				If nPos == nBottom 
					MSCBSAY(cInitTitle,nPos+0.6,memoline(cDesc,nTamMax,nI)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
				Else
					MSCBSAY(cInitTitle,nPos,memoline(cDesc,nTamMax,nI)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
				EndIf
			Next
		Else
			nPos    := nTop - (((nTop - nBottom)/3)*3)
			MSCBSAY(cInitTitle,nPos,cDesc    ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
		EndIf

		/*---------------------------------FIM BOX05-----------------------------------------*/

		/*---------------------------------BOX06---------------------------------------------*/                        
		nLeft   := 05   //Margem em milímetros a esquerda
		nBottom := 71  //Margem em milímetros do topo
		nRight  := 95   //Margem em milímetros a direita
		nTop    := 74  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          
		//MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFDesc          := 2 //Tamanho Fonte Descricão

		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "LEFT")    //Calcula posicao inicio titulo - ESQUERDA

		cDesc 			:= AllTrim(cSIF)

		MSCBSAY(cInitTitle,nBottom + 0.1,cDesc     ,"N",cValToChar(nFDesc),"1,1")   //Imprime Titulo


		/*---------------------------------FIM BOX06-----------------------------------------*/

		/*---------------------------------BOX07---------------------------------------------*/                        
		nLeft   := 60   //Margem em milímetros a esquerda
		nBottom := 0  //Margem em milímetros do topo
		nRight  := 99   //Margem em milímetros a direita
		nTop    := 10  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          
		//MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFDesc          := 2 //Tamanho Fonte Descricão

		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "LEFT")    //Calcula posicao inicio titulo - ESQUERDA

		cDesc 			:= AllTrim(cGluten)

		MSCBSAY(cInitTitle,nBottom + 0.1,cDesc     ,"N",cValToChar(nFDesc),"1,1")   //Imprime Titulo


		/*---------------------------------FIM BOX07-----------------------------------------*/
		MSCBEND()  


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

	aAdd(aSX1,{"ETQ019","01","Ordem de Producao?"	,""			,""		,"MV_CH1","C",TamSX3("D3_OP")[1]     ,0  ,0   ,"G" ,""  ,"MV_PAR01",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","","SC2ETQ"	,"S","","","",""})
	aAdd(aSX1,{"ETQ019","02","Produto?"	   			,""			,""		,"MV_CH2","C",TamSX3("D3_COD")[1],0  ,0   ,"G" ,""  ,"MV_PAR02",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","","SB1"	,"S","","","",""})
	aAdd(aSX1,{"ETQ019","03","Lote?"		   		,""			,""		,"MV_CH3","C",TamSX3("C2_XLOTE")[1]  ,0  ,0   ,"G" ,""  ,"MV_PAR03",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","",""		,"S","","","",""})
	aAdd(aSX1,{"ETQ019","04","Qtde Etiqueta?"		,""			,""		,"MV_CH4","N",04                     ,0  ,0   ,"G" ,""  ,"MV_PAR04",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","",""		,"S","","","",""})
	aAdd(aSX1,{"ETQ019","05","Impressora?"			,""			,""		,"MV_CH5","C",TamSX3("CB5_CODIGO")[1],0  ,0   ,"G" ,""  ,"MV_PAR05",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","","CB5"	,"S","","","",""})

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

Static Function CalcInit(cTitle,nFontSize,nLeft, nRight, cPosition)
	Local nInit := 0

	DO CASE
		CASE UPPER(cPosition) == "CENTER"
		IF nFontSize == 3
			nInit := nLeft + (((nRight - nLeft)-Len(cTitle)*2)/2)
		ELSEIF nFontSize == 2
			nInit := nLeft +  (((nRight - nLeft)-Len(cTitle)*1.6)/2)
		ELSEIF nFontSize == 1
			nInit := nLeft +  (((nRight - nLeft)-Len(cTitle)*1.1)/2)
		EndIF
		CASE UPPER(cPosition) == "LEFTBOX"
			nInit := nLeft + 2
		CASE UPPER(cPosition) == "LEFT"
			nInit := nLeft + 0.5
		OTHERWISE
			nInit := nLeft + 0.5
	ENDCASE
Return nInit