/*Descri��o:
Ponto de entrada disparado antes da abertura do Browse, caso Browse inicial da rotina esteja habilitado, ou antes da apresenta��o do Menu de op��es, caso Browse inicial esteja desabilitado.

Eventos

 

Programa Fonte
OMSA200.PRW
Sintaxe
OM200MNU - Inclus�o de Novas Op��es ( ) --> Nil

Retorno
Nil(nulo)
Nil
Observa��es
Para habilitar ou desabilitar o Browse, entre na rotina, clique em Configura��es/Browse Inicial e selecione
a op��o desejada:
Sim - Habilitar Browse Inicial
N�o - Desabilitar Browse Inicial
Este ponto de entrada pode ser utilizado para inserir novas op��es no array aRotina.

Exemplos
aadd(aRotina,{'TEXTO DO BOT�O','NOME DA FUN��O' , 0 , 3,0,NIL})   ONDE:Parametros do array a Rotina:1. Nome a aparecer no cabecalho2. Nome da Rotina associada   3. Reservado                       4. Tipo de Transa��o a ser efetuada:     1 - Pesquisa e Posiciona em um Banco de Dados     2 - Simplesmente Mostra os Campos                 3 - Inclui registros no Bancos de Dados            4 - Altera o registro corrente                     5 - Remove o registro corrente do Banco de Dados5. Nivel de acesso                                  6. Habilita Menu Funcional

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
