#include 'totvs.ch'

/*/{Protheus.doc} User Function CTFAT04WK
    Função para geração pedido de venda na filial CIC
    @type  Function
    @author Willian Kaneta
    @since 08/09/2020
    @version 1.0
    /*/
User Function CTFAT04WK(cNumTlvX,cNumSC5X)
    Local lRet       := .F.
    Local cFilSA1    := ""
    Local cFilSB1    := ""
    Local cFilSE4    := ""
    Local cFilSF4    := ""
    Local cFilBkp    := cFilAnt
    Local nOpcX      := 0
    Local aCabec     := {}
    Local aItens     := {}
    Local aLinha     := {}
    Local cTpOperPV  := SUPERGETMV("CT_TPOPTRS",.F.,"01")
    Local cCondPgto  := SUPERGETMV("CT_CONDPGT",.F.,"001")
    Local _cTESInt   := ""

    Private lMsErroAuto    := .F.
    Private lAutoErrNoFile := .F.
    Private cFilCD	  := SUPERGETMV("CT_ESTCENT",.F.,"010101")

    SB1->(dbSetOrder(1))
    SE4->(dbSetOrder(1))
    SF4->(dbSetOrder(1))
    
    cFilAGG := xFilial("AGG")
    cFilSA1 := xFilial("SA1")
    cFilSB1 := xFilial("SB1")
    cFilSE4 := xFilial("SE4")
    cFilSF4 := xFilial("SF4")
    
    DbSelectArea("SA1")
    SA1->(DbSetOrder(3))

    //****************************************************************
    //* Verificacao do ambiente para teste
    //****************************************************************    
    If SA1->(MsSeek(xFilial("SA1")+SM0->M0_CGC))
        cFilAnt := cFilCD
        
        //****************************************************************
        //* Inclusao - INÍCIO
        //****************************************************************
        aCabec   := {}
        aItens   := {}
        aLinha   := {}
        aadd(aCabec, {"C5_TIPO"     , "N"           , Nil})
        aadd(aCabec, {"C5_CLIENTE"  , SA1->A1_COD   , Nil})
        aadd(aCabec, {"C5_LOJACLI"  , SA1->A1_LOJA  , Nil})
        aadd(aCabec, {"C5_LOJAENT"  , SA1->A1_LOJA  , Nil})
        aadd(aCabec, {"C5_CONDPAG"  , cCondPgto     , Nil})
        aadd(aCabec, {"C5_XNUMSUA"  , cNumTlvX      , Nil})
        aadd(aCabec, {"C5_XESTOQU"  , "2"           , Nil})
        aadd(aCabec, {"C5_XFILSUA"  , cFilBkp       , Nil})

        DbSelectArea("SC6")
        SC6->(DbSetOrder(1))

        If SC6->(MsSeek(cFilBkp+cNumSC5X))
            While !SC6->(EOF()) .AND. SC6->(C6_FILIAL+C6_NUM) == cFilBkp+cNumSC5X
                //--- Informando os dados do item do Pedido de Venda
                aLinha := {}
                _cTESInt := MaTesInt(2, cTpOperPV, SA1->A1_COD , SA1->A1_LOJA, "C", SC6->C6_PRODUTO)
                aadd(aLinha,{"C6_ITEM"      , SC6->C6_ITEM   , Nil})
                aadd(aLinha,{"C6_PRODUTO"   , SC6->C6_PRODUTO, Nil})
                aadd(aLinha,{"C6_QTDVEN"    , SC6->C6_QTDVEN , Nil})
                aadd(aLinha,{"C6_QTDLIB"    , SC6->C6_QTDVEN , Nil})
                aadd(aLinha,{"C6_PRCVEN"    , SC6->C6_PRCVEN , Nil})
                aadd(aLinha,{"C6_PRUNIT"    , SC6->C6_PRUNIT , Nil})
                aadd(aLinha,{"C6_VALOR"     , SC6->C6_VALOR  , Nil})
                aadd(aLinha,{"C6_OPER"      , cTpOperPV      , Nil})
                aadd(aLinha,{"C6_TES"       , _cTESInt       , Nil})
                aadd(aItens, aLinha)
                SC6->(DbSkip())
            EndDo        
        EndIf
        nOpcX := 3
        MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)
        If !lMsErroAuto
            lRet := .T.
        Else
            MostraErro()
        EndIf
    EndIf
    
    cFilAnt := cFilBkp
Return lRet
