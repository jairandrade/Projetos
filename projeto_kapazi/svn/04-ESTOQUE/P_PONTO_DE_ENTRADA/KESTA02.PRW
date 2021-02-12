/** Estoque & Custos                                                                                                             **/
/** Apuração de CIF|GGF|MOD nas ordens de produção                                                                               **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                       **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 27/11/2016 | Rogério Souza Pereira          | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

#Define ENTER CHR(13)+CHR(10)

/**********************************************************************************************************************************/
/** user function KESTA02()                                                                                                      **/
/** Chamada da rotina de apuração de custos                                                                                      **/
/**********************************************************************************************************************************/
user function KESTA02()
	Local	cCadastro	:= "Processamento de custos indiretos"
	local 	cTxtExp   	:= "Esta rotina tem por objetivo calcular os custos indiretos e gerar o movimento interno para cada ordem de produção apropriar o custo."
	Local 	cPerg 		:= PadR("KESTA02", 10)

	If existPerg(cPerg)
		tNewProcess():New("KESTA02", cCadastro, {|oObj| Inicio( oObj ) }, cTxtExp, cPerg)
	Else
		MsgStop("A filial não possui os parâmetros para execução do cálculo. (SX1)")
	Endif

Return


Static Function Inicio(oObj)
	// variaveis auxiliares
	local 	nRegs 		:= 0
	local 	cMsgErro 	:= ""
	local 	lErro 		:= .F.
	Local	dDtIni		:= Stod("")
	Local	dDtFim		:= Stod("")
	Local	cTpProc		:= 0
	Local	lContinua	:= .T.
	Local	nStart		:= 0
	Local	nElap		:= 0
	Local	lSimula		:= .F.
	Local	aCCErro		:= {}
	private cLogFile 	:= "\logs\"
	private nHdl 		:= 0
	private dUlMes 		:= GetMv("MV_ULMES")
	Private oObjProces	:= oObj

	nStart := Seconds()

	dDtIni 	:= mv_par01 //:= Stod("20170101")
	dDtFim 	:= mv_par02 //:= Stod("20170131")
	lSimula := mv_par03 == 1

	dDtIni 	:= mv_par01 //:= Stod("20170101")
	dDtFim 	:= mv_par02 //:= Stod("20170131")
	lSimula := mv_par03 == 1

	//cTpProc := mv_par03 //:= 0

	// valida se o estoque foi fechado
	if dDtIni <= dUlMes
		Aviso("Período incorreto!", "O período informado está incorreto devido ao estoque estar fechado (" + Dtoc(dUlMes) + ")", {"OK"})
		If !lSimula
			return Nil
		Endif
	endIf

	If jaProc(dDtIni,dDtFim)
		Aviso("Já processado!", "O período informado já foi processado.", {"OK"})
		If !lSimula
			return Nil
		Endif
	Endif

	// cria estrutura de pastas para o log
	CriaPasta(cLogFile)

	// nome do arquivo
	cLogFile+= "CUSTO_INDIRETO"+Alltrim(RetCodUsr()) + "_" + Dtos(Date()) + StrTran(Time(), ":", "") + ".txt"
	// cria o arquivo
	nHdl 	:= FCreate(cLogFile)

	if nHdl < 0
		Aviso("Erro no arquivo de log!", "Não foi possível criar o arquivo de log em " + cLogFile + "!", {"OK"})
		return Nil
	endIf

	WriteLog("Inicio processamento.")
	WriteLog("Filial: "+xFilial("SD3")+" "+AllTrim( FWFilialName() ) )
	WriteLog("Data inicial: "+DtoC(dDtIni))
	WriteLog("Data Final: "+DtoC(dDtFim))
	WriteLog("SIMULAÇAO: "+iif(lSimula,"SIM","NAO")+ENTER)
	//WriteLog("Tipo Proc: "+ValToSql(cTpProc))

	WriteLog("Recuperando lançamentos sem centro de custo...")
	//MsgRun("Recuperando lançamentos sem centro de custo...", "Por favor, aguarde...", {|| nRegs := QryCt2(dDtIni,dDtFim,cTpProc,.T.)})

	nRegs := QryCt2(dDtIni,dDtFim,cTpProc,.T.)

	If nRegs > 0
		aadd(aCCErro," ")
		cMsgErro := "Existem lançamentos de MOD sem centro de custo para as contas abaixo:"+ENTER
		While !QCT2->(Eof())
			cMsgErro += AllTrim(QCT2->CT1_CONTA)+" - "+Alltrim(QCT2->CT1_DESC01)+": "+Transform(QCT2->CT2_VALOR,PesqPict("CT2","CT2_VALOR"))+ENTER
			QCT2->( DbSkip() )
		Enddo
		cMsgErro += ENTER
		cMsgErro += "Continuar mesmo assim?"
		lContinua := ShowMsg(cMsgErro)

	Endif

	If Select("QCT2") > 0
		QCT2->( DbCloseArea() )
	Endif

	If lContinua .and. !lSimula
		lContinua := MsgYesNo("Iniciar o processamento dos lançamentos de custo? Esse processo pode demorar.")
		If !lContinua
			WriteLog("Cancelado pelo usuário.")
		Endif
	Endif

	If lContinua

		If !Empty(AllTrim(cMsgErro))
			cMsgErro += " SIM"
			WriteLog(ENTER+cMsgErro+ENTER)

			cMsgErro := ""
		Endif

		// recupera os registros de rateio
		WriteLog("Recuperando registros de rateio...")
		//MsgRun("Recuperando registros de rateio...", "Por favor, aguarde...", {|| nRegs := QryCt2(dDtIni,dDtFim,cTpProc)})

		nRegs := QryCt2(dDtIni,dDtFim,cTpProc)

		// verifica se ha registros
		if nRegs > 0

			oObjProces:SetRegua1( nRegs )
			oObjProces:SetRegua2( 0 )

			// alimenta o log
			WriteLog("Iniciando controle de transação.")
			Begin Transaction

				// executa a rotina
				lErro := CalcGGF(nRegs, @cMsgErro,dDtIni,dDtFim,cTpProc,lSimula,aCCErro)

				// avisa o usuário
				if lErro
					WriteLog("Desfazendo alterações devido a erro.")
					DisarmTransactions()
				Endif

				WriteLog("Finalizando controle de transação.")

			End Transaction

		Else
			Aviso("Não há dados!", "Não foram encontrados registros para o processamento neste período!", {"OK"})
		endIf

		// fecha a query
		QCT2->(DbCloseArea())
	Endif

	nElap	:=  Round(Seconds()-nStart,0)

	// avisa o usuário
	if lErro
		If lContinua
			cMsg	:= "Procedimento concluído com erros."
		Else
			cMsg	:= "Procedimento cancelado pelo usuário."
		endif
	else
		cMsg	:= "Processamento finalizado com sucesso."
	endIf

	cMsg += ENTER+"Tempo processamento: "+Alltrim(Str(nElap))+" segundos."

	WriteLog(cMsg)
	WriteLog("Tempo processamento: "+Alltrim( Str( Round( nElap/60,0 ) ) ) +" minutos.")

	FClose(nHdl)

	If !lErro
		MsgInfo(cMSg)
	Else
		MsgStop(cMsg)
		cMsg := MemoRead(cLogFile)
		ShowMsg(cMsg,cLogFile)
	Endif

	copyLog(cLogFile)

