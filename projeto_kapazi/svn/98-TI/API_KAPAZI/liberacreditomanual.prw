#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

/*/
    {Protheus.doc} REST Webservice liberacreditomanual
    @type method
    @author Marcos
    @since 17/07/2020
    @version 1.040
    @see https://documenter.getpostman.com/view/11053018/Szzhedx7
/*/

WSRESTFUL liberacreditomanual DESCRIPTION "Liberacao de Credito Manual | v1.040" FORMAT "application/json"

    WSDATA tenantId As String // Formato do tenantId: Empresa,Filial

    WSMETHOD POST DESCRIPTION "Liberacao de Credito Manual | v1.040" WSSYNTAX "/liberacreditomanual" PATH "/liberacreditomanual" PRODUCES APPLICATION_JSON 

END WSRESTFUL

WSMETHOD POST WSSERVICE liberacreditomanual 

    Local cBody     := ::GetContent()
    Local cTenantId := ''
    Local cEmpK     := ''
    Local cFilK     := ''
    Local oDados    := NIL


    Private lOK         := .T.
    Private nStatusCode := 200
    Private nCodErro    := 000
    Private nHrIni 		:= timecounter()
    Private oReturn     := nil

    Default ::tenantId := ''

    logWS('Inicio da execucao | v1.040')

    /*--------------------------------------------------------------------------------------*\
    | Montagem do objeto de retorno do WS                                                    |
    \*--------------------------------------------------------------------------------------*/
    oReturn := JsonObject():New()
    oReturn["resultado"] := "OK"
    oReturn["mensagem"] := "Credito liberado"
    // oReturn["listaOPs"] := {}

    /*--------------------------------------------------------------------------------------*\
    | Sempre prepara em uma empresa e filial fixas, apenas pra realizar as validações na SM0 |
    | caso a empresa e filial recebidas sejam válidas, faz uma nova prepação nelas           |
    \*--------------------------------------------------------------------------------------*/
    // if select("SX6") == 0
    RpcClearEnv()
    RPCSetType(3)
    RpcSetEnv('04','01')
    // endif

   
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
        EndCase
    endif


    /*--------------------------------------------------------------------------------------*\
    | Realiza a alteracao de empresa e filial, caso necessario                               |
    \*--------------------------------------------------------------------------------------*/
    if lOK .and. (cEmpK <> '04' .or. cFilK <> '01')
        if !ExistCpo("SM0", cEmpK + cFilK)
            montaErro("Empresa/Filial recebidas nao encontradas no sistema. Verificar header tenantId.", 404, 6)
        else
            RpcClearEnv()
            RPCSetType(3)
            RpcSetEnv(cEmpK,cFilK)
        endif
    endif


    /*--------------------------------------------------------------------------------------*\
    | Verifica se o Body da requisicao nao esta vazio                                        |
    \*--------------------------------------------------------------------------------------*/
    if lOK .and. empty(cBody)
        montaErro("Body da requisicao esta vazio", 400, 7)
    else
        logWS(cBody)
    endif
    

    /*--------------------------------------------------------------------------------------*\
    | Chamada da função que fará todo o processamento das infos recebidas                    |
    \*--------------------------------------------------------------------------------------*/
    if lOK

        oDados := JsonObject():New()
        oDados:FromJson(cBody)
        
		StaticCall(M440STTS,LibCred,oDados["pedidoVenda"])

        FreeObj(oDados)


    endif


    /*--------------------------------------------------------------------------------------*\
    | Define o formato de retorno e monta o mesmo de acordo com o resultado da execucao      |
    \*--------------------------------------------------------------------------------------*/
    ::SetContentType("application/json")
    
    if lOK
        ::SetResponse(oReturn:Tojson())
    else
        SetRestFault(nCodErro,oReturn["mensagem"],.T.,nStatusCode)
    endif

    logWS(oReturn["mensagem"])
    FreeObj(oReturn)
    
Return lOK


Static Function logWS(cMsgLog)

    Local cDtHr := dtos(date()) + ' ' + time()

    conout('[liberacreditomanual] ' + cDtHr + ' : ' + cMsgLog)
    
return



/*/{Protheus.doc} montaErro()
    @type  Static Function
    @description Preenche objeto de retorno e 'seta' variaveis de controle
    @author Marcos Felipe Xavier
    @since 31/08/2020
/*/
Static Function montaErro(cMensagem, nHTTPCod, nCodWS)

    oReturn["resultado"] := "ERRO"
    oReturn["mensagem"] := encodeUTF8(cMensagem + ' | Tempo gasto: ' + Tgasto())
    // oReturn["listaOPs"] := {}
    
    nStatusCode := nHTTPCod
    nCodErro    := nCodWS
    lOK := .F.
    
return
/*/{Protheus.doc} Tgasto()
    @type  Static Function
    @description Calcula o tempo gasto para execucao do WS
    @author Marcos Felipe Xavier
    @since 31/08/2020
/*/
Static Function Tgasto()

    Local cDiff := ''
    Local cElapsed := ''

    cDiff := cvaltochar(timecounter() - nHrIni)
    cElapsed := substr(cDiff,1,at('.',cDiff)+3) + 'ms'

return cElapsed
