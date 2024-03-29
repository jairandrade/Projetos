#include "rwmake.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"
#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "totvs.ch"
#include "tbiconn.ch"
#include "TbiCode.ch"
#include "TOPCONN.CH"
//==================================================================================================//
//	Programa: PVRETSLD 	|	Autor: Luis Paulo									|	Data: 04/03/2021//
//==================================================================================================//
//	Descri��o: Rotina para retorno dos saldo para 0401(KI) na exclusao do pedido de venda           //
//																									//
//==================================================================================================//
User Function PVRETSLD(__cFilNF,__cSerie,__cNota,__cFornec,__cLoja)
Local aArea         := GetArea()

Local nRegPv        := 0
Local nRegNF	    := 0
Local nRegNFEn      := 0

Local nRecOri       := SC5->(RECNO()) 

Local cQry          := ""

Local lErro         := .f.

Local aLastQuery    := ""
Local cLastQuery    := {}

Local _cIdHist      := ""

Local aRetProd      := {}

Local cPVOri08      := ""

Local cFilbkp       := ""

Private  cAliasF1	:= ""
Private cXIDTRFCD   := ""
Private cCRLF       := CRLF
Private cLog        := ""

Private lIncPV      := .f.
Private aTranf      := ""

Default __cFilNF    := "" 
Default __cSerie    := "" 
Default __cNota     := "" 
Default __cFornec   := "" 
Default __cLoja     := "" 

aTranf := StrTokArr( Alltrim(SC5->C5_XHISTRF),"/")

For nX:= 1 To Len(aTranf)
    _cIdHist += "'" + aTranf[nX] + "',"
Next

_cIdHist := Substr(_cIdHist,1,Len(_cIdHist) - 1)

cAliasF1	:= GetNextAlias()

Qry  := " SELECT *, "+cCRLF
Qry  += "        ( "+cCRLF
Qry  += "             SELECT SUM(D1_QUANT) "+cCRLF
Qry  += "             FROM SF1040 SF1  (NOLOCK)  "+cCRLF
Qry  += "             LEFT JOIN SD1040 SD1 (NOLOCK)  ON SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SD1.D_E_L_E_T_ = ' ' AND SD1.D1_COD = DD.D1_COD"+cCRLF
Qry  += "             WHERE  SF1.D_E_L_E_T_ = ' '"+cCRLF
Qry  += "             AND SF1.F1_FILIAL = '08' "+cCRLF
Qry  += "             AND SF1.F1_XIDTRFP IN ("+_cIdHist+")"+cCRLF
Qry  += "         )TOTALQTD,"+cCRLF

Qry  += "         ("+cCRLF
Qry  += "             SELECT TOP 1 (D1_VUNIT) "+cCRLF
Qry  += "             FROM SF1040 SF1 (NOLOCK)   "+cCRLF
Qry  += "             LEFT JOIN SD1040 SD1 (NOLOCK)  ON SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SD1.D_E_L_E_T_ = ' ' AND SD1.D1_COD = DD.D1_COD "+cCRLF
Qry  += "             WHERE  SF1.D_E_L_E_T_ = ' ' "+cCRLF
Qry  += "             AND SF1.F1_FILIAL = '08' "+cCRLF
Qry  += "             AND SF1.F1_XIDTRFP IN ("+_cIdHist+") "+cCRLF
Qry  += "         )VLRUNIT "+cCRLF
Qry  += " FROM ( "+cCRLF
Qry  += "         SELECT DISTINCT D1_COD,D1_UM,D1_LOCAL "+cCRLF
Qry  += "         FROM SF1040 SF1 (NOLOCK) "+cCRLF
Qry  += "         LEFT JOIN SD1040 SD1 (NOLOCK) ON SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SD1.D_E_L_E_T_ = '' "+cCRLF
Qry  += "         WHERE SF1.D_E_L_E_T_ = '' "+cCRLF
Qry  += "         AND SF1.F1_FILIAL = '08' "+cCRLF
Qry  += "         AND SF1.F1_XIDTRFP IN ("+_cIdHist+")  "+cCRLF
Qry  += "     ) DD "+cCRLF

TcQuery Qry New Alias (cAliasF1)

DbSelectArea((cAliasF1))
(cAliasF1)->(DbGoTop())

