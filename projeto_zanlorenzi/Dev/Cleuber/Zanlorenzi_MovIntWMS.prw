//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
  
//Vari�veis Est�ticas
Static cTitulo := "Movimenta��es Internas ERP x WMS CyberLog"
  
/*/{Protheus.doc} CadZA8MI
Rotina para Gerenciar a Integra��o das Movimenta��es Internas entre o ERP x WMS CyberLog
@type function
@version 12.1.27  
@author Carlos Cleuber Pereira
@since 30/01/2021
/*/ 
User Function CadZA8MI
    Local aArea   := GetArea()
    Local oBrowse

    Private bLeg:= {||fLeg()}
    Private bVJson:= {||fVJson()}
    Private bEJson:= {||fMovInt()}

    //Cria um browse para a ZA8
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZA8")
    oBrowse:SetDescription(cTitulo)
    oBrowse:setMenuDef('ZANLORENZI_MOVINTWMS')
    oBrowse:SetFilterDefault( 'ZA8->ZA8_TIPO == "MI"' )
    oBrowse:SetUseFilter(.T.)
    oBrowse:DisableDetails()

	oBrowse:AddLegend( "ZA8->ZA8_STAWMS == ' ' "		,"BR_BRANCO"    ,"N�o Enviado" )
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
      
    //Adicionando op��es
    ADD OPTION aRot TITLE 'Visualizar'                          ACTION 'VIEWDEF.ZANLORENZI_MOVINTWMS'   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'                             ACTION 'VIEWDEF.ZANLORENZI_MOVINTWMS'   OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'                             ACTION 'VIEWDEF.ZANLORENZI_MOVINTWMS'   OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'                             ACTION 'VIEWDEF.ZANLORENZI_MOVINTWMS'   OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE "CyberLog - Valida JSon WMS"	        ACTION 'eval(bVJson)'                   OPERATION 9                      ACCESS 0 
    ADD OPTION aRot TITLE "CyberLog - Envia Mov.Int. JSon WMS"	ACTION 'eval(bEJson)'                   OPERATION 9                      ACCESS 0 
    ADD OPTION aRot Title 'Legenda'                             ACTION 'eval(bLeg)'			            OPERATION 9                      ACCESS 0
    
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
    //Na montagem da estrutura do Modelo de dados, o cabe�alho filtrar� e exibir� somente 3 campos, j� a grid ir� carregar a estrutura inteira conforme fun��o fModStruct
    Local oModel    := NIL
    Local oStruCab  := FWFormStruct(1, 'ZA8')
    Local oStruGrid := FWFormStruct(1, 'ZA8')
    Local aRelation := {}
 
    //Monta o modelo de dados, e na P�s Valida��o, informa a fun��o fValidGrid
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
    oStruGrid:removeField("ZA8_ARMDES")
    oStruGrid:removeField("ZA8_EMISSA")
    oStruGrid:removeField("ZA8_USRREQ")
    oStruGrid:removeField("ZA8_TIPO")
        
    //Agora, define no modelo de dados, que ter� um Cabe�alho e uma Grid apontando para estruturas acima
    oModel:AddFields('CabZA8', NIL, oStruCab)
    oModel:AddGrid('GridZA8', 'CabZA8', oStruGrid )

    //Adiciona o relacionamento de Filho, Pai
	aAdd(aRelation, {'ZA8_FILIAL', 'Iif(!INCLUI, ZA8_FILIAL, FWxFilial("ZA8"))'} )
	aAdd(aRelation, {'ZA8_DOC'  , 'Iif(!INCLUI, ZA8_DOC, ZA8_DOC  )'} ) 


    //Monta o relacionamento entre Grid e Cabe�alho, as express�es da Esquerda representam o campo da Grid e da direita do Cabe�alho
    oModel:SetRelation('GridZA8', aRelation, ZA8->(IndexKey(1)))
      
    //Definindo outras informa��es do Modelo e da Grid
    oModel:GetModel("GridZA8"):SetMaxLine(999)
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
    oStruGrid:removeField("ZA8_ARMDES")
    oStruGrid:removeField("ZA8_USRREQ")
    oStruGrid:removeField("ZA8_STAWMS")
    oStruGrid:removeField("ZA8_TIPO")
 
    //Cria o View
    oView:SetModel(oModel)              
 
    //Cria uma �rea de Field vinculando a estrutura do cabe�alho com CabZA8, e uma Grid vinculando com GridZA8
    oView:AddField('VIEW_ZA8', oStruCab, 'CabZA8')
    oView:AddGrid ('GRID_ZA8', oStruGRID, 'GridZA8' )
 
    //O cabe�alho (MAIN) ter� 15% de tamanho, e o restante de 85% ir� para a GRID
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
Local cProduto	    := ''
Local nDeletados    := 0
Local nLinAtual     := 0
Local lRet  		:= .T.

