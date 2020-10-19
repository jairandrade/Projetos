#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
//-------------------------------------------------------------------------------
/*/{Protheus.doc} AMNT032
Devolução de Ferramentas
@return
@author Felipe Toazza Caldeira
@since 22/07/2016

/*/
//-------------------------------------------------------------------------------
#DEFINE CRLF (chr(13)+chr(10))

User Function AMNT032()
Local cFiltro := "Z12_STATUS != '2'" //Expressao do Filtro
Local aIndex := {}

Private cAlias := "Z12"
Private bFiltraBrw := { || FilBrowse( cAlias , @aIndex , @cFiltro ) } //Determina a Expressao do Filtro
Private cCadastro := "Devolução Ferramentas"
Private aRotina := {}
Private aCores := {}

aCORES := {{"Z12->Z12_STATUS == '1' " ,"BR_AMARELO" } ,;
{"Z12->Z12_STATUS == '3'  " ,"BR_VERMELHO"}}



//***************************************************************//
//Montagem do aRotina											 //
//***************************************************************//
AADD(aRotina,{"Pesquisar"  , "AxPesqui"   		,0,1})
AADD(aRotina,{"Visualizar" , "U_AMNT032D()"		,0,2})
AADD(aRotina,{"Devolução"  , "U_AMNT032D()" 	,0,3})
AADD(aRotina,{"Prazo Itens", "U_AMNT032P()" 	,0,6})
AADD(aRotina,{"Imprimir"   , "U_RMNT032()" 		,0,6})
AADD(aRotina,{"Legendas"   , "U_AMNT032L()" 	,0,6})

(cAlias)->(dbSetOrder(1))
(cAlias)->(dbGoTop())

Eval( bFiltraBrw ) //Efetiva o Filtro antes da Chamada a mBrowse

mBrowse(006,001,022,075,cAlias,,,,,,aCores)

EndFilBrw( cAlias , @aIndex ) //Finaliza o Filtro

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} AMNT032D
Inclusão Emprestimos Ferramentas

