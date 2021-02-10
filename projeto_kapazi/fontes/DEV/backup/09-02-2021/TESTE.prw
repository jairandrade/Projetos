#INCLUDE 'FWMVCDEF.CH'

//Inclusão de um roteiro
User Function incRot()
	Local oModel, oMdlDet, oMdlH3
	Local cErro  := ""
	Local lRet   := .T.

	INCLUI := .T.
	ALTERA := .F.

	oModel := FWLoadModel('MATA632') //Carrega o modelo do programa MATA632

	oModel:SetOperation(MODEL_OPERATION_INSERT) //Seta a operação de inclusão no modelo.

	If oModel:Activate() //Ativa o modelo.
		If !oModel:SetValue("MATA632_CAB","G2_CODIGO" , "02") //Atribui o código do roteiro no modelo. (G2_CODIGO)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf
		If lRet .And. !oModel:SetValue("MATA632_CAB","G2_PRODUTO", "PRD_EXEMPLO") //Atribui o código do produto no modelo. (G2_PRODUTO)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf

		oMdlDet := oModel:GetModel("MATA632_SG2") //Recupera o submodelo detalhe.

		If lRet .And. !oMdlDet:SetValue("G2_OPERAC","10") //Atribui o código da operação no modelo. (G2_OPERAC)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf
		If lRet .And. !oMdlDet:SetValue("G2_DESCRI","OPERAC. TESTE") //Atribui a descrição da operação no modelo. (G2_DESCRI)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf
		If lRet .And. !oMdlDet:SetValue("G2_RECURSO","REC01") //Atribui o código do recurso no modelo. (G2_RECURSO)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf
		If lRet .And. !oMdlDet:SetValue("G2_SETUP",1) //Atribui o tempo de setup no modelo. (G2_SETUP)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf
		If lRet .And. !oMdlDet:SetValue("G2_LOTEPAD",100) //Atribui o lote padrão no modelo. (G2_LOTEPAD)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf
		If lRet .And. !oMdlDet:SetValue("G2_TEMPAD",1) //Atribui o tempo padrão no modelo. (G2_TEMPAD)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf
		If lRet .And. !oMdlDet:SetValue("G2_TPOPER",'1') //Atribui o tipo de operação no modelo. (G2_TPOPER)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf
		If lRet .And. !oMdlDet:SetValue("G2_CTRAB",'CT01') //Atribui o Centro de trabalho no modelo. (G2_CTRAB)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf


		If lRet
			//Adiciona recursos alternativos.
			oMdlH3 := oModel:GetModel("MATA632_SH3_R")
			If !oMdlH3:SetValue("H3_RECALTE",'REC02') //Atribui o Recurso alternativo
				//Se ocorreu algum erro na atribuição, recupera o erro.
				cErro := u_getErr(oModel)
				lRet := .F.
			EndIf
			If lRet .And. !oMdlH3:SetValue("H3_TIPO",'A') //Atribui o Tipo do Recurso alternativo
				//Se ocorreu algum erro na atribuição, recupera o erro.
				cErro := u_getErr(oModel)
				lRet := .F.
			EndIf

			//Adiciona um novo recurso alternativo
			If lRet .And. !oMdlH3:AddLine()
				lRet := .F.
				cErro := u_getErr(oModel)
			EndIf

			If lRet .And. !oMdlH3:SetValue("H3_RECALTE",'REC03') //Atribui o Recurso alternativo
				//Se ocorreu algum erro na atribuição, recupera o erro.
				cErro := u_getErr(oModel)
				lRet := .F.
			EndIf
			If lRet .And. !oMdlH3:SetValue("H3_TIPO",'A') //Atribui o Tipo do Recurso alternativo
				//Se ocorreu algum erro na atribuição, recupera o erro.
				cErro := u_getErr(oModel)
				lRet := .F.
			EndIf
		EndIf

		If lRet .And. !oMdlDet:AddLine() //Adiciona uma nova linha no modelo detalhe
			//Se ocorreu algum erro ao adicionar uma nova linha, recupera o erro
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf

		If lRet .And. !oMdlDet:SetValue("G2_OPERAC","20") //Atribui o código da operação no modelo. (G2_OPERAC)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf
		If lRet .And. !oMdlDet:SetValue("G2_DESCRI","OPERAC. TESTE 2") //Atribui a descriçãoo da operação no modelo. (G2_DESCRI)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf
		If lRet .And. !oMdlDet:SetValue("G2_RECURSO","REC02") //Atribui o código do recurso no modelo. (G2_RECURSO)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf
		If lRet .And. !oMdlDet:SetValue("G2_SETUP",0) //Atribui o tempo de setup no modelo. (G2_SETUP)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf
		If lRet .And. !oMdlDet:SetValue("G2_LOTEPAD",90) //Atribui o lote padrão no modelo. (G2_LOTEPAD)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf
		If lRet .And. !oMdlDet:SetValue("G2_TEMPAD",1) //Atribui o tempo padrão no modelo. (G2_TEMPAD)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf
		If lRet .And. !oMdlDet:SetValue("G2_TPOPER",'1') //Atribui o tipo de operação no modelo. (G2_TPOPER)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf
		If lRet .And. !oMdlDet:SetValue("G2_CTRAB",'CT01') //Atribui o Centro de trabalho no modelo. (G2_CTRAB)
			//Se ocorreu algum erro na atribuição, recupera o erro.
			cErro := u_getErr(oModel)
			lRet := .F.
		EndIf

		If lRet
			//Adiciona recursos alternativos.
			oMdlH3 := oModel:GetModel("MATA632_SH3_R")
			If !oMdlH3:SetValue("H3_RECALTE",'REC03') //Atribui o Recurso alternativo
				//Se ocorreu algum erro na atribuição, recupera o erro.
				cErro := u_getErr(oModel)
				lRet := .F.
			EndIf
			If lRet .And. !oMdlH3:SetValue("H3_TIPO",'A') //Atribui o Tipo do Recurso alternativo
				//Se ocorreu algum erro na atribuição, recupera o erro.
				cErro := u_getErr(oModel)
				lRet := .F.
			EndIf
		EndIf

		If lRet
			If oModel:VldData() //Valida as informações
				lRet := oModel:CommitData() //Efetiva o cadastro.
				If !lRet
					cErro := u_getErr(oModel)
				EndIf
			Else
				cErro := u_getErr(oModel)
				lRet := .F.
			EndIf
		EndIf
		oModel:DeActivate() //Desativa o modelo.
	Else
		lRet := .F.
	EndIf

Return lRet
