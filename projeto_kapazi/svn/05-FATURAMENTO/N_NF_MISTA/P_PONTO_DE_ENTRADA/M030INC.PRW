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
| Descricao: Criar item contabil na inclusão do cadastro de clientes                                                                     |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function M030INC()

If Inclui .And. !Empty(SA1->A1_XPERSV) .And. Alltrim(SA1->A1_XGERASV) == "S" .And. PARAMIXB != 3 //NF MISTA
		Reclock("SA1", .F.)		    
		SA1->A1_XFLAGSV := "X"
		SA1->A1_XDATASV := Date()
		SA1->A1_XHORASV := time()
		SA1->A1_XQUEMSV := UsrFullName(__cUserID) 		    
		//SA1->A1_XCOB	:= U_BUSATEND() //Busca atendente
		SA1->(MsUnlock())
	
	Else
		//Reclock("SA1", .F.)
		//SA1->A1_XCOB	:= U_BUSATEND() //Busca atendente
		//SA1->(MsUnlock())
		
EndIf

If Inclui .And. PARAMIXB != 3
	U_GeraCTD("C")
EndIf

Return Nil
