#INCLUDE "PROTHEUS.CH"       
#include "topconn.ch"
#include "tbiconn.ch"
#Include "AP5MAIL.CH"

User Function F200IMP()//F200FIM() -- ALTERADO PARA NÃO INTERFERIR NA GRAVAÇÃO DA SE5 
	local aParcela		:= {}
	local cChaveFile	:= ""
	local aArea := GetArea()
	// Lista de empresas onde o envio de boleto é prsac	ermitido
	local cListEmp	:= "01/02/03/04/05/07" //GetMV("KP_F200EMP", .f., "01/02/03/04/05/07")
	local lDelPDF	:= GetMV("KP_F200DEL", .f., .f.)	// Deleta PDF
	local cExt			:= ""
	local cFile		:= ""
	local _nWait	:= GetMV("KP_F200TW", .f., 1) * 1000 
	local nI 

	if FwCodEmp() $ cListEmp
		SplitPath(AllTrim(MV_PAR04), /*@cDrive*/, /*@cPath*/, @cFile, @cExt)
		cFile += cExt
		cFile := PadR(cFile, TamSX3("Z0A_FILE")[1])

		cChaveFile := cFile //SE1->E1_FILIAL + 

		// 27.06.2018
		If Select("TRB")<>0
			DbSelectArea("TRB")
			dbCloseArea()
		Endif

		cQry := "SELECT *"
		cQry += " FROM "+RetSqlName("Z0A") + " Z0A "
		cQry += " WHERE D_E_L_E_T_ = ' ' "
		cQry += "   AND Z0A_FILE = '"+cFile+"' "

		TCQUERY cQry NEW ALIAS "TRB"

		while !TRB->(eof()) .and. cChaveFile == TRB->Z0A_FILE
			aParcela := {}
			cChave := TRB->(Z0A_FILIAL + Z0A_FILE + Z0A_CLIENT + Z0A_LOJA + Z0A_NUM)
			while cChave == TRB->(Z0A_FILIAL + Z0A_FILE + Z0A_CLIENT + Z0A_LOJA + Z0A_NUM)
				if TRB->Z0A_STATUS == 'N'
					SE1->(dbGoTo(TRB->Z0A_E1RECN))
					dbSelectArea("SA1")
					SA1->(dbSetOrder(1))
					if SA1->(dbSeek(xFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA)))
						aAdd(aParcela, {SE1->(RecNo()), SA1->(RecNo()), TRB->(RecNo())})
					endif
				endif
				TRB->(dbSkip())
			enddo

			if Len(aParcela) > 0
				cFPath := U_BOLKAPX(aParcela)
				Sleep(_nWait)
				aFSize	:= {}
				aFile	:= {}
				nArq	:= ADir(cFPath, @aFile, @aFSize)
				SLEEP(2000)
				
				//ConOut("F200FIM | " + Time() + " | " + cFPath + " | " + cValToChar(Iif(Len(aFSize)>0, aFSize[1], 999999999)) + ' bytes')
				If !Empty(cFPath) .And. nArq > 0 .And. Len(aFSize) > 0 .And. aFSize[1] > 0
					lRet := fSendBol(cFPath, aParcela)

					for nI := 1 to Len(aParcela)
						//TRB->(dbGoTo(aParcela[nI,3]))

						dbSelectArea("Z0A")
						dbGoTop()
						Z0A->(dbSetOrder(1)) //Z0A_FILIAL+Z0A_FILE+Z0A_CLIENT+Z0A_LOJA+Z0A_NUM+Z0A_PARCEL                                                                                                      
						Z0A->(dbseek(SE1->E1_FILIAL+alltrim(STR(aParcela[nI,1]))))

						RecLock("Z0A", .F.)
						Z0A->Z0A_STATUS := IIF(lRet, 'E', 'N')
						Z0A->Z0A_STDESC := IIF(lRet, 'Email enviado com sucesso', 'Erro ao enviar email')
						//Z0A->Z0A_EMAIL := ALLTRIM(SA1->A1_EMAIL) - Luis 21-05-18 Comentado após atualizacao, pois o campo nao existia na Base(Alinhado com o André).
						MsUnlock()

					next nI


					if lDelPDF
						FErase(cFPath)
					endif
				endif
			endif
		enddo
	endif

	RestArea(aArea)
Return

