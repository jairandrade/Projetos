#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LinCol
description
@author  Kaique Sousa
@since   07/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------

User Function LinCol(cLinha,cSimbolo)
 
Local aRet      := {}
Local cAux      := ""
Local X         := 0
 
Default cSimbolo  := "~#/\_-:;|,"
 
//Efetua um Loop comparando Caracter por Caracter com simbolos mais usados.
For X := 1 To Len(AllTrim(cLinha))
    If !(SubStr(cLinha,X,1) $ cSimbolo)
        cAux    := cAux + SubStr(cLinha,X,1)
    Else
        If !Empty(cAux)
                aADD(aRet,cAux)
        EndIf
        cAux    := " "
    EndIf
Next X
 
//Caso não tenha adicionado o ultimo conteudo
If !Empty(cAux)
    aADD(aRet,cAux)
    cAux    := ""
EndIf
 
Return( aRet )