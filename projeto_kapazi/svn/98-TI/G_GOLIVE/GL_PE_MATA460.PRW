// ---------------------------------------------------
// INTREGRACAOO MADEIRAMADEIRA -- GOlive            
// ---------------------------------------------------
User Function M460MARK()
	If ExistBlock("M050205")
		If !Empty(ThisMark()) 
			lRet := U_M050205(SC9->C9_FILIAL,SC9->C9_PEDIDO) 
		EndIf
	EndIf
Return(lRet)