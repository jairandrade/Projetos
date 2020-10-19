#include "totvs.ch"

/*/{Protheus.doc} TCWFCTRET
Funcao especifica para tratar o retorno do workflow
@type  user Function
@author Kaique Mathias
@since 31/03/2020
@param __aCookies, array, Cookies
@param __aPostParms, array, Parametros post
@param __nProcID, numérico, Proc Id
@param __aProcParms, array, Parametros do processo
@param __cHTTPPage, character, Http Page
@return cReturn Retorno com as tags html
/*/

user function TCWFCTRET( __aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage )
    Local lRejeita      := .F.
    local nPos          := 0
    local aParams       := {}
    local cReturn       := ""
    local cMsg   		:= ""
    Local cMessage 		:= ""
    Local cMessageType	:= ""
    Local lSuccess      := .F.
    Local cEmpresa		:= ""
    Local _cFilial		:= ""
    Local nX            := 1
    Local aProcParms    := {}
    Local lWfReturn     := .F.
    
    Private aPostParams := aClone(__aPostParms)

    If ( ValType( __aProcParms ) == "A" )
        
        if ( Len( __aProcParms ) > 0 )

            //descriptograda hash
            cHash := DECODE64(__aProcParms[1][1])
            cHash := Alltrim(StrTran(cHash,"?",""))
            aProcPAux := STRTOKARR( cHash, "&" )

            If Len(aProcPAux) > 0
                For nX := 1 to len(aProcPAux)
                    aAdd(aProcParms,{;
                                    SubStr(aProcPAux[nX],1,At("=",aProcPAux[nX])-1),;
                                    SubStr(aProcPAux[nX],At("=",aProcPAux[nX])+1);
                                    })
                Next nX
            EndIf

            //Recupera a empresa para realização do retorno do processo.
            if ( nPos := AsCan( aProcParms,{ |x| Upper( x[1] ) == "EMPRESA" } ) ) > 0
                cEmpresa := aProcParms[ nPos,2 ]
                AAdd( aParams, cEmpresa )
            end

            //Recupera a filial para realização do retorno do processo.
            if ( nPos := AsCan( aProcParms,{ |x| Upper( x[1] ) == "FILIAL" } ) ) > 0
                _cFilial := aProcParms[ nPos,2 ]
                AAdd( aParams, _cFilial )
            end

            //Recupera o ID do processo para realização do retorno.
            If ( Len( aParams ) == 2 )

                RPCSetType( 3 )
                RpcSetEnv( aParams[1], aParams[2],,, "CTB",,,,,,)

                AAdd( aParams, aProcParms )
                
                xRet := TCPWFReturn( aProcParms )

                If ValType( xRet ) == "A"
                    cMsg     := xRet[1]
                    cTitle   := xRet[2]
                    lWfReturn:= xRet[3]
                    lRejeita := xRet[4]
                Else
                    cMsg     := xRet
                EndIf    

                If ( Empty( cMsg ) )
                    cMessage		+= "Resposta enviada para o servidor"
                    cMessageType 	:= "Mensagem"
                    lSuccess        := .T.
                else
                    cMessage		+= cMsg
                    cMessageType    := cTitle
                    lSuccess        := lWfReturn
                EndIf
            Else
                cMessage		+= "" //
                cMessageType    := "Erro"
                lSuccess        := .F.
            EndIf
        else
            cMessage		+= "Nao houve postdata a ser processado"
            cMessageType    := "Erro"
            lSuccess        := .F.
        EndIf
    else
        cMessage		+= "Os parâmetros para o retorno não foram recebidos."
        cMessageType    := "Erro"
        lSuccess        := .F.
    EndIf

    FwLogMsg("INFO",, "TCWFCTRET", FunName(), "", "01", "Empresa: " + cEmpresa, 0, 0, {})
    FwLogMsg("INFO",, "TCWFCTRET", FunName(), "", "01", "Filial: " + _cFilial, 0, 0, {})
    FwLogMsg("INFO",, "TCWFCTRET", FunName(), "", "01", "Empresa: " + cEmpresa, 0, 0, {})
    FwLogMsg("INFO",, "TCWFCTRET", FunName(), "", "01", "Mensagem: " + cMessage, 0, 0, {})

    //cFileName := Iif (lSuccess, "\wfreturn.htm", "\wfreterr.htm" )

    If lRejeita
        cReturn := cMsg
    Else
        cReturn := U_TCPWFHtmlTemp("TCP | Workflow", cMessage, cMessageType )
    EndIf
    
    //Fecha as conexões
    RPCClearEnv()

return ( cReturn )

/*/{Protheus.doc} TCPWFReturn
    Executa função de retorno WF
    @type  Function
    @author Willian Kaneta
    @since 26/06/2020
    @version 1.0
    @return xRet
    @example
    (examples)
    @see (links_or_references)
    /*/
Static function TCPWFReturn( __aProcParms )

    Local cFuncName := ""
    Local nI        := 0
    Local aParamVar := {}
    Local xRet  
    
    // validação dos parametros do usuário
    for nI := 1 to len( __aProcParms )

        // retira o nome da função
        if (nI == 1) .and. ( AllTrim(UPPER(__aProcParms[nI, 1])) == "FUNCNAME" )
            cFuncName := __aProcParms[nI, 2]
        else
            // adiciona o array de parametros
            AAdd( aParamVar, { __aProcParms[nI, 1] ,; // nome do parametro
            __aProcParms[nI, 2]  ; // conteudo
            }                     ;
                )

        endIf

    Next nI

    // valida o nome da função
    if Empty(cFuncName)
        xRet := 'Não foi especificada a função a executar"
        return( xRet )
    endIf

    // executa a função
    xRet := U_TCCT01RET(aParamVar)

Return( xRet )
