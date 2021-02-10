User Function zTeste()
	Local aArea       := GetArea()
	Local oBrowse
	Local cFunBkp     := FunName()
	Local cArquivo    := "\teste"+GetDBExtension()
	Local cArqs       := ""
	Local aStrut      := {}
	Local aBrowse     := {}
	Local aSeek       := {}
	Local aIndex      := {}
	Private cAliasTmp := "CADTMP"

	//Pode se usar tamb�m a FWTemporaryTable

	//Criando a estrutura que ter� na tabela
	aAdd(aStrut, {"TMP_COD", "C", 06, 0} )
	aAdd(aStrut, {"TMP_DES", "C", 50, 0} )
	aAdd(aStrut, {"TMP_VAL", "N", 10, 2} )
	aAdd(aStrut, {"TMP_DAT", "D", 08, 0} )

	//Se o arquivo dbf / ctree existir, usa ele
	If Select(cAliasTmp) == 0
		If File(cArquivo)
			DbUseArea(.T., "DBFCDX", cArquivo, cAliasTmp, .T., .F.)

			//Sen�o, cria uma tempor�ria
		Else
			//Criando a tempor�ria
			cArqs := CriaTrab( aStrut, .T. )
			DbUseArea(.T., "DBFCDX", cArqs, cAliasTmp, .T., .F.)

			MsgInfo("Arquivo criado '"+cArqs+GetDBExtension()+"'", "Aten��o")
		EndIf
	EndIf

	//Definindo as colunas que ser�o usadas no browse
	aAdd(aBrowse, {"Codigo",    "TMP_COD", "C", 06, 0, "@!"})
	aAdd(aBrowse, {"Descricao", "TMP_DES", "C", 50, 0, "@!"})
	aAdd(aBrowse, {"Valor",     "TMP_VAL", "N", 10, 0, "@E 9,999,999.99"})
	aAdd(aBrowse, {"Data",      "TMP_DAT", "D", 08, 0, "@D"})

	SetFunName("zTmpCad")

	aAdd(aIndex, "TMP_COD" )

	//Criando o browse da tempor�ria
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAliasTmp)
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetFields(aBrowse)
	oBrowse:DisableDetails()
	oBrowse:SetDescription("cTitulo")
	oBrowse:Activate()

	SetFunName(cFunBkp)
	RestArea(aArea)
Return Nil
