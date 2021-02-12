
/** FINALIDADE	: Funcoes genericas para criacao de tela com listbox                              										**/
/** RESPONSAVEL	: RSAC Solucoes          																																							**/
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"

#Define ENTER CHR(13)+CHR(10)

/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: dialogListBox														                            **/
/** DESCRICAO		: funcao generica para exibir uma listbox a partir de uma query ou de array de campos/dados		**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**                                      CRIACAO / ALTERACOES / MANUTENCOES                       	   				**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** Data       	| Desenvolvedor          | Solicitacao         	  | Descricao                             			**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** 19/03/2018 	| Luiz Henrique Jacinto  |                        |   												**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**	                                               PARAMETROS                                                     	**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** _cTitulo    | tiulo da tela                                                                                 	**/
/** _cCampos    | campos do sql                                                                                 	**/
/** _cSelect    | select do sql                                                                                 	**/
/** _cFrom      | from do sql                                                                                   	**/
/** lHasMark    | possui check box                                                                              	**/
/** aDados      | array com os dados a serem exibidos                                                           	**/
/** _aCampos    | array com os campos a serem exibidos                                                          	**/
/** cLDblClick  | funcao executada no duploclick                                                                	**/
/** lMax        | maximiza o dialog                                                                             	**/
/** lHasOk      | possui ok?                                                                                    	**/
/**----------------------------------------------------------------------------------------------------------------	**/
Static function dialogListBox(_cTitulo,_cCampos,_cSelect,_cFrom,lHasMark,aDados,_aCampos,cLDblClick,lMax,_lHasOk)
	// area
	Local	aArea		:= GetArea()
	// retorno
	Local	lRet		:= .F.
	// array com o retorno dos selecionados
	Local	aRet		:= {}
	// funcao botao ok
	Local 	bOkb 		:= {|| lRet:=.T.,oDlgAux:End() }
	// funcao cancelar
	Local 	bCancel 	:= {|| oDlgAux:End() }
	// msg ao deletar
	Local 	lMsgDel		:= .F.
	// botoes
	Local 	aButtons	:= {}
	// registro
	Local 	nRecno 		:= Nil
	// alias
	Local 	cAlias		:= Nil
	// exibe mashups
	Local 	lMashups	:= .F.
	// imprime padrao
	Local 	lImpCad		:= .F.
	// botoes padra
	Local 	lPadrao		:= .F.
	// exibe botao ok
	Local 	lHasOk		:= .F.
	// exibe walk
	Local 	lWalkThru	:= .F.
	// posicao da linha
	Local 	nLinha		:= 035
	// alias temporario
	Local 	cTemp		:= GetNextAlias()
	// query
	Local 	cQuery 		:= ""
	// contador
	Local 	nX			:= 0
	// cabecalho
	Local 	aLbxHead	:= {}
	// tamanho das colunas
	Local 	aLbxTam		:= {}
	// colunas
	Local 	aLbxCols	:= {}
	// campo
	Local 	cCampo		:= ""
	// campos usados
	Local 	cCampos		:= ""
	// array com os capos
	Local 	aCampos		:= {}
	// item temporario
	Local 	aItem		:= {}
	// bitmap Ok
	Local	oOk			:= LoadBitmap( GetResources(), "LBOK" )
	// bitmap No
	Local	oNo			:= LoadBitmap( GetResources(), "LBNO" )
	// executa elect
	Local	lSelect		:= .F.
	// tamanho da tela
	Local 	aSize		:= {}
	// tamanho dos objetos
	Local	aObj		:= {}
	// posicao dos objetos em tela
	Local	aPObj		:= {}
	// tamanho da tela
	Local	aTTela		:= {}
	Local	lMontaQuery	:= .F.
		
	// valor iniciais de campos
	Default _cCampos	:= ""
	// valor iniciais de campos
	Default _cFrom		:= ""
	// valor iniciais de campos
	Default _cSelect	:= "SELECT "
	// valor iniciais de campos
	Default lHasMark	:= .F.
	// valor iniciais de campos
	Default aDados		:= {}
	// valor iniciais de campos
	Default _aCampos	:= {}
	// valor iniciais de campos
	Default cLDblClick	:= ""
	// valor iniciais de campos
	Default lMax		:= .T.
	Default _lHasOk		:= nil
	
	// bitmap Ok
	oOk	:= LoadBitmap( GetResources(), "LBOK" )
	// bitmap No
	oNo	:= LoadBitmap( GetResources(), "LBNO" )
	
	// adiciona o objeto em tela
	AAdd( aObj, { 100, 100, .T., .T. } )
	
	// valida campos necessarios
	If (MycVazio(_cCampos) .or. MycVazio(_cFrom)) .and. Empty(aDados)
		// retorna
		Return aRet
	Endif 
	
	// verifica se usa o select
	lSelect		:= !MycVazio(_cSelect)

	// obtem os campos
	cCampos	:= _cCampos
	// separa os campos
	aItem	:= Separa(cCampos,",")
	
	// se usa select
	If lSelect 
		lMontaQuery := _cSelect == "SELECT "
		cQuery 		+= _cSelect+" "+ENTER
	Endif
	
	// variavel dados da linha
	bLine		:= "{|| { "
	
	// se com marcacao e usa select
	If lHasMark .and. lSelect 

		// adiciona o marcado no array de campos
		aadd(aCampos	,{"MARK","L"})
		// adiciona o titulo
		aadd(aLbxHead	," ")
		// adiciona o tamanho do campo
		aadd(aLbxTam	,fieldSize( "C9_OK" ) )
		if lMontaQuery
			// adiciona campo na query
			cQuery += "'F' MARK"
		Endif
		
		// exibe botao de ok
		lHasOk	:= .T. 

		// adiciona o campo na linha
		bLine += "iif(aLbxCols[oLbxObj:nAt]["+cValToChar(1)+"], oOk, oNo)"
		
	Endif
	
	If ValType(_lHasOk) == "L" .and. !lHasMark
		lHasOk := .T.
	Endif
	
	// se nao informou os campos
	If Empty(_aCampos)
		// abre a tabela
		SX3->( DbSetOrder(2) )
		// faz loop nos campos
		For nX := 1 to Len(aItem)
			
			// nome do campo
			cCampo := aItem[nX]
			
			// localiza o campo
			If SX3->( MsSeek(cCampo) )
			
				// adiciona o titulo no cabecalho
				aadd(aLbxHead	,AllTrim( X3Titulo() )		)
				// adicioan o tamanho do campo
				aadd(aLbxTam	,fieldSize(SX3->X3_CAMPO) 	)
				// adiciona o campo no array de campos usados 
				aadd(aCampos	,{cCampo,SX3->X3_TIPO}		)
				
				// se ja existe cabecalho
				If Len(aLbxHead) > 1
					// se usa select
					If lSelect .and. lMontaQuery
						// adiciona dados do select
						cQuery 	+= "	,"
					Endif
					// adiciona dados do select
					bLine	+= ", "
				// se nao existe cabeccalho
				else
					// se usa select
					If lSelect .and. lMontaQuery
						// adiciona dados do select
						cQuery 	+= " "
					Endif
					// adiciona dados do select
					bLine	+= " "
				Endif
				
				// se usa select
				If lSelect .and. lMontaQuery
					// monta query
					cQuery += cCampo+" "+ENTER
				Endif
				
				If SX3->X3_TIPO == "N"
					bLine += "Transform(
				Endif
				// adiciona o campo na linha
				bLine += "aLbxCols[oLbxObj:nAt]"
				
				// se existe mais de um campo a exibir
				If Len(aItem) > 1
					// adiciona a coluna
					bLine += "["+cValToChar(Len(aLbxHead))+"]"
				Endif
				
				If SX3->X3_TIPO == "N"
					bLine += ",'"+SX3->X3_PICTURE+"')
				Endif
			Else
				If "REGNO" $ cCampo
					// adiciona o titulo no cabecalho
					aadd(aLbxHead	,"RECNO"	)
					// adicioan o tamanho do campo
					aadd(aLbxTam	,10			)
					// adiciona o campo no array de campos usados 
					aadd(aCampos	,{cCampo,"N"})
				
					// se ja existe cabecalho
					If Len(aLbxHead) > 1
						// se usa select
						If lSelect .and. lMontaQuery
							// adiciona dados do select
							cQuery 	+= "	,"
						Endif
						// adiciona dados do select
						bLine	+= ", "
					// se nao existe cabeccalho
					else
						// se usa select
						If lSelect .and. lMontaQuery
							// adiciona dados do select
							cQuery 	+= " "
						Endif
						// adiciona dados do select
						bLine	+= " "
					Endif
					
					// se usa select
					If lSelect .and. lMontaQuery
						// monta query
						cQuery += cCampo+" "+ENTER
					Endif
					
					// adiciona o campo na linha
					bLine += "aLbxCols[oLbxObj:nAt]"
					
					// se existe mais de um campo a exibir
					If Len(aItem) > 1
						// adiciona a coluna
						bLine += "["+cValToChar(Len(aLbxHead))+"]"
					Endif
					
				Endif
			Endif
		Next
	// se informou os campos
	Else
		
		// faz loop nos campos
		For nX := 1 to Len(_aCampos)
			
			// adiciona cabecalho
			aadd(aLbxHead	,AllTrim( _aCampos[nX][2] )	)
			// adiciona o tamanho
			aadd(aLbxTam	, _aCampos[nX][3] )
			// adiciona no array de campos 
			aadd(aCampos	,{_aCampos[nX][1],_aCampos[nX][5]})
			
			// se ja existe cabecalho
			If Len(aLbxHead) > 1
				// se usa select
				If lSelect
					// adiciona ao select
					cQuery 	+= "	,"
				Endif
				// adiciona a linha
				bLine	+= ", "
			// se nao existe cabecalho
			else
				// se usa select
				If lSelect
					// adiciona ao select
					cQuery 	+= " "
				Endif
				// adiciona a linha
				bLine	+= " "
			Endif
			// se usa select
			If lSelect
				// adiciona o campo ao select
				cQuery += _aCampos[nX][1]+" "+ENTER
			Endif
			
			// se usa marcacao e primeiro registro
			If lHasMark .and. nX == 1
				// exibe botao de ok
				lHasOk	:= .T. 
		
				// adiciona o campo na linha
				bLine += "iif(aLbxCols[oLbxObj:nAt]["+cValToChar(nX)+"], oOk, oNo)"
			// se nao usa marcacao
			Else
				// adiciona o campo na linha
				bLine += "aLbxCols[oLbxObj:nAt]"
				// se mais de uma coluna
				If Len(_aCampos) > 1
					// adiciona a coluna
					bLine += "["+cValToChar(Len(aLbxHead))+"]"
				Endif
			Endif
			
		Next
		
	Endif
	
	// fecha a linha
	bLine 	+= "}} "
	// se usa select
	If lSelect
		// adiciona dados a query
		cQuery 	+= " "+ENTER
		// adiciona dados a query
		cQuery 	+= _cFrom
		
		// fecha a area
		StaticCall(QUERY,MyClose,cTemp)
		
		// executa a query
		TcQuery cQuery New Alias (cTemp)
	
		// faz loop nos campos
		For nX := 1 to Len(aCampos)
			If aCampos[nX][2] $ "D/L"  
				// converte os campos para o tipo protheus 
				TCSetField((cTemp),aCampos[nX][1],aCampos[nX][2],)
			Endif
		Next
		
		// faz loop nos dados da query
		While  !(cTemp)->( EOF() )
			// zera array de item
			aItem := {}
			// faz loop nos campos
			For nX := 1 to Len(aCampos)
				If !"REGNO" $ aCampos[nX][1]
					// adiciona o campo ao item
					aadd(aItem, &(cTemp+"->"+aCampos[nX][1] ) )
				Else
					// adiciona o campo ao item
					aadd(aItem, &(cTemp+"->REGNO" ) )
				Endif
			Next
			// adiciona o item ao array do listbox
			aadd(aLbxCols,aItem)
			// proximo registro
			(cTemp)->( DbSkip() )
		Enddo
		
		// fecha a area
		StaticCall(QUERY,MyClose,cTemp)
	// se recebeu os dados
	Else
		// adiciona os dados ao listbox
		aLbxCols := aClone(aDados)
	Endif
	
	// se nao retornou dados
	If Empty(aLbxCols)
		// exibe msg
		MsgInfo("Não foram contrados registros para exibição.")
	// se obteve algo no listbox
	Else
		// obtem tamanho da tela
		aTTela 	:= screenSize(aObj)
		// tamanho da tela
		aSize 	:= aTTela[1]
		// posicao do ojeto
		aPObj	:= aTTela[3]

		// se maximizado
		If lMax
			// monta dialog
			DEFINE MSDIALOG oDlgAux TITLE _cTitulo From aSize[7],0 to aSize[6],aSize[5] pixel
			// monta o listbox
			@ aPObj[1,1],aPObj[1,2] ListBox oLbxObj Fields size aPObj[1,4]-aPObj[1,2],aPObj[1,3]-aPObj[1,1] of oDlgAux pixel
		
		// se nao maximizado
		Else
			
			// monta dialog
			DEFINE MSDIALOG oDlgAux TITLE _cTitulo From 0,0 to 340,970 pixel
			// define o listbox 
			@ nLinha,004 ListBox oLbxObj Fields size 475,130 of oDlgAux pixel
		Endif
		
		// define o array
		oLbxObj:SetArray(aLbxCols)
		// vai pro inicio
		oLbxObj:nAt 			:= 1
		// cabecalho
		oLbxObj:aHeaders 		:= aLbxHead
		// tamanho colunas
		oLbxObj:aColSizes		:= aLbxTam
		// dados da linha
		oLbxObj:bLine 			:= &bLine
		oLbxObj:lAdjustColSize	:= .T.	
		
		// se possui marca
		If lHasMark
			// seleciona registro
			oLbxObj:bLDblClick 		:= {|| SelLibx(oLbxObj,aLbxCols,.F.) }
			// seleciona todos os registros
			oLbxObj:bHeaderClick	:= {|| SelLibx(oLbxObj,aLbxCols,.T.) }
		ElseIf !MycVazio(cLDblClick)
			// seleciona registro
			oLbxObj:bLDblClick 		:= &cLDblClick
		Endif
		
		// ativa a tela
		ACTIVATE MSDIALOG oDlgAux Centered ON INIT EnchoiceBar( oDlgAux ,bOkb,bCancel,lMsgDel,aButtons,nRecno,cAlias,lMashups,lImpCad,lPadrao,lHasOk,lWalkThru)
	Endif
	
	// se deu ok
	If lRet 
		If lHasMark
			// faz loop nos dados do array
			For nX := 1 to Len(aLbxCols)
				// se marcado
				If aLbxCols[nX][1]
					// adiciona ao array de retorno
					aadd(aRet,aLbxCols[nX])
				Endif
			Next
		Else
			aRet := aLbxCols
		Endif
	Endif
	
	// restaura a area
	RestArea(aArea)
	// retorna os selecionados