return Nil


/**********************************************************************************************************************************/
/** static function CalcGGF(nRegs, cMsgErro)                                                                                     **/
/** Executa o processamento dos registros                                                                                        **/
/**********************************************************************************************************************************/
static function CalcGGF(nRegs, cMsgErro,dDtIni,dDtFim,cTpProc,lSimula,aCCErro)

	// variaveis auxiliares
	local 	nFatGGF 	:= 0.000000000000000000
	local	nFatCIF 	:= 0.000000000000000000
	local 	nCusMov 	:= 0
	local 	nCusMod 	:= 0
	local 	cProdMod	:= ""
	local 	lErro 		:= .F.
	local 	dDtEncOp 	:= Stod("")
	local 	aSd3 		:= {}
	local 	cTmAbsor 	:= GetNewPar("MV_K_TMABS", "620")
	local 	nQtdMod 	:= DEC_CREATE("0", 18, 0)
	local 	nQtdCc 		:= DEC_CREATE("0", 18, 0)
	local 	nQtdTot 	:= DEC_CREATE("0", 18, 0)
	local 	nValCt2 	:= DEC_CREATE("0", 2, 0)
	local 	cCusF		:= ""
	local 	nPos 		:= 0
	Local	nModTot		:= 0
	Local	nModCC		:= 0
	Local	cMsg		:= ""
	Local	cMsgLog		:= ""
	Local	cFator		:= ""
	Local	nCount		:= 0
	Local	cMsgProd	:= ""
	Local	lContinua	:= .T.
	Local	nConta		:= 0
	Local	aProd		:= {}
	Local	aItem		:= {}
	Local	nExiste		:= 0
	Local	nX 			:= 0
	Local	nOps		:= 0
	private lMsErroAuto := .F.

	Default cMsgErro	:= ""

	nModTot	:= GetMod(dDtIni,dDtFim)
	cMsgLog	:= "Mod Total: " + Transform(nModTot,PesqPict("CT2","CT2_VALOR"))
	WriteLog(cMsgLog)

	If !QCT2->( EOF() )
		WriteLog("Validando produtos mod... ")
		While !QCT2->( EOF() )
			oObjProces:IncRegua2( "Validando produtos mod... " + AllTrim(QCT2->CT2_CCUSTO) + "..." )

			cMsgLog := ""

			cProdMod := produtoMod(QCT2->CTR_DESC,QCT2->CTT_K_CTIN,QCT2->CT2_CCUSTO)

			If !produtoExist(cProdMod)
				nConta ++

				If nConta == 1
					WriteLog("Os produtos de mão de obra abaixo não possuem cadastro e não serão apropriados.")
				Endif

				If !Empty(AllTrim(cMsgLog))
					cMsgLog += ', '
				Endif
				cMsgLog += Alltrim(cProdMod)

				If AllTrim(QCT2->CT2_CCUSTO) $  Alltrim(cProdMod)
					aadd(aCCErro,QCT2->CT2_CCUSTO)
					cMsgLog += " "+QCT2->CTT_DESC01
				Endif

				If !Empty(AllTrim(cMsgProd))
					cMsgProd += ENTER
				Endif
				writelog(cMsgLog)
			Endif

			IF !Empty(AllTrim(cMsgLog))
				cMsgProd += cMsgLog
			Endif

			QCT2->( DbSkip () )
		Enddo

		cMsgLog := ""

		If !Empty(AllTrim(cMsgProd))
			cMsgErro := "Os produtos de mão de obra abaixo não possuem cadastro e não serão apropriados."+ENTER
			cMsgErro += "Continuar mesmo assim?"+ENTER
			cMsgErro += cMsgProd+ENTER

			If !Empty(aCCErro)
				cMsgErro += ENTER+LctoErro(aCCErro,dDtIni,dDtFim)+ENTER
			Endif

			lContinua := ShowMsg(cMsgErro)
			WriteLog("Continuar mesmo assim?")
			If lContinua
				WriteLog(" SIM "+ENTER)
			Else
				WriteLog(" NAO "+ENTER)
			Endif


			cMsgErro := ""
			cMsgProd := ""
		Endif

	Endif

	If !lContinua
		Return .T.
	endif

	QCT2->( DbGoTop() )
	nConta := 0
	// faz o loop sobre os registros
	while !QCT2->(Eof())
		nConta ++

		If nConta == 1

			WriteLog("Iniciando o cálculo dos lançamentos")
			// monta msg para log da memoria de calculo
			cMsgLog		:= 		Padr("Data"			,10						 						)
			cMsgLog		+= +"|"+Padr("Hora"			,8 												)
			cMsgLog		+= +"|"+Padr("OP"			,TamSx3("D3_OP"		)[1] 						)
			cMsgLog		+= +"|"+Padr("Sequen" 		,TamSx3("D3_NUMSEQ"	)[1] 						)
			cMsgLog		+= +"|"+Padr("Ident" 		,TamSx3("D3_IDENT"	)[1] 						)
			cMsgLog		+= +"|"+Padr("CC"			,TamSx3("CT2_CCC"	)[1] 						)
			cMsgLog		+= +"|"+Padr("Prd Mod"		,TamSx3("B1_COD"	)[1] 						)
			cMsgLog		+= +"|"+Padr("Vlr Ctb"		,Len(Transform(0,PesqPict("CT2","CT2_VALOR"))) 	)
			cMsgLog		+= +"|"+Padr("Tp Fator"		,8 												)
			cMsgLog		+= +"|"+Padr("Fator"		,19											 	)
			cMsgLog		+= +"|"+Padr("Vlr Rateiro"	,Len(Transform(0,PesqPict("SD3","D3_CUSTO1")))	)

			WriteLog(ENTER+cMsgLog)
		Endif

		// incrementa a barra de progresso
		//IncProc("Processando CC " + AllTrim(QCT2->CT2_CCUSTO) + "...")
		// atualiza a regua 1 centros de custo
		oObjProces:IncRegua1( "CC " + AllTrim(QCT2->CT2_CCUSTO) +" - "+Alltrim(QCT2->CTT_DESC01)+ "..." )

		// recupera a mao de obra lancada para a empresa
		nModCC	:= GetMod(dDtIni,dDtFim,AllTrim(QCT2->CT2_CCUSTO))

		cProdMod := produtoMod(QCT2->CTR_DESC,QCT2->CTT_K_CTIN,QCT2->CT2_CCUSTO)

		If QCT2->CTT_K_CTIN == "1"
			// traz todas as ordens de producao
			nCount 	:= QrySh6(,dDtIni,dDtFim,cTpProc)
		Else
			// recupera os registros de produção deste centro de custo
			nCount 	:= QrySh6(QCT2->CT2_CCUSTO,dDtIni,dDtFim,cTpProc)
		Endif

		// define regua 2
		oObjProces:SetRegua2( nCount )

		// faz loops nas ordens
		while !QSH6->(Eof())

			// atualiza a regua 2 - ordem de producao
			oObjProces:IncRegua2( "OP " + AllTrim(QSH6->H6_OP) + "..." )

			// calcula os fatores
			nQtdMod := DEC_CREATE(Str(QSH6->D3_QUANT	), 18, 10)
			nValCt2 := DEC_CREATE(Str(QCT2->CT2_VALOR	), 18, 10)
			nQtdCc 	:= DEC_CREATE(Str(nModCC			), 18, 10)
			nQtdTot := DEC_CREATE(Str(nModTot			), 18, 10)

			// define o custo da MOD
			if AllTrim(QCT2->CTR_DESC) == "GGF"

				// SE CENTRO DE CUSTO INDIRETO
				if QCT2->CTT_K_CTIN == "1"
					nFatCIF 	:= DEC_ROUND(Iif(Empty(nModTot)	,nModTot,DEC_DIV(nQtdMod, nQtdTot	) ),17)
					nCusMov 	:= DEC_ROUND(DEC_MUL(nFatCIF, nValCt2),17)
					cFator		:= Padr("FatCIF",8)+"|"+Padr(StrTran(cValToChar(nFatCIF),".",",") ,19)
				// se centro de custo direto
				else
					nFatGGF 	:= DEC_ROUND(Iif(Empty(nModCC)	,nModCC	,DEC_DIV(nQtdMod, nQtdCc	) ),17)
					// gastos gerais
					nCusMov 	:= DEC_ROUND(DEC_MUL(nFatGGF, nValCt2),17)
					cFator		:= Padr("FatGGF",8)+"|"+Padr(StrTran(cValToChar(nFatGGF),".",","),19 )
				endIf
			else
				// SE CENTRO DE CUSTO INDIRETO
				if QCT2->CTT_K_CTIN == "1"
					nFatCIF 	:= DEC_ROUND(Iif(Empty(nModTot)	,nModTot,DEC_DIV(nQtdMod, nQtdTot	) ),17)
					// mao de obra indireta
					nCusMov 	:= DEC_ROUND(DEC_MUL(nFatCIF, nValCt2),17)
					cFator		:= Padr("FatCIF",8)+"|"+Padr(StrTran(cValToChar(nFatCIF),".",",") ,19)
				// se custo direto (filtrado na query para nao aparacer, o sistema ja calcula ele)
				else
					nFatGGF 	:= DEC_ROUND(Iif(Empty(nModCC)	,nModCC	,DEC_DIV(nQtdMod, nQtdCc	) ),17)
					// mao de obra direta
					nCusMov 	:= DEC_ROUND(DEC_MUL(nFatGGF, nValCt2),17)
					cFator		:= Padr("FatGGF",8)+"|"+Padr(StrTran(cValToChar(nFatGGF),".",","),19 )
				endIf

			endIf

			// monta msg para log da memoria de calculo
			cMsgLog		:= 		QSH6->H6_OP
			cMsgLog		+= "|"+ QSH6->D3_NUMSEQ
			cMsgLog		+= "|"+ QSH6->H6_IDENT
			cMsgLog		+= "|"+ QCT2->CT2_CCUSTO
			cMsgLog		+= "|"+ cProdMod
			cMsgLog		+= "|"+ Transform( nValCt2 , PesqPict("CT2","CT2_VALOR") )
			cMsgLog		+= "|"+ cFator
			cMsgLog		+= "|"+ Transform( nCusMov , PesqPict("SD3","D3_CUSTO1") )

			aFator := StrTokArr(cFator,"|")
			
			DbSelectArea("ZPC")
			Reclock("ZPC",.T.)
			ZPC->ZPC_PERIOD := Substr((DTOS(dDtIni)),1,6)
			ZPC->ZPC_OP 	:= QSH6->H6_OP
			ZPC->ZPC_NUMSEQ := QSH6->D3_NUMSEQ
			ZPC->ZPC_IDENT 	:= QSH6->H6_IDENT
			ZPC->ZPC_CC 	:= QCT2->CT2_CCUSTO
			ZPC->ZPC_PRODUT := cProdMod
			ZPC->ZPC_VALOR 	:= Val(StrTran(StrTran((Transform(nValCt2 , PesqPict("ZPC","ZPC_VALOR") )),".",""),",",".")) 
			ZPC->ZPC_FATOR 	:= Alltrim(aFator[1])
			ZPC->ZPC_VLRFAT := Val(StrTran(StrTran((aFator[2]),".",""),",","."))
			ZPC->ZPC_RATEIO := Val(StrTran(StrTran((Transform(nCusMov , PesqPict("ZPC","ZPC_VALOR") )),".",""),",","."))  
			ZPC->ZPC_CONTA	:= QSH6->D3_CONTA
			ZPC->(MsUnlock())

			WriteLog(cMsgLog)

			// atualiza o custo
			cCusF 	:= cValToChar(nCusMov)
			nPos 	:= At(".", cCusF)
			nCusMod := Val(Substr(cCusF, 1, nPos - 1) + Substr(cCusF, nPos, 8))

			// se o produto existe e tem valor de mod
			if produtoExist(cProdMod) .and. nCusMod > 0

				nExiste := aScan(aProd,{ |x| x[1]+x[3] == QSH6->H6_OP+cProdMod } )

				If nExiste == 0
					nOps ++

					If !lSimula
						// cria o armazem, senão existir
						CriaSb2(PadR(cProdMod, TamSx3("B1_COD")[01]), PadR(SB1->B1_LOCPAD, TamSx3("B1_LOCPAD")[01]))
					Endif

					aItem := {}
					aadd(aItem,QSH6->H6_OP				) // 1
					aadd(aItem,cTmAbsor					) // 3
					aadd(aItem,cProdMod					) // 3
					aadd(aItem,SB1->B1_LOCPAD			) // 4
					aadd(aItem,nCusMod					) // 5
					aadd(aItem,Stod(QSH6->D3_EMISSAO)	) // 6
					aadd(aItem,"S"						) // 7
					aadd(aItem,QSH6->D3_NUMSEQ			) // 8
					aadd(aItem,QSH6->H6_IDENT			) // 9
					aadd(aProd,aItem)
				Else
					aProd[nExiste][5] += nCusMod
				Endif
			endIf
			// proximo registro
			QSH6->(DbSkip())
		endDo

		//Memowrite("c:\temp\querys\CUSTOCIFGGF_"+AllTrim(QCT2->CT2_CCUSTO)+".txt",cVarInfo)

		// fecha a query
		QSH6->(DbCloseArea())

		// se houve erro na rotina automatica, sai do loop
		if lMsErroAuto
			Exit
		endIf

		// proximo registro
		QCT2->(DbSkip())
	endDo

	aSort(aProd,,,{|x,y| x[1]+x[3] <= y[1]+y[3] })

	WriteLog("Iniciando gravacao dos movimentos na SD3.")
	oObjProces:SetRegua1( nOps-1 )
	oObjProces:SetRegua2( Len(aProd)-1 )

	For nX := 1 to Len(aProd)

		oObjProces:IncRegua1("OP: "+(aProd[nX][1]))
		oObjProces:IncRegua2("Prod: "+AllTrim(aProd[nX][3]) )

		If nX == 1
			WriteLog("Inicio dos lançamentos na SD3")
			cMsgLog		:= 		Padr("Data"			,10						 						)
			cMsgLog		+= +"|"+Padr("Hora"			,8 												)
			cMsgLog		+= +"|"+Padr("OP"			,TamSx3("D3_OP"		)[1] 						)
			cMsgLog		+= +"|"+Padr("Sequen"		,TamSx3("D3_NUMSEQ"	)[1] 						)
			cMsgLog		+= +"|"+Padr("Ident"		,TamSx3("D3_IDENT"	)[1] 						)
			cMsgLog		+= +"|"+Padr("Produto"		,TamSx3("B1_COD"	)[1] 						)
			cMsgLog		+= +"|"+Padr("Valor"		,Len(Transform(0,PesqPict("SD3","D3_CUSTO1")))	)
			WriteLog(ENTER+cMsgLog)
		Endif

		cMsg := 	 Padr( aProd[nX][1], TamSx3("D3_OP"		)[1]		)
		cMsg += "|"+ Padr( aProd[nX][8], TamSx3("D3_NUMSEQ"	)[1]		)
		cMsg += "|"+ Padr( aProd[nX][9], TamSx3("D3_IDENT"	)[1]		)
		cMsg += "|"+ Padr( aProd[nX][3], TamSx3("B1_COD"	)[1]		)
		cMsg += "|"+ Transform( aProd[nX][5], PesqPict("SD3","D3_CUSTO1") )

		Writelog(cMsg)
		If !lSimula
			// posiciona a ordem de producao
			SC2->(DbSetOrder(1))
			if SC2->(MsSeek(XFilial("SC2") + aProd[nX][1]))
				// verifica se a OP esta encerrada
				if Empty(SC2->C2_DATRF)
					dDtEncOp := Stod("")
				else
					// salva a data de encerramento
					dDtEncOp := SC2->C2_DATRF

					// reativa a OP
					RecLock("SC2", .F.)
						SC2->C2_DATRF := Stod("")
					MsUnlock()
				endIf

				// gera o registro de rateio na MOD
				aSd3 := {}
				AAdd(aSd3, {"D3_OP"		, aProd[nX][1]				, Nil})
				AAdd(aSd3, {"D3_TM"		, aProd[nX][2]				, Nil})
				AAdd(aSd3, {"D3_COD"	, aProd[nX][3]				, Nil})
				AAdd(aSd3, {"D3_LOCAL"	, aProd[nX][4]				, Nil})
				AAdd(aSd3, {"D3_CUSTO1"	, aProd[nX][5]				, Nil})
				AAdd(aSd3, {"D3_EMISSAO", aProd[nX][6]				, Nil})
				AAdd(aSd3, {"D3_MODABS"	, aProd[nX][7]				, Nil})
				AAdd(aSd3, {"D3_OBSERVA","KESTA02 CUSTO INDIRETO"	, Nil})

				//cVarInfo	+= varinfo("aSd3",aSd3,0,.f.)

				// executa a rotina automatica
				lMsErroAuto := .F.
				MsExecAuto({|x, y| Mata240(x, y)}, aSd3, 3)

				if lMsErroAuto
					// erro na rotina automatica
					MostraErro()
					lErro := .T.
					exit
				else
					// atualiza o NUMSEQ do movimento
					RecLock("SD3", .F.)
						SD3->D3_NUMSEQ := aProd[nX][8]
					MsUnlock("SD3")
					
				endIf

				// procedimento ok, restaura a OP
				RecLock("SC2", .F.)
					SC2->C2_DATRF := dDtEncOp
				MsUnlock("SC2")

			endIf
		Endif
	Next
