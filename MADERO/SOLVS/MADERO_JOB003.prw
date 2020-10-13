#INCLUDE 'TOPCONN.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

User Function JOB003( aDados, cEmpDes, cFilDes, cThreadId, nOpc )

	Local aEmpresas 	:= {}
	Local aInclui		:= aDados[1,1]
	Local aAltera		:= aDados[1,2]
	Local aExclui		:= aDados[1,3]
	Local aError		:= {}
	Local nCount 		:= 0
	Local cCodCC		:=""
	Private lMsErroAuto := .F.
	Private lMsHelpAuto	:= .T.
	Private lAutoErrNoFile := .T.
	Private _cThread	:= cThreadId

	If !Empty( cEmpDes ) .And. IsBlind()
		RpcSetType( 3 )
		RpcSetEnv( cEmpDes, cFilDes, , , "CTB" )
	EndIf

	GetGlbVars(cThreadId,aEmpresas)

	Begin Transaction

		//Caso não tenha encontrado o registro para alterar tenta incluir e vice versa
		cCodCC	:= aInclui[Ascan(aInclui,{|x| AllTrim(x[1])=="CTT_CUSTO"  }),2]
		
		CTT->(DbSetOrder(1))	//CTT_FILIAL+CTT_CUSTO
		
		If nOpc == 3
			If CTT->(DbSeek(xFilial("CTT") + cCodCC))
				nOpc := 4
			EndIf
		ElseIf nOpc == 4
			If !CTT->(DbSeek(xFilial("CTT") + cCodCC))
				nOpc := 3
			EndIf
		EndIf
	
		//Direciona o array correto para cada operação
		If nOpc == 4		//Altera
            MSExecAuto({|x,y| CTBA030(x,y)},aAltera,nOpc)
		ElseIf nOpc == 3	//Inclui
			MSExecAuto({|x,y| CTBA030(x,y)},aInclui,nOpc)
		ElseIf nOpc == 5	//Exclui
			//Caso o registro não exista na outra empresa não precisa tentar excluir.
			If CTT->(DbSeek(xFilial("CTT") + cCodCC))
				MSExecAuto({|x,y| CTBA030(x,y)},aExclui,nOpc)
			Else
				lMsErroAuto := .F.
			EndIf
		EndIf
		
		If lMsErroAuto
			
			//Carrega o log de erros
			aError := aClone(GetAutoGRLog())

			//Em caso de erro aborta a operação
			If ExecErro(aEmpresas,cEmpDes,cFilDes,cThreadId,aError)
				DisarmTransaction()	
			EndIf

		Else

			//Em caso de erro aborta a operação
			If !ExecOk(aEmpresas,cEmpDes,cFilDes,cThreadId)
				DisarmTransaction()
			EndIf

		EndIf

	End Transaction

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

Static Function ExecErro(aEmpresas,cEmpDes,cFilDes,cThreadId,aError)

	Local nCount	:= 0
	Local nErros	:= 0
	Local nPosErro	:= 0
	Local cErros	:= ""
	Local lErro		:= .T.

	For nCount := 1 to Len(aEmpresas)
		If aEmpresas[nCount,1] == cEmpDes .And. aEmpresas[nCount,2] == cFilDes 
			
			cErros := "Empresa[" + cEmpDes + "]" + CHR(13) + CHR(10)
			//Carrega os erros registrados
			nPosErro := Ascan(aError,{|x| "Erro -->" $ x })
			If nPosErro > 0 
				cErros += aError[nPosErro] + CHR(13) + CHR(10)
			Else
			
				For nErros := 1 to Len(aError)
					cErros += aError[nErros] + CHR(13) + CHR(10)
				Next nErros

			EndIf
					
			aEmpresas[nCount,3] := "02"		//02 - Concluido na Thread com erro
			aEmpresas[nCount,4] := cErros	//Detalhes do erro
		EndIf
	Next nCount
			
	//Atualiza a variavel global para identificar que o processo deve ser abortado
	PutGlbVars(cThreadId,aEmpresas)
	
Return lErro