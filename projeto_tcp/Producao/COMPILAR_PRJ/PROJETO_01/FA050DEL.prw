#include "protheus.ch"

/*/{Protheus.doc} FA050DEL
//O ponto de entrada FA050DEL sera executado apos a confirmação da exclusao. 
@author Kaique Mathias
@since 13/04/2020
@version version
/*/

User Function FA050DEL()

	Local lReturn := .T.
	//Local cFilNum := ''

	//If ( Alltrim(SE2->E2_XORIGEM) == "SP" .And. !IsIncallStack("U_TFIA02CANC") )
	If ( Alltrim(SE2->E2_XORIGEM) == "SP" .And. .Not.( Alltrim(SE2->E2_ORIGEM) $ 'FINA376/FINA378/FINA290/FINA870' ) .And. !IsIncallStack("U_TFIA02CANC") )
		Help(" ",1,"NO_DELETE",,"Solicitação de Pagamento",3,1)
		lReturn := .F.
	EndIf

	//jair 21-10-2020 - so passa pela rotina FINA870
	If lReturn
		If ( Alltrim(SE2->E2_ORIGEM) $ 'FINA376/FINA378/FINA290/FINA870' ) .and. Alltrim(SE2->E2_XCODPGM) <> ""
			dbSelectArea('ZA0')
			ZA0->(dbSetOrder(2))
			If ZA0->(dbSeek(SE2->E2_FILIAL+SE2->E2_NUM+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA))
				//cFilNum :=ZA0->ZA0_FILIAL+ZA0->ZA0_NUM+ZA0->ZA0_TIPO+ZA0->ZA0_CLIFOR+ZA0->ZA0_LOJA
				//	While !ZA0->(Eof()) .And. ZA0->ZA0_FILIAL+ZA0->ZA0_NUM+ZA0->ZA0_TIPO+ZA0->ZA0_CLIFOR+ZA0->ZA0_LOJA == SE2->E2_FILIAL+SE2->E2_NUM+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
				RecLock("ZA0",.F.)
				ZA0->ZA0_STATUS:= '9'
				MSUnlock()
				//ZA0->(dbSkip())
				//EndDo
				//Posiciono na ZA0
				//ZA0->(dbSeek(cFilNum))
				//Notifico por e-mail o cancelamento
				U_TCFIW004(4)
			EndIf
		EndIf
	EndIF

Return( lReturn )
