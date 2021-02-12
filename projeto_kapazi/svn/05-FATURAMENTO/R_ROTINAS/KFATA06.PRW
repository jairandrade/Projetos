/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** Importacao / update do cadastro de complemento de produtos a partir do arquivo CSV.                                          **/
/** Autor: luiz henrique jacinto                                                                                                 **/
/** RSAC Soluções                                                                                                                **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/                          
/** 07/03/2018 | Luiz Henrique Jacinto          | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"

Static cLogfile := "\logs\"+AllTrim(FunName())+".LOG"
Static nStart	:= 0

#Define ENTER CHR(13)+CHR(10)

/**********************************************************************************************************************************/
/** user function KFATA06()                                                                                                      **/
/** Importacao de dados no cadastro de produtos.                                                                                 **/
/**********************************************************************************************************************************/
User Function KFATA06()
	// arquivo
	Local cFileDir	:= ""
	
	Local oFileDir
	Local _cEmp		:= cEmpAnt
	Local _cFil		:= cFilAnt
	Local oEmp
	Local oFil
	Local _cUsr		:= AllTrim(UPPER(GetMv("KA_KFAT05U",,"RSAC/ALUISIO")))
	Local cUsrAtu	:= UsrRetName( RetCodUsr() )
	
	IF !cUsrAtu $ _cUsr
		MsgStop("Usuáro sem permissão.")
		Return
	Endif
	
	// dimensoes da tela de anexos
	Define MsDialog oDlgAnx from 001, 001 to 205, 500 title "Movimentação de pedidos" pixel
	
	// box selecao arquivo
	@ 002, 002 to 025, 250 Label "" of oDlgAnx pixel
	@ 005,018 Say "Movimentacao de pedidos de venda entre empresas a partir de arquivo " 			of oDlgAnx Pixel
	@ 013,018 Say "de texto separado por virgulas (*.csv)." 										of oDlgAnx Pixel
	
	// box selecao arquivo
	@ 028, 002 to 058, 250 Label "[ Selecione o Arquivo ]" of oDlgAnx pixel
	
	// botao abrir
	@ 040, 005 Button "Abrir" Size 20,12 Action cFileDir := Abrir(cFileDir) of oDlgAnx Pixel
	// caminho selecionado
	@ 040, 026 MsGet oFileDir Var cFileDir Size 222,10 Picture "@!" When .F. of oDlgAnx Pixel
	
	// box selecao arquivo
	@ 058, 002 to 088, 250 Label "[ Empresa/Filial ]" of oDlgAnx pixel
	
	@ 070, 005 Say "Empresa Destino"	of oDlgAnx Pixel
	// botao 
	@ 069, 055 MsGet oEmp Var _cEmp Size 20,08 Picture "@!" of oDlgAnx Pixel F3 "EMPTQ2" Valid validEmp(_cEmp,.T.) 
	
	@ 070, 090 Say "Filial Destino"	of oDlgAnx Pixel
	// caminho selecionado
	@ 069, 125 MsGet oFil Var _cFil Size 20,08 Picture "@!" of oDlgAnx Pixel F3 "FWSM0" Valid validFil(_cEmp,_cFil,.T.) 
	
	// botao confirmar
	@ 090, 188 Button "Confirmar" Size 30,11 Action { || Processa( {|| Proces(cFileDir,_cEmp,_cFil) }, "Processando..."	),oDlgAnx:End() } When !Empty( AllTrim( cFileDir ) ) .and. !Empty(AllTrim(_cEmp)) .and. !Empty(allTrim(_cFil)) .and. _cEmp+_cFil <> cEmpAnt+cFilAnt of oDlgAnx Pixel
	
	// botao fechar
	@ 090, 220 Button "Fechar" Size 30,11 Action oDlgAnx:End() of oDlgAnx Pixel
	
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
Static function Proces(cArquivo,_cEmp,_cFil)
	Local 	aRet	:= {}
	// cabecalho
	Local	aCab	:= {}
	// dados
	Local	aDados	:= {}
	// mensagem
	Local	cMsg	:= ""
	
	Local 	cEmpBkp	:= cEmpAnt
	Local 	cFilBkp	:= cFilAnt
	Private lSimula	:= .f. //MsgYesNo("Simular processamento?")	 
	Private lCopia	:= MsgYesNo("Copia o pedido?")	 
	Private lExclui	:= MsgYesNo("Exclui pedido?")	 
	
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
		
		WriteLog("Inicio leitura do arquivo.")
		WriteLog(cArquivo)
		WriteLog("Empresa Atual: " + cEmpAnt)
		WriteLog("Filial Atual:  " + cFilAnt)
		WriteLog("Empresa Destino: " + _cEmp)
		WriteLog("Filial Destino:  " + _cFil)
		WriteLog("Simula?  " + iif(lSimula,"Sim","Nao"))
		
		// faz a leitura do arquivo
		Processa({|| aRet := Import(cArquivo)}, "Lendo Arquivo..."			)
		
		WriteLog("Fim leitura do arquivo.")
		
		// cabecalho da tabela
		aCab 	:= aClone(aRet[1])
		// dados a serem importados
		aDados 	:= aClone(aRet[2])
		
		WriteLog("Inicio gravacao dos registros.")
		
		// grava os dados na tabela
		Processa({|| analise(aCab,aDados,_cEmp,_cFil) }, "Atualizando Dados...")
		nElap := Round(Seconds() - nStart,0)
		WriteLog("Processo finalizado. Tempo: "+cValToChar(nElap)+" segundos ")
	Endif
	
	cEmpAnt:= cEmpBkp 
	cFilAnt:= cFilBkp 
	
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
static function analise(aCab,aDados,_cEmpDest,_cFilDest)
	// retorno
	Local lRet		:= .T.
	// mensagem
	Local cMsg		:= ""
	// tabela
	Local nX		:= 0
	// empresa
	Local nPEmp		:= 0
	// filial
	Local nPFil		:= 0
	// pedido
	Local nPPed		:= 0
	Local _cFil		:= ""
	Local _cPed		:= ""
	
	If Empty(aCab) .or. Empty(aDados)
		Return
	Endif
	
	nPEmp	:= aScan(aCab,{|x| "EMPRESA" $ Upper( AllTrim( x ) ) })
	nPFil	:= aScan(aCab,{|x| "FILIAL" $ Upper( AllTrim( x ) ) })
	nPPed	:= aScan(aCab,{|x| "PEDIDO" $ Upper( AllTrim( x ) ) })
	If nPEmp == 0 .or. nPFil == 0 .or. nPPed == 0
		Return
	Endif
	
	// inicia nova regua
	ProcRegua( Len(aDados)-2 )
	
	For nX := 1 to Len(aDados)
		incproc()
		_cEmp	:= aDados[nX][nPEmp]
		_cFil 	:= aDados[nX][nPFil]
		_cPed	:= aDados[nX][nPPed]
		If !Empty(AllTrim(_cEmp)) .and. !Empty(AllTrim(_cFil)) .and. !Empty(AllTrim(_cPed))
			lRet 	:= procPedido(_cEmp,_cFil,_cPed,_cEmpDest,_cFilDest)
		Endif
		/*
		If !lRet
			Exit
		Endif
		*/
	Next
	
	
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

