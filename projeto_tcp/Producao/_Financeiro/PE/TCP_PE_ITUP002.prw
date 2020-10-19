/*
+----------------------------------------------------------------------------+ 
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Ponto de entrada                                        !
+------------------+---------------------------------------------------------+
!Modulo            ! Compras                                                 !
+------------------+---------------------------------------------------------+
!Nome              ! TCP_PE_ITUP002                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina para Envio de e-mails                            !
+------------------+---------------------------------------------------------+
!Autor             ! Marcos Aurélio Feijó - IT UP Sul                        !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 18/12/2018                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES   !                                                         !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

#include 'tbiconn.ch'
#Include 'PROTHEUS.Ch'
#Include 'AP5MAIL.Ch'
#include 'colors.ch'
#include 'topconn.ch'
#include 'RWMAKE.CH'

/*
+-----------------------------------------------------------------------------+
! Função     ! SendMail     ! Autor ! Marcos Feijó IT UP ! Data !  18/12/2018 !
+------------+--------------+-------+--------------------+------+-------------+
! Parâmetros ! ExpC1 : Conta para conexao com servidor SMTP(OPC)              !
!            ! ExpC2 : Password da conta para conexao com o servidor SMTP(OPC)!
!            ! ExpC3 : Servidor de SMTP(OPC)                                  !
!            ! ExpC4 : Conta de origem do e-mail. O padrao eh a mesma conta   !
!            !         de conexao com o servidor SMTP(OPC)                    !
!            ! ExpC5 : Conta de destino do e-mail.                            !
!            ! ExpC6 : Assunto do e-mail.                                     !
!            ! ExpC7 : Corpo da mensagem a ser enviada.                       !
!            ! ExpC8 : Patch com o arquivo que serah enviado(OPC)             !
+------------+----------------------------------------------------------------+
! Descricao  ! Rotina para Envio de e-mails                                   !
+------------+----------------------------------------------------------------+
*/

User Function SendMail(cAccount,cPassword,cServer,cFrom,cEmail,cAssunto,cMensagem,cAttach)
//u_SendMail(,,,,"marcos.feijo@itupsul.com.br","Lançamento de NF Fora do Prazo","teste",)

Local cEmailTo := ""
Local cEmailBcc:= ""
Local lResult  := .F.
Local cError   := ""
Local i        := 0
Local cArq     := "" 
Local lAuth    := GetMv("MV_RELAUTH",,.F.)
//Local cMensagem:= u_MontaHTML("999999999", "AAA", "999999", "99", "Razão Social do Fornecedor", dDataBase, "ZZZZZ", dDataBase, "Nome do Digitador", "digitador@email.com.br", "Nome do Gestor", "gestor@email.com.br")
  																						
// Verifica se serao utilizados os valores padrao.
cAccount	:= Iif( cAccount  == NIL, GetMV( "MV_RELACNT" ), cAccount  )
cPassword	:= Iif( cPassword == NIL, GetMV( "MV_RELPSW"  ), cPassword )
cServer		:= Iif( cServer   == NIL, GetMV( "MV_RELSERV" ), cServer   )
cAttach		:= Iif( cAttach   == NIL, ""                   , cAttach   )
cFrom		:= Iif( cFrom     == NIL, cAccount             , cFrom     )  
//cFrom       := cAccount

//MsgAlert("cEmail => " + cEmail)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia o e-mail para a lista selecionada. Envia como BCC para que a pessoa pense³
//³que somente ela recebeu aquele email, tornando o email mais personalizado.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If At(";",cEmail) > 0
	cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
	cEmailBcc:= SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
Else
	cEmailTo := cEmail
Endif

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult 

If lAuth 
	lResult := Mailauth(cAccount,cPassword)
Endif

If lResult           

	SEND MAIL	FROM cFrom ;
	TO      	cEmailTo;
	BCC     	cEmailBcc;
	SUBJECT 	cAssunto;
	BODY    	cMensagem; // FORMAT HTML;
	RESULT 		lResult
	
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
	EndIf
	
	DISCONNECT SMTP SERVER
	
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
EndIf

