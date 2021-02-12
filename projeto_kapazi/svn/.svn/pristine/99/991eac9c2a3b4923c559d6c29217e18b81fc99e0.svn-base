/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** liberação pedido de venda                                                                                              		 **/
/** Ponto de entrada MTA450I - Liberacao de estoque																				 **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/

User Function MTA455I()

Local aArea :=	GetArea() 
Local lRet	:=	.T.

//	If ExistBlock("KFATR15")
//		U_KFATR15("04",SC9->C9_PEDIDO)
//	Endif

//GRAVA DADOS DE LIBERACAO DE CREDITO FINANCEIRO AUTOMATICA
//U_GRVLIBE()  - COMENTADO DIA 16/11/2017 

//Ponto de entrada na liberação de estoques automática
U_LESTAU()   

// chama a rotina para gravar o historico de liberação de credito
U_KFATA02(SC9->C9_BLCRED, SC9->C9_PEDIDO)

RestArea(aArea)

//PE desativado Fluig - uso do MT450END 

Return	nil   


user function LESTAU()

local _cPedido:=sc9->c9_pedido

if sc5->(dbseek(xfilial()+_cPedido,.f.).and.reclock(alias(),.f.))
    sc5->c5_xsitlib:=u_KpFatC01(_cPedido)
    
     _vDatas:=sc5->(u_Sc5Libs(_cPFil:=c5_filial,_cPNumPed:=c5_num,_cPSit:=c5_xsitlib,_dPDataP:=C5_xDtLibP,_dPDataF:=C5_xDtLibF,_dPDataE:=C5_xDtLibe))
    sc5->c5_xdtlibp:=_vDatas[1]	//DESCOMENTADO DIA 30/05/2017 - SULIVAN
    sc5->c5_xdtlibf:=_vDatas[2]
    sc5->c5_xdtlibe:=_vDatas[3]
   
    sc5->(msunlock())
endif
	
return