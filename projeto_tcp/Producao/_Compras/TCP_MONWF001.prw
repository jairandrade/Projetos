#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
/*---------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina                                       			 !
+------------------+---------------------------------------------------------+
!Módulo            !                                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Monitor de Pedidos de Compra.  
!				   !	 !
/*-----------------+---------------------------------------------------------+
!Nome              ! MONWF001                                                 !			                                          !
+------------------+---------------------------------------------------------+
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo G. Vieira                                       !
+------------------+--------------------------------------------------------*/


user function MONWF00X

PREPARE ENVIRONMENT EMPRESA '02' FILIAL '01' TABLES "SC7" MODULO "SIGACOM"

	u_MONWF001()
	
RESET ENVIRONMENT
RETURN   

user function MONWF001   

local oDlg    
local oPnlFiltro
local oPnlBotoes
local aSize      := MsAdvSize() 
local aDados     := {} 
local oSelect    
local oGetFilI
local oGetFilF
local oGetDatI
local oGetDatF        
local oGetDCo
local oGetDes
local oGetStat
local oGetStaB
local bAtualiza := {|| atuDados(oSelect,@aDados) }
local bImprime  := {|| imprimePed(oSelect,@aDados) }          
local bReprovar := {|| atuStatus(oSelect,@aDados,'2') }        
local bGed 		:= {|| abreGed(oSelect,@aDados) }  
local bLegenda 	:= {|| legenda() } 
LOCAL bSair	    := {|| oDlg:End() } 
Local bAprovar  := {|| atuStatus(oSelect,@aDados,'1') } 
Local bVisualiza:= {|| visualiza(oSelect,@aDados) } 
Local bNota   	:= {|| preNota(oSelect,@aDados) } 
Local bReenvWf	:= {|| reenvWf(oSelect,@aDados) } 
Local bVisAprov	:= {|| visAprov(oSelect,@aDados) } 
local oOk	    := LoadBitMap(getResources(), "lBok")
local oNo	    := LoadBitMap(getResources(), "lBno")    
LOCAL aOpcEnt   := {}
LOCAL aOpcBloq  := {}
Local aOpcTipo  := {}
private cStat   := ' ' 
private cEntida   := ' ' 
private cCc       := SPACE(9) 
private cNumPed   := SPACE(6)
private cNumFor   := SPACE(6)
private cStatBl   := '1' 
private cStatusPd := ''
private cImpr := ''
private nValor    := 0000000000
private cNumNf    := SPACE(9)
private cNumNf2    := SPACE(9)
private _cNumSc    := SPACE(6)
private _cCodUsu  := RetCodUsr()
private cDataIni  := DDATABASE
private cDataFim  := DDATABASE   
Private oGetNf2
private oNfLnc   := LoadBitmap(GetResources(), "BR_AMARELO")
private oPendEnv  := LoadBitmap(GetResources(), "BR_BRANCO")
private oReprov   := LoadBitmap(GetResources(), "BR_VERMELHO")
private oSucesso  := LoadBitmap(GetResources(), "BR_VERDE")
private oAprov    := LoadBitmap(GetResources(), "BR_AZUL")     
private oErrProc  := LoadBitmap(GetResources(), "BR_CANCEL")                
private oReenv    := LoadBitmap(GetResources(), "BR_LARANJA")                  
private oSolic    := LoadBitmap(GetResources(), "BR_LARANJA")        
private oCotac    := LoadBitmap(GetResources(), "BR_AZUL_CLARO")  
   
aOpcStat := StrTokArr("  ;"+AllTrim(getSx3Cache("ZZE_STATUS","X3_CBOX")),";")   
aOpcTipo := StrTokArr("  ;"+AllTrim(getSx3Cache("ZZE_TIPO","X3_CBOX")),";")   

cOpcAx  := "0=Solicitação;1=Cotação;2=Em Aprovação;1=Aprovado;2=Nota Lançada;3=Pago"  
aOpcEnt := StrTokArr("  ;"+AllTrim(cOpcAx),";")  

cOpcAx  := "1=Sim;2=Não"  
aOpcImp := StrTokArr("  ;"+AllTrim(cOpcAx),";")  
DEFINE MSDIALOG oDlg TITLE 'Pedidos de Compra' FROM aSize[7],aSize[1] To aSize[6],aSize[5] PIXEL      

oPnlFiltro := TPanel():New(,,,oDlg,,,,,,,48,,.F.,.F. )
oPnlFiltro:Align := CONTROL_ALIGN_TOP

oPnlBotoes := TPanel():New(,,,oDlg,,,,,,,16,,.F.,.F. )
oPnlBotoes:Align := CONTROL_ALIGN_BOTTOM

