#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

/*/
    {Protheus.doc} REST Webservice pedidovenda
    @type method
    @author Marcos
    @since 17/07/2020
    @version 1.300
    @see https://documenter.getpostman.com/view/11053018/Szzhedx7
/*/

WSRESTFUL pedidovenda DESCRIPTION "Manutencao dos Pedidos de Venda | v1.300" FORMAT "application/json"

    WSDATA tenantId As String // Formato do tenantId: Empresa,Filial
    WSDATA liberado As String // Indica se este pedido sera liberado logo em seguida

    WSMETHOD POST DESCRIPTION "Inclusao de Pedido de Venda | v1.300" WSSYNTAX "/pedidovenda" PATH "/pedidovenda" PRODUCES APPLICATION_JSON 

END WSRESTFUL

WSMETHOD POST WSSERVICE pedidovenda

    Local cBody         := ::GetContent()

    Private lOK         := .T.
    Private nStatusCode := 200
    Private nCodErro    := 000
    Private nHrIni 		:= timecounter()
    Private oReturn     := nil
    Private lLibera     := .F.

    Default ::tenantId := ''
    Default ::liberado := ''

    logWS('Inicio da execucao | v1.300')

    /*--------------------------------------------------------------------------------------*\
    | Montagem do objeto de retorno do WS                                                    |
    \*--------------------------------------------------------------------------------------*/
    oReturn := JsonObject():New()
    oReturn["resultado"] := "OK"
    oReturn["mensagem"] := "Pedido incluido com sucesso"
    oReturn["numeroPedido"] := "000000"

    /*--------------------------------------------------------------------------------------*\
    | Realiza a preparacao do ambiente de acordo com o tenantId informado                    |
    \*--------------------------------------------------------------------------------------*/
    if ! empty(::tenantId)
        trataAmbiente(::tenantId)
    else
        montaErro("Header tenantId nao foi informado", 404, 1)
    endif

    lLibera := ! empty(::liberado) .and. ::liberado == 'S'


    /*--------------------------------------------------------------------------------------*\
    | Verifica se o Body da requisicao nao esta vazio                                        |
    \*--------------------------------------------------------------------------------------*/
    if lOK .and. empty(cBody)
        montaErro("Body da requisicao esta vazio", 400, 7)
    else
        logWS('Header tenantId: ' + ::tenantId)
        logWS('Header liberado: ' + ::liberado)
        logWS('Body: ')
        logWS(cBody)
    endif


    /*--------------------------------------------------------------------------------------*\
    | Chamada da funcao que fara todo o processamento das infos recebidas                    |
    \*--------------------------------------------------------------------------------------*/
    if lOK
        incluiPedido(cBody)
    endif


    /*--------------------------------------------------------------------------------------*\
    | Define o formato de retorno e monta o mesmo de acordo com o resultado da execucao      |
    \*--------------------------------------------------------------------------------------*/
    ::SetContentType("application/json")
    
    if lOK
        ::SetResponse(oReturn:Tojson())
    else
        logWS(oReturn["mensagem"])
        SetRestFault(nCodErro,oReturn["mensagem"],.T.,nStatusCode)
    endif

    FreeObj(oReturn)
    
Return lOK

