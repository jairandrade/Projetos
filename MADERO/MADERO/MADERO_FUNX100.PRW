#INCLUDE "Protheus.CH"
#INCLUDE "Topconn.ch"
/*
+----------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina                                                  !
+------------------+---------------------------------------------------------+
!Modulo            ! TODOS                                                   !
+------------------+---------------------------------------------------------+
!Nome              ! Funcoes                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Funcoes Diversas								    	 !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos de Andrade		                             !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 25/01/19                                                !
+------------------+---------------------------------------------------------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
! 											!           !           !		 !
! 			                                !   	    !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/ 

/*/{Protheus.doc} ValDtSE2
REtorno do vencimento da primeira parcela do documento

@author Jair Matos
@since 25/01/2019
@version P12
@type function
@return dData
/*/
User Function ValDtSE2()
	Local cQuery := ""
	Local dData
	Local cAliasSE2 := GetNextAlias()        // da um nome pro arquivo temporario

	cQuery := " SELECT E2_VENCTO "
	cQuery += " FROM "+RetSQLName("SE2") + " "
	cQuery += " WHERE E2_FILIAL = '"+xFilial("SE2")+"' "
	cQuery += " AND E2_NUM 		= '"+SubStr(SCR->CR_NUM,1,9)+"' "
	cQuery += " AND E2_PREFIXO 	= '"+SubStr(SCR->CR_NUM,10,3)+"' "
	cQuery += " AND E2_FORNECE 	= '"+SUBSTR(SCR->CR_NUM,13,6)+"' "
	cQuery += " AND E2_LOJA 	= '"+SUBSTR(SCR->CR_NUM,19,2)+"' "
	cQuery += " AND ROWNUM 		<= 1 "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	//Memowrite("c:\temp\ValDtSE2.txt",CQuery)

	TCQUERY cQuery NEW ALIAS &cAliasSE2
	If !Empty((cAliasSE2)->E2_VENCTO)
		dData := STOD((cAliasSE2)->E2_VENCTO)
	Else
		dData := "  /  /  "
	EndIf

	(cAliasSE2)->(dbCloseArea())

Return dData
/*/{Protheus.doc} CalcSC1
Calculo dos campos C1_QUANT * C1_VUNIT

