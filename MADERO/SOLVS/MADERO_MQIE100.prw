#include "totvs.ch"
#include "FWBrowse.ch"
#Include 'FWMVCDef.ch'
#define FRIGORIFICO    "FRIGORIFICO"
#define HORTIfRUTI     "HORTIfRUTI"
#define MERCEARIA      "MERCEARIA"

static aGets
static lLoteOK
static LOCATION


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! MADERO_MQIE100                                                                !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! vRotina de administra��o de pr�-separa��o, com browse listando as separa��es  !
!                  ! iniciadas/finalizadas                                                         !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Revis�es         ! M�rcio A. Zaguetti                                                            !
+------------------+-------------------------------------------------------------------------------+
! Informa��es      !                                                                               !
! Adicionais       !                                                                               !
+------------------+-------------------------------------------------------------------------------+
*/  

user function MQIE100()
Local oBrowse

Private omGetMM

	oBrowse := FWMBrowse():New()
	oBrowse:setAlias( "ZI1" )
	oBrowse:setDescription( "Pr� Inspe��o de entrada" )
	oBrowse:setMenuDef('MADERO_MQIE100')

	oBrowse:addLegend('ZI1_STATUS == "I"','QADIMG16',"Inspe��o Iniciada")
	oBrowse:addLegend('ZI1_STATUS == "E"','QIEIMG16',"Inspe��o Encerrada")
	oBrowse:addLegend('ZI1_STATUS == "R"','ESTOMOVI',"Inspe��o Rejeitada")

	//n�o faz cache na view para ocultar os campos conforme cada tipo de conferencia
	oBrowse:setCacheView(.F.)

	//n�o permite ver registros de outras filias, pois a tela sera operada fisicamente em locais filiais distintas
	//sendo assim n�o pode ver ou editar registros de outras filiais
	oBrowse:SetChgAll(.F.)
	oBrowse:SetSeeAll(.F.)

	oBrowse:activate()

return






/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  ModelDef                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Defini��o do Modelo MVC                                                       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
static function ModelDef()
Local oStructInspecao := FWFormStruct(1,'ZI1', /*bAvalCampo*/, /*lViewUsado*/)
Local oStructProdutos := FWFormStruct(1,'ZI2', /*bAvalCampo*/, /*lViewUsado*/)
Local oStructPallets  := FWFormStruct(1,'ZI3', /*bAvalCampo*/, /*lViewUsado*/)
Local oStructLotes    := FWFormStruct(1,'ZI4', /*bAvalCampo*/, /*lViewUsado*/)
Local oStructNaoConf  := FWFormStruct(1,'ZI5', /*bAvalCampo*/, /*lViewUsado*/)
Local oStructDivergs  := FWFormStruct(1,'ZI6', /*bAvalCampo*/, /*lViewUsado*/)
Local oModel := MPFormModel():New('_MQIE100', /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

	oModel:AddFields( 'INSPECAO' , /*cOwner*/ , oStructInspecao , /*bLinePre*/     ,/*bLinePost*/    , /*bPreVal*/, /*bPosVal*/)
	oModel:AddGrid  ( 'PRODUTOS' , 'INSPECAO' , oStructProdutos , /*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
	oModel:AddGrid  ( 'LOTES'    , 'PRODUTOS' , oStructLotes    , /*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
	oModel:AddGrid  ( 'PALLETS'  , 'PRODUTOS' , oStructPallets  , /*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
	oModel:AddGrid  ( 'NAOCONF'  , 'PALLETS'  , oStructNaoConf  , /*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
	oModel:AddGrid  ( 'DIVERGS'  , 'PRODUTOS' , oStructDivergs  , /*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

	oModel:SetRelation( 'PRODUTOS' , { { 'ZI2_FILIAL', 'xFilial( "ZI2" )' } , { 'ZI2_ID', 'ZI1_ID' } } , ZI2->(IndexKey(1)) )
	oModel:SetRelation( 'LOTES'    , { { 'ZI4_FILIAL', 'xFilial( "ZI4" )' } , { 'ZI4_ID', 'ZI2_ID' }, { 'ZI4_PROD', 'ZI2_PROD' } } , ZI4->(IndexKey(1)) )
	oModel:SetRelation( 'PALLETS'  , { { 'ZI3_FILIAL', 'xFilial( "ZI3" )' } , { 'ZI3_ID', 'ZI2_ID' }, { 'ZI3_PROD', 'ZI2_PROD' } } , ZI3->(IndexKey(1)) )
	oModel:SetRelation( 'NAOCONF'  , { { 'ZI5_FILIAL', 'xFilial( "ZI5" )' } , { 'ZI5_ID', 'ZI3_ID' }, { 'ZI5_PROD', 'ZI3_PROD' }, { 'ZI5_PALLET', 'ZI3_PALLET' } } , ZI5->(IndexKey(1)) )
	oModel:SetRelation( 'DIVERGS'  , { { 'ZI6_FILIAL', 'xFilial( "ZI6" )' } , { 'ZI6_ID', 'ZI2_ID' }, { 'ZI6_PROD', 'ZI2_PROD' } } , ZI6->(IndexKey(1)) )

	oModel:SetDescription("Pr� Inspe��o de Entrada")

	oModel:SetPrimaryKey( { "ZI1_FILIAL", "ZI1_ID" } )

	noAll(oModel:GetModel('PRODUTOS'))
	noAll(oModel:GetModel('LOTES'))
	noAll(oModel:GetModel('PALLETS'))
	noAll(oModel:GetModel('NAOCONF'))
	noAll(oModel:GetModel('DIVERGS'))

	oModel:InstallEvent("MQIE100Event", /*cOwner*/, MQIE100Event():New())

return oModel



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  noAll                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para atribuir parametros ao modelo                                     !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
static function noAll(oModel)

	oModel:SetOptional(.T.)
	oModel:SetNoDeleteLine(.T.)
	oModel:SetNoInsertLine(.T.)
	oModel:SetNoUpdateLine(.T.)

return



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  MQIE100Event                                                                 !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Eventos para o Modelo MVC                                                     !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
class MQIE100Event from FWModelEvent
    method New()
    method After()
    method ModelPosVld()
end class




/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  New                                                                          !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Metodo construtor, sem conteudo porque � obrigat�rio                          !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
method New() Class MQIE100Event
return



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  After                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! M�todo que � chamado pelo MVC quando ocorrer as a��es do commit               !
!                  ! depois da grava��o de cada submodelo (field ou cada linha de uma grid)        !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
method After(oModel, cModelId, cAlias, lNewRecord) Class MQIE100Event

	//-> inspecao
	If cModelId == "INSPECAO"

		SF1->( dbSetOrder(1) )
		SF1->( dbSeek( xFilial("SF1") + ZI1->(ZI1_DOC+ZI1_SERIE+ZI1_FORN+ZI1_LOJA) ) )

		If SF1->( Found() )

			//na exclus�o
			If oModel:GetOperation() == MODEL_OPERATION_DELETE
				Reclock("SF1",.F.)
				SF1->F1_PIPSTAT := "B"
				SF1->( MsUnlock() )

				event("Inspe��o Excluida","Inspe��o da nota " +SF1->(F1_FILIAL+"/"+F1_DOC+"/"+F1_SERIE+"/"+F1_FORNECE+"/"+F1_LOJA)+ " - RECNO " +cValToChar(SF1->(Recno()))+" foi Excluida.")
			EndIf

			//na altera��o para libera��o
			If oModel:GetOperation() == MODEL_OPERATION_UPDATE .and. IsInCallStack("u_MQIE100Lib")
				Reclock("SF1",.F.)
				SF1->F1_PIPSTAT := "L"
				//#TB20191119 Thiago Berna - Ajuste para alterar o campo STATCON para 1
				SF1->F1_STATCON := '1'
				SF1->( MsUnlock() )

				event("Inspe��o Liberada para Classifica��o","Inspe��o da nota " +SF1->(F1_FILIAL+"/"+F1_DOC+"/"+F1_SERIE+"/"+F1_FORNECE+"/"+F1_LOJA)+ " - RECNO " +cValToChar(SF1->(Recno()))+" foi liberada para classifica��o antes do inspe��o de todos os Produtos.")
			EndIf

		EndIf

	EndIf

return



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  ModelPosVld                                                                  !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        !M�todo que � chamado pelo MVC quando ocorrer as a��es de pos valida��o do Model!
!                  !Esse evento ocorre uma vez no contexto do modelo principal.                    !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
method ModelPosVld(oModel, cModelId) class MQIE100Event

	//na exclus�o na Inspe��o
	//#TB20191111 Thiago Berna - Ajuste para desconsiderar esta regra.
	/*
	If oModel:GetOperation() == MODEL_OPERATION_DELETE

		SF1->( dbSetOrder(1) )
		SF1->( dbSeek( xFilial("SF1") + ZI1->(ZI1_DOC+ZI1_SERIE+ZI1_FORN+ZI1_LOJA) ) )

		If SF1->( Found() ) .And. ! Empty(SF1->F1_STATUS)
			Help("",1,"PRE-INSP_CLASS",,"N�o � possivel excluir a inspe��o desta nota, pois j� foi classificada ou est� bloqueada.",4,1)
			return .F.
		EndIf

	EndIf*/

return .T.



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  ViewDef                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Defini��o da View                                                             !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
static function ViewDef()
Local oStructInspecao := FWFormStruct(2,'ZI1', /*bAvalCampo*/, /*lViewUsado*/)
Local oStructProdutos := FWFormStruct(2,'ZI2', /*bAvalCampo*/, /*lViewUsado*/)
Local oStructPallets  := FWFormStruct(2,'ZI3', /*bAvalCampo*/, /*lViewUsado*/)
Local oStructLotes    := FWFormStruct(2,'ZI4', /*bAvalCampo*/, /*lViewUsado*/)
Local oStructNaoConf  := FWFormStruct(2,'ZI5', /*bAvalCampo*/, /*lViewUsado*/)
Local oStructDivergs  := FWFormStruct(2,'ZI6', /*bAvalCampo*/, /*lViewUsado*/)
Local oModel := ModelDef()
Local oView  := FWFormView():New()

	oStructProdutos:RemoveField("ZI2_ID")
	oStructLotes:RemoveField("ZI4_ID")
	oStructLotes:RemoveField("ZI4_PROD")
	oStructPallets:RemoveField("ZI3_ID")
	oStructPallets:RemoveField("ZI3_PROD")
	oStructNaoConf:RemoveField("ZI5_ID")
	oStructNaoConf:RemoveField("ZI5_PROD")
	oStructNaoConf:RemoveField("ZI5_PALLET")
	oStructDivergs:RemoveField("ZI6_ID")
	oStructDivergs:RemoveField("ZI6_PROD")
	

	oView:SetModel( oModel )

	oView:AddField('vINSPECAO', oStructInspecao, 'INSPECAO')
	oView:AddGrid ('vPRODUTOS', oStructProdutos, 'PRODUTOS')
	oView:AddGrid ('vLOTES'   , oStructLotes   , 'LOTES')
	oView:AddGrid ('vPALLETS' , oStructPallets , 'PALLETS')
	oView:AddGrid ('vNAOCONF' , oStructNaoConf , 'NAOCONF')
	oView:AddGrid ('vDIVERGS' , oStructDivergs , 'DIVERGS')

	//cria um painel com um memo	
	//#TB2019108 Thiago Berna - Ajuste para liberar o objeto criado
	//oView:AddOtherObject('vOBSERV', {|panel| makeObservPanel(panel, oModel) } )
	oView:AddOtherObject('vOBSERV', {|panel| makeObservPanel(panel, oModel) },{|panel|killobspan(panel, oModel)} )
	
	//atualiza o memo conforme muda de linha
	oView:SetViewProperty('vPALLETS', 'CHANGELINE', {{ |oView, cViewID| omGetMM:refresh() } })

	oView:setContinuousForm(.T.)
	oView:CreateHorizontalBox('LINE01' , 24 )
	oView:CreateHorizontalBox('LINE02' , 24 )
	oView:CreateHorizontalBox('LINE03' , 24 )
	oView:CreateHorizontalBox('LINE04' , 24 )
	oView:CreateVerticalBox('LINE03COLUMN01' , 30 ,'LINE03' )
	oView:CreateVerticalBox('LINE03COLUMN02' , 70 ,'LINE03' )
	oView:CreateVerticalBox('LINE04COLUMN01' , 50 ,'LINE04' )
	oView:CreateVerticalBox('LINE04COLUMN02' , 25 ,'LINE04' )
	oView:CreateVerticalBox('LINE04COLUMN03' , 25 ,'LINE04' )

	oView:SetOwnerView( 'vINSPECAO','LINE01' )

	oView:SetOwnerView( 'vPRODUTOS' ,'LINE02' )
	oView:EnableTitleView('vPRODUTOS' , 'Produtos da nota fiscal de entrada' )

	oView:SetOwnerView( 'vLOTES' ,'LINE03COLUMN01' )
	oView:EnableTitleView('vLOTES' , 'Lotes do produto' )

	oView:SetOwnerView( 'vPALLETS' ,'LINE03COLUMN02' )
	oView:EnableTitleView('vPALLETS' , 'Pallets do produto' )

	oView:SetOwnerView( 'vDIVERGS' ,'LINE04COLUMN01' )
	oView:EnableTitleView('vDIVERGS' , 'Diverg�ncias do Produto' )

	oView:SetOwnerView( 'vNAOCONF' ,'LINE04COLUMN02' )
	oView:EnableTitleView('vNAOCONF' , 'N�o conformidades do pallet' )

	oView:SetOwnerView( 'vOBSERV' ,'LINE04COLUMN03' )
	oView:EnableTitleView('vOBSERV' , 'Observa��o do pallet' )

	oView:SetViewCanActivate({ |view| viewCanActivate(view) })

return oView


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  viewCanActivate                                                              !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Ativa��o dos componentes da view                                              !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
static function viewCanActivate(oView)

	//se n�o for inclus�o
	If oView:getOperation() != MODEL_OPERATION_INSERT
		//s� tem SIF para frigorifico
		If ZI1->ZI1_TIPO != Left(FRIGORIFICO,1)
			oView:getViewStruct('LOTES'):RemoveField('ZI4_SIF')
			oView:getViewStruct('PALLETS'):RemoveField('ZI3_SIF')
		EndIf
		If ZI1->ZI1_TIPO == Left(HORTIfRUTI,1)
			oView:getViewStruct('LOTES'):RemoveField('ZI4_LTEMB')
		EndIf
	EndIf

return .T.



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  makeObservPanel                                                              !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Cria��o do Painel para mostrar a observa��o gravado num MEMO                  !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
static function makeObservPanel(oPanel, oModel)

		omGetMM := tMultiget():new( 15, 3, bSetGet(oModel:GetModel('PALLETS'):getValue('ZI3_OBSERV')),  oPanel, __DlgWidth(oPanel)-5, __DlgHeight(oPanel)-15, /*fonte*/, , , , , .T.,,,/*when*/,,,.T.,/*valid*/,,,/*border*/,.T.)

return

/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  killobspan                                                                   !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Elimina o Painel                                                              !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Thiago Berna                                                                  !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 08/10/2019                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
Static Function killobspan(oPanel, oModel)		
		oPanel:FreeChildren()
Return



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  MenuDef                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Defini��o das op��es do Menu                                                  !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
Static Function MenuDef()
Local aRotina := {}
Local aInspecoes := {}

	ADD OPTION aInspecoes Title "Frigorifico" Action 'u_MQIE100Fri' OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aInspecoes Title "Mercearia"   Action 'u_MQIE100Mer' OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aInspecoes Title "Hortifruti"  Action 'u_MQIE100Hor' OPERATION MODEL_OPERATION_INSERT ACCESS 0

	ADD OPTION aRotina Title "Visualizar"  Action 'VIEWDEF.MADERO_MQIE100' OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina Title "Inspecionar" Action aInspecoes               OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina Title "Continuar Inspe��o"         Action "u_MQIE100Cont" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRotina Title "Liberar para Classifica��o" Action "u_MQIE100Lib"  OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina Title "Excluir"     Action 'u_MQIE100Del' OPERATION MODEL_OPERATION_DELETE ACCESS 0
	ADD OPTION aRotina Title "Eventos"     Action 'u_MQIE100Evt' OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina Title "Email"     Action 'u_MMteste' OPERATION MODEL_OPERATION_VIEW ACCESS 0

Return aRotina





/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  MQIE100Cont                                                                  !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para coninua��o de uma inspe��o                                        !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
user function MQIE100Cont()

	//posiciona na nota
	SF1->( dbSetOrder(1) )
	SF1->( dbSeek( xFilial("SF1") + ZI1->(ZI1_DOC+ZI1_SERIE+ZI1_FORN+ZI1_LOJA) ) )

	If SF1->( Found() )

		If ZI1->ZI1_TIPO == Left(FRIGORIFICO,1)
			return u_MQIE100Fri()
		EndIf

		If ZI1->ZI1_TIPO == Left(MERCEARIA,1)
			return u_MQIE100Mer()
		EndIf

		If ZI1->ZI1_TIPO == Left(HORTIfRUTI,1)
			return u_MQIE100Hor()
		EndIf

	EndIf

return



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  MQIE100Lib                                                                   !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para libera��o da Inspe��o para classifica��o                          !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
user function MQIE100Lib()

	//habilita apenas salvar (liberar) e cancelar
	Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Liberar para Classifica��o"},{.T.,"Cancelar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}

	//verifica se j� foi encerrado
	If ZI1->ZI1_STATUS $ "ER"
		Help("",1,"MADERO_PREINSP_ENCERRADA",,"A pr� inspe��o j� foi encerrada.",4,1)
		return
	EndIf

	//abre tela para confirma��o
	FWExecView("Liberar para Classifica��o","MADERO_MQIE100",MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOK*/,{|| validaLiberacao() },/*nPercReducao*/,aEnableButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/)

return



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  MQIE100Evt                                                                   !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para exibir os eventos de inspe��o                                     !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
user function MQIE100Evt()
Local oModal
Local oBrowse
Local oMemo, oGrid, oGet

	oModal	:= FWDialogModal():New()
	oModal:SetEscClose(.T.)
	oModal:setTitle("Eventos da Inspe��o " + ZI1->ZI1_ID)
	oModal:SetBackground(.T.)
	oModal:SetFreeArea(GetScreenRes()[1]/2*.9,GetScreenRes()[2]/2*.7)
	oModal:enableFormBar(.T.)
	oModal:createDialog()

    oMemo       := tPanel():New(01,01,,oModal:getPanelMain(),,,,,,100,60)
    oMemo:Align := CONTROL_ALIGN_BOTTOM

    oGrid       := tPanel():New(01,01,,oModal:getPanelMain(),,,,,,100,20)
    oGrid:Align := CONTROL_ALIGN_ALLCLIENT

	oGet := tMultiget():new( 15, 3, bSetGet(ZI7->ZI7_OBSERV),  oMemo, 5, 5, TFont():New('Arial',,-16), , , , , .T.,,,/*when*/,,,.T.,/*valid*/,,,/*border*/,.T.)
    oGet:Align := CONTROL_ALIGN_ALLCLIENT


    oBrowse := FWBrowse():New()
	oBrowse:SetDescription("")
	oBrowse:setOwner(oGrid)
	oBrowse:setDataTable()
	oBrowse:SetAlias("ZI7")
	oBrowse:setColumns({;
		column('ZI7_DATA') ,;
		column('ZI7_HORA') ,;
		column('ZI7_USER') ,;
		column('ZI7_NOME',,{|| UsrFullName(ZI7_USER) }) ,;
		column('ZI7_DATA') ,;
		column('ZI7_EVENTO') ;
	})
	oBrowse:setFilterDefault("ZI7->ZI7_FILIAL == '"+xFilial("ZI7")+"' .And. ZI7->ZI7_ID = '"+ZI1->ZI1_ID+"'")
	oBrowse:disableReport()
	oBrowse:disableConfig()
	oBrowse:disableFilter()
	oBrowse:setChange({|| oGet:refresh() })
	oBrowse:activate()

	oModal:addCloseButton()

	oModal:activate()