oSelect := tcBrowse():New(,,,,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.)
oSelect:Align := CONTROL_ALIGN_ALLCLIENT

@ 002, 008 SAY 'Centro Custo'    SIZE 053, 007 OF oPnlFiltro PIXEL
@ 002, 80 SAY 'Emissao de?' SIZE 053, 007 OF oPnlFiltro PIXEL	
@ 002, 160 SAY 'Emissao até?'    SIZE 053, 007 OF oPnlFiltro PIXEL
@ 002, 230 SAY 'Pedido'    SIZE 053, 007 OF oPnlFiltro PIXEL
@ 002, 290 SAY 'Status'    SIZE 053, 007 OF oPnlFiltro PIXEL
@ 002, 380 SAY 'Fornecedor'    SIZE 053, 007 OF oPnlFiltro PIXEL
@ 002, 450 SAY 'Valor'    SIZE 053, 007 OF oPnlFiltro PIXEL
@ 002, 550 SAY 'Nota'    SIZE 053, 007 OF oPnlFiltro PIXEL
@ 025, 008 SAY 'Usuário'    SIZE 053, 007 OF oPnlFiltro PIXEL
@ 025, 080 SAY 'Sol. Compras'    SIZE 053, 007 OF oPnlFiltro PIXEL
@ 025, 160 SAY 'Impresso?'    SIZE 053, 007 OF oPnlFiltro PIXEL
//350F3 cF3

@ 010, 008  MSGET oGetxCc VAR cCc F3 'CTT'  SIZE 060,010  OF oPnlFiltro  PIXEL HASBUTTON
@ 010, 80 MSGET oGetDatI VAR cDataIni SIZE 060, 010 OF oPnlFiltro PIXEL HASBUTTON
@ 010, 160 MSGET oGetDatF VAR cDataFim SIZE 060, 010 OF oPnlFiltro PIXEL HASBUTTON    
@ 010, 230 MSGET oGetPed VAR cNumPed F3 'SC7' SIZE 060, 010 OF oPnlFiltro PIXEL HASBUTTON
@ 010, 290  MSCOMBOBOX oGetStaB VAR cStatusPd ITEMS aOpcEnt SIZE 080,010  OF oPnlFiltro PIXEL 
@ 010, 380  MSGET oGetFor VAR cNumFor F3 'FOR' SIZE 060,010  OF oPnlFiltro PIXEL HASBUTTON
@ 010, 450  MSGET oGetVal VAR nValor SIZE 080,010 PICTURE "@R 999999999999.99"  OF oPnlFiltro PIXEL HASBUTTON
@ 010, 550  MSGET oGetNf VAR cNumNf SIZE 080,010  OF oPnlFiltro PIXEL 
@ 032, 008  MSGET oGetUsu VAR _cCodUsu F3 'US1' SIZE 060,010  OF oPnlFiltro PIXEL HASBUTTON 
@ 032, 080  MSGET oGetSol VAR _cNumSc F3 'SC1' SIZE 060,010  OF oPnlFiltro PIXEL HASBUTTON
@ 032, 160  MSCOMBOBOX oGetImp VAR cImpr ITEMS aOpcImp SIZE 060,010  OF oPnlFiltro PIXEL 

//Campo q exibe o número da nota, para o usuário poder dar Ctrl+c
@ 002, 600 SAY 'NF:'    SIZE 053, 007 OF oPnlBotoes PIXEL
@ 002, 620  MSGET oGetNf2 VAR cNumNf2 SIZE 060,010  OF oPnlBotoes PIXEL 

oBtnAtuali   := TButton():New(030,0230,'Atualizar',oPnlFiltro,bAtualiza,50,12,,,,.T.)
bImprime     := TButton():New(002,010,'Imprimir',oPnlBotoes,bImprime,50,12,,,,.T.)
bVisualiza   := TButton():New(002,080,'Visualizar Pedido',oPnlBotoes,bVisualiza,50,12,,,,.T.)
bNota        := TButton():New(002,150,'Pré Nota',oPnlBotoes,bNota,50,12,,,,.T.)
bReenvWf     := TButton():New(002,220,'Reiniciar Aprovação',oPnlBotoes,bReenvWf,50,12,,,,.T.)
bGed     	 := TButton():New(002,290,'GED Tcp',oPnlBotoes,bGed,50,12,,,,.T.)
bGed     	 := TButton():New(002,360,'Vis. Aprovações',oPnlBotoes,bVisAprov,50,12,,,,.T.)

