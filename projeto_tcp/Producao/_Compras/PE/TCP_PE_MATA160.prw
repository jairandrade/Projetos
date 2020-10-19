#Include 'Protheus.ch'
#Include 'TopConn.ch'

/*---------------------------------------------------------------------------+
|                             FICHA TECNICA DO PROGRAMA                      |
+----------------------------------------------------------------------------+
|   DADOS DO PROGRAMA                                                        |
+------------------+---------------------------------------------------------+
|Tipo              | Ponto de entrada                                        |
+------------------+---------------------------------------------------------+
|Modulo            | Compras                                                 |
+------------------+---------------------------------------------------------+
|Nome              | TCP_PE_MATA160                                          |
+------------------+---------------------------------------------------------+
|Descricao         | Fonte de Ponto de Entrada para a Analise de Cotações    |
+------------------+---------------------------------------------------------+
|Autor             | Lucas José Corrêa Chagas                                |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 30/05/2013                                              |
+------------------+---------------------------------------------------------+
|   ATUALIZACOES   |                                                         |
+-------------------------------------------+-----------+-----------+--------+
|   Descricao detalhada da atualizacao      |Nome do    | Analista  |Data da |
|                                           |Solicitante| Respons.  |Atualiz.|
+-------------------------------------------+-----------+-----------+--------+
|                                           |           |           |        |
|                                           |           |           |        |
+-------------------------------------------+-----------+-----------+-------*/

/*--------------------------+----------------------------+--------------------+
| Função:  MT160QRY         | Autor: Lucas J.C. Chagas   | Data: 30/05/2013   |
+------------+--------------+----------------------------+--------------------+
| Parâmetros | PARAMIXB[1] - String que contém o Alias da tabela SC8          |
+------------+----------------------------------------------------------------+
| Descricao  | Ponto de Entrada que filtra os itens de cotação considerados na|
|            | montagem do browse de análise de cotações em ambientes Top     |
|            | Connect.                                                       |
+------------+---------------------------------------------------------------*/
User Function MT160QRY

Local aArea := GetArea()

Local cAlias  := PARAMIXB[1]
Local cFiltro := ""// Expressão do filtro na sintaxe SQL

cFiltro += "C8_MOTCAN = '" + Space(TamSx3('C8_MOTCAN')[1]) + "' "
cFiltro += "AND C8_USUCAN = '" + Space(TamSx3('C8_USUCAN')[1]) + "' "
cFiltro += "AND C8_DTCANC = '" + Space(TamSx3('C8_DTCANC')[1]) + "'"

RestArea(aArea)

Return (cFiltro)


User Function M160STRU
Local aStr 		:= PARAMIXB[1]
Local aCabec 	:= PARAMIXB[2]
Local aCpoSC8 	:= PARAMIXB[3]
Local nPos 		:= aScan(aCpoSC8,"PLN_FORNEC")
Public _oContrato  := NIL
Public _cContrato  := space(tamsx3('C8_XCONTRA')[1])
IF !Empty(SC8->C8_XCONTRA)
	_cContrato  := SC8->C8_XCONTRA
EndIF

dbSelectArea("SX3")
dbSetOrder(2)
If dbSeek("C8_XCONTRA")
	aadd(aStr,{"C8_XCONTRA",TamSX3("C8_XCONTRA")[3],TamSX3("C8_XCONTRA")[1],TamSX3("C8_XCONTRA")[2]})
	aadd(aCabec,{"C8_XCONTRA","",RetTitle("C8_XCONTRA"),PesqPict("SC8","C8_XCONTRA")})
	aAdd(aCpoSC8,"C8_XCONTRA")
EndIf

Return {aStr,aCabec,aCpoSC8}

//-------------------------------------------------------------------
/*/{Protheus.doc} MT160TEL
PONTO DE ENTRADA PARA CRIAR CAMPO NA ANALISE DE COTACAO
@author Rodrigo Slisinski
@since 31/07/2017
@version 1.0
/*/


User Function MT160TEL()
Local oNewDialog  := PARAMIXB[1]
Local aPosGet     := PARAMIXB[2]
Local  nOpcx      := PARAMIXB[3]
Local nRecno      := PARAMIXB[4]
Local ni
DbSelectArea('SC8')
DBgoTo(nRecno)
@ aPosGet[1][1]+20 ,aPosGet[1][2]-25 SAY  "Contrato"  SIZE 30,09 PIXEL OF oScrollBox
@ aPosGet[1][1]+20 ,aPosGet[1][2]+10 MSGET _cContrato SIZE 60,09 WHEN .t. F3 'CN9TCP' valid U_valctr() PIXEL OF oScrollBox

