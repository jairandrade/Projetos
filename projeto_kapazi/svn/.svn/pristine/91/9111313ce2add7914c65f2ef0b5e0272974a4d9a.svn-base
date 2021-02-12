#include "protheus.ch"
#Include "TopConn.ch"

#define enter chr(13) + chr(10)

/*/{Protheus.doc} STARTPROCESS
//TODO Inicia uma solicitação no Fluig.
@author Reinaldo Santos
@since 13/04/2018
@version 1.0
@type function
/*/
User Function STARTPROCESS(cUsername,cPassword,cCompanyId,cProcessId,nChoosedState,aColleagueIds,cComments,cUserId,aDados,lCompleteTask,lManagerMode)

	Local oWs   	:= wsECMWorkflowEngineServiceService():new() 
	Local nX 		:= 0
	Local lRet  	:= .T.
	Local nRet 		:= 0
	Local cMsg		:= ""
	Local cCJ_FIL 	:= ""
	Local cCJ_NUM 	:= ""
	Local cCJ_CLI 	:= ""
	Local cCJ_LOJA 	:= ""

	oWs:cUsername        					:= cUsername 		//"protheus"
	oWs:cPassword        					:= cPassword 		//"1"
	oWs:nCompanyId          				:= VAL(cCompanyId) 	//99
	oWs:cProcessId          				:= cProcessId 		//"Processo Compras"
	oWs:nChoosedState          				:= nChoosedState 	//56
	oWs:owsStartProcessColleagueIds:cItem   := aColleagueIds 	//{"protheus"}
	oWs:cComments        					:= cComments 		//"Importado via WS"
	oWs:cUserId        						:= cUserId 			//"protheus"
	oWs:lCompleteTask          				:= lCompleteTask 	//.T.
	oWs:lManagerMode          				:= lManagerMode 	//.F.
	
	For nX := 1 To LEN(aDados)
		aAdd(oWs:oWsStartProcessCardData:oWsItem, ECMWorkflowEngineServiceService_stringArray():new())
		nItem := len(oWs:oWsStartProcessCardData:oWsItem)		
		oWs:oWsStartProcessCardData:oWsItem[nX]:cItem := {aDados[nX][1], aDados[nX][2]}
		ConOut("aDados - p1 ! " + cValtoChar(aDados[nX][1]) + " - p2 ! " +  cValtoChar(aDados[nX][2]) )
	Next nX	

	cCJ_FIL  := cValtoChar(aDados[2][2]) // Filial
	cCJ_NUM  := cValtoChar(aDados[3][2]) //Numero 
	cCJ_CLI  := cValtoChar(aDados[4][2]) //Cliente
	cCJ_LOJA := cValtoChar(aDados[5][2]) // Loja

		ConOut("cCJ_FIL"  +  cCJ_FIL )
		ConOut("cCJ_NUM"  +  cCJ_NUM )
		ConOut("cCJ_CLI"  +  cCJ_CLI )
		ConOut("cCJ_LOJA" + cCJ_LOJA )

	dbSelectArea("SCJ")
	dbSetOrder(1)
	dbSeek(cCJ_FIL+cCJ_NUM+cCJ_CLI+cCJ_LOJA)     // Filial/Numero/Cliente/Loja

	IF FOUND()
		ConOut("ENCONTROU O ORÇAMENTO - INICIANDO A INTEGRAÇÃO COM FLUIG")
	
		if oWs:startProcess()
			lRet := .F.
			For i := 1 to LEN(oWs:oWsStartProcessResult:oWsItem)
			
				IF "ERROR" $ OWS:OWSSTARTPROCESSRESULT:OWSITEM[i]:CITEM[1]			
					cMsg += enter + OWS:OWSSTARTPROCESSRESULT:OWSITEM[1]:CITEM[2]
					msgErroFluig += enter + OWS:OWSSTARTPROCESSRESULT:OWSITEM[1]:CITEM[2]				
					lRet := .F.
					nRet := 16 //erro
					EnvMail("sac@cooperkap.com.br",cMsg,msgErroFluig,aDados)			
				ElseIF "iProcess" $ oWs:oWsStartProcessResult:oWsItem[i]:cItem[1]
					cMsg += "Foi iniciado o processo de aprovação de número: "+ oWs:oWsStartProcessResult:oWsItem[i]:cItem[2] + " no Fluig."

					ConOut("Retorno Número Fluig - " + cValtoChar(oWs:oWsStartProcessResult:oWsItem[i]:cItem[2]))
					
					RecLock('SCJ', .F.)
						CJ_XNUMFLU := oWs:oWsStartProcessResult:oWsItem[i]:cItem[2]
					SCJ->(MsUnlock()) 
					
					ConOut("Alteração no Protheus realizada")
					//M->CJ_XNUMFLU := oWs:oWsStartProcessResult:oWsItem[i]:cItem[2]			
					lRet := .T.	
				EndIf	
			next i
		else		
			cMsg := enter+ "Erro na criacao do processo :" + getWSCError()
			msgErroFluig += enter + OWS:OWSSTARTPROCESSRESULT:OWSITEM[1]:CITEM[2]	
			lRet := .F.
			nRet := 16 //erro
			EnvMail("sac@cooperkap.com.br",cMsg,msgErroFluig,aDados)
		endIf
			

	ELSE
		lRet := .F.
		ConOut("NÃO ENCONTROU O ORÇAMENTO N° - " + cCJ_NUM)
	
	ENDIF

	SCJ->(DbCloseArea())
	ConOut("Mensagem final - " + cMsg)
	MessageBox(cMsg,"",nRet)

Return lRet

Static Function EnvMail(cMailTo,cMsg, msgErroFluig,aDados)

	local oMailSend
	local aArea		:= GetArea()
	local cUsr 		:= GetMV('KP_MBOLUSR', .f., 'kapazi')
	local cPwd 		:= GetMV('KP_MBOLPWD', .f., 'laertes77')
	local nPort		:= GetMV('KP_MBOLPRT', .f., 587)
	local cAddr		:= GetMV('KP_MBOLADD', .f., 'smtplw.com.br')

	local cFrom		:= GetMV('KP_MBOLMFR', .f., 'boleto@kapazi.com.br')
	 
	local cSubj		:= "Erro de integracao com fluig"
	
		//Inicia o processo do workflow
	oWfProc   := TWfProcess():New( "000002", "RELATORIOS", NIL )
	//Layout  
	cWfTaskId := oWfProc:NewTask( "RELATORIOS",  "" )     
	oWfProc:cBody := cMsg + chr(13)+chr(10)+chr(13)+chr(10)+msgErroFluig+chr(13)+chr(10)+chr(13)+chr(10)+varinfo("aDados",aDados)+chr(13)+chr(10)+chr(13)+chr(10)+"Mensagem automatica enviada pelo protheus - Não responder"
	//Dispara o processo para o usuario
	oWfProc:ClientName(cUserName)
	
	//Define as propriedades de envio do e-mail
	oWfProc:cFromAddr := cFrom
	oWfProc:cFromName := cFrom  
	oWfProc:cTo       := cMailTo //cMailTo
	oWfProc:cSubject  := cSubj 
	
	oWfProc:bReturn   := Nil
	//Inicia o processo
	oWfProc:Start()
	//Chama o workflow para enviar os e-mails
	WfSendMail()
	
return