#INCLUDE 'protheus.ch'
#INCLUDE "restful.ch"

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! PutClassificacaoNF                                                            !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração do WebService PutClassificacaoNF                                   !
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
WSRESTFUL PutClassificacaoNF DESCRIPTION "Madero - Classificação da NF"
	
	WSDATA cdempresa AS STRING
	WSDATA cdfilial AS STRING
	WSDATA cdusuario AS STRING
	WSDATA chavenfe AS STRING

	WSMETHOD PUT DESCRIPTION "Acesso de Usuários" WSSYNTAX "/PutClassificacaoNF || /PutClassificacaoNF/{id}"

End WSRESTFUL






/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! PutClassificacaoNF                                                            !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração do Metodo PutClassificacaoNF                                       !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
WSMETHOD PUT WSRECEIVE cdempresa, cdfilial, cdusuario, chavenfe  WSSERVICE PutClassificacaoNF
Local cXml	:= ""
Local nThrdID := ThreadId()
Local cEmpProth := "01"
Local cFilProth := "01GDAD0001"

	ConOut(AllTrim(Str(nThrdID))+": Requisitando metodo PutClassificacaoNF em " + DtoC(Date()) + " as " + Time())
	::SetContentType("application/xml")

	ConOut(AllTrim(Str(nThrdID))+": PutClassificacaoNF: Carregando dicionario de dados...")
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
		ConOut(AllTrim(Str(nThrdID))+": PutClassificacaoNF: Erro ao abrir o dicionário de dados.")
		Return(.F.)
	EndIf

	cXml := U_WSEST022(Self:cdempresa,Self:cdfilial,Self:cdusuario,Self:chavenfe,nThrdID)

	::SetResponse(cXML)

