#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TopConn.CH"

/*/{Protheus.doc} EST552
Rotina para Procresssar o Inventário
@type function
@version 12.1.0.25
@author Mario L. B. Faria
@since 30/07/2018
/*/
User Function EST552()
Local aArea := GetArea()
	
	If Aviso("","Confirma o processamento do inventario da filial "+xFilial("Z23")+" na data de "+Dtoc(dDataBase)+"?",{"Sim","Não"},2) == 1
		Processa({ || PROCSB7() },"Aguarde, Processando Inventário...")
	EndIf

	RestArea(aArea)
	
Return

/*/{Protheus.doc} PROCSB7
Processa o invetário
@type function
@version 12.1.0.25
@author Mario L. B. Faria
@since 30/07/2018
/*/
Static Function PROCSB7()
Local cQuery	:= ""
Local cAlQry	:= ""
Local cModAux	:= nModulo
Local cDtaAux	:= dDataBase
Local nRecnoZA0	:= 0 
Local cProces   := "Inventario - Contagem"
Local lBlocZ23	:= .F.
Local aDtaZWE	:= {}
Local lErrProc	:= .F.
Local cEntid    := "Z23"
Local aRet      := {}
Local cMsg      := ""
Local nx        := 0
Local cMsgFim	:= ""
Local cIdProc   := ""

	ProcRegua(0)

	cQuery := "	SELECT " + CRLF 
	cQuery += "	    Z23.R_E_C_N_O_ Z23_REGNO " + CRLF
	cQuery += "	FROM " + RetSqlName("Z23") + " Z23 " + CRLF 
	cQuery += "	WHERE " + CRLF  
	cQuery += "	        Z23_FILIAL     = '" + xFilial("Z23") + "'  " + CRLF
	cQuery += "	    AND Z23_DATA       = '" + DtoS(dDataBase) + "' " + CRLF 
	cQuery += "	    AND Z23_DTCONF    != ' ' " + CRLF 
	cQuery += "	    AND Z23_DTPROC     = ' ' " + CRLF
	cQuery += "	    AND Z23.D_E_L_E_T_ = ' ' " + CRLF 

	cQuery := ChangeQuery(cQuery)
	cAlQry := MPSysOpenQuery(cQuery)
	
	dbSelectArea("ZA0")
	dbSelectArea("Z05")
	dbSelectArea("Z23")
	
	If (cAlQry)->(Eof())
		Help("",1,"Processamento Inventário",,"Não ha dados para processamento na data de "+DtoC(dDataBase),4,1)
		lErrProc := .T.
	Else
	
		nModulo := 4
    
	    While !(cAlQry)->(Eof()) .and. !lErrProc
	    
	    	Begin Transaction
	    
				Z23->(dbGoTo((cAlQry)->Z23_REGNO))
			    dDataBase := Z23->Z23_DATA	    
				cIdProc   := Z23->Z23_ID
		    	
				cMsg:="Processo iniciado."
				aAdd(aDtaZWE,{xFilial("ZWE"),dDataBase,cProces,Z23->Z23_ID,dDataBase,Z23->Z23_ID,cEntid,"1","INVENTARIO","","L",0,cMsg,""})

				// -> Verifica se existe registros na SB7
				SB7->(DbSetOrder(4))
				SB7->(DbSeek(xFilial("SB7")+"INV"+Z23->Z23_ID+DtoS(dDataBase)))
				If !SB7->(Found())
					lErrProc := .T.	
					cMsg     :="Inventario com ID "+Z23->Z23_ID+" da filial "+xFilial("Z23") + " do dia "+DtoC(dDataBase)+" nao encontrado no arquivo de contagens do Protheus (Tabela SB7)." 
					aAdd(aDtaZWE,{xFilial("ZWE"),dDataBase,cProces,Z23->Z23_ID,dDataBase,Z23->Z23_ID,cEntid,"1","INVENTARIO","","E",0,cMsg,""})
					Help("",1,"Processamento Inventário",,cMsg,4,1)
					DisarmTransaction()
				Else
					If SB7->B7_STATUS == "2"
						lErrProc := .T.	
						cMsg     :="Inventario com ID "+Z23->Z23_ID+" da filial "+xFilial("Z23") + " do dia "+DtoC(dDataBase)+" já processado." 
						aAdd(aDtaZWE,{xFilial("ZWE"),dDataBase,cProces,Z23->Z23_ID,dDataBase,Z23->Z23_ID,cEntid,"1","INVENTARIO","","W",0,cMsg,""})
						Help("",1,"Processamento Inventário",,cMsg,4,1)
						DisarmTransaction()	
					EndIf	
				EndIf		    	
								
				// -> Se Ok, continua
		    	If !lErrProc

					// -> Bloqueia o registro	
					If RecLock("Z23",.F.)
						lBlocZ23 := .T.
					Else
						lErrProc := .T.	
						cMsg     :="Inventario com ID "+Z23->Z23_ID+" da filial "+xFilial("Z23") + " do dia "+DtoC(dDataBase)+" ja esta em processamento." 
						aAdd(aDtaZWE,{xFilial("ZWE"),dDataBase,cProces,Z23->Z23_ID,dDataBase,Z23->Z23_ID,cEntid,"1","INVENTARIO","","E",0,cMsg,""})
						Help("",1,"Processamento Inventário",,cMsg,4,1)
						Z23->(MSUnlock())
						DisarmTransaction()
					EndIf	
		    	
			    	//-> Verifica Centro de Custo ZA0
			    	nRecnoZA0 := VerZA0()
		    	
			    	If nRecnoZA0 == 0
						cMsg     := "Não ha Centro de Custo para a filial: " + cFilAnt
						lErrProc := .T.	
						Help("",1,"Processamento Inventário",,cMsg,4,1)
						aAdd(aDtaZWE,{xFilial("ZWE"),dDataBase,cProces,Z23->Z23_ID,dDataBase,Z23->Z23_ID,cEntid,"1","INVENTARIO","","E",0,cMsg,""})
						Z23->(MSUnlock())
						DisarmTransaction()
					Else

		    			aRet:= ValFecha(@aDtaZWE)
	    			
			    		If aRet[01]

							// -> Posiciona no centro de cuso da filial
							ZA0->(DbGoTo(nRecnoZA0))

							SetMVValue("MTA340", "MV_PAR01", dDataBase)           // Data de processamento do inventário 
							SetMVValue("MTA340", "MV_PAR02", ZA0->ZA0_CUSTO)      // Centro de custo
							SetMVValue("MTA340", "MV_PAR03", 2)                   // Mostra lancamento contábil (2=Nao)
							SetMVValue("MTA340", "MV_PAR04", 2)                   // Aglutina lancamento contábil (2=Nao)
							SetMVValue("MTA340", "MV_PAR05", "               ")   // Produto inicial
							SetMVValue("MTA340", "MV_PAR06", "ZZZZZZZZZZZZZZZ")   // Produto final
							SetMVValue("MTA340", "MV_PAR07", "  ")                // Armazém inicial
							SetMVValue("MTA340", "MV_PAR08", "ZZ")                // Armazém final
							SetMVValue("MTA340", "MV_PAR09", "    ")              // Grupo inicial
							SetMVValue("MTA340", "MV_PAR10", "ZZZZ")              // Grupo final
							SetMVValue("MTA340", "MV_PAR11", "INV" + Z23->Z23_ID) // Documento inicial
							SetMVValue("MTA340", "MV_PAR12", "INV" + Z23->Z23_ID) // Documento final
							SetMVValue("MTA340", "MV_PAR13", 2)                   // Considera os empenhos (2=Todos)
							SetMVValue("MTA340", "MV_PAR14", 2)                   // marca o processamento para atualizar o custo da SD3
							MATA340(.T.,"INV"+Z23->Z23_ID,.F.)
			    			
		    				// -> Se Ok, continua...
							If !lErrProc
						
								lErrProc:=!ValPrcInv(@aDtaZWE)	
	
			    				// -> Grava processamento na Z23
			    				If !lErrProc
		    						Z23->Z23_DTPROC := Date()
		    						Z23->Z23_HRPROC := Time()
		    						Z23->Z23_USERPR := UsrRetName(RetCodUsr())
		    					Else
									lErrProc :=.T.
									cMsg     := "Erro ao finalizar a gravacao do inventario com ID "+Z23->Z23_ID+" da filial "+xFilial("Z23") + " do dia "+DtoC(dDataBase)
									Help("",1,"Processamento Inventário",,cMsg,4,1)
									aAdd(aDtaZWE,{xFilial("ZWE"),dDataBase,cProces,Z23->Z23_ID,dDataBase,Z23->Z23_ID,cEntid,"1","INVENTARIO","","E",0,cMsg,""})
									Z23->(MSUnlock())
									DisarmTransaction()
		    					EndIf
						
							EndIf	
		    			
		    			Else
		    				
							lErrProc :=.T.
							cMsg     := aRet[2]
							Help("",1,"Processamento Inventário",,cMsg,4,1)
							aAdd(aDtaZWE,{xFilial("ZWE"),dDataBase,cProces,Z23->Z23_ID,dDataBase,Z23->Z23_ID,cEntid,"1","INVENTARIO","","E",0,cMsg,""})
							Z23->(MSUnlock())
							DisarmTransaction()

						EndIf
		
			    	EndIf

		    		//-> Verifica desbloqueio Z23
		    		Z23->(MSUnlock())

				EndIf	

	    	End Transaction

	    	(cAlQry)->(dbSkip())
	    
	    EndDo
	    
	EndIf

	(cAlQry)->(dbCloseArea())

	If !lErrProc
		cMsgFim := "Inventário com ID " + Z23->Z23_ID + " da filial " + Z23->Z23_FILIAL + " e data " + DtoC(Z23->Z23_DATA) + " processado com sucesso."	
	Else
		cMsgFim := "Inventário " + IIF(!Empty(cIdProc), "com ID " + cIdProc, "") + " da filial " + xFilial("Z23") + " e data " + DtoC(dDataBase) + " com erro de processamento."
	EndIf
	aAdd(aDtaZWE,{xFilial("ZWE"),dDataBase,cProces,Z23->Z23_ID,dDataBase,Z23->Z23_ID,cEntid,"1","INVENTARIO","",IIF(lErrProc,"E","L"),0,cMsgFim,""})

	// -> Gera dados de log
	dbSelectArea("ZWE")
	For nx:=1 to Len(aDtaZWE)
		RecLock("ZWE",.T.)
		ZWE_FILIAL	:= aDtaZWE[nx,01]
		ZWE_DATA	:= aDtaZWE[nx,02]
		ZWE_PROCES	:= aDtaZWE[nx,03]
		ZWE_DOCUM   := aDtaZWE[nx,04]
		ZWE_DTPROC  := aDtaZWE[nx,05]
		ZWE_ID		:= aDtaZWE[nx,06]
		ZWE_ENTID	:= aDtaZWE[nx,07]
		ZWE_CHAVE   := aDtaZWE[nx,08]
		ZWE_DESCP   := aDtaZWE[nx,09]
		ZWE_PROD    := aDtaZWE[nx,10]
		ZWE_TIPO	:= aDtaZWE[nx,11]
		ZWE_VALOR	:= aDtaZWE[nx,12]
		ZWE_DESC	:= aDtaZWE[nx,13]
		ZWE_DETAIL  := aDtaZWE[nx,14]
		ZWE->(msUnLock())
	Next nx

	nModulo		:= cModAux
	dDataBase	:= cDtaAux


	Help("",1,"Processamento Inventário",,cMsgFim,4,1)

