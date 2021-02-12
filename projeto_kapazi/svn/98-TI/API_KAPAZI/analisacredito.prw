#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

/*/
    {Protheus.doc} Webservice - analisacredito
    @type  Function
    @author Marcos
    @since 11/06/2020
    @version 1.120
    @description Webservice utilizado pelo sistema de vendas mobile para An�lise de Cr�dito
    @see https://documenter.getpostman.com/view/11053018/Szzhedx7
/*/
WSRESTFUL analisacredito DESCRIPTION "Analisa Credito do cliente recebido | v1.120"

    WSDATA codigoCliente    AS CHARACTER
    WSDATA lojaCliente      AS CHARACTER
    WSDATA valor            AS FLOAT
    WSDATA tenantId         As String // Formato do tenantId: Empresa,Filial

    WSMETHOD PUT DESCRIPTION "Analisa Credito do cliente recebido" WSSYNTAX "analisacredito/"

END WSRESTFUL

WSMETHOD PUT WSRECEIVE codigoCliente, lojaCliente, valor WSSERVICE analisacredito

    Local aReturn := {}
    Local lResult := .T.
    Local cMsgErr := ""
    Local cTenantId := ''
    Local oReturn := JsonObject():New()

    Default ::tenantId := ''


    logWS('Inicio da execucao')


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


    /*--------------------------------------------------------------------------------------*\
    | Sempre prepara em uma empresa e filial fixas, apenas pra realizar as validações na SM0 |
    | caso a empresa e filial recebidas sejam válidas, faz uma nova prepação nelas           |
    \*--------------------------------------------------------------------------------------*/
    RpcClearEnv()
    RPCSetType(3)
    RpcSetEnv('04','01')

   
    /*--------------------------------------------------------------------------------------*\
    | Realiza as validacoes de empresa e filial                                              |
    \*--------------------------------------------------------------------------------------*/
    cTenantId := ::tenantId

    if empty(cTenantId)
        lResult := .F.
        cMsgErr := "Header tenantId nao foi informado"
    else
        cEmpK := alltrim(substr(::tenantId,1,at(',',::tenantId)-1))
        cFilK := alltrim(substr(::tenantId,at(',',::tenantId)+1))

        Do Case
            Case empty(cEmpK)
                lResult := .F.
                cMsgErr :="Header tenantId enviado no formato incorreto"

            Case empty(cFilK)
                lResult := .F.
                cMsgErr :="Header tenantId enviado no formato incorreto"

            Case len(cEmpK) <> len(alltrim(cEmpAnt))
                lResult := .F.
                cMsgErr :="Header tenantId enviado no formato incorreto"

            Case len(cFilK) <> len(alltrim(cFilAnt))
                lResult := .F.
                cMsgErr :="Header tenantId enviado no formato incorreto"

        EndCase
    endif


    /*--------------------------------------------------------------------------------------*\
    | Realiza a alteracao de empresa e filial, caso necessario                               |
    \*--------------------------------------------------------------------------------------*/
    if lResult .and. (cEmpK <> '04' .or. cFilK <> '01')
        if !ExistCpo("SM0", cEmpK + cFilK)
            lResult := .F.
            cMsgErr := "Empresa/Filial recebidas nao encontradas no sistema. Verificar header tenantId."
        else
            RpcClearEnv()
            RPCSetType(3)
            RpcSetEnv(cEmpK,cFilK)
        endif
    endif



    /*-----------------------------------------------------------*\
    | Somente chama a funcao de recalculos caso esteja OK         |
    \*-----------------------------------------------------------*/
    ::SetContentType("application/json") // Define que o retorno deste WS sera no formato JSON

    if lResult
        aReturn := U_GetCredCli(::codigoCliente, ::lojaCliente, ::valor)

        oReturn["Resultado"] := aReturn[1]
        oReturn["Mensagem"]  := EncodeUTF8(aReturn[2])   

        logWS( oReturn["Mensagem"] )

        ::SetResponse(oReturn:ToJson())
    else
        logWS(cMsgErr)
        SetRestFault(400,cMsgErr)  
    endif

Return lResult


Static Function logWS(cMsgLog)

    Local cDtHr := dtos(date()) + ' ' + time()

    conout('[analisacredito] ' + cDtHr + ' : ' + cMsgLog)
    
Return
