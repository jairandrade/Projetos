#include "totvs.ch"

/*/{Protheus.doc} TCCO02KM
Funcao responsável pela abertura da tela de EPI x Fornecedor
@type  User Function
@author Kaique Sousa
@since 18/07/2019
@version 1.0
/*/

User Function TCCO02KM()

    Local aButtons      := {}
    Local oGetForn
    Local cNomeFor      := ""
    Local oSayForn
    Local _nOpcA        := 0
    Private _aHeadSD1   := aClone(aHeader)
    Private _aColsSD1   := aClone(aCols)
    Private aHeader     := {}
    Private aCols       := {}
    Private cCadastro 	:= 'EPI x Fornecedor'
    Private lSigaMdtPS  := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .T. , .F. )
    Private cSeekTN3    := ""
    //Variaveis de tamanho de tela e objetos
    Private aSize       := MsAdvSize(,.F.,430)
    Private aObjects    := {}
    Static _oDlg

    Aadd(aObjects,{030,030,.T.,.T.})
    Aadd(aObjects,{100,100,.T.,.T.})
    aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
    aPosObj := MsObjSize(aInfo, aObjects,.T.)

    DbSelectArea("SA2")
    SA2->(DbSetOrder(1))
    SA2->(MsSeek(xFilial("SA2")+cA100For+cLoja))
    cNomeFor	:= SA2->A2_NOME
    cSeekTN3    := xFilial("TN3")+SA2->A2_COD+SA2->A2_LOJA

    DEFINE MSDIALOG _oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd Pixel

    @ 040, 006 SAY oSayForn PROMPT "Fornecedor:" SIZE 033, 007 OF _oDlg COLORS 0, 16777215 PIXEL
    @ 038, 044 MSGET oGetForn VAR cNomeFor SIZE 163, 010 WHEN .F. OF _oDlg COLORS 0, 16777215 PIXEL

    fGetDados()

    ACTIVATE MSDIALOG _oDlg CENTERED ON INIT EnchoiceBar(_oDlg, {||If(oMSNewGe1:TudoOk(),(_nOpcA := 1,_oDlg:End()),Nil)}, {|| _nOpcA := 0,  _oDlg:End()},,aButtons)

    If(_nOpcA == 1 ) //Se confirmado gravo na TN3
        Begin Transaction
            lGravaOk := fGravaTN3()
            If !lGravaOk
                Help(" ",1,"NG200NAOREG")
            Endif
        End Transaction
    Else
        Return(.F.)
    EndIf

Return( .T. )

/*/{Protheus.doc} fGravaTN3
Função responsável por gravar os dados na TN3
@type  User Function
@author Kaique Sousa
@since 18/07/2019
@version 1.0
/*/

Static Function fGravaTN3()

    Local i, j    := 0
    Local nCODEPI := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TN3_CODEPI" })
    Local nNUMCAP := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TN3_NUMCAP" })

    aCols := oMSNewGe1:aCols

    For i:=1 To Len(aCols)
        cNumCAP := aCols[i][nNUMCAP]
        //Não gravo se estiver vazio o numero do CA
        If !Empty(cNumCAP)
            If !aCols[i][Len(aCols[i])] .And. !Empty(aCols[i][nCODEPI])
                dbSelectArea("TN3")
                TN3->(dbSetOrder(1))

                If TN3->(dbSeek(cSeekTN3+aCols[i][nCODEPI]+cNumCAP))
                    RecLock("TN3",.F.)
                Else
                    RecLock("TN3",.T.)
                Endif

                For j:=1 to FCount()
                    If "_FILIAL"$Upper(FieldName(j))
                        FieldPut(j, xFilial("TN3"))
                    ElseIf "_FORNEC"$Upper(FieldName(j))
                        FieldPut(j, SA2->A2_COD)
                    ElseIf "_LOJA"$Upper(FieldName(j))
                        FieldPut(j, SA2->A2_LOJA)
                    ElseIf "_XDOC"$Upper(FieldName(j))
                        FieldPut(j, cNFISCAL)
                    ElseIf "_XSERIE"$Upper(FieldName(j))
                        FieldPut(j, cSerie)
                    Else
                        If (nPos := aScan(aHeader, {|x| AllTrim(Upper(x[2])) == AllTrim(Upper(FieldName(j))) })) > 0
                            FieldPut(j, aCols[i][nPos])
                        Endif
                    Endif
                Next j
                MsUnlock("TN3")
            Endif
        EndIf
    Next i

    dbSelectArea("SA2")

