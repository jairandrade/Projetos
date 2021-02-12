#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMBROWSE.CH"

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Ponto de Entrada para adicionar filtro na liberação de  !
!                  ! Crédito/Estoque.                                        ! 
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 20/05/2020                                              !
+------------------+--------------------------------------------------------*/
User Function M456FIL()
Local cRet := ".F."

If SuperGetMv("KP_BLQM456",,.T.)
	//Por ser o 1º PE executado na rotina MATA456, foi implementado a restrição de acesso nesse ponto
	//Optado por desenvolver a restrição ao invés bloquear via acesso/menu
	Final("Rotina Bloqueada (Contate o Administrador).")
Else
	cRet := ""
EndIf

Return cRet