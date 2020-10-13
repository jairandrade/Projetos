#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina de Alteraçao de parametros(Dialog)               !
+------------------+---------------------------------------------------------+
!Modulo            ! Contabilidade Gerencial                                 !
+------------------+---------------------------------------------------------+
!Nome              ! CTBX001.PRW                                             !
+------------------+---------------------------------------------------------+
!Descricao         ! Lancamento do parametro de fechamento do financeiro.    !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos de Andrade                                   !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 08/10/2018                                              !
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

User Function CTBX001()
Local oDlgPar := NIL
Local oDataMV
Local oDataFIM
Local oDataUDP
Private nCont :=0
Private aFiliais := {}
Private aEmpFIN := {}
Private aEmpFIS := {}
Private dDataMVU := SUPERGETMV("MV_DBLQMOV", .T., STOD("20180101"))
Private dDataFIN := SUPERGETMV("MV_DATAFIN", .T., STOD("20180101"))
Private dDataFIS := SUPERGETMV("MV_DATAFIS", .T., STOD("20180101"))

//MV_DBLQMOV -> Data para bloqueio de movimentos.

//MV_DATAFIN -> Data limite p/ realizacao de operacoes financeiras

//MV_DATAFIS -> Ultima data de encerramento de operacoes fiscais


// Monta a tela
DEFINE MSDIALOG oDlgPar TITLE "Alteraçäo Parametros " FROM 001,001 TO 200,620 PIXEL
DEFINE FONT oFnt NAME "Arial" Size 6,22

oSay:= tSay():New(10,10,{||"Parametros  | Descriçao"},oDlgPar,,oFnt,,,,.T.)
oSay:= tSay():New(11,105,{||"Para alterar os Parametro selecione as filias/empresas através do botão FILTRAR."},oDlgPar,,,,,,.T.)

//Parämetro 1
@ 026,010 SAY "MV_DBLQMOV  | Data para bloqueio de movimentos: "   SIZE 200,07 PIXEL OF oDlgPar
@ 025,230 MSGET oDataMV VAR dDataMVU SIZE 45,05 WHEN .T. PICTURE PesqPict("SE1","E1_EMISSAO") PIXEL OF oDlgPar
//Parämetro 2
@ 040,010 SAY "MV_DATAFIN | Data limite p/ realizacao de operacoes financeiras: "   SIZE 200,07 PIXEL OF oDlgPar
@ 039,230 MSGET oDataFIM VAR dDataFIN SIZE 45,05 WHEN .T. PICTURE PesqPict("SE1","E1_EMISSAO") PIXEL OF oDlgPar
//Parämetro 3
@ 054,010 SAY "MV_DATAFIS | Ultima data de encerramento de operacoes fiscais: "   SIZE 200,07 PIXEL OF oDlgPar
@ 053,230 MSGET oDataUDP VAR dDataFIS SIZE 45,05 WHEN .T. PICTURE PesqPict("SE1","E1_EMISSAO") PIXEL OF oDlgPar
//Tipo 13 - Salvar
DEFINE SBUTTON FROM 025,280 TYPE 13 ACTION U_CTBX001A(1) ENABLE OF oDlgPar
DEFINE SBUTTON FROM 040,280 TYPE 13 ACTION U_CTBX001A(2) ENABLE OF oDlgPar
DEFINE SBUTTON FROM 054,280 TYPE 13 ACTION U_CTBX001A(3) ENABLE OF oDlgPar
//Tipo 17 - Filtrar
DEFINE SBUTTON FROM 025,200 TYPE 17 ACTION ChamaSM0(1) ENABLE OF oDlgPar
DEFINE SBUTTON FROM 040,200 TYPE 17 ACTION ChamaSM0(2) ENABLE OF oDlgPar
DEFINE SBUTTON FROM 054,200 TYPE 17 ACTION ChamaSM0(3) ENABLE OF oDlgPar

//DEFINE SBUTTON FROM 080,200 TYPE 1 ACTION oDlgPar:End() ENABLE OF oDlgPar
@ 080,265 BUTTON oButton PROMPT "SAIR"  OF oDlgPar PIXEL ACTION (oDlgPar:End())

