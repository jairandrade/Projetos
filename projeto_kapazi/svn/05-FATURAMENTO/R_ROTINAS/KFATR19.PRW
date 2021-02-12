#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#INCLUDE "topconn.ch"

#Define ENTER CHR(13)+CHR(10)

/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: Funcao Base															                        **/
/**----------------------------------------------------------------------------------------------------------------	**/
User Function KFATR19()
	Local 	oBrowse
	Private aRotina		:= {}
	Private	cCadastro	:= "Packing List"
	Private	cFiltro		:= "@"

	aRotina		:= MenuDef()

	cFiltro += " Z03_AGLUTIN == 'S' "
	Z03->( DbSetFilter({|| .T.},cFiltro))

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('Z03')
	oBrowse:SetDescription(cCadastro)
	oBrowse:SetWalkThru(.f.)
	oBrowse:OptionReport(.f.)
	oBrowse:Activate()

	Z03->( DbClearFilter() )

Return

/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: MenuDef															                            **/
/** DESCRICAO		: Cria o menu                                                                       			**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**	                  				             PARAMETROS     	              		      						**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**----------------------------------------------------------------------------------------------------------------	**/
Static Function MenuDef()
	Local aRet := {}

	aadd(aRet,{ "Pesquisar"		,"AxPesqui"		, 0 , 1})  //"Pesquisar"
	aadd(aRet,{ "Visualizar"	,"u_KFATR19A"	, 0 , 2})  //"Visualizar"
	aadd(aRet,{ "Incluir"		,"u_KFATR19A"	, 0 , 3})  //"Incluir"
	aadd(aRet,{ "Alterar"		,"u_KFATR19A"	, 0 , 4})  //"Alterar"
	aadd(aRet,{ "Excluir"		,"u_KFATR19A"	, 0 , 5})  //"Excluir"
	aadd(aRet,{ "Gerar Packing"	,"u_KFATR20"	, 0 , 3})  //"Excluir"
	aadd(aRet,{ "Imprimir Packing"	,"u_KFATR21"	, 0 , 3})  //"Excluir"
	// aadd(aRet,{ "Imprimir"		,"U_PFATR15A"	, 0 , 6})  //"Imprimir"

Return aRet

