#Include "RwMake.ch"
#Include "Protheus.ch"
#Include 'TbiConn.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RTAFM01  บAutor  ณ Vinํcius Moreira   บ Data ณ 14/06/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera็ใo de titulos de provisใo de impostos IRPJ e CSLL.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function RTAFM01( nTipo, nOpcX, nValor, dEmissao, dVencto, cTipo, aProvisorios, lShowMsg )

Local lRet 				:= .T.
Local cPrefix			:= SuperGetMV( "ES_PRFTAF"	,, "TST" )
Local cNaturez			:= ""
Local cCodFor			:= PadR( SuperGetMV( "MV_UNIAO"		,, "" )		, Len( SE2->E2_FORNECE ), " " )
Local cLojFor 			:= StrZero( 0, Len( SA2->A2_LOJA ) )
Local lExistSE2			:= .F.
Local aTits				:= { }
Local cNum				:= Nil
Local nTit				:= 0

Default cTipo			:= PadR( SuperGetMV( "ES_TIPTAF"	,, "PR" )	, Len( SE2->E2_TIPO ), " " )
Default lShowMsg		:= .T.
Default aProvisorios	:= { }

If nTipo == 1
	cNaturez := SuperGetMV( "MV_IRPJ"		,, "" )
Else
	cNaturez := SuperGetMV( "MV_CSLL2"		,, "" )
EndIf

If nOpcX == 3
	If Len( aTits := RTAFM01A( cPrefix, cTipo, cNaturez, cCodFor, cLojFor, dEmissao, dEmissao ) ) > 0
		SE2->( dbGoTo( aTits[ 1 ] ) )
		lExistSE2 := .T.
		lRet := MsgBox( "Jแ existe tํtulo " + cTipo + " para a empresa, tributo e perํodo selecionado, Deseja substitui-lo?", "", "YESNO" )
	EndIf

	If lRet
		Begin Transaction
		If lExistSE2
			cNum	:= SE2->E2_NUM
			lRet 	:= fExcTit( )
		EndIf
		If lRet
			If Len( aProvisorios ) > 0
				For nTit := 1 to Len( aProvisorios )
					SE2->( dbGoTo( aProvisorios[ nTit ] ) )
					lRet := fExcTit( )
					If !lRet
						Exit
					EndIf
				Next nTit
			EndIf
			If lRet
				lRet := fIncTit( cNum, cPrefix, cTipo, cNaturez, cCodFor, cLojFor, dEmissao, nValor, dVencto )
			EndIf
		EndIf
		End Transaction
	EndIf
ElseIf nOpcX == 5
	If Len( aTits := RTAFM01A( cPrefix, cTipo, cNaturez, cCodFor, cLojFor, dEmissao, dEmissao ) ) == 0
		If lShowMsg
			lRet := .F.
			Help (" ", 1, "xRTAFM0101",,"Titulo nใo encontrado.", 3, 0)
		EndIf
	Else
		SE2->( dbGoTo( aTits[ 1 ] ) )
		Begin Transaction
		lRet := fExcTit( )
		End Transaction
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RTAFM01A บAutor  ณ Vinํcius Moreira   บ Data ณ 14/06/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Checa se o titulo jแ foi gerado.                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static Function RTAFM01A( cPrefix, cTipo, cNaturez, cCodFor, cLojFor, dEmiDe, dEmiAte, lSaldo )
Local aRet 		:= { }
Local cQuery 	:= ""
Local cAliasQry	:= GetNextAlias( )
Default lSaldo	:= .F.

