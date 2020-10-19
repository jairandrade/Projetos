/*---------------------------------------------------------------------------+
|                         FICHA TECNICA DO PROGRAMA                          |
+----------------------------------------------------------------------------+
|   DADOS DO PROGRAMA                                                        |
+------------------+---------------------------------------------------------+
|Tipo              | Rotina                                                  |
+------------------+---------------------------------------------------------+
|Modulo            | Compras                                                 |
+------------------+---------------------------------------------------------+
|Nome              | TCP_MCOM004.PRW                                         |
+------------------+---------------------------------------------------------+
|Descricao         | Rotina para a partir do cadastro de fornecedores gerar  |
|                  | os dados de Produtos x Fornecedores.                    |
+------------------+---------------------------------------------------------+
|Autor             | Lucas José Corrêa Chagas                                |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 16/05/2013                                              |
+------------------+---------------------------------------------------------+
|   ATUALIZACOES                                                             |
+-------------------------------------------+-----------+-----------+--------+
|   Descricao detalhada da atualizacao      |Nome do    | Analista  |Data da |
|                                           |Solicitante| Respons.  |Atualiz.|
+-------------------------------------------+-----------+-----------+--------+
|                                           |           |           |        |
|                                           |           |           |        |
+-------------------------------------------+-----------+-----------+-------*/
// includes e defines
#INCLUDE "RWMAKE.CH"
#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwmvcdef.ch"

#define nSuperior 035
#define nEsquerda 005
#define nInferior 140
#define nDireita  330

User Function MCOM005()

Local aArea     := GetArea()
Local aButtons  := {}
Local aHeader   := {}
Local aCols     := {}
Local aAlterGDa := {}
Local aMata060  := {}
Local cLinOk    := "AllwaysTrue"
Local cTudoOk   := "AllwaysTrue"
Local cFieldOk  := "AllwaysTrue"
Local cDelOk    := "AllwaysFalse"
Local cIniCpos  := ""
Local cSuperDel := ""
Local cSA2Cod   := ''
Local cSA2Loja  := ''
Local oDlg      := Nil
Local oGet      := Nil
Local nX        := 0
Local nOpcA     := 0
Local nFreeze   := 000
Local nMax      := 999

If _SetAutoMode()
	return
endif

cSA2Cod  := SA2->A2_COD
cSA2Loja := SA2->A2_LOJA

aAlterGDa := MCOM051()
aHeader   := aClone(aAlterGDa[1])
aCols     := aClone(aAlterGDa[2])
aAlterGDa := {} 

oDlg           := MSDIALOG():Create()
oDlg:cName     := "oDlg"
oDlg:cCaption  := "Escolha os produtos para o Fornecedor - " + AllTrim(cSA2Cod) + " Loja - " + AllTrim(cSA2Loja) 
oDlg:nLeft     := 0
oDlg:nTop      := 0
oDlg:nWidth    := 676
oDlg:nHeight   := 319
oDlg:lShowHint := .F.
oDlg:lCentered := .T.
oDlg:bInit     := {|| EnchoiceBar(oDlg, {||( nOpcA := 1,oDlg:End() )}, {||oDlg:End()},,aButtons)}

oGet := MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita, GD_INSERT + GD_UPDATE + GD_DELETE,;
							cLinOk,cTudoOk,cIniCpos,,nFreeze,nMax,cFieldOk, cSuperDel,;
							cDelOk, oDlg, aHeader, aCols)
oDlg:Activate()

