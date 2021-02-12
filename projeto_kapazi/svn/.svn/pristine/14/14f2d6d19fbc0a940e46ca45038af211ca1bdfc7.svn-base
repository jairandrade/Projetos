/**********************************************************************************************************************************/
/** SIGAEST - Estoque e Custos                                                                                                   **/
/** Cadastro de Ordens de Produção                                                                                               **/
/** Tratamento do campo de lote para ordens de produção                                                                          **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi Indústria Brasileira Ltda.                                                                                            **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 28/05/2013 | Rogério Souza Pereira          | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "msole.ch"                                                                                      

/**********************************************************************************************************************************/
/** user function KESTA01Val()                                                                                                   **/
/** faz a validação do campo C2_K_QTLOT para calcular a quantidade da OP conforme a quantidade base e lote informados            **/
/**********************************************************************************************************************************/
user function KESTA01Val()

  // variaveis auxilares
  local lRet := .F.
  local aArea := GetArea()
  local aAreaSb1 := SB1->(GetArea())
  local nQuant := 0
  

  // posiciona o produto
  SB1->(DbSetOrder(1))
  if !SB1->(DbSeek(XFilial("SB1") + M->C2_PRODUTO))
    // produto nao localizado
    MsgAlert("Produto não localizado!")
    RestArea(aAreaSb1)
    RestArea(aArea)
    return lRet
  endIf

  // verifica se tem quantidade base
  if !Empty(SB1->B1_QB) .and. !Empty(M->C2_K_QTLOT)
    
    // calcula a quantidade liquida
    nQuant := M->C2_K_QTLOT * SB1->B1_QB
    
  else                             
    
    // recupera o valor do lote ou quantidade informada
    if Empty(M->C2_K_QTLOT)
      nQuant := M->C2_QUANT
    else
      nQuant := M->C2_K_QTLOT
    endIf
    
  endIf    
  
  // atualiza a quantidade da OP
  M->C2_QUANT := nQuant
   
  // procedimento concluido
  RestArea(aAreaSb1)
  RestArea(aArea)
  lRet := .T.

return lRet