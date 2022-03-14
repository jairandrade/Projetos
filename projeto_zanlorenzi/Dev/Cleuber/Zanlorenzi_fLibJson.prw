#Include 'Protheus.ch'
/*
-------------------------------------------------------------------------------
Biblioteca de Fun��es para Conex�o do WS CyberLog
-------------------------------------------------------------------------------
*/ 

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fIDWmsErp
Fun��o para Retornar o Nr da Transa��o de integra��o
@type function
@version 12.1.27
@author Carlos CLeuber
@since 21/12/2020
/*/
User Function fIDWmsErp
Local cNrTrans:= soma1(GetMV("FZ_WSTRANS"))

PutMV("FZ_WSTRANS", cNrTrans)

Return cNrTrans

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fLgInJson
Fun��o para fazer Login e Autentica��o no Servi�o do WS JSon 
@type function
@version 12.1.27
@author Carlos Cleuber
@since 15/12/2020
@return character, Numero do token gerado
/*/

User Function fLgInJson()
Local cIpSrv	:= "http://192.168.7.210:9393"
Local cNameSrv	:= "/cyberweb/api/autenticador/login"
Local cChave	:= GetMV("FZ_WSCHWMS")
Local cUserWS	:= GetMV("FZ_WSUSWMS")
Local cPwdWS	:= GetMV("FZ_WSPWWMS")

Local cBody		:= ''
Local cMsg		:= ''
Local cRet		:= ''
Local cToken	:= ''
Local aHeader	:= {}
Local aRet		:= array(3)
Local lRet		:= .T.
Local oJson		:= JsonObject():New()
Local oRest
Local oObj

Local cError	:= ''
Local cJson		:= ''
Local nStatus	:= 0

//aAdd(aHeader,'Accept-Encoding: UTF-8')
AAdd(aHeader,'Accept: application/json')
aAdd(aHeader,'Content-Type: application/x-www-form-urlencoded')
aAdd(aHeader,'Chave: '+ cChave )

cBody:= 'conta=' + AllTrim(cUserWS) + '&'
cBody+= 'senha=' + AllTrim(cPwdWS) + '&'
cBody+= 'modulo=SYNC&'
cBody+= 'numeroDeposito=1&'
cBody+= 'address=192.168.7.31&'

//Monta a conex�o com o servidor REST
oRest := FWRest():New(cIpSrv) 
oRest:setPath(cNameSrv)
	
//Definindo o par�metro a ser usado no POST
cBody := FWNoAccent(cBody)
oRest:SetPostParams(cBody)
oRest:SetChkStatus(.F.)
	
//Publica a altera��o, e caso n�o d� certo, mostra erro
If ! oRest:Post(aHeader)
	cMsg:= 'Aten��o !!! Houve erro na atualiza��o no servidor!' + CRLF + ;
		'Contate o Administrador!' + CRLF + ;
		"Erro: " + oRest:GetLastError() + CRLF + "Result: " + oRest:GetResult()
		lRet:= .F.
Else

	FWJsonDeserialize(oRest:GetResult(),@oObj)
	cError := ""
	nStatus := HTTPGetStatus(@cError)

	if nStatus >= 200 .And. nStatus <= 299
		if Empty(oRest:getResult())
			lRet:= .F.
			cMsg:= "GetStatus: " + str(nStatus)
		else
			cJson:= oJson:fromJson(oRest:GetResult())
			If !Empty(oJson["token"])
				cToken:=alltrim(oJson["token"]) 			
				cMsg:= "Autentica��o OK. Token "+ cToken
			Else
				lRet:= .F.
				cMsg:= "Token em Branco"
			Endif
		endif
	else
		lRet:= .F.
		cMsg:= alltrim(cError)
	endif

EndIf

//Aviso( "Mensagem WS", cMsg, {'OK'}, 03)
cRet:= cMsg

FreeObj(oObj)
FreeObj(oRest)
FreeObj(oJSON)

aRet[1]:= lRet
aRet[2]:= cMsg
aRet[3]:= cToken

Return aRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fOutJson
Fun��o para fazer Login e Autentica��o no Servi�o do WS JSon 
@type function
@version 12.1.27
@author Carlos Cleuber
@since 15/12/2020
@return character, faz o logout do WS Cyberlog
/*/
User Function fLgOuJson(cToken)
Local cIpSrv	:= "http://192.168.7.210:9393"
Local cNameSrv	:= "/cyberweb/api/autenticador/logout"
Local cChave	:= GetMV("FZ_WSCHWMS")
Local cBody		:= ''
Local cMsg		:= ''
Local cRet		:= ''
Local aHeader	:= {}
Local lRet		:= .T.
Local oJson		:= JsonObject():New()
Local oRest
Local oObj

Local cError	:= ''
Local cJson		:= ''
Local nStatus	:= 0

AAdd(aHeader,'Accept: application/json')
aAdd(aHeader,'Content-Type: application/x-www-form-urlencoded')
aAdd(aHeader,'Chave: '+ cChave )
aAdd(aHeader,"token: "+ cToken)

cBody:= ''

//Monta a conex�o com o servidor REST
oRest := FWRest():New(cIpSrv) 
oRest:setPath(cNameSrv)
	
//Definindo o par�metro a ser usado no POST
cBody := FWNoAccent(cBody)
oRest:SetPostParams(cBody)
oRest:SetChkStatus(.F.)
	
//Publica a altera��o, e caso n�o d� certo, mostra erro
If ! oRest:Post(aHeader)
	cMsg:= 'Aten��o !!! Houve erro na atualiza��o no servidor!' + CRLF + ;
		'Contate o Administrador!' + CRLF + ;
		"Erro: " + oRest:GetLastError() + CRLF + "Result: " + oRest:GetResult()
	lRet:= .F.
Else

	FWJsonDeserialize(oRest:GetResult(),@oObj)
	cError := ""
	nStatus := HTTPGetStatus(@cError)

	if nStatus >= 200 .And. nStatus <= 299
		if Empty(oRest:getResult())
			lret:= .F.
			cMsg:= "GetStatus: " + str(nStatus)
		else
			cJson:= oJson:fromJson(oRest:GetResult())
			If !Empty(oJson["CyberWeb"])
				cMsg:=alltrim(oJson["CyberWeb"]) 			
			Else
				lRet:= .F.
				cMsg:= ""
			Endif
		endif
	else
		lRet:= .F.
		cMsg:= cError
	endif
	
EndIf

cRet:= cMsg

FreeObj(oObj)
FreeObj(oRest)
FreeObj(oJSON)

Return cRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fConJson
Fun��o para Conectar ao Servi�o do WS JSon baseado do Modelo cadastrado na Tabela ZA2
@type function
@version 12.1.27
@author Carlos Cleuber
@since 08/12/2020
@param cLayout, character, codigo do layout do WebService
/*/
User Function fConJson(cLayOut,cTab,nIndice,cCpsPesq,cChvPesq)
Local aZA2		:= GetArea()
Local lRet		:= .T.
Local cEndWS	:= ''
Local cMetodo	:= ''
Local cBody 	:= ''
Local cChave	:= GetMV("FZ_WSCHWMS")
Local cToken	:= ''
Local cTipoMov	:= ''
Local cOrigMov	:= ''
Local aOK 		:= array(2)
Local aRet		:= array(3)
Local aHeader	:= {}
Local aLogIn	:= {}
Local oJson		
Local oRest
Local oObj

