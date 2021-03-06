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
!Nome              ! TCP_PE_MA120BUT                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! Pontos de entrada para adicionar bot�es na inclus�o e edi��o do PC        !
+------------------+---------------------------------------------------------+
!Autor             ! Eduardo G. Vieira                                 !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 00/04/2019                                              !
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

User Function MA120BUT() 
Local aButtons := {} 
// Botoes a adicionar
IF !INCLUI
	aadd(aButtons,{'Imprimir',{|| Matr110( 'SC7', SC7->(RECNO()), 2 )},'Imprimir Pedido','Imprimir'}) 
ENDIF

Return (aButtons )
