#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "AP5MAIL.CH"
#include "fileio.ch"

#DEFINE CRLF (chr(13)+chr(10))


/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
! Versão           ! Protheus 11                                             !
+------------------+---------------------------------------------------------+
! Tipo             ! PE                                                      !
+------------------+---------------------------------------------------------+
! Modulo           ! PCO                                                     !
+------------------+---------------------------------------------------------+
! Nome             ! PCOA5304                                                !
+------------------+---------------------------------------------------------+
! Descricao        ! Preenche o campo ALI_XPROWF na criação da contingencia.!
+------------------+---------------------------------------------------------+
! Autor            ! HUGO                                                    !
+------------------+---------------------------------------------------------+
! Data de Criacao  ! 17/03/2015                                              !
+------------------+---------------------------------------------------------+

*/

User Function PCOA5304()

LOCAL aAreaAnt := GETAREA()

DbSelectArea('ALI')
RecLock('ALI', .F.)
	ALI->ALI_XPROWF := 'A'
ALI->(MsUnlock())

RESTAREA(aAreaAnt)   // Retorna o ambiente anterior

Return