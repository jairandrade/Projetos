
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} JOB004
JOB utilizado na replica de cadastro de plano de contas
@type function
@version 
@author Thiago Berna
@since 29/05/2020
@param aDados, array, param_description
@param cEmpDes, character, param_description
@param cFilDes, character, param_description
@param cThreadId, character, param_description
@param nOpc, numeric, param_description
@return Nil
/*/
User Function JOB004( aDados, cEmpDes, cFilDes, cThreadId, nOpc, aSubMod1, aSubMod2, aSubMod3, cCodConta )

	Local aEmpresas 	:= {}
	Local aError		:= {}
	Local aAreaCTS		:= {}
	Local nCount 		:= 0
	Local nCountB		:= 0
	Local nHeader		:= 0
	Local nErros		:= 0
	Local nPosFil		:= 0
	Local nPosPla		:= 0
	Local nPosOrd		:= 0
	Local nPosLin		:= 0
	Local nPosIni		:= 0
	Local nPosFim		:= 0
	Local nLinCTS		:= 0
	Local nLinCVD		:= 0
	Local cHoraIni		:= ""
	Local cErro			:= ""
    Local oModelAut     := Nil
	Local oCT1			:= Nil
	Local oCVD			:= Nil
	Local oCTS			:= Nil
	local lAchou		:= .T.
	Local lErroCTS		:= .F.
	Private _cThread	:= cThreadId

	If !Empty( cEmpDes ) .And. IsBlind()
		RpcSetType( 3 )
		RpcSetEnv( cEmpDes, cFilDes, , , "CTB" )
	EndIf

	GetGlbVars(cThreadId,aEmpresas)

	CT1->(DbSetOrder(1))
		
	If nOpc == 3
		If CT1->(DbSeek(xFilial("CT1") + cCodConta))
			nOpc := 4
		EndIf
	ElseIf nOpc == 4
		If !CT1->(DbSeek(xFilial("CT1") + cCodConta))
			nOpc := 3
		EndIf
	EndIf
		
	oModelAut := FWLoadModel('CTBA020')
	
	//Direciona o array correto para cada operação
	If nOpc == 3 .Or. nOpc == 4		// 3 - Inclusão | 4 - Alteração

		oModelAut:SetOperation(nOpc) 
		oModelAut:Activate() 
			
       	//Tratamento tabela CT1
		oCT1 := oModelAut:GetModel('CT1MASTER')
		For nCount := 2 To Len(aSubMod1[1])
			If oCT1:CanSetValue(aSubMod1[1][nCount][1])
				oCT1:SetValue(aSubMod1[1][nCount][1],IIF(ValType(aSubMod1[1][nCount][2]) == "C",AllTrim(aSubMod1[1][nCount][2]),aSubMod1[1][nCount][2]))
			EndIf
		Next nCount

		//Tratamento tabela CVD
		oCVD := oModelAut:GetModel('CVDDETAIL') 

		//Verifica se o destino tem mais linhas que a origem e exclui
		nLinCVD := oCVD:GetQTDLine()
		If nLinCVD > Len(aSubMod3)
			For nCountB := Len(aSubMod2) + 1 To nLinCVD
				//Posiciona na linha
				oCVD:GoLine(nCountB)
				//Exclui Linha
				oCVD:DeleteLine()
			Next nCountB
		EndIf 

		For nCount := 1 To Len(aSubMod2)

			//Verifica se a origem possuim mais linhas que o destino e cria uma nova
			If nCount > oCVD:GetQTDLine() 
				//Verifica se a linha não foi deletada
				If !aSubMod2[nCount][3]
					//Inclui uma nova linha
					oCVD:AddLine()
						
					//Posiciona na linha
					oCVD:GoLine(nCount)
					
				EndIf
			Else
				//Posiciona na linha
				oCVD:GoLine(nCount)

				//Verifica se a linha não foi deletada
				If aSubMod2[nCount][3] .Or. Empty(aSubMod2[nCount][1][1][2])
					oCVD:DeleteLine()
				EndIf
			EndIf
			
			If !Empty(aSubMod2[nCount][1][1][2]) .And. !oCVD:IsDeleted()
				For nHeader := 1 To Len(oCVD:aHeader)
					If oCVD:CanSetValue(oCVD:aHeader[nHeader][2])
						If !Empty(aSubMod2[nCount][1][1][nHeader]) .Or. ValType(aSubMod2[nCount][1][1][nHeader]) == "N"
							oCVD:SetValue(oCVD:aHeader[nHeader][2],IIF(ValType(aSubMod2[nCount][1][1][nHeader]) == "C",AllTrim(aSubMod2[nCount][1][1][nHeader]),aSubMod2[nCount][1][1][nHeader]))
						EndIf
					EndIf
				Next nHeader
			EndIf

		Next nCount

		//Tratamento tabela CTS
		oCTS := oModelAut:GetModel('CTSDETAIL') 

		//Verifica se o destino tem mais linhas que a origem e exclui
		nLinCTS := oCTS:GetQTDLine()
		If nLinCTS > Len(aSubMod3)
			For nCountB := Len(aSubMod3) + 1 To nLinCTS
				//Posiciona na linha
				oCTS:GoLine(nCountB)
				//Exclui Linha
				oCTS:DeleteLine()
			Next nCountB
		EndIf 
		
		For nCount := 1 To Len(aSubMod3)

			aAreaCTS := CTS->(GetArea())
			CTS->(DbSetOrder(1)) //CTS_FILIAL+CTS_CODPLA+CTS_ORDEM+CTS_LINHA
			nPosFil	:= Ascan(oCTS:aHeader,{|x| AllTrim(x[2])=="CTS_FILIAL"  })
			nPosPla := Ascan(oCTS:aHeader,{|x| AllTrim(x[2])=="CTS_CODPLA"  })
			nPosOrd	:= Ascan(oCTS:aHeader,{|x| AllTrim(x[2])=="CTS_ORDEM"   })
			nPosLin := Ascan(oCTS:aHeader,{|x| AllTrim(x[2])=="CTS_LINHA"   })
			nPosIni := Ascan(oCTS:aHeader,{|x| AllTrim(x[2])=="CTS_CT1INI"  })
			nPosFim := Ascan(oCTS:aHeader,{|x| AllTrim(x[2])=="CTS_CT1FIM"  })
			
			If  !aSubMod3[nCount][3] .And. !Empty(aSubMod3[nCount][1][1][2]) .And. ;
			CTS->(DbSeek(aSubMod3[nCount][1][1][nPosFil] + aSubMod3[nCount][1][1][nPosPla] + aSubMod3[nCount][1][1][nPosOrd] + aSubMod3[nCount][1][1][nPosLin]))

				If !CTS->CTS_CT1INI == aSubMod3[nCount][1][1][nPosIni] .Or. !CTS->CTS_CT1FIM == aSubMod3[nCount][1][1][nPosFim]
					AADD(aError,"[CTS] - Chave Duplicada [" + aSubMod3[nCount][1][1][nPosFil] + " - " + aSubMod3[nCount][1][1][nPosPla] + " - " + aSubMod3[nCount][1][1][nPosOrd] + " - " + aSubMod3[nCount][1][1][nPosLin] + "]")
					lErroCTS := .T.
					Exit
				EndIf

			EndIf
			
			If !lErroCTS

				RestArea(aAreaCTS)
				
				//Verifica se a origem possuim mais linhas que o destino e cria uma nova
				If nCount > oCTS:GetQTDLine() 
					//Verifica se a linha não foi deletada
					If !aSubMod3[nCount][3]
						//Inclui uma nova linha
						oCTS:AddLine()
							
						//Posiciona na linha
						oCTS:GoLine(nCount)
						
					EndIf
				Else
					//Posiciona na linha
					oCTS:GoLine(nCount)

					//Verifica se a linha não foi deletada
					If aSubMod3[nCount][3] .Or. Empty(aSubMod3[nCount][1][1][2])
						oCTS:DeleteLine()
					EndIf
				EndIf
					
				If !Empty(aSubMod3[nCount][1][1][2]) .And. !oCTS:IsDeleted()
					For nHeader := 1 To Len(oCTS:aHeader)
						If oCTS:CanSetValue(oCTS:aHeader[nHeader][2])
							If !Empty(aSubMod3[nCount][1][1][nHeader]) .Or. ValType(aSubMod3[nCount][1][1][nHeader]) == "N"
								//Atualiza o campo CTS_COLUNA apenas se maior que zero
								If oCTS:aHeader[nHeader][2] == "CTS_COLUNA"
									//If aSubMod3[nCount][1][1][nHeader] > 0
										oCTS:SetValue(oCTS:aHeader[nHeader][2],CTS->CTS_COLUNA)
									//EndIf
								Else
									oCTS:SetValue(oCTS:aHeader[nHeader][2],IIF(ValType(aSubMod3[nCount][1][1][nHeader]) == "C",AllTrim(aSubMod3[nCount][1][1][nHeader]),aSubMod3[nCount][1][1][nHeader]))
								EndIf
							EndIf
						EndIf
					Next nHeader
				EndIf

			EndIF

		Next nCount
		
	ElseIf nOpc == 5	//5 - Exclusão
			
		//Caso o registro não exista na outra empresa não precisa tentar excluir.
		If !CT1->(DbSeek(xFilial("CT1") + cCodConta))
			lAchou := .F.
		Else
			
			oModelAut:SetOperation(nOpc) 
			oModelAut:Activate() 

		EndIf

	EndIf
		
	If !lErroCTS
	
		If lAchou
			If !oModelAut:VldData()
					
				//Carrega o log de erros
				aError := aClone(oModelAut:GetErrorMessage())

				//Em caso de erro aborta a operação
				ExecErro(aEmpresas,cEmpDes,cFilDes,cThreadId,aError)
				
			Else
					
				If ExecOk(aEmpresas,cEmpDes,cFilDes,cThreadId)
					
					If !oModelAut:CommitData() 
					
						//Carrega o log de erros
						aError := aClone(oModelAut:GetErrorMessage())

						//Em caso de erro aborta a operação
						ExecErro(aEmpresas,cEmpDes,cFilDes,cThreadId,aError)
						
					EndIf

				EndIf

			EndIf
		Else

			//Em caso de erro aborta a operação
			If !ExecOk(aEmpresas,cEmpDes,cFilDes,cThreadId)
				//DisarmTransaction()
			EndIf

		EndIf

	Else
		
		ExecErro(aEmpresas,cEmpDes,cFilDes,cThreadId,aError)

	EndIf

	//Caso tenha Finalizado a transação e tenha o status 05 - Concluido na origem com sucesso
	If Ascan(aEmpresas,{|x| x[3]=="05" }) > 0 //05 - Concluido na origem com sucesso
		For nCount := 1 to Len(aEmpresas)
			If aEmpresas[nCount,1] == cEmpDes .And. aEmpresas[nCount,2] == cFilDes 
				aEmpresas[nCount,3] := "06"	//06 - Commit executado na Thread
			EndIf
		Next nCount

		//Atualiza a variavel global para identificar que o processo teve commit na thread
		PutGlbVars(cThreadId,aEmpresas)
	EndIf

	If !Empty( cEmpDes ) .And. IsBlind()

		RpcClearEnv()
		KillApp(.T.)
		
	EndIf

Return


Static Function ExecOk(aEmpresas,cEmpDes,cFilDes,cThreadId)

	Local nCount	:= 0
	Local cHoraIni	:= ""
	Local lOk		:= .T.

	For nCount := 1 to Len(aEmpresas)
		If aEmpresas[nCount,1] == cEmpDes .And. aEmpresas[nCount,2] == cFilDes 
			aEmpresas[nCount,3] := "01"	//01 - Concluido na thread com sucesso
		EndIf
	Next nCount

	//Atualiza a variavel global para identificar que o processo deve ser abortado
	PutGlbVars(cThreadId,aEmpresas)

	//Carrega o horario que começou o processo
	cHoraIni := Time()
			
	//Verifica se foi liberado pela Thread principal para concluir
	While Ascan(aEmpresas,{|x| x[3]=="05" }) == 0 .And. Ascan(aEmpresas,{|x| x[3]=="04" }) == 0 //04 - Processo abortado - 05 - Concluido na origem com sucesso
		//ConOut(cThreadId + ' - Aguardando Jobs')
		GetGlbVars(cThreadId,aEmpresas)
			
		//Caso tenha passado mais de 15 minuto aborta a operação
		If SubHoras(time(),cHoraIni) > 0.15
					
			For nCount := 1 to Len(aEmpresas)
				If aEmpresas[nCount,1] == cEmpDes .And. aEmpresas[nCount,2] == cFilDes 
					aEmpresas[nCount,3] := "04"	//04 - Processo abortado
				EndIf
			Next nCount

			//Atualiza a variavel global para identificar que o processo deve ser abortado
			PutGlbVars(cThreadId,aEmpresas)
				
		EndIf
	EndDo

	//Caso tenha identificado algum erro em outra empresa aborta o processo
	If Ascan(aEmpresas,{|x| x[3]=="04" }) > 0 //04 - Processo abortado
		//DisarmTransaction()
		lOk	:= .F.
	EndIf

Return lOk

Static Function ExecErro(aEmpresas,cEmpDes,cFilDes,cThreadId,aErro)

	Local nCount	:= 0
	Local nErros	:= 0
	//Local nPosErro	:= 0
	Local cErros	:= ""
	Local lErro		:= .T.

	For nCount := 1 to Len(aEmpresas)
		If aEmpresas[nCount,1] == cEmpDes .And. aEmpresas[nCount,2] == cFilDes 
			
			cErros := "Empresa[" + cEmpDes + "]" + CHR(13) + CHR(10)
			For nErros := 1 To Len(aErro)
				cErros += AllToChar( aErro[nErros] ) + CHR(13) + CHR(10)
			Next nErros
					
			aEmpresas[nCount,3] := "02"		//02 - Concluido na Thread com erro
			aEmpresas[nCount,4] := cErros	//Detalhes do erro
		EndIf
	Next nCount
			
	//Atualiza a variavel global para identificar que o processo deve ser abortado
	PutGlbVars(cThreadId,aEmpresas)
	
Return lErro