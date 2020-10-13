#INCLUDE "FINA473.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FILEIO.CH'

Static __cProcPrinc := "FINA473"
Static __cPerg		:= "FINA473"
Static lFWCodFil := .T.

User Function FImpEx(aConfig1, aConfig2, nOpc,aLog,aLogLanc)

Local lRet			:= .T.
Local cPosNum		:= ""
Local cPosData		:= ""
Local cPosValor		:= ""
Local cPosOcor		:= ""
Local cPosDescr		:= ""
Local cPosDif		:= "" 
Local lPosNum		:= .F.
Local lPosData		:= .F.
Local lPosValor		:= .F.
Local lPosOcor		:= .F.
Local lPosDescr		:= .F.
Local lPosDif		:= .F.
Local lPosBco		:= .F.
Local lPosAge		:= .F.
Local lPosCta		:= .f.
Local nLidos		:= 0
Local nLenNum		:= 0
Local nLenData		:= 0
Local nLenValor		:= 0
Local nLenDescr		:= 0
Local nLenOcor		:= 0
Local nLenDif		:= 0
Local nLenBco		:= 0
Local nLenAge		:= 0
Local nLenCta		:= 0
Local cArqConf		:= ""
Local cArqEnt		:= ""
Local xBuffer
Local cDebCred		:= ""
Local nHdlBco		:= 0
Local cBanco 		:= 	Space(TamSX3("E5_BANCO")[1])
Local cAgencia 		:= 	Space(TamSX3("E5_AGENCIA")[1]) 
Local cConta 		:= 	Space(TamSX3("E5_CONTA")[1])
Local cDifer		:= ""
Local lPosVSI		:= .F.
Local lPosDSI 		:= .F.
Local lPosDCI 		:= .F.
Local nLenVSI		:= 0
Local nLenDSI		:= 0
Local nLenDCI		:= 0
Local cPosVSI		:= ""
Local cPosDSI		:= ""
Local cPosDCI		:= ""
Local lFebraban		:= .F.
Local lGrava		:= .T.
Local nTipoDat		:= 0
Local lGravaSIF		:= .T.
Local nHdlConf		:= 0
Local nTamArq		:= 0
Local nTamDet		:= 0
Local cPosBco		:= ""
Local cPosAge		:= ""
Local cPosCta		:= ""
Local cNumMov  		:= ""
Local cDataBco		:= ""
Local dDataMov		:= CtoD("")
Local cDataMov		:= ""
Local cValorMov		:= ""
Local cCodMov		:= ""
Local cDescrMov		:= ""
Local cTipoMov 		:= ""
Local cDescMov 		:= ""
Local cItem			:= Replicate("0",TamSx3("IG_ITEM")[1])
Local cChkSum		:= ""
Local nLinha		:= 0
Local nContReg		:= 0
Local nTamA6Cod := TamSX3( "A6_COD"     )[1]
Local nTamA6Agn := TamSX3( "A6_AGENCIA" )[1]
Local nTamA6Num := TamSX3( "A6_NUMCON"  )[1]
Local aConta		:= {}
Local lFa473Cta 	:= ExistBlock("FA473CTA")
Local lTemLacto		:= .F.

Default aLog := {}

dbSelectArea("SA6")
SA6->(DBSetOrder(1))

dbSelectArea("SIG")
SIG->(DBSetOrder(1))

dbSelectArea("SIF")
SIF->(DBSetOrder(1))

//Posiciona no Banco indicado 
dbSelectArea("SEE")
dbSetOrder(1)	//"EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA"
If dbSeek(xFilial("SEE")+aConfig1[2]+aConfig1[3]+aConfig1[4]+aConfig1[5])
	lFebraban := IIF(SEE->EE_BYTESXT > 200 , .t., .f.)
	nTamDet	 := IIF(SEE->EE_BYTESXT > 0, SEE->EE_BYTESXT + 2, 202 )
	nTipoDat	 := SEE->EE_TIPODAT
Else
	aAdd(aLog,{0,STR0049})//"Verifique os parametros digitados, pois não foi possível, localizar o registro das parametrizaçães de transmissão(SEE)."
Return .F.
Endif

If Empty(nTipoDat)
	nTipoDat := IIF(nTamDet > 202, 4,1)		//1 = ddmmaa		4= ddmmaaaa
EndIf

//Abre arquivo de configuracao
cArqConf:=aConfig2[1]

IF !FILE(cArqConf)
	aAdd(aLog,{0,STR0029}) // "Arquivo de Configuração não encontrado"
Return .F.
Else
	nHdlConf:=FOPEN(cArqConf,0+64)
EndIF

