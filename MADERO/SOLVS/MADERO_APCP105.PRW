#include "rwmake.ch"
#include "topconn.ch"
#include "totvs.ch"
#include "protheus.ch"
/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! PCP - Faturamento                                       !
+------------------+---------------------------------------------------------+
!Nome              ! APCP105                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Tela de Cadastro de Produtos X Etiquetas                !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 17/06/2018                                              !
+------------------+---------------------------------------------------------+
*/
User Function APCP105(nOpcao)

Local oFontCli  := TFont():New("Arial",0,-14,,.T.,,,,,.F.,.F.)
Local aCampos   := {}
Local cLinOk    := "U_APCP105B()"//"AllwaysTrue"
Local cTudoOk   := "U_APCP105C()"
Local cFieldOk  := "NaoVazio()" //"AllwaysTrue"
Local cSuperDel := ""
Local cDelOk    := "AllwaysTrue"
Local aArea     := GetArea()
Local cPesq     := Space(100)

Private cCodigo := IIF(INCLUI,&("M->B1_COD"), &("SB1->B1_COD"))
Private cDescri := IIF(INCLUI,&("M->B1_DESC"), &("SB1->B1_DESC"))

Private aHETIQ := {}
Private aCETIQ := {}

Private nOpc := 0

DEFAULT nOpcao := 2

nOpc := nOpcao

If (Select("TMP010") <> 0) .AND. !INCLUI
	dbSelectArea("TMP010")
	dbCloseArea("TMP010")
EndIf

If !(Select("TMP010") <> 0)
	aAdd(aCampos,{"PRODUTO"  ,"C", TAMSX3("B1_COD")[1], 0})
	aAdd(aCampos,{"DESCPRO"  ,"C", TAMSX3("B1_DESC")[1], 0})
	aAdd(aCampos,{"ETIQUET"  ,"C", TAMSX3("ZIA_TPETQ")[1] , 0})
	aAdd(aCampos,{"DESCETQ"  ,"C", TAMSX3("ZIA_DESC")[1], 0})
	aAdd(aCampos,{"QTDE"     ,"N", TAMSX3("ZIB_QTDE")[1], 0})
	aAdd(aCampos,{"APONT"    ,"C", TAMSX3("ZIB_APONTA")[1], 0})
	aAdd(aCampos,{"IMPPAD"   ,"C", TAMSX3("ZIA_IMPPAD")[1], 0})
	aAdd(aCampos,{"DELETA"   ,"L", 1, 0})
	
	cTrab := CriaTrab(aCampos)
	
	dbUseArea(.T.,,cTrab,"TMP010",nil,.F.)
	IndRegua("TMP010",cTrab,"ETIQUET")
	dbClearIndex()
	dbSetIndex(cTrab + OrdBagExt())
	
	//================================= BUSCA INFORMAÇÕES JÁ REGISTRADAS =================================//
	cAliasZIB := GetNextAlias()
	
	cQuery := "SELECT * FROM " + RETSQLNAME("ZIB") + " ZIB, "
	cQuery += RETSQLNAME("ZIA") + " ZIA "
	cQuery += "WHERE ZIB.D_E_L_E_T_ = '' "
	cQuery += "AND ZIA.D_E_L_E_T_ = '' "
	cQuery += "AND ZIB.ZIB_FILIAL = '" + xFilial("ZIB") + "' "
	cQuery += "AND ZIA.ZIA_FILIAL = '" + xFilial("ZIA") + "' "
	cQuery += "AND ZIB.ZIB_PRODUT = '" + cCodigo + "' "
	cQuery += "AND ZIB.ZIB_TPETQ = ZIA.ZIA_TPETQ "
	cQuery += "ORDER BY ZIB.ZIB_TPETQ "
	
	cQuery := ChangeQuery(cQuery)
	
	If (Select(cAliasZIB) <> 0)
		dbSelectArea(cAliasZIB)
		dbCloseArea(cAliasZIB)
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	TCQUERY cQuery NEW ALIAS &(cAliasZIB)
	
	dbSelectArea(cAliasZIB)
	dbGoTop()
	While !Eof()
		
		AADD(aCETIQ,{(cAliasZIB)->ZIB_TPETQ,(cAliasZIB)->ZIA_DESC,(cAliasZIB)->ZIB_QTDE,(cAliasZIB)->ZIB_APONTA,(cAliasZIB)->ZIA_IMPPAD,.F.})
		
		dbSelectArea(cAliasZIB)
		(cAliasZIB)->(dbSkip())
	EndDo
