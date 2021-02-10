#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF (chr(13)+chr(10))

#define POS_PROD     1
#define POS_QUANT    2
#define POS_VALUNIT  3
#define POS_DESC     4
#define POS_VALDESC  5
#define POS_TES      6
#define POS_CONTA    7
#define POS_CC       8
#define POS_ITEMCTA  9

User function AGCT009()

	Local aArea			:= GetArea()
	Local aSaveLines	:= FWSaveRows()
	Private nHandle

	cTipo := "Arquivos Texto  (*.CSV)  | *.CSV | "
//cNomeTXT := cGetFile(cTipo,OemToAnsi("Selecionar Arquivo..."))
	cNomeTXT := cGetFile( cTipo,'Selecionar Arquivo',0,,.F.,GETF_LOCALHARD  + GETF_NETWORKDRIVE,.T.)

	if !empty(cNomeTXT)

		nHandle := FT_FUSE(cNomeTXT)

		if nHandle < 0
			Alert("Erro ao abrir o arquivo de texto!")
			Return .F.
		endif

		Processa( {|| impPlan(cNomeTXT) }, "Aguarde...", "Importando planilha...",.F.)

		FT_FUSE()

	endif

	FWRestRows(aSaveLines)
	RestArea(aArea)
RETURN


Static Function impPlan(cNomeTXT)
	Local aArea	 	:= GetArea()
	Local oModel	:= FWModelActive()
	Local oModelCNB := oModel:GetModel("CNBDETAIL")
	Local oModelCNA := oModel:GetModel("CNADETAIL")
	Local cItem		:= ""
	Local nNewLine	:= 0
	Local lServico	:= Cn300RetSt('SERVIÇO')
	Local lSemiProd := CN300RetSt('SEMIPROD')
	Local lRet		:= .T.
	Local nVlrPlan  := 0
	Local nVlrSald  := 0
	Local nCntImp   := 0
	Local nCntLin   := 0
	Local _cErros   := ''

	FT_FGOTOP()
	DO while !FT_FEOF() .and. lRet

		nCntLin ++

		cVar   := FT_FREADLN()
		aLinha := StrTokArr(cVar,";")

		dbSelectArea('SB1')
		SB1->(DBSetOrder(1))

		IncProc("Processando produto: "+ALLTRIM(aLinha[POS_PROD])+". Linha "+ALLTRIM(STR(nCntLin)),'')

		if (!EMPTY(aLinha[POS_PROD]) .AND. SB1->(DBSEEK(xFilial('SB1')+RTRIM(aLinha[POS_PROD])))) .AND. SB1->B1_MSBLQL != '1'.AND. LEN(aLinha) >= 3

			nNewLine := MTFindMVC(oModelCNB,{{"CNB_PRODUT",SB1->B1_COD}},0,1)
			if(nNewLine > 0)
				oModelCNB:GoLine(nNewLine)
			else
				//-- Caso a linha nao esteja em branco, adiciona uma linha
				If oModelCNB:isDeleted() .OR. (!Empty(oModelCNB:GetValue("CNB_PRODUT")) .AND. !oModelCNB:isDeleted() .And. (!Empty(oModelCNB:GetValue("CNB_QUANT")) .Or. lServico .Or. lSemiProd)  )
					cItem := Soma1(oModelCNB:GetValue("CNB_ITEM",oModelCNB:Length()))
					nNewLine := oModelCNB:AddLine()

					oModelCNB:GoLine(nNewLine)
					oModelCNB:SetValue("CNB_ITEM",cItem)
				Else
					nNewLine := oModelCNB:GetLine()
				EndIf

			endif

			//Gambiarra copiada o fonte padrão da totvs rsrs Mesmo preenchendo o campo, mostra erro
			oModel:GetModel("CNBDETAIL"):GetStruct():SetProperty("CNB_VLUNIT",MODEL_FIELD_OBRIGAT,.F.)

			oModelCNB:GoLine(nNewLine)
			oModelCNB:SetValue("CNB_PRODUT",SB1->B1_COD)
			oModelCNB:SetValue("CNB_DESCRI",SB1->B1_DESC)
			oModelCNB:SetValue("CNB_UM",SB1->B1_UM)
			// If !lServico .And. !lSemiProd
			If !lServico .And. !lSemiProd
				oModelCNB:SetValue("CNB_QUANT",	trataVal(aLinha[POS_QUANT]))
			endif
			// EndIf
			oModelCNB:SetValue("CNB_VLUNIT"	,trataVal(aLinha[POS_VALUNIT]) )

			If !lServico .And. !lSemiProd
				oModelCNB:LoadValue('CNB_VLTOT', trataVal(aLinha[POS_VALUNIT])* oModelCNB:GetValue('CNB_QUANT'))
			else
				oModelCNB:LoadValue("CNB_VLTOT"	,trataVal(aLinha[POS_VALUNIT]))
			endif

			IF LEN(aLinha) >= POS_DESC
				oModelCNB:LoadValue("CNB_DESC",trataVal(aLinha[POS_DESC]) )
			ENDIF

			IF LEN(aLinha) >= POS_VALDESC
				oModelCNB:LoadValue("CNB_VLDESC",trataVal(aLinha[POS_VALDESC]) )
			ENDIF

			dbSelectArea('SF4')
			SF4->(DBSetOrder(1))

			if LEN(aLinha) >= POS_TES  .and. !EMPTY(aLinha[POS_TES]) .AND. (SF4->(DBSEEK(xFilial('SF4')+RTRIM(aLinha[POS_TES]))))
				oModelCNB:SetValue("CNB_TE",ALLTRIM(aLinha[POS_TES]))
			ENDIF

			dbSelectArea('CT1')
			CT1->(DBSetOrder(1))
			if LEN(aLinha) >= POS_CONTA .AND. !EMPTY(aLinha[POS_CONTA]) .AND. (CT1->(DBSEEK(xFilial('CT1')+RTRIM(aLinha[POS_CONTA]))))
				oModelCNB:SetValue("CNB_CONTA",ALLTRIM(aLinha[POS_CONTA]))
			ENDIF

			dbSelectArea('CTT')
			CTT->(DBSetOrder(1))
			if LEN(aLinha) >= POS_CC .AND. !EMPTY(aLinha[POS_CC]) .AND. (CTT->(DBSEEK(xFilial('CTT')+RTRIM(aLinha[POS_CC]))))
				oModelCNB:SetValue("CNB_CC",ALLTRIM(aLinha[POS_CC]))
			ENDIF

			dbSelectArea('CTD')
			CTD->(DBSetOrder(1))
			if LEN(aLinha) >= POS_ITEMCTA .AND. !EMPTY(aLinha[POS_ITEMCTA]) .AND. (CTD->(DBSEEK(xFilial('CTD')+RTRIM(aLinha[POS_ITEMCTA]))))
				oModelCNB:SetValue("CNB_ITEMCT",ALLTRIM(aLinha[POS_ITEMCTA]) )
			ENDIF

			//Gatilha valor com desconto para a planilha
			If oModelCNB:GetValue("CNB_DESC") > 0

				nVlrPlan := oModelCNA:GetValue("CNA_VLTOT") - oModelCNB:GetValue("CNB_VLDESC")
				nVlrSald := oModelCNA:GetValue("CNA_SALDO") - oModelCNB:GetValue("CNB_VLDESC")

				oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.T.})

				oModelCNA:SetValue("CNA_VLTOT",nVlrPlan)
				oModelCNA:SetValue("CNA_SALDO",nVlrSald)

				oModel:GetModel("CNADETAIL"):GetStruct():SetProperty('CNA_VLTOT',MODEL_FIELD_WHEN,{||.F.})
			EndIf

			nCntImp++
		ELSE
			_cErros += 'Produto inválido: '+RTRIM(aLinha[POS_PROD])+' Linha:'+ALLTRIM(STR(nCntLin)) + CRLF
		ENDIF


		// oModelCNB:AddLine()
		// oModelCNB:DeleteLine(.T.,.T.)
		oModel:GetModel("CNBDETAIL"):GetStruct():SetProperty("CNB_VLUNIT",MODEL_FIELD_OBRIGAT,.T.)
		// oModel:GetModel("CNBDETAIL"):GetStruct():SetProperty("CNB_VLUNIT",MODEL_FIELD_OBRIGAT,.T.)

		lRet := !(oModel:HasErrorMessage())//O modelo não deve ter erros ao fim do processamento

		FT_FSKIP()
	ENDDO


	If oModel:HasErrorMessage()
		Aviso('',oModel:GetErrorMessage()[6])
		// oModelCNB:DeleteLine(.T.,.T.)
		oModel:SetErrorMessage("","","","",,"")
		lRet := .F.
	endif




	IF!EMPTY(_cErros)
		Help(1," ","ERRO AO INCLUIR PRODUTOS",,_cErros,3,0)
	ENDIF

	RestArea(aArea)

	// If lView
	// 	If oView:HasError()
	// 		oView:ShowLastError()
	// 	Endif
	// 	oView:Refresh('VIEW_CNB')
	// EndIf

	// aEval(aAreas, {|x| RestArea(x), FwFreeArray(x) })
	// FwFreeArray(aAreas)

	// FWRestRows(aSaveLines)
	// FwFreeArray(aSaveLines)
	// FwFreeArray(aPCs)

Return lRet

static function trataVal(cVal)
	Local nVal := strtran(cVal,',','.')

	nVal := val(nVal)
	If nVal < 0
		nVal := 0
	EndIf
return nVal
