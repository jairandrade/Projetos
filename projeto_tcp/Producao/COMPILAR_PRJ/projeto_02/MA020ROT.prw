#include "protheus.ch"

/*/{Protheus.doc} F290Can
//O ponto de entrada MA020ROT Adiciona mais opções ao menu.
@author Jair Andrade    
@since 21/10/2020
@version version
/*/
User Function MA020ROT()
Local aRotUser := {}
//Define Array contendo as Rotinas a executar do programa     
// ----------- Elementos contidos por dimensao ------------    
// 1. Nome a aparecer no cabecalho                             
// 2. Nome da Rotina associada                                 
// 3. Usado pela rotina                                        
// 4. Tipo de Transacao a ser efetuada                         
//    1 - Pesquisa e Posiciona em um Banco de Dados            
//    2 - Simplesmente Mostra os Campos                        
//    3 - Inclui registros no Bancos de Dados                  
//    4 - Altera o registro corrente                           
//    5 - Remove o registro corrente do Banco de Dados         
//    6 - Altera determinados campos sem incluir novos Regs     
AAdd( aRotUser, { 'Reenvio de Avaliação', 'U_RCOM009()', 0, 4 } )
Return (aRotUser)
