#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Modulo            ! PCP - PRODUÇÃO                                          !
+------------------+---------------------------------------------------------+
!Nome              ! ETQ013                                                  !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina Emissão etiqueta Recebimento                     !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 20/05/18                                                !
+------------------+---------------------------------------------------------+
*/
User Function ETQ013()
Local  _nQtde   := 1
Local  _cImp    := Posicione("ZIA",1,XFILIAL("ZIA")+"013","ZIA_IMPPAD")
Local _fim      := Chr(13)+Chr(10)
Local cModelo   := ""
Local nxPixel   := 0
Local nyPixel   := 0
Local nx        := 0
Local nPontoMM  := 0
Local QRCODE    := "" 
Local aTexto    := {}
Local nQuant	:= 0
Local cCondTXt	:= ""
Local cCodigo	:= ""
Local cPrdRest  := ""
Local lSIF      := .F.

    // -> Verifica impressora
    _cImp:=IIF(AllTrim(_cImp)=="",GetMV("MV_IACD02"),_cImp)
    If !CB5->(DbSeek(xFilial("CB5")+_cImp))
	    MsgStop("Impressora "+_cImp+" nao encontrada na CB5."+Chr(13)+Chr(10)+"Favor verificar o cadastro de impressoras na tabela CB5.")
        Return("")
    EndIf

	// -> Posiciona no fornecedor 
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2")+ZI1->ZI1_FORN+ZI1->ZI1_LOJA))
    If !SA2->(Found())
	    MsgStop("Fornecedor não cadastrado - (SA2) - " + ZI1->ZI1_FORN+ZI1->ZI1_LOJA + " !")
        Return("")
    Endif

	// -> Posiciona no produto
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+ZI3->ZI3_PROD))
	If !SB1->(Found())
        MsgStop("Produto não cadastrado - (SB1) - " + ZI2->ZI2_PROD + "!")
        Return("")
	EndIf

    //#TB20191203 Thiago Berna - Ajuste para verificar se imprimie o texto SIF
    DbSelectArea('QE8')
    QE8->(DbSetOrder(1))
    If QE8->(DbSeek(xFilial('QE8') + SB1->B1_COD))
        If AllTrim(QE8->QE8_ENSAIO) == 'TP001' // FRIGORIFICO
            lSIF := .T.
        EndIf
    EndIf

    // -> Carrega dados da impressora
    cModelo :=Trim(CB5->CB5_MODELO)
    If CB5->CB5_TIPO == '4'
        cPorta:= "IP"
    Else
        If CB5->CB5_PORTA $ "12345"
            cPorta  :='COM'+CB5->CB5_PORTA+':'+CB5->CB5_SETSER
        EndIf
        IF CB5->CB5_LPT $ "12345"
            cPorta  :='LPT'+CB5->CB5_LPT
        EndIf
    EndIf

    lTipo   :=CB5->CB5_TIPO $ '12'
    nPortIP :=Val(CB5->CB5_PORTIP)
    cServer :=Trim(CB5->CB5_SERVER)
    cEnv    :=Trim(CB5->CB5_ENV)
    cFila   := NIL            
    If CB5->CB5_TIPO=="3"
        cFila := Alltrim(Tabela("J3",CB5->CB5_FILA,.F.))
    EndIf
    cModelo :=Trim(CB5->CB5_MODELO)
    nBuffer := CB5->CB5_BUFFER
    lDrvWin := (CB5->CB5_DRVWIN =="1")
            
    // -> Inicia a geração da etiqueta
    MSCBPRINTER(cModelo,cPorta,,,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH))
    MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")

    cCodigo := CBGrvEti('01',{SB1->B1_COD,ZI3->ZI3_QUANT,,ZI1->ZI1_DOC,ZI1->ZI1_SERIE,SA2->A2_COD, SA2->A2_LOJA,,,,,,,,,ZI3->ZI3_PALLET,,ZI4->ZI4_VALID,,,,,,})
	CB0->(dbSetOrder(1))
	CB0->(dbGoTop())
	CB0->(DbSeek(xFilial("CB0")+cCodigo))
	cCodEt2 := UPPER(FWUUIDV4())

	RecLock("CB0", .F.)
	CB0->CB0_CODET2 := cCodEt2
	CB0->(MsUnLock())

    // -> Grava dados de conferência do processo padrão
    GrvCBE(CB0->CB0_CODETI,SB1->B1_COD,ZI3->ZI3_QUANT,ZI4->ZI4_SIF,ZI4->ZI4_VALID,ZI1->ZI1_DOC,ZI1->ZI1_SERIE,SA2->A2_COD,SA2->A2_LOJA,__cUserId)

	// -> Busca codigo do produto restaurante
	cPrdRest:=U_ETQ013P(CB0->CB0_CODPRO)
 	QRCODE  := '(99)' + AllTrim(CB0->CB0_CODET2) + '(10)' + AllTrim(CB0->CB0_LOTE) + '(01)' + AllTrim(CB0->CB0_CODPRO) + '(17)' + AllTrim(DtoS(CB0->CB0_DTVLD))  + '(90)' + AllTrim(cPrdRest) + '(91)' + AllTrim(SB1->B1_XCODEXT) + '(21)' + AllTrim(CB0->CB0_CODPRO)

	MSCBBEGIN(_nQtde,6)
	MSCbModelo('DPL',cModelo,@nPontoMM)
    nxPixel    := nPontoMM *if(15==NIL,0,15)
    nyPixel    := nPontoMM *if(5==NIL,0,5)
    nxPixel    := Strzero(val(str(nxPixel,5,3))*100,4)
    nyPixel    := strzero(val(str(nyPixel,5,3))*100,4)

	aTexto:={}
	Do Case
		Case ZI3->ZI3_CONDIC=="R"
			cCondTXt := " - REPROVADO"
		Case ZI3->ZI3_CONDIC=="Q
			cCondTXt := " - QUARENTENA"
		Case ZI3->ZI3_CONDIC=="A"
			cCondTXt := " - APROVADO"
		OtherWise
			cCondTXt := ""
	End Case

    MSCBSAY(If(Empty(cCondTXt),33,20),46,"MADERO" + cCondTXt,"N","4","1,1")
    MSCBLineH(05,44,87,2,"B")

	aadd(aTexto,"<STX>KcDE300" +_fim)
    aadd(aTexto,"D11" +_fim) 
    If nPontoMM == 0.03937008
        aadd(aTexto,"1W1D55000"+nxPixel+nyPixel+"2HM,"+QRCODE +_fim) //300DPI
    Else
        aadd(aTexto,"1W1D33000"+nxPixel+nyPixel+"2HM,"+QRCODE +_fim) //200DPI
    EndIf
    aadd(aTexto,"E" +_fim)

    MSCBLineH(05,10,87,2,"B")
    If lSIF
        MSCBSAY(40,39,"SIF: "+ZI4->ZI4_SIF,"N","3","1,1")
    EndIF
    MSCBSAY(40,34,"VALIDADE: "+DTOC(ZI4->ZI4_VALID),"N","3","1,1")
    MSCBSAY(40,29,"QTDE: "+ Transform(ZI3->ZI3_QUANT, PesqPict("ZI3","ZI3_QUANT")),"N","3","1,1")
    MSCBSAY(40,24,"UN: "+ZI2->ZI2_UM,"N","3","1,1")
    MSCBSAY(40,19,"FORN: "+ALLTRIM(SA2->A2_NREDUZ),"N","3","1,1")
    MSCBSAY(40,14,"LOTE: ",ZI3->ZI3_PALLET,"3","1,1")
    MSCBSAY(3,5,ALLTRIM(SB1->B1_COD)+"-"+SUBSTR(ALLTRIM(SB1->B1_DESC),1,35),"N","3","1,1")
    MSCBSAY(3,0,"DATA RECEB: "+DTOC(ZI1->ZI1_DTINIC),"N","2","1,1")
    MSCBSAY(43,0,"N NF: "+ALLTRIM(ZI1->ZI1_DOC)+"/"+ALLTRIM(ZI1->ZI1_SERIE),"N","2","1,1")
	
    For nx := 1 To Len(aTexto)
		MSCBWRITE(aTexto[nx])     
    Next nx
	
    MSCBEND() 
	MSCBCLOSEPRINTER() 

