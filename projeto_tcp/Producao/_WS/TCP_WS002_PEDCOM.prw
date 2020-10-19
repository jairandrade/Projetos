/*
+----------------------------------------------------------------------------+
!                          FICHA TECNICA DO PROGRAMA                         !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! WebService                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Compras	                                             !
+------------------+---------------------------------------------------------+
!Descricao         ! WebService para retorno de informações de pedidos de	 !
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Clederson Bahl e Dotti									 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 29/10/2014												 !
+------------------+---------------------------------------------------------+
!                               ATUALIZACOES                                 !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !  Nome do  ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

#include "PROTHEUS.CH"
#include "APWEBSRV.CH"
#include "APWEBEX.CH"
#INCLUDE "TOPCONN.CH"

wsservice wsPWSPEDCOMTCP description "Webservice para tratamento de pedidos de compra - TCP"

	// DECLARACAO DAS VARIVEIS GERAIS
	wsdata sFILIAL as string
	wsdata sNUMPED as string
	wsdata sNUMFLG as string
	wsdata sSTATUS as string

	// DECLARACAO DAS ESTRUTURAS DE RETORNO
	wsdata oAprovacao as PWSAprovacao_Struct
	wsdata oAprovacoes as PWSAprovacoes_Struct

	// DELCARACAO DO METODOS
	wsmethod SetPedApr description "Aprova o pedido"

endwsservice



/*
+------------+---------------------------------------------------------------+
! Funcao     ! SetPedAprovado											     !
+------------+---------------------------------------------------------------+
! Autor      ! Clederson Bahl e Dotti										 !
+------------+---------------------------------------------------------------+
! Descricao  ! Define o pedido de compra como aprovado						 !
+------------+---------------------------------------------------------------+
! Parametros !                                                               !
+------------+---------------------------------------------------------------+
*/
wsmethod SetPedApr wsreceive sFILIAL, sNUMPED, sNUMFLG, oAprovacoes wssend sSTATUS wsservice wsPWSPEDCOMTCP
	Local nI
	local aArea := GetArea()
	Local lTodosAprovados := .F.


	sFILIAL := IIF(Empty(sFILIAL), xFilial("SCR"), sFILIAL)

	Begin Transaction
		dbSelectArea("SCR")
		SCR->(dbSetOrder(2))
		for nI := 1 to Len(oAprovacoes:Item)
			if SCR->(dbSeek(sFILIAL + "PC" + PadR(sNUMPED, TamSX3("CR_NUM")[1]) + oAprovacoes:Item[nI]:CodUsr))
				RecLock("SCR",.f.)
				SCR->CR_STATUS := "03"	// LIBERADO
				SCR->CR_DATALIB := CtoD(oAprovacoes:Item[nI]:DataAprov)
				SCR->CR_USERLIB := oAprovacoes:Item[nI]:CodUsr
				//SCR->CR_LIBAPROV := oAprovacoes:Item[nI]:CodUsr
				SCR->CR_OBS := SubStr(oAprovacoes:Item[nI]:Observacao,1,TamSX3("CR_OBS")[1])
				MsUnlock()
			endif
		next nI

		SCR->( dbSetOrder(1) )
		SCR->( dbGoTop() )
		SCR->( dbSeek( sFILIAL + "PC" + sNUMPED ) )

		IF SCR->( Found() )
			lTodosAprovados := .T.
			While !SCR->( Eof() ) .And. SCR->CR_FILIAL+SCR->CR_TIPO+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM)) == sFILIAL + "PC" + sNUMPED
				IF SCR->CR_STATUS != '03'
					lTodosAprovados := .F.
				EndIF
				SCR->( dbSkip() )
			EndDO
		EndIF


		IF lTodosAprovados
			// libera o pedido
			dbSelectArea("SC7")
			SC7->(dbSetOrder(1))
			if SC7->(dbSeek(sFILIAL + sNUMPED))
				while !SC7->(eof()) .and. SC7->(C7_FILIAL + C7_NUM) == sFILIAL + sNUMPED
					RecLock("SC7",.f.)
					SC7->C7_CONAPRO := "L"
					if !Empty(sNUMFLG) .and. SC7->C7_XNUMFLG != sNUMFLG
						SC7->C7_XNUMFLG := sNUMFLG
					endif
					MsUnlock()
					SC7->(dbSkip())
				enddo
				// Retorna liberacao do pedido
				::sSTATUS := "OK"
			else
				::sSTATUS := "ERRO - Nao foi possivel localizar o pedido com: " + sFILIAL + sNUMPED
			endif
		Else
			// Retorna liberacao do pedido
			::sSTATUS := "OK"
		EndIF
	End Transaction

	RestArea(aArea)
return .T.

// Definicao das estruturas de retorno

// Estrutura de um aprovador
wsstruct PWSAprovacao_Struct
	wsdata CodUsr AS string
	wsdata Nome AS string
	wsdata DataAprov as string
	wsdata Observacao as string
endwsstruct

wsstruct PWSAprovacoes_Struct
	wsdata Item as array of PWSAprovacao_Struct
endwsstruct