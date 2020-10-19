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
!Modulo            ! financeiro                                             !
+------------------+---------------------------------------------------------+
!Descrico         ! após a baixa .
!				   !	 !
/*-----------------+---------------------------------------------------------+
!Nome              ! SE5FI080!			                                          !
+------------------+---------------------------------------------------------+
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo G. Vieira                                       !
+------------------+--------------------------------------------------------*/

User Function SE5FI080()
Local cCamposE5 := PARAMIXB[1]

Local oSubModel := PARAMIXB[2]

If oSubModel:cID == "FK2DETAIL"

    oCompras  := ClassIntCompras():new()    
	
	IF oCompras:registraIntegracao('4',SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA,'I')  
		oCompras:enviaSales()
	elseif !empty(oCompras:cErro)
		ALERT(oCompras:cErro)
	ENDIF  

EndIf

Return cCamposE5
	