ACTIVATE MSDIALOG oDlgPar CENTERED

Return

//-------------------------------------------------------------------
/*/{Protheus.CODIGO} User Function CTBX001A
Alterar os parametros

@author  Jair Matos de Andrade
@since   08/10/2018
@return  .T. - Sempre verdadeiro
/*/
//-------------------------------------------------------------------
User Function CTBX001A(nOpc)
Local lRet := .T.  
Local nX := 0
Local cParamMv :=""

If nOpc ==1 //MV_DBLQMOV  | Data para bloqueio de movimentos
	If !Empty(aFiliais)
		DbSelectArea("SX6") //Abre a tabela SX6
		DbSetOrder(1) //Se posiciona no primeiro indice
		For nX := 1 To Len(aFiliais)
			
			If !DbSeek(aFiliais[nX]+"MV_DBLQMOV") //Verifique se o parametro existe
				RecLock("SX6",.T.) //Se nao existe, criar o registro
				SX6->X6_FIL     := aFiliais[nX]
				SX6->X6_VAR     := "MV_DBLQMOV"
				SX6->X6_TIPO    := "D"
				SX6->X6_DESCRIC := "Data para bloqueio de movimentos. Não podem ser "
				SX6->X6_DESC1   := "alterados / criados / excluidos movimentos com "
				SX6->X6_DESC2   := "data menor ou igual a data informada no parametro."
				SX6->X6_CONTEUD := DTOS(dDataMVU)
				MsUnLock() //salva o registro com as informações passada
			Else
				RecLock("SX6",.F.) //Abre o registro para edição
				SX6->X6_CONTEUD := DTOS(dDataMVU)  //atualiza apenas o campo desejado
				MsUnLock() //salva o registro
			EndIf
		Next nX
		
		//Zera o array
		aFiliais := {}
		cParamMv :="MV_DBLQMOV"
	Else
		MsgAlert("Selecione uma filial antes de Salvar .","Aviso")
		lRet := .F.
	EndIf
ElseIf nOpc ==2//MV_DATAFIN | Data limite p/ realizacao de operacoes financeiras
	If !Empty(aEmpFIN)
		For nX := 1 To Len(aEmpFIN)
			//	1-Verifica as filiais que estão vinculadas a esta empresa
			DbSelectArea("SM0")
			SM0->(DbGoTop())
			While !SM0->(EoF())
				If SM0->M0_CODIGO == cEmpAnt   .AND. SUBSTR(SM0->M0_CODFIL,1,2)==SUBSTR(aEmpFIN[nX],9,2)
					DbSelectArea("SX6") //Abre a tabela SX6
					DbSetOrder(1) //Se posiciona no primeiro indice
					If !DbSeek(Alltrim(SM0->M0_CODFIL)+"MV_DATAFIN") //Verifique se o parametro existe
					RecLock("SX6",.T.) //Se nao existe, criar o registro
					SX6->X6_FIL     := SM0->M0_CODFIL
					SX6->X6_VAR     := "MV_DATAFIN"
					SX6->X6_TIPO    := "D"
					SX6->X6_DESCRIC := "Data limite p/ realizacao de operacoes financeiras."
					SX6->X6_CONTEUD := DTOS(dDataFIN)
					MsUnLock() //salva o registro com as informações passada
					Else
					RecLock("SX6",.F.) //Abre o registro para edição
					SX6->X6_CONTEUD := DTOS(dDataFIN)  //atualiza apenas o campo desejado
					MsUnLock() //salva o registro
					EndIf
				EndIf
				SM0->(DbSkip())
			EndDo
		Next nX
	Else
		MsgAlert("Selecione uma Empresa antes de Salvar .","Aviso")
		lRet := .F.
	EndIf
	
	//Zera o array
	aEmpFIN := {}
	cParamMv :="MV_DATAFIN"
	
