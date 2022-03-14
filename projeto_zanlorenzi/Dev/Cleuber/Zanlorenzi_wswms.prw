#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//-------------------------------------------------------------------------------------------------------------------------------------------------
WSRESTFUL wscyberlog DESCRIPTION "API Rest de Integracao com WMS CyberLog - Pedidos de Vendas" 
	WSData json_dados	As String

	WSMethod POST	RecebePedidoVendas	DESCRIPTION "Metodo POST para receber o Retorno do Pedido de Venda" 		PATH '/rest/wscyberlog/RecebePedidoVendas'	WSSYNTAX "/rest/wscyberlog/RecebePedidoVendas/{JSON}"
	WSMethod POST	RecNota				DESCRIPTION "Metodo POST para receber o Retorno da Pre-Nota de Entrada" 	PATH '/rest/wscyberlog/RecNota' 			WSSYNTAX "/rest/wscyberlog/RecNota/{JSON}"
	WSMethod POST	RecMInterno			DESCRIPTION "Metodo POST para receber o Retorno da Movimentacao Interna" 	PATH '/rest/wscyberlog/RecMInterno' 		WSSYNTAX "/rest/wscyberlog/RecMInterno/{JSON}"
	WSMethod POST	RecInvent			DESCRIPTION "Metodo POST para receber o Inventario " 						PATH '/rest/wscyberlog/RecInvent'			WSSYNTAX "/rest/wscyberlog/RecInvent/{JSON}"

END WSRESTFUL

//-------------------------------------------------------------------------------------------------------------------------------------------------
WSMethod POST RecebePedidoVendas WSReceive json_dados WSService wscyberlog

Local aSaldoLib	:= {}
Local aSaldos	:= {}
Local aVldSC9	:= {}
Local aAuto		:= {}
Local aLinha	:= {}
Local aOK		:= {}
Local cEndERP	:= padr(SuperGetMV("FZ_XENDERP"), tamsx3('D3_LOCALIZ')[1])
Local cEndWMS	:= padr(SuperGetMV("FZ_XENDWMS"), tamsx3('D3_LOCALIZ')[1])
Local cJson 	:= self:getContent()
Local cAlmox	:= ''
Local cChvPedido:= ''
Local cNumPedido:= ''
Local cItePedido:= ''
Local cProduto	:= ''
Local cErpID	:= ''
Local cSeqItem	:= ''
Local cLocaliz	:= ''
Local dDtVald	:= ''
Local cMsg		:= ''
Local cMsgPnl	:= ''
Local cDocumen	:= ''
Local nQtdSC9	:= 0
Local nQtdTot	:= 0
Local nQtd		:= 0
Local nSaldo	:= 0

Local lRet		:= .T.
Local lRastro	:= .F.
Local oJson		:= Nil 
Local nX1
Local nX2
Local nX3
Local nX4
Local nX5

Private lWSCyberLog:= .T.


/*TAGs do Retorno do Pedido
oJSON:ErpID
oJSON:operacao
oJSON:empresa
oJSON:noPedido
oJSON:documento
oJSON:serie
oJSON:data
oJSON:avaria
oJSON:noCliente
oJSON:clienteErpId
oJSON:nomeCliente
oJSON:prioridade
oJSON:tipopedido			
oJSON:observacao
oJSON:noRota
oJSON:descRota
oJSON:docasConsolidacao
oJSON:equipe
oJSON:faturado
oJSON:notafiscal
oJSON:clienteRetira
oJSON:dataEntrega
oJSON:dataInsert
oJSON:loteInformado
ItensPedido->	oJSON:itensPedido[nX]:operacao
				oJSON:itensPedido[nX]:codigoReduzido
				oJSON:itensPedido[nX]:quantidade
				oJSON:itensPedido[nX]:qtdAvaria
				oJSON:itensPedido[nX]:produtoCliente
				oJSON:itensPedido[nX]:observacao
				oJSON:itensPedido[nX]:sequenciaErp			
				oJSON:itensPedido[nX]:noLayout
				loteItensPedido-> 	oJSON:itensPedido[nX]:loteItensPedido[nY]:quantidade
									oJSON:itensPedido[nX]:loteItensPedido[nY]:qtdAvaria
									oJSON:itensPedido[nX]:loteItensPedido[nY]:noLote
									oJSON:itensPedido[nX]:loteItensPedido[nY]:validadeLote
									oJSON:itensPedido[nX]:loteItensPedido[nY]:datafabricacao
oJSON:volumes
oJSON:vinculo
oJSON:representante
*/

::SetContentType("application/json")	
	
If !FWJsonDeserialize(cJson, @oJSON)
	cMsg:= 'Ocorreu erro no processamento do JSON.'
	lRet := .F.
Else

	cOperacao := oJSON:OPERACAO

	If cOperacao != "RETURN"
		cMsg:= 'Operacao de retorno nao e valida para retorno do Pedido no Protheus'	
		lRet:= .F.
	Else

		cChvPedido	:= alltrim(oJSON:ERPID)
		cNumPedido	:= padr(substr(cChvPedido, TamSX3("C9_FILIAL")[1]+1 	, TamSX3("C9_PEDIDO")[1]) ,  TamSX3("C5_NUM")[1])

		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))
		If ! SC5->(dbSeek(FWxFilial("SC5")+cNumPedido,.T. ))
			cMsg:= 'Pedido Nr. ' + cNumPedido + ' nao encontrado no Protheus.'
			lRet := .F.
		EndIf			

		If lRet
			If SC5->(C5_CLIENTE+C5_LOJACLI) <> alltrim(oJSON:clienteErpId)
				cMsg:= 'Pedido Nr. ' + cNumPedido + ' Codigo do Cliente retornado e diferente do gravado no pedido.'
				lRet := .F.
			Endif
		Endif

/* 		If lRet .and. Type(oJSON:itensPedido) == "U"
			cMsg:= 'Pedido nao contem itens para serem atualizados.'
			lRet := .F.
		Endif */
		
		If Empty(oJSON:VOLUMES) .or. upper(alltrim(oJSON:VOLUMES)) == "NULL" .or. oJSON:VOLUMES== 0
			cMsg:= 'Quantidade de volumes em branco ou zerado.'
			lRet := .F.
		Endif

		If lRet

			nVolumes	:= oJSON:VOLUMES

			For nX1:=1 to len(oJSON:itensPedido)

				cErpID	:= oJSON:itensPedido[nX1]:erpID

				cSeqItem	:= substr(cErpID, TamSX3("C9_FILIAL")[1]+TamSX3("C9_PEDIDO")[1]+1												, TamSX3("C9_SEQUEN")[1])
				cItePedido	:= substr(cErpID, TamSX3("C9_FILIAL")[1]+TamSX3("C9_PEDIDO")[1]+TamSX3("C9_SEQUEN")[1]+1						, TamSX3("C9_ITEM")[1])
				cProduto	:= padr(substr(cErpID, TamSX3("C9_FILIAL")[1]+TamSX3("C9_PEDIDO")[1]+TamSX3("C9_SEQUEN")[1]+TamSX3("C9_ITEM")[1]+1	, len(cErpID)), TamSX3("B1_COD")[1])

				nSaldo	:= 0
				aSaldos	:= {}
				aSaldoLib:= {}

				If alltrim(oJSON:itensPedido[nX1]:operacao) != "RETURN"
					cMsg:= 'Item '+ cItePedido +' Produto '+ cProduto + ' do Pedido Nr. ' + cNumPedido + ' operacao de retornonao e valida .'
					lRet:= .F.
					Exit
				Endif										

				dbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				If ! SB1->(dbSeek(FWxFilial("SB1")+cProduto,.T.))
					cMsg:= 'Produto '+ cProduto + ' do Pedido Nr. ' + cNumPedido + ' nao existe no cadastro do Protheus.'
					lRet:= .F.
					Exit
				Endif

				lRastro:= SB1->B1_RASTRO == 'L'

