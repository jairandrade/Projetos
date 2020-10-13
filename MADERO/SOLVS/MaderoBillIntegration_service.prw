#include "totvs.ch"
#include "restful.ch"

#define TYPE_TEMPORARY 'PR '
#define TYPE_REAL 'TX '


wsRestful MaderoBillIntegration DESCRIPTION "Serviço REST para manipulação do Contas a Pagar para integração com o TAF, gerando financeiro após a apuração dos impostos" FORMAT APPLICATION_JSON

	//header params
	wsDATA branch as String

	WSDATA type      AS String OPTIONAL
	WSDATA issueDate AS Date   OPTIONAL
	WSDATA dueDate   AS Date   OPTIONAL
	WSDATA value     AS Float  OPTIONAL
	WSDATA start     AS Date   OPTIONAL


	WSMETHOD POST   TEMPORARY  DESCRIPTION "Incluí titulos Provisórios" ;
		WSSYNTAX "/v1/MaderoBillIntegration/Temporary/" ;
		PATH     "/v1/MaderoBillIntegration/Temporary/"

	WSMETHOD POST   REAL       DESCRIPTION "Incluí titulos Reias" ;
		WSSYNTAX "/v1/MaderoBillIntegration/Real/" ;
		PATH     "/v1/MaderoBillIntegration/Real/"

	WSMETHOD PUT    REPLACE    DESCRIPTION "Substitui titulos provisórios por Reais" ;
		WSSYNTAX "/v1/MaderoBillIntegration/Replace/" ;
		PATH     "/v1/MaderoBillIntegration/Replace/"

	WSMETHOD DELETE TEMPORARY  DESCRIPTION "Excluir os titulos Provisisórios" ;
		WSSYNTAX "/v1/MaderoBillIntegration/Temporary/" ;
		PATH     "/v1/MaderoBillIntegration/Temporary/"

	WSMETHOD DELETE REAL       DESCRIPTION "Excluir os titulos Reais" ;
		WSSYNTAX "/v1/MaderoBillIntegration/Real/" ;
		PATH     "/v1/MaderoBillIntegration/Real/"

ENDWSRESTFUL


WSMETHOD POST TEMPORARY HEADERPARAM branch PATHPARAM type, issueDate, duaDate, value WSSERVICE MaderoBillIntegration

	Local message := ''

	IF ! validadeBranch(::branch)
		return .F.
	EndIF

	IF ! callInsert(TYPE_TEMPORARY, ::type, ::issueDate, ::dueDate, ::value, @message)
		return .F.
	EndIF

	::setResponse('{"message": "' + EncodeUTF8(message) + '"}')

return .T.


WSMETHOD POST REAL HEADERPARAM branch PATHPARAM type, issueDate, duaDate, value WSSERVICE MaderoBillIntegration

	Local message := ''

	IF ! validadeBranch(::branch)
		return .F.
	EndIF


	IF ! callInsert(TYPE_REAL, ::type, ::issueDate, ::dueDate, ::value, @message)
		return .F.
	EndIF

	::setResponse('{"message": "' + EncodeUTF8(message) + '"}')

return .T.


WSMETHOD PUT REPLACE HEADERPARAM branch PATHPARAM type, issueDate, duaDate, value, start WSSERVICE MaderoBillIntegration

	Local message := ''

	IF ! validadeBranch(::branch)
		return .F.
	EndIF


	IF ! callReplace(::type, ::issueDate, ::dueDate, ::value, ::start, @message)
		return .F.
	EndIF

	::setResponse('{"message": "' + EncodeUTF8(message) + '"}')

return .T.


WSMETHOD DELETE TEMPORARY HEADERPARAM branch PATHPARAM type, issueDate WSSERVICE MaderoBillIntegration

	Local message := ''

	IF ! validadeBranch(::branch)
		return .F.
	EndIF


	IF ! callDelete(TYPE_TEMPORARY, ::type, ::issueDate, @message)
		return .F.
	EndIF

	::setResponse('{"message": "' + EncodeUTF8(message) + '"}')

return .T.


WSMETHOD DELETE REAL HEADERPARAM branch PATHPARAM type, issueDate WSSERVICE MaderoBillIntegration
	Local message := ''

	IF ! validadeBranch(::branch)
		return .F.
	EndIF


	IF ! callDelete(TYPE_REAL, ::type, ::issueDate, @message)
		return .F.
	EndIF

	::setResponse('{"message": "' + EncodeUTF8(message) + '"}')

return .T.


