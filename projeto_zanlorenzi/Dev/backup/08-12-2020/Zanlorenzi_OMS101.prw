//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Vari�veis Est�ticas
Static cTitulo := ""

/*/{Protheus.doc} OMS101
Modelo 2 EM mvc para cadastro de EDI de transportadoras na tabela ZA0
@author Jair Andrade
@since 07/12/2020
@version 1.0
    @return Nil, Fun��o n�o tem retorno
    @example
/*/
User Function OMS101()

	Local oBrowse
	Private aRotina := MenuDef()
	Private __lCopia := .F.

	//Cria um browse para a ZA0, filtrando somente a tabela 00 (cabe�alho das tabelas
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZA0")
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetFilterDefault("ZA0->ZA0_ITEM == '001'")
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
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.Zanlorenzi_OMS101' OPERATION 2 ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.Zanlorenzi_OMS101' OPERATION 3 ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.Zanlorenzi_OMS101' OPERATION 4 ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.Zanlorenzi_OMS101' OPERATION 5 ACCESS 0 //OPERATION 5
    ADD OPTION aRot Title 'Copiar'     ACTION 'u_OMS101C' OPERATION 9 ACCESS 0 //OPERATION 9

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
    Local oStFilho := FWFormStruct(1, 'ZA0')
    Local bVldPos  := {|| u_OMS101V()}
    Local bVldCom  := {|| u_OMS101S()}
    Local aZA0Rel  := {}
     
    //Adiciona a tabela na estrutura tempor�ria
    oStTmp:AddTable('ZA0', {'ZA0_FILIAL', 'ZA0_CODIGO', 'ZA0_DESCRI','ZA0_OCOR'}, "Cabecalho ZA0")
     
    //Adiciona o campo de Filial
    oStTmp:AddField(;
        "Filial",;                                                                                  // [01]  C   Titulo do campo
        "Filial",;                                                                                  // [02]  C   ToolTip do campo
        "ZA0_FILIAL",;                                                                               // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        TamSX3("ZA0_FILIAL")[1],;                                                                    // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de valida��o do campo
        Nil,;                                                                                       // [08]  B   Code-block de valida��o When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigat�rio
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZA0->ZA0_FILIAL,FWxFilial('ZA0'))" ),;   // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma opera��o de update.
        .F.)                                                                                        // [14]  L   Indica se o campo � virtual
     
    //Adiciona o campo de C�digo da Tabela
    oStTmp:AddField(;
        "C�digo",;                                                                    // [01]  C   Titulo do campo
        "C�digo",;                                                                    // [02]  C   ToolTip do campo
        "ZA0_CODIGO",;                                                                  // [03]  C   Id do Field
        "C",;                                                                         // [04]  C   Tipo do campo
        TamSX3("ZA0_CODIGO")[1],;                                                      // [05]  N   Tamanho do campo
        0,;                                                                           // [06]  N   Decimal do campo
        Nil,;                                                                         // [07]  B   Code-block de valida��o do campo
        Nil,;                                                                         // [08]  B   Code-block de valida��o When do campo
        {},;                                                                          // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigat�rio
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZA0->ZA0_CODIGO,GETSXENUM('ZA0','ZA0_CODIGO'))" ),;    // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma opera��o de update.
        .F.)                                                                          // [14]  L   Indica se o campo � virtual
     
    //Adiciona o campo de Descri��o
    oStTmp:AddField(;
        "Descricao",;                                                                 // [01]  C   Titulo do campo
        "Descricao",;                                                                 // [02]  C   ToolTip do campo
        "ZA0_DESCRI",;                                                                 // [03]  C   Id do Field
        "C",;                                                                         // [04]  C   Tipo do campo
        TamSX3("ZA0_DESCRI")[1],;                                                      // [05]  N   Tamanho do campo
        0,;                                                                           // [06]  N   Decimal do campo
        Nil,;                                                                         // [07]  B   Code-block de valida��o do campo
        Nil,;                                                                         // [08]  B   Code-block de valida��o When do campo
        {},;                                                                          // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigat�rio
       Nil,;                                                                           // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma opera��o de update.
        .F.)                                                                          // [14]  L   Indica se o campo � virtual
         //Adiciona o campo de Ocorrencia
    oStTmp:AddField(;
        "Tipo Layout",;                                                                 // [01]  C   Titulo do campo
        "Tipo Layout",;                                                                 // [02]  C   ToolTip do campo
        "ZA0_OCOR",;                                                                 // [03]  C   Id do Field
        "C",;                                                                         // [04]  C   Tipo do campo
        TamSX3("ZA0_OCOR")[1],;                                                      // [05]  N   Tamanho do campo
        0,;                                                                           // [06]  N   Decimal do campo
        Nil,;                                                                         // [07]  B   Code-block de valida��o do campo
        Nil,;                                                                         // [08]  B   Code-block de valida��o When do campo
        {},;                                                                          // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigat�rio
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZA0->OCOR,'')" ),;   // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma opera��o de update.
        .F.)  
     
    //Setando as propriedades na grid, o inicializador da Filial e Tabela, para n�o dar mensagem de coluna vazia
    oStFilho:SetProperty('ZA0_FILIAL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
    oStFilho:SetProperty('ZA0_CODIGO', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
     
    //Criando o FormModel, adicionando o Cabe�alho e Grid
    oModel := MPFormModel():New("Zanlorenzi_OMS101", , bVldPos, bVldCom) 
    oModel:AddFields("FORMCAB",/*cOwner*/,oStTmp)
    oModel:AddGrid('ZA0DETAIL','FORMCAB',oStFilho,{ |oModelGrid, nLine, cAction, cField| COMPLPRE(oModelGrid, nLine, cAction, cField) })
     
    //Adiciona o relacionamento de Filho, Pai
    aAdd(aZA0Rel, {'ZA0_FILIAL', 'Iif(!INCLUI, ZA0->ZA0_FILIAL, FWxFilial("ZA0"))'} )
    aAdd(aZA0Rel, {'ZA0_CODIGO', 'Iif(!INCLUI, ZA0->ZA0_CODIGO,  "")'} ) 
     
    //Criando o relacionamento
    oModel:SetRelation('ZA0DETAIL', aZA0Rel, ZA0->(IndexKey(1)))
     
    //Setando o campo �nico da grid para n�o ter repeti��o
    oModel:GetModel( 'ZA0DETAIL' ):SetUniqueLine( { "ZA0_CODIGO" , "ZA0_ITEM"} )

     //Definindo que usar� a grid no formato antigo
    oModel:GetModel('ZA0DETAIL'):SetUseOldGrid(.T.)
     
    //Setando outras informa��es do Modelo de Dados
    oModel:SetDescription("Cadastro de EDI de Transportadoras "+cTitulo)
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
    Local oModel     := FWLoadModel("Zanlorenzi_OMS101")
    Local oStTmp     := FWFormViewStruct():New()
    Local oStFilho   := FWFormStruct(2, 'ZA0')
    Local oView      := Nil
     
    //Adicionando o campo Chave para ser exibido
    oStTmp:AddField(;
        "ZA0_CODIGO",;                // [01]  C   Nome do Campo
        "01",;                      // [02]  C   Ordem
        "C�digo",;                  // [03]  C   Titulo do campo
        X3Descric('ZA0_CODIGO'),;    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("ZA0_CODIGO"),;    // [07]  C   Picture
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
        "ZA0_DESCRI",;               // [01]  C   Nome do Campo
        "02",;                      // [02]  C   Ordem
        "Descricao",;               // [03]  C   Titulo do campo
        X3Descric('ZA0_DESCRI'),;    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("ZA0_DESCRI"),;    // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo � alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior op��o do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo � virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha ap�s o campo
        oStTmp:AddField(;
        "ZA0_OCOR",;               // [01]  C   Nome do Campo
        "03",;                      // [02]  C   Ordem
        "Tipo Layout",;               // [03]  C   Titulo do campo
        X3Descric('ZA0_OCOR'),;    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        X3Picture("ZA0_OCOR"),;    // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo � alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        {'','1=ENVIO','2=RECEBIMENTO'},;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior op��o do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo � virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha ap�s o campo
     
    //Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
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
     
    //Habilitando t�tulo
    oView:EnableTitleView('VIEW_CAB','Cabe�alho EDI')
    oView:EnableTitleView('VIEW_ZA0','Itens EDI')
     
    //Tratativa padr�o para fechar a tela
    oView:SetCloseOnOk({||.T.})
     
    //Remove os campos de Filial e Tabela da Grid
    oStFilho:RemoveField('ZA0_FILIAL')
    oStFilho:RemoveField('ZA0_CODIGO')
Return oView

/*/{Protheus.doc} OMS101V
Fun��o chamada na valida��o do bot�o Confirmar, para verificar se j� existe a tabela digitada
@type function
@author Jair Andrade
@since 07/12/2020
@version 1.0
    @return lRet, .T. se pode prosseguir e .F. se deve barrar
/*/
User Function OMS101V()

	Local aArea      := GetArea()
	Local lRet       := .T.
	Local oModelDad  := FWModelActive()
	Local cFilZA0    := oModelDad:GetValue('FORMCAB', 'ZA0_FILIAL')
	Local cCodigo    := SubStr(oModelDad:GetValue('FORMCAB', 'ZA0_CODIGO'), 1, TamSX3('ZA0_CODIGO')[01])
	Local nOpc       := oModelDad:GetOperation()

	//Se for Inclus�o
	If nOpc == 3
		DbSelectArea('ZA0')
		ZA0->(DbSetOrder(1)) //ZA0_FILIAL + ZA0_CODIGO + ZA0_CODIGO

		//Se conseguir posicionar, tabela j� existe
		If ZA0->(DbSeek(cFilZA0 +cCodigo))
		
			Aviso('Aten��o', 'Esse c�digo de EDI j� existe!', {'OK'}, 02)
			lRet := .F.
		EndIf
	ElseIf nOpc ==9
		ALERT("OP��O 9")
	EndIf

RestArea(aArea)
Return lRet
/*/{Protheus.doc} OMS101S
Fun��o desenvolvida para salvar os dados do Modelo 2
@type function
@author Jair Andrade
@since 07/12/2020
@version 1.0
/*/
User Function OMS101S()
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
	Local aColsAux   := oModelGrid:aCols
	Local nPosCampo  := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA0_CAMPO")})
	Local nPosIt  := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA0_ITEM")})
	Local nPosIni := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA0_POSINI")})
	Local nPosFim := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA0_POSFIM")})
	Local nPosTpDad := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA0_TPDADO")})
	Local nPosTipo := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA0_TIPO")})
	Local nPosConteu := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA0_CONTEU")})
	Local nPosDecima := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA0_DECIMA")})
	//Local nPosOcor := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZA0_OCOR")})
	Local nAtual     := 0

	DbSelectArea('ZA0')
	ZA0->(DbSetOrder(2)) //ZA0_FILIAL + ZA0_CODIGO + ZA0_ITEM

	//Se for Inclus�o
	If nOpc == 3

		//Percorre as linhas da grid
		For nAtual := 1 To oModelGrid:Length()
			//Posicionando na linha
			oModelGrid:GoLine(nAtual)
			//Se a linha n�o estiver exclu�da, inclui o registro
			If(!oModelGrid:IsDeleted())
				RecLock('ZA0', .T.)
				ZA0_FILIAL   := cFilZA0
				ZA0_CODIGO   := cCodigo
				ZA0_DESCRI   := cDescri
				ZA0_OCOR     := cOcor//aColsAux[nAtual][nPosOcor]
				ZA0_ITEM    := oModelGrid:aCols[nAtual][nPosIt]
				ZA0_CAMPO    := oModelGrid:aCols[nAtual][nPosCampo]
				ZA0_POSINI   := oModelGrid:aCols[nAtual][nPosIni]
				ZA0_POSFIM   := oModelGrid:aCols[nAtual][nPosFim]
				ZA0_TPDADO   := oModelGrid:aCols[nAtual][nPosTpDad]
				ZA0_TIPO     := oModelGrid:aCols[nAtual][nPosTipo]
				ZA0_CONTEU   := oModelGrid:aCols[nAtual][nPosConteu]
				ZA0_DECIMA   := oModelGrid:aCols[nAtual][nPosDecima]
				ZA0->(MsUnlock())
			EndIf
		Next nAtual

		//Se for Altera��o
	ElseIf nOpc == 4
		//Se conseguir posicionar, altera a descri��o digitada
		If ZA0->(DbSeek(cFilZA0 + cCodigo))
			//Percorre as linhas da grid
			For nAtual := 1 To oModelGrid:Length()
				//Posicionando na linha
				oModelGrid:GoLine(nAtual)
				//Se a linha n�o estiver exclu�da, inclui o registro
				If(!oModelGrid:IsDeleted())
					//Se conseguir posicionar no registro, ser� altera��o
					If ZA0->(DbSeek(cFilZA0 + cCodigo + oModelGrid:aCols[nAtual][nPosIt]))
						RecLock('ZA0', .F.)

						//Sen�o, ser� inclus�o
					Else
						RecLock('ZA0', .T.)
						ZA0_FILIAL := cFilZA0
						ZA0_CODIGO := cCodigo
					EndIf
					ZA0_DESCRI   := cDescri
					ZA0_OCOR     := cOcor//aColsAux[nAtual][nPosOcor]
					ZA0_ITEM    := oModelGrid:aCols[nAtual][nPosIt]
					ZA0_CAMPO    := oModelGrid:aCols[nAtual][nPosCampo]
					ZA0_POSINI   := oModelGrid:aCols[nAtual][nPosIni]
					ZA0_POSFIM   := oModelGrid:aCols[nAtual][nPosFim]
					ZA0_TPDADO   := oModelGrid:aCols[nAtual][nPosTpDad]
					ZA0_TIPO     := oModelGrid:aCols[nAtual][nPosTipo]
					ZA0_CONTEU   := oModelGrid:aCols[nAtual][nPosConteu]
					ZA0_DECIMA   := oModelGrid:aCols[nAtual][nPosDecima]
					ZA0->(MsUnlock())
				EndIf
			Next nAtual
			ZA0->(MsUnlock())
		EndIf
		//Se for Exclus�o
	ElseIf nOpc == 5
		//Se conseguir posicionar, exclui o registro
		If ZA0->(DbSeek(cFilZA0 + cCodigo))
			For nAtual := 1 To oModelGrid:Length()
				//Posicionando na linha
				oModelGrid:GoLine(nAtual)
				RecLock('ZA0', .F.)
				DbDelete()
				ZA0->(MsUnlock())
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
/*/{Protheus.doc} OMS101C
Fun��o para c�pia dos dados em MVC
@type function
@author Atilio
@since 29/04/2017
@version 1.0
/*/
 
User Function OMS101C()
    Local aArea        := GetArea()
    Local cTitulo      := "C�pia"
    Local cPrograma    := "Zanlorenzi_OMS101"
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
    cCodigo := GetSXENum("ZA0", "ZA0_CODIGO")
    ConfirmSX8()
     
    //Setando os campos do cabe�alho
    oModel:SetValue("FORMCAB", "ZA0_CODIGO",  cCodigo)
    oModel:SetValue("FORMCAB", "ZA0_DESCRI",   "COP - "+Alltrim(ZA0->ZA0_DESCRI))
     
    //Pegando os dados do filho
    oModelGrid := oModel:GetModel("ZA0DETAIL")
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
