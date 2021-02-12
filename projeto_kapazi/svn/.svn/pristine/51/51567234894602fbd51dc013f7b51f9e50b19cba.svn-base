#include 'protheus.ch'
#Include "FwMvcDef.ch"
#Include 'parmtype.ch'
#Include "tbiconn.ch"
#Include "TbiCode.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include 'TOTVS.CH'
//==================================================================================================//
//	Programa: TELASLDO		|	Autor: Luis Paulo							|	Data: 10/06/2020	//
//==================================================================================================//
//	Descrição: Tela de saldo de op              													//
//	-																								//
//==================================================================================================//
User Function TELASLDO()
Local lRet := .t.

If !IsBlind() .And. IsInCallStack("MATA681")
	MostraTLOP()
EndIf

Return(lRet)

Static Function MostraTLOP()
Local cAlias		:="SC2"
Local nReg			:= SC2->(RECNO())
Local nOpc			:= 2	//Visualizar sempre

//MsGetDados():New(nTop,nLeft,nBottom,nRight,nOpc,cLinhaOk,cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,,cDelOk,oWnd,lUseFreeze,cTela)
//{20,10,130,390}	
Local nTop     		:= 35
Local nLeft    		:= 05
Local nBottom  		:= 250
Local nRight   		:= 520
Local cLinhaOk 		:= "AllwaysTrue"  					//"U_RetTrue()"
Local cTudoOk  		:= "AllwaysTrue" //"AllwaysTrue"     //"U_RetTrue()"
Local cIniCpos 		:= ""//"+Z55_ITEM"
Local lDeleta  		:= .T.
Local aAlter   		:= {}
Local nFreeze  		:= 1
Local lEmpty   		:= .F.
Local nMax     		:= 99
Local cFieldOk 		:= "AllwaysTrue"
Local cSuperDel		:= "AllwaysTrue"
Local cDelOk   		:= "AllwaysTrue"
Local lUseFreeze 	:= .F.

Local oDlg
Local oGD
Local nBtoOk		:= 0 
Private aHeader 	:= {}
Private aCols 		:= {}
Private	aECV1		:= {}
Private	aGCV1		:= {}
Private aNroLin		:= {}
Private aCEncGra	:= {}
Private cAliasC2	:= GetNextAlias()
Private nRegs		:= 0
Private cAliasC2
Private cOpMem      := Substr(M->H6_OP,1,6)
Private aRotina     := {{"Pesquisar", "AxPesqui", 0, 1},;
                        {"Visualizar", "AxVisual", 0, 2},;
                        {"Incluir", "AxInclui", 0, 3},;
                        {"Alterar", "AxAltera", 0, 4},;
                        {"Excluir", "AxDeleta", 0, 5}}

//Criar as variaveis de memoria
If nOpc == 3 						//Inclusão, cria as variaveis de memoria para o cabecalho(MsGetDados)
	RegToMemory(cAlias, (nOpc==3))
Else
	RegToMemory(cAlias, .F. )
EndIf

CargaAHeader(cAlias)			//Funcao que faz a carga dos campos do aHeader
CargaCols(cAlias,nOpc)			//Funcao que faz a carga dos campos do aCols

DEFINE MSDIALOG oDlg TITLE "SALDOS PENDENTES DE APONTAMENTO" FROM 0,0 TO 500,1040 PIXEL

oGD := MsGetDados():New(nTop,nLeft,nBottom,nRight,nOpc,cLinhaOk,cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel, ,cDelOk,oDlg,lUseFreeze )

ACTIVATE MSDIALOG oDlg CENTERED ON INIT ENCHOICEBAR( oDlg,{ || nBtoOk := 1, oDlg:End() },{ || nBtoOk := 0, oDlg:End() } )

If nBtoOk == 1 							//USUARIO CONFIRMOU MSMGET
	If nOpc == 4						//ALTERACAO
	EndIf
EndIF


Return

