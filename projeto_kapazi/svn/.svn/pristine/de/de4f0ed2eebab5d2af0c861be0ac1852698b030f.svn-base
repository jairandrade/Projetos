#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

User Function BETHANOB
	local aEmp := {}

	If	Select('SX2') <> 0
		MsgRun("Processando Rotina ... Aguarde...","Validando notas",{||  U_BETHANOTA() })

		MsgInfo("Rotina concluida!")
	Else

		If MyOpenSM0()
			While !Eof()
				AADD(aEmp,{Alltrim(SM0->M0_CODIGO),alltrim(SM0->M0_CODFIL)})
				dbSkip()
			Enddo
			dbCloseArea("SM0")
			
			For nI:= 1 To Len(aEmp)
				RPCSetType( 3 )						//Não consome licensa de uso
				conout(dtoc(date())+"/"+time()+" Utilizando empresa " + aEmp[nI][1] + " filial " + aEmp[nI][2] + " Iniciando rotina BETHANOTA")
				RpcSetEnv(aEmp[nI][1],aEmp[nI][2],,,,GetEnvServer(),{ "SM2" })

				lContinua:= GetMv("KP_ATVNFM",,.F.) //Verifica se a NF mista esta ativa


				if lContinua
					conout(dtoc(date())+"/"+time()+" Utilizando empresa " + aEmp[nI][1] + " filial " + aEmp[nI][2] + " [BETHANOTA] - Parametro habilitado")
					u_BETHANOTA()
				EndIf
				conout(dtoc(date())+"/"+time()+" Utilizando empresa " + aEmp[nI][1] + " filial " + aEmp[nI][2] + " Finalizando rotina BETHANOTA")

				RpcClearEnv()
			Next nI
		EndIf
	EndIf

return			


User Function BETHANOTA
	local cQry := ""
	local oXML
	local cString := ""
	local lRet := .F.
	
	If !LockByName("BETHANF",.T.,.T.,.T.)
		conout(dtoc(date())+"/"+time()+" Já existe um processo rodando, saindo...")
		Return
	EndIf
	
	//varios erros são devidos a caracter e comercial nos cadastros de clientes
	cQry := "update "+RetSQLName("SA1")+" set A1_NOME = REPLACE(A1_NOME, '&', 'E'), A1_NREDUZ = REPLACE(A1_NREDUZ, '&', 'E') where  (A1_NOME like '%&%' OR A1_NREDUZ like '%&%') AND D_E_L_E_T_ <> '*'  "
	TcSqlExec(cQry)

	cQry := " select * from ( 
	cQry += "select F2_SERV.F2_EMISSAO, F2_SERV.F2_SERIE, F2_SERV.F2_DOC, F2_SERV.F2_CLIENTE, F2_SERV.F2_LOJA,F2_SERV.F2_XIDVNFK, ZP6.*  From "+RetSQLName("SF2")+" F2 
	cQry += " join "+RetSQLName("SF2")+" F2_SERV on F2.F2_FILIAL = '"+xFilial("SF2")+"' and F2.F2_XIDVNFK = F2_SERV.F2_XIDVNFK and F2_SERV.F2_XTIPONF = '2' and F2_SERV.D_E_L_E_T_ <> '*' "
	cQry += " left join "+RetSQLName("ZP6")+" ZP6 on ZP6.D_E_L_E_T_ <> '*' and ZP6_FILIAL = '"+xFilial("ZP6")+"' and F2_SERV.F2_SERIE+F2_SERV.F2_DOC = ZP6_ID  " 
	cQry += " where F2.F2_XIDVNFK <> '' and F2.F2_XTIPONF = '1' and F2.D_E_L_E_T_ <>'*' and F2.F2_DAUTNFE <> '' and F2.F2_FILIAL =  '"+xFilial("SF2")+"' and F2.F2_EMISSAO between '"+DTOS(dDatabase-90)+"' and '"+DTOS(dDatabase)+"' "

	cQry += " union all "

	cQry += " select F2_EMISSAO, F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA,F2_XIDVNFK, ZP6.*  From "+RetSQLName("SF2")+" F2 
	cQry += " left join "+RetSQLName("ZP6")+" ZP6 on ZP6.D_E_L_E_T_ <> '*' and ZP6_FILIAL = '"+xFilial("ZP6")+"' and F2_SERIE+F2_DOC = ZP6_ID  " 
	cQry += " where F2.F2_XIDVNFK = '' and F2.F2_XTIPONF = '2'  and F2.D_E_L_E_T_ <>'*' and F2.F2_FILIAL =  '"+xFilial("SF2")+"'  and F2.F2_EMISSAO between '"+DTOS(dDatabase-90)+"' and '"+DTOS(dDatabase)+"' "
	cQry += " ) a where (ZP6_NOTA = '' and ZP6_ERRO = '' and ZP6_PROTOC = '') OR ZP6_FILIAL is null "
	
	Conout("")
	Conout(cQry)
	Conout("")
	
	TcQuery cQry new alias "QSF2"

	cCodMun		:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )

	While QSF2->(!EOF())
		If Alltrim(QSF2->ZP6_NOTA) == ''
			conout(dtoc(date())+"/"+time()+" Utilizando empresa " + cEmpAnt + " filial " + cFilAnt + " [BETHANOTA] - Transmitindo "+ QSF2->F2_SERIE+ QSF2->F2_DOC)
			U_nfseXMLUni( cCodMun, "1", STOD(QSF2->F2_EMISSAO), QSF2->F2_SERIE, QSF2->F2_DOC, QSF2->F2_CLIENTE, QSF2->F2_LOJA, "", {} )
			If !Empty(QSF2->F2_XIDVNFK)
				U_xAtuZP6(QSF2->F2_XIDVNFK)
			EndIf
		EndIf
		QSF2->(DbSkip())
	EndDo

	QSF2->(DbCloseArea())

	cQry := "select *, R_E_C_N_O_ RECZP6 from "+RetSQLName("ZP6")+ " ZP6 where D_E_L_E_T_ <> '*' and ZP6_FILIAL = '"+xFilial("ZP6")+"' and ZP6_NOTA = '' and ZP6_ERRO = '' and ZP6_PROTOC <> '' "
	// query para filtrar somente um recno para testes
