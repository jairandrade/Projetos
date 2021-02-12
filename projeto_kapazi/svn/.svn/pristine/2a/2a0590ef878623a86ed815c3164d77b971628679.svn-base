#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService?wsdl
Gerado em        07/13/18 08:48:30
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _YCLQSPM ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSECMWorkflowEngineServiceService
------------------------------------------------------------------------------- */

WSCLIENT WSECMWorkflowEngineServiceService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD importProcess
	WSMETHOD setDueDate
	WSMETHOD takeProcessTask
	WSMETHOD getInstanceCardData
	WSMETHOD createWorkFlowProcessVersion
	WSMETHOD getCardValue
	WSMETHOD getAllProcessAvailableToExport
	WSMETHOD saveAndSendTask
	WSMETHOD setAutomaticDecisionClassic
	WSMETHOD importProcessWithCardAndRelatedDatasets
	WSMETHOD calculateDeadLineHours
	WSMETHOD getAllProcessAvailableToImport
	WSMETHOD cancelInstance
	WSMETHOD getActualThread
	WSMETHOD getWorkFlowProcessVersion
	WSMETHOD getAvailableProcessOnDemand
	WSMETHOD getAvailableStatesDetail
	WSMETHOD exportProcessInZipFormat
	WSMETHOD importProcessWithCard
	WSMETHOD saveAndSendTaskByReplacement
	WSMETHOD startProcessClassic
	WSMETHOD cancelInstanceByReplacement
	WSMETHOD calculateDeadLineTime
	WSMETHOD simpleStartProcess
	WSMETHOD getAvailableProcess
	WSMETHOD startProcess
	WSMETHOD getAllActiveStates
	WSMETHOD releaseProcess
	WSMETHOD setTasksComments
	WSMETHOD searchProcess
	WSMETHOD getAvailableUsersOnDemand
	WSMETHOD getProcessFormId
	WSMETHOD saveAndSendTaskClassic
	WSMETHOD getAvailableUsersStartOnDemand
	WSMETHOD getAvailableUsers
	WSMETHOD getProcessImage
	WSMETHOD getAttachments
	WSMETHOD importProcessWithCardAndPersistenceType
	WSMETHOD getAvailableUsersStart
	WSMETHOD importProcessWithCardAndGeneralInfo
	WSMETHOD takeProcessTaskByReplacement
	WSMETHOD exportProcess
	WSMETHOD getAvailableStates
	WSMETHOD updateWorkflowAttachment
	WSMETHOD getHistories

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cusername                 AS string
	WSDATA   cpassword                 AS string
	WSDATA   ncompanyId                AS int
	WSDATA   cprocessId                AS string
	WSDATA   oWSimportProcessattachments AS ECMWorkflowEngineServiceService_attachmentArray
	WSDATA   lnewProcess               AS boolean
	WSDATA   loverWrite                AS boolean
	WSDATA   ccolleagueId              AS string
	WSDATA   cresult                   AS string
	WSDATA   nprocessInstanceId        AS int
	WSDATA   cuserId                   AS string
	WSDATA   nthreadSequence           AS int
	WSDATA   cnewDueDate               AS string
	WSDATA   ntimeInSecods             AS int
	WSDATA   oWSgetInstanceCardDataCardData AS ECMWorkflowEngineServiceService_stringArrayArray
	WSDATA   ccardFieldName            AS string
	WSDATA   ccontent                  AS string
	WSDATA   oWSgetAllProcessAvailableToExportresult AS ECMWorkflowEngineServiceService_processDefinitionDtoArray
	WSDATA   nchoosedState             AS int
	WSDATA   oWSsaveAndSendTaskcolleagueIds AS ECMWorkflowEngineServiceService_stringArray
	WSDATA   ccomments                 AS string
	WSDATA   lcompleteTask             AS boolean
	WSDATA   oWSsaveAndSendTaskattachments AS ECMWorkflowEngineServiceService_processAttachmentDtoArray
	WSDATA   oWSsaveAndSendTaskcardData AS ECMWorkflowEngineServiceService_stringArrayArray
	WSDATA   oWSsaveAndSendTaskappointment AS ECMWorkflowEngineServiceService_processTaskAppointmentDtoArray
	WSDATA   lmanagerMode              AS boolean
	WSDATA   oWSsaveAndSendTaskresult  AS ECMWorkflowEngineServiceService_stringArrayArray
	WSDATA   niTaskAutom               AS int
	WSDATA   niTask                    AS int
	WSDATA   ncondition                AS int
	WSDATA   oWSsetAutomaticDecisionClassiccolleagueIds AS ECMWorkflowEngineServiceService_stringArray
	WSDATA   oWSsetAutomaticDecisionClassicresult AS ECMWorkflowEngineServiceService_keyValueDtoArray
	WSDATA   oWSimportProcessWithCardAndRelatedDatasetsprocessAttachs AS ECMWorkflowEngineServiceService_attachmentArray
	WSDATA   nparentDocumentId         AS int
	WSDATA   cdocumentDescription      AS string
	WSDATA   ccardDescription          AS string
	WSDATA   cdatasetName              AS string
	WSDATA   oWSimportProcessWithCardAndRelatedDatasetscardAttachs AS ECMWorkflowEngineServiceService_attachmentArray
	WSDATA   oWSimportProcessWithCardAndRelatedDatasetscustomEvents AS ECMWorkflowEngineServiceService_cardEventDtoArray
	WSDATA   oWSimportProcessWithCardAndRelatedDatasetsgeneralInfo AS ECMWorkflowEngineServiceService_generalInfoDto
	WSDATA   lupdate                   AS boolean
	WSDATA   npersistenceType          AS int
	WSDATA   oWSimportProcessWithCardAndRelatedDatasetsrelatedDatasets AS ECMWorkflowEngineServiceService_stringArray
	WSDATA   oWSimportProcessWithCardAndRelatedDatasetsresult AS ECMWorkflowEngineServiceService_webServiceMessage
	WSDATA   cdata                     AS string
	WSDATA   nhora                     AS int
	WSDATA   nprazo                    AS int
	WSDATA   cperiodId                 AS string
	WSDATA   oWScalculateDeadLineHoursresult AS ECMWorkflowEngineServiceService_deadLineDto
	WSDATA   oWSgetAllProcessAvailableToImportresult AS ECMWorkflowEngineServiceService_processDefinitionDtoArray
	WSDATA   ccancelText               AS string
	WSDATA   nstateSequence            AS int
	WSDATA   nActualThread             AS int
	WSDATA   nlimit                    AS int
	WSDATA   nlastRowId                AS int
	WSDATA   oWSgetAvailableProcessOnDemandAvailableProcesses AS ECMWorkflowEngineServiceService_processDefinitionVersionDtoArray
	WSDATA   oWSgetAvailableStatesDetailAvailableStatesDetail AS ECMWorkflowEngineServiceService_processStateDtoArray
	WSDATA   oWSimportProcessWithCardprocessAttachs AS ECMWorkflowEngineServiceService_attachmentArray
	WSDATA   oWSimportProcessWithCardcardAttachs AS ECMWorkflowEngineServiceService_attachmentArray
	WSDATA   oWSimportProcessWithCardcustomEvents AS ECMWorkflowEngineServiceService_cardEventDtoArray
	WSDATA   oWSimportProcessWithCardresult AS ECMWorkflowEngineServiceService_webServiceMessage
	WSDATA   oWSsaveAndSendTaskByReplacementcolleagueIds AS ECMWorkflowEngineServiceService_stringArray
	WSDATA   oWSsaveAndSendTaskByReplacementattachments AS ECMWorkflowEngineServiceService_processAttachmentDtoArray
	WSDATA   oWSsaveAndSendTaskByReplacementcardData AS ECMWorkflowEngineServiceService_stringArrayArray
	WSDATA   oWSsaveAndSendTaskByReplacementappointment AS ECMWorkflowEngineServiceService_processTaskAppointmentDtoArray
	WSDATA   creplacementId            AS string
	WSDATA   oWSsaveAndSendTaskByReplacementresult AS ECMWorkflowEngineServiceService_stringArrayArray
	WSDATA   oWSstartProcessClassiccolleagueIds AS ECMWorkflowEngineServiceService_stringArray
	WSDATA   oWSstartProcessClassicattachments AS ECMWorkflowEngineServiceService_processAttachmentDtoArray
	WSDATA   oWSstartProcessClassiccardData AS ECMWorkflowEngineServiceService_keyValueDtoArray
	WSDATA   oWSstartProcessClassicappointment AS ECMWorkflowEngineServiceService_processTaskAppointmentDtoArray
	WSDATA   oWSstartProcessClassicresult AS ECMWorkflowEngineServiceService_keyValueDtoArray
	WSDATA   oWScalculateDeadLineTimeresult AS ECMWorkflowEngineServiceService_deadLineDto
	WSDATA   oWSsimpleStartProcessattachments AS ECMWorkflowEngineServiceService_processAttachmentDtoArray
	WSDATA   oWSsimpleStartProcesscardData AS ECMWorkflowEngineServiceService_stringArrayArray
	WSDATA   oWSsimpleStartProcessresult AS ECMWorkflowEngineServiceService_stringArray
	WSDATA   oWSgetAvailableProcessAvailableProcesses AS ECMWorkflowEngineServiceService_processDefinitionVersionDtoArray
	WSDATA   oWSstartProcesscolleagueIds AS ECMWorkflowEngineServiceService_stringArray
	WSDATA   oWSstartProcessattachments AS ECMWorkflowEngineServiceService_processAttachmentDtoArray
	WSDATA   oWSstartProcesscardData   AS ECMWorkflowEngineServiceService_stringArrayArray
	WSDATA   oWSstartProcessappointment AS ECMWorkflowEngineServiceService_processTaskAppointmentDtoArray
	WSDATA   oWSstartProcessresult     AS ECMWorkflowEngineServiceService_stringArrayArray
	WSDATA   oWSgetAllActiveStatesStates AS ECMWorkflowEngineServiceService_intArray
	WSDATA   lfavorite                 AS boolean
	WSDATA   oWSsearchProcesssearchResults AS ECMWorkflowEngineServiceService_processDefinitionVersionDtoArray
	WSDATA   nstate                    AS int
	WSDATA   ninitialUser              AS int
	WSDATA   cuserSearch               AS string
	WSDATA   oWSgetAvailableUsersOnDemandAvailableUsers AS ECMWorkflowEngineServiceService_availableUsersDto
	WSDATA   oWSsaveAndSendTaskClassiccolleagueIds AS ECMWorkflowEngineServiceService_stringArray
	WSDATA   oWSsaveAndSendTaskClassicattachments AS ECMWorkflowEngineServiceService_processAttachmentDtoArray
	WSDATA   oWSsaveAndSendTaskClassiccardData AS ECMWorkflowEngineServiceService_keyValueDtoArray
	WSDATA   oWSsaveAndSendTaskClassicappointment AS ECMWorkflowEngineServiceService_processTaskAppointmentDtoArray
	WSDATA   oWSsaveAndSendTaskClassicresult AS ECMWorkflowEngineServiceService_keyValueDtoArray
	WSDATA   oWSgetAvailableUsersStartOnDemandAvailableUsers AS ECMWorkflowEngineServiceService_availableUsersDto
	WSDATA   oWSgetAvailableUsersAvailableUsers AS ECMWorkflowEngineServiceService_stringArray
	WSDATA   cImage                    AS string
	WSDATA   oWSgetAttachmentsAttachments AS ECMWorkflowEngineServiceService_processAttachmentDtoArray
	WSDATA   oWSimportProcessWithCardAndPersistenceTypeprocessAttachs AS ECMWorkflowEngineServiceService_attachmentArray
	WSDATA   oWSimportProcessWithCardAndPersistenceTypecardAttachs AS ECMWorkflowEngineServiceService_attachmentArray
	WSDATA   oWSimportProcessWithCardAndPersistenceTypecustomEvents AS ECMWorkflowEngineServiceService_cardEventDtoArray
	WSDATA   oWSimportProcessWithCardAndPersistenceTyperesult AS ECMWorkflowEngineServiceService_webServiceMessage
	WSDATA   oWSgetAvailableUsersStartAvailableUsers AS ECMWorkflowEngineServiceService_stringArray
	WSDATA   oWSimportProcessWithCardAndGeneralInfoprocessAttachs AS ECMWorkflowEngineServiceService_attachmentArray
	WSDATA   oWSimportProcessWithCardAndGeneralInfocardAttachs AS ECMWorkflowEngineServiceService_attachmentArray
	WSDATA   oWSimportProcessWithCardAndGeneralInfocustomEvents AS ECMWorkflowEngineServiceService_cardEventDtoArray
	WSDATA   oWSimportProcessWithCardAndGeneralInfogeneralInfo AS ECMWorkflowEngineServiceService_generalInfoDto
	WSDATA   oWSimportProcessWithCardAndGeneralInforesult AS ECMWorkflowEngineServiceService_webServiceMessage
	WSDATA   oWSgetAvailableStatesStates AS ECMWorkflowEngineServiceService_intArray
	WSDATA   cusuario                  AS string
	WSDATA   oWSupdateWorkflowAttachmentdocument AS ECMWorkflowEngineServiceService_documentDtoArray
	WSDATA   oWSupdateWorkflowAttachmentattachments AS ECMWorkflowEngineServiceService_attachmentArray
	WSDATA   oWSgetHistoriesHistories  AS ECMWorkflowEngineServiceService_processHistoryDtoArray

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSECMWorkflowEngineServiceService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180425 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSECMWorkflowEngineServiceService
	::oWSimportProcessattachments := ECMWorkflowEngineServiceService_ATTACHMENTARRAY():New()
	::oWSgetInstanceCardDataCardData := ECMWorkflowEngineServiceService_STRINGARRAYARRAY():New()
	::oWSgetAllProcessAvailableToExportresult := ECMWorkflowEngineServiceService_PROCESSDEFINITIONDTOARRAY():New()
	::oWSsaveAndSendTaskcolleagueIds := ECMWorkflowEngineServiceService_STRINGARRAY():New()
	::oWSsaveAndSendTaskattachments := ECMWorkflowEngineServiceService_PROCESSATTACHMENTDTOARRAY():New()
	::oWSsaveAndSendTaskcardData := ECMWorkflowEngineServiceService_STRINGARRAYARRAY():New()
	::oWSsaveAndSendTaskappointment := ECMWorkflowEngineServiceService_PROCESSTASKAPPOINTMENTDTOARRAY():New()
	::oWSsaveAndSendTaskresult := ECMWorkflowEngineServiceService_STRINGARRAYARRAY():New()
	::oWSsetAutomaticDecisionClassiccolleagueIds := ECMWorkflowEngineServiceService_STRINGARRAY():New()
	::oWSsetAutomaticDecisionClassicresult := ECMWorkflowEngineServiceService_KEYVALUEDTOARRAY():New()
	::oWSimportProcessWithCardAndRelatedDatasetsprocessAttachs := ECMWorkflowEngineServiceService_ATTACHMENTARRAY():New()
	::oWSimportProcessWithCardAndRelatedDatasetscardAttachs := ECMWorkflowEngineServiceService_ATTACHMENTARRAY():New()
	::oWSimportProcessWithCardAndRelatedDatasetscustomEvents := ECMWorkflowEngineServiceService_CARDEVENTDTOARRAY():New()
	::oWSimportProcessWithCardAndRelatedDatasetsgeneralInfo := ECMWorkflowEngineServiceService_GENERALINFODTO():New()
	::oWSimportProcessWithCardAndRelatedDatasetsrelatedDatasets := ECMWorkflowEngineServiceService_STRINGARRAY():New()
	::oWSimportProcessWithCardAndRelatedDatasetsresult := ECMWorkflowEngineServiceService_WEBSERVICEMESSAGE():New()
	::oWScalculateDeadLineHoursresult := ECMWorkflowEngineServiceService_DEADLINEDTO():New()
	::oWSgetAllProcessAvailableToImportresult := ECMWorkflowEngineServiceService_PROCESSDEFINITIONDTOARRAY():New()
	::oWSgetAvailableProcessOnDemandAvailableProcesses := ECMWorkflowEngineServiceService_PROCESSDEFINITIONVERSIONDTOARRAY():New()
	::oWSgetAvailableStatesDetailAvailableStatesDetail := ECMWorkflowEngineServiceService_PROCESSSTATEDTOARRAY():New()
	::oWSimportProcessWithCardprocessAttachs := ECMWorkflowEngineServiceService_ATTACHMENTARRAY():New()
	::oWSimportProcessWithCardcardAttachs := ECMWorkflowEngineServiceService_ATTACHMENTARRAY():New()
	::oWSimportProcessWithCardcustomEvents := ECMWorkflowEngineServiceService_CARDEVENTDTOARRAY():New()
	::oWSimportProcessWithCardresult := ECMWorkflowEngineServiceService_WEBSERVICEMESSAGE():New()
	::oWSsaveAndSendTaskByReplacementcolleagueIds := ECMWorkflowEngineServiceService_STRINGARRAY():New()
	::oWSsaveAndSendTaskByReplacementattachments := ECMWorkflowEngineServiceService_PROCESSATTACHMENTDTOARRAY():New()
	::oWSsaveAndSendTaskByReplacementcardData := ECMWorkflowEngineServiceService_STRINGARRAYARRAY():New()
	::oWSsaveAndSendTaskByReplacementappointment := ECMWorkflowEngineServiceService_PROCESSTASKAPPOINTMENTDTOARRAY():New()
	::oWSsaveAndSendTaskByReplacementresult := ECMWorkflowEngineServiceService_STRINGARRAYARRAY():New()
	::oWSstartProcessClassiccolleagueIds := ECMWorkflowEngineServiceService_STRINGARRAY():New()
	::oWSstartProcessClassicattachments := ECMWorkflowEngineServiceService_PROCESSATTACHMENTDTOARRAY():New()
	::oWSstartProcessClassiccardData := ECMWorkflowEngineServiceService_KEYVALUEDTOARRAY():New()
	::oWSstartProcessClassicappointment := ECMWorkflowEngineServiceService_PROCESSTASKAPPOINTMENTDTOARRAY():New()
	::oWSstartProcessClassicresult := ECMWorkflowEngineServiceService_KEYVALUEDTOARRAY():New()
	::oWScalculateDeadLineTimeresult := ECMWorkflowEngineServiceService_DEADLINEDTO():New()
	::oWSsimpleStartProcessattachments := ECMWorkflowEngineServiceService_PROCESSATTACHMENTDTOARRAY():New()
	::oWSsimpleStartProcesscardData := ECMWorkflowEngineServiceService_STRINGARRAYARRAY():New()
	::oWSsimpleStartProcessresult := ECMWorkflowEngineServiceService_STRINGARRAY():New()
	::oWSgetAvailableProcessAvailableProcesses := ECMWorkflowEngineServiceService_PROCESSDEFINITIONVERSIONDTOARRAY():New()
	::oWSstartProcesscolleagueIds := ECMWorkflowEngineServiceService_STRINGARRAY():New()
	::oWSstartProcessattachments := ECMWorkflowEngineServiceService_PROCESSATTACHMENTDTOARRAY():New()
	::oWSstartProcesscardData := ECMWorkflowEngineServiceService_STRINGARRAYARRAY():New()
	::oWSstartProcessappointment := ECMWorkflowEngineServiceService_PROCESSTASKAPPOINTMENTDTOARRAY():New()
	::oWSstartProcessresult := ECMWorkflowEngineServiceService_STRINGARRAYARRAY():New()
	::oWSgetAllActiveStatesStates := ECMWorkflowEngineServiceService_INTARRAY():New()
	::oWSsearchProcesssearchResults := ECMWorkflowEngineServiceService_PROCESSDEFINITIONVERSIONDTOARRAY():New()
	::oWSgetAvailableUsersOnDemandAvailableUsers := ECMWorkflowEngineServiceService_AVAILABLEUSERSDTO():New()
	::oWSsaveAndSendTaskClassiccolleagueIds := ECMWorkflowEngineServiceService_STRINGARRAY():New()
	::oWSsaveAndSendTaskClassicattachments := ECMWorkflowEngineServiceService_PROCESSATTACHMENTDTOARRAY():New()
	::oWSsaveAndSendTaskClassiccardData := ECMWorkflowEngineServiceService_KEYVALUEDTOARRAY():New()
	::oWSsaveAndSendTaskClassicappointment := ECMWorkflowEngineServiceService_PROCESSTASKAPPOINTMENTDTOARRAY():New()
	::oWSsaveAndSendTaskClassicresult := ECMWorkflowEngineServiceService_KEYVALUEDTOARRAY():New()
	::oWSgetAvailableUsersStartOnDemandAvailableUsers := ECMWorkflowEngineServiceService_AVAILABLEUSERSDTO():New()
	::oWSgetAvailableUsersAvailableUsers := ECMWorkflowEngineServiceService_STRINGARRAY():New()
	::oWSgetAttachmentsAttachments := ECMWorkflowEngineServiceService_PROCESSATTACHMENTDTOARRAY():New()
	::oWSimportProcessWithCardAndPersistenceTypeprocessAttachs := ECMWorkflowEngineServiceService_ATTACHMENTARRAY():New()
	::oWSimportProcessWithCardAndPersistenceTypecardAttachs := ECMWorkflowEngineServiceService_ATTACHMENTARRAY():New()
	::oWSimportProcessWithCardAndPersistenceTypecustomEvents := ECMWorkflowEngineServiceService_CARDEVENTDTOARRAY():New()
	::oWSimportProcessWithCardAndPersistenceTyperesult := ECMWorkflowEngineServiceService_WEBSERVICEMESSAGE():New()
	::oWSgetAvailableUsersStartAvailableUsers := ECMWorkflowEngineServiceService_STRINGARRAY():New()
	::oWSimportProcessWithCardAndGeneralInfoprocessAttachs := ECMWorkflowEngineServiceService_ATTACHMENTARRAY():New()
	::oWSimportProcessWithCardAndGeneralInfocardAttachs := ECMWorkflowEngineServiceService_ATTACHMENTARRAY():New()
	::oWSimportProcessWithCardAndGeneralInfocustomEvents := ECMWorkflowEngineServiceService_CARDEVENTDTOARRAY():New()
	::oWSimportProcessWithCardAndGeneralInfogeneralInfo := ECMWorkflowEngineServiceService_GENERALINFODTO():New()
	::oWSimportProcessWithCardAndGeneralInforesult := ECMWorkflowEngineServiceService_WEBSERVICEMESSAGE():New()
	::oWSgetAvailableStatesStates := ECMWorkflowEngineServiceService_INTARRAY():New()
	::oWSupdateWorkflowAttachmentdocument := ECMWorkflowEngineServiceService_DOCUMENTDTOARRAY():New()
	::oWSupdateWorkflowAttachmentattachments := ECMWorkflowEngineServiceService_ATTACHMENTARRAY():New()
	::oWSgetHistoriesHistories := ECMWorkflowEngineServiceService_PROCESSHISTORYDTOARRAY():New()
