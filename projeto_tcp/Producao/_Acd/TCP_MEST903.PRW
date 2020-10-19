//-------------------------------------------------------------------------------
/*/{Protheus.doc} MEST903
Rotina para zerar saldos de estoque via inventário

@return 
@author Felipe Toazza Caldeira
@since 23/11/2015

/*/
//-------------------------------------------------------------------------------
#include "totvs.ch"
#include "protheus.ch"               
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "TBICONN.CH"
                                    

User Function MEST903()    
Private lAbort := .T.         
	 
	Processa ( {|lEnd| Importa(@lEnd) }, "Atualizando custos..."," Aguarde...",lAbort)

Return
                                   

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Importa
Rotina para leitura do arquivo e importação

@return 
@author Felipe Toazza Caldeira
@since 23/11/2015

/*/
//-------------------------------------------------------------------------------
Static Function Importa(lEnd)
Local cPerg		:= Padr("RCOM002M",10)


If MsgYesNo('Esta rotina irá alimentar a planilha de inventário com informações para zerar o saldo de estoque. Deseja continuar?')
	DbSelectArea('SB2')
	SB2->(DbSetOrder(1))
	SB2->(DbGoTop())   
	While !SB2->(EOF())
		If SB2->B2_QATU > 0
			RecLock('SB7',.T.)
			SB7->B7_FILIAL 		:= SB2->B2_FILIAL
			SB7->B7_COD 		:= SB2->B2_COD
			SB7->B7_LOCAL 		:= SB2->B2_LOCAL 
			SB7->B7_DOC		:= 'ZERAEST'
			SB7->B7_TIPO		:= Posicione('SB1',1,SB2->B2_FILIAL+SB2->B2_COD,"B1_TIPO")
			SB7->B7_QUANT		:= 0
			SB7->B7_DATA		:= dDataBase
			SB7->B7_NUMDOC 		:= 'INVENT '
			SB7->B7_STATUS 		:= '1'	
			SB7->B7_CONTAGE 	:= '1'			 		
			SB7->B7_ORIGEM 		:= 'MATA270'	 		
			MsUnlock()     
		EndIf     
		SB2->(DbSkip())
	EndDo

	ApMsgInfo("Alimentação de invnetário com valor zero efetuada com sucesso!","[MEST903] - SUCESSO")
EndIf         


Return                                                                       

