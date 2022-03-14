#include "Protheus.ch"
#Include "TopConn.ch"

//----------------------------------------------------------------------------
/*/{Protheus.doc} OMS106F
Gera as Nf´s
@type function
@version 
@author Jair Andrade
@since 05/01/2021
@return return_type, return_description
/*/

User Function OMS106F()
	Private _cNotaGer := ""
	Private cMsgErro  := ""
	Private cCodZA7    := ZA7->ZA7_CODIGO

	If ZA7->ZA7_STATUS <>'4'
		HELP(' ',1,'Atenção!',,"A geração de Nf´s só é permitida para cargas com status  = 4(Aguardando faturamento).",1,0, NIL, NIL, NIL, NIL, NIL, {""})
		Return
	EndIf

	Processa({ || GeraNF() },"Aguarde!","Gerando N.Fiscal ")

Return()

//Grava erro no log.
User Function BSGrvErro(cArq, cPatch, cMsg)

	Local cArquivo := cPatch + cArq
	Local _nHa
	Local nBytesSalvo  := 0
	Local cTexto       := ""

//Cria diretórios da DIRECT no servidor 
	U_BSCriaDir(cPatch)

	If File(cArquivo)
		FErase(cArquivo)
	EndIf

	_nHa := FCREATE(cArquivo)

	If _nHa == -1
		MsgStop('Erro ao criar destino. Ferror = '+str(ferror(),4),'Erro')
		FCLOSE(_nHa)	// Fecha o arquivo de Origem
		Return()
	Endif

	cTexto := cMsg
	nBytes := Len(cTexto)
	nBytesSalvo := FWRITE(_nHa, cTexto, nBytes)

	FT_FUSE()
	FClose(_nHa)

Return()


//----------------------------------------------------------------------------
/*/{Protheus.doc} OMS106c
Cria diretorios necessarios para a integração
@type function
@version 
@author Jair Andrade
@since 05/01/2021
@return return_type, return_description
/*/

