#INCLUDE 'protheus.ch'
#INCLUDE "restful.ch"
/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GetTiposMovimntos                                                             !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! WS para gerar a lista de tipos de movimentos do estoque                       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio A. Zaguetti                                                            !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 15/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
WSRESTFUL GetTiposMovimntos DESCRIPTION "Madero - Cadastro de tipos de movimentos"

	WSDATA cdempresa AS STRING
	WSDATA cdfilial AS STRING

	WSMETHOD GET DESCRIPTION "Cadastro de tipos de movimentos" WSSYNTAX "/GetTiposMovimntos"

End WSRESTFUL


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GET                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Implementação do método GET do WS para gerar a lista de tipos de movimentos   !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio A. Zaguetti                                                            !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 15/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
WSMETHOD GET WSRECEIVE cdempresa, cdfilial  WSSERVICE GetTiposMovimntos
Local cCodEmpTek:= Self:cdempresa
Local cCodFilTek:= Self:cdfilial
Local cXml		:= ""
Local nThrdID   := ThreadId()
Local cEmpProth := "01"
Local cFilProth := "01GDAD0001"

	ConOut(AllTrim(Str(nThrdID))+": Requisitando metodo GetTiposMovimntos em " + DtoC(Date()) + " as " + Time())
	::SetContentType("application/xml")

	ConOut(AllTrim(Str(nThrdID))+": GetTiposMovimntos: Carregando dicionario de dados...")
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
		ConOut(AllTrim(Str(nThrdID))+": GetTiposMovimntos: Erro ao abrir o dicionário de dados.")
		Return(.F.)
	EndIf

    cXml := WSEST012(cCodEmpTek, cCodFilTek, nThrdID)

	::SetResponse(cXML)

Return .T.



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ProtheusGetTiposMovimntos                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Implementação dda classe para o WS para gerar o cadastro de movimentos        !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Marcio A. Zaguetti                                                            !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 15/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                

Class ProtheusGetTiposMovimntos From ProtheusMethodAbstract

	Method new(cMethod) constructor
	Method makeXml(cAlQry,cErro,lOk,cCodEmpTek,cCodFilTek,cFilWS,nThrdID)

EndClass



/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! New                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Construtor da classe do WS para gerar o cadastro de movimntos                 !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio A. Zaguetti                                                            !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 15/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Method New(cMethod) Class ProtheusGetTiposMovimntos
	::cMethod := cMethod
Return




/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! makeXml                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Implementação do método makeXml da classe do WS para gerar a lista de movimen-!
!                  ! tos                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio A. Zaguetti                                                            !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 15/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                

Method makeXml(cAlQry,cErroRet,lOk,cCodEmpTek,cCodFilTek,cFilWS,nThrdID) Class ProtheusGetTiposMovimntos
Local cXml 			:= ""
Local lErro         := .F.
Local cErro         := ""

	cXml := '<?xml version="1.0" encoding="ISO-8859-1"?>'
	cXml += '<retorno>'

	cXml += '<id ' 
	cXml += 'cdempresa="'     + cCodEmpTek + '" '	
	cXml += 'cdfilial="'      + cCodFilTek + '" '
	cXml += 'filial="'	      + cFilWS     + '" '		
	cXml += '/>'

	cXml += '<tm>'

    If lOk			
    	// -> Gera produtos dados de produtos
	    While !(cAlQry)->(Eof()) 
			
		    cXml += '<tm'
			cXml += ::tag('cdmovimento'	,(cAlQry)->F5_CODIGO)		
			cXml += ::tag('dsmovimento'	,AllTrim((cAlQry)->F5_TEXTO))	
			cXml += '/>'

			(cAlQry)->(dbSkip())
			
		EndDo
	
	EndIf

	cXml += '</tm>'	
	
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
Static Function WSEST012(cCodEmpTek, cCodFilTek, nThrdID)
Local cErro	  := ""
Local cXml	  := ""
Local lCont	  := .T.
Local cQuery  := ""
Local cEmpWS  := ""
Local cFilWS  := ""
Local cxEmpant:= ""
Local cxFilAnt:= ""
Local oWs	  := ProtheusGetTiposMovimntos():New("Tag")
Local cAlQry  := ""
	
	ConOut(AllTrim(Str(nThrdID))+": Validando dados da empresa...")
	// -> Verifica se foram passados os parâmetros de empresa e filial
	lCont:=!(cCodEmpTek == Nil .or. cCodFilTek == Nil)
	If lCont
		// -> Verifica os dados da empresa
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
					cEmpAnt  := SM0->M0_CODIGO
					cFilAnt  := SM0->M0_CODFIL		
				
					ConOut(AllTrim(Str(nThrdID))+": Pesquisando tipos de movimentos...")
					cQuery := "SELECT F5_CODIGO, F5_TEXTO       "
    	            cQuery += "FROM "+RetSqlName("SF5")     + " " 
        	        cQuery += "WHERE D_E_L_E_T_ <> '*' AND      "
            	    cQuery += "      SUBSTR(F5_CODIGO,1,1) IN ('6','7','8') "
                	cQuery += "ORDER BY F5_CODIGO "
					cQuery := ChangeQuery(cQuery)
					cAlQry := MPSysOpenQuery(cQuery)
					If (cAlQry)->(Eof())
						lCont := .F.
						cErro := "Nao ha tipos de movimentos para pesquisar."
					Else	
						cXml:=oWs:makeXml(cAlQry,cErro,lCont,cCodEmpTek,cCodFilTek,cFilWS,nThrdID)					                  
						(cAlQry)->(DbCloseArea())
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
			cEmpAnt  := SM0->M0_CODIGO
			cFilAnt  := SM0->M0_CODFIL		
		Else	
			cErro :="Empresa e filial nao encontradas da tabela ADK do Protheus."
			lCont:=.F.		
		EndIf
	Else
		cErro :="Informe os parametros [cdempresa] e [cdfilial] do Teknisa para o metodo."
		cCodEmpTek:=IIF(cCodEmpTek==Nil,"Nao informado",cCodEmpTek)
		cCodFilTek:=IIF(cCodFilTek==Nil,"Nao informado",cCodFilTek)
		lCont:=.F.		
	EndIf	
	
	If !lCont
		cXml:=oWs:makeXml(cAlQry,cErro,lCont,cCodEmpTek,cCodFilTek,cFilWS,nThrdID)
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


