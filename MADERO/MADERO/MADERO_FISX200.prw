#INCLUDE "Protheus.CH"

#INCLUDE "Topconn.ch"
/*
+----------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Customização                                            !
+------------------+---------------------------------------------------------+
!Modulo            ! LIVROS FISCAIS                                          !
+------------------+---------------------------------------------------------+
!Nome              ! FISX200                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! FUNCOES INTEGRACAO Codigos e Servicos - PROTHEUS X CSV  !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Andrade   										 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 14/01/2018                                              !
+------------------+---------------------------------------------------------+
!				   !														 !
!				   !												         !
+------------------+---------------------------------------------------------+

*/

User Function FISX200()
Local aButtons := {}
Local cCadastro := "Integração Codigos e Servicos(MATA963) Excel X Protheus"
Local nOpca     	:= 0
Local aSays     	:= {}
Local aArea			:= GetArea()
Private cArquivo	:= ""
Private aFiliais 	:= {}
Private aTabelas 	:={} 

AADD(aSays,OemToAnsi("Este programa tem o objetivo importar Codigos e Servicos do arquivo Excel..."       ))
AADD(aSays,OemToAnsi("Os códigos pertencem a rotina MATA963- Relacionamento de Codigos e Serviços."       ))
AADD(aSays,OemToAnsi(""																					  ))
AADD(aSays,OemToAnsi("Clique no botão PARÂMETROS para selecionar o ARQUIVO CSV de interface."	          ))
AADD(aSays,OemToAnsi("Clique no botão FILTRAR para selecionar a(s) FILIAL(is)."		                      ))
AADD(aButtons, { 1,.T.						,{|o| (Iif(ImpArq(),o:oWnd:End(),Nil)) 						  }})
AADD(aButtons, { 2,.T.						,{|o| o:oWnd:End()											  }})
AADD(aButtons, { 5,.T.						,{|o| (AbreArq(),o:oWnd:refresh())							  }})
AADD(aButtons, { 17,.T.						,{|o| (ChamaSM0(1),o:oWnd:refresh())						  }})
FormBatch( cCadastro, aSays, aButtons )
RestArea(aArea)
Return .T.
 
