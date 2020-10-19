#include 'protheus.ch'


#define PENDIN     'Pending'
/*/{Protheus.doc} ClassIntPcCompras
(long_description)
@author    Eduardo
@since     28/05/2019
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
class ClassIntPcCompras 

method new() constructor 
method gravaLogZZK()  
method registraIntegracao()  
Method buscaPed()
Method carrDados()
Method carrDadosPc()
Method carrDadosAl()
method enviaPost()
method atuLog()
method atuErro()
method enviaSales()
method buscaAnexo()
method buscaPagtos()
method buscaRateios()
method buscaItems()
method buscaCot()
method SIGLAMOEDA()
method CARACESP()
method PROXCODIGO()
method PROXALCA()
Method PROXAPR()
method RetNomFunc()
method reenviaSales()
method pedVenc()
method retWs()
method procPed()
method procAlcada()
method vincAlcada()
method vincUsuario()
method vincGrupo()
method tratNum()
method criaAlcada()
method atuCodPed()
method fGetUsrName()
data oRetorno
Data cCorpoPost
data cNumSolics
data cCodInt
data cFilPc
data cCodAl
data cNumPc
data cItmSc
data lIntegra
data cErroInt
data cNumPed
data nTotPed
data nTotProd
data nTotFret
data nTotDisc
data nTotTax
data oRetWs
data cErro
data cSugestao
data cStatAprov
data cStatScr
data primNivel
data primUser
data ultAprov
data _cTipo
data cMethod
data aGrpSal
data cGrpSales
data cGrpProt
data cChvAnx
data cOper
endclass

/*/{Protheus.doc} new
Metodo construtor
@author    Eduardo
@since     28/05/2019
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
method new() class ClassIntPcCompras
	::cCorpoPost := ''
	::lIntegra := GETMV( 'TCP_PCSFOR' ) 
	::cNumPc   := ''
	::cItmSc   := ''
	::cErro    := ''
	::cSugestao := ''
	::cErroInt := ''
	::_cTipo   := ''
	::cMethod  := ''
	::aGrpSal  := {}
	::oRetWs   := nil 
	::oRetorno := nil
	::cGrpSales:= ''
	::cGrpProt := ''
	::cChvAnx  := ''
	::cCodAl   := ''
	::cOper    := ''
return

/*/{Protheus.doc} registraIntegracao
(metodo responsavel pelo controle da integraí§ão. Grava o registro da integraí§ão))
@author    Eduardo
@since     28/05/2019
@version   ${version}
@param cTipo, Character, Indica qual entidade está sendo movimentada 1=IncCot
@example
(examples)
@see (links_or_references)
/*/
method registraIntegracao(_cTipo,_cCod,_cOper) class ClassIntPcCompras

	Local lRet := .T.
	Local cMetIncPed := superGETMV( 'TCP_MINCPC', .T.,'AtualizarPurchaseOrder' ) //"https://wsc-hom.tcp.com.br/SalesForce/api/AtualizarPurchaseOrder"
	Local cMetAlcada := superGETMV( 'TCP_URLALC', .T.,'ObterAreaPurchaseOrder' ) //"https://wsc-hom.tcp.com.br/SalesForce/api/ObterAreaPurchaseOrder"

	::_cTipo := _cTipo
	::cOper  := _cOper
	IF ::lIntegra
		
		IF ! ::buscaPed(_cTipo,_cCod,_cOper)
			lRet := .F.
		ENDIF
	ENDIF