If !(cAliasF1)->(EOF())
    cXIDTRFCD 	:= GetSx8Num("ZLG","ZLG_ID")  
    ConfirmSx8()
    
    cFilbkp		:= 	cFilAnt		
    
    Conout("")
    ConOut(SM0->M0_CODIGO+" - "+SM0->M0_CODFIL)
    Conout("")


    cFilant		:= 	"08"			
    DbSelectArea("SM0")
    SM0->(DbGoTop())
    SM0->(DbSeek( "04" + "08" ) )

    Conout("")
    ConOut(SM0->M0_CODIGO+" - "+SM0->M0_CODFIL)
    Conout("")

    aRetProd := ANSLDRET(@aRetProd)

    If Len(aRetProd) > 0

            If CriPVRet(cXIDTRFCD,@nRegPv,aRetProd,@cPVOri08) 
                
                    If U_LibGerPv(nRegPv) 
                        
                        If U_LibCrEPv(nRegPv) 

                            If MATA455(nRegPv)
                                
                                    If U_GerNFR08(nRegPV,@nRegNF,cXIDTRFCD) 

                                        If u_TranNF08() 

                                                If !U_NFEntRKI(cXIDTRFCD,@nRegNFEn) 
                                                        MsgInfo("Transferencia de NF de retorno n�o incluida, informe o TI","KAPAZI")
                                                        lErro := .t.           
                                                    Else
                                                        Gravalog(cXIDTRFCD,nRegPV,nRegNF,nRegNFEn,cPVOri08)  

                                                        DbSelectArea("SC5")
                                                        SC5->(DbGoTop())
                                                        SC5->(DbGoTo(nRecOri))
                                                                                
                                                        Reclock("SC5",.F.)
                                                        SC5->C5_XHISTRF := ""
                                                        SC5->(MsUnlock())

                                                        MsgInfo("Transferencia de NF de retorno conclu�da!!!","KAPAZI")
                                                EndIf
                                            

                                            EndIf

                                        Else
                                            MsgAlert("N�o foi poss�vel gerar a NF de sa�da com os produtos informados na NF, efetue a transferencia de forma manual")
                                            lErro := .t.
                                    EndIf 

                                Else 
                                    MsgAlert("N�o foi poss�vel liberar estoque do PV de sa�da com os produtos informados na NF, efetue a transferencia de forma manual")
                                    lErro := .t.
                            EndIf

                        EndIf

                    EndIf
                
                Else 
                    MsgAlert("N�o foi poss�vel criar o PV de sa�da com os produtos informados na NF, efetue a transferencia de forma manual")
                    lErro := .t.
            EndIf
        
        Else
            Conout("") 
            Conout("Sem produtos para transferir")
            Conout("") 
            
            Reclock("SC5",.F.)
            SC5->C5_XHISTRF := ""
            SC5->(MsUnlock())
            
            MsgInfo("Processo de transferencia de retorno conclu�da!!!","KAPAZI")

            lErro := .t.
    EndIf

    DbSelectArea("SM0")
    SM0->(DbGoTop())
    SM0->(DbSeek( "04" + cFilbkp ) )

    Conout("")
    ConOut(SM0->M0_CODIGO+" - "+SM0->M0_CODFIL)
    Conout("")

EndIf

If lErro
    If nRegNF > 0
        //u_ExcNFSTF("08",nRegNF)
    EndIf

    If nRegPv > 0
        //u_ExcPVSTF("08",nRegPv)
    EndIf

    If nRegNFEn > 0
        //u_ExcNFETF("01",nRegNFEn)
    EndIf

EndIf

RestArea(aArea)
Return()


/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 21/02/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function MATA455(nRegPv)
// variaveis auxiliares
Local aArea     := GetArea()
Local lEnd      := .F.
Local cPerg     :="LIBAT2"
Local lRet      := .F.
Local cAlias    :="SC9"  
Local cNumPed   := ""

DbSelectArea("SC5")
SC5->(dbGoTop())
SC5->(dbGoTo(nRegPv))

cNumPed := SC5->C5_NUM


//inicializa as variaveis
cMsgErro :=""
DbSelectArea("SC9")
SC9->(DbSetOrder(1))

