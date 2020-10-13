#include 'protheus.ch'

user function _Z74YT1AC8()
return


/*/{Protheus.doc} TeknisaLog
//TODO Classe para gerar LOG de WS
@author Rafael Vieceli
@since 25/05/2018
@version 1.0
/*/
class TeknisaLog from LongClassName

	data nReg

	method start(cMethod, cUrl) constructor
	method broken(cMethod, cInfoConn, cReturn, lAddInfo) constructor
	method newOrUpdate(cMethod)
	method finish()

	method setXmlEnv(cXml, nItens)
	method setXmlRet(cXml)
	method setError(cError)
	method setCountOk()
	method pos()

endclass


/*/{Protheus.doc} start
//TODO Metodo para iniciar o LOG
@author Rafael Vieceli
@since 25/05/2018
@version 1.0
@param cMethod, characters, Metodo que esta sendo utilizado
@param cUrl, characters, URL de conexão
/*/
method start(cMethod, cUrl) class TeknisaLog

	::newOrUpdate(cMethod)

	ZWS->ZWS_PROCES := cMethod
	ZWS->ZWS_NINT   ++
	ZWS->ZWS_STATUS := "A" //aguardando
	ZWS->ZWS_DTINT  := date()
	ZWS->ZWS_HRINT  := time()
	ZWS->ZWS_INF    := "Conectando em " + cUrl
//	ZWS->ZWS_XMLE	:= ""
//	ZWS->ZWS_XMLR	:= ""
	ZWS->( msUnLock() )

	//salva o registro
	::nReg := ZWS->( Recno() )

return


/*/{Protheus.doc} broken
//TODO Metodo para atualizar o LOG
@author Rafael Vieceli
@since 25/05/2018
@version 1.0
@return ${return}, ${return_description}
@param cMethod, characters, Nome do Metodo
@param cInfoConn, characters, Informações de conexão
@param cReturn, characters, XML de retorno
/*/
method broken(cMethod, cInfoConn, cReturn) class TeknisaLog

	::newOrUpdate(cMethod)

	ZWS->ZWS_PROCES := cMethod
	ZWS->ZWS_STATUS := "E" //erro
	ZWS->ZWS_DTINT  := date()
	ZWS->ZWS_HRINT  := time()
	ZWS->ZWS_INF    := cInfoConn
//	ZWS->ZWS_XMLR   += cReturn + CRLF + Replicate("-",40) + CRLF
	ZWS->ZWS_XMLR   := cReturn
	ZWS->( msUnLock() )

	ConOut("[" + DtoC(date()) + " " + time() + "] Broken method " + cMethod + " " + cInfoConn)

return nil


/*/{Protheus.doc} newOrUpdate
//TODO Metodo para verificar se é novi registo ou alteração
@author Rafael Vieceli
@since 25/05/2018
@param cMethod, characters, Mome do Metodo
/*/
method newOrUpdate(cMethod) class TeknisaLog

	Local lnew

	//tabela de log
	dbSelectArea("ZWS")

	//ZWS_FILIAL+ZWS_PROCES+ZWS_DTINT
	ZWS->( dbSetOrder(1) )
	ZWS->( dbGoTop() )
	ZWS->( dbSeek( xFilial("ZWS") + PadR(cMethod,TamSX3("ZWS_PROCES")[1]) + DtoS(Date()) ) )

	lnew := ! ZWS->( Found() )

	recLock("ZWS",lnew)

	IF lnew
		ZWS->ZWS_FILIAL := xFilial("ZWS")
	EndIF
	
	//limpa numero de itens
	ZWS->ZWS_ITCONF := 0

return


/*/{Protheus.doc} finish
//TODO Metodo para finalizar o log
@author Rafael Vieceli
@since 25/05/2018
@version 1.0
/*/
method finish() class TeknisaLog

	::pos()

	recLock("ZWS",.F.)
	ZWS->ZWS_STATUS := IIF(ZWS->ZWS_ITENV == ZWS->ZWS_ITCONF,"I","E")
	ZWS->( msUnLock() )

	::nReg := nil

return


/*/{Protheus.doc} setXmlEnv
//TODO Metodo para gravar o XML enviado
@author Rafael Vieceli
@since 25/05/2018
@version 1.0
@return ${return}, ${return_description}
@param cXml, characters, CML
@param nItens, numeric, Quantidad de itens enviados
/*/
method setXmlEnv(cXml, nItens) class TeknisaLog

	::pos()

	recLock("ZWS",.F.)
//	ZWS->ZWS_XMLE	+= cXml + CRLF + Replicate("-",40) + CRLF
	ZWS->ZWS_XMLE	:= cXml
	ZWS->ZWS_ITENV  := nItens
	ZWS->( msUnLock() )

return


/*/{Protheus.doc} setXmlRet
//TODO Metodo para gravar o XML recebido
@author Rafael Vieceli
@since 25/05/2018
@version 1.0
@param cXml, characters, XML
/*/
method setXmlRet(cXml) class TeknisaLog

	::pos()

	recLock("ZWS",.F.)
//	ZWS->ZWS_XMLR += cXml + CRLF + Replicate("-",40) + CRLF
	ZWS->ZWS_XMLR := cXml
	ZWS->( msUnLock() )

return


/*/{Protheus.doc} setCountOk
//TODO Metodo para contar o retonos com sucesso
@author Rafael Viecelia
@since 25/05/2018
@version 1.0
/*/
method setCountOk() class TeknisaLog

	::pos()

	recLock("ZWS",.F.)
	ZWS->ZWS_ITCONF ++
	ZWS->( msUnLock() )

return


/*/{Protheus.doc} setError
//TODO Metodo para gravar erro
@author Rafael Vieceli
@since 25/05/2018
@version 1.0
@param cError, characters, Erro
/*/
method setError(cError) class TeknisaLog

	::pos()

	recLock("ZWS",.F.)
	ZWS->ZWS_INF    := cError + " " + ZWS->ZWS_INF
	ZWS->( msUnLock() )

return


/*/{Protheus.doc} pos
//TODO metodo para posiconar tabela no registro correto
@author Mario L. B. Faria
@since 25/05/2018
@version 1.0
/*/
method pos() class TeknisaLog

	IF ::nReg == nil
		UserException("Classe nao por instancia para method Start.")
	EndIF

	IF ZWS->( Recno() ) != ::nReg
		ZWS->( dbGoTo( ::nReg ) )
	EndIF
	
return