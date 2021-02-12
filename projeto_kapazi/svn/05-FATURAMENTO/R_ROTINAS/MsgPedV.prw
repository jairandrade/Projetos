#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Processa Mensagens do Pedido de Venda conforme fÓrmulas !
!                  ! cadastradas no parâmetro KP_MSGPEDV.                    !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 05/10/2020                                              !
+------------------+--------------------------------------------------------*/
User Function MsgPedV()
Local aArea     := GetArea()
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
Local aAreaSM4  := SM4->(GetArea())
Local aFormulas := Separa(SuperGetMv("KP_MSGPEDV",,""), ";")
Local cMensagem := "" 
Local cRet      := ""
Local nX        := 0  

dbSelectArea("SM4")
SM4->(dbSetOrder(1))

For nX := 1 To Len(aFormulas)
	SM4->(dbSetOrder(1))
	If SM4->(dbSeek(xFilial("SM4")+aFormulas[nX]))
		cMensagem := Formula(aFormulas[nX])
		
		If ValType(cMensagem) == "C" .And. !Empty(cMensagem)
			cRet += Iif(!Empty(cRet), " - ", "") + cMensagem
		EndIf 
	EndIf
Next nX

RestArea(aAreaSM4)
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aArea)
Return cRet

/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Calandrine Maximiliano                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Retorna mensagem para Pedidos com Produtos Sanitizantes.!
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 05/10/2020                                              !
+------------------+--------------------------------------------------------*/
User Function MsgSanit()
Local aArea      := GetArea()
Local aAreaSC5   := SC5->(GetArea())
Local aAreaSC6   := SC6->(GetArea())
Local aAreaSB1   := SB1->(GetArea())
Local cRet       := ""
Local cKPGrpSani := SuperGetMv("KP_GRPSANI",,"") 

dbSelectArea("SC6")
SC6->(dbSetOrder(1))
dbSelectArea("SB1")
SB1->(dbSetOrder(1))
If SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))						
	While !SC6->(Eof()) .And. SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+SC5->C5_NUM
		If SB1->(dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)) .And. SB1->B1_GRUPO $ cKPGrpSani
			cRet := "*NAO ACEITAMOS DEVOLUCOES E TROCAS PARA TODA LINHA DE TAPETES SANITIZANTES."
			Exit
		EndIf
		SC6->(dbSkip())
	EndDo
EndIf

RestArea(aAreaSB1)
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aArea)
Return cRet







