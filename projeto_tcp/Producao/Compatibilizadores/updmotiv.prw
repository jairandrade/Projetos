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
/*/{Protheus.doc} UPDMOTIV
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  16/07/2019
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDMOTIV( cEmpAmb, cFilAmb )

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
					MsgStop( "Atualização Realizada.", "UPDMOTIV" )
				Else
					MsgStop( "Atualização não Realizada.", "UPDMOTIV" )
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
			MsgStop( "Atualização não Realizada.", "UPDMOTIV" )

		EndIf

	Else
		MsgStop( "Atualização não Realizada.", "UPDMOTIV" )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  16/07/2019
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
			// Atualiza o dicionário SX2
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX2()

			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()

			//------------------------------------
			// Atualiza o dicionário SIX
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSIX()

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
			//FSAtuSX6()

			//------------------------------------
			// Atualiza o dicionário SXB
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de consultas padrão" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXB()

			//------------------------------------
			// Atualiza o dicionário SX5
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de tabelas sistema" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX5()

			//------------------------------------
			// Atualiza o dicionário SX1
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de perguntas" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX1()

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
/*/{Protheus.doc} FSAtuSX2
Função de processamento da gravação do SX2 - Arquivos

@author TOTVS Protheus
@since  16/07/2019
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2()
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cCpoUpd   := "X2_ROTINA /X2_UNICO  /X2_DISPLAY/X2_SYSOBJ /X2_USROBJ /X2_POSLGT /"
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SX2" + CRLF )

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"   , "X2_NOMESPA", "X2_NOMEENG", "X2_MODO"   , ;
             "X2_TTS"    , "X2_ROTINA" , "X2_PYME"   , "X2_UNICO"  , "X2_DISPLAY", "X2_SYSOBJ" , "X2_USROBJ" , ;
             "X2_POSLGT" , "X2_CLOB"   , "X2_AUTREC" , "X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }


dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Tabela ZZR
//
aAdd( aSX2, { ;
	'ZZR'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'ZZR'+cEmpr																, ; //X2_ARQUIVO
	'MOTIVOS DE COBRANCA'													, ; //X2_NOME
	'MOTIVOS DE COBRANCA'													, ; //X2_NOMESPA
	'MOTIVOS DE COBRANCA'													, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2)..." )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			AutoGrLog( "Foi incluída a tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		MsUnLock()

	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
			RecLock( "SX2", .F. )
			SX2->X2_UNICO := aSX2[nI][12]
			MsUnlock()

			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
			EndIf

			AutoGrLog( "Foi alterada a chave única da tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .F. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If PadR( aEstrut[nJ], 10 ) $ cCpoUpd
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf

			EndIf
		Next nJ
		MsUnLock()

	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  16/07/2019
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
// Campos Tabela SA1
//
aAdd( aSX3, { ;
	{ 'SA1'																	, .T. }, ; //X3_ARQUIVO
	{ 'R2'																	, .T. }, ; //X3_ORDEM
	{ 'A1_XGREMPR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'GR Empresa'															, .T. }, ; //X3_TITULO
	{ 'GR Empresa'															, .T. }, ; //X3_TITSPA
	{ 'GR Empresa'															, .T. }, ; //X3_TITENG
	{ 'Grupo Empresarial'													, .T. }, ; //X3_DESCRIC
	{ 'Grupo Empresarial'													, .T. }, ; //X3_DESCSPA
	{ 'Grupo Empresarial'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)									, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ 'ExistCpo("SX5","GR"+M->A1_XGREMPR) .or. Vazio()'						, .T. }, ; //X3_VLDUSER
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
// Campos Tabela ZZR
//
aAdd( aSX3, { ;
	{ 'ZZR'																	, .T. }, ; //X3_ARQUIVO
	{ '01'																	, .T. }, ; //X3_ORDEM
	{ 'ZZR_FILIAL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Filial'																, .T. }, ; //X3_TITULO
	{ 'Sucursal'															, .T. }, ; //X3_TITSPA
	{ 'Branch'																, .T. }, ; //X3_TITENG
	{ 'Filial do Sistema'													, .T. }, ; //X3_DESCRIC
	{ 'Sucursal'															, .T. }, ; //X3_DESCSPA
	{ 'Branch of the System'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ 'U'																	, .T. }, ; //X3_PROPRI
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
	{ '033'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ ''																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'ZZR'																	, .T. }, ; //X3_ARQUIVO
	{ '02'																	, .T. }, ; //X3_ORDEM
	{ 'ZZR_PREFIX'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Prefixo'																, .T. }, ; //X3_TITULO
	{ 'Prefixo'																, .T. }, ; //X3_TITSPA
	{ 'Prefixo'																, .T. }, ; //X3_TITENG
	{ 'Prefixo'																, .T. }, ; //X3_DESCRIC
	{ 'Prefixo'																, .T. }, ; //X3_DESCSPA
	{ 'Prefixo'																, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'ZZR'																	, .T. }, ; //X3_ARQUIVO
	{ '03'																	, .T. }, ; //X3_ORDEM
	{ 'ZZR_NUM'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nr Titulo'															, .T. }, ; //X3_TITULO
	{ 'Nr Titulo'															, .T. }, ; //X3_TITSPA
	{ 'Nr Titulo'															, .T. }, ; //X3_TITENG
	{ 'Numero do Titulo'													, .T. }, ; //X3_DESCRIC
	{ 'Numero do Titulo'													, .T. }, ; //X3_DESCSPA
	{ 'Numero do Titulo'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'ZZR'																	, .T. }, ; //X3_ARQUIVO
	{ '04'																	, .T. }, ; //X3_ORDEM
	{ 'ZZR_PARCEL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Parcela'																, .T. }, ; //X3_TITULO
	{ 'Parcela'																, .T. }, ; //X3_TITSPA
	{ 'Parcela'																, .T. }, ; //X3_TITENG
	{ 'Parcela'																, .T. }, ; //X3_DESCRIC
	{ 'Parcela'																, .T. }, ; //X3_DESCSPA
	{ 'Parcela'																, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'ZZR'																	, .T. }, ; //X3_ARQUIVO
	{ '05'																	, .T. }, ; //X3_ORDEM
	{ 'ZZR_TIPO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 3																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo'																, .T. }, ; //X3_TITULO
	{ 'Tipo'																, .T. }, ; //X3_TITSPA
	{ 'Tipo'																, .T. }, ; //X3_TITENG
	{ 'Tipo'																, .T. }, ; //X3_DESCRIC
	{ 'Tipo'																, .T. }, ; //X3_DESCSPA
	{ 'Tipo'																, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'ZZR'																	, .T. }, ; //X3_ARQUIVO
	{ '06'																	, .T. }, ; //X3_ORDEM
	{ 'ZZR_DATA'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Data'																, .T. }, ; //X3_TITULO
	{ 'Data'																, .T. }, ; //X3_TITSPA
	{ 'Data'																, .T. }, ; //X3_TITENG
	{ 'Data'																, .T. }, ; //X3_DESCRIC
	{ 'Data'																, .T. }, ; //X3_DESCSPA
	{ 'Data'																, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'ZZR'																	, .T. }, ; //X3_ARQUIVO
	{ '07'																	, .T. }, ; //X3_ORDEM
	{ 'ZZR_HORA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 5																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Hora'																, .T. }, ; //X3_TITULO
	{ 'Hora'																, .T. }, ; //X3_TITSPA
	{ 'Hora'																, .T. }, ; //X3_TITENG
	{ 'Hora'																, .T. }, ; //X3_DESCRIC
	{ 'Hora'																, .T. }, ; //X3_DESCSPA
	{ 'Hora'																, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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

aAdd( aSX3, { ;
	{ 'ZZR'																	, .T. }, ; //X3_ARQUIVO
	{ '08'																	, .T. }, ; //X3_ORDEM
	{ 'ZZR_MOTIVO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Motivo'																, .T. }, ; //X3_TITULO
	{ 'Motivo'																, .T. }, ; //X3_TITSPA
	{ 'Motivo'																, .T. }, ; //X3_TITENG
	{ 'Motivo de Cobrança'													, .T. }, ; //X3_DESCRIC
	{ 'Motivo de Cobrança'													, .T. }, ; //X3_DESCSPA
	{ 'Motivo de Cobrança'													, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SX5XM'																, .T. }, ; //X3_F3
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

aAdd( aSX3, { ;
	{ 'ZZR'																	, .T. }, ; //X3_ARQUIVO
	{ '09'																	, .T. }, ; //X3_ORDEM
	{ 'ZZR_USER'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Usuário'																, .T. }, ; //X3_TITULO
	{ 'Usuário'																, .T. }, ; //X3_TITSPA
	{ 'Usuário'																, .T. }, ; //X3_TITENG
	{ 'Usuário'																, .T. }, ; //X3_DESCRIC
	{ 'Usuário'																, .T. }, ; //X3_DESCSPA
	{ 'Usuário'																, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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

aAdd( aSX3, { ;
	{ 'ZZR'																	, .T. }, ; //X3_ARQUIVO
	{ '10'																	, .T. }, ; //X3_ORDEM
	{ 'ZZR_JUSTIF'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 255																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Justificativ'														, .T. }, ; //X3_TITULO
	{ 'Justificativ'														, .T. }, ; //X3_TITSPA
	{ 'Justificativ'														, .T. }, ; //X3_TITENG
	{ 'Justificativa'														, .T. }, ; //X3_DESCRIC
	{ 'Justificativa'														, .T. }, ; //X3_DESCSPA
	{ 'Justificativa'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ ''																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ ''																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'ZZR'																	, .T. }, ; //X3_ARQUIVO
	{ '11'																	, .T. }, ; //X3_ORDEM
	{ 'ZZR_CONTAT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 50																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Contato'																, .T. }, ; //X3_TITULO
	{ 'Contato'																, .T. }, ; //X3_TITSPA
	{ 'Contato'																, .T. }, ; //X3_TITENG
	{ 'Contato'																, .T. }, ; //X3_DESCRIC
	{ 'Contato'																, .T. }, ; //X3_DESCSPA
	{ 'Contato'																, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ '€'																	, .T. }, ; //X3_OBRIGAT
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
/*/{Protheus.doc} FSAtuSIX
Função de processamento da gravação do SIX - Indices

@author TOTVS Protheus
@since  16/07/2019
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX()
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SIX" + CRLF )

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela SA1
//
aAdd( aSIX, { ;
	'SA1'																	, ; //INDICE
	'D'																		, ; //ORDEM
	'A1_FILIAL+A1_ARGUS'													, ; //CHAVE
	'Cod. Argus'															, ; //DESCRICAO
	'Cod. Argus'															, ; //DESCSPA
	'Cod. Argus'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela ZZR
//
aAdd( aSIX, { ;
	'ZZR'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'ZZR_FILIAL+ZZR_PREFIX+ZZR_NUM+ZZR_PARCEL+ZZR_TIPO+ZZR_DATA+ZZR_HORA'		, ; //CHAVE
	'Prefixo+Nr Titulo+Parcela+Tipo+Data+Hora'								, ; //DESCRICAO
	'Prefixo+Nr Titulo+Parcela+Tipo+Data+Hora'								, ; //DESCSPA
	'Prefixo+Nr Titulo+Parcela+Tipo+Data+Hora'								, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt    := .F.
	lDelInd := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		AutoGrLog( "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
	Else
		lAlt := .T.
		aAdd( aArqUpd, aSIX[nI][1] )
		If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "" ) == ;
		    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			AutoGrLog( "Chave do índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
			lDelInd := .T. // Se for alteração precisa apagar o indice do banco
		EndIf
	EndIf

	RecLock( "SIX", !lAlt )
	For nJ := 1 To Len( aSIX[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
		EndIf
	Next nJ
	MsUnLock()

	dbCommit()

	If lDelInd
		TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
	EndIf

	oProcess:IncRegua2( "Atualizando índices..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXB
Função de processamento da gravação do SXB - Consultas Padrao

@author TOTVS Protheus
@since  16/07/2019
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXB()
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0

AutoGrLog( "Ínicio da Atualização" + " SXB" + CRLF )

aEstrut := { "XB_ALIAS"  , "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , "XB_DESCRI" , "XB_DESCSPA", "XB_DESCENG", ;
             "XB_WCONTEM", "XB_CONTEM" }


//
// Consulta A1A2F8
//
aAdd( aSXB, { ;
	'A1A2F8'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente x Fornecedor'													, ; //XB_DESCRI
	'Cliente vs Proveed'													, ; //XB_DESCSPA
	'Client x Supplier'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1A2F8'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo + Loja'															, ; //XB_DESCRI
	'Codigo + Tienda'														, ; //XB_DESCSPA
	'Code + Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1A2F8'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_FILIAL'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1A2F8'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1A2F8'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1A2F8'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1A2F8'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1A2F8'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

//
// Consulta A1VXTR
//
aAdd( aSXB, { ;
	'A1VXTR'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1VXTR'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo+Loja'															, ; //XB_DESCRI
	'Codigo+Tienda'															, ; //XB_DESCSPA
	'Code+Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1VXTR'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1VXTR'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'RCPJ'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1VXTR'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1VXTR'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1VXTR'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1VXTR'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'RCPJ'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1VXTR'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1VXTR'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'RCPJ'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1VXTR'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'RCPJ'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1VXTR'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1VXTR'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1VXTR'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'A1VXTR'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'left(SA1->A1_CGC,8) == left(SM0->M0_CGC,8) .and. SA1->A1_CGC # SM0->M0_CGC'} ) //XB_CONTEM

//
// Consulta AOECMP
//
aAdd( aSXB, { ;
	'AOECMP'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Cons.Cmp Estrangeiro'													, ; //XB_DESCRI
	'Cons.Cmp Extranjero'													, ; //XB_DESCSPA
	'Foreign Cmp. Query'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AOECMP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CRM280CMPC()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AOECMP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CRM280CMPR()'															} ) //XB_CONTEM

//
// Consulta AOEORD
//
aAdd( aSXB, { ;
	'AOEORD'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Cons. Padrão Ordem'													, ; //XB_DESCRI
	'Cons. Estandar Orden'													, ; //XB_DESCSPA
	'Order Standard Query'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AOEORD'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CRM280ORDC()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AOEORD'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CRM280ORDR()'															} ) //XB_CONTEM

//
// Consulta AOEORI
//
aAdd( aSXB, { ;
	'AOEORI'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Cons.Chv de Origem'													, ; //XB_DESCRI
	'Cons.Clv de Origen'													, ; //XB_DESCSPA
	'Source Key Query'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AOEORI'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CRM280ORIC()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AOEORI'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CRM280ORIR()'															} ) //XB_CONTEM

//
// Consulta AOESEQ
//
aAdd( aSXB, { ;
	'AOESEQ'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Inf.Priorização'														, ; //XB_DESCRI
	'Inf.Priorización'														, ; //XB_DESCSPA
	'Prioritization Inf.'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AOESEQ'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CRM200F3Ord()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AOESEQ'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CRM200ORIR()'															} ) //XB_CONTEM

//
// Consulta AONREG
//
aAdd( aSXB, { ;
	'AONREG'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Retorna Chave do Reg'													, ; //XB_DESCRI
	'Devuelve clave reg.'													, ; //XB_DESCSPA
	'Returns Rec Key'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AONREG'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CRMA580Cons()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AONREG'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CRMA580RChv()'															} ) //XB_CONTEM

//
// Consulta AVE001
//
aAdd( aSXB, { ;
	'AVE001'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Importadores'															, ; //XB_DESCRI
	'Importadores'															, ; //XB_DESCSPA
	'Importers'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE001'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE001'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE001'																, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE001'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE001'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE001'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE001'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE001'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE001'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE001'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE001'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE001'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"SA1->A1_TIPCLI $ '1/4'"												} ) //XB_CONTEM

//
// Consulta AVE002
//
aAdd( aSXB, { ;
	'AVE002'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cadastro de Clientes'													, ; //XB_DESCRI
	'Archivo de Clientes'													, ; //XB_DESCSPA
	'Customer File'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE002'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE002'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE002'																, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE002'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE002'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE002'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE002'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE002'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE002'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE002'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE002'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE002'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"SA1->A1_TIPCLI $ '1/2/3/4'"											} ) //XB_CONTEM

//
// Consulta AVE003
//
aAdd( aSXB, { ;
	'AVE003'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consignatários'														, ; //XB_DESCRI
	'Consignatarios'														, ; //XB_DESCSPA
	'Consignee'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE003'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE003'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE003'																, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE003'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE003'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE003'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE003'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE003'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE003'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE003'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE003'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE003'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"SA1->A1_TIPCLI $ '2/4'"												} ) //XB_CONTEM

//
// Consulta AVE004
//
aAdd( aSXB, { ;
	'AVE004'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Notify'																, ; //XB_DESCRI
	'Notify'																, ; //XB_DESCSPA
	'Notify'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE004'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE004'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE004'																, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE004'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE004'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE004'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE004'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE004'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE004'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE004'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE004'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE004'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_NOME'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'AVE004'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"SA1->A1_TIPCLI $ '3/4'"												} ) //XB_CONTEM

//
// Consulta B80
//
aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CGC'																	, ; //XB_DESCRI
	'CGC'																	, ; //XB_DESCSPA
	'CGC Number'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Codigo da Empresa'														, ; //XB_DESCRI
	'Codigo de la Empresa'													, ; //XB_DESCSPA
	'Company Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'CGC'																	, ; //XB_DESCRI
	'CGC'																	, ; //XB_DESCSPA
	'CGC Number'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo da Empresa'														, ; //XB_DESCRI
	'Codigo de la Empresa'													, ; //XB_DESCSPA
	'Company Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CODEMP'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_CODEMP'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'B80'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	''																		, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_YTIPCLI=="E"'													} ) //XB_CONTEM

//
// Consulta CF8A1
//
aAdd( aSXB, { ;
	'CF8A1'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CF8A1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo + Loja'															, ; //XB_DESCRI
	'Codigo + Tienda'														, ; //XB_DESCSPA
	'Code + Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CF8A1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_FILIAL'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CF8A1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CF8A1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CF8A1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CF8A1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CF8A1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

//
// Consulta CLF
//
aAdd( aSXB, { ;
	'CLF'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Cliente/Fornecedor'													, ; //XB_DESCRI
	'Cliente/Proveedor'														, ; //XB_DESCSPA
	'Customer/Supplier'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLF'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'M145COK(,"CLF")'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLF'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'If(Alias()=="SA2",A2_COD,A1_COD)'										} ) //XB_CONTEM

//
// Consulta CLI
//
aAdd( aSXB, { ;
	'CLI'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLI'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLI'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLI'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'CNPJ'																	, ; //XB_DESCSPA
	'CNPJ  Number'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLI'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLI'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLI'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLI'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLI'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLI'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLI'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLI'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'CNPJ'																	, ; //XB_DESCSPA
	'CNPJ Number'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLI'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLI'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

//
// Consulta CLJ
//
aAdd( aSXB, { ;
	'CLJ'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Loja de Clientes'														, ; //XB_DESCRI
	'Tienda de Clientes'													, ; //XB_DESCSPA
	'Customer store'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLJ'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo+Loja'															, ; //XB_DESCRI
	'Codigo+Tienda'															, ; //XB_DESCSPA
	'Code+Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLJ'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome+Loja'																, ; //XB_DESCRI
	'Nombre+tienda'															, ; //XB_DESCSPA
	'Name+Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLJ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLJ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLJ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLJ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLJ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLJ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLJ'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

//
// Consulta CLL
//
aAdd( aSXB, { ;
	'CLL'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLL'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLL'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLL'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLL'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLL'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLL'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLL'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLL'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLL'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLL'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD + SA1->A1_LOJA'											} ) //XB_CONTEM

//
// Consulta CLT
//
aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1FTMKPO();Prospect;SUS->US_COD;SUS->US_LOJA'							} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'RCPJ'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Tel'																	, ; //XB_DESCRI
	'Tel'																	, ; //XB_DESCSPA
	'Phone'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(SA1->A1_NOME,1,30)'												} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(SA1->A1_NOME,1,30)'												} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'RCPJ'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_CGC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(SA1->A1_NOME,1,30)'												} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'09'																	, ; //XB_COLUNA
	'Tel'																	, ; //XB_DESCRI
	'Tel'																	, ; //XB_DESCSPA
	'Phone'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_Tel'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'10'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(SA1->A1_NOME,1,30)'												} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'11'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_Loja'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'12'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_Cod'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CLT'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

//
// Consulta DE4
//
aAdd( aSXB, { ;
	'DE4'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Clientes'																, ; //XB_DESCRI
	'Clientes'																, ; //XB_DESCSPA
	'Customers'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE4'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE4'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE4'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CGC'																	, ; //XB_DESCRI
	'CGC'																	, ; //XB_DESCSPA
	'CGC'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE4'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(SA1->A1_NOME,1,30)'												} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(SA1->A1_NOME,1,30)'												} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'CGC'																	, ; //XB_DESCRI
	'CGC'																	, ; //XB_DESCSPA
	'CGC'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_CGC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(SA1->A1_NOME,1,30)'												} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE4'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_CGC'															} ) //XB_CONTEM

//
// Consulta DE5
//
aAdd( aSXB, { ;
	'DE5'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Clientes'																, ; //XB_DESCRI
	'Clientes'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE5'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE5'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE5'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CGC'																	, ; //XB_DESCRI
	'CGC'																	, ; //XB_DESCSPA
	'CGC'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE5'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Regist. New'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(SA1->A1_NOME,1,30)'												} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(SA1->A1_NOME,1,30)'												} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'CGC'																	, ; //XB_DESCRI
	'CGC'																	, ; //XB_DESCSPA
	'CGC'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_CGC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(SA1->A1_NOME,1,30)'												} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE5'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_CGC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DE5'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_NREDUZ'														} ) //XB_CONTEM

//
// Consulta DL2
//
aAdd( aSXB, { ;
	'DL2'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Cliente/Fornecedor'													, ; //XB_DESCRI
	'Cliente/Proveedor'														, ; //XB_DESCSPA
	'Customer/Supplier'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DL2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'DlgxCliFor()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'DL2'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Iif(Alias()=="SA1",SA1->A1_COD,SA2->A2_COD)'							} ) //XB_CONTEM

//
// Consulta EA1
//
aAdd( aSXB, { ;
	'EA1'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Clientes'																, ; //XB_DESCRI
	'Clientes'																, ; //XB_DESCSPA
	'Customers'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'EA1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'EA1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'EA1'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'EA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'EA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_NOME'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'EA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_NOME'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'EA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'EA1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'EA1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_NREDUZ'														} ) //XB_CONTEM

//
// Consulta ENTCNX
//
aAdd( aSXB, { ;
	'ENTCNX'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Entidade da Conexao'													, ; //XB_DESCRI
	'Entidad de Conexion'													, ; //XB_DESCSPA
	'Connection Entity'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ENTCNX'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CRM190ENT()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ENTCNX'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CRM190ChvCnx()'														} ) //XB_CONTEM

//
// Consulta ER1
//
aAdd( aSXB, { ;
	'ER1'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Importador/Cliente'													, ; //XB_DESCRI
	'Importador/Cliente'													, ; //XB_DESCSPA
	'Importer/Customer'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ER1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'EECSA1F3(cWHENSA1)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ER1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ER1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

//
// Consulta ER3
//
aAdd( aSXB, { ;
	'ER3'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Importador/Cliente'													, ; //XB_DESCRI
	'Importador/Cliente'													, ; //XB_DESCSPA
	'Importer/Customer'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ER3'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'EECSA1F3(cWHENSA1,"Q")'												} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ER3'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ER3'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

//
// Consulta ER5
//
aAdd( aSXB, { ;
	'ER5'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Armazens'																, ; //XB_DESCRI
	'Almacenes'																, ; //XB_DESCSPA
	'Warehouses'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ER5'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo + Loja'															, ; //XB_DESCRI
	'Codigo + Tienda'														, ; //XB_DESCSPA
	'Code + Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ER5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ER5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ER5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ER5'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ER5'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

//
// Consulta FCL
//
aAdd( aSXB, { ;
	'FCL'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FCL'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FCL'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FCL'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CGC'																	, ; //XB_DESCRI
	'CGC'																	, ; //XB_DESCSPA
	'CGC'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FCL'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'#FRTCliente()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FCL'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FCL'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FCL'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FCL'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FCL'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FCL'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FCL'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'CGC'																	, ; //XB_DESCRI
	'CGC'																	, ; //XB_DESCSPA
	'CGC'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FCL'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FCL'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'FCL'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

//
// Consulta IMP
//
aAdd( aSXB, { ;
	'IMP'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Importadores'															, ; //XB_DESCRI
	'Importadores'															, ; //XB_DESCSPA
	'Importers'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'IMP'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'IMP'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'IMP'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'IMP'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'IMP'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'IMP'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'IMP'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'IMP'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'IMP'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'IMP'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'IMP'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_NOME'															} ) //XB_CONTEM

//
// Consulta JURSA1
//
aAdd( aSXB, { ;
	'JURSA1'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Clientes do SIGAPFS'													, ; //XB_DESCRI
	'Clientes del SIGAPFS'													, ; //XB_DESCSPA
	'SIGAPFS Clients'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'JURSA1'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo + Loja'															, ; //XB_DESCRI
	'Codigo + Tienda'														, ; //XB_DESCSPA
	'Code + Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'JURSA1'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome + Loja'															, ; //XB_DESCRI
	'Nombre + Tienda'														, ; //XB_DESCSPA
	'Name + Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'JURSA1'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Cnpj/Cpf'																, ; //XB_DESCRI
	'RPNJ/RPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'JURSA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'JURSA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'JURSA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'JURSA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'JURSA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'JURSA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Nome Substr(A1_NOME,1,30)'												} ) //XB_CONTEM

aAdd( aSXB, { ;
	'JURSA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'JURSA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'JURSA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'09'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Nome Substr(A1_NOME,1,30)'												} ) //XB_CONTEM

aAdd( aSXB, { ;
	'JURSA1'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'JURSA1'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

//
// Consulta MA8
//
aAdd( aSXB, { ;
	'MA8'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Empresa'																, ; //XB_DESCRI
	'Empresa'																, ; //XB_DESCSPA
	'Company'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'MA8'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'MA8'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'MA8'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'MA8'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'New Record'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'MA8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'MA8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'MA8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'MA8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'MA8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'MA8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'MA8'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'MA8'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_NOME'															} ) //XB_CONTEM

//
// Consulta NUHREL
//
aAdd( aSXB, { ;
	'NUHREL'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Clientes'																, ; //XB_DESCRI
	'Clientes'																, ; //XB_DESCSPA
	'Customers'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'NUHREL'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'JURSA1PFL()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'NUHREL'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

//
// Consulta NVESA1
//
aAdd( aSXB, { ;
	'NVESA1'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente/Loja'															, ; //XB_DESCRI
	'Cliente/Tienda'														, ; //XB_DESCSPA
	'Customer/Unit'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'NVESA1'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo + Loja'															, ; //XB_DESCRI
	'Codigo + Tienda'														, ; //XB_DESCSPA
	'Code+Unit'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'NVESA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'NVESA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'NVESA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'NVESA1'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'NVESA1'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'NVESA1'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'J070F3CLI()'															} ) //XB_CONTEM

//
// Consulta OF1
//
aAdd( aSXB, { ;
	'OF1'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'OF1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'OF1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'OF1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'CNPJ'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'OF1'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'OF1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'OF1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'OF1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'OF1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'OF1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'OF1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'OF1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'CNPJ'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'OF1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'OF1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

//
// Consulta QPW
//
aAdd( aSXB, { ;
	'QPW'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'QPW'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'QPW'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'QPW'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'CUIT'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'QPW'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra'																, ; //XB_DESCRI
	'Registra'																, ; //XB_DESCSPA
	'Register'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'QPW'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'QPW'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'QPW'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'QPW'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'QPW'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'QPW'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'QPW'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'CNPJ'																	, ; //XB_DESCRI
	'CUIT'																	, ; //XB_DESCSPA
	'CNPJ'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'QPW'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'QPW'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'QPW'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'QPW'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_NOME'															} ) //XB_CONTEM

//
// Consulta SA1
//
aAdd( aSXB, { ;
	'SA1'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01#A030INCLUI#A030VISUAL'												} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'#CRMXFilSXB("SA1")'													} ) //XB_CONTEM

//
// Consulta SA1AZ0
//
aAdd( aSXB, { ;
	'SA1AZ0'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Clientes'																, ; //XB_DESCRI
	'Clientes'																, ; //XB_DESCSPA
	'Customers'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1AZ0'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo+Loja'															, ; //XB_DESCRI
	'Código+Tienda'															, ; //XB_DESCSPA
	'Code+Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1AZ0'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código do Cliente'														, ; //XB_DESCRI
	'Código del cliente'													, ; //XB_DESCSPA
	'Customer Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1AZ0'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja do Cliente'														, ; //XB_DESCRI
	'Tienda del cliente'													, ; //XB_DESCSPA
	'Customer Store'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1AZ0'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome do Cliente'														, ; //XB_DESCRI
	'Nombre del cliente'													, ; //XB_DESCSPA
	'Customer Name'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1AZ0'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

//
// Consulta SA1CIG
//
aAdd( aSXB, { ;
	'SA1CIG'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente C.Inform.GAV'													, ; //XB_DESCRI
	'Cliente C.Inform.GAV'													, ; //XB_DESCSPA
	'GAV Inf.C.Customer'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CIG'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo+loja'															, ; //XB_DESCRI
	'Codigo+tienda'															, ; //XB_DESCSPA
	'Code+unit'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CIG'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome+loja'																, ; //XB_DESCRI
	'Nombre+tienda'															, ; //XB_DESCSPA
	'Name+unit'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CIG'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'N Fantasia'															, ; //XB_DESCRI
	'N Fantasia'															, ; //XB_DESCSPA
	'Trade name'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CIG'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CIG'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CIG'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CIG'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CIG'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CIG'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CIG'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'N Fantasia'															, ; //XB_DESCRI
	'N Fantasia'															, ; //XB_DESCSPA
	'Trade name'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NREDUZ'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CIG'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CIG'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CIG'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CIG'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CIG'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"If(cGrupoCli=='',.T.,SA1->A1_GRPVEN = cGrupoCli)"						} ) //XB_CONTEM

//
// Consulta SA1CLI
//
aAdd( aSXB, { ;
	'SA1CLI'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Clientes'																, ; //XB_DESCRI
	'Clientes'																, ; //XB_DESCSPA
	'Customers'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CLI'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo+Loja'															, ; //XB_DESCRI
	'Codigo+Tienda'															, ; //XB_DESCSPA
	'Code+Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CLI'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CLI'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CLI'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CLI'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

//
// Consulta SA1CLW
//
aAdd( aSXB, { ;
	'SA1CLW'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Clientes'																, ; //XB_DESCRI
	'Clientes'																, ; //XB_DESCSPA
	'Customers'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CLW'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo+Loja'															, ; //XB_DESCRI
	'Codigo+Tienda'															, ; //XB_DESCSPA
	'Code+Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CLW'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CLW'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CLW'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1CLW'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

//
// Consulta SA1FIN
//
aAdd( aSXB, { ;
	'SA1FIN'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'CLIENTE EXTRATOR FIN'													, ; //XB_DESCRI
	'CLIENTE EXTRACTOR FI'													, ; //XB_DESCSPA
	'CLIENTE EXTRATOR FIN'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FIN'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo + Loja'															, ; //XB_DESCRI
	'Codigo + Tienda'														, ; //XB_DESCSPA
	'Code + store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FIN'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome + Loja'															, ; //XB_DESCRI
	'Nombre + Tienda'														, ; //XB_DESCSPA
	'Name + store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_FILIAL'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_FILIAL'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FIN'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FIN'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FIN'																, ; //XB_ALIAS
	'7'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Space(FWSizeFilial())'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FIN'																, ; //XB_ALIAS
	'7'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"Replicate('Z', FWSizeFilial())"										} ) //XB_CONTEM

//
// Consulta SA1FT1
//
aAdd( aSXB, { ;
	'SA1FT1'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente C.Inform.GAV'													, ; //XB_DESCRI
	'Cliente C.Inform.GAV'													, ; //XB_DESCSPA
	'GAV Inf.C.Customer'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FT1'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo+loja'															, ; //XB_DESCRI
	'Codigo+Tienda'															, ; //XB_DESCSPA
	'Code + unit'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FT1'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome+loja'																, ; //XB_DESCRI
	'Nombre+Tienda'															, ; //XB_DESCSPA
	'Name + unit'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FT1'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'N Fantasia'															, ; //XB_DESCRI
	'N Fantasia'															, ; //XB_DESCSPA
	'Corporate name'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FT1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FT1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FT1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FT1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FT1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FT1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FT1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'N Fantasia'															, ; //XB_DESCRI
	'N Fantasia'															, ; //XB_DESCSPA
	'Corporate name'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NREDUZ'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FT1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FT1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'09'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FT1'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FT1'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1FT1'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'If(Empty(M->FT1_GRPCLI),.T.,SA1->A1_GRPVEN = M->FT1_GRPCLI)'			} ) //XB_CONTEM

//
// Consulta SA1G4A
//
aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Lojas do Cliente'														, ; //XB_DESCRI
	'Tiendas del cliente'													, ; //XB_DESCSPA
	'Customer Store'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código + Loja'															, ; //XB_DESCRI
	'Código + Tienda'														, ; //XB_DESCSPA
	'Code + Loja'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Razão Social + Loja'													, ; //XB_DESCRI
	'Razón social + Tiend'													, ; //XB_DESCSPA
	'Corporate Name + Sto'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'RCPJ/RCPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Razão Social'															, ; //XB_DESCRI
	'Razón social'															, ; //XB_DESCSPA
	'Trade Name'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome Fantasia'															, ; //XB_DESCRI
	'Nombre fantasía'														, ; //XB_DESCSPA
	'Trade Name'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NREDUZ'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'RCPJ/RCPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Razão Social'															, ; //XB_DESCRI
	'Razón social'															, ; //XB_DESCSPA
	'Corporate Name'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Nome Fantasia'															, ; //XB_DESCRI
	'Nombre fantasía'														, ; //XB_DESCSPA
	'Trade Name'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NREDUZ'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'RCPJ/RCPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'09'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'10'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'11'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'RCPJ/RCPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'12'																	, ; //XB_COLUNA
	'Razão Social'															, ; //XB_DESCRI
	'Razón social'															, ; //XB_DESCSPA
	'Corporate Name'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'13'																	, ; //XB_COLUNA
	'Nome Fantasia'															, ; //XB_DESCRI
	'Nombre fantasía'														, ; //XB_DESCSPA
	'Trade Name'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NREDUZ'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'14'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'15'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G4A'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'#TURXFIL("SA1G4A")'													} ) //XB_CONTEM

//
// Consulta SA1G80
//
aAdd( aSXB, { ;
	'SA1G80'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Lojas do Cliente'														, ; //XB_DESCRI
	'Tienda del cliente'													, ; //XB_DESCSPA
	'Customer Stores'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G80'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo + Loja'															, ; //XB_DESCRI
	'Código + Tienda'														, ; //XB_DESCSPA
	'Code + Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G80'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G80'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G80'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'N Fantasia'															, ; //XB_DESCRI
	'N Fantasía'															, ; //XB_DESCSPA
	'Company Name'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NREDUZ'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G80'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'RCPJ/RCPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G80'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1G80'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD == FwFldGet("G6L_CLIENT")'										} ) //XB_CONTEM

//
// Consulta SA1GAC
//
aAdd( aSXB, { ;
	'SA1GAC'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'GAC/Cliente'															, ; //XB_DESCRI
	'GAC/Cliente'															, ; //XB_DESCSPA
	'GAC/Customer'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GAC'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome + Loja'															, ; //XB_DESCRI
	'Nomb + Tienda'															, ; //XB_DESCSPA
	'Name+Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GAC'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo + Loja'															, ; //XB_DESCRI
	'Codigo + Tienda'														, ; //XB_DESCSPA
	'Code+Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GAC'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Cnpj/Cpf'																, ; //XB_DESCRI
	'Cnpj/Cpf'																, ; //XB_DESCSPA
	'Cnpj/Cpf'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GAC'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GAC'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GAC'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GAC'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GAC'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GAC'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GAC'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GAC'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GAC'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'09'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GAC'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'10'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GAC'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GAC'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

//
// Consulta SA1GCT
//
aAdd( aSXB, { ;
	'SA1GCT'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GCT'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GCT'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GCT'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'RCPJ/RPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GCT'																, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GCT'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GCT'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GCT'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GCT'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GCT'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GCT'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GCT'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'RCPJ/RPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GCT'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GCT'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1GCT'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

//
// Consulta SA1LJ
//
aAdd( aSXB, { ;
	'SA1LJ'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Clientes'																, ; //XB_DESCRI
	'Clientes'																, ; //XB_DESCSPA
	'Customers'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1LJ'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. + Loja'															, ; //XB_DESCRI
	'Cod. + Tienda'															, ; //XB_DESCSPA
	'Code+Unit'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1LJ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod.'																	, ; //XB_DESCRI
	'Cod.'																	, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1LJ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1LJ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1LJ'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

//
// Consulta SA1NSZ
//
aAdd( aSXB, { ;
	'SA1NSZ'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Clientes do Processo'													, ; //XB_DESCRI
	'Clientes del proceso'													, ; //XB_DESCSPA
	'Process Customers'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NSZ'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'JA095CLI()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NSZ'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NSZ'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

//
// Consulta SA1NT0
//
aAdd( aSXB, { ;
	'SA1NT0'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Clientes do Contrato'													, ; //XB_DESCRI
	'Clientes de Contrato'													, ; //XB_DESCSPA
	'Contract Clients'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT0'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo + Loja'															, ; //XB_DESCRI
	'Codigo + Tienda'														, ; //XB_DESCSPA
	'Code + Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT0'																, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT0'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT0'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT0'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT0'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Grp. Vendas'															, ; //XB_DESCRI
	'Grp. Ventas'															, ; //XB_DESCSPA
	'Sales Group'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_GRPVEN'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT0'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT0'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT0'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'@#J96SA1NT0()'															} ) //XB_CONTEM

//
// Consulta SA1NT9
//
aAdd( aSXB, { ;
	'SA1NT9'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Clientes Env'															, ; //XB_DESCRI
	'Clientes Env'															, ; //XB_DESCSPA
	'Sent Customer'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT9'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Clientes Env'															, ; //XB_DESCRI
	'Clientes Env'															, ; //XB_DESCSPA
	'Customers Sent'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT9'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'JURSXB("SA1","SA1NT9",{"A1_COD","A1_LOJA","A1_NOME","A1_CGC","A1_END","A1_TEL","A1_EMAIL"},.T.,.F.,"@#JURA105ECL()")'} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT9'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT9'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT9'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT9'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'RCPJ\RCPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT9'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Endereco'																, ; //XB_DESCRI
	'Dirección'																, ; //XB_DESCSPA
	'Address'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_END'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT9'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Telefone'																, ; //XB_DESCRI
	'Teléfono'																, ; //XB_DESCSPA
	'Phone'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_TEL'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT9'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'E-Mail'																, ; //XB_DESCRI
	'E-Mail'																, ; //XB_DESCSPA
	'Email'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_EMAIL'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT9'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT9'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NT9'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'@#JURA105ECL()'														} ) //XB_CONTEM

//
// Consulta SA1NUH
//
aAdd( aSXB, { ;
	'SA1NUH'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Clientes'																, ; //XB_DESCRI
	'Clientes'																, ; //XB_DESCSPA
	'Customers'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NUH'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'JURSA1PFL()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NUH'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NUH'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'JurRetLoja()'															} ) //XB_CONTEM

//
// Consulta SA1NUQ
//
aAdd( aSXB, { ;
	'SA1NUQ'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Clientes da Unidades'													, ; //XB_DESCRI
	'Clientes de Unidades'													, ; //XB_DESCSPA
	'Customers of Units'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NUQ'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'J183CliNUQ()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NUQ'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NUQ'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

//
// Consulta SA1NVE
//
aAdd( aSXB, { ;
	'SA1NVE'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Cliente Caso'															, ; //XB_DESCRI
	'Cliente caso'															, ; //XB_DESCSPA
	'Case Customer'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVE'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'JURConsCli()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVE'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVE'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

//
// Consulta SA1NVS
//
aAdd( aSXB, { ;
	'SA1NVS'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Clientes Juridicos'													, ; //XB_DESCRI
	'Clientes Juridicos'													, ; //XB_DESCSPA
	'Legal Customers'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVS'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome + Loja'															, ; //XB_DESCRI
	'Nombre + Tienda'														, ; //XB_DESCSPA
	'Name + Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVS'																, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVS'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVS'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVS'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVS'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVS'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVS'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Empty(M->NVS_GRPCLI) .Or.SA1->A1_GRPVEN==M->NVS_GRPCLI'				} ) //XB_CONTEM

//
// Consulta SA1NVV
//
aAdd( aSXB, { ;
	'SA1NVV'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Clientes Fatura Adic'													, ; //XB_DESCRI
	'Clientes Factura Adi'													, ; //XB_DESCSPA
	'Addit. Inv. Customer'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVV'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo + Loja'															, ; //XB_DESCRI
	'Codigo + Tienda'														, ; //XB_DESCSPA
	'Code + Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVV'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome + Loja'															, ; //XB_DESCRI
	'Nombre + Tienda'														, ; //XB_DESCSPA
	'Name + Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVV'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVV'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVV'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVV'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVV'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVV'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVV'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVV'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVV'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'@#J033FCliV()'															} ) //XB_CONTEM

//
// Consulta SA1NVW
//
aAdd( aSXB, { ;
	'SA1NVW'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Clientes Caso Fat Ad'													, ; //XB_DESCRI
	'Clientes Caso Fac Ad'													, ; //XB_DESCSPA
	'Custom Case Inv Ad'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVW'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo + Loja'															, ; //XB_DESCRI
	'Codigo + Tienda'														, ; //XB_DESCSPA
	'Code + Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVW'																, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVW'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVW'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVW'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVW'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVW'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NVW'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'@#J033FCliW()'															} ) //XB_CONTEM

//
// Consulta SA1NX0
//
aAdd( aSXB, { ;
	'SA1NX0'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente por Grupo'														, ; //XB_DESCRI
	'Cliente por Grupo'														, ; //XB_DESCSPA
	'Customer per Group'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NX0'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo + Loja'															, ; //XB_DESCRI
	'Codigo + Tienda'														, ; //XB_DESCSPA
	'Code + Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NX0'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NX0'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NX0'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NX0'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NX0'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NX0'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'@#JA202F3("1")'														} ) //XB_CONTEM

//
// Consulta SA1NYJ
//
aAdd( aSXB, { ;
	'SA1NYJ'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Cliente da Unidade'													, ; //XB_DESCRI
	'Cliente da UnIDade'													, ; //XB_DESCSPA
	'Unit Customer'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NYJ'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'J095CliNYJ()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NYJ'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1NYJ'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

//
// Consulta SA1PR2
//
aAdd( aSXB, { ;
	'SA1PR2'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Clientes Pré-Fatur'													, ; //XB_DESCRI
	'Clientes Fact previa'													, ; //XB_DESCSPA
	'Proforma Customer'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PR2'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo + Loja'															, ; //XB_DESCRI
	'Codigo + Loja'															, ; //XB_DESCSPA
	'Code + Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PR2'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome + Loja'															, ; //XB_DESCRI
	'Nombre + Tienda'														, ; //XB_DESCSPA
	'Name + Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PR2'																, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PR2'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PR2'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PR2'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PR2'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PR2'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PR2'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PR2'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PR2'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PR2'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'@#JA201F3("1")'														} ) //XB_CONTEM

//
// Consulta SA1PRE
//
aAdd( aSXB, { ;
	'SA1PRE'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente por Grupo'														, ; //XB_DESCRI
	'Cliente por Grupo'														, ; //XB_DESCSPA
	'Customer per Group'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PRE'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo + Loja'															, ; //XB_DESCRI
	'Codigo + Tienda'														, ; //XB_DESCSPA
	'Code + Store'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PRE'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PRE'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cód Loja'																, ; //XB_DESCRI
	'Cod Tda.'																, ; //XB_DESCSPA
	'Store Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PRE'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PRE'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PRE'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA1PRE'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'@#JA201F3("1")'														} ) //XB_CONTEM

//
// Consulta SARAAG
//
aAdd( aSXB, { ;
	'SARAAG'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Agenda'																, ; //XB_DESCRI
	'Agenda'																, ; //XB_DESCSPA
	'Schedule'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SARAAG'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A802AGETEL()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SARAAG'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A802AGRET()'															} ) //XB_CONTEM

//
// Consulta SARACL
//
aAdd( aSXB, { ;
	'SARACL'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Clientes'																, ; //XB_DESCRI
	'Busca CFOP'															, ; //XB_DESCSPA
	'Customers'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SARACL'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"LookUpSara('CL')"														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SARACL'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'cRetLkSara'															} ) //XB_CONTEM

//
// Consulta SARIMO
//
aAdd( aSXB, { ;
	'SARIMO'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Cargas Perigosas'														, ; //XB_DESCRI
	'Cargas peligrosas'														, ; //XB_DESCSPA
	'Dangerous Loads'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SARIMO'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"LookUpSara('SARIMO')"													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SARIMO'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'cRetLkSara'															} ) //XB_CONTEM

//
// Consulta SARRES
//
aAdd( aSXB, { ;
	'SARRES'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Reserva'																, ; //XB_DESCRI
	'Reserva'																, ; //XB_DESCSPA
	'Reservation'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SARRES'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"LOOKUPSARA('SARRES')"													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SARRES'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'cRetLkSara'															} ) //XB_CONTEM

//
// Consulta SARVIA
//
aAdd( aSXB, { ;
	'SARVIA'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Viagem Ferroviária'													, ; //XB_DESCRI
	'Viaje ferroviaria'														, ; //XB_DESCSPA
	'Railway Trip'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SARVIA'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"LOOKUPSARA('VIAFE')"													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SARVIA'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'cRetLkSara'															} ) //XB_CONTEM

//
// Consulta SRPCNT
//
aAdd( aSXB, { ;
	'SRPCNT'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Containers'															, ; //XB_DESCRI
	'Contenedores'															, ; //XB_DESCSPA
	'Containers'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SRPCNT'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"LookUpSara('SRPCNT')"													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SRPCNT'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'cRetLkSara'															} ) //XB_CONTEM

//
// Consulta SRTRID
//
aAdd( aSXB, { ;
	'SRTRID'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Reserva de Prog.'														, ; //XB_DESCRI
	'Reserva de prog.'														, ; //XB_DESCSPA
	'Sched Reservation'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SRTRID'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"LookUpSara('SRTRID')"													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SRTRID'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'cRetLkSara'															} ) //XB_CONTEM

//
// Consulta SX5GR
//
aAdd( aSXB, { ;
	'SX5GR'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'GRUPO EMPRESARIAL'														, ; //XB_DESCRI
	'GRUPO EMPRESARIAL'														, ; //XB_DESCSPA
	'GRUPO EMPRESARIAL'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SX5'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SX5GR'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Tabela + Chave'														, ; //XB_DESCRI
	'Tabla + Clave'															, ; //XB_DESCSPA
	'Table + Key'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SX5GR'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Chave'																	, ; //XB_DESCRI
	'Clave'																	, ; //XB_DESCSPA
	'Key'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'X5_CHAVE'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SX5GR'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'X5_DESCRI'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SX5GR'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SX5->X5_CHAVE'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SX5GR'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'GR'																	} ) //XB_CONTEM

//
// Consulta SX5XM
//
aAdd( aSXB, { ;
	'SX5XM'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'MOTIVOS DE COBRANÇA'													, ; //XB_DESCRI
	'MOTIVOS DE COBRANÇA'													, ; //XB_DESCSPA
	'MOTIVOS DE COBRANÇA'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SX5'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SX5XM'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Tabela + Chave'														, ; //XB_DESCRI
	'Tabla + Clave'															, ; //XB_DESCSPA
	'Table + Key'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SX5XM'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Chave'																	, ; //XB_DESCRI
	'Clave'																	, ; //XB_DESCSPA
	'Key'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'X5_CHAVE'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SX5XM'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'X5_DESCRI'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SX5XM'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SX5->X5_CHAVE'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SX5XM'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'XM'																	} ) //XB_CONTEM

//
// Consulta TIPDOC
//
aAdd( aSXB, { ;
	'TIPDOC'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Tipo de Documento'														, ; //XB_DESCRI
	'Tipo de Documento'														, ; //XB_DESCSPA
	'Document Type'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TIPDOC'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TM491DOC()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TIPDOC'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'VAR_IXB'																} ) //XB_CONTEM

//
// Consulta TMK013
//
aAdd( aSXB, { ;
	'TMK013'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TMK013'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TMK013'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TMK013'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TMK013'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TMK013'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TMK013'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TMK013'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TMK013'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TMK013'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TMK013'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TMK013'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TMK013'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD+SA1->A1_LOJA'												} ) //XB_CONTEM

//
// Consulta TMSRDP
//
aAdd( aSXB, { ;
	'TMSRDP'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Tipo Receita/Despesa'													, ; //XB_DESCRI
	'Tipo Ingresos/Gastos'													, ; //XB_DESCSPA
	'Type Income/Expense'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TMSRDP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TmsRecDp()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TMSRDP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'VAR_IXB'																} ) //XB_CONTEM

//
// Consulta VCF
//
aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Clientes CEV'															, ; //XB_DESCRI
	'Clientes CEV'															, ; //XB_DESCSPA
	'CEV Customers'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod.Cliente + Loja'													, ; //XB_DESCRI
	'Cod.Cliente + Tienda'													, ; //XB_DESCSPA
	'Customer Cd. + Unit'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome do Cliente'														, ; //XB_DESCRI
	'Nombre del cliente'													, ; //XB_DESCSPA
	'Customer Name'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'09'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'10'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'11'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'12'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VCF'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'VCF->(DbSeek(xFilial("VCF")+SA1->A1_COD+SA1->A1_LOJA))'				} ) //XB_CONTEM

//
// Consulta VEISA1
//
aAdd( aSXB, { ;
	'VEISA1'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Clientes'																, ; //XB_DESCRI
	'Clientes'																, ; //XB_DESCSPA
	'Customers'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VEISA1'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VEISA1'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VEISA1'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'RCPJ/RCPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VEISA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VEISA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VEISA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VEISA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VEISA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VEISA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VEISA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'RCPJ/RCPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VEISA1'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VEISA1'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VEISA1'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

//
// Consulta VS1
//
aAdd( aSXB, { ;
	'VS1'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VS1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo Cliente'														, ; //XB_DESCRI
	'Codigo Cliente'														, ; //XB_DESCSPA
	'Customer Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VS1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VS1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VS1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_CGC'															} ) //XB_CONTEM

//
// Consulta VSA
//
aAdd( aSXB, { ;
	'VSA'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo Cliente'														, ; //XB_DESCRI
	'Código de cliente'														, ; //XB_DESCSPA
	'Customer Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome do Cliente'														, ; //XB_DESCRI
	'Nombre del cliente'													, ; //XB_DESCSPA
	'Customer Name'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01#A030INCLUI("SA1",,3)#A030VISUAL("SA1",,2)'							} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Municipio'																, ; //XB_DESCRI
	'Municipio'																, ; //XB_DESCSPA
	'City'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_MUN'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'RCPJ/RCPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'09'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'RCPJ/RCPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_NOME'															} ) //XB_CONTEM

//
// Consulta VSA1
//
aAdd( aSXB, { ;
	'VSA1'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'codigo'																, ; //XB_DESCRI
	'codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA1'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'codigo'																, ; //XB_DESCRI
	'codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A1_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSA1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_NOME'															} ) //XB_CONTEM

//
// Consulta VSB
//
aAdd( aSXB, { ;
	'VSB'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSB'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo Cliente'														, ; //XB_DESCRI
	'Codigo Cliente'														, ; //XB_DESCSPA
	'Customer Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSB'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome do Cliente'														, ; //XB_DESCRI
	'Nombre del Cliente'													, ; //XB_DESCSPA
	"Customer's Name"														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSB'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSB'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSB'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSB'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSB'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSB'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSB'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSB'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'FS_FILCLI()'															} ) //XB_CONTEM

//
// Consulta VSC
//
aAdd( aSXB, { ;
	'VSC'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Customer'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSC'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo Cliente'														, ; //XB_DESCRI
	'Codigo Cliente'														, ; //XB_DESCSPA
	'Customer Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSC'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome do Cliente'														, ; //XB_DESCRI
	'Nombre del Cliente'													, ; //XB_DESCSPA
	"Customer's Name"														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSC'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSC'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSC'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSC'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSC'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSC'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSC'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_LOJA'															} ) //XB_CONTEM

//
// Consulta VSD
//
aAdd( aSXB, { ;
	'VSD'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Clientes'																, ; //XB_DESCRI
	'Clientes'																, ; //XB_DESCSPA
	'Customers'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSD'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome do Cliente'														, ; //XB_DESCRI
	'Nombre del Cliente'													, ; //XB_DESCSPA
	'Customer Name'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSD'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSD'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSD'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSD'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A1_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'VSD'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA1->A1_NOME'															} ) //XB_CONTEM

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( "SXB" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

	If !Empty( aSXB[nI][1] )

		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
				AutoGrLog( "Foi incluída a consulta padrão " + aSXB[nI][1] )
			EndIf

			RecLock( "SXB", .T. )

			For nJ := 1 To Len( aSXB[nI] )
				If FieldPos( aEstrut[nJ] ) > 0
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				If aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
					!StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), " ", "" ) == ;
					 StrTran( AllToChar( aSXB[nI][nJ]            ), " ", "" )

					cMsg := "A consulta padrão " + aSXB[nI][1] + " está com o " + SXB->( FieldName( nJ ) ) + ;
					" com o conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( SXB->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
					", e este é diferente do conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( aSXB[nI][nJ] ) ) + "]" + CRLF +;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SXB" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SXB e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SXB que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
						EndIf

					EndIf

					If nOpcA == 1
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

							If !( aSXB[nI][1] $ cAlias )
								cAlias += aSXB[nI][1] + "/"
								AutoGrLog( "Foi alterada a consulta padrão " + aSXB[nI][1] )
							EndIf

					EndIf

				EndIf

			Next

		EndIf

	EndIf

	oProcess:IncRegua2( "Atualizando Consultas Padrões (SXB)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SXB" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX5
Função de processamento da gravação do SX5 - Indices

@author TOTVS Protheus
@since  16/07/2019
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
	'GR'																	, ; //X5_CHAVE
	'GRUPOS EMPRESARIAIS'													, ; //X5_DESCRI
	'GRUPOS EMPRESARIAIS'													, ; //X5_DESCSPA
	'GRUPOS EMPRESARIAIS'													} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'00'																	, ; //X5_TABELA
	'XM'																	, ; //X5_CHAVE
	'MOTIVOS DE COBRANÇA'													, ; //X5_DESCRI
	'MOTIVOS DE COBRANÇA'													, ; //X5_DESCSPA
	'MOTIVOS DE COBRANÇA'													} ) //X5_DESCENG

//
// Tabela GR
//
aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'GR'																	, ; //X5_TABELA
	'000001'																, ; //X5_CHAVE
	'JBS'																	, ; //X5_DESCRI
	'JBS'																	, ; //X5_DESCSPA
	'JBS'																	} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'GR'																	, ; //X5_TABELA
	'000002'																, ; //X5_CHAVE
	'SEARA'																	, ; //X5_DESCRI
	'SEARA'																	, ; //X5_DESCSPA
	'SEARA'																	} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'GR'																	, ; //X5_TABELA
	'000003'																, ; //X5_CHAVE
	'BEMIS'																	, ; //X5_DESCRI
	'BEMIS'																	, ; //X5_DESCSPA
	'BEMIS'																	} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'GR'																	, ; //X5_TABELA
	'000004'																, ; //X5_CHAVE
	'MARFRIG'																, ; //X5_DESCRI
	'MARFRIG'																, ; //X5_DESCSPA
	'MARFRIG'																} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'GR'																	, ; //X5_TABELA
	'000005'																, ; //X5_CHAVE
	'BOSCH'																	, ; //X5_DESCRI
	'BOSCH'																	, ; //X5_DESCSPA
	'BOSCH'																	} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'GR'																	, ; //X5_TABELA
	'000006'																, ; //X5_CHAVE
	'ARAUCO'																, ; //X5_DESCRI
	'ARAUCO'																, ; //X5_DESCSPA
	'ARAUCO'																} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'GR'																	, ; //X5_TABELA
	'000007'																, ; //X5_CHAVE
	'LAR'																	, ; //X5_DESCRI
	'LAR'																	, ; //X5_DESCSPA
	'LAR'																	} ) //X5_DESCENG

//
// Tabela XM
//
aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'XM'																	, ; //X5_TABELA
	'000001'																, ; //X5_CHAVE
	'DISPUTE'																, ; //X5_DESCRI
	'DISPUTE'																, ; //X5_DESCSPA
	'DISPUTE'																} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'XM'																	, ; //X5_TABELA
	'000002'																, ; //X5_CHAVE
	'DESC. COMERCIAL'														, ; //X5_DESCRI
	'DESC. COMERCIAL'														, ; //X5_DESCSPA
	'DESC. COMERCIAL'														} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'XM'																	, ; //X5_TABELA
	'000003'																, ; //X5_CHAVE
	'RENOVAÇÃO TARIFÁRIO'													, ; //X5_DESCRI
	'RENOVAÇÃO TARIFÁRIO'													, ; //X5_DESCSPA
	'RENOVAÇÃO TARIFÁRIO'													} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'XM'																	, ; //X5_TABELA
	'000004'																, ; //X5_CHAVE
	'AVARIAS'																, ; //X5_DESCRI
	'AVARIAS'																, ; //X5_DESCSPA
	'AVARIAS'																} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'XM'																	, ; //X5_TABELA
	'000005'																, ; //X5_CHAVE
	'RECUPERAÇÃO JUDICIAL'													, ; //X5_DESCRI
	'RECUPERAÇÃO JUDICIAL'													, ; //X5_DESCSPA
	'RECUPERAÇÃO JUDICIAL'													} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'XM'																	, ; //X5_TABELA
	'000006'																, ; //X5_CHAVE
	'NOTA DE CRÉDITO'														, ; //X5_DESCRI
	'NOTA DE CRÉDITO'														, ; //X5_DESCSPA
	'NOTA DE CRÉDITO'														} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'XM'																	, ; //X5_TABELA
	'000007'																, ; //X5_CHAVE
	'SERASA'														, ; //X5_DESCRI
	'SERASA'														, ; //X5_DESCSPA
	'SERASA'														} ) //X5_DESCENG

aAdd( aSX5, { ;
	'  '																	, ; //X5_FILIAL
	'XM'																	, ; //X5_TABELA
	'000008'																, ; //X5_CHAVE
	'CARTÓRIO'														, ; //X5_DESCRI
	'CARTÓRIO'														, ; //X5_DESCSPA
	'CARTÓRIO'														} ) //X5_DESCENG

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
/*/{Protheus.doc} FSAtuSX1
Função de processamento da gravação do SX1 - Perguntas

@author TOTVS Protheus
@since  16/07/2019
@obs    Gerado por EXPORDIC - V.5.2.1.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX1()
Local aEstrut   := {}
Local aSX1      := {}
Local aStruDic  := SX1->( dbStruct() )
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTam1     := Len( SX1->X1_GRUPO )
Local nTam2     := Len( SX1->X1_ORDEM )

AutoGrLog( "Ínicio da Atualização " + cAlias + CRLF )

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"  }

//
// Perguntas FIN130
//

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'01'																	, ; //X1_ORDEM
	'Do Cliente ?'															, ; //X1_PERGUNT
	'¿De Cliente ?'															, ; //X1_PERSPA
	'From Customer ?'														, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	6																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR01'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'CLI'																	, ; //X1_F3
	'S'																		, ; //X1_PYME
	'001'																	, ; //X1_GRPSXG
	'.FIN13001.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'02'																	, ; //X1_ORDEM
	'Ate o Cliente ?'														, ; //X1_PERGUNT
	'¿A Cliente ?'															, ; //X1_PERSPA
	'To Customer ?'															, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	6																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR02'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'ZZZZZZ'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'CLI'																	, ; //X1_F3
	'S'																		, ; //X1_PYME
	'001'																	, ; //X1_GRPSXG
	'.FIN13002.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'03'																	, ; //X1_ORDEM
	'Do Prefixo ?'															, ; //X1_PERGUNT
	'¿De Prefijo ?'															, ; //X1_PERSPA
	'From Prefix ?'															, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	3																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR03'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13003.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'04'																	, ; //X1_ORDEM
	'Ate o Prefixo ?'														, ; //X1_PERGUNT
	'¿A Prefijo ?'															, ; //X1_PERSPA
	'To Prefix ?'															, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	3																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR04'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'ZZZ'																	, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13004.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'05'																	, ; //X1_ORDEM
	'Do Titulo ?'															, ; //X1_PERGUNT
	'¿De Titulo ?'															, ; //X1_PERSPA
	'From Bill ?'															, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	9																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR05'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	'018'																	, ; //X1_GRPSXG
	'.FIN13005.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'06'																	, ; //X1_ORDEM
	'Ate o Titulo ?'														, ; //X1_PERGUNT
	'¿A Titulo ?'															, ; //X1_PERSPA
	'To Bill ?'																, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	9																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR06'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'ZZZZZ'																	, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	'018'																	, ; //X1_GRPSXG
	'.FIN13006.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'07'																	, ; //X1_ORDEM
	'Do Banco ?'															, ; //X1_PERGUNT
	'¿De Banco ?'															, ; //X1_PERSPA
	'From Bank ?'															, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	3																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR07'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'BCO'																	, ; //X1_F3
	'S'																		, ; //X1_PYME
	'007'																	, ; //X1_GRPSXG
	'.FIN13007.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'08'																	, ; //X1_ORDEM
	'Ate o Banco ?'															, ; //X1_PERGUNT
	'¿A Banco ?'															, ; //X1_PERSPA
	'To the Bank ?'															, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	3																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR08'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'ZZZ'																	, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'BCO'																	, ; //X1_F3
	'S'																		, ; //X1_PYME
	'007'																	, ; //X1_GRPSXG
	'.FIN13008.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'09'																	, ; //X1_ORDEM
	'Do Vencimento ?'														, ; //X1_PERGUNT
	'¿De Vencimiento ?'														, ; //X1_PERSPA
	'From Expiration ?'														, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'D'																		, ; //X1_TIPO
	8																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR09'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'20160601'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13009.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'10'																	, ; //X1_ORDEM
	'Ate o Vencimento ?'													, ; //X1_PERGUNT
	'¿A Vencimiento ?'														, ; //X1_PERSPA
	'To Expiration ?'														, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'D'																		, ; //X1_TIPO
	8																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR10'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'20180630'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13010.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'11'																	, ; //X1_ORDEM
	'Da Natureza ?'															, ; //X1_PERGUNT
	'¿De Modalidad ?'														, ; //X1_PERSPA
	'From Nature ?'															, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	10																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR11'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'SED'																	, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13011.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'12'																	, ; //X1_ORDEM
	'Ate a Natureza ?'														, ; //X1_PERGUNT
	'¿A Modalidad ?'														, ; //X1_PERSPA
	'To Nature ?'															, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	10																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR12'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'ZZZZZZZ'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'SED'																	, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13012.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'13'																	, ; //X1_ORDEM
	'Da Emissao ?'															, ; //X1_PERGUNT
	'¿De Emision ?'															, ; //X1_PERSPA
	'From Issue ?'															, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'D'																		, ; //X1_TIPO
	8																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR13'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'20160601'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13013.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'14'																	, ; //X1_ORDEM
	'Ate a Emissao ?'														, ; //X1_PERGUNT
	'¿A Emision ?'															, ; //X1_PERSPA
	'To Issue ?'															, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'D'																		, ; //X1_TIPO
	8																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR14'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'20161230'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13014.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'15'																	, ; //X1_ORDEM
	'Qual Moeda ?'															, ; //X1_PERGUNT
	'¿Cual Moneda ?'														, ; //X1_PERSPA
	'What Currency ?'														, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	2																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	'VerifMoeda(mv_par15)'													, ; //X1_VALID
	'MV_PAR15'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'1'																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13015.'															, ; //X1_HELP
	'99'																	, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'16'																	, ; //X1_ORDEM
	'Imprime Provisorios ?'													, ; //X1_PERGUNT
	'¿Imprime Provisorios ?'												, ; //X1_PERSPA
	'Print Provisory ?'														, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	2																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR16'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13016.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'17'																	, ; //X1_ORDEM
	'Converte Venci pela ?'													, ; //X1_PERGUNT
	'¿Convierte Venci por ?'												, ; //X1_PERSPA
	'Convert Due Dt by ?'													, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	2																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR17'																, ; //X1_VAR01
	'Data Base'																, ; //X1_DEF01
	'Fecha Base'															, ; //X1_DEFSPA1
	'Base Date'																, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Data de Vencto'														, ; //X1_DEF02
	'Fecha de Vencto'														, ; //X1_DEFSPA2
	'Expiration Date'														, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13017.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'18'																	, ; //X1_ORDEM
	'Impr Tit em Descont ?'													, ; //X1_PERGUNT
	'¿Impr Tit en Descuent ?'												, ; //X1_PERSPA
	'Prnt Bill in Disc. ?'													, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	1																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR18'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13018.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'19'																	, ; //X1_ORDEM
	'Imprime Relatorio ?'													, ; //X1_PERGUNT
	'¿Imprime Informe ?'													, ; //X1_PERSPA
	'Print Report ?'														, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	1																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR19'																, ; //X1_VAR01
	'Analitico'																, ; //X1_DEF01
	'Analitico'																, ; //X1_DEFSPA1
	'Detailed'																, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Sintetico'																, ; //X1_DEF02
	'Sintetico'																, ; //X1_DEFSPA2
	'Summarized'															, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13019.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'20'																	, ; //X1_ORDEM
	'Compoem Saldo Retroativo ?'											, ; //X1_PERGUNT
	'¿Componen Saldo Retroactivo ?'											, ; //X1_PERSPA
	'Compose Backdated Bal. ?'												, ; //X1_PERENG
	'MV_CH2'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	1																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR20'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13020.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'21'																	, ; //X1_ORDEM
	'Cons.Filiais abaixo ?'													, ; //X1_PERGUNT
	'¿Cons.Sucursales a cont. ?'											, ; //X1_PERSPA
	'Cons. Branches below ?'												, ; //X1_PERENG
	'MV_CH2'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	1																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR21'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13021.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'22'																	, ; //X1_ORDEM
	'Da Filial ?'															, ; //X1_PERGUNT
	'¿De Sucursal ?'														, ; //X1_PERSPA
	'From branch ?'															, ; //X1_PERENG
	'MV_CH2'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	2																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR22'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'SM0_01'																, ; //X1_F3
	'S'																		, ; //X1_PYME
	'033'																	, ; //X1_GRPSXG
	'.FIN13022.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'23'																	, ; //X1_ORDEM
	'Ate a Filial ?'														, ; //X1_PERGUNT
	'¿A Sucursal ?'															, ; //X1_PERSPA
	'To Branch ?'															, ; //X1_PERENG
	'MV_CH2'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	2																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR23'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'ZZ'																	, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'SM0_01'																, ; //X1_F3
	'S'																		, ; //X1_PYME
	'033'																	, ; //X1_GRPSXG
	'.FIN13023.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'24'																	, ; //X1_ORDEM
	'Da Loja ?'																, ; //X1_PERGUNT
	'¿De Tienda ?'															, ; //X1_PERSPA
	'From store ?'															, ; //X1_PERENG
	'MV_CH2'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	2																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR24'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	'002'																	, ; //X1_GRPSXG
	'.FIN13024.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'25'																	, ; //X1_ORDEM
	'Ate a Loja ?'															, ; //X1_PERGUNT
	'¿A Tienda ?'															, ; //X1_PERSPA
	'To Store ?'															, ; //X1_PERENG
	'MV_CH2'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	2																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR25'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'ZZ'																	, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	'002'																	, ; //X1_GRPSXG
	'.FIN13025.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'26'																	, ; //X1_ORDEM
	'Considera Adiantam. ?'													, ; //X1_PERGUNT
	'¿Considera Anticipo ?'													, ; //X1_PERSPA
	'Consider Advance ?'													, ; //X1_PERENG
	'MV_CH2'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	1																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR26'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13026.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'27'																	, ; //X1_ORDEM
	'Da data contabil ?'													, ; //X1_PERGUNT
	'¿De fecha contable ?'													, ; //X1_PERSPA
	'From account date ?'													, ; //X1_PERENG
	'MV_CH2'																, ; //X1_VARIAVL
	'D'																		, ; //X1_TIPO
	8																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR27'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'20160601'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13027.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'28'																	, ; //X1_ORDEM
	'Ate data contabil ?'													, ; //X1_PERGUNT
	'¿A fecha contable ?'													, ; //X1_PERSPA
	'To account date ?'														, ; //X1_PERENG
	'MV_CH2'																, ; //X1_VARIAVL
	'D'																		, ; //X1_TIPO
	8																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR28'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'20161231'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13028.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'29'																	, ; //X1_ORDEM
	'Imprime Nome ?'														, ; //X1_PERGUNT
	'¿Imprime Nombre ?'														, ; //X1_PERSPA
	'Print Name ?'															, ; //X1_PERENG
	'MV_CH2'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	2																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR29'																, ; //X1_VAR01
	'Nome Reduzido'															, ; //X1_DEF01
	'Nombre Reducido'														, ; //X1_DEFSPA1
	'Reduced Name'															, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Razao Social'															, ; //X1_DEF02
	'Razon Social'															, ; //X1_DEFSPA2
	'Comp. Name'															, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13029.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'30'																	, ; //X1_ORDEM
	'Outras Moedas ?'														, ; //X1_PERGUNT
	'¿Otras Monedas ?'														, ; //X1_PERSPA
	'Other Currencies ?'													, ; //X1_PERENG
	'MV_CH3'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	2																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR30'																, ; //X1_VAR01
	'Converter'																, ; //X1_DEF01
	'Convierte'																, ; //X1_DEFSPA1
	'Convert'																, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao Imprimir'															, ; //X1_DEF02
	'No Imprime'															, ; //X1_DEFSPA2
	'Do not print'															, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13030.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'31'																	, ; //X1_ORDEM
	'Imprimir Tipos ?'														, ; //X1_PERGUNT
	'¿Imprime Tipos ?'														, ; //X1_PERSPA
	'Print types ?'															, ; //X1_PERENG
	'MV_CH3'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	40																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR31'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13031.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'32'																	, ; //X1_ORDEM
	'Nao Imprimir Tipos ?'													, ; //X1_PERGUNT
	'¿No Imprime Tipos ?'													, ; //X1_PERSPA
	'Nao Print types ?'														, ; //X1_PERENG
	'MV_CH3'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	40																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR32'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13032.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'33'																	, ; //X1_ORDEM
	'Abatimentos ?'															, ; //X1_PERGUNT
	'¿Descuentos ?'															, ; //X1_PERSPA
	'Discount ?'															, ; //X1_PERENG
	'MV_CH3'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	1																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR33'																, ; //X1_VAR01
	'Listar'																, ; //X1_DEF01
	'Lista'																	, ; //X1_DEFSPA1
	'List'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao Listar'															, ; //X1_DEF02
	'No Lista'																, ; //X1_DEFSPA2
	'Do Not List'															, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	'Nao Considerar'														, ; //X1_DEF03
	'No Considera'															, ; //X1_DEFSPA3
	'Do Not Consider'														, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13033.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'34'																	, ; //X1_ORDEM
	'Somente Tit.p/Fluxo ?'													, ; //X1_PERGUNT
	'¿Solamente Tit.p/Flujo ?'												, ; //X1_PERSPA
	'Only Bill for Flow ?'													, ; //X1_PERENG
	'MV_CH3'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	2																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR34'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13034.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'35'																	, ; //X1_ORDEM
	'Salta pag p/Cliente ?'													, ; //X1_PERGUNT
	'¿Salta pag p/Cliente ?'												, ; //X1_PERSPA
	'Skip pay for Cust ?'													, ; //X1_PERENG
	'MV_CH3'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	2																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR35'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13035.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'36'																	, ; //X1_ORDEM
	'Data Base ?'															, ; //X1_PERGUNT
	'¿Fecha base ?'															, ; //X1_PERSPA
	'Data base ?'															, ; //X1_PERENG
	'MV_CH3'																, ; //X1_VARIAVL
	'D'																		, ; //X1_TIPO
	8																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR36'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'20161231'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13036.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'37'																	, ; //X1_ORDEM
	'Compoe Saldo por ?'													, ; //X1_PERGUNT
	'¿Compone Saldo por ?'													, ; //X1_PERSPA
	'Compound Balance by ?'													, ; //X1_PERENG
	'MV_CH3'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	1																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR37'																, ; //X1_VAR01
	'Data da Baixa'															, ; //X1_DEF01
	'Fecha de Baja'															, ; //X1_DEFSPA1
	'Issuing Date'															, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Data de Credito'														, ; //X1_DEF02
	'Fecha Credito'															, ; //X1_DEFSPA2
	'Credit Date'															, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	'Data Digitacao'														, ; //X1_DEF03
	'Fch. Digitacion'														, ; //X1_DEFSPA3
	'Typing Date'															, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13037.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'38'																	, ; //X1_ORDEM
	'Tit. Emissao Futura ?'													, ; //X1_PERGUNT
	'¿Tit. Emision Futura ?'												, ; //X1_PERSPA
	'Future Issue Bill ?'													, ; //X1_PERENG
	'MV_CH3'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	2																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR38'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13038.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'39'																	, ; //X1_ORDEM
	'Converte valores pela ?'												, ; //X1_PERGUNT
	'¿Convierte valores por la ?'											, ; //X1_PERSPA
	'Convert values by ?'													, ; //X1_PERENG
	'MV_CH3'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	1																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR39'																, ; //X1_VAR01
	'Taxa do dia'															, ; //X1_DEF01
	'Tasa del dia'															, ; //X1_DEFSPA1
	'Day rate'																, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Taxa do Mov.'															, ; //X1_DEF02
	'Tasa del Mov.'															, ; //X1_DEFSPA2
	'Trans. Rate'															, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13039.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'40'																	, ; //X1_ORDEM
	'Considera data ?'														, ; //X1_PERGUNT
	'¿Considera fecha ?'													, ; //X1_PERSPA
	'Consider date ?'														, ; //X1_PERENG
	'MV_CH4'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	1																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR40'																, ; //X1_VAR01
	'Vencimento Real'														, ; //X1_DEF01
	'Venc. Real'															, ; //X1_DEFSPA1
	'Real Due Date'															, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Vencimento'															, ; //X1_DEF02
	'Vencimiento'															, ; //X1_DEFSPA2
	'Expiration'															, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13040.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'41'																	, ; //X1_ORDEM
	'Compensação entre Filiais ?'											, ; //X1_PERGUNT
	'¿Compensac.entre sucursales ?'											, ; //X1_PERSPA
	'Compensation among Branches ?'											, ; //X1_PERENG
	'MV_CH4'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	2																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR41'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13041.'															, ; //X1_HELP
	'9'																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'42'																	, ; //X1_ORDEM
	'Seleciona Filiais ?'													, ; //X1_PERGUNT
	'¿Selecciona Sucursales ?'												, ; //X1_PERSPA
	'Select Branches ?'														, ; //X1_PERENG
	'MV_CH4'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	2																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR42'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Não'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13042.'															, ; //X1_HELP
	'9'																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'43'																	, ; //X1_ORDEM
	'Considera titulos Excluidos ?'											, ; //X1_PERGUNT
	'¿Considera títulos borrados ?'											, ; //X1_PERSPA
	'Consider Deleted bills ?'												, ; //X1_PERENG
	'MV_CH4'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	2																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR43'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Sí'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13043.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN130'																, ; //X1_GRUPO
	'44'																	, ; //X1_ORDEM
	'Grupo Empresarial ?'													, ; //X1_PERGUNT
	'Grupo Empresarial ?'													, ; //X1_PERSPA
	'Grupo Empresarial ?'													, ; //X1_PERENG
	'MV_CH4'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	6																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR44'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'000001'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'SX5GR'																	, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

//
// Perguntas FIN340
//

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'01'																	, ; //X1_ORDEM
	'Do Cliente ?'															, ; //X1_PERGUNT
	'¿De Cliente ?'															, ; //X1_PERSPA
	'From Customer ?'														, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	6																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR01'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'CLI'																	, ; //X1_F3
	'S'																		, ; //X1_PYME
	'001'																	, ; //X1_GRPSXG
	'.FIN34001.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'02'																	, ; //X1_ORDEM
	'Ate o Cliente ?'														, ; //X1_PERGUNT
	'¿A Cliente ?'															, ; //X1_PERSPA
	'To Customer ?'															, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	6																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR02'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'ZZZZZZ'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'CLI'																	, ; //X1_F3
	'S'																		, ; //X1_PYME
	'001'																	, ; //X1_GRPSXG
	'.FIN34002.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'03'																	, ; //X1_ORDEM
	'Da loja ?'																, ; //X1_PERGUNT
	'¿De tienda ?'															, ; //X1_PERSPA
	'From store ?'															, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	2																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR03'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	'002'																	, ; //X1_GRPSXG
	'.FIN34003.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'04'																	, ; //X1_ORDEM
	'Ate a Loja ?'															, ; //X1_PERGUNT
	'¿A Tienda ?'															, ; //X1_PERSPA
	'To Store ?'															, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	2																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR04'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'ZZ'																	, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	'002'																	, ; //X1_GRPSXG
	'.FIN34004.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'05'																	, ; //X1_ORDEM
	'Da Emissao ?'															, ; //X1_PERGUNT
	'¿De Emision ?'															, ; //X1_PERSPA
	'From Issue ?'															, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'D'																		, ; //X1_TIPO
	8																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR05'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'20160601'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN34005.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'06'																	, ; //X1_ORDEM
	'Ate a Emissao ?'														, ; //X1_PERGUNT
	'¿A Emision ?'															, ; //X1_PERSPA
	'To Issue ?'															, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'D'																		, ; //X1_TIPO
	8																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR06'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'20160930'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN34006.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'07'																	, ; //X1_ORDEM
	'Do Vencimento ?'														, ; //X1_PERGUNT
	'¿De Vencimiento ?'														, ; //X1_PERSPA
	'From Expiration ?'														, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'D'																		, ; //X1_TIPO
	8																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR07'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'20160601'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN34007.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'08'																	, ; //X1_ORDEM
	'Ate o Vencimento ?'													, ; //X1_PERGUNT
	'¿A Vencimiento ?'														, ; //X1_PERSPA
	'To Expiration ?'														, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'D'																		, ; //X1_TIPO
	8																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR08'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'20160930'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN34008.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'09'																	, ; //X1_ORDEM
	'Imprime provisorios ?'													, ; //X1_PERGUNT
	'¿Imprime provisorios ?'												, ; //X1_PERSPA
	'Prints provisory ?'													, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	2																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR09'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN34009.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'10'																	, ; //X1_ORDEM
	'Qual a moeda ?'														, ; //X1_PERGUNT
	'¿Cual moneda ?'														, ; //X1_PERSPA
	'What currency ?'														, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	2																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	'VerifMoeda(mv_par10)'													, ; //X1_VALID
	'MV_PAR10'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'1'																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN34010.'															, ; //X1_HELP
	'99'																	, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'11'																	, ; //X1_ORDEM
	'Reajusta Venc.pela ?'													, ; //X1_PERGUNT
	'¿Reajusta Venc.por ?'													, ; //X1_PERSPA
	'Adjusts Exp By ?'														, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	1																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR11'																, ; //X1_VAR01
	'Data Base'																, ; //X1_DEF01
	'Fecha Base'															, ; //X1_DEFSPA1
	'Base Date'																, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Data de Vencto'														, ; //X1_DEF02
	'Fecha de Vencto'														, ; //X1_DEFSPA2
	'Exp Date'																, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN34011.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'12'																	, ; //X1_ORDEM
	'Considera Faturados ?'													, ; //X1_PERGUNT
	'¿Considera Facturados ?'												, ; //X1_PERSPA
	'Considers Invoiced ?'													, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	2																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR12'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN34012.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'13'																	, ; //X1_ORDEM
	'Outras Moedas ?'														, ; //X1_PERGUNT
	'¿Otras Monedas ?'														, ; //X1_PERSPA
	'Other Currencies ?'													, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	2																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR13'																, ; //X1_VAR01
	'Converter'																, ; //X1_DEF01
	'Convierte'																, ; //X1_DEFSPA1
	'Convert'																, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao Imprimir'															, ; //X1_DEF02
	'No Imprime'															, ; //X1_DEFSPA2
	'Do not print'															, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN34013.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'14'																	, ; //X1_ORDEM
	'Compoe Saldo Retroativo ?'												, ; //X1_PERGUNT
	'¿Compone Saldo Retroactivo ?'											, ; //X1_PERSPA
	'Compounds Retroactive Balanc ?'										, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	1																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR14'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN34014.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'15'																	, ; //X1_ORDEM
	'Imprime Nome ?'														, ; //X1_PERGUNT
	'¿Imprime Nombre ?'														, ; //X1_PERSPA
	'Print Name ?'															, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	1																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	'Finr340Val()'															, ; //X1_VALID
	'MV_PAR15'																, ; //X1_VAR01
	'Razao Social'															, ; //X1_DEF01
	'Razon Social'															, ; //X1_DEFSPA1
	'Company Name'															, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nome Reduzido'															, ; //X1_DEF02
	'Nombre Reducido'														, ; //X1_DEFSPA2
	'Reduced Name'															, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN34015.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'16'																	, ; //X1_ORDEM
	'Da Natureza ?'															, ; //X1_PERGUNT
	'¿De Modalidad ?'														, ; //X1_PERSPA
	'From Nature ?'															, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	10																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR16'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'SED'																	, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN34016.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'17'																	, ; //X1_ORDEM
	'Ate Natureza ?'														, ; //X1_PERGUNT
	'¿A Modalidad ?'														, ; //X1_PERSPA
	'To Nature ?'															, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	10																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR17'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'ZZZ'																	, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'SED'																	, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN34017.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'18'																	, ; //X1_ORDEM
	'Considera Liquidados ?'												, ; //X1_PERGUNT
	'¿Considera Liquidados ?'												, ; //X1_PERSPA
	'Considers Settled ?'													, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	1																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR18'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN34018.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'19'																	, ; //X1_ORDEM
	'Cons. Baixas por Recibo ?'												, ; //X1_PERGUNT
	'¿Cons. Bajas por Recibo ?'												, ; //X1_PERSPA
	'Cons. Writeoffs by Receipt ?'											, ; //X1_PERENG
	'MV_CH1'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	1																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR19'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN34019.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'20'																	, ; //X1_ORDEM
	'Cons.Filiais abaixo ?'													, ; //X1_PERGUNT
	'¿Cons. Sucurs. abajo ?'												, ; //X1_PERSPA
	'Consider following branches: ?'										, ; //X1_PERENG
	'MV_CH2'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	1																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR20'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Nao'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN13021.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'21'																	, ; //X1_ORDEM
	'Da Filial ?'															, ; //X1_PERGUNT
	'¿De la Sucursal ?'														, ; //X1_PERSPA
	'From branch ?'															, ; //X1_PERENG
	'MV_CH2'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	2																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR21'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'SM0_01'																, ; //X1_F3
	'S'																		, ; //X1_PYME
	'033'																	, ; //X1_GRPSXG
	'.FIN13022.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'22'																	, ; //X1_ORDEM
	'Ate a Filial ?'														, ; //X1_PERGUNT
	'¿A la Sucursal ?'														, ; //X1_PERSPA
	'To branch ?'															, ; //X1_PERENG
	'MV_CH2'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	2																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR22'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'ZZ'																	, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'SM0_01'																, ; //X1_F3
	'S'																		, ; //X1_PYME
	'033'																	, ; //X1_GRPSXG
	'.FIN13023.'															, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'23'																	, ; //X1_ORDEM
	'Seleciona Filial ?'													, ; //X1_PERGUNT
	'¿Selecciona sucursal ?'												, ; //X1_PERSPA
	'Select Branch ?'														, ; //X1_PERENG
	'MV_CH2'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	2																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR23'																, ; //X1_VAR01
	'Sim'																	, ; //X1_DEF01
	'Si'																	, ; //X1_DEFSPA1
	'Yes'																	, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	'Não'																	, ; //X1_DEF02
	'No'																	, ; //X1_DEFSPA2
	'No'																	, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	'S'																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	'.FIN34023.'															, ; //X1_HELP
	'9'																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'FIN340'																, ; //X1_GRUPO
	'24'																	, ; //X1_ORDEM
	'Grupo Empresarial ?'													, ; //X1_PERGUNT
	'Grupo Empresarial ?'													, ; //X1_PERSPA
	'Grupo Empresarial ?'													, ; //X1_PERENG
	'MV_CH2'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	6																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR24'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'000001'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'SX5GR'																	, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL


//
// Atualizando dicionário
//

nPosPerg:= aScan( aEstrut, "X1_GRUPO"   )
nPosOrd := aScan( aEstrut, "X1_ORDEM"   )
nPosTam := aScan( aEstrut, "X1_TAMANHO" )
nPosSXG := aScan( aEstrut, "X1_GRPSXG"  )

oProcess:SetRegua2( Len( aSX1 ) )

dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSX1 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX1[nI][nPosSXG]  )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX1[nI][nPosSXG] ) )
			If aSX1[nI][nPosTam] <> SXG->XG_SIZE
				aSX1[nI][nPosTam] := SXG->XG_SIZE
				AutoGrLog( "O tamanho da pergunta " + aSX1[nI][nPosPerg] + " / " + aSX1[nI][nPosOrd] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				"   por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	oProcess:IncRegua2( "Atualizando perguntas..." )

	If !SX1->( dbSeek( PadR( aSX1[nI][nPosPerg], nTam1 ) + PadR( aSX1[nI][nPosOrd], nTam2 ) ) )
		AutoGrLog( "Pergunta Criada. Grupo/Ordem " + aSX1[nI][nPosPerg] + "/" + aSX1[nI][nPosOrd] )
		RecLock( "SX1", .T. )
	Else
		AutoGrLog( "Pergunta Alterada. Grupo/Ordem " + aSX1[nI][nPosPerg] + "/" + aSX1[nI][nPosOrd] )
		RecLock( "SX1", .F. )
	EndIf

	For nJ := 1 To Len( aSX1[nI] )
		If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
			SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aSX1[nI][nJ] ) )
		EndIf
	Next nJ

	MsUnLock()

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX1" + CRLF + Replicate( "-", 128 ) + CRLF )

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
@since  16/07/2019
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
@since  16/07/2019
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
