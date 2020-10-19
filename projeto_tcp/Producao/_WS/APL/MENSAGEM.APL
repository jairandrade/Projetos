/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina                                                  !
+------------------+---------------------------------------------------------+
!Modulo            ! Compras                                                 !
+------------------+---------------------------------------------------------+
!Nome              ! MENSAGEM.APL                                            !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotinas para gerar HTML para enviar mensagem            !
+------------------+---------------------------------------------------------+
!Autor             ! Mário Lúcio Blasi Faria                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 17/06/2013                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACOES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

#include "SIGAWIN.CH"

#DEFINE CRLF CHR(13)+CHR(10)

HTML Function MENSAGEM(cLink,__aCookies,__aPostParms,__nProcId,__aProcParms,__cHTTPPage)

	Local __Response := ""

	__Response += PlainH_1()
	__Response += '<font face="Arial">Insira a mensagem abaixo:</font>' + CRLF
	__Response += '<form id="form1" name="form1" method="post" action="http://10.41.4.68:' + AllTrim(GetMv("TCP_PORTWF")) + '/pp/U_WEBGRMSG.apw?keyvalue=' + cLink +'">' + CRLF   
	__Response += '  <p>' + CRLF
	__Response += '    <label for="msg"></label>' + CRLF       
	__Response += '   <textarea name="cmsgg" cols="90" rows="3" id="msg" lang="pt" maxlength="150"></textarea>' + CRLF 
	__Response += '  </p>' + CRLF
	__Response += '  <p>' + CRLF
	__Response += '    <input type="submit" name="Enviar" id="Enviar" value="Enviar" />' + CRLF
	__Response += '  </p>' + CRLF
	__Response += '</form>' + CRLF
	__Response += '<p>&nbsp;</p>' + CRLF
	__Response += PlainH_2()

Return(__Response)

Static Function PlainH_1()

	Local __Response := ""
	
	__Response += '<html xmlns="http://www.w3.org/1999/xhtml">' + CRLF
	__Response += '<head>' + CRLF
	__Response += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />' + CRLF
	__Response += '<title>Mensagem</title>' + CRLF  
	__Response += '</head>' + CRLF
	__Response += '<body>' + CRLF
	
Return(__Response)

Static Function PlainH_2()

	Local __Response := ""
	
	__Response += '</body>' + CRLF
	__Response += '</html>' + CRLF
	
Return(__Response)