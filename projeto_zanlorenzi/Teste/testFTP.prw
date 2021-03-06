#INCLUDE "protheus.ch"
#DEFINE DEFAULT_FTP 21
#DEFINE PATH "\teste\"
Function TestFTP()
	Local aRetDir := {}		//Tenta se conectar ao servidor ftp em localhost na porta 21
	//com usuario e senha anonimos
	if ! FTPCONNECT ( "localhost" , 21 ,"Anonymous", "test@test.com" )
		conout( "Nao foi possivel se conectar!!" )
		Return NIL
	EndIf
	//Tenta mudar do diretorio corrente ftp, para o diretorio
	//especificado como parametro
	if ! FTPDIRCHANGE ( "/test" )
		conout( "Nao foi possivel modificar diretório!!" )
		Return NIL
	EndIf
	//Retorna apenas os arquivos contidos no local
	aRetDir := FTPDIRECTORY ( "*.*" , )
	//Retorna os diretorios e arquivos contidos no local
	//aRetDir := FTPDIRECTORY ( "*.*" , "D")
	//Verifica se o array esta vazio
	If Empty( aRetDir )
		conout( "Array Vazio!!" )
		Return NIL
	EndIf
	//Tenta realizar o download de um item qualquer no array
	//Armazena no local indicado pela constante PATH
	if ! FTPDOWNLOAD ( PATH + aRetDir[1][1], aRetDir[1][1])
		conout( "Nao foi possivel realizar o download!!" )
		Return NIL
	EndIf
	//Tenta renomear um arquivo ou diretorio
	if ! FTPRENAMEFILE ( aRetDir[1][1] , "novo" )
		conout( "Nao foi possivel renomear o arquivo!!" )
		Return NIL
	EndIf
	//Tenta realizar o upload de um item qualquer no array
	//Armazena no local indicado pela constante PATH
	if ! FTPUPLOAD ( PATH, aRetDir[1][1] )
		conout( "Nao foi possivel realizar o upload!!" )
		Return NIL
	EndIf
	//Tenta desconectar do servidor ftp
	FTPDISCONNECT ()
Return NIL
