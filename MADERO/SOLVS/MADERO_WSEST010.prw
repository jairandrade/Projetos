#INCLUDE 'protheus.ch'
#INCLUDE "restful.ch"
/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GetProdutosARequisitar                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! WS para gerar a lista de produtos a requisitar do usuário                     !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Paulo Gabriel França e Silva                                                  !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 15/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
WSRESTFUL GetProdutosARequisitar DESCRIPTION "Madero - Produtos a Requisitar"

	WSDATA cdempresa AS STRING
	WSDATA cdfilial AS STRING
	WSDATA idusuario AS STRING
	WSDATA codtipmov AS STRING

	WSMETHOD GET DESCRIPTION "Produtos a Requisitar" WSSYNTAX "/GetProdutosARequisitar"

End WSRESTFUL


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GetProdutosARequisitar                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Implementação do método GET do WS para gerar a lista de produtos a requisitar !
!                  ! por usuário                                                                   !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Paulo Gabriel França e Silva                                                  !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 15/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
WSMETHOD GET WSRECEIVE cdempresa, cdfilial, idusuario, codtipmov  WSSERVICE GetProdutosARequisitar
Local cCodEmpTek:= Self:cdempresa
Local cCodFilTek:= Self:cdfilial
Local cTpMov 	:= AllTrim(Self:codtipmov)
Local cIdUser   := Self:idusuario
Local cXml		:= ""
Local nThrdID   := ThreadId()
Local cEmpProth := "01"
Local cFilProth := "01GDAD0001"

	ConOut(AllTrim(Str(nThrdID))+": Requisitando metodo GetProdutosARequisitar em " + DtoC(Date()) + " as " + Time())
	::SetContentType("application/xml")

	ConOut(AllTrim(Str(nThrdID))+": GetProdutosARequisitar: Carregando dicionario de dados...")
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
		ConOut(AllTrim(Str(nThrdID))+": GetProdutosARequisitar: Erro ao abrir o dicionário de dados.")
		Return(.F.)
	EndIf

    cXml := WSEST010(cCodEmpTek, cCodFilTek, cIdUser, cTpMov, nThrdID)

	::SetResponse(cXML)

Return .T.



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ProtheusGetProdutosARequisitar                                                !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Implementação dda classe para o WS para gerar a lista de produtos a requisitar!
!                  ! por usuário                                                                   !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Paulo Gabriel França e Silva                                                  !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 15/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                

Class ProtheusGetProdutosARequisitar From ProtheusMethodAbstract

	Method new(cMethod) constructor
	Method makeXml(cAlQry,cErro,lOk,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,cUsrName,aGrpUser,cIdMvto,nThrdID)

EndClass



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ProtheusGetProdutosARequisitar                                                !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Construtor da classe do WS para gerar a lista de produtos a requisitar        !
!                  ! por usuário                                                                   !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Paulo Gabriel França e Silva                                                  !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 15/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Method New(cMethod) Class ProtheusGetProdutosARequisitar
	::cMethod := cMethod
Return




/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! makeXml                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Implementação do método makeXml da classe do WS para gerar a lista de produtos!
!                  !  a requisitar por usuário                                                     !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Paulo Gabriel França e Silva                                                  !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 15/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                

Method makeXml(cAlQry,cErroRet,lOk,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,cUsrName,cIdMvto,aGrpUser,nThrdID) Class ProtheusGetProdutosARequisitar
Local cXml 			:= ""
Local nPos			:= 0
Local cRot 		    := "MTA240 "
Local cxProd 	    := "" 
Local cxGrupoP	    := "" 
Local cCodProd		:= ""
Local cDescProd 	:= ""
Local cCodGrpProd	:= ""
Local cDescGrpProd	:= ""
Local cUMProd		:= ""
Local cUMCompProd	:= ""
Local cTipConv		:= ""
Local cFatConv		:= ""
Local cCodPrF		:= ""

//#TB20200305 Thiago Berna - Ajuste para retornar o campo A5_XCODARV
//Local cCodBar		:= ""
Local cCodArv		:= ""