/* 				If lRastro .and. Type(oJSON:itensPedido[nX1]:loteItensPedido) == "U"
					cMsg:= 'Produto '+ cProduto + ' do Pedido Nr. ' + cNumPedido + ' controle lote. Nao foi Informado Lote no retorno.'
					lRet := .F.
					exit
				Endif */

				//Posiciona na SC9 e faz as validacões iniciais da Liberacao
				dbSelectArea("SC9")
				SC9->(dbSetOrder(1))
				If ! SC9->(dbSeek(cErpID,.T. ))
					cMsg:= 'Item '+ cItePedido +' Produto '+ cProduto + ' do Pedido Nr. ' + cNumPedido + ' nao encontrado na liberacao do Pedido no Protheus.'
					lRet := .F.
					exit
				Endif

				aVldSC9:= fVldSC9()
				If ! aVldSC9[1]
					lRet:= aVldSC9[1]
					cMsg:= aVldSC9[2]
					exit
				Endif

				nQtdSC9:= SC9->C9_QTDLIB
				cMsgPnl:= SC9->C9_XMSGWMS + CRLF

				dbSelectArea("SC6")
				SC6->(dbSetOrder(1))
				If ! SC6->(dbSeek(FWxFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO))
					cMsg:= 'Item '+ cItePedido +' Produto '+ cProduto + ' do Pedido Nr. ' + cNumPedido + ' nao encontrado na  liberacao do Pedido no Protheus.'
					lRet := .F.
					exit
				Endif

				If !Empty(SC6->C6_NOTA)
					cMsg:= 'Item '+ cItePedido +' Produto '+ cProduto + ' do Pedido Nr. ' + cNumPedido + ' jc faturado na NOta Fiscal Nr ' + SC6->C6_NOTA
					lRet := .F.
					exit
				Endif

				cAlmox:= SC6->C6_LOCAL

				If SC5->C5_TIPO $ "DB"
					dbSelectArea("SA2")
					SA2->(dbSetOrder(1))
					SA2->(dbSeek(FWxFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.T.))
				Else
					dbSelectArea("SA1")
					SA1->(dbSetOrder(1))
					SA1->(dbSeek(FWxFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.T.))
				EndIf

				dbSelectArea("SB2")
				SB2->(dbSetOrder(1))
				SB2->(dbSeek(FWxFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL,.T.))

				dbSelectArea("NNR")
				NNR->(dbSetOrder(1))
				NNR->(dbSeek(FWxFilial("NNR")+SC6->C6_LOCAL,.T.))

				dbSelectArea("SM2")
				SM2->(dbSetOrder(1))
				SM2->(dbSeek(dDataBase,.T.))

				DbSelectArea("ZA7") //<-- Tabela de Controle de Envio EDI Transportadoras
				ZA7->(DbSetOrder(3))
				If ! ZA7->(dbSeek(FWxFilial("ZA7")+SC9->C9_PEDIDO+SC9->C9_ITEM,.T.))
					cMsg:= 'Item '+ cItePedido +' Produto '+ cProduto + ' do Pedido Nr. ' + cNumPedido + ' nao foi encontrado na Liberacao EDI da transportadora. Favor verificar com a Logistica.'
					lRet := .F.
					exit				
				Endif

				If lRastro

					For nX2:=1 to len(oJSON:itensPedido[nX1]:loteItensPedido)

						nSaldo	:= 0
						nSldEnd := 0
						nQtd	:= oJSON:itensPedido[nX1]:loteItensPedido[nX2]:quantidade
						cLoteCtl:= padr(oJSON:itensPedido[nX1]:loteItensPedido[nX2]:nolote, TamSX3("D3_LOTECTL")[1])
						cLocaliz:= cEndWMS

						If Empty(cLoteCtl) //.or. Empty(dDtVald)
							cMsg:= 'Item '+ cItePedido +' Produto '+ cProduto + ' do Pedido Nr. ' + cNumPedido + ' controle lote. Lote igual a branco .'
							lRet := .F.
							exit
						Else
							dbSelectArea("SB8")
							SB8->(DbSetOrder(3))
							If SB8->(dbSeek(FWxFilial("SB8")+cProduto+cAlmox+cLoteCtl,.T.))
								dDtVald:= SB8->B8_DTVALID
								aSaldos:=SldPorLote(cProduto,cAlmox,nQtd,0,cLoteCtl,Nil,cLocaliz,SC6->C6_NUMSERI,NIL,NIL,NIL,(SuperGetMv('MV_LOTVENC')=='S'),,,dDataBase)

								For nX3:=1 to len(aSaldos)
									For nX4:=1 to len(aSaldos[nX3,10])
										nSaldo+= aSaldos[nX3,10,nX4,02]
									Next nX4
								Next nX3

								If nSaldo < nQtd
									cMsg:= 'Item '+ cItePedido +' Produto '+ cProduto + ' do Pedido Nr. ' + cNumPedido + ' saldo disponivel no protheus, nao atende a quantidade solicitada pelo WMS .'
									lRet := .F.
									exit									
								Endif

								nSldEnd:= SaldoSBF(cAlmox,cLocaliz,cProduto,SC6->C6_NUMSERI,cLoteCtl,SC6->C6_NUMLOTE)
								If nSldEnd < nQtd
									cMsg:= 'Item '+ cItePedido +' Produto '+ cProduto + ' do Pedido Nr. ' + cNumPedido + ' saldo disponivel no endereco ' + cLocaliz + ' protheus, nao atende a quantidade solicitada pelo WMS .'
									lRet := .F.
									exit									
								Endif								
								
								/*
								aSaldos[1][1] //Lote
								aSaldos[1][2] //Sub-Lote
								aSaldos[1][3] //Endereco
								aSaldos[1][4] //Numero Serie
								aSaldos[1][7] //Dt.Validade
								aSaldos[1][6] //Potencia
								aadd(aSaldos,{TRB->TRB_LOTECT,TRB->TRB_NUMLOT,Iif(!(lWmsNew .And. lInfoWms),TRB->TRB_LOCALI,''),TRB->TRB_NUMSER,TRB->TRB_QTDLIB,TRB->TRB_POTENC,TRB->TRB_DTVALI})
								*/

								aAdd( aSaldoLib , { cLoteCtl,; 	//Numero do Lote
													'',;		//Sub-Lote
													cLocaliz,;	//Endereco
													'',;		//Numero de Serie
													nQtd,;		//Qtd. Liberada
													0,;			//Potencia
													dDtVald})	//Dt Validade do Lote								

							Else
								cMsg:= 'Item '+ cItePedido +' Produto '+ cProduto + ' do Pedido Nr. ' + cNumPedido + ' Lote Informado ' + cLoteCtl + ' nao existe no sistema.'
								lRet := .F.
								exit
							Endif

						Endif

					Next nX2

				Else

					nSaldo	:= SaldoSB2(cProduto,cAlmox)
					nSldEnd := 0
					nQtd	:= oJSON:itensPedido[nX1]:quantidade
					cLoteCtl:= ''
					cLocaliz:= cEndWMS
					dDtVald	:= ctod("//")

					If nSaldo < nQtd
						cMsg:= 'Item '+ cItePedido +' Produto '+ cProduto + ' do Pedido Nr. ' + cNumPedido + ' saldo disponivel no protheus, nao atende a quantidade solicitada pelo WMS .'
						lRet := .F.
						exit									
					Endif

					nSldEnd:= SaldoSBF(cAlmox,cLocaliz,cProduto,SC6->C6_NUMSERI,SC6->C6_LOTECTL,SC6->C6_NUMLOTE)
					If nSldEnd < nQtd
						cMsg:= 'Item '+ cItePedido +' Produto '+ cProduto + ' do Pedido Nr. ' + cNumPedido + ' saldo disponivel no endereco ' + cLocaliz + ' protheus, nao atende a quantidade solicitada pelo WMS .'
						lRet := .F.
						exit									
					Endif								

					aAdd( aSaldoLib , { cLoteCtl,; 	//Numero do Lote
										'',;		//Sub-Lote
										cLocaliz,;	//Endereco
										'',;		//Numero de Serie
										nQtd,;		//Qtd. Liberada
										0,;			//Potencia
										dDtVald})	//Dt Validade do Lote								

				Endif

				If len(aSaldoLib) > 0

					cDocumen := GetSxeNum("SD3","D3_DOC")

					nQtdTot:= 0
					aAuto:= {}
					
					aadd(aAuto,{cDocumen,dDataBase}) //Cabecalho
					
					For nX5:=1 to len(aSaldoLib)
						nQtdTot+= aSaldoLib[nX5,05]

						//Origem
						aLinha:= {}
						aadd(aLinha,{"ITEM"		,'00'+cvaltochar(nX5)	, Nil})
						aadd(aLinha,{"D3_COD"		, SB1->B1_COD			, Nil}) //Cod Produto origem
						aadd(aLinha,{"D3_DESCRI"	, SB1->B1_DESC			, Nil}) //descr produto origem
						aadd(aLinha,{"D3_UM"		, SB1->B1_UM			, Nil}) //unidade medida origem
						aadd(aLinha,{"D3_LOCAL"	, SC6->C6_LOCAL			, Nil}) //armazem origem
						aadd(aLinha,{"D3_LOCALIZ"	, cEndWMS				, Nil}) //Informar endereÃ§o origem
						
						//Destino
						aadd(aLinha,{"D3_COD"		, SB1->B1_COD			, Nil}) //cod produto destino
						aadd(aLinha,{"D3_DESCRI"	, SB1->B1_DESC			, Nil}) //descr produto destino
						aadd(aLinha,{"D3_UM"		, SB1->B1_UM			, Nil}) //unidade medida destino
						aadd(aLinha,{"D3_LOCAL"	, SC6->C6_LOCAL			, Nil}) //armazem destino
						aadd(aLinha,{"D3_LOCALIZ"	, cEndERP				, Nil}) //Informar endereÃ§o destino
						
						aadd(aLinha,{"D3_NUMSERI"	, SC6->C6_NUMSERI		, Nil}) //Numero serie
						aadd(aLinha,{"D3_LOTECTL"	, aSaldoLib[nX5,01]		, Nil}) //Lote Origem
						aadd(aLinha,{"D3_NUMLOTE"	, SC6->C6_NUMLOTE		, Nil}) //sublote origem
						aadd(aLinha,{"D3_DTVALID"	, aSaldoLib[nX5,07]		, Nil}) //data validade
						aadd(aLinha,{"D3_POTENCI"	, 0						, Nil}) //Potencia
						aadd(aLinha,{"D3_QUANT"	, aSaldoLib[nX5,05]		, Nil}) //Quantidade
						aadd(aLinha,{"D3_QTSEGUM"	, 0						, Nil}) //Seg unidade medida
						aadd(aLinha,{"D3_ESTORNO"	, ""					, Nil}) //Estorno
						aadd(aLinha,{"D3_NUMSEQ" 	, ""					, Nil}) //Numero sequencia D3_NUMSEQ
						
						aadd(aLinha,{"D3_LOTECTL"	, aSaldoLib[nX5,01]		, Nil}) //Lote destino
						aadd(aLinha,{"D3_NUMLOTE"	, SC6->C6_NUMLOTE		, Nil}) //sublote destino
						aadd(aLinha,{"D3_DTVALID"	, aSaldoLib[nX5,07]		, Nil}) //validade lote destino
						aadd(aLinha,{"D3_ITEMGRD"	, ""					, Nil}) //Item Grade

						aAdd( aAuto, aLinha)

					Next nX5

					If nQtdTot != nQtdSC9
						cMsg:= 'Item '+ cItePedido +' Produto '+ cProduto + ' do Pedido Nr. ' + cNumPedido + ' a quantidade total retornada pelo WMS não bate com a quantidade total do item no pedido.'					
						lRet:= .F.
						Exit
					Else

						aOK:= U_fTrfERP(aAuto,3) //3=Inclusao 6=Estorno

						If aOK[1]
							RecLock("SC5",.F.)
							SC5->C5_VOLUME1:= nVolumes
							SC5->(MsUnlock())

							fLibPed(.F.,.T.,Nil,aSaldoLib,.T. ) //Efetua a Liberacao do Pedido

						Endif
						
					Endif
				Endif

			Next nX1

		Endif
	Endif

