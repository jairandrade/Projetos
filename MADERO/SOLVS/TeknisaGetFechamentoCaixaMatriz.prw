#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} TkGetFec
//TODO Função para chamar Ws GetFechamentoCaixaMatriz via menu
@author Marcos Aurélio Feijó
@since 27/07/2018
@version 1.0
/*/
User Function TkGetFec(lBatch,dCaixa)
Private cPerg := padr("TkGetFec",10)
Default lBatch:= .F.             
Default dCaixa:= CtoD("  /  /  ")


	// -> Se não for executado por job
	If! lBatch
		U_CRSX03MD()
		if !Pergunte(cPerg,.T.)
			Return
		EndIf
		If !Empty(MV_PAR01)
			TkFec(DtoS(MV_PAR01))
		EndIf
    EndIf

    // -> Se não for executado por job
	
	If lBatch .And. !Empty(dCaixa)
		TkFec(DtoS(dCaixa))
	EndIf
	
return


/*/{Protheus.doc} TkPed
//TODO Executa o Ws GetFechamentoCaixaMatriz
@author Marcos Aurélio Feijó
@since 27/06/2018
@version 1.0
@return ${return}, ${return_description}
@param cMetEnv, characters, descricao
@param cDtCaixa, characters, descricao
/*/
Static Function TkFec(cDtCaixa)

	Local oIntegra
	Local cMethod	:= "GetFechamentoCaixaMatriz"
	Local cMetEnv	:= "Get"
	Local cAlias	:= ""
	Local cAlRot	:= ""
	Local cXmlRet	:= ""
	Local lOk		:= .T.
	Local aRet 		:= {,}
	Local oEventLog := EventLog():start("Fechamento de Caixa - Teknisa", StoD(cDtCaixa), "Iniciando processo de integracao: Fechamento de Caixa...", cMetEnv, "Z05")
	Private cDataCaixa:= cDtCaixa
	
	//instancia a classe
	oIntegra := TeknisaGetFechamentoCaixaMatriz():new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)

	//se estiver ativo
	IF oIntegra:isEnable()
		
		//Chama rotina para controlar WS GetFechamentoCaixaMatriz
		aRet := oIntegra:sendGet()
		lOk		:= aRet[01]
		cXmlRet := aRet[02]
		
		If lOk
			If !isBlind()
				Processa({ || U_AWS013(cXmlRet,oEventLog),"Aguarde..."}, "Processando Fechamento de Caixa...")
			Else
				U_AWS013(cXmlRet,oEventLog)
			EndIf		
		EndIf

	EndIF
	
	oEventLog:Finish()

return


/*/{Protheus.doc} TeknisaGetFechamentoCaixaMatriz
//TODO Classe contrutora do metodo GetFechamentoCaixaMatriz
@author Marcos Aurélio Feijó
@since 27/06/2018
@version 1.0
/*/
class TeknisaGetFechamentoCaixaMatriz from TeknisaMethodAbstract
data oEventLog

	method new() constructor
	method analise(oXmlItem,oEventLog)

endclass


/*/{Protheus.doc} new
//TODO Inicializador da Classe
@author Marcos Aurélio Feijó
@since 27/06/2018
@version 1.0
@return ${return}, ${return_description}
@param cMethod, characters, Metodo a ser executado
@param cMetEnv, characters, Metodo de Envio
@param cAlias, characters, Alias da tabela tenporária
@param cAlRot, characters, Alias da tabela pricipal
/*/
method new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog) class TeknisaGetFechamentoCaixaMatriz
    ::oEventLog := oEventLog 
	::init(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)
	
return


/*/{Protheus.doc} analise
//TODO Metodo para analisar retorno do WS
@author Marcos Aurélio Feijó
@since 27/06/2018
@version 1.0
@param oXmlItem, object, descricao
/*/
method analise(oXmlItem) class TeknisaGetFechamentoCaixaMatriz

	Local lOk		:= .T.
	Local cMsgAux	:= ""

	//para poder usar função type
	Private oItem := oXmlItem
		
	//Valida se houve retorno válido
	If ValType(oItem) == "O"
	                                 
		If Upper(oItem:_CONFIRMACAO:_INTEGRADO:TEXT) == "TRUE"
	
	
			IF lOk
			
				//Verifica data caixa e caixa
				lOk := lOk .And. ::Integrado("oItem:_ID:_CDCAIXA:TEXT"		,"U","Erro na estrutura do XML: Tag Código do Caixa Teknisa inexistente")
				lOk := lOk .And. ::Integrado("oItem:_ID:_DTENTRVENDA:TEXT"	,"U","Erro na estrutura do XML: Tag Código da Data do Caixa Teknisa inexistente")			
	
				If lOk
						
					//Valida Empresa e Filial
					lOk := lOk .And. ::Integrado("oItem:_ID:_CDEMPRESA:TEXT"	,"U","Erro na estrutura do XML: Tag Código da Empresa Teknisa inexistente")
					lOk := lOk .And. ::Integrado("oItem:_ID:_CDFILIAL:TEXT"		,"U","Erro na estrutura do XML: Tag Código da Filial Teknisa inexistentea")	
					
					If lOk
						
						//Valida conteudo dos campos
						lOk := lOk .And. ::Integrado("oItem:_ID:_CDEMPRESA:TEXT"	,"","Código da Empresa Teknisa inválido")
						lOk := lOk .And. ::Integrado("oItem:_ID:_CDFILIAL:TEXT"		,"","Código da Filial Teknisa inválido")
						lOk := lOk .And. ::Integrado("oItem:_ID:_CDCAIXA:TEXT"		,"","Código do Caixa Teknisa inválido")
						lOk := lOk .And. ::Integrado("oItem:_ID:_DTENTRVENDA:TEXT"	,"","Código da Data do Caixa Teknisa inválido")
						
						If !lOk 
					        ::oEventLog:SetAddInfo("Erro: Conteudo das tags CDEMPRESA, CDFILIAL, CDCAIXA ou DTENTRVENDA invalido.","")
					        ConOut("Erro: Conteudo das tags CDEMPRESA, CDFILIAL, CDCAIXA ou DTENTRVENDA invalido.")
						EndIf

					Else
				        ::oEventLog:SetAddInfo("Erro: Estrutura do XML do fechamento de Caixa.","")
				        ConOut("Erro: Estrutura do XML do fechamento de Caixa.")
						lOk := .F.
					EndIf
					
				Else
			        ::oEventLog:SetAddInfo("Erro: Estrutura do XML do fechamento de Caixa.","")
			        ConOut("Erro: Estrutura do XML do fechamento.")
					lOk := .F.
				EndIf 	
            
            Else            
		        ::oEventLog:SetAddInfo("Erro: Estrutura do XML do fechamento de Caixa.","")
				ConOut("Erro: Estrutura do XML do fechamento de Caixa.")
				lOk := .F.            
			EndIf
									
		Else
			::oEventLog:SetAddInfo("Erro: "+oItem:_CONFIRMACAO:_MENSAGEM:TEXT,"")
			ConOut("Erro: "+oItem:_CONFIRMACAO:_MENSAGEM:TEXT)
			lOk := .F.		
		EndIf
		
	Else
        ::oEventLog:SetAddInfo("Erro: Estrutura do XML do fechamento de Caixa.","")
        ConOut("Erro: Estrutura do XML do fechamento de Caixa.")
		lOk := .F.
	EndIf	


	If lOk
		::oEventLog:setItensRet()
	Else	                                                                                                       
		::oEventLog:broken("Falha na integracao do fechamento de Caixa.", "", .T.)
	EndIf
	
return lOk