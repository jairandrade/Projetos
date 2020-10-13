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
!Modulo            ! Compras                                                 !
+------------------+---------------------------------------------------------+
!Nome              ! COMX002                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Funcoes genericas para cadastro dos fornecedores    	 !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos de Andrade		                             !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 05/10/18                                                !
+------------------+---------------------------------------------------------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!validar a rotina COMX002C e COMX002L e 	!			!			!		 !
!incluir validação referente a faixa 4 jáque!			!			!		 !
!o mesmo CNPJ poderá ser incluido diversas  !			!			!		 !
!vezes. 									! Bruna     !Jair Matos !15-04-20!
!INCLUIDO funcao comx002d - CGC PROTHEUS    !   Jair	!Jair Matos !08-06-20!
+-------------------------------------------+-----------+-----------+--------+
*/
/*/{Protheus.doc} PesqCGC 
Rotina que valida gatilho A2_CGC->A2_COD . Caso exista codigo retorna o codigo .Caso não exista , deixa o codigo que está.

@author Jair Matos
@since 05/10/2018
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
User function COMX002C(cCGC,cCodAnt,nOpc)
	Local aAreaSA2	:= SA2->(GetArea())
	Local cCodigo :=""
	Local cQuery := ""
	Local cLojaProx := ""
	Local cCGCInteiro := cCGC 
	Local cAliasSA2 := GetNextAlias()        // da um nome pro arquivo temporario
	Default cCGC 	 := "1"
	Default cCodAnt := ""

	If nOpc ==1//cadastro fornecedor - Protheus
		oModel    := FWModelActive()
		oModelA2 := oModel:GetModel("SA2MASTER") //Instancia submodelo SA2
	EndIf

	If !Empty(cCGC)
		If len(cCGC) == 14
			If cCodAnt =="4"
				cQuery := "SELECT distinct A2_COD as COD FROM  "+RetSQLName("SA2")+" WHERE D_E_L_E_T_ = ' ' AND A2_CGC = '"+cCGC+"' "
			Else
				cCGC := SUBSTR(cCGC,1,8)
				cQuery := "SELECT distinct A2_COD as COD FROM  "+RetSQLName("SA2")+" WHERE D_E_L_E_T_ = ' ' AND SUBSTR(A2_CGC,1,8) = '"+cCGC+"' "
			EndIf
		Else
			cQuery := "SELECT A2_COD as COD FROM "+RetSQLName("SA2")+" WHERE D_E_L_E_T_ = ' ' AND A2_CGC = '"+cCGC+"' "
		EndIf
		//Memowrite("c:\temp\comx003c.txt",cQuery)
		TCQUERY cQuery NEW ALIAS &cAliasSA2
		If !Empty(Alltrim((cAliasSA2)->COD))
			cCodigo := (cAliasSA2)->COD
			If nOpc ==1//cadastro fornecedor - Protheus
				cLojaProx := U_COMX002L(cCGCInteiro)
				//Atribui um conteudo a de um campo do Modelo.
				oModelA2:LoadValue('A2_LOJA',cLojaProx)
			EndIf
		Else
			cCodigo := Alltrim(cCodAnt)
			If nOpc ==1//cadastro fornecedor - Protheus
				cLojaProx := U_COMX002L(cCGCInteiro)
				//Atribui um conteudo a de um campo do Modelo.
				oModelA2:LoadValue('A2_LOJA',cLojaProx)
			EndIf
		EndIf
		(cAliasSA2)->(dbCloseArea())
	EndIf
	RestArea(aAreaSA2)
Return cCodigo
//---------------------------------------------------------------------
/*/{Protheus.doc} PesqLoja
Rotina que valida gatilho A2_CGC->A2_LOJA. Caso fornecedor ja exista adiciona a proxima loja.

@author Jair Matos
@since 01/11/2018
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
User function COMX002L(cCGC,cFaixa)
	Local cLoja :=""
	Local lRet := .T.
	Local cQuery := ""
	Local cAliasSA2 := GetNextAlias()        // da um nome pro arquivo temporario
	Default cCGC 	 := ""
	If Empty(Alltrim(cFaixa))
		Return cLoja
	EndIf
	If Empty(cCGC)
		cLoja  :=PADL("01",TAMSX3("A2_LOJA")[1],"0")
	Else
		cFaixa := Alltrim(cFaixa)
		//Verifica se O cnpj INTEIRO ja existe. Caso já exista, traz a loja correta.
		cQuery := "SELECT A2_COD,max(A2_LOJA) as LOJA FROM "+RetSQLName("SA2")+" WHERE D_E_L_E_T_ = ' ' AND A2_CGC = '"+cCGC+"' GROUP BY A2_COD"
		If Select(cAliasSA2) > 0
			dbSelectArea(cAliasSA2)
			dbCloseArea()
		EndIf

		TCQUERY cQuery NEW ALIAS &cAliasSA2
		If !Empty(Alltrim((cAliasSA2)->LOJA))
			/*verifica se o codigo começa com 4. Esta faixa é utilizada para cadastro de aluguel 
			e deixa o mesmo CNPJ mudando somente a loja.*/
			If substr((cAliasSA2)->A2_COD,1,1) == "4"
				cLoja :=Soma1((cAliasSA2)->LOJA)
			Else
				cLoja :=(cAliasSA2)->LOJA
			EndIf		
			lRet := .F.   
		EndIf
		(cAliasSA2)->(dbCloseArea())
		If lRet //Se o CNPJ inteiro não existe, verificar a RAIZ do cnpj. Se achar o CNPJ , traz a ultima loja e acresce +1.
			If cFaixa == "4"
				cLoja  :=PADL("01",TAMSX3("A2_LOJA")[1],"0")
			Else
				If len(cCGC) == 14
					cCGC := SUBSTR(cCGC,1,8)
				EndIf

				cQuery := "SELECT MAX(A2_LOJA) as LOJA FROM "+RetSQLName("SA2")+" WHERE D_E_L_E_T_ = ' ' AND SUBSTR(A2_CGC,1,8) = '"+cCGC+"' "

				TCQUERY cQuery NEW ALIAS &cAliasSA2
				If !Empty(Alltrim((cAliasSA2)->LOJA))
					cLoja := PADL(Soma1(Alltrim((cAliasSA2)->LOJA)),TAMSX3("A2_LOJA")[1],"0")				
				Else
					cLoja := PADL("01",TAMSX3("A2_LOJA")[1],"0")
				EndIf
				(cAliasSA2)->(dbCloseArea())
			EndIf
		EndIf
	EndIf

