#include "totvs.ch"

/*/{Protheus.doc} TCPGED
Amarração de entidade x Documentos 
@type user function
@version 1.0
@author Kaique Mathias
@since 02/07/2020
@param cAlias, character, param_description
@param nReg, numeric, param_description
@param nOpc, numeric, param_description
@param xVar, param_type, param_description
@param nOper, numeric, param_description
@param aRecACB, array, param_description
@param lExcelConnect, logical, param_description
@return return_type, return_description
/*/

User Function TCPGED( cAlias, nReg, nOpc, xVar, nOper, aRecACB , lExcelConnect)

    Local aArea       := GetArea()
    Local aAreaEnt    := {}
    Local oModal      := Nil
    Local oPanel      := Nil
    Local oLayer      := Nil
    Local oDocumentos := Nil
    Local aRecAC9      := {}
    Local aGet		   := {}
    Local aTravas      := {}
    Local aEntidade    := {}
    Local aArea        := GetArea()
    Local aExclui      := {}
    Local aChave       := {}
    Local cCodEnt      := ""
    Local cCodDesc     := ""
    Local cNomEnt      := ""
    Local cEntidade    := ""
    Local cUnico       := ""
    Local lMTCONHEC    := ExistBlock('MTCONHEC')
    Local lTravas      := .T.
    Local lVisual      := .T. //( aRotina[ nOpc, 4 ] == 2 )
    Local lAchou       := .F.
    Local lRetCon      := .T.
    Local lRet		   := .T.
    Local nCntFor      := 0
    Local nScan        := 0
    Local oGetD
    Local oOle
    Local cQuery        := ""
    Local cSeek         := ""
    Local cWhile        := ""
    Local aNoFields     := {"AC9_ENTIDA","AC9_CODENT"}									      // Campos que nao serao apresentados no aCols
    Local bCond         := {|| .T.}														      	// Se bCond .T. executa bAction1, senao executa bAction2
    Local bAction1      := {|| MSVERAC9(@aTravas,@aRecAC9,@aRecACB,lTravas,nOper,nOpc,.F.) }	// Retornar .T. para considerar o registro e .F. para desconsiderar
    Local bAction2      := {|| .F. }															      // Retornar .T. para considerar o registro e .F. para desconsiderar
    Local lVisPE	    := lVisual															      // Retornar .T. para considerar o registro e .F. para desconsiderar
    Local aFieldsAC9    := {}
    Local nPos          := 0
    DEFAULT aRecAC9    		:= {}
    DEFAULT aRecACB    		:= {}
    DEFAULT nOper      		:= 1
    DEFAULT lExcelConnect	:= .F.

    PRIVATE aCols      := {}
    PRIVATE aColsSPE   := {}
    PRIVATE aHeader    := {}
    PRIVATE INCLUI     := .F.
    PRIVATE lFilAcols  := .F.

    SaveInter()

    If ExistBlock("CXF0001")
        U_CXF0001(@cAlias,@nReg)
    EndIf

    If ExistBlock("MTVLDACE")
        lRet := ExecBlock("MTVLDACE",.F.,.F.)
        If ValType(lRetCon) <> "L"
            lRet := .T.
        EndIf
        If !lRet
            Return .F.
        EndIf
    EndIf

    If lMTCONHEC
        lRetCon := ExecBlock('MTCONHEC', .F., .F.)

        If ValType(lRetCon) <> "L"
            lRetCon := .T.
        EndIf

    EndIf

    cEntidade := IIF(Len(cAlias) == 3, cAlias, Substr(cAlias,0,3))

    dbSelectArea( cEntidade )
    dbGoto( nReg )

    aEntidade := U_TCPGEDENT( cEntidade )

    lAchou := len(aEntidade) > 0

    If lAchou

        cCodEnt  := aEntidade[1]
        cCodDesc := aEntidade[2]

        cCodEnt  := PadR( cCodEnt, TamSX3("AC9_CODENT")[1] )

        dbSelectArea("AC9")
        dbSetOrder(2)

        cQuery += "SELECT AC9.*,AC9.R_E_C_N_O_ AC9RECNO FROM " + RetSqlName( "AC9" ) + " AC9 "
        cQuery += "WHERE "
        cQuery += "AC9_FILIAL='" + xFilial( "AC9" )     + "' AND "
        cQuery += "AC9_FILENT='" + xFilial( cEntidade ) + "' AND "
        cQuery += "AC9_ENTIDA='" + cEntidade            + "' AND "
        cQuery += "AC9_CODENT='" + cCodEnt              + "' AND "
        cQuery += "D_E_L_E_T_<>'*' ORDER BY " + SqlOrder( AC9->( IndexKey() ) )

        cSeek  := cEntidade + xFilial( cEntidade ) + cCodEnt
        cWhile := "AC9->AC9_FILIAL + AC9->AC9_ENTIDA + AC9->AC9_FILENT + AC9->AC9_CODENT"

        Do Case
        Case nOper == 1

            cNomEnt := Capital( FwSX2Util():GetX2Name( cEntidade ) )

            aadd(aGet,{ FWSX3Util():GetDescription( "AA2_CODTEC" ),;
                        GetSx3Cache("AA2_CODTEC", "X3_PICTURE"),;
                        GetSx3Cache("AA2_CODTEC", "X3_F3")})

            aFieldsAC9 := FwSX3Util():GetAllFields("AC9")

            For nPos := 1 to len(aFieldsAC9)
                If( FWSX3Util():GetFieldType( aFieldsAC9[nPos] ) == "M" .And.; 
                    GetSx3Cache( aFieldsAC9[nPos] , "X3_CONTEXT") == "V" .Or.; 
                    aFieldsAC9[nPos] == "AC9_PRVIEW" )
                    Aadd(aNoFields,aFieldsAC9[nPos])
                EndIf
            Next nPos

            dbSelectArea("AC9")
            dbSetOrder(2)
            dbGoTop()

            FillGetDados(nOpc,"AC9",2,cSeek,{|| &cWhile },{{bCond,bAction1,bAction2}},aNoFields,/*aYesFields*/,/*lOnlyYes*/,cQuery,/*bMontCols*/,/*Inclui*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bBeforeCols*/)

            bAction1 := {|| MsVerAC9(@aTravas,@aRecAC9,@aRecACB,lTravas,nOper,nOpc,.T.) }
            aColsSPE := aClone(aCols)
            aCols	:= {}
            aHeader	:= {}
            aTravas	:= {}
            aRecACB := {}
            aRecAC9 := {}

            FillGetDados(nOpc,"AC9",2,cSeek,{|| &cWhile },{{bCond,bAction1,bAction2}},aNoFields,/*aYesFields*/,/*lOnlyYes*/,cQuery,/*bMontCols*/,/*Inclui*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bBeforeCols*/)

            If Len(aColsSPE) > Len(aCols)
                lFilAcols := .T.
            Endif

            If ( lTravas )

                lVisual := ( aRotina[ nOpc, 4 ] == 2 )

                If !lVisual .And. ExistBlock("MSDOCVIS")
                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³ MSDOCVIS - Ponto de Entrada utilizado para somente visualizar o Conhecimento  |
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    lVisual := If(ValType(lVisual:=ExecBlock("MSDOCVIS",.F.,.F.))=='L',lVisual,.F.)
                EndIf

                INCLUI  := .T.

                lVisPE	:= lVisual

                If ExistBlock("MSDOCEXC") .AND. lVisual = .F.
                    lVisPE := iF(ValType(lretu:=ExecBlock("MSDOCEXC",.F.,.F.))=='L',lRetu,lVisual)
                EndIf

                oModal := FWDialogModal():New()
                oModal:SetEscClose(.T.)				//Permite fechar a tela com o ESC
                oModal:SetBackground(.T.)			//Escurece o fundo da janela
                oModal:SetTitle("TCP - Gestão Eletrônica de Documentos - Entidade: " + Alltrim(cNomEnt) + " - Identificação: " + cCodDesc )			//"Base de Conhecimento"
                oModal:enableAllClient()
                oModal:EnableFormBar(.T.)
                oModal:CreateDialog()
                oModal:CreateFormBar()				//Cria barra de botoes
                oModal:AddButton( "Salvar", {|| If( oGetD:TudoOk(), ( TCPGEDGRV(cEntidade,cCodEnt,aRecAC9,lFilAcols), TCPEXCTMP( aExclui ), oModal:oOwner:End() ) , Nil) }, "Salvar", , .T., .F., .T., )
                oModal:AddButton( "Anexar", {|| TCPGEDANEX( @oGetD )  }, "Anexar", , .T., .F., .T. )
                oModal:AddButton( "Baixar", {|| If( !Empty( AllTrim( GDFieldGet( "AC9_OBJETO" ) ) ), ( oGetd:oBrowse:SetFocus(), TCPSAVEFILE( @oGetD, .F. ) ), .T. )	}, "Baixar", , .T., .F., .T. )
                oModal:AddButton( "Baixar Todos", {|| If( !Empty( AllTrim( GDFieldGet( "AC9_OBJETO" ) ) ), ( oGetd:oBrowse:SetFocus(), TCPSAVEFILE( @oGetD,.T. ) ), .T. )	}, "Baixar Todos", , .T., .F., .T. )
                oModal:AddButton( "Abrir", {|| If( !Empty( AllTrim( GDFieldGet( "AC9_OBJETO" ) ) ), ( oGetd:oBrowse:SetFocus(), MsDocOpen( @oOle, @aExclui ) ), .T. )  }, "Abrir", , .T., .F., .T. )
                oModal:AddButton( "Fechar", {|| oModal:oOwner:End() }, "Fechar", , .T., .F., .T., )

                //oModal:addExitPageButton({|| oModal:oOwner:End() },{|| If( oGetD:TudoOk(), ( TCPGEDGRV(cEntidade,cCodEnt,aRecAC9,lFilAcols), TCPEXCTMP( aExclui ), oModal:oOwner:End() ) , Nil) },{||})
                //oModal:AddCloseButton()

                oPanel := oModal:GetPanelMain()

                oLayer := FwLayer():New()
                oLayer:Init(oPanel, .F.)

                oLayer:AddCollumn("COLUNA2", 100, .F.,)

                oLayer:AddWindow("COLUNA2", "WINDOW3", "Documentos", 100, .F., .F., {|| .T.},  , {|| .T.})	//"Documentos"

                oDocumentos := oLayer:getWinPanel("COLUNA2", "WINDOW3", )

                oGetd :=     MSGetDados():New(  000,;
                    000,;
                    200,;
                    300,;
                    nOpc,;
                    "U_TCPGEDLOK",;
                    "AlwaysTrue",;
                    ,;
                    !lVisPE,;
                    NIL,;
                    NIL,;
                    NIL,;
                    1000,;
                    NIL,;
                    NIL,;
                    NIL,;
                    NIL,;
                    oDocumentos)

                oGetd:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

                n := 1

                oModal:Activate()

                If Len(aAreaEnt) > 0
                    RestArea(aAreaEnt)
                EndIf

                RestArea(aArea)

            EndIf

            If ( __lSx8 )
                RollBackSx8()
            EndIf
            For nCntFor := 1 To Len(aTravas)
                dbSelectArea(aTravas[nCntFor][1])
                dbGoto(aTravas[nCntFor][2])
                MsUnLock()
            Next nCntFor

        Case nOper == 3
            MsDocGrv( cEntidade, cCodEnt, , .T. )
        Case nOper == 4
            MsDocArray( cEntidade, cCodEnt, , , , ,@aRecACB )
        EndCase
    Else
        If( nOper == 1 )
            Aviso( "Atencao !", "Nao existe chave de relacionamento definida para o alias " + cAlias, { "Ok" } )
        EndIf
    EndIf

