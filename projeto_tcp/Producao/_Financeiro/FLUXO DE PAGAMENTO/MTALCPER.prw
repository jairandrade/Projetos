#include "protheus.ch"

/*/{Protheus.doc} MTALCPER
O ponto de entrada MTALCPER permite utilizar o controle de al�adas de 
forma customizada em documentos que n�o controlam al�ada por padr�o. 
@type  Function
@author Kaique Mathias
@since 31/03/2020
/*/

user function MTALCPER()

    Local aAlc := {}
    
    // Valida��es do usu�rio
    If ( SCR->CR_TIPO == 'AP' )
        aAdd( aAlc ,{ SCR->CR_TIPO, 'ZA0', 1, 'ZA0->ZA0_CODIGO','','',{'ZA0->ZA0_STATUS',"1","2","3"}})
    EndIf

return( aAlc )