Return .T.


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! WSEST022                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função principal de processamento                                             !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
User Function WSEST022(cCodEmp,cCodFil,cIdUser,chavenfe,nThrdID)
Local cXml		:= ""
Local cErro		:= ""
Local oTag		:= ProtheusPutClassificacaoNF():New( "Tag" )
Local lCont     := .F.
Local cEmpWS    := ""
Local cFilWS    := "" 
Local cxEmpant  := "" 
Local cxFilAnt  := ""
Local cCNPJ	    := ""
Local cSerNFe	:= ""
Local cCodNfe	:= ""
Local dEmisNFe  := CToD("")
Local cNomFor	:= ""
Local cUserA    := ""
Local dDataAnt  := dDataBase
Local cUsrName  := ""
Local aGrpUser  := {}

	// -> Valida a conexão da empresa
	lCont:=VerEmp(cCodEmp,cCodFil,@cEmpWS,@cFilWS,@cxEmpant,@cxFilAnt)
	If lCont	
		// -> Carrega o ambiente conforme dados da empresa e filial passados nos parâmetros do método
		ConOut(AllTrim(Str(nThrdID))+": Carregando ambiente para empresa " + cEmpWS + " e filial "+cFilWS)
		RpcClearEnv()
		RPcSetType(3)
		RpcSetEnv(cEmpWS,cFilWS, , ,'EST' , GetEnvServer() )
			OpenSm0(cEmpWS, .f.)
			nModulo := 4
			SM0->(dbSetOrder(1))
			lCont:=SM0->(dbSeek(cEmpWS+cFilWS))					
			// -> Se o ambiente está ok, continua
			If lCont								
				// -> Posiciona no acesso do usuário
				PswOrder(1)
				PswSeek(cIdUser,.T.) 
				cUsrName  :=UsrRetName(cIdUser)
				__cUserID :=cUsrName
				cIDUsuario:=__cUserID
				aGrpUser  :=UsrRetGrp(cUsrName)
				cEmpAnt   :=SM0->M0_CODIGO
				cFilAnt   :=SM0->M0_CODFIL	
				dDataBase :=Date() 
				cUserA    := RetCodUsr()

				// -> Verifica se é Admin
				lCont:=!("ADMIN" $ Upper(cUsrName))
				If lCont											
					// -> Se o usuário ok, continua
					lCont:=!Empty(cUsrName)
					If lCont																				
						cCNPJ 	:= SubStr(chavenfe,07,14)
						cSerNFe := SubStr(chavenfe,23,03)
						cCodNfe := SubStr(chavenfe,26,09)
						ConOut(AllTrim(Str(nThrdID))+": Classificando NF no. " + cCodNfe + " e serie " + cSerNFe+"...")

						// -> Pesquisar fornecedor
						SA2->(DbSetOrder(3))
						lCont:=SA2->(DbSeek(xFilial("SA2")+cCNPJ))
						If lCont
							cNomFor:=SA2->A2_NOME
							// -> Pesquisar Pré-nota
							SF1->(DbSetOrder(1))
							lCont:=SF1->(DbSeek(xFilial("SF1")+cCodNfe+cSerNFe+SA2->A2_COD+SA2->A2_LOJA))
							If lCont								
								dEmisNFe:=SF1->F1_EMISSAO
								// -> Se a nota nao estiver classificada, prossegue.
								lCont:=Empty(SF1->F1_STATUS) .Or. (SF1->F1_STATUS=="B")
								If lCont	
									// -> Executa classificação do docuemnto de entrada
									cErro:=oTag:procRegs(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)
									If AllTrim(cErro) == ""
										cXml:=oTag:MakeXml(cCodEmp,cCodFil,.T.,cErro,cFilWS,cCodNfe,cSerNFe,dEmisNFe,cCNPJ,cNomFor,cUsrName)
									Else
										cXml:=oTag:MakeXml(cCodEmp,cCodFil,.F.,cErro,cFilWS,cCodNfe,cSerNFe,dEmisNFe,cCNPJ,cNomFor,cUsrName)
									EndIf
								Else
									cErro:="Documento " + SF1->F1_DOC + " e serie " + SF1->F1_SERIE + " ja classificado em " + DtoC(SF1->F1_DTDIGIT)									
									cXml :=oTag:MakeXml(cCodEmp,cCodFil,.F.,cErro,cFilWS,cCodNfe,cSerNFe,dEmisNFe,cCNPJ,cNomFor,cUsrName)
								EndIf	
							Else																
								cErro:="Documento "+cCodNfe+" e serie " + cSerNFe + " nao enocontrados na tabela SF1."					
								cXml :=oTag:MakeXml(cCodEmp,cCodFil,.F.,cErro,cFilWS,cCodNfe,cSerNFe,dEmisNFe,cCNPJ,cNomFor,cUsrName)										
							EndIf
						Else
							cErro:="Fornecedor com o CNPJ " + cCNPJ + " nao encontrado na tabela SA2 ."
							cXml :=oTag:MakeXml(cCodEmp,cCodFil,.F.,cErro,cFilWS,cCodNfe,cSerNFe,dEmisNFe,cCNPJ,cNomFor,cUsrName)
						EndIf
					Else
						cErro :="Usuario " + cUsrName + " nao encontrado no Protheus."
						cXml :=oTag:MakeXml(cCodEmp,cCodFil,.F.,cErro,cFilWS,cCodNfe,cSerNFe,dEmisNFe,cCNPJ,cNomFor,cUsrName)
					EndIf
				Else
					cErro:="Nao eh permitido utilizar o acesso do usuario Admin."
					cXml :=oTag:MakeXml(cCodEmp,cCodFil,.F.,cErro,cFilWS,cCodNfe,cSerNFe,dEmisNFe,cCNPJ,cNomFor,cUsrName)
				EndIf	
			Else
				cErro :="Erro ao carregar as filiais na tabela SM0 do Protheus [M0_CODIGO = " + cEmpWS + " e M0_CODFIL = " + cFilWS + "]"
				cXml :=oTag:MakeXml(cCodEmp,cCodFil,.F.,cErro,cFilWS,cCodNfe,cSerNFe,dEmisNFe,cCNPJ,cNomFor,cUsrName)
			EndIf

		// -> Recarrega o ambiente anterior
		RpcClearEnv()
		RPcSetType(3)
		RpcSetEnv(cxEmpant,cxFilAnt, , ,'EST' , GetEnvServer() )
		OpenSm0(cxEmpant, .f.)
		nModulo := 4
		SM0->(dbSetOrder(1))
		SM0->(dbSeek(cxEmpant+cxFilAnt))
		PswOrder(1)
		PswSeek(cUserA,.T.) 
		cUsrName :=UsrRetName(cUserA)
		__cUserID:=cUsrName
		aGrpUser := UsrRetGrp(cUsrName)
		cEmpAnt  := SM0->M0_CODIGO
		cFilAnt  := SM0->M0_CODFIL	
		dDataBase:=dDataAnt
	Else
		cErro:="Empresa e filial nao cadastrada na tabela ADK. [ADK_XEMP="+cCodEmp+" e ADK_XFIL="+cCodFil+"]"
		cXml :=oTag:MakeXml(cCodEmp,cCodFil,.F.,cErro,cFilWS,cCodNfe,cSerNFe,dEmisNFe,cCNPJ,cNomFor,cUsrName)
	EndIf

	// -> Se Ok, retorna 
	If Empty(cErro)
		ConOut(AllTrim(Str(nThrdID))+"Ok.")
	Else
		ConOut(AllTrim(Str(nThrdID))+"Erro.")
	EndIf

