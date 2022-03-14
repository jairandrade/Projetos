#Include 'Protheus.ch'
/*
-------------------------------------------------------------------------------
Biblioteca de ponto de Entrada Mata010 - Cadastro de Produtos
-------------------------------------------------------------------------------
*/

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MTA010MNU
Ponto de Entrada para adicionar novas funções no Botão Outras Ações do Browser
@type function
@author Carlos CLeuber
@since 09/12/2020
@version 1.0
/*/
User Function MTA265MNU

	Aadd( aRotina, { "CyberLog - Valida JSon WMS"	, "U_fVJsonAC()"	 , 0 , 4,0 ,NIL} )
	Aadd( aRotina, { "CyberLog - Enviar Aceite WMS"	, "processa( {|| U_fAceiJson() }, 'Aguarde', 'Enviando Aceite do Produto...' )"		, 0 , 4,0 ,NIL} )

Return 

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fVJsonAC
Rotina para mostrar o Json do Produto
@version 12.1.27
@type function
@author Carlos CLeuber
@since 02/02/2021
/*/
User Function fVJsonAC
Local cKey:= SDA->(DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA)
Local cJson:= U_fGrJson( GetMv('FZ_WSWMSA') , 'SDA', 1, 'DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA', FWxFilial('SDA')+cKey )

EECVIEW( cJson )

Return

/*/{Protheus.doc} fAceiJson
Função para efetivar o aceite do produto no WMS
@type function
@author Carlos CLeuber
@since 02/02/2021
@version 12.1.27
/*/
User Function fAceiJson
Local aSDA:= GetArea()
Local cKey:= SDA->(DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA)
Local aRet:= {}

If GetAdvFVal("SBZ","BZ_XINTWMS",xFilial("SBZ")+SDA->DA_PRODUTO,1) == "S"
	aRet:= U_fConJson(GetMv('FZ_WSWMSA'), 'SDA', 1, 'DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA', FWxFilial('SDA')+cKey )
	If ! aRet[1]
		Help( , , 'ATENÇÃO !!!' , , '*** Produto não foi liberado no WMS ***', 1, 0, , , , , , {"Favor Verificar mensgagem de erro na proxima tela!"})        
		Alert(aRet[3])
	Else
		Alert("Envio de Liberação de Estoque do produto enviado ao WMS.")
	Endif
Endif


RestArea(aSDA)

Return

/*/{Protheus.doc} ChvWmsSDA
Retorna o erpId para fazer o Aceite do Produto no WMS
@version 12.1.27
@type function
@author Carlos CLeuber
@since 02/02/2021
/*/
User Function ChvWmsSDA
Local aArea:= GetArea()
Local aSDA:= SDA->(GetArea())
Local cRet:= ''

If SDA->DA_ORIGEM == "SD1"
	DbSelectArea("SD1")
	SD1->(DbSetOrder(4))
	If SD1->(DbSeek(FWxFilial("SD1")+SDA->DA_NUMSEQ,.T.))
		cRet:= SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD+SD1->D1_ITEM
	Endif

ElseIf SDA->DA_ORIGEM == "SD3"
	DbSelectArea("SD3")
	SD3->(DbSetOrder(4))
	If SD3->(DbSeek(FWxFilial("SD3")+SDA->DA_NUMSEQ,.T.))
		cRet:= SD3->D3_FILIAL+SD3->D3_DOC+SD3->D3_COD+SD3->D3_LOTECTL
	Endif

ElseIf SDA->DA_ORIGEM == "SD5"
	cRet:= ''
Endif

RestArea(aSDA)
RestArea(aArea)
Return cRet
