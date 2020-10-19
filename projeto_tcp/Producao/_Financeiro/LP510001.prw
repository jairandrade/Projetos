/*
+----------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! 
+------------------+---------------------------------------------------------+
!Modulo            ! Diversos                                                !
+------------------+---------------------------------------------------------+
!Nome              ! LP510001                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Contabilizacao CP MULTNAT CC                            !
+------------------+---------------------------------------------------------+
!Autor             ! Edilson Marques                                         !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 23/08/2012                                              !
+------------------+---------------------------------------------------------+
*/

#include "protheus.ch"
User Function LP510001  
Local _cAreaSE2 := SE2->(GetArea())
Local _cAreaSEV := SEV->(GetArea())
SetPrvt("_CCUSTO")
_CCUSTO := " "


DbSelectarea ("SE2")
SE2->(DBSETORDER(1))
SE2->(DBGOTOP())
SE2->(DBSEEK(XFILIAL("SE2")+SEV->EV_PREFIXO+SEV->EV_NUM+SEV->EV_PARCELA+SEV->EV_TIPO+SEV->EV_CLIFOR+SEV->EV_LOJA))    
_CCUSTO:= SE2->E2_CC
                   
RestArea(_cAreaSE2)
RestArea(_cAreaSEV)

Return(_CCUSTO)