#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"


User Function KP97A77()
Local aArea		:= GetArea()
Local cQr 		:= ""
Local cClient	:= SC5->C5_CLIENTE
Local cLojaC	:= SC5->C5_LOJACLI
Private nVlrLib	:= 0
Private cCRLF	:= CRLF

If cEmpAnt <> '04' 
	MsgInfo("Esta rotina funciona apenas para informações da empresa 04 (Industria)","KAPAZI - Pedidos de Vendas SUPPLIER CARD")
	Return
EndIf

If Select("cAliaLim") <> 0
	cAliaLim->(DbCloseArea())
EndIf

cQr += " SELECT SA1.A1_CGC,SA1.A1_LC,ZSL.ZSL_RAIZCN,ZSL.ZSL_LIMTOT,ZSL.ZSL_LIMUTI,ZSL.ZSL_LIMRES,ZSL.R_E_C_N_O_ AS RECOZSL,ZSL.*
cQr += " FROM "+RetSqlName("SA1")+" SA1
cQr += " INNER JOIN "+RetSqlName("ZSL")+" ZSL ON SUBSTRING(SA1.A1_CGC,1,8) = ZSL.ZSL_RAIZCN AND ZSL.D_E_L_E_T_ = ''
cQr += " WHERE SA1.D_E_L_E_T_ = ''
cQr += " AND SA1.A1_COD = '"+cClient+"'"
cQr += " AND SA1.A1_LOJA = '"+cLojaC+"'"

// abre a query
TcQuery cQr new alias "cAliaLim"

DbSelectArea("cAliaLim")
cAliaLim->(DbGoTop())

If cAliaLim->(EOF()) 
	MsgInfo("O cliente não possui limite com a Supplier, FAVOR VERIFICAR!!","KAPAZICRED")
	cAliaLim->(DbCloseArea())
	Return()
EndIf

If !(SC5->C5_XPVSPC == 'S') 
		If MsgYesNo("Este pedido esta na carteira da kapazi, tem certeza que deseja transferi-lo para Supplier???","KAPAZI")
			MostraLi()
			AtPvASP()
		EndIf
	Else
		If MsgYesNo("Este pedido já é supplier, tem certeza que deseja voltar para carteira da kapazi???","KAPAZI")
			AtPvSPAt()
		EndIf
EndIf

cAliaLim->(DbCloseArea())

RestArea(aArea)
Return()


Static Function MostraLi()

cConfirma := "<html> Limites Supplier  <b><font color="+"BLUE"+">" + SC5->C5_CLIENTE + "-"+SC5->C5_LOJACLI+"/"+SC5->C5_NOMECLI+"</b></font>"
cConfirma += "<br><br>Limites "
//-cConfirma += "<br><br>Dados banco pagamento: "
cConfirma += "<br>Limite Total: <b><font color="+"BLUE"+">" + Transform(cAliaLim->ZSL_LIMTOT, "@E 999,999,999.99") + " </b></font>"
cConfirma += "<br>Limite Usado: <b><font color="+"BLUE"+">" + Transform(cAliaLim->ZSL_LIMUTI, "@E 999,999,999.99") + " </b></font>"
cConfirma += "<br>Limite restante: <b><font color="+"BLUE"+">" + Transform(cAliaLim->ZSL_LIMRES, "@E 999,999,999.99") + " </b></font>"
cConfirma += "</html>"

MsgInfo(cConfirma)

Return()

//Pedido Kapazi
Static Function AtPvASP()
Local 		aParamBox 	:= {}
Local 		aPVSPP		:= {"NAO","SIM"}
Private 	aRet 		:= {}	
Private 	lCentered	:= .T.
Private 	cCRLF		:= CRLF
Private 	_cPerg1 

	AAdd(aParamBox,	{ 2,"Pedido SUPPLIER???",1,aPVSPP	,60,"",.T.})
	
