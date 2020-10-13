#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} AWS012
//TODO Rotina para validar e processar o WS GetAutorizacao
@author Mario L. B. Faria
@since 24/05/2018
@version 1.0
/*/
User Function AWS012(cData)
	Local cQuery 	:= ""
	Local cAlZ01	:= ""
	Local cMetEnv   := "Get"
	Local cLotAux	:= "" 
	Local aRet		:= {}
	Local nC		:= 0
	Local lOk		:= .T.
	Local cXmlRec	:= ""
	Local cMensa    := ""
	Local oEventLog := EventLog():start("Autorizacao de Vendas - Teknisa", StoD(cData), "Iniciando processo de verificacao das autorizacoes das vendas...", cMetEnv, "Z01")	
	Local cError    := ""
	Local cWarning  := ""	
	Local aRet      := {}
	Local oXMLAut
	Local cXMLAut   := ""          
	Local lConting  := .F. 
	Local lCanc     := .F.
	
	//Seleciona Sequencias de venda
	cMensa:="-> Selecionando vendas..."
	ConOut(cMensa)                              
	oEventLog:SetAddInfo(cMensa,"")
	cQuery := "	SELECT " + CRLF
	cQuery += "		Z01_FILIAL, Z01_CDEMP, Z01_CDFIL, Z01_CAIXA, Z01_ENTREG, Z01_SEQVDA, Z01_CONTNG, Z01_CUPOMC, R_E_C_N_O_ REC " + CRLF
	cQuery += "	FROM " + RetSqlName("Z01") + " " + CRLF
	cQuery += "	WHERE " + CRLF
	cQuery += "			Z01_FILIAL = '" + xFilial("Z01") + "' " + CRLF
	cQuery += "		AND Z01_ENTREG = '" + cData          + "' " + CRLF
	cQuery += "		AND D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	ORDER BY " + CRLF 
	cQuery += "		Z01_FILIAL, Z01_CDEMP, Z01_CDFIL, Z01_CAIXA, Z01_ENTREG, Z01_SEQVDA " + CRLF
	cQuery := ChangeQuery(cQuery)
	cAlZ01 := MPSysOpenQuery(cQuery)


	// Atualiza registros a integrar
	nAux:=0
	(cAlZ01)->(DbGoTop())
	While !(cAlZ01)->(Eof())
		oEventLog:setCountOk()   	
		nAux:=nAux+1
		(cAlZ01)->(DbSkip())	
	EndDo
	cMensa:="Ok: " + AllTrim(Str(nAux)) + " registros selecionados..."
	ConOut(cMensa)                              
	oEventLog:SetAddInfo(cMensa,"")              

	//Montagem de lotes par enviar
	(cAlZ01)->(dBGoTop())
	While !(cAlZ01)->( Eof() ) 
			
		cError   := ""
		cWarning := ""	
		oXMLAut  := Nil
		aRet     := {}
		cXMLAut  := ""
		lOk      := .T.
		lConting  := .F. 
		lCanc     := .F.

		// -> Busca XML da autorização da venda
		cMensa:=(cAlZ01)->Z01_SEQVDA+":"+(cAlZ01)->Z01_CAIXA+": Buscando XML de autorizacao da venda..."
		ConOut(cMensa)                              
		oEventLog:SetAddInfo(cMensa,"")
		aRet := U_TkGetAut({(cAlZ01)->Z01_FILIAL,(cAlZ01)->Z01_CDEMP,(cAlZ01)->Z01_CDFIL,(cAlZ01)->Z01_CAIXA,(cAlZ01)->Z01_SEQVDA,(cAlZ01)->Z01_SEQVDA,(cAlZ01)->Z01_ENTREG},oEventLog)
		lOk		:= aRet[01][01]
		cXMLAut := aRet[01][02]  
	
		If lOk .and. AllTrim(cXMLAut) <> ""		

			// -> 'Abrindo' XML
			oXMLAut := XmlParser( cXMLAut, "_", @cError, @cWarning ) 
			If AllTrim(@cError) <> ""
				oEventLog:broken("Leitura do XML de autorizacao.", @cError, .T.)	
			    lOk := .F.
			    conout(cXMLAut)
	    	EndIf                    

			If lOk
			
				// -> Verifica se a venda foi enciada em contingência	
				If oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_CONTINGENCIA:TEXT == "S"
					lConting := .T.
				EndIf	

				// -> Verifica se houve cancelamento	
				If oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_CUMPOCANCELADO:TEXT <> "N"
					lCanc := .T.
				EndIf	


				// -> Se a venda 
				If lConting .Or. lCanc
				
		            // -> Posiciona no documento fiscal
					cMensa:=": Atualizando venda..."
					ConOut(cMensa)                              
					oEventLog:SetAddInfo(cMensa,"")	
		            DbSelectArea("Z01") 
					Z01->(dbGoTo((cAlZ01)->REC))
					If !Z01->(Eof())
 		
			 			Begin Transaction 
						If RecLock("Z01",.F.)

				            // -> Atualiza dados para documentos emitidos em contingencia
							If lConting
								Z01->Z01_NFCE	:= oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_NRNOTAFISCALCE:TEXT
								Z01->Z01_ANFCE	:= oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_NRLANCTONFCE:TEXT			
								Z01->Z01_CHVNFC := oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_NRACESSONFCE:TEXT				
								Z01->Z01_DTENV	:= StoD(oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_DTENVIONFCE:TEXT)				
								Z01->Z01_NPROT	:= oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_NRPROTOCOLONFCE:TEXT				
								Z01->Z01_DTRPRO	:= StoD(oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_DTHRPROTOCONFCE:TEXT)	
								Z01->Z01_HRRPRO	:= oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_HRRPROTOCONFCE:TEXT					
								Z01->Z01_SNFCE	:= oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_IDSTATUSNFCE:TEXT			
								Z01->Z01_OBSNFC := oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_DSOBSSTATUSNFCE:TEXT				
								Z01->Z01_ARQXML	:= oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_VENDAXML:_DSARQXMLNFCE:TEXT	
								Z01->Z01_QRCODE	:= oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_DSQRCODENFCE:TEXT									
							Endif
							
				            // -> Atualiza dados para documentos cancelados
							If lCanc
								Z01->Z01_CUPOMC	:= oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_CUMPOCANCELADO:TEXT	
								Z01->Z01_PROCAN	:= oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_NRPROTOCOLOCANC:TEXT
								Z01->Z01_DPROCA	:= StoD(oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_DTRPROTOCOLOCAN:TEXT)
								Z01->Z01_HPROCA	:= oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_HRRPROTOCOLOCAN:TEXT
								Z01->Z01_OPERA 	:= oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_CDOPERADORCANC:TEXT
								Z01->Z01_MOTCAN	:= oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_DSRAZAOCANCNFCE:TEXT
								Z01->Z01_CHVCAN	:= oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_NRACESSOCANC:TEXT
								Z01->Z01_OBSNFC := oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_DSOBSSTATUSNFCE:TEXT
								Z01->Z01_SNFCE	:= oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_IDSTATUSNFCE:TEXT			
							EndIf
		
							Z01->(MsUnlock()) 
							cMensa:="Ok."
							ConOut(cMensa)                              
							oEventLog:SetAddInfo(cMensa,"")	
							oEventLog:setCountInc()
					    	lOk := .T.
                        
						Else
						
							oEventLog:broken("Erro: "+(cAlZ01)->Z01_SEQVDA+"-"+(cAlZ01)->Z01_CAIXA+": Atualizacao da venda.","",.T.)	
						    lOk := .F.
						    conout(cXMLAut)
						    EndTransaction()

						EndIf						

						End Transaction 							
 
			 		Else
			 		
						oEventLog:broken((cAlZ01)->Z01_SEQVDA+"-"+(cAlZ01)->Z01_CAIXA+": Venda nao integrada.","",.T.)	
					    lOk := .F.
					    Conout(cXMLAut)
			 		
			 		EndIf
			 		
				Else
				
					cMensa:="Ok."
					ConOut(cMensa)                              
					oEventLog:SetAddInfo(cMensa,"")	
					oEventLog:setCountInc()					
				
				EndIf			 		
			 		
			EndIf			 		

        Else
        
    		oEventLog:broken("Retorno do XML de autorizacao"+IIF(cXMLAut==Nil .or. AllTrim(cXMLAut)==""," :Nao retornou XML.",""),"", .T.)
    		conout(cXMLAut)	
			lOk := .F.
        
        EndIf

		(cAlZ01)->( dbSkip() )

	EndDo

	(cAlZ01)->( dbCloseArea() )
	
Return()