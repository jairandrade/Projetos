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
User Function VLC7FORN()
Local lRet      := .t.
Local cFornKp   := ""
Local cLjKp     := ""
Local nOpcY     := 0
Local aProduto  := {}
Local nItem     := nil
Local cItem     := nil
Local nXX       := 1
Local nX        := 1

If IsInCallStack("A120Pedido") 
    If INCLUI .And. !l120Auto 
    
        If !Empty(cA120Forn)//Incluir
            
            cFornKp   := cA120Forn
            cLjKp     := cA120Loj

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

EndIf

//validar se tiver item digitado no acols, caso sim o que fazer?
//Adel(aCols,nDeleta)

If !Empty(aProduto)
    
    For nXX :=1 To Len(aProduto)

        DbSelectArea("SB1")
        SB1->(DbSetOrder(1))
        SB1->(DbGoTop())
        If SB1->(DbSeek(xFilial("SB1") + aProduto[nXX]))

            For nX := 1 to Len(aHeader)
                
                If Trim(aHeader[nX][2]) == "C7_ITEM"
                        aCols[Len(aCols)][nX] 	:= IIF(cItem<>Nil,cItem,StrZero(1,TamSx3("C7_ITEM")[01]))

                    Elseif Trim(aHeader[nX][2]) == "C7_ALI_WT"
                        aCols[Len(aCols)][nX] 	:= "SC7"

                    ElseIf Trim(aHeader[nX][2]) == "C7_REC_WT"
                        aCols[Len(aCols)][nX] 	:= 0

                    //ElseIf Trim(aHeader[nX][2]) == "C7_TES"	
                     //   aCols[Len(aCols)][nX] 	:=RetFldProd(SB1->B1_COD,"B1_TE")

                    ElseIf Trim(aHeader[nX][2]) == "C7_PRODUTO"
                        aCols[Len(aCols)][nX] 	:= SB1->B1_COD

                    ElseIf Trim(aHeader[nX][2]) == "C7_DESCRI"	    
                        aCols[Len(aCols)][nX] 	:= SB1->B1_DESC

                    ElseIf Trim(aHeader[nX][2]) == "C7_UM" //C7_SEGUM B1_SEGUM
                        aCols[Len(aCols)][nX] 	:= SB1->B1_UM

                    //ElseIf Trim(aHeader[nX][2]) == "C7_SEGUM" // 
                    //    aCols[Len(aCols)][nX] 	:= SB1->B1_SEGUM    

                    ElseIf Trim(aHeader[nX][2]) == "C7_QUANT"
                        aCols[Len(aCols)][nX] 	:= 1

                    ElseIf Trim(aHeader[nX][2]) == "C7_PRECO"
                        aCols[Len(aCols)][nX] 	:= 1

                    ElseIf Trim(aHeader[nX][2]) == "C7_TOTAL"
                        aCols[Len(aCols)][nX] 	:= 1

                    Else 		
                        aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2],(aHeader[nX][10] <> "V") )
                EndIf

                aCols[Len(aCols)][Len(aHeader)+1] := .F.

            Next nX

            If Len(aProduto) > nXX
                aadd(aCols,Array(Len(aHeader)+1))    
                nItem := (Len(aCols))
                cItem := StrZero(nItem,TamSx3("C7_ITEM")[01])
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

Return(lRet)
