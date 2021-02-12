#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Valida acesso aos Ambientes Produtivos não Oficiais.    !                                                  
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 10/05/2020                                              !
+------------------+--------------------------------------------------------*/
User Function ChkExec()
Local lRet       := .T.
Local cEnvProd   := "KAPAZI"   //Environment Produtivo Oficial
Local cDBProd    := "P12_PROD" //Database da Produção
Local cCodUser   := RetCodUsr()
Local cEnvCurren := Upper(AllTrim(GetEnvServer()))
Local cDBCurrent := Upper(AllTrim(GetSrvProfString("DBALIAS",GetSrvProfString("TOPALIAS",""))))

//Se o environment corrente for diferente do Oficial e estiver acessando o DataBase Produtivo -> Avalia Acesso 
If !(cEnvProd == cEnvCurren) .And. cDBCurrent == cDBProd .And. cCodUser <> "000000"
	dbSelectArea("ZBJ")
	ZBJ->(dbSetOrder(1))
	
	If lRet := (ZBJ->(dbSeek(cCodUser)) .And. AllTrim(ZBJ->ZBJ_AMBIEN) == cEnvCurren) 
		If ZBJ->ZBJ_DTLIM < Date() .Or. (ZBJ->ZBJ_DTLIM = Date() .And. ZBJ->ZBJ_HRLIM < SubStr(Time(),1,5))  
			lRet := .F.
		EndIf		
	EndIf
	
	If !lRet
		Final("Usuário " + cCodUser + " sem Acesso ao Ambiente " + Capital(cEnvCurren))
	EndIf	
EndIf

Return lRet

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Cadastro de acessos a ambientes Produtivos não oficiais.!                                                  
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 10/05/2020                                              !
+------------------+--------------------------------------------------------*/
User Function ContrAmb()
Private cCadastro := "Controle de Ambientes"
 
AxCadastro("ZBJ", cCadastro)
Return Nil