/*
bEnviaWf    := TButton():New(002,070,'Enviar E-mail',oPnlBotoes,bEnviaWf,50,12,,,,.T.)
bAprovar 	:= TButton():New(002,130,'Aprovar',oPnlBotoes,bAprovar,50,12,,,,.T.)  
bReprovar   := TButton():New(002,190,'Reprovar',oPnlBotoes,bReprovar,50,12,,,,.T.)
bVisualiz   := TButton():New(002,250,'Visualizar',oPnlBotoes,bVisualiz,50,12,,,,.T.)
*/
bLegenda    := TButton():New(002,430,'Legenda',oPnlBotoes,bLegenda,50,12,,,,.T.)
bSair       := TButton():New(002,500,'Sair',oPnlBotoes,bSair,50,12,,,,.T.)
//P=Pendente;E=Envia p/ Integração;S=Sucesso;R=Erro ao integrar;X=Processando Integracao;O=Erro de Processamento;V=Reenviado      
oSelect:AddColumn(tcColumn():new(""		    , {|| if(aDados[oSelect:nAt, 10], oOk, oNo)}, {|| marcaReg(@aDados,oSelect)},,,,, .T., .F.,,,, .F.))
oSelect:AddColumn(tcColumn():new("Status", {|| IF(LEN(aDados) > 0,retLegenda(aDados[oSelect:nAt, 01]),oPendEnv)}, ,,,,10, .T., .F.,,,, .F.))
oSelect:AddColumn(tcColumn():new("Tipo"		, {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 11],'')}, PESQPICT("SA2", "A2_NOME") ,,, "LEFT" , TamSX3("C1_NUM")[1]+3						, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Solicitação"		, {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 13],'')}, PESQPICT("SC1", "C1_NUM") ,,, "LEFT" , TamSX3("C1_NUM")[1]+3							, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Pedido"		, {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 02],'')}, PESQPICT("SC7", "C7_NUM") ,,, "LEFT" ,TamSX3("C7_NUM")[1]+3							, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Emissão"		, {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 16],'')}, PESQPICT("SC7", "C7_EMISSAO") ,,, "LEFT" ,TamSX3("C7_EMISSAO")[1]							, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Nota"	    , {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 03],'')}, PESQPICT("SF1", "F1_DOC"),,, "LEFT" , TamSX3("F1_DOC")[1]+3					, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Fornecedor"	, {|| IF(LEN(aDados) > 0 ,aDados[oSelect:nAt, 04],'')}, PESQPICT("SA2", "A2_COD") ,,, "LEFT" , TamSX3("A2_COD")[1]+3					, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Razão Social", {|| IF(LEN(aDados) > 0 ,aDados[oSelect:nAt, 05],'')}, PESQPICT("SA2", "A2_NREDUZ") ,,, "LEFT" , 70						, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Valor"		, {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 06],'')}, PESQPICT("SF1", "F1_VALBRUT") ,,, "LEFT" , 30						, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Vencimento"		, {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 07],'')}, PESQPICT("SE2", "E2_VENCREA") ,,, "LEFT" , 10						, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Impresso?"		, {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 08],'')}, PESQPICT("SC7", "C7_NUM") ,,, "LEFT" , 12						, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Aprovador"		, {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 09],'')}, PESQPICT("SC7", "C7_NUM") ,,, "LEFT" , 12						, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Motivo Rej."		, {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 15],'')}, PESQPICT("SC7", "C7_MOTREJ") ,,, "LEFT" , 12						, .F., .F.,,,,.F.))

oSelect:setArray(aDados)               
oSelect:bWhen := {|| Len(aDados) > 0}
oSelect:bLDblClick := { || marcaReg(@aDados,oSelect) }
atuDados(oSelect, @aDados)
ACTIVATE DIALOG oDlg CENTERED                                                      

return   

//*************************************************************************************//

static function marcaReg(aADados,oATB)

aADados[oATB:nAt, 10] := !aADados[oATB:nAt, 10]
cNumNf2 := aADados[oATB:nAt, 03]
oGetNf2:CtrlRefresh()
oATB:Refresh()

return//*************************************************************************************//
    
static function atuDados(oATB, aADados) 

Processa( {|| ATUDADOS1(oATB, aADados) }, "Aguarde...", "Atualizando...",.F.)    

return

static function ATUDADOS1(oATB, aADados) 

IF(DateDiffDay( cDataIni, cDataFim) > 31 .AND. EMPTY(_cNumSc) .AND. EMPTY(_cCodUsu) .AND. EMPTY(cCc) .AND. EMPTY(cNumNf) .AND. EMPTY(cNumFor) .AND. nValor  == 0 .AND. (EMPTY(cStatusPd) .OR. cStatusPd $ '0|1|') .and. EMPTY(cImpr) .and. EMPTY(cNumPed) )
	ALert('Para filtrar período maior que 1 mês, preencha ao menos mais um parâmetro além da data.')
	RETURN
ENDIF

aADados := {}  

