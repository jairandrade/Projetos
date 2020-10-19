#include "protheus.ch"
#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±

±±ºPrograma  ³TCP_PONA001ºAutor  ³RSAC SOLUCOES      º Data ³  16/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para manutencao de chamadas para trabalho.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ especifico para TCP.                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

user Function TCP_PONA001()
Private cPONMES := Getmv("MV_PONMES")
Private cPerg
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCadastro := OemToAnsi("Chamada para trabalho")
cPerg := 'TCPPON001'

//cria pergunta se não existir
fCriaPerg(cPerg)

//tecla F12 para alterar prametros (SX1)
SetKey(VK_F12, { || AtuMV_PAR() } )

pergunte(cPerg,.f.)


If mv_par01 = 1
	dDtIni := mv_par02
	dDtFim := mv_par03
Else
	dDtIni := stod(Substr(cPONMES,1,8))
	dDtFim := stod(Substr(cPONMES,10,8))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se arquivo IBE estiver declarado chama a funcao de BROWSE    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aRotina := {{ OemToAnsi("Pesquisa")   ,"AxPesqui"    ,0,1   },;
{ OemToAnsi("Visualizar") ,"u_TCPP001V"    ,0,2   },;
{ OemToAnsi("Atualizar")  ,"u_TCPP001I"    ,0,4   }}

mBrowse( 6, 1,22,75,"SRA")

SetKey(VK_F12,Nil)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TCPP001V  ³ Autor³ RSAC SOLUCOES      º Data ³  16/07/12   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Visualizacao do Cadastro                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void TCPP001V(cAlias,nReg,nOpc)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

user Function TCPP001V(cAlias,nReg,nOpc)

Local oDlg
Local nOpcA := 0, nOpcao:=3
Local nCntFor, _c
Local dProxDt
Local cEscalado
Local aFields 	:= {"ZP0_OK","ZP0_DATA","ZP0_DIASEM","ZP0_PER01","ZP0_PER02","ZP0_PER03","ZP0_PER04","ZP0_TNOSEQ","ZP0_ESCALA","ZP0_CONTA","ZP0_FILIAL"}
Local aField	:= {}
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
Private aHeader:={},aCols:={},nUsado:=0,Continua
Private aTela[0][0],aGets[0][0]
Private bCampo := { |nField| FieldName(nField) }
Private aTurno
Private cTurno := ""
Private cSeqTno
Private cDia
Private cTpDia
Private nPosData
Private nPosSem
Private nPosTurno1
Private nPosTurno2
Private nPosTurno3
Private nPosTurno4
Private nPosTurno
Private nPosSeq
Private nPosEsc
Private oGet
Private nTotal := 0
Private oTotal
Private nContPer := 0

SetKey(VK_F12,Nil)

If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aHeader                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//sempre nesta ordem, independente da ordem no SX3.
/*OpenSXs(,,,,,"TMPSX3","SX3")
TMPSX3->(dbSetOrder(2))

TMPSX3->(dbSeek("ZP0_OK"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(TMPSX3->x3_titulo), TMPSX3->x3_campo, TMPSX3->x3_picture,;
TMPSX3->x3_tamanho, TMPSX3->x3_decimal,'.T.',;
TMPSX3->x3_usado, TMPSX3->x3_tipo, TMPSX3->x3_arquivo, TMPSX3->x3_context } )

TMPSX3->(dbSeek("ZP0_DATA"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(TMPSX3->x3_titulo), TMPSX3->x3_campo, TMPSX3->x3_picture,;
TMPSX3->x3_tamanho, TMPSX3->x3_decimal,'.T.',;
TMPSX3->x3_usado, TMPSX3->x3_tipo, TMPSX3->x3_arquivo, TMPSX3->x3_context } )

TMPSX3->(dbSeek("ZP0_DIASEM"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(TMPSX3->x3_titulo), TMPSX3->x3_campo, TMPSX3->x3_picture,;
TMPSX3->x3_tamanho, TMPSX3->x3_decimal,'.T.',;
TMPSX3->x3_usado, TMPSX3->x3_tipo, TMPSX3->x3_arquivo, TMPSX3->x3_context } )


TMPSX3->(dbSeek("ZP0_PER01"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(sx3->x3_titulo),TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,'U_TCPP001R()',;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )

TMPSX3->(dbSeek("ZP0_PER02"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(sx3->x3_titulo),TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,'U_TCPP001R()',;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )


TMPSX3->(dbSeek("ZP0_PER03"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(sx3->x3_titulo),TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,'U_TCPP001R()',;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )


TMPSX3->(dbSeek("ZP0_PER04"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(sx3->x3_titulo),TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,'U_TCPP001R()',;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )

TMPSX3->(dbSeek("ZP0_TNOSEQ"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(sx3->x3_titulo),TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,'.T.',;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )

TMPSX3->(dbSeek("ZP0_ESCALA"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(sx3->x3_titulo),TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,'U_TCPP001E()',;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )

TMPSX3->(dbSeek("ZP0_CONTA"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(sx3->x3_titulo),TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,sx3->x3_valid,;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )

TMPSX3->(dbSeek("ZP0_FILIAL"))
nUsado:=nUsado+1
AADD(aHeader,{ "",TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,sx3->x3_valid,;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )
*/

aEval(aFields,bBlock)
aHeader := aClone(aField)

nPosData   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_DATA"})
nPosSem    := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_DIASEM"})
nPosPer1   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_PER01"})
nPosPer2   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_PER02"})
nPosPer3   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_PER03"})
nPosPer4   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_PER04"})
nPosOK     := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_OK"})
nPosTnoSeq := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_TNOSEQ"})
nPosEsc    := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_ESCALA"})
nPosCont   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_CONTA"})

