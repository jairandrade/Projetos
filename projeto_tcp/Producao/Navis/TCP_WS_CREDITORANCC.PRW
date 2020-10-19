#include "Protheus.ch"
#include "apwebsrv.ch"
#include "TOPCONN.CH"
/*/{Protheus.doc} TCPCreditoRANCC
Webservice Consulta financeira para Títulos de Crédito RA e NCC. 
@author  Luiz Fernando
@since   12/04/2016
/*/
wsService TCPCreditoRANCC description "Consulta financeira para Títulos de Crédito RA e NCC."

	wsData OrdemServico	as String
	wsData Retorno	    as Array of TCPCreditoRANCCStruct

	//Metodos
	wsMethod Consultar  description "Consulta Títulos de Crédito RA e NCC ."

endWsService


/*/{Protheus.doc} Consultar
Método utilizado para Consultar os títulos de Crédito de acordo com a OS.
@author  Luiz 
@since   20/07/2016
/*/
wsMethod Consultar wsReceive OrdemServico  wsSend Retorno wsService TCPCreditoRANCC

Local lRet   := .T.
LOCAL nPos   :=0
LOCAL cQuery := ""
LOCAL cTpTit := GetNewPar("TCP_TPTIT","RA,NCC")//Tipos separados por virgula

If Empty(Self:OrdemServico)
	SetSoapFault("TCPCreditoRANCC.Consultar","Informe um numero de OS.")
	Return .F.
EndIf

cQuery:= "SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_VALOR, E1_SALDO, E1_XNUMOS "
cQuery+= " FROM "+RetSQLNAme("SE1")
cQuery+= " WHERE "
cQuery+= " E1_FILIAL = '"+xFilial("SE1")+"' "
cQuery+= " AND E1_XNUMOS = '"+Self:OrdemServico+"' "
cQuery+= " AND E1_TIPO IN ('"+sTRtRAN(cTpTit,",","','")+"') "
cQuery+= " AND D_E_L_E_T_ != '*' "
If Select("TRBE1") <> 0
	DBSelectArea("TRBE1")
	DBCloseArea()
EndIf
TCquery cQuery New Alias "TRBE1" 

Do While !TRBE1->(Eof())

	aAdd(Self:Retorno,WsClassNew("TCPCreditoRANCCStruct"))
	nPos:= Len(Self:Retorno)
	Self:Retorno[nPos]:Prefixo := TRBE1->E1_PREFIXO
	Self:Retorno[nPos]:Numero  := TRBE1->E1_NUM
	Self:Retorno[nPos]:Tipo    := TRBE1->E1_TIPO
	Self:Retorno[nPos]:Valor   := TRBE1->E1_VALOR
	Self:Retorno[nPos]:Saldo   := TRBE1->E1_SALDO
	Self:Retorno[nPos]:Cliente := TRBE1->(E1_CLIENTE+E1_LOJA)//Codigo do cliente+Loja	
	Self:Retorno[nPos]:OS      := TRBE1->E1_XNUMOS		

	TRBE1->(DBSkip())
EndDo
If Select("TRBE1") <> 0
	DBSelectArea("TRBE1")
	DBCloseArea()
EndIf
If Len(Self:Retorno) == 0
	SetSoapFault("TCPCreditoRANCC.Consultar","Nao foi localizado dados para a consulta. Ordem de Servico:"+Self:OrdemServico)
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} TCPCreditoRANCC
Retorno dos títulos de crédito.
@author  Luiz
@since   20/07/2016
/*/
wsStruct TCPCreditoRANCCStruct

	wsData Prefixo as String
	wsData Numero  as String
	wsData Tipo    as String	
	wsData Valor   as Float
	wsData Saldo   as Float
	wsData Cliente as String//Codigo do cliente+Loja	
	wsData OS      as String	

endWsStruct