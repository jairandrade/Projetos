#include "protheus.ch"
#include "rwmake.ch"
#include "TOPCONN.ch"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MT116AGR
Ponto de entrada para alteração de titulos financeiros

@return 
@author Felipe Toazza Caldeira
@since 03/09/2015

/*/
//-------------------------------------------------------------------------------
User Function MT116AGR() 
      	
//    If GetMv('TCP_AVAAUT')	           	
		U_ACOM009()
//	EndIf

Return                              



User Function MT116GRV()
Local cQryForn := ""

	cQryForn := " SELECT SF1.* FROM "+RetSqlName('SF1')+" SF1, "+RetSqlName('Z06')+" Z06 "
 	cQryForn += " WHERE "
	cQryForn += " 		F1_FILIAL 	= Z06_FILIAL "
	cQryForn += " AND 	F1_DOC 		= Z06_NOTA  "
	cQryForn += " AND 	F1_SERIE 	= Z06_SERIE  "
	cQryForn += " AND 	F1_FORNECE 	= Z06_FORNEC  "
	cQryForn += " AND 	F1_LOJA 	= Z06_LOJA  "
	cQryForn += " AND 	F1_AVALFOR 	= ' '  "			
	cQryForn += " AND 	F1_ESPECIE 	= 'CTR'  "			
	cQryForn += " AND 	SF1.D_E_L_E_T_ != '*' "				
	cQryForn += " AND 	Z06.D_E_L_E_T_ != '*' "	

	TCQuery cQryForn Alias 'TMPSF1' NEW
	dbSelectArea('TMPSF1') 
	TMPSF1->(DbGoTop())     
        
	DbSelectArea("SF1")
	SF1->(DbSetOrder(1))
	While !TMPSF1->(EOF())  
		SF1->(DbGoTop())	
		If SF1->(DbSeek(TMPSF1->F1_FILIAL+TMPSF1->F1_DOC+TMPSF1->F1_SERIE+TMPSF1->F1_FORNECE+TMPSF1->F1_LOJA))	
			RecLock('SF1')
			SF1->F1_AVALFOR := '1'			
			MsUnlock()
		EndIf					       
	   	TMPSF1->(DbSkip())
	EndDo

	TMPSF1->(DbCloseArea())   			   
				
Return