return lErro


/**********************************************************************************************************************************/
/** static function QrySh6(cCusto)                                                                                               **/
/** Recupera os registros de produção para rateio                                                                                **/
/**********************************************************************************************************************************/
static function QrySh6(cCusto,dDtIni,dDtFim,cTpProc)

	// variaveis auxiliares
	local cQr 	:= ""
	local aArea := GetArea()
	Local nRet	:= 0

	// define a query de pesquisa
	cQr := "SELECT  "+ENTER
	cQr += "	D3_FILIAL "+ENTER
	cQr += "	,D3_CF "+ENTER
	cQr += "	,H6_OP "+ENTER
	cQr += "	,D3_EMISSAO "+ENTER
	cQr += "	,H6_DTAPONT "+ENTER
	cQr += "	,H6_DATAINI "+ENTER
	cQr += "	,H6_HORAINI "+ENTER
	cQr += "	,H6_DATAFIN "+ENTER
	cQr += "	,H6_HORAFIN "+ENTER
	cQr += "	,H6_TEMPO "+ENTER
	cQr += "	,D3_QUANT "+ENTER
	cQr += "	,H6_IDENT "+ENTER
	cQr += "    ,D3_NUMSEQ "+ENTER
	cQr += "	,D3_COD "+ENTER
	cQr += "	,D3_CONTA "+ENTER
	cQr += " "+ENTER

	cQr += "FROM " + RetSqlName("SD3") + " SD3 "+ENTER
	cQr += "	LEFT JOIN " + RetSqlName("SH6") + " SH6 On SH6.D_E_L_E_T_ <> '*' "+ENTER
	cQr += "		AND SH6.H6_FILIAL = SD3.D3_FILIAL "+ENTER
	cQr += "		AND SH6.H6_IDENT = SD3.D3_IDENT "+ENTER
	cQr += " "+ENTER
	cQr += "WHERE  "+ENTER
	cQr += "		SD3.D_E_L_E_T_ = ' ' "+ENTER
	cQr += "	AND D3_FILIAL 	= '"+xFilial("SD3")		+ "' "+ENTER
	cQr += "	AND D3_EMISSAO >= " + ValToSql(dDtIni) 	+ " "+ENTER
	cQr += "	AND D3_EMISSAO <= " + ValToSql(dDtFim) 	+ " "+ENTER
	cQr += "	AND D3_COD LIKE 'MOD%' 	"+ENTER
	cQr += "	AND D3_ESTORNO != 'S' 	"+ENTER

	If !Empty(AllTrim(cCusto))
		cQr += "	AND SUBSTRING(SD3.D3_COD, 4, 9)='"+cCusto+"' "+ENTER
	Endif

	//cQr += "	AND D3_OP 		= '52046101001' "+ENTER

	cQr += " "+ENTER
	cQr += "	ORDER BY D3_FILIAL,H6_OP,H6_IDENT "+ENTER

	Memowrite("\logs\querys\kesta02_qsh6.sql",cQr)

	// abre a query
	TcQuery cQr new alias "QSH6"
	Count to nRet

	QSH6->( DbGoTop() )

	RestArea(aArea)

