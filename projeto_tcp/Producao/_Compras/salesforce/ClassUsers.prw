#Include "TOTVS.CH"
#Include "TOPCONN.CH"

/*/{Protheus.doc} ClassUsers

Classe de Valida��o de Login de Usu�rios (Usado no WebService de Integra��o com o Portal)
	
@author Matheus Vieira / Carlos Eduardo Niemeyer Rodrigues 
@since 22/05/2014 / 03/06/2014
/*/
Class ClassUsers

	Data cTitle
	Data cVersion
	Data cLogin
	Data cSenha
	Data lLogged
	Data cLog

	Method newClassUsers() constructor
	
	Method setLogin()
	Method setSenha()
	Method isLogged()
	Method getLog()
	
	Method checkUser()
	Method loginProtheus()
	Method encriptSenhaRC4()
	Method decriptSenhaRC4()
	Method getUserMail()	
		
EndClass
 
/*/{Protheus.doc} newClassUsers

M�todo Construtor da Classe
	
@author Matheus Vieira
@since 22/05/2014
/*/
Method newClassUsers() class ClassUsers
	
	::cTitle	:= "Classe de Valida��o de Usu�rios"
	::cVersion	:= "1.01-16/08/2014"

Return Self


/*/{Protheus.doc} setLogin

Define o Login do Usu�rio
	
@author Carlos Eduardo Niemeyer Rodrigues
@since 03/06/2014

@param cLogin, Caracter, Login do Usu�rio
/*/
Method setLogin(cLogin) class ClassUsers
	::cLogin := cLogin
Return 

/*/{Protheus.doc} setSenha

Define a Senha do Usu�rio
	
@author Carlos Eduardo Niemeyer Rodrigues
@since 03/06/2014

@param cSenha, Caracter, Senha do Usu�rio
/*/
Method setSenha(cSenha) class ClassUsers
	::cSenha := cSenha
Return

/*/{Protheus.doc} isLogged

Verifica se o Usu�rio est� Logado
	
@author Carlos Eduardo Niemeyer Rodrigues
@since 03/06/2014

@return Logico lLogged Retorna se o Usu�rio est� Logado
/*/
Method isLogged() class ClassUsers
Return (::lLogged)

/*/{Protheus.doc} getLog

Retorna o Log de Conex�o
	
@author Carlos Eduardo Niemeyer Rodrigues
@since 03/06/2014

@return Caracter cLog Retorna o Log de Conex�o
/*/
Method getLog() class ClassUsers
Return (::cLog)

/*/{Protheus.doc} encriptSenhaRC4

Realiza a Criptografia de Senha usando a Criptografia RC4
http://tdn.totvs.com/display/tec/RC4Crypt
http://www.ascii-code.com/
http://www.fyneworks.com/encryption/rc4-encryption/
	
@author Carlos Eduardo Niemeyer Rodrigues
@since 09/06/2014

@param cPassword, String, Senha a Encriptar
@param cChaveCriptografada, String, Chave de Descriptografia (Padr�o: ZZ_CHAVCRI)

@return String cPasswordHexa Senha encriptada em Hexadecimal
/*/
Method encriptSenhaRC4(cPassword,cChaveCriptografada) Class ClassUsers
	Local cPasswordHexa := ""

	Default cChaveCriptografada := AllTrim(GetNewPar("ZZ_CHAVCRI", "123456789"))
	Default cPassword			:= ::cSenha 
	
	cChaveCriptografada	:= AllTrim(cChaveCriptografada)
	cPasswordHexa 		:= RC4Crypt( cPassword , cChaveCriptografada, .T.)	

Return (cPasswordHexa)

/*/{Protheus.doc} decriptSenhaRC4

Realiza a descriptografia de Senha usando a Criptografia RC4
http://tdn.totvs.com/display/tec/RC4Crypt
http://www.ascii-code.com/
http://www.fyneworks.com/encryption/rc4-encryption/
	
@author Matheus Vieira / Carlos Eduardo Niemeyer Rodrigues
@since 22/05/2014 / 09/06/2014

@param cPasswordHexa, String, Senha em Hexadecimal a Descriptar
@param cChaveCriptografada, String, Chave de Descriptografia (Padr�o: ZZ_CHAVCRI)

@return String cPassword Senha descriptografada
/*/
Method decriptSenhaRC4(cPasswordHexa,cChaveCriptografada) Class ClassUsers
	
	Default cChaveCriptografada := AllTrim(GetNewPar("ZZ_CHAVCRI", "123456789"))
	Default cPasswordHexa		:= "" 

	cPassword 			:= convStringToHexadecimal(cPasswordHexa)
	cChaveCriptografada	:= AllTrim(cChaveCriptografada)
	cPassword 			:= RC4Crypt( cPassword , cChaveCriptografada, .F.)

Return (cPassword)

