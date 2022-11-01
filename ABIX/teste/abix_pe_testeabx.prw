//#Include "protheus.ch"
//#Include "totvs.ch"
#Include "topconn.ch"
#Include "fwprintsetup.ch"
 
User Function testTss()  //   u_testTss()

Local cChvNfe :="41220506113322000123550010000307691889370646"
Local aArea   := GetArea()

//////////////////////////////////////////////////////////////
Private _cTopAlias := alltrim(getmv("AB_TOPALIA")) //DEFINIÇÃO DO SHEMA DE AMBIENTE ALIAS // tss_abix
Private _cTopDB    := "oracle"          //BANCO DE DADOS UTILIZADO
Private _cTopSrv   := alltrim(getmv("AB_TOPIP")) //= IP DO SERVIDOR //   10.20.0.117 
Private _cTopSrvN  := alltrim(getmv("AB_TOPIP")) //   10.20.0.117  
Private cTopServer
Private cTopAlias


cTop         := IIF(cEmpAnt == '01',_cTopAlias,'bdtsspoatel')  //GetPvProfString("SPED","TOPALIAS",_cTopAlias,GetAdv97())
cTopData     := GetPvProfString("SPED","TOPDATABASE",_cTopDB,GetAdv97())
cTopAlias    := cTopData + "/" + cTop
cTopServer   := GetPvProfString("SPED","TOPSERVER",_cTopSrv,GetAdv97())

LjMsgRun("Conectando em " + _cTopAlias + " " + cTopServer,,,)
TCConType("TCPIP")
nCon := TCLINK(AllTrim(cTopAlias),AllTrim(cTopServer),7890)

If nCon < 0
	MsgStop("Erro conectando SPED: " + alltrim(Str(nCon)) + " - " + AllTrim(cTopAlias) + "-" + AllTrim(cTopServer),"Conexão SPED")
	Return .f.
endif 

cQry := " SELECT * FROM ( "

//cQry += " SELECT NVL(UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(XML_ERP,2000,1)),'') AS TMEMO1   
//cQry += " 	          ,NVL(UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(XML_RET,2000,1)),'') AS TMEMO2 , a.* "   //  parou de funcionar
cQry += " SELECT  A.R_E_C_N_O_  " // Nao tras campo memo. 
cQry += "        FROM SPED150 a "
cQry += "        WHERE D_E_L_E_T_ != '*' "
cQry += "          AND STATUS = 6 "
cQry += "          AND NFE_CHV = '"+ cChvNfe +"'"
cQry += "        ORDER BY SEQEVENTO DESC ) "
cQry += " WHERE ROWNUM = 1 "


If ( SELECT("TMP") ) > 0
	dbSelectArea("TMP")
	TMP->(dbCloseArea())
EndIf


TCQUERY cQry NEW ALIAS "TMP"


dbSelectArea("TMP")
dbGoTop()

IF ( EOF() )
	MsgStop("Não existe Carta de Correção para a Nota Fiscal informada.","Carta de Correção")
	TMP->(dbCloseArea())
	RestArea(aArea)

	Return
ENDIF

MMEMO1     := TMP->XML_ERP     ///Relativo ao envio
MMEMO2     := TMP->XML_RET     ///Retorno da SEFAZ
MNFE_CHV   := TMP->NFE_CHV
MID_EVENTO := TMP->ID_EVENTO
MTPEVENTO  := STR(TMP->TPEVENTO,6)
MSEQEVENTO := STR(TMP->SEQEVENTO,1)
MAMBIENTE  := STR(TMP->AMBIENTE,1)+IIF(TMP->AMBIENTE==1," - Produção", IIF(TMP->AMBIENTE==2," - Homologação" , ""))
MDATE_EVEN := DTOC(TMP->DATE_EVEN)
MTIME_EVEN := TMP->TIME_EVEN
MVERSAO    := STR(TMP->VERSAO,4,2)
MVEREVENTO := STR(TMP->VEREVENTO,4,2)
MVERTPEVEN := STR(TMP->VERTPEVEN,4,2)
MVERAPLIC  := TMP->VERAPLIC
MCORGAO    := STR(TMP->CORGAO,2)+IIF(TMP->CORGAO==13 , " - AMAZONAS",IIF(TMP->CORGAO==35 , " - SAO PAULO" , ""))
MCSTATEVEN := STR(TMP->CSTATEVEN,3)
MCMOTEVEN  := TMP->CMOTEVEN
MPROTOCOLO := STR(TMP->PROTOCOLO,15)

TMP->(dbCloseArea())

RestArea(aArea)

RETURN()