/*---------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Descricao         ! Seleciona arquivo que será copiado para a pasta         !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                              !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 14/01/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function AbreArq()

Local cType		:=	"Arquivos CSV|*.CSV|Todos os Arquivos|*.*"
cArquivo := cGetFile(cType, OemToAnsi("Selecione o arquivo de interface"),0,"C:\",.F.,GETF_LOCALHARD,.F.)

Return()
/*---------------------------------------------------------------------------+
!   DADOS DO PROGRAMA   - IMPARQ()                                           !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina que prepara a importação do arquivo              !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                              !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 14/01/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function ImpArq()
Local lRet := .T.
Private nHdl	:= 0

If !File(cArquivo)
	Aviso("Atenção !","Arquivo não selecionado ou inválido !",{"Ok"})
	Return .F.
Endif

If Empty(aFiliais)
	Aviso("Atenção !","Selecione uma filial antes de prosseguir.",{"Ok"})
	Return .F.
EndIf

ProcRegua(474336)

BEGIN TRANSACTION
Processa({|| Importa() },"Processando...")
END TRANSACTION

Return lRet

/*---------------------------------------------------------------------------+
!   DADOS DO PROGRAMA   - Importa()                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina que prepara a importação do arquivo              !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                              !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 14/01/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function Importa()
Local cLog		:= ""
Local nCont 	:= 0
Local nRepet  	:= 0
Local cEol     	:= CHR(13)+CHR(10)
Local lErroSE5 	:= .F.
Local cLinha  	:= ""
Local aDados  	:= {}
Local nX := 0
Local nX1 := 0
Local nProc := 0
Local nIns := 0
Local nQtdPrd := 0
Local aProd
Local aTpSrv
Local aLst
Local aIss
Local nOpc := 0
Local aCabec    := {}
Local cFilOri 		:= cFilAnt
Private lMsErroAuto := .F.
Private aRotina := {}
Private oModel := Nil

FT_FUSE(cArquivo)
FT_FGOTOP()
While !FT_FEOF()
	
	cLinha := FT_FREADLN()
	
	If !Empty(cLinha) .and. Substr(cLinha,1,1)<>";"
		AADD(aDados,Separa(cLinha,";",.T.))
		nProc++
	EndIf
	
	FT_FSKIP()
EndDo
FT_FUSE()

If !Empty(aFiliais)
	nCont := Len(aFiliais)
	For nX1 := 1 To Len(aFiliais)//verifica as filiais selecionadas e grava os dados para estas filiais
		nIns := 0
		nRepet := 0
		nQtdPrd := 0
		cFilAnt := aFiliais[nX1]
		For nX:=2 to Len(aDados)//a primeira linha é o cabeçalho
			//Chama a rotina de execauto
			Begin Transaction
			aCabec  := {}
			aProd 	:= strtokarr ( aDados[nX][2] , "|")
			aIss 	:= strtokarr ( aDados[nX][3] , "|")
			aLst 	:= strtokarr ( aDados[nX][4] , "|")
			aTpSrv 	:= strtokarr ( aDados[nX][5] , "|")
			
			aadd(aCabec,{"CDN_DESCR",Substr(Alltrim(aDados[nX][1]),1,TamSX3("CDN_DESCR")[1])})
			aadd(aCabec,{"CDN_PROD",aProd[1]})
			aadd(aCabec,{"CDN_FILIAL",aFiliais[nX1]})
			aadd(aCabec,{"CDN_CODISS",PadR(aIss[1],TamSX3("CDN_CODISS")[1]," ")})
			aadd(aCabec,{"CDN_CODLST",aLst[1]})
			aadd(aCabec,{"CDN_TPSERV",aTpSrv[1]})
			
			//Verifica se produto existe na filial. Caso produto não existir, pula o produto.
			If !Empty(aProd[1])
				dbSelectArea("SB1")
				dbSetOrder(1)
				If !dbSeek(aFiliais[nX1] + aProd[1])
					nQtdPrd++
				Else
					oModel := FwLoadModel ("MATA963")
					DbSelectArea("CDN")
					dbSetOrder(1)//CDN_FILIAL+CDN_CODISS+CDN_PROD
					If dbSeek(aFiliais[nX1] +PadR(aIss[1],TamSX3("CDN_CODISS")[1]," ")+ aProd[1])
						nRepet++
						//Chamando a inclusão - Modelo 1
						lMsErroAuto := .F.
						FWMVCRotAuto( oModel,"CDN",4,{{"MATA963MOD", aCabec}})
						If lMsErroAuto
							DisarmTransaction()
							MostraErro()
							Break
						EndIf
					Else
						nIns++
						lMsErroAuto := .F.
						FWMVCRotAuto( oModel,"CDN",3,{{"MATA963MOD", aCabec}})
						If lMsErroAuto
							DisarmTransaction()
							MostraErro()
							Break
						EndIf
					EndIf
					
				EndIf
			EndIf
			End Transaction
		Next nX
		aFiliais[nX1] := "Filial: "+aFiliais[nX1]+" Total: "+Alltrim(Str(nIns))+" códigos inseridos, "+Alltrim(Str(nQtdPrd))+" códigos não encontrados, "+Alltrim(Str(nRepet))+" códigos alterados."
	Next nX1
EndIf

//nOpc := Aviso("Concluído","Importação executada com sucesso!"+Chr(13)+ Chr(10)+"Total: "+Chr(13)+ Chr(10)+Alltrim(Str(nProc-1))+" registros processados"+Chr(13)+ Chr(10)+Alltrim(Str(nCont))+" filial(is) selecionada(s).", {"Arq.Log","Ok"}, 2)
cMsg :=  "Importação executada com sucesso!"+Chr(13)+ Chr(10)+"Total: "+Chr(13)+ Chr(10)+Alltrim(Str(nProc-1))+" registros processados"+Chr(13)+ Chr(10)+Alltrim(Str(nCont))+" filial(is) selecionada(s)."
//Tela final para gerar o Log.
GerLog(cMsg, "GeraLog", 1, .F.)
//retorna para a filial correta
cFilAnt :=cFilOri

Return
//---------------------------------------------------------------------
/*/{Protheus.CODIGO} ChamaSM0(1)
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
Local cArq
Private lInverte := .F.
Private cMark   := GetMark()
Private oMark
//Cria um arquivo de Apoio
AADD(_stru,{"OK"     ,"C"	,2						,0		})
AADD(_stru,{"CODIGO" ,"C"	,TamSX3("A1_FILIAL")[1]	,0		})
AADD(_stru,{"FILIAL" ,"C"	,40						,0		})
AADD(_stru,{"DTLANC" ,"C"	,14						,0		})
cArq:=Criatrab(_stru,.T.)
DBUSEAREA(.t.,,carq,"TTRB")
//Verificar as filiais selecionadas
DbSelectArea("SM0")
SM0->(DbGoTop())
If nOpc == 1
	cDescricao := "Relação de Filiais"
	While !SM0->(EoF())
		If SM0->M0_CODIGO == cEmpAnt
			DbSelectArea("TTRB")
			RecLock("TTRB",.T.)
			TTRB->CODIGO  :=  SM0->M0_CODFIL
			TTRB->FILIAL  :=  SM0->M0_FILIAL
			TTRB->DTLANC  :=   Iif(fVerProc(SM0->M0_CODFIL,"",""),"Processado","Não Processado")
			MsunLock()
		EndIf
		SM0->(DbSkip())
	EndDo
