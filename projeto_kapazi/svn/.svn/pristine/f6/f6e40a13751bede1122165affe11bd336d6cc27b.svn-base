#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} Webservice - AnalisaCredito
    @type  Function
    @author Marcos
    @since 11/06/2020
    @version 1.0.1
    @description Webservice utilizado pelo sistema de vendas mobile para Análise de Crédito
/*/
WSRESTFUL AnalisaCredito DESCRIPTION "Analisa Credito do cliente recebido | v1.0.1"

    WSDATA codigoCliente    AS CHARACTER
    WSDATA lojaCliente      AS CHARACTER
    WSDATA valor            AS FLOAT

    WSMETHOD PUT DESCRIPTION "Analisa Credito do cliente recebido" WSSYNTAX "AnalisaCredito/"

END WSRESTFUL

WSMETHOD PUT WSRECEIVE codigoCliente, lojaCliente, valor WSSERVICE AnalisaCredito

    Local aReturn := {}
    Local lResult := .T.
    Local cMsgErr := ""
    Local oReturn := JsonObject():New()

    ::SetContentType("application/json") // Define que o retorno deste WS sera no formato JSON

    /*-----------------------------------------------------------*\
    | Verifica se foram enviados os Headers para a requisicao    |
    \*-----------------------------------------------------------*/
    DO CASE
        CASE EMPTY(::codigoCliente)
            lResult := .F.
            cMsgErr := "O parametro codigoCliente nao foi informado no header da requisicao."

        CASE EMPTY(::lojaCliente)
            lResult := .F.
            cMsgErr := "O parametro lojaCliente nao foi informado no header da requisicao."

        CASE EMPTY(::valor)
            lResult := .F.
            cMsgErr := "O parametro valor nao foi informado no header da requisicao."
    ENDCASE

    /*-----------------------------------------------------------*\
    | Somente chama a funcao de recalculos caso esteja OK         |
    \*-----------------------------------------------------------*/
    if lResult
        aReturn := U_GetCredCli(::codigoCliente, ::lojaCliente, ::valor)

        oReturn["Resultado"] := aReturn[1]
        oReturn["Mensagem"]  := EncodeUTF8(aReturn[2])        

        ::SetResponse(oReturn:ToJson())
    else
        SetRestFault(400,cMsgErr)  
    endif

Return lResult
