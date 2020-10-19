/*---------------------------------------------------------------------------+ 
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Ponto de entrada                                        !
+------------------+---------------------------------------------------------+
!Modulo            ! Compras                                                 !
+------------------+---------------------------------------------------------+
!Nome              ! TCP_PE_MATA150                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! Pontos de entrada da Rotina de Atualiza��o de Cota��es  !
+------------------+---------------------------------------------------------+
!Autor             ! Alexandre Effting                                       !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 18/03/2013                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES   !                                                         !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
! Alterada rotina MT150ROT para adicao de   ! Fernando  ! Lucas     ! 29/05/ !
! rotinas de Reenvio de cotacao e Cancela-  ! Nonato    ! Chagas    ! 2013   !
! mento de cotacao.                         !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
! Adicionada rotina MT150LEG para adicao de ! Fernando  ! Lucas     ! 30/05/ !
! legenda a rotina.                         ! Nonato    ! Chagas    ! 2013   !
!                                           !           !           !        !
! Adicionado ponto de entrada MT150ENV e    !           !           !        !
! MT150NPA para verificar se a cota��o n�o  !           !           !        !
! esta cancelada.                           !           !           !        !
+-------------------------------------------+-----------+-----------+-------*/
#INCLUDE 'protheus.ch'
#INCLUDE "rwmake.ch" 

/*-----------+--------------+-------+--------------------+------+-------------+
! Fun��o     ! MT150ROT     ! Autor ! Alexandre Effting  ! Data !  18/03/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Par�metros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  ! Este ponto � utilizado para Adicionar mais op��es no aRotina   !
+------------+---------------------------------------------------------------*/
User Function MT150ROT()
	
AAdd( aRotina, { 'GED.TCP'          , "U_TCPGED", 0, 4 } )
AAdd( aRotina, { 'Re-enviar Cota��o', "U_MCOM008", 0, 5 } )
AAdd( aRotina, { 'Cancelar Cota��o' , "U_MCOM007", 0, 6 } )
	
Return aRotina

/*-----------+--------------+-------+--------------------+------+-------------+
! Fun��o     ! MT150LEG     ! Autor ! Lucas J. C. Chagas ! Data !  30/05/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Par�metros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  ! Este ponto � utilizado para Adicionar mais op��es no aRotina   !
+------------+---------------------------------------------------------------*/
User Function MT150LEG()

Local aArea := GetArea()
Local aRet  := {}
Local nOpcA := ParamIXB[1]

if nOpcA == 1
	aAdd(aRet,{"!Empty(C8_MOTCAN) .AND. !Empty(C8_USUCAN) .AND. !Empty(C8_DTCANC)"	,"BR_PRETO"	 })
	Aadd(aRet,{"C8_XHOMFOR $ 'VE|NH' "										  		,"PMSEDT4"	 })
	Aadd(aRet,{"EMPTY(C8_NUMPED) .AND. C8_XHOMFOR == 'AP' "							,"BR_MARROM" })
else
	aAdd(aRet,{"BR_PRETO"	,"Cota��o Cancelada"})
	aAdd(aRet,{"BR_MARROM"	,"Produto qu�mico - Homologa��o vencida no prazo"})
	aAdd(aRet,{"PMSEDT4"	,"Produto qu�mico - Fornecedor n�o homologado nesta data"})
endif
 
RestArea(aArea)

Return aRet

/*-----------+--------------+-------+--------------------+------+-------------+
! Fun��o     ! MT150NPA     ! Autor ! Lucas J. C. Chagas ! Data !  30/05/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Par�metros !                                                                !
+------------+----------------------------------------------------------------+
! Retorno    ! lRet -> .T. Continua a rotina | .F. n�o processa os dados      !
+------------+----------------------------------------------------------------+
! Descricao  ! Ponto de entrada para novs participantes, retorna se continua  !
!            ! ou na a sequencia da rotina.                                   !
+------------+---------------------------------------------------------------*/

//*****************************************************//
//*****************************************************//
//*****************************************************//
// ROTINA COMENTADA PARA EXECUTAR VALIDA��O DO CONTRATO//
// MARIO FARIA - 02/08/2013                            //
// DEVER� SER RETORNADA QUANDO FOR COLOCADA EM         //
// PRODU�AO AS CUSTOMIZA��ES DO WEB SERVICE DE         //
// COTA��ES                                            //
//*****************************************************//
//*****************************************************//
//*****************************************************//

User Function MT150NPA()

