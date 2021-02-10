//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := ""

/*/{Protheus.doc} zModel2
Exemplo de Modelo 2 para cadastro de ZA0
@author Atilio
@since 14/01/2017
@version 1.0
    @return Nil, Função não tem retorno
    @example
    u_zModel2()
    @obs Para o erro na exclusão - FORMCANDEL da CC2, abra a SX9, e onde tiver '12'+CC2_COD, substitua por '12'+CC2_CODMUN
/*/
User Function zModel2()
	Local aArea   := GetArea()
	Local oBrowse
	Local cFunBkp := FunName()

	SetFunName("zModel2")

	//Cria um browse para a ZA0, filtrando somente a tabela 00 (cabeçalho das tabelas
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZA0")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetFilterDefault("ZA0->ZA0_ITEM == '001'")
	oBrowse:Activate()

	SetFunName(cFunBkp)
	RestArea(aArea)
Return Nil
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  14/01/2017                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zModel2' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zModel2' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zModel2' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zModel2' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  14/01/2017                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
Static Function ModelDef()
    Local oModel   := Nil
    Local oStTmp   := FWFormModelStruct():New()
    Local oStFilho := FWFormStruct(1, 'ZA0')
    Local bVldPos  := {|| u_zVldX5Tab()}
    Local bVldCom  := {|| u_zSaveMd2()}
    Local aZA0Rel  := {}
     
    //Adiciona a tabela na estrutura temporária
    oStTmp:AddTable('ZA0', {'ZA0_FILIAL', 'ZA0_CODIGO', 'ZA0_DESCRI','ZA0_OCOR'}, "Cabecalho ZA0")
     
    //Adiciona o campo de Filial
    oStTmp:AddField(;
        "Filial",;                                                                                  // [01]  C   Titulo do campo
        "Filial",;                                                                                  // [02]  C   ToolTip do campo
        "ZA0_FILIAL",;                                                                               // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        TamSX3("ZA0_FILIAL")[1],;                                                                    // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZA0->ZA0_FILIAL,FWxFilial('ZA0'))" ),;   // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual
     
    //Adiciona o campo de Código da Tabela
    oStTmp:AddField(;
        "Código",;                                                                    // [01]  C   Titulo do campo
        "Código",;                                                                    // [02]  C   ToolTip do campo
        "ZA0_CODIGO",;                                                                  // [03]  C   Id do Field
        "C",;                                                                         // [04]  C   Tipo do campo
        TamSX3("ZA0_CODIGO")[1],;                                                      // [05]  N   Tamanho do campo
        0,;                                                                           // [06]  N   Decimal do campo
        Nil,;                                                                         // [07]  B   Code-block de validação do campo
        Nil,;                                                                         // [08]  B   Code-block de validação When do campo
        {},;                                                                          // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZA0->ZA0_CODIGO,GETSXENUM('ZA0','ZA0_CODIGO'))" ),;    // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                          // [14]  L   Indica se o campo é virtual
     
    //Adiciona o campo de Descrição
    oStTmp:AddField(;
        "Descricao",;                                                                 // [01]  C   Titulo do campo
        "Descricao",;                                                                 // [02]  C   ToolTip do campo
        "ZA0_DESCRI",;                                                                 // [03]  C   Id do Field
        "C",;                                                                         // [04]  C   Tipo do campo
        TamSX3("ZA0_DESCRI")[1],;                                                      // [05]  N   Tamanho do campo
        0,;                                                                           // [06]  N   Decimal do campo
        Nil,;                                                                         // [07]  B   Code-block de validação do campo
        Nil,;                                                                         // [08]  B   Code-block de validação When do campo
        {},;                                                                          // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
       Nil,;                                                                           // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                          // [14]  L   Indica se o campo é virtual
         //Adiciona o campo de Ocorrencia
    oStTmp:AddField(;
        "Ocorrência",;                                                                 // [01]  C   Titulo do campo
        "Ocorrência",;                                                                 // [02]  C   ToolTip do campo
        "ZA0_OCOR",;                                                                 // [03]  C   Id do Field
        "C",;                                                                         // [04]  C   Tipo do campo
        TamSX3("ZA0_OCOR")[1],;                                                      // [05]  N   Tamanho do campo
        0,;                                                                           // [06]  N   Decimal do campo
        Nil,;                                                                         // [07]  B   Code-block de validação do campo
        Nil,;                                                                         // [08]  B   Code-block de validação When do campo
        {},;                                                                          // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZA0->OCOR,'')" ),;   // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)  
     
    //Setando as propriedades na grid, o inicializador da Filial e Tabela, para não dar mensagem de coluna vazia
    oStFilho:SetProperty('ZA0_FILIAL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
    oStFilho:SetProperty('ZA0_CODIGO', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
     
    //Criando o FormModel, adicionando o Cabeçalho e Grid
    oModel := MPFormModel():New("zModel2M", , bVldPos, bVldCom) 
    oModel:AddFields("FORMCAB",/*cOwner*/,oStTmp)
    oModel:AddGrid('ZA0DETAIL','FORMCAB',oStFilho)
     
    //Adiciona o relacionamento de Filho, Pai
    aAdd(aZA0Rel, {'ZA0_FILIAL', 'Iif(!INCLUI, ZA0->ZA0_FILIAL, FWxFilial("ZA0"))'} )
    aAdd(aZA0Rel, {'ZA0_CODIGO', 'Iif(!INCLUI, ZA0->ZA0_CODIGO,  "")'} ) 
     
    //Criando o relacionamento
    oModel:SetRelation('ZA0DETAIL', aZA0Rel, ZA0->(IndexKey(1)))
     
    //Setando o campo único da grid para não ter repetição
    oModel:GetModel( 'ZA0DETAIL' ):SetUniqueLine( { "ZA0_CODIGO" , "ZA0_ITEM"} )
     
    //Setando outras informações do Modelo de Dados
    oModel:SetDescription("Cadastro de EDI de Transportadoras "+cTitulo)
    oModel:SetPrimaryKey({})
    oModel:GetModel("FORMCAB"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  14/01/2017                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
    Local oModel     := FWLoadModel("zModel2")
    Local oStTmp     := FWFormViewStruct():New()
    Local oStFilho   := FWFormStruct(2, 'ZA0')
    Local oView      := Nil
     
    //Adicionando o campo Chave para ser exibido
    oStTmp:AddField(;
        "ZA0_CODIGO",;                // [01]  C   Nome do Campo
        "01",;                      // [02]  C   Ordem
        "Código",;                  // [03]  C   Titulo do campo
        X3Descric('ZA0_CODIGO'),;    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("ZA0_CODIGO"),;    // [07]  C   Picture
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
        "ZA0_DESCRI",;               // [01]  C   Nome do Campo
        "02",;                      // [02]  C   Ordem
        "Descricao",;               // [03]  C   Titulo do campo
        X3Descric('ZA0_DESCRI'),;    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("ZA0_DESCRI"),;    // [07]  C   Picture
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
        "ZA0_OCOR",;               // [01]  C   Nome do Campo
        "03",;                      // [02]  C   Ordem
        "Ocorrência",;               // [03]  C   Titulo do campo
        X3Descric('ZA0_OCOR'),;    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("ZA0_OCOR"),;    // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        {'','1=ENVIO','2=RECEBIMENTO'},;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo
     
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_CAB", oStTmp, "FORMCAB")
    oView:AddGrid('VIEW_ZA0',oStFilho,'ZA0DETAIL')
    oView:AddIncrementField( 'VIEW_ZA0', 'ZA0_ITEM' )
     
    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',30)
    oView:CreateHorizontalBox('GRID',70)
     
    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_CAB','CABEC')
    oView:SetOwnerView('VIEW_ZA0','GRID')
     
    //Habilitando título
    oView:EnableTitleView('VIEW_CAB','Cabeçalho - EDI Transportadora')
    oView:EnableTitleView('VIEW_ZA0','Itens - EDI Trasportadora')
     
    //Tratativa padrão para fechar a tela
    oView:SetCloseOnOk({||.T.})
     
    //Remove os campos de Filial e Tabela da Grid
    oStFilho:RemoveField('ZA0_FILIAL')
    oStFilho:RemoveField('ZA0_CODIGO')
Return oView
/*/{Protheus.doc} zVldX5Tab
Função chamada na validação do botão Confirmar, para verificar se já existe a tabela digitada
@type function
@author Atilio
@since 14/01/2017
@version 1.0
    @return lRet, .T. se pode prosseguir e .F. se deve barrar
/*/
User Function zVldX5Tab()

	Local aArea      := GetArea()
	Local lRet       := .T.
	Local oModelDad  := FWModelActive()
	Local cFilZA0    := oModelDad:GetValue('FORMCAB', 'ZA0_FILIAL')
	Local cCodigo    := SubStr(oModelDad:GetValue('FORMCAB', 'ZA0_CODIGO'), 1, TamSX3('ZA0_CODIGO')[01])
	Local nOpc       := oModelDad:GetOperation()
    alert("entrou zVldX5Tab")
	//Se for Inclusão
	If nOpc == MODEL_OPERATION_INSERT
		DbSelectArea('ZA0')
		ZA0->(DbSetOrder(1)) //ZA0_FILIAL + ZA0_CODIGO + ZA0_CODIGO

		//Se conseguir posicionar, tabela já existe
		If ZA0->(DbSeek(cFilZA0 +cCodigo))
			Aviso('Atenção', 'Esse código de EDI já existe!', {'OK'}, 02)
			lRet := .F.
		EndIf
	EndIf

	RestArea(aArea)
Return lRet
/*/{Protheus.doc} zSaveMd2
Função desenvolvida para salvar os dados do Modelo 2
@type function
@author Atilio
@since 14/01/2017
@version 1.0
/*/
User Function zSaveMd2()
	Local aArea      := GetArea()
	Local lRet       := .T.
	Local oModelDad  := FWModelActive()
	Local cFilZA0    := oModelDad:GetValue('FORMCAB', 'ZA0_FILIAL')
	Local cCodigo    := SubStr(oModelDad:GetValue('FORMCAB', 'ZA0_CODIGO'), 1, TamSX3('ZA0_CODIGO')[01])
	Local cDescri    := oModelDad:GetValue('FORMCAB', 'ZA0_DESCRI')
    Local cOcor      := oModelDad:GetValue('FORMCAB', 'ZA0_OCOR')
	Local nOpc       := oModelDad:GetOperation()
	Local oModelGrid := oModelDad:GetModel('ZA0DETAIL')
	Local aHeadAux   := oModelGrid:aHeader
	Local aColsAux   := :aColsoModelGrid
	Local nPosCampo  := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA0_CAMPO")})
	Local nPosIni := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA0_POSINI")})
	Local nPosFim := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA0_POSFIM")})
	Local nPosTpDad := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA0_TPDADO")})
	Local nPosTipo := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA0_TIPO")})
	Local nPosConteu := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA0_CONTEU")})
	Local nPosDecima := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA0_DECIMA")})
	//Local nPosOcor := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA0_OCOR")})
	Local nAtual     := 0
        alert("entrou zSaveMd2")
	DbSelectArea('ZA0')
	ZA0->(DbSetOrder(1)) //ZA0_FILIAL + ZA0_CODIGO + ZA0_CODIGO

	//Se for Inclusão
	If nOpc == 3

		//Percorre as linhas da grid
		For nAtual := 1 To Len(aColsAux)
			//Se a linha não estiver excluída, inclui o registro
			If ! aColsAux[nAtual][Len(aHeadAux)+1]
				RecLock('ZA0', .T.)
				ZA0_FILIAL   := cFilZA0
				ZA0_CODIGO   := cCodigo
				ZA0_DESCRI   := cDescri
				ZA0_OCOR      := cOcor//aColsAux[nAtual][nPosOcor]
				ZA0_CAMPO   := aColsAux[nAtual][nPosCampo]
				ZA0_POSINI  := aColsAux[nAtual][nPosIni]
				ZA0_POSFIM  := aColsAux[nAtual][nPosFim]
				ZA0_TPDADO      := aColsAux[nAtual][nPosTpDad]
				ZA0_TIPO   := aColsAux[nAtual][nPosTipo]
				ZA0_CONTEU  := aColsAux[nAtual][nPosConteu]
				ZA0_DECIMA  := aColsAux[nAtual][nPosDecima]
				ZA0->(MsUnlock())
			EndIf
		Next

		//Se for Alteração
	ElseIf nOpc == 4
		//Se conseguir posicionar, altera a descrição digitada
		If ZA0->(DbSeek(cFilZA0 + '00' + cCodigo))
			RecLock('ZA0', .F.)
			ZA0_DESCRI   := cDescri
			ZA0_POSINI  := cDescri
			ZA0_POSFIM  := cDescri
			ZA0->(MsUnlock())   
		EndIf

		//Percorre o acols
		For nAtual := 1 To Len(aColsAux)
			//Se a linha estiver excluída
			If aColsAux[nAtual][Len(aHeadAux)+1]
				//Se conseguir posicionar, exclui o registro
				If ZA0->(DbSeek(cFilZA0 + cCodigo + aColsAux[nAtual][nPosCampo]))
					RecLock('ZA0', .F.)
					DbDelete()
					ZA0->(MsUnlock())
				EndIf

			Else
				//Se conseguir posicionar no registro, será alteração
				If ZA0->(DbSeek(cFilZA0 + cCodigo + aColsAux[nAtual][nPosCampo]))
					RecLock('ZA0', .F.)

					//Senão, será inclusão
				Else
					RecLock('ZA0', .T.)
					ZA0_FILIAL := cFilZA0
					ZA0_CODIGO := cCodigo
					ZA0_CODIGO    := aColsAux[nAtual][nPosCampo]
				EndIf

				ZA0_DESCRI   := aColsAux[nAtual][nPosIni]
				ZA0_POSINI  := aColsAux[nAtual][nPosFim]
				ZA0_POSFIM  := aColsAux[nAtual][nPosTpDad]
				ZA0->(MsUnlock())
			EndIf
		Next

		//Se for Exclusão
	ElseIf nOpc == 5
		//Se conseguir posicionar, exclui o registro
		If ZA0->(DbSeek(cFilZA0 + '00' + cCodigo))
			RecLock('ZA0', .F.)
			DbDelete()
			ZA0->(MsUnlock())
		EndIf

		//Percorre a grid
		For nAtual := 1 To Len(aColsAux)
			//Se conseguir posicionar, exclui o registro
			If ZA0->(DbSeek(cFilZA0 + cCodigo + aColsAux[nAtual][nPosCampo]))
				RecLock('ZA0', .F.)
				DbDelete()
				ZA0->(MsUnlock())
			EndIf
		Next
	EndIf

	//Se não for inclusão, volta o INCLUI para .T. (bug ao utilizar a Exclusão, antes da Inclusão)
	If nOpc != 3
		INCLUI := .T.
	EndIf

	RestArea(aArea)
Return lRet
