#INCLUDE 'protheus.ch'
#INCLUDE "restful.ch" 
/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GetProdutosAInventariar                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração do Metodo GetAcesso                                                !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Revisões         ! Márcio A. Zaguetti                                                            !
+------------------+-------------------------------------------------------------------------------+
! Informações      ! Foram realizados ajustes no fonte para correção de problemas de implementacao !
! Adicionais       ! e boas práticas de implementação                                              !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
WSRESTFUL GetProdutosAInventariar DESCRIPTION "Madero - Produtos a Inventariar"

	WSMETHOD POST DESCRIPTION "Produtos a Inventariar" WSSYNTAX "/GetProdutosAInventariar"

End WSRESTFUL


 /*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GET                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração do Metodo GetProdutosAInventariar                                  !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
WSMETHOD POST WSSERVICE GetProdutosAInventariar
Local cBody 	:= ::GetContent()
Local cXml		:= ""
Local nThrdID   := ThreadId()
Local cEmpProth := "01"
Local cFilProth := "01GDAD0001"

	ConOut(AllTrim(Str(nThrdID))+": Requisitando metodo GetProdutosAInventariar em " + DtoC(Date()) + " as " + Time())
	
	::SetContentType("application/xml")
	
	ConOut(AllTrim(Str(nThrdID))+": GetProdutosAInventariar: Carregando dicionario de dados...")
	RpcClearEnv()
	RPcSetType(3)
	RpcSetEnv(cEmpProth,cFilProth,,,"FAT",GetEnvServer() )
	OpenSm0(cEmpProth, .f.)
	nModulo:=5
	SM0->(dbSetOrder(1))
	If SM0->(dbSeek(cEmpProth+cFilProth))
		cEmpAnt  := cEmpProth
		cFilAnt  := cFilProth						
		dDataBase:=Date()
	Else
		ConOut(AllTrim(Str(nThrdID))+": GetProdutosAInventariar: Erro ao abrir o dicionário de dados.")
		Return(.F.)
	EndIf

	cXml := WSEST002(cBody,nThrdID)

	::SetResponse(cXml)	

Return .T.

 /*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ProtheusMethodAbstract                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração das classe ProtheusMethodAbstract                                  !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Class ProtheusGetProdutosAInventariar From ProtheusMethodAbstract

	Method new(cMethod) constructor
	Method MakeXml(cUsr, cDtaInv, lInteg, cMsg, cArqCsv, cdEmpresa, cdfilial, cxFil, cIdInv, nThrdID)
	Method AnaliseAce(oXmlAce, nThrdID) 
	Method AnaliseGrp(oXml, nThrdID)
	Method AnalisePrd(cGrp, nThrdID)
	Method VerInvAbe(nThrdID) 

EndClass

 /*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ProtheusGetProdutosAInventariar                                               !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração das classe ProtheusGetProdutosAInventariar                         !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                

Method New(cMethod) Class ProtheusGetProdutosAInventariar
	::cMethod := cMethod
Return


 /*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! makeXml                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Metodo para gerar XML do WS GetGruposProdutos                                 !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 17/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Method MakeXml(cUsr, cDtaInv, lInteg, cMsg, cArqCsv, cdEmpresa, cdfilial, cxFil, cIdInv, nThrdID) Class ProtheusGetProdutosAInventariar
Local cXml := ''

	cXml += '<?xml version="1.0" encoding="ISO-8859-1"?>'	
	cXml += '<retorno>'
	
	cXml += '<id ' 
	cXml += 'cdempresa="'     + cdEmpresa     + '" '	
	cXml += 'cdfilial="'      + cdfilial      + '" '
	cXml += 'filial="'	      + cxFil         + '" '		
	cXml += 'idusuario="'     + AllTrim(cUsr) + '" '		
	cXml += 'datainventario="'+ cDtaInv       + '" '
	cXml += 'nomearquivo="'	  + cArqCsv       + '" '
	cXml += 'idinventario="'  + cIdInv        + '" '
	cXml += '/>'

	cXml += '<confirmacao>' 
	cXml += '<confirmacao ' 
	cXml += 'integrado="'     + IIF(lInteg,"true","false") + '" '
	cXml += 'mensagem="'	  + IIF(lInteg,"Inventario gerado com sucesso.",cMsg) + '" '
	cXml += 'data="'		  + Dtos(Date()) + '" '                
	cXml += 'hora="'		  + Time() + '" '	
	cXml += '/>'
	cXml += '</confirmacao>' 
	
	cXml += '</retorno>'

Return cXml


 /*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! AnaliseAce                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Metodo para validar os acessos a filial                                       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Method AnaliseAce(oXmlAce, nThrdID) class ProtheusGetProdutosAInventariar
Local lErro		:= .F.
Local cErro		:= ""
Local aRet      := {}
Local cQuery	:= ""
Local cAlQry	:= ""
Local cdEmpresa := oXmlAce:_CDEMPRESA:TEXT
Local cdFilial	:= oXmlAce:_CDFILIAL:TEXT	
Local cEmail    := ""
Local cxEmp 	:= ""
Local cxFil 	:= ""
Local cxNomeEmp := ""
	
	ConOut(AllTrim(Str(nThrdID))+": Verificando dados de empresa e filial...")
	If !Empty(cdEmpresa) .Or. !Empty(cdFilial)

		cQuery := "	SELECT ADK_XFILI, ADK_XGEMP, ADK_NOME, ADK_EMAIL "  + CRLF
		cQuery += "	FROM " + RetSqlName("ADK") + " ADK "                + CRLF
		cQuery += "	WHERE "                                             + CRLF
		cQuery += "			ADK_FILIAL = '" + xFilial("ADK") + "' "     + CRLF
		cQuery += "		AND ADK_XEMP = '" + cdEmpresa + "' "            + CRLF
		cQuery += "		AND ADK_XFIL = '" + cdFilial + "' "             + CRLF
		cQuery += "		AND ADK.D_E_L_E_T_ = ' ' "                      + CRLF
		cQuery := ChangeQuery(cQuery)
		cAlQry := MPSysOpenQuery(cQuery)

		If !(cAlQry)->(Eof())
			cxFil    := (cAlQry)->ADK_XFILI 
			cxEmp    := (cAlQry)->ADK_XGEMP	
			cxNomeEmp:=AllTrim((cAlQry)->ADK_NOME)
			cEmail   :=(cAlQry)->ADK_EMAIL
		Else 
			lErro:=.T.	
			cErro:="Empresa e filial nao encontradas na tabela ADK no Protheus: ADK_XEMP = " + cxEmp + " / ADK_XFIL = " + cxFil
		EndIf

		(cAlQry)->(dbCloseArea())
			
	Else
	
		lErro:=.T.
		cErro:="Codigo da empresa ou da filial foram passados 'em branco'."
	
	EndIf

	aRet:={IIF(lErro,.F.,.T.),cxEmp,cxFil,cErro,cdEmpresa,cdFilial,cxNomeEmp,cEmpAnt,cFilAnt,cEmail}

Return(aRet)

/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! AnaliseGrp                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Valida os grupos que possuem produtos                                         !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
Method AnaliseGrp(oXml, nThrdID) class ProtheusGetProdutosAInventariar
Local nGrp		:= 0
Local oXmlGrp	:= oXml
Local aGrpNot	:= {}
Local aGrpOk	:= {}

	ConOut(AllTrim(Str(nThrdID))+": Validando produtos...")
	Do Case
		Case ValType(oXmlGrp) == "O"
			lOk := ::AnalisePrd(oXmlGrp:_BMGRUPO:TEXT,nThrdID)
			VerGrp(lOk,oXmlGrp:_BMGRUPO:TEXT,@aGrpOk,@aGrpNot)
		Case ValType(oXmlGrp) == "A"
			For nGrp := 1 to len(oXmlGrp)
				lOk := ::AnalisePrd(oXmlGrp[nGrp]:_BMGRUPO:TEXT,nThrdID)
				VerGrp(lOk,oXmlGrp[nGrp]:_BMGRUPO:TEXT,@aGrpOk,@aGrpNot)
			Next nGrp			
	EndCase

Return {aGrpOk,aGrpNot}


/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! AnalisePrd                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Implementação da classe AnalisePrd                                            !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
Method AnalisePrd(cGrp, nThrdID) class ProtheusGetProdutosAInventariar
Local lRet := .T.
Local cQuery	:= ""
Local cAlQry	:= ""
	
	cQuery := "	SELECT B1_COD " + CRLF
	cQuery += "	FROM " + RetSqlName("SB1") + " SB1 " + CRLF
	cQuery += "	WHERE " + CRLF
	cQuery += "	        B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "	    AND B1_GRUPO = '" + cGrp + "' " + CRLF
	cQuery += "	    AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	    AND ROWNUM = 1 " + CRLF	

	cQuery := ChangeQuery(cQuery)
	cAlQry := MPSysOpenQuery(cQuery)

	If (cAlQry)->(Eof())
		lRet := .F.					
	EndIf

	(cAlQry)->(dbCloseArea())
	
Return lRet


/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! VerInvAbe                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Verifica se possui inventário em aberto                                       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
Method VerInvAbe(nThrdID) class ProtheusGetProdutosAInventariar
Local lRet		:= .F.	
Local cQuery	:= ""
Local cAlQry	:= ""
Local cIdInv    := ""
Local cDtaInv   := ""
Local cFileInv  := ""
Local cUserInv  := ""

	cQuery := "	SELECT Z23_ID, Z23_DATA, Z23_ARQINV, Z23_USERI " + CRLF
	cQuery += " FROM  " + RetSqlName("Z23") + " Z23 " + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += "         Z23_FILIAL = '" + xFilial("Z23") + "' " + CRLF
	cQuery += "     AND Z23_DTINV != ' ' " + CRLF
	cQuery += "     AND Z23_DTCONF = ' ' " + CRLF
	cQuery += "     AND D_E_L_E_T_ = ' ' " + CRLF

	cQuery := ChangeQuery(cQuery)
	cAlQry := MPSysOpenQuery(cQuery)

	If !(cAlQry)->(Eof())
		lRet    :=.T.	
		cIdInv  :=(cAlQry)->Z23_ID		
		cDtaInv :=(cAlQry)->Z23_DATA	
		cFileInv:=AllTrim((cAlQry)->Z23_ARQINV)
		cUserInv:=(cAlQry)->Z23_USERI
	EndIf

	(cAlQry)->(dbCloseArea())
	
Return({lRet,cIdInv,cDtaInv,cFileInv,cUserInv})


/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! WSEST002                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função Princiapal do WS                                                       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
Static Function WSEST002(cXml,nThrdID)
Local lCont		:= .T.
Local cErro		:= ""
Local aEmp      := ""
Local cMsg		:= ""
Local aRetArq	:= ""
Local cArqCsv	:= ""
Local aRetGrp	:= {}
Local aGrpNot	:= {}
Local aGrpOk	:= {}
Local oWs		:= Nil
Local oXml		:= Nil
Local oXmlAce	:= Nil
Local oXmlId	:= Nil
Local oXmlGrp	:= Nil 
Local cxEmp		:= ""
Local cxFil		:= ""
Local cErroXML  := ""
Local aRetInv   := {}
Local aRetInc   := {}
Local cDtaInv   := ""
Local cUserInv  := ""
Local cDataInv  := ""
Local cIdUser   := ""
Local cUsrName  := ""
Local aGrpUser  := {}
Local cUserA    := RetCodUsr()
Local nModAnt   := nModulo

	If Empty(cXml)
		oWs	   :=ProtheusGetProdutosAInventariar():New("Tag")
		oXmlAce:=oWs:xmlParser(cXml)
		cErroXML:="XML enviado com os parametros e invalido ou vazio."
		lCont   :=.F.
	EndIf
	
	If lCont
	
		oWs		:= ProtheusGetProdutosAInventariar():New("Tag")
		oXmlAce	:= oWs:xmlParser(cXml)
		aEmp	:= oWs:AnaliseAce(oXmlAce:_INVENTARIO:_ID,nThrdID)
		oXml	:= oWs:xmlParser(cXml)
		oXmlId	:= oXml:_INVENTARIO:_ID
		oXmlGrp := oXml:_INVENTARIO:_GRUPOS:_GRUPO		
		cIdUser := oXmlId:_IDUSUARIO:TEXT

		// -> Se os dados da empresa estão ok, prossegue.
		lCont:=aEmp[1]
		If lCont
			ConOut(AllTrim(Str(nThrdID))+": Carregando ambiente para empresa " + aEmp[2] + " e filial " + aEmp[3])
			RpcClearEnv()
			RPcSetType(3)
			RpcSetEnv(aEmp[2],aEmp[3],,,'EST',GetEnvServer())				
			OpenSm0(aEmp[2], .f.)

				// -> Reposiciona na empresa / filial
				SM0->(dbSetOrder(1))
				lCont   := SM0->(dbSeek(aEmp[2] + aEmp[3]))
				cEmpAnt := SM0->M0_CODIGO
				cFilAnt := SM0->M0_CODFIL
			    nModulo := 4	
				// -> Se nao ocorreu erro, continua o processo
				If lCont		
					// -> Posiciona no acesso do usuário
					PswOrder(1)
					lCont:=PswSeek(cIdUser,.T.) 
					cUsrName :=UsrRetName(cIdUser)
					__cUserID:=cUsrName
					aGrpUser :=UsrRetGrp(cUsrName)
					// -> Se o usuário estiver ok, continua
					If lCont						
						// -> Verifica data do inventario
						If !Empty(Stod(oXmlId:_DATAINVENTARIO:TEXT))
							aRetGrp  := oWs:AnaliseGrp(oXmlGrp,nThrdID)
							aGrpOk	 := aRetGrp[01]
							aGrpNot  := aRetGrp[02]
							dDataBase:= Stod(oXmlId:_DATAINVENTARIO:TEXT)
							// -> Verifica se há iventários em aberto 
							ConOut(AllTrim(Str(nThrdID))+": Validando inventario...")
							If Len(aGrpOk) > 0				
								aRetInv:=oWs:VerInvAbe()
								If aRetInv[1]
									cErro := "Inventario com ID " + aRetInv[2] + " pendente para a filial: " + aEmp[3] + " - " + aEmp[7]
									lCont := .F.				
								Else
									aRetInv:={}
								EndIf				
							Else
								cErro := "Nao existem produtos a inventariar para os grupos solicitados."
								lCont := .F.
							EndIf
							// -> Se não ocorreu erro,continua o processo
							aRetInc:={}
							If lCont									
								Begin Transaction
									ConOut(AllTrim(Str(nThrdID))+": Incluindo iventario...")
									aRetInc:=U_EST550I("WSEST002", xFilial("Z23"), cUsrName, dDataBase, aGrpOk, 3)
									cErro   :=aRetInc[1]
									cIdInv  :=aRetInc[2]
									cUserInv:=aRetInc[3]
									cDataInv:=DtoC(aRetInc[4])								
									// -> Se não reornou erro na inclusao, continua.
									If Empty(cErro)
										ConOut(AllTrim(Str(nThrdID))+": Gerando arquivo de contagem...")
										aRetArq:=U_EST550G("WSEST002", Z23->Z23_GRUPOS, Z23->Z23_FILIAL, Z23->Z23_ID, aEmp[05], aEmp[06], aEmp[10],Z23->Z23_DATA)
										cErro  :=aRetArq[01]
										cArqCsv:=aRetArq[02]
									
										// -> Se ocorreu erro na geração do arquivo, desarma a transação
										If !Empty(cErro)
											lCont:=.F.	
											DisarmTransaction()	
										EndIf
									Else	
										cErro+=Chr(13)+Chr(10)+"Erro na geracao dos itens a inventariar em " + DtoC(dDataBase)
										lCont:=.F.	
										DisarmTransaction()	
									EndIf
								End Transaction
							EndIf
							// -> Se não ocorreu erro, retorna os dados em formato XML
							If lCont		
								ConOut(AllTrim(Str(nThrdID))+": Retornando dados...")
								cXml := oWs:MakeXml(IIF(Len(aRetInc)>0,cUserInv,cIdUser),IIF(Len(aRetInc)>0,cDataInv,DtoS(dDataBase)),lCont ,cErro,IIF(Len(aRetInv)>0,aRetInv[4],cArqCsv),aEmp[5]  ,aEmp[6] ,aEmp[3],IIF(Len(aRetInv)>0,aRetInv[2],cIdInv),nThrdID)							
							EndIf						
						Else
							cErro := "Data do inventario invalida. [_DATAINVENTARIO=Vazio]"
							lCont := .F.		
						EndIf				
					Else
						cErro := "Usuario passado para execucao do inventario e invalido. [IDUSUARIO="+cIdUser+"]"
						lCont	:= .F.		
					EndIf	
				Else
					cErro :="Erro ao carregar as filiais na tabela SM0 do Protheus [M0_CODIGO = " + aEmp[2] + " e M0_CODFIL = " + aEmp[3] + "]"
					lCont:=.F.		
				EndIf	

			// -> Retorna o ambiente anterior
			RpcClearEnv()
			RPcSetType(3)
			RpcSetEnv(aEmp[8],aEmp[9],,,'EST',GetEnvServer())				
			OpenSm0(aEmp[2], .f.)
			SM0->(dbSetOrder(1))
			SM0->(dbSeek(aEmp[8] + aEmp[9]))
			cEmpAnt := SM0->M0_CODIGO
			cFilAnt := SM0->M0_CODFIL
			PswOrder(1)
			PswSeek(cUserA,.T.) 
			nModulo  := nModAnt
			cUsrName :=UsrRetName(cUserA)
			__cUserID:=cUsrName
			aGrpUser := UsrRetGrp(cUsrName)

		Else
			cErro :="Empresa e filial nao encontradas da tabela ADK do Protheus."
			lCont:=.F.		
		EndIf
	Else
		cErro :=aEmp[4]
		lCont:=.F.		
	EndIf

	// -> Se houve erro no processamento, retorna os erros
	If !lCont
		cXml:=oWs:MakeXml(IIF(Empty(cErroXML),IIF(Len(aRetInv)>0,aRetInv[5],oXmlId:_IDUSUARIO:TEXT),""),IIF(Empty(cErroXML),IIF(Len(aRetInv)>0,aRetInv[3],oXmlId:_DATAINVENTARIO:TEXT),""),lCont,cErro+cErroXML,IIF(Len(aRetInv)>0,aRetInv[4],""),IIF(Empty(cErroXML),aEmp[5],""),IIF(Empty(cErroXML),aEmp[6],""),IIF(Empty(cErroXML),aEmp[3],""),IIF(Len(aRetInv)>0,aRetInv[2],""),nThrdID)			
		ConOut(AllTrim(Str(nThrdID))+": Erro.")
	Else
		ConOut(AllTrim(Str(nThrdID))+": Ok.")
	EndIf

Return cXml




/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! VerGrp                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Gerar os arrayys de retorno                                                   !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
Static Function VerGrp(lOk,cGrp,aGrpOk,aGrpNot)
	If lOk
		aAdd(aGrpOk,cGrp)
	Else
		aAdd(aGrpNot,cGrp)
	EndIf
Return