//Leitura do arquivo de configuracao
nLidos:=0
FSEEK(nHdlConf,0,0)
nTamArq:=FSEEK(nHdlConf,0,2)
FSEEK(nHdlConf,0,0)

While nLidos <= nTamArq
	
	//Verifica o tipo de qual registro foi lido
	xBuffer:=Space(85)
	FREAD(nHdlConf,@xBuffer,85)
	IF SubStr(xBuffer,1,1) == CHR(1)  // Header
		nLidos+=85
		Loop
	EndIF
	
	IF SubStr(xBuffer,1,1) == CHR(4) // Saldo Final
		nLidos+=85
		Loop
	EndIF
	
	//Dados do Saldo Inicial (Bco/Ag/Cta) 
	IF !lPosBco  //Nro do Banco
		cPosBco:=Substr(xBuffer,17,10)
		nLenBco:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosBco:= .T.
		nLidos+=85
		Loop
	EndIF
	IF !lPosAge  //Agencia
		cPosAge :=Substr(xBuffer,17,10)
		nLenAge :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosAge := .T.
		nLidos+=85
		Loop
	EndIF
	IF !lPosCta  //Nro Cta Corrente
		cPosCta=Substr(xBuffer,17,10)
		nLenCta=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosCta= .T.
		nLidos+=85
		Loop
	Endif
	IF !lPosDif   // Diferencial de Lancamento
		cPosDif  := Substr(xBuffer,17,10)
		nLenDif  := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosDif  := .t.
		nLidos+=85
		Loop
	EndIF

	//Os dados abaixo não são utilizados na reconciliacao.
	//Estao ai apenas p/leitura do arquivo de configuracao.
	IF !lPosVSI   // Valor Saldo Inicial
		cPosVSI  :=Substr(xBuffer,17,10)
		nLenVSI  :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosVSI  := .t.
		nLidos+=85
		Loop
	EndIF
	IF !lPosDSI   // Data Saldo Inicial
		cPosDSI  :=Substr(xBuffer,17,10)
		nLenDSI  :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosDSI  := .t.
		nLidos+=85
		Loop
	EndIF
	IF !lPosDCI   // Identificador Deb/Cred do Saldo Inicial
		cPosDCI  :=Substr(xBuffer,17,10)
		nLenDCI  :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosDCI  := .t.
		nLidos+=85
		Loop
	EndIF
	
	//Dados dos Movimentos 
	IF !lPosNum  // Nro do Lancamento no Extrato
		cPosNum:=Substr(xBuffer,17,10)
		nLenNum:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosNum:= .t.
		nLidos+=85
		Loop
	EndIF
	
	IF !lPosData  // Data da Movimentacao
		cPosData:=Substr(xBuffer,17,10)
		nLenData:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosData:= .t.
		nLidos+=85
		Loop
	EndIF
	
	IF !lPosValor  // Valor Movimentado
		cPosValor=Substr(xBuffer,17,10)
		nLenValor=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosValor= .t.
		nLidos+=85
		Loop
	EndIF
	
	IF !lPosOcor // Ocorrencia do Banco
		cPosOcor	:=Substr(xBuffer,17,10)
		nLenOcor :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosOcor	:= .t.
		nLidos+=85
		Loop
	EndIF
	
	IF !lPosDescr  // Descricao do Lancamento
		cPosDescr:=Substr(xBuffer,17,10)
		nLenDescr:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosDescr:= .t.
		nLidos+=85
		Loop
	EndIF
	
	IF !lPosDif   // Diferencial de Lancamento
		cPosDif  :=Substr(xBuffer,17,10)
		nLenDif  :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosDif  := .t.
		nLidos+=85
		Loop
	EndIF
	
	Exit
EndDo

//fecha arquivo de configuracao
Fclose(nHdlConf)

//Abre arquivo enviado pelo banco
cArqEnt:= aConfig2[2]
IF !FILE(cArqEnt)
	aAdd(aLog,{0,STR0030}) //"Arquivo do Banco não encontrado"
	Return .F.
Else
	nHdlBco:=FOPEN(cArqEnt,0+64)
EndIF


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ler arquivo enviado pelo banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLidos:=0
FSEEK(nHdlBco,0,0)
nTamArq:=FSEEK(nHdlBco,0,2)
FSEEK(nHdlBco,0,0)

cChkSum := F473CHKSUM(nHdlBco)

SIF->(dbSetOrder(3))//IF_FILIAL + IF_ARQSUM
If SIF->(dbSeek(xFilial("SIF") + cChkSum ) )
	aAdd(aLog,{0,STR0039}) //"Arquivo de Extrato já importado"
	Fclose(nHdlBco)
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desenha o cursor e o salva para poder moviment -lo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLidos 		:= 0

