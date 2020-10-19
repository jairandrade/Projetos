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
!Descricao         ! WebService para solicitação do cadastro de C.Custos     !
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Clederson Bahl e Dotti	 							     !
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

wsservice wsPWSCCustoTCP description "Webservice retorno do cadastro de Centro de Custos."

	// DECLARACAO DAS VARIVEIS GERAIS
	wsdata sFILIAL as string
	wsdata sEmpresa as String
	wsdata sCOD as string

	// DECLARACAO DAS ESTRUTURAS DE RETORNO
	wsdata oPWSCCusto  as PWSCCusto_Struct
	wsdata oPWSCCustos as array of PWSCCusto_Struct

	// DELCARACAO DO METODOS
	wsmethod GetCCByCod description "Carrega os dados de um centro de custo a partir do código."
	wsmethod GetAllCC description "Carrega os todos os centros de custo cadastrados."

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
wsmethod GetCCByCod wsreceive sEmpresa, sFILIAL, sCOD wssend oPWSCCusto wsservice wsPWSCCustoTCP
	Local _aSM0 := GetArea("SM0")
	Local _cEmpAux := cEmpAnt
	Local _cFilAux := cFilAnt

	SM0->(DbSetOrder(1))
	SM0->(dbSeek(sEmpresa+sFilial))

	cEmpAnt := sEmpresa
	cFilAnt := sFilial

	RpcSetType( 3 )
	RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

	sFilial := xFilial("CTT")//iif(Empty(sFilial), xFilial("CTT"), sFilial )

	DbSelectArea("CTT")
	CTT->(DBSetOrder(1))
	if CTT->(DBSeek(sFILIAL+sCOD))

		::oPWSCCusto:FILIAL := CTT->CTT_FILIAL
		::oPWSCCusto:COD    := CTT->CTT_CUSTO
		::oPWSCCusto:CLASSE := IIF(CTT->CTT_CLASSE == '1', 'Sintetico', 'Analitico')
		::oPWSCCusto:DESC   := CTT->CTT_DESC01

	endif

	cEmpAnt := _cEmpAux
	cFilAnt := _cFilAux

	RestArea(_aSM0)
return .T. /* fim do metodo GetProdByCod */

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
wsmethod GetAllCC wsreceive sEmpresa, sFILIAL wssend oPWSCCustos wsservice wsPWSCCustoTCP
	
	Local cAlias := GetNextAlias()
	Local lRpc 	 := (Type('cEmpAnt') == 'U') .and. (Type('cFilAnt') == 'U')//Existe conexao ativa?
	Local cTabela   := sEmpresa+'0'
	Local cTabCTT    := '%CTT'+cTabela+'%'
	
	if lRpc
		RPCSetType(3)
		WfPrepEnv(sEmpresa,sFilial)
	endif
	
	if sEmpresa == '03'
		sFILIAL := '  '
	endif
	
	BeginSQL alias cAlias
		%noparser%

		SELECT
		CTT.CTT_FILIAL,
		CTT.CTT_CUSTO ,
		CTT.CTT_CLASSE,
		CTT.CTT_DESC01
		FROM
		%EXP:cTabCTT% CTT
		WHERE CTT.CTT_FILIAL = %Exp:sFILIAL%
		AND CTT.CTT_BLOQ <> '1'		
		AND len(rtrim(CTT_CUSTO)) = 6		 
		AND CTT.%notdel%
	EndSql
	

	while (cAlias)->(!Eof())

		aAdd(::oPWSCCustos, WSClassNew("PWSCCusto_Struct") )
		nX := Len(::oPWSCCustos)

		::oPWSCCustos[nX]:FILIAL := (cAlias)->CTT_FILIAL
		::oPWSCCustos[nX]:COD    := (cAlias)->CTT_CUSTO
		::oPWSCCustos[nX]:CLASSE := IIF((cAlias)->CTT_CLASSE == '1', 'Sintetico', 'Analitico')
		::oPWSCCustos[nX]:DESC   := (cAlias)->CTT_DESC01

		(cAlias)->(DBSkip())
	enddo

	(cAlias)->(DBCloseArea())

	if lRpc
		dbCloseAll() //Fecho todos os arquivos abertos
	endif
	
return .T. /* fim do metodo GetProds */

/*
+-----------+----------------------------------------------------------------+
! Funcao    ! Estrutura dos CCustos                               				!
+-----------+----------------------------------------------------------------+
! Autor      ! Clederson Bahl e Dotti												!
+-----------+----------------------------------------------------------------+
! Descricao ! Estrutura para armazenamento de dados do centro de custo		!
+-----------+----------------------------------------------------------------+
*/
wsstruct PWSCCusto_Struct

wsdata FILIAL as string
wsdata COD as string
wsdata CLASSE as string
wsdata DESC as string

endwsstruct /* fim da estrutura PWSCCusto_Struct */