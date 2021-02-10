#Include 'Protheus.ch'
#Include 'Topconn.ch'
//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM013
Rotina para inserção das ações nas tabelas Z06,Z07,Z08 quando NF for MEDICAO DE CONTRATOS.
Chamada é feita no pe TCP_PE_MATA103.prw

@return 
@author Jair Andrade
@since 06/11/2020

/*/
//-------------------------------------------------------------------------------

User Function ACOM013()
	Local cSql := ""
	Local cQryHdr := ""

	cSql:=" SELECT C7_NUM,C7_ITEM,C7_PRODUTO ,C7_QUANT, C7_TOTAL,C7_DATPRF, C7_EMISSAO "
	cSql+=" FROM "+RetSqlName('SD1')+" SD1"
	cSql+=" INNER JOIN "+RetSqlName('SC7')+"  SC7"
	cSql+=" ON C7_FILIAL = D1_FILIAL"
	cSql+=" AND C7_NUM = D1_PEDIDO"
	cSql+=" AND C7_ITEM = D1_ITEMPC"
	cSql+=" WHERE D1_FILIAL='"+SF1->F1_FILIAL+"'"
	cSql+=" AND D1_DOC='"+SF1->F1_DOC+"'"
	cSql+=" AND D1_SERIE ='"+SF1->F1_SERIE+"'"
	cSql+=" AND D1_FORNECE ='"+SF1->F1_FORNECE+"'"
	cSql+=" AND D1_LOJA ='"+SF1->F1_LOJA+"'"
	cSql+=" AND SD1.D_E_L_E_T_<>'*'"
	cSql+=" AND SC7.D_E_L_E_T_<>'*'"
	cSql+=" ORDER BY C7_NUM "

	IF Select('TRC7')<>0
		TRC7->(DBCloseArea())
	EndIF

	TcQuery cSql new Alias 'TRC7'

	WHILE !TRC7->(EOF())
		RecLock("Z07",.T.)
		Z07->Z07_FILIAL		:= SF1->F1_FILIAL
		Z07->Z07_FORNECE  	:= SF1->F1_FORNECE
		Z07->Z07_LOJA    	:= SF1->F1_LOJA
		Z07->Z07_DOC  		:= SF1->F1_DOC
		Z07->Z07_SERIE     	:= SF1->F1_SERIE
		Z07->Z07_REGRA      := '001'
		Z07->Z07_PEDIDO     := TRC7->C7_NUM
		Z07->Z07_ITEMNF     := TRC7->C7_ITEM
		Z07->Z07_PRODUT     := TRC7->C7_PRODUTO
		Z07->Z07_QTDNF      := TRC7->C7_QUANT
		Z07->Z07_QTDPED     := TRC7->C7_QUANT
		Z07->Z07_TOTAL      := TRC7->C7_TOTAL
		Z07->Z07_DTPREV     := STOD(TRC7->C7_DATPRF)
		Z07->Z07_DTREAL     := STOD(TRC7->C7_EMISSAO)
		Z07->Z07_AVAL01		:= 30
		Z07->Z07_AVAL02		:= 45
		Z07->Z07_AVAL03		:= 15
		Z07->Z07_AVAL04		:= 10
		Z07->Z07_AVAL05		:= 0
		Z07->Z07_COMPRA		:= SF1->F1_IDCOMPR
		MsUnlock()
		TRC7->(DBSkip())
	EndDo

	cQryHdr := " SELECT * FROM "+RetSqlName('Z04')+" WHERE "
	cQryHdr += " Z04_FILIAL = '"+xFilial('Z04')+"' "
	cQryHdr += " AND Z04_REGRA = '001' "
	//AND Z04_ACAO = '1'
	cQryHdr += " AND D_E_L_E_T_ != '*' ORDER BY Z04_CRITER "

	If (Select("Z04HDR") <> 0)
		DbSelectArea("Z04HDR")
		Z04HDR->(DbCloseArea())
	Endif

	TcQuery cQryHdr new Alias 'Z04HDR'
	WHILE !Z04HDR->(EOF())
		RecLock("Z06",.T.)
		Z06->Z06_FILIAL		:= SF1->F1_FILIAL
		Z06->Z06_FORNEC  	:= SF1->F1_FORNECE
		Z06->Z06_LOJA    	:= SF1->F1_LOJA
		Z06->Z06_NOTA  		:= SF1->F1_DOC
		Z06->Z06_SERIE     	:= SF1->F1_SERIE
		Z06->Z06_REGRA  	:= Z04HDR->Z04_REGRA
		Z06->Z06_CRITER    	:= Z04HDR->Z04_CRITER
		Z06->Z06_DCRITE    	:= Z04HDR->Z04_DESC
		Z06->Z06_PESO  		:= Z04HDR->Z04_PESO
		Z06->Z06_PONTOS     := IIF(Z04HDR->Z04_CRITER=='001',30,IIF(Z04HDR->Z04_CRITER=='002',45,Iif(Z04HDR->Z04_CRITER=='003',15,10)))
		Z06->Z06_PTDIG 		:= IIF(Z04HDR->Z04_CRITER=='001',30,IIF(Z04HDR->Z04_CRITER=='002',45,Iif(Z04HDR->Z04_CRITER=='003',15,10)))
		Z06->Z06_OBS     	:= 'Rotina automatica - Medicao de Contratos'
		Z06->Z06_DATA		:= (SF1->F1_RECBMTO)
		Z06->Z06_COMPRA		:= SF1->F1_IDCOMPR
		MsUnlock()
		Z04HDR->(DbSkip())
	EndDo

	RecLock("SF1",.F.)
	SF1->F1_AVALFOR := '1'
	MsUnlock()

return
//-------------------------------------------------------------------------------
/*/{Protheus.doc} ACOM013A
Rotina para EXCLUSAO das ações nas tabelas Z06,Z07 quando NF for MEDICAO DE CONTRATOS.
Chamada é feita no pe TCP_PE_MATA103.prw na opção de EXCLUSÃO