Static Function validEmp(_cEmp,_lMsg)
	Local 	lRet 	:= .T.
	Local	aAreaSM0:= GetArea("SM0")
	
	Default _cEmp	:= "" 
	Default _lMsg	:= .F.
	
	If !Empty(AllTrim(_cEmp))
		SM0->( DbSetOrder(1) )
		SM0->( DbGoTop() )
		If !SM0->( MsSeek(_cEmp))
			lRet := .F.
			
			If _lMsg
				MsgStop("Empresa informada não localizada.")
			Endif
			
		Endif
		
	Endif
	
	RestArea(aAreaSM0)
Return lret

Static Function validFil(_cEmp,_cFil,_lMsg)
	Local 	lRet 	:= .T.
	Local	aAreaSM0:= GetArea("SM0")
	
	Default _cEmp	:= "" 
	Default _cFil	:= ""
	Default _lMsg	:= .F.
	
	If Empty(allTrim(_cEmp)) .and. !Empty(AllTrim(_cFil))
		lRet := .f.
		MsgStop("Informe a empresa antes de informar a filial.")
	Endif
	
	If lRet .and. !Empty(AllTrim(_cEmp)) .and. !Empty(AllTrim(_cFil))
		SM0->( DbSetOrder(1) )
		SM0->( DbGoTop() )
		If !SM0->( MsSeek(_cEmp + _cFil))
			lRet := .F.
			
			If _lMsg
				MsgStop("Conjunto de Empresa e Filial informado não foi localizado.")
			Endif
			
		Endif
		
	Endif
	
	RestArea(aAreaSM0)
