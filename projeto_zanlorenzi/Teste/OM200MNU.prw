/*Descrição:
Ponto de entrada disparado antes da abertura do Browse, caso Browse inicial da rotina esteja habilitado, ou antes da apresentação do Menu de opções, caso Browse inicial esteja desabilitado.

Eventos

 

Programa Fonte
OMSA200.PRW
Sintaxe
OM200MNU - Inclusão de Novas Opções ( ) --> Nil

Retorno
Nil(nulo)
Nil
Observações
Para habilitar ou desabilitar o Browse, entre na rotina, clique em Configurações/Browse Inicial e selecione
a opção desejada:
Sim - Habilitar Browse Inicial
Não - Desabilitar Browse Inicial
Este ponto de entrada pode ser utilizado para inserir novas opções no array aRotina.

Exemplos
aadd(aRotina,{'TEXTO DO BOTÃO','NOME DA FUNÇÃO' , 0 , 3,0,NIL})   ONDE:Parametros do array a Rotina:1. Nome a aparecer no cabecalho2. Nome da Rotina associada   3. Reservado                       4. Tipo de Transação a ser efetuada:     1 - Pesquisa e Posiciona em um Banco de Dados     2 - Simplesmente Mostra os Campos                 3 - Inclui registros no Bancos de Dados            4 - Altera o registro corrente                     5 - Remove o registro corrente do Banco de Dados5. Nivel de acesso                                  6. Habilita Menu Funcional

*/
 /*/{Protheus.doc} 
Return
    (long_description)
    @type  Function
    @author user
    @since 02/12/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function OM200MNU
alert("ANTES DA TELA")
    
Return 
