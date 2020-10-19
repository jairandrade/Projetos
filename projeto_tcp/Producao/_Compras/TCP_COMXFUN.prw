#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"


/*
+----------------------------------------------------------------------------+ 
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Fun��es Gen�ricas                                       !
+------------------+---------------------------------------------------------+
!Modulo            ! Compras                                                 !
+------------------+---------------------------------------------------------+
!Nome              ! TCP_COMXFUN                                             !
+------------------+---------------------------------------------------------+
!Descricao         ! Fun��es Gen�ricas das customiza��es do m�dulo de Compras!
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
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

#INCLUDE 'totvs.ch'
#include "rwmake.ch"
#include "topconn.ch"

/*
+-----------------------------------------------------------------------------+
! Fun��o     ! CXF0001      ! Autor ! Alexandre Effting  ! Data !  18/03/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Par�metros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  ! Efetua o posicionamento da Solicita��o de Compras              !
+------------+----------------------------------------------------------------+
*/

User Function CXF0001(cAlias,nReg, nOpc)

	Local _aArea := GetArea()
	Local lEnvSales := .F.
	Local _cNumPc   := ''
	Private cAlDoc := cAlias
	Private nRegDoc := nReg


	//Busca Solicita��o de Compras pela Cota��o
	If cAlias == 'SC8'
		DbSelectArea("SC1")
		SC1->(DbSetOrder(1))
		If SC1->(DbSeek(xFilial("SC1")+SC8->C8_NUMSC+SC8->C8_ITEMSC))
			cAlDoc := "SC1"
			nRegDoc := SC1->(Recno())
		Else
			Alert("Solicita��o de Compras Nro: "+SC8->C8_NUMSC+" - Item: "+SC8->C8_ITEMSC+" n�o Localizada!")
			Return .F.
		EndIf
	EndIf

	//Busca Solicita��o de Compras pela Pedido de Compras
	If cAlias == 'SC7'	
		if !empty(SC7->C7_XSALES)  .AND. SC7->C7_CONAPRO != 'L'
			lEnvSales := .T.
			_cNumPc := SC7->C7_NUM
		ENDIF
		
		DbSelectArea("SC1")
		SC1->(DbSetOrder(1))
		If SC1->(DbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC))
			cAlDoc := "SC1"
			nRegDoc := SC1->(Recno())
		Elseif !Empty(SC7->C7_MEDICAO )
			//CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMERO+CND_NUMMED
			DBSelectArea('CND')
			DBSetorder(4)
			DBSeek(xFilial('CND')+SC7->C7_MEDICAO)
			cAlDoc := "CND"
			nRegDoc := CND->(Recno())
//					Alert("Solicita��o de Compras Nro: "+SC7->C7_NUMSC+" - Item: "+SC7->C7_ITEMSC+" n�o Localizada!")
//					Return .F.
		EndIf
	EndIf

	//Busca Solicita��o de Compras pela NF Entrada
	If cAlias == 'SF1'

		//Busca Item de NF de Entrada
		DbSelectArea("SD1")
		SD1->(DbSetOrder(1))
		If SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

			//Busca Pedido de Compra
			DbSelectArea("SC7")
			SC7->(DbSetOrder(1))
			If SC7->(DbSeek(xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC))
				if !empty(SC7->C7_XSALES) .AND. SC7->C7_CONAPRO != 'L'
					lEnvSales := .T.
					_cNumPc := SC7->C7_NUM
				ENDIF
				if !Empty(SC7->C7_MEDICAO )
					//CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMERO+CND_NUMMED
					DBSelectArea('CND')
					DBSetorder(4)
					DBSeek(xFilial('CND')+SC7->C7_MEDICAO)
					cAlDoc := "CND"
					nRegDoc := CND->(Recno())
				Else

					//Busca Colicita��o de Compras
					DbSelectArea("SC1")
					SC1->(DbSetOrder(1))
					If SC1->(DbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC))
						cAlDoc := "SC1"
						nRegDoc := SC1->(Recno())
					Else
						//Se n�o encontrar Solicita��o de Compras, busca posiciona pedido de compras
						cAlDoc := "SC7"
						nRegDoc := SC7->(Recno())
						//Alert("Solicita��o de Compras Nro: "+SC7->C7_NUMSC+" - Item: "+SC7->C7_ITEMSC+" n�o Localizada!")
						//Return .F.
					EndIf
				EndIF
			EndIf

		EndIf

	EndIf

	If cAlias == "SE2"

		//Busca Item de NF de Entrada
		DbSelectArea("SD1")
		SD1->(DbSetOrder(1))
