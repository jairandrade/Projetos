/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** Pedido de Venda                                                                                                          		 **/
/** Ponto de entrada MTA410I                               																																		 **/
/** RSAC Solu��es Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
/**********************************************************************************************************************************/
/** Data       | Respons�vel                    | Descri��o                                                                      **/
/**********************************************************************************************************************************/
/**********************************************************************************************************************************/

User Function MTA410I()
Local aArea :=	GetArea()
  
	//ROTINA PARA GRAVAR DADOS DO PEDIDO NA SZ6, SEJA INCLUS�O OU A�TERACAO
	//U_GRVZ6(C5_NUM) - COMENTADO DIA 16/11/2017 
	
RestArea(aArea)
Return	nil 