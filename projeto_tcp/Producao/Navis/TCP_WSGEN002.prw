#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} WSGEN002
Monitoramento Status NFSe.
@type function
@author luizf
@since 12/10/2016
/*/
User Function WSGEN002()
//Chamada pelo menu.
                      
Processa({|| WSGENProc()},"Processamento","Aguarde...")

Return

/*/{Protheus.doc} WSGENA02
Chamada por schedule
@type function
@author luizf
@since 12/10/2016
/*/
User Function WSGENA02()
	OpenSM0()
	RPCSETENV('02', '01',)
	WSGENProc()//Monitora
	TransNFse()//Depois transmite.     
	Sleep(5000)
	WSGENProc()
Return

/*/{Protheus.doc} WSGENT02
Chamada de Job para envio da NFS-e
@author luizf
@since 12/10/2016
/*/
User Function WSGENT02()
	OpenSM0()
	RPCSETENV('02', '01',)
	TransNFse()

Return


/*/{Protheus.doc} TransNFse
Chama envio da NFS-e
@type function
@author luizf
@since 12/10/2016
/*/
Static Function TransNFse()
Local cCodMun		:=Alltrim(SM0->M0_CODMUN)
LOCAL cQuery := ""
Local _cXML	 := ""
LOCAL cSerie := GetNewPar("TCP_SERNFW","J")
LOCAL cNFDe  := GetNewPar("TCP_NVINI","60162020")
LOCAL cNFAte := GetNewPar("TCP_NVFIM","99999999")
LOCAL cNotasOk 
//Variaveis privadas e usadas na rotina de transmissao
Private cIdEnt		:=GetIdEnt() 
Private cEntSai		:="1"
Private cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)	
cQuery := "SELECT * FROM "+RetSQLName("SF3")
cQuery += " WHERE "
cQuery += " F3_FILIAL = '"+xFilial("SF3")+"' "
cQuery += " AND F3_SERIE = '"+cSerie+"' "
cQuery += " AND F3_NFISCAL >= '"+cNFDe+"' " 
cQuery += " AND F3_NFISCAL <= '"+cNFAte+"'  "
cQuery += " AND F3_NFELETR = '' "
cQuery += " AND D_E_L_E_T_ != '*' "
If Select("TRBF3") <> 0
  DBSelectArea("TRBF3")
  DBCloseArea()
EndIf
TCQuery cQuery New Alias "TRBF3" 
Do While !TRBF3->(Eof())

	Fisa022Trs(cCodMun,TRBF3->F3_SERIE,TRBF3->F3_NFISCAL,TRBF3->F3_NFISCAL,,,@cNotasOk,,,,,,.T.,5)
	U_WGENFAT1(ALLTRIM(TRBF3->F3_NFISCAL),AllTrim(TRBF3->F3_NFELETR),AllTrim(TRBF3->F3_CODNFE),AllTrim(TRBF3->(F3_CODRET+F3_DESCRET)),"2","WSGEN002.JOB")//cStatus := "2" transmitido
	TRBF3->(DBSkip())
EndDo

If Select("TRBF3") <> 0
  DBSelectArea("TRBF3")
  DBCloseArea()
EndIf

Return


/*/{Protheus.doc} WSGENProc
Função para busca de dados.
@type function
@author luizf
@since 12/10/2016
@see (links_or_references)
/*/
Static Function WSGENProc()

LOCAL cQuery := ""
LOCAL cSerie := GetNewPar("TCP_SERNFW","J")
LOCAL cNFDe  := GetNewPar("TCP_NVINI","60162020")
LOCAL cNFAte := GetNewPar("TCP_NVFIM","99999999")

cQuery := "SELECT * FROM "+RetSQLName("SF3")
cQuery += " WHERE "
cQuery += " F3_FILIAL = '"+xFilial("SF3")+"' "
cQuery += " AND F3_SERIE = '"+cSerie+"' "
cQuery += " AND F3_NFISCAL >= '"+cNFDe+"' " 
cQuery += " AND F3_NFISCAL <= '"+cNFAte+"' "
//cQuery += " AND F3_ENTRADA >= '"+DToS(dDataBase)+"' " 
//cQuery += " AND F3_NFELETR = '' "
cQuery += " AND (( F3_CODRSEF<> ' '  AND F3_CODRET='T' AND F3_NFELETR=' ') OR (F3_NFELETR != ' ' AND F3_YINTGR != '3' AND F3_YINTGR != '5' ) )" 
//cQuery += " AND ((F3_CODRSEF<> ' '  AND F3_CODRET='T')" 
//cQuery += " OR(F3_CODRSEF ='C' AND F3_CODRET='111') )"
cQuery += " AND D_E_L_E_T_ != '*' "
If Select("TRBF3") <> 0
  DBSelectArea("TRBF3")
  DBCloseArea()
EndIf
TCQuery cQuery New Alias "TRBF3" 
Do While !TRBF3->(Eof())
	Monitora(TRBF3->F3_NFISCAL,TRBF3->F3_SERIE)
	TRBF3->(DBSkip())
EndDo

If Select("TRBF3") <> 0
  DBSelectArea("TRBF3")
  DBCloseArea()
EndIf

Return


Static Function Monitora(cNumDoc,cNumSerie)

LOCAL cIdEnt		:=  GetIdEnt()
LOCAL cURL     		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local nY
Local nX
LOCAL cHoraDe  		:= "00:00:00"
LOCAL cHoraAte 		:= "00:00:00"
Local nAmbiente		:= 2
Local cCallName		:= "PROTHEUS"	// Origem da Chamado do WebService
LOCAL aMsg      	:= {}
LOCAL nTipoMonitor 	:= 1
local nTempo 		:= 0
Local _cXML			:= ""
Local cINFOXML		:= ""
Local cNumNFSE		:= ""
Local cSerieNFSe	:= ""
Local cDtNFSe		:= ""
Local cHoraNFSe		:= ""

	oWS := WsNFSE001():New()
	oWS:cUSERTOKEN   		:= "TOTVS"
	oWS:cID_ENT      		:= cIdEnt
	oWS:_URL         		:= AllTrim(cURL)+"/NFSE001.apw"
	//oWS:cCODMUN    			:= cCodMun
	oWS:dDataDe       		:= dDataBase
	oWS:dDataAte     		:= dDataBase
	oWS:cHoraDe       		:= cHoraDe
	oWS:cHoraAte 			:= cHoraAte
	oWS:nTipoMonitor		:= nTipoMonitor
	oWS:nTempo   			:= nTempo
	oWS:nDiasParaExclusao	:= 0
	oWS:cCallName			:= cCallName

	oWS:cIdInicial := cNumSerie+cNumDoc//SERIE+DOC
	oWS:cIdFinal   := cNumSerie+cNumDoc//SERIE+DOC

	lOk := ExecWSRet(oWS,"MonitorX")
	If (lOk)

		oRetorno := oWS:OWSMONITORXRESULT

		//SF3->(dbSetOrder(5))
		bBlock1 := {|| Type("oXml:cURLNFSE") <> "U" }
		bBlock2	:= {|| Type("oXml:OWSERRO:OWSERROSLOTE") <> "U" }

		For nX := 1 To Len(oRetorno:OWSMONITORNFSE)

			aMsg 			:= {}
			oXml 			:= oRetorno:OWSMONITORNFSE[nX]
			//Willian Kaneta - Adicionado para envio por parametro na função WGENFAT1
			_cXML 			:= oXml:OWSNFE:CXML
			cINFOXML		:= oXml:OWSNFE:CXMLPROT
			
			aDadosNFSe		:=  RETDADOSNSFE(cINFOXML)
			If Len(aDadosNFSe) != 0
				cNumNFSE	:= aDadosNFSe[1][1]	
				cSerieNFSe	:= aDadosNFSe[1][2]
				cDtNFSe		:= aDadosNFSe[1][3]
				cHoraNFSe	:= aDadosNFSe[1][4]
			EndIf
			cNumero			:= PADR(Substr(oXml:cID,4,Len(oXml:cID)),TamSX3("F2_DOC")[1])

			cProtocolo		:= oXml:cPROTOCOLO
			dEmiNfe			:= CTOD( "" )
			cHorNFe			:= ""
			cSerie			:= Substr(oXml:cID,1,3)
			cRecomendacao	:= oXml:cRECOMENDACAO
			cNota			:= oXml:cNota
			cRPS			:= oXml:cRPS
			cCnpjForn		:= padR(Substr(oXml:cid,13,Len(oXml:cid)),14)
			nAmbiente		:= oXml:nAmbiente
			
			If Eval(bBlock1)
				cURLNfse := oXml:cURLNFSE
			EndIf

			//-- Atualiza os dados com as mensagens de transmissao
			
			If Eval(bBlock2)
				For nY := 1 To Len(oXml:OWSERRO:OWSERROSLOTE)
					If (oXml:OWSERRO:OWSERROSLOTE[nY]:CCODIGO <> "")
						aadd(aMsg,{oXml:OWSERRO:OWSERROSLOTE[nY]:CCODIGO,oXml:OWSERRO:OWSERROSLOTE[nY]:CMENSAGEM})
					EndIf
				Next nY
			EndIf

			If ( Empty( aMsg ) )
				aAdd( aMsg, { "", "" } )
			EndIf

			If FindFunction( "autoNfseMsg" )
				autoNfseMsg( "[Monitoramento] Nota Monitorada: " + cSerie + cNumero, .F. )
			EndIf


			AtuNota(cNumero,cNota,cSerie,cProtocolo,aMsg,cHorNFe,dEmiNfe,_cXML,cNumNFSE,cSerieNFSe,cDtNFSe,cHoraNFSe)

			//-- Atualizacao dos documentos
			//Fis022Upd(cProtocolo, cNumero, cSerie, cRecomendacao, cNota, cCnpjForn, dEmiNfe, cHorNFe, cCodMun, lRegFin, aMsg, lUsaColab)

		Next nX

	EndIf
Return


Static Function AtuNota(cNumero,cNota,cSerie,cProtocolo,aMsg,cHorNFe,dEmiNfe,_cXML,cNumNFSE,cSerieNFSe,cDtNFSe,cHoraNFSe)


Local lF3CODRSEF	:= SF3->(FieldPos("F3_CODRSEF")) > 0
Local lF3CODRET		:= SF3->(FieldPos("F3_CODRET" )) > 0 .And. SF3->(FieldPos("F3_DESCRET")) > 0
Local nTamDoc		:= TamSx3("F2_NFELETR")[1]
LOCAL cStatus       := "1"
LOCAL lGrv          := .F.

	If ( Empty( cProtocolo ) .and. Empty(cNota) )//Inserida verificação da Nota, pois a prefeitura de SP autoriza e não retorna protocolo (quando há alterta)
		If ( "Schema Invalido" $ cRecomendacao ) 
			aMsg := {}
			aAdd(aMsg,{"999",cRecomendacao})
		EndIf
		If Len(aMsg) > 0 .And. !Empty(aMsg[1][1])
			
				//-- NFS-e Nao Autorizada
				SF2->(dbSetOrder(1))
				If (SF2->(MsSeek(xFilial("SF2")+cNumero+cSerie,.T.)))
					SF2->(RecLock("SF2"))
					IF ( "002 -" $  cRecomendacao )
					SF2->F2_FIMP := "T" //NF Transmitida ,'BR_AZUL'
					ELSE
					SF2->F2_FIMP := "N" //NF nao autorizada, 'BR_PRETO'
					ENDIF
					SF2->(MsUnlock())
					SF3->(dbSetOrder(5))
					If (SF3->(MsSeek(xFilial("SF3")+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA)))
						If	lF3CODRSEF
							SF3->(RecLock("SF3"))
							IF ( "002 -" $  cRecomendacao )
							SF3->F3_CODRSEF := "T" //NF Transmitida ,'BR_AZUL'
							ELSE
							SF3->F3_CODRSEF := "N" //NF nao autorizada, 'BR_PRETO'
							ENDIF
							If	lF3CODRET .And. Empty(SF3->F3_CODRET)
								SF3->F3_CODRET	:= aMsg[1][1]
								SF3->F3_DESCRET	:= aMsg[1][2]
							EndIf
							SF3->(MsUnlock())
						EndIf
					EndIf
				EndIf
			
		EndIf
	Else
		If ( "Emissao de Nota Autorizada" $ cRecomendacao ) .Or. ( "Emissão de nota autorizada" $ cRecomendacao )
			aMsg := {}
			aAdd(aMsg,{"111",cRecomendacao})
		ElseIf ( 'Nota Fiscal Substituida' $ cRecomendacao )
			aMsg := {}
			aAdd(aMsg,{"222",cRecomendacao})
		ElseIf ( 'Cancelamento do RPS Autorizado' $ cRecomendacao ).OR.( 'Cancelamento da NFS-e autorizado' $ cRecomendacao )  
			aMsg := {}
			aAdd(aMsg,{"333",cRecomendacao})
		EndIf
		If (.T.)//( cEntSai == "1"	)
			//-- NFS-e Autorizada
			SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If SF2->(MsSeek(xFilial("SF2")+cNumero+cSerie,.T.))
				SF2->( RecLock("SF2") )
				SF2->F2_FIMP := "S" //NF Autorizada
				If (!Empty(cNota))
					SF2->F2_NFELETR	:= RIGHT(cNota,nTamDoc)
					SF2->F2_EMINFE	:= dEmiNfe
					SF2->F2_HORNFE	:= cHorNFe
					SF2->F2_CODNFE	:= RTrim(cProtocolo)
				EndIf
				SF2->(MsUnlock())
				//-- Livros Fiscais
				SF3->(dbSetOrder(5))
				If (SF3->(MsSeek(xFilial("SF3")+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA)))
					If	lF3CODRSEF
						SF3->(RecLock("SF3"))
						SF3->F3_CODRSEF := "S"
						If	lF3CODRET
							If Len( aMsg ) > 0 .And. !Empty( aMsg[1][1] )
								SF3->F3_CODRET	:= aMsg[1][1]
								SF3->F3_DESCRET	:= aMsg[1][2]
							Endif
						EndIf
						If (!Empty(cNota))
							SF3->F3_NFELETR	:= RIGHT(cNota,nTamDoc)
							SF3->F3_EMINFE	:= dEmiNfe
							SF3->F3_HORNFE	:= cHorNFe
							SF3->F3_CODNFE	:= RTrim(cProtocolo)
						EndIf
						SF3->(MsUnlock())
					EndIf
				EndIf
				//-- Financeiro - Contas a Receber
				SE1->(dbSetOrder(2))
				If (SE1->(MsSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DOC)))
					If (Alltrim(SF3->F3_CODRSEF) == "S")
						If (!empty(cNota))
							While SE1->(!EOF()) .And. xFilial("SE1") == SF2->F2_FILIAL .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And. SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_SERIE .And. SE1->E1_NUM == SF2->F2_DOC .Or.  ( SE1->(!EOF()) .And. SE1->E1_FILORIG == SF2->F2_FILIAL .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And. SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_SERIE .And. SE1->E1_NUM == SF2->F2_DOC)
								SE1->(RecLock("SE1"))
								SE1->E1_NFELETR := iif( lRetNumRps, cNota ,RIGHT(cNota,nTamDoc) )
								SE1->(MsUnlock())
								SE1->(dbSkip())
							EndDo
						EndIf
					EndIf
				ElseIf (SE1->(MsSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DOC)))
					//-- 						
					If (Alltrim(SF3->F3_CODRSEF) == "S")
						If (!empty(cNota) )
							While SE1->(!EOF()) .And. xFilial("SE1") == SF2->F2_FILIAL .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And. SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_PREFIXO .And. SE1->E1_NUM == SF2->F2_DOC .Or. ( SE1->(!EOF()) .And. SE1->E1_FILORIG == SF2->F2_FILIAL .And. SE1->E1_CLIENTE == SF2->F2_CLIENTE .And. SE1->E1_LOJA == SF2->F2_LOJA .And. SE1->E1_PREFIXO == SF2->F2_PREFIXO .And. SE1->E1_NUM == SF2->F2_DOC)
								SE1->(RecLock("SE1"))
								SE1->E1_NFELETR :=  iif( lRetNumRps, cNota ,RIGHT(cNota,nTamDoc) )
								SE1->(MsUnlock())
								SE1->(dbSkip())
							EndDo
						EndIf
					EndIf
				EndIf
				//-- Livros Fiscais - Resumo
				SFT->(dbSetOrder(1))
				If (SFT->(MsSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA)))
					If (Alltrim(SF3->F3_CODRSEF) == "S" )
						If (!Empty(cNota))
							While SFT->(!EOF()) .And. xFilial("SFT") == SF2->F2_FILIAL .And. SFT->FT_TIPOMOV == "S" .And. SFT->FT_SERIE == SF2->F2_SERIE .And. SFT->FT_NFISCAL == SF2->F2_DOC .And. SFT->FT_CLIEFOR == SF2->F2_CLIENTE .And. SFT->FT_LOJA == SF2->F2_LOJA
								SFT->(RecLock("SFT") )
								SFT->FT_NFELETR	:= RIGHT(cNota,nTamDoc)
								SFT->FT_EMINFE	:= dEmiNfe
								SFT->FT_HORNFE	:= cHorNFe
								SFT->FT_CODNFE	:= RTrim(cProtocolo)
								SFT->(MsUnlock())
								SFT->(dbSkip())
							EndDo
						EndIf
					EndIf
				EndIf
				//-- NFST-e (SIGATMS)
				If IntTms()
					DT6->(DbSetOrder(1))
					If DT6->(DbSeek(xFilial("DT6")+SF2->F2_FILIAL+ SF2->F2_DOC+SF2->F2_SERIE))
						If (Alltrim(SF3->F3_CODRSEF) == "S")
							If (!Empty(cNota))
								While DT6->(!EOF()) .And. DT6->DT6_SERIE == SF2->F2_SERIE .And. DT6->DT6_DOC == SF2->F2_DOC .And. DT6->DT6_CLIDEV == SF2->F2_CLIENTE .And. DT6->DT6_LOJDEV == SF2->F2_LOJA
									DT6->(RecLock("DT6"))
									DT6->DT6_NFELET := RIGHT(cNota,nTamDoc)
									DT6->DT6_EMINFE := dEmiNfe
									DT6->DT6_CODNFE := RTrim(cProtocolo)
									DT6->(MsUnlock())
									DT6->(dbSkip())
								EndDo
							EndIf
						EndIf
					EndIf
				EndIf
			Else
				//-- Livros Fiscais
				dbSelectArea("SF3")
				SF3->(dbSetOrder(5))
				If SF3->(MsSeek(xFilial("SF3") + cSerie + cNumero))
					If	lF3CODRSEF
						SF3->(RecLock("SF3"))
						SF3->F3_CODRSEF := "S"
						If	lF3CODRET
							If Len(aMsg) > 0 .And. !Empty(aMsg[1][1])
								SF3->F3_CODRET	:= aMsg[1][1]
								SF3->F3_DESCRET	:= aMsg[1][2]
							EndIf
						EndIf
						If !Empty(cNota) .And. Type("oRetxml") <> "U" .And. !Empty(oRetxml) .Or. !Empty(cNota) .And. Type("oRetxmlrps") <> "U" .And. !Empty(oRetxmlrps)
							SF3->F3_NFELETR	:= RIGHT(cNota,nTamDoc)
							SF3->F3_EMINFE	:= dEmiNfe
							SF3->F3_HORNFE	:= cHorNFe
							SF3->F3_CODNFE	:= RTrim(cProtocolo)
						EndIf
						SF3->(MsUnlock())
					EndIf
				EndIf
				//-- WS
//				If !lUsaColab
				//lRetMonit := GetMonitRx(cIdEnt,cUrl)
//				EndIf
			EndIf
		EndIf
		
		//IntegraStatus 
		cStatus	:= "1"
		Do Case
			Case !Empty(SF3->F3_DTCANC) // DATA DO CANCELAMENTO DA NF 5
			cStatus := "5"		
			Case Empty(SF3->F3_CODRSEF) //F3_CODRSEF E F2_FIMP==' ' //NFSe não transmitido 1
			 cStatus := "1"
			Case AllTrim(SF3->F3_CODRSEF) == "T" //F3_CODRSEF E F2_FIMP=='T' //NFSe Transmitido 2
			 cStatus := "2"
			Case AllTrim(SF3->F3_CODRSEF) == "S" //NFSe Autorizado 3
			 cStatus := "3"
			Case AllTrim(SF3->F3_CODRSEF) == "N" .AND. !Empty(Alltrim(SF3->F3_CODNFE))//NFSe Autorizado 3
			 cStatus := "3"
			Case AllTrim(SF3->F3_CODRSEF) == "N" .AND. Empty(Alltrim(SF3->F3_CODNFE))//NFSe nao autorizado 4
			cStatus := "4"				 
		EndCase

		If (lGrv:= U_WGENFAT1(ALLTRIM(SF3->F3_NFISCAL),AllTrim(SF3->F3_NFELETR),AllTrim(SF3->F3_CODNFE),AllTrim(SF3->(F3_CODRET+F3_DESCRET)),cStatus,"WSGEN002.JOB",_cXML,cNumNFSE,cSerieNFSe,cDtNFSe,cHoraNFSe))
			//+---------------------------------------------------------------------+
			//| Quando ocorrer sucesso na integracao, grava o status enviado...     |
			//+---------------------------------------------------------------------+
			If SF3->(FieldPos("F3_YINTGR")) <>0				
				RecLock("SF3",.F.)
				SF3->F3_YINTGR := cStatus
				MSUnLock()
			EndIf	
		EndIf
	EndIf

Return



/*/{Protheus.doc} GetIdEnt
Obtem o codigo da entidade apos enviar o post para o Totvs Service
Referencia FISA022
@type function
@author luizf
@since 12/10/2016
/*/
Static Function GetIdEnt()

Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs
Local lUsaGesEmp := IIF(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)
Local lEnvCodEmp := GetNewPar("MV_ENVCDGE",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem o codigo da entidade                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oWS := WsSPEDAdm():New()
oWS:cUSERTOKEN := "TOTVS"
	
oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
oWS:oWSEMPRESA:cFANTASIA   := IIF(lUsaGesEmp,FWFilialName(),Alltrim(SM0->M0_NOME))
oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
oWS:oWSEMPRESA:cCEP_CP     := Nil
oWS:oWSEMPRESA:cCP         := Nil
oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
oWS:oWSEMPRESA:cEMAIL      := "Mail@mail.com"//UsrRetMail(RetCodUsr())
oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cINDSITESP  := ""
oWS:oWSEMPRESA:cID_MATRIZ  := ""

If lUsaGesEmp .And. lEnvCodEmp
	oWS:oWSEMPRESA:CIDEMPRESA:= FwGrpCompany()+FwCodFil()
EndIf
oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
If ExecWSRet(oWs,"ADMEMPRESAS")
	cIdEnt  := oWs:cADMEMPRESASRESULT
Else
	Aviso("NFS-e",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"erro"},3)
EndIf

RestArea(aArea)
Return(cIdEnt)

/*/{Protheus.doc} RETDADOSNSFE
	Retorna dados XML NFse
	@type  Static Function
	@author Willian Kaneta
	@since 07/07/2020
	@version 1.0
	@return aRet = Dados NFSe 
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function RETDADOSNSFE(cINFOXML)
	Local aRet 		:= {}
	Local cTagIni 	:= 0 
	Local cTagFim 	:= 0 
	Local cNumNFSE	:= ""
	Local cSerieNFSe:= ""
	Local cDtNFSe	:= ""
	Local cHoraNFSe	:= ""

	cTagIni 	:= '<numero_nfse>'
	cTagFim 	:= "</numero_nfse>"
	cINFOXML 	:= SubStr(cINFOXML, At(cTagIni,cINFOXML)+13, Len(cINFOXML))
	cNumNFSE 	:= SubStr(cINFOXML, 1, At(cTagFim,cINFOXML)-1)

	cTagIni 	:= '<serie_nfse>'	
	cTagFim 	:= "</serie_nfse>"
	cINFOXML 	:= SubStr(cINFOXML, At(cTagIni,cINFOXML)+12, Len(cINFOXML))
	cSerieNFSe 	:= SubStr(cINFOXML, 1, At(cTagFim,cINFOXML)-1)

	cTagIni 	:= '<data_nfse>'
	cTagFim 	:= "</data_nfse>"
	cINFOXML 	:= SubStr(cINFOXML, At(cTagIni,cINFOXML)+11, Len(cINFOXML))
	cDtNFSe 	:= SubStr(cINFOXML, 1, At(cTagFim,cINFOXML)-1)

	cTagIni 	:= '<hora_nfse>'
	cTagFim 	:= "</hora_nfse>"
	cINFOXML 	:= SubStr(cINFOXML, At(cTagIni,cINFOXML)+11, Len(cINFOXML))
	cHoraNFSe 	:= SubStr(cINFOXML, 1, At(cTagFim,cINFOXML)-1)

	If !Empty(cNumNFSE) .AND. !Empty(cSerieNFSe) .AND. !Empty(cDtNFSe) .AND. !Empty(cHoraNFSe)
		aadd(aRet,{cNumNFSE,cSerieNFSe,cDtNFSe,cHoraNFSe})
	EndIf

Return aRet
