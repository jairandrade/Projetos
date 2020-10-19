#include 'totvs.ch'

/*/{Protheus.doc} AF240CLA
    Ponto de entrada executado ao final do processo de Classificação de Bens. (ATFA240)
    @type  Function
    @author Willian Kaneta
    @since 27/08/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function AF240CLA()

    //Envia WF Classificação Ativo Fixo
    U_TCAT02WK(6)
Return Nil
