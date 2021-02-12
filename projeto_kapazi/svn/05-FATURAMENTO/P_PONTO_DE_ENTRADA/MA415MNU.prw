#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: MA415MNU 		|	Autor: Luis										|	Data: 14/03/2018//
//==================================================================================================//
//	Descri��o: Ponto de entrada disparado antes da abertura do Browse, caso Browse inicial da rotina// 
//esteja habilitado, ou antes da apresenta��o do Menu de op��es, caso Browse inicial esteja 		//
//desabilitado. Para habilitar ou desabilitar o Browse, entre na rotina, clique em Configura��es	//
//Browse Inicial e selecione a op��o desejada: Sim - Habilitar Browse Inicial N�o - Desabilitar 	//
//Browse Inicial. Este ponto de entrada pode ser utilizado para inserir novas op��es no array 		//
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