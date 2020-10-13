#include 'protheus.ch'
#include 'restful.ch'

WsRestful AFIN001 Description "Servio REST para consultas genricas"

wsData cdProduto as String
wsData cdFilial as String
wsData Campos as String
wsData Filtros as String
wsData CamposExtras as String

WsMethod GET Description "Retorna se o servios est funcionando corretamente" WSSYNTAX "/AFIN001" PATH "/AFIN001"

WsMethod GET ADKPRD Description "Consulta de Empresa/Filial" WSSYNTAX "/AFIN001/ADKPRD" PATH "/AFIN001/ADKPRD"
WsMethod GET ADK Description "Consulta de Empresa/Filial" WSSYNTAX "/AFIN001/ADK" PATH "/AFIN001/ADK"
WsMethod GET SB1 Description "Consulta de Produto" WSSYNTAX "/AFIN001/SBM" PATH "/AFIN001/SB1"
WsMethod GET SBM Description "Consulta de Grupo de Produto" WSSYNTAX "/AFIN001/SBM" PATH "/AFIN001/SBM"
WsMethod GET XTP Description "Consulta de Tipos de Produtos" WSSYNTAX "/AFIN001/XTP" PATH "/AFIN001/XTP"
WsMethod GET XCL Description "Consulta de Classificao de Produto" WSSYNTAX "/AFIN001/XCL" PATH "/AFIN001/XCL"
WsMethod GET TIP Description "Consulta de Tipos de Materiais" WSSYNTAX "/AFIN001/TIP" PATH "/AFIN001/TIP"
WsMethod GET SAH Description "Consulta de Unidades de Medidas" WSSYNTAX "/AFIN001/SAH" PATH "/AFIN001/SAH"
WsMethod GET NNR Description "Consulta de Locais de Estoque" WSSYNTAX "/AFIN001/NNR" PATH "/AFIN001/NNR"
WsMethod GET CTT Description "Consulta de Centro de Custo" WSSYNTAX "/AFIN001/CTT" PATH "/AFIN001/CTT"
WsMethod GET CTD Description "Consulta de Item Contbil" WSSYNTAX "/AFIN001/CTD" PATH "/AFIN001/CTD"
WsMethod GET CT1 Description "Consulta de Plano de Contas" WSSYNTAX "/AFIN001/CT1" PATH "/AFIN001/CT1"
WsMethod GET SYD Description "Consulta de Nomenclatura Comum do Mercosul" WSSYNTAX "/AFIN001/SYD" PATH "/AFIN001/SYD"
WsMethod GET TS0 Description "Consulta de Tabela de Origem" WSSYNTAX "/AFIN001/TS0" PATH "/AFIN001/TS0"
WsMethod GET XNX Description "Consulta de Nivel 4 - Grupos Tekniza" WSSYNTAX "/AFIN001/XNX" PATH "/AFIN001/XNX"
WsMethod GET SAJ Description "Consulta de Grupos de compras" WSSYNTAX "/AFIN001/SAJ" PATH "/AFIN001/SAJ"
WsMethod GET T60 Description "Consulta de Cdigos de Servio de ISS" WSSYNTAX "/AFIN001/T60" PATH "/AFIN001/T60"
WsMethod GET DB0 Description "Consulta de Modelos de Carga" WSSYNTAX "/AFIN001/DB0" PATH "/AFIN001/DB0"
WsMethod GET F0G Description "Consulta de Cod. Especificador ST - CEST" WSSYNTAX "/AFIN001/F0G" PATH "/AFIN001/F0G"
WsMethod GET F08 Description "Consulta de Cd. Enquadramento Legal IPI" WSSYNTAX "/AFIN001/F08" PATH "/AFIN001/F08"
WsMethod GET TZ4 Description "Consulta de Produtos No Submetidos a Tratamento Trmico" WSSYNTAX "/AFIN001/TZ4" PATH "/AFIN001/TZ4"
WsMethod GET TZ6 Description "Consulta de Produto Acabado" WSSYNTAX "/AFIN001/TZ6" PATH "/AFIN001/TZ6"
WsMethod GET TZ7 Description "Consulta de Submetido a Tratamento Trmico" WSSYNTAX "/AFIN001/TZ7" PATH "/AFIN001/TZ7"
WsMethod GET TZD Description "Consulta de Carne Congelada de Ovino sem Osso" WSSYNTAX "/AFIN001/TZD" PATH "/AFIN001/TZD"
WsMethod GET TW1 Description "Consulta de Modo de Conservao" WSSYNTAX "/AFIN001/TW1" PATH "/AFIN001/TW1"
WsMethod GET TW2 Description "Consulta de genrica de Alergenicos" WSSYNTAX "/AFIN001/TW2" PATH "/AFIN001/TW2"
WsMethod GET Z61 Description "Consulta Especifica de Alergenicos" WSSYNTAX "/AFIN001/Z61" PATH "/AFIN001/Z61"
WsMethod GET CB3 Description "Consulta de Tipos de Embalagem" WSSYNTAX "/AFIN001/CB3" PATH "/AFIN001/CB3"
WsMethod GET DC4 Description "Consulta de Zona de Armazenagem" WSSYNTAX "/AFIN001/DC4" PATH "/AFIN001/DC4"
WsMethod GET SBE Description "Consulta de Endereos" WSSYNTAX "/AFIN001/SBE" PATH "/AFIN001/SBE"
WsMethod GET SG2 Description "Consulta de Operaes" WSSYNTAX "/AFIN001/SG2" PATH "/AFIN001/SG2"
WsMethod GET SM4 Description "Consulta de Frmulas" WSSYNTAX "/AFIN001/SM4" PATH "/AFIN001/SM4"
WsMethod GET T21 Description "Consulta de Grupo de Tributao" WSSYNTAX "/AFIN001/T21" PATH "/AFIN001/T21"

