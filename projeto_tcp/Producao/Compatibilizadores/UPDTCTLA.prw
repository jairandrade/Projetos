#INCLUDE "protheus.ch"

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
/*/{Protheus.doc} UPDTCTLA
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  08/10/2020
@obs    Gerado por EXPORDIC - V.6.5.0.3 EFS / Upd. V.5.1.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDTCTLA( cEmpAmb, cFilAmb )

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
Local   cMsg      := ""
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

	If FindFunction( "MPDicInDB" ) .AND. MPDicInDB()
		cMsg := "Este update NÃO PODE ser executado neste Ambiente." + CRLF + CRLF + ;
				"Os arquivos de dicionários se encontram no Banco de Dados e este update está preparado " + ;
				"para atualizar apenas ambientes com dicionários no formato ISAM (.dbf ou .dtc)."

		If lAuto
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( cMsg )
			ConOut( DToC(Date()) + "|" + Time() + cMsg )
		Else
			MsgInfo( cMsg )
		EndIf

		Return NIL
	EndIf

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
					MsgStop( "Atualização Realizada.", "UPDTCTLA" )
				Else
					MsgStop( "Atualização não Realizada.", "UPDTCTLA" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização Realizada." )
				Else
					Final( "Atualização não Realizada." )
				EndIf
			EndIf

		Else
			Final( "Atualização não Realizada." )

		EndIf

	Else
		Final( "Atualização não Realizada." )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  08/10/2020
@obs    Gerado por EXPORDIC - V.6.5.0.3 EFS / Upd. V.5.1.0 EFS
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
			// Atualiza o dicionário SX7
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX7()

			//------------------------------------
			// Atualiza o dicionário SXA
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de pastas" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXA()

			//------------------------------------
			// Atualiza o dicionário SXB
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de consultas padrão" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXB()

			//------------------------------------
			// Atualiza os helps
			//------------------------------------
			oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuHlp()

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
@since  08/10/2020
@obs    Gerado por EXPORDIC - V.6.5.0.3 EFS / Upd. V.5.1.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cSeqAtu   := ""
Local cX3Campo  := ""
Local cX3Dado   := ""
Local nI        := 0
Local nJ        := 0
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
// Campos Tabela TKS
//
aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '01'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_FILIAL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Filial'																, .T. }, ; //X3_TITULO
	{ 'Filial'																, .T. }, ; //X3_TITSPA
	{ 'Filial'																, .T. }, ; //X3_TITENG
	{ 'Filial'																, .T. }, ; //X3_DESCRIC
	{ 'Filial'																, .T. }, ; //X3_DESCSPA
	{ 'Filial'																, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(128) + Chr(128)													, .T. }, ; //X3_RESERV
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
	{ '033'																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '02'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_CODCJN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Código'																, .T. }, ; //X3_TITULO
	{ 'Código'																, .T. }, ; //X3_TITSPA
	{ 'Código'																, .T. }, ; //X3_TITENG
	{ 'Código Conj. Hidráulico'												, .T. }, ; //X3_DESCRIC
	{ 'Código Conj. Hidráulico'												, .T. }, ; //X3_DESCSPA
	{ 'Código Conj. Hidráulico'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "EXISTCHAV('TKS',M->TKS_CODCJN)"										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(168)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
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
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '03'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_BEM'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 16																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Bem'																	, .T. }, ; //X3_TITULO
	{ 'Bem'																	, .T. }, ; //X3_TITSPA
	{ 'Bem'																	, .T. }, ; //X3_TITENG
	{ 'Codigo do Bem'														, .T. }, ; //X3_DESCRIC
	{ 'Codigo do Bem'														, .T. }, ; //X3_DESCSPA
	{ 'Codigo do Bem'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "MDT575CHKE('ST9','M->TKS_BEM','ST9->T9_CODBEM') .AND. MDT565LBEM()"		, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'ST9'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
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
	{ ''																	, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '04'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_DESCJN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 40																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Descrição'															, .T. }, ; //X3_TITULO
	{ 'Descrição'															, .T. }, ; //X3_TITSPA
	{ 'Descrição'															, .T. }, ; //X3_TITENG
	{ 'Descrição Conjunto Hidr.'											, .T. }, ; //X3_DESCRIC
	{ 'Descrição Conjunto Hidr.'											, .T. }, ; //X3_DESCSPA
	{ 'Descrição Conjunto Hidr.'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ "IF(INCLUI,SPACE(40),POSICIONE( 'ST9', 1, xFilial('ST9') + TKS->TKS_CODCJN, 'T9_NOME') )", .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
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
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '05'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_FAMCJN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Família'																, .T. }, ; //X3_TITULO
	{ 'Família'																, .T. }, ; //X3_TITSPA
	{ 'Família'																, .T. }, ; //X3_TITENG
	{ 'Família do Conjunto'													, .T. }, ; //X3_DESCRIC
	{ 'Família do Conjunto'													, .T. }, ; //X3_DESCSPA
	{ 'Família do Conjunto'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "MDT575CHKE('ST6','M->TKS_FAMCJN','ST6->T6_CODFAMI')"					, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'ST6'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ '€'																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'Empty(M->TKS_BEM)'													, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '06'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_NFACJN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 40																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome Família'														, .T. }, ; //X3_TITULO
	{ 'Nome Família'														, .T. }, ; //X3_TITSPA
	{ 'Nome Família'														, .T. }, ; //X3_TITENG
	{ 'Nome da Família'														, .T. }, ; //X3_DESCRIC
	{ 'Nome da Família'														, .T. }, ; //X3_DESCSPA
	{ 'Nome da Família'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ "IF(INCLUI,' ',POSICIONE( 'ST6', 1, xFilial('ST6') + TKS->TKS_FAMCJN, 'T6_NOME') )", .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'Empty(M->TKS_BEM)'													, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '07'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_CCCJN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Centro Custo'														, .T. }, ; //X3_TITULO
	{ 'Centro Custo'														, .T. }, ; //X3_TITSPA
	{ 'Centro Custo'														, .T. }, ; //X3_TITENG
	{ 'Centro de Custo do Conjun'											, .T. }, ; //X3_DESCRIC
	{ 'Centro de Custo do Conjun'											, .T. }, ; //X3_DESCSPA
	{ 'Centro de Custo do Conjun'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "MDT575CHKE('CTT','M->TKS_CCCJN','CTT->CTT_CUSTO')"					, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CTT'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ '€'																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'Empty(M->TKS_BEM)'													, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '004'																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '08'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_NCCCJN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 40																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome C.C.'															, .T. }, ; //X3_TITULO
	{ 'Nome C.C.'															, .T. }, ; //X3_TITSPA
	{ 'Nome C.C.'															, .T. }, ; //X3_TITENG
	{ 'Nome do Centro de Custo'												, .T. }, ; //X3_DESCRIC
	{ 'Nome do Centro de Custo'												, .T. }, ; //X3_DESCSPA
	{ 'Nome do Centro de Custo'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ "IF(INCLUI,' ',POSICIONE( 'CTT', 1, xFilial('CTT') + TKS->TKS_CCCJN, 'CTT_DESC01') )", .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'Empty(M->TKS_BEM)'													, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '09'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_LOCCJN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 40																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Localização'															, .T. }, ; //X3_TITULO
	{ 'Localização'															, .T. }, ; //X3_TITSPA
	{ 'Localização'															, .T. }, ; //X3_TITENG
	{ 'Localização do Conjunto'												, .T. }, ; //X3_DESCRIC
	{ 'Localização do Conjunto'												, .T. }, ; //X3_DESCSPA
	{ 'Localização do Conjunto'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
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
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '10'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_TURCJN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Turno'																, .T. }, ; //X3_TITULO
	{ 'Turno'																, .T. }, ; //X3_TITSPA
	{ 'Turno'																, .T. }, ; //X3_TITENG
	{ 'Turno do Conjunto'													, .T. }, ; //X3_DESCRIC
	{ 'Turno do Conjunto'													, .T. }, ; //X3_DESCSPA
	{ 'Turno do Conjunto'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "MDT575CHKE('SH7','M->TKS_TURCJN','SH7->H7_CODIGO')"					, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SH7'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
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
	{ 'Empty(M->TKS_BEM)'													, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '11'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_NTUCJN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 20																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome Turno'															, .T. }, ; //X3_TITULO
	{ 'Nome Turno'															, .T. }, ; //X3_TITSPA
	{ 'Nome Turno'															, .T. }, ; //X3_TITENG
	{ 'Nome do Turno do Conjunto'											, .T. }, ; //X3_DESCRIC
	{ 'Nome do Turno do Conjunto'											, .T. }, ; //X3_DESCSPA
	{ 'Nome do Turno do Conjunto'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ "IF(INCLUI,' ',POSICIONE( 'SH7', 1, xFilial('SH7') + TKS->TKS_TURCJN, 'H7_DESCRI') )", .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'N'																	, .T. }, ; //X3_BROWSE
	{ 'V'																	, .T. }, ; //X3_VISUAL
	{ 'V'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ ''																	, .T. }, ; //X3_CBOX
	{ ''																	, .T. }, ; //X3_CBOXSPA
	{ ''																	, .T. }, ; //X3_CBOXENG
	{ ''																	, .T. }, ; //X3_PICTVAR
	{ 'Empty(M->TKS_BEM)'													, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '12'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_MARCA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 20																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Marca'																, .T. }, ; //X3_TITULO
	{ 'Marca'																, .T. }, ; //X3_TITSPA
	{ 'Marca'																, .T. }, ; //X3_TITENG
	{ 'Marca'																, .T. }, ; //X3_DESCRIC
	{ 'Marca'																, .T. }, ; //X3_DESCSPA
	{ 'Marca'																, .T. }, ; //X3_DESCENG
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '13'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_MODELO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Modelo'																, .T. }, ; //X3_TITULO
	{ 'Modelo'																, .T. }, ; //X3_TITSPA
	{ 'Modelo'																, .T. }, ; //X3_TITENG
	{ 'Modelo'																, .T. }, ; //X3_DESCRIC
	{ 'Modelo'																, .T. }, ; //X3_DESCSPA
	{ 'Modelo'																, .T. }, ; //X3_DESCENG
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
	{ 'Empty(M->TKS_BEM)'													, .T. }, ; //X3_WHEN
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '14'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_CAPACI'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 3																		, .T. }, ; //X3_DECIMAL
	{ 'Capacidade'															, .T. }, ; //X3_TITULO
	{ 'Capacidade'															, .T. }, ; //X3_TITSPA
	{ 'Capacidade'															, .T. }, ; //X3_TITENG
	{ 'Capacidade'															, .T. }, ; //X3_DESCRIC
	{ 'Capacidade'															, .T. }, ; //X3_DESCSPA
	{ 'Capacidade'															, .T. }, ; //X3_DESCENG
	{ '@E 99,999,999.999'													, .T. }, ; //X3_PICTURE
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '15'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_UNIMED'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Und. Medida'															, .T. }, ; //X3_TITULO
	{ 'Und. Medida'															, .T. }, ; //X3_TITSPA
	{ 'Und. Medida'															, .T. }, ; //X3_TITENG
	{ 'Unidade de Medida'													, .T. }, ; //X3_DESCRIC
	{ 'Unidade de Medida'													, .T. }, ; //X3_DESCSPA
	{ 'Unidade de Medida'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "EXISTCPO('SX5','62'+M->TKS_UNIMED)"									, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ '62'																	, .T. }, ; //X3_F3
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '16'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_SITUAC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Situação'															, .T. }, ; //X3_TITULO
	{ 'Situação'															, .T. }, ; //X3_TITSPA
	{ 'Situação'															, .T. }, ; //X3_TITENG
	{ 'Situação do Conjunto Hid.'											, .T. }, ; //X3_DESCRIC
	{ 'Situação do Conjunto Hid.'											, .T. }, ; //X3_DESCSPA
	{ 'Situação do Conjunto Hid.'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "Pertence('12')"														, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ "If(Inclui,'1',TKS->TKS_SITUAC)"										, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(133) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ 'x'																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Ativo;2=Inativo'													, .T. }, ; //X3_CBOX
	{ '1=Ativo;2=Inativo'													, .T. }, ; //X3_CBOXSPA
	{ '1=Ativo;2=Inativo'													, .T. }, ; //X3_CBOXENG
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
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '17'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_DTMANU'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dt. Inspecao'														, .T. }, ; //X3_TITULO
	{ 'Dt. Inspecao'														, .T. }, ; //X3_TITSPA
	{ 'Dt. Ult.Man.'														, .T. }, ; //X3_TITENG
	{ 'Data Inspecao'														, .T. }, ; //X3_DESCRIC
	{ 'Data Inspecao'														, .T. }, ; //X3_DESCSPA
	{ 'Data Inspecao'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '18'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_ANOFAB'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 4																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ano Fabric.'															, .T. }, ; //X3_TITULO
	{ 'Ano Fabric.'															, .T. }, ; //X3_TITSPA
	{ 'Ano Fabric.'															, .T. }, ; //X3_TITENG
	{ 'Ano da Fabricação'													, .T. }, ; //X3_DESCRIC
	{ 'Ano da Fabricação'													, .T. }, ; //X3_DESCSPA
	{ 'Ano da Fabricação'													, .T. }, ; //X3_DESCENG
	{ '9999'																, .T. }, ; //X3_PICTURE
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
	{ 'Empty(M->TKS_BEM)'													, .T. }, ; //X3_WHEN
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '19'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_DTCOMP'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Dt. Compra'															, .T. }, ; //X3_TITULO
	{ 'Dt. Compra'															, .T. }, ; //X3_TITSPA
	{ 'Dt. Compra'															, .T. }, ; //X3_TITENG
	{ 'Data da Compra'														, .T. }, ; //X3_DESCRIC
	{ 'Data da Compra'														, .T. }, ; //X3_DESCSPA
	{ 'Data da Compra'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'dDataBase'															, .T. }, ; //X3_RELACAO
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
	{ 'Empty(M->TKS_BEM)'													, .T. }, ; //X3_WHEN
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '20'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_FABRIC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Fabricante'															, .T. }, ; //X3_TITULO
	{ 'Fabricante'															, .T. }, ; //X3_TITSPA
	{ 'Fabricante'															, .T. }, ; //X3_TITENG
	{ 'Fabricante do Conjunto'												, .T. }, ; //X3_DESCRIC
	{ 'Fabricante do Conjunto'												, .T. }, ; //X3_DESCSPA
	{ 'Fabricante do Conjunto'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "MDT575CHKE('ST7','M->TKS_FABRIC','ST7->T7_FABRICA')"					, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'ST7'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
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
	{ 'Empty(M->TKS_BEM)'													, .T. }, ; //X3_WHEN
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '21'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_NOMFAB'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 40																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome Fabric.'														, .T. }, ; //X3_TITULO
	{ 'Nome Fabric.'														, .T. }, ; //X3_TITSPA
	{ 'Nome Fabric.'														, .T. }, ; //X3_TITENG
	{ 'Nome Fabric. do Conjunto'											, .T. }, ; //X3_DESCRIC
	{ 'Nome Fabric. do Conjunto'											, .T. }, ; //X3_DESCSPA
	{ 'Nome Fabric. do Conjunto'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ "IF(INCLUI,' ',POSICIONE( 'ST7', 1, xFilial('ST7') + TKS->TKS_FABRIC, 'T7_NOME') )", .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
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
	{ 'Empty(M->TKS_BEM)'													, .T. }, ; //X3_WHEN
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '22'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_FORNEC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Fornecedor'															, .T. }, ; //X3_TITULO
	{ 'Fornecedor'															, .T. }, ; //X3_TITSPA
	{ 'Fornecedor'															, .T. }, ; //X3_TITENG
	{ 'Fornecedor do Conjunto'												, .T. }, ; //X3_DESCRIC
	{ 'Fornecedor do Conjunto'												, .T. }, ; //X3_DESCSPA
	{ 'Fornecedor do Conjunto'												, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "MDT575CHKE('SA2','M->TKS_FORNEC','SA2->A2_COD')"						, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'SA2'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
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
	{ 'Empty(M->TKS_BEM)'													, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '001'																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ ''																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '23'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_LOJA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Loja Fornec.'														, .T. }, ; //X3_TITULO
	{ 'Loja Fornec.'														, .T. }, ; //X3_TITSPA
	{ 'Loja Fornec.'														, .T. }, ; //X3_TITENG
	{ 'Loja Fornec. do Conjunto'											, .T. }, ; //X3_DESCRIC
	{ 'Loja Fornec. do Conjunto'											, .T. }, ; //X3_DESCSPA
	{ 'Loja Fornec. do Conjunto'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ "IF(INCLUI,' ',POSICIONE( 'SA2', 1, xFilial('SA2') + TKS->TKS_FORNEC, 'A2_LOJA') )", .T. }, ; //X3_RELACAO
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
	{ 'Empty(M->TKS_BEM)'													, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '002'																	, .T. }, ; //X3_GRPSXG
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '24'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_NOMFOR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 40																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome Fornec.'														, .T. }, ; //X3_TITULO
	{ 'Nome Fornec.'														, .T. }, ; //X3_TITSPA
	{ 'Nome Fornec.'														, .T. }, ; //X3_TITENG
	{ 'Nome Fornec. do Conjunto'											, .T. }, ; //X3_DESCRIC
	{ 'Nome Fornec. do Conjunto'											, .T. }, ; //X3_DESCSPA
	{ 'Nome Fornec. do Conjunto'											, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ "IF(INCLUI,' ',POSICIONE( 'SA2', 1, xFilial('SA2') + TKS->TKS_FORNEC, 'A2_NOME') )", .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(132) + Chr(128)													, .T. }, ; //X3_RESERV
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '25'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_XSISTE'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 80																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Sistema'																, .T. }, ; //X3_TITULO
	{ 'Sistema'																, .T. }, ; //X3_TITSPA
	{ 'Sistema'																, .T. }, ; //X3_TITENG
	{ 'Sistema'																, .T. }, ; //X3_DESCRIC
	{ 'Sistema'																, .T. }, ; //X3_DESCSPA
	{ 'Sistema'																, .T. }, ; //X3_DESCENG
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
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '26'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_XPATRI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 40																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Patrimonio'															, .T. }, ; //X3_TITULO
	{ 'Patrimonio'															, .T. }, ; //X3_TITSPA
	{ 'Patrimonio'															, .T. }, ; //X3_TITENG
	{ 'Patrimonio'															, .T. }, ; //X3_DESCRIC
	{ 'Patrimonio'															, .T. }, ; //X3_DESCSPA
	{ 'Patrimonio'															, .T. }, ; //X3_DESCENG
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
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '27'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_XDIAME'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 40																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Diametro POL'														, .T. }, ; //X3_TITULO
	{ 'Diametro POL'														, .T. }, ; //X3_TITSPA
	{ 'Diametro POL'														, .T. }, ; //X3_TITENG
	{ 'Diametro POL'														, .T. }, ; //X3_DESCRIC
	{ 'Diametro POL'														, .T. }, ; //X3_DESCSPA
	{ 'Diametro POL'														, .T. }, ; //X3_DESCENG
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
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '28'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_XCOMPR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 40																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Comprimento'															, .T. }, ; //X3_TITULO
	{ 'Comprimento'															, .T. }, ; //X3_TITSPA
	{ 'Comprimento'															, .T. }, ; //X3_TITENG
	{ 'Comprimento'															, .T. }, ; //X3_DESCRIC
	{ 'Comprimento'															, .T. }, ; //X3_DESCSPA
	{ 'Comprimento'															, .T. }, ; //X3_DESCENG
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
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '29'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_XTIPO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 60																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo'																, .T. }, ; //X3_TITULO
	{ 'Tipo'																, .T. }, ; //X3_TITSPA
	{ 'Tipo'																, .T. }, ; //X3_TITENG
	{ 'Tipo'																, .T. }, ; //X3_DESCRIC
	{ 'Tipo'																, .T. }, ; //X3_DESCSPA
	{ 'Tipo'																, .T. }, ; //X3_DESCENG
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
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '30'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_XPRESS'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 60																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Press Ensaio'														, .T. }, ; //X3_TITULO
	{ 'Press Ensaio'														, .T. }, ; //X3_TITSPA
	{ 'Press Ensaio'														, .T. }, ; //X3_TITENG
	{ 'Pressao Ensaio'														, .T. }, ; //X3_DESCRIC
	{ 'Pressao Ensaio'														, .T. }, ; //X3_DESCSPA
	{ 'Pressao Ensaio'														, .T. }, ; //X3_DESCENG
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
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '31'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_XLACRE'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 60																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Lacre'																, .T. }, ; //X3_TITULO
	{ 'Lacre'																, .T. }, ; //X3_TITSPA
	{ 'Lacre'																, .T. }, ; //X3_TITENG
	{ 'Lacre'																, .T. }, ; //X3_DESCRIC
	{ 'Lacre'																, .T. }, ; //X3_DESCSPA
	{ 'Lacre'																, .T. }, ; //X3_DESCENG
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
	{ '1'																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TKS'																	, .T. }, ; //X3_ARQUIVO
	{ '32'																	, .T. }, ; //X3_ORDEM
	{ 'TKS_XOBSET'															, .T. }, ; //X3_CAMPO
	{ 'M'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Observacao'															, .T. }, ; //X3_TITULO
	{ 'Observacao'															, .T. }, ; //X3_TITSPA
	{ 'Observacao'															, .T. }, ; //X3_TITENG
	{ 'Observacao'															, .T. }, ; //X3_DESCRIC
	{ 'Observacao'															, .T. }, ; //X3_DESCSPA
	{ 'Observacao'															, .T. }, ; //X3_DESCENG
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
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

//
// Campos Tabela TLA
//
aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '01'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_FILIAL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 2																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Filial'																, .T. }, ; //X3_TITULO
	{ 'Sucursal'															, .T. }, ; //X3_TITSPA
	{ 'Branch'																, .T. }, ; //X3_TITENG
	{ 'Filial do Sistema'													, .T. }, ; //X3_DESCRIC
	{ 'Sucursal del sistema'												, .T. }, ; //X3_DESCSPA
	{ 'System branch'														, .T. }, ; //X3_DESCENG
	{ ''																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(221) + Chr(171)													, .T. }, ; //X3_RESERV
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
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '02'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_CODEXT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 10																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Código'																, .T. }, ; //X3_TITULO
	{ 'Codigo'																, .T. }, ; //X3_TITSPA
	{ 'Code'																, .T. }, ; //X3_TITENG
	{ 'Codigo do Extintor'													, .T. }, ; //X3_DESCRIC
	{ 'Codigo del extintor'													, .T. }, ; //X3_DESCSPA
	{ 'Extinguisher code'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'EXISTCHAV("TLA",M->TLA_CODEXT)'										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(221) + Chr(171)													, .T. }, ; //X3_RESERV
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
	{ 'INCLUI'																, .T. }, ; //X3_WHEN
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
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '03'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_DESCRI'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 30																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Descrição'															, .T. }, ; //X3_TITULO
	{ 'Descripcion'															, .T. }, ; //X3_TITSPA
	{ 'Description'															, .T. }, ; //X3_TITENG
	{ 'Descricao'															, .T. }, ; //X3_DESCRIC
	{ 'Descripcion'															, .T. }, ; //X3_DESCSPA
	{ 'Description'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(221) + Chr(171)													, .T. }, ; //X3_RESERV
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
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '04'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_CC'																, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 9																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Centro Custo'														, .T. }, ; //X3_TITULO
	{ 'Centro Costo'														, .T. }, ; //X3_TITSPA
	{ 'Cost center'															, .T. }, ; //X3_TITENG
	{ 'Centro Custo'														, .T. }, ; //X3_DESCRIC
	{ 'Centro Costo'														, .T. }, ; //X3_DESCSPA
	{ 'Cost center'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ 'IF(VAZIO(),.T.,CTB105CC())'											, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'CTT'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(221) + Chr(171)													, .T. }, ; //X3_RESERV
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
	{ 'MDT540WCC()'															, .T. }, ; //X3_WHEN
	{ ''																	, .T. }, ; //X3_INIBRW
	{ '004'																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'N'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '05'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_NOMECC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 20																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Nome'																, .T. }, ; //X3_TITULO
	{ 'Nombre'																, .T. }, ; //X3_TITSPA
	{ 'Name'																, .T. }, ; //X3_TITENG
	{ 'Nome do C. Custo'													, .T. }, ; //X3_DESCRIC
	{ 'Nombre de C. Costo'													, .T. }, ; //X3_DESCSPA
	{ 'Cost center name'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ 'MDT540BRW(.F.)'														, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(221) + Chr(171)													, .T. }, ; //X3_RESERV
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
	{ 'MDT540BRW(.T.)'														, .T. }, ; //X3_INIBRW
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
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '06'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_LOCAL'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 80																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Localização'															, .T. }, ; //X3_TITULO
	{ 'Localizacion'														, .T. }, ; //X3_TITSPA
	{ 'Location'															, .T. }, ; //X3_TITENG
	{ 'Localizacao'															, .T. }, ; //X3_DESCRIC
	{ 'Localizacion'														, .T. }, ; //X3_DESCSPA
	{ 'Location'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(221) + Chr(171)													, .T. }, ; //X3_RESERV
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
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '07'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_MARCA'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 20																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Marca'																, .T. }, ; //X3_TITULO
	{ 'Marca'																, .T. }, ; //X3_TITSPA
	{ 'Brand'																, .T. }, ; //X3_TITENG
	{ 'Marca'																, .T. }, ; //X3_DESCRIC
	{ 'Marca'																, .T. }, ; //X3_DESCSPA
	{ 'Brand'																, .T. }, ; //X3_DESCENG
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
	{ ''																	, .T. }, ; //X3_GRPSXG
	{ ''																	, .T. }, ; //X3_FOLDER
	{ ''																	, .T. }, ; //X3_CONDSQL
	{ ''																	, .T. }, ; //X3_CHKSQL
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '08'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_TIPO'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 40																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Tipo'																, .T. }, ; //X3_TITULO
	{ 'Tipo'																, .T. }, ; //X3_TITSPA
	{ 'Type'																, .T. }, ; //X3_TITENG
	{ 'Tipo'																, .T. }, ; //X3_DESCRIC
	{ 'Tipo'																, .T. }, ; //X3_DESCSPA
	{ 'Type'																, .T. }, ; //X3_DESCENG
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
	{ 'S'																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '1'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '09'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_CAPACI'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 12																	, .T. }, ; //X3_TAMANHO
	{ 3																		, .T. }, ; //X3_DECIMAL
	{ 'Capacidade'															, .T. }, ; //X3_TITULO
	{ 'Capacidad'															, .T. }, ; //X3_TITSPA
	{ 'Capacity'															, .T. }, ; //X3_TITENG
	{ 'Capacidade'															, .T. }, ; //X3_DESCRIC
	{ 'Capacidad'															, .T. }, ; //X3_DESCSPA
	{ 'Capacity'															, .T. }, ; //X3_DESCENG
	{ '@E 99999999.999'														, .T. }, ; //X3_PICTURE
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '10'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_UNIMED'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Unid. Medida'														, .T. }, ; //X3_TITULO
	{ 'Unid. Medida'														, .T. }, ; //X3_TITSPA
	{ 'Meas Unit'															, .T. }, ; //X3_TITENG
	{ 'Unidade de Medida'													, .T. }, ; //X3_DESCRIC
	{ 'Unidad de Medida'													, .T. }, ; //X3_DESCSPA
	{ 'Unit of measurement'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "EXISTCPO('SX5','62'+M->TLA_UNIMED)"									, .T. }, ; //X3_VALID
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '11'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_SITUAC'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 1																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Situação'															, .T. }, ; //X3_TITULO
	{ 'Situacion'															, .T. }, ; //X3_TITSPA
	{ 'Status'																, .T. }, ; //X3_TITENG
	{ 'Situação'															, .T. }, ; //X3_DESCRIC
	{ 'Situacion'															, .T. }, ; //X3_DESCSPA
	{ 'Status'																, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "If(Inclui,'1',TLA->TLA_SITUAC)"										, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ "If(Inclui,'1',TLA->TLA_SITUAC)"										, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(197) + Chr(128)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ ''																	, .T. }, ; //X3_TRIGGER
	{ ''																	, .T. }, ; //X3_PROPRI
	{ 'S'																	, .T. }, ; //X3_BROWSE
	{ 'A'																	, .T. }, ; //X3_VISUAL
	{ 'R'																	, .T. }, ; //X3_CONTEXT
	{ ''																	, .T. }, ; //X3_OBRIGAT
	{ ''																	, .T. }, ; //X3_VLDUSER
	{ '1=Ativo;2=Inativo'													, .T. }, ; //X3_CBOX
	{ '1=Activo;2=Inactivo'													, .T. }, ; //X3_CBOXSPA
	{ '1=Active;2=Inactive'													, .T. }, ; //X3_CBOXENG
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
	{ '1'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '12'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_XCAPEX'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 80																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Capac. Extin'														, .T. }, ; //X3_TITULO
	{ 'Capac. Extin'														, .T. }, ; //X3_TITSPA
	{ 'Capac. Extin'														, .T. }, ; //X3_TITENG
	{ 'Capacidade Extintora'												, .T. }, ; //X3_DESCRIC
	{ 'Capacidade Extintora'												, .T. }, ; //X3_DESCSPA
	{ 'Capacidade Extintora'												, .T. }, ; //X3_DESCENG
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
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '13'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_XSUPOR'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 30																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Suporte'																, .T. }, ; //X3_TITULO
	{ 'Suporte'																, .T. }, ; //X3_TITSPA
	{ 'Suporte'																, .T. }, ; //X3_TITENG
	{ 'Suporte'																, .T. }, ; //X3_DESCRIC
	{ 'Suporte'																, .T. }, ; //X3_DESCSPA
	{ 'Suporte'																, .T. }, ; //X3_DESCENG
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
	{ ''																	, .T. }, ; //X3_IDXSRV
	{ 'N'																	, .T. }, ; //X3_ORTOGRA
	{ ''																	, .T. }, ; //X3_TELA
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '14'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_XMANU3'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Manut. 3 niv'														, .T. }, ; //X3_TITULO
	{ 'Manut. 3 niv'														, .T. }, ; //X3_TITSPA
	{ 'Manut. 3 niv'														, .T. }, ; //X3_TITENG
	{ 'Manutencao 3 nivel'													, .T. }, ; //X3_DESCRIC
	{ 'Manutencao 3 nivel'													, .T. }, ; //X3_DESCSPA
	{ 'Manutencao 3 nivel'													, .T. }, ; //X3_DESCENG
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
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '15'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_XMANU2'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Manut. 2 niv'														, .T. }, ; //X3_TITULO
	{ 'Manut. 2 niv'														, .T. }, ; //X3_TITSPA
	{ 'Manut. 2 niv'														, .T. }, ; //X3_TITENG
	{ 'Manutencao 2 nivel'													, .T. }, ; //X3_DESCRIC
	{ 'Manutencao 2 nivel'													, .T. }, ; //X3_DESCSPA
	{ 'Manutencao 2 nivel'													, .T. }, ; //X3_DESCENG
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
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '16'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_DTMANU'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ult. Manut.'															, .T. }, ; //X3_TITULO
	{ 'Ult. Mant.'															, .T. }, ; //X3_TITSPA
	{ 'Last Maint'															, .T. }, ; //X3_TITENG
	{ 'Data Ultima Manutencao'												, .T. }, ; //X3_DESCRIC
	{ 'Fecha Ultimo Mantenim.'												, .T. }, ; //X3_DESCSPA
	{ 'Date of last maintenance'											, .T. }, ; //X3_DESCENG
	{ '99/99/9999'															, .T. }, ; //X3_PICTURE
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '17'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_DTRECA'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ult. Recarga'														, .T. }, ; //X3_TITULO
	{ 'Ult. recarga'														, .T. }, ; //X3_TITSPA
	{ 'Last Reload'															, .T. }, ; //X3_TITENG
	{ 'Data Ultima Recarga'													, .T. }, ; //X3_DESCRIC
	{ 'Fecha Ultima Recarga'												, .T. }, ; //X3_DESCSPA
	{ 'Date of last reload'													, .T. }, ; //X3_DESCENG
	{ '99/99/9999'															, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(254) + Chr(192)													, .T. }, ; //X3_RESERV
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'S'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '18'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_XVALID'															, .T. }, ; //X3_CAMPO
	{ 'D'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Validade'															, .T. }, ; //X3_TITULO
	{ 'Validade'															, .T. }, ; //X3_TITSPA
	{ 'Validade'															, .T. }, ; //X3_TITENG
	{ 'Validade'															, .T. }, ; //X3_DESCRIC
	{ 'Validade'															, .T. }, ; //X3_DESCSPA
	{ 'Validade'															, .T. }, ; //X3_DESCENG
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
	{ '2'																	, .T. }, ; //X3_POSLGT
	{ 'N'																	, .T. }, ; //X3_IDXFLD
	{ ''																	, .T. }, ; //X3_AGRUP
	{ '2'																	, .T. }, ; //X3_MODAL
	{ ''																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '19'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_NUMFAB'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Num. Fabric.'														, .T. }, ; //X3_TITULO
	{ 'Num. Fabric.'														, .T. }, ; //X3_TITSPA
	{ 'Num. Fabric.'														, .T. }, ; //X3_TITENG
	{ 'Numero Fabricacao'													, .T. }, ; //X3_DESCRIC
	{ 'Numero Fabricacao'													, .T. }, ; //X3_DESCSPA
	{ 'Numero Fabricacao'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '20'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_PESOVZ'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 1																		, .T. }, ; //X3_DECIMAL
	{ 'Peso Vazio'															, .T. }, ; //X3_TITULO
	{ 'Peso Vazio'															, .T. }, ; //X3_TITSPA
	{ 'Peso Vazio'															, .T. }, ; //X3_TITENG
	{ 'Peso Vazio'															, .T. }, ; //X3_DESCRIC
	{ 'Peso Vazio'															, .T. }, ; //X3_DESCSPA
	{ 'Peso Vazio'															, .T. }, ; //X3_DESCENG
	{ '@E 999,999.9'														, .T. }, ; //X3_PICTURE
	{ 'vPesoVzCh()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(192)													, .T. }, ; //X3_RESERV
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '21'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_PESOCH'															, .T. }, ; //X3_CAMPO
	{ 'N'																	, .T. }, ; //X3_TIPO
	{ 8																		, .T. }, ; //X3_TAMANHO
	{ 1																		, .T. }, ; //X3_DECIMAL
	{ 'Peso Cheio'															, .T. }, ; //X3_TITULO
	{ 'Peso Cheio'															, .T. }, ; //X3_TITSPA
	{ 'Peso Cheio'															, .T. }, ; //X3_TITENG
	{ 'Peso Cheio'															, .T. }, ; //X3_DESCRIC
	{ 'Peso Cheio'															, .T. }, ; //X3_DESCSPA
	{ 'Peso Cheio'															, .T. }, ; //X3_DESCENG
	{ '@E 999,999.9'														, .T. }, ; //X3_PICTURE
	{ 'vPesoVzCh()'															, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(158) + Chr(192)													, .T. }, ; //X3_RESERV
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '22'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_PESOUN'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 6																		, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Un.Med. Peso'														, .T. }, ; //X3_TITULO
	{ 'Un.Med. Peso'														, .T. }, ; //X3_TITSPA
	{ 'Un.Med. Peso'														, .T. }, ; //X3_TITENG
	{ 'Un.Med. Peso'														, .T. }, ; //X3_DESCRIC
	{ 'Un.Med. Peso'														, .T. }, ; //X3_DESCSPA
	{ 'Un.Med. Peso'														, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "EXISTCPO('SX5','62'+M->TLA_PESOUN)"									, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ '62'																	, .T. }, ; //X3_F3
	{ 0																		, .T. }, ; //X3_NIVEL
	{ Chr(134) + Chr(192)													, .T. }, ; //X3_RESERV
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '23'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_ATIFIX'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 14																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Ativo Fixo'															, .T. }, ; //X3_TITULO
	{ 'Ativo Fixo'															, .T. }, ; //X3_TITSPA
	{ 'Ativo Fixo'															, .T. }, ; //X3_TITENG
	{ 'Código Ativo Fixo'													, .T. }, ; //X3_DESCRIC
	{ 'Código Ativo Fixo'													, .T. }, ; //X3_DESCSPA
	{ 'Código Ativo Fixo'													, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ "IF(!Empty(M->TLA_ATIFIX),EXISTCPO('SN1',M->TLA_ATIFIX) .and. VA540AT(),.T.)", .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ 'NG9'																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(198) + Chr(192)													, .T. }, ; //X3_RESERV
	{ ''																	, .T. }, ; //X3_CHECK
	{ 'S'																	, .T. }, ; //X3_TRIGGER
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
	{ "SuperGetMv('MV_NGMDTAT',.F.,'2') == '1'"								, .T. }, ; //X3_WHEN
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
	{ '2'																	, .T. }, ; //X3_MODAL
	{ 'N'																	, .T. }} ) //X3_PYME

aAdd( aSX3, { ;
	{ 'TLA'																	, .T. }, ; //X3_ARQUIVO
	{ '24'																	, .T. }, ; //X3_ORDEM
	{ 'TLA_ABNT'															, .T. }, ; //X3_CAMPO
	{ 'C'																	, .T. }, ; //X3_TIPO
	{ 15																	, .T. }, ; //X3_TAMANHO
	{ 0																		, .T. }, ; //X3_DECIMAL
	{ 'Num. Inmetro'														, .T. }, ; //X3_TITULO
	{ 'Num. Inmetro'														, .T. }, ; //X3_TITSPA
	{ 'Num. Inmetro'														, .T. }, ; //X3_TITENG
	{ 'Numero Inmetro'														, .T. }, ; //X3_DESCRIC
	{ 'Código ABNT'															, .T. }, ; //X3_DESCSPA
	{ 'Código ABNT'															, .T. }, ; //X3_DESCENG
	{ '@!'																	, .T. }, ; //X3_PICTURE
	{ ''																	, .T. }, ; //X3_VALID
	{ Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, .T. }, ; //X3_USADO
	{ ''																	, .T. }, ; //X3_RELACAO
	{ ''																	, .T. }, ; //X3_F3
	{ 1																		, .T. }, ; //X3_NIVEL
	{ Chr(214) + Chr(192)													, .T. }, ; //X3_RESERV
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
	{ '2'																	, .T. }, ; //X3_MODAL
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

			If aSX3[nI][nJ][2]
				cX3Campo := AllTrim( aEstrut[nJ][1] )
				cX3Dado  := SX3->( FieldGet( aEstrut[nJ][2] ) )

				If  aEstrut[nJ][2] > 0 .AND. ;
					PadR( StrTran( AllToChar( cX3Dado ), " ", "" ), 250 ) <> ;
					PadR( StrTran( AllToChar( aSX3[nI][nJ][1] ), " ", "" ), 250 ) .AND. ;
					!cX3Campo  == "X3_ORDEM"

					AutoGrLog( "Alterado campo " + aSX3[nI][nPosCpo][1] + CRLF + ;
					"   " + PadR( cX3Campo, 10 ) + " de [" + AllToChar( cX3Dado ) + "]" + CRLF + ;
					"            para [" + AllToChar( aSX3[nI][nJ][1] )           + "]" + CRLF )

					RecLock( "SX3", .F. )
					FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ][1] )
					MsUnLock()
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
@since  08/10/2020
@obs    Gerado por EXPORDIC - V.6.5.0.3 EFS / Upd. V.5.1.0 EFS
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
// Tabela TKS
//
aAdd( aSIX, { ;
	'TKS'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'TKS_FILIAL+TKS_CODCJN'													, ; //CHAVE
	'Cod. Cj. Hid'															, ; //DESCRICAO
	'Cod. Cj. Hid'															, ; //DESCSPA
	'HydrSetCode'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'TKS'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'TKS_FILIAL+TKS_CCCJN'													, ; //CHAVE
	'Centro Custo'															, ; //DESCRICAO
	'Centro costo'															, ; //DESCSPA
	'Cost Center'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'TKS'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'TKS_FILIAL+TKS_FAMCJN'													, ; //CHAVE
	'Família'																, ; //DESCRICAO
	'Familia'																, ; //DESCSPA
	'Family'																, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'TKS'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'TKS_FILIAL+TKS_FORNEC'													, ; //CHAVE
	'Fornecedor'															, ; //DESCRICAO
	'Proveedor'																, ; //DESCSPA
	'Supplier'																, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'TKS'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'TKS_FILIAL+TKS_FABRIC'													, ; //CHAVE
	'Fabricante'															, ; //DESCRICAO
	'Fabricante'															, ; //DESCSPA
	'Manufacturer'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'TKS'																	, ; //INDICE
	'6'																		, ; //ORDEM
	'TKS_FILIAL+TKS_BEM'													, ; //CHAVE
	'Bem'																	, ; //DESCRICAO
	'Bien'																	, ; //DESCSPA
	'Asset'																	, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela TLA
//
aAdd( aSIX, { ;
	'TLA'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'TLA_FILIAL+TLA_CODEXT'													, ; //CHAVE
	'Código'																, ; //DESCRICAO
	'Codigo'																, ; //DESCSPA
	'Code'																	, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'TLA'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'TLA_FILIAL+TLA_DESCRI'													, ; //CHAVE
	'Descrição'																, ; //DESCRICAO
	'Descripcion'															, ; //DESCSPA
	'Description'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'TLA'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'TLA_FILIAL+TLA_CC'														, ; //CHAVE
	'Centro Custo'															, ; //DESCRICAO
	'Centro Costo'															, ; //DESCSPA
	'Cost center'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'TLA'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'TLA_FILIAL+TLA_TIPO+TLA_CODEXT'										, ; //CHAVE
	'Tipo + Código'															, ; //DESCRICAO
	'Tipo + Codigo'															, ; //DESCSPA
	'Type + Code'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'TLA'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'TLA_FILIAL+TLA_SITUAC+TLA_CODEXT'										, ; //CHAVE
	'Situação + Código'														, ; //DESCRICAO
	'Situacion + Codigo'													, ; //DESCSPA
	'Status + Code'															, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'TLA'																	, ; //INDICE
	'6'																		, ; //ORDEM
	'TLA_FILIAL+TLA_CODEXT+TLA_CC'											, ; //CHAVE
	'Código + Centro Custo'													, ; //DESCRICAO
	'Codigo + Centro Costo'													, ; //DESCSPA
	'Code + Cost center'													, ; //DESCENG
	'S'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'TLA'																	, ; //INDICE
	'7'																		, ; //ORDEM
	'TLA_FILIAL+TLA_ATIFIX'													, ; //CHAVE
	'Ativo Fixo'															, ; //DESCRICAO
	'Activo Fijo'															, ; //DESCSPA
	'Fixed Asset'															, ; //DESCENG
	'S'																		, ; //PROPRI
	'XXX+NG9'																, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

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
/*/{Protheus.doc} FSAtuSX7
Função de processamento da gravação do SX7 - Gatilhos

