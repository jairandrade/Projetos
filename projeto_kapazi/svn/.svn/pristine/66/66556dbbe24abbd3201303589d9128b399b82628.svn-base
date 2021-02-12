#include "rwmake.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** Pedido de Venda                                                                                                          		 **/
/** Ponto de entrada Ms520Del                               																																		 **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** Esse ponto de entrada está localizado na função MaDelNfs e é executado antes da exclusão do registro da tabela SF2.************/
/**********************************************************************************************************************************/

User Function MS520DEL()
Local aArea 	:=	GetArea()
Local cNfOri 	:=	SF2->F2_DOC
Local cSerOri	:=  SF2->F2_SERIE
 
U_FATDEL()

//GRAVA DADOS DELETADOS
//U_DELSTU() - COMENTADO DIA 16/11/2017 

RestArea(aArea)

Return	nil 

*----------------------------------------------------------------------------------------------------
user function FATDEL()
* Ponto de entrada ao final da exclusao da nf
*
* Ricardo Luiz da Rocha 21/11/2011 GNSJC
*----------------------------------------------------------------------------------------------------
local _cPedido:=Sc5->c5_num

if sc5->(dbseek(xfilial()+_cPedido,.f.).and.reclock(alias(),.f.))
    sc5->c5_xsitlib:=u_KpFatC01(_cPedido)
    _vDatas:=sc5->(u_Sc5Libs(_cPFil:=c5_filial,_cPNumPed:=c5_num,_cPSit:=c5_xsitlib,_dPDataP:=C5_xDtLibP,_dPDataF:=C5_xDtLibF,_dPDataE:=C5_xDtLibe))
    sc5->c5_xdtlibp:=_vDatas[1] //DESCOMENTADO DIA 30/05/2017 - SULIVAN
    sc5->c5_xdtlibf:=_vDatas[2]
    sc5->c5_xdtlibe:=_vDatas[3]
    
    sc5->(msunlock())
endif

return