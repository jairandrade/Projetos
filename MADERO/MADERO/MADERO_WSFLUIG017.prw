#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "AP5MAIL.CH"

/*/{Protheus.doc} GetGruposFornecedores
//TODO Declaração do WebService WSFornecedorFLuig
@author Jair Matos
@since 26/07/2019
@version 1.0
alteração 15-04-2020 - validar a rotina GETCODFAIXA e incluir o parametro MV_XFX4FOR na rotina.
alteração 18-05-2020 - incluir o campo A2_CPFIRP na rotina.
/*/

WSRESTFUL WSFornecedorFLuig DESCRIPTION "Madero - CRUD de Fornecedores enviados via FLUIG - FLUIG"

WSMETHOD POST 	DESCRIPTION "Gravação de Fornecedores enviados via FLUIG" 	WSSYNTAX "/WSFornecedorFLuig"
WSMETHOD PUT 	DESCRIPTION "Edição de Fornecedores enviados via FLUIG" 	WSSYNTAX "/WSFornecedorFLuig"

END WSRESTFUL


/*/{Protheus.doc} POST
//TODO Declaração do Metodo WSFornecedorFLuig
@author Jair Matos 
@since 26/07/2019
@version 1.0
/*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE WSFornecedorFLuig

	Local cResponse		:= ""
	Local cBody
	Local oObj
	Local cdempresa 	:= ""
	Local cdfilial 
	Local cMail			:= ""
	Local xFaixa		:= ""
	Local CSOLIC		:= ""
	Local aVetor		:= {}
	LOCAL A2_TIPO 		:= ""  
	Local A2_COD		:= ""
	Local A2_LOJA		:= ""
	LOCAL A2_NOME 		:= "" 
	LOCAL A2_NREDUZ 	:= "" 
	LOCAL A2_CEP 		:= "" 
	LOCAL A2_COD_MUN 	:= "" 
	LOCAL A2_MUN 		:= "" 
	LOCAL A2_EST 		:= "" 
	LOCAL A2_BAIRRO 	:= "" 
	LOCAL A2_END 		:= "" 
	LOCAL A2_NR_END		:= ""
	LOCAL A2_COMPLEM 	:= "" 
	LOCAL A2_CX_POST 	:= "" 
	LOCAL A2_PAIS 		:= ""  
	LOCAL A2_DDD 		:= "" 
	LOCAL A2_TEL 		:= "" 
	LOCAL A2_CONTATO 	:= "" 
	LOCAL A2_EMAIL 		:= "" 
	LOCAL A2_CGC 		:= "" 
	LOCAL A2_PFISICA 	:= "" 
	LOCAL A2_INSCR 		:= "" 
	LOCAL A2_INSCRM 	:= "" 
	LOCAL A2_CONTRIB 	:= "" 
	LOCAL A2_SIMPNAC 	:= "" 
	LOCAL A2_TPJ 		:= "" 
	LOCAL A2_TRANSP 	:= ""
	LOCAL A2_CODPAIS 	:= "" 
	LOCAL A2_BANCO 		:= "" 
	LOCAL A2_AGENCIA 	:= "" 
	LOCAL A2_NUMCON 	:= "" 
	LOCAL A2_TIPCTA 	:= "" 
	LOCAL A2_CONTA 		:= "" 
	LOCAL A2_NATUREZ 	:= "" 
	LOCAL A2_COND 		:= "" 
	LOCAL A2_CODADM 	:= "" 
	LOCAL A2_FORMPAG 	:= "" 
	LOCAL A2_DVCTA 		:= "" 
	LOCAL A2_DVAGE 		:= "" 
	LOCAL A2_GRPTRIB 	:= "" 
	LOCAL A2_CALCIRF 	:= "" 
	LOCAL A2_IRPROG 	:= "" 
	LOCAL A2_MINIRF 	:= "" 
	LOCAL A2_RECPIS 	:= "" 
	LOCAL A2_RECCOFI 	:= "" 
	LOCAL A2_RECCSLL 	:= "" 
	LOCAL A2_RECISS 	:= "" 
	LOCAL A2_RECINSS 	:= "" 
	LOCAL A2_CPRB 		:= "" 
	LOCAL A2_INDRUR 	:= "" 
	LOCAL A2_CPFIRP		:= ""
	LOCAL A2_XGERINT	:= ""

	::SetContentType("application/json")

	cBody := ::GetContent()


	If FWJsonDeserialize(cBody,@oObj)
		cdempresa 	:= cValtoChar(oObj:cdempresa)
		cdfilial 	:= cValtoChar(oObj:cdfilial)  
		xFaixa 		:= cValtoChar(oObj:xFaixa) 
		cMail		:= cValtoChar(oObj:cMail) 
		CSOLIC		:= cValtoChar(oObj:CSOLIC)
		A2_TIPO 	:= cValtoChar(oObj:A2_TIPO) 
		A2_NOME 	:= cValtoChar(oObj:A2_NOME) 
		A2_NREDUZ 	:= cValtoChar(oObj:A2_NREDUZ)
		A2_END 		:= cValtoChar(oObj:A2_END) 
		A2_NR_END 	:= cValtoChar(oObj:A2_NR_END) 
		A2_BAIRRO 	:= cValtoChar(oObj:A2_BAIRRO) 
		A2_COMPLEM 	:= cValtoChar(oObj:A2_COMPLEM) 
		A2_CX_POST 	:= cValtoChar(oObj:A2_CX_POST)  
		A2_CEP 		:= cValtoChar(oObj:A2_CEP) 
		A2_EST 		:= cValtoChar(oObj:A2_EST) 
		A2_COD_MUN 	:= cValtoChar(oObj:A2_COD_MUN) 
		A2_MUN 		:= cValtoChar(oObj:A2_MUN) 
		A2_PAIS 	:= cValtoChar(oObj:A2_PAIS) 
		A2_DDD 		:= cValtoChar(oObj:A2_DDD) 
		A2_TEL 		:= cValtoChar(oObj:A2_TEL) 
		A2_CONTATO 	:= cValtoChar(oObj:A2_CONTATO) 
		A2_EMAIL 	:= cValtoChar(oObj:A2_EMAIL) 
		A2_CGC 		:= cValtoChar(oObj:A2_CGC) 
		A2_PFISICA 	:= cValtoChar(oObj:A2_PFISICA) 
		A2_INSCR 	:= cValtoChar(oObj:A2_INSCR) 
		A2_INSCRM 	:= cValtoChar(oObj:A2_INSCRM) 
		A2_CONTRIB 	:= cValtoChar(oObj:A2_CONTRIB) 
		A2_SIMPNAC 	:= cValtoChar(oObj:A2_SIMPNAC) 
		A2_TPJ 		:= cValtoChar(oObj:A2_TPJ) 
		A2_TRANSP 	:= cValtoChar(oObj:A2_TRANSP) 
		A2_CODPAIS 	:= cValtoChar(oObj:A2_CODPAIS)
		A2_BANCO 	:= cValtoChar(oObj:A2_BANCO) 
		A2_AGENCIA 	:= cValtoChar(oObj:A2_AGENCIA) 
		A2_NUMCON 	:= cValtoChar(oObj:A2_NUMCON) 
		A2_TIPCTA 	:= cValtoChar(oObj:A2_TIPCTA) 
		A2_CONTA 	:= cValtoChar(oObj:A2_CONTA) 
		A2_NATUREZ 	:= cValtoChar(oObj:A2_NATUREZ) 
		A2_COND 	:= cValtoChar(oObj:A2_COND) 
		A2_CODADM 	:= cValtoChar(oObj:A2_CODADM) 
		A2_FORMPAG 	:= cValtoChar(oObj:A2_FORMPAG) 
		A2_DVCTA 	:= cValtoChar(oObj:A2_DVCTA) 
		A2_DVAGE 	:= cValtoChar(oObj:A2_DVAGE) 
		A2_GRPTRIB 	:= cValtoChar(oObj:A2_GRPTRIB) 
		A2_CALCIRF 	:= cValtoChar(oObj:A2_CALCIRF) 
		A2_IRPROG 	:= cValtoChar(oObj:A2_IRPROG) 
		A2_MINIRF 	:= cValtoChar(oObj:A2_MINIRF) 
		A2_RECPIS 	:= cValtoChar(oObj:A2_RECPIS) 
		A2_RECCOFI 	:= cValtoChar(oObj:A2_RECCOFI) 
		A2_RECCSLL 	:= cValtoChar(oObj:A2_RECCSLL)
		A2_RECISS 	:= cValtoChar(oObj:A2_RECISS)
		A2_RECINSS 	:= cValtoChar(oObj:A2_RECINSS)
		A2_CPRB 	:= cValtoChar(oObj:A2_CPRB)
		A2_INDRUR 	:= cValtoChar(oObj:A2_INDRUR)
		A2_XGERINT	:= cValtoChar(oObj:A2_XGERINT)
		A2_CPFIRP	:= cValtoChar(oObj:A2_CPFIRP)

		If cdempresa == "" .Or. cdfilial == ""
			cResponse := '{"message":"Parametros Incorretos"}'			
			SetRestFault(400, "Bad request")
		Else
			A2_COD := GetCodFaixa(cdempresa, cdfilial,xFaixa,A2_CGC)
			A2_LOJA :=U_COMX002L(A2_CGC,xFaixa)

			If A2_IRPROG =="1"
				aVetor:= {{"A2_TIPO" 		,A2_TIPO 		,.T.},;
				{"A2_COD" 		,A2_COD 		,.T.},;
				{"A2_LOJA" 		,A2_LOJA 		,.T.},;
				{"A2_NOME"		,NoAcento(A2_NOME),.T.},;
				{"A2_NREDUZ"	,NoAcento(A2_NREDUZ),.T.},;
				{"A2_END"		,NoAcento(DecodeUTF8(A2_END)+", "+A2_NR_END),.T.},;
				{"A2_BAIRRO"	,NoAcento(DecodeUTF8(A2_BAIRRO)),.T.},;
				{"A2_COMPLEM"	,NoAcento(A2_COMPLEM),.T.},;
				{"A2_CX_POST"	,A2_CX_POST 	,.T.},;
				{"A2_CEP"		,A2_CEP			,.T.},;
				{"A2_EST"	   	,A2_EST			,.T.},;
				{"A2_COD_MUN"	,A2_COD_MUN		,.T.},;
				{"A2_MUN"		,NoAcento(DecodeUTF8(A2_MUN)),.T.},;
				{"A2_PAIS"		,A2_PAIS 		,.T.},;
				{"A2_DDD"		,A2_DDD 		,.T.},;
				{"A2_TEL"		,A2_TEL 		,.T.},;
				{"A2_CONTATO"	,NoAcento(A2_CONTATO),.T.},;
				{"A2_EMAIL"		,NoAcento(A2_EMAIL),.T.},;
				{"A2_CGC"		,A2_CGC 		,.T.},;
				{"A2_PFISICA"	,A2_PFISICA 	,.T.},;
				{"A2_INSCR"		,A2_INSCR 		,.T.},;
				{"A2_INSCRM"	,A2_INSCRM 		,.T.},;
				{"A2_CONTRIB"	,A2_CONTRIB		,.T.},;
				{"A2_SIMPNAC"	,A2_SIMPNAC 	,.T.},;
				{"A2_TPJ"		,A2_TPJ 		,.T.},;
				{"A2_TRANSP"	,A2_TRANSP 		,.T.},;
				{"A2_CODPAIS"	,A2_CODPAIS 	,.T.},;
				{"A2_BANCO"		,A2_BANCO		,.T.},;
				{"A2_AGENCIA"	,A2_AGENCIA		,.T.},;
				{"A2_NUMCON"	,A2_NUMCON		,.T.},;
				{"A2_TIPCTA"	,A2_TIPCTA		,.T.},;
				{"A2_CONTA"		,A2_CONTA 		,.T.},;
				{"A2_NATUREZ"	,A2_NATUREZ 	,.T.},;
				{"A2_COND"		,A2_COND 		,.T.},;
				{"A2_CODADM"	,A2_CODADM 		,.T.},;
				{"A2_FORMPAG"	,A2_FORMPAG 	,.T.},;
				{"A2_DVCTA"		,A2_DVCTA		,.T.},;
				{"A2_DVAGE"		,A2_DVAGE		,.T.},;
				{"A2_GRPTRIB"	,A2_GRPTRIB		,.T.},;
				{"A2_CALCIRF"	,A2_CALCIRF		,.T.},;
				{"A2_MINIRF"	,A2_MINIRF 		,.T.},;
				{"A2_IRPROG"	,A2_IRPROG 		,.T.},;
				{"A2_CPFIRP"	,A2_CPFIRP 		,.T.},;
				{"A2_RECPIS"	,A2_RECPIS		,.T.},;
				{"A2_RECCOFI"	,A2_RECCOFI 	,.T.},;
				{"A2_RECCSLL"	,A2_RECCSLL		,.T.},;
				{"A2_RECISS"	,A2_RECISS		,.T.},;
				{"A2_RECINSS"	,A2_RECINSS		,.T.},;
				{"A2_CPRB"		,A2_CPRB		,.T.},;
				{"A2_INDRUR"	,A2_INDRUR		,.T.},;
				{"A2_XGERINT"	,A2_XGERINT		,.T.}}  
			Else
				aVetor:= {{"A2_TIPO" 		,A2_TIPO 		,.T.},;
				{"A2_COD" 		,A2_COD 		,.T.},;
				{"A2_LOJA" 		,A2_LOJA 		,.T.},;
				{"A2_NOME"		,NoAcento(A2_NOME),.T.},;
				{"A2_NREDUZ"	,NoAcento(A2_NREDUZ),.T.},;
				{"A2_END"		,NoAcento(DecodeUTF8(A2_END)+", "+A2_NR_END),.T.},;
				{"A2_BAIRRO"	,NoAcento(DecodeUTF8(A2_BAIRRO)),.T.},;
				{"A2_COMPLEM"	,NoAcento(A2_COMPLEM),.T.},;
				{"A2_CX_POST"	,A2_CX_POST 	,.T.},;
				{"A2_CEP"		,A2_CEP			,.T.},;
				{"A2_EST"	   	,A2_EST			,.T.},;
				{"A2_COD_MUN"	,A2_COD_MUN		,.T.},;
				{"A2_MUN"		,NoAcento(DecodeUTF8(A2_MUN)),.T.},;
				{"A2_PAIS"		,A2_PAIS 		,.T.},;
				{"A2_DDD"		,A2_DDD 		,.T.},;
				{"A2_TEL"		,A2_TEL 		,.T.},;
				{"A2_CONTATO"	,NoAcento(A2_CONTATO),.T.},;
				{"A2_EMAIL"		,NoAcento(A2_EMAIL),.T.},;
				{"A2_CGC"		,A2_CGC 		,.T.},;
				{"A2_PFISICA"	,A2_PFISICA 	,.T.},;
				{"A2_INSCR"		,A2_INSCR 		,.T.},;
				{"A2_INSCRM"	,A2_INSCRM 		,.T.},;
				{"A2_CONTRIB"	,A2_CONTRIB		,.T.},;
				{"A2_SIMPNAC"	,A2_SIMPNAC 	,.T.},;
				{"A2_TPJ"		,A2_TPJ 		,.T.},;
				{"A2_TRANSP"	,A2_TRANSP 		,.T.},;
				{"A2_CODPAIS"	,A2_CODPAIS 	,.T.},;
				{"A2_BANCO"		,A2_BANCO		,.T.},;
				{"A2_AGENCIA"	,A2_AGENCIA		,.T.},;
				{"A2_NUMCON"	,A2_NUMCON		,.T.},;
				{"A2_TIPCTA"	,A2_TIPCTA		,.T.},;
				{"A2_CONTA"		,A2_CONTA 		,.T.},;
				{"A2_NATUREZ"	,A2_NATUREZ 	,.T.},;
				{"A2_COND"		,A2_COND 		,.T.},;
				{"A2_CODADM"	,A2_CODADM 		,.T.},;
				{"A2_FORMPAG"	,A2_FORMPAG 	,.T.},;
				{"A2_DVCTA"		,A2_DVCTA		,.T.},;
				{"A2_DVAGE"		,A2_DVAGE		,.T.},;
				{"A2_GRPTRIB"	,A2_GRPTRIB		,.T.},;
				{"A2_CALCIRF"	,A2_CALCIRF		,.T.},;
				{"A2_IRPROG"	,A2_IRPROG 		,.T.},;
				{"A2_MINIRF"	,A2_MINIRF 		,.T.},;
				{"A2_RECPIS"	,A2_RECPIS		,.T.},;
				{"A2_RECCOFI"	,A2_RECCOFI 	,.T.},;
				{"A2_RECCSLL"	,A2_RECCSLL		,.T.},;
				{"A2_RECISS"	,A2_RECISS		,.T.},;
				{"A2_RECINSS"	,A2_RECINSS		,.T.},;
				{"A2_CPRB"		,A2_CPRB		,.T.},;
				{"A2_INDRUR"	,A2_INDRUR		,.T.},;
				{"A2_XGERINT"	,A2_XGERINT		,.T.}}  

			Endif

			cResponse := WSFLUIG017(cdempresa, cdfilial, 1, aVetor, "Cod:"+A2_COD+" Loja:"+A2_LOJA+" Descr:"+A2_NREDUZ+" Cnpj:"+A2_CGC,cMail,CSOLIC)
		EndIf

	Else

		cResponse := '{"message":"Parametros Incorretos"}'			
		SetRestFault(400, "Bad request")

	EndIf


	::SetResponse(cResponse)
Return .T.

/*/{Protheus.doc} POST
//TODO Declaração do Metodo WSFornecedorFLuig
@author Jair Matos
@since 26/07/2019
@version 1.0
/*/
WSMETHOD PUT WSRECEIVE NULLPARAM WSSERVICE WSFornecedorFLuig

	Local cResponse		:= ""
	Local cBody
	Local oObj
	Local cdempresa 	:= ""
	Local cdfilial 
	Local cMail			:= ""
	Local CSOLIC		:= ""
	Local aVetor		:= {}
	LOCAL A2_COD 		:= ""  
	LOCAL A2_LOJA 		:= ""  
	LOCAL A2_TIPO 		:= ""  
	LOCAL A2_NOME 		:= "" 
	LOCAL A2_NREDUZ 	:= "" 
	LOCAL A2_CEP 		:= "" 
	LOCAL A2_COD_MUN 	:= "" 
	LOCAL A2_MUN 		:= "" 
	LOCAL A2_EST 		:= "" 
	LOCAL A2_BAIRRO 	:= "" 
	LOCAL A2_END 		:= "" 
	LOCAL A2_NR_END		:= ""
	LOCAL A2_COMPLEM 	:= "" 
	LOCAL A2_CX_POST 	:= "" 
	LOCAL A2_PAIS 		:= ""  
	LOCAL A2_DDD 		:= "" 
	LOCAL A2_TEL 		:= "" 
	LOCAL A2_CONTATO 	:= "" 
	LOCAL A2_EMAIL 		:= "" 
	LOCAL A2_CGC 		:= "" 
	LOCAL A2_PFISICA 	:= "" 
	LOCAL A2_INSCR 		:= "" 
	LOCAL A2_INSCRM 	:= "" 
	LOCAL A2_CONTRIB 	:= "" 
	LOCAL A2_SIMPNAC 	:= "" 
	LOCAL A2_TPJ 		:= "" 
	LOCAL A2_TRANSP 	:= ""
	LOCAL A2_CODPAIS 	:= "" 
	LOCAL A2_BANCO 		:= "" 
	LOCAL A2_AGENCIA 	:= "" 
	LOCAL A2_NUMCON 	:= "" 
	LOCAL A2_TIPCTA 	:= "" 
	LOCAL A2_CONTA 		:= "" 
	LOCAL A2_NATUREZ 	:= "" 
	LOCAL A2_COND 		:= "" 
	LOCAL A2_CODADM 	:= "" 
	LOCAL A2_FORMPAG 	:= "" 
	LOCAL A2_DVCTA 		:= "" 
	LOCAL A2_DVAGE 		:= "" 
	LOCAL A2_GRPTRIB 	:= "" 
	LOCAL A2_CALCIRF 	:= "" 
	LOCAL A2_IRPROG 	:= "" 
	LOCAL A2_MINIRF 	:= "" 
	LOCAL A2_RECPIS 	:= "" 
	LOCAL A2_RECCOFI 	:= "" 
	LOCAL A2_RECCSLL 	:= "" 
	LOCAL A2_RECISS 	:= "" 
	LOCAL A2_RECINSS 	:= "" 
	LOCAL A2_CPRB 		:= "" 
	LOCAL A2_INDRUR 	:= "" 
	LOCAL A2_CPFIRP		:= ""
	LOCAL A2_XGERINT		:= ""

	::SetContentType("application/json")

	cBody := ::GetContent()


	If FWJsonDeserialize(cBody,@oObj)
		cdempresa 	:= cValtoChar(oObj:cdempresa)
		cdfilial 	:= cValtoChar(oObj:cdfilial) 
		cMail		:= cValtoChar(oObj:cMail)
		CSOLIC		:= cValtoChar(oObj:CSOLIC)
		A2_COD 		:= cValtoChar(oObj:A2_COD)
		A2_LOJA		:=cValtoChar(oObj:A2_LOJA)
		A2_TIPO 	:= cValtoChar(oObj:A2_TIPO) 
		A2_NOME 	:= cValtoChar(oObj:A2_NOME) 
		A2_NREDUZ 	:= cValtoChar(oObj:A2_NREDUZ) 
		A2_CEP 		:= cValtoChar(oObj:A2_CEP) 
		A2_COD_MUN 	:= cValtoChar(oObj:A2_COD_MUN) 
		A2_MUN 		:= cValtoChar(oObj:A2_MUN) 
		A2_EST 		:= cValtoChar(oObj:A2_EST) 
		A2_BAIRRO 	:= cValtoChar(oObj:A2_BAIRRO) 
		A2_END 		:= cValtoChar(oObj:A2_END) 
		A2_NR_END 	:= cValtoChar(oObj:A2_NR_END) 
		A2_COMPLEM 	:= cValtoChar(oObj:A2_COMPLEM) 
		A2_CX_POST 	:= cValtoChar(oObj:A2_CX_POST)
		A2_PAIS 	:= cValtoChar(oObj:A2_PAIS) 
		A2_DDD 		:= cValtoChar(oObj:A2_DDD) 
		A2_TEL 		:= cValtoChar(oObj:A2_TEL) 
		A2_CONTATO 	:= cValtoChar(oObj:A2_CONTATO) 
		A2_EMAIL 	:= cValtoChar(oObj:A2_EMAIL) 
		A2_CGC 		:= cValtoChar(oObj:A2_CGC) 
		A2_PFISICA 	:= cValtoChar(oObj:A2_PFISICA) 
		A2_INSCR 	:= cValtoChar(oObj:A2_INSCR) 
		A2_INSCRM 	:= cValtoChar(oObj:A2_INSCRM) 
		A2_CONTRIB 	:= cValtoChar(oObj:A2_CONTRIB) 
		A2_SIMPNAC 	:= cValtoChar(oObj:A2_SIMPNAC) 
		A2_TPJ 		:= cValtoChar(oObj:A2_TPJ) 
		A2_TRANSP 	:= cValtoChar(oObj:A2_TRANSP) 
		A2_CODPAIS 	:= cValtoChar(oObj:A2_CODPAIS) 
		A2_BANCO 	:= cValtoChar(oObj:A2_BANCO) 
		A2_AGENCIA 	:= cValtoChar(oObj:A2_AGENCIA) 
		A2_NUMCON 	:= cValtoChar(oObj:A2_NUMCON) 
		A2_TIPCTA 	:= cValtoChar(oObj:A2_TIPCTA) 
		A2_CONTA 	:= cValtoChar(oObj:A2_CONTA) 
		A2_NATUREZ 	:= cValtoChar(oObj:A2_NATUREZ) 
		A2_COND 	:= cValtoChar(oObj:A2_COND) 
		A2_CODADM 	:= cValtoChar(oObj:A2_CODADM) 
		A2_FORMPAG 	:= cValtoChar(oObj:A2_FORMPAG) 
		A2_DVCTA 	:= cValtoChar(oObj:A2_DVCTA) 
		A2_DVAGE 	:= cValtoChar(oObj:A2_DVAGE) 
		A2_GRPTRIB 	:= cValtoChar(oObj:A2_GRPTRIB) 
		A2_CALCIRF 	:= cValtoChar(oObj:A2_CALCIRF) 
		A2_IRPROG 	:= cValtoChar(oObj:A2_IRPROG) 
		A2_MINIRF 	:= cValtoChar(oObj:A2_MINIRF) 
		A2_RECPIS 	:= cValtoChar(oObj:A2_RECPIS) 
		A2_RECCOFI 	:= cValtoChar(oObj:A2_RECCOFI) 
		A2_RECCSLL 	:= cValtoChar(oObj:A2_RECCSLL)
		A2_RECISS 	:= cValtoChar(oObj:A2_RECISS)
		A2_RECINSS 	:= cValtoChar(oObj:A2_RECINSS)
		A2_CPRB 	:= cValtoChar(oObj:A2_CPRB)
		A2_INDRUR 	:= cValtoChar(oObj:A2_INDRUR)
		A2_XGERINT	:= cValtoChar(oObj:A2_XGERINT)
		A2_CPFIRP	:= cValtoChar(oObj:A2_CPFIRP)

		If cdempresa == "" .Or. cdfilial == ""
			cResponse := '{"message":"Parametros Incorretos"}'			
			SetRestFault(400, "Bad request")
		Else
			aVetor:= { {"A2_COD" 		,A2_COD 		,.T.},;
			{"A2_LOJA" 		,A2_LOJA 		,.T.},;
			{"A2_TIPO" 		,A2_TIPO 		,.T.},;
			{"A2_NOME"		,NoAcento(A2_NOME),.T.},;
			{"A2_NREDUZ"	,NoAcento(A2_NREDUZ),.T.},;
			{"A2_CEP"		,A2_CEP			,.T.},;
			{"A2_COD_MUN"	,A2_COD_MUN		,.T.},;
			{"A2_MUN"		,NoAcento(DecodeUTF8(A2_MUN)),.T.},;
			{"A2_EST"	   	,A2_EST			,.T.},;
			{"A2_BAIRRO"   	,NoAcento(DecodeUTF8(A2_BAIRRO)),.T.},;
			{"A2_END"		,NoAcento(DecodeUTF8(A2_END)),.T.},;
			{"A2_NR_END"	,A2_NR_END		,.T.},;
			{"A2_COMPLEM"	,NoAcento(A2_COMPLEM),.T.},;
			{"A2_CX_POST"	,A2_CX_POST 	,.T.},;
			{"A2_PAIS"		,A2_PAIS 		,.T.},;
			{"A2_DDD"		,A2_DDD 		,.T.},;
			{"A2_TEL"		,A2_TEL 		,.T.},;
			{"A2_CONTATO"	,NoAcento(A2_CONTATO),.T.},;
			{"A2_EMAIL"		,NoAcento(A2_EMAIL),.T.},;
			{"A2_CGC"		,A2_CGC 		,.T.},;
			{"A2_PFISICA"	,A2_PFISICA 	,.T.},;
			{"A2_INSCR"		,A2_INSCR 		,.T.},;
			{"A2_INSCRM"	,A2_INSCRM 		,.T.},;
			{"A2_CONTRIB"	,A2_CONTRIB		,.T.},;
			{"A2_SIMPNAC"	,A2_SIMPNAC 	,.T.},;
			{"A2_TPJ"		,A2_TPJ 		,.T.},;
			{"A2_TRANSP"	,A2_TRANSP 		,.T.},;
			{"A2_CODPAIS"	,A2_CODPAIS		,.T.},;
			{"A2_BANCO"		,A2_BANCO		,.T.},;
			{"A2_AGENCIA"	,A2_AGENCIA		,.T.},;
			{"A2_NUMCON"	,A2_NUMCON		,.T.},;
			{"A2_TIPCTA"	,A2_TIPCTA		,.T.},;
			{"A2_CONTA"		,A2_CONTA 		,.T.},;
			{"A2_NATUREZ"	,A2_NATUREZ 	,.T.},;
			{"A2_COND"		,A2_COND 		,.T.},;
			{"A2_CODADM"	,A2_CODADM 		,.T.},;
			{"A2_FORMPAG"	,A2_FORMPAG 	,.T.},;
			{"A2_DVCTA"		,A2_DVCTA		,.T.},;
			{"A2_DVAGE"		,A2_DVAGE		,.T.},;
			{"A2_GRPTRIB"	,A2_GRPTRIB		,.T.},;
			{"A2_CALCIRF"	,A2_CALCIRF		,.T.},;
			{"A2_IRPROG"	,A2_IRPROG 		,.T.},;
			{"A2_MINIRF"	,A2_MINIRF 		,.T.},;
			{"A2_RECPIS"	,A2_RECPIS		,.T.},;
			{"A2_RECCOFI"	,A2_RECCOFI 	,.T.},;
			{"A2_RECCSLL"	,A2_RECCSLL		,.T.},;
			{"A2_RECISS"	,A2_RECISS		,.T.},;
			{"A2_RECINSS"	,A2_RECINSS		,.T.},;
			{"A2_CPRB"		,A2_CPRB		,.T.},;
			{"A2_INDRUR"	,A2_INDRUR		,.T.},;
			{"A2_XGERINT"	,A2_XGERINT		,.T.}}

			cResponse := WSFLUIG017(cdempresa, cdfilial, 2, aVetor,"Cod:"+A2_COD+" Loja:"+A2_LOJA+" Descr:"+A2_NREDUZ+" Cnpj:"+A2_CGC,cMail,CSOLIC)
		EndIf

	Else

		cResponse := '{"message":"Parametros Incorretos"}'			
		SetRestFault(400, "Bad request")

	EndIf


	::SetResponse(cResponse)
Return .T.
/*/{Protheus.doc} POST
//TODO Declaração do Metodo WSFLUIG017(cdempresa, cdfilial, cOper, aVetor, cCodFor)
@author Jair Matos
@since 26/07/2019
@version 1.0
/*/
Static Function WSFLUIG017(cdempresa, cdfilial, cOper, aVetor, cCodFor,cMail,CSOLIC)
	Local cJson := ""
	Local nPos := 1
	Local aReturn := {}
	Local Filial := ""
	Local SM0_aux := ""
	Local lCont := .T.
	Local cQuery := ""
	Local cAlQry	:= ""
	Local lRet	:= .F.
	Local nPosCod  := aScan(aVetor,{|x| AllTrim(x[1]) == "A2_COD"})
	Local nPosLoj  := aScan(aVetor,{|x| AllTrim(x[1]) == "A2_LOJA"})
	Local nPosNom  := aScan(aVetor,{|x| AllTrim(x[1]) == "A2_NREDUZ"})
	Local nPosCgc  := aScan(aVetor,{|x| AllTrim(x[1]) == "A2_CGC"})
	aReturn := U_WSFLG018( aVetor, cOper, cdempresa, cdfilial )

	If aReturn[1]
		cJson := '{"A2_COD":"'+ cCodFor +'"}'
		//Envia email com codigo criado
		U_EMailSA(aVetor[nPosCod,2],aVetor[nPosLoj,2],aVetor[nPosNom,2],aVetor[nPosCgc,2],cMail,"1",cOper,CSOLIC)
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
@since 26/07/2019
@version 1.0
/*/
Static Function GetCodFaixa(cEmp, cFil,cFaixa,cCGC)
	Local cAux		:= ""
	Local cCodSA2 	:= cFaixa
	Local cCodigo 	:= ""
	Local cRet 		:= ""
	Local cRetFaixa := ""
	Local cEmpProx 	:= 	Iif(cEmp =="01","02","01")
	dbCloseAll()
	cEmpAnt	:= cEmp
	cFilAnt	:= cFil
	OpenSM0(cEmpAnt+cFilAnt)
	OpenFile(cEmpAnt+cFilAnt)

	//1 - verifica se cnpj já existe
	cRetFaixa := U_COMX002C(cCGC,cFaixa,2)
	If cFaixa == cRetFaixa
		If cCodSA2 =="1"   //restaurantes  100000 - 199999
			cCodigo := "MV_XFX1FOR"
		ElseIf cCodSA2 =="2"//Fornecedores Diversos  200000-399999
			cCodigo := "MV_XFX2FOR"
		ElseIf cCodSA2 =="4"//Fornecedores Aluguel  400000-499999
			cCodigo := "MV_XFX4FOR"
		ElseIf cCodSA2 =="5"//Fornecedores Exterior  500000-599999
			cCodigo := "MV_XFX5FOR"
		ElseIf cCodSA2 =="6"//Secretarias Governamentais 600000-699999
			cCodigo := "MV_XFX6FOR"
		ElseIf cCodSA2 =="7"//Bancos  700000-799999
			cCodigo := "MV_XFX7FOR"
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
@since 26/07/2019
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
/*/
Funcao:		GRVFAIXA
Autor:		Jair Matos
Data:		14/11/2018
Descricao:	Grava o Conteudo Parametro de Acordo com a Empresa de Referencia
Sintaxe:	GRVFAIXA( cEmp , cFil , uMvPar , uMvCntPut , lRpcSet )
/*/
User Function GRVFAIXA( cEmp , cFil , uMvPar , uMvCntPut , lRpcSet )

	BEGIN SEQUENCE

		IF !(;
		( IsInCallStack("U_	GRVFAIXA") );
		.or.;
		( IsInCallStack("U_GRVFAIXA") .and. Empty( ProcName(1) ) );
		)
			//Nao Permito a Chamada Direta
			BREAK
		EndIF

		DEFAULT lRpcSet	:= .F.

		IF ( lRpcSet )
			RpcSetType( 3 )
			RpcSetEnv( cEmp , cFil )
		EndIF

		If(SX6->(DbSeek(xFilial('SX6')+uMvPar)) )
			RecLock('SX6',.F.)
			SX6->X6_CONTEUD := (uMvCntPut)
			SX6->X6_CONTSPA := SX6->X6_CONTEUD
			SX6->X6_CONTENG := SX6->X6_CONTEUD
			MsUnlock()
		EndIF
		RpcClearEnv() //volta a empresa anterior
	END SEQUENCE

