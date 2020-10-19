#include "protheus.ch"

/*/{Protheus.doc} MT114CAB
Permite inserir campos customizados no cabeçalho do grupo de aprovação
@type user function
@version 12.1.25
@author Kaique Mathias
@since 6/9/2020
@return character, _cUsrCpos
/*/

user function MT114CAB()

    Local _cUsrCpos := ""
    
    _cUsrCpos := "AL_XDOCPGM|"

return( _cUsrCpos )