#include "protheus.ch"
#Include 'FWMVCDef.ch'

#Define ENTER chr(13)+ chr(10)
/*
	Visualizar dados do arquivo do EDI
	Z04 - conteudo
	Z06 - historico de processamento
*/

User Function KESTR23()
	Local 	aArea 		:= GetArea() 
	Local 	oBrowse
	Local	cAlias		:= GetNextAlias()
	Local 	aRet		:= {}
	Local 	cArqTrb		:= {}
	Local	aSeek		:= {}
	Local	aFiltro		:= {}
	Local 	aCpos		:= {}
	Local	cCadastro	:= "Arquivos EDI Proceda Recebidos"
	Private aRotina		:= {}

	aRotina		:= MenuDef()

	FWMsgRun(, {|oSay| aRet	:= CriarTabela(cAlias) }, "Carregando dados...", "Aguarde...")
	cArqTrb		:= aRet[1]
	aSeek		:= aRet[2]
	aFiltro		:= aRet[3]
	aCpos		:= aRet[4]

	(cAlias)->(DbSetOrder(1))
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAlias)
	oBrowse:SetDescription(cCadastro)
	If !Empty(aSeek)
		oBrowse:SetSeek(.T.,aSeek)
	Endif
	oBrowse:SetWalkThru(.f.)
	oBrowse:SetAmbiente(.f.)
	oBrowse:OptionReport(.f.)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetLocate()
	If !Empty(aFiltro)
		oBrowse:SetUseFilter(.T.)
		oBrowse:SetDBFFilter(.T.)
		oBrowse:SetFilterDefault( "" ) //Exemplo de como inserir um filtro padrão >>> "TR_ST == 'A'"
		oBrowse:SetFieldFilter(aFiltro)
	Endif
	oBrowse:DisableDetails()

	If !Empty(aFiltro)
		CriarColunas(oBrowse,,aFiltro)
	Else
		CriarColunas(oBrowse,aCpos)
	Endif

	oBrowse:Activate()

	If !Empty(cArqTrb)
		Ferase(cArqTrb+GetDBExtension())
		Ferase(cArqTrb+OrdBagExt())

		(cAlias)->(DbCloseArea())
		delTabTmp(cAlias)
	Endif

	RestArea(aArea)
Return

Static Function MenuDef()
	// array
	Local aRot 		:= {}
	
	aRot :={{"Pesquisar"			,"AxPesqui"		, 0 , 1, 0 , .F.},;
			{"Visualizar Conteúdo"	,"U_KESTR23B"	, 0 , 2, 0 , nil},;
			{"Visualizar Histórico"	,"U_KESTR23A"	, 0 , 2, 0 , nil}}
	
	// retorna o array
Return aRot

