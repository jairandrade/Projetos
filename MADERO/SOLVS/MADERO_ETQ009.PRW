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
!Nome              ! ETQ009                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina Emissão etiqueta HAMBURGUER - SIF                !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 20/05/18                                                !
+------------------+---------------------------------------------------------+
*/
User Function ETQ009(aEtqAuto)
	Local  _aArea   := GetArea()
	Local  _cperg   := "ETQ009    "
	Local  _cOP     := ""
	Local  _nQtde   := 0
	Local  _cImp    := ""
	Local  _cPROD   := ""
	Local  _cTpEtq  := "009" //Etiqueta HAMBURGUER
	Local  _lret    := .T.
	Local  _lrimp   := .F.
	Local i

	Local _CDESC    := ''
	Local _dPROD    := ''
	Local _dVALID   := ''
	Local _cINGRED  := ''
	Local _CINFNUT  := ''
	Local _cCons    := ''
	Local _cGluten  := ''
	Local _cLOTE    := ''
	Local _cPESOE   := ''
	Local _cQTDE    := ''
	Local _CDESCD   := ''
	Local _CDES     := ''
	Local _cPESOL   := ''
	Local _cPESOB   := ''
	Local _CSIF     := ''
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
		//#TB20200219 André Anjos - Query desnecessaria: SB1 está posicionada e SC2 basta posicionar
		SC2->(dbSetOrder(1))
		IF !SC2->(MsSeek(xFilial("SC2")+_COP))
		/*IF (!EMPTY(_COP) .OR. (!EMPTY(_CPROD) .AND. !EMPTY(_CLOTE)))
			
			_cAliasSC2 := GetNextAlias()
			_cLote:=strzero(val(_cLote),TamSX3("C2_XLOTE")[1])
			 
			cQuery := "SELECT * "
			cQuery += "FROM " + RETSQLNAME("SC2") + " SC2, " + RETSQLNAME("SB1") + " SB1 "
			cQuery += "WHERE SC2.D_E_L_E_T_ = '' "
			cQuery += "AND SC2.C2_FILIAL = '" + xFilial("SC2") + "' "
			cQuery += "AND SB1.D_E_L_E_T_ = '' "
			cQuery += "AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
			cQuery += "AND SC2.C2_PRODUTO = SB1.B1_COD "
			If !empty(_cop)
				cQuery += "AND SC2.C2_NUM = '" + substr(_cOP,1,TamSX3("C2_NUM")[1])    + "' "
				cQuery += "AND sc2.C2_ITEM= '" + substr(_cOP,TamSX3("C2_NUM")[1]+1,TamSX3("C2_ITEM")[1])    + "' "
				cQuery += "AND SC2.C2_SEQUEN = '" + substr(_cOP,TamSX3("C2_NUM")[1]+TamSX3("C2_ITEM")[1]+1,TamSX3("C2_SEQUEN")[1])+ "' "
			Else
				cQuery += "AND SC2.C2_PRODUTO = '" + _cPROD + "' "
				cQuery += "AND SC2.C2_XLOTE = '" + _cLOTE + "' "
			Endif

			If (Select(_cAliasSC2) <> 0)
				dbSelectArea(_cAliasSC2)
				dbCloseArea()
			EndIf

			cQuery := ChangeQuery(cQuery)

			TCQUERY cQuery NEW ALIAS &(_cAliasSC2)

			dbSelectArea(_cAliasSC2)
			(_cAliasSC2)->(dbGoTop())
			If (_cAliasSC2)->(Eof())*/
			MSGINFO("Ordem de Producao/Produto/Lote não Cadastrado !!!")
			_lret:=.F.
		ElseIf !_lRImp
			//#TB20200219 André Anjos - Deve ser impresso ZIB_QTDE de copias para cada etiqueta impressa
			/*IF EMPTY(_nQtde)
				_nQtde:=(_cAliasSC2)->C2_QUANT
			Endif
			_nQtde:=_nQtde*ZIB->ZIB_QTDE*/
			_nQtde := ZIB->ZIB_QTDE
		EndIf
	EndIf

	If _LRET
		
        _CDESC    := IIF(!Empty(SB1->B1_PACAMAP), ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"Z6"+SB1->B1_PACAMAP,"X5_DESCRI")),/*SB1->B1_DESC*/SB1->B1_XPADMAP)
		_dPROD    := DTOC(SC2->C2_XDTFIR)
		_dVALID   := DTOC(SC2->C2_XDTVAL)
		_cINGRED  := 'Ingredientes: ' + ALLTRIM(MSMM(SB1->B1_CODPROC))
		_CINFNUT  := ""+substr(ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+SB1->B1_COD,"B1_XINFNUT")),1,800)
		_cCons    := ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"W1"+SB1->B1_XCONS,"X5_DESCRI"))
		//_cGluten  := IIF(SB1->B1_XGLUT="1","CONT�M GLUTEN",IIF(SB1->B1_XGLUT="2","NAO CONT�M GLUTEN",""))
		_cGluten  := IIF(SB1->B1_XGLUT="1","CONT�M GLUTEN",IIF(SB1->B1_XGLUT="2","NAO CONT�M GLUTEN",""))
		_cLOTE    := Alltrim(SC2->C2_XLOTE)//Alltrim(Str(Val(SC2->C2_XLOTE)))
		_cPESOE   := TRANSFORM(SB1->B1_XPEMB,PesqPict("SB1","B1_XPEMB")) + "Kg"
		_cQTDE    := SB1->B1_TALLA + ' UN'
		_CDESCD   := ALLTRIM(POSICIONE("SB5",1,XFILIAL("SB5")+SB1->B1_COD,"B5_CEME"))
		_CDES     := ALLTRIM(POSICIONE("SB5",1,XFILIAL("SB5")+SB1->B1_COD,"B5_DES"))
		_cPESOL   := TRANSFORM(SB1->B1_PESO, PesqPict("SB1","B1_PESO")) + /*SB1->B1_UM*/ 'Kg'
		_cPESOB   := TRANSFORM(SB1->B1_PESBRU,PesqPict("SB1","B1_PESBRU")) + /*SB1->B1_UM*/ 'Kg'
		_CSIF     := "Registro no Ministerio da Agricultura SIF/DIPOA sob No." + /*SB1->B1_XRMAPA*/ POSICIONE("SB5",1,XFILIAL("SB5")+SB1->B1_COD,"B5_DES")
		_cRecoCons:= "Recomendacões para consumo: Produto exclusivo para preparo nas filiais do " + AllTrim(SM0->M0_NOME) + ", conforme procedimentos operacionais padrão estabelecido para cada produto, respeitando tempo e temperatura."

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

		MSCBPRINTER(cModelo,cPorta,,,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH)+"\ETQ009")
		MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")

		MSCBBEGIN(_nQtde,6)  

		/*---------------------------------BOX01---------------------------------------------*/     
		// nLeft   := 05   //Margem em milímetros a esquerda
		// nBottom := 110  //Margem em milímetros do topo
		// nRight  := 95   //Margem em milímetros a direita
		// nTop    := 120  //Margem em milímetros do final
		nLeft   := 07   //Margem em milímetros a esquerda
		nBottom := 70  //Margem em milímetros do topo
		nRight  := 17   //Margem em milímetros a direita
		nTop    := 150  //Margem em milímetros do final
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
		nLeft   := 19   //Margem em milímetros a esquerda
		nBottom := 70  //Margem em milímetros do topo
		nRight  := 29   //Margem em milímetros a direita
		nTop    := 130  //Margem em milímetros do final 
		nExpess := 1    //Expessura da borda          
		MSCBBOX(nLeft-1,nBottom,nRight-1,nTop + 20,nExpess) //Monta Box

		nFTitle         := 2 //Tamanho Fonte Titulo
		nFDesc          := 1 //Tamanho Fonte Descricão

		cDesc          := ALLTRIM(_CINGRED)
		cInitTitle      := CalcInit(cDesc,nFDesc,nBottom, nTop, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA

		If (Len(cDesc)*nFDesc) > nTop - nBottom
			nTamMax := (nTop - nBottom)/(nFDesc*0.90)
			nLin    := mlcount(cDesc,nTamMax)
			nPos    := nLeft
			For i := 1 to nLin
				nPos := (nPos - (nLeft - nRight)/nLin)
				If nPos == nRight 
					MSCBSAY(nPos-1,cInitTitle,memoline(cDesc,nTamMax,i)     ,"B",cValToChar(nFDesc),"1,1")     //Subtitulo
				Else
					MSCBSAY(nPos-0.45,cInitTitle,memoline(cDesc,nTamMax,i)     ,"B",cValToChar(nFDesc),"1,1")     //Subtitulo
				EndIf
			Next
		Else
			nPos    := nLeft - (((nLeft - nRight)/3)*2)
			MSCBSAY(nPos,cInitTitle,cDesc     ,"B",cValToChar(nFDesc),"1,1")     //Subtitulo
		EndIf
		/*---------------------------------FIM BOX02-----------------------------------------*/

		/*---------------------------------BOX03---------------------------------------------*/                        
		nLeft   := 29  //Margem em milímetros a esquerda
		nBottom := 70  //Margem em milímetros do topo
		nRight  := 32   //Margem em milímetros a direita
		nTop    := 150  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          

		nFTitle         := 2 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descricão

		cDesc := _cCons
		cInitTitle      := CalcInit(cDesc,nFTitle,nBottom, nTop, "CENTER")    //Calcula posicao inicio titulo - ESQUERDA
		nPos := nLeft - (((nLeft - nRight)/3)*3)-0.5
		MSCBSAY(nPos,cInitTitle,cDesc,"B",cValToChar(nFTitle),"1,1")     //Subtitulo
		/*---------------------------------FIM BOX03-----------------------------------------*/

		/*---------------------------------BOX04.01---------------------------------------------*/                        
		nLeft   := 33   //Margem em milímetros a esquerda
		nBottom := 70   //Margem em milímetros do topo
		nRight  := 40   //Margem em milímetros a direita
		nTop    := 95  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descricão

		cTitle := "DATA DE PRODUCAO"     
		cInitTitle      := CalcInit(cTitle,nFTitle,nBottom, nTop, "CENTER") //Calcula posicao inicio titulo - CENTRO

		nPos := (nLeft - ((nLeft - nRight)/2))-0.5
		MSCBSAY(nPos,cInitTitle,cTitle,"B",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc := ALLTRIM(_dPROD)
		cInitTitle      := CalcInit(cDesc,nFDesc,nBottom, nTop, "CENTER")
		nPos := nRight - 1
		MSCBSAY(nPos,cInitTitle,cDesc,"B",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX04.01-----------------------------------------*/

		/*---------------------------------BOX04.02---------------------------------------------*/                        
		nLeft   := 33   //Margem em milímetros a esquerda
		nBottom := 96   //Margem em milímetros do topo
		nRight  := 40   //Margem em milímetros a direita
		nTop    := 121  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descricão

		cTitle := "DATA DE VALIDADE"     
		cInitTitle      := CalcInit(cTitle,nFTitle,nBottom, nTop, "CENTER") //Calcula posicao inicio titulo - CENTRO

		nPos := (nLeft - ((nLeft - nRight)/2))-0.5
		MSCBSAY(nPos,cInitTitle,cTitle,"B",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc := ALLTRIM(_dVALID)
		cInitTitle      := CalcInit(cDesc,nFDesc,nBottom, nTop, "CENTER")
		nPos := nRight - 1
		MSCBSAY(nPos,cInitTitle,cDesc,"B",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX04.02-----------------------------------------*/

		/*---------------------------------BOX04.03---------------------------------------------*/                        
		nLeft   := 33   //Margem em milímetros a esquerda
		nBottom := 122   //Margem em milímetros do topo
		nRight  := 40   //Margem em milímetros a direita
		nTop    := 150  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descricão

		cTitle := "LOTE"     
		cInitTitle      := CalcInit(cTitle,nFTitle,nBottom, nTop, "CENTER") //Calcula posicao inicio titulo - CENTRO

		nPos := (nLeft - ((nLeft - nRight)/2))-0.5
		MSCBSAY(nPos,cInitTitle,cTitle,"B",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc := ALLTRIM(_cLOTE)
		cInitTitle      := CalcInit(cDesc,nFDesc,nBottom, nTop, "CENTER")
		nPos := nRight - 1
		MSCBSAY(nPos,cInitTitle,cDesc,"B",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX04.03-----------------------------------------*/


		/*---------------------------------BOX05.01---------------------------------------------*/                        
		nLeft   := 41   //Margem em milímetros a esquerda
		nBottom := 70   //Margem em milímetros do topo
		nRight  := 48   //Margem em milímetros a direita
		nTop    := 95  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descricão

		cTitle := "QUANTIDADE"     
		cInitTitle      := CalcInit(cTitle,nFTitle,nBottom, nTop, "CENTER") //Calcula posicao inicio titulo - CENTRO

		nPos := (nLeft - ((nLeft - nRight)/2))-0.5
		MSCBSAY(nPos,cInitTitle,cTitle,"B",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc := ALLTRIM(_cQTDE)
		cInitTitle      := CalcInit(cDesc,nFDesc,nBottom, nTop, "CENTER")
		nPos := nRight - 1
		MSCBSAY(nPos,cInitTitle,cDesc,"B",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX05.01-----------------------------------------*/

		/*---------------------------------BOX05.02---------------------------------------------*/                        
		nLeft   := 41   //Margem em milímetros a esquerda
		nBottom := 96   //Margem em milímetros do topo
		nRight  := 48   //Margem em milímetros a direita
		nTop    := 121  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descricão

		cTitle := "PESO BRUTO"     
		cInitTitle      := CalcInit(cTitle,nFTitle,nBottom, nTop, "CENTER") //Calcula posicao inicio titulo - CENTRO

		nPos := (nLeft - ((nLeft - nRight)/2))-0.5
		MSCBSAY(nPos,cInitTitle,cTitle,"B",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc := ALLTRIM(_cPESOB)
		cInitTitle      := CalcInit(cDesc,nFDesc,nBottom, nTop, "CENTER")
		nPos := nRight - 1
		MSCBSAY(nPos,cInitTitle,cDesc,"B",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX05.02-----------------------------------------*/

		/*---------------------------------BOX05.03---------------------------------------------*/                        
		nLeft   := 41   //Margem em milímetros a esquerda
		nBottom := 122   //Margem em milímetros do topo
		nRight  := 48   //Margem em milímetros a direita
		nTop    := 150  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda    
		MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descricão

		cTitle := "PESO LIQUIDO"     
		cInitTitle      := CalcInit(cTitle,nFTitle,nBottom, nTop, "CENTER") //Calcula posicao inicio titulo - CENTRO

		nPos := (nLeft - ((nLeft - nRight)/2))-0.5
		MSCBSAY(nPos,cInitTitle,cTitle,"B",cValToChar(nFTitle),"1,1")     //Titulo

		cDesc := ALLTRIM(_cPESOL)
		cInitTitle      := CalcInit(cDesc,nFDesc,nBottom, nTop, "CENTER")
		nPos := nRight - 1
		MSCBSAY(nPos,cInitTitle,cDesc,"B",cValToChar(nFDesc),"1,1")     //Subtitulo


		/*---------------------------------FIM BOX05.03-----------------------------------------*/

		/*---------------------------------BOX06---------------------------------------------*/                        
		nLeft   := 49   //Margem em milímetros a esquerda
		nBottom := 70  //Margem em milímetros do topo
		nRight  := 69   //Margem em milímetros a direita
		nTop    := 140  //Margem em milímetros do final 
		nExpess := 1    //Expessura da borda          
		//MSCBBOX(nLeft,nBottom,nRight,nTop,nExpess) //Monta Box

		nFTitle         := 1 //Tamanho Fonte Titulo
		nFDesc          := 1 //Tamanho Fonte Descricão

		cDesc          := ALLTRIM(_cINFNUT)
		cInitTitle      := CalcInit(cDesc,nFDesc,nBottom, nTop, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA

		If (Len(cDesc)*nFDesc) > nTop - nBottom
			nTamMax := (nTop - nBottom)/(nFDesc*0.9 )
			nLin    := mlcount(cDesc,nTamMax)
			nPos    := nLeft
			For i := 1 to nLin
				nPos := (nPos - (nLeft - nRight)/nLin)
				If nPos == nRight 
					MSCBSAY(nPos-1,nBottom+1,memoline(cDesc,nTamMax,i)     ,"B",cValToChar(nFDesc),"1,1")     //Subtitulo
				Else
					MSCBSAY(nPos-0.5,nBottom+1,memoline(cDesc,nTamMax,i)     ,"B",cValToChar(nFDesc),"1,1")     //Subtitulo
				EndIf
			Next
		Else
			nPos    := nLeft - (((nLeft - nRight)/3)*2)
			MSCBSAY(nPos,nBottom+1,cDesc     ,"B",cValToChar(nFDesc),"1,1")     //Subtitulo
		EndIf
		/*---------------------------------FIM BOX06-----------------------------------------*/
		
		/*---------------------------------BOX GLUTEN---------------------------------------------*/                        
		nLeft   := 74  //Margem em milímetros a esquerda
		nBottom := 105  //Margem em milímetros do topo
		nRight  := 78   //Margem em milímetros a direita
		nTop    := 150  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          

		nFTitle         := 2 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descricão

		cDesc := ALLTRIM(_cGluten)
		cInitTitle      := CalcInit(cDesc,nFTitle,nBottom, nTop, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA
		nPos := nLeft - (((nLeft - nRight)/3)*3)-0.5
		MSCBSAY(nPos,cInitTitle,cDesc,"B",cValToChar(nFTitle),"1,1")     //Subtitulo
		/*---------------------------------FIM BOX GLUTEN-----------------------------------------*/

		/*---------------------------------BOX07---------------------------------------------*/                        
		nLeft   := 80  //Margem em milímetros a esquerda
		nBottom := 105  //Margem em milímetros do topo
		nRight  := 84   //Margem em milímetros a direita
		nTop    := 150  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          

		nFTitle         := 2 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descricão

		cDesc := "PRODUTO: "+ ALLTRIM(SB1->B1_COD) 
		cInitTitle      := CalcInit(cDesc,nFTitle,nBottom, nTop, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA
		nPos := nLeft - (((nLeft - nRight)/3)*3)-0.5
		MSCBSAY(nPos,cInitTitle,cDesc,"B",cValToChar(nFTitle),"1,1")     //Subtitulo
		/*---------------------------------FIM BOX07-----------------------------------------*/
		
		/*---------------------------------BOX08---------------------------------------------*/                        
		nLeft   := 90  //Margem em milímetros a esquerda
		nBottom := 70  //Margem em milímetros do topo
		nRight  := 94   //Margem em milímetros a direita
		nTop    := 150  //Margem em milímetros do final
		nExpess := 1    //Expessura da borda          

		nFTitle         := 2 //Tamanho Fonte Titulo
		nFDesc          := 2 //Tamanho Fonte Descricão

		cDesc := ALLTRIM(_CSIF)
		cInitTitle      := CalcInit(cDesc,nFTitle,nBottom, nTop, "LEFTBOX")    //Calcula posicao inicio titulo - ESQUERDA
		nPos := nLeft - (((nLeft - nRight)/3)*3)-0.5
		MSCBSAY(nPos,cInitTitle,cDesc,"B",cValToChar(nFTitle),"1,1")     //Subtitulo
		/*---------------------------------FIM BOX08-----------------------------------------*/


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