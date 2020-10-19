#include "protheus.ch"

/*/{Protheus.doc} FA050DEL
//O ponto de entrada FA050DEL sera executado apos a confirmação da exclusao. 
@author Kaique Mathias
@since 13/04/2020
@version version
/*/

User Function FA050DEL()

    Local lReturn := .T.
    
    If ( Alltrim(SE2->E2_XORIGEM) == "SP" .And. !IsIncallStack("U_TFIA02CANC") ) 
        Help(" ",1,"NO_DELETE",,"Solicitação de Pagamento",3,1)
        lReturn := .F.
    EndIf

Return( lReturn )