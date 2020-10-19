#include "protheus.ch"
#Include 'rwmake.ch'

/*/{Protheus.doc} TCGP02KM
Tela para data de fechamento dos atestados medicos
@type  Function
@author Kaique Mathias
@since 19/12/2019
@version 1.0
/*/

User Function TCGP02KM()

    LOCAL nAcao     := 0
    LOCAL dDtLim    := GETMV("TCP_DTMDT")
    LOCAL oDlg1     

    DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("Data de Fechamento") from 150, 030 TO 250, 300  PIXEL
    
    @ 005, 005 Say "Data atual -> "
    @ 005, 045 GET dDtLim SIZE 040,015
    @ 020, 045 BMPBUTTON TYPE 1 ACTION (nAcao:= 1,oDlg1:End())
    @ 020, 085 BMPBUTTON TYPE 2 ACTION oDlg1:End()

    ACTIVATE DIALOG oDlg1 CENTERED

    If  ( nAcao == 1 ) .And. (Aviso("Confirmação para alteração.","Confirma a alteração da Data Limite para lançamentos de atestado medico para " + DToC(dDtLim) + " ?",{"Sim","Não"})==1)
        PUTMV("TCP_DTMDT", dDtLim)
    EndIf

Return( Nil )