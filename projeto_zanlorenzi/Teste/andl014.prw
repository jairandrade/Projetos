#Include "Protheus.ch"
#Include "TopConn.ch"

//Constantes
#Define STR_PULA        Chr(13)+ Chr(10)

/*
+----------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Relatório                                               !
+------------------+---------------------------------------------------------+
!Modulo            ! Faturamento                                             !
+------------------+---------------------------------------------------------+
!Nome              ! ANDL014                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina que valida usuario logado e retorna CC ou CTA	 !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos de Andrade		                             !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 11/04/17                                                !
+------------------+---------------------------------------------------------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
! adicionado opção de consulta por codigo e !           !Jair Matos !23/08/17!
! descrição                                 !   	    !           !        !
+-------------------------------------------+-----------+-----------+--------+ 
! adicionado posicionamento na conta e cc   !           !Jair Matos !11/09/17!
! 								            !   	    !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

User Function ANDL014(nOpc)

	Local cGrpUsu	:="" //Grupo de usuario
	Local cCCusto	:="" //Centro de Custo
	Local cCCONT	:="" //Conta contabil
	Local cTitulo	:= "Projetos"
	Local cFiltroM	:= ""									//obrigatorio
	Local cAlias	:= Iif(nOpc==1,"CTT","CT1")				//obrigatorio
	Local cCpoChave	:= Iif(nOpc==1,"CTT_CUSTO","CT1_CONTA") //obrigatorio
	Local aCamposM	:=Iif(nOpc==1,{"CTT_DESC01","CTT_CUSTO"},{"CT1_DESC01","CT1_CONTA"})
	Local lRet 		:= .T.
	Private bRet 	:= .F.
	Private nOpcP	:= nOpc


//Valida se usuario está cadastrado em algum grupo. Se não estiver, pula e retorna o F3 padrão
	DbSelectArea("Z0L")//Cadastro de Grupo de usuarios Contabil
	dbSetOrder(2)
	IF dbSeek(xFilial("Z0L")+__cUserId)
		cGrpUsu := Z0L->Z0L_COD
	Else
		lRet := .F.
	EndIf

	DbSelectArea("Z0O")//Cadastro de GRUPOxCCUSTOxCCONTABIL
	dbSetOrder(2)
	IF dbSeek(xFilial("Z0O")+cGrpUsu)
		cCCusto :=Z0O->Z0O_CODCCU
		cCCONT 	:= Z0O->Z0O_CODCC
	Else
		lRet := .F.
	EndIf

	If nOpc == 1
		If lRet
			cFiltroM := " AND CTT.CTT_BLOQ <> '1' AND CTT_CUSTO =( SELECT Z0M_CODCCU FROM "
			cFiltroM += +RetSQLName("Z0M") + " Z0M "
			cFiltroM += " WHERE Z0M.Z0M_CODCCU = CTT.CTT_CUSTO AND Z0M_COD  = '" + cCCusto + "' AND Z0M.D_E_L_E_T_= ' ' ) "
		else
			cFiltroM := " AND CTT.CTT_BLOQ <> '1' "
		EndIf
	ElseiF nOpc == 2
		If lRet
			cFiltroM := " AND CT1.CT1_BLOQ <> '1' AND CT1_CONTA =( SELECT Z0N_CODCC FROM "
			cFiltroM += +RetSQLName("Z0N") + " Z0N "
			cFiltroM += " WHERE Z0N.Z0N_CODCC = CT1.CT1_CONTA AND Z0N_COD  = '" + cCCONT + "' AND Z0N.D_E_L_E_T_= ' ' ) "
		Else
			cFiltroM := " AND CT1.CT1_BLOQ <> '1' "
		EndIf
	EndIf

	bRet := U_ANDL014A(cAlias, aCamposM, cFiltroM, cCpoChave,,cCpoChave)

Return(bRet)

/*/{Protheus.doc} ANDL014A
Função para consulta genérica
@author Jair Matos
@since 24/04/2017
@version 1.0
@param cAliasM, Caracter, Alias da tabela consultada
@param aCamposM, Array, Campos que serão montados na grid de marcação
@param cFiltroM, Caracter, Filtragem da tela (SQL)
@param cRetorM, Caracter, Campo que será checado
@param aColsM, Array, Conteúdo de campos específicos, que iniciam com XX_ no aCamposM
@param cOrdM, Caracter, Campos utilizados no Order By
@return lRetorn, retorno se a consulta foi confirmada ou não
@example
u_ANDL014A("SED", {"ED_CODIGO","ED_DESCRIC"}, " AND ED_FILIAL = '"+xFilial("SED")+"' ", "ED_CODIGO")
u_ANDL014A("SB1", {"B1_COD","B1_DESC","B1_TIPO"}, " AND B1_FILIAL = '"+xFilial("SB1")+"' ", "B1_COD")
...
User Function zConsSC2()
lOk := u_ANDL014A("SC2", {"C2_NUM","C2_ITEM","C2_SEQUEN","C2_OBS","C2_PRODUTO","C2_CC","XX_SALDO"},, "C2_NUM+C2_ITEM+C2_SEQUEN",{"u_zRetSC2Sld(QRY_DAD->RECNUM)"})
Return lOk
@obs O retorno da consulta é pública (__cRetorn) para ser usada em consultas específicas
Caso seja necessário incluir campos específicos na grid, utilize o prefixo XX_ antes do nome do campo no aCamposM,
e seu conteúdo preencha no aColsM
/*/

User Function ANDL014A(cAliasM, aCamposM, cFiltroM, cRetorM, aColsM, cOrdM)
	Local aArea := GetArea()
	Local nTamBtn := 50
	Local aItens := {"C=Codigo","D=Descrição"}
	Local oCombo := nil

//Defaults
	Default cAliasM := ""
	Default aCamposM := {}
	Default cFiltroM := ""
	Default cRetorM := ""
	Default aColsM := {}
	Default cOrdM := ""

//Privates
	Private cTipoOp :="D"
	Private cFiltro := cFiltroM
	Private cAliasPvt := cAliasM
	Private aCampos := aCamposM
	Private nTamanRet := 0
	Private cCampoRet := cRetorM
	Private aColsEsp := aColsM
	Private cOrder := cOrdM
//MsNewGetDados
	Private oMsNew
	Private aHeadAux := {}
	Private aColsAux := {}
//Tamanho da janela
	Private nJanLarg := 0500
	Private nJanAltu := 0350
//Gets e Dialog
	Private oDlgEspe
	Private oGetPesq, cGetPesq := Space(100)
//Retorno
	Private lRetorn := .F.
	Public  __cRetorn := ""

//Se tiver o alias em branco ou não tiver campos
	If Empty(cAliasM) .Or. Len(aCamposM) <= 0 .Or. Empty(cRetorM)
		MsgStop("Alias em branco e/ou Sem campos para marcação!", "Atenção")
		Return lRetorn
	EndIf

//Criando a estrutura para a MsNewGetDados
	fCriaMsNew()
	__cRetorn := Space(nTamanRet)

//retorna o centro de custo ou conta contabil selecionada no F3 / posicionado
	If cAliasM =="CTT"
		If FunName() == "MATA110"
			If !Empty(ACOLS[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CC'}) ])
				cGetPesq := ACOLS[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CC'}) ]
			EndIf
		ElseIf FunName() == "MATA121"
			If !Empty(ACOLS[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_CC'}) ])
				cGetPesq := ACOLS[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_CC'}) ]
			EndIf
		EndIf
	Else
		If FunName() == "MATA110"
			If !Empty(ACOLS[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CONTA'}) ])
				cGetPesq := ACOLS[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CONTA'}) ]
			EndIf
		ElseIf FunName() == "MATA121"
			If !Empty(ACOLS[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_CONTA'}) ])
				cGetPesq := ACOLS[N][aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_CONTA'}) ]
			EndIf
		EndIf
	EndIf

//Criando a janela
	DEFINE MSDIALOG oDlgEspe TITLE "Consulta de Dados" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 of oDlgEspe PIXEL
//Pesquisar
	@ 003, 003 GROUP oGrpPesqui TO 025, (nJanLarg/2)-3 PROMPT "Pesquisar: " OF oDlgEspe COLOR 0, 16777215 PIXEL
	@ 012, 005 COMBOBOX oCombo VAR cTipoOp ITEMS aItens SIZE 070,060 OF oDlgEspe ON CHANGE LimpaCpos() PIXEL

	@ 012, 075 MSGET oGetPesq VAR cGetPesq SIZE 170, 007 OF oDlgEspe COLORS 0, 16777215  VALID (fVldPesq())      PIXEL

//Dados
	@ 025, 003 GROUP oGrpDados TO (nJanAltu/2)-38, (nJanLarg/2)-3 PROMPT "Dados: "  OF oDlgEspe COLOR 0, 16777215 PIXEL
	oMsNew := MsNewGetDados():New(  035,;                                       //nTop
	006,;                                       //nLeft
	(nJanAltu/2)-31,;                           //nBottom
	(nJanLarg/2)-6,;                            //nRight
	GD_INSERT+GD_DELETE+GD_UPDATE,;         //nStyle
	"AllwaysTrue()",;                           //cLinhaOk
	,;                                          //cTudoOk
	"",;                                        //cIniCpos
	,;                                          //aAlter
	,;                                          //nFreeze
	999,;                                       //nMax
	,;                                          //cFieldOK
	,;                                          //cSuperDel
	,;                                          //cDelOk
	oDlgEspe,;                                  //oWnd
	aHeadAux,;                                  //aHeader
	aColsAux)                                   //aCols
	oMsNew:lActive := .F.
	oMsNew:oBrowse:blDblClick := {|| fConfirm()}

//Populando os dados da MsNewGetDados
	fPopula()

//Ações
	@ (nJanAltu/2)-25, 003 GROUP oGrpAcoes TO (nJanAltu/2)-3, (nJanLarg/2)-3 PROMPT "Ações: "   OF oDlgEspe COLOR 0, 16777215 PIXEL
	@ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*1)+06) BUTTON oBtnConf PROMPT "Confirmar" SIZE nTamBtn, 013 OF oDlgEspe ACTION(fConfirm())     PIXEL
	@ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*2)+09) BUTTON oBtnLimp PROMPT "Limpar" SIZE nTamBtn, 013 OF oDlgEspe ACTION(fLimpar())     PIXEL
	@ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*3)+12) BUTTON oBtnCanc PROMPT "Cancelar" SIZE nTamBtn, 013 OF oDlgEspe ACTION(fCancela())     PIXEL
	@ (nJanAltu/2)-19, (nJanLarg/2)-((nTamBtn*4)+15) BUTTON oBtnVisu PROMPT "Visualizar" SIZE nTamBtn, 013 OF oDlgEspe ACTION(fVisual())     PIXEL

	oMsNew:oBrowse:SetFocus()
	oDlgEspe:lEscClose := .T. //
//Ativando a janela
	ACTIVATE MSDIALOG oDlgEspe CENTERED

	RestArea(aArea)
Return lRetorn

/*---------------------------------------------------------------------*
| Func:  fCriaMsNew                                                   |
| Autor: Jair Matos                                                   |
| Data:  24/04/2017                                                   |
| Desc:  Função para criar a estrutura da MsNewGetDados               |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function fCriaMsNew()
Local aAreaX3 := SX3->(GetArea())

//Zerando o cabeçalho e a estrutura
aHeadAux := {}
aColsAux := {}

DbSelectArea("SX3")
SX3->(DbSetOrder(2)) // Campo
SX3->(DbGoTop())

//Percorrendo os campos
	For nAtual := 1 To Len(aCampos)
	cCampoAtu := aCampos[nAtual]
	
	//Se iniciar com XX_
		If SubStr(cCampoAtu, 1, 3) == "XX_"
		//Cabeçalho ... Titulo                                          Campo           Mask        Tamanho Dec     Valid   Usado   Tip     F3  CBOX
		aAdd(aHeadAux,{ Capital(StrTran(cCampoAtu, "XX_", "")), cCampoAtu,      "",         18,         0,      ".F.",  ".F.",  "C",    "", ""})
		ElseIf SubStr(cCampoAtu, 1, 3) == "YY_"
		//Cabeçalho ... Titulo                                          Campo           Mask        Tamanho Dec     Valid   Usado   Tip     F3  CBOX
		aAdd(aHeadAux,{ Capital(StrTran(cCampoAtu, "YY_", "")), cCampoAtu,      "",         100,            0,      ".F.",  ".F.",  "C",    "", ""})
		Else
		
		//Se conseguir posicionar no campo
			If SX3->(DbSeek(cCampoAtu))
			
			//Cabeçalho ... Titulo          Campo       Mask                                    Tamanho                 Dec                         Valid   Usado   Tip             F3  CBOX
			aAdd(aHeadAux,{ X3Titulo(), cCampoAtu,  PesqPict(cAliasPvt  , cCampoAtu),   TamSX3(cCampoAtu)[01],  TamSX3(cCampoAtu)[02],  ".F.",  ".F.",  SX3->X3_TIPO,    "", ""})
			
			//Se o campo atual for retornar, aumenta o tamanho do retorno
				If cCampoAtu $ cCampoRet
				nTamanRet += TamSX3(cCampoAtu)[01]
				EndIf
			EndIf
		
		EndIf
	Next

//Cabeçalho ... Titulo      Campo           Mask                        Tamanho Dec     Valid   Usado   Tip     F3  CBOX
aAdd(aHeadAux,{ "RecNo",    "XX_RECNUM",    "@E 999999999999999999",    18,         0,      ".F.",  ".F.",  "C",    "", ""})

RestArea(aAreaX3)
Return

/*---------------------------------------------------------------------*
| Func:  fPopula                                                      |
| Autor: Jair Matos                                                |
| Data:  24/04/2017                                                   |
| Desc:  Função que popula a tabela auxiliar da MsNewGetDados         |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function fPopula()
aColsAux :={}
nCampAux := 1

//Faz a consulta
cQuery := " SELECT "    + STR_PULA
cQuery += "    R_E_C_N_O_ AS RECNUM, "
	For nAtual := 1 To Len(aCampos)
	cCampoAtu := aCampos[nAtual]
		If SubStr(cCampoAtu, 1, 3) == "YY_"
		cQuery += " "+aColsEsp[nCampAux]+" AS "+cCampoAtu+","
		nCampAux++
		ElseIf SubStr(cCampoAtu, 1, 3) != "XX_"
		cQuery += " "+cCampoAtu+","
		EndIf
	Next
cQuery := SubStr(cQuery, 1, Len(cQuery)-1)  + STR_PULA
cQuery += " FROM "  + STR_PULA
cQuery += "   "+RetSQLName(cAliasPvt)+" "+cAliasPvt+" " + STR_PULA
cQuery += " WHERE " + STR_PULA
cQuery += "   "+cAliasPvt+".D_E_L_E_T_='' " + STR_PULA
cQuery += "   "+cFiltro+" " + STR_PULA
cQuery += "   AND ("
	For nAtual := 1 To Len(aCampos)
	cCampoAtu := aCampos[nAtual]
		If SubStr(cCampoAtu, 1, 3) != "XX_" .And. SubStr(cCampoAtu, 1, 3) != "YY_"
		cQuery += " UPPER("+cCampoAtu+") LIKE '%"+Upper(Alltrim(cGetPesq))+"%' OR"
		EndIf
	Next
cQuery := SubStr(cQuery, 1, Len(cQuery)-2)
cQuery += ")"+STR_PULA
cQuery += " ORDER BY "  + STR_PULA
	If !Empty(cOrder)
	cQuery += "   "+cOrder
	Else
	cQuery += "   "+cCampoRet
	EndIf
TCQuery cQuery New Alias "QRY_DAD"
//Memowrite("c:\temp\ANDL014.txt",cQuery)

//Percorrendo a estrutura, procurando campos de data
	For nAtual := 1 To Len(aHeadAux)
	//Se for data
		If aHeadAux[nAtual][8] == "D" .And. SubStr(aHeadAux[nAtual][1], 1, 3) != "XX_"
		TCSetField('QRY_DAD', aHeadAux[nAtual][2], 'D')
		EndIf
	Next

//Enquanto tiver dados
	While ! QRY_DAD->(EoF())
	nCampAux := 1
	aAux := {}
	//Percorrendo os campos e adicionando no acols (junto com o recno e com o delet
		For nAtual := 1 To Len(aCampos)
		cCampoAtu := aCampos[nAtual]
		//Se iniciar com XX_
			If SubStr(cCampoAtu, 1, 3) == "XX_"
			aAdd(aAux, &(aColsEsp[nCampAux]))
			nCampAux++
			
			//Senão, adiciona conforme consulta
			Else
			aAdd(aAux, cValToChar( &("QRY_DAD->"+cCampoAtu) ))
			EndIf
		Next
	aAdd(aAux, QRY_DAD->RECNUM)
	aAdd(aAux, .F.)
	
	aAdd(aColsAux, aClone(aAux))
	QRY_DAD->(DbSkip())
	EndDo
QRY_DAD->(DbCloseArea())

//Se não tiver dados, adiciona linha em branco
	If Len(aColsAux) == 0
	aAux := {}
	//Percorrendo os campos e adicionando no acols (junto com o recno e com o delet
		For nAtual := 1 To Len(aCampos)
		aAdd(aAux, '')
		Next
	aAdd(aAux, 0)
	aAdd(aAux, .F.)
	
	aAdd(aColsAux, aClone(aAux))
	EndIf

//Posiciona no topo e atualiza grid
oMsNew:SetArray(aColsAux)
oMsNew:oBrowse:Refresh()
Return

/*---------------------------------------------------------------------*
| Func:  fConfirm                                                     |
| Autor: Jair Matos                                                   |
| Data:  24/04/2017                                                   |
| Desc:  Função de confirmação da rotina                              |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function fConfirm()
Local aAreaX3 := SX3->(GetArea())
Local cAux := ""
Local aColsNov := oMsNew:aCols
Local nLinAtu  := oMsNew:nAt

DbSelectArea("SX3")
SX3->(DbSetOrder(2)) // Campo
SX3->(DbGoTop())

//Percorrendo os campos
	For nAtual := 1 To Len(aHeadAux)
	cCampoAtu := aHeadAux[nAtual][2]
	
	//Se coneguir posicionar no campo
		If SX3->(DbSeek(cCampoAtu))
		//Se o campo atual for retornar, soma com o auxiliar
			If cCampoAtu $ cCampoRet
			cAux += aColsNov[nLinAtu][If(cTipoOp=="C",1,2)]
			EndIf
		EndIf
	Next

//Setando o retorno conforme auxiliar e finalizando a tela
lRetorn := .T.
__cRetorn := cAux

//Se o tamanho for menor, adiciona
	If Len(__cRetorn) < nTamanRet
	__cRetorn += Space(nTamanRet - Len(__cRetorn))
	
	//Senão se for maior, diminui
	ElseIf Len(__cRetorn) > nTamanRet
	__cRetorn := SubStr(__cRetorn, 1, nTamanRet)
	EndIf

oDlgEspe:End()
RestArea(aAreaX3)
Return

/*---------------------------------------------------------------------*
| Func:  fLimpar                                                      |
| Autor: Jair Matos                                                   |
| Data:  24/04/2017                                                   |
| Desc:  Função que limpa os dados da rotina                          |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function fLimpar()
//Zerando gets
cGetPesq := Space(100)
oGetPesq:Refresh()

//Atualiza grid
fPopula()

//Setando o foco na pesquisa
oGetPesq:SetFocus()
Return

/*---------------------------------------------------------------------*
| Func:  fCancela                                                     |
| Autor: Jair Matos                                                   |
| Data:  24/04/2017                                                   |
| Desc:  Função de cancelamento da rotina                             |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function fCancela()
//Setando o retorno em branco e finalizando a tela
lRetorn := .F.
__cRetorn := Space(nTamanRet)
oDlgEspe:End()
Return

/*---------------------------------------------------------------------*
| Func:  fVldPesq                                                     |
| Autor: Jair Matos                                                   |
| Data:  24/04/2017                                                   |
| Desc:  Função que valida o campo digitado                           |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function fVldPesq()
Local lRet := .T.

//Se tiver apóstrofo ou porcentagem, a pesquisa não pode prosseguir
	If "'" $ cGetPesq .Or. "%" $ cGetPesq
	lRet := .F.
	MsgAlert("<b>Pesquisa inválida!</b><br>A pesquisa não pode ter <b>'</b> ou <b>%</b>.", "Atenção")
	EndIf

//Se houver retorno, atualiza grid
	If lRet
	fPopula()
	EndIf
Return lRet
/*---------------------------------------------------------------------*
| Func:  fVisual                                                      |
| Autor: Jair Matos                                                   |
| Data:  28/04/2017                                                   |
| Desc:  Função de visualizar o registro                              |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function fVisual()
Local cAux := ""
Local aColsNov := oMsNew:aCols
Local nLinAtu  := oMsNew:nAt
Local nPosRec  := aScan(aHeadAux,{|x| AllTrim(Upper(x[2]))=="XX_RECNUM" })

//Visualizando o registro
(cAliasPvt)->(DbGoTo(aColsNov[nLinAtu][nPosRec]))
AxVisual(cAliasPvt, aColsNov[nLinAtu][nPosRec], 2)
Return


/*---------------------------------------------------------------------*
| Func:  ChamaMARK                                                    |
| Autor: Jair Matos                                                   |
| Data:  28/04/2017                                                   |
| Desc:  Função para selecionar CCusto e Conta contabil               |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/
User Function ChamaMARK(nOpc)
	If nOpc ==1
	U_ChMARK("CT1", {"CT1_CONTA","CT1_DESC01"}, "", TamSx3("CT1_CONTA")[1], "CT1_CONTA", .T., ";")
	Else
	U_ChMARK("CTT", {"CTT_CUSTO","CTT_DESC01"}, "", TamSx3("CTT_CUSTO")[1], "CTT_CUSTO", .T., ";")
	EndIf
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

//Se tiver o alias em branco ou não tiver campos
	If Empty(cAliasM) .Or. (Len(aCamposM) <= 0 .And. cAliasM != "SM0") .Or. Empty(cCheckM)
	MsgStop("Alias em branco e/ou Sem campos para marcação!", "Atenção")
	Return lRetorn
	EndIf

	If cAliasM =="CTT"
	cFiltro := " AND NOT EXISTS(SELECT * FROM "+RetSQLName("Z0M")+"  Z0M WHERE Z0M_COD = "+cNDLNum+" AND Z0M_CODCCU =CTT_CUSTO  AND Z0M.D_E_L_E_T_ ='')
	Else
	cFiltro := " AND NOT EXISTS(SELECT * FROM "+RetSQLName("Z0N")+"  Z0N WHERE Z0N_COD = "+cNDLNum+" AND Z0N_CODCC =CT1_CONTA  AND Z0N.D_E_L_E_T_ ='')
	EndIf

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
oCheck:bChange := {|| MsAguarde( {|| ANDLMark() } ) }

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
		//                  Campo           Titulo      Mascara
		aAdd( aHeadRegs, {  cCampoAtu,  ,   X3Titulo(), PesqPict(cAliasPvt  , cCampoAtu) } )
		
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
| Func:  fConfirmG                                                     |
| Autor: Jair Matos                                                |
| Data:  28/04/2017                                                   |
| Desc:  Função de confirmação da rotina                              |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function fConfirmG(cAliasM)
Local cUltItem 	:= ""
Local cAlias	:= getNextAlias()

	If cAliasM =="CT1"
		BeginSql Alias cAlias
		Select MAX(Z0N_ITEM) ITEM from %table:Z0N% Z0N WHERE Z0N.Z0N_FILIAL =%xFilial:Z0N% AND Z0N.Z0N_COD=%Exp:cNDLNum% AND Z0N.D_E_L_E_T_ = ' '
		EndSql
	Else
		BeginSql Alias cAlias
		Select MAX(Z0M_ITEM) ITEM from %table:Z0M% Z0M WHERE Z0M.Z0M_FILIAL =%xFilial:Z0M% AND Z0M.Z0M_COD=%Exp:cNDLNum% AND Z0M.D_E_L_E_T_ = ' '
		EndSql
	Endif
//	  	Memowrite("c:\temp\ct1ctt.TXT",getLastQuery()[2])
	If !(cAlias)->(Eof())
		cUltItem := Soma1((cAlias)->ITEM)
	Else
		cUltItem := "01"
	EndIf

	dbCloseArea(cAlias)

	DbSelectArea(cAliasTmp)
	DbGoTop()
	Do While !Eof()
		If(cAliasTmp)->XX_OK =="OK"
			If cUltItem =="01"
				aCols[1][1] := cUltItem
				aCols[1][2] := Iif(cAliasM=="CT1",(cAliasTmp)->CT1_CONTA,(cAliasTmp)->CTT_CUSTO)
				aCols[1][3] := Iif(cAliasM=="CT1",(cAliasTmp)->CT1_DESC01,(cAliasTmp)->CTT_DESC01)
				aCols[1][4] := "Z0N"
				aCols[1][5] := 0
				aCols[1][6] := .F.
				cUltItem :=Soma1(cUltItem)
			Else
				aAdd(aCols, {cUltItem,Iif(cAliasM=="CT1",(cAliasTmp)->CT1_CONTA,(cAliasTmp)->CTT_CUSTO), Iif(cAliasM=="CT1",(cAliasTmp)->CT1_DESC01,(cAliasTmp)->CTT_DESC01),"Z0N",0, .F.})
				cUltItem :=Soma1(cUltItem)
			EndIf
		EndIf
		dbSkip()
	Enddo

	oDlgMark:End()
Return

/*---------------------------------------------------------------------*
| Func:  fLimparG                                                      |
| Autor: Jair Matos                                                |
| Data:  28/04/2017                                                   |
| Desc:  Função que limpa os dados da rotina                          |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function fLimparG()
//Zerando gets
cGetPesq := Space(100)
oGetPesq:Refresh()

//Atualiza grid
fPopulaG()

//Setando o foco na pesquisa
oGetPesq:SetFocus()
Return

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
	MsgAlert("<b>Pesquisa inválida!</b><br>A pesquisa não pode ter <b>'</b> ou <b>%</b>.", "Atenção")
	EndIf

//Se houver retorno, atualiza grid
	If lRet
	
	fPopulaG(cFiltro)
	EndIf
Return lRet

/*---------------------------------------------------------------------*
| Func:  fGetMkA                                                      |
| Autor: Jair Matos                                                |
| Data:  28/04/2017                                                   |
| Desc:  Função que marca o registro                                  |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function fGetMkA(cMarca)
Local lChecado:= .F.
Local lFalhou := .F.

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
| Func:  Desmarcar                                                    |
| Autor: Jair Matos                                                   |
| Data:  28/04/2017                                                   |
| Desc:  Função que marca todos registros                             |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function ANDLMark()
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
| Func:  Limpar pesquisa                                              |
| Autor: Jair Matos                                                   |
| Data:  22/08/2017                                                   |
| Desc:  Função que limpa a pesquisa                                  |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/
Static Function LimpaCpos()

aCampos := {}

	If nOpcP == 1 //CTT
		If ( cTipoOp == "C" ) //CODIGO
		aCampos	:={"CTT_CUSTO","CTT_DESC01"}
		eLSE //descricao
		aCampos	:={"CTT_DESC01","CTT_CUSTO"}
		EndIf
	
	Else//CT1
		If ( cTipoOp == "C" ) //CODIGO
		aCampos	:={"CT1_CONTA","CT1_DESC01"}
		eLSE //descricao
		aCampos	:={"CT1_DESC01","CT1_CONTA"}
		EndIf
	EndIf

fPopula()

Return
