#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RPTDEF.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RCOM012
E-mail com aviso de erros no envio de carta de avaliação dos fornecedores
no
@return
@author Jair Andrade	
@since 28/10/2020

/*/
//-------------------------------------------------------------------------------
#DEFINE CRLF (chr(13)+chr(10))

User Function RCOM012(aErros)

	Local cTime		:= TIME()
	Local nCont 	:= 0
	Local nX 		:= 0
	Local cCC		:= ''

	Private aErrosGer := aErros
	Private cDirPdf 	:= "\_FORNECEDOR_PDF\"
	Private cNomeRel 	:= "SA2_"+"_" + SubStr(DtoS(Date()),1,4) + SubStr(DtoS(Date()),5,2) + SubStr(DtoS(Date()),7,2) +;
		SubStr(cTime, 1, 2) + SubStr(cTime, 4, 2) + SubStr(cTime, 7, 2) + ".pdf"

	Private nPagi    	:= 0

	Private oFont10		:= TFont():New("Arial",,10,,.F.,,,,.F.,.F.)
	Private oFont10n	:= TFont():New("Arial",,10,,.T.,,,,.F.,.F.)
	Private oFont12n	:= TFont():New("Arial",,12,,.T.,,,,.F.,.F.)
	Private oFont13n	:= TFont():New("Arial",,13,,.T.,,,,.F.,.F.)
	Private oFont16n	:= TFont():New("Arial",,16,,.T.,,,,.F.,.F.)
	Private oFont24n	:= TFont():New("Arial",,24,,.T.,,,,.F.,.F.)

	Private nLin		:= 0
	Private oPrint		:= NIL

	If len(aErrosGer) <= 0
		Return
	EndIf
//Verifica se a pasta existe
	If !ExistDir(cDirPdf)
		MakeDir(cDirPdf)
	EndIf 

	oPrint := FWMSPrinter():New(cNomeRel,IMP_PDF,.T.,cDirPdf,.T.,,,,,.F.,,.F.,1 )

	oPrint:SetLandscape()
	oPrint:SetPaperSize(DMPAPER_A4)
	oPrint:SetMargin(05,05,05,05)

	oPrint:cPathPDF := cDirPdf

	ImpCabec()

	nPagi := 1

	nLin += 70
	oPrint:Say(nLin,0050,"Descrição",oFont10n)
	nLin += 10	
	oPrint:Line(nLin,0050,nLin,3000)
	ProcRegua(RecCount())
	For nX := 1 To Len(aErrosGer)
		nCont++
		nLin += 10		
		VERQUEBRA("N")
		nLin += 30
		oPrint:Say(nLin,0050,aErrosGer[nX],oFont10n)
		IncProc()
	Next nX
	nLin += 20	
	oPrint:Line(nLin,0050,nLin,3000)
	nLin += 050
	oPrint:Say(nLin,2350,"Total de Erros: ",oFont13n)
	oPrint:Say(nLin,2840,Transform(nCont,"@E 99,999,999"),oFont13n,,,,1)

	oPrint:Say(2250,2800,"Página: "+Transform(nPagi,"@E 99"),oFont10n)
	oPrint:Say(2250,0070,DtoC(Date())+"  "+cTime,oFont10n)

	oPrint:EndPage()
	oPrint:Preview()

//Envia email do relatorio

	cAssunto := 'Erro no envio carta de avaliação de fornecedores'

	cCorpo := CorpoM()
	cTo		 := alltrim(GetMv("TCP_ALCADP"))
	//cCC		 := alltrim(GetMv("TCP_ALCADP"))

	If !Empty(Alltrim(cTo))
		cArqLog := "\AFS\LOG\"+Alltrim(Funname())+"_"+DtoS(dDatabase)+"_"+StrTran(time(),":","")+"_"+retcodusr()+"_"+SF1->F1_FILIAL+SF1->F1_DOC+".txt"
		MemoWrite(cArqLog,SF1->F1_DOC)
		//envia email para responsaveis.
		MCOM012E(cTo, cCC, cAssunto, cCorpo, cDirPdf + cNomeRel, .F. )
	Else
		Alert('E-mail não enviado devido a falta de cadastro de endereço de e-mail no parametro TCP_ALCADP')
	EndIf

	nRet := FERASE(cDirPdf + cNomeRel)

Return

/*
+------------+-------------+-------+---------------------+------+------------+
! Função     ! IMPCABEC    ! Autor ! Jair Andrade        ! Data ! 28/10/2020 !
+------------+-------------+-------+---------------------+------+------------+
! Parâmetros !                                                               !
+------------+---------------------------------------------------------------+
! Descrição  ! Imprime cabeçalho                                             !
+------------+---------------------------------------------------------------+
*/
Static Function IMPCABEC()

	oPrint:StartPage()
	oPrint:SayBitmap( 080, 140,  "\sigaadv\lgrl01.bmp", 400, 150)
	oPrint:Say(0150,1360,SM0->M0_NOME,oFont24n)
	oPrint:Say(0220,1240,"Log de erros no envio de carta de avaliação de fornecedores",oFont16n)
	oPrint:Line(0245,0050,0245,3000)
	oPrint:Line(0250,0050,0250,3000)
	nLin := 250
	nLin += 35
	oPrint:Say(nLin,0050,"Função:",oFont13n)
	oPrint:Say(nLin,0280,FunName(),oFont13n)
	oPrint:Say(nLin,1450,"Usuario:",oFont13n)
	oPrint:Say(nLin,1680,cUserName,oFont13n)
	nLin+=35
	oPrint:Say(nLin,0050,"Data:",oFont13n)
	oPrint:Say(nLin,0280,dToC(dDataBase),oFont13n)
	oPrint:Say(nLin,1450,"Hora:",oFont13n)
	oPrint:Say(nLin,1680,Time(),oFont13n)