Endif

If lRet

	cMsg:= '{"Resultado": "T", "msg": "Recepcao com Sucesso" }'
		
	::SetResponse( cMsg )

	cJson+=CRLF+CRLF+ cMsg + CRLF

	RecLock("ZA7",.F.)
	ZA7->ZA7_STATUS:= '4' //Aguardando Faturamento
	ZA7->ZA7_DTWMS:= dDataBase
	ZA7->ZA7_HRWMS:= TIME()
	ZA7->(MsUnlock())

Else

	cMsgPnl+= "-----------------------------------------------------------------------------------------" + CRLF
	cMsgPnl+= "Data: "+dtoc(dDataBase) + " Hora: " + Time() + " Usuario Integração: " + __cUserId + "-" + upper(UsrRetName(__cUserId)) + CRLF


	cMsgPnl+= cMsg 

	SetRestFault(400, cMsg )

	cJson+=CRLF+CRLF+'{ "Resultado":"F", "msg":"' + cMsg + '"} '

	cMsgPnl+= CRLF 

	RecLock("SC9",.F.)
	SC9->C9_XSTAWMS:= "X" //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
	SC9->C9_XDTIWMS:= dDataBase
	SC9->C9_XHRIWMS:= Time()
	SC9->C9_XMSGWMS:= cMsgPnl
	SC9->(MsUnlock())

Endif

FreeObj(oJSON)

RecLock("ZA1",.T.)
ZA1->ZA1_FILIAL:= FWxFilial("ZA1")
ZA1->ZA1_STATUS:= iIf(lRet,"1","0")
ZA1->ZA1_NRTRAN:= U_fIDWmsErp()
ZA1->ZA1_TIPOTR:= "R"
ZA1->ZA1_ORIGEM:= "WS_PEDVEN"
ZA1->ZA1_DATATR:= date()
ZA1->ZA1_HORATR:= time()
ZA1->ZA1_USERTR:= 'CyberLog'//upper(UsrRetName(__cUserId))
ZA1->ZA1_JSON  := cJson
ZA1->ZA1_TPMOV := '5'
ZA1->(MsUnlock())

Return lRet

//-------------------------------------------------------------------------------------------------------------------------------------------------
WSMethod POST RecNota WSReceive json_dados WSService wscyberlog

Local cJson 	:= self:getContent()
Local cAlmox	:= ''
Local cChv		:= ''
Local cDoc		:= ''
Local cItemNF	:= ''
Local cProduto	:= ''
Local cErpID	:= ''
Local cMsg		:= ''
Local cMsgPnl	:= ''
Local nQtdSD1	:= ''
Local nQtd		:= 0

Local lRet		:= .T.
Local lRastro	:= .F.
Local oJson		:= Nil 
Local nX1
Local nX2

/*TAGs do Retorno Nota Fiscal
oJSON:operacao
oJSON:erpId
oJSON:empresa
oJSON:data
oJSON:documento
oJSON:codFornecedor
oJSON:avaria
oJSON:confCega
oJSON:tipo
oJSON:doca
oJSON:prioridade
oJSON:devolucao
itensRecebimento->	oJSON:itensRecebimento[nX]:codigoReduzido
					oJSON:itensRecebimento[nX]:erpId
					oJSON:itensRecebimento[nX]:quantidade
					oJSON:itensRecebimento[nX]:qtdAvaria
					oJSON:itensRecebimento[nX]:noLayout
					loteItensRecebimento-> 	oJSON:itensRecebimento[nX]:loteItensRecebimento[nY]:quantidade
											oJSON:itensRecebimento[nX]:loteItensRecebimento[nY]:qtdAvaria
											oJSON:itensRecebimento[nX]:loteItensRecebimento[nY]:lote
											oJSON:itensRecebimento[nX]:loteItensRecebimento[nY]:validade
											oJSON:itensRecebimento[nX]:loteItensRecebimento[nY]:fabricacao
*/

::SetContentType("application/json")	
	
If !FWJsonDeserialize(cJson, @oJSON)
	cMsg:= 'Ocorreu erro no processamento do JSON.'
	lRet := .F.
Else

	cOperacao := oJSON:OPERACAO

	If cOperacao != "RETURN"
		cMsg:= 'Operacao de retorno nao e valida para retorno do Pedido no Protheus'	
		lRet:= .F.
	Else

		cChv	:= alltrim(oJSON:ERPID)
		cDoc	:= padr(substr(cChv, TamSX3("D1_FILIAL")[1]+1 	, TamSX3("D1_DOC")[1]) ,  TamSX3("D1_DOC")[1])

		dbSelectArea("SD1")
		SD1->(dbSetOrder(1))
		If ! SD1->(dbSeek(cChv,.T. ))
			cMsg:= 'Nr. Doc ' + cDoc + ' nao encontrado no Protheus.'
			lRet := .F.
		EndIf			

