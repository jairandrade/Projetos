#Include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
/*
+----------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Ponto de entrada                                        !
+------------------+---------------------------------------------------------+
!Modulo            ! Compras                                                 !
+------------------+---------------------------------------------------------+
!Nome              ! APON002                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! Limpa as marcações importadas    !
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo G. Vieira                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 24/04/2019                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES   !                                                         !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/
User Function APON002()    
Local oDlg

Local oVal
Local oDataDe           
Local dDataDe  := CTOD('  /  /    ') 
Local oMotivo            
Local cMotivo := space(250)
Local cRet
Local lOk := .F.  
LOCAL cTime


DEFINE MSDIALOG oDlg TITLE "Limpar Marcações" FROM 000, 000 TO 300, 500 PIXEL


@ 050, 015 say "Data Inicial:" SIZE 053, 007 OF oDlg PIXEL
@ 060, 015  MSGET oDataDe VAR dDataDe SIZE 100,010 OF oDlg PIXEL HASBUTTON

//@ 005,110 SAY "Valor:" SIZE 053, 007 OF oDlg PIXEL
//@ 015, 110  MSGET oVal VAR dVal SIZE 100,010 OF oDlg PIXEL HASBUTTON
//
//@ 035, 015 SAY "Motivo:" SIZE 053, 007 OF oDlg PIXEL
//@ 045, 015  MSGET oMotivo VAR cMotivo SIZE 200,010 OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| if(valida(dDataDe), (lOk := .T., oDlg:End()), ) }, {|| oDlg:End() } )  CENTERED

cRet := Aviso("Confirmação","Deseja excluir as marcações de '"+ALLTRIM(DTOC(dDataDe))+"' até "+DTOC(DATE())+" ?",{"Confirmar", "Cancelar"})

if(lOk)
	if(cRet == 1)
		
		
		Processa( {|| EXCMARC(dDataDe) }, "Aguarde...", "Excluindo Marcações...",.F.)    
	
		
	endif
endif
return  

static function valida(dDataDe)

Local dValPonM := STOD(SUBSTR(GETMV('MV_PONMES'),1,8))
      
IF(EMPTY(dDataDe))
    Alert('Preencha a data')
	RETURN .F.
ENDIF

IF(dDataDe > DATE())
    Alert('Não é possível excluir dados futuros')
	RETURN .F.
ENDIF

IF(dValPonM > dDataDe )
	Alert('Data não pode ser inferior ao Período aberto. Período '+GETMV('MV_PONMES'))
	RETURN .F.
ENDIF

return  .T.

static function EXCMARC(dDataDe)
Local nInd
Local cNumRep := ''
Local aReps := {}

//Conout(UsrRetName(RetCodUsr())+" Excluiu as marcações de '"+ALLTRIM(DTOC(dDataDe))+"' até "+DTOC(DATE())+" ?")
		
cAlias := getNextAlias()

BeginSQL Alias cAlias

	SELECT SPC.R_E_C_N_O_ AS PCRECNO
	FROM %TABLE:SPC% SPC
	WHERE SPC.%NotDel% AND PC_FILIAL = %EXP:xFilial('SPC')% AND PC_DATA BETWEEN %EXP:DTOS(dDataDe)% AND %EXP:DTOS(DATE())%

EndSQL

//Conout(getlastquery()[2])

dbSelectArea('SPC')

IncProc("Excluindo Marcações SPC...")
	
while !(cAlias)->(Eof())
	SPC->(DBGOTO((cAlias)->PCRECNO))
	RecLock("SPC",.F.)	
	SPC->(dbDelete())
	SPC->(MsUnLock())
	(cAlias)->(dbSkip())
enddo

(cAlias)->(dbCloseArea())
	
cAlias := getNextAlias()

BeginSQL Alias cAlias

	SELECT SP8.R_E_C_N_O_ AS P8RECNO
	FROM %TABLE:SP8% SP8
	WHERE SP8.%NotDel% AND P8_FILIAL = %EXP:xFilial('SP8')% AND P8_DATA BETWEEN %EXP:DTOS(dDataDe)% AND %EXP:DTOS(DATE())%

EndSQL

//Conout(getlastquery()[2])

dbSelectArea('SP8')

IncProc("Excluindo Marcações SP8...")
	
while !(cAlias)->(Eof())
	SP8->(DBGOTO((cAlias)->P8RECNO))
	RECLOCK("SP8",.F.)	
	SP8->(DBDELETE())
	SP8->(MSUNLOCK())
	(cAlias)->(dbSkip())
enddo

(cAlias)->(dbCloseArea())

cAlias := getNextAlias()

BeginSQL Alias cAlias

	SELECT RFE.R_E_C_N_O_ AS RFERECNO,RFE_NUMREP
	FROM %TABLE:RFE% RFE
	WHERE RFE.%NotDel% AND RFE_FILIAL = %EXP:xFilial('RFE')% AND RFE_DATA BETWEEN %EXP:DTOS(dDataDe)% AND %EXP:DTOS(DATE())%

EndSQL

//Conout(getlastquery()[2])

dbSelectArea('RFE')

IncProc("Excluindo Marcações RFE...")
 	
while !(cAlias)->(Eof())
	
	if ASCAN(aReps, (cAlias)->RFE_NUMREP ) == 0
		aadd(aReps,(cAlias)->RFE_NUMREP)
	endif
	
	
	RFE->(DBGOTO((CALIAS)->RFERECNO))
	RECLOCK("RFE",.F.)	
	RFE->(DBDELETE())
	RFE->(MSUNLOCK())
	(cAlias)->(dbSkip())
enddo

(cAlias)->(dbCloseArea())


FOR nInd := 1 to LEN(aReps)	
	
	IF !EMPTY(cNumRep)
		cNumRep += ','
	endif
	cNumRep += "'"+aReps[nInd]+"'" 
	
next

IF(!EMPTY(cNumRep))
	cNumRep := '%'+cNumRep+'%'
	cAlias := getNextAlias()
	
	BeginSQL Alias cAlias
	
		SELECT RFB.R_E_C_N_O_ AS RFBRECNO
		FROM %TABLE:RFB% RFB
		WHERE RFB.%NotDel% AND RFB_FILIAL = %EXP:xFilial('RFB')% AND RFB_NUMREP IN (%EXP:cNumRep%)
	
	EndSQL
	
	//Conout(getlastquery()[2])
	
	dbSelectArea('RFB')
	
	IncProc("Excluindo Marcações RFB...")
		
	while !(cAlias)->(Eof())
		
		RFB->(DBGOTO((cAlias)->RFBRECNO))
		RecLock("RFB",.F.)	
		RFB->(dbDelete())
		RFB->(MsUnLock())
		(cAlias)->(dbSkip())
	enddo
	
	(cAlias)->(dbCloseArea())
ENDIF

Aviso("Confirmação","Marcações excluídas com sucesso. ",{"Ok"})

return