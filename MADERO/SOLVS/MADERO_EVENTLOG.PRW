#include 'protheus.ch'

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EVENTLOG                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Processo de geração de log                                                    !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 25/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Alterador por Márcio A. Zaguetti em 12/06/2018 para contemplar todos os prcessos de log das roti-!
! nas de integração do MADERO e para ajustar os log do processo de integração que não form tratados!
! no processo, conforme MIT044                                                                     !
+--------------------------------------------------------------------------------------------------+
*/                                                                                
class EventLog from LongClassName
data nReg
data cFili
data cPasso
	method start(cProcess, dDate, cInfo, cMetEnv, cRot, clog) constructor
	method restart(nrecno) constructor 
	method broken(cEventError, cReturn, lAddInfo)
	method newOrUpdate(cProcess, dDate, cMetEnv, cRot)
	method finish()  
	method setXmlEnv(cXml)
	method setXmlRet(cXml)
	method setAddXmlRet(cXml)         
	method setItensRet()
	method setInfo(cErro, cInfo)
	method setStep(cPasso)
	method setAddInfo(cErro, cInfo)
	method setCountInc()
	method setCountOk()
	method setCountTot(nxTot)
	method setDetail(cId, cEnt, cTp, nVr, cErro, lShow, cZWE_DOCUM, dZWEDTPROC, cZWECHAVE, cZWEDESCP, cZWEPROD, cZWEDETAIL, lSum, nxThrd)
	method pos()
	method GetStep()    
	method GetRecno()    
	method GetUnit()
	method GetExec(cProcess, dDate, cRot)

endclass


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! start                                                                         !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Construttor da classe                                                         !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method start(cProcess, dDate, cInfo, cMetEnv, cRot, clog) class EventLog

	::newOrUpdate(cProcess, dDate, cMetEnv, cRot, clog)

	ZWS->ZWS_PROCES := cProcess
	ZWS->ZWS_DTPROC := dDate
	ZWS->ZWS_STATUS := "A"
	ZWS->ZWS_INF    := cInfo
	ZWS->ZWS_NINT   ++
	ZWS->( msUnLock() )

	// -> salva o registro
	::nReg  :=ZWS->(Recno())
    ::cFili :=ZWS->ZWS_XFILIA
	::cPasso:=ZWS->ZWS_XPASSO

return


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! restart                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! continuidade do processo													   !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method restart(nrecno) class EventLog

	dbSelectArea("ZWS")
	ZWS->(DbGoTo(nrecno))
	If ZWS->(Eof())
		Conout("Processo com ID "+AllTrim(Str(nrecno))+" nao encontrado na tabela ZWS.")
		UserException("Processo com ID "+AllTrim(Str(nrecno))+" nao encontrado na tabela ZWS.")
	Else
		// -> salva o registro
		::nReg  :=ZWS->(Recno())
		::cFili :=ZWS->ZWS_XFILIA
		::cPasso:=ZWS->ZWS_XPASSO
	EndIf	

return


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! broken                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Construttor da classe                                                         !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method broken(cInfoBroken, cReturn, lAddInfo, lShowInfo) class EventLog
Default lAddInfo  := .F.
Default lShowInfo := .T.

	::Pos()
                       
    recLock("ZWS",.F.)
	ZWS->ZWS_STATUS := "E"
	ZWS->ZWS_INF    := cInfoBroken
	ZWS->ZWS_ERROR  := IIF(lAddInfo,ZWS->ZWS_ERROR + Chr(13) + Chr(10) + AllTrim(cReturn), AllTrim(cReturn))
	ZWS->( msUnLock() )

	If lShowInfo
	   ConOut("Erro: " + cInfoBroken)
	EndIf   