Local cError	:= ''
Local cCodRet	:= ''
Local cRetJson	:= ''
Local cJson		:= ''
Local nStatus	:= 0

Local cWSPar1:= alltrim(GetMv("FZ_WSWMS1"))	//"[FZ_WSWMS1] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Cadastro PRODUTOS]" 		
Local cWSPar2:= alltrim(GetMv("FZ_WSWMS2"))	//"[FZ_WSWMS2] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Cadastro FORNECEDOR]"		
Local cWSPar3:= alltrim(GetMv("FZ_WSWMS3"))	//"[FZ_WSWMS3] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Cadastro CLIENTE]"		
Local cWSPar4:= alltrim(GetMv("FZ_WSWMS4"))	//"[FZ_WSWMS4] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Cadastro PESSOAS]"		
Local cWSPar5:= alltrim(GetMv("FZ_WSWMS5"))	//"[FZ_WSWMS5] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Cadastro PEDIDOS]" 		
Local cWSPar6:= alltrim(GetMv("FZ_WSWMS6"))	//"[FZ_WSWMS6] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Cadastro RECEBIMENTOS]"	
Local cWSPar7:= alltrim(GetMv("FZ_WSWMS7"))	//"[FZ_WSWMS7] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Manutencao de Lotes]"	
Local cWSPar8:= alltrim(GetMv("FZ_WSWMS8"))	//"[FZ_WSWMS8] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Movimentacao de Interna]"	
Local cWSPar9:= alltrim(GetMv("FZ_WSWMS9"))	//"[FZ_WSWMS9] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Transferencias]"	
Local cWSParA:= alltrim(GetMv("FZ_WSWMSA"))	//"[FZ_WSWMSA] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Aceite]"	

cLayOut:= alltrim(cLayOut)
aLogIn:= U_fLgInJson()

If aLogIn[1] .and. !Empty(aLogIn[3]) 

	cToken:= aLogIn[3]
	AAdd(aHeader,'Accept: application/json')
	aAdd(aHeader,'Content-Type: application/x-www-form-urlencoded')
	aAdd(aHeader,"Chave: "+ cChave)
	aAdd(aHeader,"token: "+ cToken)

	cJson:= "{Header"+ CRLF
	cJson+= "Chave: "+ cChave + CRLF
	cJson+= "token: "+ cToken + "}" + CRLF + CRLF

	DbSelectArea("ZA2")
	ZA2->(DbSetOrder(1)) //Filial+Codigo Layout+Nome da TAG
	If ZA2->(DbSeek(FWxFilial("ZA2")+cLayOut,.T.))

		cEndWS:= alltrim(ZA2->ZA2_ENDWS)+":"+alltrim(ZA2->ZA2_PORWS)
		cMetodo:= alltrim(ZA2->ZA2_METWS)
		cBody:= U_fGrJson(cLayOut,cTab,nIndice,cCpsPesq,cChvPesq,ZA2->ZA2_CHVPAR)

		cJson+= cBody

		//Monta a conex�o com o servidor REST
		oRest := FWRest():New(cEndWS) 
		oRest:setPath(cMetodo) 
		
		//Definindo o par�metro a ser usado no POST
		cBody := FWNoAccent(cBody)
		oRest:SetPostParams(cBody)
		oRest:SetChkStatus(.F.)
		
		//Publica a altera��o, e caso n�o d� certo, mostra erro
		If ! oRest:Post(aHeader)
			lret:= .F.
			cCodRet:= "999"
			cMsg:= 'Aten��o !!! Houve erro na atualiza��o no servidor!' + CRLF + ;
				'Contate o Administrador!' + CRLF + ;
				"Erro: " + oRest:GetLastError() + CRLF + "Result: " + oRest:GetResult()
		Else

			FWJsonDeserialize(oRest:GetResult(),@oObj)
			cError := ""
			nStatus := HTTPGetStatus(@cError)

			if nStatus >= 200 .And. nStatus <= 299
				if Empty(oRest:getResult())
					lret:= .F.
					cCodRet:= "ERRO: " + cvaltochar(nStatus)
					cMsg:= "GetStatus: " + str(nStatus)
				else
					oJson:= JsonObject():New()
					cRetJson:= oJson:fromJson(oRest:GetResult())
					If ValType(cRetJson) != "U"
						lRet:= .F.
						cCodRet:= "999"
						cMsg:= 'Falha ao popular JsonObject. Erro: ' + cRetJson

					Else

						If !Empty(oJson["CyberWeb"])
							cCodRet:= alltrim(oJson["CyberWeb"])
							If substr(cCodRet,1,1)=="!"
								cCodRet:= substr(cCodRet,2,len(cCodRet))
							Endif
							cMsg:= "Servi�o: " + cLayOut + CRLF
							cMsg+= "M�todo: "+ cMetodo + CRLF

							aOk:= fRslCnx(cLayOut, val(cCodRet))
							cMsg+= "Codigo Retorno: " +  aOK[2]

							If ! aOK[1]
								lRet:= .f.
							Endif
						Else
							lRet:= .F.
							cCodRet:= "999"
							cMsg:= "ERRO: Chave Json [CYBERWEB]"
						Endif
					Endif
				endif
			else
				lRet:= .F.
				cCodRet:= "999"
				cMsg:= cError
			endif
		Endif

	Endif

	//Faz o LogOut no WS do WMS
	U_fLgOuJson(cToken)
