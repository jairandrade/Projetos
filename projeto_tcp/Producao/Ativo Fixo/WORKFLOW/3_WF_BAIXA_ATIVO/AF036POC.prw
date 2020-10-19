#include "totvs.ch"

/*/{Protheus.doc} AF036POC
    Ponto de entrada chamado na Pós-Gravação dos dados baixa de ativo.
    @type  Function
    @author Willian Kaneta
    @since 27/08/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function AF036POC()
    
    //Executa função para envio do WF de Baixa Ativo Fixo
    U_TCAT03WK(3)
Return Nil
