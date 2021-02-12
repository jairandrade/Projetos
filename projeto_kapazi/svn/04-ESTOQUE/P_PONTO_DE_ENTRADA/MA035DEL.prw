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
| Descricao: Excluir item contabil na exclusão do cadastro de grupos de produtos                                                         |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function MA035DEL()

	// ROTINA MATA035 MUDOU PARA MVC
	// MA035DEL É CHAMADO NA INCLUSAO E ALTERACAO DO GRUPO
	// ADICIONADO TRATATIVA PARA SO CHAMAR A FUNCAO  DE DELECAO QUANDO FOR EXCLUSAO (NAO FOR INCLUSAO/ALTERACAO)
	If !INCLUI .AND. !ALTERA
		U_DeleCTD("E")
	Endif
	
Return