Return {lResult,cError}


/*
+-----------------------------------------------------------------------------+
! Função     ! MontaHTML    ! Autor ! Marcos Feijó IT UP ! Data !  18/12/2018 !
+------------+--------------+-------+--------------------+------+-------------+
! Parâmetros ! ExpC1 : Número do Documento de Entrada                         !
!            ! ExpC2 : Série do Documento de Entrada                          !
!            ! ExpC3 : Código do Fornecedor                                   !
!            ! ExpC4 : Loja do Fornecedor                                     !
!            ! ExpC5 : Razão Social do Fornecedor ou Nome Fantasia            !
!            ! ExpD6 : Data de Emissão do Documento de Entrada                !
!            ! ExpC7 : Espécie do Documento de Entrada                        !
!            ! ExpD8 : Data de Digitação do Documento de Entrada              !
!            ! ExpC9 : Nome do Digitador do Documento de Entrada              !
!            ! ExpC10: e-mail do Digitador do Documento de Entrada            !
!            ! ExpC11: Nome do Gestor do Documento de Entrada                 !
!            ! ExpC12: e-mail do Gestor do Documento de Entrada               !
+------------+----------------------------------------------------------------+
! Descricao  ! Rotina para Envio de e-mails                                   !
+------------+----------------------------------------------------------------+
*/

User Function MontaHTML(_cDoc,_cSerie, _cFornece, _cLoja, _cRazao, _dEmis, _cEspecie, _dDigit, _cNomDig, _cEmaDig, _cNomGes, _cEmaGes)
Local _cHTML := ""

/*Modelo Antigo
_cHTML += "<html> "

_cHTML += "<head><title>Lancamento Fora do Prazo</title></head> "

_cHTML += "<body lang=PT-BR> "

_cHTML += "<div> "

_cHTML += "<table class=MsoNormalTable border=0 cellspacing=3 cellpadding=0> "
_cHTML += "  <table class=MsoNormalTable border=0 cellspacing=3 cellpadding=0> "
_cHTML += "    <tr width=627 style='background:yellow;font-size:13.5pt;font-family:Arial'> "
_cHTML += "      <td colspan=2> "
_cHTML += "        <b>Lançamento Fora do Prazo</b> "
_cHTML += "      </td> "
_cHTML += "    </tr> "
_cHTML += "    <tr width=627 style='background:#DFEFFF;font-size:13.5pt;font-family:Arial'> "
_cHTML += "      <td colspan=2> "
_cHTML += "        <b>Documento de Entrada " + _cDoc + " – Série " + _cSerie + "</b> "
_cHTML += "      </td> "
_cHTML += "    <tr> "
_cHTML += "    <tr style='font-size:10.0pt;font-family:Arial'> "
_cHTML += "      <td width=430 valign=top> "
_cHTML += "        <b>Fornecedor: </b>" + _cFornece + "/" + _cLoja + " - " + _cRazao + " "
_cHTML += "      </td> "
_cHTML += "      <td width=197 valign=top> "
_cHTML += "        <b>Date de Emissão: </b>" + DtoC(_dEmis) + " "
_cHTML += "      </td> "
_cHTML += "    </tr> "
_cHTML += "    <tr style='font-size:10.0pt;;font-family:Arial'> "
_cHTML += "      <td width=430 valign=top> "
_cHTML += "        <b>Espec.Docum: </b>" + _cEspecie + " "
_cHTML += "      </td> "
_cHTML += "      <td width=197 valign=top> "
_cHTML += "        <b>Data de Digitação: </b>" + DtoC(_dDigit) + " "
_cHTML += "      </td> "
_cHTML += "    </tr> "
_cHTML += "  </table> "

_cHTML += "  <p><b><span style='font-family:Arial,sans-serif;color:blue'>e-mail enviado para</span></b></p> "

_cHTML += "  <table class=MsoNormalTable border=1 cellspacing=3 cellpadding=0> "
_cHTML += "    <tr style='background:#DFEFFF;font-size:10.0pt;font-family:Arial;text-align:center'> "
_cHTML += "      <td width=59>Nível</td> "
_cHTML += "      <td width=263>Nome</td> "
_cHTML += "      <td width=300>e-Mail</td> "
_cHTML += "    </tr> "
_cHTML += "    <tr style='font-size:10.0pt;font-family:Arial'> "
_cHTML += "      <td>Digitador</td> "
_cHTML += "      <td>" + _cNomDig + "</td> "
_cHTML += "      <td><a href=mailto:" + _cEmaDig + ">" + _cEmaDig + "</a></td> "
_cHTML += "    </tr> "
_cHTML += "    <tr style='font-size:10.0pt;font-family:Arial'> "
_cHTML += "      <td>Gestor</td> "
_cHTML += "      <td>" + _cNomGes + "</td> "
_cHTML += "      <td><a href=mailto:" + _cEmaGes + ">" + _cEmaGes + "</a></td> "
_cHTML += "    </tr> "
_cHTML += "  </table> "
_cHTML += "</table> "

_cHTML += "</div> "

_cHTML += "</body> "

_cHTML += "</html> "
*/    

