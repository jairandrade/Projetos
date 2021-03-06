/**********************************************************************************************************************************/
/** SIGALOJA - Controle de Lojas                                                                                                 **/
/** Valida��o do campo LR_PRODUTO para sugest�o de produto e TES de venda                                                        **/
/** RSAC Solu��es Ltda.                                                                                                          **/
/** Kapazi Ind�stria Brasileira Ltda.                                                                                            **/
/**********************************************************************************************************************************/
/** Data       | Respons�vel                    | Descri��o                                                                      **/
/**********************************************************************************************************************************/
/** 26/03/2014 | Rog�rio Souza Pereira          | Cria��o da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "msole.ch"                                                                                      

/**********************************************************************************************************************************/
/** user function KLOJA01()                                                                                                      **/
/** Valida��o do campo LR_PRODUTO para sugest�o de produto e TES de venda                                                        **/
/**********************************************************************************************************************************/
user function KLOJA01()

  // variaveis auxiliares
  local lRet 		:= .T.
  local cLocPad 	:= GetNewPar("KP_LOCPAD", "01")
  local cTesPad 	:= GetNewPar("KP_LJTSPAD", "")
  local nPosLocal 	:= Ascan(aPosCpoDet, {|x| AllTrim(Upper(x[1])) == "LR_LOCAL"	})
  local nPosTes 	:= Ascan(aPosCpoDet, {|x| AllTrim(Upper(x[1])) == "LR_TES"		})
  local nPosLocaliz := Ascan(aPosCpoDet, {|x| AllTrim(Upper(x[1])) == "LR_LOCALIZ"	})
  // obtem o endereco padrao para a loja       
  Local cLocaliz	:= getEndLoja()
  
  // for�a o armaz�m do par�metro
  if nPosLocal > 0 .and. Len(aColsDet) > 0
    aColsDet[N][nPosLocal] := cLocPad
  endIf
                                 
  // for�a o TES do par�metro
  if nPosTes > 0 .and. Len(aColsDet) > 0 .and. !Empty(cTesPad)
    aColsDet[N][nPosTes] := cTesPad
  endIf
  
  if nPosLocaliz > 0 .and. Len(aColsDet) > 0 .and. !Empty(cLocaliz)
    aColsDet[N][nPosLocaliz] := cLocaliz
  endIf
                                                                                                                                      
return lRet


/**********************************************************************************************************************************/
/** Static Function getEndLoja()                                                                                                 **/
/** retorna o endereco padrao SBE da loja.                                                                                       **/
/**********************************************************************************************************************************/
Static Function getEndLoja()
	// usuario atual
	Local cUser:= AllTrim( UsrRetName( RetCodUsr() ) )
	
	// obtem do parametro
	Local cRet := GetMv("KA_"+cUser,, Space(TamSX3("LR_LOCALIZ")[1])  )

	// adiciona espacos ao final
	cRet := Padr(cRet,TamSx3("LR_LOCALIZ")[1])
	
	// retorna
Return cRet