End WsRestful

/*/{Protheus.doc} 
GET: retorna se o servio est operante com os dados do fonte
@type function
@version 12.1.0.25
@author fabricio.reche
@since 02/06/2020
/*/
WsMethod GET WsReceive Filtros WsService AFIN001

    local oRet := JsonObject():New()
    local aPrw := GetAPOInfo("MADERO_WS_AFIN001.prw")

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

WsMethod GET ADKPRD WsReceive cdProduto, Filtros WsService AFIN001

    local oResponse := JsonObject():New()
    local oEmpresa := Nil
    local _cQuery := ""
    local _cAlias := ""
    local cProp := ""

    if Empty(::cdProduto)
        SetRestFault(3, "O codigo do produto deve ser informado!")
        return .F.
    endIf

    oResponse['produto'] := ::cdProduto
    oResponse['errorMessage'] := ""
    oResponse['errorCode'] := 0
    oResponse['result'] := JsonObject():New()
    oResponse['result']['tem'] := {}
    oResponse['result']['naoTem'] := {}

    ADK->(DbGoTop())

    while ADK->( ! EoF() )

        if ADK->ADK_MSBLQL == '1'
            ADK->( DbSkip() )
            loop
        endIf

        if ! Empty(::Filtros)
            
            DbSelectArea("ADK")
            
            if ! &(::Filtros)
                ADK->( DbSkip() )
                loop
            endIf

        endIf

        oEmpresa := JsonObject():New()
        oEmpresa['descricao'] := AllTrim(ADK->ADK_NOME)
        oEmpresa['grupo'] := AllTrim(ADK->ADK_XGEMP)
        oEmpresa['filial'] := AllTrim(ADK->ADK_XFILI)

        _cQuery := ""
        _cQuery += " select B1_MSBLQL "
        _cQuery += " from SB1" + oEmpresa['grupo'] + "0 SB1 "
        _cQuery += " where SB1.D_E_L_E_T_ = ' ' and B1_FILIAL = " + ValToSql(oEmpresa['filial'])
        _cQuery += "   and B1_COD = " + ValToSql(::cdProduto)

        _cAlias := MPSysOpenQuery(_cQuery)

        cProp := IIF((_cAlias)->( ! EoF() ), "tem", "naoTem")

        oEmpresa['B1_MSBLQL'] := AllTrim((_cAlias)->B1_MSBLQL)
    
        (_cAlias)->( DbCloseArea() )

        AADD(oResponse['result'][cProp], oEmpresa)

        ADK->( DbSkip() )

    endDo

    oResponse['resultCountNaoTem'] := Len(oResponse['result']['naoTem'])
    oResponse['resultCountTem'] := Len(oResponse['result']['tem'])
    oResponse['resultCount'] := oResponse['resultCountTem'] + oResponse['resultCountNaoTem']

    ::SetContentType("application/json")
    ::SetResponse(oResponse:ToJson())

return .T.

