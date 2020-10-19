#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"
#include "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User FUNCTION RACOMPENSACAO()
	
Local cAlias       := getNextAlias()
Local cAliasUpdate := getNextAlias()
Private nRecnoRA
Private nRecnoE1

BeginSql Alias cAlias

	SELECT 
		ZRA.ZRA_DTCOMP,ZRA.ZRA_NRA,ZRA.ZRA_SE1 
	FROM 
		%table:ZRA% ZRA 
	WHERE
		 ZRA.ZRA_DTCOMP = ' ' AND D_E_L_E_T_ <> '*'		
EndSql 


(cALias)->(dbGoTop()) 
    
PERGUNTE("AFI340",.F.)

while !(cAlias)->(EOF())  

	lContabiliza  := MV_PAR11 == 1
	lAglutina     := MV_PAR08 == 1
	lDigita       := MV_PAR09 == 1                   
	
	nRecRA  := (cAlias)->ZRA_NRA
	nRecSE1 := (cAlias)->ZRA_SE1
    
	aRecRA  := {nRecRA}
	aRecSE1 := {nRecSE1}
	
	If !MaIntBxCR(3,aRecSE1,,aRecRA,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,,dDatabase )
		
		alert("Deu erro na ID RA"+CvalToChar(ZRA_NRA))
		
	endif 
		
	(cAlias)->(Dbskip())
	    
enddo

	(cAlias)->(dbCloseArea())
	
	alert("Processo finalizado!")
	
Return

	