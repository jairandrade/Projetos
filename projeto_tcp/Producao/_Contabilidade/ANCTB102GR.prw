#include "totvs.ch"

/*/{Protheus.doc} ANCTB102GR
    Ponto de entrada utilizado antes da gravação dos dados da tabela de lançamento CTBA102 
    @type  Function
    @author Willian Kaneta
    @since 26/06/2020
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function ANCTB102GR()
    Local aAreaCT2  := CT2->(GetArea())
    Local aAreaTMP  := TMP->(GetArea())
    Local aArea     := GetArea()
    Local nOpcLct   := ParamIxb[1]
    
    DbSelectArea("CT2")
	CT2->(DbSetOrder(1))

    DbSelectArea("TMP")
	TMP->(DbGotop())

	While !TMP->(Eof())
        If CT2->(MsSeek(TMP->CT2_FILIAL+DTOS(TMP->CT2_DATA)+TMP->CT2_LOTE+TMP->CT2_SBLOTE+TMP->CT2_DOC+TMP->CT2_LINHA))
            //Se a linha estiver delatada volta para saldo = 1 
            If TMP->CT2_FLAG  .AND. CT2->CT2_TPSALD == "1"
                TMP->CT2_TPSALD := "1"
            EndIf
        EndIf
        TMP->(DbSkip())
    EndDo
    
    RestArea(aAreaTMP) 

    If nOpcLct == 5
        //Função para envio WF Aprovação Pré Lançamento Contábil
        U_TCCTW003(nOpcLct,.T.)
    EndIf

    RestArea(aArea) 
    RestArea(aAreaCT2)  
Return Nil
