#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

User function WFCOM003()

	U_WFCOM3A()

	U_WFCOM3B()

return

User function WFCOM3A()

	PREPARE ENVIRONMENT EMPRESA '02' FILIAL '01' TABLES "SF1" MODULO "SIGACOM"

	WFCOM()

	RESET ENVIRONMENT
return

User function WFCOM3B()

	PREPARE ENVIRONMENT EMPRESA '03' FILIAL '01' TABLES "SF1" MODULO "SIGACOM"

	WFCOM()

	RESET ENVIRONMENT
return

static function WFCOM()
	Local cAlias  		:= GetNextAlias()
	Local _cHtml        := ''
	Local _cHtmlFoll        := ''
	local cLFRC    		:= Chr(13) + Chr(10) 
	Local cEndSrv 		:= GetMv("MV_ENDWF",,"vmsapp_hmg") 
	Local cPort         := AllTrim(GetMv("TCP_PORTWF"))
	Local cLinRepr      := 'http://'+cEndSrv+':'+cPort+'/pp/U_weblogR.apw?keyvalue='
	Local cLinApr      := 'http://'+cEndSrv+':'+cPort+'/pp/U_weblogA.apw?keyvalue='
	Local cUsrApr := ''
	
	dbSelectArea('SC7')
	
	cLinApr := "%" + cLinApr + "%"
	
	BeginSQL Alias cAlias    

		Column C7_EMISSAO as date  
		SELECT 
		C7_NUM        AS NUMBER_PO,
		C7_CONTRA     AS NUMBER_CONTRACT, 
		C7_EMISSAO    AS DTEMISSAO,
		C7_FORNECE    AS SUPPLIER,
		A2_NREDUZ     AS NOME,
		A2_NOME    AS RAZAO,
		SUM(C7_TOTAL+C7_VALEMB+C7_VALFRE - C7_VLDESC + C7_VALIPI+ C7_VALSOL+C7_DESPESA+C7_SEGURO) AS PO_VALUE,
		CR_USER,
		C7_CONTRA,
		C7_CONTRAT,
		C7_MOEDA,
		C7_TXMOEDA,
		C7_FILIAL,C7_NUM,CR_NIVEL,
		ISNULL((SELECT CR_DATALIB FROM %Table:SCR% SCRR
					WHERE  
					 SCRR.D_E_L_E_T_ <> '*'  
					AND SCRR.R_E_C_N_O_ IN (
											SELECT MAX(SCR.R_E_C_N_O_) 
											FROM %Table:SCR% SCR2
											WHERE SCR2.CR_TIPO='PC' AND SCR2.CR_NUM= C7_NUM
											AND SCR2.D_E_L_E_T_ <> '*' AND SCR2.CR_STATUS ='03'
										  ) ),'---') as ultAprov
		FROM %table:SC7%  SC7
		INNER JOIN %table:SCR%  SCR ON CR_NUM = C7_NUM AND C7_FILIAL = CR_FILIAL
		INNER JOIN %table:SA2%  SA2 ON A2_COD= C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.%NotDel%
		WHERE C7_CONAPRO != 'L' AND C7_RESIDUO != 'S' AND C7_EMISSAO >'20200101'
		AND CR_STATUS='02' AND  CR_TIPO ='PC'
		AND SC7.%NotDel%
		AND SCR.%NotDel%
  GROUP BY C7_FILIAL,C7_NUM ,C7_CONTRAT,CR_NIVEL,
C7_CONTRA,C7_EMISSAO ,C7_FORNECE,A2_NREDUZ ,A2_NOME,CR_USER,C7_MOEDA,C7_TXMOEDA
		ORDER BY CR_USER,C7_NUM

	EndSQL         

	(cAlias)->(DbGoTop())
	IF (cAlias)->(!Eof())       
		While (cAlias)->(!Eof())
			
			_cHtmlLin := ''
			
			cLinApr := 'http://'+cEndSrv+':'+cPort+"/pp/U_weblogA.apw?keyvalue="+embaralha((cAlias)->C7_FILIAL+(cAlias)->C7_NUM+(cAlias)->CR_USER+(cAlias)->CR_NIVEL+cEmpAnt,0)
			cLinRepr := 'http://'+cEndSrv+':'+cPort+"/pp/U_weblogR.apw?keyvalue="+embaralha((cAlias)->C7_FILIAL+(cAlias)->C7_NUM+(cAlias)->CR_USER+(cAlias)->CR_NIVEL+cEmpAnt,0)
			
			cTdApr :=  '<td align="center" class="td_med td_center" style="align: center !important"> <strong> <a href="'+cLinApr+'" style="color:green">Approve</a></strong></td>'
			cTdRej :=  '<td align="center" class="td_med td_center" style="align: center !important" ><strong><a href="'+cLinRepr+'" style="color:red">Reject</a></strong></td>'
			
			if(!empty(cUsrApr) .AND. cUsrApr != (cAlias)->CR_USER)
				envMail(_cHtml,cUsrApr,_cHtmlFoll)
				_cHtml := "</tr>"
				_cHtmlFoll := "</tr>"
				cUsrApr := ''
			ENDIF
			_cHtmlLin += "<tr>"
			_cHtmlLin += "<td class='td_min td_center' >"
			_cHtmlLin += if(!empty((cAlias)->C7_CONTRA),'Contract Measurement',if(!empty((cAlias)->C7_CONTRAT),'Under Contract','Purchase Order'))
			_cHtmlLin += "</td>"
			_cHtmlLin += "<td class='td_min td_left' >"
			_cHtmlLin += (cAlias)->NUMBER_PO
			_cHtmlLin += "</td>"
			_cHtmlLin += "<td  class='td_med td_left'>"
			_cHtmlLin += (cAlias)->NUMBER_CONTRACT
			_cHtmlLin += "</td>"
			_cHtmlLin += "<td align='center' class='td_med td_center' >"
			_cHtmlLin += DTOC(STOD((cAlias)->DTEMISSAO))
			_cHtmlLin += "</td>"
			_cHtmlLin += "<td align='center' class='td_med td_center' >"
			_cHtmlLin += DTOC(STOD(if(!empty((cAlias)->ultAprov) .and. (cAlias)->ultAprov != '---',(cAlias)->ultAprov,(cAlias)->DTEMISSAO)))
			_cHtmlLin += "</td>"
			_cHtmlLin += "<td class='td_med td_left' >"
			_cHtmlLin += (cAlias)->SUPPLIER + ' - '+ (cAlias)->NOME
			_cHtmlLin += "</td>"
			_cHtmlLin += "<td class='td_med td_center' >"
			_nValTot := (cAlias)->PO_VALUE
			if (cAlias)->C7_MOEDA != 1
				_nValTot := XMOEDA((cAlias)->PO_VALUE,(cAlias)->C7_MOEDA,1,STOD((cAlias)->DTEMISSAO),2,(cAlias)->C7_TXMOEDA)
			ENDIF
			_cHtmlLin += 'R$'+PadL(Alltrim(TRANSFORM(_nValTot,"@E 9,999,999,999,999.99")),15) 
			_cHtmlLin += "</td>"
			_cHtmlLin += "<td class='td_big td_left' >"
			_cHtmlLin += TRATAOBS((cAlias)->C7_FILIAL,(cAlias)->NUMBER_PO)
			_cHtmlLin += "</td>"
			_cHtmlFoll += _cHtmlLin
