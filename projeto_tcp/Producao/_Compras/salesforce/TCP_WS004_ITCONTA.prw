#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
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

wsservice wsPWSItContaTCP description "Webservice retorno do cadastro de Centro de Custos."

	// DECLARACAO DAS VARIVEIS GERAIS
	wsdata sFILIAL as string
	wsdata sEmpresa as String
	wsdata sCOD as string

	// DECLARACAO DAS ESTRUTURAS DE RETORNO
	wsdata oPWSItConta  as PWSItConta_Struct
	wsdata oPWSItContas as array of PWSItConta_Struct

	// DELCARACAO DO METODOS
	wsmethod GetItContaByCod description "Carrega os dados de um centro de custo a partir do código."
	wsmethod GetAllItContas description "Carrega os todos os centros de custo cadastrados."

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
wsmethod GetItContaByCod wsreceive sEmpresa, sFILIAL, sCOD wssend oPWSItConta wsservice wsPWSItContaTCP
	Local _aSM0 := GetArea("SM0")
	Local _cEmpAux := cEmpAnt
	Local _cFilAux := cFilAnt

	PREPARE ENVIRONMENT EMPRESA '02' FILIAL '01' TABLES "CTD" MODULO "SIGACOM"


	SM0->(DbSetOrder(1))
	SM0->(dbSeek(sEmpresa+sFilial))

	cEmpAnt := sEmpresa
	cFilAnt := sFilial

	RESET ENVIRONMENT
	RpcSetType( 3 )
	RpcSetEnv(sEmpresa, sFilial )

	sFilial := xFilial("CTD")//iif(Empty(sFilial), xFilial("CTD"), sFilial )

	DbSelectArea("CTD")
	CTD->(DBSetOrder(1))
	if CTD->(DBSeek(sFILIAL+sCOD))

		::oPWSItConta:FILIAL   := CTD->CTD_FILIAL
		::oPWSItConta:COD      := CTD->CTD_ITEM
		::oPWSItConta:CLASSE   := IIF(CTD->CTD_CLASSE == '1', 'Sintetico', 'Analitico')
		::oPWSItConta:DESC     := CTD->CTD_DESC01
		::oPWSItConta:NATUREZA := CTD->CTD_XNATUR

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
wsmethod GetAllItContas wsreceive sEmpresa, sFILIAL wssend oPWSItContas wsservice wsPWSItContaTCP
	Local cAlias := GetNextAlias()
	
	Local _aAux   := {}
	Local i       := 0
	Local _aAreaSM0 := {}
	Local _oAppBk := oApp //Guardo a variavel resposavel por componentes visuais

	dbSelectArea("SM0")
	_aAreaSM0 := SM0->(GetArea())
	_cEmpBkp := SM0->M0_CODIGO //Guardo a empresa atual
	_cFilBkp := SM0->M0_CODFIL //Guardo a filial atual

	//troco de empresa
	dbCloseAll() //Fecho todos os arquivos abertos
	OpenSM0() //Abrir Tabela SM0 (Empresa/Filial)
	dbSelectArea("SM0") //Abro a SM0
	SM0->(dbSetOrder(1))
	SM0->(dbSeek(sEmpresa + sFILIAL,.T.)) //Posiciona Empresa
	cEmpAnt := SM0->M0_CODIGO //Seto as variaveis de ambiente
	cFilAnt := SM0->M0_CODFIL
	OpenFile(cEmpAnt + cFilAnt) //Abro a empresa que eu desejo trabalhar
	
	//sFilial := xFilial("CTD")
//	sFilial := iif(sEmpresa == "03", " ",sFilial )
	
	BeginSQL alias cAlias
		%noparser%

		SELECT
		CTD.CTD_FILIAL,
		CTD.CTD_ITEM ,
		CTD.CTD_CLASSE,
		CTD.CTD_DESC01,
		CTD.CTD_XNATUR
		FROM
		%table:CTD% CTD
		WHERE CTD.CTD_FILIAL = %Exp:sFILIAL%
		AND CTD.CTD_BLOQ <> '1'
		 AND CTD_XNATUR != ' '
//		AND len(rtrim(CTD_ITEM)) = 6		 
		AND CTD.%notdel%
	EndSql
	
	while (cAlias)->(!Eof())

		aAdd(::oPWSItContas, WSClassNew("PWSItConta_Struct") )
		nX := Len(::oPWSItContas)

		::oPWSItContas[nX]:FILIAL   := (cAlias)->CTD_FILIAL
		::oPWSItContas[nX]:COD      := (cAlias)->CTD_ITEM
		::oPWSItContas[nX]:CLASSE   := IIF((cAlias)->CTD_CLASSE == '1', 'Sintetico', 'Analitico')
		::oPWSItContas[nX]:DESC     := (cAlias)->CTD_DESC01
		::oPWSItContas[nX]:NATUREZA := (cAlias)->CTD_XNATUR

		(cAlias)->(DBSkip())
	enddo

	(cAlias)->(DBCloseArea())

	//Para finalizar volto as variaveis de sistema para seus valores antes da execução
	dbCloseAll() //Fecho todos os arquivos abertos
	OpenSM0() //Abrir Tabela SM0 (Empresa/Filial)
	dbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	SM0->(RestArea(_aAreaSM0)) //Restaura Tabela
	cFilAnt := SM0->M0_CODFIL //Restaura variaveis de ambiente
	cEmpAnt := SM0->M0_CODIGO
	
	IF !EMPTY(_cEmpBkp) .AND. !EMPTY(_cFilBkp) 
		OpenFile(cEmpAnt + cFilAnt) //Abertura das tabelas
	ENDIF
	oApp := _oAppBk //Backup do componente visual
	
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
wsstruct PWSItConta_Struct

wsdata FILIAL as string
wsdata COD as string
wsdata CLASSE as string
wsdata DESC as string
wsdata NATUREZA as string

endwsstruct /* fim da estrutura PWSItConta_Struct */