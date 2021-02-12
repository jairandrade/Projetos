/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** Importacao / update do cadastro de produtos a partir de arquivo csv.                                                         **/
/** Autor: luiz henrique jacinto                                                                                                 **/
/** RSAC Soluções                                                                                                                **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/                          
/** 21/02/2018 | Luiz Henrique Jacinto          | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"

Static cLogfile := "\logs\KFATA03.LOG"
Static nStart	:= 0

#Define ENTER CHR(13)+CHR(10)

/**********************************************************************************************************************************/
/** user function KFATA03()                                                                                                      **/
/** Importacao de dados no cadastro de produtos.                                                                                 **/
/**********************************************************************************************************************************/
User Function KFATA03()
	// arquivo
	Local cFileDir	:= ""
	Local _cUsr		:= AllTrim(UPPER(GetMv("KA_KFAT05U",,"RSAC/ALUISIO")))
	Local cUsrAtu	:= UsrRetName( RetCodUsr() )
	Local oFileDir
	
	IF !cUsrAtu $ _cUsr
		MsgStop("Usuáro sem permissão.")
		Return
	Endif
	
	// dimensoes da tela de anexos
	Define MsDialog oDlgAnx from 001, 001 to 150, 500 title "Atualização de cadastro de produtos" pixel
	
	// box selecao arquivo
	@ 002, 002 to 025, 250 Label "" of oDlgAnx pixel
	@ 005,018 Say "Importação de novos produtos ou de atualizacao de campos do cadastro de " of oDlgAnx Pixel
	@ 013,018 Say "produtos através de arquivo de texto separado por virgulas (arquivo.csv)." of oDlgAnx Pixel
	
	// box selecao arquivo
	@ 028, 002 to 058, 250 Label "[ Selecione o Arquivo ]" of oDlgAnx pixel
	
	// botao abrir
	@ 040, 005 Button "Abrir" Size 20,12 Action cFileDir := Abrir(cFileDir) of oDlgAnx Pixel
	// caminho selecionado
	@ 040, 026 MsGet oFileDir Var cFileDir Size 222,10 Picture "@!" When .F. of oDlgAnx Pixel
	
	// botao confirmar
	@ 060, 188 Button "Confirmar" Size 30,11 Action { || Processa( {|| Proces(cFileDir) }, "Processando..."	),oDlgAnx:End() } When !Empty( AllTrim( cFileDir ) ) of oDlgAnx Pixel
	
	// botao fechar
	@ 060, 220 Button "Fechar" Size 30,11 Action oDlgAnx:End() of oDlgAnx Pixel
	
	// ativa a tela
	Activate MsDialog oDlgAnx Centered
	
	// copia e abre o arquivo
	copyAndOpenFile(cLogFile)
	
Return

