//Bibliotecas
#Include "Protheus.ch"

/*/{Protheus.doc} zRecurDir
Fun��o recursiva de diret�rios, que traz arquivos dentro de uma pasta e suas subpastas
@author Atilio
@since 30/05/2018
@version 1.0
@param cPasta, characters, Qual � a pasta a ser verificada
@param cMascara, characters, Qual � a m�scara de pesquisa
@param dAPartir, date, Data de corte dos arquivos (Opcional)
@type function
@obs Ao finalizar a rotina, � gerado uma mensagem no console.log com alguns dizeres:
    zRecurDir:
    Buscando arquivos '*.xml', Dentro da pasta 'Z:\Conhecimento Transportadoras XML\', Considerando a partir de '01/05/2018'!
     
    Inicio: 15:51:26
    T�rmino: 15:51:34
    Diferen�a: 00:00:08
    Arquivos encontrados: 40247
    Arquivos filtrados: 1443
     
@example Basta declarar um array, e mandar os par�metros para processamento.
    No exemplo abaixo, � buscado os arquivos xml, dentro do diret�rio especificado, pegando apenas o que consta com a data do dia 01/05/2018 em diante
    aArquivos := u_zRecurDir("Z:\Conhecimento Transportadoras XML\", "*.xml", sToD("20180501"))
/*/

