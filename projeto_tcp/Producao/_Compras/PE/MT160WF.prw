#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF (chr(13)+chr(10))

/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Ponto de Entrada                                        !
+------------------+---------------------------------------------------------+
!Modulo            ! COM - Compras                                           !
+------------------+---------------------------------------------------------+
!Nome              ! MT160WF.PRW                                             !
+------------------+---------------------------------------------------------+
!Descricao         ! P.E. após a confirmação da análise de cotações          !
+------------------+---------------------------------------------------------+
!Autor             ! RSAC Soluções                                           !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 09/09/2012                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/
User Function MT160WF()

	Local aPedidos := {}
	Local n1
	Local aSaveArea := SaveArea1({"SC8","SC7"})

//inluido por Rodrigo Slisinski 10/08/2017 para incluir a natureza e o centro de custo do contrato antes do envio para o wf
	dbSelectArea("SC8")
	SC8->(dbSetOrder(1))
	SC8->(dbSeek(xFilial("SC8")+ParamIXB[1]))
	dbSelectArea("SC7")
	SC7->(dbSetOrder(1))
	If SC7->(dbSeek(xFilial("SC7")+SC8->C8_NUMPED))
		While !SC7->(EOF()) .and. SC7->C7_FILIAL == xFilial('SC7') .AND. SC7->C7_NUM == SC8->C8_NUMPED
			if !Empty(SC7->C7_CONTRA) .and. !empty(SC7->C7_MEDICAO)

				cQueryZ21 := " SELECT TOP 1 Z21_CCUSTO,Z21_NATURE  FROM "+RetSqlName('Z21')+" Z21 "
				cQueryZ21 += " WHERE Z21.Z21_FILIAL = '"+xFilial('Z21')+"' AND Z21.Z21_CONTRA = '"+SC7->C7_CONTRA+"'"
				cQueryZ21 += "   AND Z21.Z21_NUMMED = '"+SC7->C7_MEDICAO+"' AND Z21.D_E_L_E_T_ != '*' "
				cQueryZ21 += " ORDER BY Z21_VALOR DESC "
				If (Select("TMPZ21") <> 0)
					TMPZ21->(DbCloseArea())
				Endif
				TcQuery cQueryZ21 new alias 'TMPZ21'

		
				if !TMPZ21->(eof())
					RECLOCK('SC7',.F.)
					SC7->C7_CC		:= TMPZ21->Z21_CCUSTO
					SC7->C7_XNATURE	:= TMPZ21->Z21_NATURE
					MSUnlock()
				EndIF
			EndIF
			SC7->(DBSKIP())
		EndDO
	EndIF	
	dbSelectArea("SC8")

	/* Dispara o workflow de aprovação do pedido de compras */
	SC8->( dbSetOrder(1) )
	SC8->( dbSeek( xFilial("SC8") + ParamIXB[1] ) )

	//mais de um fornecedor pode "ganhar" a mesma cotação
	//gerando mais de 1 pedido
	While !SC8->( Eof() ) .And. SC8->(C8_FILIAL+C8_NUM) == xFilial("SC8")+ParamIXB[1]
		IF !Empty(SC8->C8_NUMPED)
			IF aScan(aPedidos,{|x| x[1] == SC8->C8_NUMPED}) == 0
				aAdd( aPedidos, { SC8->C8_NUMPED, SC8->(Recno()) })
			EndIF
		EndIF
		SC8->( dbSkip() )
	EndDO
 
	//percore todos os pedidos gerados pela cotação
	For n1 := 1 to len(aPedidos)

		//posiciona na cotação
		SC8->( dbGoTo(aPedidos[n1][2]) )

		SC7->(dbSetOrder(1))
		IF SC7->(dbSeek(xFilial("SC7")+SC8->C8_NUMPED))

			oRetPed := u_ctrSales( xFilial("SC7"),SC8->C8_NUMPED, .T., .F.,.F.)
			
			oCompras  := ClassIntCompras():new()    
		
			IF oCompras:registraIntegracao('2',xFilial("SC7")+SC8->C8_NUMPED,'I')  
				oCompras:enviaSales()
			elseif !empty(oCompras:cErro)
				ALERT(oCompras:cErro)
			ENDIF  
			
		ENDIF
	Next n1
	
	RestArea1(aSaveArea)

Return .T.
