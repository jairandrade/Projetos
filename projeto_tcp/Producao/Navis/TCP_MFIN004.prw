#Include 'Protheus.ch'
#Include 'TOPCONN.CH'

/*/{Protheus.doc} MFIN004
Baixa titulos com base em arquivo .csv
@type function
@author luizf
@since 11/05/2017
/*/
User Function MFIN004()

LOCAL aSays     := {}
LOCAL aButtons  := {}
LOCAL cPerg     := "MFIN004"
LOCAL cCadastro := "Este programa irá Importar a baixa dos Títulos a Receber."
PRIVATE aLog := {}

public cEnvBaixa := '0'

MFIN04PER(cPerg)
Pergunte(cPerg,.f.)

cEnvBaixa := ALLTRIM(STR(MV_PAR07))

aadd(aSays,"Rotina para Importar Baixas a Receber com base")
aadd(aSays,"em arquivo CSV.")

aadd(aButtons, { 1,.T.,{|| Processa({|| MFIN04PROC()},"Processamento","Importação de Baixas..."),FechaBatch() }} )
aadd(aButtons, { 2,.T.,{|| FechaBatch() }} )
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )

FormBatch( cCadastro, aSays, aButtons,, 160 )

Return

/*/{Protheus.doc} MFIN04PROC
Função de processamento.
@type function
@author luizf
@since 11/05/2017
/*/
Static function MFIN04PROC()

LOCAL cArq       := ""
LOCAL cArqOld    := ""
LOCAL cLinha     := ""
LOCAL aFiles     := {}
LOCAL nHdl   
LOCAL cMSG       := ""
LOCAL cArqTxt    := ""
LOCAL nCtL       := 0
LOCAL nPosTit    := 01
LOCAL nPosVlr    := 03
LOCAL nPosTpPg   := 04
LOCAL nPosCli    := 05
LOCAL nPosOs     := 06
LOCAL aDados     := {}
LOCAL aSe1Bx     := {}
LOCAL cQuery     := ""
LOCAL cLog       :=""
LOCAL aLgAuto    := {}
LOCAL lContinua  := .T.
LOCAL nVlr       := 0
LOCAL nValJur    := 0
LOCAL dDtPto     := MV_PAR06
Local cAliasAx
Local cWhere
Local nFor
Local nRecE1
Private lMSHelpAuto := .T.
Private	lMSErroAuto := .F.

DBSelectArea("SA6")
SA6->(DBSetOrder(01))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON

If !SA6->(MSSeek(xFilial("SA6")+MV_PAR01+MV_PAR02+MV_PAR04))
	Aviso("Banco não encontrado.","O Banco informado nos parâmetros não foi localizar.",{"Finalizar"})
	return
EndIf

