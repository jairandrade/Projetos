#include "Protheus.ch"
#include "apwebsrv.ch"
#include "TOPCONN.CH"
/*/{Protheus.doc} TCPRATitulo 
Webservice Consulta financeira para Títulos de Crédito RA e NCC associados a titulos de Contas a receber. 
@author  Luiz Fernando
@since   12/04/2016
/*/
wsService TCPRATitulo description "Consulta financeira para RAs associados a Títulos de Contas a Receber."

	wsData sId 	  		as String
	wsData sCliente 	as String
	wsData Retorno	    as TCPRADadStru

	//Metodos
	wsMethod Consultar description "Consulta de RA associado a Titulo de Contas a Receber."

endWsService

/*/{Protheus.doc} TCPRADadStru
//TODO Estrutura para mesagem e status
@author Mario L. B. Faria
@since 02/02/2018
@version 1.0
@return ${return}, ${return_description}

@type class
/*/
wsStruct TCPRADadStru

	wsData STATUSRET 	as String	//TRUE or FALSE
	wsData Msg       	as String
	wsData Dados        as array of TCPRATituloStruct	

endWsStruct

/*/{Protheus.doc} TCPRATitulo
Retorno dos títulos de crédito.
@author  Luiz
@since   20/07/2016
/*/
wsStruct TCPRATituloStruct

	wsData Prefixo   as String
	wsData Numero    as String
	wsData Parcela   as String	
	wsData Tipo      as String	
	wsData Valor     as Float
	wsData Saldo     as Float
	wsData Cliente   as String	//Codigo do cliente+Loja	
	wsData OS        as String

endWsStruct

