#include "rwmake.ch"
#include "topconn.ch"
#include "totvs.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "ap5mail.ch"
//==================================================================================================//
//	Programa: M410IPI		|	Autor: Luis Paulo							|	Data: 22/06/2018	//
//==================================================================================================//
//	Descrição: PE para tratar o IPI da planilha financeira										//
//																									//
//==================================================================================================//
/*
Este ponto de entrada retorna o valor do IPI para ser demonstrado na planilha financeira do pedido de vendas.
Para realizar todo o processo corretamente deve utilizar em conjunto com o ponto de entrada M460IPI com o mesmo tratamento do ponto M410IPI. 
Para que as informações do pedido de vendas e da nota fiscal de saída fiquem iguais.
Variaveis disponiveis no ponto de entrada:
VALORIPI
BASEIPI
QUANTIDADE
ALIQIPI
BASEIPIFRETE
*/
//Retorna o valor do IPI. VALORIPI(numerico)
User Function M410IPI()
Local nVlrIPI	:= VALORIPI
Local nBaseIPI	:= BASEIPI
Local nQtd		:= QUANTIDADE
Local nAliqIPI	:= ALIQIPI
Local nBSIPIFre	:= BASEIPIFRETE
Private nXperc	:= 0

If ISINCALLSTACK('U_PLANFNFM') //Verifica a origem 
	If nBaseIPI > 0 .And. ValNFM()
		
		BASEIPI := BASEIPI * ((100-nXperc)/100)
		nVlrIPI	:= BASEIPI * (nAliqIPI/100)
	EndIf
EndIf

Return(nVlrIPI)

//Valida o vinculo com NF Mista
Static Function ValNFM()
local cQr 		:= ""
local aArea 	:= GetArea()
local nCount 	:= 0
local lRet		:= .F.
local aCloAc	:= aClone(aCols) 
local nX		:= 1
local cProd		:= ""
local nPosCod  	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_PRODUTO"})  //Posição de C6_PRODUTO

	
cQr := " SELECT B1_XGERASV,SA1.A1_XGERASV,SA1.A1_XPERSV
cQr += " FROM SB1010 SB1
cQr += " INNER JOIN SA1010 SA1 ON SB1.B1_XGERASV = SA1.A1_XGERASV AND SA1.A1_COD = '"+M->C5_CLIENTE+"' AND SA1.A1_LOJA = '"+M->C5_LOJACLI+"' AND SA1.A1_XPERSV <> 0
cQr += " WHERE SB1.D_E_L_E_T_ = ''
cQr += "	AND SB1.B1_XGERASV = 'S'
cQr += "	AND SB1.B1_COD = '"+aCloAc[n][nPosCod]+"'

// abre a query
TcQuery cQr new alias "QVALNFM"
	
QVALNFM->(DbGoTop())

If !(QVALNFM->(EOF()))
	lRet		:= .T.
	nXperc		:= QVALNFM->A1_XPERSV
EndIf
// retorna o resultado e fecha a query
QVALNFM->(DbCloseArea())

RestArea(aArea)
Return(lRet)	
