#Include "Protheus.ch"
#Include "TopConn.ch"
#Define STR_PULA        Chr(13)+ Chr(10)
/*                                                                                            
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina 								                 !
+------------------+---------------------------------------------------------+
!Modulo            ! Faturamento                                             !
+------------------+---------------------------------------------------------+
!Nome              ! OMS105.PRW                                              !
+------------------+---------------------------------------------------------+
!Descricao         ! Tela customizada Pedido de venda x transportadora       !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos de Andrade                                   !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 17/12/2020                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/
User Function OMS105()
	Local cQry := ""
	LOCAL aCores  := {{ 'ZA7_STATUS=="1"' , 'ENABLE'  },;    // Ativo
	{ 'ZA7_STATUS=="2"' , 'DISABLE' },;
		{ 'ZA7_STATUS=="3"' , 'BR_AZUL' },;
		{ 'ZA7_STATUS=="4"' , 'BR_BRANCO' },;
		{ 'ZA7_STATUS=="5"' , 'BR_AMARELO' },;
		{ 'ZA7_STATUS=="6"' , 'BR_PRETO' }}
	Local cFiltro := ""
	Private cCadastro 	:= "Envio EDI Transportadoras"
	Private aRotina1  := {{ "Geração Manual","U_OMS106F()"	,0,2,0},;
		{ "Geração Autom." ,"U_OMS106A()"	,0,2,0}}
	Private aRotina		:=  {{OemToAnsi("Pesquisar"),"AxPesqui",0,1,0,.F.},;	//"Pesquisar"
	{OemToAnsi("Visualizar"),"U_OMS105G(2)",0,2,0,nil},;	//"Visualizar"
	{OemToAnsi("Incluir"),"U_OMS105G(3)",0,3,0,nil},; //"Incluir"
	{OemToAnsi("Alterar"),"U_OMS105G(4)",0,4,0,nil},; //"Alterar"
	{OemToAnsi("Excluir"),"U_OMS105G(5)",0,5,0,nil},; //"Excluir"
	{OemToAnsi("Legenda"),"U_OMS105L()",0,6,0,nil},; //Legenda
	{OemToAnsi("EDI Transportadoras"),"U_OMS100T()",0,7,0,nil},; //Envio EDI
	{OemToAnsi("EDI Retorno"),"U_OMS100RE()",0,7,0,nil},; //Envio EDI
	{OemToAnsi("Cancelar EDI"),"U_OMS100C()",0,8,0,nil},; //cANCELAR EDI
	{OemToAnsi("Ger.Nf's"),aRotina1		,0,9,0}}

	dbSelectArea("ZA7")
	dbSetOrder(1)

	//Selecionando os dados
	cQry := " SELECT ZA7.R_E_C_N_O_ FROM "+RetSQLName('ZA7')+" ZA7 "
	cQry += " INNER JOIN ( SELECT DISTINCT ZA72.ZA7_CODIGO AS PEDIDO, ( "
	cQry += " SELECT TOP 1 ZA71.ZA7_ITEM FROM "+RetSQLName('ZA7')+" ZA71 "
	cQry += " WHERE ZA71.ZA7_FILIAL = ZA72.ZA7_FILIAL "
	cQry += " AND ZA71.ZA7_CODIGO = ZA72.ZA7_CODIGO "
	cQry += " AND ZA71.D_E_L_E_T_ = ' ' "
	cQry += " ORDER BY ZA71.ZA7_ITEM DESC) AS ULT_ITEM "
	cQry += " FROM "+RetSQLName('ZA7')+" ZA72 "
	cQry += " WHERE ZA72.ZA7_FILIAL = '"+FWxFilial('ZA7')+"' "
	cQry += " AND ZA72.D_E_L_E_T_ = ' ' ) TAB_AUX ON (ZA7.ZA7_CODIGO  = TAB_AUX.PEDIDO "
	cQry += " AND ZA7.ZA7_ITEM = TAB_AUX.ULT_ITEM ) "
	cQry += " WHERE ZA7.ZA7_FILIAL = '"+FWxFilial('ZA7')+"' "
	cQry += " AND ZA7.D_E_L_E_T_ = ' ' "
	cFiltro :=  "R_E_C_N_O_ IN ("+cQry+")"
	mBrowse( 6 , 1 , 22 , 75 , "ZA7" , NIL , NIL , NIL , NIL , NIL , aCores , NIL , NIL , NIL , NIL , NIL , NIL , NIL , cFiltro )

Return( NIL )


	//mBrowse(006,001,022,075,"ZA7")

	dbSelectArea("ZA7")
	dbClearFilter()
	dbSetOrder(1)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} OMS105G
Rotina de grava?o(inclusao, altera?o , exclusao)

@author Jair Matos
@since 17/12/2020
@version P12
@return Nil
/*/
//---------------------------------------------------------------------

