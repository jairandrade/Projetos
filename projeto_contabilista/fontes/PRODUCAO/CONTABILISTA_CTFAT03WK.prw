#include 'totvs.ch'
#include "tbiconn.ch"

/*/{Protheus.doc} User Function CTFAT03WK
    Função para executar Job para verificar Status NFe transmitida
    @type  Function
    @author Willian Kaneta
    @since 07/09/2020
    @version 1.0
    /*/
User Function CTFAT03WK()

	Local _cEmpresa := "01" // Código da Empresa que deseja incluir a carga
    Local _cFilial  := "010101" // Código da Filial que deseja incluir a carga

	PREPARE ENVIRONMENT EMPRESA _cEmpresa FILIAL _cFilial MODULO "FAT"
    
	STNFSeMnt()  

	RESET ENVIRONMENT  
Return Nil

/*/{Protheus.doc} User Function STNFSeMnt
    Monitora Status NFe transmitida
    @type  Function
    @author Willian Kaneta
    @since 07/09/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function STNFSeMnt()
	Local cURL     	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cFilCD	:= SUPERGETMV("CT_ESTCENT",.F.,"010101")
	Local aParam	:= {}
	Local cAviso	:= ""
	Local nTpMonitor:= 1
	Local cAliasSF2 := GetNextAlias()
	Local _cFilCIC  := cFilAnt

	Private lCte		:= .F.
	Private lAutomato 	:= .F.
	Private cModelo 	:="55"
	Private cIdEnt 		:= RetIdEnti(.F.)
	Private oXml

	BeginSql Alias cAliasSF2
        SELECT  SF2.R_E_C_N_O_ AS RECNO
		FROM %TABLE:SF2% SF2

		INNER JOIN %TABLE:SC5% SC5
			ON SC5.C5_FILIAL = %EXP:cFilCD%
			AND SC5.C5_NOTA = SF2.F2_DOC
			AND SC5.C5_SERIE = SF2.F2_SERIE
			AND SC5.C5_XESTOQU = '2'
			AND SC5.%NOTDEL% 

		WHERE SF2.F2_FILIAL     = %EXP:cFilCD%
            AND SF2.F2_ESPECIE  = 'SPED'
            AND SF2.F2_XFLAGJV  = ''
            AND SF2.F2_CHVNFE   <> ''
            AND SF2.%NOTDEL% 
    EndSql

	//MemoWrite("C:\Temp\GAP61_cAliasSF2.txt",getlastquery()[2])

	While !(cAliasSF2)->(EOF())
		If !Empty(cIdEnt)
			DbSelectArea("SF2")
			SF2->(DbGoTo((cAliasSF2)->RECNO))
			aParam := {}
			aAdd(aParam,SF2->F2_SERIE)
			aAdd(aParam,SF2->F2_DOC)
			aAdd(aParam,SF2->F2_DOC)

			aRetorno := procMonitorDoc(cIdEnt, cUrl, aParam, nTpMonitor, cModelo, lCte, @cAviso)

			SF2->(DbGoTo((cAliasSF2)->RECNO))
			//If aRetorno[1][5] == "100"//comentado para Valdecir testar
				//Entrada Documento de entrada filial Joinville
				_cFilCIC := cFilAnt
				ENTRADAJV(SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CHVNFE)
				cFilAnt := _cFilCIC
				POSICIONE("SM0",1,cEmpAnt+cFilAnt,"M0_CGC")
			//EndIf//comentado para Valdecir testar
		Endif
		(cAliasSF2)->(DbSkip())
	EndDo
Return Nil

/*/{Protheus.doc} ENTRADAJV
	Efetuta Entrada documento de entrada filial Joinville
	@type  Static Function
	@author Willian Kaneta
	@since 07/09/2020
	@version 1.0
	@return Nil
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function ENTRADAJV(cFilSF2,cDocumento,cSerie,cChveNFe)
	Local aCab 		:= {}
	Local aItem 	:= {}
	Local aItens 	:= {}
	Local nOpc 		:= 3 
	Local nX 		:= 1
	Local cAliasSC5 := GetNextAlias()
	Local cTpOperCD	:= SUPERGETMV("CT_TPOPTRE",.F.,"")
	Local _cTESInt  := ""

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	
	DbSelectArea("SA2")
	SA2->(DbSetOrder(3))

	If MsSeek(xFilial("SA2")+SM0->M0_CGC)

		//Cabeçalho
		aadd(aCab,{"F1_TIPO" 	,"N" 		,NIL})
		aadd(aCab,{"F1_FORMUL" 	,"N" 		,NIL})
		aadd(aCab,{"F1_DOC" 	,cDocumento ,NIL})
		aadd(aCab,{"F1_SERIE" 	,cSerie 	,NIL})
		aadd(aCab,{"F1_EMISSAO" ,DDATABASE 	,NIL})
		aadd(aCab,{"F1_DTDIGIT" ,DDATABASE 	,NIL})
		aadd(aCab,{"F1_FORNECE" ,SA2->A2_COD,NIL})
		aadd(aCab,{"F1_LOJA" 	,SA2->A2_LOJA,NIL})
		aadd(aCab,{"F1_ESPECIE" ,"NFE"		,NIL})
		//aadd(aCab,{"F1_ESPECIE" ,"SPED"		,NIL})//comentado para Valdecir testar.deixado acima
		aadd(aCab,{"F1_COND" 	,"001" 		,NIL})
		aadd(aCab,{"F1_DESPESA" , 0 		,NIL})
		aadd(aCab,{"F1_DESCONT" , 0 		,Nil})
		aadd(aCab,{"F1_SEGURO" 	, 0 		,Nil})
		aadd(aCab,{"F1_FRETE" 	, 0 		,Nil})
		aadd(aCab,{"F1_MOEDA" 	, 1 		,Nil})
		aadd(aCab,{"F1_TXMOEDA" , 1 		,Nil})
		aadd(aCab,{"F1_CHVNFE"  , cChveNFe	,Nil})

		//Itens
		DbSelectArea("SD2")
		SD2->(DbSetOrder(3))

		If SD2->(MsSeek(cFilSF2+cDocumento+cSerie))
			While SD2->(!EOF()) .AND. SD2->(D2_FILIAL+D2_DOC+D2_SERIE) == cFilSF2+cDocumento+cSerie
				aItem := {}
				_cTESInt := MaTesInt(1, cTpOperCD, SA2->A2_COD , SA2->A2_LOJA, "F", SD2->D2_COD)
				aadd(aItem,{"D1_ITEM" 	,StrZero(nX,4) 								,NIL})
				aadd(aItem,{"D1_COD" 	,PadR(SD2->D2_COD,TamSx3("D1_COD")[1]) 		,NIL})
				aadd(aItem,{"D1_UM" 	,SD2->D2_UM 								,NIL})
				aadd(aItem,{"D1_LOCAL" 	,ALLTRIM(SUPERGETMV("CT_LOCRDL",.F.,"50")) 	,NIL})
				aadd(aItem,{"D1_QUANT"  ,SD2->D2_QUANT 							    ,NIL}) 
				aadd(aItem,{"D1_VUNIT" 	,SD2->D2_PRCVEN 						    ,NIL}) 
				aadd(aItem,{"D1_TOTAL" 	,SD2->D2_TOTAL 							    ,NIL})
				aadd(aItem,{"D1_OPER" 	,cTpOperCD								    ,NIL})
				aadd(aItem,{"D1_TES" 	,_cTESInt								    ,NIL})
				aAdd(aItens,aItem)
				nX++
				SD2->(DbSkip())
			EndDo
		EndIf
		cFilAnt := "010104"
		//3-Inclusão / 4-Classificação / 5-Exclusão
		MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItens,nOpc)

		If !lMsErroAuto
			DbSelectArea("SF2")
			SF2->(DbSetOrder(1))

			If SF2->(MsSeek(cFilSF2+cDocumento+cSerie))
				If RecLock("SF2",.F.)
					SF2->F2_XFLAGJV := "S"
					SF2->(MsUnlock())
				EndIf

				//Busca Pedido para realizar a liberação filial JV
				BeginSql Alias cAliasSC5
					SELECT  SC5A.R_E_C_N_O_ AS RECNO
					FROM %TABLE:SC5% SC5A

					INNER JOIN %TABLE:SC5% SC5B
						ON SC5B.C5_NOTA	 	= %EXP:cDocumento%
						AND SC5B.C5_SERIE 	= %EXP:cSerie%
						AND SC5B.C5_FILIAL 	= %EXP:cFilSF2%
						AND SC5B.%NOTDEL% 

					INNER JOIN %TABLE:SUA% SUA
						ON SUA.UA_FILIAL 	= '010104'
						AND SUA.UA_NUM 		= SC5B.C5_XNUMSUA
						AND SUA.%NOTDEL%

					WHERE SC5A.C5_FILIAL = '010104'
						AND SC5A.C5_NUM = SUA.UA_NUMSC5
						AND SC5A.%NOTDEL% 
				EndSql

				//MemoWrite("C:\Temp\GAP61_SC5_JV.txt",getlastquery()[2])

				If !(cAliasSC5)->(EOF())
					//Gera Documento Saída
					GERDOCSAIDA((cAliasSC5)->RECNO)
				EndIf

			(cAliasSC5)->(DBCloseArea())
			EndIf
		Else
			cError := MostraErro("/dirdoc", "error.log")
		EndIf

	EndIf
