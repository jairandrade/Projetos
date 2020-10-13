#Include 'Protheus.ch'
#Include "topconn.ch"
#include "FileIO.ch"
#include "TBICONN.CH"
#include "rwmake.ch"
/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! IMPORT10                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Processa documento de entrada de importação dos saldos                        !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 19/09/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                

User Function IMPORT10()
Local   lOk       :=.T.
Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "INCLUSAO DE SALDOS POR DOCUMENTO DE ENTRADA"
Local   cDesc1    := "Esta rotina tem como objetivo incluir os saldos iniciais por documento de entrada, "
Local   cDesc2    := "com base em arquivo .csv selecionado pelo usuario. Para gerar os saldos iniciais,"
Local   cDesc3    := "deverá ser executada esta rotina com data igual ao último dia do mês anterior ao"
Local   cDesc4    := "inicio da movimentacao com uma TES que apenas movimente estoque e nao gere finan-"
Local   cDesc5    := "ceiro. Antes da execução desta rotina, deverá ser ajustado o parâmetro MV_ULMES  "
Local   cDesc6    := "para o último dia do mês anterior a data do documento importado e, apos a importa-"
Local   cDesc7    := "cao dos dados, devera ser feito os reprocessamentos e fechamento do estoque."
Private oMainWnd  := NIL
Private oRegua


// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
aAdd( aSay, cDesc6 )
aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )
FormBatch(  cTitulo,  aSay,  aButton )

If lOk
  VerParam()
EndIf

Return NIL





Static Function VerParam()
Local dDataEst :=GetMV("MV_ULMES")
Local lOk      :=.T.

  Pergunte("IMPORT10",.T.)

  // -> Verifica parametros informados - Data
  If Empty(MV_PAR01)
		MsgStop("A data do documento deve ser informada","[IMPORT10] - ATENCAO")
		lOk:=.F.
  ElseIf MV_PAR01 < dDataEst
    MsgStop("A data informada é menor que a data de fechamento do estoque. Verifique o parâmetro MV_ULMES","[IMPORT10] - ATENCAO")
		lOk:=.F.
  EndIf

  // -> Verifica parametros informados - Numero e série
  If Empty(MV_PAR02) .or. Empty(MV_PAR03)
		MsgStop("O número do documento ou serie devem ser informados.","[IMPORT10] - ATENCAO")
		lOk:=.F.
  ElseIf Len(AllTrim(MV_PAR02)) < TamSx3("F1_DOC")[1]
    MsgStop("Numero do documento deve ser preenchido com o 'zeros a esquerda'","[IMPORT10] - ATENCAO")
		lOk:=.F.
  ElseIf Len(AllTrim(MV_PAR03)) < TamSx3("F1_SERIE")[1]
    MsgStop("Série do documento deve ser preenchido com o 'zeros a esquerda'","[IMPORT10] - ATENCAO")
		lOk:=.F.
  EndIf
  
  // -> Verifica parametros informados - Fornecedor
  If Empty(MV_PAR04) .or. Empty(MV_PAR05)
		MsgStop("O código do fornecedor e loja devem ser informados.","[IMPORT10] - ATENCAO")
		lOk:=.F.
  Else
    // -> Posiciona no fornecedor
    DbSelectArea("SA2")
    SA2->(DbSetOrder(1))
    SA2->(DbSeek(xFilial("SA2")+MV_PAR04+MV_PAR05))
    If !SA2->(Found())
  		MsgStop("Fornecedor não encontrado. Verifique o código e loja.","[IMPORT10] - ATENCAO")
	  	lOk:=.F.
    EndIf
  EndIf

  // -> Verifica parametros informados - Arquivo
  If Empty(MV_PAR06) 
		MsgStop("O caminho e arquivo deve ser informado .","[IMPORT10] - ATENCAO")
		lOk:=.F.
  Else
    If !File(AllTrim(MV_PAR06))
		  MsgStop("O arquivo " + AllTrim(MV_PAR06) + " não foi encontrado.","[IMPORT04] - ATENCAO")
		  lOk:=.F.
    EndIf  
	EndIF

