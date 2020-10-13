#include 'protheus.ch'

user function mdrbin_test()

	RPCSetEnv('99','01')

//	MaderoBillIntegration_client():deleteReal('2', date())

	MaderoBillIntegration_client():createTemporaty('2', date(), date(), 145.18)

	MaderoBillIntegration_client():deleteTemporaty('2', date())

//	MaderoBillIntegration_client():createReal('2', date(), date(), 145.18)
//
//	MaderoBillIntegration_client():deleteReal('2', date())
//
//	MaderoBillIntegration_client():createTemporaty('2', date(), date(), 145.18)
//
//	MaderoBillIntegration_client():replace('2', date(), date(), 145.18)
//
//	MaderoBillIntegration_client():deleteReal('2', date())

	RPCClearEnv()

return



class MaderoBillIntegration_client from LongClassName

	data restClient
	data status
	data result

	method new()

	method createTemporary() constructor
	method createReal() constructor
	method Replace() constructor
	method deleteTemporary() constructor
	method deleteReal() constructor

	method init()

	method getCompany()
	method getBranch()
	method getUser()
	method getPass()

	method getHeaders()


	method show()

endClass


method createTemporary(type, issueDate, dueDate, value, result, lShow) class MaderoBillIntegration_client

	default lShow := .T.

	::init('Temporary', '?type='+type+'&issueDate='+trD(issueDate)+'&dueDate='+trD(dueDate)+'&value=' + cValToChar(value))
	result := ::status := ::restClient:post(::getHeaders())

	IF lShow
		::show()
	EndIF

	::restClient := nil

return


method createReal(type, issueDate, dueDate, value, result, lShow) class MaderoBillIntegration_client

	default lShow := .T.

	::init('Real', '?type='+type+'&issueDate='+trD(issueDate)+'&dueDate='+trD(dueDate)+'&value=' + cValToChar(value))

	result := ::status := ::restClient:post(::getHeaders())

	IF lShow
		::show()
	EndIF

	::restClient := nil

return


method replace(type, issueDate, dueDate, value, start, result, lShow) class MaderoBillIntegration_client

	default lShow := .T.

	::init('Replace', '?type='+type+'&issueDate='+trD(issueDate)+'&dueDate='+trD(dueDate)+'&value=' + cValToChar(value)+'&start=' + trD(start))

	result := ::status := ::restClient:put(::getHeaders())

	IF lShow
		::show()
	EndIF

	::restClient := nil

return


method deleteTemporary(type, issueDate, result, lShow) class MaderoBillIntegration_client

	default lShow := .T.

	::init('Temporary', '?type='+type+'&issueDate='+trD(issueDate)+'&dueDate')

	result := ::status := ::restClient:delete(::getHeaders())

	IF lShow
		::show()
	EndIF

	::restClient := nil

return


method deleteReal(type, issueDate, result, lShow) class MaderoBillIntegration_client

	default lShow := .T.

	::init('Real', '?type='+type+'&issueDate='+trD(issueDate)+'&dueDate')

	conout('?type='+type+'&issueDate='+trD(issueDate)+'&dueDate')

	result := ::status := ::restClient:delete(::getHeaders())

	IF lShow
		::show()
	EndIF

	::restClient := nil

return


method init(location, pathParams) class MaderoBillIntegration_client

	::restClient := FWRest():New("http://" + SuperGetMV("MD_TAFIPP",,"localhost:8067"))
	//#TB20200505 Thiago Berna - Ajuste do setPath
	//::restClient:setPath("/api/" + ::getCompany() + "/v1/MaderoBillIntegration/"+location+"/" + pathParams)
	::restClient:setPath("/MADEROBILLINTEGRATION/v1/MaderoBillIntegration/"+location+"/" + pathParams)

return


static function trD(date)
return cValToChar(year(date))+'/'+strzero(month(date),2)+'/'+strzero(day(date),2)


method getCompany() class MaderoBillIntegration_client

	C1E->( dbSetOrder(3) )
	C1E->( dbSeek( xFilial("C1E") + cFilAnt ) )

	IF C1E->( Found() )

		CR9->( dbSetOrder(1) )
		CR9->( dbSeek( xFilial("CR9") + C1E->C1E_ID ) )

		IF CR9->( Found() ) .and. ! empty(CR9->CR9_CODFIL)
			return substr(CR9->CR9_CODFIL, 1, 2)
		ElseIF ! empty(C1E->C1E_CODFIL)
			return substr(C1E->C1E_CODFIL, 1, 2)
		EndIF

	EndIF

return SuperGetMV('MD_TAFEMP',,'01')


method getBranch() class MaderoBillIntegration_client

	C1E->( dbSetOrder(3) )
	C1E->( dbSeek( xFilial("C1E") + cFilAnt ) )

	IF C1E->( Found() )

		CR9->( dbSetOrder(1) )
		CR9->( dbSeek( xFilial("CR9") + C1E->C1E_ID ) )

		IF CR9->( Found() ) .and. ! empty(CR9->CR9_CODFIL)
			return alltrim(substr(CR9->CR9_CODFIL, 3))
		ElseIF ! empty(C1E->C1E_CODFIL)
			return alltrim(substr(C1E->C1E_CODFIL, 3))
		EndIF

	EndIF

return SuperGetMV('MD_TAFFIL',,'01')


method getUser() class MaderoBillIntegration_client
return SuperGetMV('MD_TAFUSR',,'admin')


method getPass() class MaderoBillIntegration_client
return SuperGetMV('MD_TAFPASS',,' ')


method getHeaders() class MaderoBillIntegration_client
return {;
	;//"Authorization: Basic "+ Encode64('michael.andrade'+':'+'Pr0th3us12') , ;
	"Authorization: Basic "+ Encode64( ::getUser() + ':' + ::getPass() ) , ;
	"Content-Type: application/json" , ;
	"branch: " + ::getBranch()  ;
}


method show() class MaderoBillIntegration_client

	Local cJson := self:restClient:cResult
	Local result := JsonObject():new()

	result:fromJson(cJson)

	do case
		case empty(cJson)
			myHelp("Nao foi possivel conexão com o webservice para integração'.")

		case ::status
			ConOut("SUCCESS", result['message'])
			IF ! isBlind()
				Aviso('Sucesso', result['message'], {'Ok'}, 1)
			EndIF
		case ! empty(result['message'])
			myHelp(result['message'] )

		case ! empty(result['errorMessage'])
			myHelp(result['errorMessage'])

	endcase

return


static function myHelp(message)

	ConOut("FAIL", message)

	IF ! isBlind()
		Help(,1,"Atenção",,message,1,0)
	EndIF

return