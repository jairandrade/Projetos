#include "totvs.ch"

/*/{Protheus.doc} MCOM006
    Rotina disparada a partir do ponto de entrada MT130WF
    @type  Function
    @author Lucas Jose Correa Chagas
    @since 16/05/2013
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
/*/
User Function MCOM006(cNumeroCotacao)

	Local aArea     := SaveArea1({"SC1","SC8","SA2"})
	Local lOk := .F.

	Local aPosObj   := {}
	Local aObjects  := {}
	Local aSize     := {}
	Local aInfo     := {}

	Local aFornecedor := GetFornecedores(cNumeroCotacao)

	Local lRecebeCopia := .F.
	Local cMyEmail := PadR(UsrRetMail(RetCodUsr()),200)

	Local   oOk      := LoadBitmap( GetResources(), "LBOK" )
	Local   oNo      := LoadBitmap( GetResources(), "LBNO" )

	Private oDlg
	Private oList



	aSize := MsAdvSize()
	//altura um pouco menor
	aSize[6] *= .60
	aSize[4] *= .60
	//e largura um pouco menor
	aSize[5] *= .65
	aSize[3] *= .65

	aObjects := {}
	aAdd( aObjects, { 100, 100, .T., .T., .T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.,.T.)

	Define MsDialog oDlg Title 'Selecione fornecedores para enviar a cota��o [' + cNumeroCotacao + ']' From 0,0 to aSize[6],aSize[5] Pixel

	@ aPosObj[1][1],aPosObj[1][2] ListBox oList Fields Header "  ",;
		"Fornecedor",;
		"Loja",;
		"Raz�o Social",;
		"E-mail",;
		"Enviado em";
		Size aPosObj[1][3],aPosObj[1][4]-25 Of oDlg Pixel

	//seta os dados
	oList:SetArray(aFornecedor)
	//defini�o das colunas
	oList:bLine := {||{;
		IIF(aFornecedor[oList:nAt][1],oOk,oNo),;
		aFornecedor[oList:nAt][2],;
		aFornecedor[oList:nAt][3],;
		aFornecedor[oList:nAt][4],;
		aFornecedor[oList:nAt][5],;
		aFornecedor[oList:nAt][6]}}

	oList:bLDblClick := {|| aFornecedor[oList:nAt][1] := !aFornecedor[oList:nAt][1]}

	@ aPosObj[1][4]-15,aPosObj[1][2]+10 CheckBox lRecebeCopia prompt 'Desejo receber um c�pia dos e-mails enviado ao Fornecedor' size 160,08 of oDlg Pixel
	@ aPosObj[1][4]-17,aPosObj[1][2]+170 MsGet cMyEmail Size 150,7 Pixel

	Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg, {|| lOk:= .T., oDlg:End()} , {||oDlg:End()})

	IF lOk
		cMyEmail := IIF(lRecebeCopia,alltrim(cMyEmail),"")
		MsgRun( "Processando envio de e-mails para Fornecedores...", "Aguarde", { || ;
			EnviaEmails(cNumeroCotacao,aFornecedor,cMyEmail) })
	EndIF

	RestArea1(aArea)

Return