Return

User Function valctr()
Local ni
local nj
Local lRet:=.t.
//se nao tiver contrato retorna
if empty(_cContrato)
	return .t.
EndIF
CN9->(dbSetOrder(1))
if !CN9->(dbSeek(xFilial("CN9")+_cContrato))
	alert("Contrato "+_cContrato+ " não encontrado")
	Return .f.
EndIF


nRec:=SC8->(RECNO())
cNumCt:=SC8->C8_NUM

//pega os fornecedores do contrato informado
CSQL:=" SELECT * FROM "+RetSqlName('CNC')+" "
CSQL+=" WHERE CNC_NUMERO='"+_cContrato+"'
CSQL+=" AND D_E_L_E_T_<>'*'"
If Select('TRCNC')<>0
	TRCNC->(DBCLOSEAREA())
EndIF
TCQuery cSql new Alias 'TRCNC'

If TRCNC->(eof())
	alert("Não existe fornecedor amarrado a este contrato")
	return .f.
Else
	aFornCt:={}
	While !TRCNC->(EOF())
		aadd(aFornCt,TRCNC->CNC_CODIGO+TRCNC->CNC_LOJA)
		TRCNC->(DBsKIP())
	EnDDo
Endif
lTemFornec:=.t.
for ni:=1 to len(aFornCt)
	DBSelectArea('SC8')
	DBSetOrder(1)
	if !DbSeek(xFilial('SC8')+cNumCt+aFornCt[ni])
		lTemFornec:=.f.
	EndIf
Next
SC8->(DBGoto(nRec))

if !lTemFornec
	alert("Contrato informado não esta cadastrado para os fornecedores desta cotação!")
	return .f.
EndIF


/*Verifica planilha*/
lTemPln:=.f.
cSql:=" select CNB_PRODUT,CNB_SLDMED from "+RetSqlName('CN9')+" CN9 "
cSql+=" INNER JOIN "+RetSqlName('CN1')+"  CN1 "
cSql+=" ON CN1_CODIGO = CN9_TPCTO "
cSql+=" INNER JOIN "+RetSqlName('CNB')+"  CNB "
cSql+=" 	ON CNB_FILIAL = CN9_FILIAL "
cSql+=" 	AND CNB_CONTRA = CN9_NUMERO "
cSql+=" 	AND CNB_REVISA = CN9_REVISA "
cSql+=" WHERE CN9_NUMERO ='"+CN9->CN9_NUMERO+"' "
cSql+=" AND CN9_REVISA ='"+CN9->CN9_REVISA+"' "
cSql+=" AND CN1_CTRFIX='1' "
cSql+=" AND CN1.D_E_L_E_T_<>'*' "
cSql+=" AND CN9.D_E_L_E_T_<>'*' "
cSql+=" AND CNB.D_E_L_E_T_<>'*' "
If Select('TRCNB')<>0
	TRCNB->(DBCloseArea())
EndIF

Tcquery cSql New Alias "TRCNB"
if !TRCNB->(EOF())
	lRet:=.f.
	lTemPln:=.t.
EndIF

DBSelectArea('SC8')
dbGoTo(nRec)

if lTemPln
	lTemProd:=.t.
	lTemsaldo:=.t.
	For ni:=1 to len(aFornCt)
		cSql:=" select C8_PRODUTO,SUM(C8_QUANT) TOTAL "
		cSql+=" from "+RetSqlName('SC8')
		cSql+=" WHERE C8_FILIAL='"+SC8->C8_FILIAL+"'"
		cSql+=" AND C8_NUM = '"+SC8->C8_NUM+"'"
		cSql+=" AND D_E_L_E_T_<>'*'"
		cSql+=" and C8_FORNECE+C8_LOJA='"+aFornCt[NI]+"'
		cSql+=" GROUP BY C8_PRODUTO"
		
		IF Select('TRC88')<>0
			TRC88->(DBCloseArea())
		EndIf
		TcQuery cSql New ALias 'TRC88'
		lTemPrd:=.F.
		While !TRC88->(EOF())
			TRCNB->(DBGotop())
			lTemPrd:=.f.
			While !TRCNB->(EOF())
				if alltrim(TRCNB->CNB_PRODUT) == alltrim(TRC88->C8_PRODUTO)
					IF TRCNB->CNB_SLDMED < TRC88->TOTAL
						Alert("O Produto "+alltrim(TRC88->C8_PRODUTO)+" não tem saldo para a medicao!")
						return .f.
					EndIF
					lTemPrd:=.t.
					lRet:=.t.
				EndIf
				TRCNB->(DBsKIP())
			EndDo
			If !lTemPrd   
			
				Alert("O Produto "+alltrim(TRC88->C8_PRODUTO)+" não consta na planilha do contrato.")
				Return .f.
			EndIF
			
			
			
			TRC88->(DBsKIP())
		ENDdO
	Next
