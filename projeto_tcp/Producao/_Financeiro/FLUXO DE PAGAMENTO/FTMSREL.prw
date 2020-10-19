#include 'Protheus.ch'

/*/{Protheus.doc} FTMSREL
@description Ponto de entrada que cria a entidade para a MsDocument
@author Kaique Mathias
@since 20/03/2018
/*/

USER FUNCTION FTMSREL()
    
	LOCAL aEntidade 	:= {}

	AADD( aEntidade, { "SC1", { "C1_FILIAL","C1_NUM"}, { || SC1->C1_FILIAL+SC1->C1_NUM } } )
	AADD( aEntidade, { "SC7", { "C7_FILIAL","C7_NUM"}, { || SC7->C7_FILIAL+SC7->C7_NUM } } )
	AADD( aEntidade, { "ZA0", { "ZA0_FILIAL","ZA0_CODIGO" }, { || ZA0->ZA0_FILIAL+ZA0->ZA0_CODIGO } } )

Return( aEntidade )