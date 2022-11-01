#INCLUDE "PROTHEUS.CH"

User Function UPDSRD164()

Local aButtons      := {}
Local aSays         := {}
Local nOpcA         := 0

Private aCodFol     := {}
Private aLogUPD     := {}
Private aTitle      := {}

//Carrega o array aCodFol para verificar o cadastro de verbas x Ids de cálculo
If !Fp_CodFol(@aCodFol, cFilAnt, .F., .F.)
    MsgInfo( "Houve erro na carga do cadastro de verbas" )
    Return()
EndIf

aAdd(aSays,OemToAnsi( "Este programa tem como objetivo separar os lançamentos das" ))
aAdd(aSays,OemToAnsi( "verbas dos IDs 0164 e 1449 na tabela de histórico SRD     " ))
aAdd(aSays,OemToAnsi( "conforme data de pagamento quando há diferença de férias. " ))
aAdd(aSays,OemToAnsi( 'Clique no botão "Abrir" para abrir a documentação no TDN.'))
aAdd(aSays,OemToAnsi( "" ))

aAdd(aButtons, { 14 ,.T.,{||  ShellExecute("open","https://tdn.totvs.com/x/zqS_Jw","","",1) } } )
aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1, FechaBatch() }} )
aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

//Abre a tela de processamento
FormBatch( "Processamento tabela SRD", aSays, aButtons )