Static Function CargaAHeader(cAlias)
Local	_nX1		:= 0
Local	_nX2		:= 0
Local	_nX3		:= 0
Local	_cCTP		
Local 	cCampos		:= "C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,C2_UM,C2_QUANT,C2_EMISSAO"
DbSelectArea("SX3")
DbSetOrder(1)
DbGoTop()
IF DbSeek(cAlias)
	
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == cAlias

			If ((Upper(AllTrim(SX3->X3_Campo))) $ cCampos .AND. X3USO(SX3->X3_USADO) .AND. cNIVEL >= SX3->X3_NIVEL)
				
				AAdd(aHeader, 	{Trim(SX3->X3_Titulo),;//Nome do campo que aparece para o usuario
								SX3->X3_Campo       ,;//Nome do campo no banco de dados
								SX3->X3_Picture     ,;//Picture do campo
								SX3->X3_Tamanho     ,;//Tamanho do campo
								SX3->X3_Decimal     ,;//Decimais do campo, caso seja numerico
								SX3->X3_Valid       ,;//Validação do campo
								SX3->X3_Usado       ,;//Uso do campo(ativo, inativo, etc.)
								SX3->X3_Tipo        ,;//Se o campo é editavel ou somente visual
								SX3->X3_Arquivo     ,;//Consulta padrão associada ao campo
								SX3->X3_Context}	; //Tipo do campo, real ou virtual
							)
			EndIf
		SX3->( DbSkip() )			
	EndDo

EndIf

Return()


Static Function CargaCols(cAlias,nOpc)
//Na acols do modelo 3 não escolhemos campos
Local 	nAdi 	:= 0
Local 	_nI		:= 0
Private _nJ		:= 1

If nOpc == 3 //Inclusão

	Else //Visual/Altera/Exclui
		ProcFech() //Busca os dados

		DbSelectArea((cAliasC2))
		(cAliasC2)->(DbGoTop())

		While !(cAliasC2)->(EOF()) 
			
			AAdd(aCols, Array(len(aHeader)+1))
			For _nI := 1 To Len(aHeader)
				If aHeader[_nI][10] <> "V"
					If Alltrim(aHeader[_nI][2]) == "C2_EMISSAO"
							aCols[len(aCols)][_nI] := STOD((cAliasC2)->&(aHeader[_nI][2]))
						Else						
							aCols[len(aCols)][_nI] := (cAliasC2)->&(aHeader[_nI][2])
					EndIf
				Else
					aCols[len(aCols)][_nI] := CriaVar(aHeader[_nI][2])
				EndIf
			Next
			
			ACols[_nJ][len(aHeader)+1] := .F.
			Aadd( aNroLin, (cAliasC2)->RECORECO ) //Para Utilização na exclusao dentro da alteração
			(cAliasC2)->(dbSkip())
			_nJ++

		Enddo
Endif

Return()

//Processa({|| ProcFech()}, "Processando movimentos...! ") //Chama a Funcao ImpcAlias
Static Function ProcFech()
local cQry		:= ""
local cCRLF		:= CRLF
local nCount	:= 0

(cAliasC2)	:= GetNextAlias()

cQry	+= " SELECT * "+cCRLF
cQry	+= " FROM  "+cCRLF
cQry	+= " ( "+cCRLF
cQry	+= " SELECT C2_NUM,C2_ITEM,C2_SEQUEN, C2_PRODUTO,C2_UM,C2_QUANT - C2_QUJE AS C2_QUANT,C2_EMISSAO,R_E_C_N_O_ RECORECO"+cCRLF
cQry	+= " FROM "+ RetSqlName("SC2")+" "+cCRLF
cQry	+= " WHERE D_E_L_E_T_ = '' "+cCRLF
cQry	+= " AND C2_NUM = '"+cOpMem+"' "+cCRLF
cQry	+= " AND C2_FILIAL = '"+xFilial("SC2")+"' "+cCRLF
cQry	+= " )OP                "+cCRLF
cQry	+= " WHERE C2_QUANT > 0 "+cCRLF	

TcQuery cQry New Alias (cAliasC2)
Count To nRegs

DbSelectArea((cAliasC2))
(cAliasC2)->(DbGoTop())

ProcRegua(nRegs)

(cAliasC2)->(DbGoTop())
Return()