return nil
 

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! newOrUpdate                                                                   !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Método para verificar se é inclusão ou update do log                          !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method newOrUpdate(cProcess, dDate, cMetEnv, cRot, clog) class EventLog
Local lnew
Default clog := ""

	Conout(clog + "============================================================================================")
	Conout(clog + "Filial..: " + SM0->M0_CODFIL + " - " + SM0->M0_FILIAL)
	Conout(clog + "Processo: " + cProcess + " - " + cMetEnv + ' de ' + DtoC(dDate))
	Conout(clog + "Iniciado em " + DtoC(Date()) + " as " + Time())
	Conout(clog + "--------------------------------------------------------------------------------------------")

	// -> Verifica Verifica se o log existe
	dbSelectArea("ZWS")
	ZWS->( dbSetOrder(1) )
	ZWS->( dbGoTop() )
	ZWS->( dbSeek( xFilial("ZWS") + xFilial(cRot) + PadR(cProcess,TamSX3("ZWS_PROCES")[1]) + DtoS(dDate) ) )
	lnew := ! ZWS->( Found() )

	recLock("ZWS",lnew)

	IF lnew
		ZWS->ZWS_FILIAL := xFilial("ZWS")           
		ZWS->ZWS_XFILIA := xFilial(cRot)
		ZWS->ZWS_XPASSO := ""		
	EndIF
	
	// -> limpa numero de itens
	ZWS->ZWS_DTINT  := Date()
	ZWS->ZWS_HRINT  := Time()
	ZWS->ZWS_XMLE   := ""
	ZWS->ZWS_XMLR   := "" 
	ZWS->ZWS_ERROR  := ""
	ZWS->ZWS_ITENV  := 0	
	ZWS->ZWS_ITCONF := 0
    
	ConOut(clog + "-> Iniciando processamento...")

return


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! finish                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Finaliza o processo de log                                                    !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method finish() class EventLog
Local lErro:=.F.
   
	::Pos()

	recLock("ZWS",.F.)
    lErro:=(ZWS->ZWS_STATUS == "E") .or. (ZWS->ZWS_ITENV <> ZWS->ZWS_ITCONF)
	ZWS->ZWS_STATUS := IIF(!lErro,"I","E")
	ZWS->ZWS_INF    := IIF(!lErro,"Processo ok.","Erro no processo. Ver detalhe no log.")
	ZWS->ZWS_DTINT  := Date()
	ZWS->ZWS_HRINT  := Time()
	ZWS->( msUnLock() )
                                           
    ConOut(IIF(!lErro,"Fim: Processo finalizado com sucesso.","Fim: Processo finalizado com erro."))
	
	::nReg  := nil
    ::cFili := nil
	::cPasso:= nil


	// -> Grava Backup d log
	dbSelectArea("ZWL")
	RecLock("ZWL",.T.)
	ZWL->ZWL_FILIAL  := ZWS->ZWS_FILIAL
	ZWL->ZWL_XFILIA  := ZWS->ZWS_XFILIA
	ZWL->ZWL_PROCES  := ZWS->ZWS_PROCES
	ZWL->ZWL_DTPROC  := ZWS->ZWS_DTPROC
	ZWL->ZWL_DETAL   := ZWS->ZWS_ERROR
	ZWL->(MSUnlock())

	Conout("--------------------------------------------------------------------------------------------")
	Conout("Finalizado em " + DtoC(Date()) + " as " + Time())

	


return


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! setXmlEnv                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Atualiza dados enviados                                                       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method setXmlEnv(cXml) class EventLog

	::pos()

	recLock("ZWS",.F.)   
	ZWS->ZWS_XMLE   := cXml
	ZWS->ZWS_DTINT  := Date()
	ZWS->ZWS_HRINT  := Time()	
	ZWS->( msUnLock() )

return


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! setXmlRet                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Atualiza dados recebidos                                                      !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method setXmlRet(cXml) class EventLog

	::pos()

	recLock("ZWS",.F.)
	ZWS->ZWS_XMLR  := cXml   
	ZWS->ZWS_DTINT  := Date()
	ZWS->ZWS_HRINT  := Time()	
	ZWS->( msUnLock() )

return


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! setAddXmlRet                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Atualiza dados recebidos                                                      !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method setAddXmlRet(cXml) class EventLog

	::pos()

	recLock("ZWS",.F.)
	ZWS->ZWS_XMLR  := ZWS->ZWS_XMLR + cXml + Chr(13) + Chr(10)
	ZWS->ZWS_DTINT  := Date()
	ZWS->ZWS_HRINT  := Time()	
	ZWS->( msUnLock() )

return


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GetStep                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Retorna o status da execução                                                  !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method GetStep() class EventLog

	::pos()

return(::cPasso)


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GetRecno                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Retorna o recno do processo                                                   !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method GetRecno() class EventLog
Local nRec 
	
	If ::nReg == nil
		Conout("Classe nao instancia para method Start")
		UserException("Classe nao instancia para method Start.")
	Else
		nRec:=::nReg
	EndIf

return(nRec)


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! setItensRet                                                                   !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Atualiza itens recebidos                                                      !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method setItensRet() class EventLog

	::pos()

	recLock("ZWS",.F.)
	ZWS->ZWS_ITENV := ZWS->ZWS_ITENV + 1
	ZWS->ZWS_DTINT  := Date()
	ZWS->ZWS_HRINT  := Time()
	ZWS->( msUnLock() )