// -> Verifica parametros informados - TES
  If Empty(MV_PAR07) 
		MsgStop("A TES deve ser informada.","[IMPORT10] - ATENCAO")
		lOk:=.F.
  Else
    // -> Posiciona no fornecedor
    DbSelectArea("SF4")
    SF4->(DbSetOrder(1))
    SF4->(DbSeek(xFilial("SF4")+MV_PAR07))
    If !SF4->(Found())
  		MsgStop("TES não encontrado. Verifique o código da TES nformada.","[IMPORT10] - ATENCAO")
	  	lOk:=.F.
    EndIf
	EndIF

  // -> Processa alteração dos dados do produto 
  If lOk
    oRegua := MsNewProcess():New({ || ProcSaldo(oRegua,MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07)}, "Processamento dados...")
	  oRegua:Activate()
  EndIf  

Return()


Static Function ProcSaldo(oProc,dDataDoc,cDoc,cSer,cForn,cLoj,cArq,cTES)
Local cLinha     := ""
Local cErros     := ""
Local aLinha1	   := {}
Local aLinhai	   := {}
Local lFound     := .F.
Local aDados     := {}
Local aErros     := {}
Local nLinha     := 2
Local cFileLog   := StrToKarr(cArq,".")[1]
Local aMt140c	   := {}
Local aMt140i    := {}
Local nDecQtde   := TamSx3("D1_QUANT")[2]
Local nDecValor  := TamSx3("D1_VUNIT")[2]
Local lErro      := .F.
Local dDataAux   := dDataBase
Local nModAux    := nModulo 
Local nPosProd   := 0
Local nPosQuant  := 0
Local nPosValor  := 0
Local nPosLote   := 0
Local nPosValid  := 0
Local nQuant     := 0
Local aProdut    := {}
Local nx
Local nj
Local cCodP
Local oDlgMens  := Nil
Local oMsg      := Nil
Local oBtnOk    := Nil
Local oFntTxt   := TFont():New("Lucida Console",,-015,,.F.,,,,,.F.,.F.)

	nModulo  :=2
  dDataBase:=dDataDoc
  FT_FUSE(cArq)
  
  // -> Verifica se o arquivo possui dados
	If FT_FEOF()
    MsgStop("O arquivo " + AllTrim(MV_PAR06) + " está vazio.","[IMPORT04] - ATENCAO")
		Return(.F.)
	Else
    cLinha     := alltrim(FT_FREADLN())
    aLinha1	   := Strtokarr(cLinha,";")
    nPosProd   := aScan(aLinha1,"D1_COD")
    nPosQuant  := aScan(aLinha1,"D1_QUANT")
    nPosValor  := aScan(aLinha1,"D1_VUNIT")
    nPosLote   := aScan(aLinha1,"D1_LOTECTL")
    nPosValid  := aScan(aLinha1,"D1_DTVALID")
  EndIf

  // -> Verifica se os campos foram encontrados no arquivo - Produto
  If nPosProd <= 0
    MsgStop("Campo D1_COD nao encontrado no arquivo.","[IMPORT04] - ATENCAO")
    lErro:=.T.
  EndIf

  // -> Verifica se os campos foram encontrados no arquivo - Quantidade
  If nPosQuant <= 0
    MsgStop("Campo D1_QUANT nao encontrado no arquivo.","[IMPORT04] - ATENCAO")
    lErro:=.T.
  EndIf

  // -> Verifica se os campos foram encontrados no arquivo - Valor
  If nPosValor <= 0
    MsgStop("Campo D1_VUNIT nao encontrado no arquivo.","[IMPORT04] - ATENCAO")
    lErro:=.T.
  EndIf

// -> Verifica se os campos foram encontrados no arquivo - Lote
  If nPosLote <= 0
    MsgStop("Campo D1_LOTECTL nao encontrado no arquivo.","[IMPORT04] - ATENCAO")
    lErro:=.T.
  EndIf

