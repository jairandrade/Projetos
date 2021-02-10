#INCLUDE "PROTHEUS.CH"
/*                                                                                            
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina 								                 !
+------------------+---------------------------------------------------------+
!Modulo            ! Compras                                                 !
+------------------+---------------------------------------------------------+
!Nome              ! ANDL012.PRW                                             !
+------------------+---------------------------------------------------------+
!Descricao         ! Tela customizada cadastro de grupos de centro de custo  !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos de Andrade                                   !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 04/04/2017                                              !
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
User Function ANDL012()

	Private cCadastro 	:= "Grupos de Centro de Custo"
	Private aRotina		:=  {{OemToAnsi("Pesquisar"),"AxPesqui",0,1,0,.F.},;	//"Pesquisar"
	{OemToAnsi("Visualizar"),"U_ANDL2GRAV(2)",0,2,0,nil},;	//"Visualizar"
	{OemToAnsi("Incluir"),"U_ANDL2GRAV(3)",0,3,0,nil},; //"Incluir"
	{OemToAnsi("Alterar"),"U_ANDL2GRAV(4)",0,4,0,nil},; //"Alterar"
	{OemToAnsi("Excluir"),"U_ANDL2GRAV(5)",0,5,0,nil} } //"Excluir"

	dbSelectArea("Z0M")
	dbSetOrder(1)

	mBrowse(006,001,022,075,"Z0M")

	dbSelectArea("Z0M")
	dbClearFilter()
	dbSetOrder(1)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} ANDL2GRAV
Rotina de grava?o(inclusao, altera?o , exclusao)

@author Jair Matos
@since 04/04/2017
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

User Function ANDL2GRAV(nOpcX)

	Local aArea		:= Z0M->(GetArea())
	Local aSizeAut	:= MsAdvSize(,.F.)
	Local aObjects	:= {}
	Local aInfo 	:= {}
	Local aPosObj	:= {}
	Local aNoFields := {"Z0M_DESCRI","Z0M_COD"}
	Local cSeek     := ""
	Local cWhile    := ""
	Local nSaveSX8  := GetSX8Len()
	Local nOpcA     := 0
	Local nX        := 0
	Local lNDLVisual:= .F.
	Local lNDLInclui:= .F.
	Local lNDLDeleta:= .F.
	Local lNDLAltera:= .F.
	Local lGravaOK  := .T.
	Local oDlg
	Local oGetDados

	Private cNDLNum	:= CriaVar("Z0M_COD")
	Private cNDLDesc:= CriaVar("Z0M_DESCRI")
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

//??????????????????????????????
//?Monta aHeader e aCols utilizando a funcao FillGetDados.  ?
//??????????????????????????????
	If lNDLInclui
		//?????????????????????????????????????????????????????????????????????????????????????????????????????????????
		//?Sintaxe da FillGetDados(/*nOpcX*/,/*Alias*/,/*nOrdem*/,/*cSeek*/,/*bSeekWhile*/,/*uSeekFor*/,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/) |
		//?????????????????????????????????????????????????????????????????????????????????????????????????????????????
		FillGetDados(nOpcX,"Z0M",1,,,,aNoFields,,,,,.T.,,,)
		aCols[1][aScan(aHeader,{|x| Trim(x[2])=="Z0M_ITEM"})] := StrZero(1,Len(Z0M->Z0M_ITEM))

	Else
		cNDLNum := Z0M->Z0M_COD
		cNDLDesc:= Z0M->Z0M_DESCRI
		cSeek   := xFilial("Z0M")+Z0M->Z0M_COD
		cWhile  := "Z0M->Z0M_FILIAL+Z0M->Z0M_COD"
		//?????????????????????????????????????????????????????????????????????????????????????????????????????????????
		//?Sintaxe da FillGetDados(/*nOpcX*/,/*Alias*/,/*nOrdem*/,/*cSeek*/,/*bSeekWhile*/,/*uSeekFor*/,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/) |
		//?????????????????????????????????????????????????????????????????????????????????????????????????????????????
		FillGetDados(nOpcX,"Z0M",1,cSeek,{|| &cWhile },,aNoFields,,,,,,,,)
	EndIf

	AAdd( aObjects, { 000, 040, .T., .F. })
	AAdd( aObjects, { 100, 100, .T., .T. })
	aInfo  := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
	aPosObj:= MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE "GRUPO DE CENTRO DE CUSTO" From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	@ 020,010 SAY   "Numero"  OF oDlg PIXEL //"N?ero"
	@ 018,040 MSGET cNDLNum  PICTURE PesqPict("Z0M","Z0M_COD") VALID ANumero() .And. CheckSX3("Z0M_COD") WHEN lNDLInclui .And. VisualSX3("Z0M_COD") OF oDlg PIXEL SIZE 30,10 RIGHT
	@ 020,080 SAY   "Descri?o"  OF oDlg PIXEL  //"Descricao"
	@ 018,110 MSGET cNDLDesc PICTURE PesqPict("Z0M","Z0M_DESCRI")VALID CheckSX3("Z0M_DESCRI") WHEN !lNDLVisual .And. VisualSX3("Z0M_DESCRI") OF oDlg PIXEL
	@ 018,300 BUTTON oBtnVisu PROMPT "Adicionar CCusto" SIZE 050,013 WHEN !lNDLVisual  OF oDlg ACTION(U_ChamaMARK(2)) PIXEL

	oGetDados := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcX,"U_AN2LinOK()","U_AN2TudOK()","+Z0M_ITEM",!lNDLVisual,,,,250)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, IIf(oGetdados:TudoOk(),(nOpcA := 1,oDlg:End()),nOpcA := 0)},{||oDlg:End()})

	If nOpcA == 1
		If lNDLInclui .Or. lNDLAltera .Or. lNDLDeleta
			lGravaOk := ANDLGrava(lNDLDeleta)
			If lGravaOk
				EvalTrigger()
				If lNDLInclui
					While ( GetSX8Len() > nSaveSX8 )
						ConFirmSX8()
					EndDo
				EndIf
			Else
				Help(" ",1,"A085NAOREG")
				While ( GetSX8Len() > nSaveSX8 )
					RollBackSX8()
				EndDo
			EndIf
		EndIf
	Endif

	RestArea(aArea)