Return
/*/
Funcao:		EnvMail
Autor:		Jair Matos
Data:		28/01/2020
Descricao:	Envia email	para o solicitante
Sintaxe:	EnvMail(cCodigo,cLoja,cNome,cCGC,cMail)
/*/
User Function EMailSA(cCodigo,cLoja,cNome,cCGC,cMail,cOpc,cOper,CSOLIC)
	Local _cBody		:= ""  
	Local cCss 			:= ""
	Local cCssHeader 	:= ""  
	Local _cMailS		:= GetMv("MV_RELSERV")
	Local _cAccount		:= GetMV("MV_RELACNT")
	Local _cPass		:= GetMV("MV_RELFROM")
	Local _cSenha2		:= GetMV("MV_RELPSW")
	Local _cUsuario2	:= GetMV("MV_RELACNT")
	Local lAuth			:= GetMv("MV_RELAUTH",,.F.)
	Local _cSubject 	:=Iif(cOpc="1","Cadastro de Fornecedor","Cadastro de Cliente")
	Local _cNom		 	:=Iif(cOpc="1","Nome Fornecedor","Nome Cliente")
	Local _cIncAlt 		:=Iif(cOper=1,"criado","alterado")
	Local _cMailTo 		:=cMail
	Local _cCC			:= ""
	Local _cAnexo 		:=""
	Local cFonte1  		:= "<FONT FACE='Currier New'SIZE=1>"
	//Verifica se é codigo faixa 9 e inclui a informação de cliente padrão
	If substr(cCodigo,1,1) =="9"
		_cSubject := _cSubject+" Padrão"
	EndIf
	//cabecalho
	_cBody += '<HTML>'
	_cBody += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
	_cBody += '<html xmlns="http://www.w3.org/1999/xhtml">'
	_cBody += 	'<head>'
	_cBody += 		'<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
	_cBody += 		'<title>.:: Madero</title>'
	_cBody += 		'<style type="text/css">'
	_cBody += 			'<!--body,td,th {	font-family: Tahoma;	font-size: 11px;}'
	_cBody += 			'body {	margin-left: 0px;	margin-top: 0px;	margin-right: 0px;	margin-bottom: 0px;}'
	_cBody += 			'.style3 {font-size: 18px; font-weight: bold; font-family: Tahoma; color: #FFFFFF; }'
	_cBody += 			'.style4 {font-size: 14px; font-weight: bold; font-family: Tahoma; color: #FFFFFF; }-->'
	_cBody += 		'</style>'
	_cBody += 	'</head>'
	_cBody +=	'<body>'
	_cBody += 		'<br />'
	_cBody += 		'<table width="1200" height="127" border="1" align="center" cellpadding="2" cellspacing="0" bordercolor="#FFFFFF">'
	_cBody += 		'<tr>'
	_cBody += 			'<td width="716" height="70" colspan="6" align="center" valign="middle" bgcolor="#000000" class="style3">'+"MADERO - "+_cSubject+'</td>'
	_cBody += 		'</tr>'
	_cBody += 		'<tr>'
	_cBody += 			'<td height="50" colspan="6" align="middle" valign="middle" bgcolor="#4F4F4F" class="style4">'+"O "+_cSubject+" número "+cCodigo+" foi "+_cIncAlt+" com sucesso."+'</td>'
	_cBody += 		'</tr>'
	_cBody += 		'<tr>'
	_cBody += 			'<td width="20%" align="center" valign="middle" bgcolor="#C0C0C0"><b>Solicitação FLUIG</td>'
	_cBody += 	  		'<td width="30%"  align="center" valign="middle" bgcolor="#C0C0C0"><b>'+_cNom+'</td>'
	_cBody += 			'<td width="15%"  align="center" valign="middle" bgcolor="#C0C0C0"><b>Código</td>'
	_cBody += 			'<td width="15%" align="center" valign="middle" bgcolor="#C0C0C0"><b>Loja</td>'
	_cBody += 			'<td width="20%" align="center" valign="middle" bgcolor="#C0C0C0"><b>CNPJ</td>'
	_cBody += 		'</tr>'
	//item
	_cBody += 		'<tr>'
	_cBody += 			'<td align="middle" valign="middle" bgcolor="#F5F5F5">' + CSOLIC+'</td>' // Solicitação numero
	_cBody += 			'<td align="middle" valign="middle" bgcolor="#F5F5F5">' + cNome +'</td>' // Nome(cliente/fornecedor)
	_cBody += 			'<td align="middle" valign="middle" bgcolor="#F5F5F5">' +cCodigo+'</td>'// codigo
	_cBody += 			'<td align="middle" valign="middle" bgcolor="#F5F5F5">' + cLoja +'</td>' // loja
	_cBody += 			'<td align="middle" valign="middle" bgcolor="#F5F5F5">' + cCGC  +'</td>' // Cnpj
	_cBody += 		'</tr>'
	_cBody += 		'</table>'
	_cBody += 		'<br><br><p align="Center">'+cFonte1+'Email gerado  automaticamente pelo TOTVS Protheus em: '+DTOC(DDATABASE) + " - " + Substr(TIME(),1,5)+'. Favor não responder este email.<br><br><br>'
	_cBody += 	'</body>'
	_cBody += '</html>'

	Connect Smtp Server _cMailS Account _cAccount Password _cPass RESULT lResult

	If lAuth		// Autenticacao da conta de e-mail
		lResult := MailAuth(_cUsuario2, _cSenha2)
		If !lResult
			conout("Não foi possivel autenticar a conta - " + _cUsuario2)
			Return()
		EndIf
	EndIf

	_xx := 0

	lResult := .F.

	do while !lResult

		If !Empty(_cAnexo)
			Send Mail From _cAccount To _cMailTo CC _cCC Subject _cSubject Body _cBody ATTACHMENT _cAnexo RESULT lResult
		Else
			Send Mail From _cAccount To _cMailTo CC _cCC Subject _cSubject Body _cBody RESULT lResult
		Endif

		_xx++
		if _xx > 2
			Exit
		Else
			Get Mail Error cErrorMsg
			ConOut(cErrorMsg)
		EndIf
	EndDo 

return(.T.)

