#include "totvs.ch"
#include "fwmvcdef.ch"

user Function TEST02_MVC()

Local oMark

//estanciamento da classe mark
oMark := FWMarkBrowse():New()

//tabela que sera utilizada
oMark:SetAlias( "SC9" )

//Titulo
oMark:SetDescription( "Browse de Marcação" )

//campo que recebera a marca
oMark:SetFieldMark( "C9_OK" )

//Ativa
oMark:Activate()

Return
