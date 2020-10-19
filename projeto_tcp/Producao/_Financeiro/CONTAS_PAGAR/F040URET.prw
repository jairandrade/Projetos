#include "protheus.ch"

/*/{Protheus.doc} F040URET
description
@type function
@version 
@author kaiquesousa
@since 8/6/2020
@return return_type, return_description
/*/

User Function F040URET()
    
    Local lCtrApr   := GetMv("TCP_CTLIBP")
    Local uRet      := {}
    
    If( lCtrApr .And. Alltrim(FunName()) $ "FINA050/FINA750/FINA080" )
        Aadd(uRet, { 'EMPTY(E2_DATALIB) .AND. E2_SALDO > 0 .AND. !EMPTY(E2_XCODPGM) .AND. Alltrim(SE2->E2_ORIGEM) $ "FINA376/FINA378/FINA290/FINA870"', "BR_PINK" } )
    EndIf

Return( uRet )
