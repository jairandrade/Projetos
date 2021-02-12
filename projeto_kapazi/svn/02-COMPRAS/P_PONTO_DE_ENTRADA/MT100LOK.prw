#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "topconn.ch"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Compras                                                                                                                                |
| Validação para a linha/item do documento de entrada                                                                                    |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 18/02/2020                                                                                                                       |
| Descricao: Obrigar o preenchimento do centro de custo no documento de entrada                                                          |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function MT100LOK

Local cCtCus   := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_CC"})
Local cCtRat   := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_RATEIO"})
Local lRet     := .T.

If Type('l103Auto') == "U"
	lVai := .F.
Else
	lVai := l103Auto
EndIf

//If cTipo <> "B" .and. !lVai
If !(cTipo $ "B|D") .and. !lVai
	If Empty(Acols[n][cCtCus]) .and. (Acols[n][cCtRat]) != "1"
		MsgInfo("Para continuar é necessário preencher o Centro de Custo","Atenção - MT100LOK")
		lRet  := .F.
	EndIf
Endif

Return(lRet)