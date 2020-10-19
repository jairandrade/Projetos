#INCLUDE "PROTHEUS.CH"
/*---------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina                                       			 !
+------------------+---------------------------------------------------------+
!Módulo            !                                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Monitor de integração com ITAU.  
!				   !	 !
/*-----------------+---------------------------------------------------------+
!Nome              ! MNSIS01                                                 !			                                          !
+------------------+---------------------------------------------------------+
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo G. Vieira                                       !
+------------------+--------------------------------------------------------*/


user function BLTMONIT   

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
local bReenvia  := {|| reenvia(oSelect,@aDados) }          
local bCancela := {|| cancelaEnv(oSelect,@aDados) }  
local bLegenda 	:= {|| legenda() } 
LOCAL bSair	    := {|| oDlg:End() } 
Local bAprovar  := {|| atuStatus(oSelect,@aDados,'1') } 
Local bVisualiz := {|| visualiza(oSelect,@aDados) } 
Local bLibera   := {|| libPed(oSelect,@aDados) } 
local oOk	    := LoadBitMap(getResources(), "lBok")
local oNo	    := LoadBitMap(getResources(), "lBno")    
LOCAL aOpcEnt   := {}
LOCAL aOpcBloq  := {}
Local aOpcTipo  := {}
private cStat   := ' ' 
private cTpInt    := ' ' 
private cNumeroDe   := SPACE(9) 
private cNumeroAte := 'ZZZZZZZZZ' 
private cDataIni  := DDATABASE
private cDataFim  := DDATABASE   
private oPendent  := LoadBitmap(GetResources(), "BR_AMARELO")
private oReprov   := LoadBitmap(GetResources(), "BR_VERMELHO")
private oSucesso  := LoadBitmap(GetResources(), "BR_VERDE")
   
cOpcAx  := "1=Não Enviado;2=Erro;3=Sucesso"  
aOpcStat := StrTokArr("  ;"+AllTrim(cOpcAx),";")  
DEFINE MSDIALOG oDlg TITLE 'Integração Itau' FROM aSize[7],aSize[1] To aSize[6],aSize[5] PIXEL      

oPnlFiltro := TPanel():New(,,,oDlg,,,,,,,48,,.F.,.F. )
oPnlFiltro:Align := CONTROL_ALIGN_TOP

oPnlBotoes := TPanel():New(,,,oDlg,,,,,,,16,,.F.,.F. )
oPnlBotoes:Align := CONTROL_ALIGN_BOTTOM

oSelect := tcBrowse():New(,,,,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.)
oSelect:Align := CONTROL_ALIGN_ALLCLIENT

@ 002, 008 SAY 'Numero de?'    SIZE 053, 007 OF oPnlFiltro PIXEL
@ 002, 100 SAY 'Número até?' SIZE 053, 007 OF oPnlFiltro PIXEL	
@ 002, 170 SAY 'Data de?'    SIZE 053, 007 OF oPnlFiltro PIXEL
@ 002, 240 SAY 'Data Até?'    SIZE 053, 007 OF oPnlFiltro PIXEL
@ 002, 330 SAY 'Status?'    SIZE 053, 007 OF oPnlFiltro PIXEL
//350

@ 010, 008  MSGET oGetxNumd VAR cNumeroDe  SIZE 080,010  OF oPnlFiltro PIXEL 
@ 010, 100 MSGET oGetNumA VAR cNumeroAte SIZE 060, 010 OF oPnlFiltro PIXEL 
@ 010, 170 MSGET oGetDatI VAR cDataIni SIZE 060, 010 OF oPnlFiltro PIXEL HASBUTTON    
@ 010, 240  MSGET oGetDatF VAR cDataFim SIZE 060,010  OF oPnlFiltro PIXEL HASBUTTON
@ 010, 330  MSCOMBOBOX oGetStaB VAR cStat ITEMS aOpcStat SIZE 080,010  OF oPnlFiltro PIXEL            

