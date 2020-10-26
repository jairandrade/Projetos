#include "protheus.ch"

/*/{Protheus.doc} FA290
Executado durante a gravação dos dados da fatura no SE2 e antes da contabilização.
@type user function
@version 1.0
@author Kaique Mathias
@since 8/11/2020
@return return_type, return_description
/*/

User Function FA290()
    
    Local aArea     := SE2->( GetArea() )
    Local lCtrApr   := GetMv("TCP_CTLIBP")
    Local cTipoSol  := "ISS/"
    Local lContinua := .F.
    
    If( lCtrApr .And. cTipo $ cTipoSol )
        //Mudo o status
        If ExistBlock("TCFIA005")
        MsAguarde({|| Execblock("TCFIA005",.F.,.F.)}, "Aguarde...", "Gravando titulo:"+SE2->E2_NUM+" Tipo:"+SE2->E2_TIPO +" Saldo:"+TransForm(SE2->E2_SALDO,"99999.99" )+" ...")
           // Execblock("TCFIA005",.F.,.F.)
        EndIf
    EndIf
    
    If ExistBlock("TCFIA006")
        ExecBlock('TCFIA006',.F.,.F.,{ParamIXB})
    EndIf

    RestArea(aArea)

Return( Nil )
