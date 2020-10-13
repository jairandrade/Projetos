#include 'protheus.ch'
#include 'restful.ch'

//definio dos codes error do REST
#define FAULT_ERROR_PARSE 3
#define FAULT_ERROR_PARAM 2
#define FAULT_ERROR_PROC 1

//definio dos codes error e opes da rotina automtica
#define MATA010_INCLUI 3
#define MATA010_ALTERA 4
#define MATA010_ERROR  99

//definio dos status da replica
#define REPLICA_SUCESSO 1
#define REPLICA_ERRO 2
#define REPLICA_NAO_PROCESSADO 3

WsRestful AFIN002 Description "Servio REST para manuteno do cadastro de produto"

WsMethod GET Description "Retorna se o servios est funcionando corretamente" WSSYNTAX "/AFIN002" PATH "/AFIN002"

WsMethod POST Description "Incluso de produtos" WSSYNTAX "/AFIN002" PATH "/AFIN002"

WsMethod PUT Description "Alterao de produtos" WSSYNTAX "/AFIN002" PATH "/AFIN002"
WsMethod PUT BLOQUEAR Description "Bloqueio/Desbloqueio de produtos" WSSYNTAX "/AFIN002/BLOQUEAR" PATH "/AFIN002/BLOQUEAR"
WsMethod PUT REPLICAR Description "Replicao de produtos" WSSYNTAX "/AFIN002/REPLICAR" PATH "/AFIN002/REPLICAR"

End WsRestful

/*/{Protheus.doc} 
GET: retorna se o servio est operante com os dados do fonte
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET WsReceive NullParam WsService AFIN002

    local oRet := JsonObject():New()
    local aPrw := GetAPOInfo("MADERO_WS_AFIN002.prw")

    oRet['errorMessage'] := ""
    oRet['errorCode'] := 0
    oRet['result'] := JsonObject():New()
    oRet['result']['name'] := aPrw[1]
    oRet['result']['language'] := aPrw[2]
    oRet['result']['compilationMode'] := aPrw[3]
    oRet['result']['lastEditedDate'] := aPrw[4]
    oRet['result']['lastEditedHour'] := aPrw[5]

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
POST: Incluso de Produto
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/06/2020
/*/
WsMethod POST WsReceive NullParam WsService AFIN002

return incAlt010(MATA010_INCLUI, Self)

/*/{Protheus.doc} 
PUT: Alterao de Produto
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/06/2020
/*/
WsMethod PUT WsReceive NullParam WsService AFIN002

    local nX := 0
    local cRet := ""
    local cBody := ::GetContent()
    local aMata010 := {}
    local oRequest := JsonObject():New()
    local oResponse := JsonObject():New()
    
    cRet := oRequest:FromJson(cBody)

    if ! Empty(cRet)
        SetRestFault(FAULT_ERROR_PARSE, "Erro ao efetuar o parse do JSON: " + cRet)
        return .F.
    endIf

    //caso não tenha sido informado várias filiais, efetua a alteração apenas no registro atual
    if Empty(oRequest['FILIAIS'])
        return incAlt010(MATA010_ALTERA, Self)
    endIf

    if Empty(oRequest['B1_COD'])
        SetRestFault(FAULT_ERROR_PARAM, "O codigo do produto dever ser informado na alteracao!")
        return .F.
    endIf

    oResponse['errorMessage'] := ""
    oResponse['errorCode'] := 0
    oResponse['produto'] := oRequest['B1_COD']
    oResponse['result'] := {}

    aMata010 := mntAutoArr(oRequest)
    
    if Empty(aMata010)
        SetRestFault(FAULT_ERROR_PARAM, "No foi possvel criar uma listagem para rotina automtica MATA010!")
        return .F.
    endIf

    for nX := 1 to Len(oRequest['FILIAIS'])

        setaValor(@aMata010, "B1_FILIAL", oRequest['FILIAIS'][nX])

        AADD(oResponse['result'], JsonObject():New())

        mntMata010(@oResponse['result'][Len(oResponse['result'])],, aMata010, MATA010_ALTERA)

        //caso tenha ocorrido um erro ao tentar bloquear/desbloquear, registra no objeto pai
        if oResponse['result'][Len(oResponse['result'])]['errorCode'] > 0
            oResponse['errorMessage'] := "Ocorreram erros em alguns registros"
            oResponse['errorCode'] := MATA010_ERROR
        endIf

    next nX

    oResponse['resultCount'] := Len(oResponse['result'])

    ::SetContentType("application/json")
    ::SetResponse(oResponse:ToJson())

return .T.

