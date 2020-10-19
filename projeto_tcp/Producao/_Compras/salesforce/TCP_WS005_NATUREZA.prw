/*
+----------------------------------------------------------------------------+
!                          FICHA TECNICA DO PROGRAMA                         !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! WebService                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Faturamento                                             !
+------------------+---------------------------------------------------------+
!Descricao         ! WebService para solicitação do cadastro de Naturezas    !
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Clederson Bahl e Dotti	 							       !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 04/11/2014                                              !
+------------------+---------------------------------------------------------+
!                               ATUALIZACOES                                 !
+-------------------------------------------+-----------+-----------+--------+
!   Descricao detalhada da atualizacao      !  Nome do  ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

#include "PROTHEUS.CH"
#include "APWEBSRV.CH"
#include "APWEBEX.CH"
#INCLUDE "TOPCONN.CH"

wsservice wsPWSNaturezaTCP description "Webservice retorno do cadastro de naturezas."

	// DECLARACAO DAS VARIVEIS GERAIS
	wsdata sFILIAL as string
	wsdata sCOD as string
	wsdata sEmpresa as string

	// DECLARACAO DAS ESTRUTURAS DE RETORNO
	wsdata oPWSNatureza  as PWSNatureza_Struct
	wsdata oPWSNaturezas as array of PWSNatureza_Struct

	// DELCARACAO DO METODOS
	wsmethod GetNatByCod description "Carrega os dados de uma natureza a partir do código."
	wsmethod GetAllNat description "Carrega os todos as naturezas cadastrados."

endwsservice




/*
+------------+---------------------------------------------------------------+
! Funcao     ! Metodo WS                                                     !
+------------+---------------------------------------------------------------+
! Autor      ! Clederson Bahl e Dotti												!
+------------+---------------------------------------------------------------+
! Descricao  ! Carrega os dados de um c.c. conforme código                	!
+------------+---------------------------------------------------------------+
! Parametros !                                                               !
+------------+---------------------------------------------------------------+
*/
wsmethod GetNatByCod wsreceive sEmpresa, sFILIAL, sCOD wssend oPWSNatureza wsservice wsPWSNaturezaTCP
	Local _aSM0 := GetArea("SM0")
	Local _cEmpAux := cEmpAnt
	Local _cFilAux := cFilAnt

	SM0->(DbSetOrder(1))
	SM0->(dbSeek(sEmpresa+sFilial))

	cEmpAnt := sEmpresa
	cFilAnt := sFilial

	RpcSetType( 3 )
	RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

	sFilial := iif(Empty(sFilial), xFilial("SED"), sFilial )

	DbSelectArea("SED")
	SED->(DBSetOrder(1))
	if SED->(DBSeek(sFILIAL+sCOD))

		::oPWSNatureza:FILIAL := SED->ED_FILIAL
		::oPWSNatureza:CODIGO := SED->ED_CODIGO
		::oPWSNatureza:DESCRIC:= SED->ED_DESCRIC

	endif

	cEmpAnt := _cEmpAux
	cFilAnt := _cFilAux

	RestArea(_aSM0)
return .T. /* fim do metodo */



/*
+------------+---------------------------------------------------------------+
! Funcao     ! Metodo WS                                                     !
+------------+---------------------------------------------------------------+
! Autor      ! Clederson Bahl e Dotti												!
+------------+---------------------------------------------------------------+
! Descricao  ! Carrega todos os C.C. desbloqueados								!
+------------+---------------------------------------------------------------+
! Parametros !                                                               !
+------------+---------------------------------------------------------------+
*/
wsmethod GetAllNat wsreceive sEmpresa, sFILIAL wssend oPWSNaturezas wsservice wsPWSNaturezaTCP
	Local nX
	Local cAlias := GetNextAlias()
	Local _aSM0 := GetArea("SM0")
	Local _cEmpAux := cEmpAnt
	Local _cFilAux := cFilAnt
	SM0->(DbSetOrder(1))
	SM0->(dbSeek(sEmpresa+sFilial))

	cEmpAnt := sEmpresa
	cFilAnt := sFilial

	RpcSetType( 3 )
	RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

	sFilial := iif(Empty(sFilial), xFilial("SED"), sFilial )

	BeginSQL alias cAlias
		%noparser%

		SELECT
			SED.ED_FILIAL ,
			SED.ED_CODIGO ,
			SED.ED_DESCRIC
		FROM
			%table:SED% SED
		WHERE
			SED.ED_FILIAL = %xFilial:SED% AND ED_MSBLQL != '1' AND ED_COND !='R'
		AND SED.%notdel%
	EndSql

	while (cAlias)->(!Eof())

	   	aAdd(::oPWSNaturezas, WSClassNew("PWSNatureza_Struct") )
		nX := Len(::oPWSNaturezas)

		::oPWSNaturezas[nX]:FILIAL := (cAlias)->ED_FILIAL
		::oPWSNaturezas[nX]:CODIGO := (cAlias)->ED_CODIGO
		::oPWSNaturezas[nX]:DESCRIC:= (cAlias)->ED_DESCRIC

		(cAlias)->(DBSkip())
	enddo

	(cAlias)->(DBCloseArea())
	
	if !empty(_cEmpAux) .and. !empty(_cFilAux)
		cEmpAnt := _cEmpAux
		cFilAnt := _cFilAux
	endif
	
	RestArea(_aSM0)
return .T. /* fim do metodo */



/*
+-----------+----------------------------------------------------------------+
! Funcao    ! Estrutura das Naturezas                               			!
+-----------+----------------------------------------------------------------+
! Autor      ! Clederson Bahl e Dotti												!
+-----------+----------------------------------------------------------------+
! Descricao ! Estrutura para armazenamento de dados do natureza				!
+-----------+----------------------------------------------------------------+
*/
wsstruct PWSNatureza_Struct

	wsdata FILIAL as string
	wsdata CODIGO as string
	wsdata DESCRIC as string

endwsstruct /* fim da estrutura */
