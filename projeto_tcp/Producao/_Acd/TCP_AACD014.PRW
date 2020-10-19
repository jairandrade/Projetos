#include "apwebex.ch"
#include 'protheus.ch'
 
User Function AACD014()
                                  
	If CB7->CB7_STATUS != '0' .AND. CB7->CB7_STATUS != '1'
		MsgInfo('Esta ordem não pode ser fechada pois não possui status em aberto ou em andamento!')
	EndIf 

	If MsgYesNo('Deseja realmente fechar a ordem de separação '+CB7->CB7_ORDSEP+'?')
		RecLock('CB7',.F.)
		CB7->CB7_STATUS := '9'
		CB7->CB7_DTFIMS := dDataBase
		CB7->CB7_HRFIMS := SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)+SUBSTR(TIME(), 7, 2) 
		CB7->CB7_STATPA := ' '
		MsUnlock()
		
		DbSelectArea('CB8')
		CB8->(DbSetOrder(1))
		CB8->(DbGoTop())
		CB8->(DbSeek(CB7->CB7_FILIAL+CB7->CB7_ORDSEP))
		
		While !CB8->(EOF()) .AND. CB8->CB8_FILIAL+CB8->CB8_ORDSEP == CB7->CB7_FILIAL+CB7->CB7_ORDSEP
			If  CB8->CB8_SALDOS > 0 
				RecLock('CB8',.F.)
				CB8->CB8_XQTDEV := CB8->CB8_SALDOS
				MsUnlock()					
			EndIf             
			CB8->(DbSkip())
		EndDo
	
	EndIf
 	
return




