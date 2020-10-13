#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'


/*/{Protheus.doc} AWS011
//TODO Rotina para visualizar vendas
@author Mario L. B. Faria                    
@since 25/05/2018
@version 1.0
/*/
User Function AWS011()
 
	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("Z01")
	oBrowse:SetDescription("Vendas")
	oBrowse:SetMenuDef("MADERO_AWS011")
	oBrowse:Activate()

Return


Static Function MenuDef()

	Local aRotina := {}

	aAdd(aRotina,{'Visualizar'	,'VIEWDEF.MADERO_AWS011'	,0,2,0,NIL})
//	aAdd(aRotina,{'Incluir'		,'VIEWDEF.MADERO_AWS011'	,0,3,0,NIL})
//	aAdd(aRotina,{'Alterar'		,'VIEWDEF.MADERO_AWS011'	,0,4,0,NIL})
//	aAdd(aRotina,{'Excluir'		,'VIEWDEF.MADERO_AWS011'	,0,5,0,NIL})
//	aAdd(aRotina,{'Imprimir' 	,'VIEWDEF.MADERO_AWS011'	,0,8,0,NIL})
//	aAdd(aRotina,{'Copiar'		,'VIEWDEF.MADERO_AWS011'	,0,9,0,NIL})

Return( aRotina )


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Mario L. B. Faria

@since 05/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStr1 := FWFormStruct(1,'Z01')
	Local oStr2 := FWFormStruct(1,'Z02')
	Local oStr3 := FWFormStruct(1,'Z03')
	Local oStr4 := FWFormStruct(1,'Z04')

	oModel := MPFormModel():New('AWS011_MAIN')
	oModel:SetDescription('Vendas')
	oModel:addFields('MODEL_Z01',,oStr1)
	
	oModel:SetPrimaryKey({ 'Z01_FILIAL', 'Z01_CDEMP', 'Z01_CDFIL', 'Z01_SEQVDA', 'Z01_CAIXA', 'Z01_ENTREG' })
	
	oModel:addGrid('MODEL_Z02','MODEL_Z01',oStr2)
	oModel:addGrid('MODEL_Z03','MODEL_Z01',oStr3)
	oModel:addGrid('MODEL_Z04','MODEL_Z02',oStr4)
	
	oModel:getModel( 'MODEL_Z04' ):SetOptional( .T. )
	
	oModel:SetRelation('MODEL_Z02', { { 'Z02_FILIAL', 'xFilial("Z01")' }, { 'Z02_CDEMP', 'Z01_CDEMP' }, { 'Z02_CDFIL', 'Z01_CDFIL' }, { 'Z02_SEQVDA', 'Z01_SEQVDA' }, { 'Z02_CAIXA'  , 'Z01_CAIXA'   }, { 'Z02_ENTREG', 'Z01_ENTREG' } }, Z02->(IndexKey(1)) )
	oModel:SetRelation('MODEL_Z03', { { 'Z03_FILIAL', 'xFilial("Z01")' }, { 'Z03_CDEMP', 'Z01_CDEMP' }, { 'Z03_CDFIL', 'Z01_CDFIL' }, { 'Z03_SEQVDA', 'Z01_SEQVDA' }, { 'Z03_CAIXA'  , 'Z01_CAIXA'   }, { 'Z03_ENTREG', 'Z01_ENTREG' } }, Z03->(IndexKey(1)) )
	oModel:SetRelation('MODEL_Z04', { { 'Z04_FILIAL', 'xFilial("Z02")' }, { 'Z04_CDEMP', 'Z02_CDEMP' }, { 'Z04_CDFIL', 'Z02_CDFIL' }, { 'Z04_SEQVDA', 'Z02_SEQVDA' }, { 'Z04_ENTREG' , 'Z02_ENTREG'  }, { 'Z04_SEQIT'  , 'Z02_SEQIT' } }, Z04->(IndexKey(1)) )
	
	oModel:getModel('MODEL_Z02'):SetDescription('Itens')
	oModel:getModel('MODEL_Z03'):SetDescription('Condições de Pagamento')
	oModel:getModel('MODEL_Z04'):SetDescription('Produção')

	oStr1:SetProperty( 'Z01_CDEMP'	,MODEL_FIELD_INIT	,{|| U_INITEK("ADK_XEMP") })
	oStr1:SetProperty( 'Z01_CDFIL'	,MODEL_FIELD_INIT	,{|| U_INITEK("ADK_XFIL") })

	oStr1:SetProperty( 'Z01_ARQXML'	,MODEL_FIELD_WHEN	,{|oModel| oModel:GetOperation() == 3 })
	oStr1:SetProperty( 'Z01_CHVCAN'	,MODEL_FIELD_WHEN	,{|oModel| oModel:GetOperation() == 3 })
	oStr1:SetProperty( 'Z01_QRCODE'	,MODEL_FIELD_WHEN	,{|oModel| oModel:GetOperation() == 3 })
	oStr1:SetProperty( 'Z01_XSTINT'	,MODEL_FIELD_WHEN	,{|oModel| oModel:GetOperation() == 3 })
	oStr1:SetProperty( 'Z01_XDTERP'	,MODEL_FIELD_WHEN	,{|oModel| oModel:GetOperation() == 3 })
	oStr1:SetProperty( 'Z01_XHRERP'	,MODEL_FIELD_WHEN	,{|oModel| oModel:GetOperation() == 3 })
	oStr1:SetProperty( 'Z01_OBSNFC'	,MODEL_FIELD_WHEN	,{|oModel| oModel:GetOperation() == 3 })

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Mario L. B. Faria