If !Empty(SRA->RA_TNOTRAB)
	
	//busca turno/ sequencia do funcionário
	SPF->(DbSetOrder(1))
	SPF->(DbSeek(Xfilial("SPF")+SRA->RA_MAT,.T.))
	
	While !SPF->(EOF()) .and. SPF->PF_MAT == SRA->RA_MAT
		If SPF->PF_DATA <= dDtIni
			cTurno  := SPF->PF_TURNOPA
			cSeqTno := SPF->PF_SEQUEPA
		Else
			exit
		EndIf
		SPF->(DbSkip())
	End
	//monta sequncia dos turnos
	BuscaTno(dDtIni)
	
	aCols:={}
	
	//procura chamadas já cadastradas
	cQuery1 := " SELECT ZP0.* "
	cQuery1 += " FROM " + RetSQLName("ZP0")+" ZP0  "
	cQuery1 += " WHERE ZP0_FILIAL = '" + XFILIAL("ZP0") + "' "
	cQuery1 += "       AND ZP0_MAT = '" + SRA->RA_MAT + "' "
	cQuery1 += "       AND ZP0_DATA >=  '" + DTOS(dDtIni)+ "' "
	cQuery1 += "       AND ZP0_DATA <=  '" + DTOS(dDtFim)+ "' "
	cQuery1 += "       AND ZP0.D_E_L_E_T_ <> '*' "
	cQuery1 += " ORDER BY ZP0_DATA "
	
	cQuery := ChangeQuery( cQuery1)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "QRY", .F., .T. )
	dbSelectArea("QRY")
	
	If QRY->(EOF())
		MsgStop("Não existem registros.")
		Return(nOpca)
	Else
		
		While !QRY->(EOF())

			//verifica se existe excecao cadastrada
			/*			SP2->(DbSetOrder(3))
			SP2->(DbSeek(xFilial("SP2")+QRY->ZP0_MAT+Space(12)+QRY->ZP0_DATA,.t.))
			CEscalado := "S"
			If SP2->P2_MAT = QRY->ZP0_MAT .and. SP2->P2_DATA = STOD(QRY->ZP0_DATA)
			cEscalado := "N"
			EndIf
			*/
			//verifica se existe PRE-ABONO
			RF0->(DbSetOrder(1))
			RF0->(DbSeek(xFilial("RF0")+QRY->ZP0_MAT+QRY->ZP0_DATA,.t.))
			cEscalado := "S"
			
			// se tem pre-abono, não foi escalado
			If RF0->RF0_MAT = QRY->ZP0_MAT .and. RF0->RF0_DTPREI = STOD(QRY->ZP0_DATA)
				cEscalado := QRY->ZP0_ESCALA
			EndIf
			
			If alltrim(QRY->ZP0_PER01+QRY->ZP0_PER02+QRY->ZP0_PER03+QRY->ZP0_PER04) = '3'  //folga
				cEscalado := " "
			EndIf
			AADD(aCols,Array(nUsado+1))
			For _c:=1 to nUsado
				aCols[Len(aCols)][_c]:=CriaVar(aHeader[_c][2])
			Next
			aCols[Len(aCols)][nPosOK]     := "X"
			aCols[Len(aCols)][nPosData]   := stod(QRY->ZP0_DATA)
			aCols[Len(aCols)][nPosSem]    := upper(DiaSemana(stod(QRY->ZP0_DATA),3))
			aCols[Len(aCols)][nPosPer1]   := QRY->ZP0_PER01
			aCols[Len(aCols)][nPosPer2]   := QRY->ZP0_PER02
			aCols[Len(aCols)][nPosPer3]   := QRY->ZP0_PER03
			aCols[Len(aCols)][nPosPer4]   := QRY->ZP0_PER04
			aCols[Len(aCols)][nPosTnoSeq] := QRY->ZP0_TNOSEQ
			aCols[Len(aCols)][nPosEsc]    := cEscalado
			aCols[Len(aCols)][nUsado+1]   := .F.
			
			If aCols[Len(aCols)][nPosPer1] $ '12' .and. aCols[Len(aCols)][nPosEsc] = 'S'
				nTotal ++
				nContPer ++
			EndIf
			If aCols[Len(aCols)][nPosPer2] $ '12' .and. aCols[Len(aCols)][nPosEsc] = 'S'
				nTotal ++
				nContPer ++
			EndIf
			If aCols[Len(aCols)][nPosPer3] $ '12' .and. aCols[Len(aCols)][nPosEsc] = 'S'
				nTotal ++
				nContPer ++
			EndIf
			IF aCols[Len(aCols)][nPosPer4] $ '12' .and. aCols[Len(aCols)][nPosEsc] = 'S'
				nTotal ++
				nContPer ++
			EndIf
			aCols[Len(aCols)][nPosCont]   := nContPer
			
			QRY->(DbSkip())
		End
	EndIF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize:= MsAdvSize(,.F.)
	aObjects := {}
	aadd( aObjects, { 0,    25, .T., .F. } )
	aadd( aObjects, { 100, 100, .T., .T. } )
	aadd( aObjects, { 0,    3, .T., .F. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	Continua := .f.
	
	cMat  := SRA->RA_MAT
	cNome := SRA->RA_NOME
	
	DEFINE FONT oFont NAME "Arial" SIZE 000,-012 BOLD
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
	@ 036, 015 Say oSay prompt "Matricula: " SIZE 175, 007 OF oDlg PIXEL FONT oFont
	@ 033, 045 MSGET cMat when .f. SIZE 050, 011 OF oDlg PIXEL FONT oFont
	
	@ 036, 110 SAY oSay prompt "Nome: " SIZE 175, 007 OF oDlg PIXEL FONT oFont
	@ 033, 130 MSGET cNome when .f. SIZE 200, 011 OF oDlg PIXEL FONT oFont
	
	@ 036, 340 SAY oSay prompt "Período: " SIZE 175, 007 OF oDlg PIXEL FONT oFont
	@ 033, 365 MSGET dDtIni when .f. SIZE 050, 011 OF oDlg PIXEL FONT oFont
	
	@ 036, 420 SAY oSay prompt "a: " SIZE 175, 007 OF oDlg PIXEL FONT oFont
	@ 033, 435 MSGET dDtFim when .f. SIZE 050, 011 OF oDlg PIXEL FONT oFont
	
	@ 036, 495 SAY oSay prompt "Total: " SIZE 175, 007 OF oDlg PIXEL FONT oFont
	@ 033, 520 MSGET oTotal var nTotal when .f. Picture "@999" SIZE 050, 011 OF oDlg PIXEL FONT oFont
	
	oGet := MSGETDADOS():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"u_V_LINOK()","U_V_TudoOk()","",.F.,,,,dDtFim-dDtIni)
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||IIF(oGet:TudoOk(),(oDlg:End(),nOpca:=1),nOpca:=0)},{||oDlg:End()},,)
	
Else
	MsgStop("Nenhum turno cadastrado para o funcionario. Verifique.")
EndIf

SetKey(VK_F12, { || AtuMV_PAR() } )

Return(nOpca)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TCPP001I ³ Autor³RSAC SOLUCOES        º Data ³  16/07/12   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de inclusaoo do Cadastro                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void TCPP001i(cAlias,nReg,nOpc)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
user Function TCPP001I(cAlias,nReg,nOpc)

Local oDlg
Local nOpcA := 0, nOpcao:=3
Local nCntFor, _c
Local dProxDt
Local lT01 := .t.
Local lT02 := .t.
Local lT03 := .t.
Local lT04 := .t.
Local lT05 := .t.
Local lT06 := .t.
Local lT07 := .t.
Local cEscalado
Local aFields 	:= {"ZP0_OK","ZP0_DATA","ZP0_DIASEM","ZP0_PER01","ZP0_PER02","ZP0_PER03","ZP0_PER04","ZP0_TNOSEQ","ZP0_ESCALA","ZP0_CONTA","ZP0_FILIAL"}
Local aField	:= {}
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
Private aHeader:={},aCols:={},nUsado:=0,Continua
Private aTela[0][0],aGets[0][0]
Private bCampo := { |nField| FieldName(nField) }
Private aTurno
Private cTurno
Private cSeqTno
Private cDia
Private cTpDia
Private nPosData
Private nPosSem
Private nPosTurno1
Private nPosTurno2
Private nPosTurno3
Private nPosTurno4
Private nPosTurno
Private nPosSeq
Private nPosEsc
Private oGet
Private nTotal := 0
Private oTotal
Private nContPer := 0

SetKey(VK_F12,Nil)

//turnos devem estar no SX6
Private cT01 := Alltrim(GetNewPar("TCP_TNO1", "M01"))
Private cT02 := Alltrim(GetNewPar("TCP_TNO2", "M02"))
Private cT03 := Alltrim(GetNewPar("TCP_TNO3", "M03"))
Private cT04 := Alltrim(GetNewPar("TCP_TNO4", "M04"))
Private cT13 := Alltrim(GetNewPar("TCP_TNO5", "M01"))
Private cT14 := Alltrim(GetNewPar("TCP_TNO6", "M01"))
Private cT24 := Alltrim(GetNewPar("TCP_TNO7", "M02"))
Private cT17 := Alltrim(GetNewPar("TCP_TN17", "195"))
Private cT18 := Alltrim(GetNewPar("TCP_TN19", "M14"))
//Turnos inutilizados, porém mantidos na rotina, pois ela valida se o turno anterior é um turno válido.
Private cT25 := Alltrim(GetNewPar("TCP_TNO9", "M13"))
Private cT26 := Alltrim(GetNewPar("TCP_TN10", "M14"))
Private cT27 := Alltrim(GetNewPar("TCP_TN11", "M24"))

IF ALLTRIM(SRA->RA_CC) $ GetNewPar("TCP_CCAZ", "001037,001049")
	cT01 := Alltrim(GetNewPar("TCP_TNO12", "M05"))
	cT02 := Alltrim(GetNewPar("TCP_TNO13", "M06"))
	cT03 := Alltrim(GetNewPar("TCP_TNO14", "M07"))
	cT04 := Alltrim(GetNewPar("TCP_TNO15", "M08"))
	cT13 := Alltrim(GetNewPar("TCP_TNO16", "M05"))
	cT14 := Alltrim(GetNewPar("TCP_TNO18", "M09"))
	cT24 := Alltrim(GetNewPar("TCP_TNO7", "M05"))
	cT26 := Alltrim(GetNewPar("TCP_TNO18", "M09"))
	cT27 :=  "197"
	cTurno := "M05"
	cSeqTno := '01'