While nLidos <= nTamArq
	nLinha++
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tipo qual registro foi lido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xBuffer:=Space(nTamDet)
	FREAD(nHdlBco,@xBuffer,nTamDet)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o diferencial do registro de Lancamento 			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lFebraban  // 200 posicoes
		cDifer :=Substr(xBuffer,Int(Val(Substr(cPosDif, 1,3))),nLenDif )
	Else
		cDifer := "xx"  // 240 posicoes
	Endif
	
	// Header do arquivo
	IF (SubStr(xBuffer,1,1) == "0" .and. !lFebraban).or. ; // 200 posicoes
		(Substr(xBuffer,8,1) == "0" .and. lFebraban)			// 240 posicoes
		nLidos+=nTamDet
		Loop
	EndIF
	
	//Trailer do arquivo
	IF (SubStr(xBuffer,1,1) == "9" .and. !lFebraban) .or. ; //200 posicoes
		(Substr(xBuffer,8,1) == "9" .and. lFebraban)			 //240 posicoes
		nLidos+=nTamDet
		Exit
	EndIF
	
	// Saldo Inicial
	IF (SubStr(xBuffer,1,1) == "1" .and. cDifer == "0" .and. !lFebraban) .or. ;
			(SubStr(xBuffer,8,1) == "1" .and. lFebraban)
		cBanco   := Substr(xBuffer,Int(Val(Substr(cPosBco, 1,3))),nLenBco )
		cAgencia := Substr(xBuffer,Int(Val(Substr(cPosAge, 1,3))),nLenAge )
		cConta   := Substr(xBuffer,Int(Val(Substr(cPosCta, 1,3))),nLenCta )
		If lFa473Cta
			aConta   := ExecBlock("FA473CTA", .F., .F., {cBanco, cAgencia, cConta} )
			cBanco   := aConta[1]
			cAgencia := aConta[2]
			cConta   := aConta[3]
		Endif

		If cBanco != aConfig1[2]
			lTemLacto := .T.
			Exit
		EndIf	
			
		A473VldBco( @cBanco , @cAgencia , @cConta, @nLinha, @aLog, @lRet )
				
		cBanco 		:= PadR( cBanco   , nTamA6Cod )
		cAgencia 	:= PadR( cAgencia , nTamA6Agn )
		cConta 		:= PadR( cConta   , nTamA6Num )

		If AllTrim(cBanco)!= AllTrim(aConfig1[2])
			aADD(aLog,{nLinha, STR0031 } ) //"Banco não cadastrado"
			lRet := .F.
		Endif

		nLidos+=nTamDet
		Loop
	EndIF

	// Saldo Final
	IF (SubStr(xBuffer,1,1) == "1" .and. cDifer == "2" .and. !lFebraban) .or. ;
			(Substr(xBuffer,8,1) == "5" .and. lFebraban)
		nLidos+=nTamDet
		Loop
	EndIF
	
	// Lancamentos
	IF (SubStr(xBuffer,1,1) == "1" .and. cDifer == "1" .and. !lFebraban) .or. ;
			(Substr(xBuffer,8,1) == "3" .and. lFebraban)
		
		lTemLacto := .T.	
		If lFa473Cta
			If Len(aConta) == 0
				aConta   := ExecBlock("FA473CTA", .F., .F., {cBanco, cAgencia, cConta} )
				cBanco   := aConta[1]
				cAgencia := aConta[2]
				cConta   := aConta[3]
			EndIf
		Else
			cBanco   := Substr(xBuffer,Int(Val(Substr(cPosBco, 1,3))),nLenBco )
			cAgencia := Substr(xBuffer,Int(Val(Substr(cPosAge, 1,3))),nLenAge )
			cConta   := Substr(xBuffer,Int(Val(Substr(cPosCta, 1,3))),nLenCta )
		Endif
				
		A473VldBco( @cBanco , @cAgencia , @cConta, @nLinha, @aLog )
		
		cBanco 		:= PadR( cBanco   , nTamA6Cod )
		cAgencia 	:= PadR( cAgencia , nTamA6Agn )
		cConta 		:= PadR( cConta   , nTamA6Num )

		cNumMov  :=Substr(xBuffer,Int(Val(Substr(cPosNum,1,3))),nLenNum)
		cDataBco :=Substr(xBuffer,Int(Val(Substr(cPosData,1,3))),nLenData)
		cDataBco :=ChangDate(cDataBco,nTipoDat)
		dDataMov :=Ctod(Substr(cDataBco,1,2)+"/"+Substr(cDataBco,3,2)+"/"+Substr(cDataBco,5,2),"ddmmyy")
		cDataMov := dToc(dDataMov)

		cValorMov:= Round(Val(Substr(xBuffer,Int(Val(Substr(cPosValor,1,3))),nLenValor))/100,2)
		cCodMov	 :=Substr(xBuffer,Int(Val(Substr(cPosOcor,1,3))),nLenOcor)
		cDescrMov:=Substr(xBuffer,Int(Val(Substr(cPosDescr,1,3))),nLenDescr)
		
		
		dbSelectArea("SEJ")
		If dbSeek(xFilial("SEJ")+cBanco+cCodMov)
			cTipoMov := SEJ->EJ_OCORSIS
			cDescMov := SEJ->EJ_DESCR
			cDebCred := SEJ->EJ_DEBCRE
		Else
			aADD(aLog,{nLinha , STR0032 + " - " + cCodMov } ) //"Ocorrencia Não Encontrada"
			lGrava 	:= .F.
			lRet 	:= .F.
		Endif

		If lGrava
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava dados no arquivo de trabalho³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			If lGravaSIF
				RecLock("SIF",.T.)
				SIF->IF_FILIAL 	:= xFilial("SIF")
				SIF->IF_IDPROC  := aConfig1[1 ]
				SIF->IF_DTPROC  := ctod(cDataMov)
				SIF->IF_BANCO	:= aConfig1[2]
				SIF->IF_DESC	:= aConfig1[6]
				SIF->IF_STATUS 	:= '1'
				SIF->IF_ARQCFG	:= aConfig2[1]
				SIF->IF_ARQIMP	:= aConfig2[2]
				SIF->IF_ARQSUM	:= cChkSum
				SIF->(MsUnlock())
				lGravaSIF:= .F.
			EndIf

			//Grava se não tiver inconsistência

			If SA6->(DbSeek(xFilial("SA6")+cBanco+cAgencia+cConta)) .And. SA6->A6_BLOCKED = "2"//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
				// Grava SIG
				RecLock("SIG",.T.)
				cItem := Soma1(cItem)
				SIG->IG_FILIAL 	:= xFilial("SIG")
				SIG->IG_IDPROC	:= aConfig1[1 ]
				SIG->IG_ITEM	:= cItem
				SIG->IG_STATUS	:= '1'
				SIG->IG_DTEXTR	:= CTOD(cDataMov)
				SIG->IG_DOCEXT	:= cNumMov
				SIG->IG_SEQMOV  := F473ProxNum("SIG")
				SIG->IG_VLREXT 	:= Val(str(cValorMov,17,2))
				SIG->IG_TIPEXT	:= cCodMov
				SIG->IG_CARTER	:= IIF(cDebCred=="D","2","1")
				SIG->IG_AGEEXT  := cAgencia
				SIG->IG_CONEXT  := cConta
				SIG->IG_HISTEXT  := cDescrMov
				SIG->IG_FILORIG  := cFilAnt
				SIG->(MsUnlock())
				nContReg++
			Else
				aADD(aLog,{nLinha , STR0040  + cBanco + STR0041 + cAgencia + STR0042 + cConta + STR0043 } )//"Banco: "##" Agencia: "##" Conta: "##" não existe."
				lRet := .F.
			EndIf
		EndIf

	Endif
	nLidos += nTamDet
