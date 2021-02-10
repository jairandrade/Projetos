#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
USER Function SA1_MVC(xRotAuto,nOpcAuto)
	Local oMBrowseIf xRotAuto == Nil
	DEFINE FWMBROWSE oMBrowse ALIAS "SA1" DESCRIPTION "Cadastro de Clientes"
	ACTIVATE FWMBROWSE oMBrowseElse
	aRotina := MenuDef()
	FWMVCRotAuto(ModelDef(),"SA1",nOpcAuto,{{"MATA030_SA1",xRotAuto}})
Endif
Return
//-------------------------------------------------------------------
// Menu Funcional
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.SA1_MVC" OPERATION MODEL_OPERATION_VIEW 	ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.SA1_MVC" OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.SA1_MVC" OPERATION MODEL_OPERATION_UPDATE ACCESS 143
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.SA1_MVC" OPERATION MODEL_OPERATION_DELETE ACCESS 144
Return aRotina
//-------------------------------------------------------------------
// ModelDef - Modelo de dados do Cadastro de Clientes
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oModel     := Nil
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
	oModel:= MPFormModel():New("MATA030",/*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:AddFields("XXX_SA1", Nil , FWFormStruct(1,"SA1"),/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
Return(oModel)
//-------------------------------------------------------------------
// ViewDef - Visualizador de dados do Cadastro de Clientes
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oViewLocal oModel := FWLoadModel("SA1_MVC")
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "XXX_SA1" , FWFormStruct(2,"SA1"))
	oView:CreateHorizontalBox("ALL",100)
	oView:SetOwnerView("XXX_SA1","ALL")
Return oView
//-------------------------------------------------------------------
// MYTESTSA1 - Teste para rotina automatica usando MSEXECAUTO
//-------------------------------------------------------------------
User Function MYTESTSA1()
	Local oModel     := Nil
	Local nX         := 0
	RpcSetEnv("01","01")
	dbSelectArea("SA1")
	dbSetOrder(1)
	MsSeek(xFilial())
	CONOUT("Inicio: "+TIME())
	oModel := FWLoadModel("SA1_MVC")
	For nX := 50 To 51
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
		oModel:SetValue("XXX_SA1","A1_COD",StrZero(nX,6))
		oModel:SetValue("XXX_SA1","A1_LOJA","01")
		oModel:SetValue("XXX_SA1","A1_TIPO","R")
		oModel:SetValue("XXX_SA1","A1_NOME","TOTVS S/A")
		oModel:SetValue("XXX_SA1","A1_NREDUZ","TOTVS")
		oModel:SetValue("XXX_SA1","A1_END","AV. BRAZ LEME, 1631")
		oModel:SetValue("XXX_SA1","A1_BAIRRO","SANTANA")
		oModel:SetValue("XXX_SA1","A1_MUN","SAO PAULO")
		oModel:SetValue("XXX_SA1","A1_EST","SP")
		oModel:SetValue("XXX_SA1","A1_COD_MUN","50308")
		oModel:SetValue("XXX_SA1","A1_CEP","02511000")
		oModel:SetValue("XXX_SA1","A1_PESSOA","F")
		If oModel:VldData()
			oModel:CommitData()
		Else
			VarInfo("",oModel:GetErrorMessage())
		EndIf
		oModel:DeActivate()
	Next nX
	CONOUT("Fim Inclusão: "+TIME())
	CONOUT("Inicio Alteração: "+TIME())
	SA1->(MsSeek(xFilial("SA1")+"000050",.T.))
	// pesquisa o cliente 000050 para alterá-lo
	ConOut("Time Ini:"+Time())
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()
	oModel:SetValue("XXX_SA1","A1_NOME","TESTE")
	If oModel:VldData()
		ConOut("Time Commit:"+Time())
		oModel:CommitData()
	Else
		VarInfo("",oModel:GetErrorMessage())
	EndIf
	oModel:DeActivate()CONOUT("Fim Alteração: "+TIME())
	CONOUT("Inicio Exclusão: "+TIME())
	SA1->(MsSeek(xFilial("SA1")+"000051",.T.))
	// pesquisa o cliente 000051 para excluí-lo
	ConOut("Time Ini:"+Time())oModel:SetOperation(MODEL_OPERATION_DELETE)
	oModel:Activate()ConOut("Time Commit:"+Time())
	oModel:CommitData()
	oModel:DeActivate()CONOUT("Fim Exclusão: "+TIME())
	CONOUT("Inicio: "+TIME())
// inclui 2 registros pela rotina do padrão MyMata030()
	CONOUT("Fim: "+TIME())
	RpcClearEnv()
Return
Static Function MyMata030()
	Local aCabec    := {}
	Local cCodCli   := ""
	Local nX
	PRIVATE lMsErroAuto := .F.
	cCodCli := Soma1("000051")
	For nX := 1 To 2
		aCabec := {}
		aadd(aCabec,{"A1_COD"   ,cCodCli,})
		aadd(aCabec,{"A1_LOJA","01",})
		aadd(aCabec,{"A1_TIPO","R",})
		aadd(aCabec,{"A1_NOME","TOTVS S/A",})
		aadd(aCabec,{"A1_NREDUZ","TOTVS",})
		aadd(aCabec,{"A1_END","AV. BRAZ LEME, 1631",})
		aadd(aCabec,{"A1_BAIRRO","SANTANA",})
		aadd(aCabec,{"A1_MUN","SAO PAULO",})
		aadd(aCabec,{"A1_EST","SP",})
		aadd(aCabec,{"A1_COD_MUN","50308",})
		aadd(aCabec,{"A1_CEP","02511000",})
		aadd(aCabec,{"A1_PESSOA","F",})
		MATA030(aCabec,3)
		cCodCli := Soma1(cCodCli)
	Next nX
Return(.T.)





