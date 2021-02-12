/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** Pedido de Venda                                                                                                              **/
/** Envio de email para representante e cliente                                                                                  **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                       **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 15/02/2015| Marcos Sulivan          | Criação da rotina/procedimento.                                                        **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#include "topconn.ch"
#include "ap5mail.ch"
#include "tbiconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH" 


#Define ENTER chr(13)+chr(10)

/**********************************************************************************************************************************/
/** user function KPFINR02()                 cStatus, "cPedido, cCli, cLj)                                                       **/
/**********************************************************************************************************************************/
user function KPFINR02() 
	Private cPerg		:= "KPFINR01"

	If !Pergunte(cPerg, .T.)
		Return
	Endif

	Processa({|| IniProc() },"Processando...","Aguarde...")

Return

Static Function IniProc()
	Local 	aArea  	 	:= GetArea()  
	Local 	cMailVend 	:= ""
	Local 	cNomeFrom 	:= ""
//	Local 	cMailDest 	:= ""	
//	Local 	cAssunto	:= ""
//	Local 	cRepr		:= ""
	Local 	cMailRep	:= ""
//	Local 	nItem	  	:= 0
//	Local 	nQtd	   	:= 0
	Local 	nTotal  	:= 0  
	Local 	nGeral		:= 0 
	Local 	nJuros		:= 0
	Local 	cCodVend	:= ""
	Local 	cCodCli		:= ""
	Local	cCodLoja	:= ""
	local 	cObser		:= ""
	Local 	cNomec		:= ""
	Local	nN			:= 0 
	Local 	nCons		:= 0
	Local 	nCn			:= 0  
	Local 	cEmail		:= ""
//	Local	cPicCgc		:= "@R 99.999.999/9999-99"
//	Local	cCliente	:= ""
	Local	cCli		:= ""
