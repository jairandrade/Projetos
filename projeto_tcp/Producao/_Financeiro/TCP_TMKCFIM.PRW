//-------------------------------------------------------------------
/*/{Protheus.doc} TMKCFIM
Ponto de entrada no final da gravação do telecobrança.

@author Suelen Regina de Souza
@since 27/12/2013
@version P11
/*/
//-------------------------------------------------------------------
#include "totvs.ch"
#include "protheus.ch"                                                                      
#INCLUDE "topconn.ch"

User Function TMKCFIM()
Local cQuery 	:= ""
Local nSeqZ18 	:= 0                                            
Local _cMemo	:= ""               


IF funname() == "TMKA350" .OR. funname() == "TMKA280"  .OR. funname() == "TMKA380"


	cQuery := " SELECT MAX(Z18_ORDEM) AS Z18_ORDEM "
	cQuery += " FROM "+RetSqlName('Z18')
	cQuery += " WHERE "
	cQuery += "      Z18_FILIAL = '"+xFilial('Z18')+"' AND Z18_CODIGO = '"+ACF->ACF_CODIGO+"' AND D_E_L_E_T_ != '*' "
	
	If (Select("QRYZ18") <> 0)
		DbSelectArea("QRYZ18")
		QRYZ18->(DbCloseArea())
	Endif
	
	
	TCQUERY cQuery NEW ALIAS "QRYZ18"
	DbSelectArea('QRYZ18')
	QRYZ18->(DbGoTop())
	
	If !QRYZ18->(EOF())
		nSeqZ18 := QRYZ18->Z18_ORDEM
	EndIf 
	
	QRYZ18->(DbCloseArea()) 
	
	nSeqZ18++
		
	RECLOCK("Z18",.T.)
	Z18->Z18_FILIAL := ACF->ACF_FILIAL
	Z18->Z18_CODIGO := ACF->ACF_CODIGO
	Z18->Z18_CLIENT := ACF->ACF_CLIENT
	Z18->Z18_LOJA   := ACF->ACF_LOJA
	Z18->Z18_OPERAD := TkOperador()
	Z18->Z18_STATUS := ACF->ACF_STATUS
	Z18->Z18_DATA   := dDatabase
	Z18->Z18_HORA   := Time()  
	Z18->Z18_ORDEM  := nSeqZ18
	Z18->Z18_TIPOOP := ACF->ACF_OPERA
	Z18->Z18_CODCON := ACF->ACF_CODCON
	Z18->Z18_OBS	:= ACF->ACF_OBSLIG	
	Z18->(MsUnlock())


	_cMemo	:= MSMM(ACF->ACF_CODOBS,,,,3) 
	_cMemo	+= chr(13)+chr(10)+ACF->ACF_OBSLIG
	RECLOCK("ACF",.F.)   
	ACF->ACF_OBSLIG	:= ""
	ACF->(MsUnlock())   
	MSMM(ACF->ACF_CODOBS,,,_cMemo,1,,,"ACF","ACF_CODOBS")

	
ENDIF

Return