Return
/*
+------------+-------------+-------+---------------------+------+------------+
! Função     ! VERQUEBRA   ! Autor ! Jair Andrade        ! Data ! 28/10/2020 !
+------------+-------------+-------+---------------------+------+------------+
! Parâmetros !                                                               !
+------------+---------------------------------------------------------------+
! Descrição  ! Verifica se deve quebrar página                               !
+------------+---------------------------------------------------------------+
*/
Static Function VERQUEBRA(cChama)

	If nLin + 50 > 2150
		oPrint:Say(2250,2800,"Página: "+Transform(nPagi,"@E 99"),oFont10n)
		oPrint:Say(2250,0070,DtoC(Date())+"  "+cTime,oFont10n)
		ImpCabec()
		nPagi ++
		If cChama == "I"
			nLin += 35
		EndIf
	Endif

Return
/*
+------------+-------------+-------+---------------------+------+------------+
! Função     ! CorpoM      ! Autor ! Jair Andrade        ! Data ! 28/10/2020 !
+------------+-------------+-------+---------------------+------+------------+
! Parâmetros !                                                               !
+------------+---------------------------------------------------------------+
! Descrição  ! Texto que será criado no corpo do email                       !
+------------+---------------------------------------------------------------+
*/
Static Function CorpoM() 
	Local cCorpo := ""

	cCorpo += '<html> '
	cCorpo += '	<body> '
	cCorpo += '		<div style="text-align: left;"> '
	cCorpo += '			<p> '
	cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Bom dia,</span></span> '
	cCorpo += '			<BR> <BR>'
	cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Em anexo estão os fornecedores que estão com problemas no e-mail.</span></span></p> '
	cCorpo += '			<BR> '
	cCorpo += '				<span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;"><span style="font-size:12px;"><span style="font-family:verdana,geneva,sans-serif;">Quaisquer dúvidas, favor entrar em contato com o responsavel pelo cadastro dos fornecedores.</span></span></p> '
	cCorpo += '			<BR> '
	cCorpo += '			<BR> '
	cCorpo += '				<span style="font-size:16px;"><span style="font-family:verdana,geneva,sans-serif;"><span style="font-size:16px;"><span style="font-family:verdana,geneva,sans-serif;">TCP</span></span></p> '
	cCorpo += '		</div> '
	cCorpo += '	</body>'
	cCorpo += '</html>

