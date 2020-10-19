#include "protheus.ch"

/*/{Protheus.doc} F040ADLE
description
@type function
@version 
@author kaiquesousa
@since 8/6/2020
@return return_type, return_description
/*/

User Function F040ADLE

    Local lCtrApr   := GetMv("TCP_CTLIBP")
    Local aRet := {}

    If( lCtrApr .And. Alltrim(FunName()) $ "FINA050/FINA750/FINA080" )
        aAdd(aRet,{"BR_PINK","Titulo aguardando liberacao"})
    EndIf

Return( aRet )
