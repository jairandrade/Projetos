/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GetAcesso                                                                     !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração do WebService GetAcesso                                            !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
#INCLUDE 'protheus.ch' 
#INCLUDE "restful.ch"
WSRESTFUL GetAcesso DESCRIPTION "Madero - Acesso de Usuários"
	
	WSDATA cdempresa AS STRING
	WSDATA cdfilial  AS STRING
	WSDATA cdmodulo  AS INTEGER
	WSDATA cdusuario AS STRING
	WSDATA rotina    AS STRING

	WSMETHOD GET DESCRIPTION "Acesso de Usuários" WSSYNTAX "/GetAcesso"

End WSRESTFUL



/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GET                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração do Metodo GetAcesso                                                !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                          

WSMETHOD GET WSRECEIVE cdempresa, cdfilial, cdmodulo, cdusuario, rotina  WSSERVICE GetAcesso
Local cXml	    := ""
Local cError	:= ""
Local nThrdID   := ThreadId()
Local xcdempresa:= Self:cdempresa
Local xcdmodulo := Self:cdmodulo
Local xcdusuario:= Self:cdusuario
Local xrotina   := Self:rotina
Local cxNomeFil := ""
Local xcdfilial := Self:cdfilial
Local aModAtivos:= {{2,"COM"},{4,"EST"},{5,"FAT"}}
Local nPosModulo:= 5
Local cCodResp  := ""
Local cNomeResp := ""
Local cEmpProth := ""
Local cFilProth := ""

	::SetContentType("application/xml")
	
	ConOut("GetAcesso: Carregando dicionario de dados...")
	
	If !Empty(Self:cdempresa) .And. !Empty(Self:cdfilial) .And. Self:cdmodulo != 0 .And. !Empty(Self:cdusuario) .And. !Empty(Self:rotina) 
		// -> Verifica se o módulo passado está sendo tratado na função de acesso
		nPosModulo:=aScan(aModAtivos,{|x| AllTrim(Str(x[1])) == AllTrim(Str(xcdmodulo))})
		lCont:=nPosModulo > 0
		If lCont
			// -> Posiciona na unidade de negócio
			DbSelectArea("ADK")
			ADK->(DbOrderNickname("ADKXFIL"))		
			If ADK->(DbSeek(xFilial("ADK")+Self:cdempresa+Self:cdfilial))
			  	cEmpProth:=ADK->ADK_XGEMP
				cFilProth:=ADK->ADK_XFILI
				cxNomeFil:=ADK->ADK_NOME
				cCodResp :=ADK->ADK_RESP
				// -> Carrega o ambiente com os parâmetros passados 
				//RpcClearEnv()
				RPcSetType(3)
				RpcSetEnv(cEmpProth,cFilProth, , ,aModAtivos[nPosModulo,2] , GetEnvServer() )
					OpenSm0(cEmpProth, .f.)
					nModulo:=aModAtivos[nPosModulo,1]
					SM0->(dbSetOrder(1))
					If SM0->(dbSeek(cEmpProth+cFilProth))
						cEmpAnt  := cEmpProth
						cFilAnt  := cFilProth						
						dDataBase:=Date()
						cXml := WSCFG001(Self:cdempresa, Self:cdfilial, cxNomeFil, Self:cdmodulo, Self:cdusuario, Upper(Self:rotina), cCodResp, @cCodResp, @cNomeResp, cEmpAnt, cFilAnt, Self:cdmodulo, Self:cdusuario, Self:rotina, nThrdID)
					Else
						cError:="Filial nao cadastrada no ERP. [ADK_XFILI="+cFilProth+"]"			
					EndIf
				//RpcClearEnv()
			Else
				cError:="Filial nao cadastrada no ERP. [ADK_XEMP="+Self:cdempresa+" e ADK_XFIL="+Self:cdfilial+"]"
			EndIf	
		Else
			cError:="Modulo " + AllTrim(Str(xcdmodulo)) + " passado no parametro cdmodulo nao esta configurado para esta funcao."	
		EndIf	
	Else
		If Empty(Self:cdempresa)
			cError      :="Parametros incorretos. cdempresa eh um parametro obrigatorio."
			xcdempresa:=""
		ElseIf Empty(Self:cdfilial)
			cError     :="Parametros incorretos. cdfilial eh um parametro obrigatorio."
			xcdfilial:=""
		ElseIf Empty(Self:cdmodulo)
			cError     :="Parametros incorretos. cdmodulo eh um parametro obrigatorio."
			xcdmodulo:=0
		ElseIf Self:cdmodulo == 0
			cError := "Parametros incorretos. cdmodulo nao pode ser 0."
		ElseIf Empty(Self:cdusuario)
			cError      :="Parametros incorretos. cdusuario eh um parametro obrigatorio."
           	xcdusuario:=""
		ElseIf Empty(Self:rotina)
			cError   :="Parametros incorretos. rotina eh um parametro obrigatorio."
			xrotina:=""
		EndIf
	Endif

	If !Empty(cError)
		
		cXml := '<?xml version="1.0" encoding="ISO-8859-1"?>'
		
		cXml += '<retorno>'
		
		cXml += '<empresa cdempresa="' + xcdempresa + '" cdfilial="' + xcdfilial + '" nmfilial="' + cxNomeFil + '"/>'
		
		cXml += '<operador cdvendedor="' + cCodResp + '" nmvendedor="' + cNomeResp + '"/>'

		cXml += '<usuario idusuario="' + xcdusuario + '" cdmodulo="' + AllTrim(Str(xcdmodulo)) + '" rotina="' + xrotina + '"/>'

		cXml += '<confirmacao>'

		cXml += '<confirmacao integrado="false" mensagem="' + cError + '" data="' + DtoS(Date()) + '" hora="' + Time() + '"/>'

		cXml += '</confirmacao>'

		cXml += '</retorno>
	EndIf

	::SetResponse(cXml)

