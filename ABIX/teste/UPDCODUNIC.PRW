#INCLUDE "PROTHEUS.CH"

User Function UPDCODUNIC()

Local aButtons  := {}
Local aDupl     := {}
Local aSays     := {}
Local cMsg      := ""
Local lContinua := .F.
Local nOpcA     := 0

Private aLog    := {}
Private aLog2   := {}
Private aTitle  := {}
Private aTitle2 := {}

aAdd(aSays,OemToAnsi( "Este programa tem como objetivo verificar funcion�rios que possuem a mesma matr�cula" ))
aAdd(aSays,OemToAnsi( "para o eSocial (campo RA_CODUNIC) e que, por esse motivo, n�o foi poss�vel enviar" ))
aAdd(aSays,OemToAnsi( "evento de admiss�o." ))
aAdd(aSays,OemToAnsi( "Ao final, ser� apresentado uma lista dos funcion�rios com a matr�cula duplicada e ser�" ))
aAdd(aSays,OemToAnsi( "exibido uma pergunta para confirmar a corre��o nas matr�culas."))
aAdd(aSays,OemToAnsi( "Ap�s a corre��o no cadastro do funcion�rio, ser� efetuado integra��o ao TAF e o"))
aAdd(aSays,OemToAnsi( "evento de admiss�o ficar� pendente para transmiss�o ao governo."))

aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(), FechaBatch(), nOpcA := 0 ) }} )
aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

//Abre a tela de processamento
FormBatch( "Verifica��o matr�cula eSocial", aSays, aButtons )

//Efetua o processamento de gera��o
If nOpcA == 1
    Aadd( aTitle, OemToAnsi( "Funcion�rios que possuem matr�cula duplicada:" ) )
    Aadd( aLog, {} )
    ProcGpe( {|lEnd| fVerifica(@aDupl)},,,.T. )
    If Empty(aDupl)
        MsgInfo( "N�o foi encontrado funcion�rios com matr�cula duplicada." )
    Else
        fMakeLog(aLog,aTitle,,,"UPDCODUNIC_VERIFICACAO",OemToAnsi("Log de Ocorr�ncias"),"M","P",,.F.)
        IF MsgYesNo( "Deseja efetuar corre��o na matr�cula dos funcion�rios?" )
            Aadd( aTitle2, OemToAnsi( "Funcion�rios que tiveram matr�cula corrigida:" ) )
            Aadd( aLog2, {} )
            Aadd( aTitle2, OemToAnsi( "Trabalhadores que precisam ser exclu�dos no TAF:" ) )
            Aadd( aLog2, {} )
            ProcGpe( {|lEnd| fCorrige(aDupl)},,,.T. )
            MsgInfo( "� necess�rio acessar o m�dulo TAF, acessar a rotina Cadastro Trabalhador (Atualiza��es / Eventos Esocial / Trabalhador) e efetuar a exclus�o manual dos trabalhadores exibidos no log a seguir!" )
            fMakeLog(aLog2,aTitle2,,,"UPDCODUNIC_CORRECAO",OemToAnsi("Log de Ocorr�ncias"),"M","P",,.F.)
        EndIf
    EndIf
EndIf

Return

/*/{Protheus.doc} fVerifica
Fun��o que verifica os funcion�rios que possuem matr�cula duplicada
/*/
Static Function fVerifica( aDupl )

Local aCPF          := {}
Local aMatricDup    := {}
Local cAliasQry     := GetNextAlias()
Local cCateg        := fSqlIn( StrTran(fCatTrabEFD("TCV"), "|" , ""), 3 )//"101|102|103|104|105|106|111|301|302|303|306|307|309|"
Local cUltCPF       := ""
Local cWhere        := ""
Local nCont         := 0
Local nTamanho      := TamSx3("RA_CODUNIC")[1]

cWhere += "RA_CODUNIC != '" + Space(nTamanho) + "' AND "
cWhere += "RA_CATEFD IN (" + cCateg + ") AND "
cWhere += "D_E_L_E_T_ = ' ' "
cWhere += "GROUP BY RA_CODUNIC HAVING COUNT(*) > 1"

//Prepara a vari�vel para uso no BeginSql
cWhere := "%" + cWhere + "%"

//Processa a query e cria a tabela tempor�ria com os resultados
BeginSql alias cAliasQry
	SELECT RA_CODUNIC
    FROM %table:SRA% SRA
	WHERE %exp:cWhere%
