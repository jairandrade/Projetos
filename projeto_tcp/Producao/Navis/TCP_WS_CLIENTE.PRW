#include "Protheus.ch"
#include "apwebsrv.ch"
#include "TOPCONN.CH"
/*/{Protheus.doc} Cliente
Web services para inclusão/Alteração/Exclusao de cliente
@author  Luiz Fernando
@since   12/04/2016
/*/
wsService TCPCliente description "Webservice integracao de Cliente."

	wsData Cliente	as TCPClienteAtualizar
	wsData Exclui	as TCPClienteExcluir
	wsData Retorno	as TCPClienteRetorno

	//Metodos
	wsMethod Atualizar  description "Realiza a inclusão/alteração do cliente no protheus."
	wsMethod Excluir    description "Realiza a exclusão do cliente no protheus."

endWsService


/*/{Protheus.doc} Atualizar
Método utilizado para Incluir/Alterar Cliente

@author  Luiz 
@since   13/04/2016
@param Estrutura, Objeto, Dados XML para atualizar a estrutura.
@return  Retorno, Objeto, Retorna se conseguiu atualizar a estrutura e o erro, caso ocorra.
/*/
wsMethod Atualizar wsReceive Cliente  wsSend Retorno wsService TCPCliente

	Local aMata030Cab   := {}
	Local aMata030It    := {}
	Local aLog          := {}
	Local cLog          := ''
	Local lRet          := .F.
	Local nOpcao        := 3
	Local n1            := 0
	Local cComplem		:= " "
	Local cCodCli       := ""
	Local cLojaCli      := ""
	Local cPessoa       := "F"
	Local nTamCliente 	:= TamSX3("A1_COD")[1]
	Local nTamLoja	 	:= TamSX3("A1_LOJA")[1]
	Local cNatureza     := GetNewPar("TCP_NATISS","ISS RETIDO")//Natureza para geracao de ISS.
    Local nTamMUn       := TamSX3("CC2_CODMUN")[1]
    LOCAL cQuery        := ""
	Private cRetError      := ''
	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	
	Self:Retorno:Status := .F.
	SM0->(dbSetOrder(1))
	if !SM0->(dbSeek(cEmpant+Cliente:Filial))
		cLog := 'Filial incorreta!' +cEmpant +Cliente:Filial
		U_WSGEN001("TCPCliente.Atualizar",cLog)
		SetSoapFault("TCPCliente.Atualizar",cLog)
		return lRet := .F.
	else

		cFilAnt := Cliente:Filial//Atribui a filial correta		
		If AllTrim(ValType(Self:Cliente:COMPLEM)) != 'U'
			cComplem := Self:Cliente:COMPLEM
		EndIf

		If AllTrim(ValType(Self:Cliente:Codigo)) != 'U'.And. !Empty(Self:Cliente:Codigo)

		DBSelectArea("CCH")
		DBSetOrder(01)//CCH_FILIAL+CCH_CODIGO                                                                                                                                           
		If !CCH->(MSSeek(xFilial("CCH")+Self:Cliente:Pais))
			cLog := 'Código do País não localizado.' +Self:Cliente:Pais
			U_WSGEN001("TCPCliente.Atualizar",cLog)			
			SetSoapFault("TCPCliente.Atualizar",cLog)
			return lRet := .F.				
		EndIf
  		
		DBSelectArea("CC2")
		DBSetOrder(03)//CC2_FILIAL+CC2_CODMUN
		If !CC2->(MSSeek(xFilial("CC2")+PadR(Self:Cliente:Cod_Mun,nTamMUn)))
			cLog := 'Código do Município não localizado.' +Self:Cliente:Cod_Mun
			U_WSGEN001("TCPCliente.Atualizar",cLog)			
			SetSoapFault("TCPCliente.Atualizar",cLog)
			return lRet := .F.				
		EndIf		
		CC2->(DBSetOrder(01))//Deve retornar ao indice 01 para nao dar erro na ExecAuto 
		
	   cCodCli  := Subs(PadR(Self:Cliente:Codigo,(nTamCliente+nTamLoja)),1,nTamCliente)//Separa o código do cliente
	   cLojaCli := Subs(PadR(Self:Cliente:Codigo,(nTamCliente+nTamLoja)),nTamCliente+1)//separa a loja do cliente
	   DbSelectArea('SA1')
	   DBSetOrder(01)
	   If SA1->(MSSeek(xFilial("SA1")+cCodCli+cLojaCli))
			cCodCli  := SA1->A1_COD//Separa o código do cliente
	   		cLojaCli := SA1->A1_LOJA//separa a loja do cliente
			nOpcao := 4
	    Else
			cLog := 'Código de cliente informado nao existe.' +cCodCli+cLojaCli
			U_WSGEN001("TCPCliente.Atualizar",cLog)			
			SetSoapFault("TCPCliente.Atualizar",cLog)
			return lRet := .F.			
		EndIf
	EndIf
		
	//+---------------------------------------------------------------------+
	//| Busca pelo novo codigo do cliente...                                |
	//+---------------------------------------------------------------------+				
	DbSelectArea('CCH')
	DBSetOrder(01)//CCH_FILIAL+CCH_CODIGO
	If !CCH->(MSSeek(xFilial("CCH")+Self:Cliente:Pais))
		cLog := 'Código do país informado nao localizado.' +Self:Cliente:Pais
		U_WSGEN001("TCPCliente.Atualizar",cLog)			
		SetSoapFault("TCPCliente.Atualizar",cLog)
		return lRet := .F.	 
	EndIf		

	//+---------------------------------------------------------------------+
	//| Valida se existe Cliente cadastrado para o CNPJ e altera.           |
	//+---------------------------------------------------------------------+					
	If Empty(cCodCli) .And. !Empty(self:Cliente:CGC)
	   DbSelectArea('SA1')
	   DBSetOrder(03)//A1_FILIAL+A1_CGC
	   DBGoTop()
	   If SA1->(MSSeek(xFilial("SA1")+self:Cliente:CGC))
	   		self:Cliente:CGC:= SA1->A1_CGC
	   		Do While !SA1->(EOF()) .And. SA1->(A1_FILIAL+A1_CGC) == xFilial("SA1")+self:Cliente:CGC
	   			If SA1->A1_MSBLQL != "1"//1=Sim;2=Näo
					cCodCli  := SA1->A1_COD//Separa o código do cliente
			   		cLojaCli := SA1->A1_LOJA//separa a loja do cliente
					nOpcao := 4	
					Exit   			
	   			EndIf 
	   			SA1->(DBSkip())
	   		EndDo 

	   		If Empty(cCodCli)//Retorna erro quando o cliente está bloqueado.
				cLog := 'CPF/CNPJ de cliente informado esta Bloqueado.' +self:Cliente:CGC
				U_WSGEN001("TCPCliente.Atualizar",cLog)			
				SetSoapFault("TCPCliente.Atualizar",cLog)
				return lRet := .F.		   			
	   		EndIf
	   EndIf
	EndIf		
	
	
	//+---------------------------------------------------------------------+
	//| Busca pelo novo codigo do cliente...                                |
	//+---------------------------------------------------------------------+		
	If Empty(cCodCli)
	
		cQuery := " SELECT MAX(A1_COD) AS NUM FROM "+RetSqlName('SA1')+" "
		cQuery += "	WHERE A1_FILIAL = '"+xFilial('SA1')+"' "
		cQuery += " AND D_E_L_E_T_ != '*' "
		TCQUERY cQuery NEW ALIAS "QRYA1"
	
		DbSelectArea("QRYA1")
		QRYA1->(DbGoTop())
		
		IF QRYA1->(EOF())
			cNum := Strzero(1,nTamCliente)
		ElseIf Empty(Alltrim(QRYA1->NUM))
			cNum := Strzero(1,nTamCliente)
		Else
			cNum := Soma1(QRYA1->NUM)
		EndIf
		QRYA1->(DbCloseArea())	
	
		cCodCli := cNum //GetSxeNum("SA1","A1_COD")
		cLojaCli := StrZero(1,nTamLoja)  
		//SA1->(RollBAckSx8())
	EndIf
							
	If Len(AllTrim(self:Cliente:CGC)) >12
		cPessoa := "J"
	EndIf
	If !eMPTY(aLLTRIM(UPPER(Self:Cliente:Estado)))
		cEst := UPPER(Self:Cliente:Estado)
	Else
		cEst := 'EX'
	EndIf
						
	aMata030It := {{"A1_COD" 		,cCodCli		,NIL},;
		{"A1_LOJA"   	,cLojaCli		,NIL},;
		{"A1_NOME" 	    ,NoAcento(UPPER(Self:Cliente:Nome))			,NIL},;
		{"A1_NREDUZ"    ,NoAcento(UPPER(Self:Cliente:NReduz))		,NIL},;
		{"A1_END"   	,NoAcento(UPPER(Self:Cliente:Endereco))		,NIL},;
		{"A1_TIPO" 	    ,UPPER(Self:Cliente:Tipo)			,NIL},;
		{"A1_EST"   	,cest			,".T."},;
		{"A1_COD_MUN"	,Self:Cliente:Cod_Mun		,NIL},;
		{"A1_MUN" 		,NoAcento(UPPER(Self:Cliente:Mun))		,NIL},;
		{"A1_PESSOA" 	,UPPER(cPessoa)				,NIL},;//tratar pelo CPF cnpj
		{"A1_BAIRRO" 	,NoAcento(UPPER(Self:Cliente:Bairro))			,NIL},;
		{"A1_CEP" 		,Self:Cliente:CEP				,NIL},;
		{"A1_DDD" 		,Self:Cliente:DDD				,NIL},;
		{"A1_TEL" 		,Self:Cliente:Telefone		,NIL},;
		{"A1_ENDREC"	,UPPER(NoAcento(iif(ValType(Self:Cliente:Endrec)!="U",Self:Cliente:Endrec,"")))			,NIL},;	
		{"A1_ENDCOB"	,UPPER(NoAcento(iif(ValType(Self:Cliente:Endcob)!="U",Self:Cliente:Endcob,"")))			,NIL},;
		{"A1_BAIRROC"	,UPPER(NoAcento(iif(ValType(Self:Cliente:BAIRRO_C)!="U",Self:Cliente:BAIRRO_C,"")))		,NIL},;
		{"A1_CEPC" 		,iif(ValType(Self:Cliente:CEP_C)!="U",Self:Cliente:CEP_C,"")			,NIL},;
		{"A1_MUNC" 		,UPPER(NoAcento(iif(ValType(Self:Cliente:Mun_C)!="U",Self:Cliente:Mun_C,"")))			,NIL},;
		{"A1_ESTC" 		,iif(ValType(Self:Cliente:Estado_C)!="U",Self:Cliente:Estado_C,"")		,NIL},;			
		{"A1_CGC" 		,Self:Cliente:CGC				,NIL},;
		{"A1_INSCR" 	,Self:Cliente:InscR			,NIL},;
		{"A1_INSCRM" 	,Self:Cliente:InscRm			,NIL},;
		{"A1_CODPAIS"   ,Self:Cliente:Pais			,NIL},;//01058
		{"A1_PAIS"   	,SUBSTR(Self:Cliente:Pais,2,3)			,NIL},;//01058
		{"A1_EMAIL" 	,Self:Cliente:eMail			,NIL},;
		{"A1_COMPLEM"	,UPPER(NoAcento(cComplem))					,NIL},;		
		{"A1_PFISICA" 	,Self:Cliente:PFISICA		,NIL},;
		{"A1_TIPOCR" 	,iif(Empty(Self:Cliente:TIPOCR),"ZZZZZZ",Self:Cliente:TIPOCR)		,NIL},;//ZZZZZZ - Self:Cliente:TIPOCR
		{"A1_NATUREZ" 	,cNatureza     		        ,NIL},;
		{"A1_RECISS" 	,"2"		                ,NIL}}//Utilizado para gerar financeiro de ISS pela natureza...
	

		MSExecAuto({|x,y| Mata030(x,y)}, aMata030It, nOpcao) //3- Inclusão, 4- Alteração

		IF lMsErroAuto
			cLog := ''
			aLog := GetAutoGRLog()
			For n1 := 1 to len(aLog)
				cLog += aLog[n1] +  CRLF
			Next n1      
			cTime := TIME()                           
			cNomeFile := "Cliente"+dtos(dDatabase) + '_' + SUBSTR(cTime, 1, 2) + SUBSTR(cTime, 4, 2) + SUBSTR(cTime, 7, 2) + '_erroop.log'
			MostraErro("\SYSTEM\", cNomefile)						
			U_WSGEN001("TCPCliente.Atualizar",cLog)				
			SetSoapFault("TCPCliente.Atualizar",cLog) 
			DisarmTransaction()
			Return .F.
		Else
		
		    If nOpcao == 3   
		    	cLog:= "Cliente Incluido: "+SA1->(A1_COD+A1_LOJA)
		       //	SA1->(ConfirmSX8())
		    Else
		     cLog:= "Cliente Alterado: "+SA1->(A1_COD+A1_LOJA)
		    EndIf
			Self:Retorno:Status := .T.
			Self:Retorno:Codigo := SA1->(A1_COD+A1_LOJA)
			lRet := .T.			
			U_WSGEN001("TCPCliente.Atualizar",cLog)			
		EndIf
		
		//Testa se foi realmente incluido o registro
		DbSelectArea('SA1')
		DbSetOrder(1)
		If !SA1->(DbSeek(xFilial('SA1') + cCodCli+cLojaCli))
		
			U_WSGEN001("TCPCliente.Atualizar","Cliente não incluído!" + cCodCli+cLojaCli)				
			SetSoapFault("TCPCliente.Atualizar",cLog)				
			Return .F.
		EndIf
		MsUnlockAll()
	EndIf

Return lRet

/*/{Protheus.doc} Excluir 
Exclusão de clientes
@author  Luiz 
@since   12/04/2016
@param Exclusão, Objeto, XML com documento para excluir estrurura.
@return  Retorno, Objeto, Retorna se conseguiu excluir a estrurura e o erro, caso ocorra.
/*/


wsMethod Excluir wsReceive Exclui wsSend Retorno wsService TCPCliente

	Local aMata030Cab := {}
	Local aLog          := {}
	Local cLog          := ''
	Local lRet          := .T.
	Local n1            := 0
	Local nTamCliente 	:= TamSX3("A1_COD")[1]
	Local nTamLoja	 	:= TamSX3("A1_LOJA")[1]
	Local cCodCli  		:= ""
	Local cLojaCli 		:= ""
	

	Private cRetError      := ''
	Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.

	if !SM0->(dbSeek(cEmpant+Exclui:Filial))
		cLog:= 'Filial incorreta!'+Exclui:Filial
	    U_WSGEN001("TCPCliente.Excluir",cLog)
		SetSoapFault("TCPCliente.Excluir",cLog)
		lRet := .F.
	else
		cFilAnt := Exclui:Filial

			

		If AllTrim(ValType(Self:Exclui:Codigo)) != 'U'.And. !Empty(Self:Exclui:Codigo)
		
		   cCodCli  := Subs(PadR(Self:Exclui:Codigo,(nTamCliente+nTamLoja)),1,nTamCliente)//Separa o código do cliente
		   cLojaCli := Subs(PadR(Self:Exclui:Codigo,(nTamCliente+nTamLoja)),nTamCliente+1)//separa a loja do cliente

			DbSelectArea('SA1')
			DBSetOrder(01)
			If SA1->(MSSeek(xFilial("SA1")+cCodCli+cLojaCli))
	   		
				aMata030Cab := {{"A1_COD"	, SA1->A1_COD ,Nil},;
						{"A1_LOJA"	, SA1->A1_LOJA  ,Nil}}
						
				MSExecAuto({|x,y| Mata030(x,y)}, aMata030Cab, 5)
				
				IF lMsErroAuto
					cLog := ''
					aLog := GetAutoGRLog()
					For n1 := 1 to len(aLog)
						cLog += aLog[n1] +  CRLF
					Next n1
					lRet := .F.          
					cNomeFile := "Cliente"+dtos(dDatabase) + '_' + SUBSTR(cTime, 1, 2) + SUBSTR(cTime, 4, 2) + SUBSTR(cTime, 7, 2) + '_erroop.log'
					MostraErro('c:\Temp', cNomefile)			
					U_WSGEN001("TCPCliente.Excluir",cLog)
					SetSoapFault('Excluir',cLog)
				Else	
					U_WSGEN001("TCPCliente.Excluir",cCodCli+cLojaCli)
					Self:Retorno:Status := .T.
				EndIF				
				
			Else
				cLog:= 'Código de cliente informado nao existe.' +cCodCli+cLojaCli
				U_WSGEN001("TCPCliente.Excluir",cLog)
				SetSoapFault('ClienteExclusao',cLog)
				lRet := .F.			
			EndIf
		EndIf
		MsUnlockAll()
//		RpcClearEnv()
	endif

Return lRet


/*/{Protheus.doc} TCPClienteAtualizar
Estrtuura de dados para atualização(Inclusão/alteração) de clientes.
@author  Luiz
@since   12/04/2016
/*/
wsStruct TCPClienteAtualizar

	wsData Filial			as String
	wsData Codigo			as String Optional 
	wsData Nome			    as String
	wsData NReduz		    as String //Nome Reduzido
	wsData Endereco		    as String
	wsData Tipo			    as String //F=Cons.Final;L=Produtor Rural;R=Revendedor;S=Solidario;X=Exportacao
	wsData Estado			as String
	wsData Cod_Mun		    as String
	wsData Mun  		    as String
	wsData Bairro			as String
	wsData CEP				as String
	wsData DDD				as String
	wsData Telefone		    as String
	wsData Endcob			as String Optional //Endereco de cobranca
	wsData Bairro_C		    as String Optional //Bairro Cobrabca	
	wsData Endrec		    as String Optional //Endereco recebimento
	wsData CEP_C 			as String Optional//CEP cobranca
	wsData Mun_C			as String Optional
	wsData Estado_C		    as String Optional
	wsData CGC				as String
	wsData InscR			as String
	wsData InscRm			as String Optional
	wsData TipoCR			as String
	wsData Pais			    as String
	wsData eMail			as String
	wsData COMPLEM		    as String Optional
	wsData PFISICA          as String

endWsStruct

/*/{Protheus.doc} TCPClienteExcluir
Estrutura para Exclusão.

@author  Luiz
@since   12/04/2016
/*/
wsStruct TCPClienteExcluir

	wsData Filial         as String
	wsData Codigo	      as String //Contempla codigo e loja

endWsStruct

/*/{Protheus.doc} TCPClienteRetorno
Estrutura de retorno para webservices.

@author  Luiz
@since   12/04/2016
/*/
wsStruct TCPClienteRetorno

	wsData Status  as Boolean
	wsData Codigo  as String//Codigo do cliente+Loja	

endWsStruct