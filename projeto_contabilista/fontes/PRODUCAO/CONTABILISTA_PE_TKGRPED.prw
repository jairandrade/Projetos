#include "totvs.ch"

/*/{Protheus.doc} User Function TKGRPED
    Ponto de entrada para validar gravação atendimento SIGATMK
    @type  Function
    @author Willian Kaneta
    @since 23/08/2020
    @version 1.0
    @param [nLiquido], [aParcelas], [cOpera], [cNum], [cCodLig], 
    @param [cCodPagto], [cOpFat], [cCodTransp]
    @return lRet(logico) Se permite finalizar o chamado.
    /*/
User Function TKGRPED(nLiquido,aParcelas,cOpera,cNum)
    Local lRet      := .T.
    Local aAreaSUA  := SUA->(GetArea())
    Local aAreaSA1  := SA1->(GetArea())
    Local aArea     := GetArea()
    Local cInscEst  := Alltrim(POSICIONE("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_INSCR"))
    Local cUFClien  := POSICIONE("SA1",1,xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA,"A1_EST")
    
    If !Empty(cInscEst) .AND. cInscEst != "ISENTO".AND. !Empty(cUFClien) .AND. cOpera == "1" .AND. M->UA_XESTOQU == "2" .AND. Alltrim(cFilAnt) == "010104"
        //Valida Cadastro Contribuinte na SEFAZ
        lRet := U_CTFAT01WK(cInscEst,cUFClien)
    EndIf
    RestArea(aArea)
    RestArea(aAreaSA1)
    RestArea(aAreaSUA)
Return lRet
