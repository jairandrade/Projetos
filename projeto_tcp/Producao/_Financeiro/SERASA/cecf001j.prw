#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CECF001J ºAutor  ³ Kaique Sousa      º Data ³  06/13/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ CONSULTA PADRAO PARA MOTIVOS DE BAIXA.                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User FuncTion CECF001J

Local oDlg
Local _lRet		:= .F.
Local cVar		:=""
Local nOpc 		:= 0
Local aCampos 	:= {}
Local cArqTmp 	:= ""
Local cFile 	:= "SIGAADV.MOT"

Public _cRet1	:= ''

aCampos:={ 		{"SIGLA"    , 	"C" , 03,0},;
				{"DESCR"    , 	"C" , 10,0},;
				{"CARTEIRA" , 	"C" , 01,0},;
				{"MOVBANC"	,	"C"	, 01,0},;
				{"COMIS"	,	"C"	, 01,0},;
				{"CHEQUE"	,	"C"	, 01,0} }

//cArqTmp := CriaTrab( aCampos , .T.)
//dbUseArea( .T.,, cArqTmp, "cArqTmp", if(.F. .OR. .F., !.F., NIL), .F. )

If !FILE(cFile)
	
	MsgError('Arquivo de Motivos de Baixa SIGAADV.MOT não localizado !')
	Return( Nil )
	
Endif

oTempTable := FwTemporaryTable():New( cArqTmp )
oTempTable:SetFields(aCampos)
oTempTable:Create()

dbSelectArea( "cArqTmp" )

APPEND FROM &cFile SDF
dbGoTop()
 
aSize := MSADVSIZE()
nOpc := 0
cAlias := "cArqTmp"
dbSelectArea(cAlias)

DEFINE MSDIALOG oDlg FROM  aSize[7],0 To Int(aSize[6]/3),Int(aSize[5]/3) TITLE "Motivos de Baixas" PIXEL
nEspLarg := 6
nEspLin  := 7
//	oDlg:lMaximized := .T.
oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

oPanel2 := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,15,15)
oPanel2:Align := CONTROL_ALIGN_BOTTOM

@ nEspLin,nEspLarg LISTBOX oLbx  Var cVar FIELDS SIGLA,DESCR,CARTEIRA,MOVBANC,COMIS,CHEQUE ;
			HEADER OemToAnsi("SIGLA"),OemToAnsi("DESCRICAO"),OemToAnsi("CARTEIRA"),; // "SIGLA"###"DESCRICAO"###"CARTEIRA"
			OemToAnsi("MOV.BANCARIA"),OemToAnsi("COMISSAO"),OemToAnsi("CHEQUE"); // "MOV.BANCARIA"###"COMISSAO"###"CHEQUE"
			COLSIZES 28,45,40,40,40,40;
			SIZE 205, 65 OF oPanel PIXEL //ON DBLCLICK Edita( oLbx )

oLBX:Align := CONTROL_ALIGN_ALLCLIENT

DEFINE SBUTTON FROM 003, 050 TYPE  1 ENABLE OF oPanel2 Action (nOpc:=1,oDlg:End())
DEFINE SBUTTON FROM 003, 080 TYPE  2 ENABLE OF oPanel2 Action (nOpc:=0,oDlg:End())

ACTIVATE MSDIALOG oDlg Centered

If nOpc == 0
	_cRet1 := Nil
	_lRet	 := .F.
Else
	_cRet1 := cArqTmp->SIGLA
	_lRet	 := .T.
EndIf

cArqTmp->(DbCloseArea())
//FErase(cArqTmp+GetDBExtension())
oTempTable:Delete()

Return( _lRet )
