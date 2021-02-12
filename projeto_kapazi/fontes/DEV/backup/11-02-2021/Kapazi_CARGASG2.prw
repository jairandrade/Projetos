#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TopConn.ch"
/*
+----------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina                                                  !
+------------------+---------------------------------------------------------+
!Modulo            ! PCP - Roteiro de Operações                              !
+------------------+---------------------------------------------------------+
!Nome              ! CARGASG2				                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Importação dos Produtos do MOBILE6   via arquivo csv	 |	
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos de Andrade		                             !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 04/02/2021                                              !
+------------------+---------------------------------------------------------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
*/
User Function CARGASG2()
	Local aButtons := {}
	Local cCadastro := "Importação de Produtos MOBILE6"
	Local aSays     	:= {}
	Local aArea			:= GetArea()
	Local cFilBk  := cFilAnt
	Private cArq		:= ""
	Private aErros 	:= {}
	Private aInfoRet1:= {}

	AADD(aSays,OemToAnsi("Este programa tem o objetivo importar os Produtos utilizados no MOBILE6"))
	AADD(aSays,OemToAnsi("atraves de um arquivo CSV..."						                                                 		      ))
	AADD(aSays,OemToAnsi(""																					  ))
	AADD(aSays,OemToAnsi("Clique no botão parâmetros para selecionar o ARQUIVO CSV de interface."		      ))
	AADD(aSays,OemToAnsi("Clique no botão FILTRAR para selecionar as FILIAIS que receberao a importação."     ))
	AADD(aSays,OemToAnsi(""						                                                 		      ))
	AADD(aSays,OemToAnsi(""																					  ))
	AADD(aSays,OemToAnsi("                  R O T E I R O  DE  O P E R A Ç Õ E S       "		      		  ))
	AADD(aButtons, { 1,.T.						,{|o| (Iif(ImpArq(),o:oWnd:End(),Nil)) 						  }})
	AADD(aButtons, { 2,.T.						,{|o| o:oWnd:End()											  }})
	AADD(aButtons, { 5,.T.						,{|o| (AbreArq(),o:oWnd:refresh())							  }})
	AADD(aButtons, { 17,.T.						,{|o| (GetFilDest(),o:oWnd:refresh())						  }})
	FormBatch( cCadastro, aSays, aButtons )
	RestArea(aArea)
	//Voltando backup da filial
	cFilAnt := cFilBk
Return .T.

/*---------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Descricao         ! Seleciona arquivo que será copiado para a pasta         !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                              !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 04/02/2021                                              !
+------------------+--------------------------------------------------------*/
Static Function AbreArq()

	Local cType		:=	"Arquivos CSV|*.CSV|Todos os Arquivos|*.*"
	cArq := cGetFile(cType, OemToAnsi("Selecione o arquivo de interface"),0,"C:\",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

Return()
/*---------------------------------------------------------------------------+
!   DADOS DO PROGRAMA   - IMPARQ()                                           !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina que prepara a importação do arquivo              !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                              !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 04/02/2021                                              !
+------------------+--------------------------------------------------------*/
Static Function ImpArq()
	Local lRet := .T.

	If !File(cArq)
		Aviso("Atenção !","Arquivo não selecionado ou inválido !",{"Ok"})
		Return .F.
	Endif

	If 	len(aInfoRet1)==0
		MsgAlert("Nenhuma Filial de Destino foi selecionada!")
		lRet := .F.
	EndIf

	ProcRegua(474336)

	If lRet
		BEGIN TRANSACTION
			Processa({|| Importa() },"Processando...")
		END TRANSACTION
	EndIf
Return lRet

/*---------------------------------------------------------------------------+
!   DADOS DO PROGRAMA   - Importa()                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina que prepara a importação do arquivo              !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                              !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 04/02/2021                                              !
+------------------+--------------------------------------------------------*/
Static Function Importa(PARAMIXB3)

	Local cLinha  	:= ""
	Local aDados  	:= {}
	Local nX := 0
	Local nY := 0
	Local aCabec := {}
	Local aItens := {}
	Local aLinhas := {}
	Local cCodigo := ""
	Local lContinua := .T.
	Local nVlr100 := 0
	Local cVlr100 :=""
	Local nPerda := 0
	Local cPerda :=""
	Local lExclui := .T.
    Local i := 0
    Local oModel    := Nil
	Local nX := 0
	Local cNotas := ""
	Local cMsgErro := ""
	Local aCabec := {}
	Local cTranspGU3 := Alltrim(Posicione("GU3",13,xFilial("GU3")+cTranspZA7,"GU3_CDEMIT"))
	Local cNomotGU3 := Alltrim(Posicione("GUU",2,xFilial("GU3")+cCpfZa7,"GUU_NMMTR"))
	Local cCodMotGU3 := Alltrim(Posicione("GUU",2,xFilial("GU3")+cCpfZa7,"GUU_CDMTR"))
	Local aInfo := STRTOKARR(cNFs,';') // Resulta {'1','2','4'}
	Private aRotina := {}
	Private aDadosBkp := {}
	Private lMsErroAuto := .F.
	Default PARAMIXB3 := 3

	FT_FUSE(cArq)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	While !FT_FEOF()
		cLinha := FT_FREADLN()
		IncProc("Lendo arquivo csv...")
		If !Empty(cLinha) .and. !(cLinha$";;;;;;")
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf
		FT_FSKIP()
	EndDo

	FT_FUSE()
	//Verifica o total de colunas. caso seja < 8 o arquivo está incorreto
	If len(aTail(aDados)) <> 7
		Aviso("Atenção","A estrutura do arquivo está incorreta.", {"Ok"}, 2)
		Return .F.
	EndIf
	For i:=1 to Len(aInfoRet1)//array com as FILIAIS
		cFilAnt := aInfoRet1[i][2]
		cCodigo := ""
		//Rotina para validação de todo o arquivo importado. caso haja erros em alguma linha, retorna FAlse e aborta a importação
		//lContinua := ValArq(aDados)
		If lContinua

// informe oS dados para serem carregados na tabela GWN
	DbSelectArea("GWN")
	GWN->(DbSetOrder(1))
	GWN->(DbGotop())
			for nX := 1 to Len(aInfo)
				If !GWN->(DbSeek( xFilial("GWN") + cNumRom ))
			aadd(aCabec,{"GWN_NRROM",cNumRom})
			aadd(aCabec,{"GWN_CDTRP",cTranspGU3})//transportadora
			aadd(aCabec,{"GWN_CDTPOP","0000000001"})
			aadd(aCabec,{"GWN_CDMTR",cCodMotGU3})//CODIGO MOTORISTA
			aadd(aCabec,{"GWN_NMMTR",cNomotGU3})//nOME MOTORISTA
			aadd(aCabec,{"GWN_SIT","3"})//Situação = 3 - liberado

			oModel := FwLoadModel("GFEA050")
					Begin Transaction
				lMsErroAuto := .F.
				FWMVCRotAuto( oModel,"GWN",3,{{"GFEA050_GWN", aCabec}})
						If lMsErroAuto
					DisarmTransaction()
					cMsgErro := MostraErro()
						Else
					cMsgErro := "Romaneio "+cNumRom+" gerado com sucesso para a(s) Nf(s): "
					//Verifica se o documento existe na tabela GW1 e grava o codigo do romaneio GW1_NRROM
					DbSelectArea("GW1")
					GW1->(DbSetOrder(8))
					GW1->(DbGotop())
							If GW1->(DbSeek( xFilial("GW1") + Alltrim(aInfo[nX]) ))
						GW1->(RecLock("GW1" , .F.))
						GW1->GW1_NRROM := cNumRom
						GW1->(MsUnLock())
							EndIf
						EndIf
				cNotas :=aInfo[1]
					End Transaction
				Else
			//Verifica se o documento existe na tabela GW1 e grava o codigo do romaneio GW1_NRROM
			DbSelectArea("GW1")
			GW1->(DbSetOrder(8))
			GW1->(DbGotop())
					If GW1->(DbSeek( xFilial("GW1") + Alltrim(aInfo[nX]) ))
				GW1->(RecLock("GW1" , .F.))
				GW1->GW1_NRROM := cNumRom
				GW1->(MsUnLock())
				cNotas += " ;"+aInfo[nX]
					EndIf
				EndIf
			Next nX

		EndIF
	Next i

	If len(aErros) > 0
		nRetMsg := Aviso("Atenção","A Importação de Produtos foi finalizada mas existem produtos com erros no arquivo. Verifique o Log de Erros 'Erro_SG1.txt' ", {"Gera Log.Erros","Fechar"}, 2)
		If nRetMsg == 1
			fSalvArq()
		EndIf
	Else
		Aviso("Atenção","A Importação de Produtos foi finalizada com sucesso.", {"Ok"}, 2)
	EndIf

	Return
	/*/{Protheus.doc} ValArq(aDados)
	Função de validação do arquivo TXT 
	@author Jair Matos
	@since 04/02/2021 
	@version 1.0
	@return lContinua 
	/*/
Static Function ValArq(aDados)
	Local lRet := .T.
	Local nX := 0
	Local nCount := 0
	Local cErro := ""
	aDadosBkp := {}
	DbSelectArea("SM0")
	SM0->(DbGoTop())
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	//grava a primeira linha no novo array
	AADD(aDadosBkp,{"Codigo","Componente","Quantidade","Perda","Data Inicial","Data Final","TRT"})
	//Verifica se filial que está no arquivo é da empresa correta. Valida todo o arquivo. Caso haja inconsistencia, o arquivo será rejeitado

	For nX := 2 to (len(aDados)-nCount)
		lRet := .T.
		SB1->(DbGoTop())
		//Verifica se o codigo pai é igual ao codigo do componente. Caso sim, exclui da lista.
		If aDados[nX][1] == aDados[nX][2]
			cErro 	:= "O produto acabado "+Alltrim(aDados[nX][1])+" não pode ser igual ao componente "+Alltrim(aDados[nX][2])+". Verifique a linha "+Alltrim(Str(nX))+" ."
			aAdd(aErros, cErro)
			lRet := .F.
		EndIf
		If !SB1->(MsSeek(cFilAnt+aDados[nX][1])) //.and. lRet
			cErro 	:= "O produto acabado "+Alltrim(aDados[nX][1])+" não está cadastrado para a filial "+Alltrim(cFilAnt)+". Verifique a linha "+Alltrim(Str(nX))+" ."
			aAdd(aErros, cErro)
			lRet := .F.
		EndIf
		If !SB1->(MsSeek(cFilAnt+aDados[nX][2])) //.and. lRet
			cErro 	:= "O componente "+Alltrim(aDados[nX][2])+" não está cadastrado para a filial "+Alltrim(cFilAnt)+". Verifique a linha "+Alltrim(Str(nX))+" ."
			aAdd(aErros, cErro)
			lRet := .F.
		EndIf
		If lRet
			//grava a linha no novo array
			AADD(aDadosBkp,{aDados[nX][1],aDados[nX][2],aDados[nX][3],aDados[nX][4],aDados[nX][5],aDados[nX][6],aDados[nX][7]})
			//
		EndIf
	Next nX
	If len(aDadosBkp) <= 1
		Return .F.
	endIf

Return .T.
/*-----------------------------------------------*
| Função: fSalvArq                              |
| Descr.: Função para gerar um arquivo texto    |
*-----------------------------------------------*/

Static Function fSalvArq()
	Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".TXT"
	Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
	Local lOk      := .T.
	Local cTexto   := ""
	Local nX := 0

	//Pegando o caminho do arquivo
	cFileNom:= cGetFile( '*.txt|*.txt' , 'Selecione a pasta para gerar o arquivo', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )

	//Se o nome não estiver em branco
	If !Empty(cFileNom)
		//Teste de existência do diretório
		If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
			Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
			Return
		EndIf
		cArqCPag := cFileNom+"Erro_SG1.txt"
		//Montando a mensagem
		cTexto := "Função:"+ FunName()
		cTexto += " Usuário:"+ cUserName
		cTexto += " Data:"+ dToC(dDataBase)
		cTexto += " Hora:"+ Time() + cQuebra  + "Log de Erros" + cQuebra
		For nX := 1 To Len(aErros)
			cTexto +=aErros[nX]+ CRLF
		Next nX

		//Testando se o arquivo já existe
		If File(cArqCPag)
			lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
		EndIf

		If lOk
			MemoWrite(cArqCPag, cTexto)
			MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cArqCPag,"Atenção")
		EndIf
	EndIf
Return
Static Function GetFilDest()

	aInfoRet1 := FwListBranches(,.F.)

Return
