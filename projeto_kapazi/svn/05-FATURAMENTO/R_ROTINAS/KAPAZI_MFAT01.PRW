#Include "RwMake.ch"
#include "Topconn.ch"
#include "protheus.ch"

/*
+----------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! PONTO DE ENTRADA                                        !
+------------------+---------------------------------------------------------+
!Módulo            ! Compras                                                 !
+------------------+---------------------------------------------------------+
!Nome              ! KAPAZI_MFAT001                                          !
+------------------+---------------------------------------------------------+
!Tabelas Utilizadas! SC6                                                     !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para buscar o valor total dos itens do Pedido    !
!                  ! Custo utilizado                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Anderson Franco                                         !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 07/04/11                                                !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/
User Function MFAT01(cfilial,cnumped)
Local _aarea:= GetArea()
Local _ntotsc6:=0
_cAlias		:= GetNextAlias()
BeginSql Alias _cAlias
	SELECT SUM(C6_VALOR) TOTMERC
	FROM %table:SC6% SC6
	WHERE
	C6_NUM=%exp:cnumped% AND
	C6_FILIAL=%exp:cfilial%  AND
	%NotDel%
EndSql
DbSelectArea(_cAlias)
dbgotop()
If !((_cAlias)->(eof() ))
	_ntotsc6:=(_cAlias)->(TOTMERC)
EndIf
RestArea(_aArea)
(_cAlias)->(dbclosearea())

Return(_ntotsc6)
