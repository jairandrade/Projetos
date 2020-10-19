#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "TBICONN.CH"


/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
! Versão           ! Protheus 11                                             !
+------------------+---------------------------------------------------------+
! Tipo             ! WKF                                                     !
+------------------+---------------------------------------------------------+
! Modulo           ! PCO                                                     !
+------------------+---------------------------------------------------------+
! Nome             ! WFPCO001                                                !
+------------------+---------------------------------------------------------+
! Descricao        ! Disparo de e-mails para aprovação de contingencia.      !
+------------------+---------------------------------------------------------+
! Autor            ! HUGO                                                    !
+------------------+---------------------------------------------------------+
! Data de Criacao  ! 17/03/2015                                              !
+------------------+---------------------------------------------------------+

*/

// Preencher no schedule U_WFPCO001("02","01",,) e compilar e configurar.
User Function WFPCO001(cEmpTCP, cFilTCP, cCodCont, cAprRep, cUsrAp, cJust)
//u_WFPCO001("02","01", "05409",,, "TESTE")
//Verifica se o parametro de envio de e-mail esta como True
Local lEnvMail	:= ''
Local cLog 		:= ''

cLog += "WFPCO001" + CHR(13)+CHR(10)
MemoWrite( "\temp\WFPRO001_LOG.txt", cLog )


If Type('cEmpTCP')=='U'
	Default cEmpTCP := ''
Endif

If Type('cFilTCP')=='U'
	Default cFilTCP := ''
Endif

If Type('cCodCont')=='U'
	Default cCodCont := ''
Endif

If Type('cAprRep')=='U'
	Default cAprRep := ''
Endif

cLog := 'Inicio do WFPCO001 ' + CHR(13)+CHR(10)
MemoWrite( "\temp\WFPRO001_LOG.txt", cLog )

If Empty(Alltrim(cEmpTCP))
	cEmpTCP := '02'
Endif
If Empty(Alltrim(cFilTCP))
	cFilTCP := '01'
Endif


Reset Environment   
RPCSetType(3) 
RpcsetEnv(cEmpTCP,cFilTCP,,,"PCO","U_WFPCO001",{"CND", "CNE", "CNA", "CNB", "CN1", "SF2", "SD2", "SE1", "SE2", "SF3"})

cLog += "WFPCO001 - Rotina de envio de e-mail de contingencia PCO" + CHR(13)+CHR(10)
MemoWrite( "\temp\WFPRO001_LOG.txt", cLog )
cLog += "WFPCO001 - " + cEmpTCP + " - " + cFilTCP + " - " + cCodCont + " - " + cAprRep + CHR(13)+CHR(10)
MemoWrite( "\temp\WFPRO001_LOG.txt", cLog )

lEnvMail := SuperGetMV('MV_XMAILAP', .F., .T.)

If !lEnvMail
	Return
EndIf

//Busca as contingencias as quais deve enviar e-mail
// Se a variavel cCodCont estiver preenchida, é e-mail de retorno aprovação/reprovação
BuscaCont(cFilTCP, cCodCont)

While !QAA->(EOF())


	If Empty(cCodCont)
	
		IF PswSeek(QAA->ALI_USER,.t.)
			aInfo := PswRet(1)

			If !Empty(ainfo[1,14])

				cLog += "EnvWFPCO" + CHR(13)+CHR(10)
				MemoWrite( "\temp\WFPRO001_LOG.txt", cLog )

				EnvWFPCO(alltrim(aInfo[1,14]), QAA->ALI_USER, '', '')

			Endif
		EndIF

		DbSelectArea('ALI')
		ALI->(DbSetOrder(1))
		If ALI->(DbSeek(QAA->ALI_FILIAL + QAA->ALI_CDCNTG + QAA->ALI_USER)) .AND. Empty(AllTrim(cCodCont))
			BEGIN TRANSACTION

				RecLock('ALI', .F.)
				ALI->ALI_XPROWF := 'E'
				ALI->(MsUnlock())

			END TRANSACTION
		EndIf
	
	Else

		//Envia e-mail para o solicitante, informando do status.
		IF !Empty(AllTrim(QAA->ALI_SOLIC)) .and. AllTrim(QAA->ALI_USER) == AllTrim(cUsrAp)
			PswOrder(1)
			If PswSeek(QAA->ALI_SOLIC,.t.)
				aInfo := PswRet(1)

				If !Empty(ainfo[1,14])
					EnvWFPCO(alltrim(aInfo[1,14]), QAA->ALI_USER, cAprRep, cJust)
				EndIf
			EndIf
		EndIf

	Endif

	QAA->(DbSkip())
EndDo

Return