Else
	dbSelectArea("TMP010")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(cCodigo)
		While !Eof() .And. TMP010->PRODUTO == cCodigo
			
			AADD(aCETIQ,{TMP010->ETIQUET,TMP010->DESCETQ,TMP010->QTDE,TMP010->APONT,TMP010->IMPPAD,.F.})
			
			dbSelectArea("TMP010")
			TMP010->(dbSkip())
		EndDo
	EndIf
EndIf

//AADD(aHEtiq,{"Código"     ,"ETIQUET" , "@!",TAMSX3("ZIA_TPETQ")[1],0,"U_APCP105A()",,"C","ZIA",})
AADD(aHEtiq,{"Código"     ,"ETIQUET" , "@!",TAMSX3("ZIA_TPETQ")[1] ,0,"NaoVazio() .AND. U_APCP105A()",,"C","ZIA",,,})
AADD(aHEtiq,{"Descrição"  ,"DESCETQ" , "@!",TAMSX3("ZIA_DESC")[1]  ,0,                ,,"C",     ,"V",,})
AADD(aHEtiq,{"Qtde"       ,"QTDE"    , "9999",TAMSX3("ZIB_QTDE")[1],0,"M->QTDE>0" ,,"N",     ,,,})
AADD(aHEtiq,{"Imp.Apont"  ,"APONT"   , "@!",TAMSX3("ZIB_APONTA")[1],0,"pertence('SN')",,"C",     ,,"S=Sim;N=Nao",})
AADD(aHEtiq,{"Impressora" ,"IMPPAD"  , "@!",TAMSX3("ZIA_IMPPAD")[1],0,              ,,"C",     ,"V",,})
/*
aAdd(aHeader,{AllTrim(X3Titulo()),;   1
SX3->X3_CAMPO,;                        2
SX3->X3_PICTURE,;                     3
SX3->X3_TAMANHO,;                     4
SX3->X3_DECIMAL,;                     5
SX3->X3_VALID,;                       6
SX3->X3_USADO,;                       7
SX3->X3_TIPO,;                        8
SX3->X3_F3,;                          9
SX3->X3_CONTEXT,;                     10
SX3->X3_CBOX,;                        11
SX3->X3_RELACAO})                     12
*/


aOrdem := {"1=Etiqueta","2=Descrição"}
//cOrdem := "1"

DEFINE MSDIALOG oDlgEtiq TITLE "[APCP105] - Produtos x Etiquetas" From 001,001 to 490,738 COLORS CLR_BLACK, CLR_WHITE Pixel STYLE DS_MODALFRAME

//============================ PRODUTO =============================//
oGrpProd := tGroup():New(005,005,032,365,"Produto",oDlgEtiq,CLR_HBLUE,,.T.)
oSayCli  := tSay():New(018,015,{|| ALLTRIM(cCodigo) + " - " + ALLTRIM(cDescri)},oGrpProd,,oFontCli,,,,.T.,CLR_HBLUE,CLR_WHITE,500,12)
//============================ PESQUISA =============================//
//oGrpPesq := tGroup():New(037,005,065,365,"Pesquisa",oDlgEtiq,CLR_HBLUE,,.T.)
//oCmbPesq := tComboBox():New(050,010,{|u|if(PCount()>0,cOrdem:=u,cOrdem)},aOrdem,50,9,oGrpPesq,, { ||  } ,,,,.T.,,,,,,,,,'cOrdem')
//oGetPesq := tGet():New(050,065,{|u| if(PCount()>0,cPesq:=u,cPesq)}, oGrpPesq,150,9,'@!',{ ||  },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,'cPesq')
//oBtnPesq := tButton():New(050, 220, "Buscar", oGrpPesq, { || oBrwEtiq:GoTo(aScan(oBrwEtiq:aCols,{ |x| ALLTRIM(cPesq) $ ALLTRIM(x[Val(cOrdem)]) } )) },35,11,,,,.T.,,,, { || .T. },,)
//============================ MODELOS ETIQUETAS =============================//
oGrpBrow  := tGroup():New(037,005,220,365,"Etiquetas", oDlgEtiq,CLR_HBLUE,,.T.)
oBrwEtiq := MsNewGetDados():New(050,010,215,360,GD_INSERT+GD_DELETE+GD_UPDATE,cLinOk,cTudoOk,,{"ETIQUET","QTDE","APONT"},0,9999,cFieldOk,cSuperDel,cDelOk,oGrpBrow,aHEtiq,aCEtiq)