Local cTpMov		:= ""
Local cDescTipMov	:= ""
Local cQtdEst		:= ""
Local lAcesso       := .F.
Local lErro         := .F.
Local cErro         := ""
Local lSA5          := .F.
Local nTamFator     := TamSX3("A5_XCVUNF")[1]
Local nDecFator     := TamSX3("A5_XCVUNF")[2]
Local nTamQtde      := TamSX3("B2_QATU")[1]
Local nDecQtde      := TamSX3("B2_QATU")[2]
Private aHeader     := {{,"C1_PRODUTO"       }} 
Private aCols       := {{cxProd              }}
Private n    	    := 1


	cXml := '<?xml version="1.0" encoding="ISO-8859-1"?>'
	cXml += '<retorno>'
	cXml += '<id ' 
	cXml += 'cdempresa="'     + cCodEmpTek + '" '	
	cXml += 'cdfilial="'      + cCodFilTek + '" '
	cXml += 'filial="'	      + cFilWS     + '" '		
	cXml += 'idusuario="'     + cIdUser    + '" '		
	cXml += 'codtipmov="'     + cIdMvto    + '" '
	cXml += '/>'

	cXml += '<produtos>'

	If lOk
	
		// -> Abre os arquivos
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
	
		DbSelectArea("SBM")
		SBM->(DbSetOrder(1))
		
		DbSelectArea("SF5")
		SF5->(DbSetOrder(1))	
		
		DbSelectArea("SB2")
		SB2->(DbSetOrder(1))

		DbSelectArea("SA5")
		SA5->(DbSetOrder(2))

		
		// -> Gera produtos dados de produtos
		While !(cAlQry)->(Eof()) 
			
			SB1->(DbSeek(xFilial("SB1")+(cAlQry)->B1_COD))
			
			cxProd 			:= SB1->B1_COD
			cxGrupoP		:= SB1->B1_GRUPO
			cCodProd		:= SB1->B1_XCODEXT
			cDescProd 		:= SB1->B1_DESC
			cCodGrpProd		:= SB1->B1_GRUPO
			cDescGrpProd	:= ""
			cUMProd			:= SB1->B1_UM
			cUMCompProd		:= ""
			cTipConv		:= ""
			cFatConv		:= ""
			cCodPrF			:= ""
			cCodBar			:= ""
			
			//#TB20200305 Thiago Berna - Ajuste para retornar o campo A5_XCODARV
			cCodArv			:= ""
			
			cTpMov			:= ""
			cDescTipMov		:= ""
			cQtdEst			:= ""
			cTagFatConv     := ""
			
			ConOut(StrZero(nThrdID,10)+": "+AllTrim(cxProd)+"-"+AllTrim(cDescProd))
			// -> Valida se o usuário possui permissão para movimentar o produto
			lAcesso:=u_EST200RL(cRot,cxProd,cxGrupoP,cIdUser,aGrpUser,cIdMvto,.F.)
			If lAcesso
				// -> Posiciona no grupo do prouto
				If SBM->(DbSeek(xFilial("SBM")+SB1->B1_GRUPO))
					cDescGrpProd := SBM->BM_DESC
				Else
					ConOut(" Erro: Grupo "+cCodGrpProd+" nao cadastrado na tabela SBM.")
					cErro+="Grupo "+cCodGrpProd+" nao cadastrado na tabela SBM."+Chr(13)+Chr(10)
					lErro:=.T.
				EndIf
										
				// -> Pesquisa na amarração de produtos x fornecedoes
				lSA5 := .F.
				SA5->(DbSeek(xFilial("SA5")+cxProd))
				While !SA5->(Eof()) .and. SA5->A5_FILIAL == xFilial("SA5") .and. SA5->A5_PRODUTO == cxProd
				
					cUMCompProd	:=	SA5->A5_UNID
					cTipConv	:=	SA5->A5_XTPCUNF
					cFatConv	:=	AllTrim(Str(SA5->A5_XCVUNF,nTamFator,nDecFator))
					cCodPrF		:=	SA5->A5_CODPRF
					
					//#TB20200305 Thiago Berna - Ajuste para retornar o campo A5_XCODARV
					//cCodBar		:= 	SA5->A5_CODBAR
					cCodArv		:= 	SA5->A5_XCODARV
					lSA5        := .T.
					
					// -> Gera tag dos fatires de coversao
					cTagFatConv += '<unidade'
					cTagFatConv += ::tag('uncompra',cUMCompProd)	
					cTagFatConv += ::tag('dsfatorconv',cTipConv)	
					cTagFatConv += ::tag('fatorconv',cFatConv)	
					cTagFatConv += ::tag('cdcodfornec',cCodPrF)	
					
					//#TB20200305 Thiago Berna - Ajuste para alterar o nome de cdcodbar para cdcodarv
					//cTagFatConv += ::tag('cdcodbar',cCodBar)	
					cTagFatConv += ::tag('cdcodarv',cCodArv)	
					
					cTagFatConv += '/>

					SA5->(DbSkip())
				
				EndDo	
				
				// -> Se não encontro no cadastro de produtos x fornecedores, considera os dados de unidade e conversão do default 
				If !lSA5
					cUMCompProd	:= 	SB1->B1_UM
					cTipConv	:=	"M"
					cFatConv	:=AllTrim(Str(1,nTamFator,nDecFator))
					cCodPrF		:=	""
					
					//#TB20200305 Thiago Berna - Ajuste para retornar o campo A5_XCODARV 
					//cCodBar		:=	SB1->B1_CODBAR	
					cCodArv		:= ""			

					// -> Gera tag dos fatires de coversao
					cTagFatConv += '<unidade'
					cTagFatConv += ::tag('uncompra',cUMCompProd)	
					cTagFatConv += ::tag('dsfatorconv',cTipConv)	
					cTagFatConv += ::tag('fatorconv',cFatConv)	
					cTagFatConv += ::tag('cdcodfornec',cCodPrF)	
					
					//#TB20200305 Thiago Berna - Ajuste para alterar o nome de cdcodbar para cdcodarv
					//cTagFatConv += ::tag('cdcodbar',cCodBar)	
					cTagFatConv += ::tag('cdcodarv',cCodArv)

					cTagFatConv += '/>

				Endif

				If SF5->(DbSeek(xFilial("SF5")+cIdMvto))
					cTpMov		:=	SF5->F5_CODIGO
					cDescTipMov	:=	SF5->F5_TEXTO				
				Else
					ConOut(" Erro: Tipo de movimento "+AllTrim(cIdMvto)+" nao cadastrado na tabela SF5.")	
					cErro+="Tipo de movimento "+AllTrim(cIdMvto)+" nao cadastrado na tabela SF5."+Chr(13)+Chr(10)
					lErro:=.T.
				EndIF
					
				If SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD))
					cQtdEst := AllTrim(Str(SaldoSB2(),nTamQtde,nDecQtde))
				Else
					cQtdEst := AllTrim(Str(0,nTamQtde,nDecQtde))
				EndIf

				cXml += '<produto'
				cXml += ::tag('cdproduto'	,AllTrim(cCodProd))		
				cXml += ::tag('codproduto'  ,AllTrim(cxProd))		
				cXml += ::tag('dsproduto'	,AllTrim(cDescProd))	
				cXml += ::tag('cdgrupo'		,cCodGrpProd)	
				cXml += ::tag('dsgrupo'		,cDescGrpProd)	
				cXml += ::tag('unproduto'	,cUMProd)	
				cXml += ::tag('cdcodmov'	,cIdMvto)	
				cXml += ::tag('dscodmov'	,cDescTipMov)	 
				cXml += ::tag('qtdeestoque'	,cQtdEst)		
				cXml += '>'

				cXml += '<unidades>'
				
				cXML += cTagFatConv

				cXml += '</unidades>'

				cXml += '</produto>'	

			EndIf
			
			(cAlQry)->(dbSkip())
			
		EndDo
	
	EndIf

	cXml += '</produtos>'	
	
	cXml += '<confirmacao>'
	
	cXml += '<confirmacao'
	cXml += ::tag('integrado'		,IIF(lOk .and. !lErro,"true","false"))			
	cXml += ::tag('mensagem'		,IIF(lOk .and. !lErro,"Consulta finalizada com sucesso.","Ocorreram erros na consulta:"+Chr(13)+Chr(10)+cErroRet+Chr(13)+Chr(10)+cErro)) 
	cXml += ::tag('data'			,DtoS(Date()))		
	cXml += ::tag('hora'			,Time())	
	cXml += '/>'
	
	cXml += '</confirmacao>'

	cXml += '</retorno>'	

