#Include "protheus.ch"
#Include "topconn.ch"

#Define ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} KESTR24
Funcao para transferencia de produtos com reserva
@type function
@version 
@author luizh
@since 25/05/2020
@return nil, nenhum
/*/
User Function KESTR24()
	Local	oGrp
	Local	nLinha		:= 0
	Local	nCol1		:= 0
	Local	nCol2		:= 0
	Local	nCol3		:= 0
	Local	nCol4		:= 0
	Local	nCol5		:= 0
	Local	nCol6		:= 0
	Local	nCol7		:= nCol6 + 28 + 25
    Local	nCol8		:= nCol7 + 75
	Local	nCol9		:= nCol8 + 28
	Local	oBtAtu

	Local bOkb	 	:= {|| }
	Local bCancel 	:= {|| oDlg:End() }
	Local lMsgDel	:= .F.
	Local aButtons	:= {}
	Local nRecno 	:= Nil
	Local cAlias	:= Nil
	Local lMashups	:= .F.
	Local lImpCad	:= .F.
	Local lPadrao	:= .F.
	Local lHasOk	:= .F.
	Local lWalkThru	:= .F.

	Private	oProdCod
	Private	oProdDesc
	Private	oOrigArm
	Private	oSaldo
	Private	oEmpenho
	Private	oOrigEnd
	Private oLbxPri
	Private cCampos     := "C0_QUANT,C0_DOCRES,C5_CLIENTE,C5_LOJACLI,C5_NOMECLI"
	Private aCampos 	:= StrTokArr(cCampos,',')
	Private aHeader		:= {}
	Private aTam		:= {}
	Private aCols		:= {}
	Private aPosObj		:= {}
	Private aSize		:= {}
	Private	_cFilial	:= xFilial("SC2")
	Private cProdCod	:= Space( TamSx3("B1_COD"   	)[1] )
	Private cProdDesc	:= Space( TamSx3("B1_DESC"  	)[1] )
	Private cEndF3		:= Space( TamSx3("D3_LOCALIZ"	)[1] )
	Private nSaldo		:= 0
	Private nEmpenho	:= 0
	Private cOrigArm	:= "01"
	Private oOk      	:= LoadBitmap( GetResources(), "LBOK" 	)
	Private oNo      	:= LoadBitmap( GetResources(), "LBNO"	)
	Private cDestArm	:= Space( TamSx3("D3_LOCAL"		)[1] )
	Private cDestEnd	:= Space( TamSx3("D3_LOCALIZ"	)[1] )
	Private nDestQtd	:= 0
	Private	aAtalhos	:= {}
	Private cLocalF3	:= cOrigArm
	Private cProdF3		:= ""

	Static oDlg

	aadd(aAtalhos,{K_CTRL_A,{ || Processa( { || CarregarDados() }, "Carregando Dados..."	) } } )
	aadd(aAtalhos,{K_CTRL_F,{ || Limparfiltros()		}})
	aadd(aAtalhos,{K_CTRL_T,{ || Transferir()			}})
	aadd(aAtalhos,{K_CTRL_P,{ || oProdCod:SetFocus()	}})
	aadd(aAtalhos,{K_CTRL_N,{ || oOrigEnd:SetFocus()	}})
	aadd(aAtalhos,{K_CTRL_Q,{ || oDestArm:SetFocus()	}})
	aadd(aAtalhos,{K_CTRL_R,{ || oDestEnd:SetFocus()	}})
	aadd(aAtalhos,{K_CTRL_L,{ || oLbxPri:SetFocus()		}})

	CalcTela()

	ControleAtalhos(1)

	// VldProduto(@cProdCod,@cProdDesc)
	// VldEndereco(@cEndF3)
	// Processa( { || CarregarDados() }, "Carregando Dados..."			)

	// adiciona registros aos botoes
	aAdd( aButtons, {"", {|| U_KESTR24A()			}, "Atalhos disponíveis"		 		})
	// aAdd( aButtons, {"", {|| KESTR24B(.F.,.T.)	}, "Alterar Prioridade" 		})
	// aAdd( aButtons, {"", {|| Legenda()			}, "Legenda" 					})

	// TODO: Validar armazém e endereço de destino

	// atribui valor as variaveis de posicao
	nLinha	:= 040
	nCol1	:= 007
	nCol2	:= 035
	nCol3	:= 100
	nCol4	:= 140
	nCol5	:= 210
	nCol6	:= (aPosObj[1,4]/2)+5 + 5 
	nCol7	:= nCol6 + 28 + 25
    nCol8	:= nCol7 + 75
	nCol9	:= nCol8 + 28

	// define o dialog
	DEFINE MSDIALOG oDlg TITLE "Transferência de produtos com reserva" FROM aSize[7],0 to aSize[6],aSize[5]  PIXEL

		@ nLinha-10	, aPosObj[1,2] 		 GROUP oGrp TO aPosObj[1,3], (aPosObj[1,4]/2)-5 PROMPT "[ Origem ]" 	OF oDlg PIXEL
		@ nLinha-10	, (aPosObj[1,4]/2)+5 GROUP oGrp TO aPosObj[1,3], aPosObj[1,4]		PROMPT "[ Destino ]"	OF oDlg PIXEL

		// origem
		@ nLinha	, nCol1 	Say "Produto" PIXEL
		@ nLinha-1	, nCol2		MsGet oProdCod 	    Var cProdCod 	Picture PesqPict("SB1","B1_COD"   ) SIZE 050,08 OF oDlg PIXEL F3 "SB1" 	Valid VldProduto(@cProdCod,@cProdDesc) 
		@ nLinha-1	, nCol2+55 	MsGet oProdDesc 	Var cProdDesc 	Picture PesqPict("SB1","B1_DESC"  ) SIZE 200,08 OF oDlg PIXEL When .F.                										

		nLinha += 15
		@ nLinha	, nCol1     Say "Armazém" PIXEL
		@ nLinha-1	, nCol2     MsGet oOrigArm	    Var cOrigArm	Picture PesqPict("SD3","D3_LOCAL"	) SIZE 050,08 OF oDlg PIXEL When .F. Valid { cLocalF3 := cOrigArm }

		@ nLinha	, nCol3     Say "Endereço" PIXEL
		@ nLinha-1	, nCol4     MsGet oOrigEnd      Var cEndF3   	Picture PesqPict("SD3","D3_LOCALIZ" ) SIZE 050,08 OF oDlg PIXEL F3 "SBFSAL" Valid VldEndereco(@cEndF3)

		@ nLinha-2	, nCol5 BUTTON oBtAtu PROMPT "&Atualizar" 		SIZE 037, 012 OF oDlg ACTION {|| { Processa( { || CarregarDados() }, "Carregando Dados..."			)	 } } PIXEL

		nLinha += 15
		@ nLinha	, nCol1     Say "Saldo" PIXEL
		@ nLinha-1	, nCol2     MsGet oSaldo	    Var nSaldo		Picture PesqPict("SBF","BF_QUANT"	) SIZE 050,08 OF oDlg PIXEL When .F.

		@ nLinha	, nCol3     Say "Empenho" PIXEL
		@ nLinha-1	, nCol4     MsGet oEmpenho     	Var nEmpenho	Picture PesqPict("SBF","BF_EMPENHO" ) SIZE 050,08 OF oDlg PIXEL When .F.

		@ nLinha-2	, nCol5 BUTTON oBtAtu PROMPT "Limpar &Filtros" 	SIZE 037, 012 OF oDlg PIXEL ACTION {|| Limparfiltros() }
		// origem

		//destino
		nLinha	:= 040
		@ nLinha	, nCol6     Say "Armazém" PIXEL
		@ nLinha-1	, nCol7     MsGet oDestArm	    Var cDestArm	Picture PesqPict("SD3","D3_LOCAL"	) SIZE 050,08 OF oDlg PIXEL F3 "NNR"

		@ nLinha	, nCol8     Say "Endereço" PIXEL
		@ nLinha-1	, nCol9     MsGet oDestEnd      Var cDestEnd   	Picture PesqPict("SD3","D3_LOCALIZ" ) SIZE 050,08 OF oDlg PIXEL F3 "SBE" Valid VldEndereco(@cEndF3)

		nLinha += 15
		@ nLinha	, nCol6     Say "Qtd Selecionada" PIXEL
		@ nLinha-1	, nCol7 	MsGet oDestQtd	    Var nDestQtd	Picture PesqPict("SBF","BF_QUANT"	) SIZE 050,08 OF oDlg PIXEL When .F.

		nLinha += 15
		@ nLinha-2	, nCol6 BUTTON oBtnTr PROMPT "&Transferir" 		SIZE 037, 012 OF oDlg PIXEL ACTION {|| Transferir() } 
		// destino

   		@ aPosObj[2,1],aPosObj[2,2] LISTBOX oLbxPri FIELDS SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1]	OF oDlg PIXEL
		SetLbx()

	ACTIVATE MSDIALOG oDlg CENTERED on Init EnchoiceBar(oDlg,bOkb,bCancel,lMsgDel,aButtons,nRecno,cAlias,lMashups,lImpCad,lPadrao,lHasOk,lWalkThru)

Return

User Function KESTR24A()
	Local nLinha	:= 040
	Local nLin		:= 100
	Local nCol		:= 300
	Local bOkb	 	:= {|| }
	Local bCancel 	:= {|| oDlgAtalhos:End() }
	Local lMsgDel	:= .F.
	Local aButtons	:= {}
	Local nRecno 	:= Nil
	Local cAlias	:= Nil
	Local lMashups	:= .F.
	Local lImpCad	:= .F.
	Local lPadrao	:= .F.
	Local lHasOk	:= .F.
	Local lWalkThru	:= .F.

	nLin += Len(aAtalhos) * 30

	DEFINE MSDIALOG oDlgAtalhos TITLE "Atalhos" FROM 0,0 to nLin,nCol PIXEL

		@ nLinha,005 Say "Ctrl + A - Atualizar Dados" OF oDlgAtalhos PIXEL
		nLinha += 12
		@ nLinha,005 Say "Ctrl + F - Limpar Filtros" OF oDlgAtalhos PIXEL
		nLinha += 12
		@ nLinha,005 Say "Ctrl + T - Transferir" OF oDlgAtalhos PIXEL
		nLinha += 12
		@ nLinha,005 Say "Ctrl + P - Ir para o Campo Produto" OF oDlgAtalhos PIXEL
		nLinha += 12
		@ nLinha,005 Say "Ctrl + N - Ir para o Campo Endereço Origem" OF oDlgAtalhos PIXEL
		nLinha += 12
		@ nLinha,005 Say "Ctrl + Q - Ir para o Campo Armazém Destino" OF oDlgAtalhos PIXEL
		nLinha += 12
		@ nLinha,005 Say "Ctrl + R - Ir para o Campo Endereço Destino" OF oDlgAtalhos PIXEL
		nLinha += 12
		@ nLinha,005 Say "Ctrl + L - Ir para a Lista de itens" OF oDlgAtalhos PIXEL

  	ACTIVATE MSDIALOG oDlgAtalhos CENTERED on Init EnchoiceBar(oDlgAtalhos,bOkb,bCancel,lMsgDel,aButtons,nRecno,cAlias,lMashups,lImpCad,lPadrao,lHasOk,lWalkThru)

Return

Static Function Limparfiltros()
    cProdCod	:= Space( TamSx3("B1_COD"    )[1] 	)
    cProdDesc	:= Space( TamSx3("B1_DESC"   )[1] 	)
    cOrigArm	:= "01"
    cEndF3		:= Space( TamSx3("D3_LOCALIZ")[1] 	)
	nSaldo		:= 0
	nEmpenho	:= 0
	aCols		:= {}
	SetLbx()
    oProdCod:SetFocus()    
Return

Static Function CalcTela()
	Local aObjects	    := {}
	Local aInfo			:= {}

	aSize := MsAdvSize()

	aObjects := {}
	AAdd( aObjects, { 050, 050, .T., .F. } )
	AAdd( aObjects, { 150, 150, .T., .T. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }

	aPosObj := MsObjSize( aInfo, aObjects )
Return

Static Function CarregarDados()
	Local cQuery	:= ""
	Local aItem		:= {}
	Local cAlias	:= GetNextAlias()
    Local nX        := 0
	Local nSemRes	:= 0

	if Empty(AllTrim(cProdCod)) .or. Empty(AllTrim(cEndF3))
		Return
	Endif
	
	aHeader	:= {}
	aTam	:= {}
	aCols	:= {}
	nTmpProd:= 0

	If VldProduto(@cProdCod,@cProdDesc) .and. VldEndereco(@cEndF3)

		nSemRes	:= nSaldo - nEmpenho

		cQuery += "SELECT "+ENTER
		cQuery += "	ISNULL(C0_QUANT,0) C0_QUANT "+ENTER
		cQuery += "	,ISNULL(C0_DOCRES,'') C0_DOCRES "+ENTER
		cQuery += "	,ISNULL(C5_CLIENTE,'') C5_CLIENTE "+ENTER
		cQuery += "	,ISNULL(C5_LOJACLI,'') C5_LOJACLI "+ENTER
		cQuery += "	,ISNULL(C5_NOMECLI,'') C5_NOMECLI "+ENTER
		cQuery += " "+ENTER
		cQuery += "FROM "+RetSqlName("SBF")+" SBF "+ENTER
		cQuery += "	LEFT OUTER JOIN "+RetSqlName("SDC")+" SDC ON SDC.D_E_L_E_T_<>'*' "+ENTER
		cQuery += "		AND DC_FILIAL  = BF_FILIAL "+ENTER
		cQuery += "		AND DC_LOCAL   = BF_LOCAL "+ENTER
		cQuery += "		AND DC_PRODUTO = BF_PRODUTO "+ENTER
		cQuery += "		AND DC_LOCALIZ = BF_LOCALIZ "+ENTER
		cQuery += "	LEFT OUTER JOIN "+RetSqlName("SC0")+" SC0 ON SC0.D_E_L_E_T_<>'*' "+ENTER
		cQuery += "		AND C0_FILIAL  = DC_FILIAL "+ENTER
		cQuery += "		AND C0_NUM     = DC_PEDIDO "+ENTER
		cQuery += "		AND C0_TIPO    = 'PD' "+ENTER
		cQuery += "		AND C0_PRODUTO = DC_PRODUTO "+ENTER
		cQuery += "		AND C0_LOCAL   = DC_LOCAL "+ENTER
		cQuery += "	LEFT OUTER JOIN "+RetSqlName("SC5")+" SC5 ON SC5.D_E_L_E_T_<>'*' "+ENTER
		cQuery += "		AND C5_FILIAL = C0_FILIAL "+ENTER
		cQuery += "		AND C5_NUM    = C0_DOCRES "+ENTER
		cQuery += "	 "+ENTER
		cQuery += "WHERE  "+ENTER
		cQuery += "		SBF.D_E_L_E_T_<>'*' "+ENTER
		cQuery += "	AND BF_FILIAL  ='"+xFilial("SBF")	+"' "+ENTER
		cQuery += "	AND BF_PRODUTO ='"+cProdCod			+"' "+ENTER
		cQuery += "	AND BF_LOCAL   ='"+cOrigArm			+"' "+ENTER
		cQuery += "	AND BF_LOCALIZ ='"+cEndF3		+"' "+ENTER
		cQuery += " "+ENTER
		cQuery += "ORDER BY  "+ENTER
		cQuery += "	C0_DOCRES "+ENTER
		
		If Select(cAlias) > 0
			(cAlias)->( DbCloseArea() )
		Endif

		TcQuery cQuery New Alias (cAlias)
		Count to nRegs

		(cAlias)->( DbGoTop() )

		ProcRegua(nRegs)

		While !(cAlias)->( Eof() )

			if nSemRes > 0 .and. Empty(aCols)
				aadd(aItem,nSemRes		)
				aadd(aItem,""			)
				aadd(aItem,""			)
				aadd(aItem,""			)
				aadd(aItem,"DISPONÍVEL"	)
				aadd(aItem,.F.			)
				aadd(aCols,aItem)
			Endif

			IncProc()
			aItem	:= {}
			For nX := 1 to Len(aCampos)
				aadd(aItem,&( (cAlias)+"->"+aCampos[nX] ) )
			Next
			aadd(aItem,.F.)
			aadd(aCols,aItem)
			(cAlias)->( DbSkip() )
		Enddo

		(cAlias)->( DbCloseArea() )

		ControleAtalhos(1)

		If Type("oLbxPri")<>"U"
			SetLbx()
		Endif

	Endif

Return

Static Function SetLbx()
	Local aItem := {}
	Local nX	:= 0
/*
	aCols[oLbxPri:nAt][01] marcador
	aCols[oLbxPri:nAt][02] C0_QUANT
	aCols[oLbxPri:nAt][03] C0_DOCRES
	aCols[oLbxPri:nAt][04] C5_CLIENTE
	aCols[oLbxPri:nAt][05] C5_LOJACLI
	aCols[oLbxPri:nAt][06] C5_NOMECLI
*/

	aHeader := {}
	aTam	:= {}

	aadd(aHeader,""				)
	aadd(aTam,20				)
	aadd(aHeader,"Qtd Empenho"	)
	aadd(aTam,50				)
	aadd(aHeader,"Pedido"		)
	aadd(aTam,40				)
	aadd(aHeader,"Cod. Cli."	)
	aadd(aTam,40				)
	aadd(aHeader,"Loja Cli."	)
	aadd(aTam,40				)
	aadd(aHeader,"Cliente"		)
	aadd(aTam,70				)

	If Empty(aCols)
		For nX := 1 to Len(aCampos)
			aadd(aItem,CriaVar(aCampos[nX]) )
		Next
		aadd(aItem,.F.)
		aadd(aCols,aItem)
	Endif

	// nome colunas
	oLbxPri:aHeaders   := aHeader

	// tamanho colunas
	oLbxPri:aColSizes  := aTam

	// funcao clique duplo
	oLbxPri:bLDblClick := {|| KESTR24B(.F.,.F.) }

	// clicar no cabecalho
	oLbxPri:bHeaderClick := {|x, y| KESTR24B(.T.,.F.) }

	// define array
	oLbxPri:SetArray(aCols)

	oLbxPri:bLine := {|| { 	Iif(aCols[oLbxPri:nAt][Len(aCampos)+1], oOk, oNo)			,; 
								aCols[oLbxPri:nAt][aScan(aCampos,"C0_QUANT"		)]		,;
								aCols[oLbxPri:nAt][aScan(aCampos,"C0_DOCRES"	)]		,;
								aCols[oLbxPri:nAt][aScan(aCampos,"C5_CLIENTE"	)]		,;
								aCols[oLbxPri:nAt][aScan(aCampos,"C5_LOJACLI"	)]		,;
								aCols[oLbxPri:nAt][aScan(aCampos,"C5_NOMECLI"	)]		 ;
						} }

	oLbxPri:Refresh()
	oDlg:Refresh()
