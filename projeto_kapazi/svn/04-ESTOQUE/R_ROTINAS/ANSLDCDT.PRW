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
//	Descrição: Funcao para retornar os saldos a serem transferidos   		                        //
//																									//
//==================================================================================================//
User Function ANSLDCDT(cPar01,cPar02,cPar03,cPar04)
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
Local cProdSSld     := ""
Local cProdUnd      := ""
Local cProdAEr      := ""

BeginSql Alias cAlias
    
    SELECT C9_FILIAL,C9_PEDIDO,C9_ITEM,C9_CLIENTE,C9_LOJA,C9_PRODUTO,C9_LOCAL,C9_QTDLIB,C9_QTDLIB2,C9_BLEST,SC9.R_E_C_N_O_ AS SC9RECO, 
 		C6_PRODUTO,C6_ITEM,C6_QTDVEN,C6_UM,C6_SEGUM,C6_LOCAL,C6_QTDEMP,C6_QTDEMP2,C6_K_TPFAT,C6_XQTDPC,C6_XLARG,C6_XCOMPRI,C6_XQTDPC,C6_PRCVEN
    FROM SC9040 SC9 (NOLOCK)  
    INNER JOIN SC6040 SC6  (NOLOCK) ON SC9.C9_FILIAL = SC6.C6_FILIAL AND SC9.C9_PEDIDO = SC6.C6_NUM AND SC9.C9_ITEM = SC6.C6_ITEM AND SC9.C9_PRODUTO = SC6.C6_PRODUTO AND SC6.D_E_L_E_T_ = '' 
    WHERE SC9.D_E_L_E_T_ = ''  
    AND SC9.C9_FILIAL = '08' 
    AND SC9.C9_PEDIDO >= %EXP:cPar01%  
    AND SC9.C9_PEDIDO <= %EXP:cPar02%   
    AND SC9.C9_CLIENTE >= %EXP:cPar03%   
    AND SC9.C9_CLIENTE <= %EXP:cPar04%   
    ORDER BY SC9.C9_ITEM   

EndSql

DbSelectArea((cAlias))
(cAlias)->(DbGoTop())

nItemAt := ""
nItemNw := (cAlias)->C9_ITEM

If !(cAlias)->(EOF())
    DbSelectArea("SC5")
    SC5->(DbSetOrder(1))
    SC5->(DbGoTop())
    If SC5->(DbSeek( xFilial("08") + (cAlias)->C9_PEDIDO))
        If !Empty(SC5->C5_XPEDTRA)
            
            Conout("")
            Conout("---- Pedido("+(cAlias)->C9_PEDIDO+") oriundo de transferencias Sakai ----")
            Conout("")
            //(cAlias)->(DbCloseArea())
            //RestArea(aArea)
            //Return(aProdRet)
            
        EndIf
    EndIf
EndIf 

While !(cAlias)->(EOF())

    cPVOri08	:= (cAlias)->C9_PEDIDO

    nItemNw := (cAlias)->C9_ITEM

    If (cAlias)->C9_LOCAL == "04"

            If !Empty((cAlias)->C9_BLEST) .And. (cAlias)->C9_BLEST != "10" 
                
                If nItemNw != nItemAt

                        DbSelectArea("SB1")
                        SB1->(DbSetOrder(1))
                        SB1->(DbGoTop())
                        If SB1->(DbSeek( xFilial("SB1") + (cAlias)->C9_PRODUTO))

                                If Alltrim((cAlias)->C6_UM) == Alltrim(SB1->B1_UM)

                                        DbSelectArea("SB2")
                                        SB2->(DbSetOrder(1) )
                                        SB2->(DbGoTop())
                                        If SB2->(DbSeek( xFilial("SB2") + (cAlias)->C9_PRODUTO + (cAlias)->C9_LOCAL) ) 
                                                nSldProd	:= SaldoMov(Nil,Nil,Nil,lConsTerc,Nil,Nil, lSaldoSemR, dDataBase)
                                            Else
                                                CriaSB2((cAlias)->C9_PRODUTO,(cAlias)->C9_LOCAL)
                                                CriaSB2((cAlias)->C9_PRODUTO,"04")
                                        EndIf

                                        nItemAt := (cAlias)->C9_ITEM
                                        
                                        If nSldProd < (cAlias)->C9_QTDLIB
                                            nValProd := u_RetVlrCm((cAlias)->C9_PRODUTO)

                                            If nValProd == 0
                                                cProdSSld := Alltrim((cAlias)->C9_PRODUTO) +"/"+cProdSSld
                                            EndIf

                                            aAdd(aProdRet,{(cAlias)->C9_PRODUTO, (cAlias)->C9_QTDLIB, nValProd, (cAlias)->C6_UM,(cAlias)->C6_XLARG,(cAlias)->C6_XCOMPRI,(cAlias)->C6_XQTDPC,(cAlias)->C6_QTDVEN})
                                        EndIf

                                    Else     
                                        cProdUnd := Alltrim((cAlias)->C9_PRODUTO) +"/"+cProdUnd

                                EndIf 

                            Else 
                                MsgStop("O produto "+(cAlias)->C9_PRODUTO+" nao existe!!","Kapazi")
                                aProdRet := {}
                                exit 
                        EndIf
                    
                    Else

                EndIf    
            
            EndIf
        
        Else //Else Amz 04 
            cProdAEr := Alltrim((cAlias)->C9_PRODUTO) +"/"+cProdAEr
    EndIf

    (cAlias)->(DbSkip())
EndDo

(cAlias)->(DbCloseArea())

If !Empty(cProdAEr)
    MsgStop("O(s) produto(s) ( "+ Substr(cProdAEr,1,Len(Alltrim(cProdAEr))-1 ) +" ) estao com o armazem errado no pedido de venda(diferente de 04), favor verificaar!!","Kapazi")
    aProdRet := {}
EndIf

If !Empty(cProdSSld)
    MsgStop("O(s) produto(s) ( "+ Substr(cProdSSld,1,Len(Alltrim(cProdSSld))-1 ) +" ) nao possuem seu custo na tabela T01, favor verificaar!!","Kapazi")
    aProdRet := {}
EndIf

If !Empty(cProdUnd)
    MsgStop("O(s) produto(s) ( "+ Substr(cProdUnd,1,Len(Alltrim(cProdUnd))-1 )+" ) nao esta(o) na primeira unidade de medida correta!!","Kapazi")
    aProdRet := {}
EndIf

RestArea(aArea)
Return(aProdRet)

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
User Function RetVlrCm(__cProd)
Local aArea := GetArea()
Local cAliasB9  := GetNextAlias()
Local nValPrd	:= 0
	
BeginSql Alias cAliasB9

    %noParser%
    SELECT *
    FROM %table:DA1% DA1 WITH(NOLOCK) 
    WHERE D_E_L_E_T_ = ''
    AND DA1_FILIAL = '01'
    AND DA1_CODTAB = 'T01'
    AND DA1_CODPRO =  %Exp:__cProd%

EndSql

If !(cAliasB9)->(EOF())
    nValPrd := (cAliasB9)->DA1_PRCVEN
EndIf 

(cAliasB9)->(dbCloseArea())

If nValPrd != 0
    //nValPrd := Round( (nValPrd / 0.88),2) 
EndIf

RestArea(aArea)
Return(nValPrd)



