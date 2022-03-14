#Include 'Protheus.ch'
/*
-------------------------------------------------------------------------------
Biblioteca de ponto de Entrada Mata390 - Manutencao de Lotes
-------------------------------------------------------------------------------
*/

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MTA390MNU
Ponto de Entrada para adicionar novas funções no Botão Outras Ações do Browser
@type function
@author Carlos CLeuber
@since 21/012021
@version 1.0
/*/
User Function MTA390MNU

	Aadd( aRotina, { "CyberLog - Valida JSon WMS"		, "U_fVJsonLt()"	 , 0 , 4,0 ,NIL} )

Return 

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fVJsonLt
Rotina para mostrar o Json do Lote
@version 12.1.27
@type function
@author Carlos CLeuber
@since 21/12/2020
/*/
User Function fVJsonLt
Local cJson:= ''
Local cKey:= SD5->D5_PRODUTO+SD5->D5_LOCAL+SD5->D5_LOTECTL

Private cOpera:= 'U' //variavel do tipo private utilização no layout de Geração do JSON tabela ZA2/ZA3/ZA45  B-Lock; D-Unlock; U-Update

DbSelectArea("SB8")
SB8->(DbSetOrder(3))
If SB8->(DbSeek(FwxFilial('SD5')+cKey, .T.))

	cJson:= U_fGrJson( GetMv('FZ_WSWMS7'), 'SB8', 3, 'B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL', FWxFilial('SB8')+cKey )
	EECVIEW( cJson )

Else
	Alert('Lote não localizado!!!')
Endif

Return

/*/{Protheus.doc} MT390VLV  
Responsável por validar a alteração de data de validade de lotes.
@type function
@author Carlos CLeuber
@since 21/12/2020
@version 12.1.27
/*/
User Function MT390VLV 
Local lRet:= .T.

Private cOpera:= "U" //variavel do tipo private utilização no layout de Geração do JSON tabela ZA2/ZA3/ZA45  B-Lock; D-Unlock; U-Update
Private dNewVld := PARAMIXB[1]  

If GetAdvFVal("SBZ","BZ_XINTWMS",xFilial("SBZ")+SD5->D5_PRODUTO,1) == "S"

	aRet:= U_fConJson( GetMv('FZ_WSWMS7'), 'SB8', 3, 'B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL', FWxFilial('SB8')+SB8->B8_PRODUTO+SB8->B8_LOCAL+SB8->B8_LOTECTL ) 
	If ! aRet[1]
		lRet:= .F.
		Alert(aRet[3])
		Alert("Atenção !!!" + CRLF+CRLF+ "*** Data de Validade do Lote não foi Alterada ***")
	Else
		Alert("Data de Validade alterada com sucesso no WMS.")
	Endif
Endif

Return lRet
