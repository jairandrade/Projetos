#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Reimpressão de Etiquetas "

/*/{Protheus.doc} ACD001
Reimpressão de Etiquetas do ACD
@author Thiago Berna
@since 25/Março/2020
@version 1.0
@return Nil, Função não tem retorno
/*/

User Function ACD001()
	Local aArea   	:= GetArea()
	Local aColunas	:= {}
	Local aSeek		:= {}
	Local aIndex	:= {}
	Local aCmpTrab	:= {}
	Local aPesq		:= {}
	Local aStruct	:= {}
	Local cQuery	:= ""
	Local cAlias	:= GetNextAlias()
	Local cMarca	:= PadR(GetMark(),4)
	Local cPerg		:= 'ACD001'
	Local cPergA	:= 'ACD001A'		//Imprimir etiqueta de Produto
	Local cPergB	:= 'ACD001B'		//Imprimir etiqueta de Pallet
	Local nX		:= 0
	
	Private oMark		:= Nil
	Private oAliasCB0	:= Nil
	Private aRotina 	:= MenuDef()
	Private cTipo		:= ''

	//Se ja existe excluir
	If oAliasCB0 <> Nil
		oAliasCB0:Delete()
		oAliasCB0 := Nil
	EndIf

	//Cria tabela temporaria
	oAliasCB0 := FwTemporaryTable():New(cAlias)

	If Pergunte(cPerg, .T.)	
		If MV_PAR01 == 1
			cTipo := 'PRODUTO'
			
			If Pergunte(cPergA, .T.)
				aCmpTrab	:= {"CB0_FILIAL","CB0_DTNASC","CB0_CODPRO","CB0_NFENT","CB0_SERIEE","CB0_OP","CB0_LOCAL","CB0_LOTE","CB0_LOCALI","CB0_QTDE","CB0_CODETI","CB0_CODET2"}

				For nX := 1 To Len(aCmpTrab)
					aAdd(aColunas,FWBrwColumn():New())
					aColunas[Len(aColunas)]:SetTitle(RTrim(GetSx3Cache(aCmpTrab[nX],"X3_TITULO")))
					aColunas[Len(aColunas)]:SetData(&("{||" + aCmpTrab[nX] + "}"))
					aColunas[Len(aColunas)]:SetSize(GetSx3Cache(aCmpTrab[nX],"X3_TAMANHO"))
					aColunas[Len(aColunas)]:SetType(GetSx3Cache(aCmpTrab[nX],"X3_TIPO"))
					aColunas[Len(aColunas)]:SetDecimal(GetSx3Cache(aCmpTrab[nX],"X3_DECIMAL"))
					aColunas[Len(aColunas)]:SetPicture(GetSx3Cache(aCmpTrab[nX],"X3_PICTURE"))
					aColunas[Len(aColunas)]:SetAlign( IIf(GetSx3Cache(aCmpTrab[nX],"X3_TIPO") == "N","RIGHT","LEFT"))
				Next nX

				//Adiciona Coluna CB0_OK
				aAdd(aColunas,FWBrwColumn():New())
				aColunas[Len(aColunas)]:SetTitle("")
				aColunas[Len(aColunas)]:SetData(&("{|| CB0_OK }"))
				aColunas[Len(aColunas)]:SetSize(4)
				aColunas[Len(aColunas)]:SetType("C")
				aColunas[Len(aColunas)]:SetDecimal(0)
				aColunas[Len(aColunas)]:SetPicture("")
				aColunas[Len(aColunas)]:SetAlign("LEFT")

				//Cria a estrutura do alias temporario
				aStruct	:= CB0->(DBStruct())
				Aadd(aStruct, {"CB0_OK", "C", 4, 0})	 //Adiciono o campo de marca
				oAliasCB0:SetFields(aStruct)

				//Cria indices da tabela temporaria
				oAliasCB0:AddIndex("1", {"CB0_CODPRO"})
				oAliasCB0:AddIndex("2", {"CB0_NFENT"})
				oAliasCB0:AddIndex("3", {"CB0_OP"})
				oAliasCB0:AddIndex("4", {"CB0_LOTE"})
				oAliasCB0:AddIndex("5", {"CB0_LOCAL"})

				//Cria tabela temporaria
				oAliasCB0:Create()

				//Array para pesquisa na tela
				Aadd(aPesq, {AllTrim(RetTitle("CB0_CODPRO"))	, {{"CB0", "C", TamSX3("CB0_CODPRO")[1]	, 0, AllTrim(RetTitle("CB0_CODPRO")), "@!"}}, 1})
				Aadd(aPesq, {AllTrim(RetTitle("CB0_NFENT"))		, {{"CB0", "C", TamSX3("CB0_NFENT")[1]	, 0, AllTrim(RetTitle("CB0_NFENT"))	, "@!"}}, 1})
				Aadd(aPesq, {AllTrim(RetTitle("CB0_OP"))		, {{"CB0", "C", TamSX3("CB0_OP")[1]		, 0, AllTrim(RetTitle("CB0_OP"))	, "@!"}}, 1})
				Aadd(aPesq, {AllTrim(RetTitle("CB0_LOTE"))		, {{"CB0", "C", TamSX3("CB0_LOTE")[1]	, 0, AllTrim(RetTitle("CB0_LOTE"))	, "@!"}}, 1})
				Aadd(aPesq, {AllTrim(RetTitle("CB0_LOCAL"))		, {{"CB0", "C", TamSX3("CB0_LOCAL")[1]	, 0, AllTrim(RetTitle("CB0_LOCAL"))	, "@!"}}, 1})
								
				cQuery := "SELECT CB0.CB0_FILIAL,SUBSTR(CB0.CB0_DTNASC,7,2)||'/'||SUBSTR(CB0.CB0_DTNASC,5,2)||'/'||SUBSTR(CB0.CB0_DTNASC,1,4) AS CB0_DTNASC, CB0.CB0_CODPRO, CB0.CB0_NFENT, CB0.CB0_SERIEE, CB0.CB0_OP, CB0.CB0_LOCAL, CB0.CB0_LOTE, CB0.CB0_LOCALI, CB0.CB0_QTDE, CB0.CB0_CODETI, CB0.CB0_CODET2, '    ' AS CB0_OK "
				cQuery += "FROM " + RetSqlTab("CB0")
				cQuery += "WHERE CB0.CB0_FILIAL = '" + xFilial("CB0") + "' "
				cQuery += "AND CB0.CB0_CODPRO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
				cQuery += "AND CB0.CB0_NFENT  BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR05 + "' "
				cQuery += "AND CB0.CB0_SERIEE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "' "
				cQuery += "AND CB0.CB0_OP     BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
				//#TB20200529 Thiago Berna - Incluido parametros de armazém e lote
				cQuery += "AND CB0.CB0_LOTE   BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
				cQuery += "AND CB0.CB0_LOCAL  BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
				cQuery += "AND CB0.D_E_L_E_T_ = ' '  "

				cQuery := ChangeQuery(cQuery)

				//Carrega arquivo temporario
				Processa({|| SqlToTrb(cQuery, aStruct, cAlias)})
				
				//Instânciando FWMarkBrowse
				oMark := FWMarkBrowse():New()

				//Seleciona todos registros
				oMark:lInvert := .T.
				
				//Setando o alias
				oMark:SetAlias( cAlias )

				//Define array de pesquisa
				oMark:SetSeek(.T., aPesq)	
				
				//Setando as colunas
				oMark:SetColumns(aColunas)

				//Setando o campo de marcacao
				oMark:SetFieldMark( 'CB0_OK' )
				
				//Setando a descrição da rotina
				oMark:SetDescription(cTitulo)

				//Setando O MENUDEF
				oMark:SetMenuDef('MADERO_ACD001')
				
				//Setando a utilizacao de filtros
				oMark:SetUseFilter(.F.)

				//Define como temporario
				oMark:SetTemporary(.T.)
			
				//Setando a fucao para marcar todos
				oMark:SetAllMark( { || oMark:AllMark() } )

				//Ativa a Browse
				oMark:Activate()
			EndIf
		Else
			cTipo := 'PALLET'
			
			aCmpTrab	:= {"CB0_FILIAL","CB0_PALLET","CB0_CODPRO","CB0_NFENT","CB0_SERIEE","CB0_OP","CB0_LOCAL","CB0_LOTE","CB0_LOCALI","CB0_QTDE","CB0_CODETI","CB0_CODET2"}

			For nX := 1 To Len(aCmpTrab)
				aAdd(aColunas,FWBrwColumn():New())
				aColunas[Len(aColunas)]:SetTitle(RTrim(GetSx3Cache(aCmpTrab[nX],"X3_TITULO")))
				aColunas[Len(aColunas)]:SetData(&("{||" + aCmpTrab[nX] + "}"))
				aColunas[Len(aColunas)]:SetSize(GetSx3Cache(aCmpTrab[nX],"X3_TAMANHO"))
				aColunas[Len(aColunas)]:SetType(GetSx3Cache(aCmpTrab[nX],"X3_TIPO"))
				aColunas[Len(aColunas)]:SetDecimal(GetSx3Cache(aCmpTrab[nX],"X3_DECIMAL"))
				aColunas[Len(aColunas)]:SetPicture(GetSx3Cache(aCmpTrab[nX],"X3_PICTURE"))
				aColunas[Len(aColunas)]:SetAlign( IIf(GetSx3Cache(aCmpTrab[nX],"X3_TIPO") == "N","RIGHT","LEFT"))
			Next nX

			//Adiciona Coluna CB0_OK
			aAdd(aColunas,FWBrwColumn():New())
			aColunas[Len(aColunas)]:SetTitle("")
			aColunas[Len(aColunas)]:SetData(&("{|| CB0_OK }"))
			aColunas[Len(aColunas)]:SetSize(4)
			aColunas[Len(aColunas)]:SetType("C")
			aColunas[Len(aColunas)]:SetDecimal(0)
			aColunas[Len(aColunas)]:SetPicture("")
			aColunas[Len(aColunas)]:SetAlign("LEFT")

			//Cria a estrutura do alias temporario
			aStruct	:= CB0->(DBStruct())
			Aadd(aStruct, {"CB0_OK", "C", 4, 0})	 //Adiciono o campo de marca
			oAliasCB0:SetFields(aStruct)

			//Cria indices da tabela temporaria
			oAliasCB0:AddIndex("1", {"CB0_CODPRO"})
			oAliasCB0:AddIndex("2", {"CB0_NFENT"})
			oAliasCB0:AddIndex("3", {"CB0_OP"})
			oAliasCB0:AddIndex("4", {"CB0_LOTE"})
			oAliasCB0:AddIndex("5", {"CB0_LOCAL"})
			oAliasCB0:AddIndex("6", {"CB0_PALLET"})

			//Cria tabela temporaria
			oAliasCB0:Create()

			//Array para pesquisa na tela
			Aadd(aPesq, {AllTrim(RetTitle("CB0_CODPRO"))	, {{"CB0", "C", TamSX3("CB0_CODPRO")[1]	, 0, AllTrim(RetTitle("CB0_CODPRO")), "@!"}}, 1})
			Aadd(aPesq, {AllTrim(RetTitle("CB0_NFENT"))		, {{"CB0", "C", TamSX3("CB0_NFENT")[1]	, 0, AllTrim(RetTitle("CB0_NFENT"))	, "@!"}}, 1})
			Aadd(aPesq, {AllTrim(RetTitle("CB0_OP"))		, {{"CB0", "C", TamSX3("CB0_OP")[1]		, 0, AllTrim(RetTitle("CB0_OP"))	, "@!"}}, 1})
			Aadd(aPesq, {AllTrim(RetTitle("CB0_LOTE"))		, {{"CB0", "C", TamSX3("CB0_LOTE")[1]	, 0, AllTrim(RetTitle("CB0_LOTE"))	, "@!"}}, 1})
			Aadd(aPesq, {AllTrim(RetTitle("CB0_LOCAL"))		, {{"CB0", "C", TamSX3("CB0_LOCAL")[1]	, 0, AllTrim(RetTitle("CB0_LOCAL"))	, "@!"}}, 1})
			Aadd(aPesq, {AllTrim(RetTitle("CB0_PALLET"))	, {{"CB0", "C", TamSX3("CB0_PALLET")[1]	, 0, AllTrim(RetTitle("CB0_PALLET")), "@!"}}, 1})
			
			cQuery := "SELECT CB0.CB0_FILIAL, CB0.CB0_PALLET, CB0.CB0_CODPRO, CB0.CB0_NFENT, CB0.CB0_SERIEE, CB0.CB0_OP, CB0.CB0_LOCAL, CB0.CB0_LOTE, CB0.CB0_LOCALI, CB0.CB0_QTDE, CB0.CB0_CODETI, CB0.CB0_CODET2, '    ' AS CB0_OK "
			cQuery += "FROM " + RetSqlTab("CB0")
			cQuery += "WHERE CB0.CB0_FILIAL = '" + xFilial("CB0") + "' "
			cQuery += "AND CB0.CB0_PALLET <> ' ' "
			cQuery += "AND CB0.CB0_QTDE > 0 "
			cQuery += "AND CB0.CB0_STATUS <> '1' "
			cQuery += "AND CB0.D_E_L_E_T_ = ' '  "

			cQuery := ChangeQuery(cQuery)

			//Carrega arquivo temporario
			Processa({|| SqlToTrb(cQuery, aStruct, cAlias)})
				
			//Instânciando FWMarkBrowse
			oMark := FWMarkBrowse():New()
				
			//Setando o alias
			oMark:SetAlias( cAlias )

			//Define array de pesquisa
			oMark:SetSeek(.T., aPesq)		
				
			//Setando as colunas
			oMark:SetColumns(aColunas)

			//Setando o campo de marcacao
			oMark:SetFieldMark( 'CB0_OK' )
				
			//Setando a descrição da rotina
			oMark:SetDescription(cTitulo)

			//Setando O MENUDEF
			oMark:SetMenuDef('MADERO_ACD001')
				
			//Setando a utilizacao de filtros
			oMark:SetUseFilter(.F.)
				
			//Define como temporario
			oMark:SetTemporary(.T.)
			
			//Setando a fucao para marcar todos
			oMark:SetAllMark( { || oMark:AllMark() } )

			//Setando o retorno do clique duplo
			oMark:SetAfterMark( { || MarkValid(), oMark:GoTop(.T.) } )

			//Ativa a Browse
			oMark:Activate()
		EndIf
	EndIf

	RestArea(aArea)
