#Include "protheus.ch"
#include "topconn.ch"

/* KFATR15 - Grava log do pedido de venda da tabela ZA */
User Function KFATR15(cStatus,cPedido,cItemPV,cDoc,cSerie,cObs,cOcorr,cOcorrDes,cOcorrObs,dData,cHora)
	Local	aArea 		:= GetArea()
	Local 	aAreaSC5	:= SC5->(GetArea())
	Local	cTabela		:= "ZA"
	
	Default	cItemPV		:= ""
	Default	cDoc		:= ""
	Default cSerie		:= ""
	Default cObs		:= ""
	Default cOcorr		:= ""
	Default cOcorrDes	:= ""
	Default cOcorrObs	:= ""
	// permite receber data e hora por parametro para lancar a ocorrencia de transporte 
	// na data e hora da ocorrencia, nao do processamento do arquivo
	Default dData		:= Date()
	Default cHora		:= Time()

	RecLock("SZF",.T.)
		SZF->ZF_FILIAL 	:= xFilial("SZF") 
		SZF->ZF_PEDIDO 	:= cPedido 
		SZF->ZF_USUACOD := RetCodUsr()
		SZF->ZF_USUANOM := UsrFullName(SZF->ZF_USUACOD)
		SZF->ZF_DATA 	:= dData
		SZF->ZF_HORA 	:= cHora
		SZF->ZF_CODIGO 	:= cStatus
		SZF->ZF_STATUS 	:= AllTrim(TABELA(cTabela,cStatus))
		SZF->ZF_DOC 	:= cDoc
		SZF->ZF_SERIE 	:= cSerie
		SZF->ZF_ITEMPV 	:= cItemPV
		
		If SZF->( FieldPos("ZF_OBS") ) > 0
			SZF->ZF_OBS	:= cObs
		Endif
		
		If SZF->( FieldPos("ZF_TROCORR") ) > 0
			SZF->ZF_TROCORR	:= cOcorr
		Endif
		
		If SZF->( FieldPos("ZF_TROCODE") ) > 0
			SZF->ZF_TROCODE	:= cOcorrDes
		Endif
		
		If SZF->( FieldPos("ZF_TROBS") ) > 0
			SZF->ZF_TROBS	:= cOcorrObs
		Endif
		
	MsUnLock("SZF")
	
	//Atualiza Pedido com o último Status
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(xFilial("SC5")+cPedido))
		RecLock("SC5", .F.)
		SC5->C5_XCODSTA := cStatus
		SC5->C5_XDESSTA := Tabela(cTabela,cStatus)
		MsUnlock("SC5")	
	EndIf
	
	RestArea(aAreaSC5)
	RestArea(aArea)
return 

/*
	Se o log nao existe ele cria
*/
User Function KFATR15C(cLog,cDesc,cTabela)
    Local aArea := GetArea()

	Default cTabela := "ZA"

    SX5->( DbSetOrder(1))
    If !SX5->( MsSeek(xFilial("SX5")+cTabela+cLog))
        SX5->( DbGoTop())
        RecLock("SX5",.T.)
            SX5->X5_FILIAL  := xFilial("SX5")
            SX5->X5_TABELA  := cTabela
            SX5->X5_CHAVE   := cLog
            SX5->X5_DESCRI  := cDesc
            SX5->X5_DESCSPA := cDesc
            SX5->X5_DESCENG := cDesc
        MsUnLock("SX5")
    Endif

    RestArea(aArea)
Return

/*
01 - INCLUSAO PEDIDO DE VENDA
02 - LIBERACAO COMERCIAL
03 - LIBERACAO FINANCEIRO
04 - LIBERACAO DE ESTOQUE TOTAL
05 - EMISSAO NOTA FISCAL
06 - EMBARQUE NOTA FISCAL
07 - EXCLUSAO NOTA FISCAL
08 - ALTERACAO PEDIDO DE VENDA
09 - ESTORNO LIBERACAO
10 - REJEICAO FINANCEIRO
11 - PEDIDO ALTERADO
12 - PEDIDO EXCLUIDO
13 - LIBERACAO FINANCEIRO AUTOMATICA, ATUAL <= ANTERIOR
14 - LIBERACAO DE ESTOQUE PARCIAL
15 - TENTATIVA LIBERACAO ESTOQUE NENHUM LIBERADO
16 - TRANSFERENCIA DO PEDIDO PARA EXPEDICAO
17 - ESTORNO TRANSFERENCIA EXPEDICAO
18 - IMPRESSAO PACKING LIST
19 - ALTERADO PESO VOLUME
20 - OCORRENCIA TRANSPORTE
21 - INICIO PRODUCAO
22 - FIM DE PRODUCAO
23 - LIBERAÇÃO FINANCEIRO AUTOMÁTICA, CRÉDITO/RISCO OK
*/

/*
exibe o historico de movimentacao do pedido
*/
User Function KFATR15A(cAlias,nReg,nOpc)
	Local 	aArea 	:= GetArea()
	Local 	cTitulo	:= "Historico de movimentação do pedido: "
	Local	cCampos	:= "ZF_DATA,ZF_HORA,ZF_USUACOD,ZF_USUANOM,ZF_CODIGO,ZF_STATUS,ZF_DOC,ZF_SERIE,ZF_ITEMPV,ZF_TROCORR,ZF_TROCODE,ZF_TROBS"
	Local	cSelect	:= "SELECT "
	Local	cFrom	:= ""
	Local 	lHasMark:= .F.
	Local 	lMax	:= .T.
	
	Default nReg 	:= 0

	if nReg > 0 .and. nReg <> SC5->( Recno() )
		SC5->( DbGoTo(nReg))
	Endif
	
	cTitulo += AllTrim(SC5->C5_NUM)+"."
	cFrom += "FROM "+RetSqlName("SZF")+" "

	cFrom += "WHERE D_E_L_E_T_<>'*' "
	cFrom += "	AND ZF_FILIAL = '"+SC5->C5_FILIAL+"' "
	cFrom += "	AND ZF_PEDIDO = '"+SC5->C5_NUM+"' "

	cFrom += "ORDER BY ZF_DATA + ' ' + ZF_HORA "

	StaticCall(LISTBOX,dialogListBox,cTitulo,cCampos,cSelect,cFrom,lHasMark,nil,nil,nil,lMax)
	
	RestArea(aArea)
Return