//				If SD1->(DbSeek(xFilial("SD1")+SE2->E2_NUM+SE2->E2_PREFIXO))
		//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		If SD1->(DbSeek(xFilial("SD1")+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA))
			//Busca Pedido de Compra
			DbSelectArea("SC7")
			SC7->(DbSetOrder(1))
			If SC7->(DbSeek(xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC))
				if !empty(SC7->C7_XSALES)  .AND. SC7->C7_CONAPRO != 'L'
					lEnvSales := .T.
					_cNumPc := SC7->C7_NUM
				ENDIF    
				if !Empty(SC7->C7_MEDICAO )
					//CND_FILIAL+CND_CONTRA+CND_REVISA+CND_NUMERO+CND_NUMMED
					DBSelectArea('CND')
					DBSetorder(4)
					DBSeek(xFilial('CND')+SC7->C7_MEDICAO)
					cAlDoc := "CND"
					nRegDoc := CND->(Recno())
				Else
					//Busca Colicita��o de Compras
					DbSelectArea("SC1")
					SC1->(DbSetOrder(1))
					If SC1->(DbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC))
						cAlDoc := "SC1"
						nRegDoc := SC1->(Recno())
					Else
						cAlDoc := "SC7"
						nRegDoc := SC7->(Recno())
					EndIf
				EndIF
			EndIf
		Else
			/**
			Busca os anexos da tabela de pagamentos manuais.
			@author: Kaique Mathias
			@since: 25/05/2020
			**/
			dbSelectArea("ZA0")
			dbSetOrder(1)
			If ZA0->( MSSeek( xFilial('ZA0') + SE2->E2_XCODPGM) )
				cAlDoc := "ZA0"
				nRegDoc := ZA0->(Recno())
			EndIf
		EndIf

	EndIf
	
	cAlias := cAlDoc
	nReg   := nRegDoc

	//MTVLDACE - Valida acesso � rotina de conhecimento ( [ ] ) --> lRet
	//MTCONHEC - Ponto de entrada para bloquear o bot�o "Banco Conhecimento para alguns usu�rios - lRet
	
	//MsDocument(cAlDoc,nRegDoc, 4)
	
	if lEnvSales
		u_ctrSales( xFilial('SC7'),_cNumPc, .F., .F.,.F.)
	endif
	
	RestArea(_aArea)

Return( Nil )

/*
+-----------------------------------------------------------------------------+
! Fun��o     ! MSDOCVIS     ! Autor ! Alexandre Effting  ! Data !  18/03/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Par�metros ! lRet -> .T. Somente visualiza e inclui, .F. sem bloqueio       !
+------------+----------------------------------------------------------------+
! Descricao  ! Bloqueia manipula��o de dados dependendo da fun��o da usuario. !
!            ! Se T�tulo CP estiver baixado, n�o permite exclus�o.            !
+------------+----------------------------------------------------------------+
*/