Return

/*/{Protheus.doc} VerZA0
Verifica se possui cadastrado para filial
@type function
@version 
@author Mario L. B. Faria
@since 30/07/2018
@return numeric, RecNo do registro localizado
/*/
Static Function VerZA0()

Local nRet		:= 0
Local cQuery	:= ""
Local cAlQry	:= ""	

	cQuery := "	SELECT ZA0.R_E_C_N_O_ ZA0_REGNO " + CRLF
	cQuery += "	FROM " + RetSqlName("ZA0") + " ZA0 " + CRLF
	cQuery += "	WHERE " + CRLF
	cQuery += "			ZA0_FILIAL = '" + xFilial("ZA0") + "' " + CRLF
	cQuery += "		AND ZA0_FILCC  = '" + Z23->Z23_FILIAL +  "' " + CRLF 
	cQuery += "		AND ZA0.D_E_L_E_T_ = ' ' " + CRLF

	cQuery := ChangeQuery(cQuery)
	cAlQry := MPSysOpenQuery(cQuery)
	
	If !(cAlQry)->(Eof())
		nRet := (cAlQry)->ZA0_REGNO
	EndIf
	
	(cAlQry)->(dbCloseArea())

Return nRet

/*/{Protheus.doc} ValFecha
Valida se existe fechametno e se as vendas foram integradas
@type function
@version 12.1.0.25
@author Mario L. B. Faria
@since 30/07/2018
@param aDtaZWE, array, Lista de processos com erro (enviado por referência)
@return array, [1]=Indica se houve erro; [2]=Mensagem de retorno
/*/
Static Function ValFecha(aDtaZWE)
Local cMsg		:= ""
Local cProces   := "Inventario - Contagem"
Local cEntid	:= "Z23"
Local nTamZWVPK := TamSx3("ZWV_PK")[1]
Local lRet      := .T.

	// -> Verifica o fechamento das vendas
	ZWV->(DbSetOrder(1))
	ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dDataBase-1),nTamZWVPK)+"W"))
	If !ZWV->(Found()) .or. ZWV->ZWV_STATUS == "P"
		// -> Grava dados de log
		cMsg := "Nao foi concluido o processo de integracao de vendas para o dia " + DtoC(dDataBase-1) 
		lRet := .F.
		aAdd(aDtaZWE,{xFilial("ZWE"),dDataBase,cProces,Z23->Z23_ID,dDataBase,Z23->Z23_ID,cEntid,"1","INVENTARIO","","E",0,cMsg,""})
	EndIf