//Solicita a escolha do arquivo CSV a ser importado.
cArq := cGetFile(" *.csv | *.CSV  |","Selecione o Caminho....",0,"c:\",.F.,GETF_LOCALHARD+GETF_OVERWRITEPROMPT)
If !Empty(Alltrim(cArq))
	AADD(aFiles, cArq)
	cArqOld := SUBSTR(cArq,1,Len(cArq)-3)+"#tx"
EndIf

If Len(aFiles) == 0
	cMsg := "Não existem arquivos para importar. Processo Encerrado"
	Return
Else
	//+---------------------------------------------------------------------+
	//| Define o nome do Arquivo Texto a ser usado                          |
	//+---------------------------------------------------------------------+
	cArqTxt := cArq
	//+---------------------------------------------------------------------+
	//| Abertura do arquivo texto                                           |
	//+---------------------------------------------------------------------+
	nHdl := fOpen(cArqTxt)
	If nHdl == -1
		IF FERROR()== 516
			ALERT("Feche a planilha que gerou o arquivo.")
		EndIF
		cMsg := "O arquivo de nome "+cArqTxt+" não pode ser aberto! Verifique os parâmetros."
		MsgAlert(cMsg,"Atenção!")
		Return 
	Endif
Endif
fClose(nHdl)

If !File(cArq)
	MsgStop("O arquivo " +cArq + " não foi encontrado. A importação será abortada!","ATENCAO")
	
	Return 
EndIf

FT_FUSE(cArq)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()

Do While !FT_FEOF()

	IncProc("Lendo arquivo texto...")

	nCtL++
	//nao considera o cabecalho
	If nCtL<2
	 FT_FSKIP()
	 loop
	EndIf 
	cLinha := FT_FREADLN()
	cLinha := ALLTRIM(cLinha)

	AADD(aDados,Separa(cLinha,";",.T.))

	FT_FSKIP()
EndDo
FT_FUSE()

ProcRegua(Len(aDados))

pergunte( "FIN070", .F. )

For nFor:=1 To Len(aDados)
    IncProc("Processando baixas..."+aDados[nFor][nPosTit])
    lContinua:= .T.
    
    If (Empty(aDados[nFor][nPosTit])) .Or. (Empty(aDados[nFor][nPosVlr]))
		aAdd(aLog,{"","","","Erro fatura ou valor não informado "+""})
		lContinua:= .F.
	EndIf	
    
	
    If lContinua
    	nVlr       := Val(StrTran(StrTran(aDados[nFor][nPosVlr],".",""),",","."))
		nValJur    := 0
		aSe1Bx     := {}
		
		IF LEN(aDados[nFor]) >= nPosOs .AND. !EMPTY(aDados[nFor][nPosOs])
			cWhere := "%(  E1_SALDO = '"+STR(nVlr)+"' OR E1_XNUMOS = '"+aDados[nFor][nPosOs]+"')%"
		ELSE
			cWhere := "% E1_SALDO = '"+STR(nVlr)+"' %"
		ENDIF
		
		cAliasAx := getNextAlias()
		
		BeginSQL Alias cAliasAx
			 
		 SELECT R_E_C_N_O_ AS REGISTRO, E1_SALDO
		 FROM %TABLE:SE1% SE1
		 WHERE SE1.%NotDel%  AND E1_FILIAL = %EXP:xFilial('SE1')% AND E1_NUM = %EXP:aDados[nFor][nPosTit]% 
		 AND %EXP:cWhere%
		
		EndSQL
		
	    Count To nRecCount
		
		(cAliasAx)->(dbGoTop())
	
		If (cAliasAx)->(Eof())
			aAdd(aLog,{"","",aDados[nFor][nPosCli],"Erro - Título NAO LOCALIZADO "+aDados[nFor][nPosTit]+":  Valor: "+aDados[nFor][nPosVlr]+IF(len(aDados[nFor])>=nPosOs," OS: "+aDados[nFor][nPosOs] ,'')})
			lContinua:= .F.
		EndIf
		
		IF lContinua .and. nRecCount > 1
			aAdd(aLog,{"","",aDados[nFor][nPosCli],"Erro - Existe mais de um título com essas informações. "+aDados[nFor][nPosTit]+":  Valor: "+aDados[nFor][nPosVlr]+IF(len(aDados[nFor])>=nPosOs," OS: "+aDados[nFor][nPosOs] ,'')})
			lContinua:= .F.
		ENDIF
		
		IF lContinua .and. (cAliasAx)->E1_SALDO < nVlr
			aAdd(aLog,{"","",aDados[nFor][nPosCli],"Erro - Valor da baixa maior que o saldo disponível. "+aDados[nFor][nPosTit]+":  Valor: "+aDados[nFor][nPosVlr]+IF(len(aDados[nFor])>=nPosOs," OS: "+aDados[nFor][nPosOs] ,'')})
			lContinua:= .F.
		ENDIF
		
		nRecE1 := (cAliasAx)->REGISTRO
		
		(cAliasAx)->(dbclosearea())
		
	EndIf
	
	If lContinua
		DBSelectArea("SE1")
		DBSetOrder(01)
		SE1->(DBGoTo(nRecE1))
		
		aAdd( aSe1Bx, { "E1_PREFIXO", 	SE1->E1_PREFIXO, 											nil } )
		aAdd( aSe1Bx, { "E1_NUM", 	  	SE1->E1_NUM, 												nil } )
		aAdd( aSe1Bx, { "E1_PARCELA", 	SE1->E1_PARCELA,											nil } )
		aAdd( aSe1Bx, { "E1_TIPO", 	  	SE1->E1_TIPO, 												nil } )
		aAdd( aSe1Bx, { "AUTMOTBX",   	"NOR", 														nil } )
		aAdd( aSe1Bx, { "AUTDTBAIXA", 	dDtPto,														nil } )
		aAdd( aSe1Bx, { "AUTDTCREDITO", dDataBase,	       											nil } )
		aAdd( aSe1Bx, { "AUTHIST", 		"BX AUTOMATICA VIA IMPORTACAO DE ARQUIVO",   				nil } )
		aAdd( aSe1Bx, { "AUTVALREC",	nVlr,														nil } )
		aAdd( aSe1Bx, { "AUTBANCO",	    SA6->A6_COD,												nil } )
		aAdd( aSe1Bx, { "AUTAGENCIA",	SA6->A6_AGENCIA, 											nil } )
		aAdd( aSe1Bx, { "AUTCONTA",	    SA6->A6_NUMCON, 											nil } )
		
		lMSHelpAuto := .T.
		lMSErroAuto := .F.
		MSExecAuto( { |x,y| Fina070(x,y) }, aSe1Bx, 3)
		cLog       :=""
		aLgAuto    := {}	
		If lMSErroAuto 
//			aLgAuto := GetAutoGRLog()
//			For n1 := 1 to len(aLgAuto)
//				cLog += aLgAuto[n1] +  chr(13)+chr(10)
//			Next n1	

			cLog := MostraErro()

			aAdd(aLog,{SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_NOMCLI,"Erro Baixa de título "+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)+": "+cLog})
		Else
			aAdd(aLog,{SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_NOMCLI,"Baixa título "+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)+" baixado "})	
		EndIf
	EndIf
	
