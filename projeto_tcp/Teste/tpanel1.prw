#include "TOTVS.CH"
 
User Function TPanel()
 DEFINE DIALOG oDlg TITLE "Exemplo TPanel" FROM 180,180 TO 550,700 PIXEL
  // TFont
  oTFont := TFont():New('Courier new',,16,.T.)
    
  // Usando o método New
  oPanel:= tPanel():New(01,01,"Teste",oDlg,oTFont,.T.,,CLR_YELLOW,,100,100,.T.,.T.)

    
  // Usando o método Create
  oPanel:= tPanel():Create(oDlg,102,01,"Teste",oTFont,.F.,,CLR_YELLOW,,100,100,.T.,.T.)
 ACTIVATE DIALOG oDlg CENTERED
Return
