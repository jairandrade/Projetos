Static Function Importar(cArqImpor)
	Local cLinha := ""
	Local nLinha := 0
	Local aDados := {}
	Local nTamLinha := 0
	Local nTamArq:= 0
	//Valida arquivo
	If !file(cArqImpor)
		Aviso("Arquivo","Arquivo não selecionado ou invalido.",{"Sair"},1)
		Return
	Else
		//+---------------------------------------------------------------------+
		//| Abertura do arquivo texto                                           |
		//+---------------------------------------------------------------------+
		nHdl := fOpen(cArqImpor)

		If nHdl == -1
			IF FERROR()== 516
				ALERT("Feche a planilha que gerou o arquivo.")
			EndIF
		EndIf

		//+---------------------------------------------------------------------+
		//| Verifica se foi possível abrir o arquivo                            |
		//+---------------------------------------------------------------------+
		If nHdl == -1
			cMsg := "O arquivo de nome "+cArqImpor+" nao pode ser aberto! Verifique os parametros."
			MsgAlert(cMsg,"Atencao!")
			Return
		Endif

		//+---------------------------------------------------------------------+
		//| Posiciona no Inicio do Arquivo                                      |
		//+---------------------------------------------------------------------+
		FSEEK(nHdl,0,0)

		//+---------------------------------------------------------------------+
		//| Traz o Tamanho do Arquivo TXT                                       |
		//+---------------------------------------------------------------------+
		nTamArq:=FSEEK(nHdl,0,2)

		//+---------------------------------------------------------------------+
		//| Posicona novamemte no Inicio                                        |
		//+---------------------------------------------------------------------+
		FSEEK(nHdl,0,0)

		//+---------------------------------------------------------------------+
		//| Fecha o Arquivo                                                     |
		//+---------------------------------------------------------------------+
		fClose(nHdl)
		FT_FUse(cArqImpor)  //abre o arquivo
		FT_FGOTOP()         //posiciona na primeira linha do arquivo
		nTamLinha := Len(FT_FREADLN()) //Ve o tamanho da linha
		FT_FGOTOP()

		//+---------------------------------------------------------------------+
		//| Verifica quantas linhas tem o arquivo                               |
		//+---------------------------------------------------------------------+
		nLinhas := nTamArq/nTamLinha

		ProcRegua(nLinhas)

		aDados:={}
		While !FT_FEOF() //Ler todo o arquivo enquanto não for o final dele

			IncProc('Importando Linha: ' + Alltrim(Str(nCont)) )

			clinha := FT_FREADLN()

			aadd(aDados,Separa(cLinha,";",.T.))
			FT_FSKIP()
		EndDo
		FT_FUse()
		fClose(nHdl)
	EndIf

	ProcRegua(len(aDados))

	For i := 1 to len(aDados)
		//Considerando que no arquivo txt contenha 2 colunas, mostre na tela linha a linha
		alert(aDados[i,1] + " " + aDados[i,2])
	Next
	Aviso("Atenção","Importação com exito!",{"Ok"},1)
Return
