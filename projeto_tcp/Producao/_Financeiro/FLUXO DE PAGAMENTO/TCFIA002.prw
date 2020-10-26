#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} TCFIA002
//Rotina de Solicitação de pagamento
@author Kaique Mathias
@since 25/10/2016
@version 1.0
@type user function
/*/
/*/
-------------------------------------------------------------------------------------*/

User Function TCFIA002()

	Local oMBrowse	:= Nil
	Local cFilBrw   := fFilDef()
	Private aRotina := MenuDef()

	If !fVldUser()
		Return( Nil )
	EndIf

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias('ZA0')
	oMBrowse:SetDescription("Solicitação de Pagamento")
	oMBrowse:AddLegend( "ZA0_STATUS == '1'", "GREEN", "Pendente" )
	oMBrowse:AddLegend( "ZA0_STATUS == '2'", "BLUE" , "Aprovado" )
	oMBrowse:AddLegend( "ZA0_STATUS == '3'", "RED"  , "Reprovado" )
	oMBrowse:AddLegend( "ZA0_STATUS == '9'", "BLACK", "Cancelado" )
	oMBrowse:SetCacheView(.F.)
	oMBrowse:SetFilterDefault(cFilBrw)
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

	Local aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar"   ACTION 'VIEWDEF.TCFIA002' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"      ACTION 'VIEWDEF.TCFIA002' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION 'VIEWDEF.TCFIA002' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Cancelar"     ACTION 'U_TFIA02CANC'     OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Anexos"       ACTION 'MSDOCUMENT'       OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Relatorio"    ACTION 'U_TCFIR001'       OPERATION 8 ACCESS 0

Return( aRotina )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
//Modelo de dados do cadastro de solicitantes
@author Kaique Mathias
@since 25/10/2016
@version 1.0
@type static function
/*/
// -------------------------------------------------------------------------------------

Static Function ModelDef()

	Local oStruZA0      := FWFormStruct( 1, 'ZA0' )
	Local oStruZA2      := FWFormStruct( 1, 'ZA2' )
	Local oStruZA3      := FWFormStruct( 1, 'ZA3' )
	Local oModel // Modelo de dados que sera? construi?do
	Local oModelEvent   := TCFIA002EVDEF():New()

	oModel := MPFormModel():New( "TCFIA02M" )

	aAux := FwStruTrigger(	'ZA0_CLIFOR'	  ,;
		'ZA0_NOME'	  ,;
		'SA2->A2_NREDUZ' ,;
		.T.				  ,;
		'SA2'			  ,;
		1				  ,;
		'xFilial("SA2")+M->ZA0_CLIFOR')

	oStruZA0:AddTrigger( 	aAux[1]  , ;  // [01] identificador (ID) do campo de origem
	aAux[2]  , ;  // [02] identificador (ID) do campo de destino
	aAux[3]  , ;  // [03] Bloco de código de validação da execução do gatilho
	aAux[4]  )    // [04] Bloco de código de execução do gatilho

	aAux := FwStruTrigger(	'ZA0_CLIFOR'	  ,;
		'ZA0_LOJA'	  ,;
		'SA2->A2_LOJA' ,;
		.T.				  ,;
		'SA2'			  ,;
		1				  ,;
		'xFilial("SA2")+M->ZA0_CLIFOR')

	oStruZA0:AddTrigger( 	aAux[1]  , ;  // [01] identificador (ID) do campo de origem
	aAux[2]  , ;  // [02] identificador (ID) do campo de destino
	aAux[3]  , ;  // [03] Bloco de código de validação da execução do gatilho
	aAux[4]  )    // [04] Bloco de código de execução do gatilho

	aAux := FwStruTrigger(	'ZA2_NATURE'	  ,;
		'ZA2_DESCRI'	  ,;
		'SED->ED_DESCRIC' ,;
		.T.				  ,;
		'SED'			  ,;
		1				  ,;
		'xFilial("SED")+M->ZA2_NATURE')

	oStruZA2:AddTrigger( 	aAux[1]  , ;  // [01] identificador (ID) do campo de origem
	aAux[2]  , ;  // [02] identificador (ID) do campo de destino
	aAux[3]  , ;  // [03] Bloco de código de validação da execução do gatilho
	aAux[4]  )    // [04] Bloco de código de execução do gatilho

	aAux := FwStruTrigger(	'ZA2_PERC'	  ,;
		'ZA2_VLRNAT'	  ,;
		'U_TFI02VNAT(1)' ,;
		.F.				  ,;
		' '			  ,;
		0				  ,;
		' ')

	oStruZA2:AddTrigger( 	aAux[1]  , ;  // [01] identificador (ID) do campo de origem
	aAux[2]  , ;  // [02] identificador (ID) do campo de destino
	aAux[3]  , ;  // [03] Bloco de código de validação da execução do gatilho
	aAux[4]  )    // [04] Bloco de código de execução do gatilho

	aAux := FwStruTrigger(	'ZA2_VLRNAT'	  ,;
		'ZA2_PERC'	  ,;
		'U_TFI02VNAT(2)' ,;
		.F.				  ,;
		' '			  ,;
		0				  ,;
		' ')

	oStruZA2:AddTrigger( 	aAux[1]  , ;  // [01] identificador (ID) do campo de origem
	aAux[2]  , ;  // [02] identificador (ID) do campo de destino
	aAux[3]  , ;  // [03] Bloco de código de validação da execução do gatilho
	aAux[4]  )    // [04] Bloco de código de execução do gatilho

	aAux := FwStruTrigger(	'ZA2_VLRNAT'	  ,;
		'ZA2_VLRNAT'	  ,;
		'U_TFI02VCC(0)' ,;
		.F.				  ,;
		' '			  ,;
		0				  ,;
		' ')

	oStruZA2:AddTrigger( 	aAux[1]  , ;  // [01] identificador (ID) do campo de origem
	aAux[2]  , ;  // [02] identificador (ID) do campo de destino
	aAux[3]  , ;  // [03] Bloco de código de validação da execução do gatilho
	aAux[4]  )    // [04] Bloco de código de execução do gatilho

	aAux := FwStruTrigger(	'ZA3_CC'	  ,;
		'ZA3_DESCC'	  ,;
		'CTT->CTT_DESC01' ,;
		.T.				  ,;
		'CTT'			  ,;
		1				  ,;
		'xFilial("CTT")+M->ZA3_CC')

	oStruZA3:AddTrigger( 	aAux[1]  , ;  // [01] identificador (ID) do campo de origem
	aAux[2]  , ;  // [02] identificador (ID) do campo de destino
	aAux[3]  , ;  // [03] Bloco de código de validação da execução do gatilho
	aAux[4]  )    // [04] Bloco de código de execução do gatilho

	aAux := FwStruTrigger(	'ZA3_PERC'	  ,;
		'ZA3_VLRRAT'	  ,;
		'U_TFI02VCC(1)' ,;
		.F.				  ,;
		' '			  ,;
		0				  ,;
		' ')

	oStruZA3:AddTrigger( 	aAux[1]  , ;  // [01] identificador (ID) do campo de origem
	aAux[2]  , ;  // [02] identificador (ID) do campo de destino
	aAux[3]  , ;  // [03] Bloco de código de validação da execução do gatilho
	aAux[4]  )    // [04] Bloco de código de execução do gatilho

	aAux := FwStruTrigger(	'ZA3_VLRRAT'	  ,;
		'ZA3_PERC'	  ,;
		'U_TFI02VCC(2)' ,;
		.F.				  ,;
		' '			  ,;
		0				  ,;
		' ')

	oStruZA3:AddTrigger( 	aAux[1]  , ;  // [01] identificador (ID) do campo de origem
	aAux[2]  , ;  // [02] identificador (ID) do campo de destino
	aAux[3]  , ;  // [03] Bloco de código de validação da execução do gatilho
	aAux[4]  )    // [04] Bloco de código de execução do gatilho

	oStruZA0:SetProperty( 'ZA0_NUM'      , MODEL_FIELD_VALID 	, { |oFld| fVldNum(oFld) } )
	oStruZA0:SetProperty( 'ZA0_TIPO'     , MODEL_FIELD_VALID 	, { |oFld| ExistCpo("SX5","05"+M->ZA0_TIPO) .And. fVldNum(oFld) } )
	oStruZA0:SetProperty( 'ZA0_CLIFOR'   , MODEL_FIELD_VALID 	, { |oFld| fVldNum(oFld) } )
	oStruZA0:SetProperty( 'ZA0_LOJA'     , MODEL_FIELD_VALID 	, { |oFld| fVldNum(oFld) } )
	oStruZA0:SetProperty( 'ZA0_PARCEL'   , MODEL_FIELD_VALID 	, { |oFld| fVldNum(oFld) } )
	oStruZA0:SetProperty( 'ZA0_VENCTO'   , MODEL_FIELD_VALID 	, { |x| fVldVencto(x,1) } )
	oStruZA0:SetProperty( 'ZA0_VENCRE'   , MODEL_FIELD_VALID 	, { |x| fVldVencto(x,2) } )
	oStruZA0:SetProperty( 'ZA0_NATURE'   , MODEL_FIELD_VALID    , { |oFld| fVldNat(oFld:GetValue('ZA0_NATURE')) .And. fCalcImp( oFld ) })
	oStruZA0:SetProperty( 'ZA0_VALOR'    , MODEL_FIELD_VALID    , { |oFld| fCalcImp(oFld) })
	oStruZA0:SetProperty( 'ZA0_CODSOL'   , MODEL_FIELD_INIT 	, { |x| fRetCodSol(__CUSERID) } )
	oStruZA0:SetProperty( 'ZA0_NOMSOL'   , MODEL_FIELD_INIT 	, { || UsrFullName(__CUSERID) } )

	oStruZA2:SetProperty( 'ZA2_NATURE'   , MODEL_FIELD_VALID    , { |oFld| fVldNat(oFld:GetValue('ZA2_NATURE')) })
	oStruZA2:SetProperty( 'ZA2_PERC'     , MODEL_FIELD_VALID    , { |oFld| Positivo() /*.And. MNatPosZA2(.T.,oFld)*/ })
	oStruZA2:SetProperty( 'ZA2_VLRNAT'   , MODEL_FIELD_VALID    , { |oFld| Positivo() })

	oStruZA3:SetProperty( 'ZA3_CC'      , MODEL_FIELD_VALID    , { |oFld| Vazio() .Or. CTB105CC() })
	oStruZA3:SetProperty( 'ZA3_PERC'    , MODEL_FIELD_VALID    , { |oFld| Positivo() /*.And. MNatPosZA3(.T.,oFld)*/ })
	oStruZA3:SetProperty( 'ZA3_VLRRAT'  , MODEL_FIELD_VALID    , { |oFld| Positivo() })

	oModel:AddFields( 'ZA0MASTER', /*cOwner*/, oStruZA0)
	oModel:AddGrid('ZA2DETAIL','ZA0MASTER',oStruZA2,/*bPreVlZA2*/,{|oModelGrid| MNatPosZA2(.T.,oModelGrid)})
	oModel:AddGrid('ZA3DETAIL','ZA2DETAIL',oStruZA3,/*bPreVlZA2*/,{|oModelGrid| MNatPosZA3(.T.,oModelGrid)})
	oModel:SetDescription( 'Solicitação de pagamento' )

	oModel:GetModel( "ZA2DETAIL" ):SetOptional( .t. )
	oModel:GetModel( "ZA3DETAIL" ):SetOptional( .t. )
	//oModel:AddCalc('TOTMED','CNDMASTER','CXNDETAIL','CXN_VLRADI','CND_TOTADT','FORMULA'	,bVldCalc,,NomeSX3('CND_TOTADT'),{|oModel,nVlrAtu,xValor,lSoma| Cn121VlrTt(oModel,nVlrAtu,xValor,lSoma,'CND_TOTADT')})
	oModel:AddCalc( 'TCFI02CALC1', 'ZA0MASTER', 'ZA2DETAIL', 'ZA2_PERC', 'TOTPERCNAT'	,'SUM'  ,{||.t.},,"% Distribuido" )
	oModel:AddCalc( 'TCFI02CALC1', 'ZA0MASTER', 'ZA2DETAIL', 'ZA2_VLRNAT', 'TOTVLRNAT'	,'SUM'  ,{||.t.},,"Valor Distribuido" )
	oModel:AddCalc( 'TCFI02CALC2', 'ZA2DETAIL', 'ZA3DETAIL', 'ZA3_PERC', 'TOTPERCCC'	,'SUM'  ,{||.t.},,"% Distribuido" )
	oModel:AddCalc( 'TCFI02CALC2', 'ZA2DETAIL', 'ZA3DETAIL', 'ZA3_VLRRAT', 'TOTVLRCC'	,'SUM'  ,{||.t.},,"Valor Distribuido")

	// Configura chave primária.
	oModel:SetPrimaryKey({"ZA0_FILIAL", "ZA0_CODIGO"})
	oModel:SetRelation('ZA2DETAIL',{{'ZA2_FILIAL','xFilial("ZA2")'},{'ZA2_CODIGO','ZA0_CODIGO'}},ZA2->(IndexKey(1)))
	oModel:SetRelation('ZA3DETAIL',{{'ZA3_FILIAL','xFilial("ZA3")'},{'ZA3_CODIGO','ZA0_CODIGO'},{'ZA3_NATURE','ZA2_NATURE'}},ZA3->(IndexKey(1)))
	oModel:GetModel('ZA2DETAIL'):SetUniqueLine({"ZA2_NATURE"})
	oModel:GetModel('ZA3DETAIL'):SetUniqueLine({"ZA3_CC"})

	oModel:InstallEvent("oModelEvent",,oModelEvent)

	oModel:SetVldActivate( { |oModel| TF02VldAct( oModel ) } )