Static Function CriarTabela(cAlias)
	Local cArqTrb, cIndice1, cIndice2
	Local aCampos	:= {}
	// Local aRet		:= {}
	Local aSeek		:= {}
	Local aFilter	:= {}
	Local aDados	:= {aCampos,aSeek,aFilter}
	Local aIndice	:= {}
	Local cSeq		:= "9"
	Local nX		:= 0
	Local nPArq		:= 0
	Local nPData	:= 0
	Local nPHora	:= 0

	//aDados := GetCampo("Z06_FILIAL"	,"Z06",aDados)
	aDados := GetCampo("Z06_ARQUIV"	,"Z06",aDados)
	nPArq  := Len(aDados[2])
	aDados := GetCampo("Z06_DATA"	,"Z06",aDados)
	nPData := Len(aDados[2])
	aDados := GetCampo("Z06_HORA"	,"Z06",aDados)
	nPHora := Len(aDados[2])
	aDados := GetCampo("Z06_CODIGO"	,"Z06",aDados,,.F.)
	aDados := GetCampo("Z06_STATUS"	,"Z06",aDados,,.F.,.F.)
	aDados := GetCampo("CTK_RECCV3"	,"CTK",aDados,,.F.,.F.)
	// aDados := GetCampo("Z06_EMPDES"	,"Z06",aDados,,.F.)
	// aDados := GetCampo("Z06_FILDES"	,"Z06",aDados,,.F.)

	aCampos := aDados[1]
	aSeek	:= aDados[2]
	aFilter := aDados[3]

	aSeek[nPData][1]:= "Data+Hora"
	aadd(aSeek[nPData][2],aSeek[nPHora][2][1])

	For nX := 1 to Len(aSeek)
		If nX <> nPData .and. nX <> nPArq
			aSeek[nX][4] := .F.
		Endif
	Next

	//Antes de criar a tabela, verificar se a mesma já foi aberta
	If Select(cAlias) <> 0
		(cAlias)->(dbCloseArea ())
	Endif
	
	//Criar tabela temporária
	cArqTrb   := CriaTrab(aCampos,.T.)
	
	cIndice1 := Alltrim(CriaTrab(,.F.))
	
	For nX := 1 to Len(aSeek)

		cSeq	:= Soma1(cSeq)
		cIndice2:= cIndice1

		cFiltro := aSeek[nX][2][1][5]
		cTitulo := AllTrim(aSeek[nX][1])

		cIndice2:= Left(cIndice2,5)+Right(cIndice2,2)+cSeq

		If File(cIndice2+OrdBagExt())
			FErase(cIndice2+OrdBagExt())
		EndIf

		aadd(aIndice,{cIndice2,cFiltro,cTitulo})

	next
		
	//Criar e abrir a tabela
	dbUseArea(.T.,,cArqTrb,cAlias,Nil,.F.)
	
	For nX := 1 to Len(aIndice)
		IndRegua(cAlias,aIndice[nX][1],aIndice[nX][2],,,aIndice[nX][3])
	Next

	dbClearIndex()
	
	For nX := 1 to Len(aIndice)
		dbSetIndex(aIndice[nX][1]+OrdBagExt())
	Next

	CarregarDados(cAlias,aCampos)
	

Return {cArqTrb,aSeek,aFilter,aCampos}

Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1
	Default nSize 	:= 20
	Default nDecimal:= 0
	Default nArrData:= 0
	
	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
	EndIf
	
	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
Return {aColumn}


Static Function CriarColunas(oBrowse,aCpos,aFiltro)
	Local nX 	:=  1
	Local cCpo	:= ""
	Local nAlign:= 0
	Local nTam	:= 0

	If !Empty(aCpos)
		For nX := 1 to Len(aCpos)
			nAlign := 1
			cCpo := aCpos[nX][1]
			nTam := aCpos[nX][3] / 3
			if cCpo == "Z06_ARQUIV"
				nTam := aCpos[nX][3] * 0.7
			Endif
			if aCpos[nX][2] == "N"
				nAlign := 2
				nTam := aCpos[nX][3] 
			ElseIf aCpos[nX][2] == "D"
				nAlign := 0
			Endif
			oBrowse:SetColumns(MontaColunas(cCpo,RetTitle(cCpo),01,"@!",nAlign,nTam,aCpos[nX][4]))
		next	
	Else
		For nX := 1 To Len(aFiltro)
			nAlign := 1
			nTam := aFiltro[nX][4] / 3
			if aFiltro[nX][1] == "Z06_ARQUIV"
				nTam := aFiltro[nX][4] * 0.7 
			Endif
			if aFiltro[nX][3] == "N"
				nTam := aFiltro[nX][3] 
				nAlign := 2
			ElseIf aFiltro[nX][3] == "D"
				nAlign := 0
			Endif
			// Aadd(aFiltro,{cCampo,cTitulo,aCpo[3], aCpo[1],aCpo[2],cPicture})
			oBrowse:SetColumns(MontaColunas(aFiltro[nX][1],aFiltro[nX][2],01,aFiltro[nX][6],nAlign,nTam,aFiltro[nX][5]))
		Next
	Endif

Return