ENDIF
//verifica se os turnos estão cadastrados.
SR6->(DbSetOrder(1))
If !SR6->(DbSeek(xFilial("SR6")+cT01))
	lT01 := .f.
EndIf
If !SR6->(DbSeek(xFilial("SR6")+cT02))
	lT02 := .f.
EndIf
If !SR6->(DbSeek(xFilial("SR6")+cT03))
	lT03 := .f.
EndIf
If !SR6->(DbSeek(xFilial("SR6")+cT04))
	lT04 := .f.
EndIf
If !SR6->(DbSeek(xFilial("SR6")+cT13))
	lT05 := .f.
EndIf
If !SR6->(DbSeek(xFilial("SR6")+cT14))
	lT06 := .f.
EndIf
If !SR6->(DbSeek(xFilial("SR6")+cT24))
	lT07 := .f.
EndIf

If !lT01 .and. !lT02 .and. !lT03 .and. !lT04 .and. !lT05 .and. !lT06 .and. !lT06
	MsgStop("Parametros (SX6) desatualizados. Atualizar os parametros:  TCP_TNO1, TCP_TNO2, TCP_TNO3, TCP_TNO4, TCP_TNO5, TCP_TNO6 6 TCP_TNO7. ")
	Return()
EndIf

If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aHeader                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//sempre nesta ordem, independente da ordem no SX3.
/*OpenSXs(,,,,,"TMPSX3","SX3")
TMPSX3->(dbSetOrder(2))
TMPSX3->(dbSeek("ZP0_OK"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(TMPSX3->x3_titulo),TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,'.T.',;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )

TMPSX3->(dbSeek("ZP0_DATA"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(TMPSX3->x3_titulo),TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,'.T.',;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )

TMPSX3->(dbSeek("ZP0_DIASEM"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(TMPSX3->x3_titulo),TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,'.T.',;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )

TMPSX3->(dbSeek("ZP0_PER01"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(TMPSX3->x3_titulo),TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,'U_TCPP001R()',;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )

TMPSX3->(dbSeek("ZP0_PER02"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(TMPSX3->x3_titulo),TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,'U_TCPP001R()',;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )

TMPSX3->(dbSeek("ZP0_PER03"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(TMPSX3->x3_titulo),TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,'U_TCPP001R()',;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )

TMPSX3->(dbSeek("ZP0_PER04"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(TMPSX3->x3_titulo),TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,'U_TCPP001R()',;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )

TMPSX3->(dbSeek("ZP0_TNOSEQ"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(TMPSX3->x3_titulo),TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,'.T.',;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )

TMPSX3->(dbSeek("ZP0_ESCALA"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(TMPSX3->x3_titulo),TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,'U_TCPP001E()',;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )

TMPSX3->(dbSeek("ZP0_CONTA"))
nUsado:=nUsado+1
AADD(aHeader,{ TRIM(TMPSX3->x3_titulo),TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,sx3->x3_valid,;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )

TMPSX3->(dbSeek("ZP0_FILIAL"))
nUsado:=nUsado+1
AADD(aHeader,{ "",TMPSX3->x3_campo,TMPSX3->x3_picture,;
TMPSX3->x3_tamanho,TMPSX3->x3_decimal,sx3->x3_valid,;
TMPSX3->x3_usado,TMPSX3->x3_tipo,TMPSX3->x3_arquivo,TMPSX3->x3_context } )
*/

aEval(aFields,bBlock)
aHeader := aClone(aField)

nPosData   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_DATA"})
nPosSem    := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_DIASEM"})
nPosPer1   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_PER01"})
nPosPer2   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_PER02"})
nPosPer3   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_PER03"})
nPosPer4   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_PER04"})
nPosOK     := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_OK"})
nPosTnoSeq := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_TNOSEQ"})
nPosEsc    := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_ESCALA"})
nPosCont   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_CONTA"})

If !Empty(SRA->RA_TNOTRAB)
	
	//busca turno/sequencia do funcionario
	SPF->(DbSetOrder(1))
	SPF->(DbSeek(Xfilial("SPF")+SRA->RA_MAT,.T.))
	cTurno := ''
	While !SPF->(EOF()) .and. SPF->PF_MAT == SRA->RA_MAT
		If SPF->PF_DATA <= dDtIni
			cTurno  := SPF->PF_TURNOPA
			cSeqTno := SPF->PF_SEQUEPA
		Else
			exit
		EndIf
		SPF->(DbSkip())
	End
	If Empty(cTurno)
		MsgStop("Não existe turno cadastrado para o funcionario anterior a " + dtoc(dDtIni)  + ". Verifique.")
		Return()
	ElseIf !cTurno $ cT01+cT02+cT03+cT04+cT13+cT14+cT24+cT25+cT26+cT27+cT17+cT18
		MsgStop("Turno cadastrado para o funcionario invalido. Verifique.")
		Return()
	EndIf
	//montra sequencia dos turnos
	BuscaTno(dDtIni)
	
	aCols:={}
	
	//procura chamadas já cadastradas
	cQuery1 := " SELECT ZP0.* "
	cQuery1 += " FROM " + RetSQLName("ZP0")+" ZP0  "
	cQuery1 += " WHERE ZP0_FILIAL = '" + XFILIAL("ZP0") + "' "
	cQuery1 += "       AND ZP0_MAT = '" + SRA->RA_MAT + "' "
	cQuery1 += "       AND ZP0_DATA >=  '" + DTOS(dDtIni)+ "' "
	cQuery1 += "       AND ZP0_DATA <=  '" + DTOS(dDtFim)+ "' "
	cQuery1 += "       AND ZP0.D_E_L_E_T_ <> '*' "
	cQuery1 += " ORDER BY ZP0_DATA "
	
	cQuery := ChangeQuery( cQuery1)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "QRY", .F., .T. )
	dbSelectArea("QRY")
	
	//adicona os as chamadas já cadastradas no acols
	While !QRY->(EOF())
		
		//verifica se existe excecao cadastrada
		/*		SP2->(DbSetOrder(3))
		SP2->(DbSeek(xFilial("SP2")+QRY->ZP0_MAT+Space(12)+QRY->ZP0_DATA,.t.))
		CEscalado := "S"
		If SP2->P2_MAT = QRY->ZP0_MAT .and. SP2->P2_DATA = STOD(QRY->ZP0_DATA)
		cEscalado := "N"
		EndIf
		*/
		//verifica se existe PRE-ABONO
		RF0->(DbSetOrder(1))
		RF0->(DbSeek(xFilial("RF0")+QRY->ZP0_MAT+QRY->ZP0_DATA,.t.))
		cEscalado := "S"
		
		// se tem pre-abono, não foi escalado
		If RF0->RF0_MAT = QRY->ZP0_MAT .and. RF0->RF0_DTPREI = STOD(QRY->ZP0_DATA)
			cEscalado := QRY->ZP0_ESCALA
		EndIf
		
		
		If alltrim(QRY->ZP0_PER01+QRY->ZP0_PER02+QRY->ZP0_PER03+QRY->ZP0_PER04) = '3'  //folga
			cEscalado := " "
		EndIf
		
		AADD(aCols,Array(nUsado+1))
		For _c:=1 to nUsado
			aCols[Len(aCols)][_c]:=CriaVar(aHeader[_c][2])
		Next
		aCols[Len(aCols)][nPosOK]     := "X"
		aCols[Len(aCols)][nPosData]   := stod(QRY->ZP0_DATA)
		aCols[Len(aCols)][nPosSem]    := upper(DiaSemana(stod(QRY->ZP0_DATA),3))
		aCols[Len(aCols)][nPosPer1]   := QRY->ZP0_PER01
		aCols[Len(aCols)][nPosPer2]   := QRY->ZP0_PER02
		aCols[Len(aCols)][nPosPer3]   := QRY->ZP0_PER03
		aCols[Len(aCols)][nPosPer4]   := QRY->ZP0_PER04
		aCols[Len(aCols)][nPosTnoSeq] := QRY->ZP0_TNOSEQ
		aCols[Len(aCols)][nPosEsc]    := cEscalado
				
		aCols[Len(aCols)][nUsado+1]   := .F.
		
		cTurno  := SubStr(QRY->ZP0_TNOSEQ,1,3)
		cSeqTno := SubStr(QRY->ZP0_TNOSEQ,5,2)
		
		//conta quantidade de periodos
		If aCols[Len(aCols)][nPosPer1] $ '12' .and. aCols[Len(aCols)][nPosEsc] = 'S'
			nTotal ++
			nContPer ++		
		EndIf
		If aCols[Len(aCols)][nPosPer2] $ '12' .and. aCols[Len(aCols)][nPosEsc] = 'S'
			nTotal ++
			nContPer ++
		EndIf
		If aCols[Len(aCols)][nPosPer3] $ '12' .and. aCols[Len(aCols)][nPosEsc] = 'S'
			nTotal ++
			nContPer ++
		EndIf
		IF aCols[Len(aCols)][nPosPer4] $ '12' .and. aCols[Len(aCols)][nPosEsc] = 'S'
			nTotal ++
			nContPer ++
		EndIf
		aCols[Len(aCols)][nPosCont]   := nContPer
		
		QRY->(DbSkip())
	End
	
	If Len(aCols) = 0  //se não tem nenhuma chamada cadastrada
		cTpDia := ''
		GravaAcols(dDtIni,dDtFim,cTpDia,cTurno,cSeqTno)
		
		//tem chamadas, mas faltam alguns dias até o fim do periodo solicitado
	Elseif aCols[Len(aCols)][nPosData] < dDtFim
		BuscaTno(aCols[Len(aCols)][nPosData]+1)
		cTpDia := ''
		GravaAcols(aCols[Len(aCols)][nPosData]+1,dDtFim,cTpDia,cTurno,cSeqTno)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize:= MsAdvSize(,.F.)
	aObjects := {}
	aadd( aObjects, { 0,    25, .T., .F. } )
	aadd( aObjects, { 100, 100, .T., .T. } )
	aadd( aObjects, { 0,    3, .T., .F. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	Continua := .f.
	
	cMat  := SRA->RA_MAT
	cNome := SRA->RA_NOME
	
	DEFINE FONT oFont NAME "Arial" SIZE 000,-012 BOLD
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
	@ 036, 015 Say oSay prompt "Matricula: " SIZE 175, 007 OF oDlg PIXEL FONT oFont
	@ 033, 045 MSGET cMat when .f. SIZE 050, 011 OF oDlg PIXEL FONT oFont
	
	@ 036, 110 SAY oSay prompt "Nome: " SIZE 175, 007 OF oDlg PIXEL FONT oFont
	@ 033, 130 MSGET cNome when .f. SIZE 200, 011 OF oDlg PIXEL FONT oFont
	
	@ 036, 340 SAY oSay prompt "Período: " SIZE 175, 007 OF oDlg PIXEL FONT oFont
	@ 033, 365 MSGET dDtIni when .f. SIZE 050, 011 OF oDlg PIXEL FONT oFont
	
	@ 036, 420 SAY oSay prompt "a: " SIZE 175, 007 OF oDlg PIXEL FONT oFont
	@ 033, 435 MSGET dDtFim when .f. SIZE 050, 011 OF oDlg PIXEL FONT oFont
	
	@ 036, 495 SAY oSay prompt "Total: " SIZE 175, 007 OF oDlg PIXEL FONT oFont
	@ 033, 520 MSGET oTotal var nTotal when .f. Picture "@999" SIZE 050, 011 OF oDlg PIXEL FONT oFont
	
	oGet := MSGETDADOS():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"u_V_LINOK()","U_V_TudoOk()","",.F.,,,,dDtFim-dDtIni)
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||IIF(oGet:TudoOk(),(oDlg:End(),nOpca:=1),nOpca:=0)},{||oDlg:End()},,)
	
	If ( nOpcA == 1 )
		Begin Transaction
		//grava ZP0
		Grava(cAlias,nOpcao,cMat)
		
		End Transaction
	Endif
