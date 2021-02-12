/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** Gravação do histórico de alteração de liberação de credito de pedidos de venda                                               **/
/** Autor: Rogério Souza Pereira                                                                                                 **/
/** RSAC Soluções                                                                                                                **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/                          
/** 20/04/2017 | Rogério Souza Pereira          | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/**********************************************************************************************************************************/
/** user function KFATA02()                                                                                                      **/
/** Gravação do histórico de alteração de liberação de credito de pedidos de venda                                               **/
/**********************************************************************************************************************************/
User Function KFATA02(cBlCred, cNumPed)

// variaveis auxiliares
local aArea := GetArea()
local nValPed := 0   
local cSeq := "01"

// verifica se o credito foi liberado
if Empty(cBlCred)

	// pedido liberado, recupera o valor total do pedido
	nValPed := GetValLib(cNumPed)

	// recupera a sequencia de alteração do historico
	cSeq := GetSeqSzb(cNumPed)

	// grava o historico de liberação de crédito
	RecLock("SZB", .T.)
	SZB->ZB_FILIAL 	:= XFilial("SZB")
	SZB->ZB_PEDIDO 	:= cNumPed
	SZB->ZB_SEQ 	:= cSeq
	SZB->ZB_VALOR 	:= nValPed
	SZB->ZB_USER 	:= RetCodUsr()
	SZB->ZB_DATA 	:= Date()
	SZB->ZB_HORA 	:= Time()
	MsUnlock()

	// restaura a area
	RestArea(aArea)

endIf

return Nil


/**********************************************************************************************************************************/
/** static function GetSeqSzb(cNumPed)                                                                                           **/
/** recupera a sequencia de alteração do historico                                                                               **/
/**********************************************************************************************************************************/
static function GetSeqSzb(cNumPed)

  // variaveis auxiliares
  local cQr := ""
  local aArea := GetArea()
  local cRet := "01"


  // define a query para recuperar a sequencia
  cQr := " select max(SZB.ZB_SEQ) ZB_SEQ 
  cQr += "   from " + RetSqlName("SZB") + " SZB
  cQr += "  where SZB.D_E_L_E_T_ = ' '
  cQr += "    and SZB.ZB_FILIAL = '" + XFilial("SZB") + "'
  cQr += " 	  and SZB.ZB_PEDIDO = '" + cNumPed + "'
 
	// abre a query
	TcQuery cQr new alias "QSZB"
	RestArea(aArea)

  // verifica se ha sequencia
  if !Empty(QSZB->ZB_SEQ)
    cRet := Soma1(QSZB->ZB_SEQ)
  endIf

  // fecha a query
  QSZB->(DbCloseArea())

return cRet


/**********************************************************************************************************************************/
/** static function GetValLib(cNumPed)                                                                                           **/
/** recupera o valor liberado do pedido                                                                                          **/
/**********************************************************************************************************************************/
static function GetValLib(cNumPed)

// variaveis auxiliares
local nRet := 0
local cQr := ""
local aArea := GetArea()


// define a query para recuperar o maior valor do limite de credito liberado
cQr := " select (sum(SC9.C9_QTDLIB * SC6.C6_PRCVEN)) C6_VALLIB
cQr += "   from " + RetSqlName("SC6") + " SC6

cQr += " 	left join " + RetSqlName("SC9") + " SC9
cQr += " 	  on SC9.D_E_L_E_T_ = ' '
cQr += " 	 and SC9.C9_FILIAL = SC6.C6_FILIAL
cQr += " 	 and SC9.C9_PEDIDO = SC6.C6_NUM
cQr += " 	 and SC9.C9_ITEM = SC6.C6_ITEM
cQr += " 	 and SC9.C9_PRODUTO = SC6.C6_PRODUTO

cQr += " where SC6.D_E_L_E_T_ = ' '
cQr += "   and SC6.C6_FILIAL = '" + XFilial("SC6") + "'
cQr += " 	 and SC6.C6_NUM = '" + cNumPed + "'
cQr += "   and SC9.C9_BLCRED = ''

// abre a query
TcQuery cQr new alias "QSC6"
RestArea(aArea)

// retorna o resultado e fecha a query
nRet := QSC6->C6_VALLIB
QSC6->(DbCloseArea())

return nRet