#include "protheus.ch"

/*/{Protheus.doc} GP650CHK
(long_description)
@type  Function
@author user
@since date
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/

User Function GP650CHK
    
    Local aRet      := ParamIXB
    Local cTitProc  := Alltrim(MV_PAR09) 
    
    If (cTitProc $ "001|002|003")
        //Valido se o codigo do titulo é unico
        If (MV_PAR09 <> MV_PAR10)
            MsgAlert("Os campos de codigo de titulo de/até devem estar iguais para titulos do tipo FERIAS/RESCISAO/GRRF.")
            aRet[2]     := .F.
        Else
            If (MV_PAR07 <> MV_PAR08)
                MsgAlert("Os campos de data de busca de pagamento de/até devem estar iguais para titulos do tipo FFERIAS/RESCISAO/GRRF.")
                aRet[2]     := .F.
            EndIf
        EndIf
    EndIf

Return( aRet )