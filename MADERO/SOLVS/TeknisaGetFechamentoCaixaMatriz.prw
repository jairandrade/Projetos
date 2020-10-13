#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} TkGetFec
//TODO Fun��o para chamar Ws GetFechamentoCaixaMatriz via menu
@author Marcos Aur�lio Feij�
@since 27/07/2018
@version 1.0
/*/
User Function TkGetFec(lBatch,dCaixa)
Private cPerg := padr("TkGetFec",10)
Default lBatch:= .F.             
Default dCaixa:= CtoD("  /  /  ")


	// -> Se n�o for executado por job
	If! lBatch
		U_CRSX03MD()
		if !Pergunte(cPerg,.T.)
			Return
		EndIf
		If !Empty(MV_PAR01)
			TkFec(DtoS(MV_PAR01))
		EndIf
    EndIf

    // -> Se n�o for executado por job
	
	If lBatch .And. !Empty(dCaixa)
		TkFec(DtoS(dCaixa))
	EndIf
	
return


/*/{Protheus.doc} TkPed
//TODO Executa o Ws GetFechamentoCaixaMatriz
@author Marcos Aur�lio Feij�
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
@author Marcos Aur�lio Feij�
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
@author Marcos Aur�lio Feij�
@since 27/06/2018
@version 1.0
@return ${return}, ${return_description}
@param cMethod, characters, Metodo a ser executado
@param cMetEnv, characters, Metodo de Envio
@param cAlias, characters, Alias da tabela tenpor�ria
@param cAlRot, characters, Alias da tabela pricipal
/*/
method new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog) class TeknisaGetFechamentoCaixaMatriz
    ::oEventLog := oEventLog 
	::init(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)
	
return


/*/{Protheus.doc} analise
//TODO Metodo para analisar retorno do WS
@author Marcos Aur�lio Feij�
@since 27/06/2018
@version 1.0
@param oXmlItem, object, descricao
/*/
method analise(oXmlItem) class TeknisaGetFechamentoCaixaMatriz

	Local lOk		:= .T.
	Local cMsgAux	:= ""

	//para poder usar fun��o type
	Private oItem := oXmlItem
		
	//Valida se houve retorno v�lido
	If ValType(oItem) == "O"
	                                 
		If Upper(oItem:_CONFIRMACAO:_INTEGRADO:TEXT) == "TRUE"
	
	
			IF lOk
			
				//Verifica data caixa e caixa
				lOk := lOk .And. ::Integrado("oItem:_ID:_CDCAIXA:TEXT"		,"U","Erro na estrutura do XML: Tag C�digo do Caixa Teknisa inexistente")
				lOk := lOk .And. ::Integrado("oItem:_ID:_DTENTRVENDA:TEXT"	,"U","Erro na estrutura do XML: Tag C�digo da Data do Caixa Teknisa inexistente")			
	
				If lOk
						
					//Valida Empresa e Filial
					lOk := lOk .And. ::Integrado("oItem:_ID:_CDEMPRESA:TEXT"	,"U","Erro na estrutura do XML: Tag C�digo da Empresa Teknisa inexistente")
					lOk := lOk .And. ::Integrado("oItem:_ID:_CDFILIAL:TEXT"		,"U","Erro na estrutura do XML: Tag C�digo da Filial Teknisa inexistentea")	
					
					If lOk
						
						//Valida conteudo dos campos
						lOk := lOk .And. ::Integrado("oItem:_ID:_CDEMPRESA:TEXT"	,"","C�digo da Empresa Teknisa inv�lido")
						lOk := lOk .And. ::Integrado("oItem:_ID:_CDFILIAL:TEXT"		,"","C�digo da Filial Teknisa inv�lido")
						lOk := lOk .And. ::Integrado("oItem:_ID:_CDCAIXA:TEXT"		,"","C�digo do Caixa Teknisa inv�lido")
						lOk := lOk .And. ::Integrado("oItem:_ID:_DTENTRVENDA:TEXT"	,"","C�digo da Data do Caixa Teknisa inv�lido")
						
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