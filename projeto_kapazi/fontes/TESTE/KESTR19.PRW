#include "protheus.ch"
#include "topconn.ch"
#Include 'fileio.ch'

#Define ENTER chr(13)+chr(10)

User Function KESTR19T()
	Local aLinhas := {}

	aadd(aLinhas,"000TRANSPORTADORA MINUANO LTDA        80051824000120                     0904190806OCO090408060                         ")
	aadd(aLinhas,"340OCORR090408060                                                                                                       ")
	aadd(aLinhas,"34187183570001386TRANSPORTADORA MINUANO LTDA                                                                            ")
	aadd(aLinhas,"342800518240001204  000142390108042019235903DATA DE ENTREGA LANCADA POR RELACAO                                         ")
	aadd(aLinhas,"342800518240001204  000142409908042019000000AG AGENDAMENTO                                                              ")	
	aadd(aLinhas,"ARQedi-oco80051824-01042.txt")
	aadd(aLinhas,"PAS\edi\ocorr\")

	U_KESTR19(aLinhas)

Return

User Function KESTR19A(_cEmp,_cFil)
	Local 	nX			:= 1
	Local 	cArquivo	:= ""
	Local 	cPasta		:= "\edi\ocorr\"
	local 	aArqs		:= {}
	Local 	lEnv    	:= .F.
	Local	nStart		:= Seconds()
	Local 	nElap		:= 0

	Default _cEmp		:= "04"
	Default _cFil		:= "01"
	
	If Empty(AllTrim(_cEmp))
		_cEmp := "04"
	Endif

	If Empty(AllTrim(_cFil))
		_cFil := "01"
	Endif

	If u_FreeThreads(.F.,1,"KESTR19") 

		conout(DtoC(Date())+" "+Time()+" KESTR19 - Inicio processamento de arquivos EDI Ocorrer")

		CriarPastas(cPasta)
		
		lEnv    	:= StaticCall(KAP_WF03,environmentActions,1,_cEmp,_cFil,,,"SIGAEST",{"SB1"})
		
		aArqs := Directory(cPasta+"*.txt")
		For nX := 1 to Len(aArqs)
			cArquivo := Alltrim(aArqs[nX][1])
			ProcessarArquivo(cPasta,cArquivo)
		Next

		IF lEnv
			StaticCall(KAP_WF03,environmentActions,2)
		Endif

		nElap := Seconds() - nStart
		conout(DtoC(Date())+" "+Time()+" KESTR19 - Fim processamento de arquivos EDI OCorre. Tempo de execução: "+SecsToTime(nElap))
		
	Else
		conout(DtoC(Date())+" "+Time()+" KESTR19 - Job processamento de arquivos EDI Ocorre iniciado e terminado pois já está em execucao.")
	Endif
	
Return

Static Function ProcessarArquivo(cPasta,cArquivo)
	Local cFullName	:= cPasta+cArquivo
	// Local cConteudo	:= ""
	Local aLinhas	:= {}

	If !File(cFullName)
		Return
	Endif

	aLinhas := LerArquivo(cFullName)

	// If Empty(AllTrim(cConteudo))
	// 	Return
	// Endif

	// aLinhas := Separa(cConteudo,chr(13)+chr(10),.f.)
	If Empty(aLinhas)
		Return
	Endif

	aadd(aLinhas,"ARQ"+cArquivo)
	aadd(aLinhas,"PAS"+cPasta)

	U_KESTR19(aLinhas)

Return

User function KESTR19(aLinhas)
	Local aEdi		:= {}
	Local nX		:= 0
	Local cID		:= ""
	Local aRet		:= {}
	Local cInicio	:= ""
	Local cModelo	:= ""
	Local lProc		:= .F.
	Local cPasta	:= ""
	Local cOrigem	:= ""
	Local cDestino	:= ""
	Local lErro		:= .F.
	Local cInterc	:= ""

	Default aLinhas := {}

	If Empty(aLinhas)
		Return
	Endif

	U_KFATR15C("20","OCORRENCIA TRANSPORTE")

	For nX := 1 to Len(aLinhas)
		aRet 	:= {}
		lErro	:= .F.
		lProc	:= .F.

		cID := Substring(aLinhas[nX],1,3)

		If cID == "PAS"
			cRet	:= AllTrim(Upper(StrTran(aLinhas[nX],"PAS","")))
			cPasta	:= cRet
			aadd(aEdi,{{"PAS",cRet}})
		ElseIf cID == "ARQ"
			cRet	:= AllTrim(Upper(StrTran(aLinhas[nX],"ARQ","")))
			cArquivo:= cRet
			aadd(aEdi,{{"ARQ",cRet}})
		ElseIf cID == "000"
			aRet 	:= EdiCabecalho(aLinhas[nX])
			cInicio := aRet[1][4]
			cInterc	:= aRet[6][4]
		ElseIf cID == "340"
			aRet 	:= OCORR_Documento(aLinhas[nX])
			cModelo	:= aRet[2][4]
		ElseIf cID == "341"
			aRet := OCORR_Transportadora(aLinhas[nX])
		ElseIf cID == "342"
			aRet := OCORR_Entrega(aLinhas[nX])
		ElseIf cID == "343"
			aRet := OCORR_Ocorrencia(aLinhas[nX])
		Endif
		
		If !Empty(aRet)
			aadd(aEdi,aRet)
		Endif
	Next

	If cInicio == "000" .and. ("OCO" $ cInterc .or. "OCO" $ cModelo)
		lProc := .T.
		lErro := !OCORR_Processar(aEdi,cArquivo)
	Endif

	If !lProc
		cDestino:= cPasta+"\nao_processados\"+cArquivo
		cOrigem	:= cPasta+"\"+cArquivo
		U_KESTR20("03",cArquivo,"ARQUIVO NAO PROCESSADO")
		FNovoNome(cDestino,cOrigem)
	Endif

	If lErro
		cDestino:= cPasta+"\erro\"+cArquivo
		cOrigem	:= cPasta+"\"+cArquivo
		U_KESTR20("03",cArquivo,"ERRO AO PROCESSAR O ARQUIVO")
		FNovoNome(cDestino,cOrigem)
	Endif

Return

Static Function EDISepara(aDados,cLinha)
	Local aCampos 	:= aClone(aDados)
	Local nX		:= 0
	Local nIni		:= 0
	Local nTam		:= 0

	For nX := 1 to Len(aCampos)
		nIni := aCampos[nX][2]
		nTam := aCampos[nX][3]
		aCampos[nX][4] := Substring(cLinha,nIni,nTam)
	Next

Return aCampos

// 000
Static Function EdiCabecalho(cLinha)
	Local aCampos	:= {}
	
	aadd(aCampos,{"Registro"		,01,03,""})
	aadd(aCampos,{"Remetente"		,04,35,""})
	aadd(aCampos,{"Destinatario"	,39,35,""})
	aadd(aCampos,{"Data"			,74,06,""})
	aadd(aCampos,{"Hora"			,80,04,""})
	aadd(aCampos,{"Intercambio"		,84,12,""})
	aadd(aCampos,{"Filler"			,96,25,""})

	aCampos := EDISepara(aCampos,cLinha)

Return aCampos
	
// 340
Static Function OCORR_Documento(cLinha)
	Local aCampos	:= {}
	
	aadd(aCampos,{"Registro"		,01,003,""})
	aadd(aCampos,{"Documento"		,04,014,""})
	aadd(aCampos,{"Filler"			,18,103,""})

	aCampos := EDISepara(aCampos,cLinha)

Return aCampos

// 341
Static Function OCORR_Transportadora(cLinha)
	Local aCampos	:= {}
	
	aadd(aCampos,{"Registro"		,01,003,""})
	aadd(aCampos,{"CNPJ"			,04,014,""})
	aadd(aCampos,{"Razao"			,18,040,""})
	aadd(aCampos,{"Filler"			,58,063,""})

	aCampos := EDISepara(aCampos,cLinha)

Return aCampos

// 342 
Static Function OCORR_Entrega(cLinha)
	Local aCampos	:= {}
	
	aadd(aCampos,{"Registro"		,001,003,""})
	aadd(aCampos,{"CNPJ Emissor"	,004,014,""})
	aadd(aCampos,{"Serie"			,018,003,""})
	aadd(aCampos,{"Nota Fiscal"		,021,008,""})
	aadd(aCampos,{"Cod Ocorrencia"	,029,002,""})
	aadd(aCampos,{"Data"			,031,008,""})
	aadd(aCampos,{"Hora"			,039,004,""})
	aadd(aCampos,{"Cod Observacao"	,043,002,""})
	aadd(aCampos,{"Texto Livre"		,045,070,""})
	aadd(aCampos,{"Filler"			,115,006,""})

	aCampos := EDISepara(aCampos,cLinha)

Return aCampos

// 343 
Static Function OCORR_Ocorrencia(cLinha)
	Local aCampos	:= {}
	
	aadd(aCampos,{"Registro"		,001,003,""})
	aadd(aCampos,{"CNPJ Contratante",004,014,""})
	aadd(aCampos,{"Filial Emissora"	,018,010,""})
	aadd(aCampos,{"Serie Conhec"	,028,005,""})
	aadd(aCampos,{"Numero Conhec"	,033,012,""})
	aadd(aCampos,{"Filler"			,045,076,""})

	aCampos := EDISepara(aCampos,cLinha)

Return aCampos

Static Function OCORR_Processar(aEdi,cArquivo)
	// Local nX		:= 0
	Local _cEmp		:= ""
	Local _cFil		:= ""
	Local cMsg		:= ""
	Local cFilBkp	:= cFilAnt
	Local cEmpBkp	:= cEmpAnt
	Local aRet		:= {}
	Local lRet		:= .T.

	aRet := LocalizarEmpresa(aEdi)
	_cEmp := aRet[1]
	_cFil := aRet[2]
	cMsg  := aRet[3]

	If !Empty(AllTrim(cMsg))
		U_KESTR20("03",cArquivo,"DESTINATARIO DO EDI NAO LOCALIZADO")
		Return .F.
	Endif

	If cEmpAnt <> _cEmp 
		// U_KESTR20("04",cArquivo,"_cEmp :="+_cEmp+", cEmpAnt :="+cEmpAnt)
		lRet := StartJob("U_KESTR19D",GetEnvServer(),.T.		,_cEmp,_cFil,"OCORRE",aEdi)

	Else
		// U_KESTR20("04",cArquivo,"_cEmp :="+_cEmp+", cEmpAnt :="+cEmpAnt)
		If cFilAnt <> _cFil
			cFilAnt := _cFil
		Endif

		lRet := U_KESTR19D(_cEmp,_cFil,"OCORRE",aEdi)

		cFilAnt := cFilBkp
	Endif

	cEmpAnt := cEmpBkp

Return lRet

Static Function ValidarTransportadora(aLinha)
	Local lRet			:= .T.
	Local aArea			:= GetArea()
	// Local nPos			:= 0
	Local cCnpjTransp	:= GetValor("CNPJ" ,aLinha)
	Local cNome			:= GetValor("Razao",aLinha,.T.) 
	Local cMsg			:= ""
	Local aRet			:= {}
	Local cCodigo		:= ""
	Local cLoja			:= ""

	SA2->( DbSetOrder(3))
	If !SA2->( MsSeek(xFilial("SA2")+cCnpjTransp))
		lRet 	:= .F.
		cMsg 	:= "Fornecedor "+cCnpjTransp+" - "+cNome+" não cadastrado"
	Else
		cCodigo := SA2->A2_COD
		cLoja	:= SA2->A2_LOJA
		cNome	:= AllTrim(SA2->A2_NOME)
	Endif

	aRet := {lRet,cCodigo,cLoja,cNome,cCnpjTransp}
	
	RestArea(aArea)
Return aRet

Static Function GetValor(cCampo,aLinha,_lTrim)
	Local 	nPos	:= 0
	Local 	cRet	:= ""

	Default _lTrim	:= .F.

	nPos := aScan(aLinha,{|x| AllTrim(Upper(cCampo)) == AllTrim(Upper(x[1]))})
	if nPos > 0
		cRet := aLinha[nPos][4]
	Endif

	If _lTrim
		cRet := AllTrim(cRet)
	Endif

Return cRet

Static Function LocalizarEmpresa(aEdi)
	Local aArea			:= GetArea()
	Local _cEmpresa		:= ""
	Local _cFilal		:= ""
	Local aRet			:= {}
	Local cMsg			:= ""
	Local nRegno		:= SM0->( Recno() )
	Local aLinha		:= {}
	Local cDestinatario	:= ""
	Local cID			:= ""
	Local nX			:= 0

	For nX := 1 to Len(aEdi)
		aLinha 			:= aClone(aEdi[nX])
		cDestinatario 	:= ""

		cID := GetValor("Registro",aEdi[nX])
		If cID == "000"
			cDestinatario := GetValor("Destinatario",aLinha,.T.)
			cDestinatario := Padl(cDestinatario,14,"0")
		ElseIf cID == "342"
			cDestinatario := GetValor("CNPJ Emissor",aLinha,.T.)
			cDestinatario := Padl(cDestinatario,14,"0")
		Endif

		If Empty(AllTrim(cDestinatario))
			loop
		Endif

		SM0->( DbGoTop() )
		While !SM0->(EOF())
			If SM0->M0_CGC == cDestinatario
				_cEmpresa := SM0->M0_CODIGO
				_cFilal := SM0->M0_CODFIL
				Exit
			Endif
			SM0->( DbSkip() )
		Enddo

		If !Empty(Alltrim(_cEmpresa))
			Exit
		Endif

	Next

	If Empty(AllTrim(_cEmpresa)) 
		cMsg := "Cnpj "+cDestinatario+" não localizado como uma empresa/filial no protheus."
	Endif

	aRet := {_cEmpresa,_cFilal,cMsg}
	
	SM0->(DbGoTop())
	SM0->( DbGoTo(nRegno))

	RestArea(aArea)
Return aRet

User Function KESTR19D(_cEmp,_cFil,cModelo,aEdi)
	Local aArea		:= GetArea()
	Local nX		:= 0
	Local cID		:= ""
	Local cFile		:= ""
	Local nPos		:= 0
	Local aTransp	:= {}
	Local lRet		:= .T.
	Local lRetorno	:= .T.
	Local cOrigem	:= ""
	Local cDestino	:= ""
	Local cNova		:= ""
	Local lEnv    	:= StaticCall(KAP_WF03,environmentActions,1,_cEmp,_cFil,,,"SIGAEST",{"SB1"})
	
	If (nPos := aScan(aEdi,{|x| Alltrim(x[1][1]) == "ARQ"})) > 0
		cFile := aEdi[nPos][1][2]
	Endif

	if cModelo == "OCORRE"

		aTransp := ValidarTransportadora(aEdi[3])
		If !aTransp[1]
			U_KESTR20("03",cFile,"TRANSPORTADORA NAO CADASTRADA SA2")
			Return .F.
		Endif

		For nX := 1 to Len(aEdi)
			cID := GetValor("Registro",aEdi[nX])
			If cID == "342"
				lRetorno := OCORRE_NotaFiscal(aEdi[nX],cFile,aTransp)
				If lRet
					lRet := lRetorno
				Endif
			ElseIf cID == ""
				If aEdi[nX][1][1] == "PAS"
					cOrigem	:= Alltrim(aEdi[nX][1][2])
				ElseIf aEdi[nX][1][1] == "ARQ"
					cArquivo := AllTrim(aEdi[nX][1][2])
				Endif
			Endif
		Next
	Endif

	If !Empty(Alltrim(cOrigem)) .and. !Empty(Alltrim(cArquivo))
		If lRetorno
			cNova := "\backup"
		Else
			lRet 	:= .F.
			cNova 	:= "\Erro"
		Endif
		cDestino := cOrigem + cNova

		cOrigem := cOrigem +"\"+cArquivo
		cDestino:= cDestino+"\"+cArquivo

		FNovoNome(cDestino,cOrigem)
	Endif

	If lEnv
		StaticCall(KAP_WF03,environmentActions,2)
	Endif

	RestArea(aArea)
Return lRet

Static Function ConvData(cData)
	Local cAno := Substring(cData,5,4)
	Local cMes := Substring(cData,3,2)
	Local cDia := Substring(cData,1,2)
	Local cDate:= cAno + cMes + cDia
Return StoD(cDate)

Static Function ConvHora(cHora)
Return Stuff(cHora,3,0,":")+":00"

Static Function GetPedidos(cDoc,cSerie)
	Local aArea	:= GetArea()
	Local cQuery:= ""
	Local cTemp	:= GetNextAlias()
	Local aRet	:= {}
	Local aItem	:= {}
	
	cQuery += "SELECT DISTINCT "+ENTER
	cQuery += "	D2_PEDIDO "+ENTER
	cQuery += "	,D2_CLIENTE "+ENTER
	cQuery += "	,D2_LOJA "+ENTER
	cQuery += "	,D2_TIPO "+ENTER
	cQuery += " "+ENTER
	cQuery += "FROM "+RetSqlName("SD2")+" "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE  "+ENTER
	cQuery += "		D_E_L_E_T_	<>'*'  "+ENTER
	cQuery += "	AND D2_FILIAL	= '"+xFilial("SD2")	+"'  "+ENTER
	cQuery += "	AND D2_DOC		= '"+cDoc			+"'  "+ENTER
	cQuery += "	AND D2_SERIE	= '"+cSerie			+"'  "+ENTER
	cQuery += " "+ENTER
	cQuery += "ORDER BY D2_PEDIDO DESC "+ENTER

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea())
	Endif

	TcQuery cQuery New Alias (cTemp)
	
	While !(cTemp)->(EOF())
		aItem	:= {}
		aadd(aItem,(cTemp)->D2_PEDIDO	)
		aadd(aItem,(cTemp)->D2_CLIENTE	)	
		aadd(aItem,(cTemp)->D2_LOJA		)
		aadd(aItem,(cTemp)->D2_TIPO		)
		aadd(aRet,aItem)

		(cTemp)->( DbSkip() )
	Enddo

	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea())
	Endif

	RestArea(aArea)