User Function BSCriaDir(cPatch)
	Local cDir := SubStr(cPatch , 1, Len(cPatch) -1 )
	Local aDir := Separa(cDir , "\" , .F.)
	Local i    := 0
	Local cBarra := "\"
	Local cDirGer := ""

	For i := 1 To Len(aDir)
		cDirGer += cBarra + aDir[i] + "\"
		cBarra := ""
		MakeDir(cDirGer)
	Next i

Return()
//----------------------------------------------------------------------------
/*/{Protheus.doc} GeraNF
Gera Nf´s
@type function
@version 
@author Jair Andrade
@since 05/01/2021
@return return_type, return_description
/*/
Static Function GeraNF()
	Local lContinua := .T.
	Local cSerie	:= Alltrim(SUPERGETMV('MV_XSERIE', .F., '80'))
	Local cNFSaida 	:= ""
	Local cNfs := ""
	Local cTranspZA7:= ""
	Local cCpfZa7 := ""
	Local cCodPedido := ""
	Local aPvlNfs   := {}
	Private cNumRom := GetSXENum("GWN", "GWN_NRROM")

	//Obtem os pedidos da tabela ZA7 posicionada
	cQuery := " SELECT C5_CONDPAG, C5_TRANSP, C5_CLIENTE,C5_LOJACLI, ZA7_PEDIDO, ZA7_ITEMPD, "
	cQuery += " ZA7_TRANSP, ZA7_CPF ,ZA7_ITEM "
	cQuery += " FROM " + RetSqlName("SC5") + " SC5 (NOLOCK) "
	cQuery += " JOIN " + RetSqlName("ZA7") + " ZA7 ON ZA7_FILIAL = C5_FILIAL "
	cQuery += " AND ZA7_PEDIDO = C5_NUM "
	cQuery += " AND ZA7_CODIGO = '" + cCodZA7 + "' "
	cQuery += " AND ZA7.D_E_L_E_T_ = '' "
	cQuery += " WHERE "
	cQuery += " SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND "
	cQuery += " SC5.D_E_L_E_T_ = '' "
	cQuery += " AND C5_NOTA = '' AND C5_LIBEROK = 'S' "
	cQuery += " ORDER BY ZA7_PEDIDO,C5_CLIENTE,C5_LOJACLI "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida se arquivo temporario está em uso.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("TMPSC5") > 0
		TMPSC5->( dbCloseArea() )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa Query³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPSC5",.T.,.T.)

	DbSelectArea("TMPSC5")
	TMPSC5->(DbGotop())
	If !TMPSC5->(Eof())
		cCodPedido := TMPSC5->ZA7_PEDIDO
		_cNotaGer := Alltrim(Posicione("SX5",1,cFilAnt+"01"+cSerie,"X5_DESCRI"))
		cTranspZA7:= ZA7->ZA7_TRANSP
		cCpfZa7:= ZA7->ZA7_CPF
		While !TMPSC5->(Eof())
			If cCodPedido != TMPSC5->ZA7_PEDIDO
				Begin Transaction
					//Gera documento de saida
					Pergunte("MT460A",.F.)
					cNFSaida := MaPvlNfs(aPvlNfs, cSerie, .F. , .F. , .F. , .F. , .F., 0, 0, .F., .F.)

					If cNFSaida <> _cNotaGer .or. Empty(cNFSaida)
						DisarmTransaction()
						If Empty(cNFSaida)
							cMsgErro += "Não foi possível gerar a Nota fiscal numero " + _cNotaGer + CHR(10) + CHR(13)
						EndIf

						If cNFSaida <> _cNotaGer
							cMsgErro += "Nota fiscal numero " + _cNotaGer  + " gerada com numeração cNFSaida , processo não realizado." + CHR(10) + CHR(13)
						EndIf
						lContinua := .F.
					Else
						If Empty(cNFs)
							cNFs := cNFSaida
						Else
							cNFs +=" ; "+cNFSaida
						EndIf
						DbSelectArea("ZA7")
						ZA7->(DbGotop())
						ZA7->(DbSetOrder(1))
						If ZA7->(DbSeek( xFilial("ZA7") + cCodZA7 ))
							While ZA7->(!Eof()) .AND. ZA7->ZA7_CODIGO == cCodZA7
								If ZA7->ZA7_PEDIDO=cCodPedido
									ZA7->(RecLock("ZA7" , .F.))
									ZA7->ZA7_STATUS := "6"
									ZA7->ZA7_DTFAT := DATE()
									ZA7->ZA7_HRFAT := TIME()
									ZA7->ZA7_DOC := _cNotaGer
									ZA7->(MsUnLock())
								EndIf
								ZA7->(DbSkip())
							Enddo
						EndIf
					EndIf
				End Transaction
				//inclui o registro posicionado nas tabelas e continua o processo
				cCodPedido := TMPSC5->ZA7_PEDIDO
				aPvlNfs := {}
				_cNotaGer := Alltrim(Posicione("SX5",1,cFilAnt+"01"+cSerie,"X5_DESCRI"))
			EndIf
			If !lContinua
				Exit
			EndIf
			DbSelectArea("SC9")
			SC9->(DbSetOrder(1))
			DbSelectArea("SC6")
			SC6->(DbSetOrder(1))
			DbSelectArea("SE4")
			SE4->(DbSetOrder(1))
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			DbSelectArea("SB2")
			SB2->(DbSetOrder(1))
			

			If SC9->(DbSeek(xFilial("SC9")+TMPSC5->ZA7_PEDIDO+TMPSC5->ZA7_ITEMPD))
				While SC9->(!Eof()) .AND. SC9->C9_PEDIDO == TMPSC5->ZA7_PEDIDO .AND. SC9->C9_ITEM == TMPSC5->ZA7_ITEMPD
					SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO))
					SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
					SB1->(DbSeek(xFilial("SB1")+SC9->C9_PRODUTO))
					SB2->(DbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL))
					SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES))

					aAdd(aPvlNfs,{;
						SC9->C9_PEDIDO,;
						SC9->C9_ITEM,;
						SC9->C9_SEQUEN,;
						SC9->C9_QTDLIB,;
						SC9->C9_PRCVEN,;
						SC9->C9_PRODUTO,;
						.F.,;
						SC9->(RECNO()),;
						SC5->(RECNO()),;
						SC6->(RECNO()),;
						SE4->(RECNO()),;
						SB1->(RECNO()),;
						SB2->(RECNO()),;
						SF4->(RECNO());
						})
					SC9->(DbSkip())
				EndDo
			EndIf

			TMPSC5->(DbSkip())
		EndDo
		If lContinua
			//grava ultimo pedido
			Begin Transaction
				//Gera documento de saida
				Pergunte("MT460A",.F.)
				cNFSaida := MaPvlNfs(aPvlNfs, cSerie, .F. , .F. , .F. , .F. , .F., 0, 0, .F., .F.)

				If cNFSaida <> _cNotaGer .or. Empty(cNFSaida)
					DisarmTransaction()
					If Empty(cNFSaida)
						cMsgErro += "Não foi possível gerar a Nota fiscal numero " + _cNotaGer + CHR(10) + CHR(13)
					EndIf

					If cNFSaida <> _cNotaGer
						cMsgErro += "Nota fiscal numero " + _cNotaGer  + " gerada com numeração cNFSaida , processo não realizado." + CHR(10) + CHR(13)
					EndIf
				Else
					If Empty(cNFs)
						cNFs := cNFSaida
					Else
						cNFs +=" ; "+cNFSaida
					EndIf
					DbSelectArea("ZA7")
					ZA7->(DbGotop())
					ZA7->(DbSetOrder(1))
					If ZA7->(DbSeek( xFilial("ZA7") + cCodZA7))
						While ZA7->(!Eof()) .AND. ZA7->ZA7_CODIGO == cCodZA7
							If ZA7->ZA7_PEDIDO=cCodPedido
								ZA7->(RecLock("ZA7" , .F.))
								ZA7->ZA7_STATUS := "6"
								ZA7->ZA7_DTFAT := DATE()
								ZA7->ZA7_HRFAT := TIME()
								ZA7->ZA7_DOC := _cNotaGer
								ZA7->(MsUnLock())
							EndIf
							ZA7->(DbSkip())
						Enddo
					EndIf
				EndIf
			End Transaction
		EndIf
		If Empty(cMsgErro) .and. lContinua//so grava as nf´s se nao ocorrer erro
			cMsgErro := "Nf(s) "+cNFs+" gerada(s) com sucesso."
		EndIf
		//Grava na tabela de log os dados
		dbSelectArea("ZA6")
		ZA6->(dbSetOrder(1))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
		If ZA6->(dbSeek(xFilial("ZA6")+cCodZA7))
			RecLock("ZA6",.F.)
			ZA6_MSG := ZA6_MSG+cMsgErro+CHR(13)+CHR(10)
			ZA6->(MsUnlock())
		EndIf
		/*if lContinua
			//Gera Romaneio
			cMsgErro := U_GeraRoma(cTranspZA7,cCpfZa7,cNFs)

			//Grava na tabela de log os dados
			dbSelectArea("ZA6")
			ZA6->(dbSetOrder(1))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
			If ZA6->(dbSeek(xFilial("ZA6")+cCodZA7))
				RecLock("ZA6",.F.)
				ZA6_MSG := ZA6_MSG+cMsgErro+CHR(13)+CHR(10)
				ZA6->(MsUnlock())
			EndIf

		EndIf */
		If Select("TMPSC5") > 0
			TMPSC5->( dbCloseArea() )
		EndIf
		Aviso("Atenção" , "Nf(s) "+cNFs+" gerada(s) com sucesso.")
	EndIf