return nRet


/**********************************************************************************************************************************/
/** static function QryCt2(nRegs)                                                                                                **/
/** Recupera os registros de rateio                                                                                              **/
/**********************************************************************************************************************************/
static function QryCt2(dDtIni,dDtFim,cTpProc,lSemCentro)
	Local nRet	:= 0
	// variaveis auxiliares
	local cQr 	:= ""
	local aArea := GetArea()

	Default lSemCentro := .F.

	// define a query de pesquisa
	cQr := "SELECT "+ENTER
	cQr += "	CT2_FILIAL  "+ENTER
	cQr += "	,CTR_DESC "+ENTER
	cQr += "	,CTT_K_CTIN "+ENTER
	cQr += "	,CT2_CCUSTO "+ENTER
	cQr += "	,CTT_DESC01 "+ENTER
	cQr += "	,CT2_VALOR "+ENTER
	If lSemCentro
		cQr += "	,CT1_CONTA "+ENTER
		cQr += "	,CT1_DESC01 "+ENTER
	Endif
	//cQr += "	,dbo.fun_GetTempoProducao_" + SM0->M0_CODIGO + "(V.CT2_FILIAL, '" + Dtos(dDtIni) + "', '" + Dtos(dDtFim) + "', V.CT2_CCUSTO) CT2_MODCC "+ENTER
	//cQr += "	,dbo.fun_GetTempoProducao_" + SM0->M0_CODIGO + "(V.CT2_FILIAL, '" + Dtos(dDtIni) + "', '" + Dtos(dDtFim) + "', null) CT2_MODTOT "+ENTER
	cQr += " "+ENTER
	cQr += "FROM (	SELECT
	cQr += "			CT2_FILIAL "+ENTER
	cQr += " 			,CTR_DESC "+ENTER
	cQr += "			,CTT_K_CTIN "+ENTER
	cQr += "			,CT2_CCUSTO "+ENTER
	cQr += "			,CTT_DESC01 "+ENTER
	If lSemCentro
		cQr += "			,CT1_CONTA "+ENTER
		cQr += "			,CT1_DESC01 "+ENTER
	Endif
	cQr += "			,SUM(V.CT2_VALOR) CT2_VALOR "+ENTER
	cQr += " "+ENTER
	cQr += "		FROM V_LANCAMENTOS_CONTABEIS_" + SM0->M0_CODIGO + " V
	cQr += " "+ENTER
	cQr += "		WHERE "+ENTER
	cQr += "			CT2_FILIAL= '" + xFilial("CT2") + "' "+ENTER
	cQr += "			AND CT2_DATA >= '" + Dtos(dDtIni) + "' "+ENTER
	cQr += "			AND CT2_DATA <= '" + Dtos(dDtFim) + "' "+ENTER
	// nao traz mao de obra direta
	cQr += "			AND NOT ( CTR_DESC='MOD' AND  CTT_K_CTIN<>'1'  ) "+ENTER
	//cQr += "			AND CTT_K_CTIN = '1' "+ENTER
	If lSemCentro
		cQr += "			AND CT2_CCUSTO= '' "+ENTER
	Else
		cQr += "			AND CT2_CCUSTO<>'' "+ENTER
	Endif
	cQr += "			AND CT1_GRUPO <> '' "+ENTER
	cQr += " "+ENTER
	cQr += "		GROUP BY "+ENTER
	cQr += "			CT2_FILIAL "+ENTER
	cQr += "			,CTR_DESC "+ENTER
	cQr += "			,CTT_K_CTIN "+ENTER
	If lSemCentro
		cQr += "			,CT1_CONTA "+ENTER
		cQr += "			,CT1_DESC01 "+ENTER
	Endif
	cQr += "			,CTT_DESC01 "+ENTER
	cQr += "			,CT2_CCUSTO ) as V "+ENTER
	cQr += " "+ENTER
	cQr += " ORDER BY CT2_CCUSTO,CTR_DESC "+ENTER

	If lSemCentro
		Memowrite("\logs\querys\kesta02_qct2_sem.sql",cQr)
	Else
		Memowrite("\logs\querys\kesta02_qct2.sql",cQr)
	Endif

	// abre a query
	TcQuery cQr new alias "QCT2"
	count to nRet

	QCT2->(DbGoTop())

	RestArea(aArea)

