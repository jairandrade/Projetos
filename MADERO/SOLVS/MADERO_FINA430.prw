#include "PROTHEUS.CH"
#include "FILEIO.CH"
#include "FINA430.CH"
#include "FWMVCDEF.CH"

Static lFWCodFil := .T.
Static _oFina430

User Function xFinTeste(nPosAuto,_xFilial)

	Local lPanelFin := IsPanelFin()
	Local lOk		:= .F.
	Local aSays 	:= {}
	Local aButtons  := {}
	Local cPerg		:= "AFI430"
	Local cFilAnt   := _xFilial // '02MDBG0009' // ribas

	PRIVATE cCadastro := OemToAnsi( "Retorno CNAB Pagar" ) 
	Private aTit  
	Private cTipoBx  := ""
	Private nVlrCnab := 0
	Private lMVCNBImpg := GetNewPar("MV_CNBIMPG",.F.)

	Private lExecJob := ExecSchedule()
	If lExecJob
		nPosAuto := 1 
	EndIf

	// MV_PAR01: Mostra Lanc. Contab  ? Sim Nao          
	// MV_PAR02: Aglutina Lanc. Contab? Sim Nao        
	// MV_PAR03: Arquivo de Entrada   ?               
	// MV_PAR04: Arquivo de Config    ?               
	// MV_PAR05: Banco                ?               
	// MV_PAR06: Agencia              ?              
	// MV_PAR07: Conta                ?              
	// MV_PAR08: SubConta             ?             
	// MV_PAR09: Contabiliza          ?             
	// MV_PAR10: Padrao Cnab          ? Modelo1 Modelo 2  
	// MV_PAR11: Processa filiais     ? Modelo1 Modelo 2 
	
	

	A460FSA2()	
	lExecJob := .T.
	If lPanelFin .and. ! lExecJob  
		lPergunte := PergInPanel(cPerg,.T.)
	Else
		If lExecJob   
			//Pergunte(cPerg,.F.,Nil,Nil,Nil,.F.) 
			lPergunte := .T.
		Else
			lPergunte := pergunte(cPerg,.T.)
		EndIf
	EndIf

	If lPergunte
		MV_PAR03 := UPPER(MV_PAR03)

		dbSelectArea("SE2")
		dbSetOrder(1)

		ProcLogIni( aButtons )

		If nPosAuto <> Nil
			lOk := .T.
		Else
			aADD(aSays,STR0013)
			aADD(aSays,STR0014)
			If lPanelFin  
				aButtonTxt := {}
				If Len(aButtons) > 0
					AADD(aButtonTxt,{'Visualizar','Visualizar',aButtons[1][3]}) 
				EndIf
				AADD(aButtonTxt,{'Parametros','Parametros', {||Pergunte("AFI430",.T. )}}) 
				FaMyFormBatch(aSays,aButtonTxt,{||lOk:=.T.},{||lOk:=.F.})
			Else
				aADD(aButtons, { 5,.T.,{|| Pergunte("AFI430",.T. ) } } )
				aADD(aButtons, { 1,.T.,{|| lOk := .T.,FechaBatch()}} )
				aADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
				FormBatch( cCadastro, aSays, aButtons ,,,535)
			EndIf
		EndIf
		If lOk

			If lExecJob
				ProcLogAtu("INICIO",'Retorno Bancario Automatico (Pagar)'+" - "+'Arquivo:'+mv_par03) 
				Conout('Retorno Bancario Automatico (Pagar)')
			Else
				ProcLogAtu("INICIO")
				Conout('Inicio')
			EndIf

			fa430gera("SE2")

			If lExecJob
				ProcLogAtu("FIM",,'Retorno Bancario Automatico (Pagar)'+" - "+'Arquivo:'+mv_par03) 
				Conout('Retorno Bancario Automatico (Pagar), Arquivo '+mv_par03)
			Else
				ProcLogAtu("FIM")
				Conout('Fim')
			EndIf
		EndIf

		dbSelectArea("SE2")
		dbSetOrder(1)
	EndIf

Return

//---------------------------
Static Function fa430gera(cAlias)
	PRIVATE cLotefin	:= Space(TamSX3("EE_LOTECP")[1])
	PRIVATE nTotAbat	:= 0,cConta := " "
	PRIVATE nHdlBco		:= 0,nHdlConf := 0,nSeq := 0 ,cMotBx := "DEB"
	PRIVATE nValEstrang	:= 0
	PRIVATE cMarca		:= GetMark()
	PRIVATE aAC			:= { STR0004,STR0005 }  //"Abandona"###"Confirma"
	PRIVATE nTotAGer	:= 0
	PRIVATE VALOR		:= 0
	PRIVATE ABATIMENTO	:= 0
	Private nAcresc, nDecresc

	If ExistBlock("F430CIT")
		ExecBlock("F430CIT",.F.,.F.)
	EndIf

	Processa({|lEnd| fa430Ger(cAlias)}) 

	If nHdlBco > 0
		FCLOSE(nHdlBco)
	EndIf

	If nHdlConf > 0
		FCLOSE(nHdlConf)
	EndIf

Return .T.

