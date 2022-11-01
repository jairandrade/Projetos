User Function fImpEnder()

 DEFINE MSDIALOG oDlg TITLE "[AFAT319] - Imprime enderecamento" FROM 000, 000  TO 550, 500 COLORS 0, 16777215 PIXEL

    @ 011, 004 SAY oSay1 PROMPT "Nro Contrato:"   SIZE 094, 014 OF oDlg FONT oFont1           COLORS 0, 16777215 PIXEL
    @ 011, 102 MSGET oGet1 VAR _cNumCon           SIZE 104, 019 OF oDlg F3 "ZZ2Z30" VALID U_AFT319VL(@_cNumCon) /*(Posicione("Z00",1,xFilial("Z31")+_cNumCon,"Z00_CLIENT"))*/ COLORS 0, 16777215 FONT oFont1 PIXEL
    
    @ 036, 014 SAY oSay4 PROMPT "Local de Uso:"   SIZE 083, 014 OF oDlg FONT oFont1           COLORS 0, 16777215 PIXEL
    @ 036, 102 MSGET oGet4 VAR cCodUso            SIZE 104, 019 OF oDlg F3 "SZ3Z30" VALID U_AFT319VL(@_cNumCon,@cCodUso) COLORS 0, 16777215 FONT oFont1 PIXEL
    
    @ 061, 017 SAY oSay2 PROMPT "Selo Entrega:"   SIZE 084, 014 OF oDlg FONT oFont1           COLORS 0, 16777215 PIXEL
    @ 061, 102 MSGET oGet2 VAR cEtqSub            SIZE 104, 019 OF oDlg VALID U_AFT319VE(@cEtqSub,"S",,,nOpc) COLORS 0, 16777215 FONT oFont1 PIXEL
    
    @ 086, 012 SAY oSay3 PROMPT "Nro.Chamado:"    SIZE 083, 014 OF oDlg FONT oFont1           COLORS 0, 16777215 PIXEL
    @ 086, 102 MSGET oGet3 VAR cChamado           SIZE 104, 019 OF oDlg /* VALID U_AFT319VC(@cChamado) */    COLORS 0, 16777215 FONT oFont1 PIXEL

    @ 111, 055 SAY oSay12 PROMPT "Data:"          SIZE 038, 016 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
    @ 111, 101 MSGET oGet5 VAR dDataInc           SIZE 104, 019 OF oDlg VALID VldUser(@dDataInc) COLORS 0, 16777215 FONT oFont1 PIXEL  
      
    @ 136, 060 BUTTON oButton1 PROMPT "Entregar"   ACTION ( _cOpc := 1,oDlg:end() ) SIZE 066, 021 OF oDlg FONT oFont1 PIXEL
    @ 136, 151 BUTTON oButton2 PROMPT "Cancelar"   ACTION oDlg:end() SIZE 062, 021 OF oDlg FONT oFont1 PIXEL
      
    @ 161, 001 GROUP oGroup1 TO 201, 244 PROMPT "Selo Entrega" OF oDlg COLOR 0, 16777215 PIXEL
    @ 171, 007 SAY oSay5 PROMPT "Produto: "   +_cProduto    SIZE 222, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 181, 007 SAY oSay6 PROMPT "Descricao: " +_cProdDesc   SIZE 222, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 191, 007 SAY oSay7 PROMPT "Modelo: "   + _cCodItem    SIZE 222, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    
    @ 218, 002 GROUP oGroup2 TO 257, 244 PROMPT "Dados Contrato" OF oDlg COLOR 0, 16777215 PIXEL
    @ 228, 004 SAY oSay8 PROMPT  "Contrato: " + _cContrat  SIZE 222, 007 OF oGroup2 COLORS 0, 16777215 PIXEL
   // @ 238, 004 SAY oSay9 PROMPT "Anexo: " + _cAnx         SIZE 222, 007 OF oGroup2 COLORS 0, 16777215 PIXEL
   // @ 248, 004 SAY oSay10 PROMPT "Data: " + _cData        SIZE 222, 007 OF oGroup2 COLORS 0, 16777215 PIXEL
    @ 238, 004 SAY oSay11 PROMPT "Locl.Uso: " + _cLocalU   SIZE 222, 007 OF oGroup2 COLORS 0, 16777215 PIXEL


  ACTIVATE MSDIALOG oDlg CENTERED

	//---- ----
	If _cOpc == 1
		
		If Empty(cEtqSub)
			_lRet := .F.
			_cMsg := "Selo de entrega obrigatório."
		EndIf
		
		If !_lRet
			_lRet := U_AFT319VL(_cNumCon)
		EndIf

		If !_lRet
 			_lRet := U_AFT319VL(_cNumCon,cCodUso)
		EndIf
		
		If !_lRet
			_lRet := U_AFT319VC(cChamado)
 		EndIf
 		
		If !_lRet
			U_AFT319LO("Z30", "", _cMsg) //--- Gera Log com as mensagens de validação ---
			ABXBiblioteca():Avisar('[AFT319VL] Validação',_cMsg)				
			Return .F.
		Else
			U_AFT319PS(cAlias, nReg, nOpc)			
		EndIf		
		
	EndIf
	//---- ----

Return
