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
!Nome              ! MT120GOK.PRW                                            !
+------------------+---------------------------------------------------------+
!Descricao         ! P.E. após a confirmação do pedido de compras            !
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
User Function MT120GOK

	Local _lInclui 	:= PARAMIXB[2]
	Local _lAltera 	:= PARAMIXB[3]

	Local aArea 	:= GetArea()
	Local aAreaSC7 	:= SC7->(GetArea())
	Local aAreaSCR	:= SCR->(GetArea())

	Local cNumPcAux	:= SC7->C7_NUM 
	Local oRetPed   := NIL
	
	Local _lIntSal := GETMV( 'TCP_PCSFOR' ) 
	IF l120Auto
		cContra	:= ""
	EndIF
//	Local cContra	:= ""
	//Se estiver chamando da rotina de contratos
	If allTrim(FunName()) = 'CNTA120'
		cContra := CN9->CN9_NUMERO
	EndIf
	
	If _lInclui .Or. _lAltera
	
		//***********************************************************//
		//***Efetua a gravação do campo C7_CONTRATO***//
		// Mario Faria - 02/08/2013
	
		SC7->(dbGoTop())
		SC7->(dbSetOrder(1))
		SC7->(dbSeek(xFilial("SC7")+cNumPcAux))	
		
		While !SC7->(Eof()) .And. cNumPcAux == SC7->C7_NUM
			RecLock("SC7",.F.)  
			SC7->C7_CONTRAT  := cContra
			
			// Executa a atualização do TIPO e valor caso seja chamado a partir da rotina de garantia/reparo
			if FUNNAME() = 'TC04A020'
			    if ZPB->ZPB_STATUS = 'AOF'
			        SC7->C7_TPFRETE := cC7_TPFRETE
			        SC7->C7_VALFRE := nC7_VALFRE
			        SC7->C7_FRETE := nC7_VALFRE
			    endif
		    endif
		    
		    if _lInclui .OR. IsInCallStack("A120Copia")
		    	SC7->C7_XSALES := ''
		    endif
		    
	    	SC7->C7_CONAPRO  := 'B'
	    	
			SC7->(MsUnLock())
			SC7->(dbSkip())
		
		EndDo
	
		//Caso utilize contrato, não precisa de aprovação dos niveis 03 e 04
		//Quando o PC não possui cotação
	/*
		If cContra == "S" .Or. SC8->C8_CONTRAT == "S"
			
			dbSelectArea("SCR")
			SCR->(dbSetOrder(1))
			SCR->(dbGoTop())
			SCR->(dbSeek(xFilial("SCR")+"PC"+PADR(cNumPcAux,TamSx3("CR_NUM")[1])+"03"))
			
			While xFilial("SCR")+"PC"+PADR(cNumPcAux,TamSx3("CR_NUM")[1]) == SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM
			
				RecLock("SCR",.F.)	
				SCR->(dbDelete())
				SCR->(MsUnLock())
			
				SCR->(dbSkip())
			
			EndDo
		
		EndIF
              */

	EndIf

	RestArea(aAreaSCR)
	RestArea(aAreaSC7)
	RestArea(aArea)
	
	If (_lInclui .Or. _lAltera) .AND. (!_lIntSal ) //REMOVER
		/* Dispara o workflow de aprovação */
		dbSelectArea("SC7")
		SC7->(dbSetOrder(1))
		If SC7->(dbSeek(xFilial("SC7")+PARAMIXB[1]))
		   U_WFAprPed()
		   //retirado por rodrigo slisinski 12/12/2012 para implementacao de aprovacao via link
		   //	U_MCOM001()
		Endif
	Endif

Return