/*/
    {Protheus.doc} incluiPedido
    @type  Static Function
    @author Marcos Felipe Xavier
    @since 10/07/2020
    @version 1.0.1
    @param cJson, character, JSON recebido no body da requisicao
/*/
Static Function incluiPedido(cJson)

    //Local aConv     := {}
    Local aJson     := {}
    Local aCabc     := {}
    Local aItem     := {}
    Local aItens    := {}
    Local aVld      := {}
    
    Local cRaiz     := ''
    Local cMsgCli   := ''
    Local cUnMed    := ''
    Local cItemPV   := '00'

    Local nP        := 0
    
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
    aVld := U_WSK0001(oDados,'pedidovenda')
    lOK := aVld[1]

    /*--------------------------------------------------------------------------------------*\
    | Valida os campos obrigatorios que sao necessarios para a inclusao                      |
    \*--------------------------------------------------------------------------------------*/
    if lOK
        DbSelectArea("SA1")
        SA1->(DbSetOrder(1))
        if SA1->(DbSeek(xFilial("SA1")+oDados["codigo_cliente"]+oDados["loja_cliente"]))
            cCodigoCliente := SA1->A1_COD
            cLojaCliente := SA1->A1_LOJA
            cMsgCli := SA1->A1_MSGPED
        else
            montaErro("Codigo e Loja informados nao encontrados na base de dados",400,20) 
        endif


        if select('Z08A') > 0
            Z08A->(DbCloseArea())
        endif

        BEGINSQL ALIAS 'Z08A'
            SELECT
                Z09.Z09_ATIVO,
                Z08.* 
            FROM %TABLE:Z09% Z09
                INNER JOIN %TABLE:Z08% Z08
                ON Z09.Z09_FILIAL = Z08.Z08_FILIAL
                AND Z09.Z09_CODIGO = Z08.Z08_CODIGO
                AND Z08.%NOTDEL%
            WHERE Z09.%NOTDEL%
                AND Z09.Z09_FILIAL = %xFilial:Z09%
                AND LOWER(Z09.Z09_NOME) = 'pedidovenda'
            ORDER BY Z08.Z08_CODIGO
        ENDSQL
        
        while ! Z08A->(EoF())

            Do Case
            Case Z08A->Z08_TPATRI = 'A'
                cRaiz := alltrim(Z08A->Z08_CAMPO) + '.'
                Z08A->(DbSkip())
                LOOP

            Case cRaiz $ alltrim(Z08A->Z08_CAMPO)
                Z08A->(DbSkip())
                LOOP
            
            Case Z08A->Z08_ORIGEM = 'E'
                aAdd(aCabc,{alltrim(Z08A->Z08_DESTIN),alltrim(Z08A->Z08_INFO),nil})
            
            Case Z08A->Z08_ORIGEM = 'A' .and. Z08A->Z08_OBRIG = 'N'
                if ascan(aJson,alltrim(Z08A->Z08_CAMPO)) > 0 .and. ! empty(oDados[alltrim(Z08A->Z08_CAMPO)])
                    aAdd(aCabc,{alltrim(Z08A->Z08_DESTIN),oDados[alltrim(Z08A->Z08_CAMPO)],nil})
                endif
            Case Z08A->Z08_ORIGEM = 'A' .and. Z08A->Z08_OBRIG = 'S' .and. ! empty(Z08A->Z08_DESTIN)
                aAdd(aCabc,{alltrim(Z08A->Z08_DESTIN),oDados[alltrim(Z08A->Z08_CAMPO)],nil})
            EndCase

            Z08A->(DbSkip())
        end


        aCabc := FWVetByDic( aCabc, 'SC5' )


        /*--------------------------------------------------------------------------------------*\
        | Monta os itens/produtos a serem incluidos no pedido de venda                           |
        \*--------------------------------------------------------------------------------------*/
        for nP := 1 to len(oDados["produtos"])
            aItem := {}
            aProd := oDados["produtos"][nP]:GetNames()
            cItemPV := soma1(cItemPV)
            
            //for nI := 1 to len(aProd)
                if select('Z08A') > 0
                    Z08A->(DbCloseArea())
                endif

                BEGINSQL ALIAS 'Z08A'
                    SELECT
                        Z09.Z09_ATIVO,
                        Z08.* 
                    FROM %TABLE:Z09% Z09
                        INNER JOIN %TABLE:Z08% Z08
                        ON Z09.Z09_FILIAL = Z08.Z08_FILIAL
                        AND Z09.Z09_CODIGO = Z08.Z08_CODIGO
                        AND Z08.%NOTDEL%
                    WHERE Z09.%NOTDEL%
                        AND Z09.Z09_FILIAL = %xFilial:Z09%
                        AND LOWER(Z09.Z09_NOME) = 'pedidovenda'
                        AND Z08_CAMPO LIKE '%produtos.%'
                    ORDER BY Z08.Z08_CODIGO
                ENDSQL
                
                while ! Z08A->(EoF())

                    Do Case
                    Case alltrim(Z08A->Z08_CAMPO) == 'produtos.quantidade'
                        cUnMed := Posicione('SB1', 1, xFilial('SB1') + odados["produtos"][nP]['codigo_produto'], 'B1_UM')
                        if cUnMed == 'M2'
                            aAdd(aItem,{'C6_XQTDPC',odados["produtos"][nP]['quantidade'],nil})  
                        else
                            aAdd(aItem,{'C6_QTDVEN',odados["produtos"][nP]['quantidade'],nil})  
                        endif


                    Case Z08A->Z08_ORIGEM = 'E'
                        aAdd(aItem,{alltrim(Z08A->Z08_DESTIN),alltrim(Z08A->Z08_INFO),nil})
                    
                    Case Z08A->Z08_ORIGEM = 'A' .and. Z08A->Z08_OBRIG = 'N'
                        if ascan(aProd,alltrim(strtran(Z08A->Z08_CAMPO,'produtos.'))) > 0 .and. ! empty(oDados["produtos"][nP][alltrim(strtran(Z08A->Z08_CAMPO,'produtos.'))])
                            aAdd(aItem,{alltrim(Z08A->Z08_DESTIN),oDados["produtos"][nP][alltrim(strtran(Z08A->Z08_CAMPO,'produtos.'))],nil})
                        endif
                    Case Z08A->Z08_ORIGEM = 'A' .and. Z08A->Z08_OBRIG = 'S'
                        aAdd(aItem,{alltrim(Z08A->Z08_DESTIN),oDados["produtos"][nP][alltrim(strtran(Z08A->Z08_CAMPO,'produtos.'))],nil})
                    EndCase

                    Z08A->(DbSkip())
                end


                // Do Case
                // Case empty(odados["produtos"][nP][aProd[nI]])
                //     loop
                // Case aProd[nI] == 'quantidade'
                //     cUnMed := Posicione('SB1', 1, xFilial('SB1') + odados["produtos"][nP]['C6_PRODUTO'], 'B1_UM')
                //     if cUnMed == 'M2'
                //         aAdd(aItem,{'C6_XQTDPC',odados["produtos"][nP][aProd[nI]],nil})  
                //     else
                //         aAdd(aItem,{'C6_QTDVEN',odados["produtos"][nP][aProd[nI]],nil})  
                //     endif 
                // Otherwise
                //     aAdd(aItem,{aProd[nI],odados["produtos"][nP][aProd[nI]],nil})     
                // EndCase
                //next
            
            aAdd(aItem,{'C6_OPER',oDados['operacao'],nil}) 
            aAdd(aItem,{'C6_ITEM',cItemPV,nil}) 

            aItem := FWVetByDic( aItem, 'SC6' )

            aAdd(aItens,aItem)
        next


        MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabc,aItens,3) //-> 3=Inclusao; 4=Alteracao; 5=Exclusao

        if lMsErroAuto
            montaErro(mostraerro("/logs","pedidovenda" + strtran(time(),':') + ".log"),400,21)
        else
            oReturn["mensagem"] += ' | Tempo gasto: ' + Tgasto()
            oReturn["numeroPedido"] := SC5->C5_NUM  

            if lLibera

                INCLUI := .F.
                ALTERA := .T.
                lSugere := .T.
                lTransf := .F.
                lLiber := .F.

               A440Libera('SC5',SC5->(RECNO()),4,.T.)

            endif
        endif
    else

        montaErro(aVld[2],400,15) 

    endif
    