Else
	cDescricao := "Relação de Empresas"
	While !SM0->(EoF())
		If SM0->M0_CODIGO == cEmpAnt   .AND. SUBSTR(SM0->M0_CODFIL,1,2)<>cEmpAtual
			cEmpAtual := SUBSTR(SM0->M0_CODFIL,1,2)
			DbSelectArea("TTRB")
			RecLock("TTRB",.T.)
			TTRB->CODIGO  :=  "Empresa "+SUBSTR(SM0->M0_CODFIL,1,2)
			TTRB->FILIAL  :=  SM0->M0_NOMECOM
			TTRB->DTLANC  :=  Iif(fVerProc(SM0->M0_CODFIL),"Processado","Não Processado")
			MsunLock()
		EndIf
		SM0->(DbSkip())
	EndDo
EndIf

//Define quais colunas (campos da TTRB) serao exibidas na MsSelect
aCpoBro	:= {{ "OK"			,, "  "          ,"@!"},;
{ "CODIGO"		,, "Filial"      ,"@!"},;
{ "FILIAL"		,, "Descrição"   ,"@!"},;
{ "DTLANC"		,, "Status"       ,"@!"}}
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
/*/{Protheus.CODIGO} fVerProc(cFili)
Funcao executada para retornar se filial tem dados processados

@author Jair  Matos
@since 11/10/2018
@version P12
@return dUltMov
/*/
//---------------------------------------------------------------------
Static Function fVerProc(cFilAn,cCodISS,cCodProd)
Local lRet := .T.
Local cQuery :=""
Local nSaldo := 0

If select("TRBCDN")<>0
	TRBCDN->(dbclosearea())
EndIf

cQuery += " SELECT CDN_FILIAL "
cQuery += " FROM "+RetSQLName("CDN") + "  "
cQuery += " WHERE CDN_FILIAL = '" + cFilAn+ "' "
If !Empty(cCodISS)
	cQuery += " AND CDN_CODISS = '" + cCodISS+ "' "
