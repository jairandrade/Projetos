 #include 'protheus.ch'
#include 'parmtype.ch'

//==================================================================================================//
//	Programa: F460CMTC 		|	Autor: ??????									|	Data: 22/01/2018//
//==================================================================================================//
//	Descrição: PE utilizado para gravar o codigo de barras do cheque para o cnab de cheque			//
//	na liquidacao(Ponto de Entrada que permite efetuar ajuste no conteúdo do Leitor de cheque CMC7.)//
//==================================================================================================//

User Function F460CMTC()                             
Local cCmc7		:=	Paramixb 
Local aCmc7Tc 	:= {}
Public _ACMC7_	:= {}

Aadd( aCmc7Tc, SubStr(cCmc7, 2, 3) )	//Banco
Aadd( aCmc7Tc, SubStr(cCmc7, 14, 6) )	//Cheque
Aadd( aCmc7Tc, SubStr(cCmc7, 5, 4) )	//Agencia
Aadd( aCmc7Tc, SubStr(cCmc7, 25, 8) )	//Conta 

/* Descontinuado na nova versao P12.
If Len(aCols) > 0
	aCols [Len(aCols)] [ Ascan(aHeader,{|x|Alltrim(x[2]) == "EF_CODCHEQ"})] := cCmc7
EndIf
*/

//dvenc460 -> valor do cheque deve ser o mesmo do titulo --TODO colocar substr
AADD(_ACMC7_,cCmc7)

Return(aCmc7Tc)   
               