Return Nil

/*/{Protheus.doc} GERDOCSAIDA
	Função Gera documento de saída
	@type  Static Function
	@author Willian Kaneta
	@since 09/09/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function GERDOCSAIDA(nRecnoSC5)
	Local aPvlNfs	:= {}
	Local cSerie	:= ALLTRIM(SUPERGETMV("CT_OPERSER",.T.,"3"))

	DbSelectArea("SC5")
	SC5->(DbGoTo(nRecnoSC5))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Selecionando Itens para Faturamento ... ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SB1->(dbSetOrder(1))
	SC6->(dbSetOrder(1))
	SB5->(dbSetOrder(1))
	SB2->(dbSetOrder(1))
	SF4->(dbSetOrder(1))
	SE4->(dbSetOrder(1))
	SC9->(dbSetOrder(1))
	SC9->(dbSeek(xFilial("SC9") + SC5->C5_NUM + "01"))
	While !SC9->(Eof()) .and. xFilial("SC9") == SC9->C9_FILIAL .and. SC9->C9_PEDIDO == SC5->C5_NUM
		If SC9->(RecLock("SC9",.F.))
			SC9->C9_BLEST := ""
			SC9->C9_BLCRED:= ""
			SC9->(MsUnlock())
		EndIf
		If Empty(SC9->C9_BLCRED) .and. Empty(SC9->C9_BLEST)
			SC6->(dbSeek( xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM ))
			SB1->(dbSeek( xFilial("SB1") + SC9->C9_PRODUTO ))
			SB2->(dbSeek( xFilial("SB2") + SB1->B1_COD ))
			SB5->(dbSeek( xFilial("SB5") + SB1->B1_COD ))
			SF4->(MsSeek( xFilial("SF4") + SC6->C6_TES ))
			SE4->(MsSeek( xFilial("SE4") + SC5->C5_CONDPAG ))
			aAdd(aPvlNfs,{SC9->C9_PEDIDO,;
							SC9->C9_ITEM,;
							SC9->C9_SEQUEN,;
							SC9->C9_QTDLIB,;
							SC9->C9_PRCVEN,;
							SC9->C9_PRODUTO,;
							SF4->F4_ISS=="S",;
							SC9->(RecNo()),;
							SC5->(RecNo()),;
							SC6->(RecNo()),;
							SE4->(RecNo()),;
							SB1->(RecNo()),;
							SB2->(RecNo()),;
							SF4->(RecNo())})
		Else
			DisarmTransaction()
			RollbackSx8()
			MsUnlockAll()
			MaFisEnd()
			Return(.f.)
		EndIf
		SC9->(dbSkip())
	Enddo

	If len(aPvlNfs) == 0 .and. !FGX_SC5BLQ(SC5->C5_NUM,.f.) // Verifica SC5 bloqueado
		DisarmTransaction()
		RollbackSx8()
		MsUnlockAll()
		MaFisEnd()
		MaFisRestore()
		Return(.f.)
	EndIf

	ConfirmSx8()
	nRecSA1 := SA1->(Recno())

	PERGUNTE("MT460A",.f.)
	conout("Filial executando geracao_nf_saida_jv "+cFilAnt)
	cNota := MaPvlNfs(aPvlNfs,;           // 01
					cSerie,;            // 02
					(mv_par01 == 1),;   // 03
					(mv_par02 == 1),;   // 04
					(mv_par03 == 1),;   // 05
					(mv_par04 == 1),;   // 06
					.F.,;               // 07
					0,;                 // 08
					0,;                 // 09
					.T.,;               // 10
					.F.,;               // 11
					,;				  // 12
					,;	// 13
					,;				  // 14
					,;				  // 15
					,)				  // 16

	If lMsErroauto
		DisarmTransaction()
		RollbackSx8()
		MsUnlockAll()
		MaFisEnd()
		MaFisRestore()
		MostraErro()
		Return(.f.)
	EndIf
	ConfirmSx8()
Return Nil