Return lRet


/*
Static Function validTab(_cTab,_lMsg,_cObri)
	// retorno
	Local lRet := .T.
	// area
	Local aArea:= GetArea()

	// se preencheu
	If !Empty( AllTrim( _cTab ) )
		
		// abre a tabela
		SX2->( DbSetOrder(1) )
		// vai pro inicio
		SX2->( DbGoTop() )
		
		// localiza a tabela
		If !SX2->( MsSeek(_cTab) )
			// atualiza a msg
			cMsg := "A tabela informada não foi localiada."
			// altera o retorno
			lRet := .F.
		Else
			_cObri	:= AllTrim(getIndice(_cTab)[1])
		Endif
	
	Endif
	
	// restaura a area
	RestArea(aArea)
	// retorna
Return lRet
*/
/*
Static Function getIndice(_cTab)
	Local aItem := {}
	Local aRet	:= {}
	Local cInd	:= "" 
	
	(_cTab)->( DbSetOrder(1) )
	cInd 	:= SqlOrder((_cTab)->(IndexKey()))
	aItem 	:= Separa(cInd,",")
	
	aadd(aRet,cInd)
	aadd(aRet,aItem)
	
Return aRet

Static Function cpoObrigatorio(aHead,aIndice)
	Local lRet 	:= .T.
	Local nX	:= 0
	Local nPos	:= 0
	Local aCpo	:= aIndice[2]
	Local aItem	:= {}
	Local aRet	:= Array(2)
	Local cCampo:= ""
	
	aRet[1] := lRet
	aRet[2] := {}
	
	For nX := 1 to Len(aCpo)
		cCampo := Alltrim( aCpo[nX] )
		
		nPos := aScan(aHead,{|x| Alltrim( x[1] ) == cCampo  } )
		If nPos == 0
			lRet := .F.
			Exit
		Else
			aItem := {}
			aadd(aRet[2], {cCampo,nPos} )
		Endif
	Next
	
	aRet[1] := lRet
		
Return aRet
*/
Static Function procPedido(_cEmpOri,_cFilOri,_cPed,_cEmpDest,_cFilDest)
	Local 	lRet 		:= .T.
	Local 	aCabSC5		:= {}
	Local 	aItensSC6	:= {}
	Local	aItem		:= {}
	Local	nPOper		:= 0
	Local	cOper		:= ""
	//Local	nPProd		:= 0
	Local	cKOp		:= ""
	
	//WriteLog(cEmpAnt+"|"+cFilant+"|"+_cPed+"|Analise Pedido.")
	
	SC5->( DbSetOrder(1) )
	If !SC5->( MsSeek(xFilial("SC5")+_cPed) ) 
		WriteLog(_cEmpOri+"|"+_cFilOri+"|"+_cPed+"|Pedido nao encontrado.")
		Return .F.
	Endif
	
	If !SC5->C5_TIPO == "N"
		WriteLog(cEmpAnt+"|"+xFilial("SC5")+"|"+SC5->C5_NUM+"|"+SC5->C5_TIPO+"|Tipo do pedido não é de venda.")
		Return .F.
	Endif
	
	SA1->( DbSetOrder(1) )
	If SA1->( MSSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)) 
		If SA1->A1_MSBLQL == '1'	
			WriteLog(cEmpAnt+"|"+xFilial("SC5")+"|"+SC5->C5_NUM+"|"+SC5->C5_CLIENTE+"|"+SC5->C5_LOJACLI+"|Cliente Bloqueado.")
			//Return .F.
		Endif
	Else
		WriteLog(cEmpAnt+"|"+xFilial("SC5")+"|"+SC5->C5_NUM+"|"+SC5->C5_CLIENTE+"|"+SC5->C5_LOJACLI+"|Cliente nao encontrado.")
		Return .F.
	Endif
	
	SC6->( DbSetOrder(1) )
	If !SC6->( MsSeek(xFilial("SC6")+_cPed) )
		WriteLog(cEmpAnt+"|"+xFilial("SC5")+"|"+SC5->C5_NUM+"|"+SC5->C5_CLIENTE+"|"+SC5->C5_LOJACLI+"|Itens do pedido nao encontrados.")
		Return .f.
	Endif
	
	cKOp	:= _cEmpOri+_cFilOri+SC5->C5_NUM
	
	If pedidojacopiado(cKOp)
		WriteLog(_cEmpOri+"|"+_cFilOri+"|"+SC5->C5_NUM+"|"+SC5->C5_CLIENTE+"|"+SC5->C5_LOJACLI+"|Pedido ja copiado.")
		Return .f.
	Endif	
	
	aCabSC5	:= geraArrayExecAuto("SC5",_cFilDest)
	
	aadd(aCabSC5,{"C5_K_PO",cKOp,Nil} )
	
	nPOper:= aScan(aCabSC5,{|x| AllTrim( x[1] ) == "C5_K_OPER" } )
	cOper := SC5->C5_K_OPER
	
	While !SC6->( EOF() ) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == _cPed
		If SC6->C6_QTDVEN > SC6->C6_QTDENT .and. SC6->C6_BLQ <> 'R' 
			
			SB1->( DbSetOrder(1) )
			If SB1->( MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))
				If SB1->B1_MSBLQL == '1'
					WriteLog(cEmpAnt+"|"+xFilial("SC5")+"|"+SC5->C5_NUM+"|"+SC5->C5_CLIENTE+"|"+SC5->C5_LOJACLI+"|"+SC6->C6_PRODUTO+"|Produto bloqueado.")
					//exit
					//Return .f.
				Endif
			Else
				WriteLog(cEmpAnt+"|"+xFilial("SC5")+"|"+SC5->C5_NUM+"|"+SC5->C5_CLIENTE+"|"+SC5->C5_LOJACLI+"|"+SC6->C6_PRODUTO+"|Produto nao encontrado.")
			Endif
			
			SF4->( DbSetOrder(1) )
			If SF4->( MsSeek(xFilial("SF4")+SC6->C6_TES))
				
				IF SF4->F4_MSBLQL == '1'
					WriteLog(cEmpAnt+"|"+xFilial("SC5")+"|"+SC5->C5_NUM+"|"+SC5->C5_CLIENTE+"|"+SC5->C5_LOJACLI+"|"+SC6->C6_PRODUTO+"|"+SC6->C6_TES+"|TES bloqueada.")
				Endif
				If SF4->F4_DUPLIC <> 'S' 
					WriteLog(cEmpAnt+"|"+xFilial("SC5")+"|"+SC5->C5_NUM+"|"+SC5->C5_CLIENTE+"|"+SC5->C5_LOJACLI+"|"+SC6->C6_PRODUTO+"|"+SC6->C6_TES+"|TES nao gera financeiro.")
				Endif
				If SF4->F4_ESTOQUE <> 'S' 
					WriteLog(cEmpAnt+"|"+xFilial("SC5")+"|"+SC5->C5_NUM+"|"+SC5->C5_CLIENTE+"|"+SC5->C5_LOJACLI+"|"+SC6->C6_PRODUTO+"|"+SC6->C6_TES+"|TES nao movimenta estoque.")
				Endif
			Else
				WriteLog(cEmpAnt+"|"+xFilial("SC5")+"|"+SC5->C5_NUM+"|"+SC5->C5_CLIENTE+"|"+SC5->C5_LOJACLI+"|"+SC6->C6_PRODUTO+"|"+SC6->C6_TES+"|TES nao encontrado.")
				Return .f.
			Endif
			
			aItem:= geraArrayExecAuto("SC6",_cFilDest,cOper)
			
			If !Empty(aItem)
				aadd(aItensSC6,aItem)
			Endif
		Else
			WriteLog(cEmpAnt+"|"+xFilial("SC5")+"|"+SC5->C5_NUM+"|"+SC5->C5_CLIENTE+"|"+SC5->C5_LOJACLI+"|"+SC6->C6_PRODUTO+"|Produto sem saldo no pedido.")
		Endif
		SC6->( DBSkip())
	Enddo
	
	If !Empty(aCabSC5) .and. !Empty(aItensSC6)
			
		If !lSimula
			If lCopia
				//u_mycopia("SC5"	,aCabSC5,"SC6",aItensSC6,_cEmpDest	,_cFilDest	,cLogFile	,cKOp)
				StartJob("U_mycopia", GetEnvServer(), .T., 	"SC5"	,aCabSC5,"SC6",aItensSC6,_cEmpDest	,_cFilDest	,cLogFile	,cKOp)
			Endif
			If lExclui
				eliminarPedido(SC5->C5_FILIAL,SC5->C5_NUM,aCabSC5,aItensSC6)
			Endif
		Endif
		
		If lSimula
			WriteLog(cKOp+"|SIMULACAO|Pedido gerado")
		Endif
			
	Else
		WriteLog(cEmpAnt+"|"+xFilial("SC5")+"|"+SC5->C5_NUM+"|"+SC5->C5_CLIENTE+"|"+SC5->C5_LOJACLI+"|nao gerou cabecalho ou itens")
	Endif
	
