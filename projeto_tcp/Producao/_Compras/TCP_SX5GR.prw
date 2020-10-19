#include 'protheus.ch'
#include 'parmtype.ch'

user function TCP_SX5GR()
	
	Local cFilter		:= "X5_TABELA = 'GR'"
	Private cCadastro 	:= "Cadastro de Grupos Empresariais"
	
	Private aRotina := { {"Pesquisar","AxPesqui",0,1},;
	                     {"Visualizar","AxVisual",0,2},;
	                     {"Incluir","AxInclui",0,3},;
	                     {"Alterar","AxAltera",0,4},;
	                     {"Excluir","AxDeleta",0,5}}
	
	Private cString := "SX5"
	
	dbSelectArea(cString)
	dbSetOrder(1)
	dbSetFilter({ || &(cFilter) }, cFilter ) // filtrar apenas a tabela de Grupos Empresariais
	
	mBrowse(6,1,22,75,cString)
	
    return

	