/*---------------------------------------------------------------------------+
!   DADOS DA FUNÇÃO                                                          !
+------------------+---------------------------------------------------------+
!Nome              ! BuscaDados                                              !
+------------------+---------------------------------------------------------+
!Descricao         ! Query de busca as contingencias bloqueadas.             !
+------------------+---------------------------------------------------------+
!Autor      	   ! HUGO                                                    !
+------------------+---------------------------------------------------------+
!Data Criação      ! 27/02/2015                                              !
+------------------+--------------------------------------------------------*/

Static Function BuscaCont(cFilAli, cCodCont)

Local nTot 		:= 0

//Busca contingencias

//cQuery := "           SELECT * FROM " + RetSqlName('ALI') + " ALI "
cQuery := "           SELECT  ALI.*,
cQuery += "           ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ALI.ALI_MEMO)),'') AS ALI_MEMO
cQuery += "           FROM " + RetSqlName('ALI') + " ALI "
cQuery += "           WHERE "
cQuery += "           ALI.ALI_FILIAL = '" + cFilAli + "' "

//Nos e-mails de retorno deve ser passado o código da contingencia
If !Empty(AllTrim(cCodCont))
	cQuery += "           AND ALI.ALI_XPROWF = 'E' "
	cQuery += "           AND ALI.ALI_DTLIB <> '' "
	cQuery += "           AND ALI.ALI_CDCNTG = '" + cCodCont + "' "
Else
	cQuery += "           AND ALI.ALI_XPROWF = 'A' "
EndIf
cQuery += "           AND ALI.D_E_L_E_T_ = '' "


MemoWrite( "\temp\WFPRO001.txt", cQuery )


//Verifica se a area já existe e fecha para ser recriada.
If (Select("QAA")) <> 0
	dbselectarea("QAA")
	QAA->(dbclosearea())
EndIf

TcQuery	cQuery New Alias 'QAA'

//Pega a quantidade de linhas
DbSelectArea('QAA')
Count to nTot
QAA->(DbGoTop())


//Alert(nTot)

Return


/*---------------------------------------------------------------------------+
!   DADOS DA FUNÇÃO                                                          !
+------------------+---------------------------------------------------------+
!Nome              ! EnvWFPCO                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Envia WorkFlow PCO.                                     !
+------------------+---------------------------------------------------------+
!Autor      	   ! HUGO                                                    !
+------------------+---------------------------------------------------------+
!Data Criação      ! 27/02/2015                                              !
+------------------+--------------------------------------------------------*/

Static Function EnvWFPCO(cMailTo, cAprv, cAprRep, cJust)

// Localiza o(s) aprovador(es) do nível 1
Local nValIPI 	:= 0
Local nTotAux 	:= 0

Local cAssAux	:= "Solicitação de aprovação de contingencia: " + QAA->ALI_CDCNTG

Local cTitulo	:= "Solicitação de aprovação de contingencia"

Local cHtmlCon	:= ""

Local cLinkMsg 	:= ""
Local lStyle := .T.

Local oProc

If cAprRep = 'A'
	cAssAux	:= "Retorno, contingencia Aprovada -  " + QAA->ALI_CDCNTG
	cTitulo := "Retorno, contingencia Aprovada -  " + QAA->ALI_CDCNTG
ElseIf cAprRep = 'R'
	cAssAux	:= "Retorno, contingencia Reprovada -  " + QAA->ALI_CDCNTG
	cTitulo := "Retorno, contingencia Reprovada -  " + QAA->ALI_CDCNTG
EndIf

oProc := TWFProcess():New("PCO","PCO")


oProc:NewTask("PCO2", "\WORKFLOW\HTML\APROV_PCO.HTM")
oProc:cSubject := cAssAux

//VarInfo('oProc',oProc:oHtml)

//Preenchimento do titulo da pagina
oProc:oHtml:ValByName("cTitulo"	, cTitulo)

