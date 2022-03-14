#Include 'Protheus.ch'
/*
-------------------------------------------------------------------------------
Biblioteca de ponto de Entrada Mata275 - Bloqueio de Lotes
-------------------------------------------------------------------------------
*/

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MTA275MNU
Ponto de Entrada para adicionar novas funções no Botão Outras Ações do Browser
@type function
@author Carlos CLeuber
@since 21/012021
@version 1.0
/*/
User Function MTA275MNU

	Aadd( aRotina, { "CyberLog - Valida JSon WMS"		, "U_fVJsonBql()"	 , 0 , 4,0 ,NIL} )

Return 

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fVJsonBql
Rotina para mostrar o Json do Produto
@version 12.1.27
@type function
@author Carlos CLeuber
@since 21/12/2020
/*/
User Function fVJsonBql
Local cJson:= ''
Local cKey:= SDD->DD_PRODUTO+SDD->DD_LOCAL+SDD->DD_LOTECTL

Private cOpera:= 'B'

DbSelectArea("SB8")
SB8->(DbSetOrder(3))
If SB8->(DbSeek(FwxFilial('SD5')+cKey, .T.))

	cJson:= U_fGrJson( GetMv('FZ_WSWMS7'), 'SB8', 3, 'B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL', FWxFilial('SB8')+cKey )
	EECVIEW( cJson )

Else
	Alert('Lote não localizado!!!')
Endif

Return

/*/{Protheus.doc} MT275TOK 
Responsável por validar a alteração de data de validade de lotes.
@type function
@author Carlos CLeuber
@since 21/12/2020
@version 12.1.27
/*/
User Function MT275TOK
Local lRet:= .T.

Private cOpera:= "" //variavel do tipo private utilização no layout de Geração do JSON tabela ZA2/ZA3/ZA45  B-Lock; D-Unlock; U-Update
Private dNewVld := M->DD_DTVALID

If IsInCallStack("A275Bloq")
	cOpera:= "B" //B-Lock; D-Unlock; U-Update

ElseIf IsInCallStack("A275Libe")
	cOpera:= "D" //B-Lock; D-Unlock; U-Update
Else	
	Return lRet
Endif


If GetAdvFVal("SBZ","BZ_XINTWMS",xFilial("SBZ")+M->DD_PRODUTO,1) == "S"

	aRet:= U_fConJson( GetMv('FZ_WSWMS7'), 'SB8', 3, 'B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL', FWxFilial('SDD')+M->DD_PRODUTO+M->DD_LOCAL+M->DD_LOTECTL ) 
	If ! aRet[1]
		lRet:= .F.
		Alert(aRet[3])
		Alert("Atenção !!!" + CRLF+CRLF+ "*** Lote NÃO foi " + iIf( cOpera=="B", "Bloqueado", "Desbloqueado") + " ***")		
	Else
		Alert("Atenção !!!" + CRLF+CRLF+ "*** Lote " + iIf( cOpera=="B", "Bloqueado", "Desbloqueado") + " ***")		
	Endif

Endif

Return lRet
