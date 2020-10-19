/*
+----------------------------------------------------------------------------+ 
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Ponto de entrada                                        !
+------------------+---------------------------------------------------------+
!Modulo            ! Financeiro                                              !
+------------------+---------------------------------------------------------+
!Nome              ! TCP_PE_FINA050                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! Pontos de entrada da Rotina de Contas a Pagar           !
+------------------+---------------------------------------------------------+
!Autor             ! Alexandre Effting                                       !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 18/03/2013                                              !
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

#INCLUDE 'protheus.ch'
#INCLUDE "rwmake.ch" 

/*
+-----------------------------------------------------------------------------+
! Função     ! MTA110MNU    ! Autor ! Alexandre Effting  ! Data !  18/03/2013 !
+------------+--------------+-------+--------------------+------+-------------+
! Parâmetros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  ! Este ponto é utilizado para Adicionar mais opções no aRotina   !
+------------+----------------------------------------------------------------+
*/

User Function F050ROT()
	
	Local aRotina 	:= ParamIxb	
	Local _nOpcX 	:= Iif(nModulo==69,4,2)
	
	AAdd( aRotina, { 'GED.TCP'		, "U_TCPGED", 0, 4 } )
	AAdd( aRotina, { 'Alt Hist'		, "U_AFIN010", 0, 4 } )
	AAdd( aRotina, { 'Doc Entrada'	, "U_ITUP001", 0, _nOpcX } )
	AAdd( aRotina, { 'Pedido Compra', "U_ITUP003", 0, _nOpcX } )
	
	//Retira o conhecimento do Menu
	nPos := ASCAN(aRotina, { |x|   If(ValType(x[2])=="C",UPPER(x[2]) == "MSDOCUMENT",.F.) })
	If nPos > 0
		Adel(aRotina,nPos)
		Asize(aRotina,Len(aRotina)-1)
	EndIf

Return( aRotina )
