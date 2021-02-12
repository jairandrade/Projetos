/**********************************************************************************************************************************/
/** SIGAEST - Estoque e Custos                                                                                                   **/
/** Cadastro de Ordens de Produ��o                                                                                               **/
/** Tratamento do campo de lote para ordens de produ��o                                                                          **/
/** RSAC Solu��es Ltda.                                                                                                          **/
/** Kapazi Ind�stria Brasileira Ltda.                                                                                            **/
/**********************************************************************************************************************************/
/** Data       | Respons�vel                    | Descri��o                                                                      **/
/**********************************************************************************************************************************/
/** 28/05/2013 | Rog�rio Souza Pereira          | Cria��o da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "msole.ch"                                                                                      

/**********************************************************************************************************************************/
/** user function KESTA01Val()                                                                                                   **/
/** faz a valida��o do campo C2_K_QTLOT para calcular a quantidade da OP conforme a quantidade base e lote informados            **/
/**********************************************************************************************************************************/
//Comentado em 20/06/2020, pois essa fonte nao estava mais no campo C2_K_QTLOT - Luis **Nao bate com a finalidade descrita
/* 
user function KCFGM01()
  
  // variaveis auxiliares
  local cArquivo := ""
  local cChave := ""
  local aArea := GetArea()


  // abre a tabela temporaria
  cArquivo := CriaTrab(Nil, .F.)
  cChave := "X3_ARQUIVO + X3_CAMPO"
  DbUseArea(.T., "dbfcdxads", "\importa\sx3" + SM0->M0_CODIGO + "0.dbf", "TRB", .T., .F.)
  IndRegua("TRB", cArquivo, cChave, Nil, Nil)
  DbSelectArea("TRB")
     
  // atualiza o arquivo
  Processa({|lEnd| KCFGM01Exe()})
                  
  // deleta o arquivo
  TRB->(DbCloseArea())
  FErase(cArquivo)

return Nil                                 


static function KCFGM01Exe()
  
  ProcRegua(SX3->(RecCount()))
  ProcessMessages()

  SX3->(DbSetOrder(1))
  SX3->(DbGoTop())
  while !SX3->(Eof())  
    
    // atualiza a regua
    IncProc("Atualizando campo: " + AllTrim(SX3->X3_CAMPO) + "...")
    ProcessMessages()
   
    // atualiza os campos X3_USADO e X3_RESERV   
    if TRB->(DbSeek(SX3->X3_ARQUIVO + SX3->X3_CAMPO))
      RecLock("SX3", .F.)
      SX3->X3_USADO := TRB->X3_USADO
      SX3->X3_RESERV := TRB->X3_RESERV
      MsUnlock()
    else 
      //MsgAlert("Campo nao localizado: " + SX3->X3_ARQUIVO + "|" + SX3->X3_CAMPO + "!")
      RecLock("SX3", .F.)
      SX3->X3_USADO := "���������������"
      SX3->X3_RESERV := "�A"
      MsUnlock()
    endIf
       
    // proximo registro
    SX3->(DbSkip())
 
  endDo

  // procedimento finalizado
  RestArea(aArea)

return Nil
*/