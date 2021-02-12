#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"  
#Include "AP5MAIL.CH"

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Financerio                                                                                                                             |
| Schedule - Aviso de boletos a vencer                                                                                                   |
| Autor: Andre Roberto Ramos                                                                                                             |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 26.01.2017                                                                                                                       |
| Descricao:                                                                                                                             |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

   
// Schedule ativado -- 14.02.2018 -- Andre/Rsac 
//Chamada do schedule para a empresa KAPAZI
user function KAPALT01()
	U_MFIN01X("01")
return()                       	

//Chamada do schedule para a empresa ALBATROS
user function KAPALT02()
	U_MFIN01X("02")
return()

//Chamada do schedule para a empresa CAPCAP
user function KAPALT03()
	U_MFIN01X("03")
return()

//Chamada do schedule para a empresa KAPAZI INDUSTRIA
user function KAPALT04()
	U_MFIN01X("04")
return()

//Chamada do schedule para a empresa KAPBRASUUL
user function KAPALT07()
	U_MFIN01X("07")
return()


User Function MFIN01X(cParEmp)   	
	local aArea 		:= GetArea()
	local cAls			:= GetNextAlias()	
	local cTpList 		:= "NF" //GetMV("KP_F01XTIP", .f., "NF")
	local cQry 			:= ""
	local cLstData		:= ""//GetMV("KP_DIASVC", .f., "5/10/15")
	local aParcela		:= {}
	local cDtIn 		:= ""
	local lDelPDF		:= "" //GetMV("KP_F200DEL", .f., .f.)	// Deleta PDF
	Local cParFil    	 := "01"

	PREPARE ENVIRONMENT EMPRESA cParEmp FILIAL cParFil    

	lDelPDF		:= GetMV("KP_F200DEL", .f., .f.)
	cLstData 	:= GetMV("KP_DIASVC", .f., "3")

	aEval(StrTokArr2(cLstData, "/", .f.), {|cDia|  cDtIn += DtoS(dDatabase + Val(cDia)) + '/' })
	cDtIn := Left(cDtIn, Len(cDtIn)-1)

	cQry += " SELECT R_E_C_N_O_ E1RECNO
	cQry += " FROM " + RetSqlName("SE1") + " SE1"
	cQry += " WHERE E1_FILIAL   >= '  '
	cQry += "    AND E1_TIPO    IN " + FormatIn(cTpList, '/')
	cQry += "    AND E1_SALDO   > 0
	cQry += "    AND E1_VENCTO  IN " + FormatIn(cDtIn, '/')
	cQry += "    AND E1_NUMBOR  <> ''
	cQry += "    AND E1_PORTADO <> ''  
	cQry += "    AND E1_VALBCO  = 'S'
	cQry += "    AND E1_BAIXA   = ''
	cQry += "    AND SE1.D_E_L_E_T_ = ' ' 
	cQry += " ORDER BY E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_NUM, E1_PARCELA
	TCQuery cQry new alias &cAls

	dbSelectArea("Z0A")
	Z0A->(dbSetOrder(1))
	while !(cAls)->(eof())
		aParcela := {}
		SE1->(dbGoTo((cAls)->E1RECNO))
		if Z0A->(dbSeek(xFilial("Z0A") + Str(SE1->(RecNo()), 12,0) ))
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			if SA1->(dbSeek(xFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA)))
				aParcela := {{SE1->(RecNo()), SA1->(RecNo())}}//, Z0A->(RecNo())
			endif
		endif

		if Len(aParcela) > 0
			cFPath := U_BOLKAPX(aParcela)  //aLTERADO 10.08.2017 -- Andre/rsac  (U_RFIN001X)
			Sleep(1000)
			aFSize	:= {}
			aFile	:= {}
			nArq	:= ADir(cFPath, @aFile, @aFSize)
			
			//ConOut("F200FIM | " + Time() + " | " + cFPath + " | " + cValToChar(IIF(Len(aFSize)>0, aFSize[1], 999999999)) + ' bytes')
			If !Empty(cFPath) .And. nArq > 0 .And. Len(aFSize) > 0 .And. aFSize[1] > 0 
				fSendAvs(cFPath, aParcela)
			endif
			if lDelPDF
				FErase(cFPath)
			endif
		endif 
		(cAls)->(dbSkip())
	enddo

	RestArea(aArea)
return

static function fSendAvs(cFilePath, aTitulos)
	local oMailSend
	local aArea		:= GetArea()
	local cUsr 		:= GetMV('KP_MBOLUSR', .f., 'kapazi')
	local cPwd 		:= GetMV('KP_MBOLPWD', .f., 'laertes77')
	local nPort		:= GetMV('KP_MBOLPRT', .f., 587)
	local cAddr		:= GetMV('KP_MBOLADD', .f., 'smtplw.com.br')

	local cFrom		:= GetMV('KP_MBOLMFR', .f., 'boleto@kapazi.com.br')
	local cMailTo	:= ""
	local cCC			:= 'boleto@kapazi.com.br' 

	local cSubj		:= GetMV('KP_MBOLMSA', .f., 'Lembrete de Vencimento')
	local cMsg 		:= GetMV('KP_MBOLMMG', .f., 'Caro cliente, segue anexo boleto de cobrança.')

	local aTplVar	:= {}

	default cFilePath := ''

	//Posiciona na SA1
	SA1->(dbGoTo(aTitulos[1,2]))
	
	cMailTo := StrTran(AllTrim(SA1->A1_EMAIL), ";", ",")
	
	cVenc := ""
	for nI := 1 to Len(aTitulos)
		SE1->(dbGoTo(aTitulos[nI,1]))
		cVenc += DtoC(SE1->E1_VENCTO) + ', '
	next nI
	cVenc := Left(cVenc, Len(cVenc) - 2)

	//Andre-Rsac 23.01.2017
	cDiasLem := ctod(cVenc) - dDataBase 
	nValorT := Transform(SE1->E1_VALOR,"@E 999,999,999.99")
	//fim

	//Inicia o processo do workflow
	oWfProc   := TWfProcess():New( "000002", "RELATORIOS", NIL )
	
	//Layout  
	cWfTaskId := oWfProc:NewTask( "RELATORIOS",  "\workflow\Lembrete de Vencimento.html")     
	oWfHtml   := oWfProc:oHtml
	
	//Atualiza variáveis
	oWfProc:ClientName(cUserName)
	oWfHtml:ValByName("NOMECLI"		, SA1->A1_NOME)
	oWfHtml:ValByName("VENCTO"		, cVenc)
	oWfHtml:ValByName("MAILFROM"	, cFrom)  
	oWfHtml:ValByName("DIASLEM"	, cDiasLem)  
	oWfHtml:ValByName("VALOR"	, nValorT) 
	oWfHtml:ValByName("NTITUL"	, SE1->E1_NUM)   

	//Define as propriedades de envio do e-mail
	oWfProc:cFromAddr := cFrom
	oWfProc:cFromName := cFrom
	oWfProc:cTo       := cMailTo + "," + cCC
	 
	oWfProc:cSubject  := cSubj
	oWfProc:AttachFile(cFilePath)
	oWfProc:bReturn   := Nil
	
	//Inicia o processo
	oWfProc:Start()
	
	//Chama o workflow para enviar os e-mails
	WfSendMail()

	RestArea(aArea)
return .t.
