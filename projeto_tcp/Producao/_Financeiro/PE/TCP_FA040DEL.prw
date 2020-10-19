#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"
#include "ap5mail.ch"
/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    �  FA040DEL	� Autor � Lucilene Mendes    � Data �22.11.18 ���
��+----------+------------------------------------------------------------���
���Descri��o �  Ponto de entrada na exclus�o de titulo a receber          ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function FA040DEL()
Local cTipoTit	:= GetNewPar("TC_TIPTIT","NF ;") //Tipos de t�tulo que enviam e-mail
Local cDest		:= GetNewPar("TC_DESTTIT","lucilene@smsti.com.br") //E-mail de usu�rios que recebem aviso do cancelamento, separado por ";"


//Se o vencimento for alterado
If SE1->E1_TIPO $  cTipoTit .and. !Empty(cDest)
	FWMsgRun(,{|| fEnvMail(cDest)},"Exclus�o de T�tulo","Aguarde... Enviando e-mail...")	
Endif

Return

/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
��� fEnvMail � Envio de e-mail na exclus�o do t�tulo			          ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function fEnvMail(cEmailTo)
Local cEmailBcc:= ""
Local cError   := ""
Local cAttach  := ""
Local cAccount := GetMV("MV_RELACNT")     
Local cPassword:= GetMV("MV_RELPSW")
Local cServer  := "smtp.tcp.com.br"//GetMV("MV_RELSERV")
Local lAuth    := GetMv("MV_RELAUTH",,.F.)
Local lResult  := .F.
Local i        := 0
Local cLFRC	   := chr(13)+chr(10)

cMensagem:= "<html>"
cMensagem+= " 	<head>"
cMensagem+= " 		<style type='text/css' rel='sytlesheet'>"
cMensagem+= " 			.titulo {color:#103090; font-weight:bold; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:13px}
cMensagem+= " 			.mensagem {color:#81818; font-family:Tahoma,Arial,Helvetica,sans-serif; font-size:13px}
cMensagem+= " 		</style>
cMensagem+= " 	</head>
cMensagem+= "  	<body>"+cLFRC+cLFRC
cMensagem+= "		<span class='titulo'>Exclus�o de t�tulo</span><br><br>"+cLFRC
cMensagem+= "		<p class='mensagem'>O t�tulo a receber abaixo foi exclu�do pelo(a) usu�rio(a) "
cMensagem+= Alltrim(Capital(UsrFullName(__cUserId)))+" em "+dtoc(date())+" �s "+Time()+" horas.</p><br>"+cLFRC+cLFRC

cMensagem+= "		<p class='mensagem'><b>Empresa/Filial: </b>"+cEmpAnt+"/"+SE1->E1_FILIAL+"</p>"
cMensagem+= "		<p class='mensagem'><b>T�tulo: </b>"+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)+"</p>"
cMensagem+= "		<p class='mensagem'><b>Valor: </b>R$"+Transform(SE1->E1_VALOR,"@E 999,999,999.99")
cMensagem+= "		<p class='mensagem'><b>Data de Vencimento: </b>"+DTOC(SE1->E1_VENCTO)+"</p>"+cLFRC
cMensagem+= "		<p class='mensagem'><b>Cliente: </b>"+SE1->E1_NOMCLI+"</p>"+cLFRC
cMensagem+= "  	</body>"+cLFRC+cLFRC			
cMensagem+= "</html>"+cLFRC+cLFRC			


CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult 

If lAuth 
	lResult := Mailauth(cAccount,cPassword)
Endif

If lResult           

	SEND MAIL	FROM cAccount ;
	TO      	cEmailTo; 
	BCC     	cEmailBcc;
	SUBJECT 	"Exclus�o de t�tulo a receber";
	BODY    	cMensagem; // FORMAT HTML;
	ATTACHMENT  cAttach;
	RESULT 		lResult
	
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		alert("Falha ao enviar e-mail. "+cError)
	EndIf
	
	DISCONNECT SMTP SERVER
	
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
EndIf

Return lResult