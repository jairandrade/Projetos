#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

//Static cTitulo := "Cupons x NF "

/*/{Protheus.doc} FAT001
Emissao de NF com base no cupom fiscal
@author Thiago Berna
@since 10/Fevereiro/2020
@version 1.0
@return Nil, Função não tem retorno
/*/

User Function FAT001()

	Local aArea   	:= GetArea()
	Local aMvPar 	:= {}
	Local aColunas	:= {}
	Local aSeek		:= {}
	Local aIndex	:= {}
	Local aCmpTrab	:= {}
	Local cQuery	:= ""
	Local cAlias	:= GetNextAlias()
	Local cPerg		:= 'FAT001'
	Local cIn		:= ''
	Local nX		:= 0
	
	Private oMark	:= Nil
	Private nSelec	:= 0
	Private cTitulo := "Cupons x NF"
	
	//Setando O MENUDEF
	Private aRotina := MenuDef()

	//Salva parametros originais
	For nX := 1 To 40
 		aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
	Next nX

	If Empty(c920Client) .Or. Empty(c920Loja) .Or. Empty(c920Especi)
		MsgInfo("Preencher o cabeçalho primeiro.","Atenção")
	Else
	
		If Pergunte(cPerg, .T.)	
		
			aCmpTrab	:= {"F2_FILIAL","F2_EMISSAO","F2_DOC","F2_SERIE","F2_CLIENTE","F2_LOJA","F2_TIPO","F2_VALBRUT"}

			For nX := 1 To Len(aCmpTrab)

				aAdd(aColunas,FWBrwColumn():New())
				aColunas[Len(aColunas)]:SetTitle(RTrim(GetSx3Cache(aCmpTrab[nX],"X3_TITULO")))
				aColunas[Len(aColunas)]:SetData(&("{||" + aCmpTrab[nX] + "}"))
				aColunas[Len(aColunas)]:SetSize(GetSx3Cache(aCmpTrab[nX],"X3_TAMANHO"))
				aColunas[Len(aColunas)]:SetType(GetSx3Cache(aCmpTrab[nX],"X3_TIPO"))
				aColunas[Len(aColunas)]:SetDecimal(GetSx3Cache(aCmpTrab[nX],"X3_DECIMAL"))
				aColunas[Len(aColunas)]:SetPicture(GetSx3Cache(aCmpTrab[nX],"X3_PICTURE"))
				aColunas[Len(aColunas)]:SetAlign( IIf(GetSx3Cache(aCmpTrab[nX],"X3_TIPO") == "N","RIGHT","LEFT"))


				aAdd(aSeek	,{RTrim(GetSx3Cache(aCmpTrab[nX],"X3_TITULO"));
							,{{'';
							,GetSx3Cache(aCmpTrab[nX],"X3_TIPO");
							,GetSx3Cache(aCmpTrab[nX],"X3_TAMANHO");
							,0;
							,aCmpTrab[nX];
							,"@!"}}})

			Next nX

			For nX := 1 To Len( aCmpTrab )
				aAdd(aIndex, aCmpTrab[nX] )
			Next nX

			//Carrega dados dos documentos ja selecionados para nao permitir que sejam selecionados 2 vezes
			For nX := 1 To Len(aCols)
			
				If !Empty(aCols[nX,aScan(aHeader,{|x| x[2] == PadR("D2_NFORI"		,Len(SX3->X3_CAMPO))})])
					
					If !Empty(cIn)
						cIn += "/"
					EndIf

					cIn += aCols[nX,aScan(aHeader,{|x| x[2] == PadR("D2_SERIORI"		,Len(SX3->X3_CAMPO))})] + aCols[nX,aScan(aHeader,{|x| x[2] == PadR("D2_NFORI"		,Len(SX3->X3_CAMPO))})]
			
				EndIf

			Next nX

			aAdd(aIndex, "SF2_OK" )
			
			cQuery := "SELECT SF2.F2_FILIAL, SUBSTR(SF2.F2_EMISSAO,7,2)||'/'||SUBSTR(SF2.F2_EMISSAO,5,2)||'/'||SUBSTR(SF2.F2_EMISSAO,1,4) AS F2_EMISSAO, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_VALBRUT, SF2.F2_TIPO, '  ' AS SF2_OK "
			cQuery += "FROM " + RetSqlTab("SF2")
			cQuery += "WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
			cQuery += "AND SF2.F2_EMISSAO = '" + DTOS(MV_PAR01) + "' "
			cQuery += "AND SF2.F2_ESPECIE IN ('SATCE','NFCE ') "
			
			If !Empty(cIn)
				cQuery += "AND NOT SF2.F2_SERIE||SF2.F2_DOC IN " + FormatIn(cIn,"/")
			EndIf
			
			cQuery += "AND SF2.D_E_L_E_T_ = ' '  "
			
			//Instânciando FWMarkBrowse - Somente com dicionário de dados
			oMark := FWMarkBrowse():New()

			//Setando a utilizacao de query
			oMark:SetDataQuery(.T.)
			
			//Setando a query 
			oMark:SetQuery( cQuery )

			//Setando os indices para pesquisa
			oMark:oBrowse:SetQueryIndex(aIndex)
			
			//Setando o alias
			oMark:SetAlias( cAlias )	
			
			//Setando as colunas
			oMark:SetColumns(aColunas)

			//Setando o campo de marcacao
			oMark:SetFieldMark( 'SF2_OK' )
			
			//Setando a descrição da rotina
			oMark:SetDescription(cTitulo)
			
			//Setando a utilizacao de filtros
			oMark:SetUseFilter(.T.)
			
			//oMark:SetTemporary(.T.)

			//Setando os campos para pesquisa
			oMark:oBrowse:SetSeek(.T.,aSeek)

			//Setando a fucao para marcar todos
			//oMark:SetAllMark( { || oMark:AllMark() } )

			//Setando o retorno do clique duplo
			oMark:SetValid( { || MarkValid() } )
			//oMark:Valid(.F.)

			//Ativa a Browse
			oMark:Activate()

		EndIf

		//Restaura Parametros
		For nX := 1 To Len( aMvPar )
			&( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[ nX ]
		Next nX

	EndIf

	RestArea(aArea)

Return Nil

/*---------------------------------------------------------------------*
| Func:  MenuDef                                                      |
| Autor: Thiago Berna                                                 |
| Data:  10/Fevereiro/2020                                            |
| Desc:  Criação do menu MVC                                          |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function MenuDef()
	Local aRot 		:= {}
	
	//Adicionando opções	
	ADD OPTION aRot TITLE 'Importar'	ACTION "MsgRun('Aguarde...','Processando',{|| U_Ft001Pro() , CloseBrowse()  })"	OPERATION MODEL_OPERATION_UPDATE   ACCESS 0 //OPERATION 1

Return aRot


/*---------------------------------------------------------------------*
| Func:  ModelDef                                                     |
| Autor: Thiago Berna                                                 |
| Data:  10/Fevereiro/2020                                            |
| Desc:  Criação do modelo de dados MVC                               |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function ModelDef()
	//Criação do objeto do modelo de dados
	Local oModel := Nil

	//Criação da estrutura de dados utilizada na interface
	Local oStSF2 := FWFormStruct(1, "SF2")

	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("zFAT001",/*bVldPre*/,,/*bCommit*/,/*bCancel*/)

	//Atribuindo formulários para o modelo
	oModel:AddFields("FORMSF2",/*cOwner*/,oStSF2)

	//Setando a chave primária da rotina
	//oModel:SetPrimaryKey({'SF2_FILIAL','SF2_PRDPAI','SF2_CODREC'})

	//Adicionando descrição ao modelo
	oModel:SetDescription(cTitulo)

	//Setando a descrição do formulário
	oModel:GetModel("FORMSF2"):SetDescription(cTitulo)
