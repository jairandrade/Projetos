#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT415EXC
//TODO ANTES DA EXCLUSÃO DO ORÇAMENTO DE VENDAS.
@author Reinaldo Santos
@since 13/04/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
user function MT415EXC()

	Local lRet := .T.
	
	If !Empty(M->CJ_XNUMFLU)
		MessageBox("Orçamentos Gerados pelo APP não podem ser Excluidos.","Fluig - Gestao Cooperkap",64)
		lRet := .F.
	EndIf
	
return lRet