Return  lRet

Static Function geraArrayExecAuto(_cAlias,_cFilDest,cOper)
	Local	aRet		:= {}
	Local	aItem		:= {}
	Local	cPrefi		:= ""

	SX3->( DbSetOrder(1) )
	If SX3->( MsSeek(_cAlias) )
		cPrefi := Substr(SX3->X3_CAMPO,1,at("_",SX3->X3_CAMPO))
		
		While !SX3->( EOF() ) .and. SX3->X3_ARQUIVO == _cAlias
			IF ( SX3->X3_CONTEXT <> 'V' .and. !Alltrim(SX3->X3_CAMPO) $ 'C6_SEGUM/C5_K_PO/USERLG' ) ;
					.or. cPrefi+"FILIAL" $ AllTrim(SX3->X3_CAMPO) 	;
					.or. cPrefi+"NUM" $ AllTrim(SX3->X3_CAMPO)		;
					.or. cPrefi+"OPER" == AllTrim(SX3->X3_CAMPO)		
				aItem	:= {}
				aadd(aItem, AllTrim(SX3->X3_CAMPO) 			)
				
				If cPrefi+"OPER" == AllTrim(SX3->X3_CAMPO)	
					aadd(aItem, cOper	)
				Else
					aadd(aItem, &(_cAlias+"->"+SX3->X3_CAMPO)	)
				Endif
				
				aadd(aItem, Nil                          	)
				
				If "FILIAL" $ AllTrim(SX3->X3_CAMPO)
					aItem[2] := _cFilDest
				Endif
				
				If AllTrim(SX3->X3_CAMPO) == "C6_VALOR"
					aItem[2] := A410Arred(SC6->C6_PRCVEN*SC6->C6_QTDVEN,"C6_VALOR")
				Endif
				
				If AllTrim(SX3->X3_CAMPO) == "C6_QTDEMP"
					aItem[2] := 0
				Endif
				
				aadd(aRet,aItem)
			Endif
			SX3->( DbSkip() )
		Enddo
	Endif