//Preenchimento dos titulos e valor dos campos de cabeçalho
oProc:oHtml:ValByName("ALI_CDCNTG"	, TitCpo("ALI_CDCNTG")	+ ": </b>" + QAA->ALI_CDCNTG)
oProc:oHtml:ValByName("ALI_SOLIC"	, TitCpo("ALI_SOLIC")	+ ": </b>" + QAA->ALI_SOLIC +" - "+ UsrFullName(QAA->ALI_SOLIC))
oProc:oHtml:ValByName("ALI_USER"	, TitCpo("ALI_USER") 	+ ": </b>" + QAA->ALI_USER +" - "+ UsrFullName(QAA->ALI_USER))
oProc:oHtml:ValByName("ALI_DTSOLI"	, TitCpo("ALI_DTSOLI") 	+ ": </b>" + QAA->ALI_DTSOLI)
oProc:oHtml:ValByName("ALI_DTVALI"	, TitCpo("ALI_DTVALI") 	+ ": </b>" + QAA->ALI_DTVALI)
oProc:oHtml:ValByName("ALI_CODBLQ"	, TitCpo("ALI_CODBLQ") 	+ ": </b>" + QAA->ALI_CODBLQ)
oProc:oHtml:ValByName("ALI_STATUS"	, TitCpo("ALI_STATUS") 	+ ": </b>" + QAA->ALI_STATUS)
oProc:oHtml:ValByName("ALI_MEMO"	, TitCpo("ALI_MEMO") 	+ ": </b>" + QAA->ALI_MEMO)
oProc:oHtml:ValByName("ALI_PROCESS"	, TitCpo("ALI_PROCESS") + ": </b>" + QAA->ALI_PROCESS)
oProc:oHtml:ValByName("ALI_LOTEID"	, TitCpo("ALI_LOTEID") 	+ ": </b>" + QAA->ALI_LOTEID)
oProc:oHtml:ValByName("ALI_HORA"	, TitCpo("ALI_HORA") 	+ ": </b>" + QAA->ALI_HORA)
oProc:oHtml:ValByName("ALI_NIVEL"	, TitCpo("ALI_NIVEL") 	+ ": </b>" + QAA->ALI_NIVEL)

IF !Empty(cAprRep) .And. GETMV("MV_PCOCTGP",.F.,.F.)
	ALJ->( dbSetOrder(1) )
	ALJ->( dbSeek( xFilial("ALJ") + QAA->ALI_CDCNTG ) )
	oProc:oHtml:ValByName("cSenhaCont", "Senha: " + PcoCtngKey())
Else
	oProc:oHtml:ValByName("cSenhaCont", "")
EndIF

oProc:oHtml:ValByName("cOutros", "Obs.: " + cJust) 

oProc:oHtml:ValByName("ALJ_ID"		, TitCpo("ALJ_ID"))
oProc:oHtml:ValByName("ALJ_DATA"	, TitCpo("ALJ_DATA"))
oProc:oHtml:ValByName("ALJ_CO"		, TitCpo("ALJ_CO"))
oProc:oHtml:ValByName("AK5_DESCRI"	, "Descrição C.O.")
oProc:oHtml:ValByName("ALJ_HIST"	, TitCpo("ALJ_HIST"))
oProc:oHtml:ValByName("ALJ_VALOR1"	, "Valor Contingência")
oProc:oHtml:ValByName("ALJ_CC"		, TitCpo("ALJ_CC"))

//Cria a tabela de itens
oProc:oHtml:ValByName("HtmItens"		, CriaItens(QAA->ALI_CDCNTG))

//Cria a tabela com os links
cLink := embaralha(QAA->ALI_FILIAL + ';' + QAA->ALI_CDCNTG + ';' + cAprv + ';' + cEmpAnt,0)

If Empty(AllTrim(cAprRep))
	oProc:oHtml:ValByName("HtmlLinks"		, CriaLinks(cLink))
Else
	oProc:oHtml:ValByName("HtmlLinks"		, '')
EndIf


aIten := {}
nTotal := 0

oProc:cTo :=  Alltrim(cMailTo)
oProc:Start() // modo normal

return

/*---------------------------------------------------------------------------+
!   DADOS DA FUNÇÃO                                                          !
+------------------+---------------------------------------------------------+
!Nome              ! TitCpo                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Retorna o titulo do campo.                              !
+------------------+---------------------------------------------------------+
!Autor      	   ! HUGO                                                    !
+------------------+---------------------------------------------------------+
!Data Criação      ! 27/02/2015                                              !
+------------------+--------------------------------------------------------*/
Static Function TitCpo(cCpo)

Local cTitulo

dbSelectArea("SX3")
dbSetOrder(2)

If DbSeek( cCpo)
	cTitulo := X3Titulo()
EndIf

Return cTitulo


/*---------------------------------------------------------------------------+
!   DADOS DA FUNÇÃO                                                          !
+------------------+---------------------------------------------------------+
!Nome              ! CriaItens                                               !
+------------------+---------------------------------------------------------+
!Descricao         ! Retorna o html da tabela dos itens.                     !
+------------------+---------------------------------------------------------+
!Autor      	   ! HUGO                                                    !
+------------------+---------------------------------------------------------+
!Data Criação      ! 27/02/2015                                              !
+------------------+--------------------------------------------------------*/

Static Function CriaItens(cCod)

Local cHtm 		:= ''
Local cAd 		:= '"'//aspas dupla
Local cAs 		:= "'"//aspas simples
Local cChave	:= xFilial("ALJ") + cCod


