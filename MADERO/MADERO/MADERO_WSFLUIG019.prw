#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH" 
 
/*/{Protheus.doc} WSClienteFLuig
//TODO Declaração do WebService WSClienteFLuig
@author Jair Matos
@since 26/07/2019
@version 1.0
alteração - JAIR 27-04-2020 - incluido campo A1_XUSER -> CMAIL na gravação dos dados.
/*/

WSRESTFUL WSClienteFLuig DESCRIPTION "Madero - CRUD de Clientes enviados via FLUIG - FLUIG"

WSMETHOD POST 	DESCRIPTION "Gravação de Clientes enviados via FLUIG" 	WSSYNTAX "/WSClienteFLuig"
WSMETHOD PUT 	DESCRIPTION "Edição de Clientes enviados via FLUIG" 	WSSYNTAX "/WSClienteFLuig"

END WSRESTFUL


/*/{Protheus.doc} POST
//TODO Declaração do Metodo WSClienteFLuig
@author Jair Matos 
@since 30/07/2019
@version 1.0 
/*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE WSClienteFLuig

	Local cResponse		:= ""
	Local cBody
	Local oObj
	Local cdempresa 	:= ""
	Local cdfilial 
	Local cMail			:= ""
	Local xFaixa		:= ""
	Local CSOLIC		:= ""
	Local aVetor		:= {}
	Local A1_COD		:=""
	Local A1_LOJA		:=""
	Local A1_NOME		:=""
	Local A1_NREDUZ		:=""
	Local A1_CEP		:=""
	Local A1_END		:=""
	Local A1_BAIRRO		:=""
	Local A1_TIPO		:=""
	Local A1_DDD		:=""
	Local A1_TEL		:=""
	Local A1_MUN		:=""
	Local A1_COD_MUN	:=""
	Local A1_EST		:=""
	Local A1_PAIS		:=""
	Local A1_PESSOA		:=""
	Local A1_CGC		:=""
	Local A1_INSCR		:=""
	Local A1_INSCRM		:=""
	Local A1_EMAIL		:=""
	Local A1_INSCRUR	:=""
	Local A1_XFONE2		:=""
	Local A1_XCELULA	:=""
	Local A1_CODPAIS	:=""
	Local A1_CONTRIB	:=""
	Local A1_CONTA		:=""
	Local A1_NATUREZ	:=""
	Local A1_COND		:=""
	Local A1_RISCO		:=""
	Local A1_TABELA		:=""
	Local A1_TRANSP		:=""
	Local A1_VEND		:=""
	Local A1_GRPTRIB	:=""

	::SetContentType("application/json")

	cBody := ::GetContent()


	If FWJsonDeserialize(cBody,@oObj)
		cdempresa 	:=  cValtoChar(oObj:cdempresa)
		cdfilial 	:=  cValtoChar(oObj:cdfilial)  
		xFaixa 		:=  cValtoChar(oObj:xFaixa) 
		cMail		:= cValtoChar(oObj:cMail) 
		CSOLIC		:= cValtoChar(oObj:CSOLIC)
		A1_NOME 	:=  cValtoChar(oObj:A1_NOME)
		A1_NREDUZ 	:=  cValtoChar(oObj:A1_NREDUZ)
		A1_CEP 		:=  cValtoChar(oObj:A1_CEP)
		A1_END 		:=  cValtoChar(oObj:A1_END)
		A1_BAIRRO 	:=  cValtoChar(oObj:A1_BAIRRO)
		A1_TIPO 	:=  cValtoChar(oObj:A1_TIPO)
		A1_DDD 		:=  cValtoChar(oObj:A1_DDD)
		A1_TEL 		:=  cValtoChar(oObj:A1_TEL)
		A1_EST 		:=  cValtoChar(oObj:A1_EST)
		A1_MUN 		:=  cValtoChar(oObj:A1_MUN)
		A1_COD_MUN 	:=  cValtoChar(oObj:A1_COD_MUN)
		A1_PAIS 	:=  cValtoChar(oObj:A1_PAIS)
		A1_PESSOA 	:=  cValtoChar(oObj:A1_PESSOA)
		A1_CGC 		:=  cValtoChar(oObj:A1_CGC)
		A1_INSCR 	:=  cValtoChar(oObj:A1_INSCR)
		A1_INSCRM 	:=  cValtoChar(oObj:A1_INSCRM)
		A1_EMAIL 	:=  cValtoChar(oObj:A1_EMAIL)
		A1_INSCRUR 	:=  cValtoChar(oObj:A1_INSCRUR)
		A1_XFONE2 	:=  cValtoChar(oObj:A1_XFONE2)
		A1_XCELULA 	:=  cValtoChar(oObj:A1_XCELULA)
		A1_CODPAIS 	:=  cValtoChar(oObj:A1_CODPAIS)
		A1_CONTRIB  :=  cValtoChar(oObj:A1_CONTRIB)
		A1_CONTA 	:=  cValtoChar(oObj:A1_CONTA)
		A1_NATUREZ 	:=  cValtoChar(oObj:A1_NATUREZ)
		A1_COND 	:=  cValtoChar(oObj:A1_COND)
		A1_RISCO 	:=  cValtoChar(oObj:A1_RISCO)
		A1_TABELA 	:=  cValtoChar(oObj:A1_TABELA)
		A1_TRANSP 	:=  cValtoChar(oObj:A1_TRANSP)
		A1_VEND 	:=  cValtoChar(oObj:A1_VEND)
		A1_GRPTRIB 	:=  cValtoChar(oObj:A1_GRPTRIB)
 
		If cdempresa == "" .Or. cdfilial == ""
			cResponse := '{"message":"Parametros Incorretos"}'			
			SetRestFault(400, "Bad request")
		Else
			A1_COD := GetCodFaixa(cdempresa, cdfilial,xFaixa,A1_CGC)
			A1_LOJA :=U_COMX003L(A1_CGC,xFaixa)
			aVetor:= {{"A1_CGC"		,A1_CGC 		,.T.},;
			{"A1_COD" 		,A1_COD 		,.T.},;
			{"A1_LOJA" 		,A1_LOJA 		,.T.},;
			{"A1_NOME"		,NoAcento(A1_NOME),.T.},;
			{"A1_NREDUZ"	,NoAcento(A1_NREDUZ),.T.},;
			{"A1_CEP"		,A1_CEP			,.T.},;
			{"A1_END"		,NoAcento(DecodeUTF8(A1_END)),.T.},;
			{"A1_BAIRRO"	,NoAcento(DecodeUTF8(A1_BAIRRO)),.T.},;
			{"A1_TIPO"		,A1_TIPO		,.T.},;
			{"A1_DDD"		,A1_DDD 		,.T.},;
			{"A1_TEL"		,A1_TEL 		,.T.},;
			{"A1_EST"	   	,A1_EST			,.T.},;
			{"A1_COD_MUN"	,A1_COD_MUN		,.T.},;
			{"A1_MUN"		,NoAcento(DecodeUTF8(A1_MUN)),.T.},;
			{"A1_PAIS"		,A1_PAIS 		,.T.},;
			{"A1_PESSOA"	,A1_PESSOA		,.T.},;
			{"A1_INSCR"		,A1_INSCR 		,.T.},;
			{"A1_INSCRM"	,A1_INSCRM 		,.T.},;
			{"A1_EMAIL"		,NoAcento(A1_EMAIL),.T.},;
			{"A1_INSCRUR"	,A1_INSCRUR 	,.T.},;
			{"A1_XFONE2"	,A1_XFONE2 		,.T.},;
			{"A1_XCELULA"	,A1_XCELULA 	,.T.},;
			{"A1_CODPAIS"	,A1_CODPAIS		,.T.},;
			{"A1_CONTRIB"	,A1_CONTRIB		,.T.},;
			{"A1_CONTA"		,A1_CONTA		,.T.},;
			{"A1_NATUREZ"	,A1_NATUREZ		,.T.},;
			{"A1_COND"		,A1_COND 		,.T.},;
			{"A1_RISCO"		,A1_RISCO 		,.T.},;
			{"A1_TABELA"	,A1_TABELA 		,.T.},;
			{"A1_TRANSP"	,A1_TRANSP 		,.T.},;
			{"A1_VEND"		,A1_VEND 		,.T.},;
			{"A1_GRPTRIB"	,A1_GRPTRIB		,.T.},;
			{"A1_XUSER"		,cMail			,.T.}} 

			cResponse := WSFLUIG019(cdempresa, cdfilial, 1, aVetor, "Cod:"+A1_COD+" Loja:"+A1_LOJA+" Descr:"+A1_NREDUZ+" Cnpj:"+A1_CGC,cMail,CSOLIC)
		EndIf

	Else

		cResponse := '{"message":"Parametros Incorretos"}'			
		SetRestFault(400, "Bad request")

	EndIf


	::SetResponse(cResponse)
Return .T.

/*/{Protheus.doc} POST
//TODO Declaração do Metodo WSClienteFLuig
@author Jair Matos
@since 30/07/2019
@version 1.0
/*/
WSMETHOD PUT WSRECEIVE NULLPARAM WSSERVICE WSClienteFLuig

	Local cResponse		:= ""
	Local cBody
	Local oObj
	Local cdempresa 	:= ""
	Local cdfilial 
	Local cMail			:= ""
	Local CSOLIC		:= ""
	Local aVetor		:= {}
	Local A1_COD		:=""
	Local A1_LOJA		:=""
	Local A1_NOME		:=""
	Local A1_NREDUZ		:=""
	Local A1_CEP		:=""
	Local A1_END		:=""
	Local A1_BAIRRO		:=""
	Local A1_TIPO		:=""
	Local A1_DDD		:=""
	Local A1_TEL		:=""
	Local A1_MUN		:=""
	Local A1_COD_MUN	:=""
	Local A1_EST		:=""
	Local A1_PAIS		:=""
	Local A1_PESSOA		:=""
	Local A1_CGC		:=""
	Local A1_INSCR		:=""
	Local A1_INSCRM		:=""
	Local A1_EMAIL		:=""
	Local A1_INSCRUR	:=""
	Local A1_XFONE2		:=""
	Local A1_XCELULA	:=""
	Local A1_CODPAIS	:=""
	Local A1_CONTRIB	:=""
	Local A1_CONTA		:=""
	Local A1_NATUREZ	:=""
	Local A1_COND		:=""
	Local A1_RISCO		:=""
	Local A1_TABELA		:=""
	Local A1_TRANSP		:=""
	Local A1_VEND		:=""
	Local A1_GRPTRIB	:=""


	::SetContentType("application/json")

	cBody := ::GetContent()


	If FWJsonDeserialize(cBody,@oObj)
		cdempresa 	:= cValtoChar(oObj:cdempresa)
		cdfilial 	:= cValtoChar(oObj:cdfilial) 
		cMail		:= cValtoChar(oObj:cMail)
		CSOLIC		:= cValtoChar(oObj:CSOLIC)
		A1_COD 		:= cValtoChar(oObj:A1_COD)
		A1_LOJA 	:=  cValtoChar(oObj:A1_LOJA)
		A1_NOME 	:=  cValtoChar(oObj:A1_NOME)
		A1_NREDUZ 	:=  cValtoChar(oObj:A1_NREDUZ)
		A1_CEP 		:=  cValtoChar(oObj:A1_CEP)
		A1_END 		:=  cValtoChar(oObj:A1_END)
		A1_BAIRRO 	:=  cValtoChar(oObj:A1_BAIRRO)
		A1_TIPO 	:=  cValtoChar(oObj:A1_TIPO)
		A1_DDD 		:=  cValtoChar(oObj:A1_DDD)
		A1_TEL 		:=  cValtoChar(oObj:A1_TEL)
		A1_MUN 		:=  cValtoChar(oObj:A1_MUN)
		A1_COD_MUN 	:=  cValtoChar(oObj:A1_COD_MUN)
		A1_EST 		:=  cValtoChar(oObj:A1_EST)
		A1_PAIS 	:=  cValtoChar(oObj:A1_PAIS)
		A1_PESSOA 	:=  cValtoChar(oObj:A1_PESSOA)
		A1_CGC 		:=  cValtoChar(oObj:A1_CGC)
		A1_INSCR 	:=  cValtoChar(oObj:A1_INSCR)
		A1_INSCRM 	:=  cValtoChar(oObj:A1_INSCRM)
		A1_EMAIL 	:=  cValtoChar(oObj:A1_EMAIL)
		A1_INSCRUR 	:=  cValtoChar(oObj:A1_INSCRUR)
		A1_XFONE2 	:=  cValtoChar(oObj:A1_XFONE2)
		A1_XCELULA 	:=  cValtoChar(oObj:A1_XCELULA)
		A1_CODPAIS 	:=  cValtoChar(oObj:A1_CODPAIS)
		A1_CONTRIB :=  cValtoChar(oObj:A1_CONTRIB)
		A1_CONTA 	:=  cValtoChar(oObj:A1_CONTA)
		A1_NATUREZ 	:=  cValtoChar(oObj:A1_NATUREZ)
		A1_COND 	:=  cValtoChar(oObj:A1_COND)
		A1_RISCO 	:=  cValtoChar(oObj:A1_RISCO)
		A1_TABELA 	:=  cValtoChar(oObj:A1_TABELA)
		A1_TRANSP 	:=  cValtoChar(oObj:A1_TRANSP)
		A1_VEND 	:=  cValtoChar(oObj:A1_VEND)
		A1_GRPTRIB 	:=  cValtoChar(oObj:A1_GRPTRIB)

		If cdempresa == "" .Or. cdfilial == ""
			cResponse := '{"message":"Parametros Incorretos"}'			
			SetRestFault(400, "Bad request")
		Else
			aVetor:= {{"A1_CGC"		,A1_CGC 		,.T.},;
			{"A1_COD" 		,A1_COD 		,.T.},;
			{"A1_LOJA" 		,A1_LOJA 		,.T.},;
			{"A1_NOME"		,NoAcento(A1_NOME),.T.},;
			{"A1_NREDUZ"	,NoAcento(A1_NREDUZ),.T.},;
			{"A1_CEP"		,A1_CEP			,.T.},;
			{"A1_END"		,NoAcento(DecodeUTF8(A1_END)),.T.},;
			{"A1_BAIRRO"	,NoAcento(DecodeUTF8(A1_BAIRRO)),.T.},;
			{"A1_TIPO"		,A1_TIPO		,.T.},;
			{"A1_DDD"		,A1_DDD 		,.T.},;
			{"A1_TEL"		,A1_TEL 		,.T.},;
			{"A1_EST"	   	,A1_EST			,.T.},;
			{"A1_MUN"		,NoAcento(DecodeUTF8(A1_MUN)),.T.},;
			{"A1_COD_MUN"	,A1_COD_MUN		,.T.},;
			{"A1_PAIS"		,A1_PAIS 		,.T.},;
			{"A1_PESSOA"	,A1_PESSOA		,.T.},;
			{"A1_INSCR"		,A1_INSCR 		,.T.},;
			{"A1_INSCRM"	,A1_INSCRM 		,.T.},;
			{"A1_EMAIL"		,NoAcento(A1_EMAIL),.T.},;
			{"A1_INSCRUR"	,A1_INSCRUR 	,.T.},;
			{"A1_XFONE2"	,A1_XFONE2 		,.T.},;
			{"A1_XCELULA"	,A1_XCELULA 	,.T.},;
			{"A1_CODPAIS"	,A1_CODPAIS		,.T.},;
			{"A1_CONTRIB"	,A1_CONTRIB		,.T.},;
			{"A1_CONTA"		,A1_CONTA		,.T.},;
			{"A1_NATUREZ"	,A1_NATUREZ		,.T.},;
			{"A1_COND"		,A1_COND 		,.T.},;
			{"A1_RISCO"		,A1_RISCO 		,.T.},;
			{"A1_TABELA"	,A1_TABELA 		,.T.},;
			{"A1_TRANSP"	,A1_TRANSP 		,.T.},;
			{"A1_VEND"		,A1_VEND 		,.T.},;
			{"A1_GRPTRIB"	,A1_GRPTRIB		,.T.},;
			{"A1_XUSER"		,cMail			,.T.}} 

			cResponse := WSFLUIG019(cdempresa, cdfilial, 2, aVetor, "Cod:"+A1_COD+" Loja:"+A1_LOJA+" Descr:"+A1_NREDUZ+" Cnpj:"+A1_CGC,cMail,CSOLIC)
		EndIf

	Else

		cResponse := '{"message":"Parametros Incorretos"}'			
		SetRestFault(400, "Bad request")

	EndIf


	::SetResponse(cResponse)
Return .T.
/*/{Protheus.doc} POST
//TODO Declaração do Metodo WSFLUIG019(cdempresa, cdfilial, cOper, aVetor, cCodCli)
@author Jair Matos
@since 30/07/2019
@version 1.0
/*/
Static Function WSFLUIG019(cdempresa, cdfilial, cOper, aVetor, cCodCli,cMail,CSOLIC)
	Local cJson := ""
	Local nPos := 1
	Local aReturn := {}
	Local Filial := ""
	Local SM0_aux := ""
	Local lCont := .T.
	Local cQuery := ""
	Local cAlQry	:= ""
	Local lRet	:= .F.
	Local nPosCod  := aScan(aVetor,{|x| AllTrim(x[1]) == "A1_COD"})
	Local nPosLoj  := aScan(aVetor,{|x| AllTrim(x[1]) == "A1_LOJA"})
	Local nPosNom  := aScan(aVetor,{|x| AllTrim(x[1]) == "A1_NREDUZ"})
	Local nPosCgc  := aScan(aVetor,{|x| AllTrim(x[1]) == "A1_CGC"})


	aReturn := U_WSFLG020( aVetor, cOper, cdempresa, cdfilial )

	If aReturn[1]
		cJson := '{"A1_COD":"'+ cCodCli +'"}'
		//Envia email com codigo criado
		U_EMailSA(aVetor[nPosCod,2],aVetor[nPosLoj,2],aVetor[nPosNom,2],aVetor[nPosCgc,2],cMail,"2",cOper,CSOLIC)
	Else
		cJson := '{'+CRLF
		cJson += '"erro": true,'+CRLF
		cJson += '"message":'
		cJson += '"' + FTEXECAUTO(EncodeUTF8(cvaltochar(aReturn[2]))) + '"'
		cJson += '}'
	EndIf
Return cJson
/*/{Protheus.doc} POST
//TODO Declaração do Metodo GetCodFaixa(cEmp, cFil, cxLocal, cxTipo, cxClass, cGrupo)
@author Jair Matos
@since 30/07/2019
@version 1.0
/*/ 
Static Function GetCodFaixa(cEmp, cFil,cFaixa,cCGC)
	Local cAux		:= ""
	Local cCodSA1 	:= cFaixa
	Local cCodigo 	:= ""
	Local cRet 		:= ""
	Local cRetFaixa := ""
	dbCloseAll()
	cEmpAnt	:= cEmp
	cFilAnt	:= cFil
	OpenSM0(cEmpAnt+cFilAnt)
	OpenFile(cEmpAnt+cFilAnt)
	//1 - verifica se cnpj já existe
	cRetFaixa := U_COMX003C(cCGC,cFaixa,2)
	If cFaixa == Alltrim(cRetFaixa)
		If cCodSA1 =="1"  //Clientes Intercompany  100000 - 199999
			cCodigo := "MV_XFX1CLI"
		ElseIf cCodSA1 =="2"//Clientes Diversos  200000-299999
			cCodigo := "MV_XFX2CLI"
		ElseIf cCodSA1 =="3"//Operadoras de Cartões  300000-399999
			cCodigo := "MV_XFX3CLI"
		ElseIf cCodSA1 =="4"//Consumidor Final 400000-499999
			cCodigo := "MV_XFX4CLI"
		ElseIf cCodSA1 =="9"//Cliente Padrão Restaurantes  900000-999999
			cCodigo := "MV_XFX9CLI"
		EndIf
		dbSelectArea("SX6")  //Tabela de Parametros
		SX6->(DBSetOrder(1)) //X6_FIL+X6_VAR
		If(SX6->(DbSeek(xFilial('SX6')+cCodigo)) )
			cRet := SOMA1(ALLTRIM(SX6->X6_CONTEUD))
		EndIF
	Else
		cRet := cRetFaixa		
	EndIf

Return cRet
/*/{Protheus.doc} POST
//TODO Declaração do Metodo FTEXECAUTO
@author Jair Matos
@since 30/07/2019
@version 1.0
/*/
Static Function FTEXECAUTO(cErro)
	Local cErroAtual := cErro
	Local cErraTrat := ""
	Local cIniString := "Mensagem do erro:"
	Local cFimString := "Id do campo de erro:"
	Local aArray := {}
	Local nX := 0


	aArray := StrToKarr( cErroAtual , Chr(13) + Chr(10))
	If AScan( aArray,cFimString) == 0
		cErraTrat += " "
		For nX:= AScan( aArray, cIniString) to  len(aArray)
			cErraTrat += aArray[nX]
		Next
	Else
		cErraTrat := aArray[AScan( aArray,cFimString)]
		cErraTrat += " "
		For nX:= AScan( aArray, cIniString) to  AScan( aArray, "Id do formulario de erro:",AScan( aArray, cIniString)) -1
			cErraTrat += aArray[nX]
		Next
	EndIf
	cErraTrat:=StrTran( cErraTrat, "-", "" )
	cErraTrat:=StrTran( cErraTrat, Chr(13) + Chr(10), "" )
	cErraTrat:=StrTran( cErraTrat, '"', "'" )

Return cErraTrat
