#INCLUDE 'protheus.ch'
#INCLUDE "restful.ch"
/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GetTiposMovimentacao                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! WS para gerar a lista de Tipos de Movimentacao do usuário                     !
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
WSRESTFUL GetTiposMovimentacao DESCRIPTION "Madero - Tipos de Movimentacao"

	WSDATA cdempresa AS STRING
	WSDATA cdfilial AS STRING

	WSMETHOD GET DESCRIPTION "Tipos de Movimentacao" WSSYNTAX "/GetTiposMovimentacao"

End WSRESTFUL


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GetTiposMovimentacao                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Implementação do método GET do WS para gerar a lista de Tipos de Movimentacao !
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
WSMETHOD GET WSRECEIVE cdempresa, cdfilial  WSSERVICE GetTiposMovimentacao
Local cCodEmpTek := Self:cdempresa
Local cCodFilTek := Self:cdfilial
Local cXml		:= ""
Local nThrdID   := ThreadId()
Local cEmpProth := "01"
Local cFilProth := "01GDAD0001"

	ConOut(AllTrim(Str(nThrdID))+": Requisitando metodo GetTiposMovimentacao em " + DtoC(Date()) + " as " + Time())

	::SetContentType("application/xml")
		
	ConOut(AllTrim(Str(nThrdID))+": GetTiposMovimentacao: Carregando dicionario de dados...")
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
		ConOut(AllTrim(Str(nThrdID))+": GetTiposMovimentacao: Erro ao abrir o dicionário de dados.")
		Return(.F.)
	EndIf

    cXml := WSEST009(cCodEmpTek, cCodFilTek,nThrdID)

	::SetResponse(cXML)

Return .T.



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ProtheusGetTiposMovimentacao                                                !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Implementação dda classe para o WS para gerar a lista de Tipos de Movimentacao!
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

Class ProtheusGetTiposMovimentacao From ProtheusMethodAbstract

	Method new(cMethod) constructor
	Method makeXml(cAlQry,cErro,lCont,cCodEmpTek,cCodFilTek,cFilWS,nThrdID)

EndClass



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ProtheusGetTiposMovimentacao                                                !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Construtor da classe do WS para gerar a lista de Tipos de Movimentacao        !
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
Method New(cMethod) Class ProtheusGetTiposMovimentacao
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

Method makeXml(cAlQry,cErro,lOk,cCodEmpTek,cCodFilTek,cFilWS,nThrdID) Class ProtheusGetTiposMovimentacao
Local cXml:= ""

	cXml := '<?xml version="1.0" encoding="ISO-8859-1"?>'
	cXml += '<retorno>'
	cXml += '<id cdempresa="'+cCodEmpTek+'" cdfilial="'+cCodFilTek+'" filial="'+cFilWS+'"/>'
	cXml += '<tipos>'
	// -> Monta array com os dados 
	If lOk
		(cAlQry)->(DbGoTop()) 
		While !(cAlQry)->(Eof()) 
			cXml += '<tipo'
			cXml += ::tag('cdmovimentacao',AllTrim((cAlQry)->Z30_ID))
			cXml += ::tag('dsmovimentacao',AllTrim((cAlQry)->F5_TEXTO))
			cXml += '/>'
			(cAlQry)->(dbSkip())
		EndDo
		(cAlQry)->(dbCloseArea())
	EndIf	

	cXml += '</tipos>'		
	cXml += '<confirmacao>'
	cXml += '<confirmacao'
	cXml += ::tag('integrado',IIF(lOk,"true","false"))
	cXml += ::tag('mensagem',IIF(lOk,"Consulta ok.","Erro naconsulta."))
	cXml += ::tag('data'	,DtoS(Date()))		
	cXml += ::tag('hora'	,Time())	
	cXml += '/>'
	cXml += '</confirmacao>'

	cXml += '</retorno>'	

Return cXml

