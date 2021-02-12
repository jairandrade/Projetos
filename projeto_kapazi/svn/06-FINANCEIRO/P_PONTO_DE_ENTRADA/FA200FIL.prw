#Include "topconn.ch"

User Function FA200FIL
	lRet:=.F.
	cQry:=" SELECT R_E_C_N_O_ REC, *"
	cQry+=" from "+RetSqlName('SE1')+" "
	cQry+=" WHERE E1_IDCNAB='"+ALLTRIM(cNumTit)+"' "
	If Select("TRE1")<>0
		TRE1->(DBCloseArea())
	EndIF
	TcQuery cQry New alias "TRE1"
	SE1->(DBGOTO(TRE1->REC))
	lRet:=.T.
	While !TRE1->(eof())

		If ALLTRIM(SUBSTR(TRE1->E1_NUM,2)) $ alltrim(SUBSTR(PARAMIXB[16],117,10))

			SE1->(DBGOTO(TRE1->REC))
			lRet:=.T.
		EndIF
		TRE1->(DBSkip())
	EndDO

Return lRet


User Function FR650FIL
	lRet:=.F.
	lRet:=.F.
	IF MV_PAR07==1
		cQry:=" SELECT R_E_C_N_O_ REC, *"
		cQry+=" from "+RetSqlName('SE1')+" "                                                                                                                                   
		cQry+=" WHERE E1_IDCNAB='"+ALLTRIM(cNumTit)+"' "
		If Select("TRE1")<>0
			TRE1->(DBCloseArea())
		EndIF
		TcQuery cQry New alias "TRE1"
		SE1->(DBGOTO(TRE1->REC))

		While !TRE1->(eof())

			If ALLTRIM(SUBSTR(TRE1->E1_NUM,2)) $ alltrim(SUBSTR(PARAMIXB[1][14],117,10))

				SE1->(DBGOTO(TRE1->REC))
				lRet:=.T.
			EndIF
			TRE1->(DBSkip())
		EndDO

	eLSE
		lRet:=.T.
	enDif

Return lRet


//FUNCAO EXECUTADA NA INICIALIZACAO PADRAO DO BROWSE PARA MOSTRAR A CARTERIRA
//RODRIGO SLISINSKI  06/08/2013
User Function SETCART()
	cRet:=""

	if !Empty(SE1->E1_BOLETO)
		cRet:='109'
	Else
		If !Empty(SE1->E1_NUMBOR)
			cRet:='109'      // ALTERADO 21/12/2016 -- ANDRE/RSAC -- NAO SERA MAIS UTILIZADO A CARTEIRA 112
		EndIF
	EndIF

Return cRet