//consultaMedicoes(@aADados)
if (EMPTY(cStatusPd) .OR. cStatusPd $ '|2|3|4|5|6')
	consultaPedidos(@aADados)
endif

IF EMPTY(cNumNf) .AND. EMPTY(cNumFor) .AND. nValor  == 0 .AND. (EMPTY(cStatusPd) .OR. cStatusPd $ '0|1|') .and. EMPTY(cImpr) .and. EMPTY(cNumPed)
	consultaSolicitacoes(@aADados)
ENDIF

oATB:setArray(aADados)
oATB:Refresh()

return

static function consultaSolicitacoes(aADados) 

local cWhere := "%"
LOCAL cAlias 
 
if !Empty(cCc)
	cWhere += " AND C1_CC = '" + cCc + "' "
endif   

if !Empty(cDataIni)
	cWhere += " AND C1_EMISSAO >= '" + DTOS(cDataIni) + "' "
endif

if !Empty(cDataFim)
	cWhere += " AND C1_EMISSAO <= '" + DTOS(cDataFim) + "' "
endif  

if !Empty(cStatusPd)
	if cStatusPd == '0'
		cWhere += " AND C8_NUM IS NULL "
	ELSEif cStatusPd == '1'
		cWhere += " AND C8_NUM IS NOT NULL "
	ENDIF
endif       

if !Empty(_cCodUsu )
	cWhere += " AND C1_USER = '" + _cCodUsu + "' "
endif

if !Empty(_cNumSc)
	cWhere += " AND C1_NUM = '" + _cNumSc + "' "
ENDIF

cWhere += "%"
                                                                                                                                                  	
BeginSql alias 'QRYTMP_'     
	Column C1_EMISSAO as date 
	SELECT C1_FILIAL,C1_NUM,C1_EMISSAO,C8_NUM,C8_ITEM
	
	FROM %Table:SC1% SC1
	LEFT JOIN %Table:SC8% SC8 ON C8_FILIAL = C1_FILIAL AND C8_NUMSC = C1_NUM AND C8_ITEMSC = C1_ITEM AND SC8.%NotDel%
	LEFT JOIN %Table:SC7% SC7 ON C7_FILIAL = C7_FILIAL AND C1_NUM = C7_NUMSC AND C1_ITEM = C8_ITEMSC AND SC7.%NotDel%
	WHERE SC1.%NotDel%  AND C7_NUM IS NULL
	%exp:cWhere%  
	GROUP BY C1_FILIAL,C1_NUM,C1_EMISSAO,C8_NUM,C8_ITEM
	ORDER BY C1_EMISSAO,C1_NUM DESC
	
EndSql   

while !QRYTMP_->(Eof())
	
	aAdd(aADados, {		;
	IF(EMPTY(QRYTMP_->C8_NUM),'0','1'),	;
	'',	;
	'', ;
	'', ;
	'', ;
	0, ;
	CTOD('  /  /    '), ;
	'Não', ;
	'', ;
	.F.,;
	'Purchaise Order',;
	QRYTMP_->C1_FILIAL,;
	QRYTMP_->C1_NUM,;
	QRYTMP_->C8_NUM,;
	'',;
	'';
	})
	
	QRYTMP_->(DBSkip())
enddo

QRYTMP_->(DBCloseArea())

return


static function consultaPedidos(aADados) 

local cWhere := "%"
local cHaving := "%"
LOCAL cAlias  
LOCAL cFilLog := cFilAnt
LOCAL cObs   
Local cDescEnt := ''
Local lContinua := .T.
if !Empty(cCc)
//	cWhere += " AND (C7_CC = '" + cCc + "' OR Z21_CCUSTO = '"+cCc+"' ) "
	cWhere += " AND (C7_CC= '" + cCc + "' OR (SELECT COUNT(*) FROM Z21020 Z21 WHERE Z21_FILIAL = CND_FILIAL AND Z21_CONTRA = CND_CONTRA AND Z21_NUMMED = CND_NUMMED AND CND_REVISA = Z21_REVISA AND Z21_CCUSTO = '"+cCc+"' AND Z21.D_E_L_E_T_= ' ')>1) ""
endif   

if !Empty(cDataIni)
	cWhere += " AND C7_EMISSAO >= '" + DTOS(cDataIni) + "' "
endif

if !Empty(cDataFim)
	cWhere += " AND C7_EMISSAO <= '" + DTOS(cDataFim) + "' "
endif       

if !Empty(cNumPed)
	cWhere += " AND C7_NUM = '" + ALLTRIM(cNumPed) + "' "
endif     

if !Empty(_cNumSc)
	cWhere += " AND C7_NUMSC   = '" + ALLTRIM(_cNumSc) + "' "
endif
  
