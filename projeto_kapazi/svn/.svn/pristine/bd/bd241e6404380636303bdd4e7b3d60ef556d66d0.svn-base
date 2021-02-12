#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: CADZS1C		|	Autor: Luis Paulo							|	Data: 26/07/2018	//
//==================================================================================================//
//	Descrição: PE da funcao CADZS1																	//
//																									//
//==================================================================================================//
User Function CADZS1C()
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
Local aAreaZ1	:= ZS1->(GetArea())
Local cCmpObA	:= "ZS1_TPPESS/ZS1_CGC/ZS1_NOME/ZS1_TPSOLI/ZS1_RUA/ZS1_NUMERO/ZS1_BAIRRO/ZS1_CEP/ZS1_CIDADE/ZS1_UF/ZS1_NMCONT/ZS1_DDD/ZS1_TEL/ZS1_CDESDE/ZS1_TPCLIE/"
Local cCmpObB	:= "ZS1_PHISTC/ZS1_CODCOM/ZS1_DTFATU/ZS1_VLRTOR/ZS1_DTVENC/ZS1_VLRPAR"
Local lStatusL	:= .T.
Local cCmp		:= ""

If lStatusL //Valida campos obrigatorios normais
	// faz o loop sobre os campos
	For nI := 1 to ZS1->(FCount())
		If Alltrim(Field(nI)) $ cCmpObA
			
			cCmp	:= "ZS1->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZS1->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZS1")
	RecLock("ZS1",.F.)
	If lStatusL //Atualiza o status da linha
			ZS1->ZS1_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZS1->ZS1_STATUS := "1"
	EndIf
	ZS1->(MsUnlock())
EndIf

//Valida campos obrigatorios em caso de historico de compras
If lStatusL .And. Alltrim(ZS1->ZS1_PHISTC) == "S" 
	// faz o loop sobre os campos
	For nI := 1 to ZS1->(FCount())
		If Alltrim(Field(nI)) $ cCmpObB //Campos obrigatorios em caso de movimentos
			
			cCmp	:= "ZS1->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZS1->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZS1")
	RecLock("ZS1",.F.)
	If lStatusL //Atualiza o status da linha
			ZS1->ZS1_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZS1->ZS1_STATUS := "1"
	EndIf
	ZS1->(MsUnlock())
EndIf
	
RestArea(aAreaZ1)
Return()