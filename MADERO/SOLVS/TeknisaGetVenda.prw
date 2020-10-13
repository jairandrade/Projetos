#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} TkGetVda
//TODO Função para executa o metodo GetVenda
@author Mario L. B. Faria
@since 16/05/2018
@version 1.0
@param cExp01, characters, Codigo da filial Teknisa
@param cExp02, characters, Código do caixa Teknisa
@param cExp03, characters, Sequencia de venda Teknisa
/*/
User Function TkGetVda(cExp01,cExp02,cExp03,cExp04,oEventLog)

	Local oIntegra
	Local cMethod	:= "GetVenda"
	Local cMetEnv	:= "Get"
	Local cAlias	:= ""
	Local cAlRot	:= ""
	Local lOk		:= .T.
	Local aRet 		:= {,}
	
	Private cCdFil	:= cExp01
	Private cCaixa	:= cExp02
	Private cSeqVd	:= cExp03
	Private cEntreg := cExp04
	                                         
	// -> Atualiza LOG
	oEventLog:setAddInfo("", "Iniciando processo de integracao: Vendas...")
	
	//instancia a classe
	oIntegra := TeknisaGetVendas():new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)

	//se estiver ativo
	IF oIntegra:isEnable()

		aRet := oIntegra:sendGet()

	EndIF
	
	oIntegra := Nil

return aRet	//cXmlRet


/*/{Protheus.doc} TeknisaGetPedidos
//TODO Clasee contrutora do metodo GetVendas
@author Mario L. B. Faria
@since 16/05/2018
@version 1.0
/*/
class TeknisaGetVendas from TeknisaMethodAbstract
data oEventLog

	method new() constructor
	method analise(oXmlItem)
	
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
method new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog) class TeknisaGetVendas
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
method analise(oXmlItem) class TeknisaGetVendas
Local lOk		:= .T.
Local nItem		:= 0
	
	//para poder usar função type
	Private oItem := oXmlItem
		
	//Valida se houve retorno válido
	If ValType(oItem) == "O"
	
		If Upper(oItem:_CONFIRMACAO:_INTEGRADO:TEXT) == "TRUE"
	
			//Verifica Sequencia e caixa
			lOk := lOk .And. ::Integrado("oItem:_CABECALHO:_ID:_CDCAIXA:TEXT"		,"C","Erro na estrutura do XML: Tag Código do Caixa Teknisa inexistente")
			lOk := lOk .And. ::Integrado("oItem:_CABECALHO:_ID:_NRSEQVENDA:TEXT"	,"C","Erro na estrutura do XML: Tag Código da Sequencia de Venda Teknisa inexistente")
			
			If lOk			
								        
				ConOut(AllTrim(oItem:_CABECALHO:_ID:_NRSEQVENDA:TEXT)+"-"+AllTrim(oItem:_CABECALHO:_ID:_CDCAIXA:TEXT)+": Validando XML da Venda...")
				::oEventLog:SetAddInfo(AllTrim(oItem:_CABECALHO:_ID:_NRSEQVENDA:TEXT)+"-"+AllTrim(oItem:_CABECALHO:_ID:_CDCAIXA:TEXT)+": Validando XML da Venda...","")
				
				//Valida Empresa e Filial
				lOk := lOk .And. ::Integrado("oItem:_CABECALHO:_ID:_CDEMPRESA:TEXT"		,"C","Erro na estrutura do XML: Tag Código da Empresa Teknisa inexistente")
				lOk := lOk .And. ::Integrado("oItem:_CABECALHO:_ID:_CDFILIAL:TEXT"		,"C","Erro na estrutura do XML: Tag Código da Filial Teknis inexistentea")
			
				If lOk
			
					//Verifica tags obrigatorias
					lOk := lOk .And. ::Integrado("oItem:_CABECALHO:_VENDA"	,"U","Erro na estrutura do XML: Tag Cabeçalho inexistente")
					lOk := lOk .And. ::Integrado("oItem:_CONSUMIDOR"		,"U","Erro na estrutura do XML: Tag Consumidor inexistente")
					lOk := lOk .And. ::Integrado("oItem:_ITENS"				,"U","Erro na estrutura do XML: Tag Itens inexistente")
						
					If lOk	
						
				 		//Valida conteudo dos campos
						lOk := lOk .And. ::Integrado("oItem:_CABECALHO:_ID:_CDEMPRESA:TEXT"		,"","Código da Empresa Teknisa inválido")
						lOk := lOk .And. ::Integrado("oItem:_CABECALHO:_ID:_CDFILIAL:TEXT"		,"","Código da Filial Teknisa inválido")
						lOk := lOk .And. ::Integrado("oItem:_CABECALHO:_ID:_CDCAIXA:TEXT"		,"","Código da Filial Teknisa inválido")
						lOk := lOk .And. ::Integrado("oItem:_CABECALHO:_ID:_NRSEQVENDA:TEXT"	,"","Código da Sequencia de Venda Teknisa inválido")
	
						// If ValType(oItem:_ITENS:_PRODUTO) == "A"			
						// 	For nItem := 1 to Len(oItem:_ITENS:_PRODUTO)
						// 		lOk := lOk .And. ::Integrado("oItem:_ITENS:_PRODUTO["+ cValToChar(nItem) +"]:_NRSEQITVEND:TEXT"	,"","XML não possui Sequencia de item.")
						// 		lOk := lOk .And. ::Integrado("oItem:_ITENS:_PRODUTO["+ cValToChar(nItem) +"]:_QTPRODVEND:TEXT"	,"","XML não possui Quantidade de Venda.")
						// 		lOk := lOk .And. ::Integrado("oItem:_ITENS:_PRODUTO["+ cValToChar(nItem) +"]:_VRUNITVEND:TEXT"	,"","XML não possui valor Unitário.")
						// 		lOk := lOk .And. ::Integrado("oItem:_ITENS:_PRODUTO["+ cValToChar(nItem) +"]:_CDPRODUTO:TEXT"	,"","XML não possui Código do Produto.")						
					 	// 	Next nItem
						// Else
			
						// 	lOk := lOk .And. ::Integrado("oItem:_ITENS:_PRODUTO:_NRSEQITVEND:TEXT"	,"","XML não possui Sequencia de item.")
						// 	lOk := lOk .And. ::Integrado("oItem:_ITENS:_PRODUTO:_QTPRODVEND:TEXT"	,"","XML não possui Quantidade de Venda.")
						// 	lOk := lOk .And. ::Integrado("oItem:_ITENS:_PRODUTO:_VRUNITVEND:TEXT"	,"","XML não possui valor Unitário.")
						// 	lOk := lOk .And. ::Integrado("oItem:_ITENS:_PRODUTO:_CDPRODUTO:TEXT"	,"","XML não possui Código do Produto.")
						// EndIf
					
						lOk := lOk .And. ::Integrado("oItem:_CONSUMIDOR:_CDCLIENTE:TEXT"	,"","XML não possui cliente válido.")			
						
						
					Else
					
						::oEventLog:SetAddInfo("Erro: Estrutura do XML da venda: Tag VENNDA, CONSUMIDOR ou ITEM inexistentes.","")
						ConOut("Erro: Estrutura do XML da venda: Tag VENNDA, CONSUMIDOR ou ITEM inexistentes.")
						lOk := .F.				
					
					EndIf	
							
				Else

					::oEventLog:SetAddInfo("Erro: Estrutura do XML da venda: Tag CDEMPRESA ou CDFILIAL inexistentes.","")
					ConOut("Erro: Estrutura do XML da venda.")
					lOk := .F.				

				EndIf
				
			Else

				::oEventLog:SetAddInfo("Erro: Estrutura do XML da venda: Tag CDCAIXA ou NRSEQVENDA inexistente.","")
				ConOut("Erro: Estrutura do XML da venda: Tag CDCAIXA ou NRSEQVENDA inexistente.")
				lOk := .F.				

			EndIf	
		
		Else
		
			::oEventLog:SetAddInfo("Erro:" + oItem:_CONFIRMACAO:_MENSAGEM:TEXT,"")
			ConOut("Erro:" + oItem:_CONFIRMACAO:_MENSAGEM:TEXT)
			lOk := .F.
		
		EndIf
		
	Else
        
        ::oEventLog:SetAddInfo("Erro: Estrutura do XML da venda: Sem XML","")
        ConOut("Erro: Estrutura do XML da venda: Sem XML")
		lOk := .F.

	EndIf	
	
	IF !lOk                                                                                                       
		ConOut("Erro: Falha no XML da venda.")
		::oEventLog:broken("Erro: Falha no XML da venda.", "", .T.)
	EndIf

return lOk		