#include 'protheus.ch'
#include 'parmtype.ch'

/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EST551                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Rotina para processar contagens                                               !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 25/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Revisões         ! Márcio A. Zaguetti                                                            !
+------------------+-------------------------------------------------------------------------------+
! Informações      ! Foram realizados ajustes no fonte para correção de problemas de implementacao !
! Adicionais       ! e boas práticas de implementação                                              !
+------------------+-------------------------------------------------------------------------------+
*/  
User Function EST551(aEmpresa)
Local cQuery	:= ""
Local cAlQry	:= ""
Local cPath		:= ""
Local cArqCSV	:= ""
Local aArquivos	:= {}
Local aLinha	:= {}
Local cFilTek	:= ""
Local oEventLog
Local cAuxLog   := "" 
Local aDados    := {}
Local nAux      := 0
Local nCount    := 0
Local lAuxRet   := .T.
Local lProc     := .F.
Local aAuxErro  := {}
Local aAuxFile  := {}
Local cEmp     := aEmpresa[01] 
Local cFil     := aEmpresa[02] 
Local aEmp   	:= {}
Local nx 		:= 0
Local ny        := 0
Local aAuxRet   := {}
Local cKeyLock := "INV"+aEmpresa[01]+aEmpresa[02]
Private nPosCod :=1
Private nPosQtd :=11	

	nAux:=ThreadId()
	ConOut("The process "+AllTrim(Str(nAux))+"has been started.")

	// -> Executa o processo para todas as empresas selecionadas	
	aAdd(aEmp,{cEmp,cFil})   
	nx:=1

	// -> Inicia o ambiente
	RpcClearEnv()        
	RpcSetType(3) 
	RpcSetEnv(aEmp[nx,1],aEmp[nx,2],,,'EST',GetEnvServer())                           
    OpenSm0(aEmp[nx,1],.f.)
	nModulo:=5                                  

	    // -> Posiciona na empresa / filial
	    DbSelectArea("SM0")
	    SM0->(DbSetOrder(1))
	    SM0->(DbSeek(aEmp[nx,1]+aEmp[nx,2]))
	    cEmpAnt:=SM0->M0_CODIGO
	    cFilAnt:=SM0->M0_CODFIL

		// -> Verifica se o processo está em execução e, se tiver não executa o processo
		If LockByName(cKeyLock,.F.,.T.)
			ConOut("==>SEMAFORO: INV em "+DtoC(Date()) + ": STARTED.")
		Else
			ConOut("==>SEMAFORO: INV em "+DtoC(Date()) + ": RUNNING...")
			RpcClearEnv()
			nAux:=ThreadId()
			ConOut("The process "+AllTrim(Str(nAux))+"has been finished.")
			KillApp(.T.)
			Return("")
		EndIf

		oEventLog := EventLog():Start("Inventario - Contagem", Date()   , "Inicio do processo de Contagem...", "EST", "SB7")
		nCount :=0
		cAuxLog:=": Selecionando inventarios..."
		oEventLog:setAddInfo(cAuxLog, "Selecionado dados.")
		ConOut(cAuxLog)
		cQuery := "	SELECT R_E_C_N_O_ Z23_REGNO " + CRLF 
		cQuery += "	FROM " + RetSqlName("Z23") + " Z23 " + CRLF 
		cQuery += "	WHERE " + CRLF 
		cQuery += "	        Z23_FILIAL = '" + xFilial("Z23") + "' " + CRLF 
		cQuery += "	    AND Z23_DTINV != ' ' " + CRLF 
		cQuery += "	    AND Z23_DTCONF = ' ' " + CRLF 
		cQuery += "	    AND D_E_L_E_T_ = ' ' " + CRLF 
		cQuery := ChangeQuery(cQuery)
		cAlQry := MPSysOpenQuery(cQuery)
		While !(cAlQry)->(Eof())
			nCount:=nCount+1
			(cAlQry)->(DbSkip())
		EndDo

		// -> Posiciona na tabela de unidades de negocio
		dbSelectArea("ADK")
		ADK->(dbOrderNickName("ADKXFILI"))    
		ADK->(dbSeek(xFilial("ADK") + cFilAnt) )
		If !ADK->(Found()) .or. Empty(ADK->ADK_XFIL)
			cAuxLog:="Erro: Filial do Teknisa nao encontrada no cadastro de unidades de negocio. [ADK_XFILI="+cFilAnt+"]"
			oEventLog:setAddInfo(cAuxLog, "Selecionado dados.")
			ConOut(cAuxLog)
			(cAlQry)->(dbCloseArea())
			RpcClearEnv()
			ConOut("The process "+AllTrim(Str(nAux))+"has been finished.")
			KillApp(.T.)
			Return("")
		EndIf
		
		cFilTek:=ADK->ADK_XFIL

		cAuxLog:=": "+AllTrim(Str(nCount))+" registro(s) selecionando(s)..."
		oEventLog:setAddInfo(cAuxLog, "Selecionado dados.")
		ConOut(cAuxLog)
			
			// -> Inicia o processamento do inventario
		dbSelectArea("Z23")
		(cAlQry)->(DbGoTop())	
		While !(cAlQry)->(Eof())
			
			// -> Posiciona no registro do inventário e carrega os dados iniciais
			Z23->(dbGoTo((cAlQry)->Z23_REGNO))
			dDataBase:=Z23->Z23_DATA
			cPath    :=U_EST550PT(cFilTek)
			cArqCSV  :=AllTrim(Z23->Z23_ARQINV)				
			aArquivos:=Directory(cPath + cArqCSV)

			cAuxLog:=": Processando arquivo " + cPath + cArqCSV
			oEventLog:setAddInfo(cAuxLog, "Processando arquivo.")
			ConOut(cAuxLog)

			// -> Se encontrou arquivos para processar, continua....
			If Len(aArquivos) > 0
				
				aAuxFile:=StrToKarr(cArqCSV,".")
				
				Begin Transaction
				
					FT_FUSE(cPath+cArqCSV)
					FT_FGOTOP()
				
					cLinha := FT_FREADLN()
					aLinha := StrTokArr(cLinha,";")
					lProc  := .F.

					// -> Verifica se o arquivo possui a coluna b7quant (contegem). Caso não existe, exibe informação e passa para o proximo arquivo
					If aScan(aLinha,"b7quant") != 0
					
						FT_FSKIP()				
						aDados:={}
						nAux  :=0
						lProc :=.T.
						oEventLog:setCountOk()
				
						While !FT_FEOF()
						
							cLinha := FT_FREADLN()
							
							While At( ";;", cLinha ) != 0
								cLinha := Replace(cLinha, ";;", "; ;")
							EndDo
								
							aLinha:= StrTokArr(cLinha,";")
							nAux  :=aScan(aDados,{|kb| AllTrim(kb[1]) == AllTrim(aLinha[nPosCod])})
							If nAux <= 0
								aadd(aDados,{aLinha[nPosCod],aLinha[nPosQtd]})
							Else
								aDados[nAux,02]:=cValToChar(Val(aDados[nAux,02])+Val(aLinha[nPosQtd]))
							EndIf
											
							FT_FSKIP()
						
						EndDo
											
						aAuxRet:=GeraSB7(aDados)
						lAuxRet:=aAuxRet[1]
						If !lAuxRet					
							DisarmTransaction()
						Else
							aAuxRet:=GeraZ23(cArqCSV)
							lAuxRet:=aAuxRet[1]
							If !lAuxRet					
								DisarmTransaction()
							EndIf	
						EndIf
					EndIf
					
					FT_FUSE()		

					// -> Se o processamento ocorreu corretamente, renomeia arquivo como processado
					If lAuxRet .and. lProc
						// -> Se ocorreu erro ao renomear o arquivo, desfaz a transacao 
						If FRename(cPath+cArqCSV,cPath+aAuxFile[1]+"_ok"+".CSV") == -1
							aAuxErro:=aAuxRet[2]
							cAuxLog :=": Erro ao renomear o arquivo " + cPath+cArqCSV
							Aadd(aAuxErro,{cAuxLog,""})
							aAuxRet :={.F.,aAuxErro}
							ConOut(cAuxLog)
							DisarmTransaction()
						Else
							cAuxLog:=": Arquivo processado e renomeado para " + cPath+aAuxFile[1]+"_ok"+".CSV"
							aAuxErro:=aAuxRet[02]
							Aadd(aAuxErro,{cAuxLog,"Renomeando arquivo."})
							ConOut(cAuxLog)
						EndIf
					EndIf	

				End Transaction						

				// -> Se ocorreu erro, gera log
				aAuxErro:=IIF(Len(aAuxRet)>0,aAuxRet[02],{})
				For ny:=1 to Len(aAuxErro)					
					oEventLog:setAddInfo(aAuxErro[ny,01],aAuxErro[ny,02])
				Next ny	
					
				If lProc
					If !lAuxRet
						ConOut("Erro.")
					Else
						oEventLog:setCountInc()
						ConOut("Ok.")
					EndIf
				Else
					oEventLog:setCountInc()
					cAuxLog:="Aviso: Aguardando contagem do inventario. (Arquivo nao possue a coluna B7_QUANT)"
					oEventLog:setAddInfo(cAuxLog,"Aguardando contagem.")
					ConOut(cAuxLog)								
				EndIf	
			Else
				cAux := ": Não encontrado arquivo " + cArqCSV +  " não encontrado no diretório " + cPath
				oEventLog:broken(cAux, cAux, .T.)
			EndIf			
				
			(cAlQry)->(dbSkip())
			
		EndDo
			
		(cAlQry)->(dbCloseArea())
			
		oEventLog:Finish()
		UnLockByName(cKeyLock,.F.,.T.)
	
	RpcClearEnv()
	ConOut("==>SEMAFORO: INV em "+DtoC(Date()) + ": FINISHED...")
	nAux:=ThreadId()
	ConOut("The process "+AllTrim(Str(nAux))+"has been finished.")
	KillApp(.T.)
             	
