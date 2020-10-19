#INCLUDE "PROTHEUS.CH"
/*---------------------------------------------------------------------------+
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina                                       			 !
+------------------+---------------------------------------------------------+
!Módulo            !                                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Monitor de integração com manusis.  
!				   !	 !
/*-----------------+---------------------------------------------------------+
!Nome              ! MNSIS01                                                 !			                                          !
+------------------+---------------------------------------------------------+
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo G. Vieira                                       !
+------------------+--------------------------------------------------------*/


user function MNSIS01   

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
local bReprovar := {|| atuStatus(oSelect,@aDados,'2') }  
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
private cEntida   := ' ' 
private cTpInt    := ' ' 
private cStatBl   := '1' 
private cDataIni  := DDATABASE
private cDataFim  := DDATABASE   
private oIncons   := LoadBitmap(GetResources(), "BR_AMARELO")
private oPendEnv  := LoadBitmap(GetResources(), "BR_BRANCO")
private oReprov   := LoadBitmap(GetResources(), "BR_VERMELHO")
private oSucesso  := LoadBitmap(GetResources(), "BR_VERDE")
private oEmEnv    := LoadBitmap(GetResources(), "BR_AZUL")     
private oErrProc  := LoadBitmap(GetResources(), "BR_CANCEL")                
private oReenv    := LoadBitmap(GetResources(), "BR_LARANJA")           
   
//dbSelectArea("SX3")
//SX3->(DBSetOrder(2))
OpenSXs(,,,,,"TMPSX3","SX3")
TMPSX3->(DbSetOrder(2))
TMPSX3->(DBSeek("ZZE_STATUS")) 
aOpcStat := StrTokArr("  ;"+AllTrim(X3Cbox()),";")   

//dbSelectArea("SX3")
//SX3->(DBSetOrder(2))
TMPSX3->(DBSeek("ZZE_TIPO")) 

aOpcTipo := StrTokArr("  ;"+AllTrim(X3Cbox()),";")  

cOpcAx  := "CTT=Centro de Custo;CT1=Conta contabil;SB1=Produto;SAH=Unidade Medida;CTD=Item Contábil;SBM=Grupo de Produto;SR6=Turno;RCM=Tipo Afastamento;SR8=Afastamento;SA2=Fornecedor;SRA=Funcionário;SB9=Item Estoque;NNR=Almoxarifado;SRJ=Função;"  
aOpcEnt := StrTokArr("  ;"+AllTrim(cOpcAx),";")  
DEFINE MSDIALOG oDlg TITLE 'Integração Manusis' FROM aSize[7],aSize[1] To aSize[6],aSize[5] PIXEL      

oPnlFiltro := TPanel():New(,,,oDlg,,,,,,,48,,.F.,.F. )
oPnlFiltro:Align := CONTROL_ALIGN_TOP

oPnlBotoes := TPanel():New(,,,oDlg,,,,,,,16,,.F.,.F. )
oPnlBotoes:Align := CONTROL_ALIGN_BOTTOM

oSelect := tcBrowse():New(,,,,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.)
oSelect:Align := CONTROL_ALIGN_ALLCLIENT

@ 002, 008 SAY 'Tipo'    SIZE 053, 007 OF oPnlFiltro PIXEL
@ 002, 100 SAY 'Data de?' SIZE 053, 007 OF oPnlFiltro PIXEL	
@ 002, 160 SAY 'Data até?'    SIZE 053, 007 OF oPnlFiltro PIXEL
@ 002, 230 SAY 'Status'    SIZE 053, 007 OF oPnlFiltro PIXEL
@ 002, 330 SAY 'Entidade?'    SIZE 053, 007 OF oPnlFiltro PIXEL
//350

