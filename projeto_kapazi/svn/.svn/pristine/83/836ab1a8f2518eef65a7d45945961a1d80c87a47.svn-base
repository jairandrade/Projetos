#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://192.168.103.201:9092/WS_NOSSONUMERO.apw?WSDL
Gerado em        08/17/19 17:50:58
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _EGJMQAJ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWS_NOSSONUMERO
------------------------------------------------------------------------------- */

WSCLIENT WSWS_NOSSONUMERO

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CONSULTA_ITENS

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cLOGIN                    AS string
	WSDATA   cSENHA                    AS string
	WSDATA   cCGC                      AS string
	WSDATA   oWSCONSULTA_ITENSRESULT   AS WS_NOSSONUMERO_NOSSONUMERO_CAB

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWS_NOSSONUMERO
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20190114 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWS_NOSSONUMERO
	::oWSCONSULTA_ITENSRESULT := WS_NOSSONUMERO_NOSSONUMERO_CAB():New()
Return

WSMETHOD RESET WSCLIENT WSWS_NOSSONUMERO
	::cLOGIN             := NIL 
	::cSENHA             := NIL 
	::cCGC               := NIL 
	::oWSCONSULTA_ITENSRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWS_NOSSONUMERO
Local oClone := WSWS_NOSSONUMERO():New()
	oClone:_URL          := ::_URL 
	oClone:cLOGIN        := ::cLOGIN
	oClone:cSENHA        := ::cSENHA
	oClone:cCGC          := ::cCGC
	oClone:oWSCONSULTA_ITENSRESULT :=  IIF(::oWSCONSULTA_ITENSRESULT = NIL , NIL ,::oWSCONSULTA_ITENSRESULT:Clone() )
Return oClone

// WSDL Method CONSULTA_ITENS of Service WSWS_NOSSONUMERO

