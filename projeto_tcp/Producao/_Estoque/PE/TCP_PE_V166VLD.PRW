User Function V166VLD() 
Local cEtiqprod := PARAMIXB[1] 
Local nQtd      := PARAMIXB[2]
Local lRet := .T.
//Conout('cuzao')
dbSelectArea('SB1')
DbsetOrder(1)
IF SB1->(DBSeek(xFilial('SB1')+CB8->CB8_PROD)) .AND. SB1->B1_GRUPO $ GetMV("TCP_GRPINF") .AND. nQtd != CB8->CB8_SALDOS
	lRet := .F.
	VtAlert('Quantidade inválida. Retire o saldo total da OS. '+ALLTRIM(STR(nQtd)),'Aviso',.t.,4000,4) //"Aviso"
ENDIF

Return lRet
