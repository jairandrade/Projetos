

User Function veCGCcn()
cCgc:=SM0->M0_CGC
CCHAVE:=SM0->M0_CODIGO+SM0->M0_CODFIL
CEMPT:=SM0->M0_CODIGO
IF  SM0->M0_CODFIL == '01'
	   RETURN cCgc
EndIF
 	
 	DBSelectArea('SM0')
 	DBGOTOP()
 	DBsEEK(CEMPT)
 	while !SM0->(EOF()) .and. CEMPT==SM0->M0_CODIGO
 		IF  SM0->M0_CODFIL == '01'
	  	  cCgc:=SM0->M0_CGC
 		EndIF  
 		SM0->(DBSKIP())
 	EndDo
	DBSelectArea('SM0')
 	DBGOTOP()
 	DBsEEK(CCHAVE)



return cCgc