Else //MV_DATAFIS | Ultima data de encerramento de operacoes fiscais
	
	If !Empty(aEmpFIS)
		For nX := 1 To Len(aEmpFIS)
			//	1-Verifica as filiais que estão vinculadas a esta empresa
			DbSelectArea("SM0")
			SM0->(DbGoTop())
			While !SM0->(EoF())
				If SM0->M0_CODIGO == cEmpAnt   .AND. SUBSTR(SM0->M0_CODFIL,1,2)==SUBSTR(aEmpFIS[nX],9,2)
					DbSelectArea("SX6") //Abre a tabela SX6
					DbSetOrder(1) //Se posiciona no primeiro indice
					If !DbSeek(Alltrim(SM0->M0_CODFIL)+"MV_DATAFIS") //Verifique se o parametro existe
					RecLock("SX6",.T.) //Se nao existe, criar o registro
					SX6->X6_FIL     := SM0->M0_CODFIL
					SX6->X6_VAR     := "MV_DATAFIS"
					SX6->X6_TIPO    := "D"
					SX6->X6_DESCRIC := "Data limite p/ realizacao de operacoes financeiras."
					SX6->X6_CONTEUD := DTOS(dDataFIS)
					MsUnLock() //salva o registro com as informações passada
					Else
					RecLock("SX6",.F.) //Abre o registro para edição
					SX6->X6_CONTEUD := DTOS(dDataFIS)  //atualiza apenas o campo desejado
					MsUnLock() //salva o registro
					EndIf
				EndIf
				SM0->(DbSkip())
			EndDo
		Next nX
	Else
		MsgAlert("Selecione uma Empresa antes de Salvar .","Aviso")
		lRet := .F.
	EndIf
	
	//Zera o array
	aEmpFIS := {}
	cParamMv :="MV_DATAFIS"
	
EndIf

If lRet
	MSGALERT("Parametro "+cParamMv+" alterado com Sucesso!","Informacao")
EndIf

Return
//---------------------------------------------------------------------
/*/{Protheus.CODIGO} ChamaSM0()
funcao para retornar as filiais

@author Jair  Matos
@since 10/10/2018
@version P11
@return cNfs
/*/
//---------------------------------------------------------------------
Static Function  ChamaSM0(nOpc)

Local _stru:={}
Local aCpoBro := {}
Local oDlg
Local cNfs := ""
Local cEmpAtual := ""
Local cDescricao := ""
Private lInverte := .F.
Private cMark   := GetMark()
Private oMark
//Cria um arquivo de Apoio
AADD(_stru,{"OK"     ,"C"	,2						,0		})
AADD(_stru,{"CODIGO" ,"C"	,TamSX3("A1_FILIAL")[1]	,0		})
AADD(_stru,{"FILIAL" ,"C"	,40						,0		})
AADD(_stru,{"DTLANC" ,"D"	,2						,0		})
cArq:=Criatrab(_stru,.T.)
DBUSEAREA(.t.,,carq,"TTRB")
//Verificar as filiais selecionadas
DbSelectArea("SM0")
SM0->(DbGoTop())
If nOpc == 1
	cDescricao := "Relação de Filiais para parâmetro MV_DBLQMOV"
	While !SM0->(EoF())
		If SM0->M0_CODIGO == cEmpAnt
			DbSelectArea("TTRB")
			RecLock("TTRB",.T.)
			TTRB->CODIGO  :=  SM0->M0_CODFIL
			TTRB->FILIAL  :=  SM0->M0_FILIAL
			TTRB->DTLANC  :=  Stod(fRetDtMov(SM0->M0_CODFIL,nOpc))
			MsunLock()
		EndIf
		SM0->(DbSkip())
	EndDo
Else
	cDescricao := "Relação de Empresas para parâmetro "+Iif(nOpc==2,"MV_DATAFIN","MV_DATAFIS")
	While !SM0->(EoF())
		If SM0->M0_CODIGO == cEmpAnt   .AND. SUBSTR(SM0->M0_CODFIL,1,2)<>cEmpAtual
			cEmpAtual := SUBSTR(SM0->M0_CODFIL,1,2)
			DbSelectArea("TTRB")
			RecLock("TTRB",.T.)
			TTRB->CODIGO  :=  "Empresa "+SUBSTR(SM0->M0_CODFIL,1,2)
			TTRB->FILIAL  :=  SM0->M0_NOMECOM
			TTRB->DTLANC  :=  Stod(fRetDtMov(SM0->M0_CODFIL,nOpc))
			MsunLock()
		EndIf
		SM0->(DbSkip())
	EndDo
