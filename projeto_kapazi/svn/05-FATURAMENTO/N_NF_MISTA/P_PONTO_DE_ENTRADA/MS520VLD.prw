#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
#Include "tbiconn.ch"
//==================================================================================================//
//	Programa: MS520VLD		|	Autor: Luis Paulo							|	Data: 19/03/2018	//
//==================================================================================================//
//	Descrição: PONTO DE ENTRADA DE VALIDACAO DE EXCLUSAO DE NF SAIDA								//
//																									//
//==================================================================================================//
User Function MS520VLD()
Local lRet		:= .T.
Local cMarca	:= SF2->F2_OK
Local cNota		:= SF2->F2_DOC
Local cSerie	:= SF2->F2_SERIE
Local cIdNFSE	:= SF2->F2_XIDVNFK
Local aASF2		:= SF2->(GetArea())
Local aASD2		:= SD2->(GetArea())
Local Aret		:=	{}
local NCOMBOBO1 := 0


If SF2->(FieldPos("F2_XIDVNFK")) > 0 .and. SF2->(FieldPos("F2_XTIPONF")) > 0  

	If !Empty(SF2->F2_XIDVNFK) .And. cEmpAnt == '04' .And. cFilAnt == "01" .And. !IsInCallStack("U_DLNFSEKP")
		
			xExFatur(SF2->F2_XIDVNFK) //Exclui as faturas
		
			If Alltrim(SF2->F2_XTIPONF) == "2" .And. cEmpAnt == "04" .And. cFilAnt == "01" .And. lRet //Validar se a NF de servico foi marcada
				DbSelectArea("SF2")
				DbOrderNickName("XINDNFMIST")
				SF2->(DbGotop())
				If SF2->(DbSeek(cIdNFse + "1"))
		
					If SF2->F2_OK != cMarca
						lRet		:= .F.
						MsgStop("A NFSE(NF_MISTA): " + cNota + " Serie: " + cSerie + " nao pode ser excluída pois a NF(PRODUTO)  -> " + SF2->F2_DOC + " Serie -> " + SF2->F2_SERIE + " (ID: "+cIdNFSE+") nao foi marcada!!!" )
					EndIf
					
				EndIf
			EndIf
		
		ElseIf !Empty(SF2->F2_XIDVNFK) .And. cEmpAnt == '04' .And. cFilAnt != "01" .And. !IsInCallStack("U_DLNFSEKP") 
			Conout("Excluindo Fatura")
			If !StartJob("U_NWEXCNFK", GetEnvServer(), .T., cIdNFSE)
					MsgInfo("Fatura nao excluida ,informe o TI!!!")
				Else
					Conout("Fatura excluida com sucesso!!!!")
			EndIf
		
		ElseIf Empty(SF2->F2_XIDVNFK) .And. cEmpAnt == '04'  .And. !IsInCallStack("U_DLNFSEKP")
			If Alltrim(SF2->F2_XPVSPP) == "S"
				xExFatSPP(SF2->F2_DOC) //Exclui as faturas Supplier
			EndIf
		
	EndIf

	If ((!Empty(SF2->F2_XIDVNFK) .And. Alltrim(SF2->F2_XTIPONF) == "2") .or. (	Empty(SF2->F2_XIDVNFK) .and. Empty(SF2->F2_XTIPONF) .and. SF2->F2_SERIE == 'NFS' 	)) .And. cEmpAnt == "04" .And. cFilAnt == "01"
	
		cQuery := " select top 1 R_E_C_N_O_ ZP6RECNO from "+RetSQLName("ZP6")+ " where D_E_L_E_T_ <> '*' and ZP6_FILIAL = '"+xFilial("ZP6")+"' and ZP6_ID = '"+SF2->F2_SERIE + SF2->F2_DOC+"' and ZP6_NOTA <> '' and ZP6_ERRO = '' order by R_E_C_N_O_ desc "	
		TcQuery cQuery new alias "QZP6A"
	
		If QZP6A->(!EOF())
	
			DEFINE MSDIALOG oDlgCanc TITLE "Cancelamento de Nota Fiscal" FROM 000, 000  TO 100, 500 COLORS 0, 16777215 PIXEL
	
			@ 016, 010 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS {"1=Erro na emissão","2=Serviço não prestado","3=Erro de assinatura","4=Duplicidade da nota","5=Erro de processamento"} SIZE 072, 010 OF oDlgCanc COLORS 0, 16777215 PIXEL
			@ 005, 009 SAY oSay1 PROMPT "Selecione o Motivo" SIZE 170, 007 OF oDlgCanc COLORS 0, 16777215 PIXEL
			@ 033, 008 BUTTON oButton1 PROMPT "OK" SIZE 037, 012 OF oDlgCanc ACTION oDlgCanc:End() PIXEL
	
			ACTIVATE MSDIALOG oDlgCanc CENTERED
	
			cCodMun		:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )	
			U_nfseXMLUni( cCodMun, "1", SF2->F2_EMISSAO, SF2->F2_SERIE, SF2->F2_DOC, SF2->F2_CLIENTE, SF2->F2_LOJA, Alltrim(cvaltochar(nComboBo1)), {} )
			Conout("")
			Conout("Chamou o cancelamento da NFS na ZP6")
			Conout("")
		EndIf
		QZP6A->(DbCloseArea())
	
	EndIf
