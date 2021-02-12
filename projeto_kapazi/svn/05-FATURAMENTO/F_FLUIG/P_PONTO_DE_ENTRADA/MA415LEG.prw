#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} MA415LEG
//TODO Alterar textos da legenda de status do orçamento.
Este ponto de entrada pertence à rotina de atualização de orçamentos de venda, MATA415(). 
Usado, em conjunto com o ponto MA415COR,  para alterar os textos da legenda, que 
representam o “status” do orçamento.
@author Reinaldo Santos
@since 13/04/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function MA415LEG()

 aLegenda := { 	{ "BR_AZUL" 	,"Pendente de aprovação no Fluig." },;
 				{ "BR_LARANJA" 	,"Cancelado pelo Franqueado via FLUIG." },;
 				{ "ENABLE" 		,"Aprovado pelo Franqueado via FLUIG." },;
 				{ "DISABLE" 	,"Orcamento Baixado." },;
 				{ "BR_PRETO" 	,"Orcamento Cancelado.'" },;
 				{ "BR_AMARELO" 	,"Orcamento nao Orcado." },;
               	{ "BR_MARROM"	,"Orcamento bloqueado." } }
		       
Return aLegenda

