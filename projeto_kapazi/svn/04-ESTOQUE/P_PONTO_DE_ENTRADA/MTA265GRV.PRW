#include "protheus.ch"


/*/{Protheus.doc} MTA265GRV
Ponto de entrada ao final da gravacao do enderecamento
@type function
@version 
@author luizh
@since 21/05/2020
@return nil, sem retorno.
/*/
User Function MTA265GRV()
	Local aArea 		:= GetArea()
	// ativa bloqueio de produto / liberacao para nao ir pra venda no app
	Local lBlqProdApp	:= GetMV("KP_BLQPRAP",,.F.)

	If lBlqProdApp .and. ExistBlock("KFATR24") .and. SDA->DA_LOCAL == "01"
		StaticCall(KFATR24,AnaliseSaldo,SDA->DA_PRODUTO)
	Endif

	RestArea(aArea)
Return

