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
//	Programa: ANSLDCDT 	|	Autor: Luis Paulo									|	Data: 04/03/2021//
//==================================================================================================//
//	Descrição: Funcao para criar PV da 0401 para 0408 - Transf 0401 -> 0408                         //
//																									//
//==================================================================================================//
User Function TRFPVKIE(aProds,_cIdTrf)
Local aArea     := GetArea()
Local aProdRet  := {}
Local nRegPv    := 0 
Local lRet      := .f.
Private cIdTrf  := ""
Private lIncPV      := .f.
Private cPrdBlqE    := ""
Default aProds  := {}
Default _cIdTrf := ""


cIdTrf  := _cIdTrf

Conout("")
If CriaPVEnv(@nRegPv,aProds)

        If U_LibGerPv(nRegPv) 

                If U_LibCrEPv(nRegPv) 

                        If MATA455(nRegPv)
                            lRet := .t.
                        EndIf 

                    Else   
                        MsgAlert("Não foi possível liberar credito do PV na 0401")
                EndIf
            
            Else
                MsgAlert("Não foi possível liberar o PV na 0401")        
        EndIf

    Else
        MsgAlert("Não foi possível gerar o PV na 0401")
EndIf

RestArea(aArea)   
Return({lRet,nRegPv})

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
Static Function ExcPVTrf(nRegPv)
Local aCabPed		:={}
Local aLinhaPed		:={}
Local aItensPed		:={}
Local __cMsg        := ""
Private lMsErroAuto	:= .F.

DbSelectArea("SC5")
SC5->(dbGoTop())
SC5->(dbGoTo(nRegPv))

cPedido	:= SC5->C5_NUM
If U_NFMESTPV(cPedido,"")//Estorna o pedido da SC9
    Conout("Pedido liberado - SC9")
EndIf
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Guarda o Cabecalho do Pedido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aCabPed, {"C5_NUM"		,SC5->C5_NUM		,Nil})  // Nro.do Pedido
aAdd(aCabPed, {"C5_CLIENTE"	,SC5->C5_CLIENTE	,Nil})  // Cod. Cliente
aAdd(aCabPed, {"C5_LOJACLI"	,SC5->C5_LOJACLI	,Nil})  // Loja Cliente

DbSelectArea("SC6")
SC6->(DbSetOrder(1))	//Filial + Pedido
SC6->(dbGoTop())
If SC6->(DbSeek(SC5->C5_FILIAL + SC5->C5_NUM))

    While !SC6->(Eof()) .AND. SC5->C5_FILIAL + SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Guarda os Itens do Pedido   ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        Aadd(aLinhaPed,{"C6_ITEM"	,SC6->C6_ITEM		,NIL })
        Aadd(aLinhaPed,{"C6_PRODUTO",SC6->C6_PRODUTO	,NIL })
        aAdd(aLinhaPed,{"C6_NUM"	,SC6->C6_NUM		,NiL}) // Pedido
        aAdd(aLinhaPed,{"C6_PRODUTO",SC6->C6_PRODUTO	,Nil}) // Cod.Item
        aAdd(aLinhaPed,{"C6_UM"		,SC6->C6_UM			,Nil}) // Unidade
        aAdd(aLinhaPed,{"C6_QTDVEN"	,SC6->C6_QTDVEN		,Nil}) // Quantidade
        aAdd(aLinhaPed,{"C6_PRCVEN"	,SC6->C6_PRCVEN		,Nil}) // Preco Unit.
        aAdd(aLinhaPed,{"C6_PRUNIT"	,SC6->C6_PRUNIT		,Nil}) // Preco Unit.
        aAdd(aLinhaPed,{"C6_VALOR"	,SC6->C6_VALOR		,Nil}) // Valor Tot.
        aAdd(aLinhaPed,{"C6_TES"	,SC6->C6_TES		,Nil}) // Tipo de Saida
        aAdd(aLinhaPed,{"C6_LOCAL"	,SC6->C6_LOCAL		,Nil}) // Almoxarifado
        Aadd(aItensPed, aLinhaPed)
        aLinhaPed := {}
        SC6->(DbSkip())
    EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³exclui o Pedido de Venda.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SC5")
SC5->(dbGoTop())
SC5->(dbGoTo(nRegPv))

