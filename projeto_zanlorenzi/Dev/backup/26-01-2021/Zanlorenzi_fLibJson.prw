#Include 'Protheus.ch'
/*
-------------------------------------------------------------------------------
Biblioteca de Funções para Conexão do WS CyberLog
-------------------------------------------------------------------------------
*/ 

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fIDWmsErp
Função para Retornar o Nr da Transação de integração
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
Função para fazer Login e Autenticação no Serviço do WS JSon 
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

//Monta a conexão com o servidor REST
oRest := FWRest():New(cIpSrv) 
oRest:setPath(cNameSrv)
	
//Definindo o parâmetro a ser usado no POST
cBody := FWNoAccent(cBody)
oRest:SetPostParams(cBody)
oRest:SetChkStatus(.F.)
	
//Publica a alteração, e caso não dê certo, mostra erro
If ! oRest:Post(aHeader)
	cMsg:= 'Atenção !!! Houve erro na atualização no servidor!' + CRLF + ;
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
				cMsg:= "Autenticação OK. Token "+ cToken
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
Função para fazer Login e Autenticação no Serviço do WS JSon 
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

//Monta a conexão com o servidor REST
oRest := FWRest():New(cIpSrv) 
oRest:setPath(cNameSrv)
	
//Definindo o parâmetro a ser usado no POST
cBody := FWNoAccent(cBody)
oRest:SetPostParams(cBody)
oRest:SetChkStatus(.F.)
	
//Publica a alteração, e caso não dê certo, mostra erro
If ! oRest:Post(aHeader)
	cMsg:= 'Atenção !!! Houve erro na atualização no servidor!' + CRLF + ;
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
Função para Conectar ao Serviço do WS JSon baseado do Modelo cadastrado na Tabela ZA2
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
Local aRet		:= array(3)
Local aHeader	:= {}
Local aLogIn	:= {}
Local oJson		
Local oRest
Local oObj

Local cError	:= ''
Local cCodErro	:= ''
Local cCodRet	:= ''
Local cRetJson	:= ''
Local cJson		:= ''
Local nStatus	:= 0

Local cWSPar1:= alltrim(GetMv("FZ_WSWMS1"))	//"[FZ_WSWMS1] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PRODUTOS]" 		
Local cWSPar2:= alltrim(GetMv("FZ_WSWMS2"))	//"[FZ_WSWMS2] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro FORNECEDOR]"		
Local cWSPar3:= alltrim(GetMv("FZ_WSWMS3"))	//"[FZ_WSWMS3] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro CLIENTE]"		
Local cWSPar4:= alltrim(GetMv("FZ_WSWMS4"))	//"[FZ_WSWMS4] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PESSOAS]"		
Local cWSPar5:= alltrim(GetMv("FZ_WSWMS5"))	//"[FZ_WSWMS5] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PEDIDOS]" 		
Local cWSPar6:= alltrim(GetMv("FZ_WSWMS6"))	//"[FZ_WSWMS6] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro RECEBIMENTOS]"	

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

		//Monta a conexão com o servidor REST
		oRest := FWRest():New(cEndWS) 
		oRest:setPath(cMetodo) 
		
		//Definindo o parâmetro a ser usado no POST
		cBody := FWNoAccent(cBody)
		oRest:SetPostParams(cBody)
		oRest:SetChkStatus(.F.)
		
		//Publica a alteração, e caso não dê certo, mostra erro
		If ! oRest:Post(aHeader)
			lret:= .F.
			cCodRet:= "999"
			cMsg:= 'Atenção !!! Houve erro na atualização no servidor!' + CRLF + ;
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
							cMsg:= "Serviço: " + cLayOut + CRLF
							cMsg+= "Método: "+ cMetodo + CRLF
							cMsg+= "Codigo Retorno: " + fRslCnx(cLayOut, val(cCodRet)) 

							cCodErro:= alltrim(substr(cCodRet,1,2))
							If cCodErro $ "!" .or. (cCodErro != '1' .and. cCodErro != '2' .and. cCodErro != '3' )
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
	cMsg:= "Não foi possivel fazer o Login!!!"+ CRLF + aLogIn[2]
