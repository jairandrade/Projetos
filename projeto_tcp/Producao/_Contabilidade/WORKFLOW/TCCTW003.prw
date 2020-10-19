#include "totvs.ch"

/*/{Protheus.doc} TCCTW003
    Função utilizada no Ponto de Entrada DPCTB102GR - Rotina Lançamentos contábeis CTBA102
    @type  Function
    @author Willian Kaneta
    @since 26/06/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function TCCTW003(nOpcLct,lExecDel)
    Local lOk       := .F.
    Local nLenSCR 	:= TamSX3("CR_NUM")[1]
    Local lWFApLct  := SUPERGETMV( "TCP_WFLCTO", .F., .F.)
    Local cGrpAprov := SUPERGETMV( "TCP_GRAPLCO", .F., "")
    Local aCab      := {}
    Local aItens    := {}
    Local nRecnoCT2 := 0
    Local cAliasCT2 := GetNextAlias()
    Local cFil      := CT2->CT2_FILIAL
    Local cCodigo   := CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)

    BeginSql Alias cAliasCT2
        SELECT  *
		FROM %TABLE:CT2% CT2
		WHERE CT2.CT2_FILIAL     = %xFilial:CT2%
            AND CT2.CT2_DATA     = %EXP:DTOS(CT2->CT2_DATA)%
            AND CT2.CT2_LOTE     = %EXP:CT2->CT2_LOTE%
            AND CT2.CT2_SBLOTE   = %EXP:CT2->CT2_SBLOTE%
            AND CT2.CT2_DOC      = %EXP:CT2->CT2_DOC%
			AND CT2.CT2_TPSALD   = '9'
            AND CT2.%NOTDEL% 
    EndSql

    If lWFApLct .AND. (!(cAliasCT2)->( Eof() ) .OR. nOpcLct == 6 .OR. nOpcLct == 7)
        If (nOpcLct == 3 .OR. nOpcLct == 4 .OR. nOpcLct == 7 .OR. nOpcLct == 6) .AND. Alltrim(FunName()) == "CTBA102"   
            DbSelectArea("SCR")
            SCR->(DbSetOrder(3))
            
            If !SCR->(MsSeek(cFilAnt+"LC"+Padr(CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC),nLenSCR))) .AND. (nOpcLct == 3 .OR. nOpcLct == 4 .OR. nOpcLct == 6 .OR. nOpcLct == 7) 
                MaAlcDoc({  CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC),;
                        "LC",;
                        aTotRdpe[1][1],;
                        ,;
                        ,;
                        cGrpAprov,;
                        ,1;
                        ,;
                        ,;
                        dDataBase,;
                        ""},;
                        dDataBase,;
                        1)
            ElseIf SCR->(MsSeek(cFilAnt+"LC"+Padr(CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC),nLenSCR))) .AND. nOpcLct == 4
                While SCR->(!EOF()) .AND. SCR->(CR_FILIAL+CR_TIPO+CR_NUM) == cFilAnt+"LC"+Padr(CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC),nLenSCR)
                    lOk := .T.
                    If Reclock("SCR",.F.)
                        SCR->(DbDelete())
                        SCR->(MsUnlock())
                    EndIf
                    SCR->(DbSkip())
                EndDo
                
                If lOk
                    MaAlcDoc({  CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC),;
                            "LC",;
                            aTotRdpe[1][1],;
                            ,;
                            ,;
                            cGrpAprov,;
                            ,1;
                            ,;
                            ,;
                            dDataBase,;
                            ""},;
                            dDataBase,;
                            1)
                EndIf
            EndIf
        //Caso exclusão exclui Alçada na SCR
        ElseIf nOpcLct == 5 .AND. lExecDel
            DbSelectArea("SCR")
            SCR->(DbSetOrder(3))
                
            If SCR->(MsSeek(cFilAnt+"LC"+Padr(CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC),nLenSCR)))
                While SCR->(!EOF()) .AND. SCR->(CR_FILIAL+CR_TIPO+CR_NUM) == cFilAnt+"LC"+Padr(CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC),nLenSCR)
                    If Reclock("SCR",.F.)
                        SCR->(DbDelete())
                        SCR->(MsUnlock())
                    EndIf
                    SCR->(DbSkip())
                EndDo
            EndIf

            DbSelectArea("CT2")
            CT2->(DbSetOrder(1))
            //CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA
            If CT2->(MsSeek(cFil+cCodigo))
                nRecnoCT2 := CT2->(Recno())
                aAdd(aCab,  {'DDATALANC'    ,dDataBase		,NIL} )
                aAdd(aCab,  {'CLOTE'        ,CT2->CT2_LOTE  ,NIL} )
                aAdd(aCab,  {'CSUBLOTE'		,CT2->CT2_SBLOTE,NIL} )
                aAdd(aCab,  {'CDOC'         ,CT2->CT2_DOC   ,NIL} )
                
                While CT2->(!EOF()) .AND. CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)==cFil+cCodigo
                    aAdd(aItens,{   {'LINPOS'         ,'CT2_LINHA'		,CT2->CT2_LINHA},;
                                    {'CT2_FILIAL'     ,CT2->CT2_FILIAL	, NIL},;
                                    {'CT2_MOEDLC'     ,CT2->CT2_MOEDLC  , NIL},;
                                    {'CT2_DC'         ,CT2->CT2_DC      , NIL},;
                                    {'CT2_DEBITO'     ,CT2->CT2_DEBITO  , NIL},;
                                    {'CT2_CREDIT'     ,CT2->CT2_CREDIT  , NIL},;
                                    {'CT2_VALOR'      ,CT2->CT2_VALOR   , NIL},;
                                    {'CT2_ORIGEM'     ,CT2->CT2_ORIGEM  , NIL},;
                                    {'CT2_HP'         ,CT2->CT2_HP      , NIL},;
                                    {'CT2_EMPORI'     ,CT2->CT2_EMPORI  , NIL},;
                                    {'CT2_FILORI'     ,CT2->CT2_FILORI  , NIL},;
                                    {'CT2_HIST'       ,CT2->CT2_HIST    , NIL},;
                                    {'CT2_TPSALD'     ,"1"    			, NIL}}) 
                    CT2->(DbSkip()) 
                EndDo

                U_TCCTW001(4,aCab,aItens,nRecnoCT2)
            EndIf
        EndIf 
    EndIf 
Return Nil
