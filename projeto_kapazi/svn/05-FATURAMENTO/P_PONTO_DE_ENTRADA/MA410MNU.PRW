
/**********************************************************************************************************************************/
/** SIGAFAT - Faturamento                                                                                                        **/
/** Cadastro de Pedidos de Venda                                                                                                 **/
/** Alteração dos dados de volume e transportadora                                                                               **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi Indústria Brasileira Ltda.                                                                                            **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 03/07/2013 | Rogério Souza Pereira          | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH" 
#include "topconn.ch"

#Define ENTER CHR(13)+CHR(10)

/**********************************************************************************************************************************/
/** user function MA410MNU()                                                                                                     **/
/** Ponto de entrada para manipulação das rotinas do menu de Pedido de Vendas                                                    **/
/**********************************************************************************************************************************/
User Function MA410MNU()
Local aArea		:= GetArea()
Local aRotBkp 	:= aClone(aRotina)
Local lCopia	:= StaticCall(M521CART,TGetMv,"  ","KA_COPIAPV","L",.F.,"MA410MNU - Permitir o uso da funcao de 'Copiar' um pedido de venda?" )				   
Local nX		:= 0
Local lReservar	:= GetMv("KA_RESATV",,.F.)

If !lCopia
	aRotina := {}
	For nX := 1 to Len(aRotBkp)
		If UPPER( AllTrim( 'A410PCopia' ) ) $ UPPER( AllTRim( aRotBkp[nX][2] ) ) 
			Loop
		Else
			aadd(aRotina,aRotBkp[nX])
		Endif
	Next
Endif

// adiciona a rotina de alteração de volume e transportadora
AAdd(aRotina, {"Peso e Volume"					, "U_AltPesVo"		, 0, 4, 0, Nil})
AAdd(aRotina, {"Nr. Nota Fiscal"				, "U_viewNFPedido"	, 0, 2, 0, Nil})
AAdd(aRotina, {"Gerar NF Servico"				, "U_GerNFSv"		, 0, 2, 0, Nil})
AAdd(aRotina, {"Estornar Pv Sv"					, "U_ESTPVNFM"		, 0, 2, 0, Nil})
AAdd(aRotina, {"Cod Pre Aut Supplier"			, "U_PREAUTSP"		, 0, 2, 0, Nil})
AAdd(aRotina, {"Pedido aceito pela Supplier?"	, "U_KP97A07"		, 0, 4, 0, Nil})
AAdd(aRotina, {"Pedido Supplier x Kapazi?"		, "U_KP97A77"		, 0, 4, 0, Nil})

If ExistBlock("KFATR15A")
	AAdd(aRotina, {"Historico Pedido"			, "U_KFATR15A"		, 0, 2, 0, Nil})
Endif

If lReservar 
	If ExistBlock("KFATR23")
	//AAdd(aRotina, {"Reservas do pedido"			, "U_KFATR23R"		, 0, 2, 0, Nil})
	EndIf
Endif

If cEmpAnt == "04"	 //Luis - 14-11-19
	For nX := 1 to Len(aRotina)
		if ValType(aRotina[nX][2]) == "C" 
			If "A410Devol" $ aRotina[nX][2]
				aRotina[nX][2] := "u_MyRetPVK"
			EndIf
		Endif
	Next
EndIf


RestArea(aArea)
return Nil                                                        



//Luis - 14-11-19 - Chamada custmomizada do retorno, para permitir desbloquear o cliente/fornecedor
User Function MyRetPVK()
Private _lFornec	:= .F.
	
AbreTelP()	//Abre a tela e desbloqueia o cliente ou fornecedor

A410Devol('SC5',SC5->(RecNo()),4) //Chamada customizada da devolucao

u_DesGeral(__cUserId,"MATA410") //Bloqueia o cliente ou fornecedor

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

