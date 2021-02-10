Static Function LoadTree(lAt)
	Local cATivo := iif(lAt,"S / N","S")
	Local aGetArea := GetArea()



	if(Empty(ZRA->ZRA_PAI))
		Return
	EndIf
	oTree1:BeginUpdate()
	if(AllTrim(ZRA->ZRA_PAI) == "000000" .and. Alltrim(ZRA->ZRA_ATIVO) $ cAtivo )

		if(oTree1:Total()>0 .and. nContNo > 0)
			oTree1:EndTree()
		EndIf

		if(! oTree1:TreeSeek(ZRA->ZRA_COD))
			oTree1:AddTree(ZRA->ZRA_DESCRI + iif(Alltrim(ZRA->ZRA_ATIVO)=="N"," [DESATIVADO]","")+Space(24),.T.,"FOLDER5","FOLDER6",,,ZRA->ZRA_COD)
		EndIf

	Elseif(Alltrim(ZRA->ZRA_ATIVO) $ cAtivo)
		if(! oTree1:TreeSeek(ZRA->ZRA_COD))
			if oTree1:TreeSeek(ZRA->ZRA_PAI)
				oTree1:AddItem(ZRA->ZRA_DESCRI + iif(Alltrim(ZRA->ZRA_ATIVO)=="N"," [DESATIVADO]","")+Space(24),ZRA->ZRA_COD,iif(Alltrim(ZRA->ZRA_ATIVO)=="N","F5_VERM","GEOTRECHO"),,,,2)
			EndIf
		EndIf

	EndIf


	nContNo++
	ZRA->(DbSkip())
	if(ZRA->(EOF()))
		nContNo := 0
		oTree1:EndTree()
		RestArea(aGetArea)
		oTree1:EndUpdate()
		Return
	EndIf
	LoadTree(lShowDe)

Return