Return aRet

Static function pedidojacopiado(cChave)
	Local aArea	:= GetArea()
	Local cQuery:= ""
	Local cTemp	:= GetNextAlias()
	Local lRet	:= .F.
	
	cQuery += "SELECT COUNT(*) CONT "+ENTER
	cQuery += "FROM "+RetSqlName("SC5")+" "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "AND C5_K_PO='"+cChave+"' "+ENTER
	
	If Select(cTemp)>0
		(cTemp)->( DbCloseArea() )
	Endif

	TcQuery cQuery New Alias (cTemp)
	
	lRet := (cTemp)->CONT > 0
	
	RestArea(aArea)
	
	If Select(cTemp)>0
		(cTemp)->( DbCloseArea() )
	Endif
	
Return  lRet


User Function mycopia(cAlCab,aCab,cAlIt,aItens,cEmpNew,cFilNew,cLog,cKOp)
	Local lRet 		:= .T.
	Local nX		:= 0
	Local cNewNum 	:= ""
	Local cEmp		:= Substr(cKOp,1,2)
	Local cFil		:= Substr(cKOp,3,2)
	Local cPed		:= Substr(cKOp,5,6)
	cLogFile := cLog

	//Seta a nova empresa
	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv(cEmpNew, cFilNew,,,"FAT")
	
	//WriteLog(cEmpAnt+cFilAnt+"|empant")
	//WriteLog(cEmpNew+cFilNew+"|empnew")
	
	If pedidojacopiado(cKOp)
		WriteLog(cEmp+"|"+cFil+"|"+cPed+"|Pedido ja copiado.")
		Return .f.
	Endif
	
	Begin Transaction
		cNewNum	:= GetSX8Num("SC5","C5_NUM")	
		
		nPNum	:= aScan(aCab,{|x| AllTrim( x[1] ) == "C5_NUM" } )
		If nPNum > 0
			aCab[nPNum][2] := cNewNum
		Endif
		
		For nX := 1 to Len(aItens)
			nPNum := aScan(aItens[nX],{|x| x[1] == "C6_NUM"})
			If nPNum >0
				aItens[nX][nPNum][2] := cNewNum
			Endif
		Next
		
		//lRet := myexecauto(aCab,aItens)
		
		lRet	:= gravexecauto(cAlCab,aCab)
		//lRet := .F.
		
		If lRet
		
			For nX := 1 to Len(aItens)
				lRet := gravexecauto(cAlIt,aItens[nX])
				If !lRet
					DisarmTransactions()
					//Cancela o numero
					RollBackSx8()
					Return .f.
				Endif
			Next
			
			//Confirma a numeração
			ConfirmSX8()
			WriteLog(cKOp+"|"+cEmpAnt+cFilAnt+cNewNum+"|Pedido gerado")
		Else
			DisarmTransactions()
			//Cancela o numero
			RollBackSx8()
		Endif
		
	End Transaction
	
	RpcClearEnv()
	
