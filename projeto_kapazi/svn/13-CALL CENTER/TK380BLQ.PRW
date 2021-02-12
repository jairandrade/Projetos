/**********************************************************************************************************************************/
/** CALL CENTER                                                                                                                  **/
/** Ponto de entrada para liberar o bloqueio de clientes na agenda do operador                                                   **/
/** Autor: Rogério Souza Pereira                                                                                                 **/
/** RSAC Soluções                                                                                                                **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/                          
/** 29/08/2019 | Rogério Souza Pereira          | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"
#include "tbiconn.ch"

/**********************************************************************************************************************************/
/** user function TK380BLQ()                                                                                                     **/
/** Ponto de entrada para liberar o bloqueio de clientes na agenda do operador                                                   **/
/**********************************************************************************************************************************/
user function TK380BLQ()

	// variaveis auxiliares
	local aParam := ParamIxb
	local lRet := .F.


return lRet