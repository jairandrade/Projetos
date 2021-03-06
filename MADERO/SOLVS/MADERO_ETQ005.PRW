#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualiza��o                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! PCP - PRODU��O                                          !
+------------------+---------------------------------------------------------+
!Nome              ! ETQ005                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina Emiss�o etiqueta 5 CM ADESIVA NUTRICIONAL        !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 20/05/18                                                !
+------------------+---------------------------------------------------------+
*/
User Function ETQ005(aEtqAuto)
	
    Local  _aArea   := GetArea()
	Local  _cperg   := "ETQ005    "
	Local  _cOP     := ""
	Local  _nQtde   := 0
	Local  _cImp    := ""
	Local  _cPROD   := ""
	Local  _cTpEtq  := "005" //Etiqueta 5 cm ADESIVA NUTRICIONAL
	Local  _lret    := .T.
	Local  _lrimp   := .F.
	Local  i        := 0

	Local _CDESC    := ''
	Local _dPROD    := ''
	Local _dVALID   := ''
	Local _cINGRED  := ''
	Local _cLOTE    := ''
	Local _CINFNUT  := ''
	Local _cCons    := ''
	Local _cAlerg   := ''
	Local _cGluten  := ''
	Local _CDESCD   := ''
	Local _CSIF     := ''
	Local _cPESOE   := ''
	Local _cRecoCons:= ''

	Local cModelo,lTipo,nPortIP,cServer,cEnv,cFila 
	Local cPorta :=Nil

	DEFAULT aEtqAuto := NIL

	If !aEtqAuto == NIL
		_COP    :=aETQAuto[1]
		_CPROD  :=aETQAuto[2]
		_CLOTE  :=aETQAuto[3]
		_nQtde  :=aEtqAuto[4]
		_cImp   :=aEtqAuto[5]
		_lRIMP  :=aEtqAuto[6]
		//EXECUTAR IMPRIME ETIQUETA
		//valida Ordem de Producao
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
	//

	DBSELECTAREA("ZIB")
	DBSETORDER(1)
	_LRET := ZIB->(DBSEEK(XFILIAL("ZIB")+_CPROD+_cTpEtq)) .And. (_lRIMP .Or. ZIB->ZIB_APONTA == "S")

	IF _LRET

		SC2->(dbSetOrder(1))
		IF !SC2->(MsSeek(xFilial("SC2")+_COP))

			MSGINFO("Ordem de Producao/Produto/Lote n�o Cadastrado !!!")
			_lret:=.F.
		ElseIf !_lRImp
			
			_nQtde := ZIB->ZIB_QTDE
		EndIf
	EndIf

	If _LRET
		
        _CDESC    := IIF(!Empty(SB1->B1_PACAMAP), ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"Z6"+SB1->B1_PACAMAP,"X5_DESCRI")),SB1->B1_XPADMAP)
		_dPROD    := DTOC(SC2->C2_XDTFIR)
		_dVALID   := DTOC(SC2->C2_XDTVAL)
		_cINGRED  := 'Ingredientes: ' + ALLTRIM(MSMM(SB1->B1_CODPROC))
		_cLOTE    := Alltrim(SC2->C2_XLOTE)//Alltrim(Str(Val(SC2->C2_XLOTE)))
		_CINFNUT  := ""+substr(ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+SB1->B1_COD,"B1_XINFNUT")),1,800)
		_cCons    := IIF(!Empty(SB1->B1_XCONS), ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"W1"+SB1->B1_XCONS,"X5_DESCRI")), "")
		_cAlerg   := IIF(!Empty(SB1->B1_XALERG), ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"W2"+SB1->B1_XALERG,"X5_DESCRI")), "")
		_cGluten  := IIF(SB1->B1_XGLUT="1","CONT�M GLUTEN",IIF(SB1->B1_XGLUT="2","N�O CONT�M GLUTEN",""))
		_CDESCD   := ALLTRIM(POSICIONE("SB5",1,XFILIAL("SB5")+SB1->B1_COD,"B5_CEME"))
		_CSIF     := "Registro no Minist�rio da Agricultura SIF/DIPOA sob No." + /*SB1->B1_XRMAPA*/ ALLTRIM(POSICIONE("SB5",1,XFILIAL("SB5")+SB1->B1_COD,"B5_DES"))
		_cPESOE   := alltrim(TRANSFORM(SB1->B1_XPEMB, PesqPict("SB1","B1_XPEMB"))) + 'KG'//SB1->B1_UM
		_cRecoCons:= "Recomenda��es para consumo: Produto exclusivo para preparo nas filiais do GRUPO MADERO, conforme procedimentos operacionais padr�o estabelecido para cada produto, respeitando tempo e temperatura."

		If Empty(_CIMP)
			Return .f.
		EndIf         
		
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

		//
		TEXTO:={}

		MSCBPRINTER(cModelo,cPorta,,,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH)+"\ETQ005")
		MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")

		MSCBBEGIN(_nQtde,6)  

		/*---------------------------------BOX01---------------------------------------------*/     
		nLeft   := 05   //Margem em mil�metros a esquerda
		nBottom := 113  //Margem em mil�metros do topo
		nRight  := 95   //Margem em mil�metros a direita
		nTop    := 121  //Margem em mil�metros do final
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 2 //Tamanho Fonte Titulo

		cTitle          := ALLTRIM(_CDESC)    //String Titulo
		cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "CENTER") //Calcula posicao inicio titulo - CENTRO
		MSCBSAY(cInitTitle,117,cTitle     ,"N",cValToChar(nFTitle),"1,1")   //Imprime Titulo

		cTitle          := ALLTRIM(_CDESCD)                    //String Subtitulo
		cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "CENTER") //Calcula posicao inicio titulo - CENTRO
		MSCBSAY(cInitTitle,nBottom+1,cTitle     ,"N",cValToChar(nFTitle),"1,1")   //Subtitulo
		/*---------------------------------FIM BOX01-----------------------------------------*/      


		/*---------------------------------BOX02---------------------------------------------*/                        
		nLeft   := 05   //Margem em mil�metros a esquerda
		nBottom := 103  //Margem em mil�metros do topo
		nRight  := 83//95   //Margem em mil�metros a direita
		nTop    := 112  //Margem em mil�metros do final 
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight+12,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 1 //Tamanho Fonte Descric�o

		cDesc          := ALLTRIM(_CINGRED)
		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA

		If (Len(cDesc)*nFDesc) > nRight - nLeft
			//#TB20200703
			nTamMax := (nRight - nLeft)/(nFDesc*0.9)
			//nTamMax := (nRight - nLeft)/(nFDesc*1.1)
			nLin    := mlcount(cDesc,nTamMax)
			nPos    := nTop
			For i := 1 to nLin
				nPos := (nPos - (nTop - nBottom)/nLin)
				If nPos == nBottom 
					MSCBSAY(cInitTitle,nPos+1,memoline(cDesc,nTamMax,i)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
				Else
					MSCBSAY(cInitTitle,nPos+0.5,memoline(cDesc,nTamMax,i)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
				EndIf
			Next
		Else
			nPos    := nTop - (((nTop - nBottom)/3)*2)
			MSCBSAY(cInitTitle,nPos,cDesc     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
		EndIf
		/*---------------------------------FIM BOX02-----------------------------------------*/

		/*---------------------------------BOX03.01---------------------------------------------*/                        
		nLeft   := 05   //Margem em mil�metros a esquerda
		nBottom := 95   //Margem em mil�metros do topo
		nRight  := 45   //Margem em mil�metros a direita
		nTop    := 102  //Margem em mil�metros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descric�o

		cTitle := "DATA PRODUCAO/EMBALAGEM"     
		cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "CENTER")    //Calcula posicao inicio titulo - ESQUERDA

		nPos := (nTop - ((nTop - nBottom)/2))+0.5
		MSCBSAY(cInitTitle,nPos,cTitle,"N",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc := ALLTRIM(_dPROD)
		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "CENTER")
		nPos := nBottom + 1
		MSCBSAY(cInitTitle,nPos,cDesc,"N",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX03.01-----------------------------------------*/

		/*---------------------------------BOX03.02---------------------------------------------*/                        
		nLeft   := 46 //Margem em mil�metros a esquerda
		nBottom := 95  //Margem em mil�metros do topo
		nRight  := 74   //Margem em mil�metros a direita
		nTop    := 102  //Margem em mil�metros do final
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descric�o

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
		nLeft   := 75   //Margem em mil�metros a esquerda
		nBottom := 95  //Margem em mil�metros do topo
		nRight  := 95   //Margem em mil�metros a direita
		nTop    := 102  //Margem em mil�metros do final
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descric�o

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
		nLeft   := 05   //Margem em mil�metros a esquerda
		nBottom := 87  //Margem em mil�metros do topo
		nRight  := 45   //Margem em mil�metros a direita
		nTop    := 94  //Margem em mil�metros do final
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descric�o

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
		nLeft   := 46  //Margem em mil�metros a esquerda
		nBottom := 87  //Margem em mil�metros do topo
		nRight  := 95   //Margem em mil�metros a direita
		nTop    := 94  //Margem em mil�metros do final
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 1 //Tamanho Fonte Descric�o

		cTitle := "MODO DE CONSERVACAO:"
		cInitTitle      := CalcInit(cTitle,nFTitle,nLeft, nRight, "CENTER")    //Calcula posicao inicio titulo - ESQUERDA

		nPos := (nTop - ((nTop - nBottom)/2))+0.5
		MSCBSAY(cInitTitle,nPos,cTitle     ,"N",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc := ALLTRIM(_cCONS)
		cInitTitle      := CalcInit(cDesc,nFTitle,nLeft, nRight, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA
		//nPos := nTop - (((nTop - nBottom)/3)*3)+0.3
		//MSCBSAY(cInitTitle,nPos,"MANTENHA CONGELADO A -12oC OU MAIS FRIO"     ,"N",cValToChar(nFTitle),"1,1")     //Subtitulo

		If (Len(cDesc)*nFDesc) > nRight - nLeft
			nTamMax := (nRight - nLeft)/(nFDesc*0.5)
			nLin    := mlcount(cDesc,nTamMax)
			nPosIni := nPos
			For i := 1 to nLin
				nPos := (nPos - (nPosIni - nBottom)/nLin)
				If nPos == nBottom 
					MSCBSAY(cInitTitle,nPos+1,memoline(cDesc,nTamMax,i)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
				Else
					MSCBSAY(cInitTitle,nPos,memoline(cDesc,nTamMax,i)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
				EndIf
			Next
		Else
			nPos := nBottom + 1
			MSCBSAY(cInitTitle,nPos,cDesc    ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
		EndIf

		/*---------------------------------FIM BOX04.02-----------------------------------------*/

		/*---------------------------------BOX05---------------------------------------------*/                        
		nLeft   := 05   //Margem em mil�metros a esquerda
		nBottom := 80  //Margem em mil�metros do topo
		nRight  := 88//95   //Margem em mil�metros a direita
		nTop    := 86  //Margem em mil�metros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight+7,nTop,nExpess) //Monta Box

		nFDesc          := 1 //Tamanho Fonte Descric�o

		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA

		cDesc := ALLTRIM(_cRecoCons)

		If (Len(cDesc)*nFDesc) > nRight - nLeft
			//#TB20200703
			nTamMax := (nRight - nLeft)/(nFDesc*0.9)
			//nTamMax := (nRight - nLeft)/(nFDesc*1.1)
			nLin    := mlcount(cDesc,nTamMax)
			nPos    := nTop
			For i := 1 to nLin
				nPos := (nPos - (nTop - nBottom)/nLin)
				If nPos == nBottom 
					//#TB20200703
					MSCBSAY(cInitTitle,nPos+0.6,memoline(cDesc,nTamMax,i)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
					//MSCBSAY(cInitTitle,nPos+0.6,memoline(cDesc,nTamMax,i)     ,"N",cValToChar(nFDesc),"1")     //Subtitulo
				Else
					//#TB20200703
					MSCBSAY(cInitTitle,nPos,memoline(cDesc,nTamMax,i)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
					//MSCBSAY(cInitTitle,nPos,memoline(cDesc,nTamMax,i)     ,"N",cValToChar(nFDesc),"1")     //Subtitulo
				EndIf
			Next
		Else
			nPos    := nTop - (((nTop - nBottom)/3)*3)
			MSCBSAY(cInitTitle,nPos,cDesc    ,"N",cValToChar(nFDesc),"1")     //Subtitulo
		EndIf

		/*---------------------------------FIM BOX05-----------------------------------------*/

		/*---------------------------------BOX06---------------------------------------------*/                        
		nLeft   := 05   //Margem em mil�metros a esquerda
		nBottom := 68  //Margem em mil�metros do topo
		nRight  := 88//95   //Margem em mil�metros a direita
		nTop    := 80  //Margem em mil�metros do final
		nExpess := 1    //Expessura da borda          
		//MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFDesc          := 1//Tamanho Fonte Descric�o

		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "LEFT")    //Calcula posicao inicio titulo - ESQUERDA

		cDesc := ALLTRIM(_cINFNUT)

		If (Len(cDesc)) > nRight - nLeft
			//#TB20200703
			nTamMax := (nRight - nLeft)/(nFDesc)
			//nTamMax := (nRight - nLeft)/(nFDesc*1.1)
			nLin    := mlcount(cDesc,nTamMax)
			nPos    := nTop
			For i := 1 to nLin
				nPos := (nPos - (nTop - nBottom)/nLin)

				If nPos == nBottom 
					MSCBSAY(cInitTitle,nPos - (i - (1 * (i*0.55)))  ,memoline(cDesc,nTamMax,i)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
				Else
					MSCBSAY(cInitTitle,nPos - (i - (1 * (i*0.55)))  ,memoline(cDesc,nTamMax,i)     ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
				EndIf
			Next
		Else
			nPos    := nTop - (((nTop - nBottom)/3)*3)
			MSCBSAY(cInitTitle,nPos,cDesc    ,"N",cValToChar(nFDesc),"1,1")     //Subtitulo
		EndIf

		/*---------------------------------BOX08---------------------------------------------*/                        
		nLeft   := 05   //Margem em mil�metros a esquerda
		nBottom := 62  //Margem em mil�metros do topo
		nRight  := 95   //Margem em mil�metros a direita
		nTop    := 64  //Margem em mil�metros do final
		nExpess := 1    //Expessura da borda          
		//MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFDesc          := 2 //Tamanho Fonte Descric�o

		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "LEFT")    //Calcula posicao inicio titulo - ESQUERDA

		cDesc := ALLTRIM(_CSIF)

		MSCBSAY(cInitTitle,nBottom + 0.1,cDesc     ,"N",cValToChar(nFDesc),"1,1")   //Imprime Titulo


		/*---------------------------------FIM BOX08-----------------------------------------*/

		/*---------------------------------BOX08---------------------------------------------*/                        
		nLeft   := 60   //Margem em mil�metros a esquerda
		nBottom := 0  //Margem em mil�metros do topo
		nRight  := 99   //Margem em mil�metros a direita
		nTop    := 10  //Margem em mil�metros do final
		nExpess := 1    //Expessura da borda          
		//MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFDesc          := 2 //Tamanho Fonte Descric�o

		cInitTitle      := CalcInit(cDesc,nFDesc,nLeft, nRight, "LEFT")    //Calcula posicao inicio titulo - ESQUERDA

		cDesc := ALLTRIM(_cGluten)

		MSCBSAY(cInitTitle,nBottom + 0.1,cDesc     ,"N",cValToChar(nFDesc),"1,1")   //Imprime Titulo


		/*---------------------------------FIM BOX08-----------------------------------------*/

		MSCBEND()  
		MSCBCLOSEPRINTER() //Finaliza a impress�o

	Endif

	RestArea(_aArea)

Return(nil)

//
static function CalcInit(cTitle,nFontSize,nLeft, nRight, cPosition)

	Local nInit := 0

	DO CASE
		CASE UPPER(cPosition) == "CENTER"
		If nFontSize == 3
			nInit := nLeft + (((nRight - nLeft)-Len(cTitle)*2)/2)
		Elseif nFontSize == 2
			nInit := nLeft +  (((nRight - nLeft)-Len(cTitle)*1.6)/2)
		Elseif nFontSize == 1
			nInit := nLeft +  (((nRight - nLeft)-Len(cTitle)*1.2)/2)
		EndIf
		CASE UPPER(cPosition) == "LEFTBOX"
		nInit := nLeft + 2
		CASE UPPER(cPosition) == "LEFT"
		nInit := nLeft + 0.5
		OTHERWISE
		nInit := nLeft + 0.5
	ENDCASE
return nInit