Else
	MsgStop("Nenhum turno cadastrado para o funcionario. Verifique.")
EndIf

SetKey(VK_F12, { || AtuMV_PAR() } )

Return(nOpca)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TCP_PONA001ºAutor  ³RSAC SOLUCOES      º Data ³  16/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclusao automatica no ACOLS de acordo com o turno         º±±
±±º          ³ sequnecia.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TCPP001R()
Local lRet := .F.
Local s

nPosData   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_DATA"})
nPosPer1   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_PER01"})
nPosPer2   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_PER02"})
nPosPer3   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_PER03"})
nPosPer4   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_PER04"})
nPosOK     := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_OK"})
nPosTnoSeq := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_TNOSEQ"})
nPosEsc    := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_ESCALA"})

cPerAtu := SubStr(ReadVar(),4,9) //é o periodo ataual que está sendo alterado
nPosAtu := ascan(aHeader,{|x| alltrim(x[2]) == cPerAtu})

dDataI := aCols[n,nPosData]
dDataF := aCols[len(aCols),nPosData]
cTipo  := M->(&cPerAtu)

//busca novo turno/sequencia
SR6->(DbSetOrder(1))
If cTipo = '1'    //perido normal
	If n > 1
		If aCols[n-1,nPosEsc] = 'S' //se estiver escalado no dia anterior
			For s := 1 to 4 //4 periodos
				If aCols[n-1,s+3] $ '12'  //dia anterior
					nDif := nPosAtu - 3 - s
					If nDif >= -1
						lRet := .T.
					Else
						lRet := .F.
					Endif
					//					Exit
				ElseIf aCols[n-1,s+3] = '3'
					lRet := .T.
				EndIf
			Next
		Else   //se não estiver escalado no dia anterior
			lRet := .T.
		EndIf
	Else
		If ZP0->(DbSeek(XFilial("ZP0")+SRA->RA_MAT+DTOS(dDataI-1))) //dia anterior
			If ZP0->ZP0_ESCALA = 'S'  // se estiver escalado no dia anterior
				If ZP0->ZP0_PER01 $ '14'
					nDif := nPosAtu - 3 - 1
					If nDif >= -1
						lRet := .T.
					Else
						lRet := .F.
					Endif
				EndIf
				If ZP0->ZP0_PER02 $ '14'
					nDif := nPosAtu - 3 - 2
					If nDif >= -1
						lRet := .T.
					Else
						lRet := .F.
					Endif
				EndIf
				If ZP0->ZP0_PER03 $ '14'
					nDif := nPosAtu - 3 - 3
					If nDif >= -1
						lRet := .T.
					Else
						lRet := .F.
					Endif
				EndIf
				If ZP0->ZP0_PER04  $ '14'
					nDif := nPosAtu - 3 - 4
					If nDif >= -1
						lRet := .T.
					Else
						lRet := .F.
					Endif
				EndIf
			Else   //se não estiver escalado no dia anterior
				lRet := .T.
			EndIf
			
		Else
			lRet := .T.
		EndIf
		
	EndIf
	If lRet
		If nPosAtu - 3 = 1
			cPer := cT01
		ElseIf nPosAtu - 3 = 2
			cPer := cT02
		ElseIf nPosAtu - 3 = 3
			cPer := cT03
		ElseIf nPosAtu - 3 = 4
			cPer := cT04
		EndIf
	EndIf
ElseIf cTipo = '3'    //FOLGA
	If nPosAtu - nPosPer1 = 0
		cPer := cT01
	EndIf
	If nPosAtu - nPosPer2 = 0
		cPer := cT02
	EndIf
	If nPosAtu - nPosPer3 = 0
		cPer := cT03
	EndIf
	If nPosAtu - nPosPer4 = 0
		cPer := cT04
	EndIf
	lRet := .T.
ElseIf cTipo ='4'  	//recusa
	If !acols[n][nPosAtu] $ '12'
		lRet := .F.
	Else 
		lRet := .T.	
	EndIf
