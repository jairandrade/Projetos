#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

User function WFCOM002()

U_WFCOM2A()

U_WFCOM2B()

return

User function WFCOM2A()

PREPARE ENVIRONMENT EMPRESA '02' FILIAL '01' TABLES "SE2" MODULO "SIGACOM"
		
	WFCOM()

RESET ENVIRONMENT
return

User function WFCOM2B()

PREPARE ENVIRONMENT EMPRESA '03' FILIAL '01' TABLES "SE2" MODULO "SIGACOM"
		
	WFCOM()

RESET ENVIRONMENT
return


static function WFCOM()
	Local cAlias  		:= GetNextAlias()
	Local nDiasDgt 		:= GETMV('TCP_WFC002')
	Local _cEmaPar		:= Lower(AllTrim(GetMv("TCP_MALWC2")))
	Local _cHtmlNf        := ''
	Local _cHtmlPa        := ''
	Local _cHtml          := ''
	Local _cHtmlTmp          := ''
	Local cTpIgnor  	:= '%'+FormatIn('PA;'+GetNewPar("TCP_TPIGNO",'') ,";") + '%'
	Local _dData   		:= DaySuM( date() , nDiasDgt )
	local cLFRC    		:= Chr(13) + Chr(10) 
	Local _cUltForn     := ''
	Local nTotNf := 0
	Local nTotPa := 0
	
	BeginSQL Alias cAlias   
		SELECT * FROM(
			SELECT * FROM %Table:SE2% SE2 WHERE E2_VENCREA BETWEEN %EXP:DTOS(DATE())% AND %EXP:DTOS(_dData)% AND E2_SALDO >0 
			AND SE2.E2_TIPO NOT IN %EXP:cTpIgnor%  AND SE2.%NotDel%
			AND EXISTS (SELECT 1 FROM %Table:SE2% E2PA WHERE E2PA.E2_TIPO ='PA' AND E2PA.E2_SALDO > 0 
			AND E2PA.E2_FORNECE = SE2.E2_FORNECE AND E2PA.%NotDel%)
			
			UNION
			SELECT * FROM %Table:SE2% SE2PA WHERE E2_TIPO='PA' AND E2_SALDO > 0  AND SE2PA.%NotDel% 
			AND EXISTS (SELECT * FROM %Table:SE2% SE22 WHERE E2_VENCREA BETWEEN  %EXP:DTOS(DATE())% AND %EXP:DTOS(_dData)%
			AND E2_SALDO >0 AND SE2PA.E2_FORNECE = SE22.E2_FORNECE AND SE22.E2_TIPO NOT IN %EXP:cTpIgnor%  AND SE22.%NotDel% )
			) AS TAB
		ORDER BY TAB.E2_FORNECE
	EndSQL         
	
	(cAlias)->(DbGoTop())
	IF (cAlias)->(!Eof())       
		While (cAlias)->(!Eof())
		
			IF( !empty(_cUltForn) .AND. _cUltForn != (cAlias)->E2_FORNECE+(cAlias)->E2_LOJA )
			
				_cHtml += montaTab(_cUltForn,_cHtmlNf,_cHtmlPa,nTotNf,nTotPa)
				_cHtmlNf := ''
				_cHtmlPa := ''
				nTotNf := 0
				nTotPa := 0
			ENDIF
			
			_cHtmlTmp += "<tr>"
			_cHtmlTmp += "<td>"
			_cHtmlTmp += (cAlias)->E2_NUM
			_cHtmlTmp += "</td>"
			_cHtmlTmp += "<td>"
			_cHtmlTmp += (cAlias)->E2_TIPO
			_cHtmlTmp += "</td>"
			_cHtmlTmp += "<td class='class_data'>"
			_cHtmlTmp += DTOC(STOD((cAlias)->E2_EMISSAO))
			_cHtmlTmp += "</td>"
			_cHtmlTmp += "<td class='class_data'>"
			_cHtmlTmp += DTOC(STOD((cAlias)->E2_VENCREA))
			_cHtmlTmp += "</td>"
			_cHtmlTmp += "<td class='class_valor'>"
			_cHtmlTmp += 'R$ '+PadL(Alltrim(TRANSFORM((cAlias)->E2_VALOR,"@E 9,999,999,999,999.99")),15) 
			_cHtmlTmp += "</td>"
			
			_cHtmlTmp += "</tr>"
			
			IF ALLTRIM((cAlias)->E2_TIPO) == 'PA'
				_cHtmlPa += _cHtmlTmp
				nTotPa += (cAlias)->E2_VALOR
			ELSE
				_cHtmlNf += _cHtmlTmp
				
				nTotNf += (cAlias)->E2_VALOR
			ENDIF
			
			_cHtmlTmp := ''
			
			_cUltForn := (cAlias)->E2_FORNECE+(cAlias)->E2_LOJA
			
			(cAlias)->(dbSkip())
		enddo
		
		_cHtml += montaTab(_cUltForn,_cHtmlNf,_cHtmlPa,nTotNf,nTotPa)
		
		oProc := TWFProcess():New("MAILFIN02","Títulos a Vencer com PA em aberto")
	                                                             
		oProc:NewTask("Títulos a Vencer com PA em aberto", "\WORKFLOW\HTML\MAILFIN02.HTML" )
		oProc:cSubject := "Títulos a Vencer com PA em aberto"	
	
		oHtml := oProc:oHtml
	
		IF valtype(oHtml) != "U"
			
			oHtml:ValByName("cItens",_cHtml) 
			oHtml:ValByName("cNomEmp",FWFilialName()) 
			
			oProc:cTo := _cEmaPar
			oProc:Start()
			oProc:Finish()
	
			WFSendMail()
		endif	
	ENDIF
	
	(cAlias)->(dbclosearea()) 
	
