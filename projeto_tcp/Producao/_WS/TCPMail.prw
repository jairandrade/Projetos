#include "protheus.ch"

/*/{Protheus.doc} TCPMail
Classe responsável por centralizar as funções de envio de email
@author Kaique Sousa
@since 17/07/2019
@version 1.0
/*/
Class TCPMail
    
    Data _lUsaSSL	
    Data _lUsaTLS	
    Data _lSMTPAuth	 
    Data cPopAddr  	
    Data cSMTPAddr 	
    Data nPOPPort  	
    Data nSMTPPort 	
    Data cFrom		
    Data cLogin   	
    Data cConta		
    Data cPass
    Data nSMTPTime 	
    
    Method New() CONSTRUCTOR
    Method SendMail()

EndClass

/*/{Protheus.doc} New
Metodo Construtor da classe 
@author Kaique Sousa
@since 17/07/2019
@version 1.0
@return self, objeto
/*/
Method New() Class TCPMail
    
    self:_lUsaSSL		:= GETNEWPAR("MV_RELSSL"		,.F.)																// 01 - Indica se usa SSL
    self:_lUsaTLS		:= GETNEWPAR("MV_RELTLS"		,.F.)  																	// 02 - Indica se usa TSL
    self:_lSMTPAuth		:= GETNEWPAR("MV_RELAUTH"	,.T.) 																	// 03 - Indica se precisa fazer autenticacao SMTP
    self:cPopAddr  		:= ""	  															// 04 - Endereco do servidor POP3
    self:cSMTPAddr 		:= GETNEWPAR("MV_RELSERV"		,".....................")	  														// 05 - Endereco do servidor SMTP
    self:nPOPPort  		:= GETNEWPAR("MV_RELPOP3"		,110)			  														// 06 - Porta do servidor POP
    self:nSMTPPort 		:= GETNEWPAR("MV_RELSMTP"		,25)       		  													// 07 - Porta do servidor SMTP
    self:cFrom			:= GETNEWPAR("MV_RELFROM"		,"")																	// 08 - Usuario que envia o e-mail
    self:cLogin   	  	:= GETNEWPAR("MV_RELACNT"		,".....")																// 09 - Usuario para autenticacao no servidor de email
    self:cConta			:= GETNEWPAR("MV_RELAUSR"		,".........................")																	// 10 - Conta a ser utilizada no envio do email
    self:cPass     		:= GETNEWPAR("MV_RELPSW"		,"........") 						  											// 11 - Senha do usuario de autenticacao
    self:nSMTPTime 		:= 60  

Return(self)

