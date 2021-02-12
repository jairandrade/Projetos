#Include "protheus.ch"
#include "topconn.ch"

/* KESTR20 - Grava log do pedido de venda da tabela ZA */
	User Function KESTR20(cStatus,cArquivo,cObs,cNFiscal,cSerie)
	Local	aArea 		:= GetArea()
	Local	cTabela		:= "ZC"
	
	Default cObs		:= ""
	Default cNFiscal	:= ""
	Default	cSerie		:= ""

	RecLock("Z06",.T.)
		Z06->Z06_FILIAL	:= xFilial("Z06") 
		Z06->Z06_ARQUIV	:= cArquivo 
		Z06->Z06_USUACO	:= RetCodUsr()
		Z06->Z06_USUANO	:= UsrFullName(Z06->Z06_USUACOD)
		Z06->Z06_DATA 	:= Date()
		Z06->Z06_HORA 	:= Time()
		Z06->Z06_CODIGO := cStatus
		Z06->Z06_STATUS := TABELA(cTabela,cStatus)
		Z06->Z06_NFISCA	:= cNFiscal
		Z06->Z06_NFSERI	:= cSerie
		Z06->Z06_OBS	:= cObs
		if AllTrim(cStatus) == "01"
			Z06->Z06_EMPDES	:= ""
			Z06->Z06_FILDES	:= ""
		Else
			Z06->Z06_EMPDES	:= cEmpAnt
			Z06->Z06_FILDES	:= cFilAnt
			Z06->Z06_EMPDES	:= cEmpAnt
			Z06->Z06_FILDES	:= cFilAnt
		Endif
	MsUnLock("Z06")
	
	RestArea(aArea)
return 

/*
	Se o log nao existe ele cria
*/
User Function KESTR20C(cLog,cDesc)
    Local aArea := GetArea()

	DbSelectArea("Z06")
	
    SX5->( DbSetOrder(1))
    If !SX5->( MsSeek(xFilial("SX5")+"ZC"+cLog))
        SX5->( DbGoTop())
        RecLock("SX5",.T.)
            SX5->X5_FILIAL  := xFilial("SX5")
            SX5->X5_TABELA  := "ZC"
            SX5->X5_CHAVE   := cLog
            SX5->X5_DESCRI  := cDesc
            SX5->X5_DESCSPA := cDesc
            SX5->X5_DESCENG := cDesc
        MsUnLock("SX5")
    Endif

    RestArea(aArea)
Return

/*
	01 - ARQUIVO RECEBIDO
	02 - ARQUIVO IMPORTADO
	03 - ERRO NO PROCESSAMENTO
	04 - INFORMATIVO
*/
/*
	exibe o historico de movimentacao do pedido
*/
User Function KESTR20A(cArquivo)
	Local 	aArea 	:= GetArea()
	Local 	cTitulo	:= "Historico de movimentação de arquivo de EDI: "
	Local	cCampos	:= "Z06_ARQUIV,Z06_DATA,Z06_HORA,Z06_CODIGO,Z06_OBS,Z06_USUACO,Z06_USUANO,Z06_STATUS,Z06_NFISCA,Z06_NFSERI"
	Local	cSelect	:= "SELECT "
	Local	cFrom	:= ""
	Local 	lHasMark:= .F.
	Local 	lMax	:= .T.
	
	Default nReg 	:= 0

	cTitulo += AllTrim(cArquivo)+"."
	cFrom += "FROM "+RetSqlName("Z06")+" "

	cFrom += "WHERE D_E_L_E_T_<>'*' "
	cFrom += "	AND Z06_FILIAL = '"+xFilial("Z06")+"' "
	cFrom += "	AND Z06_ARQUIVO = '"+cArquivo+"' "

	cFrom += "ORDER BY Z06_DATA + ' ' + Z06_HORA "

	StaticCall(LISTBOX,dialogListBox,cTitulo,cCampos,cSelect,cFrom,lHasMark,nil,nil,nil,lMax)
	
	RestArea(aArea)
Return