User Function zRecurDir(cPasta, cMascara, dAPartir)
	Local aArea      := GetArea()
	Local cTempoIni  := Time()
	Local cTempoFim  := ""
	Local aArquivos  := {}
	Local aPastas    := {}
	Local aTemp      := {}
	Local aArqOrig   := {}
	Local nAtual     := 0
	Local nAux       := 0
	Local nTamanho   := 0
	Local nTamAux    := 0
	Default cPasta   := ""
	Default cMascara := ""
	Default dAPartir := sToD("")

	//Se tiver pasta e m�scara
	If ! Empty(cPasta) .And. ! Empty(cMascara)

		//Caso n�o tenha "\" no fim adiciona, por exemplo, "C:\TOTVS" -> "C:\TOTVS\"
		cPasta += Iif(SubStr(cPasta, Len(cPasta), 1) != "\", "\", "")

		//Pega as pastas da ra�z
		aPastas := Directory(cPasta + "*.*", "D")

		//Percorre todas as pastas do Array (Conforme ele for sendo atualizado, volta pro la�o)
		For nAtual := 1 To Len(aPastas)

			//Se n�o tiver ponto no nome, e for do tipo D (Diret�rio)
			If ! "." $ Alltrim(aPastas[nAtual][1]) .And. aPastas[nAtual][5] == "D"

				//Se n�o tiver a pasta ra�z no nome, adiciona, por exemplo, "SubPasta" -> "C:\TOTVS\SubPasta"
				If ! cPasta $ aPastas[nAtual][1]
					aPastas[nAtual][1] := cPasta + aPastas[nAtual][1]
				EndIf

				//Caso n�o tenha "\" no fim adiciona, por exemplo, "C:\TOTVS" -> "C:\TOTVS\"
				aPastas[nAtual][1] += Iif(SubStr(aPastas[nAtual][1], Len(aPastas[nAtual][1]), 1) != "\", "\", "")

				//Pega todas as pastas dentro dessa
				aTemp := Directory(aPastas[nAtual][1] + "*.*", "D")

				//Percorre as subpastas dentro, e adiciona o texto a esquerda, por exemplo, "PastaX" -> "C:\TOTVS\SubPasta\PastaX"
				For nAux := 1 To Len(aTemp)
					aTemp[nAux][1] := aPastas[nAtual][1] + aTemp[nAux][1]
				Next

				//Pega o tamanho das subpastas, e o tamanho atual das pastas
				nTamanho := Len(aTemp)
				nTamAux  := Len(aPastas)

				//Redimensiona o array das pastas, aumentando conforme o tamanho das subpastas
				aSize(aPastas, Len(aPastas) + nTamanho)

				//Copia as subpastas para dentro da pasta a partir da �ltima posi��o
				aCopy(aTemp, aPastas, , , nTamAux + 1)
			EndIf
		Next

		//Pega o tamanho das pastas
		nTamanho := Len(aPastas)

		//Percorre todas as pastas
		For nAtual := 1 To nTamanho

			//Se tiver pasta a ser validada
			If nAtual <= Len(aPastas)

				//Se tiver ponto no nome, ou for diferente de D (Diret�rio)
				If "." $ Alltrim(aPastas[nAtual][1]) .Or. aPastas[nAtual][5] != "D"

					//Exclui aposi��o atual do Array
					aDel(aPastas, nAtual)

					//Redimensiona o Array, diminuindo 1 posi��o
					aSize(aPastas, Len(aPastas) - 1)

					//Altera vari�veis de controle, diminuindo elas
					nTamanho--
					nAtual--
				EndIf
			EndIf
		Next

		//Ordena o Array por ordem alfab�tica
		aSort(aPastas)

		//Pega os arquivos da pasta ra�z
		aArquivos := Directory(cPasta + cMascara)

		//Percorre todos os arquivos
		For nAtual := 1 To Len(aArquivos)

			//Se a pasta n�o tiver no nome do arquivo, adiciona, por exemplo, "arquivo.xml" -> "C:\TOTVS\arquivo.xml"
			If ! cPasta $ aArquivos[nAtual][1]
				aArquivos[nAtual][1] := cPasta + aArquivos[nAtual][1]
			EndIf
		Next

		//Percorre todas as pastas / subpastas encontradas
		For nAtual := 1 To Len(aPastas)
			//Se a pasta realmente existe
			If ExistDir(aPastas[nAtual][1])

				//Caso n�o tenha "\" no fim adiciona, por exemplo, "C:\TOTVS" -> "C:\TOTVS\"
				aPastas[nAtual][1] += Iif(SubStr(aPastas[nAtual][1], Len(aPastas[nAtual][1]), 1) != "\", "\", "")

				//Pega todos os arquivos dessa subpasta filtrando a m�scara
				aTemp := Directory(aPastas[nAtual][1] + cMascara)

				//Percorre todos os arquivos encontrados
				For nAux := 1 To Len(aTemp)

					//Adiciona o caminho completo da subpasta, por exemplo, "arquivo2.xml" -> "C:\TOTVS\SubPasta\arquivo2.xml"
					aTemp[nAux][1] := aPastas[nAtual][1] + aTemp[nAux][1]
				Next

				//Pega o tamanho do array dos arquivos encontrados, e o tamanho do array de arquivos que ser�o retornados
				nTamanho := Len(aTemp)
				nTamAux  := Len(aArquivos)

				//Aumento o tamanho do array de Arquivos, com o tamanho dos encontrados
				aSize(aArquivos, Len(aArquivos) + nTamanho)

				//Copia o conte�do dos enontrados para dentro do array de Arquivos
				aCopy(aTemp, aArquivos, , , nTamAux + 1)
			EndIf
		Next

		//Copia para um novo array de backup
		aArqOrig := aClone(aArquivos)

		//Se tiver data de filtragem
		If ! Empty(dAPartir)

			//Enquanto houver arquivos
			nAtual := 0
			While nAtual <= Len(aArquivos)
				nAtual++

				//Se existir arquivos v�lidos a serem processados
				If Len(aArquivos) >= nAtual

					//Se na pasta atual, a data do arquivo N�O for maior que a data de corte
					If ! aArquivos[nAtual][3] >= dAPartir

						//Deleta a posi��o atual o array de Arquivos
						aDel(aArquivos, nAtual)

						//Redimensiona o Array, diminuindo uma posi��o
						aSize(aArquivos, Len(aArquivos) - 1)

						nAtual--
					EndIf
				EndIf
			EndDo
		EndIf
	EndIf

	//Finaliza o tempo, e mostra uma sa�da no console.log
	cTempoFim := Time()
	ConOut("zRecurDir:" + CRLF +;
		"Buscando arquivos '" + cMascara + "', " +;
		"Dentro da pasta '" + cPasta + "', " +;
		"Considerando a partir de '" + dToC(dAPartir) + "'!" + CRLF + CRLF +;
		"Inicio: " + cTempoIni + CRLF +;
		"T�rmino: " + cTempoFim + CRLF +;
		"Diferen�a: " + ElapTime(cTempoIni, cTempoFim) + CRLF +;
		"Arquivos encontrados: " + cValToChar(Len(aArqOrig)) + CRLF +;
		"Arquivos filtrados: " + cValToChar(Len(aArquivos)))

	RestArea(aArea)
Return aArquivos
