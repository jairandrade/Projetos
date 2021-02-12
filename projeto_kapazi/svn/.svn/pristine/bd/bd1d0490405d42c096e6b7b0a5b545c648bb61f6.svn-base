#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"  
/*
+------------------+---------------------------------------------------------+
!Nome              ! CADSZH                                                  !
+------------------+---------------------------------------------------------+
!Descrição         ! Rotina para efetuar manutencao da tabela acessoria.       !
+------------------+---------------------------------------------------------+
!Autor             ! Marcio A.Sugahara                                       !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 23/10/2019                                              !
+------------------+---------------------------------------------------------+
*/
User Function CADSZH() 

	Private cCadastro:="Cod.Val.Declaratorios "
	Private aRotina:= {}

	//Montar o vetor aRotina, obrigatorio para utilização da função mBrowse()
	aRotina := {{ "Pesquisar"	 ,"AxPesqui"	, 0 , 1},;
							{ "Visualizar" ,"AxVisual"	, 0 , 2},;
							{ "Incluir"		 ,"AxInclui"	, 0 , 3},; 
							{ "Alterar"		 ,"AxAltera"	, 0 , 4},;
							{ "Excluir"		 ,"AxDeleta"	, 0 , 5}}
							
	
	MBrowse(6, 1, 22, 75, "SZH", nil, nil, nil, nil, nil,) 

return()