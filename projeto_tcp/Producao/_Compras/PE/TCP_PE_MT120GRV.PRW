#include 'protheus.ch'

User Function MT120GRV 
Local lRet := .T.
Local lAux := ParamIxb[2]

	If lAux .AND. Posicione('SA2',1,xFilial('SA2')+cA120FORN,"A2_NOTAFOR") == 'C'
		Alert('Este fornecedor está bloqueado por classificação C')
		lRet := .F.
	EndIf

Return lRet