@ 010, 008  MSCOMBOBOX oGetxStat VAR cTpInt ITEMS aOpcTipo SIZE 080,010  OF oPnlFiltro PIXEL 
@ 010, 100 MSGET oGetDatI VAR cDataIni SIZE 060, 010 OF oPnlFiltro PIXEL HASBUTTON
@ 010, 160 MSGET oGetDatF VAR cDataFim SIZE 060, 010 OF oPnlFiltro PIXEL HASBUTTON    
@ 010, 230  MSCOMBOBOX oGetxStat VAR cStat ITEMS aOpcStat SIZE 080,010  OF oPnlFiltro PIXEL 
@ 010, 330  MSCOMBOBOX oGetStaB VAR cEntida ITEMS aOpcEnt SIZE 080,010  OF oPnlFiltro PIXEL            

oBtnAtuali  := TButton():New(032,008,'Atualizar',oPnlFiltro,bAtualiza,50,12,,,,.T.)
bLibera     := TButton():New(002,008,'Reenvia',oPnlBotoes,bReenvia,50,12,,,,.T.)
/*
bEnviaWf    := TButton():New(002,070,'Enviar E-mail',oPnlBotoes,bEnviaWf,50,12,,,,.T.)
bAprovar 	:= TButton():New(002,130,'Aprovar',oPnlBotoes,bAprovar,50,12,,,,.T.)  
bReprovar   := TButton():New(002,190,'Reprovar',oPnlBotoes,bReprovar,50,12,,,,.T.)
bVisualiz   := TButton():New(002,250,'Visualizar',oPnlBotoes,bVisualiz,50,12,,,,.T.)
*/
bLegenda    := TButton():New(002,070,'Legenda',oPnlBotoes,bLegenda,50,12,,,,.T.)
bSair       := TButton():New(002,130,'Sair',oPnlBotoes,bSair,50,12,,,,.T.)
//P=Pendente;E=Envia p/ Integração;S=Sucesso;R=Erro ao integrar;X=Processando Integracao;O=Erro de Processamento;V=Reenviado      
oSelect:AddColumn(tcColumn():new(""		    , {|| if(aDados[oSelect:nAt, 07], oOk, oNo)}, {|| marcaReg(@aDados,oSelect)},,,,, .T., .F.,,,, .F.))
oSelect:AddColumn(tcColumn():new("Status", {|| IF(LEN(aDados) > 0 ,IF(aDados[oSelect:nAt, 01] == 'P',oPendEnv,IF(aDados[oSelect:nAt, 01] == 'E',oEmEnv,IF(aDados[oSelect:nAt, 01] == 'S',oSucesso,IF(aDados[oSelect:nAt, 01] == 'R',oReprov,IF(aDados[oSelect:nAt, 01] == 'X',oIncons,IF(aDados[oSelect:nAt, 01] == 'V',oReenv,oErrProc)))))),'')}, ,,,,, .T., .F.,,,, .F.))
oSelect:AddColumn(tcColumn():new("Tipo"		, {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 02],'')}, PESQPICT("ZZE", "ZZE_TIPO") ,,, "LEFT" , 10						, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Data"	    , {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 03],'')}, PESQPICT("ZZE", "ZZE_DTINC"),,, "LEFT" , TamSX3("ZZE_DTINC")[1]						, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Entidade"	, {|| IF(LEN(aDados) > 0 ,aDados[oSelect:nAt, 04],'')}, PESQPICT("ZZE", "ZZE_ENTIDA") ,,, "LEFT" , TamSX3("ZZE_ENTIDA")[1]						, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Descrição", {|| IF(LEN(aDados) > 0 ,aDados[oSelect:nAt, 05],'')}, PESQPICT("SA2", "A2_NOME") ,,, "LEFT" , 60						, .F., .F.,,,,.F.))
oSelect:AddColumn(tcColumn():new("Erro"		, {|| IF(LEN(aDados) > 0,aDados[oSelect:nAt, 06],'')}, PESQPICT("ZZE", "ZZE_ERRO") ,,, "LEFT" , 100						, .F., .F.,,,,.F.))