cQuery += "  SELECT " + CRLF
cQuery += "    SE2.R_E_C_N_O_ SE2REC " + CRLF
cQuery += "   FROM " + RetSQLName( "SE2" ) + " SE2 " + CRLF
cQuery += "  WHERE SE2.E2_FILIAL  = '" + xFilial( "SE2" ) + "' " + CRLF
cQuery += "    AND SE2.E2_PREFIXO = '" + cPrefix + "' " + CRLF
cQuery += "    AND SE2.E2_TIPO    = '" + cTipo + "' " + CRLF
cQuery += "    AND SE2.E2_EMISSAO BETWEEN '" + DToS( dEmiDe ) + "' AND '" + DToS( dEmiAte ) + "' " + CRLF
cQuery += "    AND SE2.E2_FORNECE = '" + cCodFor + "' " + CRLF
cQuery += "    AND SE2.E2_LOJA    = '" + cLojFor + "' " + CRLF
cQuery += "    AND SE2.E2_NATUREZ = '" + cNaturez + "' " + CRLF
If lSaldo
	cQuery += "    AND SE2.E2_SALDO > 0 " + CRLF
EndIf
cQuery += "    AND SE2.D_E_L_E_T_ = ' ' " + CRLF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
While ( cAliasQry )->( !Eof( ) )
	AAdd( aRet, ( cAliasQry )->SE2REC )
	( cAliasQry )->( dbSkip( ) )
EndDo
( cAliasQry )->( dbCloseArea( ) )

Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fIncTit  บAutor  ณ Vinํcius Moreira   บ Data ณ 14/06/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclusใo do titulo a pagar.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fIncTit( cNum, cPrefix, cTipo, cNaturez, cCodFor, cLojFor, dEmissao, nValor, dVencto )

Local lRet 			:= .T.
Local nOpcX			:= 3
Local aCampos		:= {}
Local cParcela		:= StrZero( 1, Len( SE2->E2_PARCELA ) )
Default cNum		:= fGetNum( cPrefix, cTipo, cCodFor, cLojFor )
Private INCLUI 		:= nOpcX == 3
Private ALTERA 		:= nOpcX == 4
Private EXCLUI 		:= nOpcX == 5
Private lMsErroAuto	:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณColoquei aqui, apenas os campos obrigatorios em minha base,   ณ
//ณentใo voce deve checar se apenas estes sใo obrigatorios em suaณ
//ณbase e adicioanr os outros campos que quiser.                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//aAdd(aCampos, {"E2_FILIAL"	, xFilial( "SE2" )	, Nil})
aAdd(aCampos, {"E2_NUM"		, cNum				, Nil})
aAdd(aCampos, {"E2_PREFIXO"	, cPrefix			, Nil})
aAdd(aCampos, {"E2_PARCELA"	, cParcela			, Nil})
aAdd(aCampos, {"E2_TIPO"	, cTipo				, Nil})
aAdd(aCampos, {"E2_NATUREZ"	, cNaturez			, Nil})
aAdd(aCampos, {"E2_FORNECE"	, cCodFor			, Nil})
aAdd(aCampos, {"E2_LOJA"	, cLojFor			, Nil})
aAdd(aCampos, {"E2_EMISSAO"	, dEmissao			, Nil})
aAdd(aCampos, {"E2_VENCTO"	, dVencto			, Nil})
aAdd(aCampos, {"E2_VALOR"	, nValor			, Nil})
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOs campos deve ser adicionados ao vetor, na mesma ordem de    ณ
//ณexibi็ใo na tela, como isso pode ser alterado a qualquer mo-  ณ
//ณmento, desenvolvi uma fun็ใo auxiliar para corrigir a ordem   ณ
//ณem tempo de execu็ใo.                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCampos := fChkCpos( aCampos )
MSExecAuto( { | x, y, z | FINA050( x, y, z ) }, aCampos, , nOpcX )
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe deu erro, volto a numeracao e exibo a mensagem.            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lMsErroAuto
	lRet := .F.
	DisarmTransaction( )
	MostraErro( )
EndIf
lMsErroAuto	:= .F.

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fGetNum  บAutor  ณ Vinํcius Moreira   บ Data ณ 15/06/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca pr๓ximo numero para gera็ใo do titulo.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGetNum( cPrefix, cTipo, cCodFor, cLojFor )

