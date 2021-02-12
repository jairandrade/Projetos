#Include "PROTHEUS.CH"
//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction
Description

@param xParam Parameter Description
@return xRet Return Description
@author  -
@since 27/10/2015
/*/
//--------------------------------------------------------------
User Function altJur()
Local Juros
Local oButton1
Local oButton2
Local oGet1
Local nGet1 := 0.00
Local oSay1
Static oDlg
if !retcodusr() $ supergertmv("MV_URSALTJ",,'000045|0000107')
	  Alert('Usuario sem acesso para esta rotina!')
	  Return
EndIF  

  DEFINE MSDIALOG oDlg TITLE "Juros" FROM 000, 000  TO 200, 350 COLORS 0, 16777215 PIXEL

    @ 004, 004 GROUP Juros TO 094, 169 PROMPT "Juros" OF oDlg COLOR 0, 16777215 PIXEL
    @ 031, 028 SAY oSay1 PROMPT "Juros ao Mês" SIZE 041, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 029, 066 MSGET oGet1 VAR nGet1 SIZE 060, 010 OF oDlg PICTURE "@E 999.99" COLORS 0, 16777215 PIXEL
    @ 070, 039 BUTTON oButton1 PROMPT "Alterar" action altJuros(oDlg,nGet1) SIZE 037, 012 OF oDlg PIXEL
    @ 071, 086 BUTTON oButton2 PROMPT "Sair"    action oDlg:end()   SIZE 037, 012 OF oDlg PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

Return                                                 


Static Function altJuros(oDlg,nGet1)

nJurDia:=(nGet1/30) 
FOR NI:=1 TO 6
	cUpd:= " update SA1"+STRZERO(NI,2)+"0"
	cUpd+= " SET A1_PORCJUR = "+cvaltochar(ROUND(nJurDia,4))+" "
	cUpd+= " WHERE D_E_L_E_T_<>'*'"
	TCSqlExec(cUpd)
	
	
	cUpd:= " update SE1"+STRZERO(NI,2)+"0"
	cUpd+= " SET E1_PORCJUR = "+cValtochar(ROUND(nJurDia,4))+""
	cUpd+= " WHERE D_E_L_E_T_<>'*'"
	cUpd+= " AND E1_BAIXA=''"
	TCSqlExec(cUpd)         
NEXT
	



oDlg:end() 
Return