Else
	lret:= .F.
	cCodRet:= "999"
	cMsg:= "N�o foi possivel fazer o Login!!!"+ CRLF + aLogIn[2]
Endif

cJson+=CRLF+CRLF+"{ Resultado"+ CRLF
cJson+="Codigo Retorno:" + cCodRet + CRLF
cJson+="Mensagem: "+ cMsg + "}"

aRet[1]:= lRet
aRet[2]:= cCodRet
aRet[3]:= cMsg
	
If cLayOut == cWSPar1
	cTipoMov:= "1"
	cOrigMov:= "[Cadastro PRODUTOS]"

ElseIf cLayOut == cWSPar2
	cTipoMov:= "2"
	cOrigMov:= "[Cadastro FORNECEDOR]"

ElseIf cLayOut == cWSPar3
	cTipoMov:= "3"
	cOrigMov:= "[Cadastro CLIENTE]"

ElseIf cLayOut == cWSPar4
	cTipoMov:= "4"
	cOrigMov:= "[Cadastro PESSOAS]"

ElseIf cLayOut == cWSPar5
	cTipoMov:= "5"
	cOrigMov:= "[Pedido de Vendas]"

ElseIf cLayOut == cWSPar6
	cTipoMov:= "6"
	cOrigMov:= "[Recebimentos Nota Fiscal]"

ElseIf cLayOut == cWSPar7
	cTipoMov:= "7"
	cOrigMov:= "[Manutencao de Lotes]"

ElseIf cLayOut == cWSPar8
	cTipoMov:= "8"
	cOrigMov:= "[Movimentos Internos]"

ElseIf cLayOut == cWSPar9
	cTipoMov:= "9"
	cOrigMov:= "[Transferencias]"		

ElseIf cLayOut == cWSParA
	cTipoMov:= "A"
	cOrigMov:= "[Aceite]"			
Endif

RecLock("ZA1",.T.)
ZA1->ZA1_FILIAL:= FWxFilial("ZA1")
ZA1->ZA1_STATUS:= iIf(lRet,"1","0")
ZA1->ZA1_NRTRAN:= U_fIDWmsErp()
ZA1->ZA1_TIPOTR:= "E"
ZA1->ZA1_ORIGEM:= cOrigMov
ZA1->ZA1_DATATR:= date()
ZA1->ZA1_HORATR:= time()
ZA1->ZA1_USERTR:= upper(UsrRetName(__cUserId))
ZA1->ZA1_JSON  := cJson
ZA1->ZA1_TPMOV := cTipoMov
ZA1->(MsUnlock())

FreeObj(oObj)
FreeObj(oRest)
FreeObj(oJSON)

RestArea(aZA2)
Return aRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fGrJson
Fun��o para Montar o Layout JSon baseado no Modelo cadastrado na Tabela ZA3
@type function
@version 12.1.27
@author Carlos CLeuber
@since 08/12/2020
/*/
User Function fGrJson(cLayOut,cTab,nIndice,cCpsPesq,cChvPesq,cChvParam)
Local aZA3	:= GetArea()
Local nCont	:= 1
Local cValor:= ''
Local cCont	:= ''
Local cRet	:= ''

If !Empty(cChvParam)
	cRet := alltrim(cChvParam)+'={'
else
	cRet := '{'
Endif

DbSelectArea("ZA3")
ZA3->(DbSetOrder(2)) //Filial+Codigo Layout+Ordem
If ZA3->(DbSeek(FWxFilial("ZA3")+cLayOut,.T.))

	While !ZA3->(Eof()) .and. ZA3->ZA3_COD==cLayOut

		
		If ZA3->ZA3_TIPTAG == '1'

			If empty(ZA3->ZA3_CONTEU)
				If ZA3->ZA3_TPDADO == '2'
					cCont:= cvaltochar(0)
				Else
					cCont:= 'null'
				Endif
			Else
		
				If "->"  $ alltrim(ZA3->ZA3_CONTEU) .or. "U_"  $ upper(alltrim(ZA3->ZA3_CONTEU)) .or. ;
					( ("("  $ alltrim(ZA3->ZA3_CONTEU)) .and. (")"  $ alltrim(ZA3->ZA3_CONTEU)) )

					cValor:= &(ZA3->ZA3_CONTEU)
				Else
					cValor:= ZA3->ZA3_CONTEU
				Endif

				If ZA3->ZA3_TPDADO == '1'
					cCont:= '"' + alltrim( substr(cValor,1,ZA3->ZA3_TAMANH) ) + '"'

				elseIf ZA3->ZA3_TPDADO == '2' .and. ZA3->ZA3_DECIMA = 0
					cCont:= alltrim(cvaltochar(cValor))

				elseIf ZA3->ZA3_TPDADO == '2' .and. ZA3->ZA3_DECIMA != 0
					//cCont:= padl(strtran(strtran(cValor,".",""),",",""),nDec) 
					cCont:= alltrim(cvaltochar(cValor))

				ElseIf ZA3->ZA3_TPDADO == '3'
					cCont:= '"'+ DTOS(cValor) + '"'

				ElseIf ZA3->ZA3_TPDADO == '4'
					If Substr(cValor,1,1) $ "V|T"
						cCont:= 'True'
					Else
						cCont:= 'False'
					Endif
				Endif

			Endif

			cRet	+= '"' + alltrim(ZA3->ZA3_TAG) + '":'+ cCont
			cValor	:= ''
			cCont	:= ''
			
		else

			If !Empty(ZA3->ZA3_CODARR)

				cRet+= '"' + alltrim(ZA3->ZA3_TAG) + '": ['

				DbSelectArea(cTab)
				(cTab)->(DbSetOrder(nIndice))
				If (cTab)->(DbSeek(cChvPesq,.T.))
					While ! (cTab)->(Eof()) .and. (cTab)->&(cCpsPesq) == cChvPesq

						If nCont > 1
							cRet+= ','
						Endif

						cRet+=  U_fJsonArr(ZA3->ZA3_CODARR) 

						(cTab)->(DbSkip())
						nCont++
					End
				Endif

				cRet+= ']'
			Else
				cRet+= '"' + alltrim(ZA3->ZA3_TAG) + '": null'
			Endif			

		Endif

		ZA3->(DbSkip())

		If ZA3->ZA3_COD == cLayOut
			cRet+= ","
		Endif

	End
Endif

If !Empty(cChvParam)
	cRet += '}'
else
	cRet += '}'
Endif

RestArea(aZA3)
Return cRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fJsonArr
Fun��o para Montar o Layout JSon baseado no Modelo cadastrado na Tabela ZA4
@type function
@version 12.1.27
@author Carlos CLeuber
@since 08/12/2020
@param cLayout, character, codigo do layout do WebService
/*/
User Function fJsonArr(cLayOut,cTab,nIndice,cCpsPesq,cChvPesq)
Local aZA4	:= GetArea()
Local cValor:= ''
Local cCont	:= ''
Local cRet	:= '{'