User Function MSDOCVIS()
	Local lRet := .F.
	Local _aArea := GetArea()

	If Select ( "TRB" ) <> 0
		dbSelectArea("TRB")
		TRB->(dbCloseArea())
	EndIf

	//Busca T�tulo do Contas a Pagar Pela Solicita��o de Compras
	If ( FunName() == "MATA110" )

		cQuery := "  SELECT COUNT(SE2.E2_BAIXA) AS QTD "
		cQuery += "    FROM "+RetSqlName("SE2")+" SE2 "

		cQuery += "    INNER JOIN "+RetSqlName("SD1")+" SD1 ON (SD1.D1_FILIAL = SE2.E2_FILIAL "
		cQuery += "							  AND SD1.D1_DOC = SE2.E2_NUM "
		cQuery += "							  AND SD1.D1_SERIE = SE2.E2_PREFIXO "
		cQuery += "							  AND SD1.D_E_L_E_T_ <> '*') "

		cQuery += "	INNER JOIN "+RetSqlName("SC7")+" SC7 ON (SC7.C7_FILIAL = SD1.D1_FILIAL    "
		cQuery += "							  AND SC7.C7_NUM = SD1.D1_PEDIDO "
		cQuery += "							  AND SC7.C7_ITEM = SD1.D1_ITEMPC "
		cQuery += "							  AND SC7.D_E_L_E_T_ <> '*') "

		cQuery += "	INNER JOIN "+RetSqlName("SC1")+" SC1 ON (SC1.C1_FILIAL = SC7.C7_FILIAL    "
		cQuery += "							  AND SC1.C1_NUM = SC7.C7_NUMSC "
		cQuery += "							  AND SC1.C1_ITEM = SC7.C7_ITEMSC "
		cQuery += "							  AND SC1.D_E_L_E_T_ <> '*') "

		cQuery += "   WHERE SC7.C7_NUMSC = '"+SC1->C1_NUM+"'"
		cQuery += "     AND SC7.C7_ITEMSC = '"+SC1->C1_ITEM+"'"
		cQuery += "     AND SE2.E2_TIPO = 'NF'"
		cQuery += "     AND SE2.E2_BAIXA <> ' '"
		cQuery += "     AND SE2.E2_FORNECE = '"+SC1->C1_FORNECE+"'"
		cQuery += "     AND SE2.D_E_L_E_T_ <> '*' "

		TCQuery cQuery NEW ALIAS "TRB"

		DbSelectArea("TRB")
		TRB->(DbGotop())

		If TRB->QTD > 0
			lRet := .T.
		EndIF

	EndIf

	//Busca T�tulo do Contas a Pagar Pela Solicita��o de Compras
	If ( FunName() == "MATA150" ) .OR. ( FunName() == "MATA130" )

		If FunName() == "MATA150"
			cNum := SC8->C8_NUMSC
			cItem := SC8->C8_ITEMSC
			cForn := SC8->C8_FORNECE
		Else
			cNum := SC1->C1_NUM
			cItem := SC1->C1_ITEM
		EndIf

		cQuery := "  SELECT COUNT(SE2.E2_BAIXA) AS QTD "
		cQuery += "    FROM "+RetSqlName("SE2")+" SE2 "

		cQuery += "    INNER JOIN "+RetSqlName("SD1")+" SD1 ON (SD1.D1_FILIAL = SE2.E2_FILIAL "
		cQuery += "							  AND SD1.D1_DOC = SE2.E2_NUM "
		cQuery += "							  AND SD1.D1_SERIE = SE2.E2_PREFIXO "
		cQuery += "							  AND SD1.D_E_L_E_T_ <> '*') "

		cQuery += "	INNER JOIN "+RetSqlName("SC7")+" SC7 ON (SC7.C7_FILIAL = SD1.D1_FILIAL    "
		cQuery += "							  AND SC7.C7_NUM = SD1.D1_PEDIDO "
		cQuery += "							  AND SC7.C7_ITEM = SD1.D1_ITEMPC "
		cQuery += "							  AND SC7.D_E_L_E_T_ <> '*') "

		cQuery += "	INNER JOIN "+RetSqlName("SC1")+" SC1 ON (SC1.C1_FILIAL = SC7.C7_FILIAL    "
		cQuery += "							  AND SC1.C1_NUM = SC7.C7_NUMSC "
		cQuery += "							  AND SC1.C1_ITEM = SC7.C7_ITEMSC "
		cQuery += "							  AND SC1.D_E_L_E_T_ <> '*') "

		cQuery += "   WHERE SC7.C7_NUMSC = '"+cNum+"'"
		cQuery += "     AND SC7.C7_ITEMSC = '"+cItem+"'"
		cQuery += "     AND SE2.E2_TIPO = 'NF'"
		cQuery += "     AND SE2.E2_BAIXA <> ' '"

		If FunName() == "MATA150"
			cQuery += "     AND SE2.E2_FORNECE = '"+cForn+"'"
		EndIf

		cQuery += "     AND SE2.D_E_L_E_T_ <> '*' "

		TCQuery cQuery NEW ALIAS "TRB"

		DbSelectArea("TRB")
		TRB->(DbGotop())

		If TRB->QTD > 0
			lRet := .T.
		EndIF

	EndIf

	//Busca T�tulo do Contas a Pagar Pela Solicita��o de Compras
	If ( FunName() == "MATA121" )

		cQuery := "  SELECT COUNT(SE2.E2_BAIXA) AS QTD "
		cQuery += "    FROM "+RetSqlName("SE2")+" SE2 "

		cQuery += "    INNER JOIN "+RetSqlName("SD1")+" SD1 ON (SD1.D1_FILIAL = SE2.E2_FILIAL "
		cQuery += "							  AND SD1.D1_DOC = SE2.E2_NUM "
		cQuery += "							  AND SD1.D1_SERIE = SE2.E2_PREFIXO "
		cQuery += "							  AND SD1.D_E_L_E_T_ <> '*') "

		cQuery += "	INNER JOIN "+RetSqlName("SC7")+" SC7 ON (SC7.C7_FILIAL = SD1.D1_FILIAL    "
		cQuery += "							  AND SC7.C7_NUM = SD1.D1_PEDIDO "
		cQuery += "							  AND SC7.C7_ITEM = SD1.D1_ITEMPC "
		cQuery += "							  AND SC7.D_E_L_E_T_ <> '*') "

		cQuery += "   WHERE SC7.C7_NUM = '"+SC7->C7_NUM+"'"
		cQuery += "     AND SC7.C7_ITEM = '"+SC7->C7_ITEM+"'"
		cQuery += "     AND SE2.E2_TIPO = 'NF'"
		cQuery += "     AND SE2.E2_BAIXA <> ' '"
		cQuery += "     AND SE2.E2_FORNECE = '"+SC7->C7_FORNECE+"'"
		cQuery += "     AND SE2.D_E_L_E_T_ <> '*' "

		TCQuery cQuery NEW ALIAS "TRB"

		DbSelectArea("TRB")
		TRB->(DbGotop())

		If TRB->QTD > 0
			lRet := .T.
		EndIF

	EndIf

	//Busca T�tulo do Contas a Pagar Pela Solicita��o de Compras
	If ( FunName() == "MATA103" )

		//Busca se t�tulo CP da NF est� baixado
		cQuery := "SELECT COUNT(SE2.E2_NUM) AS QTD "
		cQuery += "  FROM "+RetSqlName("SE2")+" SE2 "
		cQuery += " WHERE SE2.E2_FILIAL = '"+xFilial("SE2")+"'"
		cQuery += "   AND SE2.E2_PREFIXO = '"+SF1->F1_SERIE+"'"
		cQuery += "   AND SE2.E2_NUM = '"+SF1->F1_DOC+"'"
		cQuery += "   AND SE2.E2_TIPO = 'NF'"
		cQuery += "   AND SE2.E2_BAIXA <> ' '"
		cQuery += "   AND SE2.E2_FORNECE = '"+SF1->F1_FORNECE+"'"
		cQuery += "   AND SE2.D_E_L_E_T_ <> '*'"

		TCQuery cQuery NEW ALIAS "TRB"

		DbSelectArea("TRB")
		TRB->(DbGotop())

		If TRB->QTD > 0
			lRet := .T.
		EndIF

	EndIf

	//Busca T�tulo do Contas a Pagar Pela Solicita��o de Compras
	If ( FunName() == "FINA050" ) .OR. ( FunName() == "FINA750" )

		If Alltrim(Replace(Alltrim(DTOC(SE2->E2_BAIXA)),'/','')) <> ''
			lRet := .T.
		EndIF

	EndIf

	//S� � permitido Manipula��o de Documentos com T�tulo Baixado se Usu�rio estiver contido em par�metro
	If lRet