Return aRet

/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: SelLibx															                            **/
/** DESCRICAO		: funcao generica para exibir uma listbox a partir de uma query ou de array de campos/dados		**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**                                      CRIACAO / ALTERACOES / MANUTENCOES                       	   				**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** Data       	| Desenvolvedor          | Solicitacao         	  | Descricao                             			**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** 19/03/2018 	| Luiz Henrique Jacinto  |                        |   												**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**	                                               PARAMETROS                                                     	**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** oLibx       | objeto do listbox                                                                             	**/
/** aColsLibx   | dados do listbox                                                                              	**/
/** lTodos      | marca todos                                                                                   	**/
/** cValid   	| validador se pode marcar                                                                      	**/
/**----------------------------------------------------------------------------------------------------------------	**/
static function SelLibx(oLibx,aColsLibx,lTodos,cValid)
	// inverte a marca da linha atual
	Local lMarca 	:= !aColsLibx[oLibx:nAt][1]
	// contador
	local nX 		:= 0
	// pode fazer a marca
	Local lFazMarca	:= .T.
	
	// validacao padrao
	Default cValid	:= ""
	
	// se nao marca todos
	If !lTodos
		// se valid preenchido
		If !MycVazio(cValid)
			// valida se pode marcar
			lFazMarca := &cValid
		Endif
		// se pode marcar
		If lFazMarca
			// atualiza a marca
			aColsLibx[oLibx:nAt][1] := !aColsLibx[oLibx:nAt][1]
		endif
	// se marca todos
	Else
		// faz loop nos dados
		For nX := 1 to Len(aColsLibx)
			// se valid preenchido
			If !MycVazio(cValid)
				// valida se pode marcar
				lFazMarca := &cValid
			Endif
			// se pode marcar
			If lFazMarca
				// atualiza a marca
				aColsLibx[nX][1] := lMarca
			endif
		Next
	Endif
	
	// atualiza o objeto do listbox
	oLibx:refresh()
	// retorna
