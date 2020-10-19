#Include 'Protheus.ch'
#Include 'Topconn.ch'

//-------------------------------------------------------------------------------
/*/{Protheus.doc} QN040VLD
Rotina para alteração de pontuação de nota fiscal de entrada quando incluso FNC

@return 
@author Felipe Toazza Caldeira
@since 01/12/2015
/*/
//-------------------------------------------------------------------------------

User Function QN040VLD()
Local lRet 	:= .T.
Local cUpd	:= ""
              
IF M->QI2_CODEFE != '001'
	cUpd := " UPDATE "+RetSqlName('Z07')+" SET Z07_AVAL03 = 0 "
	cUpd += " WHERE Z07_FILIAL = '"+xFilial('Z07')+"' AND Z07_FORNEC = '"+M->QI2_CODFOR+"' AND Z07_LOJA = '"+M->QI2_LOJFOR+"'  "
	cUpd += " AND Z07_DOC = '"+M->QI2_DOCNF+"' AND Z07_SERIE = '"+M->QI2_SERNF+"' AND Z07_PRODUT = '"+M->QI2_CODPRO+"' AND D_E_L_E_T_ != '*' "
	
	TcSqlExec(cUPD)                                                                       
	
	cQuery := " SELECT Z07_FILIAL, Z07_FORNEC, Z07_LOJA, Z07_DOC, Z07_SERIE, Z07_REGRA, COUNT(*) AS CONTA, SUM(Z07_AVAL03) AS V003 "
	cQuery += " FROM "+RetSqlName('Z07')
	cQuery += " WHERE Z07_FILIAL = '"+xFilial('Z07')+"' AND Z07_FORNEC = '"+M->QI2_CODFOR+"' AND Z07_LOJA = '"+M->QI2_LOJFOR+"' " 
	cQuery += " AND Z07_DOC = '"+M->QI2_DOCNF+"' AND Z07_SERIE = '"+M->QI2_SERNF+"' AND D_E_L_E_T_ != '*' "
	cQuery += " GROUP BY Z07_FILIAL, Z07_FORNEC, Z07_LOJA, Z07_DOC, Z07_SERIE, Z07_REGRA "
	
	If (Select("Z07REG") <> 0)
		DbSelectArea("Z07REG")
		Z07REG->(DbCloseArea())
	Endif
			                                                                       	
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), "Z07REG",.T., .F.)
		
	DbSelectArea("Z07REG")
	Z07REG->(DbGoTop())	     
	
	IF !Z07REG->(EOF())
		cUpd := " UPDATE "+RetSqlName('Z06')+" SET Z06_PTDIG = "+STR(ROUND(Z07REG->V003/Z07REG->CONTA,0))+",Z06_PONTOS = "+STR(ROUND(Z07REG->V003/Z07REG->CONTA,0))+" "
		cUpd += " WHERE Z06_FILIAL = '"+xFilial('Z06')+"' AND Z06_FORNEC = '"+M->QI2_CODFOR+"' AND Z06_LOJA = '"+M->QI2_LOJFOR+"'  "
		cUpd += " AND Z06_NOTA = '"+M->QI2_DOCNF+"' AND Z06_SERIE = '"+M->QI2_SERNF+"' AND D_E_L_E_T_ != '*' AND Z06_CRITER = '003' " //qualidade documental		     
	
	EndIf 
	Z07REG->(DbCloseArea())
		
Else
	cUpd := " UPDATE "+RetSqlName('Z07')+" SET Z07_AVAL04 = 0 "
	cUpd += " WHERE Z07_FILIAL = '"+xFilial('Z07')+"' AND Z07_FORNEC = '"+M->QI2_CODFOR+"' AND Z07_LOJA = '"+M->QI2_LOJFOR+"'  "
	cUpd += " AND Z07_DOC = '"+M->QI2_DOCNF+"' AND Z07_SERIE = '"+M->QI2_SERNF+"' AND D_E_L_E_T_ != '*' "
	
	TcSqlExec(cUPD)

	cUpd := " UPDATE "+RetSqlName('Z06')+" SET Z06_PTDIG = 0, Z06_PONTOS = 0 "
	cUpd += " WHERE Z06_FILIAL = '"+xFilial('Z06')+"' AND Z06_FORNEC = '"+M->QI2_CODFOR+"' AND Z06_LOJA = '"+M->QI2_LOJFOR+"'  "
	cUpd += " AND Z06_NOTA = '"+M->QI2_DOCNF+"' AND Z06_SERIE = '"+M->QI2_SERNF+"' AND D_E_L_E_T_ != '*' AND Z06_CRITER = '004' " //qualidade documental
	
	TcSqlExec(cUPD)

EndIf              






Return lRet