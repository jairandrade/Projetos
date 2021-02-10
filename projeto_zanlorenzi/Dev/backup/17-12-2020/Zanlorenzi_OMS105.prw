//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Vari�veis Est�ticas
Static cTitulo := ""

/*/{Protheus.doc} OMS105
Modelo 2 EM mvc para Integra��o Integra��o x Transportadora na tabela ZA7
@author Jair Andrade
@since 07/12/2020
@version 1.0
    @return Nil, Fun��o n�o tem retorno
    @example
/*/
User Function OMS105()

	Local oBrowse
	Private aRotina := MenuDef()
	Private __lCopia := .F.

	//Cria um browse para a ZA7, filtrando somente a tabela 00 (cabe�alho das tabelas
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZA7")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetFilterDefault("ZA7->ZA7_ITEM == '001'")
	oBrowse:Activate()

Return Nil
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor:  Jair Andrade                                                |
 | Data:  07/12/2020                                                   |
 | Desc:  Cria��o do menu MVC                                          |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando op��es
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.Zanlorenzi_OMS105' OPERATION 2 ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'u_TestSel' OPERATION 3 ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'u_OMS105A' OPERATION 4 ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.Zanlorenzi_OMS105' OPERATION 5 ACCESS 0 //OPERATION 5
Return aRot
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor:  Jair Andrade                                                |
 | Data:  07/12/2020                                                   |
 | Desc:  Cria��o do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
Static Function ModelDef()
    Local oModel   := Nil
    Local oStTmp   := FWFormModelStruct():New()
    Local oStFilho := FWFormStruct(1, 'ZA7')
    Local bVldPos  := {|| u_OMS105V()}
    Local bVldCom  := {|| u_OMS105S()}
    Local aZA7Rel  := {}
     
    //Adiciona a tabela na estrutura tempor�ria
    oStTmp:AddTable('ZA7', {'ZA7_FILIAL', 'ZA7_CODIGO', 'ZA7_TRANSP'}, "Cabecalho ZA7")
     
    //Adiciona o campo de Filial
    oStTmp:AddField(;
        "Filial",;                                                                                  // [01]  C   Titulo do campo
        "Filial",;                                                                                  // [02]  C   ToolTip do campo
        "ZA7_FILIAL",;                                                                               // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        TamSX3("ZA7_FILIAL")[1],;                                                                    // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de valida��o do campo
        Nil,;                                                                                       // [08]  B   Code-block de valida��o When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigat�rio
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZA7->ZA7_FILIAL,FWxFilial('ZA7'))" ),;   // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma opera��o de update.
        .F.)                                                                                        // [14]  L   Indica se o campo � virtual
     
    //Adiciona o campo de C�digo da Tabela
    oStTmp:AddField(;
        "C�digo",;                                                                    // [01]  C   Titulo do campo
        "C�digo",;                                                                    // [02]  C   ToolTip do campo
        "ZA7_CODIGO",;                                                                  // [03]  C   Id do Field
        "C",;                                                                         // [04]  C   Tipo do campo
        TamSX3("ZA7_CODIGO")[1],;                                                      // [05]  N   Tamanho do campo
        0,;                                                                           // [06]  N   Decimal do campo
        Nil,;                                                                         // [07]  B   Code-block de valida��o do campo
        Nil,;                                                                         // [08]  B   Code-block de valida��o When do campo
        {},;                                                                          // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigat�rio
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZA7->ZA7_CODIGO,GETSXENUM('ZA7','ZA7_CODIGO'))" ),;    // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma opera��o de update.
        .F.)                                                                          // [14]  L   Indica se o campo � virtual
     
    oStTmp:AddField(;
        "Transportadora",;                                                            // [01]  C   Titulo do campo
        "Transportadora",;                                                            // [02]  C   ToolTip do campo
        "ZA7_TRANSP",;                                                                 // [03]  C   Id do Field
        "C",;                                                                         // [04]  C   Tipo do campo
        TamSX3("ZA7_TRANSP")[1],;                                                      // [05]  N   Tamanho do campo
        0,;                                                                           // [06]  N   Decimal do campo
        Nil,;                                                                         // [07]  B   Code-block de valida��o do campo
        Nil,;                                                                         // [08]  B   Code-block de valida��o When do campo
        {},;                                                                          // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigat�rio
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZA7_TRANSP,'')" ),;   // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma opera��o de update.
        .F.)  
     
    //Setando as propriedades na grid, o inicializador da Filial e Tabela, para n�o dar mensagem de coluna vazia
    oStFilho:SetProperty('ZA7_FILIAL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
    oStFilho:SetProperty('ZA7_CODIGO', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
     
    //Criando o FormModel, adicionando o Cabe�alho e Grid
    oModel := MPFormModel():New("Zanlorenzi_OMS105", , bVldPos, bVldCom) 
    oModel:AddFields("FORMCAB",/*cOwner*/,oStTmp)
    oModel:AddGrid('ZA7DETAIL','FORMCAB',oStFilho,{ |oModelGrid, nLine, cAction, cField| COMPLPRE(oModelGrid, nLine, cAction, cField) })
     
    //Adiciona o relacionamento de Filho, Pai
    aAdd(aZA7Rel, {'ZA7_FILIAL', 'Iif(!INCLUI, ZA7->ZA7_FILIAL, FWxFilial("ZA7"))'} )
    aAdd(aZA7Rel, {'ZA7_CODIGO', 'Iif(!INCLUI, ZA7->ZA7_CODIGO,  "")'} ) 
     
    //Criando o relacionamento
    oModel:SetRelation('ZA7DETAIL', aZA7Rel, ZA7->(IndexKey(1)))
     
    //Setando o campo �nico da grid para n�o ter repeti��o
    oModel:GetModel( 'ZA7DETAIL' ):SetUniqueLine( { "ZA7_CODIGO" , "ZA7_ITEM"} )

     //Definindo que usar� a grid no formato antigo
    oModel:GetModel('ZA7DETAIL'):SetUseOldGrid(.T.)
     
    //Setando outras informa��es do Modelo de Dados
    oModel:SetDescription("Integra��o Integra��o x Transportadora "+cTitulo)
    oModel:SetPrimaryKey({})
    oModel:GetModel("FORMCAB"):SetDescription("Formul�rio do Cadastro "+cTitulo)
Return oModel
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor:  Jair Andrade                                                |
 | Data:  07/12/2020                                                   |
 | Desc:  Cria��o da vis�o MVC                                         |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
    Local oModel     := FWLoadModel("Zanlorenzi_OMS105")
    Local oStTmp     := FWFormViewStruct():New()
    Local oStFilho   := FWFormStruct(2, 'ZA7')
    Local oView      := Nil
     
    //Adicionando o campo Chave para ser exibido
    oStTmp:AddField(;
        "ZA7_CODIGO",;                // [01]  C   Nome do Campo
        "01",;                      // [02]  C   Ordem
        "C�digo",;                  // [03]  C   Titulo do campo
        X3Descric('ZA7_CODIGO'),;    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("ZA7_CODIGO"),;    // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;     // [10]  L   Indica se o campo � alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior op��o do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo � virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha ap�s o campo
     
        oStTmp:AddField(;
        "ZA7_TRANSP",;               // [01]  C   Nome do Campo
        "02",;                      // [02]  C   Ordem
        "Transportadora",;               // [03]  C   Titulo do campo
        X3Descric('ZA7_TRANSP'),;    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("ZA7_TRANSP"),;    // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        "SA4",;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo � alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior op��o do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo � virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha ap�s o campo
     
    //Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_CAB", oStTmp, "FORMCAB")
    oView:AddGrid('VIEW_ZA7',oStFilho,'ZA7DETAIL')
    oView:AddIncrementField( 'VIEW_ZA7', 'ZA7_ITEM' )
     
    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',30)
    oView:CreateHorizontalBox('GRID',70)
     
    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_CAB','CABEC')
    oView:SetOwnerView('VIEW_ZA7','GRID')
     
    //Habilitando t�tulo
    oView:EnableTitleView('VIEW_CAB','Cabe�alho Integra��o')
    oView:EnableTitleView('VIEW_ZA7','Itens Integra��o')
     
    //Tratativa padr�o para fechar a tela
    oView:SetCloseOnOk({||.T.})
     
    //Remove os campos de Filial e Tabela da Grid
    oStFilho:RemoveField('ZA7_FILIAL')
    oStFilho:RemoveField('ZA7_CODIGO')
Return oView

/*/{Protheus.doc} OMS105V
Fun��o chamada na valida��o do bot�o Confirmar, para verificar se j� existe a tabela digitada
@type function
@author Jair Andrade
@since 07/12/2020
@version 1.0
    @return lRet, .T. se pode prosseguir e .F. se deve barrar
/*/
User Function OMS105V()

	Local aArea      := GetArea()
	Local lRet       := .T.
	Local oModelDad  := FWModelActive()
	Local cFilZA7    := oModelDad:GetValue('FORMCAB', 'ZA7_FILIAL')
	Local cCodigo    := SubStr(oModelDad:GetValue('FORMCAB', 'ZA7_CODIGO'), 1, TamSX3('ZA7_CODIGO')[01])
	Local nOpc       := oModelDad:GetOperation()

	//Se for Inclus�o
	If nOpc == 3
		DbSelectArea('ZA7')
		ZA7->(DbSetOrder(1)) //ZA7_FILIAL + ZA7_CODIGO + ZA7_CODIGO

		//Se conseguir posicionar, tabela j� existe
		If ZA7->(DbSeek(cFilZA7 +cCodigo))
		
			Aviso('Aten��o', 'Esse c�digo de Integra��o j� existe!', {'OK'}, 02)
			lRet := .F.
		EndIf
	ElseIf nOpc ==9
		ALERT("OP��O 9")
	EndIf

RestArea(aArea)
Return lRet
/*/{Protheus.doc} OMS105S
Fun��o desenvolvida para salvar os dados do Modelo 2
@type function
@author Jair Andrade
@since 07/12/2020
@version 1.0
/*/
User Function OMS105S()
	Local aArea      := GetArea()
	Local lRet       := .T.
	Local oModelDad  := FWModelActive()
	Local cFilZA7    := oModelDad:GetValue('FORMCAB', 'ZA7_FILIAL')
	Local cCodigo    := SubStr(oModelDad:GetValue('FORMCAB', 'ZA7_CODIGO'), 1, TamSX3('ZA7_CODIGO')[01])
	Local cDescri    := oModelDad:GetValue('FORMCAB', 'ZA7_DESCRI')
	Local cOcor      := oModelDad:GetValue('FORMCAB', 'ZA7_TRANSP')
	Local nOpc       := oModelDad:GetOperation()
	Local oModelGrid := oModelDad:GetModel('ZA7DETAIL')
	Local aHeadAux   := oModelGrid:aHeader
	Local aColsAux   := oModelGrid:aCols
	Local nPosCampo  := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA7_CAMPO")})
	Local nPosIt  := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA7_ITEM")})
	Local nPosIni := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA7_POSINI")})
	Local nPosFim := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA7_POSFIM")})
	Local nPosTpDad := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA7_TPDADO")})
	Local nPosTipo := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA7_TIPO")})
	Local nPosConteu := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA7_CONTEU")})
	Local nPosDecima := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA7_DECIMA")})
	Local nPosCodReg := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA7_CODREG")})
	Local nAtual     := 0

	DbSelectArea('ZA7')
	ZA7->(DbSetOrder(2)) //ZA7_FILIAL + ZA7_CODIGO + ZA7_ITEM

	//Se for Inclus�o
	If nOpc == 3

		//Percorre as linhas da grid
		For nAtual := 1 To oModelGrid:Length()
			//Posicionando na linha
			oModelGrid:GoLine(nAtual)
			//Se a linha n�o estiver exclu�da, inclui o registro
			If(!oModelGrid:IsDeleted())
				RecLock('ZA7', .T.)
				ZA7_FILIAL   := cFilZA7
				ZA7_CODIGO   := cCodigo
				ZA7_DESCRI   := cDescri
				ZA7_TRANSP     := cOcor//aColsAux[nAtual][nPosOcor]
				ZA7_ITEM    := oModelGrid:aCols[nAtual][nPosIt]
				ZA7_CAMPO    := oModelGrid:aCols[nAtual][nPosCampo]
                ZA7_CODREG    := oModelGrid:aCols[nAtual][nPosCodReg]
				ZA7_POSINI   := oModelGrid:aCols[nAtual][nPosIni]
				ZA7_POSFIM   := oModelGrid:aCols[nAtual][nPosFim]
				ZA7_TPDADO   := oModelGrid:aCols[nAtual][nPosTpDad]
				ZA7_TIPO     := oModelGrid:aCols[nAtual][nPosTipo]
				ZA7_CONTEU   := oModelGrid:aCols[nAtual][nPosConteu]
				ZA7_DECIMA   := oModelGrid:aCols[nAtual][nPosDecima]
				ZA7->(MsUnlock())
			EndIf
		Next nAtual

		//Se for Altera��o
	ElseIf nOpc == 4
		//Se conseguir posicionar, altera a descri��o digitada
		If ZA7->(DbSeek(cFilZA7 + cCodigo))
			//Percorre as linhas da grid
			For nAtual := 1 To oModelGrid:Length()
				//Posicionando na linha
				oModelGrid:GoLine(nAtual)
				//Se a linha n�o estiver exclu�da, inclui o registro
				If(!oModelGrid:IsDeleted())
					//Se conseguir posicionar no registro, ser� altera��o
					If ZA7->(DbSeek(cFilZA7 + cCodigo + oModelGrid:aCols[nAtual][nPosIt]))
						RecLock('ZA7', .F.)

						//Sen�o, ser� inclus�o
					Else
						RecLock('ZA7', .T.)
						ZA7_FILIAL := cFilZA7
						ZA7_CODIGO := cCodigo
					EndIf
					ZA7_DESCRI   := cDescri
					ZA7_TRANSP     := cOcor//aColsAux[nAtual][nPosOcor]
					ZA7_ITEM    := oModelGrid:aCols[nAtual][nPosIt]
					ZA7_CAMPO    := oModelGrid:aCols[nAtual][nPosCampo]
                    ZA7_CODREG    := oModelGrid:aCols[nAtual][nPosCodReg]
					ZA7_POSINI   := oModelGrid:aCols[nAtual][nPosIni]
					ZA7_POSFIM   := oModelGrid:aCols[nAtual][nPosFim]
					ZA7_TPDADO   := oModelGrid:aCols[nAtual][nPosTpDad]
					ZA7_TIPO     := oModelGrid:aCols[nAtual][nPosTipo]
					ZA7_CONTEU   := oModelGrid:aCols[nAtual][nPosConteu]
					ZA7_DECIMA   := oModelGrid:aCols[nAtual][nPosDecima]
					ZA7->(MsUnlock())
				EndIf
			Next nAtual
			ZA7->(MsUnlock())
		EndIf
		//Se for Exclus�o
	ElseIf nOpc == 5
		//Se conseguir posicionar, exclui o registro
		If ZA7->(DbSeek(cFilZA7 + cCodigo))
			For nAtual := 1 To oModelGrid:Length()
				//Posicionando na linha
				oModelGrid:GoLine(nAtual)
				RecLock('ZA7', .F.)
				DbDelete()
				ZA7->(MsUnlock())
			Next
		EndIf
	ElseIf nOpc == 9
		ALERT("OP��O 9")
	EndIf

	//Se n�o for inclus�o, volta o INCLUI para .T. (bug ao utilizar a Exclus�o, antes da Inclus�o)
	If nOpc != 3
		INCLUI := .T.
	EndIf

	RestArea(aArea)
Return lRet
Static Function COMPLPRE( oModelGrid, nLinha, cAcao, cCampo )
	Local lRet := .T.
	Local oModel := oModelGrid:GetModel()
	Local nOperation := oModel:GetOperation()

Return lRet
/*/{Protheus.doc} OMS105C
Fun��o para c�pia dos dados em MVC
@type function
@author Atilio
@since 29/04/2017
@version 1.0
/*/
 
User Function OMS105C()
    Local aArea        := GetArea()
    Local cTitulo      := "C�pia"
    Local cPrograma    := "Zanlorenzi_OMS105"
    Local nOperation   := MODEL_OPERATION_INSERT
    Local nLin         := 0
    Local nCol         := 0
    Local nTamanGrid   := 0
     
    //Caso precise testar em algum lugar
    __lCopia     := .T.
     
    //Carrega o modelo de dados
    oModel := FWLoadModel(cPrograma)
    oModel:SetOperation(nOperation) // Inclus�o
    oModel:Activate(.T.) // Ativa o modelo com os dados posicionados
     
    //Pegando o campo de chave
    cCodigo := GetSXENum("ZA7", "ZA7_CODIGO")
    ConfirmSX8()
     
    //Setando os campos do cabe�alho
    oModel:SetValue("FORMCAB", "ZA7_CODIGO",  cCodigo)
    oModel:SetValue("FORMCAB", "ZA7_DESCRI",   "COP - "+Alltrim(ZA7->ZA7_DESCRI))
     
    //Pegando os dados do filho
    oModelGrid := oModel:GetModel("ZA7DETAIL")
    oStruct    := oModelGrid:GetStruct()
    aCampos    := oStruct:GetFields()
     
    //Se n�o for P12, pega do aCols, sen�o pega do aDataModel
    nTamanGrid := Iif(GetVersao(.F.) < "12", Len(oModelGrid:aCols), Len(oModelGrid:aDataModel))
     
    //Zerando os campos da grid
    For nLin := 1 To nTamanGrid
     
        //Setando a linha atual
        oModelGrid:SetLine(nLin)
         
        //Percorrendo as colunas
       // For nCol := 1 To Len(aCampos)
         
            //Se for a coluna desejada, ir� zerar
         //   If Alltrim(aCampos[nCol][3]) == "ZZ3_DESC"
         //       oModel:SetValue("ZZ3DETAIL", aCampos[nCol][3], "Linha "+cValToChar(nLin))
         //   EndIf
      //  Next nCol
    Next nLin
    oModelGrid:SetLine(1)  
     
    //Executando a visualiza��o dos dados para manipula��o
    nRet     := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
    __lCopia := .F.
    oModel:DeActivate()
     
    RestArea(aArea)
Return oModel
User Function OMS105I
alert("User Function OMS105I")
Return

User Function OMS105A
alert("User Function OMS105A")
Return
