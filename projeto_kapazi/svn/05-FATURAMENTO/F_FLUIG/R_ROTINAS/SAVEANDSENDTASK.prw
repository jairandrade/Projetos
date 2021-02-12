#include 'protheus.ch'
#include 'parmtype.ch'

#define enter chr(13) + chr(10)

/*/{Protheus.doc} SAST
//TODO Fonte responsavel por movimentar a atividade no Fluig.
@author Reinaldo Santos
@since 13/04/2018
@version 1.0
@type function
/*/
User function saveSTask(cUser, cPassword, nCompanyId, nProcessInstanceId, nChoosedState, cColleagueIds, cComments, cUserId, lcompleteTask, oAttachments, oCardData, oAppointment, lManagerMode, nThreadSequence)
					 
	Local oWs 	:= WSECMWorkflowEngineServiceService():New()							   		
	Local lRet	:= .T.
	Local nRet 	:= 0
	Local cMsg	:= ""
	Local I

	if oWs:saveAndSendTask(cUser, cPassword, nCompanyId, nProcessInstanceId, nChoosedState,, cComments, cUserId, lCompleteTask,oAttachments ,oCardData , oAppointment , lManagerMode, nThreadSequence) 

		For i := 1 to LEN(oWs:oWssaveAndSendTaskResult:oWsItem)
			IF "ERROR" $ oWs:oWssaveAndSendTaskResult:oWsItem[i]:cItem[1]
				cMsg += enter + oWs:oWssaveAndSendTaskResult:oWsItem[i]:cItem[2]				
				lRet := .F.
				nRet := 16 //erro
			
				//MessageBox(cMsg,"",nRet)
				
			ElseIF "WDNrDocto" $ oWs:oWssaveAndSendTaskResult:oWsItem[i]:cItem[1]
				cMsg += "Atividade movimentada no Fluig: "+ oWs:oWssaveAndSendTaskResult:oWsItem[i]:cItem[2]				
			EndIf	
		next i		
	else		
		cMsg := enter+ "Erro na criacao do processo :" + getWSCError()	
		lRet := .F.
		nRet := 16 //erro	
	endIf

Return lRet