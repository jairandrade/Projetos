#include "protheus.ch"
#INCLUDE "FWMVCDEF.CH"

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} TCFIA001
//Rotina de Cadastro de solicitantes
@author Kaique Mathias
@since 25/10/2016
@version undefined
@type function
/*/
/*/
-------------------------------------------------------------------------------------*/

User Function TCFIA001()

    Local oMBrowse	:= Nil
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias('Z99') 
	oMBrowse:SetDescription("Cadastro de Solicitantes")
	oMBrowse:DisableDetails()
	oMBrowse:Activate() 

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

Return FWMVCMenu( 'TCFIA001' )

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

	Local oStruZ99 := FWFormStruct( 1, 'Z99' )
	Local oModel // Modelo de dados que sera? construi?do
	
	oModel := MPFormModel():New('TCFIA01M',/*bPreValid*/,{|oModel| fPosVld(oModel)},/*bCommit*/,/*bCancel*/)
	
	aAux := FwStruTrigger(	'Z99_USER'	  ,;
        'Z99_NOME'	  ,;
        'UsrFullName(M->Z99_USER)' ,;
        .F.				  ,;
        ''			  ,;
        0				  ,;
        '')

    oStruZ99:AddTrigger( 	aAux[1]  , ;  // [01] identificador (ID) do campo de origem
    aAux[2]  , ;  // [02] identificador (ID) do campo de destino
    aAux[3]  , ;  // [03] Bloco de código de validação da execução do gatilho
    aAux[4]  )    // [04] Bloco de código de execução do gatilho

	oModel:AddFields( 'Z99MASTER', /*cOwner*/, oStruZ99)
	oModel:SetDescription( 'Cadastro de solicitantes' )
	
	oStruZ99:SetProperty( "Z99_GRPAPR"  , MODEL_FIELD_WHEN  , { || M->Z99_ALTALC == "N" } )
	oStruZ99:SetProperty( "Z99_USER"	, MODEL_FIELD_VALID , { |x| fVldUser(x) } )
	oModel:GetModel( 'Z99MASTER' ):SetDescription( 'Dados de Cadastro de Solicitantes' )

	// Configura chave primária.
	oModel:SetPrimaryKey({"Z99_FILIAL", "Z99_CODIGO"})

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
	
	Local oModel := FWLoadModel( 'TCFIA001' )
	Local oStruZ99 := FWFormStruct( 2, 'Z99' )
	Local oView
	
	oView := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_Z99', oStruZ99, 'Z99MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_Z99', 'TELA' )

Return( oView )

Static Function fPosVld(oModel)
	
	Local lRet		:= .T.
	Local lAltAlc 	:= FwFldGet("Z99_ALTALC") == "S"
	Local cGrpApr	:= FwFldGet("Z99_GRPAPR")

	If ( !lAltAlc .And. Empty(cGrpApr) )
		Help( " ", 1, "GRPVAZIO",, "Existem campos obrigatorios não preenchidos. Campo: Grp. Aprov.", 1, 0 )
		lRet := .F.
	EndIf

Return( lRet )

Static Function fVldUser(oFld)

	Local lRet	:= .T.
	
	If !Empty(oFld:GetValue("Z99_USER"))
		lRet := UsrExist(oFld:GetValue("Z99_USER"))
	EndIf

	If lRet
		aAreaZ99:= Z99->(GetArea())
		Z99->(DbSetOrder(2))
		If Z99->(MsSeek(xFilial("Z99")+oFld:GetValue("Z99_USER")))
			lRet := .F.
			Help('',1,'TFIA1VLUSER',,'Usuario ja cadastrado',1,0) 
		EndIf
		RestArea(aAreaZ99)
	Endif

Return( lRet )