/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: KFATR19A															                            **/
/** DESCRICAO		: executa as opcoes                                                                 			**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**	                  				             PARAMETROS     	              		      						**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** cAlias      | tabela                                                                                         	**/
/** nReg        | registro                                                                                       	**/
/** nOpc        | opcao 2=visualiza,3=inclu,4=altera,5=exclui                                                    	**/
/**----------------------------------------------------------------------------------------------------------------	**/
User Function KFATR19A(cAlias,nReg,nOpc)
	// funcao botao ok
	Local 	bOkb	 	:= {|| iif( !validTOk() ,nil, ( nOpcA := 1,oDlg:End() ) ) }
	// funcao cancelar
	Local 	bCancel 	:= {||oDlg:End()}
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
	// congelar colunas
	// Local 	lFreeze		:= .F.
	// opcao retorno
	Local	nOpcA		:= 0
	// posicao enchoice
	Local	aPos		:= {}
	// tipo de altercao
	Local	nStyle		:= GD_UPDATE+GD_DELETE
	// contador
	Local	nX			:= 0
	// validacao da linha
	Private	cLinOk		:= "AllwaysTrue" //"U_PFATE22F"
	// validacao do confirmar
	Private	cTudoOk		:= "AllwaysTrue" //"U_PFATE22G"
	// campo sequencial
	Private	cIniCpos	:= "" //"+ZH_ORDEM"
	// maximo de linhas
	Private	nMax      	:= 999        
	// validacao do campo
	// Private	cFieldOk  	:= "AllwaysTrue"  
	// validacao da delecao total
	// Private	cDelOk    	:= "AllwaysTrue"
	// validacao da delecao da linha
	Private cDelLinha	:= "U_KFATR19D()"
	// campos a serem exibidos no enchoice nao serao exibidos na grid (campos que exibem no browse)
	Private aEnchExib	:= enchoiceFields(cAlias)
	
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
	Private aNoFields	:= {}
	
	// tamanho da tela
	Private aSize		:= {}
	// objetos contidos na tela
	Private aObjects	:= {}
	// array tamanho da tela
	Private aInfo		:= {}
	// posicao dos getdados
	Private aPosObj		:= {}
	
	// botoes adicionais
	Private _aButtons	:= {}
	
	Default cAlias 		:= "Z03"

	_aButtons	:= {}

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
	
	// If (nOpc == 4 .or. nOpc == 5 ) .AND. !canAlter(Z4X->Z4X_CERTIF)
	// 	MsgInfo("O certificado já foi impresso e não pode ser alterado ou excluído.")
	// 	nOpc := 2
	// 	INCLUI := .F.
	// 	ALTERA := .F.
	// Endif
	
	lHasOk := (nOpc == 3 .or. nOpc == 4 .or. nOpc == 5 )
	
	if !lHasOk
		nStyle := 0
	Endif
	
	//monta aheader e popula o acols
	montArray(cAlias,nReg,nOpc)

	// // faz loop nos campos
	// For nX := 1 to Len(aHeader)
	// 	// se um dos campos de valor
	// 	If AllTrim(aHeader[nX][2]) == "Z4X_TEXT" .or. AllTrim(aHeader[nX][2]) == "Z4X_DATE" .or. AllTrim(aHeader[nX][2]) == "Z4X_NUMBER"
	// 		// reduz a largura da coluna
	// 		aHeader[nX][4] := 20
	// 	Endif
	// Next
	
	// calcula tamanho da tela
	screenSize()

	aPos	:= { aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4] }	 

	DbSelectArea(cAlias)
	
	//Monta Tela Modelo 2                                                                  
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7],0 to aSize[6],aSize[5] pixel //OF oMainWnd  
 	
		// carrega objeto acols
		//oGetDB:=MsGetDados()		:New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc	,cLinOk	,cTudoOk,cIniCpos,.T.		,aGrdAlte	,nColFreeze,,nMax,				,				,			,		,		,lFreeze	)
		oGetDb := MsNewGetDados()	:New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nStyle	,cLinOk	,cTudoOk,cIniCpos			,aGrdAlte	,nColFreeze	,nMax,/*cFieldOk*/	,/*cSuperDel*/	,cDelLinha	,			,aHeader,aCols,,)

	 // RegToMemory(cAlias,lInc		,lDic,lInitPad,cStack)
		RegToMemory(cAlias,nOpc == 3)

	  //	   Enchoice(cAlias,nReg,nOpc,aCRA	,cLetras,cTexto	,aAcho		,aPos	,aCpos		,nModelo	,nColMens	,cMensagem	,cTudoOk,oWnd,lF3,lMemoria	,lColumn,caTela	,lNoFolder	,lProperty	,aField	,aFolder,lCreate,lNoMDIStrech	,cTela	)
		nOpcA:=EnChoice(cAlias,Nil	,nOpc,		,		,		,aEnchExib	,aPos	,aEnchAlte	)

	//Validacao da janela
	ACTIVATE MSDIALOG oDlg  ON INIT EnchoiceBar( oDlg ,bOkb,bCancel,lMsgDel,aButtons,nReg,cAlias,lMashups,lImpCad,lPadrao,lHasOk,lWalkThru)

	setFilter(1)

	IF nOpcA == 1 // Aceita operacao e grava dados
		Begin Transaction
			cCert := regSave(cAlias,nReg,nOpc)
		End Transaction
		
		// // pergunta
		// If (INCLUI .OR. ALTERA) .and. MsgYesNo("Deseja imprimir o certificado?")
				
		// 	Z4X->( DbGoTop() )
		// 	If Z4X->( MsSeek(xFilial("Z4X")+cCert))
		// 		// chama funcao para imprimir 
		// 		U_PFATR15A(cAlias,Z4X->(Recno()),nOpc)
		// 		// reposiciona
		// 		Z4X->( MsSeek(xFilial("Z4X")+cCert))
		// 	Endif
		// Endif
	Else
		RollBackSx8()
	Endif

	// fecha a area
	(cAlias)->( DbCloseArea() )

	// restaura a area
	RestArea(aArea)
	// retorna