return nRet


/**********************************************************************************************************************************/
/** static function ShowLog()                                                                                                    **/
/** Mostra a tela de logs do processamento                                                                                       **/
/**********************************************************************************************************************************/
static function ShowMsg(_cMemo,_cArquivo)

	// variaveis auxiliares
	local 	nPosX 		:= 0
	local	nPosY 		:= 0
	Local	lRet		:= .F.
	Local	oMemo
	private oDlgLogs	:= Nil
	private oGrpLogs 	:= Nil

	// define a tela de logs
	define MsDialog oDlgLogs from 0, 0 to 500, 800 title "" pixel

	// define a posição do grupo
	nPosX := 0
	nPosY := 3
	oGrpLogs := TGroup():New(nPosX, nPosY, nPosX + 230, nPosY + 395, "[ Mensagem ]", oDlgLogs, CLR_BLACK, Nil, .T.)

	// posiciona o periodo inicial
	nPosX += 8
	nPosY += 5
	@ nPosX, nPosY Get oMemo var _cMemo size 385, 217 MEMO ReadOnly of oGrpLogs pixel

	// posiciona os botoes de comando
	nPosX += 226
	nPosY += 345

	@ nPosX, nPosY 		button "Confirmar"	size 45, 12 action {|| lRet := .T.,oDlgLogs:End()} 		of oDlgLogs pixel
	@ nPosX, nPosY-60 	button "Cancelar"	size 45, 12 action {|| lRet := .F.,oDlgLogs:End()} 		of oDlgLogs pixel

	If !Empty(AllTrim(_cArquivo))
		@ nPosX, nPosY-120 	button "Abrir Log" 	size 45, 12 action copyLog(_cArquivo)	of oDlgLogs pixel
	Endif

	// carrega o arquivo de logs para o memo
	//cGetLog := MemoRead(cLogFile)

	// ativa a tela
	Activate MsDialog oDlgLogs centered


