//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Vari�veis Est�ticas
Static cTitulo := " Cadastro Arrays Layout JSon Integra WMS"

/*/{Protheus.doc} CADZA4
Modelo2 para Cadastro de Arrays do Layout JSon Integra��o CyberLog
@author Carlos CLeuber
@since 07/12/2020
@version 1.0
/*/
User Function CADZA4()
	Local aArea   := GetArea()
	Local oBrowse

	//Private aRotina:= MenuDef()
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZA4")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetMenuDef("ZANLORENZI_CADZA4")
	oBrowse:DisableDetails()
	oBrowse:Activate()
	
	RestArea(aArea)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do Menu

@author Carlos Cleuber
@since 07/12/2020
@version 1.0
/*/
Static Function MenuDef()
	Local aRot := {}
	
	//Adicionando op��es
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ZANLORENZI_CADZA4' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.ZANLORENZI_CADZA4' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ZANLORENZI_CADZA4' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.ZANLORENZI_CADZA4' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados

@author Carlos Cleuber
@since 07/12/2020
@version 1.0
/*/
Static Function ModelDef()
	Local oModel   := Nil
	Local oStruZA41 := FWFormStruct(1, 'ZA4')
	Local oStruZA42 := FWFormStruct(1, 'ZA4')
	Local aRelation:= {}

	oModel := MPFormModel():New('MdlZA4', /*bPreValidacao*/, { | oModel | MVC001V( oModel ) } , /*{ | oMdl | MVC001C( oMdl ) }*/ ,, /*bCancel*/ )

	oStruZA41:removeField("ZA4_FILIAL")
	oStruZA41:removeField("ZA4_ORDEM")
	oStruZA41:removeField("ZA4_TIPTAG")
	oStruZA41:removeField("ZA4_TAG")
	oStruZA41:removeField("ZA4_TPDADO")
	oStruZA41:removeField("ZA4_TAMANH")
	oStruZA41:removeField("ZA4_DECIMA")
	oStruZA41:removeField("ZA4_CONTEU")
	oStruZA41:removeField("ZA4_CODARR")

	oStruZA42:removeField("ZA4_FILIAL")
	oStruZA42:removeField("ZA4_COD")
	oStruZA42:removeField("ZA4_DESC")
	oStruZA42:removeField("ZA4_LAYPAI")
	oStruZA42:removeField("ZA4_TAGPAI")
	//oStruZA42:SetProperty('ZA4_DESC'	, MODEL_FIELD_OBRIGAT, { || .F. } )
	
	oModel:AddFields("ZA4CAB",/*cOwner*/,oStruZA41)
	oModel:AddGrid('ZA4GRID','ZA4CAB',oStruZA42)
	
	//Adiciona o relacionamento de Filho, Pai
	aAdd(aRelation, {'ZA4_FILIAL', 'Iif(!INCLUI, ZA4_FILIAL, FWxFilial("ZA4"))'} )
	aAdd(aRelation, {'ZA4_COD', 'Iif(!INCLUI, ZA4_COD, ZA4_COD  )'} ) 
	
	//Criando o relacionamento
	oModel:SetRelation('ZA4GRID', aRelation, ZA4->(IndexKey(2)))
	
	//Setando o campo �nico da grid para n�o ter repeti��o
	oModel:GetModel('ZA4GRID'):SetUniqueLine({"ZA4_TAG"})
	
	//Setando outras informa��es do Modelo de Dados
	oModel:SetDescription(cTitulo)
	oModel:SetPrimaryKey({})
	oModel:GetModel("ZA4CAB"):SetDescription("Dados do Array")

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do interface

@author Carlos Cleuber
@since 07/12/2020
@version 1.0
/*/
Static Function ViewDef()
	Local oModel    := ModelDef()
	Local oView  	:= FWFormView():New()
	Local oStruZA41  := FWFormStruct(2, 'ZA4')
	Local oStruZA42  := FWFormStruct(2, 'ZA4')

	oStruZA41:removeField("ZA4_FILIAL")
	oStruZA41:removeField("ZA4_ORDEM")
	oStruZA41:removeField("ZA4_TIPTAG")
	oStruZA41:removeField("ZA4_TAG")
	oStruZA41:removeField("ZA4_TPDADO")
	oStruZA41:removeField("ZA4_TAMANH")
	oStruZA41:removeField("ZA4_DECIMA")
	oStruZA41:removeField("ZA4_CONTEU")
	oStruZA41:removeField("ZA4_CODARR")

	oStruZA42:removeField("ZA4_FILIAL")
	oStruZA42:removeField("ZA4_COD")
	oStruZA42:removeField("ZA4_DESC")
	oStruZA42:removeField("ZA4_LAYPAI")
	oStruZA42:removeField("ZA4_TAGPAI")	
	
	//Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
	oView:SetModel(oModel)

	oView:AddField("VIEW_ZA41", oStruZA41, "ZA4CAB")
	oView:AddGrid('VIEW_ZA42' , oStruZA42, "ZA4GRID")
	oView:AddIncrementField('VIEW_ZA42', 'ZA4_ORDEM')
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CAMPOS',35)
	oView:CreateHorizontalBox('GRID',65)
	
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_ZA41','CAMPOS')
	oView:SetOwnerView('VIEW_ZA42','GRID')
	
	//Habilitando t�tulo
	oView:EnableTitleView('VIEW_ZA41')
	oView:EnableTitleView('VIEW_ZA42')
	
Return oView

/*/{Protheus.doc} MVC001V
//TODO
@description Valida��o Dados ao incluir/alterar
@author Carlos Cleuber
@since 07/12/2020
@version 1.0
@param oModel, object, descricao
@type function
/*/
Static Function MVC001V( oModel )

	Local lRet      := .T.

	FwModelActive( oModel, .T. )

Return lRet

