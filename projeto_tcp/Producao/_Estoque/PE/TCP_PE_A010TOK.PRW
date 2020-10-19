User function A010TOK()
Local lExecuta := .T.

Local cGrpPrd   := GetMV("TCP_GRPINF") 
Local cLoclTi   := GetMV("TCP_LOCINF") 
Local cGrpti    := GetMV("TCP_GRPTI") 
Local cTpOper   := GetMV("TCP_TPINF") 
Local aCpMdtOb	:= {"B1_XGENER","B1_XDIAUTI","B1_XDEVOLV","B1_XTPEPI"}
Local nX

IF (M->B1_GRUPO $ cGrpPrd)

	IF M->B1_RASTRO != 'L'
		Help("",1,"TCPPRDRASTRO",,'Produtos de informática devem obrigatóriamente controlar rastreabilidade. B1_RASTRO=L',4,1,NIL, NIL, NIL, NIL, NIL, {"Altere o campo Rastro."})
		lExecuta := .F.
	ENDIF
	
	IF M->B1_LOCPAD != cLoclTi
		Help("",1,"TCPPRDLOCAL",,'Produtos de informática devem obrigatóriamente ter o armazém: '+cLoclTi,4,1,NIL, NIL, NIL, NIL, NIL, {"Altere o campo Local Padrão."})
		lExecuta := .F.
	ENDIF
	
	IF M->B1_GRPTI != cGrpti
		Help("",1,"TCPPRDGRP",,'Produtos de informática devem obrigatóriamente ter o Grupo Ti: '+cGrpti,4,1,NIL, NIL, NIL, NIL, NIL, {"Altere o campo Grupo - TI."})
		lExecuta := .F.
	ENDIF
	
	IF !EMPTY(M->B1_TE) .AND. M->B1_TE != POSICIONE('SFM',1,xFilial('SFM')+cTpOper,'FM_TE')     
		Help("",1,"TCPPRDTES",,'TES de entrada inválida para produtos de informática',4,1,NIL, NIL, NIL, NIL, NIL, {"Altere a TES de Entrada para "+SFM->FM_TE})
		lExecuta := .F.
	ENDIF

ENDIF

/** 
Kaique Mathias - 28/10/2019
Em atendimento ao email enviado por suellen, deverá validar 
se o tipo de produto for ES obrigar preenchimento de campos
B1_XGENER, B1_XDIAUTI, B1_XDEVOLV, B1_XTPEPI, B1_XDIAMAN
*/
If ( M->B1_TIPO == 'ES' ) .And. lExecuta
	_bValid := { || If(GetSX3Cache(aCpMdtOb[nX],'X3_TIPO') == "C",Empty(&("M->"+aCpMdtOb[nX])),&("M->"+aCpMdtOb[nX])==0)}
	For nX := 1 to len(aCpMdtOb)
		If  Eval(_bValid)
			Help("",1,"TCPOBRIGAT",,'Existem campos obrigatorios não preenchidos.',4,1,NIL, NIL, NIL, NIL, NIL, {"Verifique o preenchimento do campo " + Alltrim(GetSX3Cache(aCpMdtOb[nX],'X3_TITULO')) + " na ultima pasta." })
			lExecuta := .F.
			Exit
		EndIf 
	Next nX
EndIf

return lExecuta