Static function CarregarDados(cAlias,aCampos)
	Local aArea		:= GetArea()
	Local cTemp		:= GetNextAlias()
	Local cQuery	:= ""
	Local nX		:= 0

	cQuery += "SELECT "+ENTER
	cQuery += "    Z06_ARQUIV "+ENTER
	cQuery += "    ,Z06_DATA "+ENTER
	cQuery += "    ,Z06_HORA "+ENTER
	cQuery += "    ,Z06_CODIGO "+ENTER
	cQuery += "    ,X5_DESCRI Z06_STATUS  "+ENTER
	cQuery += "    ,CTK_RECCV3 "+ENTER
	// cQuery += "		,Z06_EMPDES "+ENTER
	// cQuery += "		,Z06_FILDES "+ENTER
	cQuery += "FROM ( "+ENTER
	cQuery += "		SELECT "+ENTER
	cQuery += "			Z06_FILIAL "+ENTER
	cQuery += "			,Z06_ARQUIV "+ENTER
	cQuery += "			,Z06_DATA "+ENTER
	cQuery += "			,Z06_HORA "+ENTER
	cQuery += "			,Z06_CODIGO "+ENTER
	// cQuery += "			,Z06_EMPDES "+ENTER
	// cQuery += "			,Z06_FILDES "+ENTER
	cQuery += "			,CONVERT(CHAR(100),Z06.R_E_C_N_O_) CTK_RECCV3"+ENTER
	cQuery += "			,ROW_NUMBER() OVER(PARTITION BY Z06_FILIAL,Z06_ARQUIV  ORDER BY Z06_FILIAL, Z06_ARQUIV, Z06_DATA+Z06_HORA) NUMBER "+ENTER
	cQuery += "			 "+ENTER
	cQuery += "		FROM "+RetSqlName("Z06")+" Z06 "+ENTER
	cQuery += "			 "+ENTER
	cQuery += "		WHERE  "+ENTER
	cQuery += "				Z06.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "			AND Z06.Z06_FILIAL = '"+xFilial("Z06")+"' "+ENTER
	cQuery += "		) TAB "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SX5")+" SX5 ON SX5.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND X5_FILIAL = '"+xFilial("SX5")+"' "+ENTER
	cQuery += "		AND X5_TABELA = 'ZC' "+ENTER
	cQuery += "		AND X5_CHAVE = Z06_CODIGO "+ENTER
	cQuery += "WHERE NUMBER = 1 "+ENTER
	cQuery += "ORDER BY  "+ENTER
	cQuery += "	Z06_ARQUIV "+ENTER

	MPSysOpenQuery(cQuery,cTemp)

	TcSetField(cTemp,"Z06_DATA","D")

	While !(cTemp)->( EOF() )
		RecLock(cAlias,.T.)
			
			For nX :=1 to Len(aCampos)
				if (cTemp)->(FieldPos(aCampos[nX][1]))  > 0 
					&(cAlias+"->"+aCampos[nX][1]) := &(cTemp+"->"+aCampos[nX][1])
				Endif
			Next
			
		MsUnlock(cAlias)
		(cTemp)->(DbSkip())
	Enddo

	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	Endif

	(cAlias)->(DbGoTop())

	RestArea(aArea)
Return 


Static Function GetCampo(cCampo,cTab,aDados,cTitulo,lSeek,lFiltro)
	Local aCpo		:= TamSx3(cCampo)
	Local cPicture	:= PesqPict(cTab,cCampo)
	Local aRet		:= {}
	Local aCampos	:= aClone(aDados[1]) 
	Local aSeek		:= aClone(aDados[2])
	Local aFiltro	:= aClone(aDados[3])

	Default cTitulo	:= RetTitle(cCampo)
	Default lSeek	:= .T.
	Default lFiltro	:= .T.

	// //Campos que irão compor o combo de pesquisa na tela principal
	If aCpo[3] <> "N" .and. !"_FILIAL" $ cCampo .and. lSeek
		Aadd(aSeek,{cTitulo, {{"",aCpo[3],aCpo[1],aCpo[3],cCampo,cPicture}}, Len(aSeek)+1, .T. } )
	Endif
	
	If lFiltro
		//Campos que irão comp or a tela de filtro
		Aadd(aFiltro,{cCampo,cTitulo,aCpo[3], aCpo[1],aCpo[2],cPicture})
	Endif

	aadd(aCampos,{cCampo,aCpo[3],aCpo[1],aCpo[2]})

	aRet := {aCampos,aSeek,aFiltro}