ElseIf cTipo ='2'  	//periodo adicional
	If empty(acols[n][nPosAtu])
		If n > 1
			For s := 1 to 4 //4 periodos
				//			If s <> nPosAtu - 3
				If aCols[n-1,s+3] $ '14'  //dia anterior
					nDif := nPosAtu - 3 - s
					If nDif >= 2  .or. nDif >= -1
						lRet := .T.
					Else
						lRet := .F.
					Endif
					Exit
				ElseIf aCols[n-1,s+3] = '3'
					lRet := .T.
				EndIf
				//			EndIf
			Next
			
			If lRet
				For s := 1 to 4 //4 periodos
					If s <> nPosAtu - 3
						If aCols[n,s+3] $ '14'  //dia atual
							nDif := abs(nPosAtu - 3 - s)
							If nDif >= 3
								lRet := .T.
							Else
								lRet := .F.
							Endif
							Exit
						ElseIf aCols[n,s+3] = '3'
							lRet := .F.
						EndIf
					EndIf
				Next
			EndIf
			
			If lRet
				//valida os dados do dia seguinte
				If n + 1 > len(aCols)
					If ZP0->(DbSeek(XFilial("ZP0")+SRA->RA_MAT+DTOS(dDataI+1)))  //dia seguinte
						
						If ZP0->ZP0_PER01 $ '14'
							nDif := nPosAtu - 3 - 1
							If nDif = 1
								lRet := .T.
							Else
								lRet := .F.
							Endif
						EndIf
						If ZP0->ZP0_PER02 $ '14'
							nDif := nPosAtu - 3 - 2
							If nDif = 1
								lRet := .T.
							Else
								lRet := .F.
							Endif
						EndIf
						If ZP0->ZP0_PER03 $ '14'
							nDif := nPosAtu - 3 - 3
							If nDif = 1
								lRet := .T.
							Else
								lRet := .F.
							Endif
						EndIf
						If ZP0->ZP0_PER04 $ '14'
							nDif := nPosAtu - 3 - 4
							If nDif = 1
								lRet := .T.
							Else
								lRet := .F.
							Endif
						EndIf
					Else
						lRet := .T.
					EndIf
				EndIf

			EndIf			
			
		Else
			If ZP0->(DbSeek(XFilial("ZP0")+SRA->RA_MAT+DTOS(dDataI-1)))  //dia anterior
				
				If ZP0->ZP0_PER01 $ '14'
					nDif := nPosAtu - 3 - 1
					If nDif = -1
						lRet := .T.
					Else
						lRet := .F.
					Endif
				EndIf
				If ZP0->ZP0_PER02 $ '14'
					nDif := nPosAtu - 3 - 2
					If nDif = -1
						lRet := .T.
					Else
						lRet := .F.
					Endif
				EndIf
				If ZP0->ZP0_PER03 $ '14'
					nDif := nPosAtu - 3 - 3
					If nDif = -1
						lRet := .T.
					Else
						lRet := .F.
					Endif
				EndIf
				If ZP0->ZP0_PER04 $ '14'
					nDif := nPosAtu - 3 - 4
					If nDif = -1
						lRet := .T.
					Else
						lRet := .F.
					Endif
				EndIf
			Else
				lRet := .T.
			EndIf
			If lRet
				For s := 1 to 4 //4 periodos
					If s <> nPosAtu - 3
						If aCols[n,s+3] $ '14'  //dia atual
							nDif := abs(nPosAtu - 3 - s)
							If nDif >= 3
								lRet := .T.
							Else
								lRet := .F.
							Endif
							Exit
						ElseIf aCols[n,s+3] = '3'
							lRet := .F.
						EndIf
					EndIf
				Next
			EndIf
		EndIf
	EndIf
	//	If (s = 1 .and. (nPosAtu - 3) = 4) .or. (s = 4 .and. (nPosAtu - 3) = 1)
	//		lRet := .F.
	//	EndIf
	
	If lRet     //1            //3 turno         //3                   //1turno
		If (s = 1 .and. (nPosAtu - 3) = 3) .or. (s = 3 .and. (nPosAtu - 3) = 1)
			cPer := cT13
		ElseIf (s = 1 .and. (nPosAtu - 3) = 4) .or. (s = 4 .and. (nPosAtu - 3) = 1)
			cPer := cT14                 //4 turno                   //2
		ElseIf (s = 2 .and. (nPosAtu - 3) = 4) .or. (s = 4 .and. (nPosAtu - 3) = 2)
			cPer := cT24
		EndIf
	EndIf
Else
	
	For s := 1 to 4 //4 periodos
		If s <> nPosAtu - 3
			If aCols[n,s+3] = '1'
				Exit
			EndIf
		EndIf
	Next
	If s > 4
		lRet := .F.
	Else
		If s = 1
			cPer := cT01
		EndIf
		If s = 2
			cPer := cT02
		EndIf
		If s = 3
			cPer := cT03
		EndIf
		If s = 4
			cPer := cT04
		EndIf
		
		lRet := .T.
	EndIf
EndIf

if lRet .AND. ALLTRIM(SRA->RA_CC) $ GetNewPar("TCP_CCAZ", "001037,001049")  .AND. (cTipo == '3' .OR. aCols[n,nPosAtu] == '3')
	lRet := .F.
	MsgAlert("Alteração não permitida. Faça este lançamento diretamente na tela Integrados.")
ENDIF

If lRet .and. empty(cTipo).and. aCols[n,nPosAtu] = '2'
	
	aCols[n][nPosTnoSeq] := cPer + "/" + substr(aCols[n][nPosTnoSeq],5,2)
//	aCols[n][nPosCont]   := aCols[n][nPosCont] + 1
	
//	nTotal --
ElseIf lRet .and. cTipo $ '13' .and. cTipo <> aCols[n,nPosAtu]
	aTurno := {}
	SR6->(DbSeek(xFilial("SR6")+cPer),.t.)
	cTurno := SR6->R6_TURNO
	
	SPJ->(DbSeek(xFilial("SPJ")+cTurno),.t.)
	
	While !SPJ->(EOF()) .and. cTurno = SPJ->PJ_TURNO
		//tratamento do domingo
		If SPJ->PJ_DIA = '1'
			cDia := '9'
		Else
			cDia := SPJ->PJ_DIA
		EndIf
		
		If SPJ->PJ_TPDIA == 'S' //trabalho normal
			cTp := '1'
		ElseIf SPJ->PJ_TPDIA == 'D' //fOlga
			cTp := '3'
		EndIf
		aadd(aTurno,{SPJ->PJ_TURNO, SPJ->PJ_SEMANA, cDia, cTp})
		SPJ->(DbSkip())
	End
	
	aTurno := aSort( aTurno , , , { |x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]  } )
	
	cSeqTno := substr(aCols[n][nPosTnoSeq],5,2)
	
	GravaAcols(dDataI,dDataF,cTipo,cTurno, cSeqTno)

	
ElseIf lRet .and. cTipo = '2'
	aCols[n][nPosAtu] := cTipo
	aCols[n][nPosTnoSeq] := cPer + "/" + substr(aCols[n][nPosTnoSeq],5,2)
//	aCols[n][nPosCont]   := aCols[n][nPosCont] - 1
	
	aTurno := {}
	
	If nPosAtu - 3 = 1
		cPer := cT04
	EndIf
	
	If nPosAtu - 3 = 2
		cPer := cT01
	EndIf
	
	If nPosAtu - 3 = 3
		cPer := cT02
	EndIf
	
	If nPosAtu - 3 = 4
		cPer := cT03
	EndIf
	SR6->(DbSeek(xFilial("SR6")+cPer),.t.)
	cTurno := SR6->R6_TURNO
	
	SPJ->(DbSeek(xFilial("SPJ")+cTurno),.t.)
	
	While !SPJ->(EOF()) .and. cTurno = SPJ->PJ_TURNO
		//tratamento do domingo
		If SPJ->PJ_DIA = '1'
			cDia := '9'
		Else
			cDia := SPJ->PJ_DIA
		EndIf
		
		If SPJ->PJ_TPDIA == 'S' //trabalho normal
			cTp := '1'
		ElseIf SPJ->PJ_TPDIA == 'D' //fOlga
			cTp := '3'
		EndIf
		aadd(aTurno,{SPJ->PJ_TURNO, SPJ->PJ_SEMANA, cDia, cTp})
		SPJ->(DbSkip())
	End
	
	aTurno := aSort( aTurno , , , { |x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]  } )
    
	//valida os dados do dia seguinte
	If n + 1 <= len(aCols)
	
		If Substr(aCols[n+1][nPosTnoSeq],1,3) = cT01
			cTipo := aCols[n+1][nPosPer1]
		EndIf
		If Substr(aCols[n+1][nPosTnoSeq],1,3) = cT02
			cTipo := aCols[n+1][nPosPer2]
		EndIf
		If Substr(aCols[n+1][nPosTnoSeq],1,3) = cT03
			cTipo := aCols[n+1][nPosPer3]
		EndIf
		If Substr(aCols[n+1][nPosTnoSeq],1,3) = cT04
			cTipo := aCols[n+1][nPosPer4]
		EndIf
		GravaAcols(Acols[n+1][nPosData],dDataF,cTipo,cTurno, cSeqTno)

	EndIf