DEFINE MSDIALOG oDlgEsp FROM 00,00 TO 190,490 PIXEL TITLE OemToAnsi("Retorno de Doctos. de Entrada - Kapazi")

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
						ZBL->ZBL_ROTINA	:= "MATA410"
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
						ZBL->ZBL_ROTINA	:= "MATA410"
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







/**********************************************************************************************************************************/
/** user function AltPesVo(cAlias, nRecno, nOpc)                                                                                 **/
/** Chamada da rotina de alteração dos dados de volume e transportadora                                                          **/
/**********************************************************************************************************************************/
user function AltPesVo(cAlias, nRecno, nOpc)

	// variaveis auxiliares
	local aCpos 	:= {}
	Local aPerm		:= nil 
	Local nRet		:= 0
	// Local lBlqCpo	:= .f. //StaticCall(M521CART,TGetMv,"  ","KA_BLQCPPV","L",.T.,"M410MNU - Permitir somente a alteração de campos peso, volume e transportadora no PV" )
	
	// verifica se o pedido está faturado
	if !Empty(SC5->C5_NOTA) .or. SC5->C5_LIBEROK == 'E' .and. Empty(SC5->C5_BLQ) .and. GetMv("MV_ALTPED") != "S"
	  // alteracao de pedido faturado
	  Help(" ", 1, "A410PEDFAT")
	  return Nil
	endIf

	// adiciona ao array os campos a alterar
	/*
	AAdd(aCpos,"C5_PESOL"	)
	AAdd(aCpos,"C5_PBRUTO"	)
	AAdd(aCpos,"C5_VOLUME1"	)
	AAdd(aCpos,"C5_ESPECI1"	)
	AAdd(aCpos,"C5_TRANSP"	)
	AAdd(aCpos,"C5_TPFRETE"	)
	AAdd(aCpos,"C5_XDTLIBP"	)
	AAdd(aCpos,"C5_REF10"	)
	*/

	AAdd(aCpos,"C5_NOMECLI"	)
	AAdd(aCpos,"C5_CGCCLI"	)
	AAdd(aCpos,"C5_TRANSP"	)
	AAdd(aCpos,"C5_TPFRETE"	)
	AAdd(aCpos,"C5_K_TPCL"	)
	AAdd(aCpos,"C5_NOMEVEND")
	AAdd(aCpos,"C5_PBRUTO"	)
	AAdd(aCpos,"C5_VOLUME1"	)
	AAdd(aCpos,"C5_PESOL"	)
	AAdd(aCpos,"C5_MSGNOTA"	)
	AAdd(aCpos,"C5_MSGCLI"	)
	AAdd(aCpos,"C5_X_REGRA"	)
	AAdd(aCpos,"C5_X_POR"	)
	AAdd(aCpos,"C5_X_PRC"	)
	AAdd(aCpos,"C5_X_IMP"	)
	AAdd(aCpos,"C5_REF10"	)
	AAdd(aCpos,"C5_X_IMP"	)
	// AAdd(aCpos,"C5_K_OPER"	)
	AAdd(aCpos,"C5_XPEDCLI"	)
	AAdd(aCpos,"C5_XGERASV"	)
	AAdd(aCpos,"C5_XLIBFLU"	)
	AAdd(aCpos,"C5_K_TPPV"	)
	AAdd(aCpos,"C5_XPVSPC"	)

	
	// if lBlqCpo
	aPerm := aClone(aCpos)
	// Endif

	// chama a rotina de alteração
	nRet := AxAltera(cAlias, nRecno, nOpc,aCpos,aPerm)
  //AxAltera(cAlias,nReg   ,nOpc ,aAcho,aCpos,nColMens,cMensagem,cTudoOk,cTransact,cFunc,aButtons,aParam,aAuto,lVirtual,lMaximized)

	If nRet == 1
		u_KFATR15C("19","ALTERADO PESO VOLUME")
  		U_KFATR15("19",SC5->C5_NUM)
	Endif
	
return Nil