//	Local	cHtml		:= ""
	Local	nCount		:= 0
	Private cCliIni		:= mv_par01
	Private	cLojIni		:= mv_par02
	Private cCliFim		:= mv_par03
	Private cLojFim		:= mv_par04
	Private cFilIni		:= mv_par05
	Private cFilFim		:= mv_par06
	Private	dDtIni		:= mv_par07
	Private	dDtFim		:= mv_par08
	Private cMailDes	:= mv_par09
	Private cVendIni	:= mv_par10
	Private cVendFim	:= mv_par11
	Private cMailCop	:= mv_par12
	
	ProcRegua(nCount)
	IncProc()
	IncProc()
	
	
	//INICIA EXECUCAO DA CONSULTA 
	CDEB("VEND")
	VEND->( DbGoTop() )
	Count to nCount
	
	ProcRegua(nCount)
	
	VEND->( DbGoTop() )
	While !VEND->( EOF() )
		//INICIALIZA CONSULTA
		CDEB("CLI",VEND->A3_COD)
		
		//CORRIGIDO, ESTAVA ENVIANDO PARA REPRESENTANTE ERRADO.
		cEmail 	:= CLI->EMAIL_VEND
		cNomeV	:= AllTrim(VEND->NOME_VEND)
		cCli	:= ""
		
		IncProc(cNomeV)
		
		CLI->( DbGoTop() )
		//Faz loop sobre a query
		While !CLI->( Eof() )
	
			cCli += '	<table class="Table_1" border="1" width=800>'
			cCli += '		<tr>
			cCli += '			<td class="Table_2" align=center height=40 bgcolor="gray"><b>Dados Cliente</b></td>'
			cCli += '		</tr>'
			cCli += '		<tr>'
			cCli += '			<td>'
			cCli += '				<table width=800 class="Table_2">'
			cCli += '					<tr>'
			cCli += '						<td><span class="style26">Cliente/Loja:</span> <span class="style24">'+TRANSFORM(CLI->CLIENTE +CLI->LOJA  ,"@R 999999-99")+' - '+ALLTRIM(CLI->NOME)+'</span></td>'
			cCli += '					</tr>'
			cCli += '					<tr>'
			cCli += '						<td><span class="style26">Nome fantasia:</span> <span class="style24">'+ALLTRIM(CLI->RAZAO)+'</span></td>'
			cCli += '					</tr>'
			cCli += '					<tr>'
			cCli += '						<td><span class="style26">Telefone:</span> <span class="style24">'+TRANSFORM(CLI->TELEFONE,"@R 99999-99999")+'</span></td>'
			cCli += '					</tr>'
			cCli += '					<tr>'
			cCli += '						<td><span class="style26">E-mail:</span> <span class="style24">'+ALLTRIM(CLI->EMAIL)+'</span></td>'
			cCli += '					</tr>'
			cCli += '					<tr>'
			cCli += '						<td colspan=4 align=center height=9></td>'
			cCli += '					</tr>'
			cCli += '				</table>'
			cCli += '				<table width=800 class="Table_2">'
			cCli += '					<tr>'
			cCli += '						<td style="width: 150px;" class="Table_1"><span class="style25">&nbsp;Titulo</span></td>'
			cCli += '						<td style="width: 160px;" class="Table_1"><span class="style25">&nbsp;Parcela</span></td>'
			cCli += '						<td style="width: 160px;" class="Table_1"><span class="style25">&nbsp;Valor Titulo</span></td>'
			cCli += '						<td style="width: 160px;" class="Table_1"><span class="style25">&nbsp;Saldo Debito</span></td>'
			cCli += '						<td style="width: 150px;" class="Table_1"><span class="style25">&nbsp;Vencimento</span></td>'
			cCli += '						<td style="width: 160px;" class="Table_1"><span class="style25">&nbsp;Dias Vencido<br></span></td>'
			cCli += '					</tr>'
			
			cCodVend 	:= CLI->COD_VEND
			cCodCli 	:= CLI->CLIENTE 
			cCodLoja	:= CLI->LOJA
			cNomec		:= CLI->NOME
	
			nTotal  	:= 0 
			nJuros		:= 0
			nGeral		:= 0
			nCons  		:= 0
			cObser		:= ''
	
			While cCodVend = CLI->COD_VEND .AND. cCodCli = CLI->CLIENTE .AND. cCodLoja = CLI->LOJA	
				If ALLTRIM(CLI->PREFIXO) <> '10'
					nCn = 1 
					cCli += '			<tr>'
					cCli += '				<td style="text-align: center;" class="Table_1"><span class="style11">'+ALLTRIM(CLI->TITULO)+'</span></td>'
					cCli += '				<td style="text-align: center;" class="Table_1"><span class="style11">'+ALLTRIM(CLI->PARCELA)+'</span></td>'
					cCli += '				<td style="text-align: right;" class="Table_1"><span class="style11">'+TRANSFORM(CLI->VALOR,"@E 999,999,999.99")+'</span></td>'
					cCli += '				<td style="text-align: right;" class="Table_1"><span class="style11">'+TRANSFORM(CLI->SALDO,"@E 999,999,999.99")+'</span></td>'
					cCli += '				<td style="text-align: center;" class="Table_1"><span class="style11">'+DTOC(STOD(CLI->VENCREAL))+'</span></td>'
					cCli += '				<td style="text-align: right;" class="Table_1"><span class="style11">'+TRANSFORM(CLI->DIAS_VENC,"@R 99999999")+'</span></td>'
					cCli += '			</tr>'
				ElseIf Alltrim(CLI->PREFIXO) = '10'
	
					nCons := nCons + CLI->SALDO 
	
					If nCn <> 1
						cCli += '				<tr>'
						cCli += '					<td style="text-align: center;" class="Table_1"><span class="style11">&nbsp;</span></td>'
						cCli += '					<td style="text-align: center;" class="Table_1"><span class="style11">&nbsp;</span></td>'
						cCli += '					<td style="text-align: right;" class="Table_1"><span class="style11">&nbsp;</span></td>'
						cCli += '					<td style="text-align: right;" class="Table_1"><span class="style11">&nbsp;</span></td>'
						cCli += '					<td style="text-align: center;" class="Table_1"><span class="style11">&nbsp;</span></td>'
						cCli += '					<td style="text-align: right;" class="Table_1"><span class="style11">&nbsp;</span></td>'
						cCli += '				</tr>'
					EndIf
	
				EndIf
	
				If ALLTRIM(CLI->PREFIXO) <> '10'
					nTotal  	:= CLI->SALDO + nTotal  
					nJuros		:= CLI->JUROS + nJuros  
				EndIf
				//Próximo Registro
				CLI->( DbSkip() )				
			EndDo
			
			cCli += '				<tr>'
			cCli += '					<td colspam=6 height="5"></td>'
			cCli += '				</tr>'
			cCli += '			</table>'
			cCli += '			<table width=800 class="Table_1">'
			cCli += '				<tr>'
			cCli += '					<td><span class="style25">Valor Total:</span> <span class="style27">'+TRANSFORM(nTotal	,"@E 999,999,999.99")+'</span></td>'
			cCli += '					<td><span class="style25">Consignado:</span> <span class="style27">'+TRANSFORM(nCons	,"@E 999,999,999.99")+'</span></td>'
			cCli += '				</tr>'
			cCli += '				<tr>'
			cCli += '					<td><span class="style25">Total Juros:</span> <span class="style27">'+TRANSFORM(nJuros	,"@E 999,999,999.99")+'</span></td>'
			cCli += '					<td><span class="style25">Total Geral:</span> <span class="style27">'+TRANSFORM((nTotal + nJuros + nCons),"@E 999,999,999.99")+'</span></td>'
			cCli += '				</tr>'
			cCli += '			</table>'
			cCli += '			<br>'
			cCli += '		</td>'
			cCli += '	</tr>'
			cCli += '	<tr>'
			cCli += '		<td class="Table_2" height="5"></td>'
			cCli += '	</tr>'
			cCli += '</table>'
			cCli += '<br>'
			
		EndDo
		/*
		cHtml := Cabec()
		cHtml += cCli
		cHtml += Rodap()
		
		Memowrite("c:\temp\relatorio.html",cHtml)
		*/
		//cMailRep
		cMailRep 	:= 'relatorios@kapazi.com.br'
		//Recebe o email do remetente
		cMailVend 	:= "relatorios@kapazi.com.br"

		//Email do remetente
		cNomeFrom 	:= " Relatório Vencidos  "

		//Inicia o processo do workflow