Return oModel

/*---------------------------------------------------------------------*
| Func:  ViewDef                                                      |
| Autor: Thiago Berna                                                 |
| Data:  10/Fevereiro/2020                                            |
| Desc:  Criação da visão MVC                                         |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function ViewDef()

	//Criação do objeto do modelo de dados da Interface 
	Local oModel := ModelDef()//FWLoadModel("M_FAT001")

	//Criação da estrutura de dados utilizada na interface 
	Local oStSF2 := FWFormStruct(2, "SF2")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}

	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formulários para interface
	oView:AddField("VIEW_SF2", oStSF2, "FORMSF2")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	//Colocando título do formulário
	oView:EnableTitleView('VIEW_SF2', cTitulo )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_SF2","TELA")

Return oView  

/*---------------------------------------------------------------------*
| Func:  Ft001Pro                                                     |
| Autor: Thiago Berna                                                 |
| Data:  11/Fevereiro/2020                                            |
| Desc:  Processamento da rotina                                      |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/
User Function Ft001Pro()

	Local aArea     := GetArea()
	Local aDados	:= {}
	Local cAliasBrw	:= oMark:Data():oTempDB:oStruct:cAlias
	Local cMarca	:= oMark:cMark	
	Local cItem		:= "01"
	Local nCount	:= 0
	Local nSalva	:= n

	cItem := aCols[Len(aCols),aScan(aHeader,{|x| x[2] == PadR("D2_ITEM",Len(SX3->X3_CAMPO))})]
	
	//#TB20200312 Thiago Berna - Ajuste para posicionar no primiero registro
	(cAliasBrw)->(DbGoTop())

	While !(cAliasBrw)->(Eof())
		
		//Verifica se foi selecionado
		If (cAliasBrw)->SF2_OK == cMarca

			//Posiciona no Item do cupom
			DbSelectArea("SD2")
			SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM                                  
			If SD2->(DbSeek((cAliasBrw)->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))	
				
				//Guarda os recnos utilizados para atualizar o campo D2_NFCUP utilizando a variavel aPergunta					
				//#TB20200312 Thiago Berna - Ajuste para substituir variavel
				//aSize(aPergunta,0)
				
				While !SD2->(Eof()) .And. (cAliasBrw)->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA) == SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA)
			
					//Verifica necessidade de criar novo registro no aCols
					If !Empty(aCols[Len(aCols),aScan(aHeader,{|x| x[2] == PadR("D2_COD"		,Len(SX3->X3_CAMPO))})])
						cItem := Soma1(cItem)
						AAdd(aCols,Array(Len(aHeader)+1))
						
						For nCount := 1 to Len(aHeader)
							If aHeader[nCount,2] == "D2_ALI_WT"
								aCols[Len(aCols),nCount] := "SD2"
							ElseIf aHeader[nCount,2] == "D2_REC_WT"
								aCols[Len(aCols),nCount] := 0
							Else
								aCols[Len(aCols),nCount] := CriaVar(aHeader[nCount,2],.F.)
							EndIf
						Next nCount

						aCols[Len(aCols),nCount] := .F.

					EndIf

					//Posiciona no acols
					n := Len(aCols)

					//Carrega campos na memoria
					RegToMemory("SD2",.T.)
					
					//Preenchimento do campo Item
					M->D2_ITEM := cItem
					aCols[Len(aCols),aScan(aHeader,{|x| x[2] == PadR("D2_ITEM"		,Len(SX3->X3_CAMPO))})]	:= cItem
					
					//Preenchimento do campo Codigo
					M->D2_COD := SD2->D2_COD
					aCols[Len(aCols),aScan(aHeader,{|x| x[2] == PadR("D2_COD"		,Len(SX3->X3_CAMPO))})] := SD2->D2_COD
					If ExistTrigger('D2_COD')
						RunTrigger(2,n,nil,,'D2_COD')
					EndIf
					MaFisRef("IT_PRODUTO","MT100",M->D2_COD)                                   
					
					//Preenchimento do campo Quantidade
					M->D2_QUANT := SD2->D2_QUANT
					aCols[Len(aCols),aScan(aHeader,{|x| x[2] == PadR("D2_QUANT"		,Len(SX3->X3_CAMPO))})] := SD2->D2_QUANT
					If ExistTrigger('D2_QUANT')
						RunTrigger(2,n,nil,,'D2_QUANT')
					EndIf
					MaFisRef("IT_QUANT","MT100",M->D2_QUANT)         
					
					//Preenchimento do campo Preco de Venda
					M->D2_PRCVEN := SD2->D2_PRCVEN
					aCols[Len(aCols),aScan(aHeader,{|x| x[2] == PadR("D2_PRCVEN"	,Len(SX3->X3_CAMPO))})] := SD2->D2_PRCVEN
					If ExistTrigger('D2_PRCVEN')
						RunTrigger(2,n,nil,,'D2_PRCVEN')
					EndIf
					MaFisRef("IT_PRCUNI","MT100",M->D2_PRCVEN)    
					
					//Preenchimento do campo Total
					M->D2_TOTAL := SD2->D2_TOTAL
					aCols[Len(aCols),aScan(aHeader,{|x| x[2] == PadR("D2_TOTAL"		,Len(SX3->X3_CAMPO))})] := SD2->D2_TOTAL					
					If ExistTrigger('D2_TOTAL')
						RunTrigger(2,n,nil,,'D2_TOTAL')
					EndIf
					MaFisRef("IT_VALMERC","MT100",M->D2_TOTAL)     
										
					//Preenchimento do campo TES
					M->D2_TES := MV_PAR02
					aCols[Len(aCols),aScan(aHeader,{|x| x[2] == PadR("D2_TES"		,Len(SX3->X3_CAMPO))})]	:= MV_PAR02					
					If ExistTrigger('D2_TES')
						RunTrigger(2,n,nil,,'D2_TES')
					EndIf
					MaFisRef("IT_TES","MT100",M->D2_TES)  

					//Preenchimento do campo Nota Origem
					M->D2_NFORI := (cAliasBrw)->(F2_DOC)
					aCols[Len(aCols),aScan(aHeader,{|x| x[2] == PadR("D2_NFORI"		,Len(SX3->X3_CAMPO))})] := (cAliasBrw)->(F2_DOC)
									
					//Preenchimento do campo Serie Origem
					M->D2_SERIORI := (cAliasBrw)->(F2_SERIE)
					aCols[Len(aCols),aScan(aHeader,{|x| x[2] == PadR("D2_SERIORI"	,Len(SX3->X3_CAMPO))})]	:= (cAliasBrw)->(F2_SERIE)

					//#TB20200309 Thiago Berna - Ajuste para considerar o Item
					//Preenchimento do campo Item Origem
					M->D2_ITEMORI := SD2->D2_ITEM
					aCols[Len(aCols),aScan(aHeader,{|x| x[2] == PadR("D2_ITEMORI"	,Len(SX3->X3_CAMPO))})]	:= SD2->D2_ITEM

					//Guarda os recnos utilizados para atualizar o campo D2_NFCUP utilizando a variavel aPergunta
					//#TB20200309 Thiago Berna - Ajuste para considerar o Item
					//AAdd(aPergunta,SD2->(Recno()))
					//#TB20200312 Thiago Berna - Ajuste para substituir variavel
					//AAdd(aPergunta,{SD2->(Recno()),{M->D2_NFORI,M->D2_SERIORI,M->D2_ITEM}})
					AAdd(aDados,{SD2->(Recno()),{M->D2_NFORI,M->D2_SERIORI,M->D2_ITEM}})

					SD2->(Dbskip())
					
				EndDo 

			EndIf
		EndIf
		(cAliasBrw)->(DbSkip())
	EndDo

	If Len(aDados) > 0
		//Guarda os recnos utilizados para atualizar o campo D2_NFCUP utilizando a variavel aPergunta					
		aSize(aPergunta,0)
		aPergunta := aClone(aDados)
	EndIf

	//Restaura posicao original do aCols
	n := nSalva

	RestArea(aArea)

Return

/*---------------------------------------------------------------------*
| Func:  MarkValid                                                    |
| Autor: Thiago Berna                                                 |
| Data:  11/Fevereiro/2020                                            |
| Desc:  Validacao do registro selecionado                            |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/
Static Function MarkValid()

Local lRet		:= .T.
Local cAliasBrw	:= oMark:Data():oTempDB:oStruct:cAlias	
Local cMarca	:= oMark:cMark
Local cQuery	:= ""
Local cAliasSD2	:= GetNextAlias()
Local aArea		:= GetArea()

//Reinicia a variavel
nSelec := 0

If !oMark:IsMark(cMarca)
	
	//Verificar se ja esta vinculado
	cQuery := "SELECT SD2.D2_DOC, SD2.R_E_C_N_O_ "
	cQuery += "FROM " + RetSqlTab("SD2")
	cQuery += "WHERE SD2.D2_FILIAL = '"+ (cAliasBrw)->F2_FILIAL + "' AND "
	cQuery += "SD2.D2_NFCUP = '" + (cAliasBrw)->F2_DOC + "' AND "
	cQuery += "SD2.D2_SERIORI = '" + (cAliasBrw)->F2_SERIE + "' AND "
	cQuery += "SD2.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY "+SqlOrder(SD2->(IndexKey()))

	cQuery := ChangeQuery(cQuery)

	If Select("cAliasSD2") > 0
		cAliasSD2->(DbCloseArea())  
	Endif

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
	
	If !(cAliasSD2)->(Eof())
		MsgInfo("Registro vinculado ao documento " + AllTrim((cAliasSD2)->D2_DOC) + "!","Atenção - Não é possível selecionar o registro.")
		lRet := .F.
	EndIf
	
	//Verifica se permite selecionar mais de 1 registro
	If !SuperGetMv("MV_XFAT001",,.F.)
		
		(cAliasBrw)->(DbGoTop())
		While !(cAliasBrw)->(Eof())
			If (cAliasBrw)->SF2_OK == cMarca
				nSelec++
			EndIf
			(cAliasBrw)->(DbSkip())
		EndDo
		
		If nSelec > 0
			MsgInfo("Foi selecionado mais de 1 registro. Verifique o parâmetro [MV_XFAT001]!","Atenção - Não é possível selecionar o registro.")
			lRet := .F.
		EndIf

	EndIf
	
EndIf

RestArea(aArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³RunTrigger³ Autor ³ Ary Medeiros			  ³ Data ³ 31/08/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa Gatilhos Primarios e Armazena Estrangeiros 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ RunTrigger(ExpN1) 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 := Tipo (1-Enchoice 2-GetDados 3-F3						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/*/
User Function RTrigger(nTipo,nLin,cMacro,oObj,cField)
Local cSavAlias := Alias()
Local nSavRec
Local cCpo := If(cField == NIL,SX3->X3_CAMPO,cField)
Local cResult, nElem, nSavOrd, cSeek
Local bErro
Local nPos := 0,cCompVal:=""
Local aGetsTrigger
If Type("lNoDetect") == "L"
	bErro := ErrorBlock({ |e| TriggerErr(e,SX7->X7_CAMPO,SX7->X7_SEQUENC,lNoDetect)})