Local cRet 		:= ""
Local cQuery 	:= ""
Local cAliasQry	:= GetNextAlias( )

cQuery += "  SELECT " + CRLF
cQuery += "    MAX( SE2.E2_NUM ) SE2NUM " + CRLF
cQuery += "   FROM " + RetSQLName( "SE2" ) + " SE2 " + CRLF
cQuery += "  WHERE SE2.E2_FILIAL  = '" + xFilial( "SE2" ) + "' " + CRLF
cQuery += "    AND SE2.E2_PREFIXO = '" + cPrefix + "' " + CRLF
cQuery += "    AND SE2.E2_TIPO    = '" + cTipo + "' " + CRLF
cQuery += "    AND SE2.E2_FORNECE = '" + cCodFor + "' " + CRLF
cQuery += "    AND SE2.E2_LOJA    = '" + cLojFor + "' " + CRLF
cQuery += "    AND SE2.D_E_L_E_T_ = ' ' " + CRLF
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
If ( cAliasQry )->( !Eof( ) )
	cRet := Soma1( ( cAliasQry )->SE2NUM )
Else
	cRet := StrZero( 1, Len( SE2->E2_NUM ) )
EndIf
( cAliasQry )->( dbCloseArea( ) )

Return cRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fChkCpos บAutor  ณ Vinํcius Moreira   บ Data ณ 26/03/2015  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Checa ordem dos campos para execu็ใo do MsExecAuto.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fChkCpos(aCpos)

Local aCposAux := {}
Local aRet     := {}
Local nCpo     := 0
Local nTamCpo  := Len(SX3->X3_CAMPO)

dbSelectArea("SX3")
SX3->(dbSetOrder(2))//X3_CAMPO

For nCpo := 1 to Len(aCpos)
	If SX3->(dbSeek(PadR(aCpos[nCpo, 1], nTamCpo, " ")))
		aAdd(aCposAux, {SX3->X3_ORDEM, aCpos[nCpo]})
	Else
		aAdd(aCposAux, {"999", aCpos[nCpo]})
	EndIf
Next nCpo
ASort(aCposAux,,,{|x,y| x[1] < y[1] })
For nCpo := 1 to Len(aCposAux)
	aAdd(aRet, aCposAux[nCpo,2])
Next nCpo

Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fExcTit  บAutor  ณ Vinํcius Moreira   บ Data ณ 15/06/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exclusใo do titulo gerado para o imposto.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fExcTit( )

Local lRet 			:= .T.
Local nOpcX			:= 5
Local aCampos		:= {}
Private INCLUI 		:= nOpcX == 3
Private ALTERA 		:= nOpcX == 4
Private EXCLUI 		:= nOpcX == 5
Private lMsErroAuto	:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณColoquei aqui, apenas os campos obrigatorios em minha base,   ณ
//ณentใo voce deve checar se apenas estes sใo obrigatorios em suaณ
//ณbase e adicioanr os outros campos que quiser.                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aCampos, {"E2_PREFIXO"	, SE2->E2_PREFIXO	, Nil})
aAdd(aCampos, {"E2_NUM"		, SE2->E2_NUM		, Nil})
aAdd(aCampos, {"E2_PARCELA"	, SE2->E2_PARCELA	, Nil})
aAdd(aCampos, {"E2_TIPO"	, SE2->E2_TIPO		, Nil})
aAdd(aCampos, {"E2_FORNECE"	, SE2->E2_FORNECE	, Nil})
aAdd(aCampos, {"E2_LOJA"	, SE2->E2_LOJA		, Nil})
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณOs campos deve ser adicionados ao vetor, na mesma ordem de    ณ
//ณexibi็ใo na tela, como isso pode ser alterado a qualquer mo-  ณ
//ณmento, desenvolvi uma fun็ใo auxiliar para corrigir a ordem   ณ
//ณem tempo de execu็ใo.                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCampos := fChkCpos(aCampos)
MSExecAuto({|x,y,z| FINA050(x,y,z)},aCampos,,nOpcX)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe deu erro, volto a numeracao e exibo a mensagem.            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lMsErroAuto
	lRet := .F.
	DisarmTransaction( )
	MostraErro( )