MSExecAuto( {|x,y,z| Mata410(x,y,z)} , aCabPed, aItensPed, 5) //"Excluindo Pedido"
If lMsErroAuto
     __cMsg := "Erro na exclusao do pedido de transferecia" + cCRLF 
    __cMsg  := __cMsg + MostraErro("\")

    Conout("")
    Conout(__cMsg)
    Conout("")
EndIf

Return()



/*/{Protheus.doc} nomeStaticFunction
    Liberacao do pedido de venda
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
User Function LibGerPv(nRegPv)
Local 	aBloqueio	:= {}
Local 	aPvlNfs		:= {}

DbSelectArea("SC5")
SC5->(dbGoTop())
SC5->(dbGoTo(nRegPv))

// Liberacao de pedido
Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
// Checa itens liberados
Ma410LbNfs(1,@aPvlNfs,@aBloqueio)

Return(.T.)


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
Static Function CriaPVEnv(nRegPv,aProds)
Local   lRet        := .f.
Local 	aCabec 		:= {}
Local	aItens 		:= {}
Local 	aLinha 		:= {}
Local 	cOP			:= Alltrim( SuperGetMV("KP_OPPVTRF"	,.F. ,"06")) //TRANSFERENCIA
Local 	nCount		:= 0
Local cConFor       := Alltrim( SuperGetMV("KP_FCONTRF"	,.F. ,"001"))

Private cCliCD01	:=  Alltrim( SuperGetMV("KP_CLICD01"	,.F. ,"092693"))
Private cCliLJ01	:=  Alltrim( SuperGetMV("KP_CLILJ01"	,.F. ,"01"))

Private lMsErroAuto	:= .F.

DbSelectArea("SC5")

aadd(aCabec,{"C5_TIPO" 		,"N"			                            ,Nil})
aadd(aCabec,{"C5_CLIENTE"	,Padr(cCliCD01  , TamSx3("C5_CLIENTE")[01] ) ,Nil})
aadd(aCabec,{"C5_LOJACLI"	,Padr(cCliLJ01  , TamSx3("C5_LOJACLI")[01]) ,Nil})
aadd(aCabec,{"C5_LOJAENT"	,Padr(cCliLJ01  , TamSx3("C5_LOJAENT")[01]) ,Nil})
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
aAdd(aCabec,{'C5_XIDTRFP' 	,Padr(cIdTrf    , TamSx3("C5_XIDTRFP")[01])  , Nil})

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
        aadd(aLinha,{"C6_LOCAL" , "04"                  , Nil})
        
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
            SC5->C5_XIDTRFP := cXIdTrf
            SC5->(MsUnlock())
            
            lRet    := .T.
            lIncPV  := .T.
            nRegPv := SC5->(RECNO())

            Conout("Pedido de venda de transferencia gerado com sucesso!!!! >>> " + SC5->C5_NUM )
    EndIf
EndTran()

Conout("")

Return(lRet)

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
User Function LibCrEPv(nRegPv)
Local lRet      := .t.
Local aAreaAtu 	:= GetArea()
Local aAreaSC5 	:= SC5->( GetArea() )
Local aAreaSC6 	:= SC6->( GetArea() )
Local aAreaSC9 	:= SC9->( GetArea() )
Local cPedido   := ""

DbSelectArea("SC5")
SC5->(dbGoTop())
SC5->(dbGoTo(nRegPv))

cPedido := SC5->C5_NUM

dbSelectArea("SC9")
SC9->( dbSetOrder(1) ) //C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_BLEST, C9_BLCRED, R_E_C_N_O_, D_E_L_E_T_
SC9->( dbGoTop() )
If SC9->( dbSeek(FwxFilial('SC9') + cPedido ) )
	While SC9->(!Eof()) .And. SC9->C9_FILIAL + SC9->C9_PEDIDO == FwxFilial("SC9") + cPedido
        RecLock("SC9",.F.)
        SC9->C9_BLCRED  :=""
        SC9->(MsUnlock())
        
        //a450Grava(1,.T.,.F.)
        
        SC9->(dbSkip() )
	EndDO

EndIF

RestArea(aAreaSC9)
RestArea(aAreaSC6)
RestArea(aAreaSC5)
RestArea(aAreaAtu)

Return(lRet)   

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
Local __cPrdBlE := ""

DbSelectArea("SC5")
SC5->(dbGoTop())
SC5->(dbGoTo(nRegPv))

cNumPed := SC5->C5_NUM


//inicializa as variaveis
cMsgErro :=""
DbSelectArea("SC9")
SC9->(DbSetOrder(1))

//preenche os parametros de liberação
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
        BusPBlE(@__cPrdBlE,cNumPed)
        // procedimento concluido
        lRet := .F.
        cMsgErro :="Verifique os saldos dos produtos deste pedido na 0401, produtos: ("+__cPrdBlE +"), informe o setor responsável pela liberação de estoque, pois não existe saldo disponivel no AMZ 04 na 0401!"  //Alterado por Marcellus mensagem retorno 01/04/2016
        MsgAlert(cMsgErro)
endIf
 
Return(lRet)


/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 15/03/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function BusPBlE(__cPrdBlE,cNumPed)
// variaveis auxiliares
local cAliasEs  := getNextAlias()
local lRet      := .t.

BeginSql Alias cAliasEs
    SELECT 
        C9_PRODUTO
    FROM
        %TABLE:SC9% SC9 (NOLOCK)
    WHERE 
        C9_FILIAL = '01'
        AND SC9.C9_PEDIDO = %EXP:cNumPed%
        AND SC9.C9_BLEST <> ''
        AND %NOTDEL%
endsql

while !(cAliasEs)->(EOF()) .And. lRet
    
    __cPrdBlE := Alltrim((cAliasEs)->C9_PRODUTO) + "/" + __cPrdBlE 
    
    (cAliasEs)->(dbSkip())
enddo

(cAliasEs)->(dbCloseArea())

Return()


//-------------------------------------------------
/*/{Protheus.doc} IsPedLib
retorna se o pedido foi liberado estoque 

@type function
@version 1.0
@author Desconhecido

@since 21/07/2016

@param cNumPed, character, Número do Pedido de Vendas

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
        %TABLE:SC9% SC9 (NOLOCK)
    WHERE 
        C9_FILIAL = '01'
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