/*/{Protheus.doc} incAlt010
Funo genrica de incluso e alterao de produto (POST e PUT)
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/06/2020
@param nOpc, numeric, ao a ser efetuada
@param oRest, object, Objeto SELF do FwRest
@return logical, Indica se foi possvel executar o servio
/*/
static function incAlt010(nOpc, oRest)

    local nX := 0
    local cRet := ""
    local cBody := oRest:GetContent()
    local aCpoObg := {}
    local aMata010 := {}
    local oRequest := JsonObject():New()
    local oResponse := JsonObject():New()

    cRet := oRequest:FromJson(cBody)

    if ! Empty(cRet)
        SetRestFault(FAULT_ERROR_PARSE, "Erro ao efetuar o parse do JSON: " + cRet)
        return .F.
    endIf

    if nOpc == MATA010_INCLUI .And. ! Empty(oRequest['B1_COD'])
        SetRestFault(FAULT_ERROR_PARAM, "O cdigo do produto no dever ser informado na incluso!")
        return .F.
    endIf
    
    if nOpc == MATA010_ALTERA .And. Empty(oRequest['B1_COD'])
        SetRestFault(FAULT_ERROR_PARAM, "O cdigo do produto dever ser informado na alterao!")
        return .F.
    endIf

    aMata010 := mntAutoArr(oRequest)
    
    if Empty(aMata010)
        SetRestFault(FAULT_ERROR_PARAM, "No foi possvel criar uma listagem para rotina automtica MATA010!")
        return .F.
    endIf

    //na incluso, estes campos so obrigatrios (inclusive, para buscar o cdigo do produto)
    if nOpc == MATA010_INCLUI
        AADD(aCpoObg, "B1_XTIPO")
        AADD(aCpoObg, "B1_XCLAS")
        AADD(aCpoObg, "B1_GRUPO")
    endIf

    //a filial sempre dever ser informada
    AADD(aCpoObg, "B1_FILIAL")

    //confere se os campos obrigatrios foram preenchidos
    for nX := 1 to Len(aCpoObg)

        if Empty(retFldArr(aMata010, aCpoObg[nX]))
            SetRestFault(FAULT_ERROR_PARAM, "O campo " + aCpoObg[nX] + " - " + AllTrim(GetSx3Cache(aCpoObg[nX], "X3_TITULO")) + "  obrigatorio!")
            return .F.
        endIf

    next nX

    if nOpc == MATA010_INCLUI

        AADD(aMata010, {"B1_COD", getCodPrd(aMata010), Nil})

        //O campo B1_XN4 deve ser quebrado
        ajustaXN4(@aMata010)

    endIf

    mntMata010(@oResponse, oRequest, aMata010, nOpc)

    oRest:SetContentType("application/json")
    oRest:SetResponse(oResponse:ToJson())

return .T.

