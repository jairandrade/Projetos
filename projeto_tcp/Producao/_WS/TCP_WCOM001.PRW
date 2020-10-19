#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

User function WFCOM001()

U_WFCOM0A()

U_WFCOM0B()

return

User function WFCOM0A()

PREPARE ENVIRONMENT EMPRESA '02' FILIAL '01' TABLES "SF1" MODULO "SIGACOM"
		
	WFCOM()

RESET ENVIRONMENT
return

User function WFCOM0B()

PREPARE ENVIRONMENT EMPRESA '03' FILIAL '01' TABLES "SF1" MODULO "SIGACOM"
		
	WFCOM()

RESET ENVIRONMENT
return

static function WFCOM()
	Local cAlias  		:= GetNextAlias()
	Local nDiasDgt 		:= GETMV('TCP_WFC001')
	Local _cEmaPar		:= Lower(AllTrim(GetMv("MV_EMAGES")))
	Local _cEmaGes		:= Lower(AllTrim(GetMv("MV_EMAGES")))
	Local _nDifDia		:= GetMv("MV_DIFDIA")
	Local cEpecNf		:= GetMv("TCP_ESPNFS")
	Local _cHtml        := ''
	Local _dData   		:= DaySuB( date() , nDiasDgt )
	local cLFRC    		:= Chr(13) + Chr(10) 
	Local nTotPis := 0
	Local nTotCof := 0
	Local nTotCsll := 0
	Local nTotInss := 0
	Local nTotIr := 0
	Local nTotIss := 0
	Local nTotNf := 0
	Local cUsrApr := ''
	Local nQtdNf  := 0
	
	cEpecNf := '%'+FormatIn( cEpecNf,";") + '%'
	
	BeginSQL Alias cAlias    
		
		Column F1_EMISSAO as date  
		Column F1_DTDIGIT as date
		Column E2_VENCREA as date
		SELECT F1_FILIAL,F1_EMISSAO,F1_DTDIGIT,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,A2_NREDUZ,A2_CGC,F1_USERLGI,F1_VALPIS,F1_ESPECIE,
		F1_VALBRUT,F1_ISS,F1_IRRF,F1_INSS,F1_VALCSLL,F1_VALCOFI,DATEDIFF(day,F1_EMISSAO, F1_DTDIGIT) as diferenca,E2_VENCREA,
		ISNULL((SELECT CR_USER FROM %Table:SCR% SCR
					WHERE  
					 SCR.D_E_L_E_T_ <> '*'  
					AND SCR.R_E_C_N_O_ = (
											SELECT MIN(SCR.R_E_C_N_O_) 
											FROM %Table:SCR% SCR, %Table:SD1% SD1
											WHERE SF1.F1_FILIAL=SD1.D1_FILIAL AND SF1.F1_DOC=SD1.D1_DOC AND SF1.F1_SERIE =SD1.D1_SERIE
											AND SF1.F1_FORNECE=SD1.D1_FORNECE AND SF1.F1_LOJA=SD1.D1_LOJA
											AND SCR.CR_FILIAL = SD1.D1_FILIAL AND SCR.CR_NUM = SD1.D1_PEDIDO
											AND SCR.D_E_L_E_T_ <> '*'
										  ) ),'---') as userAp ,
		ISNULL((SELECT CR_DATALIB FROM %Table:SCR% SCR
					WHERE  
					 SCR.D_E_L_E_T_ <> '*'  
					AND SCR.R_E_C_N_O_ = (
											SELECT MAX(SCR.R_E_C_N_O_) 
											FROM %Table:SCR% SCR, %Table:SD1% SD1
											WHERE SF1.F1_FILIAL=SD1.D1_FILIAL AND SF1.F1_DOC=SD1.D1_DOC AND SF1.F1_SERIE =SD1.D1_SERIE
											AND SF1.F1_FORNECE=SD1.D1_FORNECE AND SF1.F1_LOJA=SD1.D1_LOJA
											AND SCR.CR_FILIAL = SD1.D1_FILIAL AND SCR.CR_NUM = SD1.D1_PEDIDO
											AND SCR.D_E_L_E_T_ <> '*'
										  ) ),'---') as ultAprov,
		ISNULL((SELECT CR_EMISSAO FROM %Table:SCR% SCR
					WHERE  
					 SCR.D_E_L_E_T_ <> '*'  
					AND SCR.R_E_C_N_O_ = (
											SELECT MAX(SCR.R_E_C_N_O_) 
											FROM %Table:SCR% SCR, %Table:SD1% SD1
											WHERE SF1.F1_FILIAL=SD1.D1_FILIAL AND SF1.F1_DOC=SD1.D1_DOC AND SF1.F1_SERIE =SD1.D1_SERIE
											AND SF1.F1_FORNECE=SD1.D1_FORNECE AND SF1.F1_LOJA=SD1.D1_LOJA
											AND SCR.CR_FILIAL = SD1.D1_FILIAL AND SCR.CR_NUM = SD1.D1_PEDIDO
											AND SCR.D_E_L_E_T_ <> '*'
										  ) ),'---') as emissPed 								  
		
		FROM %Table:SF1% SF1
		INNER JOIN %Table:SA2% SA2 ON A2_COD = F1_FORNECE AND A2_LOJA = F1_LOJA
		INNER JOIN %Table:SE2% SE2 ON E2_NUM = F1_DOC AND E2_PREFIXO = F1_SERIE AND E2_FORNECE = F1_FORNECE AND E2_LOJA = F1_LOJA
		AND E2_PARCELA IN ('  ', '01')
		WHERE 
		F1_EMISSAO >= %EXP:DTOS(_dData)% AND 
		F1_EMISSAO < F1_DTDIGIT AND ( DATEDIFF(day,F1_EMISSAO, F1_DTDIGIT) >= %EXP:ALLTRIM(STR(_nDifDia))% OR MONTH(F1_EMISSAO) != MONTH(F1_DTDIGIT))
		AND SF1.%NotDel% AND SA2.%NotDel%  AND SE2.%NotDel%  AND LTRIM(RTRIM(F1_ESPECIE)) IN %EXP:cEpecNf%
		order by userAp,A2_NREDUZ,F1_EMISSAO
	EndSQL         
	
	(cAlias)->(DbGoTop())
	IF (cAlias)->(!Eof())       
		While (cAlias)->(!Eof())
			nQtdNf++
			if(!empty(cUsrApr) .AND. cUsrApr != (cAlias)->userAp)
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
			
			nTotPis  += (cAlias)->F1_VALPIS
			nTotCof  += (cAlias)->F1_VALCOFI
			nTotCsll += (cAlias)->F1_VALCSLL
			nTotInss += (cAlias)->F1_INSS
			nTotIr   += (cAlias)->F1_IRRF
			nTotIss  += (cAlias)->F1_ISS
			nTotNf   += (cAlias)->F1_VALBRUT
			cUsrApr  := (cAlias)->userAp
			
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