/* 		If lRet .and. Type(oJSON:itensRecebimento) == "U"
			cMsg:= 'Documento nao contem itens para serem atualizados.'
			lRet := .F.
		Endif */
	
		If lRet

			For nX1:=1 to len(oJSON:itensRecebimento)

				cErpID	:= oJSON:itensRecebimento[nX1]:erpID

				cProduto	:= padr( substr(cErpID	, TamSX3("D1_FILIAL")[1]+TamSX3("D1_DOC")[1]+TamSX3("D1_SERIE")[1]+TamSX3("D1_FORNECE")[1]+TamSX3("D1_LOJA")[1]+1, TamSX3("D1_COD")[1] ), TamSX3("D1_COD")[1] )
				cItemNF		:= 		substr(cErpID	, TamSX3("D1_FILIAL")[1]+TamSX3("D1_DOC")[1]+TamSX3("D1_SERIE")[1]+TamSX3("D1_FORNECE")[1]+TamSX3("D1_LOJA")[1]+TamSX3("D1_COD")[1]+1, TamSX3("D1_ITEM")[1])
				
				dbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				If ! SB1->(dbSeek(FWxFilial("SB1")+cProduto,.T.))
					cMsg:= 'Produto '+ cProduto + ' do Pedido Nr. ' + cDoc + ' nao existe no cadastro do Protheus.'
					lRet:= .F.
					Exit
				Endif

				lRastro:= SB1->B1_RASTRO == 'L'

/* 				If lRastro .and. Type(oJSON:itensRecebimento[nX1]:loteItensRecebimento) == "U"
					cMsg:= 'Produto '+ cProduto + ' do Documento Nr. ' + cDoc + ' controle lote. Nao foi Informado Lote no retorno.'
					lRet := .F.
					exit
				Endif */

				nQtdSD1	:= SD1->D1_QUANT
				cMsgPnl	:= SD1->D1_XMSGWMS + CRLF
				cAlmox	:= SD1->D1_LOCAL

				If lRastro
					For nX2:=1 to len(oJSON:itensRecebimento[nX1]:loteItensRecebimento)

						nQtd	:= oJSON:itensRecebimento[nX1]:loteItensRecebimento[nX2]:quantidade
						cLoteCtl:= padr(oJSON:itensRecebimento[nX1]:loteItensRecebimento[nX2]:lote, TamSX3("D3_LOTECTL")[1])

						If Empty(cLoteCtl) 
							cMsg:= 'Item '+ cItemNF +' Produto '+ cProduto + ' do Pedido Nr. ' + cDoc + ' controle lote. Lote igual a branco .'
							lRet := .F.
							exit
						Else

							If nQtd != nQtdSD1
								cMsg:= 'Item '+ cItemNF +' Produto '+ cProduto + ' do Pedido Nr. ' + cDoc + ' quantidades de conferencia(s) diferente(s) da Pre-Nota .'
								lRet := .F.
								exit									
							Endif

						Endif

					Next nX2
				Else

					nQtd	:= oJSON:itensRecebimento[nX1]:loteItensRecebimento[nX2]:quantidade
					cLoteCtl:= padr(oJSON:itensRecebimento[nX1]:loteItensRecebimento[nX2]:lote, TamSX3("D3_LOTECTL")[1])

					If nQtd != nQtdSD1
						cMsg:= 'Item '+ cItemNF +' Produto '+ cProduto + ' do Pedido Nr. ' + cDoc + ' quantidades de conferencia(s) diferente(s) da Pre-Nota .'
						lRet := .F.
					Endif

				Endif

			Next nX1
		
		Endif

	Endif

Endif

If lRet

	cMsgPnl+= "-----------------------------------------------------------------------------------------" + CRLF
	cMsgPnl+= "Data: "+dtoc(dDataBase) + " Hora: " + Time() + " Usuario Integração: " + __cUserId + "-" + upper(UsrRetName(__cUserId)) + CRLF

	cMsg:= '{"Resultado": "T", "msg": "Recepcao com Sucesso" }'
		
	::SetResponse( cMsg )

	cJson+=CRLF+CRLF+ cMsg + CRLF

	cMsgPnl+= cMsg 

	RecLock("SD1",.F.)
	SD1->D1_XSTAWMS:= "O" //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
	SD1->D1_XDTIWMS:= dDataBase
	SD1->D1_ZHRIWMS:= Time()
	SD1->D1_XMSGWMS:= cMsgPnl
	SD1->(MsUnlock())

Else

	cMsgPnl+= "-----------------------------------------------------------------------------------------" + CRLF
	cMsgPnl+= "Data: "+dtoc(dDataBase) + " Hora: " + Time() + " Usuario Integração: " + __cUserId + "-" + upper(UsrRetName(__cUserId)) + CRLF

	cMsgPnl+= cMsg 

	SetRestFault(400, cMsg )

	cJson+=CRLF+CRLF+'{ "Resultado":"F", "msg":"' + cMsg + '"} '

	cMsgPnl+= CRLF 

	RecLock("SD1",.F.)
	SD1->D1_XSTAWMS:= "X" //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
	SD1->D1_XDTIWMS:= dDataBase
	SD1->D1_ZHRIWMS:= Time()
	SD1->D1_XMSGWMS:= cMsgPnl
	SD1->(MsUnlock())

Endif

FreeObj(oJSON)

RecLock("ZA1",.T.)
ZA1->ZA1_FILIAL:= FWxFilial("ZA1")
ZA1->ZA1_STATUS:= iIf(lRet,"1","0")
ZA1->ZA1_NRTRAN:= U_fIDWmsErp()
ZA1->ZA1_TIPOTR:= "R"
ZA1->ZA1_ORIGEM:= "WS_NOTAF"
ZA1->ZA1_DATATR:= date()
ZA1->ZA1_HORATR:= time()
ZA1->ZA1_USERTR:= 'CyberLog'//upper(UsrRetName(__cUserId))
ZA1->ZA1_JSON  := cJson
ZA1->ZA1_TPMOV := '6'
ZA1->(MsUnlock())

Return lRet


//-------------------------------------------------------------------------------------------------------------------------------------------------
WSMethod POST RecMInterno WSReceive json_dados WSService wscyberlog

Local aSaldoLib	:= {}
Local aSaldos	:= {}
Local aAuto		:= {}
Local aCab		:= {}
Local aLinha	:= {}
Local aOK		:= {}
Local cEndERP	:= padr(SuperGetMV("FZ_XENDERP"), tamsx3('D3_LOCALIZ')[1])
Local cEndWMS	:= padr(SuperGetMV("FZ_XENDWMS"), tamsx3('D3_LOCALIZ')[1])
Local cJson 	:= self:getContent()
Local cTipo		:= ''
Local cArmOri	:= ''
Local cArmDes	:= ''
Local cChv		:= ''
Local cNum		:= ''
Local cItem		:= ''
Local cProduto	:= ''
Local cErpID	:= ''
Local cLocaliz	:= ''
Local dDtVald	:= ''
Local cMsg		:= ''
Local cMsgPnl	:= ''
Local cDocumen	:= ''
Local nQtd		:= 0
Local nSaldo	:= 0

Local lRet		:= .T.
Local lRastro	:= .F.
Local oJson		:= Nil 
Local nX1
Local nX2
Local nX3
Local nX4
Local nX5

Private lWSCyberLog:= .T.

/*TAGs do Retorno da Movto interno
oJSON:operacao
oJSON:ErpID
oJSON:empresa
oJSON:noPedido
oJSON:tipo
oJSON:data
oJSON:requisitante
ItensMovimentacao->	oJSON:itensMovimentacao[nX]:codigoReduzido
					oJSON:itensMovimentacao[nX]:erpId
					oJSON:itensMovimentacao[nX]:quantidade
					oJSON:itensMovimentacao[nX]:qtdAvaria
					oJSON:itensMovimentacao[nX]:noLayout
					loteItensMovimentacao-> 	oJSON:itensPedido[nX]:loteItensMovimentacao[nY]:quantidade
												oJSON:itensPedido[nX]:loteItensMovimentacao[nY]:qtdAvaria
												oJSON:itensPedido[nX]:loteItensMovimentacao[nY]:noLote
												oJSON:itensPedido[nX]:loteItensMovimentacao[nY]:validadeLote
												oJSON:itensPedido[nX]:loteItensMovimentacao[nY]:datafabricacao
*/

::SetContentType("application/json")	
	
If !FWJsonDeserialize(cJson, @oJSON)
	cMsg:= 'Ocorreu erro no processamento do JSON.'
	lRet := .F.
Else

	cOperacao := upper(alltrim(oJSON:OPERACAO))
	cTipo	  := upper(alltrim(oJSON:TIPO))

	If cOperacao != "RETURN"
		cMsg:= 'Operacao de retorno nao e valida para retorno do Pedido no Protheus'	
		lRet:= .F.
	Else

		cChv	:= alltrim(oJSON:ERPID)
		cNum	:= padr(substr(cChv, TamSX3("ZA8_FILIAL")[1]+1 	, TamSX3("D3_DOC")[1]) ,  TamSX3("D3_DOC")[1])

		dbSelectArea("ZA8")
		ZA8->(dbSetOrder(1))
		If ! ZA8->(dbSeek(cChv,.T. ))
			cMsg:= 'Nr. Doc ' + cNum + ' nao encontrado no Protheus.'
			lRet := .F.
		EndIf			

