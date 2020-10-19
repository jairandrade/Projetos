#include "protheus.ch"

/*/{Protheus.doc} TCFIA006
Gravações após geração da fatura
@type user function
@version 1.0
@author Kaique Mathias
@since 9/11/2020
@return return_type, return_description
/*/

User Function TCFIA006()

    Begin Transaction
        If RecLock("SE2",.F.)
            SE2->E2_XORIGEM := aCols[1][GDFieldPos("E2_XORIGEM")]
            SE2->( MsUnlock() )
        EndIf
    End Transaction

Return( Nil )