/*/{Protheus.doc} 
GET ADK: Retorna as empresas/filiais do sistema
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET ADK WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " SELECT ADK_XNEGOC, ZA.X5_DESCRI ADK_XNEGOCD, ADK_XSEGUI, "
    cQuery += "        ZB.X5_DESCRI ADK_XSEGUID, ADK_NOME, ADK_XFILI, ADK_RESP, "
    cQuery += "        ADK_RAZAO, ADK_XGEMP, ADK_XFIL, ADK_COD, ADK_EMAIL, ADK_XGNEG "
    cQuery += " FROM ${RetSqlTab('ADK')} "
    cQuery += " LEFT JOIN ${RetSqlName('SX5')} ZA "
    cQuery += " ON ZA.X5_TABELA   = 'ZA'       AND "
    cQuery += "    ZA.X5_CHAVE    = ADK_XNEGOC AND "
    cQuery += "    ZA.D_E_L_E_T_ <> '*' "
    cQuery += " LEFT JOIN ${RetSqlName('SX5')} ZB "
    cQuery += " ON ZB.X5_TABELA   = 'ZB'       AND "
    cQuery += "    ZB.X5_CHAVE    = ADK_XSEGUI AND "
    cQuery += "    ZB.D_E_L_E_T_ <> '*' "
    cQuery += " WHERE ADK.D_E_L_E_T_ <> '*' AND "
    cQuery += "       ADK.ADK_MSBLQL <> '1' "

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET SB1: Retorna o cadastro do Produto
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET SB1 WsReceive Filtros, Campos, CamposExtras WsService AFIN001

    local aCposExt := {}
    local aTabelas := {"SB1"}
    local cQuery := ""
    local oRet := Nil
    local nX := 0

    default ::Campos := ""
    default ::CamposExtras := ""

    if Empty(::Campos)

        ::Campos += "B1_FILIAL,B1_ALIQISS,B1_ALTER,B1_APROPRI,B1_CATMAPA,B1_CC,B1_CCCUSTO,B1_CEST,B1_COD,B1_XN1,"
        ::Campos += "B1_CODBAR,B1_CODGTIN,B1_CODISS,B1_COFINS,B1_CONTA,B1_CONTSOC,B1_CONV,B1_CRECMAP,B1_CSLL,"
        ::Campos += "B1_CTACUST,B1_CTADESP,B1_CTAREC,B1_CTATRAN,B1_CUSTD,B1_DESC,B1_EMAX,B1_EMIN,B1_ESTSEG,B1_XN2,"
        ::Campos += "B1_FANTASM,B1_FORMLOT,B1_GRPCST,B1_GRTRIB,B1_GRUPCOM,B1_GRUPO,B1_INSS,B1_IPI,B1_IRRF,B1_XTOOP,"
        ::Campos += "B1_ITEMCC,B1_LE,B1_LM,B1_LOCALIZ,B1_LOCPAD,B1_MCUSTD,B1_MRP,B1_MSBLQL,B1_NOTAMIN,B1_NUMCQPR,"
        ::Campos += "B1_OPERPAD,B1_ORIGEM,B1_PACAMAP,B1_PCOFINS,B1_PCSLL,B1_PE,B1_PESBRU,B1_PESO,B1_PESOMAP,B1_XTIPO,"
        ::Campos += "B1_PIS,B1_POSIPI,B1_PPIS,B1_PRECMAP,B1_PRODSBP,B1_PRV1,B1_PRVALID,B1_QE,B1_RASTRO,B1_REDCOF,B1_XN3,"
        ::Campos += "B1_REDINSS,B1_REDIRRF,B1_REDPIS,B1_SEGUM,B1_TALLA,B1_TIPCONV,B1_TIPE,B1_TIPO,B1_TIPOCQ,B1_TOLER,"
        ::Campos += "B1_UM,B1_VLR_COF,B1_VLR_ICM,B1_VLR_IPI,B1_VLR_PIS,B1_XALERG,B1_XCLAS,B1_XCODARV,B1_XCODEXT,B1_XCONS,"
        ::Campos += "B1_XDIAES,B1_XGLUT,B1_XINFNUT,B1_XLACTOS,B1_XLOCAL,B1_XN4,B1_XPADMAP,B1_XPEMB,B1_XRMAPA,B1_XTARA,"
        ::Campos += "B1_TIPCAR,B1_VM_PROC,B1_XUSER,B5_ALTURLC,B5_CEME,B5_COD,B5_CODZON,B5_COMPRLC,B5_DES,B5_EMB1,B5_EMB2,"
        ::Campos += "B5_EMPMAX,B5_ENDDEV,B5_ENDECD,B5_ENDENT,B5_ENDREQ,B5_ENDSAI,B5_ENDSCD,B5_ESPESS,B5_IMPETI,B5_LARGLC,"
        ::Campos += "B5_PESO,B5_QE1,B5_QE2,B5_QEI,B5_QEL,B5_QTDVAR,B5_TIPUNIT,B5_UMIND"

    endIf

    //caso tenha sido enviado campos extras a consulta
    if ! Empty(::CamposExtras)

        aCposExt := Separa(::CamposExtras, ",", .F.)

        //garante que não vai repetir campos
        for nX := 1 to Len(aCposExt)

            if ! aCposExt[nX] $ ::Campos
                ::Campos += IIF(Empty(::Campos), "", ",")
                ::Campos += AllTrim(aCposExt[nX])
            endIf

        next nX

    endIf

    //verifica se existem campos memos virtuais nos campos
    if verCposMemos(@::Campos)
        AADD(aTabelas, "SYP")
    endIf

    cQuery += " SELECT " + ::Campos
    cQuery += " FROM XXXSB1 SB1"

    //caso esteja consultando campos da SB5 também
    if "B5_" $ ::Campos

        AADD(aTabelas, "SB5")

        cQuery += " LEFT JOIN XXXSB5 SB5 "
        cQuery += "   ON SB5.D_E_L_E_T_ = ' ' "
        cQuery += "  AND SB5.B5_FILIAL = SB1.B1_FILIAL "
        cQuery += "  AND SB5.B5_COD = SB1.B1_COD "

    endIf

    cQuery += " WHERE SB1.D_E_L_E_T_=' '"
    
    cQuery := sqlMultEmp(cQuery, aTabelas, {"01", "02"})

    //caso tenha filtros a aplicar
    if ! Empty(::Filtros)
        cQuery += " WHERE " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET SBM: Retorna os dados do cadastro de grupo de produto
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET SBM WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select BM_GRUPO, BM_DESC "
    cQuery += " from ${RetSqlTab('SBM')} "
    cQuery += " where ${RetSqlCond('SBM')}"

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET XTP: Retorna da tabela genrica Tipos de Produtos
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET XTP WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select X5_CHAVE XTP_CODIGO, X5_DESCRI XTP_DESCRI  "
    cQuery += " from ${RetSqlTab('SX5')} "
    cQuery += " where ${RetSqlCond('SX5')}"
    cQuery += "   and X5_TABELA = 'Z2' " 

    if ! Empty(::Filtros)
        ::Filtros := StrTran(::Filtros, "XTP_CODIGO", "X5_CHAVE")
        ::Filtros := StrTran(::Filtros, "XTP_DESCRI", "X5_DESCRI")
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET XCL: Retorna da tabela genrica Classificao de Produto
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET XCL WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select X5_CHAVE XCL_CODIGO, X5_DESCRI XCL_DESCRI  "
    cQuery += " from ${RetSqlTab('SX5')} "
    cQuery += " where ${RetSqlCond('SX5')}"
    cQuery += "   and X5_TABELA = 'Z3' " 

    if ! Empty(::Filtros)
        ::Filtros := StrTran(::Filtros, "XCL_CODIGO", "X5_CHAVE")
        ::Filtros := StrTran(::Filtros, "XCL_DESCRI", "X5_DESCRI")
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET TIP: Retorna da tabela genrica Tipos de Materiais
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET TIP WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select X5_CHAVE TIP_CODIGO, X5_DESCRI TIP_DESCRI  "
    cQuery += " from ${RetSqlTab('SX5')} "
    cQuery += " where ${RetSqlCond('SX5')}"
    cQuery += "   and X5_TABELA = '02' " 

    if ! Empty(::Filtros)
        ::Filtros := StrTran(::Filtros, "TIP_CODIGO", "X5_CHAVE")
        ::Filtros := StrTran(::Filtros, "TIP_DESCRI", "X5_DESCRI")
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET SAH: Retorna o cadastro de Unidades de Medidas
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET SAH WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select AH_UNIMED, AH_DESCPO "
    cQuery += " from ${RetSqlTab('SAH')} "
    cQuery += " where ${RetSqlCond('SAH')}"

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET NNR: Retorna o cadastro de Locais de Estoque
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET NNR WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select NNR_CODIGO, NNR_DESCRI "
    cQuery += " from ${RetSqlTab('NNR')} "
    cQuery += " where ${RetSqlCond('NNR')}"

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET CTT: Retorna o cadastro de Centro de Custo
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET CTT WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select CTT_CUSTO, CTT_DESC01 "
    cQuery += " from ${RetSqlTab('CTT')} "
    cQuery += " where ${RetSqlCond('CTT')}"
    cQuery += "   and CTT_CLASSE <> '1' " //Nao deve buscar centro de custos sintéticos
    cQuery += "   and CTT_BLOQ <> '1' " //Nao deve trazer bloqueados

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET CTD: Retorna o cadastro de Item Contbil
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET CTD WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select CTD_ITEM, CTD_DESC01 "
    cQuery += " from ${RetSqlTab('CTD')} "
    cQuery += " where ${RetSqlCond('CTD')}"
    cQuery += "   and CTD_CLASSE <> '1' "
    cQuery += "   and CTD_BLOQ <> '1' "

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET CT1: Retorna o cadastro de Plano de Contas
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET CT1 WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select CT1_CONTA, CT1_DESC01 "
    cQuery += " from ${RetSqlTab('CT1')} "
    cQuery += " where ${RetSqlCond('CT1')}"
    cQuery += "   and CT1_CLASSE <> '1' "
    cQuery += "   and CT1_BLOQ <> '1' "

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET SYD: Retorna o cadastro de Nomenclatura Comum do Mercosul
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET SYD WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select YD_TEC, YD_DESC_P, YD_PER_IPI "
    cQuery += " from ${RetSqlTab('SYD')} "
    cQuery += " where ${RetSqlCond('SYD')}"

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET TS0: Retorna o cadastro de Tabela de Origem
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET TS0 WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select X5_CHAVE TS0_CODIGO, X5_DESCRI TS0_DESCRI  "
    cQuery += " from ${RetSqlTab('SX5')} "
    cQuery += " where ${RetSqlCond('SX5')}"
    cQuery += "   and X5_TABELA = 'S0' " 

    if ! Empty(::Filtros)
        ::Filtros := StrTran(::Filtros, "TS0_CODIGO", "X5_CHAVE")
        ::Filtros := StrTran(::Filtros, "TS0_DESCRI", "X5_DESCRI")
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET XNX: Retorna o cadastro de Nivel 4 - Grupos Tekniza
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET XNX WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select Z21_CODN1||Z21_CODN2||Z21_CODN3||Z21_CODN4 XNX_COD "
    cQuery += "       ,RTRIM(Z21_DESCN1)||'-'||RTRIM(Z21_DESCN2)||'-'||RTRIM(Z21_DESCN3)||'-'||RTRIM(Z21_DESCN4) XNX_DESC"
    cQuery += " from ${RetSqlTab('Z21')} "
    cQuery += " where ${RetSqlCond('Z21')}"

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET SAJ: Retorna o cadastro de Grupos de compras
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET SAJ WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select AJ_GRCOM, AJ_USER, AJ_US2NAME, AJ_DESC "
    cQuery += " from ${RetSqlTab('SAJ')} "
    cQuery += " where ${RetSqlCond('SAJ')}"

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    cQuery += " group by AJ_GRCOM, AJ_USER, AJ_US2NAME, AJ_DESC "

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET T60: Retorna a tabela genrica de Cdigos de Servio de ISS
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET T60 WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select X5_CHAVE T60_CODIGO, X5_DESCRI T60_DESCRI  "
    cQuery += " from ${RetSqlTab('SX5')} "
    cQuery += " where ${RetSqlCond('SX5')}"
    cQuery += "   and X5_TABELA = '60' " 

    if ! Empty(::Filtros)
        ::Filtros := StrTran(::Filtros, "T60_CODIGO", "X5_CHAVE")
        ::Filtros := StrTran(::Filtros, "T60_DESCRI", "X5_DESCRI")
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET DB0: Retorna o cadastro de Modelos de Carga
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET DB0 WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select DB0_CODMOD, DB0_DESMOD "
    cQuery += " from ${RetSqlTab('DB0')} "
    cQuery += " where DB0.D_E_L_E_T_ = ' ' "

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET F0G: Retorna o cadastro de Cod. Especificador ST - CEST
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET F0G WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select F0G_CEST, F0G_DESCRI "
    cQuery += " from ${RetSqlTab('F0G')} "
    cQuery += " where ${RetSqlCond('F0G')}"

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET F08: Retorna o cadastro de Cd. Enquadramento Legal IPI
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET F08 WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select F08_CODIGO, F08_DESCRI "
    cQuery += " from ${RetSqlTab('F08')} "
    cQuery += " where ${RetSqlCond('F08')}"

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET TZ4: Retorna a tabela genrica de Produtos No Submetidos a Tratamento Trmico
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET TZ4 WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select X5_CHAVE TZ4_CODIGO, X5_DESCRI TZ4_DESCRI  "
    cQuery += " from ${RetSqlTab('SX5')} "
    cQuery += " where ${RetSqlCond('SX5')}"
    cQuery += "   and X5_TABELA = 'Z4' " 

    if ! Empty(::Filtros)
        ::Filtros := StrTran(::Filtros, "TZ4_CODIGO", "X5_CHAVE")
        ::Filtros := StrTran(::Filtros, "TZ4_DESCRI", "X5_DESCRI")
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET TZ6: Retorna a tabela genrica de Produto Acabado
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET TZ6 WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select X5_CHAVE TZ6_CODIGO, X5_DESCRI TZ6_DESCRI  "
    cQuery += " from ${RetSqlTab('SX5')} "
    cQuery += " where ${RetSqlCond('SX5')}"
    cQuery += "   and X5_TABELA = 'Z6' " 

    if ! Empty(::Filtros)
        ::Filtros := StrTran(::Filtros, "TZ6_CODIGO", "X5_CHAVE")
        ::Filtros := StrTran(::Filtros, "TZ6_DESCRI", "X5_DESCRI")
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET TZ7: Retorna a tabela genrica de Submetido a Tratamento Trmico
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET TZ7 WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select X5_CHAVE TZ7_CODIGO, X5_DESCRI TZ7_DESCRI  "
    cQuery += " from ${RetSqlTab('SX5')} "
    cQuery += " where ${RetSqlCond('SX5')}"
    cQuery += "   and X5_TABELA = 'Z7' " 

    if ! Empty(::Filtros)
        ::Filtros := StrTran(::Filtros, "TZ7_CODIGO", "X5_CHAVE")
        ::Filtros := StrTran(::Filtros, "TZ7_DESCRI", "X5_DESCRI")
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET TZD: Retorna a tabela genrica de Carne Congelada de Ovino sem Osso
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET TZD WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select X5_CHAVE TZD_CODIGO, X5_DESCRI TZD_DESCRI  "
    cQuery += " from ${RetSqlTab('SX5')} "
    cQuery += " where ${RetSqlCond('SX5')}"
    cQuery += "   and X5_TABELA = 'ZD' " 

    if ! Empty(::Filtros)
        ::Filtros := StrTran(::Filtros, "TZD_CODIGO", "X5_CHAVE")
        ::Filtros := StrTran(::Filtros, "TZD_DESCRI", "X5_DESCRI")
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET TW1: Retorna a tabela genrica de Modo de Conservao
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET TW1 WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select X5_CHAVE TW1_CODIGO, X5_DESCRI TW1_DESCRI  "
    cQuery += " from ${RetSqlTab('SX5')} "
    cQuery += " where ${RetSqlCond('SX5')}"
    cQuery += "   and X5_TABELA = 'W1' " 

    if ! Empty(::Filtros)
        ::Filtros := StrTran(::Filtros, "TW1_CODIGO", "X5_CHAVE")
        ::Filtros := StrTran(::Filtros, "TW1_DESCRI", "X5_DESCRI")
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET TW2: Retorna a tabela genrica de Alergenicos
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET TW2 WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select X5_CHAVE TW2_CODIGO, X5_DESCRI TW2_DESCRI  "
    cQuery += " from ${RetSqlTab('SX5')} "
    cQuery += " where ${RetSqlCond('SX5')}"
    cQuery += "   and X5_TABELA = 'W2' " 

    if ! Empty(::Filtros)
        ::Filtros := StrTran(::Filtros, "TW2_CODIGO", "X5_CHAVE")
        ::Filtros := StrTran(::Filtros, "TW2_DESCRI", "X5_DESCRI")
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET Z61: Retorna a tabela Especifica de Alergenicos
@type function
@version 12.1.0.25
@author fabricio.reche
@since 06/08/2020
/*/
WsMethod GET Z61 WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    //confere se a tabela existe no dicionário de dados
    if ! AliasInDic("Z61")
        SetRestFault(99, "Tabela de Alergenicos nao criada")
        return .F.
    endIf

    cQuery += " select Z61_COD, Z61_ALERG "
    cQuery += " from ${RetSqlTab('Z61')} "
    cQuery += " where ${RetSqlCond('Z61')} "

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET CB3: Retorna o cadastro de Tipos de Embalagem
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET CB3 WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select CB3_CODEMB, CB3_DESCRI "
    cQuery += " from ${RetSqlTab('CB3')} "
    cQuery += " where CB3.D_E_L_E_T_ = ' ' "

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET DC4: Retorna o cadastro de Zona de Armazenagem
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET DC4 WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select DC4_CODZON, DC4_DESZON "
    cQuery += " from ${RetSqlTab('DC4')} "
    cQuery += " where DC4.D_E_L_E_T_ = ' ' "

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET SBE: Retorna o cadastro de Endereos
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
/*/
WsMethod GET SBE WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select BE_FILIAL, BE_LOCALIZ, BE_LOCAL, BE_DESCRIC "
    cQuery += " from ${RetSqlTab('SBE')} "
    cQuery += " where SBE.D_E_L_E_T_ = ' ' "

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET SG2: Retorna o cadastro de operaes
@type function
@version 12.1.0.25
@author fabricio.reche
@since 04/06/2020
/*/
WsMethod GET SG2 WsReceive Filtros, cdProduto WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    if Empty(::cdProduto)
        SetRestFault(3, "O codigo do produto deve ser informado!")
        return .F.
    endIf

    cQuery += " select G2_FILIAL, G2_CODIGO, G2_DESCRI "
    cQuery += " from ${RetSqlTab('SG2')} "
    cQuery += " where SG2.D_E_L_E_T_ = ' ' "
    cQuery += "   and G2_PRODUTO = " + ValToSql(::cdProduto)

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET SM4: Retorna o cadastro de frmulas
@type function
@version 12.1.0.25
@author fabricio.reche
@since 05/06/2020
/*/
WsMethod GET SM4 WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select M4_FILIAL, M4_CODIGO, M4_DESCR "
    cQuery += " from ${RetSqlTab('SM4')} "
    cQuery += " where SM4.D_E_L_E_T_ = ' ' "

    if ! Empty(::Filtros)
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} 
GET T21: Retorna a tabela genrica de Grupo Tributrio
@type function
@version 12.1.0.25
@author fabricio.reche
@since 05/06/2020
/*/
WsMethod GET T21 WsReceive Filtros WsService AFIN001

    local cQuery := ""
    local oRet := Nil

    cQuery += " select X5_CHAVE T21_CODIGO, X5_DESCRI T21_DESCRI  "
    cQuery += " from ${RetSqlTab('SX5')} "
    cQuery += " where ${RetSqlCond('SX5')}"
    cQuery += "   and X5_TABELA = '21' " 

    if ! Empty(::Filtros)
        ::Filtros := StrTran(::Filtros, "T21_CODIGO", "X5_CHAVE")
        ::Filtros := StrTran(::Filtros, "T21_DESCRI", "X5_DESCRI")
        cQuery += " AND " + ::Filtros
    endIf

    oRet := objetoConsulta(cQuery)

    //caso tenha ocorrido erro na consulta
    if oRet['errorCode'] > 0
        SetRestFault(oRet['errorCode'], oRet['errorMessage'])
        return .F.
    endIf

    ::SetContentType("application/json")
    ::SetResponse(oRet:ToJson())