if !Empty(cImpr)
	IF cImpr == '1'
		cWhere += " AND C7_EMITIDO   = 'S' "
	ELSE
		cWhere += " AND C7_EMITIDO   != 'S' "
	ENDIF
endif

if !Empty(cStatusPd)
	if cStatusPd == '2'
		cWhere += " AND C7_CONAPRO != 'L' "
	ELSEif cStatusPd == '3'
		cWhere += " AND C7_CONAPRO = 'L' "
	ELSEif cStatusPd == '4'
		cWhere += " AND D1_DOC IS NOT NULL "
	ELSEif cStatusPd == '5'
		cWhere += " AND E2_SALDO = 0 "
	ENDIF
endif    

if !Empty(cNumFor)
	cWhere += " AND C7_FORNECE = '" + ALLTRIM(cNumFor) + "' "
endif     
   
if !Empty(cNumNf)
	cWhere += " AND (D1_DOC = '" + ALLTRIM(cNumNf) + "' OR CND_XNOTA = '"+ALLTRIM(cNumNf)+"') "
endif     

if !Empty(_cCodUsu )
	cWhere += " AND (C7_USER = '" + _cCodUsu + "' OR C1_USER = '" + _cCodUsu + "') "
endif

if nValor > 0
	cHaving += " HAVING round(SUM(C7_TOTAL),2) = '" + ALLTRIM(STR(nValor)) + "' "
endif

cHaving += "%"
cWhere  += "%"

//LEFT JOIN %Table:Z21% Z21 ON Z21_FILIAL = CND_FILIAL AND Z21_CONTRA = CND_CONTRA AND Z21_NUMMED = CND_NUMMED AND CND_REVISA = Z21_REVISA AND Z21.%NotDel% 
	    
                                                                                                                                                  	
BeginSql alias 'QRYTMP_'     
	Column C7_EMISSAO as date 
	Column E2_VENCREA as date
	SELECT C7_FILIAL,C7_NUM,C7_EMISSAO,C7_FORNECE,C7_LOJA,A2_NREDUZ,D1_DOC,SUM(C7_TOTAL) AS TOTAL,E2_VENCREA,C7_CONAPRO,C7_EMITIDO,CND_XNOTA ,C7_CONAPRO,
	C7_CONTRA,C7_CONTRAT,E2_SALDO,E2_NUM, C8_NUMSC,C8_NUM
	
	FROM %Table:SC7% SC7
	INNER JOIN %Table:SA2% SA2 ON A2_COD=C7_FORNECE AND A2_LOJA=C7_LOJA
	LEFT JOIN %Table:SD1% SD1 ON D1_FILIAL  = C7_FILIAL AND D1_PEDIDO=C7_NUM AND D1_ITEMPC = C7_ITEM AND SD1.%NotDel% 
	LEFT JOIN %Table:SE2% SE2 ON D1_FILIAL  = E2_FILIAL AND E2_NUM = D1_DOC AND E2_PREFIXO = D1_SERIE AND E2_FORNECE = D1_FORNECE AND E2_LOJA = D1_LOJA AND SE2.%NotDel% 
	LEFT JOIN %Table:SC8% SC8 ON C8_FILIAL  = C7_FILIAL AND C8_NUMPED = C7_NUM AND C8_ITEMPED = C7_ITEM AND SC8.%NotDel% 
	LEFT JOIN %Table:SC1% SC1 ON C1_FILIAL  = C7_FILIAL AND C8_NUMSC = C1_NUM AND C8_ITEMSC = C1_ITEM AND SC1.%NotDel% 
	LEFT JOIN %Table:CND% CND ON CND_FILIAL = C7_FILIAL AND C7_CONTRA = CND_CONTRA AND C7_MEDICAO = CND_NUMMED AND CND_REVISA = C7_CONTREV AND CND.%NotDel% 
	WHERE SC7.%NotDel% AND SA2.%NotDel% AND 1=1
	%exp:cWhere%  
	GROUP BY C7_FILIAL,C7_NUM,C7_EMISSAO,C7_FORNECE,C7_LOJA,A2_NREDUZ,D1_DOC,E2_VENCREA,C7_CONAPRO,C7_EMITIDO,CND_XNOTA ,C7_CONAPRO ,C7_CONTRA,C7_CONTRAT,E2_SALDO,E2_NUM,
	C8_NUMSC,C8_NUM
	%exp:cHaving%
	ORDER BY C7_EMISSAO DESC,C7_NUM DESC
	
EndSql   

//Conout(getlastquery()[2])

dbSelectArea("SCR")
SCR->(dbSetorder(1))
	
