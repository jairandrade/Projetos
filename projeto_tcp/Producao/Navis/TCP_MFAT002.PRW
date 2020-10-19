#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MFAT002
Job para envio de NFS-e clientes do exterior

@return
@author Felipe Toazza Caldeira
@since 20/10/2016

/*/
//-------------------------------------------------------------------------------
User Function MFAT002(cEmp,cFil) 

	DEFAULT cEmp := ""
	DEFAULT cFil := ""

	If Empty(cEmp) .AND. Empty(cFil)
	
		cEmp := '02'
		cFil := '01' 
		
		RPCSETTYPE(3)
		PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil
		
			MFAT002Exc()                                                                                                  
			
		RESET ENVIRONMENT
		
	Else

		MFAT002Exc()
	
	Endif
	 
Return                      

Static Function MFAT002Exc()

	Local cQuery := ""
	Local cAux	 := "" 
	
	cQuery := " SELECT R_E_C_N_O_, 
	cQuery += "        NFSE_ID, "
	cQuery += "        CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),XML_ERP)) XMLERP "
	cQuery += " FROM   [TOTVS_TSS_NFSE].[dbo].[SPED051] "
	cQuery += " WHERE  STATUS = 5 AND "
	cQuery += "        D_E_L_E_T_ != '*' "
	
	TCQUERY cQuery NEW ALIAS "TMP"

	If TMP->(!EoF()) 
	
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		
		DbSelectArea('SD2')
		SD2->(DbSetOrder(3))
		
		While !TMP->(EoF())
	
			cAux := TMP->XMLERP
			
			If At("<tipo>E</tipo>",cAux) > 0
			
				nAuxNf := At("<nfse id=",cAux)
				cNf    := SubSTr(cAux,nAuxNF+10,8)

				If SD2->(DbSeek('01'+cNf+" J  "))
				
					cPessoa := Posicione('SA1',1,xFilial('SA1')+SD2->D2_CLIENTE+SD2->D2_LOJA,"A1_PFISICA")
					cAux    := STRTRAN(cAux,"<tipo>E</tipo>","<tipo>E</tipo><identificador>"+Alltrim(cPessoa)+"</identificador><estado>EX</estado>")
					cCodIss := Alltrim(Posicione('SB1',1,xFilial('SB1')+SD2->D2_COD,"B1_CODISS"))
					cAux    := STRTRAN(cAux,"<codigo_item_lista_servico>9999</codigo_item_lista_servico>","<codigo_item_lista_servico>"+Alltrim(cCodIss)+"</codigo_item_lista_servico>")
				
					TcSqlExec("UPDATE [TOTVS_TSS_NFSE].[dbo].[SPED051] SET  XML_ERP = '"+Alltrim(cAux)+"', STATUS = 1 WHERE R_E_C_N_O_ = "+Str(TMP->R_E_C_N_O_)+" ")
				EndIf     
				
			Else  // caso nota seja rejeitada e nao seja de cliente estrangeiro, ajusta a SPED051 e transmite novamente.
				TcSqlExec("UPDATE [TOTVS_TSS_NFSE].[dbo].[SPED051] SET STATUS = 1 WHERE R_E_C_N_O_ = "+Str(TMP->R_E_C_N_O_)+" ")				
			EndIf
			
			TMP->(DbSkip())
		End
		
	EndIf
	
	TMP->(DbCloseArea())
	
Return