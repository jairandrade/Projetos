#include "TOPCONN.CH"
/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** liberaçaõ pedido de venda                                                                                                		 **/
/** Ponto de entrada MA450PED                               																																		 **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
//Ponto de Entrada pertencente à rotina "Liberação de Crédito" (MATA450). Está localizado no processamento da avaliação 
//automática de crédito por pedidos, MA450PROCES(). É executado ao final do processamento de cada item. 
/**********************************************************************************************************************************/
User Function MT450END()
Local aArea :=	GetArea() 
Local lRet	:=	.T.

//GRAVA DADOS DE LIBERACAO DE CREDITO FINANCEIRO AUTOMATICA
//U_GRVLIBF(.F.)    - COMENTADO DIA 16/11/2017 

//
U_LIES() 
 
cQuebra:=SC9->C9_PEDIDO
dbSelectArea("SC5")
dbSetOrder(1)
MsSeek(xFilial("SC5")+cQuebra)

cQuery:=" Select SUM(C9_QTDLIB*C9_PRCVEN) VLR from "+RETSqlName('SC9')
cQuery+=" WHERE C9_FILIAL='"+XfILIAL('SC9')+"' "
cQuery+=" AND C9_PEDIDO='"+cQuebra+"' " 
cQuery+="  AND C9_BLCRED = '' "
cQuery+=" AND D_E_L_E_T_<>'*'
If Select('TRAB')<>0
	TRAB->(dbCloseArea())
EndIF
TcQuery cQuery new alias 'TRAB'

if !TRAB->(eof())
	nVlr:=TRAB->VLR
EndIF          

reclock('SC5',.F.)
SC5->C5_VLIB := nVlr+SC5->C5_FRETE
msunlock()

/* Processo Fluig */
If Alltrim(cEmpAnt) == "04" //Somente empresa 04 

	// Precisa estar posicionado sobre o registro,
	// por isso não foi usado Query
    SC5->(DBSetOrder(1)) //C5_FILIAL+C5_NUM
    SC5->(DbSeek(xFilial('SC5')+MV_PAR01,.F.)) //Do Pedido
    
    While  !SC5->(EOF()) .and. SC5->C5_FILIAL==xFilial('SC5') .and. SC5->C5_NUM<=MV_PAR02 //até o pedido
		
    	if SC5->C5_CLIENTE>=MV_PAR03 .AND. SC5->C5_CLIENTE<=MV_PAR04 //Do Cliente até o Cliente
			if !isBlq() //Se não está bloqueado
				U_KPLibEst(SC5->C5_NUM)
			endif
		endif
		SC5->(DBSkip())
	enddo
EndIf

RestArea(aArea)

Return	lRet 
*----------------------------------------------------------------------------------------------------
user function LIES()
* Ponto de entrada na liberação de estoques automática
*
* Ricardo Luiz da Rocha 21/11/2011 GNSJC
*----------------------------------------------------------------------------------------------------
local _cPedido:=sc9->c9_pedido

if sc5->(dbseek(xfilial()+_cPedido,.f.).and.reclock(alias(),.f.))
    sc5->c5_xsitlib:=u_KpFatC01(_cPedido)
    
    _vDatas:=sc5->(u_Sc5Libs(_cPFil:=c5_filial,_cPNumPed:=c5_num,_cPSit:=c5_xsitlib,_dPDataP:=C5_xDtLibP,_dPDataF:=C5_xDtLibF,_dPDataE:=C5_xDtLibe))
    sc5->c5_xdtlibp:=_vDatas[1] //DESCOMENTADO DIA 30/05/2017 - SULIVAN
    sc5->c5_xdtlibf:=_vDatas[2]
    sc5->c5_xdtlibe:=_vDatas[3]
    
    sc5->(msunlock())
endif

return  


/*--------------------------------------------------------------------------+
|  isBlq - Retorna .T. se está bloqueado                                    |
----------------------------------------------------------------------------*/
Static function isBlq()
Local cAliasSC9	:= GetNextAlias()
Local lBlqEst:=.F.

//Verifica se houve bloqueio de Crédito
cQuery := "	SELECT C9_BLEST "
cQuery += "	FROM " + RetSqlName("SC9")
cQuery += "	WHERE "
cQuery += "	C9_FILIAL = '" + xFilial("SC9")+"'"
cQuery += "	AND C9_PEDIDO = '" + SC5->C5_NUM+"'"
cQuery += "	AND D_E_L_E_T_ = ' ' "
//cQuery += "	AND C9_NFISCAL = ' ' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.T.,.T.)

While !(cAliasSC9)->(Eof())
	If !Empty((cAliasSC9)->C9_BLEST)
		lBlqEst := .T.
		Exit
	EndIf
	(cAliasSC9)->(dbSkip())
EndDo
(cAliasSC9)->(DBCloseArea())

return lBlqEst