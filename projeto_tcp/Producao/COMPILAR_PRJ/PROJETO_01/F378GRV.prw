#include "protheus.ch"

/*/{Protheus.doc} F378GRV
O ponto de entrada F378GRV ser� executado ap�s a grava��o de t�tulos de impostos 
j� apurados na aglutina��o de PIS/COFINS/CSLL.
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
		MsgInfo( "Gravando titulo:"+SE2->E2_NUM+" Tipo:"+SE2->E2_TIPO +" Saldo:"+TransForm(SE2->E2_SALDO,"99999.99" )+" Cod.Retencao:"+SE2->E2_CODRET, "Grava��o de contas a pagar" )
		Execblock("TCFIA005",.F.,.F.)
	EndIf

	RestArea( aArea )

Return( Nil )