If ParamBox(aParamBox,"SUPPLIER CARD", @aRet,,,lCentered,,,,,.T.,.T.)//@aRet Array com respostas - Par 11 salvar perguntas
	
	_cPerg1 := MV_PAR01
	
	If ValType(_cPerg1) == "N"
			If _cPerg1 == 1
					_cPerg1 := 1
				Else
					_cPerg1 := 2
			EndIf
		
		Else
			If _cPerg1 == "NAO"
					_cPerg1 := 1
				Else
					_cPerg1 := 2 //SIM Desconsidera uma apuracao
			EndiF
	EndIf
	
	If _cPerg1 == 2
		//Verifica se já houve liberação de crédito, pois neste caso,
		//Sera Debitado o valor do limite creditado pela kapazi, passado a creditar da supplier.
		
		If AjCdPgtoS() //Ajusta a condicao de pagamento para supplier
		
			VLibCred("S")
			
			//Movimenta os limites supplier
			MovLISPP("S")
			
			DbSelectArea("SC5")
			RecLock("SC5",.F.)
			SC5->C5_XPVSPC := "S" //SUPPLIER
			SC5->(MsUnlock())
		EndIf
		
	EndIf
	
EndIf	

Return()

Static Function AtPvSPAt()
Local 		aParamBox 	:= {}
Local 		aPVSPP		:= {"NAO","SIM"}
Private 	aRet 		:= {}	
Private 	lCentered	:= .T.
Private 	cCRLF		:= CRLF
Private 	_cPerg1 

	AAdd(aParamBox,	{ 2,"Pedido KAPAZI??",1,aPVSPP	,60,"",.T.})
	
If ParamBox(aParamBox,"KAPAZI!", @aRet,,,lCentered,,,,,.T.,.T.)//@aRet Array com respostas - Par 11 salvar perguntas

	_cPerg1 := MV_PAR01

	If ValType(_cPerg1) == "N"
			If _cPerg1 == 1
					_cPerg1 := 1
				Else
					_cPerg1 := 2
			EndIf
		
		Else
			If _cPerg1 == "NAO"
					_cPerg1 := 1
				Else
					_cPerg1 := 2 //SIM Desconsidera uma apuracao
			EndiF
	EndIf
	
	If _cPerg1 == 2
		//Verifica se já houve liberação de crédito, pois neste caso,
		//Sera Debitado o valor do limite creditado pela kapazi, passado a creditar da supplier.
		VLibCred("K")
		
		//Movimenta os limites supplier
		MovLISPP("K")
		
		DbSelectArea("SC5")
		RecLock("SC5",.F.)
		SC5->C5_XPVSPC := "N" //SUPPLIER
		SC5->(MsUnlock())
	EndIf
	
EndIf	

Return()

//Verifica o que tem liberado 
Static Function VLibCred(cOpcaoK)
Local cQry		:= ""
Local cAlias	:= GetNextAlias()
Local nVlrc		:= 0
Local nUtiliz	:= 0
Local nRest 	:= 0

cQry	+= " SELECT SUM(VLRLIB) AS VLRLPED "+cCRLF
cQry	+= " FROM (SELECT SC9.C9_QTDLIB,SC9.C9_PRCVEN,SC9.C9_QTDLIB * SC9.C9_PRCVEN AS VLRLIB "+cCRLF
cQry	+= "		FROM SC9040 SC9 "+cCRLF
cQry	+= "		WHERE SC9.D_E_L_E_T_ = '' "+cCRLF
cQry	+= "		AND SC9.C9_PEDIDO = '"+SC5->C5_NUM+"' "+cCRLF
cQry	+= "		AND SC9.C9_BLCRED = '' ) PEDLIB "+cCRLF

If Select((cAlias)) <> 0
	(cAlias)->(DbCloseArea())
EndIf

TcQuery cQry New Alias (cAlias)

DbSelectArea((cAlias))
(cAlias)->(DbGoTop())

nVlrLib	:= (cAlias)->VLRLPED

(cAlias)->(DbCloseArea())