/* 		If lRet .and. Type(oJSON:ItensMovimentacao) == "U"
			cMsg:= 'Documento não contem itens para serem atualizados.'
			lRet := .F.
		Endif */
	
		If lRet

			For nX1:=1 to len(oJSON:ItensMovimentacao)

				cErpID	:= oJSON:ItensMovimentacao[nX1]:erpID

				cItem	:= substr(cErpID		, TamSX3("ZA8_FILIAL")[1]+TamSX3("ZA8_DOC")[1]+1						, TamSX3("ZA8_ITEM")[1])
				cProduto:= padr(substr(cErpID	, TamSX3("ZA8_FILIAL")[1]+TamSX3("ZA8_DOC")[1]+TamSX3("ZA8_ITEM")[1]+1	, TamSX3("ZA8_PRODUT")[1]), TamSX3("ZA8_PRODUT")[1])

				nSaldo	:= 0
				aSaldos	:= {}
				aSaldoLib:= {}

				dbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				If ! SB1->(dbSeek(FWxFilial("SB1")+cProduto,.T.))
					cMsg:= 'Produto '+ cProduto + ' do Documento Nr. ' + cNum + ' nao existe no cadastro do Protheus.'
					lRet:= .F.
					Exit
				Endif

				lRastro:= SB1->B1_RASTRO == 'L'

/* 				If lRastro .and. Type(oJSON:ItensMovimentacao[nX1]:loteItensMovimentacao) == "U" 
					cMsg:= 'Produto '+ cProduto + ' do Documento Nr. ' + cNum + ' controle lote. Nao foi Informado Lote no retorno.'
					lRet := .F.
					exit
				Endif
 */
				nQtdZA8	:= ZA8->ZA8_QUANT
				cMsgPnl	:= ZA8->ZA8_MSGWMS + CRLF
				cArmOri	:= ZA8->ZA8_ARMORI
				If cTipo == 'TR'
					cArmDes := ZA8->ZA8_ARMDES
				Endif

				If lRastro

					For nX2:=1 to len(oJSON:ItensMovimentacao[nX1]:loteItensMovimentacao)

						nSaldo	:= 0
						nSldEnd := 0
						nQtd	:= oJSON:ItensMovimentacao[nX1]:loteItensMovimentacao[nX2]:quantidade
						cLoteCtl:= padr(oJSON:ItensMovimentacao[nX1]:loteItensMovimentacao[nX2]:nolote, TamSX3("D3_LOTECTL")[1])
						cLocaliz:= cEndWMS

						If Empty(cLoteCtl) 
							cMsg:= 'Item '+ cItem +' Produto '+ cProduto + ' do Documento Nr. ' + cNum + ' controle lote. Lote igual a branco .'
							lRet := .F.
							exit
						Else
							dbSelectArea("SB8")
							SB8->(DbSetOrder(3))
							If SB8->(dbSeek(FWxFilial("SB8")+cProduto+cArmOri+cLoteCtl,.T.))
								dDtVald:= SB8->B8_DTVALID
								aSaldos:=SldPorLote(cProduto,cArmOri,nQtd,0,cLoteCtl,Nil,cLocaliz,NIL,NIL,NIL,NIL,(SuperGetMv('MV_LOTVENC')=='S'),,,dDataBase)

								For nX3:=1 to len(aSaldos)
									For nX4:=1 to len(aSaldos[nX3,10])
										nSaldo+= aSaldos[nX3,10,nX4,02]
									Next nX4
								Next nX3

								If nSaldo < nQtd .and. cTipo $ 'RE|TR'
									cMsg:= 'Item '+ cItem +' Produto '+ cProduto + ' do Documento Nr. ' + cNum + ' saldo disponivel no protheus, nao atende a quantidade solicitada pelo WMS .'
									lRet := .F.
									exit									
								Endif

								nSldEnd:= SaldoSBF(cArmOri,cLocaliz,cProduto,Nil,cLoteCtl,NIL)
								If nSldEnd < nQtd .and. cTipo $ 'RE|TR'
									cMsg:= 'Item '+ cItem +' Produto '+ cProduto + ' do Documento Nr. ' + cNum + ' saldo disponivel no endereco ' + cLocaliz + ' protheus, nao atende a quantidade solicitada pelo WMS .'
									lRet := .F.
									exit									
								Endif								
								
								/*
								aSaldos[1][1] //Lote
								aSaldos[1][2] //Sub-Lote
								aSaldos[1][3] //Endereco
								aSaldos[1][4] //Numero Serie
								aSaldos[1][7] //Dt.Validade
								aSaldos[1][6] //Potencia
								aadd(aSaldos,{TRB->TRB_LOTECT,TRB->TRB_NUMLOT,Iif(!(lWmsNew .And. lInfoWms),TRB->TRB_LOCALI,''),TRB->TRB_NUMSER,TRB->TRB_QTDLIB,TRB->TRB_POTENC,TRB->TRB_DTVALI})
								*/

								aAdd( aSaldoLib , { cLoteCtl,; 	//Numero do Lote
													'',;		//Sub-Lote
													cLocaliz,;	//Endereco
													'',;		//Numero de Serie
													nQtd,;		//Qtd. Liberada
													0,;			//Potencia
													dDtVald})	//Dt Validade do Lote								

							Else
								cMsg:= 'Item '+ cItem +' Produto '+ cProduto + ' do Documento Nr. ' + cNum + ' Lote Informado ' + cLoteCtl + ' nao existe no sistema.'
								lRet := .F.
								exit
							Endif

						Endif

					Next nX2

				Else

					nSaldo	:= SaldoSB2(cProduto,cArmOri)
					nSldEnd := 0
					nQtd	:= oJSON:ItensMovimentacao[nX1]:quantidade
					cLoteCtl:= ''
					cLocaliz:= cEndWMS
					dDtVald	:= ctod("//")

					If nSaldo < nQtd .and. cTipo $ 'RE|TR'
						cMsg:= 'Item '+ cItem +' Produto '+ cProduto + ' do Documento Nr. ' + cNum + ' saldo disponivel no protheus, nao atende a quantidade solicitada pelo WMS .'
						lRet := .F.
						exit									
					Endif

					nSldEnd:= SaldoSBF(cArmOri,cLocaliz,cProduto,' ',cLocaliz,' ')
					If nSldEnd < nQtd .and. cTipo $ 'RE|TR'
						cMsg:= 'Item '+ cItem +' Produto '+ cProduto + ' do Documento Nr. ' + cNum + ' saldo disponivel no endereco ' + cLocaliz + ' protheus, nao atende a quantidade solicitada pelo WMS .'
						lRet := .F.
						exit									
					Endif								

					aAdd( aSaldoLib , { cLoteCtl,; 	//Numero do Lote
										'',;		//Sub-Lote
										cLocaliz,;	//Endereco
										'',;		//Numero de Serie
										nQtd,;		//Qtd. Liberada
										0,;			//Potencia
										dDtVald})	//Dt Validade do Lote								

				Endif				

			Next nX

			If len(aSaldoLib) > 0

				cDocumen:= GetSxeNum("SD3","D3_DOC")
				nQtdTot	:= 0
				aCab	:= {}
				aAuto	:= {}				

				If ZA8->ZA8_TIPO == 'MI'

					aCab:= { {"D3_DOC"		, cDocumen					, NIL} ,;
							 {"D3_TM"		, ZA8->ZA8_TM				, NIL} ,;
							 {"D3_CC"		, space(TamSX3("D3_CC")[1])	, NIL} ,;
							 {"D3_EMISSAO" 	, ZA8->ZA8_EMISSA			, NIL} }

					For nX5:=1 to len(aSaldoLib)
						nQtdTot+= aSaldoLib[nX5,05]

						//Origem
						aLinha:= {}
						aadd(aLinha,{"D3_COD"		, SB1->B1_COD			, Nil}) //Cod Produto origem
						aadd(aLinha,{"D3_UM"		, SB1->B1_UM			, Nil}) //unidade medida origem
						aadd(aLinha,{"D3_QUANT"		, aSaldoLib[nX5,05]		, Nil}) //Quantidade
						aadd(aLinha,{"D3_LOCAL"		, ZA8->ZA8_ARMORI		, Nil}) //armazem origem						
						aadd(aLinha,{"D3_LOCALIZ"	, aSaldoLib[nX5,03]		, Nil}) //Lote Origem
						aadd(aLinha,{"D3_LOTECTL"	, aSaldoLib[nX5,01]		, Nil}) //Lote Origem
						aadd(aLinha,{"D3_DTVALID"	, aSaldoLib[nX5,07]		, Nil}) //data validade

						aAdd( aAuto, aLinha)

					Next nX5

				Else

					aadd(aAuto,{cDocumen,dDataBase}) //Cabecalho
					
					For nX5:=1 to len(aSaldoLib)
						nQtdTot+= aSaldoLib[nX5,05]

						//Origem
						aLinha:= {}
						aadd(aLinha,{"ITEM"			,'00'+cvaltochar(nX5)	, Nil})
						aadd(aLinha,{"D3_COD"		, SB1->B1_COD			, Nil}) //Cod Produto origem
						aadd(aLinha,{"D3_DESCRI"	, SB1->B1_DESC			, Nil}) //descr produto origem
						aadd(aLinha,{"D3_UM"		, SB1->B1_UM			, Nil}) //unidade medida origem
						aadd(aLinha,{"D3_LOCAL"		, ZA8->ZA8_ARMORI		, Nil}) //armazem origem
						aadd(aLinha,{"D3_LOCALIZ"	, cEndWMS				, Nil}) //Informar endereÃ§o origem
						
						//Destino
						aadd(aLinha,{"D3_COD"		, SB1->B1_COD			, Nil}) //cod produto destino
						aadd(aLinha,{"D3_DESCRI"	, SB1->B1_DESC			, Nil}) //descr produto destino
						aadd(aLinha,{"D3_UM"		, SB1->B1_UM			, Nil}) //unidade medida destino
						aadd(aLinha,{"D3_LOCAL"		, ZA8->ZA8_ARMDES		, Nil}) //armazem destino
						aadd(aLinha,{"D3_LOCALIZ"	, cEndERP				, Nil}) //Informar endereÃ§o destino
						
						aadd(aLinha,{"D3_NUMSERI"	, ''					, Nil}) //Numero serie
						aadd(aLinha,{"D3_LOTECTL"	, aSaldoLib[nX5,01]		, Nil}) //Lote Origem
						aadd(aLinha,{"D3_NUMLOTE"	, ''					, Nil}) //sublote origem
						aadd(aLinha,{"D3_DTVALID"	, aSaldoLib[nX5,07]		, Nil}) //data validade
						aadd(aLinha,{"D3_POTENCI"	, 0						, Nil}) //Potencia
						aadd(aLinha,{"D3_QUANT"		, aSaldoLib[nX5,05]		, Nil}) //Quantidade
						aadd(aLinha,{"D3_QTSEGUM"	, 0						, Nil}) //Seg unidade medida
						aadd(aLinha,{"D3_ESTORNO"	, ""					, Nil}) //Estorno
						aadd(aLinha,{"D3_NUMSEQ" 	, ""					, Nil}) //Numero sequencia D3_NUMSEQ
						
						aadd(aLinha,{"D3_LOTECTL"	, aSaldoLib[nX5,01]		, Nil}) //Lote destino
						aadd(aLinha,{"D3_NUMLOTE"	, ''					, Nil}) //sublote destino
						aadd(aLinha,{"D3_DTVALID"	, aSaldoLib[nX5,07]		, Nil}) //validade lote destino
						aadd(aLinha,{"D3_ITEMGRD"	, ""					, Nil}) //Item Grade

						aAdd( aAuto, aLinha)

					Next nX5
				Endif

				If nQtdTot != nQtdZA8
					cMsg:= 'Item '+ cItem +' Produto '+ cProduto + ' do Documento Nr. ' + cNum + ' a quantidade total retornada pelo WMS não bate com a quantidade total do item no pedido.'					
					lRet:= .F.
				Else
					If cTipo == "TR"
						aOK:= U_fTrfERP(aAuto,3) //3=Inclusao 6=Estorno
					else
						aOK:= U_fMovIERP(aCab,aAuto,3)
					Endif
					If aOK[1]
						RecLock("ZA8",.F.)
						ZA8->ZA8_STAWMS:= 'O' 
						ZA8->(MsUnlock())	
					Else
						lRet:= .F.				
						cMsg:= aOK[2]		
					Endif
					
				Endif
			Endif

		Endif

	Endif

