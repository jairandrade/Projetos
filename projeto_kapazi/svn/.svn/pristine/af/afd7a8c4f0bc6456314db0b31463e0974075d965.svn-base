#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: CADZL1		|	Autor: Luis Paulo							|	Data: 13/09/2018	//
//==================================================================================================//
//	Descrição: Formulario de log conc limites														//
//																									//
//==================================================================================================//
User Function CADZL1()
Local cAlias1		:= "ZS1"
Local cAlias2		:= "ZL1"
Local nReg			:= ZS1->(RECNO())
Local nOpc			:= 2	//Visualizar sempre

//MsGetDados():New(nTop,nLeft,nBottom,nRight,nOpc,cLinhaOk,cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,,cDelOk,oWnd,lUseFreeze,cTela)
//{20,10,130,390}	
Local nTop     		:= 35
Local nLeft    		:= 05
Local nBottom  		:= 250
Local nRight   		:= 520
Local cLinhaOk 		:= "AllwaysTrue"  					
Local cTudoOk  		:= "AllwaysTrue" 					
Local cIniCpos 		:= "+ZL1_ITEM"
Local lDeleta  		:= .T.
//Local aAlter   		:= {"ZL1_NCM","ZL1_TECCOD","ZL1_CODCAT"}
Local aAlter   		:= {}
Local nFreeze  		:= 1
Local lEmpty   		:= .F.
Local nMax     		:= 999
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
Private cCodigo		:= ZS1->ZS1_CGC
Private aNroLin		:= {}
Private aCEncGra	:= {}
Private aRotina := {{"Pesquisar", "AxPesqui", 0, 1},;
                    {"Visualizar", "AxVisual", 0, 2},;
					{"Incluir", "AxInclui", 0, 3},;
					{"Alterar", "AxAltera", 0, 4},;
					{"Excluir", "AxDeleta", 0, 5}}

//Criar as variaveis de memoria
If nOpc == 3 						//Inclusão, cria as variaveis de memoria para o cabecalho(MsGetDados)
	RegToMemory(cAlias1, (nOpc==3))
	RegToMemory(cAlias2, (nOpc==3))
Else
	RegToMemory(cAlias1, .F. )
	RegToMemory(cAlias2, .F. )
EndIf


CargaAHeader(cAlias2)				//Funcao que faz a carga dos campos do aHeader
CargaCols(cAlias1,cAlias2,nOpc)		//Funcao que faz a carga dos campos do aCols

DEFINE MSDIALOG oDlg TITLE "LOGS DE ENVIO" FROM 0,0 TO 500,1040 PIXEL

oGD := MsGetDados():New(nTop,nLeft,nBottom,nRight,nOpc,cLinhaOk,cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel, ,cDelOk,oDlg,lUseFreeze )

ACTIVATE MSDIALOG oDlg CENTERED ON INIT ENCHOICEBAR( oDlg,{ || nBtoOk := 1, oDlg:End() },{ || nBtoOk := 0, oDlg:End() } )

Return()

Static Function CargaAHeader(cAlias2)
Local	_nX1		:= 0
Local	_nX2		:= 0
Local	_nX3		:= 0
Local	_cCTP		

DbSelectArea("SX3")
DbSetOrder(1)
DbGoTop()
IF DbSeek(cAlias2)
	
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == cAlias2

			If !("FILIAL" $ Upper(AllTrim(SX3->X3_Campo))) .AND. X3USO(SX3->X3_USADO) .AND. cNIVEL >= SX3->X3_NIVEL
				
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


Static Function CargaCols(cAlias1,cAlias2,nOpc)
//Na acols do modelo 3 não escolhemos campos
Local 	nAdi 	:= 0
Local 	_nI		:= 0
Private _nJ		:= 1


(cAlias2)->(DbSetOrder(2))
(cAlias2)->(DbSeek(xFilial(cAlias2) + (cAlias1)->ZS1_CGC))

While (cAlias2)->(!EOF()) .And. (cAlias2)->ZL1_FILIAL == xFilial(cAlias2) .And.(cAlias2)->ZL1_CGC == (cAlias1)->ZS1_CGC
	AAdd(aCols, Array(len(aHeader)+1))
	For _nI := 1 To Len(aHeader)
		If aHeader[_nI][10] <> "V"
			aCols[len(aCols)][_nI] := (cAlias2)->&(aHeader[_nI][2])
		Else
			aCols[len(aCols)][_nI] := CriaVar(aHeader[_nI][2])
		EndIf
	Next
	
	ACols[_nJ][len(aHeader)+1] := .F.
	Aadd( aNroLin, ZL1->( Recno() ) ) //Para Utilização na exclusao dentro da alteração
	(cAlias2)->(dbSkip())
	_nJ++
Enddo

Return()