//Modelo Novo
_cHTML += '<html>'
_cHTML += '    <head>'
_cHTML += '        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
_cHTML += '        <meta name="viewport" content="width=device-width, initial-scale=1">'
_cHTML += '        <!-- So that mobile will display zoomed in -->'
_cHTML += '        <meta http-equiv="X-UA-Compatible" content="IE=edge">'
_cHTML += '        <!-- enable media queries for windows phone 8 -->'
_cHTML += '        <meta name="format-detection" content="telephone=no">'
_cHTML += '        <!-- disable auto telephone linking in iOS -->'
_cHTML += '        <title>'
_cHTML += '            TCP &ndash; Lan&ccedil;amento fora do prazo'
_cHTML += '        </title>'
_cHTML += '        <style type="text/css">'
_cHTML += '            body { margin: 0; padding: 0; -ms-text-size-adjust: 100%; -webkit-text-size-adjust:'
_cHTML += '            100%; } table { border-spacing: 0; } table td { border-collapse: collapse; }'
_cHTML += '        </style>'
_cHTML += '    </head>'

_cHTML += '    <body style="margin:0; padding:0;" bgcolor="#F0F0F0" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">'
_cHTML += '        <!-- 100% background wrapper (grey background) -->'
_cHTML += '        <table border="0" width="100%" height="100%" cellpadding="0" cellspacing="0" bgcolor="#F0F0F0">'
_cHTML += '            <tr>'
_cHTML += '                <td align="center" valign="top" bgcolor="#F0F0F0" style="background-color: #F0F0F0;">'
_cHTML += '                    <!-- 600px container (white background) -->'
_cHTML += '                    <table border="0" width="90%" cellpadding="0" cellspacing="0" class="container" >'
_cHTML += '				 <!-- style="width:600px;max-width:600px"-->'
_cHTML += '                        <tr>'
_cHTML += '                            <td class="container-padding header" align="left" style="font-family:Helvetica, Arial, sans-serif;font-size:24px;padding-bottom:12px;color:#054F92;padding-left:24px;padding-right:24px">'
_cHTML += '                                <br>'
_cHTML += '                                <b>'
_cHTML += '                                    TCP'
_cHTML += '                                </b>'
_cHTML += '                                &ndash; Lan&ccedil;amento fora do prazo'
_cHTML += '                            </td>'
_cHTML += '                        </tr>'
_cHTML += '                        <tr>'
_cHTML += '                            <td class="container-padding content" align="left" style="padding-left:24px;padding-right:24px;padding-bottom:12px;background-color:#ffffff">'
_cHTML += '                                <br>'
_cHTML += '                                <div class="title" style="font-family:Helvetica, Arial, sans-serif;font-size:12px;color:#374550">'
_cHTML += '                                    <b>Documento de Entrada ' + _cDoc + ' &ndash; S&eacute;rie ' + _cSerie + '</b>'
_cHTML += '	                                <br>'
_cHTML += '	                                <br>'
_cHTML += '                                    <b>Fornecedor: </b> ' + _cFornece + '/' + _cLoja + ' - ' + _cRazao
_cHTML += '	                                <br>'
_cHTML += '                                    <b>Esp&eacute;cie do documento: </b> ' + _cEspecie
_cHTML += '	                                <br>'
_cHTML += '                                    <b>Data de emiss&atilde;o: </b> ' + DtoC(_dEmis)
_cHTML += '	                                <br>'
_cHTML += '                                    <b>Data de digita&ccedil;&atilde;o: </b> ' + DtoC(_dDigit)
_cHTML += '	                                <br>'
_cHTML += '                                </div>'
_cHTML += '                                <br>'
_cHTML += '                                <div class="body-text" style="font-family:Helvetica, Arial, sans-serif;font-size:14px;line-height:20px;text-align:left;color:#333333"> '
_cHTML += '                                    <table width="100%" cellpadding="5" cellspacing="5"> '
_cHTML += '                                        <tr style="background:lightgray"> '
_cHTML += '                                            <th align="left"> '
_cHTML += '                                                N&iacute;vel '
_cHTML += '                                            </th> '
_cHTML += '                                            <th align="left"> '
_cHTML += '                                                Nome '
_cHTML += '                                            </th> '
_cHTML += '                                            <th align="left"> '
_cHTML += '                                                e&ndash;mail '
_cHTML += '                                            </th> '
_cHTML += '                                        </tr> '
_cHTML += '                                        <tr>'
_cHTML += '                                            <td align="left">'
_cHTML += '                                                Aprovador'
_cHTML += '                                            </td>'
_cHTML += '                                            <td align="left">'
_cHTML += '                                                ' + _cNomGes
_cHTML += '                                            </td>'
_cHTML += '                                            <td align="left">'
_cHTML += '                                                '+ _cEmaGes
_cHTML += '                                            </td>'
_cHTML += '                                        </tr>'
_cHTML += '                                        <tr>'
_cHTML += '                                            <td align="left">'
_cHTML += '                                                Digitador'
_cHTML += '                                            </td>'
_cHTML += '                                            <td align="left">'
_cHTML += '                                                ' + _cNomDig
_cHTML += '                                            </td>'
_cHTML += '                                            <td align="left">'
_cHTML += '                                                '+ _cEmaDig
_cHTML += '                                            </td>'
_cHTML += '                                        </tr>'

