#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

User function WCOM001()

	U_WCOM001A()

	U_WCOM001B()

return

User function WCOM001A()

	PREPARE ENVIRONMENT EMPRESA '02' FILIAL '01' TABLES "SF1" MODULO "SIGACOM"

	WFCOM()

	RESET ENVIRONMENT
return

User function WCOM001B()

	PREPARE ENVIRONMENT EMPRESA '03' FILIAL '01' TABLES "SF1" MODULO "SIGACOM"

	WFCOM()

	RESET ENVIRONMENT
return

static function WFCOM()
	Local cAlias  		:= GetNextAlias()
	Local _cHtml        := ''
	local cLFRC    		:= Chr(13) + Chr(10) 
	
	Local cPortWf := GetMv("TCP_PORTWF")
	Local cEndSrv := supergetMv("MV_ENDWF",,"vmsapp_hmg")
	Local cLinkApr :=cEndSrv+':'+cPortWf+'/pp/U_weblogA.apw?keyvalue='
	Local cLinkRej :=cEndSrv+':'+cPortWf+'/pp/U_weblogR.apw?keyvalue='
	
	cEpecNf := '%'+FormatIn( cEpecNf,";") + '%'

	BeginSQL Alias cAlias    

		Column C7_EMISSAO as date  
		SELECT 
			C7_NUM        AS NUMBER_PO,
			C7_CONTRA     AS NUMBER_CONTRACT, 
			C7_EMISSAO    AS DTEMISSAO,
			C7_FORNECE    AS SUPPLIER,
			A2_NREDUZ     AS NOME,
			A2_NOME    AS RAZAO,
			C7_PRODUTO    AS PRODUCT,
			C7_DESCRI     AS PRODUCT_NAME,
			C7_TOTAL      AS PO_VALUE,
			C7_OBS        AS NOTE,
			CR_USER,
			%EXP:cLinkApr%+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,5,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,10,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,15,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,1,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,6,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,11,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,16,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,2,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,7,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,12,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,17,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,3,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,8,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,13,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,18,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,4,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,9,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,14,1) AS Approve,
			%EXP:cLinkRej%+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,5,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,10,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,15,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,1,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,6,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,11,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,16,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,2,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,7,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,12,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,17,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,3,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,8,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,13,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,18,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,4,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,9,1)+
			SUBSTRING(C7_FILIAL+C7_NUM+CR_USER+CR_NIVEL+%EXP:cEmpAnt%,14,1) AS Reject

		FROM %Table:SC7% SC7
		INNER JOIN %Table:SCR% SCR ON CR_NUM = C7_NUM
		INNER JOIN %Table:SA2% SA2 ON A2_COD= C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.%NotDel%
		INNER JOIN %Table:SE2% SA2 ON A2_COD= C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.%NotDel%
		WHERE C7_CONAPRO != 'L' 
		AND CR_STATUS = '02'
		AND SC7.%NotDel%
		AND SCR.%NotDel%
		ORDER BY CR_USER,C7_NUM


	EndSQL         

	(cAlias)->(DbGoTop())
	IF (cAlias)->(!Eof())       
		While (cAlias)->(!Eof())
			nQtdNf++
			if(!empty(cUsrApr) .AND. cUsrApr != (cAlias)->CR_USER)
				//				_cEmaPar += ';'+UsrRetMail ( cUsrApr )
				envMail(_cHtml,nTotPis,nTotCof,nTotCsll,nTotInss,nTotIr,nTotIss,nTotNf,_cEmaPar,nQtdNf)
				_cHtml := "</tr>"
				nTotPis :=0
				nTotCof :=0
				nTotCsll :=0
				nTotInss :=0
				nTotIr := 0
				nTotIss :=0
				nTotNf := 0
				_cEmaPar := _cEmaGes
				nQtdNf := 0
			ENDIF

			_cHtml += "<tr>"
			_cHtml += "<td  class='class_data'>"
			_cHtml += (cAlias)->F1_DOC +'/'+(cAlias)->F1_SERIE
			_cHtml += "</td>"
			_cHtml += "<td  class='class_data'>"
			_cHtml += (cAlias)->F1_ESPECIE
			_cHtml += "</td>"
			_cHtml += "<td  class='class_fornece'>"
			_cHtml += (cAlias)->F1_FORNECE+(cAlias)->F1_LOJA+' - '+(cAlias)->A2_NREDUZ
			_cHtml += "</td>"
			_cHtml += "<td  class='class_data'>"
			_cHtml += IF(LEN(ALLTRIM((cAlias)->A2_CGC))> 11,Transform( (cAlias)->A2_CGC, "@R 99.999.999/9999-99" ),Transform( (cAlias)->A2_CGC, "@R 999.999.999-99 " )) 
			_cHtml += "</td>"
			_cHtml += "<td  class='class_data'>"
			_cHtml += DTOC(STOD((cAlias)->emissPed))
			_cHtml += "</td>"
			_cHtml += "<td  class='class_data'>"
			_cHtml += DTOC(STOD((cAlias)->ultAprov))
			_cHtml += "</td>"
			_cHtml += "<td class='class_data'>"
			_cHtml += DTOC((cAlias)->F1_EMISSAO)
			_cHtml += "</td>"
			_cHtml += "<td class='class_data'>"
			_cHtml += DTOC((cAlias)->F1_DTDIGIT)
			_cHtml += "</td>"
			_cHtml += "<td class='class_data'>"
			_cHtml += DTOC((cAlias)->E2_VENCREA)
			_cHtml += "</td>"
			_cHtml += "<td  class='class_data'>"
			_cHtml += buscaUsu((cAlias)->F1_USERLGI)
			_cHtml += "</td>"
			_cHtml += "<td  class='class_data'>"
			_cHtml += fGetUsrName((cAlias)->userAp)
			_cHtml += "</td>"

			_cHtml += "<td  class='class_data'>"
			_cHtml += if(MONTH((cAlias)->F1_EMISSAO) != MONTH((cAlias)->F1_DTDIGIT),'Yes','No')
			_cHtml += "</td>"
			_cHtml += "<td  class='class_data'>"
			_cHtml += ALLTRIM(STR((cAlias)->diferenca))
			_cHtml += "</td>"
			_cHtml += "<td class='class_valor'>"   
			_cHtml += 'R$'+PadL(Alltrim(TRANSFORM((cAlias)->F1_VALPIS,"@E 9,999,999,999,999.99")),15) 
			_cHtml += "</td>"
			_cHtml += "<td class='class_valor'>"
			_cHtml += 'R$'+PadL(Alltrim(TRANSFORM((cAlias)->F1_VALCOFI,"@E 9,999,999,999,999.99")),15) 
			_cHtml += "</td>"
			_cHtml += "<td class='class_valor'>"
			_cHtml += 'R$'+PadL(Alltrim(TRANSFORM((cAlias)->F1_VALCSLL,"@E 9,999,999,999,999.99")),15) 
			_cHtml += "</td>"
			_cHtml += "<td class='class_valor'>"
			_cHtml += 'R$'+PadL(Alltrim(TRANSFORM((cAlias)->F1_INSS,"@E 9,999,999,999,999.99")),15) 
			_cHtml += "</td>"
			_cHtml += "<td class='class_valor'>"
			_cHtml += 'R$'+PadL(Alltrim(TRANSFORM((cAlias)->F1_IRRF,"@E 9,999,999,999,999.99")),15) 
			_cHtml += "</td>"
			_cHtml += "<td class='class_valor'>"
			_cHtml += 'R$'+PadL(Alltrim(TRANSFORM((cAlias)->F1_ISS,"@E 9,999,999,999,999.99")),15) 
			_cHtml += "</td>"
			_cHtml += "<td class='class_valor'>"
			_cHtml += 'R$'+PadL(Alltrim(TRANSFORM((cAlias)->F1_VALBRUT,"@E 9,999,999,999,999.99")),15)
			_cHtml += "</td>"

			_cHtml += "</tr>"

	
			cUsrApr  := (cAlias)->CR_USER

			(cAlias)->(dbSkip())
		enddo

		//		_cEmaPar += ';'+UsrRetMail ( cUsrApr )
		envMail(_cHtml,nTotPis,nTotCof,nTotCsll,nTotInss,nTotIr,nTotIss,nTotNf,_cEmaPar,nQtdNf)

	ENDIF

	(cAlias)->(dbclosearea()) 