/*/{Protheus.doc} Consultar
Método utilizado para Consultar os títulos de Crédito de acordo com o titulo base.
@author  Luiz 
@since   20/07/2016
/*/
wsMethod Consultar wsReceive sId, sCliente  wsSend Retorno wsService TCPRATitulo 

	LOCAL nPos   :=0
	LOCAL cQuery := ""
	LOCAL cTpTit := GetNewPar("TCP_TPTIT","RA,NCC")//Tipos separados por virgula
	Local cLog := ""

	
	If Empty(Self:sId)		
	
		cLog := "[TCPRATitulo] - Consultar - Informe o ID do titulo."
		
		Self:Retorno:STATUSRET := "FALSE"
		Self:Retorno:Msg       := cLog
	
		aAdd(Self:Retorno:Dados,WsClassNew("TCPRATituloStruct"))
		nPos:= Len(Self:Retorno:Dados)
		Self:Retorno:Dados[nPos]:Prefixo   := ""
		Self:Retorno:Dados[nPos]:Numero    := ""
		Self:Retorno:Dados[nPos]:Parcela   := ""
		Self:Retorno:Dados[nPos]:Tipo      := ""
		Self:Retorno:Dados[nPos]:Valor     := 0.00
		Self:Retorno:Dados[nPos]:Saldo     := 0.00
		Self:Retorno:Dados[nPos]:Cliente   := Self:sCliente
		Self:Retorno:Dados[nPos]:OS        := ""	
		U_WSGEN001("TCPRATitulo.Consultar",cLog)
		Return .T.
	EndIf
	
	If Empty(Self:sCliente)
	
		cLog := "[TCPRATitulo] - Consultar - Informe o Cliente."	
	
		Self:Retorno[nPos]:STATUSRET := "FALSE"
		Self:Retorno[nPos]:Msg       := cLog	
	
		aAdd(Self:Retorno:Dados,WsClassNew("TCPRATituloStruct"))
		nPos:= Len(Self:Retorno:Dados)
		Self:Retorno:Dados[nPos]:Prefixo   := ""
		Self:Retorno:Dados[nPos]:Numero    := ""
		Self:Retorno:Dados[nPos]:Parcela   := ""
		Self:Retorno:Dados[nPos]:Tipo      := ""
		Self:Retorno:Dados[nPos]:Valor     := 0.00
		Self:Retorno:Dados[nPos]:Saldo     := 0.00
		Self:Retorno:Dados[nPos]:Cliente   := Self:sCliente
		Self:Retorno:Dados[nPos]:OS        := ""	
		U_WSGEN001("TCPRATitulo.Consultar",cLog)
		Return .T.
	EndIf                         
	
	cPrefixo := ""
	cNum 	 := ""
	cTipo 	 := "RA"
	               
	cQuery:= "SELECT E1_PREFIXO, E1_NUM, E1_TIPO "
	cQuery+= " FROM "+RetSQLNAme("SE1")
	cQuery+= " WHERE "
	cQuery+= " E1_FILIAL = '"+xFilial("SE1")+"' "
	cQuery+= " AND E1_CLIENTE+E1_LOJA 	= '"+Self:sCliente+"' "
	cQuery+= " AND E1_XIDNAVI 	 		= '"+Alltrim(Self:sId)+"' "
	cQuery+= " AND D_E_L_E_T_ != '*' " 
	If Select("TRBE1") <> 0
		DBSelectArea("TRBE1")
		DBCloseArea()
	EndIf
	TCquery cQuery New Alias "TRBE1" 
	DBSelectArea("TRBE1")
	TRBE1->(DbGoTop())
	
	IF !TRBE1->(EOF())
		cPrefixo := TRBE1->E1_PREFIXO
		cNum 	 := TRBE1->E1_NUM
	EndIf
	
	DBSelectArea("TRBE1")
	DBCloseArea()
	
	cQuery:= "SELECT E5_DOCUMEN, COUNT(E5_DOCUMEN), E5_VALOR "
	cQuery+= " FROM "+RetSQLNAme("SE5")
	cQuery+= " WHERE "
	cQuery+= " E5_FILIAL = '"+xFilial("SE5")+"' "
	cQuery+= " AND E5_PREFIXO = '"+cPrefixo+"' "
	cQuery+= " AND E5_NUMERO 	  = '"+cNum+"' "
	cQuery+= " AND E5_CLIFOR+E5_LOJA = '"+Self:sCliente+"' "
	cQuery+= " AND E5_TIPODOC = 'CP' "
	cQuery+= " AND D_E_L_E_T_ != '*' " 
	cQuery+= " GROUP BY E5_DOCUMEN, E5_VALOR " 
	
	cQuery+= " EXCEPT "
	
	cQuery+= " SELECT DISTINCT E5_DOCUMEN, COUNT(E5_DOCUMEN), E5_VALOR "
	cQuery+= " FROM "+RetSQLNAme("SE5")
	cQuery+= " WHERE "
	cQuery+= " E5_FILIAL = '"+xFilial("SE5")+"' "
	cQuery+= " AND E5_PREFIXO = '"+cPrefixo+"' "
	cQuery+= " AND E5_NUMERO 	  = '"+cNum+"' "
	cQuery+= " AND E5_CLIFOR+E5_LOJA = '"+Self:sCliente+"' "
	cQuery+= " AND E5_TIPODOC = 'ES' "
	cQuery+= " AND D_E_L_E_T_ != '*' "
	cQuery+= " GROUP BY E5_DOCUMEN, E5_VALOR " 
	
	If Select("TRBE1") <> 0
		DBSelectArea("TRBE1")
		DBCloseArea()
	EndIf
	TCquery cQuery New Alias "TRBE1" 

	If !TRBE1->(Eof())
		Self:Retorno:STATUSRET := "TRUE"
		Self:Retorno:Msg       := ""	
	EndIf
	
	Do While !TRBE1->(Eof())
		DbSelectArea('SE1')
		SE1->(DbSetOrder(1))
		SE1->(DbGoTop())
		
		IF SE1->(DbSeek(xFilial('SE1')+SUBSTR(TRBE1->E5_DOCUMEN,1,17)))
	                           	
			aAdd(Self:Retorno:Dados,WsClassNew("TCPRATituloStruct"))
			nPos:= Len(Self:Retorno:Dados)
			Self:Retorno:Dados[nPos]:Prefixo   := SE1->E1_PREFIXO
			Self:Retorno:Dados[nPos]:Numero    := SE1->E1_NUM
			Self:Retorno:Dados[nPos]:Parcela   := SE1->E1_PARCELA
			Self:Retorno:Dados[nPos]:Tipo      := SE1->E1_TIPO
			Self:Retorno:Dados[nPos]:Valor     := TRBE1->E5_VALOR
			Self:Retorno:Dados[nPos]:Saldo     := SE1->E1_SALDO
			Self:Retorno:Dados[nPos]:Cliente   := SE1->(E1_CLIENTE+E1_LOJA)//Codigo do cliente+Loja	
			Self:Retorno:Dados[nPos]:OS        := SE1->E1_XNUMOS	
			
					
		EndIf
		TRBE1->(DBSkip())
	EndDo
	If Select("TRBE1") <> 0
		DBSelectArea("TRBE1")
		DBCloseArea()
	EndIf
	If Len(Self:Retorno:Dados) == 0
	
		cLog := "[TCPRATitulo] - Consultar - Nao foi localizado dados para a consulta com id: " + Self:sId	
	
		Self:Retorno:STATUSRET := "FALSE"
		Self:Retorno:Msg       := cLog
	
		aAdd(Self:Retorno:Dados,WsClassNew("TCPRATituloStruct"))
		nPos:= Len(Self:Retorno:Dados)
		Self:Retorno:Dados[nPos]:Prefixo   := ""
		Self:Retorno:Dados[nPos]:Numero    := ""
		Self:Retorno:Dados[nPos]:Parcela   := ""
		Self:Retorno:Dados[nPos]:Tipo      := ""
		Self:Retorno:Dados[nPos]:Valor     := 0.00
		Self:Retorno:Dados[nPos]:Saldo     := 0.00
		Self:Retorno:Dados[nPos]:Cliente   := Self:sCliente
		Self:Retorno:Dados[nPos]:OS        := ""	
		
		U_WSGEN001("TCPRATitulo.Consultar",cLog)
	
	//	SetSoapFault("TCPRATitulo.Consultar","Nao foi localizado dados para a consulta com id :"+Self:sId)
	//	SetSoapFault('TCPRATitulo.Consultar','Nao foi localizado dados para a consulta com id :"+Self:sId',SOAPFAULT_SENDER)
	
	Else
		U_WSGEN001("TCPRATitulo.Consultar","[" + DtoC(Date()) + " - "  + Time() + "] - [TCPRATitulo] - sId: " + sId + " - Consulta relaizada com sucesso")
	EndIf

Return .T.

