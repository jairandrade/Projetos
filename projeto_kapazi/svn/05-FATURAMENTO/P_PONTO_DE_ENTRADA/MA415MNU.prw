#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: MA415MNU 		|	Autor: Luis										|	Data: 14/03/2018//
//==================================================================================================//
//	Descrição: Ponto de entrada disparado antes da abertura do Browse, caso Browse inicial da rotina// 
//esteja habilitado, ou antes da apresentação do Menu de opções, caso Browse inicial esteja 		//
//desabilitado. Para habilitar ou desabilitar o Browse, entre na rotina, clique em Configurações	//
//Browse Inicial e selecione a opção desejada: Sim - Habilitar Browse Inicial Não - Desabilitar 	//
//Browse Inicial. Este ponto de entrada pode ser utilizado para inserir novas opções no array 		//
//aRotina.																							//
//==================================================================================================//
User Function MA415MNU()
Local aArea		:= GetArea()
Local aRotAdd	:={}

aRotAdd :=	{	{ "Posicao do cliente"	, "U_KAPPOSCL()" , 0 , 2},; //"Baixar"
				{ "Cadastro de cliente"	, "U_KAPCADCL()" , 0 , 2},; //"Lote"
				{ "Aprovacao de credito", "U_KAPAPRCR()" , 0 , 2}} //"Excluir Baixa"

//Adiciona a rotina
aAdd( aRotina,	{ "Financeiro",aRotAdd, 0 , 2})

RestArea(aArea)	
Return()