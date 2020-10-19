#iNCLUDE "TOPCONN.CH"
#iNCLUDE "protheus.ch"
#DEFINE CRLF (chr(13)+chr(10))

//-------------------------
/*/{Protheus.doc} WFAprPed                                                                                  
Gera workflow de aprova��o de pedidos de compras.

@author ????
@since ??????
@version 3.0                                                                                                 ?
@param _cNiv, character, Nivel de Aprova��o para envio
/*/                            
//-------------------------
User Function WFAprPed(_cNiv, _lReenvia)

Local aInfo     	:= {}
Local _AcompNvl 	:= ''
Private aaprov  	:= {}
Private cMvAtt  	:= GetMv("MV_WFHTML")
Private aRecno  	:= {}
Private cMailAp 	:= ""
Private recsc7  	:= SC7->(RECNO())
Private cAprov  	:= ''

default _cNiv := "01"
default _lReenvia := .F.
PutMv("MV_WFHTML","T")


//pega os e-mails dos aprovadores
dbSelectArea("SCR")
SCR->(dbSetorder(1))
if SCR->(dbSeek(xFilial("SCR")+"PC"+PADR(SC7->C7_NUM,TamSx3("CR_NUM")[1])+_cNiv))   
	//Percorre todas as al�adas do pedido
	While !SCR->(EOF()) .And. SCR->CR_FILIAL + SCR->CR_TIPO + SCR->CR_NUM ==  xFilial("SCR") + "PC" + PADR(SC7->C7_NUM,TamSx3("CR_NUM")[1])
		//Se for o nivel atual, muda o status para 2=pendente
		IF SCR->CR_NIVEL == _cNiv .AND. (!_lReenvia .OR. (_lReenvia .AND. SCR->CR_STATUS != '03'))
			cAprov := SCR->CR_USER
			PswOrder(1)
			If PswSeek(cAprov,.t.)
				aInfo := PswRet(1)
				if !Empty(ainfo[1,14])				
					RecLock("SCR",.F.)
					SCR->CR_STATUS := "02"
					
					//Limpa os campos para casos de reenvio de WF
					SCR->CR_USERLIB := ""
					SCR->CR_VALLIB  := 0
					SCR->CR_TIPOLIM := ""
					SCR->CR_LIBAPRO := ""
					SCR->CR_DATALIB := CTOD('  /  /    ')
					SCR->(MsUnlock("SCR"))
					
					dbSelectArea("SAL")
					SAL->(dbSetorder(2))
					if SAL->(dbSeek(xFilial("SAL")+SCR->CR_GRUPO+_cNiv)) .AND. !EMPTY(SAL->AL_XMAILAC)
						_AcompNvl := SAL->AL_XMAILAC
					ENDIF
					
				else
					AVISO( "WF de Aprova��o de Pedidos de Compra", "E-mail do usu�rio " +allTrim(cAprov)+ " n�o esta cadastrado!!!!", { "Ok" },2,'Valida��o de E-mail' , 1, '', .F., 200, 1 )
				endif
			EndiF
			//Se for um nivel maior, deixa o status 1=aguardando outros niveis, para corrigir a al�ada em casos de reenvio de WF
		ELSEIF(VAL(SCR->CR_NIVEL) > VAL(_cNiv))
			RecLock("SCR",.F.)
			SCR->CR_STATUS  := "01"
			SCR->CR_USERLIB := ""
			SCR->CR_VALLIB  := 0
			SCR->CR_TIPOLIM := ""
			SCR->CR_LIBAPRO := ""
			SCR->CR_DATALIB := CTOD('  /  /    ')
			MsUnlock("SCR")
		ENDIF
		SCR->(dbSkip())
	EndDo    
endif
SCR->(DBCloseArea())
            
//pega os e-mails dos aprovadores
dbSelectArea("SCR")
SCR->(dbSetorder(1))
if SCR->(dbSeek(xFilial("SCR")+"PC"+PADR(SC7->C7_NUM,TamSx3("CR_NUM")[1])+_cNiv))   
	While !SCR->(EOF()) .And. SCR->CR_FILIAL + SCR->CR_TIPO + SCR->CR_NUM + SCR->CR_NIVEL  ==  xFilial("SCR") + "PC" + PADR(SC7->C7_NUM,TamSx3("CR_NUM")[1])+_cNiv
	//SE estiver reenviando, s� envia email se o aprovador n�o tiver aprovado
		IF  (!_lReenvia .OR. (_lReenvia .AND. SCR->CR_STATUS != '03'))
			cAprov := SCR->CR_USER
			PswOrder(1)
			If PswSeek(cAprov,.t.)
				aInfo := PswRet(1)
				if !Empty(ainfo[1,14])				
				    U_envia_WF(cAprov,alltrim(aInfo[1,14]),_cNiv,recsc7,_AcompNvl)  
				else
					AVISO( "WF de Aprova��o de Pedidos de Compra", "E-mail do usu�rio " +allTrim(cAprov)+ " n�o esta cadastrado!!!!", { "Ok" },2,'Valida��o de E-mail' , 1, '', .F., 200, 1 )
				endif
			Endif
	
			// Verifica se est� cadastrado e-mail substituto
			dbSelectArea("WF4")
			WF4->(dbSetOrder(1))
			if WF4->(dbSeek(xFilial("WF4")+Alltrim(UPPER(cMailAp))))
				_lMailSub := .F.
	            _vDadosEmailSub := {}
	            _vY := 0
				While !WF4->(EOF()) .And. Alltrim(WF4->WF4_FILIAL+WF4->WF4_DE)==Alltrim(xFilial("WF4")+Alltrim(UPPER(cMailAp))) .and. !_lMailSub
					If DDATABASE >= WF4->WF4_DTINI .And. DDATABASE <= WF4->WF4_DTFIM
						_lMailSub := .T.
						if !Empty(WF4->WF4_PARA) 
							U_envia_WF(cAprov,WF4->WF4_PARA,_cNiv,recsc7,_AcompNvl) 
						else
							AVISO( "WF de Aprova��o de Pedidos de Compra", "E-mail substituto do usu�rio " +allTrim(cAprov)+ " n�o esta cadastrado!!!!", { "Ok" },2,'Valida��o de E-mail' , 1, '', .F., 200, 1 )
						endif
					Endif
					WF4->(dbSkip())
				Enddo
			endif  
		ENDIF
		WF4->(DBCloseArea())
		SCR->(dbSkip())
	EndDo    
endif  
SCR->(DBCloseArea())

SC7->(DbGoTo(recsc7))

U_ZPB_ATU(SC7->C7_NUM, SC7->C7_NUMSC, SC7->C7_MEDICAO, SC7->C7_CONAPRO)

oCompras  := ClassIntCompras():new()    
	
oCompras:registraIntegracao('2',SC7->C7_FILIAL+SC7->C7_NUM,'I')  
U_ENVSAL02(oCompras:cCodInt)

PutMv("MV_WFHTML",cMvAtt)

Return

//-------------------------
/*/{Protheus.doc} envia_WF
Envia o E-mail de workflow baseado nos par�metros

@author ????
@since ????
@version 3.0
@param cAprv, character, Aprovador
@param cMail, character, E-mail do Aprovador
@param _cNiv, character, Nivel da Aprova��o
@param recsc7, num�rico, Recno sa SC7
/*/
//-------------------------
User Function envia_WF(cAprv,cMail,_cNiv,recsc7, _mailAcmp)

// Localiza o(s) aprovador(es) do n�vel 1
Local nValIPI 	:= 0
Local nTotAux 	:= 0 
Local nTotImp	:= 0
Local cCondPag 	:= ""
Local cAssAux	:= ""
Local _cMed		:= ""
Local _cCon		:= ""
Local cHtmlCon	:= ""
Local I
Local a
Local b
Local c
Local d
Local nxi
Local e
Local cLinkMsg 	:= ""
Local lStyle := .T.
Local _cNumCont := ''
Local cPtoPed   := ''
Local cEndSrv := supergetMv("MV_ENDWF",,"vmsapp_hmg")
Local cHttpServer   := "http://" + cEndSrv + ":" + AllTrim(GetMv("TCP_PORTWF"))
Local _cMailComp :=  getMv("MV_ACOMPWF")+';'+_mailAcmp

