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

/*/{Protheus.doc} AFIN002I
Incluso de produtos
@type function
@version 12.1.0.25
@author fabricio.reche
@since 06/07/2020
@param cRequest, character, String Json da requisio
@return character, String Json da resposta
/*/
user function AFIN002I(cRequest)

    local cResponse := incAlt010(MATA010_INCLUI, cRequest)
    local oMtaRespo := JsonObject():New()
    local oResponse := JsonObject():New()
    local oRequest  := JsonObject():New()

    oMtaRespo:FromJson(cResponse)
    oRequest:FromJson(cRequest)

    oResponse['errorMessage'] := oMtaRespo['errorMessage']
    oResponse['errorCode'] := oMtaRespo['errorCode']
    oResponse['result'] := {oMtaRespo}
    oResponse['resultCount'] := Len(oResponse['result'])

    cResponse := oResponse:ToJson()

    //se ocorreu um erro na incluso, retorna erro
    if oResponse['errorCode'] > 0
        return cResponse
    endIf

    //replicar a incluso de produto para as filiais destino (quando informado)
    if ! Empty(oRequest['FILIAIS'])

        //precisa adquirir o código inserido do resultado da inclusão
        oRequest["B1_COD"] := oResponse["result"][1]['result']["B1_COD"]
        oRequest["B1_FILIAL"] := oResponse["result"][1]['result']["B1_FILIAL"]

        cResponse := U_AFIN002R(oRequest:ToJson())

    endIf

return cResponse

/*/{Protheus.doc} AFIN002A
Alterao de produto
@type function
@version 12.1.0.25
@author fabricio.reche
@since 06/07/2020
@param cRequest, character, String Json da requisio
@return character, String Json da resposta
/*/
user function AFIN002A(cRequest)

    local nX := 0
    local aCpoSB5 := {}
    local aMata010 := {}
    local oRequest := JsonObject():New()
    local oResponse := JsonObject():New()
    
    oRequest:FromJson(cRequest)
    
    oResponse['errorMessage'] := ""
    oResponse['errorCode'] := 0
    oResponse['result'] := {}

    //caso no tenha sido informado vrias filiais, efetua a alterao apenas no registro atual
    if Empty(oRequest['FILIAIS'])
        return incAlt010(MATA010_ALTERA, cRequest)
    endIf

    if Empty(oRequest['B1_COD'])
        oResponse['errorCode'] := FAULT_ERROR_PARAM
        oResponse['errorMessage'] := "O codigo do produto dever ser informado na alteracao!"
        return oResponse:ToJson()
    endIf

    oResponse['produto'] := oRequest['B1_COD']

    aMata010 := mntAutoArr(oRequest)
    aCpoSB5 := mntAutoArr(oRequest, "SB5")
    
    if Empty(aMata010)
        oResponse['errorCode'] := FAULT_ERROR_PARAM
        oResponse['errorMessage'] := "No foi possvel criar uma listagem para rotina automtica MATA010!"
        return oResponse:ToJson()
    endIf

    if ! Empty(oRequest['alteraGeral']) .And. oRequest['alteraGeral']
        //marca para não integrar tekinisa (Z13)
        _SetOwnerPrvt("lFacRep", .T.)
    endIf

    for nX := 1 to Len(oRequest['FILIAIS'])

        setaValor(@aMata010, "B1_FILIAL", oRequest['FILIAIS'][nX])

        //só deve integrar com tekinisa quando for filial relógio
        if Type("lFacRep") != "U"
            lFacRep := oRequest['FILIAIS'][nX] != SuperGetMv("MV_XFMTCAD", .F., "02MDBG0003")
        endIf

        AADD(oResponse['result'], JsonObject():New())

        mntMata010(@oResponse['result'][Len(oResponse['result'])],, aMata010, MATA010_ALTERA, aCpoSB5)

        //caso tenha ocorrido um erro ao tentar bloquear/desbloquear, registra no objeto pai
        if oResponse['result'][Len(oResponse['result'])]['errorCode'] > 0
            oResponse['errorMessage'] := "Ocorreram erros em alguns registros"
            oResponse['errorCode'] := MATA010_ERROR
        endIf

    next nX

    oResponse['resultCount'] := Len(oResponse['result'])