Enddo

If nContReg <= 0
	If !lTemLacto	
		aADD(aLogLanc,{0 , "Este arquivo de extrato não possui lançamentos. " } )//"Este arquivo de extrato não possui lançamentos. "
		lRet := .F.
	Else
		aADD(aLog,{0 , "Arquivo de Extrato Inválido. Verifique arquivo de configuração e extrato." } )//"Arquivo de Extrato Inválido. Verifique arquivo de configuração e extrato."
		lRet := .F.
	EndIf
EndIf

//Fecha arquivo do Banco 
Fclose(nHdlBco)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F473CHKSUM

Retorna o CheckSum do Arquivo.

@author	Alvaro Camillo Neto
@since		01/10/13
@version	MP11.90
		
/*/
//-------------------------------------------------------------------
Static Function F473CHKSUM(nHdlBco)
Local cRet		:= ""
Local cBuffer	:= Space(402)
Local nOffSet	:= fSeek(nHdlBco,0,FS_RELATIVE) // Sera utilizado para retornar o ponteiro do arquivo a posicao original
Local nTamArq	:= fSeek(nHdlBco,0,FS_END) // Obtem o tamanho do arquivo
Local cIdArq    := ""
Local cTrailler := ""

fSeek(nHdlBco,-804,FS_END) // Volta 804 bytes para compor o CheckSum

// Le o arquivo ate final
While fReadLn(nHdlBco,@cBuffer,402)
	cRet += cBuffer
End

fSeek(nHdlBco,nOffSet,FS_SET) // Retorna o ponteiro para a posicao original

cTrailler := cRet+Transform(nTamArq,"")

cIdArq	 := Str(MsCrc32(cTrailler),10) 

Return cIdArq

//-------------------------------------------------------------------
/*/{Protheus.doc} F473ProxNum

