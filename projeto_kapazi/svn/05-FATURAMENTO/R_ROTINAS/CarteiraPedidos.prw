#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOTVS.CH" 
#INCLUDE "FWMVCDEF.CH"

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Demonstra Carteira de Pedidos de Venda.                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 29/06/2020                                              !
+------------------+--------------------------------------------------------*/
User Function CartePed()
Local oFWDialog    := Nil
Local oPanelDlg    := Nil
Local oFWLayer     := Nil
Local oWinUp       := Nil
Local oWinCenter   := Nil
Local oWinDown     := Nil
Local nCorBack     := 0 
Local nCorFont     := 0
Local aRGB         := {}
Local nLuminance   := 0	
Local oBtnOK	   := LoadBitmap(GetResources(), "LBOK")
Local oBtnNO	   := LoadBitmap(GetResources(), "LBNO")
Local nPosColumn   := 0
Local oFont01      := TFont():New("Arial",,017,,.T.,,,,,.F.,.F.)
Local nTotWidth    := 0
Local oFiltrFil    := Nil
Local oFiltrSit    := Nil
Local oFiltrGen    := Nil 
Local oFiltEmDe    := Nil
Local oFiltEmAte   := Nil
Local oCheckNF     := Nil
Local lNewCheck    := .F.
Local cUsrAcesso   := SuperGetMv("KP_ACESSCP",,"000000")
Local cCodigoUsr   := RetCodUsr()  
Private aFiltrFil  := BuildFilter(1)
Private aFiltrSit  := {}
Private cFiltrGen  := Space(40)
Private dFiltEmDe  := MonthSub(Date(),6)
Private dFiltEmAte := SToD("")
Private lCheckNF   := .F.
Private oGetObsPed := Nil		
Private oBrowse    := Nil
Private aSitPedVen := {}
Private aIndicador := {{Nil,"COUNT(*)","Qtde Pedidos",0,"@E 999,999,999"},;
				       {Nil,"SUM(C5_XTOTMER)",FWX3Titulo("C5_XTOTMER"),0,"@E 999,999,999,999.99"}}				       
			      
Begin Sequence

/*
If !cCodigoUsr $ cUsrAcesso
	MsgInfo("<html><b>Rotina Bloqueada</b>"+;
		"<br>Solicite acesso ao Departamento de Tecnologia"+;
		"<br>Código Usr: <b>" + cCodigoUsr + "</b></html>") 
	Break
EndIf  
*/

If !cEmpAnt $ "01|04" //Para liberar outras Empresas, excluir o campo C5_MSBLQL, pois interfere no método SetBlkBackColor
	Break
EndIf

