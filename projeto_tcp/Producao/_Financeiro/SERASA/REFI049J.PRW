#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'

User Function REFI049J

Local _lRet		:= .F.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Operacao de Inclusao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	lPeInclui
	
	cQuery := " SELECT SE1.R_E_C_N_O_ RECNOSE1 "
	If AllTrim( Upper( TcGetDb() ) ) $ 'ORACLE/INFORMIX'
		cQuery += "		,NVL(SEF.R_E_C_N_O_,0) RECNOSEF, NVL(SA1.R_E_C_N_O_,0) RECNOSA1 "
	Else
		cQuery += "		,ISNULL(SEF.R_E_C_N_O_,0) RECNOSEF, ISNULL(SA1.R_E_C_N_O_,0) RECNOSA1 "
	EndIf
	cQuery += " 	, 0.00 PESALDO " + CR
	cQuery += " FROM "+	RetSqlName("SE1") + " SE1 " + CR
	cQuery += " INNER JOIN "+	RetSqlName("SA1") + " SA1 ON (SA1.A1_FILIAL = '"+xFilial('SA1')+"' AND SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA AND SA1.D_E_L_E_T_ = ' ')" + CR
	cQuery += " LEFT JOIN "+ RetSqlName("SEF") + " SEF ON (SEF.EF_FILIAL = SE1.E1_FILIAL AND SEF.EF_NUM = SE1.E1_NUM AND SEF.EF_BANCO = SE1.E1_BCOCHQ AND SEF.EF_AGENCIA = SE1.E1_AGECHQ AND SEF.EF_CONTA = SE1.E1_CTACHQ AND ( SEF.EF_ALINEA2 IN ('12','13','14') OR SEF.EF_ALINEA1 IN ('12','13','14') ) AND SEF.D_E_L_E_T_ = ' ' ) " + CR

	//cQuery += " WHERE SE1.D_E_L_E_T_ = ' ' " + CR
	//cQuery += " AND E1_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"' " + CR
	//cQuery += " AND E1_SALDO > 0 " + CR

	cQuery += " AND E1_SALDO BETWEEN " + cValToChar(ZP6->ZP6_VLRMIN) + " AND " + cValToChar(ZP6->ZP6_VLRMAX) + CR

	If AllTrim( Upper( TcGetDb() ) ) $ 'ORACLE/INFORMIX'
		cQuery += " AND ( TO_DATE('" + DtoS(dDataBase) + "','YYYYMMDD') - TO_DATE(E1_VENCREA,'YYYYMMDD') ) >= " + cValToChar(ZP6->ZP6_DIASVE) + CR
	Else
		cQuery += " AND ( CAST(CONVERT(DATETIME,'" + DtoS(dDataBase) + "',112) - CONVERT(DATETIME,E1_VENCREA,112) AS INTEGER) ) >= " + cValToChar(ZP6->ZP6_DIASVE) + CR
	EndIf
	cQuery += " AND E1_VENCREA BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' " + CR
	cQuery += " AND A1_PEFIN <> 'N' "
	cQuery += " AND (A1_PESSOA = 'J' OR " + CR
	If AllTrim( Upper( TcGetDb() ) ) $ 'ORACLE/INFORMIX'
		cQuery += "       (CASE WHEN SUBSTR(NVL(TRIM(A1_DTNASC),'0101'),5,4) <= TO_CHAR(SYSDATE,'MMDD') " + CR
		cQuery += "             THEN TO_NUMBER(EXTRACT(YEAR FROM SYSDATE)) - TO_NUMBER(EXTRACT(YEAR FROM TO_DATE(NVL(TRIM(A1_DTNASC),'20500101'),'YYYYMMDD'))) " + CR
		cQuery += "             ELSE TO_NUMBER(EXTRACT(YEAR FROM SYSDATE)) - TO_NUMBER(EXTRACT(YEAR FROM TO_DATE(NVL(TRIM(A1_DTNASC),'20500101'),'YYYYMMDD'))) - 1 END ) >= " + cValToChar(ZP6->ZP6_IDADE) + " ) " + CR
	Else
		cQuery += "       (CASE WHEN SUBSTRING(ISNULL(RTRIM(LTRIM(A1_DTNASC)),'0101'),5,4) <= RIGHT(CONVERT(VARCHAR,GETDATE(),112),4) " + CR
		cQuery += "             THEN CAST(DATEPART(YYYY,GETDATE()) AS INTEGER) - CAST(DATEPART(YYYY,CONVERT(DATETIME,ISNULL(A1_DTNASC,'20500101'),112)) AS INTEGER) " + CR
		cQuery += "             ELSE CAST(DATEPART(YYYY,GETDATE()) AS INTEGER) - CAST(DATEPART(YYYY,CONVERT(DATETIME,ISNULL(A1_DTNASC,'20500101'),112)) AS INTEGER) - 1 END ) >= " + cValToChar(ZP6->ZP6_IDADE) + " ) " + CR
	EndIf
	//Termo de Confissao de Divida vazio - sera tratado na outra Query
	If SE1->(FieldPos('E1_TERCOM')) <> 0
		cQuery += " AND E1_TERCOM = ' ' " + CR
	EndIf
	
	If !Empty(MV_PAR13)
		cQuery += " AND SE1.E1_TIPO IN (" + U_REFI052J(MV_PAR13,TamSX3('E1_TIPO')[1]) + ") " + CR
	EndIf
	
	If !lReEnvia
		cQuery += " AND E1_STPEFIN = ' ' " + CR
	EndIf
	
	//Script do Termo de Confissao (titulos com o Campo E1_TERCOM preenchido ! - Pegar apenas 1 registro com o total do Termo.
	If SE1->(FieldPos('E1_TERCOM')) <> 0
		
		cQuery += " UNION ALL " + CR
		
		cQuery += " SELECT "
		If AllTrim( Upper( TcGetDb() ) ) $ 'ORACLE/INFORMIX'
			cQuery += "     		TO_NUMBER(SUBSTR(MAX(SE1.E1_STPEFIN || TRIM(TO_CHAR(SE1.R_E_C_N_O_,'0000000'))),2,7)) RECNOSE1 " + CR
		Else
			cQuery += "     		CAST(SUBSTRING(MAX(SE1.E1_STPEFIN + RIGHT('000000'+RTRIM(LTRIM(CAST(SE1.R_E_C_N_O_ AS VARCHAR))),6)),2,7) AS INTEGER) RECNOSE1 " + CR
		EndIf
		cQuery += "         ,0 RECNOSEF " + CR
		If AllTrim( Upper( TcGetDb() ) ) $ 'ORACLE/INFORMIX'
			cQuery += "         ,NVL(MIN(SA1.R_E_C_N_O_),0) RECNOSA1  " + CR
		Else
			cQuery += "         ,ISNULL(MIN(SA1.R_E_C_N_O_),0) RECNOSA1  " + CR
		EndIf
		cQuery += "         ,SUM(SE1.E1_SALDO) PESALDO " + CR
		cQuery += "  FROM "+	RetSqlName("SE1") + " SE1 " + CR
		cQuery += "  INNER JOIN "+	RetSqlName("SA1") + " SA1 ON (SA1.A1_FILIAL = '  ' AND SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA AND SA1.D_E_L_E_T_ = ' ') " + CR
		cQuery += "  WHERE SE1.D_E_L_E_T_ = ' '  " + CR
		cQuery += "  AND E1_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"' " + CR
		cQuery += "  AND E1_SALDO BETWEEN " + cValToChar(ZP6->ZP6_VLRMIN) + " AND " + cValToChar(ZP6->ZP6_VLRMAX) + CR
		If AllTrim( Upper( TcGetDb() ) ) $ 'ORACLE/INFORMIX'
			cQuery += " AND ( TO_DATE('" + DtoS(dDataBase) + "','YYYYMMDD') - TO_DATE(E1_VENCREA,'YYYYMMDD') ) >= " + cValToChar(ZP6->ZP6_DIASVE) + CR
		Else
			cQuery += " AND ( CAST(CONVERT(DATETIME,'" + DtoS(dDataBase) + "',112) - CONVERT(DATETIME,E1_VENCREA,112) AS INTEGER) ) >= " + cValToChar(ZP6->ZP6_DIASVE) + CR
		EndIf
		cQuery += "  AND E1_VENCREA BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' " + CR
		cQuery += "  AND (A1_PESSOA = 'J' OR  " + CR
		If AllTrim( Upper( TcGetDb() ) ) $ 'ORACLE/INFORMIX'
			cQuery += "       (CASE WHEN SUBSTR(NVL(TRIM(A1_DTNASC),'0101'),5,4) <= TO_CHAR(SYSDATE,'MMDD') " + CR
			cQuery += "             THEN TO_NUMBER(EXTRACT(YEAR FROM SYSDATE)) - TO_NUMBER(EXTRACT(YEAR FROM TO_DATE(NVL(TRIM(A1_DTNASC),'20500101'),'YYYYMMDD'))) " + CR
			cQuery += "             ELSE TO_NUMBER(EXTRACT(YEAR FROM SYSDATE)) - TO_NUMBER(EXTRACT(YEAR FROM TO_DATE(NVL(TRIM(A1_DTNASC),'20500101'),'YYYYMMDD'))) - 1 END ) >= " + cValToChar(ZP6->ZP6_IDADE) + " ) " + CR
		Else
			cQuery += "       (CASE WHEN SUBSTRING(ISNULL(RTRIM(LTRIM(A1_DTNASC)),'0101'),5,4) <= RIGHT(CONVERT(VARCHAR,GETDATE(),112),4) " + CR
			cQuery += "             THEN CAST(DATEPART(YYYY,GETDATE()) AS INTEGER) - CAST(DATEPART(YYYY,CONVERT(DATETIME,ISNULL(A1_DTNASC,'20500101'),112)) AS INTEGER) " + CR
			cQuery += "             ELSE CAST(DATEPART(YYYY,GETDATE()) AS INTEGER) - CAST(DATEPART(YYYY,CONVERT(DATETIME,ISNULL(A1_DTNASC,'20500101'),112)) AS INTEGER) - 1 END ) >= " + cValToChar(ZP6->ZP6_IDADE) + " ) " + CR
		EndIf
		cQuery += "  AND SE1.E1_TERCOM <> ' ' " + CR
		
		If !Empty(MV_PAR13)
			cQuery += " AND SE1.E1_TIPO IN (" + U_REFI052J(MV_PAR13,TamSX3('E1_TIPO')[1]) + ") " + CR
		EndIf
		
		cQuery += "  GROUP BY SE1.E1_TERCOM " + CR
		
		If !lReEnvia
			cQuery += " HAVING MAX(SE1.E1_STPEFIN) = ' ' " + CR
		EndIf
		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Operacao de Exclusao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else
	
	cQuery := " SELECT SE1.R_E_C_N_O_ RECNOSE1 "
	If AllTrim( Upper( TcGetDb() ) ) $ 'ORACLE/INFORMIX'
		cQuery += "		, NVL(SEF.R_E_C_N_O_,0) RECNOSEF, NVL(SA1.R_E_C_N_O_,0) RECNOSA1 "
	Else
		cQuery += "		, ISNULL(SEF.R_E_C_N_O_,0) RECNOSEF, ISNULL(SA1.R_E_C_N_O_,0) RECNOSA1 "
	EndIf
	cQuery += "			, 0.00 PESALDO " + CR
	cQuery += " FROM "+	RetSqlName("SE1") + " SE1 " + CR
	cQuery += " INNER JOIN "+	RetSqlName("SA1") + " SA1 ON (SA1.A1_FILIAL = '"+xFilial('SA1')+"' AND SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA AND SA1.D_E_L_E_T_ = ' ')" + CR
	cQuery += " LEFT JOIN "+ RetSqlName("SEF") + " SEF ON (SEF.EF_FILIAL = SE1.E1_FILIAL AND SEF.EF_NUM = SE1.E1_NUM AND SEF.EF_BANCO = SE1.E1_BCOCHQ AND SEF.EF_AGENCIA = SE1.E1_AGECHQ AND SEF.EF_CONTA = SE1.E1_CTACHQ AND SEF.D_E_L_E_T_ = ' ' ) " + CR
	cQuery += " WHERE SE1.D_E_L_E_T_ = ' ' " + CR
	cQuery += " AND E1_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"' " + CR
	cQuery += " AND E1_SALDO = 0 " + CR
	cQuery += " AND E1_BAIXA BETWEEN '" + DtoS(MV_PAR11) + "' AND '" + DtoS(MV_PAR12) + "' " + CR
	
	//Termo de Confissao de Divida vazio - sera tratado na outra Query
	If SE1->(FieldPos('E1_TERCOM')) <> 0
		cQuery += " AND E1_TERCOM = ' ' " + CR
	EndIf
	
	If !Empty(MV_PAR13)
		cQuery += " AND SE1.E1_TIPO IN (" + U_REFI052J(MV_PAR13,TamSX3('E1_TIPO')[1]) + ") " + CR
	EndIf
	
	If !lReEnvia
		cQuery += " AND E1_STPEFIN IN ('1','2') " + CR       //Somente os que foram Enviados ou Re-Enviados na inclusao
	Else
		cQuery += " AND E1_STPEFIN IN ('1','2','3','4') " + CR       //Enviados / Re-Enviados na inclusao e na Exclusao
	EndIf
	
	//Script do Termo de Confissao (titulos com o Campo E1_TERCOM preenchido ! - Pegar apenas 1 registro com o total do Termo.
	If SE1->(FieldPos('E1_TERCOM')) <> 0
		
		cQuery += " UNION ALL " + CR
		
		cQuery += " SELECT "
		If AllTrim( Upper( TcGetDb() ) ) $ 'ORACLE/INFORMIX'
			cQuery += "     	TO_NUMBER(SUBSTR(MAX(SE1.E1_STPEFIN || TRIM(TO_CHAR(SE1.R_E_C_N_O_,'0000000'))),2,7)) RECNOSE1 " + CR
		Else
			cQuery += "     	CAST(SUBSTRING(MAX(SE1.E1_STPEFIN + RIGHT('000000'+RTRIM(LTRIM(CAST(SE1.R_E_C_N_O_ AS VARCHAR))),6)),2,7) AS INTEGER) RECNOSE1 " + CR
		EndIf
		cQuery += "         ,0 RECNOSEF " + CR
		If AllTrim( Upper( TcGetDb() ) ) $ 'ORACLE/INFORMIX'
			cQuery += "      ,NVL(MIN(SA1.R_E_C_N_O_),0) RECNOSA1  " + CR
		Else
			cQuery += "      ,ISNULL(MIN(SA1.R_E_C_N_O_),0) RECNOSA1  " + CR
		EndIf
		cQuery += "         ,SUM(SE1.E1_SALDO) PESALDO " + CR
		cQuery += " FROM "+	RetSqlName("SE1") + " SE1 " + CR
		cQuery += " INNER JOIN "+	RetSqlName("SA1") + " SA1 ON (SA1.A1_FILIAL = '  ' AND SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA AND SA1.D_E_L_E_T_ = ' ') " + CR
		cQuery += " WHERE SE1.D_E_L_E_T_ = ' '  " + CR
		cQuery += " AND E1_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"' " + CR
		cQuery += " AND E1_SALDO = 0 "
		cQuery += " AND E1_BAIXA BETWEEN '" + DtoS(MV_PAR11) + "' AND '" + DtoS(MV_PAR12) + "' " + CR
		cQuery += " AND SE1.E1_TERCOM <> ' ' " + CR
		
		If !Empty(MV_PAR13)
			cQuery += " AND SE1.E1_TIPO IN (" + U_REFI052J(MV_PAR13,TamSX3('E1_TIPO')[1]) + ") " + CR
		EndIf
		
		cQuery += "  GROUP BY SE1.E1_TERCOM " + CR
		
		If !lReEnvia
			cQuery += " HAVING MAX(SE1.E1_STPEFIN) IN ('1','2') " + CR      			//Somente os que foram Enviados ou Re-Enviados na inclusao
		Else
			cQuery += " HAVING MAX(SE1.E1_STPEFIN) IN ('1','2','3','4') " + CR      //Enviados / Re-Enviados na inclusao e na Exclusao
		EndIf
		
	EndIf
	
EndIf

If lPEInclui
	If GetNewPar("MV_WSQLPFI",.T.)
		MemoWrit("C:\TEMP\GET_TIT_PEFIN_INCLUI_SERASA.SQL",cQuery)
	EndIf
Else
	If GetNewPar("MV_WSQLPFI",.T.)
		MemoWrit("C:\TEMP\GET_TIT_PEFIN_EXCLUI_SERASA.SQL",cQuery)
	EndIf
EndIf

cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTrb, .F., .T.)



Return( _lRet )