oBtnAtuali  := TButton():New(032,008,'Atualizar',oPnlFiltro,bAtualiza,50,12,,,,.T.)
bLibera     := TButton():New(002,008,'Reenvia',oPnlBotoes,bReenvia,50,12,,,,.T.)
/*
bEnviaWf    := TButton():New(002,070,'Enviar E-mail',oPnlBotoes,bEnviaWf,50,12,,,,.T.)
bAprovar 	:= TButton():New(002,130,'Aprovar',oPnlBotoes,bAprovar,50,12,,,,.T.)  
bReprovar   := TButton():New(002,190,'Reprovar',oPnlBotoes,bReprovar,50,12,,,,.T.)
bVisualiz   := TButton():New(002,250,'Visualizar',oPnlBotoes,bVisualiz,50,12,,,,.T.)
*/
bCancela    := TButton():New(002,080,'Cancelar',oPnlBotoes,bCancela,50,12,,,,.T.)
bLegenda    := TButton():New(002,150,'Legenda',oPnlBotoes,bLegenda,50,12,,,,.T.)
bSair       := TButton():New(002,240,'Sair',oPnlBotoes,bSair,50,12,,,,.T.)
//P=Pendente;E=Envia p/ Integração;S=Sucesso;R=Erro ao integrar;X=Processando Integracao;O=Erro de Processamento;V=Reenviado      
oSelect:AddColumn(tcColumn():new(""		    , {|| if(aDados[oSelect:nAt, 08], oOk, oNo)}, {|| marcaReg(@aDados,oSelect)},,,,, .T., .F.,,,, .F.))
oSelect:AddColumn(tcColumn():new("Status", {|| IF(LEN(aDados) > 0 ,IF(EMPTY(aDados[oSelect:nAt, 01]) .OR. aDados[oSelect:nAt, 01] == '000',oPendent,IF(ALLTRIM(aDados[oSelect:nAt, 01]) == '200',oSucesso,IF(aDados[oSelect:nAt, 01] == 'S',oSucesso,oReprov))),'')}, ,,,,, .T., .F.,,,, .F.))
oSelect:AddColumn(tcColumn():new("Número"		, {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 02],'')}, PESQPICT("SE1", "E1_NUM") ,,, "LEFT" , 10						, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Nosso Número"		, {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 11],'')}, PESQPICT("SE1", "E1_NUMBCO") ,,, "LEFT" , 10						, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Emissão"	    , {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 03],'')}, PESQPICT("SE1", "E1_EMISSAO"),,, "LEFT" , TamSX3("E1_EMISSAO")[1]						, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Cliente"	, {|| IF(LEN(aDados) > 0 ,aDados[oSelect:nAt, 04],'')}, PESQPICT("SE1", "E1_NOMCLI") ,,, "LEFT" , TamSX3("E1_NOMCLI")[1]	+10					, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Valor", {|| IF(LEN(aDados) > 0 ,aDados[oSelect:nAt, 05],'')}, PESQPICT("SE1", "E1_VALOR") ,,, "RIGHT" , 60						, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Ult. Envio"		, {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 10],'')}, PESQPICT("SE1", "E1_G_DTENV") ,,, "LEFT" , 20						, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Cod. Retorno"		, {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 06],'')}, PESQPICT("SE1", "E1_G_STARE") ,,, "LEFT" , 10						, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Erro"		, {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 07],'')}, PESQPICT("SE1", "E1_G_DESRE") ,,, "LEFT" , 100						, .F., .F.,,,,.F.))

oSelect:setArray(aDados)               
oSelect:bWhen := {|| Len(aDados) > 0}
oSelect:bLDblClick := { || marcaReg(@aDados,oSelect) }
atuDados(oSelect, @aDados)
ACTIVATE DIALOG oDlg CENTERED                                                      

return   

//*************************************************************************************//

static function marcaReg(aADados,oATB)

aADados[oATB:nAt, 8] := !aADados[oATB:nAt, 8]
oATB:Refresh()

return//*************************************************************************************//
    
static function atuDados(oATB, aADados) 

local cWhere := "%"
LOCAL cAlias  
LOCAL cFilLog := cFilAnt
LOCAL cObs   
Local cDescEnt := ''
aADados := {}  

if !Empty(cNumeroDe)
	cWhere += " AND E1_NUM >= '" + cNumeroDe + "' "
endif 
if !Empty(cNumeroAte)
	cWhere += " AND E1_NUM <= '" + cNumeroAte + "' "
endif   

if !Empty(cDataIni)
	cWhere += " AND E1_EMISSAO >= '" + DTOS(cDataIni) + "' "
endif

if !Empty(cDataFim)
	cWhere += " AND E1_EMISSAO <= '" + DTOS(cDataFim) + "' "
endif       

if !Empty(cStat)
	IF(cStat == '1')
		cWhere += " AND (E1_G_STARE = '' OR E1_G_STARE ='000')"
	ELSEIF(cStat == '2')
		cWhere += " AND E1_G_STARE != ' ' AND E1_G_STARE != '200' "
	ELSEIF(cStat == '3')
		cWhere += " AND E1_G_STARE = '200' "
	ENDIF
	