oSelect:setArray(aDados)               
oSelect:bWhen := {|| Len(aDados) > 0}
oSelect:bLDblClick := { || marcaReg(@aDados,oSelect) }
atuDados(oSelect, @aDados)
ACTIVATE DIALOG oDlg CENTERED                                                      

return   

//*************************************************************************************//

static function marcaReg(aADados,oATB)

aADados[oATB:nAt, 7] := !aADados[oATB:nAt, 7]
oATB:Refresh()

return//*************************************************************************************//
    
static function atuDados(oATB, aADados) 

local cWhere := "%"
LOCAL cAlias  
LOCAL cFilLog := cFilAnt
LOCAL cObs   
Local cDescEnt := ''
aADados := {}  

if !Empty(cTpInt)
	cWhere += " AND ZZE_TIPO = '" + cTpInt + "' "
endif   

if !Empty(cDataIni)
	cWhere += " AND ZZE_DTINC >= '" + DTOS(cDataIni) + "' "
endif

if !Empty(cDataFim)
	cWhere += " AND ZZE_DTINC <= '" + DTOS(cDataFim) + "' "
endif       

if !Empty(cStat)
	cWhere += " AND ZZE_STATUS = '" + ALLTRIM(cStat) + "' "
endif

if !Empty(cEntida)
	cWhere += " AND ZZE_ENTIDA = '" + ALLTRIM(cEntida) + "' "
endif   

cWhere += "%"
                                                                                                                                                  	
BeginSql alias 'QRYTMP_'     
	Column ZZE_DTINC as date
	SELECT ZZE_FILIAL,ZZE_CODIGO,ZZE_DTINC,ZZE_TIPO, ZZE_ENTIDA,ZZE_ERRO,ZZE_CHAVE,ZZE_STATUS,ZZE_OPER, ZZE.R_E_C_N_O_ AS RECZZE
	
	FROM %Table:ZZE% ZZE

	WHERE ZZE.%NotDel% AND 1=1
	%exp:cWhere%  
	ORDER BY ZZE_FILIAL, ZZE_CODIGO
	
EndSql   