If lRet
    //Percorrendo todos os itens da grid
    For nLinAtual := 1 To oModelGRID:GetModel("GridZA8"):Length() 
        //Posiciona na linha
        oModelGRID:GetModel("GridZA8"):GoLine(nLinAtual) 

        cArmOri	    := oModel:GetModel('GridZA8'):GetValue('ZA8_ARMORI')
        cProduto	:= oModel:GetModel('GridZA8'):GetValue('ZA8_PRODUT')        

        If GetAdvFVal("SBZ","BZ_XINTWMS",xFilial("SBZ")+cProduto,1) != "S"
            lRet :=.F.
            Help( , , 'Produto' , , '[Linha'+ cvaltochar(nLinAtual)+ '] - Produto n�o esta configurado para integra��o com WMS Cyberlog!', 1, 0, , , , , , {"Favor utilizar um produto valido para integra��o!"})        
        Endif

        If lRet .and. !cArmOri $ cArmERP .and. !cArmOri $ cArmWMS
            lRet :=.F.
            Help( , , 'Armaz�m Origem' , , '[Linha'+ cvaltochar(nLinAtual)+ '] - Armaz�m Origem n�o esta configurado para integra��o com WMS Cyberlog!', 1, 0, , , , , , {"Favor utilizar um armaz�m valido para integra��o!"})
        Endif

        //Se a linha for excluida, incrementa a vari�vel de deletados, sen�o ir� incrementar o valor digitado em um campo na grid
        If oModelGRID:GetModel("GridZA8"):IsDeleted()
            nDeletados++
        EndIf
    Next nLinAtual

    //Se o tamanho da Grid for igual ao n�mero de itens deletados, acusa uma falha
    If oModelGRID:GetModel("GridZA8"):Length()==nDeletados
        lRet :=.F.
        Help( , , 'Dados Inv�lidos' , , 'A grid precisa ter pelo menos 1 linha sem ser excluida!', 1, 0, , , , , , {"Inclua uma linha v�lida!"})
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

cJson:= U_fGrJson( GetMv('FZ_WSWMS8'), 'ZA8', 1, 'ZA8_FILIAL+ZA8_DOC+ZA8_ITEM+ZA8_PRODUT+ZA8_LOTECT', FWxFilial('ZA8')+cKey )
EECVIEW( cJson )

Return

//-------------------------------------------------------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} fExpTrf
Fun��o para exportar os registros 
@type function
@author Carlos CLeuber
@since 31/01/2021
@version 12.1.27
/*/
Static Function fMovInt
Local aZA8:= GetArea()

//For nX:=1 to len(aCols)

	If GetAdvFVal("SBZ","BZ_XINTWMS",xFilial("SBZ")+ZA8->ZA8_PRODUT,1) == "S" //Verifico se o produto tem integra��o com o WMS CyberLog

		cKey:= ZA8->(ZA8_DOC+ZA8_ITEM+ZA8_PRODUT+ZA8_LOTECT)
		aRet:= U_fConJson(GetMv('FZ_WSWMS8'), 'ZA8', 1, 'ZA8_FILIAL+ZA8_DOC+ZA8_ITEM+ZA8_PRODUT+ZA8_LOTECT', FWxFilial('ZA8')+cKey )
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

Local	aLegenda  := {	{'BR_BRANCO'	,'Item n�o Integrado ao WMS'}		,;
						{'BR_AZUL'		,'Item enviado ao WMS'}				,;
						{'BR_AZUL_CLARO','Item Renviado ao WMS'}			,;
						{'BR_VERMELHO'	,'Item com falha no envio do WMS'}	,;
						{'BR_PRETO'		,'Item com falha no retorno do WMS'},;
						{'BR_VERDE'		,'Item com sucesso no retorno'}		,;
						{'BR_CANCEL'	,'Item Estornado'}}

BrwLegenda("Painel de Integra��o",'Legenda',aLegenda)

Return .T.
