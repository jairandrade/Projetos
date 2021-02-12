#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: VLFATNFM		|	Autor: Luis Paulo							|	Data: 02/04/2018	//
//==================================================================================================//
//	Descrição: Validacao para ver se tem algum titulo baixado no financeiro							//
//																									//
//==================================================================================================//
User Function VLFATNFM(cIdNFM)
Local cIdTNFM	:= cIdNFM
Local cQry		:= ""
Local aRet		:= { .T.,.T.}

cQry	+= " SELECT E1_SALDO,E1_VALOR,E1_PREFIXO
cQry	+= " FROM SE1040
cQry	+= " WHERE D_E_L_E_T_ = ''
cQry	+= " AND E1_XIDVNFK = '"+cIdNFM+"'
//cQry	+= " AND E1_PREFIXO <> 'FAT'

If Select('TRBE1N')<>0
	DbSelectArea('TRBE1N')
	TRBE1N->(DbCloseArea())
Endif

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), 'TRBE1N', .F., .T.)
TRBE1N->(DbGoTop())

While !TRBE1N->(EOF())
	
	If TRBE1N->E1_SALDO != TRBE1N->E1_VALOR
		aRet[1]	:= .F.
	EnDIf
	
	If Alltrim(TRBE1N->E1_PREFIXO) == 'FAT'
		aRet[2]	:= .F.
	EndIf
	
	TRBE1N->(DbSkip())
EndDo

TRBE1N->(DbCloseArea())	
Return(aRet)