Endif

If lRet

	cMsg:= '{"Resultado": "T", "msg": "Recepcao com Sucesso" }'
		
	::SetResponse( cMsg )

	cJson+=CRLF+CRLF+ cMsg + CRLF

Else

	cMsgPnl+= "-----------------------------------------------------------------------------------------" + CRLF
	cMsgPnl+= "Data: "+dtoc(dDataBase) + " Hora: " + Time() + " Usuario Integração: " + __cUserId + "-" + upper(UsrRetName(__cUserId)) + CRLF


	cMsgPnl+= cMsg 

	SetRestFault(400, cMsg )

	cJson+=CRLF+CRLF+'{ "Resultado":"F", "msg":"' + cMsg + '"} '

	cMsgPnl+= CRLF 

	RecLock("ZA8",.F.)
	ZA8->ZA8_STAWMS:= "X" //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
	ZA8->ZA8_DTIWMS:= dDataBase
	ZA8->ZA8_HRIWMS:= Time()
	ZA8->ZA8_MSGWMS:= cMsgPnl
	ZA8->(MsUnlock())

Endif

FreeObj(oJSON)

RecLock("ZA1",.T.)
ZA1->ZA1_FILIAL:= FWxFilial("ZA1")
ZA1->ZA1_STATUS:= iIf(lRet,"1","0")
ZA1->ZA1_NRTRAN:= U_fIDWmsErp()
ZA1->ZA1_TIPOTR:= "R"
ZA1->ZA1_ORIGEM:= "WS_MOVTOINT" + iIf(cTipo=='TR','-Transf','-Mov.Int')
ZA1->ZA1_DATATR:= date()
ZA1->ZA1_HORATR:= time()
ZA1->ZA1_USERTR:= 'CyberLog'//upper(UsrRetName(__cUserId))
ZA1->ZA1_JSON  := cJson
ZA1->ZA1_TPMOV := iIf(cTipo=='TR','9','8')
ZA1->(MsUnlock())

Return lRet

//-------------------------------------------------------------------------------------------------------------------------------------------------
WSMethod POST RecInvent WSReceive json_dados WSService wscyberlog

Local aAuto		:= {}
Local cEndWMS	:= padr(SuperGetMV("FZ_XENDWMS"), tamsx3('D3_LOCALIZ')[1])
Local cJson 	:= self:getContent()
Local cMsgPnl	:= ''
Local cMsg		:= ''
Local oJson		:= Nil 
Local nX1
Local nX2

Local lRet		:= .T.

Private lMSErroAuto := .F.

::SetContentType("application/json")	