RETURN

STATIC function envMail(_cHtml,nTotPis,nTotCof,nTotCsll,nTotInss,nTotIr,nTotIss,nTotNf,_cEmaPar,nQtdNf)
	oProc := TWFProcess():New("MAILFIN01","Invoices included overdue last 10 days")

	oProc:NewTask("Invoices included overdue last 10 days", "\WORKFLOW\HTML\MAILFIN01.HTML" )
	oProc:cSubject := "Invoices included overdue last 10 days"	
	oHtml := oProc:oHtml

	IF valtype(oHtml) != "U"

		oHtml:ValByName("cItens",_cHtml) 
		oHtml:ValByName("cNomEmp",FWFilialName()) 
		oHtml:ValByName("nQtdNf",nQtdNf) 
		oHtml:ValByName("nTotPis",'R$'+PadL(Alltrim(TRANSFORM(nTotPis,"@E 9,999,999,999,999.99")),15) ) 
		oHtml:ValByName("nTotCof", 'R$'+PadL(Alltrim(TRANSFORM(nTotCof,"@E 9,999,999,999,999.99")),15) )
		oHtml:ValByName("nTotCsll", 'R$'+PadL(Alltrim(TRANSFORM(nTotCsll,"@E 9,999,999,999,999.99")),15)  )
		oHtml:ValByName("nTotInss", 'R$'+PadL(Alltrim(TRANSFORM(nTotInss,"@E 9,999,999,999,999.99")),15) )
		oHtml:ValByName("nTotIr", 'R$'+PadL(Alltrim(TRANSFORM(nTotIr,"@E 9,999,999,999,999.99")),15))
		oHtml:ValByName("nTotIss", 'R$'+PadL(Alltrim(TRANSFORM(nTotIss,"@E 9,999,999,999,999.99")),15) )
		oHtml:ValByName("nTotNf", 'R$'+PadL(Alltrim(TRANSFORM(nTotNf,"@E 9,999,999,999,999.99")),15) )

		oProc:cTo := _cEmaPar
		oProc:Start()
		oProc:Finish()

		WFSendMail()
	endif	
return

static function buscaUsu(cUsrLgi)
	Local _cCodUsu := Subs( Embaralha( cUsrLgi, 1), 3, 6)
return FwGetUserName(_cCodUsu)

Static Function fGetUsrName(cUserID)
Return(AllTrim(UsrFullName(cUserID)))