Return lRet

Static Function gravexecauto(_cAlias,_aCampos)
	Local lRet 	:= .T.
	Local nC	:= 0
	Local cCampo:= ""
	Local xVlr	
	
	DbSelectArea(_cAlias)
	RecLock(_cAlias,.T.)
		For nC := 1 to Len(_aCampos)
			cCampo 	:= _aCampos[nC][1]
			xVlr	:= _aCampos[nC][2]
			If !(Empty(xVlr) .and. !Empty(FieldGet(FieldPos(cCampo)))) 
				FieldPut(FieldPos(cCampo),xVlr)
			Endif
			 
		Next
	MsUnLock(_cAlias)
	
Return lRet


Static Function eliminarPedido(_cFil,_cPedido,aCab,aItens)
	Local 	aArea	 	:= GetArea()
	Local 	lRet 		:= .T.
	Local	cFilBkp		:= cFilAnt
	Private	lMsErroAuto	:= .F.
	
	SC5->( DbSetOrder(1) )
	If !SC5->( MsSeek(_cFil+_cPedido))	
		WriteLog(cEmpAnt+"|"+_cFil+"|"+_cPedido+"|Pedido nao encontrado.")
		lRet := .F.
	Endif

	cFilAnt := _cFil

	If lRet
		lRet := possuiSaldo(SC5->C5_NUM)
	Endif
	
	If lRet
		estornarLiberacao(SC5->C5_NUM)
		If !faturado(SC5->C5_NUM)
			nPFil	:= aScan(aCab,{|x| AllTrim( x[1] ) == "C5_FILIAL" } )
			If nPFil > 0
				aCab[nPFil][2] := cFilAnt
			Endif
			lMsErroAuto := .F.
			MSExecAuto({|x,y,z| Mata410(x,y,z)},aCab,aItens,5) // Exclui
			If lMsErroAuto
	            WriteLog(cEmpAnt+"|"+cFilAnt+"|"+_cPedido+"|Erro: "+MostraErro())
			Else
				WriteLog(cEmpAnt+"|"+cFilAnt+"|"+_cPedido+"|Pedido Excluido")
			Endif
		Endif
	Endif
	
	cFilAnt := cFilBkp
	RestArea(aArea)
	
