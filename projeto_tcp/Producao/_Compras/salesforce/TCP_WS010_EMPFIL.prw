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
!Descricao         ! WebService para solicitação do cadastro de Empresas     !
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Alexandre Effting                  	 							     !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 09/12/2014                                              !
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

wsservice wsPWSEmpFilTCP description "Webservice retorno do cadastro de Empresas."

	// DECLARACAO DAS VARIVEIS GERAIS	
	wsdata sFILIAL as string
	wsdata sEmpresa as string
			  
	// DECLARACAO DAS ESTRUTURAS DE RETORNO
	wsdata oPWSEmpFil  as PWSEmpFil_Struct
	wsdata oPWSEmpresas as array of PWSEmpFil_Struct
	
	// DELCARACAO DO METODOS
	wsmethod GetEmpFilByCod description "Carrega os dados de uma empresa a partir do código."
	wsmethod GetAllEmpFil description "Carrega os todos as Empresas cadastradas."
		
endwsservice




/*
+------------+---------------------------------------------------------------+
! Funcao     ! Metodo WS                                                     !
+------------+---------------------------------------------------------------+
! Autor      ! Alexandre Effting																				     !
+------------+---------------------------------------------------------------+
! Descricao  ! Carrega os dados de uma Empresa conforme código                !
+------------+---------------------------------------------------------------+
! Parametros !                                                               !
+------------+---------------------------------------------------------------+
*/
wsmethod GetEmpFilByCod wsreceive sFILIAL, sEmpresa wssend oPWSEmpFil wsservice wsPWSEmpFilTCP
	Local _aSM0 := GetArea("SM0")

	DbSelectArea("SM0")
	SM0->(DBSetOrder(1))
	If SM0->(DBSeek(sEmpresa+sFILIAL))
		
		::oPWSEmpFil:FILIAL  := SM0->M0_CODFIL
		::oPWSEmpFil:Empresa := SM0->M0_CODIGO
		::oPWSEmpFil:DESCFIL := SM0->M0_FILIAL
		::oPWSEmpFil:NOME    := SM0->M0_NOME
					
	Endif
	
	RestArea(_aSM0)
	
return .T. /* fim do metodo GetProdByCod */



/*
+------------+---------------------------------------------------------------+
! Funcao     ! Metodo WS                                                     !
+------------+---------------------------------------------------------------+
! Autor      ! Alexandre Effting												                     !
+------------+---------------------------------------------------------------+
! Descricao  ! Carrega todos as Empresas desbloqueados           						 !
+------------+---------------------------------------------------------------+
! Parametros !                                                               !
+------------+---------------------------------------------------------------+
*/
wsmethod GetAllEmpFil wsreceive sFILIAL wssend oPWSEmpresas wsservice wsPWSEmpFilTCP

	Local _aSM0 := GetArea("SM0")
	
	DbSelectArea("SM0")
	SM0->(DBSetOrder(1))
	SM0->(DbGoTop())
	
	While SM0->(!Eof())
	    
	  aAdd(::oPWSEmpresas, WSClassNew("PWSEmpFil_Struct") )
		nX := Len(::oPWSEmpresas)
		
		::oPWSEmpresas[nX]:FILIAL  := SM0->M0_CODFIL
		::oPWSEmpresas[nX]:Empresa := SM0->M0_CODIGO
		::oPWSEmpresas[nX]:DESCFIL := Alltrim(SM0->M0_FILIAL)
	  ::oPWSEmpresas[nX]:NOME    := Alltrim(SM0->M0_NOME)	
	    
		SM0->(DBSkip())
	Enddo 
	
	RestArea(_aSM0)
	
return .T. /* fim do metodo GetProds */



/*
+-----------+----------------------------------------------------------------+
! Funcao    ! Estrutura das Empresas                                  				 !
+-----------+----------------------------------------------------------------+
! Autor      ! Alexandre Effting												                     !
+-----------+----------------------------------------------------------------+
! Descricao ! Estrutura para armazenamento de dados do centro de custo		   !
+-----------+----------------------------------------------------------------+
*/
wsstruct PWSEmpFil_Struct  

	wsdata FILIAL as string
	wsdata Empresa as string
	wsdata DESCFIL as string
	wsdata NOME as string
	
endwsstruct /* fim da estrutura PWSEmpFil_Struct */