Return .T.



/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ProtheusGetAcesso                                                             !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração das classe para gerar o XML                                        !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                          

Class ProtheusGetAcesso From ProtheusMethodAbstract

	Method new(cMethod) constructor
	Method makeXml(aDadUsr)

EndClass



/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! New                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Metodo Inicializados da Classe ProtheusGetAcesso                              !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  

Method New(cMethod) Class ProtheusGetAcesso
	::cMethod := cMethod
Return



/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! makeXml                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Metodo para gerar XML do Ws GetAcesso                                         !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  

Method makeXml(aDadUsr,cCodEmp,cCodFil,cxNomeFil,cCodResp,cNomeResp) Class ProtheusGetAcesso
Local cXml		:= ""
Local cAcesso	:= ""
	
	If ValType(aDadUsr[08]) == "A"
		cAcesso := If(aDadUsr[08,03],"S","N")
	Else
		cAcesso := aDadUsr[08]
	EndIf

	cXml := '<?xml version="1.0" encoding="ISO-8859-1"?>'
	
	cXml += '<retorno>'

	cXml += '<empresa'
	cXml += ::tag('cdempresa'		,cCodEmp)		
	cXml += ::tag('cdfilial'		,cCodFil)	
	cXml += ::tag('nmfilial'		,cxNomeFil)		
	cXml += '/>'
	
	cXml += '<operador'
	cXml += ::tag('cdvendedor'		,cCodResp)	
	cXml += ::tag('nmvendedor'		,cNomeResp)		
	cXml += '/>'

	cXml += '<usuario'	 
	cXml += ::tag('usrativo'		,If(aDadUsr[01],"S","N"))	
	cXml += ::tag('usrlogin'		,aDadUsr[02])		
	cXml += ::tag('idusuario'		,aDadUsr[03])
	cXml += ::tag('nmusuario'		,aDadUsr[04])		
	cXml += ::tag('emailusuario'	,aDadUsr[05])		
	cXml += ::tag('ndiasacesso'		,aDadUsr[06]	,"INTEGER")	
	cXml += ::tag('acessorotina'	,cAcesso)
	
	cXml += '/>'
	
	cXml += '<confirmacao>'
	
	cXml += '<confirmacao'
	cXml += ::tag('integrado'		,"true")			
	cXml += ::tag('mensagem'		,"Acesso ok.")
	cXml += ::tag('data'			,DtoS(Date()))		
	cXml += ::tag('hora'			,Time())	
	cXml += '/>'
	
	cXml += '</confirmacao>'

	cXml += '</retorno>'	