//---------------------------
Static Function fA430Ger(cAlias)

	Local cPosNum,cPosData,cPosDesp,cPosDesc,cPosAbat,cPosPrin,cPosJuro,cPosMult,cPosForne
	Local cPosOcor,cPosTipo,cPosCgc, cRejeicao, cPosDebito, cPosRejei
	Local cChave430,cNumSe2,cChaveSe2
	Local cArqConf,cArqEnt,cPosNsNum
	Local cTabela    := "17",cPadrao,cLanca,cNomeArq
	Local cFilOrig   := '01GDAD0001'//cFilAnt	// Salva a filial para garantir que nao seja alterada em customizacao
	Local cFilAnt    := '01GDAD0001'
	Local xBuffer
	Local lPosNum    := .f., lPosData := .f.
	Local lPosDesp   := .f., lPosDesc := .f., lPosAbat := .f.
	Local lPosPrin   := .f., lPosJuro := .f., lPosMult := .f.
	Local lPosOcor   := .f., lPosTipo := .f., lMovAdto := .F.
	Local lPosNsNum  := .f., lPosForne:= .f., lPosRejei:= .f.
	Local lPosCgc    := .f., lPosdebito:=.f.
	Local lDesconto,lContabiliza,lUmHelp := .F.,lCabec := .f.
	Local lPadrao    := .f., lBaixou := .f., lHeader := .f.
	Local lF430VAR   := ExistBlock("F430VAR"),lF430Baixa := ExistBlock("F430BXA")
	Local lF430Rej   := ExistBlock("F430REJ"),lFa430Oco  := ExistBlock("FA430OCO")
	Local lFa430Se2  := ExistBlock("FA430SE2"),lFa430Pa  := ExistBlock("FA430PA")
	Local lFa430Fil  := Existblock("FA430FIL")
	Local lFA430LP	 := Existblock("FA430LP")
	Local lRet       := .T.
	Local nLidos,nLenNum,nLenData,nLenDesp,nLenDesc,nLenAbat,nLenForne,nLenRejei
	Local nLenPrin,nLenJuro,nLenMult,nLenOcor,nLenTipo,nLenCgc, nLenDebito,nLenNsNum
	Local nTotal     := 0,nPos,nPosEsp,nBloco := 0
	Local nSavRecno  := Recno()
	Local nTamForn   := Tamsx3("E2_FORNECE")[1]
	Local nTamOcor   := TamSx3("EB_REFBAN")[1]
	Local nTamEEOcor := 2
	Local aTabela    := {},aLeitura := {},aValores := {},aCampos := {}
	Local dDebito
	Local nTamPre	:= TamSX3("E1_PREFIXO")[1]
	Local nTamNum	:= TamSX3("E1_NUM")[1]
	Local nTamPar	:= TamSX3("E1_PARCELA")[1]
	Local nTamTit	:= nTamPre+nTamNum+nTamPar
	Local lAchouTit := .F.
	Local nTamBco	:= Tamsx3("A6_COD")[1]
	Local nTamAge	:= TamSx3("A6_AGENCIA")[1]
	Local nTamCta	:= Tamsx3("A6_NUMCON")[1]
	Local lMultNat 	:= IIf(mv_par12==1,.T.,.F.)
	Local aColsSEV 	:= {}
	Local lOk 		:= .F. //Controla se foi confirmada a distribuicao
	Local nTotLtEZ 	:= 0	//Totalizador da Bx Lote Mult Nat CC
	Local nHdlPrv	:= 0
	Local aArqConf	:= {}	// Atributos do arquivo de configuracao
	Local lCtbExcl	:= !Empty( xFilial("CT2") )
	Local aFlagCTB	:= {}
	Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
	Local lF430PORT := ExistBlock("F430PORT")
	Local lAltPort 	:= .F.
	Local aDtMvFinOk := {} //Array para as datas de baixa válidas
	Local aDtMvFinNt := {} //Array para as datas de baixa inconsistentes com o parâmetro MV_DATAFIN
	Local lTrocaLP	:= .F.
	Local lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"
	Local lIRPFBaixa := .F.
	Local cPadAux	:= ""

	//DDA - Debito Direto Autorizado
	Local lUsaDDA	:= FDDAInUse()
	Local lProcDDA	:= .F.
	Local lF430COMP := ExistBlock( "F430COMP" )
	Local lFA430FIG	:= ExistBlock( "FA430FIG" )
	Local cFilAux	:= ""

	//Reestruturacao SE5
	Local oModelMov	:= Nil //Model de Movimento
	Local oSubFK2	:= Nil
	Local oSubFK5	:= Nil
	Local oSubFKA	:= ""
	Local cLog		:= ""
	Local cCamposE5	:= ""
	Local cChaveTit	:= ""
	Local cIDDoc	:= ""
	Local lBxCnab	:= GetMv("MV_BXCNAB") == "S"
	Local cBcoOfi	:= ""
	Local cAgeOfi	:= ""
	Local cCtaOfi	:= ""
	Local cNatLote:= FINNATMOV("P")
	Local cLocRec := SuperGetMV( "MV_LOCREC" , .F. , .F. )
	Local aAreaCorr := {}
	Local lF430GRAFIL := ExistBlock("F430GRAFIL")
	Local cCGCFilHeader := ""
	Local aAreaCnab
	Local nExit 	:= 0
	Local nValImp	:= 0
	Local nOldValPgto := 0
	Local nMoeda	:= 0
	Local nTxMoeda	:= 0
	Local lRet		:= .T.
	Local lBp10925	:= SuperGetMv("MV_BP10925",.F.,"2") == "1"
	Local lPagAnt	:= .F.

	Private cBanco, cAgencia, cConta
	Private cHist070, cArquivo
	Private lAut		:=.f., nTotAbat := 0
	Private cCheque 	:= " ", cPortado := " ", lAdiantamento := .F.
	Private cNumBor 	:= " ", cForne  := " " , cCgc := "", cDebito := ""
	Private cModSpb 	:= "1"  // Colocado apenas para não dar problemas nas rotinas de baixa
	Private cAutentica 	:= Space(25)  //Autenticacao retornada pelo segmento Z
	Private cLote		:= Space(TamSX3("EE_LOTECP")[1])
	Private cBenef      := ""  // JBS - 26/08/2013 - Controle da gravação do nome do beneficiario

	//Reestruturacao SE5
	PRIVATE nDescCalc 	:= 0
	PRIVATE nJurosCalc 	:= 0
	PRIVATE nMultaCalc 	:= 0
	PRIVATE nCorrCalc	:= 0
	PRIVATE nDIfCamCalc	:= 0
	PRIVATE nImpSubCalc	:= 0
	PRIVATE nPisCalc	:= 0
	PRIVATE nCofCalc	:= 0
	PRIVATE nCslCalc	:= 0
	PRIVATE nIrfCalc	:= 0
	PRIVATE nIssCalc	:= 0
	PRIVATE nPisBaseR 	:= 0
	PRIVATE nCofBaseR	:= 0
	PRIVATE nCslBaseR 	:= 0
	PRIVATE nIrfBaseR 	:= 0
	PRIVATE nIssBaseR 	:= 0
	PRIVATE nPisBaseC 	:= 0
	PRIVATE nCofBaseC 	:= 0
	PRIVATE nCslBaseC 	:= 0
	PRIVATE nIrfBaseC 	:= 0
	PRIVATE nIssBaseC 	:= 0
	Private lOnline	:= .F.
	Private lVlrMaior := .F.
	Private nVlrMaior	:= 0

	lChqPre := .F.


	cBanco  := mv_par05
	cAgencia:= mv_par06
	cConta  := mv_par07
	cSubCta := mv_par08

	If ExecSchedule() // Anula parâmetro MV_LOCREC quando vem de schedule
		cLocRec:=""
	EndIf

	dbSelectArea("SA6")
	DbSetOrder(1)
	SA6->( dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta) )

	dbSelectArea("SEE")
	DbSetOrder(1)
	SEE->( dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubCta) )

	If !Empty(SEE->EE_CTAOFI)

		cBcoOfi	:= SEE->EE_CODOFI
		cAgeOfi	:= SEE->EE_AGEOFI 
		cCtaOfi	:= SEE->EE_CTAOFI

		cBanco		:= SEE->EE_CODOFI
		cAgencia	:= SEE->EE_AGEOFI 
		cConta		:= SEE->EE_CTAOFI

	EndIf

	nBloco := If( SEE->EE_NRBYTES==0,402,SEE->EE_NRBYTES+2)
	If !SEE->( found() )
		If ! lExecJob
			Help(" ",1,"PAR150")
		EndIf

		ProcLogAtu("ERRO","PAR150",Ap5GetHelp("PAR150"))
		lRet:= .F.
	EndIf

	If lRet .And. lBxCnab 
		If Empty(SEE->EE_LOTECP)
			cLoteFin := StrZero( 1, TamSX3("EE_LOTECP")[1] )
		Else
			cLoteFin := FinSomaLote(SEE->EE_LOTECP)
		EndIf
		cLoteFin := IIf(CheckLote("P",.F.),cLoteFin,GetNewLote())
	EndIf

	lRet := DtMovFin(dDatabase,,"1")
	If !lret
		return(.f.)
	EndIf

	If FWSizeFilial() > 2
		If (FWModeAccess("CT2", 3) == "C") .Or. ( FWModeAccess("CT2", 2) == "C") .Or. ( FWModeAccess("CT2", 1) == "C")
			lCtbExcl := .F.
		EndIf
	EndIf

	If lRet
		cTabela := IIf( Empty(SEE->EE_TABELA), "17" , SEE->EE_TABELA )
		dbSelectArea( "SX5" )
		If !SX5->( dbSeek( xFilial("SX5")+ cTabela ) )
			If ! lExecJob
				Help(" ",1,"PAR430")
			EndIf
			ProcLogAtu("ERRO","PAR430",Ap5GetHelp("PAR430"))
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. mv_par11 == 2
		If lCtbExcl .and. ! ExecSchedule()
			//lRet := MsgYesNo( STR0015, STR0010 )
		EndIf
	EndIf

	If lRet .And. !(Chk430File())
		lRet := .F.
	EndIf

	If lExecJob .and. ! lRet
		ProcLogAtu("ALERTA",'Arquivo :'+Alltrim(mv_par03)+'processado anteriormente.') 
		Aadd(aMsgSch, 'Arquivo :'+Alltrim(mv_par03)+'processado anteriormente.') 		
	EndIf

	If lF430PORT
		lAltPort := ExecBlock("F430PORT",.F.,.F.)
	EndIf

	While lRet .And. !SX5->(Eof()) .and. SX5->X5_TABELA == cTabela
		AADD(aTabela,{Alltrim(X5Descri()),PadR(AllTrim(SX5->X5_CHAVE),3)})
		SX5->(dbSkip( ))
	EndDo

	If lRet
		LoteCont("FIN")
		cArqConf:=mv_par04
		If !FILE(cArqConf)
			If ! lExecJob
				//Help(" ",1,"NOARQPAR")
			EndIf
			ProcLogAtu("ERRO","NOARQPAR",Ap5GetHelp("NOARQPAR"))

			lRet:= .F.
		ElseIf ( MV_PAR10 == 1 )
			nHdlConf:=FOPEN(cArqConf,0+64)
		EndIf
	EndIf

	If lRet .And. ( MV_PAR10 == 1 )
		nLidos:=0
		FSEEK(nHdlConf,0,0)
		nTamArq:=FSEEK(nHdlConf,0,2)
		FSEEK(nHdlConf,0,0)
		While nLidos <= nTamArq
			xBuffer:=Space(85)
			FREAD(nHdlConf,@xBuffer,85)

			If SubStr(xBuffer,1,1) == CHR(1)
				nLidos+=85
				Loop
			EndIf
			If SubStr(xBuffer,1,1) == CHR(3)
				Exit
			EndIf
			If !lPosNum
				cPosNum:=Substr(xBuffer,17,10)
				nLenNum:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosNum:=.t.
				nLidos+=85
				Loop
			EndIf
			If !lPosData
				cPosData:=Substr(xBuffer,17,10)
				nLenData:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosData:=.t.
				nLidos+=85
				Loop
			End
			If !lPosDesp
				cPosDesp:=Substr(xBuffer,17,10)
				nLenDesp:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosDesp:=.t.
				nLidos+=85
				Loop
			End
			If !lPosDesc
				cPosDesc:=Substr(xBuffer,17,10)
				nLenDesc:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosDesc:=.t.
				nLidos+=85
				Loop
			End
			If !lPosAbat
				cPosAbat:=Substr(xBuffer,17,10)
				nLenAbat:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosAbat:=.t.
				nLidos+=85
				Loop
			EndIf
			If !lPosPrin
				cPosPrin:=Substr(xBuffer,17,10)
				nLenPrin:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosPrin:=.t.
				nLidos+=85
				Loop
			EndIf
			If !lPosJuro
				cPosJuro:=Substr(xBuffer,17,10)
				nLenJuro:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosJuro:=.t.
				nLidos+=85
				Loop
			EndIf
			If !lPosMult
				cPosMult:=Substr(xBuffer,17,10)
				nLenMult:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosMult:=.t.
				nLidos+=85
				Loop
			EndIf
			If !lPosOcor
				cPosOcor:=Substr(xBuffer,17,10)
				nLenOcor:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosOcor:=.t.
				nLidos+=85
				Loop
			EndIf
			If !lPosTipo
				cPosTipo:=Substr(xBuffer,17,10)
				nLenTipo:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosTipo:=.t.
				nLidos+=85
				Loop
			EndIf
			If !lPosNsNum
				cPosNsNum := Substr(xBuffer,17,10)
				nLenNsNum := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosNsNum := .t.
				nLidos += 85
				Loop
			EndIf
			If !lPosRejei
				cPosRejei := Substr(xBuffer,17,10)
				nLenRejei := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosRejei := .t.
				nLidos += 85
				Loop
			EndIf
			If !lPosForne
				cPosForne := Substr(xBuffer,17,10)
				nLenForne := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosForne := .t.
				nLidos += 85
				Loop
			EndIf
			If !lPosCgc
				cPosCgc   := Substr(xBuffer,17,10)
				nLenCgc   := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosCgc   := .t.
				nLidos += 85
				Loop
			EndIf
			If !lPosDebito
				cPosDebito:=Substr(xBuffer,17,10)
				nLenDebito:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosDebito:=.t.
				nLidos+=85
				Loop
			EndIf
		EndDo
		Fclose(nHdlConf)
	EndIf

	If lRet
		If Empty(cLocRec) .AND. !ExecSchedule()
			cArqEnt:=mv_par03
		Else
			If ExecSchedule()
				cArqEnt:=mv_par03
			ElseIf AT("\",alltrim(cLocRec))>0 .and. RAT("\",SUBSTR(alltrim(cLocRec),LEN(alltrim(cLocRec)),1)) = 0
				cArqEnt:=cLocRec+"\"+TRIM(mv_par03)	
			ElseIf AT("\",alltrim(cLocRec))>0 .and. RAT("\",SUBSTR(alltrim(cLocRec),LEN(alltrim(cLocRec)),1)) > 0
				cArqEnt:=cLocRec+TRIM(mv_par03)	
			ElseIf AT("/",alltrim(cLocRec))>0 .and. RAT("/",SUBSTR(alltrim(cLocRec),LEN(alltrim(cLocRec)),1)) > 0
				cArqEnt:=SuperGetMV( "MV_LOCREC" , .F. , .F. )+TRIM(mv_par03)
			ElseIf AT("/",alltrim(cLocRec))>0 .and. RAT("/",SUBSTR(alltrim(cLocRec),LEN(alltrim(cLocRec)),1)) = 0	
				cArqEnt:=cLocRec+"/"+TRIM(mv_par03)
			EndIf

		EndIf 

		If !Empty(cLocRec) .and. (Empty(mv_par03) .or. AT(":",mv_par03)>0 .or. (AT("/",mv_par03)>0 .or. AT("\",mv_par03)>0))
			Help(" ",1,"F150ARQ",,'Nome do Arquivo de Saida Inválido',1,0) 
			Return .F.
		EndIf

		If !FILE(cArqEnt)
			If ! lExecJob
				Help(" ",1,"NOARQENT")
			EndIf
			ProcLogAtu("ERRO","NOARQENT",Ap5GetHelp("NOARQENT"))

			lRet:= .F.
		Else
			nHdlBco:=FOPEN(cArqEnt,0+64)
			Conout('Abertura do arquivo TXT')
		EndIf
	EndIf

	If lRet

		nLidos:=0
		FSEEK(nHdlBco,0,0)
		nTamArq:=FSEEK(nHdlBco,0,2)
		FSEEK(nHdlBco,0,0)

		ProcRegua( nTamArq/nBloco )

		If (Select("TRB")<>0)
			dbSelectArea("TRB")
			dbCloseArea()
		EndIf

		AADD(aCampos,{"FILMOV"	,"C",IIf( lFWCodFil, FWGETTAMFILIAL, 2 ),0})
		AADD(aCampos,{"BANCO"	,"C",TamSx3("A6_COD")[1],0})
		AADD(aCampos,{"AGENCIA"	,"C",TamSx3("A6_AGENCIA")[1],0})
		AADD(aCampos,{"CONTA"	,"C",TamSx3("A6_NUMCON")[1],0})
		AADD(aCampos,{"DATAD"	,"D",08,0})
		AADD(aCampos,{"NATURE"	,"C",TAMSX3("E2_NATUREZ")[1],0})
		AADD(aCampos,{"MOEDA"	,"C",TAMSX3("E2_MOEDA")[1],0})
		AADD(aCampos,{"TOTAL"	,"N",17,2})

		If(_oFina430 <> NIL)

			_oFina430:Delete()
			_oFina430 := NIL

		EndIf

		_oFina430 := FwTemporaryTable():New("TRB")
		_oFina430:SetFields(aCampos)
		_oFina430:AddIndex("1",{"FILMOV","BANCO","AGENCIA","CONTA","DATAD"})
		_oFina430:Create()

		aArqConf := Directory(mv_par04)

		Begin Transaction

			While nLidos <= nTamArq
				IncProc()
				nDespes :=0
				nDescont:=0
				nAbatim :=0
				nValRec :=0
				nJuros  :=0
				nMulta  :=0
				nValCc  :=0
				nValPgto:=0
				nMoeda	:=0
				nTxMoeda:=0
				nCM     :=0
				ABATIMENTO := 0
				lPagAnt	:= .F.
				lProcDDA := .F.

				cFilAnt := cFilOrig	

				If ( MV_PAR10 == 1 )
					xBuffer:=Space(nBloco)
					FREAD(nHdlBco,@xBuffer,nBloco)

					If lHeader .AND. SubStr(xBuffer,1,1) != "1" .AND. Substr(xBuffer,1,3) != "001" .OR. (cBanco == "409" .and. SubStr(xBuffer,1,1) == "2")  
						If lFA430FIG
							cCGCFilHeader := Substr(xBuffer, 12,14)
						EndIf
					EndIf
					If !lHeader
						lHeader := .T.
						nLidos	+=nBloco
						cCGCFilHeader := Substr(xBuffer, 12,14)
						Loop
					EndIf

					If SubStr(xBuffer,1,1) == "1" .or. Substr(xBuffer,1,3) == "001" .or.;
					(cBanco == "409" .and. SubStr(xBuffer,1,1) == "2")  // Unibanco


						cNumTit :=Substr(xBuffer,Int(Val(Substr(cPosNum, 1,3))),nLenNum )
						cData   :=Substr(xBuffer,Int(Val(Substr(cPosData,1,3))),nLenData)
						cData   :=ChangDate(cData,SEE->EE_TIPODAT)
						dBaixa  :=Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5),"ddmm"+Replicate("y",Len(Substr(cData,5))))
						dDebito :=dBaixa		
						cTipo   :=Substr(xBuffer,Int(Val(Substr(cPosTipo, 1,3))),nLenTipo )
						cNsNum  := " "

						If !Empty(cPosDesp)
							nDespes:=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosDesp,1,3))),nLenDesp))/100,2)
						EndIf
						If !Empty(cPosDesc)
							nDescont:=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosDesc,1,3))),nLenDesc))/100,2)
						EndIf
						If !Empty(cPosAbat)
							nAbatim:=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosAbat,1,3))),nLenAbat))/100,2)
						EndIf
						If !Empty(cPosPrin)
							nValPgto :=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosPrin,1,3))),nLenPrin))/100,2)
						EndIf
						If !Empty(cPosJuro)
							nJuros  :=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosJuro,1,3))),nLenJuro))/100,2)
						EndIf
						If !Empty(cPosMult)
							nMulta  :=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosMult,1,3))),nLenMult))/100,2)
						EndIf
						If !Empty(cPosNsNum)
							cNsNum  :=Substr(xBuffer,Int(Val(Substr(cPosNsNum,1,3))),nLenNsNum)
						EndIf
						If !Empty(cPosRejei)
							cRejeicao  :=Substr(xBuffer,Int(Val(Substr(cPosRejei,1,3))),nLenRejei)
						End
						If !Empty(cPosForne)
							cForne  :=Substr(xBuffer,Int(Val(Substr(cPosForne,1,3))),nLenForne)
						End

						nTamEEOcor := IIf(cPaisLoc == "BRA", SEE->EE_TAMOCOR, 2) 
						cOcorr := Substr(xBuffer,Int(Val(Substr(cPosOcor,1,3))),nLenOcor)
						cOcorr := PadR( Left(Alltrim(cOcorr),nTamEEOcor) , nTamOcor)

						If !Empty(cPosCgc)
							cCgc  :=Substr(xBuffer,Int(Val(Substr(cPosCgc,1,3))),nLenCgc)
						EndIf
						If !Empty(cPosDebito)
							cDebito :=Substr(xBuffer,Int(Val(Substr(cPosDebito,1,3))),nLenDebito)
							cDebito :=ChangDate(cDebito,SEE->EE_TIPODAT)
							If !Empty(cDebito)
								dDebito :=Ctod(Substr(cDebito,1,2)+"/"+Substr(cDebito,3,2)+"/"+Substr(cDebito,5),"ddmm"+Replicate("y",Len(Substr(cDebito,5))))
							EndIf
						EndIf
						nCM     := 0

						//Processo DDA - Bradesco
						cRastro	:= Substr(xBuffer,264,2)     
						cDDA		:= Substr(xBuffer,279,2)		

						//Rastreamento DDA - Bradesco
						If lUsaDDA .and. cBanco = "237" .And. cRastro == "30" .and. cDDA == "FS"

							cBcoForn := Substr(xBuffer,096,3)		//01-03 Banco do cedente - Fornecedor
							cCodBar	:= ""							//Codigo de barras completo
							cFatorVc:= ""							//Fator de Vencimento
							cMoeda	:= "9"							//Moeda do titulo (9 = Real)
							cDV		:= ""							//Digito verIficador do codigo de barras (sera calculado)
							cVencto	:= ""							//Data de vencimento
							cOcorr	:= PadR("FS",nTamOcor)			//Forco Ocorrencia pois a mesma pode voltar vazia em caso de rastreamento DDA

							cVencto		:= Substr(xBuffer,166,8)
							cVencto  	:= ChangDate(cVencto,SEE->EE_TIPODAT)
							cVencto  	:= Substr(cVencto,1,2)+"/"+Substr(cVencto,3,2)+"/"+Substr(cVencto,5)
							cFatorVc	:= StrZero(ctod(cVencto) - ctod("07/10/97"),4)			//Fator de Vencimento

							//Valor do documento
							cValPgto := Substr(xBuffer,195,10)		//Valor do Titulo

							//Bando do Cedente = Bradesco
							If cBcoForn == "237"
								cCpoLivre:= Substr(xBuffer,100,4)+ ;		//Agencia
								Substr(xBuffer,137,2)+ ;	//Carteira
								Substr(xBuffer,140,11)+;	//Nosso Numero
								Substr(xBuffer,111,7)+ ;	//Conta corrente
								"0"							//Zero (fixo)
							Else
								cCpoLivre:= Substr(xBuffer,374,25)		//Campo Livre do codigo de barras
							EndIf

							cDV := DV_BarCode(cBcoForn + cMoeda + cFatorVc + cValPgto + cCpoLivre)

							cCodBar :=	cBcoForn 	+ ;		//01-03 - Codigo do banco
							cMoeda		+ ;		//04-04 - Codigo da moeda
							cDV			+ ;		//05-05 - Digito verIficador
							cFatorVc	+ ;		//06-09 - Fator vencimento
							cValPgto	+ ;		//10-19 - Valor do documento
							cCpoLivre			//20-44 - Campo Livre


							If !Empty(cCodBar)
								lProcDDA := .T.
							EndIf

						EndIf

						If lFa430Fil
							Execblock("FA430FIL",.F.,.F.,{xBuffer} )
						EndIf

						If lF430Var
							aValores := ( { cNumTit, dBaixa, cTipo,;
							cNsNum, nDespes, nDescont,;
							nAbatim, nValPgto, nJuros,;
							nMulta, cForne, cOcorr,;
							cCGC, nCM, cRejeicao, xBuffer })

							ExecBlock("F430VAR",.F.,.F.,{aValores})

						EndIf

						nPos := Ascan(aTabela, {|aVal|aVal[1] == Alltrim(Substr(cTipo,1,3))})
						If nPos != 0
							cEspecie := aTabela[nPos][2]
						Else
							cEspecie	:= "  "
						EndIf
						If cEspecie $ MVABATIM	
							nLidos += nBloco
							Loop
						EndIf

						If lFa430Pa
							If !(ExecBlock("FA430PA",.F.,.F.,cEspecie))
								nLidos += nBloco
								Loop
							EndIf
						EndIf
					Else
						nLidos += nBloco
						Loop
					EndIf
				Else
					If Valtype(MV_PAR04)=="C"
						cArqConf := MV_PAR04
					EndIf 
					aLeitura := ReadCnab2(nHdlBco,cArqConf,nBloco,aArqConf)
					cNumTit  := SubStr(aLeitura[1],1, nTamTit)
					cData    := aLeitura[04]
					cData    := ChangDate(cData,SEE->EE_TIPODAT)
					dBaixa   := Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5),"ddmm"+Replicate("y",Len(Substr(cData,5))))
					cTipo    := aLeitura[02]
					cNsNum   := aLeitura[11]
					nDespes  := aLeitura[06]
					nDescont := aLeitura[07]
					nAbatim  := aLeitura[08]
					nValPgto := aLeitura[05]
					nJuros   := aLeitura[09]
					nMulta   := aLeitura[10]
					cNsNum   := aLeitura[11]
					nTamEEOcor := IIf(cPaisLoc == "BRA", SEE->EE_TAMOCOR, 2)// Tamanho da Ocorrencia Bancaria retornada pelo banco.
					cOcorr   := PadR( Left(Alltrim(aLeitura[03]),nTamEEOcor) , nTamOcor)

					cForne   := aLeitura[16]
					dDebito	 := dBaixa
					xBuffer	 := aLeitura[17]

					//Segmento Z - Autenticacao
					If Len(aLeitura) > 17
						cAutentica := aLeitura[18]
					EndIf

					//CGC
					If Len(aLeitura) > 19
						cCgc := aLeitura[20]
					EndIf

					// Buscar a Conta Oficial. Abaixo alteramos os novos valores de acordo com a SEE
					If !Empty(cCtaOfi)
						cBanco		:= cBcoOfi
						cAgencia	:= cAgeOfi 
						cConta		:= cCtaOfi
					Else
						If Len(aLeitura) > 20
							cBanco	 := PAD(aLeitura[21],nTamBco)
							cAgencia := PAD(aLeitura[22],nTamAge)
							cConta	 := PAD(aLeitura[23],nTamCta)
						Else
							cBanco  := mv_par05
							cAgencia:= mv_par06
							cConta  := mv_par07
						EndIf
					EndIf

					//DDA - Debito Direto Autorizado
					If lUsaDDA .and. Len(aLeitura) > 23
						//Caso o CNPJ do Fornecedor seja retornado no Segmento H, assumo este valor
						If !Empty(aLeitura[24]) .and. Substr(aLeitura[24],1,7) != "0000000"
							cCgc := aLeitura[24]
						EndIf
						cCodBar := aLeitura[25]
						If !Empty(cCodBar)
							lProcDDA := .T.
						EndIf

					EndIf

					If lF430Var
						aValores := ( { cNumTit, dBaixa, cTipo,;
						cNsNum, nDespes, nDescont,;
						nAbatim, nValPgto, nJuros,;
						nMulta, cForne, cOcorr,;
						cCGC, nCM,cRejeicao,xBuffer,;
						cAutentica,cBanco,cAgencia,cConta })

						ExecBlock("F430VAR",.F.,.F.,{aValores})

					EndIf

					If Empty(cNumTit) .And. !lProcDDA
						nLidos += nBloco
						Loop
					EndIf

					nPos := Ascan(aTabela, {|aVal|aVal[1] == Alltrim(Substr(cTipo,1,3))})
					If nPos != 0
						cEspecie := aTabela[nPos][2]
					Else
						cEspecie	:= "  "
					EndIf
					If cEspecie $ MVABATIM			
						Loop
					EndIf

					If lFa430Pa
						If !(ExecBlock("FA430PA",.F.,.F.,cEspecie))
							Loop
						EndIf
					EndIf
				EndIf

				dbSelectArea("SE2")
				dbSetOrder( 1 )
				lHelp := .F.
				lAchouTit := .F.

				/*VerIfica a data de baixa do arquivo em relação ao parâmetro MV_DATAFIN*/
				If AScan( aDtMvFinOk , dBaixa ) == 0
					If AScan( aDtMvFinNt , dBaixa ) == 0 
						If !DtMovFin( dBaixa , .F.,"1" )
							aAdd( aDtMvFinNt , dBaixa )		
							If mv_par10 == 1
								nLidos+=nBloco
							EndIf
							ProcLogAtu( "ERRO" , "DTMOVFIN" , Ap5GetHelp( "DTMOVFIN" ) + " " + DtoC( dBaixa ) )
							Loop
						Else
							aAdd( aDtMvFinOk , dBaixa )
						EndIf
					Else		
						If mv_par10 == 1
							nLidos+=nBloco
						EndIf
						Loop
					EndIf
				EndIf

				aValores := ( { cNumTit, dBaixa, cTipo, cNsNum, nDespes, nDescont, nAbatim, nValPgto, nJuros, nMulta, cForne, cOcorr, cCGC, nCM, cRejeicao, xBuffer })
			
				If !lProcDDA
					If lFa430SE2 .and. !lProcDDA
						ExecBlock("FA430SE2", .F.,.F.,{aValores})
					Else
						
						If mv_par11 == 2 .And. !Empty(xFilial("SE2"))
							//Busca por IdCnab (sem filial)
							SE2->(dbSetOrder(13)) // IdCnab
							If SE2->(MsSeek(Substr(cNumTit,1,10)))
								cFilAnt	:= SE2->E2_FILIAL
								If lCtbExcl
									mv_par09 := 2  //Desligo contabilizacao on-line
								EndIf
							EndIf
						Else
							//Busca por IdCnab
							SE2->(dbSetOrder(11)) // Filial+IdCnab
							SE2->(MsSeek(xFilial("SE2")+	Substr(cNumTit,1,10)))
						EndIf

						If SE2->(!Found())
							SE2->(dbSetOrder(1))
							//Chave retornada pelo banco
							cChave430 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
							While !lAchouTit
								If !dbSeek(xFilial()+cChave430)
									nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,3))},nPos+1)
									If nPos != 0
										cEspecie := aTabela[nPos][2]
										cChave430 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
									Else
										Exit
									EndIf
								Else
									lAchouTit := .T.
								EndIf
							Enddo

							//Chave retornada pelo banco com a adicao de espacos para tratar chave enviada ao banco com
							//tamanho de nota de 6 posicoes e retornada quando o tamanho da nota e 9 (atual)
							If !lAchouTit
								cNumTit := SubStr(cNumTit,1,nTamPre)+Padr(Substr(cNumTit,4,6),nTamNum)+SubStr(cNumTit,10,nTamPar)
								cChave430 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
								nPos := Ascan(aTabela, {|aVal|aVal[1] == Alltrim(Substr(cTipo,1,3))})
								While !lAchouTit
									If !dbSeek(xFilial()+cChave430)
										nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,3))},nPos+1)
										If nPos != 0
											cEspecie := aTabela[nPos][2]
											cChave430 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
										Else
											Exit
										EndIf
									Else
										lAchouTit := .T.
									EndIf
								Enddo
							EndIf

							//Se achou o titulo, verIficar o CGC do fornecedor
							If lAchouTit
								cNumSe2   := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO
								cChaveSe2 := IIf(!Empty(cForne),cNumSe2+SE2->E2_FORNECE,cNumSe2)
								nPosEsp	  := nPos	// Gravo nPos para volta-lo ao valor inicial, caso encontre o titulo

								While !Eof() .and. SE2->E2_FILIAL+cChaveSe2 == xFilial("SE2")+cChave430
									nPos := nPosEsp
									If Empty(cCgc)
										Exit
									EndIf
									dbSelectArea("SA2")
									If dbSeek(xFilial()+SE2->E2_FORNECE+SE2->E2_LOJA)
										If Substr(SA2->A2_CGC,1,14) == cCGC .or. StrZero(Val(SA2->A2_CGC),14,0) == StrZero(Val(cCGC),14,0)
											Exit
										EndIf
									EndIf
									dbSelectArea("SE2")
									dbSkip()
									cNumSe2   := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO
									cChaveSe2 := IIf(!Empty(cForne),cNumSe2+SE2->E2_FORNECE,cNumSe2)
									nPos 	  := 0
								Enddo
							EndIf
						Else
							nPos := 1
						EndIf

						If nPos == 0
							lHelp := .T.
						EndIf
					EndIf

					If !lUmHelp .And. lHelp
						If ! lExecJob
							Help(" ",1,"NOESPECIE",,cNumTit+	" "+cEspecie,5,1)
						EndIf

						ProcLogAtu("ERRO","NOESPECIE",Ap5GetHelp("NOESPECIE"))

						lUmHelp := .T.
					EndIf
				EndIf
				aFa205R:= {}
				If ExecSchedule()
					cStProc := ""
					If ! lAchouTit
						cStProc := "Titulo Inexistente" // "Titulo Inexistente"
						Aadd(aFa205R,{cNumTit,"", "", dBaixa,	0, nValPgto, cStProc })
					ElseIf lHelp
						cStProc := "Titulo com Erro" // "Titulo com Erro"
					EndIf
				EndIf

				If !lHelp

					dbSelectArea("SEB")
					dbSetOrder(1)
					If !(dbSeek(xFilial("SEB")+mv_par05+cOcorr+"P"))
						If ! lExecJob
							//Help(" ",1,"HPFA430OCORR",,STR0025 + Alltrim(cOcorr) + STR0026 + Alltrim(mv_par05) + STR0027,3,1) //"Não existe o código da ocorrência informada: " ## " para o banco: " ## " - Cadastre a ocorrência no SEB."
						EndIf

						ProcLogAtu("ERRO","FA430OCORR",Ap5GetHelp("FA430OCORR"))

					EndIf
					If lFa430Oco
						ExecBlock("FA430OCO", .F., .F., {aValores})
					EndIf
					dbSelectArea("SE2")
					If ( SEB->EB_OCORR $ "01|06|07|08" )      //Baixa do Titulo

						lPagAnt := SE2->E2_TIPO $ MVPAGANT
						If lFA430LP
							lTrocaLP:= ExecBlock("FA430LP",.F.,.F.)
						EndIf
						If !lTrocaLP
							cPadrao:="530"
						Else
							cPadrao:="532"
						EndIf
						cPadrao := If( lPagAnt, "513", cPadrao)
						If cPadrao != cPadAux // Protecao de performance
							lPadrao := VerPadrao(cPadrao)
							lContabiliza := IIf(mv_par09==1,.T.,.F.)
							cPadAux := cPadrao
						EndIf

						If !lCabec .and. lPadrao .and. lContabiliza
							nHdlPrv := HeadProva( cLote,;
							"FINA430",;
							substr( cUsuario, 7, 6 ),;
							@cArquivo )

							lCabec := .T.
						EndIf

						nValEstrang := SE2->E2_SALDO
						lDesconto   := .F.
						nTotAbat	:= SumAbatPag(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,;
						SE2->E2_FORNECE,SE2->E2_MOEDA,"S",dBaixa,SE2->E2_LOJA)
						ABATIMENTO  := nTotAbat

						// Ajusta tamanho suportado pelo campo de Autenticacao Bancÿria
						cAutentica	:= PadR(Alltrim(cAutentica),TamSx3("FK2_AUTBCO")[1])

						If !Empty(cCtaOfi) .and. !lAltPort
							cBanco		:= cBcoOfi
							cAgencia	:= cAgeOfi 
							cConta		:= cCtaOfi
						Else
							If lAltPort
								dbSelectArea("SEA")
								dbSetOrder(1)
								dbSeek(xFilial()+SE2->E2_NUMBOR+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA)
								cBanco      := IIf(Empty(SEA->EA_PORTADO),cBanco,SEA->EA_PORTADO)
								cAgencia    := IIf(Empty(SEA->EA_AGEDEP),cAgencia,SEA->EA_AGEDEP)
								cConta      := IIf(Empty(SEA->EA_NUMCON),cConta,SEA->EA_NUMCON)
							ElseIf Empty(cBanco+cAgencia+cConta)
								cBanco      := mv_par05
								cAgencia    := mv_par06
								cConta      := mv_par07
							EndIf
						EndIf

						cHist070    := STR0008  //"Valor Pago s/ Titulo"

						If SEE->EE_DESPCRD == "S"
							nValPgto+=nDespes
						EndIf
						nTotAger += nValPgto
						cLanca := IIf(mv_par09==1,"S","N")
						cBenef := SE2->E2_NOMFOR

						If ExistBlock("FA430LRM")
							ExecBlock("FA430LRM",.F.,.F.,{xBuffer})
						EndIf

						If SE2->E2_TIPO $ MVPAGANT+"/"+MVTXA

							DbSelectArea("SE5")
							SE5->( DbSetOrder(7) )
							SE5->( DbGoTop() )

							// Busca movimentação já existente para este PAGAMENTO ANTECIPADO
							If !MsSeek(xFilial("SE5") + SE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA) ) .Or. ;
							( MsSeek(xFilial("SE5") + SE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA) ) .And. ( SE5->E5_TIPODOC = "BA" .And. SE5->E5_MOTBX = "PCC" ) .And. SE2->(E2_PIS + E2_COFINS + E2_CSLL + E2_IRRF) > 0 )  

								//Estrutura para o E5_CAMPOS: "{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}"
								cCamposE5 := "{"
								cCamposE5 += " {'E5_DTDIGIT', dDataBase  }"
								cCamposE5 += ",{'E5_LOTE'	, '" + cLoteFin	 + "'}"
								cCamposE5 += ",{'E5_TIPO'	, '" + If(lPagAnt,MVPAGANT,MVTXA)	 + "'}"
								cCamposE5 += ",{'E5_BENEF'  , '" + IIf(Empty(cBenef),SA2->A2_NOME,cBenef)+"'   }" // JBS - 26/08/2013 - Gravação do nome do Benenficiario -   SA2->A2_NOME
								cCamposE5 += ",{'E5_PREFIXO', '" + SE2->E2_PREFIXO	+ "'}"
								cCamposE5 += ",{'E5_NUMERO'	, '" + SE2->E2_NUM		+ "'}"
								cCamposE5 += ",{'E5_PARCELA', '" + SE2->E2_PARCELA	+ "'}"
								cCamposE5 += ",{'E5_CLIfOR'	, '" + SE2->E2_FORNECE	+ "'}"
								cCamposE5 += ",{'E5_FORNECE', '" + SE2->E2_FORNECE	+ "'}"					
								cCamposE5 += ",{'E5_LOJA'	, '" + SE2->E2_LOJA		+ "'}"
								cCamposE5 += ",{'E5_MOTBX'	, 'NOR'}"
								cCamposE5 += "}"

								oModelMov := FWLoadModel("FINM030")					//Model de Movimento a Receber
								oModelMov:SetOperation( MODEL_OPERATION_INSERT )	//Inclusao
								oModelMov:Activate()
								oModelMov:SetValue( "MASTER", "E5_GRV"		,.T.		)	//Informa se vai gravar SE5 ou não
								oModelMov:SetValue( "MASTER", "NOVOPROC"	,.T.		)	//Informa que a inclusão será feita com um novo número de processo
								oModelMov:SetValue( "MASTER", "E5_CAMPOS"	,cCamposE5 )	//Informa os campos da SE5 que serão gravados indepentes de FK5

								oSubFK5 := oModelMov:GetModel("FK5DETAIL")
								oSubFKA := oModelMov:GetModel("FKADETAIL")

								oSubFKA:SetValue( "FKA_IDORIG", FWUUIDV4() )
								oSubFKA:SetValue( "FKA_TABORI", "FK5" )

								//Dados da tabela auxiliar com o código do título a pagar
								cChaveTit := xFilial("SE2") + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM 	+ "|" + SE2->E2_PARCELA + "|" + ;
								SE2->E2_TIPO 	+ "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA

								cIDDoc := FINGRVFK7("SE2", cChaveTit)

								//Informacoes do movimento
								oSubFK5:SetValue( "FK5_ORIGEM"	, FunName() )
								oSubFK5:SetValue( "FK5_DATA"	, dBaixa )
								oSubFK5:SetValue( "FK5_VALOR"	, SE2->E2_VLCRUZ )
								oSubFK5:SetValue( "FK5_VLMOE2"	, SE2->E2_VALOR )
								oSubFK5:SetValue( "FK5_MOEDA"	, StrZero(SE2->E2_MOEDA,2))
								oSubFK5:SetValue( "FK5_NATURE"	, SE2->E2_NATUREZ	)
								oSubFK5:SetValue( "FK5_RECPAG"	, "P" )
								oSubFK5:SetValue( "FK5_TPDOC"	, If(lPagAnt,"PA","VL"))
								oSubFK5:SetValue( "FK5_HISTOR"	, SE2->E2_HIST )
								oSubFK5:SetValue( "FK5_BANCO"	, cBanco )
								oSubFK5:SetValue( "FK5_AGENCI"	, cAgencia )
								oSubFK5:SetValue( "FK5_CONTA"	, cConta )
								oSubFK5:SetValue( "FK5_DTDISP"	, dBaixa )
								oSubFK5:SetValue( "FK5_FILORI"	, cFilAnt )
								oSubFK5:SetValue( "FK5_IDDOC"   , cIDDoc )
								oSubFK5:SetValue( "FK5_LA"	    , If( lPadrao .And. (cLanca == "S") .and. !lUsaFlag,"S","N") )
								oSubFK5:SetValue( "FK5_CCUSTO"  , SE2->E2_CCUSTO)
								If SpbInUse()
									oSubFK5:SetValue( "FK5_MODSPB"	, SE2->E2_MODSPB )
								EndIf
								If SE2->E2_RATEIO == "S"
									oSubFK5:SetValue( "FK5_RATEIO",  "1" )
								Else
									oSubFK5:SetValue( "FK5_RATEIO",  "2" )
								EndIf
								If oModelMov:VldData()
									oModelMov:CommitData()
									SE5->(dbGoto(oModelMov:GetValue( "MASTER", "E5_RECNO" )))
								Else
									lRet := .F.
									cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
									cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
									cLog += cValToChar(oModelMov:GetErrorMessage()[6])
									Help( ,,"FA430GerPA",,cLog, 1, 0 )
								EndIf
								oModelMov:DeActivate()
								oModelMov:Destroy()
								oModelMov := Nil
								oSubFK5   := Nil
								oSubFKA	:= Nil

								If lPadrao .And. cLanca == "S" .and. !lUsaFlag
									RecLock("SE2",.F.)
									SE2->E2_LA	:= "S"
									MsUnlock()
								EndIf

								If lUsaFlag // Armazena em aFlagCTB para atualizar no modulo Contabil
									aAdd( aFlagCTB, { "E5_LA", "S", "SE5", SE5->( RecNo() ), 0, 0, 0} )
									aAdd( aFlagCTB, { "E2_LA", "S", "SE2", SE2->( RecNo() ), 0, 0, 0} )
								EndIf

								If SE2->E2_TIPO $ MVTXA
									Reclock("SE2",.F.)
									SE2->E2_OK := 'TA'
									SE2->(MsUnlock())
								EndIf

								AtuSalBco( cBanco,cAgencia,cConta,SE5->E5_DTDISPO,SE5->E5_VALOR,"-" )
								lBaixou := .T.
								lMovAdto := .T.
							EndIf
						Else

							// Tratamento Moeda Estrangeira
							nMoeda		:= SE2->E2_MOEDA
							nTxMoeda 	:= IIf(nMoeda > 1, IIf(SE2->E2_TXMOEDA > 0 .and. Empty(SE2->E2_DTVARIA), SE2->E2_TXMOEDA,RecMoeda(dBaixa,nMoeda)),0)

							// Serao usadas na Fa080Grv para gravar a baixa do titulo, considerando os acrescimos e decrescimos
							nAcresc     := Round(NoRound(xMoeda(SE2->E2_SDACRES,nMoeda,1,dBaixa,3),3),2)
							nDecresc    := Round(NoRound(xMoeda(SE2->E2_SDDECRE,nMoeda,1,dBaixa,3),3),2)

							nDescont := nDescont - nDecresc
							nJuros	:= nJuros - nAcresc

							If nDescont < 0
								nDescont := 0
							EndIf 

							If nJuros < 0
								nJuros := 0
							EndIf 

							If cPaisLoc == "BRA" 
								If lMVCNBImpg

									aTit := {} 
									lMsErroAuto := .F.
									aAreaCnab := GetArea()
									dbSelectArea("SA2")
									SA2->( dbSetOrder(1) )
									dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
									lIRPFBaixa := IIf( cPaisLoc = "BRA" , SA2->A2_CALCIRF == "2", .F.) .And. Posicione("SED",1,xfilial("SED") + SE2->(E2_NATUREZ),"ED_CALCIRF") = "S" .And. !SE2->E2_TIPO $ MVPAGANT
									RestArea(aAreaCnab)

									nOldValPgto	:= nValPgto
									nValPgto := nValPgto - nJuros + nDescont - nMulta - nAcresc + nDecresc

									nValImp := SE2->( E2_PIS + E2_COFINS + E2_CSLL + E2_IRRF + E2_ISS + E2_INSS )
									nVlrCnab := SE2->E2_VALOR -  nTotAbat

									//Valores acessorios
									nVlrCnab	:= nVlrCnab + nJuros - nDescont + nMulta + nAcresc - nDecresc

									// IRRF
									If lIRPFBaixa
										nVlrCnab -= SE2->E2_IRRF
									EndIf

									// PCC
									If lPCCBaixa
										nVlrCnab -= SE2->( E2_PIS + E2_COFINS + E2_CSLL )
									EndIf

									Do Case
										Case nOldValPgto == 0
										lRet := .F.							
										Case nOldValPgto == nVlrcnab
										cTipoBx := "Baixa Total por CNAB"	
										Case nOldValPgto - nValImp == nVlrcnab 		// Caso o cliente pague o valor bruto do t­tulo ao inv?s do l­quido
										cTipoBx := "Baixa Total por CNAB"														
										nOldValPgto -= nValImp
										Case nOldValPgto + nValImp < nVlrcnab					
										cTipoBx := "Baixa parcial por CNAB"							   									   	
										Case nOldValPgto + nValImp > nVlrcnab 
										cTipoBx := "Baixa Total a mais por CNAB"
										lVlrMaior	:= .T.
										nVlrMaior	:= nOldValPgto - nVlrcnab
									EndCase 

									nValPgto := Round(NoRound(nValPgto,2),2)

									If lRet
										AADD( aTit, { "E2_FILIAL"	, xFilial("SE2")	, Nil})
										AADD( aTit, { "E2_PREFIXO"	, SE2->E2_PREFIXO	, Nil } )
										AADD( aTit, { "E2_NUM"		, SE2->E2_NUM		, Nil } )
										AADD( aTit, { "E2_PARCELA"	, SE2->E2_PARCELA	, Nil } )
										AADD( aTit, { "E2_TIPO"		, SE2->E2_TIPO		, Nil } )
										AADD( aTit, { "E2_FORNECE"	, SE2->E2_FORNECE	, Nil})
										AADD( aTit, { "E2_LOJA"		, SE2->E2_LOJA		, Nil})
										AADD( aTit, { "AUTMOTBX"  	, cMotbx 			, Nil } )	
										AADD( aTit, { "AUTBANCO"	, cBanco			, Nil})
										AADD( aTit, { "AUTAGENCIA" 	, cAgencia			, Nil})
										AADD( aTit, { "AUTCONTA"	, cConta			, Nil})
										AADD( aTit, { "AUTDTBAIXA"	, dBaixa			, Nil } )
										AADD( aTit, { "AUTDTCREDITO", dDebito			, Nil } )
										AADD( aTit, { "AUTHIST"   	, cTipoBx		   	, Nil } )
										AADD( aTit, { "AUTVLRPG"  	, nValPgto - nVlrMaior , Nil } )
										AADD( aTit, { "AUTJUROS"  	, nJuros			, Nil } )
										AADD( aTit, { "AUTDESCONT" 	, nDescont			, Nil } )
										AADD( aTit, { "AUTMULTA" 	, nMulta			, Nil } )
										AADD( aTit, { "AUTACRESC" 	, nAcresc			, Nil } )
										AADD( aTit, { "AUTDECRESC" 	, nDecresc			, Nil } )

										MSExecAuto({|x, y, a, b, c, d| FINA080(x, y, a, b, c, d)}, aTit, 3,,,lOnline,lOnline)

										If  lMsErroAuto
											MOSTRAERRO()     
											DisarmTransaction()
											lBaixou := .F.
										Else
											lBaixou := .T.
										EndIf
										// recarrega os mv_parx da rotina fina430, pois foi alterado no fina080
										pergunte("AFI430",.F.)								
									EndIf
								Else
									lBaixou:=fA080Grv(lPadrao,.F.,.T.,cLanca, mv_par03, nTxMoeda) // Retorno Automatico via Job
									lMovAdto := .F.
								EndIf
							Else
								lBaixou:=fA080Grv(lPadrao,.F.,.T.,cLanca, mv_par03) // Retorno Automatico via Job
								lMovAdto := .F.
							EndIf
						EndIf

						// Retorno Automatico via Job
						// armazena os dados do titulo para emissao de relatorio de processamento
						If ExecSchedule()
							If lBaixou
								Aadd(aFa205R,{SE2->E2_NUM,	SE2->E2_FORNECE,SE2->E2_LOJA,dBaixa,SE2->E2_VALOR, nValPgto, "Baixado ok" })
							Else
								Aadd(aFa205R,{SE2->E2_NUM,	SE2->E2_FORNECE,SE2->E2_LOJA,dBaixa,SE2->E2_VALOR, nValPgto, cStProc })
							EndIf
						EndIf

						If lBaixou .and. !lMovAdto		// somente gera pro lote quando nao for PA para nao duplicar no Extrato
							dbSelectArea("TRB")
							If !(dbSeek(xFilial("SE5")+cBanco+cAgencia+cConta+Dtos(dDebito)))
								Reclock("TRB",.T.)
								Replace FILMOV	With xFilial("SE5")
								Replace BANCO		With cBanco
								Replace AGENCIA	With cAgencia
								Replace CONTA		With cConta
								Replace DATAD		With dDebito
								Replace NATURE	With cNatLote 
								Replace MOEDA		With StrZero(SE2->E2_MOEDA,2)
							Else
								Reclock("TRB",.F.)
							EndIf
							Replace TOTAL WITH TOTAL + nValPgto
							MsUnlock()
						EndIf

						If lF430Baixa
							Execblock("F430BXA",.F.,.F.)
						EndIf

						If lBaixou
							//Contabiliza Rateio Multinatureza
							If lMultNat .and. (SE2->E2_MULTNAT == "1")
								MultNatB("SE2", .F., "1", @lOk, @aColsSEV, @lMultNat, .T.)
								If lOk
									MultNatC("SE2", @nHdlPrv, @nTotal,;
									@cArquivo, (mv_par09 == 1), .T., "1",;
									@nTotLtEZ, lOk, aColsSEV, lBaixou)
								EndIf
							Else
								//Contabiliza o que nao possuir rateio multinatureza
								If lCabec .and. lPadrao .and. lContabiliza .and. lBaixou
									nTotal += DetProva( nHdlPrv,;
									cPadrao,;
									"FINA430" /*cPrograma*/,;
									cLote,;
									/*nLinha*/,;
									/*lExecuta*/,;
									/*cCriterio*/,;
									/*lRateio*/,;
									/*cChaveBusca*/,;
									/*aCT5*/,;
									/*lPosiciona*/,;
									@aFlagCTB,;
									/*aTabRecOri*/,;
									/*aDadosProva*/ )
								EndIf
							EndIf
						EndIf
					EndIf

					If ( SEB->EB_OCORR $ "03" )      //Titulo Rejeitado
						dbSelectArea("SE2")
						dbSetOrder(11)  // Filial+IdCnab
						If !DbSeek(xFilial("SE2")+	Substr(cNumTit,1,nTamTit))
							dbSetOrder(1)
							dbSeek(xFilial()+Pad(cNumTit,nTamTit)+cEspecie) // Filial+Prefixo+Numero+Parcela+Tipo
						EndIf
						cFilAux := cFilAnt
						cFilAnt := cFilOrig //Restauro a filial de origem que estava logada para posicionar o borderô correto
						dbSelectArea("SEA")
						dbSetOrder(1)
						dbSeek(xFilial()+SE2->E2_NUMBOR+SE2->E2_PREFIXO+;
						SE2->E2_NUM+SE2->E2_PARCELA+;
						SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA)
						If ( Found() .And. SE2->E2_SALDO != 0 )
							If lF430Rej
								Execblock("F430REJ",.F.,.F.)
							EndIf
							FA590Canc()// Chamada Função FA590Canc para que o Título seja retirado corretamente do borderô Imp.							
							cFilAnt := cFilAux
						EndIf
					EndIf

					//DDA - Debito Direto Autorizado
					If lUsaDDA .and. lProcDDA //.and. SEB->EB_OCORR $ "02"      //Entrada de titulo via DDA

						If lFA430FIG
							dbSelectArea("SA2")
							dbSetOrder(3)	

							If !Empty(cCGC)
								If MsSeek(xFilial("SA2")+cCGC)
									cCodForn := SA2->A2_COD
								EndIf			
							EndIf	

							cQuery := "SELECT SE2.E2_PREFIXO,SE2.E2_NUM,SE2.E2_PARCELA,SE2.E2_FORNECE,SE2.E2_LOJA FROM " + RetSqlName("SE2") + " SE2 " 
							cQuery += "WHERE SE2.E2_NUM = '" + cNumTit + "' AND SE2.E2_FORNECE = '" + SA2->A2_COD + "' AND SE2.D_E_L_E_T_ <> '*'" 				
							cQuery := ChangeQuery(cQuery)


							dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .F., .T. )
							(cAliasTmp)->(DbGotop())

							cCGC := ExecBlock( "FA430FIG", .F., .F., { cCGC, cCodForn,(cAliasTmp)->E2_PREFIXO,cNumTit,(cAliasTmp)->E2_PARCELA})
							(cAliasTmp)->(DbCloseArea())
						EndIf

						dbSelectArea("SA2")
						dbSetOrder(3)
						MsSeek(xFilial()+cCGC)

						//Grava arquivo de conciliação DDA
						RecLock("FIG",.T.)
						FIG_FILIAL	:= _xFilial //xFilial("FIG")
						FIG_DATA	:= dDataBase
						FIG_FORNEC	:= SA2->A2_COD
						FIG_LOJA	:= SA2->A2_LOJA
						FIG_NOMFOR	:= SA2->A2_NREDUZ
						FIG_TITULO	:= cNumTit
						FIG_TIPO	:= cEspecie
						FIG_VENCTO	:= dBaixa
						FIG_VALOR	:= nValPgto
						FIG_CONCIL	:= "2"
						FIG_CNPJ	:= cCGC
						FIG_CODBAR	:= cCodBar
						MsUnlock()
						Conout('Gravando arquivo de conciliação DDA')
					EndIf

					//Ponto de entrada para gravar na tabela fig a filial pertecente ao cnpj da linha header contido do arquivo .ret			
					If lF430GRAFIL
						aAreaCorr := GetArea()		
						DbSelectArea("SM0")
						SM0->(DbGoTop())

						cCGCFilHeader := IIf(mv_par10 == 1, cCGCFilHeader, cCGC) 

						While SM0->( !Eof() ) .And. !Empty(cCGCFilHeader)
							If (cCGCFilHeader == SM0->M0_CGC)						
								Exit												
							EndIf 					
							SM0->( DbSkip() )
						EndDo

						ExecBlock( "F430GRAFIL", .F., .F., SM0->M0_CODFIL)

						RestArea(aAreaCorr)				
					EndIf

					If FWHasEAI("FINA080",,,.T.)
						ALTERA := .T.
						INCLUI := .F.
						FwIntegDef( 'FINA080' )
					EndIf

				EndIf
				If mv_par10 == 1
					nLidos+=nBloco
				EndIf
			EndDo

			cFilAnt := cFilOrig		// Sempre restaura a filial original

			If lCabec .and. lPadrao .and. lContabiliza
				dbSelectArea("SE2")
				dbGoBottom()
				dbSkip()
				SE5->(dbGoBottom())
				SE5->(dbSkip())
				VALOR := nTotAger
				ABATIMENTO := 0
				nTotal += DetProva( nHdlPrv,;
				cPadrao,;
				"FINA430" /*cPrograma*/,;
				cLote,;
				/*nLinha*/,;
				/*lExecuta*/,;
				/*cCriterio*/,;
				/*lRateio*/,;
				/*cChaveBusca*/,;
				/*aCT5*/,;
				/*lPosiciona*/,;
				@aFlagCTB,;
				/*aTabRecOri*/,;
				/*aDadosProva*/ )
			EndIf

			If lPadrao .and. lContabiliza .and. lCabec
				RodaProva(  nHdlPrv,;
				nTotal )

				lDigita:=IIf(mv_par01==1,.T.,.F.)
				lAglut :=IIf(mv_par02==1,.T.,.F.)
				cA100Incl( cArquivo,;
				nHdlPrv,;
				3 /*nOpcx*/,;
				cLote,;
				lDigita,;
				lAglut,;
				/*cOnLine*/,;
				/*dData*/,;
				/*dReproc*/,;
				@aFlagCTB,;
				/*aDadosProva*/,;
				/*aDiario*/ )

				aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
			End

			If (ExistBlock("FA430REN"))
				FCLOSE(nHdlBco)
				ExecBlock("FA430REN",.f.,.f.)
			EndIf

			// Atualiza os dados da multa pelo SIGAFIN, quando feito retorno pagamento.
			If FindFunction( "NGBAIXASE2" ) .And. GetNewPar( "MV_NGMNTFI","N" ) == 'S' //Se houver integração entre os módulos Manutenção de Ativos e Financeiro
				NGBAIXASE2( 1 )
			EndIf

			If !Empty(cLoteFin) .and. lBxCnab
				If TRB->(Reccount()) > 0
					RecLock("SEE",.F.)
					SEE->EE_LOTECP := cLoteFin
					MsUnLock()
					dbSelectArea("TRB")
					dbGotop()
					While !Eof()
						cFilAnt := TRB->FILMOV

						//Define os campos que não existem na FK5 e que serão gravados apenas na E5, para que a gravação da E5 continue igual
						//Estrutura para o E5_CAMPOS: "{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}"
						cCamposE5 := "{"
						cCamposE5 += " {'E5_DTDIGIT'	,STOD('" + DTOS(TRB->DATAD) + "')}"
						cCamposE5 += ",{'E5_TIPODOC'	,' '}"
						cCamposE5 += ",{'E5_LOTE'	,'" + cLoteFin + "'}"
						cCamposE5 += "}"

						oModelMov := FWLoadModel("FINM030")							//Model de Movimento Bancário
						oModelMov:SetOperation( MODEL_OPERATION_INSERT )			//Inclusao
						oModelMov:Activate()										//Ativa o modelo de dados
						oModelMov:SetValue( "MASTER","E5_GRV"		,.T.		)	//Informa se vai gravar SE5 ou não
						oModelMov:SetValue( "MASTER","NOVOPROC"		,.T.		)	//Informa que a inclusão será feita com um novo número de processo
						oModelMov:SetValue( "MASTER","E5_CAMPOS"	,cCamposE5	)	//Informa os campos da SE5 que serão gravados indepentes de FK5

						oSubFK5 := oModelMov:GetModel("FK5DETAIL")
						oSubFKA := oModelMov:GetModel("FKADETAIL")

						oSubFKA:SetValue( "FKA_IDORIG", FWUUIDV4() )
						oSubFKA:SetValue( "FKA_TABORI", "FK5" )

						//Informacoes do movimento
						oSubFK5:SetValue( "FK5_ORIGEM"	,FunName() )
						oSubFK5:SetValue( "FK5_DATA"	,IIf(!Empty(TRB->DATAD),TRB->DATAD,dBaixa) )
						oSubFK5:SetValue( "FK5_VALOR"	,TRB->TOTAL )
						oSubFK5:SetValue( "FK5_RECPAG"	,"P" )
						oSubFK5:SetValue( "FK5_BANCO"	,TRB->BANCO )
						oSubFK5:SetValue( "FK5_AGENCI"	,TRB->AGENCIA )
						oSubFK5:SetValue( "FK5_CONTA"	,TRB->CONTA )
						oSubFK5:SetValue( "FK5_DTDISP"	,TRB->DATAD )
						oSubFK5:SetValue( "FK5_HISTOR"	,STR0009 + " " + cLoteFin ) // "Baixa por Retorno CNAB / Lote :"
						oSubFK5:SetValue( "FK5_MOEDA"	,TRB->MOEDA	)
						oSubFK5:SetValue( "FK5_NATURE"	,TRB->NATURE	)
						oSubFK5:SetValue( "FK5_TPDOC"	,"VL"	)
						oSubFK5:SetValue( "FK5_FILORI"	,cFilAnt )
						oSubFK5:SetValue( "FK5_LOTE"	,cLoteFin ) 
						If SpbInUse()
							oSubFK5:SetValue( "FK5_MODSPB", "1" )
						EndIf

						If oModelMov:VldData()
							oModelMov:CommitData()
							SE5->(dbGoto(oModelMov:GetValue( "MASTER", "E5_RECNO" )))
						Else
							lRet := .F.
							cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
							cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
							cLog += cValToChar(oModelMov:GetErrorMessage()[6])
							Help( ,,"M030_FA430MOV",,cLog, 1, 0 )
						EndIf
						oModelMov:DeActivate()
						oModelMov:Destroy()
						oModelMov := Nil
						oSubFK5 := Nil
						oSubFKA := Nil

						AtuSalBco(TRB->BANCO,TRB->AGENCIA,TRB->CONTA,SE5->E5_DATA,SE5->E5_VALOR,"-")
						dbSelectArea("TRB")
						dbSkip()
					Enddo
				EndIf
			EndIf

		End Transaction

		If(_oFina430 <> NIL)

			_oFina430:Delete()
			_oFina430 := NIL

		EndIf

		VALOR := 0
		dbSelectArea( cAlias )
		dbGoTo( nSavRecno )

		If lF430COMP
			ExecBlock("F430COMP",.f.,.f.)
		EndIf

	EndIf

	cFilAnt := cFilOrig		

