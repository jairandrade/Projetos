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
| Descricao: Criar item contabil na inclusão do cadastro de grupos de produtos                                                           |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function MA035INC()
	
	// ROTINA MATA035 MUDOU PARA MVC
	// MA035INC É CHAMADO NA INCLUSAO E ALTERACAO DO GRUPO
	// ADICIONADO TRATATIVA PARA SO CHAMAR A FUNCAO QUANDO FOR INCLUSAO
	If INCLUI
		U_GeraCTD("E")
	Endif
	
Return Nil
