/**********************************************************************************************************************************/
/** CALL CENTER                                                                                                                  **/
/** Ponto de entrada para liberar o bloqueio de clientes na agenda do operador                                                   **/
/** Autor: Rog�rio Souza Pereira                                                                                                 **/
/** RSAC Solu��es                                                                                                                **/
/**********************************************************************************************************************************/
/** Data       | Respons�vel                    | Descri��o                                                                      **/
/**********************************************************************************************************************************/                          
/** 29/08/2019 | Rog�rio Souza Pereira          | Cria��o da rotina/procedimento.                                                **/
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