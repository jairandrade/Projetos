#include 'protheus.ch'
#include 'parmtype.ch'

#define enter chr(13) + chr(10)

/*/{Protheus.doc} TAKPROTASK
//TODO Descrição Assume uma tarefa..
@author Reinaldo Santos
@since 13/04/2018
@version 1.0
@type function
/*/
user function TAKPROTASK(cUser, cPassword, nCompanyId, cUserId, nProcessInstanceId, nThreadSequence)

	Local oWs 	:= WSECMWorkflowEngineServiceService():New()							   		
	Local lRet	:= .T.
	Local nRet 	:= 0
	Local cMsg	:= ""
	
	if !oWs:takeProcessTask(cUser, cPassword, nCompanyId, cUserId, nProcessInstanceId, nThreadSequence)
			
		cMsg := enter+ "Erro na criacao do processo :" + getWSCError()	
		lRet := .F.
		nRet := 16 //erro	
		
		MessageBox(cMsg,"",nRet)
	endIf		

return lRet