Return( Nil )

/*/{Protheus.doc} MsVerAC9
Funcao disparada para validar cada registro da tabela
AC9, adicionar recno no array aRecAC9 utilizado na gravacao
cao da tabela AC9 e verificar se conseguiu travar AC9.     
Se retornar .T. considera o registro.                      
@type Static function
@version 1.0
@author Marco Bianchi
@since 7/3/2020
@param aTravas, array, param_description
@param aRecAC9, array, param_description
@param aRecACB, array, param_description
@param lTravas, logical, param_description
@param nOper, numeric, param_description
@param nOpc, numeric, param_description
@param lPE, logical, param_description
@return return_type, return_description
/*/

Static Function MsVerAC9(aTravas,aRecAC9,aRecACB,lTravas,nOper,nOpc,lPE)

    Local nTipo 	:= IIf(nOper == 1,2,1)
    Local lRet 		:= .T.
    Local lMsDocFil := Existblock("MSDOCFIL") .And. lPE
    Local nRecNoAC9
    DEFAULT nOpc 	:= 2

    If Valtype("AC9RECNO") == 'N'
        nRecNoAC9 := AC9RECNO
        AC9->( dbGoto( nRecNoAC9 ) )
    EndIf

    If nTipo == 2 .AND. nOpc <> 2
        If ( SoftLock("AC9" ) )
            AAdd(aTravas,{ Alias() , RecNo() })
        Else
            lTravas := .F.
        EndIf
    EndIf

    AAdd(aRecAC9, AC9->( Recno() ) )

    If nTipo == 1
        ACB->( dbSetOrder( 1 ) )
        If ACB->( dbSeek( xFilial( "ACB" ) + AC9->AC9_CODOBJ ) )
            AAdd( aRecACB, ACB->( RecNo() ) )
        EndIf
        lRet := .F.
    EndIf

    If lMsDocFil
        lRet := ExecBlock("MSDOCFIL",.F.,.F.,{AC9->(Recno())})
        If ValType(lRet) <> "L"
            lRet := .T.
        EndIf
    EndIf

