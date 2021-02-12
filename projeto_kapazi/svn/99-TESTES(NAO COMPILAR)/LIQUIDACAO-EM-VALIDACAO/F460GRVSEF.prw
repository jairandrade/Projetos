#include 'protheus.ch'
#include 'parmtype.ch'

//==================================================================================================//
//	Programa: F460GRVSEF	|	Autor: ??????									|	Data: 22/01/2018//
//==================================================================================================//
//	Descrição: Gravação de Campos complementares na tabela SEF										//
//  																								//
//==================================================================================================//
//
User Function F460GRVSEF()
Local cTemp
                                                                              
IF Ascan(aHeader,{|x|Alltrim(x[2])=="EF_CODCHEQ"})==0
	//ALERT("Verificar lancamento")
	return
EndIf   

cTemp	:= aCols[__LACO][ascan(aHeader,{|x|alltrim(x[2])=="EF_CODCHEQ"})]
                                                        
If ValType(cTemp) == "N"                                                     
		SEF->EF_CODCHEQ := cValTochar(cTemp)
	
	ElseIf  ValType(cTemp) == "C" 
		SEF->EF_CODCHEQ := aCols[__LACO][ascan(aHeader,{|x|alltrim(x[2])=="EF_CODCHEQ"})]
EndIf

Return()