Return aRet

Static Function OCORRE_NotaFiscal(aLinha,cArquivo,aTransp)
	Local aArea		:= GetArea()
	Local cEmissor	:= GetValor("CNPJ EMISSOR"	,aLinha)
	Local cSerie	:= GetValor("Serie"			,aLinha)
	Local cNota		:= Padl(GetValor("Nota Fiscal"	,aLinha),9,"0")
	Local cOcorrCod	:= GetValor("Cod Ocorrencia",aLinha)
	Local cOcorrDes	:= ""
	Local dData		:= ConvData(GetValor("Data"	,aLinha))
	Local cHora		:= ConvHora(GetValor("Hora"	,aLinha))
	// 01 Devolucao/recusa total, 02 Devolucao/Recusa parcial, 03 Aceite/entrega por acordo
	Local cCodObs	:= GetValor("Cod Observacao",aLinha) 
	Local cTexto	:= GetValor("Texto Livre"	,aLinha,.T.)
	Local aPedidos	:= GetPedidos(cNota,cSerie)
	Local lGrvSitLib:= StaticCall(M521CART,TGetMv,"  ","KA_OCORRSI","L",.T.,"KESTR19 - Ativar gravação do campo C5_X_SITBLI na importacao do edi ocorre?" )
	Local cCliente	:= ""
	Local cLoja		:= ""
	Local cNfTipo	:= ""
	Local cObs		:= ""
	Local nX		:= 0
	Local cSitLib	:= ""
	Local aOcorre	:= {}
	Local lMostra	:= .F.
	Local cOcorrPro	:= ""
	
	SC5->(DbSetOrder(1))
	SF2->( DbSetOrder(1) )
	If SF2->(MsSeek(xFilial("SF2")+cNota+cSerie))
		cCliente:= SF2->F2_CLIENTE
		cLoja	:= SF2->F2_LOJA
		cNfTipo	:= SF2->F2_TIPO
	Else
		U_KESTR20("03",cArquivo,"NOTA FISCAL NAO ENCONTRADA",cNota,cSerie)
	Endif

	aOcorre 	:= OCORRE_Descri(cOcorrCod)
	cOcorrDes 	:= aOcorre[1]
	cSitLib		:= aOcorre[2]
	lMostra		:= aOcorre[3]
	cOcorrPro	:= aOcorre[4]

	// Z04_FILIAL+Z04_TRANCN+Z04_NFISCA+Z04_NFSERI+DTOS(Z04_OCORDT)+Z04_OCORHR+Z04_OCOCOD+Z04_OBSCOD+Z04_OBSTXT
	Z04->(DbSetOrder(1))
	If !Z04->( MsSeek(xFilial("Z04")+aTransp[5]+cNota+cSerie+DtoS(dData)+cHora+cOcorrCod+cCodObs+cTexto+cArquivo))
		Begin Transaction
			RecLock("Z04",.T.)
				Z04->Z04_FILIAL := xFilial("Z04")
				Z04->Z04_TRANSP	:= aTransp[2]
				Z04->Z04_TRANLJ	:= aTransp[3]
				Z04->Z04_TRANNM	:= aTransp[4]
				Z04->Z04_TRANCN	:= aTransp[5]
				Z04->Z04_EMISSO	:= cEmissor
				Z04->Z04_NFISCA	:= cNota
				Z04->Z04_NFSERI	:= cSerie
				Z04->Z04_NFTIPO	:= cNfTipo
				Z04->Z04_NFCLI	:= cCliente
				Z04->Z04_NFLOJ	:= cLoja
				Z04->Z04_OCOCOD	:= cOcorrCod
				Z04->Z04_OCODES	:= cOcorrDes
				Z04->Z04_OCORDT	:= dData
				Z04->Z04_OCORHR	:= cHora
				Z04->Z04_OBSCOD	:= cCodObs
				Z04->Z04_OBSTXT	:= cTexto
				Z04->Z04_DATA	:= Date()
				Z04->Z04_HORA	:= Time()
				Z04->Z04_ARQUIV	:= AllTrim(Upper(cArquivo))
			MsUnLock("Z04")

			U_KESTR20("02",cArquivo,"OCORRENCIA REGISTRADA",cNota,cSerie)

			If lMostra .and. !Empty(aPedidos)
				If !Empty(AllTrim(cOcorrPro))
					cOcorrDes := cOcorrPro
				Endif
				
				cObs	:= AllTrim(cCodObs)+" - "+AllTrim(cTexto)

				For nX := 1 to Len(aPedidos)
					If !Empty(AllTrim(cSitLib)) .and. lGrvSitLib
						SC5->( DbSetOrder(1))
						If SC5->( MsSeek(xFilial("SC5")+aPedidos[nX][1] ) )
							cObs += ". Novo Sit. Lib.: " + cSitLib
							cObs += "; Antigo Sit. Lib.: "+cSitLib
							RecLock("SC5",.F.)
								SC5->C5_XSITLIB := cSitLib
							MsUnLock("SC5")
						Endif
					Endif
					u_KFATR15("20",aPedidos[nX][1],,cNota,cSerie,,cOcorrCod,cOcorrDes,cObs,dData,cHora)
				Next
			Endif
		End Transaction
	Endif

	RestArea(aArea)