static function callInsert(cBillType, cTaxType, dIssueDate, dDueDate, nValue, message)

	Local lRet := .T.

	Local cNature := getNature(cTaxType)
	Local cPrefix  := SuperGetMV("ES_PRFTAF",,"TST")
	Local cVendor  := PadR(SuperGetMV("MV_UNIAO",, ""), len(SE2->E2_FORNECE)," ")
	Local cBranch  := StrZero(0, len(SA2->A2_LOJA))

	Local aTits
	Local json

	IF len( aTits := getBills( cPrefix, cBillType, cNature, cVendor, cBranch, dIssueDate, dIssueDate ) ) > 0
		SE2->( dbGoTo( aTits[ 1 ] ) )

		SetRestFault(400,I18N("Ja existe titulo na empresa com prefixo #1, numero #2, parcela #3 e tipo #4", {SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO }),,400, autoLogToString())
		return .F.
	EndIF

	IF processInsert(cPrefix, cBillType, cNature, cVendor, cBranch, dIssueDate, nValue, dDueDate )
		message := i18n("Titulo incluido com sucesso com prefixo #1, numero #2, parcela #3 e tipo #4", {SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO })
		return .T.
	EndIF

return  .F.


static function callReplace(cTaxType, dIssueDate, dDueDate, nValue, dStart, message)

	Local lRet := .T.

	Local cNature := getNature(cTaxType)
	Local cPrefix  := SuperGetMV("ES_PRFTAF",,"TST")
	Local cVendor  := PadR(SuperGetMV("MV_UNIAO",, ""), len(SE2->E2_FORNECE)," ")
	Local cBranch  := StrZero(0, len(SA2->A2_LOJA))

	Local aTits
	Local cNum				:= Nil
	Local nTit				:= 0

	IF len( aTits := getBills( cPrefix, TYPE_REAL, cNature, cVendor, cBranch, dIssueDate, dIssueDate ) ) > 0
		SE2->( dbGoTo( aTits[ 1 ] ) )

		SetRestFault(400,I18N("Ja existe titulo na empresa com prefixo #1, numero #2, parcela #3 e tipo #4", {SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO }),,400, autoLogToString())
		return .F.
	EndIF

	Begin Transaction

		IF len( aTits := getBills( cPrefix, TYPE_TEMPORARY, cNature, cVendor, cBranch, dStart, dIssueDate ) ) > 0
			For nTit := 1 to len(aTits)
				SE2->( dbGoTo( aTits[ nTit ] ) )
				IF ! ( lRet := processDelete() )
					Exit
				EndIF
			Next nTit
		EndIF

		IF lRet .and. (lRet := processInsert(cPrefix, TYPE_REAL, cNature, cVendor, cBranch, dIssueDate, nValue, dDueDate ))
			message := i18n("Titulo substituido com sucesso pelo prefixo #1, numero #2, parcela #3 e tipo #4", {SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO })
		EndIF

		IF ! lRet
			DisarmTransaction()
		EndIF

	End Transaction

return lRet


static function processInsert(cPrefix, cType, cNature, cVendor, cBranch, dIssueDate, nValue, dDueDate )

	Local aCampos := {}
	Local cNumber := getNextNumber( cPrefix, cType, cVendor, cBranch )

	aAdd(aCampos, {"E2_NUM"		, cNumber			, Nil})
	aAdd(aCampos, {"E2_PREFIXO"	, cPrefix			, Nil})
	aAdd(aCampos, {"E2_PARCELA"	, CriaVar("E2_PARCELA"), Nil})
	aAdd(aCampos, {"E2_TIPO"	, cType				, Nil})
	aAdd(aCampos, {"E2_NATUREZ"	, cNature			, Nil})
	aAdd(aCampos, {"E2_FORNECE"	, cVendor			, Nil})
	aAdd(aCampos, {"E2_LOJA"	, cBranch			, Nil})
	aAdd(aCampos, {"E2_EMISSAO"	, dIssueDate		, Nil})
	aAdd(aCampos, {"E2_VENCTO"	, dDueDate			, Nil})
	aAdd(aCampos, {"E2_VALOR"	, nValue			, Nil})

	Private lMsErroAuto	   := .F.
	Private lAutoErrNoFile := .T.

	MSExecAuto({|x,y,z| FINA050(x,y,z)}, aCampos,, 3)

	IF lMsErroAuto
		SetRestFault(400,"Erro ao incluir o titulo a pagar",,400, autoLogToString())
	EndIF

return ! lMsErroAuto


static function callDelete(cBillType, cTaxType, dIssueDate, message)

	Local lRet     := .T.
	Local aTits

	Local cPrefix := SuperGetMV("ES_PRFTAF",,"TST")
	Local cVendor := PadR(SuperGetMV("MV_UNIAO",, ""), len(SE2->E2_FORNECE)," ")
	Local cBranch := StrZero(0, len(SA2->A2_LOJA))

	IF len( aTits := getBills( cPrefix, cBillType, getNature(cTaxType), cVendor, cBranch, dIssueDate, dIssueDate ) ) > 0

		SE2->( dbGoTo( aTits[ 1 ] ) )

		IF (lRet := processDelete())
			message := "Titulos excluido com sucesso"
		EndIF

	Else
		message := "Não foi encontrado titulos para o tipo e emissão informados"
	EndIF