Return


/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: fieldSize															                            **/
/** DESCRICAO		: retorna o tamanho do get do campo                                                             **/
/**----------------------------------------------------------------------------------------------------------------	**/
/**                                      CRIACAO / ALTERACOES / MANUTENCOES                       	   				**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** Data       	| Desenvolvedor          | Solicitacao         	  | Descricao                             			**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** 19/03/2018 	| Luiz Henrique Jacinto  |                        |   												**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**	                                               PARAMETROS                                                     	**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** cCampo      | nome do campo na SX3                                                                          	**/
/**----------------------------------------------------------------------------------------------------------------	**/
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
		nRet:=(3.5 * nTam )
	EndIf

	// retorna
Return nRet

/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: screenSize														                            **/
/** DESCRICAO		: calcula o tamanho da tela e posicao dos objetos.                                         		**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**                                      CRIACAO / ALTERACOES / MANUTENCOES                       	   				**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** Data       	| Desenvolvedor          | Solicitacao         	  | Descricao                             			**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** 19/03/2018 	| Luiz Henrique Jacinto  |                        |   												**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**	                                               PARAMETROS                                                     	**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** _aObjects	| tamanho dos objetos                                                                              	**/
/**----------------------------------------------------------------------------------------------------------------	**/
Static Function screenSize(_aObjects)
	// tamanho da tela
	Local aSize	:= MsAdvSize()
	// dados da tela
	Local aInfo	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	// array de retorno
	Local aRet	:= {}
	// posicao calculada dos objetos
	Local aPObj	:= {}
	
	// valor inicial
	Default _aObjects := {}
	
	// se recebeu algo
	If !Empty(_aObjects)
		// calcula a posicao dos objetos
		aPObj := MsObjSize( aInfo, _aObjects )	
	endif
	
	// adiciona o tamanho da tela ao retorno
	aadd(aRet,aSize)
	// adiciona a informacao da tela ao retorno
	aadd(aRet,aInfo)
	// adiciona a posicao dos objetos ao retorno
	aadd(aRet,aPObj)
	
	// retorna