Return cXml

/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! WSEST010                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para pesquisar os produtos por tipo de movimentação para o usuário     !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Paulo Gabriel França e Silva                                                  !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 15/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function WSEST010(cCodEmpTek, cCodFilTek, cIdUser, cTpMov, nThrdID)
Local cErro	  := ""
Local cXml	  := ""
Local lCont	  := .T.
Local cQuery  := ""
Local aProd   := {}
Local cEmpWS  := ""
Local cFilWS  := ""
Local cxEmpant:= ""
Local cxFilAnt:= ""
Local cUsrName:= ""
Local oWs	  := ProtheusGetProdutosARequisitar():New("Tag")
Local cUserA  := RetCodUsr()
Local cAlQry  := ""
	
	ConOut(AllTrim(Str(nThrdID))+": Validando dados da empresa...")

	// -> Verifica se foram passados os parâmetros de empresa, filial, usuario e movimento
	lCont:=!(cCodEmpTek == Nil .or. cCodFilTek == Nil .or. cIdUser == Nil .or. cTpMov == Nil)
	If lCont
		lCont := VerEmp(cCodEmpTek,cCodFilTek,@cEmpWS,@cFilWS,@cxEmpant,@cxFilAnt)
		If lCont
	
			// -> Carrega o ambiente conforme dados da empresa e filial passados nos parâmetros do método
			ConOut(AllTrim(Str(nThrdID))+": Carregando ambiente para empresa " + cEmpWS + " e filial "+cFilWS)
			RpcClearEnv()
			RPcSetType(3)
			RpcSetEnv(cEmpWS,cFilWS, , ,'EST' , GetEnvServer() )
			OpenSm0(cEmpWS, .f.)
				nModulo := 4
				SM0->(dbSetOrder(1))
				If !SM0->(dbSeek(cEmpWS+cFilWS))
					lCont:=.F.
				EndIf				
			
				// -> Se o ambiente está ok, continua
				If lCont

					// -> Posiciona no acesso do usuário
					PswOrder(1)
					PswSeek(cIdUser,.T.) 
					cUsrName :=UsrRetName(cIdUser)
					__cUserID:=cUsrName
					aGrpUser := UsrRetGrp(cUsrName)
					cEmpAnt  := SM0->M0_CODIGO
					cFilAnt  := SM0->M0_CODFIL							
				
					// -> Verifica se é Admin
					lCont:=!("ADMIN" $ Upper(cUsrName))
					If lCont
						// -> Se o usuário ok, continua
						lCont:=!Empty(cUsrName)
						If lCont								
							ConOut(AllTrim(Str(nThrdID))+": Pesquisando produtos...")
							cQuery := "SELECT B1_COD FROM "+RetSqlName("SB1")+" SB1												" + CRLF
							// cQuery += "WHERE B1_GRUPO IN(SELECT Z30_GRPPRO FROM "+RetSqlName("Z30")+" WHERE Z30_ID ='"+cTpMov+"')" + CRLF
							cQuery += "WHERE B1_GRUPO IN(                                                                       " + CRLF
							cQuery += "   SELECT Z30_GRPPRO FROM " + RetSqlName("Z30")                                            + CRLF
							cQuery += "   WHERE D_E_L_E_T_ = ' '                                                                " + CRLF
							cQuery += "     AND Z30_FILIAL = " + ValToSql(xFilial("Z30"))                                         + CRLF
							cQuery += "     AND Z30_ID = " + ValToSql(cTpMov)                                                     + CRLF
							cQuery += "     AND Z30_GRPPRO <> ' ')                                                              " + CRLF
							cQuery += "	AND SB1.B1_FILIAL = '"+xFilial("SB1")+"'												" + CRLF
							cQuery += "	AND SB1.B1_MSBLQL  <> '1'                  												" + CRLF
							cQuery += "	AND SB1.D_E_L_E_T_ <> '*'																" + CRLF
							cQuery += "UNION ALL																				" + CRLF
							cQuery += "SELECT B1_COD FROM "+RetSqlName("SB1")+" SB1												" + CRLF
							// cQuery += "WHERE B1_COD IN(SELECT Z30_PROD FROM "+RetSqlName("Z30")+" WHERE Z30_ID ='"+cTpMov+"')	" + CRLF
							cQuery += "WHERE B1_COD IN(                                                                         " + CRLF
							cQuery += "   SELECT Z30_PROD FROM " + RetSqlName("Z30")                                              + CRLF
							cQuery += "   WHERE D_E_L_E_T_ = ' '                                                                " + CRLF
							cQuery += "     AND Z30_FILIAL = " + ValToSql(xFilial("Z30"))                                         + CRLF
							cQuery += "     AND Z30_ID = " + ValToSql(cTpMov)                                                     + CRLF
							cQuery += "     AND Z30_PROD <> ' ')                                                                " + CRLF
							cQuery += "	AND SB1.B1_FILIAL = '"+xFilial("SB1")+"'												" + CRLF
							cQuery += "	AND SB1.B1_MSBLQL  <> '1'                  												" + CRLF
							cQuery += "	AND SB1.D_E_L_E_T_ <> '*'																" + CRLF
							cQuery := ChangeQuery(cQuery)
							cAlQry := MPSysOpenQuery(cQuery)
							If (cAlQry)->(Eof())
								lCont := .F.
								cErro := "Nao ha produtos para requisitar."
							Else
								cXml:=oWs:makeXml(cAlQry,cErro,lCont,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,cUsrName,cTpMov,aGrpUser,nThrdID)					                  
							Endif
							(cAlQry)->(DbCloseArea())
						Else
							cErro :="Usuario " + cIdUser + " nao encontrado no Protheus."
							lCont:=.F.		
						EndIf	
					Else
						cErro :="Nao eh permitido utilizar o acesso do usuario Admin."
						lCont:=.F.		
					EndIf	
				Else
					cErro :="Erro ao carregar as filiais na tabela SM0 do Protheus [M0_CODIGO = " + cEmpWS + " e M0_CODFIL = " + cFilWS + "]"
					lCont:=.F.		
				EndIF	

			// -> Restaura o ambiente original
			RpcClearEnv()
			RPcSetType(3)
			RpcSetEnv(cxEmpant,cxFilAnt, , ,'EST' , GetEnvServer() )
			OpenSm0(cxEmpant, .f.)
			nModulo := 4
			SM0->(dbSetOrder(1))
			SM0->(dbSeek(cxEmpant+cxFilAnt))
			PswOrder(1)
			PswSeek(cUserA,.T.) 
			cUsrName :=UsrRetName(cIdUser)
			__cUserID:=cUsrName
			aGrpUser := UsrRetGrp(cUsrName)
			cEmpAnt  := SM0->M0_CODIGO
			cFilAnt  := SM0->M0_CODFIL		
		Else	
			cErro :="Empresa e filial nao encontradas da tabela ADK do Protheus."
			lCont:=.F.		
		EndIf
	Else
		cErro :="Informe os parametros [cdempresa], [cdfilial], [codtipmov] e [idusuario] para o metodo."
		cCodEmpTek:=IIF(cCodEmpTek==Nil,"Nao informado",cCodEmpTek)
		cCodFilTek:=IIF(cCodFilTek==Nil,"Nao informado",cCodFilTek)
		cTpMov    :=IIF(cTpMov    ==Nil,"Nao informado",cTpMov)
		cIdUser   :=IIF(cIdUser   ==Nil,"Nao informado",cIdUser)
		lCont:=.F.		
	EndIf	

	If !lCont
		cXml:=oWs:makeXml(cAlQry,cErro,lCont,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,"",cTpMov,{},nThrdID)
		ConOut("Erro.")
	Else
		ConOut("Ok.")	
	EndIf	

