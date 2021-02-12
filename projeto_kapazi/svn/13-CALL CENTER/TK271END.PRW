/**********************************************************************************************************************************/
/** CALL CENTER                                                                                                                  **/
/** Ponto de entrada apos a finalização do atendimento                                                                           **/
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
/** user function TK271END()                                                                                                     **/
/** Ponto de entrada apos a finalização do atendimento                                                                           **/
/**********************************************************************************************************************************/
user function TK271END()

	// variaveis auxiliares
	local lBloq := Iif(Type("lTmkBloq") == "L", lTmkBloq, .F.)


	// verifica se o cliente foi bloqueado pela rotina
	if lBloq

		// chama a rotina para desbloquear o cliente	
		U_KTMKA01BL(M->ACF_CLIENT, M->ACF_LOJA, .T.)
		
	endIf

return Nil