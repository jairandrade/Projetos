#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

/*/
    {Protheus.doc} REST Webservice ordemproducao
    @type method
    @author Marcos
    @since 17/07/2020
    @version 1.090
    @see https://documenter.getpostman.com/view/11053018/Szzhedx7
/*/

WSRESTFUL ordemproducao DESCRIPTION "Manutencao das Ordens de Producao | v1.090" FORMAT "application/json"

    WSDATA tenantId As String // Formato do tenantId: Empresa,Filial

    WSMETHOD POST DESCRIPTION "Inclusao de OP | v1.090" WSSYNTAX "/ordemproducao" PATH "/ordemproducao" PRODUCES APPLICATION_JSON 

END WSRESTFUL

WSMETHOD POST WSSERVICE ordemproducao

    Local cBody     := ::GetContent()
    Local cTenantId := ''
    Local cEmpK     := ''
    Local cFilK     := ''


    Private lOK         := .T.
    Private nStatusCode := 200
    Private nCodErro    := 000
    Private nHrIni 		:= timecounter()
    Private oReturn     := nil

    Default ::tenantId := ''

    logWS('Inicio da execucao | v1.090')

    /*--------------------------------------------------------------------------------------*\
    | Sempre prepara em uma empresa e filial fixas, apenas pra realizar as validações na SM0 |
    | caso a empresa e filial recebidas sejam válidas, faz uma nova prepação nelas           |
    \*--------------------------------------------------------------------------------------*/
    // if select("SX6") == 0
    RpcClearEnv()
    RPCSetType(3)
    RpcSetEnv('04','01')
    logWS('Primeira preparacao de ambiente. Empresa: ' + cEmpAnt + ' / Filial: ' + cFilAnt)
    // endif

   
    /*--------------------------------------------------------------------------------------*\
    | Montagem do objeto de retorno do WS                                                    |
    \*--------------------------------------------------------------------------------------*/
    oReturn := JsonObject():New()
    oReturn["resultado"] := "OK"
    oReturn["mensagem"] := "Pedido incluido com sucesso"
    oReturn["listaOPs"] := {}


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
            logWS('Segunda preparacao de ambiente. Empresa: ' + cEmpAnt + ' / Filial: ' + cFilAnt)
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
        U_INCOP(cBody)
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

/*/{Protheus.doc} User Function INCPV
    (long_description)
    @type  Function
    @author user
    @since 17/07/2020
    @version v1.090
    /*/
