#include 'protheus.ch'
#include 'parmtype.ch'
//COmite em 04022020
/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Contabilidade                                                                                                                          |
| Conta Contábil                                                                                                                         |
| Autor: Willian Duda                                                                                                                    |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 14/08/2018                                                                                                                       |
| Descricao: verificação do status da transmissão da Nota Fiscal para contabilização                                                     |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function CTANF()

local aAreaCTK	:= CTK->(GetArea())
local aAreaA1	:= SA1->(GetArea())
local aAreaE1	:= SE1->(GetArea())
local aAreaE5	:= SE5->(GetArea())
Local cQuery	:= " "
Local cCtaCtb	:= " "
Local cSeekA1	:= IIf(SE5->E5_MOTBX == "CMP" .AND. SE5->E5_TIPO $ "RA |NCC",SE5->E5_FORNADT+SE5->E5_LOJAADT,IIF(EMPTY(SE5->E5_CLIENTE),SE5->E5_CLIFOR,SE5->E5_CLIENTE)+SE5->E5_LOJA)
Local cSeekE1	:= IIf(SE5->E5_MOTBX == "CMP" .AND. SE5->E5_TIPO $ "RA |NCC",SE5->E5_FILORIG+SE5->E5_FORNADT+SE5->E5_LOJAADT+SUBSTR(SE5->E5_DOCUMEN,1,14),SE5->E5_FILORIG+IIF(EMPTY(SE5->E5_CLIENTE),SE5->E5_CLIFOR,SE5->E5_CLIENTE)+SE5->E5_LOJA+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA)
Local lNfTransm	:= .T.

DBSELECTAREA('SA1')
DBSetOrder(1)
DBSEEK(FWXFILIAL('SA1')+cSeekA1)
cCtaCtb	:= SA1->A1_CONTA

DBSELECTAREA('SE1')
DBSetOrder(2)
If (SE5->E5_MOTBX == "CMP" .AND. SE5->E5_TIPO $ "RA |NCC" .AND. REGVALOR > 0)
	DBGOTO(REGVALOR)
Else
	DBSEEK(cSeekE1)
EndIf

lNfTransm	:= IIF( !SubStr(SE1->E1_ORIGEM,1,3) $ 'MAT|LOJ' ,.F. ,.T. )

If SubStr(SE1->E1_ORIGEM,1,3) $ 'MAT|LOJ'
	DBSELECTAREA('SF2')
	DBSetOrder(1)
	DBSEEK(SE1->E1_FILIAL+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA)
	If ALLTRIM(SF2->F2_ESPECIE) <> "RPS" .AND. !Empty(SF2->F2_ESPECIE)
		lNfTransm := !Empty(SF2->F2_CHVNFE)
	ElseIf ALLTRIM(SF2->F2_ESPECIE) == "RPS" .OR. ( Empty(SF2->F2_ESPECIE) .AND. SF2->F2_SERIE $ "AST|REC|TAM" .AND. SE1->E1_TIPO == "NF " )
		lNfTransm := .T.
	ElseIf Empty(SF2->F2_ESPECIE) .AND. SE1->E1_TIPO == "NF "
			DBSELECTAREA('ZP6')
			DBSetOrder(1)
			If !(DBSEEK(SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM))
				lNfTransm := .F.
			EndIf
	EndIf