oBtnConf := tButton():New(225, 275, "Confirmar", oDlgEtiq, {|| Processa({ || fGravaDados() }, "[APCP105] - AGUARDE"),oDlgETIQ:End() },40,12,,,,.T.,,,, { || .T. },,)
oBtnSair := tButton():New(225, 325, "Sair" , oDlgEtiq, {|| oDlgEtiq:End() },40,12,,,,.T.,,,, { || .T. },,)

oBtnConf:Disable()

ACTIVATE MSDIALOG oDlgETIQ CENTERED

RestArea(aArea)

Return

//===================================================== BUSCA DESCRIÇÃO DA ETIQUETA =====================================================//
User Function APCP105A()
Local lRet  := .T.
Local nPosETIQ := aScan(aHETIQ,{|x| ALLTRIM(x[2]) == "ETIQUET"})
Local nPosDescri := aScan(aHETIQ,{|x| ALLTRIM(x[2]) == "DESCETQ"})
Local nPosImp := aScan(aHETIQ,{|x| ALLTRIM(x[2]) == "IMPPAD"})
Local i

//msginfo(oBrwETIQ:aCols[oBrwETIQ:nAt,nPosETIQ])
//MSGINFO(M->ETIQUET)

//
For i:=1 to Len(oBrwETIQ:aCols)
	If !oBrwETIQ:aCols[i,Len(oBrwETIQ:aCols[i])]
		If M->ETIQUET == oBrwETIQ:aCols[i,nPosETIQ] .And. i != oBrwETIQ:nAt
			lRet := .F.
		EndIf
	EndIf
Next i

If lRet
	DBSELECTAREA("ZIA")
	DBSETORDER(1)
	ZIA->(DBSEEK(XFILIAL("ZIA")+M->ETIQUET))
	IF ZIA->(FOUND())
		oBrwETIQ:aCols[oBrwETIQ:nAt,nPosDescri] := ZIA->ZIA_DESC
		oBrwETIQ:aCols[oBrwETIQ:nAt,nPosimp] := ZIA->ZIA_IMPPAD
	ELSE
//		oBrwETIQ:aCols[oBrwETIQ:nAt,nPosDescri] := TAMSX3("ZIA_DESC")[1]
//		oBrwETIQ:aCols[oBrwETIQ:nAt,nPosimp] := TAMSX3("ZIA_IMPPAD")[1]
//		oBrwETIQ:aCols[oBrwETIQ:nAt,nPosEtiq] := TAMSX3("ZIA_TPETQ")[1]  
		//oBrwETIQ:aCols[oBrwETIQ:nAt,nPosEtiq]:SetFocus()               
		M->ETIQUET:=SPACE(TAMSX3("ZIA_TPETQ")[1])
		ApMsgStop("Verifique Tipo Etiqueta não cadastrado!")
		_LRET:=.F.
	ENDIF
ELSE
	ApMsgStop("Esta Etiqueta já foi cadastrada!")
EndIf

Return lRet

//===================================================== BUSCA DESCRIÇÃO DA ETIQUETA =====================================================//
User Function APCP105B()
Local lRet  := .T.
Local nPosETIQ := aScan(aHETIQ,{|x| ALLTRIM(x[2]) == "ETIQUET"})
Local nPosQTD := aScan(aHETIQ,{|x| ALLTRIM(x[2]) == "QTDE"})
Local nPosImp := aScan(aHETIQ,{|x| ALLTRIM(x[2]) == "IMPPAD"})
Local nPosAPO := aScan(aHETIQ,{|x| ALLTRIM(x[2]) == "APONT"})
//msginfo(oBrwETIQ:aCols[oBrwETIQ:nAt,nPosETIQ])
//MSGINFO(M->ETIQUET)       
If !oBrwETIQ:aCols[oBrwETIQ:nAt,Len(oBrwETIQ:aCols[oBrwETIQ:nAt])]
	If EMPTY(oBrwETIQ:aCols[oBrwETIQ:nAt,nPosETIQ]) .OR. EMPTY(oBrwETIQ:aCols[oBrwETIQ:nAt,nPosAPO]) .OR. (oBrwETIQ:aCols[oBrwETIQ:nAt,nPosQTD])==0
		lRet := .F.
	EndIf
EndIf
//         
If lRet
   oBtnConf:enable()
Else
	ApMsgStop("Verifique!!..Existe campos obrigatorios não informadosb!!")
	oBtnConf:Disable()   
EndIf
//	
Return lRet