Return( oModel )

Static function TFI02Calc( oModel,nVlrAtu,xValor )
	Local nValor := 0
	If( xValor > 0)
		nValor += xValor
	EndIf
Return( nValor )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface da rotina
@author: Kaique Mathias
@since: 20/02/2013
@Uso: TCFIA002
/*/
// -------------------------------------------------------------------------------------

Static Function ViewDef()

	Local oModel    := FWLoadModel( 'TCFIA002' )
	Local oStruZA0  := FWFormStruct( 2, 'ZA0' )
	Local oStruZA2  := FWFormStruct( 2, 'ZA2' )
	Local oStruZA3  := FWFormStruct( 2, 'ZA3' )
	Local oView

	oView := FWFormView():New()

	//-----------------------
	// Instacia FwCalEstruct
	//-----------------------
	oCalcNat := FWCalcStruct( oModel:GetModel( 'TCFI02CALC1') )
	oCalcCC  := FWCalcStruct( oModel:GetModel( 'TCFI02CALC2') )

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_ZA0', oStruZA0, 'ZA0MASTER' )
	oView:AddGrid('VIEW_ZA2'	,oStruZA2	,'ZA2DETAIL')
	oView:AddField('VIEW_TOTNAT',oCalcNat,'TCFI02CALC1')
	oView:AddGrid('VIEW_ZA3'	,oStruZA3	,'ZA3DETAIL')
	oView:AddField('VIEW_TOTCC',oCalcCC,'TCFI02CALC2')

	//oView:CreateVerticallBox( "TELANOVA" , 100 )
	oView:CreateHorizontalBox( "SUPERIOR" , 40 )
	oView:CreateHorizontalBox( "INF_SUP" , 20 )
	oView:CreateHorizontalBox( "INF_SUP_AUX" , 10 )
	oView:CreateHorizontalBox( "INF_INF" , 20 )
	oView:CreateHorizontalBox( "INF_INF_AUX" , 10 )

	oView:SetOwnerView( 'VIEW_ZA0', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_ZA2','INF_SUP' )
	oView:SetOwnerView( 'VIEW_TOTNAT','INF_SUP_AUX' )
	oView:SetOwnerView( 'VIEW_ZA3','INF_INF' )
	oView:SetOwnerView( 'VIEW_TOTCC','INF_INF_AUX' )
	oView:SetDescription( "Solicitação de Pagamento" )

	oStruZA0:AddGroup( 'GRUPO01', 'Dados Gerais'    , '', 2 )
	oStruZA0:AddGroup( 'GRUPO02', 'Impostos'		, '', 2 )
	oStruZA0:AddGroup( 'GRUPO03', 'Contabil'	    , '', 2 )
	oStruZA0:AddGroup( 'GRUPO04', 'Outros'	        , '', 2 )

	oStruZA0:SetProperty( 'ZA0_CODIGO'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZA0:SetProperty( 'ZA0_NUM' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZA0:SetProperty( 'ZA0_PARCEL' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZA0:SetProperty( 'ZA0_TIPO'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZA0:SetProperty( 'ZA0_CLIFOR'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZA0:SetProperty( 'ZA0_LOJA'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZA0:SetProperty( 'ZA0_NOME'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZA0:SetProperty( 'ZA0_EMISSA'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZA0:SetProperty( 'ZA0_VENCTO'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZA0:SetProperty( 'ZA0_VENCRE'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZA0:SetProperty( 'ZA0_VALOR'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZA0:SetProperty( 'ZA0_NATURE'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZA0:SetProperty( 'ZA0_CODBAR'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZA0:SetProperty( 'ZA0_HIST'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )

	oStruZA0:SetProperty( 'ZA0_MULTA'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZA0:SetProperty( 'ZA0_JUROS'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZA0:SetProperty( 'ZA0_JUSJUR'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZA0:SetProperty( 'ZA0_IRRF'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZA0:SetProperty( 'ZA0_PIS'	    , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZA0:SetProperty( 'ZA0_COFINS'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZA0:SetProperty( 'ZA0_CSLL'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZA0:SetProperty( 'ZA0_CODREC'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZA0:SetProperty( 'ZA0_PERAPU'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZA0:SetProperty( 'ZA0_NUMREF'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )

	oStruZA0:SetProperty( 'ZA0_CC'	    , MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruZA0:SetProperty( 'ZA0_TPORC'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )

	oStruZA0:SetProperty( 'ZA0_OBS'	    , MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )

	//oView:EnableTitleView('VIEW_ZA0',"Dados Gerais")
	oView:EnableTitleView('VIEW_ZA2',"Rateio Naturezas x Centro de Custo")

	If ( !INCLUI .And. !ALTERA )
		oView:AddUserButton("Log de Aprovação",'BUDGET', {|| U_TCCOA01(ZA0->ZA0_CODIGO,"AP",(fRetCodSol(ZA0->ZA0_CODSOL,2)),"U_TFIA02WF()")}) //"Log de Aprovação"
	EndIf

Return( oView )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} TF02VldAct
//Valida o Modelo
@author Kaique Mathias
@since 01/04/2020
@version 1.0
@type Static function
/*/
// -------------------------------------------------------------------------------------

