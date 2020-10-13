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
!Nome              ! ETQ011                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina Emissão etiqueta INGREDIENTES VERDES - MADERO    !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 20/05/18                                                !
+------------------+---------------------------------------------------------+
*/
User Function ETQ011(aEtqAuto)
	Local  _aArea 	:= GetArea()
	Local  _cperg 	:= "ETQ011    "
	Local  _cOP		:= ""
	Local  _nQtde	:= 0
	Local  _cImp	:= ""
	Local  _cPROD	:= ""
	Local  _cTpEtq	:= "011" //Etiqueta INGREDIENTES VERDES
	Local  _lret	:= .T.
	Local  _lrimp	:= .F.
	Local _CDESC    := ''
	Local _dPROD    := ''
	Local _dVALID   := ''
	Local _cINGRED  := ''
	Local _CINFNUT  := ''
	Local _cLOTE   	:= ''
	Local _cCons   	:= ''
	Local _cGluten  := ''
	Local _cLactos 	:= ''
	Local _cPESO    := ''
	Local _CSIF     := ''
	Local _cInfComp1:= "DESTINADO EXCLUSIVAMENTE AO USO INSTITUCIONAL"
	Local _cInfComp2:= "PROIBIDA A VENDA NO VAREJO"
	Local _cInfComp3:= "PROIBIDA A VENDA FRACIONADA"
	Local _cInfComp4:= "INDUSTRIA BRASILEIRA"
	Local _cInfComp5:= ''
	Local _cInfComp6:= ''
	Local _cInfComp7:= ''
	Local _cInfComp8:= ''
	Local _nY
	Local cModelo,lTipo,nPortIP,cServer,cEnv,cFila
	Local cPorta 	:= Nil
	
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
		
		If Empty(_CDESC := Posicione("SB5",1,xFilial("SB5")+SB1->B1_COD,"B5_CEME"))
			_CDESC := SB1->B1_DESC
		EndIf
		_dPROD    	:= DTOC(SC2->C2_XDTFIR)
		_dVALID   	:= DTOC(SC2->C2_XDTVAL)
		_cINGRED  	:= "INGREDIENTES: " + ALLTRIM(MSMM(SB1->B1_CODPROC))
		_CINFNUT  	:= ""+substr(ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+SB1->B1_COD,"B1_XINFNUT")),1,800)
		_cLOTE   	:= Alltrim(SC2->C2_XLOTE)//Alltrim(Str(Val(SC2->C2_XLOTE)))
		_cCons   	:= ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"W1"+SB1->B1_XCONS,"X5_DESCRI"))
		_cGluten  	:= IIF(SB1->B1_XGLUT="1","CONTÉM GLUTEN",IIF(SB1->B1_XGLUT="2","NAO CONTÉM GLUTEN",""))
		_cLactos 	:= IIF(SB1->B1_XLACTOS="S","CONTÉM LACTOSE",IIF(SB1->B1_XLACTOS="N","NÃO CONTÉM LACTOSE",IIF(SB1->B1_XLACTOS="P","PODE CONTER TRAÇOS DE LACTOSE","CONTÉM DERIVADOS DE LEITE")))
		_cPESO    	:= STRZERO(SB1->B1_XPEMB,4)
		_CSIF     	:= "Registro no Ministerio da Agricultura SIF/DIPOA sob No." + SB1->B1_XRMAPA
		_cInfComp5	:= "PRODUZIDO POR: " + alltrim(SM0->M0_NOMECOM)
		_cInfComp6	:= "CNPJ "+Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC"))
		_cInfComp7	:= ALLTRIM(SM0->M0_ENDENT)+", "+ ALLTRIM(SM0->M0_BAIRENT)+", "+ alltrim(SM0->M0_CIDENT) + "/" + SM0->M0_ESTENT
		_cInfComp8	:= "CEP: "+SM0->M0_CEPENT
		_CALERG		:= 'Alérgicos: ' + AllTrim(Posicione("Z61",1,xFilial('Z61')+ALLTRIM(SB1->B1_XALERG),"Z61_ALERG"))//AllTrim(Posicione("SX5",1,xFilial('SX5')+'W2'+ALLTRIM(SB1->B1_XALERG),"X5_DESCRI")) 
		
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


		MSCBPRINTER(cModelo,cPorta,,,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH)+"\ETQ011")
		MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")

		MSCBLOADGRF("\images\logoetiqueta.bmp")
		MSCBBEGIN(_nQtde,6)

		MSCBGRAFIC(17,48,"logoetiqueta")
		cProd := ALLTRIM(_CDESC)//SUBSTR(ALLTRIM(_CDESC),1,35)
		cTamFontIn := 3//4
		nLeft   := 17
		nRight  := 75
		nTop    := 48.5
		nBottom := 40//35.5
		If (Len(cProd)*cTamFontIn) > nRight - nLeft
			nTamMax := (nRight - nLeft)/(cTamFontIn*0.6)
			nLin    := mlcount(cProd,nTamMax)
			nPos := nTop -1
			nPosIni := nPos
			For _nY := 1 to nLin
				nPos := (nPos - (nPosIni - nBottom)/nLin)
				If nPos == nBottom
					MSCBSAY(nLeft,nPos,memoline(cProd,nTamMax,_nY)     ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
				Else
					MSCBSAY(nLeft,nPos,memoline(cProd,nTamMax,_nY)     ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
				EndIf
			Next
		Else
			nPos := nTop - 1
			MSCBSAY(nLeft,nPos,cProd    ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
		EndIf

		cIngr := ALLTRIM(_CINGRED)
		cTamFontIn := 1
		nLeft   := 17
		nRight  := 80
		nTop    := 40//36.5
		nBottom := 34//28.5
		If (Len(cIngr)*cTamFontIn) > nRight - nLeft
			nTamMax := (nRight - nLeft)/(cTamFontIn*1.2)
			nLin    := mlcount(cIngr,nTamMax)
			nPos := nTop -1
			nPosIni := nPos
			For _nY := 1 to nLin
				nPos := (nPos - (nPosIni - nBottom)/nLin)
				If nPos == nBottom
					MSCBSAY(nLeft,nPos,memoline(cIngr,nTamMax,_nY)     ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
				Else
					MSCBSAY(nLeft,nPos,memoline(cIngr,nTamMax,_nY)     ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
				EndIf
			Next
		Else
			nPos := nTop - 1
			MSCBSAY(nLeft,nPos,cIngr    ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
		EndIf

		cAlerg := ALLTRIM(_CALERG)
		cTamFontIn := 1
		nLeft   := 17
		nRight  := 70
		nTop    := 33.5
		nBottom := 27.5
		If (Len(cAlerg)*cTamFontIn) > nRight - nLeft
			nTamMax := (nRight - nLeft)/(cTamFontIn)
			nLin    := mlcount(cAlerg,nTamMax)
			nPos := nTop
			nPosIni := nPos
			For _nY := 1 to nLin
				nPos := (nPos - (nPosIni - nBottom)/nLin)
				If nPos == nBottom
					MSCBSAY(nLeft,nPos,memoline(cAlerg,nTamMax,_nY)     ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
				Else
					MSCBSAY(nLeft,nPos,memoline(cAlerg,nTamMax,_nY)     ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
				EndIf
			Next
		Else
			nPos := nTop
			MSCBSAY(nLeft,nPos,cAlerg    ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
		EndIf

		MSCBSAY(17,25.5,"MODO DE CONSERVACAO: ","N","1","1,1")
		MSCBSAY(42,25.5,ALLTRIM(_cCONS),"N","1","1,1")

		MSCBSAY(17,23.5,ALLTRIM(_cGluten),"N","1","1,1")
		MSCBSAY(45,23.5,ALLTRIM(_cLactos),"N","1","1,1")

		MSCBSAY(17,20.5,"DATA FABRICACAO: ","N","2","1")
		MSCBSAY(40,20.5,_dProd,"N","2","1,1")

		MSCBSAY(17,17.5,"DATA VALIDADE: ","N","2","1")
		MSCBSAY(40,17.5,_dVALID,"N","2","1,1")

		MSCBSAY(52,17.5,"LOTE: ","N","3","1")
		MSCBSAY(61,17.5,_CLOTE,"N","2","1")

		MSCBSAY(20,15,_CINFCOMP1,"N","1","1,1")
		MSCBSAY(30,13,_CINFCOMP2,"N","1","1,1")
		MSCBSAY(28,11,_CINFCOMP3,"N","1","1,1")
		MSCBSAY(32,9,_CINFCOMP4,"N","1","1,1")
		MSCBSAY(20,7,_CINFCOMP5,"N","1","1,1")
		MSCBSAY(32,5,_CINFCOMP6,"N","1","1,1")
		MSCBSAY(22,3,_CINFCOMP7,"N","1","1,1")
		MSCBSAY(35,1,_CINFCOMP8,"N","1","1,1")

		MSCBEND()

		MSCBCLOSEPRINTER() //Finaliza a impressão

	Endif

	RestArea(_aArea)

Return(nil)