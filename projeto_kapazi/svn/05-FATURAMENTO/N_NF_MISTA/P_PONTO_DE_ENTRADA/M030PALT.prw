#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: M030PALT		|	Autor: Luis Paulo							|	Data: 03/04/2018	//
//==================================================================================================//
//	Descrição: PE NA ALTERACAO DO CLIENTE - APÓS A GRAVACAO											//
//																									//
//==================================================================================================//
User Function M030PALT()
Local nOpcao	:= PARAMIXB[1]
Local lRet	 	:= .T.

If nOpcao == 1 //OK
	
	If lAltNf	//Variavel publica da NF Mista nao mexa!!!
			Reclock("SA1", .F.)		    
			SA1->A1_XFLAGSV := "X"
			SA1->A1_XDATASV := Date()
			SA1->A1_XHORASV := time()
			SA1->A1_XQUEMSV := UsrFullName(__cUserID) 
			//SA1->A1_XCOB	:= U_BUSATEND() //Busca atendente 
			SA1->(MsUnlock())
		
		Else
			//Reclock("SA1", .F.)
			//SA1->A1_XCOB	:= U_BUSATEND() //Busca atendente
			//SA1->(MsUnlock())
	
	EndIf

EndIf

Return lRet