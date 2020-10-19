#include "protheus.ch"
#include "apwebsrv.ch"
#include "apwebex.ch"
#include "rwmake.ch"
#include "topconn.ch"

WsService WsFAT003 description "Realiza a busca de ISS por produto"

	// DECLARACAO DAS VARIVEIS GERAIS
	wsdata sCODIGO  	 as string
	wsData Results   	 as Array of wfRFAT003
		
	// DELCARACAO DO METODOS

wsmethod ProcBuscaISS description "Realiza a busca de ISS por produto.<br /><br /><b>Parâmetros:</b><br /><font color='red'><b>sProduto</b></font>: Código do produto cuja aliquota de ISS será procurada (string). Se enviado em branco, trará todos os produtos com ISS. <br /><b>Resposta: Produto / Aliquota ISS </b><br /><font color='red'><b>Results</b></font>: sProduto (string) / nISS (float)."

endwsservice

wsStruct wfRFAT003

	wsdata sProduto as String
	wsdata nISS    as float

EndWsStruct


wsmethod ProcBuscaISS wsreceive sCODIGO wssend Results wsservice WsFAT003
local lRet 	:= .F.                                                        
Local nCont 	:= 1
	
	If Empty(Alltrim(sCODIGO))
	
		cQuery := " SELECT B1_COD, B1_ALIQISS  "
		cQuery += " FROM "+RetSqlName('SB1')
		cQuery += "	WHERE B1_FILIAL = '"+xFilial('SB1')+"' AND B1_ALIQISS != 0 AND D_E_L_E_T_ != '*' "
	
		TCQUERY cQuery NEW ALIAS "QRYISS"
		DbSelectArea("QRYISS")
		QRYISS->(DbGoTop())

		While !QRYISS->(EOF())						
			aAdd(Self:Results,WsClassNew("wfRFAT003"))

			Self:Results[nCont]:sProduto	:= QRYISS->B1_COD
			Self:Results[nCont]:nISS  		:= QRYISS->B1_ALIQISS
			nCont++                                              
			QRYISS->(DbSkip())						
		EndDo
		QRYISS->(DbCloseArea())
	Else
		aAdd(Self:Results,WsClassNew("wfRFAT003"))
		
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		SB1->(DbGoTop())
		If SB1->(DbSeek(xFilial("SB1")+sCODIGO))			
			Self:Results[1]:sProduto	:= sCodigo
			Self:Results[1]:nISS  		:= SB1->B1_ALIQISS
		Else
			Self:Results[1]:sProduto	:= 'Produto nao localizado'
			Self:Results[1]:nISS  		:= 0.00
		EndIf
	
	EndIF

return .T.
                                              
                               