//Buscar informações referente a geração de faturas
ElseIf SE1->E1_FATURA == 'NOTFAT   '
	cQuery := "SELECT DISTINCT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_ORIGEM "
	cQuery += "FROM " + RetSQLName("SE1") + " "
	cQuery += " WHERE D_E_L_E_T_ <> '*' " 
	cQuery += " AND E1_FILIAL = '" + SE1->E1_FILIAL + "' "
	cQuery += " AND E1_DTFATUR = '" + DTOS(SE1->E1_EMISSAO) + "' "
	cQuery += " AND E1_FATURA  = '" + SE1->E1_NUM + "' "
	cQuery += " AND E1_FATPREF = '" + SE1->E1_PREFIXO + "' "
	cQuery += " AND E1_CLIENTE = '" + SE1->E1_CLIENTE + "' "
	cQuery += " ORDER BY E1_PREFIXO, E1_NUM, E1_TIPO, E1_CLIENTE "

	If ( SELECT("FAT") ) > 0
		dbSelectArea("FAT")
		FAT->(dbCloseArea())
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"FAT",.T.,.T.)

	dbSelectArea("FAT")
	FAT->(dbGoTop())

	If SubStr(FAT->E1_ORIGEM,1,3) $ 'MAT|LOJ'
		DBSELECTAREA('SF2')
		DBSetOrder(1)
		DBSEEK(FAT->E1_FILIAL+FAT->E1_NUM+FAT->E1_PREFIXO+FAT->E1_CLIENTE+FAT->E1_LOJA)
		If ALLTRIM(SF2->F2_ESPECIE) <> "RPS"
			lNfTransm := !Empty(SF2->F2_CHVNFE)
		ElseIf ALLTRIM(SF2->F2_ESPECIE) == "RPS" .OR. ( Empty(SF2->F2_ESPECIE) .AND. SF2->F2_SERIE $ "AST|REC|TAM" .AND. SE1->E1_TIPO == "NF " )
			lNfTransm := .T.		
		ElseIf Empty(SF2->F2_ESPECIE) .AND. SE1->E1_TIPO == "NF "
			DBSELECTAREA('ZP6')
			DBSetOrder(1)
			If !(DBSEEK(SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM))
				lNfTransm := .F.
			EndIf
		EndIf
	EndIf
//Fim filtro de faturas

		//Buscar informações referente a liquidações	
ElseIf !Empty(SE1->E1_NUMLIQ)
		cQuery := "SELECT DISTINCT E5_FILORIG, E5_PREFIXO, E5_NUMERO, E5_TIPO, E5_CLIFOR, E5_CLIENTE, E5_LOJA, E5_DATA "
		cQuery += "FROM " + RetSQLName("SE5") + " "
		cQuery += " WHERE E5_FILORIG = '" + SE1->E1_FILIAL + "' "
		cQuery += " AND E5_DATA = '" + DTOS(SE1->E1_EMISSAO) + "' "
		cQuery += " AND E5_DOCUMEN = '" + SE1->E1_NUMLIQ + "' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY E5_PREFIXO, E5_NUMERO "

		If ( SELECT("LIQ") ) > 0
			dbSelectArea("LIQ")
			LIQ->(dbCloseArea())
		EndIf

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"LIQ",.T.,.T.)

		TCSETFIELD("LIQ", "E5_DATA"  , "D", 08, 0)
		TCSETFIELD("LIQ", "E5_VALOR" , "N", 14, 2)
		dbSelectArea("LIQ")
		LIQ->(dbGoTop())

		cLiqFil := LIQ->E5_FILORIG
		cLiqPrf := LIQ->E5_PREFIXO
		cLiqNum := LIQ->E5_NUMERO
		cLiqTip := LIQ->E5_TIPO
		cLiqCli := IIF(EMPTY(LIQ->E5_CLIENTE),LIQ->E5_CLIFOR,LIQ->E5_CLIENTE)
		cLiqLoj := LIQ->E5_LOJA

		//Encontrar um dos registros na SE1 para identificar a origem, por critério internos só devem haver liquidações de "tipo", por isso é apenas posicionado uma unica vez no SE1
		cQuery3 := "SELECT DISTINCT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_ORIGEM "
		cQuery3 += "FROM " + RetSQLName("SE1") + " "
		cQuery3 += "WHERE D_E_L_E_T_ <> '*' " 
		cQuery3 += " AND E1_FILIAL  = '" + cLiqFil + "' "
		cQuery3 += " AND E1_PREFIXO = '" + cLiqPrf + "' "
		cQuery3 += " AND E1_NUM     = '" + cLiqNum + "' "
		cQuery3 += " AND E1_TIPO    = '" + cLiqTip + "' "
		cQuery3 += " AND E1_CLIENTE = '" + cLiqCli + "' "
		cQuery3 += " AND E1_LOJA	= '" + cLiqLoj + "' "
		cQuery3 += " ORDER BY E1_PREFIXO, E1_NUM, E1_TIPO, E1_CLIENTE "

		If ( SELECT("LIQ2") ) > 0
			dbSelectArea("LIQ2")
			LIQ2->(dbCloseArea())
		EndIf

		cQuery3 := ChangeQuery(cQuery3)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery3),"LIQ2",.T.,.T.)

		dbSelectArea("LIQ2")
		LIQ2->(dbGoTop())

		If SubStr(LIQ2->E1_ORIGEM,1,3) $ 'MAT|LOJ'
			DBSELECTAREA('SF2')
			DBSetOrder(1)
			DBSEEK(LIQ2->E1_FILIAL+LIQ2->E1_NUM+LIQ2->E1_PREFIXO+LIQ2->E1_CLIENTE+LIQ2->E1_LOJA)
			If ALLTRIM(SF2->F2_ESPECIE) <> "RPS"
				lNfTransm := !Empty(SF2->F2_CHVNFE)
			ElseIf ALLTRIM(SF2->F2_ESPECIE) == "RPS" .OR. ( Empty(SF2->F2_ESPECIE) .AND. SF2->F2_SERIE $ "AST|REC|TAM" .AND. SE1->E1_TIPO == "NF " )
				lNfTransm := .T.
			ElseIf Empty(SF2->F2_ESPECIE) .AND. SE1->E1_TIPO == "NF "
				DBSELECTAREA('ZP6')
				DBSetOrder(1)
				If !(DBSEEK(SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM))
					lNfTransm := .F.
				EndIf
			EndIf
		EndIf
	//Fim do filtro para liquidações
