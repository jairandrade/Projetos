#include "TOTVS.CH"
User Function exFTP()
	Local nRet
	Local nI
	Local sRet
	Private oFTPHandle
    		cAdress	:= "192.168.7.8"
		nPorta	:= 21
		cUser	:= "workflow"
		cPass	:= "#ZcL#"

	oFTPHandle := tFtpClient():New()
	nRet := oFTPHandle:FTPConnect(cAdress, nPorta, cUser, cPass)
	sRet := oFTPHandle:GetLastResponse()
	Conout( sRet )

	If (nRet != 0)
		Conout( "Falha ao conectar" )
		Return .F.
	EndIf

	oFTPHandle:GetCurDir(sRet)
	Conout(sRet)
	sRet := oFTPHandle:GetLastResponse()
	Conout(sRet)

	oFTPHandle:GetHelp("")
	sRet := oFTPHandle:GetLastResponse()
	Conout(sRet)

	nRet := oFTPHandle:GetMLCount()
	varinfo("GetMultiLineRespLineCount ret",nRet)

	for nI :=0 to nRet
		sRet := oFTPHandle:GetMLLine(nI)
		Conout(sRet)
	next

	nRet := oFTPHandle:MkDir("remote_folder")
	varinfo("Mkdir ret",nRet)
	sRet := oFTPHandle:GetLastResponse()
	Conout(sRet)

	nRet := oFTPHandle:Directory("*")
	varinfo("Directory ret",nRet)
	sRet := oFTPHandle:GetLastResponse()
	Conout(sRet)

	nRet := oFTPHandle:ChDir("remote_folder")
	varinfo("Chdir ret",nRet)
	sRet := oFTPHandle:GetLastResponse()
	Conout(sRet)

	oFTPHandle:GetCurDir(sRet)
	sRet := oFTPHandle:GetLastResponse()
	Conout(sRet)

	nRet := oFTPHandle:SendFile("arquivo.txt", "arquivo_ftp.txt")
	varinfo("SendFile ret",nRet)
	sRet := oFTPHandle:GetLastResponse()
	Conout(sRet)

	nRet := oFTPHandle:RenameFile("arquivo_ftp.txt", "arquivo2.txt")
	varinfo("RenameFile ret",nRet)
	sRet := oFTPHandle:GetLastResponse()
	Conout(sRet)

	nRet := oFTPHandle:DeleteFile("arquivo2.txt")
	varinfo("DeleteFile ret",nRet)
	sRet := oFTPHandle:GetLastResponse()
	Conout(sRet)

	nRet := oFTPHandle:CdUp()
	varinfo("CdUp ret",nRet)
	sRet := oFTPHandle:GetLastResponse()
	Conout(sRet)

	oFTPHandle:GetCurDir(sRet)
	sRet := oFTPHandle:GetLastResponse()
	Conout(sRet)

	nRet := oFTPHandle:ReceiveFile("image001.jpg", "image001_rec.jpg")
	varinfo("Receive ret",nRet)
	sRet := oFTPHandle:GetLastResponse()
	Conout(sRet)

	nRet := oFTPHandle:GetType()
	Conout("Transfer type = " +str(nRet))

	nRet := oFTPHandle:SetType(0)
	sRet := oFTPHandle:GetLastResponse()
	Conout(sRet)

	nRet := oFTPHandle:GetType()
	Conout("Transfer type = " +str(nRet))

	oFTPHandle:NoOp()
	sRet := oFTPHandle:GetLastResponse()
	Conout(sRet)

	nRet := oFTPHandle:Quote("PASV")
	varinfo("PASV ret",nRet)
	sRet := oFTPHandle:GetLastResponse()
	Conout(sRet)

	oFTPHandle:Close()
	sRet := oFTPHandle:GetLastResponse()
	Conout(sRet)
Return