Return aRet

/**----------------------------------------------------------------------------------------------------------------	**/
/** NOME DA FUNCAO	: MycVazio														                 	          	**/
/** DESCRICAO		: valida se o campo char esta vazio com alltrim                                             	**/
/**----------------------------------------------------------------------------------------------------------------	**/
/**	                                               PARAMETROS                                                     	**/
/**----------------------------------------------------------------------------------------------------------------	**/
/** cValor      	| valor a ser validado                                                                         	**/
/**----------------------------------------------------------------------------------------------------------------	**/
Static Function MycVazio(xValor)
	// retorno
	Local lRet 	:= .F.
	// tipo do valor recebido
	Local cTipo	:= ValType(xValor) 
	
	// se tipo diferente de char
	If cTipo == "U"
		// retorna vazio
		lRet := .T.
	// outros tipos
	ElseIf cTipo <> "U" .and. cTipo <> "C"
		// valida vazio
		lRet := Empty(xValor)
	// se char
	Else
		// valida vazio
		lRet := Empty( AllTrim( xValor ) )
	Endif
	
	//retorna
return lRet


Static Function CampoCabecalho(cCampo,cTitulo,nTam)
	Local aItem 	:= {}
	Local aTam 		:= TamSx3(cCampo)

	Default cTitulo	:= RetTitle(cCampo)
	Default nTam	:= fieldSize(cCampo)

	aadd(aItem,cCampo	) // 1 campo
	aadd(aItem,cTitulo	) // 2 titulo
	aadd(aItem,nTam		) // 3 tamanho
	aadd(aItem,aTam[2]	) // 4 decimal
	aadd(aItem,aTam[3]	) // 5 tipo

