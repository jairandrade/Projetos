/*
+----------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Ponto de entrada                                        !
+------------------+---------------------------------------------------------+
!Modulo            ! Compras                                                 !
+------------------+---------------------------------------------------------+
!Nome              ! TCP_PE_MATA120                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! Pontos de entrada da Rotina de Pedido de Compras        !
+------------------+---------------------------------------------------------+
!Autor             ! Mário Lúcio Blasi Faria                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 19/07/2013                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES   !                                                         !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

#INCLUDE 'protheus.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
+-----------------------------------------------------------------------------+
! Função     ! MT120TEL     ! Autor ! Mário Faria        ! Data !  19/07/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Parâmetros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  ! Este ponto de entrada se encontra dentro da rotina que monta   !
!            ! a dialog do pedido de compras antes  da montagem dos folders   !
!            ! e da chamada da getdados.                                      !
+------------+----------------------------------------------------------------+
*/
User Function MT120TEL()

	Local aArea := GetArea()

	AADD( aTitles, "Obs. Adicionais" )

	RestArea(aArea)

Return

/*
+-----------------------------------------------------------------------------+
! Função     ! MT120FOL     ! Autor ! Mário Faria        ! Data !  19/07/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Parâmetros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  !                                                                !
+------------+----------------------------------------------------------------+
*/
User Function MT120FOL()

	Local aArea   	:= GetArea()
	Local oCboCont	:= Nil
	Local nOpc    	:= PARAMIXB[1]
	Local aPosGet 	:= PARAMIXB[2]
	Local aItens 	:= {"N=Não","S=Sim"}

	Public cContra := ""

	IF (!INCLUI, cContra := SC7->C7_CONTRAT, cContra := "N")

	If nOpc <> 1
	    @ 006,aPosGet[1,1] SAY OemToAnsi("Contrato") OF oFolder:aDialogs[7] PIXEL SIZE 070,009
	    @ 005,aPosGet[1,2] COMBOBOX oCboCont VAR cContra ITEMS aItens OF oFolder:aDialogs[7] PIXEL SIZE 050,009
	Endif

	RestArea(aArea)

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} MT120OK
Função para validação dos campos de fornecedor

@return
@author Felipe Toazza Caldeira
@since 03/09/2015

/*/
//-------------------------------------------------------------------------------
User Function MT120OK

	Local aArea   	:= GetArea()
	Local lRet := .T.

	if nMoedaPed != 1
		Posicione('SM2',1,DTOS(dA120Emis),"M2_MOEDA2")
		_nValTot := XMOEDA(1,nMoedaPed,1,dA120Emis,2,nTxMoeda)
		if _nValTot <= 0 
			 FwClearHLP()
			 Help(NIL, NIL, "Cotação de moeda estrangeira.", NIL, "Não existe cotação atual para a moeda utilizada!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Preencha a Taxa da moeda no pedido, ou solicite que o financeiro preencha a taxa correta."})
   
			lRet := .F.
		endif
	endif	     
	
	IF lRet
		If Posicione('SA2',1,xFilial('SA2')+cA120FORN+cA120LOJ,"A2_BLQFOR") == '1'
			Help(NIL, NIL, "Fornecedor Bloqueado", NIL, "Este fornecedor está bloqueado devido a baixa classificaçãos", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Corrija o cadastro."})
	   
			lRet := .F.
		EndIf
	endif	
	RestArea(aArea)
	
Return lRet     //001550

