//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
  
//Variáveis Estáticas
Static cTitulo := "Transferencias ERP x WMS CyberLog"
  
/*/{Protheus.doc} CadZA8
Rotina para Gerenciar a Integração das Transferencias entre o ERP x WMS CyberLog
@type function
@version 12.1.27  
@author Carlos Cleuber Pereira
@since 30/01/2021
/*/ 
User Function CadZA8TR
    Local aArea   := GetArea()
    Local oBrowse

    Private bLeg:= {||fLeg()}
    Private bVJson:= {||fVJson()}
    Private bEJson:= {||fExpTrf()}

    //Cria um browse para a ZA8
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZA8")
    oBrowse:SetDescription(cTitulo)
    oBrowse:setMenuDef('ZANLORENZI_FTRFWMS')
    oBrowse:SetFilterDefault( 'ZA8->ZA8_TIPO == "TR"' )
    oBrowse:SetUseFilter(.T.)
    oBrowse:DisableDetails()

	oBrowse:AddLegend( "ZA8->ZA8_STAWMS == ' ' "		,"BR_BRANCO"    ,"Não Enviado" )
    oBrowse:AddLegend( "ZA8->ZA8_STAWMS == 'E' "		,"BR_AZUL"      ,"Enviado" )
    oBrowse:AddLegend( "ZA8->ZA8_STAWMS == 'R' "		,"BR_AZUL_CLARO","Reenviado" )
    oBrowse:AddLegend( "ZA8->ZA8_STAWMS == 'F' "		,"BR_VERMELHO"  ,"Falha no Envio" )
    oBrowse:AddLegend( "ZA8->ZA8_STAWMS == 'X' "		,"BR_PRETO"     ,"Falha no retorno" )
    oBrowse:AddLegend( "ZA8->ZA8_STAWMS == 'O' "		,"BR_VERDE"     ,"Retorno com Sucesso" )
    oBrowse:AddLegend( "ZA8->ZA8_STAWMS == 'C' "		,"BR_CANCEL"    ,"Estornado" )
    
    oBrowse:Activate()
      
    RestArea(aArea)
Return Nil
 
  //-------------------------------------------------------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} MenuDef
Menudef
@type function
@version 12.1.27
@author Carlos Cleuber
@since 30/01/2021
/*/ 
Static Function MenuDef()
    Local aRot := {}
      
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar'                          ACTION 'VIEWDEF.ZANLORENZI_TRANSFWMS'   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'                             ACTION 'VIEWDEF.ZANLORENZI_TRANSFWMS'   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'                             ACTION 'VIEWDEF.ZANLORENZI_TRANSFWMS'   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'                             ACTION 'VIEWDEF.ZANLORENZI_TRANSFWMS'   OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE "CyberLog - Valida JSon WMS"	        ACTION 'eval(bVJson)'                   OPERATION 9                      ACCESS 0 
    ADD OPTION aRot TITLE "CyberLog - Envia Transf. JSon WMS"	ACTION 'eval(bEJson)'                   OPERATION 9                      ACCESS 0 
    ADD OPTION aRot Title 'Legenda'                             ACTION 'eval(bLeg)'                     OPERATION 9                      ACCESS 0
    
Return aRot
 
 //-------------------------------------------------------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} ModelDef
ModelDef
@type function
@version 12.1.27 
@author Carlos Cleuber
@since 30/01/2021
/*/ 
Static Function ModelDef()
    //Na montagem da estrutura do Modelo de dados, o cabeçalho filtrará e exibirá somente 3 campos, já a grid irá carregar a estrutura inteira conforme função fModStruct
    Local oModel    := NIL
    Local oStruCab  := FWFormStruct(1, 'ZA8')
    Local oStruGrid := FWFormStruct(1, 'ZA8')
    Local aRelation := {}
 
    //Monta o modelo de dados, e na Pós Validação, informa a função fValidGrid
    oModel := MPFormModel():New('MdlZA8M',/*bPreValidacao*/, {|oModel| fVldTOK(oModel)}/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )  

    oStruCab:removeField("ZA8_FILIAL")
    oStruCab:removeField("ZA8_ITEM")
    oStruCab:removeField("ZA8_PRODUT")
    oStruCab:removeField("ZA8_DESC")
    oStruCab:removeField("ZA8_UM")
    oStruCab:removeField("ZA8_ARMORI")
    oStruCab:removeField("ZA8_ENDORI")
    oStruCab:removeField("ZA8_ARMDES")
    oStruCab:removeField("ZA8_ENDDES")
    oStruCab:removeField("ZA8_LOTECT")
    oStruCab:removeField("ZA8_DTVALID")
    oStruCab:removeField("ZA8_QUANT")
    oStruCab:removeField("ZA8_STAWMS")
    oStruCab:removeField("ZA8_TM")
    oStruCab:removeField("ZA8_CF")    

    oStruGrid:removeField("ZA8_FILIAL")
    oStruGrid:removeField("ZA8_DOC")
    oStruGrid:removeField("ZA8_EMISSA")
    oStruGrid:removeField("ZA8_USRREQ")
    oStruGrid:removeField("ZA8_TIPO")
    oStruGrid:removeField("ZA8_TM")
    oStruGrid:removeField("ZA8_CF")    
        
    //Agora, define no modelo de dados, que terá um Cabeçalho e uma Grid apontando para estruturas acima
    oModel:AddFields('MdFieldZA8', NIL, oStruCab)
    oModel:AddGrid('MdGridZA8', 'MdFieldZA8', oStruGrid )

    //Adiciona o relacionamento de Filho, Pai
	aAdd(aRelation, {'ZA8_FILIAL', 'Iif(!INCLUI, ZA8_FILIAL, FWxFilial("ZA8"))'} )
	aAdd(aRelation, {'ZA8_DOC'  , 'Iif(!INCLUI, ZA8_DOC, ZA8_DOC  )'} ) 


    //Monta o relacionamento entre Grid e Cabeçalho, as expressões da Esquerda representam o campo da Grid e da direita do Cabeçalho
    oModel:SetRelation('MdGridZA8', aRelation, ZA8->(IndexKey(1)))
      
    //Definindo outras informações do Modelo e da Grid
    oModel:GetModel("MdGridZA8"):SetMaxLine(999)
    oModel:SetDescription("Transferencias entre Protheus X WMS CyberLog")
    oModel:SetPrimaryKey({})
 