return




/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! setCountInc                                                                   !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Itens Incluidos                                                               !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method setCountInc() class EventLog

	::pos()

	recLock("ZWS",.F.)
	ZWS->ZWS_ITCONF ++       
	ZWS->ZWS_DTINT  := Date()
	ZWS->ZWS_HRINT  := Time()

	ZWS->( msUnLock() )

return


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! setCountOk                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Itens processados                                                             !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method setCountOk() class EventLog

	::pos()

	recLock("ZWS",.F.)
	ZWS->ZWS_ITENV ++
	ZWS->ZWS_DTINT  := Date()
	ZWS->ZWS_HRINT  := Time()	
	ZWS->( msUnLock() )

return



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! setCountTot                                                                   !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Itens totais a serem processados                                              !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method setCountTot(nxTot) class EventLog

	::pos()

	recLock("ZWS",.F.)
	ZWS->ZWS_ITENV  := nxTot
	ZWS->ZWS_DTINT  := Date()
	ZWS->ZWS_HRINT  := Time()	
	ZWS->( msUnLock() )

return


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! setInfo                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Grava informações no log                                                      !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method setInfo(cError, cInfo) class EventLog

	::pos()

	recLock("ZWS",.F.)
	ZWS->ZWS_ERROR := cError 
	ZWS->ZWS_INF   := AllTrim(cInfo)
	ZWS->ZWS_DTINT  := Date()
	ZWS->ZWS_HRINT  := Time()	
	ZWS->( msUnLock() )

return



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! setStep                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Grava o 'passo' do log                                                        !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method setStep(cPasso) class EventLog

	::pos()

	recLock("ZWS",.F.)
	ZWS->ZWS_XPASSO := cPasso	
	ZWS->( msUnLock() )

return

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GetUnit                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Pega código da filial                                                         !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method GetUnit() class EventLog

	::pos()

return(::cFili)

 
/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! setAddInfo                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Adiciona informações no log                                                   !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method setAddInfo(cError, cInfo) class EventLog
	
	::pos()

	recLock("ZWS",.F.)
	ZWS->ZWS_ERROR := ZWS->ZWS_ERROR + AllTrim(cError) + Chr(13) + Chr(10)
	ZWS->ZWS_INF   := IIF(AllTrim(cInfo)<>"",AllTrim(cInfo),ZWS->ZWS_INF)
	ZWS->ZWS_DTINT := Date()
	ZWS->ZWS_HRINT := Time()	
	ZWS->( msUnLock() )

return


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! setCountOk                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Prosiciona no registro do log                                                 !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method pos() class EventLog

	IF ::nReg == nil
		Conout("Classe nao instancia para method Start")
		UserException("Classe nao instancia para method Start.")
	EndIf

	If ZWS->( Recno() ) != ::nReg
		ZWS->( dbGoTo( ::nReg ) )
	EndIF
	
	::cFili :=ZWS->ZWS_XFILIA
	::cPasso:=ZWS->ZWS_XPASSO
	
return





/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! setDetail                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Adiciona detalhamento no log                                                  !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method setDetail(cID, cEnt, cTp, cZWECHAVE, cErro, lShow, cZWE_DOCUM, dZWEDTPROC, nZWEVALOR, cZWEDESCP, cZWEPROD, cZWEDETAIL, lSum, nxThrd) class EventLog
Local nTamID  := TamSx3("ZWE_ID")[1]
Local cAuxID  := ""
Default lShow := .T.
Default lSum  := .F.
	
	::pos()

	// -> So o registro for "somado", verifica se já existe. Se não existir inclui e se existir soma o valor
	cAuxID:=cID+Space(nTamID-Len(cID))
	If lSum
		dbSelectArea("ZWS")
		ZWE->(DbSetOrder(1))
		lSum:=ZWE->(DbSeek(ZWS->ZWS_XFILIA+ZWS->ZWS_PROCES+DtoS(ZWS->ZWS_DTINT)+cAuxID+cEnt))
	EndIF

	// -> So o registro for detalhado, inclui no log
	If !lSum
		recLock("ZWE",.T.)
		ZWE->ZWE_FILIAL	:= ZWS->ZWS_XFILIA
		ZWE->ZWE_DATA	:= ZWS->ZWS_DTINT
		ZWE->ZWE_PROCES	:= ZWS->ZWS_PROCES
		ZWE->ZWE_DOCUM  := cZWE_DOCUM
		ZWE->ZWE_DTPROC := dZWEDTPROC
		ZWE->ZWE_ID		:= cID
		ZWE->ZWE_ENTID	:= cEnt
		ZWE->ZWE_CHAVE  := IIF(ValType(cZWECHAVE)=="N",AllTrim(Str(cZWECHAVE)),cZWECHAVE)
		ZWE->ZWE_DESCP  := cZWEDESCP
		ZWE->ZWE_PROD   := cZWEPROD
		ZWE->ZWE_TIPO	:= cTp
		ZWE->ZWE_VALOR	:= nZWEVALOR
		ZWE->ZWE_DESC	:= cErro
		ZWE->ZWE_DETAIL := cZWEDETAIL
		ZWE->ZWE_THRID  := StrZero(nxThrd,10)
		ZWE->(msUnLock())
	Else
		recLock("ZWE",.F.)
		ZWE->ZWE_VALOR	+= nZWEVALOR
		ZWE->ZWE_DESC	:= cErro
		ZWE->ZWE_DETAIL := cZWEDETAIL
		ZWE->(msUnLock())
	EndIF
	
	If lShow
		ConOut(StrZero(nxThrd,10)+": "+cEnt+": "+AllTrim(cID)+": "+IIF(cTp="E","Erro",IIF(cTp="W","Advertencia","Log"))+": "+AllTrim(cErro))
	EndIf	

