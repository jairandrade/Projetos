#Include 'Protheus.ch'
/*
-------------------------------------------------------------------------------
Biblioteca de ponto de Entrada Mata030 - Cadastro de Clientes
-------------------------------------------------------------------------------
*/

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MA030ROT
Ponto de Entrada para adicionar novas funções no Botão Outras Ações do Browser
@type function
@author Carlos CLeuber
@since 09/12/2020
@version 1.0
/*/
User Function MA030ROT
	Local aRet := {}

	Aadd( aRet, { "CyberLog - Valida JSon WMS"		, "U_fVJsonFo()"	 , 0 , 4,0 ,NIL} )
	Aadd( aRet, { "CyberLog - Envia Cliente WMS"	, "processa( {|| U_fExpCli() }, 'Aguarde', 'Exportando Cliente...' )"		, 0 , 4,0 ,NIL} )	
	
Return aRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} fVJsonCl
Rotina para mostrar o Json do Fornecedor
@version 12.1.27
@type function
@author Carlos CLeuber
@since 21/12/2020
/*/
User Function fVJsonCl
Local cJson:= U_fGrJson( GetMv('FZ_WSWMS3') )

EECVIEW( cJson )

Return

/*/{Protheus.doc} fExpProd
Função para exportar os registros em Lote
@type function
@author Carlos CLeuber
@since 21/12/2020
@version 12.1.27
/*/
User Function fExpCli
Local aSA1:= GetArea()
Local aRet:= {}
Local cPerg	:= PadR('WMSEXPSA1',10)

fSX1ExpCli(cPerg)
If Pergunte(cPerg,.T.)

	SA1->(DbSetOrder(1))
	SA1->(DbSeek(FWxFilial("SA1")+MV_PAR01,.T.))
	While ! SA1->(Eof()) .and. SA1->A1_FILIAL=FWxFilial("SA1") .and. SA1->A1_COD <= MV_PAR02

		IncProc("Exportando Codigo " + SA1->A1_COD)
		aRet:= U_fConJson(GetMv('FZ_WSWMS3'))
		If aRet[1]
			RecLock("SA1",.F.)
			SA1->A1_XSTAWMS:= "E"
			SA1->(MsUnlock())
		else
			RecLock("SA1",.F.)
			SA1->A1_XSTAWMS:= "F"
			SA1->(MsUnlock())			
		Endif
		SA1->(DbSkip())
	End

Endif

RestArea(aSA1)

Return

/*/{Protheus.doc} fSX1ExpCli
Cria Grupo de Pergntas
@version 12.1.27
@type function
@author Carlos CLeuber
@since 21/12/2020
/*/
Static Function fSX1ExpCli(cPerg)

cPerg := PADR(cPerg,10)

CheckSX1(cPerg, "01", "Cliente De?"	, "Cliente De?"	, "Cliente De?"	, "mv_ch1"		, "C", TamSX3("A1_COD")[1], 0, 0, "G", "", "SA1"	,"","","MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
CheckSX1(cPerg, "02", "Cliente Ate?", "Cliente Ate?", "Cliente Ate?", "mv_ch2"		, "C", TamSX3("A1_COD")[1], 0, 0, "G", "", "SA1"	,"","","MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")

Return()