Endif

cJson+=CRLF+CRLF+"{ Resultado"+ CRLF
cJson+="Codigo Retorno:" + cCodRet + CRLF
cJson+="Mensagem: "+ cMsg + "}"

aRet[1]:= lRet
aRet[2]:= cCodRet
aRet[3]:= cMsg
	
If cLayOut == cWSPar1
	cTipoMov:= "1"
Endif
If cLayOut == cWSPar2
	cTipoMov:= "2"
Endif
If cLayOut == cWSPar3
	cTipoMov:= "3"
Endif
If cLayOut == cWSPar4
	cTipoMov:= "4"
Endif
If cLayOut == cWSPar5
	cTipoMov:= "5"
Endif
If cLayOut == cWSPar6
	cTipoMov:= "6"
Endif

RecLock("ZA1",.T.)
ZA1->ZA1_FILIAL:= FWxFilial("ZA1")
ZA1->ZA1_STATUS:= iIf(lRet,"1","0")
ZA1->ZA1_NRTRAN:= U_fIDWmsErp()
ZA1->ZA1_TIPOTR:= "E"
ZA1->ZA1_ORIGEM:= "fExpVli"
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
Função para Montar o Layout JSon baseado no Modelo cadastrado na Tabela ZA3
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
	cRet := lower(alltrim(cChvParam))+'={'
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
Função para Montar o Layout JSon baseado no Modelo cadastrado na Tabela ZA4
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
Função para Retornar o Resultado da Integração WS
@type function
@version 12.1.27
@author Carlos Cleuber
@since 21/12/2020
@param cLayout, character, codigo do layout do WebService
/*/
Static Function fRslCnx(cSrv, nCod)
Local aCodError:= {}
Local cRet:= ""
Local nPos:= 0
Local cWSPar1:= GetMv("FZ_WSWMS1")	//"[FZ_WSWMS1] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PRODUTOS]" 		
Local cWSPar2:= GetMv("FZ_WSWMS2")	//"[FZ_WSWMS2] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro FORNECEDOR]"		
Local cWSPar3:= GetMv("FZ_WSWMS3")	//"[FZ_WSWMS3] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro CLIENTE]"		
Local cWSPar4:= GetMv("FZ_WSWMS4")	//"[FZ_WSWMS4] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PESSOAS]"		
Local cWSPar5:= GetMv("FZ_WSWMS5")	//"[FZ_WSWMS5] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro PEDIDOS]" 		
Local cWSPar6:= GetMv("FZ_WSWMS6")	//"[FZ_WSWMS6] - Código do Layout de Integração do WS CyberLog WMS - [Cadastro RECEBIMENTOS]"	

//Produto
aAdd( aCodError, {cWSPar1, 1 , 'Inserido'} )
aAdd( aCodError, {cWSPar1, 2 , 'Alterado'} )
aAdd( aCodError, {cWSPar1, 3 , 'Excluído'} )
aAdd( aCodError, {cWSPar1, 4 , 'Não inserido(não há configuração de depósito para a empresa)'} )
aAdd( aCodError, {cWSPar1, 5 , 'Não inserido(depósito informado não possui configuração)'} )
aAdd( aCodError, {cWSPar1, 6 , 'Não inserido(ERPID vazio)'} )
aAdd( aCodError, {cWSPar1, 7 , 'Não inserido(código de barras vazio)'} )
aAdd( aCodError, {cWSPar1, 8 , 'Não inserido(código reduzido vazio)'} )
aAdd( aCodError, {cWSPar1, 9 , 'Não inserido(fornecedor não existe no WMS)'} )
aAdd( aCodError, {cWSPar1, 42 , 'Erro ao converter Objeto JSON - CyberLog'} )

aAdd( aCodError, {cWSPar2, 1, 'Inserido'} )
aAdd( aCodError, {cWSPar2, 2, 'Alterado'} )
aAdd( aCodError, {cWSPar2, 3, 'Excluído'} )
aAdd( aCodError, {cWSPar2, 4, 'Não inserido(depósito informado não possui configuração)'} )
aAdd( aCodError, {cWSPar2, 5, 'Não inserido(ERPID vazio)'} )
aAdd( aCodError, {cWSPar2, 6, 'Não inserido(número vazio)'} )
aAdd( aCodError, {cWSPar2, 7, 'Não inserido(nome vazio)'} )
aAdd( aCodError, {cWSPar2, 8, 'Não inserido(endereço vazio)'} )
aAdd( aCodError, {cWSPar2, 9, 'Não inserido(cep vazio)'} )
aAdd( aCodError, {cWSPar2, 10, 'Não inserido(cidade/uf vazio)'} )
aAdd( aCodError, {cWSPar2, 42, 'Erro ao converter Objeto JSON - CyberLog'} )

//Cliente
aAdd( aCodError, {cWSPar3, 1 ,'Inserido'} )
aAdd( aCodError, {cWSPar3, 2 ,'Alterado'} )
aAdd( aCodError, {cWSPar3, 3 ,'Excluído'} )
aAdd( aCodError, {cWSPar3, 4 ,'Não inserido(depósito informado não possui configuração)'} )
aAdd( aCodError, {cWSPar3, 5 ,'Não inserido(ERPID vazio)'} )
aAdd( aCodError, {cWSPar3, 7 ,'Não inserido(nome vazio)'} )
aAdd( aCodError, {cWSPar3, 8 ,'Não inserido(endereço vazio)'} )
aAdd( aCodError, {cWSPar3, 9 ,'Não inserido(cep vazio)'} )
aAdd( aCodError, {cWSPar3, 10,'Não inserido(cidade/uf vazio)'} )
aAdd( aCodError, {cWSPar3, 42,'Erro ao converter Objeto JSON - CyberLog'} )

//Pessoas
aAdd( aCodError, {cWSPar4, 1, 'Inserido'} )
aAdd( aCodError, {cWSPar4, 2, 'Alterado'} )
aAdd( aCodError, {cWSPar4, 3, 'Excluído'} )
aAdd( aCodError, {cWSPar4, 4, 'Não inserido(depósito informado não possui configuração)'} )
aAdd( aCodError, {cWSPar4, 5, 'Não inserido(ERPID vazio)'} )
aAdd( aCodError, {cWSPar4, 6, 'Não inserido(número vazio)'} )
aAdd( aCodError, {cWSPar4, 7, 'Não inserido(nome vazio)'} )
aAdd( aCodError, {cWSPar4, 8, 'Não inserido(endereço vazio)'} )
aAdd( aCodError, {cWSPar4, 9, 'Não inserido(cep vazio)'} )
aAdd( aCodError, {cWSPar4, 10, 'Não inserido(cidade/uf vazio)'} )
aAdd( aCodError, {cWSPar4, 42, 'Erro ao converter Objeto JSON - CyberLog'} )

//Pedidos
aAdd( aCodError, {cWSPar5, 1 , 'Inserido'} )
aAdd( aCodError, {cWSPar5, 2 , 'Alterado'} )
aAdd( aCodError, {cWSPar5, 3 , 'Excluído'} )
aAdd( aCodError, {cWSPar5, 4 , 'Não alterado (processo já iniciado)'} )
aAdd( aCodError, {cWSPar5, 5 , 'Não alterado (conferência de separação já iniciada)'} )
aAdd( aCodError, {cWSPar5, 6 , 'Não inserido (processo não cadastrado)'} )
aAdd( aCodError, {cWSPar5, 7 , 'Não inserido (cliente não cadastrado)'} )
aAdd( aCodError, {cWSPar5, 8 , 'Não inserido (rota não cadastrada)'} )
aAdd( aCodError, {cWSPar5, 9 , 'Não inserido (recebimento com documento vazio)'} )
aAdd( aCodError, {cWSPar5, 10 , 'Não inserido (pedido com documento vazio)'} )
aAdd( aCodError, {cWSPar5, 11 , 'Não inserido (registro incompleto)'} )
aAdd( aCodError, {cWSPar5, 12 , 'Não inserido (produto não consta no WMS)'} )
aAdd( aCodError, {cWSPar5, 13 , 'Inserido (pedido complementar)'} )
aAdd( aCodError, {cWSPar5, 14 , 'Aguardando (conclusão da separação para integrar)'} )
aAdd( aCodError, {cWSPar5, 15 , 'Executando separação'} )
aAdd( aCodError, {cWSPar5, 16 , 'Concluída separação'} )
aAdd( aCodError, {cWSPar5, 17 , 'Executando conferência de separação'} )
aAdd( aCodError, {cWSPar5, 18 , 'Concluída conferência de separação'} )
aAdd( aCodError, {cWSPar5, 19 , 'Executando consolidação'} )
aAdd( aCodError, {cWSPar5, 20 , 'Concluída consolidação'} )
aAdd( aCodError, {cWSPar5, 21 , 'Executando expedição'} )
aAdd( aCodError, {cWSPar5, 22 , 'Concluída expedição'} )
aAdd( aCodError, {cWSPar5, 42 , 'Erro ao converter Objeto JSON - CyberLog'} )

nPos := aScan( aCodError, { |x| x[1]==AllTrim(cSrv) .and. x[2]==nCod } )
If nPos >0 
	cRet:= cvaltochar(aCodError[nPos,02]) +"-"+ aCodError[nPos,03]
Else
	cRet:= cvaltochar(nCod) +"- Mensagem de Erro não encontrada."
Endif

Return cRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} DtJsonWMS()
Função para Montar a Data no Formato Json para envio no WMS CyberLOg
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
cMes:= substr(MesExtenso(substr(cData,5,2)),1,3)
cDia:= substr(cData,7,2)

cRet:= cMes + ' ' + cDia + ', ' + cAno + ' ' + cHr+cMi + ' ' + cPer

Return cRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} DtJsonERP()
Função para Montar a Data no Formato ERP Protheus
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
	ElseIf cMes == 'FEV'
		cMes:= '02'
	ElseIf cMes == 'MAR'
		cMes:= '03'
	ElseIf cMes == 'ABR'
		cMes:= '04'
	ElseIf cMes == 'MAI'
		cMes:= '05'
	ElseIf cMes == 'JUN'
		cMes:= '06'
	ElseIf cMes == 'JUL'
		cMes:= '07'
	ElseIf cMes == 'AGO'
		cMes:= '08'
	ElseIf cMes == 'SET'
		cMes:= '09'
	ElseIf cMes == 'OUT'
		cMes:= '10'
	ElseIf cMes == 'NOV'
		cMes:= '11'
	ElseIf cMes == 'DEZ'
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
/*/{Protheus.doc} TrfEndERP()
Função para efetuar a execauto de transferencia MATA261
@type function
@version 12.1.27
@author Carlos CLeuber
@since 15/01/2021
@param cLayout, character, codigo do layout do WebService
/*/
User Function fTrfERP(aAuto,nOpcAuto)
Local aRet 		:= array(2)
Local lRet		:= .T.
Local nX

Private lMsErroAuto := .F.

If nOpcAuto == 3

	MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

	if lMsErroAuto
		MostraErro()
		lRet := .F.
	else
		lRet := .T.
	EndIf

ElseIf nOpcAuto == 6 //Estornar

    //    conout("Exemplo de estorno de movimentação multipla baseado na inclusão do movimentação multipla anterior")

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
       MostraErro()
	   lRet:= .F.
    EndIf

EndIf

aRet[1]:= lRet
aRet[2]:= ''

Return aRet