@since 05/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView
	Local oModel	:= ModelDef()	 
	Local oStr1		:= FWFormStruct(2, 'Z01')
	Local oStr2		:= FWFormStruct(2, 'Z02')
	Local oStr3		:= FWFormStruct(2, 'Z03')
	Local oStr4		:= FWFormStruct(2, 'Z04')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField('VIEW_Z01' , oStr1,'MODEL_Z01' )
	oView:AddGrid('VIEW_Z02' , oStr2,'MODEL_Z02')
	oView:AddGrid('VIEW_Z03' , oStr3,'MODEL_Z03') 
	oView:AddGrid('VIEW_Z04' , oStr4,'MODEL_Z04') 
	  
	oView:CreateHorizontalBox( 'BOX_Z01', 40)
	oView:CreateHorizontalBox( 'BOX_ITEM', 40)
	oView:CreateHorizontalBox( 'BOX_COND', 20)
	
	oView:CreateVerticalBox( 'BOX_Z02', 60, 'BOX_ITEM')
	oView:CreateVerticalBox( 'BOX_Z04', 40, 'BOX_ITEM')
	
	oView:CreateVerticalBox( 'BOX_Z03', 100, 'BOX_COND')
	
	oView:SetOwnerView('VIEW_Z04','BOX_Z04')
	oView:SetOwnerView('VIEW_Z03','BOX_Z03')
	oView:SetOwnerView('VIEW_Z02','BOX_Z02')
	oView:SetOwnerView('VIEW_Z01','BOX_Z01')
	oView:AddIncrementField('VIEW_Z02' , 'Z02_SEQIT' ) 
	
	oView:EnableTitleView('VIEW_Z04' , 'Produção')
	oView:EnableTitleView('VIEW_Z03' , 'Condições de Pagamento')
	oView:EnableTitleView('VIEW_Z02' , 'Itens')
	oView:EnableTitleView('VIEW_Z01' , 'Vendas')
	
	oStr2:RemoveField( 'Z02_CAIXA' )
	oStr2:RemoveField( 'Z02_SEQVDA')
	oStr2:RemoveField( 'Z02_CDFIL' )
	oStr2:RemoveField( 'Z02_CDEMP' )
	
	oStr3:RemoveField( 'Z03_CAIXA' )
	oStr3:RemoveField( 'Z03_SEQVDA')
	oStr3:RemoveField( 'Z03_CDFIL' )
	oStr3:RemoveField( 'Z03_CDEMP' )
	
	oStr4:RemoveField( 'Z04_CDEMP' )
	oStr4:RemoveField( 'Z04_CDFIL' )
	oStr4:RemoveField( 'Z04_SEQVDA')
	oStr4:RemoveField( 'Z04_SEQIT' )


Return oView