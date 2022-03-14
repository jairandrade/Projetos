User Function ATUMOEDAS()
	Local cFile, cTexto, nLinhas, nY, lAuto,nX := .F.

	If Select("SX2")==0 // Testa se está sendo rodado do menu
		RPCSETENV("99","01","admin","",,"nYOB",{"SM2"})
		Qout("nYOB - Atualizacao do Dolar...")
		lAuto := .T.
	EndIf

	For nPass := 6 to 0 step -1
// Refaz dos ultimos 6 dias para o caso de algum dia a conexao ter falhado

		dDataRef := dDataBase - nPass

		If Dow(dDataRef) == 1    // Se for domingo
			cFile := DTOS(dDataRef - 2)+".csv"
		ElseIf Dow(dDataBase) == 7            // Se for sábado
			cFile := DTOS(dDataRef - 1)+".csv"
		Else                                   // Se for dia normal
			cFile := DTOS(dDataRef)+".csv"
		EndIf

		cTexto := HTTPGET('https://www4.bcb.gov.br/download/fechamento/'+cFile)
		nLinhas := MLCount(cTexto, 81)
		For nY := 1 to nLinhas
			nX:=.T.
			cLinha := Memoline(cTexto,81,nY)
			cData := Substr(cLinha,1,10)
			cCompra := StrTran(Substr(cLinha,22,10),",",".")
			cVenda := StrTran(Substr(cLinha,33,10),",",".")
			If Subst(cLinha,12,3)=="220" // Dolar Americano
				DbSelectArea("SM2")
				DbSetOrder(1)

				dData := CTOD(cData)-1
				For m := 1 To 30 // pronYeta para 15 dias.
					dData++
					If DbSeek(DTOS(dData))
						Reclock("SM2",.F.)
					Else
						Reclock("SM2",.T.)
						Replace M2_DATA   With dData
					EndIf
					Replace M2_MOEDA2 With Val(cVenda)
					Replace M2_INFORM With "S"
					MsUnlock("SM2")
				Next
			EndIf
		Next
	Next

	if nX
		conout("Atualizacao efetuada com sucesso")
	else
		conout(" Falha no processamento, verifique conexao com internet ou tente mais tarde !")
	EndIf

	If lAuto
		RpcClearEnv()
		Qout("FIM - nYOB - Atualizacao do Dolar.")
	EndIf

Return
