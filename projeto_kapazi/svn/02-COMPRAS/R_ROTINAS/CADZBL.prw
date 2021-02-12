#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: CADZBL		|	Autor: Luis Paulo							|	Data: 03/11/2019	//
//==================================================================================================//
//	Descrição: Cadastro de bloqueios																//
//																									//
//==================================================================================================//
User Function CADZBL()
Local cAlias 		:= "ZBL"
Private cCadastro 	:= "Cadastro de Bloqueios"
Private aRotina     := { }


AADD(aRotina, { "Pesquisar"		, "AxPesqui"	, 0, 1 })
AADD(aRotina, { "Visualizar"	, "AxVisual"  	, 0, 2 })
AADD(aRotina, { "Incluir"      	, "AxInclui"   	, 0, 3 })
AADD(aRotina, { "Alterar"     	, "AxAltera"  	, 0, 4 })
AADD(aRotina, { "Excluir"     	, "AxDeleta" 	, 0, 5 })

DbSelectArea(cAlias)
DbSetOrder(1)
mBrowse(6, 1, 22, 75, cAlias)

	
Return()