Return()


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ GrvCBE   ³ Autor ³ Thiago Berna		    ³ Data ³ 16/12/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a Tabela CBE					                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GrvCBE(cID,cProduto,nQtde,cLote,dValid,cNota,cSerie,cFornec,cLoja,cCodOpe)

Local aArea := GetArea()


DbSelectArea('CBE')
CBE->(DbSetOrder(1))
If	CBE->(DBSeek(xFilial("CBE")+cID+cNota+cSerie+cFornec+cLoja+cProduto+cLote+dtos(dValid)))
	If ! UsaCB0("01")
		RecLock("CBE",.f.)
		CBE->CBE_CODUSR	:= cCodOpe
		CBE->CBE_DATA	:= dDatabase
		CBE->CBE_HORA	:= Time()
		CBE->CBE_QTDE   += nQtde
		CBE->(MsUnLock())
	EndIf
Else
	RecLock("CBE",.t.)
	CBE->CBE_FILIAL	:= xFilial("CBE")
	CBE->CBE_NOTA	:= cNota
	SerieNfId("CBE",1,"CBE_SERIE",,,cSerie)
	CBE->CBE_FORNEC	:= cFornec
	CBE->CBE_LOJA	:= cLoja
	CBE->CBE_CODPRO	:= cProduto
	CBE->CBE_QTDE	:= nQtde
	CBE->CBE_LOTECT	:= cLote
	CBE->CBE_CODUSR	:= cCodOpe
	CBE->CBE_DTVLD	:= dValid
	CBE->CBE_CODETI	:= cID
	CBE->CBE_DATA	:= dDatabase
	CBE->CBE_HORA	:= Time()
	CBE->(MsUnLock())
		
EndIf

RestArea(aArea)

Return