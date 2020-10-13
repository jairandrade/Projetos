#Include "Protheus.ch"
#Include "TopConn.CH"
#Include "rwmake.ch"
#Include "TBICONN.CH"
#Include "TryException.CH"
/*
+----------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina		                                             !
+------------------+---------------------------------------------------------+ 
!Módulo            ! COMPRAS    		                                     !
+------------------+---------------------------------------------------------+
!Nome              ! COMX005                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Importação de Alteração de Pedidos de compras   	     !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                  		     !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 21/07/2020                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!											!           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/  
User Function COMX005(aEmpresa)
	Local cEmp     := aEmpresa[01] 
	Local cFil     := aEmpresa[02] 
	Local na       := 0
	Local nAux     := 0
	Local aParam   := {}
	Local nRecL    := 0
	Local cAuxLog  := ""
	Local cKeyLock := "IMPSC7"+aEmpresa[01]+aEmpresa[02]
	Local lRet	   := .T.
	Local cUserProc:= ""
	Private oEventL:=Nil  
	Private cxNUserSC7

	nAux:=ThreadId()
	ConOut("The process "+AllTrim(Str(nAux))+"has been started.")

	// -> Executa processo para todas as empresas
	Aadd(aParam,{cEmp,cFil})
	na:=1
	RPcSetType(3) 
	RpcSetEnv( aParam[na,1],aParam[na,2],'ressuprimento' ,'123' ,'COM' , GetEnvServer() )
	OpenSm0(aParam[na,1], .f.)
	SM0->(dbSetOrder(1))
	SM0->(dbSeek(aParam[na,1]+aParam[na,2]))
	nModulo := 2
	cEmpAnt := SM0->M0_CODIGO
	cFilAnt := SM0->M0_CODFIL

	// -> Verifica se o processo está em execução e, se tiver não executa o processo
	If LockByName(cKeyLock,.F.,.T.)
		ConOut("==>SEMAFORO: IMPSC7 em "+DtoC(Date()) + ": STARTED.")
	Else
		UnLockByName(cKeyLock,.F.,.T.)	
		RpcClearEnv()
		ConOut("==>SEMAFORO: IMPSC7 em "+DtoC(Date()) + ": RUNNING...")
		nAux:=ThreadId()
		ConOut("The IMPSC7 process "+AllTrim(Str(nAux))+" has been finished.")
		KillApp(.T.)
		Return("")
	EndIf

	// -> inicializa o Log do Processo de IMPSC7 das unidades de negócio
	oEventL   :=EventLog():start("IMPSC7 - ALTERA PED.COMPRAS", dDataBase, "Iniciando processo de alteração de pedido de compras...","DEMPROJ", "SC7", "IMPSC7 | ")
	nRecL     :=oEventL:GetRecno()
	//cFunNamAnt:= FunName()
	//SetFunName("COMX005")

	cAuxLog:="IMPSC7 | " + ": Executando processo de IMPSC7..." 
	ConOut(cAuxLog)                              
	oEventL:SetAddInfo(cAuxLog,"")

	oEventL:setCountOk()

	// -> Verifica o usuário utilizado no processo
	PswOrder(2)
	If !PswSeek("ressuprimento", .T. )
		cAuxLog:="IMPSC7 | " + "Usuario 'ressuprimento' nao encontrado. Favor criar usuario pelo configurador."
		ConOut(cAuxLog)                              
		oEventL:SetAddInfo(cAuxLog,"")
		oEventL:Finish()
		//SetFunName(cFunNamAnt)
		RpcClearEnv()
		ConOut("==>SEMAFORO: IMPSC7 em "+DtoC(Date()) + ": RUNNING...")
		nAux:=ThreadId()
		ConOut("The IMPSC7 process "+AllTrim(Str(nAux))+" has been finished.")
		KillApp(.T.)
		Return("")
	Else
		cUserProc:=PswID()
	EndIf

	// -> Executa o procsso de importacao da previsão de vendas do Prophix
	cAuxLog:="IMPSC7 | " + ": Etapa 01 - Importacao das alteracoes de compras..." 
	ConOut(cAuxLog)                              
	oEventL:SetAddInfo(cAuxLog,"")
	lRet  :=U_COMX005I(oEventL)

	//SetFunName(cFunNamAnt)

	// -> DestRava o semaforo
	If oEventL <> Nil
		oEventL:finish()
	EndIf
	UnLockByName(cKeyLock,.F.,.T.)	
	RpcClearEnv()
	ConOut("==>SEMAFORO: IMPSC7 em "+DtoC(Date()) + ": FINISHED...")
	nAux:=ThreadId()
	ConOut("The IMPSC7 process "+AllTrim(Str(nAux))+"has been finished.")
	KillApp(.T.)

Return("")
/*-----------------+---------------------------------------------------------+
!Nome              ! COMX005I                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Importação das demandas restaurantes                    !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos			                                     !
+------------------+---------------------------------------------------------!
!Data              ! 30/07/2020                                              !
+------------------+--------------------------------------------------------*/
// Espera-se que arquivos estejam na pasta \import\prophix do servidor
//   Nome do arquivo SC7_UUUUUUUUUU.csv onde UUUUUUUUUU -> identificador da unidade 
//   Campos do arquivo
//C7_FILIAL; C7_NUM; C7_DATPRF; C7_PRODUTO; C7_QUANT ,C7_USERA
//02MDST0016;000329;20200801;20101500000500 ;26;jair.andrade  
//		  |  	   |	   |			|	 |		+->usuario alterou	
//        |        |       |   			|    +-> quantidade necessaria   
//        |        |       |   			+-> codigo do produto   
//        |        |       +-> data do pedido   
//        |        +-> pedido de compras ja incluido no Protheus   
//        +-> codigo da unidade (igual ao que consta no nome do arquivo) 
user Function COMX005I(oEventL)
	Local aFiles      := {}
	Local nX	      := 0
	Local nZ	      := 0
	Local cDirBase    := "\IMPORT\PROPHIX\IMPSC7\"
	Local lErro       := .F.
	Local cStartPath  := ""
	Local c2StartPath := "\import\prophix\IMPSC7\imp\'
	Local cAuxLog     := ""      
	Local oError
	local cFile 	:= ""
	Local na       := 0
	Local nAux     := 0
	Local aParam   := {}
	Local nRecL    := 0
	Local cPedido  := ""
	Local cCodigo := ""
	Local nPosItem := 0
	Local nHandle  :=0
	Local cLine
	Local nRecs := 0
	Local nPreco := 0
	Local nVlrQtd:= 0
	Local cVlrQtd := ""
	Local cFlSC7,cCodFSC7,cLojFSC7,cC7PRODUTO
	Local aDados 	:= {}
	Local cPathTmp:= "\DIRDOC\"
	Local cArqTmp := "SC7_ERROR.txt"
	Local cItemNovo := ""
	Local aLogAux:= {}
	Private aCabec := {}
	Private aItens := {}
	Private aLinha := {}
	PRIVATE lMsErroAuto := .F.

	cAuxLog:="IMPSC7 | " + ": Importando arquivo(s)..." 
	ConOut(cAuxLog)                              
	aadd(aLogAux,{cAuxLog,""})

	cStartPath 	:= cDirBase 
	c2StartPath	:= cDirBase+"imp\"

	//CRIA DIRETORIOS
	MkFullDir(cDirBase)
	MakeDir(Trim(cStartPath)) //CRIA DIRETORIO ENTRADA
	MakeDir(c2StartPath) //CRIA DIRETORIO ANO

	aFiles := Directory(cStartPath +"SC7"+cFilAnt+"*.CSV")
	dbSelectArea("ZWS")
	ZWS->(dbSetOrder(1))
	For nX := 1 To Len(aFiles)
		cAuxLog:="IMPSC7 | " + ": Lendo arquivo " +AllTrim(aFiles[nX,1]) + "..." 
		ConOut(cAuxLog)
		aadd(aLogAux,{cAuxLog,""})
		cFile   := aFiles[nX,1]                              
		// -> Abre o arquivo
		nHandle := FT_FUSE(cStartPath+cFile)  //cStartPath //D:\TOTVS\microsiga\protheus12\ambientes\qa\import\prophix
		if nHandle < 0
			lErro  :=.T.
			cAuxLog:="IMPSC7 | " + "Erro ao abrir o arquivo." 
			oEventL:broken("No arquivo.", cAuxLog, .T.)
			Conout(cAuxLog)
		Else
			// -> Processa arquivo de demanda
			FT_FGoTop()
			While !FT_FEOF()
				nRecs++
				// -> Pula a primeira linha
				If nRecs <=1
					FT_FSkip()
					Loop				
				EndIf

				lErro := .F.
				cLine := FT_FReadLN()
				AADD(aDados,Separa(cLine,";",.T.))
				FT_FSkip()

			Enddo
			// Fecha o Arquivo
			FT_FUSE()
			dbSelectArea("SC7")
			dbSetOrder(1)
			cAuxLog :="IMPSC7 | " + ": Carregando novas demanda..." 
			ConOut(cAuxLog)                              
			aadd(aLogAux,{cAuxLog,""})
			For nZ:=1 to Len(aDados)
				If cPedido <> aDados[nZ][2]
					cPedido 	:= aDados[nZ][2]
					cxNUserSC7	:= aDados[nZ][6]
					aCabec		:= {}
					aItens		:= {}
					cFlSC7		:= ""
					cCodFSC7	:= ""
					cLojFSC7 	:= ""
					cC7PRODUTO	:= ""
					cItemNovo 	:= PADL("0",Len(SC7->C7_ITEM),"0")
					nPreco 		:= 0

					If SC7->(DbSeek(cFilAnt+cPedido))//verifica se o pedido existe
						cFlSC7		:= SC7->C7_FILIAL
						cCodFSC7	:= SC7->C7_FORNECE
						cLojFSC7 	:= SC7->C7_LOJA
						cC7PRODUTO	:= SC7->C7_PRODUTO
						aadd(aCabec,{"C7_NUM" ,SC7->C7_NUM})
						aadd(aCabec,{"C7_EMISSAO" ,SC7->C7_EMISSAO})
						aadd(aCabec,{"C7_FORNECE" ,SC7->C7_FORNECE})
						aadd(aCabec,{"C7_LOJA" ,SC7->C7_LOJA})
						aadd(aCabec,{"C7_COND" ,SC7->C7_COND})
						aadd(aCabec,{"C7_CONTATO" ,"AUTO"})
						aadd(aCabec,{"C7_FILENT" ,cFilAnt})
						While SC7->(!Eof()) .AND. cFilAnt == SC7->C7_FILIAL .AND. cPedido == SC7->C7_NUM
							aLinha := {}
							//Valida o ultimo item do pedido de compras para incluir o proximo item
							If SC7->C7_ITEM > cItemNovo
								cItemNovo := PADL(SC7->C7_ITEM,Len(SC7->C7_ITEM),"0")
							EndIf
							aadd(aLinha,{"C7_ITEM",SC7->C7_ITEM,Nil})
							aadd(aLinha,{"C7_PRODUTO",SC7->C7_PRODUTO,Nil})
							aadd(aLinha,{"C7_QUANT",SC7->C7_QUANT,Nil})
							aadd(aLinha,{"C7_PRECO",SC7->C7_PRECO,Nil})
							aadd(aLinha,{"C7_TOTAL",SC7->C7_TOTAL,Nil})
							aadd(aLinha,{"C7_DATPRF",SC7->C7_DATPRF,Nil})
							aadd(aLinha,{"C7_XUSERA",SC7->C7_XUSERA,Nil})
							aAdd(aLinha,{"LINPOS","C7_ITEM" ,SC7->C7_ITEM})
							aAdd(aLinha,{"AUTDELETA","N" ,Nil})
							aadd(aLinha,{"C7_REC_WT" ,SC7->(RECNO()) ,Nil})
							aadd(aItens,aLinha)
							SC7->(dbSkip())
						EndDo
						For nY:=1 to Len(aDados)
							If 	cPedido == aDados[nY][2]
								//Verifica o produto do arquivo e compara no pedido se o produto existe. Caso exista, altera a quantidade
								nPosItem := aScan(aItens,{|x| AllTrim(x[2][2]) == alltrim(aDados[nY][4])})
								cVlrQtd:= StrTran( aDados[nY,5],",", "." )//retira virgula
								nVlrQtd:= Val(cVlrQtd)
								If nPosItem > 0
									if Val(aDados[nY][5]) = 0// SE quantidade == 0 exclui o item do pedido
										aItens[nPosItem][9][2] :="S"
									Else// SE quantidade > 0 altera o item do pedido
										aItens[nPosItem][3][2] :=nVlrQtd//quantidade
										aItens[nPosItem][5][2] :=nVlrQtd * aItens[nPosItem][4][2] //quantidade * SC7->C7_PRECO
										aItens[nPosItem][6][2] :=STOD(aDados[nY][3])//data entrega
										aItens[nPosItem][9][2] :=alltrim(aDados[nY][6])//usuario alterou
									EndIf
								ELSE//INCLUI UM NOVO ITEM CASO EXISTA
									if nVlrQtd > 0// SE quantidade == 0 nao grava o item do pedido já que nao encontrou o item na validacao acima
										cC7PRODUTO	:= aDados[nY][4]
										nPreco :=COMX005P(cFlSC7,cCodFSC7,cLojFSC7,cC7PRODUTO)                                                                          
										aLinha := {}
										aadd(aLinha,{"C7_ITEM",Soma1(cItemNovo),Nil})
										aadd(aLinha,{"C7_PRODUTO",aDados[nY][4],Nil})
										aadd(aLinha,{"C7_QUANT",nVlrQtd,Nil})
										aadd(aLinha,{"C7_PRECO",nPreco,Nil})
										aadd(aLinha,{"C7_TOTAL",nVlrQtd * nPreco,Nil})
										aadd(aLinha,{"C7_DATPRF",STOD(aDados[nY][3]),Nil})
										aadd(aItens,aLinha)
									EndIf
								EndIf
							EndIf
						Next nY

						TRYEXCEPTION
						//Processa Arquivo
						// -> Inicializa a gravação dos dados no destino
						Begin Transaction
							cAuxLog :="IMPSC7 | " + ": Alterando pedido "+cPedido+"..." 
							ConOut(cAuxLog)                              
							aadd(aLogAux,{cAuxLog,""}) 
							// Alteração
							MSExecAuto({|v,x,y,z| Mata120(v,x,y,z)},1,aCabec,aItens,4)
							If lMsErroAuto
								lErro   := .T.
								cAuxLog :=cArqTmp
								cAuxLog :=MostraErro( cPathTmp, cAuxLog )
								ConOut(cAuxLog)                              
								aadd(aLogAux,{cAuxLog,""})
								cAuxLog := "IMPSC7 | " + "Erro na alteracao do pedido de compras "+cPedido+" ."
								ConOut(cAuxLog)                              
								aadd(aLogAux,{cAuxLog,""}) 
								DisarmTransaction()
								Break
							EndIf
						End Transaction
						CATCHEXCEPTION USING oError
						lErro  :=.T.
						cAuxLog:="IMPSC7 | " + procname()+"("+cValToChar(procline())+")" + oError:Description 
						Conout(cAuxLog + Chr(13) + Chr(10) + 'Detalhamento :'+varinfo('oError',oError))
						ENDEXCEPTION
					EndIf
					If lErro
						Exit
					Else
						// -> Gerando log do processo
						cAuxLog :="IMPSC7 | " + ": Pedido de compra "+cPedido+" alterado..." 
						ConOut(cAuxLog)                              
						aadd(aLogAux,{cAuxLog,""})  						
					EndIf
				EndIf

			Next nZ

		EndIf
	Next nX   
	// Se não ocorreu erro no procesamento, atualiza o arquivo
	If !lErro
		oEventL:setCountInc()
		// -> Move Arquivo Lido
		cArqTXT := cStartPath+cFile
		cNomNovArq  := UPPER(c2StartPath+strtran(cFile,".","_"+dtos(date())+"."))
		// - > copia o arquivo antes da transacao
		fErase(cNomNovArq)
		If __CopyFile(cArqTXT,cNomNovArq)
			// Apaga um arquivo no TOTVS Smart Client
			If FErase(cArqTXT) == -1
				cAuxLog := "IMPSC7 | " + "Falha na delecao do Arquivo."
			Else
				cAuxLog := "IMPSC7 | " + "Arquivo deletado com sucesso."
			Endif
			conout(cAuxLog)
		EndIf

	EndIf	
	// -> Gerando log do processo
	cAuxLog :="IMPSC7 | " + ": Atualizando log..." 
	ConOut(cAuxLog)                              
	oEventL:SetAddInfo(cAuxLog)    						
	For nx:=1 to Len(aLogAux)
		oEventL:SetAddInfo(aLogAux[nx,1])
	Next nx 

	cAuxLog:="IMPSC7 | " + ": "+ AllTrim(Str(Len(aFiles))) + " arquivo(s) importando(s)." 
	ConOut(cAuxLog)                              
	oEventL:SetAddInfo(cAuxLog)    		                         

	lErro:=IIF(Len(aFiles) <= 0,.T.,lErro)
	cAuxLog:=IIF(lErro,"IMPSC7 | " + "Erro.","IMPSC7 | " + "Ok.") 
	ConOut(cAuxLog)                              
	oEventL:SetAddInfo(cAuxLog,"")

