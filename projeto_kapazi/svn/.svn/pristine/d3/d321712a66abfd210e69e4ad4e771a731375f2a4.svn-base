/*/{Protheus.doc} nomeFunction
(long_description)
@type  Function
@author user
@since 17/08/2020
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function VLF1FORN()
Local lRet      := .t.
Local cFornKp   := ""
Local cLjKp     := ""
Local nOpcY     := 0
Local aProduto  := {}
Local nItem     := nil
Local cItem     := nil
Local nXX       := 1
Local nX        := 1

If IsInCallStack("A103NFiscal") //Nota de entrada
    
    If INCLUI .And. !l103Auto 
    
        If !Empty(cA100For) //Incluir
            cFornKp   := cA100For
            cLjKp     := cLoja

            //A5_FILIAL, A5_FORNECE, A5_LOJA, A5_PRODUTO, A5_FABR, A5_FALOJA, R_E_C_N_O_, D_E_L_E_T_
            DbSelectArea("SA5")
            SA5->(DbSetOrder(1))
            SA5->(DbGoTop())
            If SA5->(DbSeek(xFilial("SA5") + cFornKp + cLjKp))
                While !SA5->(Eof()) .And. SA5->A5_FORNECE == cFornKp .And. SA5->A5_LOJA == cLjKp
                    
                    DbSelectArea("SB1")
                    SB1->(DbSetOrder(1))
                    SB1->(DbGoTop())
                    If SB1->(DbSeek(xFilial("SB1") + SA5->A5_PRODUTO))
                        If Alltrim(SB1->B1_TIPO) == 'MO'
                            aAdd(aProduto,SA5->A5_PRODUTO)
                        EndIf
                    EndIf

                    DbSelectArea("SA5")

                    SA5->(DbSkip())    
                EndDo
            EndIf 

            //Processa....
        EndIf

    EndIf

    
    //validar se tiver item digitado no acols, caso sim o que fazer?
    //Adel(aCols,nDeleta)

    If !Empty(aProduto)

        If !lAtualPr

            For nXX :=1 To Len(aProduto)
                
                DbSelectArea("SB1")
                SB1->(DbSetOrder(1))
                SB1->(DbGoTop())
                If SB1->(DbSeek(xFilial("SB1") + aProduto[nXX]))

                    For nX := 1 to Len(aHeader)
                        
                        If IsHeadRec(aHeader[nX][2])
                                aCols[Len(aCols)][nX] := 0
                        
                            ElseIf IsHeadAlias(aHeader[nX][2])
                                aCols[Len(aCols)][nX] := "SD1"
                        
                            ElseIf Trim(aHeader[nX][2]) == "D1_ITEM"
                                aCols[Len(aCols)][nX] 	:= IIF(cItem<>Nil,cItem,StrZero(1,TamSx3("D1_ITEM")[01]))
                            
                            ElseIf Alltrim(aHeader[nX][2]) == "D1_COD" //Produto
                                aCols[Len(aCols)][nX] := aProduto[nXX]
                            
                            ElseIf Alltrim(aHeader[nX][2]) == "D1_QUANT" //Produto
                                aCols[Len(aCols)][nX] := 1

                            ElseIf Alltrim(aHeader[nX][2]) == "D1_VUNIT" //Produto
                                aCols[Len(aCols)][nX] := 1

                            ElseIf Alltrim(aHeader[nX][2]) == "D1_TOTAL" //Produto
                                aCols[Len(aCols)][nX] := 1

                            ElseIf Alltrim(aHeader[nX][2]) == "D1_DESCRI" //Produto
                                aCols[Len(aCols)][nX] := SB1->B1_DESC

                            ElseIf Alltrim(aHeader[nX][2]) == "D1_UM" //Produto
                                aCols[Len(aCols)][nX] := SB1->B1_UM
                            
                            ElseIf Alltrim(aHeader[nX][2]) == "D1_CC" //Produto
                                aCols[Len(aCols)][nX] := SB1->B1_CC
                                
                            Else
                                aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2], (aHeader[nX][10] <> "V") )
                        EndIf

                        aCols[Len(aCols)][Len(aHeader)+1] := .F.

                    Next nX

                    If Len(aProduto) > nXX
                        aadd(aCols,Array(Len(aHeader)+1))    
                        nItem := (Len(aCols))
                        cItem := StrZero(nItem,TamSx3("D1_ITEM")[01])
                    EndIf
                
                EndIf

            Next

            If Len(aProduto) > 1
                //variavel publica que sinaliza quando ocorreu o preenchimento
                lAtualPr := .t.

                MsgAlert("Confirme produtos, valores, quantidades e TES!!!","Kapazi")
                //MaFisToCols(aHeader,aCols,Len(aCols),"MT100")
                GetDRefresh()

            EndIf

        EndIf

    EndIf

EndIf //Fim se for rotina de documento de entrada

If IsInCallStack("A140NFiscal") //Pré-nota
    
    If INCLUI .And. !l140Auto 
    
        If !Empty(cA100For) //Incluir
            cFornKp   := cA100For
            cLjKp     := cLoja

            //A5_FILIAL, A5_FORNECE, A5_LOJA, A5_PRODUTO, A5_FABR, A5_FALOJA, R_E_C_N_O_, D_E_L_E_T_
            DbSelectArea("SA5")
            SA5->(DbSetOrder(1))
            SA5->(DbGoTop())
            If SA5->(DbSeek(xFilial("SA5") + cFornKp + cLjKp))
                While !SA5->(Eof()) .And. SA5->A5_FORNECE == cFornKp .And. SA5->A5_LOJA == cLjKp
                    
                    DbSelectArea("SB1")
                    SB1->(DbSetOrder(1))
                    SB1->(DbGoTop())
                    If SB1->(DbSeek(xFilial("SB1") + SA5->A5_PRODUTO))
                        If Alltrim(SB1->B1_TIPO) == 'MO'
                            aAdd(aProduto,SA5->A5_PRODUTO)
                        EndIf
                    EndIf

                    DbSelectArea("SA5")

                    SA5->(DbSkip())    
                EndDo
            EndIf 

        EndIf

    EndIf
    
    //validar se tiver item digitado no acols, caso sim o que fazer?
    //Adel(aCols,nDeleta)

    If !Empty(aProduto)

        If !lAtualPr

            For nXX :=1 To Len(aProduto)
                
                DbSelectArea("SB1")
                SB1->(DbSetOrder(1))
                SB1->(DbGoTop())
                If SB1->(DbSeek(xFilial("SB1") + aProduto[nXX]))

                    For nX := 1 to Len(aHeader)
                        
                        If IsHeadRec(aHeader[nX][2])
                                aCols[Len(aCols)][nX] := 0
                        
                            ElseIf IsHeadAlias(aHeader[nX][2])
                                aCols[Len(aCols)][nX] := "SD1"
                        
                            ElseIf Trim(aHeader[nX][2]) == "D1_ITEM"
                                aCols[Len(aCols)][nX] 	:= IIF(cItem<>Nil,cItem,StrZero(1,TamSx3("D1_ITEM")[01]))
                            
                            ElseIf Alltrim(aHeader[nX][2]) == "D1_COD" //Produto
                                aCols[Len(aCols)][nX] := aProduto[nXX]
                            
                            ElseIf Alltrim(aHeader[nX][2]) == "D1_QUANT" //Produto
                                aCols[Len(aCols)][nX] := 1

                            ElseIf Alltrim(aHeader[nX][2]) == "D1_VUNIT" //Produto
                                aCols[Len(aCols)][nX] := 1

                            ElseIf Alltrim(aHeader[nX][2]) == "D1_TOTAL" //Produto
                                aCols[Len(aCols)][nX] := 1

                            ElseIf Alltrim(aHeader[nX][2]) == "D1_DESCRI" //Produto
                                aCols[Len(aCols)][nX] := SB1->B1_DESC

                            ElseIf Alltrim(aHeader[nX][2]) == "D1_UM" //Produto
                                aCols[Len(aCols)][nX] := SB1->B1_UM
                            
                            ElseIf Alltrim(aHeader[nX][2]) == "D1_CC" //Produto
                                aCols[Len(aCols)][nX] := SB1->B1_CC
                                
                            Else
                                aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2], (aHeader[nX][10] <> "V") )
                        EndIf

                        aCols[Len(aCols)][Len(aHeader)+1] := .F.

                    Next nX

                    If Len(aProduto) > nXX
                        aadd(aCols,Array(Len(aHeader)+1))    
                        nItem := (Len(aCols))
                        cItem := StrZero(nItem,TamSx3("D1_ITEM")[01])
                    EndIf
                
                EndIf

            Next

            If Len(aProduto) > 1
                //variavel publica que sinaliza quando ocorreu o preenchimento
                lAtualPr := .t.

                MsgAlert("Confirme produtos, valores, quantidades e TES!!!","Kapazi")
                //MaFisToCols(aHeader,aCols,Len(aCols),"MT100")
                GetDRefresh()

            EndIf

        EndIf

    EndIf

EndIf

Return(lRet)
