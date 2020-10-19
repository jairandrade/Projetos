#include "protheus.ch"
#INCLUDE "APWEBEX.CH"

/*/{Protheus.doc} TCPWFHTTPRET
Funcao especifica para tratar o retorno do workflow
@type  user Function
@author Kaique Mathias
@since 31/03/2020
@param __aCookies, array, Cookies
@param __aPostParms, array, Parametros post
@param __nProcID, num�rico, Proc Id
@param __aProcParms, array, Parametros do processo
@param __cHTTPPage, character, Http Page
@return cReturn Retorno com as tags html
/*/

user function TCPWFHTTPRET( __aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage )

    local nPos          := 0
    local aParams := {}
    local cReturn       := ""
    local cFileName 	:= ""
    local cProcessID 	:= ""
    local cMsg   		:= ""
    local oWF           := Nil
    Local cMessage 		:= ""
    Local cMessageType	:= ""
    Local lSuccess      := .F.
    Local cEmpresa		:= ""
    Local _cFilial		:= ""
    Local nX,nY,i       := 1
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

            //Recupera a empresa para realiza��o do retorno do processo.
            if ( nPos := AsCan( aProcParms,{ |x| Upper( x[1] ) == "EMPRESA" } ) ) > 0
                cEmpresa := aProcParms[ nPos,2 ]
                AAdd( aParams, cEmpresa )
            end

            //Recupera a filial para realiza��o do retorno do processo.
            if ( nPos := AsCan( aProcParms,{ |x| Upper( x[1] ) == "FILIAL" } ) ) > 0
                _cFilial := aProcParms[ nPos,2 ]
                AAdd( aParams, _cFilial )
            end

            //Recupera o ID do processo para realiza��o do retorno.
            If ( Len( aParams ) == 2 )

                RPCSetType( 3 )
                RpcSetEnv( aParams[1], aParams[2],,, "FIN",,,,,,)

                AAdd( aParams, aProcParms )
                
                xRet := TCPWFReturn( aProcParms )

                If ValType( xRet ) == "A"
                    cMsg     := xRet[1]
                    cTitle   := xRet[2]
                    lWfReturn:= xRet[3]
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
        cMessage		+= "Os par�metros para o retorno n�o foram recebidos."
        cMessageType    := "Erro"
        lSuccess        := .F.
    EndIf

    WFConout( "Execu��o de retorno",,,,.T.,"TCPHTTPRET" )
    WFConout( "Empresa: " + cEmpresa,,,,, "TCPHTTPRET" )
    WFConout( "Filial: " + _cFilial,,,,, "TCPHTTPRET")
    WFConout( "Mensagem: " + cMessage,,,,, "TCPHTTPRET")

    //cFileName := Iif (lSuccess, "\wfreturn.htm", "\wfreterr.htm" )

    //If ( File( cFileName ) )
    //    cReturn := WFLoadFile( cFileName )
    //else
    cReturn := U_TCPWFHtmlTemp("TCP | Workflow", cMessage, cMessageType )
    //EndIf

return ( cReturn )

Static function TCPWFReturn( __aProcParms )

    Local cFuncName := ""
    Local cExecBloc := ""
    Local nI        := 0
    Local aParamVar := {}
    Local xRet  
    
    // valida��o dos parametros do usu�rio
    for nI := 1 to len( __aProcParms )

        // retira o nome da fun��o
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

    // valida o nome da fun��o
    if Empty(cFuncName)
        xRet := 'N�o foi especificada a fun��o a executar"
        return( xRet )
    endIf

    // monta o bloco de execu��o da fun��o
    cExecBloc := cFuncName + "("

    // verifica os parametros
    for nI := 1 to len(aParamVar)
        if nI == 1
            cExecBloc += aParamVar[nI][2]
        else
            cExecBloc += (", " + aParamVar[nI][2])
        endIf
    next nI

    cExecBloc += ")"

    // executa a fun��o
    xRet := &(cExecBloc)

Return( xRet )