#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'RestFul.CH'
#Include 'tbiconn.ch'
#Include "TopConn.ch"

#Define STR_PULA chr(13)+Chr(10)

/* {Protheus.doc}
//TODO (PT-BR) metodo que Retorna todos os produtos do fornecedor e Loja passados na URL
@author Jorge Hernandes
@version 1.0
@Date 03/02/2019


@history 05/04/2019, Rafael Ricardo Vieceli, Retirado conexão com empresa usando RPCSetEnv, deixando no padrão, que precisa passar tenantId no header

*/

WSRESTFUL WS_Consultas DESCRIPTION "Serviço REST para execução de query"

WSDATA _cAlias      As String //Alias da tabela
WSDATA _cCampos     As String //Campos separados por virgula
WSDATA _cWhere      As String //Campos separados por virgula



WSMETHOD GET DESCRIPTION "Retorna Produtos de um fornecedor passado na URL" WSSYNTAX "/WS009/_cAlias,_cCampos,_cWhere"

END WSRESTFUL

WSMETHOD GET WSRECEIVE _cAlias,_cCampos,_cWhere WSSERVICE WS_Consultas

    Local aReturn           := {}
    Local lConsole          := .T.

    Local _cAlias   := cValtoChar(Self:_cAlias)
    Local _cCampos  := cValtoChar(Self:_cCampos)
    Local _cWhere   := cValtoChar(Self:_cWhere)

    Local aCab      := StrTokArr2( _cCampos, ",",.F.) //Titulo dos campos

    // define o tipo de retorno do método
	Self:SetContentType("application/json")


    //Executando a query
    aReturn := Consulta_SQL(_cAlias, _cCampos,aCab,_cWhere)

    IF LEN(aReturn) > 0
        //Chama a funcao para gerar o JSON.
        cRet   := EncodeUTF8(JSON( { "Consulta" , aCab, aReturn}))

    Else
        Self:SetResponse('{"Retorno Protheus":')
		Self:SetResponse('[')
        Self:SetResponse('"Não Existe dados para essa consulta!"]')
	    Self:SetResponse('}')

        Return(.T.)
    EndIf

    Self:SetResponse(cRet)

Return(.T.)

Static Function Consulta_SQL(_cAlias, _cCampos,aCab,_cWhere)
    Local nI
    Local nX
    Local cQuery    := ""
    Local cQRY      := ""
    Local aQuery    := {}
    Local aResult   := {}
    Local aCab      := aCab
    Local cCpoFil  := PrefixoCpo(_cAlias)+"_FILIAL"

     _cWhere := StrTran(_cWhere,"%20"," " )

    //Montando a Consulta
    cQuery := " SELECT "                           + STR_PULA
    cQuery += _cCampos                             + STR_PULA
    cQuery += " FROM"+" "+RetSQLName(_cAlias)      + STR_PULA
    cQuery += " WHERE "                            + STR_PULA
    cQuery += cCpoFil+"='"+xFilial(_cAlias)+"' "   + STR_PULA
    cQuery += "AND D_E_L_E_T_ = ' '"               + STR_PULA
    cQuery  += _cWhere                             + STR_PULA


    //Executando consulta
    cQuery := ChangeQuery(cQuery)
	cQRY := MPSysOpenQuery(cQuery)


	ConOut( PadC( "WS_CONSULTAS - Query", 30 ) )
	ConOut( Replicate( "-", 30 ) )
	ConOut( cValToChar(cQuery) )
	ConOut( Replicate( "-", 30 ) )


    //Percorrendo os registros
    While ! (cQRY)->(EoF())
        aQuery := {}
        For nX:= 1 to Len(aCab)
            AADD(aQuery,ALLTRIM(cValtoChar((cQRY)->&(aCab[nX]))))
        Next
        AADD(aResult,aQuery)
        (cQRY)->(dbSkip())
    EndDo
    (cQRY)->(DbCloseArea())

Return aResult

/* {Protheus.doc}
//TODO (PT-BR) metodo que cria e formara um Json
@author Jorge Hernandes
@version 1.0
@Date 03/02/2019
*/
Static function JSON(aGeraXML)
    Local cJSON  := ""
    Local cTable := aGeraXML[1]
    Local aCab   := aGeraXML[2]
    Local aLin   := aGeraXML[3]
    Local nI
    Local L
    Local C

    cJSON += '['

    FOR L:= 1 TO LEN( aLin )

        cJSON += '{'

        for C:= 1 to Len( aCab )

            IF VALTYPE(aLin[L][C]) = "C"
                If aCab[C] == "ObjectIn"
                    cConteudo := VldObj(aLin[L][C])
                ElseIf aCab[C] == "ObjectOut"
                    cConteudo := VldObj(aLin[L][C])
                ELSE
                    cConteudo := '"'+aLin[L][C]+'" '
                EndIf
            ELSEIF VALTYPE(aLin[L][C]) = "N"
                cConteudo := ALLTRIM(STR(aLin[L][C]))
            ELSEIF VALTYPE(aLin[L][C]) = "D"
                cConteudo := '"'+DTOC(aLin[L][C])+'"'
            ELSEIF VALTYPE(aLin[L][C]) = "L"
                cConteudo := IF(aLin[L][C], 'true' , 'false')
            ELSE
                cConteudo := '"'+aLin[L][C]+'"'
            ENDIF

            cJSON += '"'+aCab[C]+'":' + cConteudo

            IF C < LEN(aCab)
            cJSON += ','
            ENDIF

        Next
        cJSON += '}'
        IF L < LEN(aLin)
        cJSON += ','
        Else
        cJSON += ']'
        ENDIF

    Next

Return cJSON