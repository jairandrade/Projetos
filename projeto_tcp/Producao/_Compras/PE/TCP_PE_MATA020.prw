/*---------------------------------------------------------------------------+
|                         FICHA TECNICA DO PROGRAMA                          |
+----------------------------------------------------------------------------+
|   DADOS DO PROGRAMA                                                        |
+------------------+---------------------------------------------------------+
|Tipo              | Rotina                                                  |
+------------------+---------------------------------------------------------+
|Modulo            | Compras                                                 |
+------------------+---------------------------------------------------------+
|Nome              | TCP_PE_MATA020.PRW                                      |
+------------------+---------------------------------------------------------+
|Descricao         | Fonte de pontos de entrada do MATA020 (fornecedores).   |
+------------------+---------------------------------------------------------+
|Autor             | Lucas José Corrêa Chagas                                |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 16/05/2013                                              |
+------------------+---------------------------------------------------------+
|   ATUALIZACOES                                                             |
+-------------------------------------------+-----------+-----------+--------+
|   Descricao detalhada da atualizacao      |Nome do    | Analista  |Data da |
|                                           |Solicitante| Respons.  |Atualiz.|
+-------------------------------------------+-----------+-----------+--------+
|                                           |           |           |        |
|                                           |           |           |        |
+-------------------------------------------+-----------+-----------+-------*/

#Include 'Protheus.ch'
/*--------------------------+----------------------------+--------------------+
| Função: M020INC           | Autor: Lucas J. C. Chagas  | Data: 16/05/2013   |
+------------+--------------+----------------------------+--------------------+
| Parâmetros | LOCALIZAÇÃO : Function FAvalSA2 - Função de Gravações          | 
|            | adicionais do Fornecedor, após sua inclusão.                   |
|            | EM QUE PONTO: Após incluir o Fornecedor, deve ser utilizado    |
|            | para gravar arquivos/campos do usuário, complementando         |
|            | a inclusão.                                                    |
|            | Ponto de Entrada para complementar a inclusão no cadastro do   |
|            | Fornecedor.                                                    |
+------------+----------------------------------------------------------------+
| Descricao  | Rotina para criar uma tela e a partir dela gerar um execauto   |
|            | no mata060.                                                    |
+------------+---------------------------------------------------------------*/
User Function M020INC()
	Local oManusis  

	U_MCOM005()

	if(INCLUI) .AND. SUPERGETMV( 'TCP_MANUSI', .f., .F. ) 
		oManusis  := ClassIntManusis():newIntManusis()              
			
		oManusis:cFilZze    := xFilial('ZZE')
		oManusis:cChave     := SA2->A2_FILIAL+SA2->A2_COD+SA2->A2_LOJA
		oManusis:cTipo	    := 'E'
		oManusis:cStatus    := 'P'
		oManusis:cErro      := ''
		oManusis:cEntidade  := 'SA2'
		oManusis:cOperacao  := if(INCLUI,'I',IF(ALTERA,'A','E'))
		oManusis:cRotina    :=  FunName()
		oManusis:cErroValid := ''
		
		IF oManusis:gravaLog()  
			U_MNSINT03(oManusis:cChaveZZE)              
		ELSE
			ALERT(oManusis:cErroValid)
		ENDIF  
	ENDIF

Return .T.