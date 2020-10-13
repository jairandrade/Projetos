#include 'protheus.ch'                                                         
/*-----------------+---------------------------------------------------------+
!Nome              ! TkPutProds                                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para chamr o metodo Putprodutos via Menu         !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function TkPutProds()                                      
 	
	 // -> Executa o processo para inclusão de produtos
 	TkProds("Post")			
 	
	// -> Executa o processo para alteração de produtos
 	TkProds("Put")			
 	
	 // -> Executa o processo para exclusão de produtos 
 	TkProds("Delete")			
    
Return

/*-----------------+---------------------------------------------------------+
!Nome              ! TkProds                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para processar o WS                              !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function TkProds(cMetEnv)
Local oIntegra
Local cMethod	:= "PutProdutos"
Local cAlias	:= "Z13"
Local cAlRot	:= "SB1"
Local oEventLog := EventLog():start("Produtos - "+AllTrim(cMetEnv), Date(), "Iniciando processo de integracao...", cMetEnv, cAlias) 

	//instancia a classe
	oIntegra := TeknisaPutProdutos():new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)

	//se estiver ativo
	If oIntegra:isEnable()

		//busca os registros e se sequencia em lotes
		oIntegra:prepare()

		oIntegra:send()

	EndIF
	
	oEventLog:Finish()

return
 

/*-----------------+---------------------------------------------------------+
!Nome              ! TeknisaPutProdutos                                      !
+------------------+---------------------------------------------------------+
!Descrição         ! Classe PutProdutos                                      !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
class TeknisaPutProdutos from TeknisaMethodAbstract
Data oLog
Data cMetE

	method new() constructor
	method makeXml(aLote,cMetEnv)
	method analise(oXmlItem,lNewReg)
	method fetch() 
	
endclass


/*-----------------+---------------------------------------------------------+
!Nome              ! new                                                     !
+------------------+---------------------------------------------------------+
!Descrição         ! Metodo inicializador da classe                          !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog) class TeknisaPutProdutos

	//inicialisa a classe
	::init(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)
	::oLog :=oEventLog
	::cMetE:=cMetEnv

return


/*-----------------+---------------------------------------------------------+
!Nome              ! analise                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Metodo para analizar e gravar os dados de retorno do WS !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method analise(oXmlItem,lNewReg) class TeknisaPutProdutos
Local lIntegrado := .F.
Local cErrorLog := ""
Local cCodProd  := ""
Local cCodTek   := ""
Local cCodArv   := ""
Local cCodEmp   := ""
Local cCodFil   := ""
Local cQuery	:= ""
Local cMsgErro  := ""
Local cAliasQry := GetNextAlias()
Private oItem   := oXmlItem
                                  
	// -> verifica se a propriedade integrado existe
	cMsgErro  := IIF(type("oItem:_CONFIRMACAO:_MENSAGEM:TEXT")=="C",oItem:_CONFIRMACAO:_MENSAGEM:TEXT,"")
	If type("oItem:_CONFIRMACAO:_INTEGRADO:TEXT") == "C"

		cCodProd:=IIF(Type("oItem:_ID:_CODIGOPRODUTO:TEXT") == "C",oItem:_ID:_CODIGOPRODUTO:TEXT,"")
		cCodTek :=IIF(Type("oItem:_ID:_CDPRODUTO:TEXT")     == "C",oItem:_ID:_CDPRODUTO:TEXT    ,"")
		cCodArv :=IIF(Type("oItem:_ID:_CODIGOARVORE:TEXT")  == "C",oItem:_ID:_CODIGOARVORE:TEXT,"")
		
		//-> Verifica retorno do processo 
		lIntegrado := lower(oItem:_CONFIRMACAO:_INTEGRADO:TEXT) == "true"
		If lIntegrado

			lIntegrado := lIntegrado .And. !Empty(cCodProd)
			lIntegrado := lIntegrado .And. !Empty(cCodTek)
			lIntegrado := lIntegrado .And. !Empty(cCodArv)
			
			// -> Posiciona natabela ADK
			ADK->(DbOrderNickName("ADKXFILI"))
			ADK->(DbSeek(xFilial("ADK")+xFilial("Z17")))

			lIntegrado := lIntegrado .And. ADK->(Found()) .And. !Empty(ADK->ADK_XEMP) .And. !Empty(ADK->ADK_XFIL)
            cCodEmp    := ADK->ADK_XEMP
			cCodFil    := ADK->ADK_XFIL

			// -> Se a empresa possui o código do Teknisa
			If Empty(cCodEmp) .or. !ADK->(Found())
				cErrorLog:="O cadastro da empresa " +  xFilial("Z17") + " nao retornou o codigo da empresa do Teknisa. [ADK_XEMP = " + IIF(Empty(cCodEmp),"Vazio",cCodEmp)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")	
				ConOut(cErrorLog)
			EndIf	

			// -> Se a empresa nao possui codigo da filial
			If Empty(cCodFil) .or. !ADK->(Found())
				cErrorLog:="O cadastro da empresa " +  xFilial("Z17") + " nao retornou o codigo da filial do Teknisa. [ADK_XFIL= " + IIF(Empty(cCodFil),"Vazio",cCodFil)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")	
				ConOut(cErrorLog)
			EndIf	

			// -> Se o código do produto do Teknisa não retornou, registra erro no log
			If Empty(cCodTek)
				cErrorLog:="O metodo " +Self:cMetEnv + " nao retornou o codigo produto do Teknisa. [_CODIGOPRODUTO = " + IIF(Empty(cCodTek),"Vazio",cCodTek)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")	
				ConOut(cErrorLog)
			EndIf	
			
			// -> Se o código do produto do Protheus não retornou, registra erro no log
			If Empty(cCodProd)
				cErrorLog:="O metodo " +Self:cMetEnv + " nao retornou o codigo do produto do Protheus. [_CDPRODUTO = " + IIF(Empty(cCodProd),"Vazio",cCodProd)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")	
				ConOut(cErrorLog)
			EndIf	

			// -> Se o código da arvore do produto do Teknisa não retornou, registra erro no log
			If Empty(cCodArv)
				cErrorLog:="O metodo " +Self:cMetEnv + " nao retornou o codigo da arvore do produto do Teknisa. [_CODIGOARVORE = " + IIF(Empty(cCodProd),"Vazio",cCodProd)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")	
				ConOut(cErrorLog)
			EndIf	

		Else

			cErrorLog:=cMsgErro
			::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")	
			ConOut(cErrorLog)

		EndIf

		// -> Se ocorreu erro na integração, registra status de erro
		If !lIntegrado
		
			cCodProd :=PadR(IIF(Type("oItem:_ID:_CODIGOPRODUTO:TEXT") == "C",oItem:_ID:_CODIGOPRODUTO:TEXT,""),TamSX3("B1_COD")[1])
			cErrorLog:=IIF(!Empty(cMsgErro),cMsgErro,"Erro indeterminado, verifique com a area de TI do MADERO")

			// -> Posiciona no cadastro do porduto
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+cCodProd))

			// -> Posiciona na tabela de produtos a integrar
			dbSelectArea("Z13")
			Z13->(dbSetOrder(1))
			Z13->(dbSeek(xFilial("Z13")+cCodProd))
			If Z13->(Found())
				RecLock("Z13",.F.)
				Z13->Z13_XSTINT:="E"
				Z13->Z13_XDINT :=Date()
				Z13->Z13_XHINT :=Time()
				Z13->Z13_XUSER := IIF(Empty(SB1->B1_XUSER),cUserName,SB1->B1_XUSER)
				Z13->Z13_XLOG  :=cErrorLog
				Z13->(msUnLock())
			EndIf
		
		EndIf

	Else

		cErrorLog:=IIF(!Empty(cMsgErro),cMsgErro,"Erro indeterminado, verifique com a area de TI do MADERO")
		::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")		
		ConOut(cErrorLog)
	
	EndIF

	If lIntegrado

		cCodProd:=PadR(IIF(Type("oItem:_ID:_CODIGOPRODUTO:TEXT") == "C",oItem:_ID:_CODIGOPRODUTO:TEXT,""),TamSX3("B1_COD")[1])
		cCodTek :=IIF(Type("oItem:_ID:_CDPRODUTO:TEXT")     == "C",oItem:_ID:_CDPRODUTO:TEXT    ,"")
		cCodArv :=IIF(Type("oItem:_ID:_CODIGOARVORE:TEXT")  == "C",oItem:_ID:_CODIGOARVORE:TEXT,"")

		cErrorLog:=": "+AllTrim(cCodProd)+": Atualizando status no ERP..." 
		::oLog:SetAddInfo(cErrorLog,"Retorno dos dados.")
		ConOut(cErrorLog)

		// -> Posiciona no cadastro do porduto
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+cCodProd))

		// -> Posiciona na tabela de produtos a integrar
		dbSelectArea("Z13")
		Z13->(dbSetOrder(1))
		Z13->(dbSeek(xFilial("Z13")+cCodProd))
		lIntegrado := Z13->(Found())
		If lIntegrado

			Begin Transaction 
				
				// -> Atualiza tabela de proddutos do processo de integração
				RecLock("Z13", .F.)
				Z13->Z13_XSTINT	:= "I"
				Z13->Z13_XDINT	:= Date()
				Z13->Z13_XHINT	:= Time()
				Z13->Z13_XCODEX	:= cCodTek
				Z13->Z13_XCDARV	:= cCodArv
				Z13->Z13_XUSER  := IIF(Empty(SB1->B1_XUSER),cUserName,SB1->B1_XUSER)
				Z13->Z13_XLOG   := "Produto "+IIF(UPPER(Self:cMetEnv) == "POST","incluido ",IIF(UPPER(Self:cMetEnv) == "PUT","alterado ","excluido ")) + " com sucesso em " + DtoC(Date()) + " as " + Time() 
				Z13->(msUnLock())

				If SB1->(Found())
								
					// -> Atualiza cadastro do produto
					RecLock("SB1",.F.)
					SB1->B1_XCODEXT:=cCodTek
					SB1->B1_XCODARV:=cCodArv
					SB1->(msUnLock())						
				
					// -> Atualiza dados para ativação
					DbSelectArea("Z17")
					Z17->(dbSetOrder(1))
					Z17->(dbSeek(xFilial("Z17")+Z13->Z13_COD))	
					If Z17->(found()) .and. (Z13->Z13_XEXC <> "S" .or. !Empty(xFilial("Z13"))) 				
						RecLock("Z17", .F.)
						Z17->Z17_XCODEX := Z13->Z13_XCODEX
						Z17->Z17_XCDARV	:= Z13->Z13_XCDARV
						Z17->Z17_XSTINT	:= "P"
						Z17->Z17_XATIVO	:= IIF(Z13->Z13_XEXC == "S" .or. SB1->B1_MSBLQL == "1","N","S")
						Z17->Z17_XDTMOV := Date()
						Z17->Z17_XHRMOV := Time()
						Z17->Z17_XUSER  := IIF(Empty(SB1->B1_XUSER),cUserName,SB1->B1_XUSER)
						Z17->Z17_XLOG   := IIF(Z13->Z13_XEXC == "S" .or. SB1->B1_MSBLQL == "1","Desativado","Ativado")+" produto na filial " + cFilAnt + " e aguardando a integracao com o Teknisa."
						Z17->( msUnLock() )
					ElseIf (Z13->Z13_XEXC <> "S" .or. !Empty(xFilial("Z13"))) 				
						RecLock("Z17", .T.)
						Z17->Z17_FILIAL := xFilial("Z17")
						Z17->Z17_XEMP	:= cCodEmp
						Z17->Z17_XFIL	:= cCodFil
						Z17->Z17_COD    := SB1->B1_COD
						Z17->Z17_DESC   := SB1->B1_DESC
						Z17->Z17_XCODEX := Z13->Z13_XCODEX
						Z17->Z17_XCDARV	:= Z13->Z13_XCDARV
						Z17->Z17_XSTINT	:= "P"
						Z17->Z17_XATIVO	:= IIF(Z13->Z13_XEXC == "S" .or. SB1->B1_MSBLQL == "1","N","S")
						Z17->Z17_XDINT  := CtoD("  /  /  ")
						Z17->Z17_XHINT  := ""
						Z17->Z17_XDTMOV := Date()
						Z17->Z17_XHRMOV := Time()
						Z17->Z17_XUSER  := IIF(Empty(SB1->B1_XUSER),cUserName,SB1->B1_XUSER)
						Z17->Z17_XLOG   := IIF(Z13->Z13_XEXC == "S" .or. SB1->B1_MSBLQL == "1","Desativado","Ativado")+" produto na filial " + cFilAnt + " e aguardando a integracao com o Teknisa."
						Z17->(msUnLock())					
					EndIf

				ElseIf Z13->Z13_XEXC <> "S"
					
					cErrorLog:="Erro: Produto nao encontrado no cadastro na tabela SB1. [B1_COD="+cCodProd+" e B1_FILIAL="+xFilial("SB1")+"]"
					::oLog:SetAddInfo(cErrorLog,"Gravacao dos dados.")
					ConOut(cErrorLog)		
				
				EndIf					

				// -> Se o produto foi excluido atualiza todos os status da tabela de ativação
				If Z13->Z13_XEXC == "S" .and. Empty(xFilial("Z13"))
					cQuery := "	SELECT R_E_C_N_O_ REC                          " + CRLF
					cQuery += " FROM " + RetSqlName("Z17") + "                 " + CRLF
					cQuery += "	WHERE D_E_L_E_T_ <> '*'                    AND " + CRLF 
					cQuery += "	      Z17_COD     = '" + Z13->Z13_COD + "'     " + CRLF 						
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
					
					While !(cAliasQry)->(Eof())

						// -> Posiciona no registro de ativação
						Z17->(dbGoTo((cAliasQry)->REC))

						// Atualiza registro de ativação
						RecLock("Z17", .F.)
						Z17->Z17_XSTINT	:= "I"
						Z17->Z17_XATIVO	:= "N"
						Z17->Z17_XDINT  := Date()
						Z17->Z17_XHINT  := Time()
						Z17->Z17_XUSER  := Z13->Z13_XUSER
						Z17->Z17_XLOG   := "Excluido produto na filial " + cFilAnt + " e atualizado o status de ativacao."
						Z17->(MsUnlock())

						(cAliasQry)->(DbSkip())

					EndDo

					(cAliasQry)->(DbCloseArea())

				EndIf	

				cErrorLog:="Ok: Produto "+IIF(UPPER(Self:cMetEnv) == "POST","incluido ",IIF(UPPER(Self:cMetEnv) == "PUT","alterado ","excluido "))
				::oLog:SetAddInfo(cErrorLog,"Gravacao dos dados.")
				ConOut(cErrorLog)

				::oEventLog:setCountInc()

			End Transaction

		Else
			
			cErrorLog:="Erro: Produto nao encontrado no cadastros da integracao. [Z13_COD="+cCodProdT+"]"
			::oLog:SetAddInfo(cErrorLog,"Gravacao dos dados.")
			ConOut(cErrorLog)		
		
		EndIf

	EndIf

return

/*-----------------+---------------------------------------------------------+
!Nome              ! fetch                                                   !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o       ! Executa consulta generica para selecionar dados a enviar!
+------------------+---------------------------------------------------------+
!Autor             ! Márcio A. Zaguetti                                      !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2019                                              !
+------------------+--------------------------------------------------------*/
method fetch() class TeknisaPutProdutos
Local cQuery	:= ''
		
		cQuery += "	SELECT " + CRLF
		cQuery += "		" + ::cAlias + ".R_E_C_N_O_ ROT_REG, " + CRLF	//Recno da tabela Principal
		cQuery += "		    0                      ALI_REG " + CRLF		//Recno da tabela Auxiliar
		cQuery += "	FROM  " + RetSqlName(::cAlias) + " " + ::cAlias +  " " + CRLF
		cQuery += "	WHERE " + PrefixoCpo(::cAlias) + "_XSTINT IN ('P','E')               " + CRLF 
		cQuery += "   AND " + PrefixoCpo(::cAlias) + "_XFILI  = '"  + xFilial("SB1") + "'" + CRLF
		
		If Upper(::cMetEnv) == "POST"
			cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XCODEX = ' ' " + CRLF
			cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XEXC  != 'S' " + CRLF
		ElseIf Upper(::cMetEnv) == "PUT"
			cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XCODEX != ' ' "  + CRLF
			cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XEXC   != 'S'  " + CRLF
		ElseIf Upper(::cMetEnv) == "DELETE"
			cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XEXC = 'S'   " + CRLF
		EndIf
		
		cQuery += "		AND " + ::cAlias + ".D_E_L_E_T_ = ' ' " + CRLF
	
		MemoWrite("C:\TEMP\" + ::cMethod + "_" + ::cMetEnv + ".sql",cQuery)
	
		cQuery := ChangeQuery(cQuery)
	
return MPSysOpenQuery(cQuery)

/*-----------------+---------------------------------------------------------+
!Nome              ! makeXml                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Metodo para gerar o XML de envio                        !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method makeXml(aLote,cMetEnv) class TeknisaPutProdutos
Local cXml
Local nC
Local aAlter	:= {}
Local nX		:= 0
Local cTamN1	:= TamSx3("Z18_COD")[1]
Local cTamN2	:= TamSx3("Z19_CODN2")[1]
Local cTamN3	:= TamSx3("Z20_CODN3")[1]
Local cTamN4	:= TamSx3("Z21_CODN4")[1]
Local cN1		:= ""
Local cN2		:= ""
Local cN3		:= ""
Local cN4		:= ""
Local cCodN1	:= ""
Local cDescN1	:= ""
Local cCodN2	:= ""
Local cDescN2	:= ""
Local cCodN3	:= ""
Local cDescN3	:= ""
Local cCodN4	:= ""
Local cDescN4	:= ""
Local cUMP	    := ""
Local cUMS	    := ""
Local cCodCEST  := ""
Local cGrpClie  := GetMv("MV_XGRCLIU",,"")
Local cErrorLog := ""
Local lErroXML  := .F.
Local cUFFilial := GetMV("MV_ESTADO",,"")
	
	dbSelectArea("Z13")
	Z13->( dbSetOrder(1) )
	
	cXml := '<produtos>'   
	
	cErrorLog:=": Gerando XML..." 
	::oLog:SetAddInfo(cErrorLog,"Gerando XML...")
	ConOut(cErrorLog)
	
	// -> Pesquisa no cadastro de empresas
	ADK->(DbOrderNickName("ADKXFILI"))
	ADK->(DbSeek(xFilial("ADK")+cFilAnt))
	If !ADK->(Found())
		cErrorLog:="Erro: Filial " + cFilAnt + " nao foi encontrada no cadastro de unidades de negocio. [ADK_XFILI="+cFilAnt+"]" 
		::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")		
		ConOut(cErrorLog)
		Return("")
	ElseIf Empty(ADK->ADK_XFIL) .or. ADK->ADK_XFIL == "0000"
		cErrorLog:="Erro: Filial " +  cFilAnt + " nao está integrada corretamente no Teknisa. [ADK_XFILI="+IIF(Empty(ADK->ADK_XEMP),"Vazio",ADK->ADK_XEMP)+" e ADK_XFIL="+IIF(Empty(ADK->ADK_XFIL),"Vazio",ADK->ADK_XFIL)+"]" 
		::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")		
		ConOut(cErrorLog)
		Return("")
	EndIf			

	// -> Verifica o estado da UF a ser integrado, para tratamento dos impostos
	If Empty(cUFFilial) .or. cUFFilial <> ADK->ADK_EST
		cErrorLog:="Erro: UF invalida para a filial " +  cFilAnt + " e parameto MV_ESTADO. [ADK_EST="+ADK->ADK_EST+" e MV_ESTADO="+cUFFilial+"]" 
		::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")	
		ConOut(cErrorLog)
		Return("")
	EndIf

	lErroXML  := .F.
	For nC := 1 to len(aLote)

		cCodN1	:= ""
		cDescN1	:= ""
		cCodN2	:= ""
		cDescN2	:= ""
		cCodN3	:= ""
		cDescN3	:= ""
		cCodN4	:= ""                              
		cDescN4	:= ""
		cUMP	:= ""
		cUMS	:= ""
		//cCodCEST:= ""
		lErroXML:= .F.
		aAlter  := {}
		

		If Lower(cMetEnv) != "delete"

			// -> Posiciona na tabela de produtos x unidades 
			Z13->(DbGoto(aLote[nC,01]))
			If Empty(Z13->Z13_XCODEX) .and. Lower(cMetEnv) == "put"
				lErroXML :=.T.
				cErrorLog:="Erro: Nao ha codigo de relacionamento do produto com o Teknisa. [Z13_COD="+AllTrim(Z13->Z13_COD)+" e Z13_XCODEX=Vazio]" 
				::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")		
				ConOut(cErrorLog)
				Loop
			EndIf

			// -> posiciona no produto
			SB1->(DbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+Z13->Z13_COD))			
			If !SB1->(Found())
				lErroXML :=.T.
				cErrorLog:="Erro: Produto nao encontrado no Prothues. [B1_COD="+AllTrim(Z13->Z13_COD)+" e B1_FILIAL="+xFilial("SB1")+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")	
				ConOut(cErrorLog)
				Loop
			EndIf

			// -> Posiciona no grupo de tributação
			//SF7->(DbGoTop())
			//SF7->(DbOrderNickName("SF7GRPEST"))
			//SF7->(DbSeek(xFilial("SF7")+SB1->B1_GRTRIB+cGrpClie+cUFFilial))
			//If SF7->(Found())
			//	cCodCEST:=SF7->F7_SITTRIB
			//EndIf
			
			// -> Posiciona na tabela de unidades de medida - Principal
			SAH->(DbSetOrder(1))
			SAH->(DbSeek(xFilial("SAH")+SB1->B1_UM))
			If SAH->(Found())
			   cUMP := SAH->AH_XCODEX
			EndIf
			
			// -> Posiciona na tabela de unidades de medida - Secundaria
			SAH->(DbSetOrder(1))
			SAH->(DbSeek(xFilial("SAH")+SB1->B1_SEGUM))
			If SAH->(Found())
				cUMS := SAH->AH_UNIMED
			EndIf
				
            // -> Posiciona na tabela de produtos alternativos
			SGI->( dbGoTop() ) 
			SGI->( dbSeek(xFilial("SGI")+SB1->B1_COD))
			If SGI->(Found())
				While !SGI->(Eof()) .and. SGI->GI_FILIAL == xFilial("SB1") .and. SGI->GI_PRODORIG == SB1->B1_COD
					aAdd(aAlter,{SGI->GI_PRODALT})
					SGI->(dbSkip())
				EndDo
			EndIf                              
			                   
			// -> Posiciona na tabea de nÃ­vel 1  do Teknisa
			Z18->(DbSetOrder(1))
			If Z18->(DbSeek(xFilial("Z18")+SB1->B1_XN1))
				cCodN1  := Z18->Z18_COD
				cDescN1 := Z18->Z18_DESCN1				
				// -> Posiciona na tabea de nÃ­vel 2  do Teknisa
				Z19->(DbSetOrder(1))
				If Z19->(DbSeek(xFilial("Z19")+Z18->Z18_COD+SB1->B1_XN2))
					cCodN2	:= Z19->Z19_CODN2
					cDescN2	:= Z19->Z19_DESCN2
                Else
					lErroXML :=.F.
					cErrorLog:="Erro: Nao encontrado cadastro do nivel 2 da estrutura do produto do Teknisa na tabela Z19.  [Z19_CODN1="+AllTrim(Z18->Z18_CODN1)+", Z19_CODN2="+AllTrim(SB1->B1_XN2)+" e B1_COD="+AllTrim(SB1->B1_COD)+"]" 
					::oLog:SetAddInfo(cErrorLog,"Aviso na geracao do XML.")
					ConOut(cErrorLog)
                EndIf                
				// -> Posiciona na tabea de nÃ­vel 3  do Teknisa
				Z20->(DbSetOrder(1))
				If Z20->(DbSeek(xFilial("Z20")+Z19->Z19_CODN1+Z19->Z19_CODN2+SB1->B1_XN3))
					cCodN3	:= Z20->Z20_CODN3
					cDescN3	:= Z20->Z20_DESCN3
                Else
					lErroXML :=.F.
					cErrorLog:="Erro: Nao encontrado cadastro do nivel 3 da estrutura do produto do Teknisa na tabela Z20.  [Z20_CODN1="+AllTrim(Z19->Z19_CODN1)+", Z20_CODN2="+AllTrim(Z19->Z19_CODN2)+", Z20_CODN3="+AllTrim(SB1->B1_XN3)+" e B1_COD="+AllTrim(SB1->B1_COD)+"]" 
					::oLog:SetAddInfo(cErrorLog,"Aviso na geracao do XML.")
					ConOut(cErrorLog)
                EndIf
				// -> Posiciona na tabea de nÃ­vel 4  do Teknisa
				Z21->(DbSetOrder(1))
				If Z21->(DbSeek(xFilial("Z21")+Z20->Z20_CODN1+Z20->Z20_CODN2+Z20->Z20_CODN3+SB1->B1_XN4))
					cCodN4	:= Z21->Z21_CODN4
					cDescN4	:= Z21->Z21_DESCN4
                Else
					lErroXML :=.F.
					cErrorLog:="Erro: Nao encontrado cadastro do nivel 4 da estrutura do produto do Teknisa na tabela Z21.  [Z21_CODN1="+AllTrim(Z20->Z20_CODN1)+", Z21_CODN2="+AllTrim(Z20->Z20_CODN2)+", Z21_CODN3="+AllTrim(Z20->Z20_CODN3)+", Z21_CODN4="+AllTrim(SB1->B1_XN4)+" e B1_COD="+AllTrim(SB1->B1_COD)+"]" 
					::oLog:SetAddInfo(cErrorLog,"Aviso na geracao do XML.")
					ConOut(cErrorLog)
                EndIf
			Else				
				lErroXML :=.F.
				cErrorLog:="Erro: Nao encontrado cadastro do nivel 1 da estrutura do produto do Teknisa na tabela Z18.  [Z18_COD="+AllTrim(SB1->B1_XN1)+" e B1_COD="+AllTrim(SB1->B1_COD)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Aviso na geracao do XML.")
				ConOut(cErrorLog)
            EndIf                                                                

			// -> Se não ocorreu erro
			If !lErroXML
			
				cXml += '<produto>'

				cXml += '<id'
				cXml += ::tag('cdproduto'		,Z13->Z13_XCODEXT)
				cXml += ::tag('codigoproduto'	,SB1->B1_COD)
				cXml += '/>'
			
				cXml += '<cadastral'
				cXml += ::tag('nivel1'			,cCodN1)
				cXml += ::tag('dsnivel1'		,cDescN1)
				cXml += ::tag('nivel2'			,cCodN2)
				cXml += ::tag('dsnivel2'		,cDescN2)	
				cXml += ::tag('nivel3'			,cCodN3)
				cXml += ::tag('dsnivel3'		,cDescN3)	
				cXml += ::tag('nivel4'			,cCodN4)
				cXml += ::tag('dsnivel4'		,cDescN4)
				cXml += ::tag('grupo'			,SB1->B1_GRUPO)
				cXml += ::tag('nmprodut'		,SB1->B1_DESC)
				cXml += ::tag('tipo'			,SB1->B1_TIPO)
				cXml += ::tag('sunidade'		,cUMP)
				cXml += ::tag('local'			,SB1->B1_LOCPAD)
				cXml += ::tag('segunmedida'		,cUMS)
				cXml += ::tag('fatorconversao'	,SB1->B1_TIPCONV)
				cXml += ::tag('vrfatoconv'		,SB1->B1_CONV		,"decimal")
				cXml += ::tag('vrpreunit'		,SB1->B1_PRV1		,"decimal")
				cXml += ::tag('custostandard'	,SB1->B1_CUSTD		,"decimal")
				cXml += ::tag('pesobruto'		,SB1->B1_PESBRU		,"decimal")
				cXml += ::tag('vrpesounid'		,SB1->B1_PESO		,"decimal")
				cXml += ::tag('cdbarproduto'	,SB1->B1_CODBAR)
				cXml += ::tag('ncm'             ,SB1->B1_POSIPI)
				cXml += ::tag('origem'          ,SB1->B1_ORIGEM)
				cXml += ::tag('cdcest'          ,SB1->B1_CEST)			
				cXml += ::tag('ativo'			,If(SB1->B1_MSBLQL == "1","N","S"))
				cXml += '/>'
			
				cXml += '<alternativos>'
				If Len(aAlter) > 0
					For nX := 1 to Len(aAlter)
						cXml += '<alternativo'
						cXml += ::tag('codigoalternativo'	,aAlter[nX][1])
						cXml += '/>'
					Next nX
				Else
					cXml += '<alternativo'
					cXml += ::tag('codigoalternativo'	,"")
					cXml += '/>'
				EndIf
				cXml += '</alternativos>'
	
				cXml += '</produto>'
				
			EndIf	
			
		Else
		
			Z13->(dbGoTo(aLote[nC,01]))			
			If Z13->(Eof())
				lErroXML :=.T.
				cErrorLog:="Erro: Produto nao encontrado na tabela de integracao com o Teknisa." 
				::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")		
				ConOut(cErrorLog)
				Loop
			ElseIf Empty(Z13->Z13_XCODEX) 
				lErroXML :=.T.
				cErrorLog:="Erro: Nao ha codigo de relacionamento do produto com o Teknisa. [Z13_COD="+AllTrim(Z13->Z13_COD)+" e Z13_XCODEX=Vazio]" 
				::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")		
				ConOut(cErrorLog)			
				Loop
			EndIf
			
			cN1 := SubStr(Z13->Z13_XCDARV,1,cTamN1)
			cN2 := SubStr(Z13->Z13_XCDARV,cTamN1 + 1,cTamN2)
			cN3 := SubStr(Z13->Z13_XCDARV,cTamN1 + cTamN2 + 1,cTamN3)
			cN4 := SubStr(Z13->Z13_XCDARV,cTamN1 + cTamN2 + cTamN3 + 1,cTamN4)
		
			// -> Posiciona na tabea de nÃ­vel 1  do Teknisa
			Z18->(DbSetOrder(1))
			If Z18->(DbSeek(xFilial("Z18")+cN1))
				cCodN1  := Z18->Z18_COD
				cDescN1 := Z18->Z18_DESCN1				
				// -> Posiciona na tabea de nÃ­vel 2  do Teknisa
				Z19->(DbSetOrder(1))
				If Z19->(DbSeek(xFilial("Z19")+Z18->Z18_COD+cN2))
					cCodN2	:= Z19->Z19_CODN2
					cDescN2	:= Z19->Z19_DESCN2
                Else
					lErroXML :=.F.
					cErrorLog:="Erro: Nao encontrado cadastro do nivel 2 da estrutura do produto do Teknisa na tabela Z19.  [Z19_CODN1="+AllTrim(Z18->Z18_COD1)+" e Z19_CODN2="+AllTrim(cN2)+"]" 
					::oLog:SetAddInfo(cErrorLog,"Aviso de cadastro de niveis do codigo do produto no Teknisa.")
					ConOut(cErrorLog)
                EndIf                
				// -> Posiciona na tabea de nÃ­vel 3  do Teknisa
				Z20->(DbSetOrder(1))
				If Z20->(DbSeek(xFilial("Z20")+Z19->Z19_CODN1+Z19->Z19_CODN2+cN3))
					cCodN3	:= Z20->Z20_CODN3
					cDescN3	:= Z20->Z20_DESCN3
                Else
					lErroXML :=.F.
					cErrorLog:="Erro: Nao encontrado cadastro do nivel 3 da estrutura do produto do Teknisa na tabela Z20.  [Z20_CODN1="+AllTrim(Z19->Z19_CODN1)+", Z20_CODN2="+AllTrim(Z19->Z19_CODN2)+" e Z20_CODN3="+AllTrim(cN3)+"]" 
					::oLog:SetAddInfo(cErrorLog,"Aviso de cadastro de niveis do codigo do produto no Teknisa.")
					ConOut(cErrorLog)
				EndIf					
				// -> Posiciona na tabea de nÃ­vel 4  do Teknisa
				Z21->(DbSetOrder(1))
				If Z21->(DbSeek(xFilial("Z21")+Z20->Z20_CODN1+Z20->Z20_CODN2+Z20->Z20_CODN3+cN4))
					cCodN4	:= Z21->Z21_CODN4
					cDescN4	:= Z21->Z21_DESCN4
                Else
					lErroXML :=.F.
					cErrorLog:="Erro: Nao encontrado cadastro do nivel 4 da estrutura do produto do Teknisa na tabela Z21.  [Z21_CODN1="+AllTrim(Z20->Z20_CODN1)+", 	Z21_CODN2="+AllTrim(Z20->Z20_CODN2)+", Z21_CODN3="+AllTrim(Z20->Z20_CODN3)+" e Z21_CODN4="+AllTrim(cN4)+"]" 
					::oLog:SetAddInfo(cErrorLog,"Aviso de cadastro de niveis do codigo do produto no Teknisa.")
					ConOut(cErrorLog)
				EndIf

			Else				
				lErroXML :=.F.
				cErrorLog:="Erro: Nao encontrado cadastro do nivel 1 da estrutura do produto do Teknisa na tabela Z18.  [Z18_COD="+AllTrim(cN1)+"]" 
					::oLog:SetAddInfo(cErrorLog,"Aviso de cadastro de niveis do codigo do produto no Teknisa.")
				ConOut(cErrorLog)
            EndIf                                                                

			If !lErroXML
			
				cXml += '<produto>'
			
				cXml += '<id'
				cXml += ::tag('cdproduto'		,Z13->Z13_XCODEXT)
				cXml += ::tag('codigoproduto'	,Z13->Z13_COD)
				cXml += '/>'

				cXml += '<cadastral'                                                        
				cXml += ::tag('nivel1'			,cCodN1)
				cXml += ::tag('dsnivel1'		,cDescN1)
				cXml += ::tag('nivel2'			,cCodN2)
				cXml += ::tag('dsnivel2'		,cDescN2)
				cXml += ::tag('nivel3'			,cCodN3)
				cXml += ::tag('dsnivel3'		,cDescN3)
				cXml += ::tag('nivel4'			,cCodN4)
				cXml += ::tag('dsnivel4'		,cDescN4)
				cXml += ::tag('grupo'			,"")
				cXml += ::tag('nmprodut'		,"")
				cXml += ::tag('tipo'			,"")
				cXml += ::tag('sunidade'		,"")
				cXml += ::tag('local'			,"")
				cXml += ::tag('segunmedida'		,"")
				cXml += ::tag('fatorconversao'	,"")
				cXml += ::tag('vrfatoconv'		,"")
				cXml += ::tag('vrpreunit'		,"")
				cXml += ::tag('custostandard'	,"")
				cXml += ::tag('pesobruto'		,"")
				cXml += ::tag('vrpesounid'		,"")
				cXml += ::tag('cdbarproduto'	,"")
				cXml += ::tag('ncm'             ,"")
				cXml += ::tag('origem'          ,"")
				cXml += ::tag('cdcest'          ,"")			
				cXml += ::tag('ativo'			,"")
				cXml += '/>'
			
				cXml += '<alternativos>'
				cXml += '<alternativo'
				cXml += ::tag('codigoalternativo'	,"")
				cXml += '/>'
				cXml += '</alternativos>'
			
				cXml += '</produto>'
				
			EndIf
						
		EndIf

 	Next nC

	cXml += '</produtos>'
	
	If AllTrim(cXml) == "<produtos></produtos>"
		cXml:=""
	EndIf
	
	MemoWrite("C:\TEMP\XML_" + cMetEnv + ".XML",cXml)

return cXml