DbSelectArea("ZA4")
ZA4->(DbSetOrder(2)) //Filial+Codigo Layout+Ordem
If ZA4->(DbSeek(FWxFilial("ZA4")+cLayOut,.T.))

	While !ZA4->(Eof()) .and. ZA4->ZA4_COD==cLayOut

		
		If ZA4->ZA4_TIPTAG == '1'

			If empty(ZA4->ZA4_CONTEU)

				If ZA4->ZA4_TPDADO == '2'
					cCont:= cvaltochar(0)
				Else
					cCont:= 'null'
				Endif

			Else

				If "->"  $ alltrim(ZA4->ZA4_CONTEU) .or. "U_"  $ upper(alltrim(ZA4->ZA4_CONTEU)) .or. ;
				( ("("  $ alltrim(ZA4->ZA4_CONTEU)) .and. (")"  $ alltrim(ZA4->ZA4_CONTEU)) )

					cValor:= &(ZA4->ZA4_CONTEU)
				Else
					cValor:= ZA4->ZA4_CONTEU
				Endif

				If ZA4->ZA4_TPDADO == '1'
					cCont:= '"' + alltrim( substr(cValor,1,ZA4->ZA4_TAMANH) ) + '"'

				elseIf ZA4->ZA4_TPDADO == '2' .and. ZA4->ZA4_DECIMA = 0
					cCont:= cvaltochar(cValor)

				elseIf ZA4->ZA4_TPDADO == '2' .and. ZA4->ZA4_DECIMA != 0
					cCont:= cvaltochar(cValor)

				ElseIf ZA4->ZA4_TPDADO == '3'
					cCont:= '"'+ DTOS(cValor) + '"'

				ElseIf ZA3->ZA3_TPDADO == '4'
					If Substr(cValor,1,1) $ "V|T"
						cCont:= 'True'
					Else
						cCont:= 'False'
					Endif

				Endif

			Endif

			cRet+= '"' + alltrim(ZA4->ZA4_TAG) + '":'+ cCont
			cValor	:= ''
			cCont	:= ''			

		else

			If !Empty(ZA4->ZA4_CODARR)
				cRet+= '"' + alltrim(ZA4->ZA4_TAG) + '":[' + U_fJsonArr(ZA4->ZA4_CODARR) + ']'
			Else
				cRet+= '"' + alltrim(ZA4->ZA4_TAG) + '": null'
			Endif

			/*
			cRet+= '"' + alltrim(ZA4->ZA4_TAG) + '": ['

			DbSelectArea(cTab)
			(cTab)->(DbSetOrder(nIndice))
			If (cTab)->(DbSeek(cChvPesq,.T.))
				While ! (cTab)->(Eof()) .and. (cTab)->&(cCpsPesq) == cChvPesq

					If nCont > 1
						cRet+= ','
					Endif
					
					cRet+=  U_fJsonArr(ZA4->ZA4_CODARR) 

					(cTab)->(DbSkip())
					nCont++
				End
			Endif

			cRet+= ']'
			*/


		Endif

		ZA4->(DbSkip())

		If ZA4->ZA4_COD == cLayOut
			cRet+= ","
		Endif

	End
Endif
	
cRet+= '}'

