#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
/*---------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina                                       			 !
+------------------+---------------------------------------------------------+
!Módulo            ! Genérico                                             !
+------------------+---------------------------------------------------------+
!Descrição         ! Atualiza integração manusis
!				   !	 !
/*-----------------+---------------------------------------------------------+
!Nome              ! MNSINTEG!			                                          !
+------------------+---------------------------------------------------------+
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo G. Vieira                                       !
+------------------+--------------------------------------------------------*/


User Function MNSINT01(_cChave)

STARTJOB("U_MNSINT02", GetEnvServer(), .F., cEmpAnt, cFilAnt,_cChave)
//U_MNSINT02(cEmpAnt, cFilAnt,_oManusis)
return .T.

User function MNSINT02(_cEmp,_cFil,_cChave)

Local oManusis  := ClassIntManusis():newIntManusis()    

PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFil TABLES "ZZE" MODULO "SIGAPCP"
		
	oManusis:INTEGRAMANUSIS(_cChave)

RESET ENVIRONMENT
return


User function MNSINT03(_cChave)

Local oManusis  := ClassIntManusis():newIntManusis()    
		
oManusis:INTEGRAMANUSIS(_cChave)

return             

user function cargaSBM()
dbSelectArea('SBM')
SBM->(DBSetOrder(1))

while !SBM->(Eof())
	IF SBM->BM_XMANUSI == '1'
		INTEGRA(SBM->BM_FILIAL+SBM->BM_GRUPO,'SBM')
	ENDIF
	SBM->(DbSkip())	
ENDDO

return 

user function cargaSAH()
dbSelectArea('SAH')
SAH->(DBSetOrder(1))

while !SAH->(Eof()) 
	nRecCt1 := SAH->(RECNO())
    INTEGRA(SAH->AH_FILIAL+SAH->AH_UNIMED,'SAH')
    SAH->(DBGOTO(nRecCt1))
	SAH->(DbSkip())	
ENDDO

return

user function cargaNNR()
dbSelectArea('NNR')
NNR->(DBSetOrder(1))

while !NNR->(Eof()) 
    INTEGRA(NNR->NNR_FILIAL+NNR->NNR_CODIGO,'NNR')
	NNR->(DbSkip())	
ENDDO

return  

user function cargaCTT()
dbSelectArea('CTT')
CTT->(DBSetOrder(1))

while !CTT->(Eof()) 
	IF CTT->CTT_BLOQ != '1'  
		INTEGRA(CTT->CTT_FILIAL+CTT->CTT_CUSTO,'CTT')
	ENDIF
	CTT->(DbSkip())	
ENDDO

return  

user function cargaCT1()
Local nRecCt1 
dbSelectArea('CT1')
CT1->(DBSetOrder(1))

while !CT1->(Eof()) 
	IF CT1->CT1_BLOQ != '1'
		nRecCt1 := CT1->(RECNO())
		INTEGRA(CT1->CT1_FILIAL+CT1->CT1_CONTA,'ZZZ')
		CT1->(DBGOTO(nRecCt1))
    ENDIF
	CT1->(DbSkip())	
ENDDO

CT1->(DBGOTOP())

while !CT1->(Eof()) 
	IF CT1->CT1_BLOQ != '1' .AND. !EMPTY(CT1->CT1_CTASUP)
		nRecCt1 := CT1->(RECNO())
		INTEGRA(CT1->CT1_FILIAL+CT1->CT1_CONTA,'CT1')
		CT1->(DBGOTO(nRecCt1))
    ENDIF
	CT1->(DbSkip())	
ENDDO


return   

user function cargaCTD()
dbSelectArea('CTD')
CTD->(DBSetOrder(1))

while !CTD->(Eof()) 
	IF CTD->CTD_BLOQ != '1' 
		nRecCt1 := CTD->(RECNO())
		INTEGRA(CTD->CTD_FILIAL+CTD->CTD_ITEM,'CTD')
		CTD->(DBGOTO(nRecCt1))
	ENDIF
	CTD->(DbSkip())	
ENDDO

return


user function cargaSR6()
dbSelectArea('SR6')
SR6->(DBSetOrder(1))

while !SR6->(Eof()) 
	nRecCt1 := SR6->(RECNO())
    INTEGRA(SR6->R6_FILIAL+SR6->R6_TURNO,'SR6')
    SR6->(DBGOTO(nRecCt1))
	SR6->(DbSkip())	
ENDDO

return

user function cargaSB1()
dbSelectArea('SB1')
SB1->(DBSetOrder(1))

while !SB1->(Eof()) 
	nRecCt1 := SB1->(RECNO())
	IF  !EMPTY(SB1->B1_GRUPO) .AND. POSICIONE('SBM',1,xFilial('SBM')+SB1->B1_GRUPO,'BM_XMANUSI') == '1'  .AND. SB1->B1_MSBLQL != '1'
		INTEGRA(SB1->B1_FILIAL+SB1->B1_COD,'SB1')
		//INTEGRA(SB1->B1_FILIAL+SB1->B1_COD,'SB9')
    ENDIF
    SB1->(DBGOTO(nRecCt1))
	SB1->(DbSkip())	
ENDDO

return