return .T.

/*/{Protheus.doc} objetoConsulta
Confere, ::Filtros empresa/filial para retornar o objeto de uma consulta
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
@param cQuery, character, Consulta a ser realizada
@param cdEmpresa, character, Cdigo da empresa
@param cdFilial, character, Cdigo da filial
@return object, Objeto Json com o retorno da consulta
/*/
static function objetoConsulta(cQuery, cdEmpresa, cdFilial)

    local cJson := ""
    local oObj := JsonObject():New()
    
    default cdEmpresa := cEmpAnt
    default cdFilial := cFilAnt

    //valores padres, quando ocorre erro na consulta
    oObj['errorMessage'] := "Ocorreu um erro ao montar a estrutura da consulta"
    oObj['errorCode'] := 2
    oObj['resultCount'] := 0
    oObj['result'] := {}

    cJson := StartJob("U_AFIN001J", GetEnvServer(), .T., cQuery, cdEmpresa, cdFilial)

    if ! Empty(cJson)
        oObj:FromJson(cJson)
    endIf

return oObj

/*/{Protheus.doc} AFIN001J
Job de execuo de consultas, para funcionar para qualquer empresa
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
@param cQuery, character, Consulta a ser realizada
@param cdEmpresa, character, Cdigo da empresa
@param cdFilial, character, Cdigo da filial
@return character, String Json com o retorno da consulta (o retorno desta funo precisa ser String)
/*/
user function AFIN001J(cQuery, cdEmpresa, cdFilial)

    local _cAlias := ""
    local lAuto   := Type("cEmpAnt") != "C"
    local cTipo   := ""
    local oRet    := JsonObject():New()
    local nPos    := 0
    local nDec    := 0 
    local nTam    := 0 
    local nX      := 0

    //quando executado por StartJob, prepara o ambiente
    if lAuto
        RpcSetType(3)
        RpcSetEnv(cdEmpresa, cdFilial)
    endIf

    oRet['errorMessage'] := ""
    oRet['errorCode'] := 0
    oRet['result'] := {}

    cQuery := ajustaEmp(cQuery)
    
    _cAlias := MPSysOpenQuery(cQuery)
    
    while (_cAlias)->( ! EoF() )
    
        AADD(oRet['result'], JsonObject():New())

        nPos := Len(oRet['result'])

        for nX := 1 to (_cAlias)->(fCount())

            cCampo := (_cAlias)->(Field(nX))

            //caso o campo esteja no dicionrio, ajusta na query
            if nPos <= 1
                
                cTipo  := GetSx3Cache(cCampo, "X3_TIPO")
                nDec   := GetSx3Cache(cCampo, "X3_DECIMAL")
                nTam   := GetSx3Cache(cCampo, "X3_TAMANHO")

                //caso tenha encontrado o campo no dicionrio e ele seja data, numrico ou lgico
                if ! Empty(cTipo) .And. cTipo $ "DLN"
                    TcSetField(_cAlias, cCampo, cTipo, nTam, nDec)
                endIf

            endIf

            oRet['result'][nPos][cCampo] := AjustaCampo((_cAlias)->(FieldGet(nX)))

        next nX

        (_cAlias)->( DbSkip() )
    
    endDo
    
    (_cAlias)->( DbCloseArea() )
    
    oRet['resultCount'] := Len(oRet['result'])
    oRet['errorMessage'] := IIF(Empty(oRet['resultCount']), "Nenhum registro localizado", oRet['errorMessage'])
    //Quando chamado por startJob, no precisa fazer RpcClearEnv

