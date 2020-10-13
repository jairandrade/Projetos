#INCLUDE 'protheus.ch' 
#INCLUDE "restful.ch"

/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GetGruposProdutos                                                             !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração do WebService GetAcesso                                            !
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
WSRESTFUL GetGruposProdutos DESCRIPTION "Madero - Grupos de Produto"

	WSDATA cdempresa AS STRING
	WSDATA cdfilial AS STRING
	WSMETHOD GET DESCRIPTION "Grupos de Produto" WSSYNTAX "/GetGruposProdutos"

End WSRESTFUL


 /*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GET                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração do Metodo GetGruposProdutos                                        !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
WSMETHOD GET WSRECEIVE cdempresa, cdfilial WSSERVICE GetGruposProdutos
Local cCodEmpTek:= Self:cdempresa
Local cCodFilTek:= Self:cdfilial
Local cXml		:= ""
Local nThrdID   := ThreadId()
Local cEmpProth := "01"
Local cFilProth := "01GDAD0001"

	ConOut(AllTrim(Str(nThrdID))+": Requisitando metodo GetGruposProdutos em " + DtoC(Date()) + " as " + Time())
	
	::SetContentType("application/xml")
	
	ConOut(AllTrim(Str(nThrdID))+": GetGruposProdutos: Carregando dicionario de dados...")
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
		ConOut(AllTrim(Str(nThrdID))+": GetGruposProdutos: Erro ao abrir o dicionário de dados.")
		Return(.F.)
	EndIf

	cXml := WSEST001(cCodEmpTek, cCodFilTek,nThrdID)

	::SetResponse(cXML)

Return .T.



/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ProtheusGetGruposProdutos                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração das classe para gerar o XML                                        !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
Class ProtheusGetGruposProdutos From ProtheusMethodAbstract

	Method new(cMethod) constructor
	Method makeXml(cAlQry,cCodEmpTek,cCodFilTek,cFilWS)

EndClass


/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! New                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Metodo Inicializados da Classe ProtheusGetGruposProdutos                      !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
Method New(cMethod) Class ProtheusGetGruposProdutos
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
Method makeXml(cAlQry,cCodEmpTek,cCodFilTek,cFilWS) Class ProtheusGetGruposProdutos
Local cXml := ''

	cXml += '<?xml version="1.0" encoding="ISO-8859-1"?>'	
	cXml += '<retorno>'	

	cXml += '<id ' 
	cXml += 'cdempresa="'     + cCodEmpTek + '" '	
	cXml += 'cdfilial="'      + cCodFilTek + '" '
	cXml += 'filial="'	      + cFilWS     + '" '		
	cXml += '/>'
	
	cXml += '<grupos>'	

	While !(cAlQry)->(Eof())
	
		cXml += '<grupo'			
		cXml += ::tag('bmdesc'		,(cAlQry)->BM_DESC)		
		cXml += ::tag('bmgrupo'		,(cAlQry)->BM_GRUPO)	
		cXml += '/>'
	
		(cAlQry)->(dbSkip())
	
	EndDo
	
	cXml += '</grupos>'	
	cXml += '<confirmacao>'
	cXml += '<confirmacao'
	cXml += ::tag('integrado',"true")			
	cXml += ::tag('mensagem',"Consulta ok.")
	cXml += ::tag('data'	,DtoS(Date()))		
	cXml += ::tag('hora'	,Time())	
	cXml += '/>'
	cXml += '</confirmacao>'
	cXml += '</retorno>'

Return cXml


/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! WSEST001                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para executar WS GetAcesso                                             !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 17/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/
Static Function WSEST001(cCodEmpTek, cCodFilTek, nThrdID)
Local cQuery	:= ""
Local cAlQry	:= ""
local cAux		:= ""
Local lCont		:= .T.
Local cXml		:= ""
Local oTag		:= Nil
Local cEmpWS    := ""
Local cFilWS    := ""
Local cxEmpant  := ""
Local cxFilAnt  := ""

	ConOut(AllTrim(Str(nThrdID))+": Validando dados da empresa...")
	// -> Verifica se foram passados os parâmetros de empresa e filial
	lCont:=!(cCodEmpTek == Nil .or. cCodFilTek == Nil)
	If lCont
		// -> Verifica empresa
		lEmp :=VerEmp(cCodEmpTek,cCodFilTek,@cEmpWS,@cFilWS,@cxEmpant,@cxFilAnt)
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
				If lCont
					cEmpAnt := SM0->M0_CODIGO
					cFilAnt := SM0->M0_CODFIL

					ConOut(AllTrim(Str(nThrdID))+": Selecionando grupos de produtos...")
					cQuery := "	SELECT BM_GRUPO, BM_DESC " + CRLF
					cQuery += "	FROM " + RetSqlName("SBM") + " SBM " + CRLF
					cQuery += "	WHERE " + CRLF  
					cQuery += "	        BM_FILIAL = '" + xFilial("SBM") + "' " + CRLF 
					cQuery += "	    AND BM_GRUPO >= '500' " + CRLF
					cQuery += "	    AND D_E_L_E_T_ = ' '  " + CRLF
					cQuery += "	ORDER BY BM_GRUPO " + CRLF
					cQuery := ChangeQuery(cQuery)
					cAlQry := MPSysOpenQuery(cQuery)

					If (cAlQry)->(Eof())
						cAux := "Nao encontrado grupos de produtos. [BM_GRUPO > 500]"
						lCont := .F.
					EndIf
				EndIf	

				If lCont
					ConOut(AllTrim(Str(nThrdID))+": Enviando dados...")
					oTag := ProtheusGetGruposProdutos():New("Tag")
					cXml := oTag:MakeXml(cAlQry,cCodEmpTek,cCodFilTek,cFilWS)
				Else
					cXml:='<?xml version="1.0" encoding="ISO-8859-1"?>'
					cXml+='<retorno>'
					cXml += '<id ' 
					cXml += 'cdempresa="'     + cCodEmpTek + '" '	
					cXml += 'cdfilial="'      + cCodFilTek + '" '
					cXml += 'filial="'	      + cFilWS     + '" '		
					cXml += '/>'
					cXml+='<grupos>'
        			cXml+='</grupos>'
					cXml+='<confirmacao>'
					cXml+='<confirmacao integrado="false" mensagem="Erro: ' + cAux + '" data="' + DtoS(Date()) + '" hora="' + Time() + '"/>'
        			cXml+='</confirmacao>'
					cXml+='</retorno>'
				EndIf
			
				ConOut(AllTrim(Str(nThrdID))+": "+IIF(lCont,"Ok.","Erro."))
				(cAlQry)->(dbCloseArea())

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
			lCont:= .F.
			cAux := "Filial nao encontrada no ERP Protheus. [ADK_XEMP="+cCodEmpTek+" e ADK_XFIL="+cCodFilTek+"]"		
			cXml:='<?xml version="1.0" encoding="ISO-8859-1"?>'
			cXml+='<retorno>'
			cXml += '<id ' 
			cXml += 'cdempresa="'     + cCodEmpTek + '" '	
			cXml += 'cdfilial="'      + cCodFilTek + '" '
			cXml += 'filial="'	      + cFilWS     + '" '		
			cXml += '/>'
			cXml+='<grupos>'
        	cXml+='</grupos>'
			cXml+='<confirmacao>'
			cXml+='<confirmacao integrado="false" mensagem="Erro: ' + cAux + '" data="' + DtoS(Date()) + '" hora="' + Time() + '"/>'
        	cXml+='</confirmacao>'		
			cXml+='</retorno>'
			ConOut(AllTrim(Str(nThrdID))+": Filial nao encontrada no ERP Protheus. [ADK_XEMP="+cCodEmpTek+" e ADK_XFIL="+cCodFilTek+"]")
			ConOut(AllTrim(Str(nThrdID))+": "+IIF(lCont,"Ok.","Erro."))
	
		EndIf
	Else
		cAux      :="Informe os parametros [cdempresa] e [cdfilial] do Teknisa para o metodo."
		cCodEmpTek:=IIF(cCodEmpTek==Nil,"Nao informado",cCodEmpTek)
		cCodFilTek:=IIF(cCodFilTek==Nil,"Nao informado",cCodFilTek)
		cFilWS    :=""
		lCont     := .F.
		cXml      :='<?xml version="1.0" encoding="ISO-8859-1"?>'
		cXml      +='<retorno>'
		cXml      += '<id ' 
		cXml      += 'cdempresa="'     + cCodEmpTek + '" '	
		cXml      += 'cdfilial="'      + cCodFilTek + '" '
		cXml      += 'filial="'	      + cFilWS     + '" '		
		cXml      += '/>'
		cXml      +='<grupos>'
        cXml      +='</grupos>'
		cXml      +='<confirmacao>'
		cXml      +='<confirmacao integrado="false" mensagem="Erro: ' + cAux + '" data="' + DtoS(Date()) + '" hora="' + Time() + '"/>'
        cXml      +='</confirmacao>'		
		cXml      +='</retorno>'
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