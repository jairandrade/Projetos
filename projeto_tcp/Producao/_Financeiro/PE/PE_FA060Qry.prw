#include "rwmake.ch"

/*
@author Valtenio Oliveira
@version P12
@since 12/09/2018
@Ponto de Entrada na geração de bordero a receber (SE1/SA6)
*/
User Function FA060Qry()

Local cRet := ""

// Expressao SQL de filtro que sera adicionada a clausula WHERE da Query.
cRet := " E1_CLIENTE+E1_LOJA IN ( SELECT A1_COD+A1_LOJA FROM "+RetSqlName("SA1")+" SA1 WHERE A1_XBORDER <> 'N' AND SA1.D_E_L_E_T_ <> '*' ) " 

Return cRet