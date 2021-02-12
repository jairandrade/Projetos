#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: CADZS2C		|	Autor: Luis Paulo							|	Data: 11/08/2018	//
//==================================================================================================//
//	Descrição: PE da funcao	CADZS2																	//
//																									//
//==================================================================================================//
User Function CADZS2C() 
Local aParam	:=	PARAMIXB
Local oObj		:=	aParam[1]     // OBJETO
Local cIdPonto	:=	aParam[2]     // ID DO PONTO DE ENTRADA
Local cIdObj	:=	oObj:GetId()
Local cClasse   :=  oObj:ClassName()
Local nQtdLinhas:= 	0
Local nLinha    := 	0
Local xRet		:=	.T.

If cClasse	==	"FWFORMGRID"
	nQtdLinhas := oObj:GetQtdLine()
	nLinha     := oObj:nLine
EndIf

Do Case
	Case	cIdPonto	==	"MODELCOMMITTTS"
		cMsg	:=	'Apos a gravação total do modelo e dentro da transação'+CRLF
		cMsg	+=	'ID: '+cIdObj
		//MsgInfo(cMsg,cIdPonto)
		
	Case	cIdPonto	==	"MODELCOMMITNTTS"
		cMsg	:=	'Apos a gravação total do modelo e fora da transação'+CRLF
		cMsg	+=	'ID: '+cIdObj
		//MsgInfo(cMsg,cIdPonto)
		xRet	:=		.T. //  MsgYesNo('Deseja Continuar','Atenção')
		XANREGA()//Atualiza o status
		
	Case	cIdPonto	==	"FORMCOMMITTTSPOS"
		cMsg	:=	'Apos a gravação da tabela do formulário'+CRLF
		cMsg	+=	'ID: '+cIdObj
		//MsgInfo(cMsg,cIdPonto)
		 
EndCase

Return(xRet)

//Atualiza o status
Static Function XANREGA()
Local aAreaZ1	:= ZS2->(GetArea())
Local cCmpObA	:= "ZS2_TPPESS/ZS2_CGC/ZS2_NOME/ZS2_TPSOLI/ZS2_RUA/ZS2_NUMERO/ZS2_BAIRRO/ZS2_CEP/ZS2_CIDADE/ZS2_UF/ZS2_NMCONT/ZS2_DDD/ZS2_TEL/ZS2_CDESDE/ZS2_TPCLIE/"
Local cCmpObB	:= "ZS2_DTFAT/ZS2_VLRTOT/ZS2_VENCPA/ZS2_VLRPAC/" //ZS2_DTPPAR/ZS2_VPPARC"
Local lStatusL	:= .T.
Local cCmp		:= ""

If lStatusL //Valida campos obrigatorios normais
	// faz o loop sobre os campos
	For nI := 1 to ZS2->(FCount())
		If Alltrim(Field(nI)) $ cCmpObA
			
			cCmp	:= "ZS2->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZS2->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZS2")
	RecLock("ZS2",.F.)
	If lStatusL //Atualiza o status da linha
			ZS2->ZS2_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZS2->ZS2_STATUS := "1"
	EndIf
	ZS2->(MsUnlock())
EndIf

//Valida campos obrigatorios em caso de historico de compras
If lStatusL .And. Alltrim(ZS2->ZS2_HISTCP) == "S" 
	// faz o loop sobre os campos
	For nI := 1 to ZS2->(FCount())
		If Alltrim(Field(nI)) $ cCmpObB //Campos obrigatorios em caso de movimentos
			
			cCmp	:= "ZS2->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZS2->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZS2")
	RecLock("ZS2",.F.)
	If lStatusL //Atualiza o status da linha
			ZS2->ZS2_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZS2->ZS2_STATUS := "1"
	EndIf
	ZS2->(MsUnlock())
EndIf
	
RestArea(aAreaZ1)
Return()