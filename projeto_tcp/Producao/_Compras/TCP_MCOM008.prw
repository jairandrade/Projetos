#include "totvs.ch"

/*/{Protheus.doc} MCOM008
    Rotina para re-envio de email de cotacao
    @type  Function
    @author Lucas Jose Correa Chagas
    @since 29/05/2013 
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
/*/
User Function MCOM008()

Local aArea   := GetArea()
Local aRet    := {}
Local cTitulo := 'Workflow - Gera��o de E-mail de Envio'
Local cSubTit := ''
Local cMsg    := ''
Local nI      := 1

Private aEmails 	:= {}
Private aEmailsVenc := {}

If !Empty(SC8->C8_XHOMFOR)
	//Fornecedores OK e Aptos(Homologacao Vencida, mas dentro do prazo parametro TCP_DIASHM)
	If SC8->C8_XHOMFOR == "OK" .OR. SC8->C8_XHOMFOR == "AP"
		//monta os emails
		MCOM0081(SC8->C8_XHOMFOR)
	//Fornecedores com homologa��o vencida
	ElseIf ( SC8->C8_XHOMFOR == "VE" .Or. SC8->C8_XHOMFOR == "NH" )
		//monta os emails
		EmailsVenc()
		lHomVenc := .T.
	EndIf
ElseIf Empty(SC8->C8_XHOMFOR)
	//monta os emails
	MCOM0081("ND")
EndIf

if Len(aEmails) > 0
	aRet := U_MCOM002(aClone(aEmails))

	// verifica o retorno da informa��o
	if len(aRet) > 0
		cMsg := ''
		if aRet[nI,1]
			RecLock('SC8',.F.)
				SC8->C8_DTENV := dDataBase
			SC8->(dbUnlock())

			cSubTit := 'Re-envio bem sucedido'
			cMsg    := "Re-envio de cota��o para o fornecedor realizada com sucesso!"
		else
			cSubTit := 'E-mail n�o enviado'
			cMsg += 'E-mail para o fornecedor ' + aRet[nI,2] + ' n�o enviado. Observa��es: ' + CRLF
			cMsg += aRet[nI,3] + CRLF
		endif

		if !Empty(cMsg)
			Aviso( cTitulo, cMsg, { "Ok" }, 2, cSubTit, 1, , .F.)
		endif
	endif
endif

if Len(aEmailsVenc) > 0
	aRet := U_MCOM002(aClone(aEmailsVenc))

	// verifica o retorno da informa��o
	if len(aRet) > 0
		cMsg := ''
		if aRet[nI,1]
			RecLock('SC8',.F.)
				SC8->C8_DTENV := dDataBase
			SC8->(dbUnlock())

			cSubTit := 'Re-envio bem sucedido'
			cMsg    := "Re-envio de cota��o para o fornecedor realizada com sucesso!"
		else
			cSubTit := 'E-mail n�o enviado'
			cMsg += 'E-mail para o fornecedor ' + aRet[nI,2] + ' n�o enviado. Observa��es: ' + CRLF
			cMsg += aRet[nI,3] + CRLF
		endif

		if !Empty(cMsg)
			Aviso( cTitulo, cMsg, { "Ok" }, 2, cSubTit, 1, , .F.)
		endif
	endif
endif

If Len(aEmails) == 0 .AND. Len(aEmailsVenc)
	cSubTit := 'Fornecedores n�o selecionados'
	cMsg    := "Nenhum fornecedor selecionado para envio!"
	Aviso( cTitulo, cMsg, { "Ok" }, 2, cSubTit, 1, , .F.)
EndIf

RestArea(aArea)

Return

