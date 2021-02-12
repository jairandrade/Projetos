
#include "TOPCONN.CH"
/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** ponto de entrada para validar se permite altera o pedido de venda.                                                   		 **/
/** Ponto de entrada M410ALOK                                																	 **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    	 **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
User Function M410ALOK()
	// area atual
	Local aArea		:=	GetArea()
	// retorno
	Local lRet		:= .T.
	// mensagem
	Local cMsg		:= ""
	// pedido veio do fluig 
	Local lFluig	:= StaticCall(KFATA13,fromFluig,SC5->C5_NUM)
	
	// se ativado e pedido do fluig e nao sao rotinas que alteram o pedido para nf mista
	If GetMv("KA_FLUIGPV",,.t.) .and. lFluig .and. ( !IsInCallStack("xProcPvNFSE") .and. !IsInCallStack("xAltPedOri") )
	    // nao permite alterar o pedido
		lRet := .F.
		// altera msg de erro
		cMsg := "Pedido originário do FLUIG não pode ser alterado."
	Endif
		
	// se erro
	If !lRet
		// exibe msg de erro
		MsgStop(cMsg)
	Endif
	
	// restaura a area
	RestArea(aArea)
	// sai da funcao
Return lRet