return lRet


/**********************************************************************************************************************************/
/** static function WriteLog(cTexto)                                                                                             **/
/** Grava o logo do usuário                                                                                                      **/
/**********************************************************************************************************************************/
static function WriteLog(cTexto)

	// grava o texto no arquivo de log
	FWrite(nHdl, Dtoc(Date()) + "|" + Time() + "|" + cTexto + chr(13) + chr(10))

return Nil


/**********************************************************************************************************************************/
/** static function ProcSx1(cPerg)                                                                                               **/
/** processa a criação das perguntas no SX1                                                                                      **/
/**********************************************************************************************************************************/
//static function ProcSx1(cPerg)
//
//	// variáveis auxiliares
//	local cIndice 	:= "00"
//	local cVarCh 	:= "mv_ch0"
//	local cVarPar 	:= "mv_par00"
//	local cIdx0 	:= "0"
//	local aParPerg 	:= {}
//	Local nI		:= 0
//
//	/* aParPerg[]
//	aParPerg[n][01] : nome da pergunta
//	aParPerg[n][02] : descrição
//	aParPerg[n][03] : tipo
//	aParPerg[n][04] : tamanho
//	aParPerg[n][05] : decimais
//	aParPerg[n][06] : indice de pre selecao de combo
//	aParPerg[n][07] : tipo de objeto ( G=Edit|S=Text|C=Combo|R=Range|F=File|E=Expression|K=Check )
//	aParPerg[n][08] : rotina de validação do SX1
//	aParPerg[n][09] : F3
//	aParPerg[n][10] : grupo de perguntas
//	aParPerg[n][11] : item 1 do combo
//	aParPerg[n][11] : item 2 do combo
//	aParPerg[n][11] : item 3 do combo
//	aParPerg[n][11] : item 4 do combo
//	aParPerg[n][11] : item 5 do combo
//	aParPerg[n][12] : array de help */
//
//	// cria as perguntas do array
//	AAdd(aParPerg, {cPerg, "De Data Processamento?"	, "D", 8, 0, 0, "G", "", "", "", ""		, ""	, "", Nil, Nil, {"Informe o periodo inicial."}})
//	AAdd(aParPerg, {cPerg, "Ate Data Processamento?", "D", 8, 0, 0, "G", "", "", "", ""		, ""	, "", Nil, Nil, {"Informe o periodo final."}})
//	AAdd(aParPerg, {cPerg, "Simular Calculo?"		, "N", 1, 0, 0, "C", "", "", "", "Sim"	, "Nao"	, "", Nil, Nil, {"Executar o calculo sem gravar os movimentos?."}})
//
//	// inicializa as variaveis
//	cIndice := "00"
//	cIdx0 := "0"
//	cVarCh := "mv_ch0"
//	cVarPar := "mv_par00"
//
//	// inicializa a barra de progressos
//	ProcRegua(Len(aParPerg))
//
//	// loop sobre os parametros a adicionar
//	for nI := 1 to Len(aParPerg)
//
//		// incrementa os contadores
//		cIndice := soma1(cIndice)
//		cIdx0 := soma1(cIdx0)
//		cVarCh := "mv_ch" + cIdx0
//		cVarPar := "mv_par" + cIndice
//
//		// incrementa a barra de progressos
//		IncProc("Criando perguntas " + allTrim(cIndice) + "/" + StrZero(Len(aParPerg), 2) + "..." )
//
//		// adiciona o parametro
//		PutSx1( aParPerg[nI][01] ,; // nome da pergunta
//		cIndice          ,; // indice
//		aParPerg[nI][02] ,; // descricao portugues
//		aParPerg[nI][02] ,; // descricao espanhol
//		aParPerg[nI][02] ,; // descricao ingles
//		cVarCh           ,; // variavel mv_ch
//		aParPerg[nI][03] ,; // tipo
//		aParPerg[nI][04] ,; // tamanho
//		aParPerg[nI][05] ,; // decimais
//		aParPerg[nI][06] ,; // indice de pre-seleção (combo)
//		aParPerg[nI][07] ,; // tipo do objeto
//		aParPerg[nI][08] ,; // validação
//		aParPerg[nI][09] ,; // F3
//		aParPerg[nI][10] ,; // grupo de perguntas
//		" "              ,; // parametro pyme
//		cVarPar          ,; // variavel mv_par
//		aParPerg[nI][11] ,; // item 1 do combo (portugues)
//		aParPerg[nI][11] ,; // item 1 do combo (espanhol)
//		aParPerg[nI][11] ,; // item 1 do combo (ingles)
//		""               ,; // conteudo padrao da pergunta
//		aParPerg[nI][12] ,; // item 2 do combo (portugues)
//		aParPerg[nI][12] ,; // item 2 do combo (espanhol)
//		aParPerg[nI][12] ,; // item 2 do combo (ingles)
//		aParPerg[nI][13] ,; // item 3 do combo (portugues)
//		aParPerg[nI][13] ,; // item 3 do combo (espanhol)
//		aParPerg[nI][13] ,; // item 3 do combo (ingles)
//		aParPerg[nI][14] ,; // item 4 do combo (portugues)
//		aParPerg[nI][14] ,; // item 4 do combo (espanhol)
//		aParPerg[nI][14] ,; // item 4 do combo (ingles)
//		aParPerg[nI][15] ,; // item 5 do combo (portugues)
//		aParPerg[nI][15] ,; // item 5 do combo (espanhol)
//		aParPerg[nI][15] ,; // item 5 do combo (ingles)
//		aParPerg[nI][16] ,; // memo de help (portugues)
//		aParPerg[nI][16] ,; // memo de help (espanhol)
//		aParPerg[nI][16] ,; // memo de help (ingles)
//		"" /* help*/ )
//
//	next nI
//
//return nil