Local aArea := GetArea()
Local lRet := U_MCOM004()

RestArea(aArea)

return !lRet

/*-----------+--------------+-------+--------------------+------+-------------+
! Fun��o     ! MT150ENV     ! Autor ! Lucas J. C. Chagas ! Data !  30/05/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Par�metros !                                                                !
+------------+----------------------------------------------------------------+
! Retorno    ! lRet -> .T. Continua a rotina | .F. n�o processa os dados      !
+------------+----------------------------------------------------------------+
! Descricao  ! Ponto de entrada para atualizacao e proposta, retorna se a ro- !
!            ! tina continua ou n�o.                                          !
+------------+---------------------------------------------------------------*/

//*****************************************************//
//*****************************************************//
//*****************************************************//
// ROTINA COMENTADA PARA EXECUTAR VALIDA��O DO CONTRATO//
// MARIO FARIA - 02/08/2013                            //
// DEVER� SER RETORNADA QUANDO FOR COLOCADA EM         //
// PRODU�AO AS CUSTOMIZA��ES DO WEB SERVICE DE         //
// COTA��ES                                            //
//*****************************************************//
//*****************************************************//
//*****************************************************//

User Function MT150ENV()

Local aArea := GetArea()
Local lRet := U_MCOM004()
     
	If Posicione('SA2',1,xFilial('SA2')+SC8->C8_FORNECE+SC8->C8_LOJA,"A2_BLQFOR") == '1'
		Alert('A cota��o n�o pode ser acessada pois o  Fornecedor est� bloqueado devido a baixa classifica��o!')     
		lRet	:= .F.            
	EndIf    
                  

RestArea(aArea)

return !lRet

/*-----------+--------------+-------+--------------------+------+-------------+
! Fun��o     ! MT150SCR     ! Autor ! M�rio L. B. Faria  ! Data !  02/08/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Par�metros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  ! Ponto de entrada encontra-se na rotina que monta a dialog da   !
!            ! atualiza��o da cota��o de compra logo ap�s a montagem dos      !
!            ! folders, disponibiliza como par�metro o Objeto da dialog 'oDlg'!
!            ! para manipula��o do usu�rio.                                   !
+------------+---------------------------------------------------------------*/
User Function MT150SCR()
	
	Local aArea 	:= GetArea()
	Local aItens 	:= {"N=N�o","S=Sim"}
	Local oDlg   	:= PARAMIXB
	Local aAreaSC8 	:= SC8->(GetArea())
	Local cChave	:= xFilial("SC8")+cA150Num+cA150Forn+cA150Loj
	Local nRegno	:= SC8->(RECNO())

	SC8->(dbGoTop())
	SC8->(dbSetOrder(1))
	SC8->(dbSeek(cChave))
	
	Public oCtrAux
	Public cCtrAux := If(Empty(SC8->C8_CONTRAT),"N",SC8->C8_CONTRAT)

	
	@ 020,427 SAY OemToAnsi("Contrato") Of oDlg PIXEL SIZE 040,009
	@ 019,474 COMBOBOX oCtrAux VAR cCtrAux ITEMS aItens OF oDlg PIXEL SIZE 050,009
    
    
	SC8->(dbGoTo(nRegno))

	RestArea(aArea)
	RestArea(aAreaSC8)
	

Return 

/*-----------+--------------+-------+--------------------+------+-------------+
! Fun��o     ! MT150GRV     ! Autor ! M�rio L. B. Faria  ! Data !  02/08/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Par�metros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  ! Ponto de entrada encontra-se apos a atualizacao do SC8         !
+------------+---------------------------------------------------------------*/
User Function MT150GRV()

	Local aArea 	:= GetArea()
	Local aAreaSC8 	:= SC8->(GetArea())
	Local cChave	:= SC8->C8_FILIAL+SC8->C8_NUM+SC8->C8_FORNECE+SC8->C8_LOJA
	

	
	SC8->(dbGoTop())
	SC8->(dbSetOrder(1))
	SC8->(dbSeek(cChave))
	If PARAMIXB[1] = 3
		While !SC8->(EOF()) .And. cChave == SC8->C8_FILIAL+SC8->C8_NUM+SC8->C8_FORNECE+SC8->C8_LOJA 
		
			RecLock("SC8",.F.)	
			SC8->C8_CONTRAT := M->C8_CONTRAT//trAux
			MsUnLock("SC8")
		
			SC8->(dbSkip())
		EndDo
	Endif
	RestArea(aArea)
	RestArea(aAreaSC8)


Return