/*/{Protheus.doc} 
Mtodo de replicao de produtos
@type function
@version 12.1.0.25
@author fabricio.reche
@since 13/06/2020
/*/
WsMethod PUT REPLICAR WsReceive NullParam WsService AFIN002

    local nX := 0
    local nPos := 0
    local aEmp := {}
    local nRegs := 0
    local cBody := ::GetContent()
    local cDsProd := ""
    local oRequest := JsonObject():New()
    local oResponse := JsonObject():New()
    local cAliasTmp := ""

    cRet := oRequest:FromJson(cBody)

    if ! Empty(cRet)
        SetRestFault(FAULT_ERROR_PARSE, "Erro ao efetuar o parse do JSON: " + cRet)
        return .F.
    endIf

    if Empty(oRequest['B1_FILIAL'])
        SetRestFault(FAULT_ERROR_PARAM, "A filial do produto a ser replicado dever ser informado!")
        return .F.
    endIf
    
    if Empty(oRequest['B1_COD'])
        SetRestFault(FAULT_ERROR_PARAM, "O codigo do produto a ser replicado dever ser informado!")
        return .F.
    endIf

    cDsProd := buscaDescProd(oRequest['B1_FILIAL'], oRequest['B1_COD'])

    if Empty(cDsProd)
        SetRestFault(FAULT_ERROR_PARAM, "Nao foi possivel posicionar no produto " + oRequest['B1_FILIAL'] + " / " + oRequest['B1_COD'] + "!")
        return .F.
    endIf

    if Empty(oRequest['FILIAIS'])
        SetRestFault(FAULT_ERROR_PARAM, "E necessario informar as filiais para replica!")
        return .F.
    endIf

    if ! Empty(cRet := integradoTeknisa(oRequest['B1_COD']))
        SetRestFault(FAULT_ERROR_PARAM, "Produto nao integrado no teknisa: " + cRet)
        return .F.
    endIf

    //cria estrutura da tabela temporria
    cAliasTmp := StaticCall(MADERO_EST001, fGerTmpRes)

    for nX := 1 to Len(oRequest['FILIAIS'])
    
        aEmp := getEmpresa(oRequest['FILIAIS'][nX])

        RecLock(cAliasTmp, .T.)

            (cAliasTmp)->PRODUTO := oRequest['B1_COD']
            (cAliasTmp)->DESCRICAO := cDsProd
            (cAliasTmp)->EMPRESA := aEmp[1]
            (cAliasTmp)->FILIAL := aEmp[2]
            (cAliasTmp)->MSG := "nao processado"
            (cAliasTmp)->SUCESSO := REPLICA_NAO_PROCESSADO
            (cAliasTmp)->MSGLOG := ""

        MsUnLock()

        nRegs++

    next nX

    //efetua a replica do produto
    replicaProduto(oRequest['B1_FILIAL'], nRegs, cAliasTmp)
    
    //monta o retorno da aplicao
    oResponse['jsonReceived'] := oRequest
    oResponse['errorMessage'] := ""
    oResponse['errorCode'] := 0
    oResponse['result'] := {}

    (cAliasTmp)->(DbGoTop())

    while (cAliasTmp)->( ! EoF() )

        AADD(oResponse['result'], JsonObject():New())

        nPos := Len(oResponse['result'])

        oResponse['result'][nPos]['PRODUTO'] := AllTrim((cAliasTmp)->PRODUTO)
        oResponse['result'][nPos]['DESCRICAO'] := AllTrim((cAliasTmp)->DESCRICAO)
        oResponse['result'][nPos]['EMPRESA'] := AllTrim((cAliasTmp)->EMPRESA)
        oResponse['result'][nPos]['FILIAL'] := AllTrim((cAliasTmp)->FILIAL)
        oResponse['result'][nPos]['F_NOME'] := AllTrim(FwFilialName((cAliasTmp)->EMPRESA, (cAliasTmp)->FILIAL))
        oResponse['result'][nPos]['MSG'] := AllTrim((cAliasTmp)->MSG)
        oResponse['result'][nPos]['SUCESSO'] := (cAliasTmp)->SUCESSO
        oResponse['result'][nPos]['MSGLOG'] := GetErrorMessage((cAliasTmp)->MSGLOG, 90, (cAliasTmp)->EMPRESA, (cAliasTmp)->FILIAL)

        //caso tenha ocorrido erro em algum processamento
        if oResponse['result'][nPos]['SUCESSO'] == REPLICA_ERRO .Or. oResponse['result'][nPos]['SUCESSO'] == REPLICA_NAO_PROCESSADO
            oResponse['errorCode'] := FAULT_ERROR_PROC
            oResponse['errorMessage'] := "Ocorreram erros ao replicar o produto"
        endIf

        (cAliasTmp)->( DbSkip() )

    endDo

    oResponse['resultCount'] := nPos

    //remove a tabela temporria
    If !Empty(cAliasTmp)
        (cAliasTmp)->(dbCloseArea())
        TCDelFile(cAliasTmp)
        TCRefresh(cAliasTmp)
    EndIf

    ::SetContentType("application/json")
    ::SetResponse(oResponse:ToJson())

return .T.

/*/{Protheus.doc} 
PUT BLOQUEAR: Efetua o bloqueio ou desbloqueio do produto para N filiais
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/06/2020
/*/
WsMethod PUT BLOQUEAR WsReceive NullParam WsService AFIN002

    local nX := 0
    local cRet := ""
    local cBody := ::GetContent()
    local aMata010 := {}
    local oRequest := JsonObject():New()
    local oResponse := JsonObject():New()
    
    cRet := oRequest:FromJson(cBody)

    if ! Empty(cRet)
        SetRestFault(FAULT_ERROR_PARSE, "Erro ao efetuar o parse do JSON: " + cRet)
        return .F.
    endIf

    if Empty(oRequest['B1_COD'])
        SetRestFault(FAULT_ERROR_PARAM, "O cdigo do produto dever ser informado no bloqueio!")
        return .F.
    endIf

    if Empty(oRequest['FILIAIS'])
        SetRestFault(FAULT_ERROR_PARAM, "Filiais devem ser informadas!")
        return .F.
    endIf

    if Empty(oRequest['B1_MSBLQL'])
        SetRestFault(FAULT_ERROR_PARAM, "Deve indicar se deve bloquear!")
        return .F.
    endIf

    oResponse['errorMessage'] := ""
    oResponse['errorCode'] := 0
    oResponse['produto'] := oRequest['B1_COD']
    oResponse['result'] := {}

    for nX := 1 to Len(oRequest['FILIAIS'])

        aMata010 := {}

        AADD(oResponse['result'], JsonObject():New())

        AADD(aMata010, {'B1_FILIAL', oRequest['FILIAIS'][nX], Nil})
        AADD(aMata010, {'B1_COD'   , oRequest['B1_COD']     , Nil})
        AADD(aMata010, {'B1_MSBLQL', oRequest['B1_MSBLQL']  , Nil})

        mntMata010(@oResponse['result'][Len(oResponse['result'])],, aMata010, MATA010_ALTERA)

        //caso tenha ocorrido um erro ao tentar bloquear/desbloquear, registra no objeto pai
        if oResponse['result'][Len(oResponse['result'])]['errorCode'] > 0
            oResponse['errorMessage'] := "Ocorreram erros em alguns registros"
            oResponse['errorCode'] := MATA010_ERROR
        endIf

    next nX

    oResponse['resultCount'] := Len(oResponse['result'])

    ::SetContentType("application/json")
    ::SetResponse(oResponse:ToJson())

