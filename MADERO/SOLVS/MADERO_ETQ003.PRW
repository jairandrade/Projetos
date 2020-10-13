#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! PCP - PRODUÇÃO                                          !
+------------------+---------------------------------------------------------+
!Nome              ! ETQ003                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina Emissão etiqueta 4 CM NAO ADESIVA NUTRICIONAL    !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 20/05/18                                                !
+------------------+---------------------------------------------------------+
*/
User Function ETQ003(aEtqAuto)
	Local  _aArea := GetArea()
	Local  _cperg :="ETQ003   "
	Local  _cOP:=""
	Local  _nQtde:=0
	Local  _cImp:=""
	Local  _cPROD:=""
	Local  _cTpEtq:="003" //Etiqueta 4 CM NÃO ADESIVA SIF
	Local  _lret:=.T.
	Local  _LRIMP:=.F.
	Local _nY       := 0
	Local _CDESC    := ''
	Local _dPROD    := ''
	Local _dVALID   := ''
	Local _cINGRED  := ''
	Local _CINFNUT  := ''
	Local _cLOTE    := ''
	Local _cCons    := ''
	Local _cAlerg   := ''
	Local _cGluten  := ''
	Local _CDESCD   := ''
	Local _CSIF     := ''
	Local _cPESOE   := ''
	Local _cRecoCons:= ''
	Local cModelo,lTipo,nPortIP,cServer,cEnv,cFila
	Local cPorta    := Nil
	
	DEFAULT aEtqAuto := NIL
		
	If !aEtqAuto == NIL
		_COP    :=aETQAuto[1]
		_CPROD  :=aETQAuto[2]
		_CLOTE  :=aETQAuto[3]
		_nQtde  :=aEtqAuto[4]
		_cImp   :=aEtqAuto[5]
		_lRIMP  :=aEtqAuto[6]

	Else
		IF Pergunte(_cPerg,.T.)
			_cOp  :=MV_PAR01
			_cProd:=MV_PAR02
			_clote:=MV_PAR03
			_nQtde:=MV_PAR04
			_cImp :=MV_PAR05
		ELSE
			_LRET:=.F.
		Endif
	EndIf

	DBSELECTAREA("ZIB")
	DBSETORDER(1)
	_LRET := ZIB->(DBSEEK(XFILIAL("ZIB")+_CPROD+_cTpEtq)) .And. (_lRIMP .Or. ZIB->ZIB_APONTA == "S")

	IF _LRET
		
		SC2->(dbSetOrder(1))
		IF !SC2->(MsSeek(xFilial("SC2")+_COP))
		
			MSGINFO("Ordem de Producao/Produto/Lote não Cadastrado !!!")
			_lret:=.F.
		ElseIf !_lRImp
			
			_nQtde := ZIB->ZIB_QTDE
		EndIf
	EndIf

	If _LRET

		_CDESC      := IIF(!Empty(SB1->B1_PACAMAP), ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"Z6"+SB1->B1_PACAMAP,"X5_DESCRI")),SB1->B1_XPADMAP)
		_dPROD      := DTOC(SC2->C2_XDTFIR)
		_dVALID     := DTOC(SC2->C2_XDTVAL)
		_cINGRED    := 'Ingredientes: '+ALLTRIM(MSMM(SB1->B1_CODPROC))
		_CINFNUT    := ""+ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+SB1->B1_COD,"B1_XINFNUT"))
		_cLOTE      := Alltrim(SC2->C2_XLOTE)
		_cCons      := IIF(!Empty(SB1->B1_XCONS), ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"W1"+SB1->B1_XCONS,"X5_DESCRI")), "")
		_cAlerg     := IIF(!Empty(SB1->B1_XALERG), ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"W2"+SB1->B1_XALERG,"X5_DESCRI")), "")
		_cGluten    := IIF(SB1->B1_XGLUT="1","CONTÉM GLUTEN",IIF(SB1->B1_XGLUT="2","NÃO CONTÉM GLUTEN",""))
		_CDESCD     := ALLTRIM(POSICIONE("SB5",1,XFILIAL("SB5")+SB1->B1_COD,"B5_CEME"))
		_CSIF       := "Registro no Ministério da Agricultura SIF/DIPOA sob No." + /*SB1->B1_XRMAPA*/POSICIONE("SB5",1,XFILIAL("SB5")+SB1->B1_COD,"B5_DES")
		_cPESOE     := alltrim(TRANSFORM(SB1->B1_XPEMB, PesqPict("SB1","B1_XPEMB"))) + /*SB1->B1_UM*/'KG'
		_cRecoCons  := "Recomendações para consumo: Produto exclusivo para preparo nas filiais do GRUPO MADERO, conforme procedimentos operacionais padrão estabelecido para cada produto, respeitando tempo e temperatura."

		If Empty(_CIMP)
			Return .f.
		EndIf
		//
		If ! CB5->(DbSeek(xFilial("CB5")+_CIMP))
			Return .f.
		EndIf
		cModelo :=Trim(CB5->CB5_MODELO)
		If cPorta ==NIL
			If CB5->CB5_TIPO == '4'
				cPorta:= "IP"
			Else
				IF CB5->CB5_PORTA $ "12345"
					cPorta  :='COM'+CB5->CB5_PORTA+':'+CB5->CB5_SETSER
				EndIf
				IF CB5->CB5_LPT $ "12345"
					cPorta  :='LPT'+CB5->CB5_LPT //+':'
				EndIf
			EndIf
		EndIf
		lTipo   :=CB5->CB5_TIPO $ '12'
		nPortIP :=Val(CB5->CB5_PORTIP)
		cServer :=Trim(CB5->CB5_SERVER)
		cEnv    :=Trim(CB5->CB5_ENV)
		cFila   := NIL

		If CB5->CB5_TIPO=="3"
			cFila := Alltrim(Tabela("J3",CB5->CB5_FILA,.F.))
		EndIf

		nBuffer := CB5->CB5_BUFFER
		lDrvWin := (CB5->CB5_DRVWIN =="1")


		MSCBPRINTER(cModelo,cPorta,,,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH)+"\ETQ003")
		MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")

		MSCBBEGIN(_nQtde,6, 127)

		/*---------------------------------BOX01---------------------------------------------*/
		nLeft   := 05   //Margem em milímetros a esquerda
		nBottom := 110  //Margem em milímetros do topo
		nRight  := 95   //Margem em milímetros a direita
		nTop    := 120  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 2 //Tamanho Fonte Titulo

		//cTitle          := ALLTRIM(_CDESC)    //String Titulo
		//cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "CENTER") //Calcula posicao inicio titulo - CENTRO
		//MSCBSAY(cInitTitle,115.5,cTitle     ,"N",cValToChar(nFTitle),"1,1")   //Imprime Titulo

		cTitle          := ALLTRIM(_CDESCD)                     //String Subtitulo
		cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "CENTER") //Calcula posicao inicio titulo - CENTRO
		MSCBSAY(cInitTitle,nBottom+1,cTitle     ,"N",cValToChar(nFTitle),"1,1")   //Subtitulo
		/*---------------------------------FIM BOX01-----------------------------------------*/ 


		/*---------------------------------BOX02 TESTE---------------------------------------------*/                        
		nLeft   := 05   //Margem em milímetros a esquerda
		nBottom := 102  //Margem em milímetros do topo
		nRight  := 83//95   //Margem em milímetros a direita
		nTop    := 109  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight+12,nTop,nExpess) //Monta Box

		nFDesc          := 1 //Tamanho Fonte Descricão

		cDesc := AllTrim(_cINGRED)
		
		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA

		If (Len(cDesc)*nFDesc) > nRight - nLeft
			nTamMax := (nRight - nLeft)/(nFDesc)
			nLin    := mlcount(cDesc,nTamMax)
			nPos    := nTop
			For _nY := 1 to nLin
				nPos := (nPos - (nTop - nBottom)/nLin)
				If nPos == nBottom 
					MSCBSAY(cInitTitle,nPos+0.6,memoline(cDesc,nTamMax,_nY)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
				Else
					MSCBSAY(cInitTitle,nPos,memoline(cDesc,nTamMax,_nY)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
				EndIf
			Next
		Else
			nPos    := nTop - (((nTop - nBottom)/3)*3)
			MSCBSAY(cInitTitle,nPos,cDesc    ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
		EndIf

		/*---------------------------------FIM BOX02 TESTE-----------------------------------------*/

		/*---------------------------------BOX02---------------------------------------------*/                        
		/*nLeft   := 05   //Margem em milímetros a esquerda
		nBottom := 102  //Margem em milímetros do topo
		nRight  := 95   //Margem em milímetros a direita
		nTop    := 109  //Margem em milímetros do final 
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 2 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descricão

		cDesc          := AllTrim(_cINGRED)//"INGREDIENTES: Carne suina, sal, alho, molho de pimenta, pimenta do reino, açúcar, conservantes, nitrito de sódio (INS250) e nitrato de sódio (INS251)"                      //String Subtitulo
		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA

		If (Len(cDesc)*nFDesc) > nRight - nLeft
			nTamMax := (nRight - nLeft)/(nFDesc*0.6)
			nLin    := mlcount(cDesc,nTamMax)
			nPos    := nTop
			For _nY := 1 to nLin
				nPos := (nPos - (nTop - nBottom)/nLin)
				If nPos == nBottom 
					MSCBSAY(cInitTitle,nPos+1,memoline(cDesc,nTamMax,_nY)     ,"N",cValToChar(nFDesc),"1")     //Subtitulo
				Else
					MSCBSAY(cInitTitle,nPos+0.5,memoline(cDesc,nTamMax,_nY)     ,"N",cValToChar(nFDesc),"1")     //Subtitulo
				EndIf
			Next
		Else
			nPos    := nTop - (((nTop - nBottom)/3)*2)
			MSCBSAY(cInitTitle,nPos,cDesc     ,"N",cValToChar(nFDesc),"1")     //Subtitulo
		EndIf*/
		/*---------------------------------FIM BOX02-----------------------------------------*/

		/*---------------------------------BOX03.01---------------------------------------------*/                        
		nLeft   := 05   //Margem em milímetros a esquerda
		nBottom := 92   //Margem em milímetros do topo
		nRight  := 45   //Margem em milímetros a direita
		nTop    := 101  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 2 //Tamanho Fonte Titulo
		nFDesc          := 3 //Tamanho Fonte Descricão

		cTitle := "DATA PRODUCAO/EMBALAGEM"     
		cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA

		nPos := (nTop - ((nTop - nBottom)/2))+0.5
		MSCBSAY(cInitTitle,nPos,cTitle,"N",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc := ALLTRIM(_dPROD)
		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "CENTER")
		nPos := nBottom + 1
		MSCBSAY(cInitTitle,nPos,cDesc,"N",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX03.01-----------------------------------------*/

		/*---------------------------------BOX03.02---------------------------------------------*/                        
		nLeft   := 46 //Margem em milímetros a esquerda
		nBottom := 92  //Margem em milímetros do topo
		nRight  := 74   //Margem em milímetros a direita
		nTop    := 101  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 2 //Tamanho Fonte Titulo
		nFDesc          := 3 //Tamanho Fonte Descricão

		cTitle := "DATA DE VALIDADE:" 
		cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA

		nPos := (nTop - ((nTop - nBottom)/2))+0.5
		MSCBSAY(cInitTitle,nPos,cTitle     ,"N",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc := ALLTRIM(_dVALID)
		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "CENTER")
		nPos := nBottom + 1
		MSCBSAY(cInitTitle,nPos,cDesc     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX03.02-----------------------------------------*/

		/*---------------------------------BOX03.03---------------------------------------------*/                        
		nLeft   := 75   //Margem em milímetros a esquerda
		nBottom := 92  //Margem em milímetros do topo
		nRight  := 95   //Margem em milímetros a direita
		nTop    := 101  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 2 //Tamanho Fonte Titulo
		nFDesc          := 3 //Tamanho Fonte Descricão

		cTitle := "LOTE:"
		cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "CENTER")    //Calcula posicao inicio titulo - ESQUERDA
		nPos := (nTop - ((nTop - nBottom)/2))+0.5
		MSCBSAY(cInitTitle,nPos,cTitle     ,"N",cValToChar(nFTitle),"1,1")     //Titulo


		cDesc := ALLTRIM(_cLOTE)
		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "CENTER")
		nPos := nBottom + 1
		MSCBSAY(cInitTitle,nPos,cDesc,"N",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX03.03-----------------------------------------*/

		/*---------------------------------BOX04.01---------------------------------------------*/                        
		nLeft   := 05   //Margem em milímetros a esquerda
		nBottom := 82  //Margem em milímetros do topo
		nRight  := 45   //Margem em milímetros a direita
		nTop    := 91  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 2 //Tamanho Fonte Titulo
		nFDesc          := 3 //Tamanho Fonte Descricão

		cTitle := "PESO DA EMBALAGEM:"
		cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "CENTER")    //Calcula posicao inicio titulo - ESQUERDA

		nPos := (nTop - ((nTop - nBottom)/2))+0.5
		MSCBSAY(cInitTitle,nPos,cTitle,"N",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc := ALLTRIM(_cPESOE)
		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "CENTER")
		nPos := nBottom + 1
		MSCBSAY(cInitTitle,nPos,cDesc,"N",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX04.01-----------------------------------------*/

		/*---------------------------------BOX04.02---------------------------------------------*/                        
		nLeft   := 46  //Margem em milímetros a esquerda
		nBottom := 82  //Margem em milímetros do topo
		nRight  := 95   //Margem em milímetros a direita
		nTop    := 91  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 2 //Tamanho Fonte Titulo
		nFDesc          := 1 //Tamanho Fonte Descricão

		cTitle := "MODO DE CONSERVACAO:"
		cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "CENTER")    //Calcula posicao inicio titulo - ESQUERDA

		nPos := (nTop - ((nTop - nBottom)/2))+0.5
		MSCBSAY(cInitTitle,nPos,cTitle     ,"N",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc := ALLTRIM(_cCONS)
		
		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "CENTER") 

		//nPos := nTop - (((nTop - nBottom)/3)*3)+0.3
		//MSCBSAY(cInitTitle,nPos,"MANTENHA CONGELADO A -12oC OU MAIS FRIO"     ,"N",cValToChar(nFTitle),"1,1")     //Subtitulo

		If (Len(cDesc)*nFDesc) > nRight - nLeft
			nTamMax := (nRight - nLeft)/(nFDesc*0.5)
			nLin    := mlcount(cDesc,nTamMax)
			nPosIni := nPos
			For _nY := 1 to nLin
				nPos := (nPos - (nPosIni - nBottom)/nLin)
				If nPos == nBottom 
					MSCBSAY(cInitTitle,nPos+1,memoline(cDesc,nTamMax,_nY)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
				Else
					MSCBSAY(cInitTitle,nPos,memoline(cDesc,nTamMax,_nY)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
				EndIf
			Next
		Else
			nPos := nBottom + 1
			MSCBSAY(cInitTitle,nPos,cDesc    ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
		EndIf

		/*---------------------------------FIM BOX04.02-----------------------------------------*/

		/*---------------------------------BOX05---------------------------------------------*/                        
		nLeft   := 05   //Margem em milímetros a esquerda
		nBottom := 73  //Margem em milímetros do topo
		nRight  := 95//95   //Margem em milímetros a direita
		nTop    := 81  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFDesc          := 1 //Tamanho Fonte Descricão

		cDesc := ALLTRIM(_cRecoCons)
		
		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA

		If (Len(cDesc)*nFDesc) > nRight - nLeft
			nTamMax := (nRight - nLeft)/(nFDesc)
			nLin    := mlcount(cDesc,nTamMax)
			nPos    := nTop
			For _nY := 1 to nLin
				nPos := (nPos - (nTop - nBottom)/nLin)
				If nPos == nBottom 
					MSCBSAY(cInitTitle,nPos+0.6,memoline(cDesc,nTamMax,_nY)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
				Else
					MSCBSAY(cInitTitle,nPos,memoline(cDesc,nTamMax,_nY)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
				EndIf
			Next
		Else
			nPos    := nTop - (((nTop - nBottom)/3)*3)
			MSCBSAY(cInitTitle,nPos,cDesc    ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
		EndIf

		/*---------------------------------FIM BOX05-----------------------------------------*/

		/*---------------------------------BOX06 TESTE---------------------------------------------*/                        
		nLeft   := 05   //Margem em milímetros a esquerda
		nBottom := 62  //Margem em milímetros do topo
		nRight  := 85//95   //Margem em milímetros a direita
		nTop    := 72  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda    
		//MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFDesc          := 1 //Tamanho Fonte Descricão

		cDesc := ALLTRIM(_CINFNUT)
		
		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA

		If (Len(cDesc)*nFDesc) > nRight - nLeft
			nTamMax := (nRight - nLeft)/(nFDesc)
			nLin    := mlcount(cDesc,nTamMax)
			nPos    := nTop
			For _nY := 1 to nLin
				nPos := (nPos - (nTop - nBottom)/nLin)
				If nPos == nBottom 
					MSCBSAY(cInitTitle,nPos - (_nY - (1 * (_nY*0.55))),memoline(cDesc,nTamMax,_nY)     ,"N",cValToChar(nFDesc),"1")     //Subtitulo
				Else
					MSCBSAY(cInitTitle,nPos - (_nY - (1 * (_nY*0.55))),memoline(cDesc,nTamMax,_nY)     ,"N",cValToChar(nFDesc),"1")     //Subtitulo
				EndIf
			Next
		Else
			nPos    := nTop - (((nTop - nBottom)/3)*3)
			MSCBSAY(cInitTitle,nPos,cDesc    ,"N",cValToChar(nFDesc),"1")     //Subtitulo
		EndIf

		/*---------------------------------FIM BOX06 TESTE-----------------------------------------*/
		
		/*---------------------------------BOX06---------------------------------------------*/                        
		/*nLeft   := 05   //Margem em milímetros a esquerda
		nBottom := 59  //Margem em milímetros do topo
		nRight  := 95   //Margem em milímetros a direita
		nTop    := 73  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          
		//MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFDesc          := 1//Tamanho Fonte Descricão

		cDesc := ALLTRIM(_CINFNUT)

		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "LEFT")    //Calcula posicao inicio titulo - ESQUERDA
		

		If (Len(cDesc)*nFDesc) > nRight - nLeft
			nTamMax := (nRight - nLeft)/(nFDesc * 1.1)
			nLin    := mlcount(cDesc,nTamMax)
			nPos    := nTop
			For _nY := 1 to nLin
				nPos := (nPos - (nTop - nBottom)/nLin)
				If nPos == nBottom 
					MSCBSAY(cInitTitle,nPos+0.3,memoline(cDesc,nTamMax,_nY)     ,"N",cValToChar(nFDesc),"1")     //Subtitulo
				Else
					MSCBSAY(cInitTitle,nPos,memoline(cDesc,nTamMax,_nY)     ,"N",cValToChar(nFDesc),"1")     //Subtitulo
				EndIf
			Next
		Else
			nPos    := nTop - 3
			MSCBSAY(cInitTitle,nPos,cDesc    ,"N",cValToChar(nFDesc),"1")     //Subtitulo
		EndIf*/

		/*---------------------------------FIM BOX06-----------------------------------------*/

		// /*---------------------------------BOX07---------------------------------------------*/                        
		//05/08/2020 - Informado pela Bruna que nao deve exibir essa informacao
		/*nLeft   := 05   //Margem em milímetros a esquerda
		nBottom := 56  //Margem em milímetros do topo
		nRight  := 95   //Margem em milímetros a direita
		nTop    := 58  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          
		//MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFDesc          := 2 //Tamanho Fonte Descricão

		cDesc := ALLTRIM(_cAlerg)

		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "LEFT")    //Calcula posicao inicio titulo - ESQUERDA

		MSCBSAY(cInitTitle,nBottom + 0.1,cDesc     ,"N",cValToChar(nFDesc),"1,1")   //Imprime Titulo*/

		/*---------------------------------FIM BOX07-----------------------------------------*/

		/*---------------------------------BOX08---------------------------------------------*/                        
		nLeft   := 05   //Margem em milímetros a esquerda
		nBottom := 54  //Margem em milímetros do topo
		nRight  := 85   //Margem em milímetros a direita
		nTop    := 56  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          
		//MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFDesc          := 2 //Tamanho Fonte Descricão

		cDesc := ALLTRIM(_CSIF)

		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA

		MSCBSAY(cInitTitle,nBottom + 0.1,cDesc     ,"N",cValToChar(nFDesc),"1.1")   //Imprime Titulo


		/*---------------------------------FIM BOX08-----------------------------------------*/


		/*---------------------------------BOX09---------------------------------------------*/                        
		nLeft   := 60   //Margem em milímetros a esquerda
		nBottom := 0  //Margem em milímetros do topo
		nRight  := 99   //Margem em milímetros a direita
		nTop    := 10  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          
		//MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFDesc          := 2 //Tamanho Fonte Descricão

		cDesc := ALLTRIM(_cGluten)
		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "LEFT")    //Calcula posicao inicio titulo - ESQUERDA

		MSCBSAY(cInitTitle,nBottom + 0.1,cDesc     ,"N",cValToChar(nFDesc),"1,1")   //Imprime Titulo

		/*---------------------------------FIM BOX09-----------------------------------------*/

		MSCBEND()

		MSCBCLOSEPRINTER() //Finaliza a impressão

	Endif

	RestArea(_aArea)

Return(nil)




static function CalcInit(cTitle,nFontSize,nLeft, nRight, cPosition)

	Local nInit := 0

	DO CASE
		CASE UPPER(cPosition) == "CENTER"
		If nFontSize == 3
			nInit := nLeft + (((nRight - nLeft)-Len(cTitle)*1.9)/2)
		Elseif nFontSize == 2
			nInit := nLeft +  (((nRight - nLeft)-Len(cTitle)*1.45)/2)
		Elseif nFontSize == 1
			nInit := nLeft +  (((nRight - nLeft)-Len(cTitle)*1.1)/2)
		EndIf
		CASE UPPER(cPosition) == "LEFTBOX"
		nInit := nLeft + 2
		CASE UPPER(cPosition) == "LEFT"
		nInit := nLeft + 0.5
		OTHERWISE
		nInit := nLeft + 0.5
	ENDCASE
return nInit