Return .F.

//---------------------------
Static Function fA430Par()
	Pergunte( "AFI430" )
	MV_PAR03 := UPPER(MV_PAR03)
Return .T.

//---------------------------
Static Function ChangDate(__cData,nPosicao)
	LOCAL nPosDia:=0,nPosMes:=0,nPosAno:=0
	LOCAL aSubs  := {}
	
	AADD( aSubs,{ 01,03,05,2 } )
	AADD( aSubs,{ 03,01,05,2 } )
	AADD( aSubs,{ 05,03,01,2 } )
	AADD( aSubs,{ 01,03,05,4 } )
	AADD( aSubs,{ 07,05,01,4 } )
	AADD( aSubs,{ 03,01,05,4 } )

	If nPosicao == 0;nPosicao++;EndIf

	nPosDia := aSubs[nPosicao][1]
	nPosMes := aSubs[nPosicao][2]
	nPosAno := aSubs[nPosicao][3]

	__cData := Substr(__cData,nPosDia,2)+Substr(__cData,nPosMes,2)+Substr(__cData,nPosAno,aSubs[nPosicao][4])

	If Len(__cData) == 8
		__cData := Substr(__cData,1,4)+Substr(__cData,7,2)
	EndIf
Return(__cData)

//---------------------------
Static Function Chk430File()
	Local cFile 	:= "TB"+cNumEmp+".VRF"
	Local lRet		:= .F.
	Local aFiles	:= {}
	Local cString
	Local nTam
	Local nHdlFile
	Local l430Chkfile := ExistBlock("F430CHK")

	If l430ChkFile		// garantir que o arquivo nao seja reenviado
		Return Execblock("F430CHK",.F.,.F.)
	EndIf

	If !FILE(cFile)
		nHdlFile := fCreate(cFile)
	ELSE

		While (nHdlFile := fOpen(cFile,FO_READWRITE+FO_EXCLUSIVE))==-1 .AND. ;
		If(ExecSchedule(),.T., MsgYesNo( STR0011+cNumEmp+STR0012, STR0010 ))
		Enddo
	EndIf

	If nHdlFile > 0

		nTam := TamSx1("AFI430","03")[1] // Tamanho do parametro
		xBuffer := SPACE(nTam)

		// Le o arquivo e adiciona na matriz
		While fReadLn(nHdlFile,@xBuffer,nTam)
			Aadd(aFiles, Trim(xBuffer))
		Enddo

		If ASCAN(aFiles,Trim(MV_PAR03)) > 0
			If ! lExecJob
				Help(" ",1,"CHK200FILE")       // Arquivo de Trans.Banc. j  processado
			EndIf

			If !lExecJob 
				If !MsgYesNo( STR0021, STR0010 )
					ProcLogAtu("ERRO","CHK200FILE",Ap5GetHelp("CHK200FILE"))
				Else
					lRet := .T.
				EndIf
			Else

				lRet := .T.
			EndIf
		Else
			fSeek(nHdlFile,0,2) // Posiciona no final do arquivo
			cString := Alltrim(mv_par03)+Chr(13)+Chr(10)
			fWrite(nHdlFile,cString)	// Grava nome do arquivo a ser processado
			lRet := .T.
		EndIf
		fClose (nHdlFile)
	Else
		If ! lExecJob
			// Help(" ", 1, "CHK200ERRO") // Erro na leitura do arquivo de entrada
		EndIf
		ProcLogAtu("ERRO","CHK200ERRO",Ap5GetHelp("CHK200ERRO"))
		Conout('Erro na leitura do arquivo de entrada')
	EndIf