return oRet:ToJson() //retorno deve ser string, por causa do StartJob (apenas dados primitivos)

/*/{Protheus.doc} ajustaEmp
Funo genrica para ajustar aquery, para remover as tag ${FUNCAO} com suas devidas funes
@type function
@version 12.1.0.25
@author fabricio.reche
@since 02/06/2020
@param cQuery, character, Query a ser ajustada
@return character, Query ajustada
/*/
static function ajustaEmp(cQuery)

    local nPos := 0
    local cExec := ""
    local nPosEnd := 0
    local nCaract := 0

    //atualiza as funes na query
    while (nPos := At("${", cQuery)) > 0

        nPosEnd := At("}", cQuery)

        nCaract := nPosEnd - nPos - 2

        cExec := SubStr(cQuery, nPos+2, nCaract)

        cQuery := StrTran(cQuery, "${" + cExec + "}",  &(cExec))

    endDo

return cQuery

/*/{Protheus.doc} AjustaCampo
Ajusta valor de campo de string
@type function
@version 12.1.0.25
@author fabricio.reche
@since 03/06/2020
@param uValor, variadic, Valor a ser ajustado (caso seja string)
@return variadic, Valor ajustado
/*/
static function AjustaCampo(uValor)

    if ValType(uValor) == "C"

        uValor := AllTrim(uValor)
        uValor := EncodeUTF8(uValor)

    endIf