// -> Verifica se os campos foram encontrados no arquivo - Validade
  If nPosValid <= 0
    MsgStop("Campo D1_DTVALID nao encontrado no arquivo.","[IMPORT04] - ATENCAO")
    lErro:=.T.
  EndIf

  // -> Se tudo ok, continua; caso contrário sai da rotina
  If lErro
    oProc:=Nil
		Return(.F.)
  EndIf
	
  aDados:={}
  aErros:={}
  nLinha:=2
  DbSelectArea("SB1")
  SB1->(DbSetOrder(1))
	FT_FSKIP()
  While !FT_FEOF()

		cLinha := alltrim(FT_FREADLN())
    aLinhai:= Separa(cLinha,";",.T.)

    // -> Pesquisa o produto
    lFound:=.T.
    SB1->(DbSeek(xFilial("SB1")+aLinhai[nPosProd]))
    If !SB1->(Found())
      aadd(aErros,"Linha: " + StrZero(nLinha,4) + " : " + "Produto " + AllTrim(aLinhai[nPosProd]) + " nao encontrado.")
      lFound:=.F.
    Else
      // -> Valida lote e validade
      If SB1->B1_RASTRO == "L"
        // -> Valida lote
        If Empty(aLinhai[nPosLote])
          aadd(aErros,"Linha: "+ StrZero(nLinha,4) + " : " +  "Lote inválida.")
          lFound:=.F.
        EndIf

        // -> Valida data de validade
        If Empty(CtoD(aLinhai[nPosValid]))
          aadd(aErros,"Linha: "+ StrZero(nLinha,4) + " : " + "Data de validade inválida.")
          lFound:=.F.
        EndIf
      EndIf
    EndIf
    
    // -> Valida quantidade
    If toNumber(aLinhai[nPosQuant]) <= 0
      aadd(aErros,"Linha: "+ StrZero(nLinha,4) + " : " + "Quantidade inválida.")
      lFound:=.F.
    EndIf

    // -> Valida valor
    If toNumber(aLinhai[nPosValor]) <= 0
      aadd(aErros,"Linha: "+ StrZero(nLinha,4) + " : " + "Valor inválido.")
      lFound:=.F.
    EndIf

		// -> Se encontrou o produto, inclui os dados
    If lFound
      aAdd(aDados,{SB1->B1_COD,SB1->B1_LOCPAD,toNumber(aLinhai[nPosQuant]),toNumber(aLinhai[nPosValor]),aLinhai[nPosLote],CtoD(aLinhai[nPosValid])})
    EndIf

    nLinha:=nLinha+1
		FT_FSKIP()
	EndDO

	FT_FUSE()

  // -> Se ocorreu erros, gera log no diretório
  If Len(aErros) > 0
    // -> Grava arquivo de log
    cFileLog:=cFileLog+"_erro.log"
    nHandle :=FCreate(cFileLog)
    If nHandle >= 0
      // -> Grava erros
      cErros += "Ocorreram erros. Verifique os erros no arquivo " + cFileLog +Chr(13)+Chr(10)+Chr(13)+Chr(10)
      For nx:=1 to Len(aErros)
          FWrite(nHandle,aErros[nx]+Chr(13)+Chr(10))
          cErros += aErros[nx]+Chr(13)+Chr(10)
      Next nx
    Else
       cErros += "Ocorreram erros. Não foi possivel salvar o arquivo." + Chr(13)+Chr(10)+Chr(13)+Chr(10)
      For nx:=1 to Len(aErros)
          cErros += aErros[nx]+Chr(13)+Chr(10)
      Next nx
    EndIf 
    FClose(nHandle)  
    
    //Tela com log de erros
    DEFINE MSDIALOG oDlgMens TITLE 'Log de Erros' FROM 000, 000  TO 300, 400 COLORS 0, 16777215 PIXEL
        
        @ 002, 004 GET oMsg VAR cErros OF oDlgMens MULTILINE SIZE 191, 121 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
        oMsg:lReadOnly := .T.
         
        @ 127, 144 BUTTON oBtnOk  PROMPT "Fechar"   SIZE 051, 019 ACTION (oDlgMens:End()) OF oDlgMens PIXEL
         
    ACTIVATE MSDIALOG oDlgMens CENTERED 

    //MsgStop("Ocorreram erros. Verifique os erros no arquivo "+cFileLog,"[IMPORT04] - ATENCAO")
    Return(.F.)

  EndIf

  // -> Verifica se há dados para processar
  lErro:=.F.
  Begin Transaction

  If Len(aDados) > 0
	  // -> Posiciona no fornecedor
    DbSelectArea("SA2")
	  SA2->(DbSetOrder(1))
	  SA2->(DbSeek(XFilial("SA2")+cForn+cLoj))
	
	  oProc:SetRegua1( Len(aDados) )
    aAdd(aMt140c,{"F1_TIPO"    ,"N" 			      , NIL})
    aadd(aMt140c,{"F1_FORMUL" , "N"             , Nil})
		aAdd(aMt140c,{"F1_DOC"     ,cDoc	          , NIL})
		aAdd(aMt140c,{"F1_SERIE"   ,cSer			      , NIL})
		aAdd(aMt140c,{"F1_EMISSAO" ,dDataDoc        , NIL})
		aAdd(aMt140c,{"F1_FORNECE" ,SA2->A2_COD		  , NIL})
		aAdd(aMt140c,{"F1_LOJA"    ,SA2->A2_LOJA	  , NIL})
		aAdd(aMt140c,{"F1_COND"    ,SA2->A2_COND    , NIL})
		aAdd(aMt140c,{"F1_ESPECIE" ,"NF" 			      , NIL})
		aAdd(aMt140c,{"F1_STATUS"  ,"A" 			      , NIL})
	
		For nx:=1 to Len(aDados)
			
			oProc:IncRegua1("Processando " + alltrim(str(nx)) + " de " + alltrim(str(Len(aDados))) )
			// -> Verifica se o produto está cadastrado
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+alltrim(aDados[nx,1])))

      aAdd(aProdut,{SB1->B1_FILIAL+SB1->B1_COD,SB1->B1_TIPOCQ,SB1->B1_NOTAMIN})
      RecLock("SB1",.F.)
      SB1->B1_TIPOCQ :="M"
      SB1->B1_NOTAMIN:=0
      SB1->(MsUnlock())
         
      aLinha := {}
      aadd(aLinha,{"D1_FILIAL", xFilial("SD1")                                                ,NIL})
      aadd(aLinha,{"D1_COD"   , SB1->B1_COD                                                   ,NIL})
      aadd(aLinha,{"D1_LOCAL",  SB1->B1_LOCPAD                                                ,NIL})
      aadd(aLinha,{"D1_QUANT" , NoRound(aDados[nx,3],nDecQtde)                                ,NIL})
      aadd(aLinha,{"D1_VUNIT" , NoRound(aDados[nx,4],nDecValor)                               ,NIL})
      aadd(aLinha,{"D1_TOTAL",  NoRound(aDados[nx,3],nDecQtde)*NoRound(aDados[nx,4],nDecValor),NIL})
      aadd(aLinha,{"D1_TES"  ,  cTES                                                          ,NIL})
      If SB1->B1_RASTRO == "L"
        aAdd(aLinha,{"D1_LOTECTL", alltrim(aDados[nx,5]) , NIL})
				aAdd(aLinha,{"D1_DTVALID",aDados[nx,6]           , NIL})
      EndIf
			aAdd(aMt140i, aClone(aLinha))					
		Next nx
						
		lMsErroAuto := .F.
    MATA103(aMt140c,aMt140i,3)
		//MSExecAuto({|x,y,z|Mata103(x,y,z)},aMt140c,aMt140i,3)		

		If lMsErroAuto
			MostraErro()
      lErro:=.T.
      DisarmTransaction()
		Else
        // -> Retorna as configurações de qualidade / CQ para os produtos
        DbSelectArea("SB1")
        SB1->(DbSetOrder(1))
        For nx:=1 to Len(aProdut)
            // -> Posiciona no produto
            SB1->(DbSeek(aProdut[nx,01]))          
            RecLock("SB1",.F.)
            SB1->B1_TIPOCQ :=aProdut[nx,02]
            SB1->B1_NOTAMIN:=aProdut[nx,03]
            SB1->(MsUnlock())
        Next nx    
    EndIf
  
  EndIf 

  DbSelectArea("SB1")
  SB1->(DbSetOrder(1))
  // -> Imprime as etiquetas
  DbSelectArea("SD1")
  SD1->(DbSetOrder(1))
  SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
  While !SD1->(Eof()) .and. SD1->D1_FILIAL == xFilial("SD1") .and. SD1->D1_DOC == SF1->F1_DOC .and. SD1->D1_SERIE = SF1->F1_SERIE .AND. SD1->D1_FORNECE == SF1->F1_FORNECE .and. SD1->D1_LOJA == SF1->F1_LOJA
    
		SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))

    SB5->(DbSetOrder(1))
    SB5->(DbSeek(xFilial('SB5')+SD1->D1_COD))
    nQuant := 0

    If SB5->B5_QTDVAR == '2'
      While nQuant < SD1->D1_QUANT

        If SB5->B5_QEI == 0
          //Imprime 1un
          // -> Gera e atualiza dados da etiqueta na CB0
          cCodID:=Nil
          cCodigo := If(cCodID ==NIL,CBGrvEti('01',{SB1->B1_COD,1,"",SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,"","",SD1->D1_LOCAL,"",SD1->D1_NUMSEQ,NIL,NIL,NIL,SD1->D1_LOTECTL,"",SD1->D1_DTVALID,"","",NIL,"","","",SD1->D1_ITEM}),Nil)
          CB0->(dbSetOrder(1))
          CB0->(DbSeek(xFilial("CB0")+cCodigo))
          RecLock("CB0", .F.)
          CB0->CB0_CODET2 := UPPER(FWUUIDV4())
          CB0->(MsUnLock())
          nQuant += 1
        Else
          
          If nQuant + SB5->B5_QEI > SD1->D1_QUANT
            //Imprime Saldo
            // -> Gera e atualiza dados da etiqueta na CB0
            cCodID:=Nil
            cCodigo := If(cCodID ==NIL,CBGrvEti('01',{SB1->B1_COD,SD1->D1_QUANT - nQuant,"",SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,"","",SD1->D1_LOCAL,"",SD1->D1_NUMSEQ,NIL,NIL,NIL,SD1->D1_LOTECTL,"",SD1->D1_DTVALID,"","",NIL,"","","",SD1->D1_ITEM}),Nil)
            CB0->(dbSetOrder(1))
            CB0->(DbSeek(xFilial("CB0")+cCodigo))
            RecLock("CB0", .F.)
            CB0->CB0_CODET2 := UPPER(FWUUIDV4())
            CB0->(MsUnLock())
            nQuant := SD1->D1_QUANT
          Else
            //Imprime B5_QEI  
            // -> Gera e atualiza dados da etiqueta na CB0
            cCodID:=Nil
            cCodigo := If(cCodID ==NIL,CBGrvEti('01',{SB1->B1_COD,SB5->B5_QEI,"",SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,"","",SD1->D1_LOCAL,"",SD1->D1_NUMSEQ,NIL,NIL,NIL,SD1->D1_LOTECTL,"",SD1->D1_DTVALID,"","",NIL,"","","",SD1->D1_ITEM}),Nil)
            CB0->(dbSetOrder(1))
            CB0->(DbSeek(xFilial("CB0")+cCodigo))
            RecLock("CB0", .F.)
            CB0->CB0_CODET2 := UPPER(FWUUIDV4())
            CB0->(MsUnLock())
            nQuant += SB5->B5_QEI
          EndIf
        
        EndIf

      EndDo

    Else
      // -> Gera e atualiza dados da etiqueta na CB0
      cCodID:=Nil
      cCodigo := If(cCodID ==NIL,CBGrvEti('01',{SB1->B1_COD,SD1->D1_QUANT,"",SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,"","",SD1->D1_LOCAL,"", SD1->D1_NUMSEQ,NIL,NIL,NIL,SD1->D1_LOTECTL,"",SD1->D1_DTVALID,"","",NIL,"","","",SD1->D1_ITEM}),Nil)
      CB0->(dbSetOrder(1))
      CB0->(DbSeek(xFilial("CB0")+cCodigo))
      RecLock("CB0", .F.)
      CB0->CB0_CODET2 := UPPER(FWUUIDV4())
      CB0->(MsUnLock())
    EndIf
    SD1->(DbSkip())
  EndDO

  End Transaction

  dDataBase:=dDataAux
  nModulo  :=nModAux 

  If lErro
    MsgStop("Processo abortdo.","[IMPORT04] - ATENCAO")
    Return(.F.) 
  Else
    oProc:IncRegua1("Fim da importação.")
  EndIf  
Return(.T.)



Static Function toNumber(xValor)

	//se exitir virgula na string
	IF At(",",xValor) != 0
		//se o ponto vier antes da virgula ou ponto não existir
		IF ( At(",",xValor) > At(".",xValor) ).Or.At(".",xValor) == 0
			xValor := StrTran(xValor,".","")
			xValor := StrTran(xValor,",",".")
			xValor := val(xValor)
		Else
			xValor := StrTran(xValor,",","")
			xValor := val(xValor)
		EndIF
	Else
		xValor := val(xValor)
	EndIF

Return xValor