User Function viewNFPedido()
	Local aArea 	:= GetArea()
	Local cQuery 	:= ""
	Local cTemp		:= GetNextAlias()
	// funcao botao ok
	Local bOkb	 	:= {|| }
	// funcao cancelar
	Local bCancel 	:= {|| oDlgAnx:End()}
	// msg ao deletar
	Local lMsgDel	:= .F.
	// botoes
	Local aButtons	:= {}
	// registro
	Local nRecno 	:= Nil
	// alias
	Local cAlias	:= Nil
	// exibe mashups
	Local lMashups	:= .F.
	// imprime padrao
	Local lImpCad	:= .F.
	// botoes padra
	Local lPadrao	:= .F.
	// exibe botao ok
	Local lHasOk	:= .F.
	// exibe walk
	Local lWalkThru	:= .F.
	Local oPedido
	Local cPedido	:= SC5->C5_NUM
	Local oNf
	Local cNf		:= ""
	Local oSerie
	Local cSerie	:= ""
	Local nLinha	:= 0
	
	cQuery += "SELECT DISTINCT "+ENTER
	cQuery += "	C6_NUM "+ENTER
	cQuery += "	,C6_NOTA "+ENTER
	cQuery += "	,C6_SERIE "+ENTER
	cQuery += " "+ENTER
	cQuery += "FROM "+RetSqlName("SC6")+" (nolock) "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE  "+ENTER
	cQuery += "		D_E_L_E_T_<>'*' "+ENTER
	cQuery += "	AND C6_FILIAL='"+xFilial("SC6")+"' "+ENTER
	cQuery += "	AND C6_NUM='"+cPedido+"' "+ENTER
	cQuery += "	AND C6_NOTA<>'' "+ENTER
	cQuery += " "+ENTER
	cQuery += "ORDER BY C6_NOTA DESC "+ENTER
	
	If Select(cTemp)>0
		(cTemp)->( DbCloseArea() )
	Endif
	
	TcQuery cQuery New Alias (cTemp)
	
	If (cTemp)->( EOF() )
		MsgInfo("Pedido "+cPedido+" ainda não foi faturado.")
	Else
		
		cNf		:= (cTemp)->C6_NOTA
		cSerie	:= (cTemp)->C6_SERIE
		
		// dimensoes da tela de anexos
		Define MsDialog oDlgAnx from 001, 001 to 110, 500 title "Número da nota fiscal do pedido" pixel
		
		nLinha := 32
		// box selecao arquivo
		@ nLinha, 002 to nLinha+20, 250 Label "" of oDlgAnx pixel
		
		nLinha += 5
		@ nLinha	, 007 Say "Pedido"	of oDlgAnx Pixel
		// botao 
		@ nLinha - 1, 035 MsGet oPedido Var cPedido Size 20,08 Picture "@!" of oDlgAnx Pixel when .f.
		
		
		//nLinha += 12
		@ nLinha	, 070 Say "Nota Fiscal"	of oDlgAnx Pixel
		// caminho selecionado
		@ nLinha - 1, 105 MsGet oNf Var cNf Size 20,08 Picture "@!" of oDlgAnx Pixel when .f. 
	
		//nLinha += 12
		@ nLinha	, 165 Say "Série"	of oDlgAnx Pixel
		// caminho selecionado
		@ nLinha - 1, 195 MsGet oSerie Var cSerie Size 20,08 Picture "@!" of oDlgAnx Pixel when .f.
		
		// ativa a tela
		Activate MsDialog oDlgAnx Centered on init EnchoiceBar( oDlgAnx ,bOkb,bCancel,lMsgDel,aButtons,nRecno,cAlias,lMashups,lImpCad,lPadrao,lHasOk,lWalkThru)
	
	Endif
	
	If Select(cTemp)>0
		(cTemp)->( DbCloseArea() )
	Endif
	
	
	RestArea(aArea)
Return 
