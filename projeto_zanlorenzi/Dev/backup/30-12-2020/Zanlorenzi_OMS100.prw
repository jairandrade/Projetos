#include "rwmake.ch"
#include "TopConn.ch"
#include "TBICONN.ch"
#include "Protheus.ch"
#DEFINE DEFAULT_FTP 21
#DEFINE PATH "\EDI\"
/*/{Protheus.doc} OMS100T
Rotina para geração e exportação de dados para arquivo TXT.
@author Jair Andrade
@since 08/12/2020
@version 1.0
    @return Nil, Função não tem retorno
    @example
/*/
User Function OMS100T()
	Local lRet := .T.
	Private cCodZA7 		:= ZA7->ZA7_CODIGO
	Private cCodTransp 		:= ZA7->ZA7_TRANSP
	Private cCodEDI 		:= Posicione("SA4",1,xFilial("SA4")+cCodTransp,"A4_EDIENV")
	Private cCodCGC 		:= Alltrim(Posicione("SA4",1,xFilial("SA4")+cCodTransp,"A4_CGC"))

	If Empty(cCodEDI)
		HELP(' ',1,'Atenção!',,"O código de EDI não está preenchido para a transportadora "+cCodTransp+".",1,0, NIL, NIL, NIL, NIL, NIL, {"Preencher codigo EDI no cadastro da Transportadora"})
		lRet := .F.
	EndIf

	If ZA7->ZA7_STATUS $'3,4' .and. lRet
		HELP(' ',1,'Atenção!',,"A Montagem da carga já foi enviada para a transportadora "+cCodTransp+ " e não pode ser enviada EDI novamente.",1,0, NIL, NIL, NIL, NIL, NIL, {""})
		lRet := .F.
	EndIf
	If ZA7->ZA7_STATUS $'5' .and. lRet
		HELP(' ',1,'Atenção!',,"A Montagem da carga já foi enviada para a transportadora "+cCodTransp+ " e não pode ser enviada EDI novamente.",1,0, NIL, NIL, NIL, NIL, NIL, {""})
		lRet := .F.
	EndIf
	If lRet
		SetPrvt("cArqCPag,nHdlArq,cTexto,nContad,nTotalREG")

		If .Not. MsgBox("Confirma geração de arquivo de EDI para a transportadora "+cCodTransp+" ?","Geração de Arquivo de EDI","YESNO")
			Aviso("Geração de Arquivo de EDI", "Operação Cancelada", {"Ok"}, 1)
			Return
		Endif

		Processa({|lEnd| GeraArquivo("1")},"Geração de arquivo de EDI das transportadoras")
	EndIf

Return