RETURN

static function buscaUsu(cUsrLgi)
	Local _cCodUsu := embaralha(cUsrLgi,1)
	
return FwGetUserName(_cCodUsu)

Static function  montaTab(_cUltForn,_cHtmlNf,_cHtmlPa,nTotNf,nTotPa)
	Local cHtml := ''
	local cLFRC    		:= Chr(13) + Chr(10) 
	dbSelectArea('SA2')
	SA2->(DbSetOrder(1))
	if (SA2->(DBSeek(xFilial('SA2')+_cUltForn)))
		cHtml += '<table width="100%">'
		cHtml += '<tr>'
		cHtml += "<th colspan='5'>"
		cHtml += SA2->A2_COD+'/'+SA2->A2_LOJA + ' - ' + SA2->A2_NREDUZ+ ' - ' + Transform( SA2->A2_CGC, "@R 99.999.999/9999-99" )
		 
		cHtml += '</th>'
		cHtml += '</tr>'
		
		cHtml += '<tr>'
		cHtml += "<th colspan='5'>"
		cHtml += 'Notas a vencer'
		cHtml += '</th>'
		cHtml += '</tr>'
		
		cHtml += '<tr>'
		cHtml += "<th >"
		cHtml += "Título"
		cHtml += '</th>'
		cHtml += "<th >"
		cHtml += "Tipo"
		cHtml += '</th>'
		cHtml += "<th >"
		cHtml += "Emissão"
		cHtml += '</th>'
		cHtml += "<th >"
		cHtml += "Vencimento"
		cHtml += '</th>'
		cHtml += "<th >"
		cHtml += "Valor"
		cHtml += '</th>'
		cHtml += '</tr>'
		
		cHtml += _cHtmlNf
		//---------------totalizador
		cHtml += "<tr>"
		cHtml += "<th colspan='4'>"
		cHtml += "Valor Total"
		cHtml += "</th>"
		cHtml += "<th class='class_valor'>"
		cHtml += 'R$ '+PadL(Alltrim(TRANSFORM(nTotNf,"@E 9,999,999,999,999.99")),15) 
		cHtml += "</th>"
		cHtml += "</tr>"
		//---------------------------------------pa
		cHtml += '<tr>'
		cHtml += "<th colspan='5'>"
		cHtml += "PA's abertas"
		cHtml += '</th>'
		cHtml += '</tr>'
		cHtml += '<tr>'
		cHtml += "<th >"
		cHtml += "Título"
		cHtml += '</th>'
		cHtml += "<th >"
		cHtml += "Tipo"
		cHtml += '</th>'
		cHtml += "<th >"
		cHtml += "Emissão"
		cHtml += '</th>'
		cHtml += "<th >"
		cHtml += "Vencimento"
		cHtml += '</th>'
		cHtml += "<th >"
		cHtml += "Valor"
		cHtml += '</th>'
		cHtml += '</tr>'
		cHtml += _cHtmlPa
		cHtml += "<tr>"
		cHtml += "<th colspan='4'>"
		cHtml += "Valor Total"
		cHtml += "</th>"
		cHtml += "<th class='class_valor'>"
		cHtml += 'R$ '+PadL(Alltrim(TRANSFORM(nTotPa,"@E 9,999,999,999,999.99")),15) 
		cHtml += "</th>"
		cHtml += "</tr>"
		cHtml += '</table>'+cLFRC+cLFRC
	ENDIF
return cHtml