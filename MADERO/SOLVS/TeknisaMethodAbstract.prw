#include 'protheus.ch'           
/*-----------------+---------------------------------------------------------+
!Nome              ! TeknisaMethodAbstract                                   !
+------------------+---------------------------------------------------------+
!Descrição         ! Clase abstrato para envio de WS                         !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
class TeknisaMethodAbstract from LongClassName

	data cMethod
	data cAlias
	data cAlRot
	data cMetEnv
	data oEventLog
	data aKeys
	data aLotes
	data nLimite
	data oConexao

	method new() constructor
	method init(cMethod, cAlias, cMetEnv, oEventLog)
	method isEnable()
	method makeXml()
	method getMethod()
	method getMetEnv() 
	method clear()
	method fetch()     
	method prepare()
	method push()
	method pushGet(aChEnv)
	method analiseAll(cXml)
	method analise(oXmlItem,lNewReg)
	method send()
	method sendGet() 
	method tag(cTag,xValor,cTipo)
	method Integrado(cValid, cTipo, cMsg)

endclass


/*-----------------+---------------------------------------------------------+
!Nome              ! TeknisaMethodAbstract                                   !
+------------------+---------------------------------------------------------+
!Descrição         ! Obriga Inicilizr na classe de cada WS                   !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
method new() class TeknisaMethodAbstract

	UserException("Classe abstrata não pode ser instanciada, apenas herdada.")

return


/*-----------------+---------------------------------------------------------+
!Nome              ! makeXml                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Obriga  gerar o XML na classe de cada WS                !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
method makeXml() class TeknisaMethodAbstract

	UserException("Metodo 'makeXml' abstrato, implemente na classe.")

return


/*-----------------+---------------------------------------------------------+
!Nome              ! init                                                    !
+------------------+---------------------------------------------------------+
!Descrição         ! Metodo para inicializar as variaveis da classe          !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
method init(cMethod, cMetEnv, cAlias, cAlRot, oEventLog) class TeknisaMethodAbstract
::cMethod	:= cMethod
::cAlias	:= cAlias
::cAlRot	:= cAlRot
::cMetEnv	:= cMetEnv  
::oEventLog := oEventLog

	::oConexao := TeknisaConexao():new(,cMethod, cMetEnv, oEventLog)

	::nLimite := 999999999 //SuperGetMV("MD_LIMITWS",.F.,10)

	::clear()

return


/*-----------------+---------------------------------------------------------+
!Nome              ! isEnable                                                    !
+------------------+---------------------------------------------------------+
!Descrição         ! Metodo para posicionar na unidade de negócio            !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
method isEnable() class TeknisaMethodAbstract
Local lIsEnable:= ::oConexao:isEnable()
Local cLogAux  := "" 

	// -> Verifica a conexao
	If lIsEnable 
		// -> Posiciona na unidade de negocio correspondente do Madero
		dbSelectArea("ADK")
		ADK->( dbOrderNickName("ADKXFILI") )    
		ADK->( dbGoTop() )
		If !ADK->(dbSeek(xFilial("ADK")+cFilAnt))
		   	lIsEnable := .F.
	   		cLogAux   := "Filial "+cFilAnt+" nao encontrada no cadastro de unidades de negocio."
		   	::oEventLog:SetAddInfo(cLogAux,"Erro na validacao da empresa.")
		   	ConOut("Erro na validacao da empresa: "+cLogAux)
		ElseIf AllTrim(Upper(::cMethod)) <> "PUTUNIDADE"		
			// -> Verifica se a empresa e filial do Teknisa foram informadas no cadastro de unidades
			If AllTrim(ADK->ADK_XEMP) == "" .or. AllTrim(ADK->ADK_XFIL) == ""
				lIsEnable := .F.			
				cLogAux   := "Empresa e/ou filial do Teknisa nao informada(s) no cadastro de unidades de negocio."
				::oEventLog:SetAddInfo(cLogAux,"Erro na validacao da empresa.")
				ConOut("Erro na empresa: "+cLogAux)
			EndIf
		EndIf
	Else
		cLogAux:= "Erro de conexao para a filial "+cFilAnt+"."
	   	::oEventLog:SetAddInfo(cLogAux,"Erro de conexao.")
	   	ConOut(cLogAux)
	EndIf


return lIsEnable	


/*-----------------+---------------------------------------------------------+
!Nome              ! clear                                                   !
+------------------+---------------------------------------------------------+
!Descrição         ! Metodo para limpar dados                                !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
method clear() class TeknisaMethodAbstract
	::aKeys    := {}
return



/*-----------------+---------------------------------------------------------+
!Nome              ! getMethod                                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Metodo para retornar o metodo executado                 !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
method getMethod() class TeknisaMethodAbstract
return ::cMethod


/*-----------------+---------------------------------------------------------+
!Nome              ! getMetEnv                                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Metodo para retornar o metodo de envio                  !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
method getMetEnv() class TeknisaMethodAbstract
return ::cMetEnv



/*-----------------+---------------------------------------------------------+
!Nome              ! fetch                                                   !
+------------------+---------------------------------------------------------+
!Descrição         ! Executa consulta generica para selecionar dadoa a enviar!
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
method fetch() class TeknisaMethodAbstract
Local cQuery	:= ''
Local cPreRot	:= If(Len(PrefixoCpo(::cAlRot)) == 2,"S" + PrefixoCpo(::cAlRot), PrefixoCpo(::cAlRot))
Local cPreAli	:= If(Len(PrefixoCpo(::cAlias)) == 2,"S" + PrefixoCpo(::cAlias), PrefixoCpo(::cAlias))
Local cErrorLog := ""
	
	cErrorLog:=": Selecionando dados na tabela "+RetSqlName(::cAlias)+"..." 
	::oEventLog:SetAddInfo(cErrorLog,"Pesquisando dados.")
	ConOut(cErrorLog)

	cQuery += "	SELECT " + CRLF
	cQuery += "		" + cPreRot + ".R_E_C_N_O_ ROT_REG, " + CRLF	//Recno da tabela Principal
	cQuery += "		" + cPreAli + ".R_E_C_N_O_ ALI_REG " + CRLF		//Recno da tabela Auxiliar
	cQuery += "	FROM " + RetSqlName(::cAlias) + " " + cPreAli + " " + CRLF
	cQuery += "	LEFT JOIN " + RetSqlName(::cAlRot) + " " + cPreRot + " ON " + CRLF
	
	If ::cMethod == "PutProdutos"
		cQuery += "		 	" + PrefixoCpo(::cAlRot) + "_COD    = " + PrefixoCpo(::cAlias) + "_COD " + CRLF
		cQuery += "		AND " + cPreRot + ".D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "	WHERE  	" + CRLF
		cQuery += "			" + PrefixoCpo(::cAlRot) + "_FILIAL = "+ PrefixoCpo(::cAlias) +"_XFILI " + CRLF
		cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XFILI  = '" +cFilAnt + "'" 				 + CRLF
	Else
		cQuery += "			" + PrefixoCpo(::cAlRot) + "_FILIAL = '" + xFilial(::cAlRot) + "' AND " + CRLF
		cQuery += "		 	" + PrefixoCpo(::cAlRot) + "_COD    = " + PrefixoCpo(::cAlias) + "_COD " + CRLF
		cQuery += "		AND " + cPreRot + ".D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "	WHERE  	" + CRLF
		cQuery += "			" + PrefixoCpo(::cAlias) + "_FILIAL = '" + xFilial(::cAlias) + "' " + CRLF
	Endif
	
	If Upper(::cMetEnv) == "POST"
		cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XSTINT IN ('P','E') " + CRLF
		cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XDINT   = ' '       " + CRLF
		cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XEXC   != 'S'       " + CRLF
	ElseIf Upper(::cMetEnv) == "PUT"
		cQuery += "		AND	" + PrefixoCpo(::cAlias) + "_XSTINT IN ('P','E') " + CRLF
		cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XDINT  != ' '       " + CRLF
		cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XEXC   != 'S'       " + CRLF
	ElseIf Upper(::cMetEnv) == "DELETE"
		cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XSTINT IN ('P','E') " + CRLF
		cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XEXC = 'S'          " + CRLF
	EndIf
	
	cQuery += "		AND " + cPreAli + ".D_E_L_E_T_ = ' ' " + CRLF

	MemoWrite("C:\TEMP\" + ::cMethod + "_" + ::cMetEnv + ".sql",cQuery)

	cQuery := ChangeQuery(cQuery)

return MPSysOpenQuery(cQuery)


/*-----------------+---------------------------------------------------------+
!Nome              ! prepare                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Monta dados para engera lotes de envio                  !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
method prepare() class TeknisaMethodAbstract
Local cAlias   := ::fetch()
Local cErrorLog:= ""
Local nCont    := 0

	::aLotes := {}

	While ! (cAlias)->( Eof() )

		nCont:=nCont+1
				
		IF Len(::aLotes) == 0 .Or. len(::aLotes[len(::aLotes)]) >= ::nLimite
			aAdd(::aLotes, {})
		EndIF

		aAdd( ::aLotes[len(::aLotes)], {(cAlias)->ROT_REG, (cAlias)->ALI_REG} )	//[01] = Tabela Principal | [02] = Tabela Auxiliar|

		(cAlias)->( dbSkip() )
	EndDo

	(cAlias)->( dbCloseArea() )
	
	::oEventLog:setCountTot(nCont)
	cErrorLog:=": "+AllTrim(Str(nCont))+" item(ns) selecionado(s)."
	::oEventLog:SetAddInfo(cErrorLog,"Pesquisando dados.")
	ConOut(cErrorLog)

return len(::aLotes) > 0



/*-----------------+---------------------------------------------------------+
!Nome              ! push                                                    !
+------------------+---------------------------------------------------------+
!Descrição       ! Efetua a transmissão dos metodos Post, Put e Delete    !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
method push(aLote) class TeknisaMethodAbstract
Local cXml
Local cErrorLog := ""
	
	cErrorLog:=": Conectando..." 
	::oEventLog:SetAddInfo(cErrorLog,"Conectando.")
	ConOut(cErrorLog)

	//verifica se a integração esta habilitada no teknisa
	If ::oConexao:isEnable()

		//seta o method que vamos usar
		::oConexao:setMethod(::cMethod)

		//cria o XML para envio
		cXml := ::makeXml(aLote,::cMetEnv)

		cErrorLog:=": Enviando XML..." 
		::oEventLog:SetAddInfo(cErrorLog,"Enviando dados.")
		ConOut(cErrorLog)

		If AllTrim(cXml) <> ""
		
			//salva o XML no log
			::oEventLog:setXmlEnv(cXml) 
        
			If ::oConexao:send( cXml )

				//pega o xml Retorno
				cXml := ::oConexao:getResult()
	
				//salva XML no LOG
				If !(AllTrim(::cMethod) $ "GetVenda")
					::oEventLog:setAddXmlRet(cXml)
				EndIf	

				cErrorLog:=": Processando XML..." 
					::oEventLog:SetAddInfo(cErrorLog,"Retorno dos dados.")
				ConOut(cErrorLog)
				
				//tratamento o retorno
				::analiseAll(cXml)

			Else

				cErrorLog:="Falha de conexao:"+::oConexao:GetError() + " em " + ::oConexao:getUrl()
				::oEventLog:SetAddInfo(cErrorLog,"Falha na conexao.")
				ConOut("Falha na conexao: "+cErrorLog)

			EndIF
			
		EndIf	

	Else
	
		cErrorLog:="Sem conexao com a filial "+cFilAnt
		::oEventLog:SetAddInfo(cErrorLog,"Falha na conexao.")
		ConOut("Falha na conexao: "+cErrorLog)
	
	EndIF

return



/*-----------------+---------------------------------------------------------+
!Nome              ! pushGet                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Efetua a transmissão dos metodos Get                 !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
method pushGet(aChEnv) class TeknisaMethodAbstract
Local cXml		:= Nil
Local lOk		:= .T.

	//verifica se a integracao esta habilitada no teknisa
	IF ::oConexao:isEnable()

		//seta o method que vamos usar
		::oConexao:setMethod(::cMethod)    
		
		IF ::oConexao:send(aChEnv)

			//pega o xml Retorno
			cXml := ::oConexao:getResult()
			
			//salva XML no LOG    
			If AllTrim(::cMethod) == "GetPedidos"
				::oEventLog:setAddXmlRet(cXml)
			EndIf	

			//tratamento o retorno
			lOk := ::analiseAll(cXml)
						
		Else

			::oEventLog:SetAddInfo(::oConexao:GetError() + " em " + ::oConexao:getUrl(),"Falha na conexao.")

		EndIF

	EndIF

return {lOk,cXml}



/*-----------------+---------------------------------------------------------+
!Nome              ! analiseAll                                              !
+------------------+---------------------------------------------------------+
!Descrição       ! Efetua a validação e envio de cada item                 !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
method analiseAll(cXml) class TeknisaMethodAbstract
Local nItem
Local lOk 	 := .T.	//Utilizado nos metodos Get
Local lNewReg:= .T.
Private oXml := ::oConexao:xmlParse(cXml)

	do case

		case type("oXml:_RETORNOS:_RETORNO") == "O"
			lOk := ::analise(oXml:_RETORNOS:_RETORNO,lNewReg)

		case type("oXml:_RETORNOS:_RETORNO") == "A"
			lNewReg:=.T.
			For nItem := 1 to len(oXml:_RETORNOS:_RETORNO)
				lOk := ::analise(oXml:_RETORNOS:_RETORNO[nItem],lNewReg)
				lNewReg:=.F.
			Next nItem

	endCase

return lOk


/*-----------------+---------------------------------------------------------+
!Nome              ! analise                                                 !
+------------------+---------------------------------------------------------+
!Descrição       ! Obriga a criação do método na classe individual de cada ! 
!                  ! WS                                                      !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
method analise(oXmlItem,lNewReg) class TeknisaMethodAbstract
Local lOk := .T.
Private oItem := oXmlItem
    
	UserException("Metodo 'analise' abstrato, implemente na classe.")

return(lOk)


/*-----------------+---------------------------------------------------------+
!Nome              ! send                                                    !
+------------------+---------------------------------------------------------+
!Descrição         ! Trasmnite cada lote individualmente para os metodos   ! 
!                  ! Post, Put e Delete                                      !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
method send() class TeknisaMethodAbstract

	Local nC

	For nC := 1 to len(::aLotes)
		::push(::aLotes[nC])
	Next

return


/*-----------------+---------------------------------------------------------+
!Nome              ! sendGet                                                 !
+------------------+---------------------------------------------------------+
!Descrição        ! Trasmnite cada lote individualmente para o metodo Get  ! 
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
method sendGet(aChEnv) class TeknisaMethodAbstract
Local cXml	:= ""
Local aRet 	:= {,}
 
	aRet := ::pushGet(aChEnv)

return aRet



/*-----------------+---------------------------------------------------------+
!Nome              ! tag                                                     !
+------------------+---------------------------------------------------------+
!Descrição       ! Converte em YMA tag os dados recebidos                  ! 
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
method tag(cTag,xValor,cTipo) class TeknisaMethodAbstract
Default cTipo := "string"

	If ValType(xValor) == "C"
		xValor := AllTrim(xValor)
	EndIf

Return WSSoapValue(cTag,xValor,xValor,cTipo,.F.,.F.,2,NIL,.F.)




/*-----------------+---------------------------------------------------------+
!Nome              ! Integrado                                               !
+------------------+---------------------------------------------------------+
!Descrição       ! Executa validos no XML de retorno dos metodos Get       ! 
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
method Integrado(cValid,cTipo,cMsg) class TeknisaMethodAbstract
Local lRet   := .T.
Local cLog   := ""	                   
                                     
	If !Empty(cTipo)
		If cTipo == "U"
			If Type(cValid) == cTipo
				cLog := cMsg 
				lRet := .F.
			EndIf		
		Else
			If !ValType(&cValid) == cTipo
				cLog := cMsg 
				lRet := .F.
			EndIf
		EndIf
	Else
		If Empty(&cValid)
		cLog := cMsg
			lRet := .F.		
		EndIf
	EndIf
                               
    If AllTrim(cLog) <> ""
   	    ::oEventLog:SetAddInfo(cLog,"")
   	EndIf    

Return lRet