/**********************************************************************************************************************************/
/** FATURAMENTO                                                                                                                  **/
/** Cadastro - Grupo de Vendas	                                                                                                 **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                       **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 13/08/2015 | Marcos Sulivan          | Criação da rotina/procedimento.                                                       **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"

/**********************************************************************************************************************************/
/** user function KPFATA07()                                                                                                     **/
/**Cadastro - Tipo de Porte de Cliente          **/
/**********************************************************************************************************************************/

user function KPFATA07()    
	
	
	private cCadastro := "[Cadastro - Porte de Cliente ]"
	private aRotina	:= {}                            


	//define os botoes da tela padrao
	aRotina := {{ "Pesquisar"	 ,"AxPesqui"	, 0 , 1},;
							{ "Visualizar" ,"AxVisual"	, 0 , 2},;
							{ "Incluir"		 ,"AxInclui"	, 0 , 3},; 
							{ "Alterar"		 ,"AxAltera"	, 0 , 4},;
							{ "Excluir"		 ,"AxDeleta"	, 0 , 5},;
							{ "Copiar"     ,"AxCopia"   , 0 , 6}}

  
	DBSELECTAREA("SZ7")
	DBSETORDER(1)
	DBGOTOP()

  //monta tela padrao
	MBrowse(6, 1, 22, 75, "SZ7", nil, nil, nil, nil, nil,)
	
return    