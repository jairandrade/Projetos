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
!Descricao         ! Ponto de Entrada para adicionar filtro na libera��o de  !
!                  ! Cr�dito/Estoque.                                        ! 
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 20/05/2020                                              !
+------------------+--------------------------------------------------------*/
User Function M456FIL()
Local cRet := ".F."

If SuperGetMv("KP_BLQM456",,.T.)
	//Por ser o 1� PE executado na rotina MATA456, foi implementado a restri��o de acesso nesse ponto
	//Optado por desenvolver a restri��o ao inv�s bloquear via acesso/menu
	Final("Rotina Bloqueada (Contate o Administrador).")
Else
	cRet := ""
EndIf

Return cRet