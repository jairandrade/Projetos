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
!Nome              ! ESTA101				                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Importação de Produtos Alternativos via arquivo csv	 |
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos de Andrade		                             !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 07/06/2019                                              !
+------------------+---------------------------------------------------------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
! 											!           !           !		 !
! 			                                !   	    !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/
User Function ESTA101() 
	Local aButtons := {}
	Local cCadastro := "Importação de Produtos Alternativos"
	Local nOpca     	:= 0
	Local aSays     	:= {}
	Local aArea			:= GetArea()
	Private cArq		:= ""
	Private aErros 	:= {}

	AADD(aSays,OemToAnsi("Este programa tem o objetivo de importar Produtos Alternativos do arquivo Excel..."))
	AADD(aSays,OemToAnsi(""						                                                 		      ))
	AADD(aSays,OemToAnsi(""																					  ))
	AADD(aSays,OemToAnsi("Clique no botão parâmetros para selecionar o ARQUIVO CSV de interface."		      ))
	AADD(aSays,OemToAnsi(""						                                                 		      ))
	AADD(aSays,OemToAnsi(""																					  ))
	AADD(aSays,OemToAnsi("                   P R O D U T O S    A L T E R N A T I V O S"		      		  ))
	AADD(aButtons, { 1,.T.						,{|o| (Iif(ImpArq(),o:oWnd:End(),Nil)) 						  }})
	AADD(aButtons, { 2,.T.						,{|o| o:oWnd:End()											  }})
	AADD(aButtons, { 5,.T.						,{|o| (AbreArq(),o:oWnd:refresh())							  }})
	FormBatch( cCadastro, aSays, aButtons ,,,650)
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
	Private nHdl	:= 0

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
Static Function Importa()

	Local cCont 	:= "000"
	Local cLinha  	:= ""
	Local aDados  	:= {}
	Local nX := 0
	Local nX1:= 0
	Local aGets := {}
	Local cCodigo := ""
	Local lContinua := .T.
	Local nVlr100 := 0
	Local cVlr100 :=""
	Local cCodori := ""
	Private lMsErroAuto := .F.

	FT_FUSE(cArq)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	While !FT_FEOF()
		IncProc("Lendo arquivo csv...")
		cLinha := FT_FREADLN()

		If !Empty(cLinha) .and. !(cLinha$";;;;;")
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf

		FT_FSKIP()
	EndDo
	FT_FUSE()
	//Verifica o total de colunas. caso seja < 7 o arquivo está incorreto
	If len(aTail(aDados)) <> 7
		Aviso("Atenção","A estrutura do arquivo está incorreta.", {"Ok"}, 2)
		Return
	EndIf
	//Rotina para validação de todo o arquivo importado. caso haja erros em alguma linha, retorna FAlse e aborta a importação
	lContinua := ValArq(aDados)
	If lContinua
		dbSelectArea("SGI")
		SGI->(dbSetOrder(1))//	GI_FILIAL+GI_PRODORI+GI_ORDEM+GI_PRODALT
		ProcRegua(Len(aDados))
		For nX:=2 to Len(aDados)
			//pega o novo codigo
			If cCodori <> aDados[nX][2]
				cCodori:= aDados[nX][2]
				If SGI->(MsSeek(cFilant+PADR(ALLTRIM(aDados[nX][2]),TamSX3("GI_PRODORI")[1])))//+ALLTRIM(aDados[nX][3])+PADR(ALLTRIM(aDados[nX][4]),TamSX3("GI_PRODALT")[1])))
					//se achar produto alternativo para o produto de origem, deleta e inclui novamente.
					While !SGI->(EOF()) .AND. SGI->GI_FILIAL+SGI->GI_PRODORI == cFilant+PADR(ALLTRIM(aDados[nX][2]),TamSX3("GI_PRODORI")[1])

						RecLock("SGI",.F.)
						SGI->(DbDelete())
						SGI->(MsUnlock())
						SGI->(DbSkip())

					EndDo

				EndIf
				For nX1:=2 to Len(aDados)
					cVlr100:= StrTran( Alltrim(aDados[nX1,6]),",", "." )//retira virgula
					nVlr100:= Val(cVlr100)
					If aDados[nX1][2] == cCodori
						IncProc("Importando produto " + aDados[nX1][4] +" ") 
						RecLock("SGI",.T.)	
						SGI->GI_FILIAL := aDados[nX1][1]
						SGI->GI_PRODORI:= aDados[nX1][2]
						SGI->GI_ORDEM  := Alltrim(aDados[nX1][3])
						SGI->GI_PRODALT:= aDados[nX1][4]                              
						SGI->GI_TIPOCON:= aDados[nX1][5]
						SGI->GI_FATOR  := nVlr100
						SGI->GI_MRP    := aDados[nX1][7]
						MSUnlock("SGI")	
					EndIf
				Next nX1
			EndIf
		Next nX 
	EndIF
	If lContinua
		Aviso("Atenção","A Importação dos Produtos Alternativos foi executada com sucesso.", {"Ok"}, 2)
	EndIf

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
	Local cErro := ""
	Local cCodAnt :=""
	Local cOrdem :=""

	DbSelectArea("SM0")
	SM0->(DbGoTop())
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	//Verifica se filial que está no arquivo é da empresa correta. Valida todo o arquivo. Caso haja inconsistencia, o arquivo será rejeitado
	For nX := 2 to len(aDados)

		If !SM0->(dbSeek( cEmpAnt + aDados[nX][1] ) ) 
			cErro 	:= "A filial "+Alltrim(aDados[nX][1])+" pertence a outra empresa. Verifique a linha "+Alltrim(Str(nX))+" ."
			aAdd(aErros, cErro)
			lRet := .F.
		EndIf

		If cFilant <> aDados[nX][1] 
			cErro 	:="A filial "+Alltrim(aDados[nX][1])+" não é a filial corrente. Verifique a linha "+Alltrim(Str(nX))+" ."
			aAdd(aErros, cErro)
			lRet := .F.
		EndIf
		//Procurando por ordem igual para o mesmo produto principal
		If cCodAnt == aDados[nX][2] .and. cOrdem == aDados[nX][3]
			cErro 	:="A ordem não deve ser igual para 1 produto origem e diversos alternativos. Verifique a linha "+Alltrim(Str(nX))+" ."
			aAdd(aErros, cErro)
			lRet := .F.
		EndIf

		If !SB1->(MsSeek(cFilAnt+aDados[nX][2])) 
			cErro 	:= "O produto acabado "+Alltrim(aDados[nX][2])+" na linha "+Alltrim(Str(nX))+" não está cadastrado para a filial "+Alltrim(aDados[nX][1])
			aAdd(aErros, cErro)
			lRet := .F.
		Else
			If SB1->B1_TIPO <> "ME" 
				cErro 	:= "O produto acabado "+Alltrim(aDados[nX][2])+" deve ser do tipo 'ME' na linha "+Alltrim(Str(nX))
				aAdd(aErros, cErro)
				lRet := .F.
			EndIf
		EndIf

		If !SB1->(MsSeek(cFilAnt+aDados[nX][4])) 
			cErro 	:= "O produto alternativo "+Alltrim(aDados[nX][4])+" na linha "+Alltrim(Str(nX))+" não está cadastrado para a filial "+Alltrim(aDados[nX][1])
			aAdd(aErros, cErro)
			lRet := .F.
		EndIf

		If aDados[nX][2] == aDados[nX][4] 
			cErro 	:= "O produto alternativo "+Alltrim(aDados[nX][3])+" na linha "+Alltrim(Str(nX))+" não deve ser igual ao produto principal "
			aAdd(aErros, cErro)
			lRet := .F.
		EndIf

		If !(aDados[nX][5]$'MD') 
			cErro 	:= "A conversao deve ser M=Multiplicação;D=Divisão na linha "+Alltrim(Str(nX))
			aAdd(aErros, cErro)
			lRet := .F.
		EndIf

		If !(aDados[nX][7]$'SN')
			cErro 	:= "O campo EntraMRP deve estar preenchido com 'S' ou 'N' na linha "+Alltrim(Str(nX))
			aAdd(aErros, cErro)
			lRet := .F.
		EndIf

		If Empty(aDados[nX][3])
			cErro 	:="O campo Ordem deve estar preenchido na linha "+Alltrim(Str(nX))
			aAdd(aErros, cErro)
			lRet := .F.
		EndIf
		If Empty(aDados[nX][5])
			cErro 	:="O campo Fator Conv. deve estar preenchido na linha "+Alltrim(Str(nX))
			aAdd(aErros, cErro)
			lRet := .F.
		EndIf
		cCodAnt := aDados[nX][2]
		cOrdem  := aDados[nX][3]
	Next nX
	If !lRet
		nRetMsg := Aviso("Atenção","Existem erros no arquivo. Verifique o Log de Erros. ", {"Gera Log.Erros","Fechar"}, 2)
		If nRetMsg == 1
			fSalvArq()
		EndIf
	EndIf

Return lRet
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
		cArqCPag := cFileNom+"Erro_SGI.txt"
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
