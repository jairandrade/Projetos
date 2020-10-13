#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} AWS013
//TODO Rotina para processar o retorno do metodo getFechamentoCaixaMatriz
@author Marcos Aurélio Feijó
@since 27/06/2018
@version 1.0
@param oXmlRet, object, Objeto com os pedidos 
/*/
User Function AWS013(cXmlRet,oEventLog)
Local cError	:= ""
Local lOk       := .T.
Local cWarning	:= ""	
Local oXml		 
Local nSeqMov	:= 0	
Local nSeqCx    := 0
Private aErros	:= {}
	
	// -> Valida XML Retornado
	If ValType(cXmlRet) == "C"
		oXml:= XmlParser( cXmlRet, "_", @cError, @cWarning ) 
	Else
		oEventLog:broken("Leitura do XML dos fechamentos de caixa.", @cError, .T.)
		ConOut("Erro: Leitura do XML dos fechamentos de caixa.")	
		ConOut(cXmlRet)
		Return(.F.)
	EndIf

	dbSelectArea("Z05")
	Z05->( dbSetOrder(1) )
	                         
	ConOut(": Validando XML...")
    oEventLog:SetAddInfo(": Validando XML...","")        
	If AllTrim(@cError) <> ""
		oEventLog:broken("Leitura do XML dos fechamentos de caixa.", @cError, .T.)
		ConOut("Erro: Leitura do XML dos fechamentos de caixa.")	
		Return(.F.)
    Else
    	ConOut("Ok.")
        oEventLog:SetAddInfo("Ok.","")            
    EndIf                 
    
                
    cError := ""    
	If ValType(oXml:_RETORNOS:_RETORNO) == "A"
		
		cError := ""
		For nSeqCx := 1 to Len(oXml:_RETORNOS:_RETORNO)
				
			If !isBlind()
				ProcRegua(Len(oXml:_RETORNOS:_RETORNO[nSeqCx]:_MOVIMENTOS:_MOVIMENTO))  
			EndIf   

			cError:=AllTrim(oXml:_RETORNOS:_RETORNO[nSeqCx]:_ID:_DTENTRVENDA:TEXT)+"-"+AllTrim(oXml:_RETORNOS:_RETORNO[nSeqCx]:_ID:_CDCAIXA:TEXT)+": Gravando Fechamento de Caixa..."
			ConOut(cError)                              
			oEventLog:SetAddInfo(cError,"")
			
			If ValType(oXml:_RETORNOS:_RETORNO[nSeqCx]:_MOVIMENTOS) == "O"
			
				If ValType(oXml:_RETORNOS:_RETORNO[nSeqCx]:_MOVIMENTOS:_MOVIMENTO) == "A" 
					
					For nSeqMov := 1 to Len(oXml:_RETORNOS:_RETORNO[nSeqCx]:_MOVIMENTOS:_MOVIMENTO)	

						If !isBlind()
							IncProc("Gravando Fechamento do Caixa: " + AllTrim(Str(nSeqMov)))
						EndIf
						lOk:=GRVFEC(oXml:_RETORNOS:_RETORNO[nSeqCx]:_ID, oXml:_RETORNOS:_RETORNO[nSeqCx]:_MOVIMENTOS:_MOVIMENTO[nSeqMov], oEventLog)

					Next nSeqMov
								
				Else
				
					If !isBlind()
						ProcRegua()
					EndIf
					
					lOk:=GRVFEC(oXml:_RETORNOS:_RETORNO[nSeqCx]:_ID, oXml:_RETORNOS:_RETORNO[nSeqCx]:_MOVIMENTOS:_MOVIMENTO, oEventLog)
					
				EndIf
			
			EndIf
			
			If lOk
				oEventLog:setCountInc()
			EndIf				
		
		Next nSeqCx	
				
	Else 
		
		If !isBlind()
			ProcRegua(Len(oXml:_RETORNOS:_RETORNO:_MOVIMENTOS:_MOVIMENTO))  
		EndIf   
		
		cError := ""
		cError:=AllTrim(oXml:_RETORNOS:_RETORNO:_ID:_DTENTRVENDA:TEXT)+"-"+AllTrim(oXml:_RETORNOS:_RETORNO:_ID:_CDCAIXA:TEXT)+": Integrando Fechamentos de Caixa..."
		ConOut(cError)                              
		oEventLog:SetAddInfo(cError,"")
			
		If ValType(oXml:_RETORNOS:_RETORNO:_MOVIMENTOS) == "O"
			
			If ValType(oXml:_RETORNOS:_RETORNO:_MOVIMENTOS:_MOVIMENTO) == "A" 
					
				For nSeqMov := 1 to Len(oXml:_RETORNOS:_RETORNO:_MOVIMENTOS:_MOVIMENTO)	

					If !isBlind()
						IncProc("Gravando Fechamento do Caixa: " + AllTrim(Str(nSeqMov)))
					EndIf
					lOk:=GRVFEC(oXml:_RETORNOS:_RETORNO:_ID, oXml:_RETORNOS:_RETORNO:_MOVIMENTOS:_MOVIMENTO[nSeqMov], oEventLog)

				Next nSeqMov
								
			Else
				
				If !isBlind()
					ProcRegua()
				EndIf
					
				lOk:=GRVFEC(oXml:_RETORNOS:_RETORNO:_ID, oXml:_RETORNOS:_RETORNO:_MOVIMENTOS:_MOVIMENTO, oEventLog)
					
			EndIf
			
		EndIf
		
		If lOk
			oEventLog:setCountInc()
		EndIf				

	EndIf
	
	oEventLog:setAddInfo(IIF(lOk,"Ok.",""),"")	                                       
	ConOut(IIF(lOk,"Ok.",""))					
	
Return lOk


/*/{Protheus.doc} GRVFEC
//TODO Valida e chama ghravação individal do Fechamento de Caixa
@author Marcos Aurélio Feijó
@since 27/06/2018
@version 1.0
@return ${return}, ${return_description}
@param oID, Objeto, ID
@param oMovimento, Objeto, Movimentação
@param oEventLog, Objeto, EventLog
@type function
/*/
Static Function GRVFEC(oID, oMovimento, oEventLog)
Local lRet		:= .T.
Local lExiste	:= .F.
Local cXVenda	:= AllTrim(oID:_DTENTRVENDA:TEXT)
Local cXCaixa	:= AllTrim(oID:_CDCAIXA:TEXT)
Local cCond     := oMovimento:_CDTIPOREC:TEXT
Local cEventLog	:= ""
	
	If lRet
		
	    // -> Verifica se o caixa já foi incluído
	    /*Z05->(DbSetOrder(2))
	    If !Z05->(DbSeek(xFilial("Z05")+cXCaixa+cXVenda+cCond))
	
			Begin Transaction
		
				//Atualiza Consumidor - Z05
				lRet := GRVZ05(oID,oMovimento)
				If !lRet
					cEventLog := "Na atualizacao do fechamento de caixa."
					oEventLog:setAddInfo("Erro: "+AllTrim(cEventLog),"")	                                       
					ConOut("Erro:"+AllTrim(cEventLog))					
					DisarmTransaction()
				EndIf
			
			End Transaction
							
		EndIf*/

		Z05->(DbSetOrder(2))
	    If Z05->(DbSeek(xFilial("Z05")+cXCaixa+cXVenda+cCond))
			lExiste := .T.
		EndIf
	
		Begin Transaction
		
			//Atualiza Consumidor - Z05
			lRet := GRVZ05(oID,oMovimento,lExiste)
			If !lRet
				cEventLog := "Na atualizacao do fechamento de caixa."
				oEventLog:setAddInfo("Erro: "+AllTrim(cEventLog),"")	                                       
				ConOut("Erro:"+AllTrim(cEventLog))					
				DisarmTransaction()
			EndIf
			
		End Transaction
	
	EndIf			

