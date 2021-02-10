#include "rwmake.ch"
#include "TopConn.ch"
#include "TBICONN.ch"
#include "Protheus.ch"
#DEFINE DEFAULT_FTP 21
#DEFINE PATH "\EDI\"
/*/{Protheus.doc} OMS100T
Rotina para gera��o e exporta��o de dados para arquivo TXT.
@author Jair Andrade
@since 08/12/2020
@version 1.0
    @return Nil, Fun��o n�o tem retorno
    @example
/*/
User Function OMS100T()
	Local lRet := .T.
	Private cCodZA7 		:= ZA7->ZA7_CODIGO
	Private cCodTransp 		:= ZA7->ZA7_TRANSP
	Private cCodEDI 		:= Posicione("SA4",1,xFilial("SA4")+cCodTransp,"A4_EDIENV")
	Private cCodCGC 		:= Alltrim(Posicione("SA4",1,xFilial("SA4")+cCodTransp,"A4_CGC"))

	If Empty(cCodEDI)
		HELP(' ',1,'Aten��o!',,"O c�digo de EDI n�o est� preenchido para a transportadora "+cCodTransp+".",1,0, NIL, NIL, NIL, NIL, NIL, {"Preencher codigo EDI no cadastro da Transportadora"})
		lRet := .F.
	EndIf

	If ZA7->ZA7_STATUS $'3,4' .and. lRet
		HELP(' ',1,'Aten��o!',,"A Montagem da carga j� foi enviada para a transportadora "+cCodTransp+ " e n�o pode ser enviada EDI novamente.",1,0, NIL, NIL, NIL, NIL, NIL, {""})
		lRet := .F.
	EndIf
	If ZA7->ZA7_STATUS $'5' .and. lRet
		HELP(' ',1,'Aten��o!',,"A Montagem da carga j� foi enviada para a transportadora "+cCodTransp+ " e n�o pode ser enviada EDI novamente.",1,0, NIL, NIL, NIL, NIL, NIL, {""})
		lRet := .F.
	EndIf
	If lRet
		SetPrvt("cArqCPag,nHdlArq,cTexto,nContad,nTotalREG")

		If .Not. MsgBox("Confirma gera��o de arquivo de EDI para a transportadora "+cCodTransp+" ?","Gera��o de Arquivo de EDI","YESNO")
			Aviso("Gera��o de Arquivo de EDI", "Opera��o Cancelada", {"Ok"}, 1)
			Return
		Endif

		Processa({|lEnd| GeraArquivo("1")},"Gera��o de arquivo de EDI das transportadoras")
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
		HELP(' ',1,'Aten��o!',,"Arquivo Texto n�o pode ser criado!",1,0, NIL, NIL, NIL, NIL, NIL, {""})
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
	//Verifica qual EDI est� sendo utilizado de acordo com o campo A4_EDIENV
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
		MsgBox("N�o h� dados. Favor vertificar os Par�metros.","Aten��o","ALERT")
		FErase(cArqCPag)
	Else
		//Grava na tabela de log os dados
		dbSelectArea("ZA6")
		ZA6->(dbSetOrder(1))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
		If ZA6->(dbSeek(xFilial("ZA6")+cCodZA7))
			RecLock("ZA6",.F.)
		Else
			RecLock('ZA6', .T.)
		EndIf

		ZA6_FILIAL   := xFilial("ZA6")
		ZA6_CODIGO   := cCodZA7//CODIGO DA MONTAGEM DA CARGA
		ZA6_TIPO   := "1" //1=ENVIO - 2=RECEBIMENTO
		ZA6_ORIGEM    := Funname()
		ZA6_DATA    := DATE()
		ZA6_HRTRA    := TIME()
		ZA6_USERTR   := UsrFullName(__cUserId)
		ZA6_STATUS   := "1"
		ZA6_TOMOV   := "1"//1=GERACAO TXT; 2=ENVIO TXT
		If !Empty(cMsg)
			ZA6_MSG   := cMsg
		EndIf
		ZA6->(MsUnlock())
		Aviso("Gera��o de Arquivo de EDI", "Arquivo gerado: "+cArqCPag+CHR(13)+CHR(10)+"Pasta: "+targetDir+"\"+cCodCGC, {"Ok"}, 1)

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
		U_OMS100E(targetDir,cArqCPag)
	Endif
Return
/*/{Protheus.doc} OMS100R
Fun��o que tira zeros a esquerda de uma vari�vel caracter
@author Jair Andrade	
@since 08/12/2020
@version undefined
@param cTexto, characters, Texto que ter� zeros a esquerda retirados
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
		//Se a priemira posi��o for diferente de 0 ou n�o existir mais texto de retorno, encerra o la�o
		If SubStr(cRetorno, 1, 1) <> "0" .Or. Len(cRetorno) ==0
			lContinua := .f.
		EndIf

		//Se for continuar o processo, pega da pr�xima posi��o at� o fim
		If lContinua
			cRetorno := Substr(cRetorno, 2, Len(cRetorno))
		EndIf
	EndDo

	RestArea(aArea)
Return cRetorno
/*/{Protheus.doc} OMS100C
Rotina para cancelamento de EDI . Dever� ser enviado um TXT para a transportadora.
@author Jair Andrade
@since 15/12/2020
@version 1.0
    @return Nil, Fun��o n�o tem retorno
    @example
/*/
User Function OMS100C()
	Local lRet := .T.
	Private cCodZA7 		:= ZA7->ZA7_CODIGO
	Private cCodTransp 		:= ZA7->ZA7_TRANSP
	Private cCodEDI 		:= Posicione("SA4",1,xFilial("SA4")+cCodTransp,"A4_EDIENV")

	If Empty(cCodEDI)
		HELP(' ',1,'Aten��o!',,"O c�digo de EDI n�o est� preenchido para a transportadora "+cCodTransp+".",1,0, NIL, NIL, NIL, NIL, NIL, {"Preencher codigo EDI"})
		lRet := .F.
	EndIf

	If Empty(ZA7->ZA7_STATUS)  .and. lRet
		HELP(' ',1,'Aten��o!',,"A EDI ainda n�o foi gerada para a carga "+cCodZA7,1,0, NIL, NIL, NIL, NIL, NIL, {"Cancelar EDI"})
		lRet := .F.
	EndIf

	If ZA7->ZA7_STATUS $'1,2' .and. lRet
		HELP(' ',1,'Aten��o!',,"O cancelamento da EDI nao pode ser efetuado porque ainda n�o foi enviado para a transportadora. "+cCodTransp+ ".",1,0, NIL, NIL, NIL, NIL, NIL, {"Enviar EDI"})
		lRet := .F.
	EndIf

	If ZA7->ZA7_STATUS $'5' .and. lRet
		HELP(' ',1,'Aten��o!',,"O cancelamento da EDI para a transportadora "+cCodTransp+ " j� foi enviado.",1,0, NIL, NIL, NIL, NIL, NIL, {"Aguardando retorno da transportadora."})
		lRet := .F.
	EndIf
	If lRet
		SetPrvt("cArqCPag,nHdlArq,cTexto,nContad,nTotalREG")

		If .Not. MsgBox("Confirma o cancelamento do EDI ? Este cancelamento ser� enviado para a transportadora "+cCodTransp+".","Gera��o de Arquivo de cancelamento do EDI","YESNO")
			Aviso("Gera��o de Arquivo de EDI", "Opera��o Cancelada", {"Ok"}, 1)
			Return
		Endif

		Processa({|lEnd| GeraArquivo("2")},"Gera��o de arquivo de cancelamento do EDI")
	EndIf

Return

/*/{Protheus.doc} OMS100E(targetDir,cArqCPag)
Fun��o para Gera��o/Enviao ao FTP de Arquivos EDI
@type function
@version 1.0
@author Jair Andrade	
@since 22/12/2020
@param targetDir, Nome da pasta principal do EDI
@param cArqCPag, Nome do Arquivo a ser enviado para o FTP
@return return_type
/*/
User Function OMS100E(targetDir,cArqCPag)

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

	// For�a a retirada da barra caso exista, para que o controle seja feito pela fun��o
	If substr(cDir,len(cDir),1) == '\'
		cDir:= lower(substr(cDir,1,len(cDir)-1))
	Endif

	If ! File(lower(cDir)+"\"+cCodCGC+"\"+cArquivo)
		Aviso("Erro","Arquivo " + cDir + "\" +cCodCGC+"\"+ cArquivo + " n�o existe na pasta informada!!!",{"OK"}, 3 )
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

		cAdress	:= "192.168.7.8"
		nPorta	:= 21
		cUser	:= "workflow"
		cPass	:= "#ZcL#"

		oFtp := TFTPClient():New( )
		nStat := oFtp:FtpConnect( cAdress, nPorta, cUser, cPass )
		If nStat != 0
			__CopyFile( cDirNEnv + cArquivo, cDirRej + cArquivo,,,.f. )
			Memowrite( cDirRej + "erro_ftp_" + strtran(substr(time(),1,5),":","") + "_" + dtos(dDataBase)+".txt","FTPClient - Erro de Conexao " + cValToChar( nStat ))
		Else

			aRetDir := oFtp:Directory( "*", .T. )
			//Retorna os diretorios e arquivos contidos no local
			//aRetDir := FTPDIRECTORY ( "*.*" , "D")
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
				//Muda para o diretorio Enviados
				//nRet := oFtp:ChDir("Enviados")
			EndIf
			If oFtp:SendFile( cDirNEnv + cArquivo, cDirEnv+cArquivo ) == 0
				__CopyFile( cDirNEnv + cArquivo, cDirEnv +cArquivo,,,.f.)
			else
				__CopyFile( cDirNEnv + cArquivo, cDirRej + cArquivo,,,.f. )
				cMsg := "Erro de copia do arquivo para  FTP. Diretorio "+cDirRej + cArquivo+ " erro_ftp_" + strtran(substr(time(),1,5),":","") + "_" + dtos(dDataBase)+".txt"
				//Grava na tabela de log os dados
				dbSelectArea("ZA6")
				ZA6->(dbSetOrder(1))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
				If ZA6->(dbSeek(xFilial("ZA6")+cCodZA7))
					RecLock("ZA6",.F.)
					ZA6_STATUS  := "3"//1=Enviado;2=N�oEnviado;3=Rejeitado
					ZA6_TOMOV   := "2"//1=GERACAO TXT; 2=ENVIO TXT
					If !Empty(cMsg)
						ZA6_MSG   := cMsg
					EndIf
					ZA6->(MsUnlock())
				EndIf
			EndIf
			FErase( cDirNEnv + cArquivo )

			oFtp:Close( )
		EndIf

		FreeObj(oFTP)
		oFTP := Nil

	Endif
	//Grava na tabela de log os dados
	dbSelectArea("ZA6")
	ZA6->(dbSetOrder(1))//ZA6_FILIAL+ZA6_CODIGO+ZA6_TIPO
	If ZA6->(dbSeek(xFilial("ZA6")+cCodZA7))
		RecLock("ZA6",.F.)
		ZA6_STATUS  := "1"//1=Enviado;2=N�oEnviado;3=Rejeitado
		ZA6_TOMOV   := "2"//1=GERACAO TXT; 2=ENVIO TXT
		If !Empty(cMsg)
			ZA6_MSG   := cMsg
		EndIf
		ZA6->(MsUnlock())
	EndIf

Return