Static Function GetMod(dDtIni,dDtFim,cCC)
	Local aArea		:= GetArea()
	Local nRet	 	:= 0
	Local cQuery 	:= ""
	Local cTemp		:= GetNextAlias()

	Default cCC 	:= ""

	cQuery := "SELECT "+ENTER
	cQuery += "dbo.fun_GetTempoProducao_"+SM0->M0_CODIGO+"('"+xFilial("SD3")+"', "+ENTER"
	cQuery += ValToSql(dDtIni)+", "+ENTER
	cQuery += ValToSql(dDtFim)+", "+ENTER

	IF Empty( AllTrim(cCC) )
		cQuery += "Null "+ENTER
	Else
		cQuery += ValToSql(cCC)+" "+ENTER
	Endif

	cQuery += ") VALOR"+ENTER

	If Select(cTemp)>0
		(cTemp)->( DbCloseArea() )
	Endif

	Memowrite("\logs\querys\kesta02_getmod.sql",cQuery)

	TcQuery cQuery New Alias (cTemp)

	If !(cTemp)->( EOF() )
		nRet := (cTemp)->VALOR
	Endif

	If Select(cTemp)>0
		(cTemp)->( DbCloseArea() )
	Endif

	RestArea(aArea)
Return nRet



Static Function CriaPasta(cCaminho)
	// posicao da barra
	Local nAt			:= 0
	// original
	Local cOrigem	:= cCaminho+"\"
	// temporario
	Local cTemp		:= "\"
	// arquivos
	Local aArq		:= ""

	// faz loop
	While cTemp <> cOrigem
		// localiza a proxima barra
		nAt		:= at('\',cOrigem,Len(cTemp)+1)
		// corta o caminho original
		cTemp := Substring(cOrigem,1,nAt)

		// obtem os arquivos
		aArq	:= Directory(cTemp+"*","D")

		// se pasta vazia
		If Empty(aArq)
			// cria a pasta
			MakeDir(cTemp)
		Endif

	Enddo

	// retorna
Return



Static Function	produtoExist(_cProd)
 	Local lRet 		:= .T.

	_cProd := Padr(_cProd,TamSx3("B1_COD")[1] )

	// valida se o produto está cadastrado
	SB1->(DbSetOrder(1))
	// localizou o produto
	lRet := SB1->(DbSeek(xFilial("SB1") + _cProd))

Return lRet


Static Function copyLog(_cArq)
	Local cTempPath	:= GetTempPath()
	Local cArquivo	:= _cArq
	Local nPos		:= rAt("\",cArquivo)

	cArquivo := Substr(cArquivo,nPos+1,Len(cArquivo) )

	If File(_cArq)

		__copyFile(_cArq,cTempPath+cArquivo)

		If file(cTempPath+cArquivo)
			ShellExecute( "Open",cTempPath+cArquivo,"",cTempPath,1)
		Endif
	Endif

Return

Static Function produtoMod(cTpDespesa,cTpCCusto,cCusto)
	Local cRet		:= ""
	Local lIndireto := cTpCCusto == "1"

	cTpDespesa := AllTrim(cTpDespesa)

	if cTpDespesa == "GGF"

		// SE CENTRO DE CUSTO INDIRETO
		if lIndireto
			cRet 	:= "CIF"
		// se centro de custo direto
		else
			// gastos gerais
			cRet 	:= "GGF" + cCusto
		endIf

	else
		// SE CENTRO DE CUSTO INDIRETO
		if lIndireto
			// mao de obra indireta
			cRet 	:= "MOI"
		// se custo direto
		else
			// mao de obra direta
			cRet 	:= "MOD" + cCusto
		endIf

	endIf

	cRet := Padr(cRet,TamSx3("B1_COD")[1])


Return cRet


Static Function existPerg(cPerg)
	local lRet 	:= .T.
	Local aArea := GetArea()

//	// cria as perguntas do array
//	AAdd(aParPerg, {cPerg, "De Data Processamento?"	, "D", 8, 0, 0, "G", "", "", "", ""		, ""	, "", Nil, Nil, {"Informe o periodo inicial."}})
//	AAdd(aParPerg, {cPerg, "Ate Data Processamento?", "D", 8, 0, 0, "G", "", "", "", ""		, ""	, "", Nil, Nil, {"Informe o periodo final."}})
//	AAdd(aParPerg, {cPerg, "Simular Calculo?"		, "N", 1, 0, 0, "C", "", "", "", "Sim"	, "Nao"	, "", Nil, Nil, {"Executar o calculo sem gravar os movimentos?."}})

	SX1->( DbSetOrder(1) )
	SX1->( DbGoTop() )
	lRet := SX1->( MsSeek( cPerg ))

	RestArea(aArea)
Return lRet

Static Function jaProc(dDtIni,dDtFim)
	Local lRet 	:= .F.
	Local cQuery:= ""
	Local cTemp := GetNextAlias()
	Local aArea	:= GetArea()

	cQuery += "SELECT COUNT(*) QUANTIDADE "+ENTER
	cQuery += " "+ENTER
	cQuery += "FROM "+RetSqlName("SD3")+" "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "and D3_FILIAL='"+xFilial("SD3")+"' "+ENTER
	cQuery += "AND D3_ESTORNO <> 'S' "+ENTER
	cQuery += "AND D3_EMISSAO >= '"+DtoS(dDtIni)+"' "+ENTER
	cQuery += "AND D3_EMISSAO <= '"+DtoS(dDtFim)+"' "+ENTER
	cQuery += "and D3_UM='HR' "+ENTER
	cQuery += "AND D3_OBSERVA LIKE '%KESTA02%' "+ENTER

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif

	TcQuery cQuery New Alias (cTemp)

	If !(cTemp)->( EOF() )
		lRet := (cTemp)->QUANTIDADE > 0
	Endif

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif

	RestArea(aArea)
Return lRet


Static Function LctoErro(aCCErro,dDtIni,dDtFim)
	Local cQuery 	:= ""
	Local cTemp		:= GetNextAlias()
	Local cRet		:= ""
	Local cCC		:= ""
	Local nX		:= 0
	Local cMsg		:= ""

	aSort(aCCErro,,,{|x,y| x > y})

	For nX := 1 to Len(aCCErro)
		If !Empty(cCC)
			cCC += "/"
		Endif

		cCC += aCCErro[nX]
	Next

	cCC := FormatIn(cCC,"/")

	cQuery += "SELECT "+ENTER
	cQuery += "	CT2_FILIAL "+ENTER
	cQuery += "	,CT2_DATA "+ENTER
	cQuery += "	,CT1_CONTA "+ENTER
	cQuery += "	,CT1_DESC01 "+ENTER
	cQuery += "	,CTR_DESC "+ENTER
	cQuery += "	,CT2_CCUSTO "+ENTER
	cQuery += "	,CTT_DESC01 "+ENTER
	cQuery += "	,CT2_VALOR "+ENTER
	cQuery += "	,CT2_HIST "+ENTER
	cQuery += "	,CT2_LOTE "+ENTER
	cQuery += "	,CT2_SBLOTE "+ENTER
	cQuery += "	,CT2_DOC "+ENTER
	cQuery += "	,CT2_LINHA "+ENTER
	cQuery += " "+ENTER
	cQuery += "FROM V_LANCAMENTOS_CONTABEIS_04 "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE "+ENTER
	cQuery += "		CT2_FILIAL='"+xFilial("CT2")+"' "+ENTER
	cQuery += "	AND CT2_DATA>='"+DtoS(dDtIni)+"' "+ENTER
	cQuery += "	AND CT2_DATA<='"+DtoS(dDtFim)+"' "+ENTER
	cQuery += "	AND CT2_CCUSTO IN "+cCC+" "+ENTER
	cQuery += "	AND CT1_GRUPO <> '' "+ENTER
	cQuery += "	AND NOT ( CTR_DESC='MOD' AND  CTT_K_CTIN<>'1'  ) "+ENTER
	cQuery += " "+ENTER
	cQuery += "ORDER BY "+ENTER
	cQuery += "	CT2_FILIAL "+ENTER
	cQuery += "	,CT2_DATA "+ENTER
	cQuery += "	,CT1_CONTA "+ENTER
	cQuery += "	,CTR_DESC "+ENTER
	cQuery += "	,CT2_CCUSTO "+ENTER

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea())
	Endif

	TcQuery cQuery New Alias (cTemp)

	TcSetField(cTemp,"CT2_DATA","D")

	If !(cTemp)->( EOF() )

		cMsg := 	 Padr("Data"		,10						)
		cMsg += +"|"+Padr("Hora"		,8						)
		cMsg +=	+"|"+Padr("Data Lcto"	,10						)
		cMsg += +"|"+Padr("Conta"		,TamSx3("CT1_CONTA"	)[1])
		cMsg += +"|"+Padr("Descri Conta",TamSx3("CT1_DESC01")[1])
		cMsg += +"|"+     "Tp MOD"
		cMsg += +"|"+Padr("Centro Custo",TamSx3("CTT_CUSTO"	)[1])
		cMsg += +"|"+Padr("Desc CCusto" ,TamSx3("CTT_DESC01")[1])
		cMsg += +"|"+Padr("Valor"		,TamSx3("CT2_VALOR"	)[1]+4)
		cMsg += +"|"+Padr("Historico"	,TamSx3("CT2_HIST"	)[1])
		cMsg += +"|"+Padr("Lote"		,TamSx3("CT2_LOTE"	)[1])
		cMsg += +"|"+Padr("Sub-Lote"	,TamSx3("CT2_SBLOTE")[1])
		cMsg += +"|"+Padr("Documento"	,TamSx3("CT2_DOC"	)[1])
		cMsg += +"|"+Padr("Linha"		,TamSx3("CT2_LINHA"	)[1])

		cRet +=	     Padr("Data Lcto"	,10						)
		cRet += +"|"+Padr("Conta"		,TamSx3("CT1_CONTA"	)[1])
		cRet += +"|"+Padr("Descri Conta",TamSx3("CT1_DESC01")[1])
		cRet += +"|"+     "Tp MOD"
		cRet += +"|"+Padr("Centro Custo",TamSx3("CTT_CUSTO"	)[1])
		cRet += +"|"+Padr("Desc CCusto" ,TamSx3("CTT_DESC01")[1])
		cRet += +"|"+Padr("Valor"		,TamSx3("CT2_VALOR"	)[1]+4)
		cRet += +"|"+Padr("Historico"	,TamSx3("CT2_HIST"	)[1])
		cRet += +"|"+Padr("Lote"		,TamSx3("CT2_LOTE"	)[1])
		cRet += +"|"+Padr("Sub-Lote"	,TamSx3("CT2_SBLOTE")[1])
		cRet += +"|"+Padr("Documento"	,TamSx3("CT2_DOC"	)[1])
		cRet += +"|"+Padr("Linha"		,TamSx3("CT2_LINHA"	)[1])

		WriteLog(ENTER+cMsg)
		While !(cTemp)->( EOF() )
			cMsg :=		 Padr(DtoC( (cTemp)->CT2_DATA  ),10)
			cMsg += +"|"+ (cTemp)->CT1_CONTA
			cMsg += +"|"+ (cTemp)->CT1_DESC01
			cMsg += +"|"+ Padr((cTemp)->CTR_DESC,6)
			cMsg += +"|"+ (cTemp)->CT2_CCUSTO
			cMsg += +"|"+ (cTemp)->CTT_DESC01
			cMsg += +"|"+ Transform( (cTemp)->CT2_VALOR, PesqPict("CT2","CT2_VALOR") )
			cMsg += +"|"+ (cTemp)->CT2_HIST
			cMsg += +"|"+ (cTemp)->CT2_LOTE
			cMsg += +"|"+ (cTemp)->CT2_SBLOTE
			cMsg += +"|"+ (cTemp)->CT2_DOC
			cMsg += +"|"+ (cTemp)->CT2_LINHA

			WriteLog(cMsg)
			cRet += ENTER+cMsg
			(cTemp)->( DbSkip() )
		Enddo
	Endif

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea())
	Endif

Return cRet