Else
	bErro := ErrorBlock({ |e| TriggerErr(e,SX7->X7_CAMPO,SX7->X7_SEQUENC,.f.)})
EndIf
DbSelectArea("SX7")
nSavRec := Recno()
DbSeek(cCpo)
BEGIN SEQUENCE
While Alltrim(SX7->X7_CAMPO) == Alltrim(cCpo)
	If !Empty(SX7->X7_CONDIC)
		If !(&(SX7->X7_CONDIC))
			SX7->(DbSkip())
			Loop
		EndIf
	EndIf
	If SX7->X7_Tipo ==	"P"
		If SX7->X7_SEEK=="S"
			DbSelectArea(SX7->X7_ALIAS)
			nSavOrd := IndexOrd()
			DbSetOrder(SX7->X7_ORDEM)
			DbSeek(&(If(nTipo == 2,TriggerClear(SX7->X7_CHAVE,nLin,cSavAlias),SX7->X7_CHAVE)))
			DbSetOrder(nSavOrd)
			DbSelectArea("SX7")
		EndIf
		If nTipo == 1 .or. nTipo ==	3
			cResult := &(SX7->X7_REGRA)
			cMacro := "M->"+SX7->X7_CDOMIN
			If ValType(cResult) == "C"
				cResult	:= TriggerSize(SX7->X7_CDOMIN,cResult)
				&cMacro := cResult
			Else
				&cMacro := cResult
				cResult := TriggerPict(SX7->X7_CDOMIN,cResult)
			EndIf
			If nTipo == 1
				If Type("__cInternet") == "C" .and. __cInternet == "AUTOMATICO" .or. ValType(oObj) <> "O"
					If Type("aGets") <> "U"
						aGetsTrigger := aGets
					EndIf
					If Type("aTela") <> "U"
						aTelaTrigger := aTela
					EndIf
				Else
					aGetsTrigger := oObj:aGets
					aTelaTrigger := oObj:aTela
				EndIf
				If ((nElem := ASCAN(aGetsTrigger,{ |x| Substr(x,9,10) == Substr(cMacro,4)})) # 0)
					If ASC(SubStr(aGetsTrigger[nElem],1,1)) > 64
						cCompVal := Str(ASC(SubStr(aGetsTrigger[nElem],1,1))-55,2)+SubStr(aGetsTrigger[nElem],2,1)
						nPos := Val(cCompVal)
					Else
						nPos := Val(SubStr(aGetsTrigger[nElem],1,2))
					EndIf
					If nPos <= Len(aTelaTrigger) 
						aTelaTrigger[nPos][Val(SubStr(aGetsTrigger[nElem],3,1))+If(Substr(aGetsTrigger[nElem],3,1)=="1",1,2)] := cResult
					End
				EndIf
			Else
				If ((nElem := ASCAN(aGets2,{|x| Substr(x,9,10) == Substr(cMacro,4)})) # 0)
					aTela2[nElem,2] := cResult
				EndIf
			EndIf
		ElseIf nTipo == 2
			cResult := &(TriggerClear(SX7->X7_REGRA,nLin,cSavAlias))
			nElem := ASCAN(aHeader,{|x| PADR(x[2],10) == PADR(SX7->X7_CDOMIN,10)})
			If nElem > 0
				If ValType(cResult) == "C"
					If Type("aCols") # "U"
						aCols[nLin,nElem] := TriggerSize(SX7->X7_CDOMIN,cResult)
					Else
						// p/ GetDadDB
						nElem := (cSavAlias)->(FieldPos(SX7->X7_CDOMIN))
						If nElem > 0
							(cSavAlias)->( FieldPut( nElem,TriggerSize(SX7->X7_CDOMIN,cResult) ) )
						EndIf
					EndIf
				Else
					If Type("aCols") # "U"
						aCols[nLin,nElem] := cResult //TriggerPict(X7_CDOMIN,cResult)
					Else
						// p/ GetDadDB
						nElem := (cSavAlias)->(FieldPos(SX7->X7_CDOMIN))
						If nElem > 0
							(cSavAlias)->(FieldPut(nElem,cResult))
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		lRefresh := .t.
	ElseIf SX7->X7_TIPO == "X"
		DbSelectArea(SX7->X7_ALIAS)
		nSavOrd := IndexOrd()
		DbSetOrder(SX7->X7_ORDEM)
		DbSeek(&(SX7->X7_CHAVE))
		DbSetOrder(nSavOrd)
		DbSelectArea("SX7")
	Else
		nElem := ASCAN(aTrigger,{ |aX| aX[1] == SX7->X7_CAMPO .and. aX[2]==SX7->X7_SEQUENC .and.	aX[5] == nLin })
		If SX7->X7_SEEK=="S"
			DbSelectArea(SX7->X7_ALIAS)
			cSeek := &(If(nTipo == 2,TriggerClear(SX7->X7_CHAVE,nLin,cSavAlias),SX7->X7_CHAVE))
			DbSeek(cSeek)
			DbSelectArea("SX7")
		Else
			cSeek :=""
		EndIf
		If nTipo == 1
			cResult := &(SX7->X7_REGRA)
		Else
			cResult := &(TriggerClear(SX7->X7_REGRA,nLin,cSavAlias))
		EndIf
		If nElem == 0
			AADD(aTrigger,{SX7->X7_CAMPO,SX7->X7_SEQUENC,cResult,cSeek,nLin})
		Else
			aTrigger[nElem] := {SX7->X7_CAMPO,SX7->X7_SEQUENC,cResult,cSeek,nLin}
		EndIf
	EndIf
	SX7->(DbSkip())
End
End SEQUENCE
DbGoTo(nSavRec)
If !Empty(cSavAlias)
	DbSelectArea(cSavAlias)
Endif
ErrorBlock(bErro)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ TriggerClear³ Autor ³ Ary Medeiros	     ³ Data ³ 31/08/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Substitui "M->" por conteudo do array aTela                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TriggerClear(cExpr,nLin,cAliasOld)

Local cStr
Local aPos
Local nIni
Local nEnd
Local nElem
Local nElemTBL
Local cSub

cExpr := UPPER(cExpr)
While "M->"$cExpr
	nIni := At("M->",cExpr)+3
	cSub := Substr(cExpr,nIni,Len(cExpr))
	aPos := {}
	If ( "!" $ cSub )
		AADD(aPos,At("!",cSub))
	EndIf
	If ( "$" $ cSub )
		AADD(aPos,At("$",cSub))
	EndIf
	If ( "%" $ cSub )
		AADD(aPos,At("%",cSub))
	EndIf
	If ( "^" $ cSub )
		AADD(aPos,At("^",cSub))
	EndIf
	If ( ")" $ cSub )
		AADD(aPos,At(")",cSub))
	EndIf
	If ( "-" $ cSub )
		AADD(aPos,At("-",cSub))
	EndIf
	If ( "+" $ cSub )
		AADD(aPos,At("+",cSub))
	EndIf
	If ( "*" $ cSub )
		AADD(aPos,At("*",cSub))
	EndIf
	If ( "/" $ cSub )
		AADD(aPos,At("/",cSub))
	EndIf
	If ( " " $ cSub )
		AADD(aPos,At(" ",cSub))
	EndIf
	If ( "," $ cSub )
		AADD(aPos,At(",",cSub))
	EndIf
	If ( "<" $ cSub )
		AADD(aPos,At("<",cSub))
	EndIf
	If ( ">" $ cSub )
		AADD(aPos,At(">",cSub))
	EndIf
	If ( "=" $ cSub )
		AADD(aPos,At("=",cSub))
	EndIf
	If ( Len(aPos) == 0 )
		nEnd := Len(cSub)
	Else
		aPos := aSort(aPos)
		nEnd := aPos[1]
	EndIf
	cCpo	:= Substr(cExpr,nIni,nEnd-1)
	nElem := ASCAN(aHeader,{|x| AllTrim(x[2]) == AllTrim(Upper(cCpo))})
	If ( nElem == 0 )
		cExpr := Substr(cExpr,1,nIni-4)+"m"+Subs(cExpr,nIni-2)
	Else
		If ( Type("aCols") # "U" )
			cExpr := Substr(cExpr,1,nIni-4)+"aCols["+AllTrim(Str(nLin))+","+AllTrim(Str(nElem))+"]"+Substr(cSub,nEnd,Len(cSub))
		Else
			nElemTBL := (cAliasOld)->(FieldPos(AllTrim(Upper(cCpo))))
			cExpr := Substr(cExpr,1,nIni-4)+cAliasOld+"->(FieldGet("+AllTrim(Str(If(ValType(nElemTBL)=="N" .And. nElemTBL > 0,nElemTBL,nElem)))+"))"+Substr(cSub,nEnd,Len(cSub))
		EndIf
	EndIf
End
Return( cExpr )

//#TB20200309 Thiago Berna Funcao MLjR30Sped disponibilizada por Alexandre Contim por e-mail (Utilizado no NFESEFAZ.PRW)
User Function MLjR30Sped()
 
Local aRet      := {}
Local aArea     := GetArea()
Local aAreaSD2  := {}
 
Local cNumNota  := ""
Local cSerNota  := ""
Local cFilNota  := ""
Local cAlias    := "SD2"
Local cQuery    := ""
 
If !Empty(AllTrim(SF2->F2_NFCUPOM)) //.And. (AllTrim(SF2->F2_NFCUPOM) == "MDL-RECORDED")
 
    cNumNota := SF2->F2_DOC
    cSerNota := SF2->F2_SERIE
    cFilNota := SF2->F2_FILIAL
    
    If !(Select("SD2") > 0)
        DbSelectArea("SD2")
    EndIf
 
    aAreaSD2    := SD2->(GetArea())
 
    cAlias  := "SD2TMP"
    
    If Select(cAlias) > 0
        (cAlias)->(DbCloseArea())
    EndIf
    
    cQuery  := "SELECT D2_FILIAL,D2_DOC,D2_SERIE,D2_ITEM,D2_PDV,D2_CLIENTE,D2_LOJA,R_E_C_N_O_ SD2Recno "
    cQuery  += " FROM " + RetSqlName("SD2") + " SD2 "
    cQuery  += " WHERE D_E_L_E_T_ = ''  "
    cQuery  += " AND D2_FILIAL = '" + cFilNota + "'"
    cQuery  += " AND D2_NFCUP = '"+ cNumNota +"' "  
    cQuery  += " AND D2_SERIORI = '" + cSerNota + "'"
    
    cQuery := ChangeQuery( cQuery )
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.)
    (cAlias)->(DbGoTop())
 
    While !(cAlias)->(Eof())
        Aadd( aRet ,{   (cAlias)->D2_FILIAL,;
                        (cAlias)->D2_DOC,;
                        (cAlias)->D2_SERIE,;
                        (cAlias)->SD2Recno,;
                        (cAlias)->D2_CLIENTE,;
                        (cAlias)->D2_LOJA} )
 
        (cAlias)->(DbSkip())
    EndDo
 
    RestArea(aAreaSD2)
EndIf
 
RestArea(aArea)
 
Return aRet