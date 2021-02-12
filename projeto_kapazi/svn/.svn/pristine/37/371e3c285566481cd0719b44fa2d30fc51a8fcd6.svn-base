#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://192.168.101.197:8080/webdesk/ECMCardService?wsdl
Gerado em        02/26/18 17:19:30
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _YUKYWKX ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSECMCardServiceService
------------------------------------------------------------------------------- */

WSCLIENT WSECMCardServiceService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD create
	WSMETHOD updateCardData
	WSMETHOD getCardVersion
	WSMETHOD updateCard
	WSMETHOD deleteCard

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   ncompanyId                AS int
	WSDATA   cusername                 AS string
	WSDATA   cpassword                 AS string
	WSDATA   oWScreatecard             AS ECMCardServiceService_cardDtoArray
	WSDATA   oWScreateresult           AS ECMCardServiceService_webServiceMessageArray
	WSDATA   ncardId                   AS int
	WSDATA   oWSupdateCardDatacardData AS ECMCardServiceService_cardFieldDtoArray
	WSDATA   oWSupdateCardDataresult   AS ECMCardServiceService_webServiceMessageArray
	WSDATA   ndocumentId               AS int
	WSDATA   nversion                  AS int
	WSDATA   ccolleagueId              AS string
	WSDATA   oWSgetCardVersionfolder   AS ECMCardServiceService_cardDtoArray
	WSDATA   oWSupdateCardcard         AS ECMCardServiceService_cardDtoArray
	WSDATA   oWSupdateCardAttachments  AS ECMCardServiceService_attachmentArray
	WSDATA   oWSupdateCardsecurity     AS ECMCardServiceService_documentSecurityConfigDtoArray
	WSDATA   oWSupdateCardApprovers    AS ECMCardServiceService_approverDtoArray
	WSDATA   oWSupdateCardRelatedDocuments AS ECMCardServiceService_relatedDocumentDtoArray
	WSDATA   oWSupdateCardresult       AS ECMCardServiceService_webServiceMessageArray
	WSDATA   oWSdeleteCardresult       AS ECMCardServiceService_webServiceMessageArray

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSECMCardServiceService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20171107 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSECMCardServiceService
	::oWScreatecard      := ECMCardServiceService_CARDDTOARRAY():New()
	::oWScreateresult    := ECMCardServiceService_WEBSERVICEMESSAGEARRAY():New()
	::oWSupdateCardDatacardData := ECMCardServiceService_CARDFIELDDTOARRAY():New()
	::oWSupdateCardDataresult := ECMCardServiceService_WEBSERVICEMESSAGEARRAY():New()
	::oWSgetCardVersionfolder := ECMCardServiceService_CARDDTOARRAY():New()
	::oWSupdateCardcard  := ECMCardServiceService_CARDDTOARRAY():New()
	::oWSupdateCardAttachments := ECMCardServiceService_ATTACHMENTARRAY():New()
	::oWSupdateCardsecurity := ECMCardServiceService_DOCUMENTSECURITYCONFIGDTOARRAY():New()
	::oWSupdateCardApprovers := ECMCardServiceService_APPROVERDTOARRAY():New()
	::oWSupdateCardRelatedDocuments := ECMCardServiceService_RELATEDDOCUMENTDTOARRAY():New()
	::oWSupdateCardresult := ECMCardServiceService_WEBSERVICEMESSAGEARRAY():New()
	::oWSdeleteCardresult := ECMCardServiceService_WEBSERVICEMESSAGEARRAY():New()
Return

WSMETHOD RESET WSCLIENT WSECMCardServiceService
	::ncompanyId         := NIL 
	::cusername          := NIL 
	::cpassword          := NIL 
	::oWScreatecard      := NIL 
	::oWScreateresult    := NIL 
	::ncardId            := NIL 
	::oWSupdateCardDatacardData := NIL 
	::oWSupdateCardDataresult := NIL 
	::ndocumentId        := NIL 
	::nversion           := NIL 
	::ccolleagueId       := NIL 
	::oWSgetCardVersionfolder := NIL 
	::oWSupdateCardcard  := NIL 
	::oWSupdateCardAttachments := NIL 
	::oWSupdateCardsecurity := NIL 
	::oWSupdateCardApprovers := NIL 
	::oWSupdateCardRelatedDocuments := NIL 
	::oWSupdateCardresult := NIL 
	::oWSdeleteCardresult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSECMCardServiceService
Local oClone := WSECMCardServiceService():New()
	oClone:_URL          := ::_URL 
	oClone:ncompanyId    := ::ncompanyId
	oClone:cusername     := ::cusername
	oClone:cpassword     := ::cpassword
	oClone:oWScreatecard :=  IIF(::oWScreatecard = NIL , NIL ,::oWScreatecard:Clone() )
	oClone:oWScreateresult :=  IIF(::oWScreateresult = NIL , NIL ,::oWScreateresult:Clone() )
	oClone:ncardId       := ::ncardId
	oClone:oWSupdateCardDatacardData :=  IIF(::oWSupdateCardDatacardData = NIL , NIL ,::oWSupdateCardDatacardData:Clone() )
	oClone:oWSupdateCardDataresult :=  IIF(::oWSupdateCardDataresult = NIL , NIL ,::oWSupdateCardDataresult:Clone() )
	oClone:ndocumentId   := ::ndocumentId
	oClone:nversion      := ::nversion
	oClone:ccolleagueId  := ::ccolleagueId
	oClone:oWSgetCardVersionfolder :=  IIF(::oWSgetCardVersionfolder = NIL , NIL ,::oWSgetCardVersionfolder:Clone() )
	oClone:oWSupdateCardcard :=  IIF(::oWSupdateCardcard = NIL , NIL ,::oWSupdateCardcard:Clone() )
	oClone:oWSupdateCardAttachments :=  IIF(::oWSupdateCardAttachments = NIL , NIL ,::oWSupdateCardAttachments:Clone() )
	oClone:oWSupdateCardsecurity :=  IIF(::oWSupdateCardsecurity = NIL , NIL ,::oWSupdateCardsecurity:Clone() )
	oClone:oWSupdateCardApprovers :=  IIF(::oWSupdateCardApprovers = NIL , NIL ,::oWSupdateCardApprovers:Clone() )
	oClone:oWSupdateCardRelatedDocuments :=  IIF(::oWSupdateCardRelatedDocuments = NIL , NIL ,::oWSupdateCardRelatedDocuments:Clone() )
	oClone:oWSupdateCardresult :=  IIF(::oWSupdateCardresult = NIL , NIL ,::oWSupdateCardresult:Clone() )
	oClone:oWSdeleteCardresult :=  IIF(::oWSdeleteCardresult = NIL , NIL ,::oWSdeleteCardresult:Clone() )
Return oClone

// WSDL Method create of Service WSECMCardServiceService

WSMETHOD create WSSEND ncompanyId,cusername,cpassword,oWScreatecard WSRECEIVE oWScreateresult WSCLIENT WSECMCardServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:create xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("card", ::oWScreatecard, oWScreatecard , "cardDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:create>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"createCard",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMCardService")

::Init()
::oWScreateresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method updateCardData of Service WSECMCardServiceService

WSMETHOD updateCardData WSSEND ncompanyId,cusername,cpassword,ncardId,oWSupdateCardDatacardData WSRECEIVE oWSupdateCardDataresult WSCLIENT WSECMCardServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:updateCardData xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardId", ::ncardId, ncardId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardData", ::oWSupdateCardDatacardData, oWSupdateCardDatacardData , "cardFieldDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:updateCardData>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"updateCardData",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMCardService")

::Init()
::oWSupdateCardDataresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getCardVersion of Service WSECMCardServiceService