//		If UsrRetName(__cUserID) $ SuperGetMV("MV_TCPDOCU",,"Administrador")
		If cUserName $ SuperGetMV("MV_TCPDOCU",,"Administrador")
			lRet := .F.
		EndIf
	EndIf

	//Apresenta Mensagem ao usu�rio quando n�o permitir dele��o de Documentos
	If lRet
		alert("Processo de Compras Conclu�do! Este usu�rio n�o possui permiss�o para excluir documentos.")
	EndIf

	RestArea(_aArea)
Return lRet

/*
+-----------------------------------------------------------------------------+
! Fun��o     ! CXF0002      ! Autor ! Alexandre Effting  ! Data !  21/03/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Par�metros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  ! Efetua o filtro de Objetos na Consulta Padr�o (ACB)            !
+------------+----------------------------------------------------------------+
*/

User Function CXF0002(cObj)
	Local lRet := .T.
	Local _aArea := GetArea()

	If FunName() $ "MATA110|FINA050|MATA103|MATA121|MATA150|MATA130|FINA750"

		if Select ( "TRB2" ) <> 0
			dbSelectArea("TRB2")
			TRB2->(dbCloseArea())
		EndIf

		//Busca se Objeto j� est� em uso em outra Entidade
		cQuery := " SELECT COUNT(AC9.AC9_CODOBJ) AS QTD "
		cQuery += "   FROM "+RetSqlName("AC9")+" AC9 "
		cQuery += "  WHERE AC9.AC9_CODOBJ = '"+cObj+"' "
		cQuery += "    AND AC9.D_E_L_E_T_ <> '*' "

		TCQuery cQuery NEW ALIAS "TRB2"

		DbSelectArea("TRB2")
		TRB2->(DbGotop())

		If TRB2->QTD > 0
			lRet := .F.
		EndIF

	EndIf

	RestArea(_aArea)
Return lRet

user function criaCon(_cEmp,_cFil)

RpcSetType(3)

If Type('cEmpAnt') == 'U'
	RpcClearEnv()
	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFil MODULO "SIGAMDI" TABLES "SCR"
ElseIf !(_cEmp == cEmpAnt)
	RpcClearEnv()
	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFil MODULO "SIGAMDI" TABLES "SCR"
ElseIf !(_cFil == cFilAnt)
	cFilAnt := _cFil
EndIf
return
