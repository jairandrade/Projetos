#include "protheus.ch"

/*/{Protheus.doc} MTALCPER
O ponto de entrada MTALCPER permite utilizar o controle de alçadas de 
forma customizada em documentos que não controlam alçada por padrão. 
@type  Function
@author Kaique Mathias
@since 31/03/2020
/*/

user function MTALCPER()

    Local aAlc := {}
    
    // Validações do usuário
    If ( SCR->CR_TIPO == 'AP' )
        aAdd( aAlc ,{ SCR->CR_TIPO, 'ZA0', 1, 'ZA0->ZA0_CODIGO','','',{'ZA0->ZA0_STATUS',"1","2","3"}})
    EndIf

return( aAlc )