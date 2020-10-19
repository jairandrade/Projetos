#Include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} GPM060EX
O ponto de entrada GPM060EX substitui a validação padrão de exclusão de títulos
No padrão, caso o título não esteja liberado ou esteja inconsistente, o título é excluído normalmente.
Se o título já foi integrado e já foi baixado ou esteja em borderô, a exclusão não será permitida.
@type  User Function
@author Kaique Mathias
@since 13/02/2020
@version P12.1.25
@return lRet, logical, .T. ou .F.
/*/

User Function GPM060EX()

	Local cTitPerm := "001|002|003" 
	Local lRet := .f.
	
	If  ( RC1->RC1_INTEGR $ "0.2" ) .And. ( Alltrim(FunName()) == "GPEM660" )
		If ( RC1->RC1_CODTIT $ cTitPerm )
			fGPEDelZZG( RC1->RC1_FILTIT + RC1->RC1_PREFIX + RC1->RC1_NUMTIT + RC1->RC1_PARC )
		EndIf
		lRet := .t.
	Else
		If IsInCallStack("FINA050")
			
			cIndexRC1 := SE2->( xFilial("RC1") + E2_FILIAL + E2_PREFIXO + E2_NUM + E2_TIPO + E2_FORNECE)
			
			//Excluo a RC1
			DbSelectArea("RC1")
			RC1->( DbSetOrder(2) )

			If RC1->( DbSeek(cIndexRC1) )
				While 	RC1->(!Eof()) .And.;
						RC1_FILIAL+RC1_FILTIT+RC1_PREFIX+RC1_NUMTIT+RC1_TIPO+RC1_FORNEC == cIndexRC1
					If ( SE2->E2_PARCELA == RC1->RC1_PARC )
						RecLock("RC1", .F.)
						RC1->( DbDelete() )
						RC1->( MsUnLock() )
						If ( RC1->RC1_CODTIT $ cTitPerm )
							fGPEDelSEV( SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_NATUREZ )
							fGPEDelZZG( SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA )
						EndIf
					EndIf
					RC1->(dbSkip())
				EndDo
			EndIf
		Else
			DbSelectArea("SE2")
			SE2->(DbSetorder(1))
			SE2->(DbGoTop())
			If SE2->(DbSeek(RC1->RC1_FILTIT+RC1->RC1_PREFIX+RC1->RC1_NUMTIT+RC1->RC1_PARC+RC1->RC1_TIPO+RC1->RC1_FORNEC+RC1->RC1_LOJA))
				If Empty(SE2->E2_BAIXA)
					RecLock("SE2",.f.)
					SE2->(DbDelete())
					SE2->(MsUnLock())
					If ( RC1->RC1_CODTIT $ cTitPerm )
						fGPEDelSEV( RC1->RC1_FILTIT + RC1->RC1_PREFIX + RC1->RC1_NUMTIT + RC1->RC1_PARC + RC1->RC1_TIPO + RC1->RC1_FORNEC + RC1->RC1_LOJA + RC1->RC1_NATURE)
						fGPEDelZZG( RC1->RC1_FILTIT + RC1->RC1_PREFIX + RC1->RC1_NUMTIT + RC1->RC1_PARC )
					EndIf
					lRet := .t.
				Else
					MsgAlert( OemToAnsi( "O título " +  RC1->RC1_NUMTIT + " nao pode ser excluido pois já foi baixado no Módulo Financeiro"), OemToAnsi("Atencao") ) 
					lRet := .f.
				EndIf
			EndIf
		EndIf
	EndIf

Return( lRet )

Static Function fGPEDelSEV(cChave)

	DbSelectArea("SEV")
	SEV->(DbSetOrder(1))
	SEV->(DbGoTop())
	If ( SEV->(DbSeek(cChave)) )
		DbSelectArea("SEZ")
		SEZ->(DbSetOrder(1))
		SEZ->(DbGoTop())
		If SEZ->(DbSeek(cChave,.f.))
			While 	!Eof() .and.; 
					SEZ->EZ_FILIAL+SEZ->EZ_PREFIXO+SEZ->EZ_NUM+SEZ->EZ_PARCELA+SEZ->EZ_TIPO+SEZ->EZ_CLIFOR+SEZ->EZ_LOJA+SEZ->EZ_NATUREZ == cChave
				//Excluo a SEZ
				RecLock("SEZ",.f.)
				SEZ->(DbDelete())
				SEZ->(MSUnLock())
				DbSelectArea("SEZ")
				SEZ->(DbSkip())
			EndDo
		EndIf
		//Excluo a SEV
		RecLock("SEV",.f.)
		SEV->(DbDelete())
		SEV->(MSUnLock())
	EndIf

Return( Nil )

Static Function fGPEDelZZG(cChave)

	DbSelectArea("ZZG")
	ZZG->(DbSetOrder(1))
	ZZG->(DbGoTop())
	If ZZG->(DbSeek(cChave,.f.))
		While 	!Eof() .and.; 
				ZZG->ZZG_FILIAL + ZZG->ZZG_PREFIX + ZZG->ZZG_NUMTIT + ZZG->ZZG_PARC == cChave
			RecLock("ZZG",.f.)
			ZZG->(DbDelete())
			ZZG->(MSUnLock())
			DbSelectArea("ZZG")
			ZZG->(DbSkip())
		EndDo
	EndIf

Return( Nil )