return lRet


static function processDelete(message)

	Local aCampos := {}

	aAdd(aCampos, {"E2_PREFIXO"	, SE2->E2_PREFIXO	, Nil})
	aAdd(aCampos, {"E2_NUM"		, SE2->E2_NUM		, Nil})
	aAdd(aCampos, {"E2_PARCELA"	, SE2->E2_PARCELA	, Nil})
	aAdd(aCampos, {"E2_TIPO"	, SE2->E2_TIPO		, Nil})
	aAdd(aCampos, {"E2_FORNECE"	, SE2->E2_FORNECE	, Nil})
	aAdd(aCampos, {"E2_LOJA"	, SE2->E2_LOJA		, Nil})

	Private lMsErroAuto	   := .F.
	Private lAutoErrNoFile := .T.

	MSExecAuto({|x,y,z| FINA050(x,y,z)}, aCampos,, 5)

	IF lMsErroAuto
		SetRestFault(400,I18N("Erro ao excluir o titulo a pagar: prefixo #1, numero #2, parcela #3 e tipo #4", {SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO }),,400, autoLogToString())
	EndIF

return ! lMsErroAuto


static function getBills( cPrefix, cType, cNature, cVendor, cBranch, fromIssuDate, toIssueDate, hasBalance )

	Local aRet 		:= { }
	Local cQuery 	:= ""
	Local cAlias

	Default hasBalance	:= .F.

	cQuery += "  SELECT "
	cQuery += "    SE2.R_E_C_N_O_ SE2REC "
	cQuery += "   FROM " + RetSQLName( "SE2" ) + " SE2 "
	cQuery += "  WHERE SE2.E2_FILIAL  = '" + xFilial( "SE2" ) + "' "
	cQuery += "    AND SE2.E2_PREFIXO = '" + cPrefix + "' "
	cQuery += "    AND SE2.E2_TIPO    = '" + cType + "' "
	cQuery += "    AND SE2.E2_EMISSAO BETWEEN '" + DToS( fromIssuDate ) + "' AND '" + DToS( toIssueDate ) + "' "
	cQuery += "    AND SE2.E2_FORNECE = '" + cVendor + "' "
	cQuery += "    AND SE2.E2_LOJA    = '" + cBranch + "' "
	cQuery += "    AND SE2.E2_NATUREZ = '" + cNature + "' "
	If hasBalance
		cQuery += "    AND SE2.E2_SALDO > 0 "
	EndIf
	cQuery += "    AND SE2.D_E_L_E_T_ = ' ' "

	cAlias := MPSysOpenQuery(cQuery)

	While ! (cAlias)->( Eof() )

		AAdd( aRet, (cAlias)->SE2REC )

		(cAlias)->(dbSkip())
	EndDO

	(cAlias)->( dbCloseArea( ) )

return aRet


static function getNextNumber( prefix, type, vendor, branch )

	Local nextNumber
	Local cAlias	 := GetNextAlias( )

	BeginSQL Alias cAlias
		%noparser%

		SELECT
			MAX( SE2.E2_NUM ) SE2NUM

		FROM %table:SE2% SE2

		WHERE
			SE2.E2_FILIAL  = %xFilial:SE2%
		AND SE2.E2_PREFIXO = %Exp: prefix %
		AND SE2.E2_TIPO    = %Exp: type %
		AND SE2.E2_FORNECE = %Exp: vendor %
		AND SE2.E2_LOJA    = %Exp: branch %
		AND SE2.D_E_L_E_T_ = ' '

	EndSQL

	IF ! empty((cAlias)->SE2NUM)
		nextNumber := Soma1((cAlias)->SE2NUM)
	Else
		nextNumber := StrZero( 1, tamSx3('E2_NUM')[1] )
	EndIF

	(cAlias)->( dbCloseArea( ) )

return nextNumber


static function getNature(cType)

	IF cType == "1"
		return SuperGetMV("MV_IRPJ",,"")
	EndIF

return SuperGetMV("MV_CSLL2",,"")


static function autoLogToString()
	Local aError := GetAutoGRLog()
	Local cError := ''
	aEval(aError, {|line| cError += line + CRLF, conOut(line) })
	conout(cError)
return cError


static function validadeBranch(branch)

	do case
		case empty(branch)
			SetRestFault(403,"The branch was not informed in the header.",,403)
			return .F.
		case len(branch) != FWSizeFilial()
			SetRestFault(403,"The branch must be "+cValToChar(FWSizeFilial())+" characters.",,403)
			return .F.
		case ! FWFilExist(cEmpAnt, branch)
			SetRestFault(403,"The branch "+alltrim(branch)+" does not exist in company "+cEmpAnt+".",,403)
			return .F.
	endcase

	//muda a filial
	cFilAnt := branch

return .T.
