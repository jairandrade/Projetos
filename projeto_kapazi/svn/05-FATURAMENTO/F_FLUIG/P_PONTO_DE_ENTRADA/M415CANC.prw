#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} M415CANC
//TODO Nao permitir cancelar um orcamento gerado pelo Fluig.
@author Reinaldo Santos
@since 13/04/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function M415CANC()

	Local nRet := 1

	If !Empty(M->CJ_XNUMFLU) 
		MessageBox("Orçamentos Gerados pelo APP não podem ser Cancelados.","Fluig - Gestao Cooperkap",64)
		nRet := 0
	EndIf

return nRet