Static Function TF02VldAct( oModel )

	Local lView := .F.
	Local lRet  := .T.

	If ValType( oModel ) == 'O'
		lView := oModel:GetOperation() == MODEL_OPERATION_VIEW // Visualização
	EndIf

	If !lView
		lRet := fVldUser()
	EndIf

Return( lRet )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} fVldUser
//Valida se o usuario esta cadastrado como solicitante.
@author Kaique Mathias
@since 01/04/2020
@version 1.0
@type Static function
/*/
// -------------------------------------------------------------------------------------

Static Function fVldUser()

	Local lRet := .T.

	dbSelectArea("Z99")
	Z99->(dbSetOrder(2))

	If !Z99->(MSSeek(xFilial("Z99")+RetCodUsr()))
		Help("",1,"TCFI002SEMPERM",,'Não foi possivel abrir a rotina, pois o usuário logado não esta cadastrado como solicitante.',;
			4,1,NIL, NIL, NIL, NIL, NIL, {"Cadastre o usuário como solicitante para ter acesso a operação."})
		lRet := .F.
	EndIf

	Z99->(dbCloseArea())

Return( lRet )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} fRetCodSol
//Retorna o codigo do solicitante
@author Kaique Mathias
@since 01/04/2020
@version 1.0
@type Static function
/*/
// -------------------------------------------------------------------------------------

Static Function fRetCodSol( cUserID, nOpc )

	Local cUser := ""
	Default nOpc:= 1

	dbSelectArea("Z99")
	If ( nOpc = 1 )
		Z99->(dbSetOrder(2))

		If Z99->( MSSeek(xFilial("Z99")+cUserID) )
			cUser := Z99->Z99_CODIGO
		EndIf
	else
		Z99->(dbSetOrder(1))

		If Z99->( MSSeek(xFilial("Z99")+cUserID) )
			cUser := Z99->Z99_USER
		EndIf
	EndIf

	Z99->(dbCloseArea())

Return( cUser )

Static Function fMNPosMd(oModelZA2,oModelZA3,oModelZA0)

	Local lRet 	:= .T.
	Local nX	:= 1

	lRet := fVldNum(oModelZA0)

	While lRet .And. nX <= oModelZA2:Length()
		oModelZA2:GoLine(nX)
		lRet := MNatPosZA3(.F.,oModelZA3)
		lRet := lRet .And. MNatPosZA2(.F.,oModelZA2)
		nX++
	End

Return( lRet )

/*/{Protheus.doc} TFI02WHEN
Valida modo de edição dos campos no cancelamento
@type function
@version 1.0
@author Kaique Mathias
@since 6/22/2020
@return return_type, return_description
/*/

Static Function TFI02WHEN()

	Local lRet      := .F.
	Local oView		:= FwViewActive()

	If (lRet := ValType(oView) == "O" .And. oView:lActivate)
		If( oView:nBrowseOpc > 0 )
			cIdOption := Menudef()[oView:nBrowseOpc][8] //Fixo[8] que indica a posição do ID no arotina
			If (lRet := (cIdOption == OP_CANC))
				lRet := .F.//oView:GetValue('MdFieldDXJ','DXJ_TIPO') == "1"
			EndIf
		EndIf
	EndIf

