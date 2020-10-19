#Include 'Protheus.ch'
#Include 'Topconn.ch'

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM009
Rotina para avaliação automática de fornecedores

@return 
@author Felipe Toazza Caldeira
@since 27/11/2015
/*/
//-------------------------------------------------------------------------------
User Function ACOM009()    
Local nX   
Local nI
Local nCrit
local aFields 		:= {'Z07_PEDIDO', 'Z07_ITEMPC' ,'Z07_ITEMNF','Z07_PRODUT','Z07_DESC','Z07_QTDNF','Z07_QTDPED','Z07_TOTAL','Z07_DTPREV','Z07_DTREAL' }
Private cFornece 	:= SF1->F1_FORNECE
Private cLoja 		:= SF1->F1_LOJA
Private cNome 		:= IF(!SF1->F1_TIPO$'BD',Posicione('SA2',1,xFilial('SA2')+cFornece+cLoja,"A2_NOME"),Posicione('SA1',1,xFilial('SA1')+cFornece+cLoja,"A1_NOME"))
Private cNF			:= SF1->F1_DOC
Private cSerie		:= SF1->F1_SERIE
Private cCondPgt	:= Posicione('SE4',1,xFilial('SE4')+SF1->F1_COND,"E4_COND")
Private cEspecie	:= SF1->F1_ESPECIE
Private cRegra		:= ""
Private nPontos		:= 0
Private cClassif	:= " "  
Private aNotas		:= {}
Private nLaco		:= 0           
Private aRegra		:= {}
Private aFieldFill	:= {}
Private aCab		:= {}
Private aItens		:= {}
                                           
	If SD1->D1_ORIGLAN == 'FR'      
		cFornece 	:= SD1->D1_FORNECE
		cLoja 		:= SD1->D1_LOJA
		cNome 		:= IF(!SD1->D1_TIPO$'BD',Posicione('SA2',1,xFilial('SA2')+cFornece+cLoja,"A2_NOME"),Posicione('SA1',1,xFilial('SA1')+cFornece+cLoja,"A1_NOME"))
		cNF			:= SD1->D1_DOC
		cSerie		:= SD1->D1_SERIE	
		cEspecie	:= "CTR"
	EndIf
	
	cQry := " SELECT * FROM "+RetSqlName('Z03')+" WHERE "
	cQry += "      Z03_FILIAL = '"+xFilial('Z03')+"' AND Z03_INICIO <= '"+DtoS(dDataBase)+"' "
	cQry += " AND (Z03_FIM >= '"+DtoS(dDataBase)+"' OR Z03_FIM = ' ')AND D_E_L_E_T_ != '*'  "

	If (Select("Z03REG") <> 0)
  		DbSelectArea("Z03REG")
   		Z03REG->(DbCloseArea())
    Endif
		                                                                       	
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQry), "Z03REG",.T., .F.)
	
	DbSelectArea("Z03REG")
	Z03REG->(DbGoTop())	     
	If !Z03REG->(EOF())  
		cRegra := Z03REG->Z03_CODIGO
	Else
		Alert('Não existem regras vigentes para avaliação de Nota Fiscal de forma automatizada!')
		Return .F.
	EndIf    
	Z03REG->(DbCloseArea())

	If Alltrim(cEspecie) == 'CTR' .OR. Alltrim(cEspecie) == 'CTE'
		cQueryGrd := " SELECT SD1.* FROM "+RetSqlName('SD1')+" SD1 "
		cQueryGrd += " WHERE SD1.D1_FILIAL = '"+xFilial('SD1')+"' AND SD1.D1_DOC = '"+cNF+"' AND SD1.D1_SERIE = '"+cSerie+"' "
		cQueryGrd += "   AND SD1.D1_FORNECE = '"+cFornece+"' AND SD1.D1_LOJA = '"+cLOJA+"' AND  SD1.D_E_L_E_T_ != '*' "    
	    cTipAux := 'CTR'
	Else
		cQueryGrd := " SELECT SD1.*, SC7.* FROM "+RetSqlName('SD1')+" SD1, "+RetSqlName('SC7')+" SC7 "
		cQueryGrd += " WHERE SD1.D1_FILIAL = '"+xFilial('SD1')+"' AND SD1.D1_DOC = '"+SF1->F1_DOC+"' AND SD1.D1_SERIE = '"+SF1->F1_SERIE+"' "
		cQueryGrd += "   AND SD1.D1_FORNECE = '"+SF1->F1_FORNECE+"' AND SD1.D1_LOJA = '"+SF1->F1_LOJA+"' AND  SD1.D_E_L_E_T_ != '*' "   
		cQueryGrd += "   AND SD1.D1_FILIAL = SC7.C7_FILIAL AND SD1.D1_PEDIDO = SC7.C7_NUM AND SD1.D1_ITEMPC = SC7.C7_ITEM   "
		cQueryGrd += "   AND SD1.D1_COD = SC7.C7_PRODUTO AND SC7.D_E_L_E_T_ != '*' "   
		cTipAux	:= 'NFE'
	EndIf

	If (Select("TMPGRD") <> 0)
   		DbSelectArea("TMPGRD")
   		TMPGRD->(DbCloseArea())
    Endif
		
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQueryGRD), "TMPGRD",.T., .F.)
		
	DbSelectArea("TMPGRD")
	TMPGRD->(DbGoTop())
	
	If TMPGRD->(EOF())                 
		cQueryGrd := " SELECT SD1.* FROM "+RetSqlName('SD1')+" SD1 "
		cQueryGrd += " WHERE SD1.D1_FILIAL = '"+xFilial('SD1')+"' AND SD1.D1_DOC = '"+cNf+"' AND SD1.D1_SERIE = '"+cSerie+"' "
		cQueryGrd += "   AND SD1.D1_FORNECE = '"+cFornece+"' AND SD1.D1_LOJA = '"+cLoja+"' AND  SD1.D_E_L_E_T_ != '*' "   

   		DbSelectArea("TMPGRD")
   		TMPGRD->(DbCloseArea())

		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQueryGRD), "TMPGRD",.T., .F.)
		TMPGRD->(DbGoTop())
		cTipAux := "CTR"
	
//		Alert('Essa nota não poderá ser avaliada pois a mesma não está vinculada a Pedidos de Compras!')     
//		Return()
	EndIf 

	cQryHdr := " SELECT SUBSTRING(Z04_DESC,1,10) AS TITULO, * FROM "+RetSqlName('Z04')+" WHERE "
	cQryHdr += "      Z04_FILIAL = '"+xFilial('Z04')+"' AND Z04_REGRA = '"+cRegra+"' AND Z04_ACAO = '1' AND D_E_L_E_T_ != '*' ORDER BY Z04_CRITER "

	If (Select("Z04HDR") <> 0)
  		DbSelectArea("Z04HDR")
   		Z04HDR->(DbCloseArea())
    Endif
		
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQryHdr), "Z04HDR",.T., .F.)
	
	DbSelectArea("Z04HDR")
	Z04HDR->(DbGoTop())	     
	While !Z04HDR->(EOF())           
		aADD(aFields,Z04HDR->TITULO)
		AADD(aRegra,Z04HDR->Z04_CRITER)
		AADD(aNotas,0)
		Z04HDR->(DbSkip())
	EndDo              
	//*********************************************************************************

	for nX := 1 to len(aFields)
		if Z07->(FieldPos(aFields[nX])) > 0
			aAdd(aFieldFill, criaVar(aFields[nX], .F.))
		Else
			aAdd(aFieldFill, criaVar("Z04_PESO", .F.))
		endIf
	next nX 

    nLaco := 0
	While !TMPGRD->(EOF())
		If cTipAux == 'CTR' .OR. cTipAux == 'CTE'
			aFieldFill[1]  := TMPGRD->D1_PEDIDO 
			aFieldFill[2]  := TMPGRD->D1_ITEMPC
			aFieldFill[3]  := TMPGRD->D1_ITEM 				
			aFieldFill[4]  := TMPGRD->D1_COD  			
			aFieldFill[5]  := TMPGRD->D1_DESCRI  			
			aFieldFill[6]  := TMPGRD->D1_QUANT  			
			aFieldFill[7]  := TMPGRD->D1_QUANT//IIF(TMPGRD->C7_QUANT==TMPGRD->C7_QUJE,TMPGRD->C7_QUANT,TMPGRD->C7_QUANT-TMPGRD->C7_QUJE)     			
			aFieldFill[8]  := TMPGRD->D1_TOTAL  			
			aFieldFill[9]  := SF1->F1_RECBMTO   			
			aFieldFill[10]  := SF1->F1_RECBMTO
			For nCrit := 1 to Len(aRegra)   
				aFieldFill[10+nCrit]  := CalcRegra(cRegra,aRegra[nCrit])
				aNotas[nCrit] += aFieldFill[10+nCrit]	
			Next
		Else 				
			aFieldFill[1]  := TMPGRD->D1_PEDIDO
			aFieldFill[2]  := TMPGRD->D1_ITEMPC
			aFieldFill[3]  := TMPGRD->D1_ITEM 				
			aFieldFill[4]  := TMPGRD->D1_COD  			
			aFieldFill[5]  := TMPGRD->D1_DESCRI  			
			aFieldFill[6]  := TMPGRD->D1_QUANT  			
			aFieldFill[7]  := TMPGRD->C7_QUANT//IIF(TMPGRD->C7_QUANT==TMPGRD->C7_QUJE,TMPGRD->C7_QUANT,TMPGRD->C7_QUANT-TMPGRD->C7_QUJE)     			
			aFieldFill[8]  := TMPGRD->D1_TOTAL  			
			aFieldFill[9]  := StoD(TMPGRD->C7_DATPRF)   			
			aFieldFill[10]  := SF1->F1_RECBMTO
			For nCrit := 1 to Len(aRegra)
				aFieldFill[10+nCrit]  := CalcRegra(cRegra,aRegra[nCrit])
				aNotas[nCrit] += aFieldFill[10+nCrit]	
			Next
		EndIf		
		aAdd(aItens, aClone(aFieldFill))		                                                                                                    			
		nLaco++
		TMPGRD->(DbSkip())
	EndDo	                                                                                                    	
	
	If (Select("TMPGRD") <> 0)
   		DbSelectArea("TMPGRD")
   		TMPGRD->(DbCloseArea())
    Endif
	
	nPontos := 0

	DbSelectArea('Z04')
	Z04->(DbSetOrder(1))
	Z04->(DbGoTop())
	Z04->(DbSeek(xFilial('Z04')+cRegra))
                    
	nAux := 1  
	While !Z04->(EOF()) .AND. xFilial('Z04')+Z04->Z04_REGRA == xFilial('Z04')+cRegra
		aFieldFill[1]  := Z04->Z04_CRITER
		aFieldFill[2]  := Z04->Z04_DESC  				
		aFieldFill[3]  := Z04->Z04_PESO 
		aFieldFill[4]  := IIF(Z04->Z04_ACAO=='2',Z04->Z04_PESO,IIF(nAux<=Len(aNotas),aNotas[nAux]/nLaco,0))  
		aFieldFill[5]  := IIF(Z04->Z04_ACAO=='2',Z04->Z04_PESO,IIF(nAux<=Len(aNotas),aNotas[nAux]/nLaco,0))  			
		aFieldFill[6]  := Space(len(Z06->Z06_OBS))  				
		 	
		nPontos += aFieldFill[5] 	
		 			
		aAdd(aCab, aClone(aFieldFill))		                                                                                                    			
		nAux++
		Z04->(DbSkip())
	EndDo	

                      
		
	cQueryC := " SELECT Z02_CLASSI, Z02_SITUAC "
	cQueryC += " FROM "+RetSqlName('Z02')+" Z02 "
	cQueryC += " WHERE "
	cQueryC += "      Z02_FILIAL = '"+xFilial('Z02')+"' AND Z02.D_E_L_E_T_ != '*' " 
	cQueryC += "  AND "+Str(nPontos)+" >= Z02_NTMIN AND "+Str(nPontos)+" <= Z02_NTMAX "
	
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQueryC), "TMPSUM",.T., .F.)
			
	DbSelectArea("TMPSUM")
	TMPSUM->(DbGoTop())
 	cClassif	:= TMPSUM->Z02_CLASSI 
 	cNomClass   := TMPSUM->Z02_SITUAC  
	TMPSUM->(DbCloseArea())	
    
	//Só grava se a nota tiver pontuação total

	If Round(nPontos,0) == 100
		For nI := 1 to Len(aItens)
	   		RecLock("Z07",.T.)
		    Z07->Z07_FILIAL		:= xFilial('Z07')	
		    Z07->Z07_FORNECE  	:= cFornece
		    Z07->Z07_LOJA    	:= cLoja
		    Z07->Z07_DOC  		:= cNf
		    Z07->Z07_SERIE     	:= cSerie
		    Z07->Z07_REGRA      := cRegra
		    Z07->Z07_PEDIDO     := aItens[nI,1]
		    Z07->Z07_ITEMNF     := aItens[nI,3]
		    Z07->Z07_PRODUT     := aItens[nI,4]
		    Z07->Z07_QTDNF      := aItens[nI,6]
		    Z07->Z07_QTDPED     := aItens[nI,7]
		    Z07->Z07_TOTAL      := aItens[nI,8]
		    Z07->Z07_DTPREV     := aItens[nI,9]
		    Z07->Z07_DTREAL     := aItens[nI,10]
		    If LEN(aItens[nI]) >= 11 .AND. VALTYPE(aItens[nI,11]) == 'N'
				Z07->Z07_AVAL01		:= aItens[nI,11]     
			EndIf         
		    If LEN(aItens[nI]) >= 12 .AND. VALTYPE(aItens[nI,12]) == 'N'
				Z07->Z07_AVAL02		:= aItens[nI,12]     
			EndIf
		    If LEN(aItens[nI]) >= 13 .AND. VALTYPE(aItens[nI,13]) =='N'
				Z07->Z07_AVAL03		:= aItens[nI,13]     
			EndIf
		    If LEN(aItens[nI]) >= 14 .AND. VALTYPE(aItens[nI,14]) =='N'
				Z07->Z07_AVAL04		:= aItens[nI,14]
			EndIf
		    If LEN(aItens[nI]) >= 15 .AND. VALTYPE(aItens[nI,15]) =='N'
				Z07->Z07_AVAL05		:= aItens[nI,15]     
			EndIf
			Z07->Z07_COMPRA			:= SF1->F1_IDCOMPR
			MsUnlock()
	
		Next
	
		For nI := 1 to Len(aCab)
	   		RecLock("Z06",.T.)  
		    Z06->Z06_FILIAL		:= xFilial('Z06')	
		    Z06->Z06_FORNEC  	:= cFornece
		    Z06->Z06_LOJA    	:= cLOJA
		    Z06->Z06_NOTA  		:= cNf
		    Z06->Z06_SERIE     	:= cSerie
		    Z06->Z06_REGRA  	:= cRegra
		    Z06->Z06_CRITER    	:= aCab[nI,1]
		    Z06->Z06_DCRITE    	:= aCab[nI,2]
		    Z06->Z06_PESO  		:= aCab[nI,3] 
		    Z06->Z06_PONTOS     := aCab[nI,4] 
		    Z06->Z06_PTDIG 		:= aCab[nI,5] 
		    Z06->Z06_OBS     	:= aCab[nI,6]      
		    Z06->Z06_DATA		:= SD1->D1_DTDIGIT
		    Z06->Z06_COMPRA		:= SF1->F1_IDCOMPR
			MsUnlock()
		Next  
		
		If cEspecie == 'CTE' .OR. cEspecie == 'CTR'
			DbSelectArea('SF1')
			SF1->(DbSetOrder(1))
			SF1->(DbGoTop())
			If SF1->(DbSeek(xFilial('SF1')+Padr(cNf,Len(SF1->F1_DOC))+Padr(cSerie,Len(SF1->F1_DOC))+Padr(cFornece,Len(SF1->F1_DOC))+Padr(cLoja,Len(SF1->F1_DOC))))     
				RecLock("SF1",.F.)
				SF1->F1_AVALFOR := '1'
				MsUnlock()
			EndIf
		Else
			RecLock("SF1",.F.)
			SF1->F1_AVALFOR := '1'
			MsUnlock()
		EndIf
		            
	EndIf
           
return .T.
                       
                                                       
Static Function CalcRegra(cRegra,cCritic)
Local nPt 		:= 0      
Local cCampoUt 	:= ""
Local cTabela	:= ""        
Local cQryReg 	:= ""		            
Local cQryPt	:= ""              

Private xComp

          
DbSelectArea('Z05')
Z05->(DbSetOrder(1))
Z05->(DbGotop())
If Z05->(DbSeek(xFilial('Z05')+cRegra+cCritic)) 				//PROCURA REGRA QUE ESTÁ SENDO UTILIZADA
	cCampoUt := Z05->Z05_CAMPO 									// VERIFICA QUAL O CAMPO DE COMPARAÇÃO    
	cTabAux := SubStr(Z05->Z05_CAMPO,1,AT("_",Z05->Z05_CAMPO)-1) 	// BUSCA NOME DA TABELA  
	If Len(Alltrim(cTabAux)) == 2 								// verificar se é uma tabela iniciada com S ou não 
		cTabela := "S"+cTabAux  
	Else 
		cTabela := cTabAux
	EndIf             
       
    // ==============================================
    // BUSCA INFORMAÇÕES PARA COMPARAÇÃO
    //===============================================
	If cTabela == 'SD1'
		cQryReg := " SELECT D1_PEDIDO, D1_ITEMPC, SUM("+cCampoUt+") AS "+cCampoUt+" FROM "+RetSqlName(cTabela)
		cQryReg += " WHERE "
		cQryReg += "     D1_FILIAL = '"+xFilial(cTabela)+"' AND D1_DOC = '"+TMPGRD->D1_DOC+"' AND D1_SERIE = '"+TMPGRD->D1_SERIE+"' 
		cQryReg += " AND D1_FORNECE = '"+TMPGRD->D1_FORNECE+"' 	AND D1_LOJA = '"+TMPGRD->D1_LOJA+"' AND D1_COD = '"+TMPGRD->D1_COD+"' "
		cQryReg += " AND D1_PEDIDO = '"+TMPGRD->D1_PEDIDO+"' AND D1_ITEMPC = '"+TMPGRD->D1_ITEMPC+"' AND D_E_L_E_T_ != '*' "                                                                                                       
		cQryReg += " GROUP BY D1_PEDIDO, D1_ITEMPC "
	ElseIf cTabela == 'SF1'
		cQryReg := " SELECT "+cCampoUt+" FROM "+RetSqlName(cTabela)
		cQryReg += " WHERE "
		cQryReg += "     "+cTabAux+"_FILIAL = '"+xFilial(cTabela)+"' AND "+cTabAux+"_DOC = '"+TMPGRD->D1_DOC+"' AND "+cTabAux+"_SERIE = '"+TMPGRD->D1_SERIE+"'
		cQryReg += " AND "+cTabAux+"_FORNECE = '"+TMPGRD->D1_FORNECE+"' 	AND "+cTabAux+"_LOJA = '"+TMPGRD->D1_LOJA+"'  AND D_E_L_E_T_ != '*' "  		
	ElseIf cTabela == 'QI2'
		cQryReg := " SELECT "+cCampoUt+" FROM "+RetSqlName(cTabela)
		cQryReg += " WHERE "
		cQryReg += "     "+cTabAux+"_FILIAL = '"+xFilial(cTabela)+"' AND "+cTabAux+"_DOCNF = '"+TMPGRD->D1_DOC+"' AND "+cTabAux+"_SERNF = '"+TMPGRD->D1_SERIE+"'
		cQryReg += " AND "+cTabAux+"_CODFOR = '"+TMPGRD->D1_FORNECE+"' 	AND "+cTabAux+"_LOJFOR = '"+TMPGRD->D1_LOJA+"'  AND D_E_L_E_T_ != '*' "  		

	EndIf			

	If (Select("CALCREG") <> 0)
  		DbSelectArea("CALCREG")
   		CALCREG->(DbCloseArea())                
    Endif
		                                                                       	
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQryReg), "CALCREG",.T., .F.)
	
	DbSelectArea("CALCREG")
	CALCREG->(DbGoTop())	     
    // ==============================================

	If cTabela == 'SD1'
		xComp := IIF(cTipAux!='CTR',CALCREG->&cCAmpoUt/TMPGRD->C7_QUANT,1) //IIF(TMPGRD->C7_QUANT==TMPGRD->C7_QUJE,TMPGRD->C7_QUANT,TMPGRD->C7_QUANT-TMPGRD->C7_QUJE)   // MONTA PERCENTUAL DA REGRA              
	ElseIf cTabela == 'SF1'
		xComp := StoD(CALCREG->&cCAmpoUt)-IIF(cTipAux!='CTR',StoD(TMPGRD->C7_DATPRF),StoD(CALCREG->&cCAmpoUt))   // MONTA PERCENTUAL DA REGRA              
	ElseIf cTabela == 'QI2'
		xComp := IIF(!Empty(Alltrim(CALCREG->&cCAmpoUt)),1,0) 
	EndIf			    

    // ===========================================================
    // NOVA REGRA PARA PEDIDOS PARCIAIS ENTREGUES DENTRO DO PRAZO
    //============================================================	                                                                                                                    
	If cTabela == 'SD1' .AND. xComp < 1

		cQryReg := " SELECT F1_RECBMTO   FROM "+RetSqlName('SF1')
		cQryReg += " WHERE "
		cQryReg += "     F1_FILIAL = '"+xFilial('SF1')+"' AND F1_DOC = '"+TMPGRD->D1_DOC+"' AND F1_SERIE = '"+TMPGRD->D1_SERIE+"'
		cQryReg += " AND F1_FORNECE = '"+TMPGRD->D1_FORNECE+"' 	AND F1_LOJA = '"+TMPGRD->D1_LOJA+"'  AND D_E_L_E_T_ != '*' "  		
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQryReg), "CALCALT",.T., .F.)

		DbSelectArea("CALCALT")
		CALCALT->(DbGoTop())	     
		If StoD(TMPGRD->C7_DATPRF)-StoD(CALCALT->F1_RECBMTO) > 0 
			xComp := 1	
		EndIF	        
		CALCALT->(DbCloseArea())	     		
	EndIf	    
    // ==============================================
    // BUSCA INFORMAÇÕES DA REGRA PARA CALCULO
    //===============================================	                                                                                                                    
	cQryPt := " SELECT * FROM "+RetSqlName('Z05')
	cQryPt += " WHERE "
	cQryPt += "      Z05_FILIAL = '"+xFilial('Z05')+"' AND Z05_REGRA = '"+cRegra+"' AND Z05_CRITER = '"+cCritic+"' AND D_E_L_E_T_ != '*' "
	
	If (Select("CALCPT") <> 0)
  		DbSelectArea("CALCPT")
   		CALCPT->(DbCloseArea())
    Endif
		                                                                       	
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQryPt), "CALCPT",.T., .F.)
	
	DbSelectArea("CALCPT")
	CALCPT->(DbGoTop())	   
	
	While !CALCPT->(EOF())    
	    // ==============================================
	    // ANALISA REGRA DE COMPARAÇÃO
   	 	//===============================================
        
        If Empty(Alltrim(CALCPT->Z05_REGRA2)) 		// SE TIVER COMPARAÇÃO COM 1 REGRA
        
			If CALCPT->Z05_REGRA1 == '1'
				cRegra1 := " CALCPT->Z05_VALOR1/100 > xComp "
			ElseIf CALCPT->Z05_REGRA1 == '2'
				cRegra1 := " CALCPT->Z05_VALOR1/100 >= xComp "
			ElseIf CALCPT->Z05_REGRA1 == '3'
				cRegra1 := " CALCPT->Z05_VALOR1/100 = xComp "
			ElseIf CALCPT->Z05_REGRA1 == '4'
				cRegra1 := " CALCPT->Z05_VALOR1/100 <= xComp "
			ElseIf CALCPT->Z05_REGRA1 == '5'
				cRegra1 := " CALCPT->Z05_VALOR1/100 < xComp "
			EndIF		
	
	        // ==============================================
		    // VERIFICA SE ESTÁ DENTRO DA REGRA CORRENTE
   			//===============================================
	        If &cRegra1  //CALCPT->Z05_VALOR1/100 &cRegra1 xComp    
	       		nPt := CALCPT->Z05_NOTA  
	            Exit
	        EndIf
	   	
		Else
			If CALCPT->Z05_REGRA1 == '1'
				cRegra1 := " CALCPT->Z05_VALOR1/100 > xComp "
			ElseIf CALCPT->Z05_REGRA1 == '2'
				cRegra1 := " CALCPT->Z05_VALOR1/100 >= xComp "
			ElseIf CALCPT->Z05_REGRA1 == '3'
				cRegra1 := " CALCPT->Z05_VALOR1/100 = xComp "
			ElseIf CALCPT->Z05_REGRA1 == '4'
				cRegra1 := " CALCPT->Z05_VALOR1/100 <= xComp "
			ElseIf CALCPT->Z05_REGRA1 == '5'
				cRegra1 := " CALCPT->Z05_VALOR1/100 < xComp "
			EndIF		

                   // regra invertida para compreender a necessidade
			If CALCPT->Z05_REGRA2 == '1'
				cRegra1 += ' .AND. xComp < CALCPT->Z05_VALOR2/100 '
			ElseIf CALCPT->Z05_REGRA2 == '2'
				cRegra1 += ' .AND. xComp <= CALCPT->Z05_VALOR2/100 '
			ElseIf CALCPT->Z05_REGRA2 == '3'
				cRegra1 += ' .AND. xComp = CALCPT->Z05_VALOR2/100 '
			ElseIf CALCPT->Z05_REGRA2 == '4'
				cRegra1 += ' .AND. xComp >= CALCPT->Z05_VALOR2/100 '
			ElseIf CALCPT->Z05_REGRA2 == '5'                             
				cRegra1 += ' .AND. xComp > CALCPT->Z05_VALOR2/100 '
			EndIF
		                        
	        // ==============================================
		    // VERIFICA SE ESTÁ DENTRO DA REGRA CORRENTE
   			//===============================================
	        If &cRegra1  //CALCPT->Z05_VALOR1/100 &cRegra1 xComp    
	       		nPt := CALCPT->Z05_NOTA
	       		Exit
	        EndIf	    
	    EndIf
	      
		CALCPT->(DbSkip())
	EndDo  

	CALCPT->(DbCloseArea())
	CALCREG->(DbCloseArea())
 
Else
	Alert('Problemas ao encontrar forma de cálculo para a Regra '+cRegra+'/'+cCritic)
EndIf  

Z05->(DbCLoseArea())

Return nPt

	