@return 
@author Jair Andrade
@since 11/11/2020

/*/
//-------------------------------------------------------------------------------

User Function ACOM013A()
//Z06 - avaliacao NF x FORNECEDOR -Z06_FILIAL+Z06_FORNEC+Z06_LOJA+Z06_NOTA+Z06_SERIE+Z06_CRITER+Z06_REGRA
	DbSelectArea('Z06')
	Z06->(DbSetOrder(1))
	Z06->(DbGoTop())
	If Z06->(DbSeek(SF1->F1_FILIAL+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE))
		While !Z06->(EOF()) .AND. Z06->Z06_FILIAL=SF1->F1_FILIAL .AND. Z06_FORNEC=SF1->F1_FORNECE .AND. Z06->Z06_LOJA=SF1->F1_LOJA .AND. Z06->Z06_NOTA=SF1->F1_DOC .AND. Z06->Z06_SERIE=SF1->F1_SERIE
			RecLock("Z06",.F.)
			DbDelete()
			MsUnlock()
			Z06->(DbSkip())
		EndDo
	EndIF


//Z07 - avaliacao Itens NF x FORNECEDOR -Z07_FILIAL+Z07_FORNEC+Z07_LOJA+Z07_DOC+Z07_SERIE+Z07_REGRA+Z07_PEDIDO+Z07_PRODUT+Z07_ITEMNF
	DbSelectArea('Z07')
	Z07->(DbSetOrder(1))
	Z07->(DbGoTop())
	If Z07->(DbSeek(SF1->F1_FILIAL+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE))
		While !Z07->(EOF()) .AND. Z07_FILIAL=SF1->F1_FILIAL .AND. Z07_FORNEC=SF1->F1_FORNECE .AND. Z07_LOJA=SF1->F1_LOJA .AND. Z07_DOC=SF1->F1_DOC .AND. Z07_SERIE=SF1->F1_SERIE
			RecLock("Z07",.F.)
			DbDelete()
			MsUnlock()
			Z07->(DbSkip())
		EndDo
	EndIF
Return
