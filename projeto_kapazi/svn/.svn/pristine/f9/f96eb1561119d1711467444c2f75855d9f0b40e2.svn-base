/**********************************************************************************************************************************/
/** SIGACOM - Faturamento                                                                                                        **/
/** PONTO DE ENTRADA PARA RETORNO DO NOME CLIENTE NO CADASTRO DO PEDIDO.                                                                                                         **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi Indústria Brasileira Ltda.                                                                                            **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 15/03/2015 | Marcos Sulivan          | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/**********************************************************************************************************************************/
/** user function WFW120P()                                                                                                      **/
/**********************************************************************************************************************************/
User Function WFW120P()

Local aArea  	 := GetArea()
Local cPedido  :=  PARAMIXB
Local cFornec	 :=		""  


dBselectArea('SC7')
SC7->(dbSetOrder(1))
SC7->(dbSeek(cPedido))

cFornec		:=  Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME") 

SC7->(dbclosearea('SC7'))

DBSelectArea('SCR')
//SCR->(dbSetOrder(3))
SCR->(DbOrderNickName("XDOCUKAP"))
SCR->(DbGoTop())
If (SCR->(dbSeek(cPedido)))
 		WHILE SCR->(!EOF()) .AND. ALLTRIM(xFilial("SCR")+SCR->CR_NUM) == ALLTRIM(cPedido) 
 			RecLock( "SCR" , .F. ) 
			SCR->CR_NOME :=		cFornec 
			SCR->(MsUnLock()) 
			SCR->(DBSkip())
		
		EndDo   
EndIf

SCR->(dbclosearea('SCR'))

RestArea(aArea)

Return nil 