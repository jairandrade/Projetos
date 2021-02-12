#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"

/*/
    {Protheus.doc} User Function WSINTMS
    @type  Function
    @author Marcos Felipe Xavier
    @since 17/10/2020
    @version 1.000
    @description Funcao responsavel por realizar integracao com o Mobile Sales
    @see https://documenter.getpostman.com/view/11053018/Szzhedx7
/*/


User Function WSINTMS( cReferenceCode, cStatus, cStatusMotive )

    Local aRequestHeaders   as array

    Local cResponseBody     as char
    Local cUrlMobileSales   as char
    Local cUrlParams        as char

    Local lRequestResult    as logical

    Local oWSRequest        as object
    // Local oResponseBody     as object
    Local oRequestBody      as object

    Default cStatusMotive := ''

    if select("SX6") == 0
        RPCSetType(3)
        RpcSetEnv('04','01')
    endif


    cUrlMobileSales := GetNewPar('KA_URLMOBS','http://api.develop.kapazi.mobilesales.com.br/')
    cSecurityKey    := 'msId=' + GetNewPar('KA_KEYMOBS','T0TV5.PR07HEU5FLU1G.K4P421')
    cUrlParams      := '/orders?' + cSecurityKey

    // Instancia o objeto de requisicao REST
    oWSRequest := FWRest():New(cUrlMobileSales)

    // Define o Endpoint da requisicao
	oWSRequest:setPath(cUrlParams)

    // Monta o array contendo todos os Request Headers
    aRequestHeaders := {}
    Aadd(aRequestHeaders, "Content-Type: application/json")

    // Atribui o Body montado para dentro do objeto de requisicao
    oRequestBody := JsonObject():New()
    // oRequestBody["order"] := {}
    // aadd(oRequestBody["order"],JsonObject():New())
    oRequestBody["order"] := JsonObject():New()
    oRequestBody["order"]["referenceCode"] := cReferenceCode
    oRequestBody["order"]["status"] := cStatus
    oRequestBody["order"]["statusMotive"] := alltrim(cStatusMotive)


//     ?"order"?:{
// ?"referenceCode"?:?"98CA436045EB"?,
// ?"status"?:?"PRODUCTION"?,
// ?"statusMotive"?:?"descrição opcional, utilizada no caso de cancelamento"
// }
    oWSRequest:setPostParams(oRequestBody:ToJSON())

    // Realiza a requisicao utilizando o verbo POST e captura a resposta de sucesso ou falha 
    lRequestResult := oWSRequest:Post(aRequestHeaders)

    // Pega o corpo do retorno da requisicao
    if lRequestResult
        cResponseBody := oWSRequest:GetResult()
    else
        cResponseBody := oWSRequest:GetLastError()
    endif

Return