return uValor

/*/{Protheus.doc} sqlMultEmp
Retorna uma consulta para mais de uma empresa (grupo)
@type function
@version 12.1.0.25
@author fabricio.reche
@since 12/06/2020
@param cQuery, character, Query original
@param aTabelas, array, Tabelas a serem ajustadas
@param aSM0, array, Lista de empresas (grupos)
@return character, Nova query ajustada
/*/
static function sqlMultEmp(cQuery, aTabelas, aSM0)

    local nX := 0
    local nJ := 0
    local cTabela := ""
    local cNewQry := ""

    cNewQry += "select * from ("

    for nX := 1 to Len(aSM0)
    
        cNewQry += IIF(nX > 1, " union all ", "")
        cNewQry += cQuery

        for nJ := 1 to Len(aTabelas)

            cTabela := aTabelas[nJ] + aSM0[nX] + "0"

            if ! cTabela $ cNewQry
                cNewQry := StrTran(cNewQry, "XXX" + aTabelas[nJ], cTabela)
            endIf

        next nJ

    next nX

    cNewQry += ")"

return cNewQry

/*/{Protheus.doc} verCposMemos
Ajusta os campos memos virtuais
@type function
@version 12.1.0.25
@author fabricio.reche
@since 20/08/2020
@param cCampos, character, Campos a serem analisados
@param cTabela, character, Tabela de consulta (010, 020)
/*/
static function verCposMemos(cCampos)

    local nX := 0
    local lAchou := .F.
    local cCpoMem := ""
    local cCpoAtu := ""
    local cConSYP := ""
    local aCampos := Separa(cCampos, ",", .F.)

    for nX := 1 to Len(aCampos)

        cCpoAtu := AllTrim(aCampos[nX])

        //se for um campo memo virtual, faz a troca para a consulta equivalente
        if GetSx3Cache(cCpoAtu, "X3_TIPO") == "M" .And. GetSx3Cache(cCpoAtu, "X3_CONTEXT") == "V"

            cCpoMem := GetSx3Cache(cCpoAtu, "X3_RELACAO")
            cCpoMem := pegaCpoMsmm(cCpoMem)

            if ! Empty(cCpoMem)

                cConSYP := "("
                cConSYP += " select LISTAGG(Trim(YP_TEXTO),' ')"
                cConSYP += " within group (order by YP_SEQ)"
                cConSYP += " from XXXSYP"
                cConSYP += " where D_E_L_E_T_=' '"
                cConSYP += " and YP_CAMPO=" + ValToSql(cCpoMem)
                cConSYP += " and YP_CHAVE=" + cCpoMem
                cConSYP += ") " + cCpoAtu

                cCampos := StrTran(cCampos, cCpoAtu, cConSYP)

                lAchou := .T.

            endIf

        endIf

    next nX

return lAchou


static function pegaCpoMsmm(cCpoMem)

    local nAt := 0

    cCpoMem := AllTrim(Upper(cCpoMem))

    //MSMM(XXX->XX_CAMPO, TAMANHO)
    nAt := At("MSMM(", cCpoMem)

    if nAt <= 0
        return ""
    endIf

    cCpoMem := AllTrim(SubStr(cCpoMem, nAt+5))

    //XXX->XX_CAMPO, TAMANHO)
    nAt := At("->", cCpoMem)

    if nAt <= 0
        return ""
    endIf

    cCpoMem := AllTrim(SubStr(cCpoMem, nAt+2))

    //XX_CAMPO, TAMANHO)
    nAt := At(",", cCpoMem)

    cCpoMem := AllTrim(SubStr(cCpoMem, 1, nAt-1))

return cCpoMem
