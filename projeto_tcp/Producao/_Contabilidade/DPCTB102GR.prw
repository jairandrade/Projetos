#include "totvs.ch"

/*/{Protheus.doc} DPCTB102GR
    Ponto de entrada utilizado após a gravação dos dados da tabela de lançamento CTBA102
    @type  Function
    @author Willian Kaneta
    @since 22/06/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function DPCTB102GR()
    Local aAreaCT2  := CT2->(GetArea())
    Local aArea     := GetArea()
    Local nOpcLct   := ParamIxb[1]
    Local cIndexCT2 := (DTOS(ParamIxb[2])+ParamIxb[3]+ParamIxb[4]+ParamIxb[5])
    
    DbSelectArea("CT2")
    CT2->(DbSetOrder(1))
     //CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA
    If CT2->(MsSeek(xFilial("CT2")+cIndexCT2))
        If (nOpcLct == 3 .OR. nOpcLct == 4 .OR. nOpcLct == 7 .OR. nOpcLct == 6) .AND.;
        Alltrim(FunName()) == "CTBA102"
            //Função para envio WF Aprovação Pré Lançamento Contábil
            U_TCCTW003(nOpcLct,.F.)
        EndIf
    EndIf
    RestArea(aArea)
    RestArea(aAreaCT2)  
Return Nil