Return( lRet )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} TCFI02RET
//Trata o retorno do workflow.
@author Kaique Mathias
@since 01/04/2020
@version 1.0
@type user function
/*/
// -------------------------------------------------------------------------------------

User Function TCFI02RET(pParam1,pParam2,pParam3,pParam4,pParam5,pParam6)

	Local cReturn       := ""
	Local _nDias  		:= GetMv("TCP_DIAVEN",.F.,13)
	Local cEmp          := StrZero(pParam1,2)
	Local cFil          := StrZero(pParam2,TamSX3("ZA0_FILIAL")[1])
	Local cCodigo       := StrZero(pParam3,TamSX3("ZA0_CODIGO")[1])
	Local nOpc          := pParam4
	Local cAprov        := StrZero(pParam5,TamSX3("AK_COD")[1])
	Local aRotAuto      := {}
	Local oModel094		:= NIl
	Local cTpDocAP      := "AP"
	Local aRatEvEz      := {}
	Local lReturn       := .T.
	Local cTitle        := ""
	Local cHoras        := StrZero(pParam6,4)
	Local cTpTitExc     := GetMv("TCP_TPTIEX")
	Local cPrefixo      := ""
	Private lMsErroAuto := .F.

	nLenSCR := TamSX3("CR_NUM")[1]

	dbSelectArea("SCR")
	SCR->(dbSetOrder(3))

	If SCR->(MsSeek(cFil+"AP"+Padr(cCodigo,nLenSCR)+cAprov))

		If( SCR->CR_STATUS == "02" )

			//Verifico se o link ja foi utilizado
			If ( cHoras # Alltrim(SCR->CR_XHORAS) )
				cTitle  := "ERROR"
				cReturn := "Payment Request has expired."
				Return( {cReturn,cTitle,lReturn} )
			EndIf

			//Aprovar
			If ( nOpc == 4 )

				dbSelectArea("ZA0")
				ZA0->(dbSetOrder( 1 ))
				ZA0->( MSSeek( cFil + cCodigo ) )

				Begin Transaction

					lLiberou := MaAlcDoc({  Padr(cCodigo,nLenSCR),;
						SCR->CR_TIPO,;
						SCR->CR_TOTAL,;
						SCR->CR_APROV,;
						,;
						SCR->CR_GRUPO,;
						,;
						,;
						,;
						,;
						""},;
						dDataBase,;
						nOpc)

					If lLiberou

						If( Empty(ZA0->ZA0_ORIGEM) ) //Gerado pela Solicitacao de Pgto
							cPrefixo := "MAN"
						Else
							cPrefixo := ZA0->ZA0_PREFIXO
						EndIf

						//Analiso se o titulo ja existe
						dbSelectArea("SE2")
						SE2->( dbSetOrder( 1 ) )

						//Se ja existir verifico se ele esta aguardando liberacao e realizo a liberacao
						If( SE2->( MSSeek(xFilial("SE2") + cPrefixo + ZA0->ZA0_NUM + ZA0->ZA0_PARCEL + ZA0->ZA0_TIPO + ZA0->ZA0_CLIFOR + ZA0->ZA0_LOJA ) ) )
							If( SE2->E2_STATLIB == "01" .Or. ( Empty(SE2->E2_STATLIB) .And. Empty(SE2->E2_DATALIB) ) )
								RecLock( "SE2", .F. )
								SE2->E2_STATLIB := "03"
								SE2->E2_DATALIB := dDataBase
								SE2->E2_USUALIB := cUserName
								MsUnlock()
								If RecLock("ZA0",.F.)
									ZA0->ZA0_STATUS := "2"
									ZA0->(MsUnlock())
								EndIf
								cTitle  := "MESSAGE"
								cReturn := "Successfully approved."
								U_TCFIW004(2)
							Else
								DisarmTransaction()
								cTitle  := "ERROR"
								cReturn := "An error occurred when approving the request. Invoice already exists."
								lReturn := .F.
							EndIf
						Else
							aCab := {}
							AAdd( aCab, { "E2_PREFIXO", cPrefixo , NIL } )
							AAdd( aCab, { "E2_NUM"    , ZA0->ZA0_NUM , NIL } )
							AAdd( aCab, { "E2_TIPO"   , ZA0->ZA0_TIPO, NIL } )
							AADD( aCab, { "E2_PARCELA", ZA0->ZA0_PARCEL, NIL})
							AAdd( aCab, { "E2_NATUREZ", PadR( ZA0->ZA0_NATURE, Len( ZA0->ZA0_NATUREZ ) ), NIL } )
							AAdd( aCab, { "E2_FORNECE", ZA0->ZA0_CLIFOR, NIL } )
							AAdd( aCab, { "E2_LOJA"   , ZA0->ZA0_LOJA  , NIL } )
							AAdd( aCab, { "E2_EMISSAO", ZA0->ZA0_EMISSA, NIL } )
							AAdd( aCab, { "E2_VENCTO" , ZA0->ZA0_VENCTO, NIL } )
							AAdd( aCab, { "E2_BARRA"  , ZA0->ZA0_CODBAR , NIL } )

							if ( ( DateDiffDay( ZA0->ZA0_VENCTO , Date() ) < _nDias ) .Or. ( ZA0->ZA0_VENCTO <= Date() ) ) .And. !( ZA0->ZA0_TIPO $ cTpTitExc )
								dVencRea := DataValida(DaySum( Date() , _nDias ),.T.)
							Else
								dVencRea := DataValida(ZA0->ZA0_VENCTO,.T.)
							EndIf

							AAdd( aCab, { "E2_VENCREA", dVencRea, NIL } )
							AADD( aCab, { "E2_ORIGEM" , ZA0->ZA0_ORIGEM    , NIL})
							AAdd( aCab, { "E2_VALOR"  , ZA0->ZA0_VALOR , NIL } )
							AAdd( aCab, { "E2_HIST"  , "Request Payment " + ZA0->ZA0_CODIGO + " - " + Alltrim(ZA0->ZA0_HIST) , NIL } )
							AAdd( aCab, { "E2_XORIGEM"  , "SP" , NIL } )
							AAdd( aCab, { "E2_XDCODRF"  , ZA0->ZA0_CODREC , NIL } )
							AAdd( aCab, { "E2_XDPAPUR"  , ZA0->ZA0_PERAPU , NIL } )
							AAdd( aCab, { "E2_XDNUMRF"  , ZA0->ZA0_NUMREF , NIL } )
							AAdd( aCab, { "E2_CC"       , ZA0->ZA0_CC , NIL } )
							AAdd( aCab, { "E2_XMULTA"  , ZA0->ZA0_MULTA , NIL } )
							AAdd( aCab, { "E2_XJUROS"  , ZA0->ZA0_JUROS , NIL } )
							AAdd( aCab, { "E2_XCODPGM"  , ZA0->ZA0_CODIGO , NIL } )

							dbSelectArea('ZA2')
							ZA2->(dbSetOrder(1))

							dbSelectArea('ZA3')
							ZA3->(dbSetOrder(1))

							If ZA2->(MsSeek(xFilial('ZA2')+ZA0->ZA0_CODIGO))

								aadd( aCab ,{ "E2_MULTNAT" , '1', Nil }) //rateio multinaturezs = sim

								While !ZA2->(Eof()) .And. ZA2->ZA2_FILIAL+ZA2->ZA2_CODIGO == xFilial('ZA2')+ZA0->ZA0_CODIGO

									aAuxEv := {}

									//Adicionando o vetor da natureza
									aadd( aAuxEv ,{"EV_NATUREZ" , padr(ZA2->ZA2_NATURE,tamsx3("EV_NATUREZ")[1]), Nil })//natureza a ser rateada
									aadd( aAuxEv ,{"EV_VALOR" , ZA2->ZA2_VLRNAT, Nil })//valor do rateio na natureza
									aadd( aAuxEv ,{"EV_PERC" , Alltrim(Str(ZA2->ZA2_PERC)), Nil })//percentual do rateio na natureza

									//Adicionando multiplos centros de custo
									//primeiro centro de custo

									If ZA3->(dbSeek(xFilial('ZA3')+ZA2->ZA2_CODIGO+ZA2->ZA2_NATURE))
										aadd( aAuxEv ,{"EV_RATEICC" , "1", Nil })//indicando que há rateio por centro de custo
										aRatEz := {}
										While !ZA3->(Eof()) .And. ZA3->ZA3_FILIAL+ZA3->ZA3_CODIGO+ZA3->ZA3_NATURE == xFilial('ZA3')+ZA2->ZA2_CODIGO+ZA2->ZA2_NATURE
											aAuxEz:={}
											aadd( aAuxEz ,{"EZ_CCUSTO" , ZA3->ZA3_CC, Nil })//centro de custo da natureza
											aadd( aAuxEz ,{"EZ_VALOR" , ZA3->ZA3_VLRRAT, Nil })//valor do rateio neste centro de custo
											aadd( aAuxEz ,{"EZ_ITEMCTA", ZA3->ZA3_ITEMCT, Nil })
											aadd(aRatEz,aAuxEz)
											ZA3->(dbSkip())
										EndDo
										aadd(aAuxEv,{"AUTRATEICC" , aRatEz, Nil })//recebendo dentro do array da natureza os multiplos centros de custo
									else
										aadd( aAuxEv ,{"EV_RATEICC" , "2", Nil })//indicando que há rateio por centro de custo
									EndIf
									aAdd(aRatEvEz,aAuxEv)//adicionando a natureza ao rateio de multiplas naturezas
									ZA2->(dbSkip())
								EndDo
								aAdd(aCab,{"AUTRATEEV",ARatEvEz,Nil})//adicionando ao vetor aCab o vetor do rateio
							EndIf

							MSExecAuto({|x,y,z| FINA050(x,y,z)}, aCab,,3)

							If lMsErroAuto
								DisarmTransaction()
								//cReturn := MostraErro("/dirdoc", "error.log")
								cTitle  := "ERROR"
								cReturn := "An error occurred when approving the request. Contact your system administrator."
								lReturn := .F.
							else
								If RecLock("ZA0",.F.)
									ZA0->ZA0_STATUS := "2"
									ZA0->(MsUnlock())
								EndIf
								cTitle  := "MESSAGE"
								cReturn := "Successfully approved."
								U_TCFIW004(2)
							EndIf
						EndIf
					Else
						cTitle  := "MESSAGE"
						cReturn := "Successfully approved."
					EndIf

				End Transaction

			elseIf nOpc == 7
				cReturn := geraHtmlWF()
				cTitle  := "» JUSTIFICATION"
				lReturn := .T.
			elseIf nOpc == 6

				cUserBkp    := cUserName
				cUserName   := UsrRetName(SCR->CR_USER)

				A094SetOp('005')

				oModel094 := FWLoadModel('MATA094')
				oModel094:SetOperation( MODEL_OPERATION_UPDATE )

				If oModel094:Activate()

					oModel094:GetModel("FieldSCR"):SetValue( 'CR_OBS' , aPostParams[1][2] )

					lOk := oModel094:VldData()

					If lOk

						lOk := oModel094:CommitData()

						If RecLock("ZA0",.F.)
							ZA0->ZA0_STATUS := "3"
							ZA0->(MsUnlock())
						EndIf

						If( Alltrim(ZA0->ZA0_ORIGEM) == "GPEM670" )
							dbSelectArea("RC1")
							RC1->( dbSetOrder( 2 ) )
							cIndexRC1 := SE2->( xFilial("RC1") + ZA0->ZA0_FILIAL + ZA0->ZA0_PREFIXO + ZA0->ZA0_NUM + ZA0->ZA0_TIPO + ZA0->ZA0_CLIFOR )
							If( RC1->( DbSeek(cIndexRC1) ) )
								While 	RC1->(!Eof()) .And.;
										RC1_FILIAL+RC1_FILTIT+RC1_PREFIX+RC1_NUMTIT+RC1_TIPO+RC1_FORNEC == cIndexRC1
									If ( ZA0->ZA0_PARCEL == RC1->RC1_PARC )
										RecLock("RC1", .F.)
										RC1->RC1_INTEGR := "0"
										RC1->( MsUnLock() )
									EndIf
									RC1->(dbSkip())
								EndDo
							EndIf
						EndIf

						cTitle  := "WARNING"
						cReturn := "Rejected successfully."

						U_TCFIW004(3)

						//Salvo o anexo
						SaveAttach()

					else
						aErro := oModel094:GetErrorMessage()

						AutoGrLog("Id do formulário de origem:" + ' [' + AllToChar(aErro[01]) + ']')
						AutoGrLog("Id do campo de origem: "     + ' [' + AllToChar(aErro[02]) + ']')
						AutoGrLog("Id do formulário de erro: "  + ' [' + AllToChar(aErro[03]) + ']')
						AutoGrLog("Id do campo de erro: "       + ' [' + AllToChar(aErro[04]) + ']')
						AutoGrLog("Id do erro: "                + ' [' + AllToChar(aErro[05]) + ']')
						AutoGrLog("Mensagem do erro: "          + ' [' + AllToChar(aErro[06]) + ']')
						AutoGrLog("Mensagem da solução:"        + ' [' + AllToChar(aErro[07]) + ']')
						AutoGrLog("Valor atribuído: "           + ' [' + AllToChar(aErro[08]) + ']')
						AutoGrLog("Valor anterior: "            + ' [' + AllToChar(aErro[09]) + ']')

						cTitle  := "ERROR"
						cReturn := "An error occurred when you failed the request. Contact your system administrator."
						lReturn := .F.
					EndIf

					oModel094:DeActivate()

				EndIf

				cUserName   := cUserBkp
			EndIf
		ElseIf( SCR->CR_STATUS == "04" )
			cTitle  := "ERROR"
			cReturn := "Request has been cancelled."
			lReturn := .F.
		Else
			cTitle  := "ERROR"
			cReturn := "Request already answered before."
			lReturn := .F.
		EndIf
	Else
		cReturn := ""
		lReturn := .F.
	EndIf

Return( {cReturn,cTitle,lReturn} )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} fVldVencto
//Valida a data de vencimento
@author Kaique Mathias
@since 01/04/2020
@version 1.0
@type static function
/*/
// -------------------------------------------------------------------------------------

