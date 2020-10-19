#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} EXPMDT2
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  08/11/2019
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function EXPMDT2( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
Local   cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk
	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualização Realizada.", "EXPMDT2" )
				Else
					MsgStop( "Atualização não Realizada.", "EXPMDT2" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização Concluída." )
				Else
					Final( "Atualização não Realizada." )
				EndIf
			EndIf

		Else
			MsgStop( "Atualização não Realizada.", "EXPMDT2" )

		EndIf

	Else
		MsgStop( "Atualização não Realizada.", "EXPMDT2" )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  08/11/2019
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// Só adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()

			oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )

			// Alteração física dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] )
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			//------------------------------------
			// Atualiza o dicionário SX6
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de parâmetros" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX6()

			//------------------------------------
			// Atualiza o dicionário SX5
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de tabelas sistema" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX5()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  08/11/2019
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local cX3Campo  := ""
Local cX3Dado   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
             { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
             { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
             { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
             { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
             { "X3_AGRUP"  , 0 }, { "X3_MODAL"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )

//
// --- ATENÇÃO ---
// Coloque .F. na 2a. posição de cada elemento do array, para os dados do SX3
// que não serão atualizados quando o campo já existir.
//

//
// Campos Tabela RA1
//

aAdd( aSX3, { ;
	{ 'SA2'																	, .T. }, ; //X3_ARQUIVO
	{ '53'																	, .T. }, ; //X3_ORDEM
	{ 'A2_GRUPO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Grupo'																, .T. }, ; //X3_TITULO
	{ 'Grupo'																, .T. }, ; //X3_TITSPA
	{ 'Group'																, .T. }, ; //X3_TITENG
	{ 'Grupo'																, .T. }, ; //X3_DESCRIC
	{ 'Grupo'																, .T. }, ; //X3_DESCSPA
	{ 'Group'																, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Vazio().or.ExistCpo("SX5","Y7"+M->A2_GRUPO,1)'						, .T. }, ; //X3_VALID
	{ Chr(160) + Chr(128) + Chr(144) + Chr(130) + Chr(241) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'GRU'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela SB1
//
aAdd( aSX3, { ;
	{ 'SB1'																	, .T. }, ; //X3_ARQUIVO
	{ '05'																	, .T. }, ; //X3_ORDEM
	{ 'B1_TIPO'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo'																, .T. }, ; //X3_TITULO
	{ 'Tipo'																, .T. }, ; //X3_TITSPA
	{ 'Type'																, .T. }, ; //X3_TITENG
	{ 'Tipo de Produto (MP,PA,.)'											, .T. }, ; //X3_DESCRIC
	{ 'Tipo de Producto (MP,PA,.'											, .T. }, ; //X3_DESCSPA
	{ 'Type of Product'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'A010Tipo()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ '02'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(135) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'SB1'																	, .T. }, ; //X3_ARQUIVO
	{ 'T8'																	, .T. }, ; //X3_ORDEM
	{ 'B1_XTPEPI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 25																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo EPI'															, .T. }, ; //X3_TITULO
	{ 'Tipo EPI'															, .T. }, ; //X3_TITSPA
	{ 'Tipo EPI'															, .T. }, ; //X3_TITENG
	{ 'Tipo de EPI'															, .T. }, ; //X3_DESCRIC
	{ 'Tipo de EPI'															, .T. }, ; //X3_DESCSPA
	{ 'Tipo de EPI'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela SR8
//
aAdd( aSX3, { ;
	{ 'SR8'																	, .T. }, ; //X3_ARQUIVO
	{ '40'																	, .T. }, ; //X3_ORDEM
	{ 'R8_CRMMED'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Insc Emitent'														, .T. }, ; //X3_TITULO
	{ 'Insc Emitent'														, .T. }, ; //X3_TITSPA
	{ 'Issuance Reg'														, .T. }, ; //X3_TITENG
	{ 'Inscrição do Emitente'												, .T. }, ; //X3_DESCRIC
	{ 'Inscripcion del Emitente'											, .T. }, ; //X3_DESCSPA
	{ 'Issuer Registration'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'fGP240Edit()'														, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela SRJ
//
aAdd( aSX3, { ;
	{ 'SRJ'																	, .T. }, ; //X3_ARQUIVO
	{ '12'																	, .T. }, ; //X3_ORDEM
	{ 'RJ_PPPIMP'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Impr.no PPP?'														, .T. }, ; //X3_TITULO
	{ 'Impr. en PPP'														, .T. }, ; //X3_TITSPA
	{ 'Print in PPP'														, .T. }, ; //X3_TITENG
	{ 'Imprimir no PPP?'													, .T. }, ; //X3_DESCRIC
	{ 'Imprimir en PPP?'													, .T. }, ; //X3_DESCSPA
	{ 'Print in PPP?'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'pertence("12")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(198) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Sim;2=Nao'															, .T. }, ; //X3_CBOX
	{ '1=Sí;2=No'															, .T. }, ; //X3_CBOXSPA
	{ '1=Yes;2=No'															, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ 'C'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela TJC
//
aAdd( aSX3, { ;
	{ 'TJC'																	, .T. }, ; //X3_ARQUIVO
	{ '04'																	, .T. }, ; //X3_ORDEM
	{ 'TJC_CODPRO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Produto'																, .T. }, ; //X3_TITULO
	{ 'Produto'																, .T. }, ; //X3_TITSPA
	{ 'Produto'																, .T. }, ; //X3_TITENG
	{ 'Código do Produto Químico'											, .T. }, ; //X3_DESCRIC
	{ 'Código do Produto Químico'											, .T. }, ; //X3_DESCSPA
	{ 'Código do Produto Químico'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'MDT182EXPQ(M->TJC_CODPRO)'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(176)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SB1'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'MDT182WHPR()'														, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '030'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

//
// Campos Tabela TLE
//
aAdd( aSX3, { ;
	{ 'TLE'																	, .T. }, ; //X3_ARQUIVO
	{ '04'																	, .T. }, ; //X3_ORDEM
	{ 'TLE_NOMRES'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 30																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome Resp.'															, .T. }, ; //X3_TITULO
	{ 'Nombre resp.'														, .T. }, ; //X3_TITSPA
	{ 'Name of Resp'														, .T. }, ; //X3_TITENG
	{ 'Nome do Responsavel'													, .T. }, ; //X3_DESCRIC
	{ 'Nombre del responsable'												, .T. }, ; //X3_DESCSPA
	{ 'Responsible Name'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'TMK->(VDISP(TLE->TLE_CODRES,"TMK_NOMUSU"))'							, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ '!lReprog'															, .T. }, ; //X3_WHEN
	{ 'IF(TMK->(DBSEEK(xFilial("TMK")+TLE->TLE_CODRES)),TMK->TMK_NOMUSU,"")'	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela TM0
//
aAdd( aSX3, { ;
	{ 'TM0'																	, .T. }, ; //X3_ARQUIVO
	{ '52'																	, .T. }, ; //X3_ORDEM
	{ 'TM0_INDBIO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Biometria'															, .T. }, ; //X3_TITULO
	{ 'Biometria'															, .T. }, ; //X3_TITSPA
	{ 'Biometria'															, .T. }, ; //X3_TITENG
	{ 'Biometria'															, .T. }, ; //X3_DESCRIC
	{ 'Biometria'															, .T. }, ; //X3_DESCSPA
	{ 'Biometria'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "Pertence('12')"														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ "'1'"																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOX
	{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOXSPA
	{ '1=Sim;2=Não'															, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'EMPTY(M->TM0_CANDID)'												, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

//
// Campos Tabela TMY
//
aAdd( aSX3, { ;
	{ 'TMY'																	, .T. }, ; //X3_ARQUIVO
	{ '25'																	, .T. }, ; //X3_ORDEM
	{ 'TMY_CONFIN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Espaco Confi'														, .T. }, ; //X3_TITULO
	{ 'Espac Confi'															, .T. }, ; //X3_TITSPA
	{ 'Config Space'														, .T. }, ; //X3_TITENG
	{ 'Trabalho Espaco Confinado'											, .T. }, ; //X3_DESCRIC
	{ 'Trabajo espacio confinado'											, .T. }, ; //X3_DESCSPA
	{ 'Closed Space Work'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Sim;2=Nao'															, .T. }, ; //X3_CBOX
	{ '1=Sí;2=No'															, .T. }, ; //X3_CBOXSPA
	{ '1=Yes;2=No'															, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TMY'																	, .T. }, ; //X3_ARQUIVO
	{ '26'																	, .T. }, ; //X3_ORDEM
	{ 'TMY_ALTURA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Trab. Altura'														, .T. }, ; //X3_TITULO
	{ 'Trab. Altura'														, .T. }, ; //X3_TITSPA
	{ 'Work Height'															, .T. }, ; //X3_TITENG
	{ 'Trabalho em Altura'													, .T. }, ; //X3_DESCRIC
	{ 'Trabalho em Altura'													, .T. }, ; //X3_DESCSPA
	{ 'Working at a Height'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Sim;2=Nao'															, .T. }, ; //X3_CBOX
	{ '1=Si;2=No'															, .T. }, ; //X3_CBOXSPA
	{ '1=Yes;2=No'															, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

//
// Campos Tabela TN0
//
aAdd( aSX3, { ;
	{ 'TN0'																	, .T. }, ; //X3_ARQUIVO
	{ '03'																	, .T. }, ; //X3_ORDEM
	{ 'TN0_CODAMB'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 30																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ambiente'															, .T. }, ; //X3_TITULO
	{ 'Ambiente'															, .T. }, ; //X3_TITSPA
	{ 'Environment'															, .T. }, ; //X3_TITENG
	{ 'Codigo do Ambiente Fisico'											, .T. }, ; //X3_DESCRIC
	{ 'Codigo de Ambiente Fisico'											, .T. }, ; //X3_DESCSPA
	{ 'Environment Code'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'MDT180AMB(1)'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'TNE'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(246) + Chr(224)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ "(Type('lTrava902') == 'L' .AND. lTrava902)"							, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TN0'																	, .T. }, ; //X3_ARQUIVO
	{ '04'																	, .T. }, ; //X3_ORDEM
	{ 'TN0_NOMAMB'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 20																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome Amb.'															, .T. }, ; //X3_TITULO
	{ 'Nom. Ent'															, .T. }, ; //X3_TITSPA
	{ 'Env. Name'															, .T. }, ; //X3_TITENG
	{ 'Nome do Ambiente'													, .T. }, ; //X3_DESCRIC
	{ 'Nombre de Entorno'													, .T. }, ; //X3_DESCSPA
	{ 'Environment Name'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ "If( INCLUI,'',Posicione( 'TNE', 1, xFilial( 'TNE' ) + TN0->TN0_CODAMB, 'TNE_NOME'   ))", .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(242) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'DTVALIDA'															, .T. }, ; //X3_WHEN
	{ "POSICIONE( 'TNE', 1, XFILIAL( 'TNE' ) + TN0->TN0_CODAMB, 'TNE_NOME')"	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TN0'																	, .T. }, ; //X3_ARQUIVO
	{ '18'																	, .T. }, ; //X3_ORDEM
	{ 'TN0_QTAGEN'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 3																		, .T. }, ; //X3_DECIMAL
	{ 'Quant.Agente'														, .T. }, ; //X3_TITULO
	{ 'Quant.Agente'														, .T. }, ; //X3_TITSPA
	{ 'Quant.Agente'														, .T. }, ; //X3_TITENG
	{ 'Quantidade de Agente'												, .T. }, ; //X3_DESCRIC
	{ 'Cantidad de Agente'													, .T. }, ; //X3_DESCSPA
	{ 'Agent Quantity'														, .T. }, ; //X3_DESCENG
	{ '@E 99,999.999'														, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(224)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'DTVALIDA'															, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TN0'																	, .T. }, ; //X3_ARQUIVO
	{ '19'																	, .T. }, ; //X3_ORDEM
	{ 'TN0_UNIMED'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Unid. Medida'														, .T. }, ; //X3_TITULO
	{ 'Unid. Medida'														, .T. }, ; //X3_TITSPA
	{ 'UOM'																	, .T. }, ; //X3_TITENG
	{ 'Unidade de Medida'													, .T. }, ; //X3_DESCRIC
	{ 'Unidad de Medida'													, .T. }, ; //X3_DESCSPA
	{ 'Unit of Measure'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'If(!Empty(M->TN0_UNIMED),ExistCpo("V3F",M->TN0_UNIMED,2),.T.)'		, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'MDTV3F'																, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(246) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

//
// Campos Tabela TNF
//
aAdd( aSX3, { ;
	{ 'TNF'																	, .T. }, ; //X3_ARQUIVO
	{ '03'																	, .T. }, ; //X3_ORDEM
	{ 'TNF_DESC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 30																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Descrição'															, .T. }, ; //X3_TITULO
	{ 'Descrição'															, .T. }, ; //X3_TITSPA
	{ 'Descrição'															, .T. }, ; //X3_TITENG
	{ 'Descricao do Produto'												, .T. }, ; //X3_DESCRIC
	{ 'Descripcion del Producto'											, .T. }, ; //X3_DESCSPA
	{ 'Product Description'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'SB1->(VDISP(TNF->TNF_CODEPI,"B1_DESC"))'								, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(146) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ 'IF(SB1->(DBSEEK(XFILIAL("SB1")+TNF->TNF_CODEPI)),SB1->B1_DESC," ")'		, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME


aAdd( aSX3, { ;
	{ 'RA1'																	, .T. }, ; //X3_ARQUIVO
	{ '04'																	, .T. }, ; //X3_ORDEM
	{ 'RA1_TIPO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo Curso'															, .T. }, ; //X3_TITULO
	{ 'Tipo Curso'															, .T. }, ; //X3_TITSPA
	{ 'Course Tp'															, .T. }, ; //X3_TITENG
	{ 'Tipo do Curso'														, .T. }, ; //X3_DESCRIC
	{ 'Tipo del Curso'														, .T. }, ; //X3_DESCSPA
	{ 'Course Type'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("SX5","R6"+M->RA1_TIPO) .AND. RA1TIPOVLD()'					, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(129) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'R6'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA1'																	, .T. }, ; //X3_ARQUIVO
	{ '06'																	, .T. }, ; //X3_ORDEM
	{ 'RA1_DURACA'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 7																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Duracao'																, .T. }, ; //X3_TITULO
	{ 'Duracion'															, .T. }, ; //X3_TITSPA
	{ 'Duration'															, .T. }, ; //X3_TITENG
	{ 'Duracao'																, .T. }, ; //X3_DESCRIC
	{ 'Duracion'															, .T. }, ; //X3_DESCSPA
	{ 'Duration'															, .T. }, ; //X3_DESCENG
	{ '9999.99'																, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(63) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA1'																	, .T. }, ; //X3_ARQUIVO
	{ '07'																	, .T. }, ; //X3_ORDEM
	{ 'RA1_UNDURA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Unid.Duracao'														, .T. }, ; //X3_TITULO
	{ 'Un.Duracion'															, .T. }, ; //X3_TITSPA
	{ 'Duration Un.'														, .T. }, ; //X3_TITENG
	{ 'Tempo de Duracao'													, .T. }, ; //X3_DESCRIC
	{ 'Tiempo de Duracion'													, .T. }, ; //X3_DESCSPA
	{ 'Length of Time'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("SX5","R5"+M->RA1_UNDURA)'									, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(63) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'R5'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA1'																	, .T. }, ; //X3_ARQUIVO
	{ '08'																	, .T. }, ; //X3_ORDEM
	{ 'RA1_VALOR'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Valor'																, .T. }, ; //X3_TITULO
	{ 'Valor'																, .T. }, ; //X3_TITSPA
	{ 'Value'																, .T. }, ; //X3_TITENG
	{ 'Valor'																, .T. }, ; //X3_DESCRIC
	{ 'Valor'																, .T. }, ; //X3_DESCSPA
	{ 'Value'																, .T. }, ; //X3_DESCENG
	{ '@R 999,999,999.99'													, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(63) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela RA2
//
aAdd( aSX3, { ;
	{ 'RA2'																	, .T. }, ; //X3_ARQUIVO
	{ '03'																	, .T. }, ; //X3_ORDEM
	{ 'RA2_DESC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 20																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Descricao'															, .T. }, ; //X3_TITULO
	{ 'Descripcion'															, .T. }, ; //X3_TITSPA
	{ 'Description'															, .T. }, ; //X3_TITENG
	{ 'Descricao'															, .T. }, ; //X3_DESCRIC
	{ 'Descripcion'															, .T. }, ; //X3_DESCSPA
	{ 'Description'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(191) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA2'																	, .T. }, ; //X3_ARQUIVO
	{ '06'																	, .T. }, ; //X3_ORDEM
	{ 'RA2_TURMA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Turma'																, .T. }, ; //X3_TITULO
	{ 'Grupo'																, .T. }, ; //X3_TITSPA
	{ 'Class'																, .T. }, ; //X3_TITENG
	{ 'Turma do Curso'														, .T. }, ; //X3_DESCRIC
	{ 'Grupo del Curso'														, .T. }, ; //X3_DESCSPA
	{ 'Course Class'														, .T. }, ; //X3_DESCENG
	{ '999'																	, .T. }, ; //X3_PICTURE
	{ 'NaoVazio() .And. Val(M->RA2_TURMA) > 0'								, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(191) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'RA2When()'															, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA2'																	, .T. }, ; //X3_ARQUIVO
	{ '10'																	, .T. }, ; //X3_ORDEM
	{ 'RA2_HORARI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 20																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Horario'																, .T. }, ; //X3_TITULO
	{ 'Horario'																, .T. }, ; //X3_TITSPA
	{ 'Time'																, .T. }, ; //X3_TITENG
	{ 'Horario'																, .T. }, ; //X3_DESCRIC
	{ 'Horario'																, .T. }, ; //X3_DESCSPA
	{ 'Time'																, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(191) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA2'																	, .T. }, ; //X3_ARQUIVO
	{ '11'																	, .T. }, ; //X3_ORDEM
	{ 'RA2_DURACA'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 7																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Duracao'																, .T. }, ; //X3_TITULO
	{ 'Duracion'															, .T. }, ; //X3_TITSPA
	{ 'Duração'																, .T. }, ; //X3_TITENG
	{ 'Duracao'																, .T. }, ; //X3_DESCRIC
	{ 'Duraccion'															, .T. }, ; //X3_DESCSPA
	{ 'Duração'																, .T. }, ; //X3_DESCENG
	{ '@E 9,999.99'															, .T. }, ; //X3_PICTURE
	{ 'Positivo()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(191) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA2'																	, .T. }, ; //X3_ARQUIVO
	{ '12'																	, .T. }, ; //X3_ORDEM
	{ 'RA2_UNDURA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Un. Duracao'															, .T. }, ; //X3_TITULO
	{ 'Un. Duracion'														, .T. }, ; //X3_TITSPA
	{ 'Duration Un.'														, .T. }, ; //X3_TITENG
	{ 'Unidade Duracao'														, .T. }, ; //X3_DESCRIC
	{ 'Unidad Duracion'														, .T. }, ; //X3_DESCSPA
	{ 'Duration Unit'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("SX5","R5"+M->RA2_UNDURA)'									, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(191) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'R5'																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ ''																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA2'																	, .T. }, ; //X3_ARQUIVO
	{ '13'																	, .T. }, ; //X3_ORDEM
	{ 'RA2_VAGAS'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'No.Vagas'															, .T. }, ; //X3_TITULO
	{ 'Nro.Vacantes'														, .T. }, ; //X3_TITSPA
	{ 'Places'																, .T. }, ; //X3_TITENG
	{ 'Numero de Vagas'														, .T. }, ; //X3_DESCRIC
	{ 'Numero de Vacantes'													, .T. }, ; //X3_DESCSPA
	{ 'Number of Places'													, .T. }, ; //X3_DESCENG
	{ '9999'																, .T. }, ; //X3_PICTURE
	{ 'Positivo() .And. Tr050Custo()'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(136) + Chr(138) + Chr(132) + Chr(129) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA2'																	, .T. }, ; //X3_ARQUIVO
	{ '14'																	, .T. }, ; //X3_ORDEM
	{ 'RA2_RESERV'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Vagas Reserv'														, .T. }, ; //X3_TITULO
	{ 'Vacan.Reserv'														, .T. }, ; //X3_TITSPA
	{ 'Res. Places'															, .T. }, ; //X3_TITENG
	{ 'No. Vagas Reservadas'												, .T. }, ; //X3_DESCRIC
	{ 'Num Vacantes Reservados'												, .T. }, ; //X3_DESCSPA
	{ 'Nr.of Reserved Places'												, .T. }, ; //X3_DESCENG
	{ '9999'																, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(191) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA2'																	, .T. }, ; //X3_ARQUIVO
	{ '15'																	, .T. }, ; //X3_ORDEM
	{ 'RA2_INSTRU'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Instrutor'															, .T. }, ; //X3_TITULO
	{ 'Instructor'															, .T. }, ; //X3_TITSPA
	{ 'Instructor'															, .T. }, ; //X3_TITENG
	{ 'Instrutor'															, .T. }, ; //X3_DESCRIC
	{ 'Instructor'															, .T. }, ; //X3_DESCSPA
	{ 'Instructor'															, .T. }, ; //X3_DESCENG
	{ '999999'																, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("RA7",M->RA2_INSTRU) .And. Tr050Curso(.F.,4)'				, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(191) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'RA7'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '121'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA2'																	, .T. }, ; //X3_ARQUIVO
	{ '16'																	, .T. }, ; //X3_ORDEM
	{ 'RA2_LOCAL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 30																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Local'																, .T. }, ; //X3_TITULO
	{ 'Lugar'																, .T. }, ; //X3_TITSPA
	{ 'Location'															, .T. }, ; //X3_TITENG
	{ 'Local'																, .T. }, ; //X3_DESCRIC
	{ 'Ubicacion'															, .T. }, ; //X3_DESCSPA
	{ 'Location'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(191) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA2'																	, .T. }, ; //X3_ARQUIVO
	{ '18'																	, .T. }, ; //X3_ORDEM
	{ 'RA2_CUSTO'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Custo Estim.'														, .T. }, ; //X3_TITULO
	{ 'Costo Estim'															, .T. }, ; //X3_TITSPA
	{ 'Estm.Cost'															, .T. }, ; //X3_TITENG
	{ 'Custo Estimado'														, .T. }, ; //X3_DESCRIC
	{ 'Costo Estimado'														, .T. }, ; //X3_DESCSPA
	{ 'Estim.Cost'															, .T. }, ; //X3_DESCENG
	{ '@R 999,999,999.99'													, .T. }, ; //X3_PICTURE
	{ 'Positivo()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(191) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA2'																	, .T. }, ; //X3_ARQUIVO
	{ '19'																	, .T. }, ; //X3_ORDEM
	{ 'RA2_RESPON'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 30																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Responsavel'															, .T. }, ; //X3_TITULO
	{ 'Responsable'															, .T. }, ; //X3_TITSPA
	{ 'Responsible'															, .T. }, ; //X3_TITENG
	{ 'Responsavel'															, .T. }, ; //X3_DESCRIC
	{ 'Responsable'															, .T. }, ; //X3_DESCSPA
	{ 'Responsible'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(191) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA2'																	, .T. }, ; //X3_ARQUIVO
	{ '21'																	, .T. }, ; //X3_ORDEM
	{ 'RA2_AVAL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod. Aval.'															, .T. }, ; //X3_TITULO
	{ 'Evaluacion'															, .T. }, ; //X3_TITSPA
	{ 'Apprais.Code'														, .T. }, ; //X3_TITENG
	{ 'Codigo Avaliacao'													, .T. }, ; //X3_DESCRIC
	{ 'Codigo de Evaluacion'												, .T. }, ; //X3_DESCSPA
	{ 'Appraisal Code'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("RAB",M->RA2_AVAL) .And. Tr050Curso(.F.,3)'					, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(129) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'RAB'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA2'																	, .T. }, ; //X3_ARQUIVO
	{ '24'																	, .T. }, ; //X3_ORDEM
	{ 'RA2_HORAS'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Horas'																, .T. }, ; //X3_TITULO
	{ 'Horas'																, .T. }, ; //X3_TITSPA
	{ 'Hours'																, .T. }, ; //X3_TITENG
	{ 'Horas'																, .T. }, ; //X3_DESCRIC
	{ 'Horas'																, .T. }, ; //X3_DESCSPA
	{ 'Hours'																, .T. }, ; //X3_DESCENG
	{ '@R 999.99'															, .T. }, ; //X3_PICTURE
	{ 'Positivo()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(191) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela RA3
//
aAdd( aSX3, { ;
	{ 'RA3'																	, .T. }, ; //X3_ARQUIVO
	{ '01'																	, .T. }, ; //X3_ORDEM
	{ 'RA3_FILIAL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Filial'																, .T. }, ; //X3_TITULO
	{ 'Sucursal'															, .T. }, ; //X3_TITSPA
	{ 'Branch'																, .T. }, ; //X3_TITENG
	{ 'Filial'																, .T. }, ; //X3_DESCRIC
	{ 'Sucursal'															, .T. }, ; //X3_DESCSPA
	{ 'System Branch'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(129) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(130) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '033'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA3'																	, .T. }, ; //X3_ARQUIVO
	{ '08'																	, .T. }, ; //X3_ORDEM
	{ 'RA3_DATA'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Data Solic.'															, .T. }, ; //X3_TITULO
	{ 'Fecha Solic.'														, .T. }, ; //X3_TITSPA
	{ 'Req.Date'															, .T. }, ; //X3_TITENG
	{ 'Data da Solicitacao'													, .T. }, ; //X3_DESCRIC
	{ 'Fecha de la Solicitud'												, .T. }, ; //X3_DESCSPA
	{ 'Request Date'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ 'NaoVazio()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(63) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela RA4
//
aAdd( aSX3, { ;
	{ 'RA4'																	, .T. }, ; //X3_ARQUIVO
	{ '08'																	, .T. }, ; //X3_ORDEM
	{ 'RA4_ENTIDA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Cod.Entidade'														, .T. }, ; //X3_TITULO
	{ 'Cod.Ente'															, .T. }, ; //X3_TITSPA
	{ 'Ent. desc'															, .T. }, ; //X3_TITENG
	{ 'Codigo da Entidade'													, .T. }, ; //X3_DESCRIC
	{ 'Codigo del Ente'														, .T. }, ; //X3_DESCSPA
	{ 'Entity Description'													, .T. }, ; //X3_DESCENG
	{ '9999'																, .T. }, ; //X3_PICTURE
	{ 'NaoVazio() .And. Tr100RetDesc() .And. Tr100Exist(2)'					, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(63) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'RA6'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'Ra4EntidWhen()'														, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA4'																	, .T. }, ; //X3_ARQUIVO
	{ '10'																	, .T. }, ; //X3_ORDEM
	{ 'RA4_VALIDA'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dt.Validade'															, .T. }, ; //X3_TITULO
	{ 'Fch Validez'															, .T. }, ; //X3_TITSPA
	{ 'Valid. Dt'															, .T. }, ; //X3_TITENG
	{ 'Data Validade'														, .T. }, ; //X3_DESCRIC
	{ 'Fecha Validez'														, .T. }, ; //X3_DESCSPA
	{ 'Validity Date'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(63) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ 'CTOD("  /  /  ")'													, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA4'																	, .T. }, ; //X3_ARQUIVO
	{ '12'																	, .T. }, ; //X3_ORDEM
	{ 'RA4_UNDURA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Un.Duracao'															, .T. }, ; //X3_TITULO
	{ 'Un.Duracion'															, .T. }, ; //X3_TITSPA
	{ 'Last. Unit'															, .T. }, ; //X3_TITENG
	{ 'Unidade de Duracao'													, .T. }, ; //X3_DESCRIC
	{ 'Unidad de Duracion'													, .T. }, ; //X3_DESCSPA
	{ 'Lasting Unit'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Existcpo("SX5","R5"+M->RA4_UNDURA)'									, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(63) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'R5'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA4'																	, .T. }, ; //X3_ARQUIVO
	{ '13'																	, .T. }, ; //X3_ORDEM
	{ 'RA4_DURACA'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 7																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Duracao'																, .T. }, ; //X3_TITULO
	{ 'Duracion'															, .T. }, ; //X3_TITSPA
	{ 'Duration'															, .T. }, ; //X3_TITENG
	{ 'Duracao'																, .T. }, ; //X3_DESCRIC
	{ 'Duracion'															, .T. }, ; //X3_DESCSPA
	{ 'Duration'															, .T. }, ; //X3_DESCENG
	{ '@E 9999.99'															, .T. }, ; //X3_PICTURE
	{ 'Positivo()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(63) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA4'																	, .T. }, ; //X3_ARQUIVO
	{ '14'																	, .T. }, ; //X3_ORDEM
	{ 'RA4_PRESEN'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ '% Presenca'															, .T. }, ; //X3_TITULO
	{ '% Presencia'															, .T. }, ; //X3_TITSPA
	{ '% Presence'															, .T. }, ; //X3_TITENG
	{ '% Presenca'															, .T. }, ; //X3_DESCRIC
	{ '% Presencia'															, .T. }, ; //X3_DESCSPA
	{ '% Presence'															, .T. }, ; //X3_DESCENG
	{ '999.99'																, .T. }, ; //X3_PICTURE
	{ 'M->RA4_PRESEN <= 100'												, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(63) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA4'																	, .T. }, ; //X3_ARQUIVO
	{ '15'																	, .T. }, ; //X3_ORDEM
	{ 'RA4_DATAIN'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Data Inicio'															, .T. }, ; //X3_TITULO
	{ 'Fch Inicial'															, .T. }, ; //X3_TITSPA
	{ 'Initial Date'														, .T. }, ; //X3_TITENG
	{ 'Data Inicio'															, .T. }, ; //X3_DESCRIC
	{ 'Fecha Inicial'														, .T. }, ; //X3_DESCSPA
	{ 'Initial Date'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(63) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ 'CTOD("  /  /  ")'													, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(151) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA4'																	, .T. }, ; //X3_ARQUIVO
	{ '16'																	, .T. }, ; //X3_ORDEM
	{ 'RA4_DATAFI'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Data Fim'															, .T. }, ; //X3_TITULO
	{ 'Fch Final'															, .T. }, ; //X3_TITSPA
	{ 'Final Dt'															, .T. }, ; //X3_TITENG
	{ 'Data Fim'															, .T. }, ; //X3_DESCRIC
	{ 'Fecha Final'															, .T. }, ; //X3_DESCSPA
	{ 'Final Date'															, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(63) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ 'CTOD("  /  /  ")'													, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA4'																	, .T. }, ; //X3_ARQUIVO
	{ '17'																	, .T. }, ; //X3_ORDEM
	{ 'RA4_VALOR'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Valor'																, .T. }, ; //X3_TITULO
	{ 'Valor'																, .T. }, ; //X3_TITSPA
	{ 'Value'																, .T. }, ; //X3_TITENG
	{ 'Valor'																, .T. }, ; //X3_DESCRIC
	{ 'Valor'																, .T. }, ; //X3_DESCSPA
	{ 'Value'																, .T. }, ; //X3_DESCENG
	{ '@R 999,999,999.99'													, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(63) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA4'																	, .T. }, ; //X3_ARQUIVO
	{ '18'																	, .T. }, ; //X3_ORDEM
	{ 'RA4_HORAS'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Horas Trein.'														, .T. }, ; //X3_TITULO
	{ 'Horas'																, .T. }, ; //X3_TITSPA
	{ 'Hours'																, .T. }, ; //X3_TITENG
	{ 'Horas Treinamento'													, .T. }, ; //X3_DESCRIC
	{ 'Horas'																, .T. }, ; //X3_DESCSPA
	{ 'Hours'																, .T. }, ; //X3_DESCENG
	{ '999.99'																, .T. }, ; //X3_PICTURE
	{ 'Positivo()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(63) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA4'																	, .T. }, ; //X3_ARQUIVO
	{ '19'																	, .T. }, ; //X3_ORDEM
	{ 'RA4_CALEND'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Calendario'															, .T. }, ; //X3_TITULO
	{ 'Calendario'															, .T. }, ; //X3_TITSPA
	{ 'Schedule'															, .T. }, ; //X3_TITENG
	{ 'Calendario'															, .T. }, ; //X3_DESCRIC
	{ 'Calendario'															, .T. }, ; //X3_DESCSPA
	{ 'Schedule'															, .T. }, ; //X3_DESCENG
	{ '9999'																, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(63) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'RA4'																	, .T. }, ; //X3_ARQUIVO
	{ '20'																	, .T. }, ; //X3_ORDEM
	{ 'RA4_TURMA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Turma'																, .T. }, ; //X3_TITULO
	{ 'Grupo'																, .T. }, ; //X3_TITSPA
	{ 'Division'															, .T. }, ; //X3_TITENG
	{ 'Turma'																, .T. }, ; //X3_DESCRIC
	{ 'Grupo'																, .T. }, ; //X3_DESCSPA
	{ 'Division'															, .T. }, ; //X3_DESCENG
	{ '999'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(63) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela RA7
//
aAdd( aSX3, { ;
	{ 'RA7'																	, .T. }, ; //X3_ARQUIVO
	{ '02'																	, .T. }, ; //X3_ORDEM
	{ 'RA7_MAT'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Matricula'															, .T. }, ; //X3_TITULO
	{ 'Matricula'															, .T. }, ; //X3_TITSPA
	{ 'Registration'														, .T. }, ; //X3_TITENG
	{ 'Matricula'															, .T. }, ; //X3_DESCRIC
	{ 'Matrícula Empleado'													, .T. }, ; //X3_DESCSPA
	{ 'Employee Registration'												, .T. }, ; //X3_DESCENG
	{ '999999'																, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("SRA",M->RA7_MAT)'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(191) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SRA'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '121'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela RA8
//
aAdd( aSX3, { ;
	{ 'RA8'																	, .T. }, ; //X3_ARQUIVO
	{ '06'																	, .T. }, ; //X3_ORDEM
	{ 'RA8_CC'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'C.Custo'																, .T. }, ; //X3_TITULO
	{ 'Centro Costo'														, .T. }, ; //X3_TITSPA
	{ 'Cost Center'															, .T. }, ; //X3_TITENG
	{ 'Centro de Custo'														, .T. }, ; //X3_DESCRIC
	{ 'Centro de Costo'														, .T. }, ; //X3_DESCSPA
	{ 'Cost Center'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'Ctb105CC() .And. Tr130Desc(4)'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(138) + Chr(132) + Chr(191) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CTT'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(198) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ ''																	, .T. }, ; //X3_VISUAL
	{ ''																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '004'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'S'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela RAM
//
aAdd( aSX3, { ;
	{ 'RAM'																	, .T. }, ; //X3_ARQUIVO
	{ '01'																	, .T. }, ; //X3_ORDEM
	{ 'RAM_FILIAL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Filial'																, .T. }, ; //X3_TITULO
	{ 'Sucursal'															, .T. }, ; //X3_TITSPA
	{ 'Branch'																, .T. }, ; //X3_TITENG
	{ 'Filial do Sistema'													, .T. }, ; //X3_DESCRIC
	{ 'Sucursal'															, .T. }, ; //X3_DESCSPA
	{ 'System Branch'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '033'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela RBN
//
aAdd( aSX3, { ;
	{ 'RBN'																	, .T. }, ; //X3_ARQUIVO
	{ '02'																	, .T. }, ; //X3_ORDEM
	{ 'RBN_MAT'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Matricula'															, .T. }, ; //X3_TITULO
	{ 'Matricula'															, .T. }, ; //X3_TITSPA
	{ 'Reg.Number'															, .T. }, ; //X3_TITENG
	{ 'Matricula do funcionario'											, .T. }, ; //X3_DESCRIC
	{ 'Matricula del funcionario'											, .T. }, ; //X3_DESCSPA
	{ 'Employee Regist.Number'												, .T. }, ; //X3_DESCENG
	{ '999999'																, .T. }, ; //X3_PICTURE
	{ 'ExistCpo("SRA")'														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(130) + Chr(132) + Chr(129) + ;
	Chr(132) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(144)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SRA01'																, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(133) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '121'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

//
// Campos Tabela SB1
//
aAdd( aSX3, { ;
	{ 'SB1'																	, .T. }, ; //X3_ARQUIVO
	{ 'T8'																	, .T. }, ; //X3_ORDEM
	{ 'B1_XTPEPI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 25																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo EPI'															, .T. }, ; //X3_TITULO
	{ 'Tipo EPI'															, .T. }, ; //X3_TITSPA
	{ 'Tipo EPI'															, .T. }, ; //X3_TITENG
	{ 'Tipo de EPI'															, .T. }, ; //X3_DESCRIC
	{ 'Tipo de EPI'															, .T. }, ; //X3_DESCSPA
	{ 'Tipo de EPI'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'ZZZ'																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela SQO
//
aAdd( aSX3, { ;
	{ 'SQO'																	, .T. }, ; //X3_ARQUIVO
	{ '06'																	, .T. }, ; //X3_ORDEM
	{ 'QO_PONTOS'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Pontos'																, .T. }, ; //X3_TITULO
	{ 'Puntos'																, .T. }, ; //X3_TITSPA
	{ 'Points'																, .T. }, ; //X3_TITENG
	{ 'Pontos da Questao'													, .T. }, ; //X3_DESCRIC
	{ 'Puntos de la Pregunta'												, .T. }, ; //X3_DESCSPA
	{ 'Question Points'														, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(129) + Chr(128) + Chr(138) + Chr(128) + Chr(129) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela SQP
//
aAdd( aSX3, { ;
	{ 'SQP'																	, .T. }, ; //X3_ARQUIVO
	{ '05'																	, .T. }, ; //X3_ORDEM
	{ 'QP_ALTERNA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Alternativa'															, .T. }, ; //X3_TITULO
	{ 'Alternativa'															, .T. }, ; //X3_TITSPA
	{ 'Alternative'															, .T. }, ; //X3_TITENG
	{ 'Codigo da Alternativa'												, .T. }, ; //X3_DESCRIC
	{ 'Codigo de Alternativa'												, .T. }, ; //X3_DESCSPA
	{ 'Alternative code'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'NaoVazio()'															, .T. }, ; //X3_VALID
	{ Chr(129) + Chr(128) + Chr(138) + Chr(128) + Chr(129) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(150) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'SQP'																	, .T. }, ; //X3_ARQUIVO
	{ '07'																	, .T. }, ; //X3_ORDEM
	{ 'QP_PERCENT'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 2																		, .T. }, ; //X3_DECIMAL
	{ 'Percentual'															, .T. }, ; //X3_TITULO
	{ 'Porcentaje'															, .T. }, ; //X3_TITSPA
	{ 'Percentage'															, .T. }, ; //X3_TITENG
	{ 'Percentual'															, .T. }, ; //X3_DESCRIC
	{ 'Porcentaje'															, .T. }, ; //X3_DESCSPA
	{ 'Percentage'															, .T. }, ; //X3_DESCENG
	{ '@E 999.99'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(129) + Chr(128) + Chr(138) + Chr(128) + Chr(129) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

//
// Campos Tabela TJC
//
aAdd( aSX3, { ;
	{ 'TJC'																	, .T. }, ; //X3_ARQUIVO
	{ '04'																	, .T. }, ; //X3_ORDEM
	{ 'TJC_CODPRO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Produto'																, .T. }, ; //X3_TITULO
	{ 'Produto'																, .T. }, ; //X3_TITSPA
	{ 'Produto'																, .T. }, ; //X3_TITENG
	{ 'Código do Produto Químico'											, .T. }, ; //X3_DESCRIC
	{ 'Código do Produto Químico'											, .T. }, ; //X3_DESCSPA
	{ 'Código do Produto Químico'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'MDT182EXPQ(M->TJC_CODPRO)'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(176)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SB1'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'MDT182WHPR()'														, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '030'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ 'N'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME


//
// Atualizando dicionário
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

aSort( aSX3,,, { |x,y| x[nPosArq][1]+x[nPosOrd][1]+x[nPosCpo][1] < y[nPosArq][1]+y[nPosOrd][1]+y[nPosCpo][1] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG][1] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG][1] ) )
			If aSX3[nI][nPosTam][1] <> SXG->XG_SIZE
				aSX3[nI][nPosTam][1] := SXG->XG_SIZE
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo][1] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq][1] $ cAlias )
		cAlias += aSX3[nI][nPosArq][1] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq][1] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo][1], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq][1] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq][1]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ][1] ) )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo][1] )

	Else

		//
		// Verifica se o campo faz parte de um grupo e ajsuta tamanho
		//
		If !Empty( SX3->X3_GRPSXG ) .AND. SX3->X3_GRPSXG <> aSX3[nI][nPosSXG][1]
			SXG->( dbSetOrder( 1 ) )
			If SXG->( MSSeek( SX3->X3_GRPSXG ) )
				If aSX3[nI][nPosTam][1] <> SXG->XG_SIZE
					aSX3[nI][nPosTam][1] := SXG->XG_SIZE
					AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo][1] + " NÃO atualizado e foi mantido em [" + ;
					AllTrim( Str( SXG->XG_SIZE ) ) + "]"+ CRLF + ;
					"   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF )
				EndIf
			EndIf
		EndIf

		//
		// Verifica todos os campos
		//
		For nJ := 1 To Len( aSX3[nI] )

			//
			// Se o campo estiver diferente da estrutura
			//
			If aSX3[nI][nJ][2]
				cX3Campo := AllTrim( aEstrut[nJ][1] )
				cX3Dado  := SX3->( FieldGet( aEstrut[nJ][2] ) )

				If  aEstrut[nJ][2] > 0 .AND. ;
					PadR( StrTran( AllToChar( cX3Dado ), " ", "" ), 250 ) <> ;
					PadR( StrTran( AllToChar( aSX3[nI][nJ][1] ), " ", "" ), 250 ) .AND. ;
					!cX3Campo == "X3_ORDEM"

					cMsg := "O campo " + aSX3[nI][nPosCpo][1] + " está com o " + cX3Campo + ;
					" com o conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( cX3Dado ) ) + "]" + CRLF + ;
					"que será substituído pelo NOVO conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( aSX3[nI][nJ][1] ) ) + "]" + CRLF + ;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SX3" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SX3 e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SX3 que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
						EndIf

					EndIf

					If nOpcA == 1
						AutoGrLog( "Alterado campo " + aSX3[nI][nPosCpo][1] + CRLF + ;
						"   " + PadR( cX3Campo, 10 ) + " de [" + AllToChar( cX3Dado ) + "]" + CRLF + ;
						"            para [" + AllToChar( aSX3[nI][nJ][1] )           + "]" + CRLF )

						RecLock( "SX3", .F. )
						FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ][1] )
						MsUnLock()
					EndIf

				EndIf

			EndIf

		Next

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX6
Função de processamento da gravação do SX6 - Parâmetros

@author TOTVS Protheus
@since  08/11/2019
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX6()
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lContinua := .T.
Local lReclock  := .T.
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

AutoGrLog( "Ínicio da Atualização" + " SX6" + CRLF )

aEstrut := { "X6_FIL"    , "X6_VAR"    , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , ;
             "X6_DSCSPA1", "X6_DSCENG1", "X6_DESC2"  , "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", ;
             "X6_CONTENG", "X6_PROPRI" , "X6_VALID"  , "X6_INIT"   , "X6_DEFPOR" , "X6_DEFSPA" , "X6_DEFENG" , ;
             "X6_PYME"   }

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_ARQTRAN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica quais arquivos externos a folha de pagto'						, ; //X6_DESCRIC
	'Indica que archivos externos a Liquidacion Haberes'					, ; //X6_DSCSPA
	'Indicate which payroll external files should be'						, ; //X6_DSCENG
	'devem fazer parte da transferência do funcionário.'					, ; //X6_DESC1
	'deben formar parte de transferencia del empleado.'						, ; //X6_DSCSPA1
	'part of the employee´s relocation data.'								, ; //X6_DSCENG1
	'Os arquivos devem conter FILIAL e MATRICULA.'							, ; //X6_DESC2
	'Los archivos deben contener SUCURSAL y MATRICULA.'						, ; //X6_DSCSPA2
	'Files must contain BRANCH and REGISTRATION No.'						, ; //X6_DSCENG2
	'SP2SP5SP8SPBSPCSPESPFSPISPKRF0RFERFF'									, ; //X6_CONTEUD
	'SP2SP5SP8SPBSPCSPESPFSPISPKRF0RFERFF'									, ; //X6_CONTSPA
	'SP2SP5SP8SPBSPCSPESPFSPISPKRF0RFERFF'									, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_BIOVLDR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica o Aparelho de Validação Biométrica sendo'						, ; //X6_DESCRIC
	'Indica el Aparato de Validac. Biometrica donde'						, ; //X6_DSCSPA
	'It indicates Equipment of Biometric Validation,'						, ; //X6_DSCENG
	'Utilizado (1=Nitgen, 2=BioTouch)'										, ; //X6_DESC1
	'se utiliza (1=Nitgen, 2=BioTouch)'										, ; //X6_DSCSPA1
	'Using (1=Nitgen, 2=BioTouch)'											, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'1'																		, ; //X6_CONTSPA
	'1'																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'1'																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_CIPADIA'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Indica quantos dias antes do evento CIPA o sistema'					, ; //X6_DESCRIC
	'Indica cuantos dias antes de evento CIPA el siste'						, ; //X6_DSCSPA
	'It indicates the number of days before CCIPA event'					, ; //X6_DSCENG
	'deve emitir aviso aos usuarios. Ex.: 10'								, ; //X6_DESC1
	'ma debe emitir aviso a los usuarios. Ej.: 10'							, ; //X6_DSCSPA1
	'the system must alert the users. E.g.: 10'								, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'15'																	, ; //X6_CONTEUD
	'365'																	, ; //X6_CONTSPA
	'365'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'10'																	, ; //X6_DEFPOR
	'10'																	, ; //X6_DEFSPA
	'10'																	, ; //X6_DEFENG
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_DEVBIOM'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se utiliza Biometria na Devolução do EPI.'						, ; //X6_DESCRIC
	'Indica si utiliza Biometria en la devoluc.de EPI'						, ; //X6_DSCSPA
	'Indicates whether Biometric Id. is used to return'						, ; //X6_DSCENG
	'1=Sim ou 2=Nao.'														, ; //X6_DESC1
	'1=Si o 2=No.'															, ; //X6_DSCSPA1
	'PPE. 1=Yes or 2=No.'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_DIRACA'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Path onde serao gravados os arquivos DOT na estaca'					, ; //X6_DESCRIC
	'Path donde se grabaran los archivos DOT en la'							, ; //X6_DSCSPA
	'Path where DOT files will be saved'									, ; //X6_DSCENG
	'o de trabalho'															, ; //X6_DESC1
	'estacion de trabajo'													, ; //X6_DSCSPA1
	'in the workstation'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'\SAMPLES\'																, ; //X6_CONTEUD
	'\SAMPLES\'																, ; //X6_CONTSPA
	'\SAMPLES\'																, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_DIREST'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Path onde serao gravados os arquivos DOT na estaca'					, ; //X6_DESCRIC
	'Path donde se grabaran los archivos DOT en la'							, ; //X6_DSCSPA
	'Path where DOT files will be saved in the'								, ; //X6_DSCENG
	'o de trabalho'															, ; //X6_DESC1
	'estacion de trabajo'													, ; //X6_DSCSPA1
	'workstation'															, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'C:\TEMP\'																, ; //X6_CONTEUD
	'C:\TEMP\'																, ; //X6_CONTSPA
	'C:\TEMP\'																, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_EMCONTA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica qual conta utilizada para envio de e-mails'						, ; //X6_DESCRIC
	'Indica que cuenta es utilizada para envio de'							, ; //X6_DSCSPA
	'Indicate the account the system uses to send'							, ; //X6_DSCENG
	'automaticos pelo sistema.'												, ; //X6_DESC1
	'e-mails automaticos por el sistema.'									, ; //X6_DSCSPA1
	'automatic e-mails.'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'workflow@tcp.com.br'													, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_EMSENHA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica qual a senha da conta utilizada para envio'						, ; //X6_DESCRIC
	'Indica cual es la clave de cuenta utilizada para'						, ; //X6_DSCSPA
	'Indicate the account password the system uses'							, ; //X6_DSCENG
	'de e-mails automaticos pelo sistema.'									, ; //X6_DESC1
	'envio de e-mails automaticos por el sistema'							, ; //X6_DSCSPA1
	'to send automatic e-mails.'											, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MCONTAB'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Módulo contábil utilizado pelo Advanced'								, ; //X6_DESCRIC
	'Modulo Contable utilizado por el Advanced'								, ; //X6_DSCSPA
	'Accounting module used by Advanced.'									, ; //X6_DSCENG
	'CTB = SIGACTB (Contabilidade Gerencial)'								, ; //X6_DESC1
	'CTB = SIGACTB (Contabilidad de Gestion)'								, ; //X6_DSCSPA1
	'CTB = SIGACTB (Managerial Accounting)'									, ; //X6_DSCENG1
	'CON = SIGACON (Contabilidade)'											, ; //X6_DESC2
	'CON = SIGACON (Contabilidad)'											, ; //X6_DSCSPA2
	'CON= SIGACON (Accounting).'											, ; //X6_DSCENG2
	'CTB'																	, ; //X6_CONTEUD
	'CTB'																	, ; //X6_CONTSPA
	'CTB'																	, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MDTACSE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se utiliza o semaforo no cadastro dos'							, ; //X6_DESCRIC
	'Indica si utiliza el semaforo en el archivo de los'					, ; //X6_DSCSPA
	'It indicates if it uses semaphor in the accident'						, ; //X6_DSCENG
	'acidentes. (S / N)'													, ; //X6_DESC1
	'accidentes. (S / N)'													, ; //X6_DSCSPA1
	'file. (Y/N)'															, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'S'																		, ; //X6_CONTEUD
	'S'																		, ; //X6_CONTSPA
	'S'																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MDTDTFI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica quais datas serão consideradas na impressão'					, ; //X6_DESCRIC
	'Indica que fechas se consideraran en la impresion'						, ; //X6_DSCSPA
	'Indicates which dates will be considered in'							, ; //X6_DSCENG
	'das seções do P.P.P.'													, ; //X6_DESC1
	'de las secciones del P.P.P.'											, ; //X6_DSCSPA1
	'when printing sections from P.P.P.'									, ; //X6_DSCENG1
	'1 - Responsáveis; 2 - Funcionários'									, ; //X6_DESC2
	'1 - Responsables; 2 - Empleados'										, ; //X6_DSCSPA2
	'1 - Responsible; 2 - Employees'										, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MDTEPID'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se solicita confirmacao de exclusao de Epi'						, ; //X6_DESCRIC
	'Indica si solicita confirmacion de borrado de Epi'						, ; //X6_DSCSPA
	'Indicate if it requests EPI deletion confirmation'						, ; //X6_DSCENG
	'entregue ao funcionario. S=Sim;N=Nao'									, ; //X6_DESC1
	'entregado al empleado. S=Si;N=No'										, ; //X6_DSCSPA1
	'sent to the employee. Y=Yes;N=No'										, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'S'																		, ; //X6_CONTEUD
	'S'																		, ; //X6_CONTSPA
	'S'																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MDTEPIV'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Indica se EPI vencida sera entregue ou nao.'							, ; //X6_DESCRIC
	'Indica si EPI vencida se entregara o no.'								, ; //X6_DSCSPA
	'Indicate whether EPI due will be'										, ; //X6_DSCENG
	'1=Entregar EPI vencida, 2=Nao Entregar ou'								, ; //X6_DESC1
	'1=Entregar EPI vencida, 2=No entregar o'								, ; //X6_DSCSPA1
	'delivered or not.1=Deliver EPI due, 2='								, ; //X6_DSCENG1
	'3=Pergunta se deve ou nao entrega'										, ; //X6_DESC2
	'3=Pregunta si debe o no entregar'										, ; //X6_DSCSPA2
	'Do Not Deliver or 3=Ask whether deliver or not.'						, ; //X6_DSCENG2
	'3'																		, ; //X6_CONTEUD
	'3'																		, ; //X6_CONTSPA
	'3'																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MDTF3CO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica o cadastro que os componentes da CIPA serão'					, ; //X6_DESCRIC
	'Indica el archivo donde se seleccionaran los integ'					, ; //X6_DSCSPA
	'Indicate register in which CIPA members will be'						, ; //X6_DSCENG
	'selecionados. Opções: 1 (Candidatos da CIPA - TNO)'					, ; //X6_DESC1
	'rantes de la CIPA. Opciones: 1 (Candidatos de la C'					, ; //X6_DSCSPA1
	'selected. Options: 1 (CIPA candidates -TNO)'							, ; //X6_DSCENG1
	'ou 2 (Funcionarios - SRA).'											, ; //X6_DESC2
	'IPA o 2 (Empleados - SRA).'											, ; //X6_DSCSPA2
	'or 2 (Employees - SRA).'												, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MDTGPE'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Integracao do SIGAMDT com o SIGAGPE'									, ; //X6_DESCRIC
	'Integracion del SIGAMDT con el SIGAGPE'								, ; //X6_DSCSPA
	'Integration of SIGAMDT with SIGAGPE'									, ; //X6_DSCENG
	'Informar S=Sim ou N=Nao'												, ; //X6_DESC1
	'Informar S=Si o N=No'													, ; //X6_DSCSPA1
	'Enter S=Yes or N=No'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'S'																		, ; //X6_CONTEUD
	'S'																		, ; //X6_CONTSPA
	'S'																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MDTPEPI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo que define se um produto de EPI. Esse tipo'						, ; //X6_DESCRIC
	'Tipo que define si un producto de EPI. Ese tipo'						, ; //X6_DSCSPA
	'Type which defines whether an EPI product. This'						, ; //X6_DSCENG
	'deve estar definido na tabela generica 02.'							, ; //X6_DESC1
	'debe estar definido en tabla generica 02.'								, ; //X6_DSCSPA1
	'type must be defined in a generic table 02.'							, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'ES;MS'																	, ; //X6_CONTEUD
	'ES;MS'																	, ; //X6_CONTSPA
	'ES;MS'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_MDTRESP'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica qual tabela sera utilizada para selecionar'						, ; //X6_DESCRIC
	'Indica que tabla se utilizara para seleccionar'						, ; //X6_DSCSPA
	'Determine the table used to select the company'						, ; //X6_DSCENG
	'o responsavel da empresa na impressao do PPP.'							, ; //X6_DESC1
	'el responsable de la empresa en impresion del PPP.'					, ; //X6_DSCSPA1
	'responsible while printing the PPP'									, ; //X6_DSCENG1
	'1 - Funcionarios(SRA) ou 2 - Usuarios SESMT(TMK)'						, ; //X6_DESC2
	'1 - Empleados(SRA) o 2 - Usuarios SESMT(TMK)'							, ; //X6_DSCSPA2
	'1-Employee (SRA) or 2-SESMT Users (TMK)'								, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'1'																		, ; //X6_CONTSPA
	'1'																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NG2ABON'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigos de Abono que podem ser informados pelo'						, ; //X6_DESCRIC
	'Codigos de Abono que se pueden informar por el'						, ; //X6_DSCSPA
	'Allowance codes that can be informed by the'							, ; //X6_DSCENG
	'programa de Atestado Medico. Insira os codigos'						, ; //X6_DESC1
	'programa de Atestado Medico. Digite los codigos'						, ; //X6_DSCSPA1
	'Medical Attestation program. Enter the code separa'					, ; //X6_DSCENG1
	'separando-os por virgula. Ex: 010,099,023...'							, ; //X6_DESC2
	'separandolos con coma. Ej: 010,099,023...'								, ; //X6_DSCSPA2
	'ting them by commas. E.g.: 010,099,023...'								, ; //X6_DSCENG2
	'001'																	, ; //X6_CONTEUD
	'001'																	, ; //X6_CONTSPA
	'001'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NG2AFAS'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigos de Afastamento que podem ser informados'						, ; //X6_DESCRIC
	'Codigos de licencia que se podran informar por el'						, ; //X6_DSCSPA
	'Absence codes that can be informed by the Med.'						, ; //X6_DSCENG
	'pelo programa de Atestado Medico. Insira os codi-'						, ; //X6_DESC1
	'programa de Atestado Medico. Digite los codigos'						, ; //X6_DSCSPA1
	'Attestation program. Enter the codes separating'						, ; //X6_DSCENG1
	'gos separando-os por virgula. Ex: 1,2,A,6,Q,O...'						, ; //X6_DESC2
	'separandolos con coma. Ej: 1,2,A,6,Q,O...'								, ; //X6_DSCSPA2
	'them by comma. E.g.: 1,2,A,6,Q,0...'									, ; //X6_DSCENG2
	'1,2,A,6,Q,O,P,9'														, ; //X6_CONTEUD
	'9,O,P,Q'																, ; //X6_CONTSPA
	'9,O,P,Q'																, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NG2AUXD'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se gera estabilidade no retorno ao trabalho'					, ; //X6_DESCRIC
	'Indica si genera estabilidad en regreso a trabajo'						, ; //X6_DSCSPA
	'It indicates if stability is generated returning'						, ; //X6_DSCENG
	'apos o termino do auxilio-doenca acidentario.'							, ; //X6_DESC1
	'tras el fin de auxilio enfermedad accidental'							, ; //X6_DSCSPA1
	'to work after end of sickness allowance.'								, ; //X6_DSCENG1
	'1=Gera, 2=Nao gera ou 3=Pergunta se gera ou nao.'						, ; //X6_DESC2
	'1=Genera, 2=No genera o 3=Pregunta si genera o no.'					, ; //X6_DSCSPA2
	'1=Gener., 2=Not gener.or 3=Asks if yes or no'							, ; //X6_DSCENG2
	'3'																		, ; //X6_CONTEUD
	'3'																		, ; //X6_CONTSPA
	'3'																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NG2BIOM'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se utiliza Biometria na Entrega de EPI.'						, ; //X6_DESCRIC
	'Indica si utiliza Biometria en la Entrega de EPI'						, ; //X6_DSCSPA
	'Indica se utiliza Biometria na Entrega de EPI.'						, ; //X6_DSCENG
	'1=Sim ou 2=Não.'														, ; //X6_DESC1
	'1=Si o 2=No.'															, ; //X6_DSCSPA1
	'1=Sim ou 2=Não.'														, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	'2'																		, ; //X6_DEFPOR
	'2'																		, ; //X6_DEFSPA
	'2'																		, ; //X6_DEFENG
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NG2CEPC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se a empresa consiste o EPC'									, ; //X6_DESCRIC
	'Indica si la empresa utiliza el EPC'									, ; //X6_DSCSPA
	'Detrmine if the company holds EPC.'									, ; //X6_DSCENG
	'S=Sim, N=Nao'															, ; //X6_DESC1
	'S=Si, N=No'															, ; //X6_DSCSPA1
	'S=Yes;N=No'															, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'S'																		, ; //X6_CONTEUD
	'S'																		, ; //X6_CONTSPA
	'S'																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NG2CEPI'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se a empresa consiste o EPI'									, ; //X6_DESCRIC
	'Indica si la empresa utiliza el EPI'									, ; //X6_DSCSPA
	'Detrmine if the compny holds EPI.'										, ; //X6_DSCENG
	'S=Sim, N=Nao'															, ; //X6_DESC1
	'S=Si, N=No'															, ; //X6_DSCSPA1
	'S=Yes;N=No'															, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'S'																		, ; //X6_CONTEUD
	'S'																		, ; //X6_CONTSPA
	'S'																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NG2D685'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Indica a quantidade m?nima de dias de afastamento'						, ; //X6_DESCRIC
	'Indica la cantidad minima de dias de licencia'							, ; //X6_DSCSPA
	'Inidcates minimum amount of absence days'								, ; //X6_DSCENG
	'suficiente para gerar automaticamente'									, ; //X6_DESC1
	'suficiente para generar automaticamente'								, ; //X6_DSCSPA1
	'to automatically generate'												, ; //X6_DSCENG1
	'um exame(NR7)de retorno do trabalho.'									, ; //X6_DESC2
	'un examen(NR7)de retorno del trabajo.'									, ; //X6_DSCSPA2
	'an examination (BR7) to return to work'								, ; //X6_DSCENG2
	'0'																		, ; //X6_CONTEUD
	'30'																	, ; //X6_CONTSPA
	'30'																	, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NG2EPDU'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se emite alerta de Epi vencido no cadastro'						, ; //X6_DESCRIC
	'Indica si se emite alerta de Epi vencido en regis'						, ; //X6_DSCSPA
	'It indicates if warning for expired IPE is issued'						, ; //X6_DSCENG
	'Funcionario x Epi (MDTA695). 0=Nao, 1=Somente Epi'						, ; //X6_DESC1
	'Empleado x Epi (MDTA695). 0=No, 1=Solo Epi'							, ; //X6_DSCSPA1
	'in Employee x IPE (MDTA695) Register. 0=No, 1=Only'					, ; //X6_DSCENG1
	'c/ devolucao, 2=Somente Epi s/ devolucao, 3=Todos.'					, ; //X6_DESC2
	'c/ devolucion, 2=Solo Epi s/ devolucion, 3=Todos'						, ; //X6_DSCSPA2
	'IPE w/ return, 2=Only IPE w/o return, 3=All.'							, ; //X6_DSCENG2
	'3'																		, ; //X6_CONTEUD
	'3'																		, ; //X6_CONTSPA
	'3'																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NG2EPIB'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se será bloqueado o Epi,'										, ; //X6_DESCRIC
	'Indica si se bloqueará el EPI,'										, ; //X6_DSCSPA
	'Indicates if the Epi will be blocked,'									, ; //X6_DSCENG
	'após a impressão do relatório.'										, ; //X6_DESC1
	'después de imprimir el informe.'										, ; //X6_DSCSPA1
	'after printing the report.'											, ; //X6_DSCENG1
	'1 = Bloqueado ou  2 = Não Bloqueado.'									, ; //X6_DESC2
	'1 = Bloqueado o  2 = No bloqueado.'									, ; //X6_DSCSPA2
	'1 = Blocked or  2 = Not Blocked.'										, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'1'																		, ; //X6_CONTSPA
	'1'																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NG2ESTN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se o sistema ira trabalhar com estoque'							, ; //X6_DESCRIC
	'Indica si el sistema trabajara con stock de medica'					, ; //X6_DSCSPA
	'It informs whether the system will work with a neg'					, ; //X6_DSCENG
	'de medicamentos negativo. S-SIM N-NAO'									, ; //X6_DESC1
	'mentos negativo. S-SI N-NO'											, ; //X6_DSCSPA1
	'ative stock of medicine. S=Yes ; N=No.'								, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'S'																		, ; //X6_CONTEUD
	'S'																		, ; //X6_CONTSPA
	'S'																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NG2EXCC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se a programacao de exames sera feita com'						, ; //X6_DESCRIC
	'Indica si la programacion de examenes se hara con'						, ; //X6_DSCSPA
	'It indicates if exam schedules are made with'							, ; //X6_DSCENG
	'filtragem dos funcionarios de acordo com o codigo'						, ; //X6_DESC1
	'filtrado de los empleados de acuerdo con el codigo'					, ; //X6_DSCSPA1
	'filter of employees according to the code'								, ; //X6_DSCENG1
	'do centro de custo. (S / N)'											, ; //X6_DESC2
	'del centro de costo. (S / N)'											, ; //X6_DSCSPA2
	'of the cost center. (Y/N)'												, ; //X6_DSCENG2
	'N'																		, ; //X6_CONTEUD
	'N'																		, ; //X6_CONTSPA
	'N'																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NG2INVE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se deve ser trocado na impressao do PPP o'						, ; //X6_DESCRIC
	'Indica si debe cambiarse en la impresion del PPP'						, ; //X6_DSCSPA
	'Determine if the Job column content must be'							, ; //X6_DSCENG
	'conteudo da coluna do Cargo com a coluna da Funcao'					, ; //X6_DESC1
	'el contenido de la columna del Cargo con la colum'						, ; //X6_DSCSPA1
	'changed with Position column while printing the'						, ; //X6_DSCENG1
	'S=Sim;N=Nao'															, ; //X6_DESC2
	'na de la Funcion S=Si;N=No'											, ; //X6_DSCSPA2
	'PPP. Y=YES;N=NO'														, ; //X6_DSCENG2
	'N'																		, ; //X6_CONTEUD
	'N'																		, ; //X6_CONTSPA
	'N'																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NG2SA'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se gera solicitacao ao armazem ao inves de'						, ; //X6_DESCRIC
	'Indica si genera solicitud al armazem en vez de'						, ; //X6_DSCSPA
	'It indicates if warehouse request is generated'						, ; //X6_DSCENG
	'baixar do estoque. S=Sim;N=Nao'										, ; //X6_DESC1
	'bajar del stock. S=Si;N=No'											, ; //X6_DSCSPA1
	'instead of write it off from stock. S=Yes;N=No'						, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'S'																		, ; //X6_CONTEUD
	'S'																		, ; //X6_CONTSPA
	'S'																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NGEPICC'															, ; //X6_VAR
	'N'																		, ; //X6_TIPO
	'Indica se e permitido excluir o EPI que esta'							, ; //X6_DESCRIC
	'Indica si se permite borrar el EPI que esta'							, ; //X6_DSCSPA
	'Indicates whether it is allowed to delete the EPI'						, ; //X6_DSCENG
	'entregue a um funcionario, sendo que o EPI esta'						, ; //X6_DESC1
	'relacionada a un empleado del mismo centro'							, ; //X6_DSCSPA1
	'related to an employee of the same Cost Center'						, ; //X6_DSCENG1
	'vinculado ao C. Custo ou a Funcao. 1=Sim; 2=Nao.'						, ; //X6_DESC2
	'de costo o funcion. 1 = Si; 2 = No'									, ; //X6_DSCSPA2
	'or Role. 1 = Yes; 2 = No'												, ; //X6_DSCENG2
	'1'																		, ; //X6_CONTEUD
	'1'																		, ; //X6_CONTSPA
	'1'																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NGEPIEN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'"Define se a entrega de EPI será permitida caso"'						, ; //X6_DESCRIC
	'"Define si se permitira la entrega de EPI si"'							, ; //X6_DSCSPA
	'It defines if IPE delivery is allowed whether'							, ; //X6_DSCENG
	'" o funcionário não esteja com situação ativa.  "'						, ; //X6_DESC1
	'"el empleado no esta con situac. activa."'								, ; //X6_DSCSPA1
	'employee has not active situation.'									, ; //X6_DSCENG1
	'"Ex: S=Permite/N=Não Permite"'											, ; //X6_DESC2
	'"Ej: S=Permite/N=No Permite"'											, ; //X6_DSCSPA2
	'Ex: Y=Allows/N=Does not Allow'											, ; //X6_DSCENG2
	'S'																		, ; //X6_CONTEUD
	'S'																		, ; //X6_CONTSPA
	'S'																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NGFORPD'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Define o codigo do fornecedor padrão para ser'							, ; //X6_DESCRIC
	'Define codigo de proveedor estandar para ser'							, ; //X6_DSCSPA
	'It defines the code of standard supplier to be'						, ; //X6_DSCENG
	'utilizado na entrega de Epis da rotina de'								, ; //X6_DESC1
	'utilizado en entrega de Epis de rutina de'								, ; //X6_DSCSPA1
	'used in IPEs delivery of the routine'									, ; //X6_DSCENG1
	'Funcionário x Epi.Informar codigo+loja.Ex:0000010'						, ; //X6_DESC2
	'Empleado vs Epi.Informar codigo+Tda.Ej:000010'							, ; //X6_DSCSPA2
	'Employee x IPE. Indicate code+store. Ex:0000010'						, ; //X6_DSCENG2
	''																		, ; //X6_CONTEUD
	''																		, ; //X6_CONTSPA
	''																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NGMDTAF'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se o Funcionario devera ser afastado do'						, ; //X6_DESCRIC
	'Indica si el empleado debe salir de licencia de'						, ; //X6_DSCSPA
	'It informs whether the Employee should be absent'						, ; //X6_DSCENG
	'trabalho apos o Atestado Medico    S-SIM N-NAO'						, ; //X6_DESC1
	'trabajo tras el Atestado Medico    S-SI N-NO'							, ; //X6_DSCSPA1
	'from work after Medical Attestation. S=Yes;N=No.'						, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'S'																		, ; //X6_CONTEUD
	'S'																		, ; //X6_CONTSPA
	'S'																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'N'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NGMDTES'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Integracao do SIGAMDT com o Estoque'									, ; //X6_DESCRIC
	'Integracion del SIGAMDT con el Stock'									, ; //X6_DSCSPA
	'Integration of SIGAMDT with Inventory'									, ; //X6_DSCENG
	'Informar S=Sim ou N=Nao'												, ; //X6_DESC1
	'Informar S=Si o N=No'													, ; //X6_DSCSPA1
	'Enter S=Yes or N=No'													, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'S'																		, ; //X6_CONTEUD
	'S'																		, ; //X6_CONTSPA
	'S'																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_NGSERVE'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Identifica o caminho do servidor para acessar os'						, ; //X6_DESCRIC
	'Identifica el camino del servidor en el acceso a'						, ; //X6_DSCSPA
	'It identifies the server path to access the files'						, ; //X6_DSCENG
	'arquivos necessarios para montar graficos.'							, ; //X6_DESC1
	'los archivos neces. para hacer graficos.'								, ; //X6_DSCSPA1
	'necessary to set up charts.'											, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'\\AP7\SIGAADV\'														, ; //X6_CONTEUD
	'\\AP7\SIGAADV\'														, ; //X6_CONTSPA
	'\\AP7\SIGAADV\'														, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_PPPRISC'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Indica se o relatorio PPP listara somente funcio-'						, ; //X6_DESCRIC
	'Indica si el informe PPP listara solamente emplead'					, ; //X6_DSCSPA
	'Indicates if PPP report must list only employees'						, ; //X6_DSCENG
	'narios expostos a riscos ambientais. S=SIM / N=NAO'					, ; //X6_DESC1
	'dos expuestos a riesgos ambientales. S=SI / N=NO'						, ; //X6_DSCSPA1
	'exposed to environmental risks. S=Yes/N=No'							, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'N'																		, ; //X6_CONTEUD
	'N'																		, ; //X6_CONTSPA
	'N'																		, ; //X6_CONTENG
	''																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	''																		} ) //X6_PYME

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .F.
	lReclock  := .F.

	If !SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lContinua := .T.
		lReclock  := .T.
		AutoGrLog( "Foi incluído o parâmetro " + aSX6[nI][1] + aSX6[nI][2] + " Conteúdo [" + AllTrim( aSX6[nI][13] ) + "]" )
	Else
		lContinua := .T.
		lReclock  := .F.
		If !StrTran( SX6->X6_CONTEUD, " ", "" ) == StrTran( aSX6[nI][13], " ", "" )

			cMsg := "O parâmetro " + aSX6[nI][2] + " está com o conteúdo" + CRLF + ;
			"[" + RTrim( StrTran( SX6->X6_CONTEUD, " ", "" ) ) + "]" + CRLF + ;
			", que é será substituido pelo NOVO conteúdo " + CRLF + ;
			"[" + RTrim( StrTran( aSX6[nI][13]   , " ", "" ) ) + "]" + CRLF + ;
			"Deseja substituir ? "

			If      lTodosSim
				nOpcA := 1
			ElseIf  lTodosNao
				nOpcA := 2
			Else
				nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SX6" )
				lTodosSim := ( nOpcA == 3 )
				lTodosNao := ( nOpcA == 4 )

				If lTodosSim
					nOpcA := 1
					lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SX6 e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
				EndIf

				If lTodosNao
					nOpcA := 2
					lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SX6 que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
				EndIf

			EndIf

			lContinua := ( nOpcA == 1 )

			If lContinua
				AutoGrLog( "Foi alterado o parâmetro " + aSX6[nI][1] + aSX6[nI][2] + " de [" + ;
				AllTrim( SX6->X6_CONTEUD ) + "]" + " para [" + AllTrim( aSX6[nI][13] ) + "]" )
			EndIf

		Else
			lContinua := .F.
		EndIf
	EndIf

	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf

		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
	EndIf

	oProcess:IncRegua2( "Atualizando Arquivos (SX6)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX5
Função de processamento da gravação do SX5 - Indices

@author TOTVS Protheus
@since  08/11/2019
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX5()
Local aEstrut   := {}
Local aSX5      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamFil   := Len( SX5->X5_FILIAL )

AutoGrLog( "Ínicio da Atualização SX5" + CRLF )

aEstrut := { "X5_FILIAL", "X5_TABELA", "X5_CHAVE", "X5_DESCRI", "X5_DESCSPA", "X5_DESCENG" }

//
// Tabela 00
//
aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'00'																	, ; //X5_TABELA
	'XE'																	, ; //X5_CHAVE
	'TIPO EPI'																, ; //X5_DESCRI
	'TIPO EPI'																, ; //X5_DESCSPA
	'TIPO EPI'																} ) //X5_DESCENG

//
// Tabela XE
//
aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'XE'																	, ; //X5_TABELA
	'01'																	, ; //X5_CHAVE
	'CABECA'																, ; //X5_DESCRI
	'CABECA'																, ; //X5_DESCSPA
	'CABECA'																} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'XE'																	, ; //X5_TABELA
	'02'																	, ; //X5_CHAVE
	'PESCOCO'																, ; //X5_DESCRI
	'PESCOCO'																, ; //X5_DESCSPA
	'PESCOCO'																} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'XE'																	, ; //X5_TABELA
	'03'																	, ; //X5_CHAVE
	'BRACOS'																, ; //X5_DESCRI
	'BRACOS'																, ; //X5_DESCSPA
	'BRACOS'																} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'XE'																	, ; //X5_TABELA
	'04'																	, ; //X5_CHAVE
	'MAOS'																	, ; //X5_DESCRI
	'MAOS'																	, ; //X5_DESCSPA
	'MAOS'																	} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'XE'																	, ; //X5_TABELA
	'05'																	, ; //X5_CHAVE
	'TRONCO'																, ; //X5_DESCRI
	'TRONCO'																, ; //X5_DESCSPA
	'TRONCO'																} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'XE'																	, ; //X5_TABELA
	'06'																	, ; //X5_CHAVE
	'PERNAS'																, ; //X5_DESCRI
	'PERNAS'																, ; //X5_DESCSPA
	'PERNAS'																} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'XE'																	, ; //X5_TABELA
	'07'																	, ; //X5_CHAVE
	'PE'																	, ; //X5_DESCRI
	'PE'																	, ; //X5_DESCSPA
	'PE'																	} ) //X5_DESCENG

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX5 ) )

dbSelectArea( "SX5" )
SX5->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSX5 )

	oProcess:IncRegua2( "Atualizando tabelas..." )

	If !SX5->( dbSeek( PadR( aSX5[nI][1], nTamFil ) + aSX5[nI][2] + aSX5[nI][3] ) )
		AutoGrLog( "Item da tabela criado. Tabela " + AllTrim( aSX5[nI][1] ) + aSX5[nI][2] + "/" + aSX5[nI][3] )
		RecLock( "SX5", .T. )
	Else
		AutoGrLog( "Item da tabela alterado. Tabela " + AllTrim( aSX5[nI][1] ) + aSX5[nI][2] + "/" + aSX5[nI][3] )
		RecLock( "SX5", .F. )
	EndIf

	For nJ := 1 To Len( aSX5[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSX5[nI][nJ] )
		EndIf
	Next nJ

	MsUnLock()

	aAdd( aArqUpd, aSX5[nI][1] )

	If !( aSX5[nI][1] $ cAlias )
		cAlias += aSX5[nI][1] + "/"
	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX5" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lOk       := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), oDlg:End()  ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  08/11/2019
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  08/11/2019
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet


/////////////////////////////////////////////////////////////////////////////