//		oWfProc   	:= TWfProcess():New( "000002", "RELATORIOKAPAZI", NIL )

		//Layout  
//		cWfTaskId 	:= oWfProc:NewTask( "RELATORIOKAPAZI", "\workflow\generic2.html" )
		// seta as variáveis do processo
//		oWfHtml   	:= oWfProc:oHtml 
//		oWfHtml:ValByName("CABECALHO"	, Cabec()	)     
//		oWfHtml:ValByName("CORPO"		, cCli		)     
//		oWfHtml:ValByName("RODAPE"		, Rodap()	)     

		//Dispara o processo para o usuario
//		oWfProc:ClientName(cUserName)

//		oWfHtml   	:= oWfProc:oHtml
		
		//Define as propriedades de envio do e-mail
//		If ALLTRIM(cMailDes) <> ''
//			oWfProc:cTo := ALLTRIM(cMailDes	)
//		Else
//			oWfProc:cTo := ALLTRIM(cEmail	)	 
//		EndIf
	
		If ALLTRIM(cMailDes) <> ''
			xTo := ALLTRIM(cMailDes	)
		Else
			xTo := ALLTRIM(cEmail	)	 
		EndIf
	
		xSbj := "Relatório Vencidos - Representante: "+ALLTRIM(cNomeV)+" " + DTOC(dDtIni) + " - " + DTOC(dDtFim)
		
		xCorpo := Cabec()
		xCorpo += cCli
		xCorpo += Rodap()
		
//		oWfProc:cFromAddr := "pv@e-kapazi.com.br"
//		oWfProc:cRetFrom  := "cobranca@kapazi.com.br"
//		oWfProc:cFromName := cNomeFrom  
//		oWfProc:cCC       := ALLTRIM(cMailCop)
//		oWfProc:cSubject  := "Relatório Vencidos - Representante: "+ALLTRIM(cNomeV)+" " + DTOC(dDtIni) + " - " + DTOC(dDtFim) 
//		oWfProc:bReturn   := Nil  
		nN := nN + 1                 