//			_cHtmlLin += "<td class='class_data'>"
			_cHtmlLin += cTdApr
//			_cHtmlLin += "</td>"
//			_cHtmlLin += "<td  class='class_data'>"
			_cHtmlLin += cTdRej
//			_cHtmlLin += "</td>"

			_cHtmlFoll += "<td class='td_min td_center'>---</td><td class='class_data'>---</td></tr>"
			
			_cHtmlLin += "</tr>"
			
			_cHtml += _cHtmlLin
			
			cUsrApr  := (cAlias)->CR_USER

			(cAlias)->(dbSkip())
		enddo

		envMail(_cHtml,cUsrApr,_cHtmlFoll)

	ENDIF

	(cAlias)->(dbclosearea()) 

RETURN

STATIC FUNCTION TRATAOBS(_cFil, _cNum)
Local _cObs := ''
SC7->(dbSetOrder(1))
IF SC7->(DBSeek(_cFil+_cNum))
	_cObs := SC7->C7_OBS
endif

RETURN TRATATXT(_cObs)


STATIC FUNCTION TRATATXT(cString)
 Local _sRet := cString

   
   _sRet := StrTran (_sRet, "'", "")
   _sRet := StrTran (_sRet, '"', "")
//   _sRet := StrTran (_sRet, "º", ".")
//   _sRet := StrTran (_sRet, "ª", ".")
   _sRet := StrTran (_sRet, "&", "e")
   _sRet := StrTran (_sRet, "|", "")
   _sRet := StrTran (_sRet, "\", " ")
   _sRet := StrTran (_sRet, "/", " ")
   _sRet := StrTran (_sRet, "<", " ")
   _sRet := StrTran (_sRet, ">", " ")
   _sRet := StrTran (_sRet, chr (9), " ") // TAB
   _sRet := ALLTRIM (_sRet) 
   //_sRet := StrTran (_sRet, chr (32), "") // TAB
   //Só para garantir
//   _sRet := noAcento (_sRet)
   
RETURN _sRet
STATIC function envMail(_cHtml,_cUsr, cHtmlFol)
	
	Local _cNome := UsrFullName(_cUsr)
	Local _cMail :=UsrRetMail ( _cUsr )
	Local _cTxtAdd := ' on '+DTOC(DATE())+' - '+_cNome
	Local _cMailFol := getMv("MV_ACOMPWF")
	oProc := TWFProcess():New("MAILCOM03","Purchase Orders Pending Approval")
	
	oProc:NewTask("Purchase Orders Pending Approval", "\WORKFLOW\HTML\MAILCOM03.HTML" )
	oProc:cSubject := "Purchase Orders Pending Approval"+_cTxtAdd	
	oHtml := oProc:oHtml

	IF valtype(oHtml) != "U"

		oHtml:ValByName("cItens",_cHtml) 
		oHtml:ValByName("cNomEmp",FWFilialName()) 
		oHtml:ValByName("cTxtAdc",_cTxtAdd) 
		oProc:cTo := _cMail
		oProc:Start()
		oProc:Finish()

		WFSendMail()
		//Envia Follow
		oProc := TWFProcess():New("MAILCOM03","Purchase Orders Pending Approval (Follow)")
	
		oProc:NewTask("Purchase Orders Pending Approval", "\WORKFLOW\HTML\MAILCOM03.HTML" )
		oProc:cSubject := "Purchase Orders Pending Approval"+_cTxtAdd	+ '  (Follow)'
		oHtml := oProc:oHtml

		IF valtype(oHtml) != "U"

			oHtml:ValByName("cItens",cHtmlFol) 
			oHtml:ValByName("cNomEmp",FWFilialName()) 
			oHtml:ValByName("cTxtAdc",_cTxtAdd) 
			oProc:cTo := _cMailFol
			oProc:Start()
			oProc:Finish()
	
			WFSendMail()
		endif
		
	endif	
return

static function buscaUsu(cUsrLgi)
	Local _cCodUsu := Subs( Embaralha( cUsrLgi, 1), 3, 6)
return FwGetUserName(_cCodUsu)