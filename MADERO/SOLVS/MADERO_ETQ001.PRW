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
!Nome              ! ETQ001                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina Emissão etiqueta 3 CM ADESIVA                    !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 20/05/18                                                !
+------------------+---------------------------------------------------------+
*/
User Function ETQ001(aEtqAuto)
	Local  _aArea   := GetArea()
	Local  _cperg   :="ETQ001    "
	Local  _cOP     :=""
	Local  _nQtde   :=0
	Local  _cImp    :=""
	Local  _cPROD   :=""
	Local  _cTpEtq  :="001" //Etiqueta 3 cm ADESIVA
	Local  _lret    :=.T.
	Local  _lrimp   :=.F.
	Local _CDESC    := ''
	Local _dPROD    := ''
	Local _dVALID   := ''
	Local _cINGRED  := ''
	Local _CINFNUT  := ''
	Local _cLOTE    := ''
	Local _cCons    := ''
	Local _cGluten  := ''
	Local _cQTDE    := ''
	Local _CDESCD   := ''
    Local _CSIF     := ''
	Local _cPESOE   := ''
	Local _cRecoCons:= ''

	Local cModelo,lTipo,nPortIP,cServer,cEnv,cFila 
	Local cPorta    := Nil
	Local i
	
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

	    _CDESC      := IIF(!Empty(SB1->B1_PACAMAP), ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"Z6"+SB1->B1_PACAMAP,"X5_DESCRI")), SB1->B1_XPADMAP)
	    _dPROD      := DTOC(SC2->C2_XDTFIR)
	    _dVALID     := DTOC(SC2->C2_XDTVAL)
	    _cINGRED    := 'Ingredientes: '+ALLTRIM(MSMM(SB1->B1_CODPROC))
	    _CINFNUT    := ""+ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+SB1->B1_COD,"B1_XINFNUT"))
	    _cLOTE      := Alltrim(SC2->C2_XLOTE)
	    _cCons      := IIF(!Empty(SB1->B1_XCONS), ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"W1"+SB1->B1_XCONS,"X5_DESCRI")), "")
	    _cGluten    := IIF(SB1->B1_XGLUT="1","CONTÉM GLUTEN",IIF(SB1->B1_XGLUT="2","NÃO CONTÉM GLUTEN",""))
	    _cQTDE      := SB1->B1_TALLA
	    _CDESCD     := ALLTRIM(POSICIONE("SB5",1,XFILIAL("SB5")+SB1->B1_COD,"B5_CEME"))
        _CSIF       :="Registro no Ministério da Agricultura SIF/DIPOA sob No." + /*SB1->B1_XRMAPA*/ POSICIONE("SB5",1,XFILIAL("SB5")+SB1->B1_COD,"B5_DES")
	    _cPESOE     := alltrim(TRANSFORM(SB1->B1_XPEMB, PesqPict("SB1","B1_XPEMB"))) + /*SB1->B1_UM*/ 'KG'
	    _cRecoCons  := "Recomendações para consumo: Produto exclusivo para preparo nas filiais do GRUPO MADERO, conforme procedimentos operacionais padrão estabelecido para cada produto, respeitando tempo e temperatura."

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

		MSCBPRINTER(cModelo,cPorta,,,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH)+"\Etq001")
		MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")

		MSCBBEGIN(_nQtde,6)  

		/*---------------------------------BOX01---------------------------------------------*/     
		nLeft   := 02   //Margem em mil?metros a esquerda
		nBottom := 00  //Margem em mil?metros do topo
		nRight  := 12   //Margem em mil?metros a direita
		nTop    := 80  //Margem em mil?metros do final
		nExpess := 1    //Expessura da borda
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 2 //Tamanho Fonte Titulo

		cTitle          := ALLTRIM(_CDESC)    //String Titulo
		cInitTitle      := CalcInit(cTitle,nFTitle,nBottom, nTop, "CENTER") //Calcula posicao inicio titulo - CENTRO
		MSCBSAY(nRight-4.5,cInitTitle,cTitle     ,"B",cValToChar(nFTitle),"1,1")   //Imprime Titulo

		cTitle          := ALLTRIM(_CDESCD)                    //String Subtitulo
		cInitTitle      := CalcInit(cTitle,nFTitle,nBottom, nTop, "CENTER") //Calcula posicao inicio titulo - CENTRO
		MSCBSAY(nRight-1,cInitTitle,cTitle     ,"B",cValToChar(nFTitle),"1,1")   //Subtitulo
		/*---------------------------------FIM BOX01-----------------------------------------*/      


		/*---------------------------------BOX02---------------------------------------------*/                        
		nLeft   := 13   //Margem em mil?metros a esquerda
		nBottom := 00  //Margem em mil?metros do topo
		nRight  := 20   //Margem em mil?metros a direita
		nTop    := 62  //Margem em mil?metros do final 
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft,nBottom,nRight,nTop+18,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 1 //Tamanho Fonte Descric?o

		cDesc          := ALLTRIM(_CINGRED)
		cInitTitle      := CalcInit(cDesc,nFDesc,nBottom, nTop, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA

		If (Len(cDesc)*nFDesc) > nTop - nBottom
			nTamMax := (nTop - nBottom)/(nFDesc*0.9)
			nLin    := mlcount(cDesc,nTamMax)
			nPos    := nLeft
			For i := 1 to nLin
				nPos := (nPos - (nLeft - nRight)/nLin)
				If nPos == nRight 
					MSCBSAY(nPos-1,cInitTitle,memoline(cDesc,nTamMax,i)     ,"B",cValToChar(nFDesc),"1,1")     //Subtitulo
				Else
					MSCBSAY(nPos-0.3,cInitTitle,memoline(cDesc,nTamMax,i)     ,"B",cValToChar(nFDesc),"1,1")     //Subtitulo
				EndIf
			Next
		Else
			nPos    := nLeft - (((nLeft - nRight)/3)*2)
			MSCBSAY(nPos,cInitTitle,cDesc     ,"B",cValToChar(nFDesc),"1,1")     //Subtitulo
		EndIf
		/*---------------------------------FIM BOX02-----------------------------------------*/

		/*---------------------------------BOX03.01---------------------------------------------*/                        
		nLeft   := 21   //Margem em mil?metros a esquerda
		nBottom := 00   //Margem em mil?metros do topo
		nRight  := 27   //Margem em mil?metros a direita
		nTop    := 25  //Margem em mil?metros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descric?o

		cTitle := "DATA DE PRODUCAO"     
		cInitTitle      := CalcInit(cTitle,nFTitle,nBottom, nTop, "CENTER") //Calcula posicao inicio titulo - CENTRO

		nPos := (nLeft - ((nLeft - nRight)/2))-0.5
		MSCBSAY(nPos,cInitTitle,cTitle,"B",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc := ALLTRIM(_dPROD)
		cInitTitle      := CalcInit(cDesc,nFDesc,nBottom, nTop, "CENTER")
		nPos := nRight - 0.5
		MSCBSAY(nPos,cInitTitle,cDesc,"B",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX03.01-----------------------------------------*/

		/*---------------------------------BOX03.02---------------------------------------------*/                        
		nLeft   := 21   //Margem em mil?metros a esquerda
		nBottom := 26   //Margem em mil?metros do topo
		nRight  := 27   //Margem em mil?metros a direita
		nTop    := 51  //Margem em mil?metros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descric?o

		cTitle := "DATA DE VALIDADE"     
		cInitTitle      := CalcInit(cTitle,nFTitle,nBottom, nTop, "CENTER") //Calcula posicao inicio titulo - CENTRO

		nPos := (nLeft - ((nLeft - nRight)/2))-0.5
		MSCBSAY(nPos,cInitTitle,cTitle,"B",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc := ALLTRIM(_dVALID)
		cInitTitle      := CalcInit(cDesc,nFDesc,nBottom, nTop, "CENTER")
		nPos := nRight - 0.5
		MSCBSAY(nPos,cInitTitle,cDesc,"B",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX03.02-----------------------------------------*/

		/*---------------------------------BOX03.03---------------------------------------------*/                        
		nLeft   := 21   //Margem em mil?metros a esquerda
		nBottom := 52   //Margem em mil?metros do topo
		nRight  := 27   //Margem em mil?metros a direita
		nTop    := 80  //Margem em mil?metros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descric?o

		cTitle := "LOTE"     
		cInitTitle      := CalcInit(cTitle,nFTitle,nBottom, nTop, "CENTER") //Calcula posicao inicio titulo - CENTRO

		nPos := (nLeft - ((nLeft - nRight)/2))-0.5
		MSCBSAY(nPos,cInitTitle,cTitle,"B",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc := ALLTRIM(_cLOTE)
		cInitTitle      := CalcInit(cDesc,nFDesc,nBottom, nTop, "CENTER")
		nPos := nRight - 0.5
		MSCBSAY(nPos,cInitTitle,cDesc,"B",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX03.03-----------------------------------------*/


		/*---------------------------------BOX03.01---------------------------------------------*/                        
		nLeft   := 28   //Margem em mil?metros a esquerda
		nBottom := 00   //Margem em mil?metros do topo
		nRight  := 34   //Margem em mil?metros a direita
		nTop    := 25  //Margem em mil?metros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descric?o

		cTitle := "PESO EMBALAGEM"     
		cInitTitle      := CalcInit(cTitle,nFTitle,nBottom, nTop, "CENTER") //Calcula posicao inicio titulo - CENTRO

		nPos := (nLeft - ((nLeft - nRight)/2))-0.5
		MSCBSAY(nPos,cInitTitle,cTitle,"B",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc := ALLTRIM(_cPESOE)
		cInitTitle      := CalcInit(cDesc,nFDesc,nBottom, nTop, "CENTER")
		nPos := nRight - 0.5
		MSCBSAY(nPos,cInitTitle,cDesc,"B",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX03.01-----------------------------------------*/

		/*---------------------------------BOX03.02---------------------------------------------*/                        
		nLeft   := 28   //Margem em mil?metros a esquerda
		nBottom := 26   //Margem em mil?metros do topo
		nRight  := 34   //Margem em mil?metros a direita
		nTop    := 80  //Margem em mil?metros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 1 //Tamanho Fonte Descric?o

		cTitle := "MODO DE CONSERVACAO"     
		cInitTitle      := CalcInit(cTitle,nFTitle,nBottom, nTop, "CENTER") //Calcula posicao inicio titulo - CENTRO

		nPos := (nLeft - ((nLeft - nRight)/2))-0.5
		MSCBSAY(nPos,cInitTitle,cTitle,"B",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc := ALLTRIM(_cCONS)
		cInitTitle      := CalcInit(cDesc,nFDesc,nBottom, nTop, "CENTER")
		nPos := nRight - 0.5
		MSCBSAY(nPos,cInitTitle,cDesc,"B",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX03.02-----------------------------------------*/

		/*---------------------------------BOX04---------------------------------------------*/                        
		nLeft   := 35   //Margem em mil?metros a esquerda
		nBottom := 00   //Margem em mil?metros do topo
		nRight  := 41   //Margem em mil?metros a direita
		nTop    := 75  //Margem em mil?metros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight,nTop+5,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 1 //Tamanho Fonte Descric?o

		cDesc          := ALLTRIM(_cRecoCons)
		cInitTitle      := CalcInit(cDesc,nFDesc,nBottom, nTop, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA

		If (Len(cDesc)*nFDesc) > nTop - nBottom
			nTamMax := (nTop - nBottom)/(nFDesc*0.9)
			nLin    := mlcount(cDesc,nTamMax)
			nPos    := nLeft
			For i := 1 to nLin
				nPos := (nPos - (nLeft - nRight)/nLin)
				If nPos == nRight 
					MSCBSAY(nPos-0.2,cInitTitle,memoline(cDesc,nTamMax,i)     ,"B",cValToChar(nFDesc),"1,1")     //Subtitulo
				Else
					MSCBSAY(nPos+0.1,cInitTitle,memoline(cDesc,nTamMax,i)     ,"B",cValToChar(nFDesc),"1,1")     //Subtitulo
				EndIf
			Next
		Else
			nPos    := nLeft - (((nLeft - nRight)/3)*2)
			MSCBSAY(nPos,cInitTitle,cDesc     ,"B",cValToChar(nFDesc),"1,1")     //Subtitulo
		EndIf


		/*---------------------------------FIM BOX04-----------------------------------------*/

		/*---------------------------------BOX06---------------------------------------------*/                        
		nLeft   := 42   //Margem em mil?metros a esquerda
		nBottom := 00  //Margem em mil?metros do topo
		nRight  := 56   //Margem em mil?metros a direita
		nTop    := 75  //Margem em mil?metros do final 
		nExpess := 1    //Expessura da borda          
		//MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 1 //Tamanho Fonte Descric?o

		cDesc          := ALLTRIM(_cINFNUT)
		cInitTitle      := CalcInit(cDesc,nFDesc,nBottom, nTop, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA

		If (Len(cDesc)*nFDesc) > nTop - nBottom
			nTamMax := (nTop - nBottom)/(nFDesc/* *0.9*/ )
			nLin    := mlcount(cDesc,nTamMax)
			nPos    := nLeft
			For i := 1 to nLin
				nPos := (nPos - (nLeft - nRight)/nLin)
				If nPos == nRight 
					MSCBSAY(nPos - (i - (1 * (i * 1.20))),cInitTitle,memoline(cDesc,nTamMax,i)     ,"B",cValToChar(nFDesc),"1,1")     //Subtitulo
				Else
					MSCBSAY(nPos - (i - (1 * (i * 1.20))),cInitTitle,memoline(cDesc,nTamMax,i)     ,"B",cValToChar(nFDesc),"1,1")     //Subtitulo
				EndIf
			Next
		Else
			nPos    := nLeft - (((nLeft - nRight)/3)*2)
			MSCBSAY(nPos,cInitTitle,cDesc     ,"B",cValToChar(nFDesc),"1,1")     //Subtitulo
		EndIf
		/*---------------------------------FIM BOX06-----------------------------------------*/

		/*---------------------------------BOX08---------------------------------------------*/                        
		nLeft   := 60  //Margem em mil?metros a esquerda
		nBottom := 00  //Margem em mil?metros do topo
		nRight  := 62   //Margem em mil?metros a direita
		nTop    := 80  //Margem em mil?metros do final
		nExpess := 1    //Expessura da borda          

		nFTitle         := 2 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descric?o

		cDesc := ALLTRIM(_CSIF)
		cInitTitle      := CalcInit(cDesc,nFTitle,nBottom, nTop, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA
		nPos := nLeft - (((nLeft - nRight)/3)*3)-0.5
		MSCBSAY(nPos,cInitTitle,cDesc,"B",cValToChar(nFTitle),"1,1")     //Subtitulo
		/*---------------------------------FIM BOX08-----------------------------------------*/

		/*---------------------------------BOX08---------------------------------------------*/                        
		nLeft   := 100  //Margem em mil?metros a esquerda
		nBottom := 45  //Margem em mil?metros do topo
		nRight  := 105   //Margem em mil?metros a direita
		nTop    := 80  //Margem em mil?metros do final
		nExpess := 1    //Expessura da borda      

		nFTitle         := 2 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descric?o

		cDesc := ALLTRIM(_cGluten)
		cInitTitle      := CalcInit(cDesc,nFTitle,nBottom, nTop, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA
		nPos := nLeft - (((nLeft - nRight)/3)*3)-0.5
		MSCBSAY(nPos,cInitTitle,cDesc,"B",cValToChar(nFTitle),"1,1")     //Subtitulo
		/*---------------------------------FIM BOX08-----------------------------------------*/

		MSCBEND()  

		MSCBCLOSEPRINTER() //Finaliza a impress?o

	Endif

	RestArea(_aArea)

return nil
             

static function CalcInit(cTitle,nFontSize,nLeft, nRight, cPosition)

	Local nInit := 0

	DO CASE
		CASE UPPER(cPosition) == "CENTER"
		If nFontSize == 3
			nInit := nLeft + (((nRight - nLeft)-Len(cTitle)*2)/2)
		Elseif nFontSize == 2
			nInit := nLeft +  (((nRight - nLeft)-Len(cTitle)*1.4)/2)
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