Return oModel

//-------------------------------------------------------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} ViewDef
Viewdef
@type function
@version 12.1.27
@author Carlos Cleuber
@since 30/01/2021
/*/ 
Static Function ViewDef()
    Local oModel    := ModelDef() 
    Local oView     := FWFormView():New() 
    Local oStruCab  := FWFormStruct(2, "ZA8")
    Local oStruGRID := FWFormStruct(2, "ZA8")

    oStruCab:removeField("ZA8_FILIAL")
    oStruCab:removeField("ZA8_ITEM")
    oStruCab:removeField("ZA8_PRODUT")
    oStruCab:removeField("ZA8_DESC")
    oStruCab:removeField("ZA8_UM")
    oStruCab:removeField("ZA8_ARMORI")
    oStruCab:removeField("ZA8_ENDORI")
    oStruCab:removeField("ZA8_ARMDES")
    oStruCab:removeField("ZA8_ENDDES")
    oStruCab:removeField("ZA8_LOTECT")
    oStruCab:removeField("ZA8_DTVALI")
    oStruCab:removeField("ZA8_QUANT")
    oStruCab:removeField("ZA8_STAWMS")
    oStruCab:removeField("ZA8_TM")    
    oStruCab:removeField("ZA8_CF")    

    oStruGrid:removeField("ZA8_FILIAL")
    oStruGrid:removeField("ZA8_DOC")
    oStruGrid:removeField("ZA8_EMISSA")
    oStruGrid:removeField("ZA8_USRREQ")
    oStruGrid:removeField("ZA8_STAWMS")
    oStruGrid:removeField("ZA8_TIPO")
    oStruGrid:removeField("ZA8_TM")    
    oStruGrid:removeField("ZA8_CF")    
    
    //Cria o View
    oView:SetModel(oModel)              
 
    //Cria uma área de Field vinculando a estrutura do cabeçalho com MDFieldZA8, e uma Grid vinculando com MdGridZA8
    oView:AddField('VIEW_ZA8', oStruCab, 'MdFieldZA8')
    oView:AddGrid ('GRID_ZA8', oStruGRID, 'MdGridZA8' )
 
    //O cabeçalho (MAIN) terá 15% de tamanho, e o restante de 85% irá para a GRID
    oView:CreateHorizontalBox("MAIN", 15)
    oView:CreateHorizontalBox("GRID", 85)
 
    //Vincula o MAIN com a VIEW_ZA8 e a GRID com a GRID_ZA8
    oView:SetOwnerView('VIEW_ZA8', 'MAIN')
    oView:SetOwnerView('GRID_ZA8', 'GRID')

    //Define o campo incremental da grid como o ZA8_ITEM
    oView:AddIncrementField('GRID_ZA8', 'ZA8_ITEM')
Return oView


//-------------------------------------------------------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} fVldTOK
Funcao Validacao dos campos
@type function
@version 12.1.27
@author Carlos Cleuber
@since 30/01/2021
/*/ 
Static Function fVldTOK(oModel)
Local oModelGRID    := FWModelActive()
Local aSaveLine 	:= FWSaveRows()
Local cEndERP	    := alltrim(SuperGetMV("FZ_XENDERP"))
Local cEndWMS	    := alltrim(SuperGetMV("FZ_XENDWMS"))
Local cArmERP       := substr(cEndERP,1,2)
Local cArmWMS       := substr(cEndWMS,1,2)
Local cArmOri	    := ''
Local cArmDes	    := ''
Local cProduto	    := ''
Local nDeletados    := 0
Local nLinAtual     := 0
Local lRet  		:= .T.