return



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  validaLiberacao                                                              !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Valida��o da confirma��o da inspe��o                                          !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
static function validaLiberacao()

	Local oView		:= FWViewActive()
	Local oModel    := oView:GetModel()

	//pede confirma��o para o usu�rio
	If APMsgYesNo("Ap�s a classifica��o da pre nota de entrada, com uma inspe��o n�o concluida, os itens que ainda n�o foram inspecionados n�o ser�o liberados do CQ automaticamente e n�o ser� feito analise de diferen�as, pois � feito apenas na classifica��o. Continua?", "Libera��o para classifica��o")

		//modifica o campo STATUS para Encerrado
		oModel:GetModel("INSPECAO"):loadValue("ZI1_STATUS","E")

		//muda estado da view e do modelo para modificado
		oView:lModify  := .T.
		oModel:lModify := .T.

		//e retorna true
		return .T.

	EndIf

return .F.




/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! MQIE100Fri                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Inspe��o frigorifico para o Menu                                              !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
user function MQIE100Fri()

	//seta a localiza��o
	LOCATION := FRIGORIFICO

	//e chama fun��o de inspe��o
	MQIE100Insp()

return



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! MQIE100Hor                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Inspe��o Hortifruti para o Menu                                               !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
user function MQIE100Hor()

	//seta a localiza��o
	LOCATION := HORTIfRUTI

	//e chama fun��o de inspe��o
	MQIE100Insp()

return



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! MQIE100Mer                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Inspe��o Mercearia para o Menu                                                !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
user function MQIE100Mer()

	//seta a localiza��o
	LOCATION := MERCEARIA

	//e chama fun��o de inspe��o
	MQIE100Insp()

return



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! MQIE100Insp                                                                   !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para abrir tela de parametro recursivamente e chamando tela de inspe��o!
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function MQIE100Insp()

	Local cProxID 	:= ''
	Local aArea 	:= GetArea()
	Local lSegue	:= .T.
	//Private cEndEntrada	 := space(Len(ZI3->ZI3_ENDENT))
	Private cEndEntrada	:= Posicione("SB5",1,xFilial("SB5")+ZI2->ZI2_PROD,"B5_ENDENT")

	//pre inspe��o desativada
	If !SuperGetMV("MDR_PREINS",,.F.)
		Help("",1,"MADERO_PREINSP_DESATIVADA",,"N�o � possivel fazer a pr� inspe��o, pois est� desativada nesta Filial. Ative com parametro MDR_PREINS.",4,1)
		return
	EndIf

	//se for continua��o
	If IsInCallStack('u_MQIE100Cont')

		//se tiver sido rejeitada totalmente
		If ZI1->ZI1_STATUS == "R"
			Aviso('REJEITADO','Inspe��o foi rejeitada totalmente, por isso n�o � possivel retomar a inspe��o.',{'Sair'},1)
			return
		EndIf

		return Inspeciona()
	EndIf

	//a tela de parametro � recursiva
	While getPreNota()

		ZI1->( dbSetOrder(1) )
		ZI1->( dbSeek( xFilial("ZI1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) ) )

		If ZI1->( Found() )
			If Left(LOCATION,1) != ZI1->ZI1_TIPO
				Help("",1,"MADERO_PRE_INSP",,"N�o � possivel continuar uma inspe��o de "+LOCATION+", pois foi iniciada como "+getTipo(ZI1->ZI1_TIPO)+".",4,1)
				Loop
			EndIf
			If Aviso('Aten��o','Est� nota j� teve inspe��o iniciada, deseja retomar a inspe��o?',{'Continuar','Voltar'},1) != 1
				Loop
			EndIf

			//se tiver sido rejeitada totalmente
			If ZI1->ZI1_STATUS == "R"
				Aviso('REJEITADO','Inspe��o foi rejeitada totalmente, por isso n�o � possivel retomar a inspe��o.',{'Sair'},1)
				Loop
			EndIf

		Else

			begin transaction

			//#TB20191023 Thiago Berna - Ajuste para verificar se a numeracao ja existe
			cProxID := GetSX8Num("ZI1","ZI1_ID")
			DbSelectArea('ZI1')
			ZI1->(DbSetOrder(2))
			If ZI1->(DbSeek(xFilial('ZI1') + cProxID))
				MsgInfo("Falha com a numera��o autom�tica. ZI1_ID : " + cProxID + "j� existe. Verifique a numera��o on License Server","MQIE100 - Opera��o Cancelada")
				RollbackSx8()
				DisarmTransaction()
				lSegue := .F.
			Else

				Reclock("ZI1",.T.)
				ZI1->ZI1_FILIAL := xFilial("ZI1")
				ZI1->ZI1_DOC    := SF1->F1_DOC
				ZI1->ZI1_SERIE  := SF1->F1_SERIE
				ZI1->ZI1_FORN   := SF1->F1_FORNECE
				ZI1->ZI1_LOJA   := SF1->F1_LOJA
				ZI1->ZI1_DTINIC := Date()
				ZI1->ZI1_HRINIC := Left(Time(),5)
				ZI1->ZI1_INSP   := RetCodUsr()
				ZI1->ZI1_INSPN  := UsrFullName()
				//#TB20191023 Thiago Berna - Ajuste para verificar se a numeracao ja existe
				//ZI1->ZI1_ID     := GetSX8Num("ZI1","ZI1_ID")
				ZI1->ZI1_ID     := cProxID
				ZI1->ZI1_TIPO   := Left(LOCATION,1)
				ZI1->ZI1_STATUS := 'I' //Iniciado
				ZI1->ZI1_CHVNFE	:= SF1->F1_CHVNFE
				ZI1->( MsUnlock() )

				ConfirmSX8()

				event("Inspe��o iniciada","Inspe��o iniciada para nota " +SF1->(F1_FILIAL+"/"+F1_DOC+"/"+F1_SERIE+"/"+F1_FORNECE+"/"+F1_LOJA)+ " - RECNO " +cValToChar(SF1->(Recno()))+".")

				SD1->( dbSetOrder(1) )
				SD1->( dbSeek( xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) ) )

				While ! SD1->( Eof() ) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_TIPO) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)
					If SD1->D1_PIPSTAT == 'S'

						ZI2->( dbSetOrder(1) )
						ZI2->( dbSeek( xFilial("ZI2") + ZI1->ZI1_ID + SD1->D1_COD ) )

						If ZI2->( Found() )
							Reclock("ZI2",.F.)
							ZI2->ZI2_QUANT += SD1->D1_QUANT
							ZI2->( MsUnlock() )
							event("Somado produto","Item "+SD1->D1_ITEM+" - Produto " +alltrim(SB1->B1_COD)+ " com quantidade " + cValtoChar(SD1->D1_QUANT) + ".")
						Else
							SB1->( dbSetOrder(1) )
							SB1->( dbSeek( xFilial("SB1") + SD1->D1_COD ) )

							Reclock("ZI2",.T.)
							ZI2->ZI2_FILIAL := xFilial("ZI2")
							ZI2->ZI2_ID     := ZI1->ZI1_ID
							ZI2->ZI2_PROD   := SD1->D1_COD
							ZI2->ZI2_DESC   := SB1->B1_DESC
							ZI2->ZI2_UM     := SD1->D1_UM
							ZI2->ZI2_QUANT  := SD1->D1_QUANT
							ZI2->ZI2_STATUS := 'P' //Pendente
							ZI2->( MsUnlock() )
							event("Adicionado produto","Item "+SD1->D1_ITEM+" - Produto " +alltrim(SB1->B1_COD)+ " com quantidade " + cValtoChar(SD1->D1_QUANT) + ".")

						EndIf

					EndIf
					SD1->(dbSkip())
				EndDo

				If ZI1->ZI1_ID != ZI2->ZI2_ID
					DisarmTransaction()
				EndIf

			EndIf

			end transaction

		EndIf

		//rotina de inspe��o
		If lSegue
			Inspeciona()
		EndIf

		//se foi chamada pela tela de administra��o
		If FunName() == 'MQIE100'
			//n�o faz loop
			return
		EndIf
	EndDo

	RestArea(aArea)

return




/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! Inspeciona                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o principal para Inspe��o                                                !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function Inspeciona()
Local oModal
Local oLayer
Local oBrowse
Local nTamTop
Local cAliasEntity := IIf(SF1->F1_TIPO $ "DB","SA1","SA2")

	//posiciona (mesma chave)
	(cAliasEntity)->( dbSetOrder(1) )
	(cAliasEntity)->( dbSeek( xFilial(cAliasEntity) + SF1->F1_FORNECE + SF1->F1_LOJA ) )

	oModal := FWDialogModal():New()

	oModal:SetEscClose(.T.)
	oModal:enableAllClient()
	oModal:SetTitle("MADERO  -  Recebimento de Mercadorias  -  " + LOCATION)
	oModal:CreateDialog()
	oModal:createFormBar()

	//calculo para fixar o tamanho do cabe�alho
	nTamTop := int( 80 / oModal:nFreeHeight * 100)

	oLayer := FWLayer():New()
	oLayer:Init( oModal:getPanelMain(), .F.)

	//divide a tela horizontalmente, 20% encima, 80% embaixo
	oLayer:AddLine('cabecalho'  ,nTamTop,.F.)
	oLayer:AddLine('itens',100-nTamTop,.F.)

	//depois divide a parte de cima verticalmente, meio a meio
	oLayer:addCollumn( "esquerda" , 50, .F.,"cabecalho" )
	oLayer:addCollumn( "direita", 50, .F.,"cabecalho" )

	//fornecedor/cliente
	TGet():New(10, 10, bSetGet(SF1->F1_FORNECE) ,oLayer:GetColPanel('esquerda','cabecalho'), 60, 16, "",,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'SF1->F1_FORNECE' ,,,,,,,IIf(cAliasEntity=='SA1',"Cliente","Fornecedor"),1)
	TGet():New(10, 80, bSetGet(SF1->F1_LOJA)    ,oLayer:GetColPanel('esquerda','cabecalho'), 30, 16, "",,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'SF1->F1_LOJA'    ,,,,,,,'Loja',1)
	If cAliasEntity=='SA1'
		TGet():New(10,120, bSetGet(SA1->A1_NOME),oLayer:GetColPanel('esquerda','cabecalho'),160, 16, "",,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'SA1->A1_NOME',,,,,,,'Nome',1)
	Else
		TGet():New(10,120, bSetGet(SA2->A2_NOME),oLayer:GetColPanel('esquerda','cabecalho'),160, 16, "",,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'SA2->A2_NOME',,,,,,,'Nome',1)
	EndIf
	//inspetor
	TGet():New(45, 10, bSetGet(RetCodUsr())  ,oLayer:GetColPanel('esquerda','cabecalho'), 60, 16, "",,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'RetCodUsr()' ,,,,,,,"Inspetor",1)
	TGet():New(45, 80, bSetGet(UsrFullName()),oLayer:GetColPanel('esquerda','cabecalho'),160, 16, "",,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'UsrFullName()',,,,,,,'Nome',1)

	//dados da nota fiscal
	TGet():New(10,10, bSetGet(SF1->F1_CHVNFE) ,oLayer:GetColPanel('direita','cabecalho') ,150, 16, "",,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'SF1->F1_CHVNFE' ,,,,,,,'Chave da NFe SEFAZ',1)
	//segunda linha
	TGet():New(45, 10, bSetGet(SF1->F1_DOC)    ,oLayer:GetColPanel('direita','cabecalho') , 60, 16, "",,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'SF1->F1_DOC'    ,,,,,,,'N�mero',1)
	TGet():New(45, 80, bSetGet(SF1->F1_SERIE)  ,oLayer:GetColPanel('direita','cabecalho') , 30, 16, "",,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'SF1->F1_SERIE'  ,,,,,,,'S�rie',1)
	TGet():New(45,120, bSetGet(SF1->F1_EMISSAO),oLayer:GetColPanel('direita','cabecalho') , 60, 16, "",,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'SF1->F1_EMISSAO',,,,,,,'Emiss�o',1)

	oBrowse := FWBROWSE():New()
	oBrowse:SetOwner( oLayer:GetLinePanel('itens') )
	oBrowse:SetDataTable()
	oBrowse:setAlias("ZI2")
	oBrowse:DisableReport()
	oBrowse:setFilterDefault("ZI2->ZI2_FILIAL == '"+xFilial("ZI1")+"' .And. ZI2->ZI2_ID == '"+ZI1->ZI1_ID+"'")
	oBrowse:SetDoubleClick( { || InspItem() } )
	oBrowse:addLegend('ZI2_STATUS == "P"', 'PENDENTE', 'Pr� inspe��o n�o iniciada')
	oBrowse:addLegend('ZI2_STATUS == "I"', 'QADIMG16', 'Pr� Inspe��o em andamento')
	oBrowse:addLegend('ZI2_STATUS == "C"', 'QIEIMG16', 'Pr� Inspe��o conclu�da')
	oBrowse:SetColumns({;
		column("ZI2_STATUS") ,;
		column("ZI2_PROD") ,;
		column("ZI2_DESC") ,;
		column("ZI2_UM") ,;
		column("ZI2_QUANT"),;
		column("ZI2_INSP"),;
		column("ZI2_INSP","Diferen�a",{|| ZI2_INSP - ZI2_QUANT }) })

	oBrowse:Activate()

	oModal:addButtons({{"", "Fechar"       , {|| oModal:Deactivate() }, "Clique aqui para Enviar",,.T.,.T.}})
	oModal:addButtons({{"", "Inspecionar"  , {|| InspItem(), oBrowse:Refresh(.F.) }, "Clique aqui para Enviar",,.T.,.T.}})
	oModal:addButtons({{"", "Refresh"      , {|| oBrowse:Refresh(.T.) }, "Clique aqui para Enviar",,.T.,.T.}})

	If ! InspIniciada()
		oModal:addButtons({{"", "Rejei��o Total"  , {|| IIf( RejeicaoTotal(), oModal:Deactivate(), oBrowse:Refresh(.F.) ) }, "Clique aqui para Enviar",,.T.,.T.}})
	EndIf

	oModal:activate()

return




/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! InspItem                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Inspe��o por produto                                                          !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function InspItem()
Local oModal
Local oLayer
Local winProd
Local nTamProd
Local nTamLote := 0
Local lTelaLote

	If ZI2->ZI2_STATUS == "C"
		If ZI1->ZI1_STATUS == "I" .And. empty(SF1->F1_STATUS)
			If Aviso('Concluida','A Pr� Inspe��o deste item j� foi conclu�da. Deseja retomar?',{'Sim','Sair'},1) == 2
				return
			EndIf
			Reclock("ZI2",.F.)
			ZI2->ZI2_STATUS := "I"
			ZI2->( MsUnlock() )
		Else
			Help("",1,"PRE-INSP_OK",,"A Pr� Inspe��o deste item j� foi conclu�da.",4,1)
			return
		EndIf
	EndIf

	Private cSIF      := CriaVar('ZI3_SIF')
	Private dValidade := StoD('')
	Private cLote     := CriaVar('ZI4_LTEMB')

	Private cID      := ZI2->ZI2_ID
	Private cProduto := ZI2->ZI2_PROD

	//frigorifico � por QUILO, SEMPRE!
	//mercearia e hortifruti, nem sempre
	//Private lPesagem := (LOCATION == FRIGORIFICO)// .Or. ZI2->ZI2_UM == "KG")
	Private lPesagem := (LOCATION == FRIGORIFICO .Or. LOCATION == HORTIfRUTI)

	cEndEntrada	:= Posicione("SB5",1,xFilial("SB5")+ZI2->ZI2_PROD,"B5_ENDENT")
	lLoteOK := .F.

	//inicia json com variaveis estaticas
	aGets := JsonObject():new()

	//posiciona no produto
	SB1->( dbSetOrder(1) )
	SB1->( dbSeek( xFilial("SB1") + cProduto ) )

	//#TB20191008 Thiago Berna - Ajuste para validar se o produto possui controle de lote e endereco ativado
	If  !SB1->B1_LOCALIZ == 'S' .Or. !SB1->B1_RASTRO == 'L'
		MsgInfo("Produto sem controle de lote e endere�o ativado.","MQIE100 - Opera��o Cancelada")
		Return
	EndIf

	//box com o LOTE s� tem para frigorifico para mercearia quando o produto controla Lote
	lTelaLote := (LOCATION == FRIGORIFICO .Or. LOCATION == MERCEARIA .And. Rastro(SB1->B1_COD))

	oModal := FWDialogModal():New()
	oModal:SetEscClose(.F.)
	oModal:SetTitle("MADERO  -  Recebimento de Mercadorias  -  " + LOCATION + "  -   " + SB1->B1_DESC)
	oModal:enableAllClient()
	oModal:CreateDialog()
	oModal:createFormBar()

	//calculo para fixar o tamanho do cabe�alho
	nTamProd := int( 55 / oModal:nFreeHeight * 100)

	oLayer := FWLayer():New()
	oLayer:Init( oModal:getPanelMain(), .F.)

	//divide a tela horizontalmente, 20% encima, 80% embaixo
	oLayer:AddLine('cabecalho',nTamProd,.F.)
	oLayer:AddLine('resto'  ,100-nTamProd,.F.)

	oLayer:addCollumn('produto' ,100,.F., 'cabecalho')
	If lTelaLote
		nTamLote := int( 250 / oModal:nFreeWidth * 100)
		oLayer:addCollumn('lote'    , nTamLote,.F., 'resto')
	EndIf
	oLayer:addCollumn('pallet'  , 100-nTamLote,.F., 'resto')

	//cria uma janela
	oLayer:addWindow( 'produto', "winProd","Inspe��o do produto", 100, .F., .T., {||  }, 'cabecalho')
	//e pega o panel do janela
	winProd := oLayer:getWinPanel('produto',"winProd",'cabecalho')

	//produto
	TGet():New(0,  5, bSetGet(ZI2->ZI2_PROD)  , winProd ,  75, 16, "",,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'ZI2->ZI2_PROD'  ,,,,,,,'Produto',1)
	TGet():New(0, 90, bSetGet(ZI2->ZI2_DESC)  , winProd , 150, 16, "",,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'ZI2->ZI2_DESC'  ,,,,,,,'Descri��o',1)
	TGet():New(0,250, bSetGet(ZI2->ZI2_UM)    , winProd ,  20, 16, "",,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'ZI2->ZI2_UM'    ,,,,,,,"Unidade",1)
	TGet():New(0,280, bSetGet(ZI2->ZI2_QUANT) , winProd ,  80, 16, PesqPict("ZI2","ZI2_QUANT"),,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'ZI2->ZI2_QUANT' ,,,,,,,'Quantidade',1)
	TGet():New(0,370, bSetGet(ZI2->ZI2_INSP)  , winProd ,  80, 16, PesqPict("ZI2","ZI2_INSP" ),,,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'ZI2->ZI2_INSP'  ,,,,,,,'Inspecionada',1)

	//frigorifico
	If lTelaLote
		//cria uma janela com titulo
		oLayer:addWindow( 'lote', "winLote","Lotes/Embarques", 100, .F., .T., {||  }, 'resto' )

		//SIF
		telaLotes(oLayer:getWinPanel('lote',"winLote",'resto') )
	EndIf

	//cria uma janela com titulo
	oLayer:addWindow( 'pallet', "winPallet","Pallets", 100, .F., .T., {||  }, 'resto' )

	telaPallet(oLayer:getWinPanel('pallet',"winPallet",'resto'))

	oModal:addButtons({{"", "Fechar", {|| oModal:Deactivate() }, "Clique aqui para Enviar",,.T.,.T.}})
	oModal:addButtons({{"", "Encerrar Produto", {|| IIf(EncerrarProduto(),oModal:Deactivate(),) }, "Clique aqui para Enviar",,.T.,.T.}})

	If LOCATION == FRIGORIFICO
		oModal:addButtons({{"", "Pr�ximo S.I.F.", {|| NextSIF() }, "Clique aqui para Enviar",,.T.,.T.}})
	EndIf

	oModal:activate()

	//libera memoria
	FreeObj(aGets)