Return 

/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: createArr															                        **/
/** DESCRICAO		: monta o aheader, acols, e os campos da enchoice                                   			**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**	                  				             PARAMETROS     	              		      						**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** cAlias      | tabela                                                                                         	**/
/** nReg        | registro                                                                                       	**/
/** nOpc        | opcao 2=visualiza,3=inclu,4=altera,5=exclui                                                    	**/
/**----------------------------------------------------------------------------------------------------------------	**/
Static Function montArray(cAlias,nReg,nOpc)
	// indice cabecalho
	Local cCabIndexKey	:= (cAlias)->( IndexKey(2) )
	// indice do item
	Local cItemIndexKey	:= (cAlias)->( IndexKey(1) )
	// contador
	Local nX 			:= ""
	// campo
	Local cCampo		:= ""
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
					if SX3->X3_CONTEXTO <> 'V'
						// adiciona que pode alterar o campo
						Aadd(aEnchAlte,Trim(SX3->X3_CAMPO))
					endif
					// adiciona nos campos que nao exibem na grid
					aadd(aNoFields,Trim(SX3->X3_CAMPO))
				// se nao existe na grid
				Else 
					// se campo real
					if SX3->X3_CONTEXTO <> 'V' 
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
	cQuery += "FROM "+RetSqlName(cAlias)+" "	
	cQuery += "WHERE D_E_L_E_T_<>'*' "	
	cQuery += "AND "+cCabIndexKey+" ='"+ &(cAlias+"->("+cCabIndexKey+")") +"' "
	cQuery += "ORDER BY "+SqlOrder(cItemIndexKey)
	
	// Montagem do aHeader e aCols
	FillGetDados(nOpc,cAlias,1,cSeek,bWhile,{{bCond,{|| .T. },{|| .F. }}},aNoFields,/*aYesFields*/,/*lOnlyYes*/,cQuery,/*bMontCols*/,INCLUI,/*aHeaderAux*/,/*aColsAux*/,/*bafterCols*/,/*bBeforeCols*/,/*bAfterHeader*/,"TMP")
	
Return

/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: screenSize															                        **/
/** DESCRICAO		: calcula os dados da tela.                                                         			**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**	                  				             PARAMETROS     	              		      						**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** nenhum parametro esperado                                                                                    	**/
/**----------------------------------------------------------------------------------------------------------------	**/
Static Function screenSize()
	aSize := MsAdvSize()

	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }

	aPosObj := MsObjSize( aInfo, aObjects )	
Return


