#include "protheus.ch"

/*/{Protheus.doc} F376GRV
O ponto de entrada F376GRV será executado após a gravação de títulos de impostos 
@type  User Function
@author Kaique Mathias
@since 27/07/2020
@version 1.0
@return Nil
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6071035
/*/

User Function F376GRV()

    Local lCtrApr   := GetMv("TCP_CTLIBP")
    Local aArea     := GetArea()   
    
    If( lCtrApr )
        Public __nRecSE2_ := SE2->(Recno())
    EndIf

    RestArea( aArea )

Return( Nil )