return



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EncerrarProduto                                                               !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Encerramento da inspe��o do produto                                           !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function EncerrarProduto()
Local lTotal := .F.
Local nDiferenca := ZI2->(ZI2_INSP-ZI2_QUANT)

	If lLoteOK
		//precisa ter pallets num SIF
		ZI3->( dbSetOrder(1) )
		ZI3->( dbSeek( xFilial("ZI3") + cID + cProduto + cSIF ) )

		If ! ZI3->( Found() )
			Help("",1,"PRE-INSP_SIF",,"Para encerrar um SIF precisa ao menos um pallets pesado.",4,1)
			return .F.
		EndIf
	EndIf

	//verifica se h� diferen�a
	If nDiferenca != 0
		If Aviso("Diferen�a","H� diferen�a ("+IIf(nDiferenca>0,"Excedente","Falta")+") de " + cValToChar(nDiferenca) + " "+ZI2->ZI2_UM+". Deseja continuar",{"Voltar","Continuar"}) == 1
			return .F.
		EndIf
	//se n�o houver diferen�a
	Else
		//pergunta para confirmar
		If Aviso("Confirma","Continuar encerramento da Inspe��o do Item "+alltrim(ZI2->ZI2_DESC)+" ?",{"Voltar","Continuar"}) == 1
			return .F.
		EndIf
	EndIf

	begin transaction

		Reclock("ZI2",.F.)
		ZI2->ZI2_STATUS := "C"
		ZI2->( MsUnlock() )

		event("Encerrado produto","Inspe��o do produto "+alltrim(cProduto)+" foi encerrada.")

		If ZI1->ZI1_STATUS != "E"
			//verifica se encerra a inspe��o totalmente
			lTotal := EncerrarInspecao(ZI2->(Recno()))
		EndIf
	end transaction

	//da mensagem fora da transa��o para n�o bloquear registro da SF1
	If lTotal
		Aviso("Inspe��o","A Inspe��o foi concluida totalmente.",{"Ok"})
	EndIf

return .T.



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EncerrarInspecao                                                              !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para verificar e encerrar a inspe��o                                   !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function EncerrarInspecao(nDesconsiderar)

	Local cAlias := getNextAlias()
	Local lTotal := .F.

	BeginSQL Alias cAlias
		select
			count(1) as NCOUNT
		from
			%table:ZI2%
		where
			ZI2_FILIAL  = %xFilial:ZI2%
		and ZI2_ID      = %Exp: cID %
		and ZI2_STATUS <> 'C' //n�o concluidos
		and R_E_C_N_O_ <> %Exp: nDesconsiderar % //descondira o item encerrado
		and D_E_L_E_T_  = ' '
	EndSQL

	If ( lTotal := (cAlias)->NCOUNT == 0)

		//marca a inspe��o com encerrada
		Reclock("ZI1",.F.)
		ZI1->ZI1_STATUS := "E" //encerrado
		ZI1->( MsUnlock() )

		//e a prenota como OK
		Reclock("SF1",.F.)
		SF1->F1_PIPSTAT := "L"

		//#TB20191119 Thiago Berna - Ajuste para alterar o campo STATCON para 1
		SF1->F1_STATCON := '1'
		SF1->( MsUnlock() )

		event("Inspe��o encerrada normalmente","Inspe��o encerrada totalmente por processo Normal")
	EndIf

	(cAlias)->( dbCloseArea() )

return lTotal




/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! NextSIF                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! fun��o para atualiza tela para proximo SIF (agrupar de lotes)                 !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function NextSIF()

	//se n�o tem um SIF validado, n�o pode encerrar
	If ! lLoteOK
		return
	EndIf

	//precisa ter pallets num SIF
	ZI3->( dbSetOrder(1) )
	ZI3->( dbSeek( xFilial("ZI3") + cID + cProduto + cSIF ) )

	If ! ZI3->( Found() )
		Help("",1,"PRE-INSP_SIF",,"Para encerrar um SIF precisa ao menos um pallets pesado.",4,1)
		return
	EndIf

	//limpa variaveis para lote
	cSIF      := CriaVar('ZI3_SIF')
	dValidade := StoD('')
	cLote     := CriaVar('ZI4_LTEMB')

	//abre campos de lote e fecha de pesagem
	lLoteOK := .F.

	//atualiza os browse
	bpRefresh()
	blRefresh()
	//e totais
	totals()

	//e foco no campo SIF
	aGets['SIF']:setFocus()

return




/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! telaPallet                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! fun��o para montem da tela de pallets                                         !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function telaPallet(oPanel)
Local nTamFormTara	:= int( 70 / oPanel:nHeight * 100)
Local nTamFormPesag	:= int( 70 / oPanel:nHeight * 100)
Local nTamTot   	:= int( 55 / oPanel:nHeight * 100)
Local nTamValid 	:= 0
Local oLayer 		:= FWLayer():New()
Local nTaraPallet   := 0 //ZI3_TARAPL
Local nTaraEmbalagem:= 0 //ZI3_TARAEB
Local nQuantCaixas  := 0 //ZI3_QTDCX
Local nPesoBruto    := 0 //ZI3_PESOB
Local nPesoLiquido  := 0 //ZI3_QUANT
Local nQuant:= 0, nQuant2:=0, nQuantFor:=0
//validade para Hortifruti divide com campos da pesagem
Local lValidade 	:=  (LOCATION == HORTIfRUTI .And. Rastro(SB1->B1_COD))
//MDR_BALFRI, MDR_BALHOR, MDR_BALMER
Local lAtivaEdicao	:= SuperGetMV("MDR_BAL"+SubStr(LOCATION,1,3),,.F.)
Local lReadOnly		:= .F.
//Local cEndEntrada	 := Space(Len(ZI3->ZI3_ENDENT)) //ZI3_ENDENT
//Private cEndEntrada	 := Posicione("SB5",1,xFilial("SB5")+ZI2->ZI2_PROD,"B5_ENDENT")

	If lValidade
		nTamValid := int( 320 / oPanel:nWidth * 100)
	EndIf

	oLayer:init( oPanel, .T. )

	oLayer:addLine( 'formtara', nTamFormTara )
	oLayer:addCollumn( "tara" , 100, .F.,"formtara" )
	oLayer:addLine( 'formpesag', nTamFormPesag )
	oLayer:addCollumn( "validade" , nTamValid, .F.,"formpesag" )
	oLayer:addCollumn( "pesagem", 100-nTamValid, .F.,"formpesag" )
	oLayer:addLine( 'grid', 100-nTamFormTara-nTamFormPesag-nTamTot )
	oLayer:addLine( 'total', nTamTot )

	/*ZI4->( dbSetOrder(1) )
	ZI4->( dbSeek( xFilial("ZI4") + cID + cProduto ) )
	lLoteOK := ZI4->( Found() )*/
	
	//apenas para hortifruti
	If lValidade
		//procura por um Lote, para achar a validade do produto
		//ZI4->( dbSetOrder(1) )
		//If ZI4->( dbSeek( xFilial("ZI4") + cID + cProduto ) )
		SB8->(DbSetOrder(5))//B8_FILIAL+B8_PRODUTO+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID) 
		If SB8->( DbSeek( xFilial("SB8") + cProduto + cLote ) )
			//assume a validade j� digitada
			//dValidade 	:= ZI4->ZI4_VALID
			dValidade 	:= SB8->B8_DTVALID
			lReadOnly	:= .T.
		
		Else
			//se n�o achar e tiver prazo cadastrado no produto
			If SB1->B1_PRVALID > 0
				//preenche o campos com o prazo de validade padr�o
				dValidade := date() + SB1->B1_PRVALID
			EndIf
		EndIf

		TGet():New(0,5, bSetGet(dValidade), oLayer:GetColPanel('validade','formpesag') ,  65, 16, "",{|| .T. },,,,.F.,,.T.,,.F.,{|| ! lLoteOK },.F.,.F.,,.F.,lReadOnly,,'dValidade'  ,,,,,,,'Validade',1)
		TButton():New( 7.5, 80, "Confirmar", oLayer:GetColPanel('validade','formpesag'), {|| validAndStoreLote() }, 50,18,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| ! lLoteOK },,.F. )

	EndIf

	//peso (unidade KG ou Frigrifico)
	aGets['ENDEN'] := TGet():New(0,195, bSetGet(cEndEntrada), oLayer:GetColPanel('tara','formtara'), 150, 16, getMask("ZI3_ENDENT"),{|| Vazio() .Or. ExistCpo('SBE',SB1->B1_LOCPAD+cEndEntrada)},,,,.F.,,.T.,,.F.,{|| lLoteOK },.F.,.F.,,.F.,.F.,'ZI3F30','cEndEntrada',,,,.T.,,,'Endere�o Entrega',1)
	
	If lPesagem
		
		aGets['TARAP'] := TGet():New(0,  5, bSetGet(nTaraPallet)   , oLayer:GetColPanel('tara','formtara') ,  50, 16, getMask("ZI3_TARAPL"), {|| calcPesoLiquido(nTaraPallet, nTaraEmbalagem, nQuantCaixas, nPesoBruto, @nPesoLiquido) },,,,.F.,,.T.,,.F.,{|| lLoteOK },.F.,.F.,,.F.,.F.,,'nTaraPallet'   ,,,,,,,'TARA Pallet',1)
		TBtnBmp2():New( 15,110,36,36,'balanca',,,,{|| IIf(callBalance(@nTaraPallet),calcPesoLiquido(nTaraPallet, nTaraEmbalagem, nQuantCaixas, nPesoBruto, @nPesoLiquido),) },oLayer:GetColPanel('tara','formtara'),"Tara do Pallet",/*when*/,.F.,.F.)
		aGets['TARAE'] := TGet():New(0, 75, bSetGet(nTaraEmbalagem), oLayer:GetColPanel('tara','formtara') ,  50, 16, getMask("ZI3_TARAEB"), {|| calcPesoLiquido(nTaraPallet, nTaraEmbalagem, nQuantCaixas, nPesoBruto, @nPesoLiquido) },,,,.F.,,.T.,,.F.,{|| lLoteOK },.F.,.F.,,.F.,.F.,,'nTaraEmbalagem',,,,,,,'TARA M�dia Embs.',1)
		aGets['QTDCX'] := TGet():New(0,135, bSetGet(nQuantCaixas)  , oLayer:GetColPanel('tara','formtara') ,  25, 16, getMask("ZI3_QTDCX") , {|| calcPesoLiquido(nTaraPallet, nTaraEmbalagem, nQuantCaixas, nPesoBruto, @nPesoLiquido) },,,,.F.,,.T.,,.F.,{|| lLoteOK },.F.,.F.,,.F.,.F.,,'nQuantCaixas'  ,,,,,,,'Qtd. Cxs',1)
		//aGets['ENDEN'] := TGet():New(0,195, bSetGet(cEndEntrada), oLayer:GetColPanel('tara','formtara'), 150, 16, getMask("ZI3_ENDENT"),{||},,,,.F.,,.T.,,.F.,{|| lLoteOK },.F.,.F.,,.F.,.F.,'ZI3F30','cEndEntrada',,,,.T.,,,'Endere�o Entrega',1)
		aGets['PESOB'] := TGet():New(0,5, bSetGet(nPesoBruto)    , oLayer:GetColPanel('pesagem','formpesag') ,  50, 16, getMask("ZI3_PESOB") , {|| calcPesoLiquido(nTaraPallet, nTaraEmbalagem, nQuantCaixas, nPesoBruto, @nPesoLiquido) },,,,.F.,,.T.,,.F.,{|| lLoteOK },.F.,.F.,,.F.,.F.,,'nPesoBruto'    ,,,,,,,'Peso Bruto',1)
		TBtnBmp2():New( 15,110,36,36,'balanca',,,,{|| IIf(callBalance(@nTaraPallet),calcPesoLiquido(nTaraPallet, nTaraEmbalagem, nQuantCaixas, nPesoBruto, @nPesoLiquido),) },oLayer:GetColPanel('pesagem','formpesag'),"Tara do Pallet",/*when*/,.F.,.F.)
		aGets['PESOL'] := TGet():New(0,75, bSetGet(nPesoLiquido)  , oLayer:GetColPanel('pesagem','formpesag') ,  50, 16, getMask("ZI3_QUANT") , {|| calcPesoLiquido(nTaraPallet, nTaraEmbalagem, nQuantCaixas, nPesoBruto, @nPesoLiquido) },,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'nPesoLiquido'  ,,,,,,,'Peso Liquido',1)
		
		//#TB20200327 Thiago Berna - Ajuste para considerar Horti Fruti na pesagem
		If LOCATION == HORTIfRUTI

			nLeft := 135
			DBSelectArea('SA5')  //Produto x Fornecedor
			DBSelectArea('SAH')  //Unidade de Medidas

			SA5->(DBSetOrder(1)) //A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO
			SAH->(DBSetOrder(1)) //AH_FILIAL+AH_UNIMED

			/*if SAH->(DBSeek(xFilial('SAH')+SB1->B1_UM))
				aGets['UNIDADE']:= TGet():New(0 , nLeft, bSetGet(nQuant)    , oLayer:GetColPanel('pesagem','formpesag') ,  50, 16, getMask("ZI3_QUANT"), {|| lLoteOK .And. xconvUM('UNIDADE',@nQuant,@nQuant2,@nQuantFor) },,,,.F.,,.T.,,.F.,{|| lLoteOK .and. xconvUM('UNIDADE',@nQuant,@nQuant2,@nQuantFor) },.F.,.F.,,.F.,.F.,,'nQuant'     ,,,,,,,'Qtde em '+Alltrim(SAH->AH_UMRES),1)
				
				nLeft+=60
			endif

			if SAH->(DBSeek(xFilial('SAH')+SB1->B1_SEGUM))
				aGets['UN2']    := TGet():New(0, nLeft, bSetGet(nQuant2), oLayer:GetColPanel('pesagem','formpesag') ,  50, 16, getMask("ZI3_QUANT"), {|| lLoteOK .And. xconvUM('UN2',@nQuant,@nQuant2,@nQuantFor)  },,,,.F.,,.T.,,.F.,{|| lLoteOK .and. xconvUM('UNIDADE',@nQuant,@nQuant2,@nQuantFor)},.F.,.F.,,.F.,.F.,,'nQuant2'     ,,,,,,,'Qtde em '+Alltrim(SAH->AH_UMRES),1)
				nLeft+=60
			endif*/

			TButton():New( 7, nLeft, "Confirmar", oLayer:GetColPanel('pesagem','formpesag'), {|| gravaPallet(@nTaraPallet, @nTaraEmbalagem, @nQuantCaixas, @nPesoBruto, @nPesoLiquido, @nQuant, @cEndEntrada) }, 50,18,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| lLoteOK },,.F. )

		Else
			TButton():New( 7, 135, "Confirmar", oLayer:GetColPanel('pesagem','formpesag'), {|| gravaPallet(@nTaraPallet, @nTaraEmbalagem, @nQuantCaixas, @nPesoBruto, @nPesoLiquido, @nQuant, @cEndEntrada) }, 50,18,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| lLoteOK },,.F. )
		EndIf

	//outra unidade qualquer (inclusivo grama ou tonelada)			
	Else
		nLeft:=5
		DBSelectArea('SA5')  //Produto x Fornecedor
		DBSelectArea('SAH')  //Unidade de Medidas

		SA5->(DBSetOrder(1)) //A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO
		SAH->(DBSetOrder(1)) //AH_FILIAL+AH_UNIMED

		if SAH->(DBSeek(xFilial('SAH')+SB1->B1_UM))
			aGets['UNIDADE']:= TGet():New(0 , nLeft, bSetGet(nQuant), oLayer:GetColPanel('pesagem','formpesag') ,  50, 16, getMask("ZI3_QUANT"), {|| lLoteOK .And. xconvUM('UNIDADE',@nQuant,@nQuant2,@nQuantFor) },,,,.F.,,.T.,,.F.,{|| lLoteOK .and. xconvUM('UNIDADE',@nQuant,@nQuant2,@nQuantFor) },.F.,.F.,,.F.,.F.,,'nQuant',,,,,,,'Qtde em '+Alltrim(SAH->AH_UMRES),1)
			nLeft+=60
		endif

		if SAH->(DBSeek(xFilial('SAH')+SB1->B1_SEGUM))
			aGets['UN2']    := TGet():New(0, nLeft, bSetGet(nQuant2), oLayer:GetColPanel('pesagem','formpesag') ,  50, 16, getMask("ZI3_QUANT"), {|| lLoteOK .And. xconvUM('UN2',@nQuant,@nQuant2,@nQuantFor)  },,,,.F.,,.T.,,.F.,{|| lLoteOK .and. xconvUM('UNIDADE',@nQuant,@nQuant2,@nQuantFor)},.F.,.F.,,.F.,.F.,,'nQuant2'     ,,,,,,,'Qtde em '+Alltrim(SAH->AH_UMRES),1)
			nLeft+=60
		endif

        //N�o existe necessidade de ter esse campo
		/*if SA5->( dbSeek( xFilial("SA5") + SF1->F1_FORNECE + SF1->F1_LOJA + SB1->B1_COD ))
	        if SAH->(DBSeek(xFilial('SAH')+SA5->A5_UNID))
	        	aGets['UNFOR']  := TGet():New(0, nLeft, bSetGet(nQuantFor) , oLayer:GetColPanel('pesagem','formpesag') ,  50, 16, getMask("ZI3_QUANT"), {|| lLoteOK .And. xconvUM('UNFOR',@nQuant,@nQuant2,@nQuantFor)  },,,,.F.,,.T.,,.F.,{|| lLoteOK .and. xconvUM('UNIDADE',@nQuant,@nQuant2,@nQuantFor) },.F.,.F.,,.F.,.F.,,'nQuantFor'  ,,,,,,,'Qtde em '+Alltrim(SAH->AH_UMRES),1)
				nLeft+=60
			endif
		endif*/

		TButton():New( 7, nLeft, "Confirmar", oLayer:GetColPanel('pesagem','formpesag'), {|| gravaPallet(,,,,,@nQuant, @cEndEntrada) }, 50,18,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| lLoteOK },,.F. )
		
	EndIf

	aGets['brwPallets'] := FWBROWSE():New()
	aGets['brwPallets']:SetOwner( oLayer:GetLinePanel('grid') )
	aGets['brwPallets']:SetDataTable()
	aGets['brwPallets']:setAlias("ZI3")
	aGets['brwPallets']:DisableReport()
	If LOCATION <> MERCEARIA
		aGets['brwPallets']:setFilterDefault("ZI3->ZI3_FILIAL == '"+xFilial("ZI3")+"' .And. ZI3->ZI3_ID == '" + cID +;
					"' .And. ZI3->ZI3_PROD == '" + cProduto + "' .And. ZI3->ZI3_SIF == '" + ZI4->ZI4_SIF +"'")
	Else
		aGets['brwPallets']:setFilterDefault("ZI3->ZI3_FILIAL == '"+xFilial("ZI3")+"' .And. ZI3->ZI3_ID == '" + cID +;
					"' .And. ZI3->ZI3_PROD == '" + cProduto + "' .And. ZI3->ZI3_SIF == '" + ZI4->ZI4_SIF +;
					"' .And. AllTrim(ZI3->ZI3_PALLET) == '" + AllTrim(ZI4->ZI4_LTEMB) + "'")
	EndIf
	//#TB20200906 Thiago Berna -Ajuste para incluir a opcao de exclusao.
	aGets['brwPallets']:AddStatusColumns({|| "br_cancel" }, {|| delLote() })
	aGets['brwPallets']:SetColumns({;		
		column("ZI3_PALLET") ,;
		column("ZI3_QUANT",IIf(lPesagem,"Peso Liquido","Quantidade")) ,;
		column("ZI3_CONDIC") })
	aGets['brwPallets']:SetTotalDefault('ZI3_FILIAL','COUNT','Lotes')
	aGets['brwPallets']:Activate()

	//totalizadores
	TGet():New(5, 05, bSetGet(aGets['TOT_PROD']) , oLayer:getLinePanel('total') ,  50, 10, getMask("ZI2_QUANT"), {|| .T. },,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,,,,,,,,'Total do Produto ',1)
	TGet():New(5,105, bSetGet(aGets['TOT_SALDO']), oLayer:getLinePanel('total') ,  50, 10, getMask("ZI2_QUANT"), {|| .T. },,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,,,,,,,,'Saldo do Produto ',1)

	If LOCATION == FRIGORIFICO
		TGet():New(5,205, bSetGet(aGets['TOT_SIF'])  , oLayer:getLinePanel('total') ,  50, 10, getMask("ZI2_QUANT"), {|| .T. },,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,,,,,,,,'Total do SIF ',1)
	EndIf

	//inicializa os totalizadores
	totals()