/*/{Protheus.doc} checkUser

Verifica se o usu�rio passado para WebService � v�lido
	
@author Matheus Vieira
@since 22/05/2014

@param parlogin, String, Login do Usu�rio
@param parSenha, String, Senha do Usu�rio

@return L�gico (.T., .F.) -> True, est� validado
/*/
Method checkUser(cParLogin, cParSenha) class ClassUsers
	local lRet 			:= .F.
	local cLog 			:= ""
	local aDados 		:= {}

	Default cParLogin	:= ""
	Default cParSenha 	:= ""
	
	::cLogin := cParLogin
	::cSenha := cParSenha

	//Pesquisa Usu�rio por Login
	PswOrder(2)
	If PswSeek(::cLogin,.T.) //Se usu�rio encontrado
	                       
		//Recupera informa��es do Usu�rio
		aDados := PswRet() 
			
		//Verifica a Senha do Usu�rio posicionado
		If PswName(::cSenha)
			//Executa o Login no Protheus
			::loginProtheus(::cLogin)
			lRet := .T.								
		Else 
			cLog += "[ClassUsers] Aten��o! A senha informada para o usu�rio '" + AllTrim(::cLogin) + "' � inv�lida."
		Endif
	Else
		cLog += "[ClassUsers] Aten��o! O usu�rio '" + Alltrim(::cLogin) + "' informado � inv�lido."
	Endif
	
	if !Empty(cLog)                                           
		::cLog := cLog
		showLog(cLog)		
	endif 
	
Return (lret)

/*/{Protheus.doc} loginProtheus

Efetua o Login no Protheus, atualizando vari�veis P�blicas do Protheus
	
@author Carlos Eduardo Niemeyer Rodrigues
@since 04/06/2014

@param cCodUser, String, C�digo do Usu�rio a realizar o Login no Protheus

@return L�gico (.T., .F.) -> True, est� logado no Protheus
/*/
Method loginProtheus(cParLogin) Class ClassUsers
	Local cSenhaUsr    	:= ""
	Local aDadosUser 	:= {}
	Local lRet			:= .F.
	Local cLog			:= ""

	Default cParLogin := ""
	
	::cLogin := cParLogin

	//Define o Usu�rio Logado		
	//Pesquisa Usu�rio por C�digo de Usu�rio
	PswOrder(1)
	If PswSeek(::cLogin,.T.) //Se usu�rio encontrado
		lRet := .T.		
			                       
		//Recupera informa��es do Usu�rio
		aDadosUser := PswRet() 
		
		cSenhaUsr	:= aDadosUser[01,03] //Senha Criptografada
			
		//Atualiza o Usu�rio Corrente - Atualiza Vari�veis Private
		cUserName	:= aDadosUser[01,02] //Altera o Login do Usu�rio
		__cUserID	:= ::cLogin      	 //Altera o C�digo do Usu�rio Logado			
		__NUSERACS	:= aDadosUser[01,15] //N�mero de Acessos do Usu�rio 
		cUsuario	:= Padr(cSenhaUsr,6)+Padr(aDadosUser[01,02],15)+aDadosUser[02,05] //Atualiza Vari�vel de Usu�rio Completa (Full)
	Else
		cLog := "[ClassUsers] Aten��o! O usu�rio '" + Alltrim(::cLogin) + "' informado � inv�lido."
	Endif
	
	::cLog		:= cLog
	::lLogged 	:= lRet
	
Return (lRet)

/*
	Fun��o para Converter uma String ASCII em Hexadecimal
*/
Static Function convStringToHexadecimal(cASCII)
	Local cRet 	:= ""
	Local cAux	:= ""
	Local nCont	:= 0

	For nCont:=1 to len(cASCII)
		cAux := substr(cASCII, nCont, 2)
		cRet += chr(CTON(cAux, 16))
		nCont++
	Next nCont
	
Return (cRet)

/*/{Protheus.doc} getUserMail

Retorna o E-mail do Usu�rio informado
	
@author Carlos Eduardo Niemeyer Rodrigues
@since 15/07/2014

@param cUserName, String, Nome do Usu�rio a realizar o Login no Protheus

@return Caracter, contendo o E-mail do Cadastro do Usu�rio se encontrado
/*/
Method getUserMail(cUserName) Class ClassUsers
	Local aDadosUser 	:= {}
	Local cEmail		:= ""

	Default cUserName 	:= ""

	PswOrder(2) //Pesquisa por Nome
	If PswSeek(cUserName,.T.)
		aDadosUser 	:= PswRet()		
		cEmail		:= aDadosUser[01,14]
	Endif
	
Return (cEmail)

/*
	Apresenta Logs
*/
Static Function showLog(cMensagem,lAtivaLog)
	Default lAtivaLog	:= GetNewPar("ZZ_USRLOGS",.T.)
	Default cMensagem 	:= ""
	
	If lAtivaLog
		//Conout(OEMToAnsi(cMensagem))
	Endif
	
Return