return




/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! Semaforo                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Semáforo de execução dos processos                                            !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 18/09/2019                                                                    !
+------------------+------------------------------------------------------------------s-------------+
*/                                                                                
class Semaforo from LongClassName
data nReg

	method start(cProcess, dDate, cEmp) constructor
	method pos()
	method GetExec(cProcessERP)
	method GetStart()
	method Finish()

endclass



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! start                                                                         !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Inicia a classe de semaforo                                                   !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/  
method start(cProcess, dDate, cEmp) class Semaforo
Local lnew
	// -> Verifica Verifica se o semaforo existe
	dbSelectArea("ZWS")
	ZWS->(DbSetOrder(1))
	ZWS->(DbGoTop())
	ZWS->(DbSeek(xFilial("ZWS")+Space(TamSX3("ZWS_XFILIA")[1])+cProcess+":"+cEmp))
	lnew:=!ZWS->(Found())

	// -> Inclui semáforo
	If lnew
		ConOut("==>SEMAFORO: "+AllTrim(cProcess) + ": ON")
		RecLock("ZWS",.T.)
		ZWS->ZWS_FILIAL := xFilial("ZWS")
		ZWS->ZWS_PROCES := cProcess+":"+cEmp
		ZWS->ZWS_DTPROC := dDate
		ZWS->ZWS_STATUS := "S"
		ZWS->ZWS_INF    := "Semaforo ON"
		ZWS->(MsUnLock())
	EndIf	

	// -> salva o registro
	::nReg  :=ZWS->(Recno())

return



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! pos                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Prosiciona no registro do log                                                 !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method pos() class Semaforo

	If ::nReg == nil
		::nReg:=-1
	EndIf
	
	ZWS->(DbGoTo(::nReg ))
	
return


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! getExec                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Metodo para retornar se o processo está em execução                           !
!                  ! Utilizado para validar a execução em modo exclusivo                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method GetExec(cProcessERP) class Semaforo
Local lRet:=.T.

	::pos()

	If ZWS->ZWS_STATUS == "E"
		ConOut("==>SEMAFORO: "+AllTrim(ZWS->ZWS_PROCES)+" em "+DtoC(ZWS->ZWS_DTPROC) + ": Em execucao, verifique o log do processo "+cProcessERP)
		lRet:=.F.
	EndIf

Return lRet



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GetStart                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Marca inicio do processamento                                                 !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method GetStart() class Semaforo

	::pos()

	RecLock("ZWS",.F.)
	ZWS->ZWS_STATUS := "E"
	ZWS->ZWS_INF    := "Semaforo START"
	ZWS->(MsUnLock())
	
	ConOut("==>SEMAFORO: "+AllTrim(ZWS->ZWS_PROCES)+" em "+DtoC(ZWS->ZWS_DTPROC) + ": START")

Return()


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! Finish                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Finaliza o semaforo e libera para próxima execução                            !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
method Finish() class Semaforo

	::pos()

	RecLock("ZWS",.F.)
	ZWS->ZWS_STATUS := "F"
	ZWS->ZWS_INF    := "Semaforo OFF"
	ZWS->(MsUnLock())
	
	ConOut("==>SEMAFORO: "+AllTrim(ZWS->ZWS_PROCES)+" em "+DtoC(ZWS->ZWS_DTPROC) + ": OFF")

Return()