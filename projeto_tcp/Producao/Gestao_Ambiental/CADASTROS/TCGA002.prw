#include "totvs.ch"
#include "fwmvcdef.ch"

Static cCadastro := "Manutenção de Fornecedores de Produtos Quimicos"

/*/{Protheus.doc} User Function TCGA002
Função responsavel por montar a tela de fornecedores de produtos quimicos
@type  Function
@author Kaique Mathias
@since 18/08/2020
@version 1.0
/*/

User Function TCGA002()

    Local oBrowse

    oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "SA2" )
	oBrowse:SetDescription( cCadastro )
	oBrowse:SetMenuDef("TCGA002")
	oBrowse:AddLegend("Empty(A2_XVLDHOM)"                                           						,"BR_VERMELHO" ,"Não Homologado")
	oBrowse:AddLegend("!Empty(A2_XVLDHOM) .And. A2_XVLDHOM < Date() .And. Date()-A2_XVLDHOM > 90 "          ,"BR_PRETO"    ,"Vencido")
	oBrowse:AddLegend("!Empty(A2_XVLDHOM) .And. Date()>A2_XVLDHOM .And. Date()-A2_XVLDHOM <= 90"          	,"BR_AMARELO"  ,"Vencido no prazo")
    oBrowse:AddLegend("!Empty(A2_XVLDHOM) .And. A2_XVLDHOM >= Date()"               						,"BR_VERDE"    ,"Homologado")
	
	oBrowse:Activate()

