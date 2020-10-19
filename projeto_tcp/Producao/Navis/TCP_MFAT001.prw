#Include 'Protheus.ch'
#include 'topconn.ch'

/*/{Protheus.doc} MFAT001
Funcao via schedule para integracao de Status de NFS-e.
@type function
@author luizf
@since 25/05/2016
/*/
User Function MFAT001()
MFATSTAT()//Chamada menu via menu.
Alert("Processo concluido.")
Return

//Chamada via schedule
User Function MFAT001S()
OpenSM0()
RPCSETENV('02', '01',)
MFATSTAT()//Prepara ambiente.
Return

/*/{Protheus.doc} MFATSTAT
Funcao auxiliar que executa a integracao de Status de NFS-e.
@type function
@author luizf
@since 25/05/2016
/*/
Static Function MFATSTAT()

LOCAL cStatus := ""
LOCAL cQuery := ""
LOCAL cGeraLog:= GetNewPar("TCP_NVGRLO","S")//Informa de gera Log.
LOCAL lGrv    := .F.
//OpenSM0()
//RPCSETENV('02', '01',)
PRIVATE cEspNFWs := GetNewPar("TCP_ESPNFW","NF")

//SF3->F3_NFELETR	:= RIGHT(cNota,nTamDoc)
//SF3->F3_EMINFE	:= dEmiNfe
//SF3->F3_HORNFE	:= cHorNFe
//SF3->F3_CODNFE	:= RTrim(cProtocolo)
//F3_DT_CANC - DATA DO CANCELAMENTO DA NF 5

cQuery := "SELECT  "
cQuery += " F3_DTCANC, F3_CODRSEF,F3_NFISCAL,F3_NFELETR,F3_CODNFE,F3_CODRET,F3_DESCRET,R_E_C_N_O_ AS REGISTRO  "
If SF3->(FieldPos("F3_YINTGR")) <>0
	cQuery += ",F3_YINTGR "
EndIf
cQuery += " FROM "+RetSQLName("SF3")+" SF3 "
cQuery += " WHERE "
cQuery += " F3_FILIAL =  '"+xFilial("SF3")+"' "
cQuery += " AND F3_ESPECIE = '"+cEspNFWs+"' "
cQuery += " AND (F3_EMISSAO >= '"+DToS(dDataBase)+"' "
cQuery += " OR F3_DTCANC >= '"+DToS(dDataBase)+"' )"
cQuery += " AND (("
cQuery += "    SELECT COUNT(1) TEMOS FROM "+RetSQLName("SD2")+" SD2 "
cQuery += "    WHERE "
cQuery += "    D2_FILIAL = F3_FILIAL "
cQuery += "    AND D2_DOC = F3_NFISCAL "
cQuery += "    AND D2_SERIE = F3_SERIE "
cQuery += "    AND D2_CLIENTE = F3_CLIEFOR "
cQuery += "    AND D2_LOJA = F3_LOJA "
cQuery += "    AND D2_YNUMOS <> ' ' "//Somente envia o que contem OS.
cQuery += "    AND SD2.D_E_L_E_T_ <> '*' "
cQuery += ")>0 OR F3_DTCANC <> '' )"
//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
cQuery += " AND SF3.D_E_L_E_T_ <> '*' "
If Select("TRBNF")<>0
	DBSelectArea("TRBNF")
	DBCloseArea()
EndIf
TCQuery cQuery New Alias "TRBNF"

Do While !TRBNF->(Eof())
	
	//F3_CODRSEF E F2_FIMP==' ' //NFSe não transmitido 1
	//F3_CODRSEF E F2_FIMP=='T' //NFSe Transmitido 2
	//F3_CODRSEF E F2_FIMP=='S' //NFSe Autorizado 3
	//F3_CODRSEF E F2_FIMP=='D' //NF Uso Denegado
	//F3_CODRSEF E F2_FIMP=='N' //NFSe nao autorizado 4
	//F3_DTCANC - DATA DO CANCELAMENTO DA NF 5
	
	cStatus	:= "1"
	Do Case
		Case !Empty(TRBNF->F3_DTCANC) // DATA DO CANCELAMENTO DA NF 5
			cStatus := "5"
		Case Empty(TRBNF->F3_CODRSEF) //F3_CODRSEF E F2_FIMP==' ' //NFSe não transmitido 1
			cStatus := "1"
		Case AllTrim(TRBNF->F3_CODRSEF) == "T" //F3_CODRSEF E F2_FIMP=='T' //NFSe Transmitido 2
			cStatus := "2"
		Case AllTrim(TRBNF->F3_CODRSEF) == "S" //NFSe Autorizado 3
			cStatus := "3"
		Case AllTrim(SF3->F3_CODRSEF) == "N" .AND. !Empty(Alltrim(SF3->F3_CODNFE))//NFSe Autorizado 3
			cStatus := "3"
		Case AllTrim(SF3->F3_CODRSEF) == "N" .AND. Empty(Alltrim(SF3->F3_CODNFE))//NFSe nao autorizado 4
			cStatus := "4"
	EndCase
	
	//+---------------------------------------------------------------------+
	//| Compara os Status das NFS, quando mesmo Status nao envia.           |
	//+---------------------------------------------------------------------+
	ZAC->(DBSETORDER(2))
	If SF3->(FieldPos("F3_YINTGR")) <>0
		If ZAC->(MSSEEK(TRBNF->F3_NFISCAL+ALLTRIM(cStatus)))
			TRBNF->(DBSkip())
			Loop
		EndIf
	EndIf
	
	//+---------------------------------------------------------------------+
	//| Itegra o Status da NF.                                              |
	//+---------------------------------------------------------------------+
	If (lGrv:= U_WGENFAT1(ALLTRIM(TRBNF->F3_NFISCAL),AllTrim(TRBNF->F3_NFELETR),AllTrim(TRBNF->F3_CODNFE),AllTrim(TRBNF->(F3_CODRET+F3_DESCRET)),cStatus,"MFAT001.JOB"))
		
		//+---------------------------------------------------------------------+
		//| Quando ocorrer sucesso na integracao, grava o status enviado...     |
		//+---------------------------------------------------------------------+
		If SF3->(FieldPos("F3_YINTGR")) <>0
			DBSelectArea("SF3")
			DBGoTo(TRBNF->REGISTRO)
			RecLock("SF3",.F.)
			SF3->F3_YINTGR := cStatus
			MSUnLock()
		EndIf
	EndIf
	TRBNF->(DBSkip())
EndDo
If Select("TRBNF")<>0
	DBSelectArea("TRBNF")
	DBCloseArea()
EndIf
If !Empty(cStatus).And. Alltrim(cGeraLog) ==  "S"
	U_WSGEN001("MFAT001","Itegra o Status da NF. Para mais Detalhes consulte Arquivo: WGENFAT1_"+DToS(Date())+".TXT")
EndIf

Return
