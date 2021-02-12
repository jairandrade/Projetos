#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+          
!Descricao         ! Ponto de Entrada após Liberação/Rejeição do crédito.    ! 
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 02/06/2020                                              !
+------------------+--------------------------------------------------------*/ 
User Function MTA450RP
Local aArea    := GetArea()
Local nOpcao   := Paramixb[1]
Local cPedido  := Paramixb[2] //cQuebra

If nOpcao = 1 //Liberação
	U_KFATR15("03",cPedido)
ElseIf nOpcao = 3 //Rejeição	
	U_KFATR15("10",cPedido)
EndIf

RestArea(aArea)
Return Nil