EndIf

//Define quais colunas (campos da TTRB) serao exibidas na MsSelect
aCpoBro	:= {{ "OK"			,, "  "          ,"@!"},;
{ "CODIGO"		,, "Filial"      ,"@!"},;
{ "FILIAL"		,, "Descrição"   ,"@!"},;
{ "DTLANC"		,, "Data"        ,"@!"}}
//Cria uma Dialog
DEFINE MSDIALOG oDlg TITLE cDescricao From 9,0 To 315,550 PIXEL
DbSelectArea("TTRB")
DbGotop()
//Cria a MsSelect
oMark := MsSelect():New("TTRB","OK","",aCpoBro,@lInverte,@cMark,{01,1,130,275},,,,,)
oMark:bMark := {| | Disp()}
//Exibe a Dialog

DEFINE SBUTTON FROM 140,145 TYPE 1 ACTION Iif(ChamaMsg(nOpc),oDlg:End(),Nil) ENABLE OF oDlg
DEFINE SBUTTON FROM 140,175 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg


ACTIVATE MSDIALOG oDlg CENTERED

TTRB->(DbCloseArea())
Iif(File(cArq + GetDBExtension()),FErase(cArq  + GetDBExtension()) ,Nil)

Return
//---------------------------------------------------------------------
/*/{Protheus.CODIGO} Disp()
Funcao executada ao Marcar/Desmarcar um registro.

@author Jair  Matos
@since 10/10/2018
@version P11
@return cNfs
/*/
//---------------------------------------------------------------------
Static Function Disp()
RecLock("TTRB",.F.)
If Marked("OK")
	TTRB->OK := cMark
Else
	TTRB->OK := ""
Endif
MSUNLOCK()
oMark:oBrowse:Refresh()
Return()
//---------------------------------------------------------------------
/*/{Protheus.CODIGO} ChamaMsg()
Funcao executada ao Marcar/Desmarcar um registro.

@author Jair  Matos
@since 10/10/2018
@version P11
@return cNfs
/*/
//---------------------------------------------------------------------
Static Function ChamaMsg(nOpc)
  
Local lRet := .T.
nCont := 0  
//Fecha a Area e elimina os arquivos de apoio criados em disco.
TTRB->(DbGotop())
While  TTRB->(!Eof())
	If !Empty(TTRB->OK)
		If nOpc == 1
			aAdd(aFiliais, TTRB->CODIGO)
			nCont++
		ElseIf nOpc == 2
			aAdd(aEmpFIN, TTRB->CODIGO)
			nCont++
		Else
			aAdd(aEmpFIS, TTRB->CODIGO)
			nCont++
		EndIf
	EndIf
	TTRB->(DbSkip())
Enddo
If nCont <=0
	MsgAlert("Selecione a filial antes de confirmar .","Aviso")
	lRet := .F.
EndIf
TTRB->(DbGotop())
oMark:oBrowse:Refresh()

Return  lRet
//---------------------------------------------------------------------
/*/{Protheus.CODIGO} fRetDtMov()
Funcao executada para retornar a data da ultima movimentação de acordo com o parametro

@author Jair  Matos
@since 11/10/2018
@version P12
@return dUltMov
/*/
//---------------------------------------------------------------------
Static Function fRetDtMov(cFilParam,nOpc)
Local dUltMov  := ""

DbSelectArea("SX6") //Abre a tabela SX6
DbSetOrder(1) //Se posiciona no primeiro indice
If nOpc == 1
	If DbSeek(Alltrim(cFilParam)+"MV_DBLQMOV") //Verifique se o parametro existe
		dUltMov := SX6->X6_CONTEUD
	EndIf
ElseIf nOpc == 2 
	If DbSeek(Alltrim(cFilParam)+"MV_DATAFIN") //Verifique se o parametro existe
		dUltMov := SX6->X6_CONTEUD
	EndIf	
Else
	If DbSeek(Alltrim(cFilParam)+"MV_DATAFIS") //Verifique se o parametro existe
		dUltMov := SX6->X6_CONTEUD
	EndIf	
EndIf
return dUltMov
