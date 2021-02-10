//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := ""

/*/{Protheus.doc} OMS102
Modelo 2 EM mvc para cadastro de REGIOES x transportadoras na tabela ZA5
@author Jair Andrade
@since 09/12/2020
@version 1.0
    @return Nil, Função não tem retorno
    @example
/*/
User Function OMS102()

	Local oBrowse
	Private aRotina := MenuDef()
	Private __lCopia := .F.

	//Cria um browse para a ZA5, filtrando somente a tabela 00 (cabeçalho das tabelas
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZA5")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetFilterDefault("ZA5->ZA5_ITEM == '001'")
	oBrowse:Activate()

Return Nil
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor:  Jair Andrade                                                |
 | Data:  09/12/2020                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.Zanlorenzi_OMS102' OPERATION 2 ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.Zanlorenzi_OMS102' OPERATION 3 ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.Zanlorenzi_OMS102' OPERATION 4 ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.Zanlorenzi_OMS102' OPERATION 5 ACCESS 0 //OPERATION 5
    ADD OPTION aRot Title 'Copiar'     ACTION 'U_OMS102C' OPERATION 9 ACCESS 0 //OPERATION 9

Return aRot
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor:  Jair Andrade                                                |
 | Data:  09/12/2020                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
Static Function ModelDef()
    Local oModel   := Nil
    Local oStTmp   := FWFormModelStruct():New()
    Local oStFilho := FWFormStruct(1, 'ZA5')
    Local bVldPos  := {|| u_OMS102V()}
    Local bVldCom  := {|| u_OMS102S()}
    Local aZA5Rel  := {}
     
    //Adiciona a tabela na estrutura temporária
    oStTmp:AddTable('ZA5', {'ZA5_FILIAL', 'ZA5_CODIGO','ZA5_DESCRI','ZA5_REGIAO'}, "Cabecalho ZA5")
     
    //Adiciona o campo de Filial
    oStTmp:AddField(;
        "Filial",;                                                                                  // [01]  C   Titulo do campo
        "Filial",;                                                                                  // [02]  C   ToolTip do campo
        "ZA5_FILIAL",;                                                                               // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        TamSX3("ZA5_FILIAL")[1],;                                                                    // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZA5->ZA5_FILIAL,FWxFilial('ZA5'))" ),;   // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual
     
    //Adiciona o campo de Código da Tabela
    oStTmp:AddField(;
        "Código",;                                                                    // [01]  C   Titulo do campo
        "Código",;                                                                    // [02]  C   ToolTip do campo
        "ZA5_CODIGO",;                                                                  // [03]  C   Id do Field
        "C",;                                                                         // [04]  C   Tipo do campo
        TamSX3("ZA5_CODIGO")[1],;                                                      // [05]  N   Tamanho do campo
        0,;                                                                           // [06]  N   Decimal do campo
        Nil,;                                                                         // [07]  B   Code-block de validação do campo
        Nil,;                                                                         // [08]  B   Code-block de validação When do campo
        {},;                                                                          // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZA5->ZA5_CODIGO,GETSXENUM('ZA5','ZA5_CODIGO'))" ),;    // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                          // [14]  L   Indica se o campo é virtual
//Adiciona o campo de Descrição
    oStTmp:AddField(;
        "Descrição",;                                                                 // [01]  C   Titulo do campo
        "Descrição",;                                                                 // [02]  C   ToolTip do campo
        "ZA5_DESCRI",;                                                                 // [03]  C   Id do Field
        "C",;                                                                         // [04]  C   Tipo do campo
        TamSX3("ZA5_DESCRI")[1],;                                                      // [05]  N   Tamanho do campo
        0,;                                                                           // [06]  N   Decimal do campo
        Nil,;                                                                         // [07]  B   Code-block de validação do campo
        Nil,;                                                                         // [08]  B   Code-block de validação When do campo
        {},;                                                                          // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
       Nil,;                                                                           // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)    
        //Adiciona o campo de Região
    oStTmp:AddField(;
        "Região",;                                                                 // [01]  C   Titulo do campo
        "Região",;                                                                 // [02]  C   ToolTip do campo
        "ZA5_REGIAO",;                                                                 // [03]  C   Id do Field
        "C",;                                                                         // [04]  C   Tipo do campo
        TamSX3("ZA5_REGIAO")[1],;                                                      // [05]  N   Tamanho do campo
        0,;                                                                           // [06]  N   Decimal do campo
        Nil,;                                                                         // [07]  B   Code-block de validação do campo
        Nil,;                                                                         // [08]  B   Code-block de validação When do campo
        {},;                                                                          // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
       FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZA5_REGIAO,'')" ),;                                                                         // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                          // [14]  L   Indica se o campo é virtual
                     
    //Setando as propriedades na grid, o inicializador da Filial e Tabela, para não dar mensagem de coluna vazia
    oStFilho:SetProperty('ZA5_FILIAL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
    oStFilho:SetProperty('ZA5_CODIGO', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
    
    //----------------------------------------------------------GATILHO--------------------------------------------------------------
    oStFilho:AddTrigger	("ZA5_REGEST",	"ZA5_ESTADO",  {|| .T.},{||ValZA5(oModel,"ZA5_REGEST") } )    // gatilho Regiao do estado X estado
   // oStFilho:SetProperty( 'ZA5_ESTADO',     MODEL_FIELD_WHEN,  {|| .F.} ) 
    
    //Criando o FormModel, adicionando o Cabeçalho e Grid
    oModel := MPFormModel():New("Zanlorenzi_OMS102", , bVldPos, bVldCom) 
    oModel:AddFields("FORMCAB",/*cOwner*/,oStTmp)
    oModel:AddGrid('ZA5DETAIL','FORMCAB',oStFilho,{ |oModelGrid, nLine, cAction, cField| COMPLPRE(oModelGrid, nLine, cAction, cField) })
     
    //Adiciona o relacionamento de Filho, Pai
    aAdd(aZA5Rel, {'ZA5_FILIAL', 'Iif(!INCLUI, ZA5->ZA5_FILIAL, FWxFilial("ZA5"))'} )
    aAdd(aZA5Rel, {'ZA5_CODIGO', 'Iif(!INCLUI, ZA5->ZA5_CODIGO,  "")'} ) 
     
    //Criando o relacionamento
    oModel:SetRelation('ZA5DETAIL', aZA5Rel, ZA5->(IndexKey(1)))
     
    //Setando o campo único da grid para não ter repetição
    oModel:GetModel( 'ZA5DETAIL' ):SetUniqueLine( { "ZA5_CODIGO" , "ZA5_ITEM"} )

     //Definindo que usará a grid no formato antigo
    oModel:GetModel('ZA5DETAIL'):SetUseOldGrid(.T.)
     
    //Setando outras informações do Modelo de Dados
    oModel:SetDescription("Cadastro de Transportadora X Região "+cTitulo)
    oModel:SetPrimaryKey({})
    oModel:GetModel("FORMCAB"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor:  Jair Andrade                                                |
 | Data:  09/12/2020                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
    Local oModel     := FWLoadModel("Zanlorenzi_OMS102")
    Local oStTmp     := FWFormViewStruct():New()
    Local oStFilho   := FWFormStruct(2, 'ZA5')
    Local oView      := Nil
     
    //Adicionando o campo Chave para ser exibido
    oStTmp:AddField(;
        "ZA5_CODIGO",;                // [01]  C   Nome do Campo
        "01",;                      // [02]  C   Ordem
        "Código",;                  // [03]  C   Titulo do campo
        X3Descric('ZA5_CODIGO'),;    // [04]  C   Região do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("ZA5_CODIGO"),;    // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;     // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo
     
    
    oStTmp:AddField(;
        "ZA5_DESCRI",;               // [01]  C   Nome do Campo
        "02",;                      // [02]  C   Ordem
        "Descricao",;               // [03]  C   Titulo do campo
        X3Descric('ZA5_DESCRI'),;    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("ZA5_DESCRI"),;    // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo 

        oStTmp:AddField(;
        "ZA5_REGIAO",;               // [01]  C   Nome do Campo
        "03",;                      // [02]  C   Ordem
        "Região",;               // [03]  C   Titulo do campo
        X3Descric('ZA5_REGIAO'),;    // [04]  C   Região do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("ZA5_REGIAO"),;    // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        {'','1=TODOS','2=NORTE','3=SUL','4=LESTE','5=OESTE'},; // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_CAB", oStTmp, "FORMCAB")
    oView:AddGrid('VIEW_ZA5',oStFilho,'ZA5DETAIL')
    oView:AddIncrementField( 'VIEW_ZA5', 'ZA5_ITEM' )
     
    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',30)
    oView:CreateHorizontalBox('GRID',70)
     
    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_CAB','CABEC')
    oView:SetOwnerView('VIEW_ZA5','GRID')
     
    //Habilitando título
    oView:EnableTitleView('VIEW_CAB','Cabeçalho ZA5')
    oView:EnableTitleView('VIEW_ZA5','Itens ZA5')
     
    //Tratativa padrão para fechar a tela
    oView:SetCloseOnOk({||.T.})
     
    //Remove os campos de Filial e Tabela da Grid
    oStFilho:RemoveField('ZA5_FILIAL')
    oStFilho:RemoveField('ZA5_CODIGO')
Return oView

/*/{Protheus.doc} OMS102V
Função chamada na validação do botão Confirmar, para verificar se já existe a tabela digitada
@type function
@author Jair Andrade
@since 07/12/2020
@version 1.0
    @return lRet, .T. se pode prosseguir e .F. se deve barrar
/*/
User Function OMS102V()

	Local aArea      := GetArea()
	Local lRet       := .T.
	Local oModelDad  := FWModelActive()
	Local cFilZA5    := oModelDad:GetValue('FORMCAB', 'ZA5_FILIAL')
	Local cCodigo    := SubStr(oModelDad:GetValue('FORMCAB', 'ZA5_CODIGO'), 1, TamSX3('ZA5_CODIGO')[01])
	Local nOpc       := oModelDad:GetOperation()

	//Se for Inclusão
	If nOpc == 3
		DbSelectArea('ZA5')
		ZA5->(DbSetOrder(1)) //ZA5_FILIAL + ZA5_CODIGO + ZA5_ITEM

		//Se conseguir posicionar, tabela já existe
		If ZA5->(DbSeek(cFilZA5 +cCodigo))

			Aviso('Atenção', 'Esse código de Região já existe!', {'OK'}, 02)
			lRet := .F.
		EndIf
	ElseIf nOpc ==9
		ALERT("OPÇÃO 9")
	EndIf

	RestArea(aArea)
Return lRet
/*/{Protheus.doc} OMS102S
Função desenvolvida para salvar os dados do Modelo 2
@type function
@author Jair Andrade
@since 09/12/2020
@version 1.0
/*/
User Function OMS102S()
	Local aArea      := GetArea()
	Local lRet       := .T.
	Local oModelDad  := FWModelActive()
	Local cFilZA5    := oModelDad:GetValue('FORMCAB', 'ZA5_FILIAL')
	Local cCodigo    := SubStr(oModelDad:GetValue('FORMCAB', 'ZA5_CODIGO'), 1, TamSX3('ZA5_CODIGO')[01])
	Local cDescri    := oModelDad:GetValue('FORMCAB', 'ZA5_DESCRI')
	Local cRegiao    := oModelDad:GetValue('FORMCAB', 'ZA5_REGIAO')
	Local nOpc       := oModelDad:GetOperation()
	Local oModelGrid := oModelDad:GetModel('ZA5DETAIL')
	Local aHeadAux   := oModelGrid:aHeader
	Local aColsAux   := oModelGrid:aCols
	Local nPosIt     := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA5_ITEM")})
	Local nPosRegestr:= aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA5_REGEST")})
	Local nPosEstado := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA5_ESTADO")})
	Local nPosTransp := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA5_TRANSP")})
	Local nPosTipo := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA5_TIPO")})
	Local nAtual     := 0

	DbSelectArea('ZA5')
	ZA5->(DbSetOrder(1)) //ZA5_FILIAL + ZA5_CODIGO + ZA5_ITEM

	//Se for Inclusão
	If nOpc == 3

		//Percorre as linhas da grid
		For nAtual := 1 To oModelGrid:Length()
			//Posicionando na linha
			oModelGrid:GoLine(nAtual)
			//Se a linha não estiver excluída, inclui o registro
			If(!oModelGrid:IsDeleted())
				RecLock('ZA5', .T.)
				ZA5_FILIAL   := cFilZA5
				ZA5_CODIGO   := cCodigo
				ZA5_DESCRI   := cDescri
				ZA5_REGIAO     := cRegiao
				ZA5_ITEM    := oModelGrid:aCols[nAtual][nPosIt]
				ZA5_REGEST    := oModelGrid:aCols[nAtual][nPosRegestr]
				ZA5_ESTADO   := oModelGrid:aCols[nAtual][nPosEstado]
				ZA5_TRANSP     := oModelGrid:aCols[nAtual][nPosTransp]
				ZA5_TIPO   := oModelGrid:aCols[nAtual][nPosTipo]
				ZA5->(MsUnlock())
			EndIf
		Next nAtual

		//Se for Alteração
	ElseIf nOpc == 4
		//Se conseguir posicionar, altera a descrição digitada
		If ZA5->(DbSeek(cFilZA5 + cCodigo))
			//Percorre as linhas da grid
			For nAtual := 1 To oModelGrid:Length()
				//Posicionando na linha
				oModelGrid:GoLine(nAtual)
				//Se a linha não estiver excluída, inclui o registro
				If(!oModelGrid:IsDeleted())
					//Se conseguir posicionar no registro, será alteração
					If ZA5->(DbSeek(cFilZA5 + cCodigo + oModelGrid:aCols[nAtual][nPosIt]))
						RecLock('ZA5', .F.)

						//Senão, será inclusão
					Else
						RecLock('ZA5', .T.)
						ZA5_FILIAL := cFilZA5
						ZA5_CODIGO := cCodigo
					EndIf
					ZA5_DESCRI   := cDescri
					ZA5_REGIAO     := cRegiao
					ZA5_ITEM    := oModelGrid:aCols[nAtual][nPosIt]
					ZA5_REGEST    := oModelGrid:aCols[nAtual][nPosRegestr]
					ZA5_ESTADO   := oModelGrid:aCols[nAtual][nPosEstado]
					ZA5_TRANSP     := oModelGrid:aCols[nAtual][nPosTransp]
					ZA5_TIPO   := oModelGrid:aCols[nAtual][nPosTipo]
					ZA5->(MsUnlock())
				EndIf
			Next nAtual
			ZA5->(MsUnlock())
		EndIf
		//Se for Exclusão
	ElseIf nOpc == 5
		//Se conseguir posicionar, exclui o registro
		If ZA5->(DbSeek(cFilZA5 + cCodigo))
			For nAtual := 1 To oModelGrid:Length()
				//Posicionando na linha
				oModelGrid:GoLine(nAtual)
				RecLock('ZA5', .F.)
				DbDelete()
				ZA5->(MsUnlock())
			Next
		EndIf
	ElseIf nOpc == 9
		ALERT("OPÇÃO 9")
	EndIf

	//Se não for inclusão, volta o INCLUI para .T. (bug ao utilizar a Exclusão, antes da Inclusão)
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
/*/{Protheus.doc} OMS102C
Função para cópia dos dados em MVC
@type function
@author Atilio
@since 29/04/2017
@version 1.0
/*/

User Function OMS102C()
	Local aArea        := GetArea()
	Local cTitulo      := "Cópia"
	Local cPrograma    := "Zanlorenzi_OMS102"
	Local nOperation   := MODEL_OPERATION_INSERT
	Local nLin         := 0
	Local nCol         := 0
	Local nTamanGrid   := 0

	//Caso precise testar em algum lugar
	__lCopia     := .T.

	//Carrega o modelo de dados
	oModel := FWLoadModel(cPrograma)
	oModel:SetOperation(nOperation) // Inclusão
	oModel:Activate(.T.) // Ativa o modelo com os dados posicionados

	//Pegando o campo de chave
	cCodigo := GetSXENum("ZA5", "ZA5_CODIGO")
	ConfirmSX8()

	//Setando os campos do cabeçalho
	oModel:SetValue("FORMCAB", "ZA5_CODIGO",  cCodigo)
	oModel:SetValue("FORMCAB", "ZA5_DESCRI",   "COP - "+Alltrim(ZA5->ZA5_DESCRI))

	//Pegando os dados do filho
	oModelGrid := oModel:GetModel("ZA5DETAIL")
	oStruct    := oModelGrid:GetStruct()
	aCampos    := oStruct:GetFields()

	//Se não for P12, pega do aCols, senão pega do aDataModel
	nTamanGrid := Iif(GetVersao(.F.) < "12", Len(oModelGrid:aCols), Len(oModelGrid:aDataModel))

	//Zerando os campos da grid
	For nLin := 1 To nTamanGrid

		//Setando a linha atual
		oModelGrid:SetLine(nLin)
	Next nLin
	oModelGrid:SetLine(1)

	//Executando a visualização dos dados para manipulação
	nRet     := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
	__lCopia := .F.
	oModel:DeActivate()

	RestArea(aArea)
Return oModel

/*/{Protheus.doc} ValZ0C(oModel,cCampo)
	Retorna valor de campo passado como parametro de acordo com a Filial logada .Funcao para carregar TRIGGER

	@author Jair Matos
	@since 21/02/2019
	@version P12
	@type function
	@return cCampoRet
	/*/
Static Function ValZA5(oModel,cCampo)
	Local cRetorno 	:= Space(TamSX3(cCampo)[1])

	If oModel:GetValue('ZA5DETAIL','ZA5_REGEST') =='1'
		cRetorno :="ZZ"
	EndIf

Return cRetorno
