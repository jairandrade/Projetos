#include 'totvs.ch'
 
User function tPanel1()
Local oDlg    
Local oPanel1,oPanel2,oPanel3,oPanel4
     
DEFINE DIALOG oDlg TITLE "Exemplo de TABS" FROM 0,0 TO 300,400 PIXEL
 
@ 10,15 MSPANEL oPanel1 COLORS CLR_BLACK,CLR_HGRAY SIZE 100, 20 OF oDlg
@ 7,10 SAY "Texto Exemplo 1" OF oPanel1 PIXEL
        
@ 40,15 MSPANEL oPanel2 COLORS CLR_BLACK,CLR_HGRAY SIZE 100, 20 OF oDlg RAISED
@ 7,10 SAY "Texto Exemplo 2" OF oPanel2 PIXEL
 
@ 70,15 MSPANEL oPanel3 COLORS CLR_BLACK,CLR_HGRAY SIZE 100, 20 OF oDlg LOWERED
@ 7,10 SAY "Texto Exemplo 3" OF oPanel3 PIXEL
 
@ 100,15 MSPANEL oPanel4 COLORS CLR_BLACK,CLR_HGRAY PROMPT "Painel 4" SIZE 100, 20 OF oDlg
 
ACTIVATE DIALOG oDlg CENTER
 
Return