User Function OMS105G(nOpcX)

	Local aArea		:= ZA7->(GetArea())
	Local aSizeAut	:= MsAdvSize(,.F.)
	Local aObjects	:= {}
	Local aInfo 	:= {}
	Local aPosObj	:= {}
	Local aNoFields := {"ZA7_NOMTRA","ZA7_CODIGO"}
	Local cSeek     := ""
	Local cWhile    := ""
	Local nSaveSX8  := GetSX8Len()
	Local nOpcA     := 0
	Local lNDLVisual:= .F.
	Local lNDLInclui:= .F.
	Local lNDLDeleta:= .F.
	Local lNDLAltera:= .F.
	Local lGravaOK  := .T.
	Local oDlg
	Local oGetDados
	Private cCodEdi := SPACE(TamSx3("ZA7_CODEDI")[1])
	Private oGetEDI
	Private cNDLNum	:= CriaVar("ZA7_CODIGO")
	Private cCodTrans:= CriaVar("ZA7_TRANSP")
	Private aHeader := {}
	Private aCols   := {}

//??????????????????????????????
//?Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ?
//??????????????????????????????
	If     aRotina[nOpcX][4] == 2
		lNDLVisual := .T.
	ElseIf aRotina[nOpcX][4] == 3
		lNDLInclui	:= .T.
	ElseIf aRotina[nOpcX][4] == 4
		lNDLAltera	:= .T.
	ElseIf aRotina[nOpcX][4] == 5
		lNDLDeleta	:= .T.
		lNDLVisual	:= .T.

	EndIf

	If (ZA7->ZA7_STATUS) <>'1' .and. lNDLAltera
		HELP(' ',1,'Atenção!',,"Não é permitido alterar esta carga ",1,0, NIL, NIL, NIL, NIL, NIL, {"Retorne a carga para o STATUS = 1-VERDE"})
		Return
	EndIf

	If (ZA7->ZA7_STATUS) !="1" .and. lNDLDeleta
		HELP(' ',1,'Atenção!',,"Não é permitido excluir esta carga ",1,0, NIL, NIL, NIL, NIL, NIL, {"Altere o STATUS do cadastro para 1=VERDE"})
		Return
	EndIf