MakeDir("\WEB\WSCYBERLOG\")
	
If !FWJsonDeserialize(cJson, @oJSON)
	cMsg:= 'Ocorreu erro no processamento do JSON.'
	lRet := .F.
Else

/*TAGs do Retorno Inventario

oJSON:empresa
oJSON:documento
oJSON:data
oJSON:status
itensInventario->	oJSON:itensInventario[nX]:codigoReduzido
					oJSON:itensInventario[nX]:quantidade": "10.0"
					oJSON:itensInventario[nX]:noLayout": 1
					loteItensInventario->	oJSON:itensInventario[nX]:loteItensInventario[nY]:noLote
											oJSON:itensInventario[nX]:loteItensInventario[nY]:quantidade
											oJSON:itensInventario[nX]:loteItensInventario[nY]:validadeLote
											oJSON:itensInventario[nX]:loteItensInventario[nY]:dataFabricacao

*/


	cDocumen:= oJSON:documento
	dData	:= U_DtJsonERP(oJSON:data)[1]

/* 	If lRet .and. Type("oJSON:ITENSINVENTARIO") == "U"
		cMsg:= 'Documento nao contem itens para serem atualizados.'
		lRet := .F.
	Endif */
	
	If lRet

		For nX1:=1 to len(oJSON:itensInventario)

				cProduto:= padr(oJSON:itensInventario[nX1]:codigoReduzido, TamSX3("ZA8_PRODUT")[1])

				dbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				If ! SB1->(dbSeek(FWxFilial("SB1")+alltrim(cProduto),.T.))
					cMsg:= 'Produto '+ alltrim(cProduto) + ' nao existe no cadastro do Protheus.'
					lRet:= .F.
				Endif

				lRastro:= SB1->B1_RASTRO == 'L'
/* 
				If lRastro .and. Type("oJSON:itensInventario[nX1]:loteItensInventario") == "U"
					cMsg:= 'Produto '+ cProduto + ' do Invetario Nr. ' + cDocumen + ' controle lote. Nao foi Informado Lote no retorno.'
					lRet := .F.
					exit
				Endif */

				If lRastro

					For nX2:=1 to len(oJSON:itensInventario[nX1]:loteItensInventario)

						nQtd	:= oJSON:itensInventario[nX1]:loteItensInventario[nX2]:quantidade
						cLoteCtl:= padr(oJSON:itensInventario[nX1]:loteItensInventario[nX2]:nolote, TamSX3("D3_LOTECTL")[1])

						If Empty(cLoteCtl) 
							cMsg:= 'Item '+ cItem +' Produto '+ cProduto + ' do Documento Nr. ' + cNum + ' controle lote. Lote igual a branco .'
							lRet := .F.
							exit
						Endif		

						aAuto	:= {}
						Aadd(aAuto,{"B7_FILIAL"  ,FWxFilial("SB7")	, Nil}) // 1
						Aadd(aAuto,{"B7_COD"     ,cProduto			, Nil}) // 2 
						Aadd(aAuto,{"B7_LOCAL"   ,SB1->B1_LOCPAD	, Nil}) // 3
						Aadd(aAuto,{"B7_TIPO"    ,SB1->B1_TIPO		, Nil}) // 3
						Aadd(aAuto,{"B7_DOC"     ,cDocumen			, Nil}) // 4
						Aadd(aAuto,{"B7_QUANT"   ,nQtd				, Nil}) // 5
						Aadd(aAuto,{"B7_DATA"    ,dData				, Nil}) // 6
						Aadd(aAuto,{"B7_LOCALIZ" ,cEndWMS			, Nil}) // 7
						Aadd(aAuto,{"B7_LOTECTL" ,cLoteCtl			, Nil}) // 7
						Aadd(aAuto,{"B7_ORIGEM" , "WS_RECINVENT"	, NIL})
						Aadd(aAuto,{"B7_STATUS" , "1" 				, NIL})						
						Aadd(aAuto,{"INDEX" ,1						, Nil}) // 7

						dbSelectArea("SB7")
						dbSetOrder(1)

						// SE NÃO EXISTIR O REGISTRO, EXECUTA MSExecAuto() PARA INCLUIR.
						MSExecAuto({|x,y| mata270(x,y)},aAuto,3) 
							
						If lMSErroAuto 
							MostraErro("\WEB\WSCYBERLOG\", "ERR_INVENT.TXT")
							cMsg:= U_WSTxtLog("\WEB\WSCYBERLOG\ERR_INVENT.TXT")

							lRet := .F.
						Else
							lRet:= .T.
						Endif

					Next nX2

				Else

					nQtd	:= oJSON:itensInventario[nX1]:quantidade

					aAuto	:= {}
					Aadd(aAuto,{"B7_FILIAL"  ,FWxFilial("SB7")	, Nil}) // 1
					Aadd(aAuto,{"B7_COD"     ,cProduto			, Nil}) // 2 
					Aadd(aAuto,{"B7_LOCAL"   ,SB1->B1_LOCPAD	, Nil}) // 3
					Aadd(aAuto,{"B7_TIPO"    ,SB1->B1_TIPO		, Nil}) // 3
					Aadd(aAuto,{"B7_DOC"     ,cDocumen			, Nil}) // 4
					Aadd(aAuto,{"B7_QUANT"   ,nQtd				, Nil}) // 5
					Aadd(aAuto,{"B7_DATA"    ,dData				, Nil}) // 6
					Aadd(aAuto,{"B7_LOCALIZ" ,cEndWMS			, Nil}) // 7
					Aadd(aAuto,{"B7_ORIGEM" , "WS_RECINVENT"	, NIL})
					Aadd(aAuto,{"B7_STATUS" , "1" 				, NIL})						
					Aadd(aAuto,{"INDEX" ,1			, Nil}) // 7
						
					dbSelectArea("SB7")
					dbSetOrder(1)

					// SE NÃO EXISTIR O REGISTRO, EXECUTA MSExecAuto() PARA INCLUIR.
					MSExecAuto({|x,y| mata270(x,y)},aAuto,3) 
						
					If lMSErroAuto 
						MostraErro("\WEB\WSCYBERLOG\", "ERR_INVENT.TXT")
						cMsg:= U_WSTxtLog("\WEB\WSCYBERLOG\ERR_INVENT.TXT")

						lRet := .F.
					Else
						lRet:= .T.
					Endif
				
				Endif

		Next nX1

	Endif

Endif

If lRet

	cMsg:= '{"Resultado": "T", "msg": "Recepcao com Sucesso" }'
		
	::SetResponse( cMsg )

	cJson+=CRLF+CRLF+ cMsg + CRLF

Else

	cMsgPnl+= "-----------------------------------------------------------------------------------------" + CRLF
	cMsgPnl+= "Data: "+dtoc(dDataBase) + " Hora: " + Time() + " Usuario Integração: " + __cUserId + "-" + upper(UsrRetName(__cUserId)) + CRLF


	cMsgPnl+= cMsg 

	SetRestFault(400, cMsg )

	cJson+=CRLF+CRLF+'{ "Resultado":"F", "msg":"' + cMsg + '"} '

	cMsgPnl+= CRLF 

Endif

FreeObj(oJSON)

RecLock("ZA1",.T.)
ZA1->ZA1_FILIAL:= FWxFilial("ZA1")
ZA1->ZA1_STATUS:= iIf(lRet,"1","0")
ZA1->ZA1_NRTRAN:= U_fIDWmsErp()
ZA1->ZA1_TIPOTR:= "R"
ZA1->ZA1_ORIGEM:= "WS_INVENT"
ZA1->ZA1_DATATR:= date()
ZA1->ZA1_HORATR:= time()
ZA1->ZA1_USERTR:= 'CyberLog'//upper(UsrRetName(__cUserId))
ZA1->ZA1_JSON  := cJson
ZA1->ZA1_TPMOV := '1' //Inventario
ZA1->(MsUnlock())

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fVldSC9
Funcao para validar o SC9 
@type function
@author Carlos CLeuber
@since 21/12/2020
@version 12.1.27
/*/
Static Function fVldSC9()
Local aRet:= array(2)

aRet[1]:= .T.
aRet[2]:= ''

If Empty(SC9->C9_XSTAWMS) //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
	aRet[1]:= .F.
	aRet[2]:= 'Item do Pedido de Venda com status de não enviado ao WMS.'
Endif

If aRet[1] .and. SC9->C9_XSTAWMS == 'F'
	aRet[1]:= .F.
	aRet[2]:= 'Item do Pedido de Venda com falha de envio ao WMS, favor verificar LOG de envio.'
Endif

If aRet[1] .and. SC9->C9_XSTAWMS == 'O'
	aRet[1]:= .F.
	aRet[2]:= 'Item do Pedido de Venda com retorno do WMS ja processado.'
Endif

If aRet[1] .and. SC9->C9_BLCRED == "10" .AND. SC9->C9_BLEST == "10"
	aRet[1]:= .F.
	aRet[2]:= 'Pedido de Venda ja emitido Nota Fiscal.'
EndIf

If aRet[1] .and. !Empty(SC9->C9_BLCRED)
	aRet[1]:= .F.
	If SC9->C9_BLCRED == "09"
		aRet[2]:= 'A Liberacao de um Pedido Rejeitado deve ser efetuada na Liberacao Manual de Credito.'
	Else
		aRet[2]:= 'Para efetuar a Liberacao no Estoque e necesscrio que o Pedido esteja  liberado no Credito.'
	EndIf

EndIf

If aRet[1] .and. SC9->C9_LOCAL==SuperGetMV("MV_CQ", .F.,"98")
	aRet[1]:= .F.
	aRet[2]:= 'Nao e permitida a liberacao de estoque manual de produtos bloqueados no CQ.'
EndIf

If aRet[1] .and. SC9->C9_BLCRED == "  " .And. SC9->C9_BLEST == "  " .And. SC9->C9_BLWMS == "  "
	aRet[1]:= .F.
	aRet[2]:= 'Pedido ja liberado.'
EndIf

If aRet[1] .and. !Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_BLEST)
	aRet[1]:= .F.
	aRet[2]:= 'Pedido bloqueado no Credito.'
EndIf								

Return aRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fLibPed
Esta rotina realiza a atualizacao da liberacao de pedido de  venda com base na tabela SC9
@type function
@author Carlos CLeuber
@since 21/12/2020
@version 12.1.27
@param	lAtuCred, logical	, Indica uma Liberacao de Credito                       
@param	lAtuEst	, logical	, Indica uma liberacao de Estoque                       
@param	lHelp	, logical	, Indica se exibira o help da liberacao                 
@param	aSaldos	, array	, Saldo dos lotes a liberar                             
@param	lAvest	, logical	, Forca analise da liberacao de estoque                 
@param	lLogMsg	, logical	, Indica se a funcao deve armazenar as mensagens de inconsistencias e alertas no processo de liberacao    
*/
Static Function fLibPed( lAtuCred  , lAtuEst   , lHelp     , ;
                   aSaldos  , lAvEst    , lLogMsg)

Local aArea      := GetArea()
Local aAreaC9    := SC9->(GetArea())
Local lCredito   := Empty(SC9->C9_BLCRED)
Local nQtdEst    := 0
Local nMCusto    :=  Val(SuperGetMv("MV_MCUSTO"))
Local nQtdALib   := 0
Local nQtdLib    := 0
Local lOrdSepLib := .F.
Local lEstoque   := .F.
Local lMvAvalEst := SuperGetMv("MV_AVALEST")==2
Local lBlqEst    := SuperGetMv("MV_AVALEST")==3 .And. Empty(aSaldos)
Local cMsg		 := ""
Local cLiberOk   := ""
Local cBlq       := ""
Local cBloquei   := ""
Local nX
                 
DEFAULT lHelp    := .T.
DEFAULT aSaldos  := {}
DEFAULT lAvEst   := .F.
DEFAULT lLogMsg  := .F.

//- Status dos Bloqueios do pedido de venda. Se .T. DCF gerado, tem que estornar.
Private lbloqDCF := !Empty(SC9->C9_BLCRED+SC9->C9_BLEST)
lBlqEst := lBlqEst .And. !lAvEst
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona Registros                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC5")
dbSetOrder(1)
MsSeek(xFilial("SC5")+SC9->C9_PEDIDO)

dbSelectArea("SC6")
dbSetOrder(1)
MsSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)

dbSelectArea("SA1")
dbSetOrder(1)
MsSeek(xFilial("SA1")+SC9->C9_CLIENTE+SC9->C9_LOJA)

dbSelectArea("SF4")
dbSetOrder(1)
MsSeek(xFilial("SF4")+SC6->C6_TES)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Moeda Forte do Cliente                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMCusto:= If (SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, nMCusto)					
dbSelectArea("SB2")
dbSetOrder(1)
MsSeek(cFilial+SC6->C6_PRODUTO+SC6->C6_LOCAL)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Liberacao do SC9                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Travamento dos Registros                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(SC5->C5_TIPO $ "DB")
		RecLock("SA1",.F.)
	EndIf
	RecLock("SC5",.F.)
	RecLock("SC6",.F.)
	RecLock("SC9",.F.)
	If ( SB2->(Found()) )
		RecLock("SB2",.F.)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula a quantidade disponivel em estoque                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nQtdEst :=SC9->C9_QTDLIB
	If ( Empty(SC9->C9_RESERVA) .And. !Empty(SC9->C9_BLCRED+SC9->C9_BLEST) .And. SF4->F4_ESTOQUE == "S")				
		If lBlqEst
			lEstoque := .F.
		Else
			If Empty(aSaldos)
				lEstoque := A440VerSB2(@nQtdEst,lMvAvalEst)
			Else          
				lEstoque := A440VerSB2(@nQtdEst,lMvAvalEst,,,,.F.)
			EndIf
		EndIf
	Else
		lEstoque := .T.
	EndIf
	If ( nQtdEst == 0 )
		nQtdEst  := SC9->C9_QTDLIB
		lEstoque := .F.
	EndIf

	If ( Empty(SC9->C9_BLCRED) .And. (lAtuEst .Or. lEstoque))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Avaliacao do Estoque                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Rastro(SC9->C9_PRODUTO) .Or. Localiza(SC9->C9_PRODUTO) .Or. !Empty(SC9->C9_RESERVA) 
			If (Rastro(SC9->C9_PRODUTO) .Or. Localiza(SC9->C9_PRODUTO)) .And. !lEstoque
				//Nao faz nada.
			Else

				RecLock("SC5")
				cLiberOk := SC5->C5_LIBEROK
				nQtdALib := SC9->C9_QTDLIB
				cBlq     := SC5->C5_BLQ
				cBloquei := SC6->C6_BLOQUEI
				SC9->(a460Estorna())
				SC5->C5_BLQ     := cBlq
				SC6->C6_BLOQUEI := cBloquei
				If Len(aSaldos)>0
					For nX := 1 To Len(aSaldos)
						RecLock("SC6")
						SC6->C6_LOTECTL := aSaldos[nX][1]
						SC6->C6_NUMLOTE := aSaldos[nX][2]
						SC6->C6_LOCALIZ := aSaldos[nX][3]
						SC6->C6_NUMSERI := aSaldos[nX][4]
						SC6->C6_DTVALID := aSaldos[nX][7]
						SC6->C6_POTENCI := aSaldos[nX][6]
						
						MaLibDoFat(SC6->(RecNo()),Min(aSaldos[nX][5],nQtdALib),@lCredito,@lEstoque,!(lAtuCred .Or. Empty(SC9->C9_BLCRED)),!Empty(SC9->C9_BLEST),.F.,.F.)
						nQtdALib -= Min(aSaldos[nX][5],nQtdALib)
						
						If Empty(SC6->C6_NUMSERI)
							SC6->C6_LOTECTL := ''//aSaldos[nX][1]
							SC6->C6_NUMLOTE := ''//aSaldos[nX][2]
							SC6->C6_LOCALIZ := ''//aSaldos[nX][3]
							SC6->C6_NUMSERI := ''//aSaldos[nX][4]
							SC6->C6_DTVALID := Ctod('')//aSaldos[nX][7]
							SC6->C6_POTENCI := 0//aSaldos[nX][6]
						EndIf		

						cMsg:= "-----------------------------------------------------------------------------------------" + CRLF
						cMsg+= "Data: "+dtoc(dDataBase) + " Hora: " + Time() + " Usuario Integração: " + __cUserId + "-" + upper(UsrRetName(__cUserId)) + CRLF
						cMsg+= "Integração / Liberação do Pedido efetuada com Sucesso ."

						RecLock("SC9")	
						SC9->C9_LOTECTL:= aSaldos[nX][1]
						SC9->C9_DTVALID:= aSaldos[nX][7]
						SC9->C9_BLEST  := ''
						SC9->C9_XSTAWMS:= "O" //' '=Nao Enviado;E=Enviado;F=Falha Envio;O=Retorno OK;X=Retorno Incorreto;C=Cancelado
						SC9->C9_XDTIWMS:= dDataBase
						SC9->C9_XHRIWMS:= Time()
						SC9->C9_XMSGWMS:= cMsg

					Next nX
				Else
					nQtdLib := MaLibDoFat(SC6->(RecNo())                        , SC9->C9_QTDLIB       , @lCredito, @lEstoque, ;
											!(lAtuCred .Or. Empty(SC9->C9_BLCRED)), !Empty(SC9->C9_BLEST), .F.      , .F.      , ;
																				,                      ,          ,          , ;
																				,                      ,          , lLogMsg  , ;
											@lOrdSepLib)
					If (Empty(nQtdLib) .And. lOrdSepLib) 
						DisarmTransaction()
						Break
					EndIf
				EndIf
				RecLock("SC5")
				SC5->C5_LIBEROK := cLiberOk
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retira o Bloqueio de Estoque                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FatAtuEmpN("-")
			MaAvalSC9("SC9",6,{{ "","","","",SC9->C9_QTDLIB,SC9->C9_QTDLIB2,Ctod(""),"","","",SC9->C9_LOCAL}},Nil,Nil,.F.)
			SC9->C9_BLEST := ""
			MaAvalSC9("SC9",5,{{ "","","","",SC9->C9_QTDLIB,SC9->C9_QTDLIB2,Ctod(""),"","","",SC9->C9_LOCAL}})
			dbSelectArea("SC9")
			MsUnlock()
			dBCommit()
			FatAtuEmpN("+")
		EndIf
	EndIf
	MsUnLockAll()
End Transaction

RestArea(aAreaC9)
RestArea(aArea)
Return(Nil)