WSMETHOD CONSULTA_ITENS WSSEND cLOGIN,cSENHA,cCGC WSRECEIVE oWSCONSULTA_ITENSRESULT WSCLIENT WSWS_NOSSONUMERO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONSULTA_ITENS xmlns="http://192.168.103.201:9092/">'
cSoap += WSSoapValue("LOGIN", ::cLOGIN, cLOGIN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("SENHA", ::cSENHA, cSENHA , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CGC", ::cCGC, cCGC , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CONSULTA_ITENS>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://192.168.103.201:9092/CONSULTA_ITENS",; 
	"DOCUMENT","http://192.168.103.201:9092/",,"1.031217",; 
	"http://192.168.103.201:9092/WS_NOSSONUMERO.apw")

::Init()
::oWSCONSULTA_ITENSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTA_ITENSRESPONSE:_CONSULTA_ITENSRESULT","NOSSONUMERO_CAB",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure NOSSONUMERO_CAB

WSSTRUCT WS_NOSSONUMERO_NOSSONUMERO_CAB
	WSDATA   cCGC                      AS string
	WSDATA   oWSITEM                   AS WS_NOSSONUMERO_ARRAYOFNOSSONUMERO_ITENS OPTIONAL
	WSDATA   cNOME                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_NOSSONUMERO_NOSSONUMERO_CAB
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_NOSSONUMERO_NOSSONUMERO_CAB
Return

WSMETHOD CLONE WSCLIENT WS_NOSSONUMERO_NOSSONUMERO_CAB
	Local oClone := WS_NOSSONUMERO_NOSSONUMERO_CAB():NEW()
	oClone:cCGC                 := ::cCGC
	oClone:oWSITEM              := IIF(::oWSITEM = NIL , NIL , ::oWSITEM:Clone() )
	oClone:cNOME                := ::cNOME
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_NOSSONUMERO_NOSSONUMERO_CAB
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCGC               :=  WSAdvValue( oResponse,"_CGC","string",NIL,"Property cCGC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_ITEM","ARRAYOFNOSSONUMERO_ITENS",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSITEM := WS_NOSSONUMERO_ARRAYOFNOSSONUMERO_ITENS():New()
		::oWSITEM:SoapRecv(oNode2)
	EndIf
	::cNOME              :=  WSAdvValue( oResponse,"_NOME","string",NIL,"Property cNOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFNOSSONUMERO_ITENS

WSSTRUCT WS_NOSSONUMERO_ARRAYOFNOSSONUMERO_ITENS
	WSDATA   oWSNOSSONUMERO_ITENS      AS WS_NOSSONUMERO_NOSSONUMERO_ITENS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_NOSSONUMERO_ARRAYOFNOSSONUMERO_ITENS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_NOSSONUMERO_ARRAYOFNOSSONUMERO_ITENS
	::oWSNOSSONUMERO_ITENS := {} // Array Of  WS_NOSSONUMERO_NOSSONUMERO_ITENS():New()
Return

WSMETHOD CLONE WSCLIENT WS_NOSSONUMERO_ARRAYOFNOSSONUMERO_ITENS
	Local oClone := WS_NOSSONUMERO_ARRAYOFNOSSONUMERO_ITENS():NEW()
	oClone:oWSNOSSONUMERO_ITENS := NIL
	If ::oWSNOSSONUMERO_ITENS <> NIL 
		oClone:oWSNOSSONUMERO_ITENS := {}
		aEval( ::oWSNOSSONUMERO_ITENS , { |x| aadd( oClone:oWSNOSSONUMERO_ITENS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_NOSSONUMERO_ARRAYOFNOSSONUMERO_ITENS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_NOSSONUMERO_ITENS","NOSSONUMERO_ITENS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSNOSSONUMERO_ITENS , WS_NOSSONUMERO_NOSSONUMERO_ITENS():New() )
			::oWSNOSSONUMERO_ITENS[len(::oWSNOSSONUMERO_ITENS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure NOSSONUMERO_ITENS

WSSTRUCT WS_NOSSONUMERO_NOSSONUMERO_ITENS
	WSDATA   cBANCO                    AS string
	WSDATA   cCNPJ_EMISSOR             AS string
	WSDATA   cEMISSAO                  AS string
	WSDATA   cNOME_EMISSOR             AS string
	WSDATA   cNOSSONUMERO              AS string
	WSDATA   nSALDO                    AS float
	WSDATA   nVALOR                    AS float
	WSDATA   cVENCIMENTO               AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_NOSSONUMERO_NOSSONUMERO_ITENS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_NOSSONUMERO_NOSSONUMERO_ITENS
Return

WSMETHOD CLONE WSCLIENT WS_NOSSONUMERO_NOSSONUMERO_ITENS
	Local oClone := WS_NOSSONUMERO_NOSSONUMERO_ITENS():NEW()
	oClone:cBANCO               := ::cBANCO
	oClone:cCNPJ_EMISSOR        := ::cCNPJ_EMISSOR
	oClone:cEMISSAO             := ::cEMISSAO
	oClone:cNOME_EMISSOR        := ::cNOME_EMISSOR
	oClone:cNOSSONUMERO         := ::cNOSSONUMERO
	oClone:nSALDO               := ::nSALDO
	oClone:nVALOR               := ::nVALOR
	oClone:cVENCIMENTO          := ::cVENCIMENTO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_NOSSONUMERO_NOSSONUMERO_ITENS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cBANCO             :=  WSAdvValue( oResponse,"_BANCO","string",NIL,"Property cBANCO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCNPJ_EMISSOR      :=  WSAdvValue( oResponse,"_CNPJ_EMISSOR","string",NIL,"Property cCNPJ_EMISSOR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cEMISSAO           :=  WSAdvValue( oResponse,"_EMISSAO","string",NIL,"Property cEMISSAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOME_EMISSOR      :=  WSAdvValue( oResponse,"_NOME_EMISSOR","string",NIL,"Property cNOME_EMISSOR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOSSONUMERO       :=  WSAdvValue( oResponse,"_NOSSONUMERO","string",NIL,"Property cNOSSONUMERO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nSALDO             :=  WSAdvValue( oResponse,"_SALDO","float",NIL,"Property nSALDO as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nVALOR             :=  WSAdvValue( oResponse,"_VALOR","float",NIL,"Property nVALOR as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cVENCIMENTO        :=  WSAdvValue( oResponse,"_VENCIMENTO","string",NIL,"Property cVENCIMENTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