WSMETHOD getCardVersion WSSEND ncompanyId,cusername,cpassword,ndocumentId,nversion,ccolleagueId WSRECEIVE oWSgetCardVersionfolder WSCLIENT WSECMCardServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getCardVersion xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("documentId", ::ndocumentId, ndocumentId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("version", ::nversion, nversion , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:getCardVersion>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getCardVersion",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMCardService")

::Init()
::oWSgetCardVersionfolder:SoapRecv( WSAdvValue( oXmlRet,"_FOLDER","cardDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method updateCard of Service WSECMCardServiceService

WSMETHOD updateCard WSSEND ncompanyId,cusername,cpassword,oWSupdateCardcard,oWSupdateCardAttachments,oWSupdateCardsecurity,oWSupdateCardApprovers,oWSupdateCardRelatedDocuments WSRECEIVE oWSupdateCardresult WSCLIENT WSECMCardServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:updateCard xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("card", ::oWSupdateCardcard, oWSupdateCardcard , "cardDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Attachments", ::oWSupdateCardAttachments, oWSupdateCardAttachments , "attachmentArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("security", ::oWSupdateCardsecurity, oWSupdateCardsecurity , "documentSecurityConfigDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Approvers", ::oWSupdateCardApprovers, oWSupdateCardApprovers , "approverDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("RelatedDocuments", ::oWSupdateCardRelatedDocuments, oWSupdateCardRelatedDocuments , "relatedDocumentDtoArray", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:updateCard>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"updateCard",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMCardService")

::Init()
::oWSupdateCardresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method deleteCard of Service WSECMCardServiceService

WSMETHOD deleteCard WSSEND ncompanyId,cusername,cpassword,ncardId WSRECEIVE oWSdeleteCardresult WSCLIENT WSECMCardServiceService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:deleteCard xmlns:q1="http://ws.dm.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cardId", ::ncardId, ncardId , "int", .T. , .T. , 0 , NIL, .F.,.F.) 
cSoap += "</q1:deleteCard>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"deleteCard",; 
	"RPCX","http://ws.dm.ecm.technology.totvs.com/",,,; 
	"http://192.168.101.197:8080/webdesk/ECMCardService")

::Init()
::oWSdeleteCardresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","webServiceMessageArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure cardDtoArray

WSSTRUCT ECMCardServiceService_cardDtoArray
	WSDATA   oWSitem                   AS ECMCardServiceService_cardDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMCardServiceService_cardDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMCardServiceService_cardDtoArray
	::oWSitem              := {} // Array Of  ECMCardServiceService_CARDDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMCardServiceService_cardDtoArray
	Local oClone := ECMCardServiceService_cardDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMCardServiceService_cardDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "cardDto", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMCardServiceService_cardDtoArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , ECMCardServiceService_cardDto():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure cardDto

WSSTRUCT ECMCardServiceService_cardDto
	WSDATA   cadditionalComments       AS string OPTIONAL
	WSDATA   oWSattachs                AS ECMCardServiceService_attachment OPTIONAL
	WSDATA   oWScardData               AS ECMCardServiceService_cardFieldDto OPTIONAL
	WSDATA   ccolleagueId              AS string OPTIONAL
	WSDATA   oWSdocapprovers           AS ECMCardServiceService_approverDto OPTIONAL
	WSDATA   oWSdocsecurity            AS ECMCardServiceService_documentSecurityConfigDto OPTIONAL
	WSDATA   cdocumentDescription      AS string OPTIONAL
	WSDATA   ndocumentId               AS int OPTIONAL
	WSDATA   cdocumentKeyWord          AS string OPTIONAL
	WSDATA   cexpirationDate           AS dateTime OPTIONAL
	WSDATA   lexpires                  AS boolean OPTIONAL
	WSDATA   linheritSecurity          AS boolean OPTIONAL
	WSDATA   nparentDocumentId         AS int OPTIONAL
	WSDATA   oWSreldocs                AS ECMCardServiceService_relatedDocumentDto OPTIONAL
	WSDATA   ntopicId                  AS int OPTIONAL
	WSDATA   luserNotify               AS boolean OPTIONAL
	WSDATA   cvalidationStartDate      AS dateTime OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSDATA   cversionDescription       AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMCardServiceService_cardDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMCardServiceService_cardDto
	::oWSattachs           := {} // Array Of  ECMCardServiceService_ATTACHMENT():New()
	::oWScardData          := {} // Array Of  ECMCardServiceService_CARDFIELDDTO():New()
	::oWSdocapprovers      := {} // Array Of  ECMCardServiceService_APPROVERDTO():New()
	::oWSdocsecurity       := {} // Array Of  ECMCardServiceService_DOCUMENTSECURITYCONFIGDTO():New()
	::oWSreldocs           := {} // Array Of  ECMCardServiceService_RELATEDDOCUMENTDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMCardServiceService_cardDto
	Local oClone := ECMCardServiceService_cardDto():NEW()
	oClone:cadditionalComments  := ::cadditionalComments
	oClone:oWSattachs := NIL
	If ::oWSattachs <> NIL 
		oClone:oWSattachs := {}
		aEval( ::oWSattachs , { |x| aadd( oClone:oWSattachs , x:Clone() ) } )
	Endif 
	oClone:oWScardData := NIL
	If ::oWScardData <> NIL 
		oClone:oWScardData := {}
		aEval( ::oWScardData , { |x| aadd( oClone:oWScardData , x:Clone() ) } )
	Endif 
	oClone:ccolleagueId         := ::ccolleagueId
	oClone:oWSdocapprovers := NIL
	If ::oWSdocapprovers <> NIL 
		oClone:oWSdocapprovers := {}
		aEval( ::oWSdocapprovers , { |x| aadd( oClone:oWSdocapprovers , x:Clone() ) } )
	Endif 
	oClone:oWSdocsecurity := NIL
	If ::oWSdocsecurity <> NIL 
		oClone:oWSdocsecurity := {}
		aEval( ::oWSdocsecurity , { |x| aadd( oClone:oWSdocsecurity , x:Clone() ) } )
	Endif 
	oClone:cdocumentDescription := ::cdocumentDescription
	oClone:ndocumentId          := ::ndocumentId
	oClone:cdocumentKeyWord     := ::cdocumentKeyWord
	oClone:cexpirationDate      := ::cexpirationDate
	oClone:lexpires             := ::lexpires
	oClone:linheritSecurity     := ::linheritSecurity
	oClone:nparentDocumentId    := ::nparentDocumentId
	oClone:oWSreldocs := NIL
	If ::oWSreldocs <> NIL 
		oClone:oWSreldocs := {}
		aEval( ::oWSreldocs , { |x| aadd( oClone:oWSreldocs , x:Clone() ) } )
	Endif 
	oClone:ntopicId             := ::ntopicId
	oClone:luserNotify          := ::luserNotify
	oClone:cvalidationStartDate := ::cvalidationStartDate
	oClone:nversion             := ::nversion
	oClone:cversionDescription  := ::cversionDescription
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMCardServiceService_cardDto
	Local cSoap := ""
	cSoap += WSSoapValue("additionalComments", ::cadditionalComments, ::cadditionalComments , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	aEval( ::oWSattachs , {|x| cSoap := cSoap  +  WSSoapValue("attachs", x , x , "attachment", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
	aEval( ::oWScardData , {|x| cSoap := cSoap  +  WSSoapValue("cardData", x , x , "cardFieldDto", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
	cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ::ccolleagueId , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	aEval( ::oWSdocapprovers , {|x| cSoap := cSoap  +  WSSoapValue("docapprovers", x , x , "approverDto", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
	aEval( ::oWSdocsecurity , {|x| cSoap := cSoap  +  WSSoapValue("docsecurity", x , x , "documentSecurityConfigDto", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
	cSoap += WSSoapValue("documentDescription", ::cdocumentDescription, ::cdocumentDescription , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("documentId", ::ndocumentId, ::ndocumentId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("documentKeyWord", ::cdocumentKeyWord, ::cdocumentKeyWord , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("expirationDate", ::cexpirationDate, ::cexpirationDate , "dateTime", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("expires", ::lexpires, ::lexpires , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("inheritSecurity", ::linheritSecurity, ::linheritSecurity , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("parentDocumentId", ::nparentDocumentId, ::nparentDocumentId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	aEval( ::oWSreldocs , {|x| cSoap := cSoap  +  WSSoapValue("reldocs", x , x , "relatedDocumentDto", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
	cSoap += WSSoapValue("topicId", ::ntopicId, ::ntopicId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("userNotify", ::luserNotify, ::luserNotify , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("validationStartDate", ::cvalidationStartDate, ::cvalidationStartDate , "dateTime", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("version", ::nversion, ::nversion , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("versionDescription", ::cversionDescription, ::cversionDescription , "string", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMCardServiceService_cardDto
	Local nRElem2 , nTElem2
	Local aNodes2 := WSRPCGetNode(oResponse,.T.)
	Local nRElem3 , nTElem3
	Local aNodes3 := WSRPCGetNode(oResponse,.T.)
	Local nRElem5 , nTElem5
	Local aNodes5 := WSRPCGetNode(oResponse,.T.)
	Local nRElem6 , nTElem6
	Local aNodes6 := WSRPCGetNode(oResponse,.T.)
	Local nRElem14 , nTElem14
	Local aNodes14 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cadditionalComments :=  WSAdvValue( oResponse,"_ADDITIONALCOMMENTS","string",NIL,NIL,NIL,"S",NIL,"xs") 
	nTElem2 := len(aNodes2)
	For nRElem2 := 1 to nTElem2 
		If !WSIsNilNode( aNodes2[nRElem2] )
			aadd(::oWSattachs , ECMCardServiceService_attachment():New() )
  			::oWSattachs[len(::oWSattachs)]:SoapRecv(aNodes2[nRElem2])
		Endif
	Next
	nTElem3 := len(aNodes3)
	For nRElem3 := 1 to nTElem3 
		If !WSIsNilNode( aNodes3[nRElem3] )
			aadd(::oWScardData , ECMCardServiceService_cardFieldDto():New() )
  			::oWScardData[len(::oWScardData)]:SoapRecv(aNodes3[nRElem3])
		Endif
	Next
	::ccolleagueId       :=  WSAdvValue( oResponse,"_COLLEAGUEID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	nTElem5 := len(aNodes5)
	For nRElem5 := 1 to nTElem5 
		If !WSIsNilNode( aNodes5[nRElem5] )
			aadd(::oWSdocapprovers , ECMCardServiceService_approverDto():New() )
  			::oWSdocapprovers[len(::oWSdocapprovers)]:SoapRecv(aNodes5[nRElem5])
		Endif
	Next
	nTElem6 := len(aNodes6)
	For nRElem6 := 1 to nTElem6 
		If !WSIsNilNode( aNodes6[nRElem6] )
			aadd(::oWSdocsecurity , ECMCardServiceService_documentSecurityConfigDto():New() )
  			::oWSdocsecurity[len(::oWSdocsecurity)]:SoapRecv(aNodes6[nRElem6])
		Endif
	Next
	::cdocumentDescription :=  WSAdvValue( oResponse,"_DOCUMENTDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ndocumentId        :=  WSAdvValue( oResponse,"_DOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cdocumentKeyWord   :=  WSAdvValue( oResponse,"_DOCUMENTKEYWORD","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cexpirationDate    :=  WSAdvValue( oResponse,"_EXPIRATIONDATE","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::lexpires           :=  WSAdvValue( oResponse,"_EXPIRES","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::linheritSecurity   :=  WSAdvValue( oResponse,"_INHERITSECURITY","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::nparentDocumentId  :=  WSAdvValue( oResponse,"_PARENTDOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	nTElem14 := len(aNodes14)
	For nRElem14 := 1 to nTElem14 
		If !WSIsNilNode( aNodes14[nRElem14] )
			aadd(::oWSreldocs , ECMCardServiceService_relatedDocumentDto():New() )
  			::oWSreldocs[len(::oWSreldocs)]:SoapRecv(aNodes14[nRElem14])
		Endif
	Next
	::ntopicId           :=  WSAdvValue( oResponse,"_TOPICID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::luserNotify        :=  WSAdvValue( oResponse,"_USERNOTIFY","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cvalidationStartDate :=  WSAdvValue( oResponse,"_VALIDATIONSTARTDATE","dateTime",NIL,NIL,NIL,"S",NIL,"xs") 
	::nversion           :=  WSAdvValue( oResponse,"_VERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cversionDescription :=  WSAdvValue( oResponse,"_VERSIONDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure webServiceMessageArray

WSSTRUCT ECMCardServiceService_webServiceMessageArray
	WSDATA   oWSitem                   AS ECMCardServiceService_webServiceMessage OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMCardServiceService_webServiceMessageArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMCardServiceService_webServiceMessageArray
	::oWSitem              := {} // Array Of  ECMCardServiceService_WEBSERVICEMESSAGE():New()
Return

WSMETHOD CLONE WSCLIENT ECMCardServiceService_webServiceMessageArray
	Local oClone := ECMCardServiceService_webServiceMessageArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMCardServiceService_webServiceMessageArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , ECMCardServiceService_webServiceMessage():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure cardFieldDtoArray

WSSTRUCT ECMCardServiceService_cardFieldDtoArray
	WSDATA   oWSitem                   AS ECMCardServiceService_cardFieldDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMCardServiceService_cardFieldDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMCardServiceService_cardFieldDtoArray
	::oWSitem              := {} // Array Of  ECMCardServiceService_CARDFIELDDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMCardServiceService_cardFieldDtoArray
	Local oClone := ECMCardServiceService_cardFieldDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMCardServiceService_cardFieldDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "cardFieldDto", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure attachmentArray

WSSTRUCT ECMCardServiceService_attachmentArray
	WSDATA   oWSitem                   AS ECMCardServiceService_attachment OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMCardServiceService_attachmentArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMCardServiceService_attachmentArray
	::oWSitem              := {} // Array Of  ECMCardServiceService_ATTACHMENT():New()
Return

WSMETHOD CLONE WSCLIENT ECMCardServiceService_attachmentArray
	Local oClone := ECMCardServiceService_attachmentArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMCardServiceService_attachmentArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "attachment", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure documentSecurityConfigDtoArray

WSSTRUCT ECMCardServiceService_documentSecurityConfigDtoArray
	WSDATA   oWSitem                   AS ECMCardServiceService_documentSecurityConfigDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMCardServiceService_documentSecurityConfigDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMCardServiceService_documentSecurityConfigDtoArray
	::oWSitem              := {} // Array Of  ECMCardServiceService_DOCUMENTSECURITYCONFIGDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMCardServiceService_documentSecurityConfigDtoArray
	Local oClone := ECMCardServiceService_documentSecurityConfigDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMCardServiceService_documentSecurityConfigDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "documentSecurityConfigDto", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure approverDtoArray

WSSTRUCT ECMCardServiceService_approverDtoArray
	WSDATA   oWSitem                   AS ECMCardServiceService_approverDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMCardServiceService_approverDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMCardServiceService_approverDtoArray
	::oWSitem              := {} // Array Of  ECMCardServiceService_APPROVERDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMCardServiceService_approverDtoArray
	Local oClone := ECMCardServiceService_approverDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMCardServiceService_approverDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "approverDto", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure relatedDocumentDtoArray

WSSTRUCT ECMCardServiceService_relatedDocumentDtoArray
	WSDATA   oWSitem                   AS ECMCardServiceService_relatedDocumentDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMCardServiceService_relatedDocumentDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMCardServiceService_relatedDocumentDtoArray
	::oWSitem              := {} // Array Of  ECMCardServiceService_RELATEDDOCUMENTDTO():New()
Return

WSMETHOD CLONE WSCLIENT ECMCardServiceService_relatedDocumentDtoArray
	Local oClone := ECMCardServiceService_relatedDocumentDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMCardServiceService_relatedDocumentDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "relatedDocumentDto", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure attachment

WSSTRUCT ECMCardServiceService_attachment
	WSDATA   lattach                   AS boolean OPTIONAL
	WSDATA   ldescriptor               AS boolean OPTIONAL
	WSDATA   lediting                  AS boolean OPTIONAL
	WSDATA   cfileName                 AS string OPTIONAL
	WSDATA   oWSfileSelected           AS ECMCardServiceService_attachment OPTIONAL
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

WSMETHOD NEW WSCLIENT ECMCardServiceService_attachment
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMCardServiceService_attachment
Return

WSMETHOD CLONE WSCLIENT ECMCardServiceService_attachment
	Local oClone := ECMCardServiceService_attachment():NEW()
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

WSMETHOD SOAPSEND WSCLIENT ECMCardServiceService_attachment
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

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMCardServiceService_attachment
	Local oNode5
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lattach            :=  WSAdvValue( oResponse,"_ATTACH","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::ldescriptor        :=  WSAdvValue( oResponse,"_DESCRIPTOR","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::lediting           :=  WSAdvValue( oResponse,"_EDITING","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cfileName          :=  WSAdvValue( oResponse,"_FILENAME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	oNode5 :=  WSAdvValue( oResponse,"_FILESELECTED","attachment",NIL,NIL,NIL,"O",NIL,"xs") 
	If oNode5 != NIL
		::oWSfileSelected := ECMCardServiceService_attachment():New()
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

// WSDL Data Structure cardFieldDto

WSSTRUCT ECMCardServiceService_cardFieldDto
	WSDATA   cfield                    AS string OPTIONAL
	WSDATA   cvalue                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMCardServiceService_cardFieldDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMCardServiceService_cardFieldDto
Return

WSMETHOD CLONE WSCLIENT ECMCardServiceService_cardFieldDto
	Local oClone := ECMCardServiceService_cardFieldDto():NEW()
	oClone:cfield               := ::cfield
	oClone:cvalue               := ::cvalue
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMCardServiceService_cardFieldDto
	Local cSoap := ""
	cSoap += WSSoapValue("field", ::cfield, ::cfield , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("value", ::cvalue, ::cvalue , "string", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMCardServiceService_cardFieldDto
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cfield             :=  WSAdvValue( oResponse,"_FIELD","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cvalue             :=  WSAdvValue( oResponse,"_VALUE","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure approverDto

WSSTRUCT ECMCardServiceService_approverDto
	WSDATA   napprovelMode             AS int OPTIONAL
	WSDATA   napproverType             AS int OPTIONAL
	WSDATA   ccolleagueId              AS string OPTIONAL
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   ndocumentId               AS int OPTIONAL
	WSDATA   cfoo                      AS string OPTIONAL
	WSDATA   clevelDescription         AS string OPTIONAL
	WSDATA   nlevelId                  AS int OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMCardServiceService_approverDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMCardServiceService_approverDto
	::cfoo                 := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT ECMCardServiceService_approverDto
	Local oClone := ECMCardServiceService_approverDto():NEW()
	oClone:napprovelMode        := ::napprovelMode
	oClone:napproverType        := ::napproverType
	oClone:ccolleagueId         := ::ccolleagueId
	oClone:ncompanyId           := ::ncompanyId
	oClone:ndocumentId          := ::ndocumentId
	oClone:cfoo                 := IIf(::cfoo <> NIL , aClone(::cfoo) , NIL )
	oClone:clevelDescription    := ::clevelDescription
	oClone:nlevelId             := ::nlevelId
	oClone:nversion             := ::nversion
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMCardServiceService_approverDto
	Local cSoap := ""
	cSoap += WSSoapValue("approvelMode", ::napprovelMode, ::napprovelMode , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("approverType", ::napproverType, ::napproverType , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ::ccolleagueId , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("companyId", ::ncompanyId, ::ncompanyId , "long", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("documentId", ::ndocumentId, ::ndocumentId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	aEval( ::cfoo , {|x| cSoap := cSoap  +  WSSoapValue("foo", x , x , "string", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
	cSoap += WSSoapValue("levelDescription", ::clevelDescription, ::clevelDescription , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("levelId", ::nlevelId, ::nlevelId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("version", ::nversion, ::nversion , "int", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMCardServiceService_approverDto
	Local oNodes6 :=  WSAdvValue( oResponse,"_FOO","string",{},NIL,.T.,"S",NIL,"xs") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::napprovelMode      :=  WSAdvValue( oResponse,"_APPROVELMODE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::napproverType      :=  WSAdvValue( oResponse,"_APPROVERTYPE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ccolleagueId       :=  WSAdvValue( oResponse,"_COLLEAGUEID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::ndocumentId        :=  WSAdvValue( oResponse,"_DOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	aEval(oNodes6 , { |x| aadd(::cfoo ,  x:TEXT  ) } )
	::clevelDescription  :=  WSAdvValue( oResponse,"_LEVELDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nlevelId           :=  WSAdvValue( oResponse,"_LEVELID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nversion           :=  WSAdvValue( oResponse,"_VERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
Return

// WSDL Data Structure documentSecurityConfigDto

WSSTRUCT ECMCardServiceService_documentSecurityConfigDto
	WSDATA   nattributionType          AS int OPTIONAL
	WSDATA   cattributionValue         AS string OPTIONAL
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   ndocumentId               AS int OPTIONAL
	WSDATA   ldownloadEnabled          AS boolean OPTIONAL
	WSDATA   cfoo                      AS string OPTIONAL
	WSDATA   lpermission               AS boolean OPTIONAL
	WSDATA   nsecurityLevel            AS int OPTIONAL
	WSDATA   lsecurityVersion          AS boolean OPTIONAL
	WSDATA   nsequence                 AS int OPTIONAL
	WSDATA   lshowContent              AS boolean OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMCardServiceService_documentSecurityConfigDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMCardServiceService_documentSecurityConfigDto
	::cfoo                 := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT ECMCardServiceService_documentSecurityConfigDto
	Local oClone := ECMCardServiceService_documentSecurityConfigDto():NEW()
	oClone:nattributionType     := ::nattributionType
	oClone:cattributionValue    := ::cattributionValue
	oClone:ncompanyId           := ::ncompanyId
	oClone:ndocumentId          := ::ndocumentId
	oClone:ldownloadEnabled     := ::ldownloadEnabled
	oClone:cfoo                 := IIf(::cfoo <> NIL , aClone(::cfoo) , NIL )
	oClone:lpermission          := ::lpermission
	oClone:nsecurityLevel       := ::nsecurityLevel
	oClone:lsecurityVersion     := ::lsecurityVersion
	oClone:nsequence            := ::nsequence
	oClone:lshowContent         := ::lshowContent
	oClone:nversion             := ::nversion
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMCardServiceService_documentSecurityConfigDto
	Local cSoap := ""
	cSoap += WSSoapValue("attributionType", ::nattributionType, ::nattributionType , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("attributionValue", ::cattributionValue, ::cattributionValue , "string", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("companyId", ::ncompanyId, ::ncompanyId , "long", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("documentId", ::ndocumentId, ::ndocumentId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("downloadEnabled", ::ldownloadEnabled, ::ldownloadEnabled , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	aEval( ::cfoo , {|x| cSoap := cSoap  +  WSSoapValue("foo", x , x , "string", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
	cSoap += WSSoapValue("permission", ::lpermission, ::lpermission , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("securityLevel", ::nsecurityLevel, ::nsecurityLevel , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("securityVersion", ::lsecurityVersion, ::lsecurityVersion , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("sequence", ::nsequence, ::nsequence , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("showContent", ::lshowContent, ::lshowContent , "boolean", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("version", ::nversion, ::nversion , "int", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMCardServiceService_documentSecurityConfigDto
	Local oNodes6 :=  WSAdvValue( oResponse,"_FOO","string",{},NIL,.T.,"S",NIL,"xs") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nattributionType   :=  WSAdvValue( oResponse,"_ATTRIBUTIONTYPE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cattributionValue  :=  WSAdvValue( oResponse,"_ATTRIBUTIONVALUE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::ndocumentId        :=  WSAdvValue( oResponse,"_DOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ldownloadEnabled   :=  WSAdvValue( oResponse,"_DOWNLOADENABLED","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	aEval(oNodes6 , { |x| aadd(::cfoo ,  x:TEXT  ) } )
	::lpermission        :=  WSAdvValue( oResponse,"_PERMISSION","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::nsecurityLevel     :=  WSAdvValue( oResponse,"_SECURITYLEVEL","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::lsecurityVersion   :=  WSAdvValue( oResponse,"_SECURITYVERSION","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::nsequence          :=  WSAdvValue( oResponse,"_SEQUENCE","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::lshowContent       :=  WSAdvValue( oResponse,"_SHOWCONTENT","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::nversion           :=  WSAdvValue( oResponse,"_VERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
Return

// WSDL Data Structure relatedDocumentDto

WSSTRUCT ECMCardServiceService_relatedDocumentDto
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   ndocumentId               AS int OPTIONAL
	WSDATA   cfoo                      AS string OPTIONAL
	WSDATA   nrelatedDocumentId        AS int OPTIONAL
	WSDATA   nversion                  AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ECMCardServiceService_relatedDocumentDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMCardServiceService_relatedDocumentDto
	::cfoo                 := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT ECMCardServiceService_relatedDocumentDto
	Local oClone := ECMCardServiceService_relatedDocumentDto():NEW()
	oClone:ncompanyId           := ::ncompanyId
	oClone:ndocumentId          := ::ndocumentId
	oClone:cfoo                 := IIf(::cfoo <> NIL , aClone(::cfoo) , NIL )
	oClone:nrelatedDocumentId   := ::nrelatedDocumentId
	oClone:nversion             := ::nversion
Return oClone

WSMETHOD SOAPSEND WSCLIENT ECMCardServiceService_relatedDocumentDto
	Local cSoap := ""
	cSoap += WSSoapValue("companyId", ::ncompanyId, ::ncompanyId , "long", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("documentId", ::ndocumentId, ::ndocumentId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	aEval( ::cfoo , {|x| cSoap := cSoap  +  WSSoapValue("foo", x , x , "string", .F. , .T., 0 , NIL, .F.,.F.)  } ) 
	cSoap += WSSoapValue("relatedDocumentId", ::nrelatedDocumentId, ::nrelatedDocumentId , "int", .F. , .T., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("version", ::nversion, ::nversion , "int", .F. , .T., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMCardServiceService_relatedDocumentDto
	Local oNodes3 :=  WSAdvValue( oResponse,"_FOO","string",{},NIL,.T.,"S",NIL,"xs") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::ndocumentId        :=  WSAdvValue( oResponse,"_DOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	aEval(oNodes3 , { |x| aadd(::cfoo ,  x:TEXT  ) } )
	::nrelatedDocumentId :=  WSAdvValue( oResponse,"_RELATEDDOCUMENTID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::nversion           :=  WSAdvValue( oResponse,"_VERSION","int",NIL,NIL,NIL,"N",NIL,"xs") 
Return

// WSDL Data Structure webServiceMessage

WSSTRUCT ECMCardServiceService_webServiceMessage
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

WSMETHOD NEW WSCLIENT ECMCardServiceService_webServiceMessage
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ECMCardServiceService_webServiceMessage
	::cfoo                 := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT ECMCardServiceService_webServiceMessage
	Local oClone := ECMCardServiceService_webServiceMessage():NEW()
	oClone:ncompanyId           := ::ncompanyId
	oClone:cdocumentDescription := ::cdocumentDescription
	oClone:ndocumentId          := ::ndocumentId
	oClone:cfoo                 := IIf(::cfoo <> NIL , aClone(::cfoo) , NIL )
	oClone:nversion             := ::nversion
	oClone:cwebServiceMessage   := ::cwebServiceMessage
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ECMCardServiceService_webServiceMessage
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


