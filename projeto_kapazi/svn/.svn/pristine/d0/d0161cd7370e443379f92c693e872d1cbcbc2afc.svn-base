#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} A415TDOK
//TODO VALIDACAO DA TUDOOK - ORCAMENTO DE VENDA
Este ponto de entrada é disparado na validação da tudook da rotina de orcamento de venda..
Não permite alterar um orçamento se já estiver sido aprovado no Fluig.
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
		MSGALERT("Orçamento já foi aprovado pelo Fluig, Não poderá ser alterado!")
		lRet := .F.

	ElseIf ALTERA .and. SCJ->CJ_XAPROVA == '3'
		MSGALERT("Orçamento foi cancelado pelo Franqueado, Não poderá ser alterado!")
		lRet := .F.
	EndIf
	
	RestArea(aArea)

Return lRet