EndSql 

SRA->( dbSetOrder( RetOrdem("SRA", "RA_CODUNIC+RA_FILIAL") ) )

While (cAliasQry)->( !EoF() )    
    aCPF := {}
    //Posiciona na tabela SRA
    If SRA->( dbSeek( (cAliasQry)->RA_CODUNIC ) )
        While SRA->( !EoF() .And. SRA->RA_CODUNIC == (cAliasQry)->RA_CODUNIC )
            If aScan( aCPF, { |x| x[2] == SRA->RA_CIC } ) == 0
                aAdd( aCPF, { SRA->RA_CODUNIC, SRA->RA_CIC, SRA->RA_FILIAL, SRA->RA_MAT, SRA->(Recno()) } )
            EndIf
            SRA->( dbSkip() )
        EndDo
    EndIf

    If Len(aCPF) > 1
        For nCont := 1 To Len(aCPF)
            //Adiciona no log de ocorr�ncias
            aAdd( aLog[1], "RA_CODUNIC: " + aCPF[nCont, 1] + " |  Filial: " + aCPF[nCont, 3] + "  -  Matr�cula: " + aCPF[nCont, 4] + " -  CPF: " + aCPF[nCont, 2] )
        Next nCont
        aAdd( aDupl, aClone(aCPF) )
    EndIf
   
    //Pula para o pr�ximo registro
    (cAliasQry)->( dbSkip() )
EndDo

//Fecha a tabela tempor�ria da query
(cAliasQry)->( dbCloseArea() )

Return

/*/{Protheus.doc} fCorrige
Fun��o que ajusta a matr�cula do funcion�rio
/*/
Static Function fCorrige( aDupl )

Local aErros        := {}
Local cCodUnic      := ""
Local cC9VFil       := ""
Local cC9VId        := ""
Local cBkpFil       := cFilAnt
Local cUltCodUni    := ""
Local cVersEnvio    := ""
Local cVersGPE      := ""
Local lIntegra      := .F.
Local lRet          := .F.
Local nCont         := 0
Local nContRA       := 0

For nCont := 1 To Len(aDupl)
    For nContRA := 1 To Len(aDupl[nCont])
        //Posiciona na filial do funcion�rio
        cFilAnt := aDupl[nCont, nContRA, 3]
        //Se status no TAF for diferente de 4
        If TAFGetStat( "S-2200", aDupl[nCont, nContRA, 2] + ";" + aDupl[nCont, nContRA, 1] ) != "4"
            cC9VFil := C9V->C9V_FILIAL
            cC9VId  := C9V->C9V_ID
            //Posiciona no registro f�sico da tabela SRA
            SRA->( dbGoTo(aDupl[nCont, nContRA, 5]) )
            //Carrega o conte�do da tabela para a mem�ria 
            RegToMemory("SRA",,,.F.)  
            //Gera nova matricula
            cCodUnic  := fRACodUnic()
            //Verifica vers�o do layout
            lIntegra := Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2200", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio,@cVersGPE ), .T.)
            //Integra novo trabalhador ao TAF
            If lIntegra
                lRet := fIntAdmiss("SRA", Nil, Nil, "S2200", Nil, Nil, cCodUnic, Nil, "ADM", @aErros, cVersEnvio)
            EndIf 
            //Adiciona o funcion�rio no log de processamento
            If lRet        
                //Adiciona no log de ocorr�ncias
                aAdd( aLog2[1], "- Filial: " + SRA->RA_FILIAL + " - Matr�cula: " + SRA->RA_MAT + " - RA_CODUNIC antigo: " + SRA->RA_CODUNIC + "  -  novo: " + cCodUnic )
                aAdd( aLog2[2], "- Filial: " + cC9VFil + "  -  ID: " + cC9VId )
                //Trava o registro na SRA para edi��o
                If SRA->( RecLock("SRA", .F.) )  
                    SRA->RA_CODUNIC := cCodUnic
                    //Libera o registro da SRA
                    SRA->( MsUnlock() )
                EndIf
            Else
                //Adiciona no log de ocorr�ncias
                aAdd( aLog2[1], "- Filial: " + SRA->RA_FILIAL + "  -  Matr�cula: " + SRA->RA_MAT )
                aAdd( aLog2[1], "  Erro na integra��o com o TAF. Matr�cula n�o ser� corrigida." )
            EndIf
        EndIf
    Next nContRA
Next nCont

cFilAnt := cBkpFil

Return