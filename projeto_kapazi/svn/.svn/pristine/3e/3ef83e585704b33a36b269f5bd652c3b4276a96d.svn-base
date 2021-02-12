#include "protheus.ch"
#include "topconn.ch"
#include "totvs.ch"

#Define ENTER chr(13)+chr(10)

User Function KESTR18(_cEmp, _cFil)
	Local	lEnv    	:= .F. 
	Local	oMail		:= nil	
	Local 	cAccount	:= ""
	Local 	cPassword	:= ""
	Local	lDel		:= .F.
	Local	nStart		:= Seconds()
	Local 	nElap		:= 0

	Default _cEmp		:= "04"
	Default _cFil		:= "01"

	If Empty(AllTrim(_cEmp))
		_cEmp := "04"
	Endif

	If Empty(AllTrim(_cFil))
		_cFil := "01"
	Endif
	
	// valida que já não está em execucao
	If u_FreeThreads(.F.,1,"KESTR18") 

		conout(DtoC(Date())+" "+Time()+" KESTR18 - Inicio download EDI OCorre")
		// abre o ambiente
		lEnv 	:= StaticCall(KAP_WF03,environmentActions,1,_cEmp,_cFil,,,"SIGAEST",{"SB1"})

	 	cAccount	:= GetMV("KA_OCOEMUS",,"transportadoras.edi@kapazi.com.br")
	 	cPassword	:= GetMV("KA_OCOEMPA",,"Logistica#kap")

		U_KESTR20C("01","ARQUIVO RECEBIDO"		)
		U_KESTR20C("02","ARQUIVO IMPORTADO"		)
		U_KESTR20C("03","ERRO NO PROCESSAMENTO"	)
		U_KESTR20C("04","INFORMATIVO"			)
		
		oMail 	:= connectEmail(cAccount,cPassword)
		if oMail <> nil
			receiveEmails(oMail,"\edi\ocorr\",".txt",lDel)
		Endif

		oMail:PopDisconnect()

		IF lEnv
			StaticCall(KAP_WF03,environmentActions,2)
		Endif

		nElap := Seconds() - nStart
		conout(DtoC(Date())+" "+Time()+" KESTR18 - Fim download EDI OCorre. Tempo de execução: "+SecsToTime(nElap))
	Else
		conout(DtoC(Date())+" "+Time()+" KESTR18 - Job download EDI Ocorre iniciado e terminado pois já está em execucao.")
	Endif

Return

Static Function connectEmail(cAccount,cPassword)
	Local oMail			:= TMailManager():New()
	Local cSmtpServer	:= GetMV("KA_OCOEMSM",,"stmp.skymail.net.br")
	Local nSmtpPort		:= GetMv("KA_OCOEMSP",,465)
	Local cPopServer	:= GetMv("KA_OCOEMPO",,"pop.skymail.net.br")
	Local nPopPort		:= GeTMV("KA_OCOEMPP",,110)
	Local cErro			:= ""
	Local lSSL			:= GetMV("KA_OCOEMSL",,.T.)
	Local lTLS			:= GetMv("KA_OCOEMTL",,.F.)
	Local nRet			:= 0 

	oMail:Init(cPopServer,cSmtpServer,cAccount,cPassword,nPopPort,nSmtpPort)
	oMail:SetUseTLS(lTLS)
	oMail:SetUseSSL(lSSL)
	nRet := oMail:PopConnect()

	if nRet <> 0
		cErro := oMail:GetErrorString(nRet)
		oMail.PopDisconnect()
		oMail	:= nil
		conout(DtoC(Date())+" "+Time()+" KESTR18 - Erro conexao e-mail: "+cErro)
	Else
		conout(DtoC(Date())+" "+Time()+" KESTR18 - E-mail conectado")
	Endif

Return oMail

Static Function receiveEmails(oMail,cPasta,cExt,lDel)
	Local nNumMsgs	:= 0
	Local nMsg		:= 0
	Local oMessage	:= TMailMessage():New()
	Local nAtach	:= 0
	Local aAttInfo	:= {}
	Local nPopResult:= 0
	Local lSave		:= .F.
	Local cBaseName	:= GetSrvProfString( "RootPath", "" )
	Local lRet		:= .T.
	Local cArquivo	:= ""

	Default	cPasta	:= ""
	Default cExt	:= ""
	Default lDel	:= .T.

	If !Empty(AllTRim(cPasta))
		cBaseName += cPasta
	Endif

	StaticCall(KESTR19,CriarPastas,cPasta)

	cExt := Upper(AllTrim(cExt))

	oMail:GetNumMsgs(@nNumMsgs)

	For nMsg := nNumMsgs to 1 step - 1
		lRet	:= .T.
		nPopResult := oMessage:Receive( oMail, nMsg )

		If ( nPopResult == 0 ) //Recebido com sucesso?

			//Verifica todos anexos .XML da mensagem e os salva
			For nAtach := 1 To oMessage:getAttachCount()
				aAttInfo    := {}
				aAttInfo	:= oMessage:getAttachInfo( nAtach )
				cArquivo	:= Upper(AllTrim(aAttInfo[1]))
				If Empty(cArquivo) .and. !Empty(AllTrim(aAttInfo[4]))
					cArquivo := Upper(AllTrim(aAttInfo[4]))
				Endif
				if !Empty(cArquivo) .and. iif(!Empty(cExt),Upper(cExt) == Upper(Right(cArquivo,4)),.T.) .and. !ArquivoJaBaixado(cArquivo)
					If !File(cBaseName + cArquivo)
						lSave := oMessage:SaveAttach(nAtach,cBaseName + cArquivo)
						If !lSave
							Conout("Erro ao salvar anexo: "+cBaseName+cArquivo)
							lRet := .F.
						else
							conout(DtoC(Date())+" "+Time()+" KESTR18 - Download arquivo: "+AllTrim(cArquivo))
							U_KESTR20("01",cArquivo)
						Endif
					Endif
				Endif
			Next
		Endif
		
		oMessage:SetConfirmRead(.T.)
		oMessage:Clear()
		If lDel .and. lRet
			oMail:DeleteMsg(nMsg)
		Endif
	Next

Return

Static Function ArquivoJaBaixado(cArquivo)
	Local lRet	:= .F.
	Local aArea	:= GetArea()
	Local cTemp	:= "BAIXADO"
	Local cQuery:= ""

	cQuery += "SELECT ISNULL(COUNT(*),0) CONTA "+ENTER
	cQuery += "FROM "+RetSqlName("Z06")+" "+ENTER
	cQuery += "WHERE D_E_L_E_T_ <> '*' "+ENTER
	cQuery += "	AND Z06_FILIAL='"+xFilial("Z06")+"' "+ENTER
	cQuery += "	AND Z06_ARQUIV='"+Upper(AllTrim(cArquivo))+"' "+ENTER

	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	Endif

	TcQuery cQuery New Alias (cTemp)

	lRet := (cTemp)->CONTA > 0

	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	Endif

	RestArea(aArea)
Return lRet

	
//Verifica threads disponíveis
User Function FreeThreads( lFreeAll ,_nThreads, pProc)
	// transacoes abertas pelo usuario
	Local aUserInfoArray	:= GetUserInfoArray()
	// ambiente atual do servidor
	Local cEnvServer		:= GetEnvServer()
	// nome do computador
	Local cComputerName		:= GetComputerName()
	// qtd de transacoes abertas
	Local nThreadsAt		:= 0
	
	// valida se existem transacoes ativas
	Default lFreeAll		:= .F.
	
	Default pProc := "" 

	If Empty(AllTrim(pProc))
		Return .T.
	Endif
	
	// faz loop nas transacoes abertas pelo usuario
	aEval	( aUserInfoArray,	{ |aThread| IIF	( aThread[2] == cComputerName 	.and.	 ;
												  aThread[5] == pProc 			.and.	 ;
												  aThread[6] == cEnvServer 				,;
												  nThreadsAt++ 							,;
												  NIL									 ;
												);
								};
			)
	
	// verifica se tem alguma transacao
	IF lFreeAll
		// existe transacao
		lFreeThreads	:= nThreadsAt == 0
	// verifica se existem slots para transcao
	Else
		// existem slots?
		lFreeThreads	:= nThreadsAt <= Int( _nThreads / 2 )
	EndIF
	
	// retorna
Return lFreeThreads

