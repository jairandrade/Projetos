#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} TkGetPed
//TODO Função para chamar Ws GetPedidos via menu
@author Mario L. B. Faria
@since 16/05/2018
@version 1.0
/*/
User Function TkGetPed(lBatch,dIni,dFim)
Private cPerg := padr("TkGetPed",10)
Private dAux  := CtoD("  /  /  ")
Default lBatch:= .F.             
Default dIni  := CtoD("  /  /  ")
Default dFim  := CtoD("  /  /  ")


	// -> Se não for executado por job
	If! lBatch
		U_CRSX02MD()
		if !Pergunte(cPerg,.T.)
			Return
		EndIf
		TkPed(MV_PAR01,MV_PAR02)
		dAux:=MV_PAR01
		While (dAux <= MV_PAR02) .and. !Empty(dAux)
			TkPed(DtoS(dAux),DtoS(dAux))
			dAux:=dAux+1  
		EndDo
    EndIf

    // -> Se não for executado por job
	
	If lBatch          
		dAux:=dIni
		While (dAux <= dFim) .and. !Empty(dAux)
			TkPed(DtoS(dAux),DtoS(dAux))
			dAux:=dAux+1  
		EndDo
	EndIf
	
return


/*/{Protheus.doc} TkPed
//TODO Executa o Ws GetPedidos
@author Mario L. B. Faria
@since 16/05/2018
@version 1.0
@return ${return}, ${return_description}
@param cMetEnv, characters, descricao
@param cDtIni, characters, descricao
@param cDtFim, characters, descricao
/*/
Static Function TkPed(cDtIni,cDtFim)

	Local oIntegra
	Local cMethod	:= "GetPedidos"
	Local cMetEnv	:= "Get"
	Local cAlias	:= ""
	Local cAlRot	:= ""
	Local cXmlRet	:= ""
	Local lOk		:= .T.
	Local aRet 		:= {,}
	Local oEventLog := EventLog():start("Vendas - Teknisa", StoD(cDtIni), "Iniciando processo de integracao: Pedidos...", cMetEnv, "Z01")
	Private cDataIni := cDtIni
	Private cDataFim := cDtFim
	
	//instancia a classe
	oIntegra := TeknisaGetPedidos():new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)

	//se estiver ativo
	IF oIntegra:isEnable()
		
		//Chama rotina para controlar WS GetVendas
		aRet := oIntegra:sendGet()
		lOk		:= aRet[01]
		cXmlRet := aRet[02]
		
		If lOk
			If !isBlind()
				Processa({ || U_AWS010(cXmlRet,oEventLog),"Aguarde..."}, "Processando Venda...")
			Else
				U_AWS010(cXmlRet,oEventLog)
			EndIf		
		EndIf

	EndIF
	
	oEventLog:Finish()

return


/*/{Protheus.doc} TeknisaGetPedidos
//TODO Clasee contrutora do metodo GetPedidos
@author Mario L. B. Faria
@since 16/05/2018
@version 1.0
/*/
class TeknisaGetPedidos from TeknisaMethodAbstract
data oEventLog

	method new() constructor
	method analise(oXmlItem,oEventLog)

endclass


/*/{Protheus.doc} new
//TODO Inicializador da Classe
@author Mario L. B. Faria
@since 16/05/2018
@version 1.0
@return ${return}, ${return_description}
@param cMethod, characters, Metodo a ser executado
@param cMetEnv, characters, Metodo de Envio
@param cAlias, characters, Alias da tabela tenporária
@param cAlRot, characters, Alias da tabela pricipal
/*/
method new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog) class TeknisaGetPedidos
    ::oEventLog := oEventLog 
	::init(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)
	
return


/*/{Protheus.doc} analise
//TODO Metodo para analisar retorno do WS
@author Mario L. B. Faria
@since 21/05/2018
@version 1.0
@param oXmlItem, object, descricao
/*/
method analise(oXmlItem) class TeknisaGetPedidos

	Local lOk		:= .T.
	Local cMsgAux	:= ""

	//para poder usar função type
	Private oItem := oXmlItem
		
	//Valida se houve retorno válido
	If ValType(oItem) == "O"
	                                 
		If Upper(oItem:_CONFIRMACAO:_INTEGRADO:TEXT) == "TRUE"
	
			cMsgAux:=AllTrim(oItem:_ID:_NRSEQVENDA:TEXT)+"-"+AllTrim(oItem:_ID:_CDCAIXA:TEXT + ": Validando XML do pedido...")
			ConOut(cMsgAux)
			::oEventLog:SetAddInfo(cMsgAux,"")

			IF lOk
			
				//Verifica Sequencia e caixa
				lOk := lOk .And. ::Integrado("oItem:_ID:_CDCAIXA:TEXT"		,"U","Erro na estrutura do XML: Tag Código do Caixa Teknisa inexistente")
				lOk := lOk .And. ::Integrado("oItem:_ID:_NRSEQVENDA:TEXT"	,"U","Erro na estrutura do XML: Tag Código da Sequencia de Venda Teknisa inexistente")			
	
				If lOk
						
					//Valida Empresa e Filial
					lOk := lOk .And. ::Integrado("oItem:_ID:_CDEMPRESA:TEXT"	,"U","Erro na estrutura do XML: Tag Código da Empresa Teknisa inexistente")
					lOk := lOk .And. ::Integrado("oItem:_ID:_CDFILIAL:TEXT"		,"U","Erro na estrutura do XML: Tag Código da Filial Teknisa inexistentea")	
					
					If lOk
						
						//Valida conteudo dos campos
						lOk := lOk .And. ::Integrado("oItem:_ID:_CDEMPRESA:TEXT"	,"","Código da Empresa Teknisa inválido")
						lOk := lOk .And. ::Integrado("oItem:_ID:_CDFILIAL:TEXT"		,"","Código da Filial Teknisa inválido")
						lOk := lOk .And. ::Integrado("oItem:_ID:_CDCAIXA:TEXT"		,"","Código da Filial Teknisa inválido")
						lOk := lOk .And. ::Integrado("oItem:_ID:_NRSEQVENDA:TEXT"	,"","Código da Sequencia de Venda Teknisa inválido")
						
						If !lOk 
					        ::oEventLog:SetAddInfo("Erro: Conteudo das tags CDEMPRESA, CDFILIAL, CDCAIXA ou NRSEQVENDA invalido.","")
					        ConOut("Erro: Conteudo das tags CDEMPRESA, CDFILIAL, CDCAIXA ou NRSEQVENDA invalido.")
						EndIf

					Else
				        ::oEventLog:SetAddInfo("Erro: Estrutura do XML do pedido.","")
				        ConOut("Erro: Estrutura do XML do pedido.")
						lOk := .F.
					EndIf
					
				Else
			        ::oEventLog:SetAddInfo("Erro: Estrutura do XML do pedido.","")
			        ConOut("Erro: Estrutura do XML do pedido.")
					lOk := .F.
				EndIf 	
            
            Else            
		        ::oEventLog:SetAddInfo("Erro: Estrutura do XML do pedido.","")
				ConOut("Erro: Estrutura do XML do pedido.")
				lOk := .F.            
			EndIf
									
		Else
			::oEventLog:SetAddInfo("Erro: "+oItem:_CONFIRMACAO:_MENSAGEM:TEXT,"")
			ConOut("Erro: "+oItem:_CONFIRMACAO:_MENSAGEM:TEXT)
			lOk := .F.		
		EndIf
		
	Else
        ::oEventLog:SetAddInfo("Erro: Estrutura do XML do pedido.","")
        ConOut("Erro: Estrutura do XML do pedido.")
		lOk := .F.
	EndIf	


	IF lOk                                                                                                       
		ConOut("Ok.")
        ::oEventLog:SetAddInfo("Ok.","")
        ::oEventLog:setItensRet()
	Else
		::oEventLog:broken("Falha na integracao do pedido.", "", .T.)
	EndIf
	
return lOk