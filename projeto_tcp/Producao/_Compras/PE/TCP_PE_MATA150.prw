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
!Descricao         ! Pontos de entrada da Rotina de Atualização de Cotações  !
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
! MT150NPA para verificar se a cotação não  !           !           !        !
! esta cancelada.                           !           !           !        !
+-------------------------------------------+-----------+-----------+-------*/
#INCLUDE 'protheus.ch'
#INCLUDE "rwmake.ch" 

/*-----------+--------------+-------+--------------------+------+-------------+
! Função     ! MT150ROT     ! Autor ! Alexandre Effting  ! Data !  18/03/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Parâmetros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  ! Este ponto é utilizado para Adicionar mais opções no aRotina   !
+------------+---------------------------------------------------------------*/
User Function MT150ROT()
	
AAdd( aRotina, { 'GED.TCP'          , "U_TCPGED", 0, 4 } )
AAdd( aRotina, { 'Re-enviar Cotação', "U_MCOM008", 0, 5 } )
AAdd( aRotina, { 'Cancelar Cotação' , "U_MCOM007", 0, 6 } )
	
Return aRotina

/*-----------+--------------+-------+--------------------+------+-------------+
! Função     ! MT150LEG     ! Autor ! Lucas J. C. Chagas ! Data !  30/05/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Parâmetros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  ! Este ponto é utilizado para Adicionar mais opções no aRotina   !
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
	aAdd(aRet,{"BR_PRETO"	,"Cotação Cancelada"})
	aAdd(aRet,{"BR_MARROM"	,"Produto químico - Homologação vencida no prazo"})
	aAdd(aRet,{"PMSEDT4"	,"Produto químico - Fornecedor não homologado nesta data"})
endif
 
RestArea(aArea)

Return aRet

/*-----------+--------------+-------+--------------------+------+-------------+
! Função     ! MT150NPA     ! Autor ! Lucas J. C. Chagas ! Data !  30/05/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Parâmetros !                                                                !
+------------+----------------------------------------------------------------+
! Retorno    ! lRet -> .T. Continua a rotina | .F. não processa os dados      !
+------------+----------------------------------------------------------------+
! Descricao  ! Ponto de entrada para novs participantes, retorna se continua  !
!            ! ou na a sequencia da rotina.                                   !
+------------+---------------------------------------------------------------*/

//*****************************************************//
//*****************************************************//
//*****************************************************//
// ROTINA COMENTADA PARA EXECUTAR VALIDAÇÃO DO CONTRATO//
// MARIO FARIA - 02/08/2013                            //
// DEVERÁ SER RETORNADA QUANDO FOR COLOCADA EM         //
// PRODUÇAO AS CUSTOMIZAÇÕES DO WEB SERVICE DE         //
// COTAÇÕES                                            //
//*****************************************************//
//*****************************************************//
//*****************************************************//

User Function MT150NPA()

Local aArea := GetArea()
Local lRet := U_MCOM004()

RestArea(aArea)

return !lRet

/*-----------+--------------+-------+--------------------+------+-------------+
! Função     ! MT150ENV     ! Autor ! Lucas J. C. Chagas ! Data !  30/05/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Parâmetros !                                                                !
+------------+----------------------------------------------------------------+
! Retorno    ! lRet -> .T. Continua a rotina | .F. não processa os dados      !
+------------+----------------------------------------------------------------+
! Descricao  ! Ponto de entrada para atualizacao e proposta, retorna se a ro- !
!            ! tina continua ou não.                                          !
+------------+---------------------------------------------------------------*/

//*****************************************************//
//*****************************************************//
//*****************************************************//
// ROTINA COMENTADA PARA EXECUTAR VALIDAÇÃO DO CONTRATO//
// MARIO FARIA - 02/08/2013                            //
// DEVERÁ SER RETORNADA QUANDO FOR COLOCADA EM         //
// PRODUÇAO AS CUSTOMIZAÇÕES DO WEB SERVICE DE         //
// COTAÇÕES                                            //
//*****************************************************//
//*****************************************************//
//*****************************************************//

User Function MT150ENV()

Local aArea := GetArea()
Local lRet := U_MCOM004()
     
	If Posicione('SA2',1,xFilial('SA2')+SC8->C8_FORNECE+SC8->C8_LOJA,"A2_BLQFOR") == '1'
		Alert('A cotação não pode ser acessada pois o  Fornecedor está bloqueado devido a baixa classificação!')     
		lRet	:= .F.            
	EndIf    
                  

RestArea(aArea)

return !lRet

/*-----------+--------------+-------+--------------------+------+-------------+
! Função     ! MT150SCR     ! Autor ! Mário L. B. Faria  ! Data !  02/08/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Parâmetros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  ! Ponto de entrada encontra-se na rotina que monta a dialog da   !
!            ! atualização da cotação de compra logo após a montagem dos      !
!            ! folders, disponibiliza como parâmetro o Objeto da dialog 'oDlg'!
!            ! para manipulação do usuário.                                   !
+------------+---------------------------------------------------------------*/
User Function MT150SCR()
	
	Local aArea 	:= GetArea()
	Local aItens 	:= {"N=Não","S=Sim"}
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
! Função     ! MT150GRV     ! Autor ! Mário L. B. Faria  ! Data !  02/08/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Parâmetros !                                                                !
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
