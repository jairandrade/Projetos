#include "protheus.ch"

//-------------------------------
/*/{Protheus.doc} MCOM004
Rotina para verificar se a cotação esta cancelada ou não.

@author Lucas
@since 16/05/2013
@version 1.0

@param cC8Num, character, Número da cotação para verificação.

@return lRet Retorno lógico da função.

@obs
	Lucas - FSW - Totvs Curitiba | 17/06/2014:
		Alterada rotina para inserir tratamento para legendas de declínio do workflow de cotações.
/*/
//-------------------------------
User Function MCOM004( cC8Num )

Local aArea := GetArea()
Local lRet  := .F.
Local cMsg  := 'A operação não pode ser concluída pois a cotação esta cancelada.'

if (cC8Num != Nil)
	// vai verificar se encontra a cotação
	// se não encontrar, retornar que a mesma não esta bloqueada
	dbSelectArea('SC8')
	SC8->(dbGoTop())
	if !SC8->(dbSeek(xFilial('SC8') + cC8Num))
		return lRet
	endif
endif

if !Empty(SC8->C8_MOTCAN) .AND. !Empty(SC8->C8_USUCAN) .AND. !Empty(SC8->C8_DTCANC)
	Aviso( 'Verificação da cotação', cMsg, { "Ok" }, 2, 'Cotação cancelada', 1, , .F.)
	lRet := .T.
endif

if !empty(SC8->C8_XHORA) .and. !Empty(SC8->C8_XDATAD)
	cMsg  := 'A operação não pode ser concluída pois a cotação esta declinada pelo fornecedor.'
	Aviso( 'Verificação da cotação', cMsg, { "Ok" }, 2, 'Cotação Declinada', 1, , .F.)
	lRet := .T.
endif

RestArea(aAreA)

Return lRet