/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: regSave															                            **/
/** DESCRICAO		: grava os registros                                                                			**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**	                  				             PARAMETROS     	              		      						**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** cAlias      | tabela                                                                                         	**/
/** nReg        | registro                                                                                       	**/
/** nOpc        | opcao 2=visualiza,3=inclu,4=altera,5=exclui                                                    	**/
/**----------------------------------------------------------------------------------------------------------------	**/
STATIC FUNCTION regSave(cAlias,nReg,nOpc)
	// area
	Local aArea 	:= GetArea()
	// indice dos itens
	Local cIndexKey	:= (cAlias)->( IndexKey(1) )
	// existe o registro
	Local lExiste	:= .F.
	// contador
	Local nY		:= 0
	// contador
	Local nX		:= 0
	// registro
	Local nRecno	:= 0
	// contador
	Local nCont		:= 0
	// certificado para retorno
	Local cCert		:= ""
	
	// atualiza o acols
	aCols			:= oGetDb:aCols
	aHeader			:= oGetDb:aHeader 
	
	// define ordem
	(cAlias)->( dbSetOrder(1) )
	
	Begin Transaction

		// faz loop
		For nY := 1 to Len(aCols)
			// registro atual
			nRecno := aCols[nY][Len(aHeader)]
			// se nao esta deletado
			If !aCols[nY][Len(aHeader)+1]
				// inclui ou altera
				If nOpc == 3 .Or. nOpc == 4
					// se inclui e sem registro
					if nOpc == 3 .or. nRecno == 0
						// procura registro
						lExiste := (cAlias)->( DbSeek( &("M->("+cIndexKey+")") ) )
					// se altera
					Else
						// posiciona no registro
						(cAlias)->( DbGoTo(nRecno) )
						// valida se posicionou no registro certo
						lExiste := (cAlias)->( Recno() ) == nRecno
					Endif
					
					// cria novo
					RecLock( (cAlias), !lExiste )
						
						// grava o campo filial
						FieldPut( FieldPos(cCmpFil), xFilial(cAlias) )
						
						// faz loop no cabecalho
						for nX := 1 to Len(aEnchAlte)
							// campo do cabecalho
							cCampo := aEnchAlte[nX]
							// se nao é flag 
							if cCampo <> "NOUSER"
								// atualiza o campo
								FieldPut( FieldPos(cCampo),&("M->"+cCampo) )
							Endif
						Next
		
						// faz loop no aheader
						For nCont := 1 To Len(aHeader)
							// nao grava campos virtuais
							If (aHeader[nCont][10] != "V" )
								// grava o campo do aheader
								FieldPut(FieldPos(aHeader[nCont][2]),	aCols[nY][GdFieldPos(aHeader[nCont][2])] )
							EndIf
						Next nCont
	
					// destrava o registro
					(cAlias)->( MsUnLock() )
				// Se for exclusao
				Elseif nOpc == 5 
					(cAlias)->( DbGoTo(nRecno) )
					// posiciona no registro
					If (cAlias)->( Recno() ) == nRecno
						// trava a tabela
						RecLock(cAlias,.F.,.T.)
							// deleta registro
							(cAlias)->( dbDelete() )
						// destrava o registro
						(cAlias)->( MsUnLock() )
					EndIf
				EndIf
			// Item deletado na MSGETDB
			Else 
				// se existe o registro
				if nRecno > 0
					// posiciona no registro
					(cAlias)->( DbGoTo(nRecno) )
					// posicionou certo
					if (cAlias)->( Recno() ) == nRecno
						// trava o registro
						RecLock( (cAlias), .f., .t. )
							// deleta o registro
							(cAlias)->( DbDelete() )
						// destrava o registro
						(cAlias)->( MsUnlock() )
					Endif
				Endif
			EndIf
		Next
		
		// se inclui
		if nOpc == 3
			// confirma o codigo
			ConfirmSX8()
		Endif
		
	End Transaction
	
	// restaura area
	RestArea(aArea)
	// retorna
Return cCert