Return(lRet)

/*/{Protheus.doc} TCPGEDANEX
Funcao responsavel por realizar a inclusao dos anexos na grid do GED
@type function
@version 1.0
@author Kaique Mathias
@since 03/07/2020
@param oGetDad, object, param_description
@return return_type, return_description
/*/

Static Function TCPGEDANEX( oGetDad )

    Local aColsWiz      := {}
    Local aHeaderWiz    := {}
    Local cObj          := ""
    Local cDescri       := ""
    Local nTamDesc      := 0
    Local lRet          := .T.
    Local nCntFor       := 0
    Local aObj          := {}
    Local lFwSX3Util    := FindFunction( '__FwSX3Util' )
    Local cExten        := ""
    Local aObj          := {}
    Local nI            := 0
    Local aFieldsACC    := {}
    Local nPos          := 0
    
    If Empty( GDFieldGet( "AC9_OBJETO" ) ) .Or. U_TCPGEDLOK()

        TCPGETDOC( @aObj )

        For nI := 1 to len(aObj)

            aHeaderWiz  := {}
            aColsWiz    := {}

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Montagem do aHeaderWiz                                ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            /*While ( !Eof() .And. SX3->X3_ARQUIVO == "ACC" )
                If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
                    Aadd(aHeaderWiz, {   AllTrim(X3Titulo()),;
                        SX3->X3_CAMPO,;
                        SX3->X3_PICTURE,;
                        SX3->X3_TAMANHO,;
                        SX3->X3_DECIMAL,;
                        SX3->X3_VALID,;
                        SX3->X3_USADO,;
                        SX3->X3_TIPO,;
                        SX3->X3_F3,;
                        SX3->X3_CONTEXT,;
                        X3Cbox(),;
                        SX3->X3_RELACAO,;
                        ".T."})
                
                EndIf
                dbSelectArea("SX3")
                dbSkip()
            EndDo*/
            aFieldsACC := FwSX3Util():GetAllFields("ACC")
            For nPos := 1 to len(aFieldsACC)
                Aadd(aHeaderWiz, {   TRIM(FwX3Titulo(aFieldsACC[nPos])),;
                        aFieldsACC[nPos],;
                        GetSx3Cache(aFieldsACC[nPos], "X3_PICTURE"),;
                        GetSx3Cache(aFieldsACC[nPos], "X3_TAMANHO"),;
                        GetSx3Cache(aFieldsACC[nPos], "X3_DECIMAL"),;
                        GetSx3Cache(aFieldsACC[nPos], "X3_VALID"),;
                        GetSx3Cache(aFieldsACC[nPos], "X3_USADO" ),;
                        FWSX3Util():GetFieldType( aFieldsACC[nPos]),;
                        GetSx3Cache(aFieldsACC[nPos], "X3_F3"),;
                        GetSx3Cache(aFieldsACC[nPos], "X3_CONTEXT"),;
                        GetSx3Cache(aFieldsACC[nPos], "X3_CBOX"   ),;
                        GetSx3Cache(aFieldsACC[nPos], "X3_RELACAO"),;
                        ".T."})
            Next nPos
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Montagem do aColsWiz                                  ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            nUsado := Len( aHeaderWiz )

            AAdd(aColsWiz,Array(nUsado+1))
            For nCntFor	:= 1 To nUsado
                aColsWiz[1,nCntFor] := CriaVar(aHeaderWiz[nCntFor,2])
            Next nCntFor
            aColsWiz[1,nUsado+1] := .F.

            cObj    := CriaVar( "ACB_OBJETO", .F. )
            cDescri := CriaVar( "ACB_DESCRI", .F. )
            nTamDesc:= Len( cDescri )

            cObj := Alltrim(UPPER(aObj[nI]))
            M->ACB_OBJETO := cObj
            M->ACB_TAMANH := Ft340Taman( M->ACB_OBJETO )

            SplitPath( cObj,,, @cDescri, @cExten )

            If Len( AllTrim( cDescri ) ) > nTamDesc
                cDescri := Left( cDescri, nTamDesc - 3 ) + "..."
            EndIf

            cDescri := Pad( cDescri, nTamDesc )
            cDescri := Upper( cDescri )

            M->ACB_OBJETO := cObj

            lRet := TCPGEDGBC( @cObj, @cDescri, aHeaderWiz, aColsWiz )

            If lRet

                nUsado := Len( aHeader )

                If !Empty( GDFieldGet( "AC9_OBJETO" ) )
                    AAdd(aCols,Array(nUsado+1))
                EndIf

                For nCntFor := 1 To nUsado
                    If ( aHeader[nCntFor][10] != "V" )
                        aCols[Len(aCols)][nCntFor] := AC9->(FieldGet(FieldPos(aHeader[nCntFor][2])))
                        If ( ExistIni(aHeader[nCntFor][2]) .And. Empty(aCols[Len(aCols)][nCntFor]) ) .Or. (lFwSX3Util .And. FwSX3Util():GetOwner( aHeader[nCntFor][2] ) == 'U')
                            aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
                        Endif
                    Else
                        If AllTrim( aHeader[nCntFor][2] ) == "AC9_OBJETO"
                            aCols[Len(aCols)][nCntFor] := cObj
                        ElseIf AllTrim( aHeader[nCntFor][2] ) == "AC9_DESCRI"
                            aCols[Len(aCols)][nCntFor] := cDescri
                        ElseIf !IsHeadRec( aHeader[nCntFor][2] )  .And. !IsHeadAlias( aHeader[nCntFor][2] )
                            aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
                        EndIf
                    EndIf
                Next

                aCols[Len(aCols)][nUsado+1] := .F.
                n := Len( aCols )
                oGetDad:oBrowse:nAt := N
                oGetDad:oBrowse:Refresh()

            EndIf

            oGetDad:lNewLine := .F.

        Next nI

    EndIf