Return


/*/
    {Protheus.doc} trataAmbiente
    @type  Static Function
    @author Marcos Felipe Xavier
    @since 10/07/2020
    @version 1.0.1
    @param cTenantId, character, Header tenantId recebido na requisicao
/*/
Static Function trataAmbiente(cTenantId)

    Local cEmpK := ''
    Local cFilK := ''

    logWS('trataAmbiente()')

    /*--------------------------------------------------------------------------------------*\
    | Sempre prepara em uma empresa e filial fixas, apenas pra realizar as validacões na SM0 |
    | caso a empresa e filial recebidas sejam validas, faz uma nova prepacao nelas           |
    \*--------------------------------------------------------------------------------------*/
    //if select("SX6") == 0
    RpcClearEnv()
    RPCSetType(3)
    RpcSetEnv('04','01')
    logWS('Primeira preparacao de ambiente. Empresa: ' + cEmpAnt + ' / Filial: ' + cFilAnt)
    //endif
   
    /*--------------------------------------------------------------------------------------*\
    | Realiza as validacoes de empresa e filial                                              |
    \*--------------------------------------------------------------------------------------*/
    cEmpK := alltrim(substr(cTenantId,1,at(',',cTenantId)-1))
    cFilK := alltrim(substr(cTenantId,at(',',cTenantId)+1))

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

Return


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
    lOK := .F.
    
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

    conout('[pedidovenda] ' + cDtHr + ' : ' + cMsgLog)
    
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

/*------------------------------------------------------------------*\
| JSON ESPERADO                                                      |
           
    {
        "C5_CLIENTE": "098123",
        "C5_LOJACLI": "01",
        "C5_VEND1": "000706",
        "C5_CONDPAG": "001",
        "C5_FECENT": "20200801",
        "C5_K_OPER": "01",
        "C5_XPEDCLI": "",
        "C5_XTPPED": "",
        "C5_REDESP": "",
        "C5_TABELA": "",
        "C5_TPFRETE": "",
        "C5_TRANSP": "",
        "C5_MSGCLI": "",
        "C5_MSGNOTA": "",
        "C5_IDDW": "",
        "C5_FRETE": 0.00,
        "produtos": [
            {
                "C6_PRCVEN": 0.0000,
                "C6_PRODUTO": "",
                "C6_QTDVEN": 0.0000,
                "C6_VALDESC": 0.0000,
                "C6_DESCONT": 0.0000,
                "C6_XLARG": 0.00,
                "C6_XCOMPRI": 0.00000,
                "C6_XQTDPC": 0.0000
            },
            .
            .
            .
        ]
    }

\*------------------------------------------------------------------*/