/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: KFATR19B															                            **/
/** DESCRICAO		: Funcao para atualizar as variaveis do certificado                                 			**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**										  CRIACAO / ALTERACOES / MANUTENCOES                       	   			 	**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** Data       	| Desenvolvedor          | Solicitacao         		| Descricao                               		**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** 20/12/2017 	| Luiz Henrique Jacinto  |                          | 												**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**	                  				             PARAMETROS     	              		      						**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** nenhum parametro esperado.                                                                                   	**/
/**----------------------------------------------------------------------------------------------------------------	**/
User Function KFATR19B(cConfig)
	// retorno
	Local lRet		:= .T.
	// cabecalho
	// Local aHead		:= oGetDb:aHeader
	// posicao atual
	// Local nPos		:= 0
	// tam
	Local nTam		:= 0
	
	// configuracao
	Default cConfig	:= &(ReadVar())
	/*
	
	// se inclusao
	If INCLUI .and. ValType(oGetDb) == "O"
		// se nao preenchido
		If Empty( AllTrim( cConfig ) )
			// sai da funcao
			Return lRet
		Endif
		
		oGetDb:GoTop()
		
		// abre a tabela
		Z4V->( DbSetOrder(1) )
		// se nao localizou
		If !Z4V->( DbSeek( xFilial("Z4V")+cConfig) )
			// retorno
			lRet := .F.
			// exibe msg
			MsgStop("Configuração não encontrada.")
			
			Return lRet
		Endif
		
		// faz loop de traz pra frente
		For nPos := Len(oGetDb:aCols) to 1 step -1
			// tamanho do array
			nTam := Len(oGetDb:aCols)
			// apaga a linha do array
			aDel (oGetDb:aCols,nPos  )
			// diminui o array
			aSize(oGetDb:aCols,nTam-1)
		Next
		
		// faz loop nas variaveis
		While !Z4V->( EOF() ) .and. Z4V->Z4V_CODIGO == cConfig
			// adiciona a linha
			oGetDb:AddLine(.F.,.F.)
		
			// linha atual
			nPos := Len(oGetDb:aCols)
			
			// faz loop nas colunas
			For nCol := 1 to Len(aHead)
				// coluna
				cCampo := StrTran(aHead[nCol][2],"Z4X","Z4V")
				// se campo de variavel
				If "Z4V_V" $ cCampo
					// atualiza o valor da coluna
					oGetDb:aCols[nPos][nCol] := &("Z4V->"+cCampo) 
				Endif
			Next
			
			// proximo registro
			Z4V->( DbSkip() )
		Enddo
				
		// adiciona a linha para confirmar a anterior
		oGetDb:AddLine(.F.,.F.)
		
		
		// facilitadores
		For nPos := 1 to Len(oGetDb:aCols)
			
			cVar := AllTrim(GdFieldGet("Z4X_VARIAV",nPos,.f.,aHead,oGetDb:aCols ) )
			
			If "Doc_NF" $ cVar
				GdFieldPut("Z4X_TEXT",M->Z4X_DOCUME,nPos,aHead,oGetDb:aCols)
			Endif
			
			If "Doc_Emissao" $ cVar
				GdFieldPut("Z4X_DATE",M->Z4X_DATA,nPos,aHead,oGetDb:aCols)
			Endif
			
			If "Doc_Certificado" $ cVar
				GdFieldPut("Z4X_TEXT",M->Z4X_CERTIF,nPos,aHead,oGetDb:aCols)
			Endif
			
			If "Doc_Ano" $ cVar
				GdFieldPut("Z4X_TEXT",Substr(DtoS(M->Z4X_DATA),1,4),nPos,aHead,oGetDb:aCols)
			Endif
			
			If "Doc_Referencia" $ cVar
				GdFieldPut("Z4X_TEXT",M->Z4X_MONTA,nPos,aHead,oGetDb:aCols)
			Endif
			
		Next
		
		// atualiza a tela
		oDlg:Refresh()
		// atualiza o getdados
		oGetDb:Refresh()
		// volta pro inicio
		oGetDb:GoTop()
		// vai pro final
		oGetDb:GoBottom()
		// volta pro inicio
		oGetDb:GoTop()
		// atualiza o get dados
		oGetDb:Refresh()
		
	Endif
	*/
	// retorno
Return lRet


/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: KFATR19D															                            **/
/** DESCRICAO		: Funcao para validar se a linha pode ser excluida                                      		**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**	                  				             PARAMETROS     	              		      						**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** nenhum parametro esperado.                                                                                   	**/
/**----------------------------------------------------------------------------------------------------------------	**/
USer Function KFATR19D()
	// se for o automatico permite excluir
	Local lRet := IsInCallStack("U_KFATR19B") 
	
	// retorna
