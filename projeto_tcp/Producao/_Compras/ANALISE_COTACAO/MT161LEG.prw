#include "totvs.ch"

/*/{Protheus.doc} MT161LEG
O Ponto de Entrada MT161LEG deve ser utilizado para incluir legenda na rotina de Análise de Cotação
@type  Function
@author Kaique Mathias
@since 27/07/2020
@version 1.0
/*/

User Function MT161LEG()
    
    Local aCores := {}

    Aadd(aCores,{"C8_XHOMFOR $ 'VE|NH' ","PMSEDT4","Produto químico - Fornecedor não homologado nesta data" })
    //Aadd(aCores,{"C8_PRECO==0 .AND. EMPTY(C8_NUMPED) .AND. C8_XHOMFOR $ 'VE|NH' ","WHITE", "Em aberto - Homologação vencida fora do prazo"})
    Aadd(aCores,{"EMPTY(C8_NUMPED) .AND. C8_PRECO <> 0 .AND. !EMPTY(C8_COND) .AND. C8_XHOMFOR == 'AP' ","BROWN", "Produto químico - Homologação vencida no prazo"})

Return( aCores )