while !QRYTMP_->(Eof())
	
	lContinua := .T.
	
	_cStatus := RETSTATUS(QRYTMP_->C7_CONAPRO,QRYTMP_->D1_DOC,QRYTMP_->E2_SALDO,QRYTMP_->E2_NUM)
	_cAprov  := retSitAprov(QRYTMP_->C7_FILIAL,QRYTMP_->C7_NUM,QRYTMP_->C7_CONAPRO)
	
	IF lContinua 
		aAdd(aADados, {		;
		_cStatus,	;
		QRYTMP_->C7_NUM,	;
		IF(!EMPTY(QRYTMP_->D1_DOC),QRYTMP_->D1_DOC,QRYTMP_->CND_XNOTA ), ;
		QRYTMP_->C7_FORNECE+'-'+QRYTMP_->C7_LOJA, ;
		QRYTMP_->A2_NREDUZ, ;
		QRYTMP_->TOTAL, ;
		QRYTMP_->E2_VENCREA, ;
		IF(QRYTMP_->C7_EMITIDO == 'S','Sim','Não'), ;
		_cAprov, ;
		.F.,;
		IF(!EMPTY(QRYTMP_->C7_CONTRA),'Contract',IF(!EMPTY(QRYTMP_->C7_CONTRA),'Under Contract','Purchaise Order')),;
		QRYTMP_->C7_FILIAL,;
		QRYTMP_->C8_NUMSC,;
		QRYTMP_->C8_NUM,;
		IF(QRYTMP_->C7_CONAPRO =='L','',POSICIONE('SC7',1,QRYTMP_->C7_FILIAL+QRYTMP_->C7_NUM,'C7_MOTREJ')),;
		QRYTMP_->C7_EMISSAO;
		})
		
	ENDIF
	QRYTMP_->(DBSkip())
enddo

QRYTMP_->(DBCloseArea())

cFilAnt := cFilLog

return

static function retSitAprov(_cFilial,_cNum,_cStatus)
Local _cAprov := ''
Local _cNomUsu := ''
Local _aRetUsu 
IF _cStatus == 'L'
	_cAprov := 'Liberado'
ELSE
	IF SCR->(dbSeek(_cFilial+"PC"+PADR(_cNum,TamSx3("CR_NUM")[1])))   
		//Percorre todas as alçadas do pedido
		While !SCR->(EOF()) .And. SCR->CR_FILIAL + SCR->CR_TIPO + SCR->CR_NUM ==  _cFilial + "PC" + PADR(_cNum,TamSx3("CR_NUM")[1])
			
			_cNomUsu := RetNomFunc(SCR->CR_USER)
			
			if SCR->CR_STATUS == '04'
				
				_cAprov := 'Bloqueado - '+_cNomUsu//UsrFullName(RetCodUsr())
			ELSEIF SCR->CR_STATUS == '02'
				_cAprov += IF(EMPTY(_cAprov),'Pendente Nvl '+SCR->CR_NIVEL+' - '+_cNomUsu,', '+_cNomUsu )
			ENDIF
			
			SCR->(dbSkip())
		EndDo    
	ENDIF
	
	IF EMPTY(_cAprov) .AND. _cStatus == 'B'
		_cAprov := 'Bloqueado'
	ENDIF
	
ENDIF

SCR->(DBCloseArea())

return _cAprov


STATIC FUNCTION RetNomFunc(cCodigo)
_cNomUsu := ''

IF(!EMPTY(cCodigo))
	_aRetUsu := FWSFALLUSERS({cCodigo})
	if(LEN(_aRetUsu) >= 1 .AND. LEN(_aRetUsu[1]) >= 4)
		_cNomUsu := ALLTRIM(_aRetUsu[1,4])
	ENDIF
endif

return _cNomUsu

static function atuStatus(oSelect, aDados,cStatus)
   
	atuDados(oSelect,@aDados)

Return       

static function libPed(oSelect, aDados)
   
	atuDados(oSelect,@aDados)

return 

static function retStatus(cConapro,cD1Doc,nE2Saldo,cE2Num)

Local _cStatus := '2'

IF !empty(cE2Num) .AND. nE2Saldo == 0
	_cStatus := '5'
ELSEIF !EMPTY(cD1Doc)
	_cStatus := '4'
ELSEIF cConapro == 'L'
	_cStatus := '3' 
ENDIF

return _cStatus

static function legenda()

BrwLegenda( "Pedidos de Compra"	,;						//Titulo do Cadastro
		    "Legenda"		    ,;						//"Legenda"
			{;
				{"BR_LARANJA"	,"Solic. Compra"	}	,;
				{"BR_AZUL_CLARO","Cotação"	}	,;
				{"BR_BRANCO"	,"Em Aprovação"	}	,;
				{"BR_AZUL"		,"Aprovado"	}	,;	
				{"BR_AMARELO"  	,"Nota Lançada"	}  ,	 ;
				{"BR_VERDE"	,"Pago"	}	;
			};
		 )
		   
		 
