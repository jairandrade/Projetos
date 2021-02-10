#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

User Function CADZA6()
	Local oBrowse
	Private aRotina := MenuDef()
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZA6')
	oBrowse:SetDescription( 'Log de Integração Transportadoras X Protheus' )

	oBrowse:Activate()

Return NIL

//------------------------------------------------------------------- 
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar'      ACTION 'VIEWDEF.CADZA6' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'      ACTION 'VIEWDEF.CADZA6' OPERATION 8 ACCESS 0

Return aRotina

//------------------------------------------------------------------- 
Static Function ModelDef()

// Cria a estrutura a ser acrescentada no Modelo de Dados 
	Local oStruZA6 := FWFormStruct( 1, 'ZA6', /*bAvalCampo*/,/*lViewUsado*/ )

// Inicia o Model com um Model ja existente 
	Local oModel := FWLoadModel( 'VIEWZA6_MVC' )

// Adiciona a nova FORMFIELD 
	oModel:AddFields( 'ZA6MASTER', 'ZA6MASTER', oStruZA6 )

// Faz relacionamento entre os compomentes do model 
	oModel:SetRelation( 'ZA6MASTER', { { 'ZA6_FILIAL', 'xFilial( "ZA6" )' }, { 'ZA6_CODIGO', 'ZA6_CODIGO' } }, ZA6->( IndexKey( 1 ) ) )

Return oModel

//------------------------------------------------------------------- 
Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado 
	Local oModel := FWLoadModel( 'CADZA6' )

// Cria a estrutura a ser acrescentada na View 
	Local oStruZA6 := FWFormStruct( 2, 'ZA6' )

// Inicia a View com uma View ja existente 
	Local oView := FWLoadView( 'VIEWZA6_MVC' )

// Altera o Modelo de dados quer será utilizado 
	oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice) 
	oView:AddField( 'VIEW_ZA6', oStruZA6, 'ZA6MASTER' )

// É preciso criar sempre um box vertical dentro de um horizontal e vice-versa 
// como na VIEWZA6_MVC o box é horizontal, cria-se um vertical primeiro 
// Box existente na interface original 
	oView:CreateVerticallBox( 'TELANOVA' , 100, 'TELA' )

// Novos Boxes 
	oView:CreateHorizontalBox( 'SUPERIOR' , 20, 'TELANOVA' )
	oView:CreateHorizontalBox( 'INFERIOR' , 80, 'TELANOVA' )

// Relaciona o identificador (ID) da View com o "box" para exibicao 
	oView:SetOwnerView( 'VIEW_ZA6', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_ZA6', 'INFERIOR' )

Return oView
