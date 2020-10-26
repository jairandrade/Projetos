#include "protheus.ch"

/*/{Protheus.doc} F376CanBx
//O ponto de entrada F376CanBx é utilizado para validação após a confirmação do cancelamento da aglutinação de PIS/COFINS/CSLL.
@author Jair Andrade    
@since 21/10/2020
@version version
/*/User Function F376CanBx()
Local lReturn := .T.

If ( Alltrim(SE2->E2_ORIGEM) $ 'FINA376' ) .and. Alltrim(SE2->E2_XCODPGM) <> ""
	dbSelectArea('ZA0')
	ZA0->(dbSetOrder(2))
	If ZA0->(dbSeek(SE2->E2_FILIAL+SE2->E2_NUM+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA))
		While !ZA0->(Eof()) .And. ZA0->ZA0_FILIAL+ZA0->ZA0_NUM+ZA0->ZA0_TIPO+ZA0->ZA0_CLIFOR+ZA0->ZA0_LOJA == SE2->E2_FILIAL+SE2->E2_NUM+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
			If ZA0->ZA0_STATUS $ '1~2'
				RecLock("ZA0",.F.)
				ZA0->ZA0_STATUS:= '9'
				MSUnlock()
				//Notifico por e-mail o cancelamento
				U_TCFIW004(4)
			EndIf
			ZA0->(dbSkip())
		EndDo
	EndIf
EndIf

Return lReturn