Return lRet


/*/{Protheus.doc} GRVZ05
//TODO Valida e grava Z05 - Fechamento de Caixa
@author Marcos Aurélio Feijó
@since 27/06/2018
@version 1.0
@return lRet, logico, .T. = Sucesso | .F. = Erro
@param oID, Objeto, ID
@param oMovimento, Objeto, Movimentação
@param lExiste,Logico, movimento ja existe na tabela
@param oEventLog, Objeto, EventLog
@param cXEmp, characters, Empresa Teknisa
@param cXFil, characters, Filial Teknisa
@type function
/*/
//Static Function GRVZ05(oID,oMovimento)
Static Function GRVZ05(oID,oMovimento,lExiste)
Local lRet 		:= .T.
Local cAliasZ01 := GetNextAlias()
Local cQuery 	:= ''

	/*RecLock("Z05",.T.)
	Z05->Z05_FILIAL	:= xFilial("Z05")
	Z05->Z05_CDEMP 	:= AllTrim(oID:_CDEMPRESA:TEXT)	
	Z05->Z05_CDFIL	:= AllTrim(oID:_CDFILIAL:TEXT)
	Z05->Z05_CAIXA	:= oID:_CDCAIXA:TEXT
	Z05->Z05_DATA	:= StoD(oID:_DTENTRVENDA:TEXT)
	Z05->Z05_DTABER	:= StoD(oID:_DATAABERTURA:TEXT)
	Z05->Z05_DATAF	:= StoD(oID:_DATAFECHAMENTO:TEXT)
	Z05->Z05_COND	:= oMovimento:_CDTIPOREC:TEXT
	Z05->Z05_TIPO	:= oMovimento:_TIPOMOVIMENTO:TEXT
	Z05->Z05_VALOR1	:= U_xCharToVal(oMovimento:_SANGRIA:TEXT,"Z05_VALOR")
	Z05->Z05_VALOR2	:= U_xCharToVal(oMovimento:_SISTEMA:TEXT,"Z05_VALOR")
	Z05->Z05_VALOR	:= U_xCharToVal(oMovimento:_VRMOVIMENTO:TEXT,"Z05_VALOR")
	Z05->Z05_HIST	:= oMovimento:_HISTORICO:TEXT
	Z05->Z05_NVENDA	:= U_xCharToVal(oID:_QTDEVENDAS:TEXT,"Z05_NVENDA")
	Z05->Z05_XSTINT := "I"
	Z05->Z05_XDINT  := Date()
	Z05->Z05_XHINT	:= Time()
	Z05->(MsUnlock())*/
	
	If !lExiste
		RecLock("Z05",.T.)
		Z05->Z05_FILIAL	:= xFilial("Z05")
		Z05->Z05_CDEMP 	:= AllTrim(oID:_CDEMPRESA:TEXT)	
		Z05->Z05_CDFIL	:= AllTrim(oID:_CDFILIAL:TEXT)
		Z05->Z05_CAIXA	:= oID:_CDCAIXA:TEXT
		Z05->Z05_DATA	:= StoD(oID:_DTENTRVENDA:TEXT)
		Z05->Z05_DTABER	:= StoD(oID:_DATAABERTURA:TEXT)
		Z05->Z05_DATAF	:= StoD(oID:_DATAFECHAMENTO:TEXT)
		Z05->Z05_COND	:= oMovimento:_CDTIPOREC:TEXT
		Z05->Z05_TIPO	:= oMovimento:_TIPOMOVIMENTO:TEXT
		Z05->Z05_VALOR1	:= U_xCharToVal(oMovimento:_SANGRIA:TEXT,"Z05_VALOR")
		Z05->Z05_VALOR2	:= U_xCharToVal(oMovimento:_SISTEMA:TEXT,"Z05_VALOR")
		Z05->Z05_VALOR	:= U_xCharToVal(oMovimento:_VRMOVIMENTO:TEXT,"Z05_VALOR")
		Z05->Z05_HIST	:= oMovimento:_HISTORICO:TEXT
		Z05->Z05_NVENDA	:= U_xCharToVal(oID:_QTDEVENDAS:TEXT,"Z05_NVENDA")
		Z05->Z05_XSTINT := "P" // PENDENTE
		Z05->Z05_XDINT  := Date()
		Z05->Z05_XHINT	:= Time()
		Z05->(MsUnlock())
	Else
		cQuery :="SELECT COUNT(Z01_SEQVDA) TOTAL "  
		cQuery += "FROM " + RetSqlName("Z01")    + "          "    
		cQuery += "WHERE D_E_L_E_T_ <> '*'                AND "
		cQuery += "      Z01_FILIAL   = '" + xFilial("Z01") + "'     AND "
		cQuery += "      Z01_ENTREG  = '" + oID:_DTENTRVENDA:TEXT + "' "
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ01,.T.,.T.)
		
		If (cAliasZ01)->TOTAL == U_xCharToVal(oID:_QTDEVENDAS:TEXT,"Z05_NVENDA")
			RecLock("Z05",.F.)
			Z05->Z05_FILIAL	:= xFilial("Z05")
			Z05->Z05_CDEMP 	:= AllTrim(oID:_CDEMPRESA:TEXT)	
			Z05->Z05_CDFIL	:= AllTrim(oID:_CDFILIAL:TEXT)
			Z05->Z05_CAIXA	:= oID:_CDCAIXA:TEXT
			Z05->Z05_DATA	:= StoD(oID:_DTENTRVENDA:TEXT)
			Z05->Z05_DTABER	:= StoD(oID:_DATAABERTURA:TEXT)
			Z05->Z05_DATAF	:= StoD(oID:_DATAFECHAMENTO:TEXT)
			Z05->Z05_COND	:= oMovimento:_CDTIPOREC:TEXT
			Z05->Z05_TIPO	:= oMovimento:_TIPOMOVIMENTO:TEXT
			Z05->Z05_VALOR1	:= U_xCharToVal(oMovimento:_SANGRIA:TEXT,"Z05_VALOR")
			Z05->Z05_VALOR2	:= U_xCharToVal(oMovimento:_SISTEMA:TEXT,"Z05_VALOR")
			Z05->Z05_VALOR	:= U_xCharToVal(oMovimento:_VRMOVIMENTO:TEXT,"Z05_VALOR")
			Z05->Z05_HIST	:= oMovimento:_HISTORICO:TEXT
			Z05->Z05_NVENDA	:= U_xCharToVal(oID:_QTDEVENDAS:TEXT,"Z05_NVENDA")
			Z05->Z05_XSTINT := "I" // PENDENTE
			Z05->Z05_XDINT  := Date()
			Z05->Z05_XHINT	:= Time()
			Z05->(MsUnlock())
		Else
			RecLock("Z05",.F.)
			Z05->Z05_FILIAL	:= xFilial("Z05")
			Z05->Z05_CDEMP 	:= AllTrim(oID:_CDEMPRESA:TEXT)	
			Z05->Z05_CDFIL	:= AllTrim(oID:_CDFILIAL:TEXT)
			Z05->Z05_CAIXA	:= oID:_CDCAIXA:TEXT
			Z05->Z05_DATA	:= StoD(oID:_DTENTRVENDA:TEXT)
			Z05->Z05_DTABER	:= StoD(oID:_DATAABERTURA:TEXT)
			Z05->Z05_DATAF	:= StoD(oID:_DATAFECHAMENTO:TEXT)
			Z05->Z05_COND	:= oMovimento:_CDTIPOREC:TEXT
			Z05->Z05_TIPO	:= oMovimento:_TIPOMOVIMENTO:TEXT
			Z05->Z05_VALOR1	:= U_xCharToVal(oMovimento:_SANGRIA:TEXT,"Z05_VALOR")
			Z05->Z05_VALOR2	:= U_xCharToVal(oMovimento:_SISTEMA:TEXT,"Z05_VALOR")
			Z05->Z05_VALOR	:= U_xCharToVal(oMovimento:_VRMOVIMENTO:TEXT,"Z05_VALOR")
			Z05->Z05_HIST	:= oMovimento:_HISTORICO:TEXT
			Z05->Z05_NVENDA	:= U_xCharToVal(oID:_QTDEVENDAS:TEXT,"Z05_NVENDA")
			Z05->Z05_XSTINT := "P" // PENDENTE
			Z05->Z05_XDINT  := Date()
			Z05->Z05_XHINT	:= Time()
			Z05->(MsUnlock())
		EndIf

		(cAliasZ01)->(DbCloseArea())
	EndIf
			
Return lRet