Retorna o próximo número da chave

@author	Alvaro Camillo Neto
@since		01/10/13
@version	MP11.90
		
/*/
//-------------------------------------------------------------------
Static Function F473ProxNum(cTab)
Local cNovaChave := ""
Local aArea := GetArea()
Local cCampo := ""
Local cChave 
Local nIndex := 0

If cTab == "SIF"
	SIF->(dbSetOrder(1))//IF_FILIAL+IF_IDPROC
	cCampo := "IF_IDPROC"
	nIndex := 1	
Else
	SIG->(dbSetOrder(2))//IG_FILIAL+IG_SEQMOV
	cCampo := "IG_SEQMOV"
	cChave := "IG_SEQMOV"+cEmpAnt
	nIndex := 2
EndIf


While .T.
	(cTab)->(dbSetOrder(nIndex))
	cNovaChave := GetSXEnum(cTab,cCampo,cChave,nIndex)
	ConfirmSX8()
	If cTab == "SIF" 
		If (cTab)->(!dbSeek(xFilial(cTab) + cNovaChave) )
			Exit
		EndIf
	Else
		If (cTab)->(!dbSeek(cNovaChave) )
			Exit
		EndIf
	EndIf
EndDo

RestArea(aArea)
Return cNovaChave

//-------------------------------------------------------------------
/*/{Protheus.doc} A473VldBco
Valida o banco, agencia e conta 
Funcao retirada do FINA910A
@author	Daniel Mendes
@since		30/05/16
@version	12.1.7
/*/
//-------------------------------------------------------------------
Static Function A473VldBco( cBanco , cAgencia , cConta, nLinha, aLog, lRet )
Local aAreaATU := GetArea()
Local aAreaSA6 := SA6->( GetArea() )
Local cFilSA6  := xFilial( 'SA6' )
Local nSubAge  := 0
Local nSubCon  := 0
Local lStop    := .F.

If !SA6->( MsSeek( cFilSA6 + cBanco + cAgencia + cConta ) )
	SA6->( MsSeek( cFilSA6 + cBanco ) )

	While !SA6->( Eof() ) .And. cFilSA6 == SA6->A6_FILIAL .And. cBanco == SA6->A6_COD .And. !lStop
		
		If SA6->A6_BLOCKED = '1' //Se banco estiver bloqueado ceverá ser pulado
			SA6->( DbSkip() )
			Loop
		EndIf
			
		nSubAge := At( Alltrim( SA6->A6_AGENCIA ) , cAgencia )
		nSubCon := At( Alltrim( SA6->A6_NUMCON  ) , cConta   )
		If nSubAge > 0 .And. nSubCon > 0
			If ( SubStr( cAgencia , 1 , nSubAge-1 ) == StrZero( 0 , nSubAge-1 ) .Or. ;// Valida 0 a esquerda: Agencia 
			     Alltrim( SA6->A6_AGENCIA ) == AllTrim( cAgencia ) ) ;
			   .And. ;
			   ( SubStr( cConta   , 1 , nSubCon-1 ) == StrZero( 0 , nSubCon-1 ) .Or. ;// Valida 0 a esquerda: Conta Corrente
			     Alltrim( SA6->A6_NUMCON  ) == AllTrim( cConta   ) )
				cAgencia := SA6->A6_AGENCIA
				cConta   := SA6->A6_NUMCON
				cBanco   := SA6->A6_COD
				lStop    := .T.
			EndIf
		EndIf
		SA6->( DbSkip() )
	EndDo
	
	If Empty(nSubAge) .or. Empty(nSubCon)  
		aADD(aLog,{nLinha , STR0040  + cBanco + STR0041 + cAgencia + STR0042 + cConta + STR0043 } )//"Banco: "##" Agencia: "##" Conta: "##" não existe."
		lRet := .F.		
	EndIf
	
EndIf

RestArea( aAreaSA6 )
RestArea( aAreaATU )
aSize( aAreaSA6 , 0 )
aSize( aAreaATU , 0 )
aAreaSA6 := Nil
aAreaATU := Nil

Return Nil