Return aRet

User Function KESTR23A(cAlias,nReg,nOpc)
	Local aArea			:= GetArea()
	Local cFiltro		:= "Z06_ARQUIV"
	// indice cabecalho 
	Local cCabIndexKey	:= "Z06_FILIAL+Z06_ARQUIV"  
	// indice do item   
	Local cItemIndexKey	:= "Z06_FILIAL+Z06_NFISCA+Z06_NFSERI+DTOS(Z06_DATA)+Z06_HORA+Z06_CODIGO" 
	Local cCabecalho	:= "Histórico de processamento"
	Local cArquivo		:= (cAlias)->Z06_ARQUIV
	
	nReg	:= 0
	cAlias	:= "Z06"
	nOpc	:= 2

	CriaTela(cAlias,nReg,nOpc,cCabecalho,cFiltro,cCabIndexKey,cItemIndexKey,"01",xFilial("Z06"),cArquivo)

	RestArea(aArea)
Return

User Function KESTR23B(cAlias,nReg,nOpc)
	Local aArea			:= GetArea()
	Local cFiltro		:= "Z04_ARQUIV,Z04_TRANSP,Z04_TRANLJ,Z04_TRANNM,Z04_TRANCN,Z04_EMISSO,Z04_DATA,Z04_HORA"
	// indice cabecalho 
	Local cCabIndexKey	:= "Z04_FILIAL+Z04_ARQUIV"  
	// indice do item   
	Local cItemIndexKey	:= "Z04_FILIAL+Z04_NFISCA+Z04_NFSERI+Z04_OCORDT+Z04_OCORHR"
	Local cCabecalho	:= "Conteúdo do arquivo"
	Local _cEmp			:= ""
	Local _cFil			:= ""
	Local cArquivo		:= (cAlias)->Z06_ARQUIV
	Local aRet			:= {"",""}
	
	nReg	:= 0 // GetZ04Recno( (cAlias)->Z06_ARQUIV )
	cAlias	:= "Z04"
	nOpc	:= 2

	aRet := GetEmpresa(cArquivo)
	_cEmp:= aRet[1]
	_cFil:= aRet[2]

	if Empty(AllTrim(_cEmp)) .or. Empty(AllTrim(_cFil))
		MsgStop("Não foi possível localizar a empresa e filial de destino do arquivo.")
		return
	Endif
	
	CriaTela(cAlias,nReg,nOpc,cCabecalho,cFiltro,cCabIndexKey,cItemIndexKey,_cEmp,_cFil,cArquivo)

	RestArea(aArea)
Return

