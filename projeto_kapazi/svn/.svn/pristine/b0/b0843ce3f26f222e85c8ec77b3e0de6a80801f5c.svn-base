#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

User Function CADWSKAP()
    Local oBrowse := FwLoadBrw("CADWSKAP")

    oBrowse:Activate()
Return (NIL)

Static Function BrowseDef()
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias("Z09")
    oBrowse:SetDescription("Cadastro de Endpoints")

   oBrowse:SetMenuDef("CADWSKAP")
Return (oBrowse)


Static Function MenuDef()
    Local aRotina := FwMVCMenu("CADWSKAP")
Return (aRotina)


Static Function ModelDef()
    Local oModel := MPFormModel():New("ATRIBS")

    Local oStruZ09 := FwFormStruct(1, "Z09")
    Local oStruZ08 := FwFormStruct(1, "Z08")

    oStruZ08:SetProperty('Z08_CODIGO', MODEL_FIELD_OBRIGAT , .F.)

    oModel:AddFields("Z09MASTER", NIL, oStruZ09)
    oModel:AddGrid("Z08DETAIL", "Z09MASTER", oStruZ08)

	oModel:SetPrimaryKey({'Z09_FILIAL','Z09_CODIGO'})

    oModel:SetRelation("Z08DETAIL", {{"Z08_FILIAL", "FwXFilial('Z08')"}, {"Z08_CODIGO", "Z09_CODIGO"}},Z08->(IndexKey( 1 )))

    oModel:SetDescription("Cadastro de Endpoints" )

    oModel:GetModel("Z09MASTER"):SetDescription("Cadastro de endpoints")
    oModel:GetModel("Z08DETAIL"):SetDescription("Atributos do endpoint")

Return (oModel)


Static Function ViewDef()

    Local oView := FwFormView():New()
    Local oStruZ09 := FwFormStruct(2, "Z09")
    Local oStruZ08 := FwFormStruct(2, "Z08")
    Local oModel := FwLoadModel("CADWSKAP")

    oView:SetModel(oModel)

    oView:AddField("VIEW_Z09", oStruZ09, "Z09MASTER")
    oView:AddGrid("VIEW_Z08", oStruZ08, "Z08DETAIL")

    oView:CreateHorizontalBox("SUPERIOR", 15)
    oView:CreateHorizontalBox("INFERIOR", 85)

    oView:SetOwnerView("VIEW_Z09", "SUPERIOR")
    oView:SetOwnerView("VIEW_Z08", "INFERIOR")

    oView:AddIncrementField("VIEW_Z08", "Z08_ITEM")

    oView:EnableTitleView("VIEW_Z08","Atributos")

    oStruZ08:RemoveField( 'Z08_CODIGO' )
Return (oView)