Static function fVldVencto(oFld,nTpVenc)

	Local lRetorna  := .T.
	//Local nTpVenc   := Iif(Alltrim(ReadVar())=="M->ZA0_VENCTO",1,2)
	Local _nDias  	:= GetMv("TCP_DIAVEN",.F.,13)
	Local cTpTitExc := GetMv("TCP_TPTIEX")
	Default nTpVenc := 1

	//Validando data de vencto
	If ( oFld:GetValue('ZA0_VENCTO') < oFld:GetValue('ZA0_EMISSA') )
		Help(" ",1,"FANODATA")
		lRetorna := .F.
		//Validando data de vencimento Real
	ElseIf ( nTpVenc == 2 .and. oFld:GetValue('ZA0_VENCRE')  < oFld:GetValue('ZA0_VENCTO') )
		lRetorna := .F.
		MsgAlert("Data de Vencimento Real não pode ser menor que a data de Vencimento.")
	Else
		If ( nTpVenc == 1 )
			If  !( oFld:GetValue('ZA0_TIPO') $ cTpTitExc )
				if ( DateDiffDay( oFld:GetValue('ZA0_VENCTO') , Date() ) < _nDias ) .Or. ( oFld:GetValue('ZA0_VENCTO') <= Date() )
					dVencRea := DataValida(DaySum( Date() , _nDias ),.T.)
				Else
					dVencRea := DataValida(oFld:GetValue('ZA0_VENCTO'),.T.)
				EndIf
			Else
				dVencRea := DataValida( oFld:GetValue('ZA0_VENCTO') ,.T.)
			EndIf
			oFld:SetValue('ZA0_VENCRE',DataValida(dVencRea,.T.))
		Endif
	EndIf

Return( lRetorna )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} saveAttach
//Salva o anexo
@author Kaique Mathias
@since 01/04/2020
@version 1.0
@type static function
/*/
// -------------------------------------------------------------------------------------

Static Function saveAttach()

	Local cAliasAx  := GetNextAlias()
	Local cCodEnt := xFilial("ZA0")+ZA0->ZA0_CODIGO
	Local cChaveAne := "%'ZA0" + cCodEnt + "'%"
	Local lRet      := .F.
	Private aRotina := {}

	BeginSql Alias cAliasAx

    SELECT *
    FROM %TABLE:AC9% AC9
    INNER JOIN %TABLE:ACB% ACB ON ACB_FILIAL = AC9_FILIAL AND AC9_CODOBJ = ACB_CODOBJ  AND ACB.%NotDel% 
    WHERE AC9.%NotDel%  AND AC9_ENTIDA||AC9_CODENT IN (%EXP:cChaveAne%)
    
	EndSql

	dbSelectArea(cAliasAx)
	(cAliasAx)->(dbGoTop())

	If (cAliasAx)->(Eof())
		lRet := .F.
		aAdd(aRotina,{})
		aAdd(aRotina,{})
		aAdd(aRotina,{})
		Aadd(aRotina,{"Anexos","MsDocument('ZA0',ZA0->(Recno()),4)", 0, 4,0,NIL})
		MsDocument('ZA0',ZA0->(Recno()),4)
	else
		lRet := .T.
		If( Type("__cChaveAnexo")=="U")
			__cChaveAnexo := cCodEnt
		EndIf
	EndIf

Return( lRet )

/*/{Protheus.doc} fVldNat
Realiza a validação da natureza digitada
@type function
@version 1.0
@author Kaique Mathias
@since 6/29/2020
@param cNatureza, character, param_description
@return logical, lRet
/*/

Static Function fVldNat(cNatureza)

	Local aArea     := GetArea()
	Local lRet      := .T.

	If( Alltrim(FunName()) $ "TCFIA002" )
		If !Empty(cNatureza)
			DbSelectArea("SED")
			SED->(DbSetOrder(1))
			If !SED->(DbSeek (xFilial("SED")+cNatureza))
				Help( " ", 1, "NATNAOENC",, "A natureza não foi encontrada!!", 1, 0 )
				lRet	:= .F.
			Else
				If( SED->ED_XPGTOMA <> "1" )
					Help( " ", 1, "NAT_INV",, "Natureza invalida. A Natureza não poderá ser utilizada nesta rotina !", 1, 0 )
					lRet	:= .F.
				EndIf
			EndIf
		Else
			Help( " ", 1, "VAZIO",, "Especificar uma natureza!", 1, 0 )
			lRet	:= .F.
		EndIf
	EndIf

	RestArea(aArea)

Return( lRet )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} fSelGrpApr
//Monta a tela de seleção de grupo de aprovação
@author Kaique Mathias
@since 01/04/2020
@version 1.0
@type Static function
/*/
// -------------------------------------------------------------------------------------

Static Function fSelGrpApr()

	Local cAlias    := GetNextAlias()
	Local aGrupo    := {}
	Local cGrupo    := ""

	BeginSql alias cAlias
        SELECT DISTINCT AL_COD, 
                        AL_DESC
        FROM %table:SAL% SAL
        WHERE   SAL.%notDel% AND 
                SAL.AL_XDOCPGM='1' AND 
                SAL.AL_MSBLQL != '1'
	EndSql

	dbSelectArea(cAlias)
	dbGoTop()

	While !Eof()
		AADD(aGrupo,{(cAlias)->AL_COD,(cAlias)->AL_DESC})
		dbSelectArea(cAlias)
		(cAlias)->(dbSkip())
	EndDo

	If Len(aGrupo) > 0

		DEFINE MSDIALOG oDlgAprov TITLE "Definir grupo de aprovação" From 001,001 to 380,615 Pixel Style DS_MODALFRAME

		oDlgAprov:lEscClose     := .F.
		oBrwGrp := TCBrowse():New(010,005,300,150,,,,oDlgAprov,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

		oBrwGrp:AddColumn(TCColumn():New("Grupo"      , {|| aGrupo[oBrwGrp:nAt,01]},,,,, ,.F.,.F.,,,,.F., ) )
		oBrwGrp:AddColumn(TCColumn():New("Descrição"  , {|| aGrupo[oBrwGrp:nAt,02]},,,,, ,.F.,.F.,,,,.F., ) )
		oBrwGrp:SetArray(aGrupo)

		oBrwGrp:bLDblClick   := { || cGrupo := aGrupo[oBrwGrp:nAt,01], oDlgAprov:End()}

		ACTIVATE MSDIALOG oDlgAprov CENTERED

	EndIf

Return( cGrupo )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} fSendWf
Realiza o envio do workflow
@author Kaique Mathias
@since 01/04/2020
@version 1.0
@type Static function
/*/
// -------------------------------------------------------------------------------------

User Function TFIA02WF()

	Local aAreaSCR  := GetArea()
	Local lFound    := .F.

	dbSelectArea(cAliasSCR)
	(cAliasSCR)->(dbgotop())

	dbSelectArea("SCR")

	If( MsgYesNo('Ao selecionar essa opção será reenviado o workflow de aprovação apenas para os aprovadores que ainda não realizaram a aprovação. Deseja continuar mesmo assim ?' ) )
		While (cAliasSCR)->(!Eof())
			If ( (cAliasSCR)->CR_STATUS == "02" )
				SCR->(dbGoto((cAliasSCR)->SCRRECNO))
				U_TCFIW004()
				lFound := .T.
			EndIf
			(cAliasSCR)->(dbSkip())
		EndDo
		If lFound
			MsgInfo('Workflow Reenviado com sucesso!')
		else
			MsgInfo('Não existe registros aptos a serem reenviados!')
		EndIf
	EndIf

	RestArea(aAreaSCR)

Return( Nil )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} GeraHTMLWF
//Monta o HTML p/ inserir a justificativa
@author Kaique Mathias
@since 01/04/2020
@version 1.0
@type Static function
/*/
// -------------------------------------------------------------------------------------