Next

//Mostra o log de processados
MostraLog()

Return


Static Function MFIN04PER(cPerg)
	Local aRegs := {}

	aAdd(aRegs,{cPerg,"01","Banco","","","mv_ch1","C",TamSX3("A6_COD")[1],0,1,"G","","SA6DV","","","mv_par01",   "","","","",   "","","","","","","","","","","","",{"Informe o banco para a baixa."}})
	aAdd(aRegs,{cPerg,"02","Agencia","","","mv_ch2","C",TamSX3("A6_AGENCIA")[1],0,1,"G","","","","","mv_par02",   "","","","",   "","","","","","","","","","","","",{""}})
	aAdd(aRegs,{cPerg,"03","DV Agencia","","","mv_ch2","C",TamSX3("A6_DVAGE")[1],0,1,"G","","","","","mv_par03",   "","","","",   "","","","","","","","","","","","",{""}})
	aAdd(aRegs,{cPerg,"04","Nro Conta","","","mv_ch4","C",TamSX3("A6_NUMCON")[1],0,1,"G","","","","","mv_par04",   "","","","",   "","","","","","","","","","","","",{""}})
	aAdd(aRegs,{cPerg,"05","DV Conta","","","mv_ch5","C",TamSX3("A6_DVCTA")[1],0,1,"G","","","","","mv_par05",   "","","","",   "","","","","","","","","","","","",{""}})
	aAdd(aRegs,{cPerg,"06","Dt Pgto","","","mv_ch6","D",8,0,1,"G","","","","","mv_par06",   "","","","",   "","","","","","","","","","","","",{"Data em que o pagamento ocorreu."}})
	aAdd(aRegs,{cPerg,"07","Env. Intr. Baixa?"	 	   ,"Env. Intr. Baixa?"      ,"Env. Intr. Baixa?"	     ,"mv_par07","C",1,0,1,"C","","mv_par07","Não","Não",'Não',"1"  ,"mv_par12","Sim","Sim","Sim","","","","","","","","","","","","","","","","","","","",""})
	
	U_BuscaPerg(aRegs)
Return


/*/{Protheus.doc} MostraLog
Mostra log do processamento
@type function
@author luizf
@since 11/05/2017
/*/
Static Function MostraLog()

Local oDlg
Local oFont
Local cMemo := ""

DEFINE FONT oFont NAME "Courier New" SIZE 5,0

DEFINE MSDIALOG oDlg TITLE "Log de Processo" From 3,0 to 400,417 PIXEL

aCabec := {"Código","Loja","Nome","Log"}
cCabec := "{aLog[oBrw:nAT][1],aLog[oBrw:nAT][2],aLog[oBrw:nAT][3],aLog[oBrw:nAT][4]}"
bCabec := &( "{ || " + cCabec + " }" )

oBrw := TWBrowse():New( 005,005,200,090,,aCabec,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oBrw:SetArray(aLog)
oBrw:bChange    := { || cMemo := aLog[oBrw:nAT][4], oMemo:Refresh()}
oBrw:bLDblClick := { || cMemo := aLog[oBrw:nAT][4], oMemo:Refresh()}
oBrw:bLine := bCabec

@ 100,005 GET oMemo VAR cMemo MEMO SIZE 200,080 OF oDlg PIXEL

oMemo:bRClicked := {||AllwaysTrue()}
oMemo:lReadOnly := .T.
oMemo:oFont := oFont

//oImprimir :=tButton():New(185,120,'Imprimir' ,oDlg,{|| fImprimeLog() },40,12,,,,.T.)
oSair     :=tButton():New(185,165,'Sair'     ,oDlg,{|| ::End() },40,12,,,,.T.)

ACTIVATE MSDIALOG oDlg CENTERED

Return
