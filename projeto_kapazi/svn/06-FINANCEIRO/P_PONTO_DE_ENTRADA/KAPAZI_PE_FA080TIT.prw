#INCLUDE "PROTHEUS.CH"
/**********************************************************************************************************************************/
/** Financeiro                                                                                                                  **/
/** Pedido de Venda - inclusão da linha                                                                                          **/
/** Ponto de entrada FA080TIT                               																																		  **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/** 08/05/2015 | Marcos Sulivan									| validar se esta usando cheque e se o numero do cheque foi preenchido           **/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/ 
 
User Function FA080TIT()
Local aArea  	 := GetArea()
lRet	:=	.T.  

If(CMOTBX == "CHEQUE")
	
	If (ALLTRIM(CCHEQUE) == ""  )
	
		Aviso("ATENÇÃO","Informe o Numero do cheque.",{"Ok"})
		lRet	:=	.F.          
	
	EndIf
		                              
EndIf 

If lRet   

	If SE2->E2_EMIS1 > ddatabase  
	
			Aviso("ATENÇÃO","A data de contabilização esta maior que a data de baixa.",{"Ok"})
			lRet	:=	.F.
	
	EndIf
	
EndIf

RestArea(aArea)

Return lRet  