//preenche os parametros de libera��o
Pergunte(cPerg, .F.)
mv_par01 := cNumPed
mv_par02 := cNumPed
mv_par03 := Space(6)
mv_par04 := Replicate("Z", 6)
mv_par05 := Stod("")
mv_par06 := Stod("20491231")
mv_par07 = 1

//chama a rotina para liberar o estoque
Processa({|lEnd| Ma450Processa(cAlias, .F., .T., @lEnd, Nil, MV_PAR07 == 2)}, Nil, Nil, .T.)
                    
//restaura a area
RestArea(aArea)

//valida se o pedido foi totalmente liberado
if IsPedLib(cNumPed)
    // procedimento concluido
    lRet := .T.

else
    // procedimento concluido
    lRet := .F.
    cMsgErro :="Produtos sem saldos, informe o setor respons�vel pela libera��o de estoque!"  //Alterado por Marcellus mensagem retorno 01/04/2016
    Conout(cMsgErro)
endIf
 
Return(lRet)



//-------------------------------------------------
/*/{Protheus.doc} IsPedLib
retorna se o pedido foi liberado estoque 

@type function
@version 1.0
@author Desconhecido

@since 21/07/2016

@param cNumPed, character, N�mero do Pedido de Vendas

@return Logical, True or False

@protected
/*/  
//-------------------------------------------------   
static function IsPedLib(cNumPed)

// variaveis auxiliares
local cAliasEs  := getNextAlias()
local lRet      := .t.

BeginSql Alias cAliasEs
    SELECT 
        COUNT(*) AS C9_TOTAL, C9_PRODUTO
    FROM
        %TABLE:SC9% SC9
    WHERE 
        C9_FILIAL = '08'
        AND SC9.C9_PEDIDO = %EXP:cNumPed%
        AND SC9.C9_BLEST <> ''
        AND %NOTDEL%
    GROUP BY 
        C9_PRODUTO
endsql

while !(cAliasEs)->(EOF()) .And. lRet
    lRet := ((cAliasEs)->C9_TOTAL == 0)

    (cAliasEs)->(dbSkip())
enddo

(cAliasEs)->(dbCloseArea())

return lRet

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 04/03/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function CriPVRet(cXIDTRFCD,nRegPv,aProds,cPVOri08)
Local aArea := GetArea()
Local   lRet        := .f.
Local 	aCabec 		:= {}
Local	aItens 		:= {}
Local 	aLinha 		:= {}
Local 	cOP			:= Alltrim( SuperGetMV("KP_OPPVTRF"	,.F. ,"06")) //TRANSFERENCIA
Local 	nCount		:= 0
Local cConFor       := Alltrim( SuperGetMV("KP_FCONTRF"	,.F. ,"001"))
Local nValProd      := 0

Private cCliCD08	:=  Alltrim( SuperGetMV("KP_CLICD08"	,.F. ,"007484"))
Private cCliLJ08	:=  Alltrim( SuperGetMV("KP_CLILJ08"	,.F. ,"20"))

Private lMsErroAuto	:= .F.

DbSelectArea("SC5")

aadd(aCabec,{"C5_TIPO" 		,"N"			                            ,Nil})
aadd(aCabec,{"C5_CLIENTE"	,Padr(cCliCD08  , TamSx3("C5_CLIENTE")[01]) ,Nil})
aadd(aCabec,{"C5_LOJACLI"	,Padr(cCliLJ08  , TamSx3("C5_LOJACLI")[01]) ,Nil})
aadd(aCabec,{"C5_LOJAENT"	,Padr(cCliLJ08  , TamSx3("C5_LOJAENT")[01]) ,Nil})
aadd(aCabec,{"C5_CONDPAG"	,Padr(cConFor   , TamSx3("C5_CONDPAG")[01]) ,Nil})
aadd(aCabec,{"C5_TPFRETE"	,Padr("S"       , TamSx3("C5_TPFRETE")[01]) ,Nil})
aadd(aCabec,{"C5_K_TPCL"	,Padr("000055"  , TamSx3("C5_K_TPCL")[01])  ,Nil})
aadd(aCabec,{"C5_TIPOCLI"	,Padr("R"       , TamSx3("C5_TIPOCLI")[01]) ,Nil})
aadd(aCabec,{"C5_VEND1"		,Padr("000147"  , TamSx3("C5_VEND1")[01])   ,Nil})
aadd(aCabec,{"C5_USER"		,Padr("Sistema" , TamSx3("C5_USER")[01])    ,Nil})
aadd(aCabec,{"C5_K_OPER"	,Padr(cOP       , TamSx3("C5_K_OPER")[01])  ,Nil})
aadd(aCabec,{"C5_XSITLIB"	,Padr("6"       , TamSx3("C5_XSITLIB")[01]) ,Nil})
aadd(aCabec,{"C5_XGERASV"	,Padr("N"       , TamSx3("C5_XGERASV")[01]) ,Nil})
aAdd(aCabec,{'C5_XTPPED' 	,Padr("014"     , TamSx3("C5_XTPPED")[01])  , Nil})
aAdd(aCabec,{'C5_INDPRES' 	,Padr("0"       , TamSx3("C5_INDPRES")[01])  , Nil})
aAdd(aCabec,{'C5_XIDTRFP' 	,Padr(cXIDTRFCD , TamSx3("C5_XIDTRFP")[01])  , Nil})

