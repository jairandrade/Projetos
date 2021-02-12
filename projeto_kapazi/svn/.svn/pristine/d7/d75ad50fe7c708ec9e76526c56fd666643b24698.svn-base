/**********************************************************************************************************************************/
/** FATURAMENTO                                                                                                              **/
/** Cadastro - Grupo de Vendas	                                                                                           **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 07/06/2015 | Marcos Sulivan          | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"

/**********************************************************************************************************************************/
/** user function KPFATA03()                                                                                                     **/
/**Cadastro - Grupo de Vendas									.                      **/
/**********************************************************************************************************************************/

user function KPFATA03()    
	
	
	private cCadastro := "[Cadastro - Grupo de Vendas ]"
	private aRotina	:= {}                            '


	//define os botoes da tela padrao
	aRotina := {{ "Pesquisar"	 ,"AxPesqui"	, 0 , 1},;
							{ "Visualizar" ,"AxVisual"	, 0 , 2},;
							{ "Incluir"		 ,"AxInclui"	, 0 , 3},; 
							{ "Alterar"		 ,"AxAltera"	, 0 , 4},;
							{ "Excluir"		 ,"AxDeleta"	, 0 , 5},;
							{ "Copiar"     ,"AxCopia"   , 0 , 6}}

  
	DBSELECTAREA("SZ4")
	DBSETORDER(1)
	DBGOTOP()

  //monta tela padrao
	MBrowse(6, 1, 22, 75, "SZ4", nil, nil, nil, nil, nil,)
	
return      