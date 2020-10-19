#include "totvs.ch"
#include "fwmvcdef.ch"

Static cCadastro := "Manutenção de Produtos Quimicos"

/*/{Protheus.doc} User Function TCGA001
Função responsavel por montar a tela de produtos quimicos
@type  Function
@author Kaique Mathias
@since 18/08/2020
@version 1.0
/*/
User Function TCGA001()

    Local oBrowse

    oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "SB1" )
	oBrowse:SetDescription( cCadastro )
	oBrowse:SetMenuDef("TCGA001")
	oBrowse:Activate()

Return( Nil )

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title "Alterar"    Action 'VIEWDEF.TCGA001' OPERATION MODEL_OPERATION_UPDATE   ACCESS 0
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TCGA001' OPERATION MODEL_OPERATION_VIEW   ACCESS 0

Return( aRotina )

Static Function ModelDef()
	
	Local oModel
	Local oStructSB1  	:= fGetStruSB1(1)
	Local oModelEvent   := TCGA001EVDEF():New()
	
	oModel := MPFormModel():New('TCGA001M')
	oModel:AddFields( 'SB1MASTER', /*cOwner*/, oStructSB1)
	oModel:SetDescription( cCadastro )
	
	oStructSB1:SetProperty( "B1_COD"  , MODEL_FIELD_WHEN  , { || .F. } )
	oStructSB1:SetProperty( "B1_DESC" , MODEL_FIELD_WHEN  , { || .F. } )
	
	oModel:InstallEvent("oModelEvent",,oModelEvent)

	// Configura chave primária.
	oModel:SetPrimaryKey({"B1_FILIAL", "B1_COD"})

Return( oModel )

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStructSB1  	:= fGetStruSB1(2)

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( 'VIEW_SB1', oStructSB1, 'SB1MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SB1', 'TELA' )

Return( oView )

Static Function fGetStruSB1(nOpc)
	Local oStru  	:= FWFormStruct(nOpc,'SB1', {|campo| alltrim(campo) $ 'B1_FILIAL#B1_COD#B1_DESC#B1_XNIVEL#B1_XQUIMI' } )
Return( oStru )
