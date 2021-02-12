/**********************************************************************************************************************************/
/** Financeiro                                                                                                                   **/
/** Ponto de entrada na inclusao de titulos a pagar. FINA050                                                                     **/
/** Autor: luiz henrique jacinto                                                                                                 **/
/** RSAC Soluções                                                                                                                **/
/**********************************************************************************************************************************/
/** Data       | Responsavel                    | Descricao                                                                      **/
/**********************************************************************************************************************************/                          
/** 24/08/2018 | Luiz Henrique Jacinto          | Criacao da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"

/**********************************************************************************************************************************/
/** definicao de palavras                                                                                                        **/
/**********************************************************************************************************************************/
#Define ENTER CHR(13)+CHR(10)

/**********************************************************************************************************************************/
/** Funcao   : FA050INC()                                                                                                        **/
/** Descricao: Validacoes executadas na inclusao manual de um título a ser pago SE2                                               **/
/**********************************************************************************************************************************/
User Function FA050INC()
 	// retorno
	Local lRet	:= .T.
	// cria o parametro e obtem o valor
	Local lAtivo:= StaticCall(M521CART,TGetMv,"  ","KA_CPVLDTD","L",.F.,"FA050INC - Impedir que a data de emissao do titulo a pagar seja diferente da database?" )

	// valida se nao existe a variavel
	If Type("lF050Auto") == "U"
		// nao é automatico
		lF050Auto := .F.
	Endif

	// se nao é rotina automatica e processo ativado e a data de emissao é diferente da database
	If !lF050Auto .and. lAtivo .and. M->E2_EMISSAO <> dDataBase 
		// informa o usuario e pergunta se deseja continuar
		lRet := MsgYesNo("A data de digitação é diferente da data base, deseja continuar mesmo assim?")
	Endif

	If Empty(M->E2_CCUSTO) .AND. M->E2_RATEIO <> "S"  .and. !lF050Auto
		MsgStop("Para confimar esse lançamento deve-se preencher o centro de custo!","Centro de Custo - FA050INC")
		lRet	:= .F.
	EndIf


	// retorna
Return lRet



