#Include 'Protheus.ch'

/*/{Protheus.doc} MA416COR
//TODO Alterar cores do browse do cadastro.
Este ponto de entrada pertence à rotina de baixa de orçamentos de venda, MATA416(). 
Usado para alterar cores do “browse” do cadastro, que representam o “status” do orçamento.
@author Reinaldo Santos
@since 13/04/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function MA416COR()

	Local aNovCor :=  {}

	aNovCor := {{ "SCJ->CJ_STATUS=='A'  .and. SCJ->CJ_XAPROVA == '1' " , "BR_AZUL"   },;//Pendente de aprovação no Fluig
				{ "SCJ->CJ_STATUS=='A'  .and. SCJ->CJ_XAPROVA == '2' " , "ENABLE"    },; //Aprovado pelo Fraqeuado (FLUIG)
				{ "SCJ->CJ_STATUS=='A'  .and. SCJ->CJ_XAPROVA == '3' " , "BR_LARANJA"},; //Cancelado pelo Franqueado (FLUIG)
				{ 'SCJ->CJ_STATUS=="B"' , 'DISABLE'},;		//Orcamento Baixado
				{ 'SCJ->CJ_STATUS=="C"' , 'BR_PRETO'},;		//Orcamento Cancelado
				{ 'SCJ->CJ_STATUS=="D"' , 'BR_AMARELO'},;	//Orcamento nao Orcado
				{ 'SCJ->CJ_STATUS=="F"' , 'BR_MARROM' }}	//Orcamento bloqueado

Return aNovCor