Return

WSMETHOD RESET WSCLIENT WSECMWorkflowEngineServiceService
	::cusername          := NIL 
	::cpassword          := NIL 
	::ncompanyId         := NIL 
	::cprocessId         := NIL 
	::oWSimportProcessattachments := NIL 
	::lnewProcess        := NIL 
	::loverWrite         := NIL 
	::ccolleagueId       := NIL 
	::cresult            := NIL 
	::nprocessInstanceId := NIL 
	::cuserId            := NIL 
	::nthreadSequence    := NIL 
	::cnewDueDate        := NIL 
	::ntimeInSecods      := NIL 
	::oWSgetInstanceCardDataCardData := NIL 
	::ccardFieldName     := NIL 
	::ccontent           := NIL 
	::oWSgetAllProcessAvailableToExportresult := NIL 
	::nchoosedState      := NIL 
	::oWSsaveAndSendTaskcolleagueIds := NIL 
	::ccomments          := NIL 
	::lcompleteTask      := NIL 
	::oWSsaveAndSendTaskattachments := NIL 
	::oWSsaveAndSendTaskcardData := NIL 
	::oWSsaveAndSendTaskappointment := NIL 
	::lmanagerMode       := NIL 
	::oWSsaveAndSendTaskresult := NIL 
	::niTaskAutom        := NIL 
	::niTask             := NIL 
	::ncondition         := NIL 
	::oWSsetAutomaticDecisionClassiccolleagueIds := NIL 
	::oWSsetAutomaticDecisionClassicresult := NIL 
	::oWSimportProcessWithCardAndRelatedDatasetsprocessAttachs := NIL 
	::nparentDocumentId  := NIL 
	::cdocumentDescription := NIL 
	::ccardDescription   := NIL 
	::cdatasetName       := NIL 
	::oWSimportProcessWithCardAndRelatedDatasetscardAttachs := NIL 
	::oWSimportProcessWithCardAndRelatedDatasetscustomEvents := NIL 
	::oWSimportProcessWithCardAndRelatedDatasetsgeneralInfo := NIL 
	::lupdate            := NIL 
	::npersistenceType   := NIL 
	::oWSimportProcessWithCardAndRelatedDatasetsrelatedDatasets := NIL 
	::oWSimportProcessWithCardAndRelatedDatasetsresult := NIL 
	::cdata              := NIL 
	::nhora              := NIL 
	::nprazo             := NIL 
	::cperiodId          := NIL 
	::oWScalculateDeadLineHoursresult := NIL 
	::oWSgetAllProcessAvailableToImportresult := NIL 
	::ccancelText        := NIL 
	::nstateSequence     := NIL 
	::nActualThread      := NIL 
	::nlimit             := NIL 
	::nlastRowId         := NIL 
	::oWSgetAvailableProcessOnDemandAvailableProcesses := NIL 
	::oWSgetAvailableStatesDetailAvailableStatesDetail := NIL 
	::oWSimportProcessWithCardprocessAttachs := NIL 
	::oWSimportProcessWithCardcardAttachs := NIL 
	::oWSimportProcessWithCardcustomEvents := NIL 
	::oWSimportProcessWithCardresult := NIL 
	::oWSsaveAndSendTaskByReplacementcolleagueIds := NIL 
	::oWSsaveAndSendTaskByReplacementattachments := NIL 
	::oWSsaveAndSendTaskByReplacementcardData := NIL 
	::oWSsaveAndSendTaskByReplacementappointment := NIL 
	::creplacementId     := NIL 
	::oWSsaveAndSendTaskByReplacementresult := NIL 
	::oWSstartProcessClassiccolleagueIds := NIL 
	::oWSstartProcessClassicattachments := NIL 
	::oWSstartProcessClassiccardData := NIL 
	::oWSstartProcessClassicappointment := NIL 
	::oWSstartProcessClassicresult := NIL 
	::oWScalculateDeadLineTimeresult := NIL 
	::oWSsimpleStartProcessattachments := NIL 
	::oWSsimpleStartProcesscardData := NIL 
	::oWSsimpleStartProcessresult := NIL 
	::oWSgetAvailableProcessAvailableProcesses := NIL 
	::oWSstartProcesscolleagueIds := NIL 
	::oWSstartProcessattachments := NIL 
	::oWSstartProcesscardData := NIL 
	::oWSstartProcessappointment := NIL 
	::oWSstartProcessresult := NIL 
	::oWSgetAllActiveStatesStates := NIL 
	::lfavorite          := NIL 
	::oWSsearchProcesssearchResults := NIL 
	::nstate             := NIL 
	::ninitialUser       := NIL 
	::cuserSearch        := NIL 
	::oWSgetAvailableUsersOnDemandAvailableUsers := NIL 
	::oWSsaveAndSendTaskClassiccolleagueIds := NIL 
	::oWSsaveAndSendTaskClassicattachments := NIL 
	::oWSsaveAndSendTaskClassiccardData := NIL 
	::oWSsaveAndSendTaskClassicappointment := NIL 
	::oWSsaveAndSendTaskClassicresult := NIL 
	::oWSgetAvailableUsersStartOnDemandAvailableUsers := NIL 
	::oWSgetAvailableUsersAvailableUsers := NIL 
	::cImage             := NIL 
	::oWSgetAttachmentsAttachments := NIL 
	::oWSimportProcessWithCardAndPersistenceTypeprocessAttachs := NIL 
	::oWSimportProcessWithCardAndPersistenceTypecardAttachs := NIL 
	::oWSimportProcessWithCardAndPersistenceTypecustomEvents := NIL 
	::oWSimportProcessWithCardAndPersistenceTyperesult := NIL 
	::oWSgetAvailableUsersStartAvailableUsers := NIL 
	::oWSimportProcessWithCardAndGeneralInfoprocessAttachs := NIL 
	::oWSimportProcessWithCardAndGeneralInfocardAttachs := NIL 
	::oWSimportProcessWithCardAndGeneralInfocustomEvents := NIL 
	::oWSimportProcessWithCardAndGeneralInfogeneralInfo := NIL 
	::oWSimportProcessWithCardAndGeneralInforesult := NIL 
	::oWSgetAvailableStatesStates := NIL 
	::cusuario           := NIL 
	::oWSupdateWorkflowAttachmentdocument := NIL 
	::oWSupdateWorkflowAttachmentattachments := NIL 
	::oWSgetHistoriesHistories := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSECMWorkflowEngineServiceService
