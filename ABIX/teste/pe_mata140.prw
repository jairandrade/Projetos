USER FUNCTION MT140SAI()

	Local nOrdem := SF1->( IndexOrd() )
	Private dDataVen := cTod(" / / ")
	Private lPossuiBol := .F.
	//PARAMIXB[1] = Numero da operação - ( 2-Visualização, 3-Inclusão, 4-Alteração, 5-Exclusão )
	//PARAMIXB[2] = Número da nota
	//PARAMIXB[3] = Série da nota
	//PARAMIXB[4] = Fornecedor
	//PARAMIXB[5] = Loja
	//PARAMIXB[6] = Tipo
	//PARAMIXB[7] = Opção de Confirmação (1 = Confirma pré-nota; 0 = Não Confirma pré-nota)

	If ParamIxb[1] == 3 .and. ParamIxb[7] == 1
		SF1->( dbSetOrder( 1 ) )
		SF1->( MsSeek( xFilial( 'SF1' ) + ParamIxb[2] + ParamIxb[3] + ParamIxb[4] + ParamIxb[5] ) )
		SF1->( dbSetOrder( nOrdem ) )

		//incluir static ACOM003 - Informar Data Fatura Nota
		dDataVen := u_ACOM003(SF1->(Recno()))

		//incluir static ACOM003F - Informar ao Compras Falta Bol/Fatura
		lPossuiBol := u_ACOM03F(SF1->(Recno()))

		//enviar email da Pre-nota
		EnPreNota(dDataVen,lPossuiBol)
	EndIf
Return( NIL )
/*/{Protheus.doc} EnPreNota
Rotina de ENVIO de email da Pré-Nota de Entrada 
@type    function
@author	 Jair Andrade
@since	 24/06/2022
@version P12 R27
@Project 
@return 
@History 
/*/  
Static Function EnPreNota(dDataVen,lPossuiBol)

	Local lRet     := .F.
	Local cAssunto := " "
	Local cDest    := " "
	Local cCtIPO   := " "
	Local CTRSELO  := " "
	Local lQtdEnt := .T.
	Local cTipoEnt :=""
	Local nTotFalt := 0
	Local nTotSD1 := 0
	Local cxEmp := ""
	Local _aAreaSF1 := SF1->(GetArea())
	Local _aAreaSD1 := SD1->(GetArea())

// envia e-mail com dados da pre-nota

	If sm0->m0_codigo =='01'
		cxEmp := "Abix"
	elseif  sm0->m0_codigo =='02'
		cxEmp := "Cricom"
	elseif  sm0->m0_codigo =='04'
		cxEmp := "Alson"
	elseif  sm0->m0_codigo =='05'
		cxEmp := "HRS"
	endif

	iF ctipo =='N'
		cCtIPO := "Normal"
	elseiF ctipo =='B'
		cCtIPO := "Beneficiamento"
	elseiF ctipo =='D'
		cCtIPO := "Devolucao"
	elseiF ctipo =='D'
		cCtIPO := "Devolucao"
	Endif

	chtml := '	<head> '
	chtml += '	</head> '
	chtml += '	<body> <page size="A4"> '
	chtml += '	<h3> '
	chtml += '	Usuario    : '+cusername+'  <br>'
	chtml += '	Empresa    : '+cxEmp+' <br>'
	chtml += '	Filial     : '+alltrim(sm0->m0_codfil)+'<br>'
	chtml += '	Pre-nota   : '+SF1->F1_DOC+'  <br> '
	chtml += '	Serie      : '+SF1->F1_SERIE+'<br>'
	chtml += '	Tipo       : '+SF1->F1_TIPO+'<br>'
	chtml += '	Data Atual   : '+substring(dtos(DATE()),7,2)+"/"+substring(dtos(DATE()),5,2)+"/"+substring(dtos(DATE()),1,4) +'   <br>'
	chtml += '	Data Entrada NF    : '+substring(dtos(DDATABASE),7,2)+"/"+substring(dtos(DDATABASE),5,2)+"/"+substring(dtos(DDATABASE),1,4) +'   <br>'
	chtml += '	Data Emissao NF    : '+substring(dtos(SF1->F1_EMISSAO),7,2)+"/"+substring(dtos(SF1->F1_EMISSAO),5,2)+"/"+substring(dtos(SF1->F1_EMISSAO),1,4) +' <br>'
	chtml += '	Data Vencto NF     : '+(dDataVen)+' <br>'
	chtml += '	Possui Boleto      : '+Iif(lPossuiBol,"Não","Sim")+'<br>'
	chtml += '	Fornecedor : '+ alltrim(SA2->A2_COD)+'-'+alltrim(SA2->A2_LOJA)+'-'+alltrim(SA2->A2_NREDUZ)+'<br> '
	chtml += '	</h3>
	chtml += '	<table width="750" cellpadding="0" cellspacing="0" border="1">
	chtml += '	<tr>
	chtml += '		<td  >Produto</td><td>UM</td><td >Qtde</td><td ><font color="red">Qtde Faltante</font></td><td >Preço</td><td >Total</td><td >Selo</td> <td >Pedido</td> <td >ItemPC</td>
	chtml += '	</tr>