aCabec := FWVetByDic(aCabec,'SC5',.f.,1)

For nX := 1 To Len(aProds)    
    
    DbSelectArea("SB1")
    SB1->(dbSetOrder(1))
    SB1->(dbGoTop())
    If SB1->(DbSeek(xFilial("SB1") + aProds[nX][1] ))

        nCount++
        aLinha := {}
        aadd(aLinha,{"C6_ITEM"	 , StrZero(nCount,2)               , Nil})
        aadd(aLinha,{"C6_PRODUTO", aProds[nX][1]	               , Nil})		
        
        aadd(aLinha,{"C6_QTDVEN" , aProds[nX][2]	               , Nil})

        // se usa m2
        If Alltrim(aProds[nX][4]) == "M2"
            aAdd( aLinha , { "C6_XLARG"  	, aProds[nX][5]			, NIL } ) //Adicionado Posteriormente
            aAdd( aLinha , { "C6_XCOMPRI"  	, aProds[nX][6]			, NIL } ) //Adicionado Posteriormente
            aAdd( aLinha , { "C6_XQTDPC"  	, aProds[nX][7]			, NIL } ) //Adicionado Posteriormente
        EndIf

        aadd(aLinha,{"C6_OPER"	 , cOP			                   , Nil})
        aadd(aLinha,{"C6_PRCVEN" , aProds[nX][3]                   , Nil})
        aadd(aLinha,{"C6_PRUNIT" , aProds[nX][3]                   , Nil})
        aadd(aLinha,{"C6_LOCAL" , "04"            , Nil})

        aadd(aLinha,{"C6_CC"    , SB1->B1_XCCTRF        , Nil})
        
        aadd(aItens,aLinha)
        
    EndIf 

Next

DbSelectArea("SFM")
SFM->(dbSetOrder(1))

Conout("")

BeginTran()
    MATA410(aCabec,aItens,3)
    If lMsErroAuto
            lIncPV	:= .F.
            /*
            cLog := "Erro na inclusao do pedido de venda de transferencia, informe o TI!"    
            cLog := cLog + cCRLF
            cLog := cLog + cCRLF + MostraErro("\")

            Conout(cLog)
            */
            MostraErro()

        Else 
            Reclock("SC5",.F.)
            SC5->C5_XIDTRFP := cXIDTRFCD
            SC5->(MsUnlock())
            
            cPVOri08 := SC5->C5_NUM

            lIncPV  := .T.
            nRegPv := SC5->(RECNO())

            Conout("Pedido de venda de transferencia gerado com sucesso!!!! >>> " + SC5->C5_NUM )
    EndIf
EndTran()

Conout("")

RestArea(aArea)
Return(lIncPV)


//-------------------------------------------------
/*/{Protheus.doc} TrataErro
Rotina para tratamento de erros.

@type function
@version 1.0
@author Lucas Jos� Corr�a Chagas

@since 21/12/2020

@param oError, object, Objeto com informa��es do erro.

@protected
/*/
//-------------------------------------------------
Static Function TrataErro( oError as Object )

    if InTransact() // se estiver em uma transa��o de banco, aborta a mesma
        DisarmTransaction()
        EndTran()
    endif

    if !isBlind()
        MsgStop( alltrim(oError:Description), 'KAPAZI - Gera��o de notas fiscais RETORNO CD - Erro' )    
    endif
    Break