Return lRet

//---------------------------
Static Function FAVerInd()
Return .T.

//---------------------------
Static Function DV_BarCode( cBarCode )
	Local cDig
	Local nPos
	Local nAux := 0
	For nPos := 1 To 43
		nAux += Val(SubStr(cBarCode,nPos,1)) * If( nPos<= 3, ( 5-nPos),     ;
		If( nPos<=11, (13-nPos),     ;
		If( nPos<=19, (21-nPos),     ;
		If( nPos<=27, (29-nPos),     ;
		If( nPos<=35, (37-nPos),     ;
		(45-nPos) )))))
	Next
	nAux := nAux % 11
	cDig := If( (11-nAux)>9, 1, (11-nAux) )
Return Str(cDig,1)

//---------------------------
Static Function FinA430T(aParam)
	cRotinaExec := "FINA380"
	ReCreateBrow("SE2",FinWindow)
	FinA430()
	ReCreateBrow("SE2",FinWindow)
	dbSelectArea("SE2")
	INCLUI := .F.
	ALTERA := .F.
Return .T.

//---------------------------
Static Function ExecSchedule()
	Local lRetorno := .T.
	lRetorno := IsBlind()
Return( lRetorno )

//---------------------------
Static Function A460FSA2()
	Local cFilter  := SA2->(dbFilter())
	Local cFilBlq  := " !SA2->A2_MSBLQL == '1' "
	Local aGetArea := GETAREA()
	dbSelectArea("SA2")
	If SA2->(FieldPos("A2_MSBLQL")) > 0
		If !'A2_MSBLQL' $ cFilter
			If !Empty(cFilter)
				cFilter += " .AND. "
			EndIf
			cFilter += cFilBlq
			SA2->(dbSetFilter({||&cFilter},cFilter))
		EndIf
	EndIf
	RESTAREA(aGetArea)
Return nil