/**********************************************************************************************************************************/
/** static function abrir()                                                                                                      **/
/** Seleciona o arquivo a ser importado.                                                                                         **/
/**********************************************************************************************************************************/
Static Function Abrir(cArquivo)
	Local	cRet		:= ""
	Default cArquivo 	:= ""
	
	// monta tela de selecao
	cRet := cGetFile('Arquivos CSV (*.CSV) | *.CSV', 'Arquivos CSV', 1, 'C:\', .T., GETF_LOCALHARD, .F.	)
	
	// se selecionou algum arquivo
	If Empty(AllTrim(cRet))
		// atualiza o retorno
		cRet := cArquivo
	Endif
	
	// retorna
Return cRet

/**********************************************************************************************************************************/
/** Static function Proces()                                                                                                     **/
/** inicia o procesamento                                                                                                        **/
/**********************************************************************************************************************************/
Static function Proces(cArquivo)
	Local 	aRet	:= {}
	// cabecalho
	Local	aCab	:= {}
	// dados
	Local	aDados	:= {}
	// mensagem
	Local	cMsg	:= ""
	
	// valida se o arquivo foi lido
	If !File(cArquivo)
		// exibe msg de erro
		MsgAlert("Problema na leitura do arquivo - Arquivo não encontrado")
		// sai da rotina
		Return
	Else
		// pergunta se tem certeza para continuar
		If !MsgYesNo(OemToAnsi("Esta rotina irá importar dados de acordo com o arquivo informado! Deseja Continuar ?"))
			// retorna
			Return
		Endif
		
		// inicio processamento
		nStart := Seconds()
		
		
		WriteLog("Inicio processamento.")
		WriteLog( RetCodUsr()+" - "+ UsrRetName( RetCodUsr() ) )
		WriteLog(cArquivo)
		
		WriteLog("Inicio leitura do arquivo.")
		
		// faz a leitura do arquivo
		Processa({|| aRet := Import(cArquivo)}, "Lendo Arquivo..."			)
		
		WriteLog("Fim leitura do arquivo.")
		
		// cabecalho da tabela
		aCab 	:= aClone(aRet[1])
		// dados a serem importados
		aDados 	:= aClone(aRet[2])
		
		WriteLog("Inicio gravacao dos registros.")
		// grava os dados na tabela
		Processa({|| Gravar(aCab,aDados) }, "Atualizando Dados...")
		
	Endif
	
Return

/**********************************************************************************************************************************/
/** Static Function Import(0                                                                                                     **/
/** abre o arquivo, le os dados e retorna um array com o cabecalho e outro com os dados                                          **/
/**********************************************************************************************************************************/
Static Function Import(cArquivo)
	// armazenará a leitura da linha
	Local cBuffer 	:= ""
	// armazenara um array contendo a leitura da linha convertida um array
	Local aLinha  	:= {}
	// cabecalho
	Local aCab		:= {}
	// dados
	Local aDados	:= {}
	// retorno
	Local aRet		:= Array(2)
	
	// função para abertura do arquivo a ser importado
	FT_FUSE(cArquivo)
	// quantidade de registros a serem lidos
	ProcRegua(FT_FLASTREC())
	// INICIO DO ARQUIVO
	FT_FGOTOP()
	
	// INCRMENTA A RÉGUA DE PROCESSAMENTO
	IncProc()
	// realiza a leitura da primeira linha do arquivo com o nome dos campos da tabela
	cBuffer := UPPER( FT_FREADLN() )
	// primeira linha com cabecalho do arquivo e nome dos campos a serem gravados
	aCab  	:= Separa(cBuffer,';',.T.)
	// pula a linha
	FT_FSKIP()
	
	// faz loop no arquivo
	While !FT_FEOF()
		
		// INCRMENTA A RÉGUA DE PROCESSAMENTO
		IncProc()
		
		// realiza a leitura da linha no arquivo
		cBuffer := FT_FREADLN()
		// converte conteúdo da leitura da linha em array para o array aLinha.
		aLinha  := Separa(cBuffer,';',.T.)
		// adiciona no array principal
		aADD(aDados, aLinha)
		// próxima linha
		FT_FSKIP()
		
	EndDo
	
	// fecha arquivo
	FT_FUSE()
	
	// monta array de retorno
	aRet[1] := aClone(aCab)
	// monta array de retorno
	aRet[2] := aClone(aDados)
	
	// retorna
Return aRet

/**********************************************************************************************************************************/
/** static function Grava()                                                                                                      **/
/** abre o arquivo, le os dados e retorna um array com o cabecalho e outro com os dados                                          **/
/**********************************************************************************************************************************/
static function Gravar(aCab,aDados)
	// retorno
	Local lRet		:= .T.
	// posicao
	Local nPos		:= 0
	// cabecalho
	Local aHead		:= {}
	// dados
	Local nDados	:= 0
	// posicao codigo
	Local nPosCod	:= aScan(aCab,"B1_COD")
	// mensagem
	Local cMsg		:= ""
	// elap
	Local nElap 	:= 0
	// elap
	Local cElap		:= ""
	// contador
	Local nY		:= 0
	// contador
	Local nAux		:= 0
	
	// inicia nova regua
	ProcRegua( Len(aDados)-2 )
	
	// valida se o nome da tabela foi
	If !ChkFile("SB1")
		// exibe msg de erro
		MsgStop("Tabela informada não localizada.")
		// altera retorno
		lRet	:= .F.
		// retorna
		Return lRet
		// achou a tabela
	Else
		// flag existe campo
		lExiste	:= .F.
		//abre a tabela
		DbSelectArea("SB1")
		// faz loop no cabecalho
		For nY := 1 to Len(aCab)
			// retorna a posicao do campo na tabela
			nPos :=  FieldPos( AllTrim( aCab[nY] ) )
			// se localizou
			If nPos > 0
				// atualiza a flag
				lExiste	:= .T.
				// obtem os dados
				aTam	:= TamSx3( AllTrim( aCab[nY] ) )
			// se nao localizou
			Else
				// atualiza os dados
				aTam	:= {0,0,""}
			Endif
			// adiciona dados ao array auxiliar
			aadd(aHead,{ AllTrim(aCab[nY]) ,nPos, aTam[1],aTam[2],aTam[3] } )
		Next
		
		// se campos existem
		If !lExiste
			// grava no log
			WriteLog("Nenhum campo informado no arquivo foi localizado na tabela para gravacao. Favor verificar")
			// exibe msg derro
			MsgStop("Nenhum campo informado no arquivo foi localizado na tabela para gravacao. Favor verificar")
		Else
			// inicia transacao
			Begin Transaction
				// abre a tabela
				DbSelectArea('SB1')
				// altera o indice
				SB1->( DbSetOrder(1) )
				// faz loop nos dados
				For nAux := 1 To Len(aDados)
				
					// incrementa a regua
					IncProc()
					// zeram mensagem
					cMsg := ""
					
					// valida se a linha nao tem todas as colunas
					if Len( aDados[nAux] ) <> Len(aHead)
						// proximo registro
						Loop
					Endif
					
					// codigo do produto
					cCod		:= Padr( AllTrim( aDados[nAux][nPosCod] ),TamSx3("B1_COD")[1] )
					
					// se codigo em branco
					If Empty(AllTrim(cCod) )
						// proximo registro
						Loop
					Endif
					
					// log
					cMsg 		:= cCod
					// achou o registro?
					lLocaliz 	:= SB1->( MsSeek( xFilial("SB1")+cCod,.T. ) )
					
					// se achou
					If lLocaliz
						// atualiza o log
						cMsg	+= "|Alterado"
					// se nao achou
					Else
						// sai do EOF
						SB1->( DbGoTop() )
						// atualiza o log
						cMsg	+= "|Incluido"
					Endif
					
					// manda gravar o log
					WriteLog(cMsg)
					
					DbSelectArea("SB1")
					
					// trava o registro
					RecLock("SB1",!lLocaliz)
					
						// se novo registro
						If !lLocaliz
							// atualiza a filial
							SB1->B1_FILIAL 	:= xFilial("SB1")
							// atualiza o codigo
							SB1->B1_COD		:= cCod
						Endif
						
						// contador
						nDados++
						// faz loop no cabecalho
						For nY := 1 to Len(aHead)
							// valida se o campo existe
							If aHead[nY][2] > 0 .AND. !aHead[nY][1] == 'B1_COD'
								// atribui o valor do campo
								_Valor	:= aDados[nAux][nY]
								// se o campo é data
								If aHead[nY][5] == "D"
									// converte para data
									_Valor	:= CtoD( _Valor )
								// se numero
								ElseIf aHead[nY][5] == "N"
									// converte para numerico
									_Valor	:= Val( _Valor )
								// se char
								ElseIf aHead[nY][5] == "C"
									// se maior que o tamanho do campo
									If Len( AllTRim(_Valor) ) > aHead[nY][3]
										// corta o campo
										_Valor := Substr(_Valor,1,aHead[nY][3])
									Endif
								Endif
								// grava o campo
								FieldPut(aHead[nY][2]	,_Valor	)
							Endif
						Next
					// destrava o registro
					MsUnLock("SB1")
				Next
			// desfaz transacao
			End Transaction
			
		Endif
		
		// tempo de procesamento
		nElap := Seconds() - nStart
		// texto do tempo
		cElap := cValToChar(nElap)+" segundos"
		
		// se maior que um minuto
		If nElap > 60
			// converte para minutos
			nElap := Round(nElap/60,2)
			// texto do tempo
			cElap := cValToChar(nElap)+" minutos"
		Endif
		
		// se processou
		If lExiste
			// monta msg
			cMsg := "Importação concluida."+ENTER
			// atualiza dados
			cMsg += "Foram incluídos ou alterados "+cValToChar(nDados)+" registros em "+cElap+"."
			
		// se nao pocessou
		Else
			cMsg := "Processo terminado."
			// atualiza dados
			cMsg += "Tempo de processamento "+cElap+"."
		Endif
		
		// escreve no log
		WriteLog(cMsg)
		
		// exibe msg de fim
		MsgInfo ( cMsg )
		
	Endif
	
	// retorno
return lRet

/**********************************************************************************************************************************/
/** static function criaPasta()                                                                                                  **/
/** cria estrutura de pastas                                                                                                     **/
/**********************************************************************************************************************************/
Static Function criaPasta(cCaminho)
	// posicao da barra
	Local nAt		:= 0
	// original
	Local cOrigem	:= cCaminho
	// temporario
	Local cTemp		:= "\"
	// arquivos
	Local aArq		:= ""
	// ultima pasta
	Local nRat		:= rat("\",cOrigem)
	
	// faz loop
	While cTemp <> Substr(cOrigem,1,nRat)
		// localiza a proxima barra
		nAt		:= at('\',cOrigem,Len(cTemp)+1)
		// corta o caminho original
		cTemp 	:= Substring(cOrigem,1,nAt)
		
		// obtem os arquivos
		aArq	:= Directory(cTemp+"*","D")
		
		// se pasta vazia
		If Empty(aArq)
			// cria a pasta
			MakeDir(cTemp)
		Endif
		
	Enddo 
	
	// retorna
Return

/**********************************************************************************************************************************/
/** static function convertData()                                                                                                **/
/** converte data para formato brasileiro com 4 digitos no ano                                                                   **/
/**********************************************************************************************************************************/
Static Function convertData(sData)
// retorna a data convertida com 4 digitos para o ano
Return Substr(sData,7,2)+"/"+Substr(sData,5,2)+"/"+Substr(sData,1,4)
 

/**********************************************************************************************************************************/
/** static function cdateTime()                                                                                                  **/
/** retorna a data com 4 digitos no ano e a hora.                                                                                **/
/**********************************************************************************************************************************/
Static Function cdateTime()
// retorna a data atual convertida com 4 digitos e a hora atual 
Return convertData( DtoS( Date() ) )+"|"+ Time()

/**********************************************************************************************************************************/
/** static function WriteLog()                                                                                                   **/
/** escreve o texto no log.                                                                                                      **/
/**********************************************************************************************************************************/
Static Function WriteLog(cTexto)
	// handle do arquivo
	Local nHdlLog	:= -1
	// retorno
	Local lRet		:= .F.
	
	// cria a pasta do arquivo
	CriaPasta(cLogFile)
	
	// adiciona data e hora ao texto
	cTexto := cdateTime()+"|"+cTexto
	// exibe o texto no console
	conout(cTexto)
	
	// se arquivo de log informado
	If !Empty(AllTrim(cLogFile))
	
		// se o arquivo existe
		If fIle (cLogFile)
			// abre o arquivo
			nHdlLog	:= fOpen(cLogFile,FO_READWRITE	)
		// se nao existe
		Else
			// cria o arquivo
			nHdlLog	:= fCreate(cLogFile,FC_NORMAL	)
		Endif
		
	Endif
	
	// se abriu o arquivo
	If nHdlLog > -1	
		// vai pro final do arquivo
		FSEEK(nHdlLog,0,FS_END)
		// grava o texto
		lRet := FWrite(nHdlLog, cTexto + ENTER)
		// fecha o arquivo
		fClose(nHdlLog)
	Endif
	
	// retorna
Return lRet

/**********************************************************************************************************************************/
/** static function copyAndOpenFile()                                                                                            **/
/** copia o arquivo para o temporario do usuario e abre ele.                                                                     **/
/**********************************************************************************************************************************/
Static Function copyAndOpenFile(_cArq)
	// temporario do usuaro
	Local cTempPath	:= GetTempPath()
	// arquivo do log
	Local cArquivo	:= _cArq
	// ultima \
	Local nPos		:= rAt("\",cArquivo)
	
	// nome do arquivo
	cArquivo := Substr(cArquivo,nPos+1,Len(cArquivo) ) 
	
	// se o arquivo existe
	If File(_cArq)
	
		// copia o arquivo para o tempo do usuario
		__copyFile(_cArq,cTempPath+cArquivo)
	
		// se o arquivo existe no temp do usuario
		If file(cTempPath+cArquivo)
			// abre o arquivo
			ShellExecute( "Open",cTempPath+cArquivo,"",cTempPath,1)
		Endif
		
		// apaga o arquivo de log
		fErase(_cArq)
		
	Endif 
	// retorna
Return