#INCLUDE "PROTHEUS.CH"
/*---------------------------------------------------------------------------+
!                             FICHA T�CNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina                                       			 !
+------------------+---------------------------------------------------------+
!M�dulo            ! FINANCEIRO                                              !
+------------------+---------------------------------------------------------+
!Descri��o         ! PE AP�S A BAIXA AUTOM�TICA DE BORDER�                                 !
/*-----------------+---------------------------------------------------------+
!Nome              ! FA090TX                                                 !			                                          
+------------------+---------------------------------------------------------+
+------------------+---------------------------------------------------------+
!Autor             !                                                         !
+------------------+--------------------------------------------------------*/



User Function FA090TX()
 	oCompras  := ClassIntCompras():new()    
	
	IF oCompras:registraIntegracao('4',SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA,'I')  
		oCompras:enviaSales()
	elseif !empty(oCompras:cErro)
		ALERT(oCompras:cErro)
	ENDIF  
RETURN