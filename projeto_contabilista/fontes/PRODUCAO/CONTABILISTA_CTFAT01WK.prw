#include "totvs.ch"

/*/{Protheus.doc} User Function CTFAT01WK
    Função para retornar a situação do contrinuinte na SEFAZ
    @type  Function
    @author Willian Kaneta
    @since 22/08/2020
    @version 1.0
    @return lRet .T. Ativo, .F. Inativo
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function CTFAT01WK(cIECli,cUFCli)
    Local cURL     	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
    Local cIdEnt    := ""
    Local cRazSoci 	:= ""
    Local cRegApur  := ""
    Local cCnpj	    := ""
    Local cCpf	    := ""
    Local cSituacao := ""
    Local lRet      := .T.

    Local dIniAtiv  := Date()
    Local dAtualiza	:= Date()

    Local nX	    := {}

    Private oWS

    cIdEnt := RetIdEnti(.F.)

    oWs:= WsNFeSBra():New()
    oWs:cUserToken    := "TOTVS"
    oWs:cID_ENT	      := cIdEnt
    oWs:cUF		      := cUFCli
    oWs:cCNPJ	      := ""
    oWs:cCPF	      := ""
    oWs:cIE		      := Alltrim(cIECli)
    oWs:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"

    If oWs:CONSULTACONTRIBUINTE()

        If Type("oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE") <> "U"
            If ( Len(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE) > 0 )
                nX := Len(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE)

                If ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dInicioAtividade) <> "U"
                    dIniAtiv  := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dInicioAtividade
                Else
                        dIniAtiv  := ""
                EndIf
                cRazSoci  := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cRazaoSocial
                cRegApur  := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cRegimeApuracao
                cCnpj	    := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cCNPJ
                cCpf	    := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cCPF
                cIe       := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cIE
                cUf	    := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cUF
                cSituacao := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:cSituacao

                If ValType(oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dUltimaSituacao) <> "U"
                    dAtualiza := oWs:OWSCONSULTACONTRIBUINTERESULT:OWSNFECONSULTACONTRIBUINTE[nX]:dUltimaSituacao
                Else
                    dAtualiza := ""
                EndIf

                If ( cSituacao == "0" )
                    M->UA_OPER := "2"
                    Help(NIL, NIL, "CTFAT01WK", NIL, "Cliente com restrições no Governo Estadual " + cUf, 1,0, NIL, NIL, NIL, NIL, NIL,;
                        {"Favor verifique a situação com o cliente."})
                    lRet := .F.
                EndIf

            EndIf
        EndIf
    Else
        Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
    EndIf
Return lRet
