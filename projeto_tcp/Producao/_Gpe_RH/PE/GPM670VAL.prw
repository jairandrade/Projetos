#include "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} GPM670VAL
description Ponto de entrada permite usuário fazer validação da integ
ração do título no financeiro
@author  Kaique Sousa
@since   18/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------

User Function GPM670VAL()

    Local cTipoPm := GetMV("TCP_TPTGPE") //Tipo de titulo que ira ser considerado para inserir no pagamento manual
    Local lRet    := .T.

    If( RC1->RC1_CODTIT $ cTipoPm )
        lRet := Execblock("TCGP04KM",.F.,.F.)
    Else
        cParcela	:= RC1->RC1_PARC
    EndIf

Return( lRet )
