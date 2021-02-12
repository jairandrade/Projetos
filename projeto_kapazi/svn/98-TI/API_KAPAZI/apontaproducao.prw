#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

/*/
    {Protheus.doc} REST Webservice apontaproducao
    @type method
    @author Marcos
    @since 17/07/2020
    @version 1.150
    @see https://documenter.getpostman.com/view/11053018/Szzhedx7
/*/

WSRESTFUL apontaproducao DESCRIPTION "Apontamento das Ordens de Producao | v1.050" FORMAT "application/json"

    WSDATA tenantId As String // Formato do tenantId: Empresa,Filial

    WSMETHOD POST DESCRIPTION "Apontamento de OP | v1.150" WSSYNTAX "/apontaproducao" PATH "/apontaproducao" PRODUCES APPLICATION_JSON 

END WSRESTFUL

WSMETHOD POST WSSERVICE apontaproducao 

    Local cBody     := ::GetContent()
    Local aJson     := {}
    Local cTenantId := ''
    Local cEmpK     := ''
    Local cFilK     := ''
    
    Local lPedLib   := .T.

    Private lOK         := .T.
    Private nStatusCode := 200
    Private nCodErro    := 000
    Private nHrIni 		:= timecounter()
    Private oReturn     := nil
    Private oDados      := nil

    Default ::tenantId := ''

    logWS('Inicio da execucao | v1.050')

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
    oReturn["mensagem"] := "OP apontada com sucesso"
    // oReturn["listaOPs"] := {}


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
    | Monta o objeto Json com base no Body da reuisicao e busca todos os atributos recebidos |
    \*--------------------------------------------------------------------------------------*/
    oDados := JsonObject():New()
    oDados:FromJson(cBody)
    aJson := oDados:GetNames()

    /*--------------------------------------------------------------------------------------*\
    | Valida os campos obrigatorios que sao necessarios para a inclusao                      |
    \*--------------------------------------------------------------------------------------*/
    Do Case
    Case ascan(aJson,"numeroOP") == 0
        montaErro("O atributo numeroOP � obrigatorio",400,8) 

    Case ascan(aJson,"itemOP") == 0
        montaErro("O atributo itemOP � obrigatorio",400,8)    
    EndCase
    

    /*--------------------------------------------------------------------------------------*\
    | Chamada da função que fará todo o processamento das infos recebidas                    |
    \*--------------------------------------------------------------------------------------*/
    if lOK
        if ! jaApontada()
            apontaOP()
        endif
    endif


    /*--------------------------------------------------------------------------------------*\
    | Define o formato de retorno e monta o mesmo de acordo com o resultado da execucao      |
    \*--------------------------------------------------------------------------------------*/
    ::SetContentType("application/json")
    
    if lOK

        //Realiza a libera��o de estoque manualmente - Inicio

        DbSelectArea("SC5")
        SC5->(DbSetOrder(1))
        SC5->(DbSeek(xFilial("SC5") + oDados["numeroOP"]))

        if SC5->C5_LIBEROK <> "S"

            INCLUI := .F.
            ALTERA := .T.
            lSugere := .T.
            lTransf := .F.
            lLiber := .F.

            logWS("liberando pedido")


            A440Libera('SC5',SC5->(RECNO()),4,.T.)

        endif

        logWS("liberando estoque")

        LibEstq(oDados["numeroOP"])
        
		// StaticCall(M410PVNF,LibBlEst,oDados["numeroOP"])
		// StaticCall(M410PVNF,MATA455,oDados["numeroOP"],'')

		lPedLib := StaticCall(M410PVNF,IsPedLib,oDados["numeroOP"])

        if lPedLib
            logWS("estoque liberado")

            U_KFATR15("04",oDados["numeroOP"])  
        endif

        // Fim

        ::SetResponse(oReturn:Tojson())
    else
        SetRestFault(nCodErro,oReturn["mensagem"],.T.,nStatusCode)
    endif

    logWS(oReturn["mensagem"])
    FreeObj(oReturn)
    FreeObj(oDados)
    
Return lOK

/*/{Protheus.doc} User Function INCPV
    (long_description)
    @type  Function
    @author user
    @since 17/07/2020
    @version v1.050
    /*/