If lRet
    //Percorrendo todos os itens da grid
    For nLinAtual := 1 To oModelGRID:GetModel("MdGridZA8"):Length() 
        //Posiciona na linha
        oModelGRID:GetModel("MdGridZA8"):GoLine(nLinAtual) 

        cArmOri	    := oModel:GetModel('MdGridZA8'):GetValue('ZA8_ARMORI')
        cArmDes	    := oModel:GetModel('MdGridZA8'):GetValue('ZA8_ARMDES')
        cProduto	:= oModel:GetModel('MdGridZA8'):GetValue('ZA8_PRODUT')        

        If GetAdvFVal("SBZ","BZ_XINTWMS",xFilial("SBZ")+cProduto,1) != "S"
            lRet :=.F.
            Help( , , 'Produto' , , '[Linha'+ cvaltochar(nLinAtual)+ '] - Produto não esta configurado para integração com WMS Cyberlog!', 1, 0, , , , , , {"Favor utilizar um produto valido para integração!"})        
        Endif

        If lRet .and. !cArmOri $ cArmERP .and. !cArmOri $ cArmWMS
            lRet :=.F.
            Help( , , 'Armazém Origem' , , '[Linha'+ cvaltochar(nLinAtual)+ '] - Armazém Origem não esta configurado para integração com WMS Cyberlog!', 1, 0, , , , , , {"Favor utilizar um armazém valido para integração!"})
        Endif

        If lRet .and. !cArmOri $ cArmERP .and. !cArmOri $ cArmWMS
            lRet :=.F.
            Help( , , 'Armazém Destino' , , '[Linha'+ cvaltochar(nLinAtual)+ '] - Armazém Destino não esta configurado para integração com WMS Cyberlog!', 1, 0, , , , , , {"Favor utilizar um armazém valido para integração!"})
        Endif        
            
        //Se a linha for excluida, incrementa a variável de deletados, senão irá incrementar o valor digitado em um campo na grid
        If oModelGRID:GetModel("MdGridZA8"):IsDeleted()
            nDeletados++
        EndIf
    Next nLinAtual

    //Se o tamanho da Grid for igual ao número de itens deletados, acusa uma falha
    If oModelGRID:GetModel("MdGridZA8"):Length()==nDeletados
        lRet :=.F.
        Help( , , 'Dados Inválidos' , , 'A grid precisa ter pelo menos 1 linha sem ser excluida!', 1, 0, , , , , , {"Inclua uma linha válida!"})
    EndIf
        
Endif

FWRestRows( aSaveLine )

Return lRet


//-------------------------------------------------------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} fVJson
Rotina para mostrar o Json do Lote
@version 12.1.27
@type function
@author Carlos CLeuber
@since 31/01/2021
/*/
Static Function fVJson
Local cJson:= ''
Local cKey:= ZA8->(ZA8_DOC+ZA8_ITEM+ZA8_PRODUT+ZA8_LOTECT)

cJson:= U_fGrJson( GetMv('FZ_WSWMS9'), 'ZA8', 1, 'ZA8_FILIAL+ZA8_DOC+ZA8_ITEM+ZA8_PRODUT+ZA8_LOTECT', FWxFilial('ZA8')+cKey )
EECVIEW( cJson )

Return

//-------------------------------------------------------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} fExpTrf
Função para exportar os registros 
@type function
@author Carlos CLeuber
@since 31/01/2021
@version 12.1.27
/*/
Static Function fExpTrf
Local aZA8:= GetArea()

//For nX:=1 to len(aCols)

	If GetAdvFVal("SBZ","BZ_XINTWMS",xFilial("SBZ")+ZA8->ZA8_PRODUT,1) == "S" //Verifico se o produto tem integração com o WMS CyberLog

		cKey:= ZA8->(ZA8_DOC+ZA8_ITEM+ZA8_PRODUT+ZA8_LOTECT)
		aRet:= U_fConJson(GetMv('FZ_WSWMS9'), 'ZA8', 1, 'ZA8_FILIAL+ZA8_DOC+ZA8_ITEM+ZA8_PRODUT+ZA8_LOTECT', FWxFilial('ZA8')+cKey )
		If aRet[1]
			RecLock("ZA8",.F.)
			ZA8->ZA8_STAWMS:= "E"
			ZA8->(MsUnlock())
		else
			RecLock("ZA8",.F.)
			ZA8->ZA8_STAWMS:= "F"
			ZA8->(MsUnlock())
        Endif
		
	Endif

//Next

RestArea(aZA8)

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} fLeg
Legenda Painel Integracao WMS
@version 12.1.27
@type function
@author Carlos CLeuber
@since 15/01/2021
/*/
Static Function fLeg()

Local	aLegenda  := {	{'BR_BRANCO'	,'Item não Integrado ao WMS'}		,;
						{'BR_AZUL'		,'Item enviado ao WMS'}				,;
						{'BR_AZUL_CLARO','Item Renviado ao WMS'}			,;
						{'BR_VERMELHO'	,'Item com falha no envio do WMS'}	,;
						{'BR_PRETO'		,'Item com falha no retorno do WMS'},;
						{'BR_VERDE'		,'Item com sucesso no retorno'}		,;
						{'BR_CANCEL'	,'Item Estornado'}}

BrwLegenda("Painel de Integração",'Legenda',aLegenda)

Return .T.
