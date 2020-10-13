#include 'protheus.ch'
#include 'parmtype.ch'


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! AWS005                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Cadastro de Clientes x unidades de negócio                                    !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 10/04/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                

User Function AWS005()
Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("Z11")
	oBrowse:SetDescription("Clientes x Unidades")
	oBrowse:SetMenuDef("MADERO_AWS005")
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aAdd(aRotina,{'Visualizar'	,'VIEWDEF.MADERO_AWS005'	,0,2,0,NIL})
//	aAdd(aRotina,{'Incluir'		,'VIEWDEF.MADERO_AWS005'	,0,3,0,NIL})
//	aAdd(aRotina,{'Alterar'		,'VIEWDEF.MADERO_AWS005'	,0,4,0,NIL})
//	aAdd(aRotina,{'Excluir'		,'VIEWDEF.MADERO_AWS005'	,0,5,0,NIL})
//	aAdd(aRotina,{'Imprimir' 	,'VIEWDEF.MADERO_AWS005'	,0,8,0,NIL})
//	aAdd(aRotina,{'Copiar'		,'VIEWDEF.MADERO_AWS005'	,0,9,0,NIL})

Return( aRotina )

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ModelDef                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Modelo padrão                                                                 !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                

Static Function ModelDef()
Local oModel 
Local oStr1:= FWFormStruct(1,'Z11')
	
	oModel:=MPFormModel():New('MAIN_AWS005')
	oModel:SetDescription('Clientes x Unidades')
	oModel:addFields('MODEL_Z11',,oStr1)
	oModel:SetPrimaryKey({ 'Z11_FILIAL', 'Z11_COD', 'Z11_LOJA' })

Return oModel

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ViewDef                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Visão padrão                                                                 !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1:= FWFormStruct(2, 'Z11')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_Z11' , oStr1,'MODEL_Z11' ) 
	oView:CreateHorizontalBox( 'BOX_Z11', 100)
	oView:SetOwnerView('VIEW_Z11','BOX_Z11')

Return oView