EndIf
lMsErroAuto	:= .F.

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RTAFM01B บAutor  ณ Vinํcius Moreira   บ Data ณ 27/06/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra tela para escolha dos vencimentos.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function RTAFM01B( dDatEmi, cTipoTit, nValor, dIniPer)

Local nOpcA       	:= 0
Local oEmissao		:= Space( 10 )
Local oVencto		:= Space( 10 )
Local oDlg
Local lRet 			:= .F.
Local nTipo			:= 0
Default dDatEmi 	:= CToD( Right( cDescPerio, 10 ) )
Default nValor		:= 0
Private dEmissao	:= dDatEmi
Private dVencto		:= CToD( "//" )

If T0N->T0N_CODIGO == "000001"
	nTipo 	:= 1
	If nValor == 0
		nValor 	:= nVlrPrIRPJ
	EndIf
ElseIf T0N->T0N_CODIGO == "000002"
	nTipo	:= 2
	If nValor == 0
		nValor	:= nVlrImpost
	EndIf
EndIf

If nTipo == 0
	Help (" ", 1, "xRTAFM0102",,"Evento nใo liberado para gera็ใo de titulo.", 3, 0)
Else
	Define MsDialog oDlg From 0,0 to 115,204 Title "Titulo Provisao" Pixel Color CLR_BLACK, CLR_WHITE

	TSay():New(004,005,{|| "Emissao" },oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,80)
	oEmissao := TGet():New(003,040,{|u| If(PCount()>0,dEmissao:=u,dEmissao)}, oDlg,55,10, ,{||  },,,,,,.T.,,,,,,,.T.,,,'dEmissao')

	TSay():New(020,005,{|| "Vencimento" },oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,100,80)
	oVencto := TGet():New(019,040,{|u| If(PCount()>0,dVencto:=u,dVencto)}, oDlg,55,10, ,{|| fValData( dEmissao, dVencto ) },,,,,,.T.,,,,,,,,,,'dVencto')

	TButton():New(035, 009,"Confirmar", oDlg,{|| nOpcA := 1, oDlg:End() },0040,0015,,,,.T.)
	TButton():New(035, 054,"Cancelar" , oDlg,{|| nOpcA := 0, oDlg:End() },0040,0015,,,,.T.)

	Activate MsDialog oDlg Centered

	If nOpcA == 1 .And. nValor > 0 .And. !Empty( dVencto )
		//MsgRun("Gerando titulo...","Processando...",{|| lRet := U_RTAFM01( nTipo, 3, nValor, dEmissao, dVencto, cTipoTit, aProvisorios ) })
		IF empty(cTipoTit) .or. alltrim(cTipoTit) == "PR"
			MaderoBillIntegration_client():createTemporaty(cValToChar(nTipo), dEmissao, dVencto, nValor)
		Else
			MaderoBillIntegration_client():replace(cValToChar(nTipo), dEmissao, dVencto, nValor, dIniPer)
		EndIF
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fValData บAutor  ณ Vinํcius Moreira   บ Data ณ 28/06/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida digita็ใo da data de vencimento.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fValData( dEmissao, dVencto )

Local lRet := .T.

If dVencto < dEmissao
	lRet := .F.
	Help (" ", 1, "xRTAFM0103",,"A data de vencimento (" + DToC( dVencto ) + ") nใo pode ser inferior a data de emissใo (" + DToC( dEmissao ) + ") do titulo.", 3, 0)
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RTAFM01C บAutor  ณ Vinํcius Moreira   บ Data ณ 28/06/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera็ใo dos titulos efetivos de impostos.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function RTAFM01C( )