Return({lRet,cMsg})



/*/{Protheus.doc} ValPrcInv
Valida processamento do inventário
@type function
@version 12.1.0.25
@author Mario L. B. Faria
@since 30/07/2018
@param aValid, array, Lista de processos com problemas (recebido por referência)
@return logical, Indica se houve erro em algum processamento
/*/
Static Function ValPrcInv(aValid)
Local cQuery	:= ""
Local cAlQry	:= ""	
Local cProces	:= "Inventário - Fechamento Caixa"
Local cEntid	:= "Z23"
Local lRet      := .T.

	cQuery := "	SELECT " + CRLF 
	cQuery += "	B7_FILIAL, B7_DATA, B7_DOC || B7_COD || B7_LOCAL SB7_ID, B7_COD " + CRLF  
	cQuery += "	FROM " + RetSqlName("SB7") + " SB7 " + CRLF 
	cQuery += "	WHERE " + CRLF 
	cQuery += "			B7_FILIAL  = '"    + xFilial("SB7")  + "' " + CRLF 
	cQuery += "		AND B7_DOC     = 'INV" + Z23->Z23_ID     + "' " + CRLF 
	cQuery += "		AND B7_DATA    = '"    + DtoS(dDataBase) + "' " + CRLF 
	cQuery += "		AND B7_STATUS != '2'                          " + CRLF 
	cQuery += "		AND SB7.D_E_L_E_T_ = ' '                      " + CRLF 
	cQuery := ChangeQuery(cQuery)
	cAlQry := MPSysOpenQuery(cQuery)
	
	While !(cAlQry)->(Eof())
		cMsg:="Produto " +  (cAlQry)->B7_COD + " nao processado."+Chr(13)+Chr(10)
		lRet:=.F.
		aAdd(aValid,{xFilial("ZWE"),dDataBase,cProces,Z23->Z23_ID,dDataBase,Z23->Z23_ID,cEntid,"1","INVENTARIO","","E",0,cMsg,""})		
		(cAlQry)->(dbSkip())
	EndDo

Return lRet