//??????????????????????????????
//?Monta aHeader e aCols utilizando a funcao FillGetDados.  ?
//??????????????????????????????
	If lNDLInclui
		//?????????????????????????????????????????????????????????????????????????????????????????????????????????????
		//?Sintaxe da FillGetDados(/*nOpcX*/,/*Alias*/,/*nOrdem*/,/*cSeek*/,/*bSeekWhile*/,/*uSeekFor*/,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/) |
		//?????????????????????????????????????????????????????????????????????????????????????????????????????????????
		FillGetDados(nOpcX,"ZA7",1,,,,aNoFields,,,,,.T.,,,)
		aCols[1][aScan(aHeader,{|x| Trim(x[2])=="ZA7_ITEM"})] := StrZero(1,Len(ZA7->ZA7_ITEM))

	Else
		cNDLNum := ZA7->ZA7_CODIGO
		cCodTrans:= ZA7->ZA7_TRANSP
		cCodEdi:= ZA7->ZA7_CODEDI
		cSeek   := xFilial("ZA7")+ZA7->ZA7_CODIGO
		cWhile  := "ZA7->ZA7_FILIAL+ZA7->ZA7_CODIGO"
		//?????????????????????????????????????????????????????????????????????????????????????????????????????????????
		//?Sintaxe da FillGetDados(/*nOpcX*/,/*Alias*/,/*nOrdem*/,/*cSeek*/,/*bSeekWhile*/,/*uSeekFor*/,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/) |
		//?????????????????????????????????????????????????????????????????????????????????????????????????????????????
		FillGetDados(nOpcX,"ZA7",1,cSeek,{|| &cWhile },,aNoFields,,,,,,,,)
	EndIf

	AAdd( aObjects, { 000, 040, .T., .F. })
	AAdd( aObjects, { 100, 100, .T., .T. })
	aInfo  := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
	aPosObj:= MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE "Pedido de Venda X Transportadoras" From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	@ 038,010 SAY   "Numero"  OF oDlg PIXEL //"N?ero"
	@ 036,040 MSGET cNDLNum  PICTURE PesqPict("ZA7","ZA7_CODIGO") VALID ANumero() .And. CheckSX3("ZA7_CODIGO") WHEN lNDLInclui .And. VisualSX3("ZA7_CODIGO") OF oDlg PIXEL SIZE 30,10 RIGHT
	@ 038,080 SAY   "Transportadora"  OF oDlg PIXEL  //"Descricao"
	@ 036,125 MSGET cCodTrans PICTURE PesqPict("ZA7","ZA7_TRANSP")VALID PREDI(cCodTrans) F3 "SA4"  WHEN !lNDLVisual .And. VisualSX3("ZA7_TRANSP") OF oDlg PIXEL
	@ 038,170 SAY   "Código EDI"  OF oDlg PIXEL
	@ 036,205 MSGET oGetEDI VAR cCodEdi PICTURE PesqPict("ZA7","ZA7_CODEDI") VALID ANumero() .and. CheckSX3("ZA7_CODEDI")  WHEN .F.  .and. VisualSX3("ZA7_CODEDI") OF oDlg PIXEL
	@ 036,300 BUTTON oBtnVisu PROMPT "Selecionar Pedidos" SIZE 050,013 WHEN !lNDLVisual  OF oDlg ACTION(U_ChamaMARK()) PIXEL

	oGetDados := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcX,"U_AN2LinOK()","U_AN2TudOK()","+ZA7_ITEM",!lNDLVisual,,,,250)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, IIf(oGetdados:TudoOk(),(nOpcA := 1,oDlg:End()),nOpcA := 0)},{||oDlg:End()})

	If nOpcA == 1
		If lNDLInclui .Or. lNDLAltera .Or. lNDLDeleta
			If !(Len(aCols) == 1 .AND. Empty(aCols[1][2]))//Verifica se existe registro para ser gravado
				lGravaOk := OMS105GR(lNDLDeleta)
				If lGravaOk
					EvalTrigger()
					If lNDLInclui
						While ( GetSX8Len() > nSaveSX8 )
							ConFirmSX8()
						EndDo
						//Grava na tabela de log os dados
						DbSelectArea("ZA6")
						ZA6->(DbSetOrder(1))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
						ZA6->(DbGoTop())
						If !ZA6->(dbSeek(xFilial("ZA6")+cNDLNum))
							RecLock('ZA6', .T.)
							ZA6_FILIAL  := xFilial("ZA6")
							ZA6_CODIGO  := cNDLNum//CODIGO DA MONTAGEM DA CARGA
							ZA6_TIPO   	:= "1" //1=ENVIO - 2=RECEBIMENTO
							ZA6_ORIGEM  := Funname()
							ZA6_DATA    := DATE()
							ZA6_HRTRA   := TIME()
							ZA6_USERTR  := UsrFullName(__cUserId)
							ZA6_STATUS  := "1"
							ZA6_TOMOV   := "4"//1=GERACAO TXT; 2=ENVIO TXT
							ZA6_MSG   	:= "Carga "+cNDLNum+" foi gerada com sucesso. "+dtoc(date())+" / "+time()+CHR(13)+CHR(10)
							ZA6_TRANSP  := cCodTrans
							ZA6->(MsUnlock())
						EndIf
					EndIf
				Else
					Help(" ",1,"A085NAOREG")
					While ( GetSX8Len() > nSaveSX8 )
						RollBackSX8()
					EndDo
				EndIf
			EndIf
		EndIf
	Endif

	RestArea(aArea)

