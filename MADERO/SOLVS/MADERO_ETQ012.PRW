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
!Nome              ! ETQ012                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina Emissão Etiqueta Produto                         !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 20/05/18                                                !
+------------------+---------------------------------------------------------+
*/
User Function ETQ012(aEtqAuto)
	
	Local  _aArea 		:= GetArea()
	Local  _cperg 		:= "ETQ012    "
	Local  _cOP			:= ""
	Local  _nQtde		:= 0
	Local  _cImp		:= ""
	Local  _cPROD		:= ""
	Local  _cTpEtq		:= "012" //Etiqueta INGREDIENTES VERDES
	Local  _lret		:= .T.
	Local  _lRImp		:= .F.
	Local _lSubProd 	:= .F.

	Local _fim     		:= chr(13)+chr(10)
	Local _oFile   		:= Nil
	Local _cSaida  		:= CriaTrab("",.F.)
	Local _cPorta  		:= "LPT1"
	Local _CDESC   		:= ''
	Local _dPROD   		:= ''
	Local _dVALID  		:= ''
	Local _cLOTE   		:= ''
	Local _cValid  		:= ''
	Local _cPESO   		:= ''
	Local _nSemana 		:= 0
	Local _DATA1		:= FIRSTYDATE(DDATABASE)
	Local _DATA2		:= DDATABASE
	Local _NDIAS		:= (_DATA2-_DATA1)+1
	Local _nY	   		:= 0
	Local nPontoMM 		:= 0
	Local QRCODE		:= ""
	Local _nX			:= 0 
	Local cCodEt2		:= 0
	Local cCNPJRestau	:= ""
	Local cQuery 		:= ""
	Local cQuant		:= ""
	Local cModelo,lTipo,nPortIP,cServer,cEnv,cFila,lrvWin 
	Local cPorta 		:= Nil

	Private _cAliasSC2 := ""

	DEFAULT aEtqAuto := NIL

	AJUSTASX1()

	If !aEtqAuto == NIL
		_COP    :=aETQAuto[1][1]
		_CPROD  :=aETQAuto[1][2]
		_CLOTE  :=aETQAuto[1][3]
		_nQtde  :=aEtqAuto[1][4]
		_cImp   :=aEtqAuto[1][5]
		_lRIMP  :=aEtqAuto[1][6]
		_lSubProd   :=aETQAuto[1][7]
		_lUM	:=aETQAuto[1][8]
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

	IF _LRET
		IF (!EMPTY(_COP) .OR. (!EMPTY(_CPROD) .AND. !EMPTY(_CLOTE)))
			//
			_cAliasSC2 := GetNextAlias()
			//_cLote:=strzero(val(_cLote),TamSX3("C2_XLOTE")[1])
			//
			cQuery := "SELECT * FROM " + RETSQLNAME("SC2") + " SC2, " + RETSQLNAME("SD3") + " SD3, " + RETSQLNAME("SB1") + " SB1 "
			cQuery += "LEFT JOIN " + RETSQLNAME("SB5") + " SB5 ON SB1.B1_COD = SB5.B5_COD "
			cQuery += "WHERE SC2.D_E_L_E_T_ != '*' "
			cQuery += "AND SC2.C2_FILIAL = '" + xFilial("SC2") + "' "
			cQuery += "AND SB1.D_E_L_E_T_ != '*' "
			cQuery += "AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
			If _lSubProd //SubProduto
				cQuery += "AND SB1.B1_COD  = '"+_CPROD+"' "
			Else
				cQuery += "AND SC2.C2_PRODUTO = SB1.B1_COD "
			EndIf
			If !empty(_cop)
				cQuery += "AND SC2.C2_NUM = '" + substr(_cOP,1,TamSX3("C2_NUM")[1])    + "' "
				cQuery += "AND SC2.C2_ITEM= '" + substr(_cOP,TamSX3("C2_NUM")[1]+1,TamSX3("C2_ITEM")[1])    + "' "
				cQuery += "AND SC2.C2_SEQUEN = '" + substr(_cOP,TamSX3("C2_NUM")[1]+TamSX3("C2_ITEM")[1]+1,TamSX3("C2_SEQUEN")[1])+ "' "
				cQuery += "AND D3_OP = '"+_cOP+"'	"
				cQuery += "AND D3_FILIAL = '" + xFilial("SD3") + "'	"
				cQuery += "AND D3_CF = 'PR0'	"
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
			If (_cAliasSC2)->(Eof())
				MSGINFO("Ordem de Producao/Produto/Lote não Cadastrado !!!")
				_lret:=.F.
			Else
				DBSELECTAREA("ZIB")
				DBSETORDER(1)
				ZIB->(DBSEEK(XFILIAL("ZIB")+(_cAliasSC2)->B1_COD+_cTpEtq))
				IF !ZIB->(FOUND())
					MSGINFO("Etiqueta não Cadastrada para este Produto!!")
					_lret:=.F.
				ElseIf !_lRImp
					IF EMPTY(_nQtde)
						_nQtde:=(_cAliasSC2)->C2_QUANT
					Endif
					_nQtde:=_nQtde*ZIB->ZIB_QTDE
				EndIf
			EndIf
			//
		Else
			MSGINFO("Parametros Invalido para Emissao de Etiqueta...Verifique!!")
		EndIf
	EndIf

	If _LRET

		_CDESC   	:= (_cAliasSC2)->B1_DESC
		_dPROD   	:= DTOC(STOD((_cAliasSC2)->C2_XDTFIR))
		_dVALID  	:= DTOC(STOD((_cAliasSC2)->C2_XDTVAL))
		_cLOTE   	:= (_cAliasSC2)->C2_XLOTE//Alltrim(Str(Val((_cAliasSC2)->C2_XLOTE)))
		_cValid  	:= Alltrim((_cAliasSC2)->D3_DTVALID)
		_cPESO   	:= STRZERO((_cAliasSC2)->B1_XPEMB,4)
		cQuant		:= AllTrim(Transform(IIF((_cAliasSC2)->B5_QEI > 0 ,(_cAliasSC2)->B5_QEI,1) , PesqPict("SC2","C2_QUANT")))

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
		
		//calculo semana
		If (_ndias/7)>int(_ndias/7)
			_NSEMANA:=int(_NDIAS/7)+1
		Else
			_NSEMANA:=int(_NDIAS/7)
		Endif
		
		TEXTO:={}
		
		//INICIO  
		IF _CIMP="000001" .OR._CIMP="000002"  
			aadd(texto,"^JMB^FS"+_fim)    
		ENDIF
		/*
		MSCBPRINTER(cModelo,cPorta,,,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH))
		MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")

		cCodigo := CBGrvEti('01',{(_cAliasSC2)->B1_COD,_nQtde,,,,,,,,(_cAliasSC2)->D3_LOCAL,(_cAliasSC2)->D3_OP,,,,,(_cAliasSC2)->D3_LOTECTL,,STOD((_cAliasSC2)->D3_DTVALID),,,,,,,})

		dbSelectArea("CB0")
		CB0->(dbSetOrder(1))
		CB0->(DbSeek(xFilial("CB0")+cCodigo))
		cCodEt2 := Upper(FWUUIDV4())

		RecLock("CB0", .F.)
		CB0->CB0_CODET2 := cCodEt2
		CB0->(MsUnLock())

		aSM0:=SM0->(GetArea())
		SM0->(dbSetOrder(1))
		cCNPJRestau:=SM0->M0_CGC

		DbSelectArea("SA2")
		SA2->(dbSetOrder(3))
		SA2->(dbSeek(xFilial("SA2")+cCNPJRestau))


		cQuery := "SELECT DISTINCT SA5.A5_PRODUTO,SB1.B1_COD, SB1.B1_XCODEXT    " + CRLF
		cQuery += "FROM SA5020 SA5  								" + CRLF
		cQuery += "INNER JOIN SB1020 SB1   							" + CRLF
		cQuery += "ON SB1.B1_COD = SA5.A5_PRODUTO AND  				" + CRLF
		cQuery += "SB1.D_E_L_E_T_ = ' '    							" + CRLF
		cQuery += "WHERE   											" + CRLF
		cQuery += "SA5.A5_FORNECE = '"+SA2->A2_COD+"' AND   		" + CRLF
		cQuery += "SA5.A5_LOJA = '"+SA2->A2_LOJA+"' AND  			" + CRLF
		cQuery += "SA5.A5_CODPRF = '"+(_cAliasSC2)->B1_COD+"' AND   " + CRLF
		cQuery += "SA5.D_E_L_E_T_ = ' '    							" + CRLF
		cQuery += "UNION ALL   										" + CRLF
		cQuery += "SELECT DISTINCT SA51.A5_PRODUTO,SB11.B1_COD, SB11.B1_XCODEXT 	" + CRLF
		cQuery += "FROM SA5010 SA51    								" + CRLF
		cQuery += "INNER JOIN SB1010 SB11  							" + CRLF
		cQuery += "ON SB11.B1_COD = SA51.A5_PRODUTO AND    			" + CRLF
		cQuery += "SB11.D_E_L_E_T_ = ' '   							" + CRLF
		cQuery += "WHERE   											" + CRLF
		cQuery += "SA51.A5_FORNECE = '"+SA2->A2_COD+"' AND   		" + CRLF
		cQuery += "SA51.A5_LOJA = '"+SA2->A2_LOJA+"' AND  			" + CRLF
		cQuery += "SA51.A5_CODPRF = '"+(_cAliasSC2)->B1_COD+"' AND  " + CRLF
		cQuery += "SA51.D_E_L_E_T_ = ' '  							" + CRLF	

		cQuery := ChangeQuery(cQuery)
		cAlQry := MPSysOpenQuery(cQuery)


		If !empty(_cop)
			QRCODE := '(01)' + AllTrim(CB0->CB0_CODPRO) + '(10)' + AllTrim(_cLOTE) + '(21)' + AllTrim((_cAliasSC2)->B1_COD) + '(17)' + _cValid + '(90)' + AllTrim((cAlQry)->B1_COD) + '(91)' + AllTrim((cAlQry)->B1_XCODEXT) + '(99)' + AllTrim(cCodEt2)
		EndIf
		*/
		
		For _nX := 1 to iif(_lUM,1,_nQtde) 

			MSCBPRINTER(cModelo,cPorta,,,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH))
		MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")

		cCodigo := CBGrvEti('01',{(_cAliasSC2)->B1_COD,iif(_lUM,_nQtde,_nQtde/_nQtde),,,,,,,,(_cAliasSC2)->D3_LOCAL,(_cAliasSC2)->D3_OP,,,,,(_cAliasSC2)->D3_LOTECTL,,STOD((_cAliasSC2)->D3_DTVALID),,,,,,,})

		dbSelectArea("CB0")
		CB0->(dbSetOrder(1))
		CB0->(DbSeek(xFilial("CB0")+cCodigo))
		cCodEt2 := Upper(FWUUIDV4())

		RecLock("CB0", .F.)
		CB0->CB0_CODET2 := cCodEt2
		CB0->(MsUnLock())

		aSM0:=SM0->(GetArea())
		SM0->(dbSetOrder(1))
		cCNPJRestau:=SM0->M0_CGC

		DbSelectArea("SA2")
		SA2->(dbSetOrder(3))
		SA2->(dbSeek(xFilial("SA2")+cCNPJRestau))


		cQuery := "SELECT DISTINCT SA5.A5_PRODUTO,SB1.B1_COD, SB1.B1_XCODEXT    " + CRLF
		cQuery += "FROM SA5020 SA5  								" + CRLF
		cQuery += "INNER JOIN SB1020 SB1   							" + CRLF
		cQuery += "ON SB1.B1_COD = SA5.A5_PRODUTO AND  				" + CRLF
		cQuery += "SB1.D_E_L_E_T_ = ' '    							" + CRLF
		cQuery += "WHERE   											" + CRLF
		cQuery += "SA5.A5_FORNECE = '"+SA2->A2_COD+"' AND   		" + CRLF
		cQuery += "SA5.A5_LOJA = '"+SA2->A2_LOJA+"' AND  			" + CRLF
		cQuery += "SA5.A5_CODPRF = '"+(_cAliasSC2)->B1_COD+"' AND   " + CRLF
		cQuery += "SA5.D_E_L_E_T_ = ' '    							" + CRLF
		cQuery += "UNION ALL   										" + CRLF
		cQuery += "SELECT DISTINCT SA51.A5_PRODUTO,SB11.B1_COD, SB11.B1_XCODEXT 	" + CRLF
		cQuery += "FROM SA5010 SA51    								" + CRLF
		cQuery += "INNER JOIN SB1010 SB11  							" + CRLF
		cQuery += "ON SB11.B1_COD = SA51.A5_PRODUTO AND    			" + CRLF
		cQuery += "SB11.D_E_L_E_T_ = ' '   							" + CRLF
		cQuery += "WHERE   											" + CRLF
		cQuery += "SA51.A5_FORNECE = '"+SA2->A2_COD+"' AND   		" + CRLF
		cQuery += "SA51.A5_LOJA = '"+SA2->A2_LOJA+"' AND  			" + CRLF
		cQuery += "SA51.A5_CODPRF = '"+(_cAliasSC2)->B1_COD+"' AND  " + CRLF
		cQuery += "SA51.D_E_L_E_T_ = ' '  							" + CRLF	

		cQuery := ChangeQuery(cQuery)
		cAlQry := MPSysOpenQuery(cQuery)


		If !empty(_cop)
			QRCODE := '(01)' + AllTrim(CB0->CB0_CODPRO) + '(10)' + AllTrim(_cLOTE) + '(21)' + AllTrim((_cAliasSC2)->B1_COD) + '(17)' + _cValid + '(90)' + AllTrim((cAlQry)->B1_COD) + '(91)' + AllTrim((cAlQry)->B1_XCODEXT) + '(99)' + AllTrim(cCodEt2)
		EndIf


			MSCBBEGIN(1,6)  

			MSCbModelo('DPL',cModelo,@nPontoMM)

			nXPixel    := nPontoMM *if(25==NIL,0,20)
			nYPixel    := nPontoMM *if(5==NIL,0,5)
			nXPixel     := Strzero(val(str(nXPixel,5,3))*100,4)
			nYPixel     := strzero(val(str(nYPixel,5,3))*100,4)

			TEXTO:={}

			aadd(texto,"<STX>KcDE300" +_fim)
			aadd(texto,"D11" +_fim)
			If nPontoMM == 0.03937008
				aadd(texto,"1W1D55000"+nXPixel+nYPixel+"2HM,"+QRCODE+_fim) //300DPI
			Else
				aadd(texto,"1W1D33000"+nXPixel+nYPixel+"2HM,"+QRCODE +_fim) //200DPI
			EndIf
			
			aadd(texto,"E" +_fim)

			MSCBSAY(40,40,"LOTE: " +_cLOTE								,"N","3","1,1")
			MSCBSAY(40,35,"VALIDADE: " +_dVALID							,"N","3","1,1")
			MSCBSAY(40,30,"SEMANA: " + alltrim(str(_nSemana))			,"N","3","1,1")
			MSCBSAY(40,25,"QTDE: " + Transform(iif(_lUM,_nQtde,_nQtde/_nQtde),PesqPict("SH6","H6_QTDPROD"))	    		,"N","3","1,1")
			MSCBSAY(40,20,"COD.PROD.: " + ALLTRIM((_cAliasSC2)->B1_COD)	,"N","3","1,1")

			cProd := ALLTRIM(_CDESC)
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
				For _nY := 1 to nLin
					nPos := (nPos - (nPosIni - nBottom)/nLin)
					If nPos == nBottom
						MSCBSAY(nLeft,nPos,memoline(cProd,Nil,_nY)     ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
					Else
						MSCBSAY(nLeft,nPos,memoline(cProd,nTamMax,_nY)     ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
					EndIf
				Next
			Else
				nPos := nTop - 1
				MSCBSAY(nLeft,nPos,cProd    ,"N",cValToChar(cTamFontIn),"1,1")     //Subtitulo
			EndIf


			For _nY := 1 To Len(texto)
				MSCBWRITE(texto[_nY])     
			Next _nY

			MSCBEND()  
		Next _nX

		MSCBCLOSEPRINTER() //Finaliza a impressão
	Endif

	RestArea(_aArea)

Return(nil)

//Ajusta SX1
Static Function AjustaSX1()
	Local aSX1   := {}
	Local aEstrut	:= {}
	Local i      := 0
	Local j      := 0
	Local lSX1	 := .F.

	aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM"  ,"X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO"   ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL",;
	"X1_GSC"    ,"X1_VALID"  ,"X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01"  ,"X1_VAR02"  ,"X1_DEF02"  ,;
	"X1_DEFSPA2","X1_DEFENG2","X1_CNT02"  ,"X1_VAR03" ,"X1_DEF03"  ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03"  ,"X1_VAR04"  ,"X1_DEF04",;
	"X1_DEFSPA4","X1_DEFENG4","X1_CNT04"  ,"X1_VAR05" ,"X1_DEF05"  ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05"  ,"X1_F3"     ,"X1_PYME","X1_GRPSXG",;
	"X1_HELP","X1_PICTURE","X1_IDFIL"}

	//Exemplo:
	// AADD(aSX1,{})
	//			"01"	,"02","03"					,"04"		,"05"	,"06"	,"07","08"                  ,"09","10","11","12","13"	   ,"14"	,"15"	,"16"	,"17"	,"18","19"	,"20"	,"21","22"	,"23","24"	,"25","26"	,"27","28"	,"29","30"	,"31","32"	,"33","34"	,"35","36"	,"37","38"	,"39","40"	,"41","42"	,"43"
	aAdd(aSX1,{"ETQ012","01","Ordem de Producao?"	,""			,""		,"MV_CH1","C",TamSX3("D3_OP")[1]     ,0  ,0   ,"G" ,""  ,"MV_PAR01",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","","SC2ETQ"	,"S","","","",""})
	aAdd(aSX1,{"ETQ012","02","Produto?"	   			,""			,""		,"MV_CH2","C",TamSX3("D3_COD")[1],0  ,0   ,"G" ,""  ,"MV_PAR02",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","","SB1"	,"S","","","",""})
	aAdd(aSX1,{"ETQ012","03","Lote?"		   		,""			,""		,"MV_CH3","C",TamSX3("C2_XLOTE")[1]  ,0  ,0   ,"G" ,""  ,"MV_PAR03",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","",""		,"S","","","",""})
	aAdd(aSX1,{"ETQ012","04","Qtde Etiqueta?"		,""			,""		,"MV_CH4","N",04                     ,0  ,0   ,"G" ,""  ,"MV_PAR04",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","",""		,"S","","","",""})
	aAdd(aSX1,{"ETQ012","05","Impressora?"			,""			,""		,"MV_CH5","C",TamSX3("CB5_CODIGO")[1],0  ,0   ,"G" ,""  ,"MV_PAR05",""		,""			,""			,"","",""			,""			,""			,"","","","","","","","","","","","","","","","","CB5"	,"S","","","",""})

	ProcRegua(Len(aSX1))

	dbSelectArea("SX1")
	dbSetOrder(1)
	For i:= 1 To Len(aSX1)
		If !Empty(aSX1[i][1])

			if ! dbSeek( Padr( aSX1[i,1] , Len( X1_GRUPO ) , ' ' ) + aSX1[i,2] )

				lSX1 := .T.
				RecLock("SX1",.T.)

				For j:=1 To Len(aSX1[i])
					If !Empty(FieldName(FieldPos(aEstrut[j])))
						FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
					EndIf
				Next j

				dbCommit()
				MsUnLock()
				IncProc("Atualizando Perguntas Etiquetas....")
			EndIf
		EndIf
	Next i

Return