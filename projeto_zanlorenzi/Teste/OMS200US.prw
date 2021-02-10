#include "protheus.ch"
User Function Teste()
Local cTitulo
Local cDescri
Local cCombo
dbSelectArea(“SX3”)
dbSetOrder(2)
If dbSeek( cCampo )  
 cTitulo := X3Titulo()  
  cDescri := X3Descri()   
  cCombo  := X3Cbox()
EndIf Return