Return

Static Function VldProduto(cCod,cDesc)
	Local aArea	:= GetArea()
	Local _lRet	:= .T.

	IF !Empty( AllTrim(cCod) )
		SB1->( DbSetOrder(1) )
		If SB1->( MsSeek( xFilial("SB1")+cCod ) )
			cDesc	:= SB1->B1_DESC
			cProdF3 := SB1->B1_COD
		Else
			MsgStop("Código do produto informado não localizado.")
			_lRet	:= .F.
		Endif
	Else
		cDesc	:= ""
	Endif

	RestArea(aArea)
Return _lRet

Static Function KESTR24B(lCab,lAlt)
	Local 	nAt		:= oLbxPri:nAt
	Local 	nColPos	:= oLbxPri:nColPos
	Local 	nX		:= 0

	Default lCab	:= .F.
	Default lAlt	:= .F.

	If !lAlt
		If lCab

			For nX := 1 to Len(aCols)
				If aCols[nX][Len(aCampos)+1] 
					aCols[nX][Len(aCampos)+1] := .F.
				Endif
			Next

			nDestQtd := 0
			oBtnTr:Refresh()
			oDestQtd:Refresh()
			oLbxPri:refresh()
			oDlg:Refresh()
			Return
		Endif

		If nColPos == 1
			aCols[nAt][Len(aCampos)+1] := !aCols[nAt][Len(aCampos)+1]
			nPos := aScan(aCampos,"C0_QUANT")
			If aCols[nAt][Len(aCampos)+1]
				nDestQtd += aCols[nAt][nPos]
			Else
				nDestQtd -= aCols[nAt][nPos]
			Endif
			oBtnTr:Refresh()
			oDestQtd:Refresh()
			oLbxPri:Refresh()
			oDlg:Refresh()
			Return
		Endif
	Endif