EndIF
//Verifica tabela de precos no contrato
lTabPrc:=.f.
cSqL:=" select AIB_CODPRO,AIB_PRCCOM from "+RetSqlName('CN9')+" CN9 "
cSql+=" INNER JOIN  "+RetSqlName('CN1')+" CN1 "
cSql+=" ON CN1_CODIGO = CN9_TPCTO "
cSql+=" INNER JOIN  "+RetSqlName('AIB')+" AIB "
cSql+=" ON AIB_FILIAL = CN9_FILIAL "
cSql+=" AND AIB_CODTAB =CN9_XCODTA "
cSql+=" WHERE CN9_NUMERO ='"+CN9->CN9_NUMERO+"' "
cSql+=" AND CN9_REVISA ='"+CN9->CN9_REVISA+"' "
cSql+=" AND CN1_CTRFIX<>'1' "
cSql+=" AND CN9_XCODTA<>'' "
cSql+=" AND CN1.D_E_L_E_T_<>'*' "
cSql+=" AND CN9.D_E_L_E_T_<>'*' "
cSql+=" AND AIB.D_E_L_E_T_<>'*' "
cSql+=" ORDER BY CN9_NUMERO DESC  "
If Select('TRCNB')<>0
	TRCNB->(DBCloseArea())
EndIF
Tcquery cSql New Alias "TRCNB"
if !TRCNB->(EOF())
	lRet:=.f.
	lTabPrc:=.t.
EndIF

if lTabPrc
	lTemProd:=.f.
	lTemsaldo:=.t.
	While !TRCNB->(EOF())
		if alltrim(TRCNB->AIB_CODPRO) == alltrim(SC8->C8_PRODUTO)
			lTemProd:=.t.
			IF TRCNB->AIB_PRCCOM >= SC8->C8_PRECO
				lRet:= .t.
			Else
				Alert("Valor maior que o informado na tabela de precos!")
				return .f.
			EndIF
		EndIf
		
		
		TRCNB->(DBsKIP())
		
	EndDo
	if !lRet
		alert("Produto nao encontrado na tabela de precos!")
		RETURN .F.
	Endif
EndIF

TRCNC->(DBGOTOP())
lTemFornec:=.f.
DBSelectArea('SC8')
DBSetOrder(1)
if DbSeek(xFilial('SC8')+cNumCt+TRCNC->CNC_CODIGO+TRCNC->CNC_LOJA)
	While !SC8->(EOF()) .AND. SC8->(C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA)==xFilial('SC8')+cNumCt+TRCNC->CNC_CODIGO+TRCNC->CNC_LOJA
		
		dbSelectArea('AIA')
		DbSetOrder(1)
		IF dbSeek(xFilial('AIA')+TRCNC->CNC_CODIGO+TRCNC->CNC_LOJA+CN9->CN9_XCODTA)
			if AIA->AIA_DATDE > DDATABASE
				ALERT("Tabela de preco fora da vigencia")
				return .f.
			EndIF
			IF !EMPTY(AIA->AIA_DATATE)
				if AIA->AIA_DATATE < DDATABASE
					ALERT("Tabela de preco fora da vigencia")
					return .f.
				EndIF
				
			EndIF
			
		EndIF
		
		
		
		RECLOCK('SC8',.F.)
		SC8->C8_XCONTRA:=_cContrato
		Msunlock()
		lTemFornec:=.t.
		SC8->(DBSkip())
	EndDO
EndIF

DBSelectArea('SC8')
dbGoTo(nRec)

if !lTemFornec
	alert("Contrato informado não esta cadastrado para os fornecedores desta cotação!")
	return .f.
