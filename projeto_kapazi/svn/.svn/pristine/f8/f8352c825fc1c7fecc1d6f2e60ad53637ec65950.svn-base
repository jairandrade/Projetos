#include "rwmake.ch"
*----------------------------------------------------------------------------------------------------
user function Mta450r
* Ponto de entrada na analise de credito de cliente - Rejeição de item na liberação
*
* Ricardo Luiz da Rocha 21/11/2011 GNSJC
*----------------------------------------------------------------------------------------------------
local _cPedido:=sc9->c9_pedido

if sc5->(dbseek(xfilial()+_cPedido,.f.).and.reclock(alias(),.f.))
    sc5->c5_xsitlib:=u_KpFatC01(_cPedido)

    _vDatas:=sc5->(u_Sc5Libs(_cPFil:=c5_filial,_cPNumPed:=c5_num,_cPSit:=c5_xsitlib,,_dPDataP:=C5_xDtLibP,_dPDataF:=C5_xDtLibF,_dPDataE:=C5_xDtLibe))
    sc5->c5_xdtlibp:=_vDatas[1] //DESCOMENTADO DIA 30/05/2017 - SULIVAN
    sc5->c5_xdtlibf:=_vDatas[2]
    sc5->c5_xdtlibe:=_vDatas[3]
	
    sc5->(msunlock())
endif

//Gravação realizada pelo PE MTA450RP
//grava log de liberação do pedido
//If ExistBlock("KFATR15")
//	U_KFATR15("10",SC9->C9_PEDIDO)
//Endif

return