Return

Static Function ControleAtalhos(nOpc)
	Local	nX			:= 0

	// opcao
	If nOpc == 1
		For nX := 1 to Len(aAtalhos)
			SetKey(aAtalhos[nX][1],aAtalhos[nX][2])
		Next
	ElseIf nOpc == 2
		For nX := 1 to Len(aAtalhos)
			SetKey(aAtalhos[nX][1], Nil )
		Next
	Endif

Return

Static Function VldEndereco(cCod)
    Local lRet := .T.

	// valida se esta preenchido
	IF !Empty( AllTrim(cCod) ) .and. !Empty(AllTrim(cOrigArm))
		// abre a tabela de recursos
		SBE->( DbSetOrder(1) )
		// localiza o registro
		If !SBE->( MsSeek( xFilial("SBE")+cOrigArm+cCod ) )
			// exibe msg de erro
			MsgStop("Código do produto informado não localizado.")
			// retorna erro
			_lRet	:= .F.
		Else
			AtualizarSaldoOrigEnd()
		Endif
	Endif

Return lRet

Static Function AtualizarSaldoOrigEnd()
	Local aArea 	:= GetArea()
	Local cQuery	:= ""
	Local cTemp		:= GetNextAlias()

	nSaldo 	:= 0
	nEmpenho:= 0

	cQuery += "SELECT "+ENTER
	cQuery += "	SUM(BF_QUANT) BF_QUANT "+ENTER
	cQuery += "	,SUM(BF_EMPENHO) BF_EMPENHO "+ENTER
	cQuery += "FROM "+RetSqlName("SBF")+" "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE  "+ENTER
	cQuery += "		D_E_L_E_T_<>'*' "+ENTER
	cQuery += "	AND BF_FILIAL='"+xFilial("SBF")+"' "+ENTER
	cQuery += "	AND BF_PRODUTO='"+cProdCod+"' "+ENTER
	cQuery += "	AND BF_LOCAL='"+cOrigArm+"' "+ENTER
	cQuery += "	AND BF_LOCALIZ='"+cEndF3+"' "+ENTER
	
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	Endif

	TcQuery cQuery New Alias (cTemp)

	If !(cTemp)->(EOF())
		nSaldo 	:= (cTemp)->BF_QUANT
		nEmpenho:= (cTemp)->BF_EMPENHO
	Endif

	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	Endif

	RestArea(aArea)
Return

Static Function Transferir()
	Alert("Transferir")
Return
