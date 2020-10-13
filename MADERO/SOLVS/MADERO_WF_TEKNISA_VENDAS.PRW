/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! FATWF02                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para executar a integração de vendas                                   !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
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
#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "TBICONN.CH"
        
User Function FATWF02(aEmpresa)
Local dDataIni:=Date()
Local dDataFim:=Date()
Local cEmp     := aEmpresa[01]
Local cFil     := aEmpresa[02]
Local dDtStart := IIF(aEmpresa[03]==Nil,CToD("  /  /  "),SToD(aEmpresa[03]))
Local nx       := 0
Local nAux     := 0
Local aParam   := {}
Local aDados   := {}
Local cKeyLock := "TEK02"+aEmpresa[01]+aEmpresa[02]
Local nTamZWVPK:= 0

	nAux:=ThreadId()
	ConOut("The process "+AllTrim(Str(nAux))+"has been started.")

	// -> Executa processo para todas as empresas
	Aadd(aParam,{cEmp,cFil})
	nx:=1
	aDados     := {} 
	dIniAux    := CtoD("  /  /  ")
	cFunNamAnt := FunName()
	SetFunName("FATWF02")

	RPcSetType(3) 
	RpcSetEnv( aParam[nx,1],aParam[nx,2], , ,'FAT' , GetEnvServer() )
    OpenSm0(aParam[nx,1], .f.)
	SM0->(dbSetOrder(1))
	SM0->(dbSeek(aParam[nx,1]+aParam[nx,2]))

	// -> Verifica se o processo está em execução e, se tiver não executa o processo
	If LockByName(cKeyLock,.F.,.T.)
		ConOut("==>SEMAFORO: TEK02 em "+DtoC(Date()) + ": STARTED.")
	Else
		RpcClearEnv()
		ConOut("==>SEMAFORO: TEK02 em "+DtoC(Date()) + ": RUNNING...")
		nAux:=ThreadId()
		ConOut("The process "+AllTrim(Str(nAux))+" has been finished.")
		KillApp(.T.)
		Return("")
	EndIf

	// -> Verifica a data de início do processamento
	dIniAux  :=dDataFim-SuperGetMV("MV_XDVDINT",,2)
	nTamZWVPK:=TamSX3("ZWV_PK")[01]
	If !Empty(dDtStart)
		// -> Pesquisa ponto de lançamento do fechamento do estoque. Se foi finalizado para a dara de start, considera o parâmetro de dias para teroagir a data
		DbSelectArea("ZWV")
    	ZWV->(DbSetOrder(1))
    	ZWV->(DbSeek(xFilial("ZWV")+PADR(DtoS(dDtStart),nTamZWVPK)+"W"))
    	If !ZWV->(Found()) .or. ZWV->ZWV_STATUS == "P" 
		 	dIniAux:=dDtStart
		EndIf
	EndIf

	nModulo := 5
	cEmpAnt := SM0->M0_CODIGO
	cFilAnt := SM0->M0_CODFIL
	dDataIni:= dIniAux	   	
	While dDataIni <= dDataFim

	   	aDados:={}
		aadd(aDados,dDataIni)  
	
		aadd(aDados,aParam[nx,1]) 
		aadd(aDados,aParam[nx,2]) 

		startJob("u_StartVda", GetEnvServer(), .T., aDados)

		dDataIni:=dDataIni+1		

	EndDo
		
	SetFunName(cFunNamAnt)

	// -> Destava execucao da rotina
	UnLockByName(cKeyLock,.F.,.T.)
	RpcClearEnv()
	ConOut("==>SEMAFORO: TEK02 em "+DtoC(Date()) + ": FINISHED...")
	ConOut("The process "+AllTrim(Str(nAux))+" has been finished.")
	nAux:=ThreadId()
	KillApp(.T.)

Return()




 /*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! StartVda                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Inicia job para carga das vendas do teknisa                                   !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 14/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function StartVda(paramixb)
Local dData		:=paramixb[1]
Local cEmp		:=paramixb[2]
Local cFil		:=paramixb[3]
Local aTabelas	:= {"Z01","Z02","Z03","Z04","Z05","ADK","SX5"}	   		   	

	nAux:=ThreadId()
	ConOut("The process "+AllTrim(Str(nAux))+"has been started.")
	
	// -> Inicializa ambiente
	RPcSetType(3) 
	RpcSetEnv(cEmp,cFil, , ,'FAT' , GetEnvServer() , aTabelas)
	
	nModulo  := 5
	dDataBase:= dData     		   	
	
	// -> Posiciona nas eunidades de negócio : Unidade de negócio
	DbSelectArea("ADK")
	ADK->(DbOrderNickName("ADKXFILI"))
	ADK->(ADK->(DbSeek(Space(TamSX3("ADk_FILIAL")[1])+cFilAnt)))

	// -> Vendas
	u_TkGetPed(.T.,dData,dData)            
		 
	// -> Fechamento do caixa
	u_TkGetFec(.T.,dData)
			
	RpcClearEnv()
	
	ConOut("The process "+AllTrim(Str(nAux))+"has been finished.")
	nAux:=ThreadId()
	KillApp(.T.)
	
Return()