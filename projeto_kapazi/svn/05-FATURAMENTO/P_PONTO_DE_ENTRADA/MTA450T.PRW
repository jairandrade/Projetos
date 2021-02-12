
/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** liberaçaõ pedido de venda                                                                                                		 **/
/** Ponto de entrada MTA450T                              																																		 **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/

User Function MTA450T()
Local aArea :=	GetArea() 
Local lRet	:=	.T.

//GRAVA DADOS DE LIBERACAO DE CREDITO FINANCEIRO AUTOMATICA
//U_GRVLIBF()  - COMENTADO DIA 16/11/2017 
	
// chama a rotina para gravar o historico de liberação de credito
U_KFATA02(SC9->C9_BLCRED, SC9->C9_PEDIDO) 

RestArea(aArea)
Return	lRet   