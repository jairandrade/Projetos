User Function MPON080
Local cQuery := ""


PONM080()

cQuery := " SELECT * FROM "+RetSqlName('SPB')
cQuery += " WHERE "
cQuery += " 	PB_FILIAL = '"+xFilial('SPB')+"' AND PB_PD = '297' AND PB_HORAS <= 20 AND PB_DATA >= '"+DtoS(dDataBase-150)+"' AND D_E_L_E_T_ != '*'"

cQuery := ChangeQuery( cQuery)

If (Select("TMPRH") <> 0)
	DbSelectArea("TMPRH")
	TMPRH->(DbCloseArea())
 Endif
			                                                                       	
DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "TMPRH",.T., .F.)
				
DbSelectArea("TMPRH")
TMPRH->(DbGoTop())
WHILE !TMPRH->(eof())
	cQuery := " SELECT * FROM "+RetSqlName('SPB')
	cQuery += " WHERE "
	cQuery += " 	PB_FILIAL = '"+xFilial('SPB')+"' AND PB_MAT = '"+TMPRH->PB_MAT+"' AND  PB_PD = '499' AND PB_DATA >= '"+DtoS(dDataBase-150)+"' AND D_E_L_E_T_ != '*'"
	
	cQuery := ChangeQuery( cQuery)
	
	If (Select("TMPDEV") <> 0)
		DbSelectArea("TMPDEV")
		TMPDEV->(DbCloseArea())
	 Endif           
	 DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "TMPDEV",.T., .F.)
				
	DbSelectArea("TMPDEV")
	TMPDEV->(DbGoTop())           
	nDev 	:= 0     
	nRecDev := 0
	IF !TMPDEV->(eof())
		nDev	:= TMPDEV->PB_HORAS 
		nRecDev := TMPDEV->R_E_C_N_O_
	EndIf                      
	TMPDEV->(DbCloseArea())

	If nDev > TMPRH->PB_HORAS//se tiver volume maior de horas engativas
		DbSelectArea('SPB')
		SPB->(DbSetOrder(1))
		SPB->(DbGoTop())            
		SPB->(DbGoTo(TMPRH->R_E_C_N_O_))		
		recLock('SPB',.F.)
		SPB->(DbDelete())
		SPB->(MsUnlock())
			
		SPB->(DbSetOrder(1))
		SPB->(DbGoTop())            
		SPB->(DbGoTo(nRecDev))
		recLock('SPB',.F.)
		SPB->PB_HORAS := SPB->PB_HORAS - TMPRH->PB_HORAS
		SPB->(MsUnlock())	
	ElseIf	nDev < TMPRH->PB_HORAS .AND. nDev > 0//se tiver volume maior de horas engativas
		DbSelectArea('SPB')
		SPB->(DbSetOrder(1))
		SPB->(DbGoTop())            
		SPB->(DbGoTo(TMPRH->R_E_C_N_O_))				
		recLock('SPB',.F.)
		SPB->PB_HORAS 	:= SPB->PB_HORAS-nDev
		SPB->(MsUnlock())
			
		SPB->(DbSetOrder(1))
		SPB->(DbGoTop())            
		SPB->(DbGoTo(nRecDev))
		recLock('SPB',.F.)
		SPB->(DbDelete())
		SPB->(MsUnlock())	
	ElseIf TMPRH->PB_HORAS == nDev//se for igual                                                                               	
		DbSelectArea('SPB')
		SPB->(DbSetOrder(1))
		SPB->(DbGoTop())            
		SPB->(DbGoTo(TMPRH->R_E_C_N_O_))		
		recLock('SPB',.F.)
		SPB->(DbDelete())
		SPB->(MsUnlock())
		
		If nRecDev > 0		
			SPB->(DbSetOrder(1))
			SPB->(DbGoTop())            
			SPB->(DbGoTo(nRecDev))
			recLock('SPB',.F.)
			SPB->(DbDelete())
			SPB->(MsUnlock())							
		EndIf
	EndIf	
	TMPRH->(DbSkip())
EndDo 
TMPRH->(DbCloseArea())


cQuery := " SELECT * FROM "+RetSqlName('SPB')
cQuery += " WHERE "
cQuery += " 	PB_FILIAL = '"+xFilial('SPB')+"' AND PB_PD = '297' AND PB_HORAS > 20 AND PB_DATA >= '"+DtoS(dDataBase-150)+"' AND D_E_L_E_T_ != '*'"

