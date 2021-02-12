#include 'protheus.ch'
#include 'parmtype.ch'
#include "TopConn.ch"
//==================================================================================================//
//	Programa: CADZSLC		|	Autor: Luis Paulo							|	Data: 26/07/2018	//
//==================================================================================================//
//	Descrição: PE da funcao CADZSL																	//
//																									//
//==================================================================================================//
User Function CADZSLC()
Local aParam	:=	PARAMIXB
Local oObj		:=	aParam[1]     // OBJETO
Local cIdPonto	:=	aParam[2]     // ID DO PONTO DE ENTRADA
Local cIdObj	:=	oObj:GetId()
Local cClasse   :=  oObj:ClassName()
Local nQtdLinhas:= 	0
Local nLinha    := 	0
Local xRet		:=	.T.
Local cRaizCGC	:= ""

Local oModel	:= FWLoadModel("CADZSLC")
Local oZSL 		:= oObj:GetModel('Enchoice_ZSL')
Local cCodigo	
Local LINCLUI	:= oZSL:GetOperation() == 3 //Insert
Local nValor	:= 0

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
		//XANREGA()//Atualiza o status
		
	Case	cIdPonto	==	"FORMCOMMITTTSPOS"
		cMsg	:=	'Apos a gravação da tabela do formulário'+CRLF
		cMsg	+=	'ID: '+cIdObj
		//MsgInfo(cMsg,cIdPonto)
	
	Case	cIdPonto	==	"FORMPOS"
		cMsg	:=	'Na validação total do formulário'+CRLF
		cMsg	+=	'ID: '+cIdObj
		If LINCLUI
			
			cRaizCGC 	:= oZSL:GetValue("Enchoice_ZSL","ZSL_RAIZCN")
			nValor		:= oZSL:GetValue("Enchoice_ZSL","ZSL_LIMTOT")
			If !ValRaizc(cRaizCGC)
				xRet:= .F.
				Help(NIL, NIL, "CNPJ - KAPAZICRED", NIL, "Raiz de CNPJ já informada", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o código -> " + cAliaZSL->ZSL_CODIGO})
				//Help(NIL, NIL, "Texto do Help", NIL, "Texto do Problema", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Texto da Solução"})
				//http://tdn.totvs.com/display/public/PROT/Help
				cAliaZSL->(DbCloseArea())
			EndIf
			
			If ValRaizS(cRaizCGC)
				xRet:= .F.
				Help(NIL, NIL, "CNPJ - KAPAZICRED", NIL, "Raiz de CNPJ não existente!!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o CNPJ -> " + cRaizCGC})
				//Help(NIL, NIL, "Texto do Help", NIL, "Texto do Problema", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Texto da Solução"})
				//http://tdn.totvs.com/display/public/PROT/Help
				cAliaZSL->(DbCloseArea())
			EndIf
			
			If Len(Alltrim(cRaizCGC)) < 8
				xRet:= .F.
				Help(NIL, NIL, "CNPJ - KAPAZICRED", NIL, "Raiz de CNPJ não existente!!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o CNPJ -> " + cRaizCGC})
				//Help(NIL, NIL, "Texto do Help", NIL, "Texto do Problema", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Texto da Solução"})
				//http://tdn.totvs.com/display/public/PROT/Help
			EndIf
			
			If Empty(nValor)
				xRet:= .F.
				Help(NIL, NIL, "CNPJ - KAPAZICRED", NIL, "Valor do limite não informado!!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o CNPJ -> " + cRaizCGC})
				//Help(NIL, NIL, "Texto do Help", NIL, "Texto do Problema", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Texto da Solução"})
				//http://tdn.totvs.com/display/public/PROT/Help
			EndIf
			
			
		EndIf
EndCase

Return(xRet)

Static Function ValRaizc(cRaizCGC)
Local lRet	:= .T.
Local cQr 	:= ""

If Select("cAliaZSL")<>0
	DbSelectArea("cAliaZSL")
	cAliaZSL->(DbCloseArea())
Endif

cQr += " SELECT *
cQr += " FROM "+ RetSqlName("ZSL") +" ZSL
cQr += " WHERE ZSL.D_E_L_E_T_ = ''
cQr += "		AND ZSL.ZSL_RAIZCN = "+cRaizCGC

// abre a query
TcQuery cQr new alias "cAliaZSL"
Count to nRegs

DbSelectArea("cAliaZSL")
cAliaZSL->(DbGoTop())

Return(cAliaZSL->(EOF()))


Static Function ValRaizS(cRaizCGC)
Local lRet	:= .T.
Local cQr 	:= ""

If Select("cAliaZSL")<>0
	DbSelectArea("cAliaZSL")
	cAliaZSL->(DbCloseArea())
Endif

cQr += " SELECT *
cQr += " FROM "+ RetSqlName("SA1") +" SA1
cQr += " WHERE SA1.D_E_L_E_T_ = ''
cQr += "		AND SUBSTRING(SA1.A1_CGC,1,8) = '"+cRaizCGC+"'"

// abre a query
TcQuery cQr new alias "cAliaZSL"
Count to nRegs

DbSelectArea("cAliaZSL")
cAliaZSL->(DbGoTop())

Return(cAliaZSL->(EOF()))



Return(lRet)

//Atualiza o status
Static Function XANREGA()
Local aAreaZ1	:= ZSL->(GetArea())
Local cCmpObA	:= "ZSL_TPPESS/ZSL_CGC/ZSL_NOME/ZSL_TPSOLI/ZSL_RUA/ZSL_NUMERO/ZSL_BAIRRO/ZSL_CEP/ZSL_CIDADE/ZSL_UF/ZSL_NMCONT/ZSL_DDD/ZSL_TEL/ZSL_CDESDE/ZSL_TPCLIE/"
Local cCmpObB	:= "ZSL_PHISTC/ZSL_CODCOM/ZSL_DTFATU/ZSL_VLRTOR/ZSL_DTVENC/ZSL_VLRPAR"
Local lStatusL	:= .T.
Local cCmp		:= ""

If lStatusL //Valida campos obrigatorios normais
	// faz o loop sobre os campos
	For nI := 1 to ZSL->(FCount())
		If Alltrim(Field(nI)) $ cCmpObA
			
			cCmp	:= "ZSL->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZSL->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZSL")
	RecLock("ZSL",.F.)
	If lStatusL //Atualiza o status da linha
			ZSL->ZSL_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZSL->ZSL_STATUS := "1"
	EndIf
	ZSL->(MsUnlock())
EndIf

//Valida campos obrigatorios em caso de historico de compras
If lStatusL .And. Alltrim(ZSL->ZSL_PHISTC) == "S" 
	// faz o loop sobre os campos
	For nI := 1 to ZSL->(FCount())
		If Alltrim(Field(nI)) $ cCmpObB //Campos obrigatorios em caso de movimentos
			
			cCmp	:= "ZSL->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZSL->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZSL")
	RecLock("ZSL",.F.)
	If lStatusL //Atualiza o status da linha
			ZSL->ZSL_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZSL->ZSL_STATUS := "1"
	EndIf
	ZSL->(MsUnlock())
EndIf
	
RestArea(aAreaZ1)
Return()