ElseIf lRet .and. cTipo = '4'
	aCols[n][nPosAtu] := cTipo
	aCols[n][nPosEsc] := 'S'  
	Totaliza()
ElseIf !lRet
	MsgAlert("Alteração não permitida.")
EndIf

oTotal:Refresh()

Return(lRet)

//sem validacao final
User Function V_TUDOOK()

Return (.T.)

//sem validação da linha
User Function V_LINOK()
Return(.T.)



User Function TCPP001E()
Local lRet := .T.
If M->ZP0_ESCALA <> '' .and. (aCols[n][nPosPer1] $ '3' .or. aCols[n][nPosPer2] $ '3' .or. aCols[n][nPosPer3] $ '3' .or. aCols[n][nPosPer4] $ '3' )
	lRet := .F.
EndIf

If M->ZP0_ESCALA = 'N' .and. (aCols[n][nPosPer1] $ '4' .or. aCols[n][nPosPer2] $ '4' .or. aCols[n][nPosPer3] $ '4' .or. aCols[n][nPosPer4] $ '4' )
	lRet := .F.
EndIf

If lret 
	aCols[n][nPosEsc] := M->ZP0_ESCALA

	If M->ZP0_ESCALA = 'N' .and. M->ZP0_ESCALA <> aCols[n][nPosEsc] .and. (aCols[n][nPosPer1] $ '12' .or. aCols[n][nPosPer2] $ '12' .or. aCols[n][nPosPer3] $ '12' .or. aCols[n][nPosPer4] $ '12' )
		nTotal --
	EndIf

	If M->ZP0_ESCALA = 'S' .and. M->ZP0_ESCALA <> aCols[n][nPosEsc] .and. (aCols[n][nPosPer1] $ '12' .or. aCols[n][nPosPer2] $ '12' .or. aCols[n][nPosPer3] $ '12' .or. aCols[n][nPosPer4] $ '12' )
		nTotal ++
	EndIf
Else
	MsgAlert("Alteração não permitida.")
EndIf

Totaliza()
oTotal:Refresh()
Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Grava      ºAutor  ³³RSAC SOLUCOES     º Data ³  16/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava chamdas para trabalho (ZP0) e grava as trocas de     º±±
±±º          ³ turno (SPF)                                               º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Grava(cAlias,nOpcao, cMat)
Local _y, _x
Local nPosData   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_DATA"})
Local nPosSem    := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_DIASEM"})
Local nPosPer1   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_PER01"})
Local nPosPer2   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_PER02"})
Local nPosPer3   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_PER03"})
Local nPosPer4   := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_PER04"})
Local nPosTnoSeq := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_TNOSEQ"})
Local nPosEsc    := ascan(aHeader,{|x| alltrim(x[2]) == "ZP0_ESCALA"})
Local cRegDe     := SRA->RA_REGRA
Local nPos, xCampo, cTnoATu, cSeqAtu, dDtTno, cTnoAnt, cSeqAnt

ZP0->(dbSetOrder(1))
SPF->(DbSetOrder(1))
For _x := 1 to len(aCols)
	if aCols[_x][len(aHeader)+1] .OR.; //DELETADO
		empty(aCols[_x][nPosPer1]+aCols[_x][nPosPer2]+aCols[_x][nPosPer3]+aCols[_x][nPosPer4]) // se todos em branco
		if ZP0->(dbSeek(xFilial("ZP0")+cMat+dtos(aCols[_x][nPosData])))
			Reclock("ZP0",.f.)
			ZP0->(dbDelete())
			Msunlock()
		EndIf
	else
		If !empty(aCols[_x][nPosPer1]+aCols[_x][nPosPer2]+aCols[_x][nPosPer3]+aCols[_x][nPosPer4]) // se não vazio
			if ZP0->(dbSeek(xFilial("ZP0")+cMat+dtos(aCols[_x][nPosData])))
				Reclock("ZP0",.f.)
			else
				Reclock("ZP0",.t.)
			endif
			ZP0->ZP0_FILIAL  := XFilial("ZP0")
			ZP0->ZP0_MAT  := CMat
			For _y := 1 to len(aHeader)
				If alltrim(aHeader[_y][2]) <> "ZP0_FILIAL"
					If(nPos   := ZP0->(FieldPos(aHeader[_y][2])))>0
						xCampo := aCols[_x][_y]
						ZP0->(FieldPut(nPos,xCampo))
					EndIf
				EndIf
			Next
			ZP0->(Msunlock())
			
			//			If _x > 1
			cTnoATu := SubStr(aCols[_x][nPosTnoSeq],1,3)
			cSeqAtu := SubStr(aCols[_x][nPosTnoSeq],5,2)
			dDtTno  := aCols[_x][nPosData]
			If _x = 1
				cTnoAnt := cTnoATu
				cSeqAnt := cSeqAtu
			Else
				cTnoAnt := SubStr(aCols[_x-1][nPosTnoSeq],1,3)
				cSeqAnt := SubStr(aCols[_x-1][nPosTnoSeq],5,2)
			EndIf
			If cTnoAnt <> cTnoATu .or. cSeqAnt <> cSeqAtu .or. cTnoAnt == cT27 .OR. cTnoATu == cT27
				If !SPF->(DbSeek(Xfilial("SPF")+cMat+dtos(dDtTno)))
					RecLoCk("SPF",.T.)
					SPF->PF_FILIAL  := xFilial("SPF")
					SPF->PF_MAT     := cMat
					SPF->PF_DATA    := dDtTno
					SPF->PF_TURNODE := cTnoAnt
					SPF->PF_SEQUEDE := cSeqAnt
					SPF->PF_REGRADE := cRegDe
					SPF->PF_TURNOPA := cTnoATu
					SPF->PF_SEQUEPA := cSeqAtu
					SPF->PF_REGRAPA := cRegDe
					MsUnLock()
				Else
					RecLock("SPF",.f.)
					SPF->PF_TURNODE := cTnoAnt
					SPF->PF_SEQUEDE := cSeqAnt
					SPF->PF_REGRADE := cRegDe
					SPF->PF_TURNOPA := cTnoATu
					SPF->PF_SEQUEPA := cSeqAtu
					SPF->PF_REGRAPA := cRegDe
					MsUnLock()
				EndIf
			Else
				If SPF->(DbSeek(Xfilial("SPF")+cMat+dtos(dDtTno)))
					RecLoCk("SPF",.f.)
					SPF->PF_FILIAL  := xFilial("SPF")
					SPF->PF_MAT     := cMat
					SPF->PF_DATA    := dDtTno
					SPF->PF_TURNODE := cTnoAnt
					SPF->PF_SEQUEDE := cSeqAnt
					SPF->PF_REGRADE := cRegDe
					SPF->PF_TURNOPA := cTnoATu
					SPF->PF_SEQUEPA := cSeqAtu
					SPF->PF_REGRAPA := cRegDe
					MsUnLock()
					
					SPF->(DbSkip())
					If cMat == SPF->PF_MAT
						RecLock("SPF",.f.)
						
						SPF->PF_TURNODE := cTnoAnt
						SPF->PF_SEQUEDE := cSeqAnt
						SPF->PF_REGRADE := cRegDe
						SPF->PF_TURNOPA := cTnoATu
						SPF->PF_SEQUEPA := cSeqAtu
						SPF->PF_REGRAPA := cRegDe
					EndIf
				EndIf
			EndIf
			//			EndIf
			
		EndIf
	EndIf
	cStatus := aCols[_x][nPosPer1] + aCols[_x][nPosPer2] +  aCols[_x][nPosPer3] + aCols[_x][nPosPer4]
	// 	GravaSP2(cMat,aCols[_x][nPosData],aCols[_x][nPosEsc],cStatus)
	GravaRF0(cMat,aCols[_x][nPosData],aCols[_x][nPosEsc],cStatus)
	