Return lRet


Static Function setFilter(nSet)
	Local aArea 	:= GetArea()
	Local cFilZ4V	:= ""
	
	Default nSet := 0
	
	if nSet == 0
		cFilZ4V := " Z03->Z03_AGLUT == 'S' "
		
	 	DbSelectArea("Z03")
	 	Set Filter to &cFilZ4v
	Else
		DbSelectArea("Z03")
		Set Filter to 
	Endif
	
	RestArea(aArea)
Return

Static Function fieldSize(cCampo)
	// obtem o tamanho do campo
	Local nTam	:= TamSx3(cCampo)[1]
	// valor de retorno
	Local nRet	:= 0

	// se menor que 9
	If nTam < 9 
		// faz o calculo
		nRet := ( 6 * nTam )
		// se menor que 15
	ElseIf nTam < 15
		// faz o calculo
		nRet:=(4.8* nTam )
		// outros
	Else
		// faz o calculo
		nRet:=(4 * nTam )
	EndIf

	// retorna
Return nRet

Static Function canAlter(_cCert)
	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local aAreaZ4X	:= GetArea("Z03")
	
	
	RestArea(aArea)
	RestArea(aAreaZ4X)
Return lRet


Static Function enchoiceFields(cAlias)
	Local aRet 	:= {} 
	Local aArea	:= GetArea()
	
	// aadd(aRet,"NOUSER")
	
	SX3->( DbSetOrder(1))
	If SX3->( MsSeek(cAlias) )
		While !SX3->( EOF() ) .and. SX3->X3_ARQUIVO == cAlias
			If SX3->X3_BROWSE == 'S' .and. x3Uso(SX3->x3_usado) .and. cNivel >= SX3->x3_nivel .and. !'FILIAL' $ SX3->X3_CAMPO
				aadd(aRet,AllTrim(SX3->X3_CAMPO))
			Endif
			SX3->( DbSkip() )
		Enddo
	Endif

	RestArea(aArea)
Return aRet

Static Function validTOk()
	Local lRet	:= .T.
	Local cCampo	:= ""
	Local xValor	:= ""
	Local nFolder	:= 0
	Local cText		:= ""
	Local nX		:= 0
	
	#ifdef ENGLISH
		Local aPos := {"First","Second","Third","Fourth","Fifth","Sixth","Seventh","Eighth","Ninth","Last"}
		Local cFold := "Folder"
	#else
		#ifdef SPANISH
			Local aPos := {"Primera","Segunda","Tercera","Cuarta","Quinta","Sexta","Septima","Octava","Novena","Ultima"}
			Local cFold := "Carpeta"
		#else
			Local aPos := {"Primeira","Segunda","Terceira","Quarta","Quinta","Sexta","Setima","Oitava","Nona","Ultima"}
			Local cFold := "Pasta"
		#endif
	#endif
	
	IF INCLUI .OR. ALTERA
		
		For nX := 1 to Len(aEnchAlte)
			
			cCampo := aEnchAlte[nX]
			
			If X3Obrigat(cCampo)
				
				xValor := &("M->"+cCampo)
				
				If ValType(xValor) == "C"
					xValor := AllTrim(xValor)
				Endif
				
				lRet := !Empty(xValor)
				
			Endif
			
			If !lRet
				
				nFolder	:= Val(GetSx3Cache( cCampo, 'X3_FOLDER' ))
				
				cText := cCampo+" -> '"+AllTrim( RetTitle( cCampo ) )+"'"
				
				If nFolder > 0
					cText += " -> "+aPos[nFolder]+" "+cFold	
				Endif
				
				Help(1," ","OBRIGAT",,cText,5,0)
				
				Exit
			Endif
		Next
	Endif
	
Return lRet