Static Function CriaTela(cAlias,nReg,nOpc,cCabecalho,cFiltro,cCabIndexKey,cItemIndexKey,_cEmp,_cFil,cArquivo)
	// funcao botao ok
	Local 	bOkb	 	:= {|| oDlg:End()}
	// funcao cancelar
	Local 	bCancel 	:= {|| oDlg:End()}
	// msg ao deletar
	Local 	lMsgDel		:= .F.
	// botoes
	Local 	aButtons	:= {}
	// exibe mashups
	Local 	lMashups	:= .F.
	// imprime padrao
	Local 	lImpCad		:= .F.
	// botoes padra
	Local 	lPadrao		:= .F.
	// exibe botao ok
	Local 	lHasOk		:= .T.
	// exibe walk
	Local 	lWalkThru	:= .F.

	// area atual
	Local 	aArea		:= GetArea()
	// coluna a ser congelada
	Local 	nColFreeze	:= 0
	// opcao retorno
	// Local	nOpcA		:= 0
	// posicao enchoice
	Local	aPos		:= {}
	// tipo de altercao
	Local	nStyle		:= GD_UPDATE
	// contador
	// Local	nX			:= 0

	// validacao da linha
	Private	cLinOk		:= "AllwaysTrue" //"U_PFATE22F"
	// validacao do confirmar
	Private	cTudoOk		:= "AllwaysTrue" //"U_PFATE22G"
	// campo sequencial
	Private	cIniCpos	:= "" //"+ZH_ORDEM"
	// maximo de linhas
	Private	nMax      	:= 999        
	// // validacao do campo
	// Private	cFieldOk  	:= "AllwaysTrue"  
	// // validacao da delecao total
	// Private	cDelOk    	:= "AllwaysTrue"
	// validacao da delecao da linha
	Private cDelLinha	:= "AllwaysTrue"
	// campos a serem exibidos no enchoice nao serao exibidos na grid (campos que exibem no browse)
	Private aEnchExib	:= enchoiceFields(cAlias,cFiltro)
	
	// objeto tela
	Private	oDlg
	// objeto itens msgetdados
	Private	oGetDb
	// campo filial
	Private cCmpFil		:= ""
	// array do cabecalho do msgetdados
	Private aHeader 	:= {}
	// itens do msgetdados
	Private aCols		:= {}
		
	// campos que podem ser alterados no enchoice
	Private aEnchAlte	:= {}
	// array com campos que podem ser editados na grid
	Private	aGrdAlte 	:= {}
	// capos que nao aparecerao na grid
	Private aNoFields	:= {"Z04_FILIAL","Z06_FILIAL","Z04_EMPRES"}
	
	// tamanho da tela
	Private aSize		:= {}
	// objetos contidos na tela
	Private aObjects	:= {}
	// array tamanho da tela
	Private aInfo		:= {}
	// posicao dos getdados
	Private aPosObj		:= {}
	Private cCadastro	:= cCabecalho
	
	If Type("INCLUI") == "U"
		INCLUI := .F.
	Endif

	If Type("ALTERA") == "U"
		ALTERA := .F.
	Endif

	if nOpc == 3 
		INCLUI 	:= .T.
		ALTERA	:= .F.
	ElseIf nOpc == 4
		ALTERA 	:= .T.
		INCLUI	:= .F.
	Endif
	
	lHasOk := (nOpc == 3 .or. nOpc == 4 .or. nOpc == 5 )
	
	if !lHasOk
		nStyle := 0
	Endif
	
	aAdd( aButtons, {"", {|| U_KESTR23G("pedidos"		,_cEmp,_cFil)}, "Pedidos da nota fiscal"					})
	aAdd( aButtons, {"", {|| U_KESTR23G("ocorrencias"	,_cEmp,_cFil)}, "Ocorrências dos pedidos da nota fiscal."	})

	// DbSelectArea(cAlias)
	// (cAlias)->( DbGoTo(nReg) )
	
	//monta aheader e popula o acols
	CriarArrays(cAlias,nReg,nOpc,cCabIndexKey,cItemIndexKey,_cEmp,_cFil,cArquivo)

	// calcula tamanho da tela
 	screenSize()

	aPos	:= { aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4] }	 

	//Monta Tela Modelo 2                                                                  
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7],0 to aSize[6],aSize[5] pixel //OF oMainWnd  

		@ 045,015 Say "Arquivo: " of oDlg Pixel
		@ 044,045 Msget AllTrim(cArquivo) Size 100,10 Picture "@!" of oDlg Pixel When .F.
 	
		// carrega objeto acols
		oGetDb := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nStyle,cLinOk,cTudoOk,cIniCpos,aGrdAlte,nColFreeze,nMax,,,cDelLinha,,aHeader,aCols,,)

	//Validacao da janela
	ACTIVATE MSDIALOG oDlg  ON INIT EnchoiceBar( oDlg ,bOkb,bCancel,lMsgDel,aButtons,nReg,cAlias,lMashups,lImpCad,lPadrao,lHasOk,lWalkThru)

	// fecha a area
	(cAlias)->( DbCloseArea() )

	// restaura a area
	RestArea(aArea)
	// retorna