user function cargaSB9()
dbSelectArea('SB1')
SB1->(DBSetOrder(1))

while !SB1->(Eof()) 
	nRecCt1 := SB1->(RECNO())
	IF  !EMPTY(SB1->B1_GRUPO) .AND. POSICIONE('SBM',1,xFilial('SBM')+SB1->B1_GRUPO,'BM_XMANUSI') == '1'  .AND. SB1->B1_MSBLQL != '1'
		//INTEGRA(SB1->B1_FILIAL+SB1->B1_COD,'SB1')
		INTEGRA(SB1->B1_FILIAL+SB1->B1_COD,'SB9')
		
    ENDIF
    SB1->(DBGOTO(nRecCt1))
	SB1->(DbSkip())	
ENDDO

return

user function cargaRCM()
dbSelectArea('RCM')
RCM->(DBSetOrder(1))

while !RCM->(Eof()) 
	nRecCt1 := RCM->(RECNO())
    INTEGRA(RCM->RCM_FILIAL+RCM->RCM_TIPO,'RCM')
    RCM->(DBGOTO(nRecCt1))
	RCM->(DbSkip())	
ENDDO

return

user function cargaSRJ(cOper)
Default cOper := 'I'
dbSelectArea('SRJ')
SRJ->(DBSetOrder(1))

while !SRJ->(Eof()) 
	nRecCt1 := SRJ->(RECNO())
    INTEGRA(SRJ->RJ_FILIAL+SRJ->RJ_FUNCAO,'SRJ',cOper)
    SRJ->(DBGOTO(nRecCt1))
	SRJ->(DbSkip())
ENDDO

return


user function cargaSA2()
Local nRecEnt
dbSelectArea('SA2')
SA2->(DBSetOrder(1))

while !SA2->(Eof()) 

	nRecEnt := SA2->(RECNO())
	IF SA2->A2_MSBLQL != '1'
		INTEGRA(SA2->A2_FILIAL+SA2->A2_COD+SA2->A2_LOJA,'SA2')
    ENDIF
    SA2->(DBGOTO(nRecEnt))
    
	SA2->(DbSkip())	
ENDDO

return         


user function cargaSRA()
Local nRecEnt
dbSelectArea('SRA')
SRA->(DBSetOrder(1))

while !SRA->(Eof()) 

	nRecEnt := SRA->(RECNO())
	IF empty(SRA->RA_DEMISSA)  .AND. ALLTRIM(SRA->RA_CC) == '001032'
		INTEGRA(SRA->RA_FILIAL+SRA->RA_MAT,'SRA')
    ENDIF
    SRA->(DBGOTO(nRecEnt))
    
	SRA->(DbSkip())	
ENDDO

return  


user function cargaSR8()
Local nRecEnt
Local _ccManusis := SUPERGETMV( 'TCP_MANCC', .f., '001032' )
dbSelectArea('SR8')
SR8->(DBSetOrder(1))

while !SR8->(Eof()) 

	nRecEnt := SR8->(RECNO())
	IF ALLTRIM(POSICIONE('SRA',1,xFilial('SRA')+SR8->R8_MAT,'RA_CC') )  $ ALLTRIM( _ccManusis );
	.AND. (EMPTY(SR8->R8_DATAFIM) .OR. (!EMPTY(SR8->R8_DATAFIM) .AND. SR8->R8_DATAFIM >= DATE()) )
		INTEGRA(SR8->R8_FILIAL+SR8->R8_NUMID,'SR8')
    ENDIF
    SR8->(DBGOTO(nRecEnt))
    
	SR8->(DbSkip())	
ENDDO

return   



user function CT1MANUS()
Local nRecEnt
dbSelectArea('ZZE')
ZZE->(DBSetOrder(1))

while !ZZE->(Eof()) 

	
	IF ZZE->ZZE_ENTIDA == 'ZZZ'
		RecLock("ZZE",.F.)
		ZZE->ZZE_ENTIDA := 'CT1'
		ZZE->(msUnlock())
    ENDIF
    
	ZZE->(DbSkip())	
ENDDO

return 

STATIC FUNCTION INTEGRA(cChave,cEntidade,cOper)
Default cOper := 'I'
	oManusis  := ClassIntManusis():newIntManusis()     
	oManusis:cFilZze     := xFilial('ZZE')
	oManusis:cChave      := cChave
	oManusis:cTipo	     := 'E'
	oManusis:cStatus     := 'P'
	oManusis:cErro       := ''
	oManusis:cEntidade   := cEntidade
	oManusis:cOperacao   := cOper
	oManusis:cRotina     :=  FunName()
	oManusis:cErroValid  := ''
	IF oManusis:gravaLog()  
		U_MNSINT03(oManusis:cChaveZZE)              
	ELSE
		ALERT(oManusis:cErroValid)
	ENDIF  
RETURN

user function ATUMANUS()

PREPARE ENVIRONMENT EMPRESA '02' FILIAL '01' TABLES "ZZE" MODULO "SIGAEST"

	oManusis  := ClassIntManusis():newIntManusis()  
	oManusis:atualizaHistorico()
	//oManusis:enviaMailEstoque()
	
RESET ENVIRONMENT
return
