#include "protheus.ch"

User Function IMPORT21()

	Local bProcess
	Local cPerg := Padr("IMPORT21",10)
	Local oProcess

	bProcess := {|oSelf| Executa(oSelf) }

	//cria as peguntas se não existe
	//CriaSX1(cPerg)
	Pergunte(cPerg,.F.)

	oProcess := tNewProcess():New("IMPORT21","Importação de complemento de produtos",bProcess,"Rotina para importação de complemento de produtos. Na opção parametros, favor informar o arquivo .CSV para importação",cPerg,,.F.,,,.T.,.F.)

Return

Static Function Executa(oProc)

	Local cArq       := alltrim(mv_par01)
	Local cLinha     := ""
	Local lPrim      := .T.
	Local aCampos    := {}
	Local aDados     := {}
	Local aMata180 := {}
	Local cDiretory
	Local nMostra   := mv_par02

	Local lErro := .F.
	Local i
	Local j
	Local n1

	Local nTotalLinhas

	IF !File(cArq)
		MsgStop("O arquivo " +cArq + " não foi encontrado. A importação será abortada!","[AEST905] - ATENCAO")
		Return
	EndIF

	//valida o diretório se for pra gravar em disco
	IF nMostra == 2
		cDiretory := alltrim(mv_par03)
		cDiretory += Iif( Right( cDiretory, 1 ) == "\", "", "\" )
		//valida o diretório
		If !ExistDir( cDiretory )
			Aviso("Diretório","Diretório " + cDiretory + " invalido.",{"Ok"},2)
			Return
		EndIF
	EndIF


	FT_FUSE(cArq)

	//Regua
	oProc:SetRegua1( nTotalLinhas := FT_FLastRec() )

	While !FT_FEOF()

		cLinha := alltrim(FT_FREADLN())

		If lPrim
			aCampos := Separa(cLinha,";",.T.)
			lPrim := .F.
		Else
			aAdd(aDados,Separa(cLinha,";",.T.))
		EndIf

		//Regua
		oProc:IncRegua1("Lendo linha " + cValToChar(len(aDados)) + " de " + cValToChar(nTotalLinhas))

		FT_FSKIP()
	EndDO

	FT_FUSE()
	oProc:IncRegua1("Leitura do arquivo texto OK")

	Begin Transaction

		//Regua
		oProc:SetRegua2( len(aDados) )

		For i:=1 to Len(aDados)

			aMata180 := {}
			
			For j:=1 to Len(aCampos)

				If FieldPos(aCampos[j]) > 0
					IF alltrim(aCampos[j]) != "B5_FILIAL"
						Do Case
						Case FWSX3Util():GetFieldType(aCampos[j]) == 'N'
							AADD(aMata180,{alltrim(aCampos[j]), toNumber(aDados[i,j]), NIL})
						Case FWSX3Util():GetFieldType(aCampos[j])  == 'D'
							AADD(aMata180,{alltrim(aCampos[j]), CTOD(aDados[i,j]), NIL})
						Otherwise
							AADD(aMata180,{alltrim(aCampos[j]), aDados[i,j], NIL})
						EndCase
					EndIf
				EndIf
			Next j


			lMsErroAuto := .F.
			MSExecAuto({ |x,y| Mata180(x,y)}, aMata180, 3)

			IF lMsErroAuto
				lErro := .T.
				IF nMostra == 1
					MostraErro()
				ElseIF nMostra == 2
					cNome := "["+cFilAnt+"]"
					cNome += "["+DtoS(Date())+"]"
					cNome += "["+RetNum(Time())+"]"
					cNome += "["+cValToChar(i)+"]"
					cNome += ".txt"
					MostraErro(cDiretory,cNome)
				EndIF
			EndIF

		Next i

		IF lErro
			DisarmTransaction()
		EndIF

	End Transaction

Return

Static Function toNumber(xValor)

	//se exitir virgula na string
	IF At(",",xValor) != 0
		//se o ponto vier antes da virgula ou ponto não existir
		IF ( At(",",xValor) > At(".",xValor) ).Or.At(".",xValor) == 0
			xValor := StrTran(xValor,".","")
			xValor := StrTran(xValor,",",".")
			xValor := val(xValor)
		Else
			xValor := StrTran(xValor,",","")
			xValor := val(xValor)
		EndIF
	Else
		xValor := val(xValor)
	EndIF

Return xValor


/*
Static Function CriaSX1(cPerg)

	//Arquivo
	//PutSx1(cPerg,"01","Arquivo?","Arquivo?","Arquivo?","mv_ch1","C",99,0,0,"G","","DIR","","","mv_par01","","","","","","","","","","","","","","","","",{"Informe o arquivo para importação,","obrigatóriamente deve ser .CSV","",""},{"","","",""},{"","",""},"")
	//Mostra erros?
	//PutSx1(cPerg,"02","Mostra erro?","Mostra erro?","Mostra erro?","mv_ch2","N",1,0,0,"C","","","","","mv_par02","Mostra","Mostra","Mostra","","Grava em Disco","Grava em Disco","Grava em Disco","Não Mostra","Não Mostra","Não Mostra","","","","","","",{"Informe se deseja que a cada erro","mostra a mensagem na tela ou","seja gravada em disco.",""},{"","","",""},{"","",""},"")
	//Diretorio
	//PutSx1(cPerg,"03","Diretório?","Diretório?","Diretório?","mv_ch3","C",99,0,0,"G","","HSSDIR","","","mv_par03","","","","","","","","","","","","","","","","",{"Informe o diretório para gravar","erros se o parametros anterior","estiver para Grava em Disco.",""},{"","","",""},{"","",""},"")

Return*/


Static Function ToString(xValor)

	Local cValor := ""
	//verifica se tem conteudo
	Do Case
	Case valtype(xValor) == "N"
		cValor := cValToChar(xValor)
		/*
		Solicitado pelo Aparecido (Mocartins)
		Para alterar o separador de decimal de ponto para virgula
		Este padrão será adotado em todas as integração
		*/
		cValor := StrTran(cValor, ".", ",")
	Case valtype(xValor) == "C"
		cValor := alltrim(xValor)
		//Para garantir que não haverá problema com
		//o separador de campos (ponto-e-virgula)
		cValor := StrTran(cValor, ";", "")
	Case valtype(xValor) == "D"
		cValor := DtoS(xValor)
	Case valtype(xValor) == "L"
		cValor := IF(xValor,"T","F")
	EndCase
Return cValor
