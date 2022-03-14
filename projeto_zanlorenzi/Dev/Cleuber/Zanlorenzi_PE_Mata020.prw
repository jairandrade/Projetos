#Include 'Protheus.ch'
/*
-------------------------------------------------------------------------------
Biblioteca de ponto de Entrada Mata020 - Cadastro de Fornecedores
-------------------------------------------------------------------------------
*/

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MA020ROT
Ponto de Entrada para adicionar novas funções no Botão Outras Ações do Browser
@type function
@author Carlos CLeuber
@since 09/12/2020
@version 1.0
/*/
User Function MA020ROT
	Local aRet := {}

	Aadd( aRet, { "CyberLog - Valida JSon WMS"		, "U_fVJsonFo()"	 , 0 , 4,0 ,NIL} )
	Aadd( aRet, { "CyberLog - Envia Fornecedor WMS"	, "processa( {|| U_fExpFor() }, 'Aguarde', 'Exportando Fornecedor...' )"		, 0 , 4,0 ,NIL} )

Return aRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fVJsonFo
Rotina para mostrar o Json do Fornecedor
@version 12.1.27
@type function
@author Carlos CLeuber
@since 21/12/2020
/*/
User Function fVJsonFo
Local cJson:= U_fGrJson( GetMv('FZ_WSWMS2') )

EECVIEW( cJson )

Return

/*/{Protheus.doc} fExpProd
Função para exportar os registros em Lote
@type function
@author Carlos CLeuber
@since 21/12/2020
@version 12.1.27
/*/
User Function fExpFor
Local aSA2:= GetArea()
Local cPerg	:= PadR('WMSEXPSA2',10)
Local aRet	:= {}

fSX1ExpFor(cPerg)
If Pergunte(cPerg,.T.)

	SA2->(DbSetOrder(1))
	SA2->(DbSeek(FWxFilial("SA2")+MV_PAR01,.T.))
	While ! SA2->(Eof()) .and. SA2->A2_COD <= MV_PAR02

		IncProc("Exportando Codigo " + SA2->A2_COD)
		aRet:= U_fConJson(GetMv('FZ_WSWMS2'))
		If aRet[1]
			RecLock("SA2",.F.)
			SA2->A2_XSTAWMS:= "E"
			SA2->(MsUnlock())
		else
			RecLock("SA2",.F.)
			SA2->A2_XSTAWMS:= "F"
			SA2->(MsUnlock())			
		Endif
		SA2->(DbSkip())
	End

Endif

RestArea(aSA2)

Return

/*/{Protheus.doc} fSX1ExpfOR
Cria Grupo de Pergntas
@version 12.1.27
@type function
@author Carlos CLeuber
@since 21/12/2020
/*/
Static Function fSX1ExpFor(cPerg)

cPerg := PADR(cPerg,10)

CheckSX1(cPerg, "01", "Fornecedor De?"	, "Fornecedor De?"	, "Fornecedor De?"	, "mv_ch1"		, "C", TamSX3("A2_COD")[1], 0, 0, "G", "", "SA2"	,"","","MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "02", "Fornecedor Ate?"	, "Fornecedor Ate?"	, "Fornecedor Ate?"	, "mv_ch2"		, "C", TamSX3("A2_COD")[1], 0, 0, "G", "", "SA2"	,"","","MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")

Return()
