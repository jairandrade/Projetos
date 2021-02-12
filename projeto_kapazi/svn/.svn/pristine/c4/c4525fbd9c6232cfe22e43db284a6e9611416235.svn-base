#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: MT450FIM		|	Autor: Luis Paulo							|	Data: 02/04/2018	//
//==================================================================================================//
//	Descrição: Este ponto pertence à rotina de liberação de crédito, MATA450(). Está localizado na 	//
//	liberação manual do crédito por pedido A450LIBMAN(). É executado ao final da liberação de um 	//
//	pedido.																							//
//																									//
//==================================================================================================//
User Function MT450FIM()
Local aArea 	:=	GetArea() 
Local cPedido	:= SC9->C9_PEDIDO	

Local aPvlNfs	:= {}
Local aBloqueio	:= {}

// mata450 liberacao financeira
If IsInCallStack("A450LibAut") .or. IsInCallStack("A450LibMan")
	//grava log de liberação do pedido
	If ExistBlock("KFATR15")
		U_KFATR15("03",SC9->C9_PEDIDO)
	Endif
Endif

If cEmpAnt == "04"
	
	DbSelectArea("SC5")
	DbSetOrder(1)
	SC5->(DbGoTop())
	If MsSeek(xFilial("SC5")+cPedido)
	
		If !Empty(SC5->C5_XIDVNFK) .And. cFilAnt == "01" .And. Alltrim(SC5->C5_XTIPONF) == "1" //Validacao para NFMista
			U_LIBPVNFM(SC5->C5_XIDVNFK,@aPvlNfs,@aBloqueio)
			MsgInfo("Pedido Liberado - MT450FIM")
		EndIf
		
		//Verifica o pedido era Supplier e agora nao é
		//Verificar se o pedido nao era supplier e agora é
		//Primeira liberacao
		If Alltrim(SC5->C5_XPVSPC) == "S" .And. !IsInCallStack("U_M410PVNF")
				ApuZCLMV()
			Else
				//VerZCLMV()
		EndIf
	EndIf
EndIf

RestArea(aArea)	
Return()

Static Function VerZCLMV()

Return()

//
Static Function ApuZCLMV()
Local nNew	:= 0

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
ZCL->(MsUnLock())

DbSelectArea("SA1")
SA1->(DbSetOrder(1))
SA1->(DbGoTOp())
If SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
	
	nNew := SA1->A1_SALPEDL - SC5->C5_XTOTMER
	
	RecLock("SA1",.F.)
	SA1->A1_SALPEDL := nNew
	SA1->(MsUnlock())
EndIf

Return()


Static Function PegaSeq()
Local cQry := ""
Local cSeq := ""
 
cQry:=" SELECT  TOP 1 ZCL_SEQ FROM "+ RETSQLNAME('ZCL')
cQry+=" WHERE D_E_L_E_T_<>'*'"
cQry+=" AND ZCL_PEDIDO = '"+ SC5->C5_NUM +"'"
cQry+=" AND ZCL_FILINC = '"+ xFilial("SC5") +"'"
cQry+=" ORDER BY ZCL_SEQ DESC"

IF Select('TRZCL')<>0
	TRZCL->(DBCloseArea())
EndIF

TcQuery cQry New Alias 'TRZCL'

If TRZCL->(eof())
		cSeq := '001'
	Else
		cSeq := Soma1(TRZCL->ZCL_SEQ)
EndIf

TRZCL->(DBCloseArea())
Return(cSeq)