return .T.

/*/{Protheus.doc} mntMata010
Funo genrica de execuo da rotina automtica do cadastro de produtos (MATA010)
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/06/2020
@param oResponse, object, Objeto instanciado da classe JsonObject para resposta
@param oRequest, object, Json da requisio efetuada
@param aMata010, array, Array da rotina automtica
@param nOpc, numeric, Ao a ser executada
/*/
static function mntMata010(oResponse, oRequest, aMata010, nOpc)

    local cJsonRes := ""
    local cJsonReq := ""
    local cFilBkp := cFilAnt
    local aEmp := getEmpresa(retFldArr(aMata010, "B1_FILIAL"))

    if oRequest != Nil
        cJsonReq := oRequest:ToJson()
    endIf

    //caso seja a mesma empresa
    if aEmp[1] == cEmpAnt

        //caso necessite alterar a filial
        if aEmp[2] != cFilAnt
            cFilAnt := aEmp[2]
        endIf

        cJsonRes := U_AFIN002J(, cJsonReq, aMata010, nOpc)

        //restaura backup da filial posicionada
        cFilAnt := cFilBkp

    else

        cJsonRes := StartJob("U_AFIN002J", GetEnvServer(), .T., aEmp, cJsonReq, aMata010, nOpc)

    endIf

    oResponse:FromJson(cJsonRes)

return

/*/{Protheus.doc} AFIN002J
Efetiva a execuo da rotina automtica, via JOB (ou no)
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/06/2020
@param aEmp, array, Quando for execuo via JOB, indica [1]=Empresa e [2]=Filial para preparao do ambiente
@param cJsonReq, character, String Json da requisio
@param aMata010, array, Array de execuo da rotina automtica
@param nOpc, numeric, Ao a ser executada
@return character, String Json da resposta
/*/
user function AFIN002J(aEmp, cJsonReq, aMata010, nOpc)

    local lAuto := ! Empty(aEmp)
    local nPosFld := 0
    local oResponse := JsonObject():New()
    local cPathErro := "\WSAFIN002\"
    local cFileErro := "mata010_erro" + FwTimeStamp() + ".log"
    local aCpoUpdat := {}
    local nX        := 0

