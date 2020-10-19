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
!Modulo            ! GenErico                                             !
+------------------+---------------------------------------------------------+
!Descrico         ! Envia integração apra o Sales em casos que é bom garantir que não apareça erro na tela.
!				   !	 !
/*-----------------+---------------------------------------------------------+
!Nome              ! MNSINTEG!			                                          !
+------------------+---------------------------------------------------------+
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo G. Vieira                                       !
+------------------+--------------------------------------------------------*/

User Function VALIDSC()
local nX := 1
lOCAL nPosRat := aScan(aHeader,{|x| AllTrim(x[2])=="C1_RATEIO"})
lOCAL nPosCC := aScan(aHeader,{|x| AllTrim(x[2])=="C1_CC"})
lOCAL nPosConta := aScan(aHeader,{|x| AllTrim(x[2])=="C1_CONTA"})

IF LEN(aRatSC) > 0 .AND. l110Auto
	aCols[n][nPosCC] := SPACE(9) 
	aCols[n][nPosConta] := SPACE(20) 
ENDIF

IF nPosConta > 0 .AND. aCols[n][nPosConta] != ''
	dbSelectArea('CT1')
	CT1->(DBSetOrder(1))
	IF !CT1->(DbSeek(xFilial('CT1')+aCols[n][nPosConta]))
		aCols[n][nPosConta] := SPACE(20) 
	endif
ENDIF

return .T.