User Function INCOP(cJson)

    //Local aConv     := {}
    Local aJson     := {}
    Local aCabc     := {}

    Local cPedido   := ''

    Local nQtd      := 0


    // Local aItem     := {}
    // Local aItens    := {}

    // Local cOperac   := ''
    // Local cMsgCli   := ''
    // Local cUnMed    := ''
    // Local cItemPV   := '00'

    // Local nP        := 0
    // Local nI        := 0
    // Local nDias     := 0
    
    Local oDados    := nil

    Private lMsErroAuto := .F.
        
    /*--------------------------------------------------------------------------------------*\
    | Monta o objeto Json com base no Body da reuisicao e busca todos os atributos recebidos |
    \*--------------------------------------------------------------------------------------*/
    oDados := JsonObject():New()
    oDados:FromJson(cJson)
    aJson := oDados:GetNames()

    /*--------------------------------------------------------------------------------------*\
    | Valida os campos obrigatorios que sao necessarios para a inclusao                      |
    \*--------------------------------------------------------------------------------------*/
    Do Case
    Case ascan(aJson,"pedidoVenda") == 0
        montaErro("O atributo pedidoVenda é obrigatorio",400,8)    
    
    EndCase

    /*--------------------------------------------------------------------------------------*\
    | Valida se o Pedido de Venda informado existe no Protheus                               |
    \*--------------------------------------------------------------------------------------*/
    if lOK
        DbSelectArea("SC5")
        SC5->(DbSetOrder(1))
        if ! SC5->(DbSeek(xFilial("SC5") + oDados["pedidoVenda"]))
            montaErro("Numero do Pedido de Vendas informado (" + oDados["pedidoVenda"] + ") nao foi encontrado na base de dados",400,20) 
        else
            cPedido := oDados["pedidoVenda"]
        endif
    endif

    if lOK

        begin transaction

        if select("TSC6A") > 0
            TSC6A->(DbCloseArea())
        endif

        BEGINSQL ALIAS "TSC6A"
            SELECT * FROM %TABLE:SC6%
            WHERE %NOTDEL%
            AND C6_FILIAL = %XFILIAL:SC6%
            AND C6_NUM = %EXP:cPedido%
            ORDER BY C6_ITEM ASC
        ENDSQL

        while ! TSC6A->(EoF())

            aCabc  := { {'C2_FILIAL'    , xFilial("SC2")        ,NIL},;         
                        {'C2_NUM'       , TSC6A->(C6_NUM)       ,'.T.'},;          
                        {'C2_ITEM'      , TSC6A->(C6_ITEM)      ,'.T.'},;     
                        {'C2_SEQUEN'    , "001"                 ,'.T.'},;  
                        {'C2_PRODUTO'   , alltrim(TSC6A->(C6_PRODUTO))   ,NIL},;     
                        {'C2_PEDIDO'    , TSC6A->(C6_NUM)       ,NIL},;
                        {"C2_ITEMPV"    , TSC6A->(C6_ITEM)      ,NIL},;  
                        {"C2_QUANT"     , TSC6A->(C6_QTDVEN)    ,NIL},;  
                        {"C2_STATUS"    , 'N'                   ,NIL},;  
                        {"C2_LOCAL"     , '04'                  ,NIL},;  
                        {"C2_CC"        , '430010017'           ,NIL},;  
                        {"C2_PRIOR"     , '500'                 ,NIL},;  
                        {"C2_DATPRI"    , DDATABASE             ,NIL},;  
                        {"C2_DATPRF"    , DDATABASE + 10        ,NIL},;  
                        {'AUTEXPLODE'   , "S"                   ,NIL}}       
                 
            msExecAuto({|x,Y| Mata650(x,Y)},aCabc,3)

            if lMsErroAuto
                montaErro(mostraerro("/logs","ordemproducao" + strtran(time(),':') + ".log"),400,21)
                DisarmTransaction()
                Break
            else
                oReturn["resultado"] := "OK"
                oReturn["mensagem"] += ' | Tempo gasto: ' + Tgasto()
                
                AADD(oReturn["listaOPs"], JsonObject():New())
                nQtd := len(oReturn["listaOPs"])
                oReturn["listaOPs"][nQtd]["item"] := TSC6A->(C6_XITEMEX)
                oReturn["listaOPs"][nQtd]["opGerada"] := TSC6A->(C6_NUM)
            endif

            TSC6A->(DbSkip())
        end

        end transaction
    endif
    
Return


/*/{Protheus.doc} montaErro()
    @type  Static Function
    @description Preenche objeto de retorno e 'seta' variaveis de controle
    @author Marcos Felipe Xavier
    @since 31/08/2020
/*/
Static Function montaErro(cMensagem, nHTTPCod, nCodWS)

    oReturn["resultado"] := "ERRO"
    oReturn["mensagem"] := encodeUTF8(cMensagem + ' | Tempo gasto: ' + Tgasto())
    oReturn["listaOPs"] := {}
    
    nStatusCode := nHTTPCod
    nCodErro    := nCodWS
    lOK := .F.
    
return


/*/{Protheus.doc} logWS()
    @type  Static Function
    @description Define um log padrao a ser impresso no console
    @author Marcos Felipe Xavier
    @since 31/08/2020
/*/
Static Function logWS(cMsgLog)

    Local cDtHr := dtos(date()) + ' ' + time()

    conout('[ordemproducao] ' + cDtHr + ' : ' + cMsgLog)
    
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
