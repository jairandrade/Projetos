#Include "Protheus.ch"                                    
#Include "TopConn.CH"
#Include "rwmake.ch"
#Include "TBICONN.CH"
#Include "TryException.CH"

/*----------------+----------------------------------------------------------+
!Nome              ! EST100 - Cliente: Madero                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Execucao dos bobs nas unidades de negócio               !
+------------------+---------------------------------------------------------+
!Autor             ! Marcio Zaguetti                                         !
+------------------+---------------------------------------------------------!
!Data              ! 30/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function EST999(cEmpJob,cFilJob,cExec,cComp,cFTAF)
Local aParam   :={cEmpJob,cFilJob}
Local cKeyLock :="TAF"+cEmpJob+cFilJob

     // -> Executa processo de inventário
     If "INV" $ cExec
         aErroProc:=StartJob("U_EST551", GetEnvServer(), .F.,{aParam[01],aParam[02],cComp})
     EndIf

     // -> Executa processo de MRP
     If "MRP" $ cExec
        aErroProc:=StartJob("U_EST100", GetEnvServer(), .F.,{aParam[01],aParam[02],cComp})
     EndIf
   
     // -> Executa processo integração Teknisa - Cadastros
     If "TEK01" $ cExec
        aErroProc:=StartJob("U_FATWF01", GetEnvServer(), .F.,{aParam[01],aParam[02],cComp})
     EndIf

     // -> Executa processo integração Teknisa - Vendas
     If "TEK02" $ cExec
        aErroProc:=StartJob("U_FATWF02", GetEnvServer(), .F.,{aParam[01],aParam[02],cComp})
     EndIf

     // -> Executa processo integração Teknisa - ERP
     If "TEK03" $ cExec
        aErroProc:=StartJob("U_FAT300", GetEnvServer(), .F.,{aParam[01],aParam[02],cComp})
     EndIf

    // -> Executa processo DOCFIS
    If "DOCFIS" $ cExec
       aErroProc:=StartJob("U_NFEJob", GetEnvServer(), .F.,aParam[01],aParam[02])
    EndIf

    // -> Executa processo de importação dos arquivos do DDA
    If "DDA" $ cExec
       aErroProc:=StartJob("FINA435",GetEnvServer(),.F.,{aParam[01],aParam[02]})
    EndIf

    // -> Executa processo de integração com o TAF
    If "TAF" $ cExec
        aErroProc:=StartJob("u_xTafExt", GetEnvServer(), .F.,{cEmpJob,cFilJob,cFTAF})
    EndIf 

    // -> Executa processo de medição de contratos
    If "CNT" $ cExec
        aErroProc:=StartJob("u_xCNTMed", GetEnvServer(), .F.,{cEmpJob,cFilJob})
    EndIf 

    // -> Executa processo de importação de pedidos de compras
    If "IMPSC7" $ cExec
        aErroProc:=StartJob("u_xComx005", GetEnvServer(), .F.,{cEmpJob,cFilJob})
    EndIf 

Return("")




/*-----------------+---------------------------------------------------------+
!Nome              ! xTafExt                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Executa extrator do TAF                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Marcio Zaguetti                                         !
+------------------+---------------------------------------------------------!
!Data              ! 30/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function xTafExt(aEmpresa)
Local aParam   :={aEmpresa[01],aEmpresa[02]}
Local cKeyLock :="TAF"+aEmpresa[01]+aEmpresa[02]
Local nAux     :=0 
Local aParamTAF:={}
Local nHandle  :=0
Local cLine    :=""
Local aAux     :=""


CONOUT("EMPRESA:"+aEmpresa[01])
CONOUT("FILIAL :"+aEmpresa[02])

    // -> Carrega arquivos de configuração do extrator
    If !File("\"+aEmpresa[03]) 
    	ConOut("Arquivo de ocnfiguracao do TAF nao encontrado na pasta Protheus_Data:"+aEmpresa[03])
        Return("")
    EndIf   

    nHandle := FT_FUse("\"+aEmpresa[03])
    If nHandle = -1
       ConOut("Erro na abertura do arquivo "+aEmpresa[03])
       Return("")
    Endif

    FT_FGoTop()
    While !FT_FEOF()
        cLine:=AllTrim(FT_FReadLn())
        aAux :=StrToKarr(cLine,"%")
        If Len(aAux) >= 2
            aAux :=StrToKarr(aAux[02],">")
            If Len(aAux) > 0
                If SubStr(aAux[01],1,3) == "PAR"
                    aAdd(aParamTAF,AllTrim("MV_"+aAux[01]))
                EndIf
            Endif
        EndIf
        FT_FSKIP()
    EndDo
    FT_FUSE()
 
    nAux:=ThreadId()
	ConOut("The TAF process "+AllTrim(Str(nAux))+"has been started.")

    RPcSetType(3) 
    RpcSetEnv(aParam[01],aParam[02],,,'FIS',GetEnvServer())
    OpenSm0(aParam[01],.f.)
	SM0->(dbSetOrder(1))
	SM0->(dbSeek(aParam[01]+aParam[02]))
    nModulo  := 9
	cEmpAnt  := SM0->M0_CODIGO
	cFilAnt  := SM0->M0_CODFIL
    dDataBase:=Date()

	// -> Verifica se o processo está em execução e, se tiver não executa o processo
	If LockByName(cKeyLock,.F.,.T.)
		ConOut("==>SEMAFORO: TAF em "+DtoC(Date()) + ": STARTED.")
	Else
		RpcClearEnv()
		ConOut("==>SEMAFORO: TAF em "+DtoC(Date()) + ": RUNNING...")
		nAux:=ThreadId()
		ConOut("The process "+AllTrim(Str(nAux))+"has been finished.")
		KillApp(.T.)
		Return("")
	EndIf

    // -> Parâmetros do Extrator fiscal: Fiscal -> Miscelanea -> Arquivos mangneticos -> Extrator fiscal
    For nAux:=1 to Len(aParamTAF)
        &(aParamTAF[nAux])
    Next nAux

    // -> Verifica os parâmetros
    If Len(aParamTAF) <= 0        
        ConOut("Nao encontrado parametos configurado no aruivo "+aEmpresa[03])
        RpcClearEnv()
		nAux:=ThreadId()
		ConOut("The process "+AllTrim(Str(nAux))+"has been finished.")
		KillApp(.T.)
		Return("")
    EndIf    

    // -> Executa a função do extartor fiscal
    FisaExtExc({})

    // -> Destava execucao da rotina
	UnLockByName(cKeyLock,.F.,.T.)
	RpcClearEnv()
	ConOut("==>SEMAFORO: TAF em "+DtoC(Date()) + ": FINISHED...")
	ConOut("The process "+AllTrim(Str(nAux))+"has been finished.")
	nAux:=ThreadId()
	KillApp(.T.)

Return()





/*-----------------+---------------------------------------------------------+
!Nome              ! xCNTMed                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Executa medição de contrtos                             !
+------------------+---------------------------------------------------------+
!Autor             ! Marcio Zaguetti                                         !
+------------------+---------------------------------------------------------!
!Data              ! 30/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function xCNTMed(aEmpresa)
Local aParam   :={aEmpresa[01],aEmpresa[02]}
Local cKeyLock :="CNT"+aEmpresa[01]+aEmpresa[02]
Local nAux     := 0
Local lRet     := .F.

    nAux:=ThreadId()
	ConOut("The CNT process "+AllTrim(Str(nAux))+" has been started.")

    RpcSetType(3)
	RpcSetEnv(aParam[01],aParam[02],,,"GCT","CNTA260",{'CN9','CNA','CNB','CND','CNE'})

	// -> Verifica se o processo está em execução e, se tiver não executa o processo
	If LockByName(cKeyLock,.F.,.T.)
		ConOut("==>SEMAFORO: CNT em "+DtoC(Date()) + ": STARTED.")
	Else
		RpcClearEnv()
		ConOut("==>SEMAFORO: CNT em "+DtoC(Date()) + ": RUNNING...")
		nAux:=ThreadId()
		ConOut("The CNT process "+AllTrim(Str(nAux))+" has been finished.")
		KillApp(.T.)
		Return(lRet)
	EndIf

    lRet := !CN260Exc(.T.)

    // -> Destava execucao da rotina
	UnLockByName(cKeyLock,.F.,.T.)
	RpcClearEnv()
	ConOut("==>SEMAFORO: CNT em "+DtoC(Date()) + ": FINISHED...")
	ConOut("The CNT process "+AllTrim(Str(nAux))+" has been finished.")
	nAux:=ThreadId()
	KillApp(.T.)

Return(lRet)




/*-----------------+---------------------------------------------------------+
!Nome              ! xComx005                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Executa importacao de pedidos de compras                !
+------------------+---------------------------------------------------------+
!Autor             ! Marcio Zaguetti                                         !
+------------------+---------------------------------------------------------!
!Data              ! 10/09/2020                                              !
+------------------+--------------------------------------------------------*/
User Function xComx005(aEmpresa)
Local aParam   :={aEmpresa[01],aEmpresa[02]}
Local cKeyLock :="IMPSC7"+aEmpresa[01]+aEmpresa[02]
Local nAux     := 0
Local lRet     := .F.

    nAux:=ThreadId()
	ConOut("The IMPSC7 process "+AllTrim(Str(nAux))+" has been started.")

    RPcSetType(3) 
    RpcSetEnv(aParam[01],aParam[02],,,'COM',GetEnvServer())
    OpenSm0(aParam[01],.f.)
	SM0->(dbSetOrder(1))
	SM0->(dbSeek(aParam[01]+aParam[02]))
    nModulo  := 2
	cEmpAnt  := SM0->M0_CODIGO
	cFilAnt  := SM0->M0_CODFIL
    dDataBase:=Date()

	// -> Verifica se o processo está em execução e, se tiver não executa o processo
	If LockByName(cKeyLock,.F.,.T.)
		ConOut("==>SEMAFORO: IMPSC7 em "+DtoC(Date()) + ": STARTED.")
	Else
		RpcClearEnv()
		ConOut("==>SEMAFORO: IMPSC7 em "+DtoC(Date()) + ": RUNNING...")
		nAux:=ThreadId()
		ConOut("The IMPSC7 process "+AllTrim(Str(nAux))+" has been finished.")
		KillApp(.T.)
		Return(lRet)
	EndIf

    StartJob("U_COMX005", GetEnvServer(),.F.,{aParam[01],aParam[02],})

    // -> Destava execucao da rotina
	UnLockByName(cKeyLock,.F.,.T.)
	RpcClearEnv()
	ConOut("==>SEMAFORO: IMPSC7 em "+DtoC(Date()) + ": FINISHED...")
	ConOut("The IMPSC7 process "+AllTrim(Str(nAux))+" has been finished.")
	nAux:=ThreadId()
	KillApp(.T.)

Return(lRet)