return


/*--------------------------------------------------------------------------+
|  xconvUM - Converte as Unidades de Medidas                                 |
----------------------------------------------------------------------------*/
static function xconvUM(cField,nQuant,nQuant2,nQuantFor)
	Local lRet:=.F.

	DO CASE
		CASE cField=='UNIDADE'
			If SB1->B1_TIPCONV=='M'
				nQuant2:=nQuant*SB1->B1_CONV
			else
				nQuant2:=nQuant/SB1->B1_CONV
			endif

			if SA5->A5_XTPCUNF=='M' //M=Multiplicador;D=Divisor
				nQuantFor:=nQuant*SA5->A5_XCVUNF	//Fator de Convers�o
			else
				nQuantFor:=nQuant/SA5->A5_XCVUNF //Fator de Convers�o
			endif
			lRet:= Positivo(nQuant)
		CASE cField=='UN2'
			If SB1->B1_TIPCONV=='M'
				nQuant:=nQuant2/SB1->B1_CONV
			else
				nQuant:=nQuant2*SB1->B1_CONV
			endif

			if SA5->A5_XTPCUNF=='M' //M=Multiplicador;D=Divisor
				nQuantFor:=nQuant*SA5->A5_XCVUNF	//Fator de Convers�o
			else
				nQuantFor:=nQuant/SA5->A5_XCVUNF //Fator de Convers�o
			endif

		    lRet:= Positivo(nQuant2)
		CASE cField=='UNFOR'
			if SA5->A5_XTPCUNF=='M' //M=Multiplicador;D=Divisor
				nQuant:=nQuantFor/SA5->A5_XCVUNF	//Fator de Convers�o
			else
				nQuant:=nQuantFor*SA5->A5_XCVUNF //Fator de Convers�o
			endif

			If SB1->B1_TIPCONV=='M'
				nQuant2:=nQuant*SB1->B1_CONV
			else
				nQuant2:=nQuant/SB1->B1_CONV
			endif

		    lRet:= Positivo(nQuantFor)
	ENDCASE
return lRet

static function callBalance(nPeso)

	Local aPeso := u_ToledoGet()

	If aPeso[1]
		nPeso := aPeso[2]
	EndIf

return aPeso[1]



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! gravaPallet                                                                   !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! fun��o para grava��o do pallet                                                !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function gravaPallet(nTaraPallet, nTaraEmbalagem, nQuantCaixas, nPesoBruto, nPesoLiquido, nQuant, cEndEntrada)
Local cCondicao := ''
Local cObservacao := ''
Local aNC := {}
Local nNC
Local cPallet
Local newRecno, saveArea

	//-> peso liquido zerado
	If lPesagem .And. nPesoLiquido <= 0
		Help(Nil,Nil,"PRE-INSP_PALLET",Nil,"Peso liquido menor ou igual a zero.",4,1,Nil,Nil,Nil,Nil,Nil,{"Informe o peso para o lote."})
		return
	EndIf

	//-> quantidade zerado
	If ! lPesagem .And. nQuant <= 0
		Help(Nil,Nil,"PRE-INSP_PALLET",Nil,"Quantidade menor ou igual a zero.",4,1,Nil,Nil,Nil,Nil,Nil,{"Informe a quantidade pata lo lote."})
		return
	EndIf

	//-> Verifica impressora de etiqueta
	DBSelectArea("ZIA")
	ZIA->(DbSetOrder(1))
	ZIA->(DBSeek(xFilial("ZIA")+"013"))
	If !ZIA->(Found()) .or. Empty(ZIA->ZIA_IMPPAD)
		Help(Nil,Nil,"PRE-INSP_PALLET",Nil,"Impressora nao cadastrada.",4,1,Nil,Nil,Nil,Nil,Nil,{"Cadastre a impressora de etiquetas na tabela ZIA."})
		return
	EndIf
		
	If confirmaPallet(nTaraPallet, nTaraEmbalagem, nQuantCaixas, nPesoBruto, nPesoLiquido, nQuant, @cCondicao, @cObservacao, @aNC)

		//nova numera��o de pallet
		cPallet := makeNewPallet(ZI4->ZI4_SIF)

		begin transaction

			Reclock("ZI3",.T.)
			ZI3->ZI3_FILIAL := xFilial("ZI3")
			ZI3->ZI3_ID     := cID
			ZI3->ZI3_PROD   := cProduto
			ZI3->ZI3_PALLET := cPallet
			ZI3->ZI3_SIF    := ZI4->ZI4_SIF
			ZI3->ZI3_CONDIC := cCondicao
			ZI3->ZI3_OBSERV := cObservacao
			If lPesagem
				ZI3->ZI3_QUANT  := nPesoLiquido
				ZI3->ZI3_TARAPL := nTaraPallet
				ZI3->ZI3_TARAEB := nTaraEmbalagem
				ZI3->ZI3_QTDCX  := nQuantCaixas
				ZI3->ZI3_PESOB  := nPesoBruto
			else
				ZI3->ZI3_QUANT  := nQuant
			EndIf
			//aguardando classifica��o
			ZI3->ZI3_STATUS := "AC"
			ZI3->ZI3_ENDENT	:= cEndEntrada
			ZI3->( MsUnlock() )

			// Impress�o da Etiqueta Recebimento
        	ImpEtiqACD()

			newRecno := ZI3->( Recno() )

			Reclock("ZI2",.F.)
			ZI2->ZI2_INSP   += ZI3->ZI3_QUANT
			ZI2->ZI2_STATUS := 'I' //Inspecionando
			ZI2->( MsUnlock() )

			For nNC := 1 to len(aNC)

				SAG->( dbSetOrder(1) )
				SAG->( dbSeek( xFilial("SAG") + aNC[nNC] ) )

				Reclock("ZI5",.T.)
				ZI5->ZI5_FILIAL := xFilial("ZI5")
				ZI5->ZI5_ID     := ZI3->ZI3_ID
				ZI5->ZI5_PROD   := ZI3->ZI3_PROD
				ZI5->ZI5_PALLET := ZI3->ZI3_PALLET
				ZI5->ZI5_CODNC  := SAG->AG_NAOCON
				ZI5->ZI5_DESCNC := SAG->AG_DESCPO
				ZI5->( MsUnlock() )

			Next nNC

		end transaction

		//atualiza grid de pallets
		aGets['brwPallets']:Refresh(.T.)
		//aGets['brwPallets']:GoBottom()
		aGets['brwPallets']:goTo( newRecno, .T. )

		//atualiza os totalizadores
		totals()

		If lPesagem
			//zera os valores
			nTaraPallet := nTaraEmbalagem := nQuantCaixas := nPesoBruto := nPesoLiquido := 0
			//e posiciona no campo TARA Pallet
			aGets['TARAP']:setFocus()
		Else
			nQuant := 0
			aGets['UNIDADE']:setFocus() 
		EndIf

        saveArea := saveAreas({'ZI1','ZI2','ZI3','ZI4','SA2','SB1'})
        
        restoreAreas(saveArea)

	EndIf

return

static function saveAreas(aAreas)
	Local nArea
	Local aSaves := {}
	For nArea := 1 to len(aAreas)
		aAdd( aSaves, { aAreas[nArea], ;
		  (aAreas[nArea])->( IndexOrd() ) , ;
		  (aAreas[nArea])->( Recno() ) } )
	Next
return aSaves

static function restoreAreas(aRestore)
	Local nArea
	For nArea := 1 to len(aRestore)
		(aRestore[nArea][1])->( dbSetOrder( aRestore[nArea][2] ) )
		(aRestore[nArea][1])->( dbGoTo( aRestore[nArea][3] ) )
	Next
return


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! confirmaPallet                                                                !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Cria tela para confirma��o do pallet, com as informa��es digitadas e          !
!                  ! aprova��o/rejei��o                                                            !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function confirmaPallet(nTaraPallet, nTaraEmbalagem, nQuantCaixas, nPesoBruto, nPesoLiquido, nQuant, cCondicao, cObserv, aNC, lRejeicaoTotal)

	Local lContinue := .F.
	Local aMarkNC := {}
	Local oModal
	Local oLayer, oPanel, oBrowse
	Local nCondicao  := 1
	Local aCondicao := {'Aprovado','Reprovado','Quarentena'}
	Local cObservacao := ''

	Default lRejeicaoTotal := .F.

	oModal	:= FWDialogModal():New()
	oModal:SetEscClose(.T.)
	oModal:setTitle("Confirma��o do pallet")
	oModal:setSize(250, 300)
	oModal:enableFormBar(.T.)
	oModal:createDialog()


	oLayer := FWLayer():New()

	oLayer:init( oModal:getPanelMain(), .T. )

	If lRejeicaoTotal

		oLayer:addLine( 'mensagem'  , 10 )
		oLayer:addLine( 'observacao', 30 )
		oLayer:addLine( 'naoConf'   , 60 )

		TSay():New(5,5,{|| "<b>Confirma a rejei��o total da Nota?</b>"},oLayer:getLinePanel('mensagem'),,TFont():New(,,-14),,,,.T.,,,240,9,,,,,,.T.)

		//rejeitado
		nCondicao := 2
	Else
		oLayer:addLine( 'mensagem'  , 10 )
		oLayer:addLine( 'pesos'     , 15 )
		oLayer:addLine( 'condicao'  , 15 )
		oLayer:addLine( 'observacao', 20 )
		oLayer:addLine( 'naoConf'   , 40 )

		TSay():New(5,5,{|| "<b>Confirma a grava��o do Pallet?</b>"},oLayer:getLinePanel('mensagem'),,TFont():New(,,-14),,,,.T.,,,240,9,,,,,,.T.)

		If lPesagem
			TGet():New(0,  5, bSetGet(nTaraPallet)   , oLayer:getLinePanel('pesos') ,  50, 16, getMask("ZI3_TARAPL"), {|| .T. },,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'nTaraPallet'   ,,,,,,,'TARA Pallet',1)
			TGet():New(0, 65, bSetGet(nTaraEmbalagem), oLayer:getLinePanel('pesos') ,  50, 16, getMask("ZI3_TARAEB"), {|| .T. },,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'nTaraEmbalagem',,,,,,,'TARA M�dia Embs.',1)
			TGet():New(0,125, bSetGet(nQuantCaixas)  , oLayer:getLinePanel('pesos') ,  25, 16, getMask("ZI3_QTDCX") , {|| .T. },,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'nQuantCaixas'  ,,,,,,,'Qtd. Cxs',1)
			TGet():New(0,160, bSetGet(nPesoBruto)    , oLayer:getLinePanel('pesos') ,  50, 16, getMask("ZI3_PESOB") , {|| .T. },,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'nPesoBruto'    ,,,,,,,'Peso Bruto',1)
			TGet():New(0,220, bSetGet(nPesoLiquido)  , oLayer:getLinePanel('pesos') ,  50, 16, getMask("ZI3_QUANT") , {|| .T. },,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'nPesoLiquido'  ,,,,,,,'Peso Liquido',1)
		Else
			TGet():New(0,  5, bSetGet(nQuant)   , oLayer:getLinePanel('pesos') ,  50, 16, getMask("ZI3_QUANT"), {|| .T. },,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,'nQuant'   ,,,,,,,'Quantidade',1)
		EndIf

		TSay():New(0,5,{|| "<b>Qual a Condi��o do Pallet?<b>"},oLayer:getLinePanel('condicao'),,TFont():New(,,-14),,,,.T.,,,240,9,,,,,,.T.)

		TRadMenu():New ( 15,05,aCondicao,bSetGet(nCondicao),oLayer:getLinePanel('condicao'),,,,,,,,240,12,,,,.T.,.T.)
	EndIf

	oPanel := oLayer:getLinePanel('observacao')
	tMultiget():new( 0, 5, bSetGet(cObservacao),  oPanel, __DlgWidth(oPanel)-10, __DlgHeight(oPanel)-10, /*fonte*/, , , , , .T.,,,/*when*/,,,/*read*/,/*valid*/,,,/*border*/,.T.,"Observa��o",1)

    oBrowse := FWBrowse():New()
	oBrowse:SetDescription("")
	oBrowse:setOwner(oLayer:getLinePanel('naoConf'))
	oBrowse:setDataTable()
	oBrowse:SetAlias("SAG")
	oBrowse:SetDoubleClick( { || markArray(@aMarkNC, AG_NAOCON) } )
	oBrowse:AddMarkColumns({|| IIf( aScan(aMarkNC,{|cod| cod == AG_NAOCON }) > 0 , "LBOK", "LBNO" ) },{|| markArray(@aMarkNC, AG_NAOCON) },{||})
	oBrowse:setColumns({;
		column('AG_NAOCON',"Codigo") ,;
		column('AG_DESCPO',"Nao Conformidade") ;
	})
	oBrowse:disableReport()
	oBrowse:disableConfig()
	oBrowse:disableFilter()
	oBrowse:activate()

	oModal:addButtons({{"", "Confirmar", {||  IIf(validConfirmacao(nCondicao, cObservacao, aMarkNC), (lContinue := .T., oModal:Deactivate()),) }, "Clique aqui para Enviar",,.T.,.T.}})
	oModal:addButtons({{"", "Voltar", {||  lContinue := .F., oModal:Deactivate() }, "Clique aqui para Enviar",,.T.,.T.}})
	oModal:activate()

	If lContinue
		cCondicao := left(aCondicao[nCondicao],1)
		cObserv   := cObservacao
		aNC       := aClone(aMarkNC)
	EndIf

return lContinue





/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! validConfirmacao                                                              !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Valida��o na confirma��o do Pallet                                            !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function validConfirmacao(nCondicao, cObservacao, aMarkNC)

	//se for Rejeitado
	If nCondicao == 2
		If empty(cObservacao)
			Help("",1,"PRE-INSP_OBS",,"Para situa��o 'Reprovado' a Observa��o � obrigat�ria.",4,1)
			return .F.
		EndIf
		If len(aMarkNC) == 0
			Help("",1,"PRE-INSP_OBS",,"Para situa��o 'Reprovado' a marca��o de pelo menos uma n�o conformidade � obrigat�ria.",4,1)
			return .F.
		EndIf
	EndIf

return .T.




/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! markArray                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para marca��o de MarkBrowse em array, ao inv�s de usar campo OK,       !
!                  ! adiciona e exclui chave em um array                                           !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function markArray(aArray, cCodigo)

	Local nPos := aScan(aArray,{|cod| cod == cCodigo })

	If nPos == 0
		aAdd(aArray,cCodigo)
	Else
		aDel(aArray,nPos)
		aSize(aArray,len(aArray)-1)
	EndIf

return .T.



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! makeNewPallet                                                                 !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para criar um novo ID de pallet                                        !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function makeNewPallet(cCodSIF)
	Local cPallet := ''
	Local cAlias  := getNextAlias()
	//#TB20200110 Thiago Berna - Ajuste para corrigir a sequencia do lote
	Local cLike	  := ''

	// -> o codigo do pallet � formado por
	If LOCATION == FRIGORIFICO
		// -> NOVO ESCOPO DE STRING DO LOTECTL: dtavenc(dd/mm).sequencialpallet(9999).
		/*cPallet := strZero( day(dValidade), 2 )
		cPallet += strZero( month(dValidade), 2 )*/
		//#TB20200213 Andr� Anjos - nova regra para nro: 5 do SIF + 8 da validade + 2 sequencial
		cPallet := PadL(AllTrim(cCodSIF),5,'0') + DToS(dValidade)

		//#TB20200110 Thiago Berna - Ajuste para corrigir a sequencia do lote
		cLike	  := cPallet + "%"

		BeginSQL Alias cAlias

			select max(ZI3_PALLET) as ZI3_PALLET
			from %table:ZI3%

			where
			
			ZI3_FILIAL = %xFilial:ZI3%
			//#TB20200110 Thiago Berna - Ajuste para corrigir a sequencia do lote
			//and ZI3_ID     = %Exp: cID %
			and ZI3_PALLET like %Exp:cLike %
			
			and ZI3_PROD   = %Exp: cProduto %
			and D_E_L_E_T_ = ' '
		EndSQL

		If !Empty( (cAlias)->ZI3_PALLET )
			cPallet += soma1( right( alltrim((cAlias)->ZI3_PALLET), 2 ) )
		Else
			cPallet += '01'
		EndIf

		//fecha
		(cAlias)->( dbCloseArea() )
	ElseIf LOCATION == MERCEARIA
		//gera numera��o do LOTE
		cPallet := ZI4->ZI4_LTEMB
	Else
		cPallet := NextLote(SB1->B1_COD,"L")
	EndIf

return cPallet


/*/{Protheus.doc} noZeroOrSpaceOnLeft
Fun��o para retirar os zeros ou espa�os a esquerda de uma string

@author Rafael Ricardo Vieceli
@since 05/2018
@version 1.0
@return character, string sem zeros a esquerda
@param cString, characters, string para tratamento
@type function
/*/
/*Static Function noZeroOrSpaceOnLeft(cString)
	While left(cString,1) $ "0 "
		cString := substr(cString,2)
	EndDo
Return alltrim(cString)*/




/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! calcPesoLiquido                                                               !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para calcular o peso Liquido                                           !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function calcPesoLiquido(nTaraPallet, nTaraEmbalagem, nQuantCaixas, nPesoBruto, nPesoLiquido)

	//subtrai a tara do pallet do peso bruto
	Local nPeso := (nPesoBruto - nTaraPallet)

	//subtrai do peso, a multiplica��o da tara media das embalagens pela quantidade de caixas
	nPeso -= (nTaraEmbalagem * nQuantCaixas)

	//se o peso for menor que zero
	If nPeso < 0
		//zera
		nPeso := 0
	EndIf

	//e atualiza o campo peso liquido
	nPesoLiquido := nPeso

return .T.




