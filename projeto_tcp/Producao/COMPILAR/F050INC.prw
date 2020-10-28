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

	If( lCtrApr )
		If( Alltrim( FunName() ) $ "FINA870" )

			If ExistBlock("TCFIA005")
				//ApMsgAlert("Gravando titulo:"+SE2->E2_NUM+" Tipo:"+SE2->E2_TIPO +" Saldo:"+TransForm(SE2->E2_SALDO,"99999.99" )+" Cod.Retencao:"+SE2->E2_CODRET, "Gravação de contas a pagar")
			   	//MsgInfo( "Gravando titulo:"+SE2->E2_NUM+" Tipo:"+SE2->E2_TIPO +" Saldo:"+TransForm(SE2->E2_SALDO,"99999.99" )+" Cod.Retencao:"+SE2->E2_CODRET, "Gravação de contas a pagar" )
				  Help(NIL, NIL, "Gravação de contas a pagar", NIL, "Contas a pagar", 1,0, NIL, NIL, NIL, NIL, NIL,;
                    {"Gravando titulo:"+SE2->E2_NUM+" Tipo:"+SE2->E2_TIPO +" Saldo:"+TransForm(SE2->E2_SALDO,"99999.99" )+" Cod.Retencao:"+SE2->E2_CODRET})
					Execblock("TCFIA005",.F.,.F.)
			EndIf

		EndIf
	EndIf

	RestArea( aArea )

Return( Nil )
