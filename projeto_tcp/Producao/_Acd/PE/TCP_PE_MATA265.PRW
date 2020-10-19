#Include "Protheus.ch"
#Include "TOPCONN.ch"
       
//-------------------------------------------------------------------------------
/*/{Protheus.doc} MTA265GRV
Alimenta campo padrão de endereço quando ele está vazio.

@return 
@author Felipe Toazza Caldeira
@since 15/01/2015

/*/
//-------------------------------------------------------------------------------
User Function MTA265GRV 
Local aAreaSb1	:= SB1->(GetArea()) 

	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))   
	SB1->(DbGoTop())
	If SB1->(DbSeek(xFilial('SB1')+SDB->DB_PRODUTO))
		If SB1->B1_LOCALIZ == 'S' //.AND. Empty(Alltrim(SB1->B1_ZLOCALI))
			RecLock('SB1',.F.)
			SB1->B1_ZLOCALI	:= SDB->DB_LOCALIZ
			SB1->(MsUnlock())
		EndIf
	EndIF        
	RestArea(aAreaSb1)
	
Return