/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! delLote                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para montagem da tela de lotes dentro da tela de inspe��o              !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function telaLotes(oPanel)
Local nTamForm
Local oFont    := TFont():New('Arial',,-26)
Local oLayer   := FWLayer():New()
Local aColumns := {}
Local lValidade:=  ((LOCATION == FRIGORIFICO .Or. LOCATION == MERCEARIA) .And. Rastro(SB1->B1_COD))
Local lReadOnly:= .F.

	oLayer:init( oPanel, .T. )

	cSIF      := CriaVar('ZI3_SIF')
	dValidade := StoD('')
	cLote     := CriaVar('ZI4_LTEMB')

	//se for frigorifico, buscar sifs abertos
	If LOCATION == FRIGORIFICO
		lLoteOK := getOpenSif()
	EndIf

	//tela para FRIGORIFICO (com mais campos)
	If LOCATION == FRIGORIFICO
		nTamForm := int( 140 / oPanel:nHeight * 100)
		oLayer:addLine( 'form', nTamForm )

		aGets['SIF'] := TGet():New(0,  5, bSetGet(cSIF)     , oLayer:getLinePanel('form') ,  85, 20, "@E 99999",{|| .T. },,,oFont,.F.,,.T.,,.F.,{|| ! lLoteOK },.F.,.F.,,.F.,.F.,,'cSIF'  ,,,,,,,'S.I.F.',1)
		TGet():New(0,100, bSetGet(dValidade), oLayer:getLinePanel('form') ,  85, 20, "",{|| .T. },,,oFont,.F.,,.T.,,.F.,{|| ! lLoteOK },.F.,.F.,,.F.,lReadOnly,,'dValidade'  ,,,,,,,'Validade',1)
		aGets['LOTE'] := TGet():New(35, 5, bSetGet(cLote)     , oLayer:getLinePanel('form') ,  85, 16, "",{|| .T. },,,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F.,,'cLote'  ,,,,,,,'Lote ou Embarque',1)
		TButton():New( 42.5, 100, "Confirmar", oLayer:getLinePanel('form'), {|| validAndStoreLote() }, 50,18,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| .T. },,.F. )

		aAdd( aColumns, column("ZI4_SIF") )
		aAdd( aColumns, column("ZI4_LTEMB", "Lote/Embarque") )
	EndIf

	//tela para MERCEARIA (com menos campos)
	If LOCATION == MERCEARIA
		nTamForm := int( 70 / oPanel:nHeight * 100)
		oLayer:addLine( 'form', nTamForm )

		aGets['LOTE'] := TGet():New(0, 5, bSetGet(cLote)     , oLayer:getLinePanel('form') ,  65, 16, "",{|| .T. },,,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F.,,'cLote'  ,,,,,,,'Lote',1)
		TGet():New(0,80, bSetGet(dValidade), oLayer:getLinePanel('form') ,  65, 16, "",{|| .T. },,,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,lReadOnly,,'dValidade'  ,,,,,,,'Validade',1)
		TButton():New( 7.5, 155, "Confirmar", oLayer:getLinePanel('form'), {|| validAndStoreLote() }, 50,18,,/*oFont*/,.T.,.T.,.F.,,.F.,{|| .T. },,.F. )

		aAdd( aColumns, column("ZI4_LTEMB", "Lote") )
		aAdd( aColumns, column("ZI4_VALID", "Validade") )
	EndIf

	//hortifruti esta no telaPallets porque s� tem validade (e apenas uma, sem grid)

	//e monta o grid de lotes
	oLayer:addLine( 'grid', 100-nTamForm )

	aGets['brwLotes'] := FWBROWSE():New()
	aGets['brwLotes']:SetOwner( oLayer:GetLinePanel('grid') )
	aGets['brwLotes']:SetDataTable()
	aGets['brwLotes']:setAlias("ZI4")
	aGets['brwLotes']:DisableReport()
	aGets['brwLotes']:setFilterDefault("ZI4->ZI4_FILIAL == '"+xFilial("ZI4")+"' .And. ZI4->ZI4_ID == '"+ cID +"' .And. ZI4->ZI4_PROD == '"+ cProduto +"' .And. ZI4->ZI4_SIF == '"+cSIF+"'")
	aGets['brwLotes']:AddStatusColumns({|| "br_cancel" }, {|| delLote() })
	aGets['brwLotes']:SetColumns(aColumns)
	aGets['brwLotes']:SetTotalDefault('ZI4_FILIAL','COUNT','Lotes')
	aGets['brwLotes']:SetChange({|| bpRefresh()})
	aGets['brwLotes']:Activate()

return


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! delLote                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para excluir lotes                                                     !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function delLote()

	Local lExcluiLote := .F.
	
	ZI3->( dbSetOrder(1) )
	If LOCATION == FRIGORIFICO
		ZI3->( dbSeek( xFilial("ZI3") + cID + cProduto + ZI4->ZI4_SIF ) )
		lExcluiLote := Aviso('Excluir','Confirmar a excluis�o do SIF ' + alltrim(ZI4->ZI4_SIF) + '?',{'Confirmar','Cancelar'},1) == 1
	ElseIf LOCATION == HORTIfRUTI
		//ZI3->( dbSeek( xFilial("ZI3") + cID + cProduto + ZI4->ZI4_SIF ) )
		lExcluiLote := Aviso('Excluir','Confirmar a excluis�o do ID Pallet ' + alltrim(ZI3->ZI3_PALLET) + '?',{'Confirmar','Cancelar'},1) == 1
	Else
		ZI3->( dbSeek( xFilial("ZI3") + cID + cProduto + ZI4->(ZI4_SIF + ZI4_LTEMB) ) )
		lExcluiLote := Aviso('Excluir','Confirmar a excluis�o do Lote/Embarque ' + alltrim(ZI4->ZI4_LTEMB) + '?',{'Confirmar','Cancelar'},1) == 1
	EndIf

	If lExcluiLote

		begin transaction

		If LOCATION == HORTIfRUTI

			event("ID Pallet excluido","O ID Pallet " + alltrim(ZI3->ZI3_PALLET)+ " foi exclu�do." )

			ZI4->(dbSetOrder(1))
			ZI4->(MsSeek(xFilial("ZI4")+ZI3->(ZI3_ID+ZI3_PROD+ZI3_SIF)))
			
			Reclock("ZI2",.F.)
			ZI2->ZI2_INSP   -= ZI3->ZI3_QUANT
			ZI2->ZI2_STATUS := 'I' //Inspecionando
			ZI2->( MsUnlock() )
				
			//-- Exclus�o da Etiqueta Recebimento
			DelEtiqACD()

			Reclock("ZI3",.F.)
			ZI3->( dbDelete() )
			ZI3->( MsUnlock() )

			Reclock("ZI4",.F.)
			ZI4->( dbDelete() )
			ZI4->( MsUnlock() )

		Else
		
			event("Lote excluido","O Lote/Embarque " + alltrim(ZI4->ZI4_LTEMB)+ " foi exclu�do" +IIf(LOCATION==FRIGORIFICO," SIF " + alltrim(ZI4->ZI4_SIF), "")+ "." )

			While ! ZI3->( Eof() ) .And. ZI3->(ZI3_FILIAL+ZI3_ID+ZI3_PROD+ZI3_SIF) == xFilial("ZI3") + cID + cProduto + ZI4->ZI4_SIF .And.;
							Iif(LOCATION == FRIGORIFICO,.T.,AllTrim(ZI3->ZI3_PALLET) == AllTrim(ZI4->ZI4_LTEMB))

				Reclock("ZI2",.F.)
				ZI2->ZI2_INSP   -= ZI3->ZI3_QUANT
				ZI2->ZI2_STATUS := 'I' //Inspecionando
				ZI2->( MsUnlock() )
				
				//-- Exclus�o da Etiqueta Recebimento
				DelEtiqACD()

				Reclock("ZI3",.F.)
				ZI3->( dbDelete() )
				ZI3->( MsUnlock() )

				ZI3->(dbSkip())
			EndDo

			cSIF      := CriaVar('ZI3_SIF')
			dValidade := StoD('')
			lLoteOK := .F.

			Reclock("ZI4",.F.)
			ZI4->( dbDelete() )
			ZI4->( MsUnlock() )

		EndIf

		end transaction
		
		If LOCATION == HORTIfRUTI
			aGets['brwPallets']:refresh(.T.)
		Else
			aGets['brwLotes']:refresh(.T.)
		EndIf
		
		//atualiza browse de pallets
		bpRefresh()

		//e atualiza os totalizadores
		totals()

		//volta o foco para o campo SIF
		If LOCATION == FRIGORIFICO
			aGets['SIF']:SetFocus()
		ElseIf LOCATION == MERCEARIA
			aGets['LOTE']:SetFocus()
		EndIf
	EndIf

return


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! validAndStoreLote                                                             !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Valida��o e grava��o de lotes para todos os tipos de inspe��o                 !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function validAndStoreLote()
Local newRecno

	//se algum campo estiver vazio, ja retorna
	If empty(dValidade)
		return
	EndIf

	//n�o tem lote no Hortifruti
	If LOCATION != HORTIfRUTI .And. empty(cLote)
		return
	EndIf

	//valida o SIF apenas no Frigorifico
	If LOCATION == FRIGORIFICO .And. empty(cSIF)
		return
	EndIf

	//SIF novo
	If LOCATION == FRIGORIFICO .And. ( lLoteOK == nil .Or. ! lLoteOK ) .And. sifExists() > 0
		//mensagem
		Help("",1,"PRE-INSP_SIF",,"O SIF "+alltrim(cSIF)+" j� foi inspecionado.",4,1)
		//volta no campo SIF
		aGets['SIF']:SetFocus()
		//e retorna
		return
	EndIf

	If LOCATION == FRIGORIFICO .Or. LOCATION == MERCEARIA
		//Valida a data de validade
		ZI4->( dbSetOrder(1) )
		If ZI4->( dbSeek( xFilial("ZI4") + ZI1->ZI1_ID + ZI2->ZI2_PROD ) )
			//assume a validade j� digitada
			If dValidade != ZI4->ZI4_VALID
				dValidade 	:= ZI4->ZI4_VALID
				MsgInfo("Lote ja existente. Validade alterada para:"+DTOC(ZI4->ZI4_VALID),"Atencao")
			EndIf
		Else
			If LOCATION == MERCEARIA
				//Verifica se o lote ja existe MERCEARIA
				SB8->(DbSetOrder(5)) //B8_FILIAL+B8_PRODUTO+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID) 
				IF SB8->(DbSeek(xFilial('SB8') + ZI2->ZI2_PROD + cLote))
					If dValidade != SB8->B8_DTVALID
						dValidade 	:= SB8->B8_DTVALID
						MsgInfo("Lote ja existente. Validade alterada para:"+DTOC(SB8->B8_DTVALID),"Atencao")
					EndIf
				EndIf
			Else
				//Verifica se o lote ja existe FRIGORIFICO
				SB8->(DbSetOrder(5)) //B8_FILIAL+B8_PRODUTO+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID) 
				IF SB8->(DbSeek(xFilial('SB8') + ZI2->ZI2_PROD +  PadL(AllTrim(cSIF),5,'0') + DToS(dValidade) ))
					If dValidade != SB8->B8_DTVALID
						dValidade 	:= SB8->B8_DTVALID
						MsgInfo("Lote ja existente. Validade alterada para:"+DTOC(SB8->B8_DTVALID),"Atencao")
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	//grava o embarque
	Reclock("ZI4",.T.)
	ZI4->ZI4_FILIAL := xFilial("ZI4")
	ZI4->ZI4_ID     := ZI1->ZI1_ID
	ZI4->ZI4_PROD   := ZI2->ZI2_PROD
	ZI4->ZI4_SIF    := cSIF
	ZI4->ZI4_VALID  := dValidade
	If ! empty(cLote)
		ZI4->ZI4_LTEMB  := cLote
	EndIf
	ZI4->( MsUnlock() )

	newRecno := ZI4->(Recno())

	Reclock("ZI2",.F.)
	ZI2->ZI2_STATUS := 'I' //Inspecionando
	ZI2->( MsUnlock() )

	//e n�o permite que altere o SIF/validade
	lLoteOK := .T.

	 //hortifruti n�o tem lote, logo n�o tem grid
	If LOCATION != HORTIfRUTI
		//limpa o lote/embarque
		cLote := CriaVar('ZI4_LTEMB')

		aGets['LOTE']:Refresh()
		aGets['LOTE']:SetFocus()

		//e posiciona no registro novo
		aGets['brwLotes']:setFilterDefault("ZI4->ZI4_FILIAL == '"+xFilial("ZI4")+"' .And. ZI4->ZI4_ID == '" + cID + "' .And. ZI4->ZI4_PROD == '" + cProduto + "' .And. ZI4->ZI4_SIF == '" + cSIF + "'")
		aGets['brwLotes']:goTo( newRecno, .T. )

		bpRefresh()
	EndIf

return


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! getOpenSif                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Monta estrutura da tela do SIF                                                !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function getOpenSif()
Local lContinue := .F.
Local oModal
Local oHeader
Local oPanel
Local oBrowse

	ZI4->( dbSetOrder(1) )
	ZI4->( dbSeek( xFilial("ZI4") + ZI1->ZI1_ID + ZI2->ZI2_PROD ) )

	If ! ZI4->( Found() )
		return .F.
	EndIf

	oModal	:= FWDialogModal():New()
	oModal:SetEscClose(.T.)
	oModal:setTitle("S.I.F.s existentes para o produto")
	oModal:setSize(200, 280)
	oModal:enableFormBar(.T.)
	oModal:createDialog()

    oHeader       := tPanel():New(01,01,,oModal:getPanelMain(),,,,,,100,20)
    oHeader:Align := CONTROL_ALIGN_TOP

	TSay():New(5,5,{|| "<b>Existem S.I.F.s j� iniciados para este produto, duplo clique para continuar um deles</b>"},oHeader,,TFont():New(,,-14),,,,.T.,,,240,9,,,,,,.T.)

    oPanel       := tPanel():New(01,01,,oModal:getPanelMain(),,,,,,100,20)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT

    oBrowse := FWBrowse():New()
	oBrowse:SetDescription("")
	oBrowse:setOwner(oPanel)
	oBrowse:setDataQuery()
	oBrowse:SetAlias( getNextAlias() )
	oBrowse:setQuery(makeQuerySIF())
	oBrowse:setColumns({;
		column('ZI4_SIF') ,;
		column('ZI4_VALID',,{|| StoD(ZI4_VALID) }) ;
	})
	oBrowse:disableReport()
	oBrowse:disableConfig()
	oBrowse:disableFilter()
	oBrowse:SetDoubleClick( { || ZI4->( DbGoTo( (oBrowse:alias())->ZI4RECNO ) ), lContinue := .T. , oModal:Deactivate() } )
	oBrowse:activate()

	oModal:addButtons({{"", "Novo S.I.F.", {|| oModal:Deactivate() }, "Clique aqui para Enviar",,.T.,.T.}})
	oModal:addButtons({{"", "Continuar"  , {|| ZI4->( DbGoTo( (oBrowse:alias())->ZI4RECNO ) ), lContinue := .T. , oModal:Deactivate() }, "Clique aqui para Enviar",,.T.,.T.}})

	oModal:activate()

	If lContinue
		cSIF      := ZI4->ZI4_SIF
		dValidade := ZI4->ZI4_VALID
	EndIf

return lContinue


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! makeQuerySIF                                                                  !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Monta consulta agrupando os registros por SIF e Validade                      !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function makeQuerySIF()
Local cQuery := ''

	cQuery += "select ZI4_SIF, ZI4_VALID, max(R_E_C_N_O_) ZI4RECNO"
	cQuery += " from " + retSqlName("ZI4")
	cQuery += " where"
	cQuery += "     ZI4_FILIAL = '" + xFilial("ZI4") + "'"
	cQuery += " and ZI4_ID     = '" + ZI1->ZI1_ID + "'"
	cQuery += " and ZI4_PROD   = '" + ZI2->ZI2_PROD + "'"
	cQuery += " and D_E_L_E_T_ = ' '"
	cQuery += " group by ZI4_SIF, ZI4_VALID"

return cQuery





/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! getPreNota                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Tela para usu�rio selecionar a nota                                           !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function getPreNota()
Local lContinue := .F.
Local oModal
Local oFont := TFont():New('Arial',,-16)
Local cChavNFE := CriaVar('F1_CHVNFE')
Local cDocumento  := CriaVar('F1_DOC')
Local cSerie      := CriaVar('F1_SERIE')
Local cFornecedor := CriaVar('F1_FORNECE')
Local cLoja       := CriaVar('F1_LOJA')
Local oGet

	oModal	:= FWDialogModal():New()
	oModal:SetEscClose(.T.)
	oModal:setTitle("Chave pr� nota de entrada | " + LOCATION)
	
	//#TB20200312 Thiago Berna - Ajuste para permitir a localiza��o pelo numero do documento
	If LOCATION == HORTIfRUTI
		oModal:setSize(100, 250)
	Else
		oModal:setSize(150, 250)
	EndIf
	
	oModal:enableFormBar(.T.)
	oModal:createDialog()

	//para hortifruti, precisa informar Documento e Fornecedor
	If LOCATION == HORTIfRUTI
		oGet := TGet():New(10, 20, bSetGet(cDocumento) , oModal:getPanelMain() , 60, 16, "",,,,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F.,"SF1PIN",'SF1->F1_DOC'    ,,,,,,,'N�mero',1)
		TGet():New(10, 90, bSetGet(cSerie)     , oModal:getPanelMain() , 20, 16, "",,,,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F.,,'SF1->F1_SERIE'  ,,,,,,,'S�rie',1)
		TGet():New(10,120, bSetGet(cFornecedor), oModal:getPanelMain() , 60, 16, "",,,,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F.,,'SF1->F1_FORNECE' ,,,,,,,"Fornecedor",1)
		TGet():New(10,190, bSetGet(cLoja)      , oModal:getPanelMain() , 30, 16, "",,,,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F.,,'SF1->F1_LOJA'    ,,,,,,,'Loja',1)
	Else
		oGet := TGet():New(10,20, bSetGet(cChavNFE),oModal:getPanelMain(), 210, 20 , "@S44",,,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,'cChavNFE',,,,,,,'Chave da NFe SEFAZ',1,oFont)

		//#TB20200312 Thiago Berna - Ajuste para permitir a localiza��o pelo numero do documento
		oGet := TGet():New(45, 20, bSetGet(cDocumento) , oModal:getPanelMain() , 60, 16, "",,,,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F.,"SF1PIN",'SF1->F1_DOC'    ,,,,,,,'N�mero',1)
		TGet():New(45, 90, bSetGet(cSerie)     , oModal:getPanelMain() , 20, 16, "",,,,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F.,,'SF1->F1_SERIE'  ,,,,,,,'S�rie',1)
		TGet():New(45,120, bSetGet(cFornecedor), oModal:getPanelMain() , 60, 16, "",,,,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F.,,'SF1->F1_FORNECE' ,,,,,,,"Fornecedor",1)
		TGet():New(45,190, bSetGet(cLoja)      , oModal:getPanelMain() , 30, 16, "",,,,,.F.,,.T.,,.F.,{|| .T. },.F.,.F.,,.F.,.F.,,'SF1->F1_LOJA'    ,,,,,,,'Loja',1)
	
	EndIf

	oModal:addButtons({{"", "Confirmar", {|| IIf( lContinue := validaChaveNFE(@cChavNFE, @cDocumento, @cSerie, @cFornecedor, @cLoja), oModal:Deactivate(), ) }, "Clique aqui para Enviar",,.T.,.T.}})
	oModal:addButtons({{"", "Fechar", {|| oModal:Deactivate() }, "Clique aqui para Enviar",,.T.,.T.}})

	oModal:setInitBlock({|| oGet:setFocus() })
	oModal:Activate()

