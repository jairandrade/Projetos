#include "ap5mail.ch"
#INCLUDE "TOPCONN.CH"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "totvs.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "XMLXFUN.CH"
#Include "Protheus.ch"

#Define ENTER chr(13)+chr(10)

//Compilado e validado 05/12/2016 -- Usuaria Patricia/Fiscal -- Andre/Rsac 
//Em manuten��o -- 24.05.2018 -- Para chamada de rotina de importa��o de dados CTe para tabelas ZC1 e ZC2. -- Andre/Rsac

/*Tela de importacao doo xml da nota fiscal eletronica*/

User Function ImpXML_X()
Private aRotina := {{"Documento de entrada", "U_RSNFEB(1)", 0, 2},;
					{"Pre-Nota", "U_RSNFEB(2)", 0, 2},;
					{"Download XML", "U_PuxaNFE()", 0, 3},;
					{"Download CTE","U_Pegarqs()", 0, 3},;
					{"arquivo xml" ,"U_Pegarqs2()", 0, 3},;
					{"Visualizar", "U_RSNFEB(3)", 0, 3},;
					{"Legenda","U_LegC00()",0,5}}

AtualizarStatus()
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('C00')

//EM 27/05/2019 
oBrowse:AddLegend( "C00_CLASSI<>'S'", "GREEN"	, "Nao Classificada" )
oBrowse:AddLegend( "C00_CLASSI=='S'", "RED"		, "Classificada" )


oBrowse:SetFilterDefault( "C00_JABAIX=='S'" )
oBrowse:Activate()

Return

 
User Function PuxaNFE()
Processa( { || PuxaNFE2() } , "[PUXANFE] - AGUARDE")

Return


Static Function PuxaNFE2()
Private cWEBUser  	:= ''					//Nome do Usuario
Private cWEBSenha 	:= ''  				//Senha do usuario
Private cWebEnv 	:= '01' 	 		//Environment/Ambiente
Private cWebModulo 	:= 'SIGACOM'	//Modulo a ser usado
Private cSrvEmpresa := '04'				//Empresa
Private aSrvTabelas := {}
PRIVATE lReajuste	:= .F.
lLiberou:=.f.

/*aSrvTabelas := {"C00"} //Tabelas a serem abertas
RPCSetType(3) //Nao come licen�a
RPCSETENV(cSrvEmpresa, '01', cWEBUser, cWEBSenha, cWebModulo, cWebEnv, aSrvTabelas)
*/

SincDados(.t.)

cQuery:=" Select * from "+RetSqlName('C00')
cQuery+=" where C00_STATUS =0"
cQuery+=" AND D_E_L_E_T_<>'*'"
If Select('TRC0')<>0
	TRC0->(dbCloseArea())
EndIf
TcQuery cQuery New Alias "TRC0"
NCONT:=0
While !TRC0->(EOF()) .AND. NCONT <= 10
	MontaXmlManif({{"",TRC0->C00_CHVNFE}},"","")
	NCONT++
	TRC0->(DBSkip())
EndDO

peganfe()
Return

Static Function SincDados(lProcAll)
Local aChave	:= {}
Local aDocs		:= {}
Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cIdEnt	:= RetIdEnti(.F.)
Local cChave	:= ""
Local cCancNSU	:= ""
Local cAlert	:= ""
Local cSitConf	:= ""
Local cAmbiente	:= ""
Local lContinua	:= .T.

Local dData		:= CtoD("  /  /    ")
Local lOk       := .F.
Local nX		:= 0
Private oWs		:= Nil
Default lProcAll := .F.

//If ReadyTSS()
oWs :=WSMANIFESTACAODESTINATARIO():New()
oWs:cUserToken   := "TOTVS"
oWs:cIDENT	     := cIdEnt
oWs:cINDNFE		 := "0"
oWs:cINDEMI      := "0"
oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"

oWs :=WSMANIFESTACAODESTINATARIO():New()
oWs:cUserToken   := "TOTVS"
oWs:cIDENT	     := cIdEnt
oWs:cAMBIENTE	 := ""
oWs:cVERSAO      := ""
oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"
oWs:CONFIGURARPARAMETROS()
cAmbiente		 :=oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE

//Tratamento para solicitar a sincroniza��o enaquanto o IDCONT n�o retornar zero.
ProcRegua(0)

While lContinua
	
	
	If oWs:SINCRONIZARDOCUMENTOS()
		If Type ("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO") <> "U"
			If Type("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO")=="A"
				aDocs := oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO
			Else
				aDocs := {oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO}
			EndIf
			
			For nX := 1 To Len(aDocs)
				
				If Type(aDocs[nX]:CCHAVE) <> "U" .and. Type(aDocs[nX]:CSITCONF) <> "U"
					IncProc("Processando nota "+Substr(aDocs[Nx]:CCHAVE,26,9))
					cSitConf  := aDocs[Nx]:CSITCONF
					cChave    := aDocs[Nx]:CCHAVE
					IF Type("aDocs[nX]:CCANCNSU") <> "U"
						cCancNSU  := aDocs[Nx]:CCANCNSU
					Else
						cCancNSU  := ""
					EndIF
					If !DbSeek( xFilial("C00") + cChave)
						RecLock("C00",.T.)
						C00->C00_FILIAL     := xFilial("C00")
						C00->C00_STATUS     := cSitConf
						C00->C00_CHVNFE		:= cChave
						dData := CtoD("01/"+Substr(cChave,5,2)+"/"+Substr(cChave,3,2))
						C00->C00_ANONFE		:= Strzero(Year(dData),4)
						C00->C00_MESNFE		:= Strzero(Month(dData),2)
						C00->C00_SERNFE		:= Substr(cChave,23,3)
						C00->C00_NUMNFE		:= Substr(cChave,26,9)
						C00->C00_CODEVE		:= Iif(cSitConf $ '0',"1","3")
						aadd(aChave,cChave)
						lOk := .T.
						MsUnLock()
					Else
						If !Empty(cCancNSU)
							RecLock("C00",.F.)
							C00->C00_SITDOC := "3"
							MsUnLock()
						EndIf
					EndIf
				EndIf
			Next
			
			If lOk
				MonitoraManif(aChave,cAmbiente,cIdEnt,cUrl)
			EndIf
			
			If Type("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:CINDCONT") <> "U"
				
				If oWs:OWSSINCRONIZARDOCUMENTOSRESULT:CINDCONT == "0"
					lContinua := .F.
				endif
			else
				lContinua := .F.
			endif
			
			If Empty(aDocs) .And. !lContinua .And. !lOk
				cAlert:= "N�o h� documentos para serem sincronizados"
				Aviso("Sincroniza��o",cAlert,{"OK"},3)
			EndIF
			
			if lContinua .And. !lProcAll
				lContinua := MsgYesNo("Ainda existem documentos na SEFAZ a serem sincronizados, deseja solicitar novamente a sincroniza��o ?")
			endif
			Sleep(2000)
		EndIf
	Else
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
		lContinua := .F.
	EndIf
EndDo
//Else
//s	Aviso("SPED",STR0021,{STR0114},3) //"Execute o m�dulo de configura��o do servi�o, antes de utilizar esta op��o!!!"
//EndIf

oWs := Nil
DelClassIntf()

Return

Static Function MontaXmlManif(aMontXml,cRetorno,cJustific)
Local aRet			:={}
Local cAmbiente		:= ""
Local cXml				:= ""
Local cTpEvento		:= SubStr("210210",1,6)
Local cIdEnt		:=  RetIdEnti()
Local cURL			:= GetMV("MV_SPEDURL")
Local cChavesMsg	:= ""
Local cMsgManif		:= ""
Local lRetOk		:= .T.
Local nX 			:= 0
Local nZ 			:= 0
Private oWs			:= Nil
Private lUsaColab		:= UsaColaboracao("1")
Default cJustific 	:= ""

oWs :=WSMANIFESTACAODESTINATARIO():New()
oWs:cUserToken   := "TOTVS"
oWs:cIDENT	     := cIdEnt
oWs:cAMBIENTE	 := ""
oWs:cVERSAO      := ""
oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"

If oWs:CONFIGURARPARAMETROS()
	cAmbiente		 := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE
	
	cXml+='<envEvento>'
	cXml+='<eventos>'
	
	For nX:=1 To Len(aMontXml)
		cXml+='<detEvento>'
		cXml+='<tpEvento>'+cTpEvento+'</tpEvento>'
		cXml+='<chNFe>'+Alltrim(aMontXml[nX][2])+'</chNFe>'
		cXml+='<ambiente>'+cAmbiente+'</ambiente>'
		If '210240' $ cTpEvento .and. !Empty(cJustific)
			cXml+='<xJust>'+Alltrim(cJustific)+'</xJust>'
		EndIf
		cXml+='</detEvento>'
	Next
	cXml+='</eventos>'
	cXml+='</envEvento>'
	
	
	lRetOk:= RetEnvManif(cXml    ,cIdEnt,cUrl,@aRet,''      )
	
	If lRetOk .And. Len(aRet) > 0
		For nZ:=1 to Len(aRet)
			aRet[nZ]:= Substr(aRet[nZ],9,44)
			cChavesMsg += aRet[nZ] + Chr(10) + Chr(13)
		Next
		cMsgManif := "Transmiss�o da Manifesta��o conclu�da com sucesso!"+ Chr(10) + Chr(13)//
		cMsgManif += '210210'+ Chr(10) + Chr(13)
		cMsgManif += "Chave(s): "+ Chr(10) + Chr(13)
		cMsgManif += cChavesMsg
		cRetorno := Alltrim(cMsgManif)
		
	EndIf
	
	AtuStatus(aRet,cTpEvento)
	
Else
	Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
EndIF

Return lRetOk

Static Function AtuStatus(aRet,cTpEvento)

Local aAreas	:= {}

Local cStat		:= "0"
Local nX		:= 0

If cTpEvento $ '210200'
	cStat:= "1"  //Confirmada opera��o
ElseIf cTpEvento $ '210220'
	cStat:= "2"  //Desconhecimento da Opera��o
ElseIf cTpEvento $ '210240'
	cStat:= "3"  //Opera��o n�o Realizada
ElseIf cTpEvento $ '210210'
	cStat:= "4"  //Ci�ncia da opera��o
EndIf

If Len(aRet) > 0
	aAreas := GetArea()
	For nX:=1 to Len(aRet)
		C00->(DbSetOrder(1))
		If C00->(DBSEEK(xFilial("C00")+aRet[nX]))
			RecLock("C00")
			C00->C00_STATUS := cStat
			C00->C00_CODEVE := "2"
			MsUnlock()
		EndIf
	Next
	RestArea(aAreas)
EndIf

Return
Static Function MonitoraManif(aChave,cAmbiente,cIdEnt,cUrl)

Local aMonDoc	:={}
Local nZ := 0
Local nY := 0

Private oWS		:= Nil

oWs :=WSMANIFESTACAODESTINATARIO():New()
oWs:cUserToken   := "TOTVS"
oWs:cIDENT	     := cIdEnt
oWs:cAMBIENTE	 := cAmbiente
oWs:OWSMONDADOS:OWSDOCUMENTOS  := MANIFESTACAODESTINATARIO_ARRAYOFMONDOCUMENTO():New()
For nY := 1 to Len(aChave)
	aadd(oWs:OWSMONDADOS:OWSDOCUMENTOS:OWSMONDOCUMENTO,MANIFESTACAODESTINATARIO_MONDOCUMENTO():New())
	oWs:OWSMONDADOS:OWSDOCUMENTOS:OWSMONDOCUMENTO[nY]:CCHAVE := aChave[nY]
Next
oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"