Static Function GeraHTMLWF()

	Local cHTML := ""

	cAction := ENCODE64( "funcName=u_TCFI02RET&empresa=" + cEmpAnt + "&filial=" + cFilAnt + "&codigo=" + Alltrim(SCR->CR_NUM )+ "&opc=6" + "&aprovador=" + SCR->CR_APROV + "&horas=" + Alltrim(SubS(SCR->CR_XHORAS,1,4)) )

	cHTML += '<form id="form1" name="form1" method="post" action="u_tcpwfhttpret.apl?' + cAction + ' "> '
	cHTML += '<div align="center" style=";margin: 2px 15px;padding: 10px;font: 12px Arial, Helvetica, sans-serif;"> '
	cHTML += '            <textarea name="cJus" cols="150" rows="6" onBlur="this.value=retira_acentos(this.value)"></textarea>'
	cHTML += '</div> '
	cHTML += '<div align="center" style="margin: 0px 0px;padding: 0px;"> '
	cHTML += '	<input type="submit" name="B1" value="Send"> '
	cHTML += '	<input type="reset" name="B2" value="Clear"> '
	cHTML += '</div> '
	cHTML += '</form> '

Return( cHtml )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} MNatPosZA2
//Valida Grid de naturezas
@author Kaique Mathias
@since 01/04/2020
@version 1.0
@type Static function
/*/
// -------------------------------------------------------------------------------------

Static Function MNatPosZA2(lVldLine,oModelZA2,nPerc,nLine)

	Local aArea			:= GetArea()
	Local aSaveLines	:= FWSaveRows()
	Local lRet			:= .T.	//- Retorno da função
	Local lRat			:= .F.	//- Controle se existe rateio
	Local nPerc			:= 0
	Local nVlrNat       := 0
	Local nX			:= 0
	Local oModel        := FwModelActive()
	Local nValTot       := oModel:GetValue("ZA0MASTER","ZA0_VALOR")
	Default oModelZA2  	:= ""
	Default lVldLine	:= .F.
	Default nPerc		:= 0
	Default nLine		:= 0

	If 	!Empty(oModelZA2) .And. !IsInCallStack("U_TCGP04KM")
		For nX := 1 to oModelZA2:Length()
			oModelZA2:GoLine(nX)
			If !oModelZA2:IsDeleted() .And. !Empty(oModelZA2:GetValue("ZA2_PERC"))
				If nX != nLine
					nPerc += oModelZA2:GetValue("ZA2_PERC")
					nVlrNat += oModelZA2:GetValue("ZA2_VLRNAT")
				EndIf
				lRat := .T.
			EndIf
		Next nX

		If lRat .And. ((lVldLine .And. nPerc > 100) .Or. (!lVldLine .And. nPerc <> 100))
			Help(" ",1,"CNMNATNPER") //-- A somatória dos percentuais das múltiplas naturezas diferem de 100%.
			lRet := .F.
		EndIf

		If( lRet )
			If lRat .And. ((lVldLine .And. nVlrNat > nValTot) .Or. (!lVldLine .And. nVlrNat <> nValTot))
				//Help(" ",1,"CNMNATNPER") //-- A somatória dos percentuais das múltiplas naturezas diferem de 100%.
				Help("",1,"CNMNATNVAL",,'A somatória dos valores das múltiplas naturezas difere do valor total da solicitação.',4,1,NIL, NIL, NIL, NIL, NIL, {"Ajuste o valor da natureza no rateio."})
				lRet := .F.
			EndIf
		EndIf

	EndIf

	FWRestRows(aSaveLines)
	RestArea(aArea)

Return( lRet )

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} MNatPosZA2
//Valida Grid de centro de custo
@author Kaique Mathias
@since 01/04/2020
@version 1.0
@type Static function
/*/
// -------------------------------------------------------------------------------------

Static Function MNatPosZA3(lVldLine,oModelZA3,nPerc,nLine)

	Local aArea			:= GetArea()
	Local aSaveLines	:= FWSaveRows()

	Local lRet			:= .T.	//- Retorno da função
	Local lRat			:= .F.	//- Controle se existe rateio
	Local nPerc			:= 0
	Local nX			:= 0
	Local oModel        := FwModelActive()
	Local nVlrNat		:= Round(oModel:GetValue('ZA2DETAIL','ZA2_VLRNAT'),2)
	Local nValCC        := 0
	Default oModelZA3	:= ""
	Default lVldLine	:= .F.
	Default nPerc		:= 0
	Default nLine		:= 0

	If 	!Empty(oModelZA3) .And. !IsInCallStack("U_TCGP04KM")
		For nX := 1 to oModelZA3:Length()
			oModelZA3:GoLine(nX)
			If !oModelZA3:IsDeleted() .And. !Empty(oModelZA3:GetValue("ZA3_PERC"))
				If nX != nLine
					nPerc += oModelZA3:GetValue("ZA3_PERC")
					nValCC+= oModelZA3:GetValue("ZA3_VLRRAT")
				EndIf
				lRat := .T.
			EndIf
		Next nX

		If lRat .And. ((lVldLine .And. nPerc > 100) .Or. (!lVldLine .And. nPerc <> 100))
			Help(" ",1,"CNMNATEPER") //-- A somatória dos percentuais das entidades contábeis das múltiplas naturezas diferem de 100%.
			lRet := .F.
		EndIf
		If lRet
			If lRat .And. ((lVldLine .And. nValCC > nVlrNat) .Or. (!lVldLine .And. nValCC <> nVlrNat ))
				//Help(" ",1,"CNMNATEPER") //-- A somatória dos percentuais das entidades contábeis das múltiplas naturezas diferem de 100%.
				Help("",1,"CNMNATNVAL",,'A somatória dos valores do centro de custo difere do valor rateado na natureza.',4,1,NIL, NIL, NIL, NIL, NIL, {"Ajuste o valor do centro de custo no rateio."})
				lRet := .F.
			EndIf
		EndIf
	EndIf

	FWRestRows(aSaveLines)
	RestArea(aArea)

Return( lRet )

User Function TFI02VNAT(nOper)

	Local aArea			:= {}
	Local aSaveLines	:= {}
	Local aValores		:= {}
	Local oView			:= Nil
	Local oModel 		:= Nil
	Local oModelZA2		:= Nil
	Local nVlrSolic		:= 0
	Local nRet 			:= 0
	Local nX			:= 0

	Default nOper 		:= 0

	aArea := GetArea()
	aSaveLines := FWSaveRows()

	oModel := FwModelActive()
	oModelZA2 := oModel:GetModel('ZA2DETAIL')

	nVlrSolic := oModel:GetValue('ZA0MASTER','ZA0_VALOR')

	DO CASE
	CASE nOper == 0

		For nX := 1 To oModelZA2:Length()
			oModelZA2:GoLine(nX)
			If oModelZA2:GetValue('ZA2_PERC') > 0
				oModelZA2:SetValue('ZA2_VLRNAT',nVlrSolic * oModelZA2:GetValue('ZA2_PERC') / 100 )
			EndIf
		Next nX
		oView := FwViewActive()
		If oView != Nil .And. oView:IsActive()
			oView:Refresh('ZA2DETAIL')
		EndIf
		oModelZA2:GoLine(1)

	CASE nOper == 1
		nRet :=  nVlrSolic * oModelZA2:GetValue('ZA2_PERC') / 100
	CASE nOper == 2
		nRet := oModelZA2:GetValue('ZA2_VLRNAT') / nVlrSolic * 100
	END DO

	FWRestRows(aSaveLines)
	RestArea(aArea)