return lContinue



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! validaChaveNFE                                                                !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Valida��o da chave nfe da nota ou documento + fornecedor                      !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function validaChaveNFE(cChave, cDocumento, cSerie, cFornecedor, cLoja)

	If LOCATION == HORTIfRUTI .And. ( empty(cDocumento) .Or. empty(cSerie) .Or. empty(cFornecedor) .Or. empty(cLoja) )
		return .F.
	EndIf

	//#TB20200312 Thiago Berna - Ajuste para permitir a localiza��o pelo numero do documento
	//If LOCATION != HORTIfRUTI .And. empty(cChave)
	If LOCATION != HORTIfRUTI .And. Empty(cChave + cDocumento + cSerie + cFornecedor + cLoja) 
		return .F.
	EndIf

	//#TB20200312 Thiago Berna - Ajuste para permitir a localiza��o pelo numero do documento
	//If LOCATION == HORTIfRUTI
	If LOCATION == HORTIfRUTI .Or. !Empty(cDocumento + cSerie + cFornecedor + cLoja) 

		//procura a nota pelo documento + fornecedor
		SF1->( dbSetOrder(1) )
		SF1->( dbSeek( xFilial("SF1") + cDocumento + cSerie + cFornecedor + cLoja ) )

		//limpa a chave
		cDocumento  := CriaVar('F1_DOC')
		cSerie      := CriaVar('F1_SERIE')
		cFornecedor := CriaVar('F1_FORNECE')
		cLoja       := CriaVar('F1_LOJA')

		If ! SF1->( Found() )
			Help("",1,"PRE-INSP_NAOEXISTE",,"A nota n�o foi encontrada com o documento informado.",4,1)
			return .F.
		EndIf

	Else

		//procura a nota pela chave
		SF1->( dbSetOrder(8) )
		SF1->( dbSeek( xFilial("SF1") + cChave ) )

		//limpa a chave
		cChave := CriaVar('F1_CHVNFE')

		If ! SF1->( Found() )
			Help("",1,"PRE-INSP_NAOEXISTE",,"A nota n�o foi encontrada com esta chave.",4,1)
			return .F.
		EndIf

	EndIf

	//valida se h� itens para inspe��o
	If Empty(SF1->F1_PIPSTAT)
		Help("",1,"PRE-INSP_NAO",,"N�o � possivel fazer a inspe��o desta nota, pois n�o h� produtos configurados para inspe��o.",4,1)
		return .F.
	EndIf

	//valida se j� se a inspe��o j� foi finalizada
	If SF1->F1_PIPSTAT != "B"
		Help("",1,"PRE-INSP_JA",,"N�o � possivel fazer a inspe��o desta nota, pois a nota "+alltrim(SF1->F1_DOC)+"/"+alltrim(SF1->F1_SERIE)+" j� foi inspecionada.",4,1)
		return .F.
	EndIf

	//valida se a nota j� foi classificada
	If ! Empty(SF1->F1_STATUS)
		Help("",1,"PRE-INSP_NFECLASS",,"N�o � possivel fazer a inspe��o desta nota, pois j� foi classificada ou est� bloqueada.",4,1)
		return .F.
	EndIf

	DbSelectArea('SD1')
	SD1->(DbSetOrder(1))
	If SD1->(DbSeek(xFilial('SD1') + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)))
		While SD1->(!Eof()) .And. xFilial('SD1') + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA) == SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA)
			If LOCATION == HORTIfRUTI
				DbSelectArea('QE8')
				QE8->(DbSetOrder(1))
				If QE8->(DbSeek(xFilial('QE8') + SD1->D1_COD))
					If !AllTrim(QE8->QE8_ENSAIO) == 'TP003'
						Help("",1,"PRE-INSP_NFECLASS",,"Documento fiscal com itens que n�o pertencem ao ensaio HORTIFRUTI.",4,1)
						Return .F.
					EndIf
				Else
					Help("",1,"PRE-INSP_NFECLASS",,"Documento fiscal com itens que n�o cadastrados no ensaio.",4,1)
					Return .F.
				EndIf
			ElseIf LOCATION == FRIGORIFICO
				DbSelectArea('QE8')
				QE8->(DbSetOrder(1))
				If QE8->(DbSeek(xFilial('QE8') + SD1->D1_COD))
					If !AllTrim(QE8->QE8_ENSAIO) == 'TP001'
						Help("",1,"PRE-INSP_NFECLASS",,"Documento fiscal com itens que n�o pertencem ao ensaio FRIGORIFICO.",4,1)
						Return .F.
					EndIf
				Else
					Help("",1,"PRE-INSP_NFECLASS",,"Documento fiscal com itens que n�o cadastrados no ensaio.",4,1)
					Return .F.
				EndIf
			ElseIf LOCATION == MERCEARIA
				DbSelectArea('QE8')
				QE8->(DbSetOrder(1))
				If QE8->(DbSeek(xFilial('QE8') + SD1->D1_COD))
					If !AllTrim(QE8->QE8_ENSAIO) == 'TP002'
						Help("",1,"PRE-INSP_NFECLASS",,"Documento fiscal com itens que n�o pertencem ao ensaio MERCEARIA.",4,1)
						Return .F.
					EndIf
				Else
					Help("",1,"PRE-INSP_NFECLASS",,"Documento fiscal com itens que n�o cadastrados no ensaio.",4,1)
					Return .F.
				EndIf
			EndIf	
			SD1->(DbSkip())
		EndDo
	Else
		Help("",1,"PRE-INSP_NFECLASS",,"Itens do documento fiscal n�o encontrados.",4,1)
		Return .F.
	EndIf

return .T.




/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! column                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para montar colunas para FWBrowse                                      !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function column(cField, cTitle, bData)
Local oFWColumn := FWBrwColumn():New()

	SX3->( dbSetOrder(2) )
	SX3->( dbSeek( cField ) )

	default cTitle := X3Titulo()
	default bData := &('{ || ' + cField + ' }')

	oFWColumn:SetTitle(cTitle)
	oFWColumn:SetData(bData)
	oFWColumn:SetType(SX3->X3_TIPO)
	oFWColumn:SetPicture(SX3->X3_PICTURE)
	oFWColumn:SetSize(SX3->X3_TAMANHO)
	oFWColumn:SetDecimal(SX3->X3_DECIMAL)
	oFWColumn:SetAlign( IIf(SX3->X3_TIPO == "N",COLUMN_ALIGN_RIGHT,IIf(SX3->X3_TIPO == "D",COLUMN_ALIGN_CENTER,COLUMN_ALIGN_LEFT)) )

	If ! empty( X3CBOX() )
		oFWColumn:setOptions(StrTokArr( X3CBOX(), ';' ))
	EndIf

return oFWColumn



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! getTipo                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o facilitadora para pegar o define com o tipo (ZI1_TIPO)                 !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function getTipo(cTipo)
	If cTipo == "F"
		return FRIGORIFICO
	EndIf
	If cTipo == "H"
		return HORTIfRUTI
	EndIf
return MERCEARIA




/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! MDRPreInsp                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para verificar se a Pre Inspe��o customizada do Madero esta Ativa      !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
User Function MDRPreInsp(cForn,cLoja,cProd)
Local lPreInsp := .F.
Local aArea    := GetArea()
Local lConfere := GetMV("MV_CONFFIS",,"N") == "S" .and. SuperGetMV("MDR_PREINS",,.F.) .and. !Empty(cForn)	

	// -> Verifica se o produto possui nota para inspe��o, se for materiais e se o par�metro de inspe��o customizado est� ativo
	If lConfere
		// -> Valida dados de confer�ncia do fornecedor
		DBSelectArea("SA2")
		DbSetOrder(1)
		DbSeek(xFilial("SA2")+cForn+cLoja)
		lConfere:=SA2->A2_CONFFIS == "3"
		If lConfere 
			SB1->(dbSetOrder(1) )
			SB1->(msSeek(xFilial("SB1")+cProd))
			If SB1->B1_TIPOCQ == "M" .and. SB1->B1_NOTAMIN > 0 
				// -> Verifica produto x fornecedor
				SA5->(dbSetOrder(2))
				SA5->(dbSeek(xFilial("SA5") + SD1->(cProd+cForn)) )
				If SA5->(Found())
					lPreInsp:=SA5->A5_NOTA < SB1->B1_NOTAMIN
					// -> Verificar os cadastros da qualidade
					DbSelectArea("QE6")
					QE6->(DbSetOrder(1))
					lPreInsp:=QE6->(DbSeek(xFilial("QE6")+SB1->B1_COD))
				EndIf
			EndIf	
		EndIf	
	EndIf
	
	RestArea(aArea)

Return(lPreInsp)



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! sifExists                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Verifica quantos lotes existem para aquele SIF (agrupador de lotes)           !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function sifExists()

	Local cAlias  := getNextAlias()
	Local nExists := 0
	Local cWhere  := "%" 

	If LOCATION <> FRIGORIFICO
		cWhere += " AND ZI4_LTEMB = '" +ZI4->ZI4_LTEMB +"'"
	EndIf
	cWhere += "%"

	BeginSQL Alias cAlias
		SELECT count(1) as NR
		FROM %table:ZI4%
		WHERE ZI4_FILIAL = %xFilial:ZI4%
			AND ZI4_ID     = %Exp: cID %
			AND ZI4_PROD   = %Exp: cProduto %
			AND ZI4_SIF    = %Exp: ZI4->ZI4_SIF %
			AND 1 = 1
			%Exp:cWhere%
			AND %NotDel%
	EndSQL

	nExists := (cAlias)->NR

	(cAlias)->( dbCloseArea() )

return nExists



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! totals                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para totalizar o grid de pallets                                       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function totals()

	Local cAlias   := getNextAlias()

	//faz consulta sobre o produto
	//sem problemas para Mercearia e Hortifruti
	//para Frigorifico, faz o sum com case para somar apenas no SIF
	BeginSQL Alias cAlias
		%noparser%
		select sum(ZI3_QUANT) PROD, sum(case ZI3_SIF when %Exp: cSIF % then ZI3_QUANT else 0 end) as SIF
		from %table:ZI3%
		where
			ZI3_FILIAL = %xFilial:ZI3%
		and ZI3_ID     = %Exp: cID %
		and ZI3_PROD   = %Exp: cProduto %
		and D_E_L_E_T_ = ' '
	EndSQL

	aGets['TOT_PROD']  := (cAlias)->PROD
	aGets['TOT_SALDO'] := (cAlias)->PROD-ZI2->ZI2_QUANT

	If LOCATION == FRIGORIFICO
		aGets['TOT_SIF']   := (cAlias)->SIF
	EndIf

	(cAlias)->( dbCloseArea() )

return



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! getMask                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para buscar a mascara usando apenas o campo, sem o alias               !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function getMask(cField)

	Local cAlias := AliasCpo(cField)

	If empty(cAlias) .Or. (cAlias)->( FieldPOS(cField) ) == 0
		return "@E 999,999.9999"
	EndIf

return PesqPict(cAlias,cField)



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! bpRefresh                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Faz refresh do browse de pallets, ap�s atualiza do filtro padr�o              !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/

static function bpRefresh()

	//atualiza browse de pallets
	If aGets['brwPallets'] <> NIL
		If LOCATION <> MERCEARIA
			aGets['brwPallets']:setFilterDefault("ZI3->ZI3_FILIAL == '"+xFilial("ZI3")+"' .And. ZI3->ZI3_ID == '" + cID +;
						"' .And. ZI3->ZI3_PROD == '" + cProduto + "' .And. ZI3->ZI3_SIF == '" + ZI4->ZI4_SIF +"'")
		Else
			aGets['brwPallets']:setFilterDefault("ZI3->ZI3_FILIAL == '"+xFilial("ZI3")+"' .And. ZI3->ZI3_ID == '" + cID +;
						"' .And. ZI3->ZI3_PROD == '" + cProduto + "' .And. ZI3->ZI3_SIF == '" + ZI4->ZI4_SIF +;
						"' .And. AllTrim(ZI3->ZI3_PALLET) == '" + AllTrim(ZI4->ZI4_LTEMB) + "'")
		EndIf
		aGets['brwPallets']:refresh(.T.)
	EndIf

return


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! blRefresh                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Faz refresh do browse de lotes, ap�s atualiza do filtro padr�o                !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function blRefresh()

	//atualiza browse de pallets
	aGets['brwLotes']:setFilterDefault("ZI4->ZI4_FILIAL == '"+xFilial("ZI4")+"' .And. ZI4->ZI4_ID == '" + cID + "' .And. ZI4->ZI4_PROD == '" + cProduto + "' .And. ZI4->ZI4_SIF == '" + cSIF + "'")
	aGets['brwLotes']:refresh(.T.)

return




/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ZI2StatusComboBox                                                             !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Atualiza status do ComboBox                                                   !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
user function ZI3StatusComboBox()
Local cBox := ''

	cBox += 'AC=Aguardando Classifica��o;'
	cBox += 'AD=Aguardando Devolu��o;'
	cBox += 'AE=Aguardando Excedente;'
	cBox += 'MO=Movimentado;'
	cBox += 'BX=Baixado Manualmente;'
	cBox += 'BN=Baixado via NFEntrada ou NFDevolu��o'

Return cBox


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! event                                                                         !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Atualiza eventos da inspe��o                                                  !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function event(cEvento, cObservacao)

	Reclock("ZI7",.T.)
	ZI7->ZI7_FILIAL := xFilial("ZI1")
	ZI7->ZI7_ID     := ZI1->ZI1_ID
	ZI7->ZI7_DATA   := date()
	ZI7->ZI7_HORA   := time()
	ZI7->ZI7_USER   := RetCodUsr()
	ZI7->ZI7_EVENTO := cEvento
	ZI7->ZI7_OBSERV := cObservacao
	ZI7->( MsUnlock() )

return




