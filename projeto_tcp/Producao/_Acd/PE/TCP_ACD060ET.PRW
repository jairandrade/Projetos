#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

User Function ACD060F3()
Public cPrdColTCP := ''

Return           


user function AIC060VPR()
Local lRet := .T.
Local cProd := PARAMIXB[1]

	If !Empty(Alltrim(cPrdColTCP)) .AND. cPrdColTCP != cProd
   		VtAlert('Para trocar de produto você deve endereçar o anterior!','Produto')					
   		Return .F.
	EndIf
	cPrdColTCP := cProd

Return lRet


user function ACD060VE ()

	cPrdColTCP := ''

Return .T.


                         
