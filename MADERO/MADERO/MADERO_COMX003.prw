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
!Nome              ! COMX003                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Funcoes genericas para cadastro dos clientes	    	 !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos de Andrade		                             !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 05/10/18                                                !
+------------------+---------------------------------------------------------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
! 											!           !           !		 ! 
! 			                                !   	    !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/
//---------------------------------------------------------------------
/*/{Protheus.doc} COMX003C
Rotina que valida gatilho A1_CGC->A1_COD . Caso exista codigo retorna o codigo .Caso não exista , deixa o codigo que está.

@author Jair Matos
@since 05/10/2018
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
User function COMX003C(cCGC,cFaixa,nOpc)
	Local cCodigo 	:= ""
	Local lRet 		:= .T.
	Local cQuery 	:= ""
	Local cAliasSA1 := GetNextAlias()        // da um nome pro arquivo temporario
	Local cCGCInteiro := cCGC
	Default cCGC 	 := ""
	Default cFaixa	:="1"
	If Empty(Alltrim(cFaixa))
		Return cCodigo
	EndIf
	If nOpc ==1//cadastro fornecedor - Protheus
		oModel    := FWModelActive()
		oModelA1 := oModel:GetModel("SA1MASTER") //Instancia submodelo SA1
	EndIf

	If !Empty(cCGC)
		If len(cCGC) == 14
			cCGC := SUBSTR(cCGC,1,8)
			cFaixa := Alltrim(cFaixa)
			If cFaixa =="1" .or. cFaixa =="9"
				cQuery := "SELECT distinct A1_COD as COD FROM "+RetSQLName("SA1")+" WHERE D_E_L_E_T_ = ' ' AND SUBSTR(A1_CGC,1,8) = '"+cCGC+"' "
				cQuery += "AND SUBSTR(A1_COD,1,1)= '"+cFaixa+"'"
				//ElseIf cFaixa =="9"
				//	cQuery := "SELECT distinct A1_COD as COD FROM "+RetSQLName("SA1")+" WHERE D_E_L_E_T_ = ' ' AND A1_CGC = '"+cCGCInteiro+"' "
				//	cQuery += "AND SUBSTR(A1_COD,1,1)= '"+cFaixa+"'"
			Else
				cQuery := "SELECT distinct A1_COD as COD FROM "+RetSQLName("SA1")+" WHERE D_E_L_E_T_ = ' ' AND SUBSTR(A1_CGC,1,8) = '"+cCGC+"' "
			EndIf
		Else
			cQuery := "SELECT A1_COD as COD FROM "+RetSQLName("SA1")+" WHERE D_E_L_E_T_ = ' ' AND A1_CGC = '"+cCGC+"' "
		EndIf
		//Memowrite("c:\temp\comx003c.txt",cQuery)
		TCQUERY cQuery NEW ALIAS &cAliasSA1
		If !Empty(Alltrim((cAliasSA1)->COD))
			cCodigo := (cAliasSA1)->COD
		Else
			cCodigo := cFaixa
		EndIf
		If nOpc ==1//cadastro fornecedor - Protheus
			cLojaProx := U_COMX003L(cCGCInteiro,cFaixa)
			//Atribui um conteudo a de um campo do Modelo.
			oModelA1:LoadValue('A1_LOJA',cLojaProx)
		EndIf
		(cAliasSA1)->(dbCloseArea())
	Else
		cCodigo := cFaixa
		If nOpc ==1//cadastro fornecedor - Protheus
			cLojaProx := U_COMX003L(cCGCInteiro,cFaixa)
			//Atribui um conteudo a de um campo do Modelo.
			oModelA1:LoadValue('A1_LOJA',cLojaProx)
		EndIf
	EndIf

Return cCodigo
//---------------------------------------------------------------------
/*/{Protheus.doc} COMX003L
Rotina que valida gatilho A1_CGC->A1_LOJA . Caso cliente ja exista adiciona a proxima loja.

@author Jair Matos
@since 01/11/2018
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
User function COMX003L(cCGC,cFaixa)
	Local cLoja :=""
	Local lRet := .T.
	Local cQuery := ""
	//Local cFaixa := "1"
	Local cAliasSA1 := GetNextAlias()// da um nome pro arquivo temporario
	DEFAULT cCGC 	 := ""
	If Empty(Alltrim(cFaixa))
		Return cLoja
	EndIf
	If Empty(cCGC)
		cLoja  :=PADL("01",TAMSX3("A1_LOJA")[1],"0")
	Else
		cFaixa := Alltrim(cFaixa)
		//Verifica se O cnpj INTEIRO ja existe. Caso já exista, traz a loja correta. desta maneira nao deixa gravar novamente
		If cFaixa =="1" .or. cFaixa =="9"
			cQuery := "SELECT A1_COD,A1_LOJA as LOJA FROM "+RetSQLName("SA1")+" WHERE D_E_L_E_T_ = ' ' AND A1_CGC = '"+cCGC+"' "
			cQuery += "AND SUBSTR(A1_COD,1,1)= '"+cFaixa+"'"
		Else
			cQuery := "SELECT A1_COD,A1_LOJA as LOJA FROM "+RetSQLName("SA1")+" WHERE D_E_L_E_T_ = ' ' AND A1_CGC = '"+cCGC+"' "
		EndIf
		//Memowrite("c:\temp\comx003L1.txt",cQuery)
		TCQUERY cQuery NEW ALIAS &cAliasSA1
		If !Empty(Alltrim((cAliasSA1)->LOJA))
			cLoja :=(cAliasSA1)->LOJA
			lRet := .F.
		EndIf
		(cAliasSA1)->(dbCloseArea())
		If lRet //Se o CNPJ inteiro não existe, verificar a RAIZ do cnpj. Se achar o CNPJ , traz a ultima loja e acresce +1

			If len(cCGC) == 14
				cCGC := SUBSTR(cCGC,1,8)
			EndIf
			If cFaixa =="1" .or. cFaixa =="9"
				cQuery := "SELECT MAX(A1_LOJA) as LOJA FROM "+RetSQLName("SA1")+" WHERE D_E_L_E_T_ = ' ' AND SUBSTR(A1_CGC,1,8) = '"+cCGC+"' "
				cQuery += "AND SUBSTR(A1_COD,1,1)= '"+cFaixa+"'"
			Else
				cQuery := "SELECT MAX(A1_LOJA) as LOJA FROM "+RetSQLName("SA1")+" WHERE D_E_L_E_T_ = ' ' AND SUBSTR(A1_CGC,1,8) = '"+cCGC+"' "
			EndIf
			//Memowrite("c:\temp\comx003L2.txt",cQuery)
			TCQUERY cQuery NEW ALIAS &cAliasSA1
			If !Empty(Alltrim((cAliasSA1)->LOJA)) .and. (cFaixa== "1" .or. cFaixa== "9")
				cLoja :=PADL(Soma1(Alltrim((cAliasSA1)->LOJA)),TAMSX3("A1_LOJA")[1],"0")
			Else
				cLoja :=PADL("01",TAMSX3("A1_LOJA")[1],"0")
			EndIf
			(cAliasSA1)->(dbCloseArea())
		EndIf
	EndIf

Return cLoja