For nxi := 1 to 2
	default _cNiv := "01"

	SC7->(DBselectArea("SC7"))
	SC7->(DBGOTO(recsc7))
	CnUMPED:=SC7->C7_NUM
	
	_cNumCont := SC7->C7_CONTRA
	
	cArea:=getArea()
	oProc := TWFProcess():New("PEDCOM","Pedido de Compras")

	//Seleciona o HTML padr�o de acordo com o nivel do aprovador
	//********************************************************//
	If nXi == 1
		If Empty(Alltrim(SC7->C7_MEDICAO)) .AND. Alltrim(FunName()) != 'CNTA120' .and. Alltrim(FunName()) != 'CNTA121'
			If _cNiv $ ("01|02")
				oProc:NewTask("Solicita��o", "\WORKFLOW\HTML\APROVPED.HTM")
			ElseIf _cNiv == "03"
				oProc:NewTask("Solicita��o", "\WORKFLOW\HTML\APROVPED3.HTM")
			Else 
				oProc:NewTask("Solicita��o", "\WORKFLOW\HTML\APROVPED4.HTM")
			EndIF
	
			cAssAux := "Purchase Order approval N: " + SC7->C7_NUM + "  Level " + _cNiv + " "
			cAssAux += iif(SC7->C7_CONTRAT == "S"," Order Under Contract ", "")
		Else
			cAssAux := "Contract Measurement - Purchase Order N�: " + SC7->C7_NUM + " "
			oProc:NewTask("Solicita��o", "\WORKFLOW\HTML\APROVCON.HTM")
		EndIf
	Else
		If Empty(Alltrim(SC7->C7_MEDICAO)) .AND. Alltrim(FunName()) != 'CNTA120'
			oProc:NewTask("Solicita��o de Pedido", "\WORKFLOW\HTML\PEDIDOAP.HTM")
			cAssAux := "Purchase Order approval N�: " + SC7->C7_NUM + "  Level " + _cNiv + " (Follow)"
			
			cAssAux += iif(SC7->C7_CONTRAT == "S"," Order Under Contract ", "")
			lStyle := .f.
		Else
			oProc:NewTask("Solicita��o de Medi��o", "\WORKFLOW\HTML\APROVCON_ACOMP.HTM")
			cAssAux := "Contract Measurement - Purchase Order N�: " + SC7->C7_NUM + "  Level " + _cNiv + "  (Follow)"		
		EndIf
	EndIf
	oProc:cSubject := cAssAux
	oHtml := oProc:oHtml

	If Empty(Alltrim(SC7->C7_MEDICAO)) .AND. Alltrim(FunName()) != 'CNTA120' .AND. Alltrim(FunName()) != 'CNTA121'
	
	/*** Preenche os dados do cabecalho ***/
		If SC7->C7_CONTRAT == "S"
			cHtmlCon := '<tr>' + CRLF
			cHtmlCon += '	<td colspan="4" bgcolor="#FFFF00" height="24">' + CRLF
			cHtmlCon += '		<p align="left">' + CRLF
			cHtmlCon += '			<font size="4" face="Arial">' + CRLF
			cHtmlCon += '				<b>Order Under Contract</b>' + CRLF
			cHtmlCon += '			</font>' + CRLF
			cHtmlCon += '		</p>' + CRLF
			cHtmlCon += '	</td>' + CRLF
			cHtmlCon += '</tr>' + CRLF
		
		Else
			cHtmlCon += ''
		EndIf
	
		dEmissao := SC7->C7_EMISSAO
		cCondPag := Posicione("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_DESCRI")
		cNum     := SC7->C7_NUM
	
		oHtml:ValByName("cContrato" ,cHtmlCon)
		If nXi != 1
			oHtml:ValByName("lb_empresa",SM0->M0_NOMECOM)
		endif
		oHtml:ValByName("EMISSAO"   ,SC7->C7_EMISSAO)
		oHtml:ValByName("pedido"    ,SC7->C7_NUM)
		oHtml:ValByName("FORNECEDOR",SC7->C7_FORNECE)
		oHtml:ValByName("cond_pag"  ,AllTrim(cCondPag))
		oHtml:ValByName("cod_compra",fGetUsrName(SC7->C7_USER) )
		oHtml:ValByName("termos",AllTrim(SC7->C7_XTERMOS))
		oHtml:ValByName("capex",IF(SC7->C7_XCAPEX=='1','Capex',IF(SC7->C7_XCAPEX=='2','Opex','')))
	
		/* Removido at� validarem o processo completo
		oHtml:ValByName("lb_obs",SC7->C7_XOBSENG)
		oHtml:ValByName("lb_obsPt",SC7->C7_OBS)
		*/
		oHtml:ValByName("lb_obs",STRTRAN( SC7->C7_OBS,Chr(13) + Chr(10) ,'</br>'))
		oHtml:ValByName("moeda",U_getWFMoe(SC7->C7_MOEDA))
	
		dbSelectArea('SA2')
		SA2->(dbSetOrder(1))
		SA2->(dbSeek(xFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA))
		oHtml:ValByName("lb_nome",SA2->A2_NREDUZ+if(SC7->C7_MOEDA <> 1,"(Estimated Values - Import)",""))
	
		cLink := If(nxi == 1, embaralha(SC7->C7_FILIAL+SC7->C7_NUM+cAprv+_cNiv+cEmpAnt,0),'')
	
		//Monta o link para gravar a mensagem
		If _cNiv == "03"
	   		cLinkMsg := Embaralha(SC7->C7_FILIAL+SC7->C7_NUM+_cNiv+cEmpAnt,0,)
	 	ElseIf _cNiv == "04"
	   		cLinkMsg := AllTrim(SC7->C7_OBSWF)
	 	EndIf
	
		If nXi == 1
			oHtml:ValByName("cLinkOk", cHttpServer + "/pp/U_weblogA.apw?keyvalue=" + cLink) // confirma
			oHtml:ValByName("cLinkCn", cHttpServer + "/pp/U_weblogR.apw?keyvalue=" + cLink) // cancela
		endif
		aIten := {}
		nTotal := 0
		nFrete := 0
		SC7->(dbSetOrder(1))
		SC7->(dbSeek(xFilial('SC7')+cNum))
	
		oHtml:ValByName("styleh","display: block")  
		_vDesc := 0
		nTotImp:= 0
		nFrete:= 0
		
		//cChaveAne := "%'SC7"+SC7->C7_FILIAL+ SC7->C7_NUM+SC7->C7_ITEM + "'"
		cChaveAne := "%" + fBuildKey( "SC7" )
		While !SC7->(EOF()) .And. SC7->C7_NUM == cNum
			cPtoPed := 'No'
			dbSelectArea('SC1')
			SC1->(dbSetOrder(1))
			if !empty(SC7->C7_NUMSC) .AND. SC1->(dbSeek(SC7->C7_FILIAL+SC7->C7_NUMSC+SC7->C7_ITEMSC))
				if ALLTRIM(SC1->C1_ORIGEM) == 'MATA170'
					cPtoPed := 'Yes'                       
				endif
				oHtml:ValByName("solicitante"    ,SC1->C1_SOLICIT)
			ENDIF
			dbSelectArea('SB1')
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial('SB1')+SC7->C7_PRODUTO))
			
			dbSelectArea("SB2")
			SB2->(dbSeek(xFilial("SB2") +SC7->C7_PRODUTO +SC7->C7_LOCAL))
			nSaldo := SaldoSb2()
			
			AADD((oHtml:ValByName("it.item")),SC7->C7_ITEM)
			AADD((oHtml:ValByName("it.codigo")),SC7->C7_PRODUTO)
			AADD((oHtml:ValByName("it.descricao")),RetDesc(SC7->C7_PRODUTO))
			AADD((oHtml:ValByName("it.ptPedido")),cPtoPed)
			AADD((oHtml:ValByName("it.garantia"  )), IF(SC7->C7_XGARANTA=='1','Yes','No'))
			AADD((oHtml:ValByName("it.tempoGar"  )),ALLTRIM(STR(SC7->C7_XTMPGAR))+ IF(SC7->C7_XDESCGA=='1','Days',IF(SC7->C7_XDESCGA=='2','Months',IF(SC7->C7_XDESCGA=='3','Years',''))))
			AADD((oHtml:ValByName("it.saldo")),TRANSFORM(nSaldo,'@E 999,999.99'))
			AADD((oHtml:ValByName("it.ponto")),TRANSFORM(SB1->B1_EMIN,'@E 999,999.99'))
			AADD((oHtml:ValByName("it.quant")),TRANSFORM(SC7->C7_QUANT,'@E 999,999.99'))
	
			//Campos para o centro de custo e data de entrega
			//Lucas - 11/10/13
			AADD((oHtml:ValByName("it.ctt"    )), iif(empty(SC7->C7_CC), Space(TamSx3('C7_CC')[1])     , SC7->C7_CC))
			AADD((oHtml:ValByName("it.cttdesc")), iif(empty(SC7->C7_CC), Space(TamSx3('CTT_DESC01')[1]), Posicione('CTT', 1, Xfilial('CTT') + SC7->C7_CC, 'CTT_DESC01')))
			
			AADD((oHtml:ValByName("it.conta"    )), iif(empty(SC7->C7_CONTA), Space(TamSx3('C7_CONTA')[1])     , SC7->C7_CONTA))
			AADD((oHtml:ValByName("it.cCont")), iif(empty(SC7->C7_CONTA), Space(TamSx3('CT1_DESC01')[1]), Posicione('CT1', 1, Xfilial('CT1') + SC7->C7_CONTA, 'CT1_DESC01')))
			//AADD((oHtml:ValByName("it.dtent"  )), cValToChar(SC7->C7_PRAZO))
			AADD((oHtml:ValByName("it.dtent"  )), dToC(SC7->C7_DATPRF))
	
			if lStyle
				AADD((oHtml:ValByName("it.style"  )), "display: block")
			endif
	
			if SC7->C7_MOEDA <> 1
				cPerc := posicione("SC8",3,xFilial("SC8")+SC7->C7_NUMCOT+SC7->C7_PRODUTO+SC7->C7_FORNECE+SC7->C7_LOJA,"C8_IMPPREV")
	
				nPreco := (XMOEDA(SC7->C7_PRECO + (SC7->C7_VALEMB/SC7->C7_QUANT),SC7->C7_MOEDA,1,dEmissao,2,SC7->C7_TXMOEDA))
				nPreco := nPreco + (nPreco * (cPerc/100) )
