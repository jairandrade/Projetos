User Function MT103MNT()
Local aHeadSev := PARAMIXB[1]
Local aColsSev := PARAMIXB[2]///  carga do aColsSev ///
Local nPosPed  := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_PEDIDO" })
Local nPosItm  := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMPC" })
Local nPosNat  := aScan(aHeadSev,{|x| AllTrim(x[2]) == "EV_NATUREZ" })
Local nPosPerc := aScan(aHeadSev,{|x| AllTrim(x[2]) == "EV_PERC" })
Local nPosAlia := aScan(aHeadSev,{|x| AllTrim(x[2]) == "EV_ALI_WT" })
Local nPosRecn := aScan(aHeadSev,{|x| AllTrim(x[2]) == "EV_REC_WT" })
Local nPosDoc  := aScan(aHeadSev,{|x| AllTrim(x[2]) == "EV_IDDOC" })
Local cChvPed  := ''
Local lDifPeds := .F.
Local cAlias 
Local nX

For nX := 1 To Len(aCols)

	If !aCols[nX][Len(aHeader)+1]
	
		IF(!EMPTY(aCols[nX][nPosPed]))
			if !empty(cChvPed) .and. SUBSTR(cChvPed,1,6) != aCols[nX][nPosPed]
				lDifPeds := .T.
			endif
			
			cChvPed := aCols[nX][nPosPed]+ aCols[nX][nPosItm]
		ENDIF
	
	Endif

Next nX

IF !EMPTY(cChvPed) .AND. Len(aHeadSev) > 0
	cAlias := getNextAlias()
	BeginSQL Alias cAlias
	
		SELECT SUM((CX_PERC * C7_TOTAL)/100) AS VALOR, SUM(CX_PERC) AS PERC  , CX_XNATURE 
		FROM %TABLE:SC7% SC7
		INNER JOIN %TABLE:SC1% SC1 ON C7_FILIAL = C1_FILIAL AND C7_NUMSC = C1_NUM AND C7_ITEMSC = C1_ITEM AND SC1.%NotDel%
		INNER JOIN %TABLE:SCX% SCX ON CX_FILIAL = C1_FILIAL AND CX_SOLICIT = C1_NUM AND CX_ITEMSOL = C1_ITEM AND SCX.%NotDel%
		WHERE  SC7.%NotDel% AND C7_NUM||C7_ITEM = %EXP:cChvPed%
		GROUP BY CX_XNATURE
	EndSQL
	//SEMPRE QUE USAR O COUNT, COLOCAR DBTOP DEPOIS	
	Count To nNumRegs
	(cAlias)->(DBGOTOP())
	
	////Se tiver apenas 1 natureza, não precisa ratear
	IF nNumRegs > 1
		aColsSev := {}
		while !(cAlias)->(Eof())
			AADD(aColsSev,Array(Len(aHeadSev)+1) )
		
			aColsSev[LEN(aColsSev)][nPosNat]  := (cAlias)->CX_XNATURE
			aColsSev[LEN(aColsSev)][nPosPerc] := (cAlias)->PERC
			aColsSev[LEN(aColsSev)][nPosAlia] := 'SEV'
			aColsSev[LEN(aColsSev)][nPosRecn] := 0
			IF nPosDoc > 0
				aColsSev[LEN(aColsSev)][nPosDoc]  := SPACE(TamSX3("EV_IDDOC")[1])
			ENDIF
			aColsSev[LEN(aColsSev)][Len(aHeadSev)+1] := .F.
			
			(cAlias)->(dbSkip())
		enddo
	ELSE
		lDifPeds := .F.
	endif
	
	(cAlias)->(DbCloseArea())	
ENDIF

IF LEN(aColsSev) == 0 .AND. Len(aHeadSev) > 0
	AADD(aColsSev,Array(Len(aHeadSev)+1) )
	aColsSev[LEN(aColsSev)][nPosNat]  := SPACE(TamSX3("ED_CODIGO")[1])
	aColsSev[LEN(aColsSev)][nPosPerc] := 0
	aColsSev[LEN(aColsSev)][nPosAlia] := 'SEV'
	aColsSev[LEN(aColsSev)][nPosRecn] := 0
	IF nPosDoc > 0
		aColsSev[LEN(aColsSev)][nPosDoc]  := SPACE(TamSX3("EV_IDDOC")[1])
	ENDIF
	aColsSev[LEN(aColsSev)][Len(aHeadSev)+1] := .F.
endif

Return aColsSev    
