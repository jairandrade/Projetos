#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "TryException.ch"
#Include "rwmake.ch"
#Include "AP5MAIL.Ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*-----------------+---------------------------------------------------------+
!Nome              ! ACOM101P - Cliente: Madero                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Envio de pedidos de compras (Impressao)                 !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 28/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function ACOM101P()
Local cAlias 	:= "SC7" 
Local nReg   	:= SC7->(recno())
Local nOpcx  	:= 6
Local lTRepInUse:= .T.
Local aRet 		:= {}
Local oReport
PRIVATE lAuto := (nReg!=Nil)

    lTRepInUse := .T.

    // -> Verifica se o pedido foi liberado por alçadas
    If SC7->C7_CONAPRO <> "L"
    	aadd(aRet,{SC7->C7_FILIAL,SC7->C7_NUM,"SC7",SC7->C7_NUM,"Pedido de compra nao liberado por alcada: [C7_CONAPRO = " + SC7->C7_CONAPRO+"]"})
    EndIf
    
    If Len(aRet) <= 0
	    oReport:= ReportDef(nReg, nOpcx)
	    oReport:PrintDialog()
    Endif
        
Return(aRet)


/*-----------------+---------------------------------------------------------+
!Nome              ! COM101E - Cliente: Madero                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Envio de pedidos de compras (Email)                 !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 28/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function COM101E()
Local cAlias 	:= "SC7" 
Local nReg   	:= SC7->(recno())
Local nOpcx  	:= 6
Local lTRepInUse:= .T.
Local aRet 		:={}
Local cCorpo 	:= ""
Local cEmDest	:= ""
Local cSubj  	:= ""
Local cAnexo 	:= ""
Local cCidade 	:= ""
Local cUF     	:= ""
Local aSM0   	:= SM0->(GetArea())
Local nw        := 0
Local cAux      := ""
Local oReport
Local aRetMail
Local nRecSC7
PRIVATE lAuto := (nReg!=Nil)
    
    nRecSC7:=SC7->(recno())
    
    // -> Verifica se o pedido foi liberado
    If SC7->C7_XENVCR <> "L"
		aadd(aRet,{SC7->C7_FILIAL,SC7->C7_NUM,"SC7",SC7->C7_NUM,"Pedido de compra nao liberado pela rotina de MRP: [C7_XENVCR = " + SC7->C7_XENVCR+"]"})    
    EndIf
    
    // -> Verifica se o pedido foi liberado por alçadas
    If SC7->C7_CONAPRO <> "L"
    	aadd(aRet,{SC7->C7_FILIAL,SC7->C7_NUM,"SC7",SC7->C7_NUM,"Pedido de compra nao liberado por alcada: [C7_CONAPRO = " + SC7->C7_CONAPRO+"]"})
    EndIf
    
    If Len(aRet) <= 0
		
		// -> posiciona no comprador 	    
	    SY1->(dbSetOrder(1))
	    SY1->(dbSeek(xFilial("SY1")+SC7->C7_COMPRA))
	    
	    // -> Posiciona no fornecedor
	    SA2->(dbSetOrder(1))
	    SA2->(dbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA))
	    	    
	    // -> Posiciona na filial de destino
	    SM0->(dbSeek(cEmpAnt+SC7->C7_FILIAL))
	    cCidade := trim(SM0->M0_CIDENT)
	    cUF     := trim(SM0->M0_ESTENT)
    	SM0->(RestArea(aSM0))
        
        // -> Pega dados da unidade de destino
        cEmDest:= ""
        ADK->(dbSetOrder(3))
        if ADK->(dbSeek(xFilial("ADK")+SA2->A2_CGC))
        	If empty(ADK->ADK_EMAIL)
        		cEmDest:= trim(ADK->ADK_EMAIL)
        	Else
        		SA3->(dbSetOrder(1))
        		If SA3->(dbSeek(xFilial("SA3")+ADK->ADK_RESP)) .and. !empty(SA3->A3_EMAIL)
        			cEmDest:= trim(SA3->A3_EMAIL)
        		EndIf
        	Endif
        Endif
        If !empty(SA2->A2_EMAIL)
        	if !empty(cEmDest)
        		cEmDest += ";"
        	Endif
        	cEmDest += trim(SA2->A2_EMAIL)
        EndIf
        
        // -> Se não existir e-mail para enviar
        if empty(cEmDest)
	    	aadd(aRet,{SC7->C7_FILIAL,SC7->C7_NUM,"SC7",SC7->C7_NUM,"Nao encontrado endereco de e-mail: [ADK_EMAIL = Vazio / ADK_RESP ou A3_EMAIL = Vazio / A2_EMAIL = Vazio]"})
        	// -> Atualiza pedido de compra
        	RecLock("SC7", .f.)
        	SC7->C7_XEMAIL := 'S'
        	SC7->(MsUnlock()) 
        Endif
        
        // -> Se ocorreu erro, sai da função
        If Len(aRet) > 0
           Return(aRet)
        EndIf
        
		// -> Gera pedido para enviar por e-mail
		lTRepInUse := .T.		
		oReport:= ReportDef(nReg, nOpcx)
		oReport:nDevice := 6
	    
        //#TB20191121 Thiago Berna - Ajuste para colocar a filial no nome
        //oReport:cFile   := trim(SC7->C7_NUM)
		//ferase(GetTempPath() + 'totvsprinter\'+trim(SC7->C7_NUM)+".pdf")
        oReport:cFile   := UPPER(AllTrim(SC7->C7_FILIAL)) + trim(SC7->C7_NUM)
        ferase(GetTempPath() + 'totvsprinter\' + UPPER(AllTrim(SC7->C7_FILIAL)) + trim(SC7->C7_NUM)+".pdf")

		oReport:SetPreview(.f.)
		oReport:SetViewPDF(.F.)
		oReport:Print(.f.)
		
		// -> Aguarda geração do PDF
		nAux:=1
		//#TB20191121 Thiago Berna - Ajuste para colocar a filial no nome
        //While !File(GetTempPath()+'totvsprinter\'+trim(SC7->C7_NUM)+".pdf") .and. nAux <= 5000
        While !File(GetTempPath()+'totvsprinter\' +  oReport:cFile +".pdf") .and. nAux <= 5000
		   nAux:=nAux+1
		EndDo

		// -> Envia arquivo por e-mail
		//#TB20191121 Thiago Berna - Ajuste para colocar a filial no nome
        //If File(GetTempPath()+'totvsprinter\'+trim(SC7->C7_NUM)+".pdf")
		    //cAnexo:=GetTempPath()+'totvsprinter\'+trim(SC7->C7_NUM)+".pdf"
	    If File(GetTempPath()+'totvsprinter\' +  oReport:cFile +".pdf")
		    cAnexo:=GetTempPath()+'totvsprinter\'+  oReport:cFile +".pdf" 
            
            cSubj  := 'Pedido de Compra MADERO no. '+SC7->C7_NUM
		    cCorpo := ''
	        cCorpo += '<html>'
	        cCorpo += 	'<head>'
	        cCorpo += 		'<META http-equiv="Content-Type" content="text/html; charset=UTF-8">'
	        cCorpo += 		'<title>Pedido de Compra Madeiro</title>'
	        cCorpo += 	'</head>'
	        cCorpo += 	'<body>'
	        cCorpo += 		'<p>Prezado(s),</p>'
	        cCorpo += 		'<p/>'
	        cCorpo += 		'<p>Segue anexo pedido de compra da empresa MADERO para entrega em '+ ;
	        					cCidade + ' - ' + cUF + ', conforme condições negociadas. </p>'
	        cCorpo += 		'<p/>'
	        cCorpo += 		'<p/>'
	        cCorpo += 		'<p>Att.,</p>'
	        cCorpo += 		'<p/>'
	        cCorpo += 		'<p/>'
	        cCorpo +=         '<p>' + trim(SY1->Y1_NOME) + '</p>'
	        if !empty(SY1->Y1_TEL)
	        	cCorpo +=         '<p>' + trim(SY1->Y1_TEL) + '</p>'
	        EndIf
	        cCorpo +=         '<p>' + trim(SY1->Y1_EMAIL) + '</p>'
	        cCorpo +=  '</body>'
	        cCorpo += '</html>'
	        
			// -> Envia e-mail
		    aRetMail:=SendMail(cEmDest,cSubj,cCorpo,cAnexo)
		    if !aRetMail[1]
		    	aadd(aRet,{SC7->C7_FILIAL,SC7->C7_NUM,"SC7",SC7->C7_NUM,"Nao foi possivel enviar e-mail: "+aRetMail[2]})
		    Endif 
		Else
	    	aadd(aRet,{SC7->C7_FILIAL,SC7->C7_NUM,"SC7",SC7->C7_NUM,"Nao foi possivel gerar o DPF para envio do e-mail: "+GetTempPath()+'totvsprinter\'+trim(SC7->C7_NUM)+".pdf"})
		EndIf
	Endif
	
	// -> Se for da tela, exibe erro
	cAux:=""
	If AllTrim(FunName()) == "MATA121" .and. Len(aRet) > 0
		For nw:=1 to Len(aRet)
			cAux+=aRet[nw,5]+Chr(13)+Chr(10)
		Next nw
		Alert(cAux)
	EndIf	
	
Return aRet


/*-----------------+---------------------------------------------------------+
!Nome              ! SendMail - Cliente: Madero                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Envio e-mail                                            !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 29/05/2018                                              !
+------------------+--------------------------------------------------------*/
static Function SendMail(cEmailTo,cAssunto,cMensagem,cAttach)
Local cAccount,cPassword,cServer,cFrom
Local cEmailBcc:= ""
Local lResult  := .F.
Local cError   := ""
Local lAuth    := GetMv("MV_RELAUTH",,.F.)
default cEmailTo := ""

    lAuth := .t.
    cEmailTo := cEmailTo
    // Verifica se serao utilizados os valores padrao.
    cAccount	:= GetMV( "MV_RELACNT" )
    cPassword	:= GetMV( "MV_RELPSW"  )
    cServer		:= GetMV( "MV_RELSERV" )
    cFrom		:= cAccount
    cAttach		:= Iif( cAttach == NIL, "", cAttach )
    if !file(cAttach)
    	cAttach := ''
    Else
        cpyt2s(cAttach,'\temp\',.t.)
        cAttach := '\temp'+substr(cAttach,rat('\',cAttach), 200)
        if !file(cAttach)
            cAttach := ''
        EndIf
    EndIf

    CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult 

    If lAuth 
        lResult := Mailauth(cAccount,cPassword)
    Endif

    If lResult           
        if empty(cAttach)
            SEND MAIL	FROM cFrom ;
            TO      	cEmailTo ;
            BCC     	cEmailBcc ;
            SUBJECT 	cAssunto ;
            BODY    	cMensagem ; // FORMAT HTML;
            RESULT 		lResult
        else
            SEND MAIL	FROM cFrom ;
            TO      	cEmailTo ;
            BCC     	cEmailBcc ;
            SUBJECT 	cAssunto ;
            BODY    	cMensagem ; // FORMAT HTML;
            ATTACHMENT  cAttach ;
            RESULT 		lResult
        EndIf

        If !lResult
            //Erro no envio do email
            GET MAIL ERROR cError
        EndIf
        
        DISCONNECT SMTP SERVER
        
    Else
        //Erro na conexao com o SMTP Server
        GET MAIL ERROR cError
    EndIf
    if file(cAttach)
        ferase(cAttach)
    Endif

Return {lResult,cError}


/*-----------------+---------------------------------------------------------+
!Nome              ! ReportDef - Cliente: Madero                             !
+------------------+---------------------------------------------------------+
!Descrição         ! Definicao do Relatorio                                  !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 29/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function ReportDef(nReg,nOpcx)

Local cTitle   := "Emissao dos Pedidos de Compras ou Autorizacoes de Entrega"
Local oReport
Local oSection1
Local oSection2
Local nTamCdProd:= TamSX3("C7_PRODUTO")[1]


    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Variaveis utilizadas para parametros                         ³
    //³ mv_par01               Do Pedido                             ³
    //³ mv_par02               Ate o Pedido                          ³
    //³ mv_par03               A partir da data de emissao           ³
    //³ mv_par04               Ate a data de emissao                 ³
    //³ mv_par05               Somente os Novos                      ³
    //³ mv_par06               Campo Descricao do Produto    	     ³
    //³ mv_par07               Unidade de Medida:Primaria ou Secund. ³
    //³ mv_par08               Imprime ? Pedido Compra ou Aut. Entreg³
    //³ mv_par09               Numero de vias                        ³
    //³ mv_par10               Pedidos ? Liberados Bloqueados Ambos  ³
    //³ mv_par11               Impr. SC's Firmes, Previstas ou Ambas ³
    //³ mv_par12               Qual a Moeda ?                        ³
    //³ mv_par13               Endereco de Entrega                   ³
    //³ mv_par14               todas ou em aberto ou atendidos       ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Pergunte("MTR110",.F.)
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Criacao do componente de impressao                                      ³
    //³                                                                        ³
    //³TReport():New                                                           ³
    //³ExpC1 : Nome do relatorio                                               ³
    //³ExpC2 : Titulo                                                          ³
    //³ExpC3 : Pergunte                                                        ³
    //³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
    //³ExpC5 : Descricao                                                       ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//    conOut("Gerar arquivo "+"PC_"+trim(SC7->C7_FILIAL)+"_"+SC7->C7_NUM)
    oReport:= TReport():New("MATR110",cTitle,"MTR110", {|oReport| ReportPrint(oReport,nReg,nOpcx)},"Emissao dos pedidos de compras ou autorizacoes de entrega cadastrados e que ainda nao foram impressos")
    oReport:SetPortrait()
    oReport:HideParamPage()
    oReport:HideHeader()
    oReport:HideFooter()
    oReport:SetTotalInLine(.F.)
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Criacao da secao utilizada pelo relatorio                               ³
    //³                                                                        ³
    //³TRSection():New                                                         ³
    //³ExpO1 : Objeto TReport que a secao pertence                             ³
    //³ExpC2 : Descricao da seçao                                              ³
    //³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
    //³        sera considerada como principal para a seção.                   ³
    //³ExpA4 : Array com as Ordens do relatório                                ³
    //³ExpL5 : Carrega campos do SX3 como celulas                              ³
    //³        Default : False                                                 ³
    //³ExpL6 : Carrega ordens do Sindex                                        ³
    //³        Default : False                                                 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Criacao da celulas da secao do relatorio                                ³
    //³                                                                        ³
    //³TRCell():New                                                            ³
    //³ExpO1 : Objeto TSection que a secao pertence                            ³
    //³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
    //³ExpC3 : Nome da tabela de referencia da celula                          ³
    //³ExpC4 : Titulo da celula                                                ³
    //³        Default : X3Titulo()                                            ³
    //³ExpC5 : Picture                                                         ³
    //³        Default : X3_PICTURE                                            ³
    //³ExpC6 : Tamanho                                                         ³
    //³        Default : X3_TAMANHO                                            ³
    //³ExpL7 : Informe se o tamanho esta em pixel                              ³
    //³        Default : False                                                 ³
    //³ExpB8 : Bloco de código para impressao.                                 ³
    //³        Default : ExpC2                                                 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    oSection1:= TRSection():New(oReport,"Pedido de Compras / Autorização de Entrega" ,{"SC7","SM0","SA2"},/*aOrdem*/) //"| P E D I D O  D E  C O M P R A S"
    oSection1:SetLineStyle()
    oSection1:SetReadOnly()

    TRCell():New(oSection1,"M0_NOMECOM","SM0","Empresa:"      ,/*Picture*/,49,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"A2_NOME"   ,"SA2",/*Titulo*/   ,/*Picture*/,40,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"A2_COD"    ,"SA2",/*Titulo*/   ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"A2_LOJA"   ,"SA2",/*Titulo*/   ,/*Picture*/,04,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"M0_ENDENT" ,"SM0","Endereco:"       ,/*Picture*/,48,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"A2_END"    ,"SA2",/*Titulo*/   ,/*Picture*/,40,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"A2_BAIRRO" ,"SA2",/*Titulo*/   ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"M0_CEPENT" ,"SM0","CEP:"       ,/*Picture*/,10,/*lPixel*/,{|| Trans(SM0->M0_CEPENT,PesqPict("SA2","A2_CEP")) })
    TRCell():New(oSection1,"M0_CIDENT" ,"SM0","Cidade:"      ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"M0_ESTENT" ,"SM0","UF:"       ,/*Picture*/,11,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"A2_MUN"    ,"SA2",/*Titulo*/   ,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"A2_EST"    ,"SA2",/*Titulo*/   ,/*Picture*/,02,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"A2_CEP"    ,"SA2",/*Titulo*/   ,/*Picture*/,08,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"A2_CGC"    ,"SA2",/*Titulo*/   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"M0_TEL"    ,"SM0","TEL:"       ,/*Picture*/,14,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"M0_FAX"    ,"SM0","FAX:"       ,/*Picture*/,34,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oSection1,"FONE"      ,"   ","FONE:"       ,/*Picture*/,25,/*lPixel*/,{|| "("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15)})
    TRCell():New(oSection1,"FAX"       ,"   ","FAX:"       ,/*Picture*/,25,/*lPixel*/,{|| "("+Substr(SA2->A2_DDD,1,3)+") "+SubStr(SA2->A2_FAX,1,15)})
    TRCell():New(oSection1,"INSCR"     ,"   ","Ins. Estad.:" ,/*Picture*/,18,/*lPixel*/,{|| SA2->A2_INSCR })
    TRCell():New(oSection1,"M0_CGC"    ,"SM0","CNPJ/CPF"      ,/*Picture*/,18,/*lPixel*/,{|| Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC")) })
    TRCell():New(oSection1,"M0IE"  ,"   ","IE:"       ,/*Picture*/,18,/*lPixel*/,{|| InscrEst()})

    oSection1:Cell("A2_BAIRRO"):SetCellBreak()
    oSection1:Cell("A2_CGC"   ):SetCellBreak()
    oSection1:Cell("INSCR"    ):SetCellBreak()
    oSection2:= TRSection():New(oSection1, "Pedido de Compras / Autorização de Entrega (Produtos)", {"SC7","SB1"}, /* <aOrder> */ ,;
								 /* <.lLoadCells.> */ , , /* <cTotalText>  */, /* !<.lTotalInCol.>  */, /* <.lHeaderPage.>  */,;
								 /* <.lHeaderBreak.> */, /* <.lPageBreak.>  */, /* <.lLineBreak.>  */, /* <nLeftMargin>  */,;
								 /* <.lLineStyle.>  */, /* <nColSpace>  */, /*<.lAutoSize.> */, /*<cSeparator> */,;
								 /*<nLinesBefore>  */, /*<nCols>  */, /* <nClrBack> */, /* <nClrFore>  */)
    oSection2:SetCellBorder("ALL",,,.T.)
    oSection2:SetCellBorder("RIGHT")
    oSection2:SetCellBorder("LEFT")

    TRCell():New(oSection2,"C7_ITEM"    ,"SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
    TRCell():New(oSection2,"C7_PRODUTO" ,"SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| cCodProd },,,,,,.F.)
    TRCell():New(oSection2,"DESCPROD"   ,"   ","Descricao"    ,/*Picture*/,30,/*lPixel*/, {|| cDescPro},,,,,,.F.)
    TRCell():New(oSection2,"C7_UM"      ,"SC7","UM"    ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
    TRCell():New(oSection2,"C7_QUANT"   ,"SC7",/*Titulo*/,PesqPictQt("C7_QUANT",13),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
    TRCell():New(oSection2,"C7_SEGUM"   ,"SC7","2a.UM",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
    TRCell():New(oSection2,"C7_QTSEGUM" ,"SC7",/*Titulo*/,PesqPictQt("C7_QUANT",13),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
    TRCell():New(oSection2,"PRECO"      ,"   ","Valor Unitario" ,/*Picture*/,16/*Tamanho*/,/*lPixel*/,{|| nVlUnitSC7 },"RIGHT",,"RIGHT")
    TRCell():New(oSection2,"C7_IPI"     ,"SC7",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
    TRCell():New(oSection2,"TOTAL"      ,"   ","Valor Total",/*Picture*/,14/*Tamanho*/,/*lPixel*/,{|| nValTotSC7 },"RIGHT",,"RIGHT",,,.F.)
    TRCell():New(oSection2,"C7_DATPRF"  ,"SC7","Dt. Entrega"/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
    TRCell():New(oSection2,"C7_CC"      ,"SC7","CC " ,PesqPict("SC7","C7_CC",20),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
    TRCell():New(oSection2,"C7_NUMSC"   ,"SC7","Nro.SC" ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
    TRCell():New(oSection2,"OPCC"       ,"   ","Numero da OP ou CC"    ,/*Picture*/,30.5,/*lPixel*/,{|| cOPCC },,,,,,.F.)

    oSection2:Cell("C7_PRODUTO"):SetLineBreak()
    oSection2:Cell("DESCPROD"):SetLineBreak()
    oSection2:Cell("C7_CC"):SetLineBreak()
    oSection2:Cell("OPCC"):SetLineBreak()

    If nTamCdProd > 15
        oSection2:Cell("C7_IPI"):SetTitle("% IPI")
    EndIf

Return(oReport)

/*-----------------+---------------------------------------------------------+
!Nome              ! ReportPrint - Cliente: Madero                           !
+------------------+---------------------------------------------------------+
!Descrição         ! Impressao do Relatorio                                  !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 29/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function ReportPrint(oReport,nReg,nOpcX)

Local oSection1   	:= oReport:Section(1)
Local oSection2   	:= oReport:Section(1):Section(1)
Local aRecnoSave  	:= {}
Local aPedido     	:= {}
Local aPedMail    	:= {}
Local aValIVA     	:= {}
Local cFilSC7     	:= SC7->C7_FILIAL
Local cNumSC7		:= Len(SC7->C7_NUM)
Local cCondicao		:= ""
Local cFiltro		:= ""
Local cComprador	:= ""
LOcal cAlter		:= ""
Local cAprov		:= ""
Local cTipoSC7		:= ""
Local cCondBus		:= ""
Local cMensagem		:= ""
Local cVar			:= ""
Local cPictVUnit	:= PesqPict("SC7","C7_PRECO",16)
Local cPictVTot		:= PesqPict("SC7","C7_TOTAL",, mv_par12)
Local lNewAlc		:= .F.
Local lLiber		:= .F.
Local nRecnoSC7   	:= 0
Local nRecnoSM0   	:= 0
Local nX          	:= 0
Local nY          	:= 0
Local nVias       	:= 0
Local nTxMoeda    	:= 0
Local nTpImp	  	:= IIF(ValType(oReport:nDevice)!=Nil,oReport:nDevice,0) // Tipo de Impressao
Local nPageWidth  	:= IIF(nTpImp==1.Or.nTpImp==6,2314,2290) // oReport:PageWidth()
Local nPrinted    	:= 0
Local nValIVA     	:= 0
Local nTotIpi	  	:= 0
Local nTotIcms	  	:= 0
Local nTotDesp	  	:= 0
Local nTotFrete	  	:= 0
Local nTotalNF	  	:= 0
Local nTotSeguro  	:= 0
Local nLinPC	  	:= 0
Local nLinObs     	:= 0
Local nDescProd   	:= 0
Local nTotal      	:= 0
Local nTotMerc    	:= 0
Local nPagina     	:= 0
Local nOrder      	:= 1
Local cUserId     	:= RetCodUsr()
Local cCont       	:= Nil
Local lImpri      	:= .F.
Local cCident	  	:= ""
Local cCidcob	  	:= ""
Local nLinPC2	  	:= 0
Local nLinPC3	  	:= 0
Local nTamCdProd	:= TamSX3("C7_PRODUTO")[1]
Local nTamQtd   	:= TamSX3("C7_QUANT")[1]
Local nTamanCorr	:=148 // tamanho correto do final da linha
Local nTotalCpos	:= 0//tamanho atual do final da linha
Local lArrumou		:= .F.
//Arrays abaixo 	:= {Campo		,oSection2,Tamanho Minimo	,  Tamanho Maximo}
Local aTamItem		:= {"C7_ITEM"	,0,TamSX3("C7_ITEM")[1]		,TamSX3("C7_ITEM")[1]+5}
Local aTamProd 		:= {"C7_PRODUTO",0,IIf(nTamCdProd<30,nTamCdProd+(30-nTamCdProd),30),50}
Local aTamCdDesc	:= {"DESCPROD"	,0,TamSX3("B1_DESC")[1]		,TamSX3("B1_DESC")[1]+30}
Local aTamUm		:= {"C7_UM"		,0,TamSX3("C7_UM")[1]		,TamSX3("C7_UM")[1]+5}
Local aTamQuant 	:= {"C7_QUANT"	,0,IIf(nTamQtd<12,nTamQtd+(12-nTamQtd),12),12}
Local aTamSeg		:= {"C7_SEGUM"	,0,TamSX3("C7_SEGUM")[1]	,TamSX3("C7_SEGUM")[1]+5}
Local aTamqtseg		:= {"C7_QTSEGUM",0,TamSX3("C7_QTSEGUM")[1]	,TamSX3("C7_QTSEGUM")[1]}
Local aTamprec 		:= {"PRECO"		,0,16						,30}
Local aTamIpi   	:= {"C7_IPI"	,0,TamSX3("C7_IPI")[1]		,TamSX3("C7_IPI")[1]}
Local aTamTot 		:= {"TOTAL"		,0,14						,25}
Local aTamDaTp		:= {"C7_DATPRF"	,0,TamSX3("C7_DATPRF")[1]	,IIf(TamSX3("C7_DATPRF")[1]+5 < 11,11,TamSX3("C7_DATPRF")[1]+5)}
Local aTamCC 		:= {"C7_CC"		,0,9						,15}
Local aTamNum		:= {"C7_NUMSC"	,0,TamSX3("C7_NUMSC")[1]	,TamSX3("C7_NUMSC")[1]+10}
//                     1*       2*        3*       4*       5*       6*      7*        8*      9*      10*      11*    12*     13*
Local aTamCamp 		:= {aTamItem,aTamProd,aTamCdDesc,aTamUm,aTamQuant,aTamSeg,aTamqtseg,aTamprec,aTamIpi,aTamTot,aTamDaTp,aTamCC,aTamNum}
Local nDeslV    	:= 516    // Deslocamento vertical -- ajuste do relatório para MADERO
For nX:= 1 To Len(aTamCamp)
    aTamCamp[nX][2] :=oSection2:Cell(aTamCamp[nX][1]):GetCellSize()
Next
Private cDescPro  := ""
Private cCodProd  := ""
Private cOPCC     := ""
Private	nVlUnitSC7:= 0
Private nValTotSC7:= 0
Private cObs01    := ""
Private cObs02    := ""
Private cObs03    := ""
Private cObs04    := ""
Private cObs05    := ""
Private cObs06    := ""
Private cObs07    := ""
Private cObs08    := ""
Private cObs09    := ""
Private cObs10    := ""
Private cObs11    := ""
Private cObs12    := ""
Private cObs13    := ""
Private cObs14    := ""
Private cObs15    := ""
Private cObs16    := ""
    
    nPageWidth += 100
    If Type("lPedido") != "L"
        lPedido := .F.
    Endif

    If nTpImp==1 .Or. nTpImp==6
        oSection2:ACELL[2]:NSIZE:=20
        oSection2:ACELL[3]:NSIZE:=20
        oSection2:ACELL[14]:NSIZE:=25
    EndIf

    dbSelectArea("SC7")

    If lAuto
        dbSelectArea("SC7")
        dbGoto(nReg)
        mv_par01 := SC7->C7_NUM
        mv_par02 := SC7->C7_NUM
        mv_par03 := SC7->C7_EMISSAO
        mv_par04 := SC7->C7_EMISSAO
        mv_par05 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","05"),If(cCont == Nil,2,cCont) })
        mv_par08 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","08"),If(cCont == Nil,C7_TIPO,cCont) })
        mv_par09 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","09"),If(cCont == Nil,1,cCont) })
        mv_par10 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","10"),If(cCont == Nil,3,cCont) })
        mv_par11 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","11"),If(cCont == Nil,3,cCont) })
        mv_par14 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","14"),If(cCont == Nil,1,cCont) })
    Else
        MakeAdvplExpr(oReport:uParam)

        cCondicao := 'C7_FILIAL=="'       + cFilSC7 + '".And.'
        cCondicao += 'C7_NUM>="'          + mv_par01       + '".And.C7_NUM<="'          + mv_par02 + '".And.'
        cCondicao += 'Dtos(C7_EMISSAO)>="'+ Dtos(mv_par03) +'".And.Dtos(C7_EMISSAO)<="' + Dtos(mv_par04) + '"'

        oReport:Section(1):SetFilter(cCondicao,IndexKey())
    EndIf

    If lPedido
        mv_par12 := MAX(SC7->C7_MOEDA,1)
    Endif

    If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
        cCondBus := mv_par01
        nOrder	 := 1
    Else
        cCondBus := "2"+StrZero(Val(mv_par01),6)
        nOrder	 := 10
    EndIf

    If mv_par14 == 2
        cFiltro := "SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)"
    Elseif mv_par14 == 3
        cFiltro := "SC7->C7_QUANT > SC7->C7_QUJE"
    EndIf

    oSection2:Cell("PRECO"):SetPicture(cPictVUnit)
    oSection2:Cell("TOTAL"):SetPicture(cPictVTot)

    TRPosition():New(oSection2,"SB1",1,{ || xFilial("SB1") + SC7->C7_PRODUTO })
    TRPosition():New(oSection2,"SB5",1,{ || xFilial("SB5") + SC7->C7_PRODUTO })

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Executa o CodeBlock com o PrintLine da Sessao 1 toda vez que rodar o oSection1:Init()   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    oReport:onPageBreak( { || nPagina++ , nPrinted := 0 , CabecPCxAE(oReport,oSection1,nVias,nPagina) })

    oReport:SetMeter(SC7->(LastRec()))
    dbSelectArea("SC7")
    dbSetOrder(nOrder)
    dbSeek(cFilSC7+cCondBus,.T.)

    oSection2:Init()

    cNumSC7 := SC7->C7_NUM

    While !oReport:Cancel() .And. !SC7->(Eof()) .And. SC7->C7_FILIAL == cFilSC7 .And. SC7->C7_NUM >= mv_par01 .And. SC7->C7_NUM <= mv_par02

        If (SC7->C7_CONAPRO == "B" .And. mv_par10 == 1) .Or.;
            (SC7->C7_CONAPRO <> "B" .And. mv_par10 == 2) .Or.;
            (SC7->C7_EMITIDO == "S" .And. mv_par05 == 1) .Or.;
            ((SC7->C7_EMISSAO < mv_par03) .Or. (SC7->C7_EMISSAO > mv_par04)) .Or.;
            ((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3) .And. mv_par08 == 2) .Or.;
            (SC7->C7_TIPO == 2 .And. (mv_par08 == 1 .OR. mv_par08 == 3)) .Or. !MtrAValOP(mv_par11, "SC7") .Or.;
            (SC7->C7_QUANT > SC7->C7_QUJE .And. mv_par14 == 3) .Or.;
            ((SC7->C7_QUANT - SC7->C7_QUJE <= 0 .Or. !Empty(SC7->C7_RESIDUO)) .And. mv_par14 == 2 )

            dbSelectArea("SC7")
            dbSkip()
            Loop
        Endif

        If oReport:Cancel()
            Exit
        EndIf

        MaFisEnd()
        R110FIniPC(SC7->C7_FILIAL,SC7->C7_NUM,,,cFiltro)

        cObs01    := " "
        cObs02    := " "
        cObs03    := " "
        cObs04    := " "
        cObs05    := " "
        cObs06    := " "
        cObs07    := " "
        cObs08    := " "
        cObs09    := " "
        cObs10    := " "
        cObs11    := " "
        cObs12    := " "
        cObs13    := " "
        cObs14    := " "
        cObs15    := " "
        cObs16    := " "

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Roda a impressao conforme o numero de vias informado no mv_par09 ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        For nVias := 1 to mv_par09

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Dispara a cabec especifica do relatorio.                     ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            oReport:EndPage()

            nPagina  := 0
            nPrinted := 0
            nTotal   := 0
            nTotMerc := 0
            nDescProd:= 0
            nLinObs  := 0
            nRecnoSC7:= SC7->(Recno())
            cNumSC7  := SC7->C7_NUM
            aPedido  := {SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_EMISSAO,SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_TIPO}

            While !oReport:Cancel() .And. !SC7->(Eof()) .And. SC7->C7_FILIAL == cFilSC7 .And. SC7->C7_NUM == cNumSC7

                If (SC7->C7_CONAPRO == "B" .And. mv_par10 == 1) .Or.;
                    (SC7->C7_CONAPRO <> "B" .And. mv_par10 == 2) .Or.;
                    (SC7->C7_EMITIDO == "S" .And. mv_par05 == 1) .Or.;
                    ((SC7->C7_EMISSAO < mv_par03) .Or. (SC7->C7_EMISSAO > mv_par04)) .Or.;
                    ((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3) .And. mv_par08 == 2) .Or.;
                    (SC7->C7_TIPO == 2 .And. (mv_par08 == 1 .OR. mv_par08 == 3)) .Or. !MtrAValOP(mv_par11, "SC7") .Or.;
                    (SC7->C7_QUANT > SC7->C7_QUJE .And. mv_par14 == 3) .Or.;
                    ((SC7->C7_QUANT - SC7->C7_QUJE <= 0 .Or. !Empty(SC7->C7_RESIDUO)) .And. mv_par14 == 2 )
                    dbSelectArea("SC7")
                    dbSkip()
                    Loop
                Endif

                If oReport:Cancel()
                    Exit
                EndIf

                oReport:IncMeter()

                If oReport:Row() > oReport:LineHeight() * 100
                    oReport:Box( oReport:Row(),010,oReport:Row() + oReport:LineHeight() * 3, nPageWidth )
                    oReport:SkipLine()
                    oReport:PrintText("Continua na Proxima Pagina .... " ,, 050 ) // Continua na Proxima pagina ....
                    oReport:EndPage()
                EndIf

                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Salva os Recnos do SC7 no aRecnoSave para marcar reimpressao.³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                If Ascan(aRecnoSave,SC7->(Recno())) == 0
                    AADD(aRecnoSave,SC7->(Recno()))
                Endif

                cCodProd := ""
                cCodProd := trim(SC7->C7_PRODUTO)
                // Codigo do produto
                if SC7->(FieldPos("C7_XCODPRF"))> 0 .and. !empty(SC7->C7_XCODPRF)
                    cCodProd := trim(SC7->C7_XCODPRF)
                Endif

                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Inicializa o descricao do Produto conf. parametro digitado.³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                cDescPro :=  ""
                If Empty(mv_par06)
                    mv_par06 := "B1_DESC"
                EndIf
                If AllTrim(mv_par06) == "B1_DESC"
                    SB1->(dbSetOrder(1))
                    SB1->(dbSeek( xFilial("SB1") + SC7->C7_PRODUTO ))
                    cDescPro := SB1->B1_DESC
                ElseIf AllTrim(mv_par06) == "B5_CEME"
                    SB5->(dbSetOrder(1))
                    If SB5->(dbSeek( xFilial("SB5") + SC7->C7_PRODUTO ))
                        cDescPro := SB5->B5_CEME
                    EndIf
                ElseIf AllTrim(mv_par06) == "C7_DESCRI"
                    cDescPro := SC7->C7_DESCRI
                EndIf

                If Empty(cDescPro)
                    SB1->(dbSetOrder(1))
                    SB1->(dbSeek( xFilial("SB1") + SC7->C7_PRODUTO ))
                    cDescPro := SB1->B1_DESC
                EndIf

                SA5->(dbSetOrder(1))
                If SA5->(dbSeek(xFilial("SA5")+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO)) .And. !Empty(SA5->A5_CODPRF)
//                    cDescPro := cDescPro + " ("+Alltrim(SA5->A5_CODPRF)+")"
                    cCodProd := trim(SA5->A5_CODPRF)
                EndIf

                if !Empty(C7_XOBS)
                    cDescPro := trim(cDescPro) + " – " +C7_XOBS
                EndIf

                If SC7->C7_DESC1 != 0 .Or. SC7->C7_DESC2 != 0 .Or. SC7->C7_DESC3 != 0
                    nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
                Else
                    nDescProd+=SC7->C7_VLDESC
                Endif
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Inicializacao da Observacao do Pedido.                       ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                If !Empty(SC7->C7_OBS) .And. nLinObs < 17
                    nLinObs++
                    cVar:="cObs"+StrZero(nLinObs,2)
                    Eval(MemVarBlock(cVar),SC7->C7_OBS)
                Endif

                nTxMoeda   := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
                nValTotSC7 := xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)

                nTotal     := nTotal + SC7->C7_TOTAL
                nTotMerc   := MaFisRet(,"NF_TOTAL")

                If MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM) .And. !Empty(SC7->C7_SEGUM)
                    //oSection2:Cell("C7_DATPRF"):SetSize(9)
                    oSection2:Cell("C7_SEGUM"  ):Enable()
                    oSection2:Cell("C7_QTSEGUM"):Enable()
                    oSection2:Cell("C7_UM"     ):Disable()
                    oSection2:Cell("C7_QUANT"  ):Disable()
                    nVlUnitSC7 := xMoeda((SC7->C7_TOTAL/SC7->C7_QTSEGUM),SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
                ElseIf MV_PAR07 == 1 .And. !Empty(SC7->C7_QUANT) .And. !Empty(SC7->C7_UM)
                    //oSection2:Cell("C7_DATPRF"):SetSize(11)
                    oSection2:Cell("C7_SEGUM"  ):Disable()
                    oSection2:Cell("C7_QTSEGUM"):Disable()
                    oSection2:Cell("C7_UM"     ):Enable()
                    oSection2:Cell("C7_QUANT"  ):Enable()
                    nVlUnitSC7 := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
                Else
                    nTamanCorr  :=143
                    //oSection2:Cell("C7_DATPRF"):SetSize(11)
                    oSection2:Cell("C7_SEGUM"  ):Enable()
                    oSection2:Cell("C7_QTSEGUM"):Enable()
                    oSection2:Cell("C7_UM"     ):Enable()
                    oSection2:Cell("C7_QUANT"  ):Enable()
                    nVlUnitSC7 := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
                EndIf

                If mv_par08 == 2
                    oSection2:Cell("C7_IPI" ):Disable()
                EndIf

                If mv_par08 == 1 .OR. mv_par08 == 3
                    oSection2:Cell("OPCC"):Disable()
                Else
                    oSection2:Cell("C7_DATPRF"):SetSize(9)
                    oSection2:Cell("C7_CC"):Disable()
                    oSection2:Cell("C7_NUMSC"):Disable()
                    If !Empty(SC7->C7_OP)
                        cOPCC := "OP "  + " " + SC7->C7_OP
                    ElseIf !Empty(SC7->C7_CC)
                        cOPCC := "CC "  + " " + SC7->C7_CC
                    EndIf
                EndIf
                nTamanCorr := IIF(oReport:nDevice == 2,nTamanCorr-2,nTamanCorr)  // se for impressão por spool diminuir o tamanho da linha
/*********
                    //Ajusta o tamanho dos campos de acordo com o tamanho do relatorio
                    If !lArrumou .And. !oSection2:UseFilter()
                        lArrumou := .T.
                        For nX:= 1 To Len(aTamCamp)
                            If oSection2:Cell(aTamCamp[nX][1]):Enabled()
                                nTotalCpos +=aTamCamp[nX][2]
                                nTotalsX3 +=aTamCamp[nX][3]
                            EndIf
                        Next
                        nX:=0

                        //Verifica se é possível realizar ajuste no tamanho dos campos considerando o tamanho físico dos campos no dicionário.
                        If nTotalsX3 > nTamanCorr
                            lRet := .F.
                        EndIf

                        If lRet
                            While nTotalCpos <> nTamanCorr
                                IIf(nX >= Len(aTamCamp),nX:=1,nX++)
                                If oSection2:Cell(aTamCamp[nX][1]):Enabled() //se o campo estiver  Enable
                                    If nTotalCpos > nTamanCorr //se os campos passarem da linha
                                        If aTamCamp[nX][2] >  aTamCamp[nX][3] //Se o campo[nX] estiver maior que o tamanho minimo
                                            aTamCamp[nX][2] -= 1      //diminui o tamanho do campo
                                            nTotalCpos -= 1
                                        EndIf
                                    ElseIf aTamCamp[nX][2] <  aTamCamp[nX][4] //Se o campo[nX] estiver menor que o tamanho maximo
                                        aTamCamp[nX][2] += 1 //aumenta o tamanho do campo
                                        nTotalCpos +=1
                                    Endif
                                Endif
                            EndDo
                        EndIf
                        For nX:= 1 To Len(aTamCamp)
                            If oSection2:Cell(aTamCamp[nX][1]):Enabled()
                                oSection2:Cell(aTamCamp[nX][1]):SetSize(aTamCamp[nX][2])//atualiza o tamanho certo dos campos
                            EndIf
                        Next
                    EndIf
**********/
				oSection2:Cell("C7_ITEM"):SetSize(06)
				oSection2:Cell("DESCPROD"):SetSize(50)
				oSection2:Cell("C7_NUMSC"):SetSize(14.3)
				If MV_PAR07 == 1
					If nTpImp == 6
						oSection2:Cell("C7_DATPRF"):SetSize(23)
						oSection2:Cell("DESCPROD"):SetSize(80)
					EndIF
				ElseIf MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM) .And. !Empty(SC7->C7_SEGUM)
	   				oSection2:Cell("DESCPROD"):SetSize(47)
	   				If nTpImp == 6
						oSection2:Cell("C7_DATPRF"):SetSize(24.7)
						oSection2:Cell("DESCPROD"):SetSize(80)
					EndIF
	   			Else
	   				oSection2:Cell("DESCPROD"):SetSize(32.3)
	   				oSection2:Cell("C7_NUMSC"):SetSize(8)
	   				oSection2:Cell("C7_ITEM"):SetSize(9)
	   				If nTpImp == 6
						oSection2:Cell("C7_DATPRF"):SetSize(14.7)
						oSection2:Cell("DESCPROD"):SetSize(85)
						oSection2:Cell("C7_NUMSC"):SetSize(20.5)
					EndIF
	   			EndIF
	   			
	   			If nTpImp == 6 
					oSection2:Cell("C7_ITEM"):SetSize(10)
					oSection2:Cell("C7_PRODUTO"):SetSize(30)
					oSection2:Cell("C7_UM"):SetSize(08)
					oSection2:Cell("C7_QUANT"):SetSize(30)
//					oSection2:Cell("C7_SEGUM"):SetSize(15)
//					oSection2:Cell("C7_QTSEGUM"):SetSize(30)
					oSection2:Cell("C7_IPI"):SetSize(25)
					oSection2:Cell("TOTAL"):SetSize(25) 
					oSection2:Cell("C7_DATPRF"):SetSize(15)
					oSection2:Cell("C7_CC"):SetSize(15)
				EndIf


                oSection2:PrintLine()

                nPrinted ++
                lImpri  := .T.
                dbSelectArea("SC7")
                dbSkip()

            EndDo

            SC7->(dbGoto(nRecnoSC7))

            If oReport:Row() > oReport:LineHeight() * 68

                oReport:Box( oReport:Row(),010,oReport:Row() + oReport:LineHeight() * 3, nPageWidth )
                oReport:SkipLine()
                oReport:PrintText("Continua na Proxima Pagina .... " ,, 050 ) // Continua na Proxima pagina ....

                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Dispara a cabec especifica do relatorio.                     ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                oReport:EndPage()
                oReport:PrintText(" ",1992+nDeslV , 010 ) // Necessario para posicionar Row() para a impressao do Rodape

//                oReport:Box( 280,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted )+nDeslV , nPageWidth )
                oReport:Box( 280,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )

            Else
//                oReport:Box( oReport:Row(),oReport:Col(),oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted )+nDeslV , nPageWidth )
                oReport:Box( oReport:Row(),oReport:Col(),oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
            EndIf
            
            oReport:Box( 1990+nDeslV ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
            oReport:Box( 2080+nDeslV ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
            oReport:Box( 2200+nDeslV ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
            oReport:Box( 2320+nDeslV ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )

            oReport:Box( 2200+nDeslV , 1080 , 2320+nDeslV , 1400 ) // Box da Data de Emissao
            oReport:Box( 2320+nDeslV ,  010 , 2406+nDeslV , 1220 ) // Box do Reajuste
            oReport:Box( 2320+nDeslV , 1220 , 2460+nDeslV , 1750 ) // Box do IPI e do Frete
            oReport:Box( 2320+nDeslV , 1750 , 2460+nDeslV , nPageWidth ) // Box do ICMS Despesas e Seguro
            oReport:Box( 2406+nDeslV ,  010 , 2700+nDeslV , 1220 ) // Box das Observacoes

            cMensagem:= Formula(C7_MSG)
            If !Empty(cMensagem)
                oReport:SkipLine()
                oReport:PrintText(PadR(cMensagem,129), , oSection2:Cell("DESCPROD"):ColPos() )
            Endif

            oReport:PrintText( "D E S C O N T O S -->"  /*"D E S C O N T O S -->"*/ + " " + ;
            TransForm(SC7->C7_DESC1,"999.99" ) + " %    " + ;
            TransForm(SC7->C7_DESC2,"999.99" ) + " %    " + ;
            TransForm(SC7->C7_DESC3,"999.99" ) + " %    " + ;
            TransForm(xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , PesqPict("SC7","C7_VLDESC",14, MV_PAR12) ),;
            2022+nDeslV , 050 )

            oReport:SkipLine()
            oReport:SkipLine()
            oReport:SkipLine()

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Posiciona o Arquivo de Empresa SM0.                          ³
            //³ Imprime endereco de entrega do SM0 somente se o MV_PAR13 =" "³
            //³ e o Local de Cobranca :                                      ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            SM0->(dbSetOrder(1))
            nRecnoSM0 := SM0->(Recno())
            SM0->(dbSeek(SUBS(cNumEmp,1,2)+SC7->C7_FILENT))

            cCident := IIF(len(SM0->M0_CIDENT)>20,Substr(SM0->M0_CIDENT,1,15),SM0->M0_CIDENT)
            cCidcob := IIF(len(SM0->M0_CIDCOB)>20,Substr(SM0->M0_CIDCOB,1,15),SM0->M0_CIDCOB)

            If Empty(MV_PAR13) //"Local de Entrega  : "
                oReport:PrintText("Local de Entrega  : "  + SM0->M0_ENDENT+"  "+Rtrim(SM0->M0_CIDENT)+"  - "+SM0->M0_ESTENT+" - "+"CEP :" +" "+Trans(Alltrim(SM0->M0_CEPENT),PesqPict("SA2","A2_CEP")),, 050 )
            Else
                oReport:PrintText("Local de Entrega  : "  + mv_par13,, 050 ) //"Local de Entrega  : " imprime o endereco digitado na pergunte
            Endif
            SM0->(dbGoto(nRecnoSM0))
            oReport:PrintText("Local de Cobranca : "  + SM0->M0_ENDCOB+"  "+Rtrim(SM0->M0_CIDCOB)+"  - "+SM0->M0_ESTCOB+" - "+"CEP :" +" "+Trans(Alltrim(SM0->M0_CEPCOB),PesqPict("SA2","A2_CEP")),, 050 )

            oReport:SkipLine()
            oReport:SkipLine()

            SE4->(dbSetOrder(1))
            SE4->(dbSeek(xFilial("SE4")+SC7->C7_COND))

            nLinPC := oReport:Row()
            oReport:PrintText( "Condicao de Pagto " +SubStr(SE4->E4_COND,1,40),nLinPC,050 )
            oReport:PrintText( "Data de Emissao" ,nLinPC,1120 ) //"Data de Emissao"
            oReport:PrintText( "Total das Mercadorias : "  +" "+ Transform(xMoeda(nTotal,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotal,14,MsDecimais(MV_PAR12)) ),nLinPC,1612 ) //Total das Mercadorias : "  das Mercadorias : "
            oReport:SkipLine()
            nLinPC := oReport:Row()

            If cPaisLoc<>"BRA"
                aValIVA := MaFisRet(,"NF_VALIMP")
                nValIVA :=0
                If !Empty(aValIVA)
                    For nY:=1 to Len(aValIVA)
                        nValIVA+=aValIVA[nY]
                    Next nY
                EndIf
                oReport:PrintText(SubStr(SE4->E4_DESCRI,1,34),nLinPC, 050 )
                oReport:PrintText( dtoc(SC7->C7_EMISSAO),nLinPC,1120 )
                oReport:PrintText( "Total dos Impostos:    " + "   " + ; //Total das Mercadorias : "  dos Impostos:    "
                Transform(xMoeda(nValIVA,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nValIVA,14,MsDecimais(MV_PAR12)) ),nLinPC,1612 )
            Else
                oReport:PrintText( SubStr(SE4->E4_DESCRI,1,34),nLinPC, 050 )
                oReport:PrintText( dtoc(SC7->C7_EMISSAO),nLinPC,1120 )
                oReport:PrintText( "Total com Impostos:    " + "  " + ; //Total das Mercadorias : "  com Impostos:    "
                Transform(xMoeda(nTotMerc,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotMerc,14,MsDecimais(MV_PAR12)) ),nLinPC,1612 )
            Endif
            oReport:SkipLine()

            nTotIpi	  := MaFisRet(,'NF_VALIPI')
            nTotIcms  := MaFisRet(,'NF_VALICM')
            nTotDesp  := MaFisRet(,'NF_DESPESA')
            nTotFrete := MaFisRet(,'NF_FRETE')
            nTotSeguro:= MaFisRet(,'NF_SEGURO')
            nTotalNF  := MaFisRet(,'NF_TOTAL')

            oReport:SkipLine()
            oReport:SkipLine()
            nLinPC := oReport:Row()

            SM4->(dbSetOrder(1))
            If SM4->(dbSeek(xFilial("SM4")+SC7->C7_REAJUST))
                oReport:PrintText(  "Reajuste :" + " " + SC7->C7_REAJUST + " " + SM4->M4_DESCR ,nLinPC, 050 )  //"Reajuste :"
            EndIf

            If cPaisLoc == "BRA"
                oReport:PrintText( "IPI      :"  + Transform(xMoeda(nTotIPI ,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotIpi ,14,MsDecimais(MV_PAR12))) ,nLinPC,1320 ) //"IPI      :"
                oReport:PrintText( "ICMS     :"  + Transform(xMoeda(nTotIcms,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotIcms,14,MsDecimais(MV_PAR12))) ,nLinPC,1815 ) //"ICMS     :"
            EndIf
            oReport:SkipLine()

            nLinPC := oReport:Row()
            oReport:PrintText( "Frete    :"  + Transform(xMoeda(nTotFrete,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotFrete,14,MsDecimais(MV_PAR12))) ,nLinPC,1320 ) //"Frete    :"
            oReport:PrintText( "Despesas :" + Transform(xMoeda(nTotDesp ,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotDesp ,14,MsDecimais(MV_PAR12))) ,nLinPC,1815 ) //"Despesas :"
            oReport:SkipLine()

            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Inicializar campos de Observacoes.                           ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If Empty(cObs02)
                If Len(cObs01) > 30
                    cObs := cObs01
                    cObs01 := Substr(cObs,1,30)
                    For nX := 2 To 16
                        cVar  := "cObs"+StrZero(nX,2)
                        &cVar := Substr(cObs,(30*(nX-1))+1,30)
                    Next nX
                EndIf
            Else
                cObs01:= Substr(cObs01,1,IIf(Len(cObs01)<30,Len(cObs01),30))
                cObs02:= Substr(cObs02,1,IIf(Len(cObs02)<30,Len(cObs01),30))
                cObs03:= Substr(cObs03,1,IIf(Len(cObs03)<30,Len(cObs01),30))
                cObs04:= Substr(cObs04,1,IIf(Len(cObs04)<30,Len(cObs01),30))
                cObs05:= Substr(cObs05,1,IIf(Len(cObs05)<30,Len(cObs01),30))
                cObs06:= Substr(cObs06,1,IIf(Len(cObs06)<30,Len(cObs01),30))
                cObs07:= Substr(cObs07,1,IIf(Len(cObs07)<30,Len(cObs01),30))
                cObs08:= Substr(cObs08,1,IIf(Len(cObs08)<30,Len(cObs01),30))
                cObs09:= Substr(cObs09,1,IIf(Len(cObs09)<30,Len(cObs01),30))
                cObs10:= Substr(cObs10,1,IIf(Len(cObs10)<30,Len(cObs01),30))
                cObs11:= Substr(cObs11,1,IIf(Len(cObs11)<30,Len(cObs01),30))
                cObs12:= Substr(cObs12,1,IIf(Len(cObs12)<30,Len(cObs01),30))
                cObs13:= Substr(cObs13,1,IIf(Len(cObs13)<30,Len(cObs01),30))
                cObs14:= Substr(cObs14,1,IIf(Len(cObs14)<30,Len(cObs01),30))
                cObs15:= Substr(cObs15,1,IIf(Len(cObs15)<30,Len(cObs01),30))
                cObs16:= Substr(cObs16,1,IIf(Len(cObs16)<30,Len(cObs01),30))
            EndIf

            cComprador:= ""
            cAlter	  := ""
            cAprov	  := ""
            lNewAlc	  := .F.
            lLiber 	  := .F.

            SY1->(dbSetOrder(1))
            if SY1->(dbSeek(xFilial("SY1")+SC7->C7_COMPRA))
                cComprador := trim(SY1->Y1_NOME)
            Endif
            dbSelectArea("SC7")
            If !Empty(SC7->C7_APROV)

                cTipoSC7:= IIF((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),"PC","AE")
                lNewAlc := .T.
//                cComprador := UsrFullName(SC7->C7_USER)
                If SC7->C7_CONAPRO != "B"
                    lLiber := .T.
                EndIf
                dbSelectArea("SCR")
                dbSetOrder(1)
                dbSeek(xFilial("SCR")+cTipoSC7+SC7->C7_NUM)
                While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM) == xFilial("SCR")+Alltrim(SC7->C7_NUM) .And. SCR->CR_TIPO == cTipoSC7
                    cAprov += AllTrim(UsrFullName(SCR->CR_USER))+" ["
                    Do Case
                        Case SCR->CR_STATUS=="03" //Liberado
                            cAprov += "Ok"
                        Case SCR->CR_STATUS=="04" //Bloqueado
                            cAprov += "BLQ"
                        Case SCR->CR_STATUS=="05" //Nivel Liberado
                            cAprov += "##"
                        OtherWise                 //Aguar.Lib
                            cAprov += "??"
                    EndCase
                    cAprov += "] - "
                    dbSelectArea("SCR")
                    dbSkip()
                Enddo
                If !Empty(SC7->C7_GRUPCOM)
                    dbSelectArea("SAJ")
                    dbSetOrder(1)
                    dbSeek(xFilial("SAJ")+SC7->C7_GRUPCOM)
                    While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+SC7->C7_GRUPCOM
                        If SAJ->AJ_USER != SC7->C7_USER
                            cAlter += AllTrim(UsrFullName(SAJ->AJ_USER))+"/"
                        EndIf
                        dbSelectArea("SAJ")
                        dbSkip()
                    EndDo
                EndIf
            EndIf

            nLinPC := oReport:Row()
            oReport:PrintText( "Observacoes "  ,nLinPC, 050 ) // "Observacoes "
            oReport:PrintText( "SEGURO   :"  + Transform(xMoeda(nTotSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotSeguro,14,MsDecimais(MV_PAR12))) ,nLinPC, 1815 ) // "SEGURO   :"
            oReport:SkipLine()

            nLinPC2 := oReport:Row()
//            oReport:PrintText(cObs01,,050 )
            oReport:PrintText("Comprador Responsavel :" +" "+Substr(cComprador,1,60),,050 ) 	//"Comprador Responsavel :" //"BLQ:Bloqueado"
//            oReport:PrintText(cObs02,,050 )
            oReport:PrintText("Aprovador(es:" +" "+If( Len(cAprov) > 0 , Substr(cAprov,001,140) , " " ),,050 ) //"Aprovador(es) :"

            nLinPC := oReport:Row()
//            oReport:PrintText(cObs03,nLinPC,050 )
            oReport:PrintText(            If( Len(cAprov) > 0 , Substr(cAprov,141,140) , " " ),,310 ) //"Aprovador(es) :"

            If !lNewAlc
                oReport:PrintText( "Total Geral :"  + Transform(xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotalNF,14,MsDecimais(MV_PAR12))) ,nLinPC,1774 ) //Total das Mercadorias : "  Geral :"
            Else
                If lLiber
                    oReport:PrintText( "Total Geral :"  + Transform(xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotalNF,14,MsDecimais(MV_PAR12))) ,nLinPC,1774 )
                Else
                    oReport:PrintText( "Total Geral :"  + If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),"     P E D I D O   B L O Q U E A D O " ,"AUTORIZACAO DE ENTREGA BLOQUEADA   " ) ,nLinPC,1390 )
                EndIf
            EndIf
            oReport:SkipLine()

            oReport:PrintText("So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso" ,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
            oReport:PrintText("Pedido de Compras." ,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
            oReport:SkipLine()
            nLinPC3 := oReport:Row()
            nLinPC := nLinPC3
            oReport:Box( 2570+nDeslV , 1220 , 2700+nDeslV , 1820 )
            oReport:Box( 2570+nDeslV , 1820 , 2700+nDeslV , nPageWidth )
            oReport:PrintText( If( lLiber , "      P E D I D O   L I B E R A D O"  , "     P E D I D O   B L O Q U E A D O "  ) ,nLinPC,1290 ) //"     P E D I D O   L I B E R A D O"#"|     P E D I D O   B L O Q U E A D O !!!"
            oReport:PrintText( "Obs. do Frete: "  + Substr(RetTipoFrete(SC7->C7_TPFRETE),3),nLinPC,1830 ) //"Obs. do Frete: "


        Next nVias

        MaFisEnd()


        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Grava no SC7 as Reemissoes e atualiza o Flag de impressao.   ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


        dbSelectArea("SC7")
        If Len(aRecnoSave) > 0
            For nX :=1 to Len(aRecnoSave)
                dbGoto(aRecnoSave[nX])
                If(SC7->C7_QTDREEM >= 99)
                    If nRet == 1
                        RecLock("SC7",.F.)
                        SC7->C7_EMITIDO := "S"
                        MsUnLock()
                    Elseif nRet == 2
                        RecLock("SC7",.F.)
                        SC7->C7_QTDREEM := 1
                        SC7->C7_EMITIDO := "S"
                        MsUnLock()
                    Elseif nRet == 3
                        //cancelar
                    Endif
                Else
                    RecLock("SC7",.F.)
                    SC7->C7_QTDREEM := (SC7->C7_QTDREEM + 1)
                    SC7->C7_EMITIDO := "S"
                    MsUnLock()
                Endif
            Next nX
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Reposiciona o SC7 com base no ultimo elemento do aRecnoSave. ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            dbGoto(aRecnoSave[Len(aRecnoSave)])
        Endif

        Aadd(aPedMail,aPedido)

        aRecnoSave := {}

        dbSelectArea("SC7")
        dbSkip()

    EndDo

    oSection2:Finish()

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Executa o ponto de entrada M110MAIL quando a impressao for   ³
    //³ enviada por email, fornecendo um Array para o usuario conten ³
    //³ do os pedidos enviados para possivel manipulacao.            ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If ExistBlock("M110MAIL")
        lEnvMail := (oReport:nDevice == 3)
        If lEnvMail
            Execblock("M110MAIL",.F.,.F.,{aPedMail})
        EndIf
    EndIf

    If lAuto .And. !lImpri
        Aviso("Atenção","Verifique os parâmetros definidos para esse relatório no configurador para o usuário corrente." ,{"OK"})
    Endif

    dbSelectArea("SC7")
    dbClearFilter()
    dbSetOrder(1)

Return

/*-----------------+---------------------------------------------------------+
!Nome              ! CabecPCxAE - Cliente: Madero                            !
+------------------+---------------------------------------------------------+
!Descrição         ! Cabecalho do relatorio                                  !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 29/05/2018                                              !
+------------------+--------------------------------------------------------*/
static Function CabecPCxAE(oReport,oSection1,nVias,nPagina)

    Local cMoeda	:= IIf( mv_par12 < 10 , Str(mv_par12,1) , StADMINr(mv_par12,2) )
    Local nLinPC	:= 0
    Local nTpImp	  := IIF(ValType(oReport:nDevice)!=Nil,oReport:nDevice,0) // Tipo de Impressao
    Local nPageWidth  := IIF(nTpImp==1.Or.nTpImp==6,2314,2290)
    Local cCident	:= IIF(len(SM0->M0_CIDENT)>20,Substr(SM0->M0_CIDENT,1,15),SM0->M0_CIDENT)
    Local cFileBmp
    Local _cFileLogo
    Local cBitmap
    Local aSM0 := SM0->(GetArea())
    Public nRet:= 0
    
    SM0->(dbSeek(cEmpAnt+SC7->C7_FILIAL))
    nPageWidth += 100
    cBitmap := R110Logo()
    TRPosition():New(oSection1,"SA2",1,{ || xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA })

    SA2->(dbSetOrder(1))
    SA2->(dbSeek(xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA))

    oSection1:Init()

    oReport:Box( 010 , 010 ,  260 , 1000 )
    oReport:Box( 010 , 1010,  260 , nPageWidth-2 ) // 2288
//    oReport:Box( 010 , 1010,  260 , 2300 ) 

    oReport:PrintText( If(nPagina > 1,(" - continuacao" )," "),,oSection1:Cell("M0_NOMECOM"):ColPos())

    nLinPC := oReport:Row()
//    cFileBmp := "\system\lgrl"+cEmpAnt+".bmp"
//    if file(cFileBmp)
//    	oReport:SayBitmap(nLinPC, 15, cFileBmp, 900, oReport:LineHeight()*2)
//    EndIf
    oReport:PrintText( If( mv_par08 == 1 , "P E D I D O  D E  C O M P R A S", "A U T O R I Z A C A O  D E  E N T R E G A") + " - " + GetMV("MV_MOEDA1") ,nLinPC,1030 )
    oReport:PrintText( If( mv_par08 == 1 , SC7->C7_NUM, SC7->C7_NUMSC + "/" + SC7->C7_NUM ) + " /" + Ltrim(Str(nPagina,2)) ,nLinPC,1910 )
    oReport:SkipLine()

    
    nLinPC := oReport:Row()
    If(SC7->C7_QTDREEM >= 99)
      nRet := Aviso("TOTVS", "O pedido de compras chegou ao seu limite de reemissões." +chr(13)+chr(10)+ "1- " + "Reimprimir 99ª emissão" +chr(13)+chr(10)+ "2- " + "Voltar a 1ª emissão" +chr(13)+chr(10)+ "3- " + "Cancelar",{"1", "2", "3"},2)
      If(nRet == 1)
        oReport:PrintText( Str(SC7->C7_QTDREEM,2) + "a.Emissao "  + Str(nVias,2) + "a.VIA"  ,nLinPC,1910 )
      Elseif(nRet == 2)
        oReport:PrintText( "1" + "a.Emissao "  + Str(nVias,2) + "a.VIA"  ,nLinPC,1910 )
      Elseif(nRet == 3)
        oReport:CancelPrint()
      Endif
    Else
      oReport:PrintText( If( SC7->C7_QTDREEM > 0, Str(SC7->C7_QTDREEM+1,2) , "1" ) + "a.Emissao "  + Str(nVias,2) + "a.VIA"  ,nLinPC,1910 )
    Endif

    _cFileLogo	:= GetSrvProfString('Startpath','') + cBitmap
    oReport:SayBitmap(25,25,_cFileLogo,150,60) // insere o logo no relatorio

    oReport:SkipLine()
    nLinPC := oReport:Row()
    oReport:PrintText("Empresa:" + SM0->M0_NOMECOM,nLinPC,15)  // "Empresa:"
    oReport:PrintText("Razão Social:"  + trim(SA2->A2_NOME)+"       Codigo:" +SA2->A2_COD+" Loja:"+SA2->A2_LOJA,nLinPC,1025)
    oReport:SkipLine()

    nLinPC := oReport:Row()
    oReport:PrintText("Endereco:"  + SM0->M0_ENDENT,nLinPC,15)
    oReport:PrintText("Endereco:"  + SA2->A2_END+"  Bairro:" +SA2->A2_BAIRRO,nLinPC,1025)
    oReport:SkipLine()

    nLinPC := oReport:Row()
    oReport:PrintText("CEP:"  + Trans(SM0->M0_CEPENT,PesqPict("SA2","A2_CEP"))+Space(2)+"Cidade:" + "  " + RTRIM(SM0->M0_CIDENT) + " " + "UF:"  + SM0->M0_ESTENT ,nLinPC,15)
    oReport:PrintText("Municipio:" +Left(SA2->A2_MUN, 30)+" "+"Estado:"+SA2->A2_EST+" "+"CEP:" +SA2->A2_CEP+" "+"CNPJ/CPF"+":"+Transform(SA2->A2_CGC,Iif(SA2->A2_TIPO == 'F',Substr(PICPES(SA2->A2_TIPO),1,17),Substr(PICPES(SA2->A2_TIPO),1,21))),nLinPC,1025)
    oReport:SkipLine()

    nLinPC := oReport:Row()
    oReport:PrintText("TEL:"  + SM0->M0_TEL + Space(2) + "FAX:"  + SM0->M0_FAX ,nLinPC,15)
    oReport:PrintText("FONE:"  + "("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15) + " "+"FAX:" +"("+Substr(SA2->A2_DDD,1,3)+") "+SubStr(SA2->A2_FAX,1,15)+" "+If( cPaisLoc$"ARG|POR|EUA",space(11) , "Ins. Estad.:"  )+If( cPaisLoc$"ARG|POR|EUA",space(18), SA2->A2_INSCR ),nLinPC,1025)
    oReport:SkipLine()

    nLinPC := oReport:Row()
    oReport:PrintText("CNPJ/CPF:" + Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC")) ,nLinPC,15)
    If cPaisLoc == "BRA"
      oReport:PrintText(Space(2) + "IE:"  + InscrEst() ,nLinPC,415)
    Endif
    oReport:SkipLine()
    oReport:SkipLine()

    oSection1:Finish()
    SM0->(RestArea(aSM0))

Return


/*-----------------+---------------------------------------------------------+
!Nome              ! R110FIniPC - Cliente: Madero                            !
+------------------+---------------------------------------------------------+
!Descrição         ! Rodape do relatorio                                     !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 29/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function R110FIniPC(cFilSC7, cPedido,cItem,cSequen,cFiltro)

    Local aArea     := GetArea()
    Local aAreaSC7  := SC7->(GetArea())
    Local cValid        := ""
    Local nPosRef       := 0
    Local nItem     := 0
    Local cItemDe       := IIf(cItem==Nil,'',cItem)
    Local cItemAte  := IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
    Local cRefCols  := ''
    DEFAULT cSequen := ""
    DEFAULT cFiltro := ""

    dbSelectArea("SC7")
    dbSetOrder(1)
    If dbSeek(cFilSC7+cPedido+cItemDe+Alltrim(cSequen))
      MaFisEnd()
      MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
      While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == cFilSC7+cPedido .AND. ;
          SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen) .OR. cSequen == SC7->C7_SEQUEN)

        // Nao processar os Impostos se o item possuir residuo eliminado  
        If &cFiltro
          dbSelectArea('SC7')
          dbSkip()
          Loop
        EndIf
                
        // Inicia a Carga do item nas funcoes MATXFIS  
        nItem++
        MaFisIniLoad(nItem)
        dbSelectArea("SX3")
        dbSetOrder(1)
        dbSeek('SC7')
        While !EOF() .AND. (X3_ARQUIVO == 'SC7')
          cValid    := StrTran(UPPER(SX3->X3_VALID)," ","")
          cValid    := StrTran(cValid,"'",'"')
          If "MAFISREF" $ cValid
            nPosRef  := AT('MAFISREF("',cValid) + 10
            cRefCols := Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
            // Carrega os valores direto do SC7.           
            //#TB20191121 Thiago Berna - Ajuste para nao considerar campos virtuais
            If !SX3->X3_CONTEXT == 'V'
                MaFisLoad(cRefCols,&("SC7->"+ SX3->X3_CAMPO),nItem)
            EndIf
          EndIf
          dbSkip()
        End
        MaFisEndLoad(nItem,2)
        dbSelectArea('SC7')
        dbSkip()
      End
    EndIf

    RestArea(aAreaSC7)
    RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R110Logo  ³ Autor ³ Materiais             ³ Data ³07/01/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna string com o nome do arquivo bitmap de logotipo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R110Logo()

Local cBitmap := "LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" // Empresa+Filial

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao encontrar o arquivo com o codigo do grupo de empresas ³
//³ completo, retira os espacos em branco do codigo da empresa   ³
//³ para nova tentativa.                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !File( cBitmap )
	cBitmap := "LGRL" + AllTrim(SM0->M0_CODIGO) + SM0->M0_CODFIL+".BMP" // Empresa+Filial
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao encontrar o arquivo com o codigo da filial completo,  ³
//³ retira os espacos em branco do codigo da filial para nova    ³
//³ tentativa.                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !File( cBitmap )
	cBitmap := "LGRL"+SM0->M0_CODIGO + AllTrim(SM0->M0_CODFIL)+".BMP" // Empresa+Filial
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se ainda nao encontrar, retira os espacos em branco do codigo³
//³ da empresa e da filial simultaneamente para nova tentativa.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !File( cBitmap )
	cBitmap := "LGRL" + AllTrim(SM0->M0_CODIGO) + AllTrim(SM0->M0_CODFIL)+".BMP" // Empresa+Filial
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao encontrar o arquivo por filial, usa o logo padrao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !File( cBitmap )
	cBitmap := "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
EndIf

Return cBitmap 