EndIf

If SE1->E1_TIPO == 'CH '
	cCtaCtb := '110206001'
ElseIf !lNfTransm
	If SUBSTR(SE1->E1_NATUREZ,1,3) $"103|104|105|106" .OR. SE1->E1_PREFIXO == "LOC"
		cCtaCtb := Posicione("SED",1,xFilial("SED")+SE1->E1_NATUREZ,"ED_CONTA")
	Else
		cCtaCtb := '210603002'
	EndIf
EndIf

RestArea(aAreaA1)
RestArea(aAreaE1)
RestArea(aAreaE5)
RestArea(aAreaCTK)

Return(cCtaCtb)

/*
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 14/08/2018                                                                                                                       |
| Descricao: Identificar se a liquidação foi com cheque, caso não, retornar a conta contabil conforme a transmissão das notas            |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/
User Function CTALIQ()

local aAreaCTK	:= GetArea()
local aAreaA1	:= SA1->(GetArea())
local aAreaE1	:= SE1->(GetArea())
local aAreaE5	:= SE5->(GetArea())
Local cCtaCtb	:= " "
Local cSeekA1	:= IIf(SE5->E5_MOTBX == "CMP" .AND. SE5->E5_TIPO $ "RA |NCC",SE5->E5_FORNADT+SE5->E5_LOJAADT,IIF(EMPTY(SE5->E5_CLIENTE),SE5->E5_CLIFOR,SE5->E5_CLIENTE)+SE5->E5_LOJA)
Local cSeekE1	:= IIf(SE5->E5_MOTBX == "CMP" .AND. SE5->E5_TIPO $ "RA |NCC",SE5->E5_FILORIG+SE5->E5_FORNADT+SE5->E5_LOJAADT+SUBSTR(SE5->E5_DOCUMEN,1,12),SE5->E5_FILORIG+IIF(EMPTY(SE5->E5_CLIENTE),SE5->E5_CLIFOR,SE5->E5_CLIENTE)+SE5->E5_LOJA+SE5->E5_PREFIXO+SE5->E5_NUMERO)

DBSELECTAREA('SA1')
DBSetOrder(1)
DBSEEK(FWXFILIAL('SA1')+cSeekA1)
cCtaCtb	:= SA1->A1_CONTA

DBSELECTAREA('SE1')
DBSetOrder(2)
DBSEEK(cSeekE1)

DBSELECTAREA('FO0')
DBSetOrder(2)
DBSEEK(FWXFILIAL('FO0')+SUBSTR(SE5->E5_DOCUMEN,1,6))

If FO0->FO0_TIPO <> 'CH '
	cCtaCtb := U_CTANF()
Else
	cCtaCtb := '110206001'
EndIf

RestArea(aAreaA1)
RestArea(aAreaE1)
RestArea(aAreaE5)
RestArea(aAreaCTK)

Return(cCtaCtb)
