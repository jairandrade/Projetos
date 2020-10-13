#include 'totvs.ch'
#include "fileio.ch"
#include "topconn.ch"
/*---------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina                                                  !
+------------------+---------------------------------------------------------+
!Modulo            ! TAF                                                     !
+------------------+---------------------------------------------------------+
!Nome              ! TAF002                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina para processamento do TAF - ST1 para ST2         !
!		           !                                                         ! 
+------------------+---------------------------------------------------------+
!Atualizado por    ! Márcio A. Zaguetti                                      !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 25/05/2020                                             !
+------------------+--------------------------------------------------------*/
User Function TAF002(cGrupo,nJob,cAliasTop,cDataBase,nPotaTop,nEscopo)
Local cKeyLock :="TAFPROC"+cGrupo
Local cGpPad   := "01"
Local cEmpPag  := "01GDIN0004" 
Local aFili    := {}
Local nx       := 0
                           
    RPcSetType(3) 
    RpcSetEnv(cGpPad,cEmpPag,,,'TAF',GetEnvServer())
    OpenSm0(cGpPad,.f.)    

    // -> Carrega as filiais
    SB0->(DbGotop())
    While !SM0->(Eof())
        If AllTrim(SM0->M0_CODIGO) == AllTrim(cGrupo)
            Aadd(aFili,{SM0->M0_CODIGO,SM0->M0_CODFIL})
        EndIf
        SM0->(DbSkip())
    EndDo
	RpcClearEnv()

    For nx:=1 To Len(aFili)                    

    	ConOut('Filial: '+aFili[nx,02])

	    RPcSetType(3)      
    	RpcSetEnv(aFili[nx,01],aFili[nx,02],,,'TAF',GetEnvServer())
	    OpenSm0(aFili[nx,01],.f.)

	    SM0->(dbSetOrder(1))
	    SM0->(dbSeek(aFili[nx,01]+aFili[nx,02]))
	    cEmpAnt  := SM0->M0_CODIGO
	    cFilAnt  := SM0->M0_CODFIL
        dDataBase:=Date()

		// -> Verifica se o processo está em execução e, se tiver não executa o processo
		cKeyLock :="TAFPROC"+SM0->M0_CODIGO+SM0->M0_CODFIL
		If LockByName(cKeyLock,.F.,.T.)
		    ConOut("==>SEMAFORO: TAFPROC em "+DtoC(Date()) + ": STARTED.")                   
		Else
			ConOut("==>SEMAFORO: TAFPROC em "+DtoC(Date()) + ": RUNNING...")
			RpcClearEnv()
		EndIf

		TAFAInteg({Val(nJob),cAliasTop,cDataBase,cEmpAnt,cFilAnt,Val(nPotaTop),nEscopo})
		RpcClearEnv()

    Next nx         
    KillApp(.T.)

return