return oResponse:ToJson()

/*/{Protheus.doc} incAlt010
Funo genrica de incluso e alterao de produto (POST e PUT)
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/06/2020
@param nOpc, numeric, ao a ser efetuada
@param cReques, character, String Json da requisio
@return character, String Json de resposta
/*/
static function incAlt010(nOpc, cRequest)

    local nX := 0
    // local cRet := ""
    local aCpoObg := {}
    local aCpoSB5 := {}
    local aMata010 := {}
    local oRequest := JsonObject():New()
    local oResponse := JsonObject():New()

    oRequest:FromJson(cRequest)
    
    oResponse['errorMessage'] := ""
    oResponse['errorCode'] := 0

    if nOpc == MATA010_INCLUI .And. ! Empty(oRequest['B1_COD'])
        oResponse['errorCode'] := FAULT_ERROR_PARAM
        oResponse['errorMessage'] := "O cdigo do produto no dever ser informado na incluso!"
        return oResponse:ToJson()
    endIf
    
    if nOpc == MATA010_ALTERA .And. Empty(oRequest['B1_COD'])
        oResponse['errorCode'] := FAULT_ERROR_PARAM
        oResponse['errorMessage'] := "O cdigo do produto dever ser informado na alterao!"
        return oResponse:ToJson()
    endIf

    aMata010 := mntAutoArr(oRequest)
    aCpoSB5 := mntAutoArr(oRequest, "SB5")
    
    if Empty(aMata010)
        oResponse['errorCode'] := FAULT_ERROR_PARAM
        oResponse['errorMessage'] := "No foi possvel criar uma listagem para rotina automtica MATA010!"
        return oResponse:ToJson()
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
            oResponse['errorCode'] := FAULT_ERROR_PARAM
            oResponse['errorMessage'] := "O campo " + aCpoObg[nX] + " - " + AllTrim(GetSx3Cache(aCpoObg[nX], "X3_TITULO")) + "  obrigatorio!"
            return oResponse:ToJson()
        endIf

    next nX

    if nOpc == MATA010_INCLUI

        AADD(aMata010, {"B1_COD", getCodPrd(aMata010), Nil})

        //O campo B1_XN4 deve ser quebrado
        ajustaXN4(@aMata010)

    endIf

    mntMata010(@oResponse, oRequest, aMata010, nOpc, aCpoSB5)

return oResponse:ToJson()

