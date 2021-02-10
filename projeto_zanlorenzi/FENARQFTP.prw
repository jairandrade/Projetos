#Include "Protheus.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} fEnArqFTP
Função para Geração/Enviao ao FTP de Arquivos CNABs a Pagar/Receber
@type function
@version 1.0
@author Carlos Cleuber Pereira
@since 13/11/2020
@param pBanco, Caracter, Codigo do banco a ser Gerado o CNAB
@param pCarteria, Carater, Tipo da Cartereira a ser Gerada P-Pagar / R-Receber
@param pArquivo, Nome do Arquivo a ser enviado para o FTP
@return return_type
/*/
User Function FTPCnabAt( pCarteira,pArquivo,pBanco, pAgencia, pConta, pSubCta )
Local aSEE		:= SEE->(GetArea())
Local cArquivo	:= lower(alltrim(pArquivo))
Local cDir		:= alltrim(SuperGetMV( "MV_XDIRFTP",, "\env_cnab_ftp"))
Local cDirEnv	:= ""
Local cDirNEnv	:= ""
Local cDirRej	:= ""
Local cAdress	:= ""
Local nPorta	:= ""
Local cUser		:= ""
Local cPass		:= ""
Local cKey		:= FWxFilial("SEE")+padr(pBanco, TamSX3("EE_CODIGO")[1])+ ;
									padr(pAgencia, TamSX3("EE_AGENCIA")[1])+;
									padr(pConta	, TamSX3("EE_CONTA")[1])+;
									padr(pSubCta	, TamSX3("EE_SUBCTA")[1])
Local cNomBco	:= ""
Local oFtp		:= Nil
Local nStat

DbSelectArea("SEE")
SEE->(DbSetorder(1))
If SEE->(Dbseek(cKey,.T.))

	// Força a retirada da barra caso exista, para que o controle seja feito pela função
	If substr(cDir,len(cDir),1) == '\' 
		cDir:= lower(substr(cDir,1,len(cDir)-1))
	Endif	

	If ! File("c:"+cDir+"\"+cArquivo)
		
		Aviso("Erro","Arquivo C:" + cDir + "\" + cArquivo + " não existe na pasta informada!!!",{"OK"}, 3 )

	Else

		cDirAnt:= cDir
		If pCarteira == "P"
			cDir+= "\pagar"
		Else
			cDir+= "\receber"
		Endif

		If !ExistDir(cDir) 
			MakeDir(cDir) 
		Endif

		cNomBco	:= alltrim(SEE->EE_CODIGO)+"_"+alltrim(SEE->EE_CONTA)+"_"+alltrim(SEE->EE_SUBCTA)
		If !ExistDir(cDir+"\"+cNomBco) 
			MakeDir(cDir+"\"+cNomBco) 
		Endif

		cDirNEnv:= cDir+"\"+cNomBco+"\NaoEnviados"
		cDirEnv	:= cDir+"\"+cNomBco+"\Enviados"
		cDirRej	:= cDir+"\"+cNomBco+"\Rejeitados"

		If !ExistDir(cDirEnv) 
			MakeDir(cDirEnv) 
		Endif

		If !ExistDir(cDirRej) 
			MakeDir(cDirRej) 
		Endif

		cDirNEnv+= "\"
		cDirEnv	+= "\"
		cDirRej += "\"

		__CopyFile( "c:"+cDirAnt + "\"+ cArquivo, cDirNEnv + cArquivo,,,.f. )	
		FErase( "c:"+ cDirAnt + "\" + cArquivo )

		cAdress	:= alltrim(SEE->EE_XFTPEND)
		nPorta	:= SEE->EE_XFTPPOR
		cUser	:= lower(alltrim(SEE->EE_XFTPUSR))
		cPass	:= lower(alltrim(SEE->EE_XFTPPWD))	

		oFtp := TFTPClient():New( )
		nStat := oFtp:FtpConnect( cAdress, nPorta, cUser, cPass )
		If nStat != 0
			__CopyFile( cDirNEnv + cArquivo, cDirRej + cArquivo,,,.f. )
			Memowrite( cDirRej + "erro_ftp_" + strtran(substr(time(),1,5),":","") + "_" + dtos(dDataBase)+".txt","FTPClient - Erro de Conexao " + cValToChar( nStat ))
		Else
			
			If oFtp:SendFile( cDirNEnv + cArquivo, cArquivo ) == 0  
				__CopyFile( cDirNEnv + cArquivo, cDirEnv +cArquivo,,,.f.)
			else
				__CopyFile( cDirNEnv + cArquivo, cDirRej + cArquivo,,,.f. )
				Memowrite( cDirRej + "erro_ftp_" + strtran(substr(time(),1,5),":","") + "_" + dtos(dDataBase)+".txt", "Erro de copia do arquivo para  FTP. Arquivo: ")
			EndIf
			FErase( cDirNEnv + cArquivo )
				
			oFtp:Close( )
		EndIf

		FreeObj(oFTP)
		oFTP := Nil
	Endif

Endif

RestArea(aSEE)

Return
