#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"        
#INCLUDE "RPTDEF.CH"   
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MEST003
Job para correção saldo estoque de baixas vindo de Pneus

@return 
@author Felipe Toazza Caldeira
@since 20/10/2016

/*/
//-------------------------------------------------------------------------------

User Function MEST003(cEmp,cFil) 
Local cQuery 	:= ""
Local cAux		:= ""

If Empty(cEmp)
	cEmp := '02'
	cFil := '01'
EndIf
                
PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil               

dDataAux := DtoS(dDataBase-50)
//dDataAux := SubStr(dDataAux,1,6)+'01'


cQuery := " SELECT *, R_E_C_N_O_ AS RECSD3 "
cQuery += " FROM "+RetSqlName('SD3')+" "
cQuery += " WHERE "
cQuery += "      D3_FILIAL = '"+cFil+"' AND D3_TM = '999' AND D3_COD NOT LIKE '%MOD%' AND D3_COD NOT LIKE '%MANUT%' AND D3_OP != ' ' "
cQuery += "  AND D3_LOCAL != '10' AND D3_LOCAL != '11' AND D3_EMISSAO >= '"+dDataAux+"' AND D3_CF = 'RE0' AND D_E_L_E_T_ != '*' "

TCQUERY cQuery NEW ALIAS "TMP"
dbSelectArea("TMP")		
TMP->(DbGoTop())
           
DbSelectArea('SB2')
SB2->(DbSetOrder(1))
DbSelectArea('SBF')
SBF->(DbSetOrder(1))
DbSelectArea('SD3')
SD3->(DbSetOrder(1))
SDB->(DbSetOrder(7))

While !TMP->(EOF()) 
	SB2->(DbGoTop())
	If SB2->(DbSeek(xFilial('SB2')+TMP->D3_COD+TMP->D3_LOCAL))
		cD3Doc :=TMP->D3_DOC
		RecLock('SB2',.F.)
		SB2->B2_QATU := SB2->B2_QATU + TMP->D3_QUANT
		SB2->B2_VATU1 := SB2->B2_VATU1 + (TMP->D3_QUANT*B2_CM1)
		SB2->(MsUnlock())
		           
		SBF->(DbSetOrder(1))		                     
		SBF->(DbGoTop())
		If SBF->(DbSeek(xFilial('SBF')+TMP->D3_LOCAL+TMP->D3_LOCALIZ+TMP->D3_COD))
			RecLock('SBF',.F.)
			SBF->BF_QUANT := SBF->BF_QUANT + TMP->D3_QUANT
			SBF->(MsUnlock())		                             
		Else             
			SBF->(DbSetOrder(2))
			SBF->(DbGoTop())
			If SBF->(DbSeek(xFilial('SBF')+TMP->D3_COD+TMP->D3_LOCAL))
				RecLock('SBF',.F.)
				SBF->BF_QUANT := SBF->BF_QUANT + TMP->D3_QUANT
				SBF->(MsUnlock())		                             		
			EndIf
		EndIf                           
		
		SD3->(DbGoTo(TMP->RECSD3))  
		RecLock('SD3',.F.)
		SD3->(DbDelete())
		SD3->(MsUnlock())		
		
		IF SDB->(DdSeek(xFilial('SDB')+TMP->D3_COD+cD3Doc))
			RecLock('SDB',.F.)
			SDB->(DbDelete())
			SDB->(MsUnlock())		
		EndIf
		
	EndIf	
	TMP->(DbSkip())	
EndDo

TMP->(DbCloseArea())

Return