Static Function GeraArquivo(cOpc)
	Local cTexto 		:= ""
	Local cMsg 			:= ""
	Local cConteudo 	:= ""
	Local cCodReg 		:= ""
	Local cAliasZA7 	:= GetNextAlias()        // da um nome pro arquivo temporario
	Local cQryZA7 		:= ""
	Local targetDir 	:= "\EDI"
	Local cArqCPag 		:= "EDI-"+cCodCGC+Substr(dtoc(date()),1,2)+Substr(dtoc(date()),4,2)+Substr(dtoc(date()),7,2)+".TXT"

	If File(cArqCPag)
		FErase(cArqCPag)
	Endif

	//Cria a pasta EDI na raiz do Protheus
	If !ExistDir(targetDir)
		MakeDir(targetDir)
	Endif

	//Cria a pasta da transportadora
	If !ExistDir(targetDir+"\"+cCodCGC)
		MakeDir(targetDir+"\"+cCodCGC)
	Endif

	If (nHdlArq := FCreate(targetDir+"\"+cCodCGC+"\"+cArqCPag,0)) == -1
		HELP(' ',1,'Atenção!',,"Arquivo Texto não pode ser criado!",1,0, NIL, NIL, NIL, NIL, NIL, {""})
		Return
	Else
		IncProc("Gerando arquivo "+cArqCPag)
	Endif

	cQryZA7 := " SELECT * FROM  "+RetSQLName("ZA7")+" ZA7 "
	cQryZA7 += " JOIN "+RetSQLName("SC5")+" SC5 ON  C5_FILIAL=ZA7_FILIAL AND C5_NUM=ZA7_PEDIDO AND SC5.D_E_L_E_T_ = ' ' "
	cQryZA7 += " JOIN "+RetSQLName("SC9")+" SC9 ON  C9_FILIAL=ZA7_FILIAL AND C9_PEDIDO=ZA7_PEDIDO AND C9_ITEM = ZA7_ITEMPD AND SC9.D_E_L_E_T_ = ' ' "
	cQryZA7 += " WHERE ZA7.D_E_L_E_T_ = ' ' "
	cQryZA7 += " AND ZA7_CODIGO = '"+cCodZA7+"' "
	cQryZA7 += " AND ZA7_FILIAL = '"+FWxFilial('ZA7')+"' "
	cQryZA7 += " ORDER BY C9_PEDIDO "
	If Select(cAliasZA7) > 0
		dbSelectArea(cAliasZA7)
		dbCloseArea()
	EndIf

	//Memowrite("c:\temp\oms100t.txt",cQuery)
	//Verifica qual EDI está sendo utilizado de acordo com o campo A4_EDIENV
	dbSelectArea("ZA0")
	ZA0->(dbSetOrder(1))

	TCQUERY cQryZA7 NEW ALIAS &cAliasZA7
	While !(cAliasZA7)->(EOF())
		If Empty(cCodReg)
			ZA0->(dbGotop())
			ZA0->(DbSeek(xFilial("ZA0")+cCodEDI))	//ZA0_FILIAL+ZA0_CODIGO
			cCodReg := ZA0->ZA0_CODREG
		Else
			//grava o ultimo codigo de registro
			If !Empty(cTexto)
				FWrite(nHdlArq,cTexto+CHR(13)+Chr(10))
			EndIf
			cTexto := ""
			ZA0->(dbSetOrder(3))
			ZA0->(dbGotop())
			ZA0->(DbSeek(xFilial("ZA0")+cCodEDI+cCodReg))	//ZA0_FILIAL+ZA0_CODIGO
		Endif

		While !ZA0->(EOF()) //.AND. ZA0->ZA0_CODREG == cCodReg
			cConteudo := ""
			If 	cCodReg  <> ZA0->ZA0_CODREG
				FWrite(nHdlArq,cTexto+CHR(13)+CHR(10))
				cCodReg := ZA0->ZA0_CODREG
				cTexto := ""
			EndIf

			If ZA0->ZA0_TPDADO=="1"//Caracter
				If SUBSTR(Alltrim(ZA0->ZA0_CONTEU),1,1) =='"'
					cConteudo :=STRTRAN(Alltrim(ZA0->ZA0_CONTEU), '"', "")
					If cConteudo == "TPENV"
						If cOpc =="1"
							cConteudo :="ENV"
						Else
							cConteudo :="CAN"
						EndIf
					Endif
				Else
					cMacro := STRTRAN(Alltrim(ZA0->ZA0_CONTEU), '"', "")
					cConteudo :=&((cAliasZA7)+"->"+cMacro)
				EndIf
			Else//Numerico
				If SUBSTR(Alltrim(ZA0->ZA0_CONTEU),1,1) =='"'
					cConteudo := STRTRAN(Alltrim(ZA0->ZA0_CONTEU), '"', "")
				Else
					cMacro := STRTRAN(Alltrim(ZA0->ZA0_CONTEU), '"', "")
					cConteudo :=&((cAliasZA7)+"->"+cMacro)
					cConteudo := Alltrim(Str(cConteudo))
				EndIf
			EndIf
			cConteudo := AllTrim(cConteudo)
			//Calcula o tamanho do campo para a configuracao do texto
			_nTamCpo :=(Val(OMS100R(ZA0->ZA0_POSFIM)) - Val(OMS100R(ZA0->ZA0_POSINI))) + 1
			_cContTemp := _nTamCpo - Len((cConteudo))
			If _cContTemp > 0
				_cCompText := cConteudo+Padr("",_cContTemp)
			Else
				_cCompText :=Substr(cConteudo, 1,_nTamCpo)
			EndIf
			cTexto +=_cCompText
			nContad++
			ZA0->(DbSkip())
		Enddo
		(cAliasZA7)->(dbSKip())
	EndDo

	(cAliasZA7)->(DbCloseArea())

//grava o ultimo codigo de registro
	FWrite(nHdlArq,cTexto+CHR(13)+CHR(10))
	FClose(nHdlArq)

	If nContad = 0
		MsgBox("Não há dados. Favor vertificar os Parâmetros.","Atenção","ALERT")
		FErase(cArqCPag)
	Else
		cMsg := "Arquivo txt gerado com sucesso: "+cArqCPag+" Pasta: "+targetDir+" \ "+cCodCGC
		//Grava na tabela de log os dados
		dbSelectArea("ZA6")
		ZA6->(dbSetOrder(1))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
		If ZA6->(dbSeek(xFilial("ZA6")+cCodZA7))
			RecLock("ZA6",.F.)
		Else
			RecLock('ZA6', .T.)
		EndIf

		ZA6_FILIAL  := xFilial("ZA6")
		ZA6_CODIGO  := cCodZA7//CODIGO DA MONTAGEM DA CARGA
		ZA6_TIPO   	:= "1" //1=ENVIO - 2=RECEBIMENTO
		ZA6_ORIGEM  := Funname()
		ZA6_DATA    := DATE()
		ZA6_HRTRA   := TIME()
		ZA6_USERTR  := UsrFullName(__cUserId)
		ZA6_STATUS  := Iif(cOpc=="1",'1','3')
		ZA6_TOMOV   := "4"//1=GERACAO TXT; 2=ENVIO TXT
		ZA6_MSG   	:= cMsg
		ZA6_TRANSP  := cCodTransp
		ZA6->(MsUnlock())
		//Altera o STATUS da tabela ZA7 para Envio transportadora.
		//Neste caso o campo ZA7_STATUS deve ser preenchido com valor='3'
		dbSelectArea("ZA7")
		ZA7->(dbSetOrder(1))
		If ZA7->(DbSeek(xFilial("ZA7")+cCodZA7))
			While !ZA7->(Eof()) .and. ZA7_CODIGO==cCodZA7
				RecLock('ZA7', .F.)
				ZA7_STATUS := Iif(cOpc=="1",'3','5')
				ZA7->(MsUnlock())
				ZA7->(dbSkip())
			Enddo

		EndIf
		//Valida se o arquivo foi gerado corretamente e se estiver ok, exporta o arquivo
		//via FTP para a transportadora
		U_OMS100E(targetDir,cArqCPag,cOpc)
	Endif
Return
/*/{Protheus.doc} OMS100R
Função que tira zeros a esquerda de uma variável caracter
@author Jair Andrade	
@since 08/12/2020
@version undefined
@param cTexto, characters, Texto que terá zeros a esquerda retirados
@type function
@example Exemplos abaixo:
    u_OMS100R("00000090") //Retorna "90"
/*/

Static Function OMS100R(cTexto)
	Local aArea     := GetArea()
	Local cRetorno  := ""
	Local lContinua := .T.
	Default cTexto  := ""

	//Pegando o texto atual
	cRetorno := Alltrim(cTexto)

	//Enquanto existir zeros a esquerda
	While lContinua
		//Se a priemira posição for diferente de 0 ou não existir mais texto de retorno, encerra o laço
		If SubStr(cRetorno, 1, 1) <> "0" .Or. Len(cRetorno) ==0
			lContinua := .f.
		EndIf

		//Se for continuar o processo, pega da próxima posição até o fim
		If lContinua
			cRetorno := Substr(cRetorno, 2, Len(cRetorno))
		EndIf
	EndDo

	RestArea(aArea)
Return cRetorno
/*/{Protheus.doc} OMS100C
Rotina para cancelamento de EDI . Deverá ser enviado um TXT para a transportadora.
@author Jair Andrade
@since 15/12/2020
@version 1.0
    @return Nil, Função não tem retorno
    @example
/*/
User Function OMS100C()
	Local lRet := .T.
	Private cCodZA7 		:= ZA7->ZA7_CODIGO
	Private cCodTransp 		:= ZA7->ZA7_TRANSP
	Private cCodEDI 		:= Posicione("SA4",1,xFilial("SA4")+cCodTransp,"A4_EDIENV")
	Private cCodCGC 		:= Alltrim(Posicione("SA4",1,xFilial("SA4")+cCodTransp,"A4_CGC"))

	If Empty(cCodEDI)
		HELP(' ',1,'Atenção!',,"O código de EDI não está preenchido para a transportadora "+cCodTransp+".",1,0, NIL, NIL, NIL, NIL, NIL, {"Preencher codigo EDI"})
		lRet := .F.
	EndIf

	If Empty(ZA7->ZA7_STATUS)  .and. lRet
		HELP(' ',1,'Atenção!',,"A EDI ainda não foi gerada para a carga "+cCodZA7,1,0, NIL, NIL, NIL, NIL, NIL, {"Cancelar EDI"})
		lRet := .F.
	EndIf

	If ZA7->ZA7_STATUS $'1,2' .and. lRet
		HELP(' ',1,'Atenção!',,"O cancelamento da EDI nao pode ser efetuado porque ainda não foi enviado para a transportadora. "+cCodTransp+ ".",1,0, NIL, NIL, NIL, NIL, NIL, {"Enviar EDI"})
		lRet := .F.
	EndIf

	If ZA7->ZA7_STATUS $'5' .and. lRet
		HELP(' ',1,'Atenção!',,"O cancelamento da EDI para a transportadora "+cCodTransp+ " já foi enviado.",1,0, NIL, NIL, NIL, NIL, NIL, {"Aguardando retorno da transportadora."})
		lRet := .F.
	EndIf
	If lRet
		SetPrvt("cArqCPag,nHdlArq,cTexto,nContad,nTotalREG")

		If .Not. MsgBox("Confirma o cancelamento do EDI ? Este cancelamento será enviado para a transportadora "+cCodTransp+".","Geração de Arquivo de cancelamento do EDI","YESNO")
			Aviso("Geração de Arquivo de EDI", "Operação Cancelada", {"Ok"}, 1)
			Return
		Endif

		Processa({|lEnd| GeraArquivo("2")},"Geração de arquivo de cancelamento do EDI")
	EndIf

Return

/*/{Protheus.doc} OMS100E(targetDir,cArqCPag,cOpc)
Função para Geração/Enviao ao FTP de Arquivos EDI
@type function
@version 1.0
@author Jair Andrade	
@since 22/12/2020
@param targetDir, Nome da pasta principal do EDI
@param cArqCPag, Nome do Arquivo a ser enviado para o FTP
@return return_type
/*/
User Function OMS100E(targetDir,cArqCPag,cOpc)

	Local cArquivo	:= lower(alltrim(cArqCPag))
	Local cDir		:= targetDir//diretorio principal da EDI
	Local cDirEnv	:= ""
	Local cDirNEnv	:= ""
	Local cDirRej	:= ""
	Local cAdress	:= ""
	Local nPorta	:= ""
	Local cUser		:= ""
	Local cPass		:= ""
	Local oFtp		:= Nil
	Local nStat
	Local cDirTransp := Posicione("SA4",1,xFilial("SA4")+cCodTransp,"A4_CGC")
	Local cMsg :=""
	Local aRetDir := {}

	// Força a retirada da barra caso exista, para que o controle seja feito pela função
	If substr(cDir,len(cDir),1) == '\'
		cDir:= lower(substr(cDir,1,len(cDir)-1))
	Endif

	If ! File(lower(cDir)+"\"+cCodCGC+"\"+cArquivo)
		Aviso("Erro","Arquivo " + cDir + "\" +cCodCGC+"\"+ cArquivo + " não existe na pasta informada!!!",{"OK"}, 3 )
	Else

		cDirAnt:= cDir+"\"+cCodCGC

		If !ExistDir(cDir)
			MakeDir(cDir)
		Endif

		If !ExistDir(cDir+"\"+cDirTransp)
			MakeDir(cDir+"\"+cDirTransp)
		Endif

		cDirNEnv:= cDir+"\"+cDirTransp+"\NaoEnviados"
		cDirEnv	:= cDir+"\"+cDirTransp+"\Enviados"
		cDirRej	:= cDir+"\"+cDirTransp+"\Rejeitados"

		If !ExistDir(cDirNEnv)
			MakeDir(cDirNEnv)
		Endif

		If !ExistDir(cDirEnv)
			MakeDir(cDirEnv)
		Endif

		If !ExistDir(cDirRej)
			MakeDir(cDirRej)
		Endif

		cDirNEnv+= "\"
		cDirEnv	+= "\"
		cDirRej += "\"

		__CopyFile( cDirAnt + "\"+ cArquivo, cDirNEnv + cArquivo,,,.f. )
		FErase( cDirAnt + "\" + cArquivo )

		cAdress	:= GetMV("MV_XADRESS")
		nPorta	:= GetMV("MV_XPORTA")
		cUser	:= GetMV("MV_XUSER")
		cPass	:= GetMV("MV_XPASSWD")

		oFtp := TFTPClient():New( )
		nStat := oFtp:FtpConnect( cAdress, nPorta, cUser, cPass )
		If nStat != 0
			__CopyFile( cDirNEnv + cArquivo, cDirRej + cArquivo,,,.f. )
			Memowrite( cDirRej + "erro_ftp_" + strtran(substr(time(),1,5),":","") + "_" + dtos(dDataBase)+".txt","FTPClient - Erro de Conexao " + cValToChar( nStat ))
		Else

			aRetDir := oFtp:Directory( "*", .T. )
			//Retorna os diretorios e arquivos contidos no local
			//Verifica se o array esta vazio
			If Empty( aRetDir )
				nRet := oFtp:MkDir( "EDI" )
				If nRet == 0
					aRetDir := oFtp:Directory( "*", .T. )
				EndIf
			EndIf
			//Verifica se a pasta EDI existe
			If ASCAN(aRetDir,{|x| alltrim(x[1]) == "EDI" }) >0//Caso nao exista, cria o diretorio RAIz da transportadora. No caso o CNPJ
				nRet := oFtp:ChDir("EDI")//Muda para o diretorio EDI por padrao
			EndIf
			If nRet == 0
				//verifica se a pasta CNPJ da transportadora existe. Caso nao exista, cadastra
				If ASCAN(aRetDir,{|x| alltrim(x[1]) == cDirTransp }) <= 0
					nRet := oFtp:MkDir( cDirTransp )
				EndIf
				//Muda para o diretorio CNPJ
				nRet := oFtp:ChDir(cDirTransp)

				If ASCAN(aRetDir,{|x| alltrim(x[1]) == "Enviados" }) <= 0//verifica se a pasta de enviados existe
					nRet := oFtp:MkDir( "Enviados" )
				endIf

				If ASCAN(aRetDir,{|x| alltrim(x[1]) == "Retornados" }) <= 0//verifica se a pasta de Retornados existe
					nRet := oFtp:MkDir( "Retornados" )
				endIf

			EndIf
			If oFtp:SendFile( cDirNEnv + cArquivo, cDirEnv+cArquivo ) == 0
				__CopyFile( cDirNEnv + cArquivo, cDirEnv +cArquivo,,,.f.)
				cMsg := "Arquivo enviado com sucesso para a transportadora: "+cDirEnv + cArquivo
				//Grava na tabela de log os dados
				dbSelectArea("ZA6")
				ZA6->(dbSetOrder(1))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
				If ZA6->(dbSeek(xFilial("ZA6")+cCodZA7))
					RecLock("ZA6",.F.)
					ZA6_STATUS  := Iif(cOpc=="1",'1','3')//1=Enviado;2=NãoEnviado;3=Rejeitado
					ZA6_TOMOV   := "4"//1=GERACAO TXT; 2=ENVIO TXT
					ZA6_MSG   	:= ZA6_MSG+CHR(13)+CHR(10)+cMsg
					ZA6->(MsUnlock())
				EndIf
				Aviso("Envio EDI para transportadora", "Operação concluida com sucesso para a transação "+cCodZA7, {"Ok"}, 1)
			else
				__CopyFile( cDirNEnv + cArquivo, cDirRej + cArquivo,,,.f. )
				cMsg := "Erro de copia do arquivo para  FTP. Diretorio "+cDirRej + cArquivo+ " erro_ftp_" + strtran(substr(time(),1,5),":","") + "_" + dtos(dDataBase)+".txt"
				//Grava na tabela de log os dados
				dbSelectArea("ZA6")
				ZA6->(dbSetOrder(1))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
				If ZA6->(dbSeek(xFilial("ZA6")+cCodZA7))
					RecLock("ZA6",.F.)
					ZA6_STATUS  := "2"//1=Enviado;2=NãoEnviado;3=Rejeitado
					ZA6_TOMOV   := "4"//1=GERACAO TXT; 2=ENVIO TXT
					ZA6_MSG   := ZA6_MSG+CHR(13)+CHR(10)+cMsg
					ZA6->(MsUnlock())
				EndIf
			EndIf
			FErase( cDirNEnv + cArquivo )

			oFtp:Close( )
		EndIf

		FreeObj(oFTP)
		oFTP := Nil

	Endif

Return
/*/{Protheus.doc} OMS100RE
Função que verifica se existem retornos das transportadoras
@author Jair Andrade	
@since 29/12/2020
@version undefined
@param 
@type function
@example
/*/

User Function OMS100RE()
	Local   cAdress	:= GetMV("MV_XADRESS")
	Local	nPorta	:= GetMV("MV_XPORTA")
	Local	cUser	:= GetMV("MV_XUSER")
	Local 	cPass	:= GetMV("MV_XPASSWD")
	Local aRetDir := {}		//Tenta se conectar ao servidor ftp em localhost na porta 21
	Local nAtual := 0
	Local nAux := 0
	//com usuario e senha anonimos
	if ! FTPCONNECT ( cAdress , nPorta ,cUser, cPass )
		ALERT( "Nao foi possivel se conectar!!" )
		Return NIL
	EndIf
	//Tenta mudar do diretorio corrente ftp, para o diretorio
	//especificado como parametro
	if ! FTPDIRCHANGE ( "/EDI" )
		ALERT( "Nao foi possivel modificar diretório!!" )
		Return NIL
	EndIf
	//Retorna apenas os arquivos contidos no local
	aRetDir := FTPDIRECTORY ( "*.*" ,"D" )
	If Empty( aRetDir )
		conout( "Array Vazio!!" )
		Return NIL
	EndIf

	For nAtual:=1 to len(aRetDir)
		If aRetDir[nAtual][5]=="D"//cnpj transportadoras
			FTPDIRCHANGE ( aRetDir[nAtual][1] )
			//Caso não tenha "\" no fim adiciona, por exemplo, "C:\TOTVS" -> "C:\TOTVS\"
			aRetDir[nAtual][1] += Iif(SubStr(aRetDir[nAtual][1], Len(aRetDir[nAtual][1]), 1) != "\", "\", "")
			//Pega todas as pastas dentro dessa
			aTemp := FTPDIRECTORY("*.*", "D")
			//Percorre as subpastas dentro, e adiciona o texto a esquerda, por exemplo, "PastaX" -> "C:\TOTVS\SubPasta\PastaX"
			For nAux := 1 To Len(aTemp)
				aTemp[nAux][1] := aRetDir[nAtual][1] + aTemp[nAux][1]
			Next nAux
			//Pega o tamanho das subpastas, e o tamanho atual das pastas
			nTamanho := Len(aTemp)
			nTamAux  := Len(aRetDir)

			//Redimensiona o array das pastas, aumentando conforme o tamanho das subpastas
			aSize(aRetDir, Len(aRetDir) + nTamanho)

			//Copia as subpastas para dentro da pasta a partir da última posição
			aCopy(aTemp, aRetDir, , , nTamAux + 1)
		EndIf
	Next nAtual
	//Pega o tamanho das pastas
	nTamanho := Len(aRetDir)

	//Percorre todas as pastas
	For nAtual := 1 To nTamanho

		//Se tiver pasta a ser validada
		If nAtual <= Len(aRetDir)

			//Se tiver ponto no nome, ou for diferente de D (Diretório)
			If "." $ Alltrim(aRetDir[nAtual][1]) .Or. aRetDir[nAtual][5] != "D"

				//Exclui aposição atual do Array
				aDel(aRetDir, nAtual)

				//Redimensiona o Array, diminuindo 1 posição
				aSize(aRetDir, Len(aRetDir) - 1)

				//Altera variáveis de controle, diminuindo elas
				nTamanho--
				nAtual--
			EndIf
		EndIf
	Next nAtual
	//Ordena o Array por ordem alfabética
	aSort(aRetDir)
//volta para o diretorio raiz
	FTPDIRCHANGE ( "/EDI" )
	//Pega os arquivos da pasta raíz
	aArquivos := FTPDirectory( "*.*" ,"D" )

	//Percorre todos os arquivos
	For nAtual := 1 To Len(aArquivos)

		//Se a pasta não tiver no nome do arquivo, adiciona, por exemplo, "arquivo.xml" -> "C:\TOTVS\arquivo.xml"
		If ! "EDI" $ aArquivos[nAtual][1]
			aArquivos[nAtual][1] := "EDI" +"/"+ aArquivos[nAtual][1]
		EndIf
	Next nAtual

	//Percorre todas as pastas / subpastas encontradas
	For nAtual := 1 To Len(aRetDir)
		//Se a pasta realmente existe
		If ExistDir(aRetDir[nAtual][1])

			//Caso não tenha "\" no fim adiciona, por exemplo, "C:\TOTVS" -> "C:\TOTVS\"
			aRetDir[nAtual][1] += Iif(SubStr(aRetDir[nAtual][1], Len(aRetDir[nAtual][1]), 1) != "\", "\", "")

			//Pega todos os arquivos dessa subpasta filtrando a máscara
			aTemp := FTPDIRECTORY("*.*", "D")

			//Percorre todos os arquivos encontrados
			For nAux := 1 To Len(aTemp)

				//Adiciona o caminho completo da subpasta, por exemplo, "arquivo2.xml" -> "C:\TOTVS\SubPasta\arquivo2.xml"
				aTemp[nAux][1] := aRetDir[nAtual][1] + aTemp[nAux][1]
			Next nAux

			//Pega o tamanho do array dos arquivos encontrados, e o tamanho do array de arquivos que serão retornados
			nTamanho := Len(aTemp)
			nTamAux  := Len(aArquivos)

			//Aumento o tamanho do array de Arquivos, com o tamanho dos encontrados
			aSize(aArquivos, Len(aArquivos) + nTamanho)

			//Copia o conteúdo dos enontrados para dentro do array de Arquivos
			aCopy(aTemp, aArquivos, , , nTamAux + 1)
		EndIf
	Next nAtual

	//Copia para um novo array de backup
	aArqOrig := aClone(aArquivos)

Return aArquivos

	//Tenta desconectar do servidor ftp
	FTPDISCONNECT ()
Return Nil
