#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH' 

#DEFINE STR0001 'Reimpressão de Etiquetas - ETQCONTR'
#DEFINE STR0002 'Pesquisar' 
#DEFINE STR0003 'Visualizar'
#DEFINE STR0004 'Criar Etiqueta'
#DEFINE STR0005 'Alterar'
#DEFINE STR0006 'Excluir'
#DEFINE STR0007 'Imprimir'
#DEFINE TIPO_PRODUTO    "PA/PI","P","N"
#DEFINE TITULO_JANELA   "ETQCONTR"
#DEFINE MENSAGEM_TEXTO  "Realizando impressão..."
#DEFINE MENSAGEM_EXCLUSAO "Ops.... Não é possível realizar a exclusão de registros através dessa rotina!!!"
#DEFINE MENSAGEM_INCLUSAO "Ops.... Funcionalidade descontinuada!!!"
#DEFINE MENSAGEM_CODET2 "Ops... Registros sem conteúdo na coluna CB0_CODET2 não podem ser impressos!!!"

User Function ETQCONTR()
    Local oBrowse
    oBrowse	:= FWMBrowse():New()
    oBrowse:SetAlias('CB0')
    oBrowse:SetDescription(STR0001)
    oBrowse:Activate()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return 	aRotina - Estrutura
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
				7 - Cópia
			[n,5] Nivel de acesso
			[n,6] Habilita Menu Funcional
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina 	:= {}
    ADD OPTION aRotina TITLE STR0002	ACTION 'PesqBrw'			            OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE STR0003	ACTION 'VIEWDEF.MADERO_ETQCONTR'	            OPERATION MODEL_OPERATION_VIEW ACCESS 0
    ADD OPTION aRotina TITLE STR0004	ACTION 'StaticCall(ETQCONTR,InclEtiq)'	OPERATION MODEL_OPERATION_INSERT ACCESS 0
    ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.MADERO_ETQCONTR'	            OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    ADD OPTION aRotina TITLE STR0006	ACTION 'StaticCall(ETQCONTR,ExclEtiq)'  OPERATION MODEL_OPERATION_DELETE ACCESS 0
    ADD OPTION aRotina TITLE STR0007  	ACTION 'StaticCall(ETQCONTR,PrepEtiq)'	OPERATION 8 ACCESS 0 
Return aRotina

