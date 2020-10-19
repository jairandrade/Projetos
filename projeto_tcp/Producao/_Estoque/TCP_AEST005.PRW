#Include "Protheus.ch"
#Include "TOPCONN.ch"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} AEST005
Soliticação de EPIs com geração de OP para apresentação na tela de Ordem de Separação

@return
@author Felipe Toazza Caldeira
@since 31/05/2016
/*/
//-------------------------------------------------------------------------------

User Function AEST005()

Private cCadastro := "Solicitação de EPIs"
Private aRotina := {}
Private cAlias := "ZD4"
Private aCores := {}

aCORES := {{"ZD4->ZD4_STATUS == '1' " ,"BR_AMARELO" } ,;
{"ZD4->ZD4_STATUS == '2'  " ,"BR_VERDE"}}



//***************************************************************//
//Montagem do aRotina											 //
//***************************************************************//
AADD(aRotina,{"Pesquisar"  , "AxPesqui"   	,0,1})
AADD(aRotina,{"Visualizar" , "AxVisual" 	,0,2})
AADD(aRotina,{"Incluir"    , "U_AEST005I" 	,0,3})
AADD(aRotina,{"Excluir"    , "U_AEST005D" 	,0,5})
AADD(aRotina,{"Lengenda"   , "U_AEST005L" 	,0,6})

(cAlias)->(dbSetOrder(1))
(cAlias)->(dbGoTop())

mBrowse(006,001,022,075,cAlias,,,,,,aCORES)

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} AEST005
Soliticação de EPIs com geração de OP para apresentação na tela de Ordem de Separação