EndIf
If !Empty(cCodProd)
	cQuery += " AND CDN_PROD = '" + cCodProd+ "' "
EndIf
cQuery += " AND D_E_L_E_T_= ' ' "
//Memowrite("c:\temp\fVerProc.txt",cQuery)
TcQuery cQuery new Alias "TRBCDN"
DbSelectArea("TRBCDN")
TRBCDN->(DbGoTop())

If TRBCDN->(EOF())
	lRet := .F.
EndIf
Return lRet
//---------------------------------------------------------------------
/*/{Protheus.CODIGO} fVerProc(cMsg, cTitulo, nTipo, lEdit)
Funcao que gera log em TXT

@author Jair  Matos
@since 05/02/2019
@version P12
@return
/*/
//---------------------------------------------------------------------
Static Function GerLog(cMsg, cTitulo, nTipo, lEdit)
Local lRetMens := .F.
Local oDlgMens
Local oBtnOk, cTxtConf := ""
Local oBtnCnc, cTxtCancel := ""
Local oBtnSlv
Local oFntTxt := TFont():New("Lucida Console",,-015,,.F.,,,,,.F.,.F.)
Local oMsg
Local nIni:=1
Local nFim:=50
Default cMsg    := "..."
Default cTitulo := "Gera Log"
Default nTipo   := 1 // 1=Ok; 2= Confirmar e Cancelar
Default lEdit   := .F.

//Definindo os textos dos botões
If(nTipo == 1)
	cTxtConf:='&Ok'
Else
	cTxtConf:='&Confirmar'
	cTxtCancel:='C&ancelar'
EndIf

//Criando a janela centralizada com os botões
DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 300, 400 COLORS 0, 16777215 PIXEL
//Get com o Log
@ 002, 004 GET oMsg VAR cMsg OF oDlgMens MULTILINE SIZE 191, 121 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
If !lEdit
	oMsg:lReadOnly := .T.
EndIf

//Se for Tipo 1, cria somente o botão OK
If (nTipo==1)
	@ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 019 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
	
	//Senão, cria os botões OK e Cancelar
ElseIf(nTipo==2)
	@ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 009 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
	@ 137, 144 BUTTON oBtnCnc PROMPT cTxtCancel SIZE 051, 009 ACTION (lRetMens:=.F., oDlgMens:End()) OF oDlgMens PIXEL
EndIf

//Botão de Salvar em Txt
@ 127, 004 BUTTON oBtnSlv PROMPT "&Gerar Log em .txt" SIZE 051, 019 ACTION (fSalvArq(cMsg, cTitulo)) OF oDlgMens PIXEL
ACTIVATE MSDIALOG oDlgMens CENTERED

Return lRetMens

/*-----------------------------------------------*
| Função: fSalvArq                              |
| Descr.: Função para gerar um arquivo texto    |
*-----------------------------------------------*/

Static Function fSalvArq(cMsg, cTitulo)
Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".txt"
Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
Local lOk      := .T.
Local cTexto   := ""
Local nX := 0

//Pegando o caminho do arquivo
cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,"C:\",.F.,GETF_LOCALHARD,.F.)

//Se o nome não estiver em branco
If !Empty(cFileNom)
	//Teste de existência do diretório
	If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
		Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
		Return
	EndIf
	
	//Montando a mensagem
	cTexto := "Função - "+ FunName()
	cTexto += " Usuário - "+ cUserName
	cTexto += " Data - "+ dToC(dDataBase)
	cTexto += " Hora - "+ Time() + cQuebra  + cMsg + cQuebra
	For nX := 1 To Len(aFiliais)
		cTexto +=aFiliais[nX]+ CRLF
	Next nX
	
	//Testando se o arquivo já existe
	If File(cFileNom)
		lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
	EndIf
	
	If lOk
		MemoWrite(cFileNom, cTexto)
		MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atenção")
	EndIf
EndIf
Return
