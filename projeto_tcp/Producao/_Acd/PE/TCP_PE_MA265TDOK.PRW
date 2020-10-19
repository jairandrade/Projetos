#include 'totvs.ch'
User Function MA265TDOK()
Local lExecuta := .T.
Local nPosNS	:= GdFieldPos('DB_NUMSERI') 
Local nI

	For nI := 1 to Len(aCols)
		If Posicione('SB1',1,xFilial('SB1')+M->DA_PRODUTO,"B1_XNUMSER") == '1' .AND. Empty(alltrim(aCols[nI][nPosNS]))
			Alert('O produto '+Alltrim(M->DA_PRODUTO)+' deve ter seu numero de série informado!')
			lExecuta := .F.
		EndIf
	Next

Return (lExecuta)