//Situação dos Pedidos de Venda
dbSelectArea("SX5")
SX5->(dbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE
If SX5->(dbSeek(xFilial("SX5")+"ZD"))
	While !SX5->(Eof()) .And. SX5->(X5_FILIAL+X5_TABELA) == xFilial("SX5")+"ZD"			 
		If IsDigit(AllTrim(SX5->X5_DESCSPA))
			nCorBack   := Val(SX5->X5_DESCSPA)			
			aRGB       := ColorToRGB(nCorBack)
			nLuminance := (0.299 * aRGB[1] + 0.587 * aRGB[2] + 0.114 * aRGB[3])/255
			
			If nLuminance > 0.5
				nCorFont := 0        //Bright colors - Black font
			Else
				nCorFont := 16777215 //Dark colors - White font
			EndIf						
		Else
			nCorBack := Nil
			nCorFont := Nil
		EndIf		 
		
		Aadd(aSitPedVen, {PadR(SX5->X5_CHAVE, TamSx3("C5_XSITLIB")[1]),; //Código da Situação
			              AllTrim(SX5->X5_DESCRI),;                      //Descrição da Situação
			              nCorBack,;                                     //Cor do Fundo da Linha
			              nCorFont})                                     //Cor da Font da Linha						
		Aadd(aFiltrSit, {.T., PadR(SX5->X5_CHAVE, TamSx3("C5_XSITLIB")[1]), AllTrim(SX5->X5_DESCRI)})
		
		SX5->(dbSkip())
	EndDo		
EndIf  
aSort(aFiltrSit,,,{|x,y| PadL(AllTrim(x[2]),2,"0") < PadL(AllTrim(y[2]),2,"0")})

oFWDialog := FWDialogModal():New()	
oFWDialog:SetBackground(.F.)          		            		           
		             	 	
oFWDialog:SetEscClose(.T.)                 
oFWDialog:EnableAllClient()	
oFWDialog:EnableFormBar(.T.)
oFWDialog:CreateDialog()	

oPanelDlg := oFWDialog:GetPanelMain()

//Cria Layers
oFWLayer := FWLayer():New()
oFWLayer:Init(oPanelDlg,.T.)

oFWLayer:AddLine("L_UP",30,.T.)
oFWLayer:AddCollumn("C_UP",80,.T.,"L_UP")
oFWLayer:AddWindow("C_UP","W_UP", "Filtros",100,.F.,.F.,{||},"L_UP")
oWinUp  := oFWLayer:GetWinPanel("C_UP","W_UP","L_UP")

oFWLayer:AddCollumn("C_UP2",20,.T.,"L_UP")
oFWLayer:AddWindow("C_UP2","W_UP2", "Observação do Pedido",100,.F.,.F.,{||},"L_UP")
oWinUp2 := oFWLayer:GetWinPanel("C_UP2","W_UP2","L_UP")

oFWLayer:AddLine("L_CENTER",55,.T.)
oFWLayer:AddCollumn("C_CENTER",100,.T.,"L_CENTER")
oFWLayer:AddWindow("C_CENTER","W_CENTER","Pedidos de Venda",100,.F.,.F.,{||},"L_CENTER")
oWinCenter := oFWLayer:GetWinPanel("C_CENTER","W_CENTER","L_CENTER")

oFWLayer:AddLine("L_DOWN",15,.T.)
oFWLayer:AddCollumn("C_DOWN",100,.T.,"L_DOWN")
oFWLayer:AddWindow("C_DOWN","W_DOWN","Indicadores",100,.F.,.F.,{||},"L_DOWN")
oWinDown := oFWLayer:GetWinPanel("C_DOWN","W_DOWN","L_DOWN")

//Calcula dimensões para aproveitamento máximo da tela de acordo com a resolução
nTotWidth  := (oWinUp:nWidth/2) - 30 //Subtrai espaçamentos 

//Filtro por Filial
oFiltrFil := TCBrowse():New(0,0,nTotWidth*0.25,oWinUp:nHeight/2,,,,oWinUp,,,,,,,,,,,,,,.T.,,,,.T.)
oFiltrFil:AddColumn(TCColumn():New("  ",    {|| Iif(aFiltrFil[oFiltrFil:nAt,1],oBtnOK,oBtnNO)},,,,,010,.T.,.F.,,,,,))
oFiltrFil:AddColumn(TCColumn():New("Filial",{|| aFiltrFil[oFiltrFil:nAt,2]},,,,,020,.F.,.F.,,,,,))				
oFiltrFil:AddColumn(TCColumn():New("Nome",  {|| aFiltrFil[oFiltrFil:nAt,3]},,,,,050,.F.,.F.,,,,,))
oFiltrFil:SetArray(aFiltrFil)
oFiltrFil:bLDblClick := {|| aFiltrFil[oFiltrFil:nAT,1] := !aFiltrFil[oFiltrFil:nAT,1], ExecFilter(1)}
oFiltrFil:bHeaderClick := {|oObj,nCol| Iif(nCol = 1,;
	(lNewCheck := !aFiltrFil[1][1], aEval(aFiltrFil, {|x| x[1] := lNewCheck})), Nil),; 
	oFiltrFil:Refresh(), ExecFilter(1)}  
nPosColumn += 10+nTotWidth*0.25

//Filtro por Situação
oFiltrSit := TCBrowse():New(0,nPosColumn,nTotWidth*0.25,oWinUp:nHeight/2,,,,oWinUp,,,,,,,,,,,,,,.T.,,,,.T.)
oFiltrSit:AddColumn(TCColumn():New("  ",          {|| Iif(aFiltrSit[oFiltrSit:nAt,1],oBtnOK,oBtnNO)},,,,,010,.T.,.F.,,{|| ExecFilter(2)},,,))
oFiltrSit:AddColumn(TCColumn():New("Sit Liberac", {|| aFiltrSit[oFiltrSit:nAt,2]},,,,,030,.F.,.F.,,,,,))				
oFiltrSit:AddColumn(TCColumn():New("Situação",    {|| aFiltrSit[oFiltrSit:nAt,3]},,,,,050,.F.,.F.,,,,,))
oFiltrSit:SetArray(aFiltrSit)
oFiltrSit:bLDblClick := {|| aFiltrSit[oFiltrSit:nAT,1] := !aFiltrSit[oFiltrSit:nAT,1], ExecFilter(2)}
oFiltrSit:bHeaderClick := {|oObj,nCol| Iif(nCol = 1,;
	(lNewCheck := !aFiltrSit[1][1], aEval(aFiltrSit, {|x| x[1] := lNewCheck})), Nil),; 
	oFiltrSit:Refresh(), ExecFilter(2)}  
oFiltrSit:SetBlkBackColor({|| SetCorBack(aFiltrSit[oFiltrSit:nAt][2])})
oFiltrSit:SetBlkColor({|| SetCorFont(aFiltrSit[oFiltrSit:nAt][2])})
nPosColumn += 10+nTotWidth*0.25

//Filtra informações genéricas conforme necessidade
oFiltrGen := TGet():New(0,nPosColumn, bSetGet(cFiltrGen),oWinUp, nTotWidth*0.25,12,"@!",{|| ExecFilter(3)},,,;
				oFont01,.F.,,.T.,,.F.,,.F.,.F.,,,.F.,Nil,"cFiltrGen",,,,,,,"Consultas (Nome Cliente/Pedido/NF)",1,oPanelDlg:oFont)

//Filtra Emissão
oFiltEmDe := TGet():New(24,nPosColumn, bSetGet(dFiltEmDe),oWinUp, 60, 12, "@!",{|| ExecFilter(4)},,,;
	oFont01,.F.,,.T.,,.F.,,.F.,.F.,,,.F.,,"dFiltEmDe",,,,,,,"Emissão De",1,oPanelDlg:oFont)

oFiltEmAte := TGet():New(24,nPosColumn+65, bSetGet(dFiltEmAte),oWinUp, 60, 12, "@!",{|| ExecFilter(5)},,,;
	oFont01,.F.,,.T.,,.F.,,.F.,.F.,,,.F.,,"dFiltEmAte",,,,,,,"Emissão Até",1,oPanelDlg:oFont)				

//Filtra Pedidos com Nota Fiscal
oCheckNF := TCheckBox():New(48,nPosColumn,"Somente Pedidos com Nota Fiscal",;
		 				 {|u| If(PCount()=0, lCheckNF, lCheckNF := u)},;
					     oWinUp,100,12,,{|| ExecFilter(6)},,,,,,.T.,,,)
nPosColumn += 10+nTotWidth*0.25

//Limpa Filtros Aplicados - Restaura default
oBmpCleanF := TBtnBmp2():New(00,oWinUp:nWidth-25,25,25,"KP_LIMPAFILTRO.png",,,,{||;
	aEval(aFiltrFil, {|x| x[1] := .T.}), oFiltrFil:Refresh(),  ExecFilter(1),;  //Filiais
	aEval(aFiltrSit, {|x| x[1] := .T.}), oFiltrSit:Refresh(),  ExecFilter(2),;  //Situação
	cFiltrGen  := Space(40),             oFiltrGen:Refresh(),  ExecFilter(3),;  //Pesquisa Genérica (Cliente/Pedido/NF)
	dFiltEmDe  := MonthSub(Date(),6),    oFiltEmDe:Refresh(),  ExecFilter(4),;  //Data de Emissão De
	dFiltEmAte := SToD(""),              oFiltEmAte:Refresh(), ExecFilter(5),;  //Data de Emissão Até  
	lCheckNF   := .F.,                   oCheckNF:Refresh(),   ExecFilter(6)},; //Somente Pedidos com Nota Fiscal
	oWinUp,,,.T.)

//Observação do Pedido
oGetObsPed := TMultiGet():new(15,20,{|u| If(pCount() > 0, SC5->C5_MSGCLI := u, SC5->C5_MSGCLI)},;
		oWinUp2,210,30,,,,,,.T.,,,/*{|| .F.}*/,,,.T.,,,,,,"",1,,16744448)				
oGetObsPed:Align := CONTROL_ALIGN_ALLCLIENT

//Indicadores
nPosColumn := 0
For nX := 1 To Len(aIndicador)
	TSay():New(01,nPosColumn,&("{|| aIndicador[" + cValToChar(nX) + "][3]}"),oWinDown,,oPanelDlg:oFont,,,,.T.,,,60,16)
	
	aIndicador[nX][1] := TSay():New(08,nPosColumn,;
		&("{|| AllTrim(Transform(aIndicador[" + cValToChar(nX) + "][4],aIndicador[" + cValToChar(nX) + "][5]))}"),;
		oWinDown,,oFont01,,,,.T.,8388672,,60,16)
	nPosColumn += 50
Next nX

//Cria MBrowse
BuildBrowse(oWinCenter)

oFWDialog:AddButtons({{"","Fechar",     {|| oBrowse:VerifyLayout(), oFWDialog:Deactivate()},"",,.T.,.T.}})
oFWDialog:AddButtons({{"","Configurar", {|| oBrowse:Config()},"",,.T.,.T.}})
oFWDialog:AddButtons({{"","Visualizar", {|| U_CPAcoes(1)},"",,.T.,.T.}})
oFWDialog:AddButtons({{"","Histórico",  {|| U_CPAcoes(2)},"",,.T.,.T.}})
oFWDialog:AddButtons({{"","Imprimir",   {|| oBrowse:Report()},"",,.T.,.T.}})

oFWDialog:SetInitBlock({|| ExecFilter(4)})		
oFWDialog:Activate()

End Sequence
Return Nil

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Cria Browse para os registros conforme parâmetros.      !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 29/06/2020                                              !
+------------------+--------------------------------------------------------*/
Static Function BuildBrowse(oOwner)
Local aColumns   := {}
Local nX         := 0
Local aOnlyField := {"C5_NUM",     "C5_CLIENTE", "C5_LOJACLI", "C5_NOMECLI", "C5_XTOTMER", "C5_XSITLIB",;
					 "C5_XSITLIN", "C5_NOTA",    "C5_XDESSTA", "C5_EMISSAO", "C5_FILIAL"}
		             		                       		             		            
oBrowse := FWMBrowse():New()
oBrowse:SetAlias("SC5")
oBrowse:SetOwner(oOwner) 
oBrowse:DisableDetails()
oBrowse:SetWalkThru(.F.)
oBrowse:SetAmbiente(.F.)
oBrowse:SetAttach(.F.)
oBrowse:SetUseFilter(.F.)
oBrowse:SetUseCaseFilter(.F.)
oBrowse:SetSeek(.F.)
oBrowse:SetOnlyFields(aOnlyField)
oBrowse:OptionReport(.F.)
oBrowse:DisableReport()
oBrowse:SetBlkBackColor({|| SetCorBack(SC5->C5_XSITLIB)})
oBrowse:SetBlkColor({|| SetCorFont(SC5->C5_XSITLIB)})
oBrowse:SetChange({|| oGetObsPed:Refresh()})
oBrowse:Activate()
Return Nil

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Customiza Cores no Browse (Back).                       ! 
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 29/06/2020                                              !
+------------------+--------------------------------------------------------*/
Static Function SetCorBack(cSitucao)
Local nRet    := Nil
Local nPosSit := aScan(aSitPedVen, {|x| x[1] == cSitucao})

If nPosSit > 0
	nRet := aSitPedVen[nPosSit][3]	
EndIf	 
Return nRet

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Customiza Cores no Browse (Font).                       ! 
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 29/06/2020                                              !
+------------------+--------------------------------------------------------*/
Static Function SetCorFont(cSitucao)
Local nRet    := Nil
Local nPosSit := aScan(aSitPedVen, {|x| x[1] == cSitucao})

If nPosSit > 0
	nRet := aSitPedVen[nPosSit][4]	
EndIf	 
Return nRet

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Retorna conteúdo do Filtro solicitado.                  !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 26/07/2020                                              !
+------------------+--------------------------------------------------------*/
Static Function BuildFilter(nFilter)
Local aRet     := {}	
Local aFiliais := {}
Local nX       := 0

If nFilter = 1 //Filiais
	aFiliais := FWAllFilial()
	For nX := 1 To Len(aFiliais)
		Aadd(aRet, {.T., aFiliais[nX], AllTrim(FWFilialName(cEmpAnt, aFiliais[nX], 1))})	
	Next nX
EndIf
Return aRet

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Executa Filtros.                                        ! 
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 26/07/2020                                              !
+------------------+--------------------------------------------------------*/
Static Function ExecFilter(nFiltro)
Local cFiltro    := ""
Local aFiltro    := {}
Local lFiltra    := .F.
Local nX         := 0
Local nPosFiltro := 0

Begin Sequence

If nFiltro = 1 //Filiais	
	For nX := 1 To Len(aFiltrFil)
		If aFiltrFil[nX][1]
			cFiltro += Iif(!Empty(cFiltro), " OR ", "")
			cFiltro += "C5_FILIAL = '" + aFiltrFil[nX][2] + "'
		Else						
			lFiltra := .T.
		EndIf
	Next nX				 
	If lFiltra .And. Empty(cFiltro)
		cFiltro := "1=2" //Negação lógica
	EndIf
EndIf

If nFiltro = 2 //Situação
	For nX := 1 To Len(aFiltrSit)
		If aFiltrSit[nX][1]
			cFiltro += Iif(!Empty(cFiltro), " OR ", "")
			cFiltro += "C5_XSITLIB = '" + aFiltrSit[nX][2] + "'
		Else
			lFiltra := .T.
		EndIf
	Next nX
	If lFiltra .And. Empty(cFiltro)
		cFiltro := "1=2" //Negação lógica
	EndIf
EndIf

If nFiltro = 3 //Filtra campos (Nome do Cliente, Pedido, NF)	
	If !Empty(cFiltrGen)
		aFiltro := Separa(AllTrim(cFiltrGen), " ")
		lFiltra := .T.
		
		For nX := 1 To Len(aFiltro)
			cFiltro += Iif(!Empty(cFiltro), "AND ", "")
			cFiltro += "(CHARINDEX('" + AllTrim(aFiltro[nX]) + "',UPPER(C5_NUM))>0"
			cFiltro += " OR CHARINDEX('" + AllTrim(aFiltro[nX]) + "',UPPER(C5_NOMECLI))>0"
			cFiltro += " OR CHARINDEX('" + AllTrim(aFiltro[nX]) + "',UPPER(C5_NOTA))>0)"
		Next nX	
	Endif				 
EndIf

If nFiltro = 4 //Emissão De
	If !Empty(dFiltEmDe)
		lFiltra := .T.		
		cFiltro += " C5_EMISSAO >= '" + DToS(dFiltEmDe) + "'"   	
	Endif
EndIf

If nFiltro = 5 //Emissão Até
	If !Empty(dFiltEmAte)
		lFiltra := .T.		
		cFiltro += " C5_EMISSAO <= '" + DToS(dFiltEmAte) + "'"
	Endif
EndIf

If nFiltro = 6 //Somente Pedidos com Nota Fiscal	
	If lCheckNF
		lFiltra := .T.
		cFiltro += " C5_NOTA <> ''"
	EndIf
EndIf

//Verifica necessidade de Aplicação do Filtro
nPosFiltro := aScan(oBrowse:oFWFilter:aFilter, {|x| x[9] == StrZero(nFiltro,3)})
If (nPosFiltro > 0 .And. oBrowse:oFWFilter:aFilter[nPosFiltro][2] == "@("+cFiltro+")") .Or.;
	(nPosFiltro = 0 .And. !(lFiltra .And. !Empty(cFiltro)))
	Break 
EndIf

//Elimina Filtro anterior
oBrowse:DeleteFilter(StrZero(nFiltro,3)) 

If lFiltra .And. !Empty(cFiltro)
	cFiltro := "@("+cFiltro+")"	
	oBrowse:AddFilter("Filtro Dinâmico",cFiltro,.F.,.T.,,.F.,,StrZero(nFiltro,3))
	FWMsgRun(,{|| oBrowse:Refresh(.T.), RefreshInd()}, "Aguarde", "Aplicando Filtro/Totalizando Indicadores...")
Else
	oBrowse:Refresh(.T.)
	RefreshInd()
EndIf

End Sequence
Return .T.

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Executa Ação solicitada.                                !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 29/06/2020                                              !
+------------------+--------------------------------------------------------*/
User Function CPAcoes(nAcao)
Local aArea     := GetArea()
Local aAreaSC5  := SC5->(GetArea())
Local aBkpFil   := cFilAnt
Private aRotina   := {}
Private cCadastro := ""

cFilAnt := SC5->C5_FILIAL
If nAcao = 1 //Visualização do Pedido
	cCadastro := "Visualizar - Pedido de Venda " + SC5->C5_NUM
	aRotina := StaticCall(MATA410, MenuDef)	
	A410Visual("SC5",Recno(),2)	
ElseIf nAcao = 2 //Histórico do Pedido
	cCadastro := "Histórico - Pedido de Venda " + SC5->C5_NUM
	U_KFATR15A()
EndIf
oBrowse:SetFocus()

cFilAnt := aBkpFil
RestArea(aAreaSC5)
RestArea(aArea)
Return

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Atualiza Indicadores.                                   !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 29/06/2020                                              !
+------------------+--------------------------------------------------------*/
Static Function RefreshInd()
Local cSelect    := ""
Local cFrom      := ""
Local cWhere     := ""
Local cGroup     := "" 
Local nX         := 0
Local cVirgula   := ""
Local cFilterExp := oBrowse:GetFilterExpression()

//Atualiza Indicadores
cSelect := "SELECT "
For nX := 1 To Len(aIndicador)
	cSelect   += cVirgula + aIndicador[nX][2]
	cVirgula := ", "
Next nX
cFrom  += "FROM " + RetSqlName("SC5") + " SC5 "
cWhere += "WHERE C5_FILIAL >= '' "
If !Empty(cFilterExp)
	cWhere += "	AND " + oBrowse:GetFilterExpression() + " "
EndIf
cWhere += " AND SC5.D_E_L_E_T_ = ' ' "
MpSysOpenQuery(cSelect+cFrom+cWhere, "QRY")
aStruct := QRY->(dbStruct())

For nX := 1 To Len(aStruct)
	aIndicador[nX][4] := &("QRY->"+aStruct[nX][1])
	aIndicador[nX][1]:Refresh() 
Next nX
QRY->(dbCloseArea())
Return Nil