If oWs:MONITORARDOCUMENTOS()
	If Type ("oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET") <> "U"
		If Type ("oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET") == "A"
			aMonDoc := oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET
		Else
			aMonDoc := {oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET}
		EndIf
	EndIF
	For nZ :=1 to Len(aMonDoc)
		If Type(aMonDoc[nZ]:CCHAVE) <> "U"
			cChave := aMonDoc[nZ]:CCHAVE
			C00->(DbsetOrder(1))
			If C00->(DbSeek( xFilial("C00") + cChave))
				RecLock("C00",.F.)
				C00->C00_CNPJEM     := Iif(!Empty(Alltrim(aMonDoc[nZ]:CEMITENTECNPJ)),Alltrim(aMonDoc[nZ]:CEMITENTECNPJ),Alltrim(aMonDoc[nZ]:CEMITENTECPF))
				C00->C00_IEEMIT		:= AllTrim(aMonDoc[nZ]:CEMITENTEIE)
				C00->C00_NOEMIT     := Alltrim(aMonDoc[nZ]:CEMITENTENOME)
				C00->C00_STATUS     := aMonDoc[nZ]:CSITUACAOCONFIRMACAO
				C00->C00_SITDOC     := aMonDoc[nZ]:CSITUACAO
				C00->C00_DESRES     := Alltrim(aMonDoc[nZ]:CRESPOSTADESCRICAO)
				C00->C00_CODRET		:= aMonDoc[nZ]:CRESPOSTASTATUS
				C00->C00_DTEMI  	:= StoD(StrTran(aMonDoc[nZ]:CDATAEMISSAO,"-",""))
				C00->C00_DTREC      := StoD(StrTran(aMonDoc[nZ]:CDATAAUTORIZACAO,"-",""))
				C00->C00_VLDOC		:= aMonDoc[nZ]:NVALORTOTAL
				C00->(MsUnLock())
				
				cChave := aMonDoc[nZ]:CCHAVE
				
				cCNPJEmit	:= Iif(!Empty(Alltrim(aMonDoc[nZ]:CEMITENTECNPJ)),Alltrim(aMonDoc[nZ]:CEMITENTECNPJ),Alltrim(aMonDoc[nZ]:CEMITENTECPF))
				cIeEmit	:= AllTrim(aMonDoc[nZ]:CEMITENTEIE)
				cNomeEmit	:= Alltrim(aMonDoc[nZ]:CEMITENTENOME)
				cSitConf	:= aMonDoc[nZ]:CSITUACAOCONFIRMACAO
				cSituacao	:= aMonDoc[nZ]:CSITUACAO
				cDesResp	:= Alltrim(aMonDoc[nZ]:CRESPOSTADESCRICAO)
				cDesCod	:= aMonDoc[nZ]:CRESPOSTASTATUS
				
				dDtEmi		:= StoD(StrTran(aMonDoc[nZ]:CDATAEMISSAO,"-",""))
				dDtRec		:= StoD(StrTran(aMonDoc[nZ]:CDATAAUTORIZACAO,"-",""))
				
				nValDoc		:= aMonDoc[nZ]:NVALORTOTAL
				
				
				MonAtuDados(cChave,cCNPJEmit,cIeEmit,cNomeEmit,cSitConf,cSituacao,cDesResp,cDesCod,dDtEmi,dDtRec,nValDoc)
			EndIf
		EndIf
	Next
Else
	//	Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
EndIf

oWs := Nil
DelClassIntf()

Return
/*DOWNLOAD DO XML DAS NOTAS*/

Static Function peganfe

cIdEnt	:= RetIdEnti()
cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
oWs :=WSMANIFESTACAODESTINATARIO():New()
oWs:cUserToken   := "TOTVS"
oWs:cIDENT	     := cIdEnt
oWs:cAMBIENTE	 := ""
oWs:cVERSAO      := ""
oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"
oWs:CONFIGURARPARAMETROS()
cAmbiente		 := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE

oWs:cUserToken   := "TOTVS"
oWs:cIDENT	     := cIdEnt
oWs:cAMBIENTE	 := cAmbiente



cQry:=" select C00_CHVNFE, R_E_C_N_O_ AS REC from "+RETSQLNAME('C00')+""
cQry+=" WHERE C00_JABAIX<>'S'
cQry+=" AND C00_STATUS='4'
cQry+=" AND D_E_L_E_T_<>'*'
IF Select('TRC0')<>0
	TRC0->(DBCloseArea())
EndIF
TcQuery  cQry New Alias "TRC0"