EndIF


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MT160AOK
lISTA DE CONTATOS
@author Rodrigo Slisinski
@since 13/07/2017
@version 1.0
/*/
//-------------------CHAMADA TELA PRINCIPAL------------------------------------------------

User function MT160AOK

Local aCabec := {}
Local aItem  := {}
Local cDoc   := ""
Local cArqTrb	:= ""
Local cContra 	:= ""
Local cRevisa 	:= ""
Local aPln		:= PARAMIXB[1]
Local nI		:= 0
Local nj		:= 0
Local cNumCot	:= cA160num

Private lMsHelpAuto := .T.
PRIVATE lMsErroAuto := .F.
nRecbkp:=SC8->(RECNO())
//lGeraGCT:=.T.

aForn:={}
aFornece:={}
aCabec := {}
aItens := {}
aItem := {}
For ni:=1 to len(aPln)
	for nj:=1 to len(aPln[ni])
		if !Empty(aPln[ni,nj,1])
			aadd(aForn,{aPln[ni,nj,2]+aPln[ni,nj,3],aPln[ni,nj,13]})
			if aScan(aFornece,aPln[ni,nj,2]+aPln[ni,nj,3])==0
				AADD(aFornece,aPln[ni,nj,2]+aPln[ni,nj,3])
			EndIF
		EndIF
	Next
Next


for ni:=1 to len(aFornece)
	
	dbSelectArea('SC8')
	DbSetOrder(1)
	dbSeek(xFilial('SC8')+cNumCot+aFornece[NI])
	if(!EMPTY(SC8->C8_XCONTRA))
		CN9->(dbSetOrder(1))
		CN9->(dbSeek(xFilial("CN9")+SC8->C8_XCONTRA))
		CN1->(dbSetOrder(1))
		CN1->(dbSeek(xFilial("CN1")+CN9->CN9_TPCTO))
		lFixo  := (Empty(CN1->CN1_CTRFIX) .OR. (CN1->CN1_CTRFIX == "1"))
		
		nTot:=0
		For nj:=1 to len(aForn)
			if aForn[nj][1]==aFornece[ni]
				dbSelectArea('SC8')
				aItens := {}
				DbSetOrder(1)
				dbSeek(xFilial('SC8')+cNumCot+aFornece[NI]+aForn[nj][2])
				nTot+=SC8->C8_TOTAL
			EndIF
		Next
		
		cDoc := CriaVar("CND_NUMMED")
		reclock('CND',.T.)
		CND->CND_FILIAL	:=  XFILIAL('CND')
		CND->CND_NUMMED :=  cDoc
		CND->CND_ZERO	:=  '2'
		CND->CND_FORNEC	:=  SC8->C8_FORNECE
		CND->CND_LJFORN	:=  SC8->C8_LOJA
		CND->CND_CONTRA :=  SC8->C8_XCONTRA
		CND->CND_REVISA :=  CN9->CN9_REVISA
		CND->CND_COMPET	:= SUBSTR(DTOC(DDATABASE),4)
		CND->CND_VLTOT  :=  nTot
		CND->CND_DTINIC	:= DDATABASE
		CND->CND_DTVENC	:= DDATABASE
		//CND->CND_DTFIM	:= DDATABASE
		CND->CND_CONDPG	:= CN9->CN9_CONDPG
		CND->CND_VLCONT :=  nTot
		CND->CND_MOEDA	:= 1
		CND->CND_XVENC 	:=	Condicao(1,CN9->CN9_CONDPG,,dDataBase)[1][1]
		CND->CND_XVENCR	:= 	DataValida(Condicao(1,CN9->CN9_CONDPG,,dDataBase)[1][1])                                                                                                                                                            
		CND->CND_AUTFRN := '1'
		CND->CND_SERVIC	:= '1'
		CND->CND_ALCAPR	:= 'L'
		CND->(MsUnlock())
		
		cItem:=criavar("CNE_ITEM")
		For nj:=1 to len(aForn)
			if aForn[nj][1]==aFornece[ni]
				cItem:=SOMA1(cItem)
				dbSelectArea('SC8')
				aItens := {}
				DbSetOrder(1)
				dbSeek(xFilial('SC8')+cNumCot+aFornece[NI]+aForn[nj][2])
				SC8->(reclock('SC8',.F.))
				SC8->C8_XMEDI 	:= cDoc
				SC8->C8_XITMEDI	:= cItem
				SC8->(MSUnlock())
				
				
				CNE->(RECLOCK('CNE',.T.))
				CNE->CNE_FILIAL := xFilial('CNE')
				CNE->CNE_ITEM   := cItem
				CNE->CNE_PRODUT	:= SC8->C8_PRODUTO
				CNE->CNE_QUANT	:= SC8->C8_QUANT
				CNE->CNE_VLUNIT	:= SC8->C8_PRECO
				//CNE->CNE_DESCRI := POSICIONE('SB1',1,XFILIAL('SB1')+SC8->C8_PRODUTO,'B1_DESC')
				CNE->CNE_VLTOT  := SC8->C8_TOTAL
				CNE->CNE_CONTRA := SC8->C8_XCONTRA
				CNE->CNE_REVISA := CN9->CN9_REVISA
				CNE->CNE_DTENT	:= DDATABASE
				CNE->CNE_EXCEDE	:='2'
				CNE->CNE_NUMMED := cDoc
				CNE->(MsUnlock())
				
			EndIf
		Next
		
		cUpdate:=" update "+retSqlName('SC8')+" set C8_NUMPED = 'XXXXXX',C8_ITEMPED = 'XXXX' "
		cUpdate+=" WHERE C8_FILIAL='"+xFilial('SC8')+"'"
		cUpdate+=" AND C8_NUM ='"+cNumCot+"'"
		cUpdate+=" AND D_E_L_E_T_<>'*'"
		TCSqlExec(cUpdate) 		
		
		alert("Medicao numero: "+cDoc+" Gerada com Sucesso! ")
	EndIf
Next

dbSelectArea('SC8')
dbgoto(nRecbkp)
Return .t.




User Function AVALCOPC()

Local cNumPed := ''
Local cProd := ''
Local cQtde := ''
Local cContr:= ''
Local cQuery := ''
Local lprj:=.f.
nRecbkp:=SC8->(RECNO())

cNumPed := SC7->C7_NUM
cProd := SC7->C7_PRODUTO
cQtde := SC7->C7_QUANT
cContr:= SC8->C8_XCONTRA
cQuery := ''
IF !EMPTY(cContr)
	// deleta pedido compra
	cArqTrb	:= CriaTrab( nil, .F. )
	cQuery := "SELECT SC7.R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("SC7")+" SC7 "
	cQuery += "  INNER JOIN "+RetSQLName("SC8")+" SC8"
	cQuery += "  	ON C8_FILIAL = C7_FILIAL "
	cQuery += "  	AND C8_NUMPED = C7_NUM "
	cQuery += "  	AND C8_ITEMPED = C7_ITEM "
	cQuery += "  	AND C8_XCONTRA <>''"
	cQuery += " WHERE SC7.C7_FILIAL = '"+xFilial("SC7")+"' "
	cQuery += "   AND SC7.C7_NUM = '"+cNumPed+"' "
	cQuery += "   AND SC7.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SC8.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cArqTrb, .T., .T. )
	
	While !(cArqTrb)->(Eof())
		SC7->(dbGoTo((cArqTrb)->RECNO))
		lprj:=.t.
		//	AtuHistCOI()
		
		Reclock("SC7",.F.)
		SC7->(DbDelete())
		SC7->(MsUnlock())
		(cArqTrb)->(dbSkip())
	EndDo
	(cArqTrb)->( dbCloseArea() )
	
	if !lprj
		return .t.
	EndIF
	//desamarra com a cotacao
	dbSelectArea("SC8")
	cArqTrb	:= CriaTrab( nil, .F. )
	cQuery := "SELECT R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("SC8")+" SC8 "
	cQuery += " WHERE SC8.C8_FILIAL = '"+xFilial("SC8")+"' "
	cQuery += "   AND SC8.C8_XCONTRA = '"+cContr+"' "
	cQuery += "   AND SC8.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cArqTrb, .T., .T. )
	
	While !(cArqTrb)->(Eof())
		SC8->(dbGoTo((cArqTrb)->RECNO))
		Reclock("SC8",.F.)
		SC8->C8_NUMPED := 'XXXXXX'
		SC8->C8_ITEMPED := 'XXXX'
		SC8->(MsUnlock())
		(cArqTrb)->(dbSkip())
	EndDo
	
	(cArqTrb)->( dbCloseArea() )
	
	// desamarra SCR - doc bloqueados
	cArqTrb	:= CriaTrab( nil, .F. )
	cQuery := "SELECT R_E_C_N_O_ as RECNO "
	cQuery += "  FROM "+RetSQLName("SCR")+" SCR "
	cQuery += " WHERE SCR.CR_FILIAL = '"+xFilial("SCR")+"' "
	cQuery += "   AND SCR.CR_NUM = '"+cNumPed+"' "
	cQuery += "   AND SCR.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cArqTrb, .T., .T. )
	
	While !(cArqTrb)->(Eof())
		SCR->(dbGoTo((cArqTrb)->RECNO))
		Reclock("SCR",.F.)
		SCR->(DbDelete())
		SCR->(MsUnlock())
		(cArqTrb)->(dbSkip())
	EndDo
	(cArqTrb)->( dbCloseArea() )
	
	DbSelectArea("SB2")
	DbSetOrder(1)
	If dbseek((XFilial("SB2")+cProd))
		Reclock("SB2",.F.)
		SB2->B2_SALPEDI := (SB2->B2_SALPEDI - cQtde)
		SB2->(MsUnlock())
	Endif
Endif
dbSelectArea('SC8')
dbgoto(nRecbkp)

Return .T.