Return


Static function possuiSaldo(_cPedido)
	Local aArea		:= GetArea()
	Local lRet 		:= .F.
	Local cQuery 	:= ""
	Local cTemp		:= GetNextAlias()
	
	cQuery += "SELECT COUNT(*) REGS "+ENTER
	cQuery += "FROM "+RetSqlName("SC6")+" "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "AND C6_FILIAL='"+xFilial("SC6")+"' "+ENTER
	cQuery += "AND C6_NUM='"+_cPedido+"' "+ENTER
	cQuery += "AND C6_QTDVEN > C6_QTDENT  "+ENTER
	cQuery += "AND C6_BLQ<>'R' "+ENTER 
	
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	Endif
	
	TcQuery cQuery New Alias (cTemp)
	
	If !(cTemp)->( EOF() )
		lRet := (ctemp)->REGS > 0
	Endif
	
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	Endif
	
	RestArea(aArea)
REturn lRet
	
	
Static Function estornarLiberacao(_cPedido)
	Local aArea	:= GetArea()
	
	SC9->( DbSetOrder(1) )
	If SC9->( MsSeek(xFilial("SC9")+_cPedido))
		While !SC9->(EOF() ) .and. SC9->C9_FILIAL == xFilial("SC9") .and. SC9->C9_PEDIDO == _cPedido
			If Empty(AllTrim(SC9->C9_NFISCAL)) 
				a460Estorna()
			Endif
			SC9->( DbSkip())
		Enddo
	Endif
	
	RestArea(aArea)
Return

Static Function faturado(_cPedido)
	Local aArea		:= GetArea()
	Local lRet 		:= .F.
	Local cQuery 	:= ""
	Local cTemp		:= GetNextAlias()
	
	cQuery += "SELECT COUNT(*) REGS "+ENTER
	cQuery += "FROM "+RetSqlName("SC6")+" SC6 "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND D2_FILIAL = C6_FILIAL "+ENTER
	cQuery += "		AND D2_PEDIDO = C6_NUM "+ENTER
	cQuery += "		AND D2_ITEMPV = C6_ITEM "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE SC6.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "AND C6_FILIAL='"+xFilial("SC6")+"' "+ENTER
	cQuery += "AND C6_NUM='"+_cPedido+"' "+ENTER

	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	Endif
	
	TcQuery cQuery New Alias (cTemp)
	
	If !(cTemp)->( EOF() )
		lRet := (ctemp)->REGS > 0
	Endif
	
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	Endif
	
	RestArea(aArea)
REturn lRet
	