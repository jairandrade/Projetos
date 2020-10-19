#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
/*---------------------------------------------------------------------------+
!                             FICHA TÃNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina                                       			 !
+------------------+---------------------------------------------------------+
!Modulo            ! FINANCEIRO                                             !
+------------------+---------------------------------------------------------+
!Descrico         ! após o cancelamento da baixa.
!				   !	 !
/*-----------------+---------------------------------------------------------+
!Nome              ! FA080CAN!			                                          !
+------------------+---------------------------------------------------------+
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo G. Vieira                                       !
+------------------+--------------------------------------------------------*/

User Function FA080CAN()

	oCompras  := ClassIntCompras():new()    
	
	IF oCompras:registraIntegracao('4',SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA,'E')  
		oCompras:enviaSales()
	elseif !empty(oCompras:cErro)
		ALERT(oCompras:cErro)
	ENDIF  
return