Return(!lErro)
/*-----------------+---------------------------------------------------------+
!Nome              ! MkFullDir - Cliente: Madero                             !
+------------------+---------------------------------------------------------+
!Descrição         ! Criacao de estrutura completa de diretorio              !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function MkFullDir(cDir)
	local cBase := ""
	cDir := trim(cDir)
	if (left(cDir, 2) != "\\")
		while (!empty(cDir))
			if ("\" $ cDir)
				cBase += substr(cDir, 1, at("\", cDir)-1)
			Else
				cBase += cDir
			EndIf
			if !empty(cBase)
				MakeDir(cBase)
			Endif
			cBase += "\"
			if ("\" $ cDir)
				cDir := substr(cDir, at("\", cDir)+1)
			Else
				exit
			EndIf
		enddo
	EndIf
Return nil  
/*-----------------+---------------------------------------------------------+
!Nome              ! fCriaDir - Cliente: Madero                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Cria pasta              					             !
+------------------+---------------------------------------------------------+
!Autor             ! Thiago Berna - TSM                                      !
+------------------+---------------------------------------------------------!
!Data              ! 08/03/2019                                              !
+------------------+--------------------------------------------------------*/
Static Function fCriaDir(cPatch, cBarra)

	Local lRet   := .T.
	Local aDirs  := {}
	Local nPasta := 1
	Local cPasta := ""
	Default cBarra	:= "\"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criando diretório de configurações de usuários.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDirs := Separa(cPatch, cBarra)
	For nPasta := 1 to Len(aDirs)
		If !Empty (aDirs[nPasta])
			cPasta += cBarra + aDirs[nPasta]
			If !ExistDir (cPasta) .And. MakeDir(cPasta) != 0
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nPasta