EndIf

RestArea(aASF2)
RestArea(aASD2)	
Return(lRet)


//Exclui a fatura
Static Function xExFatur(cIdNFSE)
Local cAliasE1	:= ""
Local nRegs		:= 0
Local cQuery	:= ""
Local aArea		:= GetArea()
Local nReco		:= 0

If Select("cAliasE1") <> 0
	DBSelectArea("cAliasE1")
	cAliasE1->(DBCloseArea())
Endif

cAliasE1	:= GetNextAlias()

cQuery := " SELECT E1_PREFIXO,E1_NUMLIQ,R_E_C_N_O_ AS RECNOE1
cQuery += " FROM SE1040
cQuery += " WHERE D_E_L_E_T_ = ''
cQuery += " AND E1_XIDVNFK = '"+cIdNFSE+"'
cQuery += " AND E1_PREFIXO = 'FAT'

TCQuery cQuery NEW ALIAS 'cAliasE1'		//depois que a Query é montada é utilizado a função TCQUERY criando uma tabela temporária com o resultado da pesquisa.

DBSelectArea("cAliasE1")
Count To nRegs
cAliasE1->(DbGoTop())

If nRegs > 0
	nReco	:= cAliasE1->RECNOE1
	DbSelectArea("SE1")
	DbGoto(nReco)
	FINA460( , , , 5, , cAliasE1->E1_NUMLIQ )	//Cancelamento da liquidacao

EndIf

cAliasE1->(DBCloseArea())

RestArea(aArea)
Return()

//Exclui a fatura
Static Function xExFatSPP(cDocNF)
Local cAliasE1	:= ""
Local nRegs		:= 0
Local cQuery	:= ""
Local aArea		:= GetArea()
Local nReco		:= 0

If Select("cAliasE1") <> 0
	DBSelectArea("cAliasE1")
	cAliasE1->(DBCloseArea())
Endif

cAliasE1	:= GetNextAlias()

cQuery := " SELECT E1_PREFIXO,E1_NUMLIQ,R_E_C_N_O_ AS RECNOE1
cQuery += " FROM SE1040
cQuery += " WHERE D_E_L_E_T_ = ''
cQuery += " AND E1_NUM = '"+cDocNF+"'
cQuery += " AND E1_PREFIXO = 'FAT'
cQuery += " AND E1_CLIENTE = '999999' 
cQuery += " AND E1_XIDVNFK = ''

TCQuery cQuery NEW ALIAS 'cAliasE1'		//depois que a Query é montada é utilizado a função TCQUERY criando uma tabela temporária com o resultado da pesquisa.

DBSelectArea("cAliasE1")
Count To nRegs
cAliasE1->(DbGoTop())

If nRegs > 0
	nReco	:= cAliasE1->RECNOE1
	DbSelectArea("SE1")
	DbGoto(nReco)
	FINA460( , , , 5, , cAliasE1->E1_NUMLIQ )	//Cancelamento da liquidacao

EndIf

cAliasE1->(DBCloseArea())

RestArea(aArea)
Return()
