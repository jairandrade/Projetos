#include "totvs.ch"
#include "protheus.ch"
// Funcao para padronizar string para envio no WS
User Function fStdString(cString)
    local cNewString

    cNewString := AllTrim(NoAcento(OemToAnsi(cString)))
    cNewString := StrTran(cNewString, "&", "e")
    cNewString := StrTran(cNewString, "'", " ")
    cNewString := StrTran(cNewString, '"', ' ')
	cNewString := EncodeUTF8(AllTrim(cNewString))

Return cNewString

// Funcao para padronizar string para envio no WS
User Function fStdStr2(cString)
    local cNewString

    cNewString := NoAcento(OemToAnsi(cString))
    cNewString := StrTran(cNewString, "&", "e")
    cNewString := StrTran(cNewString, "'", " ")
    cNewString := StrTran(cNewString, '"', ' ')
	cNewString := EncodeUTF8(cNewString)

Return cNewString