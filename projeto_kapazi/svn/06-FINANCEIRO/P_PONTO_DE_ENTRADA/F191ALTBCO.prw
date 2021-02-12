#include "rwmake.ch"
#include "protheus.ch"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Financeiro                                                                                                                             |
| Alteração do banco na compensação do cheque recebido                                                                                   |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 01/05/2017                                                                                                                       |
| Descricao: Este ponto de entrada serve para que a conta contabil do banco selecionado na compensação                                   |
|            seja gravado na SEF para que na contabilização Off-Line o LP tenha a conta referente ao banco (isto devido ao sistema não   |
|            posicionar na SA6 e nem na SE5 na contabilização do LP 559)                                                                 |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function F191ALTBCO()

Local _aArea	:= GetArea()
Local cBanco	:= paramixb[1]
Local cAgencia	:= paramixb[2]
Local cConta	:= paramixb[3]
Local aNWBco	:= {}

AADD (aNWBco,{cBanco,cAgencia,cConta})

SA6->(DbSetOrder(1))
If SA6->(MsSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
	cCTA	:= SA6->A6_CONTA
EndIf

Reclock ("SEF",.F.)
SEF->EF_CREDIT	:= cCTA
SEF->(MsUnlock())

RestArea(_aArea)

Return(aNWBco)