Return( .T. )         

static function visualiza(oSelect,aDados)
local nCount      := 0
local _cFilAtu    := cFilAnt 
Local cNumPed     := ''
Local lSemPed     := .F.
Local nInd

Private cCadastro := "Pedido de Compra"  
Private aRotina   := StaticCall( MATA121 , MenuDef )
PRIVATE INCLUI    :=.F.
PRIVATE ALTERA    :=.F.

for nInd := 1 to LEN(aDados) 

	IF(aDados[nInd, 10])
		cNumPed := aDados[nInd, 12]+aDados[nInd, 2]
		nCount++
		
		IF EMPTY(aDados[nInd, 2])
			lSemPed := .T.
		ENDIF
		
	ENDIF
next    

        
IF(nCount>1)
	Aviso("Aviso","Não é possível visualizar mais de um pedido. Selecione apenas o pedido que deseja visualizar.",{"Ok"})
	return 
ENDIF

IF lSemPed
	Aviso("Aviso","Esta solicitação ainda não possui pedido.",{"Ok"})
	return 
ENDIF

IF(nCount==0)
	Aviso("Aviso","Nenhum pedido selecionado.",{"Ok"})
	return 
ENDIF

IF( !empty(cNumPed) )
	dbSelectArea('SC7')
	dbSetOrder(1)
	SC7->(DBSeek(cNumPed)) 
	cFilAnt := SC7->C7_FILIAL   
	//Mata120(ExpN1,ExpA1,ExpA2,ExpN2,ExpA1)
    /*
    ExpN1 = 1-Pedido de compras ou 2-Autorizacao de entrega
    ExpA1 = Array Cabecalho para Rotina Automatica 
    ExpA2 = Array Itens para Rotina Automatica 
    ExpN2 = Opcao do aRotina para Rotina Automatica 
    ExpA1 = Apresenta a Dialog da Rotina em Rotina Automatica (.T. ou .F.)
    */
    Mata120(1,/*aCabec*/,/*aItens*/,2,.T.) 

ENDIF

cFilAnt := _cFilAtu 
	
return        


static function abreGed(oSelect,aDados)
local nCount      := 0
local _cFilAtu    := cFilAnt 
Local cNumPed     := ''
Local cNumSc      := ''
Local nInd
Private cCadastro := "Pedido de Compra"  
Private aRotina   := StaticCall( MATA121 , MenuDef )
PRIVATE INCLUI    :=.F.
PRIVATE ALTERA    :=.F.

for nInd := 1 to LEN(aDados) 

	IF(aDados[nInd, 10])
		cNumPed := aDados[nInd, 12]+aDados[nInd, 2]
		cNumSc  := aDados[nInd, 12]+aDados[nInd, 13]
		nCount++
	ENDIF
next     
       
IF(nCount>1)
	Aviso("Aviso","Não é possível reenviar Wf de mais de um pedido. Selecione apenas o pedido.",{"Ok"})
	return 
ENDIF

IF(nCount==0)
	Aviso("Aviso","Nenhum pedido selecionado.",{"Ok"})
	return 
ENDIF

IF( !empty(cNumPed) )
	dbSelectArea('SC7')
	dbSetOrder(1)
	SC7->(DBSeek(cNumPed)) 
//	IF( !empty(SC7->C7_CONTRA) )
//		dbSelectArea('CND')
//		dbSetOrder(1)
//		CND->(DBSeek(SC7->C7_FILIAL+SC7->C7_CONTRA+SC7->C7_MEDICAO+SC7->C7_CONTREV)) 
//		cFilAnt := SC7->C7_FILIAL   
//	    U_TCPGED('CND',CND->(RECNO()),2)
//	ELSE
		cFilAnt := SC7->C7_FILIAL   
	    U_TCPGED('SC7',SC7->(RECNO()),2)
//    ENDIF
elseIF( !empty(cNumSc) )
	dbSelectArea('SC1')
	dbSetOrder(1)
	SC1->(DBSeek(cNumSc)) 
	cFilAnt := SC1->C1_FILIAL   
    U_TCPGED('SC1',SC1->(RECNO()),2)
ENDIF

cFilAnt := _cFilAtu 
	
//atuDados(oSelect,@aDados)
		
return  

static function reenvWf(oSelect,aDados)
local nCount      := 0
local _cFilAtu    := cFilAnt 
Local cNumPed     := ''
Local nInd

for nInd := 1 to LEN(aDados) 

	IF(aDados[nInd, 10])
		cNumPed := aDados[nInd, 12]+aDados[nInd, 2]
		nCount++
	ENDIF
