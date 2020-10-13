#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! PCP - PRODUÇÃO                                          !
+------------------+---------------------------------------------------------+
!Nome              ! APCP103                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina Emissão Etiqueta                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 20/05/18                                                !
+------------------+---------------------------------------------------------+
*/
User Function APCP103()
Local oFont := TFont():New("Arial",0,-16,,.T.,,,,,.F.,.F.)
Local oOk  := LoadBitMap(GetResources(), "LBOK")
Local oNo  := LoadBitMap(GetResources(), "LBNO")
//
PRIVATE _cROP:=SPACE(TamSX3("D3_OP")[1])
Private _nRQtde:=0 //SPACE(TamSX3("C2_QUANT")[1])
Private _cRProd:=SPACE(TamSX3("B1_COD")[1])
Private _cRDesc:=SPACE(TamSX3("B1_DESC")[1])
Private _cRLOTE:=SPACE(TamSX3("C2_XLOTE")[1])
Private _cRImp:=SPACE(TamSX3("CB5_CODIGO")[1])
//===== VARIAVEIS PARA A GETDADOS DAS ETIQUETAS =====//
Private cLinOk    := ""
Private cTudoOk   := "AllwaysTrue"
Private cFieldOk  := ""
Private cSuperDel := ""
Private cDelOk    := "AllwaysFalse"
//
//===== VARIAVEIS PARA A GETDADOS DAS ETIQUETAS =====//
Private aHeader := {}
Private aCols   := {}
Private nUsado  := 0
Private cDoc    :=""
// Validacoes na GetDados da Modelo 2
Private cLinhaOk   := "AllwaysTrue()"
Private aEtq    := {}
//

DEFINE MSDIALOG oDlgEtq TITLE "APCP103 - Imprime Etiquetas " From 001,001 to 530,710 Pixel STYLE DS_MODALFRAME
//============================ DADOS Documento =============================//

oGrpdoc := tGroup():New(005,005,075,350,, oDlgEtq,CLR_HBLUE,,.T.)
oSayOP  := tSay():New(015,030,{|| "Ordem de Producao: "   },oGRPDOC,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,15)
oGetOP  := tGet():New(015,125,{|u| if(PCount()>0,_cROP:=u,_cROP)}, oGRPDOC,60,9,PesqPict("SD3","D3_OP"),{ || IF(!EMPTY(_cROP),vOPPRO(_cROP,_cRPROD,_cRLote),vProduto()) },,,,,,.T.,,, {|| .T. } ,,,,.F.,,"SC2",'_cROP')

oSayPROD  := tSay():New(030,030,{|| "Produto: "   },oGRPDOC,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,15)
oGetPROD  := tGet():New(030,125,{|u| if(PCount()>0,_cRPROD:=u,_cRPROD)}, oGRPDOC,60,9,PesqPict("SB1","B1_COD"),{ || IF(!EMPTY(_cRProd),_cRDesc:=posicione("SB1",1,XFILIAL("SB1")+_cRProd,"B1_DESC"),_cRDesc:="")},,,,,,.T.,,, {|| .T. } ,,,,.F.,,"SB1",'_cRPROD')
oGetDESC  := tGet():New(030,200,{|u| if(PCount()>0,_cRDESC:=u,_cRDESC)}, oGRPDOC,100,9,PesqPict("SB1","B1_DESC"),,,,,,,.T.,,, {|| .F. } ,,,,.F.,,,'_cRDESC')

oSayLote  := tSay():New(045,030,{|| "Lote: "   },oGRPDOC,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,15)
oGetLote  := tGet():New(045,125,{|u| if(PCount()>0,_cRLOTE:=u,_cRLOTE)}, oGRPDOC,60,9,PesqPict("SC2","C2_XLOTE"),{ || IIF(!EMPTY(_cROP).or.(!empty(_cRprod) .and. !empty(_cRLote)),vOPPRO(_cROP,_cRPROD,_cRLote),.T.) },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,'_cRLOTE')