Return .T.

Static Function FNovoNome(cNewName,cOldName)
	Local cAux 		:= ''
	Local lMinuscula:= .F.
	Local nRet 		:= 0	

	If cOldName == NIL
		cOldName := cNewName
	Endif
	
	cNewName := RemoveBarras(cNewName)
	cOldName := RemoveBarras(cOldName)

	CriarPastas(alltrim(cOldName))
	// cria a pasta destino
	CriarPastas(alltrim(cNewName))

	If File(cNewName)
		cAux:= "001"
	EndIf
	
	While File(cNewName+cAux)
		cAux := soma1(cAux)
	EndDo
	
	// remove espacoes
	cOldName := alltrim(cOldName)
	cNewName := alltrim(cNewName+cAux)

	// renomeia o arquivo
	nRet := FRename(cOldName, cNewName, nil, lMinuscula)
	conout(dtoc(date())+' '+time()+' '+'Renomeando arquivo DE: '+cOldName+' PARA: '+cNewName+'...')
	
	// se menor que zero
	If nRet < 0 
		//obtem o numero do erro
		nRet := FError()
		conout(dtoc(date())+' '+time()+' '+'Error: '+cValtochar(nRet)+'...')
		// lista de errors
		// http://tdn.totvs.com/display/tec/FError 
	Endif
	
	// retorna