DbSelectArea("SA1")
SA1->(DbSetOrder(1))
SA1->(DbGoTOp())
If SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
	
	
	If cOpcaoK == "S"
			nVlrc := SA1->A1_SALPEDL - nVlrLib //Pega o valor do controle de limite para achar o decrescimo, pois pedidos supplier nao podem usar o limite.
			
			RecLock("SA1",.F.)
			SA1->A1_SALPEDL := nVlrc
			SA1->(MsUnlock())
			
			nUtiliz	:= cAliaLim->ZSL_LIMUTI + nVlrLib
			nRest 	:= cAliaLim->ZSL_LIMTOT - (cAliaLim->ZSL_LIMUTI + nVlrLib) 
			
			DBSelectArea("ZSL")
			ZSL->(DbSetOrder(1))
			ZSL->(DbGoTop())
			ZSL->(DbGoTo(cAliaLim->RECOZSL))
			RecLock("ZSL",.F.)
			ZSL->ZSL_LIMUTI	:= nUtiliz
			ZSL->ZSL_LIMRES	:= nRest
			ZSL->(MsUnLock())
			
		Else
			nVlrc := SA1->A1_SALPEDL + nVlrLib //Volta o pedido para kapazi
			RecLock("SA1",.F.)
			SA1->A1_SALPEDL := nVlrc
			SA1->(MsUnlock())
			
			nUtiliz	:= cAliaLim->ZSL_LIMUTI - nVlrLib
			nRest 	:= cAliaLim->ZSL_LIMTOT - (cAliaLim->ZSL_LIMUTI - nVlrLib) 

			DBSelectArea("ZSL")
			ZSL->(DbSetOrder(1))
			ZSL->(DbGoTop())
			ZSL->(DbGoTo(cAliaLim->RECOZSL))
			RecLock("ZSL",.F.)
			ZSL->ZSL_LIMUTI	:= nUtiliz
			ZSL->ZSL_LIMRES	:= nRest
			ZSL->(MsUnLock())
					
	EndIf
	
EndIf


Return()

//Movimentos de limites
Static Function MovLISPP(cOpcaoK)

If cOpcaoK == "S"
		DbSelectArea("ZCL")
		Reclock("ZCL",.T.)
		ZCL->ZCL_FILINC	:= xFilial("SC5")
		ZCL->ZCL_PEDIDO	:= SC5->C5_NUM
		ZCL->ZCL_SEQ	:= PegaSeq()
		ZCL->ZCL_VALOR	:= nVlrLib
		ZCL->ZCL_RECSC5	:= SC5->(RECNO())
		ZCL->ZCL_CDUSER	:= __cUserId
		ZCL->ZCL_NMUSER	:= UsrFullName(__cUserID)
		ZCL->ZCL_DTALT	:= Date()
		ZCL->ZCL_HRALT	:= Time()
		ZCL->(MsUnLock())
		
	Else
		VerSPVFS() //Exclui da movimentacao de limites supplier
EndIf

Return()


//Funcao para verificar 
Static Function VerSPVFS()
Local cQry := ""
Local cSeq := ""
Local nNew := 0
 
cQry:=" SELECT  TOP 1 ZCL_FILINC,ZCL_PEDIDO,ZCL_SEQ,ZCL_VALOR,ZCL_RECSC5,ZCL_CDUSER,ZCL_NMUSER,ZCL_DTALT,ZCL_HRALT,ZCL_OFF,R_E_C_N_O_ AS RECOZCL FROM "+ RETSQLNAME('ZCL')
cQry+=" WHERE D_E_L_E_T_<>'*'"
cQry+=" AND ZCL_PEDIDO = '"+ SC5->C5_NUM +"'"
cQry+=" AND ZCL_FILINC = '"+ xFilial("SC5") +"'"
cQry+=" ORDER BY ZCL_SEQ DESC"

IF Select('TRZCL')<>0
	TRZCL->(DBCloseArea())
EndIF

TcQuery cQry New Alias 'TRZCL'