Return Nil

/*---------------------------------------------------------------------*
| Func:  MenuDef                                                      |
| Autor: Thiago Berna                                                 |
| Data:  25/Março/2020                                                |
| Desc:  Criação do menu MVC                                          |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function MenuDef()
	Local aRot 		:= {}
	
	//Adicionando opções	
	ADD OPTION aRot TITLE 'Imprimir'	ACTION 'Processa( {|| U_AC001pro() }, "Aguarde...","Imprimindo Etiquetas...")'	OPERATION MODEL_OPERATION_UPDATE   ACCESS 0 //OPERATION 1
Return aRot

/*---------------------------------------------------------------------*
| Func:  AC001pro                                                     |
| Autor: Thiago Berna                                                 |
| Data:  25/Março/2020                                                |
| Desc:  Processamento da rotina                                      |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/
User Function AC001Pro()
	Local aArea     := GetArea()
	Local aPallets	:= {}
	Local cAliasBrw	:= oAliasCB0:oStruct:cAlias //oMark:Data():oTempDB:oStruct:cAlias
	Local cPerg		:= "ACD001IMP"
	Local nCount	:= 0

	If Pergunte(cPerg, .T.)	
		//Parametriza a impressora de destino
		CB5SetImp(MV_PAR01,IsTelnet())

		//#TB20200312 Thiago Berna - Ajuste para posicionar no primiero registro
		(cAliasBrw)->(DbGoTop())
		
		ProcRegua(RecCount())
		
		While !(cAliasBrw)->(Eof())
			
			//Verifica se foi selecionado
			If oMark:IsMark()
				//Posiciona na tabela SB1
				DbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+(cAliasBrw)->CB0_CODPRO))

				//Posiciona na tabela CB0
				DbSelectArea("CB0")
				CB0->(DbSetOrder(2))
				CB0->(DbSeek((cAliasBrw)->(CB0_FILIAL + CB0_CODET2)))

				//Executa a impressão
				If cTipo == 'PRODUTO'
					//Imprime a etiqueta de Produto
					IncProc("Imprimindo Etiqueta: " + (cAliasBrw)->CB0_CODETI) 
					ExecBlock("IMG01",,,{,,CB0->CB0_CODETI})

					//Conta quantos registros foram processados
					nCount++
				Else
					//Executa a impressão apenas 1 vez
					If aScan(aPallets,{|x| x == CB0->CB0_PALLET }) == 0
						//Imprime a etiqueta de Pallet
						IncProc("Imprimindo Etiqueta do Pallet: " + (cAliasBrw)->CB0_PALLET) 
						ExecBlock("IMG10",,,{CB0->CB0_PALLET})
						AADD(aPallets,CB0->CB0_PALLET)

						//Conta quantos registros foram processados
						nCount++
					EndIf
				EndIf
			Else
				IncProc() 	
			EndIf
			(cAliasBrw)->(DbSkip())
		EndDo
	EndIf

	MSCBCLOSEPRINTER()

	If nCount > 0
		MsgInfo(AllTrim(Str(nCount)) + ' registros processados.','Concluído')
	Else
		MsgInfo("Nenhum registro selecionado.",'Abortado')
	EndIf

	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
| Func:  MarkValid                                                    |
| Autor: Thiago Berna                                                 |
| Data:  26/Março/2020                                                |
| Desc:  Validacao do registro selecionado                            |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/
Static Function MarkValid()
	Local cAliasBrw	:= oAliasCB0:oStruct:cAlias//oMark:Data():oTempDB:oStruct:cAlias	
	Local cMarca	:= oMark:cMark
	Local cPallet	:= (cAliasBrw)->CB0_PALLET
	Local aArea		:= GetArea()
	Local lMarca	:= oMark:IsMark(cMarca)
	Local nRecno	:= (cAliasBrw)->(Recno())
		
	(cAliasBrw)->(DbGoTop())
	While !(cAliasBrw)->(Eof())
		If (cAliasBrw)->CB0_PALLET == cPallet .And. !(cAliasBrw)->(Recno()) == nRecno
			If lMarca .And. !oMark:IsMark()
				//Marca todos os registros do mesmo Pallet
				oMark:MarkRec()
			ElseIf !lMarca .And. oMark:IsMark()
				//Desmarca todos os registros do mesmo Pallet
				oMark:MarkRec()
			EndIf
		EndIf
		(cAliasBrw)->(DbSkip())
	EndDo

	RestArea(aArea)

Return