@author Jair Matos
@since 25/01/2019
@version P12
@type function
@return C1_QUANT * C1_VUNIT
/*/
User Function CalcSC1()
	Local nQtd 	 	 := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_QUANT'})
	Local nVunit 	 := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_VUNIT'})

	Return	(aCols[n][nQtd] * aCols[n][nVunit])
	/*/{Protheus.doc} xValITEM()
	Retorna valor de campo passado como parametro de acordo com a Filial logada

	@author Jair Matos
	@since 21/02/2019
	@version P12
	@type function
	@return cCampoRet
	/*/
User Function xValITEM()
	Local cQuery := ""
	Local cCampoRet := ""
	Local nQtdDias := 0
	Local aArea       := GetArea()
	Local cAliasZJA := GetNextAlias()        // da um nome pro arquivo temporario

	cQuery := " SELECT ZJA_ITEM, ZJA_NDIAS , ADK_XDTABE"
	cQuery += " FROM "+RetSQLName("ZJA") + " ZJA "
	cQuery += " JOIN  "+RetSQLName("ADK") + " ADK ON ADK.D_E_L_E_T_ = ' ' AND ADK_XFILI = ZJA_FILIT  "
	cQuery += " WHERE ZJA_FILIT = '"+cFilAnt+"' "
	cQuery += " AND ZJA.D_E_L_E_T_ = ' ' "

	//Memowrite("c:\temp\xValItem.txt",cQuery)
	TCQUERY cQuery NEW ALIAS &cAliasZJA
	If !Empty((cAliasZJA)->ZJA_ITEM) .and. !Empty((cAliasZJA)->ADK_XDTABE)
		//Soma Dias em Uma Data e compara com data atual
		//If DaySum( Stod((cAliasZJA)->ADK_XDTABE) , (cAliasZJA)->ZJA_NDIAS ) >= dDatabase
		If Stod((cAliasZJA)->ADK_XDTABE) >= dDatabase
			cCampoRet := (cAliasZJA)->ZJA_ITEM
		EndIf
	EndIf

	(cAliasZJA)->(dbCloseArea())
	RestArea(aArea)
	Return cCampoRet

	/*/{Protheus.doc} xValITEML()
	Retorna valor de campo passado como parametro de acordo com a Filial logada

	@author Jair Matos
	@since 21/02/2019
	@version P12
	@type function
	@return lRet
	/*/
User Function xValITL()
	Local cQuery := ""
	Local cCampoRet := ""
	Local nQtdDias := ZJA->ZJA_NDIAS
	Local dDtNova := ""
	Local lRet := .F.
	Local aArea       := GetArea()
	Local cAliasADK := GetNextAlias()        // da um nome pro arquivo temporario

	cQuery := " SELECT ADK_XDTABE "
	cQuery += " FROM  "+RetSQLName("ADK") + " "
	cQuery += " WHERE ADK_XFILI =  '"+cFilAnt+"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	//Memowrite("c:\temp\xValITL.txt",CQuery)

	TCQUERY cQuery NEW ALIAS &cAliasADK
	If !Empty((cAliasADK)->ADK_XDTABE)
		dDtNova :=DaySum( Stod((cAliasADK)->ADK_XDTABE) , nQtdDias ) //Soma Dias em Uma Data
		If dDtNova >= dDatabase
			lRet := .T.
		EndIf
	EndIf

	(cAliasADK)->(dbCloseArea())
	RestArea(aArea)
	Return lRet
	//-------------------------------------------------------------------
	/*/{Protheus.doc} VerTabela()
	Verifica se tabela existe para a empresa logada

	@author 	Jair Matos
	@since 		28/03/2019
	@version 	P12
	@return 
	/*/
//-------------------------------------------------------------------
User Function VerTabela(cTabela)
	Local cQuery := ""
	Local lRet := .F.
	Local aArea       := GetArea()
	Local cAliaZ02 := GetNextAlias()        // da um nome pro arquivo temporario

	cQuery := " SELECT TABLE_NAME FROM all_tables "
	cQuery += " WHERE table_name = '"+RetSQLName(cTabela)+"' "
	//Memowrite("c:\temp\VerTabela.txt",CQuery)

	TCQUERY cQuery NEW ALIAS &cAliaZ02
	If !Empty((cAliaZ02)->TABLE_NAME)
		lRet := .T.
	EndIf

	(cAliaZ02)->(dbCloseArea())
	RestArea(aArea)
	Return lRet
	//-------------------------------------------------------------------
	/*/{Protheus.doc} xVldSF1()
	Valida o campo F1_DOC / cnfiscal para preencher com zeros.

	@author 	Jair Matos
	@since 		02/07/2019
	@version 	P12
	@return 
	/*/
//-------------------------------------------------------------------
User Function xVldSF1()
	Local aArea    := GetArea()
	Local cFunName:= AllTrim(FunNAme())
	Local lRet     := .T.

	If  (cFunName == "MATA103" .or. cFunName == "NFEGERA") .and. (!Empty(M->F1_DOC) .or. !Empty(CNFISCAL))
		FG_StrZero("CNFISCAL",TamSX3("F1_DOC")[1])
	EndIf

	RestArea(aArea)
	Return lRet
	//-------------------------------------------------------------------
	/*/{Protheus.doc} xVldSF1S()
	Valida o campo F1_SERIE para preencher com zeros.

	@author 	Jair Matos
	@since 		06/09/2019
	@version 	P12
	@return 
	/*/
//-------------------------------------------------------------------
User Function xVldSF1S()
	Local aArea    := GetArea()
	Local cFunName:= AllTrim(FunNAme())
	Local cIsAlpha := ""
	Local cSerieTm := ""
	If  (cFunName == "MATA103" .or. cFunName == "MATA140") 
		If !Empty(CSERIE)
			cIsAlpha := IsAlpha(Alltrim(CSERIE))
			If Inclui .and. !cIsAlpha
				cSerieTm := Val(Alltrim(CSERIE))
				If !Empty(CESPECIE) .and. Alltrim(CESPECIE)=="SPED" 			
					M->CSERIE	:=StrZero(cSerieTm,TamSX3("F1_SERIE")[1],0)
				EndIf 

			EndIf
		EndIf
	EndIf
	RestArea(aArea)
	Return .T.
	//-------------------------------------------------------------------
	/*/{Protheus.doc} xVldUsu()
	Valida usuario logado na tabela SA2  e SA1. Existe o parametro MV_XUSUAPV. 
	cASO o usuario esteja neste parametro, retorna .T.

	@author 	Jair Matos
	@since 		02/07/2019
	@version 	P12
	@return 	lRet
	/*/
//-------------------------------------------------------------------
User Function xVldUsu()
	Local aArea    := GetArea()
	Local lRet     := .F.

	If IsInCallStack("U_IMPORT02")
		//Caso esteja executando a rotina de importação retorna .T.
		lRet     := .T.
	Else
		If  RetCodUsr()$GETMV("MV_XUSUAPV")
			lRet     := .T.
		EndIf
	EndIf

	RestArea(aArea)
Return lRet
