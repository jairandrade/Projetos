#Include "totvs.ch"
#include "directry.ch" 

/*/{Protheus.doc} TCIMPCV1
    Função para realizar importação arquivo .CSV para a tabela CV1
    @type  Function
    @author Willian Kaneta
    @since 18/08/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function TCIMPCV1()
    Local aDados1   := {}
    Local aDados2   := {}
    Local nLin      := 0
    Local cTipo     := "Planilha Excel  (*.xlsx)  | *.xlsx | "
    Local cNomeARQ  := cGetFile(cTipo,OemToAnsi("Selecionar Arquivo..."))

    if !empty(cNomeARQ)

        nHandle := FT_FUSE(cNomeARQ)
        
        if nHandle < 0
            Alert("Erro ao abrir o arquivo de texto!")
            Return .F.
        endif
        
        //Converte arquivo .XLSX para Array
        aDados1 := CONVXLSX(cNomeARQ,1)
        
        //Remove a Primeira Linha
        For nLin := 2 To Len(aDados1)
            aAdd(aDados2, aDados1[nLin])
        Next nLin 

        Processa( {|| IMPORTACV1(aDados2) } ,;
                    "Aguarde realizando a importação..."+CRLF+"Pode demorar")

        FT_FUSE()  
        
    endif
Return Nil

/*/{Protheus.doc} CONVXLSX
    Função que realiza a importação do arquivo .XLSX para um array
    @type  Static Function
    @author Willian Kaneta
    @since 18/08/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function CONVXLSX(cNamARQ,cOrigemE,nLinTitE)
   Local cMsg        := ""
   Local nPosIni     := 0

   Private cArq       := ""
   Private _cNomeAr   := cNamARQ
   Private cArqMacro  := "XLS2DBF.XLA"
   Private cTemp      := GetTempPath() //pega caminho do temp do client
   Private cSystem    := Upper(GetSrvProfString("STARTPATH",""))//Pega o caminho do sistema
   Private cOrigem    := If(ValType(cOrigemE)=="C",cOrigemE,"")
   Private nLinTit    := If(ValType(nLinTitE)=="N",nLinTitE,0)
   Private aArquivos  := {}
   Private aRet       := {}

   cArq := Alltrim(_cNomeAr)
   cMsg := validaCpos(cArq)

   nPosIni  := RAt("\",cArq) + 1
   nPosFim  := Len(Alltrim(cArq)) + 1
   
   cOrigem  := SUBSTR(cArq,1,nPosIni-1)
   cArq := SUBSTR(cArq,nPosIni,nPosFim)

   If Empty(cMsg) 
      aAdd(aArquivos, cArq)
      IntegraArq()
   Else
      MsgStop(cMSg)
      Return
   EndIf

Return aRet

/*/{Protheus.doc} IntegraArq
    Faz a chamada das rotinas referentes a integração
    @type  Static Function
    @authorKanaãm L. R. Rodrigues
    @since 24/05/2012
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function IntegraArq()
    Local lConv      := .F.
    //converte arquivos xls para csv copiando para a pasta temp
    MsAguarde( {|| lConv := convArqs(aArquivos) }, "Convertendo arquivo", "Convertendo arquivo" )
    If lConv
        //carrega do xls no array
        Processa( {|| aRet:= CargaArray(AllTrim(cArq)) } ,;
                        "Aguarde, carregando planilha..."+CRLF+"Pode demorar") 
    EndIf
Return

/*/{Protheus.doc} convArqs
    Converte os arquivos .xls para .csv
    @type  Static Function
    @authorKanaãm L. R. Rodrigues
    @since 24/05/2012
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function convArqs(aArqs)
    Local oExcelApp
    Local cNomeXLS  := ""
    Local cFile     := ""
    Local cExtensao := ""
    Local i         := 1
    Local j         := 1
    Local aExtensao := {}

    //loop em todos arquivos que serão convertidos
    For i := 1 To Len(aArqs)      

    If !"." $ AllTrim(aArqs[i])
        //passa por aqui para verifica se a extensão do arquivo é .xls ou .xlsx
        aExtensao := Directory(cOrigem+AllTrim(aArqs[i])+".*")
        For j := 1 To Len(aExtensao)
            If "XLS" $ Upper(aExtensao[j][1])
                cExtensao := SubStr(aExtensao[j][1],Rat(".",aExtensao[j][1]),Len(aExtensao[j][1])+1-Rat(".",aExtensao[j][1]))
                Exit
            EndIf
        Next j
    EndIf
    //recebe o nome do arquivo corrente
    cNomeXLS := AllTrim(aArqs[i])
    cFile    := cOrigem+cNomeXLS+cExtensao
    
    If !File(cFile)
        MsgInfo("O arquivo "+cFile+" não foi encontrado!" ,"Arquivo")      
        Return .F.
    EndIf
        
    //verifica se existe o arquivo na pasta temporaria e apaga
    If File(cTemp+cNomeXLS+cExtensao)
        fErase(cTemp+cNomeXLS+cExtensao)
    EndIf                 
    
    //Copia o arquivo XLS para o Temporario para ser executado
    Copy File &cFile To &(cTemp+cNomeXLS+cExtensao)
    /*If !AvCpyFile(cFile,cTemp+cNomeXLS+cExtensao,.F.) 
        MsgInfo("Problemas na copia do arquivo "+cFile+" para "+cTemp+cNomeXLS+cExtensao ,"AvCpyFile()")
        Return .F.
    EndIf*/                                       
    
    //apaga macro da pasta temporária se existir
    If File(cTemp+cArqMacro)
        fErase(cTemp+cArqMacro)
    EndIf

    //Copia o arquivo XLA para o Temporario para ser executado
    Copy File &(cSystem+cArqMacro) To &(cTemp+cArqMacro)
    /*If !AvCpyFile(cSystem+cArqMacro,cTemp+cArqMacro,.F.) 
        MsgInfo("Problemas na copia do arquivo "+cSystem+cArqMacro+"para"+cTemp+cArqMacro ,"AvCpyFile()")
        Return .F.
    EndIf*/
    
    //Exclui o arquivo antigo (se existir)
    If File(cTemp+cNomeXLS+".csv")
        fErase(cTemp+cNomeXLS+".csv")
    EndIf
    
    //Inicializa o objeto para executar a macro
    oExcelApp := MsExcel():New()             
    //define qual o caminho da macro a ser executada
    oExcelApp:WorkBooks:Open(cTemp+cArqMacro)       
    //executa a macro passando como parametro da macro o caminho e o nome do excel corrente
    oExcelApp:Run(cArqMacro+'!XLS2DBF',cTemp,cNomeXLS)
    //fecha a macro sem salvar
    oExcelApp:WorkBooks:Close('savechanges:=False')
    //sai do arquivo e destrói o objeto
    oExcelApp:Quit()
    oExcelApp:Destroy()

    //Exclui o Arquivo excel da temp
    fErase(cTemp+cNomeXLS+cExtensao)
    fErase(cTemp+cArqMacro) //Exclui a Macro no diretorio temporario
    //
    Next i
    //
Return .T. 

/*/{Protheus.doc} CargaArray
    Carrega dados do csv no array pra retorno
    @type  Static Function
    @authorKanaãm L. R. Rodrigues
    @since 24/05/2012
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function CargaArray(cArq)
    Local cLinha  := ""
    Local cNomeArq:= ""
    Local nLin    := 1 
    Local aDados  := {}
    Local cFile   := ""
    Local nHandle := 0

    cNomeArq  := SUBSTR(cArq,1,RAt(".",cArq)-1)

    cFile   := cTemp + cNomeArq + ".csv"
    //abre o arquivo csv gerado na temp
    nHandle := Ft_Fuse(cFile)
    If nHandle == -1
    Return aDados
    EndIf
    Ft_FGoTop()                                                         
    nLinTot := FT_FLastRec()-1
    ProcRegua(nLinTot)
    //Pula as linhas de cabeçalho
    While nLinTit > 0 .AND. !Ft_FEof()
    Ft_FSkip()
    nLinTit--
    EndDo

    //percorre todas linhas do arquivo csv
    Do While !Ft_FEof()
    //exibe a linha a ser lida
    IncProc("Carregando Linha "+AllTrim(Str(nLin))+" de "+AllTrim(Str(nLinTot)))
    nLin++
    //le a linha
    cLinha := Ft_FReadLn()
    //verifica se a linha está em branco, se estiver pula
    If Empty(AllTrim(StrTran(cLinha,';','')))
        Ft_FSkip()
        Loop
    EndIf
    //transforma as aspas duplas em aspas simples
    cLinha := StrTran(cLinha,'"',"'")
    cLinha := '{"'+cLinha+'"}' 
    //adiciona o cLinha no array trocando o delimitador ; por , para ser reconhecido como elementos de um array 
    cLinha := StrTran(cLinha,';','","')
    aAdd(aDados, &cLinha)
    
    //passa para a próxima linha
    FT_FSkip()
    //
    EndDo

    //libera o arquivo CSV
    FT_FUse()             

    //Exclui o arquivo csv
    If File(cFile)
    FErase(cFile)
    EndIf
Return aDados

/*/{Protheus.doc} validaCpos
    Faz a validação dos campos da tela de filtro
    @type  Static Function
    @authorKanaãm L. R. Rodrigues
    @since 24/05/2012
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function validaCpos(cArq)
Local cMsg := ""

If Empty(cArq)
   cMsg += "Campo Arquivo deve ser preenchido!"+ENTER
EndIf                            

Return cMsg

/*/{Protheus.doc} IMPORTACV1
    Função que realiza a importação dos dados para a CV1
    @type  Static Function
    @author Willian Kaneta
    @since 18/08/2020
    @version 1.0
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function IMPORTACV1(aDados)
    Local aCampo    := {}
    Local aDadosCV1 := {}
    Local nX        := 0
    Local nValor    := 0
    Local nLinTot   := 0
    Local nTotGrv   := 0
    Local nTotIgn   := 0
    Local nPeriodo  := 0
    Local cChaveCV2 := ""
    Local cMsgLog   := ""
    Local lRegOK    := .T.
    
    Private cMsgNoImp   := ""
    Private aRetAuto    := {}

    aAdd(aRetAuto,.F.)
    aAdd(aRetAuto,.F.)

    Pergunte("CTB390", .F.)

    nLinTot := Len(aDados)
    ProcRegua(nLinTot)

    For nX := 1 To Len(aDados)  
        IncProc("Analisando registro "+AllTrim(Str(nX))+" de "+AllTrim(Str(nLinTot)))     
        If nX == 1
            cChaveCV2 := PadR(aDados[nX][2],TamSX3("CV2_ORCMTO")[1])+PadR(aDados[nX][5],TamSX3("CV2_CALEND")[1])
        EndIf
        nValor := VAL(StrTran(StrTran(StrTran(aDados[nX][20],".",""),"R$",""),",","."))
        aCampo := {}

        //Valida a consistência das informações do registro
        lRegOK := VALDADOS(aDados[nX],nX+1)
        
        If lRegOK
            If aDados[nX][17] == "01"
                nPeriodo := 1
            EndIf
            //CV1_FILIAL, CV1_ORCMTO, CV1_CALEND, CV1_MOEDA, CV1_REVISA, CV1_SEQUEN, CV1_PERIOD
            cChaveCV1 := PadR(aDados[nX][2],TamSX3("CV2_ORCMTO")[1])        + PadR(aDados[nX][5],TamSX3("CV2_CALEND")[1])   + ;
                        PadR(aDados[nX][6],TamSX3("CV1_MOEDA")[1])          + PadR(aDados[nX][7],TamSX3("CV1_REVISA")[1])   + ;
                        STRZERO(VAL(aDados[nX][8]),TamSX3("CV1_SEQUEN")[1]) + STRZERO(nPeriodo,TamSX3("CV1_PERIOD")[1])
            DbSelectArea("CV1")
            CV1->(DbSetOrder(1))

            If !CV1->(MsSeek(xFilial("CV1")+cChaveCV1))
                aAdd(aCampo,{"CV1_FILIAL"  , xFilial("CV1")        })
                aAdd(aCampo,{"CV1_ORCMTO"  , aDados[nX][2]         })
                aAdd(aCampo,{"CV1_DESCRI"  , aDados[nX][3]         })
                aAdd(aCampo,{"CV1_STATUS"  , aDados[nX][4]         })
                aAdd(aCampo,{"CV1_CALEND"  , aDados[nX][5]         })
                aAdd(aCampo,{"CV1_MOEDA"   , aDados[nX][6]         })
                aAdd(aCampo,{"CV1_REVISA"  , aDados[nX][7]         })
                aAdd(aCampo,{"CV1_SEQUEN"  , STRZERO(VAL(aDados[nX][8]),TamSX3("CV1_SEQUEN")[1])})
                aAdd(aCampo,{"CV1_CT1INI"  , aDados[nX][9]         })
                aAdd(aCampo,{"CV1_CT1FIM"  , aDados[nX][10]        })
                aAdd(aCampo,{"CV1_CTTINI"  , aDados[nX][11]        })
                aAdd(aCampo,{"CV1_CTTFIM"  , aDados[nX][12]        })
                aAdd(aCampo,{"CV1_CTDINI"  , aDados[nX][13]        })
                aAdd(aCampo,{"CV1_CTDFIM"  , aDados[nX][14]        })         
                aAdd(aCampo,{"CV1_CTHFIM"  , aDados[nX][15]        })
                aAdd(aCampo,{"CV1_CTHFIM"  , aDados[nX][16]        })
                aAdd(aCampo,{"CV1_PERIOD"  , STRZERO(nPeriodo,TamSX3("CV1_PERIOD")[1])})         
                aAdd(aCampo,{"CV1_DTINI"   , CTOD(aDados[nX][18])  })
                aAdd(aCampo,{"CV1_DTFIM"   , CTOD(aDados[nX][19])  })
                aAdd(aCampo,{"CV1_VALOR"   , nValor                })
                aAdd(aCampo,{"CV1_APROVA"  , aDados[nX][21]        })
                aAdd(aDadosCV1,aCampo)
                nTotGrv++
                nPeriodo++
            Else
                nTotIgn++
            EndIf
        EndIf
    Next nX

    DbSelectArea("CV2")
    CV2->(DbSetOrder(1))

    If CV2->(MsSeek(xFilial("CV2")+cChaveCV2))
        Processa( {|| GRAVACV1("CV1",CV2->(Recno()),4,.T.,aDadosCV1) } ,;
                    "Aguarde realizando a importação..."+CRLF+"Pode demorar") 
    Else
        Processa( {|| GRAVACV1("CV1",,3,.T.,aDadosCV1) } ,;
                        "Aguarde realizando a importação..."+CRLF+"Pode demorar") 
    EndIf

    //Log de Importação
    cMsgLog += "Total Importado...................: " + cValToChar(nTotGrv) + CRLF
    cMsgLog += "Total Ignorado (Já existe na CV1).: " + cValToChar(nTotIgn) + CRLF
    If !Empty(cMsgNoImp)
        cMsgLog += CRLF+CRLF+ "Registros com inconsitência: " + CRLF
        cMsgLog += cMsgNoImp
    EndIf
    
    LOGIMPORT(cMsgLog, "Log Importação CV1/CV2", 1, .F.) 

Return Nil

/*/{Protheus.doc} LOGIMPORT
Função que mostra uma mensagem de Log com a opção de salvar em txt
@type function
@author Willian Kaneta
@since 20/05/2020
@version 1.0
@param cMsg, character, Mensagem de Log
@param cTitulo, character, Título da Janela
@param nTipo, numérico, Tipo da Janela (1 = Ok; 2 = Confirmar e Cancelar)
@param lEdit, lógico, Define se o Log pode ser editado pelo usuário
@return lRetMens, Define se a janela foi confirmada
@example
    LOGIMPORT("Teste 123", "Título", 1, .T.)
    LOGIMPORT("Teste 123", "Título", 2, .F.)
/*/
 
Static Function LOGIMPORT(cMsg, cTitulo, nTipo, lEdit)
    Local lRetMens := .F.
    Local oDlgMens
    Local oBtnOk, cTxtConf := ""
    Local oBtnCnc, cTxtCancel := ""
    Local oBtnSlv
    Local oFntTxt := TFont():New("Lucida Console",,-015,,.F.,,,,,.F.,.F.)
    Local oMsg

    Default cMsg    := "..."
    Default cTitulo := "LOGIMPORT"
    Default nTipo   := 1 // 1=Ok; 2= Confirmar e Cancelar
    Default lEdit   := .F.
     
    //Definindo os textos dos botões
    If(nTipo == 1)
        cTxtConf:='&Ok'
    Else
        cTxtConf:='&Confirmar'
        cTxtCancel:='C&ancelar'
    EndIf
 
    //Criando a janela centralizada com os botões
    DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 300, 550 COLORS 0, 16777215 PIXEL
        //Get com o Log
        @ 002, 004 GET oMsg VAR cMsg OF oDlgMens MULTILINE SIZE 270, 121 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
        If !lEdit
            oMsg:lReadOnly := .T.
        EndIf
         
        //Se for Tipo 1, cria somente o botão OK
        If (nTipo==1)
            @ 127, 224 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 019 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
         
        //Senão, cria os botões OK e Cancelar
        ElseIf(nTipo==2)
            @ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 009 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
            @ 137, 144 BUTTON oBtnCnc PROMPT cTxtCancel SIZE 051, 009 ACTION (lRetMens:=.F., oDlgMens:End()) OF oDlgMens PIXEL
        EndIf
         
        //Botão de Salvar em Txt
        @ 127, 004 BUTTON oBtnSlv PROMPT "&Salvar em .txt" SIZE 051, 019 ACTION (fSalvArq(cMsg, cTitulo)) OF oDlgMens PIXEL
    ACTIVATE MSDIALOG oDlgMens CENTERED
 
Return lRetMens

/*/{Protheus.doc} fSalvArq
//TODO
@description CFunção para gerar um arquivo texto
@author Willian Kaneta
@since 20/05/2020
@version 1.0
@type function
/*/
Static Function fSalvArq(cMsg, cTitulo)
    Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".txt"
    Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
    Local lOk      := .T.
    Local cTexto   := ""
     
    //Pegando o caminho do arquivo
    cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,'',.T., GETF_LOCALHARD)
 
    //Se o nome não estiver em branco    
    If !Empty(cFileNom)
        //Teste de existência do diretório
        If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
            Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
            Return
        EndIf
         
        //Montando a mensagem
        cTexto := "Função   - "+ FunName()       + CRLF
        cTexto += "Usuário  - "+ cUserName       + CRLF
        cTexto += "Data     - "+ dToC(dDataBase) + CRLF
        cTexto += "Hora     - "+ Time()          + CRLF
        cTexto += "Mensagem - "+ cTitulo + cQuebra  + cMsg + cQuebra
         
        //Testando se o arquivo já existe
        If File(cFileNom)
            lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
        EndIf
         
        If lOk
            MemoWrite(cFileNom, cTexto)
            MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atenção")
        EndIf
    EndIf
Return

/*/{Protheus.doc} VALDADOS
    Função para realizar a validação das informações
    @type  Static Function
    @author Willian Kaneta
    @since 21/08/2020
    @version 1.0
    @param aDados[nX] = Linha com registro atual no loop
    @return lRet = .T. Valido/.F. Não Valido
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function VALDADOS(aLDados,nLinha)
    Local lRet      := .T.
    Local nTamCampo := 0
    
    If Empty(aLDados[2])
        cMsgNoImp += "Campo: CV1_ORCMTO Vazio, linha " + cValToChar(nLinha) + CRLF
        lRet := .F.
    EndIf
    If Empty(aLDados[3])
        cMsgNoImp += "Campo: CV1_DESCRI Vazio, linha " + cValToChar(nLinha) + CRLF
        lRet := .F.
    EndIf
    If Empty(aLDados[4])
        cMsgNoImp += "Campo: CV1_STATUS Vazio, linha " + cValToChar(nLinha) + CRLF
        lRet := .F.
    EndIf
    If Empty(aLDados[5])
        cMsgNoImp += "Campo: CV1_CALEND Vazio, linha " + cValToChar(nLinha) + CRLF
        lRet := .F.
    EndIf
    If Empty(aLDados[6])
        cMsgNoImp += "Campo: CV1_MOEDA Vazio, linha " + cValToChar(nLinha) + CRLF
        lRet := .F.
    EndIf
    If Empty(aLDados[7])
        cMsgNoImp += "Campo: CV1_REVISA Vazio, linha " + cValToChar(nLinha) + CRLF
        lRet := .F.
    EndIf
    If Empty(aLDados[8])
        cMsgNoImp += "Campo: CV1_SEQUEN Vazio, linha " + cValToChar(nLinha) + CRLF
        lRet := .F.
    EndIf
    If  Empty(aLDados[9])  .AND. Empty(aLDados[10]) .AND. ;
        Empty(aLDados[11]) .AND. Empty(aLDados[12]) .AND. ;
        Empty(aLDados[13]) .AND. Empty(aLDados[14]) .AND. ;
        Empty(aLDados[14]) .AND. Empty(aLDados[16])
        cMsgNoImp += "É necessário informar a entidade a ser orçada, linha " + cValToChar(nLinha) + CRLF
        lRet := .F.
    Else 
        If !Empty(aLDados[9]) .OR. !Empty(aLDados[10])
            nTamCampo := TamSX3("CT1_CONTA")[1]
            DbSelectArea("CT1")
            CT1->(DbSetOrder(1))
            If !CT1->(MsSeek(xFilial("CT1")+PadR(aLDados[9],nTamCampo))) .OR. !CT1->(MsSeek(xFilial("CT1")+PadR(aLDados[10],nTamCampo)))
                cMsgNoImp += "Entidade não localizada CV1_CT1INI/ CV1_CT1FIM, linha " + cValToChar(nLinha) + CRLF
                lRet := .F.
            EndIf            
        EndIf
        If !Empty(aLDados[11]) .OR. !Empty(aLDados[12])
            nTamCampo := TamSX3("CTT_CUSTO")[1]
            DbSelectArea("CTT")
            CTT->(DbSetOrder(1))
            If !CTT->(MsSeek(xFilial("CTT")+PadR(aLDados[11],nTamCampo))) .OR. !CTT->(MsSeek(xFilial("CTT")+PadR(aLDados[12],nTamCampo)))
                cMsgNoImp += "Entidade não localizada CV1_CTTINI/ CV1_CTTFIM, linha " + cValToChar(nLinha) + CRLF
                lRet := .F.
            EndIf            
        EndIf       
        If !Empty(aLDados[13]) .OR. !Empty(aLDados[14])
            nTamCampo := TamSX3("CTD_ITEM")[1]
            DbSelectArea("CTD")
            CTD->(DbSetOrder(1))
            If !CTD->(MsSeek(xFilial("CTD")+PadR(aLDados[13],nTamCampo))) .OR. !CTD->(MsSeek(xFilial("CTD")+PadR(aLDados[14],nTamCampo)))
                cMsgNoImp += "Entidade não localizada CV1_CTDINI/ CV1_CTDFIM, linha " + cValToChar(nLinha) + CRLF
                lRet := .F.
            EndIf            
        EndIf
        If !Empty(aLDados[15]) .OR. !Empty(aLDados[16])
            nTamCampo := TamSX3("CTH_CLVL")[1]
            DbSelectArea("CTH")
            CTH->(DbSetOrder(1))
            If !CTH->(MsSeek(xFilial("CTH")+PadR(aLDados[15],nTamCampo))) .OR. !CTH->(MsSeek(xFilial("CTH")+PadR(aLDados[16],nTamCampo)))
                cMsgNoImp += "Entidade não localizada CV1_CTHINI/ CV1_CTHFIM, linha " + cValToChar(nLinha) + CRLF
                lRet := .F.
            EndIf            
        EndIf        
    EndIf
    If Empty(aLDados[17])
        cMsgNoImp += "Campo: CV1_PERIOD Vazio, linha " + cValToChar(nLinha) + CRLF
        lRet := .F.
    EndIf
    If Empty(aLDados[18])
        cMsgNoImp += "Campo: CV1_DTINI Vazio, linha " + cValToChar(nLinha) + CRLF
        lRet := .F.
    EndIf
    If Empty(aLDados[19])
        cMsgNoImp += "Campo: CV1_DTFIM Vazio, linha " + cValToChar(nLinha) + CRLF
        lRet := .F.
    EndIf    
    If Empty(aLDados[20])
        cMsgNoImp += "Campo: CV1_VALOR Vazio, linha " + cValToChar(nLinha) + CRLF
        lRet := .F.
    EndIf    
Return lRet


/*/{Protheus.doc} GRAVACV1
    Grava Registros CV1 e CV2
    @type  Static Function
    @author Willian Kaneta
    @since 20/08/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function GRAVACV1(cAlias,nReg,nOpcx,lAutomato,aAuto)
	Local nLenVal	 	:= nSEQUEN := 0
	Local nC			:= 0
	Local cCV2Filial 	:= xFilial("CV2")
	Local nT			:= 0
	Local nLinTot		:= 0

	nLinTot := Len(aAuto)
    ProcRegua(nLinTot)

	For nT := 1 to Len(aAuto)
		IncProc("Importando para tabela CV1 e CV2 - "+AllTrim(Str(nT))+" de "+AllTrim(Str(nLinTot)))
		RecLock("CV1",.T.)
        If nT == 1
            If nOpcx == 3
                DbSelectArea("CV2")
                CV2->(DbsetOrder(1))

                RecLock("CV2",.T.)		/// SE FOR INCLUSAO, COPIA OU REVISAO
                CV2->CV2_FILIAL	:= cCV2Filial
                CV2->CV2_ORCMTO	:= aAuto[nT][2][2]
                CV2->CV2_DESCRI	:= aAuto[nT][3][2]
                CV2->CV2_CALEND	:= aAuto[nT][5][2]
                CV2->CV2_MOEDA	:= aAuto[nT][6][2]
                CV2->CV2_REVISA	:= aAuto[nT][7][2]
                CV2->CV2_STATUS	:= aAuto[nT][4][2]
                CV2->CV2_APROVA := aAuto[nT][21][2]
                CV2->(MsUnlock())
            ElseIf nOpcx == 4
                DbSelectArea("CV2")
                CV2->(DbGoTo(nReg))

                RecLock("CV2",.F.)
                CV2->CV2_CALEND	:= aAuto[nT][5][2]
                CV2->CV2_MOEDA	:= aAuto[nT][6][2]
                CV2->CV2_REVISA	:= aAuto[nT][7][2]
                CV2->CV2_DESCRI	:= aAuto[nT][3][2]
                CV2->CV2_APROVA := aAuto[nT][21][2]
                CV2->(MsUnlock())	
            Endif
        EndIf

		For nC := 1 To Len(aAuto[nT])
			If CV1->( FieldPos(aAuto[nT][nC][1]) ) > 0
				CV1->&(aAuto[nT][nC][1]) := aAuto[nT][nC][2]
			EndIf
		Next nC
		CV1->(MsUnlock())
	Next nT

Return(.T.)
