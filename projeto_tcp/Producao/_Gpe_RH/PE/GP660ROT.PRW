#INCLUDE 'PROTHEUS.CH'  

User Function GP660ROT()

Local aArea  := GetArea()
Local aRotAux  := ParamixB[1]

aAdd(aRotAux, { "Rateio","U_BrwZZG", 0 , 5, ,.F.})

RestArea(aArea)

Return (aRotAux)    

User Function BrwZZG()    

Private aRotina     := {{"Pesquisar" , "AxPesqui"         , 0, 1 }}       

dbSelectArea("ZZG")
dbSetOrder(1)      
Set Filter to ZZG->ZZG_FILIAL+ZZG->ZZG_PREFIX+ZZG->ZZG_NUMTIT+ZZG->ZZG_PARC==RC1->RC1_FILTIT+RC1->RC1_PREFIX+RC1->RC1_NUMTIT+RC1->RC1_PARC
DbGoTop()
mBrowse(,,,,"ZZG")

Set Filter to
DbGoTop() 

Return
