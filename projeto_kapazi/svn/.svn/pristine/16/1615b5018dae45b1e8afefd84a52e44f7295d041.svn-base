#include "rwmake.ch"
#include "topconn.ch"

user function Mt410Alt
	Local cDes		:= ""
	local _cPedido:=m->c5_num
	
	if sc5->(reclock(alias(),.f.))
	   sc5->c5_xtotmer:=u_MFAT01(xfilial('SC5'),_cPedido)
	   sc5->c5_xsitlib:= u_KpFatC01(_cPedido)// 19.04.2017
	   
	   
		_vDatas:=sc5->(u_Sc5Libs(_cPFil:=c5_filial,_cPNumPed:=c5_num,_cPSit:=c5_xsitlib,,_dPDataP:=C5_xDtLibP,_dPDataF:=C5_xDtLibF,_dPDataE:=C5_xDtLibe))
    sc5->c5_xdtlibp:=_vDatas[1] //DESCOMENTADO DIA 30/05/2017 - SULIVAN
    sc5->c5_xdtlibf:=_vDatas[2]
    sc5->c5_xdtlibe:=_vDatas[3]
    
    
      
	   sc5->(Msunlock())
	endif
	
	If ExistBlock("KFATR15")
		If SC5->( FieldPos("C5_XJUSTIF") ) > 0
			If SX5->( MsSeek(xFilial("SX5")+"ZB"+SC5->C5_XJUSTIF ) )
				cDes := AllTrim( SX5->X5_DESCRI )
			Endif
			U_KFATR15("11",SC5->C5_NUM,,,,AllTrim(SC5->C5_XJUSTIF)+';'+AllTrim(cDes) )
		Else
			U_KFATR15("11",SC5->C5_NUM)
		Endif
	Endif	
	//u_KpFatC01(_cPedido)// 19.04.2017                                          	

  // executa a liberação automática do pedido
  //Ka410Alt()
	
return .t. 
