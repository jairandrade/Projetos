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
!Modulo            ! Estoque / Custos			                             !
+------------------+---------------------------------------------------------+
!Nome              ! ESTA100				                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Importação de Estrutura dos Produtos via arquivo csv	 |	
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos de Andrade		                             !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 05/06/2019                                              !
+------------------+---------------------------------------------------------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
! 											!           !           !		 !
! 			                                !   	    !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/
User Function ESTA100() 
	Local aButtons := {}
	Local cCadastro := "Importação da Estrutura de Produtos"
	Local aSays     	:= {}
	Local aArea			:= GetArea()
	Private cArq		:= ""
	Private aErros 	:= {}

	AADD(aSays,OemToAnsi("Este programa tem o objetivo importar a Estrutura de Produtos do arquivo Excel..."))
	AADD(aSays,OemToAnsi(""						                                                 		      ))
	AADD(aSays,OemToAnsi(""																					  ))
	AADD(aSays,OemToAnsi("Clique no botão parâmetros para selecionar o ARQUIVO CSV de interface."		      ))
	AADD(aSays,OemToAnsi(""						                                                 		      ))
	AADD(aSays,OemToAnsi(""																					  ))
	AADD(aSays,OemToAnsi("                   E S T R U T U R A    D E    P R O D U T O S "		      		  ))
	AADD(aButtons, { 1,.T.						,{|o| (Iif(ImpArq(),o:oWnd:End(),Nil)) 						  }})
	AADD(aButtons, { 2,.T.						,{|o| o:oWnd:End()											  }})
	AADD(aButtons, { 5,.T.						,{|o| (AbreArq(),o:oWnd:refresh())							  }})
	FormBatch( cCadastro, aSays, aButtons )
	RestArea(aArea)
Return .T.

/*---------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Descricao         ! Seleciona arquivo que será copiado para a pasta         !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                              !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 07/06/2019                                              !
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
!Data de Criacao   ! 07/06/2019                                              !
+------------------+--------------------------------------------------------*/
Static Function ImpArq()
	Local lRet := .T.

	If !File(cArq)
		Aviso("Atenção !","Arquivo não selecionado ou inválido !",{"Ok"})
		Return .F.
	Endif

	ProcRegua(474336)

	BEGIN TRANSACTION
		Processa({|| Importa() },"Processando...")
	END TRANSACTION

Return lRet

/*---------------------------------------------------------------------------+
!   DADOS DO PROGRAMA   - Importa()                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina que prepara a importação do arquivo              !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                              !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 07/06/2019                                              !
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
	Private lMsErroAuto := .F.
	Default PARAMIXB3 := 3
	/*
	Filial		- aDados[nX][1]
	Codigo 		- aDados[nX][2]
	Componente	- aDados[nX][3]
	Quantidade	- aDados[nX][4]
	Perda		- aDados[nX][5]
	Data Inicial- aDados[nX][6]
	DAta Final 	- aDados[nX][7]
	TRT			- aDados[nX][8]
	"Filial","Codigo","Componente","Quantidade","Perda","Data Inicial","Data Final","TRT"
	*/
	FT_FUSE(cArq)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	While !FT_FEOF()
		cLinha := FT_FREADLN()
		IncProc("Lendo arquivo csv...")
		If !Empty(cLinha) .and. !(cLinha$";;;;;;;")
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf

		FT_FSKIP()
	EndDo
	FT_FUSE()
	//Verifica o total de colunas. caso seja < 8 o arquivo está incorreto
	If len(aTail(aDados)) <> 8
		Aviso("Atenção","A estrutura do arquivo está incorreta.", {"Ok"}, 2)
		Return
	EndIf
	//Rotina para validação de todo o arquivo importado. caso haja erros em alguma linha, retorna FAlse e aborta a importação
	lContinua := ValArq(aDados)
	If lContinua
		dbSelectArea("SG1")
		SG1->(dbSetOrder(1))//	G1_FILIAL+G1_COD+G1_COMP+G1_TRT
		ProcRegua(Len(aDados))
		For nX:=2 to Len(aDados)//FAZER 02 LAÇOS 1 PARA O CODIGO PAI
			//pega o novo codigo
			If cCodigo <> aDados[nX][2]
				cCodigo := aDados[nX][2]
				aCabec := {}
				aItens := {}
				aCabec := {{"G1_COD",cCodigo,NIL}}
				IncProc("Importando produto " + cCodigo +" ") 
				For nY:=2 to Len(aDados)
					If 	cCodigo == aDados[nY][2]
						cVlr100:= StrTran( aDados[nY,4],",", "." )//retira virgula
						cPerda:= StrTran( aDados[nY,5],",", "." )//retira virgula				
						nVlr100:= Val(cVlr100)
						nPerda:= Val(cPerda)
						aLinhas := {} 
						aadd(aLinhas,{"G1_COD",cCodigo,NIL}) 
						aadd(aLinhas,{"G1_COMP",aDados[nY][3],NIL}) 
						aadd(aLinhas,{"G1_TRT",aDados[nY][8],NIL}) 
						aadd(aLinhas,{"G1_QUANT",nVlr100,NIL}) 
						aadd(aLinhas,{"G1_PERDA",nPerda,NIL}) 
						aadd(aLinhas,{"G1_INI",CTOD(aDados[nY][6]),NIL}) 
						aadd(aLinhas,{"G1_FIM",CTOD(aDados[nY][7]),NIL}) 
						aadd(aItens,aLinhas) 	
					Endif
				Next nY
				//Verifica se o codigo da estrutura ja existe. Caso exista, exclui a estrutura
				If SG1->(MsSeek(cFilAnt+cCodigo)) 
					Begin Transaction
						//Chama a rotina de execauto	
						MSExecAuto({|x,y,z| mata200(x,y,z)},aCabec,Nil,5) 
						If lMsErroAuto
							MostraErro()
							DisarmTransaction()
							lExclui := .F.
						EndIf
					End Transaction
				EndIf
				If lExclui
					Begin Transaction
						//Chama a rotina de execauto	
						MSExecAuto({|x,y,z| mata200(x,y,z)},aCabec,aItens,3) 
						If lMsErroAuto
							MostraErro()
							DisarmTransaction()
						EndIf
					End Transaction
				EndIf
			EndIf
			If !lExclui
				Exit
			EndIf
		Next nX	
		If !lMsErroAuto
			Aviso("Atenção","A Importação foi executada com sucesso.", {"Ok"}, 2)
		EndIf
	EndIF

	Return
	/*/{Protheus.doc} ValArq(aDados)
	Função de validação do arquivo TXT 
	@author Jair Matos
	@since 29/05/2019 
	@version 1.0
	@return lContinua 
	/*/