Return


/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GeraSB7                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para gerar SB7                                                         !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 25/07/2018                                                                   !
+------------------+-------------------------------------------------------------------------------+
*/  
Static Function GeraSB7(aDados)
Local lRet 		:= .T.
Local aArea		:= GetArea()
Local nModAux	:= nModulo
Local cFilAux	:= cFilAnt
Local aMata270	:= {}
Local cPergunta := "MTA270"
Local nx		:= 0
Local cAuxLog   := ""
Local aAuxRet   := {}
Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .T.
	
	nModulo		:= 4
	dDataBase	:= Z23->Z23_DATA
	cFilAnt		:= Z23->Z23_FILIAL

	Pergunte(cPergunta,.F.)
	mv_par01 := 1
	mv_par02 := 1
	mv_par03 := 1
	mv_par04 := 1
	mv_par05 := 1
	mv_par06 := "001"
	mv_par07 := dDataBase

	DbSelectArea("SB1")	
	SB1->(DbSetOrder(1))
	For nx:=1 to Len(aDados)
		
		cAuxLog:=": "+aDados[nx][1]+": Gerando contagem para o produto..."
		Aadd(aAuxRet,{cAuxLog,""})
		ConOut(cAuxLog)				
			
		If SB1->(DbSeek(xFilial("SB1")+aDados[nx,01]))
		
			aMata270 := {}
			aAdd( aMata270, { "B7_FILIAL"	, xFilial("SB1")	    , Nil })
			aAdd( aMata270, { "B7_COD"		, SB1->B1_COD		    , Nil })
			aAdd( aMata270, { "B7_LOCAL"	, SB1->B1_LOCPAD	    , Nil })
			aAdd( aMata270, { "B7_DOC"		, "INV" + Z23->Z23_ID	, Nil })
			aAdd( aMata270, { "B7_QUANT"	, Val(aDados[nx,02])	, Nil })
			aAdd( aMata270, { "B7_ORIGEM"	, "TEKNISA"				, Nil }) 
			aAdd( aMata270, { "B7_DATA"		, dDataBase				, Nil })  

			lMsErroAuto := .F.
			MSExecAuto({|x,y,z| Mata270(x,y,z)},aMata270,.T.,3)
	
			If lMsErroAuto
				lRet 	:= .F.	
				cAuxLog := RetErro()
				cAuxLog := "Erro execauto (MATA270):  " + cAuxLog 
				Aadd(aAuxRet,{cAuxLog,""})
				ConOut("Erro: " + cAuxLog)
			Else
				cAuxLog:="Ok."
				Aadd(aAuxRet,{cAuxLog,""})
				ConOut(cAuxLog)						
			EndIf		
		
		Else
			lRet   := .F.
			cAuxLog:=": Produto nao encontrado."
			Aadd(aAuxRet,{": Erro: "+cAuxLog,""})
			ConOut(cAuxLog)													
		EndIf	

	Next nx		

	RestArea(aArea)
	cFilAnt := cFilAux
	nModulo := nModAux
	If Len(aAuxRet) <= 0
	   lRet   := .F.
	   cAuxLog:= ": Sem dados de contagem."
	   Aadd(aAuxRet,{cAuxLog,""})
	   ConOut(cAuxLog)													
	EndIf

