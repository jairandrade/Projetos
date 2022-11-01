#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} AtuDescep
	Programa para atualiza��o do campo RA_DESCEP
	@type  user Function
	@author isabel.noguti
	@since 04/01/2022
	@version 1.0
	/*/
User Function AtuDescep()
	Local aButtons	:= {}
	Local aSays		:= {}
	Local nOpcA		:= 0

	aAdd(aSays,OemToAnsi( "Este programa tem como objetivo ajustar o campo Controle de Matr�cula TSV (RA_DESCEP)" ))
	aAdd(aSays,OemToAnsi( "dos registros de Trabalhadores Sem Vinculo (SRA) j� integrados ao TAF/Middleware," ))
	aAdd(aSays,OemToAnsi( "com evento S-2300 gerado contendo informa��o de matr�cula de acordo com o Leiaute S-1.0" ))
	aAdd(aSays,OemToAnsi( "sem alimenta��o do campo de controle." ))
	aAdd(aSays,OemToAnsi( "" ))
	aAdd(aSays,OemToAnsi( "A execu��o deste programa � destinada apenas ao cen�rio acima, ap�s atualiza��o" ))
	aAdd(aSays,OemToAnsi( "do ambiente conforme DRHROTPRT-3320." ))

	aAdd(aButtons, { 14, .T., {|| ShellExecute("open","https://tdn.totvs.com/x/IsBDJw","","",1) } } )
	aAdd(aButtons, { 1, .T., {|o| nOpcA := 1,FechaBatch() } } )
	aAdd(aButtons, { 2, .T., {|o| FechaBatch() } } )

	FormBatch( "Atualiza��o RA_DESCEP", aSays, aButtons )

	If nOpcA == 1
		If SRA->(ColumnPos("RA_DESCEP")) > 0 .And. X3USO( GetSX3Cache("RA_DESCEP", "X3_USADO"))
			ProcGpe( {|lEnd| fProc()},,,.T.)
		else
			MsgInfo("Efetue a atualiza��o do dicion�rio de dados no ambiente conforme a issue especificada para execu��o desta rotina.")
		EndIf
	Endif

Return

/*/{Protheus.doc} fProc
	Processamento da atualiza��o do campo RA_DESCEP para integra��es S-2300 conforme matr�cula do leiaute S-1.0
/*/
Static Function fProc()
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local cWhere	:= ""
	Local cTSV		:= "%" + fSqlIn( StrTran(fCatTrabEFD("TSV"), "|" , ""), 3 ) + "%"
	Local cAliasQry	:= GetNextAlias()

	If ChkFile("C9V") .And. C9V->(ColumnPos("C9V_MATTSV")) > 0
		cWhere := "SELECT C9V_MATTSV FROM " + RetSqlName("C9V")
		cWhere += " WHERE C9V_NOMEVE='S2300' AND C9V_MATTSV<>'' AND D_E_L_E_T_=' '"
	EndIf

	If ChkFile("RJE")
		If !Empty(cWhere)
			cWhere += " UNION "
		EndIf
		cWhere += "SELECT RJE_KEY FROM " + RetSqlName("RJE")
		cWhere += " WHERE RJE_EVENTO='S2300' AND RJE_KEY<>'' AND D_E_L_E_T_=' '"
	EndIf

	If !Empty(cWhere)
		cWhere := "%" + cWhere + "%"

		BeginSqL alias cAliasQry
			SELECT RA_FILIAL, RA_MAT
			FROM %Table:SRA% SRA
			WHERE
				SRA.RA_CODUNIC IN (%Exp:cWhere%)
				AND SRA.RA_CATEFD IN (%Exp:cTSV%)
				AND SRA.RA_DESCEP <> '1'
				AND SRA.%NotDel%
		EndSql

		If (cAliasQry)->(Eof())
			MsgInfo("N�o foram encontrados registros da SRA correspondentes ao cen�rio para atualiza��o.")
		Else
			SRA->( dbSetOrder(1) )
			While (cAliasQry)->(!Eof())
				If SRA->( dbSeek((cAliasQry)->RA_FILIAL + (cAliasQry)->RA_MAT) )
					RecLock("SRA",.F.)
						SRA->RA_DESCEP := "1"
					SRA->(MsUnlock())
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo

			MsgInfo("Processamento finalizado com sucesso.")
		EndIf
	else
		MsgInfo("N�o foram encontrados registros de integra��o do evento S-2300 no leiaute S-1.0 com matr�cula para verifica��o.")
	EndIf

	(cAliasQry)->( dbCloseArea() )
	RestArea(aArea)

Return lRet