//caso aEmp não tenha sido informado, não é preciso montar o ambiente, mas precisa de dados no array de empresa
    default aEmp := getEmpresa(retFldArr(aMata010, "B1_FILIAL"))

    private lMsErroAuto := .F.

    //caso precise preparar o ambiente (StartJob)
    if lAuto
        RpcSetType(3)
        RpcSetEnv(aEmp[1], aEmp[2],,, 'FAT', 'MATA010')
        //OBS.: Como veio do startJob, no precisa do RpcClearEnv()
    endIf
    
    if ! Empty(cJsonReq)
        oResponse['jsonReceived']:= JsonObject():New()
        oResponse['jsonReceived']:FromJson(cJsonReq)
    endIf

    oResponse['errorMessage'] := ""
    oResponse['errorCode'] := 0
    oResponse['result'] := JsonObject():New()

    //no caso de alterao, posiciona no cadastro do produto
    if nOpc == MATA010_ALTERA

        SB1->( DbSetOrder(1) ) //B1_FILIAL+B1_COD
        SB1->( DbGoTop() )

        if ! SB1->( DbSeek( retFldArr(aMata010, "B1_FILIAL") + retFldArr(aMata010, "B1_COD") ) )

            oResponse['errorCode'] := MATA010_ERROR
            oResponse['errorMessage'] := "Nao foi possivel localizar o produto " + retFldArr(aMata010, "B1_FILIAL") + " / " + retFldArr(aMata010, "B1_COD")

            return oResponse:toJson()

        endIf

    endIf

    //confere se existem campos que devem ser removidos da rotina automática e atualizados posteriormente
    aCpoUpdat := verCpoUpdate(@aMata010)

    //ordena o array conforme dicionrio de dados
    aMata010 := FwVetByDic(aMata010, "SB1")

    MsExecAuto({|x, y| Mata010(x, y)}, aMata010, nOpc)

    if lMsErroAuto

        oResponse['errorCode'] := MATA010_ERROR

        MakeDir(cPathErro)
        MostraErro(cPathErro, cFileErro)

        oResponse['errorMessage'] := GetErrorMessage(MemoRead(cPathErro + cFileErro), 80, aEmp[1], aEmp[2])
        oResponse['errorLog'] := cPathErro + cFileErro

        if Empty(oResponse['errorMessage'])
            oResponse['errorMessage'] := "Ocorreu um erro interno na rotina automatica MATA010"
        endIf

        oResponse['mata010Params'] := retMt10Par(aMata010)

        return oResponse:toJson()

    endIf

    if ! Empty(aCpoUpdat)

        RecLock("SB1")

            for nX := 1 to Len(aCpoUpdat)

                nPosFld := SB1->(FieldPos(aCpoUpdat[nX][1]))

                if nPosFld > 0

                    SB1->( FieldPut( nPosFld, aCpoUpdat[nX][2] ) )

                endIf

            next nX

        MsUnlock()

    endIf

    oResponse['result']['B1_FILIAL'] := AllTrim(retFldArr(aMata010, "B1_FILIAL"))
    oResponse['result']['B1_COD'] := AllTrim(retFldArr(aMata010, "B1_COD"))
    oResponse['result']['F_NOME'] := AllTrim(FwFilialName())

return oResponse:toJson()

/*/{Protheus.doc} AjustaCampo
Efetua o ajuste de uValor conforme os dados do cCampo
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/06/2020
@param cCampo, character, Nome do campo do dicionrio de dados (SX3)
@param uValor, variadic, Valor recebido da requisio
@return variadic, Retorna o valor ajustado conforme dicionrio de dados (SX3)
/*/
static function AjustaCampo(cCampo, uValor)

    local cTipo := GetSx3Cache(cCampo, "X3_TIPO")

    if ValType(uValor) == cTipo
        return uValor
    endIf

    do Case

        case cTipo == "C"
            return paraCaractere(uValor)

        case cTipo == "D"
            return paraData(uValor)
        
        case cTipo == "N"
            return paraNumero(uValor)
            
        case cTipo == "L"
            return paraLogico(uValor)

    endCase

return uValor

/*/{Protheus.doc} paraCaractere
Converte uValor para caractere
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/06/2020
@param uValor, variadic, Contedo para efetuar o cast
@return character, uValor em caractere
/*/
static function paraCaractere(uValor)

    do Case
    
        case ValType(uValor) == "U"
            return ""

        case ValType(uValor) == "N"
            return cValToChar(uValor)

        case ValType(uValor) == "D"
            return dToS(uValor)

        case ValType(uValor) == "L"
            return IIF(uValor, ".T.", ".F.")

    endCase

return uValor

/*/{Protheus.doc} paraData
Converte uValor para data
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/06/2020
@param uValor, variadic, Contedo para ser feito cast para data
@return date, Contedo convertido para data
/*/
static function paraData(uValor)

    local cData := ""

    do Case

        case ValType(uValor) == "U"
            return sToD("")
            
        case ValType(uValor) == "C"
            return sToD(uValor)
        
        case ValType(uValor) == "N"

            cData := Str(uValor)

            //caso o valor numrico no possa ser convertido para data
            if Len(cData) != 8
                return sToD("")
            endIf

            return sToD(cData)
        
        case ValType(uValor) == "L"
            return sToD("")

    endCase

return uValor

/*/{Protheus.doc} paraNumero
Converte uValor para numrico
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/06/2020
@param uValor, variadic, Contedo para ser feito o cast
@return numeric, uValor em nmero
/*/
static function paraNumero(uValor)

    do Case

        case ValType(uValor) == "U"
            return 0
            
        case ValType(uValor) == "C"
            return Val(uValor)
        
        case ValType(uValor) == "D"
            return Val(dToS(uValor))
        
        case ValType(uValor) == "L"
            return IIF(uValor, 1, 0)

    endCase

return uValor

/*/{Protheus.doc} paraLogico
Converte uValor para lgico
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/06/2020
@param uValor, variadic, Contedo para ser feito cast
@return logical, uValor em valor lgico
/*/
static function paraLogico(uValor)

    //"" .F.
    //0 .F.
    //Nil .F.

    //"algo" .T.
    //10 .T.
    //Object .T.

