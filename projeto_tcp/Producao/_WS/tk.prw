#include "rwmake.ch"
#include "tk.ch"

/*
!PRG! tk.CH
!OBJ! protótipo de funções de uso comum
!AUT! HMO - COMSIS 18/11/03
!OBS! propriedade da Takaoka
*/

/*
!FNC! User Function TKSX3(cField)
!OBJ! Retornar um vetor com informações sobre o campo baseando-se no dicionário de dados
!PAR! cField	nome do campo a ter a estrutura retornada
!AUT! HMO - COMSIS 
!OBS!	[1] = TITULO
		[2] = MASCARA
		[3] = TAMANHO
		[4] = DECIMAL
		[5] = VALIDACAO
		[6] = CONSULTA
		[7] = RELACAO (VALOR INICIAL)
		[8] = TIPO DE CAMPO

*/
USER function TKSX3(cField)
	local aRet[8]
	begin sequence
		//valores detault
		aRet[TITULO]:=""  ; aRet[MASCARA]:="" 
		aRet[TAMANHO]:=0  ; aRet[DECIMAL]:=0
		aRet[VALIDA]:=TRUE ; aRet[CONSULTA]:=""
		aRet[RELACAO]:="" ; aRet[TIPO]:="C"
		aRet[TITULO]	:= FwSX3Util():GetDescription(cField)
		aRet[MASCARA]	:= X3PICTURE(cField)
		aRet[TAMANHO]	:= TamSX3(cField)[1]
		aRet[DECIMAL]	:= TamSX3(cField)[2]
		aRet[VALIDA]	:= TRIM(GetSx3Cache(cField, "X3_VALID")+if(!empty(GetSx3Cache(cField, "X3_VALID")).AND.!EMPTY(GetSx3Cache(cField,"X3_VLDUSER")),".AND.","")+GetSx3Cache(cField, "X3_VALID"))
		aRet[CONSULTA]	:= X3F3(cField)
		aRet[RELACAO]	:= GetSx3Cache(cField, "X3_RELACAO")
		aRet[TIPO]		:= FwSX3Util():GetFieldType(cField)
	end sequence
return aRet


/*
!FNC! User Function InitSched()
!OBJ! Ativar agendamento de funções para utilizar o workflow
!AUT! HMO - COMSIS
!OBS!
*/
User Function InitSched()
	Local aParams := {"01","01"}  //código da empresa e  filial
	WFSCheduler(aParams) 
Return TRUE

/*
!FNC! User Function EWSetArray(aVetor,aConteudo)
!OBJ! Inserir valores repetidos em array
!AUT! HMO - COMSIS 
!OBS!
*/
USER function EWSETARRAY(aVetor,aConteudo)
	local nContador
	begin sequence
		for nContador:=1 to len(aVetor)
			aVetor[nContador]:=aConteudo
		next nContador
	end sequence
return aVetor

