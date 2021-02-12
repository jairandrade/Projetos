/**********************************************************************************************************************************/
/** CALL CENTER                                                                                                                  **/
/** Validação de cliente no atendimento do Call Center                                                                           **/
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
/** user function KTMKA01()                                                                                                      **/
/** Validação de cliente no atendimento do Call Center                                                                           **/
/**********************************************************************************************************************************/
user function KTMKA01()
// variaveis auxiliares
local lRet := .F.
public lTmkBloq := .F.

// chama a rotina para bloquear/desabloquear o cliente
lRet := U_KTMKA01BL(M->ACF_CLIENT, M->ACF_LOJA, .F.)

// executa a validação padrão do sistema
if lRet
		// seta a variavel publica pra ser usada no outro ponto de entrada no final do atendimento
		lTmkBloq := .T.
		lRet := Tk274Client() //Valid do campo ACF_CLIENT que atualiza os titulos a serem cobrados pelo operador.
	else
		lTmkBloq := .F.
endIf

return lRet


/**********************************************************************************************************************************/
/** user function KTMKA01BL(cCliCod, cCliLoj, lBloq)                                                                             **/
/** rotina para bloquear/desbloquear o cliente apartir de um atendimento                                                         **/
/**********************************************************************************************************************************/
user function KTMKA01BL(cCliCod, cCliLoj, lBloq)
// variaveis auxiliares
local aArea := GetArea()
local aAreaSa1 := SA1->(GetArea())
local lRet := .T.
local lContinua := .T.

// se o cliente estiver vazio, sai
if Empty(cCliCod) //.or. Empty(cCliLoj)
	return .F.
endIf

// verifica se o cliente esta bloqueado
SA1->(DbSetOrder(1))
if SA1->(DbSeek(XFilial("SA1") + cCliCod + AllTrim(cCliLoj)))
		// se a loja nao estiver preenchida, preenche
		if Empty(cCliLoj) .and. !lBloq
			M->ACF_LOJA := SA1->A1_LOJA
		endIf
	
		if !lBloq
			// verifica se o cliente esta bloqueado
			if SA1->A1_MSBLQL == "1"
				// verifica se o operador possui permissão para atender cliente bloqueado
				lContinua := MsgYesNo("O cliente está bloqueado! Deseja desabloqueá-lo?")
			endIf
		endIf
	
		if lContinua
			// se for bloqueio, grava o registro na tabela de bloqueios do call center
			if lBloq
				// recupera os clientes bloqueados do usuario
				QrySzg(cUserName)
				// faz o loop sobre os clientes bloqueados
				while !QSZG->(Eof())
	
					// localiza o cliente
					SA1->(DbSetOrder(1))
					if SA1->(DbSeek(XFilial("SA1") + QSZG->ZG_CLIENTE + QSZG->ZG_LOJA))
	
						// bloqueia o cliente
						RecLock("SA1", .F.)
						SA1->A1_MSBLQL := "1"
						MsUnlock()
						
						DbSelectArea("SZG")
						SZG->(DbGoTo(QSZG->RECORECO))
						RecLock("SZG",.F.)
						DbDelete()
						SZG->(MsUnlock())
					endIf
	
					// proximo registro
					QSZG->(DbSkip())
	
				endDo
	
				// fecha a query
				QSZG->(DbCloseArea())		  	
	
			else
	
				// verifica se o cliente esta bloqueado
				if SA1->A1_MSBLQL == "1"
					// desbloqueia o cliente
					RecLock("SA1", .F.)
					SA1->A1_MSBLQL := "2"
					MsUnlock()
					// grava o registro
					RecLock("SZG", .T.)
					SZG->ZG_FILIAL 	:= XFilial("SZG")
					SZG->ZG_CLIENTE := SA1->A1_COD
					SZG->ZG_LOJA 	:= SA1->A1_LOJA
					SZG->ZG_USUARIO := cUserName
					MsUnlock()
				endIf
			endIf
	
			// ajusta a variavel de retorno
			lRet := .T.
		endIf
	
	else
		// cliente nao localizado
		MsgAlert("O cliente não foi localizado!")
		lRet := .F.

endIf

// procedimento concluido
RestArea(aAreaSa1)
RestArea(aArea)

return lRet


/**********************************************************************************************************************************/
/** static function QrySzg(cNomeUsu)                                                                                             **/
/** Recupera a lista de clientes bloqueados pelo usuario                                                                         **/
/**********************************************************************************************************************************/
static function QrySzg(cNomeUsu)
// variaveis auxiliares
local cQr := ""
local aArea := GetArea()


// recupera os dados dos bloqueios
cQr := " select SZG.ZG_CLIENTE,
cQr += "        SZG.ZG_LOJA,R_E_C_N_O_ AS RECORECO
cQr += "   from " + RetSqlName("SZG") + " SZG
cQr += "  where SZG.D_E_L_E_T_ = ' '
cQr += "    and SZG.ZG_FILIAL = '" + XFilial("SZG") + "'	
cQr += "    and SZG.ZG_USUARIO = '" + cNomeUsu + "'

// abre a query
TcQuery cQr new alias "QSZG"
RestArea(aArea)

return Nil