return ! Empty(uValor)

/*/{Protheus.doc} getEmpresa
Retorna array com o [1]=Cdigo da Empresa e [2]=Cdigo da Fillial
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/06/2020
@param cdFilial, character, Cdigo da filial para pesquisa
@return array, {Cdigo da Empresa, Cdigo da Fillial}
/*/
static function getEmpresa(cdFilial)

    local aEmp := {}
    local aAreaADK := ADK->(GetArea())

    ADK->( DbOrderNickName("ADKXFILI") )
    ADK->( DbGoTop() )

    if ADK->( DbSeek( xFilial("ADK") + cdFilial ) )

        AADD(aEmp, ADK->ADK_XGEMP)
        AADD(aEmp, ADK->ADK_XFILI)

    endIf

    ADK->(RestArea(aAreaADK))

return aEmp

/*/{Protheus.doc} getCodPrd
Retorna o cdigo do produto a ser includo
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/06/2020
@param aMata010, array, Array da rotina automtica
@return character, Novo cdigo de produto
/*/
static function getCodPrd(aMata010)

    local cdProduto := ""
    local cdFilial := retFldArr(aMata010, "B1_FILIAL")
    local lRelogio := cdFilial == SuperGetMv("MV_XFMTCAD", .F., "02MDBG0003")
    local cCodIni := IIF(lRelogio, "2", "1")
    local _cQuery := ""
    local _cAlias := ""

    _cQuery += " select SubStr(MAX(B1_COD), 1, 12) + 1 || '00' B1_COD "
    _cQuery += " from SB10" + cCodIni + "0 "
    _cQuery += " where D_E_L_E_T_ <> '*' "
    _cQuery += "   and B1_FILIAL = " + ValToSql(cdFilial)
    _cQuery += "   and SubStr(B1_COD, 1, 1) = " + ValToSql(cCodIni)
    _cQuery += "   and SubStr(B1_COD, 2, 2) = B1_XTIPO "
    _cQuery += "   and SubStr(B1_COD, 4, 2) = B1_XCLAS "
    _cQuery += "   and SubStr(B1_COD, 6, 3) = SubStr(B1_GRUPO,1,3) "
    _cQuery += "   and B1_XTIPO = " + ValToSql(retFldArr(aMata010, "B1_XTIPO"))
    _cQuery += "   and B1_XCLAS = " + ValToSql(retFldArr(aMata010, "B1_XCLAS"))
    _cQuery += "   and B1_GRUPO = " + ValToSql(retFldArr(aMata010, "B1_GRUPO"))

    _cAlias := MPSysOpenQuery(_cQuery)

    cdProduto := AllTrim((_cAlias)->B1_COD)

    if Empty(cdProduto) .Or. cdProduto == "00"

        cdProduto := cCodIni
        cdProduto += AllTrim(retFldArr(aMata010, "B1_XTIPO"))
        cdProduto += AllTrim(retFldArr(aMata010, "B1_XCLAS"))
        cdProduto += SubStr(retFldArr(aMata010, "B1_GRUPO"), 1, 3)
        cdProduto += '000100'

    endIf
    
    (_cAlias)->( DbCloseArea() )

    //garante que o código do produto não existe
    while existeProduto(cCodIni, cdFilial, cdProduto)

        cdProduto := cValToChar( Val( SubStr(cdProduto, 1, 12) ) + 1 )
        cdProduto += "00"

    endDo

return AllTrim(cdProduto)

/*/{Protheus.doc} retFldArr
Busca o contedo de um campo no array de rotina automtica
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/06/2020
@param aAuto, array, Array da rotina automtica
@param cField, character, Campo a ser feita a busca
@return variadic, Contedo do campo no array da rotina automtica
/*/
static function retFldArr(aAuto, cField)

    local nPosFld := aScan(aAuto, {|at| AllTrim(at[1]) == cField  })

    if Empty(nPosFld)
        return ""
    endIf

return aAuto[nPosFld][2]

/*/{Protheus.doc} buscaDescProd
Busca descrio do produto para filial informada
@type function
@version 12.1.0.25
@author fabricio.reche
@since 05/06/2020
@param cdFilial, character, Cdigo da filial
@param cdProduto, character, Cdigo do produto
@return character, Descrio do produto
/*/
static function buscaDescProd(cdFilial, cdProduto)

    local _cQuery := ""
    local _cAlias := ""
    local cDescri := ""
    local aEmp := getEmpresa(cdFilial)

    _cQuery += " select B1_DESC " 
    _cQuery += " from SB1" + aEmp[1] + "0 SB1"
    _cQuery += " where D_E_L_E_T_ = ' ' "
    _cQuery += "   and B1_FILIAL = " + ValToSql(aEmp[2])
    _cQuery += "   and B1_COD = " + ValToSql(cdProduto)

    _cAlias := MPSysOpenQuery(_cQuery)

    while (_cAlias)->( ! EoF() )

        cDescri := (_cAlias)->B1_DESC

        (_cAlias)->( DbSkip() )

    endDo

    (_cAlias)->( DbCloseArea() )

