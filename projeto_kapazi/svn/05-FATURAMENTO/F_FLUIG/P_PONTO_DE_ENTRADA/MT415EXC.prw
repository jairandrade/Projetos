#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT415EXC
//TODO ANTES DA EXCLUS�O DO OR�AMENTO DE VENDAS.
@author Reinaldo Santos
@since 13/04/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
user function MT415EXC()

	Local lRet := .T.
	
	If !Empty(M->CJ_XNUMFLU)
		MessageBox("Or�amentos Gerados pelo APP n�o podem ser Excluidos.","Fluig - Gestao Cooperkap",64)
		lRet := .F.
	EndIf
	
return lRet