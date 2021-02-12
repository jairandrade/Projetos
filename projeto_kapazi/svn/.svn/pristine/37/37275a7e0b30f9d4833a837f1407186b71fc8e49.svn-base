#include "rwmake.ch"
#include "protheus.ch"


/*                       	
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Financeiro                                                                                                                             |
| Extrato bancário                                                                                                                       |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 05/12/2016                                                                                                                       |
| Descricao: Deve informar se o sistema não vai filtrar por filial - considerando todas as filiais (.F.) ou vai filtrar por filial -     |
| considerando somente os registros da filial corrente(.T.)                                                                              |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/


User Function F470ALLF
Local lAllFil := ParamIxb[1]

//Comparar qual foi a resposta para emissão do extrato (considerar o movimento apenas da Filial = 1 ou do Banco (todas as filiais) = 2)
If MV_PAR10 == 1
	lAllFil := .F. //FILIAL CORRENTE
Else
	lAllFil := .T. //TODAS AS FILIAIS
EndIf

Return(lAllFil)