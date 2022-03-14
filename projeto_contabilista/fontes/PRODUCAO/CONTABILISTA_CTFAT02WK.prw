#include 'totvs.ch'
#Include 'FWMVCDef.ch'
#Include "FWPrintSetup.ch"

/*/{Protheus.doc} User Function CTFAT02WK
    Função para impressão Romaneio Contabilista
    @type  Function
    @author Willian Kaneta
    @since 29/08/2020
    @version 1.0
    /*/
User Function CTFAT02WK()
    Local aArea       := GetArea()
    Local oBrowse
    Local cFunBkp     := FunName()
    Local aFields     := {}
    Local aBrowse     := {}
    Local aIndex      := {}
        
    Private cPerg     := "CTFAT02WK"
    Private cTitulo   := "Romaneio"
    Private oTempTrb  := nil
    Private cAliasTmp := GetNextAlias()
    Private cAliasRom := GetNextAlias()

    Private cAliasNFCIC:= GetNextAlias()
    Private cAliasNFJV := GetNextAlias()

    Private cNFJVLIni := "" 
    Private cNFJVLFim := ""
    Private cSerJVL   := ""
    Private cSerCIC   := ""
    Private cNFCICIni := ""
    Private cNFCICFim := ""
    Private cFilCD	  := SUPERGETMV("CT_ESTCENT",.F.,"010101")
      
    If CriaSX1()

        //-------------------
        //Criação do objeto
        //-------------------
        oTempTrb := FWTemporaryTable():New( cAliasTmp )
        
        //Definindo as colunas que serão usadas no browse
        aAdd(aFields, {"TMP_ROMAN", "C", 08, 0, "@!"})
        aAdd(aFields, {"TMP_PEDJV", "C", 06, 0, "@!"})
        aAdd(aFields, {"TMP_DTEMJ", "D", 08, 0, "@D"})
        aAdd(aFields, {"TMP_DOCJV", "C", 09, 0, "@!"})
        aAdd(aFields, {"TMP_SERJV", "C", 03, 0, "@!"})
        aAdd(aFields, {"TMP_PEDCI", "C", 06, 0, "@!"})
        aAdd(aFields, {"TMP_DTEMC", "D", 08, 0, "@D"})
        aAdd(aFields, {"TMP_DOCCI", "C", 09, 0, "@!"})
        aAdd(aFields, {"TMP_SERCI", "C", 03, 0, "@!"})    
        aAdd(aFields, {"TMP_CLIEN", "C", 06, 0, "@!"})
        aAdd(aFields, {"TMP_LOJA" , "C", 03, 0, "@!"})
        aAdd(aFields, {"TMP_RZSOC", "C", 80, 0, "@!"})       
        aAdd(aFields, {"TMP_VALOR", "N", 10, 2, "@E 9,999,999.99"})

        oTempTrb:SetFields( aFields )
        oTempTrb:AddIndex("01", {"TMP_PEDJV"} )
        oTempTrb:AddIndex("02", {"TMP_DTEMJ"} )
        oTempTrb:AddIndex("03", {"TMP_DOCJV"} )
        oTempTrb:AddIndex("04", {"TMP_PEDCI"} )
        oTempTrb:AddIndex("05", {"TMP_ROMAN"} )
        
        //RET DOC JV
        BeginSql Alias cAliasNFJV
            SELECT  SD2JVL.D2_DOC       AS DOCJVL,
                    SD2JVL.D2_SERIE     AS SERIEJV                   

            FROM %TABLE:SC5% SC5JVL

            INNER JOIN %TABLE:SUA% SUA
                ON SUA.UA_NUMSC5 = SC5JVL.C5_NUM
                AND SUA.UA_XESTOQU = '2'
                AND SUA.D_E_L_E_T_ = ''        

            INNER JOIN %TABLE:SC5% SC5CIC
                ON SC5CIC.C5_XNUMSUA = SUA.UA_NUM
                AND SC5CIC.D_E_L_E_T_ = ''
            
            INNER JOIN %TABLE:SD2% SD2JVL
                ON SD2JVL.D2_PEDIDO = SC5JVL.C5_NUM
                AND SD2JVL.D2_FILIAL = '010104'
                AND SD2JVL.D2_ITEM = '01'
                AND SD2JVL.D_E_L_E_T_ = ''

            INNER JOIN %TABLE:SD2% SD2CIC
                ON SD2CIC.D2_PEDIDO = SC5CIC.C5_NUM
                AND SD2CIC.D2_FILIAL = %EXP:cFilCD%
                AND SD2CIC.D2_ITEM = '01'
                AND SD2CIC.D_E_L_E_T_ = ''

            INNER JOIN %TABLE:GW1% GW1
                ON GW1.GW1_FILIAL = %EXP:cFilCD%
                AND GW1.GW1_NRROM BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%
                AND GW1.GW1_DTEMIS BETWEEN %EXP:DTOS(MV_PAR03)% AND %EXP:DTOS(MV_PAR04)%
                AND GW1.GW1_NRDC   = SD2CIC.D2_DOC
                AND GW1.GW1_SERDC  = SD2CIC.D2_SERIE
                AND GW1.D_E_L_E_T_ = ''

            INNER JOIN %TABLE:SA1% SA1
                ON SA1.A1_FILIAL = %EXP:xFilial("SA1")%
                AND SA1.A1_COD = SC5JVL.C5_CLIENTE
                AND SA1.A1_LOJA = SC5JVL.C5_LOJACLI
                AND SA1.D_E_L_E_T_ = ''

            WHERE SC5JVL.C5_FILIAL  = '010104'
                AND SC5JVL.D_E_L_E_T_ != '*'
            
            ORDER BY    SD2JVL.D2_DOC,
                        SD2JVL.D2_SERIE
        EndSql

        //MemoWrite("C:\Temp\cAliasNFJV.txt",getlastquery()[2])

        (cAliasNFJV)->(DbGoTop())
        cNFJVLIni := (cAliasNFJV)->DOCJVL
        cSerJVL   := (cAliasNFJV)->SERIEJV

        While (cAliasNFJV)->(!EOF())
            cNFJVLFim := (cAliasNFJV)->DOCJVL
            (cAliasNFJV)->(dbSkip())
        EndDo

        //RET DOC CIC
        BeginSql Alias cAliasNFCIC 
            SELECT  SD2CIC.D2_DOC       AS DOCCIC,
                    SD2CIC.D2_SERIE     AS SERIECI                 

            FROM %TABLE:SC5% SC5JVL

            INNER JOIN %TABLE:SUA% SUA
                ON SUA.UA_NUMSC5 = SC5JVL.C5_NUM
                AND SUA.UA_XESTOQU = '2'
                AND SUA.D_E_L_E_T_ = ''        

            INNER JOIN %TABLE:SC5% SC5CIC
                ON SC5CIC.C5_XNUMSUA = SUA.UA_NUM
                AND SC5CIC.D_E_L_E_T_ = ''
            
            INNER JOIN %TABLE:SD2% SD2JVL
                ON SD2JVL.D2_PEDIDO = SC5JVL.C5_NUM
                AND SD2JVL.D2_FILIAL = '010104'
                AND SD2JVL.D2_ITEM = '01'
                AND SD2JVL.D_E_L_E_T_ = ''

            INNER JOIN %TABLE:SD2% SD2CIC
                ON SD2CIC.D2_PEDIDO = SC5CIC.C5_NUM
                AND SD2CIC.D2_FILIAL = %EXP:cFilCD%
                AND SD2CIC.D2_ITEM = '01'
                AND SD2CIC.D_E_L_E_T_ = ''

            INNER JOIN %TABLE:GW1% GW1
                ON GW1.GW1_FILIAL = %EXP:cFilCD%
                AND GW1.GW1_NRROM BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%
                AND GW1.GW1_DTEMIS BETWEEN %EXP:DTOS(MV_PAR03)% AND %EXP:DTOS(MV_PAR04)%
                AND GW1.GW1_NRDC   = SD2CIC.D2_DOC
                AND GW1.GW1_SERDC  = SD2CIC.D2_SERIE
                AND GW1.D_E_L_E_T_ = ''

            INNER JOIN %TABLE:SA1% SA1
                ON SA1.A1_FILIAL = %EXP:xFilial("SA1")%
                AND SA1.A1_COD = SC5JVL.C5_CLIENTE
                AND SA1.A1_LOJA = SC5JVL.C5_LOJACLI
                AND SA1.D_E_L_E_T_ = ''

            WHERE SC5JVL.C5_FILIAL  = '010104'
                AND SC5JVL.D_E_L_E_T_ != '*'
            
            ORDER BY    SD2CIC.D2_DOC,
                        SD2CIC.D2_SERIE
        EndSql

        (cAliasNFCIC)->(DbGoTop())
        cSerCIC   := (cAliasNFCIC)->SERIECI
        cNFCICIni := (cAliasNFCIC)->DOCCIC
        
        While (cAliasNFCIC)->(!EOF())
            cNFCICFim := (cAliasNFCIC)->DOCCIC        
            (cAliasNFCIC)->(dbSkip())
        EndDo

        //MemoWrite("C:\Temp\cAliasNFCIC.txt",getlastquery()[2])
        //------------------
        //Criação da tabela
        //------------------
        oTempTrb:Create()    
        
        BeginSql Alias cAliasRom
            SELECT  SC5JVL.C5_NUM       AS PEDJVL,
                    SC5CIC.C5_NUM       AS PEDCIC,
                    SC5JVL.C5_EMISSAO   AS DTEMJVL,
                    SC5CIC.C5_EMISSAO   AS DTEMCIC,
                    SC5JVL.C5_CLIENTE   AS CLIENT,
                    SC5JVL.C5_LOJACLI   AS LOJACLI,
                    SD2JVL.D2_DOC       AS DOCJVL,
                    SD2JVL.D2_SERIE     AS SERIEJV,
                    SD2CIC.D2_DOC       AS DOCCIC,
                    SD2CIC.D2_SERIE     AS SERIECI,
                    SUA.UA_VALMERC      AS VALOR,
                    SA1.A1_NOME         AS NOMECLI,
                    GW1.GW1_NRROM	    AS ROMANEIO

            FROM %TABLE:SC5% SC5JVL

            INNER JOIN %TABLE:SUA% SUA
                ON SUA.UA_NUMSC5 = SC5JVL.C5_NUM
                AND SUA.UA_XESTOQU = '2'
                AND SUA.D_E_L_E_T_ = ''        

            INNER JOIN %TABLE:SC5% SC5CIC
                ON SC5CIC.C5_XNUMSUA = SUA.UA_NUM
                AND SC5CIC.D_E_L_E_T_ = ''
            
            INNER JOIN %TABLE:SD2% SD2JVL
                ON SD2JVL.D2_PEDIDO = SC5JVL.C5_NUM
                AND SD2JVL.D2_FILIAL = '010104'
                AND SD2JVL.D2_ITEM = '01'
                AND SD2JVL.D_E_L_E_T_ = ''

            INNER JOIN %TABLE:SD2% SD2CIC
                ON SD2CIC.D2_PEDIDO = SC5CIC.C5_NUM
                AND SD2CIC.D2_FILIAL = %EXP:cFilCD%
                AND SD2CIC.D2_ITEM = '01'
                AND SD2CIC.D_E_L_E_T_ = ''

            INNER JOIN %TABLE:GW1% GW1
                ON GW1.GW1_FILIAL = %EXP:cFilCD%
                AND GW1.GW1_NRROM BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%
                AND GW1.GW1_DTEMIS BETWEEN %EXP:DTOS(MV_PAR03)% AND %EXP:DTOS(MV_PAR04)%
                AND GW1.GW1_NRDC   = SD2CIC.D2_DOC
                AND GW1.GW1_SERDC  = SD2CIC.D2_SERIE
                AND GW1.D_E_L_E_T_ = ''

            INNER JOIN %TABLE:SA1% SA1
                ON SA1.A1_FILIAL = %EXP:xFilial("SA1")%
                AND SA1.A1_COD = SC5JVL.C5_CLIENTE
                AND SA1.A1_LOJA = SC5JVL.C5_LOJACLI
                AND SA1.D_E_L_E_T_ = ''

            WHERE SC5JVL.C5_FILIAL  = '010104'
                AND SC5JVL.D_E_L_E_T_ != '*'
            
            ORDER BY SC5JVL.C5_NUM
        EndSql

        //MemoWrite("C:\Temp\CONTABILISTA_GAP61_1.txt",getlastquery()[2])
        
        While (cAliasRom)->(!Eof())
                RecLock(cAliasTmp,.T.)
                (cAliasTmp)->TMP_ROMAN   := (cAliasRom)->ROMANEIO
                (cAliasTmp)->TMP_PEDJV   := (cAliasRom)->PEDJVL
                (cAliasTmp)->TMP_DTEMJ   := STOD((cAliasRom)->DTEMJVL)
                (cAliasTmp)->TMP_DOCJV   := (cAliasRom)->DOCJVL
                (cAliasTmp)->TMP_SERJV   := (cAliasRom)->SERIEJV
                (cAliasTmp)->TMP_PEDCI   := (cAliasRom)->PEDCIC
                (cAliasTmp)->TMP_DTEMC   := STOD((cAliasRom)->DTEMCIC)
                (cAliasTmp)->TMP_DOCCI   := (cAliasRom)->DOCCIC
                (cAliasTmp)->TMP_SERCI   := (cAliasRom)->SERIECI
                (cAliasTmp)->TMP_CLIEN   := (cAliasRom)->CLIENT
                (cAliasTmp)->TMP_LOJA    := (cAliasRom)->LOJACLI
                (cAliasTmp)->TMP_RZSOC   := (cAliasRom)->NOMECLI
                (cAliasTmp)->TMP_VALOR   := (cAliasRom)->VALOR
                (cAliasTmp)->(MsUnlock())
            (cAliasRom)->(DbSkip())
        EndDo

        (cAliasTmp)->(DbGoTop())

        //Definindo as colunas que serão usadas no browse
        aAdd(aBrowse, {"Romaneio"   ,"TMP_ROMAN", "C", 08, 0, "@!"})
        aAdd(aBrowse, {"Ped. JV"    ,"TMP_PEDJV", "C", 06, 0, "@!"})
        aAdd(aBrowse, {"Dt Em. JV"  ,"TMP_DTEMJ", "D", 08, 0, "@D"})
        aAdd(aBrowse, {"NF JV"      ,"TMP_DOCJV", "C", 09, 0, "@!"})
        aAdd(aBrowse, {"Serie"      ,"TMP_SERJV", "C", 03, 0, "@!"})
        aAdd(aBrowse, {"Ped. CD"   ,"TMP_PEDCI", "C", 06, 0, "@!"})
        aAdd(aBrowse, {"Dt Em. CD" ,"TMP_DTEMC", "D", 08, 0, "@D"})
        aAdd(aBrowse, {"NF CD"     ,"TMP_DOCCI", "C", 09, 0, "@!"})
        aAdd(aBrowse, {"Serie"      ,"TMP_SERCI", "C", 03, 0, "@!"})    
        aAdd(aBrowse, {"Cod. Cli."  ,"TMP_CLIEN", "C", 06, 0, "@!"})
        aAdd(aBrowse, {"Loja"       ,"TMP_LOJA" , "C", 03, 0, "@!"})
        aAdd(aBrowse, {"Razao"      ,"TMP_RZSOC", "C", 80, 0, "@!"})       
        aAdd(aBrowse, {"Valor"      ,"TMP_VALOR", "N", 10, 2, "@E 9,999,999.99"})

        //Criando o browse da temporária
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias(cAliasTmp)
        oBrowse:SetQueryIndex(aIndex)
        oBrowse:SetTemporary(.T.)
        oBrowse:SetMenuDef("CTFAT02WK")
        oBrowse:SetFields(aBrowse)
        oBrowse:DisableDetails()
        oBrowse:SetDescription(cTitulo)
        oBrowse:AddButton("Imprimir Romaneio"  , { || FWMsgRun(, {|| GERROMAN() }, 'Processando', 'Aguarde, Imprimindo Danfes das NFes...' ),oBrowse:GetOwner():End()   },,,, .F., 2 )
        oBrowse:AddButton("Cancelar"		   , { || oBrowse:GetOwner():End()          		 },,,, .F., 2 )

        oBrowse:Activate()
        
        SetFunName(cFunBkp)
        RestArea(aArea)

    EndIf