Static Function apontaOP()

    //Local aConv     := {}
    Local aItem     := {}

    Local cOrdemP   := ''
    Local cItemOP   := ''

    Private lMsErroAuto := .F.
        
    /*--------------------------------------------------------------------------------------*\
    | Valida se a Ordem de Producao informada existe no Protheus                               |
    \*--------------------------------------------------------------------------------------*/
    if lOK
        DbSelectArea("SC2")
        SC2->(DbSetOrder(1))
        if ! SC2->(DbSeek(xFilial("SC2") + oDados["numeroOP"]))
            montaErro("Numero da Ordem de Producao informada (" + oDados["numeroOP"] + ") nao foi encontrado na base de dados",400,20) 
        else
            cOrdemP := oDados["numeroOP"]
            cItemOP := oDados["itemOP"]
        endif
    endif


    if lOK

        begin transaction

        if select("TSC2A") > 0
            TSC2A->(DbCloseArea())
        endif

        BEGINSQL ALIAS "TSC2A"
            SELECT C2.* FROM %TABLE:SC6% C6
            INNER JOIN %TABLE:SC2% C2
                ON C2.C2_FILIAL = C6.C6_FILIAL
                AND C2.C2_NUM = C6.C6_NUM
                AND C2.C2_ITEM = C6.C6_ITEM
                AND C2.%NOTDEL%
            WHERE C6.%NOTDEL%
                AND C6_FILIAL = %XFILIAL:SC6%
                AND C6_NUM = %EXP:cOrdemP%
                AND C6_XITEMEX = %EXP:cItemOP%
        ENDSQL

        if ! TSC2A->(EoF())

            cNumOP := TSC2A->(C2_NUM) + TSC2A->(C2_ITEM) + TSC2A->(C2_SEQUEN)

            aItem := {  {"H6_FILIAL"    ,xFilial("SH6")     ,NIL},;
                        {"H6_OP"        , cNumOP            ,NIL},;
                        {"H6_PRODUTO"   ,TSC2A->(C2_PRODUTO),NIL},;
                        {"H6_OPERAC"    ,"01"               ,NIL},;
                        {"H6_RECURSO"   ,"000032"           ,NIL},;
                        {"H6_FERRAMENTA","000020"           ,NIL},;
                        {"H6_DATAINI"   ,dDataBase          ,NIL},;
                        {"H6_HORAINI"   ,"08:00"            ,NIL},;
                        {"H6_HORAFIN"   ,"09:00"            ,NIL},;
                        {"H6_DATAFIN"   ,dDataBase          ,NIL},;
                        {"H6_DTAPONT"   ,dDataBase          ,NIL},;
                        {"H6_QTDPERD"   ,0                  ,NIL},;
                        {"H6_QTGANHO"   ,0                  ,NIL},;
                        {"H6_PT"        ,'T'                ,NIL},;
                        {"H6_LOCAL"     ,"04"               ,NIL},;
                        {"H6_QTDPROD"   ,TSC2A->(C2_QUANT)  ,NIL}} 
            
            MSExecAuto({|x| MATA681(x)},aItem,3)


            if lMsErroAuto
                montaErro(mostraerro("/logs","apontaproducao" + strtran(time(),':') + ".log"),400,21)
                DisarmTransaction()
                Break
            else
                oReturn["resultado"] := "OK"
                oReturn["mensagem"] += ' | Tempo gasto: ' + Tgasto()
            endif

        else
            montaErro("Numero da Ordem de Producao informada (" + oDados["numeroOP"] + ") nao foi encontrado na base de dados",400,20) 
        endif

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

    conout('[apontaproducao] ' + cDtHr + ' : ' + cMsgLog)
    
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


Static Function LibEstq( cPedido )

Local aAreaAtu 	:= GetArea()
Local aAreaSC5 	:= SC5->( GetArea() )
Local aAreaSC6 	:= SC6->( GetArea() )
Local aAreaSC9 	:= SC9->( GetArea() )

dbSelectArea("SC9")
SC9->( dbSetOrder(1) ) //C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_BLEST, C9_BLCRED, R_E_C_N_O_, D_E_L_E_T_
SC9->( dbGoTop() )
If SC9->( dbSeek(FwxFilial('SC9') + cPedido ) )
	While SC9->(!Eof()) .And. SC9->C9_FILIAL + SC9->C9_PEDIDO == FwxFilial("SC9") + cPedido
	//-- Libera de Estoque para o item da liberacao do Pedido de Venda ( SC9 )   --             
            RecLock("SC9",.F.)
                SC9->C9_BLEST  := ""
            SC9->(MsUnlock())
		SC9->(dbSkip() )
	EndDO
EndIF

SC5->( dbSetOrder(1) ) //C5_FILIAL, C5_PEDIDO
SC5->( dbGoTop() )
If SC5->( dbSeek(FwxFilial('SC5') + cPedido ) )
    RecLock("SC5",.F.)
        SC5->C5_XSITLIB  := "6"
    SC5->(MsUnlock())
EndIF


RestArea(aAreaSC9)
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aAreaAtu)

Return()


static function jaApontada()

    Local lret := .F.
    Local cOrdemP := oDados["numeroOP"]
    Local cItemOP := oDados["itemOP"]
    Local cProdOP := ''

    if select("TMPC6")
        TMPC6->(DbCloseArea())
    endif

    BEGINSQL ALIAS "TMPC6"
        SELECT C6_PRODUTO FROM %TABLE:SC6%
        WHERE %NOTDEL%
        AND C6_FILIAL = %XFILIAL:SC6%
        AND C6_NUM =  %EXP:cOrdemP%
        AND C6_XITEMEX = %EXP:cItemOP%
    ENDSQL

    if ! TMPC6->(Eof())
        cProdOP := TMPC6->(C6_PRODUTO)
    endif

    TMPC6->(DbCloseArea())

    DbSelectArea('SH6')
    SH6->(DbSetOrder(1))
    If SH6->(DbSeek(xFilial("SH6") + cOrdemP + '01001   ' + cProdOP))
        lret := .T.
    EndIf

return lret
