#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Contabilidade                                                                                                                          |
| Itens Contábeis                                                                                                                        |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 23/03/2016                                                                                                                       |
| Descricao: rotina para Buscar/Exclusao Itens Itens Contabeis - Tipo Cliente/Fornecedor/Grupo de Produtos                               |
| Carregado pelas funções P.Entrada U_M030EXC(nTipo="C"), U_A020DELE(nTipo="F") e  U_MA035INC(nTipo="E")                                 |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function DeleCTD(nTipo)
Local _LastArea := GetArea()
Local cAuxBusca

If nTipo = "C" //Clientes
	cAuxBusca := "C"+SA1->A1_COD + SA1->A1_LOJA
ElseIf nTipo = "F" //Fornecedores
	cAuxBusca := "F"+SA2->A2_COD + SA2->A2_LOJA
ElseIf nTipo = "E" //Grupo de Produtos
	cAuxBusca := "E"+SBM->BM_GRUPO
EndIf

CTD->(DbGoTop())
If CTD->(DbSeek(xFilial("CTD")+cAuxBusca))
	If RecLock("CTD", .F.)
		CTD->(DbDelete())
		CTD->(MsUnLock())
	Endif
Endif

RestArea(_LastArea)

Return Nil
