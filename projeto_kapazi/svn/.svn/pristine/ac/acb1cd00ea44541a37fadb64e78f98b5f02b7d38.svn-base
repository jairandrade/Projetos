#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "AP5MAIL.CH"


//Realizado validação no ambiente compilar -- 09.08.2017 -- Andre/Rsac
User Function BOLKAPXC()
Local aFix				:= {}
Local nStatus   		:= 0
Local aFields			:= {}
Local bEnvia            := {|| U_BolEnPen()}

private cCadastro		:=	"Log de envio de boletos"
private cAls			:= "Z0A"
private aRotina			:= {}
Private aCores    		:= {}
Private oMrkBrowse      := Nil

If cEmpAnt $ "01/04"
	If !Pergunte("BOLKAPXC  ", .T.)
		Return
	EndIf
	nStatus := MV_PAR01
Else
	nStatus := 1
EndIf

aAdd(aFix, {'Cliente'	, 'Z0A_CLIENT'})
aAdd(aFix, {'Loja'		, 'Z0A_LOJA'})
aAdd(aFix, {'Numero NF'	, 'Z0A_NUM'})
aAdd(aFix, {'Parcela'	, 'Z0A_PARCEL'})
aAdd(aFix, {'Status'	, 'Z0A_STDESC'})

If nStatus = 1 //Todos E-mails
	aAdd(aRotina, {"Enviar e-mail"	,	"U_AFIN01X" , 0, 4 })
	aAdd(aRotina, {"Legenda"		,	"U_BLegenda", 0, 5 })


	aCores    := {	{'Z0A_STATUS == "N"','BR_VERMELHO'} ,;
					{'Z0A_STATUS == "E"','BR_VERDE'}}

					DbSelectArea(cAls)
					(cAls)->(DbsetOrder(1))
					(cAls)->(DbGoTop())


	mBrowse(,,,,cAls, aFix,,,,,aCores)
Else //Somente Pendentes
	OpenSXs(,,,,,"TMPSX3","SX3")	
	TMPSX3->(dbSetOrder(2))
	For nX := 1 To Len(aFix)
		If TMPSX3->(dbSeek(PadR(aFix[nX][2],10, " ")))
			Aadd(aFields, {TMPSX3->X3_TITULO,;
					       TMPSX3->X3_CAMPO,;
					       TMPSX3->X3_TIPO,;
					       TMPSX3->X3_TAMANHO,;
				           TMPSX3->X3_DECIMAL,;
				           TMPSX3->X3_PICTURE})
		EndIf
	Next nX
	
	oMrkBrowse := FWMarkBrowse():New()
	oMrkBrowse:SetFieldMark("Z0A_OK")
	oMrkBrowse:SetAlias("Z0A")
	oMrkBrowse:AddButton("Enviar e-mail",bEnvia,,4)
	oMrkBrowse:SetFields(aFields)
	oMrkBrowse:SetFilterDefault("@Z0A_STATUS = 'N' AND Z0A_DATA >= '20200101'") //Somente Não enviados
	oMrkBrowse:SetDescription(cCadastro)
	oMrkBrowse:AddLegend("Z0A_STATUS == 'N'", "RED", "E-mail Não enviado")
	oMrkBrowse:Activate()
EndIf
Return()

User Function AFIN01X(cAls, nReg, nOpc, lBolEnPen)
local aParcela := {}
local cChave		:= ""
local aArea			:= GetArea()
local nI
Local nTimeKP		:= 2000
Private lImprimi	:= .F.
Default lBolEnPen   := .F. //.T. = Rotina de reprocessamento dos envios pendentes

If lBolEnPen .Or. MsgYesNo("Envia todas as parcelas?")
		cChave := Z0A->(Z0A_FILIAL + Z0A_FILE + Z0A_CLIENT + Z0A_LOJA + Z0A_NUM)
		
		//Z0A_FILIAL, Z0A_FILE, Z0A_CLIENT, Z0A_LOJA, Z0A_NUM, Z0A_PARCEL, R_E_C_N_O_, D_E_L_E_T_
		//Indice 2
		DbSelectArea("Z0A")
		Z0A->(DbSetOrder(2))
		Z0A->(DbGoTop())
		If Z0A->(DbSeek(cChave))
			
			While cChave == Z0A->(Z0A_FILIAL + Z0A_FILE + Z0A_CLIENT + Z0A_LOJA + Z0A_NUM)
				
				SE1->(DbGoTo(Z0A->Z0A_E1RECN))
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))
				If SA1->(dbSeek(xFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA)))
					aAdd(aParcela, {SE1->(RecNo()), SA1->(RecNo()), Z0A->(RecNo())})
				EndIf
				Z0A->(DbSkip())
				
			EndDo
		
		EndIf
		
Else
		SE1->(dbGoTo(Z0A->Z0A_E1RECN))
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA)))
			aAdd(aParcela, {SE1->(RecNo()), SA1->(RecNo()), Z0A->(RecNo())})			
		EndIf
EndIf

if Len(aParcela) > 0
	
	nTimeKP	:= (( (Len(aParcela)) /2) + 2) * 1000 //Calcula o tempo para envio do email

	cFPath := U_BOLKAPX(aParcela)
	if !Empty(cFPath)
		
		If lImprimi //se imprimiu alguma parcela
			SLEEP(nTimeKP)
			lRet := StaticCall(F200FIM, fSendBol, cFPath, aParcela)
			for nI := 1 to Len(aParcela)
				Z0A->(dbGoTo(aParcela[nI,3]))
				RecLock("Z0A", .F.)
				Z0A->Z0A_STATUS := IIF(lRet, 'E', 'N')
				Z0A->Z0A_STDESC := IIF(lRet, 'Email enviado com sucesso', 'Erro ao enviar email')
				MsUnlock()
			next nI
		EndIf
		
		//FErase(cFPath)
	endif
endif

If !lBolEnPen
	RestArea(aArea)
EndIf
return

//+-------------------------------------------//
//Função: BLegenda - Rotina de Legenda
//+-------------------------------------------

User Function BLegenda()
Local aCores := {}
AADD(aCores,{"BR_VERDE"    ,"E-mail enviado"})
AADD(aCores,{"BR_VERMELHO" ,"E-mail não enviado"})

BrwLegenda("Legenda", "Legenda", aCores)

Return Nil


User Function BolEnPen()
Local oSay := Nil

If MsgYesNo("<html>Confirma o envio do boleto de <b>todas as parcelas</b> para os registros selecionados?<//b>")
	FWMsgRun(, {|oSay| BolEnPen(@oSay)}, "Aguarde...","Processando envio(s)...")		
EndIf	
Return Nil

Static Function BolEnPen(oSay)

Z0A->(dbGoTop())
While !Z0A->(Eof())	
	If oMrkBrowse:IsMark() .And. Z0A->Z0A_STATUS == "N" 
		oSay:cCaption := "Enviando e-mail Nota Fiscal " + AllTrim(Z0A->Z0A_NUM) +;
			Iif(!Empty(Z0A->Z0A_PARCEL), "/", "") + Z0A->Z0A_PARCEL		
		ProcessMessages()  
		U_AFIN01X("Z0A", Z0A->(Recno()), 4, .T.)		
	EndIf
	
	Z0A->(dbSkip())
EndDo
Z0A->(dbGoTop())
oMrkBrowse:Refresh(.T.)
Return Nil
