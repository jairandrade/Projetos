#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'RestFul.CH'
#Include 'tbiconn.ch'
#Include "TopConn.ch"

#Define STR_PULA chr(13)+Chr(10)

/*{Protheus.doc}
//TODO (PT-BR) metodo que Retorna todos os produtos do fornecedor e Loja passados na URL
@author Jorge Hernandes
@version 1.0
@Date 03/02/2019


@history 05/04/2019, Rafael Ricardo Vieceli, Retirado conexão com empresa usando RPCSetEnv, deixando no padrão, que precisa passar tenantId no header
29-04-2020 - incluido linha na query para validar tabela do grupo 01 e 02(len(_cAlias) > 3, calias SB1 OU SB1010 OU SB1020)
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

	Local cQuery    := ""
	Local cQRY      := ""
	Local aQuery    := {}
	Local aResult   := {}
	Local aCab      := aCab
	Local cCpoFil  	:= PrefixoCpo(_cAlias)+"_FILIAL"
	Local nX        := 0

	_cWhere := StrTran(_cWhere,"%20"," " )

	if len(_cAlias) > 3
		//Montando a Consulta tabela fora padrão P12
		cQuery := " SELECT "                           + STR_PULA
		cQuery += _cCampos                             + STR_PULA
		cQuery += " FROM"+" "+_cAlias                  + STR_PULA
		cQuery += " WHERE "                            + STR_PULA
		cQuery += " D_E_L_E_T_ = ' ' "                 + STR_PULA
		//if !empty(_cWhere)
		cQuery  += _cWhere                             + STR_PULA
		//endif

	ELSE


		//Montando a Consulta
		cQuery := " SELECT "                           + STR_PULA
		cQuery += _cCampos                             + STR_PULA
		cQuery += " FROM"+" "+RetSQLName(_cAlias)      + STR_PULA
		cQuery += " WHERE "                            + STR_PULA
		cQuery += " D_E_L_E_T_ = ' '"                  + STR_PULA
		cQuery  += _cWhere                             + STR_PULA

	ENDIF

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
			If ValType(ALLTRIM(cValtoChar((cQRY)->&(aCab[nX]))))=="C"
				//AADD(aQuery,FwCutOff(TiraGraf((ALLTRIM(cValtoChar((cQRY)->&(aCab[nX])))))))
					AADD(aQuery,TiraGraf(NOACENTO(EncodeUTF8(AnsiToOem(ALLTRIM(cValtoChar((cQRY)->&(aCab[nX]))))))))
			Else
				AADD(aQuery,ALLTRIM(cValtoChar((cQRY)->&(aCab[nX]))))
			EndIf
		Next
		AADD(aResult,aQuery)
		(cQRY)->(dbSkip())
	EndDo
	(cQRY)->(DbCloseArea())

Return aResult

/*{Protheus.doc}
//TODO (PT-BR) metodo que cria e formara um Json
@author Jorge Hernandes
@version 1.0
@Date 03/02/2019
*/

Static function JSON(aGeraXML)
	Local cxJSON  := ""
	Local cTable := aGeraXML[1]
	Local aCab   := aGeraXML[2]
	Local aLin   := aGeraXML[3]
	Local L, C   := 0

	cxJSON += '['

	FOR L:= 1 TO LEN( aLin )

		cxJSON += '{'

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

			cxJSON += '"'+aCab[C]+'":' + cConteudo

			IF C < LEN(aCab)
				cxJSON += ','
			ENDIF

		Next
		cxJSON += '}'
		IF L < LEN(aLin)
			cxJSON += ','
		Else
			cxJSON += ']'
		ENDIF

	Next

Return cxJSON
Static function TiraGraf (_sOrig)
	local _sRet := _sOrig
	_sRet = strtran (_sRet, "á", "a")
	_sRet = strtran (_sRet, "é", "e")
	_sRet = strtran (_sRet, "í", "i")
	_sRet = strtran (_sRet, "ó", "o")
	_sRet = strtran (_sRet, "ú", "u")
	_SRET = STRTRAN (_SRET, "Á", "A")
	_SRET = STRTRAN (_SRET, "É", "E")
	_SRET = STRTRAN (_SRET, "Í", "I")
	_SRET = STRTRAN (_SRET, "Ó", "O")
	_SRET = STRTRAN (_SRET, "Ú", "U")
	_sRet = strtran (_sRet, "ã", "a")
	_sRet = strtran (_sRet, "õ", "o")
	_SRET = STRTRAN (_SRET, "Ã", "A")
	_SRET = STRTRAN (_SRET, "Õ", "O")
	_sRet = strtran (_sRet, "â", "a")
	_sRet = strtran (_sRet, "ê", "e")
	_sRet = strtran (_sRet, "î", "i")
	_sRet = strtran (_sRet, "ô", "o")
	_sRet = strtran (_sRet, "û", "u")
	_SRET = STRTRAN (_SRET, "Â", "A")
	_SRET = STRTRAN (_SRET, "Ê", "E")
	_SRET = STRTRAN (_SRET, "Î", "I")
	_SRET = STRTRAN (_SRET, "Ô", "O")
	_SRET = STRTRAN (_SRET, "Û", "U")
	_sRet = strtran (_sRet, "ç", "c")
	_sRet = strtran (_sRet, "Ç", "C")
	_sRet = strtran (_sRet, "à", "a")
	_sRet = strtran (_sRet, "À", "A")
	_sRet = strtran (_sRet, "º", "")
	_sRet = strtran (_sRet, "ª", "")
	_sRet = strtran (_sRet, '"', "")
	_sRet = strtran (_sRet, "'", "")
	_sRet = strtran (_sRet, "", "")
	//_sRet = strtran (_sRet, "/", "")
	_sRet = strtran (_sRet, "\", "")
	_sRet = strtran (_sRet, "’", "")
	_sRet = strtran (_sRet, "”", "")
	_sRet = strtran (_sRet, "(", "")
	_sRet = strtran (_sRet, ")", "")
	_sRet = strtran (_sRet, "_", "")
	_sRet = strtran (_sRet, "%", "")
	_sRet = strtran (_sRet, "$", "")
	_sRet = strtran (_sRet, "#", "")
	_sRet = strtran (_sRet, "@", "")
	_sRet = strtran (_sRet, "?", "")
	_sRet = strtran (_sRet, "<", "")
	_sRet = strtran (_sRet, ">", "")
	_sRet = strtran (_sRet, ",", "")
	_sRet = strtran (_sRet, ";", "")
	_sRet = strtran (_sRet, "[", "")
	_sRet = strtran (_sRet, "]", "")
	_sRet = strtran (_sRet, "{", "")
	_sRet = strtran (_sRet, "}", "")
	//_sRet = strtran (_sRet, ".", "")
	_sRet = strtran (_sRet, ":", "")
	_sRet = strtran (_sRet, "=", "")
	_sRet = strtran (_sRet, "+", "")
	_sRet = strtran (_sRet, "&", "")
	_sRet = strtran (_sRet, "^", "")
	_sRet = strtran (_sRet, "~", "")
	_sRet = strtran (_sRet, "!", "")
	_sRet = strtran (_sRet, "*", "")
	_sRet = strtran (_sRet, ".,", "")
	_sRet = strtran (_sRet, "~~", "")
	_sRet = strtran (_sRet, "  ", "")
	_sRet = strtran (_sRet, "“", "")
	_sRet = strtran (_sRet, "”", "")
	_sRet = strtran (_sRet, chr (9), "") // TAB
	_sRet = strtran (_sRet, chr (10), "") // espaco
	_sRet = strtran (_sRet, chr (13), "") // espaco

return _sRet