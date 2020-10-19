#include "protheus.ch"

/*/{Protheus.doc} F050BUT
Adiciona botoes do usuario na EnchoiceBar
@type user function
@version 1.0
@author Kaique Mathias
@since 9/15/2020
@return Array, aButUsr
/*/

User function F050BUT()

    Local aButUsr := {}
    Local cCodSol := ""

    If( !Empty(SE2->E2_XCODPGM) )
        dbSelectArea('ZA0')
        ZA0->( dbSetOrder(1) )
        If( ZA0->( MSSeek( xFilial("SE2") + ZA0->ZA0_CODIGO ) ) )
            cCodSol := StaticCall(TCFIA002,fRetCodSol,ZA0->ZA0_CODSOL,2)
            Aadd(aButUsr, {"BUDGET", { || U_TCCOA01(ZA0->ZA0_CODIGO,"AP", cCodSol) }, OemToAnsi( 'Log de Aprovação' ) } ) 
        EndIf
    EndIf

Return( aButUsr )
