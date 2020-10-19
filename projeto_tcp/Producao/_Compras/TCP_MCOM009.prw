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
!Nome              ! TCP_MCOM009                                             !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotinas utilizadas na criação de alçadas do PC          !
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

#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF (chr(13)+chr(10))

/*
+-----------------------------------------------------------------------------+
! Função     ! MCOM09HR     ! Autor ! Mário Faria        ! Data !  07/08/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Parâmetros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  ! Rotina para verificar se o PC possui percentual de imposto     !
!            ! previsto e incluir as alçadas adicionais necessárias           !
+------------+----------------------------------------------------------------+
*/
User Function MCOM09HR()

	Local nRegno	:= SC7->(RECNO())	
	Local aArea 	:= GetArea()
	Local aAreaSC7 	:= SC7->(GetArea())
	Local aAreaSC8	:= SC8->(GetArea())
	Local aAreaSAL	:= SAL->(GetArea())
	Local aAreaSCR	:= SCR->(GetArea())
	
	Local cGrpApr	:= ""
	Local cNumPCAux	:= ""
	Local cQuery	:= ""
	
	Local aNivApr	:= {}

	Local nMoedaAux := 0
	Local nTxMoeAux	:= 0
	Local nValItem	:= 0
	Local nPercImp	:= 0
	Local nTotPcMo	:= 0	//Total na moeda do PC
	Local nTotPC	:= 0	//Total do PC em Real
	Local nTotPCIp	:= 0	//Total do PC em Real com Imposto Previsto
	
	Local cAlias 	:= GetNextAlias()

	//Calcula os totais do PC. Com e sem o Imposto Previsto
	dbSelectArea("SC7")
	SC7->(dbSetOrder(1))
	SC7->(dbGoTop())
	SC7->(dbSeek(xFilial("SC7")+SC8->C8_NUMPED))	

	If AllTrim(FunName()) == "MATA160"
		cGrpApr := SC7->C7_APROV
	Else
		cGrpApr := _cGrpApr
	EndIF
	
	nMoedaAux	:= SC7->C7_MOEDA
	nTxMoeAux	:= SC7->C7_TXMOEDA
	cNumPCAux 	:= SC8->C8_NUMPED
	
	While !SC7->(EOF()) .And. cNumPCAux == SC7->C7_NUM

		//Acumula o total na moeda do PC
		nTotPcMo += SC7->C7_TOTAL+SC7->C7_VALEMB

		//Converte o valor do item em reais
		nValItem := xMoeda(SC7->C7_TOTAL+SC7->C7_VALEMB	,SC7->C7_MOEDA	,1				,SC7->C7_EMISSAO)
				  //xMoeda(valor a converter			,moeda origem	,moeda destino	,data da cotação)

		//Acumula o total do PC em real sem o Imposto Previsto
		nTotPC += nValItem
	
		//Recupera o Percentual de Imposto Previsto (C8_IMPPREV)
		nPercImp := Posicione("SC8",3,xFilial("SC8")+SC7->C7_NUMCOT+SC7->C7_PRODUTO+SC7->C7_FORNECE+SC7->C7_LOJA,"C8_IMPPREV")
	
		//Aplica o Percentual de Imposto Previsto (C8_IMPPREV)
		nValItem := nValItem + (nValItem * (nPercImp/100))

		//Acumula o total do PC em Real com o Imposto Previsto
		nTotPCIp += nValItem
		
		SC7->(dbSkip())
	
	EndDo
	
	//Verifica as alçadas do grupo de aprovação
	cQuery := "	SELECT " + CRLF
	cQuery += "		SAL.AL_NIVEL, SAL.AL_APROV, SAL.AL_USER " + CRLF 
	cQuery += "	FROM " + RetSqlName("SAL") + " SAL " + CRLF 
	cQuery += "	INNER JOIN " + RetSqlName("SAK") + " SAK ON " + CRLF
	cQuery += "			SAK.AK_FILIAL = '" + xFilial("SAK") + "' " + CRLF
	cQuery += "		AND SAK.AK_COD = SAL.AL_APROV " + CRLF 
	cQuery += "		AND SAK.AK_LIMMIN < " + cValToChar(nTotPCIp) + " " + CRLF
	cQuery += "		AND SAK.D_E_L_E_T_ <> '*' " + CRLF 
	cQuery += "	WHERE " + CRLF
	cQuery += "			SAL.AL_FILIAL = '" + xFilial("SAL") + "' " + CRLF
	cQuery += "		AND SAL.AL_COD = '" + cGrpApr + "' " + CRLF
	cQuery += "		AND SAL.D_E_L_E_T_ <> '*' " + CRLF
	cQuery += "		AND SAL.AL_NIVEL NOT IN " + CRLF
	cQuery += "								( " + CRLF
	cQuery += "									SELECT Q1.CR_NIVEL " + CRLF
	cQuery += "									FROM " + RetSqlName("SCR") + " Q1 " + CRLF 
	cQuery += "									WHERE " + CRLF
	cQuery += "											Q1.CR_FILIAL = '" + xFilial("SCR") + "' " + CRLF
	cQuery += "										AND Q1.CR_NUM = '" + cNumPCAux + "' " + CRLF
	cQuery += "										AND Q1.CR_TIPO = 'PC' " + CRLF
	cQuery += "										AND Q1.D_E_L_E_T_ <> '*' " + CRLF
	cQuery += "								) " + CRLF
	cQuery += "	ORDER BY SAL.AL_NIVEL " + CRLF

	Memowrite("c:\temp\grp_aprov.txt",cQuery)

	TcQuery cQuery New Alias (cAlias)

	(cAlias)->(dbGoTop())

	dbSelectArea(cAlias)
	(cAlias)->(dbGoTop())   
	
	//Inclui novas alçadas se necessário
	While !(cAlias)->(Eof())
	
		RecLock("SCR",.T.)
		
		SCR->CR_FILIAL 	:= xFilial("SCR")
		SCR->CR_NUM 	:= cNumPCAux
		SCR->CR_NIVEL	:= (cAlias)->AL_NIVEL
		SCR->CR_USER	:= (cAlias)->AL_USER
		SCR->CR_STATUS	:= "01"
		SCR->CR_TOTAL	:= nTotPcMo
		SCR->CR_EMISSAO	:= dDataBase
		SCR->CR_MOEDA	:= nMoedaAux
		SCR->CR_TXMOEDA	:= nTxMoeAux
		SCR->CR_TIPO	:= "PC"
		SCR->CR_APROV	:= (cAlias)->AL_APROV
		
		MsUnLock("SCR")

		(cAlias)->(dbSkip())

	EndDo
	
	(cAlias)->(dbCloseArea())  

	RestArea(aArea)
	RestArea(aAreaSC7)
	RestArea(aAreaSC8)
	RestArea(aAreaSAL)
	RestArea(aAreaSCR)
	
	SC7->(dbGoTo(nRegno))

Return