Return 

Static Function CriarArrays(cAlias,nReg,nOpc,cCabIndexKey,cItemIndexKey,_cEmp,_cFil,cArquivo)
	Local nPos	:= 0
	Local nTam	:= 0

	// contador
	// Local nX 			:= ""
	// campo
	// Local cCampo		:= ""
	// query sim ou nao
	Local lQuery  		:= .T.
	// query
	Local cQuery 		:= ""
	// pesquisa do item
	Local cSeek			:= cCabIndexKey
	// contador
	Local bWhile		:= {|| cCabIndexKey }
	// condicao para continuar
	Local bCond			:= {|| .T. }
	Local cTabela		:= cAlias+_cEmp+"0"

	If Type("cNivel") == "U"
		cNivel := "5"
	Endif
	
	// abre SX3, define ordem e posiciona na tabela
	SX3->( dbSetOrder(1) )
	IF SX3->( dbSeek(cAlias) )
		// faz loop enquanto existirem campos da tabela
		While !SX3->( EOF() ) .And. (SX3->x3_arquivo == cAlias)
			// ser o campo for usado e de um nivel menor ou igual ao do menu de usuario
			If (x3Uso(SX3->x3_usado) .and. cNivel >= SX3->x3_nivel ) .and. !'FILIAL' $ SX3->X3_CAMPO 
				// localiza se exibe o registro no enchoice
				If Ascan(aEnchExib,Trim(SX3->X3_CAMPO)) > 0
					// se nao é virtual
					if SX3->x3_contexto <> 'V'
						// adiciona que pode alterar o campo
						Aadd(aEnchAlte,Trim(SX3->X3_CAMPO))
					endif
					// adiciona nos campos que nao exibem na grid
					aadd(aNoFields,Trim(SX3->X3_CAMPO))
				// se nao existe na grid
				Else 
					// se campo real
					if SX3->x3_contexto <> 'V' 
						// adiciona o campo que pode alterar na grid
						aadd(aGrdAlte,Trim(SX3->X3_CAMPO))
					Endif
				EndIF
			EndIF
			
			// se campo filial
			If 'FILIAL' $ SX3->X3_CAMPO
				// fixa o campo filial
				cCmpFil := SX3->X3_CAMPO
				// nao exibe o campo na grid
				aadd(aNoFields,Trim(SX3->X3_CAMPO))
			Endif
			// proximo registro
			SX3->( DbSkip() )
		Enddo
	Endif

	lQuery  := .T.
	//query que alimenta o acols
	cQuery := "SELECT * "	
	cQuery += "FROM "+cTabela+" "	
	cQuery += "WHERE D_E_L_E_T_<>'*' "	
	cQuery += "AND "+cCabIndexKey+" ='"+ _cFil+cArquivo +"' "
	cQuery += "ORDER BY "+SqlOrder(cItemIndexKey)
	
	// Montagem do aHeader e aCols
	FillGetDados(nOpc,cAlias,1,cSeek,bWhile,{{bCond,{|| .T. },{|| .F. }}},aNoFields,/*aYesFields*/,/*lOnlyYes*/,cQuery,/*bMontCols*/,INCLUI,/*aHeaderAux*/,/*aColsAux*/,/*bafterCols*/,/*bBeforeCols*/,/*bAfterHeader*/,"TMP")
	
	nPos := aScan(aHeader,{|x| AllTrim(x[2]) == "Z06_OBS"})
	If nPos > 0
		nTam := 30 
		aHeader[nPos][4] := nTam
	Endif

	nPos := aScan(aHeader,{|x| AllTrim(x[2]) == "Z06_USUANO"})
	If nPos > 0
		nTam := 30 
		aHeader[nPos][4] := nTam
	Endif

	nPos := aScan(aHeader,{|x| AllTrim(x[2]) == "Z06_STATUS"})
	If nPos > 0
		nTam := 30
		aHeader[nPos][4] := nTam
	Endif

