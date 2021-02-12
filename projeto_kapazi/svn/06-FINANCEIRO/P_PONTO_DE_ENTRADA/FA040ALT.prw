#include 'protheus.ch'
#include 'parmtype.ch'
/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Financeiro                                                                                                                             |
| Liberação para alteração dos vencimentos                                                                                               |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 28/10/2019                                                                                                                       |
| Descricao: Senha para liberar a alteração do vencimento dos titulos no contas a receber                                                |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/
User Function FA040ALT()

Local oButton1
Local oButton2
Local oSay1
Private lRet := .T.
Private cCodLib := "       "

If (SE1->E1_VENCTO <> M->E1_VENCTO) .OR. (SE1->E1_VENCREA <> M->E1_VENCREA)
	lRet := .F.
Else
	Return(lRet)
EndIf

If !lRet
	DEFINE MSDIALOG oDlg1 FROM  96,42 TO 323,415  TITLE "Alteração de Vencimento" PIXEL
	@ 20,14 SAY "Alterações de vencimentos devem ser confirmados pelo superior."    SIZE 200,08 PIXEL
	@ 53,14 SAY "Senha para liberar:" PIXEL
	@ 53,70 GET cCodLib SIZE 40,08 Password PIXEL
	@ 86,100 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF oDlg1 PIXEL ACTION OkProc()
	@ 86,145 BUTTON oButton2 PROMPT "Sair" SIZE 037, 012 OF oDlg1 PIXEL ACTION oDlg1:End()
	ACTIVATE DIALOG oDlg1 CENTERED
EndIf
Return(lRet)

Static Function OkProc()
Processa({|| Grava()})
Return nil


Static Function Grava()
If cCodLib == "19@@kap"
	lRet := .T.
EndIf
oDlg1:End()
	
Return(lRet)