Return cXml



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! VerEmp                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Verifica os dados da filial de conexão                                        !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Paulo Gabriel França e Silva                                                  !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 15/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function VerEmp(xEmp,xFil,cEmpWS,cFilWS,cxEmpant,cxFilAnt)
Local lRet:=.F.
	
	// -> Pesquisa filiais
	cQuery := "	SELECT ADK_XFILI,ADK_XGEMP      " + CRLF
	cQuery += "	FROM  " + RetSqlName("ADK")       + CRLF
	cQuery += "	WHERE "                           + CRLF  
	cQuery += " ADK_XEMP   = '" + xEmp + "' AND " + CRLF
	cQuery += " ADK_XFIL   = '" + xFil + "' AND " + CRLF
	cQuery += "	D_E_L_E_T_ = ' '                " + CRLF	
	cQuery := ChangeQuery(cQuery)
	cAlQry := MPSysOpenQuery(cQuery)
		
	If !(cAlQry)->(Eof())
		cFilWS:=(cAlQry)->ADK_XFILI 
		cEmpWS:=(cAlQry)->ADK_XGEMP
		lRet:=.T.
	EndIf
	(cAlQry)->(dbCloseArea())
	cxEmpant:=cEmpAnt
	cxFilAnt:=cFilAnt

Return lRet


