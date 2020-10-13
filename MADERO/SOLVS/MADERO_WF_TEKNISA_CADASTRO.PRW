/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! FATWF01                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Funcaoo para executar o processo de integracoes dos cadastros em WF           !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Marcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 14/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
#Include 'Protheus.ch'
#Include "topconn.ch"
#Include 'Protheus.ch'
#Include "topconn.ch"
        
User Function FATWF01(aEmpresa)
Local aEmp   	:= {}
Local cEmp      := aEmpresa[01] //AllTrim(GetSrvProfString('Empresa',''))
Local cFil      := aEmpresa[02] //AllTrim(GetSrvProfString('Filiais',''))
Local nx 		:= 0
Local nAux      := 0
Local cKeyLock  := "TEK01"+aEmpresa[01]+aEmpresa[02]

	nAux:=ThreadId()
	ConOut("The process "+AllTrim(Str(nAux))+" has been started.")

	// -> Executa o processo para todas as empresas selecionadas
	Aadd(aEmp,{cEmp,cFil})
	nx:=1 

    // -> Verifica se os dados da filial e empresa estão preenchidos
	If Empty(aEmp[nx,1]) .or. Empty(aEmp[nx,2])
		ConOut(": Parametros de empresa e filial invalidos. Favor verifique os parametros 'Empresa' e 'Filiais' no arquivo appserver.ini.")
		Return("")
	EndIf

	RpcClearEnv()
	RPcSetType(3)
    RpcSetEnv( aEmp[nx,1],aEmp[nx,2], , ,'FAT' , GetEnvServer() )
    OpenSm0(aEmp[nx,1], .f.)
	nModulo := 5

	    // -> Posiciona na empresa / filial
	    DbSelectArea("SM0")
	    SM0->(DbSetOrder(1))
		SM0->(DbSeek(aEmp[nx,1]+aEmp[nx,2]))
	    cEmpAnt:=SM0->M0_CODIGO
	    cFilAnt:=SM0->M0_CODFIL

		If LockByName(cKeyLock,.F.,.T.)
			ConOut("==>SEMAFORO: TEK01 em "+DtoC(Date()) + ": STARTED...")
		Else
			RpcClearEnv()
			ConOut("==>SEMAFORO: TEK01 em "+DtoC(Date()) + ": RUNNING...")
			nAux:=ThreadId()
			ConOut("The process "+AllTrim(Str(nAux))+" has been finished.")
			KillApp(.T.)
			Return("")
		EndIf

	    // -> Cadastro de unidades de negócio
	    u_TkPutUnid(.T.)           
	    	
	    // -> Cadastro de recebimentos
	    u_TkPutReceb(.T.)
                                          
		// -> Cadastro de produtos
        u_TkPutProds(.T.)

		// -> Ativacao de produtos
        u_TkPutPAt(.T.)  
                                      
        // -> Cadastro de impostos
        u_TkPutImp(.T.)           
            
        // -> Cadastro de estrutura de producao
        u_TkPutCompo(.T.)
            
        // -> Cadastro de clientes
        u_TkPutClie(.T.)
		
		// -> Destava execucao da rotina
		UnLockByName(cKeyLock,.F.,.T.)
	
	RpcClearEnv()
	ConOut("==>SEMAFORO: TEK01 em "+DtoC(Date()) + ": FINISHED...")
	nAux:=ThreadId()
	ConOut("The process "+AllTrim(Str(nAux))+" has been finished.")
	KillApp(.T.)

Return()