#include "protheus.ch"

/*/{Protheus.doc} F290Can
//O ponto de entrada F290CAN sera utilizado para complementar a gravacao apos cancelamento da fatura.
@author Jair Andrade    
@since 21/10/2020
@version version
/*/User Function F290CAN()
Local lReturn := .T.
//Local cFilNum := ''

If ( Alltrim(SE2->E2_ORIGEM) $ 'FINA290' ) .and. Alltrim(SE2->E2_XCODPGM) <> ""
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

Return lReturn