_cHTML += '                                  </table>'
_cHTML += '                                </div>'
_cHTML += '                            </td>'
_cHTML += '                        </tr>'
_cHTML += '                        <tr>'
_cHTML += '                            <td class="container-padding footer-text" align="left" style="font-family:Helvetica, Arial, sans-serif;font-size:12px;line-height:16px;color:#aaaaaa;padding-left:24px;padding-right:24px">'
_cHTML += '                                <br>'
_cHTML += '                                <br>'
_cHTML += '                                <strong>'
_cHTML += '                                    TCP - Terminal de Containeres de Paranagu&aacute;'
_cHTML += '                                </strong>'
_cHTML += '                                <br>'
_cHTML += '                                <span class="ios-footer">'
_cHTML += '                                    Av. Portu&aacute;ria, s/n &ndash; Porto D. Pedro II'
_cHTML += '                                    <br>'
_cHTML += '                                    Paranagu&aacute; &ndash; PR &ndash; Brasil &ndash; CEP 83221-570'
_cHTML += '                                    <br>'
_cHTML += '                                    +55 (41) 3420-3300'
_cHTML += '                                    <br>'
_cHTML += '                                </span>'
_cHTML += '                                <a href="http://www.tcp.com.br" style="color:#aaaaaa">www.tcp.com.br</a>'
_cHTML += '                                <br>'
_cHTML += '                                <br>'
_cHTML += '                                <br>'
_cHTML += '                            </td>'
_cHTML += '                        </tr>'
_cHTML += '                    </table>'
_cHTML += '                    <!--/600px container -->'
_cHTML += '                </td>'
_cHTML += '            </tr>'
_cHTML += '        </table>'
_cHTML += '        <!--/100% background wrapper-->'
_cHTML += '    </body>'
_cHTML += '</html>'

Return _cHTML
