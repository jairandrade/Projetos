#INCLUDE 'protheus.ch'
#INCLUDE "restful.ch"
/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GetProdutosAConferir                                                          !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração do WebService GetProdutosAConferir                                 !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
WSRESTFUL GetProdutosAConferir DESCRIPTION "Madero - Produtos a Conferir"
	
	WSDATA cdempresa AS STRING
	WSDATA cdfilial AS STRING
	WSDATA cdusuario AS STRING
	WSDATA chavenfe AS STRING

	WSMETHOD GET DESCRIPTION "Acesso de Usuários" WSSYNTAX "/GetProdutosAConferir"

End WSRESTFUL


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GET                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaracao do metodo GET                                                      !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
WSMETHOD GET WSRECEIVE cdempresa, cdfilial, cdusuario, chavenfe  WSSERVICE GetProdutosAConferir
Local cXml	  := ""
Local nThrdID := ThreadId()
Local cEmpProth := "01"
Local cFilProth := "01GDAD0001"

	ConOut("=================================================================================================")	
	ConOut(AllTrim(Str(nThrdID))+": Requisitando metodo GetProdutosAConferir em " + DtoC(Date()) + " as " + Time())
	::SetContentType("application/xml")

	ConOut(AllTrim(Str(nThrdID))+": GetProdutosAConferir: Carregando dicionario de dados...")
	RpcClearEnv()
	RPcSetType(3)
	RpcSetEnv(cEmpProth,cFilProth,,,"FAT",GetEnvServer())
	OpenSm0(cEmpProth, .f.)
	nModulo:=5
	SM0->(dbSetOrder(1))
	If SM0->(dbSeek(cEmpProth+cFilProth))
		cEmpAnt  := cEmpProth
		cFilAnt  := cFilProth						
		dDataBase:=Date()
	Else
		ConOut(AllTrim(Str(nThrdID))+": GetProdutosAConferir: Erro ao abrir o dicionário de dados.")
		Return(.F.)
	EndIf
	
	cXml := U_WSEST020(Self:cdempresa, Self:cdfilial, Self:cdusuario, Self:chavenfe, nThrdID)

	::SetResponse(cXML)

Return .T.



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ProtheusGetProdutosAConferir                                                  !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração das classe para gerar o XML                                        !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Class ProtheusGetProdutosAConferir From ProtheusMethodAbstract

	Method new(cMethod)  constructor
	Method makeXml(cAliasQry,lOk,cErro,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,cSerie,cDocum,dEmis,cCGC,cNomeForn,cUserName)

EndClass



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! New                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração do método new                                                      !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Method New(cMethod) Class ProtheusGetProdutosAConferir
	::cMethod := cMethod
Return


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! makeXml                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Monta o XML com os dados do documento fiscal                                  !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 17/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Method makeXml(cAliasQry,lOk,cErro,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,cSerie,cDocum,dEmis,cCGC,cNomeForn) Class ProtheusGetProdutosAConferir
Local cXml 		:= ""
Local cA5UNID   := ""
Local cA5XTPCUNF:= ""
Local cA5XCVUNF := ""
Local cA5CODPRF := ""
Local cA5CODBAR := ""
Local cA5Prod   := "" 

