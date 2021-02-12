#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: MT103FDV		|	Autor: Luis Paulo							|	Data: 17/10/2019	//
//==================================================================================================//
//	Descrição: Este ponto de entrada é executado na avaliacao do SD2 para devolucao do documento de //
// 	saida. ( Botao Retornar )																		//
//																									//
//==================================================================================================//
User Function MT103FDV()
Local aArea 	:= GetArea()
Local aVetPar	:= PARAMIXB[1]		//cAliasSD2
Local lExpL1	:= .T.
Local lFlagDev	:= SuperGetMv("MV_FLAGDEV",.F.,.F.) 
Local lAtvDesb	:= SuperGetMv("KP_DESBDEV",.F.,.T.)

If !lFlagDev .And. lAtvDesb .And. cEmpAnt == "04" //Nao tem flag de retorno(Conferir o parametro)
	If Type("_aATItDV") == "U" 
			Public _aATItDV	:= {} 
		Else
			//_aATItDV	:= {}
	EndIf
	
	//Essa Variavel vai ser trabalhada no PE MT103NFE
	//e zerada no MT103FIM ou no MT103CAN
	aAdd(_aATItDV,{(aVetPar)->D2_FILIAL,(aVetPar)->D2_DOC,(aVetPar)->D2_SERIE,(aVetPar)->D2_CLIENTE,(aVetPar)->D2_LOJA,(aVetPar)->D2_ITEM,(aVetPar)->D2_COD,(aVetPar)->D2_PEDIDO,(aVetPar)->D2_ITEMPV,(aVetPar)->D2_EMISSAO,(aVetPar)->D2_CCUSTO}) 
EndIf

RestArea(aArea)
Return(lExpL1)