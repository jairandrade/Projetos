
#include "rwmake.ch"
#include "topconn.ch"
#include "totvs.ch"
#include "protheus.ch"
#include 'hbutton.ch'
user Function validaA()



	cQery :=" SELECT C1_USER,Y1_GRAPROV,SUM(C7_TOTAL)C7_TOTAL "
	cQery +=" FROM "+RetSqlName('SC7')+" SC7 "
	cQery +=" LEFT JOIN "+RetSqlName('SC1')+" SC1 ON C1_FILIAL = C7_FILIAL AND C1_NUM = C7_NUMSC
	cQery +=" AND C1_PRODUTO = C7_PRODUTO AND SC1.D_E_L_E_T_ =' ' "
	cQery +=" INNER JOIN "+RetSqlName('SY1')+" SY1 ON Y1_USER = C1_USER AND SY1.D_E_L_E_T_ =' ' "
	cQery +=" WHERE C7_NUM ='"+'013757'+" ' "
	cQery +=" AND C7_FILIAL='"+'07'+" ' "
	cQery +=" AND SC7.D_E_L_E_T_ =' ' "
	cQery +=" GROUP BY C1_USER,Y1_GRAPROV "

	If ( SELECT("TRAB2") ) > 0
		dbSelectArea("TRAB2")
		TRAB2->(dbCloseArea())
	EndIf

	TCQUERY cQery NEW ALIAS "TRAB2"
	if TRAB2->C7_TOTAL >= 1500
		
		cDestino :="jair.andrade@abix.com.br"
		cAssunto := "Incluido aprovação manualmente do pedido: " + '013757'
		cMensagem := "Incluido valor maior que 1500" 
		U_MailTo(cDestino, cAssunto, cMensagem )

        else
            
            cDestino :="jair.andrade@abix.com.br"
		cAssunto := "Incluido aprovação manualmente do pedido: " + sc7->c7_num
		cMensagem := "Incluido valor menor que 1500" 
		U_MailTo(cDestino, cAssunto, cMensagem )
	endif
return