Return aItem

Static Function QueryDados(cQuery,aCampos)
	Local aArea	:= GetArea()
	Local nX	:= 0
	Local aRet	:= {}
	Local aItem	:= {}
	Local cTemp	:= GetNextAlias()

	StaticCall(MYQUERY,MyClose,cTemp)

	TcQuery cQuery New Alias (cTemp)

	// faz loop nos campos
	For nX := 1 to Len(aCampos)
		If aCampos[nX][5] $ "D/L"  
			// converte os campos para o tipo protheus 
			TCSetField((cTemp),aCampos[nX][1],aCampos[nX][5],)
		Endif
	Next

	// faz loop nos dados da query
	While  !(cTemp)->( EOF() )
		// zera array de item
		aItem := {}
		// faz loop nos campos
		For nX := 1 to Len(aCampos)
			If !"REGNO" $ aCampos[nX][1]
				// adiciona o campo ao item
				aadd(aItem, &(cTemp+"->"+aCampos[nX][1] ) )
			Else
				// adiciona o campo ao item
				aadd(aItem, &(cTemp+"->REGNO" ) )
			Endif
		Next
		// adiciona o item ao array do listbox
		aadd(aRet,aItem)
		// proximo registro
		(cTemp)->( DbSkip() )
	Enddo
	
	// fecha a area
	StaticCall(QUERY,MyClose,cTemp)

	RestArea(aArea)
Return aRet
