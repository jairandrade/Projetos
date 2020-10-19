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
!Nome              ! TCP_PE_ITUP001                                          !
+------------------+---------------------------------------------------------+
!Descricao         ! Pontos de entrada da Rotina de Contas a Pagar           !
+------------------+---------------------------------------------------------+
!Autor             ! Marcos Aurélio Feijó - IT UP Sul                        !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 17/12/2018                                              !
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
! Função     ! ITUP001      ! Autor ! Marcos Feijó IT UP ! Data !  17/12/2018 !
+------------+--------------+-------+--------------------+------+-------------+
! Parâmetros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  ! Indentifica a NF referente ao título no financeiro             !
!            ! OBS: Apenas para títulos gerados pela rotina MATA100           !
+------------+----------------------------------------------------------------+
*/

User Function ITUP001

If SE2->E2_ORIGEM = 'MATA100'
	SF1->(dbSetOrder(1))
	If SF1->(dbSeek(SE2->(E2_FILIAL+E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA)))
		cCadastro := "Nota Fiscal de Entrada"
		_nPosFunc := aScan(aRotina,{|x| "U_ITUP001" $ If(ValType(x[2]) == "B",Alltrim(GetCbSource(x[2])),x[2]) })
		A103NFiscal("SF1",SF1->(Recno()),_nPosFunc)
	Else
		MsgAlert("Documento de Entrada não Encontrado:"	+ Chr(10) + Chr(10) + "=> " + ;
				 "Filial "		+ SE2->E2_FILIAL	+ ", " + ;   
				 "Documento "	+ SE2->E2_NUM		+ ", " + ;
				 "Série " 		+ SE2->E2_PREFIXO	+ " e "+ ;
				 "Fornecedor " 	+ SE2->E2_FORNECE	+ "/"  + ;
				 				  SE2->E2_LOJA				 ;
				,"ATENÇÃO !!!")
	EndIf
Else
	MsgAlert("Título Criado por Outra Rotina", "ATENÇÃO !!!")
EndIf	

Return .T.