/*/{Protheus.doc} EnviaEmails
    Corre todos os registros da SC8 para enviar p e-mail 
    @type  Function
    @author Lucas Jose Correa Chagas
    @since  17/05/2013
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function EnviaEmails(cNumeroCotacao, aFornecedor, cComCopia)

	Local aRet    := {}
	Local cTitulo := 'Workflow - Gera��o de E-mail de Envio'
	Local cSubTit := ''
	Local cMsg    := ''
	Local cHomFor := ''
	Local nI      := 0
	Local n1	  := 0
	Local aProdVenc := {}
	Local lEnvia  := .F.

	Private aEmails 	:= {}
	Private aEmailsVenc := {}

	For  n1 := 1 to Len(aFornecedor)
		
		aProdVenc := {}
		
		IF aFornecedor[n1][1]

			SA2->( dbSetOrder(1) )
			SA2->( dbSeek( xFilial("SA2") + aFornecedor[n1][2]+aFornecedor[n1][3] ) )

			SC8->( dbSetOrder(1) )
			SC8->( dbSeek( xFilial("SC8") + cNumeroCotacao + SA2->(A2_COD+A2_LOJA) ) )

			While SC8->(!EOF()) .AND. SC8->(C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA) ==;
					xFilial("SC8") + cNumeroCotacao + SA2->(A2_COD+A2_LOJA)

				//If( SC8->C8_XHOMFOR != cHomFor )
				cHomFor := SC8->C8_XHOMFOR
				//Willian Kaneta - Verifica se fornecedor possui Hologa��o Qu�mico
				If !Empty(cHomFor)
					//Fornecedores OK e Aptos(Homologacao Vencida, mas dentro do prazo parametro TCP_DIASHM)
					If( cHomFor == "OK" .OR. cHomFor == "AP" )
						//monta os emails
						lEnvia := .T.
						//Fornecedores com homologa��o vencida
					ElseIf ( cHomFor == "VE" .Or. cHomFor == "NH" )
						//monta os emails
						aAdd(aProdVenc,SC8->C8_PRODUTO)
					EndIf
				ElseIf Empty(cHomFor)
					//monta os emails
					lEnvia := .T.
				EndIf
				//EndIf
				SC8->(DbSkip())
			EndDo
			
			SC8->( dbSetOrder(1) )
			SC8->( dbSeek( xFilial("SC8") + cNumeroCotacao + SA2->(A2_COD+A2_LOJA) ) )

			If( lEnvia )
				MontaEmails(cComCopia)
			EndIf

			If( Len(aProdVenc) > 0 )
				EmailsVenc(cComCopia,aProdVenc)
			EndIf
		EndIF

	Next n1

	If Len(aEmails) > 0

		aRet := U_MCOM002(aClone(aEmails),1)

		// verifica o retorno da informa��o
		IF Len(aRet) > 0
			cMsg := ''
			For nI := 1 to Len(aRet)
				IF aRet[nI,1]
					SC8->( dbSetOrder(1) )
					SC8->( dbSeek( xFilial("SC8") + cNumeroCotacao + aRet[nI,2] ) )
					IF SC8->( Found() )
						RecLock('SC8',.F.)
						SC8->C8_DTENV := dDataBase
						SC8->(dbUnlock())
					EndIF
				Else
					cMsg += 'E-mail para o fornecedor ' + aRet[nI,2] + ' n�o enviado. Observa��es: ' + CRLF
					If Len(aRet[nI]) >= 3
						cMsg += aRet[nI,3] + CRLF
					Else
						cMsg += "INDETERMINADO" + CRLF
					EndIf
				EndIF
			Next nI

			IF !Empty(cMsg)
				cSubTit := 'E-mails n�o enviados'
				Aviso( cTitulo, cMsg, { "Ok" }, 2, cSubTit, 1, , .F.)
			EndIF
		EndIF
	endif

	//Envia email para fornecedor com homologa��o produto quimico vencida
	If Len(aEmailsVenc) > 0

		aRet := U_MCOM002(aClone(aEmailsVenc))

		// verifica o retorno da informa��o
		IF Len(aRet) > 0
			cMsg := ''
			For nI := 1 to Len(aRet)
				IF aRet[nI,1]
					SC8->( dbSetOrder(1) )
					SC8->( dbSeek( xFilial("SC8") + cNumeroCotacao + aRet[nI,2] ) )
					IF SC8->( Found() )
						RecLock('SC8',.F.)
						SC8->C8_DTENV := dDataBase
						SC8->(dbUnlock())
					EndIF
				Else
					cMsg += 'E-mail para o fornecedor ' + aRet[nI,2] + ' n�o enviado. Observa��es: ' + CRLF
					If Len(aRet[nI]) >= 3
						cMsg += aRet[nI,3] + CRLF
					Else
						cMsg += "INDETERMINADO" + CRLF
					EndIf
				EndIF
			Next nI

			IF !Empty(cMsg)
				cSubTit := 'E-mails n�o enviados'
				Aviso( cTitulo, cMsg, { "Ok" }, 2, cSubTit, 1, , .F.)
			EndIF
		EndIF
	EndIf

	If Len(aEmails) == 0 .AND. Len(aEmailsVenc)
		cSubTit := 'Fornecedores n�o selecionados'
		cMsg    := "Nenhum fornecedor selecionado para envio!"
		Aviso( cTitulo, cMsg, { "Ok" }, 2, cSubTit, 1, , .F.)
	EndIf

Return

/*/{Protheus.doc} MontaEmails
Monta dados para envio de e-mail   
@type  Function
@author Lucas Jose Correa Chagas
@since  17/05/2013
@version 1.0
@return Nil
@example
(examples)
@see (links_or_references)
/*/
Static Function MontaEmails(cComCopia)

	Local aArea	  := SC8->( GetArea() )	
	Local cHtml   := ''
	Local cHttp   := SuperGetMV("TCP_HTTP" , .F., '')
	Local cTitulo := 'Workflow - Gera��o de E-mail de Envio'
	Local cSubTit := ''
	Local cMsg    := ''
	Local cId     := ''
	//Local cDescPro:= POSICIONE("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")

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
				cId := u_Encripta(cId)
				//Conout(cId)
				cHttp += cId

				if (Empty(SC8->C8_NUMSC))
					cHtml := MontaLayout( SA2->A2_EST != 'EX', Nil, cHttp  )
				else
					SC1->(dbGoTop())
					if SC1->(dbSeek(xFilial('SC1') + SC8->C8_NUMSC + SC8->C8_ITEMSC))
						cHtml := MontaLayout( SA2->A2_EST != 'EX', SC1->C1_CODCOMP, cHttp )
					else
						cHtml := MontaLayout( SA2->A2_EST != 'EX', Nil, cHttp )
					endif
				endif

				cMail := SA2->A2_EMAIL

				if (SA2->A2_EST != 'EX')
					cAssunto := "Cota��o de Produtos - " + SM0->M0_NOME
				else
					cAssunto := "Listing of Products - " + SM0->M0_NOME
				endif

				aAdd(aEmails,{cMail, cComCopia, cAssunto, cHtml, SC8->C8_FORNECE + SC8->C8_LOJA})
			endif
		endif
	endif

	RestArea( aArea )

return

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
Static Function EmailsVenc(cComCopia,aProdutos)

	Local aArea	  := SC8->( GetArea() )
	Local cHtml   := ''
	Local cHttp   := SuperGetMV("TCP_HTTP" , .F., '')
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
					cHtml := LayoutVenc( SA2->A2_EST != 'EX', Nil, cHttp, aProdutos )
				else
					SC1->(dbGoTop())
					if SC1->(dbSeek(xFilial('SC1') + SC8->C8_NUMSC + SC8->C8_ITEMSC))
						cHtml := LayoutVenc( SA2->A2_EST != 'EX', SC1->C1_CODCOMP, cHttp ,aProdutos )
					else
						cHtml := LayoutVenc( SA2->A2_EST != 'EX', Nil, cHttp, aProdutos )
					endif
				endif

				cMail := SA2->A2_EMAIL

				if (SA2->A2_EST != 'EX')
					//cAssunto := "Cota��o de Produtos - " + SM0->M0_NOME
					cAssunto := "Homologa��o Vencida"
				else
					cAssunto := "Supplier Not Approved - " + SM0->M0_NOME
				endif

				If !Empty(cMailCmp)
					cComCopia := cComCopia+";"+cMailCmp
				EndIf 
				aAdd(aEmailsVenc,{cMail, cComCopia, cAssunto, cHtml, SC8->C8_FORNECE + SC8->C8_LOJA})
			endif
		endif
	endif

	RestArea( aArea )

return

/*/{Protheus.doc} MontaLayout
Monta corpo do e-mail   
@type  Function
@author Lucas Jose Correa Chagas
@since  17/05/2013
@version 1.0
@return cHtml - Corpo Email
@example
(examples)
@see (links_or_references)
/*/
Static Function MontaLayout( lNacional, cY1Cod, cHttp )

	Local cHtml      := ''
	Local cComprador := '		<p></p>' + CRLF
	Local oHtml      := TWFHtml():New("\WORKFLOW\HTML\MAILNOTIFLISTING.html")

	Default aProdutos:= {}

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
		cHtml += '		<p> Sr.(a) '+Alltrim(SA2->A2_NOME)+', '+ CRLF
		cHtml += '		<p> Solicitamos or�amento, <a href="' + cHttp + '" target="_blank">clique aqui para preenchimento da cota��o n.� ' + AllTrim(SC8->C8_NUM) + '</a>. </p>' + CRLF
		cHtml += '		<p></p>' + CRLF
		/*If cHomFor == "AP"
			cHtml += '<p>Prezado fornecedor,</p>' + CRLF
			cHtml += '<p align="justify">Informamos que, devido ao vencimento de um documento requerido, <b>sua homologa��o '
			cHtml += 'no sistema da TCP est� vencida</b>. Conforme previsto em nosso sistema de homologa��o, '
			cHtml += 'a sua empresa tem o prazo de 90 dias para envio da documenta��o atualizada e se '
			cHtml += 'manter ativa para fornecimento de produtos e/ou servi�os para TCP. Caso n�o seja '
			cHtml += 'realizada a regulariza��o no prazo informado, a homologa��o da sua empresa estar� '
			cHtml += 'suspensa e ser� bloqueado o fornecimento de produtos e/ou servi�os para a TCP.</p>' 	+ CRLF
			cHtml += '<p>Por favor, encaminhar os documentos atualizados para o e-mail sga@tcp.com.br.</p>' + CRLF
		Else*/
			cHtml += '		<p>' + CRLF
			cHtml += '		</p>' + CRLF
		//EndIf
		//If( cHomFor <> "AP" )
		//	cHtml += '		<p>Produto(s):</p>' + CRLF
		//	cHtml += '		<p>-'+Alltrim(cProduto)+"-"+Alltrim(cDescPro)+'</p>' + CRLF
		//EndIf
		cHtml += '		<p style="font-weight:bold;">Observa��o:</p>' + CRLF
		cHtml += '		<p>Nosso CNPJ: ' +AllTrim(Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"))+ '</p>' + CRLF
		cHtml += '		<p>Inscri��o Estadual: ISENTO</p>' + CRLF
		cHtml += '		<p></p>' + CRLF
		cHtml += '		<p>D�vidas entrar em contato.</p>' + CRLF
		cHtml += '		<p></p>' + CRLF
		cHtml += '		<p>TCP - Terminal de Cont�ineres de Paranagu� S.A.</p>' + CRLF
		cHtml += '		<p>Conhe�a o TCP, acesso nosso site: ' + CRLF
		cHtml += '			<span>' + CRLF
		cHtml += '				<a href="http://www.tcp.com.br" target="_blank">www.tcp.com.br</a>' + CRLF
		cHtml += '			</span>' + CRLF
		cHtml += '		</p>' + CRLF
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
		cHtml += '		<p> Messr. (the) '+Alltrim(SA2->A2_NOME)+',</p>' + CRLF
		cHtml += '		<p> Budget request, <a href="' + cHttp + '" target="_blank">click here to fill the quotation n. � ' + AllTrim(SC8->C8_NUM) + '</a>. </p>' + CRLF
		cHtml += '		<p></p>' + CRLF
		If cHomFor == "AP"
			cHtml += '<p>Messrs. (the) supplier,</p>' + CRLF
			cHtml += '<p align="justify">We inform that, due to the maturity of a required document, <b>its homologation '
			cHtml += 'in the TCP system is expired.</b> As provided for in our homologation system, '
			cHtml += 'your company has 90 days to send updated documentation and if '
			cHtml += 'keep active to supply products and / or services to TCP. If it is not '
			cHtml += 'regularization is carried out within the informed period, the homologation of your company will be '
			cHtml += 'suspended and the supply of products and / or services to TCP will be blocked.</p>' 	+ CRLF
			cHtml += '<p>Please forward the updated documents to the email sga@tcp.com.br.</p>' + CRLF
		Else
			cHtml += '		<p>' + CRLF
			cHtml += '		</p>' + CRLF
		EndIf
		//If( cHomFor <> "AP" )
		//	cHtml += '		<p>Product:</p>' + CRLF
		//	cHtml += '		<p>-'+Alltrim(cProduto)+"-"+Alltrim(cDescPro)+'</p>' + CRLF
		//EndIf
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
Static Function LayoutVenc( lNacional, cY1Cod, cHttp , aProdutos )

	Local cHtml      := ''
	Local cComprador := '		<p></p>' + CRLF
	Local oHtml      := TWFHtml():New("\WORKFLOW\HTML\MAILNOTIFLISTING.html")
	Local i			 := 0

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

	//Homologa��o Vencida
	If SC8->C8_XHOMFOR != "NH"
		if (lNacional)
			cHtml += '		<p> Prezado(a) fornecedor(a) '+Alltrim(SA2->A2_NOME)+',' + CRLF
			cHtml += '		<p align="justify"><b>A homologa��o de sua empresa encontra-se suspensa</b>, pois o prazo de 90 dias '
			cHtml +=			'para regulariza��o foi ultrapassado. Dessa forma sua empresa est� impossibilitada '
			cHtml +=			'de fornecer produtos qu�micos e/ou perigosos e servi�os para a TCP at� o envio de todos os documentos '
			cHtml +=			'atualizados.' + CRLF + CRLF
			cHtml += '		<p>Por favor, encaminhar documentos atualizados para o e-mail sga@tcp.com.br.</p>' + CRLF
			cHtml += '		<p>Produto(s):</p>' + CRLF
			For i := 1 to len(aProdutos)
				cDescPro := POSICIONE("SB1",1,xFilial("SB1")+aProdutos[i],"B1_DESC")
				cHtml += '		<p>-'+Alltrim(aProdutos[i])+"-"+Alltrim(cDescPro)+'</p>' + CRLF
			Next i
			cHtml += cComprador
			cHtml += '		<p>(N�o responder este e-mail.)</p>' + CRLF
			cHtml += '<BR> <BR> '
		Else
			cHtml += '		<p> Messrs. (the) '+Alltrim(SA2->A2_NOME)+',</p>' + CRLF
			cHtml += '		<p align="justify"> <b>Your company homologation is suspended</b>, as the 90-day period for regularization'
			cHtml +=			"has been exceeded. Thus, your company is unable to provide products and / or services "
			cHtml +=			"to TCP until the sending of all updated documents. </p>" + CRLF + CRLF
			cHtml += '		<p>Por favor, encaminhar documentos atualizados para o e-mail sga@tcp.com.br.</p>' + CRLF
			cHtml += '		<p>Product:</p>' + CRLF
			For i := 1 to len(aProdutos)
				cDescPro := POSICIONE("SB1",1,xFilial("SB1")+aProdutos[i],"B1_DESC")
				cHtml += '		<p>-'+Alltrim(aProdutos[i])+"-"+Alltrim(cDescPro)+'</p>' + CRLF
			Next i
			cHtml += cComprador
			cHtml += '		<p>(Do not respond this e-mail.)</p>' + CRLF
		Endif

	//Homologa��o Fornecedores SEM OS DADOS cadastradps da homologa��o SA2
	ElseIf SC8->C8_XHOMFOR == "NH"
		if (lNacional)
			cHtml += '		<p> Prezado(a) fornecedor(a) '+Alltrim(SA2->A2_NOME)+',' + CRLF
			cHtml += '		<p align="justify"><b>Sua empresa n�o est� homologada junto ao TCP, para fornecer '
			cHtml +=			'produtos qu�micos.</b> Por favor, entre em contato com o setor ambiental atrav�s do e-mail '
			cHtml +=			'sga@tcp.com.br e solicite a rela��o de documentos necess�rios. '+ CRLF + CRLF
			cHtml += '		<p>Produto(s):</p>' + CRLF
			For i := 1 to len(aProdutos)
				cDescPro := POSICIONE("SB1",1,xFilial("SB1")+aProdutos[i],"B1_DESC")
				cHtml += '		<p>-'+Alltrim(aProdutos[i])+"-"+Alltrim(cDescPro)+'</p>' + CRLF
			Next i
			cHtml += cComprador
			cHtml += '		<p>(N�o responder este e-mail.)</p>' + CRLF
			cHtml += '<BR> <BR> '
		Else
			cHtml += '		<p> Messrs. (the) '+Alltrim(SA2->A2_NOME)+',</p>' + CRLF
			cHtml += '		<p align="justify"> <b>Your company is not approved by TCP to supply chemicals. </b>'
			cHtml +=			"Please contact the environmental sector by e-mail sga@tcp.com.br "
			cHtml +=			"and request the list of necessary documents.</p>" + CRLF + CRLF
			cHtml += '		<p>Product:</p>' + CRLF
			For i := 1 to len(aProdutos)
				cDescPro := POSICIONE("SB1",1,xFilial("SB1")+aProdutos[i],"B1_DESC")
				cHtml += '		<p>-'+Alltrim(aProdutos[i])+"-"+Alltrim(cDescPro)+'</p>' + CRLF
			Next i
			cHtml += cComprador
			cHtml += '		<p>(Do not respond this e-mail.)</p>' + CRLF
		Endif	
	Endif

	If lNacional
		oHtml:ValByName("HEADER","Cota��o de Produtos")
	Else
		oHtml:ValByName("HEADER","Listing of Products")
	Endif

	oHtml:ValByName("BODY",cHtml)
	cHtml := oHtml:HtmlCode()

Return cHtml

/*/{Protheus.doc} GetFornecedores
    Retorna dados Fornecedores   
    @type  Function
    @author Lucas Jose Correa Chagas
    @since  17/05/2013
    @version 1.0
    @return aFornecedor - Dados Fornecedores
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GetFornecedores(cCotacao)

	Local cAlias := GetNextAlias()
	Local aFornecedor := {}

	BeginSQL Alias cAlias
		%noparser%

		column C8_DTENV as Date

		select
			SC8.C8_FORNECE,
			SC8.C8_LOJA,
			SA2.A2_NOME,
			SA2.A2_EMAIL,
			max(SC8.C8_DTENV) as C8_DTENV

		from %table:SC8% SC8

			inner join %table:SA2% SA2 ON
				SA2.A2_FILIAL = %xFilial:SA2%
				AND SA2.A2_COD = SC8.C8_FORNECE
				AND SA2.A2_LOJA = SC8.C8_LOJA
				AND SA2.%NotDel%
		where
		SC8.C8_FILIAL  = %xFilial:SC8%
		AND SC8.C8_NUM     = %EXP:cCotacao%
		AND SC8.D_E_L_E_T_ = ' '

		group by
			SC8.C8_FORNECE,
			SC8.C8_LOJA,
			SA2.A2_NOME,
			SA2.A2_EMAIL

		order by
		SC8.C8_FORNECE, SC8.C8_LOJA
	EndSQL

	While !(cAlias)->( Eof() )
		aAdd(aFornecedor,{(cAlias)->C8_DTENV==CtoD("//"),;
			(cAlias)->C8_FORNECE,;
			(cAlias)->C8_LOJA,;
			(cAlias)->A2_NOME,;
			(cAlias)->A2_EMAIL,;
			(cAlias)->C8_DTENV})

		(cAlias)->( dbSkip() )
	EndDO

Return aFornecedor

/*/{Protheus.doc} Encripta
    Encripta chave
    @type  Function
    @author Lucas Jose Correa Chagas
    @since  17/05/2013
    @version 1.0
    @return cChave - Chave criptografada 
    @example
    (examples)
    @see (links_or_references)
/*/
User Function Encripta(cChave)
	Local cEmb := SubStr("06408770258432adsf8zcv1003o964422777i0o1zcv61857w3s2fdsli38920mjklo02700062s8654oz1559vil083t0fdj8rf661324kjkj52005on350czz017fu7631u56f3b210409m090502683541",1,Randomize(100, 158))
	Local nVezes := Randomize(1, 100)
	Local nX
	For nX := 1 To nVezes
		cEmb := Embaralha(cEmb, 0)
	Next nX
	//troca espa�os por _
	cChave := StrTran(cChave, " ", "_")+"starthere"+cEmb
	For nX := 1 to 10
		cChave := Embaralha(cChave, 0)
	Next nX
Return cChave

/*/{Protheus.doc} Decripta
    Decripta chave
    @type  Function
    @author Lucas Jose Correa Chagas
    @since  17/05/2013
    @version 1.0
    @return cChave - Chave criptografada 
    @example
    (examples)
    @see (links_or_references)
/*/
User Function Decripta(cChave)
	Local nX
	For nX := 1 to 10
		cChave := Embaralha(cChave, 1)
	Next nX
	//troca espa�os por _
	cChave := StrTran(cChave, "_", " ")
	//tira o texto adicional
	cChave := SubStr(cChave,1,at("starthere",cChave)-1)
Return cChave
