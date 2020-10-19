#Include 'Protheus.ch'
#Include 'TOPCONN.ch'

/*/{Protheus.doc} MFIN002
Compensacao de RAs, quando o campo de OS na RA estiver preenchido, busca por títulos para compensar
que contenham o mesmo número de OS. 
@type function
@author luizf
@since 28/06/2016
/*/
User Function MFIN002()

LOCAL aSays     := {}
LOCAL aButtons  := {}
LOCAL cCadastro := "Compensação de RA."
LOCAL cPerg     := "AFI340"

aadd(aSays,"Esta Rotina Faz a compensação automática de RA.")
aadd(aSays,"Com base nos títulos com número de OS vinculado.")

aadd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
aadd(aButtons, { 1,.T.,{|| Processa({|| MFINP02()},"Processamento","Compensando RA..."),FechaBatch() }} )
aadd(aButtons, { 2,.T.,{|| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons,, 160 )

Return


/*/{Protheus.doc} MFINP02
Rotina autilizar para compensação
@type function
@author luizf
@since 30/08/2016
/*/
Static Function MFINP02()


LOCAL cQuery := ""
LOCAL cLog   := ""
Local lContabiliza
Local lAglutina     
Local lDigita     
PRIVATE aLog := {}

cQuery := "SELECT SE1.R_E_C_N_O_ AS RECRA , SE1NF.R_E_C_N_O_ AS RECNF  "
cQuery += " FROM "+RetSQLName("SE1")+" SE1 "
cQuery += "   INNER JOIN "+RetSQLName("SE1")+" SE1NF "
cQuery += "   ON "
cQuery += "   SE1NF.E1_FILIAL = SE1.E1_FILIAL "
cQuery += "   AND SE1NF.E1_XNUMOS = SE1.E1_XNUMOS "
cQuery += "   AND SE1NF.E1_TIPO != 'RA' "
cQuery += "   AND SE1NF.E1_SALDO > 0 "
cQuery += "   AND SE1NF.D_E_L_E_T_ != '*' "
cQuery += " WHERE "
cQuery += " SE1.E1_FILIAL = '"+xFilial("SE1")+"' "
cQuery += " AND SE1.E1_TIPO = 'RA' "
cQuery += " AND SE1.E1_XNUMOS != '' "
cQuery += " AND SE1.E1_SALDO > 0 "
cQuery += " AND SE1.D_E_L_E_T_ != '*' "
If Select("TRBRA") <> 0
	DBSelectArea("TRBRA")
	DBCloseArea()
EndIf
TCQuery cQuery New Alias "TRBRA"

DBSelectArea("SE1")

PERGUNTE("AFI340",.F.)  

Do While !TRBRA->(Eof())
	
	lContabiliza  := MV_PAR11 == 1
	lAglutina     := MV_PAR08 == 1
	lDigita       := MV_PAR09 == 1
	
	cLog := ""                 
	    
	aRecRA  := {TRBRA->RECRA}
	aRecSE1 := {TRBRA->RECNF}
    SE1->(dbSetOrder(1))
	SE1->(DBGoTop())
	SE1->(DBGoTo(TRBRA->RECNF))	
	//E1_PREFIXO, E1_NUM,E1_PARCELA, E1_TIPO,E1_CLIENTE,E1_LOJA,E1_NOMCLI,E1_VALOR,E1_XNUMOS
	//E1_PREFIXO, E1_NUM,E1_PARCELA, E1_TIPO,E1_CLIENTE,E1_LOJA,E1_NOMCLI,E1_VALOR
	 
	If !MaIntBxCR(3,aRecSE1,,aRecRA,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,,dDatabase )
		SE1->(DBGoTop())
		SE1->(DBGoTo(TRBRA->RECRA))
	    cLog:= " ERRO Compensação Titulo: "+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
	    cLog += " OS: "+ SE1->E1_XNUMOS

		SE1->(DBGoTop())
		SE1->(DBGoTo(TRBRA->RECNF))	    
	    cLog += " Titulo: "+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
	    
		aAdd(aLog,{SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_NOMCLI,cLog})
	Else
		aAdd(aLog,{SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_NOMCLI,"Compensação Titulo: "+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)})		
	EndIf

	TRBRA->(DBSkip())
EndDo
If Select("TRBRA") <> 0
	DBSelectArea("TRBRA")
	DBCloseArea()
EndIf

If Len(aLog) == 0
	aAdd(aLog,{"","","","Processamento concluido sem compensações."})		
EndIf

MostraLog()

Return


/*/{Protheus.doc} MostraLog
Monta Log de Processo para o usuario.
@type function
@author luizf
@since 28/06/2016
/*/Static Function MostraLog()

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