// laço dos itens
	dbSelectArea("SD1")
	ProcRegua(0)
	dbSetOrder(1)
	dbGoTop()
	dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	If SD1->D1_CTRSELO == "S"
		CTRSELO:=  "Sim"
	else
		CTRSELO:=  "Nao"
	endif


	While !SD1->(Eof()) .And. SF1->F1_DOC == SD1->D1_DOC;
			.And. SF1->F1_SERIE == SD1->D1_SERIE;
			.And. SF1->F1_FORNECE == SD1->D1_FORNECE;
			.And. SF1->F1_LOJA == SD1->D1_LOJA
		// Ajusta data entrada no pedido
		if funName() == "MATA140"
			DbSelectArea("SC7")
			SC7->(DbSetOrder(14)) // Fil Ent + Pedido + Item
			SC7->(MsSeek(xFilEnt(xFilial("SC7"),"SC7") + SF1->F1_PEDIDO + SF1->F1_ITEMPC))
			nTotSD1 := FGetTotSD1(SC7->C7_NUM, SC7->C7_ITEM)
			nTotFalt := ( SC7->C7_QUANT - nTotSD1  )
			If (SD1->D1_QUANT <> SC7->C7_QUANT) .and. nTotFalt > 0
				If (SD1->D1_QUANT < nTotFalt)
					nTotFalt :=  nTotFalt - SD1->D1_QUANT
					lQtdEnt := .F.
				ElseIf (SD1->D1_QUANT >= nTotFalt)
					nTotFalt := 0
				EndIf
			Else
				nTotFalt := 0
			Endif
			Reclock("SC7",.F.)
			SC7->C7_DTPRE :=  DATE()
			SC7->(MsUnlock())
		endif
		chtml += '		<tr><td >'+SD1->D1_COD+'</td><td  >'+SD1->D1_UM+'</td><td >'+CVALTOCHAR(SD1->D1_QUANT)+'</td><td ><font color="red">'+CVALTOCHAR(nTotFalt)+'</font></td><td >'+CVALTOCHAR(SD1->D1_VUNIT)+'</td><td >'+CVALTOCHAR(SD1->D1_TOTAL)+'</td > <td >'+CTRSELO+'</td ><td >'+CVALTOCHAR(SD1->D1_PEDIDO)+'</td ><td >'+CVALTOCHAR(SD1->D1_ITEMPC)+'</td ></tr>
		SD1->(dbSkip())
	EndDo

	If lQtdEnt
		cTipoEnt := " TOTAL"
	Else
		cTipoEnt := " PARCIAL"
	EndIf
	chtml += '	</table>
	chtml += '	<h3> '
	chtml += 'Tipo de Entrega: '+cTipoEnt+'<br> '
	chtml += '	</h3>
	chtml += '	</body>
	chtml += ' </html>

	cAssunto := "Pre-nota : "+SF1->F1_DOC+"- "+SF1->F1_SERIE+" Fornecedor : "+alltrim(SA2->A2_NOME)
	if  SA2->A2_COD  <> '006113322'
		If cFilAnt == '01' //--Mtz
			cDest := " compras@abix.com.br;logistica@abix.com.br;"

		ElseIf cFilAnt == '02' //--RIO
			cDest := "compras@abix.com.br;todos.logistica.rio@abix.com.br;"

		ElseIf cFilAnt == '03' //--CANOAS
			cDest := "compras@abix.com.br;marcos.machado@abix.com.br;"

		ElseIf cFilAnt == '04' //--SPA
			cDest := "compras@abix.com.br;todos.logisticasp@abix.com.br"

		ElseIf cFilAnt == '07'  //--CD
			cDest := "compras@abix.com.br;todos.cd@abix.com.br;"

		ElseIf cFilAnt == '10' //--UBER
			cDest := "compras@abix.com.br;rose@abix.com.br;"

		ElseIf cFilAnt == '12' //--ITJ
			cDest := "compras@abix.com.br;marcos.machado@abix.com.br;"

		ElseIf cFilAnt == '15' //--MACEIO
			cDest := "compras@abix.com.br;marcos.machado@abix.com.br;"

		ElseIf cFilAnt == '16' //--LAURO
			cDest := "compras@abix.com.br;rosangela.costa@abix.com.br;"
		EndIf
	else
		If cFilAnt == '01' //--Mtz
			cDest := "logistica@abix.com.br;"

		ElseIf cFilAnt == '02' //--RIO
			cDest := "todos.logistica.rio@abix.com.br;"

		ElseIf cFilAnt == '03' //--CANOAS
			cDest := "marcos.machado@abix.com.br;"

		ElseIf cFilAnt == '04' //--SPA
			cDest := "todos.logisticasp@abix.com.br"

		ElseIf cFilAnt == '07'  //--CD
			cDest := "todos.cd@abix.com.br;"

		ElseIf cFilAnt == '10' //--UBER
			cDest := "rose@abix.com.br;"

		ElseIf cFilAnt == '12' //--ITJ
			cDest := "marcos.machado@abix.com.br;"

		ElseIf cFilAnt == '15' //--MACEIO
			cDest := "marcos.machado@abix.com.br;"

		ElseIf cFilAnt == '16' //--LAURO
			cDest := "rosangela.costa@abix.com.br;"
		EndIf
	endif


	If U_MailTo("jair.andrade@abix.com.br",cAssunto , chtml , {} )
		//If U_MailTo(cDest,cAssunto , chtml , {} )
	Else
		MsgStop("Erro ao Enviar Email! AVISAR EQUIPE PIPA","[MATA140]")
	Endif

	RestArea(_aAreaSD1)
	RestArea(_aAreaSF1)

Return lRet