Return({lRet,aAuxRet})



/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GeraZ23                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para atualizar Z23                                                     !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 25/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  

Static Function GeraZ23(cArqCSV)
Local nX		:= 0
Local lRet		:= .T.
Local oModel	:= FWLoadModel("MADERO_EST550")
Local cAuxLog   := ""
Local lAuxRet   := ""
Local aAuxRet   := {}


	cAuxLog:=": "+Z23->Z23_ID+": Atualizando registro de inventário."
	Aadd(aAuxRet,{cAuxLog, ""})
	ConOut(cAuxLog)						
	
	oModel:SetOperation(4)
	oModel:Activate()
	
	oModel:SetValue("MODEL_Z23", "Z23_DTCONF"	, Date())
	oModel:SetValue("MODEL_Z23", "Z23_HRCONF"	, Time())		

	If oModel:VldData()
		oModel:CommitData()		
		cAuxLog:=": Ok."
		ConOut(cAuxLog)						
		Aadd(aAuxRet,{cAuxLog, ""})
	Else	
		aErro := oModel:GetErrorMessage()
		lRet  := .F.
		
		AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1] ) + ']' )
		AutoGrLog( "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' )
		AutoGrLog( "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + ']' )
		AutoGrLog( "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' )
		AutoGrLog( "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' )
		AutoGrLog( "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' )
		AutoGrLog( "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' )
		AutoGrLog( "Valor atribuído: " + ' [' + AllToChar( aErro[8] ) + ']' )
		AutoGrLog( "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']' )
		
		cAuxLog:=RetErro()
		Aadd(aAuxRet,{"Erro na atualização do inventario.",cAuxLog})
	EndIf
	
	oModel:DeActivate()

Return({lRet,aAuxRet})



/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! RetErro                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Formata erro                                                                  !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
Static Function RetErro()

	Local nX     := 0
	Local cErro  := ""
	Local aLog	 := GetAutoGRLog()

	For nX := 1 To Len(aLog)
		cErro += aLog[nX] + CRLF
	Next nX

Return cErro