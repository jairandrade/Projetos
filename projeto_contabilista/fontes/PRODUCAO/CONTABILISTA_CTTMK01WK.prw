#include 'totvs.ch'

/*/{Protheus.doc} CTTMK01WK
    Função utilizada na validação do usuário campo UA_CLIENTE
    @type  Function
    @author Willian Kaneta
    @since 11/09/2020
    @version 1.0
    @return lRet .T./ .F.
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function CTTMK01WK()
    Local lRet      := .T.
    Local aAreaSUA  := SUA->(GetArea())
    Local aAreaSA1  := SA1->(GetArea())
    Local aArea     := GetArea()
    Local cInscEst  := ""
    Local cUFClien  := ""
    
    If !Empty(M->UA_CLIENTE)
        cInscEst  := Alltrim(POSICIONE("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_INSCR"))
        cUFClien  := POSICIONE("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_EST")
    EndIf
    If !Empty(cInscEst) .AND. cInscEst != "ISENTO".AND. !Empty(cUFClien) .AND. Alltrim(cFilAnt) == "010104"
        //Valida Cadastro Contribuinte na SEFAZ
        lRet := U_CTFAT01WK(cInscEst,cUFClien)
    EndIf
    RestArea(aArea)
    RestArea(aAreaSA1)
    RestArea(aAreaSUA)
Return lRet

