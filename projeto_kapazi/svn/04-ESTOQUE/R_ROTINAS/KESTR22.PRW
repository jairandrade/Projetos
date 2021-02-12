#include "protheus.ch"

/*
    Funcao para cadastro da tabela Z05 do Edi Ocorre.
*/

User Function KESTR22()
    Local   aArea       := GetArea()
    Local   cTab        := "Z05"
    Local 	oBrowse

    Private aRotina     := MenuDef()
    Private	cCadastro	:= "Cadastro Ocorrencias Padrão EDI Ocorre"

    aRotina := MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cTab)
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetDescription(cCadastro)
	oBrowse:Activate()

	RestArea(aArea)
Return

Static Function MenuDef()
	// array
	Local aRot 		:= {}
	
	aRot :={{"Pesquisar"		,"AxPesqui"		, 0 , 1, 0 , .F.},;
			{"Visualizar"		,"AxVisual"		, 0 , 2, 0 , nil},;
			{"Incluir"			,"AxInclui"		, 0 , 3, 0 , nil},;
			{"Alterar"			,"AxAltera"		, 0 , 4, 0 , nil},;
			{"Excluir"			,"AxExclui"		, 0 , 5, 0 , nil}}
	
	// retorna o array
Return aRot