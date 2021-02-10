#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'TBICONN.ch'
//==================================================================================================//
//	Programa: ITEM		|	Autor: Luis Paulo							|	Data: 06/04/2018		//
//==================================================================================================//
//	Descrição: PONTO DE ENTRADA DA ROTINA MATA010 - PRODUTOS										//
//																									//
//==================================================================================================//
User Function ITEM()
	Local aArea			:= GetArea()
	Local aAreaSB1		:= GetArea("SB1")
	Local aParam		:= PARAMIXB
	Local xRet 			:= .T.
	Local oObj 			:= ""
	Local cIdPonto 		:= ""
	Local cIdModel 		:= ""
	Local lIsGrid 		:= .F.
	Local nLinha 		:= 0
	Local nQtdLinhas 	:= 0
	Local cMsg 			:= ""
	Local lVldGrp		:= StaticCall(M521CART,TGetMv,"  ","KA_MA010GR","L",.T.,"PE_MATA010 - Ativa a validação do grupo informado para o produto." )
/*****NF MISTA ****/
	Local oSB1			:= NIL
	Local oModelB1		:= NIL
	Local lAltera		:= .F.
	Local lInclui		:= .F.
/*****NF MISTA ****/

// se nao existe a variavel de controle de execucao automatica
	If ValType("l010Auto") <> "L"
		// cria
		l010Auto := .F.
	Endif

	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		lIsGrid := (Len(aParam) > 3)

		If cIdPonto == "MODELPOS" //Chamada na validação total do modelo
			oModelB1	:= FWModelActive()
			oSB1		:= oModelB1:GetModel('SB1MASTER')
			lInclui		:= oSB1:GetOperation() == 3
			lAltera		:= oSB1:GetOperation() == 4

			// se validacao do grupo ativada e nao eh execauto
			If lVldGrp .and. !l010Auto
				// valida o grupo de produto
				xRet := VldGrp(oSB1:GetValue("B1_GRUPO"))
			Endif

		/* comentado em 2018-10-16 - esse "ponto de entrada" é para validar o modelo, nao efetuar alteracoes no registro.
		nesse ponto o sistema nem esta posicionado no registro a sb1.
		*/
		/*
			If ValType(oSB1) != "U" .And. lAltera
		// posiciona no regisro e valida se esta diferente
				If SB1->( MsSeek(xFilial("SB1")+oSB1:GetValue("B1_COD"))) .AND. SB1->B1_XGERASV != oSB1:GetValue("B1_XGERASV")
		Reclock("SB1",.F.)
		SB1->B1_XFLAGSV	:= "X"
		SB1->B1_XDATASV	:= Date()
		SB1->B1_XHRSV	:= Time()
		SB1->B1_XQUEMSV	:= UsrFullName(__cUserID)
		SB1->(MsUnlock())
				EndIf

			EndIf
		*/
		ElseIf cIdPonto == "FORMLINEPRE"
			If aParam[5] == "DELETE"
				cMsg := "Chamada na pré validação da linha do formulário. " + CRLF
				cMsg += "Onde esta se tentando deletar a linha" + CRLF
				cMsg += "ID " + cIdModel + CRLF
				cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
				cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
				//xRet := ApMsgYesNo(cMsg + " Continua?")
			EndIf

		ElseIf cIdPonto == "MODELCOMMITNTTS" //Chamada após a gravação total do modelo e fora da transação
			oModelB1	:= FWModelActive()
			oSB1		:= oModelB1:GetModel('SB1MASTER')
			lInclui		:= oSB1:GetOperation() == 3
			lAltera		:= oSB1:GetOperation() == 4
			If ValType(oSB1) != "U"
			/* 2018-10-16 adicionado a validacao do bloco MODELPOS para efetuar a alteracao quando o registro esta posicionado */
				// se ( inclui e gera servido = s ) ou (altera e gera servico do model <> gera servico gravado )
				If (lInclui .And. oSB1:GetValue("B1_XGERASV") == "S" ) .or. ;
						(lAltera .and. oSB1:GetValue("B1_XGERASV") <> SB1->B1_XGERASV)
					Reclock("SB1",.F.)
					SB1->B1_XFLAGSV	:= "X"
					SB1->B1_XDATASV	:= Date()
					SB1->B1_XHRSV	:= Time()
					SB1->B1_XQUEMSV	:= UsrFullName(RetCodUsr())
					SB1->(MsUnlock())
				Endif

				If lInclui .OR. lAltera //ALUISIOPRODUTO
					DbSelectArea("SZ3")
					SZ3->(DbSetOrder(1))
					SZ3->(DbGoTop())
					If  !SZ3->(DbSeek(xFilial("SZ3") + SB1->B1_COD ))

						Reclock("SZ3",.T.)
						SZ3->Z3_CODPROD := SB1->B1_COD
						SZ3->(MsUnlock())
					EndIf

					U_GeraSB5()//jair-09-02-2021
				EndIf

			EndIf

		ElseIf cIdPonto == "FORMCOMMITTTSPRE"
			//ApMsgInfo("Chamada após a gravação da tabela do formulário.")

		ElseIf cIdPonto == "FORMCOMMITTTSPOS"
			//ApMsgInfo("Chamada após a gravação da tabela do formulário.")

		ElseIf cIdPonto == "MODELCANCEL"
			cMsg := "Deseja realmente sair?"
			//xRet := ApMsgYesNo(cMsg)

		ElseIf cIdPonto == "BUTTONBAR"
			//xRet := {{"Salvar", "SALVAR", {||u_TSMT010()}}}
		EndIf

		RestArea(aAreaSB1)
		RestArea(aArea)
	EndIf