Return( MbrChgLoop( .F. ) )


User Function AN2LinOK()

	Local lRet := .T.

Return lRet


User Function AN2TudOK()

	Local lRet := .T.

Return lRet

Static Function ANumero()

	Local lRet := .T.

	If Empty(cNDLNum)
		Help(" ",1,"VAZIO")
		lRet := .F.
	EndIf

Return lRet

Static Function OMS105GR(lNDLDeleta)

	Local nPosITTEM := aScan(aHeader,{|x| AllTrim(x[2]) == "ZA7_ITEM"})
	Local ni       := 0
	Local nCount	:= 0

	dbSelectArea("ZA7")
	ZA7->(dbSetOrder(1))

	For ni:=1 To Len(aCols)
		If (!aCols[ni][Len(aHeader)+1]) .AND. (!Empty(aCols[ni][2]))
			//Verifica se registro Existe. Se existir, altera
			If ZA7->(dbSeek(xFilial("ZA7")+cNDLNum+aCols[nI][nPosITTEM]))
				RecLock("ZA7",.F.)
			Else
				RecLock("ZA7",.T.)
			EndIf
			If !lNDLDeleta
				nCount++
				ZA7->ZA7_FILIAL := xFilial("ZA7")
				ZA7->ZA7_CODIGO := cNDLNum
				ZA7->ZA7_TRANSP := cCodTrans
				ZA7->ZA7_ITEM 	:= Strzero(nCount,3,0)
				ZA7->ZA7_PEDIDO := aCols[ni][2]
				ZA7->ZA7_ITEMPD := aCols[ni][3]
				ZA7->ZA7_CODEDI  := cCodEdi
				ZA7->ZA7_QUANT  := aCols[ni][4]
				ZA7->ZA7_DATA  := aCols[ni][5]
				ZA7->ZA7_HORA  := aCols[ni][6]
				ZA7->ZA7_PRODUT  := aCols[ni][7]
				ZA7->ZA7_DESPRO  := aCols[ni][8]
				ZA7->ZA7_PESOL  := aCols[ni][9]
				ZA7->ZA7_PESOB  := aCols[ni][10]
				ZA7->ZA7_STATUS  := "1"
			Else
				ZA7->(dbDelete())
			EndIf
		Else
			If ZA7->(dbSeek(xFilial("ZA7")+cNDLNum+aCols[nI][nPosITTEM]))
				RecLock("ZA7",.F.)
				ZA7->(dbDelete())
			EndIf
		EndIf
	Next
	ZA7->(MsUnLock())