RestArea(aZA4)
Return cRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fResulCnx
Fun��o para Retornar o Resultado da Integra��o WS
@type function
@version 12.1.27
@author Carlos Cleuber
@since 21/12/2020
@param cLayout, character, codigo do layout do WebService
/*/
Static Function fRslCnx(cSrv, nCod)
Local aCodError:= {}
Local aRet:= array(2)
Local nPos:= 0
Local cWSPar1:= alltrim(GetMv("FZ_WSWMS1"))	//"[FZ_WSWMS1] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Cadastro PRODUTOS]" 		
Local cWSPar2:= alltrim(GetMv("FZ_WSWMS2"))	//"[FZ_WSWMS2] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Cadastro FORNECEDOR]"		
Local cWSPar3:= alltrim(GetMv("FZ_WSWMS3"))	//"[FZ_WSWMS3] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Cadastro CLIENTE]"		
Local cWSPar4:= alltrim(GetMv("FZ_WSWMS4"))	//"[FZ_WSWMS4] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Cadastro PESSOAS]"		
Local cWSPar5:= alltrim(GetMv("FZ_WSWMS5"))	//"[FZ_WSWMS5] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Cadastro PEDIDOS]" 		
Local cWSPar6:= alltrim(GetMv("FZ_WSWMS6"))	//"[FZ_WSWMS6] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Cadastro RECEBIMENTOS]"	
Local cWSPar7:= alltrim(GetMv("FZ_WSWMS7"))	//"[FZ_WSWMS7] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Manutencao de Lotes]"	
Local cWSPar8:= alltrim(GetMv("FZ_WSWMS8"))	//"[FZ_WSWMS8] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Movimentacao de Interna]"	
Local cWSPar9:= alltrim(GetMv("FZ_WSWMS9"))	//"[FZ_WSWMS9] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Transferencias]"	
Local cWSParA:= alltrim(GetMv("FZ_WSWMSA"))	//"[FZ_WSWMS9] - C�digo do Layout de Integra��o do WS CyberLog WMS - [Aceite do Produto]"	

//Produto
aAdd( aCodError, {cWSPar1, 1 , 'Inserido'														, .t. } )
aAdd( aCodError, {cWSPar1, 2 , 'Alterado'														, .t. } )
aAdd( aCodError, {cWSPar1, 3 , 'Exclu�do'														, .t. } )
aAdd( aCodError, {cWSPar1, 4 , 'N�o inserido(n�o h� configura��o de dep�sito para a empresa)'	, .f. } )
aAdd( aCodError, {cWSPar1, 5 , 'N�o inserido(dep�sito informado n�o possui configura��o)'		, .f. } )
aAdd( aCodError, {cWSPar1, 6 , 'N�o inserido(ERPID vazio)'										, .f. } )
aAdd( aCodError, {cWSPar1, 7 , 'N�o inserido(c�digo de barras vazio)'							, .f. } )
aAdd( aCodError, {cWSPar1, 8 , 'N�o inserido(c�digo reduzido vazio)'							, .f. } )
aAdd( aCodError, {cWSPar1, 9 , 'N�o inserido(fornecedor n�o existe no WMS)'						, .f. } )
aAdd( aCodError, {cWSPar1, 42 , ' Erro n�o cadastrado(informa��es no log do servidor).'			, .f. } )

aAdd( aCodError, {cWSPar2, 1, 'Inserido'														, .t. } )
aAdd( aCodError, {cWSPar2, 2, 'Alterado'														, .t. } )
aAdd( aCodError, {cWSPar2, 3, 'Exclu�do'														, .t. } )
aAdd( aCodError, {cWSPar2, 4, 'N�o inserido(dep�sito informado n�o possui configura��o)'		, .f. } )
aAdd( aCodError, {cWSPar2, 5, 'N�o inserido(ERPID vazio)'										, .f. } )
aAdd( aCodError, {cWSPar2, 6, 'N�o inserido(n�mero vazio)'										, .f. } )
aAdd( aCodError, {cWSPar2, 7, 'N�o inserido(nome vazio)'										, .f. } )
aAdd( aCodError, {cWSPar2, 8, 'N�o inserido(endere�o vazio)'									, .f. } )
aAdd( aCodError, {cWSPar2, 9, 'N�o inserido(cep vazio)'											, .f. } )
aAdd( aCodError, {cWSPar2, 10, 'N�o inserido(cidade/uf vazio)'									, .f. } )
aAdd( aCodError, {cWSPar2, 42, ' Erro n�o cadastrado(informa��es no log do servidor).'			, .f. } )

//Cliente
aAdd( aCodError, {cWSPar3, 1 ,'Inserido'														, .t. } )
aAdd( aCodError, {cWSPar3, 2 ,'Alterado'														, .t. } )
aAdd( aCodError, {cWSPar3, 3 ,'Exclu�do'														, .t. } )
aAdd( aCodError, {cWSPar3, 4 ,'N�o inserido(dep�sito informado n�o possui configura��o)'		, .f. } )
aAdd( aCodError, {cWSPar3, 5 ,'N�o inserido(ERPID vazio)'										, .f. } )
aAdd( aCodError, {cWSPar3, 7 ,'N�o inserido(nome vazio)'										, .f. } )
aAdd( aCodError, {cWSPar3, 8 ,'N�o inserido(endere�o vazio)'									, .f. } )
aAdd( aCodError, {cWSPar3, 9 ,'N�o inserido(cep vazio)'											, .f. } )
aAdd( aCodError, {cWSPar3, 10,'N�o inserido(cidade/uf vazio)'									, .f. } )
aAdd( aCodError, {cWSPar3, 42,' Erro n�o cadastrado(informa��es no log do servidor).'			, .f. } )

//Pessoas
aAdd( aCodError, {cWSPar4, 1, 'Inserido'														, .t. } )
aAdd( aCodError, {cWSPar4, 2, 'Alterado'														, .t. } )
aAdd( aCodError, {cWSPar4, 3, 'Exclu�do'														, .t. } )
aAdd( aCodError, {cWSPar4, 4, 'N�o inserido(dep�sito informado n�o possui configura��o)'		, .f. } )
aAdd( aCodError, {cWSPar4, 5, 'N�o inserido(ERPID vazio)'										, .f. } )
aAdd( aCodError, {cWSPar4, 6, 'N�o inserido(n�mero vazio)'										, .f. } )
aAdd( aCodError, {cWSPar4, 7, 'N�o inserido(nome vazio)'										, .f. } )
aAdd( aCodError, {cWSPar4, 8, 'N�o inserido(endere�o vazio)'									, .f. } )
aAdd( aCodError, {cWSPar4, 9, 'N�o inserido(cep vazio)'											, .f. } )
aAdd( aCodError, {cWSPar4, 10, 'N�o inserido(cidade/uf vazio)'									, .f. } )
aAdd( aCodError, {cWSPar4, 42, ' Erro n�o cadastrado(informa��es no log do servidor).'			, .f. } )

//Pedidos
aAdd( aCodError, {cWSPar5, 1 , 'Inserido'														, .t. } )
aAdd( aCodError, {cWSPar5, 2 , 'Alterado'														, .t. } )
aAdd( aCodError, {cWSPar5, 3 , 'Exclu�do'														, .t. } )
aAdd( aCodError, {cWSPar5, 4 , 'N�o alterado (processo j� iniciado)'							, .f. } )
aAdd( aCodError, {cWSPar5, 5 , 'N�o alterado (confer�ncia de separa��o j� iniciada)'			, .f. } )
aAdd( aCodError, {cWSPar5, 6 , 'N�o inserido (processo n�o cadastrado)'							, .f. } )
aAdd( aCodError, {cWSPar5, 7 , 'N�o inserido (cliente n�o cadastrado)'							, .f. } )
aAdd( aCodError, {cWSPar5, 8 , 'N�o inserido (rota n�o cadastrada)'								, .f. } )
aAdd( aCodError, {cWSPar5, 9 , 'N�o inserido (recebimento com documento vazio)'					, .f. } )
aAdd( aCodError, {cWSPar5, 10 , 'N�o inserido (pedido com documento vazio)'						, .f. } )
aAdd( aCodError, {cWSPar5, 11 , 'N�o inserido (registro incompleto)'							, .f. } )
aAdd( aCodError, {cWSPar5, 12 , 'N�o inserido (produto n�o consta no WMS)'						, .f. } )
aAdd( aCodError, {cWSPar5, 13 , 'Inserido (pedido complementar)'								, .f. } )
aAdd( aCodError, {cWSPar5, 14 , 'Aguardando (conclus�o da separa��o para integrar)'				, .f. } )
aAdd( aCodError, {cWSPar5, 15 , 'Executando separa��o'											, .f. } )
aAdd( aCodError, {cWSPar5, 16 , 'Conclu�da separa��o'											, .f. } )
aAdd( aCodError, {cWSPar5, 17 , 'Executando confer�ncia de separa��o'							, .f. } )
aAdd( aCodError, {cWSPar5, 18 , 'Conclu�da confer�ncia de separa��o'							, .f. } )
aAdd( aCodError, {cWSPar5, 19 , 'Executando consolida��o'										, .f. } )
aAdd( aCodError, {cWSPar5, 20 , 'Conclu�da consolida��o'										, .f. } )
aAdd( aCodError, {cWSPar5, 21 , 'Executando expedi��o'											, .f. } )
aAdd( aCodError, {cWSPar5, 22 , 'Conclu�da expedi��o'											, .f. } )
aAdd( aCodError, {cWSPar5, 42 , ' Erro n�o cadastrado(informa��es no log do servidor).'			, .f. } )

//Recebimentos
aAdd( aCodError, {cWSPar6, 1 , 'Inserido'														, .t. } )
aAdd( aCodError, {cWSPar6, 2 , 'Alterado'														, .t. } )
aAdd( aCodError, {cWSPar6, 3 , 'Exclu�do'														, .t. } )
aAdd( aCodError, {cWSPar6, 4 , 'N�o alterado (processo j� iniciado)'							, .f. } )
aAdd( aCodError, {cWSPar6, 5 , 'N�o alterado (confer�ncia de separa��o j� iniciada)'			, .f. } )
aAdd( aCodError, {cWSPar6, 6 , 'N�o inserido (N�o h� configura��o de deposito para Empresa)'	, .f. } )
aAdd( aCodError, {cWSPar6, 7 , 'N�o inserido (deposito informado n�o possui configura��o)'		, .f. } )
aAdd( aCodError, {cWSPar6, 8 , 'N�o Excluido (processo ja iniciado)'							, .f. } )
aAdd( aCodError, {cWSPar6, 9 , 'N�o inserido (documento vazio)'									, .f. } )
aAdd( aCodError, {cWSPar6, 10 , 'N�o inserido (ERPID vazio)'									, .f. } )
aAdd( aCodError, {cWSPar6, 11 , 'N�o inserido (fornecedor nao cadastrado)'						, .f. } )
aAdd( aCodError, {cWSPar6, 12 , 'N�o inserido (fornecedor vazio)'								, .f. } )
aAdd( aCodError, {cWSPar6, 13 , 'Nao inserido (produto n�o consta no WMS)'						, .f. } )
aAdd( aCodError, {cWSPar6, 42 , ' Erro n�o cadastrado(informa��es no log do servidor).'			, .f. } )

//Manuten��o de Lotes
aAdd( aCodError, {cWSPar7, 1 , 'Processado'														, .t. } )
aAdd( aCodError, {cWSPar7, 2 , 'Processado com pend�ncias'										, .f. } )
aAdd( aCodError, {cWSPar7, 3 , 'N�o processado(n�o h� configura��o de dep�sito para a empresa)' , .f. } )
aAdd( aCodError, {cWSPar7, 4 , 'N�o processado(dep�sito informado n�o possui configura��o)'		, .f. } )
aAdd( aCodError, {cWSPar7, 5 , 'N�o processado(c�digo reduzido vazio)'							, .f. } )
aAdd( aCodError, {cWSPar7, 6 , 'N�o processado(produto n�o identificado no WMS)'				, .f. } )
aAdd( aCodError, {cWSPar7, 7 , 'N�o processado(lote n�o encontrado)' 							, .f. } )
aAdd( aCodError, {cWSPar7, 8 , 'N�o processado(lote n�o encontrado no layout especificado)' 	, .f. } )
aAdd( aCodError, {cWSPar7, 9 , 'N�o processado(campo opera��o vazio)'							, .f. } )
aAdd( aCodError, {cWSPar7, 10 , 'N�o processado(opera��o n�o identificada)'						, .f. } )
aAdd( aCodError, {cWSPar7, 11 , 'N�o processado(lote n�o informado)'							, .f. } )
aAdd( aCodError, {cWSPar7, 42 , 'Erro n�o cadastrado(informa��es no log do servidor)'			, .f. } )

//Movimentacao Interna
aAdd( aCodError, {cWSPar8, 1  , 'Inserido'														, .t. } )
aAdd( aCodError, {cWSPar8, 2  , 'Alterado'														, .t. } )
aAdd( aCodError, {cWSPar8, 3  , 'Exclu�do'														, .t. } )
aAdd( aCodError, {cWSPar8, 4  , 'N�o alterado (processo j� iniciado)'							, .f. } )
aAdd( aCodError, {cWSPar8, 6  , 'N�o inserido (processo n�o cadastrado)'						, .f. } )
aAdd( aCodError, {cWSPar8, 10 , 'N�o inserido (pedido com documento vazio)'						, .f. } )
aAdd( aCodError, {cWSPar8, 11 , 'N�o inserido (registro incompleto)'							, .f. } )
aAdd( aCodError, {cWSPar8, 12 , 'N�o inserido (produto n�o consta no WMS)'						, .f. } )
aAdd( aCodError, {cWSPar8, 14 , 'Aguardando (conclus�o da separa��o para integrar)'				, .f. } )
aAdd( aCodError, {cWSPar8, 15 , 'Executando separa��o'											, .f. } )
aAdd( aCodError, {cWSPar8, 16 , 'Conclu�da separa��o'											, .f. } )
aAdd( aCodError, {cWSPar8, 42 , 'Erro n�o cadastrado(informa��es no log do servidor).'			, .f. } )

//Transferencias
aAdd( aCodError, {cWSPar9, 1  , 'Inserido'														, .t. } )
aAdd( aCodError, {cWSPar9, 2  , 'Alterado'														, .t. } )
aAdd( aCodError, {cWSPar9, 3  , 'Exclu�do'														, .t. } )
aAdd( aCodError, {cWSPar9, 4  , 'N�o alterado (processo j� iniciado)'							, .f. } )
aAdd( aCodError, {cWSPar9, 6  , 'N�o inserido (processo n�o cadastrado)'						, .f. } )
aAdd( aCodError, {cWSPar9, 10 , 'N�o inserido (pedido com documento vazio)'						, .f. } )
aAdd( aCodError, {cWSPar9, 11 , 'N�o inserido (registro incompleto)'							, .f. } )
aAdd( aCodError, {cWSPar9, 12 , 'N�o inserido (produto n�o consta no WMS)'						, .f. } )
aAdd( aCodError, {cWSPar9, 14 , 'Aguardando (conclus�o da separa��o para integrar)'				, .f. } )
aAdd( aCodError, {cWSPar9, 15 , 'Executando separa��o'											, .f. } )
aAdd( aCodError, {cWSPar9, 16 , 'Conclu�da separa��o'											, .f. } )
aAdd( aCodError, {cWSPar9, 42 , 'Erro n�o cadastrado(informa��es no log do servidor).'			, .f. } )

//Aceite do Produto no WMS
aAdd( aCodError, {cWSParA, 1  , 'Efetivado'														, .t. } )
aAdd( aCodError, {cWSParA, 2  , 'N�o Alterado(erpId n�o consta no WMS)'							, .f. } )
aAdd( aCodError, {cWSParA, 3  , 'Opera��o inv�lida (opera��o n�o conforme documenta��o)'		, .f. } )
aAdd( aCodError, {cWSParA, 42 , 'Erro n�o cadastrado(informa��es no log do servidor).'			, .f. } )


nPos := aScan( aCodError, { |x| x[1]==AllTrim(cSrv) .and. x[2]==nCod } )
If nPos >0
	aRet[1]:= aCodError[nPos,04]
	aRet[2]:= cvaltochar(aCodError[nPos,02]) +"-"+ aCodError[nPos,03]
Else
	aRet[1]:= .F.
	aRet[2]:= cvaltochar(nCod) +"- Mensagem de Erro n�o encontrada."
Endif

Return aRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} DtJsonWMS()
Fun��o para Montar a Data no Formato Json para envio no WMS CyberLOg
@type function
@version 12.1.27
@author Carlos CLeuber
@since 23/12/2020
@param cLayout, character, codigo do layout do WebService
/*/
User Function DtJsonWMS(dData)
Local cRet:= ''
Local cHr:= ''
Local cMi:= ''
Local cPer:= ''
Local cData:= ''
Local cDia:= ''
Local cMes:= ''
Local cAno:= ''

