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

	If ZA7->ZA7_STATUS $'3,4,5,7' .and. lRet
		HELP(' ',1,'Atenção!',,"A Montagem da carga já foi enviada para a transportadora "+cCodTransp+ " e não pode ser enviada EDI novamente.",1,0, NIL, NIL, NIL, NIL, NIL, {""})
		lRet := .F.
	EndIf
	If ZA7->ZA7_STATUS =='6' .and. lRet
		HELP(' ',1,'Atenção!',,"A Montagem da carga já foi faturada para a transportadora "+cCodTransp+ " e não pode ser enviada EDI novamente.",1,0, NIL, NIL, NIL, NIL, NIL, {""})
		lRet := .F.
	EndIf
	If ZA7->ZA7_STATUS =='2' .and. lRet
		HELP(' ',1,'Atenção!',,"A Montagem da carga foi cancelada para a transportadora "+cCodTransp+ " e não pode ser enviada EDI novamente.",1,0, NIL, NIL, NIL, NIL, NIL, {""})
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
	Local cArqCPag 		:= "EDI-"+cCodCGC+dtos(date())+StrTran( time(), ":", "" ) +".TXT"

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
	cQryZA7 += " JOIN "+RetSQLName("SA1")+" SA1 ON A1_COD=C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1.D_E_L_E_T_ = ' ' "
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

		While !ZA0->(EOF()) .AND. ZA0->ZA0_CODIGO == cCodEDI//04-01-2020
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
					ElseIf cConteudo == "FILIAL"
						cMacro :=&((cAliasZA7)+"->"+"ZA7_FILIAL")
						cConteudo := FWFilialName (cEmpAnt,cMacro)
					Endif
				Else
					cMacro := STRTRAN(Alltrim(ZA0->ZA0_CONTEU), '"', "")
					cConteudo :=&((cAliasZA7)+"->"+cMacro)
				EndIf
			Else//Numerico
				If SUBSTR(Alltrim(ZA0->ZA0_CONTEU),1,1) =='"'
					cConteudo := STRTRAN(Alltrim(ZA0->ZA0_CONTEU), '"', "")
				ElseIf Alltrim(ZA0->ZA0_CONTEU) == "C5_PBRUTO"
					cConteudo := Alltrim(STR((cAliasZA7)->C9_QTDLIB * (Posicione("SB1",1,xFilial("SB1")+(cAliasZA7)->C9_PRODUTO,"B1_PESBRU"))))
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
		cMsg := "Arquivo txt gerado com sucesso: "+targetDir+"\"+cCodCGC+"\"+cArqCPag+" "
		//Grava na tabela de log os dados
		DbSelectArea("ZA6")
		ZA6->(DbSetOrder(1))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
		ZA6->(DbGoTop())
		If ZA6->(dbSeek(xFilial("ZA6")+cCodZA7))
			RecLock("ZA6",.F.)
			ZA6_STATUS  := Iif(cOpc=="1",'1','3')
			ZA6_MSG   	:= ZA6_MSG+" "+cMsg+dtoc(date())+" / "+time()+CHR(13)+CHR(10)
			ZA6->(MsUnlock())
		EndIf
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

	If ZA7->ZA7_STATUS $'1' .and. lRet
		HELP(' ',1,'Atenção!',,"O cancelamento da EDI nao pode ser efetuado porque ainda não foi enviado para a transportadora. "+cCodTransp+ ".",1,0, NIL, NIL, NIL, NIL, NIL, {"Enviar EDI"})
		lRet := .F.
	EndIf

	If ZA7->ZA7_STATUS $'2' .and. lRet
		HELP(' ',1,'Atenção!',,"O cancelamento da EDI já foi efetuado para a transportadora. "+cCodTransp+ ".",1,0, NIL, NIL, NIL, NIL, NIL, {"Cancelamento EDI"})
		lRet := .F.
	EndIf

	If ZA7->ZA7_STATUS $'5' .and. lRet
		HELP(' ',1,'Atenção!',,"O cancelamento da EDI para a transportadora "+cCodTransp+ " já foi enviado.",1,0, NIL, NIL, NIL, NIL, NIL, {"Aguardando retorno da transportadora."})
		lRet := .F.
	EndIf
	If ZA7->ZA7_STATUS =='6' .and. lRet
		HELP(' ',1,'Atenção!',,"A carga já foi faturada para a transportadora "+cCodTransp+ " e não pode ser cancelada.",1,0, NIL, NIL, NIL, NIL, NIL, {"Necessario estornar a Nf. antes de cancelar a EDI"})
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
		cDirRet	:= cDir+"\"+cDirTransp+"\Retornados"

		If !ExistDir(cDirNEnv)
			MakeDir(cDirNEnv)
		Endif

		If !ExistDir(cDirEnv)
			MakeDir(cDirEnv)
		Endif

		If !ExistDir(cDirRej)
			MakeDir(cDirRej)
		Endif

		If !ExistDir(cDirRet)
			MakeDir(cDirRet)
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
				cMsg := "Arquivo enviado com sucesso para a transportadora: "+cDirEnv + cArquivo+" "
				//Grava na tabela de log os dados
				dbSelectArea("ZA6")
				ZA6->(dbSetOrder(1))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
				If ZA6->(dbSeek(xFilial("ZA6")+cCodZA7))
					RecLock("ZA6",.F.)
					ZA6_STATUS  := Iif(cOpc=="1",'1','3')//1=Enviado;2=NãoEnviado;3=Rejeitado
					ZA6_TOMOV   := "4"//1=GERACAO TXT; 2=ENVIO TXT
					ZA6_MSG   	:= ZA6_MSG+CHR(13)+CHR(10)+cMsg+dtoc(date())+" / "+time()+CHR(13)+CHR(10)
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
	Local aTemp := {}
	Local aRetornados := {}
	Local aCampZA0 :={}
	Local nAtual := 0
	Local nAux := 0
	Local nR := 0
	Local nY := 0
	Local cFTPCurDir := ""
	Local cCodTransp 	:= ""
	Local cCodEDI 		:= ""
	Local cCodCGC 		:= ""
	Local cStatus := ""
	Local cMsg := ""

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
	cFTPCurDir :=FTPGetCurDir()
	For nAtual:=1 to len(aRetDir)
		cCodCGC :=aRetDir[nAtual][1]
		If aRetDir[nAtual][5]=="D"//cnpj transportadoras
			FTPDIRCHANGE ( aRetDir[nAtual][1] )
			//Pega todas as pastas dentro dessa
			aTemp := FTPDIRECTORY("*.*", "D")
			//Percorre as subpastas dentro e encontra a pasta Retornados
			For nAux := 1 To Len(aTemp)
				If aTemp[nAux][1] == "Retornados"
					FTPDIRCHANGE (  aTemp[nAux][1] )
					aRetornados := FTPDIRECTORY("*.*",)
					if !Empty(aRetornados)
						dbSelectArea("SA4")
						SA4->(dbSetOrder(3))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
						If SA4->(dbSeek(xFilial("SA4")+cCodCGC))
							cCodTransp 	:= A4_COD
							cCodEDI		:= A4_EDIRET
						EndIf
						For nR := 1 to len(aRetornados)
							aCampZA0 :={}
							//faz download do arquivo
							If !FTPDOWNLOAD("\EDI\"+cCodCGC+"\retornados\"+aRetornados[nR][1], aRetornados[nR][1] )
								cMsg := 'Problemas ao copiar arquivo '+ aRetornados[nR][1]
							Else
								If !FTPERASE( aRetornados[nR][1] )
									cMsg +='Problemas ao apagar o arquivo ' + aRetornados[nR][1]
								EndIf
							EndIf
							//1 - abrir arquivo txt e verificar dados
							If !File("\EDI\"+cCodCGC+"\retornados\"+aRetornados[nR][1])
								MsgStop("O arquivo " +"\EDI\"+aRetDir[nAtual][1]+"\retornados\"+aRetornados[nR][1] + " não foi encontrado. A importação será abortada!","[ImportZ07] - ATENCAO")
								Return
							EndIf

							FT_FUSE("\EDI\"+cCodCGC+"\retornados\"+aRetornados[nR][1])
							ProcRegua(FT_FLASTREC())
							FT_FGOTOP()
							While !FT_FEOF()
								IncProc("Lendo arquivo texto...")

								cLinha := FT_FREADLN()

								//verifica EDI criado para a transportadora
								ZA0->(dbSetOrder(3))
								ZA0->(dbGotop())
								If ZA0->(DbSeek(xFilial("ZA0")+cCodEDI))	//ZA0_FILIAL+ZA0_CODIGO
									While !ZA0->(EOF()) .AND. ZA0->ZA0_CODIGO = cCodEDI
										If SUBSTR(Alltrim(ZA0->ZA0_CONTEU),1,1) =='"'
											cConteudo :=STRTRAN(Alltrim(ZA0->ZA0_CONTEU), '"', "")
										Else
											cConteudo :=Alltrim(ZA0->ZA0_CONTEU)
										EndIf
										If cConteudo != "TPRET"
											_nTamCpo :=(Val((ZA0->ZA0_POSFIM)) - Val((ZA0->ZA0_POSINI))) + 1
											dbSelectArea('SX3')
											dbSetOrder(2)
											If dbSeek(cConteudo)
												cTipo := X3_TIPO
											EndIf
											AAdd( aCampZA0, {cConteudo,Substr(cLinha,Val(ZA0->ZA0_POSINI),_nTamCpo),cTipo})
										Else
											_nTamCpo :=(Val((ZA0->ZA0_POSFIM)) - Val((ZA0->ZA0_POSINI))) + 1
											If Substr(cLinha,Val(ZA0->ZA0_POSINI),_nTamCpo) =="RET"
												cStatus :="7"//retorno aprovado. STATUS aguardando liberacao de pedidos
											Else
												cStatus :="2"//retorno cancelado
											EndIf
											cConteudo := "ZA7_STATUS"
											AAdd( aCampZA0, {cConteudo,cStatus,"C"})
										EndIf
										ZA0->(DbSkip())
									Enddo
								EndIf
								FT_FSKIP()
							EndDo
							FT_FUSE()
							If !Empty(aCampZA0)
								cMsg := "Arquivo retornado com sucesso da transportadora "+"\EDI\"+cCodCGC+"\retornados\"+aRetornados[nR][1]+" "
								//Grava na tabela de log os dados
								dbSelectArea("ZA7")
								ZA7->(dbSetOrder(1))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
								If ZA7->(dbSeek(xFilial("ZA7")+aCampZA0[2][2]))
									While !ZA7->(EOF()) .AND. ZA7->ZA7_CODIGO == aCampZA0[2][2]
										RecLock("ZA7",.F.)
										for nY := 1 to len(aCampZA0)
											If aCampZA0[nY][1] !="ZA7_CODIGO"
												cMacro := STRTRAN(Alltrim(aCampZA0[nY][1]), '"', "")
												If aCampZA0[nY][3] =='D'
													ZA7->&(cMacro) := STOD(aCampZA0[nY][2])
												ElseIf  aCampZA0[nY][3] =='N'
													ZA7->&(cMacro) := Val(aCampZA0[nY][2])
												Else
													ZA7->&(cMacro) := aCampZA0[nY][2]
												EndIf
											EndIf
										Next nY
										ZA7->(dbSkip())
									Enddo
									ZA7->(MsUnlock())
								EndIf
								//Grava na tabela de log os dados
								DbSelectArea("ZA6")
								ZA6->(DbSetOrder(1))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
								ZA6->(DbGoTop())
								If ZA6->(dbSeek(xFilial("ZA6")+aCampZA0[2][2]))
									RecLock("ZA6",.F.)
									ZA6_MSG := ZA6_MSG+cMsg+dtoc(date())+" / "+time()+CHR(13)+CHR(10)
									ZA6->(MsUnlock())
								EndIf
							EndIf
						Next nR
					Endif
					Exit
				EndIf

			Next nAux
			FTPDIRCHANGE ( cFTPCurDir )
			//Neste ponto verificar se existem arquivos TXT nesta pasta. Caso exista, copiar os dados para o Protheus

		EndIf
	Next nAtual
//Tenta desconectar do servidor ftp
	FTPDISCONNECT ()
Return Nil

