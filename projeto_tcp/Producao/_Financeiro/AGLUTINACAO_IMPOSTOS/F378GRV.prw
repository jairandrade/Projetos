#include "protheus.ch"

/*/{Protheus.doc} F378GRV
O ponto de entrada F378GRV será executado após a gravação de títulos de impostos 
já apurados na aglutinação de PIS/COFINS/CSLL.
@type  User Function
@author Kaique Mathias
@since 27/07/2020
@version 1.0
@return Nil
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6071035
/*/

User Function F378GRV()

    Local lCtrApr   := GetMv("TCP_CTLIBP")
    Local aArea     := GetArea()   
    
    If( lCtrApr )
        Execblock("TCFIA005",.F.,.F.)
    EndIf

    RestArea( aArea )

Return( Nil )