If dData= Nil .or. Empty(dData)
	dData:= dDataBase
Endif

cHr:= substr(Time(),1,2)
cMi:= substr(Time(),3,6) 
If substr(cHr,1,2) >= '13' .and. substr(cHr,1,2) <= '23'
	cHr:= strzero(val(substr(cHr,1,2)) - 12, 02)
	cPer:= "PM"
Else
	cPer:= "AM"
Endif

cData:= dtos(dData)

cAno:= substr(cData,1,4)
cMes:= upper(substr(MesExtenso(substr(cData,5,2)),1,3))
cDia:= substr(cData,7,2)

If cMes == 'FEV'
	cMes:= 'FEB'
ElseIf cMes == 'ABR'
	cMes:= 'APR'
ElseIf cMes == 'MAI'
	cMes:= 'MAY'
ElseIf cMes == 'AGO'
	cMes:= 'AGU'
ElseIf cMes == 'SET'
	cMes:= 'SEP'
ElseIf cMes == 'OUT'
	cMes:= 'OCT'
ElseIf cMes == 'DEZ'
	cMes:= 'DEC'
Endif

cRet:= cMes + ' ' + cDia + ', ' + cAno + ' ' + cHr+cMi + ' ' + cPer

Return cRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} DtJsonERP()
Fun��o para Montar a Data no Formato ERP Protheus
@type function
@version 12.1.27
@author Carlos CLeuber
@since 14/01/2021
@param cLayout, character, codigo do layout do WebService
/*/
User Function DtJsonERP(dData)
Local aRet:= array(2)
Local cHr:= ''
Local cMi:= ''
Local cSe:= ''

Local cDia:= ''
Local cMes:= ''
Local cAno:= ''


//012345678901234567890123
//Jan 06, 2021 03:57:06 PM

If dData= Nil .or. Empty(dData)

	aRet[1]:= dDataBase
	aRet[2]:= Time()

Else

	cMes:= upper(substr(dData,1,3))
	cDia:= substr(dData,5,2)
	cAno:= substr(dData,9,4)

	If cMes == 'JAN'
		cMes:= '01'
	ElseIf cMes == 'FEB'
		cMes:= '02'
	ElseIf cMes == 'MAR'
		cMes:= '03'
	ElseIf cMes == 'APR'
		cMes:= '04'
	ElseIf cMes == 'MAY'
		cMes:= '05'
	ElseIf cMes == 'JUN'
		cMes:= '06'
	ElseIf cMes == 'JUL'
		cMes:= '07'
	ElseIf cMes == 'AGU'
		cMes:= '08'
	ElseIf cMes == 'SEP'
		cMes:= '09'
	ElseIf cMes == 'OCT'
		cMes:= '10'
	ElseIf cMes == 'NOV'
		cMes:= '11'
	ElseIf cMes == 'DEC'
		cMes:= '12'
	Endif

	cHr:= substr(dData,14,2)
	cMi:= substr(dData,17,2) 
	cSe:= substr(dData,20,2) 

	If upper(substr(dData,22,2)) == "PM"
		cHr:= strzero(val(cHr) + 12, 02)
	endif

	aRet[1]:= ctod(cDia+'/'+cMes+'/'+cAno)
	aRet[2]:= cHr + ':' + cMi + ':' + cSe 

Endif

Return aRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MovIErp()
Fun��o para efetuar a execauto de Movimentacao Interna MATA241
@type function
@version 12.1.27
@author Carlos CLeuber
@since 02/01/2021
/*/
User Function fMovIERP(aCab,aItens,nOpcAuto)
Local aRet 		:= array(2)
Local cTxtLog	:= ''
Local lRet		:= .T.