/*/{Protheus.doc} AFIN002R
Replicao de produto
@type function
@version 12.1.0.25
@author fabricio.reche
@since 06/07/2020
@param cRequest, character, String Json da requisio
@return character, String Json de resposta
/*/
user function AFIN002R(cRequest)

    local nX := 0
    local nPos := 0
    local aEmp := {}
    local nRegs := 0
    local cDsProd := ""
    local oRequest := JsonObject():New()
    local oResponse := JsonObject():New()
    local cAliasTmp := ""
    
    oRequest:FromJson(cRequest)

    oResponse['errorMessage'] := ""
    oResponse['errorCode'] := 0
    oResponse['result'] := {}

    if Empty(oRequest['B1_FILIAL'])
        oResponse['errorCode'] := FAULT_ERROR_PARAM
        oResponse['errorMessage'] := "A filial do produto a ser replicado dever ser informado!"
        return oResponse:ToJson()
    endIf
    
    if Empty(oRequest['B1_COD'])
        oResponse['errorCode'] := FAULT_ERROR_PARAM
        oResponse['errorMessage'] := "O codigo do produto a ser replicado dever ser informado!"
        return oResponse:ToJson()
    endIf

    cDsProd := buscaDescProd(oRequest['B1_FILIAL'], oRequest['B1_COD'])

    if Empty(cDsProd)
        oResponse['errorCode'] := FAULT_ERROR_PARAM
        oResponse['errorMessage'] := "Nao foi possivel posicionar no produto " + oRequest['B1_FILIAL'] + " / " + oRequest['B1_COD'] + "!"
        return oResponse:ToJson()
    endIf

    if Empty(oRequest['FILIAIS'])
        oResponse['errorCode'] := FAULT_ERROR_PARAM
        oResponse['errorMessage'] := "E necessario informar as filiais para replica!"
        return oResponse:ToJson()
    endIf

    if ! Empty(cRet := integradoTeknisa(oRequest['B1_COD']))
        oResponse['errorCode'] := FAULT_ERROR_PARAM
        oResponse['errorMessage'] := "Produto nao integrado no teknisa: " + cRet
        return oResponse:ToJson()
    endIf

    //cria estrutura da tabela temporria
    cAliasTmp := StaticCall(MADERO_EST001, fGerTmpRes)

    for nX := 1 to Len(oRequest['FILIAIS'])

        //ignora a mesma filial de cópia
        if oRequest['FILIAIS'][nX] == oRequest['B1_FILIAL']
            loop
        endIf
    
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

    (cAliasTmp)->(DbGoTop())

    while (cAliasTmp)->( ! EoF() )

        AADD(oResponse['result'], JsonObject():New())

        nPos := Len(oResponse['result'])

        oResponse['result'][nPos]['result'] := JsonObject():New()

        oResponse['result'][nPos]['result']['B1_COD'] := AllTrim((cAliasTmp)->PRODUTO)
        oResponse['result'][nPos]['result']['B1_FILIAL'] := AllTrim((cAliasTmp)->FILIAL)
        oResponse['result'][nPos]['result']['F_NOME'] := AllTrim(FwFilialName((cAliasTmp)->EMPRESA, (cAliasTmp)->FILIAL))

        oResponse['result'][nPos]['errorCode'] := 0
        oResponse['result'][nPos]['errorMessage'] := GetErrorMessage((cAliasTmp)->MSGLOG, 90, (cAliasTmp)->EMPRESA, (cAliasTmp)->FILIAL)
        oResponse['result'][nPos]['errorMessage'] := IIF(Empty(oResponse['result'][nPos]['errorMessage']), AllTrim((cAliasTmp)->MSG), oResponse['result'][nPos]['errorMessage'])

        //caso tenha ocorrido erro em algum processamento
        if (cAliasTmp)->SUCESSO == REPLICA_ERRO //.Or. (cAliasTmp)->SUCESSO == REPLICA_NAO_PROCESSADO
            oResponse['result'][nPos]['errorCode'] := (cAliasTmp)->SUCESSO
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

return oResponse:ToJson()

/*/{Protheus.doc} AFIN002B
Funo para bloqueio de produtos
@type function
@version 12.1.0.25
@author fabricio.reche
@since 06/07/2020
@param cRequest, character, String json com a requisio do fluig
@return character, String json com a resposta da requisio
/*/
user function AFIN002B(cRequest)

    local nX := 0
    local aMata010 := {}
    local oRequest := JsonObject():New()
    local oResponse := JsonObject():New()
    
    //monta o objeto com o request
    oRequest:FromJson(cRequest)
    
    //monta o objeto de response
    oResponse['errorMessage'] := ""
    oResponse['errorCode'] := 0
    oResponse['result'] := {}

    if Empty(oRequest['B1_COD'])
        oResponse['errorCode'] := FAULT_ERROR_PARAM
        oResponse['errorMessage'] := "O cdigo do produto dever ser informado no bloqueio!"
        return oResponse:ToJson()
    endIf

    if Empty(oRequest['FILIAIS'])
        oResponse['errorCode'] := FAULT_ERROR_PARAM
        oResponse['errorMessage'] := "Filiais devem ser informadas!"
        return oResponse:ToJson()
    endIf

    if Empty(oRequest['B1_MSBLQL'])
        oResponse['errorCode'] := FAULT_ERROR_PARAM
        oResponse['errorMessage'] := "Deve indicar se deve bloquear!"
        return oResponse:ToJson()
    endIf

    //marca para no integrar tekinisa (Z13)
    _SetOwnerPrvt("lFacRep", .T.)

    oResponse['produto'] := oRequest['B1_COD']

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

