/*/{Protheus.doc} Kapazi
Invoca o processo de liberação automática
@type function
 
@author Rodolpho Leal
@since 11/07/2019
@version 1.0
/*/

#Include "TOTVS.CH"

User Function LIBERACREDEST(PEDIDO, CLIENTE) 
	
	Local aArea := GetArea()
	Local cAlias := 'SA9'
	local lReturn
	
	MV_PAR01 := PEDIDO //'000001' //C9_PEDIDO >=
	MV_PAR02 := PEDIDO//'999999' //C9_PEDIDO <=
	MV_PAR03 := CLIENTE//'000001' //C9_CLIENTE >=
	MV_PAR04 := CLIENTE// '999999' //C9_CLIENTE <=

	MV_PAR05 := CTOD('20190101') //C6_ENTREG >=
	MV_PAR06 := CTOD('20401231') //C6_ENTREG <=

	lAvCred := .T. // Avalia Credito
	lAvEst := .T. // Avalia Estoque
	lEnd := .F.
	lEmpresa := .F.
	lAvWMS := .F.
	lLogMsg := .F.
	
	//DbSelectArea("SM0")
	
	if Ma450Proces(cAlias, lAvCred, lAvEst, lEnd, lEmpresa, lAvWMS, lLogMsg)
		conout('Liberação Automática realizada com sucesso.')
		lReturn:= .T.
	Else
		RecLock('ZA1', .F.)
		ZA1->ZA1_STATUS:='E' //Erro
		ZA1->ZA1_LOG:='Erro na integração: Erro liberação credito estoque. (Ma450Proces)'
		ZA1->ZA1_DATA:=Date()
		ZA1->ZA1_HORA:=Time()
		MsUnlock()
		conout('Falha na liberação automatica.')
		lReturn:= .F.
	endIf
	
	RestArea(aArea)
			
Return lReturn