Return cCorpo
//-------------------------------------------------------------------------------
/*/{Protheus.doc} MCOM012E
Realiza envio de e-mail

@return 
@author Jair Andrade	
@since 28/10/2020
/*/                                                                    
//-------------------------------------------------------------------------------
Static Function MCOM012E(cTo, cCC, cAssunto, cCorpo, cAnexo, lSleep )
	Local aArea      := GetArea()
	Local aRet       := {}
	local cSmtp      := SuperGetMV("TCP_SERVER", .F., Nil)
	Local cEmail     := SuperGetMV("TCP_EMAIL" , .F., Nil)
	Local cMailSenha := SuperGetMV("TCP_SENHA" , .F., Nil)
	Local cMailUser  := iif( cEmail == Nil, cEmail, substr(cEmail, 1, RAT('@', cEmail) - 1))
	Local lTsl       := SuperGetMV("TCP_TSL"   , .F., Nil)
	Local nPorta     := SuperGetMV("TCP_PORT"  , .F., Nil)
	Local nRet       := 0
	Local nNumMsg    := 0
	Local nX         := 0
	Local oMail      := Nil
	Local oMessage   := Nil
	if (cSmtp == Nil) .OR. (cEmail == Nil) .OR. (cMailSenha == Nil) ;
			.OR. (cMailUser == Nil) .OR. (lTsl == Nil) .OR. (nPorta == Nil)
		aAdd(aRet,{.F.,'Por favor, verifique os parâmetros TCP_SERVER, TCP_EMAIL, TCP_SENHA, TCP_TSL e TCP_PORT.'})
		cArqAux := DtoS(dDataBase)+STRTRAN(TIME(),":","")+".txt"
		MEMOWRITE('/AFS/'+cArqAux,cTo+cassunto+cCorpo)

	else
		oMail := TMailManager():New()
		oMail:SetUseTLS(lTsl)
		oMail:Init('', cSmtp, cMailUser, cMailSenha, 0, nPorta)

		nret := oMail:SmtpConnect()
		If nRet == 0
			nRet := oMail:SmtpAuth(cMailUser, cMailSenha)
			If nRet <> 0
				cArqAux := DtoS(dDataBase)+STRTRAN(TIME(),":","")+".txt"
				MEMOWRITE('/AFS/'+cArqAux,cTo+cassunto+cCorpo)
				aAdd(aRet, {oMail:GetErrorString(nRet)})
			else
				oMessage := TMailMessage():New()
				oMessage:Clear()
				oMessage:cFrom    := cEmail
				oMessage:cTo      := cTo
				oMessage:cCc      := cCC
				oMessage:cSubject := cAssunto
				oMessage:cBody    := cCorpo

				//Adiciona um attach

				If oMessage:AttachFile(cAnexo) < 0
					cArqAux := DtoS(dDataBase)+STRTRAN(TIME(),":","")+".txt"
					MEMOWRITE('/AFS/'+cArqAux,cTo+cassunto+cCorpo)
					Return .F.
				Else
					//adiciona uma tag informando que é um attach e o nome do arq
					oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+cAnexo)
				EndIf

				//Envia o e-mail
				nRet := oMessage:Send(oMail)
				If nRet <> 0
					cArqAux := DtoS(dDataBase)+STRTRAN(TIME(),":","")+".txt"
					MEMOWRITE('/AFS/'+cArqAux,cTo+cassunto+cCorpo)
					Return .F.
					aAdd(aRet, {.F., oMail:GetErrorString(nRet)})
				EndIf
				oMessage := FreeObj(oMessage)

			Endif
		Else
			aAdd(aRet, {"Conexão SMTP: " + oMail:GetErrorString(nRet)})
		Endif

		oMail:SMTPDisconnect()
		oMail := FreeObj(oMail)
	endif
	If lSleep
		Sleep( 15000 )//para evitar travamento de envio de e-mail, envia 1 e-mail a cada 15 segundos
	EndIf
	RestArea(aArea)

return aClone(aRet)
