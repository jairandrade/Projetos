#include "rwmake.ch"
#INCLUDE "protheus.ch"
#include "topconn.ch"

/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** Exclusao da nota fiscal de saida                                                                                      		 **/
/** Ponto de entrada M520QRY                																					 **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
/**********************************************************************************************************************************/
/** Adiciona filtro na query da rotina.                                                                                          **/
/**********************************************************************************************************************************/
User Function M520QRY()
	// recebe o filtro da query
	Local cQry	:= PARAMIXB[1]
	
	// se o campo existe e filtra somente do usuario atual
	If SF2->( FieldPos("F2_K_USRCO") ) > 0 .and. MsgYesNo("Filtrar notas emitidas somente pelo seu usuário?")
		// adiciona a condicao
		cQry += " AND F2_K_USRCO = '"+RetCodUsr()+"' "
	Endif
	
	// retorna
Return cQry