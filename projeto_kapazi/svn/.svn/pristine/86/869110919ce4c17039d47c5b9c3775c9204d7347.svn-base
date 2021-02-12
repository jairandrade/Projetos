#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'
#DEFINE TAMMAXXML  If((GetNewPar("MV_XMLSIZE",400000) < 400000), 400000, iif((GetNewPar("MV_XMLSIZE",400000) > 800000),800000,GetNewPar("MV_XMLSIZE",400000)))
#DEFINE VBOX       080
#DEFINE HMARGEM    030

user function KPZMONFE(cSerie,cNotaIni,cNotaFim, lCTe, lMDFe, cModel,lTMS, lAutoColab,lExibTela,lUsaColab)
	//Function SpedNFe6Mnt(cSerie,cNotaIni,cNotaFim, lCTe, lMDFe, cModel,lTMS, lAutoColab,lExibTela,lUsaColab)
	//SpedNFe6Mnt(,,,lCTE,,cModel)
	Local cIdEnt   := ""
	local cUrl			:= Padr( GetNewPar("MV_SPEDURL",""), 250 )
	Local aPerg    := {}
	Local aParam   := {Space(Len(SerieNfId("SF2",2,"F2_SERIE"))),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),CtoD(""),CtoD("")}
	Local aSize    := {}
	Local aObjects := {}
	Local aListBox := {}
	Local aInfo    := {}
	Local aPosObj  := {}
	Local oWS
	Local oDlg
	Local oListBox
	Local oBtn1
	Local oBtn2
	Local oBtn3
	Local oBtn4
	Local cParNfeRem := SM0->M0_CODIGO+SM0->M0_CODFIL+"SPEDNFEREM"
	Local lOK        := .F.
	Local dDataDe		:= CtoD("")
	Local dDataAte	:= CtoD("")
	Local lSdoc     := TamSx3("F2_SERIE")[1] == 14

	Default cSerie   := ''
	Default cNotaIni := ''
	Default cNotaFim := ''
	Default lCTe     := .F.
	Default lMDFe    := .F.
	Default cModel	 := ""
	default lTMS     := .F.
	Default lAutoColab := .F.
	Default lExibTela		:= .F. // Não exibe se Falso
	Default lUsaColab	:= .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento da NFCe para o Loja                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cModel == "65"
		If !Empty( GetNewPar("MV_NFCEURL","") )
			cURL := PadR(GetNewPar("MV_NFCEURL","http://"),250)
		Endif
	EndIf

	lUsaColab := UsaColaboracao( IIF(lCte,"2",IIF(lMDFe,"5","1")) )
	if lUsacolab .And. Empty(cModel)
		cModel := Iif(lCte,"57",iif(lMDFe,"58","55"))
	endif

	If !lAutoColab
		aadd(aPerg,{1,Iif(lMDFe,"Serie da Nota Fiscal","Serie da Nota Fiscal"),aParam[01],"",".T.","",".T.",30,.F.}) //"Serie da Nota Fiscal"
		aadd(aPerg,{1,Iif(lMDFe,"Nota fiscal inicial","Nota fiscal inicial"),aParam[02],"",".T.","",".T.",30,.T.}) //"Nota fiscal inicial"
		aadd(aPerg,{1,Iif(lMDFe,"Nota fiscal final","Nota fiscal final"),aParam[03],"",".T.","",".T.",30,.T.}) //"Nota fiscal final"

		aParam[01] := ParamLoad(cParNfeRem,aPerg,1,aParam[01])
		aParam[02] := ParamLoad(cParNfeRem,aPerg,2,aParam[02])
		aParam[03] := ParamLoad(cParNfeRem,aPerg,3,aParam[03])
	EndIF

	If lSdoc
		aadd(aPerg,{1,"Dt. Emissão De"	,aParam[04],"@R 99/99/9999",".T.","",".T.",50,.F.}) 			//"Data de Emissão"
		aadd(aPerg,{1,"Dt. Emissão Até"	,aParam[05],"@R 99/99/9999",".T.","",".T.",50,.F.}) 			//"Data de Emissão"

		dDataDe := aParam[04] := ParamLoad(cParNfeRem,aPerg,4,aParam[04])
		dDataAte := aParam[05] := ParamLoad(cParNfeRem,aPerg,5,aParam[05])
	EndIf

	If IsReady( ,,,lUsaColab ) 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem o codigo da entidade                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		cIdEnt := GetIdEnt( lUsaColab )
		If !Empty(cIdEnt)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Instancia a classe                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cIdEnt)
				If lAutoColab
					aParam[01] := cSerie
					aParam[02] := cNotaIni
					aParam[03] := cNotaFim
					lOK        := .T.
				Else
					If (lCTe) .And. !Empty(cSerie) .And. !Empty(cNotaIni) .And. !Empty(cNotaFim)
						aParam[01] := cSerie
						aParam[02] := cNotaIni
						aParam[03] := cNotaFim
						lOK        := .T.
					ElseIf (lMDFe) .And. !Empty(cSerie) .And. !Empty(cNotaIni) .And. !Empty(cNotaFim)
						aParam[01] := cSerie
						aParam[02] := cNotaIni
						aParam[03] := cNotaFim
						lOK        := .T.			
					Else 
						IF (lExibTela)
							aParam[01] := cSerie
							aParam[02] := cNotaIni
							aParam[03] := cNotaFim
							lOK        := .T.
						Else
							lOK        := ParamBox(aPerg,"SPED - NFe",@aParam,,,,,,,cParNfeRem,.T.,.T.)
							cSerie   := aParam[01] 
							cNotaIni := aParam[02] 
							cNotaFim := aParam[03] 				
						EndIF
					EndIf

					If lSdoc 
						dDataDe  := aParam[04]
						dDataAte := aParam[05]
						GetFiltroF3(@aParam,,dDataDe,dDataAte)                                      			
					EndIF			
				EndIF
				If (lOK)
					If lMDFe .And. !lUsaColab
						aListBox := WsMDFeMnt(cIdEnt,cSerie,cNotaIni,cNotaFim,.T.)
					Else                                          
						aListBox := getListBox(cIdEnt, cUrl, aParam, 1, cModel, lCte, .T., lMDFe, lTMS,lUsaColab)
					EndIf	
					If !Empty(aListBox) .And. !lAutoColab
						aSize := MsAdvSize()
						aObjects := {}
						AAdd( aObjects, { 100, 100, .t., .t. } )
						AAdd( aObjects, { 100, 015, .t., .f. } )

						aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
						aPosObj := MsObjSize( aInfo, aObjects )

						DEFINE MSDIALOG oDlg TITLE "SPED - NFe" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL

						@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER "","NF","Ambiente","Modalidade","Protocolo","Recomendação","Tempo decorrido","Tempo SEF"; //"NF"###"Ambiente"###"Modalidade"###"Protocolo"###"Recomendação"###"Tempo decorrido"###"Tempo SEF"
						SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
						oListBox:SetArray( aListBox )
						oListBox:bLine := { || { aListBox[ oListBox:nAT,1 ],aListBox[ oListBox:nAT,2 ],aListBox[ oListBox:nAT,3 ],aListBox[ oListBox:nAT,4 ],aListBox[ oListBox:nAT,5 ],aListBox[ oListBox:nAT,6 ],aListBox[ oListBox:nAT,7 ],aListBox[ oListBox:nAT,8 ]} }


						@ aPosObj[2,1],aPosObj[2,4]-040 BUTTON oBtn1 PROMPT "OK"   		ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //"OK"
						@ aPosObj[2,1],aPosObj[2,4]-080 BUTTON oBtn2 PROMPT "Mensagens"   		ACTION (Bt2NFeMnt(aListBox[oListBox:nAT][09])) OF oDlg PIXEL SIZE 035,011 //"Mensagens"
						@ aPosObj[2,1],aPosObj[2,4]-120 BUTTON oBtn3 PROMPT "Rec.XML"   		ACTION (SPEDNFEXML(cIdEnt,aListBox[ oListBox:nAT,2 ],,lUsaColab,cModel)) OF oDlg PIXEL SIZE 035,011 //"Rec.XML"
						If lMDFe .And. !lUsaColab
							@ aPosObj[2,1],aPosObj[2,4]-160 BUTTON oBtn4 PROMPT "Refresh" 	ACTION (aListBox := WsMDFeMnt(cIdEnt,cSerie,cNotaIni,cNotaFim,.T.),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 //"Refresh"
						Else
							@ aPosObj[2,1],aPosObj[2,4]-160 BUTTON oBtn4 PROMPT "Refresh" 	ACTION (aListBox := getListBox(cIdEnt, cUrl, aParam, 1, cModel, lCte, .T., lMDfe, lTMS,lUsaColab),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 //"Refresh"
						EndIf	
						@ aPosObj[2,1],aPosObj[2,4]-200 BUTTON oBtn4 PROMPT "Schema"  		ACTION (SPEDNFEXML(cIdEnt,aListBox[ oListBox:nAT,2 ],2,lUsaColab,cModel)) OF oDlg PIXEL SIZE 035,011 //"Schema"
						ACTIVATE MSDIALOG oDlg
					EndIf
				EndIf
			EndIf
		Else
			Aviso("SPED","Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!",{"Ok"},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
		EndIf
	Else
		Aviso("SPED","Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!",{"Ok"},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	EndIf

Return




static function getListBox(cIdEnt, cUrl, aParam, nTpMonitor, cModelo, lCte, lMsg, lMDfe, lTMS,lUsaColab)

	local aLote			:= {}
	local aListBox			:= {}
	local aRetorno			:= {}
	local cId				:= ""
	local cProtocolo		:= ""	
	local cRetCodNfe		:= ""
	local cAviso			:= ""
	local cSerie			:= ""
	local cNota			:= ""

	local nAmbiente		:= ""
	local nModalidade		:= ""
	local cRecomendacao	:= ""
	local cTempoDeEspera	:= ""
	local nTempomedioSef	:= ""
	local nX				:= 0


	local oOk				:= LoadBitMap(GetResources(), "ENABLE")
	local oNo				:= LoadBitMap(GetResources(), "DISABLE")

	default lUsaColab		:= .F.		
	default lMsg			:= .T.
	default lCte			:= .F.	
	default lMDfe		:= .F.
	default cModelo		:= IIf(lCte,"57",IIf(lMDfe,"58","55"))
	default lTMS			:= .F.

	if cModelo <> "65"
		lUsaColab := UsaColaboracao( IIf(lCte,"2",IIf(lMDFe,"5","1")) )
	endif

	if 	lUsaColab
		//processa monitoramento por tempo
		aRetorno := colNfeMonProc( aParam, nTpMonitor, cModelo, lCte, @cAviso, lMDfe, lTMS ,lUsaColab )
	else
		//processa monitoramento
		aRetorno := procMonitorDoc(cIdEnt, cUrl, aParam, nTpMonitor, cModelo, lCte, @cAviso)
	endif	

	if empty(cAviso)

		for nX := 1 to len(aRetorno)

			cId				:= aRetorno[nX][1]
			cSerie			:= aRetorno[nX][2]
			cNota			:= aRetorno[nX][3]
			cProtocolo		:= aRetorno[nX][4]	
			cRetCodNfe		:= aRetorno[nX][5]
			nAmbiente		:= aRetorno[nX][7]
			nModalidade	:= aRetorno[nX][8]
			cRecomendacao	:= aRetorno[nX][9]
			cTempoDeEspera:= aRetorno[nX][10]
			nTempomedioSef:= aRetorno[nX][11]
			aLote			:= aRetorno[nX][12]

			If type("_lFiltraNF") <> "U" .and. _lFiltraNF
				// valida se o campo existe
				IF SF2->( FieldPos("F2_K_USRCO") ) > 0			

					cQry := "select * from "+RetSQLName("SF2")+ " where F2_FILIAL = '"+xFilial("SF2")+"' and D_E_L_E_T_ <> '*' and F2_SERIE+F2_DOC = '"+cId+"'  "
					TcQuery cQry new Alias "QSF2"

					If QSF2->(!EOF())
						If QSF2->F2_K_USRCO <> RetCodUsr()
							QSF2->(DbCloseArea())
							Loop
						EndIf
					EndIf
					QSF2->(DbCloseArea())

				EndIf
			EndIf
			aadd(aListBox,{	iif(empty(cProtocolo) .Or.  cRetCodNfe $ RetCodDene(),oNo,oOk),;
			cId,;
			if(nAmbiente == 1,"Produção","Homologação"),; //"Produção"###"Homologação"
			IIF(lUsaColab,iif(nModalidade==1,"Produção","Homologação"),IIf(nModalidade ==1 .Or. nModalidade == 4 .Or. nModalidade == 6,"Normal","Contingência")),; //"Normal"###"Contingência"								
			cProtocolo,;
			cRecomendacao,;
			cTempoDeEspera,;
			nTempoMedioSef,;
			aLote;
			})
		next	

		if Empty(aListBox) .and. lMsg .and. !lCte
			Aviso("SPED","Não há dados",{"Ok"})
		endIf

	elseif !lCTe .And. lMsg
		aviso("SPED", cAviso,{"Ok"},3)	
	endif

return aListBox

Static Function IsReady(cURL,nTipo,lHelp,lUsaColab)

	Local nX       := 0
	Local cHelp    := ""
	local cError	:= ""
	Local oWS
	Local lRetorno := .F.
	DEFAULT nTipo := 1
	DEFAULT lHelp := .F.
	DEFAULT lUsaColab := .F.
	if !lUsaColab
		If FunName() <> "LOJA701"
			If !Empty(cURL) .And. !PutMV("MV_SPEDURL",cURL)
				RecLock("SX6",.T.)
				SX6->X6_FIL     := xFilial( "SX6" )
				SX6->X6_VAR     := "MV_SPEDURL"
				SX6->X6_TIPO    := "C"
				SX6->X6_DESCRIC := "URL SPED NFe"
				MsUnLock()
				PutMV("MV_SPEDURL",cURL)
			EndIf
			SuperGetMv() //Limpa o cache de parametros - nao retirar
			DEFAULT cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
		Else
			If !Empty(cURL) .And. !PutMV("MV_NFCEURL",cURL)
				RecLock("SX6",.T.)
				SX6->X6_FIL     := xFilial( "SX6" )
				SX6->X6_VAR     := "MV_NFCEURL"
				SX6->X6_TIPO    := "C"
				SX6->X6_DESCRIC := "URL de comunicação com TSS"
				MsUnLock()
				PutMV("MV_NFCEURL",cURL)
			EndIf
			SuperGetMv() //Limpa o cache de parametros - nao retirar
			DEFAULT cURL      := PadR(GetNewPar("MV_NFCEURL","http://"),250)	
		EndIf	
		//Verifica se o servidor da Totvs esta no ar	
		if(isConnTSS(@cError))	
			lRetorno := .T.
		Else
			If lHelp
				Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
			EndIf
			lRetorno := .F.
		EndIf


		//Verifica se Há Certificado configurado	
		If nTipo <> 1 .And. lRetorno		

			if( isCfgReady(, @cError) )
				lRetorno := .T.
			else	
				If nTipo == 3
					cHelp := cError

					If lHelp .And. !"003" $ cHelp
						Aviso("SPED",cHelp,{"Ok"},3)
						lRetorno := .F.

					EndIf		

				Else
					lRetorno := .F.

				EndIf
			endif

		EndIf

		//Verifica Validade do Certificado	
		If nTipo == 2 .And. lRetorno
			isValidCert(, @cError)
		EndIf
	else
		lRetorno := ColCheckUpd()
		if lHelp .And. !lRetorno .And. !lAuto
			MsgInfo("UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0")		
		endif	
	endif

Return(lRetorno)


Static Function GetIdEnt(lUsaColab)

	local cIdEnt := ""
	local cError := ""

	Default lUsaColab := .F.

	If !lUsaColab

		cIdEnt := getCfgEntidade(@cError)

		if(empty(cIdEnt))
			Aviso("SPED", cError, {"Ok"}, 3)

		endif	

	else
		if !( ColCheckUpd() )
			Aviso("SPED","UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0",{"Ok"},3)
		else
			cIdEnt := "000000"
		endif	 
	endIf	

Return(cIdEnt)



Static Function Bt2NFeMnt(aMsg)

	Local aSize    := MsAdvSize()
	Local aObjects := {}
	Local aInfo    := {}
	Local aPosObj  := {}
	Local oDlg
	Local oListBox
	Local oBtn1

	If !Empty(aMsg)
		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 015, .t., .f. } )
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )

		DEFINE MSDIALOG oDlg TITLE "SPED - NFe" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
		@ aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox Fields HEADER "Lote","Dt.Lote","Hr.Lote","Recibo SEF","Cod.Env.Lote","Msg.Env.Lote","Cod.Ret.Lote","Msg.Ret.Lote","Cod.Ret.NFe","Msg.Ret.NFe"; //"Lote"###"Dt.Lote"###"Hr.Lote"###"Recibo SEF"###"Cod.Env.Lote"###"Msg.Env.Lote"###"Cod.Ret.Lote"###"Msg.Ret.Lote"###"Cod.Ret.NFe"###"Msg.Ret.NFe"
		SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL
		oListBox:SetArray( aMsg )
		oListBox:bLine := { || { aMsg[ oListBox:nAT,1 ],aMsg[ oListBox:nAT,2 ],aMsg[ oListBox:nAT,3 ],aMsg[ oListBox:nAT,4 ],aMsg[ oListBox:nAT,5 ],aMsg[ oListBox:nAT,6 ],aMsg[ oListBox:nAT,7 ],aMsg[ oListBox:nAT,8 ],aMsg[ oListBox:nAT,9 ],aMsg[ oListBox:nAT,10 ]} }
		@ aPosObj[2,1],aPosObj[2,4]-030 BUTTON oBtn1 PROMPT "Ok"         ACTION oDlg:End() OF oDlg PIXEL SIZE 028,011
		ACTIVATE MSDIALOG oDlg
	EndIf
Return(.T.)
