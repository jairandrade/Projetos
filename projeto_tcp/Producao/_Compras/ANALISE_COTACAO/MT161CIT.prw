#include "totvs.ch"

/*/{Protheus.doc} MT161CIT
Ponto de Entrada MT161CIT tem como funcionalidade filtrar os itens que vão para analise de cotação. MATA161
@type  Function
@author Willian Kaneta
@since 27/07/2020
@version 1.0
@return cFiltro
@example
(examples)
@see (links_or_references)
/*/
User Function MT161CIT()
    
    Local cFiltro := ''
    
    //Campo Homologação Fornecedor <> Vencida - Acima de 90 dias
    //Campo Homologação Fornecedor <> Sem Cadastro - 
    cFiltro := " AND C8_XHOMFOR <> 'VE' AND C8_XHOMFOR <> 'NH' "

Return (cFiltro)