static function fSendBol(cFilePath, aTitulos)
local oMailSend
local aArea		:= GetArea()
local cUsr 		:= GetMV('KP_MBOLUSR', .f., 'kapazi')
local cPwd 		:= GetMV('KP_MBOLPWD', .f., 'laertes77')
local nPort		:= GetMV('KP_MBOLPRT', .f., 587)
local cAddr		:= GetMV('KP_MBOLADD', .f., 'smtplw.com.br')
local cFrom		:= GetMV('KP_MBOLMFR', .f., 'boleto@kapazi.com.br')
local cMailTo	:= ""
local cCC		:= GetMV('KP_MBOLMCC', .f., 'boleto@kapazi.com.br')
local cSubj		:= GetMV('KP_MBOLMSJ', .f., 'Boleto de cobrança')
local cMsg 		:= GetMV('KP_MBOLMMG', .f., 'Caro cliente, segue anexo boleto de cobrança.')
local aTplVar	:= {}
local nI
default cFilePath := ''


	SA1->(dbGoTo(aTitulos[1,2]))
	cMailTo := StrTran(AllTrim(SA1->A1_EMAIL),";",",")
	
	If SubStr(cMailTo,Len(cMailTo)-1,1) == ","
		cMailTo := SubStr(cMailTo,1,Len(cMailTo)-1)
	EndIf	
	
	cVenc := ""
	//ANDRE-RSAC 11/10/2017
	cComplMSG := SUBSTR(cFilePath, AT(".", cFilePath) - 9)  
	cComplMSG := SUBSTR(cComplMSG,1,9)

	for nI := 1 to Len(aTitulos)
		SE1->(dbGoTo(aTitulos[nI,1]))
		cVenc += DtoC(SE1->E1_VENCTO) + ', '
	next nI
	cVenc := Left(cVenc, Len(cVenc) - 2)

	//Inicia o processo do workflow
	oWfProc   := TWfProcess():New( "000002", "RELATORIOS", NIL )
	
	//Layout  
	cWfTaskId := oWfProc:NewTask( "RELATORIOS",  "\workflow\mailboleto.html" )     
	oWfHtml   := oWfProc:oHtml
	
	//Atualiza variáveis
	oWfProc:ClientName(cUserName)
	oWfHtml:ValByName("NOMECLI"		, Posicione("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA, "A1_NOME"))   //alterado 05.05.2017 -- a pedido de Aluisio (A1_CONTATO) --aNDRE/rSAC
	oWfHtml:ValByName("VENCTO"		, cVenc)
	oWfHtml:ValByName("MAILFROM"	, cFrom)
	
	//Define as propriedades de envio do e-mail	
	oWfProc:cFromAddr := cFrom
	oWfProc:cFromName := cFrom  
	oWfProc:cTo       := cMailTo + "," + cCC	
		
	oWfProc:cSubject  := cSubj + " - " + substr(SA1->A1_NOME,1,20) + " - " + cComplMSG  //alterado 11.01.2017 -- Andre/Rsac
	oWfProc:AttachFile(cFilePath)
	oWfProc:bReturn   := Nil
	
	//Inicia o processo
	oWfProc:Start()
	
	//Chama o workflow para enviar os e-mails
	WfSendMail()
	
	RestArea(aArea)
return .t.
/*
user function marota()
RPCSETENV('04', '01')

aParcela := {;
{190275, 294, 5129},;
{190276, 294, 5130},;
{190277, 294, 5131},;
{190278, 294, 5132}}



dbSelectArea("Z0A")
while !Z0A->(eof())
aParcela := {}
cChave := Z0A->(Z0A_FILIAL + Z0A_FILE + Z0A_CLIENT + Z0A_LOJA + Z0A_NUM)
while cChave == Z0A->(Z0A_FILIAL + Z0A_FILE + Z0A_CLIENT + Z0A_LOJA + Z0A_NUM)
SE1->(dbGoTo(Z0A->Z0A_E1RECN))
dbSelectArea("SA1")
SA1->(dbSetOrder(1))
if SA1->(dbSeek(xFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA)))
aAdd(aParcela, {SE1->(RecNo()), SA1->(RecNo()), Z0A->(RecNo())})
endif
Z0A->(dbSkip())
enddo

if Len(aParcela) > 0
cFPath := U_BOLKAPX(aParcela)
Sleep(1000)
aFSize	:= {}
aFile		:= {}
nArq		:= ADir(cFPath, @aFile, @aFSize)
nCont		:= 0
while Len(aFSize) > 0 .and. aFSize[1] <= 0
aFSize	:= {}
aFile		:= {}
nArq		:= ADir(cFPath, @aFile, @aFSize)
ConOut("F200FIM | " + Time() + " | " + cFPath + " | " + cValToChar(IIF(Len(aFSize) > 0, aFSize[1], 999999999)) + ' bytes - Tentando ' + cValToChar(nCont++))
enddo
ConOut("F200FIM | " + Time() + " | " + cFPath + " | " + cValToChar(IIF(Len(aFSize) > 0, aFSize[1], 999999999)) + ' bytes')
endif
enddo

return
*/