@return
@author Felipe Toazza Caldeira
@since 22/07/2016
/*/
//-------------------------------------------------------------------------------
User Function AMNT032D( cAlias, nReg, nOpc )
Local aObjects  	:= {}
Local aPosObj   	:= {}
Local aCpo			:= {"Z12_NUM","Z12_MATRIC","Z12_NOME","Z12_DTEMP","Z12_HREMP","Z12_DTDEV","Z12_HRDEV"}
Local aSizeAut  	:= MsAdvSize()
Local aButtons 		:= {}
Local aCpoAlt		:= {}
Local nX
Private bCampo    	:= {|nField| FieldName(nField) }                                                                                                     
Private cCadastro 	:= 'Devolução de Ferramentas'
Private oGet
Private cMatricula	:= Space(6)
Private aHeader		:= {}
Private aCols		:= {}
Private lVisualiza	:= !INCLUI .And. !ALTERA //nOpc == 2

static oDlgI

//***************************************************************//
//Inicio da criação da tela										 //
//***************************************************************//
aObjects := {}
AAdd( aObjects, { 315,  50, .T., .T. } )
AAdd( aObjects, { 100,  20, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 6 ], aSizeAut[ 5 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

dbSelectArea("Z12")
Z12->(dbSetOrder(1))

For nX := 1 To FCount()
	M->&( Eval( bCampo, nX ) ) := CriaVar( FieldName( nX ), .T. )
Next nX

M->Z12_NUM		:= Z12->Z12_NUM
M->Z12_MATRIC	:= Z12->Z12_MATRIC
M->Z12_NOME		:= Posicione('SRA',1,xFilial('SRA')+M->Z12_MATRIC,"RA_NOME")
M->Z12_DTEMP	:= Z12->Z12_DTEMP
M->Z12_HREMP	:= Z12->Z12_HREMP
M->Z12_DTDEV	:= dDataBase
M->Z12_HRDEV	:= time()

DEFINE MSDIALOG oDlgI TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],1010 OF oMainWnd PIXEL
Enchoice( cAlias, nReg, 4,,,,aCpo,aPosObj	[1],aCpoAlt,, , , , , ,.F. )
GridCrit()// cabecalho

ACTIVATE MSDIALOG oDlgI CENTER On INIT (enchoiceBar(oDlgI, {|| If(!lVisualiza,(If(Gravadado(),oDlgI:end(),Nil)),oDlgI:end()) }, {|| oDlgI:end()},,@aButtons))

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
local aFields 		:= {'Z13_FERRAM','Z13_NOMFER','Z13_NUMSER'}
local aFieldFill	:= {}
local aAlterFields	:= {'Z13_FERRAM','Z13_NOMFER','Z13_NUMSER'}
Local aField 		:= {}
Local bBlock :=  {|cField| AAdd(aField, {	FwSX3Util():GetDescription(cField),;
											cField,;
											X3PICTURE(cField),; 
											TamSX3(cField)[1],;
											TamSX3(cField)[2],;
											GetSx3Cache(cField, "X3_VALID"),;
											GetSx3Cache(cField, "X3_USADO"),;
											FwSX3Util():GetFieldType(cField),;
											GetSx3Cache(cField,"X3_F3"),;
											GetSx3Cache(cField, "X3_CONTEXT"),;
											X3CBOX(cField),;
											GetSx3Cache(cField, "X3_RELACAO");
											})}

aEval(aFields,bBlock)
aHeader := aClone(aField)
aEval(aHeader,{|aCampo| aAdd(aFieldFill,CriaVar(aCampo[02],.F.))})
aAdd(aFieldFill, .f.)
aAdd(aCols, aClone(aFieldFill))

oGet := MsNewGetDados():New( 060, 010, 275, 500	, If(!lVisualiza,GD_INSERT+GD_DELETE+GD_UPDATE,0), 'AllwaysTrue', 'AllwaysTrue', '', aAlterFields, 0, 99, 'AllwaysTrue', '', 'AllwaysTrue', oDlgI, aHeader, aCols)

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
Local aItens := {}
Local aAuto := {}
Local cDocumento := GetSxENum("SD3","D3_DOC",1)
Local nI
Private cSenhaAtu	:= Space(10)
Private lMsErroAuto := .F.
Private aCampos := {{"Z14_COMPON"	,"","Item","@!" },;
{"Z14_COMSER"	,"","N. Serie","@!" },;
{"Z14_FERRAM"	,"","Ferramenta","@!" },;
{"Z14_NUMSER"	,"","N. Serie","@!" };
}
Private aRotina := {}

aRotina := {{"Devolver" 	,'ExecBlock("AMNT032C",.F.,.F.,6), CloseBrowse()',0,6}}

For nI := 1 To len(oGet:aCols)
	If !oGet:aCols[nI][Len(aHeader)+1]
		
		cQuery := " SELECT * "
		cQuery += " FROM "+RetSqlName('Z13')+" Z13 "
		cQuery += " WHERE "
		cQuery += "     Z13_FILIAL = '"+xFilial('Z13')+"' AND Z13_NUM = '"+Z12->Z12_NUM+"' AND D_E_L_E_T_ != '*' "
		cQuery += " AND Z13_NUMSER = '"+oGet:aCols[nI][3]+"' AND Z13_FERRAM = '"+oGet:aCols[nI][1]+"' "
		cQuery := ChangeQuery(cQuery)
		
		If Select("TRBSER")<>0
			DBSelectArea("TRBSER")
			TRBSER->(DBCloseArea())
		EndIf
		TCQuery cQuery New Alias "TRBSER"
		
		DbSelectArea('TRBSER')
		TRBSER->(DbGoTop())
		
		IF !TRBSER->(EOF())
			If TRBSER->Z13_STATUS == '2'
				Alert('O produto '+Alltrim(oGet:aCols[nI][1])+' com o numero de série '+oGet:aCols[nI][3]+' já teve a entrega realizada!')
				oGet:aCols[nI][Len(aHeader)+1] := .T.
				Loop
			EndIf
		Else
			Alert('O produto '+Alltrim(oGet:aCols[nI][1])+' com o numero de série '+oGet:aCols[nI][3]+' não faz parte desta separação!')
			Loop
		EndIf
		TRBSER->(DBCloseArea())
	EndIf
Next

cParQry := ""
For nI := 1 To len(oGet:aCols)
	If !oGet:aCols[nI][Len(aHeader)+1]
		If empty(alltrim(cParQry))
			cParQry += " (Z14_FERRAM = '"+oGet:aCols[nI][1]+"' AND Z14_NUMSER = '"+oGet:aCols[nI][3]+"') "
		Else
			cParQry += " OR (Z14_FERRAM = '"+oGet:aCols[nI][1]+"' AND Z14_NUMSER = '"+oGet:aCols[nI][3]+"') "
		EndIf
	EndIf
Next
If !Empty(Alltrim(cParQry))
	cParQry := " AND ( "+cParQry+" ) "
EndIf
GeraDados(cParQry)

dbSelectArea("_TRB")
DbGotop()
MarkBrow("_TRB","Z14_OK",,aCampos)
_TRB->(DbCloseArea())

Return .T.


//-------------------------------------------------------------------------------
/*/{Protheus.doc} AEST005L
Rotina para montagem de legenda

@return
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
User Function AMNT032L()
Private cCadastro := "Devolução Ferramentras"

BrwLegenda( cCadastro , "Legenda" ,{{"BR_AMARELO"	,"Ferramenta Emprestada"	},;
{"BR_VERMELHO"	,"Ferramenta com Pendencia"}})

Return .T.

//-------------------------------------------------------------------------------
/*/{Protheus.doc} AMNT032S
Pergunte para informação da senha

@return
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------
Static Function AMNT032S()
Private aTela[0][0],aGets[0][0]
Private cCadastro := "Cadastro de Senha"

DEFINE FONT oFont NAME "Arial" SIZE 000,-012

DEFINE MSDIALOG oDlgM TITLE cCadastro FROM 000, 000  TO 100, 300  OF oMainWnd PIXEL
@ 013, 010 Say oSay prompt "Senha Confirmação " SIZE 175, 007 OF oDlgM PIXEL FONT oFont
@ 010, 070 MSGET cSenhaAtu when .T. SIZE 060, 011 Password OF oDlgM PIXEL FONT oFont

ACTIVATE MSDIALOG oDlgM ON INIT EnchoiceBar(oDlgM,{|| oDlgM:End()},{||oDlgM:End()},,)//EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,)

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} AMNT032I
Inclusão Emprestimos Ferramentas