Static Function ModelDef()
    Local oStruct	:= FWFormStruct(1,'CB0',/*bAvalCampo*/,/*lViewUsado*/)
    Local oModel	:= Nil	
    oModel := MPFormModel():New('METQCONTR', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
    oModel:AddFields('DADOS', /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
    oModel:GetModel('DADOS'):SetDescription(STR0001)
Return oModel         

Static Function ViewDef()
    Local oView  
    Local oModel	:= FWLoadModel('ETQCONTR')
    Local oStruct	:= FWFormStruct(2,'CB0')
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField('DADOS',oStruct)
    oView:CreateHorizontalBox('WINDOW',100)
    oView:SetOwnerView('DADOS','WINDOW')
Return oView

Static Function PrepEtiq()
    Local cLinha	:= AllTrim(SC2->C2_XLINHA)
    Local cImpPad   := GetMV("MV_IACD02")
    Local aDados    := {}
    Local aImp      := {}
    Local aArea     := GetArea()
    Local lRimp     := .F. 
    Local lSubProd  := .F. 
    Local nCount    := 0
    Local sConteudo := ""
    Local nCopias   := 1
    Local lDocFis   := Type("lxDocFis") <> "U"
    Local lInspCust := .F.
    Local cTipoDoc  := IIF(SB1->B1_TIPO $ "PA/PI","P","N")
    Local cType
    Local cNFEnt    := CB0->CB0_NFENT
    Local cSeriee   := CB0->CB0_SERIEE
    Local cFornec   := CB0->CB0_FORNEC
    Local cLojaFo   := CB0->CB0_LOJAFO

    Local cTipoProduto  := Posicione('SB1',1,xFilial('SB1')+CB0->CB0_CODPRO,'B1_TIPO')

    cType   := IIF(cTipoProduto=="P","","Pallet")

    IF Empty(CB0->CB0_CODET2)
        MsgInfo(MENSAGEM_CODET2,TITULO_JANELA)
        Return(.F.)
    EndIF
    
    IF AllTrim(cTipoProduto) == 'P'
        dbSelectArea('ZIB')
        ZIB->(dbSetOrder(1))
        IF ZIB->(dbSeek(xFilial('ZIB')+CB0->CBO_CODPRO))
            While ZIB->(.NOT. Eof()) .AND. xFilial('ZIB')+CB0->CB0_CODPRO == ZIB->ZIB_FILIAL+ZIB_PRODUT                
                //Somente etiquetas de apontamento
                IF ZIB->ZIB_APONTA == 'S'                                
                    dbSelectArea('ZIA')
                    ZIA->(dbSetOrder(1))
                    IF ZIA->(dbSeek(xFilial('ZIA')+ZIB->ZIB_TPETQ))
                        IF ZIA->ZIA_PROC == '1'        
                            cImpPad := ZIA->ZIA_IMPPAD                                
                            //Impressora padrao da linha tem prioridade
                            dbSelectArea('Z55')
                            Z55->(dbSetOrder(1))
                            IF Z55->(dbSeek(xFilial('Z55')+cLinha))                                    
                                IF .NOT. Empty(Z55_CODIMP)
                                    cImpPad := Z55->Z55_CODIMP
                                EndIF
                            EndIF
                        //#TB20191129 Thiago Berna -  Ajuste para considerar a impressora definida no ZIA_IMPPAD quando o ZIA_PROC for 0
                        ELSEIF ZIA->ZIA_PROC == '0'
                            cImpPad := ZIA->ZIA_IMPPAD                        
                        ELSE                                
                            cImpPad := ''                        
                        EndIF                    
                    EndIF     
                    AAdd(aDados,{SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD),SC2->C2_PRODUTO,SC2->C2_XLOTE,ZIB->ZIB_QTDE,cImpPad,lRimp,lSubProd})                          
                    AAdd(aImp,{'U_ETQ'+ZIB->ZIB_TPETQ,aDados})
                    aDados := {}                                
                EndIF                    
                ZIB->(dbSkip())            
            EndDo            
        EndIF
        For nCount := 1 To Len(aImp)
            &(aImp[nCount,1] + '(aImp[nCount,2])')
        Next nCount
    ELSE
        //Chama impessao de etiqueta para recebimento customizado
        dbSelectArea('ZI1')
        ZI1->(dbSetOrder(1))
        ZI1->(dbSeek(xFilial('ZI1')+cNFEnt+cSeriee+cFornec+cLojafo))
        IF ZI1->(Found())    
            // -> Posiciona no produto inspecionado
        	ZI2->(dbSetOrder(1))
            ZI2->(dbSeek(xFilial('ZI2')+ZI1->ZI1_ID+CB0->CB0_CODPRO))
            IF ZI2->(Found())
            	//While .NOT. ZI2->(Eof()) .AND. ZI2->ZI2_FILIAL == ZI1->ZI1_FILIAL .AND. ZI2->ZI2_ID == ZI1->ZI1_ID .AND. ZI2->ZI2_PROD == CB0->CB0_CODPRO 
                    // -> Posiciona no produto inspecionado
                	ZI3->(dbSetOrder(1))
                    ZI3->(dbSeek(xFilial('ZI3')+ZI2->ZI2_ID+ZI2->ZI2_PROD))
                    IF ZI3->(Found())
            	        //While .NOT. ZI3->(Eof()) .AND. ZI3->ZI3_FILIAL == ZI2->ZI2_FILIAL .AND. ZI3->ZI3_ID == ZI2->ZI2_ID .AND. ZI3->ZI3_PROD == ZI2->ZI2_PROD
                            MsgRun(MENSAGEM_TEXTO,TITULO_JANELA,{||U_ETQ013RI(ZI1->ZI1_ID,cType)})
                            ZI3->(dbSkip())
                        //EndDo
                    EndIF
                    ZI2->(dbSkip())
                //EndDo
            EndIF
        ELSE
            // -> Chama rotina para imprimir etiqueta de recebimento
            //#TB20191203 Thiago Berna - Ajuste para imprimir quando os dados estiverem preenchidos
            IF .NOT. Empty(cNFEnt) .AND. .NOT. Empty(cSeriee) .AND. .NOT. Empty(cFornec) .AND. .NOT.Empty(cLojafo) .AND. Empty(CB0->CB0_OP)
                MsgRun(MENSAGEM_TEXTO,TITULO_JANELA,{||U_ETQ013AR(nCopias,cImpPad,cType,lDocFis,lInspCust,cTipoDoc)})
            ELSE
                MsgRun(MENSAGEM_TEXTO,TITULO_JANELA,{||U_ETQ018RI()})    
            EndIF
        EndIF   
    EndIF
Return

Static Function ExclEtiq()
    Local lRet  := .F.
    MsgInfo(MENSAGEM_EXCLUSAO,TITULO_JANELA)
Return(lRet)

Static Function InclEtiq()
    Local lRet  := .F.
    MsgInfo(MENSAGEM_INCLUSAO,TITULO_JANELA)
Return(lRet)