Return()
//----------------------------------------------------------------------------
/*/{Protheus.doc} OMS106A
Gera as Nf´s automaticamente
@type function
@version 
@author Jair Andrade
@since 05/01/2021
@return return_type, return_description
/*/
User Function OMS106A()
	Local aSays :={}
	Local aButtons:={}
	Local nOpca := 0
	Local cPerg       := padr("OMS106A",10)
	Local cQuery := ""
	Local cAliasZA7 := GetNextAlias()        // da um nome pro arquivo temporario
	Private cDeCliente
	Private cAteCliente
	Private cDeLoja
	Private cAteLoja
	Private cDePedido
	Private cAtePedido
	Private _aNotasA := {}

	AjustaSX1(cPerg)

	Pergunte(cPerg , .F.)

	cDeCliente   := MV_PAR01
	cAteCliente  := MV_PAR02
	cDeLoja      := MV_PAR03
	cAteLoja     := MV_PAR04
	cDePedido    := MV_PAR05
	cAtePedido   := MV_PAR06
	// Inicializa o log de processamento
	//ProcLogIni( aButtons )
	AADD(aSays, 'Este programa tem como objetivo gerar Nf´s a partir da EDI das transportadoras.')
	AADD(aSays, 'Este processo será automatico e não devera ter interferencias manuais')
	AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
	AADD(aButtons, { 1,.T.,{|| nOpca:= 1, FechaBatch() }} )
	AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
	FormBatch( 'Geração de Nf´s', aSays, aButtons,, 220, 560 )
	If nOpca == 1
		MsAguarde()
		//Verifica as cargas que estão pendentes de faturamento
		cQuery := " SELECT DISTINCT ZA7_CODIGO  "
		cQuery += " FROM " + RetSqlName("SC5") + " SC5 (NOLOCK) "
		cQuery += " JOIN " + RetSqlName("ZA7") + " ZA7 ON ZA7_FILIAL = C5_FILIAL "
		cQuery += " AND ZA7_PEDIDO = C5_NUM "
		cQuery += " AND ZA7_STATUS = '4' "
		cQuery += " AND ZA7.D_E_L_E_T_ = '' "
		cQuery += " WHERE "
		cQuery += " SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
		cQuery += " AND C5_CLIENTE >= '" + cDeCliente  + "' AND C5_CLIENTE <= '" + cAteCliente + "' "
		cQuery += " AND C5_LOJACLI >= '" + cDeLoja  + "' AND C5_LOJACLI <= '" + cAteLoja + "' "
		cQuery += " AND C5_NUM >= '" + cDePedido  + "' AND C5_NUM <= '" + cAtePedido + "' "
		cQuery += " AND SC5.D_E_L_E_T_ = '' "
		cQuery += " AND C5_NOTA = '' AND C5_LIBEROK = 'S' "

		TCQUERY cQuery NEW ALIAS &cAliasZA7
		If !Empty(Alltrim((cAliasZA7)->ZA7_CODIGO))
			While !(cAliasZA7)->(Eof())
				AADD(_aNotasA , Alltrim((cAliasZA7)->ZA7_CODIGO))
				(cAliasZA7)->(dbSKip())
			Enddo
			Processa({ || GerAutNF(_aNotasA) },"Aguarde!","Gerando Doc. de Saída")
		EndIf
		(cAliasZA7)->(dbCloseArea())
	endIf