@return
@author Felipe Toazza Caldeira
@since 22/07/2016
/*/
//-------------------------------------------------------------------------------
Static Function AMNT032A(aItens)
Local aObjects  	:= {}
Local aPosObj   	:= {}
Local aSizeAut  	:= MsAdvSize()
local aHeader		:= {}
local aFields 		:= {'Z13_FERRAM','Z13_NOMFER','Z13_NUMSER'}
local aFieldFill	:= {}
local aAlterFields	:= {}
local aCols			:= {}
Local aField 		:= {}
Local bBlock :=  {|cField| AAdd(aField, {	FwSX3Util():GetDescription(cField),;
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
											})}
Private cCadastro2 	:= 'Emprestimo de Ferramentas'
Private oGet2

static oDlg

aObjects := {}
AAdd( aObjects, { 315,  50, .T., .T. } )
AAdd( aObjects, { 100,  20, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 6 ], aSizeAut[ 5 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro2 From aSizeAut[7],00 To aSizeAut[6],1010 OF oMainWnd PIXEL

aEval(aFields,bBlock)
aHeader := aClone(aField)
aCols := aItens

oGet2 := MsNewGetDados():New( 060, 010, 010, 500	, , 'AllwaysTrue', 'AllwaysTrue', '', aAlterFields, 0, 99, 'AllwaysTrue', '', 'AllwaysTrue', oDlg, aHeader, aCols)

ACTIVATE MSDIALOG oDlg CENTER On INIT (enchoiceBar(oDlg, {|| lConf := .T.,oDlg:end() }, {|| lConf := .F.,oDlg:end()},,))

Return .T.


Static Function GERADADOS(cParQry)

aTemp := {{"Z14_OK" 	,"C",2,0},;
{"Z14_COMPON"	,"C",15,0},;
{"Z14_COMSER"	,"C",12,0},;
{"Z14_FERRAM"	,"C",15,0},;
{"Z14_NUMSER"	,"C",12,0};
}
//cArqTmp := CriaTrab(aTemp)
//dbUseArea( .T.,, cArqTmp, "_TRB", .F., .F. )

oTempTable := FWTemporaryTable():New( "_TRB" )
oTemptable:SetFields( aTemp )
oTempTable:Create()
cArqTmp := oTempTable:GetRealName()

cQry := ""
cQry := " SELECT Z14_COMPON, Z14_COMSER, Z14_FERRAM, Z14_NUMSER "
cQry += " FROM "+RetSQLName("Z14")+" Z14 "
cQry += " WHERE Z14_FILIAL='"+xFilial("Z14")+"' AND Z14_NUM = '"+Z12->Z12_NUM+"' AND D_E_L_E_T_ != '*' "+cParQry

cQry := ChangeQuery(cQry)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), 'QRY', .F., .T.)
dbSelectArea("QRY")
QRY->(dbGoTop())
While !QRY->(Eof())
	Reclock("_TRB",.T.)
	_TRB->Z14_COMPON  	:= QRY->Z14_COMPON
	_TRB->Z14_COMSER  	:= QRY->Z14_COMSER
	_TRB->Z14_FERRAM  	:= QRY->Z14_FERRAM
	_TRB->Z14_NUMSER  	:= QRY->Z14_NUMSER
	MsUnlock()
	QRY->(dbSkip())
Enddo
QRY->(dbCloseArea())
freeObj(oTempTable)
oTemptable := nil
Return

User Function AMNT032C()
Local aAuto := {}
Local cDocumento := GetSxENum("SD3","D3_DOC",1)
Local lImp	:= .F.
Local lRet	:= .T.
Local nMark	:= 0
Local nFor
Local _FerEmp   := GetMv("TCP_FEREMP")
Local _EstTrop  := GetMv("TCP_ESTROP")

DbSelectArea("_TRB")
_TRB->(DbGoTop())
While !_TRB->(EOF())
	If AllTrim(_TRB->Z14_OK) != ""
		nMark++
	EndIf
	_TRB->(DbSkip())
EndDo

If nMark == 0
	Alert('Nenhum item foi marcado! Nenhuma ação foi realizada!')
	Return
EndIf

Begin Transaction

DbSelectArea("_TRB")
_TRB->(DbGoTop())
While !_TRB->(EOF())
	If !AllTrim(_TRB->Z14_OK) == ""
		DbSelectArea('Z14')
		Z14->(DbSetOrder(3))
		Z14->(DbGoTop())
		If Z14->(DbSeek(xFilial('Z14')+Z12->Z12_NUM+_TRB->Z14_FERRAM+_TRB->Z14_NUMSER+_TRB->Z14_COMPON+_TRB->Z14_COMSER))
			RecLock('Z14',.F.)
			Z14->Z14_STATUS := '2'
			Z14->Z14_DTENTR := dDataBase
			MsUnlock()
		EndIf
	Else
		DbSelectArea('Z14')
		Z14->(DbSetOrder(3))
		Z14->(DbGoTop())
		If Z14->(DbSeek(xFilial('Z14')+Z12->Z12_NUM+_TRB->Z14_FERRAM+_TRB->Z14_NUMSER+_TRB->Z14_COMPON+_TRB->Z14_COMSER))
			IF Z14->Z14_STATUS <> '2'
				RecLock('Z14',.F.)
				Z14->Z14_STATUS := '3'
				Z14->Z14_DTPEND := dDataBase
				Z14->Z14_DTPREV := dDataBase+1
				MsUnlock()
			EndIf
		EndIf
		MsUnlock()
		
	Endif
	_TRB->(Dbskip())
Enddo

DbSelectArea('Z14')
Z14->(DbSetOrder(3))
Z14->(DbGoTop())
Z14->(DbSeek(xFilial('Z14')+Z12->Z12_NUM))
While xFilial('Z14')+Z12->Z12_NUM == Z14->Z14_FILIAL+Z14->Z14_NUM .AND. !Z14->(EOF())
	//pega o que não foi marcado e coloca como pendencia
	If Z14->Z14_STATUS == '1'
		RecLock('Z14',.F.)
		Z14->Z14_STATUS := '3'
		Z14->Z14_DTPEND := dDataBase
		Z14->Z14_DTPREV := dDataBase+1
		MsUnlock()
	EndIf
	
	If Z14->Z14_STATUS == '3'
		DbSelectArea('Z13')
		Z13->(DbGoTop())
		Z13->(DbSetOrder())
		If Z13->(DbSeek(xFilial('Z13')+Z12->Z12_NUM+Z14->Z14_FERRAM+Z14->Z14_NUMSER))
			RecLock('Z13',.F.)
			Z13->Z13_STATUS := '3'
			//				Z13->Z13_DTENTR	:= dDataBase
			MsUnlock()
		EndIF
	EndIf
	If Z14->Z14_STATUS == '2'
		DbSelectArea('Z13')
		Z13->(DbGoTop())
		Z13->(DbSetOrder())
		If Z13->(DbSeek(xFilial('Z13')+Z12->Z12_NUM+Z14->Z14_FERRAM+ALLTRIM(Z14->Z14_NUMSER)))
	   		DbSeek(xFilial('Z13')+Z12->Z12_NUM+Z14->Z14_FERRAM+ALLTRIM(Z14->Z14_NUMSER)) //teste
			RecLock('Z13',.F.)    
			Z13->Z13_STATUS := '2'
			Z13->Z13_DTENTR	:= dDataBase
			MsUnlock()
			AcertaZ13(Z13->Z13_NUMSER,Z13->Z13_NUM)
		EndIF
	EndIf
	Z14->(DbSkip())
Enddo


DbSelectArea('Z13')
Z13->(DbSetOrder(1))
Z13->(DbGoTop())
Z13->(DbSeek(xFilial('Z13')+Z12->Z12_NUM))
While xFilial('Z13')+Z12->Z12_NUM == Z13->Z13_FILIAL+Z13->Z13_NUM .AND. !Z13->(EOF())
	If Z13->Z13_STATUS == '3'
		RecLock('Z12',.F.)
		Z12->Z12_STATUS := '3'
		MsUnlock()
		Z13->(DbGoBottom())
	EndIF
	Z13->(DbSkip())
Enddo

//TcSqlExec("UPDATE "+RETSQLNAME('Z13')+" SET Z13_STATUS = '2' WHERE Z13_FILIAL = '"+xFilial('Z13')+"' AND Z13_NUM = '"+Z12->Z12_NUM+"' AND Z13_STATUS = '1' AND Z13_NUMSER = '"+Z14->Z14_NUMSER+"' ")


If Z12->Z12_STATUS == '1'
	RecLock('Z12',.F.)
	Z12->Z12_STATUS := '2'
	Z12->Z12_DTDEV 	:= dDataBase
	Z12->Z12_HRDEV  := Time()
	MsUnlock()
EndIf

For nFor := 1 to Len(oGet:aCols)
	If !oGet:aCols[nFor][Len(aHeader)+1]
		aAuto := {}
		aAdd(aAuto,{cDocumento,ddatabase})
		cEnd := Posicione('SBF',4,xFilial('SBF')+oGet:aCols[nFor][1]+Padr(oGet:aCols[nFor][3],Len(SBF->BF_NUMSERI)),"BF_LOCALIZ")
		
		aAdd(aAuto, {oGet:aCols[nFor][1] ,; //1 Prod.Orig.
		Posicione('SB1',1,xFilial('SB1')+oGet:aCols[nFor][1],"B1_DESC"),; //2 Desc.Orig.
		SB1->B1_UM,; //3 UM Orig.
		IIF(SB1->B1_LOCPAD=='10',Alltrim(_FerEmp),Alltrim(_EstTrop)),; //4 Armazem Or
		cEnd,; //5 Endereco O
		oGet:aCols[nFor][1],; //6 Prod.Desti
		SB1->B1_DESC,; //7 Desc.Desti
		SB1->B1_UM,; //8 UM Destino
		SB1->B1_LOCPAD,; //9 Armazem De
		cEnd,; //10 Endereco D
		oGet:aCols[nFor][3],; //11 Numero Ser
		"",; //12 Lote
		"",; //13 Sub-Lote
		dDataBase,;	//14 Validade
		000.00,; //15 Potencia
		1,; //16 Quantidade
		0,; //17 Qt 2aUM
		"",; //18 Estornado
		"",; //19 Sequencia
		"",; //20 Lote Desti
		dDataBase,;	//21 Validade D
		"",;//22 Item Grade
		""})// Observação 
		
		lMsErroAuto := .F.
		
		MSExecAuto({|x,y| mata261(x,y)},aAuto,3)//inclusão
		
		If lMsErroAuto
			//Conout("Erro na transferencia de armazém para o produto "+oGet:aCols[nFor][1]+"!")
			MostraErro()
			DisarmTransaction()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

End Transaction
If lImp
	U_RMNT033()
EndIf

Return lRet


//-------------------------------------------------------------------------------
/*/{Protheus.doc} AMNT032D
Inclusão Emprestimos Ferramentas

