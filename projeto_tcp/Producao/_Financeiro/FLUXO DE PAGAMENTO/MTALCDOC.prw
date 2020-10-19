#include "totvs.ch"

/*/{Protheus.doc} MTALCDOC
O ponto de Entrada MTALCDOC permite manipular a tabela de documento de alçadas SCR
@type  User Function
@author Kaique Mathias
@since 01/04/2020
/*/

user function MTALCDOC()

    Local aDocto   := ParamIXB[1]
    Local nOper    := ParamIXB[3]
    //Local dDataRef := ParamIXB[2]
    //Local cItGrp   := ParamIXB[4]
    //Local cTpDocWF := ""

    //Willian Kaneta - Adicionado CR_TIPO = LC - Lançamento Contábil
    If ( aDocto[2] $ 'AP|LC' )
        TCPALCDOC(aDocto,nOper)
    EndIf

return( nil )

/*/{Protheus.doc} TCPALCDOC
O ponto de Entrada TCPALCDOC permite manipular a tabela de documento de alçadas SCR
@type  User Function
@author Kaique Mathias
@since 01/04/2020
/*/

Static Function TCPALCDOC(aDocto,nOper)

    Local aArea     := getArea()
    Local cDocto    := aDocto[1]
    Local cTipoDoc 	:= aDocto[2]
    Local cAprov    := If(aDocto[4]==Nil,"",aDocto[4])
    Local cGrupo	:= If(aDocto[6]==Nil,"",aDocto[6])
    Local cFilSCR   := xFilial("SCR")
    Local lAchou    := .F.
    Local cAuxNivel := ""
    Local cNextNiv  := ""
    Local cNivIgual := ""    
    Local lUserNiv	:= .F.
    Local nCount    := 1
    Local lBlqNivel := .F.
    Local lEnvCop   := .F.

    Do Case

    Case ( nOper == 1 ) //Inclusao

        SCR->(dbSetOrder(1))
        SCR->(MsSeek(cFilSCR + cTipoDoc + PadR(cDocto,TamSX3('CR_NUM')[1]) ))

        While SCR->(!Eof()) .And. SCR->(CR_FILIAL+CR_TIPO+CR_NUM) == cFilSCR + cTipoDoc + PadR(cDocto,TamSX3('CR_NUM')[1])
            If ( SCR->CR_STATUS == "02" )
                If ( cTipoDoc == "AP" )
                    If RecLock("SCR",.F.)
                        SCR->CR_XHORAS := Alltrim(SubS(StrTran(Time(),":",""),1,4))
                        SCR->(MsUnlock())
                    EndIf
                    U_TCFIW004()
                //Willian Kaneta - Envio WF Aprovação Pré Lançamento Contábil CT2
                ElseIf ( cTipoDoc == "LC" )
                    If RecLock("SCR",.F.)
                        SCR->CR_XHORAS := Alltrim(SubS(StrTran(Time(),":",""),1,4))
                        SCR->(MsUnlock())
                    EndIf
                    U_TCCTW001(1)
                    //Envia email cópia parametro TCP_MAILLC
                    If !lEnvCop
                        U_TCCTW001(5)
                        lEnvCop   := .T.
                    EndIf
                EndIf
            EndIf
            SCR->(dbSkip())
        EndDo

    Case ( nOper == 4 ) //aprovacao

        If !Empty(cAprov)

            dbSelectArea("SAL")
            SAL->(dbSetOrder(3))

            SAL->(dbSeek( xFilial("SAL") + cGrupo + cAprov ) )

            cAuxNivel := SAL->AL_NIVEL

            SCR->(dbSetOrder(1))
            SCR->(MsSeek(cFilSCR + cTipoDoc + cDocto + cAuxNivel))

            While SCR->(!Eof()) .And. ( SCR->(CR_FILIAL+CR_TIPO+CR_NUM) == cFilSCR + cTipoDoc + cDocto )

                If ( cAuxNivel == SCR->CR_NIVEL .And. SCR->CR_STATUS != "03" .And. SAL->AL_TPLIBER $ "U " ) //.And. ( !Alltrim(SCR->CR_OBS) $ cObsBloq + SAK->AK_COD )
                    If ( cGrupo # SCR->CR_GRUPO )
                        SCR->(dbSkip())
                        Loop
                    ElseIf nCount > 1 // Indica que ainda existem usuarios neste nivel do mesmo grupo, com pendencia de aprovacao , neste caso nao deve liberar os niveis seguintes
                        lBlqNivel := .T.
                        SCR->(dbSkip())
                        Loop
                    EndIf
                    lUserNiv := .T.
                EndIf

                If ( cAuxNivel != SCR->CR_NIVEL .And. lUserNiv .And. SAL->AL_TPLIBER $ "U " .And. cGrupo == SCR->CR_GRUPO )
                    SCR->(dbSkip())
                    Loop
                EndIf

                If ( cGrupo # SCR->CR_GRUPO )
                    If ( cAuxNivel >= SCR->CR_NIVEL )
                        SCR->(dbSkip())
                        Loop
                    EndIf
                EndIf

                If ( SCR->CR_NIVEL > cAuxNivel .And. SCR->CR_STATUS != "03" .And. !lAchou .And. cGrupo == SCR->CR_GRUPO )
                    lAchou := .T.
                    cNextNiv := SCR->CR_NIVEL
                EndIf

                If ( lAchou .And. SCR->CR_NIVEL == cNextNiv .And. SCR->CR_STATUS != "03" )
                    If Reclock("SCR",.F.)
                        If ( (Empty(cNivIgual) .Or. cNivIgual == SCR->CR_NIVEL) .And. cStatusAnt <> "01" .And. !lBlqNivel )
                            SCR->CR_STATUS := "02"
                            SCR->CR_XHORAS := Alltrim(SubS(StrTran(Time(),":",""),1,4))
                            cNivIgual := SCR->CR_NIVEL
                            If ( cTipoDoc == "AP" )
                                dbSelectArea("ZA0")
                                ZA0->(dbSetOrder( 1 ))
                                ZA0->(MSSeek(xFilial("ZA0")+PadR(SCR->CR_NUM,TamSX3("ZA0_CODIGO")[1])))
                                U_TCFIW004()
                            //Willian Kaneta - Envia WF para os próximos níveis aprovação Pré Lançamento CT2
                            ElseIf ( cTipoDoc == "LC" )
                            	DbSelectArea("CT2")
                            	CT2->(DbSetOrder(1))
                            	If CT2->(MsSeek(cFilSCR+Alltrim(cDocto)))
                            		U_TCCTW001(1)
                                EndIf
                            EndIf
                        EndIf
                        SCR->(MsUnlock())
                        lAchou    := .F.
                    Endif
                Endif
                
                If ( cGrupo == SCR->CR_GRUPO )
                    cStatusAnt := SCR->CR_STATUS
                EndIf
                
                nCount++
                
                SCR->(dbSkip())
            EndDo
        Endif
    
    End Case

    RestArea(aArea)

Return( Nil )
