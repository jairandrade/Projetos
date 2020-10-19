#include "PROTHEUS.CH"
#include "TOPCONN.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} SD3240E
Verifica se o item estornado tem Ordem de Separação e realizado a atualização na CB8                 

@author Felipe Toazza Caldeira
@since 11/01/2017
@version 1.0
@obs 
/*/
//-------------------------------------------------------------------    
User Function SD3240E()                     
Local cQuery := ""

	cQuery := " SELECT * FROM "+RETSQLNAME('CB9')
	cQuery += " WHERE "
	cQuery += "       CB9_FILIAL = '"+xFilial('CB9')+"' AND CB9_PROD = '"+M->D3_COD+"' AND CB9_DOC = '"+M->D3_DOC+"' AND D_E_L_E_T_ != '*' "	
	
	If (Select("TMPCB9") <> 0)
		DbSelectArea("TMPCB9")
		TMPCB9->(DbCloseArea())
	Endif
					                                                                       	
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "TMPCB9",.T., .F.)
	DbSelectArea("TMPCB9")
	TMPCB9->(DbGoTop())
	
	If !TMPCB9->(EOF())
		DbSelectArea('CB8')
		CB8->(DbSetOrder(1))
		CB8->(DbGoTop())
		CB8->(DbSeek(xFilial('CB8')+TMPCB9->CB9_ORDSEP))
		While !CB8->(EOF()) .AND. CB8->CB8_FILIAL == TMPCB9->CB9_FILIAL .AND. CB8->CB8_ORDSEP == TMPCB9->CB9_ORDSEP
			IF CB8->CB8_PROD == M->D3_COD
				RecLock('CB8',.F.)
				CB8->CB8_SALDOS := CB8->CB8_SALDOS+M->D3_QUANT
				CB8->CB8_XQTDEV := CB8->CB8_XQTDEV+M->D3_QUANT
				CB8->(MsUnlock())
		                                 
		 	EndIf
			CB8->(DbSkip())
		EndDo
		
	
	EndIf	
	
	TMPCB9->(DbCloseArea())

Return