/*/{Protheus.doc} SendMail
Classe responsavel pelo envio do email
@author Kaique Sousa
@since 17/07/2019
@version 1.0
@param  cMail, Caracter, email
        cSubject, caracter, conteudo
        xBody, caracter, html para envio no corpo do email
        cError, caracter, variavel passada por parametro para exibição de erros
        aAnexo, arraym anexo
/*/
Method SendMail(cMail,cSubject,xBody,cError,aAnexo) Class TCPMail
    
    Local oServer   := Nil
    Local oMessage 	:= Nil
    Local cTic		:= ""
    Local nRet		:= 0
    Local nErr     	:= 0
    Local aMail		:= {}
    Local cEMail	:= ""
    Local cEmailTmp	:= "" 
    Local cEmailOri	:= ""
    Local lEmailOK	:= .T.

    Local _nI, _nZ		:= 0

    Local _cBuf			:= ""
    Local cBody			:= ""

    Default cMail		:= ""
    Default cSubject	:= "Sem assunto"
    Default xBody		:= "NiHil"
    Default cError		:= ""
    Default aAnexo		:= {}

    //Trata caso o paramentro cMail venha como Array !
    If ValType(cMail) = "A"
        For _nI := 1 To Len(cMail)
            cEmailTmp += cMail[_nI] + ';'
        Next _nI
        cMail := cEmailTmp
        cEmailTmp := ""
    EndIf

    //Prepara uma array com os e-mail (caso tenham vindo com separador , ou ;
    //Troca possiveis , por ; - padronizacao de separacao de e-mails
    cMail := StrTran(cMail,',',';')
    cMail := StrTran(cMail,';;',';')
    aMail := U_LINCOL(cMail,';')

    //Prepara os destinatarios.
    For _nI := 1 To Len(aMail)

        //Guardo e-mail original para Log
        cEMailOri += AllTrim(aMail[_nI]) + If(_nI < Len(aMail),',','')

        //Tento ajustar algumas coisas comuns ao informar um e-mail
        cEmailTmp := Lower(AllTrim(aMail[_nI]))

        //If U_MailOK( @cEmailTmp , @cInfoTmp )  //Funcao de Validacao de e-mail (Castrillon Auto Pecas)
        cEMail += cEmailTmp + If(_nI < Len(aMail),',','')
        //EndIf
    Next _nI

    // Complementa o erro com mais informacoes
    cTic += "-------------------------------------------------" + CRLF
    cTic += "[LOGIN    ]-" + ::cLogin + CRLF
    cTic += "[PASS     ]-" + ::cPass + CRLF
    cTic += "[FROM     ]-" + ::cFrom + CRLF
    cTic += "[TO_ORI   ]-" + cEmailOri + CRLF
    cTic += "[TO_OK    ]-" + cEmail + CRLF
    cTic += "[SUBJECT  ]-" + cSubject + CRLF
    cTic += "[SMTPADDR ]-" + ::cSMTPAddr + CRLF
    cTic += "[USASSL   ]-" + If(::_lUsaSSL,'SIM','NAO') + CRLF
    cTic += "[USATLS   ]-" + If(::_lUsaTLS,'SIM','NAO') + CRLF
    cTic += "[USAAUTH  ]-" + If(::_lSMTPAuth,'SIM','NAO') + CRLF

    //Verifica se houve pelo menos 1 e-mail valido para envio ou tudo que veio eh invalido
    If Empty(cEmail)		//Tudo Invaliado
        cError += "[ERROR]Email(s) informado(s) invalido(s)!" + CRLF 
        cError += CRLF + CRLF + cTic
        Return( .F. )
    EndIf	

    If Empty(oServer)

        // Instancia um novo TMailManager
        oServer := tMailManager():New()

        // Usa SSL na conexao
        If	::_lUsaSSL
            oServer:SetUseSSL(.T.)
        Else
            oServer:SetUseSSL(.F.)
        EndIf

        // Usa TLS na conexao
        If	::_lUsaTLS
            oServer:SetUseTLS(.T.)
        Else
            oServer:SetUseTLS(.F.)
        EndIf
        
        // Inicializa
        oServer:init(::cPopAddr, ::cSMTPAddr, ::cLogin, ::cPass, ::nPOPPort, ::nSMTPPort)
        
        // Define o Timeout SMTP
        if oServer:SetSMTPTimeout(::nSMTPTime) != 0
            cError += "[ERROR]Falha ao definir timeout"
            cError += CRLF + CRLF + cTic
            Return( .F. )
        endif
        
        // Conecta ao servidor
        nErr := oServer:smtpConnect()
        If nErr <> 0
            cError += "[ERROR]" + oServer:getErrorString(nErr)
            cError += CRLF + CRLF + cTic
            oServer:smtpDisconnect()
            Return( .F. )
        EndIf
        
        If ::_lSMTPAuth
            nRet := oServer:SMTPAuth(::cLogin, ::cPass)
            If nRet <> 0
                nRet := oServer:SMTPAuth(::cConta, ::cPass)
                If nRet <> 0
                    nRet := oServer:SMTPAuth(::cFrom, ::cPass)			
                    If nRet <> 0			
                        cError += "[ERROR]Falha na autenticação SMTP"
                        cError += CRLF + CRLF + cTic
                        Return( .F. )
                    EndIf
                Endif
            Endif
        EndIf

    EndIf	

    //Tratamento do Corpo do e-mail
    //Se xBody for uma String - procedimento Normal - apenas passa para objeto TMailMessage
    //Se xBody for um Array segue a seguinte estrutura
    // xBody[1] - Nome do Arquivo HTML modelo para uso (caminho relativou ou absoluto)
    // xBody[2][1..N] - Array contendo Nome da Variavel e Valor de Substituicao
    //                  {"Variavel","Valor de Substituicao"}
                            
    If ValType(xBody) = "A"

        If !File(xBody[1])
            cBody := "NiHil"
        Else
            FT_FUSE(xBody[1])
            FT_FGOTOP()
        
            While !FT_FEOF() //FACA ENQUANTO NAO FOR FIM DE ARQUIVO IncProc()
                _cBuf := FT_FREADLN()
                cBody += _cBuf + CR
            FT_FSKIP()   //próximo registro no arquivo txt
            EndDo
        
            FT_FUSE()
        Endif

        For _nI := 1 To Len(xBody[2])	
            cBody := StrTran( cBody , xBody[2][_nI][1] , xBody[2][_nI][2] )
        Next _nI
    Else
        cBody := xBody
    EndIf

    // Cria uma nova mensagem (TMailMessage)
    oMessage := tMailMessage():new()
    oMessage:clear()
    oMessage:cFrom    := ::cFrom
    oMessage:cTo      := cEMail
    //	oMessage:cCC      := _cCC
    oMessage:cSubject := cSubject
    oMessage:cBody    := cBody

    //Anexa arquivos
    For _nI := 1 To Len(aAnexo)
        If File(aAnexo[_nI])
            If oMessage:AttachFile( aAnexo[_nI] ) < 0
                cError += "[ERROR]Erro ao atachar o arquivo"
                cError += CRLF + CRLF + cTic
                Return( .F. )
            Else                     
                oMessage:AddAtthTag( "Content-Disposition: attachment; filename=" + Substr(aAnexo[_nI],RAt("\",aAnexo[_nI])+1) )
            EndIf
        EndIf
    Next _nI

    // Envia a mensagem
    nErr := oMessage:send(oServer)

    If nErr <> 0
        cError += '[ERROR]' + oServer:getErrorString(nErr)
        cError += CRLF + CRLF + cTic
        Return( .F. )
    EndIf

Return( .T. )