Return (nRet)

static Function CriarPastas(cCaminho)
		// posicao da barra
	Local nAt		:= 0
	// original
	Local cOrigem	:= ""
	// temporario
	Local cTemp		:= "\"
	// ultima pasta
	Local nRat		:= 0
	// driver
	Local cDrive	:= ""
	// pastas
	Local cPastas	:= ""
	// nome do arquivo
	Local cNome		:= ""
	// extensao
	Local cExt		:= "'
	
	cCaminho := RemoveBarras(cCaminho)
	
	// quebra o caminho
	SplitPath(cCaminho, @cDrive, @cPastas, @cNome, @cExt )
	
	// monta as pastas a serem criadas
	cOrigem	:= cDrive + cPastas
	
	// se nao tem extensao e tem nome de arquivo foi passado pasta sem \ no final
	If Empty(AllTRim(cExt)) .and. !Empty(AllTrim(cNome))
		// adiciona a pasta e a barra no final
		cOrigem += cNome+"\"
	Endif
	
	// ultima barra
	nRat	:= rat("\",cOrigem)
	
	// faz loop
	While cTemp <> Substr(cOrigem,1,nRat)
		// localiza a proxima barra
		nAt		:= at('\',cOrigem,Len(cTemp)+1)
		// corta o caminho original
		cTemp 	:= Substring(cOrigem,1,nAt)
		cTemp  := AllTrim(cTemp)
		
		If !ExistDir( cTemp ) .and. Len(cTemp) > 2
			
			nRet := MakeDir(cTemp)
			If nRet == 0 
				ConOut(dtoc(date())+'|'+time()+'|'+"Pasta não localizada, Criando pasta: "+cTemp )
			Endif
		Endif
		
	Enddo 

Return
/*
	remove barras do caminho que nao sejam de caminho de rede \\serveridor\pasta
	\pasta\\arquivo
*/
Static Function RemoveBarras(cCaminho)

	// se caminho contem \\
	If at("\\",cCaminho) > 0
		// se o caminho nao eh uma pasta na rede
		If at("\\",cCaminho) > 1
			// remove todas as \\ do caminho
			cCaminho := StrTran(cCaminho,"\\","\")
		// se eh caminho de rede
		Else
			// remove \\ a partir da segunda ocorrencia
			cCaminho := StrTran(cCaminho,"\\","\",2)
		Endif
	Endif

Return cCaminho

Static Function OCORRE_Descri(cOcorrCod)
	Local aArea := GetArea()
	Local aRet	:= {}
	Local lZ07	:= StaticCall(M521CART,TGetMv,"  ","KA_OCORRZ7","L",.F.,"KESTR19 - Ativar uso das ocorrencias customizadas da kapazi? Z07 ao inves da Z05" )

	aadd(aRet,""	)
	aadd(aRet,""	)
	aadd(aRet,.F.	)
	aadd(aRet,""	)

	If !lZ07
		Z05->( DbSetOrder(1) )
		If Z05->(MsSeek(xFilial("Z05")+cOcorrCod))
			aRet[1]	:= Z05->Z05_DESCRI
			aRet[2]	:= Z05->Z05_XSITLI
			aRet[3] := Z05->Z05_MOSTRA == "S"
			aRet[4]	:= Z05->Z05_DESPRO
		Else
			aRet[1]	:= Upper("Ocorrencia nao cadastrada")
		Endif
	Else
		Z07->( DbSetOrder(1) )
		If Z07->(MsSeek(xFilial("Z07")+cOcorrCod))
			aRet[1]	:= Z07->Z07_DESCRI
			aRet[2]	:= Z07->Z07_XSITLI
			aRet[3] := Z07->Z07_MOSTRA == "S"
			aRet[4]	:= Z07->Z07_DESCRI
		Else
			aRet[1]	:= Upper("Ocorrencia nao cadastrada")
		Endif
	Endif

	RestArea(aArea)
Return aRet

Static Function LerArquivo(cArquivo)
	Local aRet	:= { }
	Local nHdl	:= 0
	Local cBuff	:= ""
	
	nHdl := FT_FUSE(cArquivo)
	if nHdl == -1
		return aRet
	Endif

	FT_FGoTop()
	While !FT_FEOF()
		cBuff := FT_FReadLn()
		cBuff := FwCutOff(cBuff)
		aadd(aRet,cBuff)
		FT_FSkip()
	Enddo

	FT_FUse()

Return aRet
