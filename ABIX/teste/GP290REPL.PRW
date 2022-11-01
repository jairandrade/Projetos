#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} GP290REPL
RdMake para replicar fórmulas para todas as filiais quando RC2/RC2 são exclusivas.
@author Leandro Drumond
@since 14/02/2022
@version P12.1.33
@Type     Function
/*/
User Function GP290REPL()
Local aFilAux   := {}
Local aRecForm  := {}
Local lGpea290  := FunName() == "GPEA290"
Local lCompAux  := .F.

aFilAux := Gp290LoadFil(!lGpea290,@aRecForm)

If lGpea290 //Se foi chamado pelo Ponto de Entrada, retorna as filiais para gravação interna
    Return aFilAux
EndIf

If Len(aFilAux) > 0
    lCompAux := MsgYesNo("Deseja compilar a fórmula em todas as filiais selecionadas? ", "Atenção")
    Proc2BarGauge( { || GP290REPLProc(aFilAux,aRecForm,lCompAux) } , "Replicando alterações" , NIL , NIL , .F. , .T. , .F. , .F. )	// "Replicando alterações"
EndIf

Return Nil

/*/{Protheus.doc} GP290REPLProc
Processa as filiais selecionadas
@author Leandro Drumond
@since 14/02/2022
@version P12.1.33
@Type     Function
/*/
Static Function GP290REPLProc(aFilAux, aRecForm,lCompila)
Local aRc2Enchoice  := {}
Local aRc2VirtChoice:= {}
Local aRc2Visual    := {}
Local aRc2Cols      := {}
Local aRc3Cols      := {}
Local aRC3Virtual   := {}
Local aRC3Visual    := {}
Local aRC3Recnos    := {}
Local aLogTitle     := {}
Local aLogItens     := {}
Local aLogAux       := {}   
Local cFilAux       := cFilAnt
Local cRC3Key       := ""
Local cFormName     := ""
Local nY            := 0
Local nX            := 0

Private aRc3Header      := {}
Private lGpea290Cpy     := .F.
Private lManutence      := .F.

BarGauge1Set( Len(aFilAux) )

For nY := 1 to Len(aRecForm)

    RC2->(DbGoTo(aRecForm[nY]))

    cFormName     := RC2->(RC2_ORIGEM + RC2_CODIGO)

    If Empty(aLogTitle)
        aAdd(aLogTitle, "As seguintes fórmulas foram processadas:")
    EndIf 
    aAdd(aLogAux, cFormName)

    aRc2Enchoice  := {}
    aRc2VirtChoice:= {}
    aRc2Visual    := {}
    aRc2Cols      := {}

    aRc2Cols := RC2->( GdBuildCols( @aRc2Enchoice , NIL , @aRc2VirtChoice , @aRc2Visual , "RC2" , { "RC2_FILIAL" , "RC2_ORIGEM", "RC2_VERSAO" } , NIL , "RC2" ) )

    RC2->(DbGoTo(aRecForm[nY]))

    cRC3Key 	:= RC2->(RC2_FILIAL + RC2_ORIGEM + RC2_CODIGO)

    aRc3Cols      := {}
    aRc3Header    := {}
    aRC3Virtual   := {}
    aRC3Visual    := {}
    aRC3Recnos    := {}

    aRc3Cols	:= RC3->( GdMontaCols(	@aRc3Header 								,;	// 01 -> Array com os Campos do Cabecalho
                                        NIL											,;	// 02 -> Numero de campos em uso
                                        @aRC3Virtual								,;	// 03 -> Array com os campos virtuais
                                        @aRC3Visual									,;	// 04 -> Array com os campos visuais
                                        "RC3" 										,;	// 05 -> Opcional, Alias do Arquivo Carga dos itens do aCols
                                        NIL											,;	// 06 -> Opcional, campos que nao deverao constar do aHedder (NotFields)
                                        @aRC3Recnos                                	,;  // 07 -> [@]Array unidimensional contendo os Recnos
                                        "RC2"										,;	// 08 -> Alias do Arquivo Pai
                                        cRC3Key										,;	// 09 -> Chave para o Posicionamento no Alias Filho
                                        NIL											,;	// 10 -> Bloco para condicao de Loop While
                                        NIL											,;	// 11 -> Bloco para Skip no Loop While
                                        NIL											,;	// 12 -> Se Havera o Elemento de Delecao no aCols
                                        NIL											,;	// 13 -> Se cria variaveis Publicas
                                        NIL											,;	// 14 -> Se Sera considerado o Inicializador Padrao
                                        NIL											,;	// 15 -> Lado para o inicializador Padrao
                                        .T.											,;	// 16 -> Opcional, Carregar Todos os Campos
                                        NIL											,;	// 17 -> Opcional, Nao Carregar os Campos Virtuais
                                        NIL											,;	// 18 -> Opcional, Utilizacao de Query para Selecao de Dados
                                        NIL											,;	// 19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP ) - utilizado com o parametro 10
                                        NIL											,;	// 20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP ) - utilizado com o parametro 11
                                        .T.											,;	// 21 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
                                        NIL											,;	// 22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
                                        NIL											,;	// 23 -> Verifica se Deve Checar se o campo eh usado
                                        NIL											,;	// 24 -> Verifica se Deve Checar o nivel do usuario
                                        NIL											,;	// 25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
                                        NIL											,;	// 26 -> [@]Array que contera as chaves conforme recnos
                                        NIL											,;	// 27 -> [@]Se devera efetuar o Lock dos Registros
                                        NIL											,;	// 28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
                                        NIL											,;	// 29 -> Numero maximo de Locks a ser efetuado
                                        .T.		 							         ;	// 30 -> Utiliza Numeracao na GhostCol
                        );
                )

	For nX := 1 To Len( aRc2Enchoice )
		SetMemVar( aRc2Enchoice[ nX , 02 ] , aRc2Cols[ 1 , nX ] , .T. , .T. )
	Next nX

    SetMemVar( "RC2_ORIGEM", "U_", .T. , .T.  )

    Gp290Replica(4, lCompila, aFilAux, aRc2Enchoice, aRc2Cols, {}, aRc2VirtChoice, aRC3Virtual, aRC3Recnos, aRc3Cols, {}, .T., cFormName)

Next nY

cFilAnt := cFilAux

If Len(aLogTitle) > 0
    aAdd(aLogItens, aClone(aLogAux))
    aAdd(aLogTitle, "Filiais processadas")
    aAdd(aLogItens, aFilAux)
    MsAguarde( { || fMakeLog( aLogItens, aLogTitle , "GP290REPL" , NIL , FunName() , "Log de réplica de fórmulas" ) } ,  "Log de réplica de fórmulas") //"Log de réplica de fórmulas"
EndIf

Return Nil

/*/{Protheus.doc} Gp290LoadFil
Carrega filiais
@author Leandro Drumond
@since 14/02/2022
@version P12.1.33
@Type     Function
/*/
Static Function Gp290LoadFil(lLoadForm,aRecForm)
Local aArea			:= GetArea()
Local aColumns		:= {}
Local aSM0     		:= {}
Local aStru			:= {}
Local aLstIndices	:= {}
Local aRet          := {}
Local aFilAux       := {}
Local cFilRC2       := ""
Local cSeekRC2      := ""
Local lMarcar 		:= .T.
Local nOpcX 		:= 0
Local nCont
Local oSize 
Local oDlgGrid 
Local oTela
Local oPanel
Local oMark
Local oFont         := TFont():New('Courier new',,-16,,.T.)

Private cAliasTRB
Private cAliasForm

Static cAliasTmp
Static oArqTmp

If oArqTmp == Nil //Monta temporária com filiais disponíveis
	Aadd(aStru, {"OK"		, "C", 2						, 0})
	Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial			, 0})
	Aadd(aStru, {"NOME"  	, "C", 100						, 0})
    Aadd(aStru, {"FILCOMP" 	, "C", FwGetTamFilial			, 0})
	AAdd(aLstIndices, {"FILIAL"})

	cAliasTmp := cAliasTRB := GetNextAlias()

	oArqTmp := RhCriaTrab(cAliasTRB, aStru, aLstIndices)

	aSM0  := FWLoadSM0(.T.,,.T.)

	For nCont := 1 To Len(aSM0)
		If aSM0[nCont, 1] == cEmpAnt
            cFilRC2 := xFilial("RC2",aSM0[nCont, 2])
            If ( aScan(aFilAux, { |x| x == cFilRC2 } ) ) == 0
                RecLock(cAliasTRB, .T.)
                    (cAliasTRB)->FILIAL	    := cFilRC2
                    (cAliasTRB)->NOME  	    := aSM0[nCont, 7]
                    (cAliasTRB)->FILCOMP	:= aSM0[nCont, 2]
                (cAliasTRB)->(MsUnlock())
                aAdd(aFilAux, cFilRC2)
            EndIf
		EndIf
	Next nCont
Else 
	cAliasTRB := cAliasTmp
EndIf

oSize := FwDefSize():New(.F.)

oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.1),(oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
oSize:lProp 		:= .F. 				// Proporcional
oSize:Process() 	   					// Dispara os calculos

Begin Sequence

    If lLoadForm
        aStru       := {}
        aLstIndices := {}
        Aadd(aStru, {"OK"		, "C", 2						, 0})
        Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial			, 0})
        Aadd(aStru, {"FORM"  	, "C", 15						, 0})
        Aadd(aStru, {"RECNO"  	, "N", 10						, 0})
        AAdd(aLstIndices, {"FILIAL","FORM"})

        cAliasForm := cAliasFRM := GetNextAlias()

        oArqForm := RhCriaTrab(cAliasForm, aStru, aLstIndices)

        RC2->(DbSetOrder(1)) //RC2_FILIAL, RC2_ORIGEM, RC2_CODIGO, R_E_C_N_O_, D_E_L_E_T_

        cSeekRC2 := xFilial("RC2") + "U_"

        If RC2->(DbSeek(cSeekRC2)) //Busca todas as fórmulas de usuário da filial logada
            While RC2->(!Eof() .and. RC2_FILIAL + RC2_ORIGEM == cSeekRC2 )
                RecLock(cAliasForm, .T.)
                        (cAliasForm)->FILIAL    := RC2->RC2_FILIAL
                        (cAliasForm)->FORM      := RC2->RC2_CODIGO
                        (cAliasForm)->RECNO 	:= RC2->(Recno())
                    (cAliasForm)->(MsUnlock())
                RC2->(DbSkip())
            EndDo
        EndIf

        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||(cAliasForm)->FILIAL}") )
        aColumns[Len(aColumns)]:SetTitle("Filial" ) //"Filial"
        aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
        aColumns[Len(aColumns)]:SetDecimal(0)
        aColumns[Len(aColumns)]:SetPicture("@!")

        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||(cAliasForm)->FORM}") )
        aColumns[Len(aColumns)]:SetTitle("Fórmula") //"Fórmula"
        aColumns[Len(aColumns)]:SetSize(15)
        aColumns[Len(aColumns)]:SetDecimal(0)
        aColumns[Len(aColumns)]:SetPicture("@!")

        DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( "Réplica de fórmulas" ) From 0,0 TO 380,930 OF oMainWnd PIXEL //"Selecione as fórmulas para replicar" 

        // Cria o conteiner onde serão colocados os paineis
        oTela		:= FWFormContainer():New( oDlgGrid )
        cIdGrid  	:= oTela:CreateHorizontalBox( 80 )

        oTela:Activate( oDlgGrid, .F. )

        //Cria os paineis onde serao colocados os browses
        oPanel	:= oTela:GeTPanel( cIdGrid )

        @ oSize:GetDimension("CABECALHO","LININI")+08 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "Selecione as fórmulas que serão replicadas" Of oDlgGrid Pixel FONT oFont

        oMark := FWMarkBrowse():New()

        oMark:SetOwner(oPanel)
        oMark:SetAlias(cAliasForm)
        oMark:SetTemporary(.T.)
        oMark:SetColumns(aColumns)
        oMark:SetFieldMark('OK')
        oMark:SetIgnoreARotina(.T.)
        oMark:SetMenuDef('')

        oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasForm ), oMark:Refresh(.T.)  }

        oMark:Activate()

        SetMarkAll(oMark:Mark(),.T.,cAliasForm) //Marca todos os registros

        oMark:Refresh(.T.)

        //Botoes
        oBtn1:= TBrowseButton():New( oSize:GetDimension("CABECALHO","LININI")+20,oSize:GetDimension("CABECALHO","COLINI")+320, OemToAnsi("Confirmar"),oDlgGrid, {||nOpcX := 1, oDlgGrid:End()},42,12,,,.F.,.T.,.F.,,.F.,,,)	//"Confirmar"			         
        oBtn2:= TBrowseButton():New( oSize:GetDimension("CABECALHO","LININI")+20,oSize:GetDimension("CABECALHO","COLINI")+370, OemToAnsi("Cancelar"),oDlgGrid, {||nOpcX := 0, oDlgGrid:End()},42,12,,,.F.,.T.,.F.,,.F.,,,)	//"Cancelar"

        ACTIVATE MSDIALOG oDlgGrid CENTERED

        If nOpcX == 1

            //Adiciona filiais selecionadas
            (cAliasForm)->(dbGoTop())

            While (cAliasForm)->(!EOF())
                If !Empty((cAliasForm)->OK)
                    aAdd(aRecForm, (cAliasForm)->RECNO)
                EndIf
                (cAliasForm)->(dbSkip())
            EndDo
        Else 
            Break
        EndIf
        If Empty(aRecForm)
            MsgInfo("Nenhuma fórmula selecionada")
            Break 
        EndIf
    EndIf

    nOpcX := 0

    aColumns := {}

    AAdd(aColumns,FWBrwColumn():New())
    aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->FILIAL}") )
    aColumns[Len(aColumns)]:SetTitle("Filial" ) //"Filial"
    aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
    aColumns[Len(aColumns)]:SetDecimal(0)
    aColumns[Len(aColumns)]:SetPicture("@!")

    AAdd(aColumns,FWBrwColumn():New())
    aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->NOME}") )
    aColumns[Len(aColumns)]:SetTitle("Nome") //"Nome"
    aColumns[Len(aColumns)]:SetSize(Len(SM0->M0_NOME))
    aColumns[Len(aColumns)]:SetDecimal(0)
    aColumns[Len(aColumns)]:SetPicture("@!")

    DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( "Réplica de fórmulas" ) From 0,0 TO 380,930 OF oMainWnd PIXEL //"Réplica de fórmulas"

    // Cria o conteiner onde serão colocados os paineis
    oTela		:= FWFormContainer():New( oDlgGrid )
    cIdGrid  	:= oTela:CreateHorizontalBox( 80 )

    oTela:Activate( oDlgGrid, .F. )

    //Cria os paineis onde serao colocados os browses
    oPanel	:= oTela:GeTPanel( cIdGrid )

    @ oSize:GetDimension("CABECALHO","LININI")+08 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "Selecione as filiais onde as fórmulas serão replicadas" Of oDlgGrid Pixel FONT oFont

    oMark := FWMarkBrowse():New()

    oMark:SetOwner(oPanel)
    oMark:SetAlias(cAliasTRB)
    oMark:SetTemporary(.T.)
    oMark:SetColumns(aColumns)
    oMark:SetFieldMark('OK')
    oMark:SetFilterDefault( " (cAliasTRB)->FILCOMP <> cFilAnt " )
    oMark:SetIgnoreARotina(.T.)
    oMark:SetMenuDef('')

    oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasTRB ), oMark:Refresh(.T.)  }

    oMark:Activate()

    SetMarkAll(oMark:Mark(),.T.,cAliasTRB) //Marca todos os registros

    oMark:Refresh(.T.)

    //Botoes
    oBtn1:= TBrowseButton():New( oSize:GetDimension("CABECALHO","LININI")+20,oSize:GetDimension("CABECALHO","COLINI")+320, OemToAnsi("Confirmar"),oDlgGrid, {||nOpcX := 1, oDlgGrid:End()},42,12,,,.F.,.T.,.F.,,.F.,,,)	//"Confirmar"			         
    oBtn2:= TBrowseButton():New( oSize:GetDimension("CABECALHO","LININI")+20,oSize:GetDimension("CABECALHO","COLINI")+370, OemToAnsi("Cancelar"),oDlgGrid, {||nOpcX := 0, oDlgGrid:End()},42,12,,,.F.,.T.,.F.,,.F.,,,)	//"Cancelar"

    ACTIVATE MSDIALOG oDlgGrid CENTERED

    If nOpcX == 1

        //Adiciona filiais selecionadas
        (cAliasTRB)->(dbGoTop())

        While (cAliasTRB)->(!EOF())
            If !Empty((cAliasTRB)->OK) .and. (cAliasTRB)->FILCOMP <> cFilAnt
                aAdd(aRet, (cAliasTRB)->FILCOMP)
            EndIf
            (cAliasTRB)->(dbSkip())
        EndDo
    EndIf

End Sequence

RestArea(aArea)

Return aRet

/*/{Protheus.doc} SetMarkAll
Marca/Desmarca todas as filiais
@author Leandro Drumond
@since 14/02/2022
@version P12.1.33
@Type     Function
/*/
Static Function SetMarkAll(cMarca,lMarcar,cAliasTRB)

Local cAliasMark := cAliasTRB
Local aAreaMark  := (cAliasMark)->( GetArea() )

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

While !(cAliasMark)->( Eof() )
	RecLock( (cAliasMark), .F. )
	(cAliasMark)->OK := IIf( lMarcar , cMarca, '  ' )
	MsUnLock()
	(cAliasMark)->( dbSkip() )
EndDo

RestArea(aAreaMark)

Return .T.
