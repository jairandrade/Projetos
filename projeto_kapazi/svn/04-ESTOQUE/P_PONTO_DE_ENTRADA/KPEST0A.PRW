/**********************************************************************************************************************************/
/** Estoque/Compras                                                                                                              **/
/** Cadastro de Canal de Produtos.                                                                                            **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 05/02/2016 | Marcos Sulivan          | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"

/**********************************************************************************************************************************/
/** user function KPEST0A()                                                                                                     **/
/** Tela de SubGrupo de Produtos									.                      **/
/**********************************************************************************************************************************/

user function KPEST0A()    
	
	
	private cCadastro := "[Cadastro - Canal]"
	private aRotina	:= {}


	//define os botoes da tela padrao
	aRotina := {{ "Pesquisar"	 ,"AxPesqui"	, 0 , 1},;
							{ "Visualizar" ,"AxVisual"	, 0 , 2},;
							{ "Incluir"		 ,"AxInclui"	, 0 , 3},; 
							{ "Alterar"		 ,"AxAltera"	, 0 , 4},;
							{ "Excluir"		 ,"AxDeleta"	, 0 , 5},;
							{ "Copiar"     ,"AxCopia"   , 0 , 6}}

  
	DBSELECTAREA("SZA")
	DBSETORDER(1)
	DBGOTOP()

  //monta tela padrao
	MBrowse(6, 1, 22, 75, "SZA", nil, nil, nil, nil, nil,)
	
return      
