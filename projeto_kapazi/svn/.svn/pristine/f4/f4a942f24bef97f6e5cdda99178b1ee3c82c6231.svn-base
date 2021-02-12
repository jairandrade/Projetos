#include 'protheus.ch'
#include 'parmtype.ch'

User Function KAPPOSCL()

//__Execute('Finc010()','xxxxxxxxxx','Teste','06',,,.T.) -> OK
Finc010()

Return()


Static Function zIsMDI()
Local aArea := GetArea()
Local lRet  := .F.
 
    //Se tiver instanciado no objeto oApp
If Type("oApp") == "O"
    lRet := oApp:lMDI
EndIf
 
RestArea(aArea)
Return lRet