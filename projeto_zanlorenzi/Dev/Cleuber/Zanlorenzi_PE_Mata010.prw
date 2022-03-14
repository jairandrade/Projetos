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
User Function MTA010MNU

	Aadd( aRotina, { "CyberLog - Valida JSon WMS"		, "U_fVJsonPr()"	 , 0 , 4,0 ,NIL} )
	Aadd( aRotina, { "CyberLog - Envia Produto WMS"	, "processa( {|| U_fExpProd() }, 'Aguarde', 'Exportando Produto...' )"		, 0 , 4,0 ,NIL} )

Return 

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fVJsonPr
Rotina para mostrar o Json do Produto
@version 12.1.27
@type function
@author Carlos CLeuber
@since 21/12/2020
/*/
User Function fVJsonPr
Local cJson:= U_fGrJson( GetMv('FZ_WSWMS1') )

EECVIEW( cJson )

Return

/*/{Protheus.doc} fExpProd
Função para exportar os registros em Lote
@type function
@author Carlos CLeuber
@since 21/12/2020
@version 12.1.27
/*/
User Function fExpProd
Local aSB1:= GetArea()
Local cPerg	:= PadR('WMSEXPSB1',10)
Local aRet:= {}

fSX1ExpPro(cPerg)
If Pergunte(cPerg,.T.)

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(FWxFilial("SB1")+MV_PAR01,.T.))
	While ! SB1->(Eof()) .and. SB1->B1_COD <= MV_PAR02

		IncProc("Exportando Codigo " + SB1->B1_COD)
		
		If GetAdvFVal("SBZ","BZ_XINTWMS",xFilial("SBZ")+SB1->B1_COD,1) == "S"
			aRet:= U_fConJson(GetMv('FZ_WSWMS1'))
			If aRet[1]
				RecLock("SB1",.F.)
				SB1->B1_XSTAWMS:= "E"
				SB1->(MsUnlock())
			Else
				RecLock("SB1",.F.)
				SB1->B1_XSTAWMS:= "F"
				SB1->(MsUnlock())		
			Endif
		Endif
		SB1->(DbSkip())
	End

Endif

RestArea(aSB1)

Return


/*/{Protheus.doc} fSX1ExpPro
Cria Grupo de Pergntas
@version 12.1.27
@type function
@author Carlos CLeuber
@since 21/12/2020
/*/
Static Function fSX1ExpPro(cPerg)

cPerg := PADR(cPerg,10)

CheckSX1(cPerg, "01", "Produto De?"		, "Produto De?"		, "Produto De?"		, "mv_ch1"		, "C", TamSX3("B1_COD")[1], 0, 0, "G", "", "SB1"	,"","","MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "02", "Produto Ate?"	, "Produto Ate?"	, "Produto Ate?"	, "mv_ch2"		, "C", TamSX3("B1_COD")[1], 0, 0, "G", "", "SB1"	,"","","MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")

Return()