//Posiciona nos itens da contingencia
DbSelectArea("ALJ")
ALJ->(DbSetOrder(1))
If ALJ->(DbSeek(cChave))

	While cChave = ALJ->ALJ_FILIAL + ALJ->ALJ_CDCNTG

		AK5->( dbSetOrder(1) )
		AK5->( dbSeek( xFilial("AK5") + ALJ->ALJ_CO ) )

		AKD->( dbSetOrder(1) )
		AKD->( dbSeek( xFilial("AKD") + ALJ->ALJ_LOTEID ) )

		cHtm += " <tr> "
		cHtm += "     <td align="+cAd+"center"+cAd+"><font size="+cAd+"2"+cAd+" face="+cAd+"Arial"+cAd+">"+ ALJ->ALJ_ITEM +"</font></td> "
		cHtm += "     <td align="+cAd+"center"+cAd+"><font size="+cAd+"2"+cAd+" face="+cAd+"Arial"+cAd+">"+ DtoC(ALJ->ALJ_DATA) +"</font></td> "
		cHtm += "     <td align="+cAd+"center"+cAd+"><font size="+cAd+"2"+cAd+" face="+cAd+"Arial"+cAd+">"+ ALJ->ALJ_CO +"</font></td> "
		cHtm += "     <td align="+cAd+"center"+cAd+"><font size="+cAd+"2"+cAd+" face="+cAd+"Arial"+cAd+">"+ AK5->AK5_DESCRI +"</font></td> "
		cHtm += "     <td align="+cAd+"center"+cAd+"><font size="+cAd+"2"+cAd+" face="+cAd+"Arial"+cAd+">"+ ALJ->ALJ_HIST +"</font></td> "
		cHtm += "     <td align="+cAd+"right"+cAd+"><font size="+cAd+"2"+cAd+" face="+cAd+"Arial"+cAd+">"+ TRANSFORM(ALJ->ALJ_VALOR1, "@E 999,999,999.99") +"</font></td> "
		cHtm += "     <td align="+cAd+"center"+cAd+"><font size="+cAd+"2"+cAd+" face="+cAd+"Arial"+cAd+">"+ ALJ->ALJ_CC +"</font></td> "
		cHtm += " </tr> "

		ALJ->(DbSkip())
	EndDo
EndIf
Return cHtm

/*---------------------------------------------------------------------------+
!   DADOS DA FUNÇÃO                                                          !
+------------------+---------------------------------------------------------+
!Nome              ! CriaLinks                                               !
+------------------+---------------------------------------------------------+
!Descricao         ! Retorna o html da tabela dos links.                     !
+------------------+---------------------------------------------------------+
!Autor      	   ! HUGO                                                    !
+------------------+---------------------------------------------------------+
!Data Criação      ! 27/02/2015                                              !
+------------------+--------------------------------------------------------*/

Static Function CriaLinks(cLink)

Local cHtm 		:= ''
Local cAd 		:= '"'//aspas dupla

Local cEndSrv	:= supergetMv("MV_XEWFPCO",,"")
Local cPortaSrv	:= AllTrim(supergetMv("MV_XPWFPCO",,"9102"))

Local cLinkOk	:= "http://" + cEndSrv + ":" + cPortaSrv + "/pp/U_WFPCOAPR.apw?keyvalue=" + cLink
Local cLinkCn	:= "http://" + cEndSrv + ":" + cPortaSrv + "/pp/U_WFPCOREJ.apw?keyvalue=" + cLink

//oProc:oHtml:ValByName("cLinkOk","http://" + cEndSrv + ":" + cPortaSrv + "/pp/U_WFPCOAPR.apw?keyvalue=" + cLink) // confirma
//oProc:oHtml:ValByName("cLinkCn","http://" + cEndSrv + ":" + cPortaSrv + "/pp/U_WFPCOREJ.apw?keyvalue=" + cLink) // cancela


cHtm += " <table width="+cAd+"50%"+cAd+" border="+cAd+"0"+cAd+" cellspacing="+cAd+"0"+cAd+" cellpadding="+cAd+"0"+cAd+"> "
cHtm += " 	<tr> "
cHtm += " 		<td align="+cAd+"center"+cAd+" bgcolor="+cAd+"#00CC00"+cAd+"><a href="+cAd+ cLinkOk +cAd+">APROVAR</a></td> "
cHtm += " 		<td align="+cAd+"center"+cAd+"><p>&nbsp;</p> "
cHtm += " 		<p>&nbsp;</p></td> "
cHtm += " 		<td align="+cAd+"center"+cAd+" bgcolor="+cAd+"#FF0000"+cAd+"><p><a href="+cAd + cLinkCn + cAd+">REJEITAR</a></p></td> "
cHtm += " 	</tr> "
cHtm += " </table> "

Return cHtm

