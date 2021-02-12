#Include 'Protheus.ch'

/*/{Protheus.doc} MT415AUT
//TODO Autorizar baixa do orçamento.
Este ponto de entrada pertence à rotina de atualização de orçamentos de venda, MATA415(). 
Está localizado na rotina de baixa, A415BAIXA(). É usado para autorizar a baixa do orçamento.
@author Reinaldo Santos
@since 13/04/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function MT415AUT()
	Local lRet := .T.
	
	If Empty(SCJ->CJ_XNUMFLU)
	    Alert('Esse orçamento ainda não foi integrado com o Fluig.')
		lRet := .F.
	else	
		If !Empty(SCJ->CJ_XAPROVA)
			If SCJ->CJ_XAPROVA == '1' //PENDENTE		
				MessageBox("Orçamento Pendente de aprovação no Fluig: " + CJ_XNUMFLU + ".","Fluig - Gestao Cooperkap",64)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
Return lRet