Return .T.
/*---------------------------------------------------------------------*
| Func:  ChamaMARK                                                    |
| Autor: Jair Matos                                                   |
| Data:  28/04/2017                                                   |
| Desc:  Função para selecionar iTENS                                 |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/
User Function ChamaMARK()
	U_ChMARK("SC9", {"C9_PEDIDO","C9_ITEM","C9_CLIENTE","C9_LOJA","C9_PRODUTO","C6_DESCRI","C9_QTDLIB","C5_PESOL","C5_PBRUTO","C5_NOTA"}, "", TamSx3("C9_PEDIDO")[1], "C9_PEDIDO", .T., ";")
Return

User Function ChMARK(cAliasM, aCamposM, cFiltroM, nTamanM, cCheckM, lEditM, cSepM, lAllFilM)
Local cFilBkp := cFilAnt
Local aAreaM0 := SM0->(GetArea())
Local aArea := GetArea()
Local nTamBtn := 50
Local cFiltro     := ""
//Defaults
Default cAliasM     := ""
Default aCamposM    := {}
Default cFiltroM    := ""
Default nTamanM     := 99
Default cCheckM     := ""
Default lEditM      := .F.
Default cSepM       := ";"
Default lAllFilM    := .T.
//Privates
Private cAliasPvt   := cAliasM
Private cJoinSC5   := ""
Private aCampos     := aCamposM
Private nTamanRet   := nTamanM
Private cCampoRet   := cCheckM
Private lAllFil     := .T.
//MsSelect
Private oMAux
Private cArqs
Private cMarca := "OK"
Private aStrut := {}
Private aHeadRegs := {}
Private cAliasTmp:="CHK_"+RetCodUsr()
//Tamanho da janela
Private nJanLarg := 0800
Private nJanAltu := 0500
//Gets e Dialog
Private oDlgMark
Private oGetPesq, cGetPesq := Space(100)
//Retorno
Private lRetorn := .F.
Public  __cRetorn := Space(nTamanM)

	cJoinSC5 := " JOIN "+RetSQLName("SC5")+" SC5 ON C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO "
	cJoinSC5 += " AND C5_TRANSP='"+cCodTrans+"' AND SC5.D_E_L_E_T_ ='' AND C5_NOTA='' " 
	cJoinSC5 += " JOIN "+RetSQLName("SC6")+" SC6 ON C6_FILIAL = C9_FILIAL AND C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM AND SC6.D_E_L_E_T_ ='' "

	cFiltro += " AND NOT EXISTS(SELECT * FROM "+RetSQLName("ZA7")+"  ZA7 "
	cFiltro += " WHERE ZA7_PEDIDO =C9_PEDIDO  AND ZA7_ITEMPD = C9_ITEM AND ZA7.D_E_L_E_T_ =''
	cFiltro += " AND ZA7_STATUS !='2')

//Criando a estrutura para a MsSelect
fCriaMsSel()

//Criando a janela
DEFINE MSDIALOG oDlgMark TITLE "Consulta de Dados" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
//Pesquisar
@ 003, 003 GROUP oGrpPesqui TO 025, (nJanLarg/2)-3 PROMPT "Pesquisar: " OF oDlgMark COLOR 0, 16777215 PIXEL
@ 010, 006 MSGET oGetPesq VAR cGetPesq SIZE (nJanLarg/2)-12, 010 OF oDlgMark COLORS 0, 16777215  VALID (fVldPesqG(cFiltro))      PIXEL

//Dados
@ 028, 003 GROUP oGrpDados TO (nJanAltu/2)-28, (nJanLarg/2)-3 PROMPT "Dados: "  OF oDlgMark COLOR 0, 16777215 PIXEL
oMAux := MsSelect():New( cAliasTmp, "XX_OK",, aHeadRegs,, cMarca, { 035, 006, (nJanAltu/2)-28-028, (nJanLarg/2)-6 } ,,, )
oMAux:bAval := { || ( fGetMkA( cMarca ), oMAux:oBrowse:Refresh() ) }
oMAux:oBrowse:lHasMark := .T.
oMAux:oBrowse:lCanAllMark := .F.

//Populando os dados da MsSelect
fPopulaG(cFiltro)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botoes                                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lCheck := .f.
oCheck := IW_CheckBox((nJanAltu/2)-45,005,"Marca/Desmarca Todos","lCheck")
oCheck:bChange := {|| MsAguarde( {|| OMS105M() } ) }

//Ações
@ (nJanAltu/2)-25, 003 GROUP oGrpAcoes TO (nJanAltu/2)-3, (nJanLarg/2)-3 PROMPT "Ações: "   OF oDlgMark COLOR 0, 16777215 PIXEL
@ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*1)+06) BUTTON oBtnConf PROMPT "Confirmar" SIZE nTamBtn, 013 OF oDlgMark ACTION(fConfirmG(cAliasM))     PIXEL
//@ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*2)+09) BUTTON oBtnLimp PROMPT "Limpar" SIZE nTamBtn, 013 OF oDlgMark ACTION(fLimparG())     PIXEL
@ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*2)+09) BUTTON oBtnCanc PROMPT "Cancelar" SIZE nTamBtn, 013 OF oDlgMark ACTION(fCancelaG())     PIXEL

oMAux:oBrowse:SetFocus()
//Ativando a janela
ACTIVATE MSDIALOG oDlgMark CENTERED

cFilAnt := cFilBkp
RestArea(aArea)
RestArea(aAreaM0)
Return lRetorn

/*---------------------------------------------------------------------*
| Func:  fCriaMsSel                                                   |
| Autor: Jair Matos                                                |
| Data:  28/04/2017                                                   |
| Desc:  Função para criar a estrutura da MsSelect                    |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function fCriaMsSel()
Local aAreaX3 := SX3->(GetArea())
Local nAtual := 0
Local cAliasPic := ""

//Zerando o cabeçalho e a estrutura
aHeadRegs := {}
aStrut := {}

//Adicionando coluna de OK
//                  Campo           Titulo      Mascara
aAdd( aHeadRegs, {  "XX_OK",    ,   " ",        "" } )

//              Campo       Tipo    Tamanho     Decimal
aAdd( aStrut, { "XX_OK",    "C",    002,        000} )

DbSelectArea("SX3")
SX3->(DbSetOrder(2)) // Campo
SX3->(DbGoTop())

//Percorrendo os campos
	For nAtual := 1 To Len(aCampos)
	cCampoAtu := aCampos[nAtual]
	
	//Se coneguir posicionar no campo
		If SX3->(DbSeek(cCampoAtu))
			If Substr(cCampoAtu,1,2)=="C5"
		cAliasPic := "SC5"
			ElseIf Substr(cCampoAtu,1,2)=="C6"
		cAliasPic := "SC6"
			Else
		cAliasPic := "SC9"
			Endif
		//                  Campo           Titulo      Mascara
		aAdd( aHeadRegs, {  cCampoAtu,  ,   X3Titulo(), PesqPict(cAliasPic  , cCampoAtu) } )
		
		//              Campo       Tipo            Tamanho                 Decimal
		aAdd( aStrut, { cCampoAtu,  SX3->X3_TIPO,    TamSX3(cCampoAtu)[01],  TamSX3(cCampoAtu)[02]} )
		EndIf
	Next

//                      Campo               Titulo          Mascara
aAdd( aHeadRegs, {  "XX_RECNUM",    ,   "RecNo",        "" } )

//                  Campo           Tipo    Tamanho     Decimal
aAdd( aStrut, { "XX_RECNUM",    "C",    18,             0} )

//Excluindo dados da tabela temporária, se tiver aberta, fecha a tabela
	If Select(cAliasTmp)>0
	(cAliasTmp)->(DbCloseArea())
	EndIf
fErase(cAliasTmp+".DBF")

//Criando tabela temporária
cArqs:= CriaTrab( aStrut, .T. )
dbUseArea( .T.,"DBFCDX", cArqs, cAliasTmp, .T., .F. )

RestArea(aAreaX3)
Return

/*---------------------------------------------------------------------*
| Func:  fPopulaG                                                      |
| Autor: Jair Matos                                                |
| Data:  28/04/2017                                                   |
| Desc:  Função que popula a tabela auxiliar da MsSelect              |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function fPopulaG(cFiltro)
Local nAtual := 0
//Excluindo dados da tabela temporária, se tiver aberta, fecha a tabela
	If Select(cAliasTmp)>0
	(cAliasTmp)->(DbCloseArea())
	EndIf
fErase(cAliasTmp+".DBF")

//Criando tabela temporária
cArqs:= CriaTrab( aStrut, .T. )
dbUseArea( .T.,"DBFCDX", cArqs, cAliasTmp, .T., .F. )

//Faz a consulta
cQuery := " SELECT "    + STR_PULA
cQuery += " "
	For nAtual := 1 To Len(aCampos)
	cCampoAtu := aCampos[nAtual]
			cQuery += " "+cCampoAtu+","
	Next
cQuery := SubStr(cQuery, 1, Len(cQuery)-1)  + STR_PULA
cQuery += " ,"+cAliasPvt+".R_E_C_N_O_ AS XX_RECNUM "    + STR_PULA
cQuery += " FROM "  + STR_PULA
cQuery += "   "+RetSQLName(cAliasPvt)+" "+cAliasPvt+" " + STR_PULA
cQuery += cJoinSC5 + STR_PULA
cQuery += " WHERE " + STR_PULA
cQuery += "   "+cAliasPvt+".D_E_L_E_T_='' " + STR_PULA
cQuery += "   "+cFiltro+" " + STR_PULA
cQuery += "   AND ("
	For nAtual := 1 To Len(aCampos)
			cCampoAtu := aCampos[nAtual]
	cQuery += " UPPER("+cCampoAtu+") LIKE '%"+Upper(Alltrim(cGetPesq))+"%' OR"
	Next
cQuery := SubStr(cQuery, 1, Len(cQuery)-2)
cQuery += ")"+STR_PULA
cQuery += " ORDER BY "  + STR_PULA
cQuery += "   "+cCampoRet
TCQuery cQuery New Alias "QRY_DAD"

//Percorrendo a estrutura, procurando campos de data
	For nAtual := 1 To Len(aStrut)
	//Se for data
		If aStrut[nAtual][2] == "D"
		TCSetField('QRY_DAD', aStrut[nAtual][1], 'D')
		EndIf
	Next

//Enquanto tiver dados
	While ! QRY_DAD->(EoF())
	cOk := Space(Len(cMarca))
	
	//Gravando registro
	RecLock(cAliasTmp, .T.)
	XX_OK := cOK
	//Percorrendo os campos
		For nAtual := 1 To Len(aCampos)
		cCampoAtu := aCampos[nAtual]
		&(cCampoAtu+" := QRY_DAD->"+cCampoAtu)
		Next
	&("XX_RECNUM := cValToChar(QRY_DAD->XX_RECNUM)")
	(cAliasTmp)->(MsUnlock())
	
	QRY_DAD->(DbSkip())
	EndDo
QRY_DAD->(DbCloseArea())


//Posiciona no topo e atualiza grid
(cAliasTmp)->(DbGoTop())
oMAux:oBrowse:Refresh()
Return
/*---------------------------------------------------------------------*
| Func:  fVldPesqG                                                     |
| Autor: Jair Matos                                                |
| Data:  28/04/2017                                                   |
| Desc:  Função que valida o campo digitado                           |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/


Static Function fVldPesqG(cFiltro)
Local lRet := .T.

//Se tiver apóstrofo ou porcentagem, a pesquisa não pode prosseguir
	If "'" $ cGetPesq .Or. "%" $ cGetPesq
	lRet := .F.
	HELP(' ',1,'Atenção!',,"<b>Pesquisa inválida!</b><br>A pesquisa não pode ter <b>'</b> ou <b>%</b>.",1,0, NIL, NIL, NIL, NIL, NIL, {"Pesquisa"})
	EndIf

//Se houver retorno, atualiza grid
	If lRet
	
	fPopulaG(cFiltro)
	EndIf
Return lRet

/*---------------------------------------------------------------------*
| Func:  Desmarcar                                                    |
| Autor: Jair Matos                                                   |
| Data:  28/04/2017                                                   |
| Desc:  Função que marca todos registros                             |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function OMS105M()
(cAliasTmp)->(dbGoTop())
	While !(cAliasTmp)->(Eof())
	(cAliasTmp)->(RecLock((cAliasTmp),.f.))
		If lCheck == .f.
		(cAliasTmp)->XX_OK := ""
		Else
		(cAliasTmp)->XX_OK := cMarca
		EndIf
	(cAliasTmp)->(MsUnLock())
	(cAliasTmp)->(dbSkip())
	Enddo
(cAliasTmp)->(dbCommit())
(cAliasTmp)->(dbGoTop())

oMAux:oBrowse:Refresh()

Return
/*---------------------------------------------------------------------*
| Func:  fGetMkA                                                      |
| Autor: Jair Matos                                                |
| Data:  28/04/2017                                                   |
| Desc:  Função que marca o registro                                  |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function fGetMkA(cMarca)
Local lChecado:= .F.

//Verificando se o registro foi checado
DbSelectArea(cAliasTmp)
lChecado:=XX_OK <> cMarca

//Gravando a marca

RecLock( cAliasTmp, .F. )
XX_OK := IIF( lChecado, cMarca, "" )
&(cAliasTmp)->(MsUnlock())


oMAux:oBrowse:Refresh()
Return
/*---------------------------------------------------------------------*
| Func:  fConfirmG                                                     |
| Autor: Jair Matos                                                |
| Data:  28/04/2017                                                   |
| Desc:  Função de confirmação da rotina                              |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function fConfirmG(cAliasM)
Local cUltItem 	:= ""
Local cAlias	:= getNextAlias()

//Excluindo dados da tabela temporária, se tiver aberta, fecha a tabela
	If Select(cAlias)>0
	(cAlias)->(DbCloseArea())
	EndIf

	BeginSql Alias cAlias
		Select MAX(ZA7_ITEM) ITEM from %table:ZA7% ZA7 WHERE ZA7.ZA7_FILIAL =%xFilial:ZA7% AND ZA7.ZA7_CODIGO=%Exp:cNDLNum% AND ZA7.D_E_L_E_T_ = ' '
	EndSql

//	  	Memowrite("c:\temp\ct1ctt.TXT",getLastQuery()[2])
	If !(cAlias)->(Eof())
		cUltItem := Soma1((cAlias)->ITEM)
	Else
		cUltItem := "001"
	EndIf

	DbSelectArea(cAliasTmp)
	DbGoTop()
	Do While !Eof()
		If(cAliasTmp)->XX_OK =="OK"
			If cUltItem ==aCols[1][1]
				aCols[1][1] := cUltItem//item
				aCols[1][2] :=(cAliasTmp)->C9_PEDIDO//pedido
				aCols[1][3] :=(cAliasTmp)->C9_ITEM//transportadora
				aCols[1][4] := (cAliasTmp)->C9_QTDLIB//quantidade
				aCols[1][5] := DATE()
				aCols[1][6] := TIME()
				aCols[1][7] := (cAliasTmp)->C9_PRODUTO//PRODUTO
				aCols[1][8] := (cAliasTmp)->C6_DESCRI//DESCRICAO
				aCols[1][9] := (cAliasTmp)->C5_PESOL//peso liquido
				aCols[1][10] := (cAliasTmp)->C5_PBRUTO//peso bruto
				aCols[1][11] := ""
				aCols[1][12] := "ZA7"
				aCols[1][13] := 0
				aCols[1][14] := .F.
				cUltItem :=Soma1(cUltItem)
			Else
				aAdd(aCols, {cUltItem,(cAliasTmp)->C9_PEDIDO,(cAliasTmp)->C9_ITEM,(cAliasTmp)->C9_QTDLIB,;
					date(),time(),(cAliasTmp)->C9_PRODUTO,(cAliasTmp)->C6_DESCRI,(cAliasTmp)->C5_PESOL,;
					(cAliasTmp)->C5_PBRUTO,"","ZA7",0, .F.})
				cUltItem :=Soma1(cUltItem)
			EndIf
		EndIf
		dbSkip()
	Enddo

	oDlgMark:End()
Return
/*/{Protheus.doc} OM200LEG
//O ponto de entrada OM200LEG tem por objetivo a inclusão de novas legendas na rotina de montagem de carga.
@author Jair Andrade    
@since 03/12/2020
@version version
/*/
User Function OMS105L()
	Local aLeg := {}
	AAdd(aLeg,{"BR_VERDE"    , "Pedidos agrupados sem EDI"  } )
	AAdd(aLeg,{"BR_AZUL"     , "Enviado EDI para transportadora"     } )
	AAdd(aLeg,{"BR_BRANCO"   , "Aguardando faturamento"     } )
	AAdd(aLeg,{"BR_VERMELHO" , "EDI / pedidos cancelados"} )
	AAdd(aLeg,{"BR_AMARELO"   , "Solic. Cancelamento transportadora"    } )
	AAdd(aLeg,{"BR_PRETO"   , "Pedidos faturados"    } )
	BrwLegenda("Envio EDI Transportadoras", "Legenda", aLeg)
Return( Nil )

/*---------------------------------------------------------------------*
| Func:  fCancelaG                                                     |
| Autor: Jair Matos                                                |
| Data:  28/04/2017                                                   |
| Desc:  Função de cancelamento da rotina                             |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function fCancelaG()
//Setando o retorno em branco e finalizando a tela
lRetorn := .F.
__cRetorn := Space(nTamanRet)
oDlgMark:End()
Return
Static Function PREDI(cCodTrans)
cCodEdi := Posicione("SA4",1,xFilial("SA4")+cCodTrans,"A4_EDIENV")
oGetEDI:Refresh()
Return
