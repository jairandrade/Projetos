
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
/** user function KPFATA05()                                                                                                     **/
/**Cadastro - Tipo de venda, sera usado para determinar o tempo que procedimento no pedido devera pedir justificativa           **/
/**********************************************************************************************************************************/

user function KPFATA05()    
	
	
	private cCadastro := "[Cadastro - Tipo de Venda ]"
	private aRotina	:= {}                            


	//define os botoes da tela padrao
	aRotina := {{ "Pesquisar"	 ,"AxPesqui"	, 0 , 1},;
							{ "Visualizar" ,"AxVisual"	, 0 , 2},;
							{ "Incluir"		 ,"AxInclui"	, 0 , 3},; 
							{ "Alterar"		 ,"AxAltera"	, 0 , 4},;
							{ "Excluir"		 ,"AxDeleta"	, 0 , 5},;
							{ "Copiar"     ,"AxCopia"   , 0 , 6}}

  
	DBSELECTAREA("SZ5")
	DBSETORDER(1)
	DBGOTOP()

  //monta tela padrao
	MBrowse(6, 1, 22, 75, "SZ5", nil, nil, nil, nil, nil,)
	
return    