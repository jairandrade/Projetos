#include "protheus.ch"
#include "fwMvcDef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTA6851
Este Ponto de entrada Permite criação da propria regra de validacao
no momento da inclusao, alteracao e exclusao de atestados medicos e 
e acionado em qualquer rotina que esteja vinculado a ele.
@author  Kaique Mathias
@since   19/12/2019
@version 1.0
/*/
//-------------------------------------------------------------------

User Function MDTA6851()

    Local lReturn   := .T.
    Local dDataIni  := FwFldGet("TNY_DTINIC")
    Local dDataFim  := FwFldGet("TNY_DTFIM")
    Local cHrIni    := FwFldGet("TNY_HRINIC")
    Local cHrFim    := FwFldGet("TNY_HRFIM")
    Local nPrzLanc  := 48
    Local dDataFech := GetMv("TCP_DTMDT")
    Local oModel 	:= FWModelActive() //Ativa modelo utilizado.
    
    If ( dDataIni < dDataFech ) .Or. ( !Empty(dDataFim) .And. dDataFim < dDataFech )
        MsgInfo("A data informada esta bloqueada para inclusão de atestados." + CRLF +;
                "Favor verificar o parametro TCP_DTMDT.")
        lReturn := .F.
    EndIf

    If ( oModel:GetOperation() <> MODEL_OPERATION_DELETE )

        If ( lReturn )
            lReturn := U_TCMDA002() //Checo atestados para o mesmo CID
        EndIf

        if ( lReturn ) 
            If ( U_DATEDIFFTIME(dDataIni,cHrIni,Date(),Time()) > nPrzLanc )
                lReturn := U_TCMDA001()
            EndIf
        EndIf

    EndIf

Return( lReturn )