@return
@author Felipe Toazza Caldeira
@since 31/05/2016
/*/
//-------------------------------------------------------------------------------
User Function AEST005I

Local aObjects  	:= {}
Local aPosObj   	:= {}
Local aSizeAut  	:= MsAdvSize()
Local aButtons 		:= {}

Private cCadastro 	:= 'Solicitação de EPIs'
Private oGet
Private nLen		:= 0

static oDlgI

//***************************************************************//
//Inicio da criação da tela										 //
//***************************************************************//
aObjects := {}
AAdd( aObjects, { 315,  50, .T., .T. } )
AAdd( aObjects, { 100,  20, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 6 ], aSizeAut[ 5 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlgI TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],1010 OF oMainWnd PIXEL

@ 005, 005 group oGrpCabec to 270, 500 prompt ' Solicitações ' of oDlgI	color 0,16777215 pixel
GridCrit()// cabecalho

ACTIVATE MSDIALOG oDlgI CENTER On INIT (enchoiceBar(oDlgI, {|| If(Gravadado(),oDlgI:end(),Nil) }, {|| oDlgI:end()},,@aButtons))

Return .T.


//-------------------------------------------------------------------------------
/*/{Protheus.doc} GRIDCRIT
Rotina para montagem do item

@return
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------

Static Function GRIDCRIT()
local aHeader		:= {}
local aCols			:= {}
local aFields 		:= {'ZD4_REQUIS', 'ZD4_NOME' ,'ZD4_EPI','ZD4_DESCRI','ZD4_QTDE','ZD4_DATA'}
local aFieldFill	:= {}
local aAlterFields	:= {'ZD4_REQUIS', 'ZD4_EPI','ZD4_QTDE','ZD4_DATA'}
Local aField := {}
Local bBlock :=  {|cField| IIf(FieldPos(cField) == 0, NIL, AAdd(aField, {FwSX3Util():GetDescription(cField),;
																		cField,;
																		X3PICTURE(cField),; 
																		TamSX3(cField)[1],;
																		TamSX3(cField)[2],;
																		GetSx3Cache(cField, "X3_VALID"),;
																		GetSx3Cache(cField, "X3_USADO"),;
																		FwSX3Util():GetFieldType(cField),;
																		X3F3(cField),;
																		GetSx3Cache(cField, "X3_CONTEXT"),;
																		X3CBOX(cField),;
																		GetSx3Cache(cField, "X3_RELACAO");
																		}))}

aEval(aFields,bBlock)
aHeader := aClone(aField)
aEval(aHeader,{|aCampo,nI| aAdd(aFieldFill,CriaVar(aCampo[nI,2],.F.))})
aAdd(aFieldFill, .f.)
aAdd(aCols, aClone(aFieldFill))

oGet := MsNewGetDados():New( 015, 010, 265, 495	, GD_INSERT+GD_DELETE+GD_UPDATE, 'AllwaysTrue', 'AllwaysTrue', '', aAlterFields, 0, 99, 'AllwaysTrue', '', 'AllwaysTrue', oDlgI, aHeader, aCols)

return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} GRIDCRIT
Rotina para montagem do item

@return
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function GravaDado
Local _aMata380 := {}
Local _aEmpen	:= {}
Local lRet		:= .T.
Local nI

ASORT(oGet:aCols, , , { | x,y | x[1] < y[1] } )
nAux := 1
cAuxReq := ""
Begin Transaction
For nI := 1 To len(oGet:aCols)
	If !oGet:aCols[nI][7]
		If cAuxReq != oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_REQUIS'})]
			cQuery := " SELECT MAX(C2_NUM) AS C2_NUM FROM "+RetSqlName('SC2')
			cQuery += "	WHERE C2_FILIAL = '"+XfILIAL('SC2')+"' AND C2_ITEM = '01' AND C2_SEQUEN = '001' AND D_E_L_E_T_ != '*' "
			If (Select("NUMOP") <> 0)
				DbSelectArea("NUMOP")
				NUMOP->(DbCloseArea())
			Endif
			
			DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "NUMOP",.T., .F.)
			
			DbSelectArea("NUMOP")
			NUMOP->(DbGoTop())
			IF !NUMOP->(EOF())
				cNumOp := Soma1(NUMOP->C2_NUM)
			Else
				cNumOp := "000001"
			EndIf
			NUMOP->(DbCloseArea())
			
			
			//usa-se reclock na SC2 pois o objetivo não é realizar produção. Tomou-se como base a rotina de MNT
			RecLock('SC2',.T.)
			SC2->C2_FILIAL	:= xFilial('SC2')
			SC2->C2_NUM		:= cNumOp
			SC2->C2_ITEM    := "01"
			SC2->C2_SEQUEN  := "001"
			SC2->C2_PRODUTO := "EPI - "+oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_REQUIS'})]
			SC2->C2_LOCAL 	:= "01"
			SC2->C2_CC      := "001046"
			SC2->C2_QUANT   := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_QTDE'})]
			SC2->C2_UM      := Posicione('SB1',1,xFilial("SB1")+"","B1_UM")
			SC2->C2_DATPRI  := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_DATA'})]
			SC2->C2_DATPRF  := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_DATA'})]
			SC2->C2_OBS		:= "EPI"
			SC2->C2_EMISSAO := dDataBase
			SC2->C2_PRIOR   := "500"
			SC2->C2_STATUS	:= "U"
			SC2->C2_SEQPAI	:= "000"
			SC2->C2_TPOP	:= "F"
			MsUnlock()
			nAux := 1
		EndIf
		
		cProd := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_EPI'})]
		cTRT := Space(Len(SD4->D4_TRT)-Len(Alltrim(Str(nAux))))+Alltrim(Str(nAux))
		_aMata380 := {{"D4_FILIAL"	, xFilial('SD4')															, NIL},;
		{"D4_COD"	 	, oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_EPI'})]     		, NIL},;
		{"D4_OP"	 	, cNumOp+"01001"															, NIL},; // Número da OP
		{"D4_DATA" 	, DDATABASE	   																, NIL},; // Data de empenho
		{"D4_QTDEORI"	, oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_QTDE'})]	   		, NIL},;
		{"D4_QUANT"	, oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_QTDE'})]		   	, NIL},;
		{"D4_LOCAL"	, Posicione('SB1',1,xFilial('SB1')+cProd,"B1_LOCPAD")						, NIL},; // Local
		{"D4_TRT"		, cTRT																		, NIL}}  // Quantidade a ser empenhada
		
		AADD(_aEmpen,{   oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_QTDE'})]        	,;   // SD4->D4_QUANT
		SB1->B1_ZLOCALI		,;  // DC_LOCALIZ
		""        	,;  // DC_NUMSERI
		.F.})
		
		lMsErroAuto := .F.
		
		//Chamada da rotina automatica
		MSExecAuto({|x,y,z| mata380(x,y,z)},_aMata380,3,_aEmpen)
		
		If lMsErroAuto
			Alert('A rotina apresentou problema ao empenhar o EPI! Apresente a proxima mensagem ao Administrador do sistema!')
			mostraerro()
			DisarmTransaction()
			lRet := .F.
			Exit
		Else
			cLocaliz := ''
			DbSelectArea('SBF')
			SBF->(DbSetOrder(2))
			SBF->(DbGoTop())
			IF SBF->(DbSeek(xFilial('SBF')+cProd+SB1->B1_LOCPAD))
				IF (SBF->BF_QUANT) >= oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_QTDE'})]
					cLocaliz := SBF->BF_LOCALIZ
					RecLock('SBF',.F.)
					SBF->BF_EMPENHO := SBF->BF_EMPENHO+oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_QTDE'})]
					MsUnlock()
				Else
					Alert("Atenção, saldo insuficiente no endereço: " + SBF->BF_LOCALIZ)
				EndIf
			EndIf
			
			RecLock('SDC',.T.)
			SDC->DC_FILIAL 	:= xFilial('SDC')
			SDC->DC_ORIGEM 	:= 'SC2'
			SDC->DC_PRODUTO	:= cProd
			SDC->DC_LOCAL 	:= Posicione('SB1',1,xFilial('SB1')+cProd,"B1_LOCPAD")
			SDC->DC_LOCALIZ	:= cLocaliz
			SDC->DC_QUANT 	:= oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_QTDE'})]
			SDC->DC_OP 		:= cNumOp+"01001"
			SDC->DC_TRT 	:= cTRT
			SDC->DC_QTDORIG	:= oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_QTDE'})]
			MsUnlock()
			
		EndIf
		
		RecLock('ZD4',.T.)
		ZD4->ZD4_FILIAL	:= xFilial('ZD4')
		ZD4->ZD4_REQUIS := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_REQUIS'})]
		ZD4->ZD4_NOME 	:= oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_NOME'})]
		ZD4->ZD4_EPI 	:= oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_EPI'})]
		ZD4->ZD4_DESCRI	:= oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_DESCRI'})]
		ZD4->ZD4_QTDE 	:= oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_QTDE'})]
		ZD4->ZD4_DATA 	:= oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_DATA'})]
		ZD4->ZD4_OP 	:= cNumOp+"01001"
		ZD4->ZD4_STATUS	:= '1'
		MsUnlock()
		
		cAuxReq := oGet:aCols[nI,aScan(oGet:aHeader,{|x|allTrim(x[2])=='ZD4_REQUIS'})]
		nAux++
		_aEmpen := {}
	EndIf
Next
End Transaction
Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} AEST005D
Exclusão de solicitação de EPIs

@return
@author Felipe Toazza Caldeira
@since 31/05/2016
/*/
//-------------------------------------------------------------------------------
User Function AEST005D()
Local _aMata380 := {}
Local _aMata650	:= {}

If ZD4->ZD4_STATUS == '2'
	Alert('Este EPI já foi entregue. A Solicitação não pode ser excluida!')
	Return
EndIf

If !MsgYesNo('Deseja realmente excluir esta solicitação de EPI?')
	Return
EndIf

DbSelectArea('SD4')
SD4->(DbSetOrder(2))
SD4->(DbGoTop())
If SD4->(DbSeek(xFilial('SD4')+Padr(ZD4->ZD4_OP,Len(SD4->D4_OP))+ZD4->ZD4_EPI))
	_aMata380 := {{"D4_FILIAL"	, xFilial('SD4')		, NIL},;
	{"D4_OP"	 	, ZD4->ZD4_OP			, NIL},; // Número da OP
	{"D4_COD"	 	, ZD4->ZD4_EPI   		, NIL}}  // Codigo Produto
	
	lMsErroAuto := .F.
	
	//Chamada da rotina automatica
	msExecAuto({|x,Y|Mata380(x,Y)},_aMata380,5)
	
	If lMsErroAuto
		Alert('A rotina apresentou problema ao excluir a requisição de EPI! Apresente a proxima mensagem ao Administrador do sistema!')
		mostraerro()
		Return
	EndIf
EndIf
/*
DbSelectArea('SC2')
SC2->(DbSetOrder(1))
SC2->(DbGoTop())
If SC2->(DbSeek(xFilial('SC2')+ZD4->ZD4_OP))

aAdd(_aMata650, {"C2_NUM"	,SubStr(ZD4->ZD4_OP,1,6),Nil})
aAdd(_aMata650, {"C2_ITEM"	,SubStr(ZD4->ZD4_OP,7,2),Nil})
aAdd(_aMata650, {"C2_SEQUEN",SubStr(ZD4->ZD4_OP,9,3),Nil})
aAdd(_aMata650, {"INDEX" 	,1     					,Nil})

lMsErroAuto := .F.
MsgRun("Processando . . .","Aguarde . . .",{||MsExecAuto({|x,y|Mata650(x,y)},_aMata650,5) })
If lMsErroAuto
//			Alert('A rotina apresentou problema ao excluir a requisição de EPI! Apresente a proxima mensagem ao Administrador do sistema!')
//			mostraerro()
EndIf
EndIf

*/
RecLock('ZD4',.F.)
DbDelete()
MsUnlock()

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} AEST005L
Rotina para montagem de legenda

@return
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
User Function AEST005L()
Private cCadastro := "Solicitação de EPIs"

BrwLegenda( cCadastro , "Legenda" ,{{"BR_VERDE"		,"EPI Entregue"	},;
{"BR_AMARELO"	,"EPI Solicitado"}})

Return .T.

//-------------------------------------------------------------------------------
/*/{Protheus.doc} AEST005V

@return
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
User Function AEST005V()
Local nTot 	:= 0
Local lRet 	:= .T.


DbSelectArea('SB2')
SB2->(DbSetORder(1))
SB2->(DbGoTop())
SB2->(DbSeek(xFilial('SB2')+GdFieldGet("ZD4_EPI")))

While !SB2->(EOF()) .AND. SB2->B2_FILIAL+SB2->B2_COD == xFilial('SB2')+GdFieldGet("ZD4_EPI")
	nTot += SaldoSb2()
	SB2->(DbSkip())
EndDO

If nTot < M->ZD4_QTDE
	Alert("Saldo insuficiente para atender este EPI! Saldo disponível de "+Alltrim(Str(nTot))+"!")
	lRet := .F.
EndIf

Return lRet


