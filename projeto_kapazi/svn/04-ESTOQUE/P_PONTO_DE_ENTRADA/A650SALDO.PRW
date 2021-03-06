/**********************************************************************************************************************************/
/** Planejamento e Controle de Produ��o                                                                                          **/
/** Ponto de entrada para an�lise da quantidade de saldo em estoque                                                              **/
/** Analisa se o componente em quest�o deve considerar o estoque na hora da realiza��o do empenho de produ��o                    **/
/** Autor: Rog�rio Souza Pereira                                                                                                 **/
/** RSAC Solu��es                                                                                                                **/
/**********************************************************************************************************************************/
/** Data       | Respons�vel                    | Descri��o                                                                      **/
/**********************************************************************************************************************************/
/** 28/08/2014 | Rog�rio Souza Pereira          | Cria��o da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"

/**********************************************************************************************************************************/
/** user function A650SALDO()                                                                                                    **/
/** Ponto de entrada para an�lise da quantidade de saldo em estoque para considerar em alguns produtos                           **/
/**********************************************************************************************************************************/
user function A650SALDO()
           
  // variaveis auxiliares
  local nRet := ParamIxb
  local aArea := GetArea()
  local aAreaSg1 := SG1->(GetArea())
  

  // localiza o componente da estrutura
  DbSelectArea("SG1")
  SG1->(DbSetOrder(1))
  if SG1->(DbSeek(XFilial("SG1") + SC2->C2_PRODUTO + SB1->B1_COD))
	  if SG1->G1_K_CONES == "N"
	    nRet := 0
	    //if !Empty(SB1->B1_LE)
	    //  nRet += SB1->B1_LE
	    //endIf
	  endIf
	endIf

	// restaura as areas
	RestArea(aAreaSg1)
	RestArea(aArea)

return nRet