//===================================================== BUSCA DESCRIÇÃO DA ETIQUETA =====================================================//
User Function APCP105c()
Local lRet  := .T.
Local nPosETIQ := aScan(aHETIQ,{|x| ALLTRIM(x[2]) == "ETIQUET"})
Local nPosQTD := aScan(aHETIQ,{|x| ALLTRIM(x[2]) == "QTDE"})
Local nPosImp := aScan(aHETIQ,{|x| ALLTRIM(x[2]) == "IMPPAD"})
Local nPosAPO := aScan(aHETIQ,{|x| ALLTRIM(x[2]) == "APONT"})
Local i
//msginfo(oBrwETIQ:aCols[oBrwETIQ:nAt,nPosETIQ])
//MSGINFO(M->ETIQUET)       
For i:=1 to Len(oBrwETIQ:aCols)
	If !oBrwETIQ:aCols[i,Len(oBrwETIQ:aCols[i])]
		If EMPTY(oBrwETIQ:aCols[i,nPosETIQ]) .OR. EMPTY(oBrwETIQ:aCols[i,nPosAPO]) .OR. (oBrwETIQ:aCols[i,nPosQTD])==0
			lRet := .F.
		EndIf
	EndIf
Next i
//         
If lRet
   oBtnConf:enable()
Else
	ApMsgStop("Verifique!!..Existe campos obrigatorios não informadosc!!")
	oBtnConf:Disable()   
EndIf
//	
Return lRet
//===================================================== GRAVA INFORMAÇÕES DOS EQUIVALENTES =====================================================//
Static Function fGravaDados()

Local lEtiq := .F.
Local i

ProcRegua(Len(oBrwEtiq:aCols))

For i:=1 to Len(oBrwEtiq:aCols)
	
	IncProc("Registrando Etiquetas...")
	
	If Empty(oBrwEtiq:aCols[i,1]) .or. (oBrwEtiq:aCols[i,3])=0 .or. Empty(oBrwEtiq:aCols[i,4])
		Loop
	EndIf                 

	dbSelectArea("TMP010")
	dbSetOrder(1)
	dbGoTop()
	lGrava := !dbSeek(cCodigo+oBrwETIQ:aCols[i,1])
	
	Reclock("TMP010",lGrava)
	TMP010->PRODUTO := cCodigo
	TMP010->DESCPRO := cDescri
	TMP010->ETIQUET := oBrwETIQ:aCols[i,1]
	TMP010->DESCETQ := oBrwETIQ:aCols[i,2]
	TMP010->QTDE    := oBrwETIQ:aCols[i,3]
	TMP010->APONT   := oBrwETIQ:aCols[i,4]
	TMP010->DELETA  := oBrwETIQ:aCols[i,Len(oBrwETIQ:aCols[i])]
	TMP010->(MsUnlock())
Next i

If nOpc == 2
	If (Select("TMP010") <> 0)
		dbSelectArea("TMP010")
		ProcRegua(TMP010->(RecCount()))
		dbGoTop()
		While !Eof()
			
			IncProc("Registrando Etiquetas...")
			
			dbSelectArea("ZIB")
			dbSetOrder(1)
			dbGoTop()
			If !dbSeek(xFilial("ZIB")+TMP010->PRODUTO+TMP010->ETIQUET)
				If !TMP010->DELETA
					Reclock("ZIB",.T.)
					ZIB->ZIB_FILIAL  := xFilial("ZIB")
					ZIB->ZIB_PRODUT := TMP010->PRODUTO
					//					ZIB->ZIB_DESC := TMP010->DESCPRO
					ZIB->ZIB_TPETQ   := TMP010->ETIQUET
					ZIB->ZIB_QTDE    := TMP010->QTDE
					ZIB->ZIB_APONTA  := TMP010->APONT
					ZIB->(MsUnlock())
				EndIf
			Else
				If !TMP010->DELETA
					Reclock("ZIB",.F.)
					ZIB->ZIB_TPETQ   := TMP010->ETIQUET
					ZIB->ZIB_QTDE    := TMP010->QTDE
					ZIB->ZIB_APONTA  := TMP010->APONT
					ZIB->(MsUnlock())
				Else
					Reclock("ZIB",.F.)
					ZIB->(dbDelete())
					ZIB->(MsUnlock())
				EndIf
			EndIf
			
			dbSelectArea("TMP010")
			TMP010->(dbSkip())
		EndDo
		
		dbCloseArea("TMP010")
	EndIf
EndIf

Return