//				nTotalR := XMOEDA(SC7->C7_TOTAL+SC7->C7_VALEMB,SC7->C7_MOEDA,1,dEmissao)
				nTotalR := XMOEDA(SC7->C7_TOTAL+SC7->C7_VALEMB,SC7->C7_MOEDA,1,dEmissao,2,SC7->C7_TXMOEDA)
	            _vDesc := _vDesc+SC7->C7_VLDESC
				
				//Inclui o valor do IPI no item
				//M�rio Faria - 25/01/13
				nValIPI := 0//posicione("SC8",3,xFilial("SC8")+SC7->C7_NUMCOT+SC7->C7_PRODUTO+SC7->C7_FORNECE+SC7->C7_LOJA,"C8_VALIPI")
				nTotalR := (nTotalR + (nTotalR * (cPerc/100))) + nValIPI
	
				nTotal := nTotal+nTotalR
				AADD((oHtml:ValByName("it.preco")),TRANSFORM(nPreco,'@E 999,999,999.99'))
				AADD((oHtml:ValByName("it.total")),TRANSFORM(nTotalR,'@E 999,999,999.99'))
			Else
				//Inclui o valor do IPI no item
				//M�rio Faria - 25/01/13
				nValIPI := 0//posicione("SC8",3,xFilial("SC8")+SC7->C7_NUMCOT+SC7->C7_PRODUTO+SC7->C7_FORNECE+SC7->C7_LOJA,"C8_VALIPI")
				nTotalR := SC7->C7_TOTAL + SC7->C7_VALEMB + nValIPI
				_vDesc := _vDesc+SC7->C7_VLDESC
				nTotal := nTotal + nTotalR
				AADD((oHtml:ValByName("it.preco")),TRANSFORM(SC7->C7_PRECO+(SC7->C7_VALEMB/SC7->C7_QUANT),'@E 999,999,999.99'))
				AADD((oHtml:ValByName("it.total")),TRANSFORM(nTotalR,'@E 999,999,999.99'))
			EndIF    

			nFrete += SC7->C7_VALFRE
			
			cAuxTpF := Posicione('SA2',1,xFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_TIPO")
	//		aImpAux := 	U_fImpTcp(SC7->C7_FORNECE,SC7->C7_LOJA,cAuxTpF,SC7->C7_PRODUTO,SC7->C7_TES,SC7->C7_QUANT,SC7->C7_PRECO,nTotalR) 
			nTotImp += SC7->C7_VALIPI+SC7->C7_VALSOL
			                               
			ltem := .f.
			for I := 1 to len(aIten)
				if aIten[i][1] == SC7->C7_PRODUTO
					lTem := .t.
					aIten[i][2] += SC7->C7_QUANT
				EndIF
			next i
	
			if !lTem
				aadd(aIten,{SC7->C7_PRODUTO,SC7->C7_QUANT})
			EndIF
				    
		    IF !EMPTY(SC7->C7_NUMSC)
		    	cChaveAne += ",'SC1"+SC7->C7_FILIAL+SC7->C7_NUMSC+SC7->C7_ITEMSC + "'"    
		    ENDIF	 
		    
		    DBSelectArea('SC8')
		    SC8->(dbSetOrder(3))
		    IF !EMPTY(SC7->C7_NUMCOT) .AND. SC8->(dbSeek(SC7->C7_FILIAL+SC7->C7_NUMCOT+SC7->C7_PRODUTO+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_NUM+SC7->C7_ITEM))
		    	cChaveAne += ",'SC8"+SC8->C8_FILIAL+SC8->C8_NUM+SC8->C8_ITEM+SC8->C8_ITEMGRD+SC8->C8_FORNECE+SC8->C8_LOJA+caracEsp(SC8->C8_FORNOME)+ "'"    
		    ENDIF
			
			SC7->(dbSkip())
		Enddo
		
    	cChaveAne += "%"
		
		nTotal := nTotal	
		oHtml:ValByName("lbValor",TRANSFORM(nTotal,'@E 999,999,999.99'))
		oHtml:ValByName("lbimp",TRANSFORM(nTotImp,'@E 999,999,999.99'))
		oHtml:ValByName("lValFre",TRANSFORM(nFrete,'@E 999,999,999.99'))
		oHtml:ValByName("lbtotal",TRANSFORM(nTotal+nTotImp + nFrete-_vDesc,'@E 999,999,999.99'))
		oHtml:ValByName("lbdes",TRANSFORM(_vDesc,'@E 999,999,999.99'))	    

   
   		SC7->(DBSELECTAREA('SC7'))
		SC7->(DBSEEK(xFilial('SC7')+cNum))
	  //	if empty(alltrim(SC7->C7_CONTRA))
		
		cSql := "	SELECT SC8.C8_NUM,SC8.C8_FORNECE,SC8.C8_PRODUTO, " + CRLF
		cSql += "		SC8.C8_LOJA, A2_NOME,SC8.C8_MOEDA,sum(SC8.C8_QUANT) as C8_QUANT, SUM(C8_VALFRE) AS C8_VALFRE," + CRLF
		cSql += "		sum(SC8.C8_TOTAL+C8_VALEMB) AS C8_TOTAL, SUM(C8_VALIPI) AS C8_VALIPI , SUM(C8_VLDESC) AS C8_VALDESC" + CRLF
		cSql += "	FROM "+RetSqlName("SC8")+" SC8 " + CRLF
		cSql += " 	INNER JOIN "+RetSqlName("SA2")+" SA2 ON " + CRLF
		cSql += "			A2_COD = SC8.C8_FORNECE" + CRLF
		cSql += "		AND A2_LOJA = SC8.C8_LOJA " + CRLF
		cSql += "	WHERE SC8.C8_FILIAL ='"+SC7->C7_FILIAL+"'" + CRLF
		cSql += "    	AND SC8.C8_NUM = '"+SC7->C7_NUMCOT+"'" + CRLF
		cSql += "    	AND SC8.C8_FORNECE <> '"+SC7->C7_FORNECE+"' " + CRLF
		cSql += "    	AND SA2.D_E_L_E_T_<>'*' " + CRLF
		cSql += "    	AND SC8.C8_PRODUTO IN (SELECT SC7.C7_PRODUTO " + CRLF
		cSql += "   							FROM "+RetSqlName("SC7")+" SC7 " + CRLF
		cSql += "    						WHERE SC7.C7_NUM = '"+SC7->C7_NUM+"'" + CRLF
		//	cSql +="    						AND C7_ITEMSC = C8_ITEMSC" + CRLF
		cSql += "    						AND SC7.D_E_L_E_T_<>'*') " + CRLF
		cSql += "		AND C8_TOTAL > 0 " + CRLF
		cSql += "		AND SC8.D_E_L_E_T_<>'*' " + CRLF
		cSql += "	GROUP BY SC8.C8_NUM,SC8.C8_FORNECE, SC8.C8_LOJA, A2_NOME, SC8.C8_MOEDA,SC8.C8_FORNECE,SC8.C8_PRODUTO, " + CRLF
		cSql += "  			 SC8.C8_LOJA, A2_NOME " + CRLF
		        
		If Select('TRBC8')<>0
			TRBC8->(DBCloseArea()) 				
		EndIF
		
		TcQuery cSql new Alias "TRBC8"
		
		//fornecedor - produto - quantidade cotada - val. Unit. Vlr. Total
		cFor := Alltrim(TRBC8->A2_NOME)
		nTot:=0
		lAchou:=.f.
		aItens:={}
		aFor:={}
		TRBC8->(dbGoTop())
		While !TRBC8->(EOF())
			AADD(aitens,{TRBC8->A2_NOME,TRBC8->C8_PRODUTO,TRBC8->C8_QUANT,TRBC8->C8_TOTAL,"",TRBC8->C8_MOEDA,TRBC8->C8_NUM + TRBC8->C8_FORNECE + TRBC8->C8_LOJA,TRBC8->C8_VALIPI,TRBC8->C8_VALDESC,TRBC8->C8_VALFRE})
			if aScan(aFor,TRBC8->A2_NOME)==0
				aadd(aFor,TRBC8->A2_NOME)
			EndIF
			
			TRBC8->(dbSkip())
		Enddo
		lProd:=.f.
		lPedMai:=.F.
		lPedMen:=.F.
		for a:=1 to len(aFor)
			for b:=1 to len(aItens)
				if afor[a]==aItens[b][1]//verifica o fornecedor\
					for c:=1 to len(aIten)
						if aiten[c][1]== aItens[b][2]
							lProd:=.T.
							if aiten[c][2] > aItens[b][3]
								lPedMai:=.t.
							EndIF
							if aiten[c][2] < aItens[b][3]
								lPedMen:=.t.
							EndIF
						EndIF
					Next
					
					IF !lProd
						aitens[b][5]:=alltrim(aitens[b][5])+"Cotacao com produtos que nao tem no pedido."
						lProd:=.f.
					EndIf
					
					If lPedMai
						aitens[b][5]:=alltrim(aitens[b][5])+"Quantidade do pedido maior que a cotada."
					EndIf
					
					If lPedMen
						aitens[b][5]:=alltrim(aitens[b][5])+"Quantidade do pedido menor que a cotada."
						
					EndIf
				EndIf
			Next
		Next
		aForn2:={}
		for c:=1 to len(aFor)
			lItem:=.f.
			
			for b:=1 to len(aIten)
				for d := 1 to len(aItens)
					if aItens[d][1]==aFor[c]
						if aItens[d][2] == aIten[b][1]
							lItem:=.t.
						EndIF
					EndIF
				Next
				if !lItem
					aadd(aForn2,aFor[c])
				Else
					lItem:=.f.
				EndIf
			Next
		Next
		
		cMens:=""
		If Len(aItens) > 0
			_cOutCot:=""
			lMens:=.F.
			cFor:=aItens[1][1]
			
			nDesc := 0
			nTot:=0
			nValFre := 0
			nTotImp2 := 0
			_CMoeda:=aItens[1][5]
			For i:=1 to len(aItens)
				if cFor <> aItens[i][1]
					_cOutCot += "<tr>"
					_cOutCot += "<td><font size='2' face='Arial'>" + Alltrim(cFor+if( _CMoeda > 1 ,"(Estimated Values - Import)","")) + "</font></td>"
					nPos:=aScan(aForn2,cFor)
					if nPos > 0
						cMens:=alltrim(cMens)+"Supplier sent an incomplete quotation (doesn't have all needed products and/or services)."
					EndIF
					if !Empty(alltrim(cMens))
						
						_cOutCot += "<td><font size='2' face='Arial'>" + Alltrim(cMens) + "</font></td>"
						lMens:=.t.
						cMens:=""
					Else
						_cOutCot += "<td><font size='2' face='Arial'>&nbsp;</font></td>"
					EndIF
					If _CMoeda > 1
						cPerc	:= posicione("SC8",1,xFilial("SC8")+_cChave,"C8_IMPPREV")
						nTot	:= XMOEDA(nTot,_CMoeda,1,dEmissao)
						//					nTot:=nTot+(nTot * (cPerc/100) )
						
						nDesc	+= XMOEDA(nDesc,_CMoeda,1,dEmissao)
						nValFre	+= XMOEDA(nValFre,_CMoeda,1,dEmissao)
						nTotImp2	+= XMOEDA(nTotImp2,_CMoeda,1,dEmissao)
//					Else
//						nTotImp2 += aItens[i][8]
//						nValFre += aItens[i][10]
//						nDesc += aItens[i][9]
					EndIf
					_cOutCot += "<td align='right'><font size='2' face='Arial'>" + Transform(nTot,'@E 999,999,999.99') + "</font></td>"//total
					_cOutCot += "<td align='right'><font size='2' face='Arial'>" + Transform(nTotImp2,'@E 999,999,999.99') + "</font></td>"//impostos
					_cOutCot += "<td align='right'><font size='2' face='Arial'>" + Transform(nTot+nTotImp2 + nValFre- nDesc,'@E 999,999,999.99') + "</font></td>"//total
					_cOutCot += "</tr>"
					
					cFor := aItens[i][1]
					nTot := 0
					nDesc := 0
					nValFre := 0
					nTotImp2:=0
				EndIf
				nTot	+= aItens[i][4]
				nDesc	+= aItens[i][9]
				nValFre += aItens[i][10]
				nTotImp2+= aItens[i][8]
				cMens	:= alltrim(cMens)+if(Empty(alltrim(cMens)),""," - ") + aItens[i][5]
				_CMoeda	:= aItens[i][6]
				_cChave	:= aItens[i][7]
			Next
			_cOutCot += "<tr>"
			_cOutCot += "<td><font size='2' face='Arial'>" + Alltrim(cFor+if( _CMoeda > 1 ,"(Estimated Values - Import)","")) + "</font></td>"
			nPos:=aScan(aForn2,cFor)
			if nPos > 0
				cMens:=alltrim(cMens)+" Supplier sent an incomplete quotation (doesn't have all needed products and/or services)."
			EndIF
			if !Empty(alltrim(cMens))
				
				_cOutCot += "<td><font size='2' face='Arial'>" + Alltrim(cMens) + "</font></td>"
				lMens:=.t.
			EndIF
			If _CMoeda > 1
				cPerc:=posicione("SC8",1,xFilial("SC8")+_cChave,"C8_IMPPREV")
				nTot:=XMOEDA(nTot,_CMoeda,1,dEmissao)
				nTot:=nTot+(nTot * (cPerc/100) )
				nTotImp2 := XMOEDA(nTotImp2,_CMoeda,1,dEmissao)
			EndIf
			
			If Empty(Alltrim(cMens))
				_cOutCot += "<td><font size='2' face='Arial'>&nbsp;</font></td>"
			EndIf
			_cOutCot += "<td align='right'><font size='2' face='Arial'>" + Transform(nTot,'@E 999,999,999.99') + "</font></td>"
			_cOutCot += "<td align='right'><font size='2' face='Arial'>" + Transform(nTotImp2,'@E 999,999,999.99') + "</font></td>"//impostos
			_cOutCot += "<td align='right'><font size='2' face='Arial'>" + Transform(nTot+nTotImp2+nValFre- nDesc,'@E 999,999,999.99') + "</font></td>"//total
			_cOutCot += "</tr>"
			
			
			_cCab :=  " <table border='1' width='1500'>"
			_cCab  += " <tr>"
			_cCab  += " 	<td  bgcolor='#DFEFFF' height='18'>"
			_cCab  += " 		<font face='Arial'>Provider</font>"
			_cCab  += " </td>"
			//_cCab  += " 	<td align='right' width='101' bgcolor='#DFEFFF' height='18'>"
			_cCab  += " 	<td  bgcolor='#DFEFFF' height='18'>"
			_cCab  += " 		<font face='Arial'>Notes</font>"
			_cCab  += " 	</td>"
			_cCab  += " 	<td  bgcolor='#DFEFFF' height='18'>"
			_cCab  += " 		<font face='Arial'>Unit Value</font>"
			_cCab  += " 	</td>"
			_cCab  += " 	<td  bgcolor='#DFEFFF' height='18'>"
			_cCab  += " 		<font face='Arial'>Taxes</font>"
			_cCab  += " 	</td>"
			_cCab  += " 	<td bgcolor='#DFEFFF' height='18'>"
			_cCab  += " 		<font face='Arial'>Total Value + Freight</font>"
			_cCab  += " 	</td>"
			_cCab  += " </tr>"
			
			_cOutCot += "</table>"
			_cOutCot:=_cCab+_cOutCot
			
		Else
			
			_cOutCot := "No other quotations."
			
		Endif
		TRBC8->(dbCloseArea()) 
        
		oHtml:ValByName("cotacoes",_cOutCot)       
		
		

		cSql :="	SELECT CX_XNATURE , ED_DESCRIC, CX_CC ,CX_ITEMCTA , SUM((CX_PERC * C7_TOTAL)/100) AS VALOR" + CRLF 	
		cSql +="	FROM "+RetSqlName("SC7")+" SC7 " + CRLF 
		cSql +="	INNER JOIN "+RetSqlName("SCX")+" SCX ON CX_FILIAL = C7_FILIAL AND CX_SOLICIT = C7_NUMSC AND CX_ITEMSOL = C7_ITEMSC AND SCX.D_E_L_E_T_<>'*'" + CRLF 
		cSql +="	INNER JOIN "+RetSqlName("SED")+" SED ON ED_FILIAL ='"+xFilial('SED')+"' AND ED_CODIGO = CX_XNATURE AND SED.D_E_L_E_T_<>'*'" + CRLF 
		cSql +="	WHERE SC7.C7_NUM = '"+SC7->C7_NUM+"'" + CRLF
		cSql +="	AND SC7.C7_FILIAL = '"+SC7->C7_FILIAL+"'" + CRLF
		cSql +="	AND SC7.C7_ITEM = '"+SC7->C7_ITEM+"'" + CRLF
		cSql +="    AND SC7.D_E_L_E_T_<>'*' " + CRLF
		cSql +="    GROUP BY CX_XNATURE , ED_DESCRIC, CX_CC ,CX_ITEMCTA " + CRLF
		
		If Select('TRBZ21')<>0
			TRBZ21->(DBCloseArea())
		EndIF
		_cOutCot := ""
		TcQuery cSql new Alias "TRBZ21"
		DbSelectArea("TRBZ21")
		TRBZ21->(DbGoTop())
		If !TRBZ21->(EOF())	
			While !TRBZ21->(EOF())	
				_cOutCot += "<tr>"                                                                                                      
				_cOutCot += "<td align='left'><font size='2' face='Arial'>" + TRBZ21->CX_XNATURE + "</font></td>"//valor
				_cOutCot += "<td align='left'><font size='2' face='Arial'>" + TRBZ21->ED_DESCRIC + "</font></td>"//valor
				_cOutCot += "<td align='left'><font size='2' face='Arial'>" + TRBZ21->CX_CC + '-' +POSICIONE('CTT',1,xFilial('CTT')+TRBZ21->CX_CC,'CTT_DESC01')+"</font></td>"//valor
				_cOutCot += "<td align='left'><font size='2' face='Arial'>" + TRBZ21->CX_ITEMCTA + '-' +POSICIONE('CTD',1,xFilial('CTD')+TRBZ21->CX_ITEMCTA,'CTD_DESC01')+ "</font></td>"//valor
				_cOutCot += "<td align='right'><font size='2' face='Arial'>" + Transform(TRBZ21->VALOR,'@E 999,999,999.99') + "</font></td>"//valor
				_cOutCot += "</tr>"
				TRBZ21->(DbSkip())
			Enddo
	
			_cCab :=  " <table border='1' width='1500'>"
			_cCab  += " <tr>"
			_cCab  += " 	<td  bgcolor='#DFEFFF' height='18'>"
			_cCab  += " 		<font face='Arial'>Classification</font>"
			_cCab  += " </td>"
			_cCab  += " 	<td  bgcolor='#DFEFFF' height='18'>"
			_cCab  += " 		<font face='Arial'>Classification Description</font>"
			_cCab  += " 	</td>"
			_cCab  += " 	<td  bgcolor='#DFEFFF' height='18'>"
			_cCab  += " 		<font face='Arial'>Cost Center</font>"
			_cCab  += " 	</td>"
			_cCab  += " 	<td  bgcolor='#DFEFFF' height='18'>"
			_cCab  += " 		<font face='Arial'>Accounting Item</font>"
			_cCab  += " 	</td>"
			_cCab  += " 	<td  bgcolor='#DFEFFF' height='18'>"
			_cCab  += " 		<font face='Arial'>Value</font>"
			_cCab  += " 	</td>"
			_cCab  += " </tr>"
		
			_cOutCot +="</table>"
			_cOutCot:=_cCab+_cOutCot
		Else
			_cOutCot := "No apportionment in this measurement."
		Endif
		TRBZ21->(dbCloseArea())
		oHtml:ValByName("rateio",_cOutCot)   
			
				    /*
		  Alterado por Ricardo Martins - 23/08
		  Adicinando listagem de aprovadores e status de cada alcada
		*/      
		vfilial := xfilial('SCR')		
		BeginSql Alias "QSCRX"
			SELECT SCR.*
			FROM %table:SCR% SCR
			WHERE SCR.CR_FILIAL = %Exp:vfilial%
			AND SCR.CR_NUM = %Exp:cNum%
			AND SCR.CR_TIPO = 'PC'
			AND SCR.%NotDel%
		EndSql
	
		
		while !QSCRX->(EOF())  

		    _vStatusW := QSCRX->CR_STATUS 
		    if _vStatusW == "01"
				_vStatusW := "Waiting for the others levels approvement"
		    endif
		    if _vStatusW == "02"
				_vStatusW := "Pending"
			endif	
		    if _vStatusW == "03"
				_vStatusW := "Approved"
			endif	
		    if _vStatusW == "04"
				_vStatusW := "Blocked"	
			endif	
			if _vStatusW == "05"
				_vStatusW := "Approved / Blocked by level"	
			endif									
			AADD((oHtml:ValByName("ap.nivelalcada")),QSCRX->CR_NIVEL)	  
			AADD((oHtml:ValByName("ap.nomeaprovadorresp")),fGetUsrName(QSCRX->CR_USER))	 
			AADD((oHtml:ValByName("ap.statusalcada")),_vStatusW) 	 
			AADD((oHtml:ValByName("ap.nomeaprovador")),u_xRetAprv(QSCRX->CR_USERLIB,STOD(QSCRX->CR_DATALIB))) 	  
			AADD((oHtml:ValByName("ap.dataaprocacao")),STOD(QSCRX->CR_DATALIB))    
				
			QSCRX->(dbSkip())

		enddo
	 	QSCRX->(dbCloseArea())
	    /* ---------------------------------------------------------- */
	    
	    oProc := addAnexos(oProc,cChaveAne,'1')
	    
	
		//Verifica se deve inclui o link de observa��o
		//********************************************************//
//		If _cNiv == ("03")
//			oHtml:ValByName("cLinkObs","http://" + cEndSrv + ":" + AllTrim(GetMv("TCP_PORTWF")) + "/pp/U_WEBMSG.APW?keyvalue=" + cLinkMsg)
//		ElseIf _cNiv == ("04")
//			oHtml:ValByName("cMsg",cLinkMsg)
//		EndIF
		//********************************************************//
		
		dbSelectArea('SC1')
		SC1->(dbSetOrder(1))
		_cSolic := ''
		if !empty(SC7->C7_NUMSC) .AND. SC1->(dbSeek(SC7->C7_FILIAL+SC7->C7_NUMSC+SC7->C7_ITEMSC))
		
			PswOrder(1)
			
			_cUsuSol := IF(!EMPTY(SC1->C1_USER),SC1->C1_USER,SC1->C1_REQUISI)
			
			If PswSeek(ALLTRIM(_cUsuSol),.t.)
				aInfo := PswRet()
				_cSolic := ' ; '+alltrim(aInfo[1,14])
			endif
		endif
		
		If nxi == 1 // email com resposta
			oProc:cTo := cMail
		Else // e-mail de acompanhamento
  			ccpEmail := _cMailComp
  			oProc:cTo := ccpEmail +_cSolic
		Endif
	
		oProc:Start()     
		oProc:Finish()	
	/*
	  Realiza a montagem do email para pedido via contrato
	*/	
	Else
			cChaveAne := "%"
			_cCx = SC7->C7_CONTRA
	        if alltrim(_cCx) == ''
		        _cCon := CND->CND_CONTRA
		        _cContRev := CND->CND_REVISA 
		        _cMed := CND->CND_NUMMED 
	        else
				_cCon := SC7->C7_CONTRA  
				_cContRev := SC7->C7_CONTREV
				_cMed := SC7->C7_MEDICAO     
	        endif
	
		//inluido por Rodrigo Slisinski 10/08/2017 para incluir a natureza e o centro de custo do contrato antes do envio para o wf
			cQueryZ21 := " SELECT TOP 1 Z21_CCUSTO,Z21_NATURE  FROM "+RetSqlName('Z21')+" Z21 "
			cQueryZ21 += " WHERE Z21.Z21_FILIAL = '"+xFilial('Z21')+"' AND Z21.Z21_CONTRA = '"+_cCon+"' " // AND Z21.Z21_REVISA = '"+_cContRev+"'" 
			cQueryZ21 += "   AND Z21.Z21_NUMMED = '"+_cMed+"' AND Z21.D_E_L_E_T_ != '*' "
			cQueryZ21 += " ORDER BY Z21_VALOR DESC "
			If (Select("TMPZ21") <> 0)
				TMPZ21->(DbCloseArea())
			Endif
			TcQuery cQueryZ21 new alias 'TMPZ21'
		
			if !TMPZ21->(eof())
				RECLOCK('SC7',.F.)
				SC7->C7_CC		:= TMPZ21->Z21_CCUSTO
				SC7->C7_XNATURE	:= TMPZ21->Z21_NATURE
				SC7->(MSUnlock())
			EndIF
		
              
	   //	_cMed := SC7->C7_MEDICAO 
		cHtmlCon += ''	
		dEmissao := SC7->C7_EMISSAO
		cCondPag := Posicione("SE4",1,xFilial('SE4')+SC7->C7_COND,"E4_DESCRI")
		cNum     := SC7->C7_NUM
		
		
		
		oHtml:ValByName("Contrato" ,_cCon)
		If nXi != 1
			oHtml:ValByName("lb_empresa",SM0->M0_NOMECOM)
		endif
		oHtml:ValByName("EMISSAO"   ,SC7->C7_EMISSAO)
		oHtml:ValByName("pedido"    ,SC7->C7_NUM)
		oHtml:ValByName("FORNECEDOR",SC7->C7_FORNECE)
		oHtml:ValByName("cond_pag"  ,AllTrim(cCondPag))
		oHtml:ValByName("cod_compra",fGetUsrName(SC7->C7_USER))
		
		/* Removido at� validarem o processo completo
		oHtml:ValByName("lb_obs",SC7->C7_XOBSENG)
		oHtml:ValByName("lb_obsPt",SC7->C7_OBS)
		*/
		oHtml:ValByName("lb_obs",STRTRAN( SC7->C7_OBS,Chr(13) + Chr(10) ,'</br>'))
	
		oHtml:ValByName("moeda",U_getWFMoe(SC7->C7_MOEDA))
		dbSelectArea('SA2')
		SA2->(dbSetOrder(1))
		SA2->(dbSeek(xFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA))
		oHtml:ValByName("lb_nome",SA2->A2_NREDUZ+if(SC7->C7_MOEDA <> 1,"(Valores estimados - Importacao)",""))
	
		cLink := If(nxi == 1, embaralha(SC7->C7_FILIAL+SC7->C7_NUM+cAprv+_cNiv+cEmpAnt,0),'')
		
		If nXi == 1
			oHtml:ValByName("cLinkOk", cHttpServer + "/pp/U_weblogA.apw?keyvalue=" + cLink) // confirma
			oHtml:ValByName("cLinkCn", cHttpServer + "/pp/U_weblogR.apw?keyvalue=" + cLink) // cancela
		endif

		aIten := {}
		nTotal := 0
		
		_vDesc := 0
		nFrete := 0
		SC7->(dbSetOrder(1))
		SC7->(dbSeek(xFilial('SC7')+cNum))
	
		oHtml:ValByName("styleh","display: block")
		_vValorSaldo := 0
		While !SC7->(EOF()) .And. SC7->C7_NUM == cNum
			AADD((oHtml:ValByName("it.item")),SC7->C7_ITEM)
			AADD((oHtml:ValByName("it.codigo")),SC7->C7_PRODUTO)
			AADD((oHtml:ValByName("it.descricao")),RetDesc(SC7->C7_PRODUTO))
			AADD((oHtml:ValByName("it.quant")),TRANSFORM(SC7->C7_QUANT,'@E 999,999.99'))
	
			//Campos para o centro de custo e data de entrega
			//Lucas - 11/10/13
			AADD((oHtml:ValByName("it.ctt"    )), iif(empty(SC7->C7_CC), Space(TamSx3('C7_CC')[1])     , SC7->C7_CC))
			AADD((oHtml:ValByName("it.cttdesc")), iif(empty(SC7->C7_CC), Space(TamSx3('CTT_DESC01')[1]), Posicione('CTT', 1, Xfilial('CTT') + SC7->C7_CC, 'CTT_DESC01')))
			//AADD((oHtml:ValByName("it.dtent"  )), cValToChar(SC7->C7_PRAZO))
			AADD((oHtml:ValByName("it.dtent"  )), dToC(SC7->C7_DATPRF))	

			if SC7->C7_MOEDA <> 1
				cPerc := posicione("SC8",3,xFilial("SC8")+SC7->C7_NUMCOT+SC7->C7_PRODUTO+SC7->C7_FORNECE+SC7->C7_LOJA,"C8_IMPPREV")
	
				nPreco := (XMOEDA(SC7->C7_PRECO + (SC7->C7_VALEMB/SC7->C7_QUANT),SC7->C7_MOEDA,1,dEmissao,2,SC7->C7_TXMOEDA))
				nPreco := nPreco + (nPreco * (cPerc/100) )
				
//				nTotalR := XMOEDA(SC7->C7_TOTAL+SC7->C7_VALEMB,SC7->C7_MOEDA,1,dEmissao)
				nTotalR := XMOEDA(SC7->C7_TOTAL+SC7->C7_VALEMB,SC7->C7_MOEDA,1,dEmissao,2,SC7->C7_TXMOEDA)
	
				//Inclui o valor do IPI no item
				//M�rio Faria - 25/01/13
				nValIPI := 0//posicione("SC8",3,xFilial("SC8")+SC7->C7_NUMCOT+SC7->C7_PRODUTO+SC7->C7_FORNECE+SC7->C7_LOJA,"C8_VALIPI")
				nTotalR := (nTotalR + (nTotalR * (cPerc/100))) + nValIPI
	
				nTotal := nTotal+nTotalR
				
				_vValorAtual := Posicione("CN9",1,SC7->C7_FILIAL+_cCon+_cContRev,"CN9_VLATU") 
				_vTotalContrato := _vValorAtual			
   				
   				
			   	AADD((oHtml:ValByName("it.preco")),TRANSFORM(_vTotalContrato,'@E 999,999,999.99'))
			   	
			   	
//				//Retorna valor dos pedidos em aberto
//				nValAberto := u_pedidosAb(_cCon,_cContRev)
//				
//				AADD((oHtml:ValByName("it.valorsaldoCn9")),TRANSFORM(_vValorSaldo,'@E 999,999,999.99'))	
//				AADD((oHtml:ValByName("it.valorsaldo")),TRANSFORM(_vValorSaldo+nValAberto,'@E 999,999,999.99'))	
//			  
				AADD((oHtml:ValByName("it.total")),TRANSFORM(nTotalR,'@E 999,999,999.99'))
			Else
				//Inclui o valor do IPI no item
				//M�rio Faria - 25/01/13
				nValIPI := 0//posicione("SC8",3,xFilial("SC8")+SC7->C7_NUMCOT+SC7->C7_PRODUTO+SC7->C7_FORNECE+SC7->C7_LOJA,"C8_VALIPI")
				nTotalR := SC7->C7_TOTAL + SC7->C7_VALEMB + nValIPI
	
				nTotal := nTotal + nTotalR
				    
				_vValorAtual :=Posicione("CN9",1,SC7->C7_FILIAL+_cCon+_cContRev,"CN9_VLATU") 
				_vTotalContrato := _vValorAtual
					
			   	AADD((oHtml:ValByName("it.preco")),TRANSFORM(_vTotalContrato,'@E 999,999,999.99'))
				AADD((oHtml:ValByName("it.total")),TRANSFORM(nTotalR,'@E 999,999,999.99')) 

			EndIF

			
			_vDesc += SC7->C7_VLDESC
			nFrete += SC7->C7_VALFRE
			
			cAuxTpF := Posicione('SA2',1,xFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_TIPO")
	//		aImpAux := 	U_fImpTcp(SC7->C7_FORNECE,SC7->C7_LOJA,cAuxTpF,SC7->C7_PRODUTO,SC7->C7_TES,SC7->C7_QUANT,SC7->C7_PRECO,nTotalR) 
			nTotImp += SC7->C7_VALIPI+SC7->C7_VALSOL
			                               
			ltem := .f.
			for I := 1 to len(aIten)
				if aIten[i][1] == SC7->C7_PRODUTO
					lTem := .t.
					aIten[i][2] += SC7->C7_QUANT
				EndIF
			next i
	
			if !lTem
				aadd(aIten,{SC7->C7_PRODUTO,SC7->C7_QUANT})
			EndIF
			SC7->(dbSkip())
		Enddo 
		       
		_vValorSaldo := Posicione("CN9",1,xFilial('SC7')+_cCon+_cContRev,"CN9_SALDO")
		_vValorSaldo := if(IsInCallStack("CNTA120") .OR. IsInCallStack("CNTA121") ,_vValorSaldo - nTotal,_vValorSaldo) 
		
		//Retorna valor dos pedidos em aberto
		nValAberto := u_pedidosAb(_cCon,_cContRev,cNum)
		
		oHtml:ValByName("valorsaldoCn9",TRANSFORM(_vValorSaldo,'@E 999,999,999.99'))
		oHtml:ValByName("valorsaldo",TRANSFORM(_vValorSaldo + nValAberto+ nTotal  ,'@E 999,999,999.99')) //if(IsInCallStack("CNTA120"),nTotal,0)
		oHtml:ValByName("valorcontrato",TRANSFORM(_vTotalContrato,'@E 999,999,999.99'))
		oHtml:ValByName("totalpedido",TRANSFORM(nTotal,'@E 999,999,999.99'))		
	
		oHtml:ValByName("lbValor",TRANSFORM(nTotal,'@E 999,999,999.99'))
		oHtml:ValByName("lbimp",TRANSFORM(nTotImp,'@E 999,999,999.99'))
		oHtml:ValByName("lbtotal",TRANSFORM(nTotal+nTotImp,'@E 999,999,999.99'))
	     
   		/*
		  Alterado por Ricardo Martins - 23/08
		  Adicinando listagem de aprovadores e status de cada alcada
		*/     
		
		vfilial := xfilial('SCR')		
		BeginSql Alias "QSCRX"
			SELECT SCR.*
			FROM %table:SCR% SCR
			WHERE SCR.CR_FILIAL = %Exp:vfilial%
			AND SCR.CR_NUM = %Exp:cNum%
			AND SCR.CR_TIPO = 'PC'
			AND SCR.%NotDel%
		EndSql
	
		
			while !QSCRX->(EOF())  
	
			   _vStatusW := QSCRX->CR_STATUS 
			   if _vStatusW == "01"
					_vStatusW := "Waiting for the others levels approvement"
			   endif
			   if _vStatusW == "02"
					_vStatusW := "Pending"
				endif	
			   if _vStatusW == "03"
					_vStatusW := "Approved"
				endif	
			  if _vStatusW == "04"
					_vStatusW := "Blocked"	
				endif										
				AADD((oHtml:ValByName("ap.nivelalcada")),QSCRX->CR_NIVEL)
	  
				AADD((oHtml:ValByName("ap.nomeaprovadorresp")),fGetUsrName(QSCRX->CR_USER))  
	 
				AADD((oHtml:ValByName("ap.statusalcada")),_vStatusW)  
	 
				AADD((oHtml:ValByName("ap.nomeaprovador")),u_xRetAprv(QSCRX->CR_USERLIB,STOD(QSCRX->CR_DATALIB)))  
		  
				AADD((oHtml:ValByName("ap.dataaprocacao")),STOD(QSCRX->CR_DATALIB))    
			
		
				QSCRX->(dbSkip())
	
			enddo
	 	QSCRX->(dbCloseArea())
	          
	
		SC7->(DBSELECTAREA('SC7'))
		SC7->(DBSEEK(xFilial('SC7')+cNum))
		
		cSql :="	SELECT * " + CRLF 	
		cSql +="	FROM "+RetSqlName("Z21")+" Z21 " + CRLF 
		cSql +="	INNER JOIN "+RetSqlName("SED")+" SED" + CRLF 
		cSql +="	ON ED_FILIAL ='"+xFilial('SED')+"'" + CRLF 
		cSql +="	AND ED_CODIGO = Z21_NATURE" + CRLF 
		cSql +="	AND SED.D_E_L_E_T_<>'*'" + CRLF 
		cSql +="	WHERE Z21.Z21_NUMMED = '"+_cMed+"'" + CRLF
		cSql +="	AND Z21.Z21_FILIAL = '"+SC7->C7_FILIAL+"'" + CRLF
		cSql +="	AND Z21.Z21_CONTRA = '"+_cCon+"'" + CRLF
   //	 	cSql +="	AND Z21.Z21_REVISA = '"+CND->CND_REVISA+"'" + CRLF
		cSql +="    AND Z21.D_E_L_E_T_<>'*' " + CRLF
	
		If Select('TRBZ21')<>0
			TRBZ21->(DBCloseArea())
		EndIF
		_cOutCot := ""
		TcQuery cSql new Alias "TRBZ21"
		DbSelectArea("TRBZ21")
		TRBZ21->(DbGoTop())
		If !TRBZ21->(EOF())	
			While !TRBZ21->(EOF())	 
			    _cOutCot += "<tr>"                                                                                                
				_cOutCot += "<td align='left'><font size='2' face='Arial'>" + TRBZ21->Z21_NATURE + "</font></td>"//valor
				_cOutCot += "<td align='left'><font size='2' face='Arial'>" + TRBZ21->ED_DESCRIC + "</font></td>"//valor
				_cOutCot += "<td align='left'><font size='2' face='Arial'>" + TRBZ21->Z21_CCUSTO + '-' +POSICIONE('CTT',1,xFilial('CTT')+TRBZ21->Z21_CCUSTO,'CTT_DESC01')+"</font></td>"//valor
				_cOutCot += "<td align='left'><font size='2' face='Arial'>" + TRBZ21->Z21_ITEMCT + '-' +POSICIONE('CTD',1,xFilial('CTD')+TRBZ21->Z21_ITEMCT,'CTD_DESC01')+ "</font></td>"//valor
				_cOutCot += "<td align='right'><font size='2' face='Arial'>" + Transform(TRBZ21->Z21_VALOR,'@E 999,999,999.99') + "</font></td>"//valor
				_cOutCot += "</tr>"
				TRBZ21->(DbSkip())
			Enddo
	
			_cCab :=  " <table border='1' width='1100'>"
			_cCab  += " <tr>"
			_cCab  += " 	<td  bgcolor='#DFEFFF' height='18'>"
			_cCab  += " 		<font face='Arial'>Classification</font>"
			_cCab  += " </td>"
			_cCab  += " 	<td  bgcolor='#DFEFFF' height='18'>"
			_cCab  += " 		<font face='Arial'>Classification Description</font>"
			_cCab  += " 	</td>"
			_cCab  += " 	<td  bgcolor='#DFEFFF' height='18'>"
			_cCab  += " 		<font face='Arial'>Cost Center</font>"
			_cCab  += " 	</td>"
			_cCab  += " 	<td  bgcolor='#DFEFFF' height='18'>"
			_cCab  += " 		<font face='Arial'>Accounting Item</font>"
			_cCab  += " 	</td>"
			_cCab  += " 	<td  bgcolor='#DFEFFF' height='18'>"
			_cCab  += " 		<font face='Arial'>Value</font>"
			_cCab  += " 	</td>"
			_cCab  += " </tr>"
		
			_cOutCot +="</table>"
			_cOutCot:=_cCab+_cOutCot
		Else
			_cOutCot := "No apportionment in this measurement."
		Endif
		TRBZ21->(dbCloseArea())
		oHtml:ValByName("rateio",_cOutCot)   
		  
		_cContra := ''
   		IF  !Empty(Alltrim(SC7->C7_MEDICAO)) .OR. Alltrim(FunName()) == 'CNTA120' .OR. Alltrim(FunName()) == 'CNTA121'
   			
   			IF(EMPTY(SC7->C7_CONTRA))
   				_cContra := SC7->C7_CONTRA //CNE->CNE_CONTRA
	       		//cChaveAne := "%'CN9"+CNE->CNE_CONTRA + "'"
				//cChaveAne := "%'CND"+SC7->C7_FILIAL+CNE->CNE_CONTRA+CNE->CNE_REVISA +CNE->CNE_NUMMED+ "'"
				//cChaveAne += ",'CND"+ALLTRIM(CND->CND_FILIAL)+ALLTRIM(CND->CND_CONTRA)+ALLTRIM(CND->CND_REVISA) +ALLTRIM(CND->CND_NUMMED)+ "'"
				//cChaveAne += ",'CND"+CND->CND_FILIAL+CND->CND_CONTRA+CND->CND_NUMMED+ "'"
				//cChaveAne := "%'SC7"+SC7->C7_FILIAL+ SC7->C7_NUM+SC7->C7_ITEM + "'"
				cChaveAne := "%" + fBuildKey("SC7")
				//if  CND->CND_REVGER != CND->CND_REVISA
				//	cChaveAne += ",'CND"+CNE->CNE_FILIAL+CNE->CNE_CONTRA+CND->CND_REVGER +CNE->CNE_NUMMED+ "'%"
				//ELSE
					cChaveAne += '%'
				//ENDIF
   			ELSE
			   	
   				_cContra := SC7->C7_CONTRA
   				_cFornPd := SC7->C7_FORNECE+SC7->C7_LOJA
	       		
				DBSELECTAREA('CND')
				CND->(dbSetOrder(1))
				IF CND->(DBSEEK(SC7->C7_FILIAL+SC7->C7_CONTRA+SC7->C7_CONTREV +SC7->C7_PlANILH+SC7->C7_MEDICAO))
					//cChaveAne := "%'CN9"+SC7->C7_CONTRA + "'"
					cChaveAne := "%'CND"+SC7->C7_FILIAL+SC7->C7_CONTRA+SC7->C7_CONTREV +SC7->C7_MEDICAO+ "'"
					//cChaveAne += ",'CND"+ALLTRIM(CND->CND_FILIAL)+ALLTRIM(CND->CND_CONTRA)+ALLTRIM(CND->CND_REVISA) +ALLTRIM(CND->CND_NUMMED)+ "'"
					cChaveAne += "," + fBuildKey("CND")
					cChaveAne += ",'CND"+CND->CND_FILIAL+CND->CND_CONTRA+CND->CND_NUMMED+ "'"
					
					//cChaveAne += ",'SC7"+SC7->C7_FILIAL+ SC7->C7_NUM+SC7->C7_ITEM + "'"
					cChaveAne += "," + fBuildKey("SC7")

					_aAreaCnd := Lj7GetArea({"CND"}) 
					if  CND->CND_REVGER != CND->CND_REVISA
						cChaveAne += ",'CND"+CND->CND_FILIAL+CND->CND_CONTRA+CND->CND_REVGER +SC7->C7_MEDICAO+ "'%"
					else	
						cChaveAne += ",'CND"+SC7->C7_FILIAL+SC7->C7_CONTRA+SC7->C7_CONTREV +SC7->C7_MEDICAO+ "'%"
					endif
					
					Lj7RestArea(_aAreaCnd) 	
				ELSE
					cChaveAne := "%'CND"+SC7->C7_FILIAL+SC7->C7_CONTRA+SC7->C7_CONTREV +SC7->C7_MEDICAO+ "'%"
				ENDIF
   			ENDIF
	    	oHtml := buscaPag(oHtml,_cContra,_cFornPd)
	    		 
			oProc := addAnexos(oProc,cChaveAne,'2')
	    else
	    	oHtml:ValByName("pagamentos",'No other payments.')
	    ENDIF
	    
    	dbSelectArea('SC1')
		SC1->(dbSetOrder(1))
		_cSolic := ''
		if !empty(SC7->C7_NUMSC) .AND. SC1->(dbSeek(SC7->C7_FILIAL+SC7->C7_NUMSC+SC7->C7_ITEMSC))
		
			PswOrder(1)
			
			_cUsuSol := IF(!EMPTY(SC1->C1_USER),SC1->C1_USER,SC1->C1_REQUISI)
			
			If PswSeek(ALLTRIM(_cUsuSol),.t.)
				aInfo := PswRet()
				_cSolic := ' ; '+alltrim(aInfo[1,14])
			endif
		endif
	    
		If nxi == 1 // email com resposta
			oProc:cTo := cMail
		Else // e-mail de acompanhamento
			ccpEmail := _cMailComp
  			oProc:cTo := ccpEmail+_cSolic
		Endif
//		oProc:cTo :='EXT_EDUARDO.VIEIRA@TCP.COM.BR'
		oProc:Start()	
		    
		oProc:Finish()	
	EndIf

Next

SC7->(DBselectArea("SC7"))
SC7->(DBGOTO(recsc7))

reclock('ZLG',.T.)
	ZLG->ZLG_FILIAL	:= xFilial('ZLG')
	ZLG->ZLG_PEDIDO	:= SC7->C7_NUM
	ZLG->ZLG_PARA	:= cMail
	ZLG->ZLG_DATA	:= DDATABASE
	ZLG->ZLG_HORA	:= TIME()
	ZLG->ZLG_TITU	:= "Aprova��o Pedido de Compra N�: "+SC7->C7_NUM+" - N�vel " + _cNiv+" "
ZLG->(MsUnlock())

Restarea(cArea)

return

//-------------------------
/*/{Protheus.doc} RetDesc
Rotina para buscar a descricao do produto a partir do parametro

@author Lucas
@since 02/01/2014
@version 1.0
@param cCodProd, character, Retorna a descri��o do produto

@return cRet

@protected
/*/
//-------------------------
Static Function RetDesc( cCodProd )

Local aArea := GetArea()
Local cRet  := ''

dbSelectArea('SB1')
SB1->(dbSetOrder(1))
if SB1->(dbSeek(xFilial('SB1')+cCodProd))
	cRet := SB1->B1_DESC
endif

dbSelectArea('SB5')
SB5->(dbSetOrder(1))
if SB5->(dbSeek(xFilial('SB5')+cCodProd))
	cRet := SB5->B5_CEME
endif

RestArea(aArea)

return cRet                           



User Function fImpTcp(cCliFor,cLoja,cTipo,cProduto,cTes,nQtd,nPrc,nValor)
Local aImpostos := {}
Local aImp := {0,0}
MaFisIni(cCliFor,;               // 1-Codigo Cliente/Fornecedor
cLoja,;                         // 2-Loja do Cliente/Fornecedor
"F",;                         // 3-C:Cliente , F:Fornecedor
"N",;                         // 4-Tipo da NF
cTipo,;                         // 5-Tipo do Cliente/Fornecedor
MaFisRelImp("MTR700",{"SC7"}),;   // 6-Relacao de Impostos que suportados no arquivo
,;                               // 7-Tipo de complemento
,;                               // 8-Permite Incluir Impostos no Rodape .T./.F.
"SB1",;               // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
"MTR700")            // 10-Nome da rotina que esta utilizando a funcao


MaFisAdd(cProduto, cTes, nQtd, nPrc, 0, "", "",, 0, 0, 0, 0, nValor, 0)

aadd(aImpostos,"IT_VALICM")
aadd(aImpostos,"IT_ALIQICM") //               03    //Aliquota de ICMS
aadd(aImpostos,"IT_ALIQIPI") //               05    //Aliquota de IPI
aadd(aImpostos,"IT_ALIQISS") //               24,01 //Aliquota de ISS do item
aadd(aImpostos,"IT_ALIQIRR") //       25,03 //Aliquota de Calculo do IR do Item
aadd(aImpostos,"IT_ALIQINS") //       26,03 //Aliquota de Calculo do INSS
aadd(aImpostos,"IT_ALIQIV1") //       29,01 //Aliquota de Impostos Variaveis 1
aadd(aImpostos,"IT_ALIQIV2") //       29,02 //Aliquota de Impostos Variaveis 2
aadd(aImpostos,"IT_ALIQIV3") //       29,03 //Aliquota de Impostos Variaveis 3
aadd(aImpostos,"IT_ALIQIV4") //       29,04 //Aliquota de Impostos Variaveis 4
aadd(aImpostos,"IT_ALIQIV5") //       29,05 //Aliquota de Impostos Variaveis 5
aadd(aImpostos,"IT_ALIQIV6") //       29,06 //Aliquota de Impostos Variaveis 6
aadd(aImpostos,"IT_ALIQIV7") //       29,07 //Aliquota de Impostos Variaveis 7
aadd(aImpostos,"IT_ALIQIV8") //       29,08 //Aliquota de Impostos Variaveis 8
aadd(aImpostos,"IT_ALIQIV9") //       29,09 //Aliquota de Impostos Variaveis 9
aadd(aImpostos,"IT_ALIQCOF") //       41    //Aliquota de calculo do COFINS
aadd(aImpostos,"IT_ALIQCSL") //       44    //Aliquota de calculo do CSLL
aadd(aImpostos,"IT_ALIQPIS") //       47    //Aliquota de calculo do PIS
aadd(aImpostos,"IT_ALIQPS2") //       55    //Aliquota de calculo do PIS 2
aadd(aImpostos,"IT_ALIQCF2") //       58    //Aliquota de calculo do COFINS 2
aadd(aImpostos,"IT_ALIQAFRMM") //     67 //Aliquota de calculo do AFRMM ( Item )
aadd(aImpostos,"IT_ALIQSES") //       74,02 //Aliquota de calculo do SEST          
aadd(aImpostos,"IT_VALSOL")                          
aadd(aImpostos,"NF_VALSOL")   
aadd(aImpostos,"IT_VALIPI")       
aadd(aImpostos,"LF_ICMSRET")          


aImp[1] := MaFisRet(1,"IT_VALSOL")
aImp[2] := MaFisRet(1,"IT_VALIPI")

MaFisSave()
MaFisEnd()

Return aImp 

static function buscaPag(oHtml, cNumCont,_Fornec)
lOCAL _cCab := ''
lOCAL _cItensPg := ''
Local cAliasAx2 := getNextAlias()
		 
	BeginSQL Alias cAliasAx2
 
	   SELECT E2_BAIXA, E2_VALOR+E2_INSS+E2_IRRF+E2_ISS+E2_PIS+E2_COFINS+E2_CSLL-E2_SALDO AS VLBAIXA, E2_EMISSAO, E2_VENCREA,E2_NUM,E2_HIST, E2_FORNECE, E2_NOMFOR
	   FROM %TABLE:SE2% SE2
	   LEFT JOIN %TABLE:SD1% SD1 ON D1_FILIAL = E2_FILIAL AND E2_NUM = D1_DOC AND E2_PREFIXO = D1_SERIE AND E2_FORNECE = D1_FORNECE AND E2_LOJA = D1_LOJA AND SD1.%NotDel%
	   LEFT JOIN %TABLE:SC7% SC7 ON C7_FILIAL = D1_FILIAL AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC AND SC7.%NotDel%
	   WHERE SE2.%NotDel% AND E2_BAIXA != ' ' AND E2_VALOR != E2_SALDO AND  (( C7_CONTRA = %EXP:cNumCont%  AND  E2_TIPO ='NF ' AND E2_ORIGEM = 'MATA100 ') OR (E2_XCONTRA = %EXP:cNumCont% AND E2_FORNECE+E2_LOJA= %EXP:_Fornec%  ) )
	   ORDER BY E2_BAIXA DESC
	   OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY 
	
   EndSQL
	 //OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY 
	 IF !((cAliasAx2)->(Eof()))
 		_cCab :=  " <table border='1' width='1100'>"
		_cCab  += " <tr>"
		_cCab  += " 	<td colspan='1' bgcolor='#DFEFFF' height='18'>"
		_cCab  += " 		<font face='Arial'>Date</font>"
		_cCab  += " </td>"
		//_cCab  += " 	<td align='right' width='101' bgcolor='#DFEFFF' height='18'>"
		_cCab  += " 	<td  colspan='1' bgcolor='#DFEFFF' height='18'>"
		_cCab  += " 		<font face='Arial'>Provider</font>"
		_cCab  += " 	</td>"
		_cCab  += " 	<td  colspan='1' bgcolor='#DFEFFF' height='18'>"
		_cCab  += " 		<font face='Arial'>Description</font>"
		_cCab  += " 	</td>"
		_cCab  += " 	<td  colspan='1' bgcolor='#DFEFFF' height='18'>"
		_cCab  += " 		<font face='Arial'>Number</font>"
		_cCab  += " 	</td>"
		_cCab  += " 	<td  colspan='1' bgcolor='#DFEFFF' height='18'>"
		_cCab  += " 		<font face='Arial'>Payment Date</font>"
		_cCab  += " 	</td>"
		_cCab  += " 	<td  colspan='1' bgcolor='#DFEFFF' height='18'>"
		_cCab  += " 		<font face='Arial'>Value</font>"
		_cCab  += " 	</td>"
		_cCab  += " </tr>"
		 WHILE !(cAliasAx2)->(Eof())
		 	//Adiciona pagamentos
		 	_cItensPg += "<tr>"
		    _cItensPg += "<td align='right'><font size='2' face='Arial'>" + DTOC(STOD((cAliasAx2)->E2_EMISSAO)) + "</font></td>"
			_cItensPg += "<td align='right'><font size='2' face='Arial'>" + (cAliasAx2)->E2_FORNECE+' - '+(cAliasAx2)->E2_NOMFOR + "</font></td>"//
			_cItensPg += "<td align='right'><font size='2' face='Arial'>" + (cAliasAx2)->E2_HIST + "</font></td>"//
			_cItensPg += "<td align='right'><font size='2' face='Arial'>" + (cAliasAx2)->E2_NUM + "</font></td>"//
			_cItensPg += "<td align='right'><font size='2' face='Arial'>" + DTOC(STOD((cAliasAx2)->E2_BAIXA)) + "</font></td>"//
			_cItensPg += "<td align='right'><font size='2' face='Arial'>" + Transform((cAliasAx2)->VLBAIXA,'@E 999,999,999.99') + "</font></td>"//
			_cItensPg += "</tr>"
			
		 	(cAliasAx2)->(DbSkip())
		 ENDDO
		 
		_cItensPg += "</table>"
		_cItensPg :=_cCab+_cItensPg
	 ELSE
	 	_cItensPg := "No other payments."
	 ENDIF 
	 (cAliasAx2)->(dbclosearea())

	oHtml:ValByName("pagamentos",_cItensPg)   
return oHtml

STATIC FUNCTION addAnexos(oHtml,cChaveAne, _cTpo)
Local cAliasAx  := getNextAlias()
Local cArquivo  := ''
Local nMaxArq   := GetMv("TCP_TAMARQ")
Local cSelCpos  := ''
Local _cTxt := ''		 
private nTotalBit := 0
private cTextLog  := ''
//alltrim((cAliasAx)->ACB_OBJETO))  

//Removida regra para que o contrato envie somente 2 anexos
_cTpo := '1'
IF(_cTpo == '1')
	cSelCpos  := '% ACB.R_E_C_N_O_ AS RECACB%'
else
	cSelCpos  := '% MAX(ACB.R_E_c_n_O_) AS MAXRec, MIN(ACB.R_E_C_N_O_) as MinRec%'
endif

 BeginSQL Alias cAliasAx
	 
  SELECT %EXP:cSelCpos%
  FROM %TABLE:AC9% AC9
  INNER JOIN %TABLE:ACB% ACB ON ACB_FILIAL = AC9_FILIAL AND AC9_CODOBJ = ACB_CODOBJ AND ACB.%NotDel% 
  WHERE AC9.%NotDel%  AND AC9_ENTIDA||AC9_CODENT IN (%EXP:cChaveAne%)

 EndSQL
 
 WHILE !(cAliasAx)->(Eof())
 	
 	IF(_cTpo == '1')
		oHtml  := addArq(oHtml,(cAliasAx)->RECACB)
	else
		oHtml  := addArq(oHtml,(cAliasAx)->MinRec)
		oHtml  := addArq(oHtml,(cAliasAx)->MAXRec)
	endif
 	
	(cAliasAx)->(DbSkip())
 	
 ENDDO

_cTxt := 'LOG ANEXO - Chave;'+cChaveAne + '; Tamanho Total;'+ALLTRIM(STR(nTotalBit))+ ' ; Tamanho MAX'+ALLTRIM(STR(nMaxArq))

//conout(_cTxt)

(cAliasAx)->(dbclosearea())
	 
RETURN oHtml  

static FUNCTION addArq(oHtml,nAcbRecn,cChaveAne)
Local _cCaminho := 'dirdoc\co'+cEmpAnt+"\shared\"
Local cArquivo  := ''
Local nMaxArq    := GetMv("TCP_TAMARQ")	

	dbSelectArea('ACB')
	ACB->(DBGoTo(nAcbRecn))
	
 	cArquivo := _cCaminho + alltrim(ACB->ACB_OBJETO)  
 	
 	oFile := FWFileReader():New(cArquivo)
 	IF oFile:Open()
 		nTotalBit += oFile:getFileSize()
 	
		IF nMaxArq > nTotalBit
			oHtml:AttachFile(cArquivo)
		else
			nTotalBit -= oFile:getFileSize()
		
		ENDIF
	
 	ENDIF
return oHtml

user function pedidosAb(_cCon,_cContRev,cNum)
Local nVal := 0
Local cAliasAx := getNextAlias()

 BeginSQL Alias cAliasAx
	 
  SELECT SUM(C7_TOTAL) as totalaberto
  FROM %TABLE:SC7% SC7
  WHERE SC7.%NotDel%  AND C7_CONAPRO != 'L' AND C7_CONTRA = %EXP:_cCon% AND C7_REVISAO = %EXP:_cContRev% AND C7_NUM != %EXP:cNum% 

 EndSQL
 
 
 IF !(cAliasAx)->(Eof())
 	 	
 	nVal := (cAliasAx)->totalaberto
 	
 ENDIF

 (cAliasAx)->(dbclosearea())

return nVal

user function getWFMoe(nMoeda)
lOCAL cDesc := ''
Local cNomMv := ''
if nMoeda < 6
	cNomMv := "MV_MOEDA"+AllTrim(Str(nMoeda,2))
else
	cNomMv := "MV_MOEDAP"+AllTrim(Str(nMoeda,2))
endif

cDesc := ALLTRIM(SuperGetMv(cNomMv))
	
//dbSelectArea("SX6")
//SX6->(dbSetorder(1))
if FWSX6Util():ExistsParam( cNomMv )
	//If !EMPTY(SX6->X6_CONTENG)
		//cDesc := ALLTRIM(SX6->X6_CONTENG)
	//EndIf
	If ( UPPER(cDesc) == "DOLARES" )
		cDesc := "Dollars"
	EndIf
endif  

return cDesc


static function caracEsp(cString)
Local _sRet := cString

   _sRet := StrTran (_sRet, "�", ".")
   _sRet := StrTran (_sRet, "�", ".")
   _sRet := StrTran (_sRet, ">", "-")
   _sRet := StrTran (_sRet, "<", "-")
   _sRet := StrTran (_sRet, "|", "-")
   _sRet := StrTran (_sRet, "(", "-")
   _sRet := StrTran (_sRet, ")", "-")
   _sRet := StrTran (_sRet, "[", "-")
   _sRet := StrTran (_sRet, "]", "-")
   _sRet := StrTran (_sRet, "\", "-")
   _sRet := StrTran (_sRet, "/", "-")
   _sRet := StrTran (_sRet, "_", "-")
   _sRet := StrTran (_sRet, chr (9), " ") // TAB
   _sRet := StrTran (_sRet, Chr(13) + Chr(10) , " ") // enter
   _sRet := StrTran (_sRet, Chr(13)  , " ") 
   _sRet := StrTran (_sRet, Chr(10)  , " ") 
   
return _sRet

user function xRetAprv(cUsrLib,dDtLib)
	Local cAprov := ''
	if(!EMPTY(dDtLib))
		cAprov := UsrFullName(cUsrLib)
		
		//Busca Substituto
		PswOrder(1)
		If PswSeek(cUsrLib,.t.)
			aInfo := PswRet(1)
			_cMailAprv := ainfo[1,14]
			if !Empty(_cMailAprv)	
		
				dbSelectArea("WF4")
				WF4->(dbSetOrder(1))
				if WF4->(dbSeek(xFilial("WF4")+Alltrim(UPPER(_cMailAprv))))
					_lMailSub := .F.
			        _vDadosEmailSub := {}
			        _vY := 0
					While !WF4->(EOF()) .And. Alltrim(WF4->WF4_FILIAL+WF4->WF4_DE)==Alltrim(xFilial("WF4")+Alltrim(UPPER(_cMailAprv))) .and. !_lMailSub
						If dDtLib >= WF4->WF4_DTINI .And. dDtLib <= WF4->WF4_DTFIM .AND. !EMPTY(WF4->WF4_XNOME)
							_lMailSub := .T.
							cAprov := WF4->WF4_XNOME + ' on behalf ' + cAprov
						Endif
						WF4->(dbSkip())
					Enddo
				endif  
				WF4->(DBCloseArea())
			endif
		endif
	endif
return cAprov

Static Function fGetUsrName(cUserID)
Return(AllTrim(UsrFullName(cUserID)))

/*/{Protheus.doc} fBuildKey
Busca a chave da entidade 
@type function
@version 1.0
@author Kaique Mathias
@since 06/07/2020
@param cEntidade, character, param_description
@return character, cChave
/*/

Static Function fBuildKey( cEntidade )

	Local cChaveEnt := U_TCPGEDENT( cEntidade )[1]
	Local cChaveAne := "'" + cEntidade + cChaveEnt + "'"

Return( cChaveAne )