//		oWfProc:Start()
		
		//u_tEnvMail("pv@e-kapazi.com.br", xTo, xSbj, xCorpo, Nil,"cobranca@kapazi.com.br",cMailCop)
		u_tEnvMail("pv@kapazi.com.br", xTo, xSbj, xCorpo, Nil,"cobranca@kapazi.com.br",cMailCop)
		
		VEND->( DbSkip() )
	Enddo	
	
	
	//Chama o workflow para enviar os e-mails
	WfSendMail() 
	cMailRep := ""
	
	//Fecha Query
	If Select("CLI") > 0
		CLI->(DbCloseArea())
	Endif
	
	If Select("VEND") >0
		VEND->(DbCloseArea())
	Endif 

	RestArea(aArea)

Return NIL 

/**********************************************************************************************************************************/
/** user function UPDDTV()                                                                                                      **/
/** CONSULTA DADOS DE COBRANÇA           														**/
/**********************************************************************************************************************************/  

Static Function CDEB(cTemp,cFor)  
	Local 	cQuery  := ""  
	
	Default cFor	:= ""

	cQuery := "SELECT "+ENTER
	If Empty( AllTrim( cFor ) )
		cQuery += " DISTINCT A3_COD "+ENTER
		cQuery += "	,SA3.A3_NOME NOME_VEND "+ENTER
	Else
		cQuery += "	 SE1.E1_CLIENTE CLIENTE "+ENTER
		cQuery += "	,SE1.E1_LOJA LOJA "+ENTER
		cQuery += "	,SA1.A1_NOME NOME "+ENTER
		cQuery += "	,SA1.A1_NREDUZ RAZAO "+ENTER
		cQuery += "	,SE1.E1_NUM TITULO "+ENTER
		cQuery += "	,SE1.E1_PARCELA PARCELA "+ENTER
		cQuery += "	,SE1.E1_VENCREA VENCREAL "+ENTER
		cQuery += "	,SE1.E1_VALOR VALOR "+ENTER
		cQuery += "	,SE1.E1_SALDO SALDO "+ENTER
		cQuery += "	,SE1.E1_PORCJUR JURDIA "+ENTER
		cQuery += "	,(CONVERT(INT,CONVERT(DATETIME,GETDATE())) - CONVERT(INT,CONVERT(DATETIME,SE1.E1_VENCREA))-1)  DIAS_VENC "+ENTER
		cQuery += "	,((CONVERT(INT,CONVERT(DATETIME,GETDATE())) - CONVERT(INT,CONVERT(DATETIME,SE1.E1_VENCREA))-1) * (SE1.E1_PORCJUR/100)) * ( SE1.E1_VALOR) JUROS "+ENTER
		//cQuery += "	,SE1.E1_XINFO COBRANCA "+ENTER
		cQuery += "	,ISNULL(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),E1_XINFOKA)),'') AS COBRANCA  "+ENTER
		cQuery += "	,SA3.A3_COD COD_VEND "+ENTER
		cQuery += "	,SA3.A3_NOME NOME_VEND "+ENTER
		cQuery += "	,SA3.A3_EMAIL EMAIL_VEND "+ENTER
		cQuery += "	,SA3.A3_ENVEMAI ENVEMAIL "+ENTER
		cQuery += "	,SA1.A1_EMAIL EMAIL "+ENTER
		cQuery += "	,SA1.A1_CGC CNPJ  "+ENTER
		cQuery += "	,SA1.A1_TEL TELEFONE  "+ENTER
		cQuery += "	,SE1.E1_PREFIXO PREFIXO  "+ENTER
		cQuery += "	,SE1.E1_TIPO TIPO "+ENTER
		
		
		cQuery += "	,ISNULL(( "+ENTER
		cQuery += "			SELECT TOP 1 ACF.ACF_CODOBS FROM "+RetSqlName("ACG")+" ACG " +ENTER
		
		cQuery += "				JOIN 	"+RetSqlName("ACF")+" ACF "+ENTER
		cQuery += "					ON	ACF.ACF_CODIGO = ACG.ACG_CODIGO " +ENTER
		cQuery += "					AND ACG.D_E_L_E_T_ = '' "+ENTER
		
		cQuery += "				WHERE SE1.E1_NUM = ACG.ACG_TITULO  "+ENTER
		cQuery += "					AND SE1.E1_PARCELA = ACG.ACG_PARCEL "+ENTER
		cQuery += "					AND ACG.D_E_L_E_T_ = '' "+ENTER
		cQuery += "				ORDER BY ACG.ACG_CODIGO DESC "+ENTER
		cQuery += "			),'-') CODIGO "+ENTER
		
		cQuery += "	,* "+ENTER
	Endif
	
	cQuery += "FROM	"+RetSqlName("SE1")+" SE1 "+ENTER
	
	cQuery += "	JOIN "+RetSqlName("SA1")+" SA1 "+ENTER
	cQuery += "		ON	SA1.A1_COD = SE1.E1_CLIENTE "+ENTER
	cQuery += "		AND SA1.A1_LOJA = SE1.E1_LOJA "+ENTER
	cQuery += "		AND SE1.E1_FILIAL BETWEEN '"+cFilIni + "' AND '" + cFilFim + "' "+ENTER
	cQuery += "		AND SA1.A1_FILIAL BETWEEN '"+cFilIni + "' AND '" + cFilFim + "' "+ENTER
	
	cQuery += "	JOIN "+RetSqlName("SA3")+" SA3 "+ENTER
	cQuery += "		ON	SA3.A3_COD = SE1.E1_VEND1 "+ENTER
	
	cQuery += "WHERE	SE1.D_E_L_E_T_ = '' "+ENTER
	cQuery += "	AND SE1.E1_FILIAL BETWEEN '"+cFilIni + "' AND '" + cFilFim + "' "+ENTER
	cQuery += "	AND SA3.A3_FILIAL BETWEEN '"+cFilIni + "' AND '" + cFilFim + "' "+ENTER
	cQuery += "	AND SA1.D_E_L_E_T_ = '' "+ENTER
	cQuery += "	AND SA3.D_E_L_E_T_ = '' "+ENTER
	cQuery += "	AND SE1.E1_SALDO > 0 "+ENTER
	cQuery += "	AND E1_VENCREA 	BETWEEN '"+Dtos(dDtIni) + "' AND '" + Dtos(dDtFim) + "' "+ENTER
	cQuery += "	AND	SA1.A1_COD 	BETWEEN '"+cCliIni + "' AND '" + cCliFim + "'  "+ENTER
	cQuery += "	AND SA1.A1_LOJA BETWEEN '"+cLojIni + "' AND '" + cLojFim + "'  "+ENTER
	If Empty( AllTrim( cFor ) )
		cQuery += "	AND SA3.A3_COD BETWEEN	'"+cVendIni + "' AND '" + cVendFim + "'  "+ENTER
	Else
		cQuery += "	AND SA3.A3_COD = '"+cFor+"' "+ENTER
	Endif
	cQuery += "	AND SE1.E1_TIPO <> 'PA' AND SE1.E1_TIPO <> 'RA'  "+ENTER
	
	cQuery += "	AND SE1.E1_TIPO <> 'NCC'  "+ENTER
	cQuery += "	AND SE1.E1_TIPO <> 'CH'  "+ENTER
	
	cQuery += "ORDER BY  SA3.A3_COD"
	If !Empty( AllTrim( cFor ) )
		cQuery +=", SA1.A1_COD, SA1.A1_LOJA, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_VENCREA  "+ENTER
	Endif
	
	If Select(cTemp) >0
		(cTemp)->( DbCloseArea() )
	Endif
	
	//Define o alias da query              
	TcQuery cQuery New Alias (cTemp)

