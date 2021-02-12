#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} A415TDOK
//TODO VALIDACAO DA TUDOOK - ORCAMENTO DE VENDA
Este ponto de entrada � disparado na valida��o da tudook da rotina de orcamento de venda..
N�o permite alterar um or�amento se j� estiver sido aprovado no Fluig.
@author Reinaldo Santos
@since 13/04/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function A415TDOK()

	Local lRet  := .T.
	local aArea := getArea()
	
	If ALTERA .and. SCJ->CJ_XAPROVA == '2'
		MSGALERT("Or�amento j� foi aprovado pelo Fluig, N�o poder� ser alterado!")
		lRet := .F.

	ElseIf ALTERA .and. SCJ->CJ_XAPROVA == '3'
		MSGALERT("Or�amento foi cancelado pelo Franqueado, N�o poder� ser alterado!")
		lRet := .F.
	EndIf
	
	RestArea(aArea)

Return lRet