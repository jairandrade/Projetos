#include "totvs.ch"

/*/{Protheus.doc} TCCTWF01
    Função para reenviar WF Aprovação Lançamentos Contábeis CTBA102.
    @type  Function
    @author Willian Kaneta
    @since 23/06/2020
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function TCCTWF01()
    Local lFound    := .F.
    Local aArea     := GetArea()
    Local aAreaCT2  := CT2->(GetArea())
    Local nLenSCR 	:= TamSX3("CR_NUM")[1]
    Local cCodigo   := CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)

    DbSelectArea("SCR")
    SCR->(DbSetOrder(1))
    
    If SCR->(MsSeek(xFilial("SCR")+"LC"+Padr(cCodigo,nLenSCR)))
        While SCR->(!EOF()) .AND. SCR->(CR_FILIAL+CR_TIPO+CR_NUM) == (cFilAnt+"LC"+Padr(cCodigo,nLenSCR))
			If SCR->CR_STATUS == "02"
                U_TCCTW001(1)
                lFound := .T.
			EndIf
			SCR->(DbSkip())
		EndDo

        If lFound
            MsgInfo('Workflow Reenviado com sucesso!')
        Else
            MsgInfo('Não existe registros aptos a serem reenviados!')
        EndIf

    else
        MsgInfo("Alçada não localizada!")
    EndIf

    RestArea(aAreaCT2)
    RestArea(aArea)
Return Nil