Next
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GravaAcols ºAutor  ³³RSAC SOLUCOES     º Data ³  16/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava aCols                                                º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GravaAcols(dDtIni,dDtFim,cTpDia,cTurno,cSeqTno)
Local lPrimeiro := .T.
Local _c
dProxDt := dDtIni
SR6->(DbSetOrder(1))
While dProxDt <= dDtFim

	//busca turno/sequencia do funcionario
	SPF->(DbSetOrder(1))
	SPF->(DbSeek(Xfilial("SPF")+SRA->RA_MAT,.T.))
	
	While !SPF->(EOF()) .and. SPF->PF_MAT == SRA->RA_MAT
		If SPF->PF_DATA <= dProxDt
			cNovoTurno  := SPF->PF_TURNOPA
			cNovaSeqTno := SPF->PF_SEQUEPA
		Else
			exit
		EndIf
		SPF->(DbSkip())
	End
	
	If !cNovoTurno $ cT01+cT02+cT03+cT04+cT13+cT14+cT24+cT25+cT26+cT27+cT17+cT18
		Return()
	EndIf
	
	If cTurno <> cNovoTurno //.or. cSeqTno <> cNovaSeqTno
		BuscaTno(dProxDt)
	EndIf
	
	//tratamento domingo
	If DOW(dProxDt) = 1
		cDia := '9'
	Else
		cDia := Strzero(DOW(dProxDt),1)
	EndIf
	
	If Empty(cTpDia) //se ainda nção tem nenhuma chamada cadastrada.
		SR6->(DbSeek(xFilial("SR6")+cTurno),.t.)
		AADD(aCols,Array(nUsado+1))
		For _c:=1 to nUsado
			aCols[Len(aCols)][_c]:=CriaVar(aHeader[_c][2])
		Next
		aCols[Len(aCols)][nPosData] := dProxDt
		aCols[Len(aCols)][nPosSem]  := upper(DiaSemana(dProxDt,3))
		
		//posiciona no turno/sequncia que foi montado
		nPosTurno := ascan(aTurno,{|x| alltrim(x[1]+x[2]+x[3]) == cTurno+cSeqTno+cDia})
		
		//		If Alltrim(SR6->R6_DESC) = '07:00 - 13:00'  //TALVEZ CRRIAR UM CAMPO NA SR6 PARA INFORMAR QUAL O PERIODO (1,2,3 OU 4)
		If SR6->R6_TURNO = cT01
			aCols[Len(aCols)][nPosPer1] := aTurno[nPosTurno][4]
		EndIf
		//		If Alltrim(SR6->R6_DESC) = '13:00 - 19:00'
		If SR6->R6_TURNO = cT02
			aCols[Len(aCols)][nPosPer2] := aTurno[nPosTurno][4]
		EndIf                                          	
		//		If Alltrim(SR6->R6_DESC) = '19:00 - 01:00'
		If SR6->R6_TURNO = cT03
			aCols[Len(aCols)][nPosPer3] := aTurno[nPosTurno][4]
		EndIf
		//		If Alltrim(SR6->R6_DESC) = '01:00 - 07:00'
		If SR6->R6_TURNO = cT04
			aCols[Len(aCols)][nPosPer4] := aTurno[nPosTurno][4]
		EndIf
		aCols[Len(aCols)][nPosTnoSeq] := aTurno[nPosTurno][1] + "/" + aTurno[nPosTurno][2]
		
		If aTurno[nPosTurno][4] = '3'
			aCols[Len(aCols)][nPoseSC] := ' '
		Else
			aCols[Len(aCols)][nPoseSC] := 'S'
		EndIf
	Else  //se já existe chamada cadastrada
		SR6->(DbSeek(xFilial("SR6")+cTurno),.t.)
		
		If lPrimeiro
			//			nPosTurno := ascan(aTurno,{|x| alltrim(x[1]+x[3]+x[4]) == cTurno+cDia+cTpDia})
			If cTpDia = '1'
				cSeqTno := substr(aCols[n][nPosTnoSeq],5,2)
				nPosTurno := ascan(aTurno,{|x| alltrim(x[1]+x[2]+x[3]) == cTurno+cSeqTno+cDia})
				If cTpDia <> aTurno[nPosTurno][4]
					nPosTurno := ascan(aTurno,{|x| alltrim(x[1]+x[3]+x[4]) == cTurno+cDia+cTpDia})
					IF nPosTurno > 0
						SeqTno := aTurno[nPosTurno][2]
					ELSE
						SeqTno := '01'
					ENDIF
				EndIf
				lPrimeiro  := .F.
			ElseIf cTpDia = '3'
				nPosTurno := ascan(aTurno,{|x| alltrim(x[1]+x[3]+x[4]) == cTurno+cDia+cTpDia})
				IF nPosTurno > 0
					SeqTno := aTurno[nPosTurno][2]
				ELSE
					SeqTno := '01'
				ENDIF
				lPrimeiro  := .F.
			EndIf
		Else
			nPosTurno := ascan(aTurno,{|x| alltrim(x[1]+x[2]+x[3]) == cTurno+cSeqTno+cDia})
		EndIf
		
		nPosDia  := ascan(aCols,{|x| x[nPosData] == dProxDt})

/*		IF aCols[nPosDia][nPosPer1] $ '12' .and. aCols[nPosDia][nPosEsc] = 'S'
			aCols[nPosDia][nPosCont] := aCols[nPosDia][nPosCont] + 1
		EndIf
		IF aCols[nPosDia][nPosPer2] $ '12' .and. aCols[nPosDia][nPosEsc] = 'S'
			aCols[nPosDia][nPosCont] := aCols[nPosDia][nPosCont] + 1
		EndIf
		IF aCols[nPosDia][nPosPer3] $ '12' .and. aCols[nPosDia][nPosEsc] = 'S'
			aCols[nPosDia][nPosCont] := aCols[nPosDia][nPosCont] + 1
		EndIf
		IF aCols[nPosDia][nPosPer4] $ '12' .and. aCols[nPosDia][nPosEsc] = 'S'
			aCols[nPosDia][nPosCont] := aCols[nPosDia][nPosCont] + 1
		EndIf
		
*/
		//limpa a chamada atual para gravar novamente
		aCols[nPosDia][nPosPer1]   := ""
		aCols[nPosDia][nPosPer2]   := ""
		aCols[nPosDia][nPosPer3]   := ""
		aCols[nPosDia][nPosPer4]   := ""
		aCols[nPosDia][nPosTnoSeq] := ""
		aCols[nPosDia][nPoseSC]    := ""
		
		If SR6->R6_TURNO = cT01
			aCols[nPosDia][nPosPer1] := aTurno[nPosTurno][4]
		EndIf
		
		If SR6->R6_TURNO = cT02
			aCols[nPosDia][nPosPer2] := aTurno[nPosTurno][4]
		EndIf
		
		If SR6->R6_TURNO = cT03
			aCols[nPosDia][nPosPer3] := aTurno[nPosTurno][4]
		EndIf
		
		If SR6->R6_TURNO = cT04
			aCols[nPosDia][nPosPer4] := aTurno[nPosTurno][4]
		EndIf
		aCols[nPosDia][nPosTnoSeq] := aTurno[nPosTurno][1] + "/" + aTurno[nPosTurno][2]
		If aTurno[nPosTurno][4] = '3'
			aCols[nPosDia][nPoseSC] := ' '
		Else
			aCols[nPosDia][nPoseSC] := 'S'
		EndIf