return lRet
/*/{Protheus.doc} enviaSales
(metodo responsavel pelo envio))
@author    Eduardo
@since     28/05/2019
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
method enviaSales() class ClassIntPcCompras
	Local lRet := .F.
	IF !EMPTY(::cCodInt)

		if ::carrDados()
			lRet := ::enviaPost()
		endif
	else
		::cErro := 'Nenhum cí³digo de integraí§ão para integrar.'
		::cSugestao := 'Entre em contato com o suporte'
		RETURN .F.
	ENDIF
return lRet
/*/{Protheus.doc} gravaLog
(long_description)
@author    Eduardo
@since     28/05/2019
@version   ${version}
@param cNumPc, Character, ${param_descr}
@example
(examples)
@see (links_or_references)
/*/
method gravaLogZZK(cOper) class ClassIntPcCompras

	if empty(::cNumPc)
		::cErro := 'Informe o níºmero e o item do PC.'
		::cSugestao := 'Entre em contato com o suporte'
		return .F.
	ENDIF

	RecLock("ZZK",.T.)

	ZZK->ZZK_CODIGO  := ::cCodInt
	ZZK->ZZK_FILIAL  := ::cFilPc
	ZZK->ZZK_NUMPC   := ::cNumPc
	ZZK->ZZK_DATA    := DATE()
	ZZK->ZZK_HORA    := TIME()
	ZZK->ZZK_STATUS  := 'P'
	ZZK->ZZK_OPER    := cOper
	ZZK->ZZK_URL     := ::cMethod
	ZZK->ZZK_TIPO    := ::_cTipo
	ZZK->ZZK_ERRO    := ::cErro
	ZZK->ZZK_USUARI  := RetCodUsr( )
	ZZK->ZZK_ROTINA  := Alltrim(FunName())
	ZZK->ZZK_XMLENV  := ::cCorpoPost
	   
	ZZK->(msUnlock())
return .T.

method buscaPed(_cTipo,_cChave,_cOper) class ClassIntPcCompras

	Local cAlias
	Local lRet := .T.
	Local cWhere := '%%'
	Local cMetIncPed := superGETMV( 'TCP_MINCPC', .T.,'AtualizarPurchaseOrder' ) //"https://wsc-hom.tcp.com.br/SalesForce/api/AtualizarPurchaseOrder"
	Local cMetAlcada := superGETMV( 'TCP_URLALC', .T.,'ObterAreaPurchaseOrder' ) //"https://wsc-hom.tcp.com.br/SalesForce/api/ObterAreaPurchaseOrder"

	::cCodInt := ::PROXCODIGO()

	cAlias := getNextAlias()
	IF _cOper $ "I\A\E\W\R\L"
		DO CASE
			CASE _cTipo == '1'
			
				::cMethod := cMetIncPed
				
				BeginSQL Alias cAlias
		
					SELECT C7_FILIAL as FILIAL,C7_NUM AS NUMPC
					FROM %TABLE:SC7% SC7
					WHERE SC7.%NotDel% AND C7_FILIAL || C7_NUM = %EXP:_cChave%  
					GROUP BY C7_FILIAL ,C7_NUM 
		
				EndSQL
			
			CASE _cTipo == '2'
			
				::cMethod := cMetAlcada
			
				BeginSQL Alias cAlias
		
					SELECT C7_FILIAL as FILIAL,C7_NUM AS NUMPC
					FROM %TABLE:SC7% SC7
					WHERE SC7.%NotDel% AND C7_FILIAL || C7_NUM = %EXP:_cChave%  
					GROUP BY C7_FILIAL ,C7_NUM 
		
				EndSQL
	
			CASE _cTipo == '3'
			
				::cMethod := cMetAlcada
				
				::cFilPc := xFilial('SC7')
				::cNumPc := 'XXXXXX'
	
				::gravaLogZZK(_cOper)
				
			CASE _cTipo == '4'
			
				::cMethod := 'WsApproval'
			
				BeginSQL Alias cAlias
		
					SELECT C7_FILIAL as FILIAL,C7_NUM AS NUMPC
					FROM %TABLE:SC7% SC7
					WHERE SC7.%NotDel% AND UPPER(C7_XSALES) = %EXP:UPPER(ALLTRIM(_cChave))%  
					GROUP BY C7_FILIAL ,C7_NUM 
		
				EndSQL
				
			CASE _cTipo == '5'
			
				::cMethod := cMetIncPed
				
				BeginSQL Alias cAlias
		
					SELECT C7_FILIAL as FILIAL,C7_NUM AS NUMPC
					FROM %TABLE:SC7% SC7
					WHERE C7_FILIAL || C7_NUM = %EXP:_cChave%  
					GROUP BY C7_FILIAL ,C7_NUM 
		
				EndSQL
				
			OTHERWISE
			::cErro := 'Etapa não inválida.'
			::cSugestao := 'Entre em contato com o suporte'
			lRet := .F.
	
		ENDCASE
	ELSE
		::cErro := 'Operação de integração inválida.'
		::cSugestao := 'Entre em contato com o suporte'
		lRet := .F.
	ENDIF
	
	//Quando for xxxxx,  apenas para vaalidar se esta respondendo.
	IF ::cNumPc != 'XXXXXX'
		if lRet
			if !(cAlias)->(Eof())      
				while !(cAlias)->(Eof())
	
					::cFilPc := (cAlias)->FILIAL
					::cNumPc := (cAlias)->NUMPC
					//		::cItmSc := (cAlias)->ITEMSC
	
					::gravaLogZZK(_cOper)
	
					(cAlias)->(dbSkip())
				enddo
	
				//		ConfirmSX8()
			else
				lRet := .F.
			endif
			
			(cAlias)->(dbCloseArea())  
			
		else
			::cCodInt := ''
			//	RollBackSX8()
		endif
		
	ENDIF

return lRet

//carrega paraametros
method carrDados() class ClassIntPcCompras
	Local lRet := .T. 

	DO CASE
		CASE ::_cTipo == '1'

		lRet := ::carrDadosPc()

		CASE ::_cTipo == '2'

		lRet := ::carrDadosAl()
		
		CASE ::_cTipo == '3'

		lRet := ::carrDadosAl()
		
		CASE ::_cTipo == '5'

		lRet := ::carrDadosPc()

		OTHERWISE
		::cErro := 'Etapa inválida.'
		::cSugestao := 'Entre em contato com o suporte'
		lRet := .F.

	ENDCASE

return lRet


//carrega dados Pedido
method carrDadosPc() class ClassIntPcCompras
	Local _cCod := ::cCodInt
	Local _cFilPc := ::cFilPc
	Local lRet    := .T.
	Local _cWhere := '%%'
	::cCorpoPost := ''
	
	IF ::_cTipo != '5'
		_cWhere := "% AND SC7.D_E_L_E_T_ = ' ' "
		_cWhere += "%"
	endif
	
	IF VALTYPE(::cGrpSales ) == 'C' .AND. !EMPTY(::cGrpSales  )
		cAlias := getNextAlias()
	
		BeginSQL Alias cAlias
	
			SELECT C7_FILIAL,C7_NUM,C7_CONTRA,C7_CONTRAT,C7_XSALES, SC7.D_E_L_E_T_ AS C7DEL,A2_COD,A2_LOJA,A2_NREDUZ,C7_XTERMOS,C7_MEDICAO,
			C7_USER,E4_DESCRI,C7_MOEDA, C7_TXMOEDA,CN9_VLATU,C7_REVISAO,CN9_SALDO,C7_NUMCOT,C7_XGRPSAL,ZZK_OPER,C7_EMISSAO,
			SUM(C7_VALIPI+C7_VALSOL) AS TOTIMP,C7_VALEMB,SUM(C7_TOTAL) AS VALTOT, SUM(C7_VALFRE) AS VALFRE, SUM(C7_VLDESC) AS VALDESC,
			C7_CONTREV
			FROM %TABLE:ZZK% ZZK
			INNER JOIN %TABLE:SC7% SC7 ON ZZK_FILIAL= C7_FILIAL AND C7_NUM = ZZK_NUMPC 
			INNER JOIN %TABLE:SA2% SA2 ON A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.%NotDel%
			INNER JOIN %TABLE:SE4% SE4 ON C7_COND= E4_CODIGO AND SE4.%NotDel%
			LEFT JOIN %TABLE:CN9% CN9 ON CN9_FILIAL = C7_FILIAL AND CN9_NUMERO = C7_CONTRA AND C7_CONTREV = CN9_REVISA AND CN9.%NotDel%
			WHERE ZZK.%NotDel% AND ZZK_CODIGO = %EXP:_cCod% AND ZZK_FILIAL = %EXP:_cFilPc% AND 1=1 %EXP:_cWhere%
			GROUP BY C7_FILIAL,C7_NUM,C7_CONTRA,C7_CONTRAT,C7_XSALES, SC7.D_E_L_E_T_ ,A2_COD,A2_LOJA,A2_NREDUZ,C7_XTERMOS,
			C7_USER,E4_DESCRI,C7_MOEDA, C7_TXMOEDA,CN9_VLATU,C7_REVISAO,CN9_SALDO,C7_NUMCOT,C7_XGRPSAL,ZZK_OPER,C7_EMISSAO,
			C7_VALEMB,C7_MEDICAO,C7_CONTREV
			ORDER BY C7_FILIAL,C7_NUM
	
		EndSQL
	
		IF !(cAlias)->(Eof())
			
			
			::cChvAnx  += "'CN9"+(cAlias)->C7_CONTRA + "'"
			
			::cChvAnx  += ",'CND"+(cAlias)->C7_FILIAL+(cAlias)->C7_CONTRA+(cAlias)->C7_CONTREV +(cAlias)->C7_MEDICAO+ "'"
			::cChvAnx  += ",'CND"+(cAlias)->C7_FILIAL+(cAlias)->C7_CONTRA+(cAlias)->C7_MEDICAO+ "'"
			
			::cFilPc     := (cAlias)->C7_FILIAL
			::cCorpoPost := '{'
			::cCorpoPost += '"order": '
			::cCorpoPost += ' {"CompanyCod": "'+cEmpAnt+'", '
			::cCorpoPost += ' "Company": "'+ALLTRIM(FWFilialName(cEmpAnt ,(cAlias)->C7_FILIAL )) +'", '
			::cCorpoPost += ' "Branch": "'+(cAlias)->C7_FILIAL+'", '
			::cCorpoPost += ' "FlowRestart": ' + if((cAlias)->ZZK_OPER == 'A' .AND. !EMPTY((cAlias)->C7_XSALES),'true','false') + ', '
			::cCorpoPost += ' "ExcluidoResiduo": ' + if((cAlias)->ZZK_OPER == 'L','true','false') + ', '
			::cCorpoPost += ' "PurchaseOrderType": "'+IF(!EMPTY((cAlias)->C7_CONTRA),'Contract Measurement','Purchase Order')+'", '
			::cCorpoPost += ' "IdPurchaseOrder": "'+if((cAlias)->ZZK_OPER != 'I',ALLTRIM((cAlias)->C7_XSALES),'')  +'", '
			::cCorpoPost += ' "Area": "'+::cGrpSales+'", '
			::cCorpoPost += ' "Excluido": '+if((cAlias)->C7DEL == '*','true','false')+',' 
			::cCorpoPost += ' "IdOrder": "'+(cAlias)->C7_NUM+'", '
			::cCorpoPost += ' "Provider": "'+(cAlias)->A2_COD+' - '+::CARACESP((cAlias)->A2_NREDUZ)+if((cAlias)->C7_MOEDA <> 1,"(Estimated Values - Import)","")+'", '
			::cCorpoPost += ' "DateOfIssue": "'+DTOC(STOD((cAlias)->C7_EMISSAO))+'", '
			::cCorpoPost += ' "PaymentTerm": "'+::CARACESP((cAlias)->E4_DESCRI)+'", '
 
			
			_cUsuCmp := (cAlias)->C7_USER
			PswOrder(1)
			_cNomCmp := ''
			_cMailCmp := ''
			If  PswSeek((cAlias)->C7_USER,.T.) //Se usuario encontrado
			
				aGrupos := Pswret(1)  
				_cUsuCmp := aGrupos[1,2]
				_cNomCmp := aGrupos[1,4]
				_cMailCmp := aGrupos[1,14]
			endif
			
			::cCorpoPost += ' "Buyer": "'+_cUsuCmp+'", '
			::cCorpoPost += ' "BuyerName": "'+::CARACESP(_cNomCmp)+'", '
			::cCorpoPost += ' "BuyerEmail": "'+_cMailCmp+'", '
			::cCorpoPost += ' "ProposalKeyTerms": "'+::CARACESP((cAlias)->C7_XTERMOS)+'", '
			::cCorpoPost += ' "Note": "'+::CARACESP(POSICIONE('SC7',1,(cAlias)->C7_FILIAL+(cAlias)->C7_NUM,'C7_OBS'))+'", '
			::cCorpoPost += ' "Contract": '+IF(POSICIONE('SC7',1,(cAlias)->C7_FILIAL+(cAlias)->C7_NUM,'C7_CONTRAT')=='S','true','false')+', '
			::cCorpoPost += ' "CurrencyType": "'+U_getWFMoe((cAlias)->C7_MOEDA)+'", '
			::cCorpoPost += ' "ContractNumber": "'+(cAlias)->C7_CONTRA+'", '
	
			
			::cNumPed  := (cAlias)->C7_NUM
			
//			::nTotTax  := (cAlias)->TOTIMP
//			::nTotPed  := (cAlias)->VALTOT + (cAlias)->C7_VALEMB +(cAlias)->TOTIMP+ (cAlias)->VALFRE - (cAlias)->VALDESC
//			::nTotFret := (cAlias)->VALFRE
//			::nTotDisc := (cAlias)->VALDESC
//			::nTotProd := (cAlias)->VALTOT
			
			
			_nTxDol := 0
			_nTotDol := 0
			
			::cCorpoPost += ::buscaItems((cAlias)->C7_FILIAL,(cAlias)->C7_NUM)
			
			IF (cAlias)->C7_MOEDA != 1
				
				if( (cAlias)->C7_TXMOEDA != 0)
					_nTxDol := (cAlias)->C7_TXMOEDA
				else
					if((cAlias)->C7_MOEDA == 2)
						_nTxDol := Posicione('SM2',1,(cAlias)->C7_EMISSAO,"M2_MOEDA2")
					elseif((cAlias)->C7_MOEDA == 3)
						_nTxDol := Posicione('SM2',1,(cAlias)->C7_EMISSAO,"M2_MOEDA3")
					else
						_nTxDol := Posicione('SM2',1,(cAlias)->C7_EMISSAO,"M2_MOEDA4")
					endif
				endif
				_nTotDol := ::nTotPed
				
				::nTotTax  := XMOEDA(::nTotTax,(cAlias)->C7_MOEDA,1,STOD((cAlias)->C7_EMISSAO),2,(cAlias)->C7_TXMOEDA) 
				::nTotPed  := XMOEDA(::nTotPed,(cAlias)->C7_MOEDA,1,STOD((cAlias)->C7_EMISSAO),2,(cAlias)->C7_TXMOEDA) 
				::nTotFret  := XMOEDA(::nTotFret,(cAlias)->C7_MOEDA,1,STOD((cAlias)->C7_EMISSAO),2,(cAlias)->C7_TXMOEDA) 
				::nTotDisc  := XMOEDA(::nTotDisc,(cAlias)->C7_MOEDA,1,STOD((cAlias)->C7_EMISSAO),2,(cAlias)->C7_TXMOEDA) 
				//Ja vem convertido
//				::nTotProd  := XMOEDA(::nTotProd,(cAlias)->C7_MOEDA,1,STOD((cAlias)->C7_EMISSAO),2,(cAlias)->C7_TXMOEDA) 
	
			ENDIF
			
			_nValAberto := 0
			_vValorSaldo := 0

			if !empty((cAlias)->C7_CONTRA)
				
				::cCorpoPost += ::buscaPagtos((cAlias)->C7_FILIAL,(cAlias)->C7_CONTRA,(cAlias)->A2_COD,(cAlias)->A2_LOJA)
				_nValAberto := u_pedidosAb((cAlias)->C7_CONTRA,(cAlias)->C7_REVISAO,(cAlias)->C7_NUM)
				
				if (!IsInCallStack("CNTA120") .AND. !IsInCallStack("CNTA121") )
					_nValAberto += ::nTotPed
				ENDIF
				_vValorSaldo := (cAlias)->CN9_SALDO + _nValAberto 
		
			endif
			
			::cCorpoPost += ::buscaCot((cAlias)->C7_FILIAL,(cAlias)->C7_NUM)
			::cCorpoPost += ::buscaRateios((cAlias)->C7_FILIAL,(cAlias)->C7_NUM,(cAlias)->C7_CONTRA,(cAlias)->C7_MEDICAO)
			::cCorpoPost += ::buscaAnexo()

			::cCorpoPost += ' "Dolar": "'+::tratNum(_nTxDol)+'", '
			::cCorpoPost += ' "TotalDolar": "'+::tratNum(_nTotDol)+'", '
//			::cCorpoPost += ' "TotalInvoice": "'+::tratNum(::nTotPed) +'", '
			
			::cCorpoPost += ' "TotalContract": "'+::tratNum((cAlias)->CN9_VLATU) +'", '
			::cCorpoPost += ' "CurrentBalance": "'+::tratNum(_vValorSaldo) +'", '
			
			::cCorpoPost += ' "Taxes": "'+::tratNum(::nTotTax) +'", '
			::cCorpoPost += ' "Discount": "'+::tratNum(::nTotDisc)  +'", '
			::cCorpoPost += ' "Freight": "'+::tratNum(::nTotFret) +'", '
			::cCorpoPost += ' "TotalProduct": "'+::tratNum(::nTotProd) +'", '
			::cCorpoPost += ' "Total": "'+::tratNum(::nTotPed)+'" '
	
			::cCorpoPost += '					}'
			//		::cCorpoPost += '					]'
			::cCorpoPost += '}'
			
		else
			::cErro := 'Pedido não encontrado.'
			::cSugestao := 'Entre em contato com o suporte'
			lRet := .F. 
		ENDIF
		(cAlias)->(dbCloseArea())
	ELSE
		::cErro := 'Nenhuma alçada de aprovação selecionada.'
		::cSugestao := 'Selecione uma alçada.'
		lRet := .F. 
	ENDIF
return lRet

method tratNum(cNum) class ClassIntPcCompras
return STRTRAN(ALLTRIM(TRANSFORM(cNum,'@E 999999999999999.99')),',','.')
//carrega dados Alí§ada
method carrDadosAl() class ClassIntPcCompras
	Local lRet := .T.
	::cCorpoPost := ''

return lRet

method enviaPost() class ClassIntPcCompras


	Local _cUrlSal := GETMV( 'TCP_URLPCS' ) //"https://wsc-hom.tcp.com.br/SalesForce/api/AtualizarPurchaseOrder"
	Local _nTime   := 3000
	Local aHeadSal := {}
	Local cAutRet  := ""
	Local _cPostAu := ""
	Local _cCorpo  := ""
	
	_cUrlSal += ::cMethod
	aadd(aHeadSal,'Content-Type: application/json; charset=UTF-8')
	
	// aadd(aHeadSal,'Content-Type: text/plain;charset=UTF-8')

	_cPostAu := HttpPost(_cUrlSal,"",::cCorpoPost,_nTime,aHeadSal,@cAutRet)

	::atuLog(_cPostAu,cAutRet,_cUrlSal)

	lRet := ::retWs(_cPostAu,cAutRet)
	
	::atuLog(_cPostAu,cAutRet,_cUrlSal)
	
return lRet

method retWs(_cRetWs,cAutRet) class ClassIntPcCompras
	Local _cSta := ''
	Local _cDesc := ''
	Local lRet := .f.
	Local oJChecking	:= Nil
	If ("200 OK" $ cAutRet) .and. _cRetWs != nil

		_cDesc := DecodeUtf8( _cRetWs,  "cp1252")
//		oJson := JsonObject():New()
//	 
//		ret := oJson:FromJson(_cDesc)
//		
//		FreeObj(oJson)

		FWJsonDeserialize(_cDesc,@oJChecking)
		
		DO CASE
			CASE ::_cTipo == '1'
	
				lRet := ::procPed(oJChecking)
	
			CASE ::_cTipo == '2'
	
				lRet := ::procAlcada(oJChecking)
			
			CASE ::_cTipo == '3'
	
				lRet := ::procAlcada(oJChecking)
			
			CASE ::_cTipo == '5'
	
				lRet := .T.
	
			OTHERWISE
				::cErro := 'Etapa não inválida. Retorno'
				::cSugestao := 'Entre em contato com o suporte'
				lRet := .F.
	
		ENDCASE
	else
		::cErro := 'Problema na integração com Sales Force.'
		::cSugestao := 'Entre em contato com o suporte'
		
		lRet := .F.
	EndIf
	
return lRet

method procPed(oJChecking) class ClassIntPcCompras
	Local oObjRet := nil
	Local lRet    := .T.
	
	if VALTYPE(oJChecking) == 'O'
		oObjRet := oJChecking
	ELSEif VALTYPE(oJChecking) == 'A' .AND. LEN(oJChecking) > 0
		oObjRet := oJChecking[1]
	ENDIF
	
	If VALTYPE(oObjRet) == 'O' 
		
		//Operaí§ão R apenas envia mais anexos. Não precisa reprocessar tudo
		if ::cOper != 'R'

			if !::atuCodPed(oObjRet:PurchaseOrderId)
				lRet := .F.
			endif	

			IF  VALTYPE(oObjRet:Status) == 'C' .AND. oObjRet:Status == PENDIN .AND. oObjRet:PurchaseOrderId != nil
				
				::oRetorno  := ClassRetPedido():new() 
				
				IF VALTYPE(oObjRet:Aprovadores) == 'A' 
					IF ::vincAlcada(oObjRet:Aprovadores)
					
						IF ::criaAlcada()
							::oRetorno:cCodAL    := ::cGrpProt
							::oRetorno:cPuchase  := oObjRet:PurchaseOrderId
							::oRetorno:cOrderId  := oObjRet:OrderId
							::oRetorno:cMensagem := oObjRet:Mensagem
							::oRetorno:lLibera   := .F.
							
							if oObjRet:PurchaseOrderId != nil
								if !::atuCodPed(oObjRet:PurchaseOrderId)
									lRet := .F.
								endif
							endif

						ELSE
							::cErro := 'Nío foi possí­vel cadastrar a alçada de aprovaíçío deste pedido.'
							::cSugestao := 'Entre em contato com o suporte' //COLOCAR RETORNO DE ERRO
							lRet := .F.
						ENDIF
					else
						IF EMPTY(::cErro)
							::cErro := 'Não foi possí­vel vincular a alí§ada.'
						ENDIF
						::cSugestao := 'Entre em contato com o suporte' //COLOCAR RETORNO DE ERRO
						lRet := .F.
					ENDIF
				ELSE
					::cErro := 'Não foi possí­vel preencher a alí§ada do pedido.'
					::cSugestao := 'Reenvie o pedido' //COLOCAR RETORNO DE ERRO
					lRet := .F.
				ENDIF
			ELSE
				::cErro := 'Não foi possí­vel gravar o pedido no Sales Force. '+IF(TYPE("oObjRet:Mensagem") == 'C',oObjRet:Mensagem,'' )
				::cSugestao := 'Entre em contato com o suporte' //COLOCAR RETORNO DE ERRO
				lRet := .F.
			ENDIF
		ENDIF
		
	ELSE//If TYPE("oObjRet:ERRORCODE") == 'C'
		::cErro := 'Não foi possí­vel receber a alí§ada do pedido.'
		::cSugestao := 'Reenvie o pedido' //COLOCAR RETORNO DE ERRO
		lRet := .F.
	endif
	
return lRet

method procAlcada(oJChecking) class ClassIntPcCompras
	lOCAL lRet := .T.
	Local _nInd := 0
	if valtype(oJChecking) != 'A' .OR. (valtype(oJChecking) == 'A' .AND. LEN(oJChecking) = 0 )
		::cErro := 'Não foi possí­vel consultar as alí§adas do Sales Force. Entre em contato com o suporte.'
		lRet := .F.
	ELSE
		::aGrpSal := {}
		for _nInd := 1 to LEN(oJChecking)
			AADD(::aGrpSal,{oJChecking[_nInd],oJChecking[_nInd]}) 
		NEXT
	ENDIF
	
	::oRetorno := ::aGrpSal
return lRet

method atuLog(_cRet,cAutRet,_cUrlSal) class ClassIntPcCompras

	dbSelectArea('ZZK')
	ZZK->( dbSetOrder(1) )
	IF ZZK->( dbSeek( ::cFilPc + ::cCodInt ) )

		while !	ZZK->(Eof()) .AND. ZZK->ZZK_FILIAL == ::cFilPc.AND.  ALLTRIM(ZZK->ZZK_CODIGO) == ::cCodInt

			RecLock("ZZK",.F.)
			ZZK->ZZK_XMLENV := ::cCorpoPost   
			ZZK->ZZK_XMLRET := _cRet
			ZZK->ZZK_STATUS := IF(!EMPTY(::cErro),'P',IF(("200 OK" $ cAutRet),'S','E'))
			ZZK->ZZK_RETURL := cAutRet
			ZZK->ZZK_URL    := _cUrlSal
			ZZK->ZZK_ERRO   := ::cErro
			
			ZZK->ZZK_DTALT  := DATE()
			ZZK->ZZK_HRALT  := TIME()
			ZZK->(msUnlock())
			ZZK->(dbSkip())
		enddo
	endif

return

method buscaItems(_cFil,_cNumPc) class classIntPcCompras
Local cHtmlIt := ''
Local nAnoAtu :=  YEAR(DATE())
Local nAnoPass :=  YEAR(DATE()) - 1


	cAliasAx := getNextAlias()

	BeginSQL Alias cAliasAx
		SELECT C7_FILIAL,C7_NUM,C7_ITEM,C1_ORIGEM,C7_PRODUTO,C7_XGARANT,C7_CC,C7_CONTA,CT1_DESC01,CTT_DESC01,C7_PRAZO,C7_DATPRF,C7_QUANT,C7_LOCAL,
		C7_XDESCGA,C7_XTMPGAR,C7_MOEDA,C7_EMISSAO,C7_TXMOEDA,C7_VALEMB,C7_VLDESC,C7_PRECO,C7_VALFRE,C7_NUMSC,C7_ITEMSC,C1_SOLICIT,C1_XSALES,C1_REQUISI,
		C7_XCAPEX,C7_ITEMCTA, CTD_DESC01,C7_VALIPI,C7_VALSOL,C7_TOTAL,C7_NUMCOT,C7_FORNECE,C7_LOJA,C1_USER,C7_RESIDUO,C7_DESPESA,C1_XNOMREQ,
		ISNULL((SELECT SUM(D3_QUANT) FROM %Table:SD3% SD3 WHERE D3_COD = C7_PRODUTO AND SD3.%NotDel%  AND SUBSTRING(D3_EMISSAO,1,4) = %EXP:ALLTRIM(STR(nAnoAtu))% AND D3_TM > '499' AND D3_TM < '999' ),'') ANOATU,
		ISNULL((SELECT SUM(D3_QUANT) FROM %Table:SD3% SD3 WHERE D3_COD = C7_PRODUTO AND SD3.%NotDel%  AND SUBSTRING(D3_EMISSAO,1,4) = %EXP:ALLTRIM(STR(nAnoPass))% AND D3_TM > '499' AND D3_TM < '999' ),'') ANOPASS
		
		FROM %TABLE:SC7% SC7
		LEFT JOIN %TABLE:SC1% SC1 ON C1_FILIAL = C7_FILIAL AND C1_NUM= C7_NUMSC AND C1_ITEM = C7_ITEMSC and SC1.%NotDel% 
		LEFT JOIN %TABLE:CTT% CTT ON CTT_CUSTO = C7_CC and CTT.%NotDel% 
		LEFT JOIN %TABLE:CT1% CT1 ON CT1_CONTA = C7_CONTA AND CT1.%NotDel% 
		LEFT JOIN %TABLE:CTD% CTD ON CTD_FILIAL = C7_FILIAL AND CTD_ITEM = C7_ITEMCTA AND CTD.%NotDel% 
		WHERE SC7.%NotDel%  AND C7_FILIAL = %EXP:_cFil%  AND C7_NUM = %EXP:_cNumPc% 
		ORDER BY C7_NUM,C7_ITEM


	EndSQL
	
	::nTotTax  := 0
	::nTotPed  := 0
	::nTotFret := 0
	::nTotDisc := 0
	::nTotProd := 0
//
	IF !(cAliasAx)->(Eof())
	
		WHILE !(cAliasAx)->(Eof())
			
			IF(EMPTY(cHtmlIt))
				cHtmlIt += '"Items": ['
			ELSE
				cHtmlIt += ','
			ENDIF
			
			_nPreco := (((cAliasAx)->C7_PRECO + ((cAliasAx)->C7_VALEMB/(cAliasAx)->C7_QUANT)))
			IF (cAliasAx)->C7_MOEDA != 1
				_nPreco := XMOEDA(_nPreco,(cAliasAx)->C7_MOEDA,1,STOD((cAliasAx)->C7_EMISSAO),2,(cAliasAx)->C7_TXMOEDA)
			ENDIF
			
			_cPerc   := 0
			_nValImp := 0
			
			IF !EMPTY((cAliasAx)->C7_NUMCOT)
				_cPerc := posicione("SC8",3,(cAliasAx)->C7_FILIAL+(cAliasAx)->C7_NUMCOT+(cAliasAx)->C7_PRODUTO+(cAliasAx)->C7_FORNECE+(cAliasAx)->C7_LOJA,"C8_IMPPREV")
				_nValImp := _nPreco * (_cPerc/100)
			ENDIF
			
			::cChvAnx  += ",'SC1"+(cAliasAx)->C7_FILIAL+(cAliasAx)->C7_NUMSC+(cAliasAx)->C7_ITEMSC + "'"
			
			::cChvAnx  += ",'SC7"+(cAliasAx)->C7_FILIAL+ (cAliasAx)->C7_NUM+(cAliasAx)->C7_ITEM + "'"
			
			dbSelectArea('SB1')
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial('SB1')+(cAliasAx)->C7_PRODUTO))
			
			dbSelectArea("SB2")
			//Consult sempre do armazem 01, pois í© o armazem de estoque ativo.
			SB2->(dbSeek(xFilial("SB2") +(cAliasAx)->C7_PRODUTO +'01'))
			nSaldo := SaldoSb2()
			
			cHtmlIt += ' {  '
			
			cHtmlIt += ' "Item": "'+(cAliasAx)->C7_ITEM+'", '
			cHtmlIt += ' "Product": "'+SB1->B1_COD+ ::CARACESP(SB1->B1_DESC)+'", '
			cHtmlIt += ' "StockReplenishment": "'+IF(ALLTRIM((cAliasAx)->C1_ORIGEM) == 'MATA170','YES','No')+'", '
			cHtmlIt += ' "StockBalance": "'+::tratNum(nSaldo)+'", '
			cHtmlIt += ' "StockMinimum": "'+::tratNum(SB1->B1_EMIN)+'", '
			cHtmlIt += ' "CostCenter": "'+::CARACESP(ALLTRIM((cAliasAx)->C7_CC)+'-'+(cAliasAx)->CTT_DESC01)+'", '
			cHtmlIt += ' "Accounting": "'+::CARACESP(ALLTRIM((cAliasAx)->C7_CONTA)+'-'+(cAliasAx)->CT1_DESC01)+'", '
			cHtmlIt += ' "Warranty": "'+IF((cAliasAx)->C7_XGARANT=='1','Yes','No')+'", '
			cHtmlIt += ' "WarrantyTime": "'+ALLTRIM(STR((cAliasAx)->C7_XTMPGAR))+ IF((cAliasAx)->C7_XDESCGA=='1',' Days',IF((cAliasAx)->C7_XDESCGA=='2',' Months',IF((cAliasAx)->C7_XDESCGA=='3',' Years','')))+'", '
			cHtmlIt += ' "DeliveryDate": "'+DTOC(STOD((cAliasAx)->C7_DATPRF))+'", '
			cHtmlIt += ' "Quantity": "'+::tratNum((cAliasAx)->C7_QUANT)+'", '
			cHtmlIt += ' "UnitaryValue": "'+::tratNum(_nPreco)+'", '
			cHtmlIt += ' "ImportValue": "'+::tratNum(_nValImp)+'", '
			cHtmlIt += ' "TotalLastYear": "'+::tratNum((cAliasAx)->ANOPASS)+'", '
			cHtmlIt += ' "TotalCurrentYear": "'+::tratNum((cAliasAx)->ANOATU)+'", '
			
			IF !EMPTY((cAliasAx)->C1_XNOMREQ)
				_cUsuReq := (cAliasAx)->C1_XNOMREQ
			ELSE
				_cUsuReq := ::fGetUsrName((cAliasAx)->C1_USER)
				_cUsuReq := if(!empty((cAliasAx)->C1_USER) .AND. !EMPTY(_cUsuReq),_cUsuReq,if(!empty((cAliasAx)->C1_SOLICIT),(cAliasAx)->C1_SOLICIT,(cAliasAx)->C1_REQUISI))
			ENDIF

			cHtmlIt += ' "Requester": "'+ALLTRIM(_cUsuReq)+'", '

			_cUsrReq := ''
			_cReqMail := ''
			if !EMPTY((cAliasAx)->C1_SOLICIT) .AND. AT( ' ', ALLTRIM((cAliasAx)->C1_SOLICIT) )==0 //Adicionada essa validação, para não trazer nomes que eram gravados erroneamente nesse campo, trazer apenas quando for usuário
				_cUsrReq := (cAliasAx)->C1_SOLICIT

				PswOrder(2)
				If  PswSeek(_cUsrReq ,.T.) //Se usuário encontrado
					aGrupos := Pswret(1)  
					_cReqMail := AllTrim(aGrupos[1][14])
				endif
			ELSE
				if !empty((cAliasAx)->C1_USER)
					_cCodUs := (cAliasAx)->C1_USER
				else
					//Era gravado assim antigamente (errado). Apartir de hj, solicitações novas sempre vão cair no primeiro if
					_cCodUs := (cAliasAx)->C1_REQUISI
				endif

				PswOrder(1)
				If  PswSeek(_cCodUs ,.T.) //Se usuário encontrado
					aGrupos := Pswret(1)  
					_cUsrReq := AllTrim(aGrupos[1][2])
					_cReqMail := AllTrim(aGrupos[1][14])
				endif
			endif

			cHtmlIt += ' "RequesterUser": "'+::CARACESP(ALLTRIM(_cUsrReq))+'", '
			cHtmlIt += ' "RequesterEmail": "'+ALLTRIM(_cReqMail)+'", '
			cHtmlIt += ' "Excluido": '+if((cAliasAx)->C7_RESIDUO=='S','true','false')+', '
			 
			cHtmlIt += ' "IdPurchaseRequest": "'+(cAliasAx)->C1_XSALES+'", ' 
			cHtmlIt += ' "CostAllocation": "'+IF((cAliasAx)->C7_XCAPEX=='1','Capex','Opex')+'", ' 
			cHtmlIt += ' "ItemContabil": "'+::CARACESP(ALLTRIM((cAliasAx)->C7_ITEMCTA)+'-'+ALLTRIM((cAliasAx)->CTD_DESC01))+'" ' 

			cHtmlIt += ' 				}'
			
			//Totais
			::nTotProd += _nPreco * (cAliasAx)->C7_QUANT
			::nTotTax  += (cAliasAx)->C7_VALIPI + (cAliasAx)->C7_VALSOL  + (cAliasAx)->C7_DESPESA
			::nTotPed  += (cAliasAx)->C7_TOTAL + (cAliasAx)->C7_VALEMB +(cAliasAx)->C7_VALIPI + (cAliasAx)->C7_VALSOL   + (cAliasAx)->C7_DESPESA + (cAliasAx)->C7_VALFRE - (cAliasAx)->C7_VLDESC + _nValImp
			::nTotFret += (cAliasAx)->C7_VALFRE
			::nTotDisc += (cAliasAx)->C7_VLDESC
			
			(cAliasAx)->(DbSkip())
		ENDDO

		cHtmlIt += '],'
	ELSE
		cHtmlIt += '"Items": ['
		cHtmlIt += '],'
	ENDIF

	(cAliasAx)->(dbCloseArea())

return cHtmlIt

method buscaPagtos(_cFil,_cNumContra,cNumFor,cNumLoj) class classIntPcCompras
Local cHtmlTmp := ''

	cAliasAx := getNextAlias()

	BeginSQL Alias cAliasAx
		SELECT E2_BAIXA, E2_VALOR+E2_INSS+E2_IRRF+E2_ISS+E2_PIS+E2_COFINS+E2_CSLL-E2_SALDO AS VLBAIXA, E2_EMISSAO, E2_VENCREA,E2_NUM,E2_HIST, E2_FORNECE, E2_NOMFOR
	   FROM %TABLE:SE2% SE2
	   LEFT JOIN %TABLE:SD1% SD1 ON D1_FILIAL = E2_FILIAL AND E2_NUM = D1_DOC AND E2_PREFIXO = D1_SERIE AND E2_FORNECE = D1_FORNECE AND E2_LOJA = D1_LOJA AND SD1.%NotDel%
	   LEFT JOIN %TABLE:SC7% SC7 ON C7_FILIAL = D1_FILIAL AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC AND SC7.%NotDel%
	   WHERE SE2.%NotDel% AND E2_BAIXA != ' ' AND E2_VALOR != E2_SALDO AND  (( C7_CONTRA = %EXP:_cNumContra%  
	   AND  E2_TIPO ='NF ' AND E2_ORIGEM = 'MATA100 ') OR (E2_XCONTRA = %EXP:_cNumContra% AND E2_FORNECE= %EXP:cNumFor% AND E2_LOJA = %EXP:cNumLoj%  ) )
	   ORDER BY E2_BAIXA DESC

	   OFFSET 0 ROWS FETCH NEXT 36 ROWS ONLY 

	EndSQL

	IF !(cAliasAx)->(Eof())

		WHILE !(cAliasAx)->(Eof())
			
			IF(EMPTY(cHtmlTmp))
				cHtmlTmp += '"Payments": ['
			ELSE
				cHtmlTmp += ','
			ENDIF
			
			cHtmlTmp += ' {  '
			
			cHtmlTmp += ' "RegisterDate": "'+DTOC(STOD((cAliasAx)->E2_EMISSAO))+'", '
			cHtmlTmp += ' "Provider": "'+(cAliasAx)->E2_FORNECE+' - '+(cAliasAx)->E2_NOMFOR+'", '
			cHtmlTmp += ' "Description": "'+::CARACESP((cAliasAx)->E2_HIST )+'", '
			cHtmlTmp += ' "PaymentNumber": "'+ (cAliasAx)->E2_NUM+'", '
			cHtmlTmp += ' "PaymentDate": "'+DTOC(STOD((cAliasAx)->E2_BAIXA))+'", '
			cHtmlTmp += ' "Value": "'+ ::tratNum((cAliasAx)->VLBAIXA)+'" ' 

			cHtmlTmp += ' 				}'

			(cAliasAx)->(DbSkip())
		ENDDO

		//Fecha a cotacoes
		cHtmlTmp += '],'

	ENDIF

	(cAliasAx)->(dbCloseArea())

return cHtmlTmp

method buscaCot(_cFil,_cNum) class ClassIntPcCompras
	Local cHtmlCot := ''
	Local cUltCot := ''	
	Local cMsgInc := "Supplier sent an incomplete quotation (doesnt have all needed products and/or services)"			
	cAliasAx := getNextAlias()
			
	BeginSQL Alias cAliasAx
		SELECT C8_NUM,C8_FORNECE,C8_LOJA,SUM(C8_TOTAL) as C8_TOTAL, SUM(C8_VALIPI) AS VALIPI,
		MIN(C8_TOTAL) as MINVAL,C8_EMISSAO,
		 A2_NREDUZ,C8_NUMPED,C8_MOEDA,SUM(C8_DESC1) AS VALDESC,SUM(C8_VALFRE) AS VALFRE
		FROM %TABLE:SC7% SC7
		INNER JOIN %TABLE:SC8% SC8 ON C8_FILIAL = C7_FILIAL AND C7_NUMSC = C8_NUMSC AND C7_ITEMSC = C8_ITEMSC AND SC8.%NotDel% 
		INNER JOIN %TABLE:SA2% SA2 ON A2_COD = C8_FORNECE AND A2_LOJA = C8_LOJA and SA2.%NotDel% 
		WHERE SC7.%NotDel% AND C7_FILIAL = %EXP:_cFil%  AND C7_NUM = %EXP:_cNum% AND C8_NUMPED != C7_NUM
		GROUP BY C8_NUM,C8_FORNECE,C8_LOJA,A2_NREDUZ,C8_NUMPED,C8_MOEDA,C8_EMISSAO
		ORDER BY C8_NUM,C8_FORNECE


	EndSQL

	IF !(cAliasAx)->(Eof())

		WHILE !(cAliasAx)->(Eof())
			
			IF(EMPTY(cHtmlCot))
				cHtmlCot += '"Quotes": ['
			ELSE
				cHtmlCot += ','
			ENDIF
			
			cHtmlCot += ' {  '
			cHtmlCot += ' "Provider": "'+(cAliasAx)->C8_FORNECE+' '+(cAliasAx)->A2_NREDUZ+if( (cAliasAx)->C8_MOEDA > 1 ,"(Estimated Values - Import)","")+'", '
			cHtmlCot += ' "Notes": "'+IF((cAliasAx)->MINVAL==0,::CARACESP(cMsgInc),'')+'", '
			cHtmlCot += ' "Taxes": "'+::TRATNUM((cAliasAx)->VALIPI)+'", '
			_nVal := (cAliasAx)->C8_TOTAL
			_nValTot :=  (cAliasAx)->C8_TOTAL+(cAliasAx)->VALFRE-(cAliasAx)->VALDESC+(cAliasAx)->VALIPI
			
			if (cAliasAx)->C8_MOEDA != 1
				_nVal := XMOEDA(_nVal, (cAliasAx)->C8_MOEDA,1,STOD((cAliasAx)->C8_EMISSAO))
				_nValTot := XMOEDA(_nValTot, (cAliasAx)->C8_MOEDA,1,STOD((cAliasAx)->C8_EMISSAO))
			endif
			
			cHtmlCot += ' "UnitValue": "'+::TRATNUM(_nVal)+'",'	
			cHtmlCot += ' "Total": "'+::TRATNUM(_nValTot)+'"'	

			cHtmlCot += ' 				}'

			(cAliasAx)->(DbSkip())
		ENDDO

		//Fecha a cotacoes
		cHtmlCot += '],'

	ENDIF


	(cAliasAx)->(dbCloseArea())

return cHtmlCot


method buscaRateios(_cFil,cNumPc,cNumCtr,cNumMd) class classIntPcCompras

Local cHtmlTmp := ''

	cAliasAx := getNextAlias()

	BeginSQL Alias cAliasAx
	
	
		SELECT * 	
		FROM %TABLE:Z21% Z21 
		INNER JOIN %TABLE:SED% SED ON ED_FILIAL =%EXP:xFilial("SED")% AND ED_CODIGO = Z21_NATURE AND SED.%NotDel%
		LEFT JOIN %TABLE:CTT% CTT ON CTT_CUSTO = Z21_CCUSTO and CTT.%NotDel% 
		LEFT JOIN %TABLE:CTD% CTD ON CTD_ITEM = Z21_ITEMCT AND CTD.%NotDel% 
		
		WHERE Z21.Z21_NUMMED = %EXP:cNumMd%
		AND Z21.Z21_FILIAL = %EXP:_cFil% AND Z21.Z21_CONTRA = %EXP:cNumCtr% AND Z21.%NotDel% 
				
	EndSQL

	IF !(cAliasAx)->(Eof())

		WHILE !(cAliasAx)->(Eof())
			
			IF(EMPTY(cHtmlTmp))
				cHtmlTmp += '"Apportionments": ['
			ELSE
				cHtmlTmp += ','
			ENDIF
				
			cHtmlTmp += ' {  '
			
			cHtmlTmp += ' "Classification": "'+(cAliasAx)->ED_DESCRIC+'", '
			cHtmlTmp += ' "Description": "'+::CARACESP((cAliasAx)->ED_DESCRIC)+'", '
			cHtmlTmp += ' "CostCenter": "'+::CARACESP((cAliasAx)->Z21_CCUSTO+'-'+(cAliasAx)->CTT_DESC01)+'", '
			cHtmlTmp += ' "Accounting": "'+::CARACESP( (cAliasAx)->Z21_ITEMCT+'-'+ (cAliasAx)->CTD_DESC01)+'", '
			cHtmlTmp += ' "Value": "'+ ::tratNum((cAliasAx)->Z21_VALOR)+'" ' 

			cHtmlTmp += ' 				}'

			(cAliasAx)->(DbSkip())
		ENDDO

		//Fecha a cotacoes
		cHtmlTmp += '],'

	ENDIF

	(cAliasAx)->(dbCloseArea())

return cHtmlTmp

method buscaAnexo() class classIntPcCompras

	Local cChvAn    := ::cChvAnx
	lOCAL cHtmlTmp  := ''
	
	
	cAliasAx := getNextAlias()

	cChvAn := '%' +cChvAn+ '%'	   

	BeginSQL Alias cAliasAx

		SELECT AC9_CODOBJ,AC9_ENTIDA,ACB_OBJETO
		FROM %TABLE:AC9% AC9
		INNER JOIN %TABLE:ACB% ACB ON ACB_FILIAL = AC9_FILIAL AND AC9_CODOBJ = ACB_CODOBJ
		WHERE AC9.%NotDel%  AND AC9_ENTIDA||AC9_CODENT IN (%EXP:cChvAn%)
		ORDER BY AC9_ENTIDA,AC9_CODENT

	EndSQL

	IF !(cAliasAx)->(Eof())

		WHILE !(cAliasAx)->(Eof())
			
			IF(EMPTY(cHtmlTmp))
				cHtmlTmp += '"Attachments": ['
			ELSE
				cHtmlTmp += ','
			ENDIF
			
			cHtmlTmp += ' {  '
			
			cHtmlTmp += ' "FileName": "'+ALLTRIM((cAliasAx)->ACB_OBJETO)+'", '
			cHtmlTmp += ' "FileCode": "'+(cAliasAx)->AC9_CODOBJ+'" '

			cHtmlTmp += ' 				}'

			(cAliasAx)->(DbSkip())
		ENDDO

		//Fecha a cotacoes
		cHtmlTmp += '],'

	ENDIF

	(cAliasAx)->(dbclosearea())

return cHtmlTmp


method reenviaSales() class ClassIntPcCompras

	cAliaAux2 := getNextAlias()

	BeginSQL Alias cAliaAux2
		SELECT DISTINCT(ZZK_FILIAL+ZZK_CODIGO+ZZK_NUMSC),ZZK_FILIAL,ZZK_CODIGO,ZZK_NUMSC
		FROM %TABLE:ZZK% ZZK
		INNER JOIN %TABLE:SC1% SC1 ON ZZK_NUMSC = C1_NUM AND ZZK_FILIAL = C1_FILIAL AND SC1.%NotDel%  
		WHERE ZZK.%NotDel%  AND ZZK_STATUS IN ('E','P')
		GROUP BY ZZK_FILIAL,ZZK_CODIGO,ZZK_NUMSC

	EndSQL

	WHILE !(cAliaAux2)->(Eof())
		IF !EMPTY((cAliaAux2)->ZZK_FILIAL)
			cFilAnt := (cAliaAux2)->ZZK_FILIAL
		ENDIF

		::cCodInt := ::PROXCODIGO()

		::cFilPc := (cAliaAux2)->ZZK_FILIAL
		::cNumPc := (cAliaAux2)->ZZK_NUMSC

		::gravaLogZZK('R')

		::enviaSales()

		dbSelectArea('ZZK')
		ZZK->( dbSetOrder(1) )

		IF ZZK->( dbSeek( (cAliaAux2)->ZZK_FILIAL + (cAliaAux2)->ZZK_CODIGO ) )

			while !	ZZK->(Eof()) .AND. ZZK->ZZK_FILIAL == (cAliaAux2)->ZZK_FILIAL .AND.  ALLTRIM(ZZK->ZZK_CODIGO) == (cAliaAux2)->ZZK_CODIGO

				RecLock("ZZK",.F.)
				ZZK->ZZK_STATUS := 'R'
				ZZK->(msUnlock())
				ZZK->(dbSkip())
			enddo
		endif

		(cAliaAux2)->(DbSkip())
	ENDDO
	(cAliaAux2)->(dbCloseArea())

return



method SIGLAMOEDA(cMoeda) class ClassIntPcCompras 
	Local cSigla := ''

	IF(cMoeda == 1)
		cSigla := 'R$'
	ELSEIF(cMoeda == 2)
		cSigla := '$'
	ELSEIF(cMoeda == 3)
		cSigla := 'UFIR'
	ELSEIF(cMoeda == 4)
		cSigla := '€'
	ELSEIF(cMoeda == 5)
		cSigla := 'ARS'
	ENDIF

return cSigla


method CARACESP(cString) class ClassIntPcCompras 

	Local _sRet := cString


	_sRet := StrTran (_sRet, "¹", "1")
	_sRet := StrTran (_sRet, "²", "2")
	_sRet := StrTran (_sRet, "³", "3")
	_sRet := StrTran (_sRet, "'", "")
	_sRet := StrTran (_sRet, "´", "")
	_sRet := StrTran (_sRet, '"', "")
	_sRet := StrTran (_sRet, "º", ".")
	_sRet := StrTran (_sRet, "ª", ".")
	_sRet := StrTran (_sRet, "&", "e")
	// _sRet := StrTran (_sRet, "|", "")
	 _sRet := StrTran (_sRet, "\", "|")
	// _sRet := StrTran (_sRet, "/", " ")
	// _sRet := StrTran (_sRet, "<", " ")
	// _sRet := StrTran (_sRet, ">", " ")
	_sRet := StrTran (_sRet, "ç", "c")
	_sRet := StrTran (_sRet, "Ç", "C")
	_sRet := StrTran (_sRet, chr (9), " ") // TAB
//	_sRet := StrTran (_sRet, chr (32), "") // TAB
	_sRet := StrTran (_sRet, Chr(13) + Chr(10), "<br/>") // TAB
	//Sí³ para garantir
	_sRet := noAcento (_sRet) 


Return ALLTRIM(_sRet)

method PROXCODIGO() class ClassIntPcCompras

	Local cNextCod := GETSX8NUM("ZZK","ZZK_CODIGO")

	dbSelectArea('ZZK')
	ZZK->( dbSetOrder(1) )
	IF ZZK->( dbSeek( xFilial("ZZK") + cNextCod ) )
		//Enquanto encontrar cí³digo, pega um novo. Atí© q encontre 1 q não existe
		while ZZK->( dbSeek( xFilial("ZZK") +  cNextCod ) )
			cNextCod  := GETSX8NUM("ZZK","ZZK_CODIGO")
		enddo
	endif

	ConfirmSX8()

return cNextCod


method PROXALCA() class ClassIntPcCompras

	Local cNextCod := GETSX8NUM("SAL","AL_COD")

	dbSelectArea('SAL')
	SAL->( dbSetOrder(1) )
	IF SAL->( dbSeek( xFilial("SAL") + cNextCod ) )
		//Enquanto encontrar cí³digo, pega um novo. Atí© q encontre 1 q não existe
		while SAL->( dbSeek( xFilial("SAL") +  cNextCod ) )
			cNextCod  := GETSX8NUM("SAL","AL_COD")
		enddo
	endif

	ConfirmSX8()

return cNextCod

method PROXAPR() class ClassIntPcCompras

	Local cNextCod := GETSX8NUM("SAK","AK_COD")

	dbSelectArea('SAK')
	SAK->( dbSetOrder(1) )
	IF SAK->( dbSeek( xFilial("SAK") + cNextCod ) )
		//Enquanto encontrar cí³digo, pega um novo. Atí© q encontre 1 q não existe
		while SAK->( dbSeek( xFilial("SAK") +  cNextCod ) )
			cNextCod  := GETSX8NUM("SAK","AK_COD")
		enddo
	endif

	ConfirmSX8()

return cNextCod



method pedVenc(_cNumCot,_cNumPd,cCodPro) class ClassIntPcCompras

	Local cPedVenc := ''

	IF(!EMPTY(_cNumPd))
		IF(_cNumPd != 'XXXXXX')
			cPedVenc := _cNumPd
		ELSE

			_cAliaAux := getNextAlias()

			BeginSQL Alias _cAliaAux
				SELECT C7_NUM
				FROM %TABLE:SC7% SC7
				WHERE SC7.%NotDel%  AND C7_NUMCOT = %EXP:_cNumCot% AND C7_PRODUTO = %EXP:cCodPro%

			EndSQL

			IF !(_cAliaAux)->(Eof())
				cPedVenc := (_cAliaAux)->C7_NUM
			ENDIF

			(_cAliaAux)->(dbCloseArea())

		ENDIF
	ENDIF

return cPedVenc

method RetNomFunc(cCodigo) class ClassIntPcCompras
	_cNomUsu := ''

	IF(!EMPTY(cCodigo))
		_aRetUsu := FWSFALLUSERS({cCodigo})
		if(LEN(_aRetUsu) >= 1 .AND. LEN(_aRetUsu[1]) >= 4)
			_cNomUsu := ALLTRIM(_aRetUsu[1,4])
		ENDIF
	endif

return _cNomUsu


method vincAlcada(aAprova) class ClassIntPcCompras
	Local _nInd := 1
	Local cCod
	Local oObjTmp := NIL
	Local lRet := .T.
	
	Local nCntNvl := 0
	
	for _nInd := 1 to LEN(aAprova)
		oObjTmp := aAprova[_nInd]
		PswOrder(2)
		
		if oObjTmp:Status != 'Started'
			
			if oObjTmp:Nivel == 0	
				::cErro := 'Nivel de aprovador inválido. Ní­vel 0'
				::cSugestao := 'Entre em contato com o suporte.'
				lRet := .F.
			else
				aCodApr := {}
				aCodApr := ::vincUsuario(oObjTmp:Usuario,oObjTmp:Nome)

				If len(aCodApr) > 0 
				    nCntNvl++                 
	//				cCodApr := ::vincUsuario(oObjTmp:Usuario,aDados[1][1],aDados[1][2])
					
					::vincGrupo(::cGrpSales,aCodApr,nCntNvl,oObjTmp:Nivel)
					
				ELSE
					::cErro := 'Usuário não cadastrado como aprovador no Protheus. Usuário: '+if(valTYPE(oObjTmp:Usuario) == 'C',oObjTmp:Usuario,'')+' .'
					::cSugestao := 'Entre em contato com o suporte.'
					lRet := .F.
				endif
			endif
		endif
	next
	
	
return lRet

method criaAlcada() class ClassIntPcCompras
Local lRet := .T.

MaAlcDoc({  ::cNumPed,;
            "PC",;
            ::nTotPed,;
            ,;
            ,;
            ::cGrpProt,;
            ,;
            SC7->C7_MOEDA,;
            ,;
            SC7->C7_EMISSAO,;
            ""},;
            SC7->C7_EMISSAO,;
            1)



dbSelectArea('SCR')
SCR->( dbSetOrder(1) )
if !SCR->(dbSeek(xFilial("SCR")+"PC"+PADR(::cNumPed,TamSx3("CR_NUM")[1])))
	lRet := .F.
ENDIF

return lRet
 
METHOD vincUsuario(_cLogin,_cNome) class ClassIntPcCompras
	Local aCodApr := {}
	Local _cAliaAk := getNextAlias()

	BeginSQL Alias _cAliaAk
		SELECT AK_COD,AK_USER
		FROM %TABLE:SAK% SAK
		WHERE SAK.%NotDel%  AND AK_XSALES = %EXP:_cLogin% 

	EndSQL

	IF !(_cAliaAk)->(Eof())
		
		aadd(aCodApr,{(_cAliaAk)->AK_COD,(_cAliaAk)->AK_USER})
		
	ELSE
	
		PswOrder(2)
		
		If  PswSeek(_cLogin,.T.) 
			
			aGrupos := Pswret(1)  
			
			_cCodAk :=  ::PROXAPR()
			
			RecLock("SAK",.T.)
			
			SAK->AK_XSALES  := _cLogin
			SAK->AK_FILIAL  := xFilial("SAK")
			SAK->AK_COD	    := _cCodAk
			SAK->AK_USER    := aGrupos[1][1]
			SAK->AK_NOME    := _cNome
			SAK->AK_LIMMIN  := 0.01
			SAK->AK_LIMMAX  := 999999999.99
			SAK->AK_MOEDA   := 1
			SAK->AK_LIMITE  := 999999999.99
			SAK->AK_TIPO    := 'D'
			SAK->AK_LIMPED  := 0
			SAK->AK_LOGIN   := aGrupos[1][2]
		
			SAL->(msUnlock())
			
			aadd(aCodApr,{SAK->AK_COD,SAK->AK_USER})
			
		ENDIF
	ENDIF	
	
	(_cAliaAk)->(dbCloseArea())
	
return aCodApr

METHOD vincGrupo(cGrupo,aCodApr,nInd,nNivel) class ClassIntPcCompras
	lOCAL cGrpProt
	Local _cAliaGrp := getNextAlias()

	BeginSQL Alias _cAliaGrp
		SELECT AL_COD
		FROM %TABLE:SAL% SAL
		WHERE SAL.%NotDel%  AND AL_XSALES = %EXP:cGrupo% AND AL_USER = %EXP:aCodApr[1,2]%

	EndSQL

	IF !(_cAliaGrp)->(Eof())
		::cGrpProt := (_cAliaGrp)->AL_COD
	ELSE
		IF EMPTY(::cCodAl)
			::cCodAl := ::PROXALCA() 
		ENDIF
		
		RecLock("SAL",.T.)
		SAL->AL_XSALES  := cGrupo
		SAL->AL_FILIAL := xFilial('SAL')
		SAL->AL_COD    := ::cCodAl
		SAL->AL_DESC   := cGrupo
		SAL->AL_ITEM   := PadL(AllTrim(STR(nInd)), 2, "0")
		SAL->AL_APROV  := aCodApr[1,1]
		SAL->AL_USER   := aCodApr[1,2]
		SAL->AL_NIVEL  := PadL(AllTrim(STR(nNivel)), 2, "0") 
		SAL->AL_LIBAPR := 'A'
		SAL->AL_AUTOLIM:= 'S' 
		SAL->AL_TPLIBER:= 'U'
		SAL->AL_PERFIL := '1'
		SAL->AL_MSBLQL := '2'
		SAL->AL_DOCPC  := .T.
		SAL->(msUnlock())
		
		::cGrpProt := SAL->AL_COD
		
	ENDIF

	(_cAliaGrp)->(dbCloseArea())
	
return

METHOD atuCodPed(cCodSal) class ClassIntPcCompras
 	Local lRet := .t.
 
  //cria o update para atualizar todos os registros processados em um unico comando
    cUpdate := " UPDATE " + retsqlname("SC7") + " "  
	
    cUpdate += " set C7_APROV = '"+::cGrpProt+"', " 
	if cCodSal != nil
    	cUpdate += " C7_XSALES = '"+cCodSal+"', "
	endif
	if ::cGrpSales != 'CANCELAR'
    	cUpdate += "  C7_XGRPSAL = '"+::cGrpSales+"', "
	ENDIF
    cUpdate += "  C7_CONAPRO = 'B' "
    cUpdate += " where C7_FILIAL = '" + ::cFilPc + "' "
    cUpdate += "   AND C7_NUM = '" + ::cNumPc + "' "
	cUpdate += "   AND D_E_L_E_T_ <> '*' "
    
    nUpdate := TcSqlExec(cUpdate)
	
    if (nUpdate < 0)
    	::cErro := 'Erro ao atualizar o pedido de compras. '+TCSQLError()
		::cSugestao := 'Entre em contato com o suporte.'
		lRet := .F.
	endif
   
	
return lRet


method fGetUsrName(cUserID)  class ClassIntPcCompras
Return(AllTrim(UsrFullName(cUserID)))