return

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 27/02/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function Gravalog(cXIDTRFCD,nRegPV,nRegNF,nRegNFEn,cPVOri08)
Local aArea := GetArea()

DbSelectArea("ZLG")

Reclock("ZLG",.T.)
ZLG->ZLG_FILIAL	:= xFilial("ZLG")
ZLG->ZLG_ID		:= cXIDTRFCD
ZLG->ZLG_RETPVS := nRegPV
ZLG->ZLG_RETNFS := nRegNF
ZLG->ZLG_RETNFE := nRegNFEn
ZLG->ZLG_PVCD	:= cPVOri08
ZLG->(MsUnlock())

RestArea(aArea)
Return() 

//Retorna o saldo correto que ainda esta disponivel na 0408
Static Function ANSLDRET(aRetProd)
Local aArea         := GetArea()
Local aProdRet      := {}
Local nSldProd      := 0
Local lSaldoSemR 	:= .T. //Subtrai a Reserva do Saldo a ser Retornado?
Local lConsTerc	    := .F. //Soma o [Saldo de Terceiros em nosso Poder] ao Saldo a ser Retornado?
Local cQry          := ""
Local cCRLF         := CRLF
Local cAlias        := GetNextAlias()
Local nItemAt       := ""
Local nItemNw       := ""

While !(cAliasF1)->(EOF())

    DbSelectArea("SB1")
    SB1->(DbSetOrder(1))
    SB1->(DbGoTop())
    If SB1->(DbSeek( xFilial("SB1") + (cAliasF1)->D1_COD))

            If Alltrim((cAliasF1)->D1_UM) == Alltrim(SB1->B1_UM)
                    //MV_TPSALDO
                    //(Q) Utiliza o valor B2_QATU-B2_QACLASS-B2_RESERVA 
                    DbSelectArea("SB2")
                    SB2->(DbSetOrder(1) )
                    SB2->(DbGoTop())
                    If SB2->(DbSeek( xFilial("SB2") + (cAliasF1)->D1_COD + (cAliasF1)->D1_LOCAL) ) //Busca qqr residuo de saldo que possa haver na origem
                            nSldProd	:= SaldoMov(Nil,Nil,Nil,lConsTerc,Nil,Nil, lSaldoSemR, dDataBase)
                        Else
                            CriaSB2((cAliasF1)->D1_COD,(cAliasF1)->D1_LOCAL)
                            CriaSB2((cAliasF1)->D1_COD,"04")
                    EndIf

                    If nSldProd >= (cAliasF1)->TOTALQTD
                            nValProd := u_RetVlrCm((cAliasF1)->D1_COD)

                            If nValProd == 0
                                MsgStop("O produto "+(cAliasF1)->D1_COD+" nao possui seu custa na tabela T01, favor verificaar!!","Kapazi")
                                aProdRet := {}
                                exit
                            EndIf

                            aAdd(aProdRet,{(cAliasF1)->D1_COD, (cAliasF1)->TOTALQTD, nValProd, (cAliasF1)->D1_UM,1,1,(cAliasF1)->TOTALQTD,(cAliasF1)->TOTALQTD})
                        /* Comentado pois pode ter usado saldo em outro pedido      
                        Else 
                            nValProd := u_RetVlrCm((cAliasF1)->D1_COD)

                            If nValProd == 0
                                MsgStop("O produto "+(cAliasF1)->D1_COD+" nao possui seu custa na tabela T01, favor verificaar!!","Kapazi")
                                aProdRet := {}
                                exit
                            EndIf

                            aAdd(aProdRet,{(cAliasF1)->D1_COD, nSldProd, nValProd, (cAliasF1)->D1_UM,1,1,nSldProd,nSldProd})
                        */
                    EndIf

                Else     
                    MsgStop("O produto "+(cAliasF1)->D1_COD+" n�o esta com a primeira unidade de medida correta (exclusao PV)!!","Kapazi")
                    aProdRet := {}
                    exit 
            EndIf 

        Else 
            MsgStop("O produto "+(cAliasF1)->D1_COD+" n�o existe (exclusao PV)!!","Kapazi")
            aProdRet := {}
            exit 
    EndIf

    (cAliasF1)->(DbSkip())
EndDo

(cAliasF1)->(DbCloseArea())

RestArea(aArea)
Return(aProdRet)