return oResponse:ToJson()

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
@param aCpoSB5, array, Array de campos da SB5
/*/
static function mntMata010(oResponse, oRequest, aMata010, nOpc, aCpoSB5)

    local cJsonRes := ""
    local cJsonReq := ""
    local cFilBkp := cFilAnt
    local aEmp := getEmpresa(retFldArr(aMata010, "B1_FILIAL"))

    default aCpoSB5 := {}

    if oRequest != Nil
        cJsonReq := oRequest:ToJson()
    endIf

    //caso seja a mesma empresa
    if aEmp[1] == cEmpAnt

        //caso necessite alterar a filial
        if aEmp[2] != cFilAnt
            cFilAnt := aEmp[2]
        endIf

        cJsonRes := U_AFIN002J(, cJsonReq, aMata010, nOpc, aCpoSB5)

        //restaura backup da filial posicionada
        cFilAnt := cFilBkp

    else

        cJsonRes := StartJob("U_AFIN002J", GetEnvServer(), .T., aEmp, cJsonReq, aMata010, nOpc, aCpoSB5)

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
@param aCpoSB5, array, Campos da SB5 para atualizar
@return character, String Json da resposta
/*/
user function AFIN002J(aEmp, cJsonReq, aMata010, nOpc, aCpoSB5)

    local lAuto := ! Empty(aEmp)
    local oModel := Nil
    local nPosFld := 0
    local oResponse := JsonObject():New()
    local cPathErro := "\WSAFIN002\"
    local cFileErro := "mata010_erro" + FwTimeStamp() + ".log"
    local aCpoUpdat := {}
    local nX        := 0

    default aCpoSB5 := {}

