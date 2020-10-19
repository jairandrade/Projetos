#include 'protheus.ch'

/*/{Protheus.doc} ClassIntCompras
(long_description)
@author    Eduardo
@since     28/05/2019
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
class ClassIntCompras 

	method new() constructor 
	method gravaLogZZK()  
	method registraIntegracao()  
	Method buscaSolic()
	Method carregaDados()
	method enviaPost()
	method atuLog()
	method enviaSales()
	method buscaItem()
	method buscaCot()
	method buscaPed()
	method buscaAprov()
	method SIGLAMOEDA()
	method CARACESP()
	method PROXCODIGO()
	method RetNomFunc()
	method reenviaSales()
	method buscaCiclos()
	method pedVenc()
	Data cCorpoPost
	data cNumSolics
	data cCodInt
	data cFilSc
	data cNumSc
	data cItmSc
	data lIntegra
	data cErroInt
	data cOper
//	data cNumSales
//	data cNumCot
//	data cItemCot
//	data cNumPc
//	data cItemPc
//	data cNumDoc
//	data cSerie
//	data dEmissSc
//	data dEmissCt
//	data dEmissNf
//	data dPgto
	data cErro
	data cStatAprov
	data cStatScr
	data primNivel
	data primUser
	data ultAprov
	data aCodInt
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
method new() class ClassIntCompras
	::cCorpoPost := ''
	::lIntegra := GETMV( 'TCP_SCSFOR' ) 
	::cNumSc   := ''
	::cItmSc   := ''
	::cOper    := ''
	::cErro    := ''
	::cErroInt := ''
	::aCodInt  := {}
return

/*/{Protheus.doc} registraIntegracao
(metodo responsavel pelo controle da integraï¿½ï¿½o. Grava o registro da integraï¿½ï¿½o))
@author    Eduardo
@since     28/05/2019
@version   ${version}
@param cTipo, Character, Indica qual entidade estï¿½ sendo movimentada 1=IncCot
@example
(examples)
@see (links_or_references)
/*/
method registraIntegracao(_cTipo,_cCod,_cOper) class ClassIntCompras
	
	Local lRet := .T.
	::cOper  := _cOper
	//C1_NUM+C1_ITEM,C1_NUM+C1_ITEM...
	::cNumSolics := ''
	IF ::lIntegra
		IF ! ::buscaSolic(_cTipo,_cCod,_cOper)
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
method enviaSales() class ClassIntCompras
	Local nInd
	IF !EMPTY(::cCodInt)
		if LEN(::aCodInt) == 0
			AADD(::aCodInt,::cCodInt)
		ENDIF
		
		for nInd := 1 to LEN(::aCodInt)
			
			::cCodInt := ::aCodInt[nInd]
			
			::carregaDados()
			if !empty(::cCorpoPost)
				::enviaPost()
			endif
		NEXT
	else
		::cErro := 'Nenhum código de integração para integrar.'
		RETURN .F.
	ENDIF
return .T.
/*/{Protheus.doc} gravaLog
(long_description)
@author    Eduardo
@since     28/05/2019
@version   ${version}
@param cNumSc, Character, ${param_descr}
@example
(examples)
@see (links_or_references)
/*/
method gravaLogZZK() class ClassIntCompras

	if empty(::cNumSc)
		::cErro := 'Informe o número e o item da SC.'
		return .F.
	ENDIF
	
	RecLock("ZZK",.T.)
			
	ZZK->ZZK_CODIGO  := ::cCodInt
	ZZK->ZZK_FILIAL  := ::cFilSc
	ZZK->ZZK_NUMSC   := ::cNumSc
	ZZK->ZZK_DATA    := DATE()
	ZZK->ZZK_HORA    := TIME()
	ZZK->ZZK_STATUS  := 'P'

	ZZK->(msUnlock())
return .T.

method buscaSolic(_cTipo,_cChave,_cOper) class ClassIntCompras

Local cAlias
Local lRet := .T.
Local cWhere := '%%'
cAlias := getNextAlias()

DO CASE
 	CASE _cTipo == '1'
	
		BeginSQL Alias cAlias
		
			SELECT C8_FILIAL as FILIAL,C8_NUMSC AS NUMSC
			FROM %TABLE:SC8% SC8
			INNER JOIN %TABLE:SC1% SC1 ON C1_NUM = C8_NUMSC AND C1_ITEM = C8_ITEMSC AND SC1.%NotDel% 
			WHERE SC8.%NotDel% AND C8_FILIAL || C8_NUM = %EXP:_cChave%  AND C1_XSALES != ' '
			GROUP BY C8_FILIAL ,C8_NUMSC 
		
		EndSQL
	
	CASE _cTipo == '2'
  
	  	IF _cOper != 'E'
	  		cWhere := "% AND SC7.D_E_L_E_T_ =' ' %"
	  	ENDIF
	  	
	  	BeginSQL Alias cAlias
		
			SELECT C7_FILIAL as FILIAL,C7_NUMSC AS NUMSC
			FROM %TABLE:SC7% SC7
			INNER JOIN %TABLE:SC1% SC1 ON C1_NUM = C7_NUMSC AND C1_ITEM = C7_ITEMSC AND SC1.%NotDel% 
			WHERE C7_FILIAL || C7_NUM = %EXP:_cChave% AND C1_XSALES != ' ' %EXP:cWhere%
			GROUP BY C7_FILIAL ,C7_NUMSC 
		
		EndSQL
	
	CASE _cTipo == '3'
  
	  	IF _cOper != 'E'
	  		cWhere := "% AND SD1.D_E_L_E_T_ =' ' %"
	  	ENDIF
	  	
	  	BeginSQL Alias cAlias
		
			SELECT C1_FILIAL as FILIAL,C1_NUM AS NUMSC
			FROM %TABLE:SD1% SD1
			INNER JOIN %TABLE:SC7% SC7 ON D1_PEDIDO = C7_NUM AND D1_ITEMPC = C7_ITEM AND SC7.%NotDel%
			INNER JOIN %TABLE:SC1% SC1 ON C1_NUM = C7_NUMSC AND C1_ITEM = C7_ITEMSC AND SC1.%NotDel% 
			WHERE D1_FILIAL||D1_DOC||D1_SERIE||D1_FORNECE||D1_LOJA||D1_TIPO = %EXP:_cChave% AND C1_XSALES != ' ' %EXP:cWhere%
			GROUP BY C1_FILIAL ,C1_NUM ,C1_ITEM 
		
		EndSQL
	CASE _cTipo == '4'
  
	  	IF _cOper != 'E'
	  		cWhere := "% AND SE2.D_E_L_E_T_ =' ' %"
	  	ENDIF
	  	
	  	BeginSQL Alias cAlias
		
			SELECT C1_FILIAL as FILIAL,C1_NUM AS NUMSC
			FROM %TABLE:SE2% SE2
			INNER JOIN %TABLE:SD1% SD1 ON D1_FILIAL = E2_FILIAL AND E2_NUM = D1_DOC AND E2_PREFIXO = D1_SERIE AND E2_FORNECE = D1_FORNECE AND E2_LOJA = D1_LOJA AND SD1.%NotDel%
			INNER JOIN %TABLE:SC7% SC7 ON D1_PEDIDO = C7_NUM AND D1_ITEMPC = C7_ITEM AND SC7.%NotDel%
			INNER JOIN %TABLE:SC1% SC1 ON C1_NUM = C7_NUMSC AND C1_ITEM = C7_ITEMSC AND SC1.%NotDel% 
			WHERE E2_FILIAL||E2_PREFIXO||E2_NUM||E2_PARCELA||E2_TIPO||E2_FORNECE||E2_LOJA = %EXP:_cChave% AND C1_XSALES != ' ' %EXP:cWhere%
			GROUP BY C1_FILIAL ,C1_NUM 
		
		EndSQL
		
	CASE _cTipo == '5'
	
		BeginSQL Alias cAlias
		
			SELECT C1_FILIAL as FILIAL,C1_NUM AS NUMSC
			FROM %TABLE:SC1% SC1
			WHERE SC1.%NotDel% AND C1_FILIAL || C1_NUM = %EXP:_cChave%  AND C1_XSALES != ' ' 
			GROUP BY C1_FILIAL ,C1_NUM
		
		EndSQL
		
	CASE _cTipo == '6'
  
	  	IF _cOper != 'E'
	  		cWhere := "% AND SC1.D_E_L_E_T_ =' ' %"
	  	ENDIF
	  	
		
		BeginSQL Alias cAlias
		
			SELECT C1_FILIAL as FILIAL,C1_NUM AS NUMSC
			FROM %TABLE:SC1% SC1
			WHERE C1_FILIAL || C1_NUM = %EXP:_cChave%  AND C1_XSALES != ' ' %EXP:cWhere%
			GROUP BY C1_FILIAL ,C1_NUM
		
		EndSQL
		
  OTHERWISE
     ::cErro := 'Etapa inválida.'
     lRet := .F.
     
     
     
ENDCASE

if lRet
	if !(cAlias)->(Eof())      
		while !(cAlias)->(Eof())
				
			::cFilSc := (cAlias)->FILIAL
			::cNumSc := (cAlias)->NUMSC
	//		::cItmSc := (cAlias)->ITEMSC
			
			::cCodInt := ::PROXCODIGO()
			aadd(::aCodInt,::cCodInt)	
			::gravaLogZZK()
					
			(cAlias)->(dbSkip())
		enddo
		 
//		ConfirmSX8()
	else
		lRet := .F.
	endif
else
	::cCodInt := ''
//	RollBackSX8()
endif

(cAlias)->(dbCloseArea())  

return lRet

method carregaDados() class ClassIntCompras
	Local _cCod := ''
	Local cUltPed
	Local cWreDel := '%'
	//Indica se eliminou rersíduo de todos os itens
	private lResTot := .f. 
	
	if ::cOper != 'E'
		cWreDel += " AND SC1.D_E_L_E_T_ =' ' "
	ENDIF

	cWreDel += '%'

	_cCod := ::cCodInt
	_cFilSc := ::cFilSc
	::cCorpoPost := ''
	
	cAlias := getNextAlias()
	
	BeginSQL Alias cAlias
	
		SELECT C1_FILIAL,C1_NUM,C1_XSALES, SC1.D_E_L_E_T_ AS SC1DEL,C1_RESIDUO
		FROM %TABLE:ZZK% ZZK
		LEFT JOIN %TABLE:SC1% SC1 ON C1_NUM = ZZK_NUMSC AND C1_FILIAL = ZZK_FILIAL %EXP:cWreDel%
	//	LEFT JOIN %TABLE:SC8% SC8 ON C8_NUMSC = C1_NUM AND C8_ITEMSC = C1_ITEM AND SC8.%NotDel%
		LEFT JOIN %TABLE:SC7% SC7 ON C1_FILIAL= C7_FILIAL AND C7_NUMSC = C1_NUM AND C7_ITEMSC = C1_ITEM AND SC7.%NotDel%
//		LEFT JOIN %TABLE:SD1% SD1 ON D1_PEDIDO = C7_NUM AND D1_ITEMPC = C7_ITEM AND SD1.%NotDel%
//		LEFT JOIN %TABLE:SE2% SE2 ON D1_FILIAL = E2_FILIAL AND E2_NUM = D1_DOC AND E2_PREFIXO = D1_SERIE AND E2_FORNECE = D1_FORNECE AND E2_LOJA = D1_LOJA  AND SE2.%NotDel%
		WHERE ZZK.%NotDel% AND ZZK_CODIGO = %EXP:_cCod% AND ZZK_FILIAL = %EXP:_cFilSc% AND C1_XSALES != ' '
		GROUP BY C1_FILIAL,C1_NUM,C1_XSALES,SC1.D_E_L_E_T_, C1_RESIDUO
		ORDER BY C1_FILIAL,C1_NUM
	
	EndSQL
	
	IF !(cAlias)->(Eof())
		::cFilSc     := (cAlias)->C1_FILIAL
		::cCorpoPost := '{'
		::cCorpoPost += '"objetoProtheus": '
		::cCorpoPost += ' {"Empresa": "'+cEmpAnt+'", '
		::cCorpoPost += ' "Filial": "'+(cAlias)->C1_FILIAL+'", '
		::cCorpoPost += ' "Solicitacao": "'+(cAlias)->C1_NUM+'", '
		lResTot := .T.
		::cCorpoPost += ::buscaItem((cAlias)->C1_FILIAL,(cAlias)->C1_NUM)
		::cCorpoPost += ::buscaCot((cAlias)->C1_FILIAL,(cAlias)->C1_NUM)
		::cCorpoPost += ::buscaPed((cAlias)->C1_FILIAL,(cAlias)->C1_NUM)
		::cCorpoPost += ' "IdSales": "'+(cAlias)->C1_XSALES+'", '
		::cCorpoPost += ' "Excluido": "'+IF((cAlias)->SC1DEL=='*' .OR. lResTot,'true','false')+'" '
		
		::cCorpoPost += '					}'
//		::cCorpoPost += '					]'
		::cCorpoPost += '}'
	else
		::cErro := 'Solicitação não encontrada.'
		lRet := .F. 
	ENDIF
	(cAlias)->(dbCloseArea())
return


method enviaPost() class ClassIntCompras


Local _cUrlSal := GETMV( 'TCP_URLSAL' ) //"http://esb-qa.tcp.com.br:8280/SalesForce/AtualizarPurchaseRequest"
Local _nTime   := 1200
Local aHeadSal := {}
Local cAutRet  := ""
Local _cPostAu := ""
Local _cCorpo  := ""

//ADICIONA HEADER DA CHAMADA POST - AUTENTICAï¿½ï¿½O.
aadd(aHeadSal,'Content-Type: text/plain;charset=UTF-8')

//EXECUTA A CHAMADA DA FUNï¿½ï¿½O - AUTENTICAï¿½ï¿½O.
_cPostAu := HttpPost(_cUrlSal,"",::cCorpoPost,_nTime,aHeadSal,@cAutRet)

::atuLog(_cPostAu,_cUrlSal,cAutRet)

return


method atuLog(_cRet,_cUrlSal,cAutRet) class ClassIntCompras

	dbSelectArea('ZZK')
	ZZK->( dbSetOrder(1) )
	IF ZZK->( dbSeek( ::cFilSc + ::cCodInt ) )
		 
		while !	ZZK->(Eof()) .AND. ZZK->ZZK_FILIAL == ::cFilSc.AND.  ALLTRIM(ZZK->ZZK_CODIGO) == ::cCodInt
			
			RecLock("ZZK",.F.)
			ZZK->ZZK_XMLENV := ::cCorpoPost   
			ZZK->ZZK_XMLRET := _cRet
			ZZK->ZZK_STATUS := IF('Status":1' $ _cRet,'S','E')
			ZZK->ZZK_RETURL := cAutRet
			ZZK->ZZK_URL     := _cUrlSal
			ZZK->(msUnlock())
			ZZK->(dbSkip())
		enddo
	endif

return

method buscaItem(_cFil,_cNumSc) class ClassIntCompras
Local cHtmlCot := ''
Local cUltSol := ''				
	cAliasAx := getNextAlias()
	
			
	BeginSQL Alias cAliasAx
		SELECT C1_NUM,C1_ITEM,C1_PRODUTO,C1_DESCRI,C1_QUANT,C1_RESIDUO,C7_NUM
		FROM %TABLE:SC1% SC1
		LEFT JOIN %TABLE:SC7% SC7 ON C1_NUM = C7_NUMSC AND C1_ITEM = C7_ITEMSC and SC7.%NotDel% 
		WHERE SC1.%NotDel%  AND C1_FILIAL = %EXP:_cFil%  AND C1_NUM = %EXP:_cNumSc% 
		GROUP BY C1_NUM,C1_ITEM,C1_PRODUTO,C1_DESCRI,C1_QUANT,C1_RESIDUO,C7_NUM
		ORDER BY C1_NUM,C1_ITEM
		

	EndSQL
	
	IF !(cAliasAx)->(Eof())
		
		cHtmlCot += '"Items": ['
		
		WHILE !(cAliasAx)->(Eof())
			
			if(!empty(cUltSol))
				cHtmlCot += ','
			endif
			IF((cAlias)->C1_RESIDUO!='S')
				lResTot := .F.
			ENDIF
			cHtmlCot += ' {  '
			cHtmlCot += ' "Item": "'+(cAliasAx)->C1_ITEM+'", '
			cHtmlCot += ' "Produto": "'+(cAliasAx)->C1_PRODUTO+'", '
			cHtmlCot += ' "Descricao": "'+::CARACESP((cAliasAx)->C1_DESCRI)+'", '
			cHtmlCot += ' "Pedido": "'+(cAliasAx)->C7_NUM+'", '
			cHtmlCot += ' "Quantidade": "'+ ALLTRIM(TRANSFORM((cAliasAx)->C1_QUANT,'@E 999,999.99'))+'", '
			cHtmlCot += ' "Excluido": "'+IF((cAliasAx)->C1_RESIDUO=='S','true','false')+'" '
			cHtmlCot += ' 				}'
			
			cUltSol := (cAliasAx)->C1_ITEM
			
			(cAliasAx)->(DbSkip())
		ENDDO
		
		//Fecha a cotacoes
		cHtmlCot += '],'
		
	ENDIF
	
	
	(cAliasAx)->(dbCloseArea())
		
return cHtmlCot


method buscaCot(_cFil,_cNumSc) class ClassIntCompras
Local cHtmlCot := ''
Local cUltCot := ''				
	cAliasAx := getNextAlias()
	
			
	BeginSQL Alias cAliasAx
		SELECT C8_NUM,C8_FORNECE,C8_LOJA,SUM(C8_TOTAL) as C8_TOTAL,A2_NREDUZ,C8_NUMPED,C8_MOEDA,C8_EMISSAO, C8_PRODUTO,B1_DESC,C8_ITEM,
		SUM(C8_DESC1) AS VALDESC,SUM(C8_VALFRE) AS VALFRE
		FROM %TABLE:SC8% SC8
		INNER JOIN %TABLE:SA2% SA2 ON A2_COD = C8_FORNECE AND A2_LOJA = C8_LOJA and SA2.%NotDel% 
		INNER JOIN %TABLE:SB1% SB1 ON B1_COD= C8_PRODUTO AND SB1.%NotDel% 
		WHERE SC8.%NotDel%  AND C8_FILIAL = %EXP:_cFil%  AND C8_NUMSC = %EXP:_cNumSc% 
		GROUP BY C8_NUM,C8_FORNECE,C8_LOJA,A2_NREDUZ,C8_NUMPED,C8_MOEDA,C8_EMISSAO, C8_PRODUTO,B1_DESC,C8_ITEM
		ORDER BY C8_NUM,C8_FORNECE
		

	EndSQL
	
	IF !(cAliasAx)->(Eof())
		
		cHtmlCot += '"Cotacoes": ['
		
		WHILE !(cAliasAx)->(Eof())
			
			
			IF cUltCot != (cAliasAx)->C8_NUM + (cAliasAx)->C8_FORNECE+(cAliasAx)->C8_LOJA
			
				IF(!EMPTY(cUltCot))
					//Fecha Itens
					cHtmlCot += ' ]  '
					//Fecha Cotaï¿½ï¿½o
					cHtmlCot += '},'
				endif
				cHtmlCot += ' {  '
				cHtmlCot += ' "Cotacao": "'+(cAliasAx)->C8_NUM+'", '
				cHtmlCot += ' "Item": "'+(cAliasAx)->C8_ITEM+'", '
				cHtmlCot += ' "Fornecedor": "'+(cAliasAx)->C8_FORNECE+(cAliasAx)->C8_LOJA+'", '
				cHtmlCot += ' "Nome_Fornecedor": "'+::CARACESP((cAliasAx)->A2_NREDUZ)+'", '
				
				cHtmlCot += ' "Data_Emissao": "'+DTOC(STOD((cAliasAx)->C8_EMISSAO))+'", '
				
				cHtmlCot += '"Itens": ['
				cUltCot := ''
			ELSE
				cHtmlCot += ','
			ENDIF

			cHtmlCot += ' {  '
			cHtmlCot += ' "Vencedora": "'+if(!EMPTY((cAliasAx)->C8_NUMPED) .AND. (cAliasAx)->C8_NUMPED != 'XXXXXX','Yes','No')+'", '
			cHtmlCot += ' "Pedido": "'+::pedVenc((cAliasAx)->C8_NUM ,(cAliasAx)->C8_NUMPED,(cAliasAx)->C8_PRODUTO)+'", '
			cHtmlCot += ' "Valor_Total": "'+ ::SIGLAMOEDA((cAliasAx)->C8_MOEDA)+' '+ALLTRIM(TRANSFORM((cAliasAx)->C8_TOTAL+(cAliasAx)->VALFRE-(cAliasAx)->VALDESC,'@E 999,999.99'))+'", '
			cHtmlCot += ' "Produto": "'+(cAliasAx)->C8_PRODUTO+'", '
			cHtmlCot += ' "Produto_Descricao": "'+::CARACESP((cAliasAx)->B1_DESC)+'"'	
			
			cHtmlCot += ' 				}'
			
			cUltCot  := (cAliasAx)->C8_NUM + (cAliasAx)->C8_FORNECE+(cAliasAx)->C8_LOJA
			
			(cAliasAx)->(DbSkip())
		ENDDO
		
		//Fecha os itens do ultima cotaï¿½ï¿½o		
		cHtmlCot += ' ]  '
		
		//Fecha o ultima cotacao
		cHtmlCot += '}'
		
		//Fecha a cotacoes
		cHtmlCot += '],'
		
	ENDIF
	
	
	(cAliasAx)->(dbCloseArea())
		
return cHtmlCot

method buscaPed(_cFil,_cNum) class ClassIntCompras
Local cHtmlPed := ''
Local cUltStat := ''
Local lTotElimin := .T.				
	cAliasAP := getNextAlias()
	
	BeginSQL Alias cAliasAP
		SELECT C7_FILIAL,C7_NUM,C7_ITEM,D1_DOC,C7_QUANT,D1_ITEM,E2_BAIXA,E2_VENCREA,C7_CONAPRO,C7_PRODUTO,C7_DESCRI,C7_DATPRF, C7_EMISSAO,C7_NUMCOT,C7_ITEMCTA,
		CTD_XNATUR,C7_RESIDUO
		FROM %TABLE:SC7% SC7
		LEFT JOIN %TABLE:SD1% SD1 ON D1_PEDIDO = C7_NUM AND D1_ITEMPC = C7_ITEM AND SD1.%NotDel%
		LEFT JOIN %TABLE:SE2% SE2 ON D1_FILIAL = E2_FILIAL AND E2_NUM = D1_DOC AND E2_PREFIXO = D1_SERIE AND E2_FORNECE = D1_FORNECE AND E2_LOJA = D1_LOJA  AND SE2.%NotDel%
		LEFT JOIN %TABLE:CTD% CTD ON CTD_ITEM = C7_ITEMCTA AND CTD.%NotDel%
		WHERE SC7.%NotDel% AND C7_FILIAL = %EXP:_cFil% AND C7_NUMSC = %EXP:_cNum%
		ORDER BY C7_NUM,C7_ITEM,D1_DOC,D1_ITEM,E2_BAIXA,C7_CONAPRO,C7_PRODUTO,C7_DESCRI

	EndSQL
	
	IF !(cAliasAP)->(Eof())
		
		::ultAprov := ''
		lTotLanc := .t.
		lTotElimin := .T.
		cUltPed  := ''
		cHtmlPed += '"Pedidos": ['
		WHILE !(cAliasAP)->(Eof())
			
			IF cUltPed != (cAliasAP)->C7_NUM
				
				if !empty(cUltPed)
					
					IF lTotLanc
						::cStatAprov := 'Total Receipt'
					ENDIF
					//Fecha os itens
					cHtmlPed += ' ],  '
					IF lTotElimin
						_cStatPed := 'Eliminated'
					ELSEIF !EMPTY(::cStatAprov)
						_cStatPed := ::cStatAprov
					ELSEif cUltStat == 'L'
						_cStatPed := 'Approved'
					ELSEIF EMPTY(::cStatScr)
						_cStatPed := 'NULL' 
					ELSE
						_cStatPed := 'On approval'
					ENDIF	
//					cHtmlPed += ' "Pedido_Status": "'+if((cAliasAP)->C7_CONAPRO=='L','Approved',IF(!EMPTY(::cStatAprov),::cStatAprov,IF(EMPTY(::cStatScr),'NULL','On approval')))+'" '
					cHtmlPed += ' "Pedido_Status": "'+_cStatPed+'" '
					
					//Fecha pedido
					cHtmlPed += '},'
					
					lTotLanc := .t.
					lTotElimin := .T.
					cUltPed  := ''
				endif
				cHtmlPed += ' {  '
				cHtmlPed += ' "Pedido": "'+(cAliasAP)->C7_NUM+'", '
				
				::cStatAprov := ''
				::primNivel := ''	
				::primUser := ''
				
				cHtmlPed += ::buscaAprov((cAliasAP)->C7_FILIAL,(cAliasAP)->C7_NUM) 
				cHtmlPed += ' "Quantidade_Ciclos": "'+::buscaCiclos((cAliasAP)->C7_FILIAL,(cAliasAP)->C7_NUM)+'" ,'
				cHtmlPed += ' "Data_Aprovacao": "'+IF((cAliasAP)->C7_CONAPRO == 'L',DTOC(STOD(::ultAprov)),'')+'" ,'
				cHtmlPed += ' "Data_Emissao": "'+DTOC(STOD((cAliasAP)->C7_EMISSAO))+'", '
				cHtmlPed += '"Itens": ['
				
//				cHtmlPed += ' }  '
			ELSE
				cHtmlPed += ','
			ENDIF
			
			IF (cAliasAP)->C7_RESIDUO != 'S'
				lTotElimin := .F.
			ENDIF

			cUltStat := (cAliasAP)->C7_CONAPRO
			cHtmlPed += ' {  '
			cHtmlPed += ' "Produto": "'+(cAliasAP)->C7_PRODUTO+'", '
			cHtmlPed += ' "Produto_Descricao": "'+::CARACESP((cAliasAP)->C7_DESCRI)+'", '
			cHtmlPed += ' "Quantidade": "'+ALLTRIM(STR((cAliasAP)->C7_QUANT))+'", '
			cHtmlPed += ' "Data_Entrega": "'+DTOC(STOD((cAliasAP)->C7_DATPRF))+'", '
			cHtmlPed += ' "Item_Conta": "'+(cAliasAP)->C7_ITEMCTA+'", '
			cHtmlPed += ' "Natureza": "'+(cAliasAP)->CTD_XNATUR+'", '
			cHtmlPed += ' "Excluido": "'+if((cAliasAP)->C7_RESIDUO == 'S','true','false')+'", '
			
			
			if !empty((cAliasAP)->D1_DOC)
				::cStatAprov := 'Partial Receipt'
			else
				lTotLanc := .F.
			endif
				
			cHtmlPed += ' "Nota": "'+(cAliasAP)->D1_DOC+'", '
			cHtmlPed += ' "Nota_Item": "'+(cAliasAP)->D1_ITEM+'", '
			
			cHtmlPed += ' "Previsao_Pgto": "'+DTOC(STOD((cAliasAP)->E2_VENCREA))+'", '
			cHtmlPed += ' "Data_Pgto": "'+DTOC(STOD((cAliasAP)->E2_BAIXA))+'" '
			
			cHtmlPed += ' }  '
			 cUltPed := (cAliasAP)->C7_NUM
			
			(cAliasAP)->(DbSkip())
		ENDDO
		
		IF lTotLanc
			::cStatAprov := 'Total Receipt'
		ENDIF
		
		//Fecha os itens do ultimo pedido		
		cHtmlPed += ' ],  '
		
		_cStatPed := ''	
		
		IF lTotElimin
			_cStatPed := 'Eliminated'
		ELSEIF !EMPTY(::cStatAprov)
			_cStatPed := ::cStatAprov
		ELSEif cUltStat == 'L'
			_cStatPed := 'Approved'
		ELSEIF EMPTY(::cStatScr)
			_cStatPed := 'NULL' 
		ELSE
			_cStatPed := 'On approval'
		ENDIF	
		
		
//		cHtmlPed += ' "Pedido_Status": "'+if(cUltStat=='L','Approved',IF(!EMPTY(::cStatAprov),::cStatAprov,IF(EMPTY(::cStatScr),'NULL','On approval')))+'" '
		cHtmlPed += ' "Pedido_Status": "'+_cStatPed +'" '
		
		//Fecha o ultimo pedido
		cHtmlPed += '}'
		
		//Fecha os pedidos
		cHtmlPed += '],'
		
	ENDIF
	
	
	(cAliasAP)->(dbCloseArea())
		
return cHtmlPed

method buscaAprov(_cFil,_cPed)  class ClassIntCompras
lOCAL _cAprovador := ''
	cAliasAx := getNextAlias()
					
	BeginSQL Alias cAliasAx
		SELECT CR_DATALIB,CR_NIVEL, AK_NOME,CR_STATUS,CR_USER
		FROM %TABLE:SCR% SCR
		INNER JOIN %TABLE:SAK% SAK ON AK_COD = CR_APROV and SAK.%NotDel% 
		WHERE SCR.%NotDel% AND CR_FILIAL = %EXP:_cFil% AND CR_NUM = %EXP:_cPed% AND CR_TIPO = 'PC'
		ORDER BY CR_NIVEL
	
	EndSQL
	
	_cAprovador := ''
	IF !(cAliasAx)->(Eof())
		WHILE !(cAliasAx)->(Eof())
			
			::cStatScr      := ''
			IF EMPTY(_cAprovador)
	//							_cAprovador := '{'
				_cAprovador += '"Aprovacoes": ['
			ELSE
				_cAprovador += ','
			ENDIF
		
			if (cAliasAx)->CR_STATUS== "01"
				::cStatScr := 'Waiting for other levels'
			elseif (cAliasAx)->CR_STATUS== "02"
				::cStatScr := 'Waiting for user approval'
			elseif (cAliasAx)->CR_STATUS== "03"
				::cStatScr := 'Approved'
			elseif (cAliasAx)->CR_STATUS== "04"
				::cStatAprov := 'Rejected'
				::cStatScr := 'Rejected'
			elseif (cAliasAx)->CR_STATUS== "05"
				::cStatScr := 'Rejected'
				::cStatAprov := 'Rejected'
			endif
			
			if empty(::primNivel)
				::primNivel := (cAliasAx)->CR_NIVEL
				::primUser := (cAliasAx)->CR_USER
			endif
			if(!EMPTY((cAliasAx)->CR_DATALIB) .AND. (cAliasAx)->CR_DATALIB > ::ultAprov)
				::ultAprov := (cAliasAx)->CR_DATALIB 
			ENDIF
			
			_cAprovador += ' {  '
			_cAprovador += ' "Aprovador": "'+(cAliasAx)->CR_USER+'", '
			_cAprovador += ' "Nome": "'+::RetNomFunc((cAliasAx)->CR_USER)+'", '
			_cAprovador += ' "Nivel": "'+(cAliasAx)->CR_NIVEL+'", '
			_cAprovador += ' "Status": "'+::cStatScr+'", '
			_cAprovador += ' "Data_Aprovacao": "'+DTOC(STOD((cAliasAx)->CR_DATALIB))+'" '
			_cAprovador += ' 				}'
			(cAliasAx)->(DbSkip())
		ENDDO
		_cAprovador += '],'
	ENDIF
	
	(cAliasAx)->(dbCloseArea())
				
return _cAprovador


method buscaCiclos(_cFil,_cPedido)  class ClassIntCompras

lOCAL cQtdCiclos := 0
lOCAL _cNivel := ::primNivel
Local cPrimUsr := ::primUser

	cAliasAx := getNextAlias()
					
	//Busca quantas vezes foi gerada alï¿½ada (contando excluidas), para saber quantas vezes passou pelo fluxo de aprovaï¿½ï¿½o
	BeginSQL Alias cAliasAx
		SELECT COUNT(*) AS CICLOS
		FROM %TABLE:SCR% SCR
		WHERE CR_FILIAL = %EXP:_cFil% AND CR_NUM = %EXP:_cPedido% AND CR_TIPO = 'PC' AND CR_NIVEL = %EXP:_cNivel% AND CR_USER = %EXP:cPrimUsr%
	
	EndSQL
	
	IF !(cAliasAx)->(Eof())
		cQtdCiclos := (cAliasAx)->CICLOS
	ENDIF
	
	(cAliasAx)->(dbCloseArea())
				
return ALLTRIM(STR(cQtdCiclos))

method reenviaSales() class ClassIntCompras
	Local dDtLim  := DaySub(dDatabase,5)
	cAliaAux2 := getNextAlias()
	
	BeginSQL Alias cAliaAux2
		SELECT DISTINCT(ZZK_FILIAL+ZZK_CODIGO+ZZK_NUMSC),ZZK_FILIAL,ZZK_CODIGO,ZZK_NUMSC
		FROM %TABLE:ZZK% ZZK
		INNER JOIN %TABLE:SC1% SC1 ON ZZK_NUMSC = C1_NUM AND ZZK_FILIAL = C1_FILIAL AND SC1.%NotDel%  
		WHERE ZZK.%NotDel%  AND ZZK_STATUS IN ('E','P') AND ZZK_DATA >= %EXP:DTOS(dDtLim)%
		GROUP BY ZZK_FILIAL,ZZK_CODIGO,ZZK_NUMSC

	EndSQL
	
	WHILE !(cAliaAux2)->(Eof())
		IF !EMPTY((cAliaAux2)->ZZK_FILIAL)
			cFilAnt := (cAliaAux2)->ZZK_FILIAL
		ENDIF
		
		::cCodInt := ::PROXCODIGO()
		
		::cFilSc := (cAliaAux2)->ZZK_FILIAL
		::cNumSc := (cAliaAux2)->ZZK_NUMSC
					
		::gravaLogZZK()
			 
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



method SIGLAMOEDA(cMoeda) class ClassIntCompras 
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


method CARACESP(cString) class ClassIntCompras 

   Local _sRet := cString

   
   _sRet := StrTran (_sRet, "'", "")
   _sRet := StrTran (_sRet, '"', "")
   _sRet := StrTran (_sRet, "º", ".")
   _sRet := StrTran (_sRet, "ª", ".")
   _sRet := StrTran (_sRet, "&", "e")
   _sRet := StrTran (_sRet, "|", "")
   _sRet := StrTran (_sRet, "\", " ")
   _sRet := StrTran (_sRet, "/", " ")
   _sRet := StrTran (_sRet, "<", " ")
   _sRet := StrTran (_sRet, ">", " ")
   _sRet := StrTran (_sRet, chr (9), " ") // TAB
   //_sRet := StrTran (_sRet, chr (32), "") // TAB
   //Sï¿½ para garantir
   _sRet := noAcento (_sRet) 
   

Return _sRet

method PROXCODIGO() class ClassIntCompras

Local cNextCod := GETSX8NUM("ZZK","ZZK_CODIGO")
		
//Valida se o cï¿½digo estï¿½ sendo usado.
dbSelectArea('ZZK')
ZZK->( dbSetOrder(1) )
IF ZZK->( dbSeek( xFilial("ZZK") + cNextCod ) )
	//Enquanto encontrar cï¿½digo, pega um novo. Atï¿½ q encontre 1 q nï¿½o existe
	while ZZK->( dbSeek( xFilial("ZZK") +  cNextCod ) )
		 cNextCod  := GETSX8NUM("ZZK","ZZK_CODIGO")
	enddo
endif

ConfirmSX8()

return cNextCod

method pedVenc(_cNumCot,_cNumPd,cCodPro) class ClassIntCompras

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
method RetNomFunc(cCodigo) class ClassIntCompras
_cNomUsu := ''

IF(!EMPTY(cCodigo))
	_aRetUsu := FWSFALLUSERS({cCodigo})
	if(LEN(_aRetUsu) >= 1 .AND. LEN(_aRetUsu[1]) >= 4)
		_cNomUsu := ALLTRIM(_aRetUsu[1,4])
	ENDIF
endif

return _cNomUsu