oSayQTD := tSay():New(060,030,{|| "Qtde Etiqueta: "   },oGRPDOC,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,100,15)
oGetQTD := tGet():New(060,125,{|u| if(PCount()>0,_nRQtde:=u,_nRQtde)}, oGRPDOC,60,9,'@R 99999',{ || iif(!empty(_cRProd),vQtdImp(_nRQtde),.T.) },,,,,,.T.,,, {|| .T. } ,,,,.F.,,,'_nRQtde')
//
oGrpEtq  := tGroup():New(080,005,234,350,"Tipos Etiquetas", oDlgEtq,CLR_HBLUE,,.T.)
oBrwEtq:= TCBrowse():New(095,010,335,130,,,,oGrpEtq,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
//
oBrwEtq:AddColumn(TCColumn():New(" "             , {|| If(aEtq[oBrwEtq:nAt,01],oOk,oNo) },,,,,,.T.,.F.,,,,.F., ) )
oBrwEtq:AddColumn(TCColumn():New("Tipo"          , {|| aEtq[oBrwEtq:nAt,02]},,,,, 20 ,.F.,.F.,,,,.F., ) )
oBrwEtq:AddColumn(TCColumn():New("Descrição"     , {|| aEtq[oBrwEtq:nAt,03]},,,,, 100 ,.F.,.T.,,,,.F., ) )
oBrwEtq:AddColumn(TCColumn():New("Qtde Cadastro" , {|| aEtq[oBrwEtq:nAt,04]},"@E 99999",,,"RIGHT", 50 ,.F.,.T.,,,,.F., ) )
oBrwEtq:AddColumn(TCColumn():New("Qtde Imprimir" , {|| aEtq[oBrwEtq:nAt,05]},"@E 99999",,,"RIGHT", 50 ,.F.,.T.,,,,.F., ) )
oBrwEtq:AddColumn(TCColumn():New("Impressora  "  , {|| aEtq[oBrwEtq:nAt,06]},,,,, 50 ,.F.,.T.,,,,.F., ) )
oBrwEtq:AddColumn(TCColumn():New("Imp.Apontamento "  , {|| aEtq[oBrwEtq:nAt,07]},,,,, 50 ,.F.,.T.,,,,.F., ) )
oBrwEtq:SetArray(aEtq)
oBrwEtq:bLDblClick := { || iif(len(aETQ)>0,fQtdImp(_nRQtde),"") }

oBtnImp := tButton():New(245,240,'Imprimir'  ,oDlgEtq, {|| Processa( { || iif(len(aETQ)>0,fImpEtq(_CROP,_CRPROD,_CRLOTE),"") },"[APCP103] - AGUARDE...") },40,12,,,,.T.)
oBtnSair := tButton():New(245,290,'Sair'     ,oDlgEtq, {|| oDlgETQ:End() },40,12,,,,.T.)

oBtnImp:Disable()
oBrwEtq:Disable()

ACTIVATE MSDIALOG oDlgETQ CENTERED

Return(nil)

*-----------------------------------------------*
Static Function fImpEtq(_cop,_cProd,_clote)
*-----------------------------------------------*
Local _i:=1
Local _cFuncao:="U_ETQ"
Local _nQtde:=0
Local _cImp:=""
DEFAULT _cOp:=""
DEFAULT _cProd:=""
DEFAULT _cLote:=""

SB1->(dbSetOrder(1))
For _i:=1 To Len(aEtq)
	IncProc("Gerando Etiquetas...")
	If !aEtq[_i,1]
		Loop
	EndIf
	_cfuncao:="U_ETQ"+aEtq[_i][2]
	_nQtde:=aEtq[_i][5]
	_cImp :=aEtq[_i][6]
	_aetqauto:={}
	//MSGINFO(aetq[_i][2] + " " + str(aEtq[_i][5]))
	//
	aadd(_aEtqAuto,{_cOp,_cProd,_cLote,_nQtde,_cImp,.T.,.F.})
	//
	SB1->(MsSeek(xFilial("SB1")+_cProd))
	&_cfuncao.(_aEtqAuto[1])  
Next  

//
oDlgETQ:End()
//                             
Return

//===================== LEITURA PRODUTO ============================//
Static Function vOpPro(_cOP,_CPROD,_CLOTE)
_cAliasSB1 := GetNextAlias()
_nItem:=0
aeTQ:={}

DEFAULT _COP:=""
DEFAULT _CPROD:=""
DEFAULT _CLOTE=""

IF EMPTY(_COP) .AND. (EMPTY(_CPROD) .OR. EMPTY(_CLOTE))
	RETURN(.F.)
ENDIF
//
cQuery := "SELECT * FROM " + RETSQLNAME("SB1") + " SB1, "
cQuery += RETSQLNAME("ZIB") + " ZIB, "
cQuery += RETSQLNAME("ZIA") + " ZIA, "
cQuery += RETSQLNAME("SC2") + " SC2 "
cQuery += "WHERE SB1.D_E_L_E_T_ = ' ' "
cQuery += "AND ZIB.D_E_L_E_T_ = ' ' "
cQuery += "AND ZIA.D_E_L_E_T_ = ' ' "
cQuery += "AND SC2.D_E_L_E_T_ = ' ' "
cQuery += "AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += "AND ZIA.ZIA_FILIAL = '" + xFilial("ZIA") + "' "
cQuery += "AND ZIB.ZIB_FILIAL = '" + xFilial("ZIB") + "' "
cQuery += "AND SC2.C2_FILIAL = '" + xFilial("SC2") + "' "
If !empty(_cop)
	cQuery += "AND SC2.C2_NUM = '" + substr(_cOP,1,TamSX3("C2_NUM")[1])    + "' "
	cQuery += "AND sc2.C2_ITEM= '" + substr(_cOP,TamSX3("C2_NUM")[1]+1,TamSX3("C2_ITEM")[1])    + "' "
	cQuery += "AND SC2.C2_SEQUEN = '" + substr(_cOP,TamSX3("C2_NUM")[1]+TamSX3("C2_ITEM")[1]+1,TamSX3("C2_SEQUEN")[1])+ "' "
Else
	cQuery += "AND SC2.C2_PRODUTO = '" + _cPROD + "' "
	cQuery += "AND SC2.C2_XLOTE = '" + _cLOTE + "' "
Endif
cQuery += "AND ZIB.ZIB_PRODUT = SB1.B1_COD "
cQuery += "AND ZIB.ZIB_TPETQ = ZIA.ZIA_TPETQ "
cQuery += "AND SB1.B1_COD = SC2.C2_PRODUTO "
cQuery += "AND ZIB.ZIB_TPETQ = ZIA.ZIA_TPETQ "
cQuery += "ORDER BY ZIB.ZIB_TPETQ "

If (Select(_cAliasSB1) <> 0)
	dbSelectArea(_cAliasSB1)
	dbCloseArea()
EndIf
cQuery := ChangeQuery(cQuery)

TCQUERY cQuery NEW ALIAS &(_cAliasSB1)

dbSelectArea(_cAliasSB1)
dbGoTop()
//
If (_cAliasSB1)->(Eof())

	_nRQtde:=0 //SPACE(TamSX3("C2_QUANT")[1])
	_cRProd:=SPACE(TamSX3("B1_COD")[1])
	_cRDesc:=SPACE(TamSX3("B1_DESC")[1])
	_cRLOTE:=SPACE(TamSX3("C2_XLOTE")[1])
	_cRImp:=SPACE(TamSX3("CB5_CODIGO")[1])
	
	oGetProd:bWhen   := { || .T. }
	oGetLOTE:bWhen   := { || .T. }

	MsgInfo("Parametros Invalidos..Verifique!!")

Else
	_cRLOTE:=(_cAliasSB1)->C2_XLOTE
	_cRPROD:=(_cAliasSB1)->C2_PRODUTO
	_cRDESC:=(_cAliasSB1)->B1_DESC
	_nRQtde:=(_cAliasSB1)->C2_QUANT //0 //SPACE(TamSX3("C2_QUANT")[1])
	//
	WHILE !(_cAliasSB1)->(Eof())
		_nitem+=1
		aadd(aEtq,{iif((_cAliasSB1)->ZIB_APONTA=="S",.T.,.F.),(_cAliasSB1)->ZIB_TPETQ,(_cAliasSB1)->ZIA_DESC,(_cAliasSB1)->ZIB_QTDE,(_cAliasSB1)->ZIB_QTDE*_nRQTde,(_cAliasSB1)->ZIA_IMPPAD,IIF((_cAliasSB1)->ZIB_APONTA=="S","Sim","Nao"),STRZERO(_nItem)})
		(_cAliasSB1)->(DBSKIP())
	END

	IF !EMPTY(_cROp)
		oGetProd:bWhen   := { || .F. }
		oGetLOTE:bWhen   := { || .F. }
	EndIf
	
EndIf
//
oGetPROD:CtrlRefresh()
oGetDESC:CtrlRefresh()
oGetOP:CtrlRefresh()
oGetLote:CtrlRefresh()
//oGetQTD:CtrlRefresh()
//
oBrwEtq:SetArray(aEtq)
oBrwEtq:Refresh()
oDlgEtq:Refresh()
//
If(len(aETQ)==0)
	oBtnImp:Disable()
	oBrwEtq:Disable()
	oGetOP:SetFocus()
Else
	oBtnImp:Enable()
	oBrwEtq:Enable()
//	oGetQTD:SetFocus()
Endif

Return(.T.)

//===================== QUANTIDADE ETIQUETA /iMPRESSORA  =====================//
Static Function fQtdimp(_nqtde)
Local oFontCli  := TFont():New("Arial",0,14,,.T.,,,,,.F.,.F.)
Local i       := 0
Local nCount  := 0
Local nOpca   := 0
Local nqtdImp := aEtq[oBrwEtq:nAt,05]
Local cImp := aEtq[oBrwEtq:nAt,06]

Default _nQtde:=0

aEtq[oBrwEtq:nAt,01]:=!aEtq[oBrwEtq:nAt,01]
oBrwEtq:Refresh()
IF !aEtq[oBrwEtq:nAt,01]
	return
Endif

DEFINE MSDIALOG oDlgQTD TITLE "[APCP103] - Digite a Quantidade a Imprimir" From 001,001 to 200,500 Pixel STYLE DS_MODALFRAME

oGroup := tGroup():New(005,005,080,247,,oDlgQTD,CLR_HBLUE,,.T.)

oSayTETQ  := tSay():New(010,010,{|| aEtq[oBrwEtq:nAt,03] },oGroup,,oFontCli,,,,.T.,CLR_HBLUE,CLR_WHITE,230,24)

oSayQTD := tSay():New(030,010,{|| "Qtd.Imprimir:" },oGroup,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,12)
oGetQTD := tGet():New(028,060,{|u| if(PCount()>0,nqtdimp:=u,nqtdimp)}, oGroup,50,9,'@E 99999', { ||  },,,,,,.T.,,, { || .T. } ,,,,.f.,,,'nQtdImp')

oSayQTD := tSay():New(050,010,{|| "Impressora:" },oGroup,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,12)
oGetQTD := tGet():New(048,060,{|u| if(PCount()>0,cImp:=u,cImp)}, oGroup,50,9,, { ||  },,,,,,.T.,,, { || .T. } ,,,,.f.,,"CB5",'cImp')

oBtnOk  := tButton():New(085,090, "Ok" ,oDlgQtd, { || nOpca:=1, oDlgQtd:End() },40,12,,,,.T.,,,, { || .T. },,)
oBtnCan := tButton():New(085,135, "Cancelar" ,oDlgQtd, { || oDlgQtd:End() },40,12,,,,.T.,,,, { || .T. },,)

ACTIVATE MSDIALOG oDlgQTD CENTERED

If nOpca == 1
	aEtq[oBrwEtq:nAt,5] := nqtdimp
	aEtq[oBrwEtq:nAt,6] := cimp
	oBrwEtq:Refresh()
EndIf

Return

//============================ Atualiza Quantidade Etiqueta ============================//
Static Function vQtdImp(nqtde)
Local i
Default nQtde:=0

For i:=1 to Len(aEtq)
	If nQtde>0
		aEtq[i,05]:= aEtq[i,04] * nqtde
	endif
Next i

oBrwEtq:Refresh()

Return
//============================ Atualiza Quantidade Etiqueta ============================//
Static Function vProduto()
_nRQtde:=0 
_cRProd:=SPACE(TamSX3("B1_COD")[1])
_cRDesc:=SPACE(TamSX3("B1_DESC")[1])
_cRLOTE:=SPACE(TamSX3("C2_XLOTE")[1])
_cRImp:=SPACE(TamSX3("CB5_CODIGO")[1])
_nItem:=0

aeTQ:={}
	
oGetProd:bWhen   := { || .T. }
oGetLOTE:bWhen   := { || .T. }
//
oGetPROD:CtrlRefresh()
oGetDESC:CtrlRefresh()
oGetOP:CtrlRefresh()
oGetLote:CtrlRefresh()
//oGetQTD:CtrlRefresh()
//
oBrwEtq:SetArray(aEtq)
oBrwEtq:Refresh()
oDlgEtq:Refresh()
//
oBtnImp:Disable()
oBrwEtq:Disable()

oGetProd:SetFocus()

Return(.T.)
