#Include 'Protheus.ch'

/*/{Protheus.doc} MT415AUT
//TODO Autorizar baixa do or�amento.
Este ponto de entrada pertence � rotina de atualiza��o de or�amentos de venda, MATA415(). 
Est� localizado na rotina de baixa, A415BAIXA(). � usado para autorizar a baixa do or�amento.
@author Reinaldo Santos
@since 13/04/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function MT415AUT()
	Local lRet := .T.
	
	If Empty(SCJ->CJ_XNUMFLU)
	    Alert('Esse or�amento ainda n�o foi integrado com o Fluig.')
		lRet := .F.
	else	
		If !Empty(SCJ->CJ_XAPROVA)
			If SCJ->CJ_XAPROVA == '1' //PENDENTE		
				MessageBox("Or�amento Pendente de aprova��o no Fluig: " + CJ_XNUMFLU + ".","Fluig - Gestao Cooperkap",64)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
Return lRet

