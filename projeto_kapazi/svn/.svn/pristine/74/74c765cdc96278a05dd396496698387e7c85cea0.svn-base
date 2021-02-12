/**********************************************************************************************************************************/
/** Planejamento e Controle de Produção                                                                                          **/
/** Ponto de entrada para análise da quantidade de saldo em estoque                                                              **/
/** Analisa se o componente em questão deve considerar o estoque na hora da realização do empenho de produção                    **/
/** Autor: Rogério Souza Pereira                                                                                                 **/
/** RSAC Soluções                                                                                                                **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 28/08/2014 | Rogério Souza Pereira          | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"

/**********************************************************************************************************************************/
/** user function A650SALDO()                                                                                                    **/
/** Ponto de entrada para análise da quantidade de saldo em estoque para considerar em alguns produtos                           **/
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