Return cXml




/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! WSCFG001                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para executar WS GetAcesso                                             !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
Static Function WSCFG001(cCodEmp, cCodFil, cxNomeFil, nCodMod, cNomeUsr, cRotina, cResp, cCodResp, cNomeResp, cEmpProth, cFilProth, cdmodulo, cdusuario, rotina, nThrdID)
Local cError    := ""
Local cXml		:= ""
Local lCont		:= .T.
Local oTag		:= Nil
Local aDadUsr	:={}	
Local cMetEnv	:= "Get"
Local cMethod	:= "GetAcesso"
Local oEventLog := Nil
	
	// -> Inicializa o Log
	oEventLog := EventLog():start(cMethod + "-" + cMetEnv,Date(), "Iniciando processo de integracao: ", cMetEnv, "")	
	
	// -> Se não deu erro, continua
	If lCont 
		// -> Busca acessos
		aDadUsr := U_xGetAces(nCodMod,cNomeUsr,cRotina,oEventLog)
		If aDadUsr[07]
			If !VerResp(cResp,@cCodResp,@cNomeResp,@cError)
				cError := cError
				oEventLog:broken(cError, "", .T.)
			EndIf	
		Else
			cError := aDadUsr[09]
			lCont  := .F.
		EndIf
		
	EndIf
				
	If lCont
		oTag   := ProtheusGetAcesso():New("Tag")
		cXml   := oTag:MakeXml(aDadUsr,cCodEmp,cCodFil,cxNomeFil,cCodResp,cNomeResp)
		cError := aDadUsr[09]
		oEventLog:setInfo("Ok.", "")
	Else	

		cXml := '<?xml version="1.0" encoding="ISO-8859-1"?>'

		cXml += '<retorno>'

		cXml += '<empresa cdempresa="' + cCodEmp + '" cdfilial="' + cCodEmp + '" nmfilial="' + cxNomeFil + '"/>'
		
		cXml += '<operador cdvendedor="' + cCodResp + '" nmvendedor="' + cNomeResp + '"/>'

		cXml += '<usuario cdusuario="' + cdusuario + '" cdmodulo="' + AllTrim(Str(cdmodulo)) + '" rotina="' + rotina + '"/>'

		cXml += '<confirmacao>'

		cXml += '<confirmacao integrado="' + If(lCont,"true","false") + '" mensagem="' + cError + '" data="' + DtoS(Date()) + '" hora="' + Time() + '"/>'

		cXml += '</confirmacao>'

		cXml += '</retorno>'

		oEventLog:broken("--> Erro na consulta dos usuários.", "", .T.)
	EndIf
	
	oEventLog:Finish()

Return cXml


/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! VerResp                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para validar e posicionar responsavel da filial                        !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/  
Static Function VerResp(cResp,cCodResp,cNomeResp,cError)
Local lRet	  :=.T.
Local aAreaADK:=GetArea()

	// -> Verifica registro na tabela de vendedores
	DbSelectArea("SA3")
	SA3->(DbSetOrder(1))
	SA3->(DbSeek(xFilial("SA3")+cResp))	

	// -> Verifica se existe o registro na SD3
	If SA3->(Found())
		cCodResp :=SA3->A3_COD
		cNomeResp:=SA3->A3_NOME
		If SA3->A3_MSBLQL == "1"
			cError:="Responsavel " + cCodResp + " - " + AllTrim(cNomeResp) + " esta bloqueado."
			lRet  :=.F.
		EndIf	
	Else
		cError:="Responsavel " + cResp + " nao encontrado na tabela SA3."
		lRet  :=.F.
	EndIf

	RestArea(aAreaADK)

Return lRet