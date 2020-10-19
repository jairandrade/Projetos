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
!Descricao         ! WebService para solicita��o do cadastro de C.Custos     !
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

wsservice wsPWSUsuarioTCP description "Webservice retorno do cadastro de Centro de Custos."

	// DECLARACAO DAS VARIVEIS GERAIS
	wsdata sFILIAL as string
	wsdata sEmpresa as String
	wsdata sCOD as string
	wsdata cLogin as string
	wsdata RetUsuario as Usuario_Struct

	// DECLARACAO DAS ESTRUTURAS DE RETORNO
	wsdata oPWSCCusto  as PWSCCusto_Struct
	wsdata oPWSCCustos as array of PWSCCusto_Struct

	// DELCARACAO DO METODOS
	wsmethod GetUsuarioByCod description "Carrega o c�digo do usu�rio, a partir do login"
	//wsmethod GetAllCC description "Carrega os todos os centros de custo cadastrados."

endwsservice

/*
+------------+---------------------------------------------------------------+
! Funcao     ! Metodo WS                                                     !
+------------+---------------------------------------------------------------+
! Autor      ! Clederson Bahl e Dotti												!
+------------+---------------------------------------------------------------+
! Descricao  ! Carrega os dados de um c.c. conforme c�digo                	!
+------------+---------------------------------------------------------------+
! Parametros !                                                               !
+------------+---------------------------------------------------------------+
*/
wsmethod GetUsuarioByCod wsreceive sEmpresa,sFILIAL,cLogin wssend RetUsuario wsservice wsPWSUsuarioTCP
	Local _aSM0 := GetArea("SM0")
	Local _cEmpAux := cEmpAnt
	Local _cFilAux := cFilAnt
		
	SM0->(DbSetOrder(1))
	SM0->(dbSeek(sEmpresa+sFilial))

	cEmpAnt := sEmpresa
	cFilAnt := sFilial

	RpcSetType( 3 )
	RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

	//Pesquisa Usu�rio por Login
	PswOrder(2)
	If PswSeek(::cLogin,.T.) //Se usu�rio encontrado
	                       
		//Recupera informa��es do Usu�rio
		aDados := PswRet() 
		
		::RetUsuario:CODIGO 	  := aDados[1][1]  
		::RetUsuario:DEPARTAMENTO := aDados[1][12]  
		
	endif
	
	cEmpAnt := _cEmpAux
	cFilAnt := _cFilAux

	RestArea(_aSM0)
return .T. /* fim do metodo GetProdByCod */


wsstruct Usuario_Struct

wsdata CODIGO as string
wsdata DEPARTAMENTO as string

endwsstruct
