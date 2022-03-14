#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWMVCDEF.CH"
#include 'fileio.ch'
#INCLUDE "OMSA200x.CH" 

#DEFINE CARGA_ENABLE    1
#DEFINE CARGA_COD       2
#DEFINE CARGA_DESC      3
#DEFINE CARGA_PESO      4
#DEFINE CARGA_VALOR     5
#DEFINE CARGA_VOLUM     6
#DEFINE CARGA_QTDLIB    7
#DEFINE CARGA_PTOENT    8
#DEFINE CARGA_TRANSP    9
#DEFINE CARGA_VEIC      10
#DEFINE CARGA_VEI2      11
#DEFINE CARGA_VEI3      12
#DEFINE CARGA_MOTOR     13
#DEFINE CARGA_AJUD1     14
#DEFINE CARGA_AJUD2     15
#DEFINE CARGA_AJUD3     16
#DEFINE CARGA_PESCIF    17
#DEFINE CARGA_QTDCIF    18
#DEFINE CARGA_VOLCIF    19
#DEFINE CARGA_VALCIF    20
#DEFINE CARGA_PESFOB    21
#DEFINE CARGA_QTDFOB    22
#DEFINE CARGA_VOLFOB    23
#DEFINE CARGA_VALFOB    24
#DEFINE CARGA_TPOP      25
#DEFINE CARGA_CLFR      26

#DEFINE FRETE_COD       1
#DEFINE FRETE_VAL       2
#DEFINE FRETE_INSS      3
#DEFINE FRETE_PEDAG     4
#DEFINE FRETE_ADIANT    5
#DEFINE FRETE_RATEIO    6
#DEFINE FRETE_FREAUT    7
#DEFINE FRETE_TABFRE    8
#DEFINE FRETE_TIPTAB    9

#DEFINE OMSA20001 "OMSA20001"
#DEFINE OMSA20002 "OMSA20002"
#DEFINE OMSA20003 "OMSA20003"
#DEFINE OMSA20004 "OMSA20004"
#DEFINE OMSA20005 "OMSA20005"

Static cVeiAnt   := ""
Static cTabAnt   := ""
Static nDelItem  := 0
Static l200Auto  := .F.
Static cCargaID  := ""
Static lOM200QRY := ExistBlock("OM200QRY")
Static lOM200ORP := ExistBlock("OM200ORP")
Static __oTmpTab := Nil
Static __oTmpSC9 := Nil

Static __aTempos := {}

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ XOMSA200  ³ Rev.  ³ DL                   ³ Data ³ 19.01.2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Geracao de carga                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void XOMSA200(void)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CONTABILISTA                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±           
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function OMSA200x(xAutoCab, xAutoItens,nOpc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa vari veis utilizadas na criacao de Arquivos de Trabalho     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea     := GetArea()
Local aCores    := {}
Local aIndDAK   := {}
Local aRetPE    := {}
Local cCondicao := ""
Local cRetPE    := ""
Local aCoresPE  := {}
Local aSetKey   := {}
Local nI        := 0

Private bFiltraBrw := {|| Nil}
Private cCadastro  := OemtoAnsi(STR0001) //"Montagem de Carga"
Private n          := 1
Private aArrayCli  := {}
Private nIndice    := 5
Private aRotAuto   := {}
Private aAutoItens := {}
Private xArrCarga  := {}
Private aVisErr    := {}

	nOpc := If (nOpc == Nil,3,nOpc)
	l200Auto   := ValType(xAutoCab) == "A" .And. ValType(xAutoItens) == "A"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Perguntas :                                                  ³
	//³                                                              ³
	//³ mv_par01  // Pedidos do Tipo (PalmTop / Manual / Ambos )     ³
	//³ mv_par02  // Do Vendedor                                     ³
	//³ mv_par03  // Ate o Vendedor                                  ³
	//³ mv_par04  // Da Emissao                                      ³
	//³ mv_par05  // Ate a Emissao                                   ³
	//³ mv_par06  // Do Pedido                                       ³
	//³ mv_par07  // Ate o Pedido                                    ³
	//³ mv_par08  // Do Cliente                                      ³
	//³ mv_par09  // Ate o Cliente                                   ³
	//³ mv_par10  // Trazer Tudo Marcado ?                           ³
	//³ mv_par11  // Do Pedido Palm-Top                              ³
	//³ mv_par12  // Ate Pedido Palm-Top                             ³
	//³ mv_par13  // Utiliza Restricoes                              ³
	//³ mv_par14  // Considera Todo Dia Quantio as Restricoes        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aRotina := xMenuDef()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para a criacao de botoes de usuario                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "OM200US" )
		aRetPE := ExecBlock( "OM200US", .F., .F.,aRotina)
		If ValType(aRetPE)=="A" .And. Len(aRetPE) > 0
			aRotina := aRetPE
		EndIf
	EndIf

	AAdd(aSetKey, { VK_F12 , { || Pergunte("OMS200C",.T.) } } )
	//-- Inicializa Teclas de Atalhos
	TmsKeyOn(aSetKey)

	If (AMIIn(5,39)) // SigaFat - SigaOms
		If ExistBlock("OM200CND")
			If ValType( aCoresPE := ExecBlock("OM200CND",.F.,.F.) ) == "A"
				For nI := 1 To Len(aCoresPE)
					AAdd(aCores,aCoresPE[nI])
				Next nI
			EndIf
		EndIf

		If (l200Auto)
			aRotAuto   := xAutoCab
			aAutoItens := aClone(xAutoItens)

			MBrowseAuto(nOpc,AClone(aRotAuto),"DAK")
		Else
			AAdd(aCores,{"DAK_FEZNF == '2' .And. DAK_ACECAR == '2'.And.(DAK_BLQCAR == '2' .Or. DAK_BLQCAR == ' ') .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","ENABLE"})      //Totalmente em aberto
			AAdd(aCores,{"DAK_FEZNF == '1' .And. DAK_ACECAR == '2'.And.(DAK_BLQCAR == '2' .Or. DAK_BLQCAR == ' ') .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","BR_LARANJA"})  //Somente faturada e nao acertada
			AAdd(aCores,{"DAK_FEZNF == '1' .And. DAK_ACECAR == '1'.And.(DAK_BLQCAR == '2' .Or. DAK_BLQCAR == ' ') .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","DISABLE"})     //Faturada e acertada
			AAdd(aCores,{"                                              DAK_BLQCAR == '1'                         .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","BR_PRETO"})    //Bloqueada

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inclui Filial de / ate nos parametros OM341B                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Pergunte("OMS20A",.T.)
				cCondicao += " DAK_FILIAL='"+xFilial("DAK")+"' And "
				cCondicao += " DAK_COD >= '"+mv_par01+"' And DAK_COD <= '"+mv_par02+"' And "
				cCondicao += " DAK_DATA >= '"+Dtos(mv_par03)+"' And DAK_DATA <= '"+Dtos(mv_par04)+"' "
				If mv_par05 == 1
					cCondicao += " And DAK_FEZNF = '2' And DAK_ACECAR = '2' "
				ElseIf mv_par05 == 2
					cCondicao += " And DAK_FEZNF = '1' And DAK_ACECAR = '2' "
				ElseIf mv_par05 == 3
					cCondicao += " And DAK_FEZNF = '1' And DAK_ACECAR = '1' "
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de Entrada para inserir filtro de usuario                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("OM200BRW")
					cRetPE := ExecBlock("OM200BRW",.F.,.F.)
					If ValTYpe(cRetPE)=="C"
						cCondicao += " And "+cRetPE
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Realiza a Filtragem                                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				Mbrowse(6,1,22,75,"DAK",,,,,,aCores,,,,,,,,cCondicao)

			EndIf
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Restaura a integridade da rotina                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("DAK")
		RetIndex("DAK")
		dbClearFilter()
		aEval(aIndDAK,{|x| Ferase(x[1]+OrdBagExt())})
		RestArea( aArea )
	EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³xOsA200Mont³ Autor ³Daniel Pereira        ³ Data ³29.01.2021  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de interface da Montagem de Carga                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do Arquivo                                       ³±±
±±³          ³ExpN2: Numero do Registro                                     ³±±
±±³          ³ExpN3: Opcao do aRotina                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function xOsA200Mont()
Local aSize       := MsAdvSize( .T. )
Local aPosObj1    := {}
Local aPosObj2    := {}
Local aPosObj3    := {}
Local aObjects    := {}
Local aArrayCarga := {}
Local aArrayRota  := {}
Local aArrayZona  := {}
Local aArraySetor := {}
Local aArrayMan   := {}
Local aLock       := {}
Local aArrayMod   := {}
Local aArrayTipo  := {}
Local aCampos     := {}
Local aCpoBrw     := {}
Local aRetPE      := {}
Local aButtonUsr  := {}
Local aButtons    := {  { "RPMNEW"  , { || (U_XOmsAbreCarga(@oEnable,@oDisable,@aArrayCarga,@aHeaderAdt,@aColsAdt,@cDakTransp,@aArrayRota,@aArrayZona,@aArraySetor)) }, OemtoAnsi(STR0008),OemtoAnsi(STR0166) },; //"Abre Carga"
						{ "CARGASEQ", { || U_XOs200VisCg(@aArrayCarga,@aArrayMan,@cHrStart,@dDtStart)}, OemtoAnsi(STR0009),OemtoAnsi(STR0167) },; //"Sequencia de Entrega"
						{ "CARGA"   , { || XOmsTransp(@aArrayMan,@aArrayCarga,@oEnable,@oDisable,@oMarked,@oNoMarked,@cHrStart,@dDtStart,@cGvCodOper, @cGvNoProc, @cGvPedComOp,@aHeaderAdt,@aColsAdt,"TRBPED",cMarca,cDakTransp )} , OemtoAnsi(STR0012),OemtoAnsi(STR0168) },; //"Associar Veiculo"
						{ "VENDEDOR", { || U_XOs200VisCF()                        }, OemtoAnsi(STR0010), OemtoAnsi(STR0030)},; //"Visualizar Dados do Cliente"
						{ "PEDIDO"  , { || XOs200VisPv()                        }, OemtoAnsi(STR0011), OemtoAnsi(STR0028)},; //"Visualizar Pedido"
						{ "PESQUISA", { || U_XOmsPesqPed("TRBPED",aCampos,aCpoBrw)}, OemtoAnsi(STR0117), OemtoAnsi(STR0169) },; //"Pesquisa de pedidos"
						{ "GRAF3D"  , { || U_XOmsVisGraph(@aArrayCarga,cMarca)    }, OemtoAnsi(STR0098), OemtoAnsi(STR0170)},; //"Graficos"
						{ "RELOAD"  , { || U_XOsA200Refr(aCampos,aArrayCarga,aArrayRota,aArrayZona,aArraySetor,aArrayMod,aArrayTipo,{oCargas,oRotas,oZonas,oSetores},aArrayMan,{oAllMark}, @cDakTransp,.T.)},"Refresh","Refresh"}}

Local lAllMark    := .F.
Local nTipoOper   := OsVlEntCom()
Local cCarga      := STR0285 //A DEFINIR
Local cMarca      := GetMark()
Local cAlocPer    := SuperGetMv("MV_ALOCPER",.F.,"N")
Local cHrStart    := SuperGetMv("MV_CGSTART",.F.,"08:00")
Local dDtStart    := dDatabase
Local oEnable     := LoadBitmap( GetResources() ,"ENABLE"  )
Local oDisable    := LoadBitmap( GetResources() ,"DISABLE" )
Local oNoMarked   := LoadBitmap( GetResources() ,"LBNO"    )
Local oMarked     := LoadBitmap( GetResources() ,"LBOK"    )
Local oDlg        := Nil
Local oProcess    := Nil
Local oAllMark    := Nil
Local nI          := 0
Local aHeadOrd    := {}
Local bBlockHead  := {||.T.}
Local cGvCodOper  := ""
Local cGvNoProc   := ""
Local cGvPedComOp := ""
Local aHeaderAdt  := {}
Local aColsAdt    := {}
Local aButtonBkp  := {}
Local cDakTransp  := Iif((l200Auto .And. !Empty(aRotAuto[15][2])), aRotAuto[15][2], Criavar("A4_COD",.F.))
Local cNTrans     := Criavar("A4_NREDUZ",.F.)
Local lDakTransp  := DAK->( ColumnPos( "DAK_TRANSP" ) ) > 0
Local lDakTpOp    := DAK->( ColumnPos( "DAK_CDTPOP" ) ) > 0 .AND. DAK->( ColumnPos( "DAK_CDCLFR" ) ) > 0 .And. SuperGetMv("MV_INTGFE",,.F.) == .T.
Local cDAKTpOp    := ""
Local cDAKClFr    := ""
Local cPictVal    := "99999999." + Replicate("9",TamSx3("DAK_VALOR")[2])
Local cPictVol    := "99999999." + Replicate("9",TamSx3("DAK_CAPVOL")[2])
Local cPictPeso   := "99999999." + Replicate("9",TamSx3("DAK_PESO")[2])
Local cPictQtde   := "99999999." + Replicate("9",TamSx3("C9_QTDLIB")[2])
Local lDaiRedesp  := DAI->( ColumnPos( "DAI_REDESP" ) ) > 0

Private lWmsPergEP := .T.

	If !l200Auto
		If lDakTransp
			Aadd(aButtons , { "TRANSP"   , { || Om200Trans(@aArrayMan,@cDakTransp,cNtrans,@aArrayCarga,oCargas)}, OemtoAnsi(STR0011),(STR0260)} ) //"Transp."
		EndIf

		If lDakTpOp
			cDAKTpOp := Criavar("DAK_CDTPOP",.F.)
			cDAKClFr := Criavar("DAK_CDCLFR",.F.)
			aAdd(aButtons , { "TP_OPER." , { || Om200TpOper(@aArrayMan, @cDAKTpOp, @cDAKClFr, @aArrayCarga, oCargas)} , OemtoAnsi("Tipo Oper/ Class. Frete"),OemtoAnsi("Tipo Oper/ Class. Frete") })
		EndIf
	EndIf

	aArrayCli := {}

	If Empty(cHrStart)
		cHrStart:="08:00"
	EndIf
	Pergunte("OMS200",.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controle de botoes                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !l200Auto .And. ExistBlock("OS200BUT")
		aButtonUsr := ExecBlock("OS200BUT",.F.,.F.)
		If ValType(aButtonUsr)=="A" .And. Len(aButtonUsr) > 0
			For nI := 1 To Len(aButtonUsr)
				AAdd(aButtons,aClone(aButtonUsr[nI]))
			Next nI
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PE - Deletar Elementos do aButtons                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !l200Auto .And. ExistBlock("OS200DEA")
		aButtonBkp := aClone(aButtons)
		aButtons := ExecBlock("OS200DEA",.F.,.F.,{aButtons})
		If ValType(aButtons) != "A" .Or. Len(aButtons) <= 0
			aButtons := aClone(aButtonBkp)
		EndIf
	EndIf

	DbSelectArea("DAK")
	DAK->(DbSetOrder(1))
	dbClearFilter()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Traz janelas de perguntas e filtro para a montagem                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If OmsFilTipo(@oMarked,@oNoMarked,aArrayMod,aArrayTipo,.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle de botoes                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !l200Auto .And. mv_par06 == 2
			AAdd(aButtons,{ "OMSDIVIDE",{ || Os200DivSC9("TRBPED",@aArrayMan,cMarca),oMark:oBrowse:Refresh()},STR0210,STR0209}) //"Divide item de pedido de venda liberado"###"Divide Item"
		EndIf

		// Cria tabela temporária utilizada na rotina
		Os200CriaTrb(aCampos)

		// Filtra pedidos e monta o mapa de cargas
		If IsBlind()
			lEnd := xOmsBuscaPed(cCarga,aArrayCarga,aArrayRota,aArrayZona,aArraySetor,aArrayMod,aArrayTipo,oProcess,cMarca)
		Else
			oProcess := MsNewProcess():New({ |lEnd| xOmsBuscaPed(cCarga,;
																aArrayCarga,;
																aArrayRota,;
																aArrayZona,;
																aArraySetor,;
																aArrayMod,;
																aArrayTipo,;
																oProcess,;
																cMarca)},"","",.F.)
			oProcess:Activate()
		Endif

		If !l200Auto
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se e por pedido ou item para alterar colunas na MsSelect      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aCpoBrw ,{"PED_MARCA"  , ,OemtoAnsi(" ")," "} )
			AAdd( aCpoBrw ,{"PED_ROTA"   , ,OemtoAnsi(STR0022)} ) //"Rota"
			AAdd( aCpoBrw ,{"PED_SEQROT" , ,OemtoAnsi(STR0027)} ) //"Entrega"
			AAdd( aCpoBrw ,{"PED_PEDIDO" , ,OemtoAnsi(STR0028)} ) //"Pedido"
			AAdd( aCpoBrw ,{"PED_ITEM"   , ,OemtoAnsi(STR0029)} ) //"Item"
			AAdd( aCpoBrw ,{"PED_SEQLIB" , ,OemtoAnsi(STR0116)} ) //"Seq. Liberacao"
			If  mv_par06 == 2 .or. MV_PAR06 == 3
				AAdd( aCpoBrw ,{"PED_CODPRO" , ,OemtoAnsi(STR0013)} )//"Codigo"
				AAdd( aCpoBrw ,{"PED_DESPRO" , ,OemtoAnsi(STR0131)} )//"Produto"
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inclui campo de filial origem caso o tipo de operacao use todas as filiais³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nTipoOper <> 1
				AAdd( aCpoBrw ,{"PED_FILORI" , ,DAI->(RetTitle("DAI_FILIAL"))} )
			EndIf
			AAdd( aCpoBrw ,{"PED_CODCLI" , ,OemtoAnsi(STR0030)} )//"Cliente"
			AAdd( aCpoBrw ,{"PED_LOJA"   , ,OemtoAnsi(STR0031)} )//"Loja"
			AAdd( aCpoBrw ,{"PED_NOME"   , ,OemtoAnsi(STR0032)} )//"Nome"
			AAdd( aCpoBrw ,{"PED_VALOR"  , ,OemtoAnsi(STR0016),"99999999."+Replicate("9",TamSx3("DAK_VALOR")[2])}  ) //"Valor"
			AAdd( aCpoBrw ,{"PED_VOLUM"  , ,OemtoAnsi(STR0034),"99999999."+Replicate("9",TamSx3("DAK_CAPVOL")[2])} ) //"Volume"
			AAdd( aCpoBrw ,{"PED_PESO"   , ,OemtoAnsi(STR0033),"99999999."+Replicate("9",TamSx3("DAK_PESO")[2])}   ) //"Qtde"
			AAdd( aCpoBrw ,{"PED_CARGA"  , ,OemtoAnsi(STR0014)} )//"Carga"
			AAdd( aCpoBrw ,{"PED_QTDLIB" , ,OemtoAnsi(STR0132)} )//"Quantidade"
			If lDaiRedesp
				AAdd( aCpoBrw ,{"PED_REDESP" , ,OemtoAnsi(STR0289)} )//"Redespachante"
				AAdd( aCpoBrw ,{"PED_REDNOM" , ,OemtoAnsi(STR0290)} )//"Nome Redespachante"
			EndIf
			AAdd( aCpoBrw ,{"PED_EST"    , ,SA1->(RetTitle("A1_EST"))} ) //"Estado"
			AAdd( aCpoBrw ,{"PED_MUN"    , ,SA1->(RetTitle("A1_MUN"))} ) //"Municipio"
			AAdd( aCpoBrw ,{"PED_BAIRRO" , ,SA1->(RetTitle("A1_BAIRRO"))} ) //"Bairro"
			AAdd( aCpoBrw ,{"PED_CEP"    , ,SA1->(RetTitle("A1_CEP"))} ) //"CEP"
			AAdd( aCpoBrw ,{"PED_ENDCLI" , ,SA1->(RetTitle("A1_END"))} ) //"Endereço"

			If ExistBlock("DL200BRW")
				aRetPE := ExecBlock("DL200BRW",.F.,.F.,aCpoBrw)
				If ValType(aRetPE)=="A"
					aCpoBrw := aRetPE
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se e por pedido ou item para alterar a ordem na MsSelect      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  mv_par06 == 2 .or. MV_PAR06 == 3
				If nTipoOper <> 1
					aHeadOrd := {{3,3},{5,1},{9,5},{11,7},{19,8},{20,8}}
				Else
					aHeadOrd := {{3,3},{5,1},{8,5},{10,7},{18,8},{19,8}}
				EndIf
			Else
				If nTipoOper <> 1
					aHeadOrd := {{3,3},{5,1},{9,7},{17,8},{18,8}}
				Else
					aHeadOrd := {{3,3},{5,1},{8,7},{16,8},{17,8}}
				EndIf
			EndIf
			If ExistBlock("OM200ORD")
				aHeadOrd := ExecBlock("OM200ORD",.F.,.F.,aHeadOrd)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Passo parametros para calculo da resolucao da tela                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aObjects := {}
			AAdd( aObjects ,{ 100 ,100 ,.T. ,.T. } )
			AAdd( aObjects ,{ 100 ,100 ,.T. ,.T. } )
			AAdd( aObjects ,{ 100 ,150 ,.T. ,.T. } )
			AAdd( aObjects ,{ 100 ,10  ,.T. ,.F. } )
			aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
			aPosObj1 := MsObjSize( aInfo, aObjects, .T. )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Resolve as dimensoes dos objetos da parte esquerda da tela                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aObjects := {}
			AAdd( aObjects ,{ 100 ,100 ,.T. ,.T. ,.T. } )
			AAdd( aObjects ,{ 100 ,100 ,.T. ,.T. ,.T. } )
			aSize2 := aClone( aPosObj1[1] )
			aInfo    := { aSize2[ 2 ], aSize2[ 1 ], aSize2[ 4 ], aSize2[ 3 ], 3, 3  }
			aPosObj2 := MsObjSize( aInfo, aObjects, ,.T. )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Resolve as dimensoes dos objetos da parte direita da tela                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aObjects := {}
			AAdd( aObjects ,{ 100 ,100 ,.T. ,.T. ,.T. } )
			AAdd( aObjects ,{ 100 ,100 ,.T. ,.T. ,.T. } )
			aSize3 := aClone( aPosObj1[2] )
			aInfo    := { aSize3[ 2 ], aSize3[ 1 ], aSize3[ 4 ], aSize3[ 3 ], 3, 3 }
			aPosObj3 := MsObjSize( aInfo, aObjects, ,.T. )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Montagem da Interface                                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DEFINE MSDIALOG oDlg FROM aSize[7], 000 TO aSize[6], aSize[5] TITLE OemtoAnsi(STR0001) PIXEL //"Montagem de Carga"

			@ aPosObj2[1,1]+2,aPosObj2[1,2] Say OemtoAnsi(STR0074) OF oDlg PIXEL //"Cargas"
			@ aPosObj2[2,1]+2,aPosObj2[2,2] Say OemtoAnsi(STR0075) OF oDlg PIXEL //"Rotas"
			@ aPosObj3[1,1]+2,aPosObj3[1,2] Say OemtoAnsi(STR0076) OF oDlg PIXEL //"Zonas"
			@ aPosObj3[2,1]+2,aPosObj3[2,2] Say OemtoAnsi(STR0077) OF oDlg PIXEL //"Setores"
			@ aPosObj1[3,1]+2,aPosObj1[3,2] Say OemtoAnsi(STR0078) OF oDlg PIXEL //"Pedidos"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Listbox de Cargas                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ aPosObj2[1,1]+10,aPosObj2[1,2] LISTBOX oCargas VAR cVar ;
				Fields HEADER " ",;
				OemToAnsi(STR0013),; //"Codigo"
				OemtoAnsi(STR0014),; //"Carga"
				OemtoAnsi(STR0015),; //"Peso"
				OemtoAnsi(STR0016),; //"Valor"
				OemtoAnsi(STR0017),; //"Volume"
				OemtoAnsi(STR0246),; //"Qtde.1a.UM"
				OemtoAnsi(STR0018),; //"Ptos. Entrega"
				OemtoAnsi(STR0259),;  //"Transportadora"
				OemtoAnsi(STR0019),; //"Veiculo"
				OemtoAnsi("Veiculo2"),; //"Veiculo2"
				OemtoAnsi("Veiculo3"),; //"Veiculo3"
				OemtoAnsi(STR0069),; //"Motorista"
				OemtoAnsi(STR0092),; //"Ajudante 1"
				OemtoAnsi(STR0093),; //"Ajudante 2"
				OemtoAnsi(STR0094); //"Ajudante 3"
				SIZE aPosObj2[1,3],aPosObj2[1,4]-10 ;
				ON DBLCLICK (OmsTroca(0,;
				dDtStart,;
				cHrStart,;
				@aArrayCarga,;
				@aArrayRota,;
				@aArrayZona,;
				@aArraySetor,;
				@aArrayMan,;
				@aLock,;
				@oEnable,;
				@oDisable,;
				@oMarked,;
				@oNoMarked,;
				cMarca,;
				lAllMark,;
				,;
				aHeaderAdt,;
				aColsAdt,;
				cDakTransp)) OF oDlg PIXEL

			oCargas:nFreeze := 1
			oCargas:SetArray(aArrayCarga)
			oCargas:bLine:={ ||{Iif(aArrayCarga[oCargas:nAT,CARGA_ENABLE],oEnable,oDisable),;
			aArrayCarga[oCargas:nAT,CARGA_COD],;
			aArrayCarga[oCargas:nAT,CARGA_DESC],;
			Transform(aArrayCarga[oCargas:nAT,CARGA_PESO  ],cPictPeso),;
			Transform(aArrayCarga[oCargas:nAT,CARGA_VALOR ],cPictVal ),;
			Transform(aArrayCarga[oCargas:nAT,CARGA_VOLUM ],cPictVol ),;
			Transform(aArrayCarga[oCargas:nAT,CARGA_QTDLIB],cPictVol ),;
			aArrayCarga[oCargas:nAT,CARGA_PTOENT],;
			aArrayCarga[oCargas:nAT,CARGA_TRANSP],;
			aArrayCarga[oCargas:nAT,CARGA_VEIC],;
			aArrayCarga[oCargas:nAT,CARGA_VEI2],;
			aArrayCarga[oCargas:nAT,CARGA_VEI3],;
			aArrayCarga[oCargas:nAT,CARGA_MOTOR],;
			aArrayCarga[oCargas:nAT,CARGA_AJUD1],;
			aArrayCarga[oCargas:nAT,CARGA_AJUD2],;
			aArrayCarga[oCargas:nAT,CARGA_AJUD3],;
			Transform(aArrayCarga[oCargas:nAT,CARGA_PESCIF],cPictPeso),;
			Transform(aArrayCarga[oCargas:nAT,CARGA_QTDCIF],cPictVal ),;
			Transform(aArrayCarga[oCargas:nAT,CARGA_VOLCIF],cPictVol ),;
			Transform(aArrayCarga[oCargas:nAT,CARGA_VALCIF],cPictQtde),;
			Transform(aArrayCarga[oCargas:nAT,CARGA_PESFOB],cPictPeso),;
			Transform(aArrayCarga[oCargas:nAT,CARGA_QTDFOB],cPictVal ),;
			Transform(aArrayCarga[oCargas:nAT,CARGA_VOLFOB],cPictVol ),;
			Transform(aArrayCarga[oCargas:nAT,CARGA_VALFOB],cPictQtde),;
			aArrayCarga[oCargas:nAT,CARGA_TPOP],;
			aArrayCarga[oCargas:nAT,CARGA_CLFR]}}

			//-- Ponto de entrada para adicionar campos na opcao Sequencia de Entrega.
			If  ExistBlock("OM200AD2")
				aRetCarga := ExecBlock("OM200AD2",.F.,.F.,{oCargas, oCargas:aArray, oCargas:aHeaders, oCargas:bLine, oEnable, oDisable})
				If  ValType(aRetCarga[1]) == "A" .And. ValType(aRetCarga[2]) == "A" .And. ValType(aRetCarga[3]) == "B"
					aArrayCarga         := aRetCarga[1]
					oCargas:aHeaders    := aRetCarga[2]
					oCargas:bLine       := aRetCarga[3]
				EndIf
			EndIf

			oCargas:Refresh()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Listbox de Rotas                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ aPosObj2[2,1]+10,aPosObj2[2,2] LISTBOX oRotas VAR cVar ;
				Fields HEADER " ",;
				" ",;
				OemToAnsi(STR0013),; //"Codigo"
				OemToAnsi(STR0020),; //"Descricao"
				OemToAnsi(STR0014); //"Carga"
				SIZE aPosObj2[2,3],aPosObj2[2,4]-10 ;
				ON DBLCLICK (OmsTroca(1,;
					dDtStart,;
					cHrStart,;
					@aArrayCarga,;
					@aArrayRota,;
					@aArrayZona,;
					@aArraySetor,;
					@aArrayMan,;
					@aLock,;
					@oEnable,;
					@oDisable,;
					@oMarked,;
					@oNoMarked,;
					cMarca,;
					lAllMark,;
					,;
					aHeaderAdt,;
					aColsAdt,;
					cDakTransp)) OF oDlg PIXEL

			oRotas:nFreeze := 2
			oRotas:SetArray(aArrayRota)
			oRotas:bLine:={ ||{Iif(aArrayRota[oRotas:nAT,1],oEnable,oDisable),;
				Iif(aArrayRota[oRotas:nAT,2],oMarked,oNoMarked),;
							aArrayRota[oRotas:nAT,3],;
							aArrayRota[oRotas:nAT,4],;
							aArrayRota[oRotas:nAt,5]}}
			oRotas:cToolTip := OemToAnsi(STR0021) //"Duplo click para Habilitar/Desabilitar"
			oRotas:Refresh()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Listbox de Zonas                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ aPosObj3[1,1]+10,aPosObj3[1,2] LISTBOX oZonas VAR cVar ;
				Fields HEADER " ",;
				" ",;
				OemtoAnsi(STR0022),; //"Rota"
				OemtoAnsi(STR0023),; //"Zona"
				OemToAnsi(STR0024),; //"Descricao da zona"
				OemToAnsi(STR0014);  //"Carga"
				SIZE aPosObj3[1,3],aPosObj3[1,4]-10 ;
				ON DBLCLICK (OmsTroca(2,;
				dDtStart,;
				cHrStart,;
				@aArrayCarga,;
				@aArrayRota,;
				@aArrayZona,;
				@aArraySetor,;
				@aArrayMan,;
				@aLock,;
				@oEnable,;
				@oDisable,;
				@oMarked,;
				@oNoMarked,;
				cMarca,;
				lAllMark,;
				,;
				aHeaderAdt,;
				aColsAdt,;
				cDakTransp)) OF oDlg PIXEL

			oZonas:nFreeze := 2
			oZonas:SetArray(aArrayZona)
			oZonas:bLine:={ ||{Iif(aArrayZona[oZonas:nAT,1],oEnable,oDisable),;
				Iif(aArrayZona[oZonas:nAT,2],oMarked,oNoMarked),;
				aArrayZona[oZonas:nAT,3],;
				aArrayZona[oZonas:nAT,4],;
				aArrayZona[oZonas:nAT,5],;
				aArrayZona[oZonas:nAT,6]}}
			oZonas:cToolTip := OemToAnsi(STR0021) //"Duplo click para Habilitar/Desabilitar"
			oZonas:Refresh()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Listbox de Setor                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ aPosObj3[2,1]+10,aPosObj3[2,2] LISTBOX oSetores VAR cVar ;
				Fields HEADER " ",;
				" ",;
				OemtoAnsi(STR0022),; //"Rota"
				OemtoAnsi(STR0023),; //"Zona"
				OemtoAnsi(STR0025),; //"Setor"
				OemToAnsi(STR0026),; //"Descricao do Setor"
				OemToAnsi(STR0014);  //"Carga"
				SIZE aPosObj3[2,3],aPosObj3[2,4]-10 ;
				ON DBLCLICK (OmsTroca(3,;
				dDtStart,;
				cHrStart,;
				@aArrayCarga,;
				@aArrayRota,;
				@aArrayZona,;
				@aArraySetor,;
				@aArrayMan,;
				@aLock,;
				@oEnable,;
				@oDisable,;
				@oMarked,;
				@oNoMarked,;
				cMarca,;
				lAllMark,;
				,;
				aHeaderAdt,;
				aColsAdt,;
				cDakTransp)) OF oDlg PIXEL

			oSetores:nFreeze := 2
			oSetores:SetArray(aArraySetor)
			oSetores:bLine:={ ||{IIf(aArraySetor[oSetores:nAT,1],oEnable,oDisable),;
			Iif(aArraySetor[oSetores:nAT,2],oMarked,oNoMarked),;
			aArraySetor[oSetores:nAT,3],;
			aArraySetor[oSetores:nAT,4],;
			aArraySetor[oSetores:nAT,5],;
			aArraySetor[oSetores:nAT,6],;
			aArraySetor[oSetores:nAT,7]}}
			oSetores:cToolTip := OemToAnsi(STR0021) //"Duplo click para Habilitar/Desabilitar"
			oSetores:Refresh()
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Listbox de Pedidos                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TRBPED->(DbGoTop())

		If l200Auto
			aArrayMan := AClone(aAutoItens)
			OmsTroca(4,dDtStart,cHrStart,aArrayCarga,aArrayRota,aArrayZona,aArraySetor,aArrayMan,aLock,@oEnable,@oDisable,@oMarked,@oNoMarked,cMarca,lAllMark,,aHeaderAdt,aColsAdt,cDakTransp)

			OmsCarrega(@oEnable,@oDisable,@oMarked,@oNoMarked,cMarca,@aArrayCarga,@aArrayRota,@aArrayZona,@aArraySetor,@aArrayMan,cHrStart,dDtStart,cGvCodOper,cGvNoProc,cGvPedComOp,aHeaderAdt,aColsAdt,cDakTransp,aArrayMod,cDAKTpOp,cDAKClFr,aCampos,aArrayTipo,oAllMark)

			nopca := 0
		Else
			oMark :=MsSelect():New("TRBPED","PED_MARCA","PED_GERA == 'S'",aCpoBrw,.F.,@cMarca,{aPosObj1[3,1]+10,aPosObj1[3,2],aPosObj1[3,3]-3,aPosObj1[3,4]})

			oMark:bAval := {||OmsTroca(4,dDtStart,cHrStart,aArrayCarga,aArrayRota,aArrayZona,aArraySetor,aArrayMan,aLock,@oEnable,@oDisable,@oMarked,@oNoMarked,cMarca,lAllMark,,aHeaderAdt,aColsAdt,cDakTransp)}
			oMark:oBrowse:lhasMark    := .T.
			oMark:oBrowse:lCanAllmark := .T.
			oMark:oBrowse:bAllMark := {|| OmsTroca(4,dDtStart,cHrStart,aArrayCarga,aArrayRota,aArrayZona,aArraySetor,aArrayMan,aLock,@oEnable,@oDisable,@oMarked,@oNoMarked,cMarca,.F.,.T.,,,cDakTransp)}
			bBlockHead := &("{|oBrw,nCol| OS200COrd(nCol,oBrw,aHeadOrd,'TRBPED'),oMark:oBrowse:SetFocus(),oMark:oBrowse:Refresh()}")
			oMark:oBrowse:bHeaderClick:= bBlockHead

			If  cAlocPer == "S"
				OS200COrd(5,oMark:oBrowse,aHeadOrd,"TRBPED") //-- Ordem Pedido
			Else
				OS200COrd(3,oMark:oBrowse,aHeadOrd,"TRBPED") //-- Ordem Rota
			EndIf

			oMark:oBrowse:Refresh()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se  a montagem e por item para incluir checkbox            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ aPosObj1[3,3]+1,5 CheckBox oAllMark Var lAllMark Prompt OemtoAnsi(STR0062) Size 150,10 OF oDlg PIXEL //"Marca todos os itens do pedido selecionado"
			oAllMark:lVisibleControl := (mv_par06 == 2 .or. MV_PAR06 == 3)

			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, { || OmsCarrega(@oEnable,@oDisable,@oMarked,@oNoMarked,cMarca,@aArrayCarga,@aArrayRota,@aArrayZona,@aArraySetor,@aArrayMan,cHrStart,dDtStart,cGvCodOper,cGvNoProc,cGvPedComOp,aHeaderAdt,aColsAdt,cDakTransp,aArrayMod,cDAKTpOp,cDAKClFr,aCampos,aArrayTipo,oAllMark) }, {||nopca := 0,oDlg:End()},,aButtons)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura a integridade da rotina                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsUnLockAll()

		//-- Ponto de entrada apos encerramento da rotina de montagem da carga.
		If ExistBlock("OM200ENC")
			ExecBlock("OM200ENC",.F.,.F.)
		EndIf

		// Deleta a tabela temporária e reinicia o ID de carregamento de dados
		DelTabTmp("TRBPED",__oTmpTab)

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura a integridade da rotina                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !l200Auto
		Eval(bFiltraBrw)
		DAK->(MsSeek(xFilial("DAK")))
		MbrChgLoop() //nao chama a tela de inclusao novamente
	Endif

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Os200VisCg³ Autor ³Daniel Pereira         ³ Data ³29.01.2021  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de interface da visualizacao da carga                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array da Carga                                         ³±±
±±³          ³ExpA2: Array dos Pedidos                                      ³±±
±±³          ³ExpC2: Hora de inicio da carga                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Os200VisCg(aArrayCarga,aArrayMan,cHrStart,dDtStart)

Local aArrayAnt  := aClone(aArrayMan)
Local aButtons   := {   { "DOWN",       { || XOmsTrocaSeq(@cHrStart,@dDtStart,cVeiculo,aArrayAnt,oPedMan,aObj,@lSeq,@cSeqAtual,@cSeqNova,1)},    STR0171, STR0127},; //"Sequencia anterior"
						{ "UP",         { || XOmsTrocaSeq(@cHrStart,@dDtStart,cVeiculo,aArrayAnt,oPedMan,aObj,@lSeq,@cSeqAtual,@cSeqNova,2)},    STR0172, STR0128},; //"Sequencia posterior"
						{ "DESTINOS",   { || XOmsTrocaSeq(@cHrStart,@dDtStart,cVeiculo,aArrayAnt,oPedMan,aObj,@lSeq,@cSeqAtual,@cSeqNova,3)},    STR0173, STR0129},; //"Mover para..."
						{ "CLOCK02",    { || XOmsHrStart (@cHrStart,@dDtStart,cVeiculo,aArrayAnt,oPedMan,aObj,@lSeq,@cSeqAtual,@cSeqNova  )},    STR0174, STR0138},; //"Hora Inicial"###"Hr.Ini."
						{ "PESQUISA",   { || XOmsVisRegra(aArrayAnt,oPedMan)},                                                                   STR0175, STR0140},; //"Visualiza regra de entrega"
						{ "RELATORIO",  { || XOms200VLeg()}, OemtoAnsi(STR0007) }} //"Legenda"
Local aButtonUsr := {}
Local aObj       := {}
Local aSize      := MsAdvSize( .T. )
Local aPosObj1   := {}
Local aObjects   := {}
Local nSeqInc    := SuperGetMV("MV_OMSENTR",.F.,5)
Local nSequencia := 0
Local nOpcA      := 0
Local nC         := 0
Local nPosCarga  := Ascan(aArrayCarga,{|x| x[CARGA_ENABLE] == .T.})
Local cCarga     := ""
Local cVar       := ""
Local cSeqAtual  := ""
Local cSeqNova   := ""
Local cVeiculo   := ""

Local lSeq       := .F.

Local oDlgMan
Local oPedMan
Local oSayNewSeq
Local oNewSeq
Local oSaySeqAtu
Local oSeqAtual
Local oDown      := LoadBitmap( GetResources(), "TRIDOWN"  )
Local oUp        := LoadBitmap( GetResources(), "TRIUP"    )
Local oLiberado  := LoadBitmap( GetResources(), "PMSTASK4" )
Local oCalend    := LoadBitmap( GetResources(), "PMSTASK1" )
Local oHorario   := LoadBitmap( GetResources(), "PMSTASK2" )
Local oVeiculo   := LoadBitmap( GetResources(), "PMSTASK3" )
Local oSayCli
Local oSayEnd
Local oSayChP
Local oSayTmSrv
Local oSaySdP
Local oSayBai
Local oSayEst
Local oSayMun
Local oSayCep
Local aRetPE     := {}

	//-- Verifica os pedidos marcados
	If !Len( aArrayAnt ) == 0 .And. nPosCarga > 0
		//-- Permite incluir botoes
		If ExistBlock("OS200VSB")
			aButtonUsr := ExecBlock("OS200VSB",.F.,.F.)
			If ValType(aButtonUsr)=="A" .And. Len(aButtonUsr) > 0
				For nC := 1 To Len(aButtonUsr)
					AAdd(aButtons,aClone(aButtonUsr[nC]))
				Next nC
			EndIf
		EndIf
		//-- Obtem o numero da carga
		cCarga    := aArrayCarga[nPosCarga,CARGA_COD]
		cVeiculo  := aArrayCarga[nPosCarga,CARGA_VEIC]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Dimensoes da matriz   ³
		//³[1]Ativo              ³
		//³[2]Marcado            ³
		//³[3]Rota               ³
		//³[4]Zona               ³
		//³[5]Setor              ³
		//³[6]Sequencia na Rota  ³
		//³[7]Pedido             ³
		//³[8]Item               ³
		//³[9]Cliente            ³
		//³[10Loja               ³
		//³[11]Nome              ³
		//³[12]Peso              ³
		//³[13]Carga             ³
		//³[14]Sequencia no Setor³
		//³[15]Sequencia final   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//-- Renumera a sequencia de entrega considerando intervalo conforme parametro: MV_OMSENTR
		nSeqInc := IIF(nSeqInc > 0,nSeqInc,5)
		For nC := 1 to Len(aArrayAnt)
			nSequencia += nSeqInc
			aArrayAnt[nC,1] := StrZero(nSequencia,6)
		Next nC

		//-- Atualiza as horas de entrega
		Oms200Time(cHrStart,dDtStart,aArrayAnt,cVeiculo,12,6,7,2,3,4,14,15,16,17,18,19,20)

		//-- Montagem da Interface
		aObjects := {}
		AAdd( aObjects, { 100 ,100 ,.T. ,.T. ,.T.   } )
		AAdd( aObjects, { 100 ,50  ,.T. ,.F.        } )

		aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
		aPosObj1 := MsObjSize( aInfo, aObjects)

		DEFINE MSDIALOG oDlgMan FROM aSize[7], 000 TO aSize[6],aSize[5] TITLE OemtoAnsi(STR0035+cCarga) OF oMainWnd PIXEL //"Sequencia da Carga "

		@ 013,233 TO 075,317 OF oDlgMan Pixel

		@ 017,(aSize[5]/2)-75 Say oSaySeqAtu Prompt OemToAnsi(STR0045) Size 50,10 OF oDlgMan Pixel //"Seq. Atual" //235
		@ 030,(aSize[5]/2)-75 MSGet oSeqAtual VAR cSeqAtual Picture "999999"  When .F. Size 30,10 OF oDlgMan Pixel //285

		@ 052,(aSize[5]/2)-75 Say oSayNewSeq Prompt OemToAnsi(STR0046) Size 50,10 OF oDlgMan Pixel //"Nova Seq."
		@ 065,(aSize[5]/2)-75 MSGet oNewSeq VAR cSeqNova Picture "999999"  Valid OmsVldSeq(cSeqNova,aArrayAnt[oPedMan:nAt,2]) When .T. Size 30,10 OF oDlgMan Pixel

		DEFINE SBUTTON oButton1 FROM 90,(aSize[5]/2)-75 TYPE 1 ACTION xOmsTrocaSeq(cHrStart,dDtStart,cVeiculo,aArrayAnt,oPedMan,aObj,@lSeq,@cSeqAtual,@cSeqNova,5) ENABLE OF oDlgMan
		DEFINE SBUTTON oButton2 FROM 90,(aSize[5]/2)-45 TYPE 2 ACTION xOmsTrocaSeq(cHrStart,dDtStart,cVeiculo,aArrayAnt,oPedMan,aObj,@lSeq,@cSeqAtual,@cSeqNova,4) ENABLE OF oDlgMan

		AAdd( aObj ,oSaySeqAtu )
		AAdd( aObj ,oSeqAtual  )
		AAdd( aObj ,oSayNewSeq )
		AAdd( aObj ,oNewSeq    )
		AAdd( aObj ,oButton1   )
		AAdd( aObj ,oButton2   )

		aEval(aObj,{|x| x:hide()})

		//-- ListBox dos pedido
		@ aPosObj1[1,1],aPosObj1[1,2] LISTBOX oPedMan VAR cVar Fields HEADER OemtoAnsi(" "),OemtoAnsi(" "),OemtoAnsi(" "),;
			OemtoAnsi(STR0036),; //"Sequencia"
			OemtoAnsi(STR0022),; //"Rota"
			OemtoAnsi(STR0028),; //"Pedido"
			OemtoAnsi(STR0150),; //"Data Chegada"
			OemtoAnsi(STR0133),; //"Chegada Prevista"
			OemtoAnsi(STR0134),; //"Time Service"
			OemtoAnsi(STR0151),; //"Data Saida"
			OemtoAnsi(STR0030),; //"Cliente"
			OemtoAnsi(STR0031),; //"Loja"
			OemToAnsi(STR0032),; //"Nome"
			OemToAnsi(STR0108),; //"Bairro"
			OemToAnsi(STR0109),; //"Cidade"
			OemToAnsi(STR0110) ; //"UF"
			SIZE aPosObj1[1,3],aPosObj1[1,4] OF oDlgMan PIXEL
		oPedMan:SetArray(aArrayAnt)

		oPedMan:bLine:={||{ Iif(aArrayAnt[oPedMan:nAT,18]==1,oLiberado,;
							Iif(aArrayAnt[oPedMan:nAT,18]==2,oVeiculo,;
							Iif(aArrayAnt[oPedMan:nAT,18]==3,oHorario,;
							Iif(aArrayAnt[oPedMan:nAT,18]==4,oCalend,oLiberado)))),;
							oDown, oUp,;
							aArrayAnt[oPedMan:nAT, 1],;
							aArrayAnt[oPedMan:nAT, 2],;
							aArrayAnt[oPedMan:nAT, 5],;
							aArrayAnt[oPedMan:nAT,19],;
							aArrayAnt[oPedMan:nAT,16],;
							aArrayAnt[oPedMan:nAT,17],;
							aArrayAnt[oPedMan:nAT,20],;
							aArrayAnt[oPedMan:nAT, 6],;
							aArrayAnt[oPedMan:nAT, 7],;
							aArrayAnt[oPedMan:nAT, 8],;
							aArrayAnt[oPedMan:nAT, 9],;
							aArrayAnt[oPedMan:nAT,10],;
							aArrayAnt[oPedMan:nAT,11],;
							aArrayAnt[oPedMan:nAT,21],;
							aArrayAnt[oPedMan:nAT,22],;
							aArrayAnt[oPedMan:nAT,23],;
							aArrayAnt[oPedMan:nAT,24]}}

		//-- Ponto de entrada para adicionar campos na opcao Sequencia de Entrega.
		If  ExistBlock("OM200ADC")
			aRetPE := ExecBlock("OM200ADC",.F.,.F.,{oPedMan:aArray, oPedMan:aHeaders, oPedMan:bLine, oLiberado, oCalend, oHorario, oVeiculo})
			If  ValType(aRetPE[1]) == "A" .And. ValType(aRetPE[2]) == "A" .And. ValType(aRetPE[3]) == "B"
				oPedMan:aArray      := aRetPE[1]
				oPedMan:aHeaders    := aRetPE[2]
				oPedMan:bLine       := aRetPE[3]
			EndIf
		EndIf

		//-- Rodape da janela
		@ aPosObj1[2,1]+2, aPosObj1[2,2] TO aPosObj1[2,3], aPosObj1[2,4] LABEL OemToAnsi(STR0137) OF oDlgMan PIXEL //"Dados da Entrega"

		@ aPosObj1[2,1]+10,05  Say OemtoAnsi(STR0030)+":"   SIZE 040,08 OF oDlgMan PIXEL //"Cliente: "
		@ aPosObj1[2,1]+10,30  Say oSayCli Prompt ""        SIZE 300,08 OF oDlgMan PIXEL

		@ aPosObj1[2,1]+20,05  Say OemtoAnsi(STR0114)+":"   SIZE 060,08 OF oDlgMan PIXEL //"Endereco:"
		@ aPosObj1[2,1]+20,30  Say oSayEnd Prompt ""        SIZE 300,08 OF oDlgMan PIXEL

		@ aPosObj1[2,1]+20,170 Say OemtoAnsi(STR0108)+":"   SIZE 060,08 OF oDlgMan PIXEL //"Bairro"
		@ aPosObj1[2,1]+20,210 Say oSayBai Prompt ""        SIZE 300,08 OF oDlgMan PIXEL

		@ aPosObj1[2,1]+30,05  Say OemtoAnsi(STR0109)+":"   SIZE 060,08 OF oDlgMan PIXEL //"Cidade"
		@ aPosObj1[2,1]+30,30  Say oSayMun Prompt ""        SIZE 300,08 OF oDlgMan PIXEL

		@ aPosObj1[2,1]+30,90  Say OemtoAnsi(STR0110)+":"   SIZE 060,08 OF oDlgMan PIXEL //"Estado"
		@ aPosObj1[2,1]+30,120 Say oSayEst Prompt ""        SIZE 040,08 OF oDlgMan PIXEL

		@ aPosObj1[2,1]+30,170 Say OemtoAnsi(STR0136)+":"   SIZE 060,08 OF oDlgMan PIXEL //"Cep"
		@ aPosObj1[2,1]+30,210 Say oSayCep Prompt ""        SIZE 040,08 OF oDlgMan PIXEL

		@ aPosObj1[2,1]+40,05  Say OemtoAnsi(STR0133)+":"   SIZE 060,08 OF oDlgMan PIXEL //"Chegada Prevista:"
		@ aPosObj1[2,1]+40,50  Say oSayChP Prompt ""        SIZE 040,08 OF oDlgMan PIXEL

		@ aPosObj1[2,1]+40,90  Say OemtoAnsi(STR0134)+":"   SIZE 060,08 OF oDlgMan PIXEL //"Time Service:"
		@ aPosObj1[2,1]+40,125 Say oSayTmSrv Prompt ""      SIZE 040,08 OF oDlgMan PIXEL

		@ aPosObj1[2,1]+40,170 Say OemtoAnsi(STR0135)+":"   SIZE 060,08 OF oDlgMan PIXEL //"Saida Prevista"
		@ aPosObj1[2,1]+40,210 Say oSaySdP Prompt ""        SIZE 040,08 OF oDlgMan PIXEL

		oPedMan:bLDblClick := { |oObj,nCol| IIF(nCol==2,xOmsTrocaSeq(@cHrStart,@dDtStart,cVeiculo,aArrayAnt,oPedMan,aObj,@lSeq,@cSeqAtual,@cSeqNova,1),;
											IIF(nCol==3,xOmsTrocaSeq(@cHrStart,@dDtStart,cVeiculo,aArrayAnt,oPedMan,aObj,@lSeq,@cSeqAtual,@cSeqNova,2),Nil)) }
		oPedMan:bChange  := {|| xOms200Msg(aArrayAnt,oPedMan,oSayCli,oSayEnd,oSayBai,oSayMun,oSayEst,oSayCep,oSayChP,oSayTmSrv,oSaySdP) }
		oPedMan:Refresh()

		//--                              EnchoiceBar(oDlg,bOk,bCancel,lMessageDel,aButtons,nReg,cAlias,lMashups,lImpCad,lPadrao,lHasOk)
		ACTIVATE MSDIALOG oDlgMan ON INIT EnchoiceBar( oDlgMan, { || nOpca := 1,oDlgMan:End()}, {||oDlgMan:End()},,aButtons,,,.F.,.F.,.F.,)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizo o Array principal                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpca == 1
			aArrayMan := aClone(aArrayAnt)
            If Select("TRBPED") > 0 //Atualiza a sequencia da rota na temporaria TRBPEDED
                Oms200sqe(aArrayMan)   
            EndIf  			
		EndIf
	Else
		Help(" ",1,"OMSPEDMARK") //Nao existem pedidos marcados
	EndIf
Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³XOmsVisRegra³ Autor ³Daniel Pereira       ³ Data ³29.01.2021  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de visualizacao das regras de entrega do cliente       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array com os dados dos clientes                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function xOmsVisRegra(aArrayAnt,oPedMan)
Local lIncluiBk := INCLUI
Local aArea     := GetArea()
Local aAreaSA1  := SA1->(GetArea())
Local cAliasSA1 := GetNextAlias()
Local cAliasDAD := Nil

	INCLUI := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe janela de entrega para o cliente ou grupo        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BeginSql Alias cAliasSA1
		SELECT SA1.A1_GRPVEN,
				SA1.A1_COD,
				SA1.A1_LOJA
		FROM %Table:SA1% SA1
		WHERE SA1.A1_FILIAL = %Exp:OsFilial("SA1",aArrayAnt[oPedMan:nAt][12])%
		AND SA1.A1_COD = %Exp:aArrayAnt[oPedMan:nAt][6]%
		AND SA1.A1_LOJA = %Exp:aArrayAnt[oPedMan:nAt][7]%
		AND SA1.%NotDel%
	EndSql
	If (cAliasSA1)->(!Eof())
		cAliasDAD := GetNextAlias()
		BeginSql Alias cAliasDAD
			SELECT DAD.R_E_C_N_O_ RECNODAD
			FROM %Table:DAD% DAD
			WHERE DAD.DAD_FILIAL = %xFilial:DAD%
			AND DAD.DAD_CODCLI = %Exp:aArrayAnt[oPedMan:nAt][6]%
			AND DAD.DAD_LOJA = %Exp:aArrayAnt[oPedMan:nAt][7]%
		EndSql
		If (cAliasDAD)->(!Eof())
			DAD->(dbGoTo((cAliasDAD)->RECNODAD))
			FWExecView("Calendario do Roteiro" ,"OMSA120",1,,{ || .T. },{ || .T. },0,,{ || .T. },,, )
		Else
			(cAliasDAD)->(dbCloseArea())
			cAliasDAD := GetNextAlias()
			BeginSql Alias cAliasDAD
				SELECT DAD.R_E_C_N_O_ RECNODAD
				FROM %Table:DAD% DAD
				WHERE DAD.DAD_FILIAL = %xFilial:DAD%
				AND DAD.DAD_GRPVEN = %Exp:(cAliasSA1)->A1_GRPVEN%
			EndSql
			If (cAliasDAD)->(!Eof())
				DAD->(dbGoTo((cAliasDAD)->RECNODAD))
				FWExecView("Calendario do Roteiro" ,"OMSA120",1,,{ || .T. },{ || .T. },0,,{ || .T. },,, )
			Else
				Help(" ",1,"OMS200REGR") //Não existem regras de entrega para este cliente.
			EndIf
			(cAliasDAD)->(dbCloseArea())
		EndIf
	EndIf
	(cAliasSA1)->(dbCloseArea())

	INCLUI := lIncluiBk

	RestArea(aAreaSA1)
	RestArea(aArea)
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Oms200VLeg³ Autor ³ Daniel Pereira        ³ Data ³23/01/2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Exibe a legenda dos status do pedido                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function xOms200VLeg()
Local aLegenda := { { "PMSTASK4" ,OemToAnsi(STR0142) },; //"Entrega permitida"
					{ "PMSTASK1" ,OemToAnsi(STR0143) },; //"Restricao por calendario"
					{ "PMSTASK2" ,OemToAnsi(STR0144) },; //"Restricao por horario"
					{ "PMSTASK3" ,OemToAnsi(STR0145) } } //"Restricao por veiculo"

	BrwLegenda(cCadastro, OemToAnsi(STR0146), aLegenda) //"Status"
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³xOmsHrStart³ Autor ³Daniel Pereira        ³ Data ³02.02.2021  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina alteracao da hora de inicio da entrega                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array da Carga                                         ³±±
±±³          ³ExpA2: Array dos Pedidos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function XOmsHrStart(cHrStart,dDtStart,cVeiculo,aArrayAnt,oPedMan,aObj,lSeq,cSeqAtual,cSeqNova)
Local nOpca   := 0
Local cNewHr  := cHrStart
Local dNewDt  := dDtStart
Local cBitmap := "PROJETOAP"

	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0139) From 0,0 To 120,280 OF oMainWnd PIXEL //"Hora Inicial da Entrega"

	@ 0 , 0 BITMAP oBmp RESNAME cBitMap OF oDlg SIZE 48,488 NOBORDER WHEN .F. PIXEL

	@ 005,055 Say OemtoAnsi(STR0138) OF oDlg PIXEL SIZE 45,10 //"Hora Inicial"
	@ 005,088 MSGET cNewHr OF oDlg Valid OmsVldHr(cNewHr) PIXEL SIZE 34,10 Picture "99:99"

	@ 020,055 Say OemtoAnsi(STR0070) Of oDlg PIXEL SIZE 45,10 //"Data"
	@ 020,088 MSGET dNewDt OF oDlg Valid OmsVldHr(cNewHr) PIXEL SIZE 41,10

	DEFINE SBUTTON FROM 045, 067 TYPE 1 ENABLE OF oDlg ACTION( nOpcA := 1,oDlg:End())
	DEFINE SBUTTON FROM 045, 097 TYPE 2 ENABLE OF oDlg ACTION( oDlg:End())

	ACTIVATE DIALOG oDlg Centered

	If nOpca ==1
		cHrStart := cNewHr
		dDtStart := dNewDt
		xOmsTrocaSeq(cHrStart,dDtStart,cVeiculo,aArrayAnt,oPedMan,aObj,.T.,cSeqAtual,cSeqNova,6)
	EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³xOms200Msg ³ Autor ³Daniel Pereira         ³ Data ³02.03.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de mensagem do rodape da sequencia de carga            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array da Carga                                         ³±±
±±³          ³ExpO2: Objeto do ListBox                                      ³±±
±±³          ³ExpO3: Objeto do Cliente                                      ³±±
±±³          ³ExpO4: Objeto do Endereco                                     ³±±
±±³          ³ExpO5: Objeto da chegada prevista                             ³±±
±±³          ³ExpO6: Objeto dO TIME SERVICE                                 ³±±
±±³          ³ExpO7: Objeto da SAIDA PREVISTA                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function xOms200Msg(aArrayAnt,oPedMan,oSayCli,oSayEnd,oSayBai,oSayMun,oSayEst,oSayCep,oSayChP,oSayTmSrv,oSaySdP)
Local aArea     := GetArea()
Local aAreaSA1  := SA1->(GetArea())
Local cAliasSC5 := GetNextAlias()
Local cAliasSA1 := Nil
Local cAliasSA2 := Nil

	BeginSql Alias cAliasSC5
		SELECT 1
		FROM %Table:SC5% SC5
		WHERE SC5.C5_FILIAL = %Exp:OsFilial("SC5",aArrayAnt[oPedMan:nAt][12])%
		AND SC5.C5_NUM = %Exp:aArrayAnt[oPedMan:nAt][05]%
		AND SC5.C5_TIPO NOT IN ('D','B')
		AND SC5.%NotDel%
	EndSql
	If (cAliasSC5)->(!Eof())
		cAliasSA1 := GetNextAlias()
		BeginSql Alias cAliasSA1
			SELECT SA1.R_E_C_N_O_ RECNOSA1
			FROM %Table:SA1% SA1
			WHERE SA1.A1_FILIAL = %Exp:OsFilial("SA1",aArrayAnt[oPedMan:nAt][12])%
			AND SA1.A1_COD = %Exp:aArrayAnt[oPedMan:nAt][6]%
			AND SA1.A1_LOJA = %Exp:aArrayAnt[oPedMan:nAt][7]%
			AND SA1.%NotDel%
		EndSql
		If (cAliasSA1)->(!Eof())
			SA1->(dbGoTo((cAliasSA1)->RECNOSA1))
			oSayCli:SetText(aArrayAnt[oPedMan:nAt][6]+"-"+aArrayAnt[oPedMan:nAt][7]+"   "+SA1->A1_NOME)
			Do Case
			Case SuperGetMv("MV_ROTCEP",.F.,"1") == "1"
				oSayEnd:SetText(Alltrim(SA1->A1_END))
				oSayBai:SetText(SA1->A1_BAIRRO)
				oSayMun:SetText(SA1->A1_MUN)
				oSayEst:SetText(SA1->A1_EST)
				oSayCep:SetText(SA1->A1_CEP)
			Case SuperGetMv("MV_ROTCEP",.F.,"1") == "2"
				oSayEnd:SetText(IIf(Empty(Alltrim(SA1->A1_ENDENT)),Alltrim(SA1->A1_END),Alltrim(SA1->A1_ENDENT)))
				oSayBai:SetText(IIf(Empty(SA1->A1_BAIRROE),SA1->A1_BAIRRO,SA1->A1_BAIRROE))
				oSayMun:SetText(IIf(Empty(SA1->A1_MUNE),SA1->A1_MUN,SA1->A1_MUNE))
				oSayEst:SetText(IIf(Empty(SA1->A1_ESTE),SA1->A1_EST,SA1->A1_ESTE))
				oSayCep:SetText(IIf(Empty(SA1->A1_CEPE),SA1->A1_CEP,SA1->A1_CEPE))
			Case SuperGetMv("MV_ROTCEP",.F.,"1") == "3"
				oSayEnd:SetText(Alltrim(SA1->A1_ENDENT))
				oSayBai:SetText(SA1->A1_BAIRROE)
				oSayMun:SetText(SA1->A1_MUNE)
				oSayEst:SetText(SA1->A1_ESTE)
				oSayCep:SetText(SA1->A1_CEPE)
			EndCase
		EndIf
		(cAliasSA1)->(dbCloseArea())
	Else
		cAliasSA2 := GetNextAlias()
		BeginSql Alias cAliasSA2
			SELECT SA2.R_E_C_N_O_ RECNOSA2
			FROM %Table:SA2% SA2
			WHERE SA2.A2_FILIAL = %Exp:OsFilial("SA2",aArrayAnt[oPedMan:nAt][12])%
			AND SA2.A2_COD = %Exp:aArrayAnt[oPedMan:nAt][6]%
			AND SA2.A2_LOJA = %Exp:aArrayAnt[oPedMan:nAt][7]%
			AND SA2.%NotDel%
		EndSql
		If (cAliasSA2)->(!Eof())
			SA2->(dbGoTo((cAliasSA2)->RECNOSA2))
			oSayCli:SetText(aArrayAnt[oPedMan:nAt][6]+"-"+aArrayAnt[oPedMan:nAt][7]+"   "+SA2->A2_NOME)
			oSayEnd:SetText(Alltrim(SA2->A2_END))
			oSayBai:SetText(SA2->A2_BAIRRO)
			oSayMun:SetText(SA2->A2_MUN)
			oSayEst:SetText(SA2->A2_EST)
			oSayCep:SetText(SA2->A2_CEP)
		EndIf
		(cAliasSA2)->(dbCloseArea())
	EndIf
	oSayChP:SetText(aArrayAnt[oPedMan:nAt][16])
	oSayTmSrv:SetText(aArrayAnt[oPedMan:nAt][17])
	oSaySdP:SetText(IntToHora(HoraToInt(aArrayAnt[oPedMan:nAt][16],2)+HoraToInt(aArrayAnt[oPedMan:nAt][17],4),2))

	RestArea( aAreaSA1 )
	RestArea( aArea    )
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Os200VisCF³ Autor ³Daniel Pereira         ³ Data ³29.01.2021  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de interface da visualizacao de cliente/fornecedor     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Os200VisCF()
Local aArea     := GetArea()
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSA1  := SA1->(GetArea())
Local aAreaSA2  := SA2->(GetArea())
Local cAliasArq := Nil
Local cAliasSC5 := GetNextAlias()
Local cSavFil   := cFilAnt
	// Verifica a filial correta do Pedido de Venda
	If OsVlEntCom() <> 1
		cFilAnt := TRBPED->PED_FILORI
	EndIf
	// Verifica-se se o pedido eh para um cliente ou Fornecedor
	BeginSql Alias cAliasSC5
		SELECT SC5.C5_TIPO
		FROM %Table:SC5% SC5
		WHERE SC5.C5_FILIAL = %Exp:OsFilial("SC5",TRBPED->PED_FILORI)%
		AND SC5.C5_NUM = %Exp:TRBPED->PED_PEDIDO%
		AND SC5.%NotDel%
	EndSql
	If (cAliasSC5)->(!Eof())
		cAliasArq := GetNextAlias()
		If (cAliasSC5)->C5_TIPO == "B" .Or. (cAliasSC5)->C5_TIPO == "D"
			BeginSql Alias cAliasArq
				SELECT SA2.R_E_C_N_O_ RECNOSA2
				FROM %Table:SA2% SA2
				WHERE SA2.A2_FILIAL = %Exp:OsFilial(cAliasArq,TRBPED->PED_FILORI)%
				AND SA2.A2_COD = %Exp:TRBPED->PED_CODCLI%
				AND SA2.A2_LOJA = %Exp:TRBPED->PED_LOJA%
				AND SA2.%NotDel%
			EndSql
			If (cAliasArq)->(!Eof())
				// Montagem da Interface
				SA2->(DbGoTo((cAliasArq)->RECNOSA2))
				AxVisual("SA2",(cAliasArq)->RECNOSA2,2)
			EndIf
		Else
			BeginSql Alias cAliasArq
				SELECT SA1.R_E_C_N_O_ RECNOSA1
				FROM %Table:SA1% SA1
				WHERE SA1.A1_FILIAL = %Exp:OsFilial(cAliasArq,TRBPED->PED_FILORI)%
				AND SA1.A1_COD = %Exp:TRBPED->PED_CODCLI%
				AND SA1.A1_LOJA = %Exp:TRBPED->PED_LOJA%
				AND SA1.%NotDel%
			EndSql
			If (cAliasArq)->(!Eof())
				// Montagem da Interface
				SA1->(DbGoTo((cAliasArq)->RECNOSA1))
				AxVisual("SA1",(cAliasArq)->RECNOSA1,2)
			EndIf
		EndIf
		(cAliasArq)->(dbCloseArea())
	EndIf
	(cAliasSC5)->(dbCloseArea())
	// Restaura a integridade da rotina
	cFilAnt := cSavFil
	RestArea( aAreaSC5 )
	RestArea( aAreaSA1 )
	RestArea( aAreaSA2 )
	RestArea( aArea    )
Return .T.
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Os200VisPv³ Autor ³Daniel Pereira         ³ Data ³ 29.01.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de interface da visualizacao do Pedido de Venda        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function XOs200VisPv()
Local lIncluiAnt := Inclui
Local aArea      := GetArea()
Local cSavFil    := cFilAnt

	// Verifica a filial correta do Pedido de Venda
	If OsVlEntCom() <> 1
		cFilAnt := TRBPED->PED_FILORI
	EndIf
	// Montagem da interface
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	If  DbSeek(OsFilial("SC5",TRBPED->PED_FILORI)+TRBPED->PED_PEDIDO)
		Inclui := .F.
		A410Visual("SC5",SC5->(Recno()),2)
		Inclui := lIncluiAnt
	EndIf
	// Carrega perguntas do OMSA200
	Pergunte("OMS200",.F.)
	// Restaura a integridade da rotina
	cFilAnt := cSavFil
	RestArea( aArea )
Return( .T. )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OmsTroca  ºAutor  ³DANIEL PEREIRA      º Data ³  29.01.2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Marca e valida as amarracoes da geracao de carga           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nEscolha - Analisa o listbox escolhido                     º±±
±±º          ³ aArrayCarga - aArray de cargas passado por referencia      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OmsTroca(nEscolha,dDtStart,cHrStart,aArrayCarga,aArrayRota,aArrayZona,aArraySetor,aArrayMan,aLock,oEnable,oDisable,oMarked,oNoMarked,cMarca,lPedMark,lAllMark,aHeaderAdt,aColsAdt,cDakTransp)
Local lSomaCarga := .T.
Local lAbatCarga := .T.
Local lDelMan    := .F.
Local lMarca     := .T.
Local lOM200MRC  := ExistBlock("OM200MRC")
Local aArea      := GetArea()
Local aAreaTRB   := TRBPED->(GetArea())
Local aArrayPto  := {}
Local aPesqRota  := {}
Local aRetPE     := {}
Local cCarga     := ""
Local cBusca     := ""
Local cAlocPer   := SuperGetMv("MV_ALOCPER",.F.,"N")
Local cVeiculo   := ""
Local cSeekPed   := ""
Local cWhile     := "PED_ROTA+PED_ZONA+PED_SETOR"
Local cRota      := ""
Local cZona      := ""
Local cSetor     := ""
Local cWhere     := ""
Local cCpoCapac  := IIf(SuperGetmv("MV_OMSCAPA",.F.,"1")=="1","DA3_CAPACN","DA3_CAPACM")
Local cAliasDA3  := Nil
Local nOrder     := 4 //-- PED_ROTA+PED_ZONA+PED_SETOR+PED_FILORI+PED_FILORI+PED_PEDIDO
Local nMultiplic := 0
Local nPosCarga  := 0
Local nPesoItem  := 0
Local nVolItem   := 0
Local nValorItem := 0
Local nQtdItem   := 0
Local nPesoCIF   := 0
Local nVolCIF    := 0
Local nValorCIF  := 0
Local nQtdCIF    := 0
Local nPesoFOB   := 0
Local nVolFOB    := 0
Local nValorFOB  := 0
Local nQtdFOB    := 0
Local nC0        := 0
Local nC1        := 0
Local nC2        := 0
Local nC3        := 0
Local nPosMan    := 0
Local nCapac     := 0
Local nPosRotAlt := 0
Local lDaiRedesp := DAI->( ColumnPos( "DAI_REDESP" ) ) > 0

Default lAllMark  := .F.
Default cDakTransp:= Criavar("A4_COD",.F.)

	//-- Verifico se existe carga disponivel aberta
	nPosCarga := Ascan(aArrayCarga,{|x| x[CARGA_ENABLE] == .T.})
	If nPosCarga == 0
		Help(" ",1,"DLACGDISP") //Nao existe carga disponivel aberta
		Return
	Else
		cCarga    := aArrayCarga[nPosCarga,CARGA_COD]
		cVeiculo  := aArrayCarga[nPosCarga,CARGA_VEIC]
	EndIf

	If !l200Auto
		oRotas:lDisablePaint        := .T.
		oZonas:lDisablePaint        := .T.
		oSetores:lDisablePaint      := .T.
		oMark:oBrowse:lDisablePaint := .T.
	Endif

	If  nEscolha == 4
		Pergunte("OMS200",.F.) //Parametro da Montagem de Cargas
		//-- Verifico se o total da carga esta fechado com a capacidade do caminhao se parametro considerar restricoes
		If !Empty(cVeiculo) .And. mv_par05 == 1 .And. TRBPED->PED_MARCA <> cMarca
			cAliasDA3 := GetNextAlias()
			BeginSql Alias cAliasDA3
				SELECT DA3.R_E_C_N_O_ RECNODA3
				FROM %Table:DA3% DA3
				WHERE DA3.DA3_FILIAL = %xFilial:DA3%
				AND DA3.DA3_COD = %Exp:cVeiculo%
				AND DA3.%NotDel%
			EndSql
			If (cAliasDA3)->(!Eof())
				DA3->(dbGoTo((cAliasDA3)->RECNODA3))
				nCapac := DA3->(FieldGet(ColumnPos(cCpoCapac)))
				If  (aArraycarga[oCargas:nAt,CARGA_PESO  ] + TRBPED->PED_PESO > nCapac).Or.;
					(aArrayCarga[oCargas:nAt,CARGA_VOLUM ] + TRBPED->PED_VOLUM > DA3->DA3_VOLMAX).Or.;
					(aArrayCarga[oCargas:nAt,CARGA_PTOENT] + 1 > DA3->DA3_LIMMAX)
					Help(" ",1,"OMSULTCARG") //Caminhao nao suporta carga montada
					oRotas:lDisablePaint        := .F.
					oZonas:lDisablePaint        := .F.
					oSetores:lDisablePaint      := .F.
					oMark:oBrowse:lDisablePaint := .F.
					Return (.F.)
				EndIf
			EndIf
			(cAliasDA3)->(dbCloseArea())
		EndIf
		If  TRBPED->PED_GERA == "N"
			cRota  := TRBPED->PED_ROTA
			cZona  := TRBPED->PED_ZONA
			cSetor := TRBPED->PED_SETOR
			RecLock("TRBPED",.F.)
			If !l200Auto
				TRBPED->PED_MARCA  := Iif(TRBPED->PED_MARCA <> cMarca, cMarca, "  ")
			Endif
			TRBPED->PED_CARGA  := Iif(TRBPED->PED_MARCA == cMarca, cCarga, "ZZZZZZ")
			TRBPED->(MsUnlock())
			//-- Verifico se existe no array de sequencia e incluo ou excluo caso a opcao escolhida pelo usuario
			cBusca  := TRBPED->(PED_PEDIDO+PED_CODCLI+PED_LOJA+PED_FILORI)
			nPosMan := Ascan(aArrayMan,{|x| x[5]+x[6]+x[7]+x[12] == cBusca})

			//-- Verifico se o pedido foi marcado para inclusao no array de sequencia
			If (TRBPED->PED_MARCA == cMarca)
				If  cAlocPer == "S"
					//-- Buscar 1a. Rota disponivel.
					If (nC1 := aScan(aArraySetor,{|x| x[4]+x[5] == cZona+cSetor}))>0
						cRota := aArraySetor[nC1,3]
					EndIf
					RecLock("TRBPED",.F.)
					TRBPED->PED_ROTA := cRota
					TRBPED->(MsUnlock())
				EndIf

				If l200Auto
					aArrayMan := AClone(aAutoItens)
					nPosMan := Len(aArrayMan)
				Else
					If nPosMan == 0
						AAdd(aArrayMan,{TRBPED->PED_SEQROT,;
						TRBPED->PED_ROTA,;
						TRBPED->PED_ZONA,;
						TRBPED->PED_SETOR,;
						TRBPED->PED_PEDIDO,;
						TRBPED->PED_CODCLI,;
						TRBPED->PED_LOJA,;
						TRBPED->PED_NOME,;
						TRBPED->PED_BAIRRO,;
						TRBPED->PED_MUN,;
						TRBPED->PED_EST,;
						TRBPED->PED_FILORI,;
						TRBPED->PED_FILCLI,;
						0,;
						0,,,,,,,,,,;
						0,;
						0,;
						TRBPED->PED_ENDCLI,;
						Iif(lDaiRedesp,TRBPED->PED_REDESP,""),;
						Iif(lDaiRedesp,TRBPED->PED_REDNOM,"")})
						nPosMan := Len(aArrayMan)
					EndIf
				EndIf
				//-- Se nao estiver pego apenas os valores do item marcado
				nPesoItem  := TRBPED->PED_PESO
				nValorItem := TRBPED->PED_VALOR
				nVolItem   := TRBPED->PED_VOLUM
				nQtdItem   := TRBPED->PED_QTDLIB
				//-- Procura e marca Rota --//
				If  (nC1:=aScan(aArrayRota,{|x|x[3] == cRota .And. x[1] .And. !x[2]}))>0
					aArrayRota[nC1,2] := .T.
				EndIf
				//-- Procura e marca Zona --//
				If  (nC1:=aScan(aArrayZona,{|x|x[3]+x[4] == cRota+cZona .And. x[1] .And. !x[2]}))>0
					aArrayZona[nC1,2] := .T.
				EndIf
				//-- Procura e marca Setor --//
				If  (nC1:=aScan(aArraySetor,{|x|x[3]+x[4]+x[5] == cRota+cZona+cSetor .And. x[1] .And. !x[2]}))>0
					aArraySetor[nC1,2] := .T.
				EndIf
				//-- Verifico se a montagem e por item e se esta ativo a marcacao de todos os itens do pedido automatica
				If lPedMark .Or. lAllMark
					If ((mv_par06 == 2 .or. MV_PAR06 == 3) .And. lPedMark)
						cPedido := TRBPED->(PED_FILORI+PED_PEDIDO)
					Else
						cPedido := ""
					EndIf
					TRBPED->(DbSetOrder(1)) //-- PED_FILORI+PED_PEDIDO+PED_ITEM+PED_SEQLIB+PED_CODCLI+PED_LOJA
					If TRBPED->(MsSeek(cPedido))
						If mv_par06 == 2
							cWhere := " AND SC9.C9_ITEM = '"+TRBPED->PED_ITEM+"'"
							cWhere += " AND SC9.C9_SEQUEN = '"+TRBPED->PED_SEQLIB+"'"
						EndIf
						cWhere := "%"+cWhere+"%"
						Do While TRBPED->(!Eof() .And. (Empty(cPedido) .Or. PED_FILORI+PED_PEDIDO == cPedido))
							cAliasSC9 := GetNextAlias()
							BeginSql Alias cAliasSC9
								SELECT SC9.C9_CARGA
								FROM %Table:SC9% SC9
								WHERE SC9.C9_FILIAL = %Exp:TRBPED->PED_FILORI%
								AND SC9.C9_PEDIDO = %Exp:TRBPED->PED_PEDIDO%
								AND SC9.%NotDel%
								%Exp:cWhere%
							EndSql
							If (cAliasSC9)->(!Eof())
								//-- Marco todos os itens se o flag estiver ativo
								If (TRBPED->PED_MARCA <> cMarca) .And. Empty((cAliasSC9)->C9_CARGA)
									cRota  := TRBPED->PED_ROTA
									cZona  := TRBPED->PED_ZONA
									cSetor := TRBPED->PED_SETOR
									RecLock("TRBPED",.F.)
									TRBPED->PED_MARCA := cMarca
									TRBPED->PED_CARGA := Iif(TRBPED->PED_MARCA == cMarca,cCarga,"ZZZZZZ")
									If  cAlocPer == "S"
										//-- Buscar 1a. Rota disponivel.
										If (nC1 := aScan(aArraySetor,{|x| x[4]+x[5] == cZona+cSetor}))>0
											cRota := aArraySetor[nC1,3]
										EndIf
										TRBPED->PED_ROTA := Iif(TRBPED->PED_MARCA == cMarca, cRota , Space(Len(DA8->DA8_COD)))
									EndIf
									TRBPED->(MsUnlock())

									//-- Verifico se existe no array de sequencia e incluo ou excluo caso a opcao escolhida pelo usuario
									cBusca  := TRBPED->(PED_PEDIDO+PED_CODCLI+PED_LOJA+PED_FILORI)
									nPosMan := Ascan(aArrayMan,{|x| x[5]+x[6]+x[7]+x[12] == cBusca})

									//-- Verifico se o pedido foi marcado para inclusao no array de sequencia
									If (TRBPED->PED_MARCA == cMarca)
										If  nPosMan == 0
											AAdd(aArrayMan,{TRBPED->PED_SEQROT,;
											TRBPED->PED_ROTA,;
											TRBPED->PED_ZONA,;
											TRBPED->PED_SETOR,;
											TRBPED->PED_PEDIDO,;
											TRBPED->PED_CODCLI,;
											TRBPED->PED_LOJA,;
											TRBPED->PED_NOME,;
											TRBPED->PED_BAIRRO,;
											TRBPED->PED_MUN,;
											TRBPED->PED_EST,;
											TRBPED->PED_FILORI,;
											TRBPED->PED_FILCLI,;
											0,;
											0,,,,,,,,,,;
											0,;
											0,;
											TRBPED->PED_ENDCLI,;
											Iif(lDaiRedesp,TRBPED->PED_REDESP,""),;
											Iif(lDaiRedesp,TRBPED->PED_REDNOM,"")})
											nPosMan := Len(aArrayMan)
										EndIf
										//-- Se nao estiver pego apenas os valores do item marcado
										nPesoItem  += TRBPED->PED_PESO
										nValorItem += TRBPED->PED_VALOR
										nVolItem   += TRBPED->PED_VOLUM
										nQtdItem   += TRBPED->PED_QTDLIB
										cRota      := TRBPED->PED_ROTA
										cZona      := TRBPED->PED_ZONA
										cSetor     := TRBPED->PED_SETOR
										//-- Procura e marca Rota --//
										If  (nC1:=aScan(aArrayRota,{|x|x[3] == cRota .And. x[1] .And. !x[2]}))>0
											aArrayRota[nC1,2] := .T.
										EndIf
										//-- Procura e marca Zona --//
										If  (nC1:=aScan(aArrayZona,{|x|x[3]+x[4] == cRota+cZona .And. x[1] .And. !x[2]}))>0
											aArrayZona[nC1,2] := .T.
										EndIf
										//-- Procura e marca Setor --//
										If  (nC1:=aScan(aArraySetor,{|x|x[3]+x[4]+x[5] == cRota+cZona+cSetor .And. x[1] .And. !x[2]}))>0
											aArraySetor[nC1,2] := .T.
										EndIf
									EndIf
								EndIf
							EndIf
							(cAliasSC9)->(DbCloseArea())
							//--
							TRBPED->(DbSkip())
						EndDo
					EndIf
				EndIf
				//-- Atualizo no array de carga os dados de volume, peso, valor e ptos de entrega
				aArrayCarga[nPosCarga,CARGA_PESO]   := aArrayCarga[nPosCarga,CARGA_PESO]   + nPesoItem
				aArrayCarga[nPosCarga,CARGA_VALOR]  := aArrayCarga[nPosCarga,CARGA_VALOR]  + nValorItem
				aArrayCarga[nPosCarga,CARGA_VOLUM]  := aArrayCarga[nPosCarga,CARGA_VOLUM]  + nVolItem
				aArrayCarga[nPosCarga,CARGA_QTDLIB] := aArrayCarga[nPosCarga,CARGA_QTDLIB] + nQtdItem
				aArrayCarga[nPosCarga,CARGA_PESCIF] := aArrayCarga[nPosCarga,CARGA_PESCIF] + nPesoCIF
				aArrayCarga[nPosCarga,CARGA_VALCIF] := aArrayCarga[nPosCarga,CARGA_VALCIF] + nValorCIF
				aArrayCarga[nPosCarga,CARGA_VOLCIF] := aArrayCarga[nPosCarga,CARGA_VOLCIF] + nVolCIF
				aArrayCarga[nPosCarga,CARGA_QTDCIF] := aArrayCarga[nPosCarga,CARGA_QTDCIF] + nQtdCIF
				aArrayCarga[nPosCarga,CARGA_PESFOB] := aArrayCarga[nPosCarga,CARGA_PESFOB] + nPesoFOB
				aArrayCarga[nPosCarga,CARGA_VALFOB] := aArrayCarga[nPosCarga,CARGA_VALFOB] + nValorFOB
				aArrayCarga[nPosCarga,CARGA_VOLFOB] := aArrayCarga[nPosCarga,CARGA_VOLFOB] + nVolFOB
				aArrayCarga[nPosCarga,CARGA_QTDFOB] := aArrayCarga[nPosCarga,CARGA_QTDFOB] + nQtdFOB

				aArrayMan[nPosMan][14] += nPesoItem
				aArrayMan[nPosMan][15] += nVolItem
				aArrayMan[nPosMan][25] += nValorItem
				aArrayMan[nPosMan][26] += nQtdItem

				//-- PE permite manipular pedidos de vendas, por exemplo, a sequencia de entrega.
				If ExistBlock("OM200MRC")
					aRetPE := ExecBlock("OM200MRC",.F.,.F.,{aArrayMan,nPosMan})
					If  ValType(aRetPE)=="A"
						aArrayMan := aRetPE
					EndIf
				EndIf

			ElseIf(TRBPED->PED_MARCA <> cMarca)
				If cAlocPer == "S"
					RecLock("TRBPED",.F.)
					TRBPED->PED_ROTA := Space(Len(DA8->DA8_COD))
					TRBPED->(MsUnlock())
				EndIf
				//-- Se nao estiver pego apenas os valores do item marcado
				nPesoItem  := TRBPED->PED_PESO
				nValorItem := TRBPED->PED_VALOR
				nVolItem   := TRBPED->PED_VOLUM
				nQtdItem   := TRBPED->PED_QTDLIB
				//-- Pesquisa se existem Pedidos marcados para a Rota / Zona / Setor
				Oms200Rot(aArrayRota,aArrayZona,aArraySetor,cRota,cZona,cSetor,cMarca)
				//-- Verifico se a montagem e por item e se esta ativo a marcacao de todos os itens do pedido automatica
				If lPedMark .Or. lAllMark
					If ((mv_par06 == 2 .or. MV_PAR06 == 3) .And. lPedMark)
						cPedido := TRBPED->PED_FILORI+TRBPED->PED_PEDIDO
					Else
						cPedido := ""
					EndIf
					TRBPED->(DbSetOrder(1)) //-- PED_FILORI+PED_PEDIDO+PED_ITEM+PED_SEQLIB+PED_CODCLI+PED_LOJA
					If TRBPED->(MsSeek(cPedido))
						Do While TRBPED->(!Eof() .And. (Empty(cPedido) .Or. PED_FILORI+PED_PEDIDO == cPedido))
							//-- Marco todos os itens se o flag estiver ativo
							If (TRBPED->PED_MARCA == cMarca)
								cRota  := TRBPED->PED_ROTA
								cZona  := TRBPED->PED_ZONA
								cSetor := TRBPED->PED_SETOR
								RecLock("TRBPED",.F.)
								TRBPED->PED_MARCA  := "  "
								TRBPED->PED_CARGA  := "ZZZZZZ"
								If  cAlocPer == "S"
									TRBPED->PED_ROTA := Space(Len(DA8->DA8_COD))
								EndIf
								TRBPED->(MsUnlock())
								nPesoItem  += TRBPED->PED_PESO
								nValorItem += TRBPED->PED_VALOR
								nVolItem   += TRBPED->PED_VOLUM
								nQtdItem   += TRBPED->PED_QTDLIB
								//-- Pesquisa se existem Pedidos marcados para a Rota / Zona / Setor
								Oms200Rot(aArrayRota,aArrayZona,aArraySetor,cRota,cZona,cSetor,cMarca)
							EndIf
							//--
							TRBPED->(DbSkip())
						EndDo
					EndIf
					lDelMan := .T.
					If lAllMark
						nPosMan := 0
					EndIf
				Else
					lDelMan := .T.
					cPedido := TRBPED->(PED_FILORI+PED_PEDIDO)
					TRBPED->(DbSetOrder(1))  //-- PED_FILORI+PED_PEDIDO+PED_ITEM+PED_SEQLIB+PED_CODCLI+PED_LOJA
					If TRBPED->(MsSeek(cPedido))
						Do While TRBPED->(!Eof() .And. PED_FILORI+PED_PEDIDO == cPedido)
							If (TRBPED->PED_MARCA == cMarca)
								lDelMan := .F.
								Exit
							EndIf
							TRBPED->(DbSkip())
						EndDo
					EndIf
				EndIf
				//-- Atualizo no array de carga os dados de volume, peso, valor e ptos de entrega
				aArrayCarga[nPosCarga,CARGA_PESO]   := aArrayCarga[nPosCarga,CARGA_PESO]   - nPesoItem
				aArrayCarga[nPosCarga,CARGA_VALOR]  := aArrayCarga[nPosCarga,CARGA_VALOR]  - nValorItem
				aArrayCarga[nPosCarga,CARGA_VOLUM]  := aArrayCarga[nPosCarga,CARGA_VOLUM]  - nVolItem
				aArrayCarga[nPosCarga,CARGA_QTDLIB] := aArrayCarga[nPosCarga,CARGA_QTDLIB] - nQtdItem
				aArrayCarga[nPosCarga,CARGA_PESCIF] := aArrayCarga[nPosCarga,CARGA_PESCIF] - nPesoCIF
				aArrayCarga[nPosCarga,CARGA_QTDCIF] := aArrayCarga[nPosCarga,CARGA_QTDCIF] - nQtdCIF
				aArrayCarga[nPosCarga,CARGA_VALCIF] := aArrayCarga[nPosCarga,CARGA_VALCIF] - nValorCIF
				aArrayCarga[nPosCarga,CARGA_VOLCIF] := aArrayCarga[nPosCarga,CARGA_VOLCIF] - nVolCIF
				aArrayCarga[nPosCarga,CARGA_PESFOB] := aArrayCarga[nPosCarga,CARGA_PESFOB] - nPesoFOB
				aArrayCarga[nPosCarga,CARGA_QTDFOB] := aArrayCarga[nPosCarga,CARGA_QTDFOB] - nQtdFOB
				aArrayCarga[nPosCarga,CARGA_VALFOB] := aArrayCarga[nPosCarga,CARGA_VALFOB] - nValorFOB
				aArrayCarga[nPosCarga,CARGA_VOLFOB] := aArrayCarga[nPosCarga,CARGA_VOLFOB] - nVolFOB

				If nPosMan > 0
					aArrayMan[nPosMan][14] -= nPesoItem
					aArrayMan[nPosMan][15] -= nVolItem
					aArrayMan[nPosMan][25] -= nValorItem
					aArrayMan[nPosMan][26] -= nQtdItem
				EndIf

				//-- PE permite manipular pedidos de vendas, por exemplo, a sequencia de entrega quando desmarca um pedido .
				If ExistBlock("OM200MRP")
					aRetPE := ExecBlock("OM200MRP",.F.,.F.,{aArrayMan,nPosMan})
					If  ValType(aRetPE)=="A"
						aArrayMan := aRetPE
					EndIf
				EndIf

				If lDelMan
					If nPosMan > 0
						aDel(aArrayMan,nPosMan)
						aSize(aArrayMan,Len(aArrayMan)-1)
					Else
						aArrayMan := {}
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		//-- Escolha da rota / Zona / Setor / Pedido de Vendas
		Do Case

			Case nEscolha == 1 //-- Rotas --//
				//-- Verifico o flag se esta habilitado ou se esta como rota inativa para deixar marcar para geracao
				aArrayRota[oRotas:nAt,2] := Iif((!aArrayRota[oRotas:nAt,2]) .And. (aArrayRota[oRotas:nAt,1]), .T., .F.)
				lMarca := aArrayRota[oRotas:nAt,2]
				cRota  := aArrayRota[oRotas:nAt,3]

				nC0 := aScan(aArrayZona,{|x|x[3] == cRota})
				For nC1 := nC0 To Len(aArrayZona)
					If (aArrayZona[nC1,3] == cRota)
						If (aArrayZona[nC1,1])
							aArrayZona[nC1,2] := lMarca
							cZona  := aArrayZona[nC1,4]
							//-- Procura primeiro setor desta rota + zona e (des)marca setores da zona --//
							nC2 := aScan(aArraySetor,{|x|x[3]+x[4] == cRota+cZona})
							For nC3 := nC2 To Len(aArraySetor)
								If (aArraySetor[nC3,3]+aArraySetor[nC3,4] == cRota+cZona)
									If  aArraySetor[nC3,1]
										aArraySetor[nC3,2] := lMarca
										AAdd(aPesqRota,{cRota, aArraySetor[nC3,4], aArraySetor[nC3,5]})
									EndIf
								EndIf
							Next nC3
						EndIf
					Else
						Exit
					EndIf
				Next nC1

			Case nEscolha == 2 //-- Zonas --//
				//--  Verifico o flag se esta habilitado ou se esta como rota inativa para deixar marcar para geracao
				aArrayZona[oZonas:nAt,2] := Iif((!aArrayZona[oZonas:nAt,2]) .And. (aArrayZona[oZonas:nAt,1]), .T., .F.)
				lMarca := aArrayZona[oZonas:nAt,2]
				cRota  := aArrayZona[oZonas:nAt,3]
				cZona  := aArrayZona[oZonas:nAt,4]
				//-- Procura e (des)marca Rota --//
				If lMarca
					If (nC1:=aScan(aArrayRota,{|x|x[3] == cRota .And. x[1] .And. !x[2]}))>0
						aArrayRota[nC1,2] := .T.
					EndIf
				Else
					If (nC1:=aScan(aArrayZona,{|x|x[3] == cRota .And. x[4] <> cZona .And. x[1] .And. x[2]}))==0
						If (nC1:=aScan(aArrayRota,{|x|x[3] == cRota .And. x[1] .And. x[2]}))>0
							aArrayRota[nC1,2] := .F.
						EndIf
					EndIf
				EndIf
				//-- Procura primeiro setor desta rota + zona e (des)marca Setores da Zona --//
				nC0 := aScan(aArraySetor,{|x|x[3]+x[4] == cRota+cZona})
				For nC1 := nC0 to Len(aArraySetor)
					If (aArraySetor[nC1,3]+aArraySetor[nC1,4] == cRota+cZona)
						If (aArraySetor[nC1,1])
							aArraySetor[nC1,2] := lMarca
							AAdd(aPesqRota,{cRota, cZona, aArraySetor[nC1,5]})
						EndIf
					EndIf
				Next nC1

			Case nEscolha == 3 //-- Setores --//
				//-- Verifico o flag se esta habilitado ou se esta como rota inativa para deixar marcar para geracao
				aArraySetor[oSetores:nAt,2] := Iif((!aArraySetor[oSetores:nAt,2]) .And. (aArraySetor[oSetores:nAt,1]), .T., .F.)
				cRota  := aArraySetor[oSetores:nAt,3]
				cZona  := aArraySetor[oSetores:nAt,4]
				cSetor := aArraySetor[oSetores:nAt,5]
				lMarca := aArraySetor[oSetores:nAt,2]
				AAdd(aPesqRota,{cRota, cZona, cSetor})
				//-- Procura e (des)marca Rota --//
				If  lMarca
					If  (nC1:=aScan(aArrayRota,{|x|x[3] == cRota .And. x[1] .And. !x[2]}))>0
						aArrayRota[nC1,2] := .T.
					EndIf
				Else
					If (nC1:=aScan(aArraySetor,{|x|x[3] == cRota .And. x[5] <> cSetor .And. x[1] .And. x[2]}))==0
						If (nC1:=aScan(aArrayRota,{|x|x[3] == cRota .And. x[1] .And. x[2]}))>0
							aArrayRota[nC1,2] := .F.
						EndIf
					EndIf
				EndIf
				//-- Procura e (des)marca Zona --//
				If  lMarca
					If  (nC1:=aScan(aArrayZona,{|x|x[3]+x[4] == cRota+cZona .And. x[1] .And. !x[2]}))>0
						aArrayZona[nC1,2] := .T.
					EndIf
				Else
					If (nC1:=aScan(aArraySetor,{|x|x[3]+x[4] == cRota+cZona .And. x[5] <> cSetor .And. x[1] .And. !x[2]}))==0
						If (nC1:=aScan(aArrayZona,{|x|x[3]+x[4] == cRota+cZona .And. x[1] .And. x[2]}))>0
							aArrayZona[nC1,2] := .F.
						EndIf
					EndIf
				EndIf
		EndCase
		//-- Se nEscolha < 4 - Selecionado Rota, Setor ou Zona.
		If  cAlocPer == "S"
			cWhile := "PED_ZONA+PED_SETOR"
			nOrder := 5
			nIndice := 7 //--PED_CODCLI+PED_LOJA
		EndIf
		For nC1 := 1 to Len(aPesqRota)
			cSeekPed := Iif(cAlocPer == "S","",aPesqRota[nC1,1])+aPesqRota[nC1,2]+aPesqRota[nC1,3]
			DbSelectArea("TRBPED")
			If !TRBPED->(MsSeek(cSeekPed))
				TRBPED->(DbSetOrder(nIndice))   //--PED_CODCLI+PED_LOJA
				aSort(aArrayCli,,,{|x,y| x[3]+x[4]+x[5] < y[3]+y[4]+y[5]})
				nPosRotAlt := aScan(aArrayCli, {|x|x[3]+x[4]+x[5]=aPesqRota[nC1,1]+aPesqRota[nC1,2]+aPesqRota[nC1,3]})
				While nPosRotAlt > 0 .And. aArrayCli[nPosRotAlt][3]+aArrayCli[nPosRotAlt][4]+aArrayCli[nPosRotAlt][5] == aPesqRota[nC1,1]+aPesqRota[nC1,2]+aPesqRota[nC1,3]
					If TRBPED->(MsSeek(aArrayCli[nPosRotAlt][1]+aArrayCli[nPosRotAlt][2]))
						While TRBPED->(!Eof()) .And. TRBPED->(PED_CODCLI+PED_LOJA) == aArrayCli[nPosRotAlt][1]+aArrayCli[nPosRotAlt][2]
							If TRBPED->(PED_ZONA+PED_SETOR) <> aPesqRota[nC1,2]+aPesqRota[nC1,3]
								RecLock("TRBPED",.F.)
								TRBPED->PED_ZONA := aPesqRota[nC1,2]
								TRBPED->PED_SETOR:= aPesqRota[nC1,3]
								MsUnlock()
							EndIf
							TRBPED->(DbSkip())
						EndDo
					EndIf
					If nPosRotAlt < Len(aArrayCli)
						nPosRotAlt++
					Else
						Exit
					EndIf
				EndDo
				TRBPED->(DbSetOrder(nOrder))
				TRBPED->(MsSeek(cSeekPed))
			EndIf

			Do While TRBPED->(!Eof() .And. &cWhile == cSeekPed)
				//-- Nao desmarcar pedido selecionados por outra Rota
				If  cAlocPer == "S" .And. !lMarca .And. TRBPED->PED_ROTA <> cRota
					TRBPED->(DbSkip())
					Loop
				EndIf
				//-- Verifico Flag do pedido
				If (TRBPED->PED_GERA == "N")

					lSomaCarga := Iif(TRBPED->PED_MARCA == cMarca,.F.,.T.)
					lAbatCarga := Iif(TRBPED->PED_MARCA <> cMarca,.F.,.T.)

					RecLock("TRBPED",.F.)
					TRBPED->PED_MARCA := Iif(lMarca, cMarca, "  ")
					TRBPED->PED_CARGA := Iif(lMarca, cCarga, "ZZZZZZ")
					If  cAlocPer == "S"
						TRBPED->PED_ROTA := Iif(lMarca, cRota, Space(Len(DA8->DA8_COD)))
					EndIf
					TRBPED->(MsUnlock())
					//-- Verifico se existe no array de sequencia e incluo ou excluo caso a opcao escolhida pelo usuario
					cBusca  := TRBPED->(PED_PEDIDO+PED_CODCLI+PED_LOJA+PED_FILORI)
					nPosMan := Ascan(aArrayMan,{|x| x[5]+x[6]+x[7]+x[12] == cBusca})
					//-- Verifico se o pedido foi marcado para inclusao no array de sequencia
					If (TRBPED->PED_MARCA == cMarca)
						nMultiplic := 1
						If  nPosMan == 0
							AAdd(aArrayMan,{TRBPED->PED_SEQROT,;
							TRBPED->PED_ROTA,;
							TRBPED->PED_ZONA,;
							TRBPED->PED_SETOR,;
							TRBPED->PED_PEDIDO,;
							TRBPED->PED_CODCLI,;
							TRBPED->PED_LOJA,;
							TRBPED->PED_NOME,;
							TRBPED->PED_BAIRRO,;
							TRBPED->PED_MUN,;
							TRBPED->PED_EST,;
							TRBPED->PED_FILORI,;
							TRBPED->PED_FILCLI,;
							TRBPED->PED_PESO,;
							TRBPED->PED_VOLUM,,,,,,,,,,;
							TRBPED->PED_VALOR,;
							TRBPED->PED_QTDLIB,;
							TRBPED->PED_ENDCLI,;
							Iif(lDaiRedesp,TRBPED->PED_REDESP,""),;
							Iif(lDaiRedesp,TRBPED->PED_REDNOM,"")})
						ElseIf lSomaCarga
							aArrayMan[nPosMan][14] += TRBPED->PED_PESO
							aArrayMan[nPosMan][15] += TRBPED->PED_VOLUM
							aArrayMan[nPosMan][26] += TRBPED->PED_QTDLIB
						EndIf

						//-- PE permite manipular pedidos de vendas, por exemplo, a sequencia de entrega.
						If lOM200MRC
							aRetPE := ExecBlock("OM200MRC",.F.,.F.,{aArrayMan,nPosMan})
							If  ValType(aRetPE)=="A"
								aArrayMan := aRetPE
							EndIf
						EndIf

					ElseIf (TRBPED->PED_MARCA <> cMarca)
						nMultiplic := -1
						If nPosMan > 0
							aDel(aArrayMan,nPosMan)
							aSize(aArrayMan,Len(aArrayMan)-1)
						EndIf
					EndIf
					//-- Atualizo no array de carga os dados de volume, peso, valor e ptos de entrega
					If (lSomaCarga .And. nMultiplic==1) .Or. (lAbatCarga .And. nMultiplic==-1)
						aArrayCarga[nPosCarga,CARGA_PESO]   := aArrayCarga[nPosCarga,CARGA_PESO]   + (nMultiplic * TRBPED->PED_PESO)
						aArrayCarga[nPosCarga,CARGA_VALOR]  := aArrayCarga[nPosCarga,CARGA_VALOR]  + (nMultiplic * TRBPED->PED_VALOR)
						aArrayCarga[nPosCarga,CARGA_VOLUM]  := aArrayCarga[nPosCarga,CARGA_VOLUM]  + (nMultiplic * TRBPED->PED_VOLUM)
						aArrayCarga[nPosCarga,CARGA_QTDLIB] := aArrayCarga[nPosCarga,CARGA_QTDLIB] + (nMultiplic * TRBPED->PED_QTDLIB)
					EndIf
				EndIf
				TRBPED->(DbSkip())
			EndDo
		Next nC1
	EndIf

	If !Empty(aVisErr)
		TmsMsgErr(aVisErr)
		aVisErr := {}
	EndIf
	//-- Calculo sequencia de entrega
	If GetNewPar("MV_SEQENT","1") == "1" //-- Sequencia + Rota + Pedido
		aArrayMan := aSort(aArrayMan,,,{|x,y| x[1]+x[2]+x[5] < y[1]+y[2]+y[5]})
	Else //-- Rota + Sequencia + Pedido
		aArrayMan := aSort(aArrayMan,,,{|x,y| x[2]+x[1]+x[5] < y[2]+y[1]+y[5]})
	EndIf
	//-- Calculo janela de entregas dos clientes da carga
	Oms200Time(cHrStart,dDtStart,aArrayMan,aArrayCarga[nPosCarga,CARGA_VEIC],12,6,7,2,3,4,14,15,16,17,18,19,20)
	//-- Calculo pontos de entrega
	For nC1 := 1 to Len(aArrayMan)
		If (Ascan(aArrayPto,{|x| x[1]+x[2]+x[3] == aArrayMan[nC1,6]+aArrayMan[nC1,7]+aArrayMan[nC1,13]}) == 0)
			AAdd(aArrayPto, {aArrayMan[nC1,6],aArrayMan[nC1,7],aArrayMan[nC1,13]})
		EndIf
	Next nC1
	aArrayCarga[nPosCarga,CARGA_PTOENT] := Int(Len(aArrayPto))
	//-- Posiciono no registro inicial do arquivo de trabalho
	RestArea( aAreaTRB )
	RestArea( aArea    )

	If !l200Auto
		oRotas:lDisablePaint        := .F.
		oZonas:lDisablePaint        := .F.
		oSetores:lDisablePaint      := .F.
		oMark:oBrowse:lDisablePaint := .F.
		oCargas:Refresh()
		oRotas:Refresh()
		oZonas:Refresh()
		oSetores:Refresh()
		oMark:oBrowse:Refresh(.T.)
	Endif
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OmsCarregaºAutor  ³ Daniel Pereira     º Data ³  29.01.2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Gera carregamento                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aArrayCarga - Array  de cargas passado por referencia      º±±
±±º          ³ aArrayRota  - Array  de rotas  passado por referencia      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OmsCarrega(oEnable,oDisable,oMarked,oNoMarked,cMarca,aArrayCarga,aArrayRota,aArrayZona,aArraySetor,aArrayMan,cHrStart,dDtStart,cGvCodOper,cGvNoProc,cGvPedComOp,aHeaderAdt,aColsAdt,cDakTransp,aArrayMod,cDAKTpOp,cDAKClFr,aCampos,aArrayTipo,oAllMark)
Local lIntWms    := IntWms()
Local lProcessa  := .T.
Local lRetPE     := .T.
Local lEndeWMS   := .F.
Local lRefresh   := .F.
Local lOms200Ok  := ExistBlock("OM200OK")
Local lOms200Fim := ExistBlock("OM200FIM")
Local lOS200PC9  := ExistBlock("OS200PC9")
Local lOM200CAR  := ExistBlock("OM200CAR")
Local lAgrUBS    := SuperGetMV("MV_AGRUBS",.F.,.F.)
Local aArrayGera := {}
Local aHoras     := {}
Local aAreaTRB   := TRBPED->(GetArea())
Local cCarga     := ""
Local cVeiculo   := ""
Local cVeiculo2  := ""
Local cVeiculo3  := ""
Local cMotorista := ""
Local cAjuda1    := ""
Local cAjuda2    := ""
Local cAjuda3    := ""
Local cEndereco  := ""
Local cEndPad    := ""
Local cAliasSC9  := Nil
Local cAliasDA3  := Nil
Local cQueryPE   := ""
Local cPedAnt    := ""
Local cAlocPer   := SuperGetMv("MV_ALOCPER",.F.,"N")
Local cCpoCapac  := IIf(SuperGetmv("MV_OMSCAPA",.F.,"1")=="1","DA3_CAPACN","DA3_CAPACM")
Local nPosRota   := 0
Local nPosZona   := 0
Local nPosSetor  := 0
Local nPosCarga  := Ascan(aArrayCarga,{|x| x[CARGA_ENABLE] == .T.})
Local nZona      := 0
Local nSetor     := 0
Local nRota      := 0
Local nPosMan    := 0
Local nRejeitados:= 0
Local cWhere     := ""
Local cOrderBy   := ""
Local cTmpTab    := "%"+__oTmpTab:GetRealName()+"%"
//-- Renumera a sequencia de entrega considerando intervalo conforme parametro: MV_OMSENTR
Local nSeqInc    := SuperGetMV("MV_OMSENTR" ,.F.,5)
Local nSequencia := 0
Local nRecSC5Ant := 0
Local lDaiRedesp := DAI->( ColumnPos( "DAI_REDESP" ) ) > 0

Default cGvCodOper  := ""
Default cGvNoProc   := ""
Default cGvPedComOp := ""
Default cDakTransp  := Criavar("A4_COD",.F.)

	If  Len( aArrayMan ) == 0
		Help(" ",1,"OMSPEDMARK") //Não existem pedidos selecionados para a visualização
		lProcessa := .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se existe carga disponivel aberta³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  lProcessa
		If  nPosCarga == 0
			Help(" ",1,"DLACGDISP") //Nao existe carga disponivel aberta
			lProcessa := .F.
		EndIf
	EndIf

	If HasTemplate("DCLEST") .And. !Empty(SuperGetMv("MV_COMBUS")) .And. Empty(cDakTransp)
		Help(" ",1,"OBRIGATORIO",,STR0267,3,1) //Campo Tranportadora Obrigatório
		lProcessa := .F.
	EndIf

	// @@@ Inicio da medição de tempo da geração da carga
	__aTempos := {}
	Aadd(__aTempos, {"Tempo Início Processo: ", Seconds()} )

	If  lProcessa
		cCarga     := aArrayCarga[nPosCarga,CARGA_COD]
		cVeiculo   := Iif(l200Auto .And. !Empty(aRotAuto[5][2]), aRotAuto[5][2], aArrayCarga[nPosCarga,CARGA_VEIC])
		cVeiculo2  := aArrayCarga[nPosCarga,CARGA_VEI2]
		cVeiculo3  := aArrayCarga[nPosCarga,CARGA_VEI3]
		cMotorista := Iif(l200Auto .And. !Empty(aRotAuto[6][2]), aRotAuto[6][2], aArrayCarga[nPosCarga,CARGA_MOTOR])
		cAjuda1    := aArrayCarga[nPosCarga,CARGA_AJUD1]
		cAjuda2    := aArrayCarga[nPosCarga,CARGA_AJUD2]
		cAjuda3    := aArrayCarga[nPosCarga,CARGA_AJUD3]

		If l200Auto
			xArrCarga := aClone(aArrayCarga)
		EndIf

		//-- Calculo janela de entregas dos clientes da carga
		Oms200Time(cHrStart,dDtStart,aArrayMan,aArrayCarga[nPosCarga,CARGA_VEIC],12,6,7,2,3,4,14,15,16,17,18,19,20)
		// @@@ Tempo calculo janela de entregas dos clientes da carga
		Aadd(__aTempos, {"Tempo Janela Entrega: ", Seconds()} )

		If !Empty(cVeiculo)
			aHoras := { aArrayMan[1][19],;
						aArrayMan[1][16],;
						aArrayMan[Len(aArrayMan)][20],;
						IntToHora(HoraToInt(aArrayMan[Len(aArrayMan)][16],2)+HoraToInt(aArrayMan[Len(aArrayMan)][17],4),2) }
			If !OmsVeiDisp(cVeiculo,aHoras[1],aHoras[2],aHoras[3],aHoras[4])
				Help(" ",1,"OMSVEIEMP") //Veículo já empenhado em outra carga ou viagem.
				lProcessa := .F.
			EndIf
			If !OmsVeiDisp(cVeiculo2,aHoras[1],aHoras[2],aHoras[3],aHoras[4])
				Help(,1,"OMSVEI2EMP",,STR0268,1,0,,,,,,{STR270,STR0271}) //Veículo já empenhado em outra carga ou viagem. // Favor selecionar outro veículo disponível // para entrega.
				lProcessa := .F.
			EndIf
			If !OmsVeiDisp(cVeiculo3,aHoras[1],aHoras[2],aHoras[3],aHoras[4])
				Help(,1,"OMSVEI3EMP",,STR0269,1,0,,,,,,{STR270,STR0271}) //Veículo já empenhado em outra carga ou viagem. // Favor selecionar outro veículo disponível // para entrega.
				lProcessa := .F.
			EndIf
		EndIf
		//-- Verifico se o total da carga esta fechado com a capacidade do caminhao se parametro considerar restricoes
		If lProcessa
			Pergunte("OMS200",.F.) //Parametro da Montagem de Cargas
			If !Empty(cVeiculo) .And. mv_par05 == 1
				cAliasDA3 := GetNextAlias()
				BeginSql Alias cAliasDA3
					SELECT DA3.R_E_C_N_O_ RECNODA3
					FROM %Table:DA3% DA3
					WHERE DA3.DA3_FILIAL = %xFilial:DA3%
					AND DA3.DA3_COD = %Exp:cVeiculo%
					AND DA3.%NotDel%
				EndSql
				If (cAliasDA3)->(!Eof())
					DA3->(dbGoTo((cAliasDA3)->RECNODA3))
					If (aArraycarga[oCargas:nAt,CARGA_PESO  ] > DA3->(FieldGet(ColumnPos(cCpoCapac)))).Or.;
						(aArrayCarga[oCargas:nAt,CARGA_VOLUM ] > DA3->DA3_VOLMAX).Or.;
						(aArrayCarga[oCargas:nAt,CARGA_PTOENT] > DA3->DA3_LIMMAX)
						Help(" ",1,"OMSULTCARG") //Caminhao nao suporta carga montada
						lProcessa := .F.
					EndIf
				EndIf
				(cAliasDA3)->(dbCloseArea())
			EndIf
		EndIf
		// @@@ Tempo de validação do veículo
		Aadd(__aTempos, {"Tempo Validação Veículo: ", Seconds()} )
	EndIf
	// Verifico o numero de rotas que existem na carga para
	// a escolha de apenas uma caso haja mais do que uma
	If  lProcessa
		If !Oms200ARota(@aArrayMan)
			lProcessa := .F.
		EndIf
		// @@@ Tempo verificação número de rotas
		Aadd(__aTempos, {"Tempo Número Rotas: ", Seconds()} )
	EndIf

	If lProcessa
		If lIntWms
			If !Oms200EPad(@aArrayMan,@cEndereco,@lEndeWMS)
				lProcessa := .F.
			EndIf
			// @@@ Tempo endereço WMS
			Aadd(__aTempos, {"Tempo Endereço WMS: ", Seconds()} )
		EndIf
	EndIf

	// Ponto de entrada antes da geracao da carga, permitindo ao usuario interferir na geracao da carga
	If  lOms200Ok .And. lProcessa
		lRetPE := ExecBlock("OM200OK",.F.,.F.,{ aArrayMan, aArrayCarga, nPosCarga})
		lProcessa := If(ValType(lRetPE)=="L", lRetPE, lProcessa)
		// @@@ Tempo PE OM200OK
		Aadd(__aTempos, {"Tempo PE OM200OK: ", Seconds()} )
	EndIf

	// Se ok confirmo geracao da carga
	If  lProcessa
		Begin Transaction
			nSeqInc := Iif(nSeqInc > 0,nSeqInc,5)

			If !lAgrUBS
			//	cWhere := " AND SC9.C9_BLEST  = '"+Space(Len(SC9->C9_BLEST)) +"'"
			EndIf
			cWhere := "%"+cWhere+"%"

			If GetNewPar("MV_SEQENT","1") == "1" //-- Sequencia + Rota + Pedido
				cOrderBy := "TMP.PED_SEQROT,TMP.PED_ROTA,TMP.PED_FILORI,TMP.PED_PEDIDO,SC9.C9_ITEM"
			Else //-- Rota + Sequencia + Pedido
				cOrderBy := "TMP.PED_ROTA,TMP.PED_SEQROT,TMP.PED_FILORI,TMP.PED_PEDIDO,SC9.C9_ITEM"
			EndIf
			cOrderBy := "%"+cOrderBy+"%"

			cAliasSC9 := GetNextAlias()
			If MV_PAR06 == 2 .Or. MV_PAR06 == 3
				BeginSql Alias cAliasSC9
				SELECT TMP.PED_SEQROT,
						 TMP.PED_ROTA,
						 TMP.PED_FILORI,
						 TMP.PED_PEDIDO,
						 TMP.PED_CODCLI,
						 TMP.PED_LOJA,
						 SC9.C9_ITEM,
						 SC9.C9_SEQUEN,
						 SC9.C9_CARGA,
						 SC9.C9_ENDPAD,
						 SC9.C9_NFISCAL,
						 SC9.R_E_C_N_O_ RECSC9,
						 SC5.R_E_C_N_O_ RECSC5
				  FROM %Exp:cTmpTab% TMP
				 INNER JOIN %Table:SC5% SC5
					 ON SC5.C5_FILIAL = TMP.PED_FILORI
					AND SC5.C5_NUM = TMP.PED_PEDIDO
					AND SC5.%NotDel%
				 INNER JOIN %Table:SC9% SC9
					 ON SC9.C9_FILIAL = TMP.PED_FILORI
					AND SC9.C9_PEDIDO = TMP.PED_PEDIDO
					AND SC9.C9_ITEM = TMP.PED_ITEM
					AND SC9.C9_SEQUEN = TMP.PED_SEQLIB
					AND SC9.%NotDel%
				 WHERE TMP.PED_MARCA = %Exp:cMarca%
					AND TMP.%NotDel%
				//	AND SC9.C9_BLCRED = '  '
					%Exp:cWhere%
				 ORDER BY %Exp:cOrderBy%
				EndSql
			Else
				BeginSql Alias cAliasSC9
				SELECT TMP.PED_SEQROT,
						 TMP.PED_ROTA,
						 TMP.PED_FILORI,
						 TMP.PED_PEDIDO,
						 TMP.PED_CODCLI,
						 TMP.PED_LOJA,
						 SC9.C9_ITEM,
						 SC9.C9_SEQUEN,
						 SC9.C9_CARGA,
						 SC9.C9_ENDPAD,
						 SC9.C9_NFISCAL,
						 SC9.R_E_C_N_O_ RECSC9,
						 SC5.R_E_C_N_O_ RECSC5
				  FROM %Exp:cTmpTab% TMP
				 INNER JOIN %Table:SC5% SC5
					 ON SC5.C5_FILIAL = TMP.PED_FILORI
					AND SC5.C5_NUM = TMP.PED_PEDIDO
					AND SC5.%NotDel%
				 INNER JOIN %Table:SC9% SC9
					 ON SC9.C9_FILIAL = TMP.PED_FILORI
					AND SC9.C9_PEDIDO = TMP.PED_PEDIDO
					AND SC9.%NotDel%
				 WHERE TMP.PED_MARCA = %Exp:cMarca%
					AND TMP.%NotDel%
				//	AND SC9.C9_BLCRED = '  '
					%Exp:cWhere%
				 ORDER BY %Exp:cOrderBy%
				EndSql
			EndIf
			// @@@ Tempo query itens da carga
			Aadd(__aTempos, {"Tempo Query Itens: ", Seconds()} )
			// Permite alterar query dos pedidos na Montagem da Carga
			If lOM200CAR
				cQueryPE := ExecBlock("OM200CAR",.F.,.F.,{ GetLastQuery()[2] , 1 })
				If !Empty(cQueryPE)
					(cAliasSC9)->(dbCloseArea())
					cQueryPE := "%"+AllTrim(cQueryPE)+"%"
					cQueryPE := StrTran(cQueryPE,"%SELECT","%")
					cAliasSC9 := GetNextAlias()
					BeginSql Alias cAliasSC9
						SELECT %Exp:cQueryPE%
					EndSql
					// @@@ Tempo PE OM200CAR
					Aadd(__aTempos, {"Tempo PE OM200CAR: ", Seconds()} )
				EndIf
			EndIf

			Do While !(cAliasSC9)->(Eof())
				// Tenta realizar lock do pedido de venda
				If !(nRecSC5Ant == (cAliasSC9)->RECSC5)
					ncRecSC5Ant := (cAliasSC9)->RECSC5
					SC5->(DbGoTo((cAliasSC9)->RECSC5))
					If !SoftLock("SC5")
						nRejeitados += 1
						(cAliasSC9)->(dbSkip())
						Loop
					EndIf
				EndIf
				// Verifica se não possui carga gerada
				If !Empty((cAliasSC9)->C9_CARGA)
					// Se for executado via rotina automática e já tiver sido faturado,
					// deve desconsiderar o registro sem contar como rejeitado
					//If Empty((cAliasSC9)->C9_NFISCAL) .And. !l200Auto    //Daniel em 18/01/2021
						If !Empty((cAliasSC9)->C9_NFISCAL) .And. !l200Auto
						nRejeitados += 1
					EndIf
					(cAliasSC9)->(dbSkip())
					Loop
				EndIf
				// Ponto de entrada para validar itens do Pedido de Venda
				If lOS200PC9
					lRetPE := ExecBlock("OS200PC9",.F.,.F.,{cAliasSC9})
					If ValType(lRetPE) == "L" .And. !lRetPE
						(cAliasSC9)->(DbSkip())
						Loop
					EndIf
				EndIf

				// Usa endereco padrao do pedido se sem endereco retornado (Oms200EPad)
				If lIntWms .And. Empty(cEndereco)
					cEndPad := (cAliasSC9)->C9_ENDPAD
				Else
					cEndPad := cEndereco
				EndIf

				If !(cPedAnt == (cAliasSC9)->(PED_PEDIDO+PED_CODCLI+PED_LOJA+PED_FILORI))
					cPedAnt := (cAliasSC9)->(PED_PEDIDO+PED_CODCLI+PED_LOJA+PED_FILORI)
					nPosMan := Ascan(aArrayMan,{|x| x[5]+x[6]+x[7]+x[12] == (cAliasSC9)->(PED_PEDIDO+PED_CODCLI+PED_LOJA+PED_FILORI)})
					nSequencia += nSeqInc
				EndIf

				If nPosMan > 0
					AAdd(aArrayGera, {  StrZero(nSequencia,6),;//  1- Sequencia
										aArrayMan[nPosMan,2],;     //  2- Rota
										aArrayMan[nPosMan,3],;     //  3- Zona
										aArrayMan[nPosMan,4],;     //  4- Setor
										(cAliasSC9)->PED_PEDIDO,;  //  5- Pedido
										(cAliasSC9)->C9_ITEM,;     //  6- Item
										(cAliasSC9)->PED_CODCLI,;  //  7- Cliente
										(cAliasSC9)->PED_LOJA,;    //  8- Loja
										(cAliasSC9)->RECSC9,;      //  9- Reg. SC9
										cEndPad,;                  // 10- Endereco padrao
										(cAliasSC9)->PED_FILORI,;  // 11- Filial Pedido
										aArrayMan[nPosMan,13],;    // 12- Filial Cliente
										aArrayMan[nPosMan,16],;    // 13- Hora chegada
										aArrayMan[nPosMan,17],;    // 14- Time Service
										aArrayMan[nPosMan,19],;    // 15- Data chegada
										aArrayMan[nPosMan,20],;    // 16- Data saida
										aArrayMan[nPosMan,23],;    // 17- Valor do Frete
										aArrayMan[nPosMan,24],;    // 18- Frete Autonom
										Iif(lDaiRedesp,aArrayMan[nPosMan,28],"") })   // 19- Redespachante
				EndIf
				(cAliasSC9)->(dbSkip())
			EndDo
			(cAliasSC9)->(dbCloseArea())
			// @@@ Tempo validação dos items SC9
			Aadd(__aTempos, {"Tempo Validação Itens: ", Seconds()} )

			If Len(aArrayGera) == 0
				OmsHelp(STR0277)  //Não foi possível gerar a carga. Todos os pedidos selecionados encontram-se reservados por outros processos.
				lProcessa := .F.
				lRefresh  := .T.
			ElseIf QtdComp(nRejeitados) > 0
			 	If l200Auto
					OmsHelp(STR0278) //Existem pedidos selecionados que encontram-se reservados por outros processos e não serão incluídos na carga.
					lRefresh  := .T.
					lProcessa := .F.
				Else
					If !MsgYesNo(STR0278+CRLF+STR0279) //Existem pedidos selecionados que encontram-se reservados por outros processos e não serão incluídos na carga. // Confirma a geração da carga?
						lRefresh  := .T.
						lProcessa := .F.
					EndIf
				EndIf
			EndIf

			If lProcessa .And. Len(aArrayGera) > 0
				//-- Gerar a carga baseado no array
				If IsBlind()
					U_xOms200Car(@aArrayGera,@cCarga,Nil,cVeiculo,cMotorista,cAjuda1,cAjuda2,cAjuda3,cHrStart,dDtStart,,cGvCodOper,cGvNoProc,cGvPedComOp,aHeaderAdt,aColsAdt,cDakTransp,lEndeWMS,cVeiculo2,cVeiculo3,cDAKTpOp,cDAKClFr)
				Else
					Processa({||U_xOms200Car(@aArrayGera,@cCarga,Nil,cVeiculo,cMotorista,cAjuda1,cAjuda2,cAjuda3,cHrStart,dDtStart,,cGvCodOper,cGvNoProc,cGvPedComOp,aHeaderAdt,aColsAdt,cDakTransp,lEndeWMS,cVeiculo2,cVeiculo3,cDAKTpOp,cDAKClFr)})
				EndIf
				If lProcessa
					lProcessa := OMSA200IPG(3,cVeiculo,cMotorista,.F.,cCarga,Nil,aArrayMan[1][5],cDakTransp,cDAKTpOp,cDAKClFr,cVeiculo2,cVeiculo3)
					// @@@ Tempo validação da integração com o GFE
					Aadd(__aTempos, {"Tempo Validação Integração GFE: ", Seconds()} )
				EndIf

				If lProcessa
					//-- Integração Protheus x GFE (INCLUSAO)
					lProcessa := OMSA200IPG(3,,,.T.,,,,cDakTransp,cDAKTpOp,cDAKClFr)
					// @@@ Tempo geração da integração com o GFE
					Aadd(__aTempos, {"Tempo Geração Integração GFE", Seconds()} )
				EndIf
				// Defaz a transação na ocorrência
				If !lProcessa
					DisarmTransaction()
				EndIf
			EndIf

			If lProcessa
				//-- Atualiza flags de geracao na markbrowse
				aArrayCarga[nPosCarga,CARGA_ENABLE] := .F.
				aArrayCarga[nPosCarga,CARGA_COD]    := cCarga
				aArrayCarga[nPosCarga,CARGA_DESC]   := OemtoAnsi(STR0040)+cCarga

				For nRota := 1 to Len(aArrayRota)
					If (aArrayRota[nRota,2])
						aArrayRota[nRota,5] := cCarga
					EndIf
					aArrayRota[nRota,1] := .F.
					aArrayRota[nRota,2] := .F.
				Next nRota

				For nZona := 1 to Len(aArrayZona)
					If (aArrayZona[nZona,2])
						aArrayZona[nZona,6] := cCarga
					EndIf
					aArrayZona[nZona,1] := .F.
					aArrayZona[nZona,2] := .F.
				Next nZona

				For nSetor := 1 to Len(aArraySetor)
					If (aArraySetor[nSetor,2])
						aArraySetor[nSetor,7] := cCarga
					EndIf
					aArraySetor[nSetor,1] := .F.
					aArraySetor[nSetor,2] := .F.
				Next nSetor

				DbSelectArea("TRBPED")
				DbGoTop()
				Do While !Eof()
					//-- Desmarca pedidos selecionados para a carga
					If (TRBPED->PED_MARCA == cMarca)
						TRBPED->PED_GERA  := "S"
						TRBPED->PED_MARCA := "  "
						TRBPED->PED_CARGA := cCarga
					EndIf
					DbSkip()
				EndDo

				//-- Verifico o array de pedidos para ver se sobraram alguns pedidos das rotas para nao desbilitar
				DbSelectArea("TRBPED")
				DbGoTop()
				Do While !Eof()
					If TRBPED->PED_GERA == "N"
						If cAlocPer == "S"
							//-- Podem existir mais de uma Rota para um mesmo Setor e/ou Zona
							Do While (nPosSetor := Ascan(aArraySetor,{|x| x[4]+x[5] == TRBPED->PED_ZONA+TRBPED->PED_SETOR .And. x[1] == .F.}))>0
								aArraySetor[nPosSetor,1] := .T.
								If (nPosZona := Ascan(aArrayZona,{|x| x[3]+x[4] == aArraySetor[nPosSetor,3]+aArraySetor[nPosSetor,4] .And. x[1] == .F.}))>0
									aArrayZona[nPosZona,1] := .T.
									If (nPosRota := Ascan(aArrayRota,{|x| x[3] == aArraySetor[nPosSetor,3] .And. x[1] == .F.}))>0
										aArrayRota[nPosRota,1] := .T.
									EndIf
								EndIf
							EndDo
						Else
							If (nPosSetor := Ascan(aArraySetor,{|x| x[3]+x[4]+x[5] == TRBPED->PED_ROTA+TRBPED->PED_ZONA+TRBPED->PED_SETOR .And. x[1] == .F.}))>0
								aArraySetor[nPosSetor,1] := .T.
								If (nPosZona := Ascan(aArrayZona,{|x| x[3]+x[4] == TRBPED->PED_ROTA+TRBPED->PED_ZONA .And. x[1] == .F.}))>0
									aArrayZona[nPosZona,1] := .T.
									If (nPosRota := Ascan(aArrayRota,{|x| x[3] == TRBPED->PED_ROTA .And. x[1] == .F.}))>0
										aArrayRota[nPosRota,1] := .T.
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					dbSkip()
				EndDo

				// @@@ Tempo ajustes da tela
				Aadd(__aTempos, {"Tempo Ajustes Tela: ", Seconds()} )
			EndIf

		End Transaction

		If lProcessa .And. lIntWms
			WmsAvalExe()
			// @@@ Tempo integração WMS
			Aadd(__aTempos, {"Tempo Integração WMS:", Seconds()} )
		EndIf
		// Zero o array de sequencia na carga
		If lProcessa
			aArrayMan := {}
		EndIf
		RestArea( aAreaTRB )
		If !l200Auto
			oCargas:Refresh()
			oRotas:Refresh()
			oZonas:Refresh()
			oSetores:Refresh()
			oMark:oBrowse:Refresh()
		EndIf
		If lProcessa
			// Ponto de entrada no final do carregamento
			If lOms200Fim
				ExecBlock("OM200FIM",.F.,.F.)
			EndIf
		EndIf
		If !l200Auto .And. !lProcessa .And. lRefresh
			OsA200Refr(aCampos,aArrayCarga,aArrayRota,aArrayZona,aArraySetor,aArrayMod,aArrayTipo,{oCargas,oRotas,oZonas,oSetores},aArrayMan,{oAllMark},@cDakTransp,.F.)
			// @@@ Tempo refresh da tela
			Aadd(__aTempos, {"Tempo Refresh Tela: ", Seconds()} )
			EndIf
	EndIf

	LogTempos(cCarga)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XOms200CarºAutor  ³Daniel Pereira       º Data ³ 29.01.2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de geracao de carga                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aArrayMan - Array contendo os pedidos que deve ser gerados º±±
±±º          ³             ja na sequencia de entrega                     º±±
±±º          ³             [1] - Sequencia                                º±±
±±º          ³             [2] - Rota                                     º±±
±±º          ³             [3] - Zona                                     º±±
±±º          ³             [4] - Setor                                    º±±
±±º          ³             [5] - Pedido                                   º±±
±±º          ³             [6] - Cliente                                  º±±
±±º          ³             [7] - Loja                                     º±±
±±º          ³ cCarga    - Numero da carga a ser gerada                   º±±
±±º          ³ cSeqCarga - Sequencia da carga                             º±±
±±º          ³ cVeiculo - Caminhao a ser gerado a carga                   º±±
±±º          ³ cMotorista- Motorista do veiculo                           º±±
±±º          ³ cAjuda1   - Ajudante 1                                     º±±
±±º          ³ cAjuda2   - Ajudante 2                                     º±±
±±º          ³ cAjuda3   - Ajudante 3                                     º±±
±±º          ³ cHrStart  - Hora de inicio de entrega                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function xOms200Car(aArrayGera,cCarga,cSeqCar,cVeiculo,cMotorista,cAjuda1,cAjuda2,cAjuda3,cHrStart,dDtStart,aCargaAnt,cGvCodOper,cGvNoProc,cGvPedComOp,aHeaderAdt,aColsAdt,cDakTransp,lEndeWMS,cVeiculo2,cVeiculo3,cDAKTpOp,cDAKClFr)
Local lIntGFE    := SuperGetMv("MV_INTGFE",,.F.)
Local lDakTransp := DAK->( ColumnPos("DAK_TRANSP") ) > 0
Local lDakVeic2  := DAK->( ColumnPos("DAK_VEIC2" ) ) > 0
Local lDakTpOp   := DAK->( ColumnPos("DAK_CDTPOP") ) > 0 .AND. DAK->( ColumnPos("DAK_CDCLFR") ) > 0
Local lDaiFilPv  := DAI->( ColumnPos("DAI_FILPV" ) ) > 0
Local lOs200DAK  := ExistBlock("OS200DAK")
Local lAlocVei   := SuperGetMv("MV_ALOCVEI",.F.,.T.)
Local OS200Ger   := ExistBlock("OS200GER")
Local aFieldValue:= {}
Local aStruModel := {}
Local cTransp    := ""
Local cPedAnt    := ""
Local cAliasDAK  := ""
Local cCdTpOp    := SuperGetMv("MV_CDTPOP",.F.,"")
Local cCdClFr    := SuperGetMv("MV_CDCLFR",.F.,"")
Local cAliasDAI  := Nil
Local cAliasSC5  := Nil
Local cAliasSC6  := Nil
Local nSequencia := 0
Local lNAchouSeq  := .T.
Local lDaiRedesp  := DAI->( ColumnPos( "DAI_REDESP" ) ) > 0

Private cCgcTransp := ""

//--
Default cMotorista  := Criavar( "DA4_COD" ,.F. )
Default cAjuda1     := Criavar( "DAU_COD" ,.F. )
Default cAjuda2     := Criavar( "DAU_COD" ,.F. )
Default cAjuda3     := Criavar( "DAU_COD" ,.F. )
Default cSeqCar     := "01"
Default cHrStart    := "00:00"
Default dDtStart    := dDatabase
Default aCargaAnt   := {}
Default cGvCodOper  := ""
Default cGvNoProc   := ""
Default cGvPedComOp := ""
Default aHeaderAdt  := {}
Default aColsAdt    := {}
Default cDakTransp  := Criavar("A4_COD",.F.)
Default lEndeWMS    := .F.
Default cVeiculo2  := ""
Default cVeiculo3  := ""
Default cDAKTpOp   := ""
Default cDAKClFr   := ""

	Pergunte("OMS200C",.F.)

	aVisErr := {}

	Do While lNAchouSeq //Enquanto não e encontrar uma sequência de carga disponível, pesquisa novamente.
		cCarga := GetSX8Num("DAK","DAK_COD") //Pega próxima sequência DAK
		If ( __lSX8 )
			ConfirmSX8()
		EndIf
		cAliasDAK := GetNextAlias()
		BeginSql Alias cAliasDAK
			SELECT DAK.DAK_COD
			  FROM %Table:DAK% DAK
			 WHERE DAK.DAK_FILIAL = %xFilial:DAK%
			   AND DAK.DAK_COD = %Exp:cCarga%
			   AND DAK.%NotDel%
		EndSql
		If (cAliasDAK)->(EoF())
			lNAchouSeq := .F.
		EndIf
		(cAliasDAK)->(DbCloseArea())
	EndDo

	ProcRegua(Len(aArrayGera))

	// @@@ Tempo Captura Código da Carga
	Aadd(__aTempos, {"Tempo Captura Código da Carga:", Seconds()} )

	// Gera o Arquivo DAK.
	RecLock("DAK",.T.)
	DAK->DAK_FILIAL := xFilial("DAK")
	DAK->DAK_COD    := cCarga
	DAK->DAK_SEQCAR := cSeqCar
	DAK->DAK_ROTEIR := If(Len(aArrayGera)>0,aArrayGera[Len(aArrayGera),2],"")
	DAK->DAK_CAMINH := cVeiculo
	If lDakVeic2
		DAK->DAK_VEIC2  := cVeiculo2
		DAK->DAK_VEIC3  := cVeiculo3
	EndIf
	DAK->DAK_MOTORI := cMotorista
	DAK->DAK_AJUDA1 := cAjuda1
	DAK->DAK_AJUDA2 := cAjuda2
	DAK->DAK_AJUDA3 := cAjuda3
	DAK->DAK_DATA   := dDtStart
	DAK->DAK_HORA   := Time()
	DAK->DAK_PESO   := 0
	DAK->DAK_CAPVOL := 0
	DAK->DAK_PTOENT := 0
	DAK->DAK_VALOR  := 0
	DAK->DAK_JUNTOU := "MANUAL"
	DAK->DAK_FLGUNI := "2"
	DAK->DAK_FEZNF  := "1"
	DAK->DAK_ACECAR := "2"
	DAK->DAK_ACEFIN := "2"
	DAK->DAK_ACEVAS := "2"
	DAK->DAK_HRSTAR := cHrStart
	If lDakTransp
		DAK->DAK_TRANSP := cDakTransp
	EndIf
	If lDakTpOp
		If !Empty(cDAKTpOp)
			DAK->DAK_CDTPOP := cDAKTpOp
		Else
			DAK->DAK_CDTPOP := cCdTpOp
		EndIf
		If !Empty(cDAKClFr)
			DAK->DAK_CDCLFR := cDAKClFr
		Else
			DAK->DAK_CDCLFR := cCdClFr
		EndIF
	EndIf
	DAK->(MsUnlock())
	DAK->(FkCommit())

	// @@@ Tempo Gravação DAK
	Aadd(__aTempos, {"Tempo Gravação DAK:", Seconds()} )


	//-- PE apos a geracao da carga
	If lOs200DAK
		ExecBlock("OS200DAK",.F.,.F.)

		// @@@ Tempo PE OS200DAK
		Aadd(__aTempos, {"Tempo PE OS200DAK:", Seconds()} )
	EndIf

	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// ³ Gera o Arquivo DAI e atualizo os acumuladores do DAK        ³
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nSequencia := 1 to Len(aArrayGera)
		IncProc()
		//Tratamento pois existe a possibilidade de nao existir o SC9
		If aArrayGera[nSequencia,9] > 0
			SC9->(DbGoTo(aArrayGera[nSequencia,9]))
			If SC9->(!Eof())
				Reclock("SC9",.F.)
				SC9->C9_CARGA   := cCarga
				SC9->C9_SEQCAR  := cSeqCar
				SC9->C9_SEQENT  := aArrayGera[nSequencia,1]
				If SC9->C9_STSERV != '3'
					SC9->C9_ENDPAD  := aArrayGera[nSequencia,10]
				EndIf
				SC9->(MsUnlock())
			EndIf
		EndIf

		If !(cPedAnt == aArrayGera[nSequencia,5]) .And. ((mv_par01 == 1) .Or. (lDakTransp .And. !Empty(cDakTransp)))
			cPedAnt := aArrayGera[nSequencia,5]
			cAliasSC5 := GetNextAlias()
			BeginSql Alias cAliasSC5
				SELECT SC5.R_E_C_N_O_ RECNOSC5
				  FROM %Table:SC5% SC5
				 WHERE SC5.C5_FILIAL = %xFilial:SC5%
					AND SC5.C5_NUM = %Exp:aArrayGera[nSequencia,5]%
					AND SC5.%NotDel%
			EndSql
			If (cAliasSC5)->(!Eof())
				SC5->(dbGoTo((cAliasSC5)->RECNOSC5))
				If (lDakTransp .And. !Empty(cDakTransp)) .Or. !Empty(cVeiculo)
					RecLock('SC5',.F.)
					If !Empty(cVeiculo)
						SC5->C5_VEICULO := cVeiculo
					EndIf
					If (lDakTransp .And. !Empty(cDakTransp))
						SC5->C5_TRANSP := cDakTransp
					EndIf
					SC5->(MsUnlock())
				EndIf
				If Empty(cVeiculo)
					cVeiculo := SC5->C5_VEICULO
				EndIf
			EndIf
			(cAliasSC5)->(dbCloseArea())
		EndIf
		//------------------------------------------------------------------------------
		// Verifica-se a existencia do item da carga, senão grava o item da carga
		//------------------------------------------------------------------------------
		cAliasDAI := GetNextAlias()
		BeginSql Alias cAliasDAI
			SELECT 1
			  FROM %Table:DAI% DAI
			 WHERE DAI.DAI_FILIAL = %xFilial:DAI%
				AND DAI.DAI_COD = %Exp:DAK->DAK_COD%
				AND DAI.DAI_SEQCAR = %Exp:DAK->DAK_SEQCAR%
				AND DAI.DAI_SEQUEN = %Exp:aArrayGera[nSequencia,1]%
				AND DAI.DAI_PEDIDO = %Exp:aArrayGera[nSequencia,5]%
				AND DAI.%NotDel%
		EndSql
		If (cAliasDAI)->(Eof())
			RecLock("DAI",.T.)
			DAI->DAI_FILIAL  := xFilial("DAI")
			DAI->DAI_COD     := DAK->DAK_COD
			DAI->DAI_SEQCAR  := DAK->DAK_SEQCAR
			DAI->DAI_SEQUEN  := aArrayGera[nSequencia,1]
			DAI->DAI_PEDIDO  := aArrayGera[nSequencia,5]
			If lDaiFilPv
				DAI->DAI_FILPV := aArrayGera[nSequencia,11]
			EndIf
			DAI->DAI_CLIENT  := aArrayGera[nSequencia,7]
			DAI->DAI_LOJA    := aArrayGera[nSequencia,8]
			DAI->DAI_ROTEIR  := aArrayGera[nSequencia,2]
			DAI->DAI_PERCUR  := aArrayGera[nSequencia,3]
			DAI->DAI_ROTA    := aArrayGera[nSequencia,4]
			DAI->DAI_SEQROT  := Space(Len(DAI->DAI_SEQROT))
			DAI->DAI_DATA    := dDataBase
			DAI->DAI_HORA    := Time()
			DAI->DAI_CARORI  := "CARGA"
			DAI->DAI_PESO   := 0
			DAI->DAI_CAPVOL := 0
			DAI->DAI_CHEGAD := aArrayGera[nSequencia,13]
			DAI->DAI_TMSERV := aArrayGera[nSequencia,14]
			DAI->DAI_DTCHEG := aArrayGera[nSequencia,15]
			DAI->DAI_DTSAID := aArrayGera[nSequencia,16]
			DAI->DAI_NFISCA := Posicione("SC5",1,xFilial("SC5")+aArrayGera[nSequencia,5],'C5_NOTA' )   //dANIEL 20/01/2021
			DAI->DAI_SERIE  := Posicione("SC5",1,xFilial("SC5")+aArrayGera[nSequencia,5],'C5_SERIE' )  //dANIEL 20/01/2021
			DAI->DAI_SDOC   := Posicione("SC5",1,xFilial("SC5")+aArrayGera[nSequencia,5],'C5_SERIE' )  //dANIEL 20/01/2021
			If lDaiRedesp
				DAI->DAI_REDESP := aArrayGera[nSequencia,19]
			EndIF
			DAI->(Msunlock())
		EndIf
		(cAliasDAI)->(dbCloseArea())
  
        //Gera Documento de carga  pedido x Nota Fiscal   -> Daniel em 20/01/2021
 		 //  aArrayGera[nSequencia,5] =  NUMERO DO PEDIDO 
        U_CRIADOCC(aArrayGera[nSequencia,5],cCarga,cSeqCar) 
		//------------------------------------------------------------------------------
		// Grava peso e volume na DAI
		//------------------------------------------------------------------------------
		OsAvalDAI("DAI",6)

		//----------------------------------------------------------------------------------------------------------
		// Posicionamento no item do pedido de venda para buscar a TES informada e consistir atualização de estoque
		//----------------------------------------------------------------------------------------------------------
		If aArrayGera[nSequencia,9] > 0 .And. SC9->(!Eof()) .And. IntWms(SC9->C9_PRODUTO) .And. !Empty(SC9->C9_SERVIC)
			cAliasSC6 := GetNextAlias()
			BeginSql Alias cAliasSC6
				SELECT SC5.C5_GERAWMS,
						SF4.F4_ESTOQUE
				  FROM %Table:SC6% SC6
				 INNER JOIN %Table:SF4% SF4
				    ON SF4.F4_FILIAL = %xFilial:SF4%
				   AND SF4.F4_CODIGO = SC6.C6_TES
				   AND SF4.%NotDel%
				 INNER JOIN %Table:SC5% SC5
				    ON SC5.C5_FILIAL = %xFilial:SC5%
				   AND SC5.C5_NUM = SC6.C6_NUM
				   AND SC5.%NotDel%
				 WHERE SC6.C6_FILIAL = %xFilial:SC6%
				   AND SC6.C6_NUM = %Exp:SC9->C9_PEDIDO%
				   AND SC6.C6_ITEM = %Exp:SC9->C9_ITEM%
				   AND SC6.C6_PRODUTO = %Exp:SC9->C9_PRODUTO%
				   AND SC6.%NotDel%
			EndSql
			If (cAliasSC6)->(!Eof())
				// Gera o Servico de WMS na montagem da Carga
				If (cAliasSC6)->F4_ESTOQUE=="S"
					// 1=no Pedido;2=na Montagem da Carga;3=na Unitizacao da Carga
					If (cAliasSC6)->C5_GERAWMS == '2'
						WmsIntPed(SC9->(Recno()))
					ElseIf (cAliasSC6)->C5_GERAWMS == '1' .And. lEndeWMS
						WmsEndDCF(SC9->C9_ENDPAD,.F.)
					EndIf
				EndIf
			EndIf
			(cAliasSC6)->(dbCloseArea())
		EndIf
	Next nSequencia

	// @@@ Tempo Atualização Peso e Volume
	Aadd(__aTempos, {"Tempo Geração DAI e Atualização SC9 / SC5:", Seconds()} )

	//Grava peso, volume, valor e quantidade de pontos de entrega da carga
	OsGravaDAK()

	// @@@ Tempo Geração DAK
	Aadd(__aTempos, {"Tempo Geração DAK:", Seconds()} )

	// Reserva o veiculo
	If  lAlocVei
		If !Empty(cVeiculo)
			OsVAgenda(cCarga,cSeqCar,cVeiculo,1)
		EndIf
		If lDakVeic2
			If !Empty(cVeiculo2)
				OsVAgenda(cCarga,cSeqCar,cVeiculo2,1)
			EndIf
			If !Empty(cVeiculo3)
				OsVAgenda(cCarga,cSeqCar,cVeiculo3,1)
			EndIf
		EndIf

		// @@@ Tempo Reserva Veículo
		Aadd(__aTempos, {"Tempo Reserva Veículo:", Seconds()} )
	EndIf
	//-- PE aCpos a geracao da carga e itens de carga
	If OS200Ger
		ExecBlock("OS200GER",.F.,.F.)

		// @@@ Tempo PE OS200GER
		Aadd(__aTempos, {"Tempo PE OS200GER", Seconds()} )
	EndIf
	If lIntGFE .And. FindFunction("MaEnvEAI")
		cTransp     := Posicione('SC5',1,xFilial('SC5')+Posicione("DAI",1,xFilial("DAI")+cCarga+cSeqCar,"DAI_PEDIDO"),'C5_TRANSP')
		cCgcTransp  := Posicione('SA4',1,xFilial('SA4')+cTransp,'A4_CGC')

		If !Empty(cTransp)
			aFieldValue := { { "DAK_CDTPOP", { || SuperGetMv("MV_CDTPOP",.F.,"")} },;
							 { "DAK_CGCTRA", { || cCGCTransp                    } } }

			Aadd(aStruModel, { "DAK", "OMSA200_DAK", NIL, NIL, NIL, aFieldValue } )
			MaEnvEAI(,,3,"OMSA200",aStruModel)
		EndIf

		// @@@ Tempo Integração EAI com GFE
		Aadd(__aTempos, {"Tempo Integração EAI com GFE:", Seconds()} )
	ElseIf FindFunction("MaEnvEAI")
		Aadd(aStruModel, { "DAK", "OMSA200_DAK", NIL, NIL, NIL, aFieldValue } )
		MaEnvEAI(,,3,"OMSA200",aStruModel)

		// @@@ Tempo Integração EAI
		Aadd(__aTempos, {"Tempo Integração EAI:", Seconds()} )
	EndIf
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OmsAbreCargaºAutor  ³Daniel Pereira de   º Data ³ 29.01.2021º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Abre Carga Disponivel                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aArrayCarga - Array  de cargas passado por referencia      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OmsAbreCarga(oEnable, oDisable, aArrayCarga , aHeaderAdt, aColsAdt, cDakTransp,aArrayRota,aArrayZona,aArraySetor)
Local lOpen     := .T.
Local lDakTpOp  := DAK->( ColumnPos( "DAK_CDTPOP" ) ) > 0 .AND. DAK->( ColumnPos( "DAK_CDCLFR" ) ) > 0
Local bLineSav  := oCargas:bLine
Local bLinSRot  := oRotas:bLine
Local bLinSZon  := oZonas:bLine
Local bLinSSet  := oSetores:bLine
Local cCarga    := ""
Local _x        := 0
Local nC        := 0

DEFAULT aHeaderAdt  := {}
DEFAULT aColsAdt    := {}
DEFAULT cDakTransp  := Criavar("A4_COD",.F.)
DEFAULT aArrayCarga := {}
DEFAULT aArrayRota  := {}
DEFAULT aArrayZona  := {}
DEFAULT aArraySetor := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se existem cargas abertas para geracao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nC := 1 to Len(aArrayCarga)
		If aArrayCarga[nC,CARGA_ENABLE]
			Help(" ",1,"OMSCGABERT") //Ja existem cargas abertas para geracao
			lOpen := .F.
		EndIf
	Next nC

	If lOpen
		//-- Limpa o conteudo do Array de adiantamento.
		aHeaderAdt  := {}
		aColsAdt    := {}

		cCarga   := STR0285 //A DEFINIR

		cDakTransp := Criavar("A4_COD",.F.)

		If Len(aArrayCarga) >= 1 .And. !Empty(aArrayCarga[1,CARGA_COD])
			AAdd(aArrayCarga,{.T.,;
								cCarga,;
								OemtoAnsi(STR0040)+cCarga,; //"CARGA"
								0,;
								0,;
								0,;
								0,;
								0,;
								Space(7),;
								Space(Len(DA3->DA3_COD)),;
								Space(Len(DA3->DA3_COD)),;
								Space(Len(DA3->DA3_COD)),;
								Space(Len(DA4->DA4_COD)),;
								Space(Len(DAU->DAU_COD)),;
								Space(Len(DAU->DAU_COD)),;
								Space(Len(DAU->DAU_COD)),;
								0,;
								0,;
								0,;
								0,;
								0,;
								0,;
								0,;
								0,;
								Space(10),;
								Space(4),;
							})
			//-- Ponto de entrada para adicionar campos na opcao Sequencia de Entrega.
			If  ExistBlock("OM200AD2")
				aRetCarga := ExecBlock("OM200AD2",.F.,.F.,{oCargas, aArrayCarga, oCargas:aHeaders, oCargas:bLine, oEnable, oDisable})
				If  ValType(aRetCarga[1]) == "A" .And. ValType(aRetCarga[2]) == "A" .And. ValType(aRetCarga[3]) == "B"
					aArrayCarga := aRetCarga[1]
					bLineSav    := aRetCarga[3]
				EndIf
			EndIf
			For _x := 1 To Len(aArrayRota)
				aArrayRota[_x,5] := cCarga
			Next
			For _x := 1 To Len(aArrayZona)
				aArrayZona[_x,6] := cCarga
			Next

			For _x := 1 To Len(aArraySetor)
				aArraySetor[_x,7] := cCarga
			Next
		Else
			aArrayCarga[1,CARGA_ENABLE] := .T.
			aArrayCarga[1,CARGA_COD]    := cCarga
			aArrayCarga[1,CARGA_DESC]   := OemtoAnsi(STR0040) + cCarga //"CARGA "
			aArrayCarga[1,CARGA_PESO]   := 0
			aArrayCarga[1,CARGA_VALOR]  := 0
			aArrayCarga[1,CARGA_VOLUM]  := 0
			aArrayCarga[1,CARGA_QTDLIB] := 0
			aArrayCarga[1,CARGA_PTOENT] := 0
			aArrayCarga[1,CARGA_TRANSP] := Space(7)
			aArrayCarga[1,CARGA_VEIC]   := Space(Len(DA3->DA3_COD))
			aArrayCarga[1,CARGA_VEI2]   := Space(Len(DA3->DA3_COD))
			aArrayCarga[1,CARGA_VEI3]   := Space(Len(DA3->DA3_COD))
			aArrayCarga[1,CARGA_MOTOR]  := Space(Len(DA4->DA4_COD))
			aArrayCarga[1,CARGA_AJUD1]  := Space(Len(DAU->DAU_COD))
			aArrayCarga[1,CARGA_AJUD2]  := Space(Len(DAU->DAU_COD))
			aArrayCarga[1,CARGA_AJUD3]  := Space(Len(DAU->DAU_COD))
			aArrayCarga[1,CARGA_PESCIF] := 0
			aArrayCarga[1,CARGA_QTDCIF] := 0
			aArrayCarga[1,CARGA_VOLCIF] := 0
			aArrayCarga[1,CARGA_VALCIF] := 0
			aArrayCarga[1,CARGA_PESFOB] := 0
			aArrayCarga[1,CARGA_QTDFOB] := 0
			aArrayCarga[1,CARGA_VOLFOB] := 0
			aArrayCarga[1,CARGA_VALFOB] := 0
			If lDakTpOp
				aArrayCarga[1,CARGA_TPOP] := Space(Len(DAK->DAK_CDTPOP))
				aArrayCarga[1,CARGA_CLFR] := Space(Len(DAK->DAK_CDCLFR))
			Else
				aArrayCarga[1,CARGA_TPOP] := ""
				aArrayCarga[1,CARGA_CLFR] := ""
			EndIf
		EndIf
	EndIf
	If !l200Auto
		oCargas:SetArray(aArrayCarga)
		oCargas:bLine := bLineSav
		oCargas:nAt   := Len(aArrayCarga)
		oCargas:Refresh()
		oRotas:SetArray(aArrayRota)
		oRotas:bLine := bLinSRot
		oRotas:nAt   := 1
		oRotas:Refresh()
		oZonas:SetArray(aArrayZona)
		oZonas:bLine := bLinSZon
		oZonas:nAt   := 1
		oZonas:Refresh()


		oSetores:SetArray(aArraySetor)
		oSetores:bLine := bLinSSet
		oSetores:nAt   := 1
		oSetores:Refresh()
	Endif
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OmsFilTipoºAutor  ³Daniel pereira      º Data ³  29.01.2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mastra janela inicial da montagem de carga para filtrar os  º±±
±±º          ³tipos de carga.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OmsFilTipo(oMarked,oNoMarked,aArrayMod,aArrayTipo,lOmsRefr)
Local lRet      := .T.
Local lDisable  := .F.
Local aSX5Tipo  := {}
Local cBitMap   := ""
Local cAliasDB0 := Nil
Local nI       := 1
	// Busca os grupos e os tipos de carga, e carrega nos respectivos arrays
	If Len(aArrayMod) <= 0 .Or. lOmsRefr
		aArrayMod  := {}
		aArrayTipo := {}
		// Busca os grupos (ou modelos) de carga
		cAliasDB0 := GetNextAlias()
		BeginSql Alias cAliasDB0
			SELECT DB0.DB0_CODMOD,
					DB0.DB0_DESMOD,
					DB0.DB0_TIPCAR
			FROM %Table:DB0% DB0
			WHERE DB0.DB0_FILIAL = %xFilial:DB0%
			AND DB0.%NotDel%
		EndSql
		Do While (cAliasDB0)->(!Eof())
			AAdd(aArrayMod,{.F.,(cAliasDB0)->DB0_CODMOD,(cAliasDB0)->DB0_DESMOD,(cAliasDB0)->DB0_TIPCAR})
			(cAliasDB0)->(dbSkip())
		EndDo
		(cAliasDB0)->(dbCloseArea())
		// Se não encontrou, carrega registro em branco
		If Len(aArrayMod) == 0
			AAdd(aArrayMod,{.F.,CriaVar("DB0_CODMOD",.F.),CriaVar("DB0_DESMOD",.F.),CriaVar("DB0_TIPCAR",.F.)})
			lDisable := .T.
		EndIf
		// Busca tipos de carga
		aSX5Tipo := FWGetSX5("DU")
		For nI := 1 To Len(aSX5Tipo)
			AAdd(aArrayTipo,{.F.,aSX5Tipo[nI][3],aSX5Tipo[nI][4]})
		Next
		// Se não encontrou, carrega registro em branco
		If Len(aArrayTipo) == 0
			AAdd(aArrayTipo,{.F.,Space(6),Space(30)})
		EndIf
	EndIf

	If !l200Auto
		DEFINE FONT oFont NAME "Arial" SIZE 0, -11

		cBitmap := "PROJETOAP"

		DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0079) FROM 0,0 TO 300,620 OF oMainWnd PIXEL //"Tipos de Cargas"
		@ 0 , 0 BITMAP oBmp RESNAME cBitMap OF oDlg SIZE 48,488 NOBORDER WHEN .F. PIXEL
		@ 25,50 TO 26,500 OF oDlg Pixel
		@ 03, 50 SAY OemtoAnsi(STR0080) OF oDlg Pixel //"Esta rotina ira montar o mapa de Rotas, Zonas, Setores e Pedidos disponiveis"
		@ 10, 50 SAY OemtoAnsi(STR0081) OF oDlg Pixel //"para a montagem de carga de acordo com os parametros escolhidos pelo usuario."

		@ 28, 50 SAY OemtoAnsi(STR0082) OF oDlg Pixel //"Grupos de Carga"
		@ 28,180 SAY OemtoAnsi(STR0079) OF oDlg Pixel //"Tipos de Carga"

		@ 35,50 LISTBOX oModelo Var cModelo FIELDS HEADER " ",;
			OemToAnsi(STR0013),; //"Codigo"
			OemtoAnsi(STR0020) SIZE 125,85 ; //"Descricao"
			ON DBLCLICK (OmsTrocaTip(1,;
			aArrayMod,;
			aArrayTipo)) OF oDlg PIXEL

			oModelo:nFreeze := 0
			oModelo:SetArray(aArrayMod)
			oModelo:bHeaderClick:= {|oObj,nCol| If(nCol==1,OmsMarcaTip(1,aArrayMod,aArrayTipo),)}
			oModelo:bLine:={||{Iif(aArrayMod[oModelo:nAT,1],oMarked,oNoMarked),;
			aArrayMod[oModelo:nAT,2],;
			aArrayMod[oModelo:nAT,3]}}

		@ 35,180 LISTBOX oTipo Var cTipo FIELDS HEADER " ",;
			OemToAnsi(STR0013),; //"Codigo"
			OemtoAnsi(STR0020) SIZE 125,85 ; //"Descricao"
			ON DBLCLICK (OmsTrocaTip(2,;
			aArrayMod,;
			aArrayTipo)) OF oDlg PIXEL

			oTipo:nFreeze := 0
			oTipo:SetArray(aArrayTipo)
			oTipo:bHeaderClick:= {|oObj,nCol| If(nCol==1,OmsMarcaTip(2,aArrayMod,aArrayTipo),)}
			oTipo:bLine:={||{Iif(aArrayTipo[oTipo:nAT,1],oMarked,oNoMarked),;
			aArrayTipo[oTipo:nAT,2],;
			aArrayTipo[oTipo:nAT,3]}}

		If lDisable
			oTipo:Disable()
			oModelo:Disable()
		EndIf

		DEFINE SBUTTON oBut1 FROM 130, 220 TYPE 5 ENABLE OF oDlg PIXEL ACTION Pergunte("OMS200",.T.)
		DEFINE SBUTTON oBut2 FROM 130, 250 TYPE 1 ENABLE OF oDlg PIXEL ACTION (oDlg:End())
		DEFINE SBUTTON oBut3 FROM 130, 280 TYPE 2 ENABLE OF oDlg PIXEL ACTION (lRet := .F.,oDlg:End())

		ACTIVATE MSDIALOG oDlg CENTERED
	Endif
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OmsTrocaTipºAutor  ³Daniel Pereira      º Data ³  29.01.2021º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Troca a marca no filtro de grupos de cargas                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OmsTrocaTip(nOpcao,aArrayMod,aArrayTipo)
Local nPosTipo := 0
Local nCntFor  := 0

	If nOpcao == 1
		oObjMark := Iif(aArrayMod[oModelo:nAt,1],.F.,.T.)
		aArrayMod[oModelo:nAt,1] := oObjMark
		nPosTipo := Ascan(aArrayTipo,{|x| Trim(x[2]) == Trim(aArrayMod[oModelo:nAt,4])})
		If nPosTipo > 0
			aArrayTipo[nPosTipo,1]   := oObjMark
		EndIf
	Else
		oObjMark := Iif(aArrayTipo[oTipo:nAt,1],.F.,.T.)
		aArrayTipo[oTipo:nAt,1] := oObjMark
		For nCntFor := 1 to Len(aArrayMod)
			If Trim(aArrayMod[nCntFor,4]) == Trim(aArrayTipo[oTipo:nAt,2])
				aArrayMod[nCntFor,1] := oObjMark
			EndIf
		Next nCntFor
	EndIf

	oModelo:Refresh()
	oTipo:Refresh()
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OmsMarcaTipºAutor  ³Daniel P            º Data ³  29.01.2021º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Troca a marca no filtro de grupos de cargas                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function OmsMarcaTip(nOpcao,aArrayMod,aArrayTipo)
Local nCntFor := 0
Local lMarca  := Nil
	If nOpcao == 1
		For nCntFor := 1 to Len(aArrayMod)
			If  (lMarca==Nil)
				lMarca := aArrayMod[nCntFor,1]
			EndIf
			If  aArrayMod[nCntFor,1] == lMarca
				oModelo:nAt := nCntFor
				OmsTrocaTip(1,aArrayMod,aArrayTipo)
			EndIf
		Next nCntFor
		oModelo:nAt := 1
	Else
		For nCntFor := 1 to Len(aArrayTipo)
			If  (lMarca==Nil)
				lMarca := aArrayTipo[nCntFor,1]
			EndIf
			If  aArrayTipo[nCntFor,1]==lMarca
				oTipo:nAt := nCntFor
				OmsTrocaTip(2,aArrayMod,aArrayTipo)
			EndIf
		Next nCntFor
		oTipo:nAt := 1
	EndIf
	oModelo:Refresh()
	oTipo:Refresh()
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OmsBuscaPedºAutor  ³Daniel Pereira      º Data ³  01/02/2021º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Monta Pedidos nos arrays para marcacao                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aArrayCarga - Array  de cargas passado por referencia      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function xOmsBuscaPed(cCarga,aArrayCarga,aArrayRota,aArrayZona,aArraySetor,aArrayMod,aArrayTipo,oProcess,cMarca)
Local lTransp    := SuperGetMv("MV_CGTRANS",.F.,.F.)
Local lOM200DA7  := ExistBlock("OM200DA7")
Local lOM200PED  := ExistBlock("OM200PED") .AND. ExecBlock("OM200PED",.F.,.F.)
Local lOM200TPC  := ExistBlock("OM200TPC")
Local lOM200CLI  := ExistBlock("OM200CLI")
Local lOM200GRV  := ExistBlock("OM200GRV")
Local lProcess   := oProcess != Nil .And. !IsBlind()
Local lDakTpOp   := DAK->( ColumnPos( "DAK_CDTPOP" ) ) > 0 .AND. DAK->( ColumnPos( "DAK_CDCLFR" ) ) > 0
Local lAchou     := .F.
Local lFiltRota  := .F.
Local lAGRUBS    := SuperGetMV("MV_AGRUBS",.F.,.F.)
Local lIntCpl    := SuperGetMv("MV_CPLINT",.F.,"2") == "1" //Indica se o sistema integra com o Planejamento CPL
Local lIntrot    := SC6->( ColumnPos( "C6_INTROT" ) ) > 0
Local aRegDA7    := {}
Local cCliente   := ""
Local cLoja      := ""
Local cQuery     := ""
Local cQuerySA1  := ""
Local cWhere     := ""
Local cCodRota   := ""
Local cDescRota  := ""
Local cRota      := ""
Local cZona      := ""
Local cSetor     := ""
Local cSequen    := ""
Local cSeqRota   := ""
Local cAliasQry  := "TRBSC9"
Local cAliasCli  := ""
Local cAliasDA8  := ""
Local cAliasDA6  := ""
Local cGrpCarga  := ""
Local cDAKTpOp   := ""
Local cDAKClFr   := ""
Local cPedLib    := ""
Local cRotaDe    := MV_PAR21
Local cRotaAte   := MV_PAR22
Local cRotAtv    := SuperGetMv("MV_ROTATV" ,.F.,"2")
Local cAlocPer   := SuperGetMv("MV_ALOCPER",.F.,"N")
Local cRotCep    := SuperGetMv("MV_ROTCEP",.F.,"1")
Local nSeqInc    := SuperGetMV("MV_OMSENTR",.F.,5  )
Local nPesoProd  := 0
Local nSequencia := 0
Local nValor     := 0
Local nCapVol    := 0
Local nQtdLib    := 0
Local nTipoOper  := OsVlEntCom()
Local nRegDA7    := 0
Local nPosRota   := 0
Local nPosTipo   := 0
Local xRetPE     := Nil
Local aArrayPed  := {}
Local nArrayPed  := 0
Local nCount     := 0
Local nTamEndPad := TamSX3("C9_ENDPAD")[1]
Local lDaiRedesp  := DAI->( ColumnPos( "DAI_REDESP" ) ) > 0

// Variaveis para armazenamento do endereço a ser considerado como endereço do Pedido.
Local cCEPPed    := ""
Local cEndPed    := ""
Local cBaiPed    := ""
Local cMunPed    := ""
Local cEstPed    := ""

Local cNomRed    := ""

//#melhoriaperformance Lógica da função OsPesoProd foi passada para o OMSA200 e é usada caso não haja o PE OM200PES
Local cCpoPeso  := ''
cCpoPeso  :=  IIf(Getmv("MV_PESOCAR") == "L","B1_PESO","B1_PESBRU") 

	OMSConout('Inicio xOmsBuscaPed')
	If lProcess
		oProcess:SetRegua1(3) //3 Processos
		oProcess:IncRegua1(OemtoAnsi(STR0286)) //Selecionando pedidos...
	EndIf

	lFiltRota  := !Empty(cRotaDe) .And. !Empty(cRotaAte)

	If lDakTpOp
		cDAKTpOp := Space(Len(DAK->DAK_CDTPOP))
		cDAKClFr := Space(Len(DAK->DAK_CDCLFR))
	EndIf

	// Armazena variável com os grupos e tipos de carga marcados
	aEval(aArrayMod ,{|aArray|Iif(aArray[1],cGrpCarga += Iif(!Empty(cGrpCarga),",'"+aArray[2]+"'","'"+aArray[2]+"'"),"")})
	cGrpCarga := Iif(!Empty(cGrpCarga),cGrpCarga,"' '")

	OMSConout('Inicio temporária')
	// Limpa tabela temporária
	If Select("TRBPED") > 0
		DbSelectArea("TRBPED")
		ZAP
	EndIf
	OMSConout('Fim temporária')

	/*#melhoriaperformance
	  Montagem Query - Parte 1 de 5
	  A query será montada em 2 partes, utilizando UNION, para evitar o uso de OR.
	  Os comandos de SELECT e de WHERE são praticamente iguais, por isso será montado 1 vez depois serão inclusas as diferenças.
	  Diferença: a primeira query faz um where C5_TIPO IN ('B','D');
	  A segunda query não faz o where na C5_TIPO, mas faz um JOIN na SA1 e podendo haver um filtro por SA1_GRPVEN.

	  Os filtros de >= e <= só serão executados caso os perguntes inicial seja diferentes de '' e final de 'ZZZZZZ' ou '99'.
	  
	  Os campos da SC5 foram inclusos na query para evitar a leitura da SC5 em cada registro da query.
	  
	  Os campos de peso da SB1 foram inclusos para evitar a leitura da SB1 em cada registro da query. Entretanto, só 
	  serão usados caso não haja o ponto de entrada OM200PES.

	  Os campos de dimensão da SB5 foram inclusos para evitar a leitura da SB5 em cada registro da query. Entretanto, só 
	  serão usados caso não haja o ponto de entrada OMSCPARM.
	  */

	cQuery := "SELECT SC5.C5_FILIAL,"
	cQuery +=       " SC5.C5_NUM,"
	cQuery +=       " SC5.C5_CLIENTE," 
	cQuery +=       " SC5.C5_LOJACLI,"
	cQuery +=       " SC5.C5_CLIENT," 
	cQuery +=       " SC5.C5_LOJAENT," 
	cQuery +=       " SC5.C5_TIPO," 
	cQuery +=       " SC5.C5_REDESP," 
	cQuery +=       " SC9.C9_FILIAL,"
	cQuery +=       " SC9.C9_CLIENTE,"
	cQuery +=       " SC9.C9_LOJA,"
	cQuery +=       " SC9.C9_PEDIDO,"
	cQuery +=       " SC9.C9_PRODUTO,"
	cQuery +=       " SC9.C9_ITEM,"
	cQuery +=       " SC9.C9_PRCVEN,"
	cQuery +=       " SC9.C9_SEQUEN,"
	cQuery +=       " SC9.C9_QTDLIB,"
	cQuery +=       " SB1.B1_DESC,"
	cQuery +=       " SB1.B1_TIPCAR,"
	cQuery +=       " SB1.B1_PESO,"
	cQuery +=       " SB1.B1_PESBRU,"
	cQuery +=       " (SELECT SB5.B5_ALTURLC * SB5.B5_LARGLC * SB5.B5_COMPRLC"
	cQuery +=       " FROM " + RetSqlName("SB5") + " SB5"
	If nTipoOper == 1
		cQuery += " WHERE SB5.B5_FILIAL = '"+xFilial("SB5")+"'"
	Else
		cQuery += " WHERE SB5.B5_FILIAL = "+OsFilQry("SB5","SC6.C6_FILIAL")
	EndIf
	cQuery +=       " AND SB5.B5_COD = SC6.C6_PRODUTO"
	cQuery +=       " AND SB5.D_E_L_E_T_ = ' ') B5_CAPARM" 
	cQuery +=  " FROM "+RetSqlName("SC5")+" SC5"

	cQuery += " INNER JOIN "+RetSqlName("SC6")+" SC6"
	cQuery +=    " ON SC6.C6_FILIAL  = SC5.C5_FILIAL"
	cQuery +=   " AND SC6.C6_NUM     = SC5.C5_NUM"
	cQuery +=   " AND SC6.C6_NOTA  <> space(9)  " //> SPACE(TamSx3("C6_NOTA"))" 
	cQuery +=   " AND SC6.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+RetSqlName("SC9")+" SC9"
	cQuery +=    " ON SC9.C9_FILIAL  = SC6.C6_FILIAL"
	cQuery +=   " AND SC9.C9_PEDIDO  = SC6.C6_NUM"
	cQuery +=   " AND SC9.C9_ITEM    = SC6.C6_ITEM"
	cQuery +=   " AND SC9.C9_CARGA = '' " //OR SC9.C9_CARGA = SPACE(TamSx3("C9_CARGA"))) " //daniel ==  se já tiver romaneio (carga) 
	cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1"
	// Se busca filial através do método padrão
	If nTipoOper == 1
		cQuery += " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	Else
		cQuery += " ON SB1.B1_FILIAL = "+OsFilQry("SB1","SC6.C6_FILIAL")
	EndIf
	cQuery +=   " AND SB1.B1_COD = SC6.C6_PRODUTO"
	If !l200Auto // Não deve filtrar o grupo de carga quando for execauto
		cQuery += " AND SB1.B1_TIPCAR  IN ("+cGrpCarga+")"
	EndIf
	cQuery += " AND SB1.D_E_L_E_T_  = ' '"

	// Join Agroindústria
	If lAgrUBS
		cQuery += OGX225H()
	EndIf
	// Se busca filial através do método padrão
	If nTipoOper == 1
		cWhere += " WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"'"
	Else
		cWhere += " WHERE SC5.C5_FILIAL >= '"+MV_PAR09+"'"
		cWhere += "   AND SC5.C5_FILIAL <= '"+MV_PAR10+"'"
	EndIf

	If !(AllTrim(MV_PAR01) == '' .And. Upper(AllTrim(MV_PAR02)) == Replicate('Z', Len(MV_PAR02)))
		cWhere +=   " AND SC5.C5_NUM     >= '"+MV_PAR01+"'"
		cWhere +=   " AND SC5.C5_NUM     <= '"+MV_PAR02+"'"
	EndIf
	If !(AllTrim(MV_PAR03) == '' .And. Upper(AllTrim(MV_PAR04)) == Replicate('Z', Len(MV_PAR04)))
		cWhere +=   " AND SC5.C5_CLIENTE >= '"+MV_PAR03+"'"
		cWhere +=   " AND SC5.C5_CLIENTE <= '"+MV_PAR04+"'"
	EndIf
	If !(AllTrim(MV_PAR13) == '' .And. Upper(AllTrim(MV_PAR14)) == Replicate('9', Len(MV_PAR14)))
		cWhere +=   " AND SC5.C5_LOJACLI >= '"+MV_PAR13+"'"
		cWhere +=   " AND SC5.C5_LOJACLI <= '"+MV_PAR14+"'"
	EndIf
	// Se na montagem da carga não serão incluídos pedidos que possuem transportadora
	If !lTransp
		cWhere += " AND SC5.C5_TRANSP = '"+Space(Len(SC5->C5_TRANSP))+"'"
	EndIf
	// Se filtra data de entrega por pedido
	If MV_PAR06 == 1
		cWhere += " AND SC5.C5_FECENT >= '"+DtoS(MV_PAR15)+"'"
		cWhere += " AND SC5.C5_FECENT <= '"+DtoS(MV_PAR16)+"'"
	EndIf
	// Se não é localização Brasil
	If !(cPaisLoc == "BRA")
		cWhere += " AND SC5.C5_DOCGER <> '3'"
	EndIf
	cWhere +=   "AND SC5.C5_TPCARGA  = '1'  AND SC5.D_E_L_E_T_  = ' '"
	// Se filtra data de entrega por itens
	If MV_PAR06 == 2
		cWhere += " AND SC6.C6_ENTREG >= '"+DtoS(MV_PAR15)+"'"
		cWhere += " AND SC6.C6_ENTREG <= '"+DtoS(MV_PAR16)+"'"
	EndIf
	If !(AllTrim(MV_PAR07) == '' .And. Upper(AllTrim(MV_PAR08)) == Replicate('Z', Len(MV_PAR08)))
		cWhere +=   " AND SC6.C6_ENDPAD  >= '"+MV_PAR07+"'"
		cWhere +=   " AND SC6.C6_ENDPAD  <= '"+MV_PAR08+"'"
	EndIf
	If !(AllTrim(MV_PAR17) == '' .And. Upper(AllTrim(MV_PAR18)) == Replicate('Z', Len(MV_PAR18)))
		cWhere +=   " AND SC6.C6_LOCAL   >= '"+MV_PAR17+"'"
		cWhere +=   " AND SC6.C6_LOCAL   <= '"+MV_PAR18+"'"
	EndIf
	// Se não estiver sendo chamado via ExecAuto
	If !l200Auto .And. cPaisLoc == "BRA" .AND. lIntrot .AND. lIntCpl
		cWhere += " AND SC6.C6_INTROT <> '2'"
	EndIf
	cWhere +=   " AND SC9.C9_CARGA    = '"+Space(Len(SC9->C9_CARGA))+"'"
	cWhere +=   " AND SC9.C9_SEQCAR   = '"+Space(Len(SC9->C9_SEQCAR))+"'"
	cWhere +=   " AND SC9.C9_DATALIB >= '"+DtoS(MV_PAR11)+"'"
	cWhere +=   " AND SC9.C9_DATALIB <= '"+DtoS(MV_PAR12)+"'"
	//cWhere +=   " AND SC9.C9_BLCRED   = '"+Space(Len(SC9->C9_BLCRED))+"'"
	If !lAgrUBS
	//	cWhere += " AND SC9.C9_BLEST    = '"+Space(Len(SC9->C9_BLEST))+"'"
	EndIf
	cWhere +=   " AND SC9.C9_TPCARGA  = '1'"
	// Se não é localização Brasil
	If !(cPaisLoc == "BRA")
		cWhere += " AND SC9.C9_REMITO = '"+Space(Len(SC9->C9_REMITO))+"'"
	EndIf

	/*Montagem Query - Parte 2 de 5
	  Segunda query, incluindo o JOIN com SA1*/
	cQuerySA1 := cQuery
	cQuerySA1 += " INNER JOIN "+RetSqlName("SA1")+" SA1"
	cQuerySA1 +=    " ON SA1.A1_FILIAL   = '"+xFilial("SA1")+"'"
	cQuerySA1 +=   " AND SA1.A1_COD      = SC5.C5_CLIENTE"
	cQuerySA1 +=   " AND SA1.A1_LOJA     = SC5.C5_LOJACLI"
	cQuerySA1 +=   " AND SA1.D_E_L_E_T_  = ' '"
	cQuerySA1 += cWhere

	/*Montagem Query - Parte 3 de 5
	Filtro exclusivo para a primeira query*/
	cWhere += " AND SC5.C5_TIPO IN ('B', 'D')"
	cQuery += cWhere

	/*Montagem Query - Parte 4 de 5
	Filtro exclusivo para a segunda query*/
	If !(AllTrim(MV_PAR19) == '' .And. Upper(AllTrim(MV_PAR20)) == Replicate('Z', Len(MV_PAR20)))
		cQuerySA1 += " AND SA1.A1_GRPVEN  >= '"+MV_PAR19+"'" + " AND SA1.A1_GRPVEN  <= '"+MV_PAR20+"'"
	EndIf

	/*#melhoriaperformance
	  Com a inclusão do UNION, o ponto de entrada será chamado 2 vezes, para o caso de fazer uso de localização de
	  conteúdo específico na variável (SELECT, WHERE etc)*/
  	If lOM200QRY
		xRetPE := ExecBlock("OM200QRY",.F.,.F.,{ cQuery , aArrayTipo,aArrayMod })
		cQuery := Iif(ValType(xRetPE)=="C", xRetPE, cQuery)

		xRetPE := ExecBlock("OM200QRY",.F.,.F.,{ cQuerySA1, aArrayTipo,aArrayMod })
		cQuerySA1 := Iif(ValType(xRetPE)=="C", xRetPE, cQuerySA1)
	EndIf

	/*Montagem Query - Parte 5 de 5
	  Une as 2 querys e inclui o ORDER BY*/
	cQuery += " UNION " + cQuerySA1
	cQuery += " ORDER BY C9_FILIAL,"
	cQuery +=          " C9_CLIENTE,"
	cQuery +=          " C9_LOJA,"
	cQuery +=          " C9_PEDIDO,"
	cQuery +=          " C9_ITEM"
/*
' AND SC9.C9_BLCRED   = '  ' AND SC9.C9_BLEST    = '  ' 
*/


	cQuery := Substr(cQuery, 8, Len(cQuery))
	cQuery := "%"+AllTrim(cQuery)+"%"
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT %Exp:cQuery%
	EndSql
	OMSConout('Abertura Query')
	OMSConout('OMSA200-Query-xOmsBuscaPed: '+GetLastQuery()[2], 0)

	/*#melhoriaperformance
	  Para tabela temporária LastRec não funciona.
	  Foi alterado para chamar o IncRegua somente a cada 100 registros, pois essa função consumia alguns ms e 
	  a atualização de 1 em 1 registro não é necessária.*/
	If lProcess 
		oProcess:IncRegua1(OemtoAnsi(STR0287)) //Validando informação dos pedidos... 
		oProcess:SetRegua2(0) 
	EndIf

	Do While !(cAliasQry)->(Eof())
		OMSConout('Pedido selecionado: ';
		   + (cAliasQry)->C9_FILIAL + '/';
		   + (cAliasQry)->C9_CLIENTE + '/';
		   + (cAliasQry)->C9_LOJA + '/';
		   + (cAliasQry)->C9_PEDIDO + '/';
		   + (cAliasQry)->C9_PRODUTO + '/';
		   + (cAliasQry)->C9_ITEM)

		nCount++
		If lProcess .And. Mod(nCount, 100) == 0
			OMSConout('Inicio Process')
			oProcess:IncRegua2(OemtoAnsi(STR0288) + AllTrim(Str(nCount))) //Total de pedidos já validados: 		
			OMSConout('Fim Process')
		EndIf

		// Permite selecionar os pedidos que serão exibidos
		If lOM200TPC
			OMSConout('Inicio OM200TPC')
			xRetPE := ExecBlock("OM200TPC",.F.,.F.,{(cAliasQry)->C9_PRODUTO,(cAliasQry)->B1_TIPCAR,.T.,aArrayMod})
			If ValType(xRetPE) == "L" .And. !xRetPE
				OMSConout('Execucao OM200TPC')
				(cAliasQry)->(DbSkip())
				Loop
			EndIf
			OMSConout('Fim OM200TPC')
		EndIf
		// Verifica os tipo de pedido e o codigo/loja do cliente/fornecedor
		cAliasCli := Iif((lDaiRedesp .And. !Empty((cAliasQry)->C5_REDESP)),"SA4",Iif((cAliasQry)->C5_TIPO $ "BD", "SA2", "SA1"))
		
		// Definição do destino a ser utilizado no OMS.
		If !Empty((cAliasQry)->C5_CLIENT)
			cCliente := (cAliasQry)->C5_CLIENT
			cLoja    := (cAliasQry)->C5_LOJAENT
		Else
			cCliente := (cAliasQry)->C5_CLIENTE
			cLoja    := (cAliasQry)->C5_LOJACLI
		EndIf
		// Permite alterar cliente/loja na montagem de carga usados na identificacao das rotas
		If lOM200CLI
			OMSConout('Inicio OM200CLI')
			xRetPE := ExecBlock("OM200CLI",.F.,.F.,{(cAliasQry)->C5_FILIAL,(cAliasQry)->C5_NUM,cCliente,cLoja})
			OMSConout('Fim OM200CLI')
			If ValType(xRetPE)=="A"
				cCliente := xRetPE[1]
				cLoja    := xRetPE[2]
			EndIf
		EndIf
		// Verifica o codigo de referencia para o operador logistico - Amarracao Cod Cli X OL
		If nTipoOper == 3
			OMSConout('Inicio DCK')
			DCK->(DbSetOrder(2)) // DCK_FILIAL+DCK_CODCLI+DCK_LOJCLI
			If DCK->(DbSeek(xFilial("DCK")+cCliente+cLoja)) .And.;
				(cAliasQry)->C5_FILIAL != cFilAnt				
				cCliente := DCK->DCK_CODOPL
				cLoja    := DCK->DCK_LOJOPL
			EndIf
			OMSConout('Fim DCK')
		EndIf
		// Só procede com a busca de rotas se for um pedido diferente, para não onerar o processo de roteirização
		If !(cPedLib == (cAliasQry)->C5_FILIAL+cCliente+cLoja+(cAliasQry)->C5_NUM)
			 cPedLib := (cAliasQry)->C5_FILIAL+cCliente+cLoja+(cAliasQry)->C5_NUM
			// Permite indicar se deve acionar a consulta da DA7 a cada novo pedido do cliente
			If lDaiRedesp 
				nPosRota := aScan(aArrayCli, {|x|x[1]+x[2]+x[8] == cCliente+cLoja+(cAliasQry)->C5_REDESP})
			Else
				nPosRota := aScan(aArrayCli, {|x|x[1]+x[2] == cCliente+cLoja})
			EndIF

			If !lOM200PED .And. nPosRota > 0
				OMSConout('Sem consulta DA7')
				cCodRota := aArrayCli[nPosRota,3]
				cZona    := aArrayCli[nPosRota,4]
				cSetor   := aArrayCli[nPosRota,5]
				cSeqRota := aArrayCli[nPosRota,6]
				cSequen  := aArrayCli[nPosRota,7]
			Else
				OMSConout('Inicio Consulta DA7')
				lAchou := .F.
				// Busca um Ponto por Zona e Setor que atenda o pedido
				OMSConout('Inicio OmsHasDA7')
				aRegDA7 := OmsHasDA7((cAliasQry)->C5_FILIAL,cCliente,cLoja,cAliasCli,Iif(lDaiRedesp,(cAliasQry)->C5_REDESP,""))
				OMSConout('Fim OmsHasDA7')
				// Permite manipular o array de Pontos por Zona e Setor
				If lOM200DA7
					OMSConout('Inicio OMS200DA7')
					xRetPE := ExecBlock("OM200DA7",.F.,.F.,{(cAliasQry)->C5_FILIAL,cCliente,cLoja,(cAliasQry)->C5_NUM,aRegDA7})
					OMSConout('Fim OMS200DA7')
					If ValType(xRetPE)=="A"
						aRegDA7 := xRetPE
					EndIf
				EndIf
				// Se encontrou registros válidos, prossegue com as validações
				If Len(aRegDA7) > 0
					OMSConout('Inicio For DA7')
					For nRegDA7 := 1 To Len(aRegDA7)
						DA7->(DbGoto(aRegDA7[nRegDA7]))
						cZona   := DA7->DA7_PERCUR
						cSetor  := DA7->DA7_ROTA
						cSequen := DA7->DA7_SEQUEN
						// Avalia se o Ponto por Zona e Setor pertence a uma rota válida
						cAliasDA8 := GetNextAlias()
						If lFiltRota
							OMSConout('Inicio 1 DA8')
							BeginSql Alias cAliasDA8
								SELECT DA8.DA8_COD,
										DA8.DA8_DESC,
										DA8.DA8_TIPCAR,
										DA8.DA8_CODCAL,
										DA9.DA9_SEQUEN
								FROM %Table:DA8% DA8
								INNER JOIN %Table:DA9% DA9
								ON DA9.DA9_FILIAL = %xFilial:DA9%
								AND DA9.DA9_PERCUR = %Exp:cZona%
								AND DA9.DA9_ROTA = %Exp:cSetor%
								AND DA9.DA9_ROTEIR >= %Exp:cRotaDe%
								AND DA9.DA9_ROTEIR <= %Exp:cRotaAte%
								AND DA9.%NotDel%
								WHERE DA8.DA8_FILIAL = %xFilial:DA8%
								AND DA8.DA8_COD = DA9.DA9_ROTEIR
								AND DA8.DA8_ATIVO = '1'
								AND DA8.%NotDel%
							EndSql
							OMSConout('Fim 1 DA8')
						Else
							OMSConout('Inicio 2 DA8')
							BeginSql Alias cAliasDA8
								SELECT DA8.DA8_COD,
										DA8.DA8_DESC,
										DA8.DA8_TIPCAR,
										DA8.DA8_CODCAL,
										DA9.DA9_SEQUEN
								FROM %Table:DA8% DA8
								INNER JOIN %Table:DA9% DA9
								ON DA9.DA9_FILIAL = %xFilial:DA9%
								AND DA9.DA9_PERCUR = %Exp:cZona%
								AND DA9.DA9_ROTA = %Exp:cSetor%
								AND DA9.%NotDel%
								WHERE DA8.DA8_FILIAL = %xFilial:DA8%
								AND DA8.DA8_COD = DA9.DA9_ROTEIR
								AND DA8.DA8_ATIVO = '1'
								AND DA8.%NotDel%
							EndSql
							OMSConout('Fim 2 DA8')
						EndIf
						Do While !(cAliasDA8)->(Eof())
							OMSConout('Inicio While DA8')

							// Verifica a necessidade de avaliar o tipo de carga, de acordo com parametrização e calendáro de entrega
							If cRotAtv == "2" .Or. Empty((cAliasDA8)->DA8_CODCAL) .Or. (!Empty((cAliasDA8)->DA8_CODCAL) .And. OmsDtEntr((cAliasDA8)->DA8_CODCAL,dDataBase) == dDataBase)
								// Verifica se a rota está vinculada a um dos tipos de carga selecionados na tela de parâmetros
								If (nPosTipo := Ascan(aArrayTipo,{|x| AllTrim(x[2]) == AllTrim((cAliasDA8)->DA8_TIPCAR)})) > 0
									// Se o tipo não estiver marcado, pula o registro
									If !aArrayTipo[nPosTipo,1]
										(cAliasDA8)->(DbSkip())
										OMSConout('Loop 1 While DA8')
										Loop
									EndIf
									// Consiste com o registro de modelo de carga
									DB0->(DbSetOrder(1)) // DB0_FILIAL+DB0_CODMOD
									If DB0->(DbSeek(xFilial("DB0")+(cAliasQry)->B1_TIPCAR)) .And.;
										!((cAliasDA8)->DA8_TIPCAR == DB0->DB0_TIPCAR)
										(cAliasDA8)->(DbSkip())
										OMSConout('Loop 2 While DA8')
										Loop
									EndIf
								EndIf
							EndIf
							lAchou   := .T.
							cCodRota := (cAliasDA8)->DA8_COD
							cDescRota:= (cAliasDA8)->DA8_DESC
							cSeqRota := (cAliasDA8)->DA9_SEQUEN
							// Pesquisa os Setores por Zona
							cAliasDA6 := GetNextAlias()
							OMSConout('Inicio DA6')
							BeginSql Alias cAliasDA6
								SELECT DA6.DA6_REF,
										DA5.DA5_DESC
								FROM %Table:DA6% DA6
								LEFT JOIN %Table:DA5% DA5
								ON DA5.DA5_FILIAL = %xFilial:DA5%
								AND DA5.DA5_COD = DA6.DA6_PERCUR
								AND DA5.%NotDel%
								WHERE DA6.DA6_FILIAL = %xFilial:DA6%
								AND DA6.DA6_PERCUR = %Exp:cZona%
								AND DA6.DA6_ROTA = %Exp:cSetor%
								AND DA6.%NotDel%
							EndSql
							OMSConout('Fim DA6')
							If !(cAliasDA6)->(Eof())
								If Ascan(aArrayRota, {|x| x[3] == cCodRota}) == 0
									AAdd(aArrayRota, { .T.,.F.,cCodRota,cDescRota,Space(6)} )
								EndIf
								If Ascan(aArraySetor, {|x| x[3]+x[4]+x[5] == cCodRota+cZona+cSetor}) == 0
									AAdd(aArraySetor, { .T.,.F.,cCodRota,cZona,cSetor,(cAliasDA6)->DA6_REF,Space(6),cSeqRota} )
									If Ascan(aArrayZona, {|x| x[3]+x[4] == cCodRota+cZona}) == 0
										AAdd(aArrayZona, { .T.,.F.,cCodRota,cZona,(cAliasDA6)->DA5_DESC,Space(6),cSeqRota} )
									EndIf
								EndIf
							EndIf
							(cAliasDA6)->(DbCloseArea())
							// Adiciona no array de Rotas por Cliente, caso ainda não exista
							If lDaiRedesp
								If aScan(aArrayCli, {|x|x[1]+x[2]+x[3]+x[4]+x[5]+x[8]=cCliente+cLoja+cCodRota+cZona+cSetor+(cAliasQry)->C5_REDESP}) == 0
									AAdd(aArrayCli, { cCliente, cLoja, cCodRota, cZona, cSetor, cSeqRota, cSequen, (cAliasQry)->C5_REDESP })
								EndIf
							Else
								If aScan(aArrayCli, {|x|x[1]+x[2]+x[3]+x[4]+x[5]=cCliente+cLoja+cCodRota+cZona+cSetor}) == 0
									AAdd(aArrayCli, { cCliente, cLoja, cCodRota, cZona, cSetor, cSeqRota, cSequen })
								EndIf							
							EndIf 
							// Se localizou uma rota válida e não permite seleção de diversas rotas
							If cAlocPer == "N"
								OMSConout('Exit Rota')
								Exit
							EndIf
							(cAliasDA8)->(DbSkip())
							OMSConout('Fim While DA8')
						EndDo
						(cAliasDA8)->(DbCloseArea())
					Next nRegDa7
					OMSConout('Fim For DA7')
					// Posiciona novamente na primeira DA7 para gravar a
					// rota priorizada nos registros da tabela temporária
					DA7->(DbGoto(aRegDA7[1]))
					cZona   := DA7->DA7_PERCUR
					cSetor  := DA7->DA7_ROTA
					cSequen := DA7->DA7_SEQUEN
				EndIf
				// Se não encontrou rota válida, cria o registro sem roteirização
				If !lAchou .And. !lFiltRota
					OMSConout('Sem roteirizacao')
					cDescRota := OemToAnsi(STR0043) //"PEDIDOS SEM ROTEIRIZACAO"
					cCodRota  := Replicate("9",Len(DA8->DA8_COD))
					cZona     := Replicate("9",Len(DA7->DA7_PERCUR))
					cSetor    := Replicate("9",Len(DA7->DA7_ROTA))
					cSeqRota  := Replicate("9",Len(DA9->DA9_SEQUEN))
					cSequen   := Replicate("9",Len(DA7->DA7_SEQUEN))
					If Ascan(aArrayRota , {|x| x[3] == cCodRota}) == 0
						AAdd(aArrayRota , {.T.,.F.,cCodRota,cDescRota,Space(6)} )
						AAdd(aArrayZona , {.T.,.F.,cCodRota,cSetor,cDescRota,Space(6),cSeqRota} )
						AAdd(aArraySetor, {.T.,.F.,cCodRota,cZona,cSetor,cDescRota,Space(6),cSeqRota} )
					EndIf
				EndIf
			EndIf
		EndIf
		// Se informou os filtros de rota no grupo de perguntas e
		// não encontrou rota válida, deve desconsiderar o Pedido
		If !lAchou .And. lFiltRota
			(cAliasQry)->(DbSkip())
			OMSConout('Loop Rota')
			Loop
		EndIf
		// Verifica se é um Cliente/Fornecedor/Transportador/Redespachante válido
		OMSConout('Inicio Valida cliente/Redespachante')
		If cAliasCli = "SA4" //cAliasCli será igual "SA4" somente se lDaiRedesp for TRUE, então, aqui não precisa validar novamente a flag.
			(cAliasCli)->(DbSetOrder(1))
			If !(cAliasCli)->(DbSeek(OsFilial(cAliasCli,(cAliasQry)->C5_FILIAL)+(cAliasQry)->C5_REDESP))
				(cAliasQry)->(DbSkip())
				OMSConout('Loop Valida Redespachante')
				Loop
			EndIf		
		Else
			(cAliasCli)->(DbSetOrder(1))
			If !(cAliasCli)->(DbSeek(OsFilial(cAliasCli,(cAliasQry)->C5_FILIAL)+cCliente+cLoja))
				(cAliasQry)->(DbSkip())
				OMSConout('Loop Valida cliente')
				Loop
			EndIf
		EndIf
		OMSConout('Fim Valida cliente/Redespachante')
		// Calcula o peso e capacidade do item do pedido
		nQtdLib   := (cAliasQry)->C9_QTDLIB
		nValor    := A410Arred((nQtdLib*(cAliasQry)->C9_PRCVEN),"DAK_VALOR")
		OMSConout('Calculos 1')
		/*#melhoriaperformance 
		  Se houver PE será necessário executá-lo. O PE pode fazer uso da leitura da SB1.
		  Se não houver PE utiliza o campo já lido na query, sem necessidade de fazer leitura na SB1.*/
		If ExistBlock("OM200PES") 
			nPesoProd := OsPesoProd((cAliasQry)->C9_PRODUTO,(cAliasQry)->C5_FILIAL) * nQtdLib
		Else 
			nPesoProd := (cAliasQry)->(&cCpoPeso) * nQtdLib
		EndIf
			
		OMSConout('Calculos 2')
		/*#melhoriaperformance 
		  Se houver PE será necessário executá-lo. O PE pode fazer uso da leitura da SB5.
		  Se não houver PE utiliza o campo já lido na query, sem necessidade de fazer leitura na SB5.*/
		If ExistBlock("OMSCPARM")
			nCapVol := OsPrCapArm((cAliasQry)->C9_PRODUTO,(cAliasQry)->C5_FILIAL) * nQtdLib
		Else
			nCapVol := (cAliasQry)->(B5_CAPARM) * nQtdLib
		EndIf
		OMSConout('Calculos 3')

		// Dados do Pedido que podem ser alterados de acordo com:
		// Se o Pedido tiver Redespacho informado.
		// Se o Pedido for do tipo "B" ou "D", vale o Endereço do Fornecedor do Pedido.
		// Se o Parâmetro MV_ROTCEP for igual a "3", vale o Endereço de Entrega do Cliente do Pedido
		// Se o Parâmetro MV_ROTCEP for igual a "1", vale o Endereço principal do Cliente do Pedido
		// Se o Parâmetro MV_ROTCEP for igual a "2", vale o Endereço de Entrega do Cliente. Caso não esteja preenchido, vale o Endereço Principal deste mesmo cliente.
		If cAliasCli = "SA4" //cAliasCli será igual "SA4" somente se lDaiRedesp for TRUE, então, aqui não precisa validar novamente a flag.
			cCEPPed := (cAliasCli)->A4_CEP
			cEndPed := (cAliasCli)->A4_END
			cBaiPed := (cAliasCli)->A4_BAIRRO
			cMunPed := (cAliasCli)->A4_MUN
			cEstPed := (cAliasCli)->A4_EST

			cNomRed := (cAliasCli)->A4_NOME

			// Necessário fazer este Seek para posicionar corretamente o Cliente/Fornecedor, para busca posterior do nome.
			If ((cAliasQry)->C5_TIPO $ "BD")
				SA2->(DbSetOrder(1))
				If !SA2->(DbSeek(OsFilial("SA2",(cAliasQry)->C5_FILIAL)+cCliente+cLoja))
					(cAliasQry)->(DbSkip())
					Loop
				EndIf
			Else
				SA1->(DbSetOrder(1))
				If !SA1->(DbSeek(OsFilial("SA1",(cAliasQry)->C5_FILIAL)+cCliente+cLoja))
					(cAliasQry)->(DbSkip())
					Loop
				EndIf			
			EndIf
		Else
			If ((cAliasQry)->C5_TIPO $ "BD")
				cCEPPed := (cAliasCli)->A2_CEP
				cEndPed := (cAliasCli)->A2_END
				cBaiPed := (cAliasCli)->A2_BAIRRO
				cMunPed := (cAliasCli)->A2_MUN
				cEstPed := (cAliasCli)->A2_EST
			Else
				Do Case
					Case cRotCep == "1"
						cCEPPed := (cAliasCli)->A1_CEP
						cEndPed := (cAliasCli)->A1_END
						cBaiPed := (cAliasCli)->A1_BAIRRO
						cMunPed := (cAliasCli)->A1_MUN
						cEstPed := (cAliasCli)->A1_EST
					Case cRotCep == "2"
						cCEPPed := Iif(Empty((cAliasCli)->A1_CEPE)   ,(cAliasCli)->A1_CEP   ,(cAliasCli)->A1_CEPE)
						cEndPed := IIf(Empty((cAliasCli)->A1_ENDENT) ,(cAliasCli)->A1_END   ,(cAliasCli)->A1_ENDENT)
						cBaiPed := IIf(Empty((cAliasCli)->A1_BAIRROE),(cAliasCli)->A1_BAIRRO,(cAliasCli)->A1_BAIRROE)
						cMunPed := IIf(Empty((cAliasCli)->A1_MUNE)   ,(cAliasCli)->A1_MUN   ,(cAliasCli)->A1_MUNE)
						cEstPed := IIf(Empty((cAliasCli)->A1_ESTE)   ,(cAliasCli)->A1_EST   ,(cAliasCli)->A1_ESTE)						
					Case cRotCep == "3"
						cCEPPed := (cAliasCli)->A1_CEPE
						cEndPed := (cAliasCli)->A1_ENDENT
						cBaiPed := (cAliasCli)->A1_BAIRROE
						cMunPed := (cAliasCli)->A1_MUNE
						cEstPed := (cAliasCli)->A1_ESTE												
				EndCase
			EndIf

			cNomRed := ""
		EndIf

		/*#melhoriaperformance 
		  Se houver PE, será obrigado a usar temporária em vez do array, já que o PE manipula a temporária.
		  Do contrário, será usado o array por ser mais rápido.*/
		If lOM200GRV
			TRBPED->(DbSetOrder(1))
			If !TRBPED->(MsSeek((cAliasQry)->C5_FILIAL+(cAliasQry)->C5_NUM+Iif((MV_PAR06 == 2 .or. MV_PAR06 == 3),(cAliasQry)->C9_ITEM+(cAliasQry)->C9_SEQUEN,"")))
				// Grava o novo registro na tabela temporária
				OMSConout('Inicio gravacao temporaria')
				RecLock("TRBPED",.T.)
				TRBPED->PED_GERA   := "N"
				TRBPED->PED_MARCA  := Iif(l200Auto,cMarca,"  ")
				TRBPED->PED_ROTA   := Iif(cAlocPer=="S",Space(Len(DA8->DA8_COD)),cCodRota)
				TRBPED->PED_ZONA   := cZona
				TRBPED->PED_SETOR  := cSetor
				TRBPED->PED_SEQROT := cSeqRota
				TRBPED->PED_PEDIDO := (cAliasQry)->C5_NUM
				If MV_PAR06 == 2 .or. MV_PAR06 == 3
					TRBPED->PED_ITEM   := (cAliasQry)->C9_ITEM
					TRBPED->PED_SEQLIB := (cAliasQry)->C9_SEQUEN
					TRBPED->PED_CODPRO := (cAliasQry)->C9_PRODUTO
					TRBPED->PED_DESPRO := (cAliasQry)->B1_DESC
				EndIf
				TRBPED->PED_FILORI := (cAliasQry)->C5_FILIAL
				TRBPED->PED_FILCLI := OsFilial("SA1",(cAliasQry)->C5_FILIAL)
				TRBPED->PED_CODCLI := cCliente
				TRBPED->PED_LOJA   := cLoja

				If (cAliasQry)->C5_TIPO $ "BD"
					TRBPED->PED_NOME   := SA2->A2_NOME
				Else
					TRBPED->PED_NOME   := SA1->A1_NOME
				EndIf

				// Dados do Endereço a ser considerado no Pedido.
				TRBPED->PED_CEP    := cCEPPed
				TRBPED->PED_ENDCLI := cEndPed
				TRBPED->PED_BAIRRO := cBaiPed
				TRBPED->PED_MUN    := cMunPed
				TRBPED->PED_EST    := cEstPed

				TRBPED->PED_PESO   := nPesoProd
				TRBPED->PED_CARGA  := "ZZZZZZ"
				TRBPED->PED_SEQSET := cSequen
				TRBPED->PED_SEQORI := cSeqRota
				TRBPED->PED_VALOR  := nValor
				TRBPED->PED_VOLUM  := nCapVol
				TRBPED->PED_QTDLIB := nQtdLib
				TRBPED->PED_ENDPAD := Space(nTamEndPad)
				If lDaiRedesp
					TRBPED->PED_REDESP := Iif(lDaiRedesp,(cAliasQry)->C5_REDESP,"")
					TRBPED->PED_REDNOM := Iif(lDaiRedesp,cNomRed,"")
				EndIf
				TRBPED->(MsUnlock())
				OMSConout('Fim gravacao temporaria')
			Else
				OMSConout('Inicio altera temporaria')
				If MV_PAR06 == 1
					OMSConout('altera temporaria')
					RecLock("TRBPED",.F.)
					TRBPED->PED_PESO  += nPesoProd
					TRBPED->PED_VALOR += nValor
					TRBPED->PED_VOLUM += nCapVol
					TRBPED->PED_QTDLIB+= nQtdLib
					TRBPED->(MsUnlock())
				EndIf
				OMSConout('Fim altera temporaria')
			EndIf
		Else
			OMSConout('Inicio array')
			nArrayPed := aScan(aArrayPed, {|x| X[12]+X[7]+X[8]+X[9] == (cAliasQry)->C5_FILIAL+(cAliasQry)->C5_NUM+Iif((MV_PAR06 == 2 .or. MV_PAR06 == 3),(cAliasQry)->C9_ITEM+(cAliasQry)->C9_SEQUEN,"")})
			If nArrayPed == 0
				Aadd(aArrayPed, {;
				  "N",; //TRBPED->PED_GERA
				  If(l200Auto,cMarca,"  "),; //TRBPED->PED_MARCA
				  Iif(cAlocPer=="S",Space(Len(DA8->DA8_COD)),cCodRota),; //TRBPED->PED_ROTA
				  cZona,; //TRBPED->PED_ZONA
				  cSetor,; //TRBPED->PED_SETOR
				  cSeqRota,; //TRBPED->PED_SEQROT
				  (cAliasQry)->C5_NUM,; //TRBPED->PED_PEDIDO
				  Iif(MV_PAR06 == 2 .or. MV_PAR06 == 3, (cAliasQry)->C9_ITEM, ''),; //TRBPED->PED_ITEM
				  Iif(MV_PAR06 == 2 .or. MV_PAR06 == 3, (cAliasQry)->C9_SEQUEN, ''),; //TRBPED->PED_SEQLIB
				  Iif(MV_PAR06 == 2 .or. MV_PAR06 == 3,	(cAliasQry)->C9_PRODUTO, ''),; //TRBPED->PED_CODPRO
				  Iif(MV_PAR06 == 2 .or. MV_PAR06 == 3,	(cAliasQry)->B1_DESC, ''),; //TRBPED->PED_DESPRO
				  (cAliasQry)->C5_FILIAL,; //TRBPED->PED_FILORI
				  OsFilial("SA1",(cAliasQry)->C5_FILIAL),; //TRBPED->PED_FILCLI
				  cCliente,; //TRBPED->PED_CODCLI
				  cLoja,;    //TRBPED->PED_LOJA
				  Iif((cAliasQry)->C5_TIPO $ "BD", SA2->A2_NOME, SA1->A1_NOME),; //TRBPED->PED_NOME
				  cEndPed,;  //TRBPED->PED_ENDCLI
				  cBaiPed,;  //TRBPED->PED_BAIRRO
				  cMunPed,;  //TRBPED->PED_MUN
				  cEstPed,;  //TRBPED->PED_EST
				  cCEPPed,;  //TRBPED->PED_CEP
				  "ZZZZZZ",; //TRBPED->PED_CARGA
				  cSequen,;  //TRBPED->PED_SEQSET
				  cSeqRota,; //TRBPED->PED_SEQORI
				  Space(nTamEndPad),; //TRBPED->PED_ENDPAD
				  nPesoProd,; //TRBPED->PED_PESO
				  nValor,; //TRBPED->PED_VALOR
				  nCapVol,; //TRBPED->PED_VOLUM
				  nQtdLib,; //TRBPED->PED_QTDLIB
				  Iif(lDaiRedesp,(cAliasQry)->C5_REDESP,""),; //TRBPED->PED_REDESP
				  Iif(lDaiRedesp,cNomRed,""); //TRBPED->PED_REDNOM
				})
			Else
				aArrayPed[nArrayPed,26] += nPesoProd //TRBPED->PED_PESO
				aArrayPed[nArrayPed,27] += nValor //TRBPED->PED_VALOR
				aArrayPed[nArrayPed,28] += nCapVol //TRBPED->PED_VOLUM
				aArrayPed[nArrayPed,29] += nQtdLib  //TRBPED->PED_QTDLIB
			EndIf
			OMSConout('Fim array')
		EndIf

		If lOM200GRV
			OMSConout('Inicio OM200GRV')
			ExecBlock("OM200GRV",.F.,.F.)
			OMSConout('Fim OM200GRV')
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	/*#melhoriaperformance
	  Se usou array agora é necessário incluir os registros na temporária*/
	If !lOM200GRV
		For nArrayPed := 1 to Len(aArrayPed)
			RecLock("TRBPED",.T.)
			TRBPED->PED_GERA   := aArrayPed[nArrayPed,1]
			TRBPED->PED_MARCA  := aArrayPed[nArrayPed,2]
			TRBPED->PED_ROTA   := aArrayPed[nArrayPed,3]
			TRBPED->PED_ZONA   := aArrayPed[nArrayPed,4]
			TRBPED->PED_SETOR  := aArrayPed[nArrayPed,5]
			TRBPED->PED_SEQROT := aArrayPed[nArrayPed,6]
			TRBPED->PED_PEDIDO := aArrayPed[nArrayPed,7]
			TRBPED->PED_ITEM   := aArrayPed[nArrayPed,8]
			TRBPED->PED_SEQLIB := aArrayPed[nArrayPed,9]
			TRBPED->PED_CODPRO := aArrayPed[nArrayPed,10]
			TRBPED->PED_DESPRO := aArrayPed[nArrayPed,11]
			TRBPED->PED_FILORI := aArrayPed[nArrayPed,12]
			TRBPED->PED_FILCLI := aArrayPed[nArrayPed,13]
			TRBPED->PED_CODCLI := aArrayPed[nArrayPed,14]
			TRBPED->PED_LOJA   := aArrayPed[nArrayPed,15]
			TRBPED->PED_NOME   := aArrayPed[nArrayPed,16]
			TRBPED->PED_ENDCLI := aArrayPed[nArrayPed,17]
			TRBPED->PED_BAIRRO := aArrayPed[nArrayPed,18]
			TRBPED->PED_MUN    := aArrayPed[nArrayPed,19]
			TRBPED->PED_EST    := aArrayPed[nArrayPed,20]
			TRBPED->PED_CEP    := aArrayPed[nArrayPed,21]
			TRBPED->PED_CARGA  := aArrayPed[nArrayPed,22]
			TRBPED->PED_SEQSET := aArrayPed[nArrayPed,23]
			TRBPED->PED_SEQORI := aArrayPed[nArrayPed,24]
			TRBPED->PED_ENDPAD := aArrayPed[nArrayPed,25]
			TRBPED->PED_PESO   := aArrayPed[nArrayPed,26]
			TRBPED->PED_VALOR  := aArrayPed[nArrayPed,27]
			TRBPED->PED_VOLUM  := aArrayPed[nArrayPed,28]
			TRBPED->PED_QTDLIB := aArrayPed[nArrayPed,29]
			If lDaiRedesp
				TRBPED->PED_REDESP := aArrayPed[nArrayPed,30]
				TRBPED->PED_REDNOM := aArrayPed[nArrayPed,31]
			EndIf
			TRBPED->(MsUnlock())
		Next
	EndIf

	//Ordena por: Rota, SeqRota, Sequencia de clientes, Zona, Setor, Pedido, Item

	If lProcess
		oProcess:IncRegua1(OemtoAnsi(STR0111)) //Roteirizando pedidos...
		oProcess:IncRegua2("") 
	EndIf
	
	OMSConout('Inicio Reordenacao temporaria')
	TRBPED->(DbSetOrder(2))
	TRBPED->(DbGoTop())
	// Renumera a sequencia de entrega considerando intervalo conforme parametro: MV_OMSENTR
	nSeqInc    := IIF(nSeqInc > 0,nSeqInc,5)
	nSequencia := nSeqInc
	cRota      := TRBPED->PED_ROTA
	cCliente   := TRBPED->PED_CODCLI
	cLoja      := TRBPED->PED_LOJA
	Do While !TRBPED->(Eof())
		If !(TRBPED->PED_ROTA == cRota)
			cRota      := TRBPED->PED_ROTA
			cCliente   := TRBPED->PED_CODCLI
			cLoja      := TRBPED->PED_LOJA
			nSequencia := nSeqInc
		EndIf
		If !(TRBPED->PED_CODCLI+TRBPED->PED_LOJA == cCliente+cLoja)
			cCliente   := TRBPED->PED_CODCLI
			cLoja      := TRBPED->PED_LOJA
			nSequencia += nSeqInc
		EndIf
		RecLock("TRBPED",.F.)
		TRBPED->PED_SEQROT := StrZero(nSequencia,6)
		TRBPED->(MsUnlock())
		TRBPED->(DbSkip())
	EndDo
	OMSConout('Fim Reordenacao temporaria')
	If ExistBlock("OM200GR2")
		OMSConout('Inicio OM200GR2')
		ExecBlock("OM200GR2",.F.,.F.,{"TRBPED"})
		OMSConout('Fim OM200GR2')
	EndIf
	// Ordeno o array de pedidos de acordo com a sequencia de geracao
	TRBPED->(DbSetOrder(3))
	// Adiciono no array de carga a inicial
	AAdd(aArrayCarga,{.T.,;
						cCarga,;
						OemtoAnsi(STR0040)+cCarga,; //"CARGA"
						0,;
						0,;
						0,;
						0,;
						0,;
						Space(7),;
						Space(Len(DA3->DA3_COD)),;
						Space(Len(DA3->DA3_COD)),;
						Space(Len(DA3->DA3_COD)),;
						Space(Len(DA4->DA4_COD)),;
						Space(Len(DAU->DAU_COD)),;
						Space(Len(DAU->DAU_COD)),;
						Space(Len(DAU->DAU_COD)),;
						0,;
						0,;
						0,;
						0,;
						0,;
						0,;
						0,;
						0,;
						cDAKTpOp,;
						cDAKClFr})
	// Verifico se existe algum em branco pois  nao e possivel criar uma dialog com array vazio
	If Len(aArrayRota) == 0
		AAdd(aArrayRota, {.T.,.F.,Space(6),Space(20),Space(6)})
	EndIf
	If Len(aArrayZona) == 0
		AAdd(aArrayZona, {.T.,.F.,Space(6),Space(6),Space(20),Space(6)})
	EndIf
	If Len(aArraySetor) == 0
		AAdd(aArraySetor, {.T.,.F.,Space(6),Space(6),Space(6),Space(20),Space(6)})
	EndIf
	// Ordena os browses de rota, zona e setor de acordo com a sequencia
	aArrayRota  := aSort(aArrayRota,,,{|x,y| x[3] < y[3] })
	aArrayZona  := aSort(aArrayZona,,,{|x,y| x[3]+x[7]+x[4] < y[3]+y[7]+y[4] })
	aArraySetor := aSort(aArraySetor,,,{|x,y| x[3]+x[8]+x[4]+x[5] < y[3]+y[8]+y[4]+x[5] })
	OMSConout('Fim  xOmsBuscaPed')
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³xOmsTrocaSeq ºAutor  ³Daniel Pereira    º Data ³ 01/02/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Monta Pedidos nos arrays para marcacao                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1 - Horario inicial da carga                           º±±
±±º          ³ ExpA2 - Array da carga                                     º±±
±±º          ³ ExpA3 - Array da carga anterior para alteracao             º±±
±±º          ³ ExpO4 - Array com os objetos a dar refresh                 º±±
±±º          ³ ExpL5 - Se ira trocar a sequencia de entrega               º±±
±±º          ³ ExpC6 - Sequencia atual                                    º±±
±±º          ³ ExpC7 - Nova sequencia                                     º±±
±±º          ³ ExpN8 - Tipo de aplicacao ao registro                      º±±
±±º          ³         [1]-Move para baixo pela toolbar                   º±±
±±º          ³         [2]-Move para cima pela toolbar                    º±±
±±º          ³         [3]-Habilita a janela de mover para                º±±
±±º          ³         [4]-Cancela  a janela de mover para                º±±
±±º          ³         [6]-Confirma a janela de mover para                º±±
±±º          ³         [7]-Apenas troca o horario                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function xOmsTrocaSeq(cHrStart,dDtStart,cVeiculo,aArrayAnt,oPedMan,aObj,lSeq,cSeqAtual,cSeqNova,nUpDown)
Local nSeqInc     := SuperGetMV("MV_OMSENTR",.F.,5)
Local nSequencia  := 0
Local nPos        := oPedMan:nAt
Local nPosAnt     := 0
Local nC          := 0
Local oDown       := LoadBitmap( GetResources(), "TRIDOWN"  )
Local oUp         := LoadBitmap( GetResources(), "TRIUP"    )
Local oLiberado   := LoadBitmap( GetResources(), "PMSTASK4" )
Local oCalend     := LoadBitmap( GetResources(), "PMSTASK1" )
Local oHorario    := LoadBitmap( GetResources(), "PMSTASK2" )
Local oVeiculo    := LoadBitmap( GetResources(), "PMSTASK3" )

	cSeqAtual   := aArrayAnt[oPedMan:nAt,1]
	//-- Verifico se o pedido esta marcado para a geracao da carga disponivel
	nPosAnt := nPos

	Do Case
		//-- Move registro para baixo pelas setas da toolbar
		Case nUpDown == 1
			xOmsTrocaSeq(cHrStart,dDtStart,cVeiculo,aArrayAnt,oPedMan,aObj,lSeq,cSeqAtual,cSeqNova,4)
			If  nPos <> Len(aArrayAnt)
				nPos++
			EndIf
			cSeqNova := StrZero(Val(aArrayAnt[nPos,1]),6)
			lSeq     := .T.
		//-- Move registro para cima pelas setas da toolbar
		Case nUpDown == 2
			xOmsTrocaSeq(cHrStart,dDtStart,cVeiculo,aArrayAnt,oPedMan,aObj,lSeq,cSeqAtual,cSeqNova,4)
			If  nPos <> 1
				nPos--
			EndIf
			cSeqNova := StrZero(Val(aArrayAnt[nPos,1]),6)
			lSeq     := .T.
		//-- Habilita janela para digitacao de Mover para....
		Case nUpDown == 3
			If !lSeq
				cSeqNova    := Space(6)
				oPedMan:nRight -= 160
				aEval(aObj,{|x| x:show()})
				lSeq := .T.
			EndIf
		//-- Cancela janela de Mover para...
		Case nUpDown == 4
			If lSeq
				aEval(aObj,{|x| x:hide()})
				oPedMan:nRight += 160
				lSeq := .F.
			EndIf
		//-- Confirmacao da janela mover para...
		Case nUpDown == 5
			If lSeq
				aEval(aObj,{|x| x:hide()})
				oPedMan:nRight += 160
				lSeq := .T.
			EndIf
		Case nUpDown == 6
			lSeq := .F.
	EndCase

	If lSeq
		If !Empty(cSeqNova)
			aArrayAnt[oPedMan:nAt,1] := cSeqNova
			//--Ordena a Sequencia de entrega
			aArrayAnt := aSort(aArrayAnt,,,{|x,y| x[1] < y[1]})
			nSeqInc   := IIF(nSeqInc > 0,nSeqInc,5)
			For nC := 1 to Len(aArrayAnt)
				nSequencia += nSeqInc
				aArrayAnt[nC,1] := StrZero(nSequencia,6)
			Next nC
		EndIf
		If nUpDown == 1 .Or. nUpDown == 2 .Or. nUpDown == 5
			lSeq := .F.
		EndIf
	EndIf
	//-- Verifica se a opcao e de alguma alteracao
	If nUpDown == 1 .Or. nUpDown == 2 .Or. nUpDown == 5 .Or. nUpDown == 6
		//-- Atualiza as horas de entrega
		Oms200Time(cHrStart,dDtStart,aArrayAnt,cVeiculo,12,6,7,2,3,4,14,15,16,17,18,19,20)
	EndIf
	//-- Da refresh no objeto da listbox
	oPedMan:bLine:={||{ Iif(aArrayAnt[oPedMan:nAT,18]==1,oLiberado,;
						Iif(aArrayAnt[oPedMan:nAT,18]==2,oVeiculo,;
						Iif(aArrayAnt[oPedMan:nAT,18]==3,oHorario,;
						Iif(aArrayAnt[oPedMan:nAT,18]==4,oCalend,oLiberado)))),;
						oDown, oUp,;
						aArrayAnt[oPedMan:nAT,1],;
						aArrayAnt[oPedMan:nAT,2],;
						aArrayAnt[oPedMan:nAT,5],;
						aArrayAnt[oPedMan:nAT,19],;
						aArrayAnt[oPedMan:nAT,16],;
						aArrayAnt[oPedMan:nAT,17],;
						aArrayAnt[oPedMan:nAT,20],;
						aArrayAnt[oPedMan:nAT,6],;
						aArrayAnt[oPedMan:nAT,7],;
						aArrayAnt[oPedMan:nAT,8],;
						aArrayAnt[oPedMan:nAT,9],;
						aArrayAnt[oPedMan:nAT,10],;
						aArrayAnt[oPedMan:nAT,11],;
						aArrayAnt[oPedMan:nAT,21],;
						aArrayAnt[oPedMan:nAT,22],;
						aArrayAnt[oPedMan:nAT,23],;
						aArrayAnt[oPedMan:nAT,24]}}
	oPedMan:nAt := nPos
	oPedMan:Refresh()
Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OmsTransp ºAutor  ³Daniel Pereira      º Data ³  22/01/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Associa caminhao para a carga                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5Dl                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function XOmsTransp(aArrayMan,aArrayCarga,oEnable,oDisable,oMarked,oNoMarked,cHrStart,dDtStart,cGvCodOper,cGvNoProc,cGvPedComOp,aHeaderAdt,aColsAdt,cAliasTRB,cMarca,cDakTransp)
Local lOs200Ass  := ExistBlock("OS200ASS")
Local aHoras     := {}
Local aButtons   := { { "CARGA" , { || cVeiDisp := OmsCVDisp(aHoras[1],aHoras[2],aHoras[3],aHoras[4],nPeso,nVolume),Iif(!Empty(cVeiDisp),cVeiculo:= cVeiDisp,cVeiculo := cVeiculo )}, OemtoAnsi(STR0164),OemtoAnsi(STR0176) }} //"Disponibilidade"
Local aButtonUsr := {}
Local oDlg
Local oVeiculo
Local oFolder
Local cCarga     := ""
Local cVeiculo   := ""
Local cMotorista := ""
Local cAjuda1    := ""
Local cAjuda2    := ""
Local cAjuda3    := ""
Local cNomeAju1  := ""
Local cNomeAju2  := ""
Local cNomeAju3  := ""
Local cBitmap    := "PROJETOAP"
Local cPlaca     := Criavar("DA3_PLACA",.F.)
Local cNomeCam   := Criavar("DA3_DESC",.F.)
Local cNomeMot   := Criavar("DA4_NOME",.F.)
Local cVeiDisp   := ""
Local cVeicAtu   := ""
Local cVeiculo2  := Criavar("DAK_CAMINH",.F.)
Local cNomeVeic2 := Criavar("DA3_DESC",.F.)
Local cPlaca2    := Criavar("DA3_PLACA",.F.)
Local cVeicAnt2  := ""
Local cVeiculo3  := Criavar("DAK_CAMINH",.F.)
Local cNomeVeic3 := Criavar("DA3_DESC",.F.)
Local cPlaca3    := Criavar("DA3_PLACA",.F.)
Local cVeicAnt3  := ""
Local cAliasDA3  := Nil
Local cAliasDA4  := Nil
Local cAliasDAU  := Nil
Local cCpoCapac  := IIf(SuperGetmv("MV_OMSCAPA",.F.,"1")=="1","DA3_CAPACN","DA3_CAPACM")
Local nI         := 0
Local nPosCarga  := Ascan(aArrayCarga,{|x| x[CARGA_ENABLE] == .T. })
Local nPeso      := 0
Local nVolume    := 0
Local nPtoEntr   := 0
Local nOpca      := 0
Local nCapacMax  := 0
Local nLimMax    := 0

//Declaradas como Private porque sao utilizadas nas funcoes da getdados do frete.
Private aHeader  := {}
Private aCols    := {}
Private oFrete
Private nFrete   := 0
Private oFreAut
Private nFreAut  := 0
Private oRatFre
Private oTipTab
Private n        := 0

Default aHeaderAdt := {}
Default aColsAdt   := {}
Default cDakTransp := Criavar("A4_COD",.F.)

	cCargaID := aArrayCarga[1][2]
	aButtons   := { { "CARGA" , { || cVeiDisp := OmsCVDisp(aHoras[1],aHoras[2],aHoras[3],aHoras[4],nPeso,nVolume),Iif(!Empty(cVeiDisp),cVeiculo:= cVeiDisp,cVeiculo := cVeiculo )}, OemtoAnsi(STR0164),OemtoAnsi(STR0176) }} //Disponibilidade
	// Se existir carga em aberto abro a tela de caminhoes
	If nPosCarga <> 0
		If Len(aArrayMan) > 0
			//Ponto de entrada para adicao de botoes pelo usuario
			If ExistBlock("OS200VEI")
				aButtonUsr := ExecBlock("OS200VEI",.F.,.F.)
				If ValType(aButtonUsr) == "A"  .And. Len(aButtonUsr) > 0
					For nI := 1 To Len(aButtonUsr)
						AAdd(aButtons,aClone(aButtonUsr[nI]))
					Next nI
				EndIf
			EndIf
			// Calculo janela de entregas dos clientes da carga
			Oms200Time(cHrStart,dDtStart,aArrayMan,aArrayCarga[nPosCarga,CARGA_VEIC],12,6,7,2,3,4,14,15,16,17,18,19,20)

			cVeiculo   := Iif(!Empty(aArrayCarga[nPosCarga][CARGA_VEIC]) ,aArrayCarga[nPosCarga][CARGA_VEIC] ,Criavar("DA3_COD",.F.))
			cVeicAtu   := Iif(!Empty(aArrayCarga[nPosCarga][CARGA_VEIC]) ,aArrayCarga[nPosCarga][CARGA_VEIC] ,Criavar("DA3_COD",.F.))
			cVeiculo2  := Iif(!Empty(aArrayCarga[nPosCarga][CARGA_VEI2]) ,aArrayCarga[nPosCarga][CARGA_VEI2] ,Criavar("DA3_COD",.F.))
			cVeiculo3  := Iif(!Empty(aArrayCarga[nPosCarga][CARGA_VEI3]) ,aArrayCarga[nPosCarga][CARGA_VEI3] ,Criavar("DA3_COD",.F.))
			cMotorista := Iif(!Empty(aArrayCarga[nPosCarga][CARGA_MOTOR]),aArrayCarga[nPosCarga][CARGA_MOTOR],Criavar("DA4_COD",.F.))
			cAjuda1    := Iif(!Empty(aArrayCarga[nPosCarga][CARGA_AJUD1]),aArrayCarga[nPosCarga][CARGA_AJUD1],Criavar("DAU_COD",.F.))
			cAjuda2    := Iif(!Empty(aArrayCarga[nPosCarga][CARGA_AJUD2]),aArrayCarga[nPosCarga][CARGA_AJUD2],Criavar("DAU_COD",.F.))
			cAjuda3    := Iif(!Empty(aArrayCarga[nPosCarga][CARGA_AJUD3]),aArrayCarga[nPosCarga][CARGA_AJUD3],Criavar("DAU_COD",.F.))
			// Ponto de Entrada para alteracao do veiculo.
			If ExistBlock("OS200MNT")
				aVeiculo := ExecBlock("OS200MNT",.F.,.F.,{cVeiculo,cMotorista,cAjuda1,cAjuda2,cAjuda3,3,cVeiculo2,cVeiculo3})
				If ValType(aVeiculo) == "A" .And. Len(aVeiculo) >= 5
					cVeiculo   := aVeiculo[1]
					cMotorista := aVeiculo[2]
					cAjuda1    := aVeiculo[3]
					cAjuda2    := aVeiculo[4]
					cAjuda3    := aVeiculo[5]
					If Len(aVeiculo) >= 7
						cVeiculo2  := aVeiculo[6]
						cVeiculo3  := aVeiculo[7]
					EndIf
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Guarda o veiculo anterior para da unlock caso troque      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cVeicAtu  := cVeiculo // variável de controle para a não sobreposição de motorista vinculado ao veículo
			cVeiAnt   := cVeiculo // variável de controle para gravação de agendamento do veículo (DAN)
			cVeicAnt2 := cVeiculo2
			cVeicAnt3 := cVeiculo3

			cCarga   := aArrayCarga[nPosCarga,CARGA_COD]
			cNomeCam := ""
			cPlaca   := ""
			nCapaxMax:= 0
			nLimMax  := 0
			nPeso    := aArrayCarga[nPosCarga,CARGA_PESO]
			nVolume  := aArrayCarga[nPosCarga,CARGA_VOLUM]
			nPtoEntr := aArrayCarga[nPosCarga,CARGA_PTOENT]

			aHoras := { aArrayMan[1][19],;
						aArrayMan[1][16],;
						aArrayMan[Len(aArrayMan)][20],;
						IntToHora(HoraToInt(aArrayMan[Len(aArrayMan)][16],2)+HoraToInt(aArrayMan[Len(aArrayMan)][17],4),2) }
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Dialog Principal.                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cVeiculo)
				cAliasDA3 := GetNextAlias()
				BeginSql Alias cAliasDA3
					SELECT DA3.R_E_C_N_O_ RECNODA3
					FROM %Table:DA3% DA3
					WHERE DA3.DA3_FILIAL = %xFilial:DA3%
					AND DA3.DA3_COD = %Exp:+cVeiculo%
					AND DA3.%NotDel%
				EndSql
				If (cAliasDA3)->(!Eof())
					cNomeCam   := DA3->DA3_DESC
					cPlaca     := DA3->DA3_PLACA
					nCapacMax  := DA3->(FieldGet(ColumnPos(cCpoCapac)))
					nLimMax    := DA3->DA3_LIMMAX
				EndIf
				(cAliasDA3)->(dbCloseArea())
			EndIf

			If !Empty(cMotorista)
				cAliasDA4 := GetNextAlias()
				BeginSql Alias cAliasDA4
					SELECT DA4.DA4_NOME
					FROM %Table:DA4% DA4
					WHERE DA4.DA4_FILIAL = %xFilial:DA4%
					AND DA4.DA4_COD = %Exp:cMotorista%
				EndSql
				If (cAliasDA4)->(!Eof())
					cNomeMot := (cAliasDA4)->DA4_NOME
				EndIf
				(cAliasDA4)->(dbCloseArea())
			EndIf

			If !Empty(cAjuda1)
				cAliasDAU := GetNextAlias()
				BeginSql Alias cAliasDAU
					SELECT DAU.DAU_NOME
					FROM %Table:DAU% DAU
					WHERE DAU.DAU_FILIAL = %xFilial:DAU%
					AND DAU.DAU_COD = %Exp:cAjuda1%
					AND DAU.%NotDel%
				EndSql
				If (cAliasDAU)->(!Eof())
					cNomeAju1 := (cAliasDAU)->DAU_NOME
				EndIf
				(cAliasDAU)->(dbCloseArea())
			EndIf

			If !Empty(cAjuda2)
				cAliasDAU := GetNextAlias()
				BeginSql Alias cAliasDAU
					SELECT DAU.DAU_NOME
					FROM %Table:DAU% DAU
					WHERE DAU.DAU_FILIAL = %xFilial:DAU%
					AND DAU.DAU_COD = %Exp:cAjuda2%
					AND DAU.%NotDel%
				EndSql
				If (cAliasDAU)->(!Eof())
					cNomeAju2 := (cAliasDAU)->DAU_NOME
				EndIf
				(cAliasDAU)->(dbCloseArea())
			EndIf

			If !Empty(cAjuda3)
				cAliasDAU := GetNextAlias()
				BeginSql Alias cAliasDAU
					SELECT DAU.DAU_NOME
					FROM %Table:DAU% DAU
					WHERE DAU.DAU_FILIAL = %xFilial:DAU%
					AND DAU.DAU_COD = %Exp:cAjuda3%
					AND DAU.%NotDel%
				EndSql
				If (cAliasDAU)->(!Eof())
					cNomeAju3 := (cAliasDAU)->DAU_NOME
				EndIf
				(cAliasDAU)->(dbCloseArea())
			EndIf

			DEFINE MSDIALOG oDlg Title OemtoAnsi(STR0112) From 200,001 to 670,690 Pixel //"Associacao do Veiculo"

			@ 0 , 0 BITMAP oBmp RESNAME cBitMap OF oDlg SIZE 48,488 NOBORDER WHEN .F. PIXEL

			@ 030,055 FOLDER oFolder OF oDlg PROMPT OemtoAnsi(STR0014) PIXEL SIZE 275,190
			// Cria os componentes da folder Carga
			@ 012,015 Say OemtoAnsi(STR0014) Size 30,7 OF oFolder:aDialogs[1] Pixel //"Carga:"
			@ 010,050 MsGet cCarga Picture "@!" When .F. Size 25,10 OF oFolder:aDialogs[1] Pixel

			@ 029,010 to 095,270 OF oFolder:aDialogs[1] Pixel
			@ 096,010 to 163,270 OF oFolder:aDialogs[1] Pixel

			@ 037,015 Say OemToAnsi(STR0019) Size 30,10 OF oFolder:aDialogs[1] Pixel //"Veiculo"

			@ 035,050 MSGet oVeiculo VAR cVeiculo Valid ( OmsVldTransp(cVeiculo,@cVeicAtu,@cNomeCam,@cPlaca,@nCapacMax,@nLimMax,nPeso,nVolume,nPtoEntr,@cMotorista,@cNomeMot,@cAjuda1,@cNomeAju1,@cAjuda2,@cNomeAju2,@cAjuda3,@cNomeAju3,aHoras,,@cVeiculo2,@cVeiculo3,@cNomeVeic2,@cNomeVeic3,@cPlaca2,@cPlaca3) );
					Picture "@!" F3 "DA3" Size 30,10 OF oFolder:aDialogs[1] Pixel
			@ 035,095 MSGet oNomeCam VAR cNomeCam When .F. Size 148,10 OF oFolder:aDialogs[1] Pixel

			@ 052,015 Say OemtoAnsi(STR0095) Size 30,10 OF oFolder:aDialogs[1] Pixel //"Placa"
			@ 050,050 MSGet oPlaca VAR cPlaca When .F. Size 35,10 OF oFolder:aDialogs[1] Pixel

			@ 052,095 Say OemtoAnsi(STR0096) Size 30,10 OF oFolder:aDialogs[1] Pixel //"Capac.Max"
			@ 050,130 MSGet oCapacMax VAR nCapacMax When .F. Size 35,10 OF oFolder:aDialogs[1] Pixel

			@ 052,180 Say OemtoAnsi(STR0097) Size 30,10 OF oFolder:aDialogs[1] Pixel //
			@ 050,208 MSGet oLimMax VAR nLimMax When .F. Size 35,10 OF oFolder:aDialogs[1] Pixel

			@ 067,015 Say OemtoAnsi("Veículo 2") Size 30,10 OF oFolder:aDialogs[1] Pixel //"Veículo 2"
			@ 065,050 MSGet cVeiculo2 Valid VldReboque(cVeiculo2,@cNomeVeic2,@cPlaca2,aHoras) Picture "@!" F3 "DA3" Size 30,10  OF oFolder:aDialogs[1] Pixel

			@ 065,095 MSGet cNomeVeic2 When .F. Size 70,10 OF oFolder:aDialogs[1] Pixel

			@ 067,180 Say OemtoAnsi("Placa 2") Size 30,10 OF oFolder:aDialogs[1] Pixel //"Placa 2"
			@ 065,208 MSGet cPlaca2 When .F. Size 35,10 OF oFolder:aDialogs[1] Pixel

			@ 082,015 Say OemtoAnsi("Veículo 3") Size 30,10 OF oFolder:aDialogs[1] Pixel //"Veículo 3"
			@ 080,050 MSGet cVeiculo3 Valid VldReboque(cVeiculo3,@cNomeVeic3,@cPlaca3,aHoras) Picture "@!" F3 "DA3" Size 30,10 OF oFolder:aDialogs[1] Pixel

			@ 080,095 MSGet cNomeVeic3 When .F. Size 70,10 OF oFolder:aDialogs[1] Pixel

			@ 082,180 Say OemtoAnsi("Placa 3") Size 30,10 OF oFolder:aDialogs[1] Pixel //"Placa 3"
			@ 080,208 MSGet cPlaca3 When .F. Size 35,10 OF oFolder:aDialogs[1] Pixel

			@ 103,015 Say OemtoAnsi(STR0069) Size 40,10 OF oFolder:aDialogs[1] Pixel //"Motorista"
			@ 101,050 MSGet cMotorista Picture "@!" Valid ( Os200Motor(cMotorista,@cNomeMot,cCarga) ) F3 "DA4" Size 30,10 OF oFolder:aDialogs[1] Pixel
			@ 101,095 MsGet oNomeMot VAR cNomeMot When .F. Size 148,10 OF oFolder:aDialogs[1] Pixel

			@ 118,015 Say OemtoAnsi(STR0092) Size 40,10 OF oFolder:aDialogs[1] Pixel //"1o. Ajudante"
			@ 116,050 MSGet cAjuda1 Picture "@!" Valid Oms200Aju(cAjuda1,@cNomeAju1,{"",cAjuda2,cAjuda3},cCarga) F3 "DAU" Size 30,10 OF oFolder:aDialogs[1] Pixel
			@ 116,095 MsGet oNomeAju1 VAR cNomeAju1 When .F. Size 148,10 OF oFolder:aDialogs[1] Pixel

			@ 133,015 Say OemtoAnsi(STR0093) Size 40,10 OF oFolder:aDialogs[1] Pixel //"2o. Ajudante"
			@ 131,050 MSGet cAjuda2 Picture "@!" Valid Oms200Aju(cAjuda2,@cNomeAju2,{cAjuda1,"",cAjuda3},cCarga) F3 "DAU" Size 30,10 OF oFolder:aDialogs[1] Pixel
			@ 131,095 MsGet oNomeAju1 VAR cNomeAju2 When .F. Size 148,10 OF oFolder:aDialogs[1] Pixel

			@ 148,015 Say OemtoAnsi(STR0094) Size 40,10 OF oFolder:aDialogs[1] Pixel //"3o. Ajudante"
			@ 146,050 MSGet cAjuda3 Picture "@!" Valid Oms200Aju(cAjuda3,@cNomeAju3,{cAjuda1,cAjuda2,""},cCarga) F3 "DAU" Size 30,10 OF oFolder:aDialogs[1] Pixel
			@ 146,095 MsGet oNomeAju1 VAR cNomeAju3 When .F. Size 148,10 OF oFolder:aDialogs[1] Pixel


			ACTIVATE DIALOG oDlg CENTERED ON INIT (EnchoiceBar( oDlg , { || Iif(MesCodVeic(cVeiculo,cVeiculo2,cVeiculo3),(nOpca := 1,,oDlg:End()),.F.) }, {||nopca := 0,oDlg:End()},,aButtons))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualizo carga com o caminhao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpca == 1
				aArrayCarga[nPosCarga, CARGA_VEIC  ] := cVeiculo
				aArrayCarga[nPosCarga, CARGA_VEI2  ] := cVeiculo2
				aArrayCarga[nPosCarga, CARGA_VEI3  ] := cVeiculo3
				aArrayCarga[nPosCarga, CARGA_MOTOR ] := cMotorista
				aArrayCarga[nPosCarga, CARGA_AJUD1 ] := cAjuda1
				aArrayCarga[nPosCarga, CARGA_AJUD2 ] := cAjuda2
				aArrayCarga[nPosCarga, CARGA_AJUD3 ] := cAjuda3

				If lOs200Ass
					ExecBlock("OS200ASS",.F.,.F.)
				EndIf
			EndIf
			Oms200Time(cHrStart,dDtStart,aArrayMan,aArrayCarga[nPosCarga,CARGA_VEIC],12,6,7,2,3,4,14,15,16,17,18,19,20)
		Else
			Help(" ",1,"OMSPEDMARK") //Não existem pedidos selecionados para a visualização
		EndIf
	Else
		Help(" ",1,"DLACGDISP") //Não existe carga disponível aberta.
	EndIf
	oMark:oBrowse:Refresh()
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OmsVldTranspºAutor  ³Daniel Pereira     º Data ³ 29.01.2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida caminhao na associacao da carga                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5Dl                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OmsVldTransp(cVeiculo,cVeicAtu,cNomeCam,cPlaca,nCapacMax,nLimMax,nPeso,nVolume,nPtoEntr,cMotorista,cNomeMot,cAjuda1,cNomeAju1,cAjuda2,cNomeAju2,cAjuda3,cNomeAju3,aHoras,lContVei,cVeiculo2,cVeiculo3,cNomeVeic2,cNomeVeic3,cPlaca2,cPlaca3,cCarga,cSeqCar)
Local lRet      := .T.
Local lAssociaV := SuperGetmv("MV_CPLTVO",.F.,"1")
Local lAltVeic  := cVeicAtu <> cVeiculo
Local cCplInt   := SuperGetMv("MV_CPLINT",.F.,"2")
Local cCpoCapac := IIf(SuperGetmv("MV_OMSCAPA",.F.,"1")=="1","DA3_CAPACN","DA3_CAPACM")
Local aAreaAnt  := GetArea()
Local cAliasDA3 := Nil
Local cAliasDK0 := Nil
Local cAliasDA4 := Nil
Local cAliasDAU := Nil
Local cAliasDAN := Nil
Local nCapac    := 0
Local ldclNew   := SuperGetMv("MV_DCLNEW",.F.,.F.)

Default lContVei := GetMV('MV_CONTVEI',,.F.) // Parametro para verificar se o sistema devera controlar veiculo/motorista

	cAliasDA3 := GetNextAlias()
	BeginSql Alias cAliasDA3
		SELECT DA3.R_E_C_N_O_ RECNODA3
		FROM %Table:DA3% DA3
		WHERE DA3.DA3_FILIAL = %xFilial:DA3%
		AND DA3.DA3_COD = %Exp:+cVeiculo%
		AND DA3.%NotDel%
	EndSql
	If (cAliasDA3)->(!Eof())
		DA3->(dbGoTo((cAliasDA3)->RECNODA3))
		// Integração OMSxCPL
		If DAK->(ColumnPos("DAK_VIAROT")) > 0 .And. cCplInt == '1' .And. !l200Auto
			cAliasDK0 := GetNextAlias()
			BeginSql Alias cAliasDK0
				SELECT 1
				FROM %Table:DK0% DK0
				WHERE DK0.DK0_FILIAL = %xFilial:DK0%
				AND DK0.DK0_CARGA = %Exp:DAK->DAK_COD%
				AND DK0.DK0_TIPVEI <> %Exp:DA3->DA3_TIPVEI%
				AND DK0.%NotDel%
			EndSql
			If (cAliasDK0)->(!Eof())
				If lAssociaV == "1" //Impedir
					Help(" ",1,"OMS200ASSVEI")// O veículo deve ser do mesmo tipo informado pelo Cockpit Logístico.
					lRet := .F.
				ElseIf lAssociaV == "2"
					If !(MsgYesNo(STR0266," "))
						lRet := .F.
					EndIf
				EndIf
			EndIf
			(cAliasDK0)->(dbCloseArea())
		 EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o peso, o volume e os pontos de entrega ultrapassan os limites³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Pergunte("OMS200",.F.) //Parametro da Montagem de Cargas
		If mv_par05 == 1 .And. lRet
			nCapac := DA3->(FieldGet(ColumnPos(cCpoCapac)))
			If ((nPeso    > nCapac)           .Or. ;
				(nVolume  > DA3->DA3_VOLMAX)  .Or. ;
				(nPtoEntr > DA3->DA3_LIMMAX)) .And.;
				DA3->DA3_ATIVO == "1"
				Help(" ",1,"OMSULTCARG") //Caminhao nao suporta carga montada
				lRet := .F.
			ElseIf  DA3->DA3_ATIVO == "2"
				Help(" ",1,"OMSCAMINDS")  //Caminhao indisponivel
				lRet := .F.
			EndIf
		EndIf
		Pergunte("OMS20A",.F.) //Restaura Parametros da tela de Cargas

		If lRet .And. (!Empty(cVeicAtu) .Or. IsIncallstack("Os200Assoc")) .And. lAltVeic
			If !OmsVeiDisp(cVeiculo,aHoras[1],aHoras[2],aHoras[3],aHoras[4],cCarga,cSeqCar)
				Help(" ",1,"OMSVEIEMP") //Veículo já empenhado em outra carga ou viagem.
				lRet := .F.
			Else
				If ldclNew
					cAliasDAN := GetNextAlias()
					BeginSql Alias cAliasDAN
						SELECT D3B.D3B_LACRES FROM %Table:DAN% DAN 
						  INNER JOIN %Table:D3B% D3B
						  ON D3B.D3B_FILIAL = %xFilial:DAN%
						  AND D3B.D3B_CODCAR = %Exp:cCarga%
						  AND D3B.%NotDel%
						WHERE DAN.DAN_FILIAL = %xFilial:DAN%
						  AND DAN.DAN_CODVEI = %Exp:cVeicAtu%
						  AND DAN.DAN_CODCAR = %Exp:cCarga% 
						  AND DAN.DAN_SEQCAR = %Exp:cSeqCar% 
						  AND DAN.%NotDel%
					EndSql
					If (cAliasDAN)->(!Eof())
						If !Empty((cAliasDAN)->D3B_LACRES)
							//CheckHLP( cKey, aHelpPor, aHelpEng, aHelpSpa, lUpdate, cStatus)
							CheckHLP('POMSA20001', {'Há lacres associados nos', ' compartimentos !!'},{''},{''},.T.) //Há lacres associados nos compartimentos !!" 
							CheckHLP('SOMSA20001', {'Para alterar o veículo é necessário', ' estornar os lacres dos compartimentos.'},{''},{''},.T.) // Para alterar o veículo é necessário estornar os lacres dos compartimentos.
							Help("",1,"OMSA20001")
							lRet := .F.
						EndIf
					EndIf
					(cAliasDAN)->(dbCloseArea())
				EndIf
			EndIf
		Else
			If ldclNew
				cAliasDAN := GetNextAlias()
				BeginSql Alias cAliasDAN
					SELECT D3B.D3B_LACRES FROM %Table:DAN% DAN 
						INNER JOIN %Table:D3B% D3B
						ON D3B.D3B_FILIAL = %xFilial:DAN%
						AND D3B.D3B_CODCAR = %Exp:cCarga%
						AND D3B.%NotDel%
					WHERE DAN.DAN_FILIAL = %xFilial:DAN%
						AND DAN.DAN_CODVEI = %Exp:cVeicAtu%
						AND DAN.DAN_CODCAR = %Exp:cCarga% 
						AND DAN.DAN_SEQCAR = %Exp:cSeqCar% 
						AND DAN.%NotDel%
				EndSql
				If (cAliasDAN)->(!Eof())
					If !Empty((cAliasDAN)->D3B_LACRES)
						//CheckHLP( cKey, aHelpPor, aHelpEng, aHelpSpa, lUpdate, cStatus)
						CheckHLP('POMSA20001', {'Há lacres associados nos', ' compartimentos !!'},{''},{''},.T.) //Há lacres associados nos compartimentos !!" 
						CheckHLP('SOMSA20001', {'Para alterar o veículo é necessário', ' estornar os lacres dos compartimentos.'},{''},{''},.T.) // Para alterar o veículo é necessário estornar os lacres dos compartimentos.
						Help("",1,"OMSA20001")
						lRet := .F.
					EndIf
				EndIf
				(cAliasDAN)->(dbCloseArea())
			EndIf
		EndIf
		If lRet
			If RecLock("DA3")
				cVeicAtu := cVeiculo
			Else
				lRet := .F.
			EndIf
		EndIf
		If lRet
			cNomeCam   := DA3->DA3_DESC
			cPlaca     := DA3->DA3_PLACA
			nCapacMax  := DA3->DA3_CAPACM
			nLimMax    := DA3->DA3_LIMMAX
			If lAltVeic
				If !Empty(DA3->DA3_MOTORI)
					cAliasDA4 := GetNextAlias()
					BeginSql Alias cAliasDA4
						SELECT DA4.DA4_NOME,
								DA4.DA4_AJUDA1,
								DA4.DA4_AJUDA2,
								DA4.DA4_AJUDA3
						FROM %Table:DA4% DA4
						WHERE DA4.DA4_FILIAL = %xFilial:DA4%
						AND DA4.DA4_COD = %Exp:DA3->DA3_MOTORI%
					EndSql
					If (cAliasDA4)->(!Eof())
						cMotorista  := DA3->DA3_MOTORI
						cNomeMot := (cAliasDA4)->DA4_NOME
						// Primeiro ajudante
						If Empty(cAjuda1)
							cAliasDAU := GetNextAlias()
							BeginSql Alias cAliasDAU
								SELECT DAU.DAU_COD,
										DAU.DAU_NOME
								FROM %Table:DAU% DAU
								WHERE DAU.DAU_FILIAL = %xFilial:DAU%
								AND DAU.DAU_COD = %Exp:(cAliasDA4)->DA4_AJUDA1%
								AND DAU.%NotDel%
							EndSql
							If (cAliasDAU)->(!Eof())
								cAjuda1   := (cAliasDAU)->DAU_COD
								cNomeAju1 := (cAliasDAU)->DAU_NOME
							EndIf
							(cAliasDAU)->(dbCloseArea())
						EndIf
						// Segundo ajudante
						If Empty(cAjuda2)
							cAliasDAU := GetNextAlias()
							BeginSql Alias cAliasDAU
								SELECT DAU.DAU_COD,
										DAU.DAU_NOME
								FROM %Table:DAU% DAU
								WHERE DAU.DAU_FILIAL = %xFilial:DAU%
								AND DAU.DAU_COD = %Exp:(cAliasDA4)->DA4_AJUDA2%
								AND DAU.%NotDel%
							EndSql
							If (cAliasDAU)->(!Eof())
								cAjuda2   := (cAliasDAU)->DAU_COD
								cNomeAju2 := (cAliasDAU)->DAU_NOME
							EndIf
							(cAliasDAU)->(dbCloseArea())
						EndIf
						// Terceiro ajudante
						If Empty(cAjuda3)
							cAliasDAU := GetNextAlias()
							BeginSql Alias cAliasDAU
								SELECT DAU.DAU_COD,
										DAU.DAU_NOME
								FROM %Table:DAU% DAU
								WHERE DAU.DAU_FILIAL = %xFilial:DAU%
								AND DAU.DAU_COD = %Exp:(cAliasDA4)->DA4_AJUDA3%
								AND DAU.%NotDel%
							EndSql
							If (cAliasDAU)->(!Eof())
								cAjuda3   := (cAliasDAU)->DAU_COD
								cNomeAju3 := (cAliasDAU)->DAU_NOME
							EndIf
							(cAliasDAU)->(dbCloseArea())
						EndIf
					EndIf
					(cAliasDA4)->(dbCloseArea())
				Else
					cAjuda1    := Criavar("DAU_COD",.F.)
					cAjuda2    := Criavar("DAU_COD",.F.)
					cAjuda3    := Criavar("DAU_COD",.F.)
					cMotorista := Criavar("DAU_COD",.F.)
					cNomeMot   := ""
					cNomeAju1  := ""
					cNomeAju2  := ""
					cNomeAju3  := ""
				EndIf
			EndIf
			oNomeCam:Refresh()
			oPlaca:Refresh()
			oCapacMax:Refresh()
			oLimMax:Refresh()
			oNomeMot:Refresh()
		EndIf
		//-- Ponto de Entrada para validar o veiculo
		If lRet
			If ExistBlock("OM200VEI")
				lRetPE := ExecBlock("OM200VEI",.F.,.F.,{cVeiculo})
				lRet   := If(ValType(lRetPE)=="L", lRetPE, lRet)
			EndIf
		EndIf
	ElseIf !Empty(cVeiculo)
		Help(" ",1,"REGNOIS")//Mensagem de registro nao relacionado
		lRet := .F.
	ElseIf Empty(cVeiculo) .And. !Empty(cVeicAtu) .And. lDclNew
		cAliasDAN := GetNextAlias()
		BeginSql Alias cAliasDAN
			SELECT D3B.D3B_LACRES FROM %Table:DAN% DAN 
				INNER JOIN %Table:D3B% D3B
				ON D3B.D3B_FILIAL = %xFilial:DAN%
				AND D3B.D3B_CODCAR = %Exp:cCarga%
				AND D3B.%NotDel%
			WHERE DAN.DAN_FILIAL = %xFilial:DAN%
				AND DAN.DAN_CODVEI = %Exp:cVeicAtu%
				AND DAN.DAN_CODCAR = %Exp:cCarga% 
				AND DAN.DAN_SEQCAR = %Exp:cSeqCar% 
				AND DAN.%NotDel%
		EndSql
		If (cAliasDAN)->(!Eof())
			If !Empty((cAliasDAN)->D3B_LACRES)
				//CheckHLP( cKey, aHelpPor, aHelpEng, aHelpSpa, lUpdate, cStatus)
				CheckHLP('POMSA20001', {'Há lacres associados nos', ' compartimentos !!'},{''},{''},.T.) //Há lacres associados nos compartimentos !!" 
				CheckHLP('SOMSA20001', {'Para alterar o veículo é necessário', ' estornar os lacres dos compartimentos.'},{''},{''},.T.) // Para alterar o veículo é necessário estornar os lacres dos compartimentos.
				Help("",1,"OMSA20001")
				lRet := .F.
			EndIf
		EndIf
		(cAliasDAN)->(dbCloseArea())
	ElseIf Empty(cVeiculo)
		cVeiculo2  := Criavar("DA3_COD",.F.)
		cVeiculo3  := Criavar("DA3_COD",.F.)
		cNomeCam   := ""
		cNomeVeic2 := ""
		cNomeVeic3 := ""
		cPlaca     := ""
		cPlaca2    := ""
		cPlaca3    := ""
		nCapacMax  := ""
		nLimMax    := ""
		cMotorista := Criavar("DA4_COD",.F.)
		cNomeMot   := ""
		cAjuda1    := Criavar("DAU_COD",.F.)
		cAjuda2    := Criavar("DAU_COD",.F.)
		cAjuda3    := Criavar("DAU_COD",.F.)
		cNomeAju1  := ""
		cNomeAju2  := ""
		cNomeAju3  := ""
		oNomeCam:Refresh()
		oPlaca:Refresh()
		oCapacMax:Refresh()
		oLimMax:Refresh()
		oNomeMot:Refresh()
	EndIf
	(cAliasDA3)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------------------
/*/{Protheus.doc} MesCodVeic
Valida se os códigos de veículo informados são iguais entre si

@author  Daniel Pereira de Souza
@version P12
@since   29.01.2021
/*/
//------------------------------------------------------
Static Function MesCodVeic(cVeiculo,cVeiculo2,cVeiculo3)
	If (!Empty(cVeiculo2) .And. AllTrim(cVeiculo2) $ (cVeiculo+cVeiculo3)) .Or.;
		(!Empty(cVeiculo3) .And. AllTrim(cVeiculo3) $ (cVeiculo+cVeiculo2))
		MsgAlert("Os veículos informados devem ser diferentes entre si!",OMSA20001)
		Return .F.
	EndIf
Return .T.
//-----------------------------------------------------
/*/{Protheus.doc} VldReboque
Efetua a validação dos campos Veículo 2 e Veículo 3
da tela de Associação de Veículos

@author  Daniel Pereira de Souza 
@version P12
@since   29.01.2021
/*/
//------------------------------------------------------
Static Function VldReboque(cVeiculo,cNomeVeic,cPlaca,aHoras,cCarga,cSeqCar)
Local lRet      := .T.
Local cAliasDA3 := Nil
	If !Empty(cVeiculo)
		cAliasDA3 := GetNextAlias()
		BeginSql Alias cAliasDA3
			SELECT DA3.DA3_DESC,
					DA3.DA3_PLACA
			FROM %Table:DA3% DA3
			WHERE DA3.DA3_FILIAL = %xFilial:DA3%
			AND DA3.DA3_COD = %Exp:+cVeiculo%
			AND DA3.%NotDel%
		EndSql
		If (cAliasDA3)->(!Eof())
			If !OmsVeiDisp(cVeiculo,aHoras[1],aHoras[2],aHoras[3],aHoras[4],cCarga,cSeqCar)
				Help(" ",1,"OMSVEIEMP") // Veículo já empenhado em outra carga ou viagem
				lRet := .F.
			EndIf
			If lRet
				cNomeVeic := (cAliasDA3)->DA3_DESC
				cPlaca    := (cAliasDA3)->DA3_PLACA
			EndIf
		Else
			Help(" ",1,"REGNOIS") // Mensagem de registro nao relacionado
			lRet := .F.
		EndIf
		(cAliasDA3)->(dbCloseArea())
	EndIf
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OmsVldSeq ºAutor  ³Daniel Pereira      º Data ³ 29.01.2021  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao Validacao da sequencia na carga se ja existe        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cSequencia := Sequencia digitada                           º±±
±±º          ³ cCarga     := Carga Disponivel para verificacao            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OmsVldSeq(cSequencia,cRota,aArrayMan)
Local lRet := .T.
	If  Ascan(aArrayMan,{|x| x[1]+x[2] == cSequencia+cRota}) > 0
		lRet := .F.
		Help(" ",1,"OMSSEQEXIS") //Sequencia ja existe na carga disponivel
	EndIf
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³Os200Estor³ Autor ³ Daniel Pereira        ³ Data ³ 29.01.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Processa o estorno de cargas indicadas                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ap5Dl                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Revisao  ³                                          ³ Data ³ 27.01.00   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Os200Estor()
Local cMens := ""
Local lRet  := .T.
	If lRet := OMSVlEstDAK()
		cMens := OemToAnsi(STR0052) //"Confirma estorno das Cargas selecionadas ? Os Pedidos de Venda contidos nestas "
		cMens := cMens + OemToAnsi(STR0053) //"Cargas voltarao a ficar sem carga definida e aptos a serem utilizados em outras Cargas."
		If l200Auto .Or. MsgYesNo(cMens,OemToAnsi(STR0054)) // Atenção
			Processa( { || Os200ProcEst(DAK->DAK_COD) }, cCadastro, OemtoAnsi(STR0055) ) //"Estornando Cargas..."
		EndIf
	EndIf
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³Os200ProcEst³ Autor ³ Daniel p            ³ Data ³ 19/01/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Efetivamente estorna as cargas indicadas                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ap5Dl                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Os200ProcEst(cCarga,cDakTransp)
Local lOS200Est := ExistBlock("OS200EST")
Local lContinua := .T.
Local lDclNew   := SuperGetMv("MV_DCLNEW",.F.,.F.)
Local aArea     := GetArea()
Local aAreaSC9  := SC9->(GetArea())
Local oMdl
Local cFilPV    := ""
Local cCplInt   := SuperGetMv("MV_CPLINT",.F.,"2")
Local cAliasDAI := Nil
Local cAliasSC9 := Nil
Local cAliasSC5 := Nil
Local cAliasDk0 := Nil
Local nTpVlEnt  := OsVlEntCom()

Default cDakTransp := Criavar("A4_COD",.F.)
	If FindFunction("MaEnvEAI")
		oMdl := MaEnvEAI(/*cEmpX*/, /*cFilX*/, /*nOpcx*/5, /*cMainModel*/"OMSA200", /*aStruModel*/, /*lHelp*/, /*lEnvia*/.F., /*lLoadModel*/, /*oMdl*/, /*cXml*/, /*cFunName*/)
	EndIf

	Begin Transaction
		If lOS200Est
			ExecBlock("OS200EST",.F.,.F.,{DAK->DAK_COD,DAK->DAK_SEQCAR})
		EndIf

		cAliasDAI := GetNextAlias()
		If nTpVlEnt <> 1
			BeginSql Alias cAliasDAI
				SELECT DAI.R_E_C_N_O_ RECNODAI,
						DAI.DAI_FILPV
				FROM %Table:DAI% DAI
				WHERE DAI.DAI_FILIAL = %xFilial:DAI%
				AND DAI.DAI_COD = %Exp:DAK->DAK_COD%
				AND DAI.DAI_SEQCAR = %Exp:DAK->DAK_SEQCAR%
				AND DAI.%NotDel%
			EndSql
		Else
			BeginSql Alias cAliasDAI
				SELECT DAI.R_E_C_N_O_ RECNODAI
				FROM %Table:DAI% DAI
				WHERE DAI.DAI_FILIAL = %xFilial:DAI%
				AND DAI.DAI_COD = %Exp:DAK->DAK_COD%
				AND DAI.DAI_SEQCAR = %Exp:DAK->DAK_SEQCAR%
				AND DAI.%NotDel%
			EndSql
		EndIf
		Do While (cAliasDAI)->(!Eof())
			cFilPv := IIf(nTpVlEnt<>1,(cAliasDAI)->DAI_FILPV,xFilial("SC9"))
			cAliasSC9 := GetNextAlias()
			BeginSql Alias cAliasSC9
				SELECT SC9.R_E_C_N_O_ RECNOSC9
				FROM %Table:SC9% SC9
				WHERE SC9.C9_FILIAL = %Exp:OsFilial("SC9",cFilPv)%
				AND SC9.C9_CARGA = %Exp:DAK->DAK_COD%
				AND SC9.C9_SEQCAR = %Exp:DAK->DAK_SEQCAR%
				AND SC9.%NotDel%
			EndSql
			// Limpa a carga do SC9
			Do While (cAliasSC9)->(!Eof())
				SC9->(dbGoTo((cAliasSC9)->RECNOSC9))
				cAliasSC5 := GetNextAlias()
				BeginSql Alias cAliasSC5
					SELECT SC5.R_E_C_N_O_ RECNOSC5,
							SC5.C5_GERAWMS
					FROM %Table:SC5% SC5
					WHERE SC5.C5_FILIAL = %Exp:OsFilial("SC5",cFilPv)%
					AND SC5.C5_NUM = %Exp:SC9->C9_PEDIDO%
					AND SC5.%NotDel%
				EndSql
				If (cAliasSC5)->(!Eof())
					// Exclui a Transportadora do pedido de venda
					If DAK->(ColumnPos('DAK_TRANSP')) > 0
						SC5->(dbGoTo((cAliasSC5)->RECNOSC5))
						If !Empty( DAK->DAK_TRANSP )
							RecLock('SC5',.F.)
							SC5->C5_TRANSP := ""
							SC5->(MsUnlock())
						EndIf
					EndIf
				EndIf
				//Exclui a integração com o módulo WMS
				//-- 1=no Pedido;2=na Montagem da Carga;3=na Unitizacao da Carga
				If (cAliasSC5)->C5_GERAWMS <> "1" .And. IntWms(SC9->C9_PRODUTO) .And. !Empty(SC9->C9_SERVIC)
					WmsUndoPed((cAliasSC9)->RECNOSC9)
				EndIf
				(cAliasSC5)->(dbCloseArea())
				//-- 8.Estorno Mont.Carga
				MaAvalSC9("SC9",8)
				//-- Restaura RecNo
				(cAliasSC9)->(dbSkip())
			EndDo
			(cAliasSC9)->(dbCloseArea())
			(cAliasDAI)->(dbSkip())
		EndDo
		(cAliasDAI)->(dbCloseArea())
		//-- Template DCL-EST - Estorno de Cargas com Compartimentos/Lacres associados.
		If lDclNew
			DCLOS200ES(DAK->DAK_COD,DAK->DAK_SEQCAR)
		ElseIf ExistTemplate("OS200ES2")
			ExecTemplate("OS200ES2",.F.,.F.,{DAK->DAK_COD,DAK->DAK_SEQCAR})
		EndIf
		//-- PE executado no final do estorno da carga
		If ExistBlock("OS200ES2")
			ExecBlock("OS200ES2",.F.,.F.,{DAK->DAK_COD,DAK->DAK_SEQCAR})
		EndIf
		//-- Integração Protheus x GFE (EXCLUSAO)
		If !OMSA200IPG(5,,,.T.,,,,cDakTransp)
			DisarmTransaction()
			lContinua := .F.
		EndIf
	End Transaction

	If lContinua
		If FindFunction("MaEnvEAI")
			MaEnvEAI(/*cEmpX*/, /*cFilX*/, /*nOpcx*/5, /*cMainModel*/ "OMSA200", /*aStruModel*/, /*lHelp*/, /*lEnvia*/, /*lLoadModel*/.F., oMdl, /*cXml*/, /*cFunName*/)
		EndIf
	EndIf
	// Atualiza as informações das tabelas da integração Cockpit Logístico
	If DAK->(ColumnPos("DAK_VIAROT")) > 0
		If !Empty(DAK->DAK_VIAROT) .And. cCplInt == '1'
			cAliasDK0 := GetNextAlias()
			BeginSql Alias cAliasDK0
				SELECT DK0.R_E_C_N_O_ RECNODK0
				FROM %Table:DK0% DK0
				WHERE DK0.DK0_FILIAL = %xFilial:DK0%
				AND DK0.DK0_CARGA = %Exp:DAK->DAK_COD%
				AND DK0.%NotDel%
			EndSql
			If (cAliasDK0)->(!Eof())
				DK0->(dbGoTo((cAliasDK0)->RECNODK0))

				RecLock('DK0',.F.)
				DK0->DK0_CARGER := '2'
				DK0->DK0_CARGA  := ''
				DK0->(MsUnLock())
			EndIf
			(cAliasDK0)->(dbCloseArea())
		Endif
	Endif
	//Integração Agroindustria - SIGAAGR
	If FindFunction("OGX225AGE") .And. (SuperGetMV("MV_AGRUBS",.F.,.F.))
		OGX225AGE()
	Endif
	RestArea(aAreaSC9)
	RestArea(aArea)
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Os200Manut³ Autor ³ Daniel P            ³ Data ³ 02/02/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manipulacao de Pedidos por Carga                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico (DISTRIBUIDORES)                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Os200Manut(cAlias,nReg,nOpc)

Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local aRecno    := {}
Local aButtons  := {}
Local aAcho     := {"DAK_COD",  "DAK_SEQCAR","DAK_ROTEIR","DAK_CAMINH","DAK_MOTORI","DAK_PESO",  "DAK_CAPVOL","DAK_PTOENT",;
					"DAK_VALOR","DAK_DATA",  "DAK_HORA",  "DAK_AJUDA1","DAK_AJUDA2","DAK_AJUDA3","DAK_FLGUNI","DAK_HRSTAR","DAK_TRANSP","DAK_NOMTRA"}
Local aCpos := {"DAK_TRANSP","DAK_NOMTRA"}
Local cHrStart  := ""
Local dDtStart  := CTOD( "" )
Local nOpca     := 0
Local lProcessa := .T.
Local lBloqueio := OsBlqExec(DAK->DAK_COD, DAK->DAK_SEQCAR)

Local cSeek     := ""
Local cWhile    := ""
Local bCond     := {|| .T.}                 // Se bCond .T. executa bAction1, senao executa bAction2
Local bAction1  := {|| Oms200Rec(@aRecno) } // Retornar .T. para considerar o registro e .F. para desconsiderar
Local bAction2  := {|| .F. }                // Retornar .T. para considerar o registro e .F. para desconsiderar
Local cCplInt   := SuperGetMv("MV_CPLINT",.F.,"2")

Private cCadastro := Iif(nOpc == 5,OemtoAnsi(STR0056),OemtoAnsi(STR0147)) // Manipulacao de Pedidos Por Carga
Private aTela[0][0],aGets[0]

Private lWmsPergEP := .T.

	AAdd( aButtons ,{ "PESQUISA" ,{ || GdSeek(oGetD,OemtoAnsi(STR0060)) },      OemtoAnsi(STR0060),OemtoAnsi(STR0060) } ) // Pesquisar
	AAdd( aButtons ,{ "CARGASEQ" ,{ || Os200SeqMn(aRecno,@cHrStart,@dDtStart)}, OemtoAnsi(STR0009),OemtoAnsi(STR0167) } ) // Sequencia de Entrega // Seq. Ent.
	AAdd( aButtons ,{ "EXCLUIR"  ,{ || Os200DelSC9()},                          OemtoAnsi(STR0214),OemtoAnsi(STR0213) } ) // Estorno do item do pedido // Est.Ped
	//Integração OMSxCPL
	If DAK->(ColumnPos("DAK_VIAROT")) > 0
		If !Empty(DAK->DAK_VIAROT) .And. cCplInt == '1'
			Help(" ",1,"OMS200MNTCPL") // Carga gerada pela integração com o Cockpit Logístico, manutenção não permitida.
			Return
		EndIf
	EndIf
	If  GetMV("MV_MANCARG") == "N" .And. DAK->DAK_FEZNF == "1"
		Help(" ",1,"OMS200CFAT") // Esta carga já se encontra faturada.
		Return
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Primeiro verifica se a carga selecionada ainda pode ser edit.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(DAK->DAK_JUNTOU) .And. DAK->DAK_JUNTOU != "JUNTOU" .And. DAK->DAK_JUNTOU != "MANUAL" .And. DAK->DAK_JUNTOU != "ASSOCI"
		Help(" ",1,"DS2602141") // A carga selecionada está indisponível para manipulaçães.
		lProcessa := .F.
	EndIf

	If DAK->DAK_ACECAR == "1"
		Help(" ",1,"DS2602143") //Retorno de Cargas já realizado, não é possível a ManipulaçÆo desta Carga.
		lProcessa := .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe o campo e se esta bloqueada                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If DAK->DAK_BLQCAR == '1' .Or. lBloqueio
		lProcessa := .F.
		Help(" ",1,"OMS200CGBL") //Carga bloqueada ou com serviço em execução.
	EndIf

	If lProcessa
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria variaveis M->????? da Enchoice                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RegToMemory( "DAK", .F., .F. )
		SoftLock("DAK")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega a data e hora de inicio da carga gravada                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cHrStart := DAK->DAK_HRSTAR
		dDtStart := DAK->DAK_DATA
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria aHeader da GetDados                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nUsado  := 0
		aHeader := {}
		n       := 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do aHeader e aCols                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³FillGetDados( nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, uSeekFor, aNoFields, aYesFields, lOnlyYes,       ³
		//³              cQuery, bMountFile, lInclui )                                                                 ³
		//³nOpcx        - Opcao (inclusao, exclusao, etc).                                                             ³
		//³cAlias       - Alias da tabela referente aos itens                                                          ³
		//³nOrder       - Ordem do SINDEX                                                                              ³
		//³cSeekKey     - Chave de pesquisa                                                                            ³
		//³bSeekWhile   - Loop na tabela cAlias                                                                        ³
		//³uSeekFor     - Valida cada registro da tabela cAlias (retornar .T. para considerar e .F. para desconsiderar ³
		//³               o registro)                                                                                  ³
		//³aNoFields    - Array com nome dos campos que serao excluidos na montagem do aHeader                         ³
		//³aYesFields   - Array com nome dos campos que serao incluidos na montagem do aHeader                         ³
		//³lOnlyYes     - Flag indicando se considera somente os campos declarados no aYesFields + campos do usuario   ³
		//³cQuery       - Query para filtro da tabela cAlias (se for TOP e cQuery estiver preenchido, desconsidera     ³
		//³               parametros cSeekKey e bSeekWhiele)                                                           ³
		//³bMountFile   - Preenchimento do aCols pelo usuario (aHeader e aCols ja estarao criados)                     ³
		//³lInclui      - Se inclusao passar .T. para qua aCols seja incializada com 1 linha em branco                 ³
		//³aHeaderAux   -                                                                                              ³
		//³aColsAux     -                                                                                              ³
		//³bAfterCols   - Bloco executado apos inclusao de cada linha no aCols                                         ³
		//³bBeforeCols  - Bloco executado antes da inclusao de cada linha no aCols                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("DAI")
		cSeek  := xFilial("DAI")+DAK->DAK_COD+DAK_SEQCAR
		cWhile := "DAI_FILIAL+DAI_COD+DAI_SEQCAR"
		FillGetDados(2,"DAI",1,cSeek,{|| &cWhile },{{bCond,bAction1,bAction2}},/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*Inclui*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bBeforeCols*/)
		// Carrega maualmente a validacao do campo DAI_COD pois a funcao esta no fonte e nao nao no dicionario.
		aHeader[GdFieldPos("DAI_COD")][6] := "D200VlCg2()"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa a Modelo 3                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSize := MsAdvSize()
		AAdd( aObjects, { 100, 100, .T., .T. } )
		AAdd( aObjects, { 200, 200, .T., .T. } )
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
		aPosObj := MsObjSize( aInfo, aObjects,.T.)

		DEFINE MSDIALOG oDlg1 TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exibe as informacoes fixas de acordo com a opcao escolhida.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("DAK")
		EnChoice("DAK", nReg, 2, , , , aAcho,aPosObj[1], aCpos, 3, , , , , , .F.)

		DbSelectArea("DAI")
		oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"Os200LOk","AllWaysTrue()", ,.T., Nil,,,Len(aCols))

		ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{||nOpcA := 1,If(OS200TOk().And.oGetd:TudoOk(),If(!Obrigatorio(aGets,aTela),nOpcA := 0,oDlg1:End()),nOpcA := 0)},{||oDlg1:End()},,aButtons)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o retorno for verdadeiro, grava os dados alterados        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpca == 1
			Begin Transaction
				lGravou := Os200ProcMan()
			End Transaction
		EndIf
		MsUnlockAll()
	EndIf
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Os200ProcManºAutor  ³ Daniel P         º Data ³  25/01/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processamento da manipulacao da carga                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5Dl                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function xOs200ProcManx()

Local aRotas     := {}
Local nPosCar    := AScan( aHeader ,{|x|Alltrim(x[2])=="DAI_COD"   } )
Local nPosSeqCar := AScan( aHeader ,{|x|Alltrim(x[2])=="DAI_SEQCAR"} )
Local nPosSeq    := AScan( aHeader ,{|x|Alltrim(x[2])=="DAI_SEQUEN"} )
Local nPosPed    := AScan( aHeader ,{|x|Alltrim(x[2])=="DAI_PEDIDO"} )
Local nPosRota   := AScan( aHeader ,{|x|Alltrim(x[2])=="DAI_ROTEIR"} )
Local nPosZona   := AScan( aHeader ,{|x|Alltrim(x[2])=="DAI_PERCUR"} )
Local nPosSetor  := AScan( aHeader ,{|x|Alltrim(x[2])=="DAI_ROTA"  } )
Local nPosTime   := AScan( aHeader ,{|x|Alltrim(x[2])=="DAI_CHEGAD"} )
Local nPosSrv    := AScan( aHeader ,{|x|Alltrim(x[2])=="DAI_TMSERV"} )
Local nPosDtC    := AScan( aHeader ,{|x|Alltrim(x[2])=="DAI_DTCHEG"} )
Local nPosDtS    := AScan( aHeader ,{|x|Alltrim(x[2])=="DAI_DTSAID"} )
Local nRegSC9    := 0
Local nUsado     := Len(aHeader)+1
Local nTpVlEnt   := OsVlEntCom()
Local nElem      := 0
Local lTransp    := DAK->(ColumnPos("DAK_TRANSP")) > 0
Local cCarOri    := M->DAK_COD
Local cSeqOri    := M->DAK_SEQCAR
Local lGravou    := .F.
Local cFilPv     := IIf(nTpVlEnt<>1,DAI->DAI_FILPV,xFilial("SC9"))
Local lNumProp   := SuperGetMv("MV_EMITMP",.F.,"0") == "1" .And. SuperGetMv("MV_INTGFE2",.F.,"2") == "1"
Local cCgcTransp := ""
	//-- Grava no cabecalho da carga os horarios!
	RecLock("DAK")
	DAK->DAK_DATA   := M->DAK_DATA
	DAK->DAK_HORA   := M->DAK_HORA
	DAK->DAK_HRSTAR := M->DAK_HRSTAR
	If lTransp
		DAK->DAK_TRANSP := M->DAK_TRANSP
	EndIf
	MsUnlock()
	//-- Varre todas as linhas do aCols
	aCols := aSort(aCols,,,{|x,y| x[nPosCar]+x[nPosSeqCar]+x[nPosSeq] < y[nPosCar]+y[nPosSeqCar]+y[nPosSeq]})
	For nElem := 1 to Len(aCols)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o item de carga correspondente a linha do aCols    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("DAI")
		DAI->(DbSetOrder(4)) //DAI_FILIAL+DAI_PEDIDO+DAI_COD+DAI_SEQCAR
		If MsSeek(xFilial("DAI")+aCols[nElem][nPosPed]+cCarOri+cSeqOri)
			If lTransp
				//Altera a Transportadora do Pedido
				If !Empty(M->DAK_TRANSP)
					DbSelectArea("SC5")
					SC5->(DbSetOrder(1))
					If SC5->(MsSeek(xFilial("SC5")+DAI->DAI_PEDIDO))
						If SC5->C5_TRANSP <> M->DAK_TRANSP
							RecLock('SC5',.F.)
							SC5->C5_TRANSP := M->DAK_TRANSP
							SC5->(MsUnlock())
						EndIf
					EndIf
				EndIf
				//Altera a Transportadora do Romaneio
				If AliasIndic('GWN')
					DbSelectArea("GWN")
					GWN->(DbSetOrder(1))
					If GWN->(MsSeek(xFilial("GWN")+M->DAK_COD+M->DAK_SEQCAR))
						If lNumProp
							cCgcTransp := Posicione('GU3',13,xFilial('GU3')+M->DAK_TRANSP,'GU3_CDEMIT')
						ELse
							cCgcTransp := Posicione('SA4',1,xFilial('SA4')+M->DAK_TRANSP,'A4_CGC')
						EndIf
							RecLock('GWN',.F.)
							GWN->GWN_CDTRP := cCgcTransp
							GWN->(MsUnlock())
					EndIf
				EndIf
			EndIf
			//-- Verifica se usa Operador Logistico: Entrega compartilhada (pedidos de outras filiais)
			cFilPv := IIf(nTpVlEnt<>1,DAI->DAI_FILPV,xFilial("SC9"))
			Do Case
				Case !aCols[nElem][nUsado] .And.( aCols[nElem][nPosSeq] <> DAI->DAI_SEQUEN )
					//-- Procura no SC9 o registro correspondente e atualiza a carga
					DbSelectArea("SC9")
					SC9->(DbSetOrder(5)) //C9_FILIAL+C9_CARGA+C9_SEQCAR+C9_SEQENT
					If MsSeek(OsFilial("SC9",cFilPv)+DAI->DAI_COD+DAI->DAI_SEQCAR+DAI->DAI_SEQUEN)
						Do While !Eof() .And.  SC9->(C9_FILIAL + C9_CARGA + C9_SEQCAR + C9_SEQENT) == ;
											OsFilial("SC9",cFilPv)+DAI->(DAI_COD + DAI_SEQCAR + DAI_SEQUEN)
							SC9->(DbSkip())
							nRegSC9 := SC9->(Recno())
							SC9->(DbSkip(-1))
							If DAI->DAI_PEDIDO == SC9->C9_PEDIDO
								RecLock("SC9")
								SC9->C9_SEQENT:= aCols[nElem][nPosSeq]
								SC9->(MsUnlock())
								SF2->(DbSetOrder(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
								If SF2->(MsSeek(xFilial("SF2")+SC9->C9_NFISCAL+SC9->C9_SERIENF+SC9->C9_CLIENTE+SC9->C9_LOJA)) .And. ;
									SF2->F2_SEQENT <> SC9->C9_SEQENT
									RecLock("SF2")
									SF2->F2_SEQENT := aCols[nElem][nPosSeq]
									SF2->(MsUnlock())
								EndIf
							EndIf
							SC9->(MsGoto(nRegSC9))
						EndDo
					EndIf
					Reclock("DAI")
					DAI->DAI_SEQUEN := aCols[nElem,nPosSeq]
					If !Empty( nPosSrv )
						DAI->DAI_TMSERV := aCols[nElem,nPosSrv ]
					EndIf
					If !Empty( nPosTime )
						DAI->DAI_CHEGAD := aCols[nElem,nPosTime]
					EndIf
					If !Empty( nPosDtC )
						DAI->DAI_DTCHEG := aCols[nElem,nPosDtC ]
					EndIf
					If !Empty( nPosDtS )
						DAI->DAI_DTSAID := aCols[nElem,nPosDtS ]
					EndIf
					DAI->(MsUnlock())
				//-- Verifica se houve alteracao do numero da carga
				Case !aCols[nElem][nUsado] .And. ( aCols[nElem][nPosCar   ] <> DAI->DAI_COD .Or. ;
													aCols[nElem][nPosSeqcar] <> DAI->DAI_SEQCAR )

					DbSelectArea("SC9")
					SC9->(DbSetOrder(1))
					If MsSeek(OsFilial("SC9",cFilPv)+aCols[nElem][nPosPed])
						While SC9->(!Eof()) .And. SC9->C9_FILIAL == OsFilial("SC9",cFilPv) .And.;
								SC9->C9_PEDIDO  == aCols[nElem][nPosPed]
							If SC9->C9_CARGA == cCarOri .And. SC9->C9_SEQCAR == cSeqOri
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Exclui o SC9 da carga origem                                   ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								MaAvalSC9("SC9",8)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Atualiza SC9 com a nova carga                                  ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								Reclock("SC9",.F.)
								SC9->C9_CARGA  := aCols[nElem][nPosCar   ]
								SC9->C9_SEQCAR := aCols[nElem][nPosSeqCar]
								SC9->C9_SEQENT := OsSeqEnt(SC9->C9_CARGA,SC9->C9_SEQCAR,SC9->C9_PEDIDO)
								SC9->(MsUnlock())
								//-- Array com os dados da roteirizacao
								//   [01] Codigo da Rota
								//   [02] Codigo da Zona
								//   [03] Codigo do Setor
								//   [04] Motorista
								//   [05] Caminhao
								//   [06] Ajudante 1
								//   [07] Ajudante 2
								//   [08] Ajudante 3
								//   [09] Hora chegada
								//   [10] Time Service
								//   [11] Data chegada
								//   [12] Data saida
								//   [13] Hora de inicio de entrega
								//   [14] Valor do Frete (DAI_VALFRE)*
								//   [15] Frete Autonomo (DAI_FREAUT)*
								AAdd( aRotas ,aCols[nElem,nPosRota ] )
								AAdd( aRotas ,aCols[nElem,nPosZona ] )
								AAdd( aRotas ,aCols[nElem,nPosSetor] )
								AAdd( aRotas ,"" )
								AAdd( aRotas ,"" )
								AAdd( aRotas ,"" )
								AAdd( aRotas ,"" )
								AAdd( aRotas ,"" )
								AAdd( aRotas ,aCols[nElem][nPosTime] )
								AAdd( aRotas ,aCols[nElem][nPosSrv ] )
								AAdd( aRotas ,aCols[nElem][nPosDtC ] )
								AAdd( aRotas ,aCols[nElem][nPosDtS ] )
								AAdd( aRotas ,"" )
								//-- Inclui o item do SC9 na nova carga
								MaAvalSC9("SC9",7,,,,,,aRotas)
							EndIf
							SC9->(DbSkip())
						EndDo
					EndIf
				//-- Verifica se o pedido corrente foi deletado da carga
				Case aCols[nElem][nUsado]
					SC5->(DbSetOrder(1))
					DbSelectArea("SC9")
					SC9->(DbSetOrder(1))
					If MsSeek(OsFilial("SC9",cFilPv)+aCols[nElem][nPosPed])
						While SC9->(!Eof()) .And. SC9->C9_FILIAL == OsFilial("SC9",cFilPv) .And.;
											SC9->C9_PEDIDO == aCols[nElem][nPosPed]
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se o item do SC9 pertence a carga selecionada³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If SC9->C9_CARGA == cCarOri .And. SC9->C9_SEQCAR == cSeqOri
								//-- Estornando a ordem de serviço do WMS
								If IntWms(SC9->C9_PRODUTO) .And. !Empty(SC9->C9_SERVIC) .And. ;
									SC5->(MsSeek(OsFilial("SC5",cFilPv)+SC9->C9_PEDIDO)) .And. SC5->C5_GERAWMS <> "1"
									WmsUndoPed(SC9->(Recno()))
								EndIf
								//-- 8.Estorno Mont.Carga
								MaAvalSC9("SC9",8)
							EndIf
							SC9->(DbSkip())
						EndDo
					EndIf
				OtherWise
					Reclock("DAI")
					DAI->DAI_SEQUEN := aCols[nElem,nPosSeq]
					If !Empty( nPosSrv )
						DAI->DAI_TMSERV := aCols[nElem,nPosSrv ]
					EndIf
					If !Empty( nPosTime )
						DAI->DAI_CHEGAD := aCols[nElem,nPosTime]
					EndIf
					If !Empty( nPosDtC )
						DAI->DAI_DTCHEG := aCols[nElem,nPosDtC ]
					EndIf
					If !Empty( nPosDtS )
						DAI->DAI_DTSAID := aCols[nElem,nPosDtS ]
					EndIf
					DAI->(MsUnlock())
			EndCase
		EndIf
	Next nElem
	//-- Ponto de entrada apos gravacao da manutencao da carga.
	If ExistBlock("OS200PM")
		ExecBlock("OS200PM",.F.,.F.)
	EndIf
	lGravou := .T.
Return( lGravou )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Oms200ARotaºAutor  ³Daniel P            º Data ³ 01/02/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe mais de uma rota  no range de pedidos   º±±
±±º          ³ e obriga o usuario a escolher apenas uma                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms200ARota(aArrayMan)
Local aArrayRt   := {}
Local oDlgRot
Local cDescRota  := ""
Local cAliasDA8  := Nil
Local nOpca      := 0
Local nC         := 0
	For nC := 1 to Len(aArrayMan)
		If (Ascan(aArrayRt,{|x| x[1] == aArrayMan[nC,3]}) == 0)
			cAliasDA8 := GetNextAlias()
			BeginSql Alias cAliasDA8
				SELECT DA8.DA8_DESC
				FROM %Table:DA8% DA8
				WHERE DA8.DA8_FILIAL = %xFilial:DA8%
				AND DA8.DA8_COD = %Exp:aArrayMan[nC,2]%
				AND DA8.%NotDel%
			EndSql
			If (cAliasDA8)->(!Eof())
				cDescRota:= (cAliasDA8)->DA8_DESC
			EndIf
			AAdd(aArrayRt, {aArrayMan[nC,3],cDescRota})
			(cAliasDA8)->(dbCloseArea())
		EndIf
	Next nC

	aArrayRt := aSort(aArrayRt,,,{|x,y| x[1] < y[1]})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se existir mais de uma rota monto checkbox para o usuario³
	//³escolher apenas uma par associar                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aArrayRt) > 1
		DEFINE MSDIALOG oDlgRot FROM 000, 000 TO 300,430 TITLE OemtoAnsi(STR0061) OF oMainWnd PIXEL//"Composicao de Rotas na Carga"
		@ 030,005 LISTBOX oRt VAR cVar Fields HEADER OemtoAnsi(STR0022), ;
			OemtoAnsi(STR0020) SIZE 210,100 OF oDlgRot PIXEL //"Rota" ### "Descricao"
		oRt:SetArray(aArrayRt)
		oRt:bLine:={||{ aArrayRt[oRt:nAT,1], aArrayRt[oRt:nAT,2] }}
		oRt:Refresh()
		ACTIVATE MSDIALOG oDlgRot ON INIT EnchoiceBar(oDlgRot, {|| nOpca := 1,oDlgRot:End()}, {||oDlgRot:End()}) CENTERED
	Else
		nOpca := 1
	EndIf
Return( nOpca == 1 )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Os200CriaTrbºAutor  ³Daniel P            º Data ³ 02/02/2021º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria arquivo temporarios para MsSelect da tela de montagem º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5dl                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Os200CriaTrb(aCampos)
Local aRetPE    := {}
Local cAlocPer  := SuperGetMv("MV_ALOCPER",.F.,"N")
Local aTamSX3   := {}
Local lDaiRedesp  := DAI->( ColumnPos( "DAI_REDESP" ) ) > 0

	nIndice := 8 // variável considerada dentro do PE DL200TR2
	aCampos := {}
									 AAdd(aCampos,{"PED_MARCA" ,"C",2             ,0         })
									 AAdd(aCampos,{"PED_GERA"  ,"C",1             ,0         })
	aTamSX3 := TamSx3("DA8_COD")   ; AAdd(aCampos,{"PED_ROTA"  ,"C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("DA7_PERCUR"); AAdd(aCampos,{"PED_ZONA"  ,"C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("DA7_ROTA")  ; AAdd(aCampos,{"PED_SETOR" ,"C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("DA9_SEQUEN"); AAdd(aCampos,{"PED_SEQROT","C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("C9_PEDIDO") ; AAdd(aCampos,{"PED_PEDIDO","C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("C9_ITEM")   ; AAdd(aCampos,{"PED_ITEM"  ,"C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("C9_SEQUEN") ; AAdd(aCampos,{"PED_SEQLIB","C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("B1_COD" )   ; AAdd(aCampos,{"PED_CODPRO","C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("B1_DESC")   ; AAdd(aCampos,{"PED_DESPRO","C",aTamSX3[1]    ,aTamSX3[2]})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria o campo de filial de origem caso o tipo de operacao trabalhe com todas as filiais³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									 AAdd(aCampos,{"PED_FILORI","C",FWSizeFilial(),0         })
									 AAdd(aCampos,{"PED_FILCLI","C",FWSizeFilial(),0         })
	aTamSX3 := TamSx3("A1_COD")    ; AAdd(aCampos,{"PED_CODCLI","C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("A1_LOJA")   ; AAdd(aCampos,{"PED_LOJA"  ,"C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("A1_NOME")   ; AAdd(aCampos,{"PED_NOME"  ,"C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("DAK_PESO")  ; AAdd(aCampos,{"PED_PESO"  ,"N",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("DAK_COD")   ; AAdd(aCampos,{"PED_CARGA" ,"C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("DA7_SEQUEN"); AAdd(aCampos,{"PED_SEQSET","C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("DA9_SEQUEN"); AAdd(aCampos,{"PED_SEQORI","C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("DAK_VALOR") ; AAdd(aCampos,{"PED_VALOR" ,"N",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("DAK_CAPVOL"); AAdd(aCampos,{"PED_VOLUM" ,"N",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("C9_ENDPAD") ; AAdd(aCampos,{"PED_ENDPAD","C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("A1_END")    ; AAdd(aCampos,{"PED_ENDCLI","C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("A1_BAIRRO") ; AAdd(aCampos,{"PED_BAIRRO","C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("A1_MUN")    ; AAdd(aCampos,{"PED_MUN"   ,"C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("A1_EST")    ; AAdd(aCampos,{"PED_EST"   ,"C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("A1_CEP" )   ; AAdd(aCampos,{"PED_CEP"   ,"C",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("DAK_VALOR") ; AAdd(aCampos,{"PED_QTDLIB","N",aTamSX3[1]    ,aTamSX3[2]})
	aTamSX3 := TamSx3("C5_TRANSP") ; AAdd(aCampos,{"TRANSP"    ,"C",aTamSX3[1]    ,aTamSX3[2]})

	If lDaiRedesp
		aTamSX3 := TamSx3("A4_COD")    ; AAdd(aCampos,{"PED_REDESP","C",aTamSX3[1]    ,aTamSX3[2]})
		aTamSX3 := TamSx3("A4_NOME")   ; AAdd(aCampos,{"PED_REDNOM","C",aTamSX3[1]    ,aTamSX3[2]})
	EndIf

	If ExistBlock("DL200TRB")
		aRetPE := ExecBlock("DL200TRB",.F.,.F.,aCampos)
		If ValType(aRetPE)=="A"
			aCampos := aRetPE
		EndIf
	EndIf

	__oTmpTab := FWTemporaryTable():New( "TRBPED" )
	__oTmpTab:SetFields( aCampos )
	If MV_PAR06 == 2 .or. MV_PAR06 == 3
		__oTmpTab:AddIndex("01", {"PED_FILORI","PED_PEDIDO","PED_ITEM","PED_SEQLIB"} )
	Else
		__oTmpTab:AddIndex("01", {"PED_FILORI","PED_PEDIDO"} )
	EndIf
	__oTmpTab:AddIndex("02", {"PED_ROTA","PED_SEQORI","PED_SEQSET","PED_ZONA","PED_SETOR","PED_CEP","PED_FILORI","PED_PEDIDO","PED_ITEM"} )
	__oTmpTab:AddIndex("03", {"PED_ROTA","PED_SEQROT","PED_FILORI","PED_PEDIDO"} )
	__oTmpTab:AddIndex("04", {"PED_ROTA","PED_ZONA","PED_SETOR","PED_FILORI","PED_PEDIDO"} )

	If cAlocPer == "S" .And. MV_PAR06 == 1
		__oTmpTab:AddIndex("05", {"PED_ZONA","PED_SETOR","PED_FILORI","PED_PEDIDO"} )
	ElseIf MV_PAR06 == 2 .or. MV_PAR06 == 3
		__oTmpTab:AddIndex("05", {"PED_ZONA","PED_SETOR","PED_FILORI","PED_CODPRO","PED_PEDIDO","PED_ITEM","PED_SEQLIB","PED_CODCLI","PED_LOJA"} )
	Else
		__oTmpTab:AddIndex("05", {"PED_ZONA","PED_SETOR","PED_FILORI","PED_PEDIDO","PED_ITEM","PED_SEQLIB","PED_CODCLI","PED_LOJA"} )
	EndIf

	If MV_PAR06 == 2 .or. MV_PAR06 == 3
		__oTmpTab:AddIndex("06", {"PED_FILORI","PED_CODPRO","PED_PEDIDO","PED_ITEM","PED_SEQLIB","PED_CODCLI","PED_LOJA"} )
	Else
		__oTmpTab:AddIndex("06", {"PED_FILORI","PED_PEDIDO","PED_ITEM","PED_SEQLIB","PED_CODCLI","PED_LOJA","PED_MARCA"} )
	EndIf

	__oTmpTab:AddIndex("07", {"PED_CODCLI","PED_LOJA"} )
	__oTmpTab:AddIndex("08", {"PED_EST","PED_MUN","PED_CODCLI","PED_LOJA","PED_PEDIDO"} )

	If ExistBlock("DL200TR2")
		SA1->(ExecBlock("DL200TR2",.F.,.F.,{__oTmpTab }))
	EndIf

	__oTmpTab:Create()
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Os200Junta³ Autor ³ Daniel Pereira        ³ Data ³29.01.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de agrupamento de cargas                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Esta rotina tem como objetivo controlar a interface com o    ³±±
±±³          ³usuario.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Distribuicao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Os200Junta()
Local lJunta     := .T.
Local oDlg
Local cBitmap    := "PROJETOAP"
Local cCodCarOri := DAK->DAK_COD
Local cRoteirOri := DAK->DAK_ROTEIR
Local cCaminhOri := DAK->DAK_CAMINH
Local cMotoriOri := DAK->DAK_MOTORI
Local cSeqCarOri := DAK->DAK_SEQCAR
Local cCodCarDes := CriaVar( "DAK_COD"    ,.F. )
Local cRoteirDes := CriaVar( "DAK_ROTEIR" ,.F. )
Local cCaminhDes := CriaVar( "DAK_CAMINH" ,.F. )
Local cMotoriDes := CriaVar( "DAK_MOTORI" ,.F. )
Local cSeqCarDes := CriaVar( "DAK_SEQCAR" ,.F. )
Local cCplInt    := SuperGetMv("MV_CPLINT",.F.,"2")
Local cAliasSC9  := Nil

Local dDatCarOri := DAK->DAK_DATA
Local dDatCarDes := CriaVar("DAK_DATA",.F.)
	//Integração OMSxCPL
	If DAK->(ColumnPos("DAK_VIAROT")) > 0
		If !Empty(DAK->DAK_VIAROT) .And. cCplInt == '1'
			Help(" ",1,"OMS200AGRPCPL")//Carga gerada pela integração com o Cockpit Logístico, agrupamento não permitido.
			Return(.F.)
		EndIf
	EndIf
	//-- Carga bloqueada ou com servico em execucao
	If  DAK->DAK_ACECAR == '1' .Or. OsBlqExec(DAK->DAK_COD,DAK->DAK_SEQCAR) .Or. DAK->DAK_BLQCAR == '1'
		Help(" ",1,"OMS200CGBL") //Carga bloqueada ou com serviço em execução.
		Return( .F. )
	EndIf
	cAliasSC9 := GetNextAlias()
	BeginSql Alias cAliasSC9
		SELECT SC9.C9_PRODUTO,
				SC9.C9_SERVIC,
				SC9.C9_STSERV
		FROM %Table:SC9% SC9
		WHERE SC9.C9_FILIAL = %xFilial:SC9%
		AND SC9.C9_CARGA = %Exp:DAK->DAK_COD%
		AND SC9.C9_SEQCAR = %Exp:DAK->DAK_SEQCAR%
		AND SC9.%NotDel%
	EndSql
	// Nao permite agutinar Cargas quando TOP, parametro MV_DEL_PVL igual a 1 e ja faturado
	If  SuperGetMV("MV_DEL_PVL")==1
		If (cAliasSC9)->(Eof())
			Aviso('SIGAOMS',STR0212, {'Ok'}) //"Não localizada a liberação do pedido de venda. A carga está faturada e a liberação excluída. A aglutinação não será permitida."###", {'Ok'})
			lJunta := .F.
		EndIf
	EndIf
	If ! lJunta
		Return( .F. )
	EndIf
	If  IntWms()
		// Nao permite agutinar Cargas Unitizadas quando utilizar WMS
		If DAK->DAK_FLGUNI == '1'
			Aviso('OMSA20002', STR0204, {'Ok'})//"Esta Carga ja foi Unitizada. A aglutinacao so sera permitida apos o estorno desta Unitizacao."###", {'Ok'})
			Return( .F. )
		EndIf
		// Nao permite agutinar Cargas quando utilizar WMS e o Servico jah tiver sido executado
		(cAliasSC9)->(dbGoTop())
		Do While (cAliasSC9)->(!Eof())
			If IntWms((cAliasSC9)->C9_PRODUTO) .And. !Empty((cAliasSC9)->C9_SERVIC) .And. ((cAliasSC9)->C9_STSERV $'23')
				Aviso('OMSA20003', STR0205, {'Ok'}) //"Esta Carga possui um servico de WMS executado. A aglutinacao so sera permitida apos o estorno deste Servico."
				lJunta := .F.
				Exit
			EndIf
			(cAliasSC9)->(DbSkip())
		EndDo
		If ! lJunta
			Return( .F. )
		EndIf
	EndIf
	(cAliasSC9)->(dbCloseArea())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dialog Principal.                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0064) FROM 000,000 TO 278,480 OF oMainWnd PIXEL //"Agrupa Cargas"

	@ 0 , 0 BITMAP oBmp RESNAME cBitMap OF oDlg SIZE 48,488 NOBORDER WHEN .F. PIXEL

	@ 004,054 TO 102,140 OF oDlg PIXEL LABEL OemToAnsi(STR0065)
	@ 016,058 SAY OemToAnsi(STR0014) OF oDlg PIXEL //"CARGA"
	@ 016,088 MSGET cCodCarOri WHEN .F. OF oDlg PIXEL
	@ 030,058 SAY RetTitle("DAK_SEQCAR") OF oDlg PIXEL
	@ 030,088 MSGET cSeqCarOri WHEN  .F. OF oDlg PIXEL
	@ 044,058 SAY OemToAnsi(STR0067) OF oDlg PIXEL //"ROTA"
	@ 044,088 MSGET cRoteirOri WHEN .F.OF oDlg PIXEL
	@ 058,058 SAY OemToAnsi(STR0068) OF oDlg PIXEL //"VEICULO"
	@ 058,088 MSGET cCaminhOri WHEN .F. OF oDlg PIXEL
	@ 072,058 SAY OemToAnsi(STR0069) OF oDlg PIXEL //"MOTORISTA"
	@ 072,088 MSGET cMotoriOri WHEN .F. OF oDlg PIXEL
	@ 086,058 SAY OemToAnsi(STR0070) OF oDlg PIXEL //"DATA"
	@ 086,088 MSGET dDatcarOri WHEN .F. OF oDlg PIXEL

	@ 004,144 TO 102,230 OF oDlg PIXEL LABEL OemToAnsi(STR0071)
	@ 016,148 SAY OemToAnsi(STR0066) OF oDlg PIXEL //"CARGA"
	@ 016,178 MSGET cCodCarDes VALID Os200VldCg(cCodCarDes,@cSeqCarDes,cCodCarOri,cSeqCarOri,dDatCarOri,@cRoteirDes,@cCaminhDes,@cMotOriDes,@dDatCarDes) F3 "DAK" OF oDlg PIXEL
	@ 030,148 SAY RetTitle("DAK_SEQCAR") OF oDlg PIXEL
	@ 030,178 MSGET cSeqCarDes VALID Os200VldCg(cCodCarDes,cSeqCarDes,cCodCarOri,cSeqCarOri,dDatCarOri,@cRoteirDes,@cCaminhDes,@cMotOriDes,@dDatCarDes) OF oDlg PIXEL
	@ 044,148 SAY OemToAnsi(STR0067) OF oDlg PIXEL //"ROTA"
	@ 044,178 MSGET cRoteirDes WHEN .F.OF oDlg PIXEL
	@ 058,148 SAY OemToAnsi(STR0068) OF oDlg PIXEL //"CAMINHAO"
	@ 058,178 MSGET cCaminhDes WHEN  .F. OF oDlg PIXEL
	@ 072,148 SAY OemToAnsi(STR0069) OF oDlg PIXEL //"MOTORISTA"
	@ 072,178 MSGET cMotoriDes WHEN .F. OF oDlg PIXEL
	@ 086,148 SAY OemToAnsi(STR0070) OF oDlg PIXEL //"DATA"
	@ 086,178 MSGET dDatCarDes WHEN .F. OF oDlg PIXEL

	DEFINE SBUTTON FROM 122,145 TYPE 5 ENABLE OF oDlg PIXEL ACTION Pergunte("OMS200A",.T.)
	DEFINE SBUTTON FROM 122,175 TYPE 1 ENABLE OF oDlg ACTION( OSAgrCarga(cCodCarOri,cSeqCarOri,cCodCarDes,cSeqCarDes, cCaminhDes),oDlg:End() )
	DEFINE SBUTTON FROM 122,205 TYPE 2 ENABLE OF oDlg ACTION( oDlg:End() )

	ACTIVATE MSDIALOG oDlg CENTERED
Return .T.
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OSAgrCarga³ Autor ³ Daniel Pereira        ³ Data ³30.01.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de atualizacao do processo de agrupamento de cargas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array com as cargas de origem                         ³±±
±±³          ³       [1] Codigo da Carga                                   ³±±
±±³          ³       [2] Sequencia da Carga                                ³±±
±±³          ³ExpC2: Carga de Destino                                      ³±±
±±³          ³ExpC3: Sequencia da carga de Destino                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Esta rotina tem como objetivo atualizar os dados necessarios ³±±
±±³          ³para agrupar as cargas                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Distribuicao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OSAgrCarga(cCodCarOri,cSeqCarOri,cCodCarDes,cSeqCarDes,cCaminhDes)
Local lRet       := .T.
Local lFezNF     := .F.
Local lAlocVei   := SuperGetMv("MV_ALOCVEI",.F.,.T.)
Local lDakTransp := DAK->( ColumnPos( "DAK_TRANSP" ) ) > 0
Local lDakVeic2  := DAK->( ColumnPos("DAK_VEIC2" ) ) > 0
Local lIntWMS    := .F.
Local lIntGFE    := SuperGetMv("MV_INTGFE",.F.,.F.)
Local lDAIFilPV  := DAI->(ColumnPos("DAI_FILPV")) > 0
Local aArea      := GetArea()
Local aCarga     := {}
Local aItens     := {}
Local aCliente   := {}
Local aTamSX3    := {}
Local oMdl       := ""
Local cAliasDAI  := "DAI"
Local cAliasDAK  := Nil
Local cAliasQry  := Nil
Local cAliasDA3  := Nil
Local cSeqAnt    := ""
Local cFilPed    := ""
Local cPedido    := ""
Local cNFiscal   := ""
Local cEndereco  := ""
Local cCampos    := ""
Local cIntGFE2   := SuperGetMv("MV_INTGFE2",.F.,"2")
Local cIntCarga  := SuperGetMv("MV_GFEI12",.F.,"2")
Local cDakTransp := Criavar("A4_COD",.F.)
Local cFilSC9    := xFilial("SC9")
Local nX         := 0
Local nY         := 0
Local nPeso      := 0
Local nPesoProd  := 0
Local nPesoDAK   := 0
Local nCapVol    := 0
Local nCapVDAK   := 0
Local nVlCarga   := 0
Local nSeqTemp   := 0
Local nSequencia := 0
Local nSeqInc    := SuperGetMV("MV_OMSENTR",.F.,5)
Local nVldRestr  := 0


Default cCaminhDes := ""
	Pergunte("OMS200A",.F.)
	Begin Transaction
		nVldRestr := MV_PAR01
		// Validação Restrição de Veiculos
		If nVldRestr == 1 .And. !Empty(cCaminhDes)
			cAliasDAK := GetNextAlias()
			BeginSql Alias cAliasDAK
				SELECT SUM(DAK.DAK_PESO)   DAK_PESO,
						SUM(DAK.DAK_PTOENT) DAK_PTOENT,
						SUM(DAK.DAK_CAPVOL) DAK_CAPVOL
				FROM %Table:DAK% DAK
				WHERE DAK.DAK_FILIAL = %xFilial:DAK%
				AND (DAK.DAK_COD   = %Exp:cCodCarDes%
					AND DAK.DAK_SEQCAR = %Exp:cSeqCarDes% )
				OR (DAK.DAK_COD   =  %Exp:cCodCarOri%
					AND DAK.DAK_SEQCAR = %Exp:cSeqCarOri% )
				AND DAK.%NotDel%
			EndSql
			aTamSX3 := TamSX3("DAK_PESO"  ); TcSetField(cAliasDAK,"DAK_PESO"  ,"N",aTamSX3[1],aTamSX3[2])
			aTamSX3 := TamSX3("DAK_PTOENT"); TcSetField(cAliasDAK,"DAK_PTOENT","N",aTamSX3[1],aTamSX3[2])
			aTamSX3 := TamSX3("DAK_CAPVOL"); TcSetField(cAliasDAK,"DAK_CAPVOL","N",aTamSX3[1],aTamSX3[2])
			//
			cAliasDA3 := GetNextAlias()
			BeginSql Alias cAliasDA3
				SELECT DA3.DA3_CAPACN,
						DA3.DA3_VOLMAX,
						DA3.DA3_LIMMAX
				FROM %Table:DA3% DA3
				WHERE DA3.DA3_FILIAL = %xFilial:DA3%
				AND DA3.DA3_COD = %Exp:cCaminhDes%
				AND DA3.%NotDel%
			EndSql
			If (cAliasDA3)->(!Eof())
				If (cAliasDAK)->DAK_PESO   > (cAliasDA3)->DA3_CAPACN .Or. ;
					(cAliasDAK)->DAK_CAPVOL > (cAliasDA3)->DA3_VOLMAX .Or. ;
					(cAliasDAK)->DAK_PTOENT > (cAliasDA3)->DA3_LIMMAX
					Help(" ",1,"OMSULTCARG") //Caminhao nao suporta carga montada
					lRet := .F.
				EndIf
			EndIf
			(cAliasDA3)->(dbCloseArea())
			(cAliasDAK)->(dbCloseArea())
		EndIf

		If lRet
			// Atualiza os dados da carga de destino
			cAliasDAK := GetNextAlias()
			BeginSql Alias cAliasDAK
				SELECT 1
				FROM %Table:DAK% DAK
				WHERE DAK.DAK_FILIAL = %xFilial:DAK%
				AND DAK.DAK_COD = %Exp:cCodCarOri%
				AND DAK.DAK_SEQCAR = %Exp:cSeqCarOri%
				AND DAK.DAK_FEZNF = '2'
				AND DAK.%NotDel%
			EndSql
			If (cAliasDAK)->(!Eof())
				lFezNF := .T.
			EndIf
			(cAliasDAK)->(dbCloseArea())
			// Atualiza os dados da carga de destino
			cAliasDAK := GetNextAlias()
			BeginSql Alias cAliasDAK
				SELECT DAK.R_E_C_N_O_ RECNODAK
				FROM %Table:DAK% DAK
				WHERE DAK.DAK_FILIAL = %xFilial:DAK%
				AND DAK.DAK_COD = %Exp:cCodCarDes%
				AND DAK.DAK_SEQCAR = %Exp:cSeqCarDes%
				AND DAK.%NotDel%
			EndSql
			If (cAliasDAK)->(!Eof())
				DAK->(dbGoTo((cAliasDAK)->RECNODAK))
				If lDakTransp
					cDakTransp := DAK->DAK_TRANSP
				EndIf
				// Busca o endereco padrao da carga
				cEndereco := Om200EndOri(cCodCarDes,cSeqCarDes)
				// Atualizo variaveis com os dados da carga origem
				RecLock("DAK",.F.)
				DAK->DAK_JUNTOU := "JUNTOU"
				DAK->DAK_PESO   := 0
				DAK->DAK_CAPVOL := 0
				DAK->DAK_VALOR  := 0
				DAK->DAK_PTOENT := 0
				If lFezNF
					DAK->DAK_FEZNF := '2'
				EndIf
				DAK->(MsUnlock())

				// Selecao dos itens das cargas para coloca-las em ordem
				AAdd(aCarga,{cCodCarDes,cSeqCarDes})
				AAdd(aCarga,{cCodCarOri,cSeqCarOri})
				// Parâmetro Campos
				cCampos := "%"
				If lDAIFilPV
					cCampos += " DAI.DAI_FILPV,"
				EndIf
				cCampos += "%"
				For nX := 1 To 2
					cAliasDAI := GetNextAlias()
					BeginSql Alias cAliasDAI
						SELECT DAI.DAI_COD,
								%Exp:cCampos%
								DAI.DAI_SEQCAR,
								DAI.DAI_CLIENT,
								DAI.DAI_LOJA,
								DAI.DAI_PEDIDO,
								DAI.DAI_ROTEIR,
								DAI.DAI_PERCUR,
								DAI.DAI_ROTA,
								DAI.DAI_PEDIDO,
								DAI.DAI_NFISCA,
								DAI.R_E_C_N_O_ DAIRECNO
						FROM %Table:DAI% DAI
						WHERE DAI.DAI_FILIAL = %xFilial:DAI%
						AND DAI.DAI_COD = %Exp:aCarga[nX,1]%
						AND DAI.DAI_SEQCAR = %Exp:aCarga[nX,2]%
						AND DAI.%NotDel%
						ORDER BY DAI.DAI_FILIAL,
									DAI.DAI_COD,
									DAI.DAI_SEQCAR,
									DAI.DAI_SEQUEN,
									DAI.DAI_PEDIDO

					EndSql
					Do While !(cAliasDAI)->(Eof())
						nSeqTemp++
						AAdd(aItens,{;
										(cAliasDAI)->DAI_COD,;
										(cAliasDAI)->DAI_SEQCAR,;
										StrZero(nSeqTemp,6),;
										(cAliasDAI)->DAI_CLIENT,;
										(cAliasDAI)->DAI_LOJA,;
										(cAliasDAI)->DAI_PEDIDO,;
										(cAliasDAI)->DAI_ROTEIR,;
										(cAliasDAI)->DAI_PERCUR,;
										(cAliasDAI)->DAI_ROTA,;
										(cAliasDAI)->DAIRECNO,;
										Iif(nX==1," ","z"),;
										Iif(lDAIFilPV,(cAliasDAI)->DAI_FILPV,xFilial("SC9")),;
										(cAliasDAI)->DAI_PEDIDO,;
										(cAliasDAI)->DAI_NFISCA,;
									})
						(cAliasDAI)->(dbSkip())
					EndDo
					(cAliasDAI)->(dbCloseArea())
				Next nX
				// Marca os pedidos repetidos para delecao
				For nX := 1 To Len(aItens)
					cPedido := aItens[nX][12]+aItens[nX][6]+aItens[nX][14]
					If aItens[nX][11] == " "
						If (nY := aScan(aItens,{|x| x[12]+x[6]+x[14] == cPedido .And. x[11] == "z"})) > 0
							aItens[nY][6] := ""
						EndIf
					Else
						Exit
					EndIf
				Next nX
				// Pedidos iguais devem permancer na mesma sequencia
				For nX := 1 To Len(aItens)
					cFilPed  := aItens[nX][12]
					cPedido  := aItens[nX][13]
					cNFiscal := aItens[nX][14]
					If aItens[nX][11] == "z"
						Exit
					EndIf
					If (nY := aScan(aItens,{|x| x[12]+x[13]+x[14] == cFilPed+cPedido+cNFiscal .And. x[11] == "z"})) > 0
						aItens[nY][3] := aItens[nX][3]
					EndIf
				Next nX
				// Clientes iguais deve permancer na mesma sequencia
				For nX := 1 To Len(aItens)
					For nY := nX+1 To Len(aItens)
						If aItens[nY,12]+aItens[nY,4]+aItens[nY,5]+aItens[nY,14] == aItens[nX,12]+aItens[nX,4]+aItens[nX,5]+aItens[nX,14]
							aItens[nY,3] := aItens[nX,3]
						EndIf
					Next nY
				Next nX
				// Ordena os itens da carga
				aItens := aSort(aItens,,,{|x,y| x[2]+x[3]+x[13]+x[11] < y[2]+y[3]+y[13]+y[11] })
				// Renumera a sequencia de entrega
				nSeqInc := IIF(nSeqInc > 0,nSeqInc,5)
				nSequencia += nSeqInc
				For nX := 1 To Len(aItens)
					cSeqAnt := aItens[nX][13]+aItens[nX][3]
					aItens[nX][3] := StrZero(nSequencia,6)
					If cSeqAnt <> aItens[Min(nX+1,Len(aItens))][13]+aItens[Min(nX+1,Len(aItens))][3]
						nSequencia += nSeqInc
					EndIf
				Next nX
				// Atualiza os dados da nova carga
				For nX := 1 To Len(aItens)
					nPeso    := 0
					nPesoDAK := 0
					nCapVol  := 0
					nVlCarga := 0
					nCapVDAK := 0
					// Posiciona registros
					DAI->(DbGoTo(aItens[nX][10]))
					If lDAIFilPV
						cFilSC9 := DAI->DAI_FILPV
					EndIf
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT SC9.R_E_C_N_O_ RECNOSC9,
								SC5.C5_GERAWMS,
								SC5.R_E_C_N_O_ RECNOSC5,
								SF4.F4_ESTOQUE
						FROM %Table:SC9% SC9
						INNER JOIN %Table:SC5% SC5
						ON SC5.C5_FILIAL = SC9.C9_FILIAL
						AND SC5.C5_NUM = SC9.C9_PEDIDO
						AND SC5.%NotDel%
						INNER JOIN %Table:SC6% SC6
						ON SC6.C6_FILIAL = SC9.C9_FILIAL
						AND SC6.C6_NUM = SC9.C9_PEDIDO
						AND SC6.C6_ITEM = SC9.C9_ITEM
						AND SC6.C6_PRODUTO = SC9.C9_PRODUTO
						AND SC6.%NotDel%
						INNER JOIN %Table:SF4% SF4
						ON SF4.F4_FILIAL = %Exp:OsFilial("SF4",cFilSC9)%
						AND SF4.F4_CODIGO = SC6.C6_TES
						AND SF4.%NotDel%
						WHERE SC9.C9_FILIAL  = %Exp:cFilSC9%
						AND SC9.C9_CARGA = %Exp:DAI->DAI_COD%
						AND SC9.C9_SEQCAR = %Exp:DAI->DAI_SEQCAR%
						AND SC9.C9_SEQENT = %Exp:DAI->DAI_SEQUEN%
						AND SC9.C9_PEDIDO = %Exp:DAI->DAI_PEDIDO%
						AND SC9.%NotDel%
					EndSql
					Do While !(cAliasQry)->(Eof())
						// Posiciona na SC9 correspondente
						SC9->(DbGoTo((cAliasQry)->RECNOSC9))
						// Cancela as ordens de serviço WMS a executar
						lIntWMS := IntWms(SC9->C9_PRODUTO) .And. !Empty(SC9->C9_SERVIC)
						If lIntWMS .And. (cAliasQry)->C5_GERAWMS == "2"
							WmsUndoPed(SC9->(Recno()))
						EndIf
						// Atualiza o registro com as informações da carga
						RecLock("SC9",.F.)
						SC9->C9_CARGA  := DAK->DAK_COD
						SC9->C9_SEQCAR := DAK->DAK_SEQCAR
						SC9->C9_SEQENT := aItens[nX][3]
						SC9->C9_ENDPAD := cEndereco
						SC9->(MsUnlock())
						// Atualiza a transportadora nos pedidos de venda
						If lDakTransp .And. !Empty(cDakTransp)
							SC5->(DbGoTo((cAliasQry)->RECNOSC5))
							RecLock('SC5',.F.)
							SC5->C5_TRANSP := cDakTransp
							SC5->(MsUnlock())
						 EndIf
						// Integra novamente o pedido com o WMS, com base na nova carga
						If lIntWMS .And. (cAliasQry)->C5_GERAWMS == "2" .And. (cAliasQry)->F4_ESTOQUE == "S"
							WmsIntPed(SC9->(Recno()))
						EndIf
						// Se o item já tiver sido faturado, atualiza a NF de saída
						If !Empty(SC9->C9_NFISCAL)
							SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
							If SF2->(DbSeek(OsFilial("SF2",SC9->C9_FILIAL)+SC9->C9_NFISCAL+SC9->C9_SERIENF+SC9->C9_CLIENTE+SC9->C9_LOJA))
								RecLock("SF2",.F.)
								SF2->F2_CARGA  := DAK->DAK_COD
								SF2->F2_SEQCAR := DAK->DAK_SEQCAR
								SF2->(MsUnlock())
								// Envia as informações para o EAI
								MaEnvEAI(,,4,"MATA461")
							EndIf
						EndIf
						// Calcula os dados acumulados do DAI/DAK
						nPesoProd := OsPesoProd(SC9->C9_PRODUTO,SC9->C9_FILIAL)
						nPeso    += (nPesoProd * SC9->C9_QTDLIB)
						nPesoDAK += (nPesoProd * SC9->C9_QTDLIB)
						nCapVol  += (OsPrCapArm(SC9->C9_PRODUTO,SC9->C9_FILIAL) * SC9->C9_QTDLIB)
						nCapVDAK += (OsPrCapArm(SC9->C9_PRODUTO,SC9->C9_FILIAL) * SC9->C9_QTDLIB)
						nVlCarga += A410Arred((SC9->C9_QTDLIB * SC9->C9_PRCVEN), "DAK_VALOR")
						(cAliasQry)->(DbSkip())
					EndDo
					(cAliasQry)->(DbCloseArea())
					// Verifica se o pedido de venda ja possui um item vinculado
					If Empty(aItens[nX][6])
						// Estorna o item duplicado do DAI e posiciona no item anterior
						Reclock("DAI",.F.)
						DAI->(dbDelete())
						DAI->(MsUnLock())
						// Atribui dimensionais
						cAliasDAI := GetNextAlias()
						BeginSql Alias cAliasDAI
							SELECT DAI.R_E_C_N_O_ RECNODAI,
									DAI.DAI_PESO,
									DAI.DAI_CAPVOL
							FROM %Table:DAI% DAI
							WHERE DAI.DAI_FILIAL = %xFilial:DAI%
							AND DAI.DAI_COD = %Exp:DAK->DAK_COD%
							AND DAI.DAI_SEQCAR = %Exp:DAK->DAK_SEQCAR%
							AND DAI.DAI_SEQUEN = %Exp:aItens[nX][3]%
							AND DAI.%NotDel%
						EndSql
						aTamSX3 := TamSX3("DAI_PESO"  ); TcSetField(cAliasDAK,"DAI_PESO"  ,"N",aTamSX3[1],aTamSX3[2])
						aTamSX3 := TamSX3("DAI_CAPVOL"); TcSetField(cAliasDAK,"DAI_CAPVOL","N",aTamSX3[1],aTamSX3[2])
						If (cAliasDAI)->(!Eof())
							DAI->(dbGoTo((cAliasDAI)->RECNODAI))
						 	nPeso    += (cAliasDAI)->DAI_PESO
							nCapVol  += (cAliasDAI)->DAI_CAPVOL
						EndIf
						(cAliasDAI)->(dbCloseArea())
					EndIf
					// Atualiza os dados do item da carga
					Reclock("DAI",.F.)
					DAI->DAI_COD    := DAK->DAK_COD
					DAI->DAI_SEQCAR := DAK->DAK_SEQCAR
					DAI->DAI_SEQUEN := aItens[nX][3]
					DAI->DAI_CARORI := aItens[nX][1]
					DAI->DAI_PESO   := nPeso
					DAI->DAI_CAPVOL := nCapVol
					DAI->(MsUnlock())
					// Atualiza os dados da carga
					nY := aScan(aCliente,DAI->DAI_CLIENT+DAI->DAI_LOJA)
					RecLock("DAK",.F.)
					DAK->DAK_PESO   += nPesoDAK
					DAK->DAK_CAPVOL += nCapVDAK
					DAK->DAK_VALOR  += nVlCarga
					DAK->DAK_PTOENT += If(nY>0,0,1)
					DAK->(MsUnlock())

					AAdd(aCliente,DAI->DAI_CLIENT+DAI->DAI_LOJA)
				Next nX
				cAliasDAI := GetNextAlias()
				BeginSql Alias cAliasDAI
					SELECT DAI.R_E_C_N_O_ RECNODAI,
							DAI.DAI_CAPVOL
					FROM %Table:DAI% DAI
					WHERE DAI.DAI_FILIAL = %xFilial:DAI%
					AND DAI.DAI_COD = %Exp:cCodCarOri%
					AND DAI.DAI_SEQCAR = %Exp:cSeqCarOri%
					AND DAI.%NotDel%
				EndSql
				Do While (cAliasDAI)->(!Eof())
					DAI->(dbGoTo((cAliasDAI)->RECNODAI))

					RecLock("DAI")
					DAI->(dbDelete())
					DAI->(MsUnlock())

					(cAliasDAI)->(dbSkip())
				EndDo
				(cAliasDAI)->(dbCloseArea())
				cAliasDAK := GetNextAlias()
				BeginSql Alias cAliasDAK
					SELECT DAK.R_E_C_N_O_ RECNODAK
					FROM %Table:DAK% DAK
					WHERE DAK.DAK_FILIAL = %xFilial:DAK%
					AND DAK.DAK_COD = %Exp:cCodCarOri%
					AND DAK.DAK_SEQCAR = %Exp:cSeqCarOri%
					AND DAK.%NotDel%
				EndSql
				If (cAliasDAK)->(!Eof())
					DAK->(dbGoTo((cAliasDAK)->RECNODAK))
					oMdl := MaEnvEAI(,,5,"OMSA200",,,.F.)
					RecLock("DAK",.F.)
					// Retira a reserva do veiculo
					If lAlocVei
						OsVAgenda(DAK->DAK_COD,DAK->DAK_SEQCAR,DAK->DAK_CAMINH,2)
						If lDakVeic2
							OsVAgenda(DAK->DAK_COD,DAK->DAK_SEQCAR,DAK->DAK_VEIC2,2)
							OsVAgenda(DAK->DAK_COD,DAK->DAK_SEQCAR,DAK->DAK_VEIC3,2)
						EndIf
					EndIf
					DAK->(dbDelete())
					DAK->(MsUnlock())
				EndIf
				// Exclusão da carga integrada ao GFE na integração Direta
				If lIntGFE .And. cIntGFE2 $ "1" .And. cIntCarga == "1"
					lRet := OMSA200IPG(5,,,.T.,cCodCarOri,cSeqCarOri,,cDakTransp)
					If lRet
						// Amarra o romaneio de carga liberado com o documento de carga agrupado
						lRet := xOMSA200IRM(cCodCarDes,cSeqCarDes)
					EndIf
				EndIf
			EndIf
			If lRet
				// PE executado apos a aglutinacao de cargas
				If ExistBlock("OSAGRCAR")
					ExecBlock("OSAGRCAR",.F.,.F.,{{{cCodCarOri,cSeqCarOri}},cCodCarDes,cSeqCarDes})
				EndIf
			EndIf
		EndIf
		If !lRet
			DisarmTransaction()
		EndIf
	End Transaction
	// Executando as ordens de serviços geradas no WMS
	If lRet .And. IntWms()
		WmsAvalExe()
	EndIf

	If lRet .And. !Empty(oMdl)
		MaEnvEAI(,,5,"OMSA200",,,,.F.,oMdl)
	EndIf
	RestArea(aArea)
Return .T.
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Oms200VlCg³ Autor ³ EDaniel Pereira      ³ Data ³ 29.01.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Validacao da rotina de agrupamento de cargas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Carga de Origem                                       ³±±
±±³          ³ExpC2: Sequencia de Origem                                   ³±±
±±³          ³ExpC3: Carga de destino                                      ³±±
±±³          ³ExpC4: Sequencia de destino                                  ³±±
±±³          ³ExpD5: Data de Origem                                        ³±±
±±³          ³ExpC6: Roteiro de Destino                                    ³±±
±±³          ³ExpC7: Caminhao de Destino                                   ³±±
±±³          ³ExpC8: Motorista de Destino                                  ³±±
±±³          ³ExpD9: Data de Destino                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Esta rotina tem como objetivo validar os dados informados na ³±±
±±³          ³interface                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Distribuicao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Os200VldCg(cCodCarDes,cSeqCarDes,cCodCarOri,cSeqCarOri,dDatCarOri,cRoteirDes,cCaminhDes,cMotoriDes,dDatCarDes)
Local lRet        := .T.
Local lDAK_VIAROT := DAK->(ColumnPos("DAK_VIAROT"))
Local aAreaDAK    := DAK->(GetArea())
Local cAliasSC9   := Nil
Local cAliasDAK   := Nil
Local cStatOri    := ""
Local cStatDes    := ""
Local cCplInt     := SuperGetMv("MV_CPLINT",.F.,"2")
	cSeqCarDes := If(Empty(cSeqCarDes),DAK->DAK_SEQCAR,cSeqCarDes)
	cAliasDAK := GetNextAlias()
	BeginSql Alias cAliasDAK
		SELECT DAK.DAK_VIAROT
		FROM %Table:DAK% DAK
		WHERE DAK.DAK_FILIAL = %xFilial:DAK%
		AND DAK.DAK_COD = %Exp:cCodCarOri%
		AND DAK.DAK_SEQCAR = %Exp:cSeqCarOri%
		AND DAK.%NotDel%
	EndSql
	If (cAliasDAK)->(!Eof())
		cStatOri := DAK->DAK_FEZNF
	EndIf
	// Valida no cadastro de cargas o codigo de carga informado
	cAliasDAK := GetNextAlias()
	BeginSql Alias cAliasDAK
		SELECT DAK.DAK_VIAROT,
				DAK.DAK_COD,
				DAK.DAK_SEQCAR,
				DAK.DAK_JUNTOU,
				DAK.DAK_ACECAR,
				DAK.DAK_BLQCAR,
				DAK.DAK_FEZNF,
				DAK.DAK_FLGUNI,
				DAK.DAK_ROTEIR,
				DAK.DAK_CAMINH,
				DAK.DAK_MOTORI,
				DAK.DAK_DATA
		FROM %Table:DAK% DAK
		WHERE DAK.DAK_FILIAL = %xFilial:DAK%
		AND DAK.DAK_COD = %Exp:cCodCarDes%
		AND DAK.DAK_SEQCAR = %Exp:cSeqCarDes%
		AND DAK.%NotDel%
	EndSql
	If (cAliasDAK)->(!Eof())
		//Integração OMSxCPL
		If lDAK_VIAROT .And. !Empty((cAliasDAK)->DAK_VIAROT) .And. cCplInt == '1'
			Help(" ",1,"OMS200AGRPCPL")//Carga gerada pela integração com o Cockpit Logístico, agrupamento não permitido.
			lRet := .F.
		EndIf
		// Verifica se existe o campo e se esta bloqueada
		If OsBlqExec((cAliasDAK)->DAK_COD,(cAliasDAK)->DAK_SEQCAR) .Or. (cAliasDAK)->DAK_BLQCAR == '1' //Bloqueada
			Help(" ",1,"OMS200CGBL") //Carga bloqueada ou com serviço em execução.
			lRet := .F.
		EndIf
		// Verifica se o Acerto de Cargas realizado ou ja iniciado
		If lRet
			If (cAliasDAK)->DAK_ACECAR == "1"
				Help(" ",1,"OMS320JAAC") //Carga já encerrada.
				lRet := .F.
			Else
				cStatDes := (cAliasDAK)->DAK_FEZNF
			EndIf
		EndIf
		If lRet
			Do Case
				Case (cAliasDAK)->DAK_COD == cCodCarOri .And. !Empty(cSeqCarOri) .And. (cAliasDAK)->DAK_SEQCAR == cSeqCarOri
					Help(" ",1,"DS2602134") //O código da carga selecionada é o mesmo da carga atual.
					lRet := .F.
				Case !Empty((cAliasDAK)->DAK_JUNTOU) .And. (cAliasDAK)->DAK_JUNTOU != "JUNTOU" .And. (cAliasDAK)->DAK_JUNTOU != "MANUAL" .And. (cAliasDAK)->DAK_JUNTOU != "ASSOCI"
					Help(" ",1,"DS2602135") //A carga informada já foi agregada a outra e encontra-se indisponível.
					lRet := .F.
				Case cStatOri != cStatDes .And. GetMV("MV_ASSCARG") == "N"
					Help(" ",1,"DS2602136") //???
					lRet := .F.
				Case IntWms()
					// Nao permite agutinar Cargas Unitizadas quando utilizar WMS
					If (cAliasDAK)->DAK_FLGUNI == '1'
						Aviso(OMSA20004, STR0206, {'Ok'}) // A Carga Destino ja foi Unitizada. A aglutinacao so sera permitida apos o estorno desta Unitizacao.
						lRet := .F.
					Else
						// Nao permite aglutinar Cargas quando utilizar WMS e o Servico jah tiver sido executado
						cAliasSC9 := GetNextAlias()
						BeginSql Alias cAliasSC9
							SELECT SC9.C9_PRODUTO,
									SC9.C9_SERVIC,
									SC9.C9_STSERV
							FROM %Table:SC9% SC9
							WHERE SC9.C9_FILIAL = %xFilial:SC9%
							AND SC9.C9_CARGA = %Exp:(cAliasDAK)->DAK_COD%
							AND SC9.C9_SEQCAR = %Exp:(cAliasDAK)->DAK_SEQCAR%
						EndSql
						Do While (cAliasSC9)->(!Eof())
							If IntWms((cAliasSC9)->C9_PRODUTO) .And. !Empty((cAliasSC9)->C9_SERVIC) .And. ((cAliasSC9)->C9_STSERV $'23')
								Aviso('OMSA20005', STR0207, {'Ok'}) //"A Carga Destino possui um servico de WMS executado. A aglutinacao so sera permitida apos o estorno deste Servico."
								lRet := .F.
								Exit
							EndIf
							(cAliasSC9)->(dbSkip())
						EndDo
						(cAliasSC9)->(dbCloseArea())
					EndIf
			EndCase
		EndIf
		If lRet .And. SuperGetMV("MV_DEL_PVL")==1
			// Nao permite agutinar Cargas quando TOP, parametro MV_DEL_PVL igual a 1 e ja faturado
			cAliasSC9 := GetNextAlias()
			BeginSql Alias cAliasSC9
				SELECT SC9.C9_PRODUTO,
						SC9.C9_SERVIC,
						SC9.C9_STSERV
				FROM %Table:SC9% SC9
				WHERE SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_CARGA = %Exp:(cAliasDAK)->DAK_COD%
				AND SC9.C9_SEQCAR = %Exp:(cAliasDAK)->DAK_SEQCAR%
			EndSql
			If (cAliasSC9)->(Eof())
				Aviso('SIGAOMS',STR0212, {'Ok'}) //"Não localizada a liberação do pedido de venda. A carga está faturada e a liberação excluída. A aglutinação não será permitida."###", {'Ok'})
				lRet := .F.
			EndIf
			(cAliasSC9)->(dbCloseArea())
		EndIf
		If lRet
			cRoteirDes := (cAliasDAK)->DAK_ROTEIR
			cCaminhDes := (cAliasDAK)->DAK_CAMINH
			cMotoriDes := (cAliasDAK)->DAK_MOTORI
			dDatCarDes := (cAliasDAK)->DAK_DATA
		EndIf
	Else
		Help(" ",1,"DS2602131") //A carga informada nÆo existe.
		lRet := .F.
	EndIf
	(cAliasDAK)->(dbCloseArea())
	// Executa ponto de entrada para validacao
	If lRet .And. ExistBlock("OM200VCG")
		lRet := ExecBlock("OM200VCG",.F.,.F.,{cCodCarDes,cSeqCarDes,cCodCarOri,cSeqCarOri})
	EndIf
	// Restaura a entrada da rotina
	RestArea(aAreaDAK)
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ Os200Leg ³ Autor ³ Daniel Pereira       ³ Data ³29/01/2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Exibe a legenda dos status da carga                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Os200Leg()
Local nI       := 0
Local aLegenPE := {}
Local aLegenda := { { "BR_VERDE",   OemToAnsi(STR0058) },; //"Totalmente em aberto"
					{ "BR_LARANJA", OemToAnsi(STR0059) },; //"Somente faturada e nao acertada"
					{ "BR_VERMELHO",OemToAnsi(STR0057) } } //"Faturada e acertos efetuados"

	AAdd(aLegenda,{"BR_PRETO", OemtoAnsi( STR0141 ) } ) //"Bloqueada"

	If ExistBlock('OM200LEG')
		If ValType( aLegenPE := ExecBlock("OM200LEG",.F.,.F.) ) == "A"
			For nI := 1 To Len(aLegenPE)
				AAdd(aLegenda,aLegenPE[nI])
			Next nI
		EndIf
	EndIf
	BrwLegenda( cCadastro, OemToAnsi( "Status" ), aLegenda  )
Return( Nil )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Oms200ePadºAutor  ³Daniel Pereira      º Data ³  26/01/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca enredeco padrao para os itens                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º20/02/2015³ Alterado propósito do parametro MV_WMSEOMS, agora quando   º±±
±±º          ³ "N" considera o endereço da SC9, mesmo que seja diferente  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms200ePad(aArrayMan,cEndereco,lEndeWMS)
Local lRet      := .T.
Local lProcessa := .T.
Local lPergWMS  := .T.
Local lGeraWMS  := .F.
Local lEndWms   := .F.
Local lWmsEOms  := SuperGetMV("MV_WMSEOMS", .F., "S") == "S"
Local lEndereco := .T.
Local lServico  := .F.
Local aRetPE    := {}
Local cMens1    := ""
Local cMens2    := ""
Local cMens3    := ""
Local cMens4    := ""
Local cMens5    := ""
Local cEstrut   := ""
Local cArmazem  := SC9->C9_LOCAL
Local cProduto  := SC9->C9_PRODUTO
Local cPedido   := SC9->C9_PEDIDO
Local cAliasSC9 := Nil
Local cAliasSC5 := Nil
Local nC        := 0
	If lProcessa
		If lWmsEOms
			// Pego o primeiro endereco de um determinado pedido da carga
			cAliasSC9 := GetNextAlias()
			BeginSql Alias cAliasSC9
				SELECT SC9.C9_LOCAL,
						SC9.C9_PRODUTO,
						SC9.C9_PEDIDO,
						SC9.C9_ENDPAD,
						SBE.BE_ESTFIS,
						SC9.C9_SERVIC
				FROM %Table:SC9% SC9
				LEFT JOIN %Table:SBE% SBE
				ON SBE.BE_FILIAL = %xFilial:SBE%
				AND SBE.BE_LOCAL = SC9.C9_LOCAL
				AND SBE.BE_LOCALIZ = SC9.C9_ENDPAD
				AND SBE.%NotDel%
				WHERE SC9.C9_FILIAL = %Exp:aArrayMan[1,12]%
				AND SC9.C9_PEDIDO =  %Exp:aArrayMan[1,5]%
				AND SC9.%NotDel%
			EndSql
			If (cAliasSC9)->(!Eof())
				cArmazem  := (cAliasSC9)->C9_LOCAL
				cProduto  := (cAliasSC9)->C9_PRODUTO
				cPedido   := (cAliasSC9)->C9_PEDIDO
				cEndereco := (cAliasSC9)->C9_ENDPAD
				cEstrut   := (cAliasSC9)->BE_ESTFIS
				lServico  := !Empty((cAliasSC9)->C9_SERVIC) .Or. lServico
			EndIf
			(cAliasSC9)->(dbCloseArea())
			// Se parametro MV_WMSEOMS igual a "N" SEMPRE pergunta endereco destino do WMS.
			// Como padrão (sem o parametro ou com MV_WMSEOMS = "S")
			// pergunta o endereco destino se nos pedidos houver enderecos diferentes definidos.
			For nC := 1 to Len(aArrayMan)
				cAliasSC9 := GetNextAlias()
				BeginSql Alias cAliasSC9
					SELECT	SC9.C9_ENDPAD,
							SC9.C9_SERVIC
					FROM %Table:SC9% SC9
					WHERE SC9.C9_FILIAL = %Exp:aArrayMan[nC,12]%
					AND SC9.C9_PEDIDO =  %Exp:aArrayMan[nC,5]%
					AND SC9.C9_ENDPAD <> %Exp:cEndereco%
					AND SC9.%NotDel%
				EndSql
				If (cAliasSC9)->(!Eof())
					// Verifico se existem mais de um endereco entre os itens
					// dos pedidos, se existirem, trago o endereco em branco
					// como sugestao, caso contrario, trago o proprio endereco
					lServico := !Empty((cAliasSC9)->C9_SERVIC) .Or. lServico
					lEndereco := .F.
				EndIf
				(cAliasSC9)->(dbCloseArea())
				If !lEndereco
					Exit
				EndIf
			Next nC
		EndIf
		// Se existirem enderecos diferentes trago o get em branco
		If !lEndereco
			cEndereco := Space(Len(SC9->C9_ENDPAD))
			cEstrut   := Space(Len(SBE->BE_ESTFIS))
			cMens1 := OemtoAnsi(STR0084)
			cMens2 := OemtoAnsi(STR0085)
			cMens3 := OemtoAnsi(STR0086)
			cMens4 := OemtoAnsi(STR0087)
		Else
			cMens1 := OemtoAnsi(STR0084) //"De acordo com a integracao com o modulo de WMS e necessario a escolha de um endereco  "
			cMens2 := OemtoAnsi(STR0088) //"de destino comum para os pedidos. Nesta montagem de carga foi constatado o que todos os "
			cMens3 := OemtoAnsi(STR0089) //"pedidos selecionados deverao seguir para o endereco abaixo mencionado. Caso necessite,"
			cMens4 := OemtoAnsi(STR0090) //"indique um novo endereco ou se permanecer em branco o mesmo sera novamente solicitado na"
			cMens5 := OemtoAnsi(STR0091) //"rotina de Mapa de Separacao."
		EndIf
		//-- Permite a informacao do Endereco e da Estrutura de Origem via Ponto de Entrada
		If ExistBlock('OMSA200E')
			//-- Retorno esperado do RDMAKE
			aRetPE := ExecBlock("OMSA200E", Nil, Nil, {cProduto, cPedido})
			If  ValType(aRetPE)=="A" .And. Len(aRetPE) >= 2
				lPergWMS   := .F.
				cEndereco  := aRetPE[1]
			EndIf
		EndIf
		If lServico .And. lPergWMS .And. (Type('l250Auto') == 'U' .Or. (Type('l250Auto') == 'L' .And. !l250Auto)) .And. Empty(cEndereco)
			For nC := 1 To Len(aArrayMan)
				cAliasSC5 := GetNextAlias()
				BeginSql Alias cAliasSC5
					SELECT SC5.C5_GERAWMS
					FROM %Table:SC5% SC5
					WHERE SC5.C5_FILIAL = %xFilial:SC5%
					AND SC5.C5_NUM = %Exp:aArrayMan[nC,5]%
					AND SC5.%NotDel%
				EndSql
				If (cAliasSC5)->(!Eof())
					//Verifica se gera OS WMS na montagem da carga
					lGeraWMS := (cAliasSC5)->C5_GERAWMS == '2'
				EndIf
				(cAliasSC5)->(dbCloseArea())
				If !lGeraWMS
					//Verifica se existe OS pendente de execução para o pedido
					lEndWms := WmsChkDCF('SC9',,,,"1,2",,aArrayMan[nC,5],,,,,,,,,,,'4')
				EndIf
				If lGeraWMS .Or. lEndWms
					Exit
				EndIf
			Next
			//Se gera serviço WMS na montagem da carga ou
			//existe OS pendente de execução (no caso de gerar serviço WMS no pedido)
			//deve perguntar endereço destino
			If lGeraWMS .Or. lEndWms
				//-- Pergunta destino Serviço WMS
				lEndeWMS := DLPergEnd(@cEndereco,,.F.,'2',cArmazem)
				//-- Verifica se exite alguma ordem de serviço executada
				If lEndeWMS
					For nC := 1 To Len(aArrayMan)
						If WmsChkDCF('SC9',,,,'3',,aArrayMan[nC,5],,,,,,,,,,,'4')
							Exit
						EndIf
					Next
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Os200LiberºAutor  ³Daniel Pereira      º Data ³  26/01/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Liberacao automatica de pedidos                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Os200Liber(cAlias,nReg,nOpc)
	Pergunte("MTA440",.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Transfere locais para a liberacao                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lTransf :=IIF(mv_par01==1,.T.,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Libera Parcial pedidos de vendas                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lLiber  :=IIF(mv_par02==1,.T.,.F.)
	A440Automa(cAlias,nReg,nOpc)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Os200MotorºAutor  ³Daniel Pereira      º Data ³  26/01/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica o motorista informado na associacao               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Os200Motor(cMotorista,cNomeMot,cCarga,cSeqCar)
Local lRet      := .T.
Local lRetPE    := .T.
Local aAreaAnt  := GetArea()
Local cAliasDAN := Nil
Local cAliasDA4 := Nil
Default cSeqCar := "01"
	// Busca nome do motorista padrao
	DA4->(DbSetOrder(1))
	If !Empty(cMotorista)
		cAliasDA4 := GetNextAlias()
		BeginSql Alias cAliasDA4
			SELECT DA4.DA4_NOME,
					DA4.DA4_BLQMOT
			FROM %Table:DA4% DA4
			WHERE DA4.DA4_FILIAL = %xFilial:DA4%
			AND DA4.DA4_COD = %Exp:cMotorista%
			AND DA4.%NotDel%
		EndSql
		If (cAliasDA4)->(!Eof())
			cNomeMot := (cAliasDA4)->DA4_NOME
			If !Empty(oNomeMot)
				oNomeMot:Refresh()
			EndIf
			// Verifica se o motorista funcionario nao esta demitido ou afastado.
			If (cAliasDA4)->DA4_BLQMOT = "1" // Sim
				Help(" ",1,"REGBLOQ")
				lRet := .F.
			EndIf
		Else
			Help(" ",1,"REGNOIS")
			lRet := .F.
		EndIf
		(cAliasDA4)->(dbCloseArea())
		Pergunte("OMS200",.F.) // Parametro da Montagem de Cargas
		If  lRet .And. mv_par05 == 1
			// Verifica se o motorista esta disponivel para carga
			cAliasDAN := GetNextAlias()
			BeginSql Alias cAliasDAN
				SELECT 1
				  FROM %Table:DAN% DAN
				 INNER JOIN %Table:DAK% DAK
				    ON DAK.DAK_FILIAL = %xFilial:DAK%
				   AND DAK.DAK_COD = DAN.DAN_CODCAR
				   AND DAK.DAK_MOTORI = %exp:cMotorista%
				   AND DAK.%notdel%
				 INNER JOIN %Table:DA3% DA3
				    ON DA3_FILIAL = %xFilial:DA3%
				   AND DA3.DA3_COD = DAK.DAK_CAMINH
				   AND DA3.DA3_STATUS = '3'
				   AND DA3.%notdel%
				 WHERE DAN.DAN_FILIAL = %xFilial:DAN%
				   AND (DAN.DAN_CODCAR <> %exp:cCarga% OR (DAN.DAN_CODCAR = %exp:cCarga% AND DAN.DAN_SEQCAR <> %exp:cSeqCar%))
				   AND DAN.%notdel%
			EndSql
			If (cAliasDAN)->(!Eof())
				Aviso('SIGAOMS',STR0249, {'Ok'}) // Motorista nao esta disponivel
				lRet := .F.
			EndIf
			(cAliasDAN)->(dbCloseArea())
		EndIf
		Pergunte("OMS20A",.F.) // Restaura Parametros da tela de Cargas
	Else
		cNomeMot := " "
	EndIf
	// PE na validação do motorista.
	If lRet
		If ExistBlock("OM200MOT")
			lRetPE := ExecBlock("OM200MOT",.F.,.F.)
			lRet   := If(ValType(lRetPE)=="L", lRetPE, lRet)
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Oms200Aju ºAutor  ³Daniel Pereira      º Data ³  27/01/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca ajudante e traz seu respectivo nome                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Oms200Aju(cAjuda,cDescAju,aAjuda,cCarga,cSeqCar)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasDAN := Nil
Local cAliasDAU := Nil
Default cSeqCar := "01"
Default aAjuda  := {}
	If !Empty(cAjuda)
		cAliasDAU := GetNextAlias()
		BeginSql Alias cAliasDAU
			SELECT DAU.DAU_NOME
			FROM %Table:DAU% DAU
			WHERE DAU.DAU_FILIAL = %xFilial:DAU%
			AND DAU.DAU_COD = %Exp:cAjuda%
			AND DAU.%NotDel%
		EndSql
		If (cAliasDAU)->(!Eof())
			cDescAju := (cAliasDAU)->DAU_NOME
		Else
			Help(" ",1,"REGNOIS")
			lRet := .F.
		EndIf
		(cAliasDAU)->(dbCloseArea())
		If lRet .And. !Empty(aAjuda)
			If  aScan(aAjuda,cAjuda)>0
				Aviso('SIGAOMS',STR0250, {'Ok'}) // Codigo ajudante ja informado
				lRet := .F.
			EndIf
		EndIf
		Pergunte("OMS200",.F.) //Parametro da Montagem de Cargas
		If  lRet .And. mv_par05 == 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o Ajudante esta disponivel para carga                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cAliasDAN := GetNextAlias()
			BeginSql Alias cAliasDAN
				SELECT 1
				  FROM %Table:DAN% DAN
				 INNER JOIN %Table:DAK% DAK
				    ON DAK.DAK_FILIAL = %xFilial:DAK%
				   AND DAK.DAK_COD = DAN.DAN_CODCAR
				   AND (DAK_AJUDA1 = %exp:cAjuda% OR DAK_AJUDA2 = %exp:cAjuda% OR DAK_AJUDA3 = %exp:cAjuda%)
				   AND DAK.%notdel%
				 INNER JOIN %Table:DA3% DA3
				    ON DA3_FILIAL = %xFilial:DA3%
				   AND DA3.DA3_COD = DAK.DAK_CAMINH
				   AND DA3.DA3_STATUS = '3'
				   AND DA3.%notdel%
				 WHERE DAN.DAN_FILIAL = %xFilial:DAN%
				   AND (DAN.DAN_CODCAR <> %exp:cCarga% OR (DAN.DAN_CODCAR = %exp:cCarga% AND DAN.DAN_SEQCAR <> %exp:cSeqCar%))
				   AND DAN.%notdel%
			EndSql
			If (cAliasDAN)->(!Eof())
				Aviso('SIGAOMS',STR0251,{'Ok'}) //"Ajudante nao esta disponivel"
				lRet := .F.
			EndIf
			(cAliasDAN)->(dbCloseArea())
		EndIf
		Pergunte("OMS20A",.F.) //Restaura Parametros da tela de Cargas
	Else
		cDescAju:=" "
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XOmsVisGraph ºAutor  ³Daniel Pereira    º Data ³  27/01/2021º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca endereco padrao e traz a descricao                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aExp1 : Array das cargas                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function XOmsVisGraph(aArrayCarga,cMarca)
Local aSize      := MsAdvSize( .F. )
Local aPosObj    := {}
Local aObjects   := {}
Local aColors    := {}
Local aSeries    := {}
Local aCbx       := {OemtoAnsi(STR0103),OemtoAnsi(STR0104),OemtoAnsi(STR0105),OemtoAnsi(STR0106),OemtoAnsi(STR0107)}
Local oGraph
Local oFontLbl
Local cVeiculo   := ""
Local cCbx       := ""
Local cAliasDA3  := Nil
Local nPosCarga  := Ascan(aArrayCarga,{|x| x[CARGA_ENABLE] == .T.})
Local nPerKg     := 0
Local nPerM3     := 0
Local nX         := 0
Local nValor     := 0
Local nColor     := 1
Local nPosSerie  := 0
Local nTrbRec    := TRBPED->(Recno())
Local nModelo    := 1

	AAdd( aColors ,CLR_HBLUE     )
	AAdd( aColors ,CLR_HGREEN    )
	AAdd( aColors ,CLR_HCYAN     )
	AAdd( aColors ,CLR_HRED      )
	AAdd( aColors ,CLR_HMAGENTA  )
	AAdd( aColors ,CLR_YELLOW    )
	AAdd( aColors ,CLR_WHITE     )
	AAdd( aColors ,CLR_BLACK     )
	AAdd( aColors ,CLR_BLUE      )
	AAdd( aColors ,CLR_GREEN     )
	AAdd( aColors ,CLR_CYAN      )
	AAdd( aColors ,CLR_RED       )
	AAdd( aColors ,CLR_MAGENTA   )
	AAdd( aColors ,CLR_BROWN     )
	AAdd( aColors ,CLR_HGRAY     )
	AAdd( aColors ,CLR_LIGHTGRAY )
	AAdd( aColors ,CLR_GRAY      )

	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0101)  FROM 09,0 TO 20,40 OF oMainWnd  //Dados do Grafico

	@ 000, 0 BITMAP oBmp RESNAME "PROJETOAP" OF oDlg SIZE 30, 1000 NOBORDER WHEN .F. PIXEL ADJUST
	@ 014, 35 MSCOMBOBOX oCbx VAR cCbx ITEMS aCbx SIZE 115, 65 OF oDlg PIXEL ON CHANGE nModelo := oCbx:nAt
	DEFINE SBUTTON oBut1 FROM 062, 120 TYPE 1 ACTION (nOpca := 1, oDlg:End())  ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	aSize := MsAdvSize()
	AAdd( aObjects ,{ 100 ,020 ,.T. ,.F. } )
	AAdd( aObjects ,{ 100 ,100 ,.T. ,.T., .T. } )
	AAdd( aObjects ,{ 100 ,15  ,.T. ,.F. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	DEFINE FONT oFontLbl SIZE 10,0 BOLD
	DEFINE MSDIALOG oDlg FROM aSize[7],00 TO aSize[6],aSize[5] TITLE OemtoAnsi(STR0102) OF oMainWnd PIXEL //Grafico de Disposicao da carga

	If nPosCarga > 0
		cVeiculo := aArrayCarga[nPosCarga,CARGA_VEIC]
	EndIf
	Do Case
		Case nModelo == 1
			@ 10,10 Say OemtoAnsi(STR0103) OF oDlg PIXEL FONT oFontLbl //"Disposicao em Peso na carga"
		Case nModelo == 2
			@ 10,10 Say OemtoAnsi(STR0104) OF oDlg PIXEL FONT oFontLbl  //"Disposicao em Volume na carga"
		Case nModelo == 3
			@ 10,10 Say OemtoAnsi(STR0105) OF oDlg PIXEL FONT oFontLbl  //"Disposicao em Valor  na carga"
		Case nModelo == 4
			@ 10,10 Say OemtoAnsi(STR0106) OF oDlg PIXEL FONT oFontLbl  //"Ocupacao do Veiculo em Peso"
		Case nModelo == 5
			@ 10,10 Say OemtoAnsi(STR0107) OF oDlg PIXEL FONT oFontLbl  //"Ocupacao do Veiculo em Volume"
	EndCase

	@ aPosObj[2,1], aPosObj[2,2] MSGRAPHIC oGraph SIZE aPosObj[2,3], aPosObj[2,4] OF oDlg
	oGraph:SetMargins( 5, 5, 5, 5 )
	oGraph:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	nSerie := oGraph:CreateSerie( 10 )

	If nModelo == 4 .Or. nModelo == 5
		If !Empty(cVeiculo)
			cAliasDA3 := GetNextAlias()
			BeginSql Alias cAliasDA3
				SELECT DA3.DA3_CAPACN,
						DA3.DA3_VOLMAX
				FROM %Table:DA3% DA3
				WHERE DA3.DA3_FILIAL = %xFilial:DA3%
				AND DA3.DA3_COD = %Exp:cVeiculo%
				AND DA3.%NotDel%
			EndSql
			If (cAliasDA3)->(!Eof())
				nPerM3 := aArrayCarga[nPosCarga,CARGA_VOLUM]
				nPerKg := aArrayCarga[nPosCarga,CARGA_PESO]
				oGraph:Add(nSerie,Iif(nModelo == 4,nPerKg,nPerM3) ,Iif(nModelo == 4,OemtoAnsi(STR0106),OemtoAnsi(STR0107)),aColors[ 1 ]) //"OCUPACAO EM KG"###"OCUPACAO EM VOLUME"
				oGraph:Add(nSerie,Iif(nModelo == 4,(cAliasDA3)->DA3_CAPACN-nPerKg ,(cAliasDA3)->DA3_VOLMAX-nPerM3) ,OemtoAnsi(STR0115),aColors[ 5 ]) //"LIVRE"      EndIf
			EndIf
			(cAliasDA3)->(dbCloseArea())
		EndIf
	Else
		// Crio o acumulado por produto para passar par as series
		DbSelectArea("TRBPED")
		DbGoTop()
		Do While !Eof()
			If TRBPED->PED_MARCA == cMarca
				nPosSerie := Ascan(aSeries,{ |x| x[1] == Iif(mv_par06 == 1,TRBPED->PED_PEDIDO, AllTrim(TRBPED->PED_CODPRO) + ' - '+ Alltrim(TRBPED->PED_DESPRO))})
				If  nPosSerie == 0
					AAdd(aSeries,{Iif(mv_par06 == 1,TRBPED->PED_PEDIDO,AllTrim(TRBPED->PED_CODPRO) + ' - '+ Alltrim(TRBPED->PED_DESPRO)),TRBPED->PED_PESO,TRBPED->PED_VOLUM,TRBPED->PED_VALOR})
				Else
					aSeries[nPosSerie][2] += TRBPED->PED_PESO
					aSeries[nPosSerie][3] += TRBPED->PED_VOLUM
					aSeries[nPosSerie][4] += TRBPED->PED_VALOR
				EndIf
			EndIf
			DbSkip()
		EndDo
		For nX := 1 to Len(aSeries)
			nValor := Iif(nModelo == 1,aSeries[nX][2],Iif(nModelo == 2,aSeries[nX][3],Iif(nModelo == 3,aSeries[nX][4],aSeries[nX][2])))
			If  nValor > 0
				oGraph:Add(nSerie,nValor,aSeries[nX][1],aColors[ nColor ])
				nColor++
				If  nColor >= 18
					nColor := 1
				EndIf
			EndIf
		Next nX
	EndIf

	oGraph:l3D := .T.

	DEFINE SBUTTON FROM aPosObj[3,1],(aSize[5]/2)-33 TYPE 1 ACTION oDlg:End() ENABLE

	ACTIVATE MSDIALOG oDlg
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Volta a posicionar no registro corrente do arquivo de trabalho³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TRBPED")
	DbGoTo(nTrbRec)
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Oms200VlEndºAutor ³Daniel Pereira      º Data ³  27/01/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca endereco padrao e traz a descricao                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Oms200VlEnd(cLocaliza,cDescEnd)
Local lRet := .T.
	cDescEnd := SBE->BE_DESCRIC
Return( lRet )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Oms200Rot ºAutor  ³Daniel Pereira      º Data ³  28/01/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz consistencia nas marcacoes na montagem da carga         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ExpA1 - Array das rotas                                     º±±
±±º          ³ExpA2 - Array das Zonas                                     º±±
±±º          ³ExpA3 - Array dos Setores                                   º±±
±±º          ³ExpC4 - Rota corrente                                       º±±
±±º          ³ExpC5 - Zona corrente                                       º±±
±±º          ³ExpC6 - Setor corrente                                      º±±
±±º          ³ExpC7 - Marca                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms200Rot(aArrayRota,aArrayZona,aArraySetor,cRotaPed,cZonaPed,cSetorPed,cMarca)
Local aAreaTRB  := TRBPED->(GetArea())
Local nX        := 0
Local lDesSetor := .T.
Local lDesZona  := .F.
Local lDesRota  := .F.
	DbSelectArea("TRBPED")
	TRBPED->(DbSetOrder(4)) //-- PED_ROTA+PED_ZONA+PED_SETOR+PED_FILORI+PED_PEDIDO
	If TRBPED->(MsSeek(cRotaPed+cZonaPed+cSetorPed))
		//-- Pesquisa se existem Pedidos marcados para a Rota / Zona / Setor
		Do While TRBPED->(!Eof() .And. PED_ROTA+TRBPED->PED_ZONA+TRBPED->PED_SETOR == cRotaPed+cZonaPed+cSetorPed)
			If TRBPED->PED_MARCA == cMarca
				lDesSetor := .F.
				Exit
			EndIf
			TRBPED->(DbSkip())
		EndDo
	EndIf
	//-- Nao encontrou Pedidos marcados para a Rota / Zona / Setor
	If lDesSetor
		If  (nX:=aScan(aArraySetor,{|x|x[3]+x[4]+x[5] == cRotaPed+cZonaPed+cSetorPed .And. x[1] .And. x[2]}))>0
			aArraySetor[nX,2] := .F.
			lDesZona := .T.
		EndIf
		//-- Procura e desmarca Zona --//
		If  lDesZona
			If (nX:=aScan(aArraySetor,{|x|x[3]+x[4] == cRotaPed+cZonaPed .And. x[1] .And. x[2]}))==0
				If (nX:=aScan(aArrayZona,{|x|x[3]+x[4] == cRotaPed+cZonaPed .And. x[1] .And. x[2]}))>0
					aArrayZona[nX,2] := .F.
					lDesRota := .T.
				EndIf
			EndIf
			//-- Procura e desmarca Rota --//
			If lDesRota
				If (nX:=aScan(aArrayZona,{|x|x[3] == cRotaPed .And. x[1] .And. x[2]}))==0
					If (nX:=aScan(aArrayRota,{|x|x[3] == cRotaPed .And. x[1] .And. x[2]}))>0
						aArrayRota[nX,2] := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea( aAreaTRB )
	If !l200Auto
		oCargas:Refresh()
		oRotas:Refresh()
		oZonas:Refresh()
		oSetores:Refresh()
		oMark:oBrowse:Refresh()
	Endif
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³D200VlCg2   ³Autor  ³ Daniel Pereira      ³ Data ³ 29/01/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nome Orig.³ DFATA215                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Valida a carga de destino selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DFATA214                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function D200VlCg2()
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasDAK := GetNextAlias()
	// Valida no cadastro de cargas o codigo de carga informado
	BeginSql Alias cAliasDAK
		SELECT DAK.DAK_DATA,
				DAK.DAK_JUNTOU,
				DAK.DAK_FEZNF,
				DAK.DAK_ACECAR
		FROM %Table:DAK% DAK
		WHERE DAK.DAK_FILIAL = %xFilial:DAK%
		AND DAK.DAK_COD = %Exp:M->DAI_COD%
		AND DAK.%NotDel%
	EndSql
	If (cAliasDAK)->(Eof())
		Help(" ",1,"DS2602131") //A carga informada nÆo existe.
		lRet := .F.
	ElseIf (cAliasDAK)->DAK_DATA <> M->DAK_DATA
		Help(" ",1,"DS2602132") //A data da carga informada difere da data da carga selecionada.
		lRet := .F.
	ElseIf !Empty((cAliasDAK)->DAK_JUNTOU) .And. (cAliasDAK)->DAK_JUNTOU != "JUNTOU" .And. (cAliasDAK)->DAK_JUNTOU != "MANUAL" .And. (cAliasDAK)->DAK_JUNTOU != "ASSOCI"
		Help(" ",1,"DS2602135") //A carga informada já foi agregada a outra e encontra-se indisponível.
		lRet := .F.
	ElseIf GetMV("MV_MANCARG") == "N" .And. (cAliasDAK)->DAK_FEZNF == "1"
		//-- MV_MANCARG = S -> Permitir a Manipulacao ou Associacao de Pedidos a Cargas com faturamento ja iniciado (Especifico Distribuidores).
		Help(" ",1,"OMS200CFAT") //Esta carga já se encontra faturada.
		lRet := .F.
	ElseIf (cAliasDAK)->DAK_ACECAR == "1"
		//-- Verifico se o Acerto de Cargas realizado ou j  iniciado (DAN)
		Help(" ",1,"DS2412133") //A carga selecionada nÆo pode sofrer alteraçÆo, pois já esta em fase de Acerto de Cargas.
		lRet := .F.
	EndIf
	(cAliasDAK)->(dbCloseArea())
	// Restaura area
	RestArea(aAreaAnt)
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Os200AssocºAutor  ³Daniel Pereira      º Data ³  29/01/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Associacao do motorista apos geracao de carga               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Os200Assoc()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis proprias da rotina                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lExistVei2  := DAK->(ColumnPos("DAK_VEIC2")) > 0
Local lProcessa   := .T.
Local lOs200Ass   := ExistBlock("OS200ASS")
Local lTrava     := .T.
Local lAGRUBS    := (SuperGetMV("MV_AGRUBS",.F.,.F.))
Local aCargas     := {}
Local aHoras      := {}
Local aButtons    := { { "CARGA" , { || cVeiDisp := OmsCVDisp(aHoras[1],aHoras[2],aHoras[3],aHoras[4],nPeso,nVolume),Iif(!Empty(cVeiDisp),cVeiculo:= cVeiDisp,cVeiculo := cVeiculo )}, OemtoAnsi(STR0164),OemtoAnsi(STR0176) }} //"Sequencia anterior"
Local aButtonUsr  := {}
Local oFolder
Local cCarga      := DAK->DAK_COD
Local cSeqCar     := DAK->DAK_SEQCAR
Local cMotorista  := DAK->DAK_MOTORI
Local cNomeMot    := ""
Local cVeiDisp    := ""
Local cVeiculo    := DAK->DAK_CAMINH
Local cVeicAtu     := ""
Local cNomeCam    := Criavar("DA3_DESC",.F.)
Local cPlaca      := Criavar("DA3_PLACA",.F.)
Local cVeiculo2   := IiF(lExistVei2,DAK->DAK_VEIC2,"")
Local cNomeVeic2  := Iif(lExistVei2,Criavar("DA3_DESC",.F.),"")
Local cPlaca2     := Iif(lExistVei2,Criavar("DA3_PLACA",.F.),"")
Local cVeicAnt2   := ""
Local cVeiculo3   := Iif(lExistVei2,DAK->DAK_VEIC3,"")
Local cNomeVeic3  := Iif(lExistVei2,Criavar("DA3_DESC",.F.),"")
Local cPlaca3     := Iif(lExistVei2,Criavar("DA3_PLACA",.F.),"")
Local cVeicAnt3   := ""
Local cAjuda1     := DAK->DAK_AJUDA1
Local cNomeAju1   := Criavar("DAU_NOME",.F.)
Local cAjuda2     := DAK->DAK_AJUDA2
Local cNomeAju2   := Criavar("DAU_NOME",.F.)
Local cAjuda3     := DAK->DAK_AJUDA3
Local cNomeAju3   := Criavar("DAU_NOME",.F.)
Local cBitmap     := "PROJETOAP"
Local cCodOper    := ""
Local cNoProc     := ""
Local cPedComOp   := ""
Local cAliasDA3   := Nil
Local cAliasDAU   := Nil
Local cAliasDA4   := Nil
Local cAliasSA4   := Nil
Local cDakTransp  := DAK->DAK_TRANSP
Local cNTrans     := ""
Local nCapacMax   := 0
Local nLimMax     := 0
Local nOpcA       := 0
Local nPeso       := DAK->DAK_PESO
Local nVolume     := DAK->DAK_CAPVOL
Local nPtoEntr    := DAK->DAK_PTOENT
Local nI          := 0
Local cDAKTpOp    := DAK->DAK_CDTPOP //Tipo de Opera?o para integra?o com o GFE
Local cDAKClFr    := DAK->DAK_CDCLFR //Classiica?o de Opera?o para integra?o com o GFE

//Declaradas como Private porque sao utilizadas nas funcoes da getdados do frete.
Private aHeader  := {}
Private aCols    := {}
Private oFrete
Private nFrete   := 0
Private oFreAut
Private nFreAut  := 0
Private oRatFre
Private oTipTab

	aButtons   := {     { "CARGA" , { || cVeiDisp := OmsCVDisp(aHoras[1],aHoras[2],aHoras[3],aHoras[4],nPeso,nVolume),Iif(!Empty(cVeiDisp),cVeiculo:= cVeiDisp,cVeiculo := cVeiculo )}, OemtoAnsi(STR0164),OemtoAnsi(STR0176) }}  //Disponibilidade
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se houve acerto financeiro                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If DAK->DAK_ACEFIN <> "2"
		Help(" ",1,"OMS200ACE") //Não é permitido alterar o motorista pois a carga está com a movimentação de Prestação de Contas realizada.
		lProcessa := .F.
	EndIf
	If DAK->DAK_ACECAR == "1"
		Help(" ",1,"DS2602143") //Retorno de Cargas já realizado, não é possível a ManipulaçÆo desta Carga.
		lProcessa := .F.
	EndIf

	cVeicAtu  := cVeiculo // variável de controle para a não sobreposição de motorista vinculado ao veículo
	cVeiAnt   := cVeiculo // variável de controle para gravação de agendamento do veículo (DAN)
	cVeicAnt2 := cVeiculo2
	cVeicAnt3 := cVeiculo3

	If lProcessa
		//Ponto de entrada para adicao de botoes
		If ExistBlock("OS200VEI")
			aButtonUsr := ExecBlock("OS200VEI",.F.,.F.)
			If ValType(aButtonUsr) == "A"  .And. Len(aButtonUsr) > 0
				For nI := 1 To Len(aButtonUsr)
					AAdd(aButtons,aClone(aButtonUsr[nI]))
				Next nI
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada para alteracao do veiculo.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("OS200MNT")
			aVeiculo := ExecBlock("OS200MNT",.F.,.F.,{cVeiculo,cMotorista,cAjuda1,cAjuda2,cAjuda3,4,cVeiculo2,cVeiculo3})
			If ValType(aVeiculo) == "A" .And. Len(aVeiculo) >= 5
				cVeiculo   := aVeiculo[1]
				cMotorista := aVeiculo[2]
				cAjuda1    := aVeiculo[3]
				cAjuda2    := aVeiculo[4]
				cAjuda3    := aVeiculo[5]
				If Len(aVeiculo) >= 7
					cVeiculo2  := aVeiculo[6]
					cVeiculo3  := aVeiculo[7]
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca horarios da carga                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCargas   := OmsTimeCg(DAK->DAK_COD,DAK->DAK_SEQCAR)
		aHoras    := {aCargas[1][6],aCargas[1][7],aCargas[1][8],aCargas[1][9]}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dialog Principal.                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cVeiculo)
			cAliasDA3 := GetNextAlias()
			BeginSql Alias cAliasDA3
				SELECT DA3.DA3_DESC,
						DA3.DA3_PLACA,
						DA3.DA3_CAPACM,
						DA3.DA3_LIMMAX
				FROM %Table:DA3% DA3
				WHERE DA3.DA3_FILIAL = %xFilial:DA3%
				AND DA3.DA3_COD = %Exp:cVeiculo%
				AND DA3.%NotDel%
			EndSql
			If (cAliasDA3)->(!Eof())
				cNomeCam   := (cAliasDA3)->DA3_DESC
				cPlaca     := (cAliasDA3)->DA3_PLACA
				nCapacMax  := (cAliasDA3)->DA3_CAPACM
				nLimMax    := (cAliasDA3)->DA3_LIMMAX
			EndIf
			(cAliasDA3)->(dbCloseArea())
		EndIf

		If !Empty(cVeiculo2)
			cAliasDA3 := GetNextAlias()
			BeginSql Alias cAliasDA3
				SELECT DA3.DA3_DESC,
						DA3.DA3_PLACA
				FROM %Table:DA3% DA3
				WHERE DA3.DA3_FILIAL = %xFilial:DA3%
				AND DA3.DA3_COD = %Exp:cVeiculo2%
				AND DA3.%NotDel%
			EndSql
			If (cAliasDA3)->(!Eof())
				cNomeVeic2 := (cAliasDA3)->DA3_DESC
				cPlaca2    := (cAliasDA3)->DA3_PLACA
			EndIf
			(cAliasDA3)->(dbCloseArea())
		EndIf

		If !Empty(cVeiculo3)
			cAliasDA3 := GetNextAlias()
			BeginSql Alias cAliasDA3
				SELECT DA3.DA3_DESC,
						DA3.DA3_PLACA
				FROM %Table:DA3% DA3
				WHERE DA3.DA3_FILIAL = %xFilial:DA3%
				AND DA3.DA3_COD = %Exp:cVeiculo3%
				AND DA3.%NotDel%
			EndSql
			If (cAliasDA3)->(!Eof())
				cNomeVeic3 := (cAliasDA3)->DA3_DESC
				cPlaca3    := (cAliasDA3)->DA3_PLACA
			EndIf
			(cAliasDA3)->(dbCloseArea())
		EndIf

		If !Empty(cMotorista)
			cAliasDA4 := GetNextAlias()
			BeginSql Alias cAliasDA4
				SELECT DA4.DA4_NOME
				FROM %Table:DA4% DA4
				WHERE DA4.DA4_FILIAL = %xFilial:DA4%
				AND DA4.DA4_COD = %Exp:cMotorista%
				AND DA4.%NotDel%
			EndSql
			If (cAliasDA4)->(!Eof())
				cNomeMot := (cAliasDA4)->DA4_NOME
			EndIf
			(cAliasDA4)->(dbCloseArea())
		EndIf

		If !Empty(cAjuda1)
			cAliasDAU := GetNextAlias()
			BeginSql Alias cAliasDAU
				SELECT DAU.DAU_NOME
				FROM %Table:DAU% DAU
				WHERE DAU.DAU_FILIAL = %xFilial:DAU%
				AND DAU.DAU_COD = %Exp:cAjuda1%
				AND DAU.%NotDel%
			EndSql
			If (cAliasDAU)->(!Eof())
				cNomeAju1 := (cAliasDAU)->DAU_NOME
			EndIf
			(cAliasDAU)->(dbCloseArea())
		EndIf

		If !Empty(cAjuda2)
			cAliasDAU := GetNextAlias()
			BeginSql Alias cAliasDAU
				SELECT DAU.DAU_NOME
				FROM %Table:DAU% DAU
				WHERE DAU.DAU_FILIAL = %xFilial:DAU%
				AND DAU.DAU_COD = %Exp:cAjuda2%
				AND DAU.%NotDel%
			EndSql
			If (cAliasDAU)->(!Eof())
				cNomeAju2 := (cAliasDAU)->DAU_NOME
			EndIf
			(cAliasDAU)->(dbCloseArea())
		EndIf

		If !Empty(cAjuda3)
			cAliasDAU := GetNextAlias()
			BeginSql Alias cAliasDAU
				SELECT DAU.DAU_NOME
				FROM %Table:DAU% DAU
				WHERE DAU.DAU_FILIAL = %xFilial:DAU%
				AND DAU.DAU_COD = %Exp:cAjuda3%
				AND DAU.%NotDel%
			EndSql
			If (cAliasDAU)->(!Eof())
				cNomeAju3 := (cAliasDAU)->DAU_NOME
			EndIf
			(cAliasDAU)->(dbCloseArea())
		EndIf

		If !Empty(cDakTransp)
			cAliasSA4 := GetNextAlias()
			BeginSql Alias cAliasSA4
				SELECT SA4.A4_NREDUZ
				FROM %Table:SA4% SA4
				WHERE SA4.A4_FILIAL = %xFilial:SA4%
				AND SA4.A4_COD = %Exp:cDakTransp%
				AND SA4.%NotDel%
			EndSql
			If (cAliasSA4)->(!Eof())
				cNTrans := (cAliasSA4)->A4_NREDUZ
			EndIf
			(cAliasSA4)->(dbCloseArea())
		EndIf

		DEFINE MSDIALOG oDlg Title OemtoAnsi(STR0112) From 200,001 to 690,690 Pixel //"Associacao do Veiculo"

		@ 0 , 0 BITMAP oBmp RESNAME cBitMap OF oDlg SIZE 48,488 NOBORDER WHEN .F. PIXEL

		// Cria as folders
		@ 030,055 FOLDER oFolder OF oDlg PROMPT OemtoAnsi(STR0014) PIXEL SIZE 275,210

		@ 012,015 Say OemtoAnsi(STR0014) Size 30,7 OF oFolder:aDialogs[1] Pixel //"Carga:"
		@ 010,050 MsGet cCarga  Picture "@!" When .F. Size 25,10 OF oFolder:aDialogs[1] Pixel
		@ 010,090 MsGet cSeqCar Picture "@!" When .F. Size 15,10 OF oFolder:aDialogs[1] Pixel

		@ 029,010 to 095,270 OF oFolder:aDialogs[1] Pixel
		@ 096,010 to 163,270 OF oFolder:aDialogs[1] Pixel
		@ 164,010 to 185,270 OF oFolder:aDialogs[1] Pixel

		@ 037,015 Say OemToAnsi(STR0019)  Size 30,10  OF oFolder:aDialogs[1] Pixel //"Veiculo"

		@ 035,050 MSGet oVeiculo VAR cVeiculo Valid ( OmsVldTransp(cVeiculo,@cVeicAtu,@cNomeCam,@cPlaca,@nCapacMax,@nLimMax,nPeso,nVolume,nPtoEntr,@cMotorista,@cNomeMot,@cAjuda1,@cNomeAju1,@cAjuda2,@cNomeAju2,@cAjuda3,@cNomeAju3,aHoras,,@cVeiculo2,@cVeiculo3,@cNomeVeic2,@cNomeVeic3,@cPlaca2,@cPlaca3,DAK->DAK_COD,DAK->DAK_SEQCAR) .And. OMSA200IPG(4,cVeiculo,"",.F.,,,,cDakTransp) );
				Picture "@!" F3 "DA3" Size 30,10 When lTrava  OF oFolder:aDialogs[1] Pixel
		@ 035,095 MSGet oNomeCam VAR cNomeCam When .F. Size 148,10 OF oFolder:aDialogs[1] Pixel

		@ 052,015 Say OemtoAnsi(STR0095) Size 30,10 OF oFolder:aDialogs[1] Pixel //"Placa"
		@ 050,050 MSGet oPlaca VAR cPlaca When .F. Size 35,10 OF oFolder:aDialogs[1] Pixel

		@ 052,095 Say OemtoAnsi(STR0096) Size 30,10 OF oFolder:aDialogs[1] Pixel //"Capac.Max"
		@ 050,130 MSGet oCapacMax VAR nCapacMax When .F. Size 35,10 OF oFolder:aDialogs[1] Pixel

		@ 052,180 Say OemtoAnsi(STR0097) Size 30,10 OF oFolder:aDialogs[1] Pixel //"Lim. Max."
		@ 050,208 MSGet oLimMax VAR nLimMax When .F. Size 35,10 OF oFolder:aDialogs[1] Pixel

		@ 067,015 Say OemtoAnsi(STR0272) Size 30,10 OF oFolder:aDialogs[1] Pixel //"Veículo 2"
		@ 065,050 MSGet cVeiculo2 Valid VldReboque(cVeiculo2,@cNomeVeic2,@cPlaca2,aHoras,cCarga,cSeqCar) Picture "@!" F3 "DA3" Size 30,10 When lTrava  OF oFolder:aDialogs[1] Pixel

		@ 065,095 MSGet cNomeVeic2 When .F. Size 70,10 OF oFolder:aDialogs[1] Pixel

		@ 067,180 Say OemtoAnsi(STR0274) Size 30,10 OF oFolder:aDialogs[1] Pixel //"Placa 2"
		@ 065,208 MSGet cPlaca2 When .F. Size 35,10 OF oFolder:aDialogs[1] Pixel

		@ 082,015 Say OemtoAnsi(STR0273) Size 30,10 OF oFolder:aDialogs[1] Pixel //"Veículo 3"
		@ 080,050 MSGet cVeiculo3 Valid VldReboque(cVeiculo3,@cNomeVeic3,@cPlaca3,aHoras,cCarga,cSeqCar) Picture "@!" F3 "DA3" Size 30,10 When lTrava  OF oFolder:aDialogs[1] Pixel

		@ 080,095 MSGet cNomeVeic3 When .F. Size 70,10 OF oFolder:aDialogs[1] Pixel

		@ 082,180 Say OemtoAnsi(STR0275) Size 30,10 OF oFolder:aDialogs[1] Pixel //"Placa 3"
		@ 080,208 MSGet cPlaca3 When .F. Size 35,10 OF oFolder:aDialogs[1] Pixel

		@ 103,015 Say OemtoAnsi(STR0069) Size 30,10 OF oFolder:aDialogs[1] Pixel //"Motorista"
		@ 101,050 MSGet cMotorista Picture "@!" Valid ( Os200Motor(cMotorista,@cNomeMot,cCarga,cSeqCar) .And. OMSA200IPG(4,"",cMotorista,.F.,,,,cDakTransp) ) F3 "DA4" Size 30,10 When lTrava OF oFolder:aDialogs[1] Pixel
		@ 101,095 MsGet oNomeMot VAR cNomeMot When .F. Size 148,10 OF oFolder:aDialogs[1] Pixel

		@ 118,015 Say OemtoAnsi(STR0092) Size 40,10 OF oFolder:aDialogs[1] Pixel //"1o. Ajudante"
		@ 116,050 MSGet cAjuda1 Picture "@!" Valid Oms200Aju(cAjuda1,@cNomeAju1,{"",cAjuda2,cAjuda3},cCarga,cSeqCar) F3 "DAU" Size 30,10 When lTrava OF oFolder:aDialogs[1] Pixel
		@ 116,095 MsGet oNomeAju1 VAR cNomeAju1 When .F. Size 148,10 OF oFolder:aDialogs[1] Pixel

		@ 133,015 Say OemtoAnsi(STR0093) Size 40,10 OF oFolder:aDialogs[1] Pixel //"2o. Ajudante"
		@ 131,050 MSGet cAjuda2 Picture "@!" Valid Oms200Aju(cAjuda2,@cNomeAju2,{cAjuda1,"",cAjuda3},cCarga,cSeqCar) F3 "DAU" Size 30,10 When lTrava OF oFolder:aDialogs[1] Pixel
		@ 131,095 MsGet oNomeAju1 VAR cNomeAju2 When .F. Size 148,10 OF oFolder:aDialogs[1] Pixel

		@ 148,015 Say OemtoAnsi(STR0094) Size 40,10 OF oFolder:aDialogs[1] Pixel //"3o. Ajudante"
		@ 146,050 MSGet cAjuda3 Picture "@!" Valid Oms200Aju(cAjuda3,@cNomeAju3,{cAjuda1,cAjuda2,"",cCarga,cSeqCar}) F3 "DAU" Size 30,10 When lTrava OF oFolder:aDialogs[1] Pixel
		@ 146,095 MsGet oNomeAju1 VAR cNomeAju3 When .F. Size 148,10 OF oFolder:aDialogs[1] Pixel

		@ 170,015 Say OemtoAnsi(STR0260) Size 40,10 OF oFolder:aDialogs[1] Pixel //"Transp."
		@ 168,050 MSGet cDakTransp Picture "@!" Valid Os200NomTr(cDakTransp, @cNTrans) F3 "SA4" Size 30,10 OF oFolder:aDialogs[1] Pixel
		@ 168,095 MsGet cNTrans When .F. Size 148,10 OF oFolder:aDialogs[1] Pixel

		ACTIVATE DIALOG oDlg ON INIT (EnchoiceBar( oDlg , { || Iif(MesCodVeic(cVeiculo,cVeiculo2,cVeiculo3),(nOpcA:=1,,OMSA200IPG(4,cVeiculo,cMotorista,.T.,,,,cDakTransp,,,cVeiculo2,cVeiculo3),oDlg:End()),.F.) }, {||nOpcA := 0,oDlg:End()},,aButtons)) CENTERED

		If nOpcA == 1
			Oms200PMot(cCarga,cSeqCar,cVeiculo,cMotorista,cAjuda1,cAjuda2,cAjuda3,cVeiAnt,cCodOper,cNoProc,cPedComOp,cDakTransp,cVeiculo2,cVeicAnt2,cVeiculo3,cVeicAnt3)

			//Verifica se o Romaneio j?foi criado no GFE -> Tabela GWN
			//Se o retorno for .F., ?necess?io criar o romaneio no GFE.
			IF !Os200GWN(cCarga, cSeqCar)
				OMSA200IPG(3,cVeiculo,cMotorista,.T.,cCarga,cSeqCar,/*cPedido*/,cDakTransp,cDAKTpOp,cDAKClFr,cVeiculo2,cVeiculo3)
			EndIF

			If lOs200Ass
				ExecBlock("OS200ASS",.F.,.F.)
			EndIf
		EndIf
		// Integração Agroindústria - UBS -> Expedição de Sementes
		If FindFunction("OGX225VAL") .And. lAGRUBS
			OGX225VAL(cVeiculo,cCarga)
		Endif
	EndIf
Return( Nil )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³Oms200PMot³ Autor ³ Daniel Pereira        ³ Data ³ 29/01/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Chamada do Processamento.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DFATA431                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms200PMot(cCarga,cSeqCar,cVeiculo,cMotorista,cAjuda1,cAjuda2,cAjuda3,cVeiAnt,cCodOper,cNoProc,cPedComOp,cDakTransp,cVeiculo2,cVeicAnt2,cVeiculo3,cVeicAnt3)
Local lDakVeic2 := DAK->( ColumnPos("DAK_VEIC2" ) ) > 0
Local lAlocVei  := SuperGetMv("MV_ALOCVEI",.F.,.T.)
Local lOs200Mot := ExistBlock("OS200MOT")
Local aCargas   := {{cCarga,cSeqCar}}
Local aAreaAnt  := GetArea()
Local aAreaDAK  := DAK->(GetArea())
Local aAreaSF2  := SF2->(GetArea())
Local aRotas    := {}
Local oTempTable:= ""
Local cCpoCapac := IIf(SuperGetmv("MV_OMSCAPA",.F.,"1")=="1","DA3_CAPACN","DA3_CAPACM")
Local cPrxSeq   := ""
Local cAliasDA3 := Nil
Local cAliasDAK := Nil
Local cAliasSC9 := Nil
Local nCapac    := 0

Default cVeiAnt   := ""
Default cCodOper  := ""
Default cNoProc   := ""
Default cPedComOp := ""
Default cDakTransp:= Criavar("A4_COD",.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retira o empenho do veiculo anterior ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAlocVei
		If cVeiAnt <> cVeiculo .And. !Empty(cVeiAnt)
			OsVAgenda(cCarga,cSeqCar,cVeiAnt,2)
		EndIf
		If cVeicAnt2 <> cVeiculo2 .And. !Empty(cVeicAnt2)
			OsVAgenda(cCarga,cSeqCar,cVeicAnt2,2)
		EndIf
		If cVeicAnt3 <> cVeiculo3 .And. !Empty(cVeicAnt3)
			OsVAgenda(cCarga,cSeqCar,cVeicAnt3,2)
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Regrava a carga atual com o codigo da carga de destino       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasDA3 := GetNextAlias()
	BeginSql Alias cAliasDA3
		SELECT DA3.R_E_C_N_O_ RECNODA3
		FROM %Table:DA3% DA3
		WHERE DA3.DA3_FILIAL = %xFilial:DA3%
		AND DA3.DA3_COD = %Exp:cVeiculo%
		AND DA3.%NotDel%
	EndSql
	If (cAliasDA3)->(!Eof())
		DA3->(dbGoTo((cAliasDA3)->RECNODA3))
		nCapac := DA3->(FieldGet(ColumnPos(cCpoCapac)))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pergunta a quebra de carga caso a carga ainda nao tenha sido faturada³
		//³e nao caiba no caminhao selecionado                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Pergunte("OMS200", .F.)
		If ((DAK->DAK_PESO > nCapac) .Or. (DAK->DAK_CAPVOL > DA3->DA3_VOLMAX)) .And. DAK->DAK_FEZNF == "2" .And. MV_PAR05 == 1
			If  MsgYesNo(OemtoAnsi(STR0126)) //"Caminhao nao suporta a carga selecionada. Deseja dividir a carga em outra sequencia para que esta seja alocada em outro veiculo ?"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Processa a diferenca de itens para a quebra de carga     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Processa({ ||Oms210Unt(aCargas,cVeiculo,@oTempTable,1,1,DA3->DA3_CAPACN,DA3->DA3_VOLMAX,.T.,.T.) })

				If Select("TRB") > 0
					cPrxSeq := OsSeqCar(aCargas[1][1])
					DbSelectArea("TRB")
					DbGoTop()
					Do While !(Eof())
						SC9->(MsGoto(TRB->TRB_RECNO))
						//-- Exclui o item do SC9 da carga atual
						MaAvalSC9("SC9",8,,,,,,aRotas)

						Reclock("SC9",.F.)
						SC9->C9_CARGA  := aCargas[1][1]
						SC9->C9_SEQCAR := cPrxSeq
						SC9->C9_SEQENT := OsSeqEnt(SC9->C9_CARGA,SC9->C9_SEQCAR,SC9->C9_PEDIDO)
						SC9->(MsUnlock())
						//-- Inclui o item do SC9 na nova carga
						MaAvalSC9("SC9",7,,,,,,aRotas)

						DbSelectArea("TRB")
						DbSkip()
					EndDo
					oTempTable:Delete()
				EndIf
			EndIf
		EndIf
		(cAliasDA3)->(dbCloseArea())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Empenha o veiculo                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAlocVei
			If !Empty(cVeiculo)
				OsVAgenda(cCarga,cSeqCar,cVeiculo ,1)
			EndIf
			If lDakVeic2
				If !Empty(cVeiculo2)
					OsVAgenda(cCarga,cSeqCar,cVeiculo2,1)
				EndIf
				If !Empty(cVeiculo3)
					OsVAgenda(cCarga,cSeqCar,cVeiculo3,1)
				EndIf
			EndIf
		EndIf
	EndIf
	cAliasDAK := GetNextAlias()
	BeginSql Alias cAliasDAK
		SELECT DAK.R_E_C_N_O_ RECNODAK
		FROM %Table:DAK% DAK
		WHERE DAK.DAK_FILIAL = %xFilial:DAK%
		AND DAK.DAK_COD = %Exp:cCarga%
		AND DAK.DAK_SEQCAR = %Exp:cSeqCar%
		AND DAK.%NotDel%
	EndSql
	If (cAliasDAK)->(!Eof())
		DAK->(dbGoTo((cAliasDAK)->RECNODAK))

		RecLock("DAK",.F.)
		DAK->DAK_CAMINH := cVeiculo
		If lDakVeic2
			DAK->DAK_VEIC2  := cVeiculo2
			DAK->DAK_VEIC3  := cVeiculo3
		EndIf
		DAK->DAK_MOTORI := cMotorista
		DAK->DAK_AJUDA1 := cAjuda1
		DAK->DAK_AJUDA2 := cAjuda2
		DAK->DAK_AJUDA3 := cAjuda3
		DAK->DAK_TRANSP := cDakTransp
		DAK->(MsUnLock())

		Pergunte("OMS200C",.F.)

		cAliasSC9 := GetNextAlias()
		BeginSql Alias cAliasSC9
			SELECT SC5.R_E_C_N_O_ RECNOSC5
			FROM %Table:SC9% SC9
			INNER JOIN %Table:SC5% SC5
			ON SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = SC9.C9_PEDIDO
			AND SC5.%NotDel%
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_CARGA = %Exp:DAK->DAK_COD%
			AND SC9.C9_SEQCAR = %Exp:DAK->DAK_SEQCAR%
			AND SC9.%NotDel%
		EndSql
		Do While (cAliasSC9)->(!Eof())
			SC5->(dbGoTo((cAliasSC9)->RECNOSC5))
			RecLock('SC5',.F.)
			If mv_par01 == 1
				SC5->C5_VEICULO := cVeiculo
			EndIf
			If !Empty(cDakTransp)
				SC5->C5_TRANSP  := cDakTransp
			EndIf
			SC5->(MsUnlock())

			(cAliasSC9)->(dBSkip())
		EndDo
		(cAliasSC9)->(dbCloseArea())

		cAliasSF2 := GetNextAlias()
		BeginSql Alias cAliasSF2
			SELECT SF2.R_E_C_N_O_ RECNOSF2
			FROM %Table:DAI% DAI
			INNER JOIN %Table:SF2% SF2
			ON SF2.F2_FILIAL = %xFilial:SF2%
			AND SF2.F2_DOC = DAI.DAI_NFISCA
			AND SF2.F2_SERIE = DAI.DAI_SERIE
			AND SF2.%NotDel%
			WHERE DAI.DAI_FILIAL = %xFilial:DAI%
			AND DAI.DAI_COD = %Exp:DAK->DAK_COD%
			AND DAI.DAI_SEQCAR = %Exp:DAK->DAK_SEQCAR%
			AND DAI.%NotDel%
		EndSql
		Do While (cAliasSF2)->(!Eof())
			SF2->(dbGoTo((cAliasSF2)->RECNOSF2))
			RecLock("SF2",.F.)
			SF2->F2_VEICUL1 := cVeiculo
			SF2->F2_VEICUL2 := cVeiculo2
			SF2->F2_VEICUL3 := cVeiculo3
			If !Empty(cDakTransp)
				SF2->F2_TRANSP  := cDakTransp
			EndIf
			SF2->(MsUnlock())
			(cAliasSF2)->(dbSkip())
		EndDo
		(cAliasSF2)->(dbCloseArea())
	EndIf
	(cAliasDAK)->(dbCloseArea())

	If lOs200Mot
		ExecBlock("OS200MOT",.F.,.F.)
	EndIf
	RestArea(aAreaSF2)
	RestArea(aAreaDAK)
	RestArea(aAreaAnt)
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OmsPesqPed³ Autor ³ Daniel Pereira       ³  Data ³28.01.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Pesquisa registro em um arquivo temporario                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array com a estrutura do TRB                         ³±±
±±³          ³ExpA2 : Array com os dados de exibicao do TRB                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Esta rotina tem como objetivo cancelar as movimentacoes      ³±±
±±³          ³feitas do cliente                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function OmsPesqPed(cAliasTRB,aCampos,aCpoBrw)
Local aCpoLbl  := {}
Local aCpo     := {}
Local oDlg
Local cCpoLbl  := ""
Local cCpo     := ""
Local xPesq    := Space(20)
Local nX       := 0
Local nTipo    := 1
Local nOpca    := 0
Local nRegTRB  := TRBPED->(Recno())

	For nX := 1 to Len(aCpoBrw)
		If !Empty(aCpoBrw[nX][3])
			AAdd(aCpoLbl,aCpoBrw[nX][3])
			AAdd(aCpo,aCpoBrw[nX][1])
		EndIf
	Next nX

	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0117)  FROM 09,0 TO 20,50 OF oMainWnd

	@ 000, 0 BITMAP oBmp RESNAME "PROJETOAP" OF oDlg SIZE 30, 1000 NOBORDER WHEN .F. PIXEL ADJUST


	@ 014,035 SAY OemtoAnsi(STR0118) OF oDlg PIXEL
	@ 014,075 MSCOMBOBOX oCpo VAR cCpoLbl ITEMS aCpoLbl SIZE 55, 65 OF oDlg PIXEL ON CHANGE (nTipo := oCpo:nAt,OmsChgPict(nTipo,aCampos,aCpo,@xPesq,oPesq,@cCpo))

	@ 028,035 SAY OemtoAnsi(STR0119) OF oDlg PIXEL
	@ 028,075 MSGET oPesq VAR xPesq Picture "@!" SIZE 113, 10 OF oDlg PIXEL

	DEFINE SBUTTON oBut1 FROM 062, 130 TYPE 1 ACTION ( nOpca := 1, oDlg:End() ) ENABLE OF oDlg
	DEFINE SBUTTON oBut1 FROM 062, 160 TYPE 2 ACTION ( nOpca := 0, oDlg:End() ) ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT OmsChgPict(nTipo, aCampos, aCpo, @xPesq, oPesq, @cCpo)

	If nOpca == 1
		DbSelectArea(cAliasTRB)
		DbGoTop()
		Do While !Eof() .And. FieldGet(ColumnPos(cCpo)) != xPesq
			(cAliasTRB)->(DbSkip())
		EndDo
		If (cAliasTRB)->(Eof())
			(cAliasTRB)->(MsGoto(nRegTRB))
		EndIf
		oMark:oBrowse:SetFocus()
	EndIf
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OmsChgPict³ Autor ³ Daniel Pereira        ³ Data ³28.01.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Tratamento da pesquisa de arquivos temporarios               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Posicao do campo no Array                            ³±±
±±³          ³ExpA2 : Array com a estrutura do arquivo                     ³±±
±±³          ³ExpA3 : Array com os campos e labels do arquivo              ³±±
±±³          ³ExpX4 : Variavel de pesquisa                                 ³±±
±±³          ³ExpN5 : Objeto da variavel de pesquisa                       ³±±
±±³          ³ExpC6 : Nome do campo por referencia para ser pesquisado     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Esta rotina tem como objetivo tratar a pesquisa a ser reali  ³±±
±±³          ³zada no arquivo temporario                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OmsChgPict(nTipo,aCampos,aCpo,xPesq,oPesq,cCpo)
Local nPosCpo := 0
Local cPict   := ""
	nPosCpo := Ascan(aCampos,{|x| x[1] == Alltrim(aCpo[nTipo])})
	If nPosCpo > 0
		cCpo  := aCampos[nPosCpo][1]
		Do Case
			Case aCampos[nPosCpo][2] == "N"
				xPesq := 0
				cPict := "@E 99,999,999.99"
			Case aCampos[nPosCpo][2] == "D"
				xPesq := dDataBase
				cPict := "@D"
			Case aCampos[nPosCpo][2] == "C"
				xPesq := Space(aCampos[nPosCpo][3])
				cPict := Replicate("!",aCampos[nPosCpo][3])
		EndCase
	EndIf
	oPesq:oGet:Picture := cPict
	oPesq:Refresh()
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Os200Blq  ³ Autor ³ Daniel Pereira        ³ Data ³29.01.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Bloqueio de carga manual                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Esta rotina tem como objetivo bloquear as cargas manualmente ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Os200Blq()
Local aArea    := GetArea()
Local cTexto    := ""
Local cCarga    := DAK->DAK_COD
Local cSeqCar   := DAK->DAK_SEQCAR
Local cTipoOper := ""
Local lBloqueio := .F.
	Do Case
		Case DAK->DAK_BLQCAR == "1"
			cTexto    := OemtoAnsi(STR0124) //"Deseja desbloquear manualmente a carga para alteracoes ?"
			cTipoOper := "2"
		Case DAK->DAK_BLQCAR == "2" .Or. DAK->DAK_BLQCAR == ' '
			cTexto    := OemtoAnsi(STR0125) //"Deseja bloquear manualmente a carga para alteracoes ?"
			cTipoOper := "1"
	EndCase
	lBloqueio := OsBlqExec(cCarga,cSeqCar)
	//-- PE para tratamento adicional no bloqueio da carga
	If ExistBlock("OM200BLQ")
		lRetPE := ExecBlock("OM200BLQ",.F.,.F.,{lBloqueio})
		lBloqueio := If(ValType(lRetPE)=="L",lRetPE,lBloqueio)
	EndIf

	If lBloqueio
		Help(" ",1,"OMS200CGBL") //"Carga bloqueada ou com serviço em execução."
	Else
		If MsgYesNo(cTexto)
			Do Case
				Case cTipoOper == "1"
					OsAvalDAK("DAK",11)
				Case cTipoOper == "2"
					OsAvalDAK("DAK",12)
			EndCase
		EndIf
	EndIf
	RestArea( aArea )
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Oms200Time³ Autor ³ Daniel Pereira        ³ Data ³30.01.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Calcula hora de chegada no cliente                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ExpC1 - Hora de inicio                                       ³±±
±±³          ³ExpD2 - Data de inicio                                       ³±±
±±³Parametros³ExpA3 - Array com os dados dos contendo e nao importando a   ³±±
±±³          ³        ordem pois a posicao sera passada nos outros parame- ³±±
±±³          ³        tros da funcao.                                      ³±±
±±³          ³      [1]-Filial                                             ³±±
±±³          ³      [2]-Rota                                               ³±±
±±³          ³      [3]-Zona                                               ³±±
±±³          ³      [4]-Setor                                              ³±±
±±³          ³      [5]-Cliente                                            ³±±
±±³          ³      [6]-Loja                                               ³±±
±±³          ³      [7]-Peso                                               ³±±
±±³          ³      [8]-Volume                                             ³±±
±±³          ³      [9]-Hora (a ser retornado pela funcao)                 ³±±
±±³          ³      [10]-Time Service (a ser retornado pela funcao)        ³±±
±±³          ³ExpC4 - Veiculo                                              ³±±
±±³          ³ExpN5 - Posicao da Filial de origem no array                 ³±±
±±³          ³ExpN6 - Posicao do cliente no array                          ³±±
±±³          ³ExpN7 - Posicao da Loja no array                             ³±±
±±³          ³ExpN8 - Posicao da Rota no Array                             ³±±
±±³          ³ExpN9 - Posicao da Zona no array                             ³±±
±±³          ³ExpN10 - Posicao do Setor no array                           ³±±
±±³          ³ExpN11 - Posicao da Peso no array                            ³±±
±±³          ³ExpN12-  Posicao do Volume no array                          ³±±
±±³          ³ExpN13 - Posicao da Hora no array  (retorno)                 ³±±
±±³          ³ExpN14 - Posicao do Time Service   (retorno)                 ³±±
±±³          ³ExpN15 - Posicao do retorno da janela (.T. ou .F.)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - .T. Sucesso no Lock ou no Unlock                     ³±±
±±³          ³        .F. Nao realizou o lock ou Unlock                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Esta rotina tem como objetivo bloquear os registros dos pe-  ³±±
±±³          ³didos marcados no browse de cargas                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Oms200Time(cHrStart,dDtStart,aTime,cVeiculo,nPosFil,nPosCli,nPosLoja,nPosRota,nPosZona,nPosSetor,nPosPeso,nPosVol,nPosHora,nPosTime,nPosJan,nPosDtC,nPosDtS)
Local aRotas    := {}
Local cFilSA1   := ""
Local cRotaAnt  := ""
Local cZonaAnt  := ""
Local cSetorAnt := ""
Local cCliAnt   := ""
Local cLojaAnt  := ""
Local dDataIni  := dDtStart
Local nX        := 0
Local nTempo    := 0
Local nSetor    := 0
Local nZona     := 0
Local nRota     := 0
Local lNew      := .F.
Local lNSrvTime := .T.
Local lRet      := .T.
Local cTimSrv   := SuperGetMv("MV_CTIMSRV",.F.,"1")
Local cAliasSA1 := Nil
Local cAliasDA5 := Nil
Local cAliasDA6 := Nil
Local cAliasDA8 := Nil

DEFAULT nPosFil   := 1
DEFAULT nPosCli   := 2
DEFAULT nPosLoja  := 3
DEFAULT nPosRota  := 4
DEFAULT nPosZona  := 5
DEFAULT nPosSetor := 6
DEFAULT nPosPeso  := 7
DEFAULT nPosVol   := 8
DEFAULT nPosHora  := 9
DEFAULT nPosTime  := 10
DEFAULT nPosJan   := 0
DEFAULT cHrStart  := SuperGetMv("MV_CGSTART",.F.,"08:00")
DEFAULT dDtStart  := dDatabase

	If Empty(cHrStart)
		cHrStart:="08:00"
	EndIf

	If l200Auto
		aArrayCarga := aClone(xArrCarga)
	EndIf

	If Len(aTime) > 0
		cRotaAnt  := aTime[1][nPosRota]
		cZonaAnt  := aTime[1][nPosZona]
		cSetorAnt := aTime[1][nPosSetor]
		cCliAnt   := aTime[1][nPosCli]
		cLojaAnt  := aTime[1][nPosLoja]

		For nX := 1 to Len(aTime)
			nTempo := 0
			lNew   := .F.
			cFilSA1 := Iif(nPosFil == 0, xFilial("SA1"),OsFilial("SA1",aTime[nX][nPosFil]))
			cAliasSA1 := GetNextAlias()
			BeginSql Alias cAliasSA1
				SELECT SA1.A1_GRPVEN
				FROM %Table:SA1% SA1
				WHERE SA1.A1_FILIAL = %Exp:cFilSA1%
				AND SA1.A1_COD = %Exp:aTime[nX][nPosCli]%
				AND SA1.A1_LOJA = %Exp:aTime[nX][nPosLoja]%
			EndSql
			aTime[nX][nPosDtS]  := dDataIni
			aTime[nX][nPosDtC]  := dDataIni
			aTime[nX][nPosTime] := "0000:00"
			aTime[nX][nPosHora] := cHrStart
			If (cAliasSA1)->(!Eof())
				// Inclui no array caso seja a primeira vez
				If Len(aRotas) == 0
					cAliasDA8 := GetNextAlias()
					BeginSql Alias cAliasDA8
						SELECT DA8.DA8_TEMPO
						FROM %Table:DA8% DA8
						WHERE DA8.DA8_FILIAL = %xFilial:DA8%
						AND DA8.DA8_COD = %Exp:aTime[nX][nPosRota]%
						AND DA8.%NotDel%
					EndSql
					If (cAliasDA8)->(!Eof())
						nTempo += HoratoInt((cAliasDA8)->DA8_TEMPO,4)
						AAdd(aRotas,{aTime[nX][nPosRota],aTime[nX][nPosZona],aTime[nX][nPosSetor],aTime[nX][nPosCli],aTime[nX][nPosLoja] })
					EndIf
					(cAliasDA8)->(dbCloseArea())
				EndIf
				// Busca se existe troca de cliente no setor
				nSetor := Ascan(aRotas,{|x| x[3] == aTime[nX][nPosSetor]})
				If nSetor > 0
					lNew := ( Ascan(aRotas,{|x| x[3]+x[4]+x[5] == aTime[nX][nPosSetor]+aTime[nX][nPosCli]+aTime[nX][nPosLoja] } ) == 0 )
					If lNew .Or. cSetorAnt+cCliAnt+cLojaAnt <> aTime[nX][nPosSetor]+aTime[nX][nPosCli]+aTime[nX][nPosLoja]
						cAliasDA6 := GetNextAlias()
						BeginSql Alias cAliasDA6
							SELECT DA6.DA6_TEMPO
							FROM %Table:DA6% DA6
							WHERE DA6.DA6_FILIAL = %xFilial:DA6%
							AND DA6.DA6_PERCUR = %Exp:aTime[nX][nPosZona]%
							AND DA6.DA6_ROTA = %Exp:aTime[nX][nPosSetor]%
							AND DA6.%NotDel%
						EndSql
						If (cAliasDA6)->(!Eof())
							nTempo += HoratoInt((cAliasDA6)->DA6_TEMPO,4)
							If lNew
								AAdd(aRotas,{aTime[nX][nPosRota],aTime[nX][nPosZona],aTime[nX][nPosSetor],aTime[nX][nPosCli],aTime[nX][nPosLoja] })
							EndIf
						EndIf
						(cAliasDA6)->(dbCloseArea())
					EndIf
				EndIf
				// Busca se existe troca de Setores nas zonas
				nZona := Ascan(aRotas,{|x| x[2] == aTime[nX][nPosZona]})
				If nZona > 0
					lNew := ( Ascan(aRotas,{|x| x[2]+x[3] == aTime[nX][nPosZona]+aTime[nX][nPosSetor]}) == 0 )
					If lNew .Or. cZonaAnt+cSetorAnt <> aTime[nX][nPosZona]+aTime[nX][nPosSetor]
						cAliasDA5 := GetNextAlias()
						BeginSql Alias cAliasDA5
							SELECT DA5.DA5_TEMPO
							FROM %Table:DA5% DA5
							WHERE DA5.DA5_FILIAL = %xFilial:DA5%
							AND DA5.DA5_COD = %Exp:aTime[nX][nPosZona]%
							AND DA5.%NotDel%
						EndSql
						If (cAliasDA5)->(!Eof())
							nTempo := HoratoInt((cAliasDA5)->DA5_TEMPO,4)
							If lNew
								AAdd(aRotas,{aTime[nX][nPosRota],aTime[nX][nPosZona],aTime[nX][nPosSetor],aTime[nX][nPosCli],aTime[nX][nPosLoja] })
							EndIf
						EndIf
						(cAliasDA5)->(dbCloseArea())
					EndIf
				EndIf
				// Busca se existe troca de zonas e setores na rota
				nRota := Ascan(aRotas,{|x| x[1] == aTime[nX][nPosRota]})
				If nRota > 0
					lNew := ( Ascan(aRotas,{|x| x[1]+x[2]+x[3] == aTime[nX][nPosRota]+aTime[nX][nPosZona]+aTime[nX][nPosSetor]}) == 0 )
					If lNew .Or. cRotaAnt+cZonaAnt+cSetorAnt <> aTime[nX][nPosRota]+aTime[nX][nPosZona]+aTime[nX][nPosSetor]
						cAliasDA8 := GetNextAlias()
						BeginSql Alias cAliasDA8
							SELECT DA8.DA8_TEMPO
							FROM %Table:DA8% DA8
							WHERE DA8.DA8_FILIAL = %xFilial:DA8%
							AND DA8.DA8_COD = %Exp:aTime[nX][nPosRota]%
							AND DA8.%NotDel%
						EndSql
						If (cAliasDA8)->(!Eof())
							nTempo += HoratoInt((cAliasDA8)->DA8_TEMPO,4)
							If lNew
								AAdd(aRotas,{aTime[nX][nPosRota],aTime[nX][nPosZona],aTime[nX][nPosSetor],aTime[nX][nPosCli],aTime[nX][nPosLoja] })
							EndIf
						EndIf
						(cAliasDA8)->(dbCloseArea())
					EndIf
				EndIf
				// Calcula hora de parada
				aTime[nX][nPosDtC]  := dDataIni
				If nTempo > 0
					SomaDiaHor(@aTime[nX][nPosDtC],@cHrStart,nTempo)
				EndIf
				aTime[nX][nPosDtS]  := aTime[nX][nPosDtC]
				aTime[nX][nPosHora] := cHrStart
				// Calcula time service
				If cTimSrv == "2" // Considera somente uma vez o TIME SERVICE para o mesmo cliente/loja do Pedido.
					If lNSrvTime .Or. cCliAnt+cLojaAnt <> aTime[nX][nPosCli]+aTime[nX][nPosLoja]
						aTime[nX][nPosTime] := OmsSrvTime((cAliasSA1)->A1_GRPVEN,aTime[nX][nPosCli],aTime[nX][nPosLoja],aTime[nX][nPosPeso],aTime[nX][nPosVol])
						lNSrvTime := .F.
					Else
						aTime[nX][nPosTime] := "0000:00"
					EndIf
				Else // Considera o TIME SERVICE para o mesmo cliente/loja do Pedido.
					aTime[nX][nPosTime] := OmsSrvTime((cAliasSA1)->A1_GRPVEN,aTime[nX][nPosCli],aTime[nX][nPosLoja],aTime[nX][nPosPeso],aTime[nX][nPosVol])
				EndIf

				If nPosJan <> 0
					aTime[nX][nPosJan] := OmsJanEntr((cAliasSA1)->A1_GRPVEN,aTime[nX][nPosCli],aTime[nX][nPosLoja],aTime[nX][nPosHora],cVeiculo,aTime[nX][nPosDtC])
					// Se houve aluguma restricao devolve .F. para verificacao
					If aTime[nX][nPosJan] <> 1
						lRet := .F.
					EndIf
				EndIf
				// Calcula proxima hora de parada incluindo time service
				nTempo := HoraToInt(aTime[nX][nPosTime],4)
				If nTempo > 0
					SomaDiaHor(@aTime[nX][nPosDtS],@cHrStart,nTempo)
				EndIf
				// Atribui os Valores
				dDataIni  := aTime[nX][nPosDtS]
				cRotaAnt  := aTime[nx][nPosRota]
				cZonaAnt  := aTime[nx][nPosZona]
				cSetorAnt := aTime[nx][nPosSetor]
				cCliAnt   := aTime[nx][nPosCli]
				cLojaAnt  := aTime[nx][nPosLoja]
			EndIf
			(cAliasSA1)->(dbCloseArea())
		Next nX
	EndIf
Return( lRet )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Oms200Seq ³ Autor ³ Daniel Pereira        ³ Data ³31.01.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Reordena e recalcula horas no acols na manutencao de carga   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - .T.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Esta rotina tem como objetivo ordenar o acols de acordo com  ³±±
±±³          ³o digitado para recalculo das horas de entrega               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Oms200Seq()
Local nPosSeq  := Ascan( aHeader ,{|x| Alltrim(x[2]) == "DAI_SEQUEN"} )
Local nPosFil  := Ascan( aHeader ,{|x| Alltrim(x[2]) == "DAI_FILPV"}  )
Local nPosCli  := Ascan( aHeader ,{|x| Alltrim(x[2]) == "DAI_CLIENT"} )
Local nPosLoja := Ascan( aHeader ,{|x| Alltrim(x[2]) == "DAI_LOJA"}   )
Local nPosRota := Ascan( aHeader ,{|x| Alltrim(x[2]) == "DAI_ROTEIR"} )
Local nPosZona := Ascan( aHeader ,{|x| Alltrim(x[2]) == "DAI_PERCUR"} )
Local nPosSetor:= Ascan( aHeader ,{|x| Alltrim(x[2]) == "DAI_ROTA"}   )
Local nPosPeso := Ascan( aHeader ,{|x| Alltrim(x[2]) == "DAI_PESO"}   )
Local nPosVol  := Ascan( aHeader ,{|x| Alltrim(x[2]) == "DAI_CAPVOL"} )
Local nPosHora := Ascan( aHeader ,{|x| Alltrim(x[2]) == "DAI_CHEGAD"} )
Local nPosTime := Ascan( aHeader ,{|x| Alltrim(x[2]) == "DAI_TMSERV"} )

	aCols[n][nPosSeq] := M->DAI_SEQUEN
	aCols := aSort(aCols,,,{|x,y| x[nPosSeq] < y[nPosSeq] })

	Oms200Time(DAK->DAK_HRSTAR,DAK->DAK_DATA,aCols,nPosFil,nPosCli,nPosLoja,nPosRota,nPosZona,nPosSetor,nPosPeso,nPosVol,nPosHora,nPosTime)
	oGetD:oBrowse:Refresh()
Return( .T. )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Os200Gant ³ Autor ³ Daniel Pereira        ³ Data ³29.01.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Exibe grafico de ] das cargas em aberto                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - .T.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Esta rotina tem como objetivo ordenar o acols de acordo com  ³±±
±±³          ³o digitado para recalculo das horas de entrega               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Os200Gant()
Local lRet     := .T.
Local aCargas  := {}
Local aCores   := {CLR_HBLUE, CLR_HRED,CLR_BROWN, CLR_BLACK, CLR_GREEN, CLR_GRAY}
Local aArea    := GetArea()
Local aAreaDAK := DAK->(GetArea())
Local aConfig  := {}
Local aAuxCfg  := {}
Local oFont
Local oDlgCar
Local oBmp
Local nTop     := oMainWnd:nTop
Local nLeft    := oMainWnd:nLeft
Local nBottom  := oMainWnd:nBottom-60
Local nRight   := oMainWnd:nRight-10
Local nCor     := 0
Local nX       := 0
Local nTsk
Local dIni     := ddatabase

Private bRfshGantt //variavel utilizada no PMSGANTT para fazer o refresh

	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

	aConfig := {1,.T.,.T.,.T.,.T.,.T.,.T.,.T.}

	aCargas  := OmsTimeCg()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estrutura do array de retorno                              ³
	//³              [1] - Codigo da carga                        ³
	//³              [2] - Sequencia da carga                     ³
	//³              [3] - Veiculo da carga                       ³
	//³              [4] - Descricao do veiculo                   ³
	//³              [5] - Recno                                  ³
	//³              [6] - Data da Carga                          ³
	//³              [7] - Hora de inicio da entrega              ³
	//³              [8] - Data de Saida final da carga           ³
	//³              [9] - Hora de Saida final da carga           ³
	//³              [10] - SubArray com os itens da carga        ³
	//³                    [1] - Sequencia de entrega             ³
	//³                    [2] - Pedido                           ³
	//³                    [3] - Cliente                          ³
	//³                    [4] - Loja                             ³
	//³                    [5] - Data de Chegada                  ³
	//³                    [6] - Hora de Chegada                  ³
	//³                    [7] - Time Service                     ³
	//³                    [8] - Data Saida                       ³
	//³                    [9] - Hora Saida                       ³
	//³                    [10] - Peso                            ³
	//³                    [11] - Capacidade volumetrica          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aGant := {}
	For nX := 1 to Len(aCargas)
		nCor++

		If nX > 6
			nCor := 1
		EndIf

		AAdd(aGant,{{aCargas[nX][1]+"-"+aCargas[nX][2],""},{{aCargas[nX][6],aCargas[nX][7],aCargas[nX][8],aCargas[nX][9],aCargas[nX][4],aCores[nCor],'Os200Visual("DAK",'+Str(aCargas[nX][5])+',2)',1,}},CLR_GRAY,oBold})
	Next nX

	Do While lRet
		DEFINE FONT oFont NAME "Arial" SIZE 0, -10
		DEFINE MSDIALOG oDlgCar TITLE OemtoAnsi(STR0148) OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight STYLE nOR(WS_VISIBLE,WS_POPUP) //"Programacao de Entrega das Cargas"
		oDlgCar:lMaximized := .T.
		bRfshGantt := Nil

		@ 00,00 BITMAP oBmp RESNAME "FAIXASUPERIOR" SIZE 1200,50 NOBORDER PIXEL
		oBmp:Align:= CONTROL_ALIGN_TOP
		aAuxCfg := {aConfig[1],aConfig[3],aConfig[4],aConfig[5],aConfig[6],aConfig[7]}

		@ 39,01 BUTTON  OemtoAnsi(STR0152) SIZE 35,12 ACTION If(Os200CfgGnt("Teste",@oDlgCar,aConfig,@dIni,aGant),(oDlgCar:End(),lRet := .T.),Nil) OF oDlgCar PIXEL //"Opcoes"
		@ 39,38 BUTTON  OemtoAnsi(STR0153) SIZE 35,12 ACTION (lRet := .F.,oDlgCar:End()) OF oDlgCar PIXEL  //"Sair"

		oPanel  := PmsGantt(aGant,aAuxCfg,@dIni,,oDlgCar,{50,1,((nBottom-nTop))-45,((nRight-nLeft)/2)-10},{{OemtoAnsi(STR0014),30}},@nTsk)
		If  aConfig[1] != 6
			aConfig[1] := aAuxCfg[1]
		EndIf

		ACTIVATE MSDIALOG oDlgCar
	EndDo
	Eval(bFiltraBrw)

	RestArea(aAreaDAK)
	RestArea(aArea)
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Os200CfgGnt³ Autor ³ Daniel Pereira       ³ Data ³ 01-02-2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exibe uma tela com as configuracoes de visualizacao do Gantt  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Os200CfgGnt(cVersao,oDlg,aConfig,dIni,aGantt)
Local lRet      := .F.
Local aConfigBk := aClone(aConfig)
	lRet := ParamBox({{3,   OemtoAnsi(STR0156),aConfig[1],{; //"Escala de tempo"
							OemtoAnsi(STR0157),; //"Diario"
							OemtoAnsi(STR0158),; //"Semanal"
							OemtoAnsi(STR0159),; //"Mensal"
							OemtoAnsi(STR0160),; //"Mensal (Zoom 30%)"
							OemtoAnsi(STR0161),; //"Bimestral"
							OemtoAnsi(STR0162)},60,,.F.}},; //"Melhor escala"
							OemtoAnsi(STR0163),aConfig,,,.F.,120,3) //"Configuracoes"
	aConfigBk[1] := aConfig[1]
	aConfig := aClone(aConfigBk)
Return( lRet )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Os200Visual³ Autor ³ Daniel Pereira     ³ Data ³ 30/01/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualizacao da carga pelo Gantt                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico APDL                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function xOs200Visual(cAlias,nRec,nOpc)
Local aArea    := Getarea()
Local aAreaDAK := DAK->(GetArea())
	DAK->(MsGoto(nRec))

	OmsVisCg(cAlias,nRec,2)

	RestArea( aAreaDAK )
	RestArea( aArea    )
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Oms200EndOri³ Autor ³ Daniel Pereira      ³ Data ³30.01.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Retorna o endereco padrao da carga                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Cargal de origem do pedido                           ³±±
±±³          ³ExpC2 - Sequencia                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1 - Endereco padrao da carga                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Esta rotina tem como objetivo retornar o endereco padrao de  ³±±
±±³          ³uma determinada carga                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Om200EndOri(cCarga,cSeqCar)
Local aArea     := GetArea()
Local aAreaDAI  := DAI->(GetArea())
Local cFilPv    := ""
Local cEndereco := ""
Local cAliasDAI := GetNextAlias()
Local cAliasSC9 := Nil
Local nTpVlEnt  := OsVlEntCom()
	If nTpVlEnt <> 1
		BeginSql Alias cAliasDAI
			SELECT DAI.DAI_FILPV,
					DAI.DAI_COD,
					DAI.DAI_SEQCAR,
					DAI.DAI_SEQUEN
			FROM %Table:DAI% DAI
			WHERE DAI.DAI_FILIAL = %xFilial:DAI%
			AND DAI.DAI_COD = %Exp:cCarga%
			AND DAI.DAI_SEQCAR = %Exp:cSeqCar%
			AND DAI.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasDAI
			SELECT DAI.DAI_COD,
					DAI.DAI_SEQCAR,
					DAI.DAI_SEQUEN
			FROM %Table:DAI% DAI
			WHERE DAI.DAI_FILIAL = %xFilial:DAI%
			AND DAI.DAI_COD = %Exp:cCarga%
			AND DAI.DAI_SEQCAR = %Exp:cSeqCar%
			AND DAI.%NotDel%
		EndSql
	EndIf
	If (cAliasDAI)->(!Eof())
		cFilPv := IIf(nTpVlEnt<>1,(cAliasDAI)->DAI_FILPV,xFilial("SC9"))
		cAliasSC9 := GetNextAlias()
		BeginSql Alias cAliasSC9
			SELECT SC9.C9_ENDPAD
			FROM %Table:SC9% SC9
			WHERE SC9.C9_FILIAL = %Exp:OsFilial("SC9",cFilPv)%
			AND SC9.C9_CARGA = %Exp:(cAliasDAI)->DAI_COD%
			AND SC9.C9_SEQCAR = %Exp:(cAliasDAI)->DAI_SEQCAR%
			AND SC9.C9_SEQENT = %Exp:(cAliasDAI)->DAI_SEQUEN%
			AND SC9.%NotDel%
		EndSql
		If (cAliasSC9)->(!Eof())
			cEndereco := (cAliasSC9)->C9_ENDPAD
		EndIf
		(cAliasSC9)->(dbCloseArea())
	EndIf
	RestArea(aAreaDAI)
	RestArea(aArea)
Return cEndereco
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Os200SeqMn   ³ Autor ³ Daniel Pereira     ³ Data ³30/01/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Os200SeqMn(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 -> Array com os recnos da tabela DAI associados ao     ³±±
±±³          ³acols                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Altera a sequencia de carga a partir da rotina de manutencao ³±±
±±³          ³de carga                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA200                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Os200SeqMn(aRecnoDAI,cHrStart,dDtStart)
Local aArea       := GetArea()
Local aArrayCarga := {}
Local aArrayMan   := {}
Local cCodCli     := ""
Local cLoja       := ""
Local cFilPV      := ""
Local cAliasSA1   := Nil
Local cAliasSA2   := Nil
Local cAliasSC5   := Nil
Local cAliasSC9   := Nil
Local nPosSequen  := GdFieldPos( "DAI_SEQUEN" )
Local nPosRota    := GdFieldPos( "DAI_ROTEIR" )
Local nPosZona    := GdFieldPos( "DAI_PERCUR" )
Local nPosSetor   := GdFieldPos( "DAI_ROTA"   )
Local nPosPedido  := GdFieldPos( "DAI_PEDIDO" )
Local nPosLoja    := GdFieldPos( "DAI_LOJA"   )
Local nPosPeso    := GdFieldPos( "DAI_PESO"   )
Local nPosVolume  := GdFieldPos( "DAI_CAPVOL" )
Local nPosTmServ  := GdFieldPos( "DAI_TMSERV" )
Local nPosChgPrev := GdFieldPos( "DAI_CHEGAD" )
Local nPosCarga   := GdFieldPos( "DAI_COD" )
Local nPosDtCheg  := GdFieldPos( "DAI_DTCHEG" )
Local nPosDtSaid  := GdFieldPos( "DAI_DTSAID" )
Local nPosData    := GdFieldPos( "DAI_DATA" )
Local nPosHora    := GdFieldPos( "DAI_HORA" )
Local nLoop       := 0
Local nTpVlEnt    := OsVlEntCom()
	// Constroi o aArraycarga
	AAdd( aArrayCarga, Array(22) )

	aArrayCarga[1,CARGA_ENABLE] := .T.
	aArrayCarga[1,CARGA_COD]    := M->DAK_COD
	aArrayCarga[1,CARGA_DESC]   := OemtoAnsi(STR0040) + M->DAK_COD //"CARGA "
	aArrayCarga[1,CARGA_PESO]   := M->DAK_PESO
	aArrayCarga[1,CARGA_VALOR]  := M->DAK_VALOR
	aArrayCarga[1,CARGA_VOLUM]  := M->DAK_CAPVOL
	aArrayCarga[1,CARGA_PTOENT] := M->DAK_PTOENT
	aArrayCarga[1,CARGA_VEIC]   := M->DAK_CAMINH
	aArrayCarga[1,CARGA_MOTOR]  := M->DAK_MOTORI
	aArrayCarga[1,CARGA_AJUD1]  := M->DAK_AJUDA1
	aArrayCarga[1,CARGA_AJUD2]  := M->DAK_AJUDA2
	aArrayCarga[1,CARGA_AJUD3]  := M->DAK_AJUDA3
	// Pesquisa o pedido de vendas
	For nLoop := 1 to Len( aCols )
		// Considera apenas os nao deletados e que nao tiveram o numero da carga alterado
		If !aCols[ nLoop, Len( aHeader ) + 1 ] .And. aCols[ nLoop, nPosCarga ] == M->DAK_COD
			// Posiciona no DAI referente ao ACOLS
			DAI->( DbGoTo( aRecnoDAI[ nLoop ] ) )

			AAdd( aArrayMan, Array( 26 ) )

			nTam := Len( aArrayMan )
			// Obtem os dados preferencialmente do ACOLS
			aArrayMan[ nTam, 1 ] := If( Empty( nPosSequen ), DAI->DAI_SEQUEN, aCols[ nLoop,nPosSequen ] )
			aArrayMan[ nTam, 2 ] := If( Empty( nPosRota   ), DAI->DAI_ROTEIR, aCols[ nLoop,nPosRota   ] )
			aArrayMan[ nTam, 3 ] := If( Empty( nPosZona   ), DAI->DAI_PERCUR, aCols[ nLoop,nPosZona   ] )
			aArrayMan[ nTam, 4 ] := If( Empty( nPosSetor  ), DAI->DAI_ROTA  , aCols[ nLoop,nPosSetor  ] )
			aArrayMan[ nTam, 5 ] := If( Empty( nPosPedido ), DAI->DAI_PEDIDO, aCols[ nLoop,nPosPedido ] )

			cFilPv := IIf(nTpVlEnt<>1,DAI->DAI_FILPV,xFilial("SC5"))
			// Pesquisa o pedido de vendas
			cAliasSC5 := GetNextAlias()
			BeginSql Alias cAliasSC5
				SELECT SC5.C5_CLIENT,
						SC5.C5_LOJAENT,
						SC5.C5_CLIENTE,
						SC5.C5_LOJACLI,
						SC5.C5_TIPO
				FROM %Table:SC5% SC5
				WHERE SC5.C5_FILIAL = %Exp:cFilPv%
				AND SC5.C5_NUM = %Exp:aCols[nLoop,nPosPedido]%
				AND SC5.%NotDel%
			EndSql
			If (cAliasSC5)->(!Eof())
				// Verifica se e cliente ou cliente de entrega
				If !Empty( (cAliasSC5)->C5_CLIENT ) .And. !Empty( (cAliasSC5)->C5_LOJAENT )
					cCodCli := (cAliasSC5)->C5_CLIENT
					cLoja   := (cAliasSC5)->C5_LOJAENT
				Else
					cCodCli := (cAliasSC5)->C5_CLIENTE
					cLoja   := (cAliasSC5)->C5_LOJACLI
				EndIf
				// Verifica se e cliente ou fornecedor
				If (cAliasSC5)->C5_TIPO $ "DB"
					cAliasSA2 := GetNextAlias()
					BeginSql Alias cAliasSA2
						SELECT SA2.A2_COD,
								SA2.A2_LOJA,
								SA2.A2_NOME,
								SA2.A2_BAIRRO,
								SA2.A2_MUN,
								SA2.A2_EST
						FROM %Table:SA2% SA2
						WHERE SA2.A2_FILIAL = %xFilial:SA2%
						AND SA2.A2_COD = %Exp:cCodCli%
						AND SA2.A2_LOJA = %Exp:cLoja%
						AND SA2.%NotDel%
					EndSql
					If (cAliasSA2)->(!Eof())
						aArrayMan[ nTam, 6  ] := (cAliasSA2)->A2_COD
						aArrayMan[ nTam, 7  ] := (cAliasSA2)->A2_LOJA
						aArrayMan[ nTam, 8  ] := (cAliasSA2)->A2_NOME
						aArrayMan[ nTam, 9  ] := (cAliasSA2)->A2_BAIRRO
						aArrayMan[ nTam, 10 ] := (cAliasSA2)->A2_MUN
						aArrayMan[ nTam, 11 ] := (cAliasSA2)->A2_EST
					EndIf
					(cAliasSA2)->(dbCloseArea())
				Else
					cAliasSA1 := GetNextAlias()
					BeginSql Alias cAliasSA1
						SELECT SA1.A1_COD,
								SA1.A1_LOJA,
								SA1.A1_NOME,
								SA1.A1_BAIRRO,
								SA1.A1_MUN,
								SA1.A1_EST
						FROM %Table:SA1% SA1
						WHERE SA1.A1_FILIAL = %xFilial:SA1%
						AND SA1.A1_COD = %Exp:cCodCli%
						AND SA1.A1_LOJA = %Exp:cLoja%
						AND SA1.%NotDel%
					EndSql
					If (cAliasSA1)->(!Eof())
						aArrayMan[ nTam, 6  ] := (cAliasSA1)->A1_COD
						aArrayMan[ nTam, 7  ] := (cAliasSA1)->A1_LOJA
						aArrayMan[ nTam, 8  ] := (cAliasSA1)->A1_NOME
						aArrayMan[ nTam, 9  ] := (cAliasSA1)->A1_BAIRRO
						aArrayMan[ nTam, 10 ] := (cAliasSA1)->A1_MUN
						aArrayMan[ nTam, 11 ] := (cAliasSA1)->A1_EST
					EndIf
					(cAliasSA1)->(dbCloseArea())
				EndIf
			EndIf
			(cAliasSC5)->(dbCloseArea())
			// Pesquisa a liberacao do pedido para localizar as filiais de origem
			cAliasSC9 := GetNextAlias()
			BeginSql Alias cAliasSC9
				SELECT SC9.C9_FILIAL
				FROM %Table:SC9% SC9
				WHERE SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_CARGA = %Exp:DAI->DAI_COD%
				AND SC9.C9_SEQCAR = %Exp:DAI->DAI_SEQCAR%
				AND SC9.C9_SEQENT = %Exp:DAI->DAI_SEQUEN%
				AND SC9.%NotDel%
			EndSql
			If (cAliasSC9)->(!Eof())
				aArrayMan[ nTam, 12 ] := (cAliasSC9)->C9_FILIAL
				aArrayMan[ nTam, 13 ] := OsFilial("SA1",(cAliasSC9)->C9_FILIAL)
			EndIf
			(cAliasSC9)->(dbCloseArea())

			aArrayMan[ nTam, 14 ] := If( Empty( nPosPeso    ), DAI->DAI_PESO  , aCols[ nLoop,nPosPeso   ] )
			aArrayMan[ nTam, 15 ] := If( Empty( nPosVolume  ), DAI->DAI_CAPVOL, aCols[ nLoop,nPosVolume ] )
			aArrayMan[ nTam, 16 ] := If( Empty( nPosChgPrev ), DAI->DAI_CHEGAD, aCols[ nLoop,nPosChgPrev] )
			aArrayMan[ nTam, 17 ] := If( Empty( nPosTmServ  ), DAI->DAI_TMSERV, aCols[ nLoop,nPosTmServ ] )
			aArrayMan[ nTam, 19 ] := If( Empty( nPosDtCheg  ), DAI->DAI_DTCHEG, aCols[ nLoop,nPosDtCheg ] )
			aArrayMan[ nTam, 20 ] := If( Empty( nPosDtSaid  ), DAI->DAI_DTSAID, aCols[ nLoop,nPosDtSaid ] )
		EndIf
	Next nLoop
	// Dispara a manipulacao da sequencia de entrega
	Os200VisCg(@aArrayCarga,@aArrayMan,@cHrStart,@dDtStart)
	// Aplica as alteracoes ao aCols
	For nLoop := 1 to Len( aArrayMan )
		If !Empty( nLinha := AScan( aCols, { |x| x[nPosPedido] == aArrayMan[ nLoop, 5 ] .And. ;
			x[nPosLoja] == aArrayMan[ nLoop, 7 ] } ) )

			aCols[ nLinha, nPosSequen ] := aArrayMan[nLoop,1 ]
			aCols[ nLinha, nPosTmServ ] := aArrayMan[nLoop,17]
			aCols[ nLinha, nPosChgPrev] := aArrayMan[nLoop,16]
			If !Empty( nPosDtCheg )
				aCols[ nLinha, nPosDtCheg ] := aArrayMan[nLoop,19]
			EndIf
			If !Empty( nPosDtSaid )
				aCols[ nLinha, nPosDtSaid ] := aArrayMan[nLoop,20]
			EndIf
			If !Empty( nPosData )
				aCols[ nLinha, nPosData   ] := dDtStart
			EndIf
			If !Empty( nPosHora )
				aCols[ nLinha, nPosHora   ] := cHrStart
			EndIf
		EndIf
	Next nLoop
	// Aplica as alteracoes no cabecalho
	M->DAK_DATA   := dDtStart
	M->DAK_HORA   := cHrStart
	M->DAK_HRSTAR := cHrStart
	RestArea(aArea)
Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Os200TOk    ³ Autor ³ Daniel Pereira       Data ³27/01/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Os200TOk()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao na manutenção da carga.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA200                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Os200TOk()
Local lRet   := .T.
Local lRetPE := .T.
Local nAnt   := n
Local nX     := 0
	//verifica se tentativa de excluir o pedido da carga, com servico de WMS jah executado
	For nX:= 1 to Len(aCols)
		n:= nX // atualizando a variavel n da getdados.
		lRet := Os200DCF()
		If ! lRet
			Exit
		EndIf
	Next nX
	n:= nAnt
	//--PE na validação da manutenção da carga.
	If lRet .And. ExistBlock("OS200TOK")
		lRetPE := ExecBlock("OS200TOK",.F.,.F.)
		lRet   := If(ValType(lRetPE)=="L", lRetPE, lRet)
	EndIf
Return( lRet )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Os200LOk    ³ Autor ³ Daniel Pereira  ³ Data ³29/01/2021    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da linha na manutenção da carga.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMSA200                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Os200LOk()
Local lRet := .T.
	//verifica se tentativa de excluir o pedido da carga, com servico de WMS jah executado
	lRet := Os200DCF()
Return( lRet )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Os200DCF    ³ Autor ³ Daniel Pereira     ³ Data ³31/01/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ So permite retirar o item da carga se NAO houver o.s.wms    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function Os200DCF()
Local lRet := .T.
	//-- So permite retirar o item da carga se NAO houver ordem de servico do WMS executada
	If GDDeleted( n )
		lRet := WmsAvalDAK(GdFieldGet('DAI_COD',n),GdFieldGet('DAI_SEQCAR',n),GdFieldGet('DAI_SEQUEN',n),GdFieldGet('DAI_PEDIDO',n))
	EndIf
Return( lRet )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OsA200Refr³ Autor ³Daniel Pereira         ³ Data ³02.02.2021  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de interface da Montagem de Carga                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do Arquivo                                       ³±±
±±³          ³ExpN2: Numero do Registro                                     ³±±
±±³          ³ExpN3: Opcao do aRotina                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OsA200Refr(aCampos,aArrayCarga,aArrayRota,aArrayZona,aArraySetor,aArrayMod,aArrayTipo,aObjetos,aArrayMan,aObjPed,cDakTransp,lFiltro)
Local oProcess   := Nil
Local oEnable    := LoadBitmap( GetResources(), "ENABLE" )
Local oDisable   := LoadBitmap( GetResources(), "DISABLE" )
Local oNoMarked  := LoadBitmap( GetResources(), "LBNO" )
Local oMarked    := LoadBitmap( GetResources(), "LBOK" )
Local nX         := 0
Local lHasOpen   := .F.
Local lOmsRefr   := SuperGetMv("MV_OMSREFR",.F.,.F.)
Local cCarga     := ""
Local aMarcados  := {}
Local cPictVal   := "99999999." + Replicate("9",TamSx3("DAK_VALOR")[2])
Local cPictVol   := "99999999." + Replicate("9",TamSx3("DAK_CAPVOL")[2])
Local cPictPeso  := "99999999." + Replicate("9",TamSx3("DAK_PESO")[2])
Local cPictQtde  := "99999999." + Replicate("9",TamSx3("C9_QTDLIB")[2])
Local cMarca     := GetMark()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega perguntas do OMSA200 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("OMS200",.F.)
	// Traz janelas de perguntas e filtro para a montagem
	If lFiltro .And. !OmsFilTipo(@oMarked,@oNoMarked,aArrayMod,aArrayTipo,lOmsRefr)
		Return .T.
	EndIf

	cDakTransp := Criavar("A4_COD",.F.)

	For nX := 1 to Len(aArrayCarga)
		If aArrayCarga[nX,CARGA_ENABLE]
			lHasOpen := .T.
		EndIf
	Next nX

	If !lHasOpen
		OmsAbreCarga(@oEnable,@oDisable,@aArrayCarga)
	EndIf

	For nX := 1 to Len(aArrayCarga)
		If aArrayCarga[nX,CARGA_ENABLE]
			cCarga := aArrayCarga[nX,CARGA_COD]
		EndIf
	Next nX

	// Armazena os registros marcados em array
	If !lOmsRefr
		MarkRegBkp(aMarcados)
	EndIf

	aArrayCarga := {}
	aArrayRota  := {}
	aArrayZona  := {}
	aArraySetor := {}
	aArrayMan   := {}
	aArrayCli   := {}

	For nX := 1 To Len(aObjetos)
		aObjetos[nX]:nAt := 1
	Next nX

	// Filtra pedidos e monta o mapa de cargas
	If IsBlind()
		lEnd := xOmsBuscaPed(cCarga,aArrayCarga,aArrayRota,aArrayZona,aArraySetor,aArrayMod,aArrayTipo,oProcess,cMarca)
	Else
		oProcess := MsNewProcess():New({ |lEnd| xOmsBuscaPed(cCarga,;
															aArrayCarga,;
															aArrayRota,;
															aArrayZona,;
															aArraySetor,;
															aArrayMod,;
															aArrayTipo,;
															oProcess,;
															cMarca)},"","",.F.)
		oProcess:Activate()
	EndIf
	// Executa a regra para marcação dos registros que já estavam selecionados
	If !lOmsRefr
		MarkTabPed(aMarcados,aArrayCarga,aArrayMan,aArrayRota,aArrayZona,aArraySetor)
	EndIf
	// Atualiza os objetos
	aObjetos[1]:SetArray(aArrayCarga)
	aObjetos[1]:bLine := { || { Iif(aArrayCarga[oCargas:nAT,CARGA_ENABLE],oEnable,oDisable),;
									aArrayCarga[oCargas:nAT,CARGA_COD],;
									aArrayCarga[oCargas:nAT,CARGA_DESC],;
									Transform(aArrayCarga[oCargas:nAT,CARGA_PESO  ],cPictPeso),;
									Transform(aArrayCarga[oCargas:nAT,CARGA_VALOR ],cPictVal ),;
									Transform(aArrayCarga[oCargas:nAT,CARGA_VOLUM ],cPictVol ),;
									Transform(aArrayCarga[oCargas:nAT,CARGA_QTDLIB],cPictVol ),;
									aArrayCarga[oCargas:nAT,CARGA_PTOENT],;
									aArrayCarga[oCargas:nAT,CARGA_TRANSP],;
									aArrayCarga[oCargas:nAT,CARGA_VEIC],;
									aArrayCarga[oCargas:nAT,CARGA_VEI2],;
									aArrayCarga[oCargas:nAT,CARGA_VEI3],;
									aArrayCarga[oCargas:nAT,CARGA_MOTOR],;
									aArrayCarga[oCargas:nAT,CARGA_AJUD1],;
									aArrayCarga[oCargas:nAT,CARGA_AJUD2],;
									aArrayCarga[oCargas:nAT,CARGA_AJUD3],;
									Transform(aArrayCarga[oCargas:nAT,CARGA_PESCIF],cPictPeso),;
									Transform(aArrayCarga[oCargas:nAT,CARGA_QTDCIF],cPictVal ),;
									Transform(aArrayCarga[oCargas:nAT,CARGA_VOLCIF],cPictVol ),;
									Transform(aArrayCarga[oCargas:nAT,CARGA_VALCIF],cPictQtde),;
									Transform(aArrayCarga[oCargas:nAT,CARGA_PESFOB],cPictPeso),;
									Transform(aArrayCarga[oCargas:nAT,CARGA_QTDFOB],cPictVal ),;
									Transform(aArrayCarga[oCargas:nAT,CARGA_VOLFOB],cPictVol ),;
									Transform(aArrayCarga[oCargas:nAT,CARGA_VALFOB],cPictQtde),;
								  aArrayCarga[oCargas:nAT,CARGA_TPOP],;
								  aArrayCarga[oCargas:nAT,CARGA_CLFR]}}
	// Ponto de entrada para adicionar campos na opcao Sequencia de Entrega
	If ExistBlock("OM200AD2")
		aRetCarga := ExecBlock("OM200AD2",.F.,.F.,{aObjetos[1], aObjetos[1]:aArray, aObjetos[1]:aHeaders, aObjetos[1]:bLine, oEnable, oDisable})
		If ValType(aRetCarga[1]) == "A" .And. ValType(aRetCarga[2]) == "A" .And. ValType(aRetCarga[3]) == "B"
			aArrayCarga       := aRetCarga[1]
			aObjetos[1]:bLine := aRetCarga[3]
		EndIf
	EndIf

	aObjetos[1]:nAt := 1
	aObjetos[1]:Refresh()

	aObjetos[2]:SetArray(aArrayRota)
	aObjetos[2]:bLine:={ ||{Iif(aArrayRota[oRotas:nAT,1],oEnable,oDisable),;
							Iif(aArrayRota[oRotas:nAT,2],oMarked,oNoMarked),;
							aArrayRota[oRotas:nAT,3],;
							aArrayRota[oRotas:nAT,4],;
							aArrayRota[oRotas:nAt,5]}}
	aObjetos[2]:nAt := 1
	aObjetos[2]:Refresh()

	aObjetos[3]:SetArray(aArrayZona)
	aObjetos[3]:bLine:={ ||{Iif(aArrayZona[oZonas:nAT,1],oEnable,oDisable),;
							Iif(aArrayZona[oZonas:nAT,2],oMarked,oNoMarked),;
							aArrayZona[oZonas:nAT,3],;
							aArrayZona[oZonas:nAT,4],;
							aArrayZona[oZonas:nAT,5],;
							aArrayZona[oZonas:nAT,6]}}
	aObjetos[3]:nAt := 1
	aObjetos[3]:Refresh()

	aObjetos[4]:SetArray(aArraySetor)
	aObjetos[4]:bLine:={ ||{IIf(aArraySetor[oSetores:nAT,1],oEnable,oDisable),;
							Iif(aArraySetor[oSetores:nAT,2],oMarked,oNoMarked),;
							aArraySetor[oSetores:nAT,3],;
							aArraySetor[oSetores:nAT,4],;
							aArraySetor[oSetores:nAT,5],;
							aArraySetor[oSetores:nAT,6],;
							aArraySetor[oSetores:nAT,7]}}
	aObjetos[4]:nAt := 1
	aObjetos[4]:Refresh()

	aObjPed[1]:lVisibleControl := (mv_par06 == 2 .or. MV_PAR06 == 3)
	aObjPed[1]:Refresh()

	TRBPED->(DbGoTop())
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} MarkRegBkp
Armazena registros marcados na consulta anterior ao Refresh

@author  Daniel Pereira 
@version P12
@since   29.01.2021
/*/
//----------------------------------------------------------
Static Function MarkRegBkp(aMarcados)
Local aAreaAnt   := GetArea()
Local cAliasQry  := GetNextAlias()
Local coTmpTab   := "%"+__oTmpTab:GetRealName()+"%"
	BeginSql Alias cAliasQry
		SELECT PED_FILORI,
				PED_PEDIDO,
				PED_ITEM,
				PED_SEQLIB,
				PED_ROTA,
				PED_ZONA,
				PED_SETOR,
				PED_MARCA
		FROM %Exp:coTmpTab%
		WHERE PED_MARCA <> '  '
	EndSql
	Do While !(cAliasQry)->(Eof())
		aAdd(aMarcados,{;
						(cAliasQry)->PED_FILORI,;
						(cAliasQry)->PED_PEDIDO,;
						(cAliasQry)->PED_ITEM,;
						(cAliasQry)->PED_SEQLIB,;
						(cAliasQry)->PED_ROTA,;
						(cAliasQry)->PED_ZONA,;
						(cAliasQry)->PED_SETOR,;
						(cAliasQry)->PED_MARCA})
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return
//----------------------------------------------------------
/*/{Protheus.doc} MarkTabPed
Marca os registros da tabela temporária TRBPED no Refresh
de tela quando o parâmetro MV_OMSREFR for falso

@author  Daniel Pereira 
@version P12
@since   26/04/2018
/*/
//----------------------------------------------------------
Static Function MarkTabPed(aMarcados,aArrayCarga,aArrayMan,aArrayRota,aArrayZona,aArraySetor)
Local nI        := 0
Local nPosMan   := 0
Local nPosCarga := Len(aArrayCarga)
Local lDaiRedesp  := DAI->( ColumnPos( "DAI_REDESP" ) ) > 0

	TRBPED->(DbSetOrder(1))
	For nI := 1 To Len(aMarcados)
		If TRBPED->(DbSeek(aMarcados[nI,1]+aMarcados[nI,2]+Iif((MV_PAR06 == 2 .or. MV_PAR06 == 3),aMarcados[nI,3]+aMarcados[nI,4],"")))
			// Atribui informações ao novo registro
			RecLock("TRBPED",.F.)
			TRBPED->PED_MARCA := aMarcados[nI,8]
			TRBPED->PED_ROTA  := aMarcados[nI,5]
			TRBPED->PED_ZONA  := aMarcados[nI,6]
			TRBPED->PED_SETOR := aMarcados[nI,7]
			TRBPED->(MsUnlock())
			// Procura e marca Rota
			If (nPos := aScan(aArrayRota,{|x| x[3] == aMarcados[nI,5] .And. x[1] .And. !x[2]}))>0
				aArrayRota[nPos,2] := .T.
			EndIf
			// Procura e marca Zona
			If (nPos := aScan(aArrayZona,{|x| x[3]+x[4] == aMarcados[nI,5]+aMarcados[nI,6] .And. x[1] .And. !x[2]}))>0
				aArrayZona[nPos,2] := .T.
			EndIf
			// Procura e marca Setor
			If (nPos := aScan(aArraySetor,{|x| x[3]+x[4]+x[5] == aMarcados[nI,5]+aMarcados[nI,6]+aMarcados[nI,7] .And. x[1] .And. !x[2]}))>0
				aArraySetor[nPos,2] := .T.
			EndIf
			// Adiciona os registros no array de pedidos
			If (nPosMan := Ascan(aArrayMan,{|x| x[5]+x[6]+x[7]+x[12] == TRBPED->PED_PEDIDO+TRBPED->PED_CODCLI+TRBPED->PED_LOJA+TRBPED->PED_FILORI})) <= 0
				AAdd(aArrayMan,{TRBPED->PED_SEQROT,;
								TRBPED->PED_ROTA,;
								TRBPED->PED_ZONA,;
								TRBPED->PED_SETOR,;
								TRBPED->PED_PEDIDO,;
								TRBPED->PED_CODCLI,;
								TRBPED->PED_LOJA,;
								TRBPED->PED_NOME,;
								TRBPED->PED_BAIRRO,;
								TRBPED->PED_MUN,;
								TRBPED->PED_EST,;
								TRBPED->PED_FILORI,;
								TRBPED->PED_FILCLI,;
								TRBPED->PED_PESO,;
								TRBPED->PED_VOLUM,;
								,,,,,,,,,;
								TRBPED->PED_VALOR,;
								TRBPED->PED_QTDLIB,;
								TRBPED->PED_ENDCLI,;
								Iif(lDaiRedesp,TRBPED->PED_REDESP,""),;
								Iif(lDaiRedesp,TRBPED->PED_REDNOM,"")})
			Else
				aArrayMan[nPosMan][14] += TRBPED->PED_PESO
				aArrayMan[nPosMan][15] += TRBPED->PED_VOLUM
				aArrayMan[nPosMan][25] += TRBPED->PED_VALOR
				aArrayMan[nPosMan][26] += TRBPED->PED_QTDLIB
			EndIf
			// Soma os valores no array de cargas
			aArrayCarga[nPosCarga,CARGA_PESO  ] := aArrayCarga[nPosCarga,CARGA_PESO  ] + TRBPED->PED_PESO
			aArrayCarga[nPosCarga,CARGA_VOLUM ] := aArrayCarga[nPosCarga,CARGA_VOLUM ] + TRBPED->PED_VOLUM
			aArrayCarga[nPosCarga,CARGA_VALOR ] := aArrayCarga[nPosCarga,CARGA_VALOR ] + TRBPED->PED_VALOR
			aArrayCarga[nPosCarga,CARGA_QTDLIB] := aArrayCarga[nPosCarga,CARGA_QTDLIB] + TRBPED->PED_QTDLIB
		EndIf
	Next

	If SuperGetMV("MV_ALOCPER",.F.,.F.) == "S"
		TRBPED->(DbSetOrder(5))
	Else
		TRBPED->(DbSetOrder(3))
	EndIf
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Os200DivSC9³ Autor ³Daniel Pereira        ³ Data ³ 30.01.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina quebra da quantidade do SC9.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias com os itens do pedido de venda                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Os200DivSC9(cAliasTrb,aArrayMan,cMarca,nRecSC9,oObjMrk)
Local aArea      := GetArea()
Local aAreaSC5   := SC5->(GetArea())
Local aAreaSC6   := SC6->(GetArea())
Local aAreaSC9   := SC9->(GetArea())
Local aAreaSA1   := SA1->(GetArea())
Local aAreaSA2   := SA2->(GetArea())
Local aAreaSB1   := SB1->(GetArea())
Local aAreaTRB   := (cAliasTRB)->(GetArea())
Local aCopySC9   := {}
Local aCopySDC   := {}
Local nX         := 0
Local nY         := 0
Local nQtdNew    := 0
Local nDif       := 0
Local nOpcA      := 0
Local nRetPE     := 0
Local nPesoProd  := 0
Local nPesoNew   := 0
Local nVolNew    := 0
Local nBaixa     := 0
Local nQuant     := 0
Local cPedido    := ""
Local cItem      := ""
Local cCarga     := ""
Local cOMSFilial := ""
Local cSequen    := ""
Local cSeqNew    := ""
Local cProduto   := ""
Local cProdDesc  := ""
Local cBlWMS     := ""
Local cAliasSDC  := Nil
Local cAliasQry  := Nil
Local lSC9       := .F.
Local oDlg
Local lOMS200DIV := ExistBlock("OMS200DIV")
Local lOM200SC9  := ExistBlock("OM200SC9")
Local lProcessa  := .T.
Local lEstLib    := SuperGetMV("MV_OMSESTP",.F.,.T.) .And. OmsPedCPL(SC9->C9_FILIAL,SC9->C9_PEDIDO)// Indica se estorna liberacao do pedido de vendas de uma carga ao dividir um item. Onde .T. (default) efetua o estorno. Quando integrado com o CPL o estorno da liberação não é permitida.
Local lRet       := .T.
Local nNewRecno  := 0

Default cAliasTRB := "SC9"
Default cMarca    := ""
Default nRecSC9   := 0
	//------------------------------
	// Pesquisa o registro no SC9
	//------------------------------
	lSC9 := cAliasTRB=="SC9"
	If lSC9 .Or. (cAliasTRB)->(ColumnPos("PED_CODPRO"))>0
		If lSC9
			If nRecSC9 > 0
				SC9->(MsGoto(nRecSC9))
			EndIf
			cPedido    := SC9->C9_PEDIDO
			cItem      := SC9->C9_ITEM
			cOMSFilial := SC9->C9_FILIAL
			cSequen    := SC9->C9_SEQUEN
			cProduto   := SC9->C9_PRODUTO
			cBlWMS     := SC9->C9_BLWMS
		Else
			cPedido    := (cAliasTRB)->PED_PEDIDO
			cItem      := (cAliasTRB)->PED_ITEM
			cCarga     := (cAliasTRB)->PED_CARGA
			cOMSFilial := (cAliasTRB)->PED_FILORI
			cSequen    := (cAliasTRB)->PED_SEQLIB
			cProduto   := (cAliasTRB)->PED_CODPRO
		EndIf
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SC9.R_E_C_N_O_ RECNOSC9,
					SB1.R_E_C_N_O_ RECNOSB1,
					SC5.R_E_C_N_O_ RECNOSC5,
					SC6.R_E_C_N_O_ RECNOSC6
			FROM %Table:SC9% SC9
			INNER JOIN %Table:SB1% SB1
			ON SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = SC9.C9_PRODUTO
			AND SB1.%NotDel%
			INNER JOIN %Table:SC5% SC5
			ON SC5.C5_FILIAL = %Exp:OsFilial("SC5",cOMSFilial)%
			AND SC5.C5_NUM = SC9.C9_PEDIDO
			AND SC5.%NotDel%
			INNER JOIN %Table:SC6% SC6
			ON SC6.C6_FILIAL = %Exp:OsFilial("SC6",cOMSFilial)%
			AND SC6.C6_NUM = SC9.C9_PEDIDO
			AND SC6.C6_ITEM = SC9.C9_ITEM
			AND SC6.%NotDel%
			WHERE SC9.C9_FILIAL = %Exp:OsFilial("SC9",cOMSFilial)%
			AND SC9.C9_PEDIDO = %Exp:cPedido%
			AND SC9.C9_ITEM = %Exp:cItem%
			AND SC9.C9_SEQUEN = %Exp:cSequen%
			AND SC9.C9_PRODUTO = %Exp:cProduto%
			AND SC9.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			SC9->(dbGoTo((cAliasQry)->RECNOSC9))
			If SoftLock("SC9")

				SB1->(dbGoTo((cAliasQry)->RECNOSB1))
				SC5->(dbGoTo((cAliasQry)->RECNOSC5))
				SC6->(dbGoTo((cAliasQry)->RECNOSC6))

				If SC5->C5_TIPO $ "BD"
					SA2->(DbSetOrder(1))
					SA2->(MsSeek(OsFilial("SA2",cOMSFilial)+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
				Else
					SA1->(DbSetOrder(1))
					SA1->(MsSeek(OsFilial("SA1",cOMSFilial)+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
				EndIf

				If !lSC9
					nQtdNew := SC9->C9_QTDLIB
					nVolNew := (cAliasTRB)->PED_VOLUM
					nPesoNew:= (cAliasTRB)->PED_PESO
				EndIf
				// Ponto de Entrada que permite sugerir quantidade para quebra
				If lOMS200DIV
					nRetPE := ExecBlock("OMS200DIV",.F.,.F.)
					If  ValType(nRetPE) == "N"
						nQtdNew := nRetPE
					EndIf
				EndIf
				//------------------------------------
				// Montagem da tela para exibicao
				//------------------------------------
				DEFINE MSDIALOG oDlg FROM  158,001 TO 450,600 TITLE STR0211 PIXEL //"Divisão dos itens de pedido de venda liberado"
				@ 005,011 TO 045,295 LABEL "" OF oDlg  PIXEL
				@ 048,144 TO 144,295 LABEL "" OF oDlg  PIXEL
				@ 048,011 TO 087,138 LABEL "" OF oDlg  PIXEL

				@ 012,015 SAY RetTitle("C9_PEDIDO")     SIZE 23,7 OF oDlg PIXEL
				@ 012,044 SAY SC9->C9_PEDIDO            SIZE 26,7 OF oDlg PIXEL
				@ 012,149 SAY RetTitle("C9_ITEM")       SIZE 23,7 OF oDlg PIXEL
				@ 012,190 SAY SC9->C9_ITEM              SIZE 26,7 OF oDlg PIXEL
				//--
				@ 023,015 SAY RetTitle("C5_CLIENTE")    SIZE 23,7 OF oDlg PIXEL
				@ 023,044 SAY IIf(SC5->C5_TIPO$"BD",Substr(SA2->A2_NOME,1,35),Substr(SA1->A1_NOME,1,35))    SIZE 114,7 OF oDlg PIXEL
				//--
				cProdDesc := Substr(AllTrim(SB1->B1_COD)+" - "+SB1->B1_DESC,1,60)
				@ 034,015 SAY RetTitle("C6_PRODUTO")    SIZE 25,7 OF oDlg PIXEL
				@ 034,044 SAY cProdDesc                 SIZE 90,7 OF oDlg PIXEL
				@ 034,149 SAY RetTitle("C6_LOCAL")      SIZE 27,7 OF oDlg PIXEL
				@ 034,190 SAY SC9->C9_LOCAL             SIZE 15,7 OF oDlg PIXEL
				//--
				@ 056,016 SAY RetTitle("C6_LOTECTL")    SIZE 38,7 OF oDlg PIXEL
				@ 056,072 SAY SC9->C9_LOTECTL           SIZE 27,7 OF oDlg PIXEL
				//--
				@ 067,016 SAY RetTitle("C6_NUMLOTE")    SIZE 37,7 OF oDlg PIXEL
				@ 067,072 SAY SC9->C9_NUMLOTE           SIZE 23,7 OF oDlg PIXEL
				//--
				@ 056,151 SAY RetTitle("C9_QTDLIB")     SIZE 53,7 OF oDlg PIXEL
				@ 056,203 GET oGet3 VAR SC9->C9_QTDLIB  PICTURE PesqPictQt("C6_QTDVEN",14) SIZE 53,7 OF oDlg PIXEL
				oGet3:lReadOnly := .T.
				@ 067,151 SAY OemtoAnsi(STR0252)        SIZE 46,7 OF oDlg PIXEL //"Qtd.p/Quebra"
				@ 067,203 MSGET nQtdNew                 PICTURE PesqPictQt("C9_QTDLIB",14) Valid nQtdNew > 0 .And. nQtdNew < SC9->C9_QTDLIB .And. Os200VlDiv(nQtdNew,@nPesoNew,@nVolNew)SIZE 53,7 OF oDlg PIXEL
				@ 078,151 SAY OemtoAnsi(STR0034)        SIZE 53,7 OF oDlg PIXEL //"Volume"
				@ 078,203 MSGET oGet1 VAR nVolNew       PICTURE "99999999."+Replicate("9",TamSx3("DAK_CAPVOL")[2]) SIZE 53,7 OF oDlg PIXEL
				oGet1:lReadOnly := .T.
				@ 089,151 SAY OemtoAnsi(STR0033)        SIZE 53,7 OF oDlg PIXEL //"Peso"
				@ 089,203 MSGET oGet2 VAR nPesoNew      PICTURE "99999999."+Replicate("9",TamSx3("DAK_PESO")[2])   SIZE 53,7 OF oDlg PIXEL
				oGet2:lReadOnly := .T.
				DEFINE SBUTTON FROM 128,230 TYPE 1 ACTION (If(nQtdNew>0,Eval({||nOpca := 1,oDlg:End()}),Eval({||nOpca := 2,oDlg:End()}))) ENABLE OF oDlg
				DEFINE SBUTTON FROM 128,263 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

				ACTIVATE MSDIALOG oDlg CENTERED
				//---------------------------------------------------------------
				// Processamento da divisao do item de pedido de venda liberado
				//---------------------------------------------------------------
				If nOpcA == 1 .And. nQtdNew <> SC9->C9_QTDLIB
					//Validação para verificar se os serviços no WMS já estão em andamento
					lProcessa := WmsAvalDAK(/*cCarga*/,/*cSeqCar*/,/*cSeqEnt*/,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,1,(lEstLib .And. lSC9))
					If lProcessa
						Begin Transaction
							nRecSc9 := SC9->(Recno())
							For nX := 1 To SC9->(FCount())
								Aadd(aCopySC9, SC9->(FieldGet(nX)))
							Next nX
							//-- Inclui uma nova Seq. no SC9 com DIFERENCA
							nDif := SC9->C9_QTDLIB - nQtdNew
							If nQtdNew > 0 .And. Len(aCopySC9) > 0
								//-- registro do SC9 com DIFERENCA da quantidade
								RecLock('SC9',.F.)
									Replace C9_QTDLIB  With nDif
									Replace C9_QTDLIB2 With ConvUM(SC9->C9_PRODUTO, nDif, 0, 2)
								SC9->(MsUnlock())
								If lOM200SC9
									ExecBlock("OM200SC9",.F.,.F.)
								EndIf
								//-- Verifica a Sequencia de Liberacao do SC9
								cQrSC9 := "MANEXTSC9"
								BeginSql Alias cQrSC9
									SELECT MAX(C9_SEQUEN) SEQUEN
									FROM %Table:SC9% SC9
									WHERE SC9.C9_FILIAL = %xFilial:SC9%
									AND SC9.C9_PEDIDO = %Exp:SC9->C9_PEDIDO%
									AND SC9.C9_ITEM  = %Exp:SC9->C9_ITEM%
									AND SC9.%NotDel%
								EndSql
								If (cQrSC9)->(!Eof())
									cSeqNew := (cQrSC9)->SEQUEN
								EndIf
								(cQrSC9)->(dbCloseArea())
								//-- Novo registro do SC9 com nova quantidade e sequencia
								cSeqNew := Soma1(cSeqNew,Len(SC9->C9_SEQUEN))
								dbSelectArea("SC9")
								RecLock("SC9", .T.)
								For nX := 1 To Len(aCopySC9)
									FieldPut(nX, aCopySC9[nX])
								Next nX
								Replace C9_SEQUEN  With cSeqNew
								Replace C9_QTDLIB  With nQtdNew
								Replace C9_QTDLIB2 With ConvUM(SC9->C9_PRODUTO, nQtdNew, 0, 2)
								SC9->(MsUnlock())

								nNewRecno := SC9->(Recno())
								//-- registro do SDC com DIFERENCA da quantidade empenho
								nQuant := nQtdNew
								// Busca as SDC da sequencia do pedido que será alterada.
								cAliasSDC := GetNextAlias()
								BeginSql Alias cAliasSDC
									SELECT SDC.R_E_C_N_O_ RECNOSDC
									FROM %Table:SDC% SDC
									WHERE SDC.DC_FILIAL = %xFilial:SDC%
									AND SDC.DC_PRODUTO = %Exp:SC9->C9_PRODUTO%
									AND SDC.DC_LOCAL = %Exp:SC9->C9_LOCAL%
									AND SDC.DC_ORIGEM = 'SC6'
									AND SDC.DC_PEDIDO = %Exp:SC9->C9_PEDIDO%
									AND SDC.DC_ITEM = %Exp:SC9->C9_ITEM%
									AND SDC.DC_SEQ = %Exp:cSequen%
									AND SDC.DC_LOTECTL = %Exp:SC9->C9_LOTECTL%
									AND SDC.DC_NUMLOTE = %Exp:SC9->C9_NUMLOTE%
									AND SDC.%NotDel%
									ORDER BY SDC.DC_QUANT DESC
								EndSql
								Do While (cAliasSDC)->(!Eof()) .And. nQuant > 0
									aCopySDC := {}
									SDC->(dbGoTo((cAliasSDC)->RECNOSDC))
									For nX := 1 To SDC->(FCount())
										Aadd(aCopySDC, SDC->(FieldGet(nX)))
									Next nX
									// Ajusta empenho
									If QtdComp(SDC->DC_QUANT) <= QtdComp(nQuant)
										RecLock("SDC", .F.)
										Replace DC_SEQ     With cSeqNew
										SDC->(MsUnlock())
										nQuant -= SDC->DC_QUANT
									Else
										nBaixa := SDC->DC_QUANT - nQuant
										// Ajusta empenho da sequencia origem
										RecLock("SDC", .F.)
										Replace DC_QUANT   With nBaixa
										Replace DC_QTSEGUM With ConvUM(SDC->DC_PRODUTO, nBaixa, 0, 2)
										SDC->(MsUnlock())
										// Gera empenho para nova sequencia
										dbSelectArea("SDC")
										RecLock("SDC", .T.)
										For nX := 1 To Len(aCopySDC)
											FieldPut(nX, aCopySDC[nX])
										Next nX
										Replace DC_SEQ     With cSeqNew
										Replace DC_QUANT   With nQuant
										Replace DC_QTSEGUM With ConvUM(SDC->DC_PRODUTO, nQuant, 0, 2)
										SDC->(MsUnlock())
										nQuant -= SDC->DC_QUANT
									EndIf
									(cAliasSDC)->(dbSkip())
								EndDo
								(cAliasSDC)->(dbCloseArea())
							EndIf
							If lRet
								If lSC9
									If nQtdNew > 0
										// Estorna a nova liberacao de pedido de venda.
										Os200TrbSC9(,SC9->(Recno()))
										oObjMrk:Refresh()
										Os200EstSC9()
									EndIf
								Else
									//-----------------------------------------------------------
									// Atualiza o arquivo temporario com os novos itens criados
									//-----------------------------------------------------------
									aCopySC9 := {}
									DbSelectArea(cAliasTRB)
									For nX := 1 To FCount()
										AAdd(aCopySC9,FieldGet(nX))
									Next nX

									For nX := 1 To 2
										If nX == 1
											SC9->(dbGoTo(nRecSc9))
											RecLock(cAliasTRB,.F.)
										Else
											SC9->(dbGoTo(nNewRecno))
											RecLock(cAliasTRB,.T.)
											For nY := 1 To FCount()
												FieldPut(nY,aCopySC9[nY])
											Next nY
										EndIf

										(cAliasTRB)->PED_SEQLIB := SC9->C9_SEQUEN
										If  (cAliasTRB)->(ColumnPos("PED_QTDLIB"))>0
											(cAliasTRB)->PED_QTDLIB := SC9->C9_QTDLIB
										EndIf
										// Calculo peso do item do pedido
										nPesoProd := OsPesoProd(SC9->C9_PRODUTO,SC9->C9_FILIAL)

										(cAliasTRB)->PED_PESO  := (nPesoProd * SC9->C9_QTDLIB)
										(cAliasTRB)->PED_VALOR := A410Arred(( SC9->C9_QTDLIB * SC9->C9_PRCVEN ),"DAK_VALOR")
										(cAliasTRB)->PED_VOLUM := OsPrCapArm(SC9->C9_PRODUTO,SC9->C9_FILIAL) * SC9->C9_QTDLIB
										(cAliasTRB)->(MsUnlock())
									Next nX
								EndIf
								If Type("aArrayMan") <> "U"
									aSize(aArrayMan,0)
								EndIf
							EndIf
							If !lRet
								Disarmtransaction()
							EndIf
						End Transaction
						// após gravação da divisão do item do pedido de vendas da carga.
						If lRet .And. lSC9 .And. ExistBlock("OM200DV9")
							ExecBlock("OM200DV9",.F.,.F.,{nRecSC9,nQtdNew})
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

	RestArea( aAreaTRB )
	RestArea( aAreaSB1 )
	RestArea( aAreaSC9 )
	RestArea( aAreaSC6 )
	RestArea( aAreaSC5 )
	RestArea( aAreaSA2 )
	RestArea( aAreaSA1 )
	RestArea( aArea    )
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Os200VlDiv³ Autor ³Daniel Pereira         ³ Data ³03.02.2021  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validacao da quantidade informada na rotina OS200DivSC9       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Quantidade Informada                                   ³±±
±±³          ³ExpN2: Peso do item                                           ³±±
±±³          ³ExpN3: Volume do item                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Os200VlDiv(nQtdNew,nPesoNew,nVolNew)
Local lRet      := .T.
Local lOM200DIV := ExistBlock("OM200DIV")
Local aAreaSB1  := SB1->(GetArea())
Local cAliasSB1 := GetNextAlias()
	BeginSql Alias cAliasSB1
		SELECT SB1.R_E_C_N_O_ RECNOSB1
		FROM %Table:SB1% SB1
		WHERE SB1.B1_FILIAL = %xFilial:SB1%
		AND SB1.B1_COD = %Exp:SC9->C9_PRODUTO%
		AND SB1.%NotDel%
	EndSql
	If (cAliasSB1)->(!Eof())
		SB1->(dbGoTo((cAliasSB1)->RECNOSB1))
		//-- Calculo peso do item do pedido
		nPesoNew := OsPesoProd(SC9->C9_PRODUTO,SC9->C9_FILIAL) * nQtdNew
		nVolNew  := OsPrCapArm(SC9->C9_PRODUTO,SC9->C9_FILIAL) * nQtdNew
		//-- Ponto de Entrada para validar a quantidade digitada pelo usuario
		If lOM200DIV
			lRetPE := ExecBlock("OM200DIV",.F.,.F.,{nQtdNew})
			lRet   := If(ValType(lRetPE)=="L", lRetPE, lRet)
		EndIf
	EndIf
	(cAliasSB1)->(dbCloseArea())
	RestArea(aAreaSB1)
Return( lRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OS200COrd ³ Autor ³Daniel Pereira        ³ Data ³30/01/2021  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Alteracao na ordem dos pedidos de venda.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Coluna do browse                                       ³±±
±±³          ³ExpO2: Objeto browse                                          ³±±
±±³          ³ExpA3: Array de ordem [1]-Coluna [2]-Indice do arquivo        ³±±
±±³          ³ExpC4: Alias do arquivo                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais/Distribuicao/Logistica                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atualizacoes sofridas desde a Construcao Inicial.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OS200COrd(nCol,oBrw,aHeadOrd,cAliasOrd)
Local nPosOrd := aScan(aHeadOrd,{|x| x[1] == nCol })
Local nX      := 1
Local nRetPE  := Nil
	If nPosOrd > 0
		// Pemite manipular a ordem dos pedidos apresentados em tela
		If lOM200ORP
			nRetPE := ExecBlock("OM200ORP",.F.,.F.,{aHeadOrd[nPosOrd][2]})
		EndIf
		If ValType(nRetPE) == "N"
			(cAliasOrd)->(DbSetOrder(nRetPE))
			(cAliasOrd)->(DbGoTop())
		Else
			(cAliasOrd)->(DbSetOrder(aHeadOrd[nPosOrd][2]))
			(cAliasOrd)->(DbGoTop())
		EndIf
		For nX := 1 to Len(aHeadOrd)
			cRes := Iif(nCol == aHeadOrd[nx,1],"COLDOWN","COLRIGHT")
			oBrw:SetHeaderImage(aHeadOrd[nx,1],cRes)
		Next
	EndIf
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Daniel Pereira        ³ Data ³01/02/2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function xMenuDef()
Local aSubRotina
Local lAGRUBS  := SuperGetMV("MV_AGRUBS",.F.,.F.)
Local lRotaInt := SuperGetMV("MV_ROTAINT",.F.,.F.)
Private aRotina := {}
	if l200Auto
		aRotina := {;
					{ OemtoAnsi(STR0060) ,'PesqBrw'      , 0 ,1 ,0 ,.F. },; //"Pesquisar"
					{ OemtoAnsi(STR0165) ,'U_xOs200Visual'  , 0 ,2 ,0 ,Nil },; //"Visualizar"
					{ OemtoAnsi(STR0003) ,'U_xOs200Liber'   , 0 ,4 ,0 ,Nil },; //"Liberacao"
					{ OemtoAnsi(STR0254) ,'MATA456'      , 0 ,4 ,0 ,Nil },; //"Liberacao Cred/Estoque"
					{ OemtoAnsi(STR0006) ,'U_xOs200Estor'   , 0 ,6 ,0 ,Nil },; //"Estorno"
					{ OemtoAnsi(STR0004) ,'U_xOsA200Mont'   , 0 ,3 ,0 ,Nil },; //"Carregamento"
					{ OemtoAnsi(STR0149) ,'U_xOs200Gant'    , 0 ,4 ,0 ,Nil },; //"Bloqueio"
					{ OemtoAnsi(STR0007) ,'U_xOs200Leg'     , 0 ,2 ,0 ,.F. }}
	Else
		aSubRotina := { { OemtoAnsi(STR0001) ,'U_xOsA200Mont'    , 0 ,3 },; //"Montagem de Carga"
						{ OemtoAnsi(STR0063) ,'U_xOS200Junta'    , 0 ,4 },; //"Agrupa"
						{ OemtoAnsi(STR0005) ,'U_xOs200Manut'    , 0 ,4 },; //"Manutencao"
						{ OemtoAnsi(STR0006) ,'U_xOs200Estor'    , 0 ,4 },; //"Estorno"
						{ OemtoAnsi(STR0012) ,'U_xOs200Assoc'    , 0 ,4 },; //"Associar Veiculo"
						{ OemtoAnsi(STR0120) ,'U_xOs200Blq'      , 0 ,4 }}  //"Bloqueio"

		aRotina := {{ OemtoAnsi(STR0060) ,'PesqBrw'       , 0 ,1 ,0 ,.F. },; //"Pesquisar"
					{ OemtoAnsi(STR0165) ,'U_xOs200Visual'   , 0 ,2 ,0 ,Nil },; //"Visualizar"
					{ OemtoAnsi(STR0003) ,'U_xOs200Liber'    , 0 ,4 ,0 ,Nil },; //"Liberacao"
					{ OemtoAnsi(STR0254) ,'MATA456'       , 0 ,4 ,0 ,Nil },; //"Liberacao Cred/Estoque"
					{ OemtoAnsi(STR0004) ,aSubRotina      , 0 ,3 ,0 ,Nil },; //"Carregamento"
					{ OemtoAnsi(STR0149) ,'U_xOs200Gant'     , 0 ,4 ,0 ,Nil },; //"Bloqueio"
					{ OemtoAnsi(STR0007) ,'U_xOs200Leg'      , 0 ,2 ,0 ,.F. } } //"Legenda"
	Endif
	//-- TEMPLATE DCL-EST - Cargas x Compartimentos e Lacres
	If SuperGetMv("MV_DCLNEW",.F.,.F.)
		aAdd(aRotina,{STR0276,"DclVaAloc",0,4,NIL}) // "Lacres"
	ElseIf HasTemplate("DCLEST")
		aAdd(aRotina,{STR0276,"DCVA04Aloc",0,4,NIL}) // "Lacres"
	EndIf
	// Integração Agroindústria - UBS -> Expedição de Sementes
	If FindFunction("OGX225MNU") .And. lAGRUBS
		aSubRotina := OGX225MNU(aSubRotina)
	Endif
	// Integração Rotas Inteligentes
	If lRotaInt .And. ExistFunc("OsRotMapLink") .And. TableInDic("DK4", .F.)
		aAdd(aRotina,{STR0281,"Os200EnvML",0,4,NIL}) // Planejar Roteirização
		aAdd(aRotina,{STR0282,"Os200VisML",0,4,NIL}) // Visualizar Roteirização
	EndIf
	If ExistBlock("OM200MNU")
		ExecBlock("OM200MNU",.F.,.F.)
	EndIf
Return( aRotina )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Oms200Rec ³ Autor ³ Daniel Pereira        ³ Data ³27/01/2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao disparada para validar cada registro da tabela      ³±±
±±³          ³ DAI e adicionar recno no array aRecSF2 utilizado na grava- ³±±
±±³          ³ cao da tabela DAI.                                         ³±±
±±³          ³ Se retornar .T. considera o registro.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array com numero dos registros da tabela DAI         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms200Rec(aRecno)
	AAdd(aRecno,DAI->(RecNo()))
Return( .T. )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Os200EstSC9ºAutor  ³Daniel Pereira       º Data ³ 29/01/2021º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Estorno as liberacoes de pedido de venda.                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Os200EstSC9()
Local lOk    := .F.
Local cAviso := ""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao permitir a exclusao de todos os itens. Somente algums podem ser estor-³
	//³nado devido ao vinculo com o DAI.                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TRB")
	DbGoTop()
	Do While !Eof()
		If !TRB->(IsMark("TRB_OK",ThisMark(),ThisInv()))
			lOk := .T.
			Exit
		EndIf
		DbSelectArea("TRB")
		DbSkip()
	EndDo
	If lOk
		If MsgYesNo(OemtoAnsi(STR0253),OemToAnsi(STR0054)) //"Confirma estorno dos itens selecionados? Os Pedidos de Vendas voltarao a ficar sem carga e aptos a serem utilizados em outras cargas."###"ATEN€AO"
			Begin Transaction
				DbSelectArea("TRB")
				DbGoTop()
				Do While !Eof() .And. lOk
					If TRB->(IsMark("TRB_OK",ThisMark(),ThisInv()))
						SC9->(MsGoto(TRB->TRB_RECNO))
						If (lOk := OMSVlEstSC9())
							lOk := OMSEstSC9()
						EndIf
					EndIf
					DbSelectArea("TRB")
					DbSkip()
				EndDo
			End Transaction
		Else
			lOk := .F.
		EndIf
		If !lOk
			DisarmTransaction()
		EndIf
		Os200TrbSC9()
	Else
		cAviso := STR0215 //"Para estornar todos os itens deste pedido, deve-se estornar o item da carga!"
	EndIf
	If  !Empty(cAviso)
		Aviso( STR0192, cAviso, { STR0194 }, 2 ) // "Atencao !"###"Ok"
	EndIf
Return lOk
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³Os200TrbSC9ºAutor  ³VDaniel Pereira    º Data ³ 29/01/2021  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Criar TRB de Pedidos para uso na MsSelect.                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Os200TrbSC9(aBrowse,nRecMrk)
Local aStruTrb   := {}
Local aTamSX3    := {}
Local cStatement := ""
Local cMark      := ThisMark()
Local cFilPv     := ""
Local nTpVlEnt   := OsVlEntCom()
Local nPCarga    := aScan(aHeader,{|x| AllTrim(x[2]) == "DAI_COD"   })
Local nPSeqCar   := aScan(aHeader,{|x| AllTrim(x[2]) == "DAI_SEQCAR"})
Local nPPedido   := aScan(aHeader,{|x| AllTrim(x[2]) == "DAI_PEDIDO"})
Local nPFilPv    := aScan(aHeader,{|x| AllTrim(x[2]) == "DAI_FILPV" })

Default nRecMrk := 0

	cFilPv := IIf(nTpVlEnt<>1,aCols[n][nPFilPv],xFilial("SC9"))
	If Select("TRB") > 0
		TRB->(DbGoTop())
		Do While TRB->(!Eof())
			Reclock("TRB",.F.)
			TRB->(DbDelete())
			TRB->(MsUnlock())
			TRB->(DbSkip())
		EndDo
	Else
		// Define arquivo de trabalho
										 AAdd(aStruTrb,{"TRB_OK"    ,"C",2         ,0         })
		aTamSX3 := TamSx3("C9_ITEM"   ); AAdd(aStruTrb,{"TRB_ITEM"  ,"C",aTamSX3[1],aTamSX3[2]})
		aTamSX3 := TamSx3("C9_SEQUEN" ); AAdd(aStruTrb,{"TRB_SEQUEN","C",aTamSX3[1],aTamSX3[2]})
		aTamSX3 := TamSx3("C9_PRODUTO"); AAdd(aStruTrb,{"TRB_PRODUT","C",aTamSX3[1],aTamSX3[2]})
		aTamSX3 := TamSx3("C9_QTDLIB" ); AAdd(aStruTrb,{"TRB_QTDLIB","N",aTamSX3[1],aTamSX3[2]})
		aTamSX3 := TamSx3("C9_LOTECTL"); AAdd(aStruTrb,{"TRB_LOTECT","C",aTamSX3[1],aTamSX3[2]})
		aTamSX3 := TamSx3("C9_NUMLOTE"); AAdd(aStruTrb,{"TRB_NUMLOT","C",aTamSX3[1],aTamSX3[2]})
		aTamSX3 := TamSx3("C9_DTVALID"); AAdd(aStruTrb,{"TRB_DTVALI","D",aTamSX3[1],aTamSX3[2]})
										 AAdd(aStruTrb,{"TRB_RECNO" ,"N",17        ,0         })
		// Define Campos
		AAdd(aBrowse,{"TRB_OK"    ,,""                    })
		AAdd(aBrowse,{"TRB_ITEM"  ,,RetTitle("C9_ITEM"   )})
		AAdd(aBrowse,{"TRB_SEQUEN",,RetTitle("C9_SEQUEN" )})
		AAdd(aBrowse,{"TRB_PRODUT",,RetTitle("C9_PRODUTO")})
		AAdd(aBrowse,{"TRB_QTDLIB",,RetTitle("C9_QTDLIB" )})
		AAdd(aBrowse,{"TRB_LOTECT",,RetTitle("C9_LOTECTL")})
		AAdd(aBrowse,{"TRB_NUMLOT",,RetTitle("C9_NUMLOTE")})
		AAdd(aBrowse,{"TRB_DTVALI",,RetTitle("C9_DTVALID")})

		__oTmpSC9 := FWTemporaryTable():New( "TRB" )
		__oTmpSC9:SetFields( aStruTrb )
		__oTmpSC9:AddIndex("indice1", {"TRB_ITEM","TRB_SEQUEN","TRB_PRODUT"} )
		__oTmpSC9:Create()
	EndIf

	If Empty(cMark)
		cMark := Space(2)
	EndIf
	// Alimenta a tabela temporária
	cStatement := "INSERT INTO "+__oTmpSC9:GetRealName()+" ("
	cStatement +=       " TRB_OK,"
	cStatement +=       " TRB_ITEM,"
	cStatement +=       " TRB_SEQUEN,"
	cStatement +=       " TRB_PRODUT,"
	cStatement +=       " TRB_QTDLIB,"
	cStatement +=       " TRB_LOTECT,"
	cStatement +=       " TRB_NUMLOT,"
	cStatement +=       " TRB_DTVALI,"
	cStatement +=       " TRB_RECNO)"
	cStatement +=" SELECT CASE WHEN SC9.R_E_C_N_O_ = "+Str(nRecMrk)+" THEN '"+cMark+"' ELSE '  ' END C9_OK,"
	cStatement +=       " SC9.C9_ITEM,"
	cStatement +=       " SC9.C9_SEQUEN,"
	cStatement +=       " SC9.C9_PRODUTO,"
	cStatement +=       " SC9.C9_QTDLIB,"
	cStatement +=       " SC9.C9_LOTECTL,"
	cStatement +=       " SC9.C9_NUMLOTE,"
	cStatement +=       " SC9.C9_DTVALID,"
	cStatement +=       " SC9.R_E_C_N_O_ SC9RECNO"
	cStatement +=  " FROM "+RetSqlName("SC9")+" SC9"
	cStatement += " WHERE SC9.C9_FILIAL  = '"+cFilPv+"'"
	cStatement +=   " AND SC9.C9_CARGA   = '"+aCols[n,nPCarga ]+"'"
	cStatement +=   " AND SC9.C9_SEQCAR  = '"+aCols[n,nPSeqCar]+"'"
	cStatement +=   " AND SC9.C9_PEDIDO  = '"+aCols[n,nPPedido]+"'"
	cStatement +=   " AND SC9.D_E_L_E_T_ = ' '"

	If TcSQLExec(cStatement) < 0
		MSgStop(STR0280 + CRLF + TCSQLError(),OMSA20002) // "Inconsistência ao tentar carregar os itens do pedido na tabela temporária: "
		Return
	EndIf
	TRB->(DbGoTop())
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Os200DelSC9³ Autor ³Daniel Pereira        ³ Data ³28.01.2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Estorno da liberação do item do pedido de venda vinculado ao³±±
±±³          ³item da carga.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Retornar                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³OMSA200                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Os200DelSC9()
Local aArea      := GetArea()
Local aBrowse    := {}
Local aObjects   := {}
Local aSize      := MsAdvSize( .F. )
Local aPosObj    := {}
Local aInfo      := {}
Local nOpcA      := 0
Local nPCarga    := aScan(aHeader,{|x| AllTrim(x[2]) == "DAI_COD"})
Local nPSeqCar   := aScan(aHeader,{|x| AllTrim(x[2]) == "DAI_SEQCAR"})
Local nPSequen   := aScan(aHeader,{|x| AllTrim(x[2]) == "DAI_SEQUEN"})
Local nPPedido   := aScan(aHeader,{|x| AllTrim(x[2]) == "DAI_PEDIDO"})
Local oDlg
Local oMark
	If nPCarga <> 0 .And. nPSeqCar <> 0 .And. nPSequen <> 0 .And. nPPedido <> 0
		Os200TrbSC9(aBrowse)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Passo parametros para calculo da resolucao da tela                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aObjects := {}
		AAdd( aObjects, { 100, 030, .T., .F. } )
		AAdd( aObjects, { 100, 090, .T., .T. } )
		aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
		aPosObj  := MsObjSize( aInfo, aObjects, .T. )

		DEFINE MSDIALOG oDlg FROM aSize[7], 000 TO aSize[6], aSize[5] TITLE OemToAnsi(STR0214) PIXEL//"Estorno do item do pedido"

		DEFINE SBUTTON FROM aPosObj[1,1]+010,aPosObj[1,4]-105 TYPE 11 ACTION (Os200DivSC9("SC9",,,TRB->TRB_RECNO,oMark:oBrowse),oMark:oBrowse:Refresh()) ENABLE OF oDlg
		DEFINE SBUTTON FROM aPosObj[1,1]+010,aPosObj[1,4]-070 TYPE  3 ACTION (Os200EstSC9(),oMark:oBrowse:Refresh())    ENABLE OF oDlg
		DEFINE SBUTTON FROM aPosObj[1,1]+010,aPosObj[1,4]-035 TYPE  1 ACTION (nOpcA:=2,oDlg:End())                  ENABLE OF oDlg
		@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] LABEL "" OF oDlg  PIXEL
		@ aPosObj[1,1]+010,010 SAY RetTitle("C9_CARGA")                         SIZE 46, 7 OF oDlg PIXEL
		@ aPosObj[1,1]+010,072 SAY aCols[n][nPCarga]+"/"+aCols[n][nPSeqCar]    SIZE 53, 7 OF oDlg PIXEL

		@ aPosObj[1,1]+010,120 SAY RetTitle("C9_PEDIDO")    SIZE 46, 7 OF oDlg PIXEL
		@ aPosObj[1,1]+010,160 SAY aCols[n][nPPedido]       SIZE 53, 7 OF oDlg PIXEL

		oMark:=MsSelect():New("TRB","TRB_OK",Nil,aBrowse,.F.,Nil,{aPosObj[2,1]+3,aPosObj[2,2],aPosObj[2,3]-3,aPosObj[2,4]})
		oMark:oBrowse:lCanAllmark := .F.

		ACTIVATE MSDIALOG oDlg

		DelTabTmp("TRB",__oTmpSC9)
	EndIf
	RestArea(aArea)
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OmsA200LOk³ Autor ³ Daniel Pereira       ³ Data ³29.01.2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da linha de GetDados                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function OmsA200LOk()
Local lRet := .T.
	If !GDDeleted( n )
		lRet := MaCheckCols( aHeader, aCols, n )
		If lRet
			lRet := GDCheckKey( { 'DAT_CODPAS' }, 4 )
		EndIf
		If lRet .And. aCols[n][Ascan(aHeader,{|x| x[2] == 'DAT_VALPAS'})] == 0
			lRet := .F.
		EndIf
	EndIf
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OmsA200TOk³ Autor ³ Daniel Pereira        ³ Data ³29.01.2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da GetDados                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function OmsA200TOk()
Local lRet := .T.
	lRet := OmsA200LOk()
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OmsA200Del³ Autor ³ Daniel Pereira        ³ Data ³29.01.2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a exclusao da linha da GetDados                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function OmsA200Del()
Local lRet := .T.
	//Condicao para nao chamar o delOk duas vezes
	If nDelItem == 1
		nDelItem := 0
		Return( .F. )
	EndIf

	nDelItem := 1

	If DAK->DAK_FEZNF == '2' //- So altera os valores se nao gerou fatura.
		If aCols[n][Len(aCols[n])] == .F.
			nFrete -= aCols[n][Ascan(aHeader,{|x| x[2] == 'DAT_VALPAS'})]
		Else
			nFrete += aCols[n][Ascan(aHeader,{|x| x[2] == 'DAT_VALPAS'})]
		EndIf
	EndIf
	oFrete:Refresh()
Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OmsA200Vld³ Autor ³ Daniel Pereira        ³ Data ³29.01.2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua a soma do frete.                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function OmsA200Vld()
Local lRet := .T.
	If ReadVar() == "M->DAT_VALPAS" .And. aCols[n][Len(aCols[n])] == .F.
		nFrete += ( M->DAT_VALPAS - aCols[n][Ascan(aHeader,{|x| x[2] == 'DAT_VALPAS'})] )
		oFrete:Refresh()
	EndIf
Return( lRet )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AdtoLinOk  ³ Autor ³Daniel Pereira       ³ Data ³29.01.2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validacao da Linha da GetDados de Adiantamentos             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AdtoLinOk()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³OMSA200                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function AdtoLinOk()
Local lRet      := .T.
Local cAliasDT7 := Nil
Local nPosBco   := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DG_BANCO'} )
Local nPosAg    := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DG_AGENCIA'} )
Local nPosCC    := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DG_NUMCON'} )
Local nPosDesp  := Ascan(aHeader, { |x| AllTrim(x[2]) == 'DG_CODDES'} )
Local nX        := 0
	If !GdDeleted(n)
		If !MaCheckCols(aHeader,aCols,n)
			Return( .F. )
		EndIf
		cAliasDT7 := GetNextAlias()
		BeginSql Alias caliasDT7
			SELECT DT7.DT7_MOVBCO
			FROM %Table:DT7% DT7
			WHERE DT7.DT7_FILIAL = %xFilial:DT7%
			AND DT7.DT7_CODDES = %Exp:GdFieldGet('DG_CODDES',n)%
			AND DT7.%NotDel%
		EndSql
		If (cAliasDT7)->(!Eof())
			// Se no cadastro da despesa o campo 'Movimento bancario' tiver conteudo igual a 'Sim'
			If (cAliasDT7)->DT7_MOVBCO == '1'
				If Empty(GdFieldGet('DG_BANCO',n)) .Or. Empty(GdFieldGet('DG_AGENCIA',n)) .Or. ;
					Empty(GdFieldGet('DG_NUMCON',n))
					Help('',1,'TMSA24035') //-- Informe o Banco / Agencia / No. da Conta ...
					GdFieldPut( 'DG_BANCO'   ,'   '        ,n )
					GdFieldPut( 'DG_AGENCIA' ,'     '      ,n )
					GdFieldPut( 'DG_NUMCON'  ,'          ' ,n )
					oGDados:oBrowse:Refresh(.T.)
					Return( .F. )
				EndIf
				//-- Copia os dados bancarios da despesa posicionada, para as outras despesas
				//-- informadas no aCols que tenham movimento bancario
				For nX := 1 To Len(aCols)
					If nX <> n
						(cAliasDT7)->(dbCloseArea())
						cAliasDT7 := GetNextAlias()
						BeginSql Alias caliasDT7
							SELECT DT7.DT7_MOVBCO
							FROM %Table:DT7% DT7
							WHERE DT7.DT7_FILIAL = %xFilial:DT7%
							AND DT7.DT7_CODDES = %Exp:aCols[nX][nPosDesp]%
							AND DT7.%NotDel%
						EndSql
						If (cAliasDT7)->(!Eof()) .And. (cAliasDT7)->DT7_MOVBCO == '1'
							GdFieldPut( 'DG_BANCO'  ,aCols[n][nPosBco] ,nX )
							GdFieldPut( 'DG_AGENCIA',aCols[n][nPosAg]  ,nX )
							GdFieldPut( 'DG_NUMCON' ,aCols[n][nPosCC]  ,nX )
						EndIf
					EndIf
				Next
				oGDados:oBrowse:Refresh(.T.)
			Else
				If  !Empty(GdFieldGet('DG_BANCO',n)) .Or. !Empty(GdFieldGet('DG_AGENCIA',n)) .Or. ;
					!Empty(GdFieldGet('DG_NUMCON',n))
					Help('',1,'TMSA24042') //-- Foi informado Banco, Conta ou Agencia para
					Return( .F. )          //   uma despesa que nao tem movimentacao bancaria.
				EndIf                       //    Retire essas informacoes !!!
			EndIf
			(cAliasDT7)->(dbCloseArea())
		EndIf

		If Empty(GdFieldGet('DG_TOTAL',n)) .Or. Empty(GdFieldGet('DG_VALCOB',n)) .Or. ;
			Empty(GdFieldGet('DG_VALBAI',n))
			Help('',1,'TMSA24007', , STR0231 + AllTrim(Str(n)), 3, 1 ) //"Existem campos com valores zerados" ### "Linha :"
			Return( .F. )
		EndIf
	EndIf
Return( lRet )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AdtoTudOk  ³ Autor ³ Daniel Pereira       ³ Data ³29.01.2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validacao da Tela da GetDados de Adiantamentos              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AdtoTudOk(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 - Opcao Selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³OMSA200                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function AdtoTudOk(nOpcx)
Static lOMA200Adt := ExistBlock('OMA200ADT')
Local lRet        := .T.
Local nX          := 0
Local nTotal      := 0
Local lGerADF     := GetMV("MV_GERADF",,.F.)  // Gera Titulo de Adiantamento de Frete com valor superior ao Valor do Frete+Pedagio
	lRet := IIf(nOpcx==3, AdtoLinOk(), .T.)
	//-- Analisa se ha itens duplicados na GetDados.
	If lRet
		For nX:=1 To Len(aCols)
			If !GDDeleted(nX)
				If Empty(GdFieldGet('DG_TOTAL',nX)) .Or. Empty(GdFieldGet('DG_VALCOB',nX)) .Or. ;
					Empty(GdFieldGet('DG_VALBAI',nX))
					Help('',1,'TMSA24007', , STR0231 + AllTrim(Str(nX)), 3, 1 ) //"Existem campos com valores zerados" ### "Linha :"
					Return( .F. )
				EndIf
				nTotal  += GdFieldGet('DG_VALBAI', nX)
			EndIf
		Next
	EndIf
	//-- Verifica se o valor cobrado e maior que valor do adiantamento.
	If !lGerADF .And. !Empty(nFrete) .And. nTotal > nFrete
		Help("",1,"TMSA24038") //"O total dos adiantamentos nao podera ser maior o valor do frete"
		Return( .F. )
	EndIf
	//-- Ponto de Entrada apos confirmar os Adiantamentos
	If lRet .And. lOMA200Adt
		lRet := ExecBlock("OMA200ADT",.F.,.F.,{nOpcx,nTotal,nFrete})
		If  ValType(lRet) <> "L"
			lRet := .T.
		EndIf
	EndIf
Return( lRet )
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OMS200VerBaºAutor ³Daniel Pereira      º Data ³  29.01.2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação de campo para zerar campos DG_AGENCIA e          º±±
±±º          ³ DG_NUMCON caso DG_BANCO esteja em branco.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function OMS200VerBa()
	If !(ExistCpo('SA6'))
			GDFIELDPUT('DG_BANCO','   ', n)
		If Empty(GdFieldGet('DG_BANCO',n))
			GDFIELDPUT('DG_BANCO'   ,'   '        , n)
			GDFIELDPUT('DG_AGENCIA' ,'     '      , n)
			GDFIELDPUT('DG_NUMCON'  ,'          ' , n)
			oGDados:oBrowse:Refresh(.T.)
			Return( .F. )
		EndIf
	EndIf
Return( .T. )
//-------------------------------------
/*  Modelo de Dados
@author     Daniel Pereira 
@version    P10 R1.4
@build      7.00.101202A
@since      06/04/2011
@return         oModel Objeto do Modelo*/
//-------------------------------------
/*
Static Function ModelDef()
Local oModel   := Nil
Local oStruDAK := FwFormStruct(1,"DAK")
Local oStruDAI := FwFormStruct(1,"DAI")
Local lIntGFE  := SuperGetMv("MV_INTGFE",,.F.)
Local aAux     := {}
	If lIntGFE
		oStruDAK:AddField( ;                      // Ord. Tipo Desc.
		"Cod.Tp.Op."                     , ;      // [01]  C   Titulo do campo
		"Cod.Tp.Op."                     , ;      // [02]  C   ToolTip do campo
		"DAK_CDTPOP"                     , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		10                               , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'SuperGetMv("MV_CDTPOP",.F.,"")' ), ;   // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual

		oStruDAK:AddField( ;                      // Ord. Tipo Desc.
		"CGC Transp"                     , ;      // [01]  C   Titulo do campo
		"CGC Transp"                     , ;      // [02]  C   ToolTip do campo
		"DAK_CGCTRA"                     , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		14                               , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		NIL                              , ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		NIL                              )        // [14]  L   Indica se o campo é virtual

		oStruDAK:AddField( ;                      // Ord. Tipo Desc.
		"Tipo Veic"                      , ;      // [01]  C   Titulo do campo
		"Tipo Veic"                      , ;      // [02]  C   ToolTip do campo
		"DAK_CDTPVC"                     , ;      // [03]  C   Id do Field
		'C'                              , ;      // [04]  C   Tipo do campo
		2                                , ;      // [05]  N   Tamanho do campo
		0                                , ;      // [06]  N   Decimal do campo
		NIL                              , ;      // [07]  B   Code-block de validação do campo
		NIL                              , ;      // [08]  B   Code-block de validação When do campo
		NIL                              , ;      // [09]  A   Lista de valores permitido do campo
		NIL                              , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'Posicione("DA3",1,xFilial("DA3")+DAK->DAK_CAMINH,"DA3_TIPVEI")'), ;      // [11]  B   Code-block de inicializacao do campo
		NIL                              , ;      // [12]  L   Indica se trata-se de um campo chave
		NIL                              , ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )        // [14]  L   Indica se o campo é virtual         +

		oStruDAK:AddField( ;                 // Ord. Tipo Desc.
		"Placa Vei"                     , ;     // [01]  C   Titulo do campo
		"Placa Vei"                     , ;     // [02]  C   ToolTip do campo
		"DAK_PLACA"                 , ;     // [03]  C   Id do Field
		'C'                                     , ;     // [04]  C   Tipo do campo
		TamSX3("DA3_PLACA")[1]  , ;     // [05]  N   Tamanho do campo
		0                                       , ;     // [06]  N   Decimal do campo
		NIL                                 , ;     // [07]  B   Code-block de validação do campo
		NIL                                 , ;     // [08]  B   Code-block de validação When do campo
		NIL                                 , ;     // [09]  A   Lista de valores permitido do campo
		NIL                                 , ;     // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'Posicione("DA3",1,xFilial("DA3")+DAK->DAK_CAMINH,"DA3_PLACA")'), ;      // [11]  B   Code-block de inicializacao do campo
		NIL                                 , ;     // [12]  L   Indica se trata-se de um campo chave
		NIL                                 , ;     // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                              )              // [14]  L   Indica se o campo é virtual         +

		aAux := FwStruTrigger(;
		"DAK_CAMINH", ;                                                      // [01] Id do campo de origem
		"DAK_CDTPVC" , ;                                                   // [02] Id do campo de destino
		'Posicione("DA3",1,xFilial("DA3")+M->DAK_CAMINH,"DA3_TIPVEI")' )

		oStruDAK:AddTrigger( ;
		aAux[1], ;                                                      // [01] Id do campo de origem
		aAux[2], ;                                                      // [02] Id do campo de destino
		aAux[3], ;                                                      // [03] Bloco de codigo de validação da execução do gatilho
		aAux[4] )                                                       // [04] Bloco de codigo de execução do gatilho

		aAux := FwStruTrigger(;
		"DAK_CAMINH", ;                          // [01] Id do campo de origem
		"DAK_PLACA" , ;                          // [02] Id do campo de destino
		'Posicione("DA3",1,xFilial("DA3")+M->DAK_CAMINH,"DA3_PLACA")')

		oStruDAK:AddTrigger( ;
		aAux[1], ;                                       // [01] Id do campo de origem
		aAux[2], ;                                       // [02] Id do campo de destino
		aAux[3], ;                                       // [03] Bloco de codigo de validação da execução do gatilho
		aAux[4] )                                        // [04] Bloco de codigo de execução do gatilho

		oStruDAK:SetProperty( '*', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, '.T.' ) )
		oStruDAK:SetProperty( '*'         , MODEL_FIELD_WHEN,  NIL )

		oStruDAI:SetProperty( '*'         , MODEL_FIELD_VALID, { || .T. } )
		oStruDAI:SetProperty( '*'         , MODEL_FIELD_WHEN,  NIL )
	EndIf
	//oModel := MpFormModel():New("OMSA200",/*PREVAL*/
	      /*POSVAL*//*BCANCEL*/
	//oModel:AddFields("OMSA200_DAK",,oStruDAK,/*prevalid*/,,/*bCarga*/)
	//oModel:SetDescription(OemtoAnsi(STR0001)) //"Montagem de carga"
	//oModel:GetModel("OMSA200_DAK"):SetDescription(OemtoAnsi(STR0001)) //"Montagem de carga"
	//oModel:SetPrimaryKey({"DAK_COD","DAK_SEQCAR"})

	//oModel:AddGrid("OMSA200_DAI","OMSA200_DAK",oStruDAI,)
	//oModel:SetRelation("OMSA200_DAI",{ {"DAI_FILIAL","xFilial('DAI')"}, {"DAI_COD","DAK_COD"}, {"DAI_SEQCAR","DAK_SEQCAR"} },"DAI_FILIAL+DAI_COD+DAI_SEQCAR")
//Return oModel

//-----------------------------------------------------
/*/ Valid após a confirmação de inclusão/alteração/exclusão
@author Daniel Pereira 
@version P11
@since 18/04/2013
/*/
//------------------------------------------------------
User Function OMSA200IPG(nOperation,cVeiculo,cMotorista,lCommit,cCarga,cSeqCar,cPedido,cDakTransp,cDAKTpOp,cDAKClFr,cVeiculo2,cVeiculo3,cRetCPL)
Local lRet      := .T.
Local lIntGFE   := SuperGetMv("MV_INTGFE",.F.,.F.)
Local cIntGFE2  := SuperGetMv("MV_INTGFE2",.F.,"2")
Local cIntCarga := SuperGetMv("MV_GFEI12",.F.,"2")

Default cVeiculo   := ""
Default cMotorista := ""
Default lCommit    := .T.
Default cCarga     := ""
Default cSeqCar    := "01"
Default cPedido    := ""
Default cDakTransp := Criavar("A4_COD",.F.)
Default cDAKTpOp   := ""
Default cDAKClFr   := ""
Default cVeiculo2  := ""
Default cVeiculo3  := ""
Default cRetCPL    := ""
	If lIntGFE .And. cIntGFE2 $ "1" .And. cIntCarga == "1"
		If !InterGWN(nOperation,cVeiculo,cMotorista,lCommit,cCarga,cSeqCar,cPedido,cDakTransp,cDAKTpOp,cDAKClFr,cVeiculo2,cVeiculo3,@cRetCPL)
			lRet := .F.
		EndIf
	EndIf
Return lRet
//-----------------------------------------------------
/*/ Integra a tabela DAK(Protheus) com GWN(SIGAGFE) a cada registro novo
@author Daniel Pereira 
@version P11
@since 18/04/2013
/*/
//------------------------------------------------------
Static Function InterGWN(nOperation,cVeiculo,cMotorista,lCommit,cCarga,cSeqCar,cPedido,cDakTransp,cDAKTpOp,cDAKClFr,cVeiculo2,cVeiculo3,cRetCPL)
Local lRet       :=  .T.
Local lPula      := .F.
Local lNumProp   := SuperGetMv("MV_EMITMP",.F.,"0") == "1" .And. SuperGetMv("MV_INTGFE2",.F.,"2") == "1"
Local lDakVeic2  := DAK->( ColumnPos("DAK_VEIC2" ) ) > 0
Local lFoundGWN  := .F.
Local lOMSXCPL7  := IsInCallStack("OMSXCPL7")
Local aAreaGWN   := GWN->( GetArea() )
Local aAreaGU3   := GU3->( GetArea() )
Local oModelGWN  := FWLoadModel("GFEA050")
Local cMsg       := ""
Local cTransp    := ""
Local cCgcTransp := ""
Local cSeqMV     := ""
Local cDataImp   := ""
Local cHoraImp   := ""
Local cNrRom     := IIf(Empty(cCarga),DAK->DAK_COD+DAK->DAK_SEQCAR,cCarga+cSeqCar)
Local cAliasGWN  := Nil
Local cAliasGU3  := Nil
Local cAliasSA4  := Nil
Local nTpOpSetad := 0
Local lAchouGFE  := .F.

	cAliasGWN := GetNextAlias()
	BeginSql Alias cAliasGWN
		SELECT GWN.R_E_C_N_O_ RECNOGWN
		FROM %Table:GWN% GWN
		WHERE GWN.GWN_FILIAL = %xFilial:GWN%
		AND GWN.GWN_NRROM = %Exp:cNrRom%
		AND GWN.%NotDel%
	EndSql
	If (cAliasGWN)->(!Eof())
		GWN->(dbGoTo((cAliasGWN)->RECNOGWN))
		lFoundGWN := .T.
	EndIf
	(cAliasGWN)->(dbCloseArea())
	// Se alterou o código da transportadora, deve excluir o romaneio atual e gerar um novo.
	// Evita a necessidade de replicar as regras de validação para a rotina do OMS, tendo em vista que
	// atualmente não existe uma função padrão do GFE para alteração do transportador do romaneio
	If lFoundGWN .And. lCommit .And. nOperation != MODEL_OPERATION_DELETE .And. !Empty(cDakTransp)
		cAliasSA4 := GetNextAlias()
		BeginSql Alias cAliasSA4
			SELECT SA4.A4_CGC
			FROM %Table:SA4% SA4
			WHERE SA4.A4_FILIAL = %xFilial:SA4%
			AND SA4.A4_COD = %Exp:cDakTransp%
			AND SA4.%NotDel%
		EndSql
		If (cAliasSA4)->(!Eof())
			cCgcTransp := (cAliasSA4)->A4_CGC
		EndIf
		(cAliasSA4)->(dbCloseArea())

		If !(cDakTransp == GWN->GWN_CDTRP .Or. cCgcTransp == GWN->GWN_CDTRP)
			If !OMSA200IPG(5,,,.T.,,,,cDakTransp)
				Return .F.
			EndIf
			cCarga    := DAK->DAK_COD
			cDAKTpOp  := DAK->DAK_CDTPOP
			cDAKClFr  := DAK->DAK_CDCLFR
			cDataImp  := DAK->DAK_DATA
			cHoraImp  := DAK->DAK_HORA
			lFoundGWN := .F.
		EndIf
	EndIf
	// Verifica se transportadora informada no pedido ou na carga
	If nOperation != MODEL_OPERATION_DELETE
		If !Empty(cDakTransp)
			cTransp := cDakTransp
		Else
			cAliasSC5 := GetNextAlias()
			If Empty(cCarga)
				BeginSql Alias cAliasSC5
					SELECT SC5.C5_TRANSP
					FROM %Table:DAI% DAI
					INNER JOIN %Table:SC5% SC5
					ON SC5.C5_FILIAL = %xFilial:SC5%
					AND SC5.C5_NUM = DAI.DAI_PEDIDO
					AND SC5.%NotDel%
					WHERE DAI.DAI_FILIAL = %xFilial:DAI%
					AND DAI.DAI_COD = %Exp:DAK->DAK_COD%
					AND DAI.DAI_SEQCAR = %Exp:DAK->DAK_SEQCAR%
					AND DAI.%NotDel%
				EndSql
			Else
				BeginSql Alias cAliasSC5
					SELECT SC5.C5_TRANSP
					FROM  %Table:SC5% SC5
					WHERE SC5.C5_FILIAL = %xFilial:SC5%
					AND SC5.C5_NUM = %Exp:cPedido%
					AND SC5.%NotDel%
				EndSql
			EndIf
			If (cAliasSC5)->(!Eof())
				cTransp := (cAliasSC5)->C5_TRANSP
			EndIf
			(cAliasSC5)->(dbCloseArea())
		EndIf
	EndIf

	If lFoundGWN

		If nOperation == MODEL_OPERATION_INSERT
			oModelGWN:SetOperation( MODEL_OPERATION_UPDATE )
			nTpOpSetad := MODEL_OPERATION_UPDATE
		Else
			oModelGWN:SetOperation( nOperation )
		EndIf

	Else
		If nOperation == MODEL_OPERATION_INSERT
			oModelGWN:SetOperation( MODEL_OPERATION_INSERT )
			nTpOpSetad := MODEL_OPERATION_INSERT
		Else
			If Empty(cCarga)
				lPula := .T.
			Else
				oModelGWN:SetOperation( MODEL_OPERATION_INSERT )
				nTpOpSetad := MODEL_OPERATION_INSERT
			EndIf
		EndIf
	EndIf

	If !lPula .And. ((nOperation == MODEL_OPERATION_DELETE) .Or. (!Empty(cTransp) .And. nOperation != MODEL_OPERATION_DELETE) )
		oModelGWN:Activate()

		If !oModelGWN:IsActive()
			cMsg := oModelGWN:GetErrorMessage()[6]
			lRet := .F.
		Else
			If nOperation <> MODEL_OPERATION_DELETE
				If nOperation == MODEL_OPERATION_INSERT .Or. ( nTpOpSetad == MODEL_OPERATION_INSERT .And. nOperation == MODEL_OPERATION_UPDATE )
					oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_CDMTR'  , IIF(Empty(cCarga),DAK->DAK_MOTORI,SubStr(cMotorista,1,TamSx3("GWN_CDMTR")[1])) )
					oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_CDTPVC' , Iif(Empty(cVeiculo)  .And. Empty(DAK->DAK_CAMINH),"",Posicione("DA3",1,xFilial("DA3")+IIF(Empty(cCarga),DAK->DAK_CAMINH,cVeiculo ),"DA3_TIPVEI")))
					oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_PLACAD' , Iif(Empty(cVeiculo)  .And. Empty(DAK->DAK_CAMINH),"",Posicione("DA3",1,xFilial("DA3")+IIF(Empty(cCarga),DAK->DAK_CAMINH,cVeiculo ),"DA3_PLACA" )))
					If lDakVeic2
						oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_PLACAM' , Iif(Empty(cVeiculo2) .And. Empty(DAK->DAK_VEIC2 ),"",Posicione("DA3",1,xFilial("DA3")+IIF(Empty(cCarga),DAK->DAK_VEIC2 ,cVeiculo2),"DA3_PLACA" )))
						oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_PLACAT' , Iif(Empty(cVeiculo3) .And. Empty(DAK->DAK_VEIC3 ),"",Posicione("DA3",1,xFilial("DA3")+IIF(Empty(cCarga),DAK->DAK_VEIC3 ,cVeiculo3),"DA3_PLACA" )))
					EndIf
					If nTpOpSetad <> MODEL_OPERATION_UPDATE
						oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_FILIAL', IIF(Empty(cCarga),DAK->DAK_FILIAL,xFilial("DAK")) )
						oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_NRROM ', IIF(Empty(cCarga),DAK->DAK_COD+DAK->DAK_SEQCAR,cCarga+cSeqCar) )
						oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_ORI'   , "2" )
					EndIf

					If !Empty(cDakTransp)
						cTransp := cDakTransp
					Else
						If Select("TRBPED")>0
							cTransp := Posicione('SC5',1,xFilial('SC5')+IIF(Empty(cCarga),Posicione("DAI",1,xFilial("DAI")+DAK->DAK_COD+DAK->DAK_SEQCAR,"DAI_PEDIDO"),TRBPED->PED_PEDIDO),'C5_TRANSP')
						Else
							cTransp := Posicione('SC5',1,xFilial('SC5')+IIF(Empty(cCarga),Posicione("DAI",1,xFilial("DAI")+DAK->DAK_COD+DAK->DAK_SEQCAR,"DAI_PEDIDO"),cPedido),'C5_TRANSP')
						EndIf
					EndIf

					If lNumProp
						cAliasGU3 := GetNextAlias()
						BeginSql Alias cAliasGU3
							SELECT GU3.GU3_CDEMIT,
									GU3.GU3_SIT
							FROM %Table:GU3% GU3
							WHERE GU3.GU3_FILIAL = %xFilial:GU3%
							AND GU3.GU3_CDTERP = %Exp:cTransp%
							AND GU3.GU3_SIT = '1'
							AND (GU3.GU3_TRANSP = '1' OR GU3.GU3_AUTON = '1')
							AND GU3.%NotDel%
						EndSql
						If (cAliasGU3)->(!Eof())
							cCgcTransp := (cAliasGU3)->GU3_CDEMIT
						Else
							cAliasSA4 := GetNextAlias()
							BeginSql Alias cAliasSA4
								SELECT SA4.A4_CGC,
										SA4.A4_INSEST,
										GU3.GU3_CDEMIT
								FROM %Table:SA4% SA4
								INNER JOIN %Table:GU3% GU3
								ON GU3.GU3_FILIAL = %xFilial:GU3%
								AND GU3.GU3_IDFED = SA4.A4_CGC
								AND GU3.GU3_IE = SA4.A4_INSEST
								AND GU3.GU3_SIT = '1'
								AND (GU3.GU3_TRANSP = '1' OR GU3.GU3_AUTON = '1')
								AND GU3.%NotDel%
								WHERE SA4.A4_FILIAL = %xFilial:SA4%
								AND SA4.A4_COD = %Exp:cTransp%
								AND SA4.%NotDel%
							EndSql
							If (cAliasSA4)->(!Eof())
								cCgcTransp := (cAliasSA4)->GU3_CDEMIT
							EndIf
							(cAliasSA4)->(dbCloseArea())
						EndIf
						(cAliasGU3)->(dbCloseArea())
					Else
						cAliasSA4 := GetNextAlias()
						BeginSql Alias cAliasSA4
							SELECT SA4.A4_CGC,
									SA4.A4_INSEST,
									GU3.GU3_CDEMIT
							FROM %Table:SA4% SA4
							INNER JOIN %Table:GU3% GU3
							ON GU3.GU3_FILIAL = %xFilial:GU3%
							AND GU3.GU3_CDEMIT = SA4.A4_CGC
							AND GU3.GU3_SIT = '1'
							AND (GU3.GU3_TRANSP = '1' OR GU3.GU3_AUTON = '1')
							AND GU3.%NotDel%
							WHERE SA4.A4_FILIAL = %xFilial:SA4%
							AND SA4.A4_COD = %Exp:cTransp%
							AND SA4.%NotDel%
						EndSql
						If (cAliasSA4)->(!Eof())
							cCgcTransp := (cAliasSA4)->GU3_CDEMIT
						EndIf
						(cAliasSA4)->(dbCloseArea())
					EndIf

					If !Empty(cDAKTpOp)
						oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_CDTPOP' , cDAKTpOp )
					Else
						oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_CDTPOP' , SuperGetMv("MV_CDTPOP",.F.,"") )
					EndIf

					If !Empty(cDAKClFr)
						oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_CDCLFR' , cDAKClFr )
					Else
						oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_CDCLFR' , SuperGetMv("MV_CDCLFR",.F.,"") )
					EndIF
					oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_CDTRP'  , cCGCTransp )
					// Definição de data e hora da implantação do Romaneio
					If Empty(cDataImp)
						If Empty(cCarga)
							cDataImp := DAK->DAK_DATA
							cHoraImp := DAK->DAK_HORA
						Else
							cDataImp := dDatabase
							cHoraImp := Time()
						EndIf
					EndIf
					oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_DTIMPL' , cDataImp)
					oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_HRIMPL' , SubStr(cHoraImp,1,5))
				Else
					oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_CDMTR'  , cMotorista )
					oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_CDTPVC' , Iif(Empty(cVeiculo) ,"",Posicione("DA3",1,xFilial("DA3")+cVeiculo,"DA3_TIPVEI")))
					oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_PLACAD' , Iif(Empty(cVeiculo) ,"",Posicione("DA3",1,xFilial("DA3")+cVeiculo ,"DA3_PLACA")))
					oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_PLACAM' , Iif(Empty(cVeiculo2),"",Posicione("DA3",1,xFilial("DA3")+cVeiculo2,"DA3_PLACA")))
					oModelGWN:SetValue( 'GFEA050_GWN', 'GWN_PLACAT' , Iif(Empty(cVeiculo3),"",Posicione("DA3",1,xFilial("DA3")+cVeiculo3,"DA3_PLACA")))
				EndIf

			EndIf
			If oModelGWN:VldData()
				If lCommit
					oModelGWN:CommitData()
					// Integração Agroindustria - SIGAAGR
					If FindFunction("OGX225I") .And. (SuperGetMV("MV_AGRUBS",.F.,.F.))

						//Pegando a resposta do pergunte para passar como parametro.
						Pergunte("OMS200C",.F.)
						cSeqMV := mv_par03
						OGX225I(nOperation,cVeiculo,cMotorista,GWN->GWN_CDTRP,AllTrim(GWN->GWN_NRROM),IIF(Empty(cCarga),DAK->DAK_COD,cCarga),cSeqCar,mv_par02,cSeqMV)

						//Devolvendo a resposta ao pergunte padrão para não impactar em outras funções.
						Pergunte("OMS200",.F.)
					EndIf
				EndIf
			Else
				If !lOMSXCPL7
					cMsg := STR0255+CRLF+CRLF+oModelGWN:GetErrorMessage()[6]//"Inconsistência com o Frete Embarcador (SIGAGFE): "##
				Else
					cRetCPL := oModelGWN:GetErrorMessage()[6]
					lAchouGFE := .T.
				EndIf
				lRet := .F.
			EndIf
		EndIf
		oModelGWN:Deactivate()
	EndIf
	If !lRet .And. !lOMSXCPL7
		Help( ,, STR0192,,cMsg, 1, 0 ) //"Atenção"
	EndIf
	IF !lRet .And. lOMSXCPL7 .AND. !Empty(cMsg) .AND. !lAchouGFE
		cRetCPL := cMsg
	EndIF	
	RestArea( aAreaGWN )
	RestArea( aAreaGU3 )
Return lRet
//-----------------------------------------------------
/*/ Integra a tabela DAK(Protheus) com GWN(SIGAGFE) quando agrupa carga
@author Squad WMS/OMS Protheus /Daniel Pereira 
@version P12
@since 21/09/2018
/*/
//------------------------------------------------------
User Function xOMSA200IRM(cCarga,cSeqCar)
Local lRet      := .T.
Local cAliasGW1 := Nil

	cAliasGW1 := GetNextAlias()
	BeginSql Alias cAliasGW1
		SELECT GW1.R_E_C_N_O_ RECNOGW1,
				DAI.DAI_COD,
				DAI.DAI_SEQCAR
		FROM %Table:GW1% GW1
		INNER JOIN %Table:DAI% DAI
		ON DAI.DAI_FILIAL = %xFilial:DAI%
		AND DAI.DAI_COD =    %Exp:cCarga%
		AND DAI.DAI_SEQCAR = %Exp:cSeqCar%
		AND DAI.DAI_NFISCA = GW1.GW1_NRDC
		AND DAI.%NotDel%
		WHERE GW1.GW1_FILIAL = %xFilial:GW1%
		AND GW1.GW1_CDTPDC = 'NFS'
		AND GW1.GW1_SIT = '3'
		AND GW1.%NotDel%
	EndSql
	Do While (cAliasGW1)->(!Eof())
		GW1->(dbGoTo((cAliasGW1)->RECNOGW1))

		RecLock("GW1", .F.)
		GW1->GW1_NRROM := (cAliasGW1)->DAI_COD+(cAliasGW1)->DAI_SEQCAR
		GW1->GW1_SIT   := "4" // Embarcado
		GW1->(MsUnLock())

		(cAliasGW1)->(dbSkip())
	EndDo
	(cAliasGW1)->(dbCloseArea())
Return lRet
//-----------------------------------------------------
/*
	Funcao Om200TpOper - Informa Tipo de Operação e Classificação de Frete
	@Author Daniel Pereira de Souza
	@Version P12
	@Since 03/10/2017
*/
//------------------------------------------------------
Static Function Om200TpOper(aArrayMan, cDAKTpOp, cDAKClFr, aArrayCarga, oCargas)
Local oDlg   := Nil
Local oTpOp  := Nil
Local oClFr  := Nil
Local nCarga := 1
	If Len(aArrayMan) > 0
		DEFINE FONT oBold  NAME "Arial" SIZE 0, -12  BOLD

		DEFINE MSDIALOG oDlg TITLE OemtoAnsi("Tipo Oper/ Class. Frete") FROM C(221),C(250) TO C(370),C(620) PIXEL // "Tipo Oper/ Class. Frete"

		@ C(033),C(006) Say ("Tipo Operação") + ":"    Size C(055),C(008) COLOR CLR_BLUE  PIXEL OF oDlg FONT oBold //"Tipo Operação"
		@ C(031),C(045) MsGet oTpOp Var cDAKTpOp Valid ( Empty(cDAKTpOp) .Or. Os200VdOp(cDAKTpOp) ) F3 "GV4" Size C(040),C(009) COLOR CLR_BLACK OF oDlg PIXEL HASBUTTON
		@ C(043),C(006) Say ("Class. Frete") +  ":"    Size C(055),C(008) COLOR CLR_BLUE  PIXEL OF oDlg FONT oBold // Class. Frete
		@ C(045),C(045) MsGet oClFr Var cDAKClFr Valid ( Empty(cDAKClFr) .Or. Os200VdClF(cDAKClFr) ) F3 "GUB" Size C(040),C(009) COLOR CLR_BLACK OF oDlg PIXEL HASBUTTON

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {||oDlg:End()}, {|| oDlg:End() })

		nCarga := Len(aArrayCarga)
		aArrayCarga[nCarga,CARGA_TPOP] := cDAKTpOp
		aArrayCarga[nCarga,CARGA_CLFR] := cDAKClFr
	Else
		Help(" ",1,"OMSPEDMARK") //Nao existem pedidos selecionados para a visualizacao
	EndIf
Return
//-----------------------------------------------------
/*  Funcao Os200VdOp - Valida se Tipo de Operação
	existe na tela de selecao
	@author Daniel Pereira 
	@version P12
	@since 03/10/2017
*/
//------------------------------------------------------
Static Function Os200VdOp(cDAKTpOp)
Local lRet      := .T.
Local aAreaGV4  := GV4->(GetArea())
Local cAliasGV4 := Nil

	cAliasGV4 := GetNextAlias()
	BeginSql Alias cAliasGV4
		SELECT 1
		FROM %Table:GV4% GV4
		WHERE GV4.GV4_FILIAL = %xFilial:GV4%
		AND GV4.GV4_CDTPOP = %Exp:cDAKTpOp%
		AND GV4.%NotDel%
	EndSql
	If (cAliasGV4)->(Eof())
		Help(" ",1,"REGNOIS")//Mensagem de registro nao relacionado
		lRet := .F.
	EndIf
	(cAliasGV4)->(dbCloseArea())
	RestArea(aAreaGV4)
Return lRet
//-----------------------------------------------------
/*  Funcao Os200VdClF - Valida se Classificação de
	Frete existe na tela de selecao
	@author Daniel Pereira 
	@version P12
	@since 03/10/2017
*/
//------------------------------------------------------
Static Function Os200VdClF(cDAKClFr)
Local lRet      := .T.
Local aAreaGUB  := GUB->(GetArea())
Local cAliasGUB := Nil

	cAliasGUB := GetNextAlias()
	BeginSql Alias cAliasGUB
		SELECT 1
		FROM %Table:GUB% GUB
		WHERE GUB.GUB_FILIAL = %xFilial:GUB%
		AND GUB.GUB_CDCLFR = %Exp:cDAKClFr%
		AND GUB.%NotDel%
	EndSql
	If (cAliasGUB)->(Eof())
		Help(" ",1,"REGNOIS")//Mensagem de registro nao relacionado
		lRet := .F.
	EndIf
	(cAliasGUB)->(dbCloseArea())
	RestArea(aAreaGUB)
Return lRet
//------------------------------------------------------
/*/ Funcao OM200TRANS - Informa Transportadora na Carga
@author Daniel Pereira 
@version P12
@since 27/09/2013
/*/
//------------------------------------------------------
Static Function Om200Trans(aArrayMan,cDakTransp,cNtrans,aArrayCarga,oCargas)
Local lA4_MSBLQL := SA4->(ColumnPos("A4_MSBLQL"))>0
Local aButtons   := {}
Local oTrans
Local onTrans
Local cAliasSA4  := Nil
Local nCarga
Local lOM200DTR := ExistBlock('OM200DTR')//Ponto de entrada para alterar o Dialog da transportadora.
Local aRetTran := {}

Private oDlg
Private INCLUI  := .F.  // (na Enchoice) .T. Traz registro para Inclusao / .F. Traz registro para Alteracao/Visualizacao

Default aArrayMan   := {}
Default cDakTransp  := Criavar("A4_COD",.F.)
Default aArrayCarga := {}
Default cNtrans     := ""
	If Len(aArrayMan) > 0
		If !Empty(cDakTransp)
			If lA4_MSBLQL
				cAliasSA4 := GetNextAlias()
				BeginSql Alias cAliasSA4
					SELECT SA4.A4_MSBLQL,
							SA4.A4_NREDUZ
					FROM %Table:SA4% SA4
					WHERE SA4.A4_FILIAL = %xFilial:SA4%
					AND SA4.A4_COD = %Exp:cDakTransp%
					AND SA4.%NotDel%
				EndSql
				If (cAliasSA4)->(!Eof())
					If (cAliasSA4)->A4_MSBLQL <> '1'
						cNtrans := (cAliasSA4)->A4_NREDUZ
					Else
						Help(" ",1,"OMS200TPBL")//Transportadora Bloqueada.
						lRet := .F.
					EndIf
				EndIf
				(cAliasSA4)->(dbCloseArea())
			Else
				cAliasSA4 := GetNextAlias()
				BeginSql Alias cAliasSA4
					SELECT SA4.A4_NREDUZ
					FROM %Table:SA4% SA4
					WHERE SA4.A4_FILIAL = %xFilial:SA4%
					AND SA4.A4_COD = %Exp:cDakTransp%
					AND SA4.%NotDel%
				EndSql
				If (cAliasSA4)->(!Eof())
					cNtrans := (cAliasSA4)->A4_NREDUZ
				EndIf
				(cAliasSA4)->(dbCloseArea())
			EndIf
		EndIf

		If lOM200DTR//Ponto de entrada para alterar o Dialog da transportadora.
			aRetTran := ExecBlock('OM200DTR',.F.,.F.,{cDakTransp,cNtrans,aArrayMan,aArrayCarga})

			If valtype(aRetTran[1]) == "C" .AND. valtype(aRetTran[2]) == "C"
				cDakTransp	:= aRetTran[1]
				cNtrans		:= aRetTran[2]
			EndIf
		else
			DEFINE FONT oBold  NAME "Arial" SIZE 0, -12  BOLD

			DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0259) FROM C(221),C(260) TO C(320),C(620) PIXEL // "Transportadora"

				@ C(033),C(006) Say (STR0259) + ":"    Size C(055),C(008) COLOR CLR_BLUE  PIXEL OF oDlg FONT oBold //"Transportadora:"
				@ C(031),C(045) MsGet oTrans  Var cDakTransp  Picture "@!" Valid ( Os200NomTr(cDakTransp, @cNtrans) ) F3 "SA4" Size C(040),C(009) COLOR CLR_BLACK PIXEL OF oDlg
				@ C(031),C(090) MsGet onTrans Var cNtrans Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlg  When .F.

			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {||oDlg:End()}, {||cDakTransp:=Criavar("A4_COD",.F.),oDlg:End()},,aButtons)

		EndIf

		nCarga := Len(aArrayCarga)
		aArrayCarga[nCarga,CARGA_TRANSP] := cDakTransp
	Else
		Help(" ",1,"OMSPEDMARK") //Nao existem pedidos selecionados para a visualizacao
	EndIf
Return
//-----------------------------------------------------
/*/ Funcao Os200NomTr - Busca o nome da transportadora
//  na tela de selecao
@author Daniel Pereira 
@version P12
@since 25/10/2013
/*/
//------------------------------------------------------
Static Function Os200NomTr(cDakTransp,cNTrans)
Local lRet       := .T.
Local lA4_MSBLQL := SA4->(ColumnPos("A4_MSBLQL"))>0
Local aAreaSA4   := GetArea()
Local cAliasSA4  := Nil

Default cDakTransp := Criavar("A4_COD",.F.)
Default cNtrans    := ""

	If Empty(cDakTransp)
		cNtrans := ""
		Return .T.
	EndIf
	If lA4_MSBLQL
		cAliasSA4 := GetNextAlias()
		BeginSql Alias cAliasSA4
			SELECT SA4.A4_MSBLQL,
					SA4.A4_NREDUZ
			FROM %Table:SA4% SA4
			WHERE SA4.A4_FILIAL = %xFilial:SA4%
			AND SA4.A4_COD = %Exp:cDakTransp%
			AND SA4.%NotDel%
		EndSql
		If (cAliasSA4)->(!Eof())
			If (cAliasSA4)->A4_MSBLQL <> '1'
				cNtrans := (cAliasSA4)->A4_NREDUZ
			Else
				Help(" ",1,"OMS200TPBL")//Transportadora Bloqueada.
				lRet := .F.
			EndIf
		Else
			Help(" ",1,"REGNOIS")//Mensagem de registro nao relacionado
			lRet := .F.
		EndIf
		(cAliasSA4)->(dbcloseArea())
	Else
		cAliasSA4 := GetNextAlias()
		BeginSql Alias cAliasSA4
			SELECT SA4.A4_NREDUZ
			FROM %Table:SA4% SA4
			WHERE SA4.A4_FILIAL = %xFilial:SA4%
			AND SA4.A4_COD = %Exp:cDakTransp%
			AND SA4.%NotDel%
		EndSql
		If (cAliasSA4)->(!Eof())
			cNtrans := (cAliasSA4)->A4_NREDUZ
		Else
			Help(" ",1,"REGNOIS")//Mensagem de registro nao relacionado
			lRet := .F.
		EndIf
		(cAliasSA4)->(dbCloseArea())
	EndIf
	RestArea( aAreaSA4 )
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} OMSVlEstDAK
Valida estorno da carga posicionada.
@author  Daniel Pereira 
@version P12
@Since	04/12/2018
@version 1.0
/*/
//-----------------------------------------------------------
User Function OMSVlEstDAK()
Local lRet      := .T.
Local lRetPE    := .T.
Local lBloqueio := OsBlqExec(DAK->DAK_COD, DAK->DAK_SEQCAR)
	// Verifico se a carga ja foi unitizada impossibilitando o estorno
	If lRet .and. ( DAK->DAK_FLGUNI == "1" )
		Help(" ",1,"OMS200CUNI") //A carga mencionada já foi unitizada.
		lRet := .F.
	EndIf
	If lRet .And. ( DAK->DAK_FEZNF == "1" )
		Help(" ",1,"OMS200CFAT") //Esta carga já se encontra faturada.
		lRet := .F.
	EndIf
	// Verifica se existe o campo e se esta bloqueada
	If lRet .And. (DAK->DAK_BLQCAR == '1' .Or. lBloqueio)
		lRet := .F.
		Help(" ",1,"OMS200CGBL") //Carga bloqueada ou com serviço em execução.
	EndIf
	// Impede o estorno de Cargas com Servico de WMS já executado
	If lRet
		lRet := WmsAvalDAK(DAK->DAK_COD,DAK->DAK_SEQCAR)
	EndIf
	// Template DCL-EST - Validacao do estorno de Cargas com Compartimentos/Lacres associados.
	If lRet .And. ExistTemplate("OMSA200P")
		lRetPE    := ExecTemplate("OMSA200P",.F.,.F.,{DAK->DAK_COD,DAK->DAK_SEQCAR})
		lRet := If(ValType(lRetPE)=="L", lRetPE, lRet)
	EndIf
	// AGROINDUSTRIA - Verifica se existe agendamento e não deixa estornar
	If lRet .And. FindFunction("OGX225K") .And. (SuperGetMV("MV_AGRUBS", .F., .F.))
		If !OGX225K(DAK->DAK_FILIAL, DAK->DAK_COD, DAK->DAK_SEQCAR)
			lRet := .F.
		EndIf
	EndIF
	// PE antes da pergunta se deseja ou não realizar o estorno
	If lRet .And. ExistBlock("OMSA200P")
		lRetPE    := ExecBlock("OMSA200P",.F.,.F.,{DAK->DAK_COD,DAK->DAK_SEQCAR})
		lRet := If(ValType(lRetPE)=="L", lRetPE, lRet)
	EndIf
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} OMSEstSC9
Valida estorno da SC9 posicionada.
@author  Daniel Pereira 
@version P12
@Since	04/12/2018
@version 1.0
/*/
//-----------------------------------------------------------
User Function xOMSVlEstSC9()
Local lRet      := .T.
Local lEstLib   := SuperGetMV("MV_OMSESTP",.F.,.T.) .And. OmsPedCPL(SC9->C9_FILIAL,SC9->C9_PEDIDO)// Indica se estorna liberacao do pedido de vendas de uma carga ao dividir um item. Onde .T. (default) efetua o estorno. Quando integrado com o CPL o estorno da liberação não é permitida.
	If (SC9->C9_BLEST == "10" .And. SC9->C9_BLCRED == "10") .OR. (SC9->C9_BLEST == "ZZ" .And. SC9->C9_BLCRED == "ZZ")
		Help(" ",1,"NFEMITIDA")
		lRet := .F.
	EndIf
	If lRet .And. !IsInCallStack("Os200DivSC9") // Já validou na função anterior
		lRet := WmsAvalDAK(/*cCarga*/,/*cSeqCar*/,/*cSeqEnt*/,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,1,lEstLib)
	EndIf
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} OMSEstSC9
Estorna SC9 posicionada da carga.
@author  Daniel Pereira
@version P12
@Since	04/12/2018
@version 1.0
/*/
//-----------------------------------------------------------
User Function OMSEstSC9()
Local lRet      := .T.
Local lEstLib   := SuperGetMV("MV_OMSESTP",.F.,.T.) .And. OmsPedCPL(SC9->C9_FILIAL,SC9->C9_PEDIDO)// Indica se estorna liberacao do pedido de vendas de uma carga ao dividir um item. Onde .T. (default) efetua o estorno. Quando integrado com o CPL o estorno da liberação não é permitida.
Local lOM200EST := ExistBlock("OM200EST")
Local aAreaSC5  := SC5->(GetArea())
Local cAliasSC5 := Nil

	cAliasSC5 := GetNextAlias()
	BeginSql Alias cAliasSC5
		SELECT SC5.R_E_C_N_O_ RECNOSC5
		FROM %Table:SC5% SC5
		WHERE SC5.C5_FILIAL = %Exp:SC9->C9_FILIAL%
		AND SC5.C5_NUM = %Exp:SC9->C9_PEDIDO%
		AND SC5.%NotDel%
	EndSql
	If (cAliasSC5)->(!Eof())
		SC5->(dbGoTo((cAliasSC5)->RECNOSC5))
		If lOM200EST
			ExecBlock("OM200EST",.F.,.F.)
		EndIf
		If lEstLib
			//-- Estorna liberacao do pedido de vendas
			a460Estorna()
		Else
			//-- Estornando a ordem de serviço do WMS
			If IntWms(SC9->C9_PRODUTO) .And. !Empty(SC9->C9_SERVIC)  .And. SC5->C5_GERAWMS <> "1"
				WmsUndoPed(SC9->(Recno()))
			EndIf
			//-- 8.Estorno Mont.Carga
			MaAvalSC9("SC9",8)
		EndIf
	EndIf
	(cAliasSC5)->(dbCloseArea())
	RestArea(aAreaSC5)
Return lRet

Static Function LogTempos(cCarga)
Local cDirLog  := SuperGetMV("MV_OMSLTGC",.F.,"")
Local nPosLog  := 0
Local cFileLog := ""
Local oFileLog := Nil
Local cMessage := ""
Local lRet     := .T.
Local nLastTempo := 0

	If !Empty(cDirLog) .And. Len(__aTempos) > 1

		cFileLog := cDirLog + cCarga + "-" + DtoS(Date()) + "-" + StrTran(Time(),":") + ".log"
		oFileLog := FWFileWriter():New(cFileLog,.F.)
		If !ExistDir(cDirLog)
			oFileLog:CreateDirectory()
		EndIf

		oFileLog:Create()
		// oFileLog:Open(FO_WRITE+FO_SHARED)

		For nPosLog := 1 to Len(__aTempos)
			cMessage := __aTempos[nPosLog,1] + Transform((__aTempos[nPosLog,2] - nLastTempo), "@E 999,999.999" ) + CRLF
			lRet := oFileLog:Write(cMessage)
			nLastTempo := __aTempos[nPosLog,2]
		Next
		oFileLog:Close()
	EndIf
Return
//-----------------------------------------------------------
/*/{Protheus.doc} Os200EnvML
Envia carga para roteirização com o Maplink.
@author  Daniel Pereira 
@version P12
@Since	25/06/2019
@version 1.0
/*/
//-----------------------------------------------------------
User Function Os200EnvML()
Local lRet    := .T.
Local aErrors := {}

	If OsRotMapLink(DAK->DAK_COD,@aErrors,.T.)
		OmsMessage(STR0283,OMSA20003) //Carga enviada para planejamento da roteirização.
	Else
		If !Empty(aErrors)
			OmsShowWng(aErrors)
		EndIF
	EndIf
Return lRet
//-----------------------------------------------------------
/*/{Protheus.doc} Os200VisML
Visualiza mapa da carga.
@author  Daniel Pereira 
@version P12
@Since	25/06/2019
@version 1.0
/*/
//-----------------------------------------------------------
User Function yOs200VisML()
Local lRet := .F.
	DK4->(DbSetOrder(1))
	If DK4->(DbSeek(xFilial("DK4")+DAK->DAK_COD))
		If (DK4->DK4_STATUS == "4")
			lRet := .T.
			OMSA205(DAK->DAK_COD)
		EndIf
	EndIf
	If !lRet
		OmsMessage(STR0284,OMSA20005) //Apenas cargas com status 4-Roteirizada podem ser visualizadas.
	EndIf
Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} Os200GWN
Fun?o para verificar se existe romaneio na GWN dentro do GFE
@author Daniel Pereira
@version P12
@Since	13/04/2020
@version 1.0
/*/
//-----------------------------------------------------------
Static Function Os200GWN(cCodCar, cSeqCar)
	Local lExitGWN	:= .F.
	Local cAliasGWN	:= GetNextAlias()
	Local cNrRom	:= cCodCar+cSeqCar

	BeginSql Alias cAliasGWN
		SELECT GWN.R_E_C_N_O_ RECNOGWN
		FROM %Table:GWN% GWN
		WHERE GWN.GWN_FILIAL = %xFilial:GWN%
		AND GWN.GWN_NRROM = %Exp:cNrRom%
		AND GWN.%NotDel%
	EndSql
	If (cAliasGWN)->(!Eof())
		GWN->(dbGoTo((cAliasGWN)->RECNOGWN))
		lExitGWN := .T.
	EndIf
	(cAliasGWN)->(dbCloseArea())
	
Return lExitGWN

//-----------------------------------------------------------
/*/{Protheus.doc} Oms200Sqe
Funcao para atualizar as sequencias na temporaria TRBPED
@author Daniel Pereir 
@version P12
@Since	04/06/2020
@version 1.0
/*/
//-----------------------------------------------------------
Static Function Oms200Sqe(aArrayMan)
Local aAreaTRB   := TRBPED->(GetArea())
Local nx         := 0
Local cSeekSeq   := ""

    For nx := 1 to Len(aArrayMan)
        cSeekSeq := aArrayMan[nx,2]+aArrayMan[nx,3]+aArrayMan[nx,4]+aArrayMan[nx,12]+aArrayMan[nx,5] //{ROTA,ZONA,SETOR,FILORI,PEDIDO

        DbSelectArea("TRBPED")
        TRBPED->(DbSetOrder(4))  //{"PED_ROTA","PED_ZONA","PED_SETOR","PED_FILORI","PED_PEDIDO"}
        TRBPED->(DbGoTop())
        
        If TRBPED->(MsSeek(cSeekSeq))
            Do While TRBPED->(!Eof()) .And. TRBPED->(PED_ROTA+PED_ZONA+PED_SETOR+PED_FILORI+PED_PEDIDO) == cSeekSeq
                RecLock("TRBPED",.F.)
                TRBPED->PED_SEQROT := aArrayMan[nx,1]
                MsUnlock()
                TRBPED->(DbSkip())
            EndDo
        EndIf
    Next nx  
   
    RestArea( aAreaTRB )

Return

//-----------------------------------------------------------
/*/{Protheus.doc} CRIADOCC()
Funcao para inclusão de documento de carga
@author daniel.pereira
@version P12
@Since	30/01/2021
@version 1.0
/*/
//-----------------------------------------------------------
USER FUNCTION CRIADOCC(_cpedido,cCarga,cSeqCar) 
Local aDadosFil := FWArrFilAtu()
Local CnpjEmp    := alltrim(aDadosFil[18])  //CGC da empresa  		   '77.765.840/0001-70'
Local CodEmit    := ''
Local c_Nota     := ''
Local aFilial    := {} 
Local cTransp    := '' 
AFilial := FWSM0Util():GetSM0Data() //Retorna todos os campos da SM0 do grupo e filial logados no sistema

/*,
DbSelectArea( "SM0" ) 
dbGoTop() 
SM0->(dbSetOrder(1)) 
While !SM0->( EOF() ) // Só adiciona no aRecnoSM0 se a empresa for diferente 
   If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
     .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0 aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } ) 
   EndIf 
   SM0->( dbSkip() ) 
End

SM0->( dbCloseArea() )
*/

aaDadosFil       := FWArrFilAtu()
CnpjEmp          := alltrim(aDadosFil[18])  //CGC da empresa  		   '77.765.840/0001-70'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o código do emitente       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CodEmit:=PegGu3(CnpjEmp)
	
c_nota :=  "" //SC6->C6_NOTA
DbSelectArea("SC6")
SC6->(DbSetOrder(1))
SC6->(DbGoTop())
if SC6->(DbSeek(xFilial("SC6")+_cPedido))
    Do while SC6->(!eof() .and. SC6->C6_NUM = _cPedido)
	    if c_nota <> SC6->C6_NOTA
			DbSelectArea("SF2")
			SF2->(DbGoTop())
			SF2->(DbSetOrder(1))
			if SF2->(DbSeek(xFilial("SF2")+SC6->C6_NOTA+SC6->C6_SERIE+SC6->C6_CLI+SC6->C6_LOJA)) 
				IF !U_vergw1(xFilial("GW1"),PADR(CodEmit,14),"NFS  ",PADR(SF2->F2_SERIE,3),PADR(SF2->F2_DOC,16))
					RecLock("GW1",.T.)
					//* incrementar aqui tabelas GW1 E GWN  
					Ccpj_Dest:= POSICIONE("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,'A1_CGC')
                    CodDest     := PegGu3(Ccpj_Dest)
	                CodEmit     := PegGu3(CnpjEmp)
					GW1->GW1_FILIAL  := xFilial("GW1")
					GW1->GW1_CDTPDC  := "NFS"
					GW1->GW1_EMISDC  := CodEmit
					GW1->GW1_DTEMIS  := SF2->F2_EMISSAO
					GW1->GW1_SERDC   := SF2->F2_SERIE
					GW1->GW1_NRDC    := SF2->F2_DOC  
					GW1->GW1_ORIGEM  := "2"
					GW1->GW1_SIT     := "1"
					GW1->GW1_CDREM   := CodEmit    
					GW1->GW1_CDDEST  := CodDest //SF2->F2_CLIENTE
					GW1->GW1_TPFRET  := IIF(SF2->F2_TPFRETE = "C","2" ,"1")   //C = CIF  F = FOB
					GW1->GW1_NRROM   := cCarga+cSeqCar 
					GW1->GW1_DTIMPL  := DDATABASE
					GW1->GW1_HRIMPL  := TIME()
					GW1->GW1_ENVEDI   := "2" 
					GW1->GW1_USO     := "1"
					GW1->GW1_DSESP   := "" 
					GW1->GW1_QTVOL   :=  SF2->F2_VOLUME1       
					GW1->GW1_CARREG  := ""
					GW1->GW1_REGCOM  := ""
					GW1->GW1_REPRES  := ""
					GW1->GW1_ICMSDC  := iif(SF2->F2_VALICM = 0 ,"2","1" )
					GW1->GW1_ORINR   := ""
					GW1->GW1_ORISER  := ""
					GW1->GW1_ENTEND  := ""
					GW1->GW1_ENTBAI  := ""
					GW1->GW1_ENTCEP  := ""
					GW1->GW1_ENTNRC  := ""
					GW1->GW1_USUIMP  := 'USUARIOS' 
					GW1->GW1_DTLIB   := DDATABASE
					GW1->GW1_HRLIB   := TIME()
					GW1->GW1_AUTSEF  := "1"
				    GW1->GW1_CALCAT  := "1"
					GW1->GW1_SITFT   := "1"
					GW1->GW1_SITFT2  := "1" 
					GW1->GW1_SITFRE  := "6" 
                    GW1->GW1_DANFE   := SF2->F2_CHVNFE
					//GW1_DTPSAI  := ""
					//GW1_HRPSAI  := ""
					//GW1_DTSAI   := ""
					//GW1_HRSAI   := ""
					//GW1_DTPENT  := ""
					//GW1_HRPENT  := ""
					//GW1_DTALT   := ""
					//GW1_HRALT   := ""
					//GW1_USUALT  := ""
					//GW1_DTCAN   := ""
					//GW1_HRCAN   := ""
					//GW1_USUCAN  := ""
					//
					//GW1_ROMTV   := ""
					//GW1_MOTFT   := "" 
					//GW1_ROMCF   := ""   
					//GW1_ROMTO   := ""  
					//GW1_MOTFT2  := ""
					//GW1_PEDCLI  := ""  
					//GW1_NRREG   := ""
					//GW1_MOTFRE  := ""
					//GW1_DTFRE   := ""
					GW1->GW1_SDOC    := SF2->F2_SERIE
					//GW1_SDOCOR  := ""
					//D_E_L_E_T_  := R_E_C_N_O_   R_E_C_D_E_L_
					GW1->(MsUnlock())   
					GW1->(FkCommit())
					Ccpj_Dest:= POSICIONE("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,'A1_CGC')
                    CodDest     := PegGu3(Ccpj_Dest)
	                CodEmit     := PegGu3(CnpjEmp)
					cTransp:=  PegGu3(posicione("SA4",1,XFILIAL("SA4")+SF2->F2_TRANSP,"A4_CGC"))
	                RecLock("GWU",.T.)
					
					GWU->GWU_FILIAL :=  xFilial("GWU")
					GWU->GWU_CDTPDC :=  "NFS"  
					GWU->GWU_EMISDC :=  CodEmit
					GWU->GWU_SEQ    :=  "01"
					GWU->GWU_SERDC  := SF2->F2_SERIE
					GWU->GWU_NRDC   := SF2->F2_DOC    
					GWU->GWU_CDTRP  := cTransp 
					GWU->GWU_NRCIDO := AFilial[20][2] //'CIDADE ORIGINAL' 
					GWU->GWU_CEPO   := AFilial[19][2] //'--  CEP'
					GWU->GWU_NRCIDD := POSICIONE("SA1",1,XFILIAL("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_COD_MUN") //'-- CIDADE DESTINO '
					GWU->GWU_CEPD   := POSICIONE("SA1",1,XFILIAL("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_CEP")  
					GWU->GWU_CDTPVC :=  ''
					GWU->GWU_CDCLFR :=  ''
					GWU->GWU_CDTPOP :=  ''
					GWU->GWU_PAGAR  := "2"
					//GWU_DTPENT := CTOD(SPACE(08)
					//GWU_HRPENT := ''
					//GWU_DTENT  := CTOD(SPACE(08)
					//GWU_HRENT  := ''
					//GWU_CHVEXT := '' 
					GWU->GWU_SDOC   :=  SF2->F2_SERIE
					
                    GWU->(MsUnlock())   
					GWU->(FkCommit())

					DbSelectArea("SD2")
					SD2->(DbSetOrder(3))
					if SD2->(DbSeek(xFilial("SD2")+SC6->C6_NOTA+SC6->C6_SERIE+SC6->C6_CLI+SC6->C6_LOJA)) 
						do while SD2->(!eof() .and. SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA = SC6->C6_NOTA+SC6->C6_SERIE+SC6->C6_CLI+SC6->C6_LOJA )   		   
							RecLock("GW8",.T.)
							//* incrementar aqui tabelas GW8   
							Ccpj_Dest:= POSICIONE("SA1",1,xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA,'A1_CGC')
                            CodDest     := PegGu3(Ccpj_Dest)
	                        CodEmit    := PegGu3(CnpjEmp)
							GW8->GW8_FILIAL := XFILIAL("GW8")
							GW8->GW8_CDTPDC := "NFS"
							GW8->GW8_EMISDC := CodEmit
							GW8->GW8_SERDC  := SD2->D2_SERIE
							GW8->GW8_NRDC   := SD2->D2_DOC  
							GW8->GW8_SEQ    := SD2->D2_ITEM
							GW8->GW8_ITEM   := SD2->D2_COD     
							GW8->GW8_DSITEM := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")                                
							GW8->GW8_CDCLFR := "001" 
							GW8->GW8_QTDE   := SD2->D2_QUANT 
							GW8->GW8_VALOR  := SD2->D2_TOTAL      
							GW8->GW8_VOLUME := 0   
							GW8->GW8_PESOR  := SD2->D2_PESO
							GW8->GW8_PESOC  := 0 
							GW8->GW8_QTDALT := SD2->D2_PESO
							GW8->GW8_INFO1  := ""
							GW8->GW8_INFO2  := ""
							GW8->GW8_INFO3  := ""
							GW8->GW8_INFO4  := ""
							GW8->GW8_INFO5  := ""
							GW8->GW8_UNINEG := ""
							GW8->GW8_RATEIO := "1"
							GW8->GW8_TPITEM := ""
							GW8->GW8_TRIBP  := iif(SD2->D2_VALCOF=0,"2","1" )
							GW8->GW8_ATUATF := "N"
							GW8->GW8_CFOP   := SD2->D2_CF
							GW8->GW8_CRDICM := "1"
							GW8->GW8_DIFICM :=  0        
							GW8->GW8_VALLIQ :=  0     
							GW8->GW8_UNIMED := ''
							GW8->GW8_SDOCDC := SD2->D2_SERIE
    						GW8->(MsUnlock())   
					        GW8->(FkCommit())
							SD2->(DbSkip())

						EndDo	
					Endif
				Else
				    dbselectArea("GW1") 

				    GW1->(RecLock("GW1",.F.))
				    //   GRAVAR AQUI 
				    GW1->GW1_NRROM   := cCarga+cSeqCar 	
				    GW1->(MsUnlock())   
			        GW1->(FkCommit())
				    dbselectArea("GWU") 
					GWU->(DbSetOrder(1))
					GWU->(DbGoTop())
				    //GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ 
					//GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ
					CodEmit     := PegGu3(CnpjEmp)
				    If !GWU->(DbSeek(xFilial("GWU")+PADR("NFS",5)+PADR(CodEmit,14)+PADR(SF2->F2_SERIE,3)+PADR(SF2->F2_DOC,16)+"01" )) 
				   	    Ccpj_Dest:= POSICIONE("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,'A1_CGC')
                        CodDest     := PegGu3(Ccpj_Dest)
	                    CodEmit     := PegGu3(CnpjEmp)
					    cTransp:=  PegGu3(posicione("SA4",1,XFILIAL("SA4")+SF2->F2_TRANSP,"A4_CGC"))
					    GWU->(RecLock("GWU",.T.))
  					    GWU->GWU_FILIAL :=  xFilial("GWU")
						GWU->GWU_CDTPDC :=  "NFS"  
						GWU->GWU_EMISDC :=  CodEmit
						GWU->GWU_SEQ    :=  "01"
						GWU->GWU_SERDC  := SF2->F2_SERIE
						GWU->GWU_NRDC   := SF2->F2_DOC    
						GWU->GWU_CDTRP  := cTransp 
						GWU->GWU_NRCIDO := AFilial[20][2] //'CIDADE ORIGINAL' 
						GWU->GWU_CEPO   := AFilial[19][2] //'--  CEP'
						GWU->GWU_NRCIDD := POSICIONE("SA1",1,XFILIAL("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_COD_MUN") //'-- CIDADE DESTINO '
						GWU->GWU_CEPD   := POSICIONE("SA1",1,XFILIAL("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_CEP")  
						GWU->GWU_CDTPVC :=  ''
						GWU->GWU_CDCLFR :=  ''
						GWU->GWU_CDTPOP :=  ''
						GWU->GWU_PAGAR  := "2"
						//GWU_DTPENT := CTOD(SPACE(08)
						//GWU_HRPENT := ''
						//GWU_DTENT  := CTOD(SPACE(08)
						//GWU_HRENT  := ''
						//GWU_CHVEXT := '' 
						GWU->GWU_SDOC   :=  SF2->F2_SERIE
						
						GWU->(MsUnlock())   
						GWU->(FkCommit())

						DbSelectArea("SD2")
						SD2->(DbGoTop())
						SD2->(DbSetOrder(3))
						if SD2->(DbSeek(xFilial("SD2")+SC6->C6_NOTA+SC6->C6_SERIE+SC6->C6_CLI+SC6->C6_LOJA)) 
							do while SD2->(!eof() .and. SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA = SC6->C6_NOTA+SC6->C6_SERIE+SC6->C6_CLI+SC6->C6_LOJA )   		   
								Ccpj_Dest:= POSICIONE("SA1",1,xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA,'A1_CGC')
								CodDest     := PegGu3(Ccpj_Dest)
								CodEmit    := PegGu3(CnpjEmp)
								//GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC+GW8_SEQ --uNICO E ORDEM 2 
								//
							    GW8->(DbSetOrder(2))
								GW8->(DbGoTop())
								IF GW8->(!DbSeek(xFilial("GW8")+PADR("NFS",5)+PADR(CodEmit,14)+PADR(SD2->D2_SERIE,3)+PADR(SD2->D2_DOC,16)+PADR(SD2->D2_ITEM,16)))
									RecLock("GW8",.T.)
									//* incrementar aqui tabelas GW8   
									GW8->GW8_FILIAL := XFILIAL("GW8")
									GW8->GW8_CDTPDC := "NFS"
									GW8->GW8_EMISDC := CodEmit
									GW8->GW8_SERDC  := SD2->D2_SERIE
									GW8->GW8_NRDC   := SD2->D2_DOC  
									GW8->GW8_SEQ    := SD2->D2_ITEM
									GW8->GW8_ITEM   := SD2->D2_COD     
									GW8->GW8_DSITEM := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")                                
									GW8->GW8_CDCLFR := "001" 
									GW8->GW8_QTDE   := SD2->D2_QUANT 
									GW8->GW8_VALOR  := SD2->D2_TOTAL      
									GW8->GW8_VOLUME := 0   
									GW8->GW8_PESOR  := SD2->D2_PESO
									GW8->GW8_PESOC  := 0 
									GW8->GW8_QTDALT := SD2->D2_PESO
									GW8->GW8_INFO1  := ""
									GW8->GW8_INFO2  := ""
									GW8->GW8_INFO3  := ""
									GW8->GW8_INFO4  := ""
									GW8->GW8_INFO5  := ""
									GW8->GW8_UNINEG := ""
									GW8->GW8_RATEIO := "1"
									GW8->GW8_TPITEM := ""
									GW8->GW8_TRIBP  := iif(SD2->D2_VALCOF=0,"2","1" )
									GW8->GW8_ATUATF := "N"
									GW8->GW8_CFOP   := SD2->D2_CF
									GW8->GW8_CRDICM := "1"
									GW8->GW8_DIFICM :=  0        
									GW8->GW8_VALLIQ :=  0     
									GW8->GW8_UNIMED := ''
									GW8->GW8_SDOCDC := SD2->D2_SERIE
									GW8->(MsUnlock())   
									GW8->(FkCommit())
								EndIf	
								SD2->(DbSkip())
							EndDo
						endif	
					EndIf	
				EndIf
			Endif
		Endif
        c_nota :=  SC6->C6_NOTA       
 	    SC6->(DbSkip())
    EndDo
Endif

return() 

//-----------------------------------------------------------
/*/{Protheus.doc} CRIADOCC()
Funcao para pesquisa de documento de carga
@author daniel.pereira
@version P12
@Since	30/01/2021
@version 1.0
/*/
//-----------------------------------------------------------
User Function vergw1(CFilial,cEmitente,cTipo,cSerie,cDoc)
Local lRet := .t. 
DbSelectArea("GW1")
GW1->(DbGoTop())
GW1->(DbSetOrder(1))
if GW1->(DbSeek(CFilial+PADR(cTipo,5)+PADR(+cEmitente,14)+PADR(cSerie,3)+PADR(cDoc,16))) 
   lRet := .t.
Else 
   lRet := .f.
Endif
Return(lRet)   
//-----------------------------------------------------------
/*/{Protheus.doc} CRIADOCC()
Funcao para Verificar o código do emitente/remetente e destinatário 
            referente a tabela de emitentes do GFE
@author daniel.pereira
@version P12
@Since	30/01/2021
@version 1.0
/*/
//-----------------------------------------------------------
Static Function PegGu3(_Cnpj) 
Local cRet:= ''
Local cAliasGU3	 := GetNextAlias()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o código do emitente/remetente e destinatário        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	BeginSql Alias cAliasGU3
		SELECT GU3.GU3_IDFED,GU3_CDEMIT
		FROM %Table:GU3% GU3
		WHERE GU3.GU3_FILIAL = %Exp:xFilial("GU3")%
		AND GU3.GU3_IDFED = %Exp:_Cnpj%
		AND GU3.%NotDel%
	EndSql
	If (cAliasGU3)->(!Eof())
        cRet  :=   (cAliasGU3)->GU3_CDEMIT
    ELSE 
	    cRet  := "Sem Reg. GU3  " 
	EndIF

Return(cRet) 