@return
@author Felipe Toazza Caldeira
@since 22/07/2016
/*/
//-------------------------------------------------------------------------------
User Function AMNT032P( cAlias, nReg, nOpc )
Local aObjects  	:= {}
Local aPosObj   	:= {}
Local aCpo			:= {"Z12_NUM","Z12_MATRIC","Z12_NOME","Z12_DTEMP","Z12_HREMP","Z12_DTDEV","Z12_HRDEV"}
Local aSizeAut  	:= MsAdvSize()
Local aButtons 		:= {}
Local aCpoAlt		:= {}
Local nX
Private bCampo    	:= {|nField| FieldName(nField) }
Private cCadastro 	:= 'Devolução de Ferramentas'
Private oGet
Private cMatricula	:= Space(6)
Private aHeader		:= {}
Private aCols		:= {}

static oDlgI

//***************************************************************//
//Inicio da criação da tela										 //
//***************************************************************//
aObjects := {}
AAdd( aObjects, { 315,  50, .T., .T. } )
AAdd( aObjects, { 100,  20, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 6 ], aSizeAut[ 5 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

dbSelectArea("Z12")
Z12->(dbSetOrder(1))

For nX := 1 To FCount()
	M->&( Eval( bCampo, nX ) ) := CriaVar( FieldName( nX ), .T. )
Next nX

M->Z12_NUM		:= Z12->Z12_NUM
M->Z12_MATRIC	:= Z12->Z12_MATRIC
M->Z12_NOME		:= Posicione('SRA',1,xFilial('SRA')+M->Z12_MATRIC,"RA_NOME")
M->Z12_DTEMP	:= Z12->Z12_DTEMP
M->Z12_HREMP	:= Z12->Z12_HREMP
M->Z12_DTDEV	:= dDataBase
M->Z12_HRDEV	:= time()


DEFINE MSDIALOG oDlgI TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],1010 OF oMainWnd PIXEL
Enchoice( cAlias, nReg, 4,,,,aCpo,aPosObj	[1],aCpoAlt,, , , , , ,.F. )
GridPrazo()// cabecalho

ACTIVATE MSDIALOG oDlgI CENTER On INIT (enchoiceBar(oDlgI, {|| oDlgI:end() }, {|| oDlgI:end()},,@aButtons))

Return .T.


//-------------------------------------------------------------------------------
/*/{Protheus.doc} GridPrazo
Rotina para montagem do item

@return
@author Felipe Toazza Caldeira
@since 01/09/2015

/*/
//-------------------------------------------------------------------------------

Static Function GridPrazo()
local aFields 		:= {'Z13_FERRAM','Z13_NOMFER','Z13_NUMSER','Z13_DTEMPR','Z13_DTPREV','Z13_DTENTR'}
local aFieldFill	:= {}
local aAlterFields	:= {}
Local aField 		:= {}
Local bBlock :=  {|cField| AAdd(aField, {	FwSX3Util():GetDescription(cField),;
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
											})}

aEval(aFields,bBlock)
aHeader := aClone(aField)

DbSelectArea('Z13')
Z13->(DbSetOrder(1))
Z13->(DbGoTop())
Z13->(DbSeek(xFilial('Z13')+Z12->Z12_NUM ))

While !Z13->(EOF()) .AND. Z12->Z12_NUM == Z13->Z13_NUM
	aFieldFill := {}
	aadd(aFieldFill,Z13->Z13_FERRAM)
	aadd(aFieldFill,Posicione('SB1',1,xFilial('SB1')+Z13->Z13_FERRAM,'B1_DESC'))
	aadd(aFieldFill,Z13->Z13_NUMSER)
	aadd(aFieldFill,Z13->Z13_DTEMPR)
	aadd(aFieldFill,Z13->Z13_DTPREV)
	aadd(aFieldFill,Z13->Z13_DTENTR)
	aAdd(aFieldFill, .f.)
	aAdd(aCols, aClone(aFieldFill))
	Z13->(DbSkip())
EndDo

oGet := MsNewGetDados():New( 060, 010, 275, 500	, , 'AllwaysTrue', 'AllwaysTrue', '', aAlterFields, 0, 99, 'AllwaysTrue', '', 'AllwaysTrue', oDlgI, aHeader, aCols)

return
                                   
Static Function AcertaZ13(cSerie,cNum)
DbSelectArea('Z13')
Z13->(DbSetOrder(1))
                                             
TcSqlExec("UPDATE "+RETSQLNAME('Z13')+" SET Z13_STATUS = '2' WHERE Z13_FILIAL = '"+xFilial('Z13')+"' AND Z13_NUM = '"+cNum+"' AND Z13_NUMSER = '"+cSerie+"' ")

return