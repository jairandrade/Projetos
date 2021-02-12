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
| Descricao: Excluir item contabil na exclusão do cadastro de clientes                                                                   |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function M030EXC()

If Inclui .And. !Empty(SA1->A1_XPERSV) .And. Alltrim(SA1->A1_XGERASV) == "S" //NF MISTA
	Reclock("SA1", .F.)		    
	SA1->A1_XFLAGSV := "X"
	SA1->A1_XDATASV := Date()
	SA1->A1_XHORASV := time()
	SA1->A1_XQUEMSV := UsrFullName(__cUserID) 		    
	SA1->(MsUnlock())

EndIf

U_DeleCTD("C")

Return Nil