Return( .T. )

/*/{Protheus.doc} fGetDados
Função responsavel por montar as linhas da grid
@type function
@version 12.1.25
@author Kaique Mathias
@since 5/7/2020
@return Nil, Nil
/*/

Static Function fGetDados()

    Local nX,nK,nU := 0
    Local _nPosCod := aScan(_aHeadSD1,{|x| Alltrim(x[2])=="D1_COD"})
    Local _nPosDesc:= aScan(_aHeadSD1,{|x| Alltrim(x[2])=="D1_DESCRI"})
    Local _nPosQtd := aScan(_aHeadSD1,{|x| Alltrim(x[2])=="D1_QUANT"})
    Local aAux     := {}       
    Local aFields       := {;
        "TN3_CODEPI",;
        "TN3_DESC",;
        "TN3_GENERI",;
        "TN3_NUMCAP",;
        "TN3_DTVENC",;
        "TN3_DURABI",;
        "TN3_INDEVO",;
        "TN3_DTAVAL",;
        "TN3_NUMCRF",;
        "TN3_NUMCRI",;
        "TN3_OBSAVA",;
        "TN3_TIPEPI",;
        "TN3_AREEPI",;
        "TN3_PERMAN",;
        "TN3_TPDURA",;
        "TN3_DTVALI";
        }
    Local aAlterFields  := {;
        "TN3_NUMCAP",;
        "TN3_DTVENC",;
        "TN3_NUMCRF",;
        "TN3_NUMCRI",;
        "TN3_OBSAVA",;
        "TN3_DTVALI",;
        "TN3_TPDURA";
        }
    Static oMSNewGe1

    dbSelectArea("TN3") 
    dbSetOrder(1)

    aAux := FwSX3Util():GetAllFields("TN3",.T.)

    For nX := 1 to Len(aFields)
        If ( aScan(aAux,{ |x| Alltrim(x) == aFields[nX] }) > 0 )
            Aadd(aHeader, { FwSX3Util():GetDescription(aFields[nX]),;
                aFields[nX],;
                X3PICTURE(aFields[nX]),;
                TamSX3(aFields[nX])[1],;
                TamSX3(aFields[nX])[2],;
                GetSx3Cache(aFields[nX], "X3_VALID"),;
                GetSx3Cache(aFields[nX], "X3_USADO"),;
                FwSX3Util():GetFieldType(aFields[nX]),;
                " ",;
                GetSx3Cache(aFields[nX], "X3_CONTEXT"),;
                X3CBOX(aFields[nX]),;
                GetSx3Cache(aFields[nX], "X3_RELACAO")})
        Endif
    Next nX

    dbSelectArea("SB1")
    SB1->(dbSetOrder(1))

    For nX := 1 to len(_aColsSD1)
        If SB1->(MSSeek(xFilial("SB1")+_aColsSD1[nX][_nPosCod]))
            If ( SB1->B1_TIPO == "ES" )
                nQtd := int(_aColsSD1[nX][_nPosQtd])
                For nU := 1 to nQtd
                    aAdd(aCols,Array(Len(aHeader)+1))
                    aCols[Len(aCols)][Len(aHeader)+1] := .F.
                    For nK := 1 to len(aHeader)
                        If "_CODEPI"$Upper(aHeader[nK][2])
                            aCols[Len(aCols)][nK] := _aColsSD1[nX][_nPosCod]
                        ElseIf "_DESC"$Upper(aHeader[nK][2])
                            aCols[Len(aCols)][nK] := _aColsSD1[nX][_nPosDesc]
                        ElseIf "_GENERI"$Upper(aHeader[nK][2])
                            aCols[Len(aCols)][nK] := SB1->B1_XGENER
                        ElseIf "_DURABI"$Upper(aHeader[nK][2])
                            aCols[Len(aCols)][nK] := SB1->B1_XDIAUTI
                        ElseIf "_INDEVO"$Upper(aHeader[nK][2])
                            aCols[Len(aCols)][nK] := SB1->B1_XDEVOLV
                        ElseIf "_DTAVAL"$Upper(aHeader[nK][2])
                            aCols[Len(aCols)][nK] := dDataBase//SD1->D1_DTDIGIT
                        ElseIf "_TIPEPI"$Upper(aHeader[nK][2])
                            aCols[Len(aCols)][nK] := SB1->B1_XTPEPI
                        ElseIf "_AREEPI"$Upper(aHeader[nK][2])
                            aCols[Len(aCols)][nK] := "DEPENDENCIAS DA EMPRESA"
                        ElseIf "_PERMAN"$Upper(aHeader[nK][2])
                            aCols[Len(aCols)][nK] := SB1->B1_XDIAMAN
                        ElseIf "_TPDURA"$Upper(aHeader[nK][2])
                            aCols[Len(aCols)][nK] := "U"
                        Else
                            aCols[Len(aCols)][nK] := CriaVar(aHeader[nK][2],.T.)
                        EndIf
                    Next nK
                Next nU
            EndIf
        EndIf

    Next nX

    oMSNewGe1 := MsNewGetDados():New( 058, 006, aPosObj[2,3],aPosObj[2,4], GD_UPDATE, "U_TCO02LOk", "U_TCO02Tok", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", _oDlg, aHeader, aCols)

Return( Nil )

/*/{Protheus.doc} TCO02LOk
Função responsável por criticar se a linha digitada esta ok
@type  User Function
@author Kaique Sousa
@since 18/07/2019
@version 1.0
/*/

User Function TCO02LOk()

    Local nX        := 1
    Local lGener    := .F. // Indica a obrigatoriedade do campo TN3_NUMCAP
    Local lRet      := .T.

    nCODEPI := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TN3_CODEPI" })
    nDTAVAL := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TN3_DTAVAL" })
    nDTVENC := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TN3_DTVENC" })
    nDURABI := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TN3_DURABI" })
    nTPDURA := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TN3_TPDURA" })
    nNUMCAP := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TN3_NUMCAP" })

    If !Empty(aCols[n][nDTVENC]) .And. !Empty(aCols[n][nDTAVAL]) .And. aCols[n][nDTAVAL] > aCols[n][nDTVENC]
        msgStop("A data de avaliação do EPI precisa menor ou igual à data de vencimento.")
        Return .F.
    Endif

    //Obriga campo de produto
    If Empty(aCols[n][nCODEPI]) .And. !aCols[n,Len(aCols[n])]
        Help(1," ","OBRIGAT2",,aHeader[nCODEPI][1],3,0)
        Return .F.
    Endif

    //Verifica o preenchimento do campo TN3_GENERI
    If NGCADICBASE("TN3_GENERI","D","TN3",.F.)
        nGENERI := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TN3_GENERI" })
        If Empty(aCols[n][nGENERI]) .And. !aCols[n,Len(aCols[n])]
            ShowHelpDlg("ATENÇÃO",{"O campo 'Generico ?' está em branco."},1,;
                {"Preencha o campo para prosseguir os cadastros."},1) //"Preencha o campo para prosseguir os cadastros."
            Return .F.
        ElseIf aCols[n][nGENERI] == '2'
            lGener := .T.
        EndIf
    EndIf

    cCodEPI := aCols[n][nCODEPI]
    cNumCA  := aCols[n][nNUMCAP]

    //Somente obriga o preenchimento de novos registros
    //If nNUMCAP > 0
    //If !aCols[n,Len(aCols[n])] .And. !lGener
    For nX := 1 to len(aCols)
        If ( aCols[ nX , nCODEPI ] == cCodEPI ) //.And. ( aCols[nX][nNUMCAP] == cNumCA )
            If !Empty(aCols[nX][nNUMCAP]) //Saio da validação se tiver preenchido
                Exit
            ElseIf Empty( aCols[ n , nNUMCAP ] )
                Help(1," ","OBRIGAT2",,aHeader[nNUMCAP][1],3,0)
                Return ( .F. )
            Endif
        EndIf
    Next nX
    //Endif
    //Endif

    If nDURABI > 0 .Or. nTPDURA > 0
        If !aCols[n,Len(aCols[n])]
            If nTPDURA > 0
                If aCols[n,nDURABI] > 0
                    If (aCols[n,nTPDURA] <> "U" .And. aCols[n,nTPDURA] <> "G")
                        MsgStop("Favor informar o tipo de Durabilidade do EPI.")
                        Return .F.
                    EndIf
                Endif
            Endif
        Endif
    Endif

Return( lRet )

/*/{Protheus.doc} TCO02TOK
Validação do TudoOk da GetDados dos EPI's
@type function
@version 12.1.25
@author Kaique Mathias
@since 5/7/2020
@return logical, .T. or .F.
/*/

User Function TCO02TOK()

    LOCAL nY:= 1
    LOCAL n := 1

    For nY := 1 to len(aCols)
        n := nY
        If !U_TCO02LOk()
            Return(.f.)
        EndIf
    Next nY

Return( .T. )