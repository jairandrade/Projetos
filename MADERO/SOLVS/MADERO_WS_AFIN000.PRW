#include 'protheus.ch'
#include 'restful.ch'
#include "fwMVCdef.ch"

WsRestful AFIN000 Description "Servio REST para integrações FLUIG"

    WsData solicitacao as Numeric
    WsData operacao as String
    WsData chave as String

    WsMethod GET STATUS Description "Verifica status do serviço de Integrações" WSSYNTAX "/AFIN000/STATUS" PATH "/AFIN000/STATUS"
    
    WsMethod GET Description "Busca de Integrações" WSSYNTAX "/AFIN000" PATH "/AFIN000"
    WsMethod POST Description "Inclusão de integração" WSSYNTAX "/AFIN000" PATH "/AFIN000"

End WsRestful

/*/{Protheus.doc} 
Consulta status do serviço
@type function
@version 12.1.0.25
@author fabricio.reche
@since 06/07/2020
/*/
WsMethod GET STATUS WsReceive NullParam WsService AFIN000

    local oResponse := JsonObject():New()
    local aPrw := GetAPOInfo("MADERO_WS_AFIN000.prw")

    oResponse['errorMessage'] := ""
    oResponse['errorCode'] := 0
    oResponse['result'] := JsonObject():New()
    oResponse['result']['name'] := aPrw[1]
    oResponse['result']['language'] := aPrw[2]
    oResponse['result']['compilationMode'] := aPrw[3]
    oResponse['result']['lastEditedDate'] := aPrw[4]
    oResponse['result']['lastEditedHour'] := aPrw[5]

    ::SetContentType("application/json")
    ::SetResponse(oResponse:ToJson())

return .T.

/*/{Protheus.doc} 
Busca de integrações do fluig
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/07/2020
/*/
WsMethod GET WsReceive solicitacao, chave, operacao WsService AFIN000

    local oResponse := JsonObject():New()
    local _cQuery := ""
    local _cAlias := ""

    default ::chave := ""
    default ::operacao := ""
    default ::solicitacao := 0

    if Empty(::solicitacao)
        SetRestFault(1, "O Parâmetro de número de solicitação é obrigatório")
        return .F.
    endIf
    
    if Empty(::chave)
        SetRestFault(1, "O Parâmetro de chave é obrigatório")
        return .F.
    endIf
    
    oResponse['status'] := "0"
    oResponse['result'] := "NÃO LOCALIZADO"

    _cQuery += " select R_E_C_N_O_ REG " 
    _cQuery += " from " + RetSqlTab("Z27") 
    _cQuery += " where " + RetSqlCond("Z27") 
    _cQuery += "   and Z27_PROCES = " + ValToSql(::chave)
    _cQuery += "   and Z27_SOLICI = " + cValToChar(::solicitacao)
    
    if ! Empty(::operacao)
        _cQuery += "   and Z27_OPERAC = " + ValToSql(::operacao)
    endIf
    
    _cAlias := MPSysOpenQuery(_cQuery)
    
    while (_cAlias)->( ! EoF() )

        Z27->(DbGoTo( (_cAlias)->REG ))

        oResponse['status'] := Z27->Z27_STATUS
        oResponse['result'] := JsonObject():New()

        oResponse['result']:FromJson(Z27->Z27_RESPON)
    
        (_cAlias)->( DbSkip() )
    
    endDo
    
    (_cAlias)->( DbCloseArea() )

    ::SetContentType("application/json")
    ::SetResponse(oResponse:ToJson())

return .T.

/*/{Protheus.doc} 
Inclusão de integração FLUIG
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/07/2020
/*/
WsMethod POST WsReceive NullParam WsService AFIN000

    local cRet := ""
    local oModel := Nil
    local oRequest := Nil
    local oResponse := Nil
    local cConteudo := ::GetContent()

    //caso seja uma string em UTF8, faz o decode
    if DecodeUTF8(cConteudo) != Nil
        cConteudo := DecodeUTF8(cConteudo)
    endIf

    ::chave := ::GetHeader("chave")
    ::operacao := ::GetHeader("operacao")
    ::solicitacao := ::GetHeader("solicitacao")

    default ::chave := ""
    default ::operacao := ""
    default ::solicitacao := ""

    if Empty(::solicitacao)
        SetRestFault(1, "O Parâmetro de número de solicitação é obrigatório")
        return .F.
    endIf
    
    if Empty(::chave)
        SetRestFault(1, "O Parâmetro de chave é obrigatório")
        return .F.
    endIf

    if Empty(cConteudo)
        SetRestFault(1, "Não existe conteúdo informado")
        return .F.
    endIf

    oRequest := JsonObject():New()

    cRet := oRequest:FromJson(cConteudo)

    if ! Empty(cRet)
        SetRestFault(1, "Erro ao efetuar o parse do JSON: " + cRet)
        return .F.
    endIf

    oModel := FwLoadModel("MADERO_AFIN003")

    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()

    oModel:SetValue("Z27MASTER", "Z27_SOLICI", Val(::solicitacao))
    oModel:SetValue("Z27MASTER", "Z27_PROCES", ::chave)
    oModel:SetValue("Z27MASTER", "Z27_OPERAC", ::operacao)
    oModel:SetValue("Z27MASTER", "Z27_REQUES", cConteudo)

    if ! oModel:VldData()
        SetRestFault(2, formataErro(oModel:GetErrorMessage()))
        return .F.
    endIf

    oModel:CommitData()

    oResponse := JsonObject():New()

    oResponse['errorCode'] := 0
    oResponse['errorMessage'] := ""
    oResponse['result'] := "Cadastrado com suecsso!"

    ::SetContentType("application/json")
    ::SetResponse(oResponse:ToJson())

return .T.

/*/{Protheus.doc} formataErro
Formara o error message do model
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/07/2020
@param aErrorMessage, array, Array do oModel:GetErrorMessage
@return character, Mensagem formatada
/*/
static function formataErro(aErrorMessage)

    local cErrorMessage := ""

    cErrorMessage += "["
    cErrorMessage += aErrorMessage[5] + " "  //Id do erro
    cErrorMessage += aErrorMessage[4] + "] " //Nome do campo
    cErrorMessage += aErrorMessage[6] + ". " //Mensagem de erro
    cErrorMessage += aErrorMessage[7]        //Solução

return cErrorMessage
