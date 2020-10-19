#include "protheus.ch"
#include "apwebsrv.ch"
#include "apwebex.ch"
#include "rwmake.ch"
#include "topconn.ch"

WsService WsFAT001 description "Realiza a análise de credito."

	// DECLARACAO DAS VARIVEIS GERAIS
	wsdata sCODIGO  	 as string
	wsdata nValor   	 as float
	wsData Results   	 as Array of wfRFAT001
		
	// DELCARACAO DO METODOS

wsmethod ProcAnaliseByCodigo description "Realiza a análise de crédito de um cliente.<br /><br /><b>Parâmetros:</b><br /><font color='red'><b>sCNPJ</b></font>: Codigo+Loja do cliente a ser analisado. (string)<br /><font color='red'><b>nValor</b></font>: Valor da carga a ser analisada. (real)<br /><br/><b>Resposta: Cliente / T or F </b><br /><font color='red'><b>sResult</b></font>: S/N (string)."

endwsservice

wsStruct wfRFAT001

	wsdata sAvaliacao    as String
	wsdata sInadimplente as String
	wsdata nLimite   	 as float
	wsdata nSaldo   	 as float 

EndWsStruct


wsmethod ProcAnaliseByCodigo wsreceive sCODIGO, nValor wssend Results wsservice WsFAT001
local lRet 		:= .F.                                                        
Local nValAdd 	:= 0
	
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())
	If SA1->(DbSeek(xFilial("SA1")+sCODIGO))
	
		If !Empty(Alltrim(SA1->A1_XGRPCLI))
			cQuery := " SELECT SUM(A1_LC-A1_SALDUP) AS LC_COMP "
			cQuery += " FROM "+RetSqlName('SA1')
			cQuery += "	WHERE A1_FILIAL = '"+xFilial('SA1')+"' AND A1_XGRPCLI = '"+SA1->A1_XGRPCLI+"' AND D_E_L_E_T_ != '*' "

			TCQUERY cQuery NEW ALIAS "QRYLC"

			DbSelectArea("QRYLC")
			QRYLC->(DbGoTop())
			
			IF !QRYLC->(EOF())						
				nValAdd := QRYLC->LC_COMP
			EndIf
			QRYLC->(DbCloseArea())
			
		EndIf	
//		lRet := MaAvalCred(SA1->A1_COD,SA1->A1_LOJA,nValor,1,.F.,,,nValAdd)				
		aAdd(Self:Results,WsClassNew("wfRFAT001"))

		Self:Results[1]:nLimite		:= SA1->A1_LC
		Self:Results[1]:nSaldo  	:= SA1->A1_LC - SA1->A1_SALDUP 
	
		If SA1->A1_XBLOQ == '1'   
			Self:Results[1]:sAvaliacao  := "False"			 
		Else
			Self:Results[1]:sAvaliacao 	:= "True"
		EndIf				
		   
		cQuery := " SELECT *  "
		cQuery += " FROM "+RetSqlName('SE1')
		cQuery += "	WHERE E1_FILIAL = '"+xFilial('SE1')+"' AND E1_CLIENTE = '"+SA1->A1_COD+"' AND E1_LOJA = '"+SA1->A1_LOJA+"' "
		cQuery += "  AND E1_VENCREA = '"+DtoS(dDataBase-2)+"'AND E1_SALDO > 0.01 AND D_E_L_E_T_ != '*' "
		TCQUERY cQuery NEW ALIAS "QRYLC"
		DbSelectArea("QRYLC")
		QRYLC->(DbGoTop())
		
		IF !QRYLC->(EOF())						
			Self:Results[1]:sInadimplente	:= "False" 
		Else
			Self:Results[1]:sInadimplente	:= "True"
		EndIf
		QRYLC->(DbCloseArea())

	Else  
	   //	aAdd(Self:Results,WsClassNew("wfRFAT001"))       
		//Self:Results[1]:sInadimplente	:= "False" 
		//Self:Results[1]:sAvaliacao  := "CLIENTE NÃO ENCONTRADO"			
			SetSoapFault("WsFAT001.ProcAnaliseByCodigo","CLIENTE NÃO ENCONTRADO")
			return .F.
		
	EndIF

/*
		aAdd(Self:Results,WsClassNew("wfRFAT001"))
		Self:Results[1]:CLIENTE := sCODIGO		
		If lRet   
			Self:Results[1]:STATUSCRED  := "T"			
		Else
			Self:Results[1]:STATUSCRED  := "F"			
		EndIf				


	Else
		aAdd(Self:Results,WsClassNew("wfRFAT001"))
		Self:Results[1]:CLIENTE := sCODIGO		
		Self:Results[1]:STATUSCRED  := "CLIENTE NÃO ENCONTRADO"			
	EndIF
*/		                    

return .T.
                                              
                               