/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! WSEST009                                                                      !
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
Static Function WSEST009(cCodEmpTek, cCodFilTek,nThrdID)
Local cErro	  := ""
Local cXml	  := ""
Local lCont	  := .T.
Local lEmp    := .T.
Local cQuery  := ""
Local cEmpWS  := ""
Local cFilWS  := ""
Local cxEmpant:= ""
Local cxFilAnt:= ""
Local cAlQry  := ""
Local oTag

	ConOut(AllTrim(Str(nThrdID))+": Validando dados da empresa...")
	oTag:=ProtheusGetTiposMovimentacao():New("Tag")
	// -> Verifica se foram passados os parâmetros de empresa e filial
	lCont:=!(cCodEmpTek == Nil .or. cCodFilTek == Nil)
	If lCont
		// -> Valida a empresa		
		lEmp:=VerEmp(cCodEmpTek,cCodFilTek,@cEmpWS,@cFilWS,@cxEmpant,@cxFilAnt)
		If lEmp
		
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
				ConOut(AllTrim(Str(nThrdID))+": Pesquisando dados...")
				If lCont
					cEmpAnt := SM0->M0_CODIGO
					cFilAnt := SM0->M0_CODFIL

		        	cQuery := "SELECT Z30_ID, F5_TEXTO FROM "+RetSqlName("Z30")+" Z30   "+ CRLF
        			cQuery += "INNER JOIN "+RetSqlName("SF5")+" ON                      "+ CRLF
        			cQuery += "	  (F5_CODIGO = Z30.Z30_ID)                              "+ CRLF
        			cQuery += "	WHERE Z30.Z30_FILIAL = '"+xFilial("Z30") +"'  AND       "+ CRLF
					cQuery += "       Z30.D_E_L_E_T_ <> '*'                             "+ CRLF
        			cQuery += "GROUP BY Z30.Z30_ID,F5_TEXTO                             "+ CRLF
					cQuery := ChangeQuery(cQuery)
					cAlQry := MPSysOpenQuery(cQuery)
					If (cAlQry)->(Eof())
						lCont:=.F.
						cErro:="Não há tipos de movimentação para esta filial."
					Else	
						ConOut(AllTrim(Str(nThrdID))+": Gerando e enviando dados...")
						cXml:=oTag:MakeXml(cAlQry,cErro,lCont,cCodEmpTek,cCodFilTek,cFilWS,nThrdID)
					Endif
				Else	
					cErro :="Erro ao carregar as filiais na tabela SM0 do Protheus [M0_CODIGO = " + cEmpWS + " e M0_CODFIL = " + cFilWS + "]"
					lCont:=.F.		
				EndIf

			// -> Reconecta no ambiente anterior
			RpcClearEnv()
			RPcSetType(3)
			RpcSetEnv(cxEmpant,cxFilAnt, , ,'EST' , GetEnvServer() )
			OpenSm0(cxEmpant, .f.)
			SM0->(dbSetOrder(1))
			SM0->(dbSeek(cxEmpant+cxFilAnt))
			cEmpAnt:=SM0->M0_CODIGO
			cFilAnt:=SM0->M0_CODFIL	
		Else
			cErro:="Filial nao encontrada no ERP Protheus. [ADK_XEMP="+cCodEmpTek+" e ADK_XFIL="+cCodFilTek+"]"		
			lCont:=.F.	
		EndIf	
	Else
		cErro :="Informe os parametros [cdempresa] e [cdfilial] do Teknisa para o metodo."
		cCodEmpTek:=IIF(cCodEmpTek==Nil,"Nao informado",cCodEmpTek)
		cCodFilTek:=IIF(cCodFilTek==Nil,"Nao informado",cCodFilTek)
		lCont:=.F.		
	EndIf	

	If !lCont
		cXml:=oTag:MakeXml(cAlQry,cErro,lCont,cCodEmpTek,cCodFilTek,cFilWS,nThrdID)
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