Return
//----------------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Gera pergunta na SX1
@type function
@version 
@author Jair Andrade
@since 05/01/2021
@return return_type, return_description
/*/
Static Function AjustaSX1(cPerg)
	Local aHelpPor01 := {"Informe o Cliente inicial a ser   ",    "considerado na selecao."}
	Local aHelpEng01 := {"",""}
	Local aHelpSpa01 := {"",""}
	Local aHelpPor02 := {"Informe o Cliente final  a ser    ",    "considerado na selecao."}
	Local aHelpEng02 := {"",""}
	Local aHelpSpa02 := {"",""}
	Local aHelpPor03 := {"Informe a Loja inicial do Cliente a ser",    "considerado na selecao."}
	Local aHelpEng03 := {"",""}
	Local aHelpSpa03 := {"",""}
	Local aHelpPor04 := {"Informe a Loja final do Cliente a ser",    "considerado na selecao."}
	Local aHelpEng04 := {"",""}
	Local aHelpSpa04 := {"",""}
	Local aHelpPor05 := {"Informe o pedido inicial a ser",    "considerado na selecao."}
	Local aHelpEng05 := {"",""}
	Local aHelpSpa05 := {"",""}
	Local aHelpPor06 := {"Informe o pedido final a ser",    "considerado na selecao."}
	Local aHelpEng06 := {"",""}
	Local aHelpSpa06 := {"",""}

	CheckSX1(cPerg,"01","Cliente  De ? " , "Cliente  De ? " , "Cliente  De ? " ,"mv_ch1","C", 6 ,0,0,"G","","SA1","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor01,aHelpEng01,aHelpSpa01)
	CheckSX1(cPerg,"02","Cliente Ate ? " , "Cliente Ate ? " , "Cliente Ate ? " ,"mv_ch2","C", 6 ,0,0,"G","","SA1","","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor02,aHelpEng02,aHelpSpa02)
	CheckSX1(cPerg,"03","Loja De ?     " , "Loja De ?     " , "Loja De ?     " ,"mv_ch3","C", 2 ,0,0,"G","","   ","","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor03,aHelpEng03,aHelpSpa03)
	CheckSX1(cPerg,"04","Loja Ate ?    " , "Loja Ate ?    " , "Loja Ate ?    " ,"mv_ch4","C", 2 ,0,0,"G","","   ","","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor04,aHelpEng04,aHelpSpa04)
	CheckSX1(cPerg,"05","Pedido De?    " , "Pedido de?    " , "Pedido De?    " ,"mv_ch5","C", 6 ,0,0,"G","","SC5","","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor05,aHelpEng05,aHelpSpa05)
	CheckSX1(cPerg,"06","Pedido Ate?   " , "Pedido Ate?   " , "Pedido Ate?   " ,"mv_ch6","C", 6 ,0,0,"G","","SC5","","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",aHelpPor06,aHelpEng06,aHelpSpa06)
Return()
//----------------------------------------------------------------------------
/*/{Protheus.doc} GerAutNF(_aNotasA)
Gera Nf´s
@type function
@version 
@author Jair Andrade
@since 05/01/2021
@return return_type, return_description
/*/
Static Function GerAutNF(_aNotasA)
	Local lContinua := .T.
	Local i         := 0
	Local cSerie	:= Alltrim(SUPERGETMV('MV_XSERIE', .F., '80'))
	Local cNFSaida 	:= ""
	Local cNfs 		:= ""
	Local _cNotaGer := ""
	Local cMsgErro 	:= ""
	Local cNfsGeral:= ""
	Local cCodZA7 := ""
	Local aPvlNfs   := {}
	Private cNumRom := ""

	ProcRegua(Len(_aNotasA))

	For i := 1 to Len(_aNotasA)
		IncProc("Criando N.Fiscal para a carga " + _aNotasA[i])
		lContinua := .T.
		cNumRom   := GetSXENum("GWN", "GWN_NRROM")
		cNfs 	  := ""
		cCodZA7 := _aNotasA[i]
			//Obtem os pedidos da tabela ZA7 posicionada
			cQuery := " SELECT C5_CONDPAG, C5_TRANSP, C5_CLIENTE,C5_LOJACLI, ZA7_PEDIDO, ZA7_ITEMPD, "
			cQuery += " ZA7_TRANSP, ZA7_CPF ,ZA7_ITEM "
			cQuery += " FROM " + RetSqlName("SC5") + " SC5 (NOLOCK) "
			cQuery += " JOIN " + RetSqlName("ZA7") + " ZA7 ON ZA7_FILIAL = C5_FILIAL "
			cQuery += " AND ZA7_PEDIDO = C5_NUM "
			cQuery += " AND ZA7_CODIGO = '" + _aNotasA[i] + "' "
			cQuery += " AND ZA7.D_E_L_E_T_ = '' "
			cQuery += " WHERE "
			cQuery += " SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND "
			cQuery += " SC5.D_E_L_E_T_ = '' "
			cQuery += " AND C5_NOTA = '' AND C5_LIBEROK = 'S' "
			cQuery += " ORDER BY ZA7_PEDIDO,C5_CLIENTE,C5_LOJACLI "

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se arquivo temporario está em uso.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Select("TMPSC5") > 0
				TMPSC5->( dbCloseArea() )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa Query³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPSC5",.T.,.T.)

			DbSelectArea("TMPSC5")
			TMPSC5->(DbGotop())
			If !TMPSC5->(Eof())
				cCodPedido := TMPSC5->ZA7_PEDIDO
				_cNotaGer := Alltrim(Posicione("SX5",1,cFilAnt+"01"+cSerie,"X5_DESCRI"))
				aPvlNfs := {}
				//Verifica se a nota já existe, caso sim aborta o processo para a nota
				DbSelectArea("SF2")
				SF2->(DbSetOrder(1))
				SF2->(DbGotop())
				If SF2->(DbSeek( xFilial("SF2") + aVKey(_cNotaGer, "F2_DOC") + aVKey(cSerie, "F2_SERIE") ))
					cMsgErro += "Não foi possível gerar a Nota fiscal numero " + _cNotaGer + ", esta nota fiscal já existe no sistema."+ CHR(10) + CHR(13)
					lContinua := .F.
				EndIf
				If lContinua
					cTranspZA7:= ZA7->ZA7_TRANSP
					cCpfZa7:= ZA7->ZA7_CPF
					While !TMPSC5->(Eof())
						If cCodPedido != TMPSC5->ZA7_PEDIDO
							Begin Transaction
								//Gera documento de saida
								Pergunte("MT460A",.F.)
								cNFSaida := MaPvlNfs(aPvlNfs, cSerie, .F. , .F. , .F. , .F. , .F., 0, 0, .F., .F.)

								If cNFSaida <> _cNotaGer .or. Empty(cNFSaida)
									DisarmTransaction()
									If Empty(cNFSaida)
										cMsgErro += "Não foi possível gerar a Nota fiscal numero " + _cNotaGer + CHR(10) + CHR(13)
									EndIf

									If cNFSaida <> _cNotaGer
										cMsgErro += "Nota fiscal numero " + _cNotaGer  + " gerada com numeração cNFSaida , processo não realizado." + CHR(10) + CHR(13)
									EndIf
									lContinua := .F.
								Else
									If Empty(cNFs)
										cNFs := cNFSaida
									Else
										cNFs +=" ; "+cNFSaida
									EndIf
									DbSelectArea("ZA7")
									ZA7->(DbGotop())
									ZA7->(DbSetOrder(1))
									If ZA7->(DbSeek( xFilial("ZA7") + cCodZA7 ))
										While ZA7->(!Eof()) .AND. ZA7->ZA7_CODIGO == cCodZA7
											If ZA7->ZA7_PEDIDO=cCodPedido
												ZA7->(RecLock("ZA7" , .F.))
												ZA7->ZA7_STATUS := "6"
												ZA7->ZA7_DTFAT := DATE()
												ZA7->ZA7_HRFAT := TIME()
												ZA7->ZA7_DOC := _cNotaGer
												ZA7->(MsUnLock())
											EndIf
											ZA7->(DbSkip())
										Enddo
									EndIf
								EndIf
							End Transaction
							//inclui o registro posicionado nas tabelas e continua o processo
							cCodPedido := TMPSC5->ZA7_PEDIDO
							aPvlNfs := {}
							_cNotaGer := Alltrim(Posicione("SX5",1,cFilAnt+"01"+"80    ","X5_DESCRI"))
						EndIf
						If !lContinua
							Exit
						EndIf
						DbSelectArea("SC9")
						SC9->(DbSetOrder(1))
						DbSelectArea("SC6")
						SC6->(DbSetOrder(1))
						DbSelectArea("SE4")
						SE4->(DbSetOrder(1))
						DbSelectArea("SB1")
						SB1->(DbSetOrder(1))
						DbSelectArea("SB2")
						SB2->(DbSetOrder(1))
						
						If SC9->(DbSeek(xFilial("SC9")+TMPSC5->ZA7_PEDIDO+TMPSC5->ZA7_ITEMPD))
							While SC9->(!Eof()) .AND. SC9->C9_PEDIDO == TMPSC5->ZA7_PEDIDO .AND. SC9->C9_ITEM == TMPSC5->ZA7_ITEMPD
								SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO))
								SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
								SB1->(DbSeek(xFilial("SB1")+SC9->C9_PRODUTO))
								SB2->(DbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL))
								SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES))

								aAdd(aPvlNfs,{;
									SC9->C9_PEDIDO,;
									SC9->C9_ITEM,;
									SC9->C9_SEQUEN,;
									SC9->C9_QTDLIB,;
									SC9->C9_PRCVEN,;
									SC9->C9_PRODUTO,;
									.F.,;
									SC9->(RECNO()),;
									SC5->(RECNO()),;
									SC6->(RECNO()),;
									SE4->(RECNO()),;
									SB1->(RECNO()),;
									SB2->(RECNO()),;
									SF4->(RECNO());
									})
								SC9->(DbSkip())
							EndDo
						EndIf

						TMPSC5->(DbSkip())
					EndDo
				EndIf
				If lContinua
					//grava ultimo pedido
					Begin Transaction
						//Gera documento de saida
						Pergunte("MT460A",.F.)
						cNFSaida := MaPvlNfs(aPvlNfs, cSerie, .F. , .F. , .F. , .F. , .F., 0, 0, .F., .F.)

						If cNFSaida <> _cNotaGer .or. Empty(cNFSaida)
							DisarmTransaction()
							If Empty(cNFSaida)
								cMsgErro += "Não foi possível gerar a Nota fiscal numero " + _cNotaGer + CHR(10) + CHR(13)
							EndIf

							If cNFSaida <> _cNotaGer
								cMsgErro += "Nota fiscal numero " + _cNotaGer  + " gerada com numeração cNFSaida , processo não realizado." + CHR(10) + CHR(13)
							EndIf
						Else
							If Empty(cNFs)
								cNFs := cNFSaida
							Else
								cNFs +=" ; "+cNFSaida
							EndIf
							DbSelectArea("ZA7")
							ZA7->(DbGotop())
							ZA7->(DbSetOrder(1))
							If ZA7->(DbSeek( xFilial("ZA7") + cCodZA7))
								While ZA7->(!Eof()) .AND. ZA7->ZA7_CODIGO == cCodZA7
									If ZA7->ZA7_PEDIDO=cCodPedido
										ZA7->(RecLock("ZA7" , .F.))
										ZA7->ZA7_STATUS := "6"
										ZA7->ZA7_DTFAT := DATE()
										ZA7->ZA7_HRFAT := TIME()
										ZA7->ZA7_DOC := _cNotaGer
										ZA7->(MsUnLock())
									EndIf
									ZA7->(DbSkip())
								Enddo
							EndIf
						EndIf
					End Transaction
				EndIf
				If Empty(cMsgErro) .and. lContinua//so grava as nf´s se nao ocorrer erro
					cMsgErro := "Nf(s) "+cNFs+" gerada(s) com sucesso."
				EndIf
				//Grava na tabela de log os dados
				dbSelectArea("ZA6")
				ZA6->(dbSetOrder(1))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
				If ZA6->(dbSeek(xFilial("ZA6")+cCodZA7))
					RecLock("ZA6",.F.)
					ZA6_MSG := ZA6_MSG+cMsgErro+CHR(13)+CHR(10)
					ZA6->(MsUnlock())
				EndIf
				if lContinua
					//Gera Romaneio
					//cMsgErro := U_GeraRoma(cTranspZA7,cCpfZa7,cNFs)
					cNfsGeral += cNFs
					//Grava na tabela de log os dados
					//dbSelectArea("ZA6")
				//	ZA6->(dbSetOrder(1))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
				//	If ZA6->(dbSeek(xFilial("ZA6")+cCodZA7))
				//		RecLock("ZA6",.F.)
				//		ZA6_MSG := ZA6_MSG+cMsgErro+CHR(13)+CHR(10)
				//		ZA6->(MsUnlock())
				//	EndIf

				EndIf
				If Select("TMPSC5") > 0
					TMPSC5->( dbCloseArea() )
				EndIf
			EndIf
	Next i

	If !Empty(cNfsGeral)
		Aviso("Atenção" , "Nf(s) "+cNfsGeral+" gerada(s) com sucesso.")
	EndIf

Return()
//----------------------------------------------------------------------------
/*/{Protheus.doc} GeraRoma(cTranspZA7,cCpfZa7,cNFs)
Gera romaneio na tabela GWN - ROMANEIO DE CARGA
@type function
@version 
@author Jair Andrade
@since 07/01/2021
@return  cMsgErro return_type, return_description
/*/
User Function GeraRoma(cTranspZA7,cCpfZa7,cNFs)
	Local oModel    := Nil
	Local nX := 0
	Local cNotas := ""
	Local cMsgErro := ""
	Local aCabec := {}
	Local cTranspGU3 := Alltrim(Posicione("GU3",13,xFilial("GU3")+cTranspZA7,"GU3_CDEMIT"))
	Local cNomotGU3 := Alltrim(Posicione("GUU",2,xFilial("GU3")+cCpfZa7,"GUU_NMMTR"))
	Local cCodMotGU3 := Alltrim(Posicione("GUU",2,xFilial("GU3")+cCpfZa7,"GUU_CDMTR"))
	Local aInfo := STRTOKARR(cNFs,';') // Resulta {'1','2','4'}
	Private aRotina := {}
// informe oS dados para serem carregados na tabela GWN
	DbSelectArea("GWN")
	GWN->(DbSetOrder(1))
	GWN->(DbGotop())
	for nX := 1 to Len(aInfo)
		If !GWN->(DbSeek( xFilial("GWN") + cNumRom ))
			aadd(aCabec,{"GWN_NRROM",cNumRom})
			aadd(aCabec,{"GWN_CDTRP",cTranspGU3})//transportadora
			aadd(aCabec,{"GWN_CDTPOP","0000000001"})
			aadd(aCabec,{"GWN_CDMTR",cCodMotGU3})//CODIGO MOTORISTA
			aadd(aCabec,{"GWN_NMMTR",cNomotGU3})//nOME MOTORISTA
			aadd(aCabec,{"GWN_SIT","3"})//Situação = 3 - liberado

			oModel := FwLoadModel("GFEA050")
			Begin Transaction
				lMsErroAuto := .F.
				FWMVCRotAuto( oModel,"GWN",3,{{"GFEA050_GWN", aCabec}})
				If lMsErroAuto
					DisarmTransaction()
					cMsgErro := MostraErro()
				Else
					cMsgErro := "Romaneio "+cNumRom+" gerado com sucesso para a(s) Nf(s): "
					//Verifica se o documento existe na tabela GW1 e grava o codigo do romaneio GW1_NRROM
					DbSelectArea("GW1")
					GW1->(DbSetOrder(8))
					GW1->(DbGotop())
					If GW1->(DbSeek( xFilial("GW1") + Alltrim(aInfo[nX]) ))
						GW1->(RecLock("GW1" , .F.))
						GW1->GW1_NRROM := cNumRom
						GW1->(MsUnLock())
					EndIf
				EndIf
				cNotas :=aInfo[1]
			End Transaction
		Else
			//Verifica se o documento existe na tabela GW1 e grava o codigo do romaneio GW1_NRROM
			DbSelectArea("GW1")
			GW1->(DbSetOrder(8))
			GW1->(DbGotop())
			If GW1->(DbSeek( xFilial("GW1") + Alltrim(aInfo[nX]) ))
				GW1->(RecLock("GW1" , .F.))
				GW1->GW1_NRROM := cNumRom
				GW1->(MsUnLock())
				cNotas += " ;"+aInfo[nX]
			EndIf
		EndIf
	Next nX
Return cMsgErro+cNotas+ CHR(10) + CHR(13)
