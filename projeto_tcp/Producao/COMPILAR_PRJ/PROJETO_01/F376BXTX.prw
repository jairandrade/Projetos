#include "totvs.ch"

/*/{Protheus.doc} User Function F376BXTX
Acessa as informações da baixa de títulos TX
@type  Function
@author Kaique Mathias
@since 18/08/2020
@version 1.0
/*/

User Function F376BXTX()

    Local lCtrApr   := GetMv("TCP_CTLIBP")
    Local aArea     := GetArea()   
    
    If( lCtrApr )
        Execblock("TCFIA005",.F.,.F.)
    EndIf

    RestArea( aArea )

Return( Nil )