Return( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional

@return aRotina - Estrutura
            [n,1] Nome a aparecer no cabecalho
            [n,2] Nome da Rotina associada
            [n,3] Reservado
            [n,4] Tipo de Transação a ser efetuada:
                1 - Pesquisa e Posiciona em um Banco de Dados
                2 - Simplesmente Mostra os Campos
                3 - Inclui registros no Bancos de Dados
                4 - Altera o registro corrente
                5 - Remove o registro corrente do Banco de Dados
                6 - Alteração sem inclusão de registros
                7 - Copia
                8 - Imprimir
            [n,5] Nivel de acesso
            [n,6] Habilita Menu Funcional
/*/
//-------------------------------------------------------------------

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title "Alterar"    Action 'VIEWDEF.TCGA002' OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TCGA002' OPERATION MODEL_OPERATION_VIEW   ACCESS 0

Return( aRotina )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
//Modelo de dados do cadastro de solicitantes
@author Kaique Mathias
@since 25/10/2016
@version undefined
@type static function
/*/
// -------------------------------------------------------------------------------------

Static Function ModelDef()
	
	Local oModel
	Local oStructSA2  	:= fGetStruSA2(1)
	
	oModel := MPFormModel():New('TCGA002M')
	oModel:AddFields( 'SA2MASTER', /*cOwner*/, oStructSA2)
	oModel:GetModel("SA2MASTER"):SetDescription( cCadastro )
	
	oStructSA2:SetProperty( "A2_COD"  , MODEL_FIELD_WHEN  , { || .F. } )
	oStructSA2:SetProperty( "A2_LOJA" , MODEL_FIELD_WHEN  , { || .F. } )
    oStructSA2:SetProperty( "A2_NOME" , MODEL_FIELD_WHEN  , { || .F. } )
    oStructSA2:SetProperty( "A2_CGC"  , MODEL_FIELD_WHEN  , { || .F. } )
    oStructSA2:SetProperty( "A2_END"  , MODEL_FIELD_WHEN  , { || .F. } )
	
	// Configura chave primária.
	oModel:SetPrimaryKey({"A2_FILIAL", "A2_COD"})

Return( oModel )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface da rotina
@author: Kaique Mathias
@since: 20/02/2013
@Uso: TCFIA001
/*/
// -------------------------------------------------------------------------------------

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStructSA2  	:= fGetStruSA2(2)

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oStructSA2:SetProperty( "A2_CGC", MVC_VIEW_PVAR, FwBuildFeature( STRUCT_FEATURE_PICTVAR, "" ) )
	oView:AddField( 'VIEW_SA2', oStructSA2, 'SA2MASTER' )
	//oView:AddOtherObject("VIEW_LOG",{|oPanel| ViewLog(oPanel)},{|oPanel| If(ValType(oPanel) == "O", oPanel:FreeChildren(), )},)
	oView:CreateHorizontalBox( 'TELA', 060 )
	//oView:CreateHorizontalBox( 'LOG' , 040 )
	
	oView:EnableTitleView("VIEW_SA2", "Dados do Forncedor")
	//oView:EnableTitleView("VIEW_LOG", "Histórico de Alterações")

	oView:SetOwnerView( 'VIEW_SA2', 'TELA' )
	//oView:SetOwnerView( 'VIEW_LOG', 'LOG' )

Return( oView )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao responsavel por retornar a estrutura dos campos que irao compor a View/Model.
@author: Kaique Mathias
@since: 20/02/2013
@Uso: TCFIA001
/*/
// -------------------------------------------------------------------------------------

Static Function fGetStruSA2(nOpc)
	Local oStru  	:= FWFormStruct(nOpc,'SA2', {|campo| alltrim(campo) $ 'A2_FILIAL#A2_COD#A2_LOJA#A2_NOME#A2_CGC#A2_END#A2_XHOMOL#A2_XVLDHOM' } )
Return( oStru )

/*/{Protheus.doc} getColumns
Funcao responsavel por retornar a estrutura dos campos que irao compor a View/Model.
@author: Kaique Mathias
@since: 20/02/2013
@Uso: TCFIA001
/*/

Static Function ViewLog( oPanel )

	Local aTabela    := { 'SA2', 'SA2' }
	Local cFilter    := "(TMP_FIELD = 'A2_XVLDHOM' AND OPERATI = 'U' AND TMP_PROGRAM = 'TCGA002')"
	Local cOrdem 	 := "TMP_DTIME DESC"

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( "123" ) //-- "Histrico de Alteraes de Assunto Jurdico / Processos"
	oBrowse:SetLocate()	

	cAliasLog := FwATTViewLog( aTabela, cFilter /*, cOrdem,,CTOD('01/01/1989'),Date() */)
	//cQry := " SELECT * FROM SA2020_TTAT_LOG WHERE TMP_FIELD = 'A2_XVLDHOM' AND TMP_OPERATI = 'U' AND TMP_PROGRAM = 'TCGA002'"
	If !Empty( cAliasLog )		
		
		( cAliasLog )->( DbGotop() )		
		/*
		oBrwLog := FWBrowse():New()
		oBrwLog:SetOwner(oPanel)
		oBrwLog:SetDataTable(.T.)
		//oBrwLog:SetDataQuery(.F.)
		oBrwLog:SetAlias(cAliasLog)
		//oBrwLog:SetTemporary(.T.)
		//oBrwLog:SetQuery( cQry )
		oBrwLog:SetColumns( getColumns() )
		//oBrwLog:SetUseFilter(.F.)
		//oBrwLog:SetSeek()
		//oBrwLog:SetProfileID("oBrwLog")
		//oBrwLog:SetClrAlterRow(RGB(241, 241, 241))

		//Desabilita componentes do Browse
		oBrwLog:DisableReports()
		//oBrwLog:DisableConfig()
		//oBrwLog:DisableDetails()
		oBrwLog:Activate()
		//oBrwLog:UpdateBrowse(.t.)
		oBrwLog:Refresh()
		//oBrwLog:oFwFilter:DisableAdd()
		//oBrwLog:oFwFilter:DisableDel()
		//oBrwLog:oFwFilter:DisableExecute()
		//oBrwLog:oFwFilter:DisableSave()
		FwATTDropLog(cAliasLog)*/

		oBrowse:SetAlias( cAliasLog )			
		oBrowse:SetOwner(oPanel)
		oBrowse:SetUseFilter( .F. )
		oBrowse:AddButton( "Visualizar" ,,, 2 )	//-- Visualizar
		oBrowse:ForceQuitButton( .T. ) 
		oBrowse:SetDataTable()	
		oBrowse:Activate()
	EndIf

Return( Nil )

/*/{Protheus.doc} getColumns
Funcao responsavel por retornar a estrutura dos campos que irao compor a View/Model.
@author: Kaique Mathias
@since: 20/02/2013
@Uso: TCFIA001
/*/

Static Function getColumns()

	Local aCpoLog := {}
	Local aColumns:= {}
	Local oColumn
	Local nX	  := 0

	/* Colunas do Browse */ 	
	aAdd( aCpoLog, { "TMP_USER",    "Usuario", 35  } )	
	aAdd( aCpoLog, { "TMP_DTIME",   "Data / Horario", 22  } )	
	aAdd( aCpoLog, { "TMP_FIELD",   "Campo", 10  } )	
	aAdd( aCpoLog, { "TMP_COLD",    "Dado Antigo", 100 } )
	aAdd( aCpoLog, { "TMP_CNEW" ,   "Dado Novo", 100 } )
	
	For nX := 1 To Len( aCpoLog )
		oColumn := FWBrwColumn():New()
		oColumn:SetData( &( "{|| " + aCpoLog[nX][1] + " }" ) )
		oColumn:SetTitle( aCpoLog[nX][2] )
		oColumn:SetSize( aCpoLog[nX][3] )
		aAdd(aColumns,oColumn)
	Next nX
	
Return( aColumns )
