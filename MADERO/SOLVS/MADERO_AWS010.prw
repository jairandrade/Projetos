#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} AWS010
//TODO Rotina para processar o retorno do metodo getPedidos
@author Mario L. B. Faria
@since 15/05/2018
@version 1.0
@param oXmlRet, object, Objeto com os pedidos 
/*/
User Function AWS010(cXmlRet,oEventLog)
Local cError	:= ""
Local lErro     := .F.
Local cWarning	:= ""	
Local oXml		  
Local nSeqVda	:= 0	
Local aCanc     := {}
Private aErros	:= {}
Private lxFound := .F.
	
	// -> Verifica se o XML foi retornado ok
	If	ValType(cXmlRet) == "C" 
		oXml:= XmlParser(cXmlRet, "_", @cError, @cWarning )  
	Else
		oEventLog:broken("XML do pedido nao retornado.", @cError, .T.)	
		ConOut("XML do pedido nao retornado.")
		ConOut(cXmlRet)
		lErro := .T.
		Return(.F.)	
	EndIf

	dbSelectArea("Z01")
	Z01->( dbSetOrder(1) )
	dbSelectArea("Z02")
	dbSelectArea("Z03")
	dbSelectArea("Z04")
	dbSelectArea("Z12")
	                         
	If AllTrim(@cError) <> ""
		oEventLog:broken("Erro: Leitura do XML de pedidos.", @cError, .T.)	
		ConOut(cError)
		ConOut(cXmlRet)
		lErro := .T.
		Return(.F.)
    EndIf                    
                
    cError := ""    
	If ValType(oXml:_RETORNOS:_RETORNO) == "A"
		If !isBlind()
			ProcRegua(Len(oXml:_RETORNOS:_RETORNO) * 3)
		EndIf   
		cError := ""
		For nSeqVda := 1 to Len(oXml:_RETORNOS:_RETORNO)
			lxFound:=.F.	
			cError :=AllTrim(oXml:_RETORNOS:_RETORNO[nSeqVda]:_ID:_NRSEQVENDA:TEXT)+"-"+AllTrim(oXml:_RETORNOS:_RETORNO[nSeqVda]:_ID:_CDCAIXA:TEXT)+": Integrando venda..."
			ConOut(cError)                              
			oEventLog:SetAddInfo(cError,"")
			// -> Verifica se a venda foi cancelada
			aCanc:=U_AUTZ01(cFilAnt,oXml:_RETORNOS:_RETORNO[nSeqVda]:_ID:_CDEMPRESA:TEXT,oXml:_RETORNOS:_RETORNO[nSeqVda]:_ID:_CDFILIAL:TEXT,oXml:_RETORNOS:_RETORNO[nSeqVda]:_ID:_CDCAIXA:TEXT,oXml:_RETORNOS:_RETORNO[nSeqVda]:_ID:_NRSEQVENDA:TEXT,oXml:_RETORNOS:_RETORNO[nSeqVda]:_ID:_DTENTRVENDA:TEXT,oEventLog)
            If !aCanc[1] .and. aCanc[1] <> Nil
				cError:="< erro no cancelamento >"
				ConOut(cError)                              
				oEventLog:SetAddInfo(cError,"")
			ElseIf aCanc[1] .and. aCanc[2] .and. !aCanc[3]
				cError:="< cancelado >"
				ConOut(cError)                              
				oEventLog:SetAddInfo(cError,"")
            ElseIf aCanc[1] .and. aCanc[3]
				VldVda(oXml:_RETORNOS:_RETORNO[nSeqVda],oEventLog,aCanc,@lxFound)
            Else 
				cError:="< erro no XML: XML retornou vazio. >"
				ConOut(cError)                              
				oEventLog:SetAddInfo(cError,"")
			EndIf	
		Next nSeqVda
	Else
		If !isBlind()
			ProcRegua(3)
		EndIf
		cError:=AllTrim(oXml:_RETORNOS:_RETORNO:_ID:_NRSEQVENDA:TEXT)+"-"+AllTrim(oXml:_RETORNOS:_RETORNO:_ID:_CDCAIXA:TEXT)+": Integrando venda..."
		ConOut(cError)                              
		oEventLog:SetAddInfo(cError,"")	                    
		// -> Verifica se a venda foi cancelada
		aCanc  :=U_AUTZ01(cFilAnt,oXml:_RETORNOS:_RETORNO:_ID:_CDEMPRESA:TEXT,oXml:_RETORNOS:_RETORNO:_ID:_CDFILIAL:TEXT,oXml:_RETORNOS:_RETORNO:_ID:_CDCAIXA:TEXT,oXml:_RETORNOS:_RETORNO:_ID:_NRSEQVENDA:TEXT,oXml:_RETORNOS:_RETORNO:_ID:_DTENTRVENDA:TEXT,oEventLog)
  		lxFound:=.F.
		If aCanc[1] .and. aCanc[2] .and. !aCanc[3] 
  			cError:="< cancelada >"
			ConOut(cError)                              
			oEventLog:SetAddInfo(cError,"")
    	ElseIf aCanc[1] .and. aCanc[3]
			VldVda(oXml:_RETORNOS:_RETORNO,oEventLog,aCanc,@lxFound)
		EndIf	
	EndIf		
Return


/*/{Protheus.doc} VldVda
//TODO Função para verificar se venda é valida e chamar WS GetVenda
@author Mario L. B. Faria
@since 16/05/2018
@version 1.0
@return ${return}, ${return_description}
@param oSeqVda, object, descricao
@type function
/*/
Static Function VldVda(oSeqVda,oEventLog,aCanc,lxFound)
Local cCdEmp := PadR( oSeqVda:_ID:_CDEMPRESA:TEXT	,TamSx3("Z01_CDEMP")[01] )
Local cCdFil := PadR( oSeqVda:_ID:_CDFILIAL:TEXT	,TamSx3("Z01_CDFIL")[01] )
Local cCaixa := PadR( oSeqVda:_ID:_CDCAIXA:TEXT		,TamSx3("Z01_CAIXA")[01] )
Local cSeqVd := PadR( oSeqVda:_ID:_NRSEQVENDA:TEXT	,TamSx3("Z01_SEQVDA")[01] )
Local cEntreg:= PadR( oSeqVda:_ID:_DTENTRVENDA:TEXT	,TamSx3("Z01_ENTREG")[01] )
Local aRet		:= {,}
Local lOk		:= .T.
Local cXmlVda	:= ""
Local cXmlRec	:= ""
Local cXMLProd  := ""
Local nTamZWVPK := TamSx3("ZWV_PK")[1]

	Z01->( dbSetOrder(1) )
	Z01->( dbSeek( xFilial("Z01") + cCdEmp + cCdFil + cSeqVd + cCaixa + cEntreg) )
	
	//Se não existe o resgistro Z01 chama Metodo GetVenda
	If !Z01->(Found())
	
		//Chama WS GetVendas
		If !isBlind()
			IncProc("WS - Venda: " + cSeqVd)
		EndIf
		aErros	:= {}
		aRet	:= U_TkGetVda(cCdFil,cCaixa,cSeqVd,cEntreg,oEventLog)
		lOk		:= aRet[01]
		cXmlVda := aRet[02]
		
		If lOk 
		
			//Chama WS GetProducaoFull
			If !isBlind() .and. lOk
				IncProc("WS - GetProducaoFull: " + cSeqVd)
			EndIf
			   
			// -> Se validação ok
			If lOk
				aErros	:= {}
				aRet	:= U_TkGetPro({cCdEmp,cCdFil,cSeqVd,cEntreg,cCaixa},oEventLog)
				lOk		:= aRet[01,01]
				cXMLProd:= IIF(ValType(aRet[01,02]) <> "C","",aRet[01,02])

				If !lOk .or. AllTrim(cXMLProd) == ""
					lOk := .F.
					oEventLog:broken("Erro: Retorno do XML de producao.", "", .T.)	
					ConOut("Erro: Retorno do XML de producao.")
					conout(cXMLProd)                                                 						
				EndIf
			EndIf	

			//Chama WS GetRecebimento
			If !isBlind() .and. lOk
				IncProc("WS - Recebimento: " + cSeqVd)
			EndIf
			   
			// -> Se validação ok
			If lOk
				aErros	:= {}
				aRet	:= U_TkGetRec(cCdFil,cCaixa,cSeqVd,cEntreg,oEventLog)
				lOk		:= aRet[01]
				cXmlRec := IIF(ValType(aRet[02]) <> "C","",aRet[02])

				If !lOk .or. AllTrim(cXmlRec) == ""
					lOk := .F.
					oEventLog:broken("Erro: Retorno do XML de condicao de recebimento.", "", .T.)	
					ConOut("Erro: Retorno do XML de condicao de recebimento.")
					conout(cXmlRec)                                                 						
				EndIf
			EndIf	
			
			// -> Se todos os XML da venda ok, prossegue
			If lOk 
				lOk:=U_AWS10GRV(cXmlVda,cXMLProd,cXmlRec,oEventLog,aCanc)
			EndIf
			
		Else                                           
			lOk := .F.
			oEventLog:broken("Erro: Retorno do XML da venda.", "", .T.)	
			ConOut("Erro: Retorno do XML da venda.")
			conout(cXmlVda)                                                 						
	    EndIf
	    
	    If lOk    
    		oEventLog:setCountInc()
    		oEventLog:SetAddInfo("Ok.","")    	
	    EndIf	

	Else

		// -> Verifica se já foi fechado o caixa do dia em que a venda está sendo integrada do Teknisa
		ZWV->(DbSetOrder(1))
		ZWV->(DbSeek(xFilial("ZWV")+PADR(cEntreg,nTamZWVPK)+"W"))
		If (ZWV->(Found()) .and. ZWV->ZWV_STATUS == "I") 
			aRet[01]:=.F.
			aRet[02]:="Já foi concluido o processo de integracao de vendas para o dia " + DtoC(StoD(cEntreg))+"."+Chr(13)+Chr(10)+"Nao podera haver vendas pendentes / canceladas apos o fechamento do caixa, favor verificar com o suporte do Teknisa." 
		EndIf

		// -> Verifica se houve cancelamento e grava os dados adicionais
		//#TB20200826 Thiago Berna - Ajuste para padronizar tamanho de string e para considerar o aCanc[2] que é .T. quando cancelamento
		//If aCanc[1] .and. SubStr(Z01->Z01_OBSNFC,1,3) <> SubStr(aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_DSOBSSTATUSNFCE:TEXT,1,3)
		If aCanc[1] .and. !SubStr(Z01->Z01_OBSNFC,1,3) == SubStr(PADR(aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_DSOBSSTATUSNFCE:TEXT,TAMSX3("Z01_OBSNFC")[1]),1,3) .And. aCanc[2] == .T.
				RecLock("Z01", .F.)
				Z01->Z01_CUPOMC	:= aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_CUMPOCANCELADO:TEXT
				Z01->Z01_PROCAN	:= aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_NRPROTOCOLOCANC:TEXT
				Z01->Z01_DPROCA	:= StoD(aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_DTRPROTOCOLOCAN:TEXT)
				Z01->Z01_HPROCA	:= aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_HRRPROTOCOLOCAN:TEXT
				Z01->Z01_OPERA 	:= aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_CDOPERADORCANC:TEXT
				Z01->Z01_MOTCAN	:= aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_DSRAZAOCANCNFCE:TEXT
				Z01->Z01_CHVCAN	:= aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_NRACESSOCANC:TEXT
				Z01->Z01_OBSNFC := aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_DSOBSSTATUSNFCE:TEXT
				Z01->Z01_SNFCE  := aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_IDSTATUSNFCE:TEXT
				Z01->Z01_XSTINT := "P"
				Z01->Z01_XDINT  := Date()
				Z01->Z01_XHRINT	:= Time()
				Z01->(MsUnlock())
				lxFound:=.T.
				ConOut("Ok: "+Z01->Z01_SEQVDA+"-"+Z01->Z01_CAIXA+": Cancelamento registrado.")		
				oEventLog:SetAddInfo("Ok: "+Z01->Z01_SEQVDA+"-"+Z01->Z01_CAIXA+": Cancelamento registrado..","")	                    
				oEventLog:setCountInc()
			
		ElseIf aCanc[1] .And. Z01->Z01_CONTNG == 'S' .And. aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_CONTINGENCIA:TEXT == "N"
				//#TB20200831 Thiago Berna - Ajuste para tratar Contingencia que estava entrando junto do tratamento de cancelamento
				RecLock("Z01", .F.)
				Z01->Z01_NFCE	:= aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_NRNOTAFISCALCE:TEXT				
				Z01->Z01_ANFCE	:= aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_NRLANCTONFCE:TEXT			
				Z01->Z01_CHVNFC := aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_NRACESSONFCE:TEXT				
				Z01->Z01_DTENV	:= StoD(aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_DTENVIONFCE:TEXT)				
				Z01->Z01_NPROT	:= aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_NRPROTOCOLONFCE:TEXT				
				Z01->Z01_DTRPRO	:= StoD(aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_DTHRPROTOCONFCE:TEXT)	
				Z01->Z01_HRRPRO	:= aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_HRRPROTOCONFCE:TEXT					
				Z01->Z01_SNFCE	:= aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_IDSTATUSNFCE:TEXT			
				Z01->Z01_OBSNFC := aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_DSOBSSTATUSNFCE:TEXT				
				Z01->Z01_CONTNG := aCanc[4]:_RETORNOS:_RETORNO:_VENDA:_VENDA:_CONTINGENCIA:TEXT	
				Z01->(MsUnlock())
				lxFound:=.T.
				ConOut("Ok: "+Z01->Z01_SEQVDA+"-"+Z01->Z01_CAIXA+": NF que estava em contingencia registrada.")		
				oEventLog:SetAddInfo("Ok: "+Z01->Z01_SEQVDA+"-"+Z01->Z01_CAIXA+": NF que estava em contingencia registrada..","")	                    
				oEventLog:setCountInc()
		Else
			ConOut("Ok: "+Z01->Z01_SEQVDA+"-"+Z01->Z01_CAIXA+": Venda ja integrada.")		
			oEventLog:SetAddInfo("Ok: "+Z01->Z01_SEQVDA+"-"+Z01->Z01_CAIXA+": Venda ja integrada.","")	                    
			oEventLog:setCountInc()
		EndIf
	EndIf	
		

Return (lOk)


/*/{Protheus.doc} AWS10GRV
//TODO Função para gerar Objeto do XML de retorno
@author Mario L. B. Faria
@since 16/05/2018
@version 1.0
@return ${return}, ${return_description}
@param cXmlVenda, characters, XML da Venda
@type function
/*/
User Function AWS10GRV(cXmlVenda,cXMLProd,cXmlReceb,oEventLog,aCanc)

Local cError	:= ""
Local cWarning	:= ""	
Local oVenda	
Local oReceb	
Local oProducao
	
	// -> Se os XML estão com erro, retorna
	If Empty(cXmlVenda) .or. Empty(cXMLProd) .or. Empty(cXmlReceb)
	   Return(.F.)
	EndIf   	   
	
	// -> 'Abre' XML da venda
	If	ValType(cXmlVenda) == "C" 
		oVenda	:= XmlParser( cXmlVenda, "_", @cError, @cWarning )  
	Else
		oEventLog:broken("XML da venda nao retornado.", @cError, .T.)	
		ConOut("XML da venda nao retornado.")
		ConOut(cXmlVenda)
		Return(.F.)	
	EndIf
	
	If AllTrim(@cError) <> ""
		oEventLog:broken("Erro: Leitura do XML da venda.", @cError, .T.)	
		Return(.F.)
    EndIf                    
                        

	// -> 'Abre' XML da producao
	cError	 := ""
	cWarning := ""		                                                                  	
	// -> 'Abre' XML do recebimento
	If	ValType(cXMLProd) == "C" .and. AllTrim(cXMLProd) <> "" 
		oProducao:=XmlParser( cXMLProd, "_", @cError, @cWarning )  
		If AllTrim(@cError) <> ""
			oEventLog:broken("Erro: Leitura do XML da producao.", @cError, .T.)	
			Return(.F.)
    	EndIf                    
	Else
		oEventLog:broken("XML de producao nao retornado.", @cError, .T.)	
		ConOut("XML de producao nao retornado.")
		ConOut(cXmlReceb)
		Return(.F.)	
	EndIf

	// -> 'Abre' XML da condicao de recebimento
	cError	 := ""
	cWarning := ""		                                                                  	
	// -> 'Abre' XML do recebimento
	If	ValType(cXmlReceb) == "C" .and. AllTrim(cXmlReceb) <> ""
		oReceb	 := XmlParser( cXmlReceb, "_", @cError, @cWarning )  
		If AllTrim(@cError) <> ""
			oEventLog:broken("Erro: Leitura do XML do recebimento.", @cError, .T.)	
			Return(.F.)
    	EndIf                    
	Else
		oEventLog:broken("XML do recebimento nao retornado.", @cError, .T.)	
		ConOut("XML do recebimento nao retornado.")
		ConOut(cXmlReceb)
		Return(.F.)	
	EndIf
    
	lRet := GRVVDA(oVenda,oProducao,oReceb,cXmlVenda,cXmlReceb,oEventLog,aCanc)
	
Return lRet

	
/*/{Protheus.doc} GRVVDA
//TODO Valida e chama ghravação individal da venda
@author Mario L. B. Faria
@since 16/05/2018
@version 1.0
@return ${return}, ${return_description}
@param oVenda, object, Objeto da Venda
@type function
/*/
Static Function GRVVDA(oVenda,oProducao,oRec,cXmlVenda,cXmlReceb,oEventLog,aCanc)
Local lRet		:= .T.
Local cXEmp		:= ""
Local cXFil		:= ""
Local oConsu	:= oVenda:_RETORNOS:_RETORNO:_CONSUMIDOR
Local oCabec	:= oVenda:_RETORNOS:_RETORNO:_CABECALHO
Local oItens	:= oVenda:_RETORNOS:_RETORNO:_ITENS:_PRODUTO
Local oProd		:= oProducao:_RETORNOS:_RETORNO:_ITENS:_PRODUTO
Local oProdObs	:= oProducao:_RETORNOS:_RETORNO:_OBSERVACOES:_OBSERVACAO
Local oReceb	:= oRec:_RETORNOS:_RETORNO
Private cXVenda	:= oCabec:_ID:_NRSEQVENDA:TEXT
Private cXCaixa	:= oCabec:_ID:_CDCAIXA:TEXT
Private cXDataVd:= oCabec:_VENDA:_DTVENDA:TEXT
Private cXDataEn:= oCabec:_VENDA:_DTENTRVENDA:TEXT
Private cEventLog:= ""

	//Posiciona na Unidade de Negócio
	dbSelectArea("ADK")
	ADK->( dbOrderNickName("ADKXFILI") )
	ADK->(dbGoTop())
	If ADK->(dbseek(xFilial("ADK")+cFilAnt))
		cXEmp := ADK->ADK_XEMP  
		cXFil := ADK->ADK_XFIL 
	Else
        ConOut("Filial nao encontrada no ERP: "+cFilAnt)
	    oEventLog:broken("Erro no processo.", "Filial nao encontrada no ERP: "+cFilAnt, .F.)	    
	    lRet:=.F.
	EndIf
	
	If lRet

		ConOut(AllTrim(oCabec:_ID:_NRSEQVENDA:TEXT)+"-"+AllTrim(oCabec:_ID:_CDCAIXA:TEXT)+": Gravando venda...")
		// cEventLog := cEventLog + oCabec:_ID:_NRSEQVENDA:TEXT+": Gravando venda..." + Chr(13) + Chr(10)
		cEventLog += " nrseqvenda='" + AllToChar(oCabec:_ID:_NRSEQVENDA:TEXT) + "'"
		cEventLog += " cdcaixa='" + AllToChar(oCabec:_ID:_CDCAIXA:TEXT) + "'"
		cEventLog += " dtentrvenda='" + AllToChar(oCabec:_VENDA:_DTENTRVENDA:TEXT) + "'"
		cEventLog += ": Gravando venda..." + Chr(13) + Chr(10)

		BeginTran()
		
			//Atualiza Consumidor - Z12
			lRet := GRVZ12(oConsu,cXEmp,cXFil)
			If !lRet
				cEventLog := cEventLog + "Erro: Na atualizacao do consumidor." + Chr(13) + Chr(10)
				DisarmTransaction()
			EndIf
			
			//Atualiza Venda - Z01 - Cabeçalho
			If lRet
				aRet := GRVZ01(oCabec,cXEmp,cXFil,aCanc,oConsu) 
				If ! (lRet := aRet[01])
					cEventLog := cEventLog + "Erro na inclusao do documento:" + Chr(13) + Chr(10) + aRet[02]
					DisarmTransaction()
				EndIf
			EndIf
			
			//Atualiza Venda - Z02 - Itens
			If lRet
				lRet := GRVZ02(oItens,cXEmp,cXFil,oEventLog,aCanc)
				If !lRet
					cEventLog := cEventLog + "Erro: Na atualizacao dos itens do documento." + Chr(13) + Chr(10)
					DisarmTransaction()
				EndIf
			EndIf

			// Atualiza Venda - Z04 - Producao
			If lRet
				lRet := GRVZ04(oProd,oProdObs,cXEmp,cXFil,oEventLog,aCanc)
				If !lRet
					cEventLog := cEventLog + "Erro: Na atualizacao dos dados da producao." + Chr(13) + Chr(10)
					DisarmTransaction()
				EndIf
			EndIf	
			
			//Atualiza Venda - Z03 - Recebimentos
			If lRet 
				lRet := GRVZ03(oReceb,cXEmp,cXFil)
				If !lRet
					cEventLog := cEventLog + "Erro: Na atualizacao dos recebimentos." + Chr(13) + Chr(10)
					DisarmTransaction()
				EndIf
			EndIf
			
		EndTran()
	
	EndIf			

	oEventLog:setAddInfo(cEventLog,"")	                                       
	ConOut(IIF(lRet,"Ok.","Erro:"+AllTrim(cEventLog)))

Return lRet



/*/{Protheus.doc} GRVZ12
//TODO Valida e grava Z12 - Consumidor
@author Mario L. B. Faria
@since 16/05/2018
@version 1.0
@return lRet, logico, .T. = Sucesso | .F. = Erro
@param oConsu, object, descricao
@param cXEmp, characters, Empresa Teknisa
@param cXFil, characters, Filial Teknisa
@param cXVenda, characters, Numero da venda Teknisa
@param cXCaixa, characters, Numero do caixa Teknisa
@type function
/*/
Static Function GRVZ12(oConsu,cXEmp,cXFil)

	Local lRet	:= .T.
	Local lNovo	:= .T.

	If lRet
		
		//Só Grava se tiver consumidor válido
		If !Empty(oConsu:_CDCONSUMIDOR:TEXT)

			Z12->( dbSetOrder(1) )
			Z12->( dbGoTop() )
			Z12->( dbSeek( xFilial("Z12") + cXEmp + cXFil  + PadR(oConsu:_CDCLIENTE:TEXT,TamSx3("Z12_CLIEN")[01]) + PadR(oConsu:_CDCONSUMIDOR:TEXT,TamSx3("Z12_CONSU")[01])  ) )
			
			If Z12->( Found() )
				lNovo := .F.
			EndIf
		
			RecLock("Z12",lNovo)
			Z12->Z12_FILIAL	:= xFilial("Z12")
			Z12->Z12_XEMP  	:= cXEmp	
			Z12->Z12_XFIL	:= cXFil
			Z12->Z12_CLIEN	:= oConsu:_CDCLIENTE:TEXT
			Z12->Z12_CONSU	:= oConsu:_CDCONSUMIDOR:TEXT
			Z12->Z12_CGC	:= oConsu:_NRINSJURCLIE:TEXT
			Z12->Z12_INSCR	:= oConsu:_NRINSESTCLIE:TEXT
			Z12->Z12_EST	:= oConsu:_SGESTADO:TEXT
			Z12->Z12_NOME	:= oConsu:_NMRAZSOCCLIE:TEXT
			Z12->Z12_NREDUZ	:= oConsu:_NMFANTCLIE:TEXT
			Z12->Z12_END	:= Alltrim(oConsu:_DSENDECONS:TEXT) + ", " + oConsu:_NRENDECONS:TEXT
			Z12->Z12_COMPLE	:= oConsu:_DSCOMPLENDECONS:TEXT
			Z12->Z12_CEP	:= oConsu:_NRCEPCONS:TEXT
			Z12->Z12_CODM	:= oConsu:_CODMUNIC:TEXT
			Z12->Z12_MUN	:= oConsu:_DSMUNICIPIO:TEXT
			Z12->Z12_BAIRRO	:= oConsu:_NMBAIRCONS:TEXT
			Z12->Z12_DDI	:= oConsu:_DDI:TEXT
			Z12->Z12_DDD	:= oConsu:_DDD:TEXT
			Z12->Z12_TEL	:= oConsu:_NRTELECONS:TEXT
			Z12->Z12_TEL2	:= oConsu:_NRTELE2CONS:TEXT
			Z12->Z12_CONTAT	:= oConsu:_NMRESPCONS:TEXT
			Z12->Z12_EMAIL	:= oConsu:_DSEMAILCONS:TEXT
			Z12->Z12_DTNASC	:= StoD(oConsu:_DTNASCCONS:TEXT)	//U_DHtoD(oConsu:_DTNASCCONS:TEXT)
			Z12->Z12_DTCAD	:= StoD(oConsu:_DTCADACLIE:TEXT)	//U_DHtoD(oConsu:_DTCADACLIE:TEXT)
			Z12->Z12_HRCAD	:= oConsu:_HRCADCLIE:TEXT
			Z12->Z12_ATIVO	:= oConsu:_ATIVO:TEXT
			Z12->(MsUnlock())
			
		EndIf

	EndIf
	
Return lRet


/*/{Protheus.doc} GRVZ01
//TODO Valida e grava Z01 - Cabeçalho da Venda
@author Mario L. B. Faria
@since 16/05/2018
@version 1.0
@return lRet, logico, .T. = Sucesso | .F. = Erro
@param oCabec, object, descricao
@param cXEmp, characters, Empresa Teknisa
@param cXFil, characters, Filial Teknisa
@type function
/*/
Static Function GRVZ01(oCabec,cXEmp,cXFil,aCanc,oConsu)
Local aRet			:={.T.,""}
Local nTamZWVPK 	:= TamSx3("ZWV_PK")[1]
Local cAliasZ01		:= GetNextAlias()
Local cAliasZ01a 	:= GetNextAlias()
Local lCxFechado	:= .F.

	// -> Verifica se já foi fechado o caixa do dia em que a venda está sendo integrada do Teknisa
	ZWV->(DbSetOrder(1))
	ZWV->(DbSeek(xFilial("ZWV")+PADR(oCabec:_VENDA:_DTENTRVENDA:TEXT,nTamZWVPK)+"W"))
	If (ZWV->(Found()) .and. ZWV->ZWV_STATUS == "I") 
		aRet[01]:=.F.
		aRet[02]:="Já foi concluido o processo de integracao de vendas para o dia " + DtoC(StoD(oCabec:_VENDA:_DTENTRVENDA:TEXT))+"."+Chr(13)+Chr(10)+"Nao podera haver vendas pendentes apos o fechamento do caixa, favor verificar com o suporte do Teknisa." 
	Else	
		// -> verifica se todos o caixa do dia foi fechado
		cAliasZ01:=GetNextAlias()		
		cQuery := "SELECT COUNT(*) TOTAL FROM " + RetSqlName("Z05") + " WHERE D_E_L_E_T_ <> '*' AND Z05_FILIAL = '"+xFilial("Z05")+"' AND Z05_DATA = '"+oCabec:_VENDA:_DTENTRVENDA:TEXT+"'"
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ01,.T.,.T.)
		
		//#TB20200826 Thiago Berna - Verifica existe registros na Z05 que nao foram integrados totalmente
		cAliasZ01a:=GetNextAlias()
		cQuery := "SELECT COUNT(*) TOTAL FROM " + RetSqlName("Z05") + " WHERE D_E_L_E_T_ <> '*' AND Z05_FILIAL = '"+xFilial("Z05")+"' AND Z05_DATA = '"+oCabec:_VENDA:_DTENTRVENDA:TEXT+"' AND Z05_XSTINT = 'P' "
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ01a,.T.,.T.)
		
		//#TB20200826 Thiago Berna - Verifica existe registros na Z05 que nao foram integrados permitindo importar cupons pendentes)
		//lCxFechado:=IIF((cAliasZ01)->TOTAL<=0,.F.,.T.)	
		lCxFechado:=IIF((cAliasZ01)->(EOF()) .Or. (cAliasZ01a)->TOTAL>=0,.F.,.T.)	
		
		(cAliasZ01)->(DbCloseArea())
		
		//#TB20200826 Thiago Berna - Verifica existe registros na Z05 que nao foram integrados permitindo importar cupons pendentes)
		(cAliasZ01a)->(DbCloseArea())
		
		If lCxFechado
			aRet[01]:=.F.
			aRet[02]:="Já foi fechado o caixa para o dia " + DtoC(StoD(oCabec:_VENDA:_DTENTRVENDA:TEXT))+"."+Chr(13)+Chr(10)+"Nao podera haver vendas pendentes apos o fechamento do caixa, favor verificar com o suporte do Teknisa." 
		EndIf	
	Endif

	// -> Se ok, grava os dados da venda	
	If aRet[01]
		RecLock("Z01",.T.)
		Z01->Z01_FILIAL	:= xFilial("Z01")
		Z01->Z01_CDEMP	:= cXEmp
		Z01->Z01_CDFIL	:= cXFil
		Z01->Z01_CAIXA	:= oCabec:_ID:_CDCAIXA:TEXT	
		Z01->Z01_SEQVDA	:= oCabec:_ID:_NRSEQVENDA:TEXT	
		Z01->Z01_DATA	:= StoD(oCabec:_VENDA:_DTVENDA:TEXT)		
		Z01->Z01_HRVDA	:= oCabec:_VENDA:_DTENTRVENDAHR:TEXT	
		Z01->Z01_ENTREG	:= StoD(oCabec:_VENDA:_DTENTRVENDA:TEXT)	
		Z01->Z01_COMAND	:= oCabec:_VENDA:_NRCOMANDAVND:TEXT	
		Z01->Z01_CDCLI	:= oConsu:_CDCLIENTE:TEXT
		Z01->Z01_CDCONS	:= oConsu:_CDCONSUMIDOR:TEXT
		Z01->Z01_NOME	:= oConsu:_NMCONSVEND:TEXT
		Z01->Z01_HORA	:= oCabec:_VENDA:_HRRPROTOCONFCE:TEXT
		Z01->Z01_OPERAD	:= oCabec:_VENDA:_CDOPERADOR:TEXT
		Z01->Z01_VRGORJ	:= U_xCharToVal(oCabec:_VENDA:_VRGORJETA:TEXT,"Z01_VRGORJ")		
		Z01->Z01_CGC	:= oCabec:_VENDA:_NRINSCRCONS:TEXT	
		Z01->Z01_SERIE	:= oCabec:_VENDA:_CDSERIENFCE:TEXT
		Z01->Z01_CUPOM	:= oCabec:_VENDA:_NRCUPOMFIS:TEXT
		Z01->Z01_CUPOMC	:= IIF(aCanc[1] .and. aCanc[2],"S","N")
		Z01->Z01_NFCE	:= oCabec:_VENDA:_NRNOTAFISCALCE:TEXT	
		Z01->Z01_UF		:= oCabec:_VENDA:_SGESTADO:TEXT
		Z01->Z01_ANFCE	:= oCabec:_VENDA:_NRLANCTONFCE:TEXT
		Z01->Z01_CHVNFC	:= oCabec:_VENDA:_NRACESSONFCE:TEXT
		Z01->Z01_DTENV	:= StoD(oCabec:_VENDA:_DTENVIONFCE:TEXT)		
		Z01->Z01_NPROT	:= oCabec:_VENDA:_NRPROTOCOLONFCE:TEXT
		Z01->Z01_DTRPRO	:= StoD(oCabec:_VENDA:_DTHRPROTOCONFCE:TEXT)
		Z01->Z01_HRRPRO	:= oCabec:_VENDA:_HRRPROTOCONFCE:TEXT
		Z01->Z01_SNFCE	:= oCabec:_VENDA:_IDSTATUSNFCE:TEXT
		Z01->Z01_OBSNFC	:= oCabec:_VENDA:_DSOBSSTATUSNFCE:TEXT
		Z01->Z01_ARQXML	:= oCabec:_VENDA:_VENDAXML:_DSARQXMLNFCE:TEXT					
		Z01->Z01_PROCAN	:= oCabec:_VENDA:_NRPROTOCOLOCANC:TEXT
		Z01->Z01_DPROCA	:= StoD(oCabec:_VENDA:_DTRPROTOCOLOCAN:TEXT)	
		Z01->Z01_HPROCA	:= oCabec:_VENDA:_HRRPROTOCOLOCAN:TEXT
		Z01->Z01_OPERA	:= oCabec:_VENDA:_CDOPERADORCANC:TEXT
		Z01->Z01_MOTCAN	:= oCabec:_VENDA:_DSRAZAOCANCNFCE:TEXT
		Z01->Z01_CHVCAN	:= oCabec:_VENDA:_NRACESSOCANC:TEXT
		Z01->Z01_QRCODE	:= oCabec:_VENDA:_LINKNF:_DSQRCODENFCE:TEXT
		Z01->Z01_TIPO	:= oCabec:_VENDA:_TIPOIMPRESSORA:TEXT
		Z01->Z01_CONTNG	:= oCabec:_VENDA:_CONTINGENCIA:TEXT
		Z01->Z01_ACRESC := U_xCharToVal(oCabec:_VENDA:_VRACRESCIMOS:TEXT,"Z01_ACRESC")
		Z01->Z01_NUMATE := U_xCharToVal(oCabec:_VENDA:_NRPESMESAVENDA:TEXT,"Z01_NUMATE") 
		Z01->Z01_XSTINT := "P"
		Z01->Z01_XDINT  := Date()
		Z01->Z01_XHRINT	:= Time()
		Z01->Z01_NOMCLI := oConsu:_NMFANTCLIE:TEXT
		Z01->(MsUnlock())
	EndIf

Return(aRet)


/*/{Protheus.doc} GRVZ02
//TODO Função verificao tipode  dados a gravar 
@author Mario L. B. Faria
@since 16/05/2018
@version 1.0
@return lRet, logico, .T. = Sucesso | .F. = Erro
@param oItens, object, descricao
@param cXEmp, characters, Empresa Teknisa
@param cXFil, characters, Filial Teknisa
@type function
/*/
Static Function GRVZ02(oItens,cXEmp,cXFil,oEventLog,aCanc)
Local lRet	   := .T.
Local cXmlProd := "" 
Local oXMLProd
Local cError   := ""
Local cWarning := ""	
Local nItem    := 0	                                                                  	
	
	If lRet
	
		If ValType(oItens) == "A"

			For nItem := 1 to Len(oItens)
				// -> Grava itens da venda
				GrvItem(oItens[nItem],cXEmp,cXFil)				
	 		Next nItem

		Else

            // -> Grava item da venda
			GrvItem(oItens,cXEmp,cXFil)

		EndIf			

	EndIf               
			
Return lRet


/*/{Protheus.doc} GrvItem
//TODO Função para validar e gravar o item
@author Mario L. B. Faria
@since 18/05/2018
@version 1.0
@param oItem, object, Item a validar e gravar
@type function
/*/
Static Function GrvItem(oItem,cXEmp,cXFil)

	Local lRet		:= .T.
	Local nItem		:= 0
	Local nValTot	:= 0
	Local nVrBrut   := 0
	Local nPerDesc	:= 0
	
	If lRet

		//Calcula o valor total e desconto
		nVrBrut  := (U_xCharToVal(oItem:_QTPRODVEND:TEXT,"Z02_QTDE") * U_xCharToVal(oItem:_VRUNITVEND:TEXT,"Z02_VRITEM"))
		nValTot	 := (U_xCharToVal(oItem:_QTPRODVEND:TEXT,"Z02_QTDE") * U_xCharToVal(oItem:_VRUNITVEND:TEXT,"Z02_VRITEM")) - U_xCharToVal(oItem:_VRDESITVEND:TEXT,"Z02_VRDESC") + U_xCharToVal(oItem:_VRACRITVEND:TEXT,"Z02_VRACRE")
		nPerDesc := 0
		If U_xCharToVal(oItem:_VRDESITVEND:TEXT,"Z02_VRDESC") > 0
			nPerDesc := NoRound((U_xCharToVal(oItem:_VRDESITVEND:TEXT,"Z02_VRDESC") * 100) / nVrBrut, TamSx3("Z02_PERDES")[02])
		EndIf
	
		RecLock("Z02",.T.)	
		Z02->Z02_FILIAL	:= xFilial("Z02")
		Z02->Z02_CDEMP	:= cXEmp	
		Z02->Z02_CDFIL	:= cXFil
		Z02->Z02_CAIXA	:= Z01->Z01_CAIXA
		Z02->Z02_SEQVDA	:= Z01->Z01_SEQVDA
		Z02->Z02_DATA	:= Z01->Z01_DATA
		Z02->Z02_ENTREG	:= Z01->Z01_ENTREG
		Z02->Z02_SEQIT	:= oItem:_NRSEQITVEND:TEXT
		Z02->Z02_PROD	:= oItem:_CDPRODUTO:TEXT
		Z02->Z02_QTDE	:= U_xCharToVal(oItem:_QTPRODVEND:TEXT,"Z02_QTDE")	
		Z02->Z02_VRITEM	:= U_xCharToVal(oItem:_VRUNITVEND:TEXT,"Z02_VRITEM")	
		Z02->Z02_VRDESC	:= U_xCharToVal(oItem:_VRDESITVEND:TEXT,"Z02_VRDESC")	
		Z02->Z02_PERDES	:= nPerDesc		
		Z02->Z02_VRACRE := U_xCharToVal(oItem:_VRACRITVEND:TEXT,"Z02_VRACRE")
		Z02->Z02_VRTOT	:= nValTot
		Z02->Z02_PRCTAB := U_xCharToVal(oItem:_VRPRECTABE:TEXT,"Z02_PRCTAB")
		Z02->Z02_VRVDCL := U_xCharToVal(oItem:_VRUNITVENDCL:TEXT,"Z02_VRVDCL")  		
		Z02->Z02_CODCST	:= oItem:_IMPOSTO:_CDIMPOSTO:TEXT
		Z02->Z02_ALIQIC := U_xCharToVal(oItem:_IMPOSTO:_VRPEALPRODIT:TEXT,"Z02_ALIQIC") 
		Z02->Z02_VRIMP	:= U_xCharToVal(oItem:_IMPOSTO:_VRIMPOPRODIT:TEXT,"Z02_VRIMP")		
		Z02->Z02_CFOP	:= oItem:_IMPOSTO:_CDCFOPPROD:TEXT
		Z02->Z02_PCOFIN	:= U_xCharToVal(oItem:_IMPOSTO:_VRPERCOFINS:TEXT,"Z02_PCOFIN")		
		Z02->Z02_PPIS	:= U_xCharToVal(oItem:_IMPOSTO:_VRPERPIS:TEXT,"Z02_PPIS")			
		Z02->Z02_PREDIM	:= U_xCharToVal(oItem:_IMPOSTO:_VRBASECALCREDUZ:TEXT,"Z02_PREDIM")
		Z02->Z02_BASCAL	:= U_xCharToVal(If(oItem:_IMPOSTO:_VRBCREDUZICMS:TEXT != '0', oItem:_IMPOSTO:_VRBCREDUZICMS:TEXT, oItem:_IMPOSTO:_VRBASECALCICMS:TEXT),"Z02_BASCAL")
		Z02->Z02_VRREDU	:= U_xCharToVal(oItem:_IMPOSTO:_VRIMPOPRODEDUZ:TEXT,"Z02_VRREDU")
		Z02->Z02_VRPIS	:= U_xCharToVal(oItem:_IMPOSTO:_VRIMPPIS:TEXT,"Z02_VRPIS")		
		Z02->Z02_VRCOFI	:= U_xCharToVal(oItem:_IMPOSTO:_VRIMPCONFINS:TEXT,"Z02_VRCOFI")
		Z02->Z02_BASPIS := U_xCharToVal(oItem:_IMPOSTO:_VRBASECALCPIS:TEXT,"Z02_BASPIS")			
		Z02->Z02_BASCOF := U_xCharToVal(oItem:_IMPOSTO:_VRBASECALCCOFINS:TEXT,"Z02_BASCOF")
		Z02->Z02_FINTE	:= "N"
		Z02->Z02_OK		:= "N"
		Z02->Z02_XDINT	:= Date()
		Z02->Z02_XHINT	:= Time()
		Z02->Z02_CODARV := oItem:_CDARVORE:TEXT
		Z02->Z02_DESCPR := oItem:_CDESCPROD:TEXT
		Z02->(MsUnlock())
		
	Endif
	
Return lRet




/*/{Protheus.doc} GrvProducao
//TODO Função para validar e itens da producao
@author Marcio Zaguetti
@since 27/07/2018
@version 1.0
@type function
/*/
Static Function GrvProducao(oProducao,cXEmp,cXFil)
Local lRet:=.T.	

	// -> Se tiver dados de produção, grava dados na tabela Z04
	If AllTrim(oProducao:_NRSEQUITVEND:TEXT) <> ""
		RecLock("Z04",.T.)	
		Z04->Z04_FILIAL	:= xfilial("Z04")
		Z04->Z04_CDEMP	:= cXEmp
		Z04->Z04_CDFIL	:= cXFil
		Z04->Z04_SEQVDA	:= cXVenda
		Z04->Z04_CAIXA	:= cXCaixa
		Z04->Z04_DATA   := StoD(cXDataVd) 
		Z04->Z04_ENTREG := StoD(cXDataEn) 
		Z04->Z04_SEQIT	:= oProducao:_NRSEQUITVEND:TEXT
		Z04->Z04_PEDFOS	:= oProducao:_NRPEDIDOFOS:TEXT
		Z04->Z04_PRDUTO	:= oProducao:_CDPRODUTO:TEXT
		Z04->Z04_CODMP	:= oProducao:_CDSUBPRODUTO:TEXT
		Z04->Z04_QTDE	:= U_xCharToVal(oProducao:_QTPRODPEFOS:TEXT,"Z04_QTDE")	
		Z04->Z04_DTINIP	:= StoD(oProducao:_DTINICIOPRODUCAO:TEXT)
		Z04->Z04_HRINIP	:= oProducao:_HRINICIOPRODUCAO:TEXT
		Z04->Z04_DTFIMP	:= StoD(oProducao:_DTFIMPRODUCAO:TEXT)
		Z04->Z04_HRFIMP	:= oProducao:_HRFIMPRODUCAO:TEXT
		Z04->Z04_XSTINT	:= "I"
		Z04->Z04_XDINT	:= Date()
		Z04->Z04_XHINT	:= Time()
		Z04->Z04_CODARV := oProducao:_CDARVORE:TEXT
		Z04->Z04_DESCPR := oProducao:_CDESCPROD:TEXT
		Z04->Z04_CODARS := oProducao:_CDARVORESUBPROD:TEXT
		Z04->Z04_DESCPS := oProducao:_CDESCSUBPROD:TEXT
		Z04->(MsUnlock())
	EndIf	 
		
Return lRet



/*/{Protheus.doc} GrvProdObs
//TODO Função para validar e itens da producao - observacoes
@author Marcio Zaguetti
@since 27/07/2018
@version 1.0
@type function
/*/
Static Function GrvProdObs(oProdObs,cXEmp,cXFil)
Local lRet:=.T.


    // -> Se existir dados da observação, grada na tabela Z04
	If AllTrim(oProdObs:_NRSEQUITVEND:TEXT) <> ""
		RecLock("Z04",.T.)	
		Z04->Z04_FILIAL	:= xfilial("Z04")
		Z04->Z04_CDEMP	:= cXEmp
		Z04->Z04_CDFIL	:= cXFil
		Z04->Z04_SEQVDA	:= cXVenda
		Z04->Z04_CAIXA	:= cXCaixa
		Z04->Z04_DATA   := StoD(cXDataVd) 
		Z04->Z04_ENTREG := StoD(cXDataEn) 
		Z04->Z04_SEQIT	:= oProdObs:_NRSEQUITVEND:TEXT
		Z04->Z04_PEDFOS	:= ""
		Z04->Z04_PRDUTO	:= oProdObs:_CDPRODUTO:TEXT
		Z04->Z04_CODMP	:= oProdObs:_CDSUBPRODUTO:TEXT
		Z04->Z04_QTDE	:= U_xCharToVal(oProdObs:_QTPRODPEFOS:TEXT,"Z04_QTDE")	
		Z04->Z04_CONTR	:= oProdObs:_CONTROLA:TEXT
		Z04->Z04_OCORR	:= oProdObs:_DSOCORR:TEXT
		Z04->Z04_CODOCO	:= oProdObs:_CDOCORR:TEXT
		Z04->Z04_GRPOCO	:= oProdObs:_CDGRPOCOR:TEXT
		Z04->Z04_IDCOBS	:= oProdObs:_IDCONTROLAOBS:TEXT		
		Z04->Z04_DTINIP	:= CtoD("//")
		Z04->Z04_HRINIP	:= ""
		Z04->Z04_DTFIMP	:= CtoD("//")
		Z04->Z04_HRFIMP	:= ""
		Z04->Z04_XSTINT	:= "I"
		Z04->Z04_XDINT	:= Date()
		Z04->Z04_XHINT	:= Time()
		Z04->(MsUnlock())
	EndIf	 		
	
Return lRet


/*/{Protheus.doc} GRVZ03
//TODO Função verificao tipode  dados a gravar 
@author Mario L. B. Faria
@since 16/05/2018
@version 1.0
@return lRet, logico, .T. = Sucesso | .F. = Erro
@param oItens, object, descricao
@param cXEmp, characters, Empresa Teknisa
@param cXFil, characters, Filial Teknisa
@type function
/*/
Static Function GRVZ03(oReceb,cXEmp,cXFil)
Local lRet		:= .T.
Local nItem     := 0
	
	If lRet
	
		If ValType(oReceb) == "A"
			For nItem := 1 to Len(oReceb)
				GrvRec(oReceb[nItem],cXEmp,cXFil)
	 		Next nItem
		Else
			GrvRec(oReceb,cXEmp,cXFil)
		EndIf
		
	EndIf
	
Return lRet



/*/{Protheus.doc} GRVZ04
//TODO Função verificao tipode  dados a gravar 
@author Marcio Zaguetti
@since 27/07/2018
@type function
/*/
Static Function GRVZ04(oProducao,oProdObs,cXEmp,cXFil,oEventLog,aCanc)
Local lRet  := .T.
Local nItem := 0
	
	If lRet
	
		// -> Grava Produtos
		If ValType(oProducao) == "A"
			For nItem := 1 to Len(oProducao)
				GrvProducao(oProducao[nItem],cXEmp,cXFil)
	 		Next nItem
		Else
			GrvProducao(oProducao,cXEmp,cXFil)
		EndIf
		
		// -> Grava observacoes
		If ValType(oProdObs) == "A"
			For nItem := 1 to Len(oProdObs)
				GrvProdObs(oProdObs[nItem],cXEmp,cXFil)
	 		Next nItem
		Else
			GrvProdObs(oProdObs,cXEmp,cXFil)
		EndIf
		
	EndIf
	
Return lRet



/*/{Protheus.doc} GrvRec
//TODO Função para validar e gravar o recebimento
@author Mario L. B. Faria
@since 18/05/2018
@version 1.0
@type function
/*/
Static Function GrvRec(oRec,cXEmp,cXFil)

Local lRet	:= .T.
	
	RecLock("Z03",.T.)		
	Z03->Z03_FILIAL		:=  xFilial("Z03")
	Z03->Z03_CDEMP		:=  cXEmp
	Z03->Z03_CDFIL		:=  cXFil
	Z03->Z03_CAIXA		:=  Z01->Z01_CAIXA
	Z03->Z03_SEQVDA		:=  Z01->Z01_SEQVDA
	Z03->Z03_DATA		:=  Z01->Z01_DATA
	Z03->Z03_ENTREG		:=  Z01->Z01_ENTREG
	Z03->Z03_COND		:=  oRec:_CONDICAO:_CDTIPOREC:TEXT  //Z10->Z10_CODIGO 
	Z03->Z03_DATA		:=  StoD(oRec:_CONDICAO:_DTMOVIMCAIXA:TEXT)		
	Z03->Z03_DTABER		:=  StoD(oRec:_CONDICAO:_DTABERCAIX:TEXT)		
	Z03->Z03_NCHEQUE	:=  oRec:_CONDICAO:_NRCHEQUEVEND:TEXT
	Z03->Z03_BCCHEQ		:=  oRec:_CONDICAO:_CDBANCHEQVEN:TEXT
	Z03->Z03_AGCHEQ		:=  oRec:_CONDICAO:_CDAGECHEQVEN:TEXT
	Z03->Z03_CTCHEQ		:=  oRec:_CONDICAO:_CDCNTCHEQVEN:TEXT
	Z03->Z03_INSCHE		:=  oRec:_CONDICAO:_NRINSJURCHEQ:TEXT
	Z03->Z03_NCART		:=  oRec:_CONDICAO:_NRCARTBANCO:TEXT
	Z03->Z03_NSU		:=  oRec:_CONDICAO:_CDNSUHOSTTEF:TEXT
	Z03->Z03_PARC		:=  U_xCharToVal(oRec:_CONDICAO:_QTPARCRECEB:TEXT,"Z03_PARC")
	Z03->Z03_VRREC		:=  U_xCharToVal(oRec:_CONDICAO:_VRMOVIVEND:TEXT,"Z03_VRREC")
	Z03->Z03_NUMVP		:=  oRec:_CONDICAO:_NUMVP:TEXT		
	Z03->Z03_XSTINT		:=  "P"
	Z03->Z03_XDINT		:=  Date()
	Z03->Z03_XHINT		:=  Time()		
	Z03->Z03_HRVDA		:=	oRec:_CONDICAO:_HRVENDA:TEXT
	Z03->(MsUnlock())       
	
Return lRet                                        



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! AUTZ01                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Verifica se o documento foi cancelado                                         !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 22/06/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function AUTZ01(cFil,cdempresa,cdfilial,cdcaixa,nseqvenda,dentrega,oEventLog)
Local aRet     := {} 
Local lOk      := .T.
Local lCanc    := .F.
Local lGeraVda := .T.
Local cXMLAut  := ""   
Local cError   := ""
Local cWarning := ""	
Local oXMLAut  

	// -> Busca XML da autorização da venda
	aRet := U_TkGetAut({cFil,cdempresa,cdfilial,cdcaixa,nseqvenda,dentrega},oEventLog)
	lOk		:= aRet[01][01]
	cXMLAut := aRet[01][02]  
	
	If lOk .and. AllTrim(cXMLAut) <> ""
		
		// -> 'Abrindo' XML autorização
		If	ValType(cXMLAut) == "C" 
			oXMLAut := XmlParser( cXMLAut, "_", @cError, @cWarning )  
		Else
			oEventLog:broken("XML de autorizacao da venda nao retornado.", @cError, .T.)	
			ConOut("XML de autorizacao da venda nao retornado.")
			ConOut(cXMLAut)
			Return({.F.,.F.,.F.,Nil})
		EndIf
		
		If AllTrim(@cError) <> ""
			oEventLog:broken("Erro: Leitura do XML de autorizacao.", @cError, .T.)	
			Return({.F.,.F.,.F.,Nil})
	    EndIf                    
		
		// -> Verifica se houve cancelamento		
		If Upper(oXMLAut:_RETORNOS:_RETORNO:_VENDA:_VENDA:_CUMPOCANCELADO:TEXT) == "S"
			lCanc   := .T.
			lGeraVda:= .T.
		EndIf	
	
	Else

		lOk := .F.
	
	EndIf		

 Return({lOk,lCanc,lGeraVda,oXMLAut})