@author TOTVS Protheus
@since  08/10/2020
@obs    Gerado por EXPORDIC - V.6.5.0.3 EFS / Upd. V.5.1.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX7()
Local aEstrut   := {}
Local aAreaSX3  := SX3->( GetArea() )
Local aSX7      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX7->X7_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX7" + CRLF )

aEstrut := { "X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "X7_TIPO", "X7_SEEK", ;
             "X7_ALIAS", "X7_ORDEM"  , "X7_CHAVE", "X7_PROPRI", "X7_CONDIC" }

//
// Campo TKS_BEM
//
aAdd( aSX7, { ;
	'TKS_BEM'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'SUBSTR(ST9->T9_NOME,1,20)'												, ; //X7_REGRA
	'TKS_DESCJN'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'ST9'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('ST9')+M->TKS_BEM"												, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'TKS_BEM'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'ST9->T9_CODFAMI'														, ; //X7_REGRA
	'TKS_FAMCJN'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'ST9'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('ST9')+M->TKS_BEM"												, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'TKS_BEM'																, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'SUBSTR(ST6->T6_NOME,1,20)'												, ; //X7_REGRA
	'TKS_NFACJN'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'ST6'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('ST6')+M->TKS_FAMCJN"											, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'TKS_BEM'																, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'ST9->T9_FORNECE'														, ; //X7_REGRA
	'TKS_FORNEC'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'ST9'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('ST9')+M->TKS_BEM"												, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'TKS_BEM'																, ; //X7_CAMPO
	'005'																	, ; //X7_SEQUENC
	'SA2->A2_LOJA'															, ; //X7_REGRA
	'TKS_LOJA'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA2'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('SA2')+M->TKS_FORNEC"											, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'TKS_BEM'																, ; //X7_CAMPO
	'006'																	, ; //X7_SEQUENC
	'SA2->A2_NOME'															, ; //X7_REGRA
	'TKS_NOMFOR'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA2'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('SA2')+M->TKS_FORNEC"											, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'TKS_BEM'																, ; //X7_CAMPO
	'007'																	, ; //X7_SEQUENC
	'ST9->T9_CCUSTO'														, ; //X7_REGRA
	'TKS_CCCJN'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'ST9'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('ST9')+M->TKS_BEM"												, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'TKS_BEM'																, ; //X7_CAMPO
	'008'																	, ; //X7_SEQUENC
	'CTT->CTT_DESC01'														, ; //X7_REGRA
	'TKS_NCCCJN'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'CTT'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('CTT')+M->TKS_CCCJN"											, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'TKS_BEM'																, ; //X7_CAMPO
	'009'																	, ; //X7_SEQUENC
	'ST9->T9_CALENDA'														, ; //X7_REGRA
	'TKS_TURCJN'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'ST9'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('ST9')+M->TKS_BEM"												, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'TKS_BEM'																, ; //X7_CAMPO
	'010'																	, ; //X7_SEQUENC
	'SH7->H7_DESCRI'														, ; //X7_REGRA
	'TKS_NTUCJN'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SH7'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('SH7')+M->TKS_TURCJN"											, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'TKS_BEM'																, ; //X7_CAMPO
	'011'																	, ; //X7_SEQUENC
	'ST9->T9_DTCOMPR'														, ; //X7_REGRA
	'TKS_DTCOMP'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'ST9'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('ST9')+M->TKS_BEM"												, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'TKS_BEM'																, ; //X7_CAMPO
	'012'																	, ; //X7_SEQUENC
	'ST9->T9_ANOFAB'														, ; //X7_REGRA
	'TKS_ANOFAB'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'ST9'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('ST9')+M->TKS_BEM"												, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'TKS_BEM'																, ; //X7_CAMPO
	'013'																	, ; //X7_SEQUENC
	'ST9->T9_FABRICA'														, ; //X7_REGRA
	'TKS_FABRIC'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'ST9'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('ST9')+M->TKS_BEM"												, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'TKS_BEM'																, ; //X7_CAMPO
	'014'																	, ; //X7_SEQUENC
	'ST7->T7_NOME'															, ; //X7_REGRA
	'TKS_NOMFAB'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'ST7'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('ST7')+M->TKS_FABRIC"											, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'TKS_BEM'																, ; //X7_CAMPO
	'015'																	, ; //X7_SEQUENC
	'ST9->T9_MODELO'														, ; //X7_REGRA
	'TKS_MODELO'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'ST9'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('ST9')+M->TKS_BEM"												, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo TKS_CCCJN
//
aAdd( aSX7, { ;
	'TKS_CCCJN'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'CTT->CTT_DESC01'														, ; //X7_REGRA
	'TKS_NCCCJN'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'CTT'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('CTT')+M->TKS_CCCJN"											, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo TKS_FABRIC
//
aAdd( aSX7, { ;
	'TKS_FABRIC'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'ST7->T7_NOME'															, ; //X7_REGRA
	'TKS_NOMFAB'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'ST7'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('ST7')+M->TKS_FABRIC"											, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo TKS_FAMCJN
//
aAdd( aSX7, { ;
	'TKS_FAMCJN'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'ST6->T6_NOME'															, ; //X7_REGRA
	'TKS_NFACJN'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'ST6'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('ST6')+M->TKS_FAMCJN"											, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo TKS_FORNEC
//
aAdd( aSX7, { ;
	'TKS_FORNEC'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'SA2->A2_LOJA'															, ; //X7_REGRA
	'TKS_LOJA'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA2'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('SA2')+M->TKS_FORNEC"											, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'TKS_FORNEC'															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'SA2->A2_NOME'															, ; //X7_REGRA
	'TKS_NOMFOR'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SA2'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('SA2')+M->TKS_FORNEC"											, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo TKS_TURCJN
//
aAdd( aSX7, { ;
	'TKS_TURCJN'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'SH7->H7_DESCRI'														, ; //X7_REGRA
	'TKS_NTUCJN'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SH7'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFilial('SH7')+M->TKS_TURCJN"											, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo TLA_ATIFIX
//
aAdd( aSX7, { ;
	'TLA_ATIFIX'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'SN3->N3_CUSTBEM'														, ; //X7_REGRA
	'TLA_CC'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SN3'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFILIAL('SN3')+M->TLA_ATIFIX"											, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'TLA_ATIFIX'															, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'CTT->CTT_DESC01'														, ; //X7_REGRA
	'TLA_NOMECC'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'CTT'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	"xFILIAL('CTT')+M->TLA_CC"												, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo TLA_CC
//
aAdd( aSX7, { ;
	'TLA_CC'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'CTT->CTT_DESC01'														, ; //X7_REGRA
	'TLA_NOMECC'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'CTT'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("CTT")+M->TLA_CC'												, ; //X7_CHAVE
	'S'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo TLA_DTRECA
//
aAdd( aSX7, { ;
	'TLA_DTRECA'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'M->TLA_DTRECA+365'														, ; //X7_REGRA
	'TLA_XVALID'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX7 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )

dbSelectArea( "SX7" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX7 )

	If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )

		If !( aSX7[nI][1] $ cAlias )
			cAlias += aSX7[nI][1] + "/"
			AutoGrLog( "Foi incluído o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] )
		EndIf

		RecLock( "SX7", .T. )
	Else

		If !( aSX7[nI][1] $ cAlias )
			cAlias += aSX7[nI][1] + "/"
			AutoGrLog( "Foi alterado o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] )
		EndIf

		RecLock( "SX7", .F. )
	EndIf

	For nJ := 1 To Len( aSX7[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
		EndIf
	Next nJ

	dbCommit()
	MsUnLock()

	If SX3->( dbSeek( SX7->X7_CAMPO ) )
		RecLock( "SX3", .F. )
		SX3->X3_TRIGGER := "S"
		MsUnLock()
	EndIf

	oProcess:IncRegua2( "Atualizando Arquivos (SX7)..." )

Next nI

RestArea( aAreaSX3 )

AutoGrLog( CRLF + "Final da Atualização" + " SX7" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXA
Função de processamento da gravação do SXA - Pastas

@author TOTVS Protheus
@since  08/10/2020
@obs    Gerado por EXPORDIC - V.6.5.0.3 EFS / Upd. V.5.1.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXA()
Local aEstrut   := {}
Local aSXA      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nPosAgr   := 0
Local lAlterou  := .F.

AutoGrLog( "Ínicio da Atualização" + " SXA" + CRLF )

aEstrut := { "XA_ALIAS"  , "XA_ORDEM"  , "XA_DESCRIC", "XA_DESCSPA", "XA_DESCENG", "XA_AGRUP"  , "XA_TIPO"   , ;
             "XA_PROPRI" }


//
// Tabela TKS
//
aAdd( aSXA, { ;
	'TKS'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Conjunto Hidráulico'													, ; //XA_DESCRIC
	'Conjunto hidraulico'													, ; //XA_DESCSPA
	'Hydraulic Set'															, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'S'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'TKS'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Características'														, ; //XA_DESCRIC
	'Caracteristicas'														, ; //XA_DESCSPA
	'Characteristics'														, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'S'																		} ) //XA_PROPRI

nPosAgr := aScan( aEstrut, { |x| AllTrim( x ) == "XA_AGRUP" } )

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXA ) )

dbSelectArea( "SXA" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXA )

	If SXA->( dbSeek( aSXA[nI][1] + aSXA[nI][2] ) )

		lAlterou := .F.

		While !SXA->( EOF() ).AND.  SXA->( XA_ALIAS + XA_ORDEM ) == aSXA[nI][1] + aSXA[nI][2]

			If SXA->XA_AGRUP == aSXA[nI][nPosAgr]
				RecLock( "SXA", .F. )
				For nJ := 1 To Len( aSXA[nI] )
					If FieldPos( aEstrut[nJ] ) > 0 .AND. Alltrim(AllToChar(SXA->( FieldGet( nJ ) ))) <> Alltrim(AllToChar(aSXA[nI][nJ]))
						FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
						lAlterou := .T.
					EndIf
				Next nJ
				dbCommit()
				MsUnLock()
			EndIf

			SXA->( dbSkip() )

		End

		If lAlterou
			AutoGrLog( "Foi alterada a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2] + "  " + aSXA[nI][3] )
		EndIf

	Else

		RecLock( "SXA", .T. )
		For nJ := 1 To Len( aSXA[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

		AutoGrLog( "Foi incluída a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2] + "  " + aSXA[nI][3] )

	EndIf

oProcess:IncRegua2( "Atualizando Arquivos (SXA)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SXA" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXB
Função de processamento da gravação do SXB - Consultas Padrao

@author TOTVS Protheus
@since  08/10/2020
@obs    Gerado por EXPORDIC - V.6.5.0.3 EFS / Upd. V.5.1.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXB()
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SXB" + CRLF )

aEstrut := { "XB_ALIAS"  , "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , "XB_DESCRI" , "XB_DESCSPA", "XB_DESCENG", ;
             "XB_WCONTEM", "XB_CONTEM" }


//
// Consulta CTT
//
aAdd( aSXB, { ;
	'CTT'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Centro Custo'															, ; //XB_DESCRI
	'Centro Costo'															, ; //XB_DESCSPA
	'Cost Center'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTT'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CTT'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CTT'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CTT'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Cod. Reduzido'															, ; //XB_DESCRI
	'Cod. Reducido'															, ; //XB_DESCSPA
	'Reduced Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CTT'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'#CtbA030Inc'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CTT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTT_CUSTO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CTT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTT_DESC01'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CTT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTT_DESC01'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CTT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTT_CUSTO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CTT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Reduzido'															, ; //XB_DESCRI
	'Cod. Reducido'															, ; //XB_DESCSPA
	'Reduced Code'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTT_RES'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CTT'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTT_DESC01'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CTT'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'CTT->CTT_CUSTO'														} ) //XB_CONTEM

//
// Consulta NG9
//
aAdd( aSXB, { ;
	'NG9'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Ativos Imobilizados'													, ; //XB_DESCRI
	'Activos fijos'															, ; //XB_DESCSPA
	'Fixed Assets'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SN1'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'NG9'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código Base'															, ; //XB_DESCRI
	'Codigo base'															, ; //XB_DESCSPA
	'Base Code'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'NG9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código Base'															, ; //XB_DESCRI
	'Codigo base'															, ; //XB_DESCSPA
	'Base Code'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SN1->N1_CBASE'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'NG9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Item'																	, ; //XB_DESCRI
	'Item'																	, ; //XB_DESCSPA
	'Item'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SN1->N1_ITEM'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'NG9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SN1->N1_DESCRIC'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'NG9'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SN1->N1_CBASE+SN1->N1_ITEM'											} ) //XB_CONTEM

aAdd( aSXB, { ;
	'NG9'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'MNTA420ATF()'															} ) //XB_CONTEM

//
// Consulta SA2
//
aAdd( aSXB, { ;
	'SA2'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Fornecedor'															, ; //XB_DESCRI
	'Proveedor'																, ; //XB_DESCSPA
	'Supplier'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA2'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'RCPJ/RCPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA2'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01#A020SXB()#A020Visual("SA2")'										} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A2_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A2_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A2_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A2_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Store'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A2_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A2_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'RCPJ/RCPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'A2_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Substr(A2_NOME,1,30)'													} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA2'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA2->A2_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SA2'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SA2->A2_LOJA'															} ) //XB_CONTEM

//
// Consulta SH7
//
aAdd( aSXB, { ;
	'SH7'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Calendário'															, ; //XB_DESCRI
	'Calendario'															, ; //XB_DESCSPA
	'Calendar'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SH7'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SH7'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SH7'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01##MaViewSH7()'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SH7'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'H7_CODIGO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SH7'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'H7_DESCRI'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SH7'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SH7->H7_CODIGO'														} ) //XB_CONTEM

//
// Consulta ST6
//
aAdd( aSXB, { ;
	'ST6'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Familias'																, ; //XB_DESCRI
	'Familias'																, ; //XB_DESCSPA
	'Families'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ST6'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST6'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST6'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST6'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T6_CODFAMI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T6_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T6_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T6_CODFAMI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST6'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ST6->T6_CODFAMI'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST6'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"ST6->T6_TIPOFAM == '1'"												} ) //XB_CONTEM

//
// Consulta ST7
//
aAdd( aSXB, { ;
	'ST7'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Fabricantes'															, ; //XB_DESCRI
	'Fabricantes'															, ; //XB_DESCSPA
	'Manufacturers'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ST7'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST7'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST7'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST7'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra Nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST7'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T7_FABRICA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST7'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T7_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST7'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T7_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST7'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T7_FABRICA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST7'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ST7->T7_FABRICA'														} ) //XB_CONTEM

//
// Consulta ST9
//
aAdd( aSXB, { ;
	'ST9'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Bens'																	, ; //XB_DESCRI
	'Bienes'																, ; //XB_DESCSPA
	'Assets'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ST9'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST9'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST9'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST9'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Familia'																, ; //XB_DESCRI
	'Familia'																, ; //XB_DESCSPA
	'Family'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST9'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01#MNTA080CAD(,,3)#MNTA080CAD(,Recno(),2)'								} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T9_CODBEM'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T9_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Código'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T9_CODBEM'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T9_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Familia'																, ; //XB_DESCRI
	'Familia'																, ; //XB_DESCSPA
	'Family'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T9_CODFAMI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nombre'																, ; //XB_DESCSPA
	'Name'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T9_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST9'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Familia'																, ; //XB_DESCRI
	'Familia'																, ; //XB_DESCSPA
	'Family'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'T9_CODFAMI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST9'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'ST9->T9_CODBEM'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'ST9'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"ST9->T9_SITMAN == 'A' .And. ST9->T9_SITBEM == 'A'"						} ) //XB_CONTEM

//
// Consulta TKS
//
aAdd( aSXB, { ;
	'TKS'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Conj. Hidráulico'														, ; //XB_DESCRI
	'Conj. Hidraulico'														, ; //XB_DESCSPA
	'Hydraulic Set'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TKS'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TKS'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TKS'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TKS'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TKS_CODCJN'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TKS'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TKS_DESCJN'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TKS'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TKS->TKS_CODCJN'														} ) //XB_CONTEM

//
// Consulta TLA
//
aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Extintores'															, ; //XB_DESCRI
	'Extintores'															, ; //XB_DESCSPA
	'Extinguishers'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo Extintor'														, ; //XB_DESCRI
	'Codigo Extintor'														, ; //XB_DESCSPA
	'Extinguisher code'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Centro Custo'															, ; //XB_DESCRI
	'Centro Costo'															, ; //XB_DESCSPA
	'Cost center'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Tipo+codigo Extintor'													, ; //XB_DESCRI
	'Tipo+codigo Extintor'													, ; //XB_DESCSPA
	'Type+Extinguisher Tp'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'05'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Situacao+codigo Exti'													, ; //XB_DESCRI
	'Situacion+codigo Ext'													, ; //XB_DESCSPA
	'Status+Ext. code'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod Extintor'															, ; //XB_DESCRI
	'Codigo extintor'														, ; //XB_DESCSPA
	'Extinguisher code'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_CODEXT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Centro Custo'															, ; //XB_DESCRI
	'Centro Costo'															, ; //XB_DESCSPA
	'Cost center'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_CC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Localizacao'															, ; //XB_DESCRI
	'Localizacion'															, ; //XB_DESCSPA
	'Location'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_LOCAL'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Marca'																	, ; //XB_DESCRI
	'Marca'																	, ; //XB_DESCSPA
	'Brand'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_MARCA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Tipo'																	, ; //XB_DESCRI
	'Tipo'																	, ; //XB_DESCSPA
	'Type'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_TIPO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Capacidade'															, ; //XB_DESCRI
	'Capacidad'																, ; //XB_DESCSPA
	'Capacity'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_CAPACI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Und. Medida'															, ; //XB_DESCRI
	'Und. Medida'															, ; //XB_DESCSPA
	'Unit of measurement'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_UNIMED'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'09'																	, ; //XB_COLUNA
	'Situacao'																, ; //XB_DESCRI
	'Situacion'																, ; //XB_DESCSPA
	'Status'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_SITUAC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'10'																	, ; //XB_COLUNA
	'Dt Ult. Manu'															, ; //XB_DESCRI
	'Fcha Ult. Mant.'														, ; //XB_DESCSPA
	'Date of last maint.'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_DTMANU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'11'																	, ; //XB_COLUNA
	'Dt Ult Recar'															, ; //XB_DESCRI
	'Fcha Ult Recar'														, ; //XB_DESCSPA
	'Date of last reload.'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_DTRECA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod Extintor'															, ; //XB_DESCRI
	'Codigo extintor'														, ; //XB_DESCSPA
	'Extinguisher code'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_CODEXT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Centro Custo'															, ; //XB_DESCRI
	'Centro Costo'															, ; //XB_DESCSPA
	'Cost center'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_CC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Localizacao'															, ; //XB_DESCRI
	'Localizacion'															, ; //XB_DESCSPA
	'Location'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_LOCAL'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Marca'																	, ; //XB_DESCRI
	'Marca'																	, ; //XB_DESCSPA
	'Brand'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_MARCA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Tipo'																	, ; //XB_DESCRI
	'Tipo'																	, ; //XB_DESCSPA
	'Type'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_TIPO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Situacao'																, ; //XB_DESCRI
	'Situacion'																, ; //XB_DESCSPA
	'Status'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_SITUAC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Dt Ult. Manu'															, ; //XB_DESCRI
	'Fcha Ult. Mant.'														, ; //XB_DESCSPA
	'Date of last maint.'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_DTMANU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'09'																	, ; //XB_COLUNA
	'Dt Ult Recar'															, ; //XB_DESCRI
	'Fcha Ult Recar'														, ; //XB_DESCSPA
	'Date of last reload.'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_DTRECA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod Extintor'															, ; //XB_DESCRI
	'Codigo extintor'														, ; //XB_DESCSPA
	'Extinguisher code'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_CODEXT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Centro Custo'															, ; //XB_DESCRI
	'Centro Costo'															, ; //XB_DESCSPA
	'Cost center'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_CC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Localizacao'															, ; //XB_DESCRI
	'Localizacion'															, ; //XB_DESCSPA
	'Location'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_LOCAL'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Marca'																	, ; //XB_DESCRI
	'Marca'																	, ; //XB_DESCSPA
	'Brand'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_MARCA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Situacao'																, ; //XB_DESCRI
	'Situacion'																, ; //XB_DESCSPA
	'Status'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_SITUAC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Dt Ult. Manu'															, ; //XB_DESCRI
	'Fcha. Ult. Mant.'														, ; //XB_DESCSPA
	'Date of last maint.'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_DTMANU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Dt Ult Recar'															, ; //XB_DESCRI
	'Fcha Ult Recar'														, ; //XB_DESCSPA
	'Date of last reload.'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_DTRECA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Tipo'																	, ; //XB_DESCRI
	'Tipo'																	, ; //XB_DESCSPA
	'Type'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_TIPO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod Extintor'															, ; //XB_DESCRI
	'Codigo extintor'														, ; //XB_DESCSPA
	'Extinguisher code'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_CODEXT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Centro Custo'															, ; //XB_DESCRI
	'Centro Costo'															, ; //XB_DESCSPA
	'Cost center'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_CC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Situacao'																, ; //XB_DESCRI
	'Situacion'																, ; //XB_DESCSPA
	'Status'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_SITUAC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Dt Ult. Manu'															, ; //XB_DESCRI
	'Fecha ult. mant.'														, ; //XB_DESCSPA
	'Date of last maint.'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_DTMANU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Dt Ult Recar'															, ; //XB_DESCRI
	'Fcha Ult Recar'														, ; //XB_DESCSPA
	'Date of last reload.'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_DTRECA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'05'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Situacao'																, ; //XB_DESCRI
	'Situacion'																, ; //XB_DESCSPA
	'Status'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_SITUAC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'05'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cod Extintor'															, ; //XB_DESCRI
	'Cod. Extintor'															, ; //XB_DESCSPA
	'Extinguisher code'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_CODEXT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'05'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'05'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Centro Custo'															, ; //XB_DESCRI
	'Centro de costo'														, ; //XB_DESCSPA
	'Cost center'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_CC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'05'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Localizacao'															, ; //XB_DESCRI
	'Localizacion'															, ; //XB_DESCSPA
	'Location'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_LOCAL'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'05'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Dt Ult. Manu'															, ; //XB_DESCRI
	'Fcha Ult. Mant.'														, ; //XB_DESCSPA
	'Date of last maint.'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_DTMANU'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'05'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Dt Ult Recar'															, ; //XB_DESCRI
	'Fcha Ult Recar'														, ; //XB_DESCSPA
	'Date of last reload.'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA_DTRECA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'TLA'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'TLA->TLA_CODEXT'														} ) //XB_CONTEM

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

					RecLock( "SXB", .F. )
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
					dbCommit()
					MsUnLock()

					If !( aSXB[nI][1] $ cAlias )
						cAlias += aSXB[nI][1] + "/"
						AutoGrLog( "Foi alterada a consulta padrão " + aSXB[nI][1] )
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
/*/{Protheus.doc} FSAtuHlp
Função de processamento da gravação dos Helps de Campos

@author TOTVS Protheus
@since  08/10/2020
@obs    Gerado por EXPORDIC - V.6.5.0.3 EFS / Upd. V.5.1.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuHlp()
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

AutoGrLog( "Ínicio da Atualização" + " " + "Helps de Campos" + CRLF )


oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

//
// Helps Tabela TKS
//
aHlpPor := {}
aAdd( aHlpPor, 'Informe a Filial do Conjunto Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the branch of the hydraulic set.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe la Sucursal del Conjunto' )
aAdd( aHlpSpa, 'Hidraulico.' )

PutSX1Help( "PTKS_FILIAL", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_FILIAL" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o Código do Conjunto Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the code of the hydraulic set.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe el Codigo del Conjunto' )
aAdd( aHlpSpa, 'Hidraulico.' )

PutSX1Help( "PTKS_CODCJN", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_CODCJN" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o bem corespondente ao conjunto' )
aAdd( aHlpPor, 'hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter hydraulic set item.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe el bien correspondiente al' )
aAdd( aHlpSpa, 'conjunto hidráulico.' )

PutSX1Help( "PTKS_BEM   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_BEM" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe a Descrição do Conjunto' )
aAdd( aHlpPor, 'Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the description of the hydraulic' )
aAdd( aHlpEng, 'set.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe la Descrpcion del Conjunto' )
aAdd( aHlpSpa, 'Hidraulico.' )

PutSX1Help( "PTKS_DESCJN", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_DESCJN" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe a Família do Conjunto' )
aAdd( aHlpPor, 'Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the family of the hydraulic set.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe la Familia del Conjunto' )
aAdd( aHlpSpa, 'Hidraulico.' )

PutSX1Help( "PTKS_FAMCJN", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_FAMCJN" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o nome da família de conjunto' )
aAdd( aHlpPor, 'hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the family name of hydraulic set.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe el Nombre de la Familia del' )
aAdd( aHlpSpa, 'Conjunto Hidraulico.' )

PutSX1Help( "PTKS_NFACJN", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_NFACJN" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o Centro de Custo do Conjunto' )
aAdd( aHlpPor, 'Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the cost center of the hydraulic' )
aAdd( aHlpEng, 'set family.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe el Centro de Costo del Conjunto' )
aAdd( aHlpSpa, 'Hidraulico.' )

PutSX1Help( "PTKS_CCCJN ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_CCCJN" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe a Descrição do Centro de Custo' )
aAdd( aHlpPor, 'do Conjunto Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the description of the cost center' )
aAdd( aHlpEng, 'of hydraulic set.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe la Descripcion del Centro de' )
aAdd( aHlpSpa, 'Costo del Conjunto Hidraulico.' )

PutSX1Help( "PTKS_NCCCJN", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_NCCCJN" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe a Localização do Conjunto' )
aAdd( aHlpPor, 'Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the location of the hydraulic set.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe la Ubicacion del Conjunto' )
aAdd( aHlpSpa, 'Hidraulico.' )

PutSX1Help( "PTKS_LOCCJN", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_LOCCJN" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o Turno do Conjunto Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the turn of the hydraulic set.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe el Turno del Conjunto' )
aAdd( aHlpSpa, 'Hidraulico.' )

PutSX1Help( "PTKS_TURCJN", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_TURCJN" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o Nome do Turno do Conjunto' )
aAdd( aHlpPor, 'Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the name of the hydraulic set' )
aAdd( aHlpEng, 'turn.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe el Nombre del Turno del Conjunto' )
aAdd( aHlpSpa, 'Hidráulico.' )

PutSX1Help( "PTKS_NTUCJN", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_NTUCJN" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe a Marca do Conjunto Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the brand of the hydraulic set.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe la Marca del Conjunto' )
aAdd( aHlpSpa, 'Hidraulico.' )

PutSX1Help( "PTKS_MARCA ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_MARCA" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o Modelo do Conjunto Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the model of the hydraulic set.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe el Modelo del Conjunto' )
aAdd( aHlpSpa, 'Hidraulico.' )

PutSX1Help( "PTKS_MODELO", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_MODELO" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe a Capacidade do Conjunto' )
aAdd( aHlpPor, 'Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the capacity of the hydraulic set.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe la Capacidad del Conjunto' )
aAdd( aHlpSpa, 'Hidraulico.' )

PutSX1Help( "PTKS_CAPACI", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_CAPACI" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe a Unidade de Medida da' )
aAdd( aHlpPor, 'Capacidade do Conjunto Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the capacity measurement unit of' )
aAdd( aHlpEng, 'the hydraulic set.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe la Unidad de Medida de la' )
aAdd( aHlpSpa, 'Capacidad del Conjunto Hidraulico.' )

PutSX1Help( "PTKS_UNIMED", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_UNIMED" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe a Situação do Conjunto' )
aAdd( aHlpPor, 'Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the status of the hydraulic set.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe la Situacion del Conjunto' )
aAdd( aHlpSpa, 'Hidraulico.' )

PutSX1Help( "PTKS_SITUAC", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_SITUAC" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe a Data de Manutenção do Conjunto' )
aAdd( aHlpPor, 'Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the maintenance date of the' )
aAdd( aHlpEng, 'hydraulic set.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe la Fecha de Mantenimiento del' )
aAdd( aHlpSpa, 'Conjunto Hidraulico.' )

PutSX1Help( "PTKS_DTMANU", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_DTMANU" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o Ano de Fabricação do Conjunto' )
aAdd( aHlpPor, 'Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the manufacturing year of the' )
aAdd( aHlpEng, 'hydraulic set.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe el Ano de Fabricacion del' )
aAdd( aHlpSpa, 'Conjunto Hidráulico.' )

PutSX1Help( "PTKS_ANOFAB", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_ANOFAB" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe a Data de Compra do Conjunto' )
aAdd( aHlpPor, 'Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the purchase date of the hydraulic' )
aAdd( aHlpEng, 'set.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe la Fecha de compra del Conjunto' )
aAdd( aHlpSpa, 'Hidraulico.' )

PutSX1Help( "PTKS_DTCOMP", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_DTCOMP" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o Fabricante do Conjunto' )
aAdd( aHlpPor, 'Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter hydraulic set manufacturer.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe el Fabricante del Conjunto' )
aAdd( aHlpSpa, 'Hidraulico.' )

PutSX1Help( "PTKS_FABRIC", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_FABRIC" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o Nome do Fabricante do Conjunto' )
aAdd( aHlpPor, 'Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the name of hydraulic set' )
aAdd( aHlpEng, 'manufacturer.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe el Nombre del Fabricante del' )
aAdd( aHlpSpa, 'Conjunto Hidraulico.' )

PutSX1Help( "PTKS_NOMFAB", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_NOMFAB" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o Fornecedor do Conjunto' )
aAdd( aHlpPor, 'Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter hydraulic set supplier.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe el Proveedor del Conjunto' )
aAdd( aHlpSpa, 'Hidraulico.' )

PutSX1Help( "PTKS_FORNEC", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_FORNEC" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe a Loja do Fornecedor do Conjunto' )
aAdd( aHlpPor, 'Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the store of hydraulic set' )
aAdd( aHlpEng, 'supplier.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe la Tienda del Proveedor del' )
aAdd( aHlpSpa, 'Conjunto Hidraulico.' )

PutSX1Help( "PTKS_LOJA  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_LOJA" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o Nome do Fornecedor do Conjunto' )
aAdd( aHlpPor, 'Hidráulico.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the name of hydraulic set' )
aAdd( aHlpEng, 'supplier.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe el Nombre del Proveedor del' )
aAdd( aHlpSpa, 'Conjunto Hidraulico.' )

PutSX1Help( "PTKS_NOMFOR", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_NOMFOR" )

aHlpPor := {}
aAdd( aHlpPor, 'Comprimento' )
aHlpEng := {}
aHlpSpa := {}

PutSX1Help( "PTKS_XCOMPR", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_XCOMPR" )

aHlpPor := {}
aAdd( aHlpPor, 'Pressao Ensaio (Kgf/cm)' )
aHlpEng := {}
aHlpSpa := {}

PutSX1Help( "PTKS_XPRESS", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_XPRESS" )

aHlpPor := {}
aAdd( aHlpPor, 'Lacre' )
aHlpEng := {}
aHlpSpa := {}

PutSX1Help( "PTKS_XLACRE", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_XLACRE" )

aHlpPor := {}
aAdd( aHlpPor, 'Observacao' )
aHlpEng := {}
aHlpSpa := {}

PutSX1Help( "PTKS_XOBSET", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TKS_XOBSET" )

//
// Helps Tabela TLA
//
aHlpPor := {}
aAdd( aHlpPor, 'Código da filial da empresa.' )
aHlpEng := {}
aAdd( aHlpEng, "Code of the company's branch." )
aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo de la sucursal de la empresa.' )

PutSX1Help( "PTLA_FILIAL", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_FILIAL" )

aHlpPor := {}
aAdd( aHlpPor, 'Código do extintor.' )
aHlpEng := {}
aAdd( aHlpEng, 'Extinguisher code.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo del extintor.' )

PutSX1Help( "PTLA_CODEXT", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_CODEXT" )

aHlpPor := {}
aAdd( aHlpPor, 'Descrição do extintor.' )
aHlpEng := {}
aAdd( aHlpEng, 'Extinguisher description.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Descripcion del extintor.' )

PutSX1Help( "PTLA_DESCRI", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_DESCRI" )

aHlpPor := {}
aAdd( aHlpPor, 'Centro de custo o qual pertence o' )
aAdd( aHlpPor, 'extintor.' )
aHlpEng := {}
aAdd( aHlpEng, 'Extinguisher cost center.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Centro de costo al cual pertenece el' )
aAdd( aHlpSpa, 'extintor.' )

PutSX1Help( "PTLA_CC    ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_CC" )

aHlpPor := {}
aAdd( aHlpPor, 'Nome do centro de custo do extintor.' )
aHlpEng := {}
aAdd( aHlpEng, 'Name of extinguisher cost center.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Nombre del centro de costo del extintor.' )

PutSX1Help( "PTLA_NOMECC", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_NOMECC" )

aHlpPor := {}
aAdd( aHlpPor, 'Local exato onde o extintor está' )
aAdd( aHlpPor, 'presente.' )
aHlpEng := {}
aAdd( aHlpEng, 'Place where the fire extinguiser is' )
aAdd( aHlpEng, 'located.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Lugar exacto donde se encuentra el' )
aAdd( aHlpSpa, 'extintor.' )

PutSX1Help( "PTLA_LOCAL ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_LOCAL" )

aHlpPor := {}
aAdd( aHlpPor, 'Nome do fabricante do extintor.' )
aHlpEng := {}
aAdd( aHlpEng, 'Name of the company that manufactured' )
aAdd( aHlpEng, 'the fire extinguisher.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Nombre del fabricante del extintor.' )

PutSX1Help( "PTLA_MARCA ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_MARCA" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo do agente extintor. Pode ser água,' )
aAdd( aHlpPor, 'agente halogenado, halon (hidrocarboneto' )
aAdd( aHlpPor, 'halogenado), dióxido de carbono, gás' )
aAdd( aHlpPor, 'inerte, pó químico ou espuma.' )
aHlpEng := {}
aAdd( aHlpEng, 'Type of extinguisher agent.  It can be' )
aAdd( aHlpEng, 'water, halogenated agent, halon' )
aAdd( aHlpEng, '(halogenated hydrocarbon), carbon' )
aAdd( aHlpEng, 'dioxide, inert gas, chemical powder or' )
aAdd( aHlpEng, 'foam.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo de agente extintor. Puede ser agua,' )
aAdd( aHlpSpa, 'agente halogenado, halon (hidrocarburo' )
aAdd( aHlpSpa, 'halogenado), dioxido de carbono, gas' )
aAdd( aHlpSpa, 'inerte, polvo quimico o espuma.' )

PutSX1Help( "PTLA_TIPO  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_TIPO" )

aHlpPor := {}
aAdd( aHlpPor, 'Medida do poder de extinção do fogo,' )
aAdd( aHlpPor, 'obtida em ensaio prático normalizado.' )
aHlpEng := {}
aAdd( aHlpEng, 'Power measurement of power extinction,' )
aAdd( aHlpEng, 'obtained from fire drill.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Medida del poder de extincion del fuego' )
aAdd( aHlpSpa, 'obtenido en ensayo practico normalizado.' )

PutSX1Help( "PTLA_CAPACI", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_CAPACI" )

aHlpPor := {}
aAdd( aHlpPor, 'Unidade de medida da capacidade do' )
aAdd( aHlpPor, 'extintor.' )
aHlpEng := {}
aAdd( aHlpEng, 'Unit of measurement for the fire' )
aAdd( aHlpEng, 'extinguisher capacity.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Unidad de medida de la capacidad del' )
aAdd( aHlpSpa, 'extintor.' )

PutSX1Help( "PTLA_UNIMED", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_UNIMED" )

aHlpPor := {}
aAdd( aHlpPor, 'Situação do extintor (ativa ou inativa).' )
aAdd( aHlpPor, 'Indica se o extintor está sendo' )
aAdd( aHlpPor, 'utilizado ou não, respectivamente.' )
aHlpEng := {}
aAdd( aHlpEng, 'Extinguisher status (active or' )
aAdd( aHlpEng, 'inactive). Indicates if the extinguisher' )
aAdd( aHlpEng, 'is being used or not, respectively.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Situacion del extintor (activa o' )
aAdd( aHlpSpa, 'inactiva). Indica se el extintor esta en' )
aAdd( aHlpSpa, 'uso o no, respectivamente.' )

PutSX1Help( "PTLA_SITUAC", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_SITUAC" )

aHlpPor := {}
aAdd( aHlpPor, 'Capacidade Extintora' )
aHlpEng := {}
aHlpSpa := {}

PutSX1Help( "PTLA_XCAPEX", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_XCAPEX" )

aHlpPor := {}
aAdd( aHlpPor, 'Qual o tipo de suporte utilizado para' )
aAdd( aHlpPor, 'guardar o extintor? (pendurado na' )
aAdd( aHlpPor, 'parede, tripe, suporte vertical ou' )
aAdd( aHlpPor, 'horizontal, etc.)' )
aHlpEng := {}
aHlpSpa := {}

PutSX1Help( "PTLA_XSUPOR", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_XSUPOR" )

aHlpPor := {}
aAdd( aHlpPor, 'Data de manutenção 3 nivel' )
aHlpEng := {}
aHlpSpa := {}

PutSX1Help( "PTLA_XMANU3", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_XMANU3" )

aHlpPor := {}
aAdd( aHlpPor, 'Data de manutenção 2º nivel' )
aHlpEng := {}
aHlpSpa := {}

PutSX1Help( "PTLA_XMANU2", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_XMANU2" )

aHlpPor := {}
aAdd( aHlpPor, 'Data da última manutenção realizada no' )
aAdd( aHlpPor, 'extintor.' )
aHlpEng := {}
aAdd( aHlpEng, 'Date of the last maintenance performed' )
aAdd( aHlpEng, 'in the extinguisher.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Fecha del ultimo mantenimiento realizado' )
aAdd( aHlpSpa, 'en el extintor.' )

PutSX1Help( "PTLA_DTMANU", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_DTMANU" )

aHlpPor := {}
aAdd( aHlpPor, 'Data da última recarga realizada no' )
aAdd( aHlpPor, 'extintor.' )
aHlpEng := {}
aAdd( aHlpEng, 'Date of the last fire extinguisher' )
aAdd( aHlpEng, 'recharge.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Fecha de la ultima recarga realizada en' )
aAdd( aHlpSpa, 'el extintor.' )

PutSX1Help( "PTLA_DTRECA", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_DTRECA" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe a data de validade do extintor.' )
aHlpEng := {}
aHlpSpa := {}

PutSX1Help( "PTLA_XVALID", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_XVALID" )

aHlpPor := {}
aAdd( aHlpPor, 'Número de Fabricação do Extintor.' )
aHlpEng := {}
aAdd( aHlpEng, 'Manufacturing No. of Extinguisher.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Numero de Fabricacion del Extintor.' )

PutSX1Help( "PTLA_NUMFAB", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_NUMFAB" )

aHlpPor := {}
aAdd( aHlpPor, 'Peso do Extintor Vazio.' )
aHlpEng := {}
aAdd( aHlpEng, 'Weight of empty extinguisher.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Peso del Extintor Vacio.' )

PutSX1Help( "PTLA_PESOVZ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_PESOVZ" )

aHlpPor := {}
aAdd( aHlpPor, 'Peso do Extintor Cheio.' )
aHlpEng := {}
aAdd( aHlpEng, 'Weight of full extinguisher.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Peso del Extintor Lleno.' )

PutSX1Help( "PTLA_PESOCH", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_PESOCH" )

aHlpPor := {}
aAdd( aHlpPor, 'Unidade de Medida do Peso do Extintor.' )
aHlpEng := {}
aAdd( aHlpEng, 'Unit of measurement of extinguisher' )
aAdd( aHlpEng, 'weight.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Unidad de Medida del Peso del Extintor.' )

PutSX1Help( "PTLA_PESOUN", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_PESOUN" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o código do ativo fixo' )
aAdd( aHlpPor, 'relacionando ao extintor.' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter the code of fixed asset related to' )
aAdd( aHlpEng, 'the extinguisher.' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe el codigo del activo fijo' )
aAdd( aHlpSpa, 'relacionando al extintor.' )

PutSX1Help( "PTLA_ATIFIX", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_ATIFIX" )

aHlpPor := {}
aAdd( aHlpPor, 'Informe o código da ABNT (Associação' )
aAdd( aHlpPor, 'Brasileira de Normas Técnicas).' )
aHlpEng := {}
aAdd( aHlpEng, 'Enter ABNT code (Brazilian Association' )
aAdd( aHlpEng, 'for Technical Norms).' )
aHlpSpa := {}
aAdd( aHlpSpa, 'Informe el codigo de ABNT (Asociacion' )
aAdd( aHlpSpa, 'Brasilena de Normas Tecnicas).' )

PutSX1Help( "PTLA_ABNT  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "TLA_ABNT" )

AutoGrLog( CRLF + "Final da Atualização" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF )

Return {}


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

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "UPDTCTLA" ) ) ) ;
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
@since  08/10/2020
@obs    Gerado por EXPORDIC - V.6.5.0.3 EFS / Upd. V.5.1.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)
Local lOpen := .F.
Local nLoop := 0

If FindFunction( "OpenSM0Excl" )
	For nLoop := 1 To 20
		If OpenSM0Excl(,.F.)
			lOpen := .T.
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
Else
	For nLoop := 1 To 20
		dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			dbSetIndex( "SIGAMAT.IND" )
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
EndIf

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  08/10/2020
@obs    Gerado por EXPORDIC - V.6.5.0.3 EFS / Upd. V.5.1.0 EFS
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
