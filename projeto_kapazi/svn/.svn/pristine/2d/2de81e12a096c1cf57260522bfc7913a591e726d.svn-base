#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Financeiro                                                                                                                             |
| Validação na inclusão do movimento bancário                                                                                            |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 18/02/2020                                                                                                                       |
| Descricao: Obrigar o preenchimento do centro de custo no movimento bancário                                                            |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function F100TOK()
Local aArea	:= GetArea()
Local lRet	:= .T.

If Empty(M->E5_CCD) .AND. M->E5_RATEIO <> "S"  .and. !lF100Auto
	MsgStop("Para confimar esse lançamento deve-se preencher o centro de custo!","Centro de Custo - F100TOK")
	lRet	:= .F.
EndIf

RestArea(aArea)
Return(lRet)