endif


cWhere += "%"
                                                                                                                                                  	
BeginSql alias 'QRYTMP_'     
	Column E1_EMISSAO as date
	Column E1_G_DTENV as date
	SELECT E1_FILIAL,E1_NUM,E1_EMISSAO, E1_VALOR, E1_CLIENTE, E1_LOJA,E1_NOMCLI,E1_G_STARE,E1_G_DESRE, SE1.R_E_C_N_O_ AS RECSE1,E1_G_DTENV,E1_G_HRENV,E1_NUMBCO
	
	FROM %Table:SE1% SE1
	INNER JOIN %Table:SA1% SA1 ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND A1_FILIAL = %EXP:xFilial('SA1')%

	WHERE SE1.%NotDel% AND SA1.%NotDel% AND 1=1 AND A1_XBORDER != "N" AND A1_EST != 'EX'
	%exp:cWhere%  
	ORDER BY E1_FILIAL, E1_NUM
	
EndSql   

while !QRYTMP_->(Eof())
	
	
	aAdd(aADados, {		;
	QRYTMP_->E1_G_STARE,	;
	QRYTMP_->E1_NUM,	;
	QRYTMP_->E1_EMISSAO, ;
	QRYTMP_->E1_CLIENTE + '/' + QRYTMP_->E1_LOJA + ' - ' + QRYTMP_->E1_NOMCLI, ;
	QRYTMP_->E1_VALOR, ;
	QRYTMP_->E1_G_STARE,;
	QRYTMP_->E1_G_DESRE,;
	.F.,;
	QRYTMP_->RECSE1,;
	DTOC(QRYTMP_->E1_G_DTENV) + ' ' + QRYTMP_->E1_G_HRENV,;
	QRYTMP_->E1_NUMBCO;
	})
	
	
	
	
	QRYTMP_->(DBSkip())
enddo

QRYTMP_->(DBCloseArea())

oATB:setArray(aADados)
oATB:Refresh()

cFilAnt := cFilLog

return


static function reenvia(oSelect,aDados)
	Local LErro := .F.
	Local _nIndx
	dbSelectArea('ZZE')
	for _nIndx := 1 to LEN(aDados) 
	
		IF(aDados[_nIndx, 08]) 
			IF ALLTRIM(aDados[_nIndx, 01]) =='200'
				LErro := .T.
			ELSE
				U_A0601REG(aDados[_nIndx, 09])
			ENDIF
		ENDIF
		
	next
	
	IF (LErro)
		ALERT('Alguns registros não foram reenviados pois não é possível reenviar boletos já registrados.')
	else
		MsgInfo( "Boletos enviados com sucesso. Verifique o status do envio após a tela recarregar automaticamente.", "Sucesso!" ) 
	ENDIF
	
	atuDados(oSelect,@aDados)
return

static function cancelaEnv(oSelect,aDados)
	Local LErro := .F.
	Local _nIndx
	dbSelectArea('ZZE')
	for _nIndx := 1 to LEN(aDados) 
	
		IF(aDados[_nIndx, 08]) 
			IF ALLTRIM(aDados[_nIndx, 01]) =='200'
				LErro := .T.
			ELSE
				SE1->(DBGOTO(aDados[_nIndx, 09]))
				RecLock("SE1",.F.)
					SE1->E1_G_STARE := ''
					SE1->E1_G_DESRE := 'Envio Cancelado'
					SE1->E1_G_DTENV := DATE()
					SE1->E1_G_HRENV := TIME()
				SE1->(MsUnlock())
			ENDIF
		ENDIF
		
	next
	
	IF (LErro)
		ALERT('Alguns registros não foram cancelados pois estão aprovados.')
	else
		MsgInfo( "Registro de boletos cancelados com sucesso.", "Sucesso!" ) 
	ENDIF
	
	atuDados(oSelect,@aDados)
return



static function atuStatus(oSelect, aDados,cStatus)
   
	atuDados(oSelect,@aDados)

Return       



static function legenda()


BrwLegenda( "Integrações Itau"	,;						//Titulo do Cadastro
		    "Legenda"		    ,;						//"Legenda"
			{;
				{"BR_AMARELO"  	,"Pendente"	}  ,	 ;
				{"BR_VERMELHO"	,"Erro ao integrar"	},	;
				{"BR_VERDE"	,"Sucesso"	};
			};
		 )
		   
		 
Return( .T. )         

static function visualiza(oSelect,aDados)
  
	
return        

static function envMal(cFil,cNumPed)   
	
return .T.


	