If !TRZCL->(EOF()) .And. TRZCL->ZCL_OFF <> 'X'
	
	DbSelectArea("ZCL")
	Reclock("ZCL",.T.)
	ZCL->ZCL_FILINC	:= xFilial("SC5")
	ZCL->ZCL_PEDIDO	:= SC5->C5_NUM
	ZCL->ZCL_SEQ	:= PegaSeq()
	ZCL->ZCL_VALOR	:= SC5->C5_XTOTMER
	ZCL->ZCL_RECSC5	:= SC5->(RECNO())
	ZCL->ZCL_CDUSER	:= __cUserId
	ZCL->ZCL_NMUSER	:= UsrFullName(__cUserID)
	ZCL->ZCL_DTALT	:= Date()
	ZCL->ZCL_HRALT	:= Time()
	ZCL->ZCL_OFF `	:= "X"
	ZCL->(MsUnLock())
EndIf

TRZCL->(DBCloseArea())
Return()

//Pega o proximo sequencial
Static Function PegaSeq()
Local cQry := ""
Local cSeq := ""
 
cQry:=" SELECT  TOP 1 ZCL_SEQ FROM "+ RETSQLNAME('ZCL')
cQry+=" WHERE D_E_L_E_T_<>'*'"
cQry+=" AND ZCL_PEDIDO = '"+ SC5->C5_NUM +"'"
cQry+=" AND ZCL_FILINC = '"+ xFilial("SC5") +"'"
cQry+=" ORDER BY ZCL_SEQ DESC"

IF Select('TRZCLS')<>0
	TRZCLS->(DBCloseArea())
EndIF

TcQuery cQry New Alias 'TRZCLS'

If TRZCLS->(eof())
		cSeq := '001'
	Else
		cSeq := Soma1(TRZCLS->ZCL_SEQ)
EndIf

TRZCLS->(DBCloseArea())
Return(cSeq)

//Verifica se a condicao de pagamento 
Static Function AjCdPgtoS()
Local aArea	:=  GetArea()
Local lRet 	:= .T.

aParcelas := Condicao(1000,SC5->C5_CONDPAG,,dDataBase)
If Len(aParcelas) > 6
		MsgInfo("Esse pedido é supplier, porém a quantidade de parcelas é superior ao contrato(6), favor verificar a condicao de pagamento!","KAPAZICRED")
		lRet 	:= .F.
	Else
		VerConPg(SC5->C5_CONDPAG) //Vali se a condicao de pagamento é supplier e se a condicao de pagamento de prazo médio esta vinculada
EndIf

RestArea(aArea)

Return(lRet)

//Validacoes da condicao de pagamento supplier
Static Function VerConPg(cCondPg)
Local aArea			:= GetArea()
Local lRet			:= .T.
Local lAchou		:= .T.
Local cCondOri		:= cCondPg
Private cCondSPP	:= ""
Private cCondPM		:= ""

//TODO deixar dinamico a qtd de parcelas e os dias de vencimento (21 ou 28 por exemplo)

//Posiciona na condicao 
DbSelectArea("SE4")
SE4->(DbSetOrder(1))
SE4->(DbGoTOP())
If SE4->(DbSeek(xFilial("SE4") + cCondOri))
		If SE4->E4_XCONDSP == 'S' //Se a condicao é a condicao suppler
			cCondSPP	:= SE4->E4_CODIGO	 //Pega o codigo da condicao
		EndIf
		
		If !Empty(SE4->E4_XCONDPM) .And. SE4->E4_XCONDSP == 'S' //Processo de tratativa supplier ja feito na base, entao pode sair da rotina
			RestArea(aArea)
			Return
		EndIf
		
		If !Empty(SE4->E4_XCODSPP)
			RecLock("SC5",.F.)
			SC5->C5_CONDPAG := SE4->E4_XCODSPP //Muda a condicao para supplier
			SC5->(MsUnlock())
			
			Return
		EndIf
		
	Else
		lAchou	:= .F.
		MsgInfo("Condicao de pgto kapazi inexistente","KAPAZICRED")
EndIf

If !Empty(cCondSPP) .And. lAchou
		DbSelectArea("SE4")
		SE4->(DbSetOrder(1))
		SE4->(DbGoTOP())
		If SE4->(DbSeek(xFilial("SE4") + cCondSPP))
			cCondPM	:= SE4->E4_XCONDPM
		EndIf
	Else
		MsgInfo("Condicao de pgto supplier inexistente, sera criada uma nova condicao e vinculada ao pedido","KAPAZICRED")
		U_CriaCPSP(cCondOri) 	//Cria a condicao de pagamento supplier
		U_CriaCPPM(cCondOri)	//cria a condicao de pagamento prazo médio supplier, que sera usada na liquidacao no financeiro
		
		RecLock("SC5",.F.)
		SC5->C5_CONDPAG := cCondSPP //Condicao de pagamento supplier
		SC5->(MsUnlock())
		
		MsgInfo("Condicoes criadas com sucesso!!!","KAPAZICRED")
EndIf

If Empty(cCondPM) .And. lAchou
	MsgInfo("Condicao de pgto prazo medio supplier inexistente, sera criada uma nova condicao e vinculada ao pedido","KAPAZICRED")
	u_CriaCPPM(cCondOri)	//cria a condicao de pagamento prazo médio supplier, que sera usada na liquidacao no financeiro
EndIf

RestArea(aArea)
Return(lRet)