Return( nRet )

User Function TFI02VCC(nOper)

	Local aSaveLines	:= FWSaveRows()

	Local oView			:= Nil
	Local oModel 		:= FwModelActive()
	Local oModelZA3		:= oModel:GetModel('ZA3DETAIL')
	Local nVlrNat		:= oModel:GetValue('ZA2DETAIL','ZA2_VLRNAT')
	Local nRet 			:= 0
	Local nX			:= 0

	Default nOper 		:= 0

	DO CASE
	CASE nOper == 0
		For nX := 1 To oModelZA3:Length()
			oModelZA3:GoLine(nX)
			oModelZA3:SetValue('ZA3_VLRRAT',nVlrNat * oModelZA3:GetValue('ZA3_PERC') / 100 )
		Next nX
		oView := FwViewActive()
		If oView:IsActive()
			oView:Refresh('ZA3DETAIL')
		EndIf
		oModelZA3:GoLine(1)
		nRet := nVlrNat
	CASE nOper == 1
		nRet :=  nVlrNat * oModelZA3:GetValue('ZA3_PERC') / 100
	CASE nOper == 2
		nRet := oModelZA3:GetValue('ZA3_VLRRAT') / nVlrNat * 100
	END DO

	FWRestRows(aSaveLines)

Return( nRet )

Static Function fFilDef()

	Local cFiltro := ""

	dbSelectArea('Z99')
	Z99->(dbSetOrder(2))

	If ( Z99->(MSSeek(xFilial("Z99")+RetCodUsr())) )
		If !( Z99->Z99_VISTOD == "S" )
			cFiltro += "ZA0_CODSOL = '" + fRetCodSol(__cUserId) + "' "
		EndIf
	EndIf

Return( cFiltro )

Static Function fCalcImp( oFld )

	Local nCalcIR := 0

	dbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	SA2->(MSSeek(xFilial("SA2") + oFld:GetValue("ZA0_CLIFOR") + oFld:GetValue("ZA0_LOJA")))

	dbSelectArea("SED")
	SED->(dbSetOrder(1))
	SED->(MSSeek(xFilial("SED") + oFld:GetValue("ZA0_NATURE") ))

	//Nao calculo impostos para alguns tipos de titulos
	If !(oFld:GetValue("ZA0_TIPO") $ MVABATIM+"/"+MVPROVIS+"/"+MVTAXA+"/"+MVINSS+"/"+MVISS+"/"+MVTXA +"/"+"SES"+"/"+MV_CPNEG+"/"+"INA")

		nBaseIrrf := oFld:GetValue("ZA0_VALOR")
		nBasePCC := oFld:GetValue("ZA0_VALOR")

		If( SED->ED_CALCIRF == "S" )
			If( SA2->A2_TIPO == "F" )
				nCalcIr	:= Round(NoRound(fa050TabIR(Round(xMoeda(nBaseIrrf,nMoeda,1,oFld:GetValue("ZA0_EMISSA"),MsDecimais(1)+1,nTxMoeda),MsDecimais(1))),3),2)
			Else
				nCalcIr	:=	nValor 	:= nBaseIrrf  * IIF(SED->ED_PERCIRF > 0, SED->ED_PERCIRF, GetMV("MV_ALIQIRF")) / 100
			EndIf
		EndIf

		oFld:SetValue("ZA0_IRRF",nCalcIr)

		If SED->ED_CALCPIS == "S"  .and. SA2->A2_RECPIS == "2"
			If ! GetNewPar("MV_RNDPIS",.F.)
				oFld:SetValue("ZA0_PIS", NoRound((nBasePCC * (SED->ED_PERCPIS / 100)),2) )
			Else
				oFld:SetValue("ZA0_PIS", Round((nBasePCC * (SED->ED_PERCPIS / 100)),2) )
			Endif
		Else
			oFld:SetValue("ZA0_PIS",0)
			nOldPis	 := 0
		EndIf

		nPisCalc := oFld:GetValue("ZA0_PIS")
		nPisBaseC := nBasePCC

		// COFINS
		//³ se natureza pede calculo do COFINS	  ³
		If SED->ED_CALCCOF == "S" .and. SA2->A2_RECCOFI == "2"
			If ! GetNewPar("MV_RNDCOF",.F.)
				oFld:SetValue("ZA0_COFINS",NoRound((nBasePCC * (SED->ED_PERCCOF / 100)),2))
			Else
				oFld:SetValue("ZA0_COFINS",Round((nBasePCC * (SED->ED_PERCCOF / 100)),2))
			Endif
		Else
			oFld:SetValue("ZA0_COFINS",0)
			nOldCofins	 := 0
		EndIf

		nCofCalc := oFld:SetValue("ZA0_COFINS")
		nCofBaseC := nBasePCC

		// CSLL
		//³ se natureza pede calculo do CSLL ³
		If SED->ED_CALCCSL == "S"  .and. SA2->A2_RECCSLL == "2"
			If ! GetNewPar("MV_RNDCSL",.F.)
				oFld:SetValue("ZA0_CSLL",NoRound((nBasePCC * (SED->ED_PERCCSL / 100)),2))
			Else
				oFld:SetValue("ZA0_CSLL",Round((nBasePCC * (SED->ED_PERCCSL / 100)),2))
			Endif
		Else
			oFld:SetValue("ZA0_CSLL",0)
			nOldCsll	  := 0
		Endif

		nCslCalc := oFld:GetValue("ZA0_CSLL")
		nCslBaseC := nBasePCC

	EndIf

Return( .T. )

Static Function fGetUsrName(cUserID)
Return(AllTrim(UsrFullName(cUserID)))

/*/{Protheus.doc} fVldNum
description
@type function
@version 12.1.25
@author Kaique Mathias
@since 6/2/2020
@param oFld, object, param_description
@return logical, logico
/*/

Static Function fVldNum( oFld )

	Local aArea     := SE2->( GetArea() )
	Local lReturn   := .T.
	Local cChaveZA0 := ""
	Local nTamParc  := TAMSX3("E2_PARCELA")[1]

	oFld:SetValue("ZA0_NUM",StrZero(Val(oFld:GetValue("ZA0_NUM")),9))

	cChaveZA0 := FwxFilial("ZA0") + oFld:GetValue("ZA0_NUM") +;
		oFld:GetValue("ZA0_TIPO") + oFld:GetValue("ZA0_CLIFOR") +;
		oFld:GetValue("ZA0_LOJA")

	dbSelectArea("ZA0")
	ZA0->( dbSetOrder( 2 ) )

	If( ZA0->( MSSeek( cChaveZA0 ) ) )
		While !ZA0->(Eof()) .And. ZA0->ZA0_FILIAL == FwxFilial("ZA0") .And.;
				ZA0->ZA0_NUM == oFld:GetValue("ZA0_NUM") .And.;
				ZA0->ZA0_TIPO == oFld:GetValue("ZA0_TIPO") .And.;
				ZA0->ZA0_CLIFOR == oFld:GetValue("ZA0_CLIFOR") .And.;
				ZA0->ZA0_LOJA == oFld:GetValue("ZA0_LOJA")
			If( ZA0->ZA0_STATUS $ '1~2') .AND. ZA0->ZA0_PARCEL == oFld:GetValue("ZA0_PARCEL")
				Help("",1,"TFI02VLNUM1",,'Numero de titulo ja existe para este fornecedor na solicitação de pagamento.',4,1,NIL, NIL, NIL, NIL, NIL, {"Utilize um numero de titulo diferente."})
				lReturn := .F.
				Exit
			EndIf
			ZA0->(dbSkip())
		EndDo
	EndIf

	ZA0->( dbCloseArea() )

	If ( lReturn )

		cChaveSE2 := FwxFilial("SE2") + "MAN" + oFld:GetValue("ZA0_NUM") +;
			oFld:GetValue("ZA0_PARCEL") + oFld:GetValue("ZA0_TIPO") + ;
			oFld:GetValue("ZA0_CLIFOR") + oFld:GetValue("ZA0_LOJA")

		dbSelectArea("SE2")
		SE2->( dbSetOrder( 1 ) )

		If SE2->( MSSeek( cChaveSE2 ) )
			Help("",1,"TFI02VLNUM2",,'Numero de titulo ja existe para este fornecedor no contas a pagar.',4,1,NIL, NIL, NIL, NIL, NIL, {"Utilize um numero de titulo diferente."})
			lReturn := .F.
		EndIf

	EndIf

	RestArea( aArea )

Return( lReturn )

/*/{Protheus.doc} TFIA02CANC
Funcao para cancelar solicitação de pagamento
@type function
@version 1.0
@author Kaique Mathias
@since 23/06/2020
@return return_type, return_description
/*/

