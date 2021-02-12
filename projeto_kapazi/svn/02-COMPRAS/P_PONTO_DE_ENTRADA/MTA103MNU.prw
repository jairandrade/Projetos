#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: MTA103MNU		|	Autor: Luis Paulo							|	Data: 05/11/2019	//
//==================================================================================================//
//	Descrição: PE para adicionar menu no documento de entrada										//
//																									//
//==================================================================================================//
User Function MTA103MNU()
Local nX	:= 0

If cEmpAnt == "04"	
	For nX := 1 to Len(aRotina)
		if ValType(aRotina[nX][2]) == "C" 
			If aRotina[nX][2] == "A103Devol"
				aRotina[nX][2] := "u_MyRetorno"
			EndIf
		Endif
	Next
EndIf

//aAdd(aRotina,{ "Retornar(Kapazi)", "U_ValRetCl", 0 , 2, 0, .F.})
	
Return()


User Function MyRetorno(cAlias,nReg,nOpcx)
Private _lFornec	:= .F.
	
AbreTelP()	//Abre a tela e desbloqueia o cliente ou fornecedor

SA103Devol(cAlias,nReg,nOpcx)

u_DesGeral(__cUserId,"MATA103") //Bloqueia o cliente ou fornecedor

/*
Local ccliente	:= ""
Local cLoja		:= ""
Local lDesblq	:= .F.
Private _dDataInc	:= Date()
Private _cHrInc		:= Time()

If !Pergunte("CLIENTE   ",.T.)
	Return
EndIf

ccliente := mv_par01

If !Empty(mv_par02)
		cLoja	 := mv_par02
	Else
		cLoja	 := "01"
EndIf
SA1->( DbSetOrder(1) )
If SA1->(MsSeek(xFilial("SA1") + ccliente + cloja)) 
		If SA1->A1_MSBLQL == '1'
			DbSelectArea("ZBL")
			Reclock("ZBL",.T.)
			ZBL->ZBL_FILIAL	:= xFilial("SF1")
			ZBL->ZBL_DOC	:= ""
			ZBL->ZBL_SERIE	:= ""
			ZBL->ZBL_CLIENT	:= ccliente
			ZBL->ZBL_LOJA	:= cLoja
			ZBL->ZBL_ITEM	:= ""
			ZBL->ZBL_COD	:= ""
			ZBL->ZBL_PEDIDO	:= ""
			//ZBL->ZBL_EMISSA	:= ""
			ZBL->ZBL_CCUSTO	:= ""
			ZBL->ZBL_PROCES	:= "SA1"
			ZBL->ZBL_IDUSER	:= __cUserId
			ZBL->ZBL_DSUSER	:= UsrFullName(__cUserID)
			ZBL->ZBL_XID	:= ""
			ZBL->ZBL_ROTINA	:= "MATA103"
			ZBL->ZBL_DTINC 	:= _dDataInc
			ZBL->ZBL_TIMEIN	:= _cHrInc
			ZBL->(MsUnlock())	
	
			//Efetua o desbloqueio
			DbSelectArea("SA1")
			Reclock("SA1",.F.)
			SA1->A1_MSBLQL := "2"
			SA1->(MsUnlock())
			
			lDesblq	:= .T.
		EndIf
	Else
		MsgAlert("Cliente nao localizado!","Kapazi")
		Return
Endif

SA103Devol(cAlias,nReg,nOpcx)

If lDesblq
	xDesbCli(__cUserId)
EndIf
*/
Return()

//Abre a parambox para informar cliente ou fornecedor e desbloquear
Static Function AbreTelP()
Local cTDataDe  := "Dt. Entrada De" //-- 
Local cTDataAte := "Dt. Entrada Ate" //-- 
Local cTFornece := RetTitle("F1_FORNECE")
Local cTLoja    := RetTitle("F1_LOJA")
Local nOpcao    := 0
Local lCliente  := .F.
Local lDocto    := .F.
Local oDlgEsp
Local oCliente
Local oForn
Local oDocto 
Local oFornece
Local oPanelCli
Local oPanelFor
Local lFornece  := .F.
Private lForn   := .T.
Private cFornece := Space(6)
Private cLoja 	:= Space(2)
Private _dDataInc	:= Date()
Private _cHrInc		:= Time()