//caso aEmp não tenha sido informado, não é preciso montar o ambiente, mas precisa de dados no array de empresa
    default aEmp := getEmpresa(retFldArr(aMata010, "B1_FILIAL"))

    private lMsErroAuto := .F.

    //caso aEmp não tenha sido informado, não é preciso montar o ambiente, mas precisa de dados no array de empresa
    default aEmp := getEmpresa(retFldArr(aMata010, "B1_FILIAL"))

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

    //confere se existem campos que devem ser removidos da rotina automtica e atualizados posteriormente
    aCpoUpdat := verCpoUpdate(@aMata010)

    //ordena o array conforme dicionrio de dados
    aMata010 := FwVetByDic(aMata010, "SB1")
    aCpoSB5 := FwVetByDic(aCpoSB5, "SB5")

    // MsExecAuto({|x, y| Mata010(x, y)}, aMata010, nOpc)

    //carrega o modelo de dados
    //erro no model, pois na ativação do modelo avalia a permissão de acesso do usuário
    __cUserId := "000000"
    cUserName := "admin"
    PswOrder(2)
    PswSeek( cUserName, .T. )

    oModel:= FwLoadModel("MATA010")
    oModel:SetOperation(nOpc)
    oModel:Activate()

    //Seta os valores do modelo de dados
    for nX := 1 to Len(aMata010)
        oModel:SetValue("SB1MASTER", aMata010[nX][1], aMata010[nX][2])
    next nX

    for nX := 1 to Len(aCpoSB5)
        oModel:SetValue("SB5DETAIL", aCpoSB5[nX][1], aCpoSB5[nX][2])
    next nX

    lMsErroAuto := ! oModel:VldData()

    if lMsErroAuto

        oResponse['errorCode'] := MATA010_ERROR

        MakeDir(cPathErro)
        // MostraErro(cPathErro, cFileErro)
        MontaErro(cPathErro + cFileErro, oModel:GetErrorMessage())

        oModel:DeActivate()
        oModel:Destroy()

        oResponse['errorMessage'] := GetErrorMessage(MemoRead(cPathErro + cFileErro), 80, aEmp[1], aEmp[2])
        oResponse['errorLog'] := cPathErro + cFileErro

        if Empty(oResponse['errorMessage'])
            oResponse['errorMessage'] := "Ocorreu um erro interno na rotina automatica MATA010"
        endIf

        oResponse['mata010Params'] := retMt10Par(aMata010)

        return oResponse:toJson()

    endIf

    //confirma os dados do model, desativa e destroi o objeto
    oModel:CommitData()    
    oModel:DeActivate()
    oModel:Destroy()

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

    //funo de replica de produtos (MADERO_EST001)
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
@param cdEmpresa, character, Cdigo da Empresa
@param cdFilial, character, Cdigo da Filial
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

            //caso tenha pego o comeo da mensagem de erro, mas no seu final
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
Retorna array com campos a serem atualizados fora da rotina automtica
@type function
@version 12.1.0.25
@author fabricio.reche
@since 15/06/2020
@param aMata010, array, Array da rotina automtica
@return array, Array de campos removidos do array da rotina automtica
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
Monta o array da rotina automtica pelo objeto de requisio
@type function
@version 12.1.0.25
@author fabricio.reche
@since 15/06/2020
@param oRequest, object, JsonObject instanciado com os dados de requisio
@param cTabela, character, Nome da tabela a ser verificada existencia
@return array, Array da rotina automtica preenchida
/*/
static function mntAutoArr(oRequest, cTabela)

    local aMata010 := {}
    local aProps := oRequest:GetNames()
    local cCampo := ""
    local uValor := Nil
    local nX := 0

    default cTabela := "SB1"

    for nX := 1 to Len(aProps)

        cCampo := AllTrim(aProps[nX])
        uValor := AjustaCampo(cCampo, oRequest[cCampo])

        //caso seja uma propriedade que no tem no dicionrio de dados ou contedo vazio
        if ! campoExiste(cTabela, cCampo) .Or. Empty(uValor)
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

/*/{Protheus.doc} MontaErro
Cria o arquivo de erro
@type function
@version 12.1.0.25
@author fabricio.reche
@since 20/08/2020
@param cFileErro, character, Arquivo a ser criado
@param aErrorLog, array, Array com os erros
/*/
static function MontaErro(cFileErro, aErrorLog)

    local cErrorLog := ""

    cErrorLog += "Id do formulário de origem:" + ' [' + AllToChar( aErrorLog[1] ) + ']'  + CRLF
    cErrorLog += "Id do campo de origem: "     + ' [' + AllToChar( aErrorLog[2] ) + ']'  + CRLF
    cErrorLog += "Id do formulário de erro: "  + ' [' + AllToChar( aErrorLog[3] ) + ']'  + CRLF
    cErrorLog += "Id do campode erro: "        + ' [' + AllToChar( aErrorLog[4] ) + ']'  + CRLF
    cErrorLog += "Id do erro: "                + ' [' + AllToChar( aErrorLog[5] ) + ']'  + CRLF
    cErrorLog += "Mensagem do erro: "          + ' [' + AllToChar( aErrorLog[6] ) + ']'  + CRLF
    cErrorLog += "Mensagem da solução: "       + ' [' + AllToChar( aErrorLog[7] ) + ']'  + CRLF
    cErrorLog += "Valor atribuído: "           + ' [' + AllToChar( aErrorLog[8] ) + ']'  + CRLF
    cErrorLog += "Valor anterior: "            + ' [' + AllToChar( aErrorLog[9] ) + ']'  + CRLF

    MemoWrite(cFileErro, cErrorLog)

return

/*/{Protheus.doc} campoExiste
Verifica se o campo existe na tabela de dados
@type function
@version 12.1.0.25
@author fabricio.reche
@since 21/08/2020
@param cTabela, character, Tabela de dados para conferência
@param cCampo, character, Nome do campo para conferência
@return logical, Indica se o campo existe
/*/
static function campoExiste(cTabela, cCampo)

    //caso seja um campo Memo Virtual
    if GetSx3Cache(cCampo, "X3_ARQUIVO") == cTabela .And. GetSx3Cache(cCampo, "X3_TIPO") == "M" .And. GetSx3Cache(cCampo, "X3_CONTEXT") == "V"
        return .T.
    endIf

    //caso seja um campo real do banco
    if (cTabela)->(FieldPos(cCampo)) > 0
        return .T.
    endIf

return .F.