//#TB20200305 Thiago Berna - Ajuste para retornar o campo A5_XCODARV
Local cA5CODARV	:= ""

	DbSelectArea("SA5")
	
	cXml += '<?xml version="1.0" encoding="ISO-8859-1"?>'

	cXml += '<retorno>'

	cXml += '<id '
	cXml += ::tag('cdempresa'	, cCodEmpTek)
	cXml += ::tag('cdfilial'	, cCodFilTek)
	cXml += ::tag('filial'	    , cFilWS)
	cXml += ::tag('numeronf'	, cDocum)
	cXml += ::tag('serienf'		, cSerie)
	cXml += ::tag('emissaonf'	, DToS(dEmis))
	cXml += ::tag('cnpj'		, cCGC)
	cXml += ::tag('nomfornec'	, cNomeForn)
	cXml += ::tag('idusuario'	, cIdUser)
	cXml += ::tag('usrlogin'	, cUserName )
	cXml += '/>'		
	
	cXml += '<produtos>'

	// -> Se não encontrou erros  
	If lOk
		(cAliasQry)->(DbGotop())
		While !(cAliasQry)->(Eof())
			// -> Posiciona na tabela SA5
			cA5UNID   := ""
			cA5XTPCUNF:= ""
			cA5XCVUNF := 0
			cA5CODPRF := ""
			cA5CODBAR := ""
			
			//#TB20200305 Thiago Berna - Ajuste para retornar o campo A5_XCODARV
			cA5CODARV := ""

			SA5->(DbOrderNickName("A5CODPRF"))
			SA5->(DbSeek(xFilial("SF1")+(cAliasQry)->D1_FORNECE+(cAliasQry)->D1_LOJA+(cAliasQry)->D1_COD))
			While !SA5->(Eof())
				If SA5->A5_XATIVO == "S"
					cA5UNID   := SA5->A5_UNID
					cA5XTPCUNF:= SA5->A5_XTPCUNF
					cA5XCVUNF := SA5->A5_XCVUNF
					cA5CODPRF := SA5->A5_CODPRF
					
					//#TB20200305 Thiago Berna - Ajuste para retornar o campo A5_XCODARV
					//cA5CODBAR := SA5->A5_CODBAR
					cA5CODARV := SA5->A5_XCODARV
					
					Exit
				EndIf	
				SA5->(DbSkip())
			EndDo

			cA5UNID   := IIF(Empty(cA5UNID)   ,(cAliasQry)->B1_UM    ,cA5UNID)
			cA5XTPCUNF:= IIF(Empty(cA5XTPCUNF),"M"                   ,cA5XTPCUNF)
			cA5XCVUNF := IIF(cA5XCVUNF<=0     ,1                     ,cA5XCVUNF)
			
			//#TB20200305 Thiago Berna - Ajuste para retornar o campo A5_XCODARV
			//cA5CODBAR := IIF(Empty(cA5CODBAR) ,(cAliasQry)->B1_CODBAR,cA5CODBAR)

			cXml += '<produto'			
			cXml += ::tag('cditem'		,(cAliasQry)->D1_ITEM)
			cXml += ::tag('cdproduto'	,(cAliasQry)->B1_XCODEXT)
			cXml += ::tag('dsproduto'	,(cAliasQry)->B1_DESC)
			cXml += ::tag('cdgrupo'		,(cAliasQry)->B1_GRUPO)
			cXml += ::tag('dsgrupo'		,(cAliasQry)->BM_DESC)
			cXml += ::tag('unprodtupo'	,(cAliasQry)->B1_UM)
			cXml += ::tag('quantidade'	,cValToChar((cAliasQry)->D1_QUANT))
			//cXml += ::tag('vrunitario'	,cValToChar((cAliasQry)->D1_VUNIT))
			//cXml += ::tag('vrtotal'		,cValToChar((cAliasQry)->D1_TOTAL))
			cXml += ::tag('uncompra'	,cA5UNID)
			cXml += ::tag('dsfatorconv'	,cA5XTPCUNF)
			cXml += ::tag('fatorconv'	,cValToChar(cA5XCVUNF))
			cXml += ::tag('cdcodfornec'	,cA5CODPRF)
			
			//#TB20200305 Thiago Berna - Ajuste para alterar o nome de cdcodbar para cdcodarv
			//cXml += ::tag('cdcodbar'	,cA5CODBAR)
			cXml += ::tag('cdcodarv'	,cA5CODARV)

			cXml += ::tag('cdProdPr'    ,cA5Prod )
			cXml += '/>'

			(cAliasQry)->(dBSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
	
	cXml += '</produtos>'	
	
	cXml += '<confirmacao>'
	
	cXml += '<confirmacao'
	cXml += ::tag('integrado'		,IIF(lOk,"true","False"))
	cXml += ::tag('mensagem'		,IIF(lOk,"Consulta Ok.",cErro))
	cXml += ::tag('data'			,DtoS(Date()))		
	cXml += ::tag('hora'			,Time())	
	cXml += '/>'
	
	cXml += '</confirmacao>'
	
	cXml += '</retorno>'

Return cXml



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! WSEST020                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função principal de processamento                                             !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function WSEST020(cCodEmpTek, cCodFilTek, cIdUser, ChaveNFe, nThrdID)
Local cXml		:= ""
Local cErro		:= ""
Local oTag		:= ProtheusGetProdutosAConferir():New( "Tag" )
Local cEmpWS    := ""
Local cFilWS    := ""
Local cUsrName  := ""
Local aGrpUser  := ""
Local cUserA    := RetCodUsr()
Local cCNPJ 	:= ""
Local cSerNFe   := ""
Local cCodNfe   := ""
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local cxFilAnt  := cFilAnt
Local cxEmpant  := cEmpAnt
Local dxDatAnt  := dDataBase
Local nModAnt   := nModulo

	lCont:=VerEmp(cCodEmpTek,cCodFilTek,@cEmpWS,@cFilWS,@cxEmpant,@cxFilAnt)
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
				aGrpUser :=UsrRetGrp(cUsrName)
				cEmpAnt  :=SM0->M0_CODIGO
				cFilAnt  :=SM0->M0_CODFIL	
				dDataBase:=Date()

				// -> Verifica se é Admin
				lCont:=!("ADMIN" $ Upper(cUsrName))
				If lCont
					// -> Se o usuário ok, continua
					lCont:=!Empty(cUsrName)
					If lCont												
						// -> Seleciona dados do documento fiscal
						ConOut(AllTrim(Str(nThrdID))+": Carregando dados...")
						cCNPJ 	:= SubStr(ChaveNFe,07,14)
						cSerNFe := SubStr(ChaveNFe,23,03)
						cCodNfe := SubStr(ChaveNFe,26,09)
				
						// -> Verifica se as informações de cnpj, serie e numero da nfe estão preenchidos
						lCont:=!(Empty(cCNPJ) .or. Empty(cSerNFe) .or. Empty(cCodNfe))
						
						// -> Se os dados da chave estão ok, prosegue
						If lCont	
							DbSelectArea("SA2")
							SA2->(DbSetOrder(3))
							SA2->(DbSeek(xFilial("SA2")+cCNPJ))
							lCont:=!SA2->(Eof())
							
							// -> Se o fornecedor estiver ok, continua
							If lCont
								DbSelectArea("SF1")
								SF1->(DbSetOrder(1))
								SF1->(DbSeek(xFilial("SF1")+cCodNfe+cSerNFe+SA2->A2_COD+SA2->A2_LOJA))
								lCont:=!SF1->(Eof())

								// -> Se o documento de entrada estiver ok, continua
								If lCont

									// -> Se a nota nao estiver bloqueada, prossegue.
									lCont:=!(SF1->F1_STATUS=="B")
									If lCont

										// -> Se a nota nao estiver classificada, prossegue.
										lCont:=Empty(SF1->F1_STATUS)
										If lCont

											// -> Monta consulta SQL
											cQuery := "  SELECT           " + CRLF 
											cQuery += "    SD1.D1_FILIAL  " + CRLF 
											cQuery += "   ,SD1.D1_ITEM    " + CRLF 
											cQuery += "   ,SD1.D1_DOC     " + CRLF 
											cQuery += "   ,SD1.D1_SERIE   " + CRLF 
											cQuery += "   ,SD1.D1_FORNECE " + CRLF 
											cQuery += "   ,SD1.D1_LOJA    " + CRLF 
											cQuery += "   ,SD1.D1_ITEM    " + CRLF 
											cQuery += "   ,SD1.D1_COD     " + CRLF
											cQuery += "   ,SB1.B1_XCODEXT " + CRLF
											cQuery += "   ,SB1.B1_GRUPO   " + CRLF
											cQuery += "   ,SB1.B1_DESC    " + CRLF
											cQuery += "   ,SB1.B1_CODBAR  " + CRLF
											cQuery += "   ,SB1.B1_UM      " + CRLF
											cQuery += "   ,SBM.BM_DESC    " + CRLF 
											cQuery += "   ,SD1.D1_QUANT   " + CRLF 
											cQuery += "   ,SD1.D1_VUNIT   " + CRLF 
											cQuery += "   ,SD1.D1_TOTAL   " + CRLF
											cQuery += "   FROM " + RetSQLName( "SF1" ) + " SF1 " + CRLF 
											cQuery += " INNER JOIN " + RetSQLName( "SD1" ) + " SD1 ON " + CRLF 
											cQuery += "        SD1.D1_FILIAL  = SF1.F1_FILIAL  " + CRLF 
											cQuery += "    AND SD1.D1_DOC     = SF1.F1_DOC     " + CRLF 
											cQuery += "    AND SD1.D1_SERIE   = SF1.F1_SERIE   " + CRLF 
											cQuery += "    AND SD1.D1_FORNECE = SF1.F1_FORNECE " + CRLF 
											cQuery += "    AND SD1.D1_LOJA    = SF1.F1_LOJA    " + CRLF 
											cQuery += "    AND SD1.D1_TIPO    = SF1.F1_TIPO    " + CRLF 
											cQuery += "    AND SD1.D_E_L_E_T_ = ' '            " + CRLF
											cQuery += " INNER JOIN " + RetSQLName( "SB1" ) + " SB1 ON " + CRLF 
											cQuery += "        SB1.B1_FILIAL  = '" + xFilial( "SB1" ) + "' " + CRLF 
											cQuery += "    AND SB1.B1_COD     = SD1.D1_COD " + CRLF 
											cQuery += "    AND SB1.D_E_L_E_T_ = ' '        " + CRLF
											cQuery += " LEFT OUTER JOIN " + RetSQLName( "SBM" ) + " SBM ON " + CRLF 
											cQuery += "        SBM.BM_FILIAL  = '" + xFilial( "SBM" ) + "' " + CRLF 
											cQuery += "    AND SBM.BM_GRUPO   = SB1.B1_GRUPO               " + CRLF 
											cQuery += "    AND SBM.D_E_L_E_T_ = ' '                        " + CRLF  
											cQuery += "  WHERE SF1.F1_FILIAL  = '" + SF1->F1_FILIAL  + "' " + CRLF 
											cQuery += "    AND SF1.F1_DOC     = '" + SF1->F1_DOC     + "' " + CRLF 
											cQuery += "    AND SF1.F1_SERIE   = '" + SF1->F1_SERIE   + "' " + CRLF 
											cQuery += "    AND SF1.F1_FORNECE = '" + SF1->F1_FORNECE + "' " + CRLF 
											cQuery += "    AND SF1.F1_LOJA    = '" + SF1->F1_LOJA    + "' " + CRLF 
											cQuery += "    AND SF1.F1_STATUS  = ' '                       " + CRLF 
											cQuery += "    AND SF1.D_E_L_E_T_ = ' '                       " + CRLF 
											cQuery += "  ORDER BY                                         " + CRLF 
											cQuery += "    SD1.D1_ITEM                                    " + CRLF
											cQuery   :=ChangeQuery(cQuery)
											cAliasQry:=MPSysOpenQuery(cQuery)

											// -> Se houver dados, prossegue.
											lCont:=(cAliasQry)->(!Eof())
											If lCont
												cXml := oTag:MakeXml(cAliasQry,lCont,cErro,cCodEmpTek,cCodFilTek,cFilWS ,cIdUser,SF1->F1_SERIE,SF1->F1_DOC,SF1->F1_EMISSAO,SA2->A2_CGC,SA2->A2_NOME,cUsrName)
											Else
											    cErro:="Nenhum registro encontrado para conferencia."
												cXml := oTag:MakeXml(cAliasQry,lCont,cErro,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,SF1->F1_SERIE,SF1->F1_DOC,SF1->F1_EMISSAO,SA2->A2_CGC,SA2->A2_NOME,cUsrName)	
											EndIf
										Else
											cErro:="Documento " + SF1->F1_DOC + " e serie " + SF1->F1_SERIE + " ja classificado em " + DtoC(SF1->F1_DTDIGIT)
											cXml := oTag:MakeXml(cAliasQry,lCont,cErro,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,SF1->F1_SERIE,SF1->F1_DOC,SF1->F1_EMISSAO,SA2->A2_CGC,SA2->A2_NOME,cUsrName)	
										EndIf		
									Else
										cErro:="Documento " + SF1->F1_DOC + " e serie " + SF1->F1_SERIE + " encontra-se com bloqueio."
										cXml := oTag:MakeXml(cAliasQry,lCont,cErro,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,SF1->F1_SERIE,SF1->F1_DOC,SF1->F1_EMISSAO,SA2->A2_CGC,SA2->A2_NOME,cUsrName)	
									EndIf		
								Else
									cErro:="Documento " + cCodNfe + " e serie " + cSerNFe + " informados na chave nao encontrados na tabela SF1." 
									cXml := oTag:MakeXml(cAliasQry,lCont,cErro,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,SF1->F1_SERIE,SF1->F1_DOC,SF1->F1_EMISSAO,SA2->A2_CGC,SA2->A2_NOME,cUsrName)	
								EndIf		
							Else
								cErro:="Fornecedor com o CNPJ " + cCNPJ + " nao encontrado na tabela SA2 ."
								cXml := oTag:MakeXml(cAliasQry,lCont,cErro,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,"","",CToD("  /  /  "),"","",cUsrName)	
							EndIf		
						Else
							cErro:="A chave informada eh invalida."
							cXml := oTag:MakeXml(cAliasQry,lCont,cErro,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,"","",CToD("  /  /  "),"","",cUsrName)	
						EndIf
					Else
						cErro :="Usuario " + cIdUser + " nao encontrado no Protheus."
						cXml := oTag:MakeXml(cAliasQry,lCont,cErro,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,"","",CToD("  /  /  "),"","","")	
					EndIf	
				Else
					cErro:="Nao eh permitido utilizar o acesso do usuario Admin."
					cXml := oTag:MakeXml(cAliasQry,lCont,cErro,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,"","",CToD("  /  /  "),"","",cUsrName)	
				EndIf	
			Else
				cErro :="Erro ao carregar as filiais na tabela SM0 do Protheus [M0_CODIGO = " + cEmpWS + " e M0_CODFIL = " + cFilWS + "]"
				cXml := oTag:MakeXml(cAliasQry,lCont,cErro,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,"","",CToD("  /  /  "),"","","")	
			EndIf

		RpcClearEnv()
		RPcSetType(3)
		RpcSetEnv(cxEmpAnt,cxFilAnt, , ,'EST' , GetEnvServer() )
		OpenSm0(cxEmpAnt, .f.)
		SM0->(dbSetOrder(1))
		SM0->(dbSeek(cxEmpAnt+cxFilAnt))
		PswOrder(1)
		PswSeek(cUserA,.T.) 
		nModulo  := nModAnt
		cUsrName :=UsrRetName(cUserA)
		__cUserID:=cUsrName
		aGrpUser := UsrRetGrp(cUsrName)
		cEmpAnt  := SM0->M0_CODIGO
		cFilAnt  := SM0->M0_CODFIL	
		dDataAnt := dxDatAnt
	
	Else
		cErro :="Empresa e filial nao cadastrada na tabela ADK."
		cXml := oTag:MakeXml(cAliasQry,lCont,cErro,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,"","",CToD("  /  /  "),"","","")	
	EndIf
	
	// -> Se Ok, retorna 
	If Empty(cErro)
		ConOut("Ok.")
	Else
		ConOut("Erro.")		
	EndIf

	ConOut(AllTrim(Str(nThrdID))+": Fim do processo: " + DtoC(Date()) + " as " + Time())
	ConOut("=================================================================================================")


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