// caso confirme, a rotina irá gerar para cada produto um cadastro na SA5
if nOpcA == 1
	dbSelectArea('SA5')
	SA5->(dbSetOrder(1))	
	
	aCols := aClone(oGet:aCols)
	for nX := 1 to len(aCols)
		if (!Empty(aCols[nX,1]) .AND. !aCols[nX,2])
			SA5->(dbGoTop())
			if !SA5->(dbSeek(xFilial('SA5') + cSA2Cod + cSA2Loja + aCols[nX,1]))
				
				/**
				@author: Kaique Mathias - 22/05/2020
				@description: Cria a amarração produto x fornecedor
				**/

				oModel := FWLoadModel('MATA061')

				oModel:SetOperation(3)
				oModel:Activate()

				//Cabeçalho
				oModel:SetValue('MdFieldSA5','A5_PRODUTO',aCols[nX,1])
				oModel:SetValue('MdFieldSA5','A5_NOMPROD',GetAdvFVal("SB1","B1_DESC",xFilial("SB1") + aCols[nX,1],1,""))

				//Grid
				oModel:SetValue('MdGridSA5','A5_FORNECE',cSA2Cod)
				oModel:SetValue('MdGridSA5','A5_LOJA' ,cSA2Loja)
				oModel:SetValue('MdGridSA5','A5_NOMEFOR', GetAdvFVal("SA2","A2_NOME",xFilial("SA2") + cSA2Cod + cSA2Loja,1,""))

				If oModel:VldData()
					oModel:CommitData()
				Endif

				oModel:DeActivate()

				oModel:Destroy()
			endif		
		endif	
	next nX
endif

oGet := FreeObj(oGet)

RestArea(aArea)

Return

/*---------+----------+-------+-----------------------+------+--------------+
| Funcao   | MCOM051  | Autor | Lucas J. C. Chagas    | Data | 16/05/2013   |
+----------+----------+-------+-----------------------+------+--------------+
| Descricao| Rotina para criação de tabela temporária                       |
+----------+----------------------------------------------------------------+
| Sintaxe  | MCOM051()                                                      |
+----------+---------------------------------------------------------------*/
Static Function MCOM051() 

	Local aArea      := GetArea()
	Local aFieldFill := {}
	Local aHeader    := {}
	Local acols      := {}
	Local nI         := 0
	Local aFields	:= {'A5_PRODUTO'}
	Local aField := {}
	Local bBlock :=  {|cField| AAdd(aField, {FwSX3Util():GetDescription(cField),;
											cField,;
											X3PICTURE(cField),; 
											TamSX3(cField)[1],;
											TamSX3(cField)[2],;
											"U_MCOM0052(M->A5_PRODUTO)",;
											GetSx3Cache(cField, "X3_USADO"),;
											FwSX3Util():GetFieldType(cField),;
											X3F3(cField),;
											GetSx3Cache(cField, "X3_CONTEXT"),;
											X3CBOX(cField),;
											GetSx3Cache(cField, "X3_RELACAO");
											})}

	aEval(aFields,bBlock)
	aHeader := aClone(aField)
	aEval(aHeader,{|e| aAdd(aFieldFill,CriaVar(e[2],.F.))})
	aAdd(aFieldFill, .f.)
	aAdd(aCols, aClone(aFieldFill))
	RestArea(aArea)

return( { aHeader, aCols } )

/*---------+----------+-------+-----------------------+------+--------------+
| Funcao   | MCOM0052 | Autor | Lucas J. C. Chagas    | Data | 16/05/2013   |
+----------+----------+-------+-----------------------+------+--------------+
| Descricao| Rotina para validar o produto na rotina customizada.           |
+----------+----------------------------------------------------------------+
| Sintaxe  | MCOM0052( cProduto )                                           |
+----------+----------------------------------------------------------------+
| Param    | cProduto - Código do produto informado no MsNewGetDados        |
+----------+---------------------------------------------------------------*/
User Function MCOM0052( cProduto )

Local aArea := GetArea()
Local lRet  := .T.

dbSelectArea('SB1')
SB1->(dbSetOrder(1))
if !SB1->(dbSeek(xFilial('SB1') + cProduto))
	lRet := .F.
	Alert('Produto informado (' +AllTrim(cProduto)+ ') não existe na base de dados.')
endif

RestArea(aArea)

return lRet