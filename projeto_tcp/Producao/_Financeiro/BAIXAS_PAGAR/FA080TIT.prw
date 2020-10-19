#include 'protheus.ch'

/*/{Protheus.doc} FA080TIT
O ponto de entrada FA080TIT sera utilizado na confirmacao da tela 
de baixa do contas a pagar, antes da gracacao dos dados.
@type function
@version 
@author Kaique Mathias
@since 8/6/2020
@return logical, lReturn
/*/

User Function FA080TIT()
    
    Local lCtrApr   := GetMv("TCP_CTLIBP")
    Local lReturn   := .T.

    If( lCtrApr )
        If( Empty(SE2->E2_DATALIB) .And. !Empty(SE2->E2_XCODPGM) .And. Alltrim( SE2->E2_ORIGEM ) $ "FINA376/FINA378/FINA290/FINA870" )
            Help(' ', 1 , "FA080NAOLIB")
            lReturn := .F.
        EndIf
    EndIf

Return( lReturn )