Return Nil
 
/*/{Protheus.doc} MenuDef
	Declaração MenuDef para não exibir botão padrão somente botões addbutton
	@type  Function
	@author Willian Kaneta
	@since 15/04/2020
	@version 1.0
/*/
Static Function MenuDef()
	
	Private aRotina := {}

Return (aRotina)
 
 /*/{Protheus.doc} ModelDef
	Criação do modelo de dados MVC
	@type  Function
	@author Willian Kaneta
	@since 15/04/2020
	@version 1.0
/*/
Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
     
    //Criação da estrutura de dados utilizada na interface
    Local oStTMP := FWFormModelStruct():New()
    
    oStTMP:AddTable(cAliasTmp, {'TMP_ROMAN','TMP_PEDJV','TMP_DTEMJ','TMP_DOCJV','TMP_SERJV','TMP_PEDCI','TMP_DTEMC','TMP_DOCCI','TMP_SERCI','TMP_CLIEN','TMP_LOJA','TMP_RZSOC','TMP_VALOR'}, "Temporaria")
  
    //Adiciona os campos da estrutura
    oStTmp:AddField(;
        "Romaneio",;                                                                                   // [01]  C   Titulo do campo
        "Romaneio",;                                                                                   // [02]  C   ToolTip do campo
        "TMP_ROMAN",;                                                                               // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        08,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->TMP_ROMAN,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)    
    oStTmp:AddField(;
        "Pedido Joinville",;                                                                        // [01]  C   Titulo do campo
        "Pedido Joinville",;                                                                        // [02]  C   ToolTip do campo
        "TMP_PEDJV",;                                                                               // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        06,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->TMP_PEDJV,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual
    oStTmp:AddField(;
        "Dt. Ped. JV",;                                                                             // [01]  C   Titulo do campo
        "Dt. Ped. JV",;                                                                             // [02]  C   ToolTip do campo
        "TMP_DTEMJ",;                                                                               // [03]  C   Id do Field
        "D",;                                                                                       // [04]  C   Tipo do campo
        08,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->TMP_DTEMJ,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "NF Joinville",;                                                                            // [01]  C   Titulo do campo
        "NF Joinville",;                                                                            // [02]  C   ToolTip do campo
        "TMP_DOCJV",;                                                                               // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        09,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->TMP_DOCJV,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;                
        "Serie Jv",;                                                                                // [01]  C   Titulo do campo
        "Serie Jv",;                                                                                // [02]  C   ToolTip do campo
        "TMP_SERJV",;                                                                               // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        03,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->TMP_SERJV,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Pedido CD",;                                                                              // [01]  C   Titulo do campo
        "Pedido CD",;                                                                              // [02]  C   ToolTip do campo
        "TMP_PEDCI",;                                                                               // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        06,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->TMP_PEDCI,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual
    oStTmp:AddField(;
        "Dt. Ped. JV",;                                                                             // [01]  C   Titulo do campo
        "Dt. Ped. JV",;                                                                             // [02]  C   ToolTip do campo
        "TMP_DTEMC",;                                                                               // [03]  C   Id do Field
        "D",;                                                                                       // [04]  C   Tipo do campo
        08,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->TMP_DTEMC,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "NF CD",;                                                                                  // [01]  C   Titulo do campo
        "NF CD",;                                                                                  // [02]  C   ToolTip do campo
        "TMP_DOCCI",;                                                                               // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        09,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->TMP_DOCCI,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;                
        "Serie CD",;                                                                               // [01]  C   Titulo do campo
        "Serie CD",;                                                                               // [02]  C   ToolTip do campo
        "TMP_SERCI",;                                                                               // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        03,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->TMP_SERCI,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual        

    oStTmp:AddField(;
        "Cod. Cliente",;                                                                            // [01]  C   Titulo do campo
        "Cod. Cliente",;                                                                            // [02]  C   ToolTip do campo
        "TMP_CLIEN",;                                                                               // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        06,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->TMP_CLIEN,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual
    oStTmp:AddField(;
        "NF CD",;                                                                                  // [01]  C   Titulo do campo
        "NF CD",;                                                                                  // [02]  C   ToolTip do campo
        "TMP_LOJA",;                                                                               // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        03,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->TMP_LOJA,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;                
        "Razão Soc.",;                                                                              // [01]  C   Titulo do campo
        "Razão Soc.",;                                                                              // [02]  C   ToolTip do campo
        "TMP_RZSOC",;                                                                               // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        80,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->TMP_RZSOC,'')" ),;       // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStTmp:AddField(;
        "Valor",;                                                                                   // [01]  C   Titulo do campo
        "Valor",;                                                                                   // [02]  C   ToolTip do campo
        "TMP_VALOR",;                                                                                 // [03]  C   Id do Field
        "N",;                                                                                       // [04]  C   Tipo do campo
        10,;                                                                                        // [05]  N   Tamanho do campo
        02,;                                                                                        // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,"+cAliasTmp+"->TMP_VALOR,0)" ),;       // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual
     
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("CTFAT02WKM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMTMP",/*cOwner*/,oStTMP)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({})
     
    //Adicionando descrição ao modelo
    oModel:SetDescription(cTitulo)
     
    //Setando a descrição do formulário
    oModel:GetModel("FORMTMP"):SetDescription(cTitulo)
Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
    Local oModel := FWLoadModel("CTFAT02WK")
    Local oStTMP := FWFormViewStruct():New()
    Local oView := Nil

    //Adicionando campos da estrutura
    oStTmp:AddField(;
        "TMP_ROMAN",;               // [01]  C   Nome do Campo
        "01",;                      // [02]  C   Ordem
        "Romaneio",;                   // [03]  C   Titulo do campo
        "Romaneio",;                   // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo
    oStTmp:AddField(;
        "TMP_PEDJV",;               // [01]  C   Nome do Campo
        "01",;                      // [02]  C   Ordem
        "Ped. JV",;                 // [03]  C   Titulo do campo
        "Ped. JV",;                 // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo
    oStTmp:AddField(;
        "TMP_DTEMJ",;               // [01]  C   Nome do Campo
        "02",;                      // [02]  C   Ordem
        "DT Emi.JV",;               // [03]  C   Titulo do campo
        "DT Emi.JV",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "D",;                       // [06]  C   Tipo do campo
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
    oStTmp:AddField(;
        "TMP_DOCJV",;               // [01]  C   Nome do Campo
        "03",;                      // [02]  C   Ordem
        "NF JV",;                   // [03]  C   Titulo do campo
        "NF JV",;                   // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo       
    oStTmp:AddField(;
        "TMP_SERJV",;               // [01]  C   Nome do Campo
        "04",;                      // [02]  C   Ordem
        "Serie JV",;                // [03]  C   Titulo do campo
        "Serie JV",;                // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo           
    oStTmp:AddField(;
        "TMP_PEDCI",;               // [01]  C   Nome do Campo
        "05",;                      // [02]  C   Ordem
        "Ped. CD",;                // [03]  C   Titulo do campo
        "Ped. CD",;                // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo
    oStTmp:AddField(;   
        "TMP_DTEMC",;               // [01]  C   Nome do Campo
        "06",;                      // [02]  C   Ordem
        "DT Emi.CD",;              // [03]  C   Titulo do campo
        "DT Emi.CD",;              // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "D",;                       // [06]  C   Tipo do campo
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
    oStTmp:AddField(;
        "TMP_DOCCI",;               // [01]  C   Nome do Campo
        "07",;                      // [02]  C   Ordem
        "NF CD",;                   // [03]  C   Titulo do campo
        "NF CD",;                   // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo       
    oStTmp:AddField(;
        "TMP_SERCI",;               // [01]  C   Nome do Campo
        "08",;                      // [02]  C   Ordem
        "Seri CD",;                // [03]  C   Titulo do campo
        "Seri CD",;                // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo    
    oStTmp:AddField(;   
        "TMP_CLIEN",;               // [01]  C   Nome do Campo
        "09",;                      // [02]  C   Ordem
        "Cod Client",;              // [03]  C   Titulo do campo
        "Cod Client",;              // [04]  C   Descricao do campo
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
    oStTmp:AddField(;
        "TMP_LOJA",;                // [01]  C   Nome do Campo
        "10",;                      // [02]  C   Ordem
        "Loja",;                    // [03]  C   Titulo do campo
        "Loja",;                    // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo       
    oStTmp:AddField(;
        "TMP_RZSOC",;               // [01]  C   Nome do Campo
        "11",;                      // [02]  C   Ordem
        "Razao Soc.",;              // [03]  C   Titulo do campo
        "Razao Soc.",;              // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        Iif(INCLUI, .T., .F.),;     // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo         
    oStTmp:AddField(;
        "TMP_VALOR",;                 // [01]  C   Nome do Campo
        "12",;                      // [02]  C   Ordem
        "Valor",;                   // [03]  C   Titulo do campo
        "Valor",;                   // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "N",;                       // [06]  C   Tipo do campo
        "@E 9,999,999.99",;         // [07]  C   Picture
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
         
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_TMP", oStTMP, "FORMTMP")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_TMP', cTitulo )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_TMP","TELA")
Return oView

/*/{Protheus.doc} CriaSx1
//TODO
@description Cria grupo de pergunta
@author Willian Kaneta
@since 29/08/2016
@version 1.0
@type function
/*/
Static Function CriaSx1()
	Local aPergs   := {}
    Local lRet     := .F.
    Local cRomDe   := Space(TamSX3('GWN_NRROM')[01])
    Local cRomAt   := Space(TamSX3('GWN_NRROM')[01])
    Local dDataDe  := CTOD("  /  /    ")
    Local dDataAt  := CTOD("  /  /    ")
    
    aAdd(aPergs, {1, "Romaneio de"    , cRomDe,  "",             ".T.",        "GW1ROM", ".T.", 80, .F.})
    aAdd(aPergs, {1, "Romaneio Até"   , cRomAt,  "",             ".T.",        "GW1ROM", ".T.", 80, .T.})
    aAdd(aPergs, {1, "Data De"        , dDataDe, "",             ".T.",        "",    ".T.", 50, .F.})
    aAdd(aPergs, {1, "Data Até"       , dDataAt, "",             ".T.",        "",    ".T.", 50, .T.})
    
    If ParamBox(aPergs, "Informe os parâmetros")
        lRet := .T.
    EndIf
	
Return lRet

/*/{Protheus.doc} GERROMAN
    Função para Gerar Romaneio OMS
    @type  Function
    @author Willian Kaneta
    @since 30/08/2020
    @version 1.0
    /*/
Static Function GERROMAN()
    Local aAreaSM0  := SM0->(GetArea())
    Local nTamNota  := TamSX3('F2_DOC')[1]
    Local nTamSerie := TamSX3('F2_SERIE')[1]
    Local cPasta    := GetTempPath()
    Local cIdent    := ""
    Local cFilBCK   := cFilAnt
    Local oDanfe    := Nil
    Local lExistNFe := .T.
    Local lIsLoja   := .F.
    
    Private cArquivo  := ""
    Private PixelX
    Private PixelY
    Private nConsNeg
    Private nConsTex
    Private oRetNF
    Private nColAux 
    Private cNota   := ""
    Private cSerie  := ""
    Private cRmIni  := ""
    Private cRmFim  := ""
         
    cRmIni    := (cAliasTmp)->TMP_ROMAN
    cRmFim    := (cAliasTmp)->TMP_ROMAN

    //--------------------------------------------
    //Define as perguntas da DANFE NFe Joinville**
    //--------------------------------------------
    cFilAnt := "010104"
    POSICIONE("SM0",1,cEmpAnt+cFilAnt,"M0_CGC")
    cIdent  := RetIdEnti()

    //Gera o XML da Nota
    cArquivo := TMP_DOCJV + "_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-") + ".xml"
    //RETXMLNF(TMP_DOCJV, TMP_SERJV, cPasta + cArquivo, .F.) 

    //Cria a Danfe
    oDanfe := FWMSPrinter():New(cArquivo, 2, .F. /*lAdjustToLegacy*/,cPasta/*cPathInServer*/,.T.,/*lTReport*/,/*oPrintSetup*/)
    //FWMSPrinter():New(cArquivo,2, .F., , .T.)
        
    //Propriedades da DANFE
    oDanfe:SetResolution(78)
    oDanfe:SetPortrait()
    oDanfe:SetPaperSize(DMPAPER_A4)
    oDanfe:SetMargin(60, 60, 60, 60)

    Pergunte("NFSIGW",.F.)
    MV_PAR01 := PadR(cNFJVLIni, nTamNota)  //Nota Inicial
    MV_PAR02 := PadR(cNFJVLFim, nTamNota)  //Nota Final
    MV_PAR03 := PadR(cSerJVL  , nTamSerie) //Série da Nota
    MV_PAR04 := 2                          //NF de Saida
    MV_PAR05 := 2                          //Frente e Verso = Sim
    MV_PAR06 := 2                          //DANFE simplificado = Nao  
    MV_PAR07 := CTOD("01/01/2000")
    MV_PAR08 := CTOD("31/12/9999")
    //Força a impressão em PDF
    oDanfe:Setup()
        
    //Variáveis obrigatórias da DANFE (pode colocar outras abaixo)
    PixelX    := oDanfe:nLogPixelX()
    PixelY    := oDanfe:nLogPixelY()
    nConsNeg  := 0.4
    nConsTex  := 0.5
    oRetNF    := Nil
    nColAux   := 0

    //Chamando a impressão da danfe no RDMAKE
    RptStatus({|lEnd| U_DanfeProc(@oDanfe, @lEnd, cIdent, Nil, Nil, @lExistNFe, lIsLoja)}, "Imprimindo Danfe...")
    oDanfe:Preview()

    Sleep(500)

    //--------------------------------------
    //Define as perguntas da DANFE NFe CD**
    //--------------------------------------
    cFilAnt := cFilCD
    POSICIONE("SM0",1,cEmpAnt+cFilAnt,"M0_CGC")
    cIdent    := RetIdEnti()
    //Gera o XML da Nota
    cArquivo := TMP_DOCCI + "_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-") + ".xml"
        
    //Cria a Danfe
    oDanfe := FWMSPrinter():New(cArquivo, 2, .F. /*lAdjustToLegacy*/,cPasta/*cPathInServer*/,.T.,/*lTReport*/,/*oPrintSetup*/)
    //FWMSPrinter():New(cArquivo,2, .F., , .T.)
        
    //Propriedades da DANFE
    oDanfe:SetResolution(78)
    oDanfe:SetPortrait()
    oDanfe:SetPaperSize(DMPAPER_A4)
    oDanfe:SetMargin(60, 60, 60, 60)

    Pergunte("NFSIGW",.F.)
    MV_PAR01 := PadR(cNFCICIni, nTamNota)  //Nota Inicial
    MV_PAR02 := PadR(cNFCICFim, nTamNota)  //Nota Final
    MV_PAR03 := PadR(cSerCIC  , nTamSerie) //Série da Nota
    MV_PAR04 := 2                          //NF de Saida
    MV_PAR05 := 2                          //Frente e Verso = Sim
    MV_PAR06 := 2                          //DANFE simplificado = Nao
    MV_PAR07 := CTOD("01/01/2000")
    MV_PAR08 := CTOD("31/12/9999")    

    //Força a impressão em PDF
    oDanfe:Setup()
        
    //Variáveis obrigatórias da DANFE (pode colocar outras abaixo)
    PixelX    := oDanfe:nLogPixelX()
    PixelY    := oDanfe:nLogPixelY()
    nConsNeg  := 0.4
    nConsTex  := 0.5
    oRetNF    := Nil
    nColAux   := 0

    //Chamando a impressão da danfe no RDMAKE
    RptStatus({|lEnd| U_DanfeProc(@oDanfe, @lEnd, cIdent, Nil, Nil, @lExistNFe, lIsLoja)}, "Imprimindo Danfe...")
    oDanfe:Preview()

    //Relatório Romaneio
    U_CTGFEROM()

    cFilAnt := cFilBCK
    RestArea(aAreaSM0)
Return Nil