//Efetua o processamento de geração
If nOpcA == 1
    Aadd( aTitle, OemToAnsi( "Funcionários que tiveram registros alterados:" ) )
    Aadd( aLogUPD, {} )
    ProcGpe( {|lEnd| fProcessa( )},,,.T. )
    If !Empty(aLogUPD[1])
        fMakeLog(aLogUPD,aTitle,,,"UPDSRD164",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
    EndIf
EndIf

Return

/*/{Protheus.doc} fProcessa
Função que efetua o processamento para a geração do Id 1562
/*/
Static Function fProcessa()

Local aAuxSRD       := {}
Local aAux1449      := {}
Local aAreaSRD      := SRD->( GetArea() )
Local aValSRD       := {}
Local cAliasQry     := GetNextAlias()
Local cChavePes     := ""
Local cIdAbon       := "0074/0079/0094/0095/0622/0623/0632/1312/1314/1316/1318/1320/1322/1324/1326/1330/1407/1408/1416/1417/"
Local cDifAbo       := RetValSRV(aCodFol[0074, 1], cFilAnt, "RV_FERSEG")
Local cDifFer       := RetValSRV(aCodFol[0072, 1], cFilAnt, "RV_FERSEG")
Local cId0164       := aCodFol[0164, 1]
Local cId1449       := aCodFol[1449, 1]
Local cMatPesq      := ""
Local cPdIn         := "%RD_PD IN ('" + cId0164 + "', '" + cId1449 + "')%"
Local cPerPesq      := ""
Local cSeq          := " "
Local cVerbaAux     := ""
Local lItemClvl     := GetMvRH( "MV_ITMCLVL", .F., "2" ) $ "1*3"
Local lRefAbono	    := SRV->( ColumnPos( "RV_REFABON" ) ) > 0
Local lSeqMV	    := SRC->( ColumnPos( "RC_SEQMV" ) ) > 0
Local nCont         := 0
Local nPosAux       := 0
Local nValSRD       := 0

If MsgNoYes("Foi efetuado backup da tabela SRD?", "Atenção!") .And. MsgYesNo("Tem certeza que quer continuar?", "Atenção!")
    SRD->( dbSetOrder(1) )//RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC+RD_PROCES

    BeginSql alias cAliasQry
        SELECT R_E_C_N_O_ AS RECNO
        FROM %table:SRD% SRD
        WHERE RD_DATPGT >= '20201201' AND %exp:cPdIn%
            AND SRD.%notDel%    
        ORDER BY RD_FILIAL,RD_MAT,RD_DATARQ,RD_PD
    EndSql 

    While (cAliasQry)->( !EoF() )
        SRD->( dbGoTo( (cAliasQry)->RECNO ) )

        //Se filial, matrícula e período já processados, pula para o próximo registro
        If cPerPesq == SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_DATARQ
            (cAliasQry)->( dbSkip() )
            Loop
        Else
            aAux0164  := {}
            aAux1449  := {}
            cPerPesq  := SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_DATARQ
        EndIf

        //Se ID 0164, monta chave com base na diferença de férias
        If RetValSRV(SRD->RD_PD, SRD->RD_FILIAL, "RV_CODFOL") == "0164"
            cChavePes := SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_DATARQ+cDifFer+SRD->RD_SEMANA
        //Senão (ID 1449), monta chave com base na diferença de abono
        Else
            cChavePes := SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_DATARQ+cDifAbo+SRD->RD_SEMANA
        EndIf

        //Verifica se no mês teve diferença de férias/abono que foi originada do período anterior
        If SRD->( dbSeek( cChavePes ) ) .And. SRD->RD_TIPO2 == "F"
            //Processa todos os lançamentos desse período para verificar os valores de férias/abono originados do período anterior
            SRD->( dbSeek( cPerPesq ) )
            While SRD->( !EoF() ) .And. SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_DATARQ == cPerPesq
                //Caso seja uma verba originada do período anterior, não seja os IDs 0164 e 1449 e seja uma verba referente a férias
                If SRD->RD_TIPO2 == "F" .And. !(SRD->RD_PD $ (cId0164+"/"+cId1449)) .And. RetValSRV(SRD->RD_PD, SRD->RD_FILIAL, "RV_REFFER") == "S"
                    //Verifica se é verba de abono ou férias
                    If RetValSRV(SRD->RD_PD, SRD->RD_FILIAL, "RV_CODFOL") $ cIdAbon .Or. (lRefAbono .And. RetValSRV(SRD->RD_PD, SRD->RD_FILIAL, "RV_REFABON") == "1")
                        cVerbaAux := cId1449
                    Else
                        cVerbaAux := cId0164
                    EndIf
                    nValSRD := SRD->RD_VALOR
                    If RetValSRV(SRD->RD_PD, SRD->RD_FILIAL, "RV_TIPOCOD") == "2"
                        nValSRD *= (-1)
                    EndIf
                    If ( nPosAux := aScan( aAuxSRD, { |x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]+dToS(x[8])+x[9] == SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_DATARQ+SRD->RD_SEMANA+SRD->RD_CC+Iif(lItemClvl, SRD->RD_ITEM, "")+Iif(lItemClvl, SRD->RD_CLVL, "")+dToS(SRD->RD_DATPGT)+cVerbaAux } ) ) > 0
                        aAuxSRD[nPosAux, 10] += nValSRD
                    Else
                        aAdd( aAuxSRD, { SRD->RD_FILIAL, SRD->RD_MAT, SRD->RD_DATARQ, SRD->RD_SEMANA, SRD->RD_CC, Iif(lItemClvl, SRD->RD_ITEM, ""), Iif(lItemClvl, SRD->RD_CLVL, ""), SRD->RD_DATPGT, cVerbaAux, nValSRD, SRD->( Recno() ) } )
                    EndIf
                EndIf
                SRD->( dbSkip() ) 
            EndDo
        EndIf

        (cAliasQry)->( dbSkip() )
    EndDo

    If lItemClvl
        SRD->( dbSetOrder(11) )//RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC+RD_ITEM+RD_CLVL
    EndIf

    For nCont := 1 To Len(aAuxSRD)
        //Se filial, matrícula e período já processados, incrementa sequência
        If cMatPesq != aAuxSRD[nCont, 1]+aAuxSRD[nCont, 2]
            cMatPesq := aAuxSRD[nCont, 1]+aAuxSRD[nCont, 2]
            If aScan( aLogUPD[1], { |x| x ==  "Filial: " + aAuxSRD[nCont, 1] + "  -  Matrícula: " + aAuxSRD[nCont, 2] } ) == 0
                aAdd( aLogUPD[1], "Filial: " + aAuxSRD[nCont, 1] + "  -  Matrícula: " + aAuxSRD[nCont, 2] )
            EndIf
            cChavePes := aAuxSRD[nCont, 1]+aAuxSRD[nCont, 2]+aAuxSRD[nCont, 3]+cId0164+aAuxSRD[nCont, 4]
            If SRD->( dbSeek( cChavePes ) )
                While SRD->( !EoF() ) .And. SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_DATARQ+SRD->RD_PD+SRD->RD_SEMANA == cChavePes
                    aAdd( aLogUPD[1], "----- Lançamento abaixo foi excluído:"  )
                    aAdd( aLogUPD[1], "----- Período: " + SRD->RD_PERIODO  + " | Verba: " + SRD->RD_PD + " | Data: " + dToC(SRD->RD_DATPGT) + " | CC: " + SRD->RD_CC + " | Valor: " + cValToChar(SRD->RD_VALOR) + " | Recno : " + cValToChar(SRD->(Recno())) )
                    If SRD->( RecLock( "SRD", .F. ) )
                        SRD->( dbDelete() )
                        SRD->( MsUnlock() )
                    EndIf
                    SRD->( dbSkip() )
                End
            EndIf
            cChavePes := aAuxSRD[nCont, 1]+aAuxSRD[nCont, 2]+aAuxSRD[nCont, 3]+cId1449+aAuxSRD[nCont, 4]
            If SRD->( dbSeek( cChavePes ) )
                While SRD->( !EoF() ) .And. SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_DATARQ+SRD->RD_PD+SRD->RD_SEMANA == cChavePes
                    aAdd( aLogUPD[1], "----- Lançamento abaixo foi excluído:"  )
                    aAdd( aLogUPD[1], "----- Período: " + SRD->RD_PERIODO  + " | Verba: " + SRD->RD_PD + " | Data: " + dToC(SRD->RD_DATPGT) + " | CC: " + SRD->RD_CC + " | Valor: " + cValToChar(SRD->RD_VALOR) + " | Recno : " + cValToChar(SRD->(Recno())) )
                    If SRD->( RecLock( "SRD", .F. ) )
                        SRD->( dbDelete() )
                        SRD->( MsUnlock() )
                    EndIf
                    SRD->( dbSkip() )
                End
            EndIf
        EndIf

        aValSRD := {}
        cSeq    := " "
        SRD->( dbGoTo( aAuxSRD[nCont, 11] ) )
        aAdd( aValSRD, { SRD->RD_TIPO1, SRD->RD_HORAS, SRD->RD_EMPRESA, SRD->RD_MES, SRD->RD_STATUS, SRD->RD_INSS, SRD->RD_IR, SRD->RD_FGTS, SRD->RD_PROCES, SRD->RD_ROTEIR, SRD->RD_VALORBA, Iif(lSeqMV, SRD->RD_SEQMV, "") } )

        cChavePes := aAuxSRD[nCont, 1]+aAuxSRD[nCont, 2]+aAuxSRD[nCont, 3]+aAuxSRD[nCont, 9]+aAuxSRD[nCont, 4]+cSeq+aAuxSRD[nCont, 5]+Iif(lItemClvl, aAuxSRD[nCont, 6]+aAuxSRD[nCont, 7], "")
        If SRD->( dbSeek( cChavePes ) )
            cSeq := Soma1(cSeq)
        EndIf

        If SRD->( RecLock( "SRD", .T. ) )
            SRD->RD_FILIAL      := aAuxSRD[nCont, 1]
            SRD->RD_MAT         := aAuxSRD[nCont, 2]
            SRD->RD_PD          := aAuxSRD[nCont, 9]
            SRD->RD_TIPO1       := aValSRD[1, 1]
            SRD->RD_HORAS       := aValSRD[1, 2]
            SRD->RD_VALOR       := aAuxSRD[nCont, 10]
            SRD->RD_DATARQ      := aAuxSRD[nCont, 3]
            SRD->RD_DATPGT      := aAuxSRD[nCont, 8]
            SRD->RD_SEQ         := cSeq
            SRD->RD_EMPRESA     := aValSRD[1, 3]
            SRD->RD_TIPO2       := "F"
            SRD->RD_MES         := aValSRD[1, 4]
            SRD->RD_STATUS      := aValSRD[1, 5]
            SRD->RD_INSS        := aValSRD[1, 6]
            SRD->RD_IR          := aValSRD[1, 4]
            SRD->RD_FGTS        := aValSRD[1, 8]
            SRD->RD_PROCES      := aValSRD[1, 9]
            SRD->RD_PERIODO     := aAuxSRD[nCont, 3]
            SRD->RD_SEMANA      := aAuxSRD[nCont, 4]
            SRD->RD_ROTEIR      := aValSRD[1, 10]
            SRD->RD_DTREF       := aAuxSRD[nCont, 8]
            SRD->RD_VALORBA     := aValSRD[1, 11]
            SRD->RD_CC          := aAuxSRD[nCont, 5]
            If lItemClvl
                SRD->RD_ITEM    := aAuxSRD[nCont, 6]
                SRD->RD_CLVL    := aAuxSRD[nCont, 7]
            EndIf
            If lSeqMV
                SRD->RD_SEQMV       := aValSRD[1, 12]
            EndIf
            SRD->( MsUnlock() )
            aAdd( aLogUPD[1], "----- Lançamento abaixo foi incluído:"  )
            aAdd( aLogUPD[1], "----- Período: " + SRD->RD_PERIODO  + " | Verba: " + SRD->RD_PD + " | Data: " + dToC(SRD->RD_DATPGT) + " | CC: " + SRD->RD_CC + " | Valor: " + cValToChar(SRD->RD_VALOR) + " | Seq. : " + SRD->RD_SEQ + " | Recno : " + cValToChar(SRD->(Recno())) )
        EndIf

    Next nCont

    //Fecha a tabela temporária da query
    (cAliasQry)->( dbCloseArea() )
EndIf

RestArea( aAreaSRD )

Return
