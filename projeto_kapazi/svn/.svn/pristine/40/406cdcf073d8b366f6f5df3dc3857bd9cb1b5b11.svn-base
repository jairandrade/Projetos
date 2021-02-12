#include 'protheus.ch'
#include 'parmtype.ch'
/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Contabilidade                                                                                                                          |
| Filtro na contabilização do SE5                                                                                                        |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 26/09/2019                                                                                                                       |
| Descricao: Filtrar para que não seja contabilizado os movimentos com o E5_MOTBX = CEC                                                  |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function F370E5F()
Local cQry := PARAMIXB

cQry += " AND SE5.E5_MOTBX != 'CEC' "
	
Return(cQry)