//	cQry := "select *, R_E_C_N_O_ RECZP6 from "+RetSQLName("ZP6")+ " ZP6 where D_E_L_E_T_ <> '*' AND R_E_C_N_O_ ='11322' " 

	TcQuery cQry new alias "QZP6"

	While QZP6->(!EOF())

		DbSelectArea("ZP6")
		ZP6->(DbGoTo(QZP6->RECZP6))
		conout(dtoc(date())+"/"+time()+" Utilizando empresa " + cEmpAnt + " filial " + cFilAnt + " [BETHANOTA] - Verificando "+ ZP6->ZP6_PROTOC)

		cString := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:e="http://www.betha.com.br/e-nota-contribuinte-ws">'
		cString += '   <soapenv:Header/>'
		cString += '   <soapenv:Body>'
		cString += '      <e:ConsultarLoteRpsEnvio>'
		cString += '         <Prestador>'
		cString += '            <Cnpj>'+alltrim(SM0->M0_CGC)+'</Cnpj>'
		cString += '         </Prestador>'
		cString += '         <Protocolo>'+ZP6->ZP6_PROTOC+'</Protocolo>'
		//cString += '         <Protocolo>752047846695771</Protocolo>'
		cString += '      </e:ConsultarLoteRpsEnvio>'
		cString += '   </soapenv:Body>'
		cString += '</soapenv:Envelope>'

		oXML := nil

		lRet := U_BETHAENV("consultarLoteRps?wsdl","ConsultarLoteRpsEnvio",EncodeUtf8(cString),@oXML)

		if valtype(xGetInfo(oxml,"_LISTANFSE:_COMPLNFSE:_NFSE:_INFNFSE:_NUMERO:TEXT")) == "C" .and. valtype(xGetInfo(oxml,"_LISTAMENSAGEMRETORNO:_MENSAGEMRETORNO:_MENSAGEM:TEXT")) == "U" 
			Reclock("ZP6",.F.)
			ZP6->ZP6_NOTA  := Alltrim(OXML:_LISTANFSE:_COMPLNFSE:_NFSE:_INFNFSE:_NUMERO:TEXT)
			ZP6->ZP6_MEMO  := Alltrim(OXML:_LISTANFSE:_COMPLNFSE:_NFSE:_INFNFSE:_OUTRASINFORMACOES:TEXT)
			ZP6->ZP6_ERRO   := "" 
			ZP6->ZP6_MSGERR := ""
			Msunlock()
		elseif valtype(xGetInfo(oxml,"_LISTAMENSAGEMRETORNO:_MENSAGEMRETORNO:_MENSAGEM:TEXT")) == "C" .and. Alltrim(oXML:_LISTAMENSAGEMRETORNO:_MENSAGEMRETORNO:_MENSAGEM:TEXT) <>"Esse RPS foi enviado para a nossa base de dados, mas ainda não foi processado"
			Reclock("ZP6",.F.)
			ZP6->ZP6_ERRO   := "S" 
			ZP6->ZP6_MSGERR := Alltrim(oXML:_LISTAMENSAGEMRETORNO:_MENSAGEMRETORNO:_MENSAGEM:TEXT) +" - "+ xmlTag(oXML:_LISTAMENSAGEMRETORNO:_MENSAGEMRETORNO,"_CORRECAO")
			Msunlock()
		EndIf

		QZP6->(DbSkip())

	EndDo

	QZP6->(DbCloseArea())

	cQry := " select * from (
	cQry += " select F2_EMISSAO, F2_SERIE, F2_DOC, F2_CLIENTE, F2_LOJA,F2_XIDVNFK, ZP6_CANC, F2.R_E_C_N_O_ RECF2  From "+RetSQLName("SF2")+" F2 " 
	cQry += " left join "+RetSQLName("ZP6")+" ZP6 on ZP6.D_E_L_E_T_ <> '*' and ZP6_FILIAL = F2_FILIAL and F2_SERIE+F2_DOC = ZP6_ID "
	cQry += " where  F2.F2_XTIPONF = '2' and F2.D_E_L_E_T_ ='*' and F2.F2_EMISSAO between '"+DTOS(dDatabase-2)+"' and '"+DTOS(dDatabase)+"' "
	cQry += " ) a where  ZP6_CANC = '' " 
	cQry += " order by RECF2 DESC "
	TcQuery cQry new alias "QSF2"

	While QSF2->(!EOF())
		If QSF2->ZP6_CANC = ' '
			conout(dtoc(date())+"/"+time()+" Utilizando empresa " + cEmpAnt + " filial " + cFilAnt + " [BETHANOTA] - Cancelando "+ QSF2->F2_SERIE+ QSF2->F2_DOC)
			U_nfseXMLUni( cCodMun, "1", STOD(QSF2->F2_EMISSAO), QSF2->F2_SERIE, QSF2->F2_DOC, QSF2->F2_CLIENTE, QSF2->F2_LOJA, "1", {} )
		EndIf
		QSF2->(DbSkip())
	EndDo

	QSF2->(DbCloseArea())
	
	UnLockByName("BETHANF",.T.,.T.,.T.)

return

Static Function MyOpenSM0()

	Local lOpen := .F.
	Local nLoop := 0

	For nLoop:= 1 To 20
		dbUseArea(.T.,,"SIGAMAT.EMP","SM0",.T.,.T.)
		If !Empty(Select("SM0"))
			lOpen:= .T.
			dbSetIndex("SIGAMAT.IND")
			Exit
		Endif
		Sleep(500)
	Next nLoop

	If !lOpen
		ConOut("Arquivo de Empresas/Filiais Não Pode Ser Lido ! - BETHANOTA")
	Endif

Return(lOpen)

Static Function xmlTag(oSegmento,cTag)
	Local oTag	:= XmlChildEx(oSegmento,cTag)
	Local cRet	:= ""
	
	If ValType(oTag)=="O"
		cRet := oTag:TEXT
	Endif
	
Return cRet