Return cXml


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ProtheusPutClassificacaoNF                                                    !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! declaração das classe para gerar o XML                                        !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  

Class ProtheusPutClassificacaoNF From ProtheusMethodAbstract

	Method new( cMethod ) constructor
	Method makeXml(cdempresa,cdfilial,lOk,cErro,filial,numeronf,serienf,emissaonf,cnpj,nomfornec,idusuario)
	Method procRegs( )

EndClass


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! New                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Metodo Inicializados da Classe New                                            !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  

Method New(cMethod) Class ProtheusPutClassificacaoNF
	::cMethod := cMethod
Return


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! getRegs                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Metodo de processamento de registros                                          !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 07/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  

Method procRegs() Class ProtheusPutClassificacaoNF
Local cxRet 	:= ""
Local aSF1		:= { }
Local aSD1		:= { }
Local lErroTes	:= .F.
Local cAuxTes   := ""
Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.
	
	// -> Seleciona tabelas
	dbSelectArea( "SB1" )
	SB1->( dbSetOrder( 1 ) )//B1_FILIAL+B1_COD
	dbSelectArea( "SF4" )
	SF4->( dbSetOrder( 1 ) )//F4_FILIAL+F4_TES
	dbSelectArea( "SC7" )
	SC7->( dbSetOrder( 1 ) ) // C7_FILIAL+C7_NUM+C7_ITEM
	
	// -> Atualiza dados do documento fiscal para classificação
	RecLock("SF1",.F.)
	SF1->F1_DTDIGIT:=dDataBase
	SF1->F1_RECBMTO:=dDataBase
	SF1->(MsUnlock())	

	// -> Posiciona nos itens da pré nota
	dbSelectArea( "SD1" )
	SD1->( dbSetOrder( 1 ) )
	If SD1->( dbSeek( SF1->( F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA ) ) )
		AAdd( aSF1, { "F1_FILIAL"	, SF1->F1_FILIAL	, Nil } )
		AAdd( aSF1, { "F1_DOC"		, SF1->F1_DOC		, Nil } )
		AAdd( aSF1, { "F1_SERIE"	, SF1->F1_SERIE		, Nil } )
		AAdd( aSF1, { "F1_FORNECE"	, SF1->F1_FORNECE	, Nil } )
		AAdd( aSF1, { "F1_LOJA"		, SF1->F1_LOJA		, Nil } )
		AAdd( aSF1, { "F1_TIPO"		, SF1->F1_TIPO		, Nil } )		
		While SD1->( !Eof( ) ) .And. SD1->( D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA ) == SF1->( F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA )
			// -> Se o documento de entrada possui pedido, verifica a TES do pedido 
			lErroTes:=.F.
			cAuxTes :=""

			// -> Valida se pre nota possui TES informada.
			If !Empty(SD1->D1_TESACLA) 
				AAdd( aSD1, {	{"D1_COD"		, SD1->D1_COD	, Nil },;
				{"D1_ITEM"		, SD1->D1_ITEM		, Nil },;
				{"D1_FORNECE"	, SD1->D1_FORNECE	, Nil },;
				{"D1_LOJA"		, SD1->D1_LOJA		, Nil },;
				{"D1_PEDIDO"	, SD1->D1_PEDIDO	, Nil },;
				{"D1_ITEMPC"	, SD1->D1_ITEMPC	, Nil },;
				{"D1_TES"		, SD1->D1_TESACLA 	, Nil },;
				{"LINPOS" , "D1_ITEM",  SD1->D1_ITEM}}) 
			Else
				lErroTes:=.T.
			EndIf
			
			// -> Verifica erro na TES
			If lErroTes	
				If Empty( cxRet )
					cxRet += "TES e/ou pedido de compra invalido(s) para os seguintes itens no pedido de compra:" + CRLF 
					cxRet += "Item Pedido    Codigo           Descricao                                                      Cod. TES  " + CRLF  
					cxRet += "---- --------- ---------------- -------------------------------------------------------------- ----------" + CRLF 
				 EndIf 
				 cxRet += PadR( SD1->D1_ITEMPC	, 04, " " )
				 cxRet += " "
				 cxRet += PadR( SD1->D1_PEDIDO	, 09, " " )
				 cxRet += " "
				 cxRet += PadR( SD1->D1_COD		, 16, " " )
				 cxRet += " "
				 SB1->( dbSeek( xFilial( "SB1" ) + SD1->D1_COD ) )
				 cxRet += PadR( SB1->B1_DESC		, 62, " " )
				 cxRet += " "
				 cxRet += PadR( cAuxTes  		, 10, " " )
				 cxRet += " " + CRLF
			EndIf			
			
			SD1->( dbSkip( ) )
		
		EndDo		
		
		If Empty( cxRet )
			SD1->( dbSeek( SF1->( F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA ) ) )
			aSF1 := fChkCpos( aSF1 )
			AEval( aSD1, {|x,y| aSD1[y] := fChkCpos( aSD1[y] ) } )
			l103Class	:= .T.
			l103TolRec	:= .T.
			INCLUI		:= .F.
			ALTERA		:= .F.
			MsExecAuto( { |x,y,z,w| MATA103( x/*xAutoCab*/, y/*xAutoItens*/, z/*nOpcAuto*/, /*lWhenGet*/, /*xAutoImp*/, /*xAutoAFN*/, /*xParamAuto*/, /*xRateioCC*/, w/*lGravaAuto*/, /*xCodRSef*/ ) }, aSF1, aSD1, 4, .T. )
			If lMsErroAuto
				cxRet := fGetErro( "MATA103" )
			Else
				//#TB20200512 Thiago Berna - Verifica se o documento foi bloqueado.
				If SF1->F1_STATUS == 'B'
					cxRet := "Documento bloqueado. Verificar parcelas e vencimento"
				EndIf
			EndIf
		EndIf
	EndIf
	
	
