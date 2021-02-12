#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Contabilidade                                                                                                                          |
| Lançamentos Padrões                                                                                                                    |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 02/06/2020                                                                                                                       |
| Descricao: Retornar o valor do custo da mercadoria (isto devido ao tambannho do campo da CT5 não comportar mais de 255 caracteres)     |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function LP01

Local aArea     := GetArea()
Local nCustD1   := 0

nCustD1   := SD1->D1_TOTAL - IIF( U_ICM(), SD1->D1_VALICM + SD1->D1_ICMSCOM, 0 ) + ;
             IIF( U_ICMRET() .AND. !U_ICM(), 0, SD1->D1_ICMSRET ) + IIF( U_IPI(), 0, SD1->D1_VALIPI ) - SD1->D1_VALDESC + SD1->D1_VALFRE + SD1->D1_DESPESA - ;
             IIF( SF4->F4_PISCRED == "1" .AND. SA2->A2_EST <> "EX", SD1->D1_VALIMP5 + SD1->D1_VALIMP6, 0 ) + SD1->D1_VALCMAJ

RestArea(aArea)

Return(nCustD1)