/*		IF aCols[nPosDia][nPosPer1] $ '12' .and. aCols[nPosDia][nPosEsc] = 'S'
			aCols[nPosDia][nPosCont] := aCols[nPosDia][nPosCont] - 1
		EndIf
		IF aCols[nPosDia][nPosPer2] $ '12' .and. aCols[nPosDia][nPosEsc] = 'S'
			aCols[nPosDia][nPosCont] := aCols[nPosDia][nPosCont] - 1
		EndIf
		IF aCols[nPosDia][nPosPer3] $ '12' .and. aCols[nPosDia][nPosEsc] = 'S'
			aCols[nPosDia][nPosCont] := aCols[nPosDia][nPosCont] - 1
		EndIf
		IF aCols[nPosDia][nPosPer4] $ '12' .and. aCols[nPosDia][nPosEsc] = 'S'
			aCols[nPosDia][nPosCont] := aCols[nPosDia][nPosCont] - 1
		EndIf
*/
	EndIf
	
	//faz tratamento da sequencia. Quando for sequencia 06 volta para sequencia 01.
	If DOW(dProxDt) = 1 .AND.  ! (ALLTRIM(SRA->RA_CC) $ GetNewPar("TCP_CCAZ", "001037,001049") )
		If cSeqTno = '06'
			cSeqTno := '01'
		Else
			cSeqTno := StrZero(Val(cSeqTno)+1,2)
		EndIf
	EndIf
		
	aCols[Len(aCols)][nUsado+1] := .F.
	
	dProxDt += 1
End

//totaliza quantidade de chamadas
Totaliza()
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  BuscaTno    ºAutor  ³³RSAC SOLUCOES     º Data ³  16/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta turno/sequencia                                      º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BuscaTno(dData)

aTurno := {}

SR6->(DbSetOrder(1))

SPJ->(DbSetOrder(1))
SPJ->(DbSeek(xFilial("SPJ")+cTurno ))

While !SPJ->(EOF()) .and. cTurno = SPJ->PJ_TURNO
	//tratamento domingo
	If SPJ->PJ_DIA = '1'
		cDia := '9'
	Else
		cDia := SPJ->PJ_DIA
	EndIf
	
	If SPJ->PJ_TPDIA == 'S'  //trabalho noraml
		cTp := '1'
	ElseIf SPJ->PJ_TPDIA == 'D'  //folga
		cTp := '3'
	EndIf
	aadd(aTurno,{SPJ->PJ_TURNO, SPJ->PJ_SEMANA, cDia, cTp})
	SPJ->(DbSkip())
End

aTurno := aSort( aTurno , , , { |x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]  } )
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  GravaSP2    ºAutor  ³³RSAC SOLUCOES     º Data ³  16/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava SP2 (EXCECOES)                                       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*Static Function GravaSP2(cMat,dDtSP2,cOpcao,cStatus)
SP2->(DbSetOrder(3))
SP2->(DbSeek(xFilial("SP2")+cMat+Space(12)+dtos(dDtSP2),.t.))
If SP2->P2_MAT = cMat .and. SP2->P2_DATA = dDtSP2
If "3" $ cStatus  //folga
Reclock("SP2",.F.)
SP2->(DbDelete())
MsUnLock()
Else
If cOpcao = "S"
Reclock("SP2",.F.)
SP2->(DbDelete())
MsUnLock()
EndIf
EndIf
Else
If "1" $ cStatus  //periodo normal
If cOpcao = "N"
Reclock("SP2",.T.)
SP2->P2_FILIAL  := xFilial("SP2")
SP2->P2_MAT     := cMat
SP2->P2_DATA    := dDtSP2
SP2->P2_DATAATE := dDtSP2
SP2->P2_CODHEXT := "1"
SP2->P2_CODHNOT := "5"
SP2->P2_TRABA   := "N"
SP2->P2_MOTIVO  := "NAO ESCALADO"
SP2->P2_NONAHOR := "N"
SP2->P2_HNOTTAB := "N"
SP2->P2_HNOTTBI := "N"
SP2->P2_HERDHOR := "N"
SP2->P2_MINHNOT := 0.01
MsUnLock()
EndIf
EndIf

EndIf
Return()
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  GravaRF0    ºAutor  ³³RSAC SOLUCOES     º Data ³  16/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava RF0 (PRE-ABONO)                                      º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaRF0(cMat,dDtRF0,cOpcao,cStatus)
RF0->(DbSetOrder(1))
RF0->(DbSeek(xFilial("RF0")+cMat+dtos(dDtRF0),.t.))
If RF0->RF0_MAT = cMat .and. RF0->RF0_DTPREI = dDtRF0
	If "3" $ cStatus  //folga
		Reclock("RF0",.F.)
		RF0->(DbDelete())
		MsUnLock()
	Else
		If cOpcao = "S"
			Reclock("RF0",.F.)
			RF0->(DbDelete())
			MsUnLock()
		EndIf
	EndIf
Else
	If "1" $ cStatus  //periodo normal
		
		If cOpcao = "N"   //nao escalado
			cCodAbono := '041'
		ElseIf cOpcao = "A"  //atestado
			cCodAbono := '001'
		EndIf
		If cOpcao $ "NA"
			Reclock("RF0",.T.)
			RF0->RF0_FILIAL := xFilial("RF0")
			RF0->RF0_MAT    := cMat
			RF0->RF0_DTPREI := dDtRF0
			RF0->RF0_DTPREF := dDtRF0
			RF0->RF0_CODABO := cCodAbono	
			RF0->RF0_HORTAB := 'S'
			RF0->RF0_ABONA  := 'N'
			RF0->RF0_USUAR  := substr(cUsuario,7,15)
			RF0->RF0_FLAG	:= "M"
			MsUnLock()
		EndIf
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  Totaliza    ºAutor  ³³RSAC SOLUCOES     º Data ³  16/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Totaliza quantidade de chamadas                            º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Totaliza()
Local ni
Local nContPer := 0
nTotal := 0

For ni := 1 to len(aCols)
	If aCols[ni][nPosPer1] $ '12' .and. aCols[ni][nPosEsc] = 'S'
		nTotal ++
		nContPer ++
	EndIf
	If aCols[ni][nPosPer2] $ '12' .and. aCols[ni][nPosEsc] = 'S'
		nTotal ++
		nContPer ++
	EndIf
	If aCols[ni][nPosPer3] $ '12' .and. aCols[ni][nPosEsc] = 'S'
		nTotal ++
		nContPer ++
	EndIf
	IF aCols[ni][nPosPer4] $ '12' .and. aCols[ni][nPosEsc] = 'S'
		nTotal ++
		nContPer ++		
	EndIf
	aCols[ni][nPosCont] := nContPer
Next
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  fCriaPerg   ºAutor  ³Microsiga           º Data ³  02/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria perguntas (SX1)                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCriaPerg(cPerg)

//PutSx1(	cPerg,"01","Filtra Período abaixo ?","Filtra Período abaixo ?","Filtra Período abaixo ?","mv_ch1",;
//"N",1,0,0,"C","", "", "","",;
//"mv_par01","Sim","Sim","Sim","",;
//"Nao","Nao","Nao",;
//"","","",;
//" "," "," ",;
//" "," "," ",;
//{ "","","","","" },;
//{ "","","","","" },;
//{ "","","","","" }, "")
//
////PutSx1(	cPerg,"03","Da Data       ?","Da Data       ?","Da Data       ?","mv_ch3",;
//"D",8,0,0,"G","", "", "","",;
//"mv_par03","","","","",;
//"","","",;
//" "," "," ",;
//" "," "," ",;
//" "," "," ",;
//{ "","","","","" },;
//{ "","","","","" },;
//{ "","","","","" }, "")
//
////PutSx1(	cPerg,"04","Ate a Data    ?","Ate a Data    ?","Ate a Data    ?","mv_ch4",;
//"D",8,0,0,"G","", "", "","",;
//"mv_par04","","","","",;
//"","","",;
//" "," "," ",;
//" "," "," ",;
//" "," "," ",;
//{ "","","","","" },;
//{ "","","","","" },;
//{ "","","","","" }, "")

Return


Static Function AtuMV_Par()
pergunte(cPerg,.t.)

If mv_par01 = 1
	dDtIni := mv_par02
	dDtFim := mv_par03
Else
	dDtIni := stod(Substr(cPONMES,1,8))
	dDtFim := stod(Substr(cPONMES,10,8))
EndIf

Return()