next            
//IF(nCount>1)
//	Aviso("Aviso","Não é possível reenviar Wf de mais de um pedido. Selecione apenas o pedido.",{"Ok"})
//	return 
//ENDIF

IF(nCount==0)
	Aviso("Aviso","Nenhum pedido selecionado.",{"Ok"})
	return 
ENDIF

IF( !empty(cNumPed) )
	dbSelectArea('SC7')
	dbSetOrder(1)
	SC7->(DBSeek(cNumPed)) 
	cFilAnt := SC7->C7_FILIAL   
	u_PcDelSCR(SC7->C7_FILIAL,SC7->C7_NUM)
	U_ctrSales(SC7->C7_FILIAL,SC7->C7_NUM,if(EMPTY(SC7->C7_XSALES),.T.,.F.),if(EMPTY(SC7->C7_XSALES),.F.,.T.),.F.)

ENDIF

cFilAnt := _cFilAtu 
	
atuDados(oSelect,@aDados)
		
return  

static function visAprov(oSelect,aDados)
local nCount      := 0
local _cFilAtu    := cFilAnt 
Local cNumPed     := ''
Local nInd
private aRotina   := {}

aRotina := {{ "Pesquisa","AxPesqui", 0 , 1},;
           { "Visual","AxVisual", 0 , 2}}


for nInd := 1 to LEN(aDados) 

	IF(aDados[nInd, 10])
		cNumPed := aDados[nInd, 12]+aDados[nInd, 2]
		nCount++
	ENDIF
next            
IF(nCount>1)
	Aviso("Aviso","Não é possível visualizar de mais de um pedido. Selecione apenas o pedido.",{"Ok"})
	return 
ENDIF

IF(nCount==0)
	Aviso("Aviso","Nenhum pedido selecionado.",{"Ok"})
	return 
ENDIF

IF( !empty(cNumPed) )
	dbSelectArea('SC7')
	dbSetOrder(1)
	SC7->(DBSeek(cNumPed)) 
	cFilAnt := SC7->C7_FILIAL   

	U_TCCOA01(SC7->C7_NUM,'PC',SC7->C7_USER,'')

ENDIF

cFilAnt := _cFilAtu 
	
return

static function preNota(oSelect,aDados)
local nCount := 0
local _cFilAtu := cFilAnt 
//Private cCadastro := "Pré Nota"  
//Private aRotina := StaticCall( MATA140 , MenuDef )

//A140NFiscal("SF1",0,3)
MATA140()
//cFilAnt := _cFilAtu 
		
atuDados(oSelect,@aDados)

return        


static function imprimePed(oSelect,aDados)
local nCount      := 0
local _cFilAtu    := cFilAnt 
Local cNumPed     := ''
Local nInd

for nInd := 1 to LEN(aDados) 
	
	IF(aDados[nInd, 10])
		dbSelectArea('SC7')
		dbSetOrder(1)
		SC7->(DBSeek(aDados[nInd, 12]+aDados[nInd, 2])) 
		cFilAnt := SC7->C7_FILIAL   
		
//		while SC7->(!Eof()) .AND. SC7->C7_FILIAL+SC7->C7_NUM == aDados[nInd, 12]+aDados[nInd, 2] 
//			
//			RecLock("SC7",.F.)
//			SC7->C7_XIMPRES := '1'
//			SC7->(msUnlock())
//			
//			SC7->(DbSkip())
//		enddo
		
		IF !EMPTY(cNumPed)
			cNumPed += ','
		ENDIF
		
		cNumPed +=  "'"+aDados[nInd, 12]+aDados[nInd, 2]+"'"
		
	ENDIF
NEXT

IF !empty(cNumPed) 

//	cNumPed := '('+ cNumPed + ')'
	
	//Conout(cNumPed)
	
	U_Matr110( 'SC7',, 2,cNumPed )
ENDIF

//SC7->(dbGoTop())
//SC7->(dbSetOrder(1))
//IF SC7->(DBSeek(aDados[nInd, 12]+aDados[nInd, 2])) 
//	U_Matr110( 'SC7', SC7->(RECNO()), 2 )
//ENDIF

cFilAnt := _cFilAtu 
		
atuDados(oSelect,@aDados)

return  	



static function retLegenda(_cStatus)
Local cButRet := oSolic

IF !empty(_cStatus) 
	IF _cStatus == '0'
		cButRet := oSolic
	elseif _cStatus == '1'
		cButRet := oCotac    
	elseif _cStatus == '2'
		cButRet := oPendEnv
	elseif _cStatus == '3'
		cButRet := oAprov
	elseif _cStatus == '4'
		cButRet := oNfLnc
	elseif _cStatus == '5'
		cButRet := oSucesso
	endif
endif

return cButRet