Return

Static Function screenSize()
	aSize := MsAdvSize()

	aObjects := {}
	If IsInCallStack("U_KESTR23A") .or. IsInCallStack("U_KESTR23B")
		AAdd( aObjects, { 100, 050, .T., .F. } )
	Else
		AAdd( aObjects, { 100, 100, .T., .F. } )
	Endif
	AAdd( aObjects, { 100, 100, .T., .T. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }

	aPosObj := MsObjSize( aInfo, aObjects )	
Return

Static Function enchoiceFields(cAlias,cFiltro)
	Local 	aRet 	:= {}
	Local 	aArea	:= GetArea()
	Default cFiltro := ""

	aadd(aRet,"NOUSER")

	SX3->( DbSetOrder(1))
	If SX3->( MsSeek(cAlias) )
		While !SX3->( EOF() ) .and. SX3->X3_ARQUIVO == cAlias
			If x3Uso(SX3->x3_usado) .and. cNivel >= SX3->x3_nivel .and. !'FILIAL' $ SX3->X3_CAMPO 
				If !Empty(AllTrim(cFiltro)) .and. !AllTrim(SX3->X3_CAMPO) $ cFiltro
					SX3->( DbSkip() )
					loop
				Endif
				aadd(aRet,AllTrim(SX3->X3_CAMPO))
			Endif
			SX3->( DbSkip() )
		Enddo
	Endif

	RestArea(aArea)
Return aRet

User Function KESTR23G(cOpc,_cEmp,_cFil)
	Local aArea := GetArea()
	Local nAt	:= oGetDb:nAt
	Local nPNF	:= aScan(oGetDb:aHeader,{|x| "NFISCA" == Right(AllTrim(x[2]),Len(AllTrim(x[2]))-4) })
	Local nPSer	:= aScan(oGetDb:aHeader,{|x| "NFSERI" == Right(AllTrim(x[2]),Len(AllTrim(x[2]))-4) })
	Local nPEmp	:= aScan(oGetDb:aHeader,{|x| "EMPDES" == Right(AllTrim(x[2]),Len(AllTrim(x[2]))-4) })
	Local nPFil	:= aScan(oGetDb:aHeader,{|x| "FILDES" == Right(AllTrim(x[2]),Len(AllTrim(x[2]))-4) })
	Local cNota	:= ""
	Local cSerie:= ""

	Default _cEmp	:= ""
	Default _cFil	:= ""

	if nPNF > 0
		cNota := oGetDb:aCols[nAt][nPNF]
	Endif

	if nPSer > 0
		cSerie := oGetDb:aCols[nAt][nPSer]
	Endif

	if nPEmp > 0
		_cEmp := oGetDb:aCols[nAt][nPEmp]
	Endif

	if nPFil > 0
		_cFil := oGetDb:aCols[nAt][nPFil]
	Endif

	if Empty(AllTrim(cNota))
		MsgStop("Registro não possui nota fiscal associada.")
		Return
	Endif

	If cOpc == "pedidos"
		U_KESTR23P(_cEmp,_cFil,cNota,cSerie)
	else
		U_KESTR23N(_cEmp,_cFil,cNota,cSerie)
	Endif

	RestArea(aArea)
Return


/*
	exibe pedidos da nota fiscal de saída
*/
User Function KESTR23P(_cEmp,_cFil,cNota,cSerie)
	Local 	aArea 	:= GetArea()
	Local 	cTitulo	:= "Pedidos da nota fiscal: "+AllTrim(cNota)+"/"+AllTrim(cSerie)
	Local	cCampos	:= "D2_DOC,D2_SERIE,D2_PEDIDO"
	Local	cSelect	:= "SELECT DISTINCT D2_DOC,D2_SERIE, D2_PEDIDO "
	Local	cFrom	:= ""
	Local 	lHasMark:= .F.
	Local 	lMax	:= .F.
	
	cFrom += "FROM SD2"+AllTrim(_cEmp)+"0	SD2 "+ENTER
	cFrom += "	 "+ENTER
	cFrom += "WHERE SD2.D_E_L_E_T_<>'*' "+ENTER
	cFrom += "AND D2_FILIAL='"+AllTrim(_cFil)+"' "+ENTER
	cFrom += "AND D2_DOC='"+cNota+"' "+ENTER
	cFrom += "AND D2_SERIE ='"+cSerie+"' "+ENTER
	cFrom += "ORDER BY 1"+ENTER

	StaticCall(LISTBOX,dialogListBox,cTitulo,cCampos,cSelect,cFrom,lHasMark,nil,nil,nil,lMax)
	
	RestArea(aArea)
Return


/*
exibe o historico de ocorrencias de transporte
*/
User Function KESTR23N(_cEmp,_cFil,cNota,cSerie)
	Local 	aArea 	:= GetArea()
	Local 	cTitulo	:= "Historico de Ocorrências de Trânsporte da nota: "+Alltrim(cNota)+"/"+Alltrim(cSerie)
	Local	cCampos	:= "ZF_PEDIDO,ZF_DATA,ZF_HORA,ZF_USUACOD,ZF_USUANOM,ZF_CODIGO,ZF_STATUS,ZF_DOC,ZF_SERIE,ZF_ITEMPV,ZF_TROCORR,ZF_TROCODE,ZF_TROBS"
	Local	cSelect	:= "SELECT "
	Local	cFrom	:= ""
	Local 	lHasMark:= .F.
	Local 	lMax	:= .T.
	
	Default nReg 	:= 0

	if nReg > 0 .and. nReg <> SC5->( Recno() )
		SC5->( DbGoTo(nReg))
	Endif
	
	cTitulo += AllTrim(SC5->C5_NUM)+"."
	cFrom += "FROM SZF"+AllTrim(_cEmp)+"0 "

	cFrom += "WHERE D_E_L_E_T_<>'*' "
	cFrom += "	AND ZF_FILIAL = '"+_cFil+"' "
	cFrom += "	AND ZF_DOC = '"+cNota+"' "
	cFrom += "	AND ZF_SERIE = '"+cSerie+"' "
	cFrom += "	AND ZF_CODIGO IN ('20','05','06')"

	cFrom += "ORDER BY ZF_PEDIDO,ZF_DATA + ' ' + ZF_HORA "

	StaticCall(LISTBOX,dialogListBox,cTitulo,cCampos,cSelect,cFrom,lHasMark,nil,nil,nil,lMax)
	
	RestArea(aArea)
Return


Static Function GetEmpresa(cArquivo)
	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cTemp	 	:= "TMP_EMPR"
	Local aRet		:= {}

	cQuery += "SELECT TOP 1 Z06_EMPDES, Z06_FILDES "+ENTER
	cQuery += "FROM "+RetSqlName("Z06")+" "+ENTER
	cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "	AND Z06_FILIAL = '"+xFilial("Z06")+"' "+ENTER
	cQuery += " AND Z06_ARQUIV = '"+cArquivo+"' "+ENTER
	cQuery += " AND Z06_EMPDES <> '' "+ENTER
	cQuery += " ORDER BY R_E_C_N_O_ "+ENTER

	MPSysOpenQuery(cQuery,cTemp)

	if !(cTemp)->(EOF())
		aadd(aRet,AllTrim((cTemp)->Z06_EMPDES))
		aadd(aRet,AllTrim((cTemp)->Z06_FILDES))
	Endif

	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	Endif

	RestArea(aArea)
Return aRet
	