return cDescri

/*/{Protheus.doc} integradoTeknisa
Confere se o produto est integrado na Teknisa na filial informada
@type function
@version 12.1.0.25
@author fabricio.reche
@since 05/06/2020
@param cdFilial, character, Cdigo da Filial
@param cdProduto, character, Cdigo do Produto
@return character, Mensagem de erro quando no itegrado
/*/
static function integradoTeknisa(cdProduto)

    local _cQuery := ""
    local _cAlias := ""
    local cMsg := ""

    _cQuery += " select * " 
    _cQuery += " from Z13010 Z13 " //compartilhada entre os grupos, empresas e filiais
    _cQuery += " where Z13.D_E_L_E_T_ = ' ' and Z13_FILIAL = ' ' "
    _cQuery += "   and Z13_COD = " + ValToSql(cdProduto)

    _cAlias := MPSysOpenQuery(_cQuery)

    while (_cAlias)->( ! EoF() )

        if (_cAlias)->Z13_XSTINT != "I"
            cMsg += (_cAlias)->Z13_XLOG
        endIf

        (_cAlias)->( DbSkip() )

    endDo

    (_cAlias)->( DbCloseArea() )

return cMsg

/*/{Protheus.doc} replicaProduto
Efetua a replica do produto para a filial informada
@type function
@version 12.1.0.25
@author fabricio.reche
@since 05/06/2020
@param cdFilial, character, Cdigo da filial origem
@param nRegs, numeric, Nmero de registros a serem processados
@param cAliasTmp, character, Alias temporrio com as replicas a serem executadas
/*/
static function replicaProduto(cdFilial, nRegs, cAliasTmp)

    local aEmp := getEmpresa(cdFilial)
    local cFilBkp := cFilAnt
    local cEmpBkp := cEmpAnt

    //garante o posicionamento na filial correta
    cEmpAnt := aEmp[1]
    cFilAnt := aEmp[2]

    //função de replica de produtos (MADERO_EST001)
    U_EST001( nRegs, cAliasTmp, .F., .T., "WS_AFIN002" )

    cEmpAnt := cEmpBkp
    cFilAnt := cFilBkp

return 

/*/{Protheus.doc} retMt10Par
Retorna um objeto json dos parametros informados no MATA010
@type function
@version 12.1.0.25
@author fabricio.reche
@since 12/06/2020
@param aMata010, array, Parametros do array da rotina automtica
@return object, Objeto Json com os dados enviados
/*/
static function retMt10Par(aMata010)

    local oObj := JsonObject():New()
    local nX := 0

    for nX := 1 to Len(aMata010)

        oObj[aMata010[nX][1]] := aMata010[nX][2]

    next nX

return oObj

/*/{Protheus.doc} ajustaXN4
Ajusta o campo de grupo de nvel 1-4 da Teknisa
@type function
@version 12.1.0.25
@author fabricio.reche
@since 12/06/2020
@param aMata010, array, Array da rotina automtica
/*/
static function ajustaXN4(aMata010)

    local cXN4 := retFldArr(aMata010, "B1_XN4")
    local cCpo := ""
    local cVal := ""
    local nTam := 1
    local nX := 1

    //caso o campo esteja em branco ou no tamanho certo, ignora
    if Empty(cXN4) .Or. Len(cXN4) == GetSx3Cache("B1_XN4", "X3_TAMANHO")
        return
    endIf

    //percorre o contedo de B1_XN1-4
    while SB1->( FieldPos( ( cCpo := "B1_XN" + cValToChar(nX) ) ) ) > 0

      cVal := SubStr(cXN4, nTam, GetSx3Cache(cCpo, "X3_TAMANHO"))

      nTam += Len(cVal)

      setaValor(@aMata010, cCpo, cVal)

      nX++

    endDo

return

/*/{Protheus.doc} setaValor
Seta o valor ao array da rotina automtica (adiciona quando no localizado)
@type function
@version 12.1.0.25
@author fabricio.reche
@since 12/06/2020
@param aMata010, array, Array da rotina automtica
@param cCampo, character, Campo
@param uVal, variadic, Valor
/*/
static function setaValor(aMata010, cCampo, uVal)

    local nPos := aScan(aMata010, {|arr| AllTrim(arr[1]) == cCampo })

    if nPos <= 0

        AADD(aMata010, {cCampo, Nil, Nil})
        nPos := Len(aMata010)

    endIf

    aMata010[nPos][2] := uVal