Return lRet
/*-----------------+---------------------------------------------------------+
!Nome              ! COMX005P - Cliente: Madero                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Retornar valor de 1 produto de acordo com tabela precos !
+------------------+---------------------------------------------------------+
!Autor             ! JAIR MATOS			                                     !
+------------------+---------------------------------------------------------!
!Data              ! 05/08/2020                                              !
+------------------+--------------------------------------------------------*/
Static Function COMX005P(cFlSC7,cCodFSC7,cLojFSC7,cC7PRODUTO)
	Local aArea     :=GetArea()
	Local cQuery    := ""
	Local cAliasQry	:= GetNextAlias()
	Local nVlrPreco := 0

	// -> Pesquisa item no cadastro de produtos x fornecedor
	cQuery :="SELECT AIB_PRCCOM" + CRLF 
	cQuery +="FROM " + RetSQLName("AIB") + "  "          + CRLF 
	cQuery +="WHERE AIB_FILIAL  = '" + cFlSC7 + "' AND " + CRLF  
	cQuery +=" AIB_CODFOR = '" + cCodFSC7     + "' AND " + CRLF
	cQuery +=" AIB_LOJFOR = '" + cLojFSC7     + "' AND " + CRLF
	cQuery +=" AIB_CODPRO = '" + cC7PRODUTO   + "' AND " + CRLF
	cQuery += " D_E_L_E_T_ = ' ' "               + CRLF
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)	   
	(cAliasQry)->(DbGoTop())
	If !(cAliasQry)->(Eof())
		nVlrPreco := (cAliasQry)->AIB_PRCCOM
	EndIf

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)

Return nVlrPreco