Return cLoja
/*/
Funcao:		U_COMX002P
Autor:		Jair Matos
Data:		14/11/2018
Descricao:	Grava o Conteudo Parametro de Acordo com a Empresa de Referencia
Sintaxe:	U_COMX002P( cEmp , cFil , uMvPar , uMvCntPut , lRpcSet )
/*/
User Function COMX002P( cEmp , cFil , uMvPar , uMvCntPut , lRpcSet )

	BEGIN SEQUENCE

		IF !(;
		( IsInCallStack("U_COMX002") );
		.or.;
		( IsInCallStack("U_COMX002P") .and. Empty( ProcName(1) ) );
		)
			//Nao Permito a Chamada Direta
			BREAK
		EndIF

		DEFAULT lRpcSet	:= .F.

		IF ( lRpcSet )
			RpcSetType( 3 )
			RpcSetEnv( cEmp , cFil )
		EndIF

		If(SX6->(DbSeek(xFilial('SX6')+uMvPar)) )
			RecLock('SX6',.F.)
			SX6->X6_CONTEUD := (uMvCntPut)
			SX6->X6_CONTSPA := SX6->X6_CONTEUD
			SX6->X6_CONTENG := SX6->X6_CONTEUD
			MsUnlock()

		EndIF
		RpcClearEnv() //volta a empresa anterior
	END SEQUENCE

Return
/*/{Protheus.doc} COMX002D 
Rotina que valida gatilho A2_CGC->A2_COD no Protheus

@author Jair Matos
@since 08/06/2020
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
User function COMX002D(cCGC,cCodAnt,cFaixa)
	Local aAreaSA2	:= SA2->(GetArea())
	Local cCodigo :=""
	Local cQuery := ""
	Local cLojaProx := ""
	Local cCGCInteiro := cCGC 
	Local cAliasSA2 := GetNextAlias()        // da um nome pro arquivo temporario
	Default cCGC 	 := "1"
	Default cCodAnt := ""

	//Desconsiderar essa regra caso esteja executando via importação - IMPORT02
	If IsInCallStack("U_IMPORT02")
		Return cCodAnt
	EndIf
	
//cadastro fornecedor - Protheus
		oModel    := FWModelActive()
		oModelA2 := oModel:GetModel("SA2MASTER") //Instancia submodelo SA2

	If !Empty(cCGC)
		If len(cCGC) == 14
			If cCodAnt =="4"
				cQuery := "SELECT distinct A2_COD as COD FROM  "+RetSQLName("SA2")+" WHERE D_E_L_E_T_ = ' ' AND A2_CGC = '"+cCGC+"' "
			Else
				cCGC := SUBSTR(cCGC,1,8)
				cQuery := "SELECT distinct A2_COD as COD FROM  "+RetSQLName("SA2")+" WHERE D_E_L_E_T_ = ' ' AND SUBSTR(A2_CGC,1,8) = '"+cCGC+"' "
			EndIf
		Else
			cQuery := "SELECT A2_COD as COD FROM "+RetSQLName("SA2")+" WHERE D_E_L_E_T_ = ' ' AND A2_CGC = '"+cCGC+"' "
		EndIf
		//Memowrite("c:\temp\comx003c.txt",cQuery)
		TCQUERY cQuery NEW ALIAS &cAliasSA2
		If !Empty(Alltrim((cAliasSA2)->COD))
			cCodigo := (cAliasSA2)->COD
				cLojaProx := U_COMX002L(cCGCInteiro,cFaixa)
				//Atribui um conteudo a de um campo do Modelo.
				oModelA2:LoadValue('A2_LOJA',cLojaProx)
		Else
			cCodigo := Alltrim(cCodAnt)
				cLojaProx := U_COMX002L(cCGCInteiro,cFaixa)
				//Atribui um conteudo a de um campo do Modelo.
				oModelA2:LoadValue('A2_LOJA',cLojaProx)
		EndIf
		(cAliasSA2)->(dbCloseArea())
	EndIf
	RestArea(aAreaSA2)
Return cCodigo