Return xRet

User Function TSMT010()
	Alert("Buttonbar")
Return NIL

Static Function VldGrp(cGrp)
	Local 	lRet 	:= .T.
	Local 	cMsg	:= ""
	Local 	aArea	:= GetArea()

	Default cGrp	:= ""

// se vazio
	If Empty(AllTrim(cGrp))
		lRet := .f.
		cMsg := "Grupo de produto não informado (B1_GRUPO)."
		// se informou
	Else
		// abre a tabela
		SBM->( DBSetOrder(1) )
		// se nao localizou
		If !SBM->( MsSeek(xFilial("SBM")+cGrp))
			lRet := .F.
			cMsg := "Grupo de produto informado "+AllTrim(cGrp)+" não localizado."
			// se localizou
		Else
			// se bloqueado
			If SBM->BM_MSBLQL == "1"
				lRet := .F.
				cMsg := "O grupo de produto informado "+AllTrim(cGrp)+" está bloqueado para uso."
			Endif
		Endif
	Endif

// se erro
	If !lRet
		MsgStop(cMsg)
	Endif

	RestArea(aArea)

Return lRet
/*/{Protheus.doc} GeraSB5
//TODO Funcao que grava os dados do produto na tabela SB5 - Dados adicionais do produto
@author Jair Matos
@since 09/02/2021
@version P12

@type function
/*/
User Function GeraSB5()

	Local aCab          := {}
	Local cemp:=cEmpant
	Local cfil:=cFilant
	Private oModel2     := Nil
	Private lMsErroAuto := .F.
	Private aRotina     := {}

	// informe o código do produto, a qual já deve estar registrado na tabela SB1
	cCodigo := SB1->B1_COD
	cDescP	:= SB1->B1_DESC
	cCodGtin:= SB1->B1_CODGTIN
	cFilSB1 := SB1->B1_FILIAL

	If SB1->B1_TIPO $ 'ME|PA'
		//Adicionando os dados do ExecAuto cab
		aCab:= {{"B5_COD"  	, cCodigo  		,Nil},;   	// Código identificador do produto
		{"B5_CEME"  		, cDescP  		,Nil},;    	// Nome científico do produto
		{"B5_2CODBAR"		, cCodGtin  	,Nil},;   	// codigo gtin
		{"B5_UMIND"  		, "1"  			,Nil}}    	// unidade de medida

		If cEmpant <>'04'//Inclui o produto somente na empresa '04'
			ALTEMP("04", "01")//ALTERA A EMPRESA
			//Verifica se ja existe o produto na SB5
			dbSelectArea("SB5")
			SB5->(DbSetOrder(1))//B5_FILIAL+B5_COD
			If SB5->(dbSeek(cFilSB1+cCodigo))
				RecLock('SB5', .F.)
				B5_COD       := cCodigo
				B5_CEME      := cDescP
				B5_2CODBAR   := cCodGtin
				SB5->(MsUnlock())
			Else
				RecLock('SB5', .T.)
				B5_COD       := cCodigo
				B5_CEME      := cDescP
				B5_2CODBAR   := cCodGtin
				B5_UMIND     := '1'
				SB5->(MsUnlock())
			EndIf
			ALTEMP(cemp, cfil)//ALTERA A EMPRESA
		Else
			GeraSB5E(aCab)
		EndIf
	EndIf

Return
/*/{Protheus.doc} GeraSB5E
//TODO Funcao que grava os dados do produto na tabela SB5 - Dados adicionais do produto para a empresa 04
@author Jair Matos
@since 09/02/2021
@version P12

@type function
/*/
Static Function GeraSB5E(aCab)
	PRIVATE lMsErroAuto := .F.
	Private INCLUI := .T.

	oModel2 := FwLoadModel("MATA180")
	dbSelectArea("SB5")
	SB5->(DbSetOrder(1))//B5_FILIAL+B5_COD
	If SB5->(dbSeek("  "+acab[1][2]))
		FWMVCRotAuto( oModel2,"SB5",4,{{"SB5MASTER", aCab}})
	Else
		FWMVCRotAuto( oModel2,"SB5",3,{{"SB5MASTER", aCab}})
	EndIf

	If !lMsErroAuto
		ConOut("Dados adicionais na SB5 incluído para a empresa 04 ")
	Else
		ConOut("Erro na inclusao!")
		MostraErro()
	EndIf
	oModel2:DeActivate()
	oModel2:Destroy()
	oModel2 := NIL

Return
/*/{Protheus.doc} ALTEMP
//TODO Funcao que altera a empresa
@author Jair Matos
@since 09/02/2021
@version P12

@type function
/*/
Static Function ALTEMP(cEmp, cFil)
	Local cemp:=cEmp
	Local cfil:=cFil

	dbcloseall()
	cempant :=cemp
	cfilant :=cfil
	cNumEmp :=cemp+cfil
	Opensm0(cempant+cfil)
	Openfile(cempant+cfil)
	lrefresh :=.T.

Return