while !QRYTMP_->(Eof())
	
	aRetEnt := RETDESC(QRYTMP_->ZZE_CHAVE,QRYTMP_->ZZE_ENTIDA)
	
	aAdd(aADados, {		;
	QRYTMP_->ZZE_STATUS,	;
	IF(QRYTMP_->ZZE_TIPO=='E','Exportação','Importação'),	;
	QRYTMP_->ZZE_DTINC, ;
	aRetEnt[1], ;
	aRetEnt[2], ;
	QRYTMP_->ZZE_ERRO,;
	.F.,;
	QRYTMP_->RECZZE;
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
	Local nInd
	dbSelectArea('ZZE')
	for nInd := 1 to LEN(aDados) 
	
		IF(aDados[nInd, 07]) 
//			if  aDados[nInd, 02] $ 'R|O' 
				ZZE->(DBGOTO(aDados[nInd, 08]))
				RecLock("ZZE",.F.)
				ZZE->ZZE_STATUS   := 'V'
				ZZE->(msUnlock())
				
				oManusis  := ClassIntManusis():newIntManusis()      
				oManusis:cFilZze    := ZZE->ZZE_FILIAL
				oManusis:cChave     := ZZE->ZZE_CHAVE
				oManusis:cTipo	    := ZZE->ZZE_TIPO  
				oManusis:cStatus    := ZZE->ZZE_STATUS
				oManusis:cErro      := '' 
				oManusis:cEntidade  := ZZE->ZZE_ENTIDA
				oManusis:cOperacao  := ZZE->ZZE_OPER  
				oManusis:cRotina    := FunName()
				oManusis:cErroValid := ''
				
				IF oManusis:gravaLog()  
					U_MNSINT01(oManusis)              
				ELSE
					ALERT(oManusis:cErroValid)
				ENDIF  
//			ELSE
//				LErro := .T.
//			ENDIF
		ENDIF
		
	next
	
	IF (LErro)
		ALERT('Alguns registros não foram reenviados. Apenas integrações de exportação que estejam com status Erro de Integração ou Erro ao Integrar podem ser reenviados.')
	ENDIF
	
	atuDados(oSelect,@aDados)
return



static function atuStatus(oSelect, aDados,cStatus)
   
	atuDados(oSelect,@aDados)

Return       

static function libPed(oSelect, aDados)
   
	atuDados(oSelect,@aDados)

return 


static function legenda()


BrwLegenda( "Integrações Manusis"	,;						//Titulo do Cadastro
		    "Legenda"		    ,;						//"Legenda"
			{;
				{"BR_BRANCO"	,"Pendente"	}	,;
				{"BR_AZUL"		,"Enviado"	}	,;	
				{"BR_AMARELO"  	,"Processando Integração"	}  ,	 ;
				{"BR_VERMELHO"	,"Erro ao integrar"	},	;
				{"BR_CANCEL"	,"Erro de Processamento"	},	;
				{"BR_LARANJA"	,"Reenviado"	},	;
				{"BR_VERDE"	,"Sucesso"	};
			};
		 )
		   
		 
Return( .T. )         

static function visualiza(oSelect,aDados)
  
	
return        

static function envMal(cFil,cNumPed)   
	
return .T.

STATIC FUNCTION RETDESC(cChaveEnt,_cEntida)
Local cDescEnt := ''
Local cNomEnt  := ''

DO CASE
	  CASE _cEntida =='CTT'
		cNomEnt  := 'Centro de Custo'
		dbSelectArea('CTT')
		DbsetOrder(1)
		IF CTT->(DBSeek(cChaveEnt))  
						
			cDescEnt := ALLTRIM(CTT->CTT_CUSTO) +"-"+ ALLTRIM(CTT->CTT_DESC01) 
		ELSE	
			cDescEnt := 'Centro de custo inválido. Chave: '+cChaveEnt
			lRet := .F.
		ENDIF
	  CASE _cEntida =='CT1'
		 cNomEnt  := 'Conta Contábil'
		 dbSelectArea('CT1')
			DbsetOrder(1)
			IF CT1->(DBSeek(cChaveEnt))  
				cDescEnt :=  ALLTRIM(CT1->CT1_CONTA) +"-"+ ALLTRIM(CT1->CT1_DESC01)
			ELSE		
				cDescEnt := 'Conta Contábil inválida. Chave: '+cChaveEnt
				lRet := .F.
			ENDIF
	  CASE _cEntida =='CTD'
		 cNomEnt  := 'Item Contábil'
		 dbSelectArea('CTD')
			DbsetOrder(1)
			IF CTD->(DBSeek(cChaveEnt))  
							
				cDescEnt :=  CTD->CTD_ITEM +"-"+ ALLTRIM(CTD->CTD_DESC01)
			   
			ELSE		
				cDescEnt := 'Item Contábil inválida. Chave: '+cChaveEnt
				lRet := .F.
			ENDIF    
	  CASE _cEntida =='SB1'
			cNomEnt := 'Produto'
		 	dbSelectArea('SB1')
			DbsetOrder(1)
			IF SB1->(DBSeek(cChaveEnt))  
				
				cDescEnt :=  ALLTRIM(SB1->B1_COD) +"-"+ ALLTRIM(SB1->B1_DESC)
					
			ELSE	
				cDescEnt := 'Produto inválido. Chave: '+cChaveEnt
				lRet := .F.
			ENDIF 
	  CASE _cEntida =='SAH'
		 cNomEnt := 'Unidade de Medida'
		 dbSelectArea('SAH')
			DbsetOrder(1)
			IF SAH->(DBSeek(cChaveEnt))   
							
				cDescEnt := SAH->AH_UNIMED +"-"+ ALLTRIM(SAH->AH_DESCPO) 
			        
			ELSE	
				cDescEnt := 'Unidade de medida inválida. Chave: '+cChaveEnt
				lRet := .F.
			ENDIF
	  CASE _cEntida =='SBM'
			cNomEnt := 'Grupo de Produto'
		 	dbSelectArea('SBM')
			DbsetOrder(1)
			IF SBM->(DBSeek(cChaveEnt))  
							
				cDescEnt :=  SBM->BM_GRUPO +"-"+ ALLTRIM(SBM->BM_DESC) 
			ELSE		
				cDescEnt := 'Grupo de Produto inválido. Chave: '+cChaveEnt
				lRet := .F.
			ENDIF    
	  CASE _cEntida =='SR6'
			cNomEnt := 'Turno'
		 	dbSelectArea('SR6')
			DbsetOrder(1)
			IF SR6->(DBSeek(cChaveEnt))  
							
				cDescEnt :=  SR6->R6_TURNO +"-"+ ALLTRIM(SR6->R6_DESC) 
			ELSE	
				cDescEnt := 'Turno inválido. Chave: '+cChaveEnt
				lRet := .F.
			ENDIF   
	  CASE _cEntida =='RCM'
			cNomEnt := 'Tipo Ausência'
		 	dbSelectArea('RCM')
			DbsetOrder(1)
			IF RCM->(DBSeek(cChaveEnt))  
							
				cDescEnt :=  RCM->RCM_TIPO +"-"+ ALLTRIM(RCM->RCM_DESCRI) 	   
			ELSE	
				cDescEnt := 'Razao de ausencia inválido. Chave: '+cChaveEnt
				lRet := .F.
			ENDIF    
	  CASE _cEntida =='SR8'
			cNomEnt := 'Ausência'
		 	dbSelectArea('SR8')
			DbsetOrder(5)
			IF SR8->(DBSeek(cChaveEnt))  
				cDescEnt := SR8->R8_MAT +"-"+ POSICIONE('RCM',1,xFilial('RCM')+SR8->R8_TIPOAFA,'RCM_DESCRI')  
			   
			ELSE		
				cDescEnt := 'Ausencia inválido. Chave: '+cChaveEnt
				lRet := .F.
			ENDIF  
	  CASE _cEntida =='SA2'
			cNomEnt := 'Fornecedor'
		 	dbSelectArea('SA2')
			DbsetOrder(1)
			IF SA2->(DBSeek(cChaveEnt))  
							
				cDescEnt := SA2->A2_COD+SA2->A2_LOJA +"-"+ ALLTRIM(SA2->A2_NOME)
			ELSE		
				cDescEnt := 'Fornecedor inválido. Chave: '+cChaveEnt
				lRet := .F.
			ENDIF  
	  CASE _cEntida =='SRA'
			cNomEnt := 'Funcionário'
		 	dbSelectArea('SRA')
			DbsetOrder(1)
			IF SRA->(DBSeek(cChaveEnt))  
							
				cDescEnt := SRA->RA_MAT +"-"+ ALLTRIM(SRA->RA_NOME) 
			ELSE	
				cDescEnt := 'Funcionário inválido. Chave: '+cChaveEnt
				lRet := .F.
			ENDIF
	  CASE _cEntida =='SB9'
			cNomEnt := 'Estoque'
		 	dbSelectArea('SB9')
			DbsetOrder(1)
			IF SB9->(DBSeek(cChaveEnt))  
				cDescEnt := SB9->B9_COD+'-'+POSICIONE('SB9',1,SB9->B9_FILIAL+SB9->B9_COD,'B1_DESC') 
			ELSE	
				cDescEnt := 'Item Estoque inválido. Chave: '+cChaveEnt
				lRet := .F.
			ENDIF
	  CASE _cEntida =='NNR'
		 cNomEnt := 'Almoxarifado'
		 dbSelectArea('NNR')
			DbsetOrder(1)
			IF NNR->(DBSeek(cChaveEnt))  
							
				cDescEnt :=  NNR->NNR_CODIGO +"-"+ NNR->NNR_DESCRI 
			   
			ELSE		
				cDescEnt := 'Almoxarifado inválido. Chave: '+cChaveEnt
				lRet := .F.
			ENDIF   
	  CASE _cEntida =='SRJ'
			cNomEnt := 'Função'
		 	dbSelectArea('SRJ')
			DbsetOrder(1)
			IF SRJ->(DBSeek(cChaveEnt))  
							
				cDescEnt := SRJ->RJ_FUNCAO +'-'+ALLTRIM(SRJ->RJ_DESC) 
			   
			ELSE		
				cDescEnt := 'Função inválida. Chave: '+cChaveEnt
			ENDIF  
	  CASE _cEntida =='AWF'
			cNomEnt := 'TIMELINE'
			
		 	dbSelectArea('SC2')
			DbsetOrder(1)
			IF SC2->(DBSeek(cChaveEnt))   
							
				cDescEnt := SC2->C2_XNUMOM +'-'+ALLTRIM(ZZE->ZZE_TXTSTA) 
			   
			ELSE		
				cDescEnt := 'TIMELINE inválida. Chave: '+cChaveEnt
			ENDIF  
	   CASE _cEntida =='SOP'
			cNomEnt := 'Status OM'
			
			dbSelectArea('ZZF')
			//op+reserva
			DbsetOrder(2)
			IF ZZF->(DBSeek(cChaveEnt))  
		 	
				cDescEnt := ZZF->ZZF_OM +' - STATUS: '+ALLTRIM(ZZE->ZZE_STATOP) 
			   
			ELSE		
				cDescEnt := 'Status inválido. Chave: '+cChaveEnt
			ENDIF  
	   CASE _cEntida =='BXP'
			
			cNomEnt := 'Baixa de Estoque'
		 	dbSelectArea('CB9')
			DbsetOrder(6)
			IF CB9->(DBSeek(cChaveEnt))  
			
				cDescEnt := 'Ordem Sep. '+CB9->CB9_ORDSEP + ' Produto: '+CB9->CB9_PROD+'-'+ALLTRIM(POSICIONE('SB1',1,xFilial('SB1')+CB9->CB9_PROD,'B1_DESC'))
 
			ELSE		
				cDescEnt := 'Função inválida. Chave: '+cChaveEnt
			ENDIF  
	   CASE _cEntida =='EXP'
			
			cNomEnt := 'Estorno de baixa de Estoque'
			
		 	dbSelectArea('SD3')
			_nRecno := VAL(cChaveEnt)
			SD3->(DbGoto(_nRecno))
			
			IF SD3->(RECNO()) ==  _nRecno
			
				cDescEnt := 'OM. '+POSICIONE('SC2',1,xFilial('SC2')+SD3->D3_OP,'C2_XNUMOM') + ' Produto: '+SD3->D3_COD+'-'+ALLTRIM(POSICIONE('SB1',1,xFilial('SB1')+SD3->D3_COD,'B1_DESC'))
 
			ELSE		
				cDescEnt := 'Função inválida. Chave: '+cChaveEnt
			ENDIF  
	   CASE _cEntida =='SC2'
			cNomEnt := 'Ordem Manutenção'
			
		 	dbSelectArea('SC2')
			DbsetOrder(12)
			IF SC2->(DBSeek(xFilial('SC2')+cChaveEnt))   
							
				cDescEnt := 'OM '+SC2->C2_XNUMOM +' OP'+ALLTRIM(SC2->C2_NUM) 
			   
			ELSE		
				cDescEnt := 'OM '+cChaveEnt
			ENDIF  
	  OTHERWISE	 
		cDescEnt := 'Entidade inválida. Entidade: ' +_cEntida
	ENDCASE 
return {cNomEnt,cDescEnt}

	
