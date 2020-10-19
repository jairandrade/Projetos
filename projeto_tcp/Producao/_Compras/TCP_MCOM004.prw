#include "protheus.ch"

//-------------------------------
/*/{Protheus.doc} MCOM004
Rotina para verificar se a cota��o esta cancelada ou n�o.

@author Lucas
@since 16/05/2013
@version 1.0

@param cC8Num, character, N�mero da cota��o para verifica��o.

@return lRet Retorno l�gico da fun��o.

@obs
	Lucas - FSW - Totvs Curitiba | 17/06/2014:
		Alterada rotina para inserir tratamento para legendas de decl�nio do workflow de cota��es.
/*/
//-------------------------------
User Function MCOM004( cC8Num )

Local aArea := GetArea()
Local lRet  := .F.
Local cMsg  := 'A opera��o n�o pode ser conclu�da pois a cota��o esta cancelada.'

if (cC8Num != Nil)
	// vai verificar se encontra a cota��o
	// se n�o encontrar, retornar que a mesma n�o esta bloqueada
	dbSelectArea('SC8')
	SC8->(dbGoTop())
	if !SC8->(dbSeek(xFilial('SC8') + cC8Num))
		return lRet
	endif
endif

if !Empty(SC8->C8_MOTCAN) .AND. !Empty(SC8->C8_USUCAN) .AND. !Empty(SC8->C8_DTCANC)
	Aviso( 'Verifica��o da cota��o', cMsg, { "Ok" }, 2, 'Cota��o cancelada', 1, , .F.)
	lRet := .T.
endif

if !empty(SC8->C8_XHORA) .and. !Empty(SC8->C8_XDATAD)
	cMsg  := 'A opera��o n�o pode ser conclu�da pois a cota��o esta declinada pelo fornecedor.'
	Aviso( 'Verifica��o da cota��o', cMsg, { "Ok" }, 2, 'Cota��o Declinada', 1, , .F.)
	lRet := .T.
endif

RestArea(aAreA)

Return lRet