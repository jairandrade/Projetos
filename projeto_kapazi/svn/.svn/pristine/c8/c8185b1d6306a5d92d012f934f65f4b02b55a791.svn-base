#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch" 

#Define ENTER CHR(13)+CHR(10)

User Function KFATR14()
	Local aArea		:= GetArea()
	Local cTitulo	:= "Prazos de Pedidos"
	Local _cAlias	:= "SZE"
	Local cVldAlt	:= ".T."
	Local cVldDel	:= ".T."
	
	DbSelectArea(_cAlias)
	(_cAlias)->( DbSetOrder(1) )

	AxCadastro(_cAlias, cTitulo, cVldDel,cVldAlt ) 
	
	RestArea(aArea)
Return 

// U_KFATR14G() // ZE_TOTAL
User Function KFATR14G()
	Local cCampo:= ReadVar()
	Local nValor:= iif(!Empty(AllTrim(cCampo)),&(cCampo),0) 
	Local nRet 	:= nValor
	
	If Upper(AllTrim(cCampo)) <> "M->ZE_REVISAO"
		nRet += M->ZE_REVISAO
	Endif
	
	If Upper(AllTrim(cCampo)) <> "M->ZE_FINANCE"
		nRet += M->ZE_FINANCE
	Endif
	
	If Upper(AllTrim(cCampo)) <> "M->ZE_PRODUCA"
		nRet += M->ZE_PRODUCA
	Endif
	
	If Upper(AllTrim(cCampo)) <> "M->ZE_SEPARAC"
		nRet += M->ZE_SEPARAC
	Endif
	
	If Upper(AllTrim(cCampo)) <> "M->ZE_EXPEDIC"
		nRet += M->ZE_EXPEDIC
	Endif

return nRet



















