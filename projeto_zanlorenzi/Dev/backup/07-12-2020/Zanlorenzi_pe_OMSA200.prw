#include "protheus.ch"

/*/{Protheus.doc} OM200MNU
//Ponto de entrada disparado antes da abertura do Browse, caso Browse inicial da rotina esteja habilitado, 
ou antes da apresentação do Menu de opções, caso Browse inicial esteja desabilitado.
@author Jair Andrade    
@since 03/12/2020
@version version
/*/
User Function OM200MNU
/*
Ponto de entrada disparado antes da abertura do Browse, caso Browse inicial da rotina esteja habilitado, ou antes da apresentação do Menu de opções, caso Browse inicial esteja desabilitado.
*/  
AAdd( aRotina, { 'EDI Transportadoras', 'U_OMS100', 0, 4 } )
AAdd( aRotina, { 'Cancelar EDI', 'U_OMS100C', 0, 4 } )
Return Nil