Return


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

Static Function ANDLGrava(lNDLDeleta)

	Local nPosITTEM := aScan(aHeader,{|x| AllTrim(x[2]) == "Z0M_ITEM"})
	Local ni       := 0
	Local nCount	:= 0

	dbSelectArea("Z0M")
	Z0M->(dbSetOrder(1))

	For ni:=1 To Len(aCols)
		If (!aCols[ni][Len(aHeader)+1]) .AND. (!Empty(aCols[ni][2]))
			//Verifica se registro Existe. Se existir, altera
			If Z0M->(dbSeek(xFilial("Z0M")+cNDLNum+aCols[nI][nPosITTEM]))
				RecLock("Z0M",.F.)
			Else
				RecLock("Z0M",.T.)
			EndIf
			If !lNDLDeleta
				nCount++
				Z0M->Z0M_FILIAL := xFilial("Z0M")
				Z0M->Z0M_COD  	:= cNDLNum
				Z0M->Z0M_DESCRI := cNDLDesc
				Z0M->Z0M_ITEM 	:= Strzero(nCount,4,0)
				Z0M->Z0M_CODCCU := aCols[ni][2]
				Z0M->Z0M_DESCC  := aCols[ni][3]
			Else
				Z0M->(dbDelete())
			EndIf
		Else
			If Z0M->(dbSeek(xFilial("Z0M")+cNDLNum+aCols[nI][nPosITTEM]))
				RecLock("Z0M",.F.)
				Z0M->(dbDelete())
			EndIf
		EndIf
	Next
	Z0M->(MsUnLock())

Return .T.
