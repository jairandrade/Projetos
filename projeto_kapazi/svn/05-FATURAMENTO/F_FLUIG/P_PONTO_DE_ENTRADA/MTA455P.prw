#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MTA455P
//TODO Liberacao de estoque manual.
@since 13/04/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function MTA455P()// MANUAL
	Local lRet 	:= .T.
	Local nOpc	:= PARAMIXB[1] // 1 = OK - 2 =  CANCELA
	Local aArea	:= GetArea()

	If Alltrim(cEmpAnt) == "04"  
		
		//Clicou em OK
		If nOpc == 2 
			U_KPLibEst(SC5->C5_NUM)
		Endif
	EndIf
	
	Restarea(aArea)
Return(lRet)