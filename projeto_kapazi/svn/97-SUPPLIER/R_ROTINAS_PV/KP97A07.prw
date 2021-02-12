#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: KP97A07		|	Autor: Luis Paulo							|	Data: 30/08/2018	//
//==================================================================================================//
//	Descrição: Atribuindo e marcando o PV como da supplier											//
//																									//
//==================================================================================================//
User Function KP97A07()
Local aArea	:= GetArea()

If cEmpAnt <> '04' 
	MsgInfo("Esta rotina funciona apenas para informações da empresa 04 (Industria)","KAPAZI - Pedidos de Vendas SUPPLIER CARD")
	Return
EndIf

If (SC5->C5_XSTSSPP) == '2' //Pedido Enviado e em status bloqueado
		AtPvASP()
	ElseIf (SC5->C5_XSTSSPP) == '3' //Pre autorizacao
		AtPvSPAt()
	ElseIf (SC5->C5_XSTSSPP) == '5' //Faturado
		AtPvFT()
	Else
		MsgInfo("Status nao permite alteracao","KAPAZI")
EndIf

RestArea(aArea)
Return()

Static Function AtPvASP()
Local 		aParamBox 	:= {}
Local 		aPVSPP		:= {"NAO","SIM"}
Private 	aRet 		:= {}	
Private 	lCentered	:= .T.
Private 	cCRLF		:= CRLF
Private 	_cPerg1 

	AAdd(aParamBox,	{ 2,"Pedido aceito pela supplier??",1,aPVSPP	,60,"",.T.})
	
If ParamBox(aParamBox,"PEDIDO DE VENDA - SUPPLIER CARD", @aRet,,,lCentered,,,,,.T.,.T.)//@aRet Array com respostas - Par 11 salvar perguntas
	
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
	
	If _cPerg1 == 1
			DbSelectArea("SC5")
			RecLock("SC5",.F.)
			SC5->C5_XSTSSPP := "6" //rejeitado
			SC5->(MsUnlock())
		Else
			RecLock("SC5",.F.)
			SC5->C5_XSTSSPP := "2" //Bloqueado - Processo normal
			SC5->(MsUnlock())
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

	AAdd(aParamBox,	{ 2,"Pedido autorizado pela supplier??",1,aPVSPP	,60,"",.T.})
	
If ParamBox(aParamBox,"PEDIDO DE VENDA - SUPPLIER CARD", @aRet,,,lCentered,,,,,.T.,.T.)//@aRet Array com respostas - Par 11 salvar perguntas

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
	
	If _cPerg1 == 1
			DbSelectArea("SC5")
			RecLock("SC5",.F.)
			SC5->C5_XSTSSPP := "7" //Rejeitado pela supplier na pre-autorizacao
			SC5->(MsUnlock())
		Else
			DbSelectArea("SC5")
			RecLock("SC5",.F.)
			SC5->C5_XSTSSPP := "3"
			SC5->(MsUnlock())
	EndIf
EndIf	

Return()

Static Function AtPvFT()
Local 		aParamBox 	:= {}
Local 		aPVSPP		:= {"NAO","SIM"}
Private 	aRet 		:= {}	
Private 	lCentered	:= .T.
Private 	cCRLF		:= CRLF
Private 	_cPerg1 

	AAdd(aParamBox,	{ 2,"Pedido faturado pela supplier??",1,aPVSPP	,60,"",.T.})
	
If ParamBox(aParamBox,"PEDIDO DE VENDA - SUPPLIER CARD", @aRet,,,lCentered,,,,,.T.,.T.)//@aRet Array com respostas - Par 11 salvar perguntas

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
	
	If _cPerg1 == 1
			DbSelectArea("SC5")
			RecLock("SC5",.F.)
			SC5->C5_XSTSSPP := "8" //Rejeitado pela supplier na pre-autorizacao
			SC5->(MsUnlock())
		Else
			DbSelectArea("SC5")
			RecLock("SC5",.F.)
			SC5->C5_XSTSSPP := "5"
			SC5->(MsUnlock())
	EndIf
EndIf	

Return()