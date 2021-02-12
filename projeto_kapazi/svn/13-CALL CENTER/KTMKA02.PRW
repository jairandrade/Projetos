/**********************************************************************************************************************************/
/** CALL CENTER                                                                                                                  **/
/** Geração de as listas de cobrança por atendente                                                                               **/
/** Autor: Rogério Souza Pereira                                                                                                 **/
/** RSAC Soluções                                                                                                                **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/                          
/** 26/09/2019 | Rogério Souza Pereira          | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"
#include "tbiconn.ch"

/**********************************************************************************************************************************/
/** user function KTMKA02()                                                                                                      **/
/** Geração de as listas de cobrança por atendente                                                                               **/
/**********************************************************************************************************************************/
user function KTMKA02()

  // variaveis auxiliares
  local lRet := .T.
  local cItem := ""
  local cContCod := ""



  // recupera os titulos vencidos
  QrySe1()

  // verifica se ha registros para gerar a lista
  if !QSE1->(Eof())
  
  	// gera o cabeçalho da lista
  	RecLock("SU4", .T.)
  	SU4->U4_FILIAL := XFilial("SU4")
  	SU4->U4_TIPO := "2"
  	SU4->U4_STATUS := "1"
  	SU4->U4_LISTA := GetSx8Num("SU4", "U4_LISTA") 
  	SU4->U4_DESC := "LISTA DE COBRANCA - " + Dtoc(Date())
  	SU4->U4_DATA := Date
  	SU4->U4_FORMA := "1"
  	SU4->U4_TELE := "3"
  	SU4->U4_OPERAD := ""
  	SU4->U4_NOPERAD := ""
  	SU4->U4_TIPOTEL := "1"
  	MsUnlock()
  
  endIf

  // faz o loop sobre os titulos
  cItem := "000000"
  while !QSE1->(Eof())

    // define o item da lista
    cItem := Soma1(cItem)

    // define o contato do cliente
    cContCod := GetContat(QSE1->E1_CLIENTE, QSE1->E1_LOJA)

  	// gera o item da lista
  	RecLock("SU6", .T.)
  	SU6->U6_FILIAL := XFilial("SU6")
  	SU6->U6_LISTA := SU4->U4_LISTA
  	SU6->U6_CODIGO := cItem
  	SU6->U6_CONTATO := cContCod
  	SU6->U6_ENTIDA := "SA1"
  	SU6->U6_CODENT := QSE1->E1_CLIENTE + QSE1->E1_LOJA
  	SU6->U6_ORIGEM := "1"
  	SU6->U6_DATA := Date()
  	SU6->U6_HRINI := "09:00"
  	SU6->U6_HRFIM := "17:00"
  	SU6->U6_STATUS := "1"
  	SU6->U6_CODOPER := ""
  	SU6->U6_DTBASE := Date()
  	MsUnlock()

  	// proximo titulo
  	QSE1->(DbSkip())
  	
  endDo
  
  // fecha a query
  QSE1->(DbCloseArea())

  // confirma o SX8
  ConfirmSx8()

return lRet


/**********************************************************************************************************************************/
/** static function QrySe1()                                                                                                     **/
/** Recupera os titulos vencidos                                                                                                 **/
/**********************************************************************************************************************************/
static function QrySe1()


return Nil