cQuery := ChangeQuery( cQuery)

If (Select("TMPRH") <> 0)
	DbSelectArea("TMPRH")
	TMPRH->(DbCloseArea())
 Endif
			                                                                       	
DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "TMPRH",.T., .F.)
				
DbSelectArea("TMPRH")
TMPRH->(DbGoTop())
WHILE !TMPRH->(eof())
	cQuery := " SELECT * FROM "+RetSqlName('SPB')
	cQuery += " WHERE "
	cQuery += " 	PB_FILIAL = '"+xFilial('SPB')+"' AND PB_MAT = '"+TMPRH->PB_MAT+"' AND  PB_PD = '499' AND PB_DATA >= '"+DtoS(dDataBase-150)+"' AND D_E_L_E_T_ != '*'"
	
	cQuery := ChangeQuery( cQuery)
	
	If (Select("TMPDEV") <> 0)
		DbSelectArea("TMPDEV")
		TMPDEV->(DbCloseArea())
	 Endif           
	 DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "TMPDEV",.T., .F.)
				
	DbSelectArea("TMPDEV")
	TMPDEV->(DbGoTop())           
	nDev 	:= 0     
	nRecDev := 0
	IF !TMPDEV->(eof())
		nDev	:= TMPDEV->PB_HORAS 
		nRecDev := TMPDEV->R_E_C_N_O_
	EndIf                      
	TMPDEV->(DbCloseArea())

	If TMPRH->PB_HORAS-nDev > 20
		nAux := TMPRH->PB_HORAS - 20 - nDev
		If nAux > 20                  		
			RecLock('SPB',.T.)
			SPB->PB_FILIAL 	:= TMPRH->PB_FILIAL
			SPB->PB_MAT 	:= TMPRH->PB_MAT
			SPB->PB_PD 		:= "299"
			SPB->PB_TIPO1 	:= TMPRH->PB_TIPO1
			SPB->PB_HORAS 	:= nAux-20
			SPB->PB_VALOR 	:= 0
			SPB->PB_DATA 	:= Stod(TMPRH->PB_DATA)
			SPB->PB_SEMANA 	:= TMPRH->PB_SEMANA
			SPB->PB_CC 		:= TMPRH->PB_CC
			SPB->PB_PARCELA := TMPRH->PB_PARCELA
			SPB->PB_TIPO2 	:= TMPRH->PB_TIPO2
			SPB->PB_PROCES 	:= TMPRH->PB_PROCES
			SPB->PB_ROTEIR 	:= TMPRH->PB_ROTEIR
			SPB->PB_PERIODO := TMPRH->PB_PERIODO
			SPB->PB_DEPTO 	:= TMPRH->PB_DEPTO
			SPB->PB_POSTO 	:= TMPRH->PB_POSTO
			SPB->PB_CODFUNC := TMPRH->PB_CODFUNC
			SPB->PB_D1 		:= TMPRH->PB_D1
			SPB->PB_D2 		:= TMPRH->PB_D2
			SPB->PB_D3 		:= TMPRH->PB_D3
			SPB->PB_D4 		:= TMPRH->PB_D4		
			SPB->PB_D5 		:= TMPRH->PB_D5 		
			SPB->PB_D6 		:= TMPRH->PB_D6 		
			SPB->PB_D7 		:= TMPRH->PB_D7 		
			SPB->PB_INTEGRA := TMPRH->PB_INTEGRA
			SPB->(MsUnlock())
			nAux := 20
		EndIf
		RecLock('SPB',.T.)
		SPB->PB_FILIAL 	:= TMPRH->PB_FILIAL
		SPB->PB_MAT 	:= TMPRH->PB_MAT
		SPB->PB_PD 		:= "298"
		SPB->PB_TIPO1 	:= TMPRH->PB_TIPO1
		SPB->PB_HORAS 	:= nAux
		SPB->PB_VALOR 	:= 0
		SPB->PB_DATA 	:= StoD(TMPRH->PB_DATA)
		SPB->PB_SEMANA 	:= TMPRH->PB_SEMANA
		SPB->PB_CC 		:= TMPRH->PB_CC
		SPB->PB_PARCELA := TMPRH->PB_PARCELA
		SPB->PB_TIPO2 	:= TMPRH->PB_TIPO2
		SPB->PB_PROCES 	:= TMPRH->PB_PROCES
		SPB->PB_ROTEIR 	:= TMPRH->PB_ROTEIR
		SPB->PB_PERIODO := TMPRH->PB_PERIODO
		SPB->PB_DEPTO 	:= TMPRH->PB_DEPTO
		SPB->PB_POSTO 	:= TMPRH->PB_POSTO
		SPB->PB_CODFUNC := TMPRH->PB_CODFUNC
		SPB->PB_D1 		:= TMPRH->PB_D1
		SPB->PB_D2 		:= TMPRH->PB_D2
		SPB->PB_D3 		:= TMPRH->PB_D3
		SPB->PB_D4 		:= TMPRH->PB_D4		
		SPB->PB_D5 		:= TMPRH->PB_D5 		
		SPB->PB_D6 		:= TMPRH->PB_D6 		
		SPB->PB_D7 		:= TMPRH->PB_D7 		
		SPB->PB_INTEGRA := TMPRH->PB_INTEGRA
		SPB->(MsUnlock())
		
		DbSelectArea('SPB')
		SPB->(DbSetOrder(1))
		SPB->(DbGoTop())            
		SPB->(DbGoTo(TMPRH->R_E_C_N_O_))
		
		If nDev > SPB->PB_HORAS//se tiver volume maior de horas engativas
			recLock('SPB',.F.)
			SPB->(DbDelete())
			SPB->(MsUnlock())
				
			SPB->(DbSetOrder(1))
			SPB->(DbGoTop())            
			SPB->(DbGoTo(nRecDev))
			recLock('SPB',.F.)
			SPB->PB_HORAS := SPB->PB_HORAS - TMPRH->PB_HORAS
			SPB->(MsUnlock())			
		Else			
			recLock('SPB',.F.)
			SPB->PB_HORAS 	:= 20
			SPB->(MsUnlock())
			If nRecDev > 0				
				SPB->(DbSetOrder(1))
				SPB->(DbGoTop())            
				SPB->(DbGoTo(nRecDev))
				recLock('SPB',.F.)
				SPB->(DbDelete())
				SPB->(MsUnlock())	
			EndIf		
		EndIf
	Else
		If nDev > TMPRH->PB_HORAS//se tiver volume maior de horas engativas
			DbSelectArea('SPB')
			SPB->(DbSetOrder(1))
			SPB->(DbGoTop())            
			SPB->(DbGoTo(TMPRH->R_E_C_N_O_))		
			recLock('SPB',.F.)
			SPB->(DbDelete())
			SPB->(MsUnlock())
				
			SPB->(DbSetOrder(1))
			SPB->(DbGoTop())            
			SPB->(DbGoTo(nRecDev))
			recLock('SPB',.F.)
			SPB->PB_HORAS := SPB->PB_HORAS - TMPRH->PB_HORAS
			SPB->(MsUnlock())	
		ElseIf	nDev < TMPRH->PB_HORAS .AND. nDev > 0//se tiver volume maior de horas engativas
			DbSelectArea('SPB')
			SPB->(DbSetOrder(1))
			SPB->(DbGoTop())            
			SPB->(DbGoTo(TMPRH->R_E_C_N_O_))				
			recLock('SPB',.F.)
			SPB->PB_HORAS 	:= SPB->PB_HORAS-nDev
			SPB->(MsUnlock())
				
			SPB->(DbSetOrder(1))
			SPB->(DbGoTop())            
			SPB->(DbGoTo(nRecDev))
			recLock('SPB',.F.)
			SPB->(DbDelete())
			SPB->(MsUnlock())	
		Else//se for igual 
			DbSelectArea('SPB')
			SPB->(DbSetOrder(1))
			SPB->(DbGoTop())            
			SPB->(DbGoTo(TMPRH->R_E_C_N_O_))		
			recLock('SPB',.F.)
			SPB->(DbDelete())
			SPB->(MsUnlock())
			
			If nRecDev > 0		
				SPB->(DbSetOrder(1))
				SPB->(DbGoTop())            
				SPB->(DbGoTo(nRecDev))
				recLock('SPB',.F.)
				SPB->(DbDelete())
				SPB->(MsUnlock())							
			EndIf
		EndIf	
	EndIf
	TMPRH->(DbSkip())
EndDo 


TMPRH->(DbCloseArea())	


Return