Return 


Static Function cabec()
	Local cRet	:= ""
	
	cRet += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	cRet += '<html>
	cRet += '	<head>
	cRet += '		<meta http-equiv="content-type" content="text/html;charset=ISO-8859-1">
	cRet += '		<style type="text/css">
	cRet += '			<!--
	cRet += '			.style1 {
	cRet += '				font-size: 22px;
	cRet += '				font-weight: bold;
	cRet += '			}
	cRet += '			.style11 {font-size: 14px}
	cRet += '			.Table_1 {
	cRet += '				border-top-width: thin;
	cRet += '				border-right-width: thin;
	cRet += '				border-bottom-width: thin;
	cRet += '				border-left-width: thin;
	cRet += '				border-top-style: solid;
	cRet += '				border-right-style: solid;
	cRet += '				border-bottom-style: solid;
	cRet += '				border-left-style: solid;
	cRet += '			}
	cRet += '			.Table_2 {
	cRet += '				border-top-style: none;
	cRet += '				border-right-style: none;
	cRet += '				border-bottom-style: none;
	cRet += '				border-left-style: none;
	cRet += '			}
	cRet += '			.style22 {font-size: 12px}
	cRet += '			.style24 {font-size: 14px}
	cRet += '			.style25 {font-size: 14px; font-weight: bold; }
	cRet += '			.style26 {font-size: 14px; font-weight: bold; }
	cRet += '			.style27 {border-top-style: none; border-right-style: none; border-bottom-style: none; border-left-style: none; font-size: 14px; }
	cRet += '			.style29 {font-size: 16px; font-weight: bold; }
	cRet += '			.style31 {border-top-style: none; border-right-style: none; border-bottom-style: none; border-left-style: none; font-size: 12px; }
	cRet += '			.Fonte {
	cRet += '				font-family: Tahoma;
	cRet += '			}
	cRet += '			-->
	cRet += '		</style>
	cRet += '		<title>wf</title>
	cRet += '	</head>
	cRet += '	<body class="Fonte">
	cRet += '		
	cRet += '		<table width=800>
	cRet += '			<tr>
	cRet += '				<td>
	cRet += '					<span class="style25"><font color=#ff0000>
	cRet += '						A empresa de representação;<br><br>
	cRet += '						Somente a título de informação, segue a relação de clientes inadimplentes pertencentes a sua carteira de clientes.<br>
	cRet += '						Reforçamos que as informações contidas no relatório abaixo são de responsabilidade do Grupo Kapazi sendo que o mesmo não deve ser divulgado.<br>
	cRet += '						Caso tenha dúvidas ou queira um relatório mais detalhado de seus clientes, favor solicitar ao <a href="mailto:cobranca@kapazi.com.br">departamento de Cobrança</a> ou responder este e-mail.</font></span>
	cRet += '				</td>
	cRet += '			</tr>
	cRet += '			<tr>
	cRet += '				<td height=10></td>
	cRet += '			</tr>
	cRet += '		</table>
	
