#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

/*/
    {Protheus.doc} REST Webservice acompanhapedido
    @type method
    @author Marcos
    @since 17/07/2020
    @version 1.0.1
    @see https://documenter.getpostman.com/view/11053018/Szzhedx7
/*/

WSRESTFUL acompanhapedido DESCRIPTION "Acompanhamento dos pedidos dos clientes | v1.0.1"

    WSDATA tenantId As String // Formato do tenantId: Empresa,Filial
    WSDATA cliente  As String // Formato do tenantId: Empresa,Filial
    WSDATA pedido   As String // Formato do tenantId: Empresa,Filial

    WSMETHOD GET DESCRIPTION "Acompanhamento dos pedidos dos clientes | v1.0.1" WSSYNTAX "/acompanhapedido" PATH "/acompanhapedido" PRODUCES APPLICATION_JSON 

END WSRESTFUL

WSMETHOD GET QUERYPARAM cliente,pedido WSSERVICE acompanhapedido

    Local cCliente  := ::cliente
    Local cPedido   := ::pedido
    Local cTenantId := ''
    Local cEmpK     := ''
    Local cFilK     := ''


    Private lOK         := .T.
    Private nStatusCode := 200
    Private nCodErro    := 000
    Private nHrIni 		:= timecounter()
    Private oReturn     := nil

    Default ::tenantId := ''

    logWS('Inicio da execucao')

    /*--------------------------------------------------------------------------------------*\
    | Sempre prepara em uma empresa e filial fixas, apenas pra realizar as valida√ß√µes na SM0 |
    | caso a empresa e filial recebidas sejam v√°lidas, faz uma nova prepa√ß√£o nelas           |
    \*--------------------------------------------------------------------------------------*/
    if select("SX6") == 0
        RPCSetType(3)
        RpcSetEnv('04','01')
    endif

   
    /*--------------------------------------------------------------------------------------*\
    | Montagem do objeto de retorno do WS                                                    |
    \*--------------------------------------------------------------------------------------*/
    oReturn := JsonObject():New()
    oReturn["processado"] := .T.
    oReturn["despachado"] := .T.
    oReturn["transito"] := .T.
    oReturn["entregue"] := .T.


    /*--------------------------------------------------------------------------------------*\
    | Realiza as validacoes de empresa e filial                                              |
    \*--------------------------------------------------------------------------------------*/
    cTenantId := ::tenantId

    if empty(cTenantId)
        montaErro("Header tenantId nao foi informado", 404, 1)
    else
        cEmpK := alltrim(substr(::tenantId,1,at(',',::tenantId)-1))
        cFilK := alltrim(substr(::tenantId,at(',',::tenantId)+1))

        Do Case
            Case empty(cEmpK)
                montaErro("Header tenantId enviado no formato incorreto", 400, 2)
            Case empty(cFilK)
                montaErro("Header tenantId enviado no formato incorreto", 400, 3)
            Case len(cEmpK) <> len(alltrim(cEmpAnt))
                montaErro("Header tenantId enviado no formato incorreto", 400, 4)
            Case len(cFilK) <> len(alltrim(cFilAnt))
                montaErro("Header tenantId enviado no formato incorreto", 400, 5)
            Case empty(cCliente)
                montaErro("CÛdigo do cliente n„o informado", 404, 6)
            Case empty(cPedido) 
                montaErro("Numero do pedido n„o informado", 404, 7)
        EndCase
    endif


    /*--------------------------------------------------------------------------------------*\
    | Realiza a alteracao de empresa e filial, caso necessario                               |
    \*--------------------------------------------------------------------------------------*/
    if lOK .and. (cEmpK <> '04' .or. cFilK <> '01')
        if !ExistCpo("SM0", cEmpK + cFilK)
            montaErro("Empresa/Filial recebidas nao encontradas no sistema. Verificar header tenantId.", 404, 8)
        else
            RpcClearEnv()
            RPCSetType(3)
            RpcSetEnv(cEmpK,cFilK)
        endif
    endif


    /*--------------------------------------------------------------------------------------*\
    | Chamada da funÁ„o que far· todo o processamento das infos recebidas                    |
    \*--------------------------------------------------------------------------------------*/
    if lOK
        consultastatus(cCliente, cPedido)
    endif


    /*--------------------------------------------------------------------------------------*\
    | Define o formato de retorno e monta o mesmo de acordo com o resultado da execucao      |
    \*--------------------------------------------------------------------------------------*/
    ::SetContentType("application/json")
    
    if lOK
        ::SetResponse(oReturn:Tojson())
        logWS(" - - SUCESSO!! - - ")
    else
        SetRestFault(nCodErro,oReturn["mensagem"],.T.,nStatusCode)
        logWS(oReturn["mensagem"])
    endif

    FreeObj(oReturn)
    
Return lOK

/*/{Protheus.doc} User Function INCPV
    (long_description)
    @type  Function
    @author user
    @since 17/07/2020
    @version v1.0.1
    /*/
// Static Function consultastatus(cCodCli, cNumPed)


//     BEGINSQL ALIAS 

    
// Return

/*/{Protheus.doc} montaErro
    (long_description)
    @type  Static Function
    @author Marcos Felipe Xavier
    @since 10/07/2020
    @version 1.0.1
    @param cMensagem, character, Mensagem de erro.
    @param nHTTPCod, numeric, Codigo HTTP de status da requisicao
    @param nCodWS, numeric, Codigo proprio de erro para controle de mensagens e localizacao do erro
    @param param_name, param_type, param_descr
    /*/
Static Function montaErro(cMensagem, nHTTPCod, nCodWS)

    /*---------------------------------------------------------------*\
    | Preenche objeto de retorno e 'seta' variaveis de controle       |
    \*---------------------------------------------------------------*/
    oReturn["resultado"] := "ERRO"
    oReturn["mensagem"] := encodeUTF8(cMensagem + ' | Tempo gasto: ' + Tgasto())
    oReturn["numeroPedido"] := ""
    
    nStatusCode := nHTTPCod
    nCodErro    := nCodWS
    lOK         := .F.
    
Return

/*/{Protheus.doc} logWS
    (long_description)
    @type  Static Function
    @author user
    @since 31/08/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function logWS(cMsgLog)

    Local cDtHr := dtos(date()) + ' ' + time()

    conout('[acompanhapedido] ' + cDtHr + ' : ' + cMsgLog)
    
Return
/*/{Protheus.doc} Tgasto
    (long_description)
    @type  Static Function
    @author user
    @since 31/08/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function Tgasto()

    Local cDiff := ''
    Local cElapsed := ''

    cDiff := cvaltochar(timecounter() - nHrIni)
    cElapsed := substr(cDiff,1,at('.',cDiff)+3) + 'ms'

return cElapsed