User function TFIA02CANC()

	Local aArea         := GetArea()
	Local lContinua     := .T.
	Local lOk           := .F.
	Local cUserSol      := fRetCodSol(ZA0->ZA0_CODSOL,2)
	Local cUsrPermAll   := GetMV("TCP_USPAMP")
	Local _cOrigem      := ''
	Local _cPrefix      := ''
	Private lMsErroAuto := .F.

	If ( __cUserID <> cUserSol ) .And. !( __cUserID $ cUsrPermAll )
		Help( , , "AJUDA", , "Você não tem permissão para alterar títulos de outros usuários.", 1, 0 )
		lContinua := .F.
	EndIf

	If( lContinua )
		If (  ZA0->ZA0_STATUS $ '3~9' )
			Help( , , "AJUDA", , "Solicitação ja foi reprovada ou cancelada! Não pode ser alterado.", 1, 0 )
			lContinua := .F.
		EndIf
	EndIf
//jair
	If( lContinua ) 
		If( Alltrim(ZA0->ZA0_ORIGEM) $ 'FINA376/FINA378/FINA290/FINA870' ) 
			Help(" ",1,"NO_DELETE",,ZA0->ZA0_ORIGEM,3,1)
			lContinua := .F.
		EndIf
	EndIf

If( lContinua )

	lContinua := (Aviso("TCFIA002",OemtoAnsi("Deseja realmente cancelar esta solicitação ? Essa operação não poderá ser desfeita."),{"Sim","Não"}) == 1)

	If( lContinua )
		ProcRegua(2)
		If( ZA0->ZA0_STATUS $ '2' ) //Se finalizado

			_cOrigem := if(EMPTY(ZA0->ZA0_ORIGEM),'FINA050',ZA0->ZA0_ORIGEM)
			_cPrefix := IF(EMPTY(ZA0->ZA0_PREFIXO),'MAN',ZA0->ZA0_PREFIXO)
			IncProc('Verificando titulo a pagar...')
			cAliasSE2 := GetNextAlias()
			BeginSql Alias cAliasSE2
                    SELECT 	E2_FILIAL,
                            E2_FILORIG,
                            E2_PREFIXO,
                            E2_NUM,
                            E2_PARCELA,
                            E2_TIPO,
                            E2_FORNECE,
                            E2_LOJA,
                            E2_ORIGEM
                    FROM 	%Table:SE2% SE2
                    WHERE	SE2.E2_FILIAL	= %xFilial:SE2%	AND
                            SE2.E2_PREFIXO	= %exp:_cPrefix%	AND
                            SE2.E2_NUM		= %exp:ZA0->ZA0_NUM%	AND
                            SE2.E2_PARCELA	= %exp:ZA0->ZA0_PARCEL%	AND
                            SE2.E2_TIPO     = %exp:ZA0->ZA0_TIPO% AND
                            SE2.E2_XCODPGM  = %exp:ZA0->ZA0_CODIGO% AND
                            SE2.E2_ORIGEM   = %exp:_cOrigem% AND
                            SE2.%NotDel%
			EndSql
			While (cAliasSE2)->(!Eof())
				lContinua := (Aviso("TCFIA002",OemtoAnsi("VOCÊ TEM CERTEZA que deseja cancelar esta solicitação ? Essa operação não poderá ser desfeita."),{"Sim","Não"}) == 1)
				If lContinua
					IncProc('Excluindo titulo a pagar...')
					aTitulo := {}
					aAdd(aTitulo,{"E2_FILIAL"	, (cAliasSE2)->E2_FILIAL		,NIL})
					aAdd(aTitulo,{"E2_PREFIXO"	, (cAliasSE2)->E2_PREFIXO		,NIL})
					aAdd(aTitulo,{"E2_NUM"		, (cAliasSE2)->E2_NUM	  		,NIL})
					aAdd(aTitulo,{"E2_PARCELA"	, (cAliasSE2)->E2_PARCELA	  	,NIL})
					aAdd(aTitulo,{"E2_TIPO"		, (cAliasSE2)->E2_TIPO			,NIL})
					aAdd(aTitulo,{"E2_FORNECE"	, (cAliasSE2)->E2_FORNECE	  	,NIL})
					aAdd(aTitulo,{"E2_LOJA"		, (cAliasSE2)->E2_LOJA			,NIL})
					aAdd(aTitulo,{"E2_ORIGEM"	, (cAliasSE2)->E2_ORIGEM		,NIL})

					MSExecAuto({|x,y,z| FINA050(x,y,z)},aTitulo,,5)	//Exclui títulos à pagar

					If lMsErroAuto .And. !IsBlind()
						MOSTRAERRO()
					Else
						lOk := .T.
					Endif
				EndIf

				(cAliasSE2)->(dbSkip())
			EndDo
			(cAliasSE2)->(dbClosearea())
		Else
			IncProc('Verificando alçadas de aprovação...')
			cAliasSCR := GetNextAlias()
			BeginSql Alias cAliasSCR
                    SELECT SCR.*,SCR.R_E_C_N_O_ SCRRECNO 
                    FROM %Table:SCR% SCR 
                    WHERE SCR.CR_FILIAL = %exp:ZA0->ZA0_FILIAL% AND
                        SCR.CR_NUM = %exp:PadR(ZA0->ZA0_CODIGO,TamSX3('CR_NUM')[1])% AND
                        SCR.CR_TIPO = 'AP' AND
                        SCR.CR_STATUS IN ('01','02') AND
                        SCR.%NotDel%
			EndSql
			IncProc('Bloqueando alçadas de aprovação...')
			While (cAliasSCR)->(!Eof())
				dbSelectArea("SCR")
				SCR->( dbGoto( (cAliasSCR)->SCRRECNO ) )
				cUserBkp    := __cUserID
				__cUserID := SCR->CR_USER
				A094SetOp("006")
				oModel094 := FWLoadModel('MATA094')
				oModel094:SetOperation( MODEL_OPERATION_UPDATE )
				If( oModel094:Activate() )
					lOk := oModel094:VldData()
					If lOk
						lOk := oModel094:CommitData()
					else
						aErro := oModel094:GetErrorMessage()

						AutoGrLog("Mensagem do erro: "          + ' [' + AllToChar(aErro[06]) + ']')
						AutoGrLog("Mensagem da solução:"        + ' [' + AllToChar(aErro[07]) + ']')
						AutoGrLog("Valor atribuído: "           + ' [' + AllToChar(aErro[08]) + ']')
						AutoGrLog("Valor anterior: "            + ' [' + AllToChar(aErro[09]) + ']')

						MostraErro()
					EndIf
				Else
					aErro := oModel094:GetErrorMessage()

					AutoGrLog("Mensagem do erro: "          + ' [' + AllToChar(aErro[06]) + ']')
					AutoGrLog("Mensagem da solução:"        + ' [' + AllToChar(aErro[07]) + ']')
					AutoGrLog("Valor atribuído: "           + ' [' + AllToChar(aErro[08]) + ']')
					AutoGrLog("Valor anterior: "            + ' [' + AllToChar(aErro[09]) + ']')

					MostraErro()
				EndIf
				__cUserID := cUserBkp
				(cAliasSCR)->( dbSkip() )
			EndDo
		EndIf

		If( lOk )
			//Atualizo o status da ZA0 para cancelado
			RecLock("ZA0",.F.)
			ZA0->ZA0_STATUS := "9"
			ZA0->( MsUnlock() )

			If( Alltrim(ZA0->ZA0_ORIGEM) == "GPEM670" )
				dbSelectArea("RC1")
				RC1->( dbSetOrder( 2 ) )
				cIndexRC1 := SE2->( xFilial("RC1") + ZA0->ZA0_FILIAL + ZA0->ZA0_PREFIXO + ZA0->ZA0_NUM + ZA0->ZA0_TIPO + ZA0->ZA0_CLIFOR )
				If( RC1->( DbSeek(cIndexRC1) ) )
					While 	RC1->(!Eof()) .And.;
							RC1_FILIAL+RC1_FILTIT+RC1_PREFIX+RC1_NUMTIT+RC1_TIPO+RC1_FORNEC == cIndexRC1
						If ( ZA0->ZA0_PARCEL == RC1->RC1_PARC )
							RecLock("RC1", .F.)
							RC1->RC1_INTEGR := "0"
							RC1->( MsUnLock() )
						EndIf
						RC1->(dbSkip())
					EndDo
				EndIf
			EndIf

			//Notifico por e-mail o cancelamento
			U_TCFIW004(4)

			MsgInfo("Solicitação cancelada com sucesso.")

		EndIf

	EndIf

EndIf

RestArea( aArea )

Return( Nil )
