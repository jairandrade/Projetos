#include 'protheus.ch'
#include 'parmtype.ch'
/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Contabilidade                                                                                                                          |
| Conta Contábil                                                                                                                         |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 23/10/2018                                                                                                                       |
| Descricao: Verificar condição no TES para regras em LPs                                                                                |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function ICM

local aArea		:= GetArea()
Local lIcm		:= IIF( (!(SF4->F4_LFICM$"I|N") .AND. !(SF4->F4_SITTRIB$"10|20|70|90")) .OR. SF4->F4_CIAP=="S"  .OR. (SF4->F4_LFICM=="T" .AND. SF4->F4_SITTRIB=="90" .AND. SF4->F4_ICMSDIF=="3"),.T.,.F.)

RestArea(aArea)

Return(lIcm)

User Function ICMRET

local aArea		:= GetArea()
Local lIcmRet	:= IIF(SF4->F4_SITTRIB$"10|30" ,.T.,.F.)

RestArea(aArea)

Return(lIcmRet)

User Function IPI

local aArea		:= GetArea()
//Local lIpi		:= IIF(SF4->F4_LFIPI=="T".AND.SF4->F4_CTIPI=="00",.T.,.F.)
Local lIpi		:= IIF(SF4->F4_CTIPI=="00",.T.,.F.)

RestArea(aArea)

Return(lIpi)
