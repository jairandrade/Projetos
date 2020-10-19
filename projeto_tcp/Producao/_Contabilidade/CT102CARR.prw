#include "totvs.ch"

/*/{Protheus.doc} CT102CARR
    Ponto de entrada CT102CARR efetua o tratamento no momento de carregar os dados para o temporario. 
    Tem a função de manipular o temporário no momento da leitura. CTBA102
    @type  Function
    @author Willian Kaneta
    @since 23/06/2020
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function CT102CARR()
    Local nOpc := PARAMIXB[1]
    
    If (nOpc == 3 .OR. nOpc == 4 .OR. nOpc == 6 .OR. nOpc == 7) .AND. !(IsBlind())
        TMP->CT2_TPSALD := "9"
    EndIf
    
Return Nil