/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! QIE100Estorna                                                                 !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Estorna dados da inspe��o                                                     !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
user function QIE100Estorna()

	//pre inspe��o ativa
	If ! SuperGetMV("MDR_PREINS",,.F.)
		return
	EndIf

	//estorno da classifica��o
	If ! IsInCallStack("A140EstCla")
		return
	EndIf

	//procura a inspe��o
	ZI1->( dbSetOrder(1) )
	ZI1->( dbSeek( xFilial("ZI1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) ) )

	If ! ZI1->( Found() )
		return
	EndiF

	ZI6->( dbSetOrder(1) )
	ZI6->( dbSeek( xFilial("ZI6") + ZI1->ZI1_ID   ) )

	While ! ZI6->( Eof() ) .And. ZI6->(ZI6_FILIAL+ZI6_ID) == xFilial("ZI6") + ZI1->ZI1_ID
		Reclock("ZI6",.F.)
		ZI6->( dbDelete() )
		ZI6->( MsUnlock() )
		ZI6->(dbSkip())
	EndDo

	ZI3->( dbSetOrder(1) )
	ZI3->( dbSeek( xFilial("ZI3") + ZI1->ZI1_ID ) )

	While ! ZI3->( Eof() ) .And. ZI3->(ZI3_FILIAL+ZI3_ID) == xFilial("ZI3") + ZI1->ZI1_ID
		Reclock("ZI3",.F.)
		ZI3->ZI3_STATUS := "AC"
		ZI3->( MsUnlock() )
       	ZI3->( dbSkip() )
	EndDo

	//log
	event("Estorno de Classifica��o", "A nota " +SF1->(F1_FILIAL+"/"+F1_DOC+"/"+F1_SERIE+"/"+F1_FORNECE+"/"+F1_LOJA)+ " - RECNO " +cValToChar(SF1->(Recno()))+" teve a classfica��o estornada.")

return


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! QIE100Analize                                                                 !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Atualiza��o dos intens da NF                                                  !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
user function QIE100Analize()
Local aArea := {}
Local nQuant
Local aItem := {}
Local aItensMail := {}

	If IsInCallStack('U_SF1100I') //.Or. IsInCallStack('U_MT103FIM')
	
		//-> pre inspe��o ativa
		If !SuperGetMV("MDR_PREINS",,.F.)
			return
		EndIf

		//-> procura a inspe��o
		ZI1->( dbSetOrder(1) )
		ZI1->( dbSeek( xFilial("ZI1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) ) )

		If ! ZI1->( Found() )
			return
		EndiF

		aEval({'SD1','SF1','SA2','SB1'},{|alias| aAdd(aArea, getArea(alias))})

		ZI2->( dbSetOrder(1) )
		ZI2->( dbSeek( xFilial("ZI2") + ZI1->ZI1_ID ) )

		//-- Ajuste de diverg�ncias da pesagem (cria saldo para sobras da pesagem)
		u_MDRInvSobra()

		While ! ZI2->( Eof() ) .And. ZI2->(ZI2_FILIAL+ZI2_ID) == xFilial("ZI2") + ZI1->ZI1_ID

			nQuant := 0
			aItem  := {}

			SD1->( dbSetOrder(1) )
			SD1->( dbSeek( xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) + ZI2->ZI2_PROD ) )

			While ! SD1->( Eof() ) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_TIPO+D1_COD) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)+ZI2->ZI2_PROD
				If SD1->D1_PIPSTAT == 'S'
					nQuant += SD1->D1_QUANT
					aAdd(aItem, SD1->( Recno() ) )
				EndIf
				SD1->(dbSkip())
			EndDo

			//se a inspe��o do item n�o foi concluido
			If ZI2->ZI2_STATUS != "C"
				//(A)lerta de (I)nspe��o N�o Concluida
				newDivg("AI",0)
				//e salva evento
				event('Inspe��o n�o concluida do item', "Documento classificado, mas a inspe��o do produto "+alltrim(ZI2->ZI2_PROD)+" n�o foi concluida.")
			EndIf

			//inspe��o concluida para o item
			If ZI2->ZI2_STATUS == "C"

				//valida��o da divergencia
				If ZI2->ZI2_QUANT != nQuant
					//(A)lerta de (D)divergencia na Classifica��o
					newDivg("AD",(nQuant-ZI2->ZI2_QUANT))
					//e salva evento
					event('Diferen�a Quantidade Prenota X Documento', "A inspe��o foi criada com quantidade " +cValToChar(ZI2->ZI2_QUANT)+ " da prenota, por�m foi classificado com a quantidade " + cValToChar(nQuant) + ".")
				EndIf

				//se a quantidade da nota for menor que a quantidade inspecionada
				//gera divergencia de excedente
				If nQuant < ZI2->ZI2_INSP
					//(D)ivergencia de (E)Excedente
					newDivg("DE",(ZI2->ZI2_INSP-nQuant))
					//e salva evento
					event('Excedente Inspe��o x Documento', "A inspe��o do produto "+alltrim(ZI2->ZI2_PROD)+" inspecionou " +cValToChar(ZI2->ZI2_INSP)+ " " + ZI2->ZI2_UM + ", por�m foi classificado a quantidade " + cValToChar(nQuant) + ".")
				EndIf

				//se a quantidade da nota for maior que a quantidade inspecionada
				//gera divergencia de excedente
				If nQuant > ZI2->ZI2_INSP
					//(D)ivergencia de (D)D�ficit
					newDivg("DD",(ZI2->ZI2_INSP-nQuant))
					//e salva evento
					event('D�ficit Inspe��o x Documento', "A inspe��o do produto "+alltrim(ZI2->ZI2_PROD)+" inspecionou " +cValToChar(ZI2->ZI2_INSP)+ " " + ZI2->ZI2_UM + ", por�m foi classificado a quantidade " + cValToChar(nQuant) + ".")
				EndIf

				//libera lotes do CQ
				liberarLotes(aItem)

			EndIf

			ZI2->(dbSkip())
		EndDo

		event("Classifica��o da prenota", "A prenota " +SF1->(F1_FILIAL+"/"+F1_DOC+"/"+F1_SERIE+"/"+F1_FORNECE+"/"+F1_LOJA)+ " - RECNO " +cValToChar(SF1->(Recno()))+" foi classificada.")

		//envia e-mail de divergencias
		makeAndSendMail()
	
	EndIf

	aEval(aArea,{|area| restArea(area)} )

return


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! liberarLotes                                                                  !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Libera��o dos lotes                                                           !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function liberarLotes(aItem)
Local aMata175 			:= {}
Local nItem
Local aPallets 			:= getPallets()
Local nPallet
Local nSaldo
Local nQuant
Local aChangeStatus	 	:= {}
Local aArea				:= GetArea()
Private lMsErroAuto    	:= .F.
Private lAutoErrNoFile 	:= .F.//.T.

	If len(aPallets) == 0
		return
	EndIf

	For nItem := 1 to len(aItem)

		aMata175 := {}

		// -> posiciona no item
		SD1->( dbGoTo( aItem[nItem] ) )
		SB1->( dbSetOrder(1) )
		SB1->( dbSeek( xFilial("SB1") + SD1->D1_COD ) )
		
		SD7->( dbSetOrder(3) )
		SD7->( dbSeek( xFilial("SD7") + SD1->(D1_COD + D1_NUMSEQ + SD1->D1_NUMCQ) ) )
		nSaldo   := SD7->D7_SALDO

		// -> Se encontrou dados para baixa do CQ
		If SD7->( Found() )
			For nPallet := 1 to len(aPallets)

				//se possi��o 2 [quantidade] e 3 [baixado] estiver igual, j� foi baixado totalmente
				If aPallets[nPallet][2] == aPallets[nPallet][3]
					Loop
				EndIf

				ZI3->( dbGoTo( aPallets[nPallet][4] ) )

				aAdd(aMata175, {})
				//rejeitado
				
				If ZI3->ZI3_CONDIC == "R"
					aAdd( aTail(aMata175), { "D7_TIPO"   ,2 ,nil})
					//aprovado/querentena
				Else
					aAdd( aTail(aMata175), { "D7_TIPO"   ,1 ,nil})
				EndIf

				//a quantidade � o Minimo entre saldo o Pallet ( quantidade - usado em outro item da nota) e o Saldo do Item
				nQuant 	:= min(ZI3->ZI3_QUANT - aPallets[nPallet][3],nSaldo)
				
				aAdd( aTail(aMata175), { "D7_DATA"   , dDataBase,nil})
				aAdd( aTail(aMata175), { "D7_QTDE"   , nQuant , nil })
				aAdd( aTail(aMata175), { "D7_OBS"    , ZI3->ZI3_OBSERV ,nil})
				aAdd( aTail(aMata175), { "D7_PALLET" , ZI3->ZI3_PALLET , nil})
				
				//#TB20191015 Thiago Berna - Ajuste para tratamento dos enderecos
				//aAdd( aTail(aMata175), { "D7_LOTECTL", ZI3->ZI3_PALLET , nil})
				//aAdd( aTail(aMata175), { "D7_LOTECTL", SD7->D7_LOTECTL , nil})
				
				aAdd( aTail(aMata175), { "D7_MOTREJE", "" , nil})
				
				//rejeitado
				If ZI3->ZI3_CONDIC == "R"
					aAdd( aTail(aMata175), { "D7_LOCDEST", GetMV("MDR_CQ",,"98") , nil})
					//aprovado/querentena
				Else
					aAdd( aTail(aMata175), { "D7_LOCDEST", SB1->B1_LOCPAD , nil})
				EndIf

				aAdd( aTail(aMata175),{"D7_LOCALIZ" 	,SubStr(GetMV("MV_DISTAUT",,'9898980000001'),3) ,nil})  				
				
				aAdd( aTail(aMata175), { "D7_SALDO"  , nil ,nil})
				aAdd( aTail(aMata175), { "D7_SALDO2" , nIL ,nil})
				aAdd( aTail(aMata175), { "D7_ESTORNO", nil ,nil})
				aPallets[nPallet][3] += nQuant
				nSaldo -= nQuant

				aAdd(aChangeStatus, aPallets[nPallet][4])

				If nSaldo <= 0
					Exit
				EndIf
			
			Next nPallet

			//-- Valor de nSaldo � a sobra em fu��o da pesagem maior que quantidade da nota
			If nSaldo > 0
				aAdd(aMata175, {})
				
				aAdd( aTail(aMata175), { "D7_TIPO"   ,2 ,nil})
				aAdd( aTail(aMata175), { "D7_DATA"   , dDataBase,nil})
				aAdd( aTail(aMata175), { "D7_QTDE"   , nSaldo , nil })
				aAdd( aTail(aMata175), { "D7_OBS"    , "Elimina��o de saldo por falta constada em pesagem." ,nil})
				aAdd( aTail(aMata175), { "D7_MOTREJE", "" , nil})
				aAdd( aTail(aMata175), { "D7_LOCDEST", GetMV("MDR_CQ",,"98") , nil})
				aAdd( aTail(aMata175), { "D7_LOCALIZ", SubStr(GetMV("MV_DISTAUT",,'9898980000001'),3) ,nil})  				
				aAdd( aTail(aMata175), { "D7_SALDO"  , nil ,nil})
				aAdd( aTail(aMata175), { "D7_SALDO2" , nIL ,nil})
				aAdd( aTail(aMata175), { "D7_ESTORNO", nil ,nil})
			EndIf

			If len(aMata175) != 0
				lMsErroAuto   := .F.
				lAutoErrNoFile:= .F.
				MSExecAuto({|x,y| mata175(x,y)}, aMata175, 4 )
				If !lMsErroAuto
					aEval(aChangeStatus,{|nRecno| changeStatus(nRecno) })

					If nSaldo > 0
						//-- Ajuste de diverg�ncias da pesagem (emilina saldo para faltas da pesagem)
						U_MDRInvFalta(SD1->D1_COD,SuperGetMV("MDR_CQ",.F.,"98"),SD1->D1_LOTECTL,PadR(SubStr(GetMV("MV_DISTAUT",,'9898980000001'),3),TamSX3("BE_LOCALIZ")[1]),nSaldo,SD1->D1_NUMSEQ,SD7->D7_NUMERO)
					EndIf
				Else
					//event('Erro na baixa do CQ', "Detalhes do erro" + CRLF + getErroAuto() + CRLF + CRLF + "Para os itens"+CRLF+VarInfo('itens',aMata175))				
					MostraErro()
					DisarmTransaction()
					Break
				EndIf
			EndIf

		EndIf

	Next nItem

	RestArea(aArea)

return


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  changeStatus                                                                 !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Atualiza status da conferencia                                                !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function changeStatus(nRecno)

	ZI3->(dbGoTo(nRecno))
	Reclock("ZI3",.F.)
	ZI3->ZI3_STATUS := IIf(ZI3->ZI3_CONDIC=="R","AD","MO")
	ZI3->( MsUnlock() )

return


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  getErroAuto                                                                  !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Captura o log de erro                                                         !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
/*static function getErroAuto()
Local cErro := ''

	aEval( GetAutoGRLog(), {|line| cErro += (line + CRLF) })

return cErro*/


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  getPallets                                                                   !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Seleciona os pallets em processo de inspe��o                                  !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function getPallets()
Local aPallets := {}

	ZI3->( dbSetOrder(2) )
	ZI3->( dbSeek( xFilial("ZI3") + ZI1->ZI1_ID + ZI2->ZI2_PROD ) )

	While ! ZI3->( Eof() ) .And. ZI3->(ZI3_FILIAL+ZI3_ID+ZI3_PROD) == xFilial("ZI3") + ZI1->ZI1_ID + ZI2->ZI2_PROD
		aAdd( aPallets, { ZI3->ZI3_PALLET, ZI3->ZI3_QUANT, 0, ZI3->( Recno() ) })
       	ZI3->( dbSkip() )
	EndDo
	ZI3->(dbSetOrder(1))

return aPallets


static function newDivg(cTipo, nQuant)

	Reclock("ZI6",.T.)
	ZI6->ZI6_FILIAL := xFilial('ZI6')
	ZI6->ZI6_ID     := ZI2->ZI2_ID
	ZI6->ZI6_PROD   := ZI2->ZI2_PROD
	//AD=Divergencia de Classifica��o
	//AI=Inspe��o N�o Concluida
	//DE=Excedente;
	//DD=D�ficit
	ZI6->ZI6_TIPO   := cTipo
	ZI6->ZI6_QUANT  := nQuant
	ZI6->( MsUnlock() )

return


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  makeAndSendMail                                                              !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para enviar e-mail                                                     !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function makeAndSendMail()
Local cAssunto, cPara, cMensagem

	//posiciona (mesma chave)
	SA2->( dbSetOrder(1) )
	SA2->( dbSeek( xFilial("SA2") + SF1->F1_FORNECE ) )

	If SA2->( FieldPOS("A2_MAILDIV") ) == 0 .Or. empty(SA2->A2_MAILDIV)
		return
	EndIf

	ZI6->( dbSetOrder(1) )
	ZI6->( dbSeek( xFilial("ZI6") + ZI1->ZI1_ID ) )

	If ZI6->( Found() )

		cAssunto  := "Diverg�ncia Inspe��o #"+ZI1->ZI1_ID
		cPara     := alltrim(SA2->A2_MAILDIV)
		cMensagem := L_MQIE100()

		//fun��o do CRM para envio de e-mail conforme parametros padr�o do sistema
		If CRMXEnvMail(/*cFrom*/, cPara, /*cCc*/, /*cBcc*/, cAssunto, cMensagem, /*cAlias*/, /*cCodEnt*/, .T., /*cUserAut*/, /*cPassAut*/)
			event("E-mail de divegencia enviado com Sucesso","E-mail de diverg�ncias foi enviado com sucesso para "+cPara+".")
		Else
			event("Falha no envio do e-mail de Diverg�ncias","N�o foi possivel enviar e-mail de diverg�ncias para "+cPara+".")
		EndIf

	EndIf

return


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  RejeicaoTotal                                                                !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para rejei��o total de inspe��o                                        !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function RejeicaoTotal()

	Local cObserv := {}
	Local aNC := {}, nNC

	If InspIniciada()
		Help("",1,"PRE-INSP_REJ_TOTAL",,"N�o � possivel Rejeitar Totalmente uma inspe��o que j� foi iniada, exclua e fa�a novamente.",4,1)
		return .F.
	EndIf

	If ! confirmaPallet(,,,,,,, @cObserv, @aNC, .T.)
		return .F.
	EndIf

	begin transaction

	//marca a inspe��o como Rejeitada
	Reclock("ZI1",.F.)
	ZI1->ZI1_STATUS := 'R'
	ZI1->( MsUnlock() )

	//libera a nota
	Reclock("SF1",.F.)
	SF1->F1_PIPSTAT := "L"

	//#TB20191119 Thiago Berna - Ajuste para alterar o campo STATCON para 1
	SF1->F1_STATCON := '1'
	SF1->( MsUnlock() )

	ZI2->( dbSetOrder(1) )
	ZI2->( dbSeek( xFilial("ZI2") + ZI1->ZI1_ID ) )

	While ! ZI2->( Eof() ) .And. ZI2->(ZI2_FILIAL+ZI2_ID) == xFilial("ZI2") + ZI1->ZI1_ID

		Reclock("ZI2",.F.)
		ZI2->ZI2_INSP   := ZI2->ZI2_QUANT
		ZI2->ZI2_STATUS := "C" //concluido
		ZI2->( MsUnlock() )

		SD1->( dbSeek( xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) + ZI2->ZI2_PROD ) )

		While ! SD1->( Eof() ) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_TIPO+D1_COD) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)+ZI2->ZI2_PROD
			If SD1->D1_PIPSTAT == 'S'
				Reclock("ZI3",.T.)
				ZI3->ZI3_FILIAL := xFilial("ZI3")
				ZI3->ZI3_ID     := ZI1->ZI1_ID
				ZI3->ZI3_PROD   := SD1->D1_COD
				ZI3->ZI3_PALLET := SD1->D1_LOTECTL
				ZI3->ZI3_SIF    := ""
				ZI3->ZI3_CONDIC := "R" //reprovado
				ZI3->ZI3_OBSERV := cObserv
				ZI3->ZI3_QUANT  := SD1->D1_QUANT
				//aguardando classifica��o
				ZI3->ZI3_STATUS := "AC"
				ZI3->( MsUnlock() )

				For nNC := 1 to len(aNC)
					SAG->( dbSetOrder(1) )
					SAG->( dbSeek( xFilial("SAG") + aNC[nNC] ) )

					Reclock("ZI5",.T.)
					ZI5->ZI5_FILIAL := xFilial("ZI5")
					ZI5->ZI5_ID     := ZI3->ZI3_ID
					ZI5->ZI5_PROD   := ZI3->ZI3_PROD
					ZI5->ZI5_PALLET := ZI3->ZI3_PALLET
					ZI5->ZI5_CODNC  := SAG->AG_NAOCON
					ZI5->ZI5_DESCNC := SAG->AG_DESCPO
					ZI5->( MsUnlock() )
				Next nNC
			EndIf
			SD1->(dbSkip())
		EndDo

		ZI2->(dbSkip())
	EndDo

	event("Rejei��o Total","A nota " +SF1->(F1_FILIAL+"/"+F1_DOC+"/"+F1_SERIE+"/"+F1_FORNECE+"/"+F1_LOJA)+ " - RECNO " +cValToChar(SF1->(Recno()))+" foi Rejeitada Totalmente:" + CRLF + cObserv)

	end transaction

return .T.



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  InspIniciada                                                                 !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Verifica se a Inspe��o foi Iniciada.                                          !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
static function InspIniciada()
Local lIniciado := .F.

	ZI3->( dbSetOrder(1) )
	ZI3->( dbSeek( xFilial("ZI3") + ZI1->ZI1_ID ) )

	lIniciado := ZI3->( found() )

	If ! lIniciado
		ZI4->( dbSetOrder(1) )
		ZI4->( dbSeek( xFilial("ZI3") + ZI1->ZI1_ID ) )

		lIniciado := ZI4->( found() )
	EndIf

return lIniciado




/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  MDRTransf2Lote                                                               !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Fun��o para transferencia de lotes                                            !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
//#TB20200110 Thiago Berna - Ajuste para posicionar corretamente na ZI3 e buscar o campo ZI3_ENDENT
//user function MDRTransf2Lote(cProduto,cLocDest,cLoteCtl,cPallet,nQtde)
user function MDRTransf2Lote(cProduto,cLocDest,cLoteCtl,cPallet,nQtde,cEndDest)
Local aAutoCab	:= {}
Local aItem		:= {}
Local aErroAuto	:= {}
Local cEndReHFL	:= PadR(SuperGetMV("MV_XENDREC",.F.,""),TamSX3("BE_LOCALIZ")[1])

//#TB20200110 Thiago Berna - Ajuste para posicionar corretamente na ZI3 e buscar o campo ZI3_ENDENT
//Local cEndDest	:= ""//Posicione('SB5',1,xFilial('SB5')+SD7->D7_PRODUTO,'B5_ENDENT')

Local lNullEnd	:= .F.

Private lMsErroAuto 	:= .F.
Private lAutoErrNoFile 	:= .F.//IsInCallStack("u_QIE100Analize")

	SB1->( dbSetOrder(1) )
	SB1->( dbSeek( xFilial("SB1") + SD7->D7_PRODUTO ) )

	SB8->( dbSetOrder(3) )
	SB8->( dbSeek( xFilial("SB8") + SD7->D7_PRODUTO + SD7->D7_LOCDEST + SD7->D7_LOTECTL ) )

	aItem       := {}
	aAutoCab    := {}

	//cabecalho
    AAdd(aAutoCab,{GETSX8NUM("SD3","D3_DOC"),dDataBase}) //Cabecalho

	aItem := {}
	//Origem
	AAdd(aItem,{"ITEM"      ,'001'                  , Nil})
	AAdd(aItem,{"D3_COD"    , SB1->B1_COD           , Nil}) //Cod Produto origem
	AAdd(aItem,{"D3_DESCRI" , SB1->B1_DESC          , Nil}) //descr produto origem
	AAdd(aItem,{"D3_UM"     , SB1->B1_UM            , Nil}) //unidade medida origem
	AAdd(aItem,{"D3_LOCAL"  , SD7->D7_LOCDEST       , Nil}) //armazem origem

	AAdd(aItem,{"D3_LOCALIZ", cEndDest				, Nil}) //Informar endereço origem						

	//Destino
	AAdd(aItem,{"D3_COD"    , SB1->B1_COD           , Nil}) //cod produto destino
	AAdd(aItem,{"D3_DESCRI" , SB1->B1_DESC          , Nil}) //descr produto destino
	AAdd(aItem,{"D3_UM"     , SB1->B1_UM            , Nil}) //unidade medida destino
	AAdd(aItem,{"D3_LOCAL"  , SD7->D7_LOCDEST       , Nil}) //armazem destino
	//-- Neste caso, o endere�amento ser� realizado pelo ACD
	If cEndDest <> cEndReHFL
		AAdd(aItem,{"D3_LOCALIZ", cEndDest			, Nil}) //Informar endereço destino
	Else
		AAdd(aItem,{"D3_LOCALIZ", CriaVar("D3_LOCALIZ")	, Nil}) //Informar endereço destino
	EndIf						

	AAdd(aItem,{"D3_NUMSERI", CriaVar("D3_NUMSERI") , Nil}) //Numero serie
	AAdd(aItem,{"D3_LOTECTL", SD7->D7_LOTECTL       , Nil}) //Lote Origem
	AAdd(aItem,{"D3_NUMLOTE", CriaVar("D3_NUMLOTE") , Nil}) //sublote origem
	AAdd(aItem,{"D3_DTVALID", SB8->B8_DTVALID       , Nil}) //data validade
	AAdd(aItem,{"D3_POTENCI", CriaVar("D3_POTENCI") , Nil}) // Potencia
	AAdd(aItem,{"D3_QUANT"  , SD7->D7_QTDE          , Nil}) //Quantidade
	AAdd(aItem,{"D3_QTSEGUM", CriaVar("D3_QTSEGUM") , Nil}) //Seg unidade medida
	AAdd(aItem,{"D3_ESTORNO", CriaVar("D3_ESTORNO") , Nil}) //Estorno

	AAdd(aItem,{"D3_LOTECTL", SD7->D7_PALLET        , Nil}) //Lote destino
	AAdd(aItem,{"D3_NUMLOTE", CriaVar("D3_NUMLOTE") , Nil}) //sublote destino
	AAdd(aItem,{"D3_DTVALID", ZI4->ZI4_VALID        , Nil}) //validade lote destino
	AAdd(aItem,{"D3_ITEMGRD", CriaVar("D3_ITEMGRD") , Nil}) //Item Grade

	AAdd(aItem,{"D3_CODLAN" , CriaVar("D3_CODLAN")  , Nil}) //cat83 prod origem
	AAdd(aItem,{"D3_CODLAN" , CriaVar("D3_CODLAN")  , Nil}) //cat83 prod destino
	AAdd(aItem,{"D3_OBSERVA", CriaVar("D3_OBSERVA")	, Nil}) 
	AAdd(aItem,{"D3_XSEQSD3", CriaVar("D3_XSEQSD3") , Nil}) 
	AAdd(aItem,{"D3_XOP"	, CriaVar("D3_XOP")   	, Nil}) 

	AAdd(aAutoCab,aItem)       

	//tem que fazer o dbSelectArea, sen�o pode dar erro
	dbSelectArea("SD3")

	//volta pra ordem original
	SD3->( dbSetOrder(1) )

	//antes de chamar o execAuto
	MSExecAuto({|x,y| mata261(x,y)},aAutoCab,3)

return ! lMsErroAuto


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  MDREstor2Lote                                                                !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Estorno de Transferencia de lote                                              !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Rafael Ricardo Vieceli                                                        !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
user function MDREstor2Lote
Local aMata261 := {}

	aAdd( aMata261, {})
	aAdd( aTail(aMata261), {"D3_COD"	, SD3->D3_COD , nil})
	aAdd( aTail(aMata261), {"D3_CHAVE" 	, 'E9' , nil})
	aAdd( aTail(aMata261), {"D3_NUMSEQ" , SD3->D3_NUMSEQ, nil })
	aAdd( aTail(aMata261), {"INDEX"		, 4,})

	//controle de erro
	Private lMsErroAuto := .F.

	MSExecAuto({|x,y| Mata261(x,y)},aMata261,6)

	If lMsErroAuto
		mostraErro()
	EndIf

return ! lMsErroAuto


/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             !  MDRENDLO                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descri��o        ! Rotina para enderecar automaticamente os produtos liberados/rejeitados        !
!                  ! automaticamente pelo CQ                                                       !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Thiago Berna                                                                  !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 15/10/2019                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/ 
//#TB20200110 Thiago Berna - Ajuste para posicionar corretamente na ZI3 e buscar o campo ZI3_ENDENT
//User Function MDRENDLO(cProduto,cLocal,cLote)
User Function MDRENDLO(cProduto,cLocal,cPallet,cEndDest,cNumSeq,dValidade)
Local lOK		:= .T.
Local cChaveCB0	:= ""
Local cEndRejei	:= PadR(SubStr(SuperGetMV("MDR_DISTAU",.F.,""),3),TamSX3("BE_LOCALIZ")[1])
Local cEndReHFL	:= PadR(SuperGetMV("MV_XENDREC",.F.,""),TamSX3("BE_LOCALIZ")[1])

//-- Se rejei��o, endere�a no endere�o de rejeitados
If cLocal == SuperGetMV("MDR_CQ",.F.,"98")
	cEndDest := cEndRejei
//-- Se pesagem do Horti-Fruit e Latic�o (sem endere�o destino definido),
//-- endere�a no tempor�rio para poder quebrar os lotes
ElseIf Empty(cEndDest)
	cEndDest := cEndReHFL
