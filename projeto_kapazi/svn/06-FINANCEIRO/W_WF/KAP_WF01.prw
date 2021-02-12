#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"   

/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Financerio                                                                                                                             |
| Schedule - Aviso de boletos vencidos a mais de 2 dias OU conforme parametro  KP_DAVISO                                                    |
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
user function KAPAVI01()
	U_KAP_WF01("01")
return()                       	

//Chamada do schedule para a empresa ALBATROS
user function KAPAVI02()
	U_KAP_WF01("02")
return()

//Chamada do schedule para a empresa CAPCAP
user function KAPAVI03()
	U_KAP_WF01("03")
return()

//Chamada do schedule para a empresa KAPAZI INDUSTRIA
user function KAPAVI04()
	U_KAP_WF01("04")
return()

//Chamada do schedule para a empresa KAPBRASUUL
user function KAPAVI07()
	U_KAP_WF01("07")
return()

User Function KAP_WF01(cParEmp)
	local aArea 		:= GetArea()
	local cAls			:= GetNextAlias()
	local cQry 			:= "" 
	local aParcela		:= {}
	Local cParFil    	:= "01"

	PREPARE ENVIRONMENT EMPRESA cParEmp FILIAL cParFil  

	IF SELECT('TRB') <> 0
		DbselectArea('TRB')
		dbClosearea()
	endif

	cQry += " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_EMISSAO, E1_VENCREA, E1_VALOR, E1_TIPO, E1_SALDO, R_E_C_N_O_ E1RECNO, E1_CLIENTE, E1_LOJA,
	cQry += " 	    floor(convert(float, GetDate() - convert(datetime, E1_VENCREA))) DIAS_VEN 
	cQry += " FROM " + RetSqlName("SE1") + " SE1"
	cQry += " WHERE E1_FILIAL  >= '  '
	cQry += "    AND E1_TIPO   = 'NF'
	cQry += "    AND E1_SALDO  > 0
	cQry += "    AND E1_BAIXA  = '' 
	cQry += "    AND E1_VALBCO = 'S'  
	cQry += "    AND E1_NUMBOR <> '' 
	cQry += "    AND E1_NUMBCO <> '' 
	cQry += "    AND SE1.D_E_L_E_T_ = ' '
	cQry += "    AND floor(convert(float, GetDate() - convert(datetime, E1_VENCREA)))  = (" + GetMv("KP_DAVISO") + ")	

	dbUsearea(.t.,"TOPCONN", tcGENQRY(,,cQry),'TRB', .F.,.T.)    

	while !TRB->(eof())
		fSendAvs()  
		Sleep(1000)
		TRB->(dbSkip())
	enddo
	
	RestArea(aArea)
return

static function fSendAvs()  
	local oMailSend
	local aArea		:= GetArea()
	local cUsr 		:= GetMV('KP_MBOLUSR', .f., 'kapazi')
	local cPwd 		:= GetMV('KP_MBOLPWD', .f., 'laertes77')
	local nPort		:= GetMV('KP_MBOLPRT', .f., 587)
	local cAddr		:= GetMV('KP_MBOLADD', .f., 'smtplw.com.br')

	local cFrom		:= GetMV('KP_MBOLMFR', .f., 'boleto@kapazi.com.br')
	local cMailTo	:= ""
	local cCC			:= 'boleto@kapazi.com.br' //GetMV('KP_MBOLMCC', .f., '')

	local cSubj		:= GetMV('KP_MBOLMSA', .f., 'Aviso de Vencimento' )
	local cMsg 		:= GetMV('KP_MBOLMMG', .f., 'Caro cliente, segue anexo boleto de cobrança.')

	local aTplVar	:= {}


	cMailTo := Posicione("SA1",1,xFilial("SA1")+ TRB->E1_CLIENTE+TRB->E1_LOJA,"A1_EMAIL")
	cMailTo := StrTran(AllTrim(cMailTo), ";", ",")
	
	cVenc   := Substr(TRB->E1_VENCREA,7,2)+"/"+Substr(TRB->E1_VENCREA,5,2)+"/"+Substr(TRB->E1_VENCREA,1,4) 

	//Andre-Rsac 23.01.2017
	cDiasVEN := GetMv("KP_DAVISO")  
	nValorT  := Transform(TRB->E1_VALOR,"@E 999,999,999.99")
	//fim

	//Inicia o processo do workflow
	oWfProc   := TWfProcess():New( "000002", "RELATORIOS", NIL )
	
	//Layout  
	cWfTaskId := oWfProc:NewTask( "RELATORIOS", "\workflow\Aviso de Vencimento1.html")     
	oWfHtml   := oWfProc:oHtml
	
	//Dispara o processo para o usuario
	oWfProc:ClientName(cUserName)
	oWfHtml:ValByName("NOMECLI"		, Posicione("SA1", 1, xFilial("SA1") + TRB->E1_CLIENTE + TRB->E1_LOJA, "A1_NOME"))
	oWfHtml:ValByName("VENCTO"		, cVenc)
	oWfHtml:ValByName("MAILFROM"	, cFrom)  
	oWfHtml:ValByName("DIASVEN"	, cDiasVEN)  
	oWfHtml:ValByName("VALOR"	, nValorT) 
	oWfHtml:ValByName("NTITUL"	, TRB->E1_NUM)   
	
	//Atualiza variáveis
	oWfProc:cFromAddr := cFrom
	oWfProc:cFromName := cFrom  
	oWfProc:cTo       := cMailTo + "," + cCC	
	oWfProc:cSubject  := cSubj
	oWfProc:bReturn   := Nil
	
	//Inicia o processo
	oWfProc:Start()
	
	//Chama o workflow para enviar os e-mails
	WfSendMail()

	RestArea(aArea)
return .t.