/*/{Protheus.doc} MCOM0081
    Monta dados para envio de e-mail
    @type  Function
    @author Lucas Jose Correa Chagas
    @since 29/05/2013 
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function MCOM0081(cHomFor)

	Local aArea   := GetArea()
	Local cHtml   := ''
	Local cHttp   := SuperGetMV("TCP_HTTP" , .F., '') //http://localhost:81/TCP
	Local cTitulo := 'Workflow - Gera��o de E-mail de Envio'
	Local cSubTit := ''
	Local cMsg    := ''
	Local cId     := ''

	DEFAULT cHomFor := "ND"

	dbSelectArea('SA2')
	SA2->(dbSetOrder(1))

	dbSelectArea('SC1')
	SC1->(dbSetOrder(1))

	if Empty(cHttp)
		cSubTit := 'Endere�o WEB n�o definido!'
		cMsg    := "Endere�o para envio do workflow n�o encontrado. Por favor verifique o par�metro 'TCP_HTTP'."
		Aviso( cTitulo, cMsg, { "Ok" }, 2, cSubTit, 1, , .F.)
	else
		if !SA2->(dbSeek(xfilial('SA2') + SC8->C8_FORNECE + SC8->C8_LOJA))
			cSubTit := 'Fornecedor da cota��o n�o encontrado!'
			cMsg    := "Fornecedor da cota��o n�o encontrado com os dados de c�digo e loja repassados ('" + AllTrim(SC8->C8_FORNECE) + "' | '" + AllTrim(SC8->C8_LOJA) + "')."
			Aviso( cTitulo, cMsg, { "Ok" }, 2, cSubTit, 1, , .F.)
		else
			if Empty(SA2->A2_EMAIL)
				cSubTit := 'E-mail do fornecedor n�o cadastrado na base de dados!'
				cMsg    := "O campo e-mail para o fornecedor ('" + AllTrim(SC8->C8_FORNECE) + "' | '" + AllTrim(SC8->C8_LOJA) + "') n�o foi cadastrado."
				Aviso( cTitulo, cMsg, { "Ok" }, 2, cSubTit, 1, , .F.)
			else

				cId := cEmpAnt + cFilAnt + SC8->C8_FILIAL + SC8->C8_NUM + SC8->C8_FORNECE + SC8->C8_LOJA + SC8->C8_NUMPRO
				//Conout(cId)
				cId := u_Encripta(cId,0)
				//Conout(cId)
				cHttp += cId

				if (Empty(SC8->C8_NUMSC))
					cHtml := MCOM0082( SA2->A2_EST != 'EX', Nil, cHttp,cHomFor )
				else
					SC1->(dbGoTop())
					if SC1->(dbSeek(xFilial('SC1') + SC8->C8_NUMSC + SC8->C8_ITEMSC))
						cHtml := MCOM0082( SA2->A2_EST != 'EX', SC1->C1_CODCOMP, cHttp,cHomFor )
					else
						cHtml := MCOM0082( SA2->A2_EST != 'EX', Nil, cHttp,cHomFor )
					endif
				endif

				cMail := SA2->A2_EMAIL
				cCc	  := ""
				if (SA2->A2_EST != 'EX')
					cAssunto := "Re-envio de Cota��o de Produtos - " + SM0->M0_NOME
				else
					cAssunto := "Re-sending Quotation Product - " + SM0->M0_NOME
				endif

				aAdd(aEmails,{cMail, cCc, cAssunto, cHtml, SC8->C8_FORNECE + SC8->C8_LOJA})
			endif
		endif
	endif

RestArea(aArea)

return

/*/{Protheus.doc} MCOM0082
    Monta corpo do e-mail 
    @type  Function
    @author Lucas Jose Correa Chagas
    @since 29/05/2013 
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function MCOM0082( lNacional, cY1Cod, cHttp, cHomFor )

	Local cHtml      := ''
	Local cComprador := '		<p></p>' + CRLF
	Local oHtml      := TWFHtml():New("\WORKFLOW\HTML\MAILNOTIFLISTING.html")

	if (cY1Cod != Nil)
		dbSelectArea('SY1')
		SY1->(dbSetOrder(1))
		SY1->(dbGoTop())
		if SY1->(dbSeek(xFilial('SY1') + cY1Cod))
			cComprador += '		<p>' + AllTrim(SY1->Y1_NOME) + ' | Comprador | Purchaser</p>' + CRLF
			cComprador += '		<p>' + AllTrim(SY1->Y1_TEL) + '</p>' + CRLF
			cComprador += '		<p></p>' + CRLF
		endif
	endif

	if (lNacional)
		cHtml += '		<p> Srs.(as),' + CRLF
		cHtml += '		<p> Solicitamos or�amento, <a href="' + cHttp + '" target="_blank">clique aqui para preenchimento da cota��o n.� ' + AllTrim(SC8->C8_NUM) + '</a>. </p>' + CRLF
		cHtml += '		<p></p>' + CRLF
		If cHomFor == "AP"
			cHtml += '<p>Prezado fornecedor,</p>' + CRLF	
			cHtml += '<p>Informamos que, devido ao vencimento de um documento requerido, sua homologa��o '
			cHtml += 'no sistema da TCP est� vencida. Conforme previsto em nosso sistema de homologa��o, '	
			cHtml += 'a sua empresa tem o prazo de 90 dias para envio da documenta��o atualizada e se '		
			cHtml += 'manter ativa para fornecimento de produtos e/ou servi�os para TCP. Caso n�o seja '	
			cHtml += 'realizada a regulariza��o no prazo informado, a homologa��o da sua empresa estar� '	
			cHtml += 'suspensa e ser� bloqueado o fornecimento de produtos e/ou servi�os para a TCP.</p>' 	+ CRLF
			cHtml += '<p>Por favor, encaminhar os documentos atualizados para o e-mail sga@tcp.com.br.</p>' + CRLF
		Else
			cHtml += '		<p>' + CRLF
			cHtml += '		</p>' + CRLF
		EndIf
		cHtml += '		<p></p>' + CRLF
		cHtml += '		<p style="font-weight:bold;">Observa��o:</p>' + CRLF
		cHtml += '		<p>Nosso CNPJ: ' +AllTrim(Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"))+ '</p>' + CRLF
		cHtml += '		<p>Inscri��o Estadual: ISENTO</p>' + CRLF
		cHtml += '		<p></p>' + CRLF
		cHtml += cComprador
		cHtml += '		<p>(N�o responder este e-mail.)</p>' + CRLF
		cHtml += '<BR> <BR> '
	
		cHtml += '<table class="tg2" style="undefined;table-layout: fixed; width: 750px"> '
		cHtml += '<colgroup> '
		cHtml += '<col style="width: 750px"> '
		cHtml += '</colgroup> '
		cHtml += '  <tr> '
		cHtml += '    <th class="tg2-dadk">CONDI��ES GERAIS DE COMPRAS:</th> '
		cHtml += '  </tr> '
		cHtml += '  <tr> '
		cHtml += '    <td class="tg2-763c">- Os produtos dever�o ser entregues absolutamente dentro do prazo combinado. A n�o observ�cia da presente cl�sula garante-nos o direito de cancelar esse "Processo de Compras", em todo ou em parte, sem qualquer preju�zo de nossa parte.<br>- Todo material fornecido dever� estar rigorosamente de acordo com o nosso pedido no que se refere a especifica��o, desenhos etc. Em caso de rejei��o ser� colocado � disposi��o, por conta e risco do fornecedor, at� a sua retirada. Qualquer despesa de transporte, relativo a materiais assim rejeitados, ocorrer�o por conta do fornecedor.<br>- Reservamo-nos o direito de recusar e devolver, � custas do fornecedor, qualquer parcela de material recebido em quantidade superior � aquela cujo fornecimento foi autorizado pelo presente pedido de compra.<br>- A presente encomenda n�o poder� ser faturada por pre�os mais elevados do que aqueles aqui estabelecidos.<br>- N�o assumimos qualquer responsabilidade por mercadorias, cujas entregas n�o tenham sido autorizadas neste processo de, compras devidamente aprovado ou que, de qualquer modo n�o esteja de acordo com os termos e condi��es supra-estabelecidas.<br>- Garanta a possibilidade de novos pedidos respeitando o estabelecido nos itens acima. Pedimos em benef�cio rec�proco nos avisar por telefone, e-mail ou carta sobre qualquer dilata��o que venha a sofrer o prazo de entrega originalmente fixado ou sobre sua impossibilidade de cumprir qualquer das cl�sulas acima.<br>- Confirmar recebimento da autoriza��o e aceite.</td> '
		cHtml += '  </tr> '
		cHtml += '</table> '
		
		cHtml += '<BR> <BR> '
		cHtml += '<table class="tg3" style="undefined;table-layout: fixed; width: 750px"> '
		cHtml += '<colgroup> '
		cHtml += '<col style="width: 750px"> '
		cHtml += '</colgroup> '
		cHtml += '  <tr> '
		cHtml += '    <th class="tg3-dadk">IMPORTANTE - TESTE PAULO</th> '
		cHtml += '  </tr> ' 
		cHtml += '  <tr> '
		cHtml += '    <td class="tg3-764c"><span style="color:red">Materiais e/ou servi&ccedil;os entregues fora do prazo ser&atilde;o descontados 5% no ato e 1% a cada sete dias de atraso, valor considerado sobre o total do pedido de compra, al&eacute;m do desconto, atrasos impactar&atilde;o na avalia&ccedil;&atilde;o do fornecedor, correndo o risco do mesmo ser exclu&iacute;do de futuras cota&ccedil;&otilde;es.</span> '
		cHtml += '			<BR> '
		cHtml += '    <span style="color:red">ATEN��O: O fornecimento de produtos e a presta��o de servi�os dever�o, obrigatoriamente, assegurar prazo de garantia min�mo de 01 (um) ano, contado da data de entrega/instala��o do produto ou finaliza��o do servi�o. Servi�os que envolvam reparos estruturais ou pinturas, obrigatoriamente, dever�o apresentar prazo de garantia min�mo de 02 (dois) anos.</span> '   
		cHtml += '			<BR> '
	
	Else
		cHtml += '		<p> Messrs. (the), </p>' + CRLF
		cHtml += '		<p> Budget request, <a href="' + cHttp + '" target="_blank">click here to fill the quotation n. � ' + AllTrim(SC8->C8_NUM) + '</a>. </p>' + CRLF
		cHtml += '		<p></p>' + CRLF
		If cHomFor == "AP"
			cHtml += '<p>Messrs. (the) supplier,</p>' + CRLF	
			cHtml += '<p>We inform that, due to the maturity of a required document, its homologation '	
			cHtml += 'in the TCP system is expired. As provided for in our homologation system, '
			cHtml += 'your company has 90 days to send updated documentation and if '
			cHtml += 'keep active to supply products and / or services to TCP. If it is not '
			cHtml += 'regularization is carried out within the informed period, the homologation of your company will be '
			cHtml += 'suspended and the supply of products and / or services to TCP will be blocked.</p>' 	+ CRLF
			cHtml += '<p>Please forward the updated documents to the email sga@tcp.com.br.</p>' + CRLF
		Else
			cHtml += '		<p>' + CRLF
			cHtml += '		</p>' + CRLF
		EndIf
		cHtml += '		<p></p>' + CRLF
		cHtml += '		<p style="font-weight:bold;">Observation:</p>' + CRLF
		cHtml += '		<p>Our CNPJ: ' +AllTrim(Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"))+ '</p>' + CRLF
		cHtml += '		<p>State Registration: ISENTO</p>' + CRLF
		cHtml += '		<p></p>' + CRLF
		cHtml += cComprador
		cHtml += '		<p>(Do not respond this e-mail.)</p>' + CRLF
	Endif

	If lNacional
		oHtml:ValByName("HEADER","Cota��o de Produtos")
	Else
		oHtml:ValByName("HEADER","Listing of Products")
	Endif
	oHtml:ValByName("BODY",cHtml)
	cHtml := oHtml:HtmlCode()

Return cHtml

/*/{Protheus.doc} EmailsVenc
    Monta dados para envio de e-mail para fornecedores com Homologa��o Produtos Quimicos Vencida    
    @type  Function
    @author Willian Kaneta
    @since  21/07/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function EmailsVenc()
	Local aArea   := GetArea()
	Local cHtml   := ''
	Local cHttp   := SuperGetMV("TCP_HTTP" , .F., '') //http://localhost:81/TCP
	Local cMailCmp:= SuperGetMV("TCP_MAILPQ" , .F., '')
	Local cTitulo := 'Workflow - Gera��o de E-mail de Envio'
	Local cSubTit := ''
	Local cMsg    := ''

	dbSelectArea('SA2')
	SA2->(dbSetOrder(1))

	dbSelectArea('SC1')
	SC1->(dbSetOrder(1))

	if Empty(cHttp)
		cSubTit := 'Endere�o WEB n�o definido!'
		cMsg    := "Endere�o para envio do workflow n�o encontrado. Por favor verifique o par�metro 'TCP_HTTP'."
		Aviso( cTitulo, cMsg, { "Ok" }, 2, cSubTit, 1, , .F.)
	else
		if !SA2->(dbSeek(xfilial('SA2') + SC8->C8_FORNECE + SC8->C8_LOJA))
			cSubTit := 'Fornecedor da cota��o n�o encontrado!'
			cMsg    := "Fornecedor da cota��o n�o encontrado com os dados de c�digo e loja repassados ('" + AllTrim(SC8->C8_FORNECE) + "' | '" + AllTrim(SC8->C8_LOJA) + "')."
			Aviso( cTitulo, cMsg, { "Ok" }, 2, cSubTit, 1, , .F.)
		else
			if Empty(SA2->A2_EMAIL)
				cSubTit := 'E-mail do fornecedor n�o cadastrado na base de dados!'
				cMsg    := "O campo e-mail para o fornecedor ('" + AllTrim(SC8->C8_FORNECE) + "' | '" + AllTrim(SC8->C8_LOJA) + "') n�o foi cadastrado."
				Aviso( cTitulo, cMsg, { "Ok" }, 2, cSubTit, 1, , .F.)
			else

				if (Empty(SC8->C8_NUMSC))
					cHtml := LayoutVenc( SA2->A2_EST != 'EX', Nil )
				else
					SC1->(dbGoTop())
					if SC1->(dbSeek(xFilial('SC1') + SC8->C8_NUMSC + SC8->C8_ITEMSC))
						cHtml := LayoutVenc( SA2->A2_EST != 'EX', SC1->C1_CODCOMP )
					else
						cHtml := LayoutVenc( SA2->A2_EST != 'EX', Nil, cHttp )
					endif
				endif

				cMail := SA2->A2_EMAIL
				If !Empty(cMailCmp)
					cCc := cMailCmp
				Else
					cCc	:= ""
				EndIf

				if (SA2->A2_EST != 'EX')
					cAssunto := "Re-envio de Cota��o de Produtos - " + SM0->M0_NOME
				else
					cAssunto := "Re-sending Quotation Product - " + SM0->M0_NOME
				endif

				aAdd(aEmailsVenc,{cMail,cCc, cAssunto, cHtml, SC8->C8_FORNECE + SC8->C8_LOJA})
			endif
		endif
	endif

	RestArea(aArea)
return

/*/{Protheus.doc} LayoutVenc
    Monta corpo do e-mail para fornecedores com Homologa��o Produtos Quimicos Vencida 
    @type  Function
    @author Willian Kaneta
    @since  21/07/2020
    @version 1.0
    @return cHtml - Corpo Email
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function LayoutVenc( lNacional, cY1Cod, cHttp )

	Local cHtml      := ''
	Local cComprador := '		<p></p>' + CRLF
	Local oHtml      := TWFHtml():New("\WORKFLOW\HTML\MAILNOTIFLISTING.html")

	if (cY1Cod != Nil)
		dbSelectArea('SY1')
		SY1->(dbSetOrder(1))
		SY1->(dbGoTop())
		if SY1->(dbSeek(xFilial('SY1') + cY1Cod))
			cComprador += '		<p>' + AllTrim(SY1->Y1_NOME) + ' | Comprador | Purchaser</p>' + CRLF
			cComprador += '		<p>' + AllTrim(SY1->Y1_TEL) + '</p>' + CRLF
			cComprador += '		<p></p>' + CRLF
		endif
	endif

	if (lNacional)
		cHtml += '		<p> Prezado fornecedor,' + CRLF
		cHtml += '		<p> A homologa��o de sua empresa encontra-se suspensa, pois o prazo de 90 dias '
		cHtml +=			'para regulariza��o foi ultrapassado. Dessa forma sua empresa est� impossibilitada '
		cHtml +=			'de fornecer produtos e/ou servi�os para a TCP at� o envio de todos os documentos '
		cHtml +=			'atualizados.' + CRLF + CRLF
		cHtml += '		<p>Por favor, encaminhar documentos atualizados para o e-mail sga@tcp.com.br.</p>' + CRLF
		cHtml += '		<p></p>' + CRLF
		cHtml += cComprador
		cHtml += '		<p>(N�o responder este e-mail.)</p>' + CRLF
		cHtml += '<BR> <BR> '	
	else
		cHtml += '		<p> Messrs. (the), </p>' + CRLF
		cHtml += "		<p> Your company's homologation is suspended, as the 90-day period for regularization "
		cHtml +=			"has been exceeded. Thus, your company is unable to provide products and / or services "
		cHtml +=			"to TCP until the sending of all updated documents. </p>" + CRLF + CRLF
		cHtml += '		<p>Por favor, encaminhar documentos atualizados para o e-mail sga@tcp.com.br.</p>' + CRLF
		cHtml += '		<p></p>' + CRLF
		cHtml += cComprador
		cHtml += '		<p>(Do not respond this e-mail.)</p>' + CRLF
	endif

	If lNacional
		oHtml:ValByName("HEADER","Cota��o de Produtos")
	Else
		oHtml:ValByName("HEADER","Listing of Products")
	Endif
	oHtml:ValByName("BODY",cHtml)
	cHtml := oHtml:HtmlCode()

Return cHtml
