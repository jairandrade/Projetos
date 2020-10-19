#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} FA260GRSE2
Grava informações adicionais no título conciliado DDA

@author  Leandro Natan Bonette Santos
@since   10/05/2016
@return  nil
	
/*/
//-------------------------------------------------------------------------------
User Function FA260GRSE2()
            
	Local lE2Barra := SE2->(FieldPos("E2_BARRA")) > 0
	
	If lE2Barra
	    SE2->E2_BARRA := TRB->CODBAR
	EndIf
	
Return
    