Return( Nil )

/*/{Protheus.doc} TCPGETDOC
description
@type function
@version 
@author kaiquesousa
@since 7/3/2020
@param aListArq, array, param_description
@param cDescri, character, param_description
@return return_type, return_description
/*/

Static Function TCPGETDOC( aListArq )

    Local cFile         := ""
    Local nI            := 0
    Local cObj          := CriaVar( "ACB_OBJETO", .F. )
    Local lMacOS 	    := .F.
    Local cLibCli	    := ""

    GetRemoteType( @cLibCli )
    lMacOS := Iif('MAC' $ cLibCli,.T.,.F.)
    lLinuxCli := ("linux" $ lower(cLibCli))

    cObj := cGetFile("Todos os arquivos" + "|*.*", "Seleção de arquivo(s)", ,If(IsSrvUnix(),"l:\","c:\"), .F., nOr(GETF_LOCALHARD, GETF_NETWORKDRIVE, GETF_MULTISELECT), ,.F.)

    aListArq := StrTokArr2(cObj, " | ")

    For nI := 1 to len(aListArq)

        cFile := aListArq[nI]
        cFile := Upper(AllTrim(cFile))

        If Left( LTrim( cFile ), 1 ) == "\"
            If( lMacOS )
                aListArq[nI] := "l:" + aListArq[nI]
            EndIf
        EndIf

    Next nI

Return( aListArq )

/*/{Protheus.doc} TCPGEDGRV
Funcão criada para realizar a gravação/exclusão da amarração
@type function
@version 1.0
@author Kaique Mathias
@since 03/07/2020
@param cEntidade, character, param_description
@param cCodEnt, character, param_description
@param aRecAC9, array, param_description
@param lFilAcols, logical, param_description
@return return_type, return_description
/*/

Static Function TCPGEDGRV(cEntidade,cCodEnt,aRecAC9,lFilAcols)

    Begin Transaction
        lGravou := MSDOCGRV( cEntidade, cCodEnt, aRecAC9 , , lFilAcols )
        If ( lGravou )
            EvalTrigger()
            If ( __lSx8 )
                ConfirmSx8()
            EndIf
            If ExistBlock( "MSDOCOK" )
                ExecBlock("MSDOCOK",.F.,.F.,{cAlias, nReg})
            EndIf
        EndIf
    End Transaction

Return( lGravou )

/*/{Protheus.doc} TCPSAVEFILE
Realiza o download do documento para a maquina local
@type user function
@version 1.0
@author Kaique Mathias
@since 03/07/2020
@param cPath, character, param_description
@return return_type, return_description
/*/

Static Function TCPSAVEFILE( oGetD, lAll )

    Local cOper     as char
    Local cFileName as char
    Local cParam    as char
    Local cDir      as char
    Local cDrive    as char
    Local nRet      as numeric
    Local lRemotLin	as logical
    Local aAppExt	as array
    Local nCont		as numeric
    Local cExten	as char
    Local lHtml 	as logical
    Local cFunction as char
    Local lTipOS	as logical
    Local cLib 		as char
    Local nX        as numeric
    Default lAll := .F.

    cOper     := "open" // "print", "explore
    cFileName := ""
    cParam    := ""
    cDir      := ""
    cDrive    := ""
    nRet      := 0
    lRemotLin	:= GetRemoteType() == 2 //Checa se o Remote e Linux
    aAppExt	:=	{}
    nCont		:= 0
    cExten	:= ''
    lHtml := GetRemoteType() == REMOTE_HTML
    cFunction := 'CpyS2TW'
    lTipOS	  := .F.

    GetRemoteType( @cLib )
    lTipOS := iif ('MAC' $ cLib, .t.,.f.)

    cGetPath := cArq := cGetFile( '*.*' , 'Selecione a pasta', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )

    If( Empty( cGetPath ) )
        Return( .F. )
    EndIf

    If( lAll )
        nAux := n
        For nX := 1 to len(aCols)

            n := nX

            If !lRemotLin .or. lTipOS
                If !lHtml
                    cFileName := cGetPath + AllTrim( GDFieldGet( "AC9_OBJETO" ) )
                Else
                    cFileName := MsDocPath() + "\" + AllTrim( GDFieldGet( "AC9_OBJETO" ) )
                EndIf
            Else
                If !lHtml
                    cFileName := cGetPath + StrTran(Lower(AllTrim(GDFieldGet("AC9_OBJETO" )))," ","_")
                Else
                    cFileName := MsDocPath() + "\" + StrTran(Lower(AllTrim(GDFieldGet("AC9_OBJETO" )))," ","_")
                EndIf
            EndIf

            If !Empty(cFileName)

                If GDFieldGet( "AC9_PRVIEW" ) <> "1"
                    //Função para transferir documento para Temp
                    TCPDOWDOC( cGetPath , .F. )
                EndIf

                SplitPath(cFileName, @cDrive, @cDir )

                If IsSrvUnix() .And. GetRemoteType() == 1
                    cDir := StrTran(cDir,"/","\")
                Endif

            Endif

        Next nX
    Else

        If !lRemotLin .or. lTipOS
            If !lHtml
                cFileName := cGetPath + AllTrim( GDFieldGet( "AC9_OBJETO" ) )
            Else
                cFileName := MsDocPath() + "\" + AllTrim( GDFieldGet( "AC9_OBJETO" ) )
            EndIf
        Else
            If !lHtml
                cFileName := cGetPath + StrTran(Lower(AllTrim(GDFieldGet("AC9_OBJETO")))," ","_")
            Else
                cFileName := MsDocPath() + "\" + StrTran(Lower(AllTrim(GDFieldGet("AC9_OBJETO")))," ","_")
            EndIf
        EndIf

        If !Empty(cFileName)

            If GDFieldGet( "AC9_PRVIEW" ) <> "1"
                //Função para transferir documento para Temp
                TCPDOWDOC( cGetPath , .F. )
            EndIf

            SplitPath(cFileName, @cDrive, @cDir )

            If IsSrvUnix() .And. GetRemoteType() == 1
                cDir := StrTran(cDir,"/","\")
            Endif

        Endif

    EndIf

Return( .T. )

/*/{Protheus.doc} TCPDOWDOC
Função criada para transmitir o documento do servidor para a maquina local
@type user function
@version 1.0
@author Kaique Mathias
@since 03/07/2020
@param cPath, character, param_description
@return return_type, return_description
/*/

Static Function TCPDOWDOC( cPath )

    Local	lRemotLin:= GetRemoteType() == 2
    Local   lCopied  := .F.
    Local   cDirDocs := ""
    Local   cFile    := AllTrim( GDFieldGet( "AC9_OBJETO" ) )

    lAbre    := .T.

    If MsMultDir()
        cDirDocs := MsRetPath( cFile )
    Else
        cDirDocs := MsDocPath()
    Endif

    cDirDocs  := MsDocRmvBar( cDirDocs )
    cPathFile := cDirDocs + "\" + cFile

    //cPath := GetTempPath()

    cPathTerm := cPath + cFile

    If File( cPathTerm )

        lAbre := .F.

        If GDFieldGet( "AC9_PRVIEW" ) <> "1"
            nOpc := Aviso( "Atencao!", "O arquivo '" + Capital( cFile ) + "' ja existe em sua area de trabalho. Qual a acao a ser efetuada ?", { "Sobrepor", "Cancelar" }, 2 )

            If nOpc == 1
                lAbre := .T.
                fErase(cPathTerm)
            EndIf
        Else
            lAbre   := .T.
            lCopied := .T.
        EndIf

    EndIf

    If lAbre
        If !lCopied
            cPathFile := Lower(cPathFile)
            cPathTerm := Lower(cPathTerm)
            Processa( { || lCopied := __CopyFile( cPathFile, cPathTerm ) }, "Realizando download", "Aguarde...", .F. )
        EndIf

        If lCopied .Or. File( cPathTerm )
            GDFieldPut( "AC9_PRVIEW", "1" )
        Else
            Aviso( "Atencao !", "Nao foi possivel efetuar o download do arquivo '" + cFile + "' para o caminho especificado !", { "Ok" }, 2 )
        EndIf
    EndIf

Return( Nil )

/*/{Protheus.doc} TCPEXCTMP
Exclui os temporarios
@type static function 
@version 1.0
@author Kaique Mathias
@since 03/07/2020
@param aExclui, array, param_description
@return return_type, return_description
/*/

Static Function TCPEXCTMP( aExclui )
    If !Empty( aExclui )
        MsDocExclui( aExclui, .F. )
    EndIf
Return( Nil )

/*/{Protheus.doc} TCPGEDGBC
Grava o anexo no banco de conhecimento
@type function
@version 1.0
@author Kaique Mathias
@since 07/07/2020
@param cObj, character, param_description
@param cDescri, character, param_description
@param aHeaderWiz, array, param_description
@param aColsWiz, array, param_description
@return return_type, return_description
/*/

Static Function TCPGEDGBC( cObj, cDescri, aHeaderWiz, aColsWiz )

    Local lRet      := Ft340CpyObj( cObj )
    Local aRecno    := {}
    PRIVATE aCols   := AClone( aColsWiz )
    PRIVATE aHeader := AClone( aHeaderWiz )

    If lRet

        nSaveSX8 := GetSX8Len()

        M->ACB_CODOBJ := GetSXENum( "ACB", "ACB_CODOBJ" )
        M->ACB_DESCRI := cDescri

        cObj    := M->ACB_OBJETO
        cDescri := M->ACB_DESCRI

        Ft340Grv(1,aRecno)

        While (GetSx8Len() > nSaveSx8)
            ConfirmSX8()
        EndDo

    EndIf

Return( lRet )

/*/{Protheus.doc} TCPGEDENT
Retorna a chave da entidade do GED
@type function
@version 1.0
@author kaique Mathias
@since 7/6/2020
@param cEntidade, character, param_description
@return return_type, return_description
/*/

User Function TCPGEDENT( cEntidade )

    Local aEntidade := MsRelation()

    nScan := AScan( aEntidade, { |x| x[1] == cEntidade } )

    If Empty( nScan )
        
        If !Empty( cUnico := FWX2Unico(cEntidade)  )

            dbSelectArea( cEntidade )
            cCodEnt  := &cUnico
            cCodDesc := Substr( AllTrim( cCodEnt ), TamSX3("A1_FILIAL")[1] + 1 )
            lAchou   := .T.

        EndIf
    
    Else

        aChave   := aEntidade[ nScan, 2 ]
        cCodEnt  := MaBuildKey( cEntidade, aChave )

        cCodDesc := AllTrim( cCodEnt ) + "-" + Capital( Eval( aEntidade[ nScan, 3 ] ) )

    EndIf

Return( {cCodEnt,cCodDesc} )


/*/{Protheus.doc} TCPGEDLOK
Validação da linha da amarração do GED
@type function
@version 1.0
@author Kaique Mathias
@since 7/6/2020
@return return_type, return_description
/*/

User Function TCPGEDLOK()

    Local lRet    := .T.
    Local nPosObj := GDFieldPos( "AC9_OBJETO" )
    Local nLoop   := 0
    Local cUsrPerm:= SuperGetMv("TCP_USRPBC",.F.,"000000") 

    If !GDDeleted()

        If Empty( GDFieldGet( "AC9_OBJETO" ) )
            lRet := .F.
        EndIf

        If lRet
            For nLoop := 1 To Len( aCols )
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Verifica se existe codigo de contato duplicado                         ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                If nLoop <> n .And. !GDDeleted( nLoop )
                    If RTRIM(aCols[ nLoop, nPosObj ]) == RTRIM(GDFieldGet( "AC9_OBJETO" ))
                        lRet := .F.
                        Help( "", 1, "FTCONTDUP", ,"O arquivo selecionado já consta no banco de conhecimento.",2,,,,,,,{"Selecione um arquivo com outro nome."} )
                    EndIf
                EndIf
            Next nLoop
        EndIf
    Else
        If( UPPER(cUserName) # Alltrim( GDFieldGet( "AC9_XUSER" ) ) .And. !( __CUSERID $ cUsrPerm ) )
            lRet := .F.
            Help( "", 1, "USRSEMPERM", ,"Usuario sem permissão para excluir anexos inseridos por outro usuario",2,,,,,,,{""} )
        EndIf   
    EndIf

Return( lRet )
