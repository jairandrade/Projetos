#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"
/*/{Protheus.doc} CNTA121
//TODO Ponto de Entrada executado após o encerramento da medição para criação de Documento de Entrada
@author Jair Matos
@since 14/02/2019
@version P12
alteração 27-04-2020 - criado validacao cXcondP para validar condicao de pagamento
@type function
/*/
User Function CNTA121()
	Local aParam     := PARAMIXB
	Local xRet       := .T.
	Local lIsGrid    := .F.
	Local oModel  //ParamIXB[1]
	Local cIdPonto //ParamIXB[2]
	Local cIdModel //ParamIXB[3]

	Local nLinha     := 0
	Local nQtdLinhas := 0
	Local cNfs       := ''


	If aParam <> NIL

		oModel   := ParamIXB[1]
		cIdPonto := ParamIXB[2]
		cIdModel := ParamIXB[3]

		If cIdPonto == 'MODELCOMMITNTTS'
			GeraSF1(oModel)
		EndIf

	EndIf

Return xRet
/*/{Protheus.doc} GeraSF1
//TODO Funcao que gera o documento de entrada a partir da Medição
@author Jair Matos
@since 14/02/2019
@version P12

@type function
/*/
Static Function GeraSF1(oModel)
	Local aArea  := GetArea()
	Local aCabec 	:= {}
	Local aItens 	:= {}
	Local aLinha 	:= {}
	Local cDoc  	:= ""
	Local cFornece  := ""
	Local cLoja  	:= ""
	Local cNum 		:= ""
	Local cXcondP	:=""
	Local cSerie	:=PADL("99",Len(SF1->F1_SERIE),"0")
	Local cAliasSC7 := GetNextAlias()        // da um nome pro arquivo temporario
	Local cNfs 		:= ""
	Private lMsErroAuto := .F.
	Private cDtVenc 
	Private cVlTot := 0

	If 	oModel:GetOperation() == 4 .and. CN9->CN9_XFLSF1 =="1"//Gera SF1 - Documento de entrada

		//Verifica TODOS os registros do contrato e medicao(cnd_nummed/cnd_contra\PEDIDOS	)
		cQuery := " SELECT C7_FILIAL, C7_FORNECE,C7_LOJA,C7_EMISSAO,C7_COND,C7_PRODUTO,C7_QUANT,C7_PRECO," 
		cQuery += " C7_TOTAL,C7_TES, C7_SEGURO,C7_VALFRE,C7_DESPESA,C7_NUM,C7_ITEM,C7_CONTRA,C7_MEDICAO , "
		cQuery += " CNA_REVISA,CNA_XCONDP,CXN_DTVENC,CXN_VLTOT "
		cQuery += " FROM " + RetSQLName("SC7") + " SC7 " 
		cQuery += " JOIN " + RetSQLName("CNA") + " CNA "
		cQuery += " ON CNA_CONTRA = C7_CONTRA AND CNA_NUMERO = C7_PLANILH AND CNA_FORNEC = C7_FORNECE AND CNA_LJFORN =C7_LOJA AND CNA.D_E_L_E_T_ <> '*'
		cQuery += " JOIN  " + RetSQLName("CXN") + "  CXN "
		cQuery += " ON CXN_CONTRA = C7_CONTRA AND CXN_NUMMED = C7_MEDICAO AND CXN_FILIAL = C7_FILIAL AND CXN.D_E_L_E_T_ <> '*' "
		cQuery += " AND CXN_REVISA = CNA_REVISA AND CXN_NUMPLA = C7_PLANILH"
		cQuery += " WHERE SC7.D_E_L_E_T_ = ' ' "
		cQuery += " AND C7_CONTRA = '"+SC7->C7_CONTRA+"' "
		cQuery += " AND C7_MEDICAO = '"+SC7->C7_MEDICAO+"' "
		cQuery += " AND C7_FILIAL = '"+SC7->C7_FILIAL+"' "
		cQuery += " ORDER BY C7_FORNECE,C7_NUM 

		If Select(cAliasSC7) > 0
			dbSelectArea(cAliasSC7)
			dbCloseArea()
		EndIf

		TCQUERY cQuery NEW ALIAS &cAliasSC7
		//		If (cAliasSC7)->(!Eof())//alterado 03-01-2019 para incluir fornecedores diferentes para cada documento
		While !(cAliasSC7)->(EOF())

			dbSelectArea("SC7")
			SC7->(dbSetOrder(1))
			SC7->(dbGotop())
			SC7->(DbSeek((cAliasSC7)->C7_FILIAL+(cAliasSC7)->C7_NUM+(cAliasSC7)->C7_ITEM))	// C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
			SC7->C7_COND :=(cAliasSC7)->CNA_XCONDP
			aCabec 	:= {}
			aItens 	:= {}
			aLinha 	:= {}
			cDoc :=  PADL((cAliasSC7)->C7_NUM,Len(SF1->F1_DOC),"0")
			cFornece := (cAliasSC7)->C7_FORNECE
			cLoja := (cAliasSC7)->C7_LOJA
			cNum := (cAliasSC7)->C7_NUM		
			cDtVenc:= STOD((cAliasSC7)->CXN_DTVENC)
			cVlTot:=(cAliasSC7)->CXN_VLTOT
			
			If Empty((cAliasSC7)->CNA_XCONDP)
				cXcondP := (cAliasSC7)->C7_COND
			Else
				cXcondP := (cAliasSC7)->CNA_XCONDP
			EndIf		
			dbSelectArea("SF1")
			SF1->(dbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
			If SF1->(dbSeek((cAliasSC7)->C7_FILIAL+cDoc+cSerie+(cAliasSC7)->C7_FORNECE+(cAliasSC7)->C7_LOJA))
				MsgAlert("Nota Fiscal "+cDoc+" já existe.","Aviso")
			Else
				//ExpA1 - Array contendo os dados do cabeçalho da Nota Fiscal de Entrada.
				aadd(aCabec,{"F1_TIPO" 		, "N" 		, Nil})
				aadd(aCabec,{"F1_FORMUL" 	, "N" 		, Nil})
				aadd(aCabec,{"F1_DOC" 		, cDoc 		, Nil})
				aadd(aCabec,{"F1_SERIE" 	, cSerie 	, Nil})
				aadd(aCabec,{"F1_EMISSAO" 	, STOD((cAliasSC7)->C7_EMISSAO), Nil})
				aadd(aCabec,{"F1_DESPESA" 	, 0 		, Nil})
				aadd(aCabec,{"F1_FORNECE" 	, cFornece , Nil})
				aadd(aCabec,{"F1_LOJA" 		, cLoja, Nil})
				aadd(aCabec,{"F1_ESPECIE" 	, "BOL" 	, Nil})
				aadd(aCabec,{"F1_COND" 		, cXcondP, Nil})
				aadd(aCabec,{"F1_DESCONT" 	, 0 		, Nil})
				aadd(aCabec,{"F1_SEGURO" 	, 0 		, Nil})
				aadd(aCabec,{"F1_FRETE" 	, 0 		, Nil})
				aadd(aCabec,{"F1_VALMERC" 	, 0 		, Nil})
				aadd(aCabec,{"F1_VALBRUT" 	, 0 		, Nil})
				aadd(aCabec,{"F1_MOEDA" 	, 0 		, Nil})
				aadd(aCabec,{"F1_TXMOEDA" 	, 0 		, Nil})
				aadd(aCabec,{"F1_STATUS" 	, "A" 		, Nil})

				While !(cAliasSC7)->(EOF()) .AND.  cFornece == (cAliasSC7)->C7_FORNECE .AND.  cLoja == (cAliasSC7)->C7_LOJA .AND.  cNum == (cAliasSC7)->C7_NUM
					//ExpA2- Array contendo os itens da Nota Fiscal de Entrada.
					aLinha := {}
					aadd(aLinha,{"D1_COD"    , (cAliasSC7)->C7_PRODUTO , Nil})
					aadd(aLinha,{"D1_QUANT"  , (cAliasSC7)->C7_QUANT , Nil})
					aadd(aLinha,{"D1_VUNIT"  , (cAliasSC7)->C7_PRECO, Nil})
					aadd(aLinha,{"D1_TOTAL"  , (cAliasSC7)->C7_TOTAL , Nil})
					aadd(aLinha,{"D1_TES" 	 , (cAliasSC7)->C7_TES , Nil})
					aadd(aLinha,{"D1_SEGURO" , (cAliasSC7)->C7_SEGURO , Nil})
					aadd(aLinha,{"D1_VALFRE" , (cAliasSC7)->C7_VALFRE , Nil})
					aadd(aLinha,{"D1_DESPESA", (cAliasSC7)->C7_DESPESA , Nil})
					aadd(aLinha,{"D1_PEDIDO" , (cAliasSC7)->C7_NUM , Nil})
					aadd(aLinha,{"D1_ITEMPC" , PADL((cAliasSC7)->C7_ITEM,Len(SD1->D1_ITEMPC),"0") , Nil})
					aadd(aLinha,{"AUTDELETA" , "N" , Nil}) // Incluir sempre no último elemento do array de cada item

					aadd(aItens,aLinha)		
					(cAliasSC7)->(dbSKip())
				EndDo

				MATA103(aCabec,aItens,3,,,,,/*aColsCC*/,,,/*aCodRet*/)
				If !lMsErroAuto
					If Empty(cNfs)
						cNfs := cDoc 
					Else 
						cNfs += " / "+cDoc 
					EndIf
				Else
					MostraErro()
				EndIf

			EndIf
		EndDo
		(cAliasSC7)->(dbCloseArea())
		MsgAlert("Nota Fiscal "+cNfs+" incluida(s) com sucesso.","Aviso")
	EndIf
	RestArea(aArea)
Return