Local lRet		:= .T.
Local cPrefix	:= SuperGetMV( "ES_PRFTAF"	,, "TST" )
Local cTipoPr	:= PadR( SuperGetMV( "ES_TIPTAF"	,, "PR" )	, Len( SE2->E2_TIPO ), " " )
Local cTipoEfe	:= PadR( SuperGetMV( "ES_TEFTAF"	,, "TX" )	, Len( SE2->E2_TIPO ), " " )
//Local cNaturez	:= ""
Local cCodFor	:= PadR( SuperGetMV( "MV_UNIAO"		,, "" )		, Len( SE2->E2_FORNECE ), " " )
Local cLojFor 	:= StrZero( 0, Len( SA2->A2_LOJA ) )
Local aEfetivo	:= { }
Local aProvisorios	:= { }
Local nTipo		:= 0
Local nValor	:= CWV->CWV_APAGAR
Local dIniPer	:= CWV->CWV_INIPER
Local dFimPer	:= CWV->CWV_FIMPER
Local cCodTrib	:= Posicione("T0J",1,xFilial("T0J")+CWV->CWV_IDTRIB,"T0J_CODIGO")

If CWV->CWV_STATUS == "1"
	lRet := .F.
	Help (" ", 1, "xRTAFM0104",,"Nใo ้ permitida a gera็ใo de titulos para periodos em aberto.", 3, 0)
Else
	If cCodTrib == "000001"
		nTipo 		:= 1
		cNaturez 	:= SuperGetMV( "MV_IRPJ"		,, "" )
	ElseIf cCodTrib == "000002"
		nTipo		:= 2
		cNaturez 	:= SuperGetMV( "MV_CSLL2"		,, "" )
	EndIf

	If nTipo > 0
		//MsgRun("Buscando titulos provisorios...","Processando...",{|| aProvisorios  := U_RTAFM01A( cPrefix, cTipoPr, cNaturez, cCodFor, cLojFor, dIniPer, dFimPer, .T. ) })
		lRet := U_RTAFM01B( dFimPer, cTipoEfe, nValor, dIniPer )
	EndIf
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fBaixTit บAutor  ณ Vinํcius Moreira   บ Data ณ 29/06/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Baixa de titulos.                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fBaixTit( aProvisorios )

Local lRet		:= .T.
Local nTit		:= 0
Local aCampos	:= { }
Private lMsErroAuto	:= .F.

For nTit := 1 to Len( aProvisorios )
	SE2->( dbGoTo( aProvisorios[nTit] ) )


	If lMsErroAuto
		lRet := .F.
		DisarmTransaction( )
		MostraErro( )
		Exit
	EndIf
Next nTit

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfProcBaix บAutor  ณ Vinํcius Moreira   บ Data ณ 29/06/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa a baixa.                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fProcBaix( nSE2Rec, cMotBx, nTxMoeda, cBanco, cAgencia, cNumCon )

Local aTit			:= { }
Private lMsErroAuto	:= .F.

SE2->( dbGoTo( nSE2Rec ) )
aAdd(aTit, {"E2_FILIAL"			, SE2->E2_FILIAL		,Nil})
aAdd(aTit, {"E2_PREFIXO"		, SE2->E2_PREFIXO		,Nil})
aAdd(aTit, {"E2_NUM"			, SE2->E2_NUM			,Nil})
aAdd(aTit, {"E2_PARCELA"		, SE2->E2_PARCELA		,Nil})
aAdd(aTit, {"E2_TIPO"			, SE2->E2_TIPO			,Nil})
aAdd(aTit, {"E2_FORNECE"		, SE2->E2_FORNECE		,Nil})
aAdd(aTit, {"E2_LOJA"			, SE2->E2_LOJA			,Nil})
aAdd(aTit, {"AUTMOTBX"			, cMotBx				,Nil})
MSExecAuto( {|x,y| FINA080(x,y)}, aTit, 3 )
If lMsErroAuto
	MostraErro( )
EndIf

Return !lMsErroAuto