WHILE !TRC0->(EOF())
	oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"
	oWs:oWSDOCUMENTOS:oWSDOCUMENTO  := MANIFESTACAODESTINATARIO_ARRAYOFBAIXARDOCUMENTO():New()
	aadd(oWs:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO,MANIFESTACAODESTINATARIO_BAIXARDOCUMENTO():New())
	
	oWs:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO[1]:CCHAVE := TRC0->C00_CHVNFE
	If oWs:BAIXARXMLDOCUMENTOS()
		If Type ("oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET") <> "U"
			If Type ("oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET") == "A"
				aXmlRet := oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET
			Else
				aXmlRet := {oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET}
			EndIf
		EndIF
		IF !Empty(aXmlRet[1]:CNFEZIP)
			MEMOWRITE("C:\CNAB\"+alltrim(TRC0->C00_CHVNFE)+".xml", TiraGraf(aXmlRet[1]:CNFEZIP))
			DBSELECTAREA('C00')
			DBGOTO(TRC0->REC)
			RECLOCK('C00',.F.)
			C00_JABAIX:="S"
			C00_RSXML:= TiraGraf(aXmlRet[1]:CNFEZIP)
			MSUNLOCK()
		EndIF
	EndIF
	
	
	TRC0->(DBSKIP())
End


Return

Static function TiraGraf (_sOrig)
local _sRet := _sOrig
_sRet = strtran (_sRet, "�", "a")
_sRet = strtran (_sRet, "�", "e")
_sRet = strtran (_sRet, "�", "i")
_sRet = strtran (_sRet, "�", "o")
_sRet = strtran (_sRet, "�", "u")
_SRET = STRTRAN (_SRET, "�", "A")
_SRET = STRTRAN (_SRET, "�", "E")
_SRET = STRTRAN (_SRET, "�", "I")
_SRET = STRTRAN (_SRET, "�", "O")
_SRET = STRTRAN (_SRET, "�", "U")
_sRet = strtran (_sRet, "�", "a")
_sRet = strtran (_sRet, "�", "o")
_SRET = STRTRAN (_SRET, "�", "A")
_SRET = STRTRAN (_SRET, "�", "O")
_sRet = strtran (_sRet, "�", "a")
_sRet = strtran (_sRet, "�", "e")
_sRet = strtran (_sRet, "�", "i")
_sRet = strtran (_sRet, "�", "o")
_sRet = strtran (_sRet, "�", "u")
_SRET = STRTRAN (_SRET, "�", "A")
_SRET = STRTRAN (_SRET, "�", "E")
_SRET = STRTRAN (_SRET, "�", "I")
_SRET = STRTRAN (_SRET, "�", "O")
_SRET = STRTRAN (_SRET, "�", "U")
_sRet = strtran (_sRet, "�", "c")
_sRet = strtran (_sRet, "�", "C")
_sRet = strtran (_sRet, "�", "a")
_sRet = strtran (_sRet, "�", "A")
_sRet = strtran (_sRet, "�", ".")
_sRet = strtran (_sRet, "�", ".")
_sRet = strtran (_sRet, "#", ".")
//_sRet = strtran (_sRet, "@", ".")
//_sRet = strtran (_sRet, '"', " ")
//_sRet = strtran (_sRet, "'", " ")
_sRet = strtran (_sRet, "&", "E")
_sRet = strtran (_sRet, chr (9), " ") // TAB
_sRet = strtran (_sRet, "�", "3")
_sRet = strtran (_sRet, "�", "0")
_sRet = strtran (_sRet, "�", " ")
_sRet = strtran (_sRet, "  ", " ")
_sRet = strtran (_sRet, "�", "2")
_sRet = strtran (_sRet, "�", "1/4")
_sRet = strtran (_sRet, "�", " ")
return _sRet


/*
//�����������������������������������������������Ŀ
//�funcao que cria documento de entrada para a nfe�
//�������������������������������������������������
*/
User Function RSNFEB(cTip)
Local nOpc 			:= 0
Local oOk  			:= LoadBitMap(GetResources(), "LBOK")
Local oNo  			:= LoadBitMap(GetResources(), "LBNO")
Local cEmpKPZ 		:= cEmpAnt
Local cFilKPZ 		:= cFilAnt

Private aRotina   	:= {}
Private aItens   	:= {{"","","","","",0,0,0,""}}
Private cCadastro 	:= "[impNfe] - Importa��o NFE"
Private aHeader		:= {}
Private aCols		:= {}
PRIVATE cA100For	:= ""
Private oXml
Private cLoja
Private cTipo
Private ldev		:=.f.
private cFile		:=""
Private nRecSA2		:=0
Private nTipo		:=cTip
Private aParcelas	:={}
Private cUforig	    := SPACE(TAMSX3("A2_EST")[1]) //adicionada variavel para compatibilidade tes inteligente - Andre Sakai - 20211602
Private aCmps 		:= {	5,;     //1
'',;//2 --CAMINHO ARQUIVO
SPACE(TAMSX3("A2_COD")[1]),;//3
SPACE(TAMSX3("A2_LOJA")[1]),;//4
SPACE(TAMSX3("A2_NOME")[1]),;//5
SPACE(TAMSX3("F1_DOC")[1]),;//6
0.00,;//SPACE(TAMSX3("F1_VALMERC")[1]),;//7
0.00,;//SPACE(TAMSX3("F1_FRETE")[1]),;//8
0.00,;//SPACE(TAMSX3("F1_DESCONT")[1]),;//9
0.00,;//SPACE(TAMSX3("F1_DESPESA")[1]),;//10
0.00,;//SPACE(TAMSX3("F1_VALIPI")[1]),;//11
0.00,;//SPACE(TAMSX3("F1_VALBRUT")[1]),;//12
0.00,;//SPACE(TAMSX3("F1_VALMERC")[1]),;//13
0.00,;//SPACE(TAMSX3("F1_FRETE")[1]),;//14
0.00,;//SPACE(TAMSX3("F1_DESCONT")[1]),;//15
0.00,;//SPACE(TAMSX3("F1_DESPESA")[1]),;//16
0.00,;//SPACE(TAMSX3("F1_VALIPI")[1]),;//17
0.00,;//SPACE(TAMSX3("F1_VALBRUT")[1]),;//18
SPACE(TAMSX3("C8_TES")[1]),;//19
SPACE(TAMSX3("E4_CODIGO")[1]),;//20
SPACE(TAMSX3("F1_CHVNFE")[1]),;//21
SPACE(TAMSX3("E2_NATUREZ")[1]),;//22
SPACE(TAMSX3("D1_PEDIDO")[1]),;//23
SPACE(TAMSX3("F1_EST")[1])}//24

IF nTipo == 1 .or. nTipo == 2
	lCanc := .f.
	cSql:= " SELECT * FROM "+RETSQLNAME('SF1')
	cSql+= " where F1_CHVNFE ='"+C00->C00_CHVNFE+"' "
	cSql+= " and D_E_L_E_T_<>'*'"
	If Select('TRNF1')<>0
		TRNF1->(dbCloseArea())
	EndIF
	
	TcQuery cSql New Alias 'TRNF1'
	if !TRNF1->(EOF())
		AVISO("Aten��o!","J� existe esta chave cadastrada no sistema!",{"OK"})
		return
	EndIf
EndIF


fBuscaDados(oXml)
oFont := TFont():New('Courier new',,-25,.T.)
aAdd(aRotina, {"Pesquisar" , "AxPesqui"   , 0, 1})
aAdd(aRotina, {"Visualizar", "U_COM06SCR" , 0, 2})
aAdd(aRotina, {"Incluir"   , "U_COM06SCR" , 0, 3})
aAdd(aRotina, {"Alterar"   , "U_COM06SCR" , 0, 4})
aAdd(aRotina, {"Excluir"   , "U_COM06SCR" , 0, 5})
aAdd(aRotina, {"Legenda"   , "U_COM06LEG" , 0, 6})
INCLUI:=.F.
aSize    := MsAdvSize()
montah()
LoadCols()
if nTipo==1 .or.  nTipo==3
	aCpoAlt :={'D1_ITEM','A5_CODPRF','D1_COD','D1_DESCRI','D1_UM','D1_LOCAL','D1_QUANT','D1_VUNIT','D1_TOTAL','D1_PEDIDO','D1_ITEMPC','D1_OPER','D1_TES','D1_VALIPI','D1_IPI','D1_BASEICM','D1_PICM','D1_VALICM','D1_FCICOD','D1_CONIMP','F1_MENNOTA'}
Elseif nTipo==2
	aCpoAlt :={'D1_ITEM','A5_CODPRF','D1_COD','D1_DESCRI','D1_UM','D1_LOCAL','D1_QUANT','D1_VUNIT','D1_TOTAL','D1_PEDIDO','D1_ITEMPC','D1_FCICOD','D1_CONIMP','F1_MENNOTA','D1_IPI'}
EndIF


nfdp:=640
DEFINE MSDIALOG oDlgTit TITLE cCadastro From 001,001 to 700,1300 Pixel

oGrpFil := TGroup():New(035,005,032,nfdp-240,'Arquivo XML',oDlgTit,CLR_HBLUE,,.T.)

oSayTip := tSay():New(047,007,{|| "Pasta:"   },oGrpFil,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetTip := tGet():New(045,033,{|u| if(PCount()>0,aCmps[2]:=u,aCmps[2])}, oGrpFil,300,9,'@!', { ||  },,,,,,.T.,,, { ||  } ,,,,.F.,,"DIR",'aCmps[2]')

//oBtnAtu := tButton():New(015,350,'Importar' , oGrpFil, {|| Processa( { || fBuscaDados(oXml) } , "[AFAT001] - AGUARDE") },40,11,,,,.T.)


oGrpnf := TGroup():New(035,403,032,nfdp,'Nota Fiscal',oDlgTit,CLR_HBLUE,,.T.)

oSayTip := tSay():New(043,435,{|| if(PCount()>0,aCmps[6]:=u,aCmps[6])   },oGrpnf,,oFont,,,,.T.,CLR_RED,CLR_WHITE,100,15)


oGrpForn := TGroup():New(065,005,62,nfdp-300,'Fornecedor',oDlgTit,CLR_HBLUE,,.T.)
oSayTip := tSay():New(077,007,{|| "Codigo:"   },oGrpForn,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetNom := tGet():New(077,033,{|u| if(PCount()>0,aCmps[3]:=u,aCmps[3])}, oGrpForn,050,9,'@!', { || mudaCli() },,,,,,.T.,,, { ||  } ,,,,.F.,,'SA2A','aCmps[3]')

oSayTip := tSay():New(077,90,{|| "Loja:"   },oGrpForn,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetNom := tGet():New(077,107,{|u| if(PCount()>0,aCmps[4]:=u,aCmps[4])}, oGrpForn,030,9,'@!', { ||mudaCli() },,,,,,.T.,,, { ||  } ,,,,.F.,,,'aCmps[4]')
cLoja:=aCmps[4]
cTipo:='N'
cA100For:=aCmps[3]
//MaTesInt(1,M->D1_OPER,cA100For,cLoja,If(cTipo$"DB","C","F"),M->D1_COD,"D1_TES")
oSayTip := tSay():New(077,150,{|| "Nome:"   },oGrpForn,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetNom := tGet():New(077,177,{|u| if(PCount()>0,aCmps[5]:=u,posicione('SA2',1,xFilial('SA2')+aCmps[3]+aCmps[4],'A2_NOME'))}, oGrpForn,150,9,'@!', { ||  },,,,,,.T.,,, { || .F. } ,,,,.F.,,,'aCmps[5]')

//adicionado para compatibilidade tes inteligente
oSayTip := tSay():New(077,400,{|| "UF:"   },oGrpForn,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetNom := tGet():New(077,415,{|u| if(PCount()>0,cUforig:=u,posicione('SA2',1,xFilial('SA2')+aCmps[3]+aCmps[4],'A2_EST'))}, oGrpForn,002,9,'@!', { ||  },,,,,,.T.,,, { || .F. } ,,,,.F.,,,'cUforig')


oGrpMV := TGroup():New(065,nfdp-298,062,nfdp,'Parametros',oDlgTit,CLR_HBLUE,,.T.)
if nTipo== 1 //somente para documento de entrada
	oSayTip := tSay():New(077,nfdp-293,{|| "Tes:"   },oGrpMV,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
	oGetNom := tGet():New(077,nfdp-273,{|u| if(PCount()>0,aCmps[19]:=u,aCmps[19])}, oGrpMV,030,9,'@!', { ||  },,,,,,.T.,,, { ||  } ,,,,.F.,,'SF4','aCmps[19]')
	
	oSayTip := tSay():New(077,nfdp-233,{|| "Cond.Pag:"   },oGrpMV,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
	oGetNom := tGet():New(077,nfdp-203,{|u| if(PCount()>0,aCmps[20]:=u,aCmps[20])}, oGrpMV,030,9,'@!', {|lRet|lRet:=veParc()  },,,,,,.T.,,, { ||  } ,,,,.F.,,'SE4','aCmps[20]')
	
	oSayTip := tSay():New(077,nfdp-170,{|| "Natureza:"   },oGrpMV,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
	oGetNom := tGet():New(077,nfdp-143,{|u| if(PCount()>0,aCmps[22]:=u,aCmps[22])}, oGrpMV,030,9,'@!', { |lRet| lRet:=!EMPTY(aCmps[22])  },,,,,,.T.,,, { ||  } ,,,,.F.,,'SED','aCmps[22]')
	oBtnAtu := tButton():New(077,590,'Atualizar'   , oDlgTit, {|| Processa({ || atuTes(.t.) } , "Atualizando - AGUARDE") } ,40,12,,,,.T.)
Else
	oSayTip := tSay():New(077,nfdp-293,{|| "Ped.Compras:"   },oGrpMV,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)//A103F4()
	oGetNom := tGet():New(077,nfdp-293,{|u| if(PCount()>0,aCmps[23]:=u,aCmps[23])}, oGrpMV,030,9,'@!', { ||  },,,,,,.T.,,, { ||  } ,,, ,.F.,,'PEDXML','aCmps[23]')
	oBtnAtu := tButton():New(077,590,'Atualizar'   , oDlgTit, {|| Processa({ || atuPed(.t.) } , "Atualizando - AGUARDE") } ,40,12,,,,.T.)
	
EndIF


montah()

oGetD := MsGetDados():New(105,005,200,640,4,"U_AFT01LOk()","","",.F.,aCpoAlt,,,,"u_CARREGAD1()")

oGrpTotx:= TGroup():New(230,005,285,325,'Total NFE',oDlgTit,CLR_HBLUE,,.T.)

oSayTip := tSay():New(240,007,{|| "Valor Mercadoria"   },oGrpTotx,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetNom := tGet():New(240,055,{|u| if(PCount()>0,aCmps[7]:=u,aCmps[7])}, oGrpTotx,050,9,'@e 999,999,999.99', { ||  },,,,,,.T.,,, { || .F. } ,,,,.F.,,,'aCmps[7]')

oSaychv := tSay():New(270,007,{|| "Chave NFE"   },oGrpTotx,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetCHV := tGet():New(270,055,{|u| if(PCount()>0,aCmps[21]:=u,aCmps[21])}, oGrpTotx,150,9,'@e 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 ', { ||  },,,,,,.T.,,, { || .F. } ,,,,.F.,,,'aCmps[21]')

oSayTip := tSay():New(255,007,{|| "Valor Frete"   },oGrpTotx,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetNom := tGet():New(255,055,{|u| if(PCount()>0,aCmps[8]:=u,aCmps[8])}, oGrpTotx,050,9,'@e 999,999,999.99', { ||  },,,,,,.T.,,, { || .F. } ,,,,.F.,,,'aCmps[8]')
nDis:=105
oSayTip := tSay():New(240,007+nDis,{|| "Valor Descontos"   },oGrpTotx,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetNom := tGet():New(240,055+nDis,{|u| if(PCount()>0,aCmps[9]:=u,aCmps[9])}, oGrpTotx,050,9,'@e 999,999,999.99', { ||  },,,,,,.T.,,, { || .F. } ,,,,.F.,,,'aCmps[9]')

oSayTip := tSay():New(255,007+nDis,{|| "Valor Despesas"   },oGrpTotx,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetNom := tGet():New(255,055+nDis,{|u| if(PCount()>0,aCmps[10]:=u,aCmps[10])}, oGrpTotx,050,9,'@e 999,999,999.99', { ||  },,,,,,.T.,,, { || .F. } ,,,,.F.,,,'aCmps[10]')
SetKey(VK_F4, {|| PEDPROD()})
nDis+=nDis

oSayTip := tSay():New(240,007+nDis,{|| "Valor IPI"   },oGrpTotx,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetNom := tGet():New(240,055+nDis,{|u| if(PCount()>0,aCmps[11]:=u,aCmps[11])}, oGrpTotx,050,9,'@e 999,999,999.99', { ||  },,,,,,.T.,,, { || .F. } ,,,,.F.,,,'aCmps[11]')

oSayTip := tSay():New(255,007+nDis,{|| "Valor Total"   },oGrpTotx,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetNom := tGet():New(255,055+nDis,{|u| if(PCount()>0,aCmps[12]:=u,aCmps[12])}, oGrpTotx,050,9,'@e 999,999,999.99', { ||  },,,,,,.T.,,, { || .F. } ,,,,.F.,,,'aCmps[12]')


oGrpTotx:= TGroup():New(230,325,255,640,'Total Calculado',oDlgTit,CLR_HBLUE,,.T.)

nDis:=320
oSayTip := tSay():New(240,007+nDis,{|| "Valor Mercadoria"   },oGrpTotx,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetNom := tGet():New(240,055+nDis,{|u| if(PCount()>0,aCmps[13]:=u,aCmps[13])}, oGrpTotx,050,9,'@e 999,999,999.99', { ||  },,,,,,.T.,,, { || .F. } ,,,,.F.,,,'aCmps[13]')

oSayTip := tSay():New(255,007+nDis,{|| "Valor Frete"   },oGrpTotx,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetNom := tGet():New(255,055+nDis,{|u| if(PCount()>0,aCmps[14]:=u,aCmps[14])}, oGrpTotx,050,9,'@e 999,999,999.99', { ||  },,,,,,.T.,,, { || .F. } ,,,,.F.,,,'aCmps[14]')
nDis+=105
oSayTip := tSay():New(240,007+nDis,{|| "Valor Descontos"   },oGrpTotx,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetNom := tGet():New(240,055+nDis,{|u| if(PCount()>0,aCmps[15]:=u,aCmps[15])}, oGrpTotx,050,9,'@e 999,999,999.99', { ||  },,,,,,.T.,,, { || .F. } ,,,,.F.,,,'aCmps[15]')

oSayTip := tSay():New(255,007+nDis,{|| "Valor Despesas"   },oGrpTotx,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetNom := tGet():New(255,055+nDis,{|u| if(PCount()>0,aCmps[16]:=u,aCmps[16])}, oGrpTotx,050,9,'@e 999,999,999.99', { ||  },,,,,,.T.,,, { || .F. } ,,,,.F.,,,'aCmps[16]')

nDis+=105

oSayTip := tSay():New(240,007+nDis,{|| "Valor IPI"   },oGrpTotx,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetNom := tGet():New(240,055+nDis,{|u| if(PCount()>0,aCmps[17]:=u,aCmps[17])}, oGrpTotx,050,9,'@e 999,999,999.99', { ||  },,,,,,.T.,,, { || .F. } ,,,,.F.,,,'aCmps[17]')

oSayTip := tSay():New(255,007+nDis,{|| "Valor Total"   },oGrpTotx,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetNom := tGet():New(255,055+nDis,{|u| if(PCount()>0,aCmps[18]:=u,aCmps[18])}, oGrpTotx,050,9,'@e 999,999,999.99', { ||  },,,,,,.T.,,, { || .F. } ,,,,.F.,,,'aCmps[18]')


if nTipo==1
	oBtnMail := tButton():New(290,310,'Doc.Entrada'   , oDlgTit, {|| Processa({ || GERARNF(oXml) } , "[AFIN003] - AGUARDE") } ,40,12,,,,.T.)
ElseIF nTipo== 2
	oBtnMail := tButton():New(290,310,'Pre-Nota'   , oDlgTit, {|| Processa({ || GERARNF(oXml) } , "[AFIN003] - AGUARDE") } ,40,12,,,,.T.)
EndIF
oBtnSair := tButton():New(290,355,'Sair'     , oDlgTit, {|| oDlgTit:End() },40,12,,,,.T.)

ACTIVATE MSDIALOG oDlgTit CENTERED

cEmpAnt := cEmpKPZ
cFilAnt := cFilKPZ
Return



Static Function fBuscaDados(oXml)

Local _lValida := .F.
Local cError   := ""
Local cWarning := ""
Local cFile:= aCmps[2]
Local cSAVEmp
Local aFil
Local nI
Private aProd
Private _oXml  
Private Ldev:=.F.
Private nRecSA2
oXml  	:= XmlParser (  EncodeUTF8(strtran(TiraGraf(FwNoAccent(C00->C00_RSXML)),chr(13)+chr(10),'')), "_", @cError,  @cWarning ) //XmlParserFile( cFile, "_", @cError, @cWarning )	//acessando o CONTEUDO do meu nodo ""
_oXml:=oXml
if type('_oXml:_nfe:_INFNFE:_IDE')<>"U"
	PRIVATE CIDE:=oXml:_nfe:_INFNFE:_IDE
	PRIVATE ONF:=oXml:_nfe      
	Private Ldev:=if("DEVOLUCAO" $_oXml:_nfeproc:_nfe:_INFNFE:_IDE:_NATOP:TEXT ,.T.,.F.)
ElseIf C00->C00_CTE=='S'
	PRIVATE CIDE:=oXml:_CTEPROC:_CTE:_INFCTE:_IDE
ElseIf type('_oXml:_nfeproc:_nfe:_INFNFE:_IDE:_NNF:TEXT')<>"U"
	PRIVATE CIDE:=oXml:_nfeproc:_nfe:_INFNFE:_IDE
	PRIVATE ONF:=oXml:_nfeproc:_nfe    
	Private Ldev:=if("DEVOLUCAO" $_oXml:_nfeproc:_nfe:_INFNFE:_IDE:_NATOP:TEXT ,.T.,.F.)
Endif
iF C00->C00_CTE<>'S'
	cNota 	:= padl(CIDE:_NNF:TEXT,tamsx3('F1_DOC')[1],'0')
	cChaveNf 	:= padl(C00->C00_CHVNFE,tamsx3('F1_CHVNFE')[1],'0')

//alterado em 08/04/2019 [akira]	
/*	cEmpt:=SM0->M0_CODIGO
	dbSelectArea('SM0')
	DBGotop()
	DBSEEK(cEmpt)
	LTEM:=.F.
	while !SM0->(EOF()) .AND. SM0->M0_CODIGO == cEmpt
		if SM0->M0_CGC == ONF:_INFNFE:_DEST:_CNPJ:TEXT
			LTEM:=.T.
			cFilant:=SM0->M0_CODFIL 
			cEmpt:=SM0->M0_CODIGO
		eNDIf
		SM0->(DBSKIP())
	EnddO
 
	dbSelectArea('SM0')
	DBGotop()
	DBSeek(cEmpt+cFilant)
*/	
	//alterado em 08/074/2019
	cSavEmp := cEmpAnt
	sSavFil := cFilAnt
	cEmpt := SM0->M0_CODIGO
	SM0->(DbSeek((cEmpt)))
	lTem := .F.
	while !SM0->(EOF()) .AND. SM0->M0_CODIGO == cEmpt
		if SM0->M0_CGC == ONF:_INFNFE:_DEST:_CNPJ:TEXT
			lTem := .T.
			cFilant := SM0->M0_CODFIL
			EXIT 
		EndIf
		SM0->(DbSkip())
	End
 
	//ate aqui - em 08/04/2019
 	
	iF !LTEM
		AVISO("NFE nao Importada!","Destinatario da nota informada!",{"OK"})
		SM0->(DbSeek((cSavEmp+cSavFil))) //em 048/04/2019
		return
	EndIF
	
	
	
	aCmps[6]:= cNota
	aCmps[21]:= cChaveNf
	IF !Ldev
		cSql:=" SELECT R_E_C_N_O_ REC FROM "+RETSQLNAME('SA2')
		cSql+=" WHERE A2_CGC ='"+onf:_INFNFE:_EMIT:_CNPJ:TEXT+"'"
		cSql+=" AND D_E_L_E_T_<>'*'"
		cSql+=" AND A2_MSBLQL <>'1'
		IF Select('TRA2')<>0
			TRA2->(DBCloseArea())
		EndIF
		TcQuery cSql New Alias 'TRA2'
		
		IF !TRA2->(EOF())
			//posiciona no forneecdor
			DBSelectArea('SA2')
			DBGoto(TRA2->REC)
		Else
			aviso('Nao Cadastrado',"O Fornecedor "+alltrim(ONF:_INFNFE:_EMIT:_XNOME:TEXT)+" nao cadastrado",{"OK"})
		EndIF
		
		aCmps[3]:=SA2->A2_COD
		aCmps[4]:=SA2->A2_LOJA
		aCmps[5]:=SA2->A2_NOME
		nRecSA2:=SA2->(RECNO())
	Else
	cSql:=" SELECT R_E_C_N_O_ REC FROM "+RETSQLNAME('SA1')
		cSql+=" WHERE A1_CGC ='"+onf:_INFNFE:_EMIT:_CNPJ:TEXT+"'"
		cSql+=" AND D_E_L_E_T_<>'*'"
		cSql+=" AND A1_MSBLQL <>'1'
		IF Select('TRA2')<>0
			TRA2->(DBCloseArea())
		EndIF
		TcQuery cSql New Alias 'TRA2'
		
		IF !TRA2->(EOF())
			//posiciona no forneecdor
			DBSelectArea('SA1')
			DBGoto(TRA2->REC)
		Else
			aviso('Nao Cadastrado',"O Cliente "+alltrim(ONF:_INFNFE:_EMIT:_XNOME:TEXT)+" nao cadastrado",{"OK"})
		EndIF
		
		aCmps[3]:=SA1->A1_COD
		aCmps[4]:=SA1->A1_LOJA
		aCmps[5]:=SA1->A1_NOME
		nRecSA2:=SA1->(RECNO())
	
	EndiF	
	aCmps[7]	:= VAL(ONF:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:TEXT)
	aCmps[8]	:= VAL(ONF:_INFNFE:_TOTAL:_ICMSTOT:_VFRETE:TEXT)
	aCmps[9]	:= VAL(ONF:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:TEXT  )
	aCmps[10]	:= VAL(ONF:_INFNFE:_TOTAL:_ICMSTOT:_VOUTRO:TEXT  )
	aCmps[11]	:= VAL(ONF:_INFNFE:_TOTAL:_ICMSTOT:_VIPI:TEXT     )
	aCmps[12]	:= VAL(ONF:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT  )
	
	
	
	
	aProd:=ONF:_INFNFE:_DET
	if type('aProd')<>"A"
		aProd:={ONF:_INFNFE:_DET}
	EndIF
	aCOls   := {}
	
	FOR nI:=1 to len(aProd)
		
		if !Empty(alltrim(aProd[nI]:_PROD:_CPROD:TEXT))
			//FUNCAO PARA BUSCAR AMARRACAO PROD x FORNECEDOR\
			cProd := IF(LDEV,"",BUSCAPROD(aProd[nI]:_PROD:_CPROD:TEXT))
			
			nIpi:=0.00
			nAipi:=0.00
			if Type("aProd[nI]:_IMPOSTO:_IPI:_ipitrib:_vipi:text")=="C"
				nIpi:=val(aProd[nI]:_IMPOSTO:_IPI:_ipitrib:_vipi:text)
			EndIF
			if Type("aProd[nI]:_IMPOSTO:_IPI:_ipitrib:_pipi:text")=="C"
				nAipi:=val(aProd[nI]:_IMPOSTO:_IPI:_ipitrib:_pipi:text)
			EndIF
			
			cFci:=space(tamsx3("D1_FCICOD")[1])
			if Type("aProd[nI]:_PROD:_NFCI:TEXT")=="C"
				cFci:=aProd[nI]:_PROD:_NFCI:TEXT
			EndIF
			infAdProd:=""
			if Type("aProd[nI]:_infAdProd:TEXT")=="C"
				infAdProd:=aProd[nI]:_infAdProd:TEXT
			EndIF
			dbSelectArea('SAH')
			dbSetOrder(1)
			if dbseek(xFilial('SAH')+aProd[nI]:_PROD:_UCOM:TEXT)
				CUM:=SAH->AH_UNIMED
			Else
				CUM:=POSICIONE('SB1',1,Xfilial('SB1')+cProd,'B1_UM')
			EndiF
			
			_oXml:=oxml
			if Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS90:_VICMS:TEXT")<>"U"
				nVicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS90:_VICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS00:_VICMS:TEXT")<>"U"
				nVicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS00:_VICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS10:_VICMS:TEXT")<>"U"
				nVicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS10:_VICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS20:_VICMS:TEXT")<>"U"
				nVicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS20:_VICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS30:_VICMS:TEXT")<>"U"
				nVicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS30:_VICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS40:_VICMS:TEXT")<>"U"
				nVicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS40:_VICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS50:_VICMS:TEXT")<>"U"
				nVicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS50:_VICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS60:_VICMS:TEXT")<>"U"
				nVicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS60:_VICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS70:_VICMS:TEXT")<>"U"
				nVicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS70:_VICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS80:_VICMS:TEXT")<>"U"
				nVicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS80:_VICMS:TEXT)
			Else
				nVicm:=0
			EndIF
			
			if Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS90:_VBC:TEXT")<>"U"
				nBCcm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS90:_VBC:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS00:_VBC:TEXT")<>"U"
				nBCcm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS00:_VBC:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS10:_VBC:TEXT")<>"U"
				nBCcm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS10:_VBC:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS20:_VBC:TEXT")<>"U"
				nBCcm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS20:_VBC:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS30:_VBC:TEXT")<>"U"
				nBCcm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS30:_VBC:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS40:_VBC:TEXT")<>"U"
				nBCcm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS40:_VBC:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS50:_VBC:TEXT")<>"U"
				nBCcm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS50:_VBC:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS60:_VBC:TEXT")<>"U"
				nBCcm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS60:_VBC:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS70:_VBC:TEXT")<>"U"
				nBCcm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS70:_VBC:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS80:_VBC:TEXT")<>"U"
				nBCcm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS80:_VBC:TEXT)
			eLSE
				nBCcm:=0
			EndIF
			
			if Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS90:_PICMS:TEXT")<>"U"
				nPicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS90:_PICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT")<>"U"
				nPicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT")<>"U"
				nPicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS10:_PICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS20:_PICMS:TEXT")<>"U"
				nPicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS20:_PICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS30:_PICMS:TEXT")<>"U"
				nPicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS30:_PICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS40:_PICMS:TEXT")<>"U"
				nPicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS40:_PICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS50:_PICMS:TEXT")<>"U"
				nPicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS50:_PICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS60:_PICMS:TEXT")<>"U"
				nPicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS60:_PICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS70:_PICMS:TEXT")<>"U"
				nPicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS70:_PICMS:TEXT)
			ElseIf Type("aProd[nI]:_IMPOSTO:_ICMS:_ICMS80:_PICMS:TEXT")<>"U"
				nPicm:=VAL(aProd[nI]:_IMPOSTO:_ICMS:_ICMS80:_PICMS:TEXT)
			ELSE
				nPicm :=0
			EndIF
			
			IF NTIPO == 1  .or. NTIPO == 3
				//		aCmp:={'D1_ITEM','A5_CODPRF','D1_COD','D1_DESCRI','D1_UM','D1_QUANT','D1_VUNIT','D1_TOTAL','D1_PEDIDO','D1_ITEMPC','D1_OPER','D1_TES','D1_VALIPI','D1_IPI','D1_BASEICM','D1_PICM','D1_VALICM','D1_FCICOD','D1_CONIMP','F1_MENNOTA','D1_NCM'}
				
				AADD(Acols,{PADL(aProd[nI]:_NITEM:TEXT,TAMSX3('D1_ITEM')[1],'0')  ,;
				PADR(aProd[nI]:_PROD:_CPROD:TEXT,TAMSX3('A5_CODPRF')[1],'')  		,;
				PADR(cProd,TAMSX3('D1_COD')[1],'')  		,;
				aProd[nI]:_PROD:_xPROD:TEXT  		,;
				CUM 			,;
				POSICIONE('SB1',1,XFILIAL('SB1')+cProd,'B1_LOCPAD'),;
				VAL(aProd[nI]:_PROD:_QCOM:TEXT)  	,;
				VAL(aProd[nI]:_PROD:_VUNCOM:TEXT)	,;
				VAL(aProd[nI]:_PROD:_VPROD:TEXT)   ,;
				SPACE(tamsx3('D1_PEDIDO')[1]),;
				SPACE(tamsx3('D1_ITEMPC')[1]),;
				SPACE(tamsx3('D1_OPER')[1]),;
				SPACE(tamsx3('C8_TES')[1]),;
				nIpi,;
				nAipi,;
				nBCcm,;
				nPicm,;
				nVicm,;
				cFci,;
				0.00,;
				infAdProd,;
				aProd[nI]:_PROD:_NCM:TEXT,;
				,.f. } ) //nIpi
			Else
				//	aCmp:={'D1_ITEM','A5_CODPRF','D1_COD','D1_DESCRI','D1_UM','D1_QUANT','D1_VUNIT','D1_TOTAL','D1_FCICOD','D1_CONIMP','F1_MENNOTA','D1_IPI','D1_NCM'}
				AADD(Acols,{PADL(aProd[nI]:_NITEM:TEXT,TAMSX3('D1_ITEM')[1],'0')  ,;
				PADR(aProd[nI]:_PROD:_CPROD:TEXT,TAMSX3('A5_CODPRF')[1],'')  		,;
				PADR(cProd,TAMSX3('D1_COD')[1],'')  		,;
				aProd[nI]:_PROD:_xPROD:TEXT  		,;
				CUM 			,;
				POSICIONE('SB1',1,XFILIAL('SB1')+cProd,'B1_LOCPAD'),;
				VAL(aProd[nI]:_PROD:_QCOM:TEXT)  	,;
				VAL(aProd[nI]:_PROD:_VUNCOM:TEXT)	,;
				VAL(aProd[nI]:_PROD:_VPROD:TEXT)   ,;
				SPACE(tamsx3('D1_PEDIDO')[1]),;
				SPACE(tamsx3('D1_ITEMPC')[1]),;
				cFci,;
				0.00,;
				infAdProd,;
				nAipi,;
				aProd[nI]:_PROD:_NCM:TEXT,;
				.f. } )
			EndIF
		EndIF
	Next
Else
	
	cNota 		:= padl(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:TEXT,tamsx3('F1_DOC')[1],'0')
	cChaveNf 	:= padl(C00->C00_CHVNFE,tamsx3('F1_CHVNFE')[1],'0')
	
	
	aCmps[6]:= cNota
	aCmps[21]:= cChaveNf
	lFOr:=.t.
	
	cSql:=" SELECT R_E_C_N_O_ REC FROM "+RETSQLNAME('SA2')
	cSql+=" WHERE A2_CGC ='"+oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT+"'"
	cSql+=" AND D_E_L_E_T_<>'*'"
	cSql+=" AND A2_MSBLQL <>'1'
	IF Select('TRA2')<>0
		TRA2->(DBCloseArea())
	EndIF
	TcQuery cSql New Alias 'TRA2'
	
	IF !TRA2->(EOF())
		//posiciona no forneecdor
		DBSelectArea('SA2')
		DBGoto(TRA2->REC)
	Else
		aviso('Nao Cadastrado',"fornecedor"+alltrim(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_XNOME:TEXT)+" nao cadastrado",{"OK"})
		//	return
		lFOr:=.f.
	EndIF
	aCmps[3]:=if(lfor,SA2->A2_COD,'')
	aCmps[4]:=if(lfor,SA2->A2_LOJA,'')
	aCmps[5]:=if(lfor,SA2->A2_NOME,alltrim(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_XNOME:TEXT))
	nRecSA2:=if(lfor,SA2->(RECNO()),0)
	
	aCOls   := {}
	aCmps[7]	:= VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VREC:TEXT) +	IIF(Type("oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_VTOTTRIB:TEXT")=="U",0,VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VREC:TEXT))
	aCmps[12]:=aCmps[7]
	
	IF NTIPO == 1  .or. NTIPO == 3
		_oXml:=oxml
		if Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_VICMS:TEXT")<>"U"
			nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_VICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT")<>"U"
			nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS10:_VICMS:TEXT")<>"U"
			nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS10:_VICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_VICMS:TEXT")<>"U"
			nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_VICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS30:_VICMS:TEXT")<>"U"
			nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS30:_VICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS40:_VICMS:TEXT")<>"U"
			nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS40:_VICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS50:_VICMS:TEXT")<>"U"
			nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS50:_VICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_VICMS:TEXT")<>"U"
			nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_VICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS70:_VICMS:TEXT")<>"U"
			nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS70:_VICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS80:_VICMS:TEXT")<>"U"
			nVicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS80:_VICMS:TEXT)
		Else
			nVicm:=0
		EndIF
		
		if Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_VBC:TEXT")<>"U"
			nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_VBC:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT")<>"U"
			nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS10:_VBC:TEXT")<>"U"
			nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS10:_VBC:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_VBC:TEXT")<>"U"
			nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_VBC:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS30:_VBC:TEXT")<>"U"
			nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS30:_VBC:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS40:_VBC:TEXT")<>"U"
			nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS40:_VBC:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS50:_VBC:TEXT")<>"U"
			nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS50:_VBC:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_VBC:TEXT")<>"U"
			nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_VBC:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS70:_VBC:TEXT")<>"U"
			nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS70:_VBC:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS80:_VBC:TEXT")<>"U"
			nBCcm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS80:_VBC:TEXT)
		eLSE
			nBCcm:=0
		EndIF
		
		if Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_PICMS:TEXT")<>"U"
			nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_PICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_PICMS:TEXT")<>"U"
			nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_PICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS10:_PICMS:TEXT")<>"U"
			nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS10:_PICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_PICMS:TEXT")<>"U"
			nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_PICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS30:_PICMS:TEXT")<>"U"
			nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS30:_PICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS40:_PICMS:TEXT")<>"U"
			nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS40:_PICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS50:_PICMS:TEXT")<>"U"
			nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS50:_PICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_PICMS:TEXT")<>"U"
			nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_PICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS70:_PICMS:TEXT")<>"U"
			nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS70:_PICMS:TEXT)
		ElseIf Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS80:_PICMS:TEXT")<>"U"
			nPicm:=VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS80:_PICMS:TEXT)
		ELSE
			nPicm :=0
		EndIF
		
		
		//	aCmp:={'D1_ITEM','A5_CODPRF','D1_COD','D1_DESCRI','D1_UM','D1_QUANT','D1_VUNIT','D1_TOTAL','D1_OPER','D1_TES','D1_PEDIDO','D1_VALIPI','D1_IPI','D1_BASEICM','D1_PICM','D1_VALICM','D1_FCICOD','D1_CONIMP','F1_MENNOTA','D1_NCM'}
		AADD(Acols,{PADL('1',TAMSX3('D1_ITEM')[1],'0')  ,;
		PADR(IIF(Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_VTOTTRIB:TEXT")=="U",'FRETE1','FRETE'),TAMSX3('D1_COD')[1])  		,;
		PADR(IIF(Type("_oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_VTOTTRIB:TEXT")=="U",'FRETE1','FRETE') ,TAMSX3('D1_COD')[1])  		,;
		'FRETE'  		,;
		'UN'  			,;
		'01',;
		1  	,;
		VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VREC:TEXT)	,;
		VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VREC:TEXT)   ,;
		SPACE(tamsx3('D1_PEDIDO')[1]),;
		SPACE(tamsx3('D1_ITEMPC')[1]),;
		SPACE(tamsx3('D1_OPER')[1]),;
		SPACE(tamsx3('D1_TES')[1]),;
		0,;
		0,;
		nBCcm,;//D1_BASEICM
		nPicm,;//D1_PICM
		nVicm,;// D1_VALICM
		"",;
		0,;
		"",;
		"",;
		,.f. } ) //nIpi
	Else
		//aCpoAlt :={'D1_ITEM','A5_CODPRF','D1_COD','D1_DESCRI','D1_UM','D1_QUANT','D1_VUNIT','D1_TOTAL','D1_PEDIDO','D1_FCICOD','D1_CONIMP','F1_MENNOTA','D1_IPI'}
		
		
		AADD(Acols,{PADL('1',TAMSX3('D1_ITEM')[1],'0')  ,;
		PADR(IIF(Type("oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_VTOTTRIB:TEXT")=='U','FRETE1',IIF(VAL(oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_VTOTTRIB:TEXT)==0,'FRETE1','FRETE')),TAMSX3('D1_COD')[1])  		,;
		PADR(IIF(Type("oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_VTOTTRIB:TEXT")=="U",'FRETE1','FRETE'),TAMSX3('D1_COD')[1])  		,;
		'FRETE'  		,;
		'UN'  			,;
		'01',;
		1  	,;
		VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VREC:TEXT)	,;
		VAL(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VREC:TEXT)   ,;
		SPACE(tamsx3('D1_PEDIDO')[1]),;
		SPACE(tamsx3('D1_ITEMPC')[1]),;
		0,;
		0,;
		"",;
		0,;
		,.f. } )
	EndIF
	
	
EndIF

return



Static Function montah()
Local nx

aHeader:={}
nUsado := 1
/*
D1_NCM
D1_BRICMS
D1_ICMSRET
D1_ALIQSOL
D1_VALICM
D1_ALIQICM
D1_CF
D1_PICM
D1_CLASFIS
*/
if nTipo==1 .or.  nTipo==3
	aCmp:={'D1_ITEM','A5_CODPRF','D1_COD','D1_DESCRI','D1_UM','D1_LOCAL','D1_QUANT','D1_VUNIT','D1_TOTAL','D1_PEDIDO','D1_ITEMPC','D1_OPER','D1_TES','D1_VALIPI','D1_IPI','D1_BASEICM','D1_PICM','D1_VALICM','D1_FCICOD','D1_CONIMP','F1_MENNOTA','D1_NCM'}
Elseif nTipo==2
	aCmp:={'D1_ITEM','A5_CODPRF','D1_COD','D1_DESCRI','D1_UM','D1_LOCAL','D1_QUANT','D1_VUNIT','D1_TOTAL','D1_PEDIDO','D1_ITEMPC','D1_FCICOD','D1_CONIMP','F1_MENNOTA','D1_IPI','D1_NCM'}
EndIF
For nx:=1 to len(aCmp)
	DBSelectArea('SX3')
	DBSetOrder(2)
	iF DBSeek(aCmp[nx])
		nUsado:=nUsado+1
		AADD(aHeader,{X3Titulo(),SX3->X3_CAMPO,;
		SX3->X3_PICTURE,;
		Iif(aCmp[nx]$'F1_MENNOTA',200,SX3->X3_TAMANHO),;
		SX3->X3_DECIMAL,;
		Iif(aCmp[nx]$'D1_COD'.or.aCmp[nx]$'D1_PEDIDO',"",SX3->X3_VALID),;
		SX3->X3_USADO,;
		SX3->X3_TIPO,;
		Iif(aCmp[nx]$'D1_PEDIDO',"PEDXML",SX3->X3_F3),;
		Iif(aCmp[nx]$'D1_PEDIDO',"A",SX3->X3_CONTEXT)})
	EndIf
Next


Return


Static Function LoadCols()

Local aLin:={}
Local cNumero
Local i


//Monta aCols da GetDados.
For i := 1 To Len(aHeader)
	AADD(aLin,CriaVar(aHeader[i][2]))
Next
AADD(aLin,.F.)
//AADD(aCols,aClone(aLin))

Return


Static Function BUSCAPROD(cProdFOr)

DBSelectArea('SA2')
DBGoto(nRecSA2)

cRet:=""
cSql:=" SELECT * FROM "+RetSqlName('SA5')+" "
cSql+=" WHERE A5_FORNECE ='"+SA2->A2_COD+"'"
cSql+=" AND A5_LOJA='"+SA2->A2_LOJA+"'"
cSql+=" AND A5_CODPRF ='"+cProdFOr+"'"
If Select('TRB1') <> 0
	TRB1->(DBCLOSEAREA())
EndIF

TcQuery cSql New Alias "TRB1"

IF !TRB1->(eof())
	cRet:=TRB1->A5_PRODUTO
EndIF


return cRet

User Function AFT01LOk()
Local lret:=.t.

nPosPrd:=aScan(aHeader,{|x| alltrim(x[2]) =='D1_COD'})
IF Empty(aCols[n][nPosPrd])
	alert('Preencher o Codigo do Produto!')
	lret:=.F.
EndIF

Return lret

Static Function GERARNF(oXml)
Local nA
Local nB


Local _lValida := .F.
Local cError   := ""
Local cWarning := ""
Local cFile:= aCmps[2]
Local IH

Local cCentroC := Alltrim( SuperGetMV("KP_CCKPCTE"	,.F. ,"490050001"))

Private aProd

oXml  	:= XmlParser ( TiraGraf(C00->C00_RSXML), "_", @cError,  @cWarning )//XmlParserFile( cFile, "_", @cError, @cWarning )	//acessando o CONTEUDO do meu nodo ""
_oxml:=oxml
LCTE:=.F.
cNota 	:= C00->C00_NUMNFE
if type('_oXml:_CTEPROC')<>'U'
	dEmis:=stod(STRTRAN(SUBSTR(_oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT,1,10),'-',''))
	LCTE:=.T.
EndiF

if TYPE('_oXml:_NFE:_INFNFE:_IDE:_DEMI:TEXT')<>'U'
	dEmis:=stod(STRTRAN(SUBSTR(_oXml:_NFE:_INFNFE:_IDE:_DEMI:TEXT,1,10),'-',''))
	Ldev:=if("DEVOLUCAO" $_oXml:_nfeproc:_nfe:_INFNFE:_IDE:_NATOP:TEXT ,.T.,.F.)
eLSEIF TYPE('_oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT') <>'U'
	dEmis:=STOD(STRTRAN(SUBSTR(_oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT,1,10),'-','')) 
	Ldev:=if("DEVOLUCAO" $_oXml:_nfeproc:_nfe:_INFNFE:_IDE:_NATOP:TEXT ,.T.,.F.)
ENDIF
ddtAUx:=dDataBase
if nTipo==1
	aCab := {{"F1_FILIAL" 	,XfILIAL('SF1')  										,NIL,Nil},;
	{"F1_TIPO" 	,"N"  										,NIL,Nil},;
	{"F1_FORMUL","N"              									,Nil,Nil},;
	{"F1_DOC"           ,C00->C00_NUMNFE        		,Nil,Nil},;
	{"F1_SERIE"        	,C00->C00_SERNFE      			,Nil,Nil},;
	{"F1_EMISSAO"       ,if(empty(dEmis),ddatabase,dEmis),Nil,Nil},;
	{"F1_FORNECE"       ,SA2->A2_COD       					,Nil,Nil},;
	{"F1_LOJA"          ,SA2->A2_LOJA             	,Nil,Nil},;
	{"F1_COND"         ,aCmps[20]             			,Nil,Nil},;
	{"F1_CHVNFE"       ,C00->C00_CHVNFE							,Nil,Nil},;
	{"E2_NATUREZ"       ,aCmps[22]									,Nil,Nil},;
	{"F1_ESPECIE"       ,IF(LCTE,'CTE',"SPED")             				,Nil,Nil}}
ElseIf nTipo==2
	aCab := {{"F1_TIPO" 	,IF(Ldev,"D","N")										,NIL,Nil},;
	{"F1_FORMUL","N"              									,Nil,Nil},;
	{"F1_DOC"           ,C00->C00_NUMNFE       			,Nil,Nil},;
	{"F1_SERIE"        	,C00->C00_SERNFE       		,Nil,Nil},;
	{"F1_EMISSAO"       ,if(empty(C00->C00_DTEMI),ddatabase,C00->C00_DTEMI)        		,Nil,Nil},;
	{"F1_FORNECE"       ,aCmps[3]       					,Nil,Nil},;
	{"F1_LOJA"          ,aCmps[4]             	,Nil,Nil},;
	{"F1_CHVNFE"       ,C00->C00_CHVNFE							,Nil,Nil},;
	{"F1_ESPECIE"       ,IF(LCTE,'CTE',"SPED")      ,Nil,Nil}}
EndIF

aItem:={}


for nA:=1 to len(aCols)
	aItemPC:={}
	IF !Ldev
		//INCSA5Nw( aCols[nA][aScan(aHeader, {|x| ALLTRIM(x[2])=='A5_CODPRF'} )] , aCols[nA][aScan(aHeader, {|x| ALLTRIM(x[2])=='D1_COD'} )])
		gravaa5(aCols[nA][aScan(aHeader, {|x| ALLTRIM(x[2])=='A5_CODPRF'} )],aCols[nA][aScan(aHeader, {|x| ALLTRIM(x[2])=='D1_COD'} )])
	EndIF
	aadd(aItemPC,	{'D1_FILIAL',XFILIAL('SD1'),NIL})
	for nB:=1 to len(aHeader)
		if !alltrim(AHEADER[nB,2]) $ 'A5_CODPRF|F1_MENNOTA'
			if alltrim(AHEADER[nB,2])  $ 'D1_TES'
					aadd(aItemPC,	{'D1_TES',aCols[nA][nB],NIL})
				Elseif alltrim(AHEADER[nB,2])  $ 'D1_PEDIDO' .AND. eMPTY(aCols[nA][nB])
					//aadd(aItemPC,	{'D1_PEDIDO',aCols[nA][nB],NIL})
					
				Elseif alltrim(AHEADER[nB,2])  == 'D1_ITEMPC' .AND. eMPTY(aCols[nA][nB])
					//aadd(aItemPC,	{'D1_ITEMPC',aCols[nA][nB],NIL})
				Elseif alltrim(AHEADER[nB,2])  == 'D1_COD'
					aadd(aItemPC,	{AHEADER[nB,2],PADR(aCols[nA][nB],TAMSX3('D1_COD')[1]),NIL})
				elseif alltrim(AHEADER[nB,2])  == 'D1_PEDIDO'
					aadd(aItemPC,	{'D1_FORNECE',cA100For,NIL})
					aadd(aItemPC,	{'D1_LOJA',cLoja,NIL})
					aadd(aItemPC,	{AHEADER[nB,2],aCols[nA][nB],"!vazio()"})
				elseif alltrim(AHEADER[nB,2])  == 'D1_ITEMPC'
					aadd(aItemPC,	{AHEADER[nB,2],aCols[nA][nB],"!vazio()"})
				
				Elseif alltrim(AHEADER[nB,2])  == 'D1_CC'
					aadd(aItemPC,	{'D1_CC',cCentroC,NIL})

				Else
					aadd(aItemPC,	{AHEADER[nB,2],aCols[nA][nB],NIL})
			EndIF
		EndIF
	Next
	
	AADD(aItem,aClone(aItemPC))
Next
lMsErroAuto := .F.

if nTipo == 1 //documento de entrada
	MSExecAuto({ |x,y,z| Mata103(x,y,z)},aCab,aItem,3)
ElseIf nTipo == 2//pre-nota//
	MSExecAuto({|x,y,z| MATA140(x,y,z)},aCab,aItem,3)
EndIF

If lMsErroAuto
	//	DisarmTransaction()
	Mostraerro()
	
	
	NITE:=00
	DBSelectArea('SE2')
	DBSETORDER(6)
	AJAFOI:={}
	//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
	if DBSeek(xFilial('SE2')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC )
		WHILE !SE2->(EOF()) .AND. SF1->F1_FILIAL+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC == SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM)
			FOR IH:= 1 TO LEN(aParcelas)
				if aParcelas[IH][1]==SE2->E2_PARCELA
					IF ASCAN(AJAFOI,SE2->E2_PARCELA)==0
						REClock('SE2',.F.)
						SE2->E2_VENCTO:=aParcelas[IH][2]
						SE2->E2_VENCREA:=DATAVALIDA(aParcelas[IH][2])
						MSUNLOCK()
						AADD(AJAFOI,SE2->E2_PARCELA)
						
					ENDIF
				EndIf
				if aParcelas[IH][1]=='01' .and. empty(SE2->E2_PARCELA)
					IF ASCAN(AJAFOI,SE2->E2_PARCELA)==0
						REClock('SE2',.F.)
						SE2->E2_VENCTO:=aParcelas[IH][2]
						SE2->E2_VENCREA:=DATAVALIDA(aParcelas[IH][2])
						MSUNLOCK()
						AADD(AJAFOI,SE2->E2_PARCELA)
						
					ENDIF
				EndIf
				
			Next
			
			NITE++
			SE2->(DBsKIP())
		EndDo
	EndIF
	
	oDlgTit:end()
Else 

dDataBase:=ddtAUx

	RECLOCK('C00',.F.)
	C00->C00_JAIMP:='S'
	MSUNLOCK()
	aCaminho:={}
	aCaminho:=StrTokArr(cFile,"\")
	
	NITE:=00
	DBSelectArea('SE2')
	DBSETORDER(6)
	AJAFOI:={}
	//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
	DBSeek(xFilial('SE2')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC )
	WHILE !SE2->(EOF()) .AND. SF1->F1_FILIAL+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC == SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM)
		FOR IH:= 1 TO LEN(aParcelas)
			if aParcelas[IH][1]==SE2->E2_PARCELA
				IF ASCAN(AJAFOI,SE2->E2_PARCELA)==0
					REClock('SE2',.F.)
					SE2->E2_VENCTO:=aParcelas[IH][2]
					SE2->E2_VENCREA:=DATAVALIDA(aParcelas[IH][2])
					MSUNLOCK()
					AADD(AJAFOI,SE2->E2_PARCELA)
					
				ENDIF
			EndIf
			if aParcelas[IH][1]=='01' .and. empty(SE2->E2_PARCELA)
				IF ASCAN(AJAFOI,SE2->E2_PARCELA)==0
					REClock('SE2',.F.)
					SE2->E2_VENCTO:=aParcelas[IH][2]
					SE2->E2_VENCREA:=DATAVALIDA(aParcelas[IH][2])
					MSUNLOCK()
					AADD(AJAFOI,SE2->E2_PARCELA)
					
				ENDIF
			EndIf
			
		Next
		
		NITE++
		SE2->(DBsKIP())
	EndDo
	if nTipo == 1
		aviso("Sucesso!","A nota fiscal numero: "+C00->C00_NUMNFE+' foi importada com sucesso!',{"Ok"})
	ElseIf nTipo == 2
		aviso("Sucesso!","A Pre-Nota numero: "+C00->C00_NUMNFE+' foi importada com sucesso!',{"Ok"})
	EndIF
	cFile:= aCmps[2]
	FErase ( cFile )
	oDlgTit:end()
EndIF

Return

Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.SA5_MVC" OPERATION MODEL_OPERATION_VIEW 	ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.SA5_MVC" OPERATION MODEL_OPERATION_INSERT ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.SA5_MVC" OPERATION MODEL_OPERATION_UPDATE ACCESS 143
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.SA5_MVC" OPERATION MODEL_OPERATION_DELETE ACCESS 144
Return aRotina



Static Function atuTes(lGeral)
Local NA:=1

if len(aCols)==1 .and. empty( aCols[1][1])
	alert('NFE nao relacionada!')
	return
EndIF


dbSelectArea('SA2')
DBGOTO(nRecSA2)
if lGeral .and. !Empty(aCmps[19])
	FOR nA:=1 to len(aCols)
		nPosTes:=aScan(aHeader,{|x| alltrim(x[2]) =='D1_TES'})
		aCols[na][nPosTes]:=aCmps[19]
	Next
	aCmps[19]:="   "
EndIF
_nAliqIcm := 0
_nValIcm := 0
_nBaseIcm := 0
_nValIpi := 0
_nBaseIpi := 0
_nValMerc := 0
_nValSol := 0
_nValDesc :=0
_nPrVen := 0

FOR nA:=1 to len(aCols)
	MaFisIni(SA2->A2_COD,SA2->A2_LOJA,"f","N",SA2->A2_TIPO,MaFisRelImp("MT100",{ "SD1" }),,,"SD1","MT100")
	nPosPrd:=aScan(aHeader,{|x| alltrim(x[2]) =='D1_COD'})
	cProd:=aCols[nA][nPosPrd]
	nPosTes:=aScan(aHeader,{|x| alltrim(x[2]) =='D1_TES'})
	cTes:=aCols[nA][nPosTes]
	nPosQtd:=aScan(aHeader,{|x| alltrim(x[2]) =='D1_QUANT'})
	cQtd:=aCols[nA][nPosQtd]
	nPosVun:=aScan(aHeader,{|x| alltrim(x[2]) =='D1_VUNIT'})
	cVun:=aCols[nA][nPosVun ]
	MaFisAdd(cProd,cTes,cQtd,cVun,0,"","",0,0,0,0,0,(cQtd*cVun),0,0,0)
	_nAliqIcm += MaFisRet(1,"IT_ALIQICM")
	_nValIcm += MaFisRet(1,"IT_VALICM" )
	_nBaseIcm += MaFisRet(1,"IT_BASEICM")
	_nValIpi += MaFisRet(1,"IT_VALIPI" )
	_nBaseIpi += MaFisRet(1,"IT_BASEICM")
	_nValMerc += MaFisRet(1,"IT_VALMERC")
	_nValSol += MaFisRet(1,"IT_VALSOL" )
	_nValDesc += MaFisRet(1,"IT_DESCONTO" )
	_nPrVen += MaFisRet(1,"IT_PRCUNI")
	
	MaFisEnd()
	
NExt

aCmps[13]:=_nValMerc
aCmps[14]:=0
aCmps[15]:=_nValDesc
aCmps[16]:=0
aCmps[17]:=_nValIpi
aCmps[18]:=_nValMerc+_nValIpi


Return






Static Function calctes()
Local nA

_nAliqIcm := 0
_nValIcm := 0
_nBaseIcm := 0
_nValIpi := 0
_nBaseIpi := 0
_nValMerc := 0
_nValSol := 0
_nValDesc :=0
_nPrVen := 0

FOR nA:=1 to len(aCols)
	MaFisIni(SA2->A2_COD,SA2->A2_LOJA,"f","N",SA2->A2_TIPO,MaFisRelImp("MT100",{ "SD1" }),,,"SD1","MT100")
	nPosPrd:=aScan(aHeader,{|x| alltrim(x[2]) =='D1_COD'})
	cProd:=aCols[nA][nPosPrd]
	nPosTes:=aScan(aHeader,{|x| alltrim(x[2]) =='D1_TES'})
	cTes:=aCols[nA][nPosTes]
	nPosQtd:=aScan(aHeader,{|x| alltrim(x[2]) =='D1_QUANT'})
	cQtd:=aCols[nA][nPosQtd]
	nPosVun:=aScan(aHeader,{|x| alltrim(x[2]) =='D1_VUNIT'})
	cVun:=aCols[nA][nPosVun ]
	MaFisAdd(cProd,cTes,cQtd,cVun,0,"","",0,0,0,0,0,(cQtd*cVun),0,0,0)
	_nAliqIcm += MaFisRet(1,"IT_ALIQICM")
	_nValIcm += MaFisRet(1,"IT_VALICM" )
	_nBaseIcm += MaFisRet(1,"IT_BASEICM")
	_nValIpi += MaFisRet(1,"IT_VALIPI" )
	_nBaseIpi += MaFisRet(1,"IT_BASEICM")
	_nValMerc += MaFisRet(1,"IT_VALMERC")
	_nValSol += MaFisRet(1,"IT_VALSOL" )
	_nValDesc += MaFisRet(1,"IT_DESCONTO" )
	_nPrVen += MaFisRet(1,"IT_PRCUNI")
	
	MaFisEnd()
	
NExt

aCmps[13]:=_nValMerc
aCmps[14]:=0
aCmps[15]:=_nValDesc
aCmps[16]:=0
aCmps[17]:=_nValIpi
aCmps[18]:=_nValMerc+_nValIpi


oDlgTit:REFRESH()

Return



static Function veParc()
Local NI
Local nX
aHeaderOld:=aHeader
aColsOld:=acols
/*
nValTot			Num�rico			Valor total da duplicata.
cCond			Num�rico			C�digo da condi��o de pagamento.
nValIpi			Array of Record			Valor do IPI destacado.			0
dData0			Array of Record			Data inicial para considerar desdobramento.
nValSolid			Array of Record			Valor do ICMS Solid�rio.			0
*/

if Empty(aCmps[20])
	return .t.
EndIF


aCOnd:=condicao(aCmps[12],aCmps[20],aCmps[11],ddatabase)
private ADADOSIMP:={}

Private aRotina := {{"Pesquisar", "AxPesqui", 0, 1},;
{"Visualizar", "AxVisual", 0, 2},;
{"Incluir", "AxInclui", 0, 3},;
{"Alterar", "AxAltera", 0, 4},;
{"Excluir", "AxDeleta", 0, 5}}


aVenc:={}
aCmpos:={'E2_PARCELA','E2_VENCREA','E2_VALOR'}
aHeader:={}
aCols:={}

FOR NI:=1 to len(aCmpos)
	dbSelectArea('SX3')
	dbsetOrder(2)
	dbSeek(aCmpos[ni])
	Aadd(aHeader,{Trim(X3Titulo()),;
	SX3->X3_CAMPO,;
	SX3->X3_PICTURE,;
	SX3->X3_TAMANHO,;
	SX3->X3_DECIMAL,;
	"",;
	"",;
	SX3->X3_TIPO,;
	"",;
	"" })
NExt
//Aadd(aCols,Array(len(aHeader)+1))
for nx:=1 to len(aCOnd)
	aadd(aCols,{strzero(nx,2),aCond[nx][1],aCond[nx][2],.f.})
next
/*For nI := 1 To len(aHeader)
aCols[1][nI] := CriaVar(aHeader[nI][2])
Next

aCols[1][len(aHeader)+1] := .F.
*/
DEFINE MSDIALOG oDlgPgt TITLE "[AFAT001] - Condi��es de Pagamento" From 001,001 to 280,500 Pixel

oGetDados := MsGetDados():New(10, 10, 95, 240, 4, "U_afat01OK", "U_afat01tOK","+E2_PARCELA", .F., {"E2_VENCREA",'E2_VALOR'}, , .F., len(aCOnd), "U_afat01fOK", "U_afat01DEL", , "U_afat01DLOK", oDlgPgt)
oBtnAtu := tButton():New(110,100,'OK'   , oDlgPgt, {|| oDlgPgt:end() } ,40,12,,,,.T.)

ACTIVATE MSDIALOG oDlgPgt CENTERED

aParcelas:=acols


aHeader:=aHeaderOld
aCols:=acolsOld

return .t.

User function afat01OK


Return .t.

User function afat01fOK


Return .t.

User function afat01DEL


Return .t.

User function afat01DLOK


Return .t.

User function afat01tOK


Return   .t.



User Function Pegarqs()
Local NI
Local xni

cFile := cGetFile("*.xml |*.XML  |","Selecione o Caminho....",0,"c:\",.F.,GETF_LOCALHARD)//+GETF_OVERWRITEPROMPT)   
if empty(cFile)
	return
EndIF
ctmp:=''
FOR NI:=1 TO LEN(cFile)
	if substr(cFile,LEN(cFile)-ni,1) $ '\/'
		cCam:=substr(cFile,1,len(cFIle)-ni)
		cFile:=substr(cFile,1,len(cFIle)-ni)+'*.xml'
		exit
	ENdif
Next


aArqDir := DIRECTORY(cFile)

/********************/
Private oOk	:= Loadbitmap(GetResources(), 'LBOK')
Private oNo	:= Loadbitmap(GetResources(), 'LBNO')
Private oDlgAl
Private aListPC:={}
nVai:=0
FOR NI:=1 TO LEN(aArqDir)
	aadd(aListPC,{.f.,aArqDir[ni][1]})
Next

ASORT(aListPC, , , { | x,y | x[2] > y[2] } )

aButtons:={}
Aadd( aButtons, {"HISTORIC", {|| aListPC :=marctodos(aListPC)}, "Inverter Sel."})

DEFINE MSDIALOG oDlgAl TITLE "[ARQUIVOS XMLS]" From 035,000 To 370,750 PIXEL// OF oMainWnd
@030, 002 LISTBOX oListPC FIELDS HEADERS "  ","Arquivo" SIZE 373,150 PIXEL OF oDlgAl ;
On dblClick(aListPC := MARCAX(oListPC:nAt,aListPC), oListPC:Refresh())
oListPC:SetArray(aListPC)
oListPC:bLine:={||{If(;
aListPC[oListPC:nAt,1],oOk,oNo),;
aListPC[oListPC:nAt,2]}}
oListPC:Refresh()

ACTIVATE MSDIALOG oDlgAl CENTERED ON INIT EnchoiceBar(oDlgAl,{|| nVai:=1 ,oDlgAl:End()},{|| oDlgAl:End()},,aButtons )

if nVai==1
	for xni:=1 to len(aListPC)
		if aListPC[xni][1]
			//alert(alltrim(cCam)+alltrim(aListPC[ni][2]))
			Pegacte(alltrim(cCam)+alltrim(aListPC[xni][2]))
		endif
	Next
EndIF
/****************/


Return

User Function Pegarqs2()
Local NI
Local nxi

cFile := cGetFile("*.xml |*.XML  |","Selecione o Caminho....",0,"c:\",.F.,GETF_LOCALHARD)//+GETF_OVERWRITEPROMPT) 
if empty(cFile)
	return
EndIF
ctmp:=''
FOR NI:=1 TO LEN(cFile)
	if substr(cFile,LEN(cFile)-ni,1) $ '\/'
		cCam:=substr(cFile,1,len(cFIle)-ni)
		cFile:=substr(cFile,1,len(cFIle)-ni)+'*.xml'
		exit
	ENdif
Next


aArqDir := DIRECTORY(cFile)

/********************/
Private oOk	:= Loadbitmap(GetResources(), 'LBOK')
Private oNo	:= Loadbitmap(GetResources(), 'LBNO')
Private oDlgAl
Private aListPC:={}
nVai:=0
FOR NI:=1 TO LEN(aArqDir)
	aadd(aListPC,{.f.,aArqDir[ni][1]})
Next

ASORT(aListPC, , , { | x,y | x[2] > y[2] } )

aButtons:={}
Aadd( aButtons, {"HISTORIC", {|| aListPC :=marctodos(aListPC)}, "Inverter Sel."})

DEFINE MSDIALOG oDlgAl TITLE "[ARQUIVOS XMLS]" From 035,000 To 370,750 PIXEL// OF oMainWnd
@030, 002 LISTBOX oListPC FIELDS HEADERS "  ","Arquivo" SIZE 373,150 PIXEL OF oDlgAl ;
On dblClick(aListPC := MARCAX(oListPC:nAt,aListPC), oListPC:Refresh())
oListPC:SetArray(aListPC)
oListPC:bLine:={||{If(;
aListPC[oListPC:nAt,1],oOk,oNo),;
aListPC[oListPC:nAt,2]}}
oListPC:Refresh()

ACTIVATE MSDIALOG oDlgAl CENTERED ON INIT EnchoiceBar(oDlgAl,{|| nVai:=1 ,oDlgAl:End()},{|| oDlgAl:End()},,aButtons )

if nVai==1
	for nxi:=1 to len(aListPC)
		if aListPC[nxi][1]
			//alert(alltrim(cCam)+alltrim(aListPC[ni][2]))
			PegaXML(alltrim(cCam)+alltrim(aListPc[nxi][2]))
		EndIF
	Next
EndIF
/****************/


Return




//pega do arquivo o xml
Static Function Pegacte(cFile)

Local dData		:= CtoD("  /  /    ")
Local cSAVEmp
Local cSavFil
Local cToma   := ''
Local cCNPJ_T := ''
Local lAchou  := .T.
Local aChvNfOri  := {}
Local nn := 0

cError :=""
cWarning:=""
//cFile := cGetFile("*.xml |*.XML  |","Selecione o Caminho....",0,"c:\",.F.,GETF_LOCALHARD+GETF_OVERWRITEPROMPT)
IF eMPTy(cFile)
	RETURN
eNDIF

aFil:=directory(cFile)
CpyT2S ( cFile, "\CTE\importar\", .F. )
cFile:="\CTE\importar\"+aFil[1][1]
oXml  		:= XmlParserFile( cFile, "_", @cError, @cWarning )	//acessando o CONTEUDO do meu nodo ""
if type('oXml:_CTEproc')=='U'
	//alert("Arquivo de cte invalido" + CHR(13)+CHR(10)+cFile)
	return
EndIF

PRIVATE CNNF:=oXml:_CTEproc:_CTE:_INFCTE:_IDE
if Type("CNNF:_NCT:TEXT")=="U"
	alert("XML Invalido!")
	return
EndIF
cNota 		:= padl(CNNF:_NCT:TEXT,tamsx3('F1_DOC')[1],'0')
cSerie 		:= padl(CNNF:_SERIE:TEXT,tamsx3('F1_SERIE')[1],'0')
cChaveNf 	:= padl(oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT,tamsx3('F1_CHVNFE')[1],'0')
If Type('oXml:_CTEproc:_CTE:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT') <>'U'
	cToma := oXml:_CTEproc:_CTE:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT
ElseIf Type('oXml:_CTEproc:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT') <>'U'
	cToma := oXml:_CTEproc:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT
EndIf

//0-Remetente;
//1-Expedidor;
//2-Recebedor;
//3-Destinat�rio.
//4-Outros  //tag toma4

If cToma = '0'
	cCNPJ_T := oXml:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT
Elseif cToma = '1'
	cCNPJ_T := oXml:_CTEPROC:_CTE:_INFCTE:_EXPED:_CNPJ:TEXT
Elseif cToma = '2' 
	cCNPJ_T := oXml:_CTEPROC:_CTE:_INFCTE:_RECEB:_CNPJ:TEXT
ElseIf cToma = '3'
	cCNPJ_T := oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT
Elseif ctoma = '4'
	cCNPJ_T := cToma := oXml:_CTEproc:_CTE:_INFCTE:_IDE:_TOMA4:_CNPJ:TEXT
EndIf


//alterado em 08/074/2019 - akira
cSavEmp := cEmpAnt
cSavFil := cFilAnt
cEmpt := SM0->M0_CODIGO
SM0->(DbSeek((cEmpt)))
lTem := .F.
while !SM0->(EOF()) .AND. SM0->M0_CODIGO == cEmpt
	//if SM0->M0_CGC == oXml:_CTEPROC:_CTE:_INFCTE:_EXPED:_CNPJ:TEXT
	if SM0->M0_CGC == cCNPJ_T
		lTem := .T.
		cFilant := SM0->M0_CODFIL
		EXIT 
	EndIf
	SM0->(DbSkip())
End

If !lTem
	AVISO("NFE nao Importada!!","Destinatario da nota informada invalido!",{"OK"})
	SM0->(DbSeek((cSavEmp+cSavFil)))
	cEmpAnt := cSavEmp
	cFilAnt := cSavFil  
	Return()
EndIf
//ate aqui - em 08/04/2019

//em 18/06/2019
//validacao para n�o permitir importa��o do xml do CTE de fretes de compra
If cToma = '3' .or. cToma = '4' 
	//chave da NF que originou o frete
	If type('oXml:_CteProc:_Cte:_InfCte:_InfCteNorm:_InfDoc:_InfNfe')='A'
		For nn := 1 to len(oXml:_CteProc:_Cte:_InfCte:_InfCteNorm:_InfDoc:_InfNfe)
			Aadd(aChvNfOri,oXml:_CteProc:_Cte:_InfCte:_InfCteNorm:_InfDoc:_InfNfe[nn]:_Chave:text)
		Next
	Else
		Aadd(aChvNfOri,oXml:_CteProc:_Cte:_InfCte:_InfCteNorm:_InfDoc:_InfNfe:_Chave:text)
	EndIf
	lAchou := .T.
	For nn := 1 to len(aChvNfOri)
		cChvNfOri := aChvNfOri[nn]
		lAchou := ValidNF(cChvNfOri)
		If !lAchou
			Exit
		EndIf
	Next
	If !lAchou
		AVISO("NFE nao Importada!!","Nota de devolu��o n�o cadastrada ou se trata de CTE referente a uma compra",{"OK"})
		cEmpAnt := cSavEmp
		cFilAnt := cSavFil  
		Return()	
	EndIf	
EndIf
//ate aqui - em 18/06/2019


//em 28/05/2019
//valida se o Fornecedor est� cadastrado (SA2),
//Antes de iniciar a importa��o
If Empty(POSICIONE('SA2',3,xfilial('SA2')+OXML:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT,'A2_COD'))
	AVISO("NFE nao Importada!!","CNPJ do Fornecedor n�o localizado!",{"OK"})
	Return()
EndIf
//Ate aqui- 28/05/82019

cXml:=""
SAVE oXml XMLSTRING cXML

dbSelectArea('C00')
DBSetOrder(1)
If !DbSeek( xFilial("C00") + cChaveNf)
	RecLock("C00",.T.)
	C00->C00_FILIAL     := xFilial("C00")
	C00->C00_STATUS     := '1'
	C00->C00_CHVNFE		:= cChaveNf
	dData := CtoD("01/"+Substr(cChaveNf,5,2)+"/"+Substr(cChaveNf,3,2))
	C00->C00_ANONFE		:= Strzero(Year(dData),4)
	C00->C00_MESNFE		:= Strzero(Month(dData),2)
	C00->C00_SERNFE		:= Substr(cChaveNf,23,3)
	C00->C00_NUMNFE		:= Substr(cChaveNf,26,9)
	C00->C00_CODEVE		:= Iif(cChaveNf $ '0',"1","3")
	C00->C00_CTE			:='S'
	C00_JABAIX				:='S'
	C00->C00_RSXML		:= TiraGraf(cXML)
	MsUnLock()
EndIf

	//Chamada de rotina para grava��o de dados do Ct-e para tabela ZC1 e ZC2. -- 24.05.2018 -- Andre/Rsac
	U_IMPCTE()


Return

User Function CARREGAD1()


nPosPrd:=aScan(aHeader,{|x| alltrim(x[2]) =='D1_COD'})
	nPosds=aScan(aHeader,{|x| alltrim(x[2]) =='D1_DESCRI'})
if type('M->D1_COD')<>'U'
	acols[n][nPosds]:=posicione('SB1',1,xFilial('SB1')+M->D1_COD,'B1_DESC')
EndIF
//M->D1_COD:=aCols[n][nPosPrd]

return .T.

static function UsaColaboracao(cModelo)
Local lUsa := .F.

If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
endif
return (lUsa)



Static Function MARCAX(nIt,aVetor)
Local nItAux	:= 0
Local nX		:= 0
Local nY		:= 0
Local ni 
Local NI

aVetor[nIt,1] := !aVetor[nIt,1]

Return(aVetor)

Static function marctodos(aVetor)
Local ni

for ni:=1 to len(aVetor)
	aVetor[ni,1] := !aVetor[ni,1]
next

Return(aVetor)

Static Function PegaXML(cFile)

Local dData		:= CtoD("  /  /    ")
Local cSAVEmp
Local cSavFil

cError :=""
cWarning:=""

//cFile := cGetFile("*.xml |*.XML  |","Selecione o Caminho....",0,"c:\",.F.,GETF_LOCALHARD+GETF_OVERWRITEPROMPT)
IF eMPTy(cFile)
	RETURN
eNDIF

aFil:=directory(cFile)
CpyT2S ( cFile, "\CTE\importar\", .F. )
cFile:="\CTE\importar\"+aFil[1][1]
oXml  		:= XmlParserFile( cFile, "_", @cError, @cWarning )	//acessando o CONTEUDO do meu nodo ""
if type('oXml:_NFEPROC')=='U'
	//alert("Arquivo de cte invalido" + CHR(13)+CHR(10)+cFile)
	return
EndIF

PRIVATE ONNF:=oXml:_NFEPROC:_nfe:_INFNFE:_IDE
cNota 		:= padl(ONNF:_NNF:TEXT,tamsx3('F1_DOC')[1],'0')
cSerie 		:= padl(ONNF:_SERIE:TEXT,tamsx3('F1_SERIE')[1],'0')
cChaveNf 	:= padl(oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT,tamsx3('F1_CHVNFE')[1],'0')

/* em 08/04/2019 - akira
cEmpt:=SM0->M0_CODIGO
dbSelectArea('SM0')
DBGotop()
DBSeek(cEmpt)
LTEM:=.F. 
dbGotop()
while !SM0->(EOF()) 
    IF cEmpt==SM0->M0_CODIGO
			if SM0->M0_CGC == oXml:_NFEPROC:_nfe:_INFNFE:_DEST:_CNPJ:TEXT
				LTEM:=.T.
				cFilant:=SM0->M0_CODFIL
				exit
			EndIf
		EndIF
	SM0->(DBSKIP())
EnddO
*/

	//alterado em 08/04/2019
	cSavEmp := cEmpAnt
	sSavFil := cFilAnt
	cEmpt := SM0->M0_CODIGO
	SM0->(DbSeek((cEmpt)))
	lTem := .F.
	while !SM0->(EOF()) .AND. SM0->M0_CODIGO == cEmpt
		if SM0->M0_CGC == oXml:_NFEPROC:_nfe:_INFNFE:_DEST:_CNPJ:TEXT
			lTem := .T.
			cFilant := SM0->M0_CODFIL
			EXIT 
		EndIf
		SM0->(DbSkip())
	End

iF !LTEM
//	AVISO("NFE nao Importada!","Destinatario da nota informada invalido!",{"OK"})
	SM0->(DbSeek((cSavEmp+cSavFil)))  //em 048/04/2019
	return
EndIF

cXml:=""
SAVE oXml XMLSTRING cXML

dbSelectArea('C00')
DBSetOrder(1)
If !DbSeek( xFilial("C00") + cChaveNf)
	RecLock("C00",.T.)
	C00->C00_FILIAL     := xFilial("C00")
	C00->C00_STATUS     := '1'
	C00->C00_CHVNFE		:= cChaveNf
	dData := CtoD("01/"+Substr(cChaveNf,5,2)+"/"+Substr(cChaveNf,3,2))
	C00->C00_ANONFE		:= Strzero(Year(dData),4)
	C00->C00_MESNFE		:= Strzero(Month(dData),2)
	C00->C00_SERNFE		:= Substr(cChaveNf,23,3)
	C00->C00_NUMNFE		:= Substr(cChaveNf,26,9)
	C00->C00_CODEVE		:= Iif(cChaveNf $ '0',"1","3")
	C00_JABAIX				:='S'
	C00->C00_RSXML		:= TiraGraf(cXML)
else
	reclock('C00',.F.)
	C00_JABAIX				:='S'
	C00->C00_RSXML		:= TiraGraf(cXML)
eNDif
MsUnLock()


Return


Static	 function mudaCli()

cLoja:=aCmps[4]
cTipo:='N'
cA100For:=aCmps[3]
dbselectArea('SA2')
DBSETORDER(1)
DBSEEK(XFILIAL('SA2')+aCmps[3]+aCmps[4])

Return .t.



Static Function gravaa5(cProdFor,cProd)
/*dbSelectArea('SA5')
DBSetOrder(1)
if !dbSeek(XfILIAL('SA5')+cA100For+cLoja+cProd)
	
	aPrFor:={	{"A5_FORNECE",cA100For	,NIL},;
				{"A5_LOJA",cLoja				,NIL},;
				{"A5_PRODUTO",cProd		,NIL},;
				{"A5_CODPRF",cProdFor 	,NIL}}
	lMsErroAuto := .F.
	MSExecAuto({ |x,y| Mata060(x,y)},aPrFor,3)
EndIF*/



SA5->(DBSetOrder(1))
if !SA5->(dbSeek(XfILIAL('SA5')+cA100For+cLoja+cProd))
	
	RecLock("SA5",.T.)
	SA5->A5_FILIAL      := xFilial('SA5')
	SA5->A5_FORNECE     := cA100For
	SA5->A5_LOJA        := cLoja
	SA5->A5_NOMEFOR     := Posicione("SA2", 1, xFilial("SA2") + cA100For + cLoja , "A2_NOME")
	SA5->A5_PRODUTO	     := cProd
	SA5->A5_NOMPROD     := Posicione("SB1", 1, xFilial("SB1") + cProd, "B1_DESC")
	SA5->A5_CODPRF      := cProdFor	
	MsUnLock("SA5")
	
EndIF
Return


//em 27/05/2019
User Function LegC00()
aLegenda := {{"BR_VERDE", "Nao Classificada"},;
{"BR_VERMELHO","Classificada"}}

BrwLegenda("Status","Legenda",aLegenda)
return()


Static Function ValidNF(cChave)
Local lRet := .F.
Local cSql := ""

cSql:=" SELECT * "
cSql+=" FROM "+RetSqlName('SF1') + " SF1  "
cSql+=" WHERE F1_CHVNFE ='"+cChave+"'"
cSql+=" AND SF1.D_E_L_E_T_<>'*'"

cSql+=" UNION ALL "

cSql+=" SELECT * " 
cSql+=" FROM "+RetSqlName('SF1') + " SF1  "
cSql+=" WHERE F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA IN ( "
cSql+="    SELECT D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA "
cSql+="    FROM "+RetSqlName('SF2') + " SF2 INNER JOIN  "
cSql+=          RetSqlName('SD1') + " SD1 ON D1_FILIAL=F2_FILIAL "
cSql+="         AND D1_NFORI=F2_DOC AND D1_SERIORI=F2_SERIE "
cSql+="         AND SD1.D_E_L_E_T_<>'*'  "
cSql+="    WHERE F2_CHVNFE ='"+cChave+"' " 
cSql+="       AND SF2.D_E_L_E_T_<>'*') "
cSql+=" AND SF1.D_E_L_E_T_<>'*' "

If Select('TRBDEV')<>0
	TRBDEV->(dbCloseArea())
EndIf
TcQuery cSql New Alias "TRBDEV"
 If TRBDEV->(EOF())
 	lRet := .F.
 Else
 	lRet := .T.
 EndIf
Return(lRet)

Static Function AtualizarStatus()
	Local aArea := GetArea()
	Local cQuery:= ""
	Local nRet	:= 0

	cQuery += "UPDATE "+RetSqlName("C00")+" SET C00_CLASSI='S' "+ENTER
	cQuery += "FROM "+RetSqlName("C00")+" C00 "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SF1")+" SF1 ON SF1.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND F1_FILIAL = C00_FILIAL "+ENTER
	cQuery += "		AND F1_CHVNFE = C00_CHVNFE "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE C00.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "AND C00_FILIAL='"+xFilial("C00")+"' "+ENTER
	cQuery += "AND C00_CLASSI<>'S' "+ENTER
	
	nRet := TcSqlExec(cQuery)
	if (nRet < 0)
		conout("PUXANFE - AtualizarStatus() - TCSQLError() " + TCSQLError())
	endif

	RestArea(aArea)
Return	

//Inclusao da nova amarracao. Onde substituiu a funcao gravaa5.
Static Function INCSA5Nw(cProdFor,cProd)
Local aArea		:= GetArea()
Local aAreaSB1	:= SB1->(GetArea())
Local nOpc 		:= 3
Local oModel 	:= Nil

DbSelectArea("SB1")
SB1->(DBSetOrder(1))
SB1->(DBGotop())
If DbSeek(xFilial('SB1') + cProd)

	DbSelectArea('SA5')
	SA5->(DBSetOrder(1)) //A5_FILIAL, A5_FORNECE, A5_LOJA, A5_PRODUTO, A5_FABR, A5_FALOJA, R_E_C_N_O_, D_E_L_E_T_
	SA5->(DBGotop())
	If !DbSeek(xFilial('SA5') + cA100For + cLoja + cProd)

		oModel := FWLoadModel('MATA061')

		oModel:SetOperation(nOpc)
		oModel:Activate()

		//Cabe�alho
		oModel:SetValue('MdFieldSA5','A5_PRODUTO'	, cProd)
		oModel:SetValue('MdFieldSA5','A5_NOMPROD'	, SB1->B1_DESC)

		//Grid
		oModel:SetValue('MdGridSA5','A5_FORNECE',cA100For)
		oModel:SetValue('MdGridSA5','A5_LOJA' 	,cLoja)
		oModel:SetValue('MdGridSA5','A5_CODPRF'	,cProdFor)
		//oModel:SetValue('MdGridSA5','A5_NOMEFOR', 'FOR. P/ ROTINA MATA061 - CT001')

		//Nova linha na Grid
		//oModel:GetModel("MdGridSA5"):AddLine()

		//oModel:SetValue('MdGridSA5','A5_FORNECE',cForn2)
		//oModel:SetValue('MdGridSA5','A5_LOJA' 	,cLoja2)
		//oModel:SetValue('MdGridSA5','A5_NOMEFOR', 'FOR. P/ ROTINA MATA061 - CT001')

		If oModel:VldData()
			oModel:CommitData()
		Endif

		oModel:DeActivate()
		oModel:Destroy()
	EndIf

EndIf 

RestArea(aArea)
RestArea(aAreaSB1)
Return()