Return cxRet


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! makeXml                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Metodo para gerar XML do WS                                                   !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 07/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/    
Method makeXml(cdempresa,cdfilial,lOk,cErro,filial,numeronf,serienf,emissaonf,cnpj,nomfornec,idusuario) Class ProtheusPutClassificacaoNF
Local cXml 		:= ''
Local nX		:= 0
Default lOk		:= .F.
Default cErro	:= "Erro indeterminado. favor verificar com a TOTVS."

	cXml += '<?xml version="1.0" encoding="ISO-8859-1"?>'
	
	cXml += '<retorno>'
	
	cXml += '<id '
	cXml += ::tag('cdempresa'	, cdempresa)
	cXml += ::tag('cdfilial'	, cdfilial)
	cXml += ::tag('filial'	    , filial)
	cXml += ::tag('numeronf'	, numeronf)
	cXml += ::tag('serienf'		, serienf)
	cXml += ::tag('emissaonf'	, DToS(emissaonf) )
	cXml += ::tag('cnpj'		, cnpj)
	cXml += ::tag('nomfornec'	, nomfornec)
	cXml += ::tag('idusuario'	, idusuario)
	
	cXml += '/>'

	cXml += '<confirmacao>'
	
	cXml += '<confirmacao'
	
	cXml += ::tag('integrado',IIF(lOk,"true","false"))
	cXml += ::tag('mensagem' ,IIF(lOk,"Documento classificado com sucesso.",cErro))
	cXml += ::tag('data'			,DtoS(Date()))		
	cXml += ::tag('hora'			,Time())	
	
	cXml += '/>'
	
	cXml += '</confirmacao>'
	
	cXml += '</retorno>'

Return cXml




/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! fChkCpos                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Ordena campos para processamento do MSExecAuto                                !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 07/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function fChkCpos(aCpos)
Local aCposAux := {}
Local aRet     := {}
Local nCpo     := 0
Local nTamCpo  := Len(SX3->X3_CAMPO)

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))

	For nCpo := 1 to Len(aCpos)
		If SX3->(dbSeek(PadR(aCpos[nCpo, 1], nTamCpo, " ")))
			aAdd(aCposAux, {SX3->X3_ORDEM, aCpos[nCpo]})
		Else
			aAdd(aCposAux, {"999", aCpos[nCpo]})
		EndIf
	Next nCpo
	
	ASort(aCposAux,,,{|x,y| x[1] < y[1] })
	For nCpo := 1 to Len(aCposAux)
		aAdd(aRet, aCposAux[nCpo,2])
	Next nCpo

Return aRet


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! fGetErro                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Retorna mensagem de erro do MSExecAuto                                        !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 07/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function fGetErro( cPrefix )
Local cDirLogs	:= "\temp\"
Local cArqLog	:= cPrefix + "_" + DToS( Date( ) ) + "_" + StrTran( Time( ), ":", "" ) + ".log"
Local cRet		:= ""

	MostraErro( cDirLogs, cArqLog )
	cRet := MemoRead( cDirLogs + cArqLog )
	FErase( cDirLogs + cArqLog )
	If Empty( cRet )
		cRet := "Erro"
	EndIf

Return cRet



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! VerEmp                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para validar e posicionar na Empresa/Filial informada                  !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/08/2018                                                                    !
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
