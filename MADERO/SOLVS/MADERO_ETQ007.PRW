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
!Nome              ! ETQ007                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina Emissão etiqueta CAIXA VERDE VAZADA - MADERO     !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 20/05/18                                                !
+------------------+---------------------------------------------------------+
*/
User Function ETQ007(aEtqAuto)
	Local  _aArea 	:= GetArea()
	Local  _cperg 	:= "ETQ007    "
	Local  _cOP		:= ""
	Local  _nQtde	:= 0
	Local  _cImp	:= ""
	Local  _cPROD	:= ""
	Local  _cTpEtq	:= "007" //Etiqueta CAIXA VERDE VAZADA
	Local  _lret	:= .T.
	Local  _lrimp	:= .F.
	Local  _nY		:=0

	Local _CDESC   	:= ''
	Local _cLOTE   	:= ''
	Local cModelo,lTipo,nPortIP,cServer,cEnv,cFila
	Local cPorta 	:= Nil

	DEFAULT aEtqAuto := NIL

	If !aEtqAuto == NIL
		_COP    :=aETQAuto[1]
		_CPROD  :=aETQAuto[2]
		_CLOTE  :=aETQAuto[3]
		_nQtde  :=aEtqAuto[4]
		_cImp   :=aEtqAuto[5]
		_lRIMP  :=iif(len(aEtqAuto)==6,aEtqAuto[1][6],.F.)
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
	//TESTE
	//_CIMP := "000001"
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
		_cLOTE   	:= Alltrim(SC2->C2_XLOTE)//Alltrim(Str(Val(SC2->C2_XLOTE)))

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


		MSCBPRINTER(cModelo,cPorta,,,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH)+"\ETQ007")
		MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")

		MSCBBEGIN(_nQtde,6)


		cProd := SUBSTR(ALLTRIM(_CDESC),1,35)
		cTamFontIn := 6
		nLeft   := 25
		nRight  := 75
		nTop    := 50
		nBottom := 13
		If (Len(cProd)*cTamFontIn) > nRight - nLeft
			nTamMax := (nRight - nLeft)/(cTamFontIn*0.7)
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


		MSCBSAY(25,3,"LOTE: "+_CLOTE,"N","5","1,1")

		MSCBEND()    

		MSCBCLOSEPRINTER() //Finaliza a impressão
	Endif

	RestArea(_aArea)
	
RETURN