Local oClone := WSECMWorkflowEngineServiceService():New()
	oClone:_URL          := ::_URL 
	oClone:cusername     := ::cusername
	oClone:cpassword     := ::cpassword
	oClone:ncompanyId    := ::ncompanyId
	oClone:cprocessId    := ::cprocessId
	oClone:oWSimportProcessattachments :=  IIF(::oWSimportProcessattachments = NIL , NIL ,::oWSimportProcessattachments:Clone() )
	oClone:lnewProcess   := ::lnewProcess
	oClone:loverWrite    := ::loverWrite
	oClone:ccolleagueId  := ::ccolleagueId
	oClone:cresult       := ::cresult
	oClone:nprocessInstanceId := ::nprocessInstanceId
	oClone:cuserId       := ::cuserId
	oClone:nthreadSequence := ::nthreadSequence
	oClone:cnewDueDate   := ::cnewDueDate
	oClone:ntimeInSecods := ::ntimeInSecods
	oClone:oWSgetInstanceCardDataCardData :=  IIF(::oWSgetInstanceCardDataCardData = NIL , NIL ,::oWSgetInstanceCardDataCardData:Clone() )
	oClone:ccardFieldName := ::ccardFieldName
	oClone:ccontent      := ::ccontent
	oClone:oWSgetAllProcessAvailableToExportresult :=  IIF(::oWSgetAllProcessAvailableToExportresult = NIL , NIL ,::oWSgetAllProcessAvailableToExportresult:Clone() )
	oClone:nchoosedState := ::nchoosedState
	oClone:oWSsaveAndSendTaskcolleagueIds :=  IIF(::oWSsaveAndSendTaskcolleagueIds = NIL , NIL ,::oWSsaveAndSendTaskcolleagueIds:Clone() )
	oClone:ccomments     := ::ccomments
	oClone:lcompleteTask := ::lcompleteTask
	oClone:oWSsaveAndSendTaskattachments :=  IIF(::oWSsaveAndSendTaskattachments = NIL , NIL ,::oWSsaveAndSendTaskattachments:Clone() )
	oClone:oWSsaveAndSendTaskcardData :=  IIF(::oWSsaveAndSendTaskcardData = NIL , NIL ,::oWSsaveAndSendTaskcardData:Clone() )
	oClone:oWSsaveAndSendTaskappointment :=  IIF(::oWSsaveAndSendTaskappointment = NIL , NIL ,::oWSsaveAndSendTaskappointment:Clone() )
	oClone:lmanagerMode  := ::lmanagerMode
	oClone:oWSsaveAndSendTaskresult :=  IIF(::oWSsaveAndSendTaskresult = NIL , NIL ,::oWSsaveAndSendTaskresult:Clone() )
	oClone:niTaskAutom   := ::niTaskAutom
	oClone:niTask        := ::niTask
	oClone:ncondition    := ::ncondition
	oClone:oWSsetAutomaticDecisionClassiccolleagueIds :=  IIF(::oWSsetAutomaticDecisionClassiccolleagueIds = NIL , NIL ,::oWSsetAutomaticDecisionClassiccolleagueIds:Clone() )
	oClone:oWSsetAutomaticDecisionClassicresult :=  IIF(::oWSsetAutomaticDecisionClassicresult = NIL , NIL ,::oWSsetAutomaticDecisionClassicresult:Clone() )
	oClone:oWSimportProcessWithCardAndRelatedDatasetsprocessAttachs :=  IIF(::oWSimportProcessWithCardAndRelatedDatasetsprocessAttachs = NIL , NIL ,::oWSimportProcessWithCardAndRelatedDatasetsprocessAttachs:Clone() )
	oClone:nparentDocumentId := ::nparentDocumentId
	oClone:cdocumentDescription := ::cdocumentDescription
	oClone:ccardDescription := ::ccardDescription
	oClone:cdatasetName  := ::cdatasetName
	oClone:oWSimportProcessWithCardAndRelatedDatasetscardAttachs :=  IIF(::oWSimportProcessWithCardAndRelatedDatasetscardAttachs = NIL , NIL ,::oWSimportProcessWithCardAndRelatedDatasetscardAttachs:Clone() )
	oClone:oWSimportProcessWithCardAndRelatedDatasetscustomEvents :=  IIF(::oWSimportProcessWithCardAndRelatedDatasetscustomEvents = NIL , NIL ,::oWSimportProcessWithCardAndRelatedDatasetscustomEvents:Clone() )
	oClone:oWSimportProcessWithCardAndRelatedDatasetsgeneralInfo :=  IIF(::oWSimportProcessWithCardAndRelatedDatasetsgeneralInfo = NIL , NIL ,::oWSimportProcessWithCardAndRelatedDatasetsgeneralInfo:Clone() )
	oClone:lupdate       := ::lupdate
	oClone:npersistenceType := ::npersistenceType
	oClone:oWSimportProcessWithCardAndRelatedDatasetsrelatedDatasets :=  IIF(::oWSimportProcessWithCardAndRelatedDatasetsrelatedDatasets = NIL , NIL ,::oWSimportProcessWithCardAndRelatedDatasetsrelatedDatasets:Clone() )
	oClone:oWSimportProcessWithCardAndRelatedDatasetsresult :=  IIF(::oWSimportProcessWithCardAndRelatedDatasetsresult = NIL , NIL ,::oWSimportProcessWithCardAndRelatedDatasetsresult:Clone() )
	oClone:cdata         := ::cdata
	oClone:nhora         := ::nhora
	oClone:nprazo        := ::nprazo
	oClone:cperiodId     := ::cperiodId
	oClone:oWScalculateDeadLineHoursresult :=  IIF(::oWScalculateDeadLineHoursresult = NIL , NIL ,::oWScalculateDeadLineHoursresult:Clone() )
	oClone:oWSgetAllProcessAvailableToImportresult :=  IIF(::oWSgetAllProcessAvailableToImportresult = NIL , NIL ,::oWSgetAllProcessAvailableToImportresult:Clone() )
	oClone:ccancelText   := ::ccancelText
	oClone:nstateSequence := ::nstateSequence
	oClone:nActualThread := ::nActualThread
	oClone:nlimit        := ::nlimit
	oClone:nlastRowId    := ::nlastRowId
	oClone:oWSgetAvailableProcessOnDemandAvailableProcesses :=  IIF(::oWSgetAvailableProcessOnDemandAvailableProcesses = NIL , NIL ,::oWSgetAvailableProcessOnDemandAvailableProcesses:Clone() )
	oClone:oWSgetAvailableStatesDetailAvailableStatesDetail :=  IIF(::oWSgetAvailableStatesDetailAvailableStatesDetail = NIL , NIL ,::oWSgetAvailableStatesDetailAvailableStatesDetail:Clone() )
	oClone:oWSimportProcessWithCardprocessAttachs :=  IIF(::oWSimportProcessWithCardprocessAttachs = NIL , NIL ,::oWSimportProcessWithCardprocessAttachs:Clone() )
	oClone:oWSimportProcessWithCardcardAttachs :=  IIF(::oWSimportProcessWithCardcardAttachs = NIL , NIL ,::oWSimportProcessWithCardcardAttachs:Clone() )
	oClone:oWSimportProcessWithCardcustomEvents :=  IIF(::oWSimportProcessWithCardcustomEvents = NIL , NIL ,::oWSimportProcessWithCardcustomEvents:Clone() )
	oClone:oWSimportProcessWithCardresult :=  IIF(::oWSimportProcessWithCardresult = NIL , NIL ,::oWSimportProcessWithCardresult:Clone() )
	oClone:oWSsaveAndSendTaskByReplacementcolleagueIds :=  IIF(::oWSsaveAndSendTaskByReplacementcolleagueIds = NIL , NIL ,::oWSsaveAndSendTaskByReplacementcolleagueIds:Clone() )
	oClone:oWSsaveAndSendTaskByReplacementattachments :=  IIF(::oWSsaveAndSendTaskByReplacementattachments = NIL , NIL ,::oWSsaveAndSendTaskByReplacementattachments:Clone() )
	oClone:oWSsaveAndSendTaskByReplacementcardData :=  IIF(::oWSsaveAndSendTaskByReplacementcardData = NIL , NIL ,::oWSsaveAndSendTaskByReplacementcardData:Clone() )
	oClone:oWSsaveAndSendTaskByReplacementappointment :=  IIF(::oWSsaveAndSendTaskByReplacementappointment = NIL , NIL ,::oWSsaveAndSendTaskByReplacementappointment:Clone() )
	oClone:creplacementId := ::creplacementId
	oClone:oWSsaveAndSendTaskByReplacementresult :=  IIF(::oWSsaveAndSendTaskByReplacementresult = NIL , NIL ,::oWSsaveAndSendTaskByReplacementresult:Clone() )
	oClone:oWSstartProcessClassiccolleagueIds :=  IIF(::oWSstartProcessClassiccolleagueIds = NIL , NIL ,::oWSstartProcessClassiccolleagueIds:Clone() )
	oClone:oWSstartProcessClassicattachments :=  IIF(::oWSstartProcessClassicattachments = NIL , NIL ,::oWSstartProcessClassicattachments:Clone() )
	oClone:oWSstartProcessClassiccardData :=  IIF(::oWSstartProcessClassiccardData = NIL , NIL ,::oWSstartProcessClassiccardData:Clone() )
	oClone:oWSstartProcessClassicappointment :=  IIF(::oWSstartProcessClassicappointment = NIL , NIL ,::oWSstartProcessClassicappointment:Clone() )
	oClone:oWSstartProcessClassicresult :=  IIF(::oWSstartProcessClassicresult = NIL , NIL ,::oWSstartProcessClassicresult:Clone() )
	oClone:oWScalculateDeadLineTimeresult :=  IIF(::oWScalculateDeadLineTimeresult = NIL , NIL ,::oWScalculateDeadLineTimeresult:Clone() )
	oClone:oWSsimpleStartProcessattachments :=  IIF(::oWSsimpleStartProcessattachments = NIL , NIL ,::oWSsimpleStartProcessattachments:Clone() )
	oClone:oWSsimpleStartProcesscardData :=  IIF(::oWSsimpleStartProcesscardData = NIL , NIL ,::oWSsimpleStartProcesscardData:Clone() )
	oClone:oWSsimpleStartProcessresult :=  IIF(::oWSsimpleStartProcessresult = NIL , NIL ,::oWSsimpleStartProcessresult:Clone() )
	oClone:oWSgetAvailableProcessAvailableProcesses :=  IIF(::oWSgetAvailableProcessAvailableProcesses = NIL , NIL ,::oWSgetAvailableProcessAvailableProcesses:Clone() )
	oClone:oWSstartProcesscolleagueIds :=  IIF(::oWSstartProcesscolleagueIds = NIL , NIL ,::oWSstartProcesscolleagueIds:Clone() )
	oClone:oWSstartProcessattachments :=  IIF(::oWSstartProcessattachments = NIL , NIL ,::oWSstartProcessattachments:Clone() )
	oClone:oWSstartProcesscardData :=  IIF(::oWSstartProcesscardData = NIL , NIL ,::oWSstartProcesscardData:Clone() )
	oClone:oWSstartProcessappointment :=  IIF(::oWSstartProcessappointment = NIL , NIL ,::oWSstartProcessappointment:Clone() )
	oClone:oWSstartProcessresult :=  IIF(::oWSstartProcessresult = NIL , NIL ,::oWSstartProcessresult:Clone() )
	oClone:oWSgetAllActiveStatesStates :=  IIF(::oWSgetAllActiveStatesStates = NIL , NIL ,::oWSgetAllActiveStatesStates:Clone() )
	oClone:lfavorite     := ::lfavorite
	oClone:oWSsearchProcesssearchResults :=  IIF(::oWSsearchProcesssearchResults = NIL , NIL ,::oWSsearchProcesssearchResults:Clone() )
	oClone:nstate        := ::nstate
	oClone:ninitialUser  := ::ninitialUser
	oClone:cuserSearch   := ::cuserSearch
	oClone:oWSgetAvailableUsersOnDemandAvailableUsers :=  IIF(::oWSgetAvailableUsersOnDemandAvailableUsers = NIL , NIL ,::oWSgetAvailableUsersOnDemandAvailableUsers:Clone() )
	oClone:oWSsaveAndSendTaskClassiccolleagueIds :=  IIF(::oWSsaveAndSendTaskClassiccolleagueIds = NIL , NIL ,::oWSsaveAndSendTaskClassiccolleagueIds:Clone() )
	oClone:oWSsaveAndSendTaskClassicattachments :=  IIF(::oWSsaveAndSendTaskClassicattachments = NIL , NIL ,::oWSsaveAndSendTaskClassicattachments:Clone() )
	oClone:oWSsaveAndSendTaskClassiccardData :=  IIF(::oWSsaveAndSendTaskClassiccardData = NIL , NIL ,::oWSsaveAndSendTaskClassiccardData:Clone() )
	oClone:oWSsaveAndSendTaskClassicappointment :=  IIF(::oWSsaveAndSendTaskClassicappointment = NIL , NIL ,::oWSsaveAndSendTaskClassicappointment:Clone() )
	oClone:oWSsaveAndSendTaskClassicresult :=  IIF(::oWSsaveAndSendTaskClassicresult = NIL , NIL ,::oWSsaveAndSendTaskClassicresult:Clone() )
	oClone:oWSgetAvailableUsersStartOnDemandAvailableUsers :=  IIF(::oWSgetAvailableUsersStartOnDemandAvailableUsers = NIL , NIL ,::oWSgetAvailableUsersStartOnDemandAvailableUsers:Clone() )
	oClone:oWSgetAvailableUsersAvailableUsers :=  IIF(::oWSgetAvailableUsersAvailableUsers = NIL , NIL ,::oWSgetAvailableUsersAvailableUsers:Clone() )
	oClone:cImage        := ::cImage
	oClone:oWSgetAttachmentsAttachments :=  IIF(::oWSgetAttachmentsAttachments = NIL , NIL ,::oWSgetAttachmentsAttachments:Clone() )
	oClone:oWSimportProcessWithCardAndPersistenceTypeprocessAttachs :=  IIF(::oWSimportProcessWithCardAndPersistenceTypeprocessAttachs = NIL , NIL ,::oWSimportProcessWithCardAndPersistenceTypeprocessAttachs:Clone() )
	oClone:oWSimportProcessWithCardAndPersistenceTypecardAttachs :=  IIF(::oWSimportProcessWithCardAndPersistenceTypecardAttachs = NIL , NIL ,::oWSimportProcessWithCardAndPersistenceTypecardAttachs:Clone() )
	oClone:oWSimportProcessWithCardAndPersistenceTypecustomEvents :=  IIF(::oWSimportProcessWithCardAndPersistenceTypecustomEvents = NIL , NIL ,::oWSimportProcessWithCardAndPersistenceTypecustomEvents:Clone() )
	oClone:oWSimportProcessWithCardAndPersistenceTyperesult :=  IIF(::oWSimportProcessWithCardAndPersistenceTyperesult = NIL , NIL ,::oWSimportProcessWithCardAndPersistenceTyperesult:Clone() )
	oClone:oWSgetAvailableUsersStartAvailableUsers :=  IIF(::oWSgetAvailableUsersStartAvailableUsers = NIL , NIL ,::oWSgetAvailableUsersStartAvailableUsers:Clone() )
	oClone:oWSimportProcessWithCardAndGeneralInfoprocessAttachs :=  IIF(::oWSimportProcessWithCardAndGeneralInfoprocessAttachs = NIL , NIL ,::oWSimportProcessWithCardAndGeneralInfoprocessAttachs:Clone() )
	oClone:oWSimportProcessWithCardAndGeneralInfocardAttachs :=  IIF(::oWSimportProcessWithCardAndGeneralInfocardAttachs = NIL , NIL ,::oWSimportProcessWithCardAndGeneralInfocardAttachs:Clone() )
	oClone:oWSimportProcessWithCardAndGeneralInfocustomEvents :=  IIF(::oWSimportProcessWithCardAndGeneralInfocustomEvents = NIL , NIL ,::oWSimportProcessWithCardAndGeneralInfocustomEvents:Clone() )
	oClone:oWSimportProcessWithCardAndGeneralInfogeneralInfo :=  IIF(::oWSimportProcessWithCardAndGeneralInfogeneralInfo = NIL , NIL ,::oWSimportProcessWithCardAndGeneralInfogeneralInfo:Clone() )
	oClone:oWSimportProcessWithCardAndGeneralInforesult :=  IIF(::oWSimportProcessWithCardAndGeneralInforesult = NIL , NIL ,::oWSimportProcessWithCardAndGeneralInforesult:Clone() )
	oClone:oWSgetAvailableStatesStates :=  IIF(::oWSgetAvailableStatesStates = NIL , NIL ,::oWSgetAvailableStatesStates:Clone() )
	oClone:cusuario      := ::cusuario
	oClone:oWSupdateWorkflowAttachmentdocument :=  IIF(::oWSupdateWorkflowAttachmentdocument = NIL , NIL ,::oWSupdateWorkflowAttachmentdocument:Clone() )
	oClone:oWSupdateWorkflowAttachmentattachments :=  IIF(::oWSupdateWorkflowAttachmentattachments = NIL , NIL ,::oWSupdateWorkflowAttachmentattachments:Clone() )
	oClone:oWSgetHistoriesHistories :=  IIF(::oWSgetHistoriesHistories = NIL , NIL ,::oWSgetHistoriesHistories:Clone() )
Return oClone

// WSDL Method importProcess of Service WSECMWorkflowEngineServiceService

WSMETHOD importProcess WSSEND cusername,cpassword,ncompanyId,cprocessId,oWSimportProcessattachments,lnewProcess,loverWrite,ccolleagueId WSRECEIVE cresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:importProcess xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("attachments", ::oWSimportProcessattachments, oWSimportProcessattachments , "attachmentArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("newProcess", ::lnewProcess, lnewProcess , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("overWrite", ::loverWrite, loverWrite , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:importProcess>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"importProcess",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method setDueDate of Service WSECMWorkflowEngineServiceService

WSMETHOD setDueDate WSSEND cusername,cpassword,ncompanyId,nprocessInstanceId,cuserId,nthreadSequence,cnewDueDate,ntimeInSecods WSRECEIVE cresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:setDueDate xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("threadSequence", ::nthreadSequence, nthreadSequence , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("newDueDate", ::cnewDueDate, cnewDueDate , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("timeInSecods", ::ntimeInSecods, ntimeInSecods , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:setDueDate>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"setDueDate",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method takeProcessTask of Service WSECMWorkflowEngineServiceService

WSMETHOD takeProcessTask WSSEND cusername,cpassword,ncompanyId,cuserId,nprocessInstanceId,nthreadSequence WSRECEIVE cresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:takeProcessTask xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("threadSequence", ::nthreadSequence, nthreadSequence , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:takeProcessTask>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"takeProcessTask",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getInstanceCardData of Service WSECMWorkflowEngineServiceService

WSMETHOD getInstanceCardData WSSEND cusername,cpassword,ncompanyId,cuserId,nprocessInstanceId WSRECEIVE oWSgetInstanceCardDataCardData WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getInstanceCardData xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getInstanceCardData>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getInstanceCardData",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSgetInstanceCardDataCardData:SoapRecv( WSAdvValue( oXmlRet,"_CARDDATA","stringArrayArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method createWorkFlowProcessVersion of Service WSECMWorkflowEngineServiceService

WSMETHOD createWorkFlowProcessVersion WSSEND cusername,cpassword,ncompanyId,cprocessId WSRECEIVE cresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:createWorkFlowProcessVersion xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:createWorkFlowProcessVersion>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"createWorkFlowProcessVersion",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getCardValue of Service WSECMWorkflowEngineServiceService

WSMETHOD getCardValue WSSEND cusername,cpassword,ncompanyId,nprocessInstanceId,cuserId,ccardFieldName WSRECEIVE ccontent WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getCardValue xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardFieldName", ::ccardFieldName, ccardFieldName , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getCardValue>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getCardValue",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::ccontent           :=  WSAdvValue( oXmlRet,"_CONTENT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getAllProcessAvailableToExport of Service WSECMWorkflowEngineServiceService

WSMETHOD getAllProcessAvailableToExport WSSEND cusername,cpassword,ncompanyId WSRECEIVE oWSgetAllProcessAvailableToExportresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getAllProcessAvailableToExport xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getAllProcessAvailableToExport>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getAllProcessAvailableToExport",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSgetAllProcessAvailableToExportresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","processDefinitionDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method saveAndSendTask of Service WSECMWorkflowEngineServiceService

WSMETHOD saveAndSendTask WSSEND cusername,cpassword,ncompanyId,nprocessInstanceId,nchoosedState,oWSsaveAndSendTaskcolleagueIds,ccomments,cuserId,lcompleteTask,oWSsaveAndSendTaskattachments,oWSsaveAndSendTaskcardData,oWSsaveAndSendTaskappointment,lmanagerMode,nthreadSequence WSRECEIVE oWSsaveAndSendTaskresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:saveAndSendTask xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("choosedState", ::nchoosedState, nchoosedState , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("colleagueIds", ::oWSsaveAndSendTaskcolleagueIds, oWSsaveAndSendTaskcolleagueIds , "stringArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("comments", ::ccomments, ccomments , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("completeTask", ::lcompleteTask, lcompleteTask , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("attachments", ::oWSsaveAndSendTaskattachments, oWSsaveAndSendTaskattachments , "processAttachmentDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardData", ::oWSsaveAndSendTaskcardData, oWSsaveAndSendTaskcardData , "stringArrayArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("appointment", ::oWSsaveAndSendTaskappointment, oWSsaveAndSendTaskappointment , "processTaskAppointmentDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("managerMode", ::lmanagerMode, lmanagerMode , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("threadSequence", ::nthreadSequence, nthreadSequence , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:saveAndSendTask>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"saveAndSendTask",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSsaveAndSendTaskresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","stringArrayArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method setAutomaticDecisionClassic of Service WSECMWorkflowEngineServiceService

WSMETHOD setAutomaticDecisionClassic WSSEND cusername,cpassword,ncompanyId,nprocessInstanceId,niTaskAutom,niTask,ncondition,oWSsetAutomaticDecisionClassiccolleagueIds,ccomments,cuserId,lmanagerMode,nthreadSequence WSRECEIVE oWSsetAutomaticDecisionClassicresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:setAutomaticDecisionClassic xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("iTaskAutom", ::niTaskAutom, niTaskAutom , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("iTask", ::niTask, niTask , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("condition", ::ncondition, ncondition , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("colleagueIds", ::oWSsetAutomaticDecisionClassiccolleagueIds, oWSsetAutomaticDecisionClassiccolleagueIds , "stringArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("comments", ::ccomments, ccomments , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("managerMode", ::lmanagerMode, lmanagerMode , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("threadSequence", ::nthreadSequence, nthreadSequence , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:setAutomaticDecisionClassic>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"setAutomaticDecisionClassic",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSsetAutomaticDecisionClassicresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","keyValueDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method importProcessWithCardAndRelatedDatasets of Service WSECMWorkflowEngineServiceService

WSMETHOD importProcessWithCardAndRelatedDatasets WSSEND cusername,cpassword,ncompanyId,cprocessId,oWSimportProcessWithCardAndRelatedDatasetsprocessAttachs,lnewProcess,loverWrite,ccolleagueId,nparentDocumentId,cdocumentDescription,ccardDescription,cdatasetName,oWSimportProcessWithCardAndRelatedDatasetscardAttachs,oWSimportProcessWithCardAndRelatedDatasetscustomEvents,oWSimportProcessWithCardAndRelatedDatasetsgeneralInfo,lupdate,npersistenceType,oWSimportProcessWithCardAndRelatedDatasetsrelatedDatasets WSRECEIVE oWSimportProcessWithCardAndRelatedDatasetsresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:importProcessWithCardAndRelatedDatasets xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processAttachs", ::oWSimportProcessWithCardAndRelatedDatasetsprocessAttachs, oWSimportProcessWithCardAndRelatedDatasetsprocessAttachs , "attachmentArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("newProcess", ::lnewProcess, lnewProcess , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("overWrite", ::loverWrite, loverWrite , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("parentDocumentId", ::nparentDocumentId, nparentDocumentId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("documentDescription", ::cdocumentDescription, cdocumentDescription , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardDescription", ::ccardDescription, ccardDescription , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("datasetName", ::cdatasetName, cdatasetName , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardAttachs", ::oWSimportProcessWithCardAndRelatedDatasetscardAttachs, oWSimportProcessWithCardAndRelatedDatasetscardAttachs , "attachmentArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("customEvents", ::oWSimportProcessWithCardAndRelatedDatasetscustomEvents, oWSimportProcessWithCardAndRelatedDatasetscustomEvents , "cardEventDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("generalInfo", ::oWSimportProcessWithCardAndRelatedDatasetsgeneralInfo, oWSimportProcessWithCardAndRelatedDatasetsgeneralInfo , "generalInfoDto", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("update", ::lupdate, lupdate , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("persistenceType", ::npersistenceType, npersistenceType , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("relatedDatasets", ::oWSimportProcessWithCardAndRelatedDatasetsrelatedDatasets, oWSimportProcessWithCardAndRelatedDatasetsrelatedDatasets , "stringArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:importProcessWithCardAndRelatedDatasets>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"importProcessWithCardAndRelatedDatasets",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSimportProcessWithCardAndRelatedDatasetsresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessage",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method calculateDeadLineHours of Service WSECMWorkflowEngineServiceService

WSMETHOD calculateDeadLineHours WSSEND cusername,cpassword,ncompanyId,cuserId,cdata,nhora,nprazo,cperiodId WSRECEIVE oWScalculateDeadLineHoursresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:calculateDeadLineHours xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("data", ::cdata, cdata , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("hora", ::nhora, nhora , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("prazo", ::nprazo, nprazo , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("periodId", ::cperiodId, cperiodId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:calculateDeadLineHours>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"calculeDeadLineHours",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWScalculateDeadLineHoursresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","deadLineDto",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getAllProcessAvailableToImport of Service WSECMWorkflowEngineServiceService

WSMETHOD getAllProcessAvailableToImport WSSEND cusername,cpassword,ncompanyId WSRECEIVE oWSgetAllProcessAvailableToImportresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getAllProcessAvailableToImport xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getAllProcessAvailableToImport>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getAllProcessAvailableToImport",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSgetAllProcessAvailableToImportresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","processDefinitionDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method cancelInstance of Service WSECMWorkflowEngineServiceService

WSMETHOD cancelInstance WSSEND cusername,cpassword,ncompanyId,nprocessInstanceId,cuserId,ccancelText WSRECEIVE cresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:cancelInstance xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cancelText", ::ccancelText, ccancelText , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:cancelInstance>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"cancelInstance",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getActualThread of Service WSECMWorkflowEngineServiceService

WSMETHOD getActualThread WSSEND cusername,cpassword,ncompanyId,nprocessInstanceId,nstateSequence WSRECEIVE nActualThread WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getActualThread xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("stateSequence", ::nstateSequence, nstateSequence , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getActualThread>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getActualThread",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::nActualThread      :=  WSAdvValue( oXmlRet,"_ACTUALTHREAD","int",NIL,NIL,NIL,"N",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getWorkFlowProcessVersion of Service WSECMWorkflowEngineServiceService

WSMETHOD getWorkFlowProcessVersion WSSEND cusername,cpassword,ncompanyId,cprocessId WSRECEIVE nresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getWorkFlowProcessVersion xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getWorkFlowProcessVersion>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getWorkFlowProcessVersion",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::nresult            :=  WSAdvValue( oXmlRet,"_RESULT","int",NIL,NIL,NIL,"N",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getAvailableProcessOnDemand of Service WSECMWorkflowEngineServiceService

WSMETHOD getAvailableProcessOnDemand WSSEND cusername,cpassword,ncompanyId,cuserId,nlimit,nlastRowId WSRECEIVE oWSgetAvailableProcessOnDemandAvailableProcesses WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getAvailableProcessOnDemand xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("limit", ::nlimit, nlimit , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("lastRowId", ::nlastRowId, nlastRowId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getAvailableProcessOnDemand>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getAvailableProcessOnDemand",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSgetAvailableProcessOnDemandAvailableProcesses:SoapRecv( WSAdvValue( oXmlRet,"_AVAILABLEPROCESSES","processDefinitionVersionDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getAvailableStatesDetail of Service WSECMWorkflowEngineServiceService

WSMETHOD getAvailableStatesDetail WSSEND cusername,cpassword,ncompanyId,cprocessId,nprocessInstanceId,nthreadSequence WSRECEIVE oWSgetAvailableStatesDetailAvailableStatesDetail WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getAvailableStatesDetail xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("threadSequence", ::nthreadSequence, nthreadSequence , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getAvailableStatesDetail>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getAvailableStatesDetail",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSgetAvailableStatesDetailAvailableStatesDetail:SoapRecv( WSAdvValue( oXmlRet,"_AVAILABLESTATESDETAIL","processStateDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method exportProcessInZipFormat of Service WSECMWorkflowEngineServiceService

WSMETHOD exportProcessInZipFormat WSSEND cusername,cpassword,ncompanyId,cprocessId WSRECEIVE cresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:exportProcessInZipFormat xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:exportProcessInZipFormat>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"exportProcess",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method importProcessWithCard of Service WSECMWorkflowEngineServiceService

WSMETHOD importProcessWithCard WSSEND cusername,cpassword,ncompanyId,cprocessId,oWSimportProcessWithCardprocessAttachs,lnewProcess,loverWrite,ccolleagueId,nparentDocumentId,cdocumentDescription,ccardDescription,cdatasetName,oWSimportProcessWithCardcardAttachs,oWSimportProcessWithCardcustomEvents,lupdate WSRECEIVE oWSimportProcessWithCardresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:importProcessWithCard xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processAttachs", ::oWSimportProcessWithCardprocessAttachs, oWSimportProcessWithCardprocessAttachs , "attachmentArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("newProcess", ::lnewProcess, lnewProcess , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("overWrite", ::loverWrite, loverWrite , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("parentDocumentId", ::nparentDocumentId, nparentDocumentId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("documentDescription", ::cdocumentDescription, cdocumentDescription , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardDescription", ::ccardDescription, ccardDescription , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("datasetName", ::cdatasetName, cdatasetName , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardAttachs", ::oWSimportProcessWithCardcardAttachs, oWSimportProcessWithCardcardAttachs , "attachmentArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("customEvents", ::oWSimportProcessWithCardcustomEvents, oWSimportProcessWithCardcustomEvents , "cardEventDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("update", ::lupdate, lupdate , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:importProcessWithCard>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"importProcessWithCard",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSimportProcessWithCardresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessage",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method saveAndSendTaskByReplacement of Service WSECMWorkflowEngineServiceService

WSMETHOD saveAndSendTaskByReplacement WSSEND cusername,cpassword,ncompanyId,nprocessInstanceId,nchoosedState,oWSsaveAndSendTaskByReplacementcolleagueIds,ccomments,cuserId,lcompleteTask,oWSsaveAndSendTaskByReplacementattachments,oWSsaveAndSendTaskByReplacementcardData,oWSsaveAndSendTaskByReplacementappointment,lmanagerMode,nthreadSequence,creplacementId WSRECEIVE oWSsaveAndSendTaskByReplacementresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:saveAndSendTaskByReplacement xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("choosedState", ::nchoosedState, nchoosedState , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("colleagueIds", ::oWSsaveAndSendTaskByReplacementcolleagueIds, oWSsaveAndSendTaskByReplacementcolleagueIds , "stringArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("comments", ::ccomments, ccomments , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("completeTask", ::lcompleteTask, lcompleteTask , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("attachments", ::oWSsaveAndSendTaskByReplacementattachments, oWSsaveAndSendTaskByReplacementattachments , "processAttachmentDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardData", ::oWSsaveAndSendTaskByReplacementcardData, oWSsaveAndSendTaskByReplacementcardData , "stringArrayArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("appointment", ::oWSsaveAndSendTaskByReplacementappointment, oWSsaveAndSendTaskByReplacementappointment , "processTaskAppointmentDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("managerMode", ::lmanagerMode, lmanagerMode , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("threadSequence", ::nthreadSequence, nthreadSequence , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("replacementId", ::creplacementId, creplacementId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:saveAndSendTaskByReplacement>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"saveAndSendTaskByReplacement",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSsaveAndSendTaskByReplacementresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","stringArrayArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method startProcessClassic of Service WSECMWorkflowEngineServiceService

WSMETHOD startProcessClassic WSSEND cusername,cpassword,ncompanyId,cprocessId,nchoosedState,oWSstartProcessClassiccolleagueIds,ccomments,cuserId,lcompleteTask,oWSstartProcessClassicattachments,oWSstartProcessClassiccardData,oWSstartProcessClassicappointment,lmanagerMode WSRECEIVE oWSstartProcessClassicresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:startProcessClassic xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("choosedState", ::nchoosedState, nchoosedState , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("colleagueIds", ::oWSstartProcessClassiccolleagueIds, oWSstartProcessClassiccolleagueIds , "stringArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("comments", ::ccomments, ccomments , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("completeTask", ::lcompleteTask, lcompleteTask , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("attachments", ::oWSstartProcessClassicattachments, oWSstartProcessClassicattachments , "processAttachmentDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardData", ::oWSstartProcessClassiccardData, oWSstartProcessClassiccardData , "keyValueDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("appointment", ::oWSstartProcessClassicappointment, oWSstartProcessClassicappointment , "processTaskAppointmentDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("managerMode", ::lmanagerMode, lmanagerMode , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:startProcessClassic>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"startProcessClassic",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSstartProcessClassicresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","keyValueDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method cancelInstanceByReplacement of Service WSECMWorkflowEngineServiceService

WSMETHOD cancelInstanceByReplacement WSSEND cusername,cpassword,ncompanyId,nprocessInstanceId,cuserId,ccancelText,creplacementId WSRECEIVE cresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:cancelInstanceByReplacement xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cancelText", ::ccancelText, ccancelText , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("replacementId", ::creplacementId, creplacementId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:cancelInstanceByReplacement>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"cancelInstanceByReplacement",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method calculateDeadLineTime of Service WSECMWorkflowEngineServiceService

WSMETHOD calculateDeadLineTime WSSEND cusername,cpassword,ncompanyId,cuserId,cdata,nhora,nprazo,cperiodId WSRECEIVE oWScalculateDeadLineTimeresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:calculateDeadLineTime xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("data", ::cdata, cdata , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("hora", ::nhora, nhora , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("prazo", ::nprazo, nprazo , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("periodId", ::cperiodId, cperiodId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:calculateDeadLineTime>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"calculeDeadLineTime",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWScalculateDeadLineTimeresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","deadLineDto",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method simpleStartProcess of Service WSECMWorkflowEngineServiceService

WSMETHOD simpleStartProcess WSSEND cusername,cpassword,ncompanyId,cprocessId,ccomments,oWSsimpleStartProcessattachments,oWSsimpleStartProcesscardData WSRECEIVE oWSsimpleStartProcessresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:simpleStartProcess xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("comments", ::ccomments, ccomments , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("attachments", ::oWSsimpleStartProcessattachments, oWSsimpleStartProcessattachments , "processAttachmentDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardData", ::oWSsimpleStartProcesscardData, oWSsimpleStartProcesscardData , "stringArrayArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:simpleStartProcess>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"simpleStartProcess",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSsimpleStartProcessresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","stringArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getAvailableProcess of Service WSECMWorkflowEngineServiceService

WSMETHOD getAvailableProcess WSSEND cusername,cpassword,ncompanyId,cuserId WSRECEIVE oWSgetAvailableProcessAvailableProcesses WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getAvailableProcess xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getAvailableProcess>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getAvailableProcess",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSgetAvailableProcessAvailableProcesses:SoapRecv( WSAdvValue( oXmlRet,"_AVAILABLEPROCESSES","processDefinitionVersionDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method startProcess of Service WSECMWorkflowEngineServiceService

WSMETHOD startProcess WSSEND cusername,cpassword,ncompanyId,cprocessId,nchoosedState,oWSstartProcesscolleagueIds,ccomments,cuserId,lcompleteTask,oWSstartProcessattachments,oWSstartProcesscardData,oWSstartProcessappointment,lmanagerMode WSRECEIVE oWSstartProcessresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:startProcess xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("choosedState", ::nchoosedState, nchoosedState , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("colleagueIds", ::oWSstartProcesscolleagueIds, oWSstartProcesscolleagueIds , "stringArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("comments", ::ccomments, ccomments , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("completeTask", ::lcompleteTask, lcompleteTask , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("attachments", ::oWSstartProcessattachments, oWSstartProcessattachments , "processAttachmentDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardData", ::oWSstartProcesscardData, oWSstartProcesscardData , "stringArrayArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("appointment", ::oWSstartProcessappointment, oWSstartProcessappointment , "processTaskAppointmentDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("managerMode", ::lmanagerMode, lmanagerMode , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:startProcess>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"startProcess",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSstartProcessresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","stringArrayArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getAllActiveStates of Service WSECMWorkflowEngineServiceService

WSMETHOD getAllActiveStates WSSEND cusername,cpassword,ncompanyId,cuserId,nprocessInstanceId WSRECEIVE oWSgetAllActiveStatesStates WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getAllActiveStates xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getAllActiveStates>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getAllActiveStates",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSgetAllActiveStatesStates:SoapRecv( WSAdvValue( oXmlRet,"_STATES","intArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method releaseProcess of Service WSECMWorkflowEngineServiceService

WSMETHOD releaseProcess WSSEND cusername,cpassword,ncompanyId,cprocessId WSRECEIVE cresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:releaseProcess xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:releaseProcess>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"relaseProcess",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method setTasksComments of Service WSECMWorkflowEngineServiceService

WSMETHOD setTasksComments WSSEND cusername,cpassword,ncompanyId,nprocessInstanceId,cuserId,nthreadSequence,ccomments WSRECEIVE cresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:setTasksComments xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("threadSequence", ::nthreadSequence, nthreadSequence , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("comments", ::ccomments, ccomments , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:setTasksComments>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"setTasksComments",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method searchProcess of Service WSECMWorkflowEngineServiceService

WSMETHOD searchProcess WSSEND cusername,cpassword,ncompanyId,ccolleagueId,ccontent,lfavorite WSRECEIVE oWSsearchProcesssearchResults WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:searchProcess xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("content", ::ccontent, ccontent , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("favorite", ::lfavorite, lfavorite , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:searchProcess>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"searchProcess",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSsearchProcesssearchResults:SoapRecv( WSAdvValue( oXmlRet,"_SEARCHRESULTS","processDefinitionVersionDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getAvailableUsersOnDemand of Service WSECMWorkflowEngineServiceService

WSMETHOD getAvailableUsersOnDemand WSSEND cusername,cpassword,ncompanyId,nprocessInstanceId,nstate,nthreadSequence,nlimit,ninitialUser,cuserSearch WSRECEIVE oWSgetAvailableUsersOnDemandAvailableUsers WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getAvailableUsersOnDemand xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("state", ::nstate, nstate , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("threadSequence", ::nthreadSequence, nthreadSequence , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("limit", ::nlimit, nlimit , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("initialUser", ::ninitialUser, ninitialUser , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userSearch", ::cuserSearch, cuserSearch , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getAvailableUsersOnDemand>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getAvailableUsersOnDemand",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSgetAvailableUsersOnDemandAvailableUsers:SoapRecv( WSAdvValue( oXmlRet,"_AVAILABLEUSERS","availableUsersDto",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getProcessFormId of Service WSECMWorkflowEngineServiceService

WSMETHOD getProcessFormId WSSEND cusername,cpassword,ncompanyId,cprocessId WSRECEIVE nresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getProcessFormId xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getProcessFormId>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getProcessFormId",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::nresult            :=  WSAdvValue( oXmlRet,"_RESULT","int",NIL,NIL,NIL,"N",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method saveAndSendTaskClassic of Service WSECMWorkflowEngineServiceService

WSMETHOD saveAndSendTaskClassic WSSEND cusername,cpassword,ncompanyId,nprocessInstanceId,nchoosedState,oWSsaveAndSendTaskClassiccolleagueIds,ccomments,cuserId,lcompleteTask,oWSsaveAndSendTaskClassicattachments,oWSsaveAndSendTaskClassiccardData,oWSsaveAndSendTaskClassicappointment,lmanagerMode,nthreadSequence WSRECEIVE oWSsaveAndSendTaskClassicresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:saveAndSendTaskClassic xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("choosedState", ::nchoosedState, nchoosedState , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("colleagueIds", ::oWSsaveAndSendTaskClassiccolleagueIds, oWSsaveAndSendTaskClassiccolleagueIds , "stringArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("comments", ::ccomments, ccomments , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("completeTask", ::lcompleteTask, lcompleteTask , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("attachments", ::oWSsaveAndSendTaskClassicattachments, oWSsaveAndSendTaskClassicattachments , "processAttachmentDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardData", ::oWSsaveAndSendTaskClassiccardData, oWSsaveAndSendTaskClassiccardData , "keyValueDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("appointment", ::oWSsaveAndSendTaskClassicappointment, oWSsaveAndSendTaskClassicappointment , "processTaskAppointmentDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("managerMode", ::lmanagerMode, lmanagerMode , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("threadSequence", ::nthreadSequence, nthreadSequence , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:saveAndSendTaskClassic>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"saveAndSendTaskClassic",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSsaveAndSendTaskClassicresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","keyValueDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getAvailableUsersStartOnDemand of Service WSECMWorkflowEngineServiceService

WSMETHOD getAvailableUsersStartOnDemand WSSEND cusername,cpassword,ncompanyId,cprocessId,nstate,nthreadSequence,nlimit,ninitialUser,cuserSearch WSRECEIVE oWSgetAvailableUsersStartOnDemandAvailableUsers WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getAvailableUsersStartOnDemand xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("state", ::nstate, nstate , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("threadSequence", ::nthreadSequence, nthreadSequence , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("limit", ::nlimit, nlimit , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("initialUser", ::ninitialUser, ninitialUser , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userSearch", ::cuserSearch, cuserSearch , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getAvailableUsersStartOnDemand>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getAvailableUsersStartOnDemand",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSgetAvailableUsersStartOnDemandAvailableUsers:SoapRecv( WSAdvValue( oXmlRet,"_AVAILABLEUSERS","availableUsersDto",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getAvailableUsers of Service WSECMWorkflowEngineServiceService

WSMETHOD getAvailableUsers WSSEND cusername,cpassword,ncompanyId,nprocessInstanceId,nstate,nthreadSequence WSRECEIVE oWSgetAvailableUsersAvailableUsers WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getAvailableUsers xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("state", ::nstate, nstate , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("threadSequence", ::nthreadSequence, nthreadSequence , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getAvailableUsers>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getAvailableUsers",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSgetAvailableUsersAvailableUsers:SoapRecv( WSAdvValue( oXmlRet,"_AVAILABLEUSERS","stringArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getProcessImage of Service WSECMWorkflowEngineServiceService

WSMETHOD getProcessImage WSSEND cusername,cpassword,ncompanyId,cuserId,cprocessId WSRECEIVE cImage WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getProcessImage xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getProcessImage>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getProcessImage",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::cImage             :=  WSAdvValue( oXmlRet,"_IMAGE","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getAttachments of Service WSECMWorkflowEngineServiceService

WSMETHOD getAttachments WSSEND cusername,cpassword,ncompanyId,cuserId,nprocessInstanceId WSRECEIVE oWSgetAttachmentsAttachments WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getAttachments xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getAttachments>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getAttachments",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSgetAttachmentsAttachments:SoapRecv( WSAdvValue( oXmlRet,"_ATTACHMENTS","processAttachmentDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method importProcessWithCardAndPersistenceType of Service WSECMWorkflowEngineServiceService

WSMETHOD importProcessWithCardAndPersistenceType WSSEND cusername,cpassword,ncompanyId,cprocessId,oWSimportProcessWithCardAndPersistenceTypeprocessAttachs,lnewProcess,loverWrite,ccolleagueId,nparentDocumentId,cdocumentDescription,ccardDescription,cdatasetName,oWSimportProcessWithCardAndPersistenceTypecardAttachs,oWSimportProcessWithCardAndPersistenceTypecustomEvents,lupdate,npersistenceType WSRECEIVE oWSimportProcessWithCardAndPersistenceTyperesult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:importProcessWithCardAndPersistenceType xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processAttachs", ::oWSimportProcessWithCardAndPersistenceTypeprocessAttachs, oWSimportProcessWithCardAndPersistenceTypeprocessAttachs , "attachmentArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("newProcess", ::lnewProcess, lnewProcess , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("overWrite", ::loverWrite, loverWrite , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("parentDocumentId", ::nparentDocumentId, nparentDocumentId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("documentDescription", ::cdocumentDescription, cdocumentDescription , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardDescription", ::ccardDescription, ccardDescription , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("datasetName", ::cdatasetName, cdatasetName , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardAttachs", ::oWSimportProcessWithCardAndPersistenceTypecardAttachs, oWSimportProcessWithCardAndPersistenceTypecardAttachs , "attachmentArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("customEvents", ::oWSimportProcessWithCardAndPersistenceTypecustomEvents, oWSimportProcessWithCardAndPersistenceTypecustomEvents , "cardEventDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("update", ::lupdate, lupdate , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("persistenceType", ::npersistenceType, npersistenceType , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:importProcessWithCardAndPersistenceType>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"importProcessWithCardAndPersistenceType",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSimportProcessWithCardAndPersistenceTyperesult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessage",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getAvailableUsersStart of Service WSECMWorkflowEngineServiceService

WSMETHOD getAvailableUsersStart WSSEND cusername,cpassword,ncompanyId,cprocessId,nstate,nthreadSequence WSRECEIVE oWSgetAvailableUsersStartAvailableUsers WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getAvailableUsersStart xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("state", ::nstate, nstate , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("threadSequence", ::nthreadSequence, nthreadSequence , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getAvailableUsersStart>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getAvailableUsersStart",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSgetAvailableUsersStartAvailableUsers:SoapRecv( WSAdvValue( oXmlRet,"_AVAILABLEUSERS","stringArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method importProcessWithCardAndGeneralInfo of Service WSECMWorkflowEngineServiceService

WSMETHOD importProcessWithCardAndGeneralInfo WSSEND cusername,cpassword,ncompanyId,cprocessId,oWSimportProcessWithCardAndGeneralInfoprocessAttachs,lnewProcess,loverWrite,ccolleagueId,nparentDocumentId,cdocumentDescription,ccardDescription,cdatasetName,oWSimportProcessWithCardAndGeneralInfocardAttachs,oWSimportProcessWithCardAndGeneralInfocustomEvents,oWSimportProcessWithCardAndGeneralInfogeneralInfo,lupdate,npersistenceType WSRECEIVE oWSimportProcessWithCardAndGeneralInforesult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:importProcessWithCardAndGeneralInfo xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processAttachs", ::oWSimportProcessWithCardAndGeneralInfoprocessAttachs, oWSimportProcessWithCardAndGeneralInfoprocessAttachs , "attachmentArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("newProcess", ::lnewProcess, lnewProcess , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("overWrite", ::loverWrite, loverWrite , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("parentDocumentId", ::nparentDocumentId, nparentDocumentId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("documentDescription", ::cdocumentDescription, cdocumentDescription , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardDescription", ::ccardDescription, ccardDescription , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("datasetName", ::cdatasetName, cdatasetName , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardAttachs", ::oWSimportProcessWithCardAndGeneralInfocardAttachs, oWSimportProcessWithCardAndGeneralInfocardAttachs , "attachmentArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("customEvents", ::oWSimportProcessWithCardAndGeneralInfocustomEvents, oWSimportProcessWithCardAndGeneralInfocustomEvents , "cardEventDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("generalInfo", ::oWSimportProcessWithCardAndGeneralInfogeneralInfo, oWSimportProcessWithCardAndGeneralInfogeneralInfo , "generalInfoDto", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("update", ::lupdate, lupdate , "boolean", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("persistenceType", ::npersistenceType, npersistenceType , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:importProcessWithCardAndGeneralInfo>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"importProcessWithCardAndGeneralInfo",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSimportProcessWithCardAndGeneralInforesult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessage",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method takeProcessTaskByReplacement of Service WSECMWorkflowEngineServiceService

WSMETHOD takeProcessTaskByReplacement WSSEND cusername,cpassword,ncompanyId,cuserId,nprocessInstanceId,nthreadSequence,creplacementId WSRECEIVE cresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:takeProcessTaskByReplacement xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("threadSequence", ::nthreadSequence, nthreadSequence , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("replacementId", ::creplacementId, creplacementId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:takeProcessTaskByReplacement>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"takeProcessTaskByReplacement",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method exportProcess of Service WSECMWorkflowEngineServiceService

WSMETHOD exportProcess WSSEND cusername,cpassword,ncompanyId,cprocessId WSRECEIVE cresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:exportProcess xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:exportProcess>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"exportProcess",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getAvailableStates of Service WSECMWorkflowEngineServiceService

WSMETHOD getAvailableStates WSSEND cusername,cpassword,ncompanyId,cprocessId,nprocessInstanceId,nthreadSequence WSRECEIVE oWSgetAvailableStatesStates WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getAvailableStates xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processId", ::cprocessId, cprocessId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("threadSequence", ::nthreadSequence, nthreadSequence , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getAvailableStates>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getAvailbleStates",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSgetAvailableStatesStates:SoapRecv( WSAdvValue( oXmlRet,"_STATES","intArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method updateWorkflowAttachment of Service WSECMWorkflowEngineServiceService

WSMETHOD updateWorkflowAttachment WSSEND cusername,cpassword,ncompanyId,nprocessInstanceId,cusuario,oWSupdateWorkflowAttachmentdocument,oWSupdateWorkflowAttachmentattachments WSRECEIVE cresult WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:updateWorkflowAttachment xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("usuario", ::cusuario, cusuario , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("document", ::oWSupdateWorkflowAttachmentdocument, oWSupdateWorkflowAttachmentdocument , "documentDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("attachments", ::oWSupdateWorkflowAttachmentattachments, oWSupdateWorkflowAttachmentattachments , "attachmentArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:updateWorkflowAttachment>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"updateWorkflowAttachment",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getHistories of Service WSECMWorkflowEngineServiceService

WSMETHOD getHistories WSSEND cusername,cpassword,ncompanyId,cuserId,nprocessInstanceId WSRECEIVE oWSgetHistoriesHistories WSCLIENT WSECMWorkflowEngineServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getHistories xmlns:q1="http://ws.workflow.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("userId", ::cuserId, cuserId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, nprocessInstanceId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getHistories>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getHistories",; 
	"RPCX","http://ws.workflow.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMWorkflowEngineService")

::Init()
::oWSgetHistoriesHistories:SoapRecv( WSAdvValue( oXmlRet,"_HISTORIES","processHistoryDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure attachmentArray

WSSTRUCT ECMWorkflowEngineServiceService_attachmentArray
	WSDATA   oWSitem                   AS ECMWorkflowEngineServiceService_attachment OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_attachmentArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_attachmentArray
	::oWSitem              := {} // Array Of  ECMWorkflowEngineServiceService_ATTACHMENT():New()
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_attachmentArray
	Local oClone := ECMWorkflowEngineServiceService_attachmentArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMWorkflowEngineServiceService_attachmentArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "attachment", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure stringArrayArray

WSSTRUCT ECMWorkflowEngineServiceService_stringArrayArray
	WSDATA   oWSitem                   AS ECMWorkflowEngineServiceService_stringArray OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_stringArrayArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_stringArrayArray
	::oWSitem              := {} // Array Of  ECMWorkflowEngineServiceService_STRINGARRAY():New()
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_stringArrayArray
	Local oClone := ECMWorkflowEngineServiceService_stringArrayArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMWorkflowEngineServiceService_stringArrayArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "stringArray", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_stringArrayArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , ECMWorkflowEngineServiceService_stringArray():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure processDefinitionDtoArray

WSSTRUCT ECMWorkflowEngineServiceService_processDefinitionDtoArray
	WSDATA   oWSitem                   AS ECMWorkflowEngineServiceService_processDefinitionDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_processDefinitionDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_processDefinitionDtoArray
	::oWSitem              := {} // Array Of  ECMWorkflowEngineServiceService_PROCESSDEFINITIONDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_processDefinitionDtoArray
	Local oClone := ECMWorkflowEngineServiceService_processDefinitionDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_processDefinitionDtoArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , ECMWorkflowEngineServiceService_processDefinitionDto():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure stringArray

WSSTRUCT ECMWorkflowEngineServiceService_stringArray
	WSDATA   citem                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_stringArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_stringArray
	::citem                := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_stringArray
	Local oClone := ECMWorkflowEngineServiceService_stringArray():NEW()
	oClone:citem                := IIf(::citem <> NIL , aClone(::citem) , NIL )
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMWorkflowEngineServiceService_stringArray
	Local cSoap := ""
	aEval( ::citem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "string", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_stringArray
	Local oNodes1 :=  WSAdvValue( oResponse,"_ITEM","string",{},NIL,.T.,"S",NIL,"xs") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	aEval(oNodes1 , { |x| aadd(::citem ,  x:TEXT  ) } )
Return

// WSDL Data Structure processAttachmentDtoArray

WSSTRUCT ECMWorkflowEngineServiceService_processAttachmentDtoArray
	WSDATA   oWSitem                   AS ECMWorkflowEngineServiceService_processAttachmentDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_processAttachmentDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_processAttachmentDtoArray
	::oWSitem              := {} // Array Of  ECMWorkflowEngineServiceService_PROCESSATTACHMENTDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_processAttachmentDtoArray
	Local oClone := ECMWorkflowEngineServiceService_processAttachmentDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMWorkflowEngineServiceService_processAttachmentDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "processAttachmentDto", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_processAttachmentDtoArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , ECMWorkflowEngineServiceService_processAttachmentDto():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure processTaskAppointmentDtoArray

WSSTRUCT ECMWorkflowEngineServiceService_processTaskAppointmentDtoArray
	WSDATA   oWSitem                   AS ECMWorkflowEngineServiceService_processTaskAppointmentDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_processTaskAppointmentDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_processTaskAppointmentDtoArray
	::oWSitem              := {} // Array Of  ECMWorkflowEngineServiceService_PROCESSTASKAPPOINTMENTDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_processTaskAppointmentDtoArray
	Local oClone := ECMWorkflowEngineServiceService_processTaskAppointmentDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMWorkflowEngineServiceService_processTaskAppointmentDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "processTaskAppointmentDto", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure keyValueDtoArray

WSSTRUCT ECMWorkflowEngineServiceService_keyValueDtoArray
	WSDATA   oWSitem                   AS ECMWorkflowEngineServiceService_keyValueDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_keyValueDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_keyValueDtoArray
	::oWSitem              := {} // Array Of  ECMWorkflowEngineServiceService_KEYVALUEDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_keyValueDtoArray
	Local oClone := ECMWorkflowEngineServiceService_keyValueDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMWorkflowEngineServiceService_keyValueDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "keyValueDto", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_keyValueDtoArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , ECMWorkflowEngineServiceService_keyValueDto():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure cardEventDtoArray

WSSTRUCT ECMWorkflowEngineServiceService_cardEventDtoArray
	WSDATA   oWSitem                   AS ECMWorkflowEngineServiceService_cardEventDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_cardEventDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_cardEventDtoArray
	::oWSitem              := {} // Array Of  ECMWorkflowEngineServiceService_CARDEVENTDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_cardEventDtoArray
	Local oClone := ECMWorkflowEngineServiceService_cardEventDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMWorkflowEngineServiceService_cardEventDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "cardEventDto", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure generalInfoDto

WSSTRUCT ECMWorkflowEngineServiceService_generalInfoDto
	WSDATA   cversionOption            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_generalInfoDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_generalInfoDto
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_generalInfoDto
	Local oClone := ECMWorkflowEngineServiceService_generalInfoDto():NEW()
	oClone:cversionOption       := ::cversionOption
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMWorkflowEngineServiceService_generalInfoDto
	Local cSoap := ""
	cSoap += WSSoapValue("versionOption", ::cversionOption, ::cversionOption , "string", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure webServiceMessage

WSSTRUCT ECMWorkflowEngineServiceService_webServiceMessage
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   cdocumentDescription      AS string OPTIONAL
	WSDATA   ndocumentId               AS int OPTIONAL
	WSDATA   cfoo                      AS string OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSDATA   cwebServiceMessage        AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_webServiceMessage
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_webServiceMessage
	::cfoo                 := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_webServiceMessage
	Local oClone := ECMWorkflowEngineServiceService_webServiceMessage():NEW()
	oClone:ncompanyId           := ::ncompanyId
	oClone:cdocumentDescription := ::cdocumentDescription
	oClone:ndocumentId          := ::ndocumentId
	oClone:cfoo                 := IIf(::cfoo <> NIL , aClone(::cfoo) , NIL )
	oClone:nversion             := ::nversion
	oClone:cwebServiceMessage   := ::cwebServiceMessage
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_webServiceMessage
	Local oNodes4 :=  WSAdvValue( oResponse,"_FOO","string",{},NIL,.T.,"S",NIL,"xs") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::cdocumentDescription :=  WSAdvValue( oResponse,"_DOCUMENTDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ndocumentId        :=  WSAdvValue( oResponse,"_DOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	aEval(oNodes4 , { |x| aadd(::cfoo ,  x:TEXT  ) } )
	::nversion           :=  WSAdvValue( oResponse,"_VERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cwebServiceMessage :=  WSAdvValue( oResponse,"_WEBSERVICEMESSAGE","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure deadLineDto

WSSTRUCT ECMWorkflowEngineServiceService_deadLineDto
	WSDATA   cdate                     AS string OPTIONAL
	WSDATA   nhora                     AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_deadLineDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_deadLineDto
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_deadLineDto
	Local oClone := ECMWorkflowEngineServiceService_deadLineDto():NEW()
	oClone:cdate                := ::cdate
	oClone:nhora                := ::nhora
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_deadLineDto
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cdate              :=  WSAdvValue( oResponse,"_DATE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nhora              :=  WSAdvValue( oResponse,"_HORA","int",NIL,NIL,NIL,"N",NIL,"xs") 
Return

// WSDL Data Structure processDefinitionVersionDtoArray

WSSTRUCT ECMWorkflowEngineServiceService_processDefinitionVersionDtoArray
	WSDATA   oWSitem                   AS ECMWorkflowEngineServiceService_processDefinitionVersionDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_processDefinitionVersionDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_processDefinitionVersionDtoArray
	::oWSitem              := {} // Array Of  ECMWorkflowEngineServiceService_PROCESSDEFINITIONVERSIONDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_processDefinitionVersionDtoArray
	Local oClone := ECMWorkflowEngineServiceService_processDefinitionVersionDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_processDefinitionVersionDtoArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , ECMWorkflowEngineServiceService_processDefinitionVersionDto():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure processStateDtoArray

WSSTRUCT ECMWorkflowEngineServiceService_processStateDtoArray
	WSDATA   oWSitem                   AS ECMWorkflowEngineServiceService_processStateDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_processStateDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_processStateDtoArray
	::oWSitem              := {} // Array Of  ECMWorkflowEngineServiceService_PROCESSSTATEDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_processStateDtoArray
	Local oClone := ECMWorkflowEngineServiceService_processStateDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_processStateDtoArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , ECMWorkflowEngineServiceService_processStateDto():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure intArray

WSSTRUCT ECMWorkflowEngineServiceService_intArray
	WSDATA   nitem                     AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_intArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_intArray
	::nitem                := {} // Array Of  0
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_intArray
	Local oClone := ECMWorkflowEngineServiceService_intArray():NEW()
	oClone:nitem                := IIf(::nitem <> NIL , aClone(::nitem) , NIL )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_intArray
	Local oNodes1 :=  WSAdvValue( oResponse,"_ITEM","int",{},NIL,.T.,"N",NIL,"xs") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	aEval(oNodes1 , { |x| aadd(::nitem ,  val(x:TEXT)  ) } )
Return

// WSDL Data Structure availableUsersDto

WSSTRUCT ECMWorkflowEngineServiceService_availableUsersDto
	WSDATA   lisCollectiveTask         AS boolean OPTIONAL
	WSDATA   oWSusers                  AS ECMWorkflowEngineServiceService_colleagueDto OPTIONAL
	WSDATA   lwillShowUsers            AS boolean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_availableUsersDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_availableUsersDto
	::oWSusers             := {} // Array Of  ECMWorkflowEngineServiceService_COLLEAGUEDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_availableUsersDto
	Local oClone := ECMWorkflowEngineServiceService_availableUsersDto():NEW()
	oClone:lisCollectiveTask    := ::lisCollectiveTask
	oClone:oWSusers := NIL
	If ::oWSusers <> NIL 
		oClone:oWSusers := {}
		aEval( ::oWSusers , { |x| aadd( oClone:oWSusers , x:Clone() ) } )
	Endif 
	oClone:lwillShowUsers       := ::lwillShowUsers
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_availableUsersDto
	Local nRElem2 , nTElem2
	Local aNodes2 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lisCollectiveTask  :=  WSAdvValue( oResponse,"_ISCOLLECTIVETASK","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	nTElem2 := len(aNodes2)
	For nRElem2 := 1 to nTElem2 
		If !WSIsNilNode( aNodes2[nRElem2] )
			aadd(::oWSusers , ECMWorkflowEngineServiceService_colleagueDto():New() )
  			::oWSusers[len(::oWSusers)]:SoapRecv(aNodes2[nRElem2])
		Endif
	Next
	::lwillShowUsers     :=  WSAdvValue( oResponse,"_WILLSHOWUSERS","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
Return

// WSDL Data Structure colleagueDto

WSSTRUCT ECMWorkflowEngineServiceService_colleagueDto
	WSDATA   lactive                   AS boolean OPTIONAL
	WSDATA   ladminUser                AS boolean OPTIONAL
	WSDATA   narea1Id                  AS int OPTIONAL
	WSDATA   narea2Id                  AS int OPTIONAL
	WSDATA   narea3Id                  AS int OPTIONAL
	WSDATA   narea4Id                  AS int OPTIONAL
	WSDATA   narea5Id                  AS int OPTIONAL
	WSDATA   ccolleagueId              AS string OPTIONAL
	WSDATA   ccolleagueName            AS string OPTIONAL
	WSDATA   ccolleaguebackground      AS string OPTIONAL
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   ccurrentProject           AS string OPTIONAL
	WSDATA   cdefaultLanguage          AS string OPTIONAL
	WSDATA   cdialectId                AS string OPTIONAL
	WSDATA   cecmVersion               AS string OPTIONAL
	WSDATA   lemailHtml                AS boolean OPTIONAL
	WSDATA   cespecializationArea      AS string OPTIONAL
	WSDATA   cextensionNr              AS string OPTIONAL
	WSDATA   lgedUser                  AS boolean OPTIONAL
	WSDATA   cgroupId                  AS string OPTIONAL
	WSDATA   lguestUser                AS boolean OPTIONAL
	WSDATA   chomePage                 AS string OPTIONAL
	WSDATA   clogin                    AS string OPTIONAL
	WSDATA   cmail                     AS string OPTIONAL
	WSDATA   nmaxPrivateSize           AS float OPTIONAL
	WSDATA   nmenuConfig               AS int OPTIONAL
	WSDATA   lnominalUser              AS boolean OPTIONAL
	WSDATA   cpasswd                   AS string OPTIONAL
	WSDATA   cphotoPath                AS string OPTIONAL
	WSDATA   nrowId                    AS int OPTIONAL
	WSDATA   csessionId                AS string OPTIONAL
	WSDATA   nusedSpace                AS float OPTIONAL
	WSDATA   cvolumeId                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_colleagueDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_colleagueDto
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_colleagueDto
	Local oClone := ECMWorkflowEngineServiceService_colleagueDto():NEW()
	oClone:lactive              := ::lactive
	oClone:ladminUser           := ::ladminUser
	oClone:narea1Id             := ::narea1Id
	oClone:narea2Id             := ::narea2Id
	oClone:narea3Id             := ::narea3Id
	oClone:narea4Id             := ::narea4Id
	oClone:narea5Id             := ::narea5Id
	oClone:ccolleagueId         := ::ccolleagueId
	oClone:ccolleagueName       := ::ccolleagueName
	oClone:ccolleaguebackground := ::ccolleaguebackground
	oClone:ncompanyId           := ::ncompanyId
	oClone:ccurrentProject      := ::ccurrentProject
	oClone:cdefaultLanguage     := ::cdefaultLanguage
	oClone:cdialectId           := ::cdialectId
	oClone:cecmVersion          := ::cecmVersion
	oClone:lemailHtml           := ::lemailHtml
	oClone:cespecializationArea := ::cespecializationArea
	oClone:cextensionNr         := ::cextensionNr
	oClone:lgedUser             := ::lgedUser
	oClone:cgroupId             := ::cgroupId
	oClone:lguestUser           := ::lguestUser
	oClone:chomePage            := ::chomePage
	oClone:clogin               := ::clogin
	oClone:cmail                := ::cmail
	oClone:nmaxPrivateSize      := ::nmaxPrivateSize
	oClone:nmenuConfig          := ::nmenuConfig
	oClone:lnominalUser         := ::lnominalUser
	oClone:cpasswd              := ::cpasswd
	oClone:cphotoPath           := ::cphotoPath
	oClone:nrowId               := ::nrowId
	oClone:csessionId           := ::csessionId
	oClone:nusedSpace           := ::nusedSpace
	oClone:cvolumeId            := ::cvolumeId
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_colleagueDto
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lactive            :=  WSAdvValue( oResponse,"_ACTIVE","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::ladminUser         :=  WSAdvValue( oResponse,"_ADMINUSER","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::narea1Id           :=  WSAdvValue( oResponse,"_AREA1ID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::narea2Id           :=  WSAdvValue( oResponse,"_AREA2ID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::narea3Id           :=  WSAdvValue( oResponse,"_AREA3ID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::narea4Id           :=  WSAdvValue( oResponse,"_AREA4ID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::narea5Id           :=  WSAdvValue( oResponse,"_AREA5ID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ccolleagueId       :=  WSAdvValue( oResponse,"_COLLEAGUEID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ccolleagueName     :=  WSAdvValue( oResponse,"_COLLEAGUENAME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ccolleaguebackground :=  WSAdvValue( oResponse,"_COLLEAGUEBACKGROUND","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::ccurrentProject    :=  WSAdvValue( oResponse,"_CURRENTPROJECT","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdefaultLanguage   :=  WSAdvValue( oResponse,"_DEFAULTLANGUAGE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdialectId         :=  WSAdvValue( oResponse,"_DIALECTID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cecmVersion        :=  WSAdvValue( oResponse,"_ECMVERSION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::lemailHtml         :=  WSAdvValue( oResponse,"_EMAILHTML","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cespecializationArea :=  WSAdvValue( oResponse,"_ESPECIALIZATIONAREA","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cextensionNr       :=  WSAdvValue( oResponse,"_EXTENSIONNR","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::lgedUser           :=  WSAdvValue( oResponse,"_GEDUSER","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cgroupId           :=  WSAdvValue( oResponse,"_GROUPID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::lguestUser         :=  WSAdvValue( oResponse,"_GUESTUSER","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::chomePage          :=  WSAdvValue( oResponse,"_HOMEPAGE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::clogin             :=  WSAdvValue( oResponse,"_LOGIN","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cmail              :=  WSAdvValue( oResponse,"_MAIL","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nmaxPrivateSize    :=  WSAdvValue( oResponse,"_MAXPRIVATESIZE","float",NIL,NIL,NIL,"N",NIL,"xs") 
	::nmenuConfig        :=  WSAdvValue( oResponse,"_MENUCONFIG","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::lnominalUser       :=  WSAdvValue( oResponse,"_NOMINALUSER","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cpasswd            :=  WSAdvValue( oResponse,"_PASSWD","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cphotoPath         :=  WSAdvValue( oResponse,"_PHOTOPATH","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nrowId             :=  WSAdvValue( oResponse,"_ROWID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::csessionId         :=  WSAdvValue( oResponse,"_SESSIONID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nusedSpace         :=  WSAdvValue( oResponse,"_USEDSPACE","float",NIL,NIL,NIL,"N",NIL,"xs") 
	::cvolumeId          :=  WSAdvValue( oResponse,"_VOLUMEID","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure documentDtoArray

WSSTRUCT ECMWorkflowEngineServiceService_documentDtoArray
	WSDATA   oWSitem                   AS ECMWorkflowEngineServiceService_documentDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_documentDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_documentDtoArray
	::oWSitem              := {} // Array Of  ECMWorkflowEngineServiceService_DOCUMENTDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_documentDtoArray
	Local oClone := ECMWorkflowEngineServiceService_documentDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMWorkflowEngineServiceService_documentDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "documentDto", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure processHistoryDtoArray

WSSTRUCT ECMWorkflowEngineServiceService_processHistoryDtoArray
	WSDATA   oWSitem                   AS ECMWorkflowEngineServiceService_processHistoryDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_processHistoryDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_processHistoryDtoArray
	::oWSitem              := {} // Array Of  ECMWorkflowEngineServiceService_PROCESSHISTORYDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_processHistoryDtoArray
	Local oClone := ECMWorkflowEngineServiceService_processHistoryDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_processHistoryDtoArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , ECMWorkflowEngineServiceService_processHistoryDto():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure processDefinitionDto

WSSTRUCT ECMWorkflowEngineServiceService_processDefinitionDto
	WSDATA   lactive                   AS boolean OPTIONAL
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   cprocessDescription       AS string OPTIONAL
	WSDATA   cprocessId                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_processDefinitionDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_processDefinitionDto
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_processDefinitionDto
	Local oClone := ECMWorkflowEngineServiceService_processDefinitionDto():NEW()
	oClone:lactive              := ::lactive
	oClone:ncompanyId           := ::ncompanyId
	oClone:cprocessDescription  := ::cprocessDescription
	oClone:cprocessId           := ::cprocessId
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_processDefinitionDto
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lactive            :=  WSAdvValue( oResponse,"_ACTIVE","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::cprocessDescription :=  WSAdvValue( oResponse,"_PROCESSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cprocessId         :=  WSAdvValue( oResponse,"_PROCESSID","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure processAttachmentDto

WSSTRUCT ECMWorkflowEngineServiceService_processAttachmentDto
	WSDATA   nattachmentSequence       AS int OPTIONAL
	WSDATA   oWSattachments            AS ECMWorkflowEngineServiceService_attachment OPTIONAL
	WSDATA   ccolleagueId              AS string OPTIONAL
	WSDATA   ccolleagueName            AS string OPTIONAL
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   ncrc                      AS long OPTIONAL
	WSDATA   ccreateDate               AS dateTime OPTIONAL
	WSDATA   ncreateDateTimestamp      AS long OPTIONAL
	WSDATA   ldeleted                  AS boolean OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSDATA   ndocumentId               AS int OPTIONAL
	WSDATA   cdocumentType             AS string OPTIONAL
	WSDATA   cfileName                 AS string OPTIONAL
	WSDATA   lnewAttach                AS boolean OPTIONAL
	WSDATA   noriginalMovementSequence AS int OPTIONAL
	WSDATA   cpermission               AS string OPTIONAL
	WSDATA   nprocessInstanceId        AS int OPTIONAL
	WSDATA   nsize                     AS float OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_processAttachmentDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_processAttachmentDto
	::oWSattachments       := {} // Array Of  ECMWorkflowEngineServiceService_ATTACHMENT():New()
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_processAttachmentDto
	Local oClone := ECMWorkflowEngineServiceService_processAttachmentDto():NEW()
	oClone:nattachmentSequence  := ::nattachmentSequence
	oClone:oWSattachments := NIL
	If ::oWSattachments <> NIL 
		oClone:oWSattachments := {}
		aEval( ::oWSattachments , { |x| aadd( oClone:oWSattachments , x:Clone() ) } )
	Endif 
	oClone:ccolleagueId         := ::ccolleagueId
	oClone:ccolleagueName       := ::ccolleagueName
	oClone:ncompanyId           := ::ncompanyId
	oClone:ncrc                 := ::ncrc
	oClone:ccreateDate          := ::ccreateDate
	oClone:ncreateDateTimestamp := ::ncreateDateTimestamp
	oClone:ldeleted             := ::ldeleted
	oClone:cdescription         := ::cdescription
	oClone:ndocumentId          := ::ndocumentId
	oClone:cdocumentType        := ::cdocumentType
	oClone:cfileName            := ::cfileName
	oClone:lnewAttach           := ::lnewAttach
	oClone:noriginalMovementSequence := ::noriginalMovementSequence
	oClone:cpermission          := ::cpermission
	oClone:nprocessInstanceId   := ::nprocessInstanceId
	oClone:nsize                := ::nsize
	oClone:nversion             := ::nversion
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMWorkflowEngineServiceService_processAttachmentDto
	Local cSoap := ""
	cSoap += WSSoapValue("attachmentSequence", ::nattachmentSequence, ::nattachmentSequence , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	aEval( ::oWSattachments , {|x| cSoap := cSoap  +  WSSoapValue("attachments", x , x , "attachment", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
	cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ::ccolleagueId , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("colleagueName", ::ccolleagueName, ::ccolleagueName , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("companyId", ::ncompanyId, ::ncompanyId , "long", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("crc", ::ncrc, ::ncrc , "long", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("createDate", ::ccreateDate, ::ccreateDate , "dateTime", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("createDateTimestamp", ::ncreateDateTimestamp, ::ncreateDateTimestamp , "long", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("deleted", ::ldeleted, ::ldeleted , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("description", ::cdescription, ::cdescription , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("documentId", ::ndocumentId, ::ndocumentId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("documentType", ::cdocumentType, ::cdocumentType , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("fileName", ::cfileName, ::cfileName , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("newAttach", ::lnewAttach, ::lnewAttach , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("originalMovementSequence", ::noriginalMovementSequence, ::noriginalMovementSequence , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("permission", ::cpermission, ::cpermission , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, ::nprocessInstanceId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("size", ::nsize, ::nsize , "float", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("version", ::nversion, ::nversion , "int", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_processAttachmentDto
	Local nRElem2 , nTElem2
	Local aNodes2 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nattachmentSequence :=  WSAdvValue( oResponse,"_ATTACHMENTSEQUENCE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	nTElem2 := len(aNodes2)
	For nRElem2 := 1 to nTElem2 
		If !WSIsNilNode( aNodes2[nRElem2] )
			aadd(::oWSattachments , ECMWorkflowEngineServiceService_attachment():New() )
  			::oWSattachments[len(::oWSattachments)]:SoapRecv(aNodes2[nRElem2])
		Endif
	Next
	::ccolleagueId       :=  WSAdvValue( oResponse,"_COLLEAGUEID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ccolleagueName     :=  WSAdvValue( oResponse,"_COLLEAGUENAME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::ncrc               :=  WSAdvValue( oResponse,"_CRC","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::ccreateDate        :=  WSAdvValue( oResponse,"_CREATEDATE","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::ncreateDateTimestamp :=  WSAdvValue( oResponse,"_CREATEDATETIMESTAMP","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::ldeleted           :=  WSAdvValue( oResponse,"_DELETED","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ndocumentId        :=  WSAdvValue( oResponse,"_DOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cdocumentType      :=  WSAdvValue( oResponse,"_DOCUMENTTYPE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cfileName          :=  WSAdvValue( oResponse,"_FILENAME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::lnewAttach         :=  WSAdvValue( oResponse,"_NEWATTACH","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::noriginalMovementSequence :=  WSAdvValue( oResponse,"_ORIGINALMOVEMENTSEQUENCE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cpermission        :=  WSAdvValue( oResponse,"_PERMISSION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nprocessInstanceId :=  WSAdvValue( oResponse,"_PROCESSINSTANCEID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nsize              :=  WSAdvValue( oResponse,"_SIZE","float",NIL,NIL,NIL,"N",NIL,"xs") 
	::nversion           :=  WSAdvValue( oResponse,"_VERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
Return

// WSDL Data Structure processTaskAppointmentDto

WSSTRUCT ECMWorkflowEngineServiceService_processTaskAppointmentDto
	WSDATA   cappointmentDate          AS dateTime OPTIONAL
	WSDATA   nappointmentSeconds       AS int OPTIONAL
	WSDATA   nappointmentSequence      AS int OPTIONAL
	WSDATA   ccolleagueId              AS string OPTIONAL
	WSDATA   ccolleagueName            AS string OPTIONAL
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   lisNewRecord              AS boolean OPTIONAL
	WSDATA   nmovementSequence         AS int OPTIONAL
	WSDATA   nprocessInstanceId        AS int OPTIONAL
	WSDATA   ntransferenceSequence     AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_processTaskAppointmentDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_processTaskAppointmentDto
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_processTaskAppointmentDto
	Local oClone := ECMWorkflowEngineServiceService_processTaskAppointmentDto():NEW()
	oClone:cappointmentDate     := ::cappointmentDate
	oClone:nappointmentSeconds  := ::nappointmentSeconds
	oClone:nappointmentSequence := ::nappointmentSequence
	oClone:ccolleagueId         := ::ccolleagueId
	oClone:ccolleagueName       := ::ccolleagueName
	oClone:ncompanyId           := ::ncompanyId
	oClone:lisNewRecord         := ::lisNewRecord
	oClone:nmovementSequence    := ::nmovementSequence
	oClone:nprocessInstanceId   := ::nprocessInstanceId
	oClone:ntransferenceSequence := ::ntransferenceSequence
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMWorkflowEngineServiceService_processTaskAppointmentDto
	Local cSoap := ""
	cSoap += WSSoapValue("appointmentDate", ::cappointmentDate, ::cappointmentDate , "dateTime", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("appointmentSeconds", ::nappointmentSeconds, ::nappointmentSeconds , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("appointmentSequence", ::nappointmentSequence, ::nappointmentSequence , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ::ccolleagueId , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("colleagueName", ::ccolleagueName, ::ccolleagueName , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("companyId", ::ncompanyId, ::ncompanyId , "long", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("isNewRecord", ::lisNewRecord, ::lisNewRecord , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("movementSequence", ::nmovementSequence, ::nmovementSequence , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("processInstanceId", ::nprocessInstanceId, ::nprocessInstanceId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("transferenceSequence", ::ntransferenceSequence, ::ntransferenceSequence , "int", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure keyValueDto

WSSTRUCT ECMWorkflowEngineServiceService_keyValueDto
	WSDATA   ckey                      AS string OPTIONAL
	WSDATA   cvalue                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_keyValueDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_keyValueDto
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_keyValueDto
	Local oClone := ECMWorkflowEngineServiceService_keyValueDto():NEW()
	oClone:ckey                 := ::ckey
	oClone:cvalue               := ::cvalue
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMWorkflowEngineServiceService_keyValueDto
	Local cSoap := ""
	cSoap += WSSoapValue("key", ::ckey, ::ckey , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("value", ::cvalue, ::cvalue , "string", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_keyValueDto
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ckey               :=  WSAdvValue( oResponse,"_KEY","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cvalue             :=  WSAdvValue( oResponse,"_VALUE","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure cardEventDto

WSSTRUCT ECMWorkflowEngineServiceService_cardEventDto
	WSDATA   ceventDescription         AS string OPTIONAL
	WSDATA   ceventId                  AS string OPTIONAL
	WSDATA   leventVersAnt             AS boolean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_cardEventDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_cardEventDto
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_cardEventDto
	Local oClone := ECMWorkflowEngineServiceService_cardEventDto():NEW()
	oClone:ceventDescription    := ::ceventDescription
	oClone:ceventId             := ::ceventId
	oClone:leventVersAnt        := ::leventVersAnt
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMWorkflowEngineServiceService_cardEventDto
	Local cSoap := ""
	cSoap += WSSoapValue("eventDescription", ::ceventDescription, ::ceventDescription , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("eventId", ::ceventId, ::ceventId , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("eventVersAnt", ::leventVersAnt, ::leventVersAnt , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure processDefinitionVersionDto

WSSTRUCT ECMWorkflowEngineServiceService_processDefinitionVersionDto
	WSDATA   ccategoryStructure        AS string OPTIONAL
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   lcounterSign              AS boolean OPTIONAL
	WSDATA   lfavorite                 AS boolean OPTIONAL
	WSDATA   nformId                   AS int OPTIONAL
	WSDATA   nformVersion              AS int OPTIONAL
	WSDATA   cfullCategoryStructure    AS string OPTIONAL
	WSDATA   oWSinitialProcessState    AS ECMWorkflowEngineServiceService_processStateDto OPTIONAL
	WSDATA   lmobileReady              AS boolean OPTIONAL
	WSDATA   cprocessDescription       AS string OPTIONAL
	WSDATA   cprocessId                AS string OPTIONAL
	WSDATA   crelatedDatasets          AS string OPTIONAL
	WSDATA   nrowId                    AS int OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSDATA   cversionDescription       AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_processDefinitionVersionDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_processDefinitionVersionDto
	::crelatedDatasets     := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_processDefinitionVersionDto
	Local oClone := ECMWorkflowEngineServiceService_processDefinitionVersionDto():NEW()
	oClone:ccategoryStructure   := ::ccategoryStructure
	oClone:ncompanyId           := ::ncompanyId
	oClone:lcounterSign         := ::lcounterSign
	oClone:lfavorite            := ::lfavorite
	oClone:nformId              := ::nformId
	oClone:nformVersion         := ::nformVersion
	oClone:cfullCategoryStructure := ::cfullCategoryStructure
	oClone:oWSinitialProcessState := IIF(::oWSinitialProcessState = NIL , NIL , ::oWSinitialProcessState:Clone() )
	oClone:lmobileReady         := ::lmobileReady
	oClone:cprocessDescription  := ::cprocessDescription
	oClone:cprocessId           := ::cprocessId
	oClone:crelatedDatasets     := IIf(::crelatedDatasets <> NIL , aClone(::crelatedDatasets) , NIL )
	oClone:nrowId               := ::nrowId
	oClone:nversion             := ::nversion
	oClone:cversionDescription  := ::cversionDescription
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_processDefinitionVersionDto
	Local oNode8
	Local oNodes12 :=  WSAdvValue( oResponse,"_RELATEDDATASETS","string",{},NIL,.T.,"S",NIL,"xs") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ccategoryStructure :=  WSAdvValue( oResponse,"_CATEGORYSTRUCTURE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::lcounterSign       :=  WSAdvValue( oResponse,"_COUNTERSIGN","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::lfavorite          :=  WSAdvValue( oResponse,"_FAVORITE","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::nformId            :=  WSAdvValue( oResponse,"_FORMID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nformVersion       :=  WSAdvValue( oResponse,"_FORMVERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cfullCategoryStructure :=  WSAdvValue( oResponse,"_FULLCATEGORYSTRUCTURE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNode8 :=  WSAdvValue( oResponse,"_INITIALPROCESSSTATE","processStateDto",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode8 != NIL
		::oWSinitialProcessState := ECMWorkflowEngineServiceService_processStateDto():New()
		::oWSinitialProcessState:SoapRecv(oNode8)
	EndIf
	::lmobileReady       :=  WSAdvValue( oResponse,"_MOBILEREADY","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cprocessDescription :=  WSAdvValue( oResponse,"_PROCESSDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cprocessId         :=  WSAdvValue( oResponse,"_PROCESSID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	aEval(oNodes12 , { |x| aadd(::crelatedDatasets ,  x:TEXT  ) } )
	::nrowId             :=  WSAdvValue( oResponse,"_ROWID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nversion           :=  WSAdvValue( oResponse,"_VERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cversionDescription :=  WSAdvValue( oResponse,"_VERSIONDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure processStateDto

WSSTRUCT ECMWorkflowEngineServiceService_processStateDto
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   lcounterSign              AS boolean OPTIONAL
	WSDATA   nsequence                 AS int OPTIONAL
	WSDATA   cstateDescription         AS string OPTIONAL
	WSDATA   cstateName                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_processStateDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_processStateDto
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_processStateDto
	Local oClone := ECMWorkflowEngineServiceService_processStateDto():NEW()
	oClone:ncompanyId           := ::ncompanyId
	oClone:lcounterSign         := ::lcounterSign
	oClone:nsequence            := ::nsequence
	oClone:cstateDescription    := ::cstateDescription
	oClone:cstateName           := ::cstateName
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_processStateDto
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::lcounterSign       :=  WSAdvValue( oResponse,"_COUNTERSIGN","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::nsequence          :=  WSAdvValue( oResponse,"_SEQUENCE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cstateDescription  :=  WSAdvValue( oResponse,"_STATEDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cstateName         :=  WSAdvValue( oResponse,"_STATENAME","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure documentDto

WSSTRUCT ECMWorkflowEngineServiceService_documentDto
	WSDATA   naccessCount              AS int OPTIONAL
	WSDATA   lactiveUserApprover       AS boolean OPTIONAL
	WSDATA   lactiveVersion            AS boolean OPTIONAL
	WSDATA   cadditionalComments       AS string OPTIONAL
	WSDATA   lallowMuiltiCardsPerUser  AS boolean OPTIONAL
	WSDATA   lapprovalAndOr            AS boolean OPTIONAL
	WSDATA   lapproved                 AS boolean OPTIONAL
	WSDATA   capprovedDate             AS dateTime OPTIONAL
	WSDATA   carticleContent           AS string OPTIONAL
	WSDATA   oWSattachments            AS ECMWorkflowEngineServiceService_attachment OPTIONAL
	WSDATA   natualizationId           AS int OPTIONAL
	WSDATA   cbackgroundColor          AS string OPTIONAL
	WSDATA   cbackgroundImage          AS string OPTIONAL
	WSDATA   cbannerImage              AS string OPTIONAL
	WSDATA   ccardDescription          AS string OPTIONAL
	WSDATA   ccolleagueId              AS string OPTIONAL
	WSDATA   ccolleagueName            AS string OPTIONAL
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   ncrc                      AS long OPTIONAL
	WSDATA   ccreateDate               AS dateTime OPTIONAL
	WSDATA   ncreateDateInMilliseconds AS long OPTIONAL
	WSDATA   cdatasetName              AS string OPTIONAL
	WSDATA   ldateFormStarted          AS boolean OPTIONAL
	WSDATA   ldeleted                  AS boolean OPTIONAL
	WSDATA   cdocumentDescription      AS string OPTIONAL
	WSDATA   ndocumentId               AS int OPTIONAL
	WSDATA   cdocumentKeyWord          AS string OPTIONAL
	WSDATA   ndocumentPropertyNumber   AS int OPTIONAL
	WSDATA   ndocumentPropertyVersion  AS int OPTIONAL
	WSDATA   cdocumentType             AS string OPTIONAL
	WSDATA   cdocumentTypeId           AS string OPTIONAL
	WSDATA   ldownloadEnabled          AS boolean OPTIONAL
	WSDATA   ldraft                    AS boolean OPTIONAL
	WSDATA   cexpirationDate           AS dateTime OPTIONAL
	WSDATA   lexpiredForm              AS boolean OPTIONAL
	WSDATA   lexpires                  AS boolean OPTIONAL
	WSDATA   cexternalDocumentId       AS string OPTIONAL
	WSDATA   lfavorite                 AS boolean OPTIONAL
	WSDATA   cfileURL                  AS string OPTIONAL
	WSDATA   nfolderId                 AS int OPTIONAL
	WSDATA   lforAproval               AS boolean OPTIONAL
	WSDATA   niconId                   AS int OPTIONAL
	WSDATA   ciconPath                 AS string OPTIONAL
	WSDATA   limutable                 AS boolean OPTIONAL
	WSDATA   lindexed                  AS boolean OPTIONAL
	WSDATA   linheritSecurity          AS boolean OPTIONAL
	WSDATA   linternalVisualizer       AS boolean OPTIONAL
	WSDATA   lisEncrypted              AS boolean OPTIONAL
	WSDATA   ckeyWord                  AS string OPTIONAL
	WSDATA   clanguageId               AS string OPTIONAL
	WSDATA   clanguageIndicator        AS string OPTIONAL
	WSDATA   clastModifiedDate         AS dateTime OPTIONAL
	WSDATA   clastModifiedTime         AS string OPTIONAL
	WSDATA   nmetaListId               AS int OPTIONAL
	WSDATA   nmetaListRecordId         AS int OPTIONAL
	WSDATA   lnewStructure             AS boolean OPTIONAL
	WSDATA   lonCheckout               AS boolean OPTIONAL
	WSDATA   nparentDocumentId         AS int OPTIONAL
	WSDATA   cpdfRenderEngine          AS string OPTIONAL
	WSDATA   npermissionType           AS int OPTIONAL
	WSDATA   cphisicalFile             AS string OPTIONAL
	WSDATA   nphisicalFileSize         AS float OPTIONAL
	WSDATA   npriority                 AS int OPTIONAL
	WSDATA   cprivateColleagueId       AS string OPTIONAL
	WSDATA   lprivateDocument          AS boolean OPTIONAL
	WSDATA   lprotectedCopy            AS boolean OPTIONAL
	WSDATA   cpublisherId              AS string OPTIONAL
	WSDATA   cpublisherName            AS string OPTIONAL
	WSDATA   crelatedFiles             AS string OPTIONAL
	WSDATA   nrestrictionType          AS int OPTIONAL
	WSDATA   nrowId                    AS int OPTIONAL
	WSDATA   nsearchNumber             AS int OPTIONAL
	WSDATA   nsecurityLevel            AS int OPTIONAL
	WSDATA   csiteCode                 AS string OPTIONAL
	WSDATA   oWSsociableDocumentDto    AS ECMWorkflowEngineServiceService_sociableDocumentDto OPTIONAL
	WSDATA   csocialDocument           AS string OPTIONAL
	WSDATA   ltool                     AS boolean OPTIONAL
	WSDATA   ntopicId                  AS int OPTIONAL
	WSDATA   ltranslated               AS boolean OPTIONAL
	WSDATA   cUUID                     AS string OPTIONAL
	WSDATA   lupdateIsoProperties      AS boolean OPTIONAL
	WSDATA   luserAnswerForm           AS boolean OPTIONAL
	WSDATA   luserNotify               AS boolean OPTIONAL
	WSDATA   nuserPermission           AS int OPTIONAL
	WSDATA   cvalidationStartDate      AS dateTime OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSDATA   cversionDescription       AS string OPTIONAL
	WSDATA   cversionOption            AS string OPTIONAL
	WSDATA   cvisualization            AS string OPTIONAL
	WSDATA   cvolumeId                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_documentDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_documentDto
	::oWSattachments       := {} // Array Of  ECMWorkflowEngineServiceService_ATTACHMENT():New()
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_documentDto
	Local oClone := ECMWorkflowEngineServiceService_documentDto():NEW()
	oClone:naccessCount         := ::naccessCount
	oClone:lactiveUserApprover  := ::lactiveUserApprover
	oClone:lactiveVersion       := ::lactiveVersion
	oClone:cadditionalComments  := ::cadditionalComments
	oClone:lallowMuiltiCardsPerUser := ::lallowMuiltiCardsPerUser
	oClone:lapprovalAndOr       := ::lapprovalAndOr
	oClone:lapproved            := ::lapproved
	oClone:capprovedDate        := ::capprovedDate
	oClone:carticleContent      := ::carticleContent
	oClone:oWSattachments := NIL
	If ::oWSattachments <> NIL 
		oClone:oWSattachments := {}
		aEval( ::oWSattachments , { |x| aadd( oClone:oWSattachments , x:Clone() ) } )
	Endif 
	oClone:natualizationId      := ::natualizationId
	oClone:cbackgroundColor     := ::cbackgroundColor
	oClone:cbackgroundImage     := ::cbackgroundImage
	oClone:cbannerImage         := ::cbannerImage
	oClone:ccardDescription     := ::ccardDescription
	oClone:ccolleagueId         := ::ccolleagueId
	oClone:ccolleagueName       := ::ccolleagueName
	oClone:ncompanyId           := ::ncompanyId
	oClone:ncrc                 := ::ncrc
	oClone:ccreateDate          := ::ccreateDate
	oClone:ncreateDateInMilliseconds := ::ncreateDateInMilliseconds
	oClone:cdatasetName         := ::cdatasetName
	oClone:ldateFormStarted     := ::ldateFormStarted
	oClone:ldeleted             := ::ldeleted
	oClone:cdocumentDescription := ::cdocumentDescription
	oClone:ndocumentId          := ::ndocumentId
	oClone:cdocumentKeyWord     := ::cdocumentKeyWord
	oClone:ndocumentPropertyNumber := ::ndocumentPropertyNumber
	oClone:ndocumentPropertyVersion := ::ndocumentPropertyVersion
	oClone:cdocumentType        := ::cdocumentType
	oClone:cdocumentTypeId      := ::cdocumentTypeId
	oClone:ldownloadEnabled     := ::ldownloadEnabled
	oClone:ldraft               := ::ldraft
	oClone:cexpirationDate      := ::cexpirationDate
	oClone:lexpiredForm         := ::lexpiredForm
	oClone:lexpires             := ::lexpires
	oClone:cexternalDocumentId  := ::cexternalDocumentId
	oClone:lfavorite            := ::lfavorite
	oClone:cfileURL             := ::cfileURL
	oClone:nfolderId            := ::nfolderId
	oClone:lforAproval          := ::lforAproval
	oClone:niconId              := ::niconId
	oClone:ciconPath            := ::ciconPath
	oClone:limutable            := ::limutable
	oClone:lindexed             := ::lindexed
	oClone:linheritSecurity     := ::linheritSecurity
	oClone:linternalVisualizer  := ::linternalVisualizer
	oClone:lisEncrypted         := ::lisEncrypted
	oClone:ckeyWord             := ::ckeyWord
	oClone:clanguageId          := ::clanguageId
	oClone:clanguageIndicator   := ::clanguageIndicator
	oClone:clastModifiedDate    := ::clastModifiedDate
	oClone:clastModifiedTime    := ::clastModifiedTime
	oClone:nmetaListId          := ::nmetaListId
	oClone:nmetaListRecordId    := ::nmetaListRecordId
	oClone:lnewStructure        := ::lnewStructure
	oClone:lonCheckout          := ::lonCheckout
	oClone:nparentDocumentId    := ::nparentDocumentId
	oClone:cpdfRenderEngine     := ::cpdfRenderEngine
	oClone:npermissionType      := ::npermissionType
	oClone:cphisicalFile        := ::cphisicalFile
	oClone:nphisicalFileSize    := ::nphisicalFileSize
	oClone:npriority            := ::npriority
	oClone:cprivateColleagueId  := ::cprivateColleagueId
	oClone:lprivateDocument     := ::lprivateDocument
	oClone:lprotectedCopy       := ::lprotectedCopy
	oClone:cpublisherId         := ::cpublisherId
	oClone:cpublisherName       := ::cpublisherName
	oClone:crelatedFiles        := ::crelatedFiles
	oClone:nrestrictionType     := ::nrestrictionType
	oClone:nrowId               := ::nrowId
	oClone:nsearchNumber        := ::nsearchNumber
	oClone:nsecurityLevel       := ::nsecurityLevel
	oClone:csiteCode            := ::csiteCode
	oClone:oWSsociableDocumentDto := IIF(::oWSsociableDocumentDto = NIL , NIL , ::oWSsociableDocumentDto:Clone() )
	oClone:csocialDocument      := ::csocialDocument
	oClone:ltool                := ::ltool
	oClone:ntopicId             := ::ntopicId
	oClone:ltranslated          := ::ltranslated
	oClone:cUUID                := ::cUUID
	oClone:lupdateIsoProperties := ::lupdateIsoProperties
	oClone:luserAnswerForm      := ::luserAnswerForm
	oClone:luserNotify          := ::luserNotify
	oClone:nuserPermission      := ::nuserPermission
	oClone:cvalidationStartDate := ::cvalidationStartDate
	oClone:nversion             := ::nversion
	oClone:cversionDescription  := ::cversionDescription
	oClone:cversionOption       := ::cversionOption
	oClone:cvisualization       := ::cvisualization
	oClone:cvolumeId            := ::cvolumeId
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMWorkflowEngineServiceService_documentDto
	Local cSoap := ""
	cSoap += WSSoapValue("accessCount", ::naccessCount, ::naccessCount , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("activeUserApprover", ::lactiveUserApprover, ::lactiveUserApprover , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("activeVersion", ::lactiveVersion, ::lactiveVersion , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("additionalComments", ::cadditionalComments, ::cadditionalComments , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("allowMuiltiCardsPerUser", ::lallowMuiltiCardsPerUser, ::lallowMuiltiCardsPerUser , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("approvalAndOr", ::lapprovalAndOr, ::lapprovalAndOr , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("approved", ::lapproved, ::lapproved , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("approvedDate", ::capprovedDate, ::capprovedDate , "dateTime", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("articleContent", ::carticleContent, ::carticleContent , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	aEval( ::oWSattachments , {|x| cSoap := cSoap  +  WSSoapValue("attachments", x , x , "attachment", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
	cSoap += WSSoapValue("atualizationId", ::natualizationId, ::natualizationId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("backgroundColor", ::cbackgroundColor, ::cbackgroundColor , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("backgroundImage", ::cbackgroundImage, ::cbackgroundImage , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("bannerImage", ::cbannerImage, ::cbannerImage , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("cardDescription", ::ccardDescription, ::ccardDescription , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ::ccolleagueId , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("colleagueName", ::ccolleagueName, ::ccolleagueName , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("companyId", ::ncompanyId, ::ncompanyId , "long", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("crc", ::ncrc, ::ncrc , "long", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("createDate", ::ccreateDate, ::ccreateDate , "dateTime", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("createDateInMilliseconds", ::ncreateDateInMilliseconds, ::ncreateDateInMilliseconds , "long", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("datasetName", ::cdatasetName, ::cdatasetName , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("dateFormStarted", ::ldateFormStarted, ::ldateFormStarted , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("deleted", ::ldeleted, ::ldeleted , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("documentDescription", ::cdocumentDescription, ::cdocumentDescription , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("documentId", ::ndocumentId, ::ndocumentId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("documentKeyWord", ::cdocumentKeyWord, ::cdocumentKeyWord , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("documentPropertyNumber", ::ndocumentPropertyNumber, ::ndocumentPropertyNumber , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("documentPropertyVersion", ::ndocumentPropertyVersion, ::ndocumentPropertyVersion , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("documentType", ::cdocumentType, ::cdocumentType , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("documentTypeId", ::cdocumentTypeId, ::cdocumentTypeId , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("downloadEnabled", ::ldownloadEnabled, ::ldownloadEnabled , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("draft", ::ldraft, ::ldraft , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("expirationDate", ::cexpirationDate, ::cexpirationDate , "dateTime", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("expiredForm", ::lexpiredForm, ::lexpiredForm , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("expires", ::lexpires, ::lexpires , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("externalDocumentId", ::cexternalDocumentId, ::cexternalDocumentId , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("favorite", ::lfavorite, ::lfavorite , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("fileURL", ::cfileURL, ::cfileURL , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("folderId", ::nfolderId, ::nfolderId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("forAproval", ::lforAproval, ::lforAproval , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("iconId", ::niconId, ::niconId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("iconPath", ::ciconPath, ::ciconPath , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("imutable", ::limutable, ::limutable , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("indexed", ::lindexed, ::lindexed , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("inheritSecurity", ::linheritSecurity, ::linheritSecurity , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("internalVisualizer", ::linternalVisualizer, ::linternalVisualizer , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("isEncrypted", ::lisEncrypted, ::lisEncrypted , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("keyWord", ::ckeyWord, ::ckeyWord , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("languageId", ::clanguageId, ::clanguageId , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("languageIndicator", ::clanguageIndicator, ::clanguageIndicator , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("lastModifiedDate", ::clastModifiedDate, ::clastModifiedDate , "dateTime", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("lastModifiedTime", ::clastModifiedTime, ::clastModifiedTime , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("metaListId", ::nmetaListId, ::nmetaListId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("metaListRecordId", ::nmetaListRecordId, ::nmetaListRecordId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("newStructure", ::lnewStructure, ::lnewStructure , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("onCheckout", ::lonCheckout, ::lonCheckout , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("parentDocumentId", ::nparentDocumentId, ::nparentDocumentId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("pdfRenderEngine", ::cpdfRenderEngine, ::cpdfRenderEngine , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("permissionType", ::npermissionType, ::npermissionType , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("phisicalFile", ::cphisicalFile, ::cphisicalFile , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("phisicalFileSize", ::nphisicalFileSize, ::nphisicalFileSize , "float", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("priority", ::npriority, ::npriority , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("privateColleagueId", ::cprivateColleagueId, ::cprivateColleagueId , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("privateDocument", ::lprivateDocument, ::lprivateDocument , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("protectedCopy", ::lprotectedCopy, ::lprotectedCopy , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("publisherId", ::cpublisherId, ::cpublisherId , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("publisherName", ::cpublisherName, ::cpublisherName , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("relatedFiles", ::crelatedFiles, ::crelatedFiles , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("restrictionType", ::nrestrictionType, ::nrestrictionType , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("rowId", ::nrowId, ::nrowId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("searchNumber", ::nsearchNumber, ::nsearchNumber , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("securityLevel", ::nsecurityLevel, ::nsecurityLevel , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("siteCode", ::csiteCode, ::csiteCode , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("sociableDocumentDto", ::oWSsociableDocumentDto, ::oWSsociableDocumentDto , "sociableDocumentDto", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("socialDocument", ::csocialDocument, ::csocialDocument , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("tool", ::ltool, ::ltool , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("topicId", ::ntopicId, ::ntopicId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("translated", ::ltranslated, ::ltranslated , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("UUID", ::cUUID, ::cUUID , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("updateIsoProperties", ::lupdateIsoProperties, ::lupdateIsoProperties , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("userAnswerForm", ::luserAnswerForm, ::luserAnswerForm , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("userNotify", ::luserNotify, ::luserNotify , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("userPermission", ::nuserPermission, ::nuserPermission , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("validationStartDate", ::cvalidationStartDate, ::cvalidationStartDate , "dateTime", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("version", ::nversion, ::nversion , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("versionDescription", ::cversionDescription, ::cversionDescription , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("versionOption", ::cversionOption, ::cversionOption , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("visualization", ::cvisualization, ::cvisualization , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("volumeId", ::cvolumeId, ::cvolumeId , "string", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure processHistoryDto

WSSTRUCT ECMWorkflowEngineServiceService_processHistoryDto
	WSDATA   lactive                   AS boolean OPTIONAL
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   nconversionSequence       AS int OPTIONAL
	WSDATA   lisReturn                 AS boolean OPTIONAL
	WSDATA   clabelActivity            AS string OPTIONAL
	WSDATA   clabelLink                AS string OPTIONAL
	WSDATA   cmovementDate             AS dateTime OPTIONAL
	WSDATA   cmovementHour             AS string OPTIONAL
	WSDATA   nmovementSequence         AS int OPTIONAL
	WSDATA   npreviousMovementSequence AS int OPTIONAL
	WSDATA   nprocessInstanceId        AS int OPTIONAL
	WSDATA   nstateSequence            AS int OPTIONAL
	WSDATA   nsubProcessId             AS int OPTIONAL
	WSDATA   oWStasks                  AS ECMWorkflowEngineServiceService_processTaskDto OPTIONAL
	WSDATA   nthreadSequence           AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_processHistoryDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_processHistoryDto
	::oWStasks             := {} // Array Of  ECMWorkflowEngineServiceService_PROCESSTASKDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_processHistoryDto
	Local oClone := ECMWorkflowEngineServiceService_processHistoryDto():NEW()
	oClone:lactive              := ::lactive
	oClone:ncompanyId           := ::ncompanyId
	oClone:nconversionSequence  := ::nconversionSequence
	oClone:lisReturn            := ::lisReturn
	oClone:clabelActivity       := ::clabelActivity
	oClone:clabelLink           := ::clabelLink
	oClone:cmovementDate        := ::cmovementDate
	oClone:cmovementHour        := ::cmovementHour
	oClone:nmovementSequence    := ::nmovementSequence
	oClone:npreviousMovementSequence := ::npreviousMovementSequence
	oClone:nprocessInstanceId   := ::nprocessInstanceId
	oClone:nstateSequence       := ::nstateSequence
	oClone:nsubProcessId        := ::nsubProcessId
	oClone:oWStasks := NIL
	If ::oWStasks <> NIL 
		oClone:oWStasks := {}
		aEval( ::oWStasks , { |x| aadd( oClone:oWStasks , x:Clone() ) } )
	Endif 
	oClone:nthreadSequence      := ::nthreadSequence
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_processHistoryDto
	Local nRElem14 , nTElem14
	Local aNodes14 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lactive            :=  WSAdvValue( oResponse,"_ACTIVE","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::nconversionSequence :=  WSAdvValue( oResponse,"_CONVERSIONSEQUENCE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::lisReturn          :=  WSAdvValue( oResponse,"_ISRETURN","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::clabelActivity     :=  WSAdvValue( oResponse,"_LABELACTIVITY","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::clabelLink         :=  WSAdvValue( oResponse,"_LABELLINK","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cmovementDate      :=  WSAdvValue( oResponse,"_MOVEMENTDATE","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::cmovementHour      :=  WSAdvValue( oResponse,"_MOVEMENTHOUR","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nmovementSequence  :=  WSAdvValue( oResponse,"_MOVEMENTSEQUENCE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::npreviousMovementSequence :=  WSAdvValue( oResponse,"_PREVIOUSMOVEMENTSEQUENCE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nprocessInstanceId :=  WSAdvValue( oResponse,"_PROCESSINSTANCEID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nstateSequence     :=  WSAdvValue( oResponse,"_STATESEQUENCE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nsubProcessId      :=  WSAdvValue( oResponse,"_SUBPROCESSID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	nTElem14 := len(aNodes14)
	For nRElem14 := 1 to nTElem14 
		If !WSIsNilNode( aNodes14[nRElem14] )
			aadd(::oWStasks , ECMWorkflowEngineServiceService_processTaskDto():New() )
  			::oWStasks[len(::oWStasks)]:SoapRecv(aNodes14[nRElem14])
		Endif
	Next
	::nthreadSequence    :=  WSAdvValue( oResponse,"_THREADSEQUENCE","int",NIL,NIL,NIL,"N",NIL,"xs") 
Return

// WSDL Data Structure attachment

WSSTRUCT ECMWorkflowEngineServiceService_attachment
	WSDATA   lattach                   AS boolean OPTIONAL
	WSDATA   ldescriptor               AS boolean OPTIONAL
	WSDATA   lediting                  AS boolean OPTIONAL
	WSDATA   cfileName                 AS string OPTIONAL
	WSDATA   oWSfileSelected           AS ECMWorkflowEngineServiceService_attachment OPTIONAL
	WSDATA   nfileSize                 AS long OPTIONAL
	WSDATA   cfilecontent              AS base64Binary OPTIONAL
	WSDATA   cfullPatch                AS string OPTIONAL
	WSDATA   ciconPath                 AS string OPTIONAL
	WSDATA   lmobile                   AS boolean OPTIONAL
	WSDATA   cpathName                 AS string OPTIONAL
	WSDATA   lprincipal                AS boolean OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_attachment
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_attachment
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_attachment
	Local oClone := ECMWorkflowEngineServiceService_attachment():NEW()
	oClone:lattach              := ::lattach
	oClone:ldescriptor          := ::ldescriptor
	oClone:lediting             := ::lediting
	oClone:cfileName            := ::cfileName
	oClone:oWSfileSelected      := IIF(::oWSfileSelected = NIL , NIL , ::oWSfileSelected:Clone() )
	oClone:nfileSize            := ::nfileSize
	oClone:cfilecontent         := ::cfilecontent
	oClone:cfullPatch           := ::cfullPatch
	oClone:ciconPath            := ::ciconPath
	oClone:lmobile              := ::lmobile
	oClone:cpathName            := ::cpathName
	oClone:lprincipal           := ::lprincipal
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMWorkflowEngineServiceService_attachment
	Local cSoap := ""
	cSoap += WSSoapValue("attach", ::lattach, ::lattach , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("descriptor", ::ldescriptor, ::ldescriptor , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("editing", ::lediting, ::lediting , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("fileName", ::cfileName, ::cfileName , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("fileSelected", ::oWSfileSelected, ::oWSfileSelected , "attachment", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("fileSize", ::nfileSize, ::nfileSize , "long", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("filecontent", ::cfilecontent, ::cfilecontent , "base64Binary", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("fullPatch", ::cfullPatch, ::cfullPatch , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("iconPath", ::ciconPath, ::ciconPath , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("mobile", ::lmobile, ::lmobile , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("pathName", ::cpathName, ::cpathName , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("principal", ::lprincipal, ::lprincipal , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_attachment
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lattach            :=  WSAdvValue( oResponse,"_ATTACH","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::ldescriptor        :=  WSAdvValue( oResponse,"_DESCRIPTOR","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::lediting           :=  WSAdvValue( oResponse,"_EDITING","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cfileName          :=  WSAdvValue( oResponse,"_FILENAME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNode5 :=  WSAdvValue( oResponse,"_FILESELECTED","attachment",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode5 != NIL
		::oWSfileSelected := ECMWorkflowEngineServiceService_attachment():New()
		::oWSfileSelected:SoapRecv(oNode5)
	EndIf
	::nfileSize          :=  WSAdvValue( oResponse,"_FILESIZE","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::cfilecontent       :=  WSAdvValue( oResponse,"_FILECONTENT","base64Binary",NIL,NIL,NIL,"SB",NIL,"xs") 
	::cfullPatch         :=  WSAdvValue( oResponse,"_FULLPATCH","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ciconPath          :=  WSAdvValue( oResponse,"_ICONPATH","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::lmobile            :=  WSAdvValue( oResponse,"_MOBILE","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cpathName          :=  WSAdvValue( oResponse,"_PATHNAME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::lprincipal         :=  WSAdvValue( oResponse,"_PRINCIPAL","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
Return

// WSDL Data Structure sociableDocumentDto

WSSTRUCT ECMWorkflowEngineServiceService_sociableDocumentDto
	WSDATA   lcommented                AS boolean OPTIONAL
	WSDATA   ldenounced                AS boolean OPTIONAL
	WSDATA   ndocumentId               AS int OPTIONAL
	WSDATA   lfollowing                AS boolean OPTIONAL
	WSDATA   lliked                    AS boolean OPTIONAL
	WSDATA   nnumberComments           AS int OPTIONAL
	WSDATA   nnumberDenouncements      AS int OPTIONAL
	WSDATA   nnumberFollows            AS int OPTIONAL
	WSDATA   nnumberLikes              AS int OPTIONAL
	WSDATA   nnumberShares             AS int OPTIONAL
	WSDATA   lshared                   AS boolean OPTIONAL
	WSDATA   nsociableId               AS long OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_sociableDocumentDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_sociableDocumentDto
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_sociableDocumentDto
	Local oClone := ECMWorkflowEngineServiceService_sociableDocumentDto():NEW()
	oClone:lcommented           := ::lcommented
	oClone:ldenounced           := ::ldenounced
	oClone:ndocumentId          := ::ndocumentId
	oClone:lfollowing           := ::lfollowing
	oClone:lliked               := ::lliked
	oClone:nnumberComments      := ::nnumberComments
	oClone:nnumberDenouncements := ::nnumberDenouncements
	oClone:nnumberFollows       := ::nnumberFollows
	oClone:nnumberLikes         := ::nnumberLikes
	oClone:nnumberShares        := ::nnumberShares
	oClone:lshared              := ::lshared
	oClone:nsociableId          := ::nsociableId
	oClone:nversion             := ::nversion
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMWorkflowEngineServiceService_sociableDocumentDto
	Local cSoap := ""
	cSoap += WSSoapValue("commented", ::lcommented, ::lcommented , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("denounced", ::ldenounced, ::ldenounced , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("documentId", ::ndocumentId, ::ndocumentId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("following", ::lfollowing, ::lfollowing , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("liked", ::lliked, ::lliked , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("numberComments", ::nnumberComments, ::nnumberComments , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("numberDenouncements", ::nnumberDenouncements, ::nnumberDenouncements , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("numberFollows", ::nnumberFollows, ::nnumberFollows , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("numberLikes", ::nnumberLikes, ::nnumberLikes , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("numberShares", ::nnumberShares, ::nnumberShares , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("shared", ::lshared, ::lshared , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("sociableId", ::nsociableId, ::nsociableId , "long", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("version", ::nversion, ::nversion , "int", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure processTaskDto

WSSTRUCT ECMWorkflowEngineServiceService_processTaskDto
	WSDATA   lactive                   AS boolean OPTIONAL
	WSDATA   lcanCurrentUserTakeTask   AS boolean OPTIONAL
	WSDATA   cchoosedColleagueId       AS string OPTIONAL
	WSDATA   nchoosedSequence          AS int OPTIONAL
	WSDATA   ccolleagueId              AS string OPTIONAL
	WSDATA   ccolleagueName            AS string OPTIONAL
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   lcomplement               AS boolean OPTIONAL
	WSDATA   ccompleteColleagueId      AS string OPTIONAL
	WSDATA   ncompleteType             AS int OPTIONAL
	WSDATA   cdeadlineText             AS string OPTIONAL
	WSDATA   chistorCompleteColleague  AS string OPTIONAL
	WSDATA   chistorTaskObservation    AS string OPTIONAL
	WSDATA   nmovementSequence         AS int OPTIONAL
	WSDATA   nprocessInstanceId        AS int OPTIONAL
	WSDATA   nstatus                   AS int OPTIONAL
	WSDATA   nstatusConsult            AS int OPTIONAL
	WSDATA   ctaskCompletionDate       AS dateTime OPTIONAL
	WSDATA   ntaskCompletionHour       AS int OPTIONAL
	WSDATA   ctaskObservation          AS string OPTIONAL
	WSDATA   ltaskSigned               AS boolean OPTIONAL
	WSDATA   ntransferredSequence      AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMWorkflowEngineServiceService_processTaskDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMWorkflowEngineServiceService_processTaskDto
Return

WSMETHOD CLONE WSCLIENT ECMWorkflowEngineServiceService_processTaskDto
	Local oClone := ECMWorkflowEngineServiceService_processTaskDto():NEW()
	oClone:lactive              := ::lactive
	oClone:lcanCurrentUserTakeTask := ::lcanCurrentUserTakeTask
	oClone:cchoosedColleagueId  := ::cchoosedColleagueId
	oClone:nchoosedSequence     := ::nchoosedSequence
	oClone:ccolleagueId         := ::ccolleagueId
	oClone:ccolleagueName       := ::ccolleagueName
	oClone:ncompanyId           := ::ncompanyId
	oClone:lcomplement          := ::lcomplement
	oClone:ccompleteColleagueId := ::ccompleteColleagueId
	oClone:ncompleteType        := ::ncompleteType
	oClone:cdeadlineText        := ::cdeadlineText
	oClone:chistorCompleteColleague := ::chistorCompleteColleague
	oClone:chistorTaskObservation := ::chistorTaskObservation
	oClone:nmovementSequence    := ::nmovementSequence
	oClone:nprocessInstanceId   := ::nprocessInstanceId
	oClone:nstatus              := ::nstatus
	oClone:nstatusConsult       := ::nstatusConsult
	oClone:ctaskCompletionDate  := ::ctaskCompletionDate
	oClone:ntaskCompletionHour  := ::ntaskCompletionHour
	oClone:ctaskObservation     := ::ctaskObservation
	oClone:ltaskSigned          := ::ltaskSigned
	oClone:ntransferredSequence := ::ntransferredSequence
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMWorkflowEngineServiceService_processTaskDto
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lactive            :=  WSAdvValue( oResponse,"_ACTIVE","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::lcanCurrentUserTakeTask :=  WSAdvValue( oResponse,"_CANCURRENTUSERTAKETASK","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cchoosedColleagueId :=  WSAdvValue( oResponse,"_CHOOSEDCOLLEAGUEID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nchoosedSequence   :=  WSAdvValue( oResponse,"_CHOOSEDSEQUENCE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ccolleagueId       :=  WSAdvValue( oResponse,"_COLLEAGUEID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ccolleagueName     :=  WSAdvValue( oResponse,"_COLLEAGUENAME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::lcomplement        :=  WSAdvValue( oResponse,"_COMPLEMENT","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::ccompleteColleagueId :=  WSAdvValue( oResponse,"_COMPLETECOLLEAGUEID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ncompleteType      :=  WSAdvValue( oResponse,"_COMPLETETYPE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cdeadlineText      :=  WSAdvValue( oResponse,"_DEADLINETEXT","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::chistorCompleteColleague :=  WSAdvValue( oResponse,"_HISTORCOMPLETECOLLEAGUE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::chistorTaskObservation :=  WSAdvValue( oResponse,"_HISTORTASKOBSERVATION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nmovementSequence  :=  WSAdvValue( oResponse,"_MOVEMENTSEQUENCE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nprocessInstanceId :=  WSAdvValue( oResponse,"_PROCESSINSTANCEID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nstatus            :=  WSAdvValue( oResponse,"_STATUS","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nstatusConsult     :=  WSAdvValue( oResponse,"_STATUSCONSULT","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ctaskCompletionDate :=  WSAdvValue( oResponse,"_TASKCOMPLETIONDATE","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::ntaskCompletionHour :=  WSAdvValue( oResponse,"_TASKCOMPLETIONHOUR","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ctaskObservation   :=  WSAdvValue( oResponse,"_TASKOBSERVATION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ltaskSigned        :=  WSAdvValue( oResponse,"_TASKSIGNED","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::ntransferredSequence :=  WSAdvValue( oResponse,"_TRANSFERREDSEQUENCE","int",NIL,NIL,NIL,"N",NIL,"xs") 
Return


