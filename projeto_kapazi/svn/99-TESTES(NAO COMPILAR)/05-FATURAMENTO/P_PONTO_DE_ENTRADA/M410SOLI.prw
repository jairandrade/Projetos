#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: M410SOLI		|	Autor: Luis Paulo							|	Data: 22/06/2018	//
//==================================================================================================//
//	Descrição: PE para tratar o ICMS-ST da planilha financeira										//
//																									//
//==================================================================================================//
/*
Este ponto de entrada retorna o valor do ICMS Solidario para ser demonstrado na planilha financeira do pedido de vendas.
Para realizar todo o processo corretamente deve utilizar em conjunto com o ponto de entrada M460SOLI com o mesmo tratamento do ponto M410SOLI. 
Para que as informações do pedido de vendas e da nota fiscal de saída fiquem iguais.
*/
/*
aSolid(vetor)
Deve retornar uma array com duas posições:
1ª - Base do ICMS Retido (Solidario)
2ª - Valor do ICMS Retido (Solidario)
Obs.: Caso não seja retornado o array corretamente com a estrutura descrita acima, o programa ira fazer os devidos calculos não considerando o P.E. em questão.
*/
//Chamados
//http://tdn.totvs.com/pages/releaseview.action?pageId=369626048
//http://tdn.totvs.com/display/public/PROT/1843501+DSERFIS2-3011+PE+M410SOLI+SUFRAMA
User Function M410SOLI()
Local aRet		:= {}
Local cItem		:= ICMSITEM 	// variavel para ponto de entrada
Local nQtd		:= QUANTITEM  	// variavel para ponto de entrada
Local nBase		:= BASEICMRET  	// criado apenas para o ponto de entrada
Local nMargem	:= MARGEMLUCR  	// criado apenas para o ponto de entrada
Local nValor	:= 0
Local nItem		:= N

If nBase > 0
	If ISINCALLSTACK('U_PLANFNFM') //Verifica a origem 
		
		If nBase > 0 .And. ValNFM()
			nValor	:= MaFisRet(nItem,"IT_VALSOL")
		EndIf
		
	EndIf
EndIf

Return(aRet)