Return cRet


Static Function Rodap()
	Local cRet	:= ""
	cRet += '		<table width=800>
	cRet += '			<tr>
	cRet += '				<td>
	cRet += '					<span class="style25">
	cRet += '					Nota de Confidencialidade: A informação contida neste documento é para uso único e exclusivo da pessoa a quem se destina, e pode tratar-se de assunto confidencial. <br>
	cRet += '					Se você não é o destinatário, por favor, notifique-nos imediatamente e destrua o documento. Não leia o conteúdo para nenhuma outra pessoa, nem tome quaisquer notas, pois ambos os procedimentos podem ser punidos legalmente.</span>
	cRet += '				</td>	
	cRet += '			</tr>	
	cRet += '		</table>
	cRet += '		<!-- fim cliente -->
	cRet += '		<br>
	cRet += '	</body>
	cRet += '</html>
		
Return cRet


user function tEnvMail(xFrom, xTo, xSbj, xCorpo, xInLineImg,xReplyTo,xCC,xBCC)
	Local 	cMsg
	Local 	cUser 		:= GetMV("MV_WFMAIL")
	Local 	cPass 		:= GetMV("MV_WFPASSW")
	Local 	cSMTPSrv 	:= GetMV("MV_WFSMTP")
	Local 	xRet
	Local 	oServer
	Local 	oMessage 
	Local 	cFileName
	Local	cSMTPPor	:= 25
	Local	lUseSSL		:= .F.
	Local	lUseTLS		:= .F.
	Local	nTimeout	:= 60
	
	Default xInLineImg 	:= ""
	Default xReplyTo	:= ""
	Default xCC			:= ""
	Default xBCC		:= ""
	
	cFileName			:= strtran(xInLineImg,"\","")
	
	oMessage:= TMailMessage():New()
	oMessage:Clear()
	
	oMessage:cDate 		:= cValToChar( Date() )
	oMessage:cFrom 		:= xFrom
	oMessage:cTo 		:= xTo
	oMessage:cSubject 	:= xSbj
	oMessage:cBody 		:= xCorpo
	oMessage:cReplyTo	:= xReplyTo
	oMessage:cCC		:= xCC
	oMessage:cBCC		:= xBCC
	
	If At("<HTML>",Upper(xCorpo)) > 0
		oMessage:MsgBodyType( "text/html" )
	Endif
	
	//Anexa um arquivo
	if xInLineImg <> ""
		xRet := oMessage:AttachFile( xInLineImg, Nil, Nil )
		if xRet < 0
			cMsg := "Could not attach file " + xInLineImg
			conout( cMsg )
			return .f.
		endif
		
		oMessage:AddCustomHeader( "Content-Transfer-Encoding:", "base64" )
		oMessage:AddCustomHeader( "Content-ID:", cFileName )
		oMessage:AddCustomHeader( "Content-Disposition: inline; filename=", cFileName )
		
	endif
	
	oServer	:= tMailManager():New()
	
	WF7->( DbSetOrder(1) )
	WF7->( DbGoTop() )
	
	If !WF7->( EOF() )
		While !WF7->( EOF() )
		 	If WF7->WF7_ATIVO
				lUseTLS	:= .F.
				lUseSSL := WF7->WF7_SSL
				cSMTPSrv:= AllTrim(WF7->WF7_SMTPSR	)
				cUser	:= AllTrim(WF7->WF7_AUTUSU	)
				cPass	:= AllTrim(WF7->WF7_AUTSEN	)
				cSMTPPor:= WF7->WF7_SMTPPR
				nTimeout:= WF7->WF7_TEMPO
				Exit
			Endif
			WF7->( DbSkip())
		Enddo
	Endif
	
	xRet := oServer:Init( "", cSMTPSrv, cUser, cPass, 0, cSMTPPor )
	
	oServer:SetUseTLS( lUseTLS ) 
	oServer:SetUseSSL( lUseSSL )
	
	if xRet != 0
		cMsg := "Could not initialize SMTP server: " + oServer:GetErrorString( xRet )
		conout( cMsg )
		return .F.
	endif
	
	xRet := oServer:SetSMTPTimeout( 60 )
	if xRet != 0
		cMsg := "Could not set Protocol timeout to 60 "
		conout( cMsg )
	endif
	
	xRet := oServer:SMTPConnect()
	if xRet <> 0
		cMsg := "Could not connect on SMTP server: " + oServer:GetErrorString( xRet )
		conout( cMsg )
		return .F.
	endif
	
	xRet := oServer:SMTPAuth(cUser,cPass)
	if xRet <> 0
		conout( "[AUTH] FAIL TRY with USER() and PASS()" )
        conout( "[AUTH][ERROR] " + str( xRet, 6 ), oServer:GetErrorString( xRet ) )
		Return .F.
	endif
	
	xRet := oMessage:Send( oServer )
	if xRet <> 0
		cMsg := "Could not send message: " + oServer:GetErrorString( xRet )
		conout( cMsg )
		Return .F.
	endif
	
	xRet := oServer:SMTPDisconnect()
	if xRet <> 0
		cMsg := "Could not disconnect from SMTP server: " + oServer:GetErrorString( xRet )
		conout( cMsg )
	endif

Return .T.