#include "totvs.ch"

/*/{Protheus.doc} F050INC
description
@type function
@version 
@author Kaique Mathias
@since 8/6/2020
@return return_type, return_description
/*/

User Function F050INC()

	Local aArea     := SE2->(GetArea())
	Local lCtrApr   := GetMv("TCP_CTLIBP")
	Local lContinua := .T.

	If( lCtrApr )
		If( Alltrim( FunName() ) $ "FINA870" )

			If ExistBlock("TCFIA005")
				MsAguarde({|| Execblock("TCFIA005",.F.,.F.)}, "Aguarde...", "Gravando titulo:"+SE2->E2_NUM+" Tipo:"+SE2->E2_TIPO +" Saldo:"+TransForm(SE2->E2_SALDO,"99999.99" )+" ...")
				// Execblock("TCFIA005",.F.,.F.)
			EndIf

		EndIf
	EndIf

	RestArea( aArea )

Return( Nil )