return

/*/{Protheus.doc} GetErrorMessage
Extrai a mensagem de erro mais sucinta do erro da rotina automtica
@type function
@version 12.1.0.25
@author fabricio.reche
@since 13/06/2020
@param cErrorLog, character, Contedo do Arquivo do error.log gerado
@param nTamTxt, numeric, Tamanho da quebra de linha
@param cdEmpresa, character, Código da Empresa
@param cdFilial, character, Código da Filial
@return character, Mensagem resumida
/*/
static function GetErrorMessage(cErrorLog, nTamTxt, cdEmpresa, cdFilial)

    local cMessage := ""
    local aErrorLg := FwTxt2Array(StrTran(cErrorLog, "\r\n", CRLF), nTamTxt, .T.)
    local nX := 0

    for nX := 1 to Len(aErrorLg)

        //se a linha for da mensagem de erro
        if "< -- Invalido" $ aErrorLg[nX] .Or. "Mensagem do erro: " $ aErrorLg[nX]

            if ! aErrorLg[nX] $ cMessage
                cMessage += AllTrim(aErrorLg[nX]) + " "
            endIf

            //caso tenha pego o começo da mensagem de erro, mas não seu final
            if "Mensagem do erro: " $ aErrorLg[nX] .And. ! "]" $ aErrorLg[nX]

                while ! "]" $ aErrorLg[nX] .And. nX <= Len(aErrorLg)
                    nX++
                    cMessage += AllTrim(aErrorLg[nX]) + " "
                endDo

            endIf

        endIf

    next nX

    cMessage := StrTran(cMessage, "]", " (para o grupo " + cdEmpresa + " filial " + cdFilial + "]")

return cMessage

/*/{Protheus.doc} verCpoUpdate
Retorna array com campos a serem atualizados fora da rotina automática
@type function
@version 12.1.0.25
@author fabricio.reche
@since 15/06/2020
@param aMata010, array, Array da rotina automática
@return array, Array de campos removidos do array da rotina automática
/*/
static function verCpoUpdate(aMata010)

    local aCampos := {}
    local nRemove := 0

    //remove os campos de grupo do tekinisa
    while (nRemove := aScan(aMata010, {|mta| "B1_XN" $ mta[1] })) > 0

        AADD(aCampos, {aMata010[nRemove][1], aMata010[nRemove][2]})

        aDel(aMata010, nRemove)
        aSize(aMata010, Len(aMata010)-1)

    endDo

return aCampos

/*/{Protheus.doc} mntAutoArr
Monta o array da rotina automática pelo objeto de requisição
@type function
@version 12.1.0.25
@author fabricio.reche
@since 15/06/2020
@param oRequest, object, JsonObject instanciado com os dados de requisição
@return array, Array da rotina automática preenchida
/*/
static function mntAutoArr(oRequest)

    local aMata010 := {}
    local aProps := oRequest:GetNames()
    local cCampo := ""
    local uValor := Nil
    local nX := 0

    for nX := 1 to Len(aProps)

        cCampo := AllTrim(aProps[nX])
        uValor := AjustaCampo(cCampo, oRequest[cCampo])

        //caso seja uma propriedade que no tem no dicionrio de dados ou contedo vazio
        if SB1->(FieldPos(cCampo)) <= 0 .Or. Empty(uValor)
            loop
        endIf

        AADD(aMata010, {cCampo, uValor, Nil})

    next nX

return aMata010

/*/{Protheus.doc} existeProduto
Confere se o código do produto existe para o grupo e filial
@type function
@version 12.1.0.25
@author fabricio.reche
@since 21/07/2020
@param cCodIni, character, Código do Grupo
@param cdFilial, character, Código da Filial
@param cdProduto, character, Código do Produto
@return logical, Indica se o produto já existe
/*/
static function existeProduto(cCodIni, cdFilial, cdProduto)

    local _cAlias := ""
    local _cQuery := ""
    local lExiste := .F.

    _cQuery += " select R_E_C_N_O_ REG " 
    _cQuery += " from SB10" + cCodIni + "0 "
    _cQuery += " where D_E_L_E_T_ = ' ' "
    _cQuery += "   and B1_FILIAL = " + ValToSql(cdFilial)
    _cQuery += "   and B1_COD = " + ValToSql(cdProduto)
    
    _cAlias := MPSysOpenQuery(_cQuery)
    
    lExiste := (_cAlias)->( ! EoF() )

    (_cAlias)->( DbCloseArea() )

return lExiste