Private lMsErroAuto := .F.

MakeDir("\WEB\WSCYBERLOG\")

If nOpcAuto == 3

	MSExecAuto({|x,y| mata241(x,y,z)},aCab,aItens)

	if lMsErroAuto
		MostraErro("\WEB\WSCYBERLOG\", "ERR_MOVINT.TXT")
		cTxtLog:= U_WSTxtLog("\WEB\WSCYBERLOG\ERR_MOVINT.TXT")

		lRet := .F.
	else
		cTxtLog:= ''
		lRet := .T.
	EndIf

EndIf

aRet[1]:= lRet
aRet[2]:= ''

Return aRet



//-------------------------------------------------------------------------------
/*/{Protheus.doc} TrfEndERP()
Fun��o para efetuar a execauto de transferencia MATA261
@type function
@version 12.1.27
@author Carlos CLeuber
@since 15/01/2021
@param cLayout, character, codigo do layout do WebService
/*/
User Function fTrfERP(aAuto,nOpcAuto)
Local aRet 		:= array(2)
Local lRet		:= .T.
Local cTxtLog	:= ''
Local nX

Private lMsErroAuto := .F.

MakeDir("\WEB\WSCYBERLOG\")
	
If nOpcAuto == 3

	MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

	if lMsErroAuto
		MostraErro("\WEB\WSCYBERLOG\", "ERR_TRANSF.TXT")
		cTxtLog:= U_WSTxtLog("\WEB\WSCYBERLOG\ERR_TRANSF.TXT")

		lRet := .F.
	else
		lRet := .T.
		cTxtLog:= ''
	EndIf

ElseIf nOpcAuto == 6 //Estornar

    //    conout("Exemplo de estorno de movimenta��o multipla baseado na inclus�o do movimenta��o multipla anterior")

    lMsErroAuto := .F.

    //-- Preenchimento dos campos
    aAuto := {}
    aadd(aAuto,{"D3_DOC", cDocumen, Nil})
    aadd(aAuto,{"D3_COD", aLista[nX], Nil})
        
    DbSelectArea("SD3")
    DbSetOrder(2)
    DbSeek(xFilial("SD3")+cDocumen+aLista[nX])
    
    //MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)
        
    If lMsErroAuto
		MostraErro("\WEB\WSCYBERLOG\", "ERR_TRANSF.TXT")
		cTxtLog:= U_WSTxtLog("\WEB\WSCYBERLOG\ERR_TRANSF.TXT")
	   lRet:= .F.
	Else
		lRet:= .T.
		cTxtLog:= ''
    EndIf

EndIf

aRet[1]:= lRet
aRet[2]:= cTxtLog

Return aRet


//-----------------------------------------------------------------------------------------------------------------------
//Abre o Arquivo .LOG e retorna em uma variavel TXT    
//Programador: Carlos Cleuber Pereira 
User Function WSTXTLOG( cArqLog )

Local cTexto := ""
Local cBuffer := ""     

FT_FUse(cArqLog)
FT_FGOTOP()  
nLin:= 1

While ( !FT_FEof() )	

	cBuffer := FT_FREADLN()

	cTexto += cBuffer + " " + CRLF

	FT_FSKIP()
	nLin++

EndDo
FT_FUse()    

cTexto:= strtran( cTexto, "\r","")
cTexto:= strtran( cTexto, "\n","")

RETURN cTexto        




