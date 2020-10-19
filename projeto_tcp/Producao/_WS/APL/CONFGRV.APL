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
!Nome              ! CONFGRV.APL                                             !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotinas para gerar HTML de confirmação de gravação msg  !
+------------------+---------------------------------------------------------+
!Autor             ! Mário Lúcio Blasi Faria                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 18/06/2013                                              !
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

HTML Function CONFGRV(__aCookies,__aPostParms,__nProcId,__aProcParms,__cHTTPPage)

	Local __Response := ''

	__Response += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' + CRLF
	__Response += '<html xmlns="http://www.w3.org/1999/xhtml">' + CRLF
	__Response += '<head>' + CRLF
	__Response += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />' + CRLF
	__Response += '<title>Mensagem</title>' + CRLF
	__Response += '</head>' + CRLF
	__Response += '<body>
	__Response += '<font face="Arial">Mensagem gravada com sucesso.</font>' + CRLF
	__Response += '<BR></BR>' + CRLF
	__Response += '<font face="Arial">Por favor efetue a aprovação/rejeição do pedido.</font>' + CRLF
	__Response += '</body>' + CRLF
	__Response += '</html>' + CRLF

Return(__Response)