DEFINE MSDIALOG oDlgEsp FROM 00,00 TO 190,490 PIXEL TITLE OemToAnsi("Retorno de Doctos. de Saida - Kapazi")

	@ 02,10 CHECKBOX oForn VAR lForn PROMPT OemToAnsi ("Fornecedor") SIZE 50,010 ;
		ON CLICK( lCliente := .F., oCliente:Refresh(), A410CliF(lForn,@lFornece,@lDocto,oDocto,oFornece,oDlgEsp,oPanelCli,oPanelFor)) OF oDlgEsp PIXEL //-- Fornecedor

	@ 02,120 CHECKBOX oCliente VAR lCliente PROMPT OemToAnsi("Cliente") SIZE 50,010 ;
		ON CLICK( lForn := .F., oForn:Refresh(), A410CliF(lForn,@lFornece,@lDocto,oDocto,oFornece,oDlgEsp,oPanelCli,oPanelFor)) OF oDlgEsp PIXEL //-- Cliente


	@ 018,000 MSPANEL oPanelCli OF oDlgEsp SIZE 245,020               

	@ 018,000 MSPANEL oPanelFor OF oDlgEsp SIZE 245,020

	cTFornece := RetTitle("F1_FORNECE")
	cTLoja    := RetTitle("F2_LOJA")
	@ 001,05 SAY cTFornece PIXEL SIZE 47 ,9 OF oPanelFor
	@ 001,40 MSGET cFornece F3 'FOR' SIZE 65, 10 OF oPanelFor PIXEL

	@ 001,120 SAY cTLoja PIXEL OF oPanelFor
	@ 001,160 MSGET cLoja SIZE 20, 10 OF oPanelFor PIXEL 

	cTLoja    := RetTitle("F2_LOJA")
	@ 001,05 SAY RetTitle("F2_CLIENTE") PIXEL SIZE 50 ,10 OF oPanelCli
	@ 001,40 MSGET cFornece F3 'SA1' SIZE 65, 10 OF oPanelCli PIXEL

	@ 001,120 SAY cTLoja PIXEL OF oPanelCli
	@ 001,160 MSGET cLoja SIZE 20, 10 OF oPanelCli PIXEL 
	oPanelCli:Hide()

	DEFINE SBUTTON FROM 05,215 TYPE 1 OF oDlgEsp ENABLE ACTION If(!Empty(cFornece) .And. !Empty(cLoja) ,(nOpcao := 1,oDlgEsp:End()),.F.)
	DEFINE SBUTTON FROM 20,215 TYPE 2 OF oDlgEsp ENABLE ACTION (nOpcao := 0,oDlgEsp:End())

ACTIVATE MSDIALOG oDlgEsp CENTERED

If nOpcao == 1 //Confirmou
	
	If Empty(cLoja)
		cLoja	 := "01"
	EndIf
	
	If lForn //Selecionado fornecedor
			SA2->( DbSetOrder(1) )
			If SA2->(MsSeek(xFilial("SA2") + cFornece + cloja)) 
					If SA2->A2_MSBLQL == '1'
						DbSelectArea("ZBL")
						Reclock("ZBL",.T.)
						ZBL->ZBL_FILIAL	:= xFilial("SF1")
						ZBL->ZBL_DOC	:= ""
						ZBL->ZBL_SERIE	:= ""
						ZBL->ZBL_CLIENT	:= cFornece
						ZBL->ZBL_LOJA	:= cLoja
						ZBL->ZBL_ITEM	:= ""
						ZBL->ZBL_COD	:= ""
						ZBL->ZBL_PEDIDO	:= ""
						//ZBL->ZBL_EMISSA	:= ""
						ZBL->ZBL_CCUSTO	:= ""
						ZBL->ZBL_PROCES	:= "SA2"
						ZBL->ZBL_IDUSER	:= __cUserId
						ZBL->ZBL_DSUSER	:= UsrFullName(__cUserID)
						ZBL->ZBL_XID	:= ""
						ZBL->ZBL_ROTINA	:= "MATA103"
						ZBL->ZBL_DTINC 	:= _dDataInc
						ZBL->ZBL_TIMEIN	:= _cHrInc
						ZBL->(MsUnlock())	
				
						//Efetua o desbloqueio
						DbSelectArea("SA2")
						Reclock("SA2",.F.)
						SA2->A2_MSBLQL := "2"
						SA2->(MsUnlock())
					EndIf
				
				Else
					MsgAlert("Fornecedor nao localizado!","Kapazi")
			EndIf
			
		Else
			SA1->( DbSetOrder(1) )
			If SA1->(MsSeek(xFilial("SA1") + cFornece + cloja)) 
					If SA1->A1_MSBLQL == '1'
						DbSelectArea("ZBL")
						Reclock("ZBL",.T.)
						ZBL->ZBL_FILIAL	:= xFilial("SF1")
						ZBL->ZBL_DOC	:= ""
						ZBL->ZBL_SERIE	:= ""
						ZBL->ZBL_CLIENT	:= cFornece
						ZBL->ZBL_LOJA	:= cLoja
						ZBL->ZBL_ITEM	:= ""
						ZBL->ZBL_COD	:= ""
						ZBL->ZBL_PEDIDO	:= ""
						//ZBL->ZBL_EMISSA	:= ""
						ZBL->ZBL_CCUSTO	:= ""
						ZBL->ZBL_PROCES	:= "SA1"
						ZBL->ZBL_IDUSER	:= __cUserId
						ZBL->ZBL_DSUSER	:= UsrFullName(__cUserID)
						ZBL->ZBL_XID	:= ""
						ZBL->ZBL_ROTINA	:= "MATA103"
						ZBL->ZBL_DTINC 	:= _dDataInc
						ZBL->ZBL_TIMEIN	:= _cHrInc
						ZBL->(MsUnlock())	
				
						//Efetua o desbloqueio
						DbSelectArea("SA1")
						Reclock("SA1",.F.)
						SA1->A1_MSBLQL := "2"
						SA1->(MsUnlock())
					EndIf
				
				Else
					MsgAlert("Cliente nao localizado!","Kapazi")
			EndIf
	EndIf
	
EndIf
	
Return()

//Mudar o foco de fornecedor x cliente
Static Function A410CliF(lForn,lFornece,lDocto,oDocto,oFornece,oDlgEsp,oPanelCli,oPanelFor)
//-- Se Clicou em Fornecedor
If lForn
		oPanelCli:Hide()
		oPanelFor:Show()
	Else //-- Se Clicou em Cliente
		oPanelFor:Hide()
		oPanelCli:Show()
EndIf

If lFornece
		lDocto := .F.
		oDocto:Refresh()
	ElseIf lDocto
		 lFornece := .F.
		 oFornece:Refresh() 
EndIf

oDlgEsp:SetFocus()
oDlgEsp:Refresh()

Return .T.

/*
//Funcao responsavel por bloqueio novamente do cliente
Static Function xDesbCli(cIdUser)
// variaveis auxiliares
local cQr := ""
local aArea := GetArea()

// recupera os dados dos bloqueios
cQr := " SELECT R_E_C_N_O_ AS RECORECO,*
cQr += " FROM ZBL040
cQr += " WHERE D_E_L_E_T_ = ''
cQr += " AND ZBL_IDUSER = '"+ cIdUser +"'
cQr += " AND ZBL_FILIAL = '"+ xFilial("SF1") +"'
cQr += " AND ZBL_PROCES = 'SA1'
cQr += " AND ZBL_ROTINA	= 'MATA103' "

// abre a query
TcQuery cQr new alias "QZBL"

While !QZBL->(Eof())

	// localiza o cliente
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())
	If SA1->(DbSeek(XFilial("SA1") + QZBL->ZBL_CLIENT + QZBL->ZBL_LOJA))

		//bloqueia o cliente
		RecLock("SA1", .F.)
		SA1->A1_MSBLQL := "1"
		MsUnlock()
		
		DbSelectArea("ZBL")
		ZBL->(DbGoTo(QZBL->RECORECO))
		RecLock("ZBL",.F.)
		DbDelete()
		ZBL->(MsUnlock())
	EndIf

	// proximo registro
	QZBL->(DbSkip())

EndDo

QZBL->(DbCloseArea())
RestArea(aArea)
Return()
*/