Static Function ValArq(aDados)
	Local lRet := .T.
	Local nX := 0
	Local nCount := 0
	Local cErro := ""
	Local aDadosBkp := {}

	DbSelectArea("SM0")
	SM0->(DbGoTop())
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	//grava a primeira linha no novo array
	AADD(aDadosBkp,{"Filial","Codigo","Componente","Quantidade","Perda","Data Inicial","Data Final","TRT"})
	//Verifica se filial que está no arquivo é da empresa correta. Valida todo o arquivo. Caso haja inconsistencia, o arquivo será rejeitado
	For nX := 2 to (len(aDados)-nCount)
		lRet := .T.
		SB1->(DbGoTop())
		//Verifica se o codigo pai é igual ao codigo do componente. Caso sim, exclui da lista.
		If aDados[nX][2] == aDados[nX][3]
			cErro 	:= "O produto acabado "+Alltrim(aDados[nX][2])+" não pode ser igual ao componente "+Alltrim(aDados[nX][2])+". Verifique a linha "+Alltrim(Str(nX))+" ."
			aAdd(aErros, cErro)
			lRet := .F.
		EndIf
		If !SM0->(dbSeek( cEmpAnt + aDados[nX][1] ) )
			cErro 	:= "A filial "+Alltrim(aDados[nX][1])+" pertence a outra empresa. Verifique a linha "+Alltrim(Str(nX))+" ."
			aAdd(aErros, cErro)
			lRet := .F.
		EndIf
		If cFilant <> aDados[nX][1] //.and. lRet
			cErro 	:= "A filial "+Alltrim(aDados[nX][1])+" no arquivo não é a filial corrente. Verifique a linha "+Alltrim(Str(nX))+" ."
			aAdd(aErros, cErro)
			lRet := .F.
		EndIf
		If !SB1->(MsSeek(cFilAnt+aDados[nX][2])) //.and. lRet
			cErro 	:= "O produto acabado "+Alltrim(aDados[nX][2])+" não está cadastrado para a filial "+Alltrim(aDados[nX][1])+". Verifique a linha "+Alltrim(Str(nX))+" ."
			aAdd(aErros, cErro)
			lRet := .F.
		EndIf
		If !SB1->(MsSeek(cFilAnt+aDados[nX][3])) //.and. lRet
			cErro 	:= "O componente "+Alltrim(aDados[nX][3])+" não está cadastrado para a filial "+Alltrim(aDados[nX][1])+". Verifique a linha "+Alltrim(Str(nX))+" ."
			aAdd(aErros, cErro)
			lRet := .F.
		EndIf
		If lRet
			//grava a linha no novo array
			AADD(aDadosBkp,{aDados[nX][1],aDados[nX][2],aDados[nX][3],aDados[nX][4],aDados[nX][5],aDados[nX][6],aDados[nX][7],aDados[nX][8]})
			//
		EndIf
	Next nX

	If len(aErros) > 0
		nRetMsg := Aviso("Atenção","Existem produtos com erros no arquivo. Verifique o Log de Erros 'Erro_SG1.txt' ", {"Gera Log.Erros","Fechar"}, 2)
		If nRetMsg == 1
			fSalvArq()
		EndIf
	EndIf
	aDados= {}
	aDados := AClone(aDadosBkp)

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