EndIf

SDA->(DbSetOrder(1))
If SDA->(DbSeek(xFilial('SDA')+cProduto+cLocal+cNumSeq))
	//-- Realiza endere�amento automatico no endere�o de fim de produ��o
	//-- para viabilizar a montagem de pallet para o item/etiqueta produzidos
	If (lOK := A100Distri(cProduto,cLocal,cNumSeq,SDA->DA_DOC,SDA->DA_SERIE,SDA->DA_CLIFOR,SDA->DA_LOJA,cEndDest,NIL,SDA->DA_SALDO,SDA->DA_LOTECTL,SDA->DA_NUMLOTE))

		cChaveCB0 := xFilial("CB0")+SF1->(F1_FORNECE+F1_LOJA+cProduto+F1_DOC+F1_SERIE)	
		CB0->(dbSetOrder(9))
		CB0->(dbSeek(cChaveCB0))
		
		//-- Atualiza local endere�o, numseq, lote e validade nas etiquetas geradas pela libera��o
		//-- pois o padr�o as retorna para CQ e loteauto (pois a nota entrou no CQ e sem lote)
		While !CB0->(EOF()) .And. CB0->(CB0_FILIAL+CB0_FORNEC+CB0_LOJAFO+CB0_CODPRO+CB0_NFENT+CB0_SERIEE) == cChaveCB0
			If cPallet == CB0->CB0_XLOTE
				RecLock("CB0",.F.)
				CB0->CB0_LOCAL	:= SDA->DA_LOCAL
				//-- Pesagem frigorifico j� endere�a
				If cEndDest <> cEndReHFL
					CB0->CB0_LOCALI := cEndDest
					CB0->CB0_NUMSEQ	:= cNumSeq
				//-- Pesagem horti-fruit e latic�nios endere�a depois
				Else
					CB0->CB0_LOCALI := CriaVar("CB0_LOCALI",.F.)
					CB0->CB0_NUMSEQ	:= CriaVar("CB0_NUMSEQ",.F.)
				EndIf
				CB0->CB0_LOTE	:= CB0->CB0_XLOTE
				CB0->CB0_DTVLD	:= dValidade

				CB0->(MsUnLock())
			EndIf
			CB0->(dbSkip())
		End
	EndIf
EndIf

Return lOK
/*Local aCabSDA   		:= {}
Local aItSDB    		:= {}
Local aItensSDB 		:= {} 
Local aArea				:= GetArea()
Local aAreaSD7			:= SD7->(GetArea())
//#TB20200110 Thiago Berna - Ajuste para posicionar corretamente na ZI3 e buscar o campo ZI3_ENDENT
//Local cEndDest			:= Posicione('SB5',1,xFilial('SB5')+cProduto,'B5_ENDENT')

Private	lMsErroAuto 	:= .F.
Private lAutoErrNoFile 	:= .F. //IsInCallStack("u_QIE100Analize")

If cLocal == GetMV("MDR_CQ",,"98")
	cEndDest := SubStr(GetMV("MDR_DISTAU",,'55000000000000001'),3)
EndIf

DbSelectArea('SDA')
//#TB20200110 Thiago Berna - Ajuste para posicionar corretamente na ZI3 e buscar o campo ZI3_ENDENT
//SDA->(DbSetOrder(2))
//If SDA->(DbSeek(xFilial('SDA')+cProduto+cLocal+cLote))
SDA->(DbSetOrder(1))
If SDA->(DbSeek(xFilial('SDA')+cProduto+cLocal+cNumSeq))
	
	//#TB20200110 Thiago Berna - Ajuste para posicionar corretamente na ZI3 e buscar o campo ZI3_ENDENT
	//While SDA->(!EOF()) .And. xFilial('SDA')+cProduto+cLocal+cLote == SDA->(DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_LOTECTL)
		aItensSDB := {} 
		If SDA->DA_SALDO > 0
			//Cabe�alho com a informa��o do item e NumSeq que sera endere�ado.
			aCabSDA	:= 	{	{"DA_PRODUTO" ,SDA->DA_PRODUTO	,Nil},;	  
							{"DA_NUMSEQ"  ,SDA->DA_NUMSEQ	,Nil}}

			//Dados do item que ser� endere�ado
			aItSDB 	:= {	{"DB_ITEM"	  ,"0001"	      	,Nil},;                   
							{"DB_ESTORNO" ," "	      		,Nil},;                   
							{"DB_LOCALIZ" ,cEndDest   		,Nil},;                   
							{"DB_DATA"	  ,dDataBase    	,Nil},;                   
							{"DB_QUANT"   ,SDA->DA_SALDO    ,Nil}}       

			AAdd(aItensSDB,aitSDB)

			//Executa o endere�amento do item
			MATA265( aCabSDA, aItensSDB, 3)

			If lMsErroAuto    
				//Event("Erro no endere�amento do Produto","Erro no endere�amento do Produto " + alltrim(SDA->DA_PRODUTO) + 'Endere�o ' + AllTrim(cEndDest) + CRLF+CRLF + getErroAuto())
				MostraErro()
				DisarmTransaction()
				Break
			Endif
		
		EndIf
		//SDA->(DbSkip())

	//EndDo

Else
	lMsErroAuto := .T.
EndIf

RestArea(aArea)
RestArea(aAreaSD7)*/

Return !lMsErroAuto

/*/{Protheus.doc} ImpEtiqACD
//Fun��o que faz a chamada da impress�o de etiquetas,
//seguindo o padr�o da nota de entrada, para paridade
//com todos os tratamentos do padr�o
@author andre.oliveira
@since 04/02/2020
@version 1.0

@type function
/*/
Static Function ImpEtiqACD()
Local lIntACD	:= SuperGetMV("MV_INTACD",.F.,"0") == "1" 
Local nQE		:= 0	//-- Quantidade da etiqueta
Local nQtde 	:= 0	//-- Quantidade de etiquetas a imprimir
Local nResto	:= 0	//-- Impress�o de etiqueta de sobra

SB1->(dbSetOrder(1))
SB1->(MsSeek(xFilial("SB1")+ZI3->ZI3_PROD))
If lIntACD .And. CBImpEti(SB1->B1_COD)
	ZI1->(dbSetOrder(2))
	ZI1->(MsSeek(xFilial("ZI1")+ZI3->ZI3_ID))
	ZI4->(dbSetOrder(1))
	If LOCATION <> MERCEARIA
		ZI4->(MsSeek(xFilial("ZI4")+ZI3->(ZI3_ID+ZI3_PROD+ZI3_SIF)))
	Else
		ZI4->(MsSeek(xFilial("ZI4")+ZI3->(ZI3_ID+ZI3_PROD+ZI3_SIF+AllTrim(ZI3_PALLET))))
	EndIf

	If CBProdUnit(SB1->B1_COD) .And. !CBQtdVar(SB1->B1_COD)	//-- Produto unit�rio
		// quantidade de embalagem fixa no B1_QE
		nQE   := Min(CBQEmbI(),ZI3->ZI3_QUANT)
		nQtde := Max(Int(ZI3->ZI3_QUANT/nQE),1)
		nResto := ZI3->ZI3_QUANT%nQE
	Else
		//granel ou //quantidade de embalagem variada conforme item de nota
		nQE   := ZI3->ZI3_QUANT
		nQtde := 1
	EndIf
	
	BeginSQL Alias "SD1TMP"
		SELECT MAX(D1_ITEM) D1_ITEM,
			MAX(D1_NUMSEQ) D1_NUMSEQ
		FROM %Table:SD1%
		WHERE %NotDel% AND
			D1_FILIAL = %xFilial:SD1% AND
			D1_DOC = %Exp:ZI1->ZI1_DOC% AND
			D1_SERIE = %Exp:ZI1->ZI1_SERIE% AND
			D1_FORNECE = %Exp:ZI1->ZI1_FORN% AND
			D1_LOJA = %Exp:ZI1->ZI1_LOJA% AND
			D1_COD = %Exp:ZI3->ZI3_PROD%
	EndSQL

	//#TB20200603 Thiago Berna - Considera parametros por localiza��o
	//CB5SetImp(CBRLocImp("MV_IACD02"),IsTelNet())
	If LOCATION == FRIGORIFICO
		CB5SetImp(CBRLocImp("MD_IACDFRI"),IsTelNet())
	ElseIf LOCATION == HORTIfRUTI
		CB5SetImp(CBRLocImp("MD_IACDHOR"),IsTelNet())
	ElseIf LOCATION == MERCEARIA
		CB5SetImp(CBRLocImp("MD_IACDMER"),IsTelNet())
	Else
		CB5SetImp(CBRLocImp("MV_IACD02"),IsTelNet())
	EndIf
	
	ExecBlock("IMG01",,,{nQE,,,nQtde,ZI1->ZI1_DOC,ZI1->ZI1_SERIE,ZI1->ZI1_FORN,ZI1->ZI1_LOJA,RetFldProd(ZI3->ZI3_PROD,"B1_LOCPAD"),,SD1TMP->D1_NUMSEQ,ZI3->ZI3_PALLET,,ZI4->ZI4_VALID,,,,,,ZI3->ZI3_ENDENT,,0,SD1TMP->D1_ITEM,ZI3->ZI3_SIF,ZI3->ZI3_CONDIC,ZI3->ZI3_PALLET})
	If nResto > 0
		ExecBlock("IMG01",,,{nResto,,,1,ZI1->ZI1_DOC,ZI1->ZI1_SERIE,ZI1->ZI1_FORN,ZI1->ZI1_LOJA,RetFldProd(ZI3->ZI3_PROD,"B1_LOCPAD"),,SD1TMP->D1_NUMSEQ,ZI3->ZI3_PALLET,,ZI4->ZI4_VALID,,,,,,ZI3->ZI3_ENDENT,,0,SD1TMP->D1_ITEM,ZI3->ZI3_SIF,ZI3->ZI3_CONDIC,ZI3->ZI3_PALLET})
	EndIf
	
	MSCBCLOSEPRINTER()
	SD1TMP->(dbCloseArea())
EndIf

Return

/*/{Protheus.doc} DelEtiqACD
//Fun��o para deletar etiquetas geradas pela pesagem que est� sendo excluida
@author andre.oliveira
@since 05/02/2020
@version 1.0

@type function
/*/
Static Function DelEtiqACD()
Local lIntACD	:= SuperGetMV("MV_INTACD",.F.,"0") == "1" 
Local cChaveEti	:= ""

If lIntACD
	BeginSQL Alias "SD1TMP"
		SELECT MAX(D1_ITEM) D1_ITEM,
			MAX(D1_NUMSEQ) D1_NUMSEQ
		FROM %Table:SD1%
		WHERE %NotDel% AND
			D1_FILIAL = %xFilial:SD1% AND
			D1_DOC = %Exp:ZI1->ZI1_DOC% AND
			D1_SERIE = %Exp:ZI1->ZI1_SERIE% AND
			D1_FORNECE = %Exp:ZI1->ZI1_FORN% AND
			D1_LOJA = %Exp:ZI1->ZI1_LOJA% AND
			D1_COD = %Exp:ZI3->ZI3_PROD%
	EndSQL
	
	cChaveEti := xFilial("CB0")+ZI1->(ZI1_FORN+ZI1_LOJA)+ZI3->ZI3_PROD+ZI1->(ZI1_DOC+ZI1_SERIE)+SD1TMP->D1_ITEM
	SD1TMP->(dbCloseArea())
	
	CB0->(dbSetOrder(9))
	CB0->(MsSeek(cChaveEti))
	While !CB0->(EOF()) .And. CB0->(CB0_FILIAL+CB0_FORNEC+CB0_LOJAFO+CB0_CODPRO+CB0_NFENT+CB0_SERIEE+CB0_ITNFE) == cChaveEti
		If ZI3->ZI3_PALLET == CB0->CB0_XLOTE
			RecLock("CB0",.F.)
			CB0->(dbDelete())
			CB0->(MsUnLock())
		EndIf
		
		CB0->(dbSkip())
	End
EndIf

Return

/*/{Protheus.doc} _MQIE100
// Pontos de entrada padrao do MVC
@author andre.oliveira
@since 05/02/2020
@version 1.0

@type function
/*/
User Function _MQIE100()
Local oModel	:= PARAMIXB[1]
Local cIdPonto	:= PARAMIXB[2]
//Local cIdModel	:= PARAMIXB[3]
Local xRet		:= .T.

If cIdPonto == 'MODELCOMMITTTS'
	//-- Exclui etiquetas na CB0
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		BeginSQL Alias "ZI3TMP"
			SELECT R_E_C_N_O_ ZI3RECNO
			FROM %Table:ZI3%
			WHERE ZI3_FILIAL = %xFilial:ZI3% AND
				ZI3_ID = %Exp:FWFldGet("ZI1_ID")%
		EndSQL
		
		While !ZI3TMP->(EOF())
			ZI3->(dbGoTo(ZI3TMP->ZI3RECNO))
			DelEtiqACD()
			
			ZI3TMP->(dbSkip())
		End
		ZI3TMP->(dbCloseArea())
	EndIf
EndIf

Return xRet

/*/{Protheus.doc} MQIE100Del
// Valida status da nota para permitir exclus�o
@author andre.oliveira
@since 05/02/2020
@version 1.0

@type function
/*/
User Function MQIE100Del()

SF1->(dbSetOrder(1))
SF1->(MsSeek(xFilial("SF1")+ZI1->(ZI1_DOC+ZI1_SERIE+ZI1_FORN+ZI1_LOJA)))
If !Empty(SF1->F1_STATUS)
	Aviso("Aten��o","Nota fiscal j� classificada: antes de excluir, estorne a classifica��o.")
Else
	FWExecView("Excluir","MADERO_MQIE100",MODEL_OPERATION_DELETE)
EndIf

Return


/*/{Protheus.doc} MDRInvSobra
Fun��o que processa o ajuste de saldo em fun��o das sobras constatadas durante
o processo de pesagem para todos os itens do documento de entrada posicionado
@type  User Function
@author Andr� Anjos
@since 09/03/2020
/*/
User Function MDRInvSobra()
Local cMVTMSOBRA	:= SuperGetMV("MV_XINSSOB",.F.,"")
Local cMVCQ			:= GetMvNNR('MV_CQ','98')
Local nQtdInv		:= 0
Local aMATA240		:= {}

If !Empty(cMVTMSOBRA)
	ZI1->(dbSetOrder(1))
	ZI1->(MsSeek(xFilial("ZI1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
	
	BeginSQL Alias "MDRINV"
		SELECT SD1.D1_COD,
			(	SELECT SUM(ZI3.ZI3_QUANT)
				FROM %Table:ZI3% ZI3
				WHERE ZI3.%NotDel% AND
					ZI3.ZI3_FILIAL = %xFilial:ZI3% AND
					ZI3.ZI3_ID = %Exp:ZI1->ZI1_ID% AND
					ZI3.ZI3_PROD = SD1.D1_COD	) ZI3QUANT,
			SUM(SD1.D1_QUANT) SD1QUANT,
			MAX(SD1.D1_NUMSEQ) D1_NUMSEQ,
			MAX(SD1.D1_LOTECTL) D1_LOTECTL,
			MAX(SD1.D1_NUMCQ) D1_NUMCQ
		FROM %Table:SD1% SD1
		WHERE SD1.%NotDel% AND
			SD1.D1_FILIAL = %xFilial:SD1% AND
			SD1.D1_DOC = %Exp:ZI1->ZI1_DOC% AND
			SD1.D1_SERIE = %Exp:ZI1->ZI1_SERIE% AND
			SD1.D1_FORNECE = %Exp:ZI1->ZI1_FORN% AND
			SD1.D1_LOJA = %Exp:ZI1->ZI1_LOJA%
		GROUP BY SD1.D1_COD
	EndSQL

	While !MDRINV->(EOF())
		If (nQtdInv := MDRINV->(QtdComp(ZI3QUANT) - QtdComp(SD1QUANT))) <= 0
			MDRINV->(dbSkip())
			Loop
		EndIf
	
		aAdd(aMATA240,{"D3_TM",cMVTMSOBRA,NIL})
		aAdd(aMATA240,{"D3_DOC","INVENTPES",NIL})
		aAdd(aMATA240,{"D3_COD",MDRINV->D1_COD,NIL})
		aAdd(aMATA240,{"D3_LOCAL",cMVCQ,NIL})
		aAdd(aMATA240,{"D3_LOTECTL",MDRINV->D1_LOTECTL,NIL})
		aAdd(aMATA240,{"D3_QUANT",Abs(nQtdInv),NIL})
		aAdd(aMATA240,{"D3_XSEQSD3",MDRINV->D1_NUMSEQ,NIL})
		
		lMSErroAuto := .F.
		MsExecAuto({|x| MATA240(x,3)},aMATA240)

		If lMsErroAuto
			MostraErro()
			DisarmTransaction()
			Break
		Else
			//-- Apaga registro novo gerado na SD7 e incorpora quantidade na SD7 da nota
			SD7->(dbSetOrder(3))
			SD7->(MsSeek(xFilial("SD7")+SD3->(D3_COD+D3_NUMSEQ)))
			RecLock("SD7",.F.)
			SD7->(dbDelete())
			SD7->(MsUnLock())
			
			SD7->(dbSetOrder(1))
			SD7->(MsSeek(xFilial("SD7")+MDRINV->(D1_NUMCQ)))
			RecLock("SD7",.F.)
			SD7->D7_SALDO += Abs(nQtdInv)
			SD7->D7_SALDO2 += ConvUM(SD7->D7_PRODUTO,Abs(nQtdInv),0,2)
			SD7->(MsUnLock())
		EndIf
		aMATA240 := {}
		MDRINV->(dbSkip())
	End

	MDRINV->(dbCloseArea())
EndIf

Return

/*/{Protheus.doc} MDRInvFalta
Fun��o que processa o ajuste de saldo em fun��o das faltas constatadas durante
o processo de pesagem
@type  User Function
@author Andr� Anjos
@since 09/03/2020
/*/
User Function MDRInvFalta(cProduto,cLocal,cLote,cLocaliz,nQuant,cNumSeq,cNumCQ)
Local cMVTMSOBRA	:= SuperGetMV("MV_XINSFAL",.F.,"")
Local aMATA240		:= {}

//-- Endere�a falta do CQ
SDA->(dbSetOrder(2))
SDA->(MsSeek(xFilial('SDA')+cProduto+cLocal+cLote))
While !SDA->(EOF()) .And. SDA->(DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_LOTECTL) == xFilial('SDA')+cProduto+cLocal+cLote
	If AllTrim(SDA->DA_DOC) == AllTrim(cNumCQ)
		A100Distri(cProduto,cLocal,SDA->DA_NUMSEQ,SDA->DA_DOC,SDA->DA_SERIE,SDA->DA_CLIFOR,SDA->DA_LOJA,cLocaliz,NIL,SDA->DA_SALDO,SDA->DA_LOTECTL,SDA->DA_NUMLOTE)
		Exit
	EndIf

	SDA->(dbSkip())
End

//-- Requisita falta
aAdd(aMATA240,{"D3_TM",cMVTMSOBRA,NIL})
aAdd(aMATA240,{"D3_DOC","INVENTPES",NIL})
aAdd(aMATA240,{"D3_EMISSAO",dDataBase,NIL})
aAdd(aMATA240,{"D3_COD",cProduto,NIL})
aAdd(aMATA240,{"D3_LOCAL",cLocal,NIL})
aAdd(aMATA240,{"D3_LOTECTL",cLote,NIL})
aAdd(aMATA240,{"D3_LOCALIZ",cLocaliz,NIL})
aAdd(aMATA240,{"D3_QUANT",Abs(nQuant),NIL})
aAdd(aMATA240,{"D3_XSEQSD3",cNumSeq,NIL})

lMSErroAuto := .F.
MsExecAuto({|x| MATA240(x,3)},aMATA240)

If lMsErroAuto
	MostraErro()
	DisarmTransaction()
	Break
EndIf

Return