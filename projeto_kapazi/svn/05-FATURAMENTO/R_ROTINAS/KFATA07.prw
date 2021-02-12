#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'
 
Static cTitle := "Grupo de Produtos em MVC"
Static cKey    := "FAKE"
Static nTamFake := 15
 
/*/{Protheus.doc} User Function KFATA07
Visualizacao de Grupos de Produtos em MVC (com tabela temporaria)
@type  Function
@author Marcos Xavier
@since  14/06/2020
@version version
/*/
 
User Function KFATA07()
    Local aArea := GetArea()

    Local cUsrLog   := __cUserID
    Local cUsrAut   := GetNewPar('KA_USREDI','000540;000060;000554;000478')

    Private cAcao       := ''
    Private cAliasTmp   := "TMPEDI"
    Private oTempTable  := Nil
 
    if ! cUsrLog $ cUsrAut
        Alert("Usuário sem permissão para acessar esta rotina")
        Return
    endif


    //Cria a temporária
    oTempTable := FWTemporaryTable():New(cAliasTmp)
     
    //Adiciona no array das colunas as que serão incluidas (Nome do Campo, Tipo do Campo, Tamanho, Decimais)
    aFields := {}
    aAdd(aFields, {"ZFFILIAL",  "C", TamSX3('ZF_FILIAL')[01],   0})
    aAdd(aFields, {"ZFPEDIDO",  "C", TamSX3('ZF_PEDIDO')[01],   0})
    aAdd(aFields, {"ZFDATA",    "D", TamSX3('ZF_DATA')[01],     0})
    aAdd(aFields, {"ZFHORA",    "C", TamSX3('ZF_HORA')[01],     0})
    aAdd(aFields, {"ZFDOCTO",   "C", TamSX3('ZF_DOC')[01],      0})
    aAdd(aFields, {"ZFSERIE",   "C", TamSX3('ZF_SERIE')[01],    0})
    aAdd(aFields, {"ZFOCOR",    "C", TamSX3('ZF_TROCORR')[01],  0})
    aAdd(aFields, {"ZFDESC2",   "C", TamSX3('ZF_TROCODE')[01],  0})
    aAdd(aFields, {"ZFDESCRI",  "C", TamSX3('ZF_TROBS')[01],    0})
     
    //Define as colunas usadas, adiciona indice e cria a temporaria no banco
    oTempTable:SetFields( aFields )
    oTempTable:AddIndex("1", {"ZFFILIAL"} )
    oTempTable:Create()
 
    //Executa a inclusao na tela
    FWExecView('Manutenção EDI', "VIEWDEF.KFATA07", MODEL_OPERATION_INSERT, , { || .T. }, { || SetAcao('OK') }, 30,,{ ||  .T. })


    if cAcao == 'OK'
        //Agora percorre todos os dados digitados
        (cAliasTmp)->(DbGoTop())
        DbSelectArea('SZF')
        While ! (cAliasTmp)->(EoF())
            
            Reclock('SZF',.T.)
                SZF->ZF_FILIAL  := (cAliasTmp)->ZFFILIAL
                SZF->ZF_PEDIDO  := (cAliasTmp)->ZFPEDIDO
                SZF->ZF_USUANOM := 'TOTVS'
                SZF->ZF_DATA    := (cAliasTmp)->ZFDATA 
                SZF->ZF_HORA    := (cAliasTmp)->ZFHORA 
                SZF->ZF_CODIGO  := '20'
                SZF->ZF_STATUS  := 'OCORRENCIA TRANSPORTE'
                SZF->ZF_DOC     := (cAliasTmp)->ZFDOCTO 
                SZF->ZF_SERIE   := (cAliasTmp)->ZFSERIE 
                SZF->ZF_OBS     := 'Inserido manualmente'
                SZF->ZF_TROCORR := (cAliasTmp)->ZFOCOR 
                SZF->ZF_TROCODE := (cAliasTmp)->ZFDESC2 
                SZF->ZF_TROBS   := (cAliasTmp)->ZFDESCRI 
            SZF->(MsUnlock())
            
            // ZFFILIAL",  "C", TamSX3('ZF_FILIAL')[01],   0})
            // ZFPEDIDO",  "C", TamSX3('ZF_PEDIDO')[01],   0})
            // ZFDATA",    "D", TamSX3('ZF_DATA')[01],     0})
            // ZFHORA",    "C", TamSX3('ZF_HORA')[01],     0})
            // ZFDOCTO",   "C", TamSX3('ZF_DOC')[01],      0})
            // ZFSERIE",   "C", TamSX3('ZF_SERIE')[01],    0})
            // ZFOCOR",    "C", TamSX3('ZF_TROCORR')[01],  0})
            // ZFDESC2",   "C", TamSX3('ZF_TROCODE')[01],  0})
            // ZFDESCRI",  "C", TamSX3('ZF_TROBS')[01],    0})


            // MsgInfo("Código: " + (cAliasTmp)->ZFFILIAL + ", Descrição: " + (cAliasTmp)->ZFPEDIDO, "Atenção")
            (cAliasTmp)->(DbSkip())
        EndDo
    EndIf
 
    //Deleta a temporaria
    oTempTable:Delete()
     
    RestArea(aArea)
Return
 
Static Function ModelDef()
    Local oModel  As Object
    Local oStrField As Object
    Local oStrGrid As Object
 
    //Criamos aqui uma estrutura falsa que sera uma tabela que ficara escondida no cabecalho
    oStrField := FWFormModelStruct():New()
    oStrField:AddTable('' , { 'XXTABKEY' } , cTitle, {|| ''})
    oStrField:AddField('String 01' , 'Campo de texto' , 'XXTABKEY' , 'C' , nTamFake)
 
    //Criamos aqui a estrutura da grid
    oStrGrid := FWFormModelStruct():New() 
    oStrGrid:AddTable(cAliasTmp, {'XXTABKEY', 'ZFFILIAL', 'ZFPEDIDO'}, "Temporaria")
      
    //Adiciona os campos da estrutura
    oStrGrid:AddField(;
        "Filial",;                                                                                  // [01]  C   Titulo do campo
        "Filial",;                                                                                  // [02]  C   ToolTip do campo
        "ZFFILIAL",;                                                                                // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        02,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->ZFFILIAL" ),;                           // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual
    
    oStrGrid:AddField(;
        "Pedido",;                                                                               // [01]  C   Titulo do campo
        "Pedido",;                                                                               // [02]  C   ToolTip do campo
        "ZFPEDIDO",;                                                                                // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        06,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->ZFPEDIDO" ),;                           // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual


        oStrGrid:AddField(;
        "Data",;                                                                                    // [01]  C   Titulo do campo
        "Data",;                                                                                    // [02]  C   ToolTip do campo
        "ZFDATA",;                                                                                  // [03]  C   Id do Field
        "D",;                                                                                       // [04]  C   Tipo do campo
        08,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validaÃ§Ã£o do campo
        Nil,;                                                                                       // [08]  B   Code-block de validaÃ§Ã£o When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatÃ³rio
        {|| ''},;                                                                                   // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operaÃ§Ã£o de update.
        .F.)                                                                                        // [14]  L   Indica se o campo Ã© virtual
    
    oStrGrid:AddField(;
        "Hora",;                                                                                    // [01]  C   Titulo do campo
        "Hora",;                                                                                    // [02]  C   ToolTip do campo
        "ZFHORA",;                                                                                  // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        08,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validaÃ§Ã£o do campo
        Nil,;                                                                                       // [08]  B   Code-block de validaÃ§Ã£o When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatÃ³rio
        {|| ''},;                                                                                   // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operaÃ§Ã£o de update.
        .F.)                                                                                        // [14]  L   Indica se o campo Ã© virtual
    
    oStrGrid:AddField(;
        "Nota Fiscal",;                                                                             // [01]  C   Titulo do campo
        "Nota Fiscal",;                                                                             // [02]  C   ToolTip do campo
        "ZFDOCTO",;                                                                                 // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        09,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validaÃ§Ã£o do campo
        Nil,;                                                                                       // [08]  B   Code-block de validaÃ§Ã£o When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatÃ³rio
        {|| ''},;                                                                                   // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operaÃ§Ã£o de update.
        .F.)                                                                                        // [14]  L   Indica se o campo Ã© virtual
  
    oStrGrid:AddField(;
        "Serie",;                                                                                   // [01]  C   Titulo do campo
        "Serie",;                                                                                   // [02]  C   ToolTip do campo
        "ZFSERIE",;                                                                                 // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        03,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validaÃ§Ã£o do campo
        Nil,;                                                                                       // [08]  B   Code-block de validaÃ§Ã£o When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatÃ³rio
        {|| ''},;                                                                                   // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operaÃ§Ã£o de update.
        .F.)                                                                                        // [14]  L   Indica se o campo Ã© virtual
    
    oStrGrid:AddField(;
        "Cod. Ocorr.",;                                                                             // [01]  C   Titulo do campo
        "Cod. Ocorr.",;                                                                             // [02]  C   ToolTip do campo
        "ZFOCOR",;                                                                                  // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        02,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validaÃ§Ã£o do campo
        Nil,;                                                                                       // [08]  B   Code-block de validaÃ§Ã£o When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatÃ³rio
        {|| ''},;                                                                                   // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operaÃ§Ã£o de update.
        .F.)                                                                                        // [14]  L   Indica se o campo Ã© virtual
    
    oStrGrid:AddField(;
        "Desc. Ocorr.",;                                                                                  // [01]  C   Titulo do campo
        "Desc. Ocorr.",;                                                                                  // [02]  C   ToolTip do campo
        "ZFDESC2",;                                                                                // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        70,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validaÃ§Ã£o do campo
        Nil,;                                                                                       // [08]  B   Code-block de validaÃ§Ã£o When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatÃ³rio
        {|| ''},;                                                                                   // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operaÃ§Ã£o de update.
        .F.)                                                                                        // [14]  L   Indica se o campo Ã© virtual
    
    oStrGrid:AddField(;
        "Observacao",;                                                                                  // [01]  C   Titulo do campo
        "Observacao",;                                                                                  // [02]  C   ToolTip do campo
        "ZFDESCRI",;                                                                                // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        250,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validaÃ§Ã£o do campo
        Nil,;                                                                                       // [08]  B   Code-block de validaÃ§Ã£o When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatÃ³rio
        {|| ''},;                                                                                   // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operaÃ§Ã£o de update.
        .F.)                                                                                        // [14]  L   Indica se o campo Ã© virtual
 
    //Agora criamos o modelo de dados da nossa tela
    oModel := MPFormModel():New('KFATA07M')
    oModel:AddFields('CABID', , oStrField)
    oModel:AddGrid('GRIDID', 'CABID', oStrGrid)
    oModel:SetRelation('GRIDID', { { 'XXTABKEY', 'XXTABKEY' } })
    oModel:SetDescription(cTitle)
    oModel:SetPrimaryKey({ 'XXTABKEY' })
    oModel:SetPrimaryKey({ 'XXTABKEY',"ZFFILIAL","ZFPEDIDO","ZFDATA","ZFHORA","ZFDOCTO","ZFSERIE","ZFOCOR"})

 
    //Ao ativar o modelo, irá alterar o campo do cabeçalho mandando o conteúdo FAKE pois é necessário alteração no cabeçalho
    oModel:SetActivate({ | oModel | FwFldPut("XXTABKEY", cKey) })
Return oModel
 
Static Function ViewDef()
    Local oView    As Object
    Local oModel   As Object
    Local oStrCab  As Object
    Local oStrGrid As Object
 
    //Criamos agora a estrtutura falsa do cabeçalho na visualização dos dados
    oStrCab := FWFormViewStruct():New()
    oStrCab:AddField('XXTABKEY' , '01' , 'String 01' , 'Campo de texto', , 'C')
 
    //Agora a estrutura da Grid
    oStrGrid := FWFormViewStruct():New()
  
    //Adicionando campos da estrutura
    oStrGrid:AddField(;
        "ZFFILIAL",;                // [01]  C   Nome do Campo
        "01",;                      // [02]  C   Ordem
        "Filial",;                  // [03]  C   Titulo do campo
        "Filial",;                  // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
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
    
    oStrGrid:AddField(;
        "ZFPEDIDO",;                // [01]  C   Nome do Campo
        "02",;                      // [02]  C   Ordem
        "Pedido",;               // [03]  C   Titulo do campo
        "Pedido",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
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

    oStrGrid:AddField(;
        "ZFDATA",;                // [01]  C   Nome do Campo
        "03",;                      // [02]  C   Ordem
        "Data Ocorr.",;               // [03]  C   Titulo do campo
        "Data Ocorr.",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "D",;                       // [06]  C   Tipo do campo
        "",;                      // [07]  C   Picture
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

    oStrGrid:AddField(;
        "ZFHORA",;                // [01]  C   Nome do Campo
        "04",;                      // [02]  C   Ordem
        "Hora Ocorr.",;               // [03]  C   Titulo do campo
        "Hora Ocorr.",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "",;                      // [07]  C   Picture
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
    
    oStrGrid:AddField(;
        "ZFDOCTO",;                // [01]  C   Nome do Campo
        "05",;                      // [02]  C   Ordem
        "Nota Fiscal",;               // [03]  C   Titulo do campo
        "Nota Fiscal",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "",;                      // [07]  C   Picture
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
    
    oStrGrid:AddField(;
        "ZFSERIE",;                // [01]  C   Nome do Campo
        "06",;                      // [02]  C   Ordem
        "Serie NF",;               // [03]  C   Titulo do campo
        "Serie NF",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "",;                      // [07]  C   Picture
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
    
    oStrGrid:AddField(;
        "ZFOCOR",;                // [01]  C   Nome do Campo
        "07",;                      // [02]  C   Ordem
        "Cod. Ocorr.",;               // [03]  C   Titulo do campo
        "Cod. Ocorr.",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        'Z07',;                       // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo
    
    oStrGrid:AddField(;
        "ZFDESC2",;                // [01]  C   Nome do Campo
        "08",;                      // [02]  C   Ordem
        "Desc. Ocorr.",;               // [03]  C   Titulo do campo
        "Desc. Ocorr.",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo
    
    oStrGrid:AddField(;
        "ZFDESCRI",;                // [01]  C   Nome do Campo
        "09",;                      // [02]  C   Ordem
        "Observacao",;               // [03]  C   Titulo do campo
        "Observacao",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "",;                      // [07]  C   Picture
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
 
    //Carrega o ModelDef
    oModel  := FWLoadModel('KFATA07')
 
    //Agora na visualização, carrega o modelo, define o cabeçalho e a grid, e no cabeçalho coloca 0% de visualização, e na grid coloca 100%
    oView := FwFormView():New()
    oView:SetModel(oModel)
    oView:AddField('CAB', oStrCab, 'CABID')
    oView:AddGrid('GRID', oStrGrid, 'GRIDID')
    oView:CreateHorizontalBox('TOHID', 0)
    oView:CreateHorizontalBox('TOSHOW', 100)
    oView:SetOwnerView('CAB' , 'TOHID')
    oView:SetOwnerView('GRID', 'TOSHOW')
    oView:SetDescription(cTitle)
Return oView


/*/{Protheus.doc} SetAcao
    (long_description)
    @type  Static Function
    @author 
    @since 04/02/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function SetAcao(cDescAcao)

    Local lRet  := .T.

    cAcao := cDescAcao


    // //Agora percorre todos os dados digitados
    // (cAliasTmp)->(DbGoTop())
    // DbSelectArea('SZF')
    // While ! (cAliasTmp)->(EoF())
        
    //     Reclock('SZF',.T.)
    //         SZF->ZF_FILIAL  := (cAliasTmp)->ZFFILIAL
    //         SZF->ZF_PEDIDO  := (cAliasTmp)->ZFPEDIDO
    //         SZF->ZF_USUANOM := 'TOTVS'
    //         SZF->ZF_DATA    := (cAliasTmp)->ZFDATA 
    //         SZF->ZF_HORA    := (cAliasTmp)->ZFHORA 
    //         SZF->ZF_CODIGO  := '20'
    //         SZF->ZF_STATUS  := 'OCORRENCIA TRANSPORTE'
    //         SZF->ZF_DOC     := (cAliasTmp)->ZFDOCTO 
    //         SZF->ZF_SERIE   := (cAliasTmp)->ZFSERIE 
    //         SZF->ZF_OBS     := 'Inserido manualmente'
    //         SZF->ZF_TROCORR := (cAliasTmp)->ZFOCOR 
    //         SZF->ZF_TROCODE := (cAliasTmp)->ZFDESC2 
    //         SZF->ZF_TROBS   := (cAliasTmp)->ZFDESCRI 
    //     SZF->(MsUnlock())
        
    //     // ZFFILIAL",  "C", TamSX3('ZF_FILIAL')[01],   0})
    //     // ZFPEDIDO",  "C", TamSX3('ZF_PEDIDO')[01],   0})
    //     // ZFDATA",    "D", TamSX3('ZF_DATA')[01],     0})
    //     // ZFHORA",    "C", TamSX3('ZF_HORA')[01],     0})
    //     // ZFDOCTO",   "C", TamSX3('ZF_DOC')[01],      0})
    //     // ZFSERIE",   "C", TamSX3('ZF_SERIE')[01],    0})
    //     // ZFOCOR",    "C", TamSX3('ZF_TROCORR')[01],  0})
    //     // ZFDESC2",   "C", TamSX3('ZF_TROCODE')[01],  0})
    //     // ZFDESCRI",  "C", TamSX3('ZF_TROBS')[01],    0})


    //     // MsgInfo("Código: " + (cAliasTmp)->ZFFILIAL + ", Descrição: " + (cAliasTmp)->ZFPEDIDO, "Atenção")
    //     (cAliasTmp)->(DbSkip())
    // EndDo
 
    
Return lRet
