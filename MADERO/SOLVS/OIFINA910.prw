#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FINA910.CH"
#INCLUDE "FINA910A.CH"
#INCLUDE "SHELL.CH"

#DEFINE GRIDMAXLIN 10000

//#TB20200205 Thiago Berna - Ajuste
//#DEFINE MAGIC_VALUE -120
#DEFINE MAGIC_VALUE -115

#DEFINE CRLF CHR(13) + CHR(10)

//Definição de variáveis Static
Static __aSelFil	As Array
Static __cCpoSE1	As Character
Static __cCpoFIF	As Character
Static __bVldSE1	As Codeblock
Static __bVldFIF	As Codeblock
Static __lCheck01	As Logical
Static __lCheck02	As Logical
Static __lCheck03	As Logical
Static __lCheck08	As Logical
Static __nFldPar	As Numeric
Static __oF910ADM	As Object
Static __cAdmFin	As Character
Static __cSM0Lay	As Character
Static __lSOFEX		As Logical
Static __lSmtHTML	As Logical
Static __oDescri	As Object 

//#TB20200122 Thiago Berna - Ajuste referente ao cabe�alho da aba fechamento
Static __oRefer		As Object
Static __oDinhe		As Object
Static __oTotal		As Object
Static __oDebit		As Object
Static __oStatu		As Object
Static __oCredi		As Object
Static __oTaxas		As Object
Static __oValFIF	As Object
Static __oValSE1	As Object

Static __cFilAnt	As Character 
Static __lOracle	As Logical
Static __cTamNSU	As Character
Static __lTodFil    As Logical
Static __nFIFFLD1   As Numeric
Static __nFIFFLD2   As Numeric
Static __NFIFFLD3	As Numeric
Static __nSE1FLD3   As Numeric
Static __nFIFFLD4   As Numeric
Static __nSE1FLD4   As Numeric
Static __nFIFFLD5   As Numeric
Static __nValFIF	As Numeric
Static __nValSE1	As Numeric
Static __nQtdSE1	As Numeric
Static __cF14FilAnt As Character

Static nTamBanco
Static nTamAgencia
Static nTamCC

Static nCodTimeOut		:= 90  

Static lPontoF			:= ExistBlock("FINA910F")		//Variavel que verifica se ponto de entrada esta' compilado no ambiente

Static __nThreads 
Static __nLoteThr 
Static __lProcDocTEF
Static __lDefTop		:= NIL
Static __lConoutR		:= FindFunction("CONOUTR")
Static __aBancos		:= {}
Static __lDocTef		:= FieldPos("FIF_DOCTEF") > 0
Static __nFldPar		:= 0
Static __aSelFil	    := {}
Static __cVarComb       := ""
Static __aVarComb       := {}

Static nTamBanco
Static nTamAgencia
Static nTamCC
Static nTamCheque
Static nTamNatureza

Static nTamParc
Static nTamParc2
Static nTamNSUTEF
Static nTamDOCTEF

Static lMEP
Static lTamParc
Static lA6MSBLQL

Static cAdmFinanIni		:= ""		//Codigo Inicial da Administradora Financeira que esta' efetuando o pagamento para a empresa
Static cConcilia		:= ""		//Tipos de Baixa: 1- Baixa individual / 2-Baixa por lote
Static nQtdDias			:= 0		//O numero de dias anteriores ao da data de crédito que sera' utilizada como referencia de pesquisa nos titulos
Static nNsuCons			:= 0		//Valida o NSU e comprovante selecionado
Static nMargem			:= 0		//Parametro utilizado para que titulos que estao com valores a menor no SITEF possam entrar na pasta de conciliados mediante tolerancia em percentual informada
Static dDataCredI		:= cTod("")	//Data de credito inicial que a administradora credita o valor para a empresa
Static dDataCredF		:= cTod("")	//Data de credito final que a administradora credita o valor para a empresa
Static cNsuInicial		:= ""
Static cNsuFinal		:= ""
Static cSelFilial		:= 0
Static cTipoPagam		:= 0
Static lUseFIFDtCred	:= .F.
Static lFifRecSE1
Static lUsaMep        	:= SuperGetMv("MV_USAMEP",.T.,.F.)
Static _oFINA910A					//Objeto para receber comandos da classe FwTemporaryTable
Static __oF910ADM		:= NIL		//Objeto para manipulação da consulta especifica
Static __cAdmFin		:= ""
Static __lSOFEX			:= .T.
Static lMsgTef			:= .T.
Static __cF14FilAnt 	:= ""

Static __lLJGERTX		:= SuperGetMv( "MV_LJGERTX" , .T. , .F. )
Static __aOrd           := {}
Static __cGuia			:= ""
Static __nCOL			:= 0
Static __lBxCnab		:= SuperGetMv( "MV_BXCNAB" , .T. , 'N' ) == 'S'

//#TB20200415 Thiago Berna - Comentado por gerar erro ao ser executado via SIGAMDI(Variaveis n�o s�o utilizadas)
//Static __cPicSALD       := PesqPict("SE1","E1_SALDO")
//Static __cPicVL         := PesqPict("FIF",Iif(__lLJGERTX,"FIF_VLBRUT","FIF_VLLIQ"))

Static __cFilTef := ""
Static cLib   	 := ""
Static cHora     := StrTran(Left(Time(),8),':','')

//-------------------------------------------------------------------
/*/{Protheus.doc} OIFINA910
Conciliacao de Pagamentos

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
User Function OIFINA910()

	//Local oBrowse 	As Object
	Local cQuery	As Character

	//#TB20200121 Thiago Berna - Nova Aba de fechamento
	Private oBrowseM 	As Object
	Private cRefer		As Character
	Private cStatu		As Character
	Private cParc460	As Character
	Private nDinhe		As Numeric
	Private nTotal		As Numeric
	Private nDebit		As Numeric
	Private nCredi		As Numeric
	Private nTaxas		As Numeric
	Private nTaxCC		As Numeric
	Private nTaxCD		As Numeric
	Private nTaxAbe 	As Numeric
	Private aFIF		As Array
	Private aFIFSeq		As Array
	Private aTitTax		As Array
	Private aTitTaxC	As Array
	Private aTitTaxD	As Array 
	Private lNConc		As Logical
	Private lContab		As Logical

	lNConc		:= .F.
	lContab		:= .F.
	cRefer		:= ""
	cStatu		:= ""
	cParc460	:= Space(3)	
	nDinhe		:= 0
	nTotal		:= 0
	nDebit		:= 0
	nCredi		:= 0
	nTaxas		:= 0
	nTaxCC		:= 0
	nTaxCD		:= 0
	nTaxAbe		:= 0
	__nValFIF	:= 0
	__nValSE1	:= 0
	__nQtdSE1	:= 0
	aFIF		:= {}
	aFIFSeq		:= {}
	aTitTax		:= {}
	aTitTaxC	:= {}
	aTitTaxD	:= {}
	cQuery 		:= ""

	//#TB20200813.ini Thiago Berna - Excluir essa parte 
	/*If __cUserId != '000423'
		MsgInfo('Rotina em Processo de Ajuste','Atencao')
		Return
	EndIf*/
	//#TB20200813.fim Thiago Berna - Excluir essa parte

	//#TB20200204 Thiago Berna - Ajuste temporario do campo E1_NSUTEF
	cQuery := " UPDATE " + RetSqlName("SE1")
   	cQuery += " SET E1_NSUTEF = LPAD(CAST(E1_DOCTEF AS INT),12,0)  "
	cQuery += " WHERE E1_NSUTEF = ' ' "
	cQuery += " AND E1_DOCTEF <> ' ' "
	
	
	Processa({|| TCSQLExec(cQuery) },'Ajuste provis�rio SE1 1 de 2')	
	
	//#TB20200204 Thiago Berna - Ajuste temporario do campo E1_NSUTEF
	cQuery := " UPDATE " + RetSqlName("SE1")
   	cQuery += " SET E1_NSUTEF = LPAD(CAST(E1_NSUTEF AS INT),12,0)  "
	cQuery += " WHERE E1_NSUTEF <> ' ' "
	
	Processa({|| TCSQLExec(cQuery) },'Ajuste provis�rio SE1 2 de 2')
	//#TB20200204 Thiago Berna - Fim do ajuste temporario do campo E1_NSUTEF

	//Inicialização de variáveis Static
	__aSelFil	:= {}
	//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_EMISSAO
	//__cCpoSE1	:= "|OK|E1_FILIAL|E1_PREFIXO|E1_NUM|E1_PARCELA|E1_TIPO|E1_NATUREZ|E1_CLIENTE|E1_LOJA|E1_NOMCLI|E1_EMISSAO|E1_VENCTO|E1_VENCREA|E1_VALOR|E1_SALDO|E1_DOCTEF|E1_FILORIG|E1_VLRREAL|CONCILIAR|E1_CARTAUT|E1_NSUTEF| "
	//#TB20200128 Thiago Berna - Ajuste para incluir o campo E1_XDESCAD
	//__cCpoSE1	:= "|OK|E1_FILIAL|E1_PREFIXO|E1_NUM|E1_PARCELA|E1_TIPO|E1_NATUREZ|E1_CLIENTE|E1_LOJA|E1_NOMCLI|E1_XDTCAIX|E1_VENCTO|E1_VENCREA|E1_VALOR|E1_SALDO|E1_DOCTEF|E1_FILORIG|E1_VLRREAL|CONCILIAR|E1_CARTAUT|E1_NSUTEF| "
	__cCpoSE1	:= "|OK|E1_FILIAL|E1_PREFIXO|E1_NUM|E1_PARCELA|E1_TIPO|E1_NATUREZ|E1_CLIENTE|E1_LOJA|E1_NOMCLI|E1_XDTCAIX|E1_VENCTO|E1_VENCREA|E1_VALOR|E1_SALDO|E1_DOCTEF|E1_FILORIG|E1_VLRREAL|CONCILIAR|E1_CARTAUT|E1_NSUTEF|E1_XDESCAD|E1_XHORAV|E1_XNSUORI| "
	
	//#TB20200128 Thiago Berna - Ajuste para incluir o campo FIF_CODRED
	//__cCpoFIF	:= "|OK|FIF_FILIAL|FIF_NSUTEF|FIF_DOCTEF|FIF_PARALF|FIF_CODEST|FIF_DTTEF|FIF_NURESU|FIF_NUCOMP|FIF_NUMCART|FIF_VLBRUT|FIF_VLLIQ|FIF_TPPROD|FIF_CODBCO|FIF_CODAGE|FIF_NUMCC|FIF_VLCOM|FIF_TXSERV|FIF_CODAUT|FIF_CODBAN|FIF_STATUS|FIF_TPREG|FIF_PARCEL|FIF_CODLOJ|FIF_DTCRED|FIF_SEQFIF|FIF_PGJUST|FIF_PGDES1|FIF_PGDES2|FIF_CODFIL|FIF_CODADM|FIF_CODMAJ|FIF_CODUSER|FIF_NSUARQ|FIF_NUM|FIF_PARC|FIF_PREFIX| "
	__cCpoFIF	:= "|OK|FIF_FILIAL|FIF_NSUTEF|FIF_DOCTEF|FIF_PARALF|FIF_CODEST|FIF_DTTEF|FIF_NURESU|FIF_NUCOMP|FIF_NUMCART|FIF_VLBRUT|FIF_VLLIQ|FIF_TPPROD|FIF_CODBCO|FIF_CODAGE|FIF_NUMCC|FIF_VLCOM|FIF_TXSERV|FIF_CODAUT|FIF_CODBAN|FIF_STATUS|FIF_TPREG|FIF_PARCEL|FIF_CODLOJ|FIF_DTCRED|FIF_SEQFIF|FIF_PGJUST|FIF_PGDES1|FIF_PGDES2|FIF_CODFIL|FIF_CODADM|FIF_CODMAJ|FIF_CODUSER|FIF_NSUARQ|FIF_NUM|FIF_PARC|FIF_PREFIX|FIF_CODRED|FIF_HRTEF "

	__bVldSE1	:= {|x| AllTrim(x) $ __cCpoSE1}
	__bVldFIF	:= {|x| AllTrim(x) $ __cCpoFIF}
	__lCheck01	:= .F.
	__lCheck02	:= .F.
	__lCheck03	:= .F.
	__lCheck08	:= .F.
	__nFldPar	:= 0
	__oF910ADM	:= NIL
	__cAdmFin	:= ""
	__cSM0Lay	:= ALLTRIM(FWSM0Layout())
	__lSOFEX	:= .T.
	__lSmtHTML	:= (GetRemoteType() == 5)
	__cFilAnt	:= cFilAnt
	__lOracle	:= TcGetDb() $ "INFORMIX*ORACLE"
	__nFIFFLD1  := 0
	__nFIFFLD2  := 0
	__nFIFFLD3	:= 0
	__nSE1FLD3  := 0
	__nFIFFLD4  := 0
	__nSE1FLD4  := 0
	__nFIFFLD5  := 0
	
	GetRemoteType(@clib)
	
	If __nThreads == Nil 
		__nThreads	:= SuperGetMv( "MV_BLATHD" , .T. , 1 )	// Limite de 20 Threads permitidas
	EndIf
	
	If __lProcDocTEF == Nil
	    __lProcDocTEF  := SuperGetMv( "MV_BLADOC" , .T. , .F. ) // Verifica se irá processar pelo DOCTEF ou pelo NSUTEF. Padrão é pelo NSUTEF
	Endif
	
	If __cTamNSU == Nil
		__cTamNSU		:= Alltrim(Str(TamSX3( "FIF_NSUTEF" )[1]))
	End
	
	If nTamBanco == Nil
		nTamBanco		:= TAMSX3("A6_COD")[1]
	Endif
	
	If nTamAgencia == Nil 
		nTamAgencia	:= TamSX3("A6_AGENCIA")[1]
	Endif
	
	If nTamCC == Nil
		nTamCC		:= TAMSX3("A6_NUMCON")[1]
	Endif
	
	If lMEP == Nil 
		lMEP		:= AliasInDic("MEP")
	Endif
	
	SetKey(019, {||}) //Desabilita CTRL+S para prevenir error.log

	oBrowseM := BrowseDef()

	oBrowseM:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Definicoes do Browse

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static Function BrowseDef() As Object
    Local oBrowse As Object

    oBrowse := FwMBrowse():New()

    oBrowse:SetAlias("FIF")

    oBrowse:SetDescription( "Conciliacao Pagamentos")		//"Conciliação Vendas"
	/*
	-------------------------------------------------------------------
		Legendas
	-------------------------------------------------------------------
	*/
    oBrowse:AddLegend("FIF_STATUS $ '1'", "BR_VERDE"	, "N�o Processado"		)		//#"Não Processado"
    oBrowse:AddLegend("FIF_STATUS $ '2'", "BR_VERMELHO"	, "Conciliado Normal"	)		//#"Conciliado Normal"
    oBrowse:AddLegend("FIF_STATUS $ '3'", "BR_AMARELO"	, "Divergente"			)		//#"Divergente"
    oBrowse:AddLegend("FIF_STATUS $ '4'", "BR_AZUL"		, "Conciliado Manual"	)		//#"Conciliado Manual"
    oBrowse:AddLegend("FIF_STATUS $ '5'", "BR_BRANCO"	, "Descartado"			)		//#"Descartado"
    oBrowse:AddLegend("FIF_STATUS $ '6'", "BR_LARANJA"	, "Ant. Nao Processada"	)		//#"Ant. Nao Processada"
    oBrowse:AddLegend("FIF_STATUS $ '7'", "BR_PINK"		, "Antecipado"			)		//#"Antecipado"	

	// Botões
	oBrowse:AddButton("Alterar"		, {|| U_OI910Ed()	, oBrowse:Refresh() }) 	//#"Alterar"
	oBrowse:AddButton("Conciliacao"	, {|| U_OI910Vw()	, oBrowse:Refresh() }) 	//#"Conciliacao"
	oBrowse:AddButton("Pesquisar"	, {|| AxPesqui()	, oBrowse:Refresh()	})	//#"Pesquisar"
	oBrowse:AddButton("Visualizar"	, {|| U_OI910Vs()	, oBrowse:Refresh() }) 	//#"Visualizar"
	oBrowse:AddButton("Listagem Reg", {|| U_OIF910C()	, oBrowse:Refresh() }) 	//#"Listagem Reg"
	//teste
    //oBrowse:SetFilterDefault(GetFilter(0, "FIF"))

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definicoes de Menu

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static Function MenuDef() As Array
	Local aRotina As Array

	aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar"	ACTION "VIEWDEF.OIF910A"	OPERATION MODEL_OPERATION_VIEW   ACCESS 0		//"Visualizar"
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} OIF910View
Acionamento da View

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
User Function OI910Vw()

	Local cTitulo		As Character		
	Local cPrograma		As Character
	Local aBtnView		As Array
	Local nRet			As Numeric
	Local oModel		As Object
	Local bCancel		As Codeblock
	Local bOk			As Codeblock
	Local bCloseOnOk	As Codeblock
	
	If OIF910Perg()
	
		MV_PAR04		:= ""
		MV_PAR05		:= "ZZZZZZ"
		MV_PAR06		:= 1
		MV_PAR07		:= 3
		MV_PAR08		:= 0
		MV_PAR09		:= 0
		MV_PAR10		:= ""
		MV_PAR11		:= 2
		MV_PAR12		:= 2
		MV_PAR13		:= 2
		MV_PAR14		:= 1
		
		dDataCredI		:= MV_PAR02
		dDataCredF		:= MV_PAR02	//If(Empty(MV_PAR03), MV_PAR02, MV_PAR03)
		cConcilia		:= 1		//MV_PAR06
		nQtdDias		:= 0		//MV_PAR08
		nNsuCons		:= 2		//MV_PAR12
		//cAdmFinanIni	:= Iif(!Empty(Alltrim(MV_PAR10)), FormatIn(Alltrim(MV_PAR10), ";"), "")
		
		lUseFIFDtCred	:= .F. 		//( MV_PAR11 == 2 ) // "Credito SITEF"
		cNsuInicial		:= "      "	//MV_PAR04
		cNsuFinal		:= "ZZZZZZ"	//MV_PAR05
		cTipoPagam		:= 3		//MV_PAR07
		cSelFilial		:= 2		//MV_PAR01
		
		//If Empty(MV_PAR09)
			nMargem := 0
		//Else
		//	nMargem = MV_PAR09
		//EndIf

		//#TB20200129 Thiago Berna - Ajuste para executar a conciliacao POS
		//If MV_PAR15 == 1
			fConcPOS()
		//EndIf

		cTitulo		:= "Concilia��o TEF"		//"Conciliação TEF"
		cPrograma	:= "OIFINA910"
		aBtnView    := {{.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}, {.T., NIL}, {.T., NIL}, {.T., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}, {.F., NIL}}
		nRet        := 0
		oModel      := NIL
		bCancel		:= {|| OIF910Canc() }
		bOk			:= {|| U_OIF910OK(oModel) }
		//bCloseOnOk	:= {|| .F. }
		__lTodFil   := .F.
		
		If cSelFilial == 1
			//Gestão - Selecao das Filiais
			__aSelFil := AdmGetFil(@__lTodFil, .T., "FIF")
		EndIf

		If cSelFilial == 2 .Or. Len(__aSelFil) > 0 

			//Processamento por Aba
			//If MV_PAR13 == 1
				//Aba para Processamento
			//	__nFldPar := MV_PAR14
			//Else
				__nFldPar := 0
			//Endif

			//While nRet == 0

				oModel	:= FWLoadModel("OIFINA910")

				//#TB20200207 Thiago Berna - AJuste para travar os registros
				If U_F910LckA()
					//oModel	:= FWLoadModel("OIFINA910")
					nRet	:= FWExecView(cTitulo, cPrograma, MODEL_OPERATION_UPDATE, /*oDlg*/, /*bCloseOnOk*/, /*bOk*/{|| U_OIF910OK(oModel) }, /*nPercReducao*/, aBtnView, bCancel, /*cOperatId*/, /*cToolBar*/, oModel)
					//oModel:Destroy()
				Else
					If MsgYesNo("Controle de Concorr�ncia, Item em uso por outra sess�o e n�o poder� ser selecionado. " + CRLF + "Deseja tentar novamente? ")
						nRet := 0
					Else
						nRet := -1
					EndIf
				EndIf
			//EndDo

			oModel:Destroy()
			oBrowseM:Refresh()

		EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do Modelo de Dados

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static Function ModelDef() As Object
	Local bVldOk	As Codeblock
	Local bLoadTot	As Codeblock
	Local oModel	As Object
	Local oStHead	As Object
	Local oStrFIF01	As Object
	Local oStrSE101	As Object
	Local oStrSE105	As Object
	Local oStrFIF02	As Object
	Local oStrSE102	As Object
	Local oStrSE103	As Object
	Local oStrFIF04	As Object
	Local oStrSE104	As Object
	Local oStrFIF05	As Object
	Local oStrTot06	As Object

	//#TB20200121 Thiago Berna - Nova Aba de fechamento
	Local oStrTot07	As Object
	Local bLoadFec	As Codeblock

	//#TB20200217 Thiago Berna - Ajuste para criar a aba de pagamento
	Local oStrFIF6A	As Object
	Local oStrSE16A	As Object

	Local bValid	As Codeblock
		
	oModel 		:= MPFormModel():New("FINA916")
	oStHead		:= StrHead(1)
	oStrTot06	:= StrTot(1)
	
	//#TB20200121 Thiago Berna - Nova Aba de fechamento
	oStrTot07	:= Fechamento(1)
	
	bValid		:= FWBuildFeature( STRUCT_FEATURE_VALID	, 'ExistCpo("FVX")'	) //Bloco de código para o valid do campo FVX_CODIGO

	/*
	-------------------------------------------------------------------
		Cabeçalho - Tabela Virtual
	-------------------------------------------------------------------
	*/
	oModel:AddFields("TMPHEADER", NIL, oStHead, NIL, NIL, {|| {"1"}})
	oModel:SetPrimaryKey({"STATUS"})
	oModel:GetModel("TMPHEADER"):SetDescription("Concilia��o TEF")		//"Conciliação Vendas"
	oModel:SetDescription("Concilia��o TEF")		//"Conciliação Vendas"
	oModel:GetModel("TMPHEADER"):SetOnlyQuery(.T.)
	
	If __nFldPar == 0 .OR. __nFldPar == 1
	
		//bVldOk 			:= {|oModGrid| OIF910Lck(oModGrid)}
		
		oStrFIF01		:= FWFormStruct(1, "FIF", __bVldFIF)
		oStrSE101		:= FWFormStruct(1, "SE1", __bVldSE1)	
		/*
		-------------------------------------------------------------------
			Folder 1 - Conciliados
		-------------------------------------------------------------------
		*/
		//FIF - Registros de Vendas
		oModel:AddGrid("FIFFLD1", "TMPHEADER", oStrFIF01)
		
		oModel:SetRelation("FIFFLD1", {{"'1'", "TMPHEADER.STATUS"}}, /*FIF->(IndexKey(1))*/ "FIF_CODFIL+FIF_NSUTEF+DTOS(FIF_DTTEF)+STR(FIF_VLBRUT)")
		oModel:GetModel("FIFFLD1"):SetDescription("Conciliados")		//"Conciliados"
		oModel:GetModel("FIFFLD1"):SetLoadFilter(NIL, GetFilter(1, "FIF"))
		oModel:GetModel("FIFFLD1"):SetNoDeleteLine(.T.)
		oModel:GetModel("FIFFLD1"):SetNoInsertLine(.T.)
		oModel:GetModel("FIFFLD1"):SetOptional(.T.)
		oModel:GetModel("FIFFLD1"):SetOnlyQuery(.T.)

		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("FIFFLD1"):SetMaxLine(GRIDMAXLIN)
	
		//Insere campo de Selecao do Registro nas Grids
		bVldOk 			:= {|oModGrid, cCampo, lValue, lOldVal| fVldOk(oModGrid, cCampo, lValue, /*lOldVal*/) .And. OIF910Lck(oModGrid, 1)}
		AddField(1, oStrFIF01, bVldOk,1)
		
		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 1, oStrFIF01)

		oModel:AddGrid("SE1FLD1", "FIFFLD1", oStrSE101)
		If __lOracle
			//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_EMISSAO
			//oModel:SetRelation("SE1FLD1", {{"E1_FILORIG", "FIFFLD1.FIF_CODFIL"},{"LPAD(TRIM(E1_NSUTEF), "+__cTamNSU+", '0')","FIFFLD1.FIF_NSUTEF" },{"E1_PARCELA", "FIFFLD1.FIF_PARALF"},{"E1_EMISSAO", "FIFFLD1.FIF_DTTEF"},{"E1_CARTAUT","FIFFLD1.FIF_CODAUT"}}, SE1->(IndexKey(1)))// //}, SE1->(IndexKey(1))) 
			//#TB20200205 Thiago Berna - Ajuste para desconsiderar o codigo de autorizacao e parcela
			//oModel:SetRelation("SE1FLD1", {{"E1_FILORIG", "FIFFLD1.FIF_CODFIL"},{"LPAD(TRIM(E1_NSUTEF), "+__cTamNSU+", '0')","FIFFLD1.FIF_NSUTEF" },{"E1_PARCELA", "FIFFLD1.FIF_PARALF"},{"E1_XDTCAIX", "FIFFLD1.FIF_DTTEF"},{"E1_CARTAUT","FIFFLD1.FIF_CODAUT"}}, SE1->(IndexKey(1)))// //}, SE1->(IndexKey(1))) 
			//#TB20200212 Thiago Berna - Ajuste para melhoria de desempenho
			//oModel:SetRelation("SE1FLD1", {{"E1_FILORIG", "FIFFLD1.FIF_CODFIL"},{"LPAD(TRIM(E1_NSUTEF), "+__cTamNSU+", '0')","FIFFLD1.FIF_NSUTEF" },{"E1_XDTCAIX", "FIFFLD1.FIF_DTTEF"},{"E1_VALOR", "FIFFLD1.FIF_VLBRUT"}}, /*SE1->(IndexKey(1))*/ "E1_FILORIG+E1_NSUTEF+DTOS(E1_XDTCAIX)+STR(E1_VALOR)" )// //}, SE1->(IndexKey(1))) 
			oModel:SetRelation("SE1FLD1", {{"E1_FILORIG", "FIFFLD1.FIF_CODFIL"},{"E1_NSUTEF","FIFFLD1.FIF_NSUTEF" },{"E1_XDTCAIX", "FIFFLD1.FIF_DTTEF"},{"E1_VALOR", "FIFFLD1.FIF_VLBRUT"}}, /*SE1->(IndexKey(1))*/ "E1_FILORIG+E1_NSUTEF+DTOS(E1_XDTCAIX)+STR(E1_VALOR)" )// //}, SE1->(IndexKey(1))) 
		Else
			//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_EMISSAO
			//oModel:SetRelation("SE1FLD1", {{"E1_FILORIG", "FIFFLD1.FIF_CODFIL"},{"REPLICATE('0', "+__cTamNSU+" - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF)" , "FIFFLD1.FIF_NSUTEF"},{"E1_PARCELA", "FIFFLD1.FIF_PARALF"},{"E1_EMISSAO", "FIFFLD1.FIF_DTTEF"},{"E1_CARTAUT","FIFFLD1.FIF_CODAUT"}}, SE1->(IndexKey(1)))//},, SE1->(IndexKey(1)))//}, SE1->(IndexKey(1)))	
			//#TB20200205 Thiago Berna - Ajuste para desconsiderar o codigo de autorizacao e parcela
			//oModel:SetRelation("SE1FLD1", {{"E1_FILORIG", "FIFFLD1.FIF_CODFIL"},{"REPLICATE('0', "+__cTamNSU+" - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF)" , "FIFFLD1.FIF_NSUTEF"},{"E1_PARCELA", "FIFFLD1.FIF_PARALF"},{"E1_XDTCAIX", "FIFFLD1.FIF_DTTEF"},{"E1_CARTAUT","FIFFLD1.FIF_CODAUT"}}, SE1->(IndexKey(1)))//},, SE1->(IndexKey(1)))//}, SE1->(IndexKey(1)))	
			//#TB20200212 Thiago Berna - Ajuste para melhoria de desempenho
			//oModel:SetRelation("SE1FLD1", {{"E1_FILORIG", "FIFFLD1.FIF_CODFIL"},{"REPLICATE('0', "+__cTamNSU+" - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF)" , "FIFFLD1.FIF_NSUTEF"},{"E1_XDTCAIX", "FIFFLD1.FIF_DTTEF"},{"E1_VALOR", "FIFFLD1.FIF_VLBRUT"}}, /*SE1->(IndexKey(1))*/ "E1_FILORIG+E1_NSUTEF+DTOS(E1_XDTCAIX)+STR(E1_VALOR)" )//},, SE1->(IndexKey(1)))//}, SE1->(IndexKey(1)))	
			oModel:SetRelation("SE1FLD1", {{"E1_FILORIG", "FIFFLD1.FIF_CODFIL"},{"E1_NSUTEF" , "FIFFLD1.FIF_NSUTEF"},{"E1_XDTCAIX", "FIFFLD1.FIF_DTTEF"},{"E1_VALOR", "FIFFLD1.FIF_VLBRUT"}}, /*SE1->(IndexKey(1))*/ "E1_FILORIG+E1_NSUTEF+DTOS(E1_XDTCAIX)+STR(E1_VALOR)" )//},, SE1->(IndexKey(1)))//}, SE1->(IndexKey(1)))	
		Endif
		
		oModel:GetModel("SE1FLD1"):SetDescription("Conciliados")		//"Conciliados"
		
		oModel:GetModel("SE1FLD1"):SetNoDeleteLine(.T.)
		oModel:GetModel("SE1FLD1"):SetNoInsertLine(.T.)
		oModel:GetModel("SE1FLD1"):SetNoUpdateLine(.T.)
		oModel:GetModel("SE1FLD1"):SetOptional(.T.)
		oModel:GetModel("SE1FLD1"):SetOnlyQuery(.T.)

		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("SE1FLD1"):SetMaxLine(GRIDMAXLIN)
		
		//Insere campo VlrTEF na grid
		AddField(1, oStrSE101,, 1)

	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 2
		bVldOk 		:= {|oModGrid| OIF910Lck(oModGrid)}
		oStrFIF02		:= FWFormStruct(1, "FIF", __bVldFIF)
		oStrSE102		:= FWFormStruct(1, "SE1", __bVldSE1)	
		/*
		-------------------------------------------------------------------
			Folder 2 - Conciliados Parcialmente
		-------------------------------------------------------------------
		*/
		//FIF - Registros de Vendas
		oModel:AddGrid("FIFFLD2", "TMPHEADER", oStrFIF02)
		oModel:SetRelation("FIFFLD2", {{"'1'", "TMPHEADER.STATUS"}}, /*FIF->(IndexKey(1))*/"FIF_CODFIL+FIF_NSUTEF+DTOS(FIF_DTTEF)+STR(FIF_VLBRUT)")
		oModel:GetModel("FIFFLD2"):SetDescription("Conciliados Parcialmente")		//"Conciliados Parcialmente"
		oModel:GetModel("FIFFLD2"):SetLoadFilter(NIL, GetFilter(2, "FIF"))
		oModel:GetModel("FIFFLD2"):SetNoDeleteLine(.T.)
		oModel:GetModel("FIFFLD2"):SetNoInsertLine(.T.)
		oModel:GetModel("FIFFLD2"):SetOptional(.T.)
		oModel:GetModel("FIFFLD2"):SetOnlyQuery(.T.)

		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("FIFFLD2"):SetMaxLine(GRIDMAXLIN)
			
		//Insere campo de Selecao do Registro nas Grids
		AddField(1, oStrFIF02, bVldOk,2)
	
		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 1, oStrFIF02)
		
		oStrFIF02:SetProperty("FIF_PGJUST", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF02:SetProperty("FIF_PGDES1", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF02:SetProperty("FIF_PGDES2", MODEL_FIELD_WHEN, {|| .T. })
		
		
		oStrFIF02:SetProperty("FIF_PGJUST", MODEL_FIELD_VALID,bValid)
		oStrFIF02:AddTrigger("FIF_PGJUST", "FIF_PGDES1", { || .T.},  { |oModel| OIF910Jus(oModel)})	
		
		//SE1 - Titulos a Receber
		oModel:AddGrid("SE1FLD2", "FIFFLD2", oStrSE102)
		If __lOracle
			//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_EMISSAO
			//oModel:SetRelation("SE1FLD2", {{"E1_FILORIG", "FIFFLD2.FIF_CODFIL"},{"LPAD(TRIM(E1_NSUTEF), "+__cTamNSU+", '0')", "FIFFLD2.FIF_NSUTEF"},{"E1_PARCELA", "FIFFLD2.FIF_PARALF"},{"E1_EMISSAO", "FIFFLD2.FIF_DTTEF"}}, SE1->(IndexKey(1)))	
			//#TB20200205 Thiago Berna - Ajuste para desconsiderar parcela
			//oModel:SetRelation("SE1FLD2", {{"E1_FILORIG", "FIFFLD2.FIF_CODFIL"},{"LPAD(TRIM(E1_NSUTEF), "+__cTamNSU+", '0')", "FIFFLD2.FIF_NSUTEF"},{"E1_PARCELA", "FIFFLD2.FIF_PARALF"},{"E1_XDTCAIX", "FIFFLD2.FIF_DTTEF"}}, SE1->(IndexKey(1)))	
			//#TB20200212 Thiago Berna - Ajuste para melhoria de desempenho
			//oModel:SetRelation("SE1FLD2", {{"E1_FILORIG", "FIFFLD2.FIF_CODFIL"},{"LPAD(TRIM(E1_NSUTEF), "+__cTamNSU+", '0')", "FIFFLD2.FIF_NSUTEF"},{"E1_XDTCAIX", "FIFFLD2.FIF_DTTEF"}}, /*SE1->(IndexKey(1))*/ "E1_FILORIG+E1_NSUTEF+DTOS(E1_XDTCAIX)+STR(E1_VALOR)" )	
			oModel:SetRelation("SE1FLD2", {{"E1_FILORIG", "FIFFLD2.FIF_CODFIL"},{"E1_NSUTEF", "FIFFLD2.FIF_NSUTEF"},{"E1_XDTCAIX", "FIFFLD2.FIF_DTTEF"}}, /*SE1->(IndexKey(1))*/ "E1_FILORIG+E1_NSUTEF+DTOS(E1_XDTCAIX)+STR(E1_VALOR)" )	
		Else
			//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_EMISSAO
			//oModel:SetRelation("SE1FLD2", {{"E1_FILORIG", "FIFFLD2.FIF_CODFIL"},{"REPLICATE('0', "+__cTamNSU+" - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF)" , "FIFFLD2.FIF_NSUTEF"},{"E1_PARCELA", "FIFFLD2.FIF_PARALF"},{"E1_EMISSAO", "FIFFLD2.FIF_DTTEF"}}, SE1->(IndexKey(1))) 
			//#TB20200205 Thiago Berna - Ajuste para desconsiderar parcela
			//oModel:SetRelation("SE1FLD2", {{"E1_FILORIG", "FIFFLD2.FIF_CODFIL"},{"REPLICATE('0', "+__cTamNSU+" - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF)" , "FIFFLD2.FIF_NSUTEF"},{"E1_PARCELA", "FIFFLD2.FIF_PARALF"},{"E1_XDTCAIX", "FIFFLD2.FIF_DTTEF"}}, SE1->(IndexKey(1))) 
			//#TB20200212 Thiago Berna - Ajuste para melhoria de desempenho
			//oModel:SetRelation("SE1FLD2", {{"E1_FILORIG", "FIFFLD2.FIF_CODFIL"},{"REPLICATE('0', "+__cTamNSU+" - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF)" , "FIFFLD2.FIF_NSUTEF"},{"E1_XDTCAIX", "FIFFLD2.FIF_DTTEF"}}, /*SE1->(IndexKey(1))*/ "E1_FILORIG+E1_NSUTEF+DTOS(E1_XDTCAIX)+STR(E1_VALOR)" ) 
			oModel:SetRelation("SE1FLD2", {{"E1_FILORIG", "FIFFLD2.FIF_CODFIL"},{"E1_NSUTEF" , "FIFFLD2.FIF_NSUTEF"},{"E1_XDTCAIX", "FIFFLD2.FIF_DTTEF"}}, /*SE1->(IndexKey(1))*/ "E1_FILORIG+E1_NSUTEF+DTOS(E1_XDTCAIX)+STR(E1_VALOR)" ) 
		Endif		
		oModel:GetModel("SE1FLD2"):SetDescription("Conciliados Parcialmente") 		//"Conciliados Parcialmente"
		oModel:GetModel("SE1FLD2"):SetNoDeleteLine(.T.)
		oModel:GetModel("SE1FLD2"):SetNoInsertLine(.T.)
		oModel:GetModel("SE1FLD2"):SetNoUpdateLine(.T.)
		oModel:GetModel("SE1FLD2"):SetOptional(.T.)
		oModel:GetModel("SE1FLD2"):SetOnlyQuery(.T.)

		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("SE1FLD2"):SetMaxLine(GRIDMAXLIN)
				
		//Insere campo de Selecao do Registro nas Grids
		AddField(1, oStrSE102,, 2) 		

	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 3
	
		bVldOk 			:= {|oModGrid| OIF910Lck(oModGrid)}
		oStrFIF03		:= FWFormStruct(1, "FIF", __bVldFIF)
		oStrSE103		:= FWFormStruct(1, "SE1", __bVldSE1)	
		/*
		-------------------------------------------------------------------
			Folder 3 - Conciliados Manualmente
		-------------------------------------------------------------------
		*/
		//FIF - Registros de Vendas
		oModel:AddGrid("FIFFLD3", "TMPHEADER", oStrFIF03)
		oModel:SetRelation("FIFFLD3", {{"'1'", "TMPHEADER.STATUS"}}, /*FIF->(IndexKey(1))*/ "FIF_CODFIL+FIF_NUM+FIF_PARC+FIF_PREFIX")
		oModel:GetModel("FIFFLD3"):SetDescription("Conciliados Manual")		//"Conciliados Manualmente"
		oModel:GetModel("FIFFLD3"):SetLoadFilter(NIL, GetFilter(3, "FIF"))
		oModel:GetModel("FIFFLD3"):SetNoDeleteLine(.T.)
		oModel:GetModel("FIFFLD3"):SetNoInsertLine(.T.)
		oModel:GetModel("FIFFLD3"):SetOptional(.T.)
		oModel:GetModel("FIFFLD3"):SetOnlyQuery(.T.)

		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("FIFFLD3"):SetMaxLine(GRIDMAXLIN)
	
		//Insere campo de Selecao do Registro nas Grids
		AddField(1, oStrFIF03, bVldOk,1)
		
		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 1, oStrFIF03)
		
		oStrFIF03:SetProperty("FIF_PGJUST", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF03:SetProperty("FIF_PGDES1", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF03:SetProperty("FIF_PGDES2", MODEL_FIELD_WHEN, {|| .T. })
		
		oStrFIF03:SetProperty("FIF_PGJUST", MODEL_FIELD_VALID,bValid)
		oStrFIF03:AddTrigger("FIF_PGJUST", "FIF_PGDES1", { || .T.},  { |oModel| OIF910Jus(oModel)})

		//SE1 - Titulos a Receber
		oModel:AddGrid("SE1FLD3", "FIFFLD3", oStrSE103)
		
		If __lOracle
			oModel:SetRelation("SE1FLD3", {{"E1_FILORIG", "FIFFLD3.FIF_CODFIL"},{"E1_NUM", "FIFFLD3.FIF_NUM"},{"E1_PARCELA", "FIFFLD3.FIF_PARC"},{"E1_PREFIXO", "FIFFLD3.FIF_PREFIX"}}, /*SE1->(IndexKey(1)*/ "E1_FILORIG+E1_NUM+E1_PARCELA+E1_PREFIXO") 
		Else
			oModel:SetRelation("SE1FLD3", {{"E1_FILORIG", "FIFFLD3.FIF_CODFIL"},{"E1_NUM", "FIFFLD3.FIF_NUM"},{"E1_PARCELA", "FIFFLD3.FIF_PARC"},{"E1_PREFIXO", "FIFFLD3.FIF_PREFIX"}}, /*SE1->(IndexKey(1))*/ "E1_FILORIG+E1_NUM+E1_PARCELA+E1_PREFIXO")	
		Endif
		
		oModel:GetModel("SE1FLD3"):SetDescription("Conciliados Manualmente")		//"Conciliados Manualmente"
		
		oModel:GetModel("SE1FLD3"):SetNoDeleteLine(.T.)
		oModel:GetModel("SE1FLD3"):SetNoInsertLine(.T.)
		oModel:GetModel("SE1FLD3"):SetNoUpdateLine(.T.)
		oModel:GetModel("SE1FLD3"):SetOptional(.T.)
		oModel:GetModel("SE1FLD3"):SetOnlyQuery(.T.)

		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("SE1FLD3"):SetMaxLine(GRIDMAXLIN)
		
		//Insere campo VlrTEF na grid
		AddField(1, oStrSE103,, 1)
		
	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 4
		oStrFIF04	:= FWFormStruct(1, "FIF", __bVldFIF)
		oStrSE104	:= FWFormStruct(1, "SE1", __bVldSE1)	
		/*
		-------------------------------------------------------------------
			Folder 4 - Não Conciliados
		-------------------------------------------------------------------
		*/
		//FIF - Registros de Vendas
		oModel:AddGrid("FIFFLD4", "TMPHEADER", oStrFIF04)
		oModel:SetRelation("FIFFLD4", {{"'1'", "TMPHEADER.STATUS"}}, /*FIF->(IndexKey(1))*/ "FIF_CODFIL+FIF_NSUTEF+DTOS(FIF_DTTEF)+STR(FIF_VLBRUT)")
		oModel:GetModel("FIFFLD4"):SetDescription("N�o Conciliados")		//"Não Conciliados"
		oModel:GetModel("FIFFLD4"):SetLoadFilter(NIL, GetFilter(4, "FIF"))
		oModel:GetModel("FIFFLD4"):SetNoDeleteLine(.T.)
		oModel:GetModel("FIFFLD4"):SetNoInsertLine(.T.)
		oModel:GetModel("FIFFLD4"):SetOptional(.T.)
		oModel:GetModel("FIFFLD4"):SetOnlyQuery(.T.)
	
		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("FIFFLD4"):SetMaxLine(GRIDMAXLIN)
		
		//Insere campo de Selecao do Registro nas Grids
		bVldOk 	:= {|oModGrid, cCampo, lValue, lOldVal| fVldOk(oModGrid, cCampo, lValue, /*lOldVal*/,4) .And. OIF910Lck(oModGrid, 1) }
		AddField(1, oStrFIF04, bVldOk)
	
		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 1, oStrFIF04)

		oStrFIF04:SetProperty("FIF_PGJUST", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF04:SetProperty("FIF_PGDES1", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF04:SetProperty("FIF_PGDES2", MODEL_FIELD_WHEN, {|| .T. })
		
		oStrFIF04:SetProperty("FIF_PGJUST", MODEL_FIELD_VALID,bValid)
		oStrFIF04:AddTrigger("FIF_PGJUST", "FIF_PGDES1", { || .T.},  { |oModel| OIF910Jus(oModel)})
	
		//SE1 - Titulos a Receber
		oModel:AddGrid("SE1FLD4", "TMPHEADER", oStrSE104)
		
		oModel:SetRelation("SE1FLD4", {{"'1'", "TMPHEADER.STATUS"}}, /*SE1->(IndexKey(1))*/"E1_FILORIG+E1_NSUTEF+DTOS(E1_XDTCAIX)+STR(E1_VALOR)"  )
		oModel:GetModel("SE1FLD4"):SetDescription("N�o Conciliados")		//"Não Conciliados"
		oModel:GetModel("SE1FLD4"):SetLoadFilter(NIL, GetFilter(4, "SE1"))
		oModel:GetModel("SE1FLD4"):SetNoDeleteLine(.T.)
		oModel:GetModel("SE1FLD4"):SetNoInsertLine(.T.)
		oModel:GetModel("SE1FLD4"):SetOptional(.T.)
		oModel:GetModel("SE1FLD4"):SetOnlyQuery(.T.)

		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("SE1FLD4"):SetMaxLine(GRIDMAXLIN)
		
		//Insere campo de Selecao do Registro nas Grids
		bVldOk 	:= {|oModGrid, cCampo, lValue, lOldVal| fVldOk(oModGrid, cCampo, lValue, /*lOldVal*/,4) .And. OIF910Lck(oModGrid, 2)}
		AddField(1, oStrSE104, bVldOk, 4)
	
		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 1, oStrSE104)
		
	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 5
		bVldOk 	:= {|oModGrid| OIF910Lck(oModGrid)}
		oStrFIF05		:= FWFormStruct(1, "FIF", __bVldFIF)
		oStrSE105		:= FWFormStruct(1, "SE1", __bVldSE1)
		/*
		-------------------------------------------------------------------
			Folder 5 - Divergentes
		-------------------------------------------------------------------
		*/
		//FIF - Registros de Vendas
		oModel:AddGrid("FIFFLD5", "TMPHEADER", oStrFIF05)
		oModel:SetRelation("FIFFLD5", {{"'1'", "TMPHEADER.STATUS"}}, /*FIF->(IndexKey(1))*/ "FIF_CODFIL+FIF_NSUTEF+DTOS(FIF_DTTEF)+STR(FIF_VLBRUT)" )
		oModel:GetModel("FIFFLD5"):SetDescription("Divergentes")		//"Divergentes"
		oModel:GetModel("FIFFLD5"):SetLoadFilter(NIL, GetFilter(5, "FIF"))
		oModel:GetModel("FIFFLD5"):SetNoDeleteLine(.T.)
		oModel:GetModel("FIFFLD5"):SetNoInsertLine(.T.)
		oModel:GetModel("FIFFLD5"):SetOptional(.T.)
		oModel:GetModel("FIFFLD5"):SetOnlyQuery(.T.)

		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("FIFFLD5"):SetMaxLine(GRIDMAXLIN)
					
		//Insere campo de Selecao do Registro nas Grids
		AddField(1, oStrFIF05, bVldOk)
	
		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 1, oStrFIF05)
	
		oStrFIF05:SetProperty("FIF_PGJUST", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF05:SetProperty("FIF_PGDES1", MODEL_FIELD_WHEN, {|| .T. })
		oStrFIF05:SetProperty("FIF_PGDES2", MODEL_FIELD_WHEN, {|| .T. }) 
		
		oStrFIF05:SetProperty("FIF_PGJUST", MODEL_FIELD_VALID,bValid)
		oStrFIF05:AddTrigger("FIF_PGJUST", "FIF_PGDES1", { || .T.},  { |oModel| OIF910Jus(oModel)})	

		oModel:AddGrid("SE1FLD5", "FIFFLD5", oStrSE105)
		If __lOracle
			oModel:SetRelation("SE1FLD5", {{"E1_FILORIG", "FIFFLD5.FIF_CODFIL"},{"E1_NSUTEF","FIFFLD5.FIF_NSUTEF" },{"E1_XDTCAIX", "FIFFLD5.FIF_DTTEF"},{"E1_VALOR", "FIFFLD5.FIF_VLBRUT"}}, "E1_FILORIG+E1_NSUTEF+DTOS(E1_XDTCAIX)+STR(E1_VALOR)" ) 
		Else
			oModel:SetRelation("SE1FLD5", {{"E1_FILORIG", "FIFFLD5.FIF_CODFIL"},{"E1_NSUTEF" ,"FIFFLD5.FIF_NSUTEF"},{"E1_XDTCAIX", "FIFFLD5.FIF_DTTEF"},{"E1_VALOR", "FIFFLD5.FIF_VLBRUT"}}, "E1_FILORIG+E1_NSUTEF+DTOS(E1_XDTCAIX)+STR(E1_VALOR)" )	
		Endif
		
		oModel:GetModel("SE1FLD5"):SetDescription("Conciliados")		//"Conciliados"
		
		oModel:GetModel("SE1FLD5"):SetNoDeleteLine(.T.)
		oModel:GetModel("SE1FLD5"):SetNoInsertLine(.T.)
		oModel:GetModel("SE1FLD5"):SetNoUpdateLine(.T.)
		oModel:GetModel("SE1FLD5"):SetOptional(.T.)
		oModel:GetModel("SE1FLD5"):SetOnlyQuery(.T.)

		// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
		oModel:GetModel("SE1FLD5"):SetMaxLine(GRIDMAXLIN)
		
		//Insere campo VlrTEF na grid
		AddField(1, oStrSE105,, 1)
		
	EndIf

	/*
	-------------------------------------------------------------------
		Folder 6A - Pagamentos
	-------------------------------------------------------------------
	*/
	
	//bVldOk 			:= {|oModGrid| OIF910Lck(oModGrid)}
	oStrFIF6A		:= FWFormStruct(1, "FIF", __bVldFIF)
	oStrSE16A		:= FWFormStruct(1, "SE1", __bVldSE1)	
	
	//FIF - Registros de Vendas
	oModel:AddGrid("FIFFLD6A", "TMPHEADER", oStrFIF6A)
		
	oModel:SetRelation("FIFFLD6A", {{"'1'", "TMPHEADER.STATUS"}}, /*FIF->(IndexKey(1))*/ "FIF_CODFIL+FIF_NSUTEF+DTOS(FIF_DTTEF)+STR(FIF_VLBRUT)")
	oModel:GetModel("FIFFLD6A"):SetDescription("Conciliados")		//"Conciliados"
	oModel:GetModel("FIFFLD6A"):SetLoadFilter(NIL, GetFilter(8, "FIF"))
	oModel:GetModel("FIFFLD6A"):SetNoDeleteLine(.T.)
	oModel:GetModel("FIFFLD6A"):SetNoInsertLine(.T.)
	oModel:GetModel("FIFFLD6A"):SetOptional(.T.)
	oModel:GetModel("FIFFLD6A"):SetOnlyQuery(.T.)

	// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
	oModel:GetModel("FIFFLD6A"):SetMaxLine(GRIDMAXLIN)
	
	//Insere campo de Selecao do Registro nas Grids
	bVldOk 	:= {|oModGrid, cCampo, lValue, lOldVal| fVldOk(oModGrid, cCampo, lValue, /*lOldVal*/, 8) .And. OIF910Lck(oModGrid, 1, 8)}
	AddField(1, oStrFIF6A, bVldOk,8)
		
	//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
	SetProp(oModel, 1, oStrFIF6A)

	//Insere campo Customizado
	//AddField(1, oStrFIF6A,, 8)
	

	oModel:AddGrid("SE1FLD6A", "FIFFLD6A", oStrSE16A)
	If __lOracle
		oModel:SetRelation("SE1FLD6A", {{"E1_FILORIG", "FIFFLD6A.FIF_CODFIL"},{"E1_NSUTEF","FIFFLD6A.FIF_NSUTEF" },{"E1_XDTCAIX", "FIFFLD6A.FIF_DTTEF"},{"E1_VALOR", "FIFFLD6A.FIF_VLBRUT"}}, "E1_FILORIG+E1_NSUTEF+DTOS(E1_XDTCAIX)+STR(E1_VALOR)" )
		oModel:SetRelation("SE1FLD3" , {{"E1_FILORIG", "FIFFLD3.FIF_CODFIL"},{"E1_NUM", "FIFFLD3.FIF_NUM"},{"E1_PARCELA", "FIFFLD3.FIF_PARC"},{"E1_PREFIXO", "FIFFLD3.FIF_PREFIX"}}, /*SE1->(IndexKey(1)*/ "E1_FILORIG+E1_NUM+E1_PARCELA+E1_PREFIXO") 
	Else
		oModel:SetRelation("SE1FLD6A", {{"E1_FILORIG", "FIFFLD6A.FIF_CODFIL"},{"E1_NSUTEF" , "FIFFLD6A.FIF_NSUTEF"},{"E1_XDTCAIX", "FIFFLD6A.FIF_DTTEF"},{"E1_VALOR", "FIFFLD6A.FIF_VLBRUT"}}, "E1_FILORIG+E1_NSUTEF+DTOS(E1_XDTCAIX)+STR(E1_VALOR)" )
	Endif
		
	oModel:GetModel("SE1FLD6A"):SetDescription("Conciliados")		//"Conciliados"
		
	oModel:GetModel("SE1FLD6A"):SetNoDeleteLine(.T.)
	oModel:GetModel("SE1FLD6A"):SetNoInsertLine(.T.)
	oModel:GetModel("SE1FLD6A"):SetNoUpdateLine(.T.)
	oModel:GetModel("SE1FLD6A"):SetOptional(.T.)
	oModel:GetModel("SE1FLD6A"):SetOnlyQuery(.T.)

	// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
	oModel:GetModel("SE1FLD6A"):SetMaxLine(GRIDMAXLIN)
		
	//Insere campo Customizado
	AddField(1, oStrSE16A,,8)
	
	/*
	-------------------------------------------------------------------
		Folder 6 - Totais
	-------------------------------------------------------------------
	*/
	bLoadTot := {|oSubMod| fLoadTot(oSubMod)}

	oModel:AddGrid("TOTFLD6", "TMPHEADER", oStrTot06, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, bLoadTot)
	oModel:SetRelation("TOTFLD6", {{"'1'", "TMPHEADER.STATUS"}}, "DTOS(DTAVEND)")
	oModel:GetModel("TOTFLD6"):SetDescription("Totais")		//"Totais"
	oModel:GetModel("TOTFLD6"):SetOptional(.T.)
	oModel:GetModel("TOTFLD6"):SetNoDeleteLine(.T.)
	oModel:GetModel("TOTFLD6"):SetNoInsertLine(.T.)
	oModel:GetModel("TOTFLD6"):SetNoUpdateLine(.T.)
	oModel:GetModel("TOTFLD6"):SetOnlyQuery(.T.)
	oModel:GetModel("TOTFLD6"):SetUniqueLine({"DTAVEND"})

	// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
	oModel:GetModel("TOTFLD6"):SetMaxLine(GRIDMAXLIN)

	//#TB20200121 Thiago Berna - Nova Aba de fechamento
	/*
	-------------------------------------------------------------------
		Folder 7 - Fechamento
	-------------------------------------------------------------------
	*/
	bLoadFec := {|oSubMod| fLoadFec(oSubMod,1)}

	oModel:AddGrid("TOTFLD7", "TMPHEADER", oStrTot07, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, bLoadFec)
	//oModel:SetRelation("TOTFLD7", {{"'1'", "TMPHEADER.STATUS"}}, "DTOS(DTAVEND)")
	oModel:GetModel("TOTFLD7"):SetDescription("Fechamento")	
	oModel:GetModel("TOTFLD7"):SetOptional(.T.)
	oModel:GetModel("TOTFLD7"):SetNoDeleteLine(.T.)
	oModel:GetModel("TOTFLD7"):SetNoInsertLine(.T.)
	oModel:GetModel("TOTFLD7"):SetNoUpdateLine(.T.)
	oModel:GetModel("TOTFLD7"):SetOnlyQuery(.T.)
	//oModel:GetModel("TOTFLD7"):SetUniqueLine({"DTAVEND"})

	// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
	oModel:GetModel("TOTFLD7"):SetMaxLine(GRIDMAXLIN)
	
	/*If MV_PAR13 == 1
		If __nFldPar == 1
			oModel:SetActivate( { |oModel| __nFIFFLD1 := OI910Cont( oModel,"FIFFLD1" ) } )
		ElseIf __nFldPar == 2
			oModel:SetActivate( { |oModel| __nFIFFLD2 := OI910Cont( oModel,"FIFFLD2" ) } )	
		ElseIf __nFldPar == 3
			oModel:SetActivate( { |oModel| __nFIFFLD3 := OI910Cont( oModel,"FIFFLD3" ) } )	
		ElseIf __nFldPar == 4
			oModel:SetActivate( { |oModel| __nFIFFLD4 := OI910Cont( oModel,"FIFFLD4" ) , __nSE1FLD4 := OI910Cont( oModel,"SE1FLD4" ) } )
		ElseIf __nFldPar == 5
			oModel:SetActivate( { |oModel| __nFIFFLD5 := OI910Cont( oModel,"FIFFLD5" ) } )	
		EndIf
	Else*/
		oModel:SetActivate( { |oModel| 	__nFIFFLD1 := OI910Cont( oModel,"FIFFLD1" ),;
										__nFIFFLD2 := OI910Cont( oModel,"FIFFLD2" ),;
										__nFIFFLD3 := OI910Cont( oModel,"FIFFLD3" ),;
										__nFIFFLD4 := OI910Cont( oModel,"FIFFLD4" ),;
										__nSE1FLD4 := OI910Cont( oModel,"SE1FLD4" ),;
										__nFIFFLD5 := OI910Cont( oModel,"FIFFLD5" ) } )
	//EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao da View

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static Function ViewDef() As Object
	Local oModel	As Object
	Local oView		As Object
	Local oStHead	As Object
	Local oStrFIF01	As Object
	Local oStrFIF02	As Object
	Local oStrFIF03 As Object
	Local oStrFIF04	As Object
	Local oStrFIF05	As Object
	Local oStrSE101	As Object
	Local oStrSE102	As Object
	Local oStrSE103	As Object
	Local oStrSE104	As Object
	Local oStrTot05	As Object
	Local oStrTot06	As Object

	//#TB20200121 Thiago Berna - Nova Aba de fechamento
	Local oStrTot07	As Object
	Local bLoadFec	As Codeblock
	
	//#TB20200217 Thiago Berna - Nova Aba de PAGAMENTOS
	Local oStrFIF6A	As Object
	Local oStrSE16A	As Object

	Local cDescri	As Character

	oModel		:= FWLoadModel("FINA916")
	oView		:= FWFormView():New()
	oStHead		:= StrHead(2)
	oStrFIF01	:= FWFormStruct(2, "FIF", __bVldFIF)
	oStrFIF02	:= FWFormStruct(2, "FIF", __bVldFIF)
	oStrFIF03	:= FWFormStruct(2, "FIF", __bVldFIF)
	oStrFIF04	:= FWFormStruct(2, "FIF", __bVldFIF)
	oStrFIF05	:= FWFormStruct(2, "FIF", __bVldFIF)
	oStrSE101	:= FWFormStruct(2, "SE1", __bVldSE1)
	oStrSE102	:= FWFormStruct(2, "SE1", __bVldSE1)
	oStrSE103	:= FWFormStruct(2, "SE1", __bVldSE1)
	oStrSE104	:= FWFormStruct(2, "SE1", __bVldSE1)
	oStrSE105	:= FWFormStruct(2, "SE1", __bVldSE1)
	oStrTot06	:= StrTot(2)
	
	//#TB20200121 Thiago Berna - Nova Aba de fechamento
	oStrTot07	:= Fechamento(2)

	//#TB20200217 Thiago Berna - Nova Aba de pagamentos
	oStrFIF6A	:= FWFormStruct(2, "FIF", __bVldFIF)
	oStrSE16A	:= FWFormStruct(2, "SE1", __bVldSE1)
	
	cDescri		:= ""
	
	__lCheck01 := .F.
	__lCheck02 := .F.
	__lCheck03 := .F.
	__lCheck08 := .F.

	oView:SetModel(oModel)

	//Box para as Grids
	oView:CreateHorizontalBox("HBINF01", 100)

	//Folder com as Planinhas
	oView:CreateFolder("FOLGRIDS", "HBINF01")

	oView:AddUserButton("Imprimir","MAGIC_BMP",{|| Processa(	{|| OIF910Print(oView)},"Aguarde...","Preparando a Impress�o...") },"Imprimir Browse")
	
	//oView:AddUserButton("Efetivar","MAGIC_BMP",{|| Processa(	{|| U_OIF910Gv(nSheet),oView:Refresh('FIFFLD1'),oView:Refresh('SE1FLD1'),oView:Refresh('FIFFLD5'),oView:Refresh('SE1FLD5'),U_F910LckA()},"Aguarde...",/*"Preparando Dados para Baixa..."*/"Conciliando...") },"Efetivar")
	//oView:SetViewAction( 'BUTTONOK' , { |oView| Processa(	{|| U_OIF910Gv(nSheet),oView:Refresh('FIFFLD1'),oView:Refresh('SE1FLD1'),oView:Refresh('FIFFLD5'),oView:Refresh('SE1FLD5'),U_F910LckA()},"Aguarde...",/*"Preparando Dados para Baixa..."*/"Conciliando...") } )
	If __nFldPar == 0 .OR. __nFldPar == 1
		/*
		-------------------------------------------------------------------
			Sheet 01 - Conciliados
		-------------------------------------------------------------------
		*/
		oView:AddSheet("FOLGRIDS", "SHT01", "Conciliados",{|| /*OIF910VTef(oView, 1)*/})		//"Conciliados"
		oView:CreateHorizontalBox("HB01SHT01", 52, NIL, NIL, "FOLGRIDS", "SHT01")
		oView:CreateHorizontalBox("HB02SHT01",  6, NIL, NIL, "FOLGRIDS", "SHT01")
		oView:CreateHorizontalBox("HB03SHT01", 26, NIL, NIL, "FOLGRIDS", "SHT01")
		oView:CreateHorizontalBox("HB04SHT01", 16, NIL, NIL, "FOLGRIDS", "SHT01")

	
		//Grid Superior - Conciliados - FIF
		oView:AddGrid("GRD01FIF01", oStrFIF01, "FIFFLD1")
		oView:SetOwnerView("GRD01FIF01", "HB01SHT01")
		oView:SetViewProperty("GRD01FIF01", "GRIDSEEK", {.T.})
	
		//Insere campo de Selecao do Registro na Grid
		AddField(2, oStrFIF01)
	
		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 2, oStrFIF01)

		oView:SetViewProperty("GRD01FIF01", "CHANGELINE", {{|| /*OIF910VTef(oView, 1)*/}})
	
		oStrFIF01:RemoveField("FIF_PGJUST")
		oStrFIF01:RemoveField("FIF_PGDES1")
		oStrFIF01:RemoveField("FIF_PGDES2")
		oStrFIF01:RemoveField("FIF_CODMAJ")
		oStrFIF01:RemoveField("FIF_NSUTEF")
		oStrFIF01:RemoveField("FIF_STATUS")
		oStrFIF01:RemoveField("FIF_PREFIX")
		oStrFIF01:RemoveField("FIF_NSUARQ")

		//#TB20200206 Thiago Berna - Ajuste para omitir o campo FIF_CODRED
		oStrFIF01:RemoveField("FIF_CODRED")
		
		//Trava os Campos
//		oStrFIF01:SetProperty("FIF_CODJUS", 	MVC_VIEW_CANCHANGE, .F.)
//		oStrFIF01:SetProperty("FIF_DESJUS", 	MVC_VIEW_CANCHANGE, .F.)

		oStrFIF01:SetProperty('OK'  	   , MVC_VIEW_ORDEM ,'01')
		oStrFIF01:SetProperty('FIF_DTTEF'  , MVC_VIEW_ORDEM ,'02')
		oStrFIF01:SetProperty('FIF_CODFIL' , MVC_VIEW_ORDEM ,'03')
		oStrFIF01:SetProperty('FIF_VLBRUT' , MVC_VIEW_ORDEM ,'04')
		oStrFIF01:SetProperty('FIF_VLLIQ'  , MVC_VIEW_ORDEM ,'05')
		oStrFIF01:SetProperty('FIF_XNSUAR' , MVC_VIEW_ORDEM ,'06')
		oStrFIF01:SetProperty('FIF_CODAUT' , MVC_VIEW_ORDEM ,'07')
		oStrFIF01:SetProperty('FIF_CODLOJ' , MVC_VIEW_ORDEM ,'08')
		oStrFIF01:SetProperty('FIF_CODEST' , MVC_VIEW_ORDEM ,'09')
		oStrFIF01:SetProperty('FIF_DTCRED' , MVC_VIEW_ORDEM ,'10')	
		oStrFIF01:SetProperty('FIF_TPREG'  , MVC_VIEW_ORDEM ,'11')
		oStrFIF01:SetProperty('FIF_NURESU' , MVC_VIEW_ORDEM ,'12')	
		oStrFIF01:SetProperty('FIF_NUCOMP' , MVC_VIEW_ORDEM ,'13')	
		oStrFIF01:SetProperty('FIF_TPPROD' , MVC_VIEW_ORDEM ,'14')	
		oStrFIF01:SetProperty('FIF_CODBCO' , MVC_VIEW_ORDEM ,'15')	
		oStrFIF01:SetProperty('FIF_CODAGE' , MVC_VIEW_ORDEM ,'16')	
		oStrFIF01:SetProperty('FIF_NUMCC'  , MVC_VIEW_ORDEM ,'17')	
		oStrFIF01:SetProperty('FIF_VLCOM'  , MVC_VIEW_ORDEM ,'18')	
		oStrFIF01:SetProperty('FIF_TXSERV' , MVC_VIEW_ORDEM ,'19')	
		oStrFIF01:SetProperty('FIF_NUM'    , MVC_VIEW_ORDEM ,'20')	
		oStrFIF01:SetProperty('FIF_PARCEL' , MVC_VIEW_ORDEM ,'21')
		oStrFIF01:SetProperty('FIF_PARALF' , MVC_VIEW_ORDEM ,'22')
		oStrFIF01:SetProperty('FIF_PARC'   , MVC_VIEW_ORDEM ,'23')	
		oStrFIF01:SetProperty('FIF_XSTATU' , MVC_VIEW_ORDEM ,'24')
		oStrFIF01:SetProperty('FIF_CODBAN' , MVC_VIEW_ORDEM ,'25')
		oStrFIF01:SetProperty('FIF_CODADM' , MVC_VIEW_ORDEM ,'26')
		oStrFIF01:SetProperty('FIF_SEQFIF' , MVC_VIEW_ORDEM ,'27')
		
		//Check Marcar Todos
		oView:AddOtherObject("chkEf01", {|oPanel| U_OIF910Mc(oPanel, 1)})
		oView:SetOwnerView("chkEf01", "HB02SHT01")

		//Grid Inferior - Conciliados Parcialmente - SE1
		oView:AddGrid("GRD01SE101", oStrSE101, "SE1FLD1")
		oView:SetOwnerView("GRD01SE101", "HB03SHT01")
//		oView:SetViewProperty("GRD01SE101", "ENABLEDGRIDDETAIL", {100})
		oView:SetViewProperty("GRD01SE101", "GRIDCANGOTFOCUS", {.F.})
	
		oStrSE101:SetNoFolder()
	
		//Insere campo VlrTEF na grid
		AddField(2, oStrSE101, ,1)
		
		//Retiro este campo de flag das abas inferiores correspondente a SE1 pois os registros são conciliados.
		oStrSE101:RemoveField('OK')
		
		oStrSE101:RemoveField("E1_NSUTEF")
		oStrSE101:RemoveField("E1_DOCTEF")
		oStrSE101:RemoveField("E1_XDOCTEF")
		//oStrSE101:RemoveField("FIF_XSTATU")

		//#TB20200206 Thiago Berna - Ajuste para remover o campo
		oStrSE101:RemoveField("E1_XVLRTEF")

		oStrSE101:SetProperty('Conciliar'  	, MVC_VIEW_ORDEM ,'01')
		//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_EMISSAO
		//oStrSE101:SetProperty('E1_EMISSAO' 	, MVC_VIEW_ORDEM ,'02')
		oStrSE101:SetProperty('E1_XDTCAIX' 	, MVC_VIEW_ORDEM ,'02')
		oStrSE101:SetProperty('E1_XFILORI' 	, MVC_VIEW_ORDEM ,'03')
		oStrSE101:SetProperty('E1_XVLRREAL' , MVC_VIEW_ORDEM ,'04')
		oStrSE101:SetProperty('E1_VALOR'   	, MVC_VIEW_ORDEM ,'05')
		
		//#TB20200206 Thiago Berna - Ajuste para remover o campo
		//oStrSE101:SetProperty('E1_XVLRTEF' 	, MVC_VIEW_ORDEM ,'06')
		
		oStrSE101:SetProperty('E1_XSALDO'  	, MVC_VIEW_ORDEM ,'07')
		oStrSE101:SetProperty('E1_XNSUTEF' 	, MVC_VIEW_ORDEM ,'08')
		//oStrSE101:SetProperty('E1_DOCTEF' 	, MVC_VIEW_ORDEM ,'08')
		oStrSE101:SetProperty('E1_XCARTAUT' , MVC_VIEW_ORDEM ,'09')
		oStrSE101:SetProperty('E1_CLIENTE' 	, MVC_VIEW_ORDEM ,'10')
		oStrSE101:SetProperty('E1_LOJA'    	, MVC_VIEW_ORDEM ,'11')
		oStrSE101:SetProperty('E1_NOMCLI'  	, MVC_VIEW_ORDEM ,'12')
		oStrSE101:SetProperty('E1_VENCTO'  	, MVC_VIEW_ORDEM ,'13')
		oStrSE101:SetProperty('E1_VENCREA' 	, MVC_VIEW_ORDEM ,'14')
		oStrSE101:SetProperty('E1_PREFIXO' 	, MVC_VIEW_ORDEM ,'15')
		oStrSE101:SetProperty('E1_NUM'     	, MVC_VIEW_ORDEM ,'16')
		oStrSE101:SetProperty('E1_PARCELA' 	, MVC_VIEW_ORDEM ,'17')
		oStrSE101:SetProperty('E1_TIPO'    	, MVC_VIEW_ORDEM ,'18')
		oStrSE101:SetProperty('E1_NATUREZ' 	, MVC_VIEW_ORDEM ,'19')
		//oStrSE101:SetProperty('E1_XDOCTEF' 	, MVC_VIEW_ORDEM ,'20')
			
		//Botao Efetivar
		oView:AddOtherObject("btnEf01", {|oPanel| U_F910Botao(oPanel, 1,,__nFIFFLD1 = GRIDMAXLIN )})
		oView:SetOwnerView("btnEf01", "HB04SHT01")
		//Imprimir Browser
		//oView:AddOtherObject("btnEf06", {|oPanel| U_F910Botao(oPanel, 8 ,oView)})
	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 2
		/*
		-------------------------------------------------------------------
			Sheet 02 - Conciliados Parcialmente
		-------------------------------------------------------------------
		*/
		oView:AddSheet("FOLGRIDS", "SHT02", "Conciliados Parcialmente",{|| /*OIF910VTef(oView, 2)*/})		//"Conciliados Parcialmente"
		oView:CreateHorizontalBox("HB01SHT02", 52, NIL, NIL, "FOLGRIDS", "SHT02")
		oView:CreateHorizontalBox("HB04SHT02",  6, NIL, NIL, "FOLGRIDS", "SHT02")
		oView:CreateHorizontalBox("HB02SHT02", 26, NIL, NIL, "FOLGRIDS", "SHT02")
		oView:CreateHorizontalBox("HB03SHT02", 16, NIL, NIL, "FOLGRIDS", "SHT02")
	
	
		//Grid Superior - Conciliados Parcialmente - FIF
		oView:AddGrid("GRD01FIF02", oStrFIF02, "FIFFLD2")
		oView:SetOwnerView("GRD01FIF02", "HB01SHT02")
		oView:SetViewProperty("GRD01FIF02", "GRIDSEEK", {.T.})
	
		//Insere campo de Selecao do Registro na Grid
		AddField(2, oStrFIF02)
		
		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 2, oStrFIF02)
		
		oView:SetViewProperty("GRD01FIF02", "CHANGELINE", {{|| /*OIF910VTef(oView, 2)*/}})
	
		oStrFIF02:RemoveField("FIF_CODMAJ")
		oStrFIF02:RemoveField("FIF_NSUTEF")
		oStrFIF02:RemoveField("FIF_STATUS")
		oStrFIF02:RemoveField("FIF_PREFIX")
		oStrFIF02:RemoveField("FIF_NSUARQ")

		//#TB20200206 Thiago Berna - Ajuste para omitir o campo FIF_CODRED
		oStrFIF02:RemoveField("FIF_CODRED")
		
		oStrFIF02:SetProperty("FIF_PGJUST", 	MVC_VIEW_CANCHANGE, .T.)
		oStrFIF02:SetProperty("FIF_PGDES1", 	MVC_VIEW_CANCHANGE, .F.)
		oStrFIF02:SetProperty("FIF_PGDES2", 	MVC_VIEW_CANCHANGE, .T.)
		
		oStrFIF02:SetProperty('OK'  	   , MVC_VIEW_ORDEM ,'01')
		oStrFIF02:SetProperty('FIF_DTTEF'  , MVC_VIEW_ORDEM ,'02')
		oStrFIF02:SetProperty('FIF_CODFIL' , MVC_VIEW_ORDEM ,'03')
		oStrFIF02:SetProperty('FIF_VLBRUT' , MVC_VIEW_ORDEM ,'04')
		oStrFIF02:SetProperty('FIF_VLLIQ'  , MVC_VIEW_ORDEM ,'05')
		oStrFIF02:SetProperty('FIF_XNSUAR' , MVC_VIEW_ORDEM ,'06')
		oStrFIF02:SetProperty('FIF_CODAUT' , MVC_VIEW_ORDEM ,'07')
		oStrFIF02:SetProperty('FIF_CODLOJ' , MVC_VIEW_ORDEM ,'08')
		oStrFIF02:SetProperty('FIF_CODEST' , MVC_VIEW_ORDEM ,'09')
		oStrFIF02:SetProperty('FIF_DTCRED' , MVC_VIEW_ORDEM ,'10')	
		oStrFIF02:SetProperty('FIF_TPREG'  , MVC_VIEW_ORDEM ,'11')
		oStrFIF02:SetProperty('FIF_NURESU' , MVC_VIEW_ORDEM ,'12')	
		oStrFIF02:SetProperty('FIF_NUCOMP' , MVC_VIEW_ORDEM ,'13')	
		oStrFIF02:SetProperty('FIF_TPPROD' , MVC_VIEW_ORDEM ,'14')	
		oStrFIF02:SetProperty('FIF_CODBCO' , MVC_VIEW_ORDEM ,'15')	
		oStrFIF02:SetProperty('FIF_CODAGE' , MVC_VIEW_ORDEM ,'16')	
		oStrFIF02:SetProperty('FIF_NUMCC'  , MVC_VIEW_ORDEM ,'17')	
		oStrFIF02:SetProperty('FIF_VLCOM'  , MVC_VIEW_ORDEM ,'18')	
		oStrFIF02:SetProperty('FIF_TXSERV' , MVC_VIEW_ORDEM ,'19')	
		oStrFIF02:SetProperty('FIF_NUM'    , MVC_VIEW_ORDEM ,'20')	
		oStrFIF02:SetProperty('FIF_PARCEL' , MVC_VIEW_ORDEM ,'21')
		oStrFIF02:SetProperty('FIF_PARALF' , MVC_VIEW_ORDEM ,'22')
		oStrFIF02:SetProperty('FIF_PARC'   , MVC_VIEW_ORDEM ,'23')	
		oStrFIF02:SetProperty('FIF_XSTATU' , MVC_VIEW_ORDEM ,'24')
		oStrFIF02:SetProperty('FIF_CODBAN' , MVC_VIEW_ORDEM ,'25')
		oStrFIF02:SetProperty('FIF_CODADM' , MVC_VIEW_ORDEM ,'26')
		oStrFIF02:SetProperty('FIF_SEQFIF' , MVC_VIEW_ORDEM ,'27')
				
		//Check Marcar Todos
		oView:AddOtherObject("chkEf02", {|oPanel| U_OIF910Mc(oPanel, 2)})
		oView:SetOwnerView("chkEf02", "HB04SHT02")
		
		//Grid Inferior - Conciliados Parcialmente - SE1
		oView:AddGrid("GRD02SE102", oStrSE102, "SE1FLD2")
		oView:SetOwnerView("GRD02SE102", "HB02SHT02")
		
		//Insere campo de Selecao do Registro na Grid
		AddField(2, oStrSE102, ,2)
		
		//Retiro este campo de flag das abas inferiores correspondente a SE1 pois os registros são conciliados.
		oStrSE102:RemoveField('OK')
		
		oStrSE102:RemoveField("E1_NSUTEF")
		oStrSE102:RemoveField("E1_DOCTEF")
		oStrSE102:RemoveField("E1_XDOCTEF")
		//oStrSE102:RemoveField("FIF_XSTATU")

		//#TB20200206 Thiago Berna - Ajuste para remover o campo
		oStrSE102:RemoveField("E1_XVLRTEF")

		oStrSE102:SetProperty('Conciliar' 	, MVC_VIEW_ORDEM ,'01')
		//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_EMISSAO
		//oStrSE102:SetProperty('E1_EMISSAO' 	, MVC_VIEW_ORDEM ,'02')
		oStrSE102:SetProperty('E1_XDTCAIX' 	, MVC_VIEW_ORDEM ,'02')
		oStrSE102:SetProperty('E1_XFILORI' 	, MVC_VIEW_ORDEM ,'03')
		oStrSE102:SetProperty('E1_XVLRREAL' , MVC_VIEW_ORDEM ,'04')
		oStrSE102:SetProperty('E1_VALOR'   	, MVC_VIEW_ORDEM ,'05')
		
		//#TB20200206 Thiago Berna - Ajuste para remover o campo
		//oStrSE102:SetProperty('E1_XVLRTEF' 	, MVC_VIEW_ORDEM ,'06')
		
		oStrSE102:SetProperty('E1_XSALDO'  	, MVC_VIEW_ORDEM ,'07')			
		oStrSE102:SetProperty('E1_XNSUTEF' 	, MVC_VIEW_ORDEM ,'08')
		//oStrSE102:SetProperty('E1_DOCTEF'  	, MVC_VIEW_ORDEM ,'08')
		oStrSE102:SetProperty('E1_XCARTAUT' , MVC_VIEW_ORDEM ,'09')
		oStrSE102:SetProperty('E1_CLIENTE' 	, MVC_VIEW_ORDEM ,'10')
		oStrSE102:SetProperty('E1_LOJA'    	, MVC_VIEW_ORDEM ,'11')
		oStrSE102:SetProperty('E1_NOMCLI'  	, MVC_VIEW_ORDEM ,'12')
		oStrSE102:SetProperty('E1_VENCTO'  	, MVC_VIEW_ORDEM ,'13')
		oStrSE102:SetProperty('E1_VENCREA' 	, MVC_VIEW_ORDEM ,'14')
		oStrSE102:SetProperty('E1_PREFIXO' 	, MVC_VIEW_ORDEM ,'15')
		oStrSE102:SetProperty('E1_NUM'     	, MVC_VIEW_ORDEM ,'16')
		oStrSE102:SetProperty('E1_PARCELA' 	, MVC_VIEW_ORDEM ,'17')
		oStrSE102:SetProperty('E1_TIPO'    	, MVC_VIEW_ORDEM ,'18')
		oStrSE102:SetProperty('E1_NATUREZ' 	, MVC_VIEW_ORDEM ,'19')
		//oStrSE102:SetProperty('E1_XDOCTEF' 	, MVC_VIEW_ORDEM ,'20')
		
		//Botao Efetivar
		//#TB20200205 Thiago Berna - Nao permitir conciliacao parcial
		//oView:AddOtherObject("btnEf02", {|oPanel| U_F910Botao(oPanel, 2,,__nFIFFLD2 = GRIDMAXLIN )})
		//oView:SetOwnerView("btnEf02", "HB03SHT02")
		//Imprimir Browser
		//oView:AddOtherObject("btnEf06", {|oPanel| U_F910Botao(oPanel, 8 ,oView)})
				
	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 3
		/*
		-------------------------------------------------------------------
			Sheet 03 - Conciliados Manualmente
		-------------------------------------------------------------------
		*/
		oView:AddSheet("FOLGRIDS", "SHT03", "Conciliados Manualmente",{|| /*OIF910VTef(oView, 3)*/})		//"Conciliados Manualmente"
		oView:CreateHorizontalBox("HB01SHT03", 52, NIL, NIL, "FOLGRIDS", "SHT03")
		oView:CreateHorizontalBox("HB02SHT03",  6, NIL, NIL, "FOLGRIDS", "SHT03")
		oView:CreateHorizontalBox("HB03SHT03", 26, NIL, NIL, "FOLGRIDS", "SHT03")
		//oView:CreateHorizontalBox("HB04SHT03", 16, NIL, NIL, "FOLGRIDS", "SHT03")

	
		//Grid Superior - Conciliados - FIF
		oView:AddGrid("GRD01FIF03", oStrFIF03, "FIFFLD3")
		oView:SetOwnerView("GRD01FIF03", "HB01SHT03")
		oView:SetViewProperty("GRD01FIF03", "GRIDSEEK", {.T.})
	
		//Insere campo de Selecao do Registro na Grid
		AddField(2, oStrFIF03)
	
		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 2, oStrFIF03)

		oView:SetViewProperty("GRD01FIF03", "CHANGELINE", {{|| /*OIF910VTef(oView, 3)*/}})
	
		/*oStrFIF03:RemoveField("FIF_PGJUST")
		oStrFIF03:RemoveField("FIF_PGDES1")
		oStrFIF03:RemoveField("FIF_PGDES2")*/
		oStrFIF03:RemoveField("FIF_CODMAJ")
		oStrFIF03:RemoveField("FIF_NSUTEF")
		oStrFIF03:RemoveField("FIF_STATUS")
		oStrFIF03:RemoveField("FIF_PREFIX")
		oStrFIF03:RemoveField("FIF_NSUARQ")

		//#TB20200206 Thiago Berna - Ajuste para omitir o campo FIF_CODRED
		oStrFIF03:RemoveField("FIF_CODRED")
		
		oStrFIF03:SetProperty("FIF_PGJUST", 	MVC_VIEW_CANCHANGE, .F.)
		oStrFIF03:SetProperty("FIF_PGDES1", 	MVC_VIEW_CANCHANGE, .F.)
		oStrFIF03:SetProperty("FIF_PGDES2", 	MVC_VIEW_CANCHANGE, .F.)
		
		//Trava os Campos
//		oStrFIF01:SetProperty("FIF_CODJUS", 	MVC_VIEW_CANCHANGE, .F.)
//		oStrFIF01:SetProperty("FIF_DESJUS", 	MVC_VIEW_CANCHANGE, .F.)

		oStrFIF03:SetProperty('OK'  	   , MVC_VIEW_ORDEM ,'01')
		oStrFIF03:SetProperty('FIF_DTTEF'  , MVC_VIEW_ORDEM ,'02')
		oStrFIF03:SetProperty('FIF_CODFIL' , MVC_VIEW_ORDEM ,'03')
		oStrFIF03:SetProperty('FIF_VLBRUT' , MVC_VIEW_ORDEM ,'04')
		oStrFIF03:SetProperty('FIF_VLLIQ'  , MVC_VIEW_ORDEM ,'05')
		oStrFIF03:SetProperty('FIF_XNSUAR' , MVC_VIEW_ORDEM ,'06')
		oStrFIF03:SetProperty('FIF_CODAUT' , MVC_VIEW_ORDEM ,'07')
		oStrFIF03:SetProperty('FIF_CODLOJ' , MVC_VIEW_ORDEM ,'08')
		oStrFIF03:SetProperty('FIF_CODEST' , MVC_VIEW_ORDEM ,'09')
		oStrFIF03:SetProperty('FIF_DTCRED' , MVC_VIEW_ORDEM ,'10')	
		oStrFIF03:SetProperty('FIF_TPREG'  , MVC_VIEW_ORDEM ,'11')
		oStrFIF03:SetProperty('FIF_NURESU' , MVC_VIEW_ORDEM ,'12')	
		oStrFIF03:SetProperty('FIF_NUCOMP' , MVC_VIEW_ORDEM ,'13')	
		oStrFIF03:SetProperty('FIF_TPPROD' , MVC_VIEW_ORDEM ,'14')	
		oStrFIF03:SetProperty('FIF_CODBCO' , MVC_VIEW_ORDEM ,'15')	
		oStrFIF03:SetProperty('FIF_CODAGE' , MVC_VIEW_ORDEM ,'16')	
		oStrFIF03:SetProperty('FIF_NUMCC'  , MVC_VIEW_ORDEM ,'17')	
		oStrFIF03:SetProperty('FIF_VLCOM'  , MVC_VIEW_ORDEM ,'18')	
		oStrFIF03:SetProperty('FIF_TXSERV' , MVC_VIEW_ORDEM ,'19')	
		oStrFIF03:SetProperty('FIF_NUM'    , MVC_VIEW_ORDEM ,'20')	
		oStrFIF03:SetProperty('FIF_PARCEL' , MVC_VIEW_ORDEM ,'21')
		oStrFIF03:SetProperty('FIF_PARALF' , MVC_VIEW_ORDEM ,'22')
		oStrFIF03:SetProperty('FIF_PARC'   , MVC_VIEW_ORDEM ,'23')	
		oStrFIF03:SetProperty('FIF_XSTATU' , MVC_VIEW_ORDEM ,'24')
		oStrFIF03:SetProperty('FIF_CODBAN' , MVC_VIEW_ORDEM ,'25')
		oStrFIF03:SetProperty('FIF_CODADM' , MVC_VIEW_ORDEM ,'26')
		oStrFIF03:SetProperty('FIF_SEQFIF' , MVC_VIEW_ORDEM ,'27')
		
		//Check Marcar Todos
		//oView:AddOtherObject("chkEf03", {|oPanel| U_OIF910Mc(oPanel, 1)})
		//oView:SetOwnerView("chkEf03", "HB02SHT03")

		//Grid Inferior - Conciliados Parcialmente - SE1
		oView:AddGrid("GRD01SE103", oStrSE101, "SE1FLD3")
		oView:SetOwnerView("GRD01SE103", "HB03SHT03")
//		oView:SetViewProperty("GRD01SE101", "ENABLEDGRIDDETAIL", {100})
		oView:SetViewProperty("GRD01SE103", "GRIDCANGOTFOCUS", {.F.})
	
		oStrSE103:SetNoFolder()
	
		//Insere campo VlrTEF na grid
		AddField(2, oStrSE103, ,1)
		
		//Retiro este campo de flag das abas inferiores correspondente a SE1 pois os registros são conciliados.
		oStrSE103:RemoveField('OK')
		
		oStrSE103:RemoveField("E1_NSUTEF")
		oStrSE103:RemoveField("E1_DOCTEF")
		oStrSE103:RemoveField("E1_XDOCTEF")
		//oStrSE103:RemoveField("FIF_XSTATU")

		//#TB20200206 Thiago Berna - Ajuste para remover o campo
		oStrSE103:RemoveField("E1_XVLRTEF")

		oStrSE103:SetProperty('Conciliar'  	, MVC_VIEW_ORDEM ,'01')
		//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_EMISSAO
		//oStrSE103:SetProperty('E1_EMISSAO' 	, MVC_VIEW_ORDEM ,'02')
		oStrSE103:SetProperty('E1_XDTCAIX' 	, MVC_VIEW_ORDEM ,'02')
		oStrSE103:SetProperty('E1_XFILORI' 	, MVC_VIEW_ORDEM ,'03')
		oStrSE103:SetProperty('E1_XVLRREAL' , MVC_VIEW_ORDEM ,'04')
		oStrSE103:SetProperty('E1_VALOR'   	, MVC_VIEW_ORDEM ,'05')
		
		//#TB20200206 Thiago Berna - Ajuste para remover o campo
		//oStrSE103:SetProperty('E1_XVLRTEF' 	, MVC_VIEW_ORDEM ,'06')

		oStrSE103:SetProperty('E1_XSALDO'  	, MVC_VIEW_ORDEM ,'07')
		oStrSE103:SetProperty('E1_XNSUTEF'  	, MVC_VIEW_ORDEM ,'08')
		//oStrSE103:SetProperty('E1_DOCTEF'  	, MVC_VIEW_ORDEM ,'08')
		oStrSE103:SetProperty('E1_XCARTAUT' , MVC_VIEW_ORDEM ,'09')
		oStrSE103:SetProperty('E1_CLIENTE' 	, MVC_VIEW_ORDEM ,'10')
		oStrSE103:SetProperty('E1_LOJA'    	, MVC_VIEW_ORDEM ,'11')
		oStrSE103:SetProperty('E1_NOMCLI'  	, MVC_VIEW_ORDEM ,'12')
		oStrSE103:SetProperty('E1_VENCTO'  	, MVC_VIEW_ORDEM ,'13')
		oStrSE103:SetProperty('E1_VENCREA' 	, MVC_VIEW_ORDEM ,'14')
		oStrSE103:SetProperty('E1_PREFIXO' 	, MVC_VIEW_ORDEM ,'15')
		oStrSE103:SetProperty('E1_NUM'     	, MVC_VIEW_ORDEM ,'16')
		oStrSE103:SetProperty('E1_PARCELA' 	, MVC_VIEW_ORDEM ,'17')
		oStrSE103:SetProperty('E1_TIPO'    	, MVC_VIEW_ORDEM ,'18')
		oStrSE103:SetProperty('E1_NATUREZ' 	, MVC_VIEW_ORDEM ,'19')
		//oStrSE103:SetProperty('E1_XDOCTEF' 	, MVC_VIEW_ORDEM ,'20')
			
		//Botao Efetivar
		//oView:AddOtherObject("btnEf03", {|oPanel| U_F910Botao(oPanel, 1,,__nFIFFLD3 = GRIDMAXLIN )})
		//oView:SetOwnerView("btnEf03", "HB04SHT03")
		//Imprimir Browser
		//oView:AddOtherObject("btnEf06", {|oPanel| U_F910Botao(oPanel, 8 ,oView)})
			
	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 4
		/*
		-------------------------------------------------------------------
			Sheet 04 - Não Conciliadas
		-------------------------------------------------------------------
		*/
		oView:AddSheet("FOLGRIDS", "SHT04", "N�o Conciliados")		//"Vendas sem Titulos"
		oView:CreateHorizontalBox("HB01SHT04", 40, NIL, NIL, "FOLGRIDS", "SHT04")
		oView:CreateHorizontalBox("HB02SHT04", 40, NIL, NIL, "FOLGRIDS", "SHT04")
		oView:CreateHorizontalBox("HB03SHT04", 18, NIL, NIL, "FOLGRIDS", "SHT04")
	
		//Grid - Vendas sem Titulos - FIF
		oView:AddGrid("GRD01FIF04", oStrFIF04, "FIFFLD4")
		oView:SetOwnerView("GRD01FIF04", "HB01SHT04")
		oView:SetViewProperty("GRD01FIF04", "GRIDSEEK", {.T.})
		oView:SetViewProperty("GRD01FIF04", "GRIDFILTER", {.T.}) 

	
		//Insere campo de Selecao do Registro na Grid
		AddField(2, oStrFIF04)
	
		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 2, oStrFIF04)
		
		oStrFIF04:RemoveField("FIF_NSUTEF")
		oStrFIF04:RemoveField("FIF_STATUS")
		oStrFIF04:RemoveField("FIF_PREFIX")
		oStrFIF04:RemoveField("FIF_NSUARQ")

		//#TB20200206 Thiago Berna - Ajuste para omitir o campo FIF_CODRED
		oStrFIF04:RemoveField("FIF_CODRED")
		
		oStrFIF04:SetProperty("FIF_PGJUST", 	MVC_VIEW_CANCHANGE, .T.)
		oStrFIF04:SetProperty("FIF_PGDES2", 	MVC_VIEW_CANCHANGE, .T.)
	
		//#TB20200415 Thiago Berna - Ajuste para reposicionar os campos na tela
		/*oStrFIF04:SetProperty('OK'  	   , MVC_VIEW_ORDEM ,'01')
		oStrFIF04:SetProperty('FIF_DTTEF'  , MVC_VIEW_ORDEM ,'02')
		oStrFIF04:SetProperty('FIF_CODFIL' , MVC_VIEW_ORDEM ,'03')
		oStrFIF04:SetProperty('FIF_VLBRUT' , MVC_VIEW_ORDEM ,'04')
		oStrFIF04:SetProperty('FIF_VLLIQ'  , MVC_VIEW_ORDEM ,'05')
		oStrFIF04:SetProperty('FIF_XNSUAR' , MVC_VIEW_ORDEM ,'06')
		oStrFIF04:SetProperty('FIF_CODAUT' , MVC_VIEW_ORDEM ,'07')
		oStrFIF04:SetProperty('FIF_CODLOJ' , MVC_VIEW_ORDEM ,'08')
		oStrFIF04:SetProperty('FIF_CODEST' , MVC_VIEW_ORDEM ,'09')
		oStrFIF04:SetProperty('FIF_DTCRED' , MVC_VIEW_ORDEM ,'10')	
		oStrFIF04:SetProperty('FIF_TPREG'  , MVC_VIEW_ORDEM ,'11')
		oStrFIF04:SetProperty('FIF_NURESU' , MVC_VIEW_ORDEM ,'12')	
		oStrFIF04:SetProperty('FIF_NUCOMP' , MVC_VIEW_ORDEM ,'13')	
		oStrFIF04:SetProperty('FIF_TPPROD' , MVC_VIEW_ORDEM ,'14')	
		oStrFIF04:SetProperty('FIF_CODBCO' , MVC_VIEW_ORDEM ,'15')	
		oStrFIF04:SetProperty('FIF_CODAGE' , MVC_VIEW_ORDEM ,'16')	
		oStrFIF04:SetProperty('FIF_NUMCC'  , MVC_VIEW_ORDEM ,'17')	
		oStrFIF04:SetProperty('FIF_VLCOM'  , MVC_VIEW_ORDEM ,'18')	
		oStrFIF04:SetProperty('FIF_TXSERV' , MVC_VIEW_ORDEM ,'19')	
		oStrFIF04:SetProperty('FIF_NUM'    , MVC_VIEW_ORDEM ,'20')	
		oStrFIF04:SetProperty('FIF_PARCEL' , MVC_VIEW_ORDEM ,'21')
		oStrFIF04:SetProperty('FIF_PARALF' , MVC_VIEW_ORDEM ,'22')
		oStrFIF04:SetProperty('FIF_PARC'   , MVC_VIEW_ORDEM ,'23')	
		oStrFIF04:SetProperty('FIF_XSTATU' , MVC_VIEW_ORDEM ,'24')
		oStrFIF04:SetProperty('FIF_CODBAN' , MVC_VIEW_ORDEM ,'25')
		oStrFIF04:SetProperty('FIF_CODADM' , MVC_VIEW_ORDEM ,'26')
		oStrFIF04:SetProperty('FIF_SEQFIF' , MVC_VIEW_ORDEM ,'27')*/	
		
		oStrFIF04:SetProperty('OK'  	   , MVC_VIEW_ORDEM ,'01')
		oStrFIF04:SetProperty('FIF_DTTEF'  , MVC_VIEW_ORDEM ,'02')
		oStrFIF04:SetProperty('FIF_HRTEF'  , MVC_VIEW_ORDEM ,'03')
		oStrFIF04:SetProperty('FIF_CODFIL' , MVC_VIEW_ORDEM ,'04')
		oStrFIF04:SetProperty('FIF_VLBRUT' , MVC_VIEW_ORDEM ,'05')
		oStrFIF04:SetProperty('FIF_TPPROD' , MVC_VIEW_ORDEM ,'06')
		oStrFIF04:SetProperty('FIF_XCODRE' , MVC_VIEW_ORDEM ,'07')
		oStrFIF04:SetProperty('FIF_PGJUST' , MVC_VIEW_ORDEM ,'08')
		oStrFIF04:SetProperty('FIF_PGDES1' , MVC_VIEW_ORDEM ,'09')
		oStrFIF04:SetProperty('FIF_XNSUAR' , MVC_VIEW_ORDEM ,'10')
		oStrFIF04:SetProperty('FIF_VLLIQ'  , MVC_VIEW_ORDEM ,'11')
		oStrFIF04:SetProperty('FIF_CODAUT' , MVC_VIEW_ORDEM ,'12')
		oStrFIF04:SetProperty('FIF_CODLOJ' , MVC_VIEW_ORDEM ,'13')
		oStrFIF04:SetProperty('FIF_CODEST' , MVC_VIEW_ORDEM ,'14')
		oStrFIF04:SetProperty('FIF_DTCRED' , MVC_VIEW_ORDEM ,'15')	
		oStrFIF04:SetProperty('FIF_TPREG'  , MVC_VIEW_ORDEM ,'16')
		oStrFIF04:SetProperty('FIF_NURESU' , MVC_VIEW_ORDEM ,'17')	
		oStrFIF04:SetProperty('FIF_NUCOMP' , MVC_VIEW_ORDEM ,'18')		
		oStrFIF04:SetProperty('FIF_CODBCO' , MVC_VIEW_ORDEM ,'19')	
		oStrFIF04:SetProperty('FIF_CODAGE' , MVC_VIEW_ORDEM ,'20')	
		oStrFIF04:SetProperty('FIF_NUMCC'  , MVC_VIEW_ORDEM ,'21')	
		oStrFIF04:SetProperty('FIF_VLCOM'  , MVC_VIEW_ORDEM ,'22')	
		oStrFIF04:SetProperty('FIF_TXSERV' , MVC_VIEW_ORDEM ,'23')	
		oStrFIF04:SetProperty('FIF_NUM'    , MVC_VIEW_ORDEM ,'24')	
		oStrFIF04:SetProperty('FIF_PARCEL' , MVC_VIEW_ORDEM ,'25')
		oStrFIF04:SetProperty('FIF_PARALF' , MVC_VIEW_ORDEM ,'26')
		oStrFIF04:SetProperty('FIF_PARC'   , MVC_VIEW_ORDEM ,'27')	
		oStrFIF04:SetProperty('FIF_XSTATU' , MVC_VIEW_ORDEM ,'28')
		oStrFIF04:SetProperty('FIF_CODBAN' , MVC_VIEW_ORDEM ,'29')
		oStrFIF04:SetProperty('FIF_CODADM' , MVC_VIEW_ORDEM ,'30')
		oStrFIF04:SetProperty('FIF_SEQFIF' , MVC_VIEW_ORDEM ,'31')		

		oStrFIF04:RemoveField("FIF_CODMAJ")
		
		//Grid - Titulos sem Vendas - SE1
		oView:AddGrid("GRD01SE104", oStrSE104, "SE1FLD4")
		oView:SetOwnerView("GRD01SE104", "HB02SHT04")
		oView:SetViewProperty("GRD01SE104", "GRIDSEEK", {.T.})
		oView:SetViewProperty("GRD01SE104", "GRIDFILTER", {.T.}) 
	
		//Insere campo de Selecao do Registro na Grid
		AddField(2, oStrSE104, ,4)
		
		oStrSE104:RemoveField("E1_NSUTEF")
		oStrSE104:RemoveField("E1_DOCTEF")
		oStrSE104:RemoveField("E1_XDOCTEF")
		//oStrSE104:RemoveField("FIF_XSTATU")

		//#TB20200206 Thiago Berna - Ajuste para remover o campo
		oStrSE104:RemoveField("E1_XVLRTEF")

		//#TB20200415 Thiago Berna - Ajuste para reposicionar os campos na tela
		/*oStrSE104:SetProperty('OK'  	   	, MVC_VIEW_ORDEM ,'01')
		//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_EMISSAO
		//oStrSE104:SetProperty('E1_EMISSAO' 	, MVC_VIEW_ORDEM ,'02')
		oStrSE104:SetProperty('E1_XDTCAIX' 	, MVC_VIEW_ORDEM ,'02')
		oStrSE104:SetProperty('E1_XFILORI' 	, MVC_VIEW_ORDEM ,'03')
		oStrSE104:SetProperty('E1_XVLRREAL' , MVC_VIEW_ORDEM ,'04')
		oStrSE104:SetProperty('E1_VALOR'   	, MVC_VIEW_ORDEM ,'05')
		oStrSE104:SetProperty('E1_XVALLIQ' 	, MVC_VIEW_ORDEM ,'06')
		oStrSE104:SetProperty('E1_XSALDO'  	, MVC_VIEW_ORDEM ,'07')	
		oStrSE104:SetProperty('E1_XNSUTEF' 	, MVC_VIEW_ORDEM ,'08')
		//oStrSE104:SetProperty('E1_DOCTEF'  	, MVC_VIEW_ORDEM ,'07')
		oStrSE104:SetProperty('E1_XCARTAUT' , MVC_VIEW_ORDEM ,'09')
		oStrSE104:SetProperty('E1_CLIENTE' 	, MVC_VIEW_ORDEM ,'10')
		oStrSE104:SetProperty('E1_LOJA'    	, MVC_VIEW_ORDEM ,'11')
		oStrSE104:SetProperty('E1_NOMCLI'  	, MVC_VIEW_ORDEM ,'12')
		oStrSE104:SetProperty('E1_VENCTO'  	, MVC_VIEW_ORDEM ,'13')
		oStrSE104:SetProperty('E1_VENCREA' 	, MVC_VIEW_ORDEM ,'14')
		oStrSE104:SetProperty('E1_PREFIXO' 	, MVC_VIEW_ORDEM ,'15')
		oStrSE104:SetProperty('E1_NUM'     	, MVC_VIEW_ORDEM ,'16')
		oStrSE104:SetProperty('E1_PARCELA' 	, MVC_VIEW_ORDEM ,'17')
		oStrSE104:SetProperty('E1_TIPO'    	, MVC_VIEW_ORDEM ,'18')
		oStrSE104:SetProperty('E1_NATUREZ' 	, MVC_VIEW_ORDEM ,'19')
		//oStrSE104:SetProperty('E1_XDOCTEF' 	, MVC_VIEW_ORDEM ,'20')*/

		oStrSE104:SetProperty('OK'  	   	, MVC_VIEW_ORDEM ,'01')
		oStrSE104:SetProperty('E1_XDTCAIX' 	, MVC_VIEW_ORDEM ,'02')
		oStrSE104:SetProperty('E1_XHORAV'  	, MVC_VIEW_ORDEM ,'03')
		oStrSE104:SetProperty('E1_XFILORI' 	, MVC_VIEW_ORDEM ,'03')
		oStrSE104:SetProperty('E1_VALOR'   	, MVC_VIEW_ORDEM ,'04')
		oStrSE104:SetProperty('E1_TIPO'    	, MVC_VIEW_ORDEM ,'05')
		oStrSE104:SetProperty('E1_XDESCAD'  , MVC_VIEW_ORDEM ,'06')
		oStrSE104:SetProperty('E1_CLIENTE' 	, MVC_VIEW_ORDEM ,'07')
		oStrSE104:SetProperty('E1_LOJA'    	, MVC_VIEW_ORDEM ,'08')
		oStrSE104:SetProperty('E1_VENCTO'  	, MVC_VIEW_ORDEM ,'09')
		oStrSE104:SetProperty('E1_XVALLIQ' 	, MVC_VIEW_ORDEM ,'10')
		oStrSE104:SetProperty('E1_XNSUTEF' 	, MVC_VIEW_ORDEM ,'11')
		oStrSE104:SetProperty('E1_NUM'     	, MVC_VIEW_ORDEM ,'12')
		oStrSE104:SetProperty('E1_XSALDO'  	, MVC_VIEW_ORDEM ,'13')	
		oStrSE104:SetProperty('E1_XCARTAUT' , MVC_VIEW_ORDEM ,'14')
		oStrSE104:SetProperty('E1_XVLRREAL' , MVC_VIEW_ORDEM ,'15')
		oStrSE104:SetProperty('E1_NOMCLI'  	, MVC_VIEW_ORDEM ,'16')
		oStrSE104:SetProperty('E1_VENCREA' 	, MVC_VIEW_ORDEM ,'17')
		oStrSE104:SetProperty('E1_PREFIXO' 	, MVC_VIEW_ORDEM ,'18')
		oStrSE104:SetProperty('E1_PARCELA' 	, MVC_VIEW_ORDEM ,'19')
		oStrSE104:SetProperty('E1_NATUREZ' 	, MVC_VIEW_ORDEM ,'20')

		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 2, oStrSE104)
			
		//Botao Efetivar
		oView:AddOtherObject("btnEf04", {|oPanel| U_F910Botao(oPanel, 4,, __nFIFFLD4 = GRIDMAXLIN .OR. __nSE1FLD4 = GRIDMAXLIN)})
		oView:SetOwnerView("btnEf04", "HB03SHT04")

		oView:AddOtherObject("RODAF04", {|oPanel| U_OIF910MN(oPanel)})
		oView:SetOwnerView("RODAF04", "HB03SHT04")
		//Imprimir Browser
		//oView:AddOtherObject("btnEf06", {|oPanel| U_F910Botao(oPanel, 8 ,oView)})
	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 5
	
		/*
		-------------------------------------------------------------------
			Sheet 05 - Divergentes 01
		-------------------------------------------------------------------
		*/
		oView:AddSheet("FOLGRIDS", "SHT05", "Divergentes",{|| /*OIF910VTef(oView, 1)*/})		//"ConDivergentesciliados"
		oView:CreateHorizontalBox("HB01SHT05", 52, NIL, NIL, "FOLGRIDS", "SHT05")
		oView:CreateHorizontalBox("HB02SHT05",  6, NIL, NIL, "FOLGRIDS", "SHT05")
		oView:CreateHorizontalBox("HB03SHT05", 26, NIL, NIL, "FOLGRIDS", "SHT05")
		oView:CreateHorizontalBox("HB04SHT05", 16, NIL, NIL, "FOLGRIDS", "SHT05")

	
		//Grid Superior - Divergentes - FIF
		oView:AddGrid("GRD01FIF05", oStrFIF05, "FIFFLD5")
		oView:SetOwnerView("GRD01FIF05", "HB01SHT05")
		oView:SetViewProperty("GRD01FIF05", "GRIDSEEK", {.T.})
	
		//Insere campo de Selecao do Registro na Grid
		AddField(2, oStrFIF05)
	
		//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
		SetProp(oModel, 2, oStrFIF05)

		oView:SetViewProperty("GRD01FIF05", "CHANGELINE", {{|| /*OIF910VTef(oView, 1)*/}})
	
		oStrFIF05:RemoveField("FIF_NSUTEF")
		oStrFIF05:RemoveField("FIF_STATUS")
		oStrFIF05:RemoveField("FIF_PREFIX")
		oStrFIF05:RemoveField("FIF_NSUARQ")

		//#TB20200206 Thiago Berna - Ajuste para omitir o campo FIF_CODRED
		oStrFIF05:RemoveField("FIF_CODRED")
		
		//Libera os Campos
		oStrFIF05:SetProperty("FIF_PGJUST", 	MVC_VIEW_CANCHANGE, .T.)
		oStrFIF05:SetProperty("FIF_PGDES2", 	MVC_VIEW_CANCHANGE, .T.)

		oStrFIF05:SetProperty('OK'  	   , MVC_VIEW_ORDEM ,'01')
		oStrFIF05:SetProperty('FIF_DTTEF'  , MVC_VIEW_ORDEM ,'02')
		oStrFIF05:SetProperty('FIF_CODFIL' , MVC_VIEW_ORDEM ,'03')
		oStrFIF05:SetProperty('FIF_VLBRUT' , MVC_VIEW_ORDEM ,'04')
		oStrFIF05:SetProperty('FIF_VLLIQ'  , MVC_VIEW_ORDEM ,'05')
		oStrFIF05:SetProperty('FIF_XNSUAR' , MVC_VIEW_ORDEM ,'06')
		oStrFIF05:SetProperty('FIF_CODAUT' , MVC_VIEW_ORDEM ,'07')
		oStrFIF05:SetProperty('FIF_CODLOJ' , MVC_VIEW_ORDEM ,'08')
		oStrFIF05:SetProperty('FIF_CODEST' , MVC_VIEW_ORDEM ,'09')
		oStrFIF05:SetProperty('FIF_DTCRED' , MVC_VIEW_ORDEM ,'10')	
		oStrFIF05:SetProperty('FIF_TPREG'  , MVC_VIEW_ORDEM ,'11')
		oStrFIF05:SetProperty('FIF_NURESU' , MVC_VIEW_ORDEM ,'12')	
		oStrFIF05:SetProperty('FIF_NUCOMP' , MVC_VIEW_ORDEM ,'13')	
		oStrFIF05:SetProperty('FIF_TPPROD' , MVC_VIEW_ORDEM ,'14')	
		oStrFIF05:SetProperty('FIF_CODBCO' , MVC_VIEW_ORDEM ,'15')	
		oStrFIF05:SetProperty('FIF_CODAGE' , MVC_VIEW_ORDEM ,'16')	
		oStrFIF05:SetProperty('FIF_NUMCC'  , MVC_VIEW_ORDEM ,'17')	
		oStrFIF05:SetProperty('FIF_VLCOM'  , MVC_VIEW_ORDEM ,'18')	
		oStrFIF05:SetProperty('FIF_TXSERV' , MVC_VIEW_ORDEM ,'19')	
		oStrFIF05:SetProperty('FIF_NUM'    , MVC_VIEW_ORDEM ,'20')	
		oStrFIF05:SetProperty('FIF_PARCEL' , MVC_VIEW_ORDEM ,'21')
		oStrFIF05:SetProperty('FIF_PARALF' , MVC_VIEW_ORDEM ,'22')
		oStrFIF05:SetProperty('FIF_PARC'   , MVC_VIEW_ORDEM ,'23')	
		oStrFIF05:SetProperty('FIF_XSTATU' , MVC_VIEW_ORDEM ,'24')
		oStrFIF05:SetProperty('FIF_CODBAN' , MVC_VIEW_ORDEM ,'25')
		oStrFIF05:SetProperty('FIF_CODADM' , MVC_VIEW_ORDEM ,'26')
		oStrFIF05:SetProperty('FIF_SEQFIF' , MVC_VIEW_ORDEM ,'27')
		
		//Check Marcar Todos
		oView:AddOtherObject("chkEf05", {|oPanel| U_OIF910Mc(oPanel, 1)})
		oView:SetOwnerView("chkEf05", "HB02SHT05")

		//Grid Inferior - Conciliados Parcialmente - SE1
		oView:AddGrid("GRD01SE105", oStrSE105, "SE1FLD5")
		oView:SetOwnerView("GRD01SE105", "HB03SHT05")
//		oView:SetViewProperty("GRD01SE101", "ENABLEDGRIDDETAIL", {100})
		oView:SetViewProperty("GRD01SE105", "GRIDCANGOTFOCUS", {.F.})
	
		oStrSE105:SetNoFolder()
	
		//Insere campo VlrTEF na grid
		AddField(2, oStrSE105, ,1)
		
		//Retiro este campo de flag das abas inferiores correspondente a SE1 pois os registros são conciliados.
		oStrSE105:RemoveField('OK')
		
		oStrSE105:RemoveField("E1_NSUTEF")
		oStrSE105:RemoveField("E1_DOCTEF")
		oStrSE105:RemoveField("E1_XDOCTEF")
		//oStrSE101:RemoveField("FIF_XSTATU")

		//#TB20200206 Thiago Berna - Ajuste para remover o campo
		oStrSE105:RemoveField("E1_XVLRTEF")

		oStrSE105:SetProperty('Conciliar'  	, MVC_VIEW_ORDEM ,'01')
		//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_EMISSAO
		//oStrSE101:SetProperty('E1_EMISSAO' 	, MVC_VIEW_ORDEM ,'02')
		oStrSE105:SetProperty('E1_XDTCAIX' 	, MVC_VIEW_ORDEM ,'02')
		oStrSE105:SetProperty('E1_XFILORI' 	, MVC_VIEW_ORDEM ,'03')
		oStrSE105:SetProperty('E1_XVLRREAL' , MVC_VIEW_ORDEM ,'04')
		oStrSE105:SetProperty('E1_VALOR'   	, MVC_VIEW_ORDEM ,'05')
		
		//#TB20200206 Thiago Berna - Ajuste para remover o campo
		//oStrSE101:SetProperty('E1_XVLRTEF' 	, MVC_VIEW_ORDEM ,'06')
		
		oStrSE105:SetProperty('E1_XSALDO'  	, MVC_VIEW_ORDEM ,'07')
		oStrSE105:SetProperty('E1_XNSUTEF' 	, MVC_VIEW_ORDEM ,'08')
		//oStrSE101:SetProperty('E1_DOCTEF' 	, MVC_VIEW_ORDEM ,'08')
		oStrSE105:SetProperty('E1_XCARTAUT' , MVC_VIEW_ORDEM ,'09')
		oStrSE105:SetProperty('E1_CLIENTE' 	, MVC_VIEW_ORDEM ,'10')
		oStrSE105:SetProperty('E1_LOJA'    	, MVC_VIEW_ORDEM ,'11')
		oStrSE105:SetProperty('E1_NOMCLI'  	, MVC_VIEW_ORDEM ,'12')
		oStrSE105:SetProperty('E1_VENCTO'  	, MVC_VIEW_ORDEM ,'13')
		oStrSE105:SetProperty('E1_VENCREA' 	, MVC_VIEW_ORDEM ,'14')
		oStrSE105:SetProperty('E1_PREFIXO' 	, MVC_VIEW_ORDEM ,'15')
		oStrSE105:SetProperty('E1_NUM'     	, MVC_VIEW_ORDEM ,'16')
		oStrSE105:SetProperty('E1_PARCELA' 	, MVC_VIEW_ORDEM ,'17')
		oStrSE105:SetProperty('E1_TIPO'    	, MVC_VIEW_ORDEM ,'18')
		oStrSE105:SetProperty('E1_NATUREZ' 	, MVC_VIEW_ORDEM ,'19')
		//oStrSE101:SetProperty('E1_XDOCTEF' 	, MVC_VIEW_ORDEM ,'20')
			
		//Botao Efetivar
		oView:AddOtherObject("btnEf05", {|oPanel| U_F910Botao(oPanel, 5,,__nFIFFLD1 = GRIDMAXLIN )})
		oView:SetOwnerView("btnEf05", "HB04SHT05")
		//Imprimir Browser
		//oView:AddOtherObject("btnEf06", {|oPanel| U_F910Botao(oPanel, 8 ,oView)})
	EndIf

	
	/*
	-------------------------------------------------------------------
		Sheet 06A - Pagamentos
	-------------------------------------------------------------------
	*/
	oView:AddSheet("FOLGRIDS", "SHT6A", "Pagamentos",{|| /*OIF910VTef(oView, 1)*/})		//"Conciliados"
	oView:CreateHorizontalBox("HB01SHT6A", 52, NIL, NIL, "FOLGRIDS", "SHT6A")
	oView:CreateHorizontalBox("HB02SHT6A",  6, NIL, NIL, "FOLGRIDS", "SHT6A")
	oView:CreateHorizontalBox("HB03SHT6A", 26, NIL, NIL, "FOLGRIDS", "SHT6A")
	oView:CreateHorizontalBox("HB04SHT6A", 16, NIL, NIL, "FOLGRIDS", "SHT6A")

	
	//Grid Superior - Conciliados - FIF
	oView:AddGrid("GRD01FIF6A", oStrFIF6A, "FIFFLD6A")
	oView:SetOwnerView("GRD01FIF6A", "HB01SHT6A")
	oView:SetViewProperty("GRD01FIF6A", "GRIDSEEK", {.T.})
	
	//Insere campo de Selecao do Registro na Grid
	AddField(2, oStrFIF6A,,8)

	//Bloqueia alteracoes em todos os campos da grid com excecao do campo de selecao
	SetProp(oModel, 2, oStrFIF6A)

	oView:SetViewProperty("GRD01FIF6A", "CHANGELINE", {{|| /*OIF910VTef(oView, 1)*/}})
	
	oStrFIF6A:RemoveField("FIF_PGJUST")
	oStrFIF6A:RemoveField("FIF_PGDES1")
	oStrFIF6A:RemoveField("FIF_PGDES2")
	oStrFIF6A:RemoveField("FIF_CODMAJ")
	oStrFIF6A:RemoveField("FIF_NSUTEF")
	oStrFIF6A:RemoveField("FIF_STATUS")
	oStrFIF6A:RemoveField("FIF_PREFIX")
	oStrFIF6A:RemoveField("FIF_NSUARQ")

	//#TB20200206 Thiago Berna - Ajuste para omitir o campo FIF_CODRED
	oStrFIF6A:RemoveField("FIF_CODRED")
	
	oStrFIF6A:SetProperty('OK'  	   , MVC_VIEW_ORDEM ,'01')
	oStrFIF6A:SetProperty('FIF_DTTEF'  , MVC_VIEW_ORDEM ,'02')
	oStrFIF6A:SetProperty('FIF_CODFIL' , MVC_VIEW_ORDEM ,'03')
	oStrFIF6A:SetProperty('FIF_VLBRUT' , MVC_VIEW_ORDEM ,'04')
	oStrFIF6A:SetProperty('FIF_VLLIQ'  , MVC_VIEW_ORDEM ,'05')
	oStrFIF6A:SetProperty('FIF_XNSUAR' , MVC_VIEW_ORDEM ,'06')
	oStrFIF6A:SetProperty('FIF_CODAUT' , MVC_VIEW_ORDEM ,'07')
	oStrFIF6A:SetProperty('FIF_CODLOJ' , MVC_VIEW_ORDEM ,'08')
	oStrFIF6A:SetProperty('FIF_CODEST' , MVC_VIEW_ORDEM ,'09')
	oStrFIF6A:SetProperty('FIF_DTCRED' , MVC_VIEW_ORDEM ,'10')	
	oStrFIF6A:SetProperty('FIF_TPREG'  , MVC_VIEW_ORDEM ,'11')
	oStrFIF6A:SetProperty('FIF_NURESU' , MVC_VIEW_ORDEM ,'12')	
	oStrFIF6A:SetProperty('FIF_NUCOMP' , MVC_VIEW_ORDEM ,'13')	
	oStrFIF6A:SetProperty('FIF_TPPROD' , MVC_VIEW_ORDEM ,'14')	
	oStrFIF6A:SetProperty('FIF_CODBCO' , MVC_VIEW_ORDEM ,'15')	
	oStrFIF6A:SetProperty('FIF_CODAGE' , MVC_VIEW_ORDEM ,'16')	
	oStrFIF6A:SetProperty('FIF_NUMCC'  , MVC_VIEW_ORDEM ,'17')	
	oStrFIF6A:SetProperty('FIF_VLCOM'  , MVC_VIEW_ORDEM ,'18')	
	oStrFIF6A:SetProperty('FIF_TXSERV' , MVC_VIEW_ORDEM ,'19')	
	oStrFIF6A:SetProperty('FIF_NUM'    , MVC_VIEW_ORDEM ,'20')	
	oStrFIF6A:SetProperty('FIF_PARCEL' , MVC_VIEW_ORDEM ,'21')
	oStrFIF6A:SetProperty('FIF_PARALF' , MVC_VIEW_ORDEM ,'22')
	oStrFIF6A:SetProperty('FIF_PARC'   , MVC_VIEW_ORDEM ,'23')	
	oStrFIF6A:SetProperty('FIF_XSTATU' , MVC_VIEW_ORDEM ,'24')
	oStrFIF6A:SetProperty('FIF_CODBAN' , MVC_VIEW_ORDEM ,'25')
	oStrFIF6A:SetProperty('FIF_CODADM' , MVC_VIEW_ORDEM ,'26')
	oStrFIF6A:SetProperty('FIF_SEQFIF' , MVC_VIEW_ORDEM ,'27')
		
	//Check Marcar Todos
	oView:AddOtherObject("chkEf6A", {|oPanel| U_OIF910Mc(oPanel, 8)})
	oView:SetOwnerView("chkEf6A", "HB02SHT6A")

	//Grid Inferior - Conciliados Parcialmente - SE1
	oView:AddGrid("GRD01SE16A", oStrSE16A, "SE1FLD6A")
	oView:SetOwnerView("GRD01SE16A", "HB03SHT6A")
	oView:SetViewProperty("GRD01SE16A", "GRIDCANGOTFOCUS", {.F.})
	
	oStrSE16A:SetNoFolder()
	
	//Insere campo Customizado
	AddField(2, oStrSE16A, ,8)
		
	//Retiro este campo de flag das abas inferiores correspondente a SE1 pois os registros são conciliados.
	oStrSE16A:RemoveField('OK')
		
	oStrSE16A:RemoveField("E1_NSUTEF")
	oStrSE16A:RemoveField("E1_DOCTEF")
	oStrSE16A:RemoveField("E1_XDOCTEF")
	
	//#TB20200206 Thiago Berna - Ajuste para remover o campo
	oStrSE16A:RemoveField("E1_XVLRTEF")

	oStrSE16A:SetProperty('Conciliar'  	, MVC_VIEW_ORDEM ,'01')
	//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_EMISSAO
	//oStrSE101:SetProperty('E1_EMISSAO' 	, MVC_VIEW_ORDEM ,'02')
	oStrSE16A:SetProperty('E1_XDTCAIX' 	, MVC_VIEW_ORDEM ,'02')
	oStrSE16A:SetProperty('E1_XFILORI' 	, MVC_VIEW_ORDEM ,'03')
	oStrSE16A:SetProperty('E1_XVLRREAL' , MVC_VIEW_ORDEM ,'04')
	oStrSE16A:SetProperty('E1_VALOR'   	, MVC_VIEW_ORDEM ,'05')
		
	//#TB20200206 Thiago Berna - Ajuste para remover o campo
	//oStrSE101:SetProperty('E1_XVLRTEF' 	, MVC_VIEW_ORDEM ,'06')
		
	oStrSE16A:SetProperty('E1_XSALDO'  	, MVC_VIEW_ORDEM ,'07')
	oStrSE16A:SetProperty('E1_XNSUTEF' 	, MVC_VIEW_ORDEM ,'08')
	//oStrSE101:SetProperty('E1_DOCTEF' 	, MVC_VIEW_ORDEM ,'08')
	oStrSE16A:SetProperty('E1_XCARTAUT' , MVC_VIEW_ORDEM ,'09')
	oStrSE16A:SetProperty('E1_CLIENTE' 	, MVC_VIEW_ORDEM ,'10')
	oStrSE16A:SetProperty('E1_LOJA'    	, MVC_VIEW_ORDEM ,'11')
	oStrSE16A:SetProperty('E1_NOMCLI'  	, MVC_VIEW_ORDEM ,'12')
	oStrSE16A:SetProperty('E1_VENCTO'  	, MVC_VIEW_ORDEM ,'13')
	oStrSE16A:SetProperty('E1_VENCREA' 	, MVC_VIEW_ORDEM ,'14')
	oStrSE16A:SetProperty('E1_PREFIXO' 	, MVC_VIEW_ORDEM ,'15')
	oStrSE16A:SetProperty('E1_NUM'     	, MVC_VIEW_ORDEM ,'16')
	oStrSE16A:SetProperty('E1_PARCELA' 	, MVC_VIEW_ORDEM ,'17')
	oStrSE16A:SetProperty('E1_TIPO'    	, MVC_VIEW_ORDEM ,'18')
	oStrSE16A:SetProperty('E1_NATUREZ' 	, MVC_VIEW_ORDEM ,'19')
	//oStrSE101:SetProperty('E1_XDOCTEF' 	, MVC_VIEW_ORDEM ,'20')
		
	//Botao Efetivar
	oView:AddOtherObject("btnEf6A", {|oPanel| U_F910Botao(oPanel, 8,,__nFIFFLD1 = GRIDMAXLIN )})
	oView:SetOwnerView("btnEf6A", "HB04SHT6A")
	//Imprimir Browser
	//oView:AddOtherObject("btnEf06", {|oPanel| U_F910Botao(oPanel, 8 ,oView)})
		
	/*
	-------------------------------------------------------------------
		Sheet 06 - Totais
	-------------------------------------------------------------------
	*/
	

	oView:AddSheet("FOLGRIDS", "SHT06", "Totais")		//"Totais"
	oView:CreateHorizontalBox("HB01SHT06", 100, NIL, NIL, "FOLGRIDS", "SHT06")
	oView:AddGrid("GRD01TOT06", oStrTot06, "TOTFLD6")
	oView:SetOwnerView("GRD01TOT06", "HB01SHT06")
	oView:SetViewProperty("GRD01TOT06", "GRIDSEEK", {.T.})

	oView:SetProgressBar(.T.)

	//#TB20200121 Thiago Berna - Nova Aba de fechamento
	/*
	-------------------------------------------------------------------
		Sheet 07 - Fechamento
	-------------------------------------------------------------------
	*/

	oView:AddSheet("FOLGRIDS", "SHT07", "Fechamento",{|| fLoadFec(oView, 2), oView:Refresh("TOTFLD7"),__oRefer:Refresh(),__oDinhe:Refresh(),__oTotal:Refresh(),__oDebit:Refresh(),__oStatu:Refresh(),__oCredi:Refresh(),__oTaxas:Refresh()})		
	
	oView:CreateHorizontalBox("HB01SHT07", 030, NIL, NIL, "FOLGRIDS", "SHT07")
	oView:CreateHorizontalBox("HB02SHT07", 070, NIL, NIL, "FOLGRIDS", "SHT07")
	oView:AddGrid("GRD01TOT07", oStrTot07, "TOTFLD7")
	oView:SetOwnerView("GRD01TOT07", "HB02SHT07")
	oView:SetViewProperty("GRD01TOT07", "GRIDSEEK", {.T.})
	oView:SetViewProperty("GRD01TOT07", "GRIDFILTER", {.T.})

	oView:AddOtherObject("CABECFEC", {|oPanel| U_OIF910FC(oPanel)})
	oView:SetOwnerView("CABECFEC", "HB01SHT07")

	//Botao Confirmar
	oView:AddOtherObject("btnEf07", {|oPanel| U_F910BTFC(oPanel, 1,,__nFIFFLD1 = GRIDMAXLIN )})
	oView:SetOwnerView("btnEf07", "HB01SHT07")

	oView:SetProgressBar(.T.)

	oView:EnableControlBar(.T.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F910Botao
Inclusao de Botao de Efetivacao

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
User Function F910Botao( oPanel, nSheet, oView, lMsg ,oModel)
	Local oButton	As Object
	Local oSay      As Object
	
	//#TB20191218 Thiago Berna - Ajuste para Default para nao sobreescrever a variavel recebida
	//Local lMsg := .F.
	Default lMsg	:= .F.
	Default oView	:= FwViewActive()
	Default oModel	:= FwModelActive()
	
	//#TB20200216 Thiago Berna - Ajuste botoes
	//If nSheet != 5
	    //If nSheet == 8
			//@018, 000 BUTTON oButton PROMPT "Imprimir"  SIZE 070, 020 FONT oPanel:oFont ACTION Processa(	{|| OIF910Print(oView)},"Aguarde...","Preparando a Impress�o...") OF oPanel PIXEL //OIF910Print(oView) OF oPanel PIXEL		//"Imprimir Browser"
		//Else
			//@020, 010 BUTTON oButton PROMPT IIf( nSheet == 8,"Efetivar","Conciliar") SIZE 060, 020 FONT oPanel:oFont ACTION Processa(	{|| U_OIF910Gv(nSheet,oModel),oView:Refresh('FIFFLD1'),oView:Refresh('SE1FLD1'),oView:Refresh('FIFFLD5'),oView:Refresh('SE1FLD5'),U_F910LckA()},"Aguarde...","Executando...") OF oPanel PIXEL
		//Endif
	//Else
	//	@020, 010 BUTTON oButton PROMPT "Gravar" SIZE 060, 020 FONT oPanel:oFont ACTION Processa(	{|| U_OIF910Gv(nSheet)},"Aguarde...","Preparando Dados para Grava��o...") OF oPanel PIXEL //U_OIF910Gv(nSheet) OF oPanel PIXEL		//"Gravar"
	//EndIf
	
	If lMsg
		If nSheet == 1 .OR. nSheet == 2
			@020, 100 Say oSay PROMPT STR0087  SIZE 400, 020 FONT  OF oPanel PIXEL		//"A quantidade de registros de vendas execedeu o limite máximo de 10.000(dez mil). Após concluir a conciliação repita o processamento da rotina com a mesma parametrização para conciliar o restante dos registros."
		ElseIf nSheet == 3
			@020, 100 Say oSay PROMPT STR0088  SIZE 400, 020 FONT  OF oPanel PIXEL		//"A quantidade de registros de títulos execedeu o limite máximo de 10.000(dez mil). Após concluir a conciliação repita o processamento da rotina com a mesma parametrização para conciliar o restante dos registros."		
		ElseIf nSheet == 4
			If __nFIFFLD4 = GRIDMAXLIN .And. __nSE1FLD4 = GRIDMAXLIN
				@020, 100 Say oSay PROMPT STR0089  SIZE 400, 020 FONT  OF oPanel PIXEL		//"A quantidade de registros de vendas e títulos execederam o limite máximo de 10.000(dez mil). Após concluir a conciliação repita o processamento da rotina com a mesma parametrização para conciliar o restante dos registros."	
			ElseIf __nFIFFLD4 = GRIDMAXLIN
				@020, 100 Say oSay PROMPT STR0087  SIZE 400, 020 FONT  OF oPanel PIXEL		//"A quantidade de registros de vendas execedeu o limite máximo de 10.000(dez mil). Após concluir a conciliação repita o processamento da rotina com a mesma parametrização para conciliar o restante dos registros."			
			ElseIf __nSE1FLD4 = GRIDMAXLIN
				@020, 100 Say oSay PROMPT STR0088  SIZE 400, 020 FONT  OF oPanel PIXEL		//"A quantidade de registros de títulos execedeu o limite máximo de 10.000(dez mil). Após concluir a conciliação repita o processamento da rotina com a mesma parametrização para conciliar o restante dos registros."
			EndIf
		ElseIf nSheet == 5
			@020, 100 Say oSay PROMPT STR0090  SIZE 400, 020 FONT  OF oPanel PIXEL		//"A quantidade de registros de divergencias execedeu o limite máximo de 10.000(dez mil). Após concluir a conciliação repita o processamento da rotina com a mesma parametrização para conciliar o restante dos registros."		
		EndIf
	EndIf

	//#TB20191218 Thiago Berna - Ponto de entrada para permitir criar um novo bot�o
	//If ExistBlock( 'F910BOTN' )
	//	Execblock( 'F910BOTN', .F., .F., {nSheet, oPanel} )
	//EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F910Marc
Inclusao de Check para marcar todos

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
User Function F910Marc( oPanel, nSheet )
	Local oCheck	As Object
	Do Case
	Case nSheet == 1
		__lCheck01 := .T.
		@003, 003 CHECKBOX oCheck VAR __lCheck01 Size 060, 020 PROMPT "Marca todos" ON Change(U_F910CHECK(__lCheck01, nSheet)) Of oPanel	//"Marca todos"
	Case nSheet == 2
		__lCheck02 := .T.
		@003, 003 CHECKBOX oCheck VAR __lCheck02 Size 060, 020 PROMPT "Marca todos" ON Change(U_F910CHECK(__lCheck02, nSheet)) Of oPanel	//"Marca todos"
	Case nSheet == 3
		@003, 003 CHECKBOX oCheck VAR __lCheck03 Size 060, 020 PROMPT "Marca todos" ON Change(U_F910CHECK(__lCheck03, nSheet)) Of oPanel	//"Marca todos"
	Case nSheet == 8
		__lCheck08 := .T.
		@003, 003 CHECKBOX oCheck VAR __lCheck08 Size 060, 020 PROMPT "Marca todos" ON Change(U_F910CHECK(__lCheck08, nSheet)) Of oPanel	//"Marca todos"
	EndCase
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} U_F910CHECK
Marca ou desmarca todos os Registros da Sheet ativa

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
User Function F910Check( lCheck, nSheet )
	Local nLinBkp	As Numeric
	Local nLinFIF	As Numeric
	Local nLinSE1	As Numeric
	Local oModel	As Object
	Local oView		As Object

	nLinBkp	:= 0
	nLinFIF	:= 0
	nLinSE1	:= 0
	oModel	:= FWModelActive()
	oView 	:= FwViewActive()

	Do Case
	Case nSheet == 1

		nLinBkp := oModel:GetModel("FIFFLD1"):GetLine()
	
		
		For nLinFIF := 1 to oModel:GetModel("FIFFLD1"):Length()
			oModel:GetModel("FIFFLD1"):GoLine(nLinFIF)
			
			oModel:SetValue("FIFFLD1", "OK", lCheck)
		Next nLinFIF
		

		oModel:GetModel("FIFFLD1"):GoLine(nLinBkp)

	Case nSheet == 2

		nLinBkp := oModel:GetModel("FIFFLD2"):GetLine()

		
		For nLinFIF := 1 to oModel:GetModel("FIFFLD2"):Length()

			oModel:GetModel("FIFFLD2"):GoLine(nLinFIF)
			oModel:SetValue("FIFFLD2", "OK", lCheck)

		Next nLinFIF
		

		oModel:GetModel("FIFFLD2"):GoLine(nLinBkp)

	Case nSheet == 3

		nLinBkp := oModel:GetModel("FIFFLD3"):GetLine()

		
		For nLinFIF := 1 to oModel:GetModel("FIFFLD3"):Length()
			oModel:GetModel("FIFFLD3"):GoLine(nLinFIF)
			If !Empty(oModel:GetModel("FIFFLD3"):GetValue("E1_NSUTEF"))
				oModel:SetValue("FIFFLD3", "OK", lCheck)
			EndIf

		Next nLinFIF
		

		oModel:GetModel("FIFFLD3"):GoLine(nLinBkp)

	EndCase

	oView:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} U_OIF910Ms
Painel com a descrição do motivo de rejeição na aba divergente

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
User Function OIF910Ms( oPanel, cDescri )
	
	DEFINE FONT oFnt NAME "Arial" SIZE 11,20 
	@ 015, 010 SAY   "Detalhes" SIZE 050, 020 OF oPanel PIXEL FONT oFnt COLOR CLR_HBLUE
	@ 030, 010 MSGET __oDescri VAR cDescri SIZE 200, 40  Of oPanel PIXEL When .F.
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fLinDbFVY
Inclui informação do motivo de rejeição na aba divergente

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
/*Static function fLinDbFVY( oForm As Object, cFieldName As Character, nLineGrid As Numeric, nLineModel As Numeric, cDescri As Character ) As Logical
	Local lRet			As Logical
	Local oModel		As Object 
	Local oModelGrid	As Object
	Local cCampo		As Character
	Local cCodFil		As Character

	lRet		:= .T.
	oModel		:= FWModelActivate() 
	oModelGrid	:= oModel:GetModel('FIFFLD5')
	cCampo		:= ""
	cDescri		:= ""
	cCodFil		:= ""
	
	If U_F910CHKMOD("FVY") // Verifica se modo da tabela é exclusivo
		cCodFil := oModelGrid:GetValue("FIF_CODFIL")
	Else
		cCodFil := xFilial("FVY")
	EndIf

	DbSelectArea("FVY")
	FVY->(DbSetOrder(1))
	
	If FVY->(DbSeek(cCodFil + oModelGrid:GetValue("FIF_CODADM") + oModelGrid:GetValue("FIF_CODMAJ") ))
		cDescri := Alltrim(FVY->FVY_DESCR)
	Else
		cDescri := " "
	Endif			
		
Return lRet*/

//-------------------------------------------------------------------
/*/{Protheus.doc} U_OIF910Gv
Gravacao dos Dados Selecionados para Conciliacao

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
User Function OIF910Gv( nSheet, oSubMod, cPar01, cPar02 )
	
	Local oModel	As Object
	Local oView		As Object
	Local oModNew	As Object
	Local oSubFIF	As Object
	Local oSubSE1	As Object
	Local nLinFIF	As Numeric
	Local nLinSE1	As Numeric
	Local nCount	As Numeric
	Local nSumSE1	As Numeric
	Local nSumFIF	As Numeric
	Local nConSE1	As Numeric
	Local nConFIF	As Numeric
	Local n460		As Numeric
	Local nAjuLim	As Numeric
	Local lRegSE1	As Logical
	Local lRetorno	As Logical
	Local lGestao 	As Logical
	Local lAjuDin	As Logical
	Local lF460SA1	As Logical
	Local lMenorSitef	As Logical
	Local cThreadId	As Character
	Local cLog		As Character
	Local cCodUser  As Character
	Local cFIFNsu	As Character
	Local cFIFAut	As Character
	Local cQuery	As Character
	Local cSeqFIF	As Character
	Local cFilOrig	As Character
	Local cParcSE1	As Character
	Local cFIFAlias	As Character
	Local cAliasSE1 As Character
	Local cTipSE1	As Character
	Local cTipFIF	As Character
	Local cFil460	As Character
	Local cNatureza	As Character
	//Local cQuery	As Character
	Local cAliasZWX	As Character
	//Local cPar01	As Character
	//Local cPar02	As Character
	Local cPar03	As Character
	//Local cPar04	As Character
	Local cCodAdm	As Character
	Local cBanco	As Character
	Local cAgencia	As Character
	Local cConta	AS Character
	Local cIdSel	As Character
	Local aTemp		As Array
	Local aSelFIF	As Array
	Local aSelSE1	As Array
	Local aTit460	As Array
	Local aTitAju	As Array
	Local aIten460	As Array
	Local aCab460	As Array
	Local aColsAux  As Array
	Local aConc		As Array
	Local aLotes	As Array
	Local aRecSel	As Array
	Local aAreaSE1	As Array
	Local aDadosPE	As Array
	Local dDataOri 	As Date
	Local dVencto	As Date
	
	Private lMsErroAuto     := .F.
	//Private lAutoErrNoFile  := .T.

	If !Empty(FWModelActive())
		oModel 	:= FWModelActive()	
	Else
		oModel	:= oSubMod
	EndIf

	//oModel		:= FWModelActive()
	oView		:= FwViewActive()
	cThreadId   := "OIFINA910_"+AllTrim(Str(ThreadId()))
	cLog		:= ""
	cCodUser	:= RetCodUsr() //R
	cQuery 		:= ""
	cSeqFIF 	:= ""
	cFilOrig 	:= ""
	cParcSE1 	:= ""
	cFIFAlias 	:= ""
	cAliasSE1	:= GetNextAlias()
	cFIFNsu		:= ""
	cFIFAut		:= ""
	cTipSE1		:= ""
	cTipFIF		:= ""
	cFil460		:= ""
	cNatureza	:= ""
	//cQuery		:= ""
	cAliasZWX	:= GetNextAlias()
	//cPar01  	:= MV_PAR01
	//cPar02		:= MV_PAR02
	//cPar03		:= MV_PAR03
	//cPar04		:= MV_PAR04
	cCodAdm		:= ""
	cBanco		:= ""
	cAgencia	:= ""
	cConta		:= ""
	lExiJus		:= SuperGetMv("MV_XEXIJUS",,.T.)
	aTemp		:= {}
	aSelFIF		:= {}
	aSelSE1		:= {}
	aTit460		:= {}
	aTitAju		:= {}
	aIten460	:= {}
	aCab460		:= {}
	aColsAux  	:= {}
	aConc		:= {}
	aLotes		:= {}
	aDadosPE	:= {}
	nLinFIF		:= 0
	nLinSE1		:= 0
	nCount		:= 0
	nSumSE1		:= 0
	nSumFIF		:= 0
	nConSE1		:= 0
	nConFIF		:= 0
	n460		:= 0
	nAjuLim		:= SuperGetMv("MV_XAJULIM",,0.10)
	lRegSE1		:= .F.
	lRetorno	:= .T.
	lMenorSitef := .F.
	lGestao   	:= FWSizeFilial() > 2
	lAjuDin		:= .F.
	lF460SA1	:= ExistBlock("F460SA1")
	dDataOri	:= dDataBase
	dVencto		:= STOD('')
	
	cFilBkp := cFilAnt

	If lF460SA1
		//Carrega a variavel global para carregar dados do ponto de entrada
		PutGlbVars(cThreadId,aDadosPE)
	EndIf

	Begin Transaction
	
		If nSheet != 8

			//Pergunte("FINA910OIF", .F.)
			
			cQuery := "SELECT * FROM " + RetSqlTab("ZWX")
			//If !Empty(MV_PAR02)
				cQuery += "WHERE ZWX.ZWX_FILIAL = '" + xFilial("ZWX") + "' "
			//Else
			//	cQuery += "WHERE ZWX.ZWX_FILIAL >= '' "
			//EndIf
			cQuery += "AND ZWX.ZWX_DATA = '" + DtoS(cPar02) + "' "
			cQuery += "AND ZWX.D_E_L_E_T_ <> '*' " 

			cQuery := ChangeQuery(cQuery)

			If Select(cAliasZWX) > 0
				(cAliasZWX)->(DbCloseArea())
			EndIf

			DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasZWX, .T., .T.)

			//MV_PAR01 := cPar01
			//MV_PAR02 := cPar02
			//MV_PAR03 := cPar03
			//MV_PAR04 := cPar04
			
			If (cAliasZWX)->(!Eof())
				MsgInfo("Per�odo fechado n�o pode ser conciliado.")
				Return
			EndIf


		EndIf

		Do Case
		Case nSheet == 1	//Conciliado Normal - FIF_STATUS := "2"
			//Begin Transaction
				oSubFIF := oModel:GetModel("FIFFLD1")
				oSubSE1 := oModel:GetModel("SE1FLD1")
				
				DbSelectArea("SE1")
				SE1->(DbSetOrder(1))
				
				
				For nLinFIF := 1 to oSubFIF:Length()
					oSubFIF:GoLine(nLinFIF)

					If oSubFIF:GetValue("OK")
						
						//If !SE1->(DbSeek(Iif(lGestao, oSubSE1:GetValue("E1_FILORIG"), xFilial("SE1"))+oSubSE1:GetValue("E1_PREFIXO")+oSubSE1:GetValue("E1_NUM")+oSubSE1:GetValue("E1_PARCELA")+oSubSE1:GetValue("E1_TIPO")))
						If !SE1->(DbSeek(oSubSE1:GetValue("E1_FILORIG")+oSubSE1:GetValue("E1_PREFIXO")+oSubSE1:GetValue("E1_NUM")+oSubSE1:GetValue("E1_PARCELA")+oSubSE1:GetValue("E1_TIPO")))
						
							MsgInfo("Arquivo nao encontrado no Financeiro")
									
						Else
								
								aDadoBanco := BuscarBanco(Right(RTrim(oSubFIF:GetValue("FIF_CODBCO")), nTamBanco), Right(RTrim(oSubFIF:GetValue("FIF_CODAGE")), nTamAgencia),Right(RTrim(oSubFIF:GetValue("FIF_NUMCC")), nTamCC),oSubFIF:GetValue("FIF_VLLIQ"))
							
								DbSelectArea("FIF")
								DbSetOrder(5)	//FIF_FILIAL, FIF_DTTEF, FIF_NSUTEF, FIF_PARCEL, FIF_CODLOJ, FIF_DTCRED, FIF_SEQFIF
								
								If FIF->(DbSeek(oSubFIF:GetValue("FIF_FILIAL") + DtoS(oSubFIF:GetValue("FIF_DTTEF")) + oSubFIF:GetValue("FIF_NSUTEF") + oSubFIF:GetValue("FIF_PARCEL") + oSubFIF:GetValue("FIF_CODLOJ") + DtoS(oSubFIF:GetValue("FIF_DTCRED")) + oSubFIF:GetValue("FIF_SEQFIF")))
								
									oModNew := FWLoadModel("FINA916A")
									oModNew:SetOperation(MODEL_OPERATION_UPDATE)	//Alteração
									oModNew:Activate()
									oModNew:GetModel("HEADER"):SetValue("FIF_STATUS", IIf( FIF->FIF_STATUS == '6', '7', '2') )
									oModNew:GetModel("HEADER"):SetValue("FIF_PREFIX", oSubSE1:GetValue("E1_PREFIXO"))
									oModNew:GetModel("HEADER"):SetValue("FIF_NUM"	, oSubSE1:GetValue("E1_NUM")	)
									oModNew:GetModel("HEADER"):SetValue("FIF_PARC"	, oSubSE1:GetValue("E1_PARCELA"))
									oModNew:GetModel("HEADER"):SetValue("FIF_PGJUST", oSubFIF:GetValue("FIF_PGJUST"))
									oModNew:GetModel("HEADER"):SetValue("FIF_PGDES1", oSubFIF:GetValue("FIF_PGDES1"))
									oModNew:GetModel("HEADER"):SetValue("FIF_PGDES2", oSubFIF:GetValue("FIF_PGDES2"))
									oModNew:GetModel("HEADER"):SetValue("FIF_USUPAG", RetCodUsr())
									oModNew:GetModel("HEADER"):SetValue("FIF_DTPAG"	, dDatabase)
									
									If oModNew:VldData()
										oModNew:CommitData()
										nCount++									
									Else
										lRetorno := .F.
										cLog := cValToChar(oModNew:GetErrorMessage()[4]) + ' - '
										cLog += cValToChar(oModNew:GetErrorMessage()[5]) + ' - '
										cLog += cValToChar(oModNew:GetErrorMessage()[6])        	
				
										Help(NIL, NIL, "U_OIF910Gv", NIL, cLog, 1, 0)
										DisarmTransaction()
										Exit
									EndIf
									oModNew:DeActivate()
									oModNew:Destroy()
									oModNew:=NIL
								EndIf
							//EndIf
						endif
					EndIf
				Next nLinFIF
				
				/*//#TB20200208 Thiago Berna - Ajuste para alterar o status do registro na tela
				oSubFIF:SetNoDeleteLine(.F.)
				oSubFIF:DelAllLine()
				oSubFIF:AddLine(.T.)
				oSubFIF:SetNoDeleteLine(.T.)

				//Recria array com os novos dados
				aSize(atemp,1)
				aCopy(oSubFIF:aDataModel,aTemp,Len(oSubFIF:aDataModel))
				oSubFIF:aDataModel := aClone(aTemp)*/

				//#TB20200221 Thiago Berna - Desmarcar registros
				U_OIF910Check( .F., nSheet,oModel )
				
				
			
			//End Transaction
		Case nSheet == 2	//Conciliado Parcialmente - FIF_STATUS := "2"
			//Begin Transaction
				oSubFIF := oModel:GetModel("FIFFLD2")
				oSubSE1 := oModel:GetModel("SE1FLD2")
				
				dbSelectArea("SE1")
				SE1->(DbSetOrder(1))
				//SE1->(DbOrderNickName("CONC"))
				
			
				For nLinFIF := 1 to oSubFIF:Length()
					oSubFIF:GoLine(nLinFIF)

					If oSubFIF:GetValue("OK")
						
						//If !SE1->(DbSeek(Iif(lGestao, oSubSE1:GetValue("E1_FILORIG"), xFilial("SE1"))+oSubSE1:GetValue("E1_PREFIXO")+oSubSE1:GetValue("E1_NUM")+oSubSE1:GetValue("E1_PARCELA")+oSubSE1:GetValue("E1_TIPO")))
						If !SE1->(DbSeek(oSubSE1:GetValue("E1_FILORIG"), xFilial("SE1"))+oSubSE1:GetValue("E1_PREFIXO")+oSubSE1:GetValue("E1_NUM")+oSubSE1:GetValue("E1_PARCELA")+oSubSE1:GetValue("E1_TIPO"))
						
							MsgInfo("Arquivo nao encontrado no Financeiro")
									
						Else
					
								aDadoBanco := BuscarBanco(Right(RTrim(oSubFIF:GetValue("FIF_CODBCO")), nTamBanco), Right(RTrim(oSubFIF:GetValue("FIF_CODAGE")), nTamAgencia),Right(RTrim(oSubFIF:GetValue("FIF_NUMCC")), nTamCC),oSubFIF:GetValue("FIF_VLLIQ"))
								
								DbSelectArea("FIF")
								DbSetOrder(5)	//FIF_FILIAL, FIF_DTTEF, FIF_NSUTEF, FIF_PARCEL, FIF_CODLOJ, FIF_DTCRED, FIF_SEQFIF
								
								If FIF->(DbSeek(oSubFIF:GetValue("FIF_FILIAL") + DtoS(oSubFIF:GetValue("FIF_DTTEF")) + oSubFIF:GetValue("FIF_NSUTEF") + oSubFIF:GetValue("FIF_PARCEL") + oSubFIF:GetValue("FIF_CODLOJ") + DtoS(oSubFIF:GetValue("FIF_DTCRED")) + oSubFIF:GetValue("FIF_SEQFIF")))
									
									oModNew := FWLoadModel("FINA916A")
									oModNew:SetOperation(MODEL_OPERATION_UPDATE)	//Alteração
									oModNew:Activate()
									oModNew:GetModel("HEADER"):SetValue("FIF_STATUS", IIf( FIF->FIF_STATUS == '6', '7', '2') )
									oModNew:GetModel("HEADER"):SetValue("FIF_PREFIX", oSubSE1:GetValue("E1_PREFIXO"))
									oModNew:GetModel("HEADER"):SetValue("FIF_NUM"	, oSubSE1:GetValue("E1_NUM")	)
									oModNew:GetModel("HEADER"):SetValue("FIF_PARC"	, oSubSE1:GetValue("E1_PARCELA"))
									oModNew:GetModel("HEADER"):SetValue("FIF_PGJUST", oSubFIF:GetValue("FIF_PGJUST"))
									oModNew:GetModel("HEADER"):SetValue("FIF_PGDES1", oSubFIF:GetValue("FIF_PGDES1"))
									oModNew:GetModel("HEADER"):SetValue("FIF_PGDES2", oSubFIF:GetValue("FIF_PGDES2"))
									oModNew:GetModel("HEADER"):SetValue("FIF_USUPAG", RetCodUsr())
									oModNew:GetModel("HEADER"):SetValue("FIF_DTPAG"	, dDatabase)
									
									If oModNew:VldData()
										oModNew:CommitData()
										nCount++
									Else
										lRetorno := .F.
										cLog := cValToChar(oModNew:GetErrorMessage()[4]) + ' - '
										cLog += cValToChar(oModNew:GetErrorMessage()[5]) + ' - '
										cLog += cValToChar(oModNew:GetErrorMessage()[6])        	
				
										Help(NIL, NIL, "U_OIF910Gv", NIL, cLog, 1, 0)
										DisarmTransaction()
										Exit
									EndIf
									oModNew:DeActivate()
									oModNew:Destroy()
									oModNew:=NIL
								EndIf
							//EndIf
						endif
					EndIf
				Next nLinFIF
				
			//End Transaction
		Case nSheet == 4	//Conciliados Manualmente
			//Nenhuma acao ou incluir FIF com os Titulos Selecionados?
			//Se incluir FIF gravar FIF_STATUS como "6"
			//Begin Transaction
				
				oSubFIF := oModel:GetModel("FIFFLD4")
				oSubSE1 := oModel:GetModel("SE1FLD4")
				
				nSumFIF := 0
				nSumSE1	:= 0
				
				For nLinFIF := 1 to oSubFIF:Length()
					oSubFIF:GoLine(nLinFIF)
					If oSubFIF:GetValue("OK")
						nSumFIF += oSubFIF:GetValue("FIF_VLBRUT")
						nConFIF++
						AAdd(aSelFIF,nLinFIF)
						If Empty(cFIFNsu)
							cFIFNsu := oSubFIF:GetValue("FIF_NSUTEF")
							cFIFAut	:= oSubFIF:GetValue("FIF_CODAUT")
							cTipFIF	:= oSubFIF:GetValue("FIF_TPPROD") 
						EndIf
					
						If lExiJus
							If Empty(oSubFIF:GetValue("FIF_PGJUST"))
								lRetorno := .F.
								Exit
							EndIf
						EndIf
					EndIf
				Next nLinFIF

				For nLinSE1 := 1 to oSubSE1:Length()
					oSubSE1:GoLine(nLinSE1)
					If oSubSE1:GetValue("OK")
						nSumSE1 += oSubSE1:GetValue("E1_VALOR")
						nConSE1++
						AAdd(aSelSE1,nLinSE1)
						If Empty(cTipSE1)
							cTipSE1	:= oSubSE1:GetValue("E1_TIPO")
						EndIf
					EndIf
				Next nLinSE1

				If !lRetorno
					Help(NIL, NIL, "U_OIF910Gv", NIL, "Informe o C�digo da Justificativa (Campo: Cd.Just.Pagt.) para a Concilia��o.", 1, 0)		//"Informe a Justificativa para a Conciliação."
				//ElseIf nSumFIF <> nSumSE1 .Or. nSumFIF == 0 .Or. nSumSE1 == 0
				ElseIf nSumFIF == 0 .Or. nSumSE1 == 0 .Or. (nSumFIF - nSumSE1) > nAjuLim
					MsgInfo("Soma dos valores do arquivo [" + AllTrim(Transform(nSumFIF,PesqPictQT("FIF_VLBRUT"))) + "] diveregente da soma dos valores dos titulos [" + AllTrim(Transform(nSumSE1,PesqPictQT("E1_VALOR"))) + "].")
				Else
					
					If IIF(nSumFIF <> nSumSE1,;
					MsgYesNo("Soma dos valores do arquivo [" + AllTrim(Transform(nSumFIF,PesqPictQT("FIF_VLBRUT"))) + "] diveregente da soma dos valores dos titulos [" + AllTrim(Transform(nSumSE1,PesqPictQT("E1_VALOR"))) + "].Deseja Continuar?"),;
					.T.)
					
						//Verifica se a conciliacao � de 1 pra 1 com o mesmo tipo sem a neessidade de realizar a liquidacao
						If (nConSE1 == 1 .And. nConFIF == 1) .And. AllTrim("C"+cTipFIF) == AllTrim(cTipSE1)
							
							For nLinSE1 := 1 to oSubSE1:Length()
								oSubSE1:GoLine(nLinSE1)
								If oSubSE1:GetValue("OK")
									
									DbSelectArea("SE1")
									SE1->(DbSetOrder(1))																								
									oSubFIF:GoLine(aSelFIF[1])
									
									//If !SE1->(DbSeek(Iif(lGestao, oSubSE1:GetValue("E1_FILORIG"), xFilial("SE1"))+oSubSE1:GetValue("E1_PREFIXO")+oSubSE1:GetValue("E1_NUM")+oSubSE1:GetValue("E1_PARCELA")+oSubSE1:GetValue("E1_TIPO")))
									If !SE1->(DbSeek(oSubSE1:GetValue("E1_FILORIG")+oSubSE1:GetValue("E1_PREFIXO")+oSubSE1:GetValue("E1_NUM")+oSubSE1:GetValue("E1_PARCELA")+oSubSE1:GetValue("E1_TIPO")))
						
										lRetorno := .F.
										MsgInfo("Arquivo nao encontrado no Financeiro")		
										Exit
									Else
								
										oSubFIF:GoLine(aSelFIF[1])

										//#TB20200219 Thiago Berna - Ajuste pra realizar acrescimo ou decrescimo
										If (nSumFIF <> nSumSE1) 
											If (nSumFIF - nSumSE1) > 0
												
												//Realizar acrescimo
												aTitAju :={ 	{ "E1_PREFIXO"  , SE1->E1_PREFIXO					, NIL },;
																{ "E1_NUM"      , SE1->E1_NUM		         	  	, NIL },;
																{ "E1_PARCELA"  , SE1->E1_PARCELA					, NIL },;
																{ "E1_TIPO"     , SE1->E1_TIPO 						, NIL },;
																{ "E1_CLIENTE"  , SE1->E1_CLIENTE				   	, NIL },;
																{ "E1_LOJA"     , SE1->E1_LOJA          			, NIL },;
																{ "E1_ACRESC"   , nSumFIF - nSumSE1        			, NIL }}
											
												lMsErroAuto := .F.
												
												SetFunName("FINA040")

												//Posiciona na SA1 e reserva
												//SA1->(DbSetOrder(1))
												//SA1->(DbSeek(xFilial('SA1') + SE1->E1_CLIENTE + SE1->E1_LOJA))
												//While !SA1->(DBRLock(Recno()))
												//EndDo
												
												MsExecAuto({|x,y| FINA040(x,y)},aTitAju,4)
												
												SetFunName("OIFINA910")
												
												If lMsErroAuto
													MostraErro()
													DisarmTransaction()								
												EndIf

											ElseIf (nSumSE1 - nSumFIF) > 0 .And. ((nSumSE1 - nSumFIF) <= nAjuLim)
												
												//Realiza derecimo
												aTitAju :={ 	{ "E1_PREFIXO"  , SE1->E1_PREFIXO					, NIL },;
																{ "E1_NUM"      , SE1->E1_NUM		         	  	, NIL },;
																{ "E1_PARCELA"  , SE1->E1_PARCELA					, NIL },;
																{ "E1_TIPO"     , SE1->E1_TIPO 						, NIL },;
																{ "E1_CLIENTE"  , SE1->E1_CLIENTE				   	, NIL },;
																{ "E1_LOJA"     , SE1->E1_LOJA          			, NIL },;
																{ "E1_DECRESC"  , nSumSE1 - nSumFIF        			, NIL }}
											
												lMsErroAuto := .F.
												
												SetFunName("FINA040")

												//Posiciona na SA1 e reserva
												//SA1->(DbSetOrder(1))
												//SA1->(DbSeek(xFilial('SA1') + SE1->E1_CLIENTE + SE1->E1_LOJA))
												//While !SA1->(DBRLock(Recno()))
												//EndDo
												
												MsExecAuto({|x,y| FINA040(x,y)},aTitAju,4)
												
												SetFunName("OIFINA910")
												
												If lMsErroAuto
													MostraErro()
													DisarmTransaction()								
												EndIf

											Else
												
												//realiza liquidacao valor a mais lancado como dinheiro
												oSubSE1:GoLine(aSelSE1[1])	
												oSubFIF:GoLine(aSelFIF[1])	
												
												If MsgYesNo("Liquida��o necessaria. Deseja continuar ?")
													
													aTit460		:= {}
													aIten460	:= {}
													aCab460		:= {}
													n460		:= 0
													cFil460		:= ""
														
													//Adiciona Titulos selecionados
													For nLinSE1 := 1 to Len(aSelSE1)

														oSubSE1:GoLine(aSelSE1[nLinSE1])
														lAjuDin := .T.								

														Aadd(aTit460,	{;
																		oSubSE1:GetValue("E1_FILORIG"),; 	//E1_FILIAL
																		oSubSE1:GetValue("E1_PREFIXO"),; 	//E1_PREFIXO
																		oSubSE1:GetValue("E1_NUM"),; 		//E1_NUM
																		oSubSE1:GetValue("E1_PARCELA"),; 	//E1_PARCELA
																		oSubSE1:GetValue("E1_TIPO"),; 		//E1_TIPO
																		oSubSE1:GetValue("E1_CLIENTE"),; 	//E1_CLIENTE
																		oSubSE1:GetValue("E1_LOJA"); 		//E1_LOJA
																		})
													Next nLinSE1
													
													cQuery := "SELECT MAX(SE1.E1_PARCELA) AS E1_PARCELA "
													cQuery += "FROM " + RetSqlTab("SE1")
													cQuery += "WHERE SE1.E1_FILIAL = '" + oSubSE1:GetValue("E1_FILORIG") + "' "
													cQuery += "AND SE1.E1_PREFIXO = '" + oSubSE1:GetValue("E1_PREFIXO") + "' "
													cQuery += "AND SE1.E1_NUM = '" + oSubSE1:GetValue("E1_NUM") + "' "
													cQuery += "AND SE1.E1_TIPO = '" + AllTrim("C"+cTipFIF) + "' "
													cQuery += "AND SE1.D_E_L_E_T_ <> '*' "

													If Select(cAliasSE1) > 0
														(cAliasSE1)->(DbCloseArea())
													EndIf
													
													DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasSE1, .T., .T.)

													If !(cAliasSE1)->(Eof())
														cParc460 := Soma1((cAliasSE1)->(E1_PARCELA))
													Else
														cParc460 := '001'
													EndIf
													
													//Adiciona Registros do arquivo selecionados
													For nLinFIf := 1 to Len(aSelFIF)

														If nLinFIF == 1
															dVencto := oSubFIF:GetValue("FIF_DTCRED")
														EndIf
														
														oSubFIF:GoLine(aSelFIF[nLinFIF])
														oSubSE1:GoLine(aSelSE1[1])

														aAdd( aIten460, {})
														aAdd( atail(aIten460), { "E1_PREFIXO" 	, oSubSE1:GetValue("E1_PREFIXO")    }) //Prefixo
														aAdd( atail(aIten460), { "E1_NUM"		, oSubSE1:GetValue("E1_NUM")      	}) //Nro. do titulo
														aAdd( atail(aIten460), { "E1_PARCELA"	, cParc460     						}) //Parcela
														aAdd( atail(aIten460), { "E1_TIPO"		, AllTrim("C"+cTipFIF)      		}) //Tipo do titulo
														aAdd( atail(aIten460), { "E1_VENCTO"	, dVencto					    	}) //Data vencimento
														aAdd( atail(aIten460), { "E1_VLCRUZ"	, oSubFIF:GetValue("FIF_VLBRUT")	}) //Valor do titulo
														aAdd( atail(aIten460), { "E1_ACRESC"	, 0	           						}) //Acrescimo
														aAdd( atail(aIten460), { "E1_DECRESC"	, 0	           						}) //Decrescimo				

														cParc460 := Soma1(cParc460)
													
													Next nLinFIF

													//Inclui uma parcela em dinheiro com a diferen�a do valor calculado
													If lAjuDin

														aAdd( aIten460, {})
														aAdd( atail(aIten460), { "E1_PREFIXO" 	, oSubSE1:GetValue("E1_PREFIXO")    }) //Prefixo
														aAdd( atail(aIten460), { "E1_NUM"		, oSubSE1:GetValue("E1_NUM")      	}) //Nro. do titulo
														aAdd( atail(aIten460), { "E1_PARCELA"	, cParc460     						}) //Parcela
														aAdd( atail(aIten460), { "E1_TIPO"		, 'R$'					      		}) //Tipo do titulo
														aAdd( atail(aIten460), { "E1_VENCTO"	, dVencto					    	}) //Data vencimento
														aAdd( atail(aIten460), { "E1_VLCRUZ"	, nSumSE1 - nSumFIF					}) //Valor do titulo
														aAdd( atail(aIten460), { "E1_ACRESC"	, 0	           						}) //Acrescimo
														aAdd( atail(aIten460), { "E1_DECRESC"	, 0	           						}) //Decrescimo				

														cParc460 := Soma1(cParc460)

													EndIf

													//#TB20200813.ini Thiago Berna - Ajuste para otimizar a utilizacao do Filtro
													
													/*cFil460 := " ("
														
													For n460 := 1 To Len(aTit460)
														If n460 > 1
															cFil460 += " .Or. "
														EndIf
																																					
														cFil460 += " ("											

														cFil460 += " E1_FILIAL == '" + aTit460[n460][1] + "' .And. "
														cFil460 += " E1_PREFIXO == '" + aTit460[n460][2] + "' .And. E1_NUM == '" + aTit460[n460][3] + "' .And. "
														cFil460 += " E1_PARCELA == '" + aTit460[n460][4] + "' .And. E1_TIPO == '" + aTit460[n460][5] + "' .And. "
														cFil460 += " E1_CLIENTE == '" + aTit460[n460][6] + "' .And. E1_LOJA == '" + aTit460[n460][7] + "' )" 

													Next
													//cFil460 += ") .And. E1_SITUACA $ '0FG' .And. E1_SALDO > 0 .And. Empty(E1_NUMLIQ) "
													cFil460 += ") .And. E1_SITUACA $ '0FG' .And. E1_SALDO > 0 "*/

													cIdSel 	:= FWUUIDV4()
													aAreaSE1:= SE1->(GetArea())

													For n460 := 1 To Len(aTit460)
														SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
														If SE1->(DbSeek(aTit460[n460][1] + aTit460[n460][6] + aTit460[n460][7] + aTit460[n460][2] + aTit460[n460][3] + aTit460[n460][4] + aTit460[n460][5]))
															//Grava ID nos registros selecionados
															SE1->(RecLock('SE1',.F.))
															SE1->E1_XIDSEL := cIdSel
															SE1->(MsUnlock())
														EndIf
													Next n460

													cFil460 := " E1_XIDSEL == '" + cIdSel + "' "
													
													RestArea(aAreaSE1)													
													//#TB20200813.fim Thiago Berna - Ajuste para otimizar a utilizacao do Filtro
													
													DbSelectArea("FIF")
													DbSetOrder(5)	//FIF_FILIAL, FIF_DTTEF, FIF_NSUTEF, FIF_PARCEL, FIF_CODLOJ, FIF_DTCRED, FIF_SEQFIF
														
													If FIF->(DbSeek(oSubFIF:GetValue("FIF_FILIAL") + DtoS(oSubFIF:GetValue("FIF_DTTEF")) + oSubFIF:GetValue("FIF_NSUTEF") + oSubFIF:GetValue("FIF_PARCEL") + oSubFIF:GetValue("FIF_CODLOJ") + DtoS(oSubFIF:GetValue("FIF_DTCRED")) + oSubFIF:GetValue("FIF_SEQFIF")))
														
														DbSelectArea("SAE")
														SAE->(DbSetOrder(1))
														If SAE->(DbSeek(xFilial("SAE")+FIF->FIF_XADMFI))
															DbSelectArea("SE4")
															SE4->(DbSetOrder(1))
															If SE4->(DbSeek(xFilial('SE4')+SAE->AE_XCOD))
																cNatureza :=  SE4->E4_XNATVDA
															Else
																cNatureza :=  oSubSE1:GetValue("E1_NATUREZ")
															EndIf
														Else	
															cNatureza :=  oSubSE1:GetValue("E1_NATUREZ")
														EndIf

														aAdd( aCab460,{ "cNatureza", cNatureza })
														aAdd( aCab460,{ "E1_TIPO"  , AllTrim("C"+cTipFIF)     		})
														aAdd( aCab460,{ "cCliente" , oSubSE1:GetValue("E1_CLIENTE")})
														aAdd( aCab460,{ "cLoja"    , oSubSE1:GetValue("E1_LOJA")    })
														aAdd( aCab460,{ "nMoeda"   , 1								})

														//Ajuste da database para permitir a liquidacao
														oSubSE1:GoLine(aSelSE1[1])
														
														//#TB20200528 Thiago Berna - Ajuste para considerar a data de emissao como FIF_DTTE
														//dDataBase := dVencto
														dDataBase := oSubFIF:GetValue("FIF_DTTEF")
															
														//Posiciona na SA1 e reserva
														//SA1->(DbSetOrder(1))
														//SA1->(DbSeek(xFilial('SA1') + oSubSE1:GetValue("E1_CLIENTE") + oSubSE1:GetValue("E1_LOJA")))
														//While !SA1->(DBRLock(Recno()))
														//EndDo
														
														//Fina460(,aCab460 , aIten460 , 3, cFil460)
														MSExecAuto({|a,b,c,d,e|FINA460(a,b,c,d,e)},, aCab460, aIten460, 3, cFil460)

														//#TB20200813.ini Thiago Berna - Ajuste para otimizar a utilizacao do Filtro
														aAreaSE1:= SE1->(GetArea())

														For n460 := 1 To Len(aTit460)
															SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
															If SE1->(DbSeek(aTit460[n460][1] + aTit460[n460][6] + aTit460[n460][7] + aTit460[n460][2] + aTit460[n460][3] + aTit460[n460][4] + aTit460[n460][5]))
																//Limpa ID nos registros selecionados
																SE1->(RecLock('SE1',.F.))
																SE1->E1_XIDSEL := ''
																SE1->(MsUnlock())
															EndIf
														Next n460

														RestArea(aAreaSE1)
														//#TB20200813.fim Thiago Berna - Ajuste para otimizar a utilizacao do Filtro
														
														
														//Restauracao da database
														dDataBase := dDataOri

														If lMsErroAuto
															MostraErro()
															DisarmTransaction()
														EndIf

														oSubFIF:GoLine(aSelFIF[1])
														oSubSE1:GoLine(aSelSE1[1])
															
														DbSelectArea("SE1")
														SE1->(DbSetOrder(1))
														
														For nLinFIF := 1 to Len(aSelFIF)

															If SE1->(DbSeek(oSubSE1:GetValue("E1_FILORIG")+oSubSE1:GetValue("E1_PREFIXO")+oSubSE1:GetValue("E1_NUM")+aIten460[nLinFIF,3,2]+AllTrim("C"+cTipFIF)))
																	
																oSubFIF:GoLine(aSelFIF[nLinFIF])
																
																//#TB20200211 Thiago Berna - Ajuste para atualizar os dados no registro conciliado manualmente
																SE1->(RecLock("SE1",.F.))
																SE1->E1_NSUTEF 	:= oSubFIF:GetValue("FIF_NSUTEF")
																SE1->E1_CARTAUT	:= oSubFIF:GetValue("FIF_CODAUT")
																SE1->E1_XNSUORI := 'MAN'
																SE1->E1_XADMIN	:= FIF->FIF_XADMFI
																SE1->E1_XDTCAIX	:= FIF->FIF_DTTEF
																SE1->(MsUnLock())

															Else

																lRetorno := .F.
																MsgInfo("Arquivo nao encontrado no Financeiro")
																DisarmTransaction()
																Exit

															EndIf

														Next nLinFIF

													Else

														lRetorno := .F.
														MsgInfo("Refistro nao encontrado no Arquivo")
														DisarmTransaction()
														Exit

													EndIf
													
												Else
													lRetorno := .F.
												EndIf

											EndIf

										EndIf
										
										//#TB20200211 Thiago Berna - Ajuste para atualizar os dados no registro conciliado manualmente
										SE1->(RecLock("SE1",.F.))
										SE1->E1_NSUTEF := cFIFNsu
										SE1->E1_CARTAUT:= cFIFAut
										SE1->E1_XNSUORI  := 'MAN'
										SE1->(MsUnLock())

									EndIf
								EndIf
							Next nLinSE1
							
							If lRetorno
								For nLinFIF := 1 to oSubFIF:Length()
									oSubFIF:GoLine(nLinFIF)
									If oSubFIF:GetValue("OK")
									
										DbSelectArea("FIF")
										DbSetOrder(5)	//FIF_FILIAL, FIF_DTTEF, FIF_NSUTEF, FIF_PARCEL, FIF_CODLOJ, FIF_DTCRED, FIF_SEQFIF
											
										If FIF->(DbSeek(oSubFIF:GetValue("FIF_FILIAL") + DtoS(oSubFIF:GetValue("FIF_DTTEF")) + oSubFIF:GetValue("FIF_NSUTEF") + oSubFIF:GetValue("FIF_PARCEL") + oSubFIF:GetValue("FIF_CODLOJ") + DtoS(oSubFIF:GetValue("FIF_DTCRED")) + oSubFIF:GetValue("FIF_SEQFIF")))
											oSubSE1:GoLine(aSelSE1[1])	
											oModNew := FWLoadModel("FINA916A")
											oModNew:SetOperation(MODEL_OPERATION_UPDATE)	//Alteração
											oModNew:Activate()
											oModNew:GetModel("HEADER"):SetValue("FIF_STATUS", IIf( FIF->FIF_STATUS == '6', '7', '4') )
											oModNew:GetModel("HEADER"):SetValue("FIF_PREFIX", oSubSE1:GetValue("E1_PREFIXO"))
											oModNew:GetModel("HEADER"):SetValue("FIF_NUM"	, oSubSE1:GetValue("E1_NUM")	)
											oModNew:GetModel("HEADER"):SetValue("FIF_PARC"	, oSubSE1:GetValue("E1_PARCELA"))
											oModNew:GetModel("HEADER"):SetValue("FIF_PGJUST", oSubFIF:GetValue("FIF_PGJUST"))
											oModNew:GetModel("HEADER"):SetValue("FIF_PGDES1", oSubFIF:GetValue("FIF_PGDES1"))
											oModNew:GetModel("HEADER"):SetValue("FIF_PGDES2", oSubFIF:GetValue("FIF_PGDES2"))
											oModNew:GetModel("HEADER"):SetValue("FIF_USUPAG", RetCodUsr())
											oModNew:GetModel("HEADER"):SetValue("FIF_DTPAG"	, dDatabase)
												
											If oModNew:VldData()
												oModNew:CommitData()
												nCount++
											Else
												lRetorno := .F.
												cLog := cValToChar(oModNew:GetErrorMessage()[4]) + ' - '
												cLog += cValToChar(oModNew:GetErrorMessage()[5]) + ' - '
												cLog += cValToChar(oModNew:GetErrorMessage()[6])        	
							
												Help(NIL, NIL, "U_OIF910Gv", NIL, cLog, 1, 0)
												DisarmTransaction()
												Exit
											EndIf
											oModNew:DeActivate()
											oModNew:Destroy()
											oModNew:=NIL
										EndIf
									
										Exit

									EndIf
								Next nLinFIF
							EndIf

						Else
							
							//Liquida��o de n registros da FIF com 1 da SE1
							//ElseIf nConSE1 == 1 .And. nConFIF > 1
							//If nConSE1 <= 1 .Or. nConFIF <= 1
								
								oSubSE1:GoLine(aSelSE1[1])	
								oSubFIF:GoLine(aSelFIF[1])	
								
								If MsgYesNo("Liquida��o necessaria. Deseja continuar ?")
									
									aTit460		:= {}
									aIten460	:= {}
									aCab460		:= {}
									n460		:= 0
									cFil460		:= ""
										
									//Adiciona Titulos selecionados
									For nLinSE1 := 1 to Len(aSelSE1)

										oSubSE1:GoLine(aSelSE1[nLinSE1])

										//#TB20200219 Thiago Berna - Ajuste pra realizar acrescimo ou decrescimo
										If (nSumFIF <> nSumSE1) .And. nLinSE1 == 1
											If (nSumFIF - nSumSE1) > 0
												//Realizar acrescimo
												aTitAju :={ 	{ "E1_PREFIXO"  , oSubSE1:GetValue("E1_PREFIXO")	, NIL },;
																{ "E1_NUM"      , oSubSE1:GetValue("E1_NUM")   	  	, NIL },;
																{ "E1_PARCELA"  , oSubSE1:GetValue("E1_PARCELA") 	, NIL },;
																{ "E1_TIPO"     , oSubSE1:GetValue("E1_TIPO")  		, NIL },;
																{ "E1_CLIENTE"  , oSubSE1:GetValue("E1_CLIENTE")   	, NIL },;
																{ "E1_LOJA"     , oSubSE1:GetValue("E1_LOJA")   	, NIL },;
																{ "E1_ACRESC"   , nSumFIF - nSumSE1        			, NIL }}
													
												lMsErroAuto := .F.
														
												SetFunName("FINA040")
												
												//Posiciona na SA1 e reserva
												//SA1->(DbSetOrder(1))
												//SA1->(DbSeek(xFilial('SA1') + oSubSE1:GetValue("E1_CLIENTE") + oSubSE1:GetValue("E1_LOJA")))
												//While !SA1->(DBRLock(Recno()))
												//EndDo
														
												MsExecAuto({|x,y| FINA040(x,y)},aTitAju,4)
														
												SetFunName("OIFINA910")
														
												If lMsErroAuto
													MostraErro()
													DisarmTransaction()								
												EndIf

											ElseIf (nSumSE1 - nSumFIF) > 0 .And. ((nSumSE1 - nSumFIF) <= nAjuLim)
														
												//Realiza derecimo
												aTitAju :={ 	{ "E1_PREFIXO"  , oSubSE1:GetValue("E1_PREFIXO")	, NIL },;
																{ "E1_NUM"      , oSubSE1:GetValue("E1_NUM")   	  	, NIL },;
																{ "E1_PARCELA"  , oSubSE1:GetValue("E1_PARCELA") 	, NIL },;
																{ "E1_TIPO"     , oSubSE1:GetValue("E1_TIPO")  		, NIL },;
																{ "E1_CLIENTE"  , oSubSE1:GetValue("E1_CLIENTE")   	, NIL },;
																{ "E1_LOJA"     , oSubSE1:GetValue("E1_LOJA")   	, NIL },;
																{ "E1_DECRESC"  , nSumSE1 - nSumFIF        			, NIL }}
													
												lMsErroAuto := .F.
														
												SetFunName("FINA040")

												//Posiciona na SA1 e reserva
												//SA1->(DbSetOrder(1))
												//SA1->(DbSeek(xFilial('SA1') + oSubSE1:GetValue("E1_CLIENTE") + oSubSE1:GetValue("E1_LOJA")))
												//While !SA1->(DBRLock(Recno()))
												//EndDo
														
												MsExecAuto({|x,y| FINA040(x,y)},aTitAju,4)
														
												SetFunName("OIFINA910")
														
												If lMsErroAuto
													MostraErro()
													DisarmTransaction()								
												EndIf

											Else
												//realiza liquidacao valor amais lancado como dinheiro
												lAjuDin := .T.
											EndIf
										EndIf

										Aadd(aTit460,	{;
														oSubSE1:GetValue("E1_FILORIG"),; 	//E1_FILIAL
														oSubSE1:GetValue("E1_PREFIXO"),; 	//E1_PREFIXO
														oSubSE1:GetValue("E1_NUM"),; 		//E1_NUM
														oSubSE1:GetValue("E1_PARCELA"),; 	//E1_PARCELA
														oSubSE1:GetValue("E1_TIPO"),; 		//E1_TIPO
														oSubSE1:GetValue("E1_CLIENTE"),; 	//E1_CLIENTE
														oSubSE1:GetValue("E1_LOJA"); 		//E1_LOJA
														})
									Next nLinSE1
									
									//Posiciona no primeiro registro
									oSubSE1:GoLine(aSelSE1[1])
									
									cQuery := "SELECT MAX(SE1.E1_PARCELA) AS E1_PARCELA "
									cQuery += "FROM " + RetSqlTab("SE1")
									cQuery += "WHERE SE1.E1_FILIAL = '" + oSubSE1:GetValue("E1_FILORIG") + "' "
									cQuery += "AND SE1.E1_PREFIXO = '" + oSubSE1:GetValue("E1_PREFIXO") + "' "
									cQuery += "AND SE1.E1_NUM = '" + oSubSE1:GetValue("E1_NUM") + "' "
									
									//#TB20200220 Thiago Berna - Ajuste para considerar corretamente a parcela maior independete do tipo
									//cQuery += "AND SE1.E1_TIPO = '" + AllTrim("C"+cTipFIF) + "' "
									
									cQuery += "AND SE1.D_E_L_E_T_ <> '*' "

									If Select(cAliasSE1) > 0
										(cAliasSE1)->(DbCloseArea())
									EndIf
									
									DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasSE1, .T., .T.)

									If !(cAliasSE1)->(Eof())
										cParc460 := Soma1((cAliasSE1)->(E1_PARCELA))
									Else
										cParc460 := '001'
									EndIf
									
									//Adiciona Registros do arquivo selecionados
									For nLinFIf := 1 to Len(aSelFIF)
										
										cTipFIF	:= oSubFIF:GetValue("FIF_TPPROD") 
										
										If nLinFIF == 1
											dVencto := oSubFIF:GetValue("FIF_DTCRED")
										EndIf
										
										oSubFIF:GoLine(aSelFIF[nLinFIF])
										oSubSE1:GoLine(aSelSE1[1])								

										aAdd( aIten460, {})
										aAdd( atail(aIten460), { "E1_PREFIXO" 	, oSubSE1:GetValue("E1_PREFIXO")    }) //Prefixo
										aAdd( atail(aIten460), { "E1_NUM"		, oSubSE1:GetValue("E1_NUM")      	}) //Nro. do titulo
										aAdd( atail(aIten460), { "E1_PARCELA"	, cParc460     						}) //Parcela
										aAdd( atail(aIten460), { "E1_TIPO"		, AllTrim("C"+cTipFIF)      		}) //Tipo do titulo
										aAdd( atail(aIten460), { "E1_VENCTO"	, dVencto						  	}) //Data vencimento
										aAdd( atail(aIten460), { "E1_VLCRUZ"	, oSubFIF:GetValue("FIF_VLBRUT")	}) //Valor do titulo
										aAdd( atail(aIten460), { "E1_ACRESC"	, 0	           						}) //Acrescimo
										aAdd( atail(aIten460), { "E1_DECRESC"	, 0	           						}) //Decrescimo				

										cParc460 := Soma1(cParc460)
									
									Next nLinFIF

									//Inclui uma parcela em dinheiro com a diferen�a do valor calculado
									If lAjuDin

										aAdd( aIten460, {})
										aAdd( atail(aIten460), { "E1_PREFIXO" 	, oSubSE1:GetValue("E1_PREFIXO")    }) //Prefixo
										aAdd( atail(aIten460), { "E1_NUM"		, oSubSE1:GetValue("E1_NUM")      	}) //Nro. do titulo
										aAdd( atail(aIten460), { "E1_PARCELA"	, cParc460     						}) //Parcela
										aAdd( atail(aIten460), { "E1_TIPO"		, 'R$'					      		}) //Tipo do titulo
										aAdd( atail(aIten460), { "E1_VENCTO"	, dVencto						   	}) //Data vencimento
										aAdd( atail(aIten460), { "E1_VLCRUZ"	, nSumSE1 - nSumFIF					}) //Valor do titulo
										aAdd( atail(aIten460), { "E1_ACRESC"	, 0	           						}) //Acrescimo
										aAdd( atail(aIten460), { "E1_DECRESC"	, 0	           						}) //Decrescimo				

										cParc460 := Soma1(cParc460)

									EndIf

									//#TB20200813.ini Thiago Berna - Ajuste para otimizar a utilizacao do Filtro
									/*cFil460 := " ("
										
									For n460 := 1 To Len(aTit460)
										If n460 > 1
											cFil460 += " .Or. "
										EndIf
										cFil460 += " ("									
										
										cFil460 += " E1_FILIAL == '" + aTit460[n460][1] + "' .And. "
										cFil460 += " E1_PREFIXO == '" + aTit460[n460][2] + "' .And. E1_NUM == '" + aTit460[n460][3] + "' .And. "
										cFil460 += " E1_PARCELA == '" + aTit460[n460][4] + "' .And. E1_TIPO == '" + aTit460[n460][5] + "' .And. "
										cFil460 += " E1_CLIENTE == '" + aTit460[n460][6] + "' .And. E1_LOJA == '" + aTit460[n460][7] + "' )"  

									Next

									cFil460 += ") "*/

									cIdSel 	:= FWUUIDV4()
									aAreaSE1:= SE1->(GetArea())

									For n460 := 1 To Len(aTit460)
										SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
										If SE1->(DbSeek(aTit460[n460][1] + aTit460[n460][6] + aTit460[n460][7] + aTit460[n460][2] + aTit460[n460][3] + aTit460[n460][4] + aTit460[n460][5]))
											//Grava ID nos registros selecionados
											SE1->(RecLock('SE1',.F.))
											SE1->E1_XIDSEL := cIdSel
											SE1->(MsUnlock())
										EndIf
									Next n460

									cFil460 := " E1_XIDSEL == '" + cIdSel + "' "
													
									RestArea(aAreaSE1)

									//#TB20200813.fim Thiago Berna - Ajuste para otimizar a utilizacao do Filtro

									DbSelectArea("FIF")
									DbSetOrder(5)	//FIF_FILIAL, FIF_DTTEF, FIF_NSUTEF, FIF_PARCEL, FIF_CODLOJ, FIF_DTCRED, FIF_SEQFIF
										
									If FIF->(DbSeek(oSubFIF:GetValue("FIF_FILIAL") + DtoS(oSubFIF:GetValue("FIF_DTTEF")) + oSubFIF:GetValue("FIF_NSUTEF") + oSubFIF:GetValue("FIF_PARCEL") + oSubFIF:GetValue("FIF_CODLOJ") + DtoS(oSubFIF:GetValue("FIF_DTCRED")) + oSubFIF:GetValue("FIF_SEQFIF")))
										
										DbSelectArea("SAE")
										SAE->(DbSetOrder(1))
										If SAE->(DbSeek(xFilial("SAE")+FIF->FIF_XADMFI))
											DbSelectArea("SE4")
											SE4->(DbSetOrder(1))
											If SE4->(DbSeek(xFilial('SE4')+SAE->AE_XCOD))
												cNatureza :=  SE4->E4_XNATVDA
											Else
												cNatureza :=  oSubSE1:GetValue("E1_NATUREZ")
											EndIf
										Else	
											cNatureza :=  oSubSE1:GetValue("E1_NATUREZ")
										EndIf

										aAdd( aCab460,{ "cNatureza", cNatureza })
										aAdd( aCab460,{ "E1_TIPO"  , AllTrim("C"+cTipFIF)     		})
										aAdd( aCab460,{ "cCliente" , oSubSE1:GetValue("E1_CLIENTE")})
										aAdd( aCab460,{ "cLoja"    , oSubSE1:GetValue("E1_LOJA")    })
										aAdd( aCab460,{ "nMoeda"   , 1								})

										//Ajuste da database para permitir a liquidacao
										oSubSE1:GoLine(aSelSE1[1])
										
										//#TB20200528 Thiago Berna - Ajuste para considerar a data de emissao como FIF_DTTE
										//dDataBase := dVencto
										dDataBase := oSubFIF:GetValue("FIF_DTTEF")

										//Posiciona na SA1 e reserva
										//SA1->(DbSetOrder(1))
										//SA1->(DbSeek(xFilial('SA1') + oSubSE1:GetValue("E1_CLIENTE") + oSubSE1:GetValue("E1_LOJA")))
										//While !SA1->(DBRLock(Recno()))
										//EndDo
											
										//Fina460(,aCab460 , aIten460 , 3, cFil460)
										MSExecAuto({|a,b,c,d,e|FINA460(a,b,c,d,e)},, aCab460, aIten460, 3, cFil460)										

										//#TB20200813.ini Thiago Berna - Ajuste para otimizar a utilizacao do Filtro
										aAreaSE1:= SE1->(GetArea())

										For n460 := 1 To Len(aTit460)
											SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
											If SE1->(DbSeek(aTit460[n460][1] + aTit460[n460][6] + aTit460[n460][7] + aTit460[n460][2] + aTit460[n460][3] + aTit460[n460][4] + aTit460[n460][5]))
												//Limpa ID nos registros selecionados
												SE1->(RecLock('SE1',.F.))
												SE1->E1_XIDSEL := ''
												SE1->(MsUnlock())
											EndIf
										Next n460

										RestArea(aAreaSE1)
										//#TB20200813.fim Thiago Berna - Ajuste para otimizar a utilizacao do Filtro
										
										//Restauracao da database
										dDataBase := dDataOri

										If lMsErroAuto
											MostraErro()
											DisarmTransaction()
										EndIf

										oSubFIF:GoLine(aSelFIF[1])
										oSubSE1:GoLine(aSelSE1[1])
											
										DbSelectArea("SE1")
										SE1->(DbSetOrder(1))
										
										For nLinFIF := 1 to Len(aSelFIF)

											If SE1->(DbSeek(oSubSE1:GetValue("E1_FILORIG")+oSubSE1:GetValue("E1_PREFIXO")+oSubSE1:GetValue("E1_NUM")+aIten460[nLinFIF,3,2]+AllTrim("C"+cTipFIF)))
													
												oSubFIF:GoLine(aSelFIF[nLinFIF])

												//#TB20200211 Thiago Berna - Ajuste para atualizar os dados no registro conciliado manualmente
												SE1->(RecLock("SE1",.F.))
												SE1->E1_NSUTEF 	:= oSubFIF:GetValue("FIF_NSUTEF")
												SE1->E1_CARTAUT	:= oSubFIF:GetValue("FIF_CODAUT")
												SE1->E1_XNSUORI := 'MAN'
												SE1->E1_XADMIN	:= FIF->FIF_XADMFI
												SE1->E1_XDTCAIX	:= FIF->FIF_DTTEF
												SE1->(MsUnLock())

											Else

												lRetorno := .F.
												MsgInfo("Arquivo nao encontrado no Financeiro")
												DisarmTransaction()
												Exit

											EndIf

										Next nLinFIF

									Else

										lRetorno := .F.
										MsgInfo("Registro nao encontrado no Arquivo")
										DisarmTransaction()									

									EndIf
									
								Else
									lRetorno := .F.
								EndIf
									
								If lRetorno
								
									DbSelectArea("FIF")
									DbSetOrder(5)	//FIF_FILIAL, FIF_DTTEF, FIF_NSUTEF, FIF_PARCEL, FIF_CODLOJ, FIF_DTCRED, FIF_SEQFIF
												
									For nLinFIF := 1 to Len(aSelFIF)

										oSubFIF:GoLine(aSelFIF[nLinFIF])
										oSubSE1:GoLine(aSelSE1[1])

										If FIF->(DbSeek(oSubFIF:GetValue("FIF_FILIAL") + DtoS(oSubFIF:GetValue("FIF_DTTEF")) + oSubFIF:GetValue("FIF_NSUTEF") + oSubFIF:GetValue("FIF_PARCEL") + oSubFIF:GetValue("FIF_CODLOJ") + DtoS(oSubFIF:GetValue("FIF_DTCRED")) + oSubFIF:GetValue("FIF_SEQFIF")))
														
											oModNew := FWLoadModel("FINA916A")
											oModNew:SetOperation(MODEL_OPERATION_UPDATE)	//Alteração
											oModNew:Activate()
											oModNew:GetModel("HEADER"):SetValue("FIF_STATUS", IIf( FIF->FIF_STATUS == '6', '7', '4') )
											oModNew:GetModel("HEADER"):SetValue("FIF_PREFIX", oSubSE1:GetValue("E1_PREFIXO"))
											oModNew:GetModel("HEADER"):SetValue("FIF_NUM"	, oSubSE1:GetValue("E1_NUM")	)
											oModNew:GetModel("HEADER"):SetValue("FIF_PARC"	, aIten460[nLinFIF,3,2])
											oModNew:GetModel("HEADER"):SetValue("FIF_PGJUST", oSubFIF:GetValue("FIF_PGJUST"))
											oModNew:GetModel("HEADER"):SetValue("FIF_PGDES1", oSubFIF:GetValue("FIF_PGDES1"))
											oModNew:GetModel("HEADER"):SetValue("FIF_PGDES2", oSubFIF:GetValue("FIF_PGDES2"))
											oModNew:GetModel("HEADER"):SetValue("FIF_USUPAG", RetCodUsr())
											oModNew:GetModel("HEADER"):SetValue("FIF_DTPAG"	, dDatabase)
														
											If oModNew:VldData()
												oModNew:CommitData()
												nCount++
											Else
												lRetorno := .F.
												cLog := cValToChar(oModNew:GetErrorMessage()[4]) + ' - '
												cLog += cValToChar(oModNew:GetErrorMessage()[5]) + ' - '
												cLog += cValToChar(oModNew:GetErrorMessage()[6])        	
									
												Help(NIL, NIL, "U_OIF910Gv", NIL, cLog, 1, 0)
												DisarmTransaction()
												
											EndIf
											oModNew:DeActivate()
											oModNew:Destroy()
											oModNew:=NIL
										EndIf

									Next nLinFIF

								EndIf
							//ElseIf nConSE1 > 1 .And. nConFIF == 1
							//	MsgInfo("Liquidar os titulos criando um novo com o mesmo tipo da tabela FIF")
							/*ElseIf nConSE1 > 1 .And. nConFIF > 1
								MsgInfo("Verifique os registros selecionados. Existe mais de 1 registro selecionado referente aos t�tulos junto com mais de 1 registro selecionado referente ao arquivo.")
								lRetorno := .F.
								DisarmTransaction()
							EndIf*/
						EndIf

					EndIf

				EndIf
				
				
			//End Transaction
		Case nSheet == 5	//Divergentes

			//Begin Transaction
				
				oSubFIF := oModel:GetModel("FIFFLD5")
				oSubSE1 := oModel:GetModel("SE1FLD5")
				
				nSumFIF := 0
				nSumSE1	:= 0
				
				For nLinFIF := 1 to oSubFIF:Length()
					oSubFIF:GoLine(nLinFIF)
					If oSubFIF:GetValue("OK")
						nSumFIF += oSubFIF:GetValue("FIF_VLBRUT")
						nConFIF++
						AAdd(aSelFIF,nLinFIF)
						If Empty(cFIFNsu)
							cFIFNsu := oSubFIF:GetValue("FIF_NSUTEF")
							cFIFAut	:= oSubFIF:GetValue("FIF_CODAUT")
							cTipFIF	:= oSubFIF:GetValue("FIF_TPPROD") 
						EndIf
					
						If Empty(oSubFIF:GetValue("FIF_PGJUST"))
							lRetorno := .F.
							Exit
						EndIf
					EndIf
				Next nLinFIF

				For nLinSE1 := 1 to oSubSE1:Length()
					
					oSubSE1:GoLine(nLinSE1)
					nSumSE1 += oSubSE1:GetValue("E1_VALOR")
					nConSE1++
					AAdd(aSelSE1,nLinSE1)
					If Empty(cTipSE1)
						cTipSE1	:= oSubSE1:GetValue("E1_TIPO")
					EndIf
					
				Next nLinSE1

				If !lRetorno
					Help(NIL, NIL, "U_OIF910Gv", NIL, "Informe o C�digo da Justificativa (Campo: Cd.Just.Pagt.) para a Concilia��o.", 1, 0)		//"Informe a Justificativa para a Conciliação."
				
				//ElseIf nSumFIF <> nSumSE1 .Or. nSumFIF == 0 .Or. nSumSE1 == 0
				ElseIf nSumFIF == 0 .Or. nSumSE1 == 0 .Or. (nSumFIF - nSumSE1) > nAjuLim
					MsgInfo("Soma dos valores do arquivo [" + AllTrim(Transform(nSumFIF,PesqPictQT("FIF_VLBRUT"))) + "] diveregente da soma dos valores dos titulos [" + AllTrim(Transform(nSumSE1,PesqPictQT("E1_VALOR"))) + "].")
				Else

					If IIF(nSumFIF <> nSumSE1,;
					MsgYesNo("Soma dos valores do arquivo [" + AllTrim(Transform(nSumFIF,PesqPictQT("FIF_VLBRUT"))) + "] diveregente da soma dos valores dos titulos [" + AllTrim(Transform(nSumSE1,PesqPictQT("E1_VALOR"))) + "].Deseja Continuar?"),;
					.T.)
					
						//Liquida��o
						oSubSE1:GoLine(aSelSE1[1])	
						oSubFIF:GoLine(aSelFIF[1])	
								
						If MsgYesNo("Liquida��o necessaria. Deseja continuar ?")
									
							aTit460		:= {}
							aIten460	:= {}
							aCab460		:= {}
							n460		:= 0
							cFil460		:= ""
										
							//Adiciona Titulos selecionados
							For nLinSE1 := 1 to Len(aSelSE1)

								oSubSE1:GoLine(aSelSE1[nLinSE1])

								Aadd(aTit460,	{;
												oSubSE1:GetValue("E1_FILORIG"),; 	//E1_FILIAL
												oSubSE1:GetValue("E1_PREFIXO"),; 	//E1_PREFIXO
												oSubSE1:GetValue("E1_NUM"),; 		//E1_NUM
												oSubSE1:GetValue("E1_PARCELA"),; 	//E1_PARCELA
												oSubSE1:GetValue("E1_TIPO"),; 		//E1_TIPO
												oSubSE1:GetValue("E1_CLIENTE"),; 	//E1_CLIENTE
												oSubSE1:GetValue("E1_LOJA"); 		//E1_LOJA
												})
							Next nLinSE1
									
							cQuery := "SELECT MAX(SE1.E1_PARCELA) AS E1_PARCELA "
							cQuery += "FROM " + RetSqlTab("SE1")
							cQuery += "WHERE SE1.E1_FILIAL = '" + oSubSE1:GetValue("E1_FILORIG") + "' "
							cQuery += "AND SE1.E1_PREFIXO = '" + oSubSE1:GetValue("E1_PREFIXO") + "' "
							cQuery += "AND SE1.E1_NUM = '" + oSubSE1:GetValue("E1_NUM") + "' "
							cQuery += "AND SE1.E1_TIPO = '" + AllTrim("C"+cTipFIF) + "' "
							cQuery += "AND SE1.D_E_L_E_T_ <> '*' "

							If Select(cAliasSE1) > 0
								(cAliasSE1)->(DbCloseArea())
							EndIf
								
							DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasSE1, .T., .T.)

							If !(cAliasSE1)->(Eof())
								cParc460 := Soma1((cAliasSE1)->(E1_PARCELA))
							Else
								cParc460 := '001'
							EndIf
									
							//Adiciona Registros do arquivo selecionados
							For nLinFIf := 1 to Len(aSelFIF)
										
								If nLinFIF == 1
									dVencto := oSubFIF:GetValue("FIF_DTCRED")
								EndIf
								
								oSubFIF:GoLine(aSelFIF[nLinFIF])
								oSubSE1:GoLine(aSelSE1[1])

								aAdd( aIten460, {})
								aAdd( atail(aIten460), { "E1_PREFIXO" 	, oSubSE1:GetValue("E1_PREFIXO")    }) //Prefixo
								aAdd( atail(aIten460), { "E1_NUM"		, oSubSE1:GetValue("E1_NUM")      	}) //Nro. do titulo
								aAdd( atail(aIten460), { "E1_PARCELA"	, cParc460     						}) //Parcela
								aAdd( atail(aIten460), { "E1_TIPO"		, AllTrim("C"+cTipFIF)      		}) //Tipo do titulo
								aAdd( atail(aIten460), { "E1_VENCTO"	, dVencto					    	}) //Data vencimento
								aAdd( atail(aIten460), { "E1_VLCRUZ"	, oSubFIF:GetValue("FIF_VLBRUT")	}) //Valor do titulo
								aAdd( atail(aIten460), { "E1_ACRESC"	, 0	           						}) //Acrescimo
								aAdd( atail(aIten460), { "E1_DECRESC"	, 0	           						}) //Decrescimo				

								cParc460 := Soma1(cParc460)
									
							Next nLinFIF						

							//#TB20200813.ini Thiago Berna - Ajuste para otimizar a utilizacao do Filtro
							/*cFil460 := " ("
								
							For n460 := 1 To Len(aTit460)
								If n460 > 1
									cFil460 += " .Or. "
								EndIf
								cFil460 += " ("

								//cFil460 += ' E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA == "';
								//+ PadR(aTit460[n460][1], TamSx3("E1_FILIAL")[1]) + PadR(aTit460[n460][2], TamSx3("E1_PREFIXO")[1]) + PadR(aTit460[n460][3], TamSx3("E1_NUM")[1]);
								//+ PadR(aTit460[n460][4], TamSx3("E1_PARCELA")[1]) + PadR(aTit460[n460][5], TamSx3("E1_TIPO")[1]) + PadR(aTit460[n460][6], TamSx3("E1_CLIENTE")[1]);
								//+ PadR(aTit460[n460][7], TamSx3("E1_LOJA")[1]) + '" )'  
								
								cFil460 += " E1_FILIAL == '" + aTit460[n460][1] + "' .And. "
								cFil460 += " E1_PREFIXO == '" + aTit460[n460][2] + "' .And. E1_NUM == '" + aTit460[n460][3] + "' .And. "
								cFil460 += " E1_PARCELA == '" + aTit460[n460][4] + "' .And. E1_TIPO == '" + aTit460[n460][5] + "' .And. "
								cFil460 += " E1_CLIENTE == '" + aTit460[n460][6] + "' .And. E1_LOJA == '" + aTit460[n460][7] + "' )" 

							Next
							//cFil460 += ") .And. E1_SITUACA $ '0FG' .And. E1_SALDO > 0 .And. Empty(E1_NUMLIQ) "
							cFil460 += ") .And. E1_SITUACA $ '0FG' .And. E1_SALDO > 0 "*/
							
							cIdSel 	:= FWUUIDV4()
							aAreaSE1:= SE1->(GetArea())

							For n460 := 1 To Len(aTit460)
								SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
								If SE1->(DbSeek(aTit460[n460][1] + aTit460[n460][6] + aTit460[n460][7] + aTit460[n460][2] + aTit460[n460][3] + aTit460[n460][4] + aTit460[n460][5]))
									//Grava ID nos registros selecionados
									SE1->(RecLock('SE1',.F.))
									SE1->E1_XIDSEL := cIdSel
									SE1->(MsUnlock())
								EndIf
							Next n460

							cFil460 := " E1_XIDSEL == '" + cIdSel + "' "
													
							RestArea(aAreaSE1)		
							//#TB20200813.fim Thiago Berna - Ajuste para otimizar a utilizacao do Filtro

							DbSelectArea("FIF")
							DbSetOrder(5)	//FIF_FILIAL, FIF_DTTEF, FIF_NSUTEF, FIF_PARCEL, FIF_CODLOJ, FIF_DTCRED, FIF_SEQFIF
										
							If FIF->(DbSeek(oSubFIF:GetValue("FIF_FILIAL") + DtoS(oSubFIF:GetValue("FIF_DTTEF")) + oSubFIF:GetValue("FIF_NSUTEF") + oSubFIF:GetValue("FIF_PARCEL") + oSubFIF:GetValue("FIF_CODLOJ") + DtoS(oSubFIF:GetValue("FIF_DTCRED")) + oSubFIF:GetValue("FIF_SEQFIF")))
										
								DbSelectArea("SAE")
								SAE->(DbSetOrder(1))
								If SAE->(DbSeek(xFilial("SAE")+FIF->FIF_XADMFI))
									DbSelectArea("SE4")
									SE4->(DbSetOrder(1))
									If SE4->(DbSeek(xFilial('SE4')+SAE->AE_XCOD))
										cNatureza :=  SE4->E4_XNATVDA
									Else
										cNatureza :=  oSubSE1:GetValue("E1_NATUREZ")
									EndIf
								Else
									cNatureza := oSubSE1:GetValue("E1_NATUREZ")
								EndIf
				
								aAdd( aCab460,{ "cNatureza", cNatureza })
								aAdd( aCab460,{ "E1_TIPO"  , AllTrim("C"+cTipFIF)     		})
								aAdd( aCab460,{ "cCliente" , oSubSE1:GetValue("E1_CLIENTE")})
								aAdd( aCab460,{ "cLoja"    , oSubSE1:GetValue("E1_LOJA")    })
								aAdd( aCab460,{ "nMoeda"   , 1								})

								//Ajuste da database para permitir a liquidacao
								oSubSE1:GoLine(aSelSE1[1])
								
								//#TB20200528 Thiago Berna - Ajuste para considerar a data de emissao como FIF_DTTE
								//dDataBase := dVencto
								dDataBase := oSubFIF:GetValue("FIF_DTTEF")

								//Posiciona na SA1 e reserva
								//SA1->(DbSetOrder(1))
								//SA1->(DbSeek(xFilial('SA1') + oSubSE1:GetValue("E1_CLIENTE") + oSubSE1:GetValue("E1_LOJA")))
								//While !SA1->(DBRLock(Recno()))
								//EndDo
											
								//Fina460(,aCab460 , aIten460 , 3, cFil460)
								MSExecAuto({|a,b,c,d,e|FINA460(a,b,c,d,e)},, aCab460, aIten460, 3, cFil460)

								//#TB20200813.ini Thiago Berna - Ajuste para otimizar a utilizacao do Filtro
								aAreaSE1:= SE1->(GetArea())

								For n460 := 1 To Len(aTit460)
									SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
									If SE1->(DbSeek(aTit460[n460][1] + aTit460[n460][6] + aTit460[n460][7] + aTit460[n460][2] + aTit460[n460][3] + aTit460[n460][4] + aTit460[n460][5]))
										//Limpa ID nos registros selecionados
										SE1->(RecLock('SE1',.F.))
										SE1->E1_XIDSEL := ''
										SE1->(MsUnlock())
									EndIf
								Next n460

								RestArea(aAreaSE1)
								//#TB20200813.fim Thiago Berna - Ajuste para otimizar a utilizacao do Filtro

								//Restauracao da database
								dDataBase := dDataOri

								If lMsErroAuto
									MostraErro()
									DisarmTransaction()
								EndIf

								oSubFIF:GoLine(aSelFIF[1])
								oSubSE1:GoLine(aSelSE1[1])
											
								DbSelectArea("SE1")
								SE1->(DbSetOrder(1))
										
								For nLinFIF := 1 to Len(aSelFIF)

									If SE1->(DbSeek(oSubSE1:GetValue("E1_FILORIG")+oSubSE1:GetValue("E1_PREFIXO")+oSubSE1:GetValue("E1_NUM")+aIten460[nLinFIF,3,2]+AllTrim("C"+cTipFIF)))
								
											//#TB20200211 Thiago Berna - Ajuste para atualizar os dados no registro conciliado manualmente
											SE1->(RecLock("SE1",.F.))
											SE1->E1_NSUTEF 	:= FIF->FIF_NSUTEF
											SE1->E1_CARTAUT	:= FIF->FIF_CODAUT
											SE1->E1_XNSUORI := 'MAN'
											SE1->E1_XADMIN	:= FIF->FIF_XADMFI
											SE1->E1_XDTCAIX	:= FIF->FIF_DTTEF
											SE1->(MsUnLock())

									Else

										lRetorno := .F.
										MsgInfo("Arquivo nao encontrado no Financeiro")
										DisarmTransaction()
										Exit

									EndIf

								Next nLinFIF

							Else

								lRetorno := .F.
								MsgInfo("Refistro nao encontrado no Arquivo")
								DisarmTransaction()							

							EndIf
									
						Else
							lRetorno := .F.
						EndIf

					EndIf
								
					If lRetorno
							
						DbSelectArea("FIF")
						DbSetOrder(5)	//FIF_FILIAL, FIF_DTTEF, FIF_NSUTEF, FIF_PARCEL, FIF_CODLOJ, FIF_DTCRED, FIF_SEQFIF
											
						For nLinFIF := 1 to Len(aSelFIF)

							oSubFIF:GoLine(aSelFIF[nLinFIF])
							oSubSE1:GoLine(aSelSE1[1])

							If FIF->(DbSeek(oSubFIF:GetValue("FIF_FILIAL") + DtoS(oSubFIF:GetValue("FIF_DTTEF")) + oSubFIF:GetValue("FIF_NSUTEF") + oSubFIF:GetValue("FIF_PARCEL") + oSubFIF:GetValue("FIF_CODLOJ") + DtoS(oSubFIF:GetValue("FIF_DTCRED")) + oSubFIF:GetValue("FIF_SEQFIF")))
													
								oModNew := FWLoadModel("FINA916A")
								oModNew:SetOperation(MODEL_OPERATION_UPDATE)	//Alteração
								oModNew:Activate()
								oModNew:GetModel("HEADER"):SetValue("FIF_STATUS", IIf( FIF->FIF_STATUS == '6', '7', '4') )
								oModNew:GetModel("HEADER"):SetValue("FIF_PREFIX", oSubSE1:GetValue("E1_PREFIXO"))
								oModNew:GetModel("HEADER"):SetValue("FIF_NUM"	, oSubSE1:GetValue("E1_NUM")	)
								oModNew:GetModel("HEADER"):SetValue("FIF_PARC"	, aIten460[nLinFIF,3,2])
								oModNew:GetModel("HEADER"):SetValue("FIF_PGJUST", oSubFIF:GetValue("FIF_PGJUST"))
								oModNew:GetModel("HEADER"):SetValue("FIF_PGDES1", oSubFIF:GetValue("FIF_PGDES1"))
								oModNew:GetModel("HEADER"):SetValue("FIF_PGDES2", oSubFIF:GetValue("FIF_PGDES2"))
								oModNew:GetModel("HEADER"):SetValue("FIF_USUPAG", RetCodUsr())
								oModNew:GetModel("HEADER"):SetValue("FIF_DTPAG"	, dDatabase)
													
								If oModNew:VldData()
									oModNew:CommitData()
									nCount++
								Else
									lRetorno := .F.
									cLog := cValToChar(oModNew:GetErrorMessage()[4]) + ' - '
									cLog += cValToChar(oModNew:GetErrorMessage()[5]) + ' - '
									cLog += cValToChar(oModNew:GetErrorMessage()[6])        	
								
									Help(NIL, NIL, "U_OIF910Gv", NIL, cLog, 1, 0)
									DisarmTransaction()
											
								EndIf
								oModNew:DeActivate()
								oModNew:Destroy()
								oModNew:=NIL
							EndIf

						Next nLinFIF

					EndIf
						
				EndIf
			//End Transaction
		Case nSheet == 8	//Pagamentos
			
			//Begin Transaction
				oSubFIF := oModel:GetModel("FIFFLD6A")
				oSubSE1 := oModel:GetModel("SE1FLD6A")
				
				dbSelectArea("SE1")
				//SE1->(DbSetOrder(1))
				SE1->(DbOrderNickName("CONC"))

				For nLinFIF := 1 to oSubFIF:Length()
					oSubFIF:GoLine(nLinFIF)

					If oSubFIF:GetValue("OK")
						
						//If !SE1->(DbSeek(Iif(lGestao, oSubSE1:GetValue("E1_FILORIG"), xFilial("SE1"))+oSubSE1:GetValue("E1_PREFIXO")+oSubSE1:GetValue("E1_NUM")+oSubSE1:GetValue("E1_PARCELA")+oSubSE1:GetValue("E1_TIPO")))
						If !SE1->(DbSeek(oSubFIF:GetValue("FIF_FILIAL")+oSubFIF:GetValue("FIF_NSUTEF")+DTOS(oSubFIF:GetValue("FIF_DTTEF"))+AllTrim(Str(oSubFIF:GetValue("FIF_VLBRUT")))))
						
							MsgInfo("Arquivo nao encontrado no Financeiro")
							Exit
									
						Else
								
								aDadoBanco := BuscarBanco(Right(RTrim(oSubFIF:GetValue("FIF_CODBCO")), nTamBanco), Right(RTrim(oSubFIF:GetValue("FIF_CODAGE")), nTamAgencia),Right(RTrim(oSubFIF:GetValue("FIF_NUMCC")), nTamCC),oSubFIF:GetValue("FIF_VLLIQ"))
							
								DbSelectArea("FIF")
								DbSetOrder(5)	//FIF_FILIAL, FIF_DTTEF, FIF_NSUTEF, FIF_PARCEL, FIF_CODLOJ, FIF_DTCRED, FIF_SEQFIF
								
								If FIF->(DbSeek(oSubFIF:GetValue("FIF_FILIAL") + DtoS(oSubFIF:GetValue("FIF_DTTEF")) + oSubFIF:GetValue("FIF_NSUTEF") + oSubFIF:GetValue("FIF_PARCEL") + oSubFIF:GetValue("FIF_CODLOJ") + DtoS(oSubFIF:GetValue("FIF_DTCRED")) + oSubFIF:GetValue("FIF_SEQFIF")))
								
									
								
									cBanco	:= PadR(oSubFIF:GetValue("FIF_CODBCO"),Len(SE8->E8_BANCO))
									cAgencia:= PadR(oSubFIF:GetValue("FIF_CODAGE"),Len(SE8->E8_AGENCIA))
									cConta	:= PadR(SubStr(oSubFIF:GetValue("FIF_NUMCC"),1,Len(Alltrim(oSubFIF:GetValue("FIF_NUMCC")))-1),Len(SE8->E8_CONTA))									
									
									//Verifica se o banco existe
									DbSelectArea("SA6")
									SA6->(DbSetOrder(1))
									If SA6->(DbSeek(xFilial('SA6') + cBanco + cAgencia + cConta))
									
										//Verifica se nao foi baixado
										If Empty(SE1->E1_BAIXA)
										
											//executar a baixa dos titulos
											aTit460	:=	{	{"E1_PREFIXO"		,SE1->E1_PREFIXO			,NiL},;
															{"E1_NUM"			,SE1->E1_NUM				,NiL},;
															{"E1_PARCELA"		,SE1->E1_PARCELA			,NiL},;
															{"E1_TIPO"			,SE1->E1_TIPO				,NiL},;
															{"E1_CLIENTE"		,SE1->E1_CLIENTE			,NiL},;
															{"E1_LOJA"			,SE1->E1_LOJA				,NiL},;
															{"AUTMOTBX"			,"NOR"						,Nil},;									
															{"AUTBANCO"			,cBanco						,Nil},;
															{"AUTAGENCIA"		,cAgencia					,Nil},;
															{"AUTCONTA"			,cConta						,Nil},;
															{"AUTDTBAIXA"		,FIF->FIF_DTCRED			,Nil},;
															{"AUTDTCREDITO"		,FIF->FIF_DTCRED			,Nil},;
															{"AUTHIST"			,"Conciliador SITEF"		,Nil},; //"Conciliador SITEF"
															{"AUTDESCONT"		,0							,Nil},; //Valores de desconto
															{"AUTACRESC"		,0							,Nil},; //Valores de acrescimo - deve estar cadastrado no titulo previamente
															{"AUTDECRESC"		,0							,Nil},; //Valore de decrescimo - deve estar cadastrado no titulo previamente
															{"AUTMULTA"			,0							,Nil},; //Valores de multa
															{"AUTJUROS"			,0							,Nil}} //Valores de Juros
															//{"AUTVALREC"		,SE1->E1_VALOR				,Nil}}  //Valor recebido
												
											lMsErroAuto	:= .F.
						
											//Ajuste da database para permitir a liquidacao
											dDataBase := FIF->FIF_DTCRED

											//Posiciona na SA1 e reserva
											//SA1->(DbSetOrder(1))
											//SA1->(DbSeek(xFilial('SA1') + SE1->E1_CLIENTE + SE1->E1_LOJA))
											//While !SA1->(DBRLock(Recno()))
											//EndDo
											
											MSExecAuto({|x, y| FINA070(x, y)}, aTit460, 3)

											//Restauracao da database
											dDataBase := dDataOri

											If lMsErroAuto
												lRetorno := .F.
												MostraErro()
												DisarmTransaction()
												Exit
											Else
												oModNew := FWLoadModel("FINA916A")
												oModNew:SetOperation(MODEL_OPERATION_UPDATE)	//Alteração
												oModNew:Activate()
												oModNew:GetModel("HEADER"):SetValue("FIF_STATUS", IIf( FIF->FIF_STATUS == '6', '7', '2') )
												oModNew:GetModel("HEADER"):SetValue("FIF_PREFIX", oSubSE1:GetValue("E1_PREFIXO"))
												oModNew:GetModel("HEADER"):SetValue("FIF_NUM"	, oSubSE1:GetValue("E1_NUM")	)
												oModNew:GetModel("HEADER"):SetValue("FIF_PARC"	, oSubSE1:GetValue("E1_PARCELA"))
												oModNew:GetModel("HEADER"):SetValue("FIF_PGJUST", oSubFIF:GetValue("FIF_PGJUST"))
												oModNew:GetModel("HEADER"):SetValue("FIF_PGDES1", oSubFIF:GetValue("FIF_PGDES1"))
												oModNew:GetModel("HEADER"):SetValue("FIF_PGDES2", oSubFIF:GetValue("FIF_PGDES2"))
												oModNew:GetModel("HEADER"):SetValue("FIF_USUPAG", RetCodUsr())
												oModNew:GetModel("HEADER"):SetValue("FIF_DTPAG"	, dDatabase)
												
												If oModNew:VldData()
													oModNew:CommitData()
													nCount++									
												Else
													lRetorno := .F.
													cLog := cValToChar(oModNew:GetErrorMessage()[4]) + ' - '
													cLog += cValToChar(oModNew:GetErrorMessage()[5]) + ' - '
													cLog += cValToChar(oModNew:GetErrorMessage()[6])        	
							
													Help(NIL, NIL, "U_OIF910Gv", NIL, cLog, 1, 0)
													DisarmTransaction()
													Exit
												EndIf
												oModNew:DeActivate()
												oModNew:Destroy()
												oModNew:=NIL
											EndIf

										EndIf

									Else
										MsgInfo("Banco inexistente: ["  + cBanco + " / "+ cAgencia + " / " + cConta + "] ") 
									EndIf
								
								EndIf
							//EndIf
						endif
					EndIf
				Next nLinFIF
			
			//End Transaction
				
		EndCase
		
		//Efetua a baixa por lote
		If cConcilia == 2
			//#TB20200204 Thiago Berna - necessario revisar regra
			//Processa({|| A910EfetuaBX (aLotes, aConc , @lRetorno)},"Aguarde...","Efetuando Baixa de T�tulos Lote...") //"Aguarde..."#"Efetuando Baixa de Títulos Lote..."
			if lRetorno
				
				Processa({|| AtuTabFIF (aConc ,,@lRetorno)},"Aguarde...","Atualizando as informa��es da concilia��o...") //"Aguarde..."#"Efetuando Baixa de Títulos Lote..."
				
			endif
		EndIf

		If lRetorno .AND. nCount > 0
			if nSheet == 5 
				FWMsgRun(, {|| oView:ButtonOkAction(.F.) }, "Processando informa��es...", "Processando informa��es..." + " Aguarde... ")
				a:= 1
			else
				FWMsgRun(, {|| oView:ButtonOkAction(.F.) }, "Carregando os Titulos...", "Carregando os Titulos..." + " Aguarde... ")
				a:=1
			endif	
		ElseIf lRetorno .AND. nCount == 0
			If lMenorSitef
				Help(NIL, NIL, "U_OIF910Gv", NIL, "Valor Sitef menor que o Valor Protheus, necess�rio corrigir no Financeiro", 1, 0)
			Else
				Help(NIL, NIL, "U_OIF910Gv", NIL, "Nenhum registro selecionado para Concilia��o.", 1, 0)		//"Nenhum registro selecionado para Conciliação."
			EndIf
		EndIf

	End Transaction

	//Libera a SA1
	//SA1->(DBRUnlock())

	//Recupera a variavel global para carregar dados do ponto de entrada
	//aDadosPE[nCount,1] : RECNO SA1
	//aDadosPE[nCount,2] : RECNO SE1
	//aDadosPE[nCount,3] : nValClient
	
	If lF460SA1
		
		GetGlbVars(cThreadId,aDadosPE)

		For nCount := 1 to Len(aDadosPE)

			SA1->(DbGoTo(aDadosPE[nCount,1]))
			SE1->(DbGoTo(aDadosPE[nCount,2]))

			AtuSalDup("-",aDadosPE[nCount,3],1,SE1->E1_TIPO,,SE1->E1_EMISSAO)
		
			RecLock("SA1")
				
			IF (SE1->E1_BAIXA-SE1->E1_VENCREA) > SA1->A1_MATR
				Replace A1_MATR With (SE1->E1_BAIXA-SE1->E1_VENCREA)
			EndIf
					
			Replace A1_NROPAG With A1_NROPAG+1  //Numero de Duplicatas

			If (SE1->E1_BAIXA - SE1->E1_VENCREA) > 0
				SA1->A1_PAGATR	:= A1_PAGATR+SE1->E1_VALLIQ   // Pagamentos Atrasados
				SA1->A1_ATR		:= IIF(A1_ATR==0,0,IIF(A1_ATR < SE1->E1_VALLIQ,0,A1_ATR - SE1->E1_VALLIQ))
				SA1->A1_METR	:=	(A1_METR * (A1_NROPAG-1) + (SE1->E1_BAIXA - SE1->E1_VENCREA)) / (A1_NROPAG)
			Endif
					
			SA1->(MsUnlock())	

		Next nCount

		//Elimina a variavel da memoria
		ClearGlbValue(cThreadId)
		aDadosPE := {}

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFilter
Retorna o Filtro do Browse de Conciliacao

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static Function GetFilter( nFolder, cAlias )// As Character

	Local cFiltro	As Character
	Local cFilAdm	As Character
	Local cAuxLay	As Character  
	Local nAuxLay	As Numeric 
	Local nAuxFil	As Numeric 
	Local nY		As Numeric

	Default cAlias	:= "FIF"
	Default nFolder	:= 0

	cFiltro	:= ""
	cFilAdm	:= ""
	cAuxLay	:= __cSM0Lay
	nAuxLay	:= 0 
	nAuxFil	:= 0 
	nY		:= 0

	If cAlias == "FIF"
		//Filtro do Browse
		If nFolder == 0
			cFiltro += " FIF_STATUS  <> ' ' " //"@FIF_STATUS <> ' ' "
		Else
			
			//#TB20200128 Thiago Berna - Ajuste para considerar o campo FIF_DTTEF ao inves do FIF_DTCRED
			//cFiltro += " FIF_DTCRED >= '" + DtoS(dDataCredI) + "' "
			//cFiltro += "AND FIF_DTCRED <= '" + DtoS(dDataCredF) + "' "
			cFiltro += " FIF_DTTEF >= '" + DtoS(dDataCredI) + "' "
			cFiltro += "AND FIF_DTTEF <= '" + DtoS(dDataCredF) + "' "
			if !__lProcDocTEF
				cFiltro += "AND FIF_NSUARQ >= '" + cNsuInicial + "' "
				cFiltro += "AND FIF_NSUARQ <= '" + cNsuFinal + "' "
			elseif __lDocTef
				cFiltro += "AND FIF_DOCTEF >= '" + cNsuInicial + "' "
				cFiltro += "AND FIF_DOCTEF <= '" + cNsuFinal + "' "
			endif

			//#TB20200217 Thiago Berna - Ajuste para exibir somente os registros de detalhe da venda tipo 1
			If nFolder == 8
				cFiltro += " AND FIF_TPREG = '10' "
			Else
				cFiltro += " AND FIF_TPREG = '1' "
			EndIf
			
			If cSelFilial == 1
				If Len( __aSelFil ) <= 0
					cFiltro += "AND FIF_CODFIL = '" + xFilial("FIF", __cFilAnt)  + "' "
				Else
					If !__lTodFil
						cFiltro += "AND FIF_CODFIL " + GetRngFil( __aSelFil, 'FIF', .T.,, 20, .T. ) + " "
					EndIf
				EndIf	
			Else
				cFiltro += "AND FIF_CODFIL = '" + xFilial("FIF", __cFilAnt)  + "' "
			EndIf
		
			if cTipoPagam == 1
				cFiltro += "AND FIF_TPPROD IN ('D','V') "
			elseif cTipoPagam == 2
				cFiltro += "AND FIF_TPPROD = 'C' "
			else
				cFiltro += "AND FIF_TPPROD IN ('D','V','C') "
			endif
			
			//#TB20200206 Thiago Berna - Desconsiderar parametro rede
			/*If !Empty(cAdmFinanIni) 
				//cFilAdm := FormatIn(Alltrim(cAdmFinanIni), ";")
				If __lSOFEX
					cFiltro += "AND FIF_CODRED IN " + cAdmFinanIni + " "
				Else
					cFiltro += "AND FIF_CODADM IN " + cAdmFinanIni + " "		
				EndIf
			EndIf*/		
			
			If __lOracle
				cFiltro += " AND ROWNUM <= " + STR(GRIDMAXLIN) + " "
			EndIf		
		EndIf

	EndIf

	If cAlias == "SE1"
		//#TB20191218 Thiago Berna - Ajuste para substituir E1_VENCREA por E1_XDTCAIX
		//cFiltro += " E1_VENCREA >= '" + DtoS(dDataCredI) + "' "
		//cFiltro += "AND E1_VENCREA <= '" + DtoS(dDataCredF) + "' "
		cFiltro += " E1_XDTCAIX >= '" + DtoS(dDataCredI) + "' "
		cFiltro += "AND E1_XDTCAIX <= '" + DtoS(dDataCredF) + "' "
		
		//#TB20191218 Thiago Berna - Ajuste para trazer registros que nao tenham NSU
		//cFiltro += "AND E1_NSUTEF <> ' ' "


			
		If cSelFilial == 1
			If Len( __aSelFil ) <= 0
				cFiltro += " AND SE1.E1_MSFIL = '" + xFilial("FIF", __cFilAnt)  + "' " 
			Else
				If !__lTodFil
					cFiltro += " AND SE1.E1_MSFIL " + GetRngFil( __aSelFil, 'FIF', .T.,, 20, .T. ) + " "
				EndIf
			EndIf	
		Else
			cFiltro += " AND SE1.E1_MSFIL = '" + xFilial("FIF", __cFilAnt)  + "' "
		EndIf

		If cTipoPagam == 1  
			cFiltro += "AND SE1.E1_TIPO = 'CD' "
		ElseIf cTipoPagam == 2
			cFiltro += "AND SE1.E1_TIPO = 'CC' "
		Else
			cFiltro += "AND SE1.E1_TIPO IN ('CC','CD') "
		EndIf	
						
		If __lOracle
			cFiltro += " AND ROWNUM <= " + STR(GRIDMAXLIN) + " "
		EndIf	
	EndIf

	If nFolder > 0
		Do Case
		Case nFolder == 1		//Conciliados
		
			//cFiltro += "AND FIF_STATUS  IN ('1','3','6') "
			cFiltro += "AND EXISTS ( "
			cFiltro += "SELECT E1_NSUTEF, E1_PARCELA "
			cFiltro += "FROM " + RetSqlName("SE1") + " SE1 "
			if !lMEP .or. !lUsaMep
				cFiltro += " JOIN " + RetSqlName("MEP") + " MEP "
				cFiltro += " ON E1_FILIAL = MEP_FILIAL AND "
				cFiltro += " E1_PREFIXO = MEP_PREFIX AND "
				cFiltro += " E1_NUM = MEP_NUM AND "
				cFiltro += " E1_PARCELA = MEP_PARCEL AND "
				cFiltro += " E1_TIPO = MEP_TIPO AND "
				cFiltro += " MEP.D_E_L_E_T_ <> '*' "
			endif
			If !__lProcDocTEF
				If __lSOFEX
					cFiltro += "WHERE FIF_NSUTEF = E1_NSUTEF "
				Else
				 	If __lOracle
						//#TB20200212 Thiago Berna - Ajuste para melhoria de desempenho
						//cFiltro += "WHERE FIF_NSUTEF = LPAD(TRIM(E1_NSUTEF), "+__cTamNSU+", '0') "
						cFiltro += "WHERE FIF_NSUTEF = E1_NSUTEF "
				 	else
						//#TB20200212 Thiago Berna - Ajuste para melhoria de desempenho
						//cFiltro += "WHERE FIF_NSUTEF =  REPLICATE('0', "+__cTamNSU+" - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF) "
						cFiltro += "WHERE FIF_NSUTEF =  E1_NSUTEF "
					Endif	
				Endif  
			ElseIf __lDocTef
	            cQry += "AND E1_DOCTEF = FIF_DOCTEF "
	        Endif
			//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_EMISSAO
			//cFiltro += "AND FIF_DTTEF = E1_EMISSAO "
			cFiltro += "AND FIF_DTTEF = E1_XDTCAIX "
			
			//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_VENCREA		
			//cFiltro += "AND E1_VENCREA >= '" + Dtos(dDataCredI - nQtdDias) + "' AND E1_VENCREA <= '" + Dtos(dDataCredF + nQtdDias) + "' "			
			cFiltro += "AND E1_XDTCAIX >= '" + Dtos(dDataCredI - nQtdDias) + "' AND E1_XDTCAIX <= '" + Dtos(dDataCredF + nQtdDias) + "' "			
			
			//cFiltro += "AND ((MEP_PARTEF = ' ' AND (FIF_PARCEL = E1_PARCELA) OR (FIF_PARALF = E1_PARCELA)) OR (MEP_PARTEF = FIF_PARCEL) OR (TRIM(FIF_PARALF) = TRIM(E1_PARCELA))) "
			
			//#TB20200206 Thiago Berna - Ajuste para desconsiderar a parcela
			//cFiltro += "AND TRIM(FIF_PARALF) = TRIM(E1_PARCELA) "
			If cSelFilial == 1
				If Len( __aSelFil ) <= 0
					cFiltro += "AND E1_MSFIL = '" + xFilial("FIF", __cFilAnt)  + "' "
				Else
					If !__lTodFil
						cFiltro += "AND E1_MSFIL " + GetRngFil( __aSelFil, 'FIF', .T.,, 20, .T. ) + " "
					EndIf
				EndIf	
			Else
				cFiltro += "AND E1_MSFIL = '" + xFilial("FIF", __cFilAnt)  + "' "
			EndIf
			cFiltro += "AND	FIF_CODFIL = E1_MSFIL "
			//cFiltro += "AND FIF_VLBRUT = E1_VLRREAL "
			cFiltro += "AND E1_SALDO > 0 "
			If cTipoPagam == 1
	            cFiltro += " AND E1_TIPO = 'CD' "
	        ElseIf	cTipoPagam == 2
	            cFiltro += " AND E1_TIPO = 'CC' "
	        Else
	            cFiltro += " AND E1_TIPO IN ('CD','CC') "
	        EndIf
	        
			//#TB20200205 Thiago Berna - Ajuste para desconsiderar o codigo de autorizacao
			//cFiltro += "AND FIF_CODAUT = E1_CARTAUT "
			
			//#TB20200204 Thiago Berna - Ajuste para considerar o valor Bruto = SALDO
			//cFiltro += "AND FIF_VLLIQ >= (E1_SALDO)  - ((E1_SALDO)  * " + AllTrim(Str(nMargem)) + " / 100) "
			cFiltro += "AND FIF_VLBRUT = E1_SALDO "
			
			If __lOracle
				cFiltro += "AND SUBSTR(E1_TIPO,2,1) = FIF_TPPROD "
			Else 
				cFiltro += "AND SUBSTRING(E1_TIPO,2,1) = FIF_TPPROD "
			EndIF
			cFiltro += "AND SE1.D_E_L_E_T_ <> '*' "
			cFiltro += ")"
			
		Case nFolder == 2		//Conciliados Parcialmente
		
		
			cFiltro += "AND FIF_STATUS = ' ' " // 3-Ajustes
			

		Case nFolder == 3		//Conciliados Manualmente
		
			cFiltro += "AND FIF_STATUS = '4' " // 3-Ajustes
			
		Case nFolder == 4		//Não Conciliadas
			Do Case
			Case cAlias == "FIF"
				cFiltro += "AND FIF_TPREG <> '3' " // 3-Ajustes
				cFiltro += "AND FIF_STATUS  NOT IN ('2','4') "
				cFiltro += "AND FIF_STATUS <> ' ' "
				cFiltro += "AND NOT EXISTS ( "
				cFiltro += "SELECT E1_NSUTEF, E1_PARCELA "
				cFiltro += "FROM " + RetSqlName("SE1") + " SE1 "
				if !lMEP .or. !lUsaMep
					cFiltro += " JOIN " + RetSqlName("MEP") + " MEP "
					cFiltro += " ON E1_FILIAL = MEP_FILIAL AND "
					cFiltro += " E1_PREFIXO = MEP_PREFIX AND "
					cFiltro += " E1_NUM = MEP_NUM AND "
					cFiltro += " E1_PARCELA = MEP_PARCEL AND "
					cFiltro += " E1_TIPO = MEP_TIPO AND "
					cFiltro += " MEP.D_E_L_E_T_ <> '*' "
				endif
				If !__lProcDocTEF
					If __lSOFEX
						cFiltro += "WHERE FIF_NSUTEF = E1_NSUTEF "
					Else
					 	If __lOracle
					 		//#TB20200212 Thiago Berna - Ajuste para melhoria de desempenho
							//cFiltro += "WHERE FIF_NSUTEF = LPAD(TRIM(E1_NSUTEF), "+__cTamNSU+", '0') "
							cFiltro += "WHERE FIF_NSUTEF = E1_NSUTEF "
					 	else
							//#TB20200212 Thiago Berna - Ajuste para melhoria de desempenho
							//cFiltro += "WHERE FIF_NSUTEF =  REPLICATE('0', "+__cTamNSU+" - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF) "
							cFiltro += "WHERE FIF_NSUTEF =  E1_NSUTEF "
						Endif	
					Endif 
				ElseIf __lDocTef
		            cQry += "AND E1_DOCTEF = FIF_DOCTEF "
		        Endif   
				//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_EMISSAO
				//cFiltro += "AND FIF_DTTEF = E1_EMISSAO "
				cFiltro += "AND FIF_DTTEF = E1_XDTCAIX "
			
				//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_VENCREA		
				//cFiltro += "AND E1_VENCREA >= '" + Dtos(dDataCredI - nQtdDias) + "' AND E1_VENCREA <= '" + Dtos(dDataCredF + nQtdDias) + "' "			
				cFiltro += "AND E1_XDTCAIX >= '" + Dtos(dDataCredI - nQtdDias) + "' AND E1_XDTCAIX <= '" + Dtos(dDataCredF + nQtdDias) + "' "			

				//cFiltro += "AND ((MEP_PARTEF = ' ' AND (FIF_PARCEL = E1_PARCELA) OR (FIF_PARALF = E1_PARCELA)) OR (MEP_PARTEF = FIF_PARCEL) OR (TRIM(FIF_PARALF) = TRIM(E1_PARCELA))) "
				//#TB20200206 Thiago Berna - Ajuste para desconsiderar a parcela
				//cFiltro += "AND TRIM(FIF_PARALF) = TRIM(E1_PARCELA) "
				
				If cSelFilial == 1
					If Len( __aSelFil ) <= 0
						cFiltro += "AND E1_MSFIL = '" + xFilial("FIF", __cFilAnt)  + "' "
					Else
						If !__lTodFil
							cFiltro += "AND E1_MSFIL " + GetRngFil( __aSelFil, 'FIF', .T.,, 20, .T. ) + " "
						EndIf
					EndIf	
				Else
					cFiltro += "AND E1_MSFIL = '" + xFilial("FIF", __cFilAnt)  + "' "
				EndIf
				cFiltro += "AND	FIF_CODFIL = E1_MSFIL "
				cFiltro += "AND E1_SALDO > 0 "
				//cFiltro += "AND FIF_VLBRUT = E1_VLRREAL "
				
				//#TB20200205 Thiago Berna - Ajuste para desconsiderar o codigo de autorizacao
				//cFiltro += "AND FIF_CODAUT = E1_CARTAUT "
				
				If cTipoPagam == 1
		            cFiltro += " AND E1_TIPO = 'CD' "
		        ElseIf	cTipoPagam == 2
		            cFiltro += " AND E1_TIPO = 'CC' "
		        Else
		            cFiltro += " AND E1_TIPO IN ('CD','CC') "
		        EndIf

				//#TB20200204 Thiago Berna - Ajuste para considerar o valor Bruto = SALDO
				cFiltro += "AND FIF_VLBRUT = E1_SALDO + E1_SDACRES - E1_SDDECRE "
				
				//cFiltro += "AND ( (FIF_VLLIQ >= (E1_SALDO)  - ((E1_SALDO)  * " + AllTrim(Str(nMargem)) + " / 100)) OR (FIF_VLLIQ < (E1_SALDO)  - ((E1_SALDO)  * " + AllTrim(Str(nMargem)) + " / 100)) )"
				
				//#TB20200206 Thiago Berna - Ajuste para enviar os registros para a aba divergentes
				/*If __lOracle
					cFiltro += "AND SUBSTR(E1_TIPO,2,1) = FIF_TPPROD "
				Else 
					cFiltro += "AND SUBSTRING(E1_TIPO,2,1) = FIF_TPPROD "
				EndIF*/
				
				cFiltro += "AND SE1.D_E_L_E_T_ <> '*' "
				cFiltro += ")"

			Case cAlias == "SE1"
				cFiltro += "AND E1_SALDO > 0 "
				//#TB20200214 Thiago Berna - Ajuste para desconsiderar liquidados
				cFiltro += "AND E1_VALLIQ = 0 "
				If cSelFilial == 1
					If Len( __aSelFil ) <= 0
						cFiltro += "AND E1_MSFIL = '" + xFilial("FIF", __cFilAnt)  + "' "
					Else
						If !__lTodFil
							cFiltro += "AND E1_MSFIL " + GetRngFil( __aSelFil, 'FIF', .T.,, 20, .T. ) + " "
						EndIf
					EndIf	
				Else
					cFiltro += "AND E1_MSFIL = '" + xFilial("FIF", __cFilAnt)  + "' "
				EndIf
				//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_VENCREA						
				//cFiltro += "AND E1_VENCREA >= '" + Dtos(dDataCredI - nQtdDias) + "' AND E1_VENCREA <= '" + Dtos(dDataCredF + nQtdDias) + "' "
				cFiltro += "AND E1_XDTCAIX >= '" + Dtos(dDataCredI - nQtdDias) + "' AND E1_XDTCAIX <= '" + Dtos(dDataCredF + nQtdDias) + "' "
				cFiltro += "AND SE1.D_E_L_E_T_ <> '*' "
				cFiltro += "AND NOT EXISTS ( "
				cFiltro += "SELECT FIF_NSUTEF, FIF_PARALF "
				cFiltro += "FROM " + RetSqlName("FIF") + " FIF "	
				If !__lProcDocTEF
					If __lSOFEX
						cFiltro += "WHERE FIF_NSUTEF = E1_NSUTEF "
					Else
					 	If __lOracle
					 		//#TB20200212 Thiago Berna - Ajuste para melhoria de desempenho
							//cFiltro += "WHERE FIF_NSUTEF = LPAD(TRIM(E1_NSUTEF), "+__cTamNSU+", '0') "
							cFiltro += "WHERE FIF_NSUTEF = E1_NSUTEF "
					 	else
							//#TB20200212 Thiago Berna - Ajuste para melhoria de desempenho
							//cFiltro += "WHERE FIF_NSUTEF =  REPLICATE('0', "+__cTamNSU+" - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF) "
							cFiltro += "WHERE FIF_NSUTEF =  E1_NSUTEF "
						Endif	
					Endif 
				ElseIf __lDocTef
		            cQry += "AND E1_DOCTEF = FIF_DOCTEF "
		        Endif   
		        cFiltro += "AND FIF_TPREG <> '3' " // 3-Ajustes
				
				//#TB20200212 Thiago Berna - Ajuste para exibir corretamente os dados
				//cFiltro += "AND FIF_STATUS IN ('2','4') "
				
				cFiltro += "AND FIF_STATUS <> ' ' "		
				//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_EMISSAO
				//cFiltro += "AND FIF_DTTEF = E1_EMISSAO "			
				cFiltro += "AND FIF_DTTEF = E1_XDTCAIX "			
				//cFiltro += "AND ( (FIF_PARALF = E1_PARCELA) OR (FIF_PARCEL = E1_PARCELA) ) "

				//#TB20200204 Thiago Berna - Ajuste para considerar o valor Bruto = SALDO
				cFiltro += "AND FIF_VLBRUT = E1_SALDO + E1_SDACRES - E1_SDDECRE "
				
				//#TB20200206 Thiago Berna - Ajuste para desconsiderar a parcela
				//cFiltro += "AND TRIM(FIF_PARALF) = TRIM(E1_PARCELA) "
				
				cFiltro += "AND	FIF_CODFIL = E1_MSFIL "
				//cFiltro += "AND FIF_VLBRUT = E1_VLRREAL "
				
				//#TB20200205 Thiago Berna - Ajuste para desconsiderar o codigo de autorizacao
				//cFiltro += "AND FIF_CODAUT = E1_CARTAUT "
				
				//#TB20200206 Thiago Berna - Ajuste para enviar os registros para a aba divergentes
				/*If __lOracle
					cFiltro += "AND SUBSTR(E1_TIPO,2,1) = FIF_TPPROD "
				Else 
					cFiltro += "AND SUBSTRING(E1_TIPO,2,1) = FIF_TPPROD "
				EndIF*/
				cFiltro += "AND SE1.D_E_L_E_T_ <> '*' "
				cFiltro += ")"
			EndCase 
		Case nFolder == 5		//Divergentes
			//#TB20200206 Thiago Berna - Ajuste para trazer conciliados com tipos de pagamento diferente
			/*cFiltro += "AND FIF_STATUS IN ('1','6') "
			If cTipoPagam == 1
	            cFiltro += " AND FIF_TPPROD = 'D' "
	        ElseIf	cTipoPagam == 2
	            cFiltro += " AND FIF_TPPROD = 'C' "
	        Else
	            cFiltro += " AND FIF_TPPROD IN ('D','C') "
	        EndIf
			cFiltro += "AND FIF_TPREG = '3' "*/

			cFiltro += "AND FIF_STATUS  IN ('1','3','6') "
			cFiltro += "AND EXISTS ( "
			cFiltro += "SELECT E1_NSUTEF, E1_PARCELA "
			cFiltro += "FROM " + RetSqlName("SE1") + " SE1 "
			if !lMEP .or. !lUsaMep
				cFiltro += " JOIN " + RetSqlName("MEP") + " MEP "
				cFiltro += " ON E1_FILIAL = MEP_FILIAL AND "
				cFiltro += " E1_PREFIXO = MEP_PREFIX AND "
				cFiltro += " E1_NUM = MEP_NUM AND "
				cFiltro += " E1_PARCELA = MEP_PARCEL AND "
				cFiltro += " E1_TIPO = MEP_TIPO AND "
				cFiltro += " MEP.D_E_L_E_T_ <> '*' "
			endif
			If !__lProcDocTEF
				If __lSOFEX
					cFiltro += "WHERE FIF_NSUTEF = E1_NSUTEF "
				Else
				 	If __lOracle
				 		//#TB20200212 Thiago Berna - Ajuste para melhoria de desempenho
						 //cFiltro += "WHERE FIF_NSUTEF = LPAD(TRIM(E1_NSUTEF), "+__cTamNSU+", '0') "
						 cFiltro += "WHERE FIF_NSUTEF = E1_NSUTEF "
				 	else
						//#TB20200212 Thiago Berna - Ajuste para melhoria de desempenho
						//cFiltro += "WHERE FIF_NSUTEF =  REPLICATE('0', "+__cTamNSU+" - LEN(E1_NSUTEF)) + RTrim(E1_NSUTEF) "
						cFiltro += "WHERE FIF_NSUTEF =  E1_NSUTEF "
					Endif	
				Endif  
			ElseIf __lDocTef
	            cQry += "AND E1_DOCTEF = FIF_DOCTEF "
	        Endif
			//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_EMISSAO
			//cFiltro += "AND FIF_DTTEF = E1_EMISSAO "
			cFiltro += "AND FIF_DTTEF = E1_XDTCAIX "
			
			//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_VENCREA		
			//cFiltro += "AND E1_VENCREA >= '" + Dtos(dDataCredI - nQtdDias) + "' AND E1_VENCREA <= '" + Dtos(dDataCredF + nQtdDias) + "' "			
			cFiltro += "AND E1_XDTCAIX >= '" + Dtos(dDataCredI - nQtdDias) + "' AND E1_XDTCAIX <= '" + Dtos(dDataCredF + nQtdDias) + "' "			
			
			//cFiltro += "AND ((MEP_PARTEF = ' ' AND (FIF_PARCEL = E1_PARCELA) OR (FIF_PARALF = E1_PARCELA)) OR (MEP_PARTEF = FIF_PARCEL) OR (TRIM(FIF_PARALF) = TRIM(E1_PARCELA))) "
			
			//#TB20200206 Thiago Berna - Ajuste para desconsiderar a parcela
			//cFiltro += "AND TRIM(FIF_PARALF) = TRIM(E1_PARCELA) "
			If cSelFilial == 1
				If Len( __aSelFil ) <= 0
					cFiltro += "AND E1_MSFIL = '" + xFilial("FIF", __cFilAnt)  + "' "
				Else
					If !__lTodFil
						cFiltro += "AND E1_MSFIL " + GetRngFil( __aSelFil, 'FIF', .T.,, 20, .T. ) + " "
					EndIf
				EndIf	
			Else
				cFiltro += "AND E1_MSFIL = '" + xFilial("FIF", __cFilAnt)  + "' "
			EndIf
			cFiltro += "AND	FIF_CODFIL = E1_MSFIL "
			//cFiltro += "AND FIF_VLBRUT = E1_VLRREAL "
			cFiltro += "AND E1_SALDO > 0 "
			If cTipoPagam == 1
	            cFiltro += " AND E1_TIPO = 'CD' "
	        ElseIf	cTipoPagam == 2
	            cFiltro += " AND E1_TIPO = 'CC' "
	        Else
	            cFiltro += " AND E1_TIPO IN ('CD','CC') "
	        EndIf
	        
			//#TB20200205 Thiago Berna - Ajuste para desconsiderar o codigo de autorizacao
			//cFiltro += "AND FIF_CODAUT = E1_CARTAUT "
			
			//#TB20200204 Thiago Berna - Ajuste para considerar o valor Bruto
			//cFiltro += "AND FIF_VLLIQ >= (E1_SALDO)  - ((E1_SALDO)  * " + AllTrim(Str(nMargem)) + " / 100) "
			cFiltro += "AND FIF_VLBRUT = E1_SALDO "
			
			If __lOracle
				cFiltro += "AND SUBSTR(E1_TIPO,2,1) <> FIF_TPPROD "
			Else 
				cFiltro += "AND SUBSTRING(E1_TIPO,2,1) <> FIF_TPPROD "
			EndIF
			cFiltro += "AND SE1.D_E_L_E_T_ <> '*' "
			cFiltro += ")"
						
		EndCase
	EndIf
	


Return cFiltro


//-------------------------------------------------------------------
/*/{Protheus.doc} StrHead
Retorna a Estrutura do Cabecalho

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static Function StrHead( nTipo As Numeric ) As Object
	Local oStruct	As Object
	Local nLenSt	As Numeric

	Do Case
	Case nTipo == 1
		oStruct	:= FWFormModelStruct():New()

		nLenSt := TamSX3("FIF_STATUS")[1]

		//Tabela
		oStruct:AddTable("TMP" ,{"STATUS"}, "Cabecalho")	//Campos do cabeçalho do TMP
		
		//Campos
		oStruct:AddField(	"STATUS"	,; 	// [01] C Titulo do campo
							"STATUS"	,; 	// [02] C ToolTip do campo
							"STATUS"	,; 	// [03] C identificador (ID) do Field
							"C" 		,; 	// [04] C Tipo do campo
							nLenSt		,; 	// [05] N Tamanho do campo
							0 			,; 	// [06] N Decimal do campo
							Nil 		,; 	// [07] B Code-block de validação do campo
							Nil			,; 	// [08] B Code-block de validação When do campo
							Nil 		,; 	// [09] A Lista de valores permitido do campo
					      	Nil 		,;	// [10] L Indica se o campo tem preenchimento obrigatório
							Nil			,; 	// [11] B Code-block de inicializacao do campo
							Nil 		,;	// [12] L Indica se trata de um campo chave
							.F.		 	,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
							.F.			)	// [14] L Indica se o campo é virtual

	Case nTipo == 2
		oStruct	:= FWFormViewStruct():New()

		oStruct:AddField(	"STATUS"	,;	// [01]  C   Nome do Campo
							"01"		,;	// [02]  C   Ordem
							"STATUS"	,;	// [03]  C   Titulo do campo
							"STATUS"	,;	// [04]  C   Descricao do campo
							NIL			,;	// [05]  A   Array com Help
							"C"			,;	// [06]  C   Tipo do campo
							NIL			,;	// [07]  C   Picture
							NIL			,;	// [08]  B   Bloco de Picture Var
							NIL			,;	// [09]  C   Consulta F3
							.F.			,;	// [10]  L   Indica se o campo é alteravel
							NIL			,;	// [11]  C   Pasta do campo
							NIL			,;	// [12]  C   Agrupamento do campo
							NIL			,;	// [13]  A   Lista de valores permitido do campo (Combo)
							NIL			,;	// [14]  N   Tamanho maximo da maior opção do combo
							NIL			,;	// [15]  C   Inicializador de Browse
							.F.			,;	// [16]  L   Indica se o campo é virtual
							NIL			,;	// [17]  C   Picture Variavel
							NIL			)	// [18]  L   Indica pulo de linha após o campo
	EndCase
						
Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} StrTot
Retorna a Estrutura do Cabecalho

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static Function StrTot( nTipo As Numeric ) As Object
	Local oStruct	As Object
	Local cPicture	As Character
	Local cOrdem	As Character
	Local nLenVlr	As Numeric
	Local nDecVlr	As Numeric
	Local nLenQtd	As Numeric

	cPicture	:= PesqPict("SE1", "E1_VALOR")
	cOrdem		:= "00"
	nLenVlr		:= TamSX3("E1_VALOR")[1]
	nDecVlr		:= TamSX3("E1_VALOR")[2]
	nLenQtd		:= 09

	Do Case
	Case nTipo == 1
		oStruct	:= FWFormModelStruct():New()

		//Tabela
		oStruct:AddTable("TOTAIS" ,{"DTAVEND"}, "Totais")	//Campos do cabeçalho do TMP	//"Totais"

		//Campos
		oStruct:AddField("Data Credito", "Data Credito", "DTAVEND", "D", 8, 0, NIL, NIL, NIL, NIL, {|| dDatabase}, NIL, .F., .F.)	//"Data Credito"
		If __nFldPar == 0 .OR. __nFldPar == 1
			oStruct:AddField("Tot. Conc.", "Tot. Conc.",  "TOTFLD1", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Tot. Conc."
			oStruct:AddField("Qt.Conc.", "Qt.Conc.",  "QTDFLD1", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)				//"Qt.Conc."
		EndIf
		If __nFldPar == 0 .OR. __nFldPar == 2
			oStruct:AddField("Tot. Parcial", "Tot. Parcial",  "TOTFLD2", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Tot. Parcial"
			oStruct:AddField("Qt. Parcial", "Qt. Parcial",  "QTDFLD2", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)				//"Qt. Parcial"
		EndIf
		If __nFldPar == 0 .OR. __nFldPar == 3
			oStruct:AddField("Tot.Manual", "Tot.Manual",  "TOTFLD3", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Tot.Manual"	
			oStruct:AddField("Qt. Manual", "Qt. Manual",  "QTDFLD3", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)				//"Qt. Manual"
		EndIf
		If __nFldPar == 0 .OR. __nFldPar == 4
			oStruct:AddField("Tot. N�o Conc.", "Tot. N�o Conc.",  "TOTFLD4", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Tot. Não Conc."
			oStruct:AddField("Qt. N�o Conc.", "Qt. N�o Conc.",  "QTDFLD4", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)				//"Qt. Não Conc."	
		EndIf
		If __nFldPar == 0 .OR. __nFldPar == 5
			oStruct:AddField("Tot. Diverg.", "Tot. Diverg.",  "TOTFLD5", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Tot. Diverg."
			oStruct:AddField("Qt.  Diverg.", "Qt.  Diverg.",  "QTDFLD5", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)				//"Qt.  Diverg."
		EndIf
		
		oStruct:AddField("Total R$", "Total R$",  "TOTTOT", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Total R$"
		oStruct:AddField("Qt.Total", "Qt.Total",  "QTDTOT", "N", nLenQtd, 0, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)				//"Total R$"

		//Indices
		oStruct:AddIndex(1, "01", "DTAVEND", "Data Credito", "", "", .T.)		//"Data Credito"
	Case nTipo == 2
		oStruct	:= FWFormViewStruct():New()

		oStruct:AddField("DTAVEND",fSoma1(@cOrdem),"Data Credito","Data Credito",NIL,"D",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)		//"Data Credito"	
		If __nFldPar == 0 .OR. __nFldPar == 1
			oStruct:AddField("TOTFLD1",fSoma1(@cOrdem),"Tot. Conc.","Tot. Conc.",NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Tot. Conc."	
			oStruct:AddField("QTDFLD1",fSoma1(@cOrdem),"Qt. Conc.","Qt. Conc.",NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)				//"Qt. Conc."	
		EndIf
		If __nFldPar == 0 .OR. __nFldPar == 2
			oStruct:AddField("TOTFLD2",fSoma1(@cOrdem),"Tot. Parcial","Tot. Parcial",NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)	//"Tot. Parcial"	
			oStruct:AddField("QTDFLD2",fSoma1(@cOrdem),"Qt. Parcial","Qt. Parcial",NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)			//"Qt. Parcial"	
		EndIf
		If __nFldPar == 0 .OR. __nFldPar == 3
			oStruct:AddField("TOTFLD3",fSoma1(@cOrdem),"Tot.Manual"	,"Tot.Manual"	,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Tot.Manual"		
			oStruct:AddField("QTDFLD3",fSoma1(@cOrdem),"Qt. Manual"	,"Qt. Manual"	,NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)				//"Qt. Manual"	
		EndIf
		If __nFldPar == 0 .OR. __nFldPar == 4
			oStruct:AddField("TOTFLD4",fSoma1(@cOrdem),"Tot. N�o Conc."	,"Tot. N�o Conc."	,NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Tot. Não Conc."
			oStruct:AddField("QTDFLD4",fSoma1(@cOrdem),"Qt. N�o Conc.","Qt. N�o Conc.",NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)				//"Qt. Não Conc."	
		EndIf
		If __nFldPar == 0 .OR. __nFldPar == 5
			oStruct:AddField("TOTFLD5",fSoma1(@cOrdem),"Tot. Diverg.","Tot. Diverg.",NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Tot. Diverg."	
			oStruct:AddField("QTDFLD5",fSoma1(@cOrdem),"Qt. Diverg.","Qt. Diverg.",NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)				//"Qt. Diverg."	
		EndIf
		oStruct:AddField("TOTTOT",fSoma1(@cOrdem),"Total R$","Total R$",NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Total R$"	
		oStruct:AddField("QTDTOT",fSoma1(@cOrdem),"Qt.Total.","Qt.Total",NIL,"N",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)				//"Qt.Total"
	EndCase
						
Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} fSoma1
Soma da Ordem dos Campos

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static Function fSoma1( cOrdem As Character ) As Character
	cOrdem := Soma1( cOrdem )
Return cOrdem

//-------------------------------------------------------------------
/*/{Protheus.doc} AddField
Inclusao dos Campos de Selecao dos Registros

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static Function AddField( nOpcao As Numeric, oStruct As Object, bValid As Codeblock, nFolder as Numeric )
	Default bValid := NIL
	Default nFolder := 0
	
	Do Case
	Case nOpcao == 1	//Model
	
		If nFolder == 1 .OR. nFolder == 2 //.OR. nFolder == 8
			oStruct:AddField(		"Conciliar"						,;	//[01]  C   Titulo do campo		//"Conciliar"
									"Conciliar"						,;	//[02]  C   ToolTip do campo	//"Conciliar"
								 	"OK"						,;	//[03]  C   Id do Field
								 	"L"							,;	//[04]  C   Tipo do campo
									1							,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
									0							,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
									bValid						,;	//[07]  B   Code-block de validação do campo
									NIL							,;	//[08]  B   Code-block de validação When do campo
									NIL							,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
									.F.							,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
									{||.F.}						,;	//[11]  B   Code-block de inicializacao do campo
									.F.							,;	//[12]  L   Indica se trata-se de um campo chave
									.F.							,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.F.							)	//[14]  L   Indica se o campo é virtual
		Else
		
			oStruct:AddField(		"Conciliar"						,;	//[01]  C   Titulo do campo		//"Conciliar"
									"Conciliar"						,;	//[02]  C   ToolTip do campo	//"Conciliar"
								 	"OK"						,;	//[03]  C   Id do Field
								 	"L"							,;	//[04]  C   Tipo do campo
									1							,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
									0							,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
									bValid						,;	//[07]  B   Code-block de validação do campo
									NIL							,;	//[08]  B   Code-block de validação When do campo
									NIL							,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
									.F.							,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
									NIL							,;	//[11]  B   Code-block de inicializacao do campo
									.F.							,;	//[12]  L   Indica se trata-se de um campo chave
									.F.							,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.F.							)	//[14]  L   Indica se o campo é virtual		
		EndIf
			
		if alltrim(oStruct:aTable[1]) == "FIF"
			
			//Adiciona legenda
			/*If nFolder == 8

				oStruct:AddField(		""															,;	//[01]  C   Titulo do campo		//"Conciliar"
										""															,;	//[02]  C   ToolTip do campo	//"Conciliar"
										"FIF_LEGEN"													,;	//[03]  C   Id do Field
										"C"															,;	//[04]  C   Tipo do campo
										50															,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
										0															,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
										Nil															,;	//[07]  B   Code-block de validação do campo
										NIL															,;	//[08]  B   Code-block de validação When do campo
										NIL															,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
										Nil														,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
										{||IIF(Empty(FIF->FIF_NUM), "BR_VERMELHO","BR_VERDE")}	,;	//[11]  B   Code-block de inicializacao do campo
										Nil															,;	//[12]  L   Indica se trata-se de um campo chave
										Nil															,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
										.T.															)	//[14]  L   Indica se o campo é virtual

			EndIf*/
			
			oStruct:AddField(	"Status Venda"	,;	//[01]  C   Titulo do campo
								"Status Venda"	,;	//[02]  C   ToolTip do campo
								"FIF_XSTATU"					,;	//[03]  C   Id do Field
								"C"								,;	//[04]  C   Tipo do campo
								TAMSX3("FIF_STATUS")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								TAMSX3("FIF_STATUS")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								NIL								,;	//[08]  B   Code-block de validação When do campo
								NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								{||FIF->FIF_STATUS}			    ,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.T.								)	//[14]  L   Indica se o campo é virtual
			
			oStruct:AddField(	"NSU SITEF"	,;	//[01]  C   Titulo do campo
								"NSU SITEF"	,;	//[02]  C   ToolTip do campo
								"FIF_XNSUAR"					,;	//[03]  C   Id do Field
								"C"								,;	//[04]  C   Tipo do campo
								TAMSX3("FIF_NSUARQ")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								TAMSX3("FIF_NSUARQ")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								NIL								,;	//[08]  B   Code-block de validação When do campo
								NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								{||iif(Empty(FIF->FIF_NSUARQ),FIF->FIF_NSUTEF,FIF->FIF_NSUARQ)}			    ,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.T.								)	//[14]  L   Indica se o campo é virtual
			
			//#TB20200206 Thiago Berna - Adicionar campo com a descricao do FIF_CODRED
			oStruct:AddField(	"Rede"	,;	//[01]  C   Titulo do campo
								"Rede"	,;	//[02]  C   ToolTip do campo
								"FIF_XCODRE"					,;	//[03]  C   Id do Field
								"C"								,;	//[04]  C   Tipo do campo
								TAMSX3("ZWY_DESC")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
								TAMSX3("ZWY_DESC")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
								Nil								,;	//[07]  B   Code-block de validação do campo
								NIL								,;	//[08]  B   Code-block de validação When do campo
								NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
								.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
								{||Posicione("SX5",1,xFilial('SX5')+'G3'+AllTrim(FIF->FIF_CODRED),"X5_DESCRI")}			    ,;	//[11]  B   Code-block de inicializacao do campo
								.F.								,;	//[12]  L   Indica se trata-se de um campo chave
								.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.T.								)	//[14]  L   Indica se o campo é virtual
		endif
									
		If nFolder == 1 .Or. nFolder == 2 .Or. nFolder == 8
		
				oStruct:AddField(	AllTrim(RetTitle("E1_NSUTEF"))	,;	//[01]  C   Titulo do campo
									AllTrim(RetTitle("E1_NSUTEF"))	,;	//[02]  C   ToolTip do campo
									"E1_XNSUTEF"					,;	//[03]  C   Id do Field
									"C"								,;	//[04]  C   Tipo do campo
									TAMSX3("E1_NSUTEF")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
									TAMSX3("E1_NSUTEF")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
									Nil								,;	//[07]  B   Code-block de validação do campo
									NIL								,;	//[08]  B   Code-block de validação When do campo
									NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
									.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
									{||/*IIF(len(alltrim(cValToChar(val(SE1->E1_DOCTEF))))>6, SE1->E1_DOCTEF,SE1->E1_NSUTEF)*/SE1->E1_NSUTEF}			    ,;	//[11]  B   Code-block de inicializacao do campo
									.F.								,;	//[12]  L   Indica se trata-se de um campo chave
									.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.								)	//[14]  L   Indica se o campo é virtual
									
				oStruct:AddField(	AllTrim(RetTitle("E1_DOCTEF"))	,;	//[01]  C   Titulo do campo
									AllTrim(RetTitle("E1_DOCTEF"))	,;	//[02]  C   ToolTip do campo
									"E1_XDOCTEF"					,;	//[03]  C   Id do Field
									"C"								,;	//[04]  C   Tipo do campo
									TAMSX3("E1_DOCTEF")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
									TAMSX3("E1_DOCTEF")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
									Nil								,;	//[07]  B   Code-block de validação do campo
									NIL								,;	//[08]  B   Code-block de validação When do campo
									NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
									.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
									{||/*IIF(len(alltrim(cValToChar(val(SE1->E1_DOCTEF))))>6, SE1->E1_NSUTEF, SE1->E1_DOCTEF)*/SE1->E1_NSUTEF}			    ,;	//[11]  B   Code-block de inicializacao do campo
									.F.								,;	//[12]  L   Indica se trata-se de um campo chave
									.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.								)	//[14]  L   Indica se o campo é virtual
		
				oStruct:AddField(	AllTrim(RetTitle("FIF_VLLIQ"))	,;	//[01]  C   Titulo do campo
									AllTrim(RetTitle("FIF_VLLIQ"))	,;	//[02]  C   ToolTip do campo
									"E1_XVLRTEF"					,;	//[03]  C   Id do Field
									"N"								,;	//[04]  C   Tipo do campo
									TAMSX3("FIF_VLLIQ")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
									TAMSX3("FIF_VLLIQ")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
									Nil								,;	//[07]  B   Code-block de validação do campo
									NIL								,;	//[08]  B   Code-block de validação When do campo
									NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
									.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
									{||FIF->FIF_VLLIQ}			    ,;	//[11]  B   Code-block de inicializacao do campo
									.F.								,;	//[12]  L   Indica se trata-se de um campo chave
									.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.								)	//[14]  L   Indica se o campo é virtual
									
				oStruct:AddField(	AllTrim(RetTitle("E1_FILORIG"))	,;	//[01]  C   Titulo do campo
									AllTrim(RetTitle("E1_FILORIG"))	,;	//[02]  C   ToolTip do campo
									"E1_XFILORI"					,;	//[03]  C   Id do Field
									TAMSX3("E1_FILORIG")[3]			,;	//[04]  C   Tipo do campo
									TAMSX3("E1_FILORIG")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
									TAMSX3("E1_FILORIG")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
									Nil								,;	//[07]  B   Code-block de validação do campo
									NIL								,;	//[08]  B   Code-block de validação When do campo
									NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
									.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
									{||SE1->E1_FILORIG}				,;	//[11]  B   Code-block de inicializacao do campo
									.F.								,;	//[12]  L   Indica se trata-se de um campo chave
									.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.								)	//[14]  L   Indica se o campo é virtual	
									
				oStruct:AddField(	"Conciliar"							,;	//[01]  C   Titulo do campo
									"Conciliar"							,;	//[02]  C   ToolTip do campo
									"Conciliar"						,;	//[03]  C   Id do Field
									TAMSX3("E1_LOJA")[3]			,;	//[04]  C   Tipo do campo
									TAMSX3("E1_LOJA")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
									TAMSX3("E1_LOJA")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
									Nil								,;	//[07]  B   Code-block de validação do campo
									NIL								,;	//[08]  B   Code-block de validação When do campo
									NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
									.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
									NIL								,;	//[11]  B   Code-block de inicializacao do campo
									.F.								,;	//[12]  L   Indica se trata-se de um campo chave
									.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.								)	//[14]  L   Indica se o campo é virtual	*/
										
				oStruct:AddField(	AllTrim(RetTitle("E1_SALDO"))	,;	//[01]  C   Titulo do campo
									AllTrim(RetTitle("E1_SALDO"))	,;	//[02]  C   ToolTip do campo
									"E1_XSALDO"						,;	//[03]  C   Id do Field
									"N"								,;	//[04]  C   Tipo do campo
									TAMSX3("E1_SALDO")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
									TAMSX3("E1_SALDO")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
									Nil								,;	//[07]  B   Code-block de validação do campo
									NIL								,;	//[08]  B   Code-block de validação When do campo
									NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
									.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
									{||SE1->E1_SALDO}			    ,;	//[11]  B   Code-block de inicializacao do campo
									.F.								,;	//[12]  L   Indica se trata-se de um campo chave
									.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.								)
									
				oStruct:AddField(	AllTrim(RetTitle("E1_VLRREAL"))	,;	//[01]  C   Titulo do campo
									AllTrim(RetTitle("E1_VLRREAL"))	,;	//[02]  C   ToolTip do campo
									"E1_XVLRREAL"						,;	//[03]  C   Id do Field
									"N"								,;	//[04]  C   Tipo do campo
									TAMSX3("E1_VLRREAL")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
									TAMSX3("E1_VLRREAL")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
									Nil								,;	//[07]  B   Code-block de validação do campo
									NIL								,;	//[08]  B   Code-block de validação When do campo
									NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
									.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
									{||SE1->E1_VLRREAL}			    ,;	//[11]  B   Code-block de inicializacao do campo
									.F.								,;	//[12]  L   Indica se trata-se de um campo chave
									.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.								)
									
				oStruct:AddField(	AllTrim(RetTitle("E1_CARTAUT"))	,;	//[01]  C   Titulo do campo
									AllTrim(RetTitle("E1_CARTAUT"))	,;	//[02]  C   ToolTip do campo
									"E1_XCARTAUT"					,;	//[03]  C   Id do Field
									"C"								,;	//[04]  C   Tipo do campo
									TAMSX3("E1_CARTAUT")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
									TAMSX3("E1_CARTAUT")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
									Nil								,;	//[07]  B   Code-block de validação do campo
									NIL								,;	//[08]  B   Code-block de validação When do campo
									NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
									.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
									{||SE1->E1_CARTAUT}			    ,;	//[11]  B   Code-block de inicializacao do campo
									.F.								,;	//[12]  L   Indica se trata-se de um campo chave
									.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.								)
									
																		
		Elseif nFolder == 3 .Or. nFolder == 4
		
				oStruct:AddField(	AllTrim(RetTitle("E1_NSUTEF"))	,;	//[01]  C   Titulo do campo
									AllTrim(RetTitle("E1_NSUTEF"))	,;	//[02]  C   ToolTip do campo
									"E1_XNSUTEF"					,;	//[03]  C   Id do Field
									"C"								,;	//[04]  C   Tipo do campo
									TAMSX3("E1_NSUTEF")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
									TAMSX3("E1_NSUTEF")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
									Nil								,;	//[07]  B   Code-block de validação do campo
									NIL								,;	//[08]  B   Code-block de validação When do campo
									NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
									.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
									{||/*IIF(len(alltrim(cValToChar(val(SE1->E1_DOCTEF))))>6, SE1->E1_DOCTEF,SE1->E1_NSUTEF)*/SE1->E1_NSUTEF}			    ,;	//[11]  B   Code-block de inicializacao do campo
									.F.								,;	//[12]  L   Indica se trata-se de um campo chave
									.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.								)	//[14]  L   Indica se o campo é virtual
									
				oStruct:AddField(	AllTrim(RetTitle("E1_DOCTEF"))	,;	//[01]  C   Titulo do campo
									AllTrim(RetTitle("E1_DOCTEF"))	,;	//[02]  C   ToolTip do campo
									"E1_XDOCTEF"					,;	//[03]  C   Id do Field
									"C"								,;	//[04]  C   Tipo do campo
									TAMSX3("E1_DOCTEF")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
									TAMSX3("E1_DOCTEF")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
									Nil								,;	//[07]  B   Code-block de validação do campo
									NIL								,;	//[08]  B   Code-block de validação When do campo
									NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
									.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
									{||/*IIF(len(alltrim(cValToChar(val(SE1->E1_DOCTEF))))>6, SE1->E1_NSUTEF, SE1->E1_DOCTEF)*/SE1->E1_NSUTEF}			    ,;	//[11]  B   Code-block de inicializacao do campo
									.F.								,;	//[12]  L   Indica se trata-se de um campo chave
									.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.								)	//[14]  L   Indica se o campo é virtual
		
			oStruct:AddField(		"Vlr Liquido"						,;	//[01]  C   Titulo do campo //"Vlr Liquido"
									"Vlr Liquido"						,;	//[02]  C   ToolTip do campo "Vlr Liquido"
									"E1_XVALLIQ"				,;	//[03]  C   Id do Field
									"N"							,;	//[04]  C   Tipo do campo
									TAMSX3("E1_SALDO")[1]		,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
									TAMSX3("E1_SALDO")[2]		,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
									Nil							,;	//[07]  B   Code-block de validação do campo
									NIL							,;	//[08]  B   Code-block de validação When do campo
									NIL							,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
									.F.							,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
									{||SE1->E1_SALDO}			,;	//[11]  B   Code-block de inicializacao do campo
									.F.							,;	//[12]  L   Indica se trata-se de um campo chave
									.F.							,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.							)	//[14]  L   Indica se o campo é virtual
		
			oStruct:AddField(		AllTrim(RetTitle("E1_FILORIG"))	,;	//[01]  C   Titulo do campo
									AllTrim(RetTitle("E1_FILORIG"))	,;	//[02]  C   ToolTip do campo
									"E1_XFILORI"					,;	//[03]  C   Id do Field
									TAMSX3("E1_FILORIG")[3]			,;	//[04]  C   Tipo do campo
									TAMSX3("E1_FILORIG")[1]			,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
									TAMSX3("E1_FILORIG")[2]			,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
									Nil								,;	//[07]  B   Code-block de validação do campo
									NIL								,;	//[08]  B   Code-block de validação When do campo
									NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
									.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
									{||SE1->E1_FILORIG}				,;	//[11]  B   Code-block de inicializacao do campo
									.F.								,;	//[12]  L   Indica se trata-se de um campo chave
									.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.								)	//[14]  L   Indica se o campo é virtual
									
			oStruct:AddField(	AllTrim(RetTitle("E1_SALDO"))	,;	//[01]  C   Titulo do campo
									AllTrim(RetTitle("E1_SALDO"))	,;	//[02]  C   ToolTip do campo
									"E1_XSALDO"						,;	//[03]  C   Id do Field
									"N"								,;	//[04]  C   Tipo do campo
									TAMSX3("E1_SALDO")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
									TAMSX3("E1_SALDO")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
									Nil								,;	//[07]  B   Code-block de validação do campo
									NIL								,;	//[08]  B   Code-block de validação When do campo
									NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
									.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
									{||SE1->E1_SALDO}			    ,;	//[11]  B   Code-block de inicializacao do campo
									.F.								,;	//[12]  L   Indica se trata-se de um campo chave
									.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.								)
									
			oStruct:AddField(	AllTrim(RetTitle("E1_VLRREAL"))	,;	//[01]  C   Titulo do campo
									AllTrim(RetTitle("E1_VLRREAL"))	,;	//[02]  C   ToolTip do campo
									"E1_XVLRREAL"						,;	//[03]  C   Id do Field
									"N"								,;	//[04]  C   Tipo do campo
									TAMSX3("E1_VLRREAL")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
									TAMSX3("E1_VLRREAL")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
									Nil								,;	//[07]  B   Code-block de validação do campo
									NIL								,;	//[08]  B   Code-block de validação When do campo
									NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
									.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
									{||SE1->E1_VLRREAL}			    ,;	//[11]  B   Code-block de inicializacao do campo
									.F.								,;	//[12]  L   Indica se trata-se de um campo chave
									.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.								)		
									
			oStruct:AddField(	AllTrim(RetTitle("E1_CARTAUT"))	,;	//[01]  C   Titulo do campo
									AllTrim(RetTitle("E1_CARTAUT"))	,;	//[02]  C   ToolTip do campo
									"E1_XCARTAUT"					,;	//[03]  C   Id do Field
									"C"								,;	//[04]  C   Tipo do campo
									TAMSX3("E1_CARTAUT")[1]		    ,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
									TAMSX3("E1_CARTAUT")[2]		    ,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
									Nil								,;	//[07]  B   Code-block de validação do campo
									NIL								,;	//[08]  B   Code-block de validação When do campo
									NIL								,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
									.F.								,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
									{||SE1->E1_CARTAUT}			    ,;	//[11]  B   Code-block de inicializacao do campo
									.F.								,;	//[12]  L   Indica se trata-se de um campo chave
									.F.								,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
									.T.								)
			
		EndIf

	Case nOpcao == 2	//View
		oStruct:AddField(	"OK"							,;	// [01]  C   Nome do Campo
							"01"							,;	// [02]  C   Ordem
							"Conciliar"							,;	// [03]  C   Titulo do campo		//"Conciliar"
							"Conciliar"							,;	// [04]  C   Descricao do campo		//"Conciliar"
							NIL								,;	// [05]  A   Array com Help
							"Check"							,;	// [06]  C   Tipo do campo
							NIL								,;	// [07]  C   Picture
							NIL								,;	// [08]  B   Bloco de Picture Var
							NIL								,;	// [09]  C   Consulta F3
							NIL								,;	// [10]  L   Indica se o campo é alteravel
							NIL								,;	// [11]  C   Pasta do campo
							NIL								,;	// [12]  C   Agrupamento do campo
							NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
							NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
							NIL								,;	// [15]  C   Inicializador de Browse
							NIL								,;	// [16]  L   Indica se o campo é virtual
							NIL								,;	// [17]  C   Picture Variavel
							NIL								)	// [18]  L   Indica pulo de linha após o
		
		if substr(alltrim(oStruct:aFields[1,1]),1,3) == "FIF"				
			
			/*If nFolder == 8
			
				oStruct:AddField( ;            							// Ord. Tipo Desc.
								'FIF_LEGEN'                   	, ;   	// [01]  C   Nome do Campo
								"00"                         	, ;     // [02]  C   Ordem
								AllTrim( ''    )        		, ;     // [03]  C   Titulo do campo
								AllTrim( '' )       			, ;     // [04]  C   Descricao do campo
								{ 'Legenda' } 					, ;     // [05]  A   Array com Help
								'C'                             , ;     // [06]  C   Tipo do campo
								'@BMP'                			, ;     // [07]  C   Picture
								NIL                             , ;     // [08]  B   Bloco de Picture Var
								''                              , ;     // [09]  C   Consulta F3
								.T.                             , ;     // [10]  L   Indica se o campo � alteravel
								NIL                             , ;     // [11]  C   Pasta do campo
								NIL                             , ;     // [12]  C   Agrupamento do campo
								NIL				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
								NIL                             , ;     // [14]  N   Tamanho maximo da maior op��o do combo
								NIL                             , ;     // [15]  C   Inicializador de Browse
								.T.                             , ;     // [16]  L   Indica se o campo � virtual
								NIL                             , ;     // [17]  C   Picture Variavel
								NIL                             )       // [18]  L   Indica pulo de linha ap�s o campo

			EndIf*/
			
			oStruct:AddField(	"FIF_XSTATU"								,;	// [01]  C   Nome do Campo
								Alltrim(Str(FIF->(FieldPos("FIF_STATUS"))+1)),;	// [02]  C   Ordem
								"Status Venda"								,;	// [03]  C   Titulo do campo
								"Status Venda"								,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"C"											,;	// [06]  C   Tipo do campo
								"@!"										,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo
			oStruct:AddField(	"FIF_XNSUAR"								,;	// [01]  C   Nome do Campo
								Alltrim(Str(FIF->(FieldPos("FIF_NSUARQ"))+1)),;	// [02]  C   Ordem
								"NSU SITEF"								,;	// [03]  C   Titulo do campo
								"NSU SITEF"								,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"C"											,;	// [06]  C   Tipo do campo
								"@!"										,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo 

			oStruct:AddField(	"FIF_XCODRE"								,;	// [01]  C   Nome do Campo
								Alltrim(Str(FIF->(FieldPos("FIF_CODRED")))+'A'),;	// [02]  C   Ordem
								"Rede"								,;	// [03]  C   Titulo do campo
								"Rede"								,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"C"											,;	// [06]  C   Tipo do campo
								"@!"										,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo 
		Endif
		
		If nFolder == 1 .Or. nFolder == 2 .Or. nFolder == 8
		
			oStruct:AddField(	"E1_XNSUTEF"								,;	// [01]  C   Nome do Campo
								Alltrim(Str(SE1->(FieldPos("E1_DOCTEF"))+1)),;	// [02]  C   Ordem
								AllTrim(RetTitle("E1_NSUTEF"))				,;	// [03]  C   Titulo do campo
								AllTrim(RetTitle("E1_NSUTEF"))				,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"C"											,;	// [06]  C   Tipo do campo
								PesqPict("SE1", "E1_NSUTEF")				,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo
								
			oStruct:AddField(	"E1_XDOCTEF"								,;	// [01]  C   Nome do Campo
								Alltrim(Str(SE1->(FieldPos("E1_DOCTEF"))+1)),;	// [02]  C   Ordem
								AllTrim(RetTitle("E1_DOCTEF"))				,;	// [03]  C   Titulo do campo
								AllTrim(RetTitle("E1_DOCTEF"))				,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"C"											,;	// [06]  C   Tipo do campo
								PesqPict("SE1", "E1_DOCTEF")				,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo
		
			oStruct:AddField(	"E1_XVLRTEF"								,;	// [01]  C   Nome do Campo
								Alltrim(Str(SE1->(FieldPos("E1_DOCTEF"))+1)),;	// [02]  C   Ordem
								"Vlr. Tef" 									,;	// [03]  C   Titulo do campo
								"Vlr. Tef" 									,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"N"											,;	// [06]  C   Tipo do campo
								PesqPict("FIF", "FIF_VLLIQ")					,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo
								
			oStruct:AddField(	"E1_XFILORI"								,;	// [01]  C   Nome do Campo
								Alltrim(Str(SE1->(FieldPos("E1_DOCTEF"))+1)),;	// [02]  C   Ordem
								AllTrim(RetTitle("E1_FILORIG"))				,;	// [03]  C   Titulo do campo
								AllTrim(RetTitle("E1_FILORIG"))				,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								TAMSX3("E1_FILORIG")[3]						,;	// [06]  C   Tipo do campo
								NIL											,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo
								
			oStruct:AddField(	"E1_XSALDO"				,;	// [01]  C   Nome do Campo
								Alltrim(Str(SE1->(FieldPos("E1_SALDO"))+1)),;	// [02]  C   Ordem
								AllTrim(RetTitle("E1_SALDO"))				,;	// [03]  C   Titulo do campo
								AllTrim(RetTitle("E1_SALDO"))				,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"N"											,;	// [06]  C   Tipo do campo
								PesqPict("SE1", "E1_SALDO")					,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo
								
			oStruct:AddField(	"E1_XVLRREAL"				,;	// [01]  C   Nome do Campo
								Alltrim(Str(SE1->(FieldPos("E1_VLRREAL"))+1)),;	// [02]  C   Ordem
								AllTrim(RetTitle("E1_VLRREAL"))				,;	// [03]  C   Titulo do campo
								AllTrim(RetTitle("E1_VLRREAL"))				,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"N"											,;	// [06]  C   Tipo do campo
								PesqPict("SE1", "E1_SALDO")					,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo
								
			oStruct:AddField(	"Conciliar"									,;	// [01]  C   Nome do Campo
								"01"										,;	// [02]  C   Ordem
								"Conciliar"									,;	// [03]  C   Titulo do campo
								"Conciliar"									,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								TAMSX3("E1_LOJA")[3]						,;	// [06]  C   Tipo do campo
								NIL											,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo
								
			oStruct:AddField(	"E1_XCARTAUT"								,;	// [01]  C   Nome do Campo
								Alltrim(Str(SE1->(FieldPos("E1_CARTAUT"))+1)),;	// [02]  C   Ordem
								AllTrim(RetTitle("E1_CARTAUT"))				,;	// [03]  C   Titulo do campo
								AllTrim(RetTitle("E1_CARTAUT"))				,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"C"											,;	// [06]  C   Tipo do campo
								PesqPict("SE1", "E1_CARTAUT")				,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo
	
		Elseif nFolder == 3 .Or. nFolder == 4
		
			oStruct:AddField(	"E1_XNSUTEF"								,;	// [01]  C   Nome do Campo
								Alltrim(Str(SE1->(FieldPos("E1_DOCTEF"))+1)),;	// [02]  C   Ordem
								AllTrim(RetTitle("E1_NSUTEF"))				,;	// [03]  C   Titulo do campo
								AllTrim(RetTitle("E1_NSUTEF"))				,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"C"											,;	// [06]  C   Tipo do campo
								PesqPict("SE1", "E1_NSUTEF")				,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo
								
			oStruct:AddField(	"E1_XDOCTEF"								,;	// [01]  C   Nome do Campo
								Alltrim(Str(SE1->(FieldPos("E1_DOCTEF"))+1)),;	// [02]  C   Ordem
								AllTrim(RetTitle("E1_DOCTEF"))				,;	// [03]  C   Titulo do campo
								AllTrim(RetTitle("E1_DOCTEF"))				,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"C"											,;	// [06]  C   Tipo do campo
								PesqPict("SE1", "E1_DOCTEF")				,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo
		
			oStruct:AddField(	"E1_XVALLIQ"								,;	// [01]  C   Nome do Campo
								Alltrim(Str(SE1->(FieldPos("E1_VALOR"))+1))	,;	// [02]  C   Ordem
								"Vlr Liquido"								,;	// [03]  C   Titulo do campo //"Vlr Liquido"
								"Vlr Liquido"								,;	// [04]  C   Descricao do campo //"Vlr Liquido"
								NIL											,;	// [05]  A   Array com Help
								"N"											,;	// [06]  C   Tipo do campo
								PesqPict("SE1", "E1_SALDO")					,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo

			oStruct:AddField(	"E1_XFILORI"								,;	// [01]  C   Nome do Campo
								Alltrim(Str(SE1->(FieldPos("E1_DOCTEF"))+1)),;	// [02]  C   Ordem
								AllTrim(RetTitle("E1_FILORIG"))				,;	// [03]  C   Titulo do campo
								AllTrim(RetTitle("E1_FILORIG"))				,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								TAMSX3("E1_FILORIG")[3]						,;	// [06]  C   Tipo do campo
								NIL											,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo
								
				oStruct:AddField(	"E1_XSALDO"				,;	// [01]  C   Nome do Campo
								Alltrim(Str(SE1->(FieldPos("E1_SALDO"))+1)),;	// [02]  C   Ordem
								AllTrim(RetTitle("E1_SALDO"))				,;	// [03]  C   Titulo do campo
								AllTrim(RetTitle("E1_SALDO"))				,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"N"											,;	// [06]  C   Tipo do campo
								PesqPict("SE1", "E1_SALDO")					,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo
								
			oStruct:AddField(	"E1_XVLRREAL"				,;	// [01]  C   Nome do Campo
								Alltrim(Str(SE1->(FieldPos("E1_VLRREAL"))+1)),;	// [02]  C   Ordem
								AllTrim(RetTitle("E1_VLRREAL"))				,;	// [03]  C   Titulo do campo
								AllTrim(RetTitle("E1_VLRREAL"))				,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"N"											,;	// [06]  C   Tipo do campo
								PesqPict("SE1", "E1_SALDO")					,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo
								
			oStruct:AddField(	"E1_XCARTAUT"								,;	// [01]  C   Nome do Campo
								Alltrim(Str(SE1->(FieldPos("E1_CARTAUT"))+1)),;	// [02]  C   Ordem
								AllTrim(RetTitle("E1_CARTAUT"))				,;	// [03]  C   Titulo do campo
								AllTrim(RetTitle("E1_CARTAUT"))				,;	// [04]  C   Descricao do campo
								NIL											,;	// [05]  A   Array com Help
								"C"											,;	// [06]  C   Tipo do campo
								PesqPict("SE1", "E1_CARTAUT")					,;	// [07]  C   Picture
								NIL											,;	// [08]  B   Bloco de Picture Var
								NIL											,;	// [09]  C   Consulta F3
								.F.											,;	// [10]  L   Indica se o campo é alteravel
								NIL											,;	// [11]  C   Pasta do campo
								NIL											,;	// [12]  C   Agrupamento do campo
								NIL											,;	// [13]  A   Lista de valores permitido do campo (Combo)
								NIL											,;	// [14]  N   Tamanho maximo da maior opção do combo
								NIL											,;	// [15]  C   Inicializador de Browse
								.T.											,;	// [16]  L   Indica se o campo é virtual
								NIL											,;	// [17]  C   Picture Variavel
								NIL											)	// [18]  L   Indica pulo de linha após o campo
			
		EndIf

	EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetProp
Ajuste nas Propriedades dos Campos da FIF

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static Function SetProp( oModel As Object, nOpcao As Numeric, oStruct As Object )
	//Bloqueia alteracoes em todos os campos
	//da grid com excecao do campo de selecao
	Do Case
	Case nOpcao == 1	//Model
		oStruct:SetProperty("*",	MODEL_FIELD_OBRIGAT, 	.F.)
		oStruct:SetProperty("*", 	MODEL_FIELD_WHEN, 		{|| .F. })
		oStruct:SetProperty("OK",	MODEL_FIELD_WHEN, 		{|| .T. })
	Case nOpcao == 2	//View
		oStruct:SetProperty("*", 	MVC_VIEW_CANCHANGE, .F.)
		oStruct:SetProperty("OK", 	MVC_VIEW_CANCHANGE, .T.)
	EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fLoadTot
Calculo dos Totais da Conciliacao

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static Function fLoadTot( oSubMod As Object ) As Array
	Local aRetorno	As Array
	Local aFields	As Array
	Local aAux		As Array
	Local aQry		As Array
	Local nField	As Numeric
	Local nX		As Numeric
	Local cTabQry	As Character
	Local cQuery	As Character
	Local dData		As Date

	aRetorno	:= {}
	aFields		:= oSubMod:GetStruct():GetFields()
	aAux		:= {}
	aQry		:= {}
	nField		:= 0
	nX			:= 0
	cQuery		:= ""
	dData		:= CtoD("")

	If __nFldPar == 0 .OR. __nFldPar == 1
		//Conciliado Normal
		cQuery := "SELECT	FIF.FIF_DTCRED			DATA" + CRLF
		cQuery += ",		'1'						ABA" + CRLF
		cQuery += ",		SUM(FIF.FIF_VLBRUT)		VALOR" + CRLF
		cQuery += ",		SUM(FIF.FIF_VLLIQ)		VLLIQ" + CRLF
		cQuery += ",		COUNT(FIF.FIF_DTCRED)	QUANT" + CRLF
		cQuery += "FROM		" + RetSqlName("FIF") + " FIF" + CRLF
		cQuery += "WHERE	FIF.D_E_L_E_T_  <> '*' " + CRLF
		cQuery += "AND " + GetFilter(1, "FIF") + CRLF
		cQuery += "GROUP BY FIF.FIF_DTCRED" + CRLF
		cQuery += "ORDER BY DATA, ABA" + CRLF
		aAdd(aQry, cQuery)

	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 2
		//--Conciliado parcialmente
		cQuery := "SELECT	FIF.FIF_DTCRED			DATA" + CRLF
		cQuery += ",		'2'						ABA" + CRLF
		cQuery += ",		SUM(FIF.FIF_VLBRUT)		VALOR" + CRLF
		cQuery += ",		SUM(FIF.FIF_VLLIQ)		VLLIQ" + CRLF
		cQuery += ",		COUNT(FIF.FIF_DTCRED)	QUANT" + CRLF
		cQuery += "FROM		" + RetSqlName("FIF") + " FIF" + CRLF
		cQuery += "WHERE	FIF.D_E_L_E_T_  <> '*' " + CRLF
		cQuery += "AND " + GetFilter(2, "FIF") + CRLF
		cQuery += "GROUP BY FIF.FIF_DTCRED" + CRLF
		cQuery += "ORDER BY DATA, ABA" + CRLF
		aAdd(aQry, cQuery)
	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 3
		//--Titulos sem Venda
		cQuery := "SELECT	FIF.FIF_DTCRED			DATA" + CRLF
		cQuery += ",		'3'						ABA" + CRLF
		cQuery += ",		SUM(FIF.FIF_VLBRUT)		VALOR" + CRLF
		cQuery += ",		SUM(FIF.FIF_VLLIQ)		VLLIQ" + CRLF
		cQuery += ",		COUNT(FIF.FIF_DTCRED)	QUANT" + CRLF
		cQuery += "FROM		" + RetSqlName("FIF") + " FIF" + CRLF
		cQuery += "WHERE	FIF.D_E_L_E_T_  <> '*' " + CRLF
		cQuery += "AND " + GetFilter(3, "FIF") + CRLF
		cQuery += "GROUP BY FIF.FIF_DTCRED" + CRLF
		cQuery += "ORDER BY DATA, ABA" + CRLF
		aAdd(aQry, cQuery)
	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 4
		//--Vendas sem Titulos
		cQuery := "SELECT	FIF.FIF_DTCRED			DATA" + CRLF
		cQuery += ",		'4'						ABA" + CRLF
		cQuery += ",		SUM(FIF.FIF_VLBRUT)		VALOR" + CRLF
		cQuery += ",		SUM(FIF.FIF_VLLIQ)		VLLIQ" + CRLF
		cQuery += ",		COUNT(FIF.FIF_DTCRED)	QUANT" + CRLF
		cQuery += "FROM		" + RetSqlName("FIF") + " FIF" + CRLF
		cQuery += "WHERE	FIF.D_E_L_E_T_ <> '*' " + CRLF
		cQuery += "AND " + GetFilter(4, "FIF") + CRLF
		cQuery += "GROUP BY FIF.FIF_DTCRED" + CRLF
		cQuery += "ORDER BY DATA, ABA" + CRLF
		aAdd(aQry, cQuery)
	EndIf

	If __nFldPar == 0 .OR. __nFldPar == 5
		//--Divergentes
		cQuery := "SELECT	FIF.FIF_DTCRED			DATA" + CRLF
		cQuery += ",		'5'						ABA" + CRLF
		cQuery += ",		SUM(FIF.FIF_VLBRUT)		VALOR" + CRLF
		cQuery += ",		SUM(FIF.FIF_VLLIQ)		VLLIQ" + CRLF
		cQuery += ",		COUNT(FIF.FIF_DTCRED)	QUANT" + CRLF
		cQuery += "FROM		" + RetSqlName("FIF") + " FIF" + CRLF
		cQuery += "WHERE	FIF.D_E_L_E_T_  <> '*' " + CRLF
		cQuery += "AND " + GetFilter(5, "FIF") + CRLF
		cQuery += "GROUP BY FIF.FIF_DTCRED" + CRLF
		cQuery += "ORDER BY DATA, ABA" + CRLF
		aAdd(aQry, cQuery)
	EndIf

	// Executa querys individualmente para evitar problemas com estouro de variável caso existam muitas filiais para serem filtradas (selecionadas no filtrar filiais "SIM")
	For nX := 1 to Len(aQry)

		cTabQry		:= GetNextAlias()
		If Select(cTabQry) > 0
			(cTabQry)->(DbCloseArea())
		EndIf

		cQuery := ChangeQuery(aQry[nX])

		
		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)
		

		While !(cTabQry)->(Eof())

			dData 		:= StoD((cTabQry)->DATA)
			If ( nPos:= aScan(aRetorno, {|x| x[2][1] == dData}) ) > 0
				aAux := aClone(aRetorno[nPos][2])
			Else
				aAux 		:= Array(Len(aFields))
				aAux[01]	:= dData
				For nField := 2 to Len(aAux)
					aAux[nField] := 0
				Next nField
			EndIf

			Do Case
				Case (cTabQry)->ABA == "1"
					aAux[Ascan(aFields, {|x| x[03] == "TOTFLD1"})] += (cTabQry)->VALOR
					aAux[Ascan(aFields, {|x| x[03] == "QTDFLD1"})] += (cTabQry)->QUANT
				Case (cTabQry)->ABA == "2"
					aAux[Ascan(aFields, {|x| x[03] == "TOTFLD2"})] += (cTabQry)->VALOR
					aAux[Ascan(aFields, {|x| x[03] == "QTDFLD2"})] += (cTabQry)->QUANT
				Case (cTabQry)->ABA == "3"
					aAux[Ascan(aFields, {|x| x[03] == "TOTFLD3"})] += (cTabQry)->VALOR
					aAux[Ascan(aFields, {|x| x[03] == "QTDFLD3"})] += (cTabQry)->QUANT
				Case (cTabQry)->ABA == "4"
					aAux[Ascan(aFields, {|x| x[03] == "TOTFLD4"})] += (cTabQry)->VALOR
					aAux[Ascan(aFields, {|x| x[03] == "QTDFLD4"})] += (cTabQry)->QUANT
				Case (cTabQry)->ABA == "5"
					aAux[Ascan(aFields, {|x| x[03] == "TOTFLD5"})] += (cTabQry)->VALOR
					aAux[Ascan(aFields, {|x| x[03] == "QTDFLD5"})] += (cTabQry)->QUANT
			EndCase
			aAux[Ascan(aFields, {|x| x[03] == "TOTTOT"})] += (cTabQry)->VALOR
			aAux[Ascan(aFields, {|x| x[03] == "QTDTOT"})] += (cTabQry)->QUANT

			If  nPos > 0
				aRetorno[nPos][2] := aClone(aAux)
			Else
				Aadd(aRetorno, {0 ,aAux})
				aAux	:= {}
			EndIf

			(cTabQry)->(dbSkip())

		End

		If Select(cTabQry) > 0
			(cTabQry)->(DbCloseArea())
		EndIf

	Next nX

	//Se não houver dados retorna um Array vazio
	If Len(aRetorno) == 0
		aAux 		:= Array(Len(aFields))
		aAux[01]	:= dDatabase
	
		For nField := 2 to Len(aAux)
			aAux[nField] := 0
		Next nField
	
		Aadd(aRetorno, {0 ,aAux})
	Else
		aRetorno := aSort(aRetorno,,,{|x,y| x[2][1] < y[2][1] })
	EndIf

	aAux		:= {}
	aQry        := {}
	aFields     := {}
Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldOk
Valida a Selecao do FIF x SE1

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static Function fVldOk( oModel As Object, cCampo As Character, lValue As Logical, lOldVal As Logical, nPasta As Numeric ) As Logical

	Local lRetorno	As Logical	
	Local nLinha	As Numeric
	Local nLinBkp	As Numeric
	Local nSelect	As Numeric
	Local nLinSave	As Numeric
	Local nLinFIF   As Numeric
	Local nLimCon	As Numeric
	Local cTipoSel	As Character
	Local cQuery	As Character
	Local cAliasZWX	As Character
	Local oView		As Object

	Default nPasta := 0
	Default lOldVal:= .F.

	lRetorno	:= .T.
	nSelect		:= 0
	nLinha		:= 0
	nLinBkp		:= 0
	nLimCon		:= SuperGetMv( "MV_XLIMCON"  , .T. , 9999 )
	cQuery		:= ""
	cAliasZWX	:= GetNextAlias()
	oView		:= FwViewActive()

	If nPasta == 8
		//Pasta pagamentos

		cQuery := "SELECT * FROM " + RetSqlTab("ZWX")
		cQuery += "WHERE ZWX.ZWX_FILIAL = '" + xFilial("ZWX") + "' "
		cQuery += "AND ZWX.ZWX_DATA = '" + DTOS(oModel:GetValue("FIF_DTTEF")) + "' "
		cQuery += "AND ZWX.D_E_L_E_T_ <> '*' " 

		cQuery := ChangeQuery(cQuery)

		If Select(cAliasZWX) > 0
			(cAliasZWX)->(DbCloseArea())
		EndIf

		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasZWX, .T., .T.)

		If (cAliasZWX)->(Eof())
			nSelect := 3
		Else
		
			//Permite selecionar para baixar apenas se o registro ja foi conciliado
			DbSelectArea("FIF")
			FIF->(DbOrderNickName("CONC"))
			If FIF->(DbSeek(oModel:GetValue("FIF_CODFIL")+oModel:GetValue("FIF_NSUTEF")+DTOS(oModel:GetValue("FIF_DTTEF"))+AllTrim(Str(oModel:GetValue("FIF_VLBRUT")))))
				If oModel:GetValue("FIF_STATUS") $ "2|4"
					nSelect := 2
				EndIf
				
				If nSelect == 0
					While !FIF->(Eof()) .And. oModel:GetValue("FIF_CODFIL")+oModel:GetValue("FIF_NSUTEF")+DTOS(oModel:GetValue("FIF_DTTEF"))+AllTrim(Str(oModel:GetValue("FIF_VLBRUT"))) == FIF->(FIF_CODFIL+FIF_NSUTEF+DTOS(FIF_DTTEF)+AllTrim(Str(FIF_VLBRUT)))  
						If !(FIF->FIF_STATUS $ '2|4') .And. Alltrim(FIF->FIF_TPREG) == '1'
							nSelect := 1
							Exit
						EndIf
						FIF->(DbSkip())
					EndDo
				EndIf
			EndIf

		EndIf

		If nSelect > 0
			lRetorno := .F.
			If nSelect == 1				
				Help(NIL, NIL, "fVldOk", NIL, "Registro n�o conciliado. N�o � permitido selecionar.", 1, 0) 
			ElseIf nSelect == 2
				Help(NIL, NIL, "fVldOk", NIL, "Registro ja baixado. N�o � permitido selecionar.", 1, 0) 
			ElseIf nSelect == 3
				Help(NIL, NIL, "fVldOk", NIL, "Per�odo n�o esta fechado. Executar o fechamento.", 1, 0) 
			EndIf
		EndIf

	ElseIf nPasta == 0
		//Pasta conciliados

		//Permite selecionar para conciliar apenas se o registro nao foi conciliado
		DbSelectArea("FIF")
		FIF->(DbOrderNickName("CONC"))
		If FIF->(DbSeek(oModel:GetValue("FIF_CODFIL")+oModel:GetValue("FIF_NSUTEF")+DTOS(oModel:GetValue("FIF_DTTEF"))+AllTrim(Str(oModel:GetValue("FIF_VLBRUT")))))
			If oModel:GetValue("FIF_STATUS") $ "2|4"
				lRetorno := .F.
				Help(NIL, NIL, "fVldOk", NIL, "Registro ja conciliado. N�o � permitido selecionar.", 1, 0) 
			EndIf
		EndIf

	ElseIf nPasta == 4
		
		//Pasta conciliados manualemnte
		If oModel:GetValue("OK")
			If oModel:cid == "FIFFLD4"	
				
				nLinSave 	:= oModel:GetLine()
				cTipoSel	:= oModel:GetValue("FIF_TPPROD")
				__nValFIF	:= 0
				//#TB20200313 Thiago Berna - verifica se todos os registros s�o do mesmo tipo
				For nLinFIF := 1 to oModel:Length()
					oModel:GoLine(nLinFIF)
					If oModel:GetValue("OK")
						If !oModel:GetValue("FIF_TPPROD") == cTipoSel
							lRetorno := .F.
							Help(NIL, NIL, "FVLDOK", NIL, "Selecionar registros de apenas um tipo para concilia��o.", 1, 0)								
							Exit
						EndIf
					EndIf
				Next nLinFIF

				For nLinFIF := 1 to oModel:Length()
					oModel:GoLine(nLinFIF)

					If lRetorno
						If oModel:GetValue("OK")
							__nValFIF += oModel:GetValue("FIF_VLBRUT")
						EndIf
					Else
						If oModel:GetValue("OK") .And. !oModel:GetValue("FIF_TPPROD") == cTipoSel
							__nValFIF += oModel:GetValue("FIF_VLBRUT")
						EndIf
					EndIf

				Next nLinFIF


				oModel:GoLine(nLinSave)

			Else
				__nValSE1 += oModel:GetValue("E1_VALOR")
				//#TB20200813 Definido parametro de controle de limite de registros selecionados
				If __nQtdSE1 + 1 <= nLimCon
					__nQtdSE1++
				Else
					lRetorno := .F.
					Help(NIL, NIL, "FVLDOK", NIL, "Permitido selecionar at� " + AllTrim(Str(nLimCon)) + " Registros. Parametro MV_XLIMCON", 1, 0)	
				EndIf
			EndIf
		Else
			If oModel:cid == "FIFFLD4"
				__nValFIF -= oModel:GetValue("FIF_VLBRUT")
			Else
				__nValSE1 -= oModel:GetValue("E1_VALOR")
				__nQtdSE1--
			EndIf
		EndIf

		__oValFIF:Refresh()
		//oView:Refresh("FIFFLD4")
		//oView:Refresh("SE1FLD4")
		//View:Refresh()

	EndIf

	//#TB20200214 Thiago Berna - Ajuste para permitir selecionar mais de um registro para conciliar
	/*If lValue
		nLinBkp	:= oModel:GetLine()
		For nLinha := 1 to oModel:Length()
			oModel:GoLine(nLinha)
			If nLinha <> nLinBkp
				If oModel:GetValue("OK")
					lRetorno := .F.
					Help(NIL, NIL, "FVLDOK", NIL, "Selecionar apenas um registro por vez para concilia��o.", 1, 0)	//"Selecionar apenas um registro por vez para conciliação."
				EndIf
			EndIf
		Next nLinha
		oModel:GoLine(nLinBkp)
	EndIf*/

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} OIF910Sel
Grava em uma String as Administradoras Selecionadas

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
/*Static Function OIF910Sel( cArqTrb As Character, cMvPar As Character ) As Logical
	Local lRet		As Logical
	Local nRecno	As Numeric
	Local nX		As Numeric
	Local nTam		As Numeric
	Local nVarTam	As Numeric
	Local nTotTam	As Numeric
	Local nMaxTam	As Numeric
	Local aParLin	As Array

	Default cArqTrb := ""
	Default cMvPar 	:= Alltrim(ReadVar())

	lRet	:= .T.
	nRecno	:= 0
	nX		:= 0
	nTam	:= 0
	nVarTam	:= 0
	nTotTam	:= 0
	nMaxTam	:= 60	
	aParLin	:= {}
	
	dbSelectArea(cArqTrb)
	nRecno := (cArqTrb)->(RecNo())
	(cArqTrb)->(DbGoTop())
	
	__cAdmFin 	:= ""
	While !(cArqTrb)->(Eof())
		If !Empty((cArqTrb)->MDE_OK)
			__cAdmFin += If(nX > 0, ";" + (cArqTrb)->MDE_CODIGO, (cArqTrb)->MDE_CODIGO )
			nX++
		EndIf
		(cArqTrb)->(DbSkip())
	EndDo

	// Efetua a validação da quantidade de empresas selecionadas para evitar estouro no parâmetro e error.log na query
	aParLin  := StrToArray( Alltrim(__cAdmFin) ,";")
	For nX := 1 to Len(aParLin)
		nVarTam := Len(Alltrim(aParLin[nX])) + 1
		If ( nTotTam + nVarTam ) <= nMaxTam
			nTotTam += nVarTam
		Else
			lRet := .F.
			Help(NIL, NIL, "OIF910Sel", NIL, "Limite de sele��o de empresas excedido para o par�metro  da rotina (Max 60 Caracteres).", 1, 0) //"Limite de seleção de empresas excedido para o parâmetro  da rotina (Max 60 Caracteres)."
			Exit
		EndIf
	Next nX

	(cArqTrb)->(DbGoTo(nRecno))

	If lRet
		lRet := Iif(Len(__cAdmFin) > 0, .T., .F.)
		&(cMvPar) := __cAdmFin
	EndIf
	
Return lRet*/

//-------------------------------------------------------------------
/*/{Protheus.doc} U_OIF910MrkAll
Marca ou Desmarca todas as Administradoras

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
User Function OIF910MrkAll( oMrkBrw As Object, cArqTrb As Character )// As Logical
	Local cMarca As Character
	
	cMarca := oMrkBrw:Mark()
	
	DbSelectArea( cArqTrb )
	(cArqTrb)->( DbGoTop() )
	
	While !(cArqTrb)->( Eof() )
		
		RecLock( cArqTrb, .F. )
		
		If (cArqTrb)->MDE_OK == cMarca
			(cArqTrb)->MDE_OK := " "
		Else
			(cArqTrb)->MDE_OK := cMarca
		EndIf
		
		MsUnlock()
		(cArqTrb)->(DbSkip())	
	EndDo
	
	(cArqTrb)->(DbGoTop())
	oMrkBrw:oBrowse:Refresh(.T.)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} OIF910Perg
Pergunte da tela de conciliação de vendas

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static Function OIF910Perg() As Logical
	Local lRet As Logical
	Local lCancel As Logical
	Local cConc	As Numeric
	Local cPerg	As Character

	lRet	:= .T.
	lCancel	:= .T.
	cConc	:= 0
	cPerg	:= ""

	// Define qual operadora para a conciliação
	/*nConc	:= Aviso("Concilia��o", "Por favor, definir operadora para a concilia��o: ",;
	 			{ "Demais", "Software Express", "Cancelar" }, 2, ) //"Conciliação"###"Por favor, definir operadora para a conciliação: "###"Demais"###"Software Express"###"Cancelar"
	__lSOFEX	:= ( nConc == 2 )
	lCancel	:= ( nConc == 3 )*/
	nConc	:= Aviso("Concilia��o", "Por favor, definir operadora para a concilia��o: ",;
	 			{ "Software Express", "Cancelar" }, 2, ) //"Conciliação"###"Por favor, definir operadora para a conciliação: "###"Demais"###"Software Express"###"Cancelar"
	__lSOFEX	:= ( nConc == 1 )
	lCancel	:= ( nConc == 2 )

	If !lCancel
		
		If __lSOFEX
			//#TB20191218 Thiago Berna - Ajuste para carregar os parametros
			//cPerg := "FINA910A" // Software Express
			cPerg := "FINA910OI" // Software Express
		Else
			cPerg := "FINA910A1"  // Demais operadoras
		EndIf

		lRet := Pergunte(cPerg, .T.)	

	Else
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} OIF910Print
Pergunte da tela de conciliação de tef

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static Function OIF910Print(oView As Object)
	Local oModel 	 As Object
	Local oModGrid1	 As Object
	Local oModGrid2	 As Object
	Local aPlanilha  As Array
	Local aStructFIF As Array
	Local aStructSE1 As Array
	Local aColsFIF 	 As Array
	Local aColsSE1 	 As Array
	Local aAux	 	 As Array
	Local nL		 As Numeric
	Local nX		 As Numeric
	Local nZ		 As Numeric
	Local nSheetAct  As Numeric
	Local cNameSheet As Character
	Local cGrid1  	 As Character
	Local cGrid2	 As Character
	Local cConteudo	 As Character
	Local cCpoCbx	 As Character
	Local lConcTotP  As Logical

	Default oView  := FwViewActive()

	oModel 		:= oView:GetModel()
	oModGrid1	:= Nil
	oModGrid2	:= Nil
	nSheetAct	:= oView:GetFolderActive("FOLGRIDS", 2)[1]
	cNameSheet	:= Alltrim(oView:GetFolderActive("FOLGRIDS", 2)[2])
	aPlanilha 	:= {}
	aStructFIF 	:= {}
	aStructSE1 	:= {}
	aColsFIF	:= {}
	aColsSE1	:= {}
	aAux		:= {}
	nL			:= 0
	nX			:= 0
	nZ			:= 0
	cGrid1 		:= ""
	cGrid2 		:= ""
	cConteudo	:= ""
	cCpoCbx		:= "FIF_STATUS"
	lConcTotP	:= .F.

	If __nFldPar == 0

		If nSheetAct == 1
			cGrid1 := "FIFFLD1"
			cGrid2 := "SE1FLD1"
		ElseIf nSheetAct == 2
			cGrid1 := "FIFFLD2"
			cGrid2 := "SE1FLD2"	
		ElseIf nSheetAct == 3
			cGrid1 := "SE1FLD3"
		ElseIf nSheetAct == 4
			cGrid1 := "FIFFLD4"
			cGrid2 := "SE1FLD4"
		ElseIf nSheetAct == 5
			cGrid1 := "FIFFLD5"
		ElseIf nSheetAct == 6
			cGrid1 := "TOTFLD6"
		EndIf

		lConcTotP := nSheetAct == 1 .Or. nSheetAct == 2
	
	Else

		If nSheetAct == 2
			cGrid1 := "TOTFLD6"
		ElseIf __nFldPar == 1
			cGrid1 := "FIFFLD1"
			cGrid2 := "SE1FLD1"
			lConcTotP := .T.
		ElseIf __nFldPar == 2
			cGrid1 := "FIFFLD2"
			cGrid2 := "SE1FLD2"	
			lConcTotP := .T.
		ElseIf __nFldPar == 3
			cGrid1 := "SE1FLD3"
		ElseIf __nFldPar == 4
			cGrid1 := "FIFFLD4"
			cGrid2 := "SE1FLD4"
		ElseIf __nFldPar == 5
			cGrid1 := "FIFFLD5"
		EndIf

	EndIf

	If !Empty(cGrid1)
		aColsFIF := {}
		oModGrid1 	:= oModel:GetModel(cGrid1)
		aStructFIF 	:= oModGrid1:GetStruct():GetFields()

		If lConcTotP .And. !Empty(cGrid2)
			aColsSE1 := {}
			oModGrid2 	:= oModel:GetModel(cGrid2)
			aStructSE1 	:= oModGrid2:GetStruct():GetFields()
		EndIf
		
		For nL := 1 to oModGrid1:Length()
			oModGrid1:GoLine(nL)
			aAux 	 := {}
			For nX := 1 to Len(aStructFIF)
				If Alltrim(aStructFIF[nX][3]) $ cCpoCbx
					cConteudo := Alltrim(X3Combo(aStructFIF[nX][3], oModGrid1:GetValue(aStructFIF[nX][3])))
				Else
					cConteudo := oModGrid1:GetValue(aStructFIF[nX][3])
				EndIf
				aAdd(aAux, cConteudo)
			Next nX
			aAdd(aColsFIF, aAux)

			If lConcTotP .And. !Empty(cGrid2)
				For nZ := 1 to oModGrid2:Length()
					oModGrid2:GoLine(nZ)
					aAux 	 := {}
					For nX := 1 to Len(aStructSE1)
						If Alltrim(aStructSE1[nX][3]) $ cCpoCbx
							cConteudo := Alltrim(X3Combo(aStructSE1[nX][3], oModGrid2:GetValue(aStructSE1[nX][3])))
						Else
							cConteudo := oModGrid2:GetValue(aStructSE1[nX][3])
						EndIf
						aAdd(aAux, cConteudo)
					Next nX
					aAdd(aColsSE1, aAux)
				Next nZ
			EndIf

		Next nL
		aAdd(aPlanilha, {aStructFIF, aColsFIF} )
		If Len(aColsSE1) > 0
			aAdd(aPlanilha, {aStructSE1, aColsSE1} )
		EndIf
	Endif

	If !lConcTotP .And. !Empty(cGrid2)
		aColsSE1 := {}
		oModGrid2 	:= oModel:GetModel(cGrid2)
		aStructSE1 	:= oModGrid2:GetStruct():GetFields()
		For nL := 1 to oModGrid2:Length()
			oModGrid2:GoLine(nL)
			aAux 	 := {}
			For nX := 1 to Len(aStructSE1)
				If Alltrim(aStructSE1[nX][3]) $ cCpoCbx
					cConteudo := Alltrim(X3Combo(aStructSE1[nX][3], oModGrid2:GetValue(aStructSE1[nX][3])))
				Else
					cConteudo := oModGrid2:GetValue(aStructSE1[nX][3])
				EndIf
				aAdd(aAux, cConteudo)
			Next nX
			aAdd(aColsSE1, aAux)
		Next nL
		aAdd(aPlanilha, {aStructSE1, aColsSE1} )
	EndIf

	// Imprime a Grid
	If Len(aPlanilha) > 0
		FWMsgRun(/*oComponent*/,{|| U_F910EXCEL(aPlanilha, "OIFINA910", "Concilia��o TEF" + " - " + cNameSheet) }, "Concilia��o TEF", "Por favor, aguarde. Imprimindo..." )  //"Conciliação TEF"###"Por favor, aguarde. Imprimindo..."
	EndIf
 
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} OIF910Jus
Gatilho da descrição da justificativa

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static function OIF910Jus (oModel As Object) As Character 
	Local cDesc	As Character
	Local cCod 	As Character	

	cCod := oModel:GetValue("FIF_PGJUST")
	cDesc := Posicione("FVX",1,xFilial("FVX")+cCod,'FVX_DESCRI')
	
Return cDesc


//-------------------------------------------------------------------
/*/{Protheus.doc} OIF910JuX
Gatilho da descrição da justificativa

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
/*Static function OIF910JuX (oModel As Object) As Character 
	Local cDesc	As Character
	Local cCod 	As Character	

	cCod := oModel:GetValue("FIF_XCODJU")
	cDesc := Posicione("FVX",1,xFilial("FVX")+cCod,'FVX_DESCRI')
	
Return cDesc*/


//-------------------------------------------------------------------
/*/{Protheus.doc} U_F910CHKMOD
Retorna se tabela é exclusiva ou compartilhada

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
User Function F910ChkMod(cTabela) //As Logical
	Local lExclusivo As Logical
	Local cEmpComp 	 As Character
	Local cUnNegComp As Character
	Local cFilcomp 	 As Character
	
	Default cTabela	:= ""

	lExclusivo 	:= .F.
	If !Empty(cTabela)
		cEmpComp 	:= FWModeAccess(cTabela,1)
		cUnNegComp 	:= FWModeAccess(cTabela,2)
		cFilcomp 	:= FWModeAccess(cTabela,3)

		If cEmpComp == "E" .And. cUnNegComp == "E" .And. cFilcomp == "E"
			lExclusivo := .T.
		EndIf
	EndIf	

Return lExclusivo


//-------------------------------------------------------------------
/*/{Protheus.doc} OIF910VChk
Valida a marcacao de registros na tela Tit. S/ Venda para não permitir 
selecionar registros com NSU Branco

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
/*Static Function OIF910VChk(oModGrid As Object) As Logical
	Local lRet As Logical

	lRet	:= .T.

	If Empty(oModGrid:GetValue("E1_NSUTEF"))
		lRet := .F.
		oModGrid:GetModel():SetErrorMessage('SE1FLD3', 'OK' , 'SE1FLD3' , 'OK' , "OIF910VChk", ;
												'N�o � permitido marcar/efetivar t�tulos sem preenchimento para o campo abaixo: ' + CRLF + CRLF +;
												"Campo: " + AllTrim(RetTitle("E1_NSUTEF")) + CRLF +;
												'Aba: ' + "N�o Conciliadas" ) //'Não é permitido marcar/efetivar títulos sem preenchimento para o campo abaixo: '###"Campo: "###'Aba: '###"Titulos sem Vendas"
	EndIf

Return lRet*/


//-------------------------------------------------------------------
/*/{Protheus.doc} OIF910VTef
Pega o valor do FIF_VLLIQ e insere na grid da SE1 para confrontar os valores.

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
/*Static Function OIF910VTef(oView, nOpc)
	Local oModel As Object
	Local oModSE1 As Object
	Local oModFIF As Object
	Local cSE1Painel As Character
	Local cFIFPainel As Character

	Default oView 		:= FwViewActive()
	Default nOpc		:= 1

	If nOpc == 1
		cSE1Painel	:= "SE1FLD1"
		cFIFPainel	:= "FIFFLD1"
	ElseIf nOpc == 2
		cSE1Painel	:= "SE1FLD2"
		cFIFPainel	:= "FIFFLD2"
	ElseIf nOpc == 3
		cSE1Painel	:= "SE1FLD3"
		cFIFPainel	:= "FIFFLD3"	
	EndIf

	oModel	:= FWModelActivate() 
	oModSE1:= oModel:GetModel(cSE1Painel)
	oModFIF := oModel:GetModel(cFIFPainel)
	
	oModSE1:SetNoUpdateLine(.F.)
	
	//#TB20200206 Thiago Berna - Ajuste para remover o campo
	//oModSE1:SetValue("E1_XVLRTEF",oModFIF:GetValue('FIF_VLLIQ'))
	
	oModSE1:SetNoUpdateLine(.T.)

	oView:Refresh(cSE1Painel)

Return*/


//-------------------------------------------------------------------
/*/{Protheus.doc} U_F910EXCEL
Exportação da GRID em arquivo XML

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
User Function F910Excel(aWorkSheet, cOrigem, cTitulo, aTabDePara) //As Logical
	Local cWorkSheet	As Character
	Local cTable		As Character
	Local cArqXml		As Character
	Local cArqXLS		As Character
	Local cAlias		As Character
	Local cNomeAlias	As Character
	Local cNameCol 		As Character
	Local cCampo 		As Character
	Local cTipo		 	As Character
	Local cCpoExc	 	As Character
	Local oExcel		As Object
	Local nA			As Numeric
	Local nH			As Numeric
	Local nX			As Numeric
	Local nAlign	 	As Numeric
	Local nFormat		As Numeric
	Local lRet			AS Logical
	Local aAux			AS Array
	Local cArqZip 		:= cUserName+"_"+DtoS(Ddatabase)+cHora+".zip"

	Default aWorkSheet	:= {}
	Default cOrigem		:= ""
	Default cTitulo		:= ""
	Default aTabDePara	:= {}
	
	cWorkSheet	:= ""
	cTable		:= ""
	cArqXml		:= cOrigem + '_' + Dtos( dDataBase ) + '_' + StrTran( Time(), ':', '' ) +'.xml'
	If __lSmtHTML
		cArqXLS 	:= GetTempPath( .T. )
	Else
		cArqXLS 	:= cGetFile('',"Selecione o Diret�rio",0,,.F.,GETF_LOCALHARD+ GETF_RETDIRECTORY+GETF_NETWORKDRIVE) //"Selecione o Diretório"
	EndIf
	cAlias		:= ""
	cNomeAlias	:= ""
	cNameCol	:= ""
	cCampo 		:= ""
	cTipo		:= ""
	oExcel		:= Nil
	nA 			:= 0
	nH 			:= 0
	nX 			:= 0
	nAlign	 	:= 0
	nFormat		:= 0
	lRet		:= .F.
	aAux		:= {}
	cCpoExc 	:= "FIF_FILIAL/E1_FILIAL/E1_FILORIG/E1_SALDO/OK"
	aAdd(aTabDePara, {"FIF", "FIF"})
	aAdd(aTabDePara, {"E1", "SE1"})

	If !Empty(cArqXLS) .And. Len(aWorkSheet) > 0
	 	
		oExcel := FwMsExcel():New()

		For nX := 1 to Len(aWorkSheet)

			cNomeAlias 	:= ""
			aHeader 	:= aClone(aWorkSheet[nX][1])
			aCols 		:= aClone(aWorkSheet[nX][2])

			If Len(aHeader) > 0
				cAlias := SubStr(aHeader[1][3], 1, (At("_",aHeader[1][3])-1))
				If ( nPos := aScan(aTabDePara, {|x| x[1] == cAlias}) ) > 0
					cAlias := aTabDePara[nPos][2]
					cNomeAlias := Lower(Alltrim(FWX2NOME(cAlias)))
					cNomeAlias := Upper(LEFT(cNomeAlias,1))+Substr(cNomeAlias,2,Len(cNomeAlias)-1)
				Else
					cNomeAlias := cAlias
				EndIf
				cTable := cTitulo + Iif(!Empty(cNomeAlias), " - " + cNomeAlias, "")
				cWorkSheet	:= cOrigem + Iif(!Empty(cNomeAlias), " - " + cNomeAlias, "")

				oExcel:AddWorkSheet( cWorkSheet )
				oExcel:AddTable( cWorkSheet, cTable )

				For nH := 1 to Len(aHeader)

					cCampo 	 := Alltrim(aHeader[nH][3])
					If !(cCampo $ cCpoExc )

						cNameCol := aHeader[nH][1]
						cTipo	 := aHeader[nH][4]
						nAlign	 := IIf( cTipo == 'N', 3, 1 ) //Alinhamento da coluna ( 1-Left,2-Center,3-Right )

						//Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )	
						If cTipo == 'C'
							nFormat	 := 1
						ElseIf cTipo == 'D'
							nFormat	 := 4
						Else
							nFormat	 := 2
						EndIf

						oExcel:AddColumn( cWorkSheet, cTable, cNameCol, nAlign, nFormat, .F. )

					EndIf

				Next nH

				For nA := 1 to Len(aCols)
					aAux := {}
					For nH := 1 to Len(aHeader)
						cCampo 	 := Alltrim(aHeader[nH][3])
						If !(cCampo $ cCpoExc )
							Aadd( aAux, aCols[nA][nH] )
						EndIf
					Next nH
					oExcel:AddRow( cWorkSheet, cTable, aAux )
				Next nA
			EndIf

		Next nX	

		oExcel:Activate()
		oExcel:GetXMLFile( cArqXml )

		If ( CpyS2T ( cArqXml, cArqXLS, .T. ) )
			lRet := .T.
			MsgInfo("Arquivo gerado com sucesso:"+' "' + cArqXml + '" ') //"Arquivo gerado com sucesso:"
		Else
			Alert("N�o foi poss�vel gravar o arquivo!") //"Não foi possível gravar o arquivo!"
		EndIf

		If File( cArqXml )
			FErase( cArqXml )
		EndIf
	
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} OIF910Lck
Controle de concorrência para efetivação da conciliação - lock de seleção

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static Function OIF910Lck(oModGrid, nGrid,nFolder)
	Local lRet 		As Logical
	Local lTravou 	As Logical
	Local cQuery 	As Character
	Local cTabQry 	As Character
	Local cMsg 		As Character
	Local nOpc 		As Numeric
	
	Local cMSFIL	:= ""
	Local cFilSitef := ""
    Local cMVParTef := ""
    Local aParName	:= A910ParName() // resgata parametro x cod. administradora 

	Default oModGrid 	:= Nil
	Default nGrid		:= 1
	Default nFolder		:= 0

	lRet 	:= .T.
	lTravou := .F.
	cQuery 	:= ""
	cTabQry	:= CriaTrab(Nil, .F.)
	cMsg 	:= ""
	nOpc 	:= 1

	If nGrid == 1

		cQuery := " SELECT R_E_C_N_O_ RECNO " + CRLF
		cQuery += " FROM "+RetSqlName("FIF") + CRLF
		cQuery += " WHERE FIF_DTCRED  = '" + DtoS(oModGrid:GetValue("FIF_DTCRED")) +"' " + CRLF
		cQuery += "   AND FIF_NSUTEF  = '" + oModGrid:GetValue("FIF_NSUTEF") +"' " + CRLF
		cQuery += "   AND FIF_PARCEL  = '" + oModGrid:GetValue("FIF_PARCEL") +"' " + CRLF
		cQuery += "   AND FIF_CODFIL  = '" + oModGrid:GetValue("FIF_CODFIL") +"' " + CRLF
		cQuery += "   AND FIF_DTTEF   = '" + DtoS(oModGrid:GetValue("FIF_DTTEF"))  +"' " + CRLF
		cQuery += "   AND D_E_L_E_T_  <> '*' " + CRLF
		cQuery := ChangeQuery(cQuery)

		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTabQry,.F.,.T.)
		

		If !(cTabQry)->( Eof() ) .And. (cTabQry)->RECNO > 0
			dbSelectArea("FIF")
			FIF->( dbGoTo( (cTabQry)->RECNO) )
			
			If cMSFIL <> oModGrid:GetValue("FIF_CODFIL") .Or. cAdmAtu <> Alltrim(oModGrid:GetValue("FIF_CODADM"))
                cFilSitef := ""
                cMVParTef := ""

				cAdmAtu := Alltrim(oModGrid:GetValue("FIF_CODADM"))
				nPos := aScan(aParName, {|x| x[1] == cAdmAtu})
				If nPos > 0
					cMVParTef := aParName[nPos][2]
				EndIf

                If !Empty(cMVParTef) .And. SX6->(MSSeek( oModGrid:GetValue("FIF_CODFIL") + cMVParTef ))
                    cIdioma := Iif(__Language == "PORTUGUESE", "1",Iif(__Language == "SPANISH", "2", "3"))
                    cFilSitef := AllTrim(Iif(cIdioma == "1",SX6->X6_CONTEUD,Iif(cIdioma == "2",SX6->X6_CONTSPA,SX6->X6_CONTENG)))
                    cMSFIL := oModGrid:GetValue("FIF_CODFIL")
                ElseIf lMsgTef
                	lMsgTef:= MsgYesNo("N�o existe o par�metro MV_EMPTEF|MV_EMPTAME|MV_EMPTCIE|MV_EMPTRED para a Empresa/Filial " + ': "' + Alltrim(oModGrid:GetValue("FIF_CODFIL")) + '"' + ". O movimento não será conciliado. Continua exibindo alerta?") // "Não existe o parâmetro MV_EMPTEF|MV_EMPTAME|MV_EMPTCIE|MV_EMPTRED para a Empresa/Filial " ## ". O movimento não será conciliado. Continua exibindo alerta?"   
                EndIf
            EndIf

			If !oModGrid:GetValue("OK") // Se estiver selecionado e está desmarcando efetua a liberação do lock de seleção
				//#TB20200207 Thiago Berna - Ajuste para manter o registro bloqueado na Thread
				//FIF->( dbRUnlock( FIF->( Recno() ) ) )
			Else
				cMsg :=  CRLF + " Data Credito: " + DtoC(FIF->FIF_DTCRED) + CRLF + " " + "NSU Sitef: " + FIF->FIF_NSUTEF + CRLF + " " + "Parcela: " + FIF->FIF_PARCEL //" Data Venda: "###"NSU Sitef: "###"Parcela: "
				While !lTravou .And. nOpc == 1 
					//Verifica se o item ainda continua aberto para CONCILIAÇÃO, pode ter sido CONCILIADO em outra sessão
					//If FIF->FIF_STATUS == '1' // 1-Nao Processado
						//#TB20200207 Thiago Berna - Ajuste para manter o registro bloqueado na Thread
						//If FIF->( dbRLock( FIF->( Recno() ) ) )
						If aScan(FIF->(DBRLockList()), {|x| x == FIF->( Recno() )}) > 0 
							lTravou := .T.
						Else
							nOpc := AVISO("Controle de Concorr�ncia", "Item em uso por outra sess�o e n�o poder� ser selecionado."; //"Controle de Concorrência"###"Item em uso por outra sessão e não poderá ser selecionado."
														+ CRLF + "O que deseja efetuar? " + CRLF + cMsg, ; //"O que deseja efetuar? "
														{ "Tentar Novamente?", "Desconsiderar item"}, 2)  //"Tentar Novamente?"###"Desconsiderar item"
						EndIf
					/*Else
						Help(,,"OIF910Lck",,"Outro processo utilizou o item enquanto este não estava marcado, não será permitido conciliar este item.",1,0,,,,,,{"Item não liberado para seleção."}) //"Outro processo utilizou o item enquanto este não estava marcado, não será permitido conciliar este item."###"Item não liberado para seleção."
						nOpc := 3
					EndIf*/	
				EndDo

				If nOpc == 2
					oModGrid:GetModel():SetErrorMessage(oModGrid:cID, 'OK', oModGrid:cID, 'OK', "OIF910VChk", "Sele��o desconsiderada.") //"Seleção desconsiderada."
				EndIf

				lRet := lTravou

			EndIf

		EndIf
		
		(cTabQry)->( dbCloseArea() )
	
	Else

		SE1->( dbSetOrder(1) ) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If SE1->( dbSeek( xFilial("SE1", oModGrid:GetValue("E1_XFILORI") ) + oModGrid:GetValue("E1_PREFIXO") + oModGrid:GetValue("E1_NUM") + oModGrid:GetValue("E1_PARCELA") + oModGrid:GetValue("E1_TIPO") ) ) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

			If !oModGrid:GetValue("OK") // Se estiver selecionado e está desmarcando efetua a liberação do lock de seleção
				//#TB20200207 Thiago Berna - Ajuste para manter o registro bloqueado na Thread
				//SE1->( dbRUnlock( SE1->( Recno() ) ) )
			Else
				cMsg :=  " " + "Prefixo: " + SE1->E1_PREFIXO + CRLF + " " + "Num. Título: " + SE1->E1_NUM + CRLF + " " + "Parcela: " + SE1->E1_PARCELA + CRLF + " " + "Tipo: " + SE1->E1_TIPO 
				//"Prefixo: " "###"Num. Título: "###"Parcela: "###"Tipo: ""
				While !lTravou .And. nOpc == 1 
					cQuery := " SELECT FIF_STATUS, R_E_C_N_O_ RECNO " + CRLF
					cQuery += " FROM "+RetSqlName("FIF") + CRLF
					//#TB20200127 Thiago Berna - Ajuste para considerar o campo E1_XDTCAIX ao inves do campo E1_EMISSAO
					//cQuery += " WHERE FIF_DTTEF   = '" + DtoS(SE1->E1_EMISSAO) +"' " + CRLF
					cQuery += " WHERE FIF_DTTEF   = '" + DtoS(SE1->E1_XDTCAIX) +"' " + CRLF
					
					//#TB20200212 Thiago Berna - Ajuste para melhoria de desempenho
					//cQuery += "   AND FIF_NSUTEF  = '" + PADL(ALLTRIM(SE1->E1_NSUTEF),VAL(__cTamNSU),"0")  +"' " + CRLF
					cQuery += "   AND FIF_NSUTEF  = '" + SE1->E1_NSUTEF  + "' " + CRLF

					cQuery += "   AND FIF_PARALF  = '" + SE1->E1_PARCELA + "' " + CRLF
					cQuery += "   AND FIF_CODFIL  = '" + SE1->E1_MSFIL +"' " + CRLF
					cQuery += "   AND D_E_L_E_T_  <> '*' " + CRLF
					cQuery := ChangeQuery(cQuery)

					if Select(cTabQry) > 0
						(cTabQry)->( dbCloseArea() )
					endif

					
					dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTabQry,.F.,.T.)
					
								
					If !(cTabQry)->( Eof() ) .And. !Empty( (cTabQry)->FIF_STATUS )
						dbSelectArea("FIF")
						FIF->( dbGoTo( (cTabQry)->RECNO) )

						//Verifica se o item ainda continua aberto para CONCILIAÇÃO, pode ter sido CONCILIADO em outra sessão
						//If (cTabQry)->FIF_STATUS == '1' // 1-Nao Processado
							//#TB20200207 Thiago Berna - Ajuste para manter o registro bloqueado na Thread
							//If SE1->( dbRLock( SE1->( Recno() ) ) )
							If aScan(SE1->(DBRLockList()), {|x| x == SE1->( Recno() )}) > 0 
								lTravou := .T.
							Else
								nOpc := AVISO("Controle de Concorr�ncia", "Item em uso por outra sess�o e n�o poder� ser selecionado."; //"Controle de Concorrência"###"Item em uso por outra sessão e não poderá ser selecionado."
															+ CRLF + "O que deseja efetuar? " + CRLF + cMsg, ; //"O que deseja efetuar? "
															{ "Tentar Novamente?", "Desconsiderar item"}, 2)  //"Tentar Novamente?"###"Desconsiderar item"
							EndIf
						/*Else
							Help(,,"OIF910Lck",,"Outro processo utilizou o item enquanto este não estava marcado, não será permitido conciliar este item.",1,0,,,,,,{"Item não liberado para seleção."}) //"Outro processo utilizou o item enquanto este não estava marcado, não será permitido conciliar este item."###"Item não liberado para seleção."
							nOpc := 3
						EndIf*/
					Else
						//#TB20200207 Thiago Berna - Ajuste para manter o registro bloqueado na Thread
						//If SE1->( dbRLock( SE1->( Recno() ) ) )
						If aScan(SE1->(DBRLockList()), {|x| x == SE1->( Recno() )}) > 0 
							lTravou := .T.
						Else
							nOpc := AVISO("Controle de Concorr�ncia", "Item em uso por outra sess�o e n�o poder� ser selecionado."; //"Controle de Concorrência"###"Item em uso por outra sessão e não poderá ser selecionado."
															+ CRLF + "O que deseja efetuar? " + CRLF + cMsg, ; //"O que deseja efetuar? "
															{ "Tentar Novamente?", "Desconsiderar item"}, 2)  //"Tentar Novamente?"###"Desconsiderar item"
						EndIf
					EndIf
					(cTabQry)->( dbCloseArea() )
				EndDo

				If nOpc == 2
					oModGrid:GetModel():SetErrorMessage(oModGrid:cID, 'OK', oModGrid:cID, 'OK', "OIF910VChk", "Sele��o desconsiderada.") //"Seleção desconsiderada."
				EndIf

				lRet := lTravou

			EndIf

		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} OI910Cont
Função executada para contagem de registros nas grids.

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static Function OI910Cont(oModel,cModel) As Numeric
//Local oMaster	:= oModel:GetModel()
//Local oModelM	:= oMaster:GetModel(cModel)
Local nLinhas := 0

//nLinhas := oModelM:GetQtdLine()

Return nLinhas

//-------------------------------------------------------------------
/*/{Protheus.doc} OIF910Mc
Inclusao de Check para marcar todos

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
User Function OIF910Mc( oPanel, nSheet )
	Local oCheck	As Object
	Local oModel 	As Object

	oModel	:= FWModelActive()

	Do Case
	Case nSheet == 1
		__lCheck01 := .F.
		@003, 003 CHECKBOX oCheck VAR __lCheck01 Size 060, 020 PROMPT "Marca todos" ON Change(U_OIF910Check(__lCheck01, nSheet, oModel)) Of oPanel	//"Marca todos"
	Case nSheet == 2
		__lCheck02 := .T.
		@003, 003 CHECKBOX oCheck VAR __lCheck02 Size 060, 020 PROMPT "Marca todos" ON Change(U_OIF910Check(__lCheck02, nSheet, oModel)) Of oPanel	//"Marca todos"
	Case nSheet == 3
		@003, 003 CHECKBOX oCheck VAR __lCheck03 Size 060, 020 PROMPT "Marca todos" ON Change(U_OIF910Check(__lCheck03, nSheet, oModel)) Of oPanel	//"Marca todos"
	Case nSheet == 8
		__lCheck08 := .F.
		@003, 003 CHECKBOX oCheck VAR __lCheck08 Size 060, 020 PROMPT "Marca todos" ON Change(U_OIF910Check(__lCheck08, nSheet, oModel)) Of oPanel	//"Marca todos"
	EndCase
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OIF910Check
Marca ou desmarca todos os Registros da Sheet ativa

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
User Function OIF910Check( lCheck, nSheet, oSubMod )
	Local nLinBkp	As Numeric
	Local nLinFIF	As Numeric
	Local nLinSE1	As Numeric
	Local oModel	As Object
	Local oView		As Object

	nLinBkp	:= 0
	nLinFIF	:= 0
	nLinSE1	:= 0
	
	If Empty(oSubMod)
		oModel	:= FWModelActive()
	Else
		oModel := oSubMod
	EndIf
	
	oView 	:= FwViewActive()

	Do Case
	Case nSheet == 1

		/*nLinBkp := oModel:GetModel("FIFFLD1"):GetLine()
	
		For nLinFIF := 1 to oModel:GetModel("FIFFLD1"):Length()
			oModel:GetModel("FIFFLD1"):GoLine(nLinFIF)
			
			oModel:SetValue("FIFFLD1", "OK", lCheck)
		Next nLinFIF

		oModel:GetModel("FIFFLD1"):GoLine(nLinBkp)*/

		//Marca apenas se o registro nao foi conciliado
		nLinBkp := oModel:GetModel("FIFFLD1"):GetLine()
	
		For nLinFIF := 1 to oModel:GetModel("FIFFLD1"):Length()
			oModel:GetModel("FIFFLD1"):GoLine(nLinFIF)
			If !lCheck
				oModel:SetValue("FIFFLD1", "OK", lCheck)
			Else
	
				If oModel:GetModel("FIFFLD1"):GetValue("FIF_STATUS") == '1'
					oModel:SetValue("FIFFLD1", "OK", lCheck)
				EndIf

			EndIf
			
		Next nLinFIF

		oModel:GetModel("FIFFLD1"):GoLine(nLinBkp)

	Case nSheet == 2

		nLinBkp := oModel:GetModel("FIFFLD2"):GetLine()

		For nLinFIF := 1 to oModel:GetModel("FIFFLD2"):Length()

			oModel:GetModel("FIFFLD2"):GoLine(nLinFIF)
			oModel:SetValue("FIFFLD2", "OK", lCheck)

		Next nLinFIF

		oModel:GetModel("FIFFLD2"):GoLine(nLinBkp)

	Case nSheet == 3

		nLinBkp := oModel:GetModel("SE1FLD3"):GetLine()

		For nLinFIF := 1 to oModel:GetModel("SE1FLD3"):Length()
			oModel:GetModel("SE1FLD3"):GoLine(nLinFIF)
			If !Empty(oModel:GetModel("SE1FLD3"):GetValue("E1_NSUTEF"))
				oModel:SetValue("SE1FLD3", "OK", lCheck)
			EndIf

		Next nLinFIF

		oModel:GetModel("SE1FLD3"):GoLine(nLinBkp)
	
	Case nSheet == 8
	
		//Marca para baixar apenas se o registro ja foi conciliado
		nLinBkp := oModel:GetModel("FIFFLD6A"):GetLine()
	
		For nLinFIF := 1 to oModel:GetModel("FIFFLD6A"):Length()
			oModel:GetModel("FIFFLD6A"):GoLine(nLinFIF)
			
			//Seleciona apena nao baixados
			If oModel:GetModel("FIFFLD6A"):GetValue("FIF_STATUS") == '1'
				DbSelectArea("FIF")
				FIF->(DbOrderNickName("CONC"))
				If FIF->(DbSeek(oModel:GetModel("FIFFLD6A"):GetValue("FIF_CODFIL")+oModel:GetModel("FIFFLD6A"):GetValue("FIF_NSUTEF")+DTOS(oModel:GetModel("FIFFLD6A"):GetValue("FIF_DTTEF"))+AllTrim(Str(oModel:GetModel("FIFFLD6A"):GetValue("FIF_VLBRUT")))))
					While !FIF->(Eof()) .And. oModel:GetModel("FIFFLD6A"):GetValue("FIF_CODFIL")+oModel:GetModel("FIFFLD6A"):GetValue("FIF_NSUTEF")+DTOS(oModel:GetModel("FIFFLD6A"):GetValue("FIF_DTTEF"))+AllTrim(Str(oModel:GetModel("FIFFLD6A"):GetValue("FIF_VLBRUT"))) == FIF->(FIF_CODFIL+FIF_NSUTEF+DTOS(FIF_DTTEF)+AllTrim(Str(FIF_VLBRUT)))  
						If FIF->FIF_STATUS $ '2|4' .And. Alltrim(FIF->FIF_TPREG) == '1'
							oModel:SetValue("FIFFLD6A", "OK", lCheck)
						EndIf
						FIF->(DbSkip())
					EndDo
				EndIf
			EndIf
			
		Next nLinFIF

		oModel:GetModel("FIFFLD6A"):GoLine(nLinBkp)

	EndCase

	oView:Refresh()

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910EfetuaBX
Efetua a baixa do titulo por lote ou individual               

@author Ricardo Minoro
@since 21/05/2019

/*/
//---------------------------------------------------------------------------
/*Static Function A910EfetuaBX( aLotes, aRegConc, lRetorno )
Local aTitulosBx	:= {}
//#TB20200120 Thiago Berna - Variavel deve ser Private
//Local lMsErroAuto
Local nCount		:= 0									//Contador utilizado para varrer o array da FIF
Local lOk			:= .F.									//Controla se a baixa por lote foi realizada com sucesso
Local cChave		:= "A910EFETUABX_THRD"
Local nCont			:= 0
Local aRecnosAux	:= {}	

Private lMsErroAuto

Default lRetorno		:= lOk

If cConcilia == 2 //Baixa por lote

	If __nThreads > 1
		lRetorno := A910ThrLote( aLotes, aRegConc, lRetorno )
	Else
		For nCount := 1 To Len( aLotes )
				
			lOk	:= .F.            
			
			aTitulosBX := aLotes[nCount][9]
			
			IncProc("Aguarde..." + ", " + " (Lote: " + aLotes[nCount][1] + " / Qtde T�tulos: " + AllTrim( Str( Len( aTitulosBX ) ) ) + ")")
			
			If FBxLotAut("SE1", aTitulosBX, aLotes[nCount][5], aLotes[nCount][6], aLotes[nCount][7],,aLotes[nCount][1],, aLotes[nCount][8])
				lOk	:= .T.
			Else 
			    lOk := .F.
				MsgStop ("Inconsistencia encontradas no processo de Baixas por Lote. esta interface ser� encerrada para garantir a integridade dos dados na situa��o de baixa por lote.","Opera��o Cancelada") 
				Exit
			EndIf
		Next nCount			
	EndIf
	
Else  
	//Baixa individual
	GETEMPR(cEmpAnt + cFilAnt)
	
	lMsErroAuto	:= .F.
	
	aTitulosBX := aLotes
	
	MSExecAuto({|x, y| FINA070(x, y)}, aTitulosBX, 3)
	
	//Verifica se ExecAuto deu erro
	lRetorno := !lMsErroAuto

	If !lRetorno
		MostraErro()
		DisarmTransaction()
	EndIf
EndIf

If !lRetorno
   MsgStop("Inconsistencia encontradas no processo de Baixas por Lote. esta interface ser� encerrada para garantir a integridade dos dados na situa��o de baixa por lote.","Opera��o Cancelada")
   ProcLogAtu(STR0149,STR0056)

Endif

Return lRetorno*/

//---------------------------------------------------------------------------
/*/{Protheus.doc} BuscarLote
Busca o numero do proximo lote para baixa dos titulos

@author Ricardo Minoro
@since 21/05/2019

/*/
//---------------------------------------------------------------------------
/*Static Function BuscarLote()
Local aArea		:= GetArea()		//Salva area local
Local aOrdSE5 	:= SE5->(GetArea())	//Salva area SE5
Local cLoteFin	:= ''				//Numero do lote
	
cLoteFin := GetSxENum("SE5","E5_LOTE","E5_LOTE"+cEmpAnt,5)
	
DbSelectArea("SE5")
DbSetOrder(5)
	
While SE5->(MsSeek(xFilial("SE5")+cLoteFin))
	If (__lSx8)
		ConfirmSX8()
	EndIf
		
	cLoteFin := GetSxENum("SE5","E5_LOTE","E5_LOTE"+cEmpAnt,5)
EndDo
	
ConfirmSX8()
	
//Restaura areas
RestArea(aArea)
RestArea(aOrdSE5)
	
Return cLoteFin*/

//-------------------------------------------------------------------
/*/{Protheus.doc} OIF910Canc
Função executada no cancelamento da tela de conciliação.

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------
Static Function OIF910Canc() As Logical
	Local lRet := .T.

	// Efetua a liberação de todos os locks de seleção no cancelamento da tela
	FIF->( dBUnlockAll() )
	SE1->( dBUnlockAll() )

Return lRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} BuscarBanco
Busca os dados de banco, agencia e conta (Ponto de entrada), se nao existir, 
matem os parametros que foram passados para a função.                                                                                                          
Atualiza informacoes do SE1                                 

@author Ricardo Minoro
@since 21/05/2019

/*/
//---------------------------------------------------------------------------
Static Function BuscarBanco(cBancoFIF,cAgFIF,cContaFIF,nVlLiqFIF)
Local aDados	:= {}				//Dados do retorno banco/agencia/conta
Local aArea		:= GetArea()		//Salva area local
Local aAliasSE1	:= SE1->(GetArea()) //Salva area SE1
Local aAliasFIF	:= FIF->(GetArea()) //Salva area FIF
Local nACRESC	:= 0
Local nDECRESC	:= 0

If !lPontoF
	aDados := {cBancoFIF, cAgFIF, cContaFIF}
Else
	aDados := ExecBlock('FINA910F', .F., .F., {cBancoFIF, cAgFIF, cContaFIF})
	
	If !(ValType(aDados) == 'A' .AND. Len(aDados) == 3)
		aDados := {cBancoFIF, cAgFIF, cContaFIF}
	EndIf
EndIf

If nVlLiqFIF > SE1->E1_SALDO
	nACRESC 	:= nVlLiqFIF - SE1->E1_SALDO
EndIf

If nVlLiqFIF < SE1->E1_SALDO
	nDECRESC := (nVlLiqFIF - SE1->E1_SALDO) * (-1)
EndIf

RecLock("SE1",.F.)
		
SE1->E1_PORTADO	:= aDados[1]
SE1->E1_AGEDEP	:= aDados[2]
SE1->E1_CONTA	:= aDados[3]
	
//#TH20200213 Thiago Berna - Ajuste para nao considerar acrescimos ou decrescimos no momento da conciliacao	
/*If nAcresc <> 0
	SE1->E1_ACRESC	:= nAcresc
	SE1->E1_SDACRES	:= nAcresc
EndIf
	
If nDECRESC <> 0
	SE1->E1_DECRESC	:= nDECRESC
	SE1->E1_SDDECRE	:= nDECRESC
EndIf*/
	
SE1->(MsUnlock())

//Restaura areas
RestArea(aAliasSE1)
RestArea(aAliasFIF)
RestArea(aArea)

Return aDados

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910ThrLote
Efetua o controle das threads da conciliação                              

@author Ricardo Minoro
@since 21/05/2019

/*/
//---------------------------------------------------------------------------
/*Static Function A910ThrLote( aLotes, aRegConc, lRet )
Local oModelBxR
Local oSubFKA
Local oSubFK5
Local aTitulosBX	:= {}
Local lOk			:= .T.
Local lFa110Tot		:= ExistBlock( 'FA110TOT' )
Local nIx			:= 0
Local cLog			:= ''
Local cCamposE5		:= ''
Local cBco110		:= '' 
Local cAge110		:= ''
Local cCta110		:= ''
Local cLoteFin		:= ''
Local cNatLote		:= FINNATMOV( 'R' )
Local cMyUId		:= 'F910_THREAD_ID' //Definição do nome da seção para controle de variáveis "globais"
Local cKeyId		:= 'F910_KEY'		//Definição da chave para controle de variáveis "globais"
Local aValor		:= {}				//Array que armazenará os valores "globais"
Local nX			:= 0
Local lSpbInUse 	:= SpbInUse()

Private oThredSE1	:= Nil	//Objeto controlador de MultThreads
Private nValorTef	:= 0

ProcRegua(Len(aLotes))

For nIx := 1 TO Len( aLotes )

	lOk := A910VldLote( aLotes[nIx] )

	If !lOk
		Exit	
	EndIf
Next nIx

If lOk
	//Defino a seção, disponibilizando variáveis globais que podem ser enxergadas nas threads que serão abertas
	VarSetUID( cMyUId )
	
	//Atribuo o valor inicial do array (em branco) para uso dentro das threads
	VarSetA( cMyUId, cKeyId, aValor )
	
	For nIx := 1 TO Len( aLotes )

		// Objeto controlador de Threads
		oThredSE1 := FWIPCWait():New( SubStr( 'FA110_' + AllTrim(Str(GenRandThread())),1,15) , 10000 )
		
		oThredSE1:SetThreads(__nThreads)
		oThredSE1:SetEnvironment(cEmpAnt,cFilAnt)
		
		oThredSE1:Start( 'OI910ATHBX' )
		
		aTitulosBX := AClone( aLotes[nIx] )
		
		If __lConoutR
			ConoutR( "Aguarde..." + ', '+ "Lote: " + aTitulosBX[1] + " / Qtde T�tulos: " + AllTrim( Str( Len( aTitulosBX[9] ) ) ) + ')' )
		EndIf 
		
		IncProc( "Aguarde..." + ', ' + "Lote: " + aTitulosBX[1] + " / Qtde T�tulos: " + AllTrim( Str( Len( aTitulosBX[9] ) ) ) + ')') //"Aguarde..."#(Lote: "#" / Qtde Títulos: "
       
		ProcLogAtu( STR0138, StrZero( ThreadId(),10) + ' ' + "Lote: " + aTitulosBX[1] + " / Qtde T�tulos: " + AllTrim( Str( Len( aTitulosBX[9] ) ) ) + ')')
	
		lOk := A910APreBx( oThredSE1, aTitulosBX, aRegConc )
		
		If !lOk
			lRet := .F.
			Exit
			
			oThredSE1:Stop() //Metodo aguarda o encerramento de todas as threads antes de retornar o controle.			
		Else

			oThredSE1:Stop() //Metodo aguarda o encerramento de todas as threads antes de retornar o controle.

			//Obtenho o array que foi alimentado pelas threads
			VarGetA( cMyUId, cKeyId, @aValor )
			
			//Varro o array atrás dos valores totais gravados pelas threads que foram executadas
			For nX := 1 To Len( aValor )
				nValorTef += aValor[nX]
			Next nX
	
			//Gera registro totalizador no SE5, caso baixa seja
			//aglutinada (BX_CNAB=S)
			If nValorTef > 0 .And. __lBxCnab
				cBco110		:= PadR( aTitulosBX[5], nTamBanco	)
				cAge110		:= PadR( aTitulosBX[6], nTamAgencia	)
				cCta110		:= PadR( aTitulosBX[7], nTamCC		)
				cLoteFin	:= aTitulosBX[1]
				dBaixa		:= aTitulosBX[8]
	
				SE1->( DbSetOrder(1) )
				SE1->( DbSeek( xFilial('SE1') + aTitulosBX[1] + aTitulosBX[2] + aTitulosBX[3] + aTitulosBX[4] + aTitulosBX[5] + aTitulosBX[7] ) )
				
				//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
				//Estrutura para o E5_CAMPOS: "{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}|{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}"
				cCamposE5 := "{"
			
			   	oModelBxR := FWLoadModel( 'FINM030' )
				oModelBxR:SetOperation( MODEL_OPERATION_INSERT ) //Inclusão
				oModelBxR:Activate()
				oModelBxR:SetValue( 'MASTER', 'E5_GRV'	, .T.	) //Informa se vai gravar SE5 ou não 
				oModelBxR:SetValue( 'MASTER', 'NOVOPROC', .T.	) //Informa que a inclusão será feita com um novo número de processo
				
				//Dados do Processo
				oSubFKA := oModelBxR:GetModel( 'FKADETAIL' )
				oSubFKA:SetValue( 'FKA_IDORIG', FWUUIDV4()	)
				oSubFKA:SetValue( 'FKA_TABORI', 'FK5'		)
				
				//Informacoes do movimento
				oSubFK5 := oModelBxR:GetModel( 'FK5DETAIL' )
				oSubFK5:SetValue( 'FK5_VALOR'	, nValorTef										)
				oSubFK5:SetValue( 'FK5_TPDOC'	, 'VL'											)
				oSubFK5:SetValue( 'FK5_BANCO'	, cBco110										)
				oSubFK5:SetValue( 'FK5_AGENCI'	, cAge110										)
				oSubFK5:SetValue( 'FK5_CONTA'	, cCta110										)
				oSubFK5:SetValue( 'FK5_RECPAG'	, 'R'											)
				oSubFK5:SetValue( 'FK5_HISTOR'	, "Baixa Automatica / Lote: " + cLoteFin		) // "Baixa Automatica / Lote: "	
				oSubFK5:SetValue( 'FK5_DTDISP'	, dDataBase										)
				oSubFK5:SetValue( 'FK5_FILORI'	, FilBxLote()									)
				oSubFK5:SetValue( 'FK5_ORIGEM'	, FunName()										)
				oSubFK5:SetValue( 'FK5_LOTE'	, cLoteFin										)
				oSubFK5:SetValue( 'FK5_NATURE'	, cNatLote										) 
				oSubFK5:SetValue( 'FK5_MOEDA'	, StrZero( SE1->E1_MOEDA, 2 )					)
				
				oSubFK5:SetValue( 'FK5_DATA', dBaixa )
				cCamposE5 += '{"E5_DTDIGIT",STOD("' + DtoS( dDataBase ) + '")}'
				cCamposE5 += ',{"E5_DTDISPO",STOD("' + DtoS( dBaixa ) + '")}'
				
				If lSpbInUse
					cCamposE5 += ',{"E5_MODSPB","1"}'
				Endif
				
				cCamposE5 += ',{"E5_LOTE","' + cLoteFin + '"}'
				cCamposE5 += '}'
				
				oModelBxR:SetValue( 'MASTER', 'E5_CAMPOS', cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK5
			
				If oModelBxR:VldData()		
					oModelBxR:CommitData()
					SE5->( dbGoto( oModelBxR:GetValue( 'MASTER', 'E5_RECNO' ) ) )
				Else
					lRet := .F.
					cLog := cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
				    cLog += cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
				    cLog += cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_MESSAGE])        	
				    
				    Help( ,,'M030VALID',,cLog, 1, 0 )	            
				EndIf
				
				oModelBxR:DeActivate()
				oModelBxR:Destroy()
				
				// PONTO DE ENTRADA FA110TOT
				// ExecBlock para gravar dados complementares ao registro totalizador
				If lFa110Tot
					Execblock( 'FA110TOT', .F., .F. )
				EndIf
			
				// Atualiza saldo bancario
				AtuSalBco( cBco110, cAge110, cCta110, SE5->E5_DATA, SE5->E5_VALOR, '+' )
			EndIf	

			aValor := {}

			//Atribuo o valor inicial do array (em branco) para uso dentro das threads
			VarSetA( cMyUId, cKeyId, aValor )

			//Zero o valor da variável, evitando que ocorra somatória incorreta dos totais
			nValorTef := 0
					
		EndIf

		FreeObj( oThredSE1 )
		
	Next nIx 
	
	IncProc( STR0154 )

	oThredSE1 := Nil

	//Deleto a seção após sua utilização
	VarClean( cMyUId )
EndIf

Return lOk*/


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} OI910Vs
Rotina para visualização do registro posicionado

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------------------------
User Function OI910Vs
Local nRecno := FIF->(Recno())

U_OI910ALT("FIF",nRecno,2)

Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} A910EDITA
Rotina para edição do registro posicionado

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------------------------
User Function OI910Ed
Local nRecno := FIF->(Recno())

U_OI910ALT("FIF",nRecno,4)

Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} OI910ALT
Rotina para visualização ou alteração do registro posicionado

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------------------------
User Function OI910ALT(cAlias,nReg,nOpc)
                                                          		
Local aCpoEnch		:= {}
Local aAlterEnch	:= {}
Local nModelo		:= 3	// Se for diferente de 1 desabilita execucao de gatilhos estrangeiros                           
Local lF3			:= .F.	// Indica se a enchoice esta sendo criada em uma consulta F3 para utilizar variaveis de memoria 
Local lMemoria		:= .T.	// Indica se a enchoice utilizara variaveis de memoria ou os campos da tabela na edicao         
Local lColumn		:= .F.	// Indica se a apresentacao dos campos sera em forma de coluna                                  
Local caTela		:= ""	// Nome da variavel tipo "private" que a enchoice utilizara no lugar da propriedade aTela       
Local lNoFolder		:= .F.	// Indica se a enchoice nao ira utilizar as Pastas de Cadastro (SXA)                            
Local lProperty		:= .T.	// Indica se a enchoice nao utilizara as variaveis aTela e aGets, somente suas propriedades com os mesmos nomes
Local aButtons		:= {}
Local lRet			:= .F.
Local nI			:= 0
Local oDlg			// Dialog Principal
Local aSize	:= MsAdvSize()
Local aPos  := {}
Local oSize := FWDefSize():New(.T.)

//Monto os campos da Enchoice deixando somente os campos customizados e o FIF_STATUS para alterar
dbSelectArea("SX3")
dbSetOrder(1)
If SX3->( dbSeek( cAlias ) )
	While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == cAlias
		aAdd(aCpoEnch,SX3->X3_CAMPO)
		If (Alltrim(SX3->X3_PROPRI) == "U" .Or. Alltrim(SX3->X3_CAMPO) == "FIF_STATUS") .And. nOpc <> 2
			aAdd(aAlterEnch,SX3->X3_CAMPO)
		EndIf
		SX3->( dbSkip() )
	End
EndIf

oSize:AddObject( "ENCHOICE", 100,100, .T., .T. )
oSize:Process()
aPos := {oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI"),oSize:GetDimension("ENCHOICE","LINEND"),oSize:GetDimension("ENCHOICE","COLEND")}

DEFINE MSDIALOG oDlg TITLE "Conciliador TEF" + " - " + If(nOpc==4,"Alterar","Visualizar") FROM aSize[7],0 to aSize[6],aSize[5] Of oMainWnd PIXEL // ##"Conciliador TEF" ##"Alterar" ##"Visualizar"
	RegToMemory(cAlias, .F., .F.)
	Enchoice(cAlias,,nOpc,,,,aCpoEnch,aPos,aAlterEnch,nModelo,,,,oDlg,lF3,lMemoria,lColumn,caTela,lNoFolder,lProperty)

ACTIVATE MSDIALOG oDlg CENTERED  ON INIT EnchoiceBar(oDlg, {|| lRet := .T.,oDlg:End()},{||lRet := .F.,oDlg:End()},,aButtons)

If lRet .And. nOpc <> 2 .And. Len(aAlterEnch) > 0
	RecLock(cAlias,.F.)
	For nI := 1 to Len(aAlterEnch)
		(cAlias)->&(aAlterEnch[nI]) :=  M->&(aAlterEnch[nI])
	Next nI
	(cAlias)->( MsUnLock() )
EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} OIF910C
Rotina para visualização ou alteração do registro posicionado

@author Ricardo Minoro
@since 21/05/2019

/*/
//-------------------------------------------------------------------------------------

User Function OIF910C()

Local cReport	:= "OIFINA910"			// Nome do Programa
Local lInd		:= .T.					// Retorna Indice SIX
Local cAlias	:= "FIF"
Local cTitulo	:= "Listagem de Conciliacao do SITEF"
Local cDescRel	:= "Listagem dos registros da tabela Conciliacao de registros do SITEF"

If TRepInUse()
	MPReport(cReport,cAlias,cTitulo,cDescRel,,lInd)
Else
    MsgInfo("Relatorio disponivel somente para a versao com TREPORT")
EndIf

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910APreBx
Inicia a preparação das baixas dos cartões                              

@type Function
@author Unknown
/*/
//---------------------------------------------------------------------------
/*Static Function A910APreBx( oThread, aTitulosBX, aRegConc )
Local aRecnosAux    := {}
Local cChave        := "FA110BXAUT_THRD"
Local cBanco        := PADR(aTitulosBX[5],nTamBanco  )
Local cAgencia      := PADR(aTitulosBX[6],nTamAgencia)
Local cConta        := PADR(aTitulosBX[7],nTamCC     )
Local cCheque       := ''
Local cLoteFin      := aTitulosBX[1]
Local cNatureza     := Nil
Local aRecnos       := aTitulosBX[9]
Local lOk           := .T.
Local lBaixaVenc    := lUseFIFDtCred	//se deve gravar a data de credito na E1_BAIXA
Local nIx           := 0
Local nCont         := 0
Local nContAux		:= 0
Local nQtLote		:= 0

Private dBaixa      := aTitulosBX[8]

If ( Len( aRecnos ) % __nThreads ) > 0 //Possui resto de divisão  
	nQtLote := Int( Len( aRecnos ) / __nThreads ) + 1
Else
	nQtLote := Int( Len( aRecnos ) / __nThreads )
EndIf

If !LockByName( cChave, .F. , .F. )
	Help( " " ,1, cChave ,,STR0155,1, 0 )
Else
	// Abertura de Threads
	ProcRegua( Len( aRecnos ) )
					
	For nIx := 1 To Len( aRecnos )
		IncProc()
		nCont++
		nContAux++
		aAdd( aRecnosAux, aRecnos[nIx] )
	
		If nCont == nQtLote .Or. nContAux == Len( aRecnos )
           // Chamada da função OI910ATHBX( aTitulos, aRegConc )
           //oThread:Go( {aRecnosAux,cBanco,cAgencia,cConta,cCheque,cLoteFin,cNatureza,dBaixa,lBaixaVenc}, aRegConc, lThread )
		   oThread:Go( {aRecnosAux,cBanco,cAgencia,cConta,cCheque,cLoteFin,cNatureza,dBaixa,lBaixaVenc}, aRegConc, .T. )
           Sleep(500)
           aRecnosAux	:= {}
           nCont		:= 0
		EndIf
	Next nIx

	// Fechamento das Threads   
	UnLockByName( cChave, .F. , .F. )
EndIf	

Return lOk*/

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910ATHRBX
Rotina de controle das baixas. Inicializa uma trasação porpor thread. Caso 
caia, somente aquela thread é afetada.      

@type Function
@author Unknown
@since 21/01/2014
@version 12   
/*/
//---------------------------------------------------------------------------
User Function OI910ATHBX( aTitulos, aRegConc, lThread )
Local lOk		:= .F.

Default lThread	:= .T.

lMsErroAuto := .F.

Conout( StrZero(ThreadId(),10) + STR0156 )
Fina110( 3, aTitulos, lThread )

//Verifica se ExecAuto deu erro
lOk := !lMsErroAuto

If lOk
    // se conseguiu efetuar a baixa, atualizo o registro da FIF
    lOk := AtualizaFIF( aTitulos, aRegConc )
Endif

If !lOk
   Conout( StrZero(ThreadId(),10) + STR0157 )
   Conout( MostraErro() )
   DisarmTransaction()
Endif

Conout( StrZero(ThreadId(),10) + STR0158 )

Return lOk

//---------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaFIF
Efetua a baixa dos registros da FIF. Está na mesma transação da baixa por  
lote.                                          

@type Function
@author Unknown
@since 21/01/2014
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function AtualizaFIF( aTitulos, aRegConc )
Local aArea		:= GetArea()
Local lOk		:= .T.
Local nIx		:= 0
Local nPosFIF	:= 0
Local aTitAux	:= aTitulos[1]

For nIx := 1 TO Len( aTitAux )

	nPosFIF := aScan( aRegConc , {|x| x[22] == aTitAux[nIx] } )
	
	// se localizei o registro da FIF dentro do aTitulos e o recno da FIF não está em branco
	If nPosFIF > 0 .And. !Empty( aRegConc[nPosFIF][23] )
		DbSelectArea( 'FIF' )
		FIF->( DbGoTo( aRegConc[nPosFIF][23] ) )
			
		If FIF->( !Eof() ) .And. FIF->( Recno() ) == aRegConc[nPosFIF][23]
			RecLock("FIF",.F.)
			
			FIF->FIF_STATUS := "2"				    	//Conciliado
//			FIF->FIF_STVEND := F910aStVen( FIF->FIF_STVEND ) // Atualiza o Status de Venda para Pagamento Conciliado
			FIF->FIF_PREFIX := aRegConc[nPosFIF][5]   	//Rastro Prefixo SE1
			FIF->FIF_NUM    := aRegConc[nPosFIF][6]   	//Rastro Num SE1
			FIF->FIF_PARC   := aRegConc[nPosFIF][8]   	//Rastro Parcela SE1
			FIF->FIF_TIPO   := aRegConc[nPosFIF][7]   	//Rastro Tipo SE1
			FIF->FIF_PGJUST := aRegConc[nPosFIF][29]	//Justificativa FVX
			FIF->FIF_PGDES1 := aRegConc[nPosFIF][30]	//Justificativa FVX
			FIF->FIF_PGDES2 := aRegConc[nPosFIF][31]	//Justificativa Manual
			FIF->FIF_USUPAG := RetCodUsr()				//Código do usuário
			FIF->FIF_DTPAG 	:= dDatabase				//database

			If lFifRecSE1
				FIF->FIF_RECSE1 := aRegConc[nPosFIF][22]    //Rastro Recno SE1
			EndIf			

			FIF->(MsUnlock())
		Else
			lOk := .F.
         
			ProcLogAtu(STR0149,STR0159 + Alltrim( Str( aRegConc[nPosFIF][23] ) ) + STR0160)         
		EndIf

	EndIf
Next nIx

RestArea( aArea )

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} f910GetComb
Função para retornar o descritivo do combo

/*/
//-------------------------------------------------------------------
/*static Function f910GetComb(cCampo,cConteudo)
Local aCombo 	:= {}
Local cCombo 	:= {}
Local aArea	 	:= GetArea()
Local aAreaSX3 	:= SX3->(GetArea())
Local nX		:= 0
Local cRet      := ""
Local nPos      := 0

If !Empty(Alltrim(cConteudo))
	If __cVarComb <> cCampo
		__cVarComb := cCampo
		__aVarComb := {}
		SX3->(dbSetOrder(2))
		If SX3->(MsSeek(cCampo))
			cCombo := SX3->( X3CBox() )
			aCombo := StrTokArr ( cCombo , ';' )
			For nx := 1 To Len(aCombo)
				aAdd(__aVarComb, StrTokArr(aCombo[nX],'=')) 
			Next
		EndIf
		RestArea(aAreaSX3)
		RestArea(aArea)
	EndIf
	
	nPos := aScan(__aVarComb, {|x| x[1] == cConteudo})
	
	If nPos > 0
		cRet := __aVarComb[nPos][2]
	EndIf
EndIf

Return cRet*/

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910VldLote
Efetua a valiação do lote de processamento dos lotes                              
  
/*/
//---------------------------------------------------------------------------
/*Static Function A910VldLote( aLotes )
Local lOk		:= .T.
Local cBanco	:= PADR(aLotes[5],nTamBanco  )
Local cAgencia	:= PADR(aLotes[6],nTamAgencia)
Local cConta	:= PADR(aLotes[7],nTamCC     )

//Verifico informacoes para processo
If Empty(cBanco) .or. Empty(cAgencia) .or. Empty(cConta) 
	Help(" ",1,"BXLTAUT1",,"Informa��es incorretas n�o permitem a baixa autom�tica em lote. Verifique as informa��es passadas para a fun��o FBXLOTAUT()", 1, 0 )		//"Informações incorretas não permitem a baixa automática em lote. Verifique as informações passadas para a função FBXLOTAUT()"
	lOk		:= .F.
ElseIf !CarregaSa6(@cBanco,@cAgencia,@cConta,.T.,,.F.)
	lOk		:= .F.
ElseIf Empty(aLotes[9])
	Help(" ",1,"RECNO")
	lOk		:= .F.
Endif

Return lOk*/

//---------------------------------------------------------------------------
/*/{Protheus.doc} AtuTabFIF
Atualiza os dados da FIF apos a baixa dos titulos

/*/
//---------------------------------------------------------------------------
Static Function AtuTabFIF(aRegConc, cIsThread, lRet)
Local nCount	As Numeric
Local aArea		As Array
Local aAliasFIF	As Array

DEFAULT aRegConc	:= {}
DEFAULT cIsThread	:= ""
DEFAULT lRet		:= .T.

nCount		:= 0				//Utilizada para ler todos os registros baixados
aArea		:= GetArea()		//Salva area local
aAliasFIF	:= FIF->(GetArea()) //Salva area FIF

ProcRegua(Len(aRegConc))
IncProc("Atualizando tabela FIF...") //"Atualizando tabela FIF..."
	
DbSelectArea("FIF")
DbSetOrder(5)
	
//FIF_FILIAL + FIF_DTTEF + FIF_NSUTEF + FIF_PARCEL
For nCount := 1 To Len( aRegConc )

	If !Empty(aRegConc[nCount][23])
		FIF->( dbGoTo(aRegConc[nCount][23]) ) // Faz a busca pelo FIF.R_E_C_N_O_
		If FIF->( !Eof() ) .And. FIF->( Recno() ) == aRegConc[nCount][23]

			IncProc()
			While !FIF->(Eof()) .AND. (DTOS(FIF->FIF_DTTEF) + FIF->FIF_NSUTEF + FIF->FIF_PARCEL == DTOS(aRegConc[nCount][10]) + aRegConc[nCount][14] + aRegConc[nCount][15]) // Não utiliza o FIF_FILIAl, pois controla através do FIF_CODLOJ
				If AllTrim(Upper(FIF->FIF_CODLOJ)) == AllTrim(Upper(aRegConc[nCount][3])) .AND. FIF->(Recno()) == aRegConc[nCount][23]
					Exit
				EndIf
				FIF->(DbSkip())
			EndDo
			
			RecLock("FIF",.F.)
			
			FIF->FIF_STATUS := aRegConc[nCount][1]	//'6' - Ant. Nao Processada / '7' - Antecipado
//				FIF->FIF_STVEND := F910aStVen( FIF->FIF_STVEND ) // Atualiza o Status de Venda para Pagamento Conciliado
			FIF->FIF_PREFIX := aRegConc[nCount][5]						//Rastro Prefixo SE1
			FIF->FIF_NUM    := aRegConc[nCount][6]						//Rastro Num SE1
			FIF->FIF_PARC   := aRegConc[nCount][8]						//Rastro Parcela SE1
			FIF->FIF_TIPO   := aRegConc[nCount][7]						//Rastro Tipo SE1
			FIF->FIF_PGJUST := aRegConc[nCount][29]						//Justificativa FVX
			FIF->FIF_PGDES1 := aRegConc[nCount][30]						//Justificativa FVX
			FIF->FIF_PGDES2 := aRegConc[nCount][31]						//Justificativa Manual
			FIF->FIF_USUPAG := RetCodUsr()								//Código do usuário
			FIF->FIF_DTPAG 	:= dDatabase								//database

			FIF->(MsUnlock())
			
		EndIf
	EndIf
	
	If Empty(cIsThread)
		IncProc()
	EndIf
		
Next nCount

//Restaura areas
RestArea(aAliasFIF)
RestArea(aArea)
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A910ParName
Função para fazer o vinculo entre o parametro x cod. administradora 
que será utilizado na conciliação SITEF
/*/
//-------------------------------------------------------------------
Static Function A910ParName()
	
	Local cAliasQry	:= GetNextAlias()
	Local aRet		:= {}
	
	BeginSql Alias cAliasQry
		SELECT  MDE.MDE_CODIGO, MDE.MDE_DESC
		
		FROM %Table:MDE% MDE
		
		WHERE MDE.MDE_TIPO = %Exp:'RD'%
			AND	MDE.MDE_ARQIMP <> %Exp:' '% 
			AND MDE.MDE_DESC IN (%Exp:'REDE'%,%Exp:'REDECARD'%,%Exp:'AMEX'%,%Exp:'AMERICAN EXPRESS'%,%Exp:'CIELO'%,%Exp:'SOFTWARE EXPRESS'%,%Exp:'SOFTWAREEXPRESS'%)
			AND MDE.%NotDel%
	EndSql
	
	(cAliasQry)->( dbGoTop() )
	If !(cAliasQry)->( Eof() )

		While !(cAliasQry)->( Eof() )
			If AllTrim( (cAliasQry)->MDE_DESC ) $ 'AMEX|AMERICAN EXPRESS'
				aAdd(aRet, {(cAliasQry)->MDE_CODIGO, "MV_EMPTAME"})
			
			ElseIf AllTrim( (cAliasQry)->MDE_DESC ) $ 'CIELO'
				aAdd(aRet, {(cAliasQry)->MDE_CODIGO, "MV_EMPTCIE"})
		
			ElseIf AllTrim( (cAliasQry)->MDE_DESC ) $ 'REDE|REDECARD'
				aAdd(aRet, {(cAliasQry)->MDE_CODIGO, "MV_EMPTRED"})
			
			ElseIf AllTrim( (cAliasQry)->MDE_DESC ) $ 'SOFTWAREEXPRESS|SOFTWARE EXPRESS'
				aAdd(aRet, {(cAliasQry)->MDE_CODIGO, "MV_EMPTEF"})
			EndIf

			(cAliasQry)->( dbSkip() )
		EndDo

	EndIf
	
	(cAliasQry)->( dbCloseArea() )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} StrTot
Retorna a Estrutura do Cabecalho

@author Thiago Berna
@since 21/01/2020

/*/
//-------------------------------------------------------------------
Static Function Fechamento( nTipo As Numeric ) As Object
	
	Local oStruct	As Object
	Local cPicture	As Character
	Local cOrdem	As Character
	Local nLenVlr	As Numeric
	Local nDecVlr	As Numeric
	Local nLenQtd	As Numeric

	cPicture	:= PesqPict("SE1", "E1_VALOR")
	cOrdem		:= "00"
	nLenVlr		:= TamSX3("E1_VALOR")[1]
	nDecVlr		:= TamSX3("E1_VALOR")[2]
	nLenQtd		:= 09

	Do Case
	Case nTipo == 1
		oStruct	:= FWFormModelStruct():New()

		//Tabela
		oStruct:AddTable("FECHAMENTO" ,{"SEQUENCIA"}, "Fechamento")	//Campos do cabeçalho do TMP	//"Totais"

		//Campos
		oStruct:AddField("Sequencia", "Sequencia", "SEQUENCIA", "C", 10, 0, NIL, NIL, NIL, NIL, {|| ''}, NIL, .F., .F.)	//"Sequencia"
		oStruct:AddField("Tipo", "Tipo", "TIPO", "C", 2, 0, NIL, NIL, NIL, NIL, {|| ''}, NIL, .F., .F.)	//"Tipo"
		oStruct:AddField("Descri��o", "Descri��o", "DESC", "C", 50, 0, NIL, NIL, NIL, NIL, {|| ''}, NIL, .F., .F.)	//"Descri��o"
		
		
		oStruct:AddField("Total Dia", "Total Dia",  "TOTTOT", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)		//"Total R$"
		oStruct:AddField("N�o Conciliado", "N�o Conciliado",  "NONTOT", "N", nLenVlr, nDecVlr, NIL, NIL, NIL, NIL, {|| 0}, NIL, .F., .F.)				//"Total R$"

		//Indices
		oStruct:AddIndex(1, "01", "SEQUENCIA", "Sequencia", "", "", .T.)		//"Sequencia"
	Case nTipo == 2
		oStruct	:= FWFormViewStruct():New()

		oStruct:AddField("SEQUENCIA",fSoma1(@cOrdem),"Sequencia","Sequencia",NIL,"C",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)		//"Sequencia"	
		oStruct:AddField("TIPO",fSoma1(@cOrdem),"Tipo","Tipo",NIL,"C",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)		//"Tipo"	
		oStruct:AddField("DESC",fSoma1(@cOrdem),"Descri��o","Descri��o",NIL,"C",NIL,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)		//"Descri��o"	
		
		oStruct:AddField("TOTTOT",fSoma1(@cOrdem),"Total Dia","Total Dia",NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL,130)		//"Total R$"	
		oStruct:AddField("NONTOT",fSoma1(@cOrdem),"N�o Conciliado","N�o Conciliado",NIL,"N",cPicture,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.F.,NIL,NIL)				//"Qt.Total"
	EndCase
	
						
Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} fLoadTot
Calculo dos Totais da Conciliacao

@author Thiago Berna
@since 21/01/2020

/*/
//-------------------------------------------------------------------
Static Function fLoadFec( oSubMod As Object, nOpca As Numeric ) As Array
	Local aRetorno		As Array
	Local aTemp			As Array
	Local aFields		As Array
	Local aAux			As Array
	Local aRecnos		As Array
	Local nField		As Numeric
	Local nX			As Numeric
	Local nPos			As Numeric
	Local nCount		As Numeric
	Local cQuery		As Character
	Local cAliasFIF		As Character
	Local cAliasFIFB	As Character
	Local cAliasZWX		As Character
	Local cAliasSE1 	As Character
	Local cAliasSE1B 	As Character
	Local cSequen		As Character
	Local cPerg			As Character
	Local oModel		As Object
	Local oView			As Object
	Local lFound		As Logical
	Local lErro			As Logical
	Local lAchou		As Logical

	Local cPar02		As Character
	Local cPar03		As Character
	//Local cPar04		As Character
	Local cPar01		As Date

	lFound		:= .F.
	lErro		:= .F.
	lNConc		:= .F.
	lAchou		:= .F.
	aRetorno	:= {}
	aTemp		:= {}
	aAux		:= {}
	aRecnos		:= {}
	nField		:= 0
	nX			:= 0
	nCount		:= 0
	cQuery		:= ""
	cAliasFIF	:= GetNextAlias()
	cAliasFIFB	:= GetNextAlias()
	cAliasZWX	:= GetNextAlias()
	cAliasSE1	:= GetNextAlias()
	cAliasSE1B	:= GetNextAlias()

	cPar01		:= STOD("")
	cPar02		:= ""
	cPar03		:= ""
	//cPar04		:= ""

	nDebit		:= 0
	nCredi		:= 0
	nTotal		:= 0
	nTaxas		:= 0
	nTaxCC		:= 0
	nTaxCD		:= 0
	nTaxAbe		:= 0
	nPos		:= 0
	nDinhe		:= 0

	aFIF		:= {}
	aFIFSeq		:= {}
	
	//tratamento parqa execu��o ao selecionar a aba
	If nOpca == 2
		
		oView	:= FWViewActive() 

		If !Empty(FWModelActive())
			oModel 	:= FWModelActive()	
			oSubMod := oModel:GetModel("TOTFLD7")
		Else
			oModel	:= oSubMod
			oSubMod := oModel:GetModel("TOTFLD7")
		EndIf

		aFields	:= oSubMod:GetStruct():GetFields()
		cPerg	:= "FINA910OIF"
		cSequen	:= '001'
		cStatu	:= "ABERTO"

		oModel:GetModel("TOTFLD7"):SetNoDeleteLine(.F.)
		oModel:GetModel("TOTFLD7"):SetNoInsertLine(.F.)
		oModel:GetModel("TOTFLD7"):SetNoUpdateLine(.F.)

		//Salva MV_PAR original
		cPar01  := MV_PAR01
		cPar02	:= MV_PAR02
		cPar03	:= MV_PAR03
		//cPar04	:= MV_PAR04
		
		Pergunte(cPerg, .T.)

		cRefer		:= DtoC(MV_PAR01)
		//Contabilizacao sempre online
		//If MV_PAR04 == 1
			lContab := .T.
		//Else
		//	lContab	:= .F.
		//EndIf

		cQuery := "SELECT * FROM " + RetSqlTab("ZWX")
		//If !Empty(MV_PAR02)
			cQuery += "WHERE ZWX.ZWX_FILIAL = '" + xFilial("ZWX") + "' "
		//Else
		//	cQuery += "WHERE ZWX.ZWX_FILIAL >= '' "
		//EndIf
		cQuery += "AND ZWX.ZWX_DATA = '" + DtoS(MV_PAR01) + "' "
		cQuery += "AND ZWX.D_E_L_E_T_ <> '*' " 

		cQuery := ChangeQuery(cQuery)

		If Select(cAliasZWX) > 0
			(cAliasZWX)->(DbCloseArea())
		EndIf

		
		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasZWX, .T., .T.)
		

		If (cAliasZWX)->(!Eof())
			
			lFound		:= .T.
			cStatu		:= "FECHADO"

			nPos := Len(oSubMod:aDataModel)
			oSubMod:DelAllLine()
			
			While (cAliasZWX)->(!Eof())

				aAux := Array(Len(aFields))
				aAux[1]	:= cSequen
				aAux[2]	:= (cAliasZWX)->ZWX_TIPO
					
				If (cAliasZWX)->ZWX_TIPO == "CM"
					aAux[3]	:= "CARTAO MADERO"
				ElseIf (cAliasZWX)->ZWX_TIPO == "R$"
					aAux[3]	:= "DINHEIRO"
				//ElseIf (cAliasZWX)->ZWX_TIPO == "TX"
				//	aAux[3]	:= "TAXAS"
				
				ElseIf (cAliasZWX)->ZWX_TIPO == "TC"
					aAux[3]	:= "TAXAS CREDITO"
				ElseIf (cAliasZWX)->ZWX_TIPO == "TD"
					aAux[3]	:= "TAXAS DEBITO"
				
				Else
					DbSelectArea('SX5')
					SX5->(DbSetOrder(1))
					If SX5->(DbSeek(xFilial('SX5')+'G3'+(cAliasZWX)->ZWX_REDE))
						aAux[3]	:= AllTrim(SX5->X5_DESCRI)
					EndIf
				EndIf
	
				aAux[4]	:= (cAliasZWX)->ZWX_VALOR
				aAux[5]	:= (cAliasZWX)->ZWX_NCONC

				nTotal += (cAliasZWX)->ZWX_VALOR	

				If AllTrim((cAliasZWX)->ZWX_TIPO) == 'D'
					nDebit += (cAliasZWX)->ZWX_VALOR
				ElseIf AllTrim((cAliasZWX)->ZWX_TIPO) == 'C'
					nCredi += (cAliasZWX)->ZWX_VALOR
				ElseIf AllTrim((cAliasZWX)->ZWX_TIPO) == 'TX'
					nTaxas += (cAliasZWX)->ZWX_VALOR					
				EndIf
					
				oSubMod:AddLine(.T.)
				oSubMod:SetValue("SEQUENCIA", aAux[1])
				oSubMod:SetValue("TIPO"		, aAux[2])
				oSubMod:SetValue("DESC"		, aAux[3])
				oSubMod:SetValue("TOTTOT"	, aAux[4])
				oSubMod:SetValue("NONTOT"	, aAux[5])
				
				Aadd(aRetorno, {0 ,aAux})

				(cAliasZWX)->(DbSkip())
				cSequen := Soma1(cSequen)
			EndDo

		Else
					
			//Busca registros conciliados para calcular taxas
			cQuery := "SELECT FIF.R_E_C_N_O_ "
			cQuery += "FROM " + AllTrim(RetSqlTab("FIF"))
			//If !Empty(MV_PAR02)
				cQuery += "WHERE FIF.FIF_FILIAL = '" + xFilial("FIF") + "' "
			//Else
			//	cQuery += "WHERE FIF.FIF_FILIAL >= '' "
			//EndIf
			cQuery += "AND FIF.FIF_DTTEF = '" + DtoS(MV_PAR01) + "' "
			cQuery += "AND FIF.FIF_CODFIL = '" + xFilial("FIF")  + "' "
			cQuery += "AND FIF.FIF_STATUS IN ('2','4') "
			cQuery += "AND FIF.D_E_L_E_T_ <> '*' "

			cQuery := ChangeQuery(cQuery)

			If Select(cAliasFIF) > 0
				(cAliasFIF)->(DbCloseArea())
			EndIf

			
			DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasFIF, .T., .T.)
			
			
			If (cAliasFIF)->(!Eof())
				While (cAliasFIF)->(!Eof())
					AAdd(aFIF,{(cAliasFIF)->R_E_C_N_O_})
					(cAliasFIF)->(DbSkip())
				EndDo
			EndIf

			//Query para mostrar dados consolidados na tela
			cQuery := "SELECT DISTINCT FIF.FIF_FILIAL, FIF.FIF_DTTEF, FIF.FIF_CODADM, FIF.FIF_CODRED, FIF.FIF_TPPROD, "
			cQuery += "(SELECT SUM(FIFB.FIF_VLBRUT) "
			cQuery += "FROM " + AllTrim(RetSqlTab("FIF")) + "B "
			cQuery += "WHERE FIFB.FIF_FILIAL =  FIF.FIF_FILIAL " 
			cQuery += "AND FIFB.FIF_DTTEF = FIF.FIF_DTTEF "
			cQuery += "AND FIFB.FIF_CODFIL = FIF.FIF_CODFIL "
			
			//cQuery += "AND FIFB.FIF_STATUS <> '2' "
			cQuery += "AND NOT FIFB.FIF_STATUS IN ('2','4') "
			
			cQuery += "AND FIFB.FIF_TPPROD = FIF.FIF_TPPROD "
			cQuery += "AND FIFB.FIF_CODADM = FIF.FIF_CODADM "
			cQuery += "AND FIFB.FIF_CODRED = FIF.FIF_CODRED "
			cQuery += "AND FIFB.FIF_TPREG = '1' " 
			cQuery += "AND FIFB.D_E_L_E_T_ <> '*' ) AS NCONC, "

			cQuery += "(SELECT SUM(FIFB.FIF_VLBRUT) "
			cQuery += "FROM " + AllTrim(RetSqlTab("FIF")) + "B "
			cQuery += "WHERE FIFB.FIF_FILIAL =  FIF.FIF_FILIAL " 
			cQuery += "AND FIFB.FIF_DTTEF = FIF.FIF_DTTEF "
			cQuery += "AND FIFB.FIF_CODFIL = FIF.FIF_CODFIL "
			cQuery += "AND FIFB.FIF_TPPROD = FIF.FIF_TPPROD "
			cQuery += "AND FIFB.FIF_CODADM = FIF.FIF_CODADM "
			cQuery += "AND FIFB.FIF_CODRED = FIF.FIF_CODRED "
			cQuery += "AND FIFB.FIF_TPREG = '1' " 
			cQuery += "AND FIFB.D_E_L_E_T_ <> '*' ) AS TOTAL, "

			cQuery += "(SELECT SUM(FIFB.FIF_VLBRUT - FIFB.FIF_VLLIQ) "
			cQuery += "FROM " + AllTrim(RetSqlTab("FIF")) + "B "
			cQuery += "WHERE FIFB.FIF_FILIAL =  FIF.FIF_FILIAL " 
			cQuery += "AND FIFB.FIF_DTTEF = FIF.FIF_DTTEF "
			cQuery += "AND FIFB.FIF_CODFIL = FIF.FIF_CODFIL "
			
			//cQuery += "AND FIFB.FIF_STATUS <> '2' "
			cQuery += "AND NOT FIFB.FIF_STATUS IN ('2','4') "
			
			cQuery += "AND FIFB.FIF_TPPROD = FIF.FIF_TPPROD "
			cQuery += "AND FIFB.FIF_CODADM = FIF.FIF_CODADM "
			cQuery += "AND FIFB.FIF_CODRED = FIF.FIF_CODRED "
			cQuery += "AND FIFB.FIF_TPREG = '1' " 
			cQuery += "AND FIFB.D_E_L_E_T_ <> '*' ) AS TAXNCONC, "

			cQuery += "(SELECT SUM(FIFB.FIF_VLBRUT - FIFB.FIF_VLLIQ) "
			cQuery += "FROM " + AllTrim(RetSqlTab("FIF")) + "B "
			cQuery += "WHERE FIFB.FIF_FILIAL =  FIF.FIF_FILIAL " 
			cQuery += "AND FIFB.FIF_DTTEF = FIF.FIF_DTTEF "
			cQuery += "AND FIFB.FIF_CODFIL = FIF.FIF_CODFIL "
			cQuery += "AND FIFB.FIF_TPPROD = FIF.FIF_TPPROD "
			cQuery += "AND FIFB.FIF_CODADM = FIF.FIF_CODADM "
			cQuery += "AND FIFB.FIF_CODRED = FIF.FIF_CODRED "
			cQuery += "AND FIFB.FIF_TPREG = '1' " 
			cQuery += "AND FIFB.D_E_L_E_T_ <> '*' ) AS TAXTOTAL "

			cQuery += "FROM " + RetSqlTab("FIF")
			//If !Empty(MV_PAR02)
				cQuery += "WHERE FIF.FIF_FILIAL = '" + xFilial("FIF") + "' "
			//Else
			//	cQuery += "WHERE FIF.FIF_FILIAL >= '' "
			//EndIf
			cQuery += "AND FIF.FIF_DTTEF = '" + DtoS(MV_PAR01) + "' "
			cQuery += "AND FIF.FIF_CODFIL = '" + xFilial("FIF")  + "' "
			cQuery += "AND FIF.FIF_TPREG = '1' " 
			
			If MV_PAR03 == 2
				cQuery += "AND FIF.FIF_TPPROD = 'C ' " 
			ElseIf MV_PAR03 == 3
				cQuery += "AND FIF.FIF_TPPROD = 'D ' "
			ElseIf MV_PAR03 == 4
				cQuery += "AND FIF.FIF_TPPROD <> ' ' "
			EndIf
			
			cQuery += "AND FIF.D_E_L_E_T_ <> '*' "	
			cQuery += "ORDER BY FIF.FIF_FILIAL, FIF.FIF_DTTEF, FIF.FIF_CODADM, FIF.FIF_CODRED, FIF.FIF_TPPROD "	

			cQuery := ChangeQuery(cQuery)

			If Select(cAliasFIF) > 0
				(cAliasFIF)->(DbCloseArea())
			EndIf

			
			DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasFIF, .T., .T.)
			

			If (cAliasFIF)->(!Eof()) //.And. (MV_PAR03 == 1 .Or. (MV_PAR03 == 2 .And. AllTrim((cAliasFIF)->FIF_TPPROD) == "C") .Or. (MV_PAR03 == 3 .And. AllTrim((cAliasFIF)->FIF_TPPROD) == "D"))
				
				lFound		:= .T.
				nPos 		:= Len(oSubMod:aDataModel)
				oSubMod:DelAllLine()
				
				While (cAliasFIF)->(!Eof())

						aAux := Array(Len(aFields) + 2) 
						aAux[1]	:= cSequen
						aAux[2]	:= "C" + (cAliasFIF)->FIF_TPPROD
						
						DbSelectArea('SX5')
						SX5->(DbSetOrder(1))
						If SX5->(DbSeek(xFilial('SX5')+'G3'+(cAliasFIF)->FIF_CODRED))
							aAux[3]	:= AllTrim(SX5->X5_DESCRI)
						EndIf
						
						aAux[4]	:= (cAliasFIF)->TOTAL
						aAux[5]	:= (cAliasFIF)->NCONC
						aAux[6]	:= (cAliasFIF)->FIF_CODADM
						aAux[7]	:= (cAliasFIF)->FIF_CODRED

						nTotal 	+= (cAliasFIF)->TOTAL + (cAliasFIF)->TAXTOTAL
						
						/*Verificar calculo correto das taxas
						nTaxas 	+= (cAliasFIF)->TAXTOTAL
						nTaxAbe	+= (cAliasFIF)->TAXNCONC	 */	

						If (cAliasFIF)->FIF_TPPROD == 'D'
							nDebit += (cAliasFIF)->TOTAL
						Else
							nCredi += (cAliasFIF)->TOTAL
						EndIf

						/*For nX := 1 to oSubMod:Length()
							oSubMod:GoLine(nX)
							oSubMod:DeleteLine()
						Next*/
						
						oSubMod:AddLine(.T.)
						oSubMod:SetValue("SEQUENCIA", aAux[1])
						oSubMod:SetValue("TIPO"		, aAux[2])
						oSubMod:SetValue("DESC"		, aAux[3])
						oSubMod:SetValue("TOTTOT"	, aAux[4])
						oSubMod:SetValue("NONTOT"	, aAux[5])

						If aAux[5] > 0
							lNConc := .T.
						EndIf

						Aadd(aRetorno, {0 ,aAux})

						//Busca registros de cada sequencia do fechamento
						cQuery := "SELECT FIF.R_E_C_N_O_ "
						cQuery += "FROM " + RetSqlTab("FIF")
						cQuery += "WHERE FIF.FIF_FILIAL = '" + (cAliasFIF)->FIF_FILIAL + "' "
						cQuery += "AND FIF.FIF_DTTEF = '" + (cAliasFIF)->FIF_DTTEF + "' "
						cQuery += "AND FIF.FIF_CODADM = '" + (cAliasFIF)->FIF_CODADM  + "' "
						cQuery += "AND FIF.FIF_CODRED = '" + (cAliasFIF)->FIF_CODRED  + "' "
						cQuery += "AND FIF.FIF_TPPROD = '" + (cAliasFIF)->FIF_TPPROD  + "' "
						cQuery += "AND FIF.FIF_STATUS IN ('2','4') "
						cQuery += "AND FIF.D_E_L_E_T_ <> '*' "	
						
						cQuery := ChangeQuery(cQuery)

						If Select(cAliasFIFB) > 0
							(cAliasFIFB)->(DbCloseArea())
						EndIf

						
						DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasFIFB, .T., .T.)
						
						
						AAdd(aFIFSeq,{aAux,"FIF",{}})
						
						While (cAliasFIFB)->(!Eof())
							AAdd(aFIFSeq[Len(aFIFSeq),3],{(cAliasFIFB)->R_E_C_N_O_})
							(cAliasFIFB)->(DbSkip())
						EndDo
						
						(cAliasFIF)->(DbSkip())
						cSequen := Soma1(cSequen)

				EndDo

				//Calculo das taxas
				For nCount := 1 to Len(aFIF)
					
					lAchou := .F.

					FIF->(DbGoTo(aFIF[nCount,1]))
					DbSelectArea("SE1")
					SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					If SE1->(DbSeek(xFilial("SE1")+FIF->(FIF_PREFIX+FIF_NUM+FIF_PARC))) 
						
						While !SE1->(Eof()) .And. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA) == xFilial("SE1")+FIF->(FIF_PREFIX+FIF_NUM+FIF_PARC)
						
							If Empty(SE1->E1_BAIXA) .And. !SE1->E1_TIPO == "AB-"
								
								lAchou := .T.
								Exit
							
							EndIf

							SE1->(DbSkip())
						EndDo
						
						If lAchou
						
							DbSelectArea("SAE")
							SAE->(DbSetOrder(1))
							If SAE->(DbSeek(xFilial("SAE")+SE1->E1_XADMIN))
								//AAdd(aTitTax,{SE1->(Recno()),FIF->(Recno()),SAE->(Recno())})
								nTaxas 	+= SE1->E1_VALOR * (SAE->AE_TAXA / 100)

								//#TB20200224 Thiago Berna - Ajuste para considerar a divisao das taxas
								If AllTrim(SE1->E1_TIPO) == "CC"
									AAdd(aTitTaxC,{SE1->(Recno()),FIF->(Recno()),SAE->(Recno())})
									nTaxCC += SE1->E1_VALOR * (SAE->AE_TAXA / 100)
								ElseIf AllTrim(SE1->E1_TIPO) == "CD"
									AAdd(aTitTaxD,{SE1->(Recno()),FIF->(Recno()),SAE->(Recno())})
									nTaxCD += SE1->E1_VALOR * (SAE->AE_TAXA / 100)
								EndIf

							Else
								If !SE1->E1_TIPO == "AB-"
									If !MsgYesNo("Campo E1_XADMIN [" + AllTrim(SE1->E1_XADMIN) + "] do titulo [" + SE1->E1_FILIAL + ' - ' + SE1->E1_PREFIXO + ' - ' + SE1->E1_NUM + ' - ' + SE1->E1_PARCELA + ' - ' + SE1->E1_TIPO + "] n�o encontrado na tabela SAE. Taxa n�o calculada, deseja continuar ?")
										lErro := .T.
										DisarmTransaction()
										Exit
									EndIf
								EndIf
							EndIf

						Else
							
							lErro := .T.
							MsgInfo("Registro na SE1 n�o encontrado. Processo Cancelado.","Aten��o!")
							DisarmTransaction()
							Exit

						EndIf
					Else
						lErro := .T.
						MsgInfo("Registro na SE1 n�o encontrado. Processo Cancelado.","Aten��o!")
						DisarmTransaction()
						Exit
					EndIf                                                                                    
				Next nCount

				aAux := Array(Len(aFields) + 2) 
				aAux[1]	:= cSequen
				aAux[2]	:= "TC"
				aAux[3]	:= "TAXAS CREDITO"
				aAux[4]	:= Round(nTaxCC,2)//Round(nTaxas,2)
				aAux[5]	:= 0
				aAux[6]	:= ""
				aAux[7]	:= ""

				AAdd(aFIFSeq,{aAux,"TAXC",aTitTaxC})

				If nTaxCC > 0
					oSubMod:AddLine(.T.)
					oSubMod:SetValue("SEQUENCIA", cSequen)
					oSubMod:SetValue("TIPO"		, aAux[2])
					oSubMod:SetValue("DESC"		, aAux[3])
					oSubMod:SetValue("TOTTOT"	, aAux[4])
					oSubMod:SetValue("NONTOT"	, aAux[5])

					cSequen := Soma1(cSequen)

				EndIf

				

				aAux := Array(Len(aFields) + 2) 
				aAux[1]	:= cSequen
				aAux[2]	:= "TD"
				aAux[3]	:= "TAXAS DEBITO"
				aAux[4]	:= Round(nTaxCD,2)
				aAux[5]	:= 0
				aAux[6]	:= ""
				aAux[7]	:= ""
				
				AAdd(aFIFSeq,{aAux,"TAXD",aTitTaxD})

				If nTaxCD > 0
					oSubMod:AddLine(.T.)
					oSubMod:SetValue("SEQUENCIA", cSequen)
					oSubMod:SetValue("TIPO"		, aAux[2])
					oSubMod:SetValue("DESC"		, aAux[3])
					oSubMod:SetValue("TOTTOT"	, aAux[4])
					oSubMod:SetValue("NONTOT"	, aAux[5])

					cSequen := Soma1(cSequen)
				EndIf

				
				
				/*aAux := Array(Len(aFields) + 2) 
				aAux[1]	:= cSequen
				aAux[2]	:= "TX"
				aAux[3]	:= "TAXAS"
				aAux[4]	:= Round(nTaxas,2)
				aAux[5]	:= 0
				aAux[6]	:= ""
				aAux[7]	:= ""
				
				AAdd(aFIFSeq,{aAux,"TAX",aTitTax})
				If nTaxas > 0
					oSubMod:AddLine(.T.)
					oSubMod:SetValue("SEQUENCIA", cSequen)
					oSubMod:SetValue("TIPO"		, aAux[2])
					oSubMod:SetValue("DESC"		, aAux[3])
					oSubMod:SetValue("TOTTOT"	, aAux[4])
					oSubMod:SetValue("NONTOT"	, aAux[5])
				EndIf

				cSequen := Soma1(cSequen)*/

			EndIf

			If (MV_PAR03 == 1 .Or. MV_PAR03 == 4) 
				//Locaiza titulos R$
				cQuery := "SELECT SUM(SE1.E1_VALOR) AS E1_VALOR FROM " + RetSqlTab("SE1")
				//If !Empty(MV_PAR02)
					cQuery += "WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
				//Else
				//	cQuery += "WHERE SE1.E1_FILIAL >= '' "
				//EndIf
				cQuery += "AND SE1.E1_XCODEXT = '001' "
				cQuery += "AND SE1.E1_XDTCAIX = '" + DtoS(MV_PAR01) + "' "
				cQuery += "AND SE1.D_E_L_E_T_ <> '*' " 

				cQuery := ChangeQuery(cQuery)

				If Select(cAliasSE1) > 0
					(cAliasSE1)->(DbCloseArea())
				EndIf

				
				DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasSE1, .T., .T.)
				

				If (cAliasSE1)->(!Eof())

					If !lFound
						nPos := Len(oSubMod:aDataModel)
						oSubMod:DelAllLine()
					EndIf

					lFound		:= .T.
					
					While (cAliasSE1)->(!Eof())

						aAux := Array(Len(aFields) + 2) 
						aAux[1]	:= cSequen
						aAux[2]	:= "R$"
						aAux[3]	:= "DINHEIRO"
						aAux[4]	:= (cAliasSE1)->E1_VALOR
						aAux[5]	:= 0
						aAux[6]	:= ""
						aAux[7]	:= ""

						nDinhe += (cAliasSE1)->E1_VALOR
						nTotal += (cAliasSE1)->E1_VALOR
							
						oSubMod:AddLine(.T.)
						oSubMod:SetValue("SEQUENCIA", aAux[1])
						oSubMod:SetValue("TIPO"		, aAux[2])
						oSubMod:SetValue("DESC"		, aAux[3])
						oSubMod:SetValue("TOTTOT"	, aAux[4])
						oSubMod:SetValue("NONTOT"	, aAux[5])
						
						Aadd(aRetorno, {0 ,aAux})

						//Busca registros tipo dinheiro do fechamento
						cQuery := "SELECT SE1.R_E_C_N_O_ "
						cQuery += "FROM " + RetSqlTab("SE1")
						
						//If !Empty(MV_PAR02)
							cQuery += "WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
						//Else
						//	cQuery += "WHERE SE1.E1_FILIAL >= '' "
						//EndIf
						cQuery += "AND SE1.E1_XCODEXT = '001' "
						cQuery += "AND SE1.E1_XDTCAIX = '" + DtoS(MV_PAR01) + "' "
						cQuery += "AND SE1.D_E_L_E_T_ <> '*' " 	
								
						cQuery := ChangeQuery(cQuery)

						If Select(cAliasSE1B) > 0
							(cAliasSE1B)->(DbCloseArea())
						EndIf

						
						DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasSE1B, .T., .T.)
						
								
						AAdd(aFIFSeq,{aAux,"SE1",{}})
								
						While (cAliasSE1B)->(!Eof())
							AAdd(aFIFSeq[Len(aFIFSeq),3],{(cAliasSE1B)->R_E_C_N_O_})
							(cAliasSE1B)->(DbSkip())
						EndDo

						(cAliasSE1)->(DbSkip())
						cSequen := Soma1(cSequen)

					EndDo
				
				EndIf

			EndIf

			If MV_PAR03 == 1 
				//Locaiza titulos Cartao Madero
				cQuery := "SELECT SUM(SE1.E1_VALOR) AS E1_VALOR FROM " + RetSqlTab("SE1")
				//If !Empty(MV_PAR02)
					cQuery += "WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
				//Else
				//	cQuery += "WHERE SE1.E1_FILIAL >= '' "
				//EndIf
				cQuery += "AND SE1.E1_XCODEXT = '014' "
				cQuery += "AND SE1.E1_XDTCAIX = '" + DtoS(MV_PAR01) + "' "
				cQuery += "AND SE1.D_E_L_E_T_ <> '*' " 

				cQuery := ChangeQuery(cQuery)

				If Select(cAliasSE1) > 0
					(cAliasSE1)->(DbCloseArea())
				EndIf

				
				DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasSE1, .T., .T.)
				

				If (cAliasSE1)->(!Eof())
					
					If !lFound
						nPos := Len(oSubMod:aDataModel)
						oSubMod:DelAllLine()
					EndIf

					lFound		:= .T.
					
					While (cAliasSE1)->(!Eof())

						aAux := Array(Len(aFields) + 2) 
						aAux[1]	:= cSequen
						aAux[2]	:= "CM"
						aAux[3]	:= "CARTAO MADERO"
						aAux[4]	:= (cAliasSE1)->E1_VALOR
						aAux[5]	:= 0
						aAux[6]	:= ""
						aAux[7]	:= ""

						nTotal += (cAliasSE1)->E1_VALOR
							
						oSubMod:AddLine(.T.)
						oSubMod:SetValue("SEQUENCIA", aAux[1])
						oSubMod:SetValue("TIPO"		, aAux[2])
						oSubMod:SetValue("DESC"		, aAux[3])
						oSubMod:SetValue("TOTTOT"	, aAux[4])
						oSubMod:SetValue("NONTOT"	, aAux[5])
						
						Aadd(aRetorno, {0 ,aAux})

						//Busca registros tipo dinheiro do fechamento
						cQuery := "SELECT SE1.R_E_C_N_O_ "
						cQuery += "FROM " + RetSqlTab("SE1")
						
						//If !Empty(MV_PAR02)
							cQuery += "WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
						//Else
						//	cQuery += "WHERE SE1.E1_FILIAL >= '' "
						//EndIf
						cQuery += "AND SE1.E1_XCODEXT = '014' "
						cQuery += "AND SE1.E1_XDTCAIX = '" + DtoS(MV_PAR01) + "' "
						cQuery += "AND SE1.D_E_L_E_T_ <> '*' " 	
								
						cQuery := ChangeQuery(cQuery)

						If Select(cAliasSE1B) > 0
							(cAliasSE1B)->(DbCloseArea())
						EndIf

						
						DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasSE1B, .T., .T.)
						

						AAdd(aFIFSeq,{aAux,"SE1",{}})
								
						While (cAliasSE1B)->(!Eof())
							AAdd(aFIFSeq[Len(aFIFSeq),3],{(cAliasSE1B)->R_E_C_N_O_})
							(cAliasSE1B)->(DbSkip())
						EndDo

						(cAliasSE1)->(DbSkip())
						cSequen := Soma1(cSequen)

					EndDo
				
				EndIf

			EndIf

		EndIf

		If lFound
		
			//Recria array com os novos dados
			aSize(atemp,Len(oSubMod:aDataModel)-nPos)
			aCopy(oSubMod:aDataModel,aTemp,nPos + 1)
			oSubMod:aDataModel := aClone(aTemp)

		Else

			nPos := Len(oSubMod:aDataModel)
			oSubMod:DelAllLine()
			oSubMod:AddLine(.T.)
			oSubMod:SetValue("SEQUENCIA", "")
			oSubMod:SetValue("TIPO"		, "")
			oSubMod:SetValue("DESC"		, "")
			oSubMod:SetValue("TOTTOT"	, 0 )
			oSubMod:SetValue("NONTOT"	, 0 )

			If Len(oSubMod:aDataModel) > 1
				//Recria array com os novos dados
				aSize(atemp,Len(oSubMod:aDataModel)-nPos)
				aCopy(oSubMod:aDataModel,aTemp,nPos + 1)
				oSubMod:aDataModel := aClone(aTemp)
			EndIf
		
		EndIf

		oView:Refresh("TOTFLD7")

		//Restaura MV_PAR original
		MV_PAR01	:= cPar01
		MV_PAR02	:= cPar02
		MV_PAR03	:= cPar03
		//MV_PAR04	:= cPar04

		oModel:GetModel("TOTFLD7"):SetNoDeleteLine(.T.)
		oModel:GetModel("TOTFLD7"):SetNoInsertLine(.T.)
		oModel:GetModel("TOTFLD7"):SetNoUpdateLine(.T.)

		oModel:GetModel("TOTFLD7"):GoLine(1)

	Else
		aFields		:= oSubMod:GetStruct():GetFields()
	EndIf

	//Se n�o houver dados retorna um Array vazio
	If Len(aRetorno) == 0
		aAux 		:= Array(Len(aFields))
		aAux[01]	:= ""
		aAux[02]	:= ""
		aAux[03]	:= ""
		aAux[04]	:= 0
		aAux[05]	:= 0
	
		Aadd(aRetorno, {0 ,aAux})
	EndIf

	aAux		:= {}
	aFields     := {}

	If lErro
		aRetorno := {}
	EndIf

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} U_OIF910Ms
Painel com a o cabe�alho da aba de fechamento

@author Thiago Berna
@since 21/01/2020

/*/
//-------------------------------------------------------------------
User Function OIF910FC( oPanel )
	
	DEFINE FONT oFnt NAME "Arial" SIZE 11,20 
	@ 030, 010 SAY   "Refer�ncia" SIZE 050, 020 OF oPanel PIXEL FONT oFnt 
	@ 030, 100 MSGET __oRefer VAR cRefer SIZE 150, 10  Of oPanel PIXEL When .F.

	@ 030, 310 SAY   "Dinheiro" SIZE 050, 020 OF oPanel PIXEL FONT oFnt 
	@ 030, 400 MSGET __oDinhe VAR nDinhe SIZE 150, 10  Of oPanel PIXEL When .F. PICTURE PesqPict("SE1", "E1_VALOR")

	@ 045, 010 SAY   "Total" SIZE 050, 020 OF oPanel PIXEL FONT oFnt  
	@ 045, 100 MSGET __oTotal VAR nTotal SIZE 150, 10  Of oPanel PIXEL When .F. PICTURE PesqPict("SE1", "E1_VALOR")

	@ 045, 310 SAY   "D�bito" SIZE 050, 020 OF oPanel PIXEL FONT oFnt  
	@ 045, 400 MSGET __oDebit VAR nDebit SIZE 150, 10  Of oPanel PIXEL When .F. PICTURE PesqPict("SE1", "E1_VALOR")

	@ 060, 010 SAY   "Status" SIZE 050, 020 OF oPanel PIXEL FONT oFnt
	@ 060, 100 MSGET __oStatu VAR cStatu SIZE 150, 10  Of oPanel PIXEL When .F.

	@ 060, 310 SAY   "Cr�dito" SIZE 050, 020 OF oPanel PIXEL FONT oFnt 
	@ 060, 400 MSGET __oCredi VAR nCredi SIZE 150, 10  Of oPanel PIXEL When .F. PICTURE PesqPict("SE1", "E1_VALOR")

	@ 075, 310 SAY   "Taxas" SIZE 050, 020 OF oPanel PIXEL FONT oFnt 
	@ 075, 400 MSGET __oTaxas VAR nTaxas SIZE 150, 10  Of oPanel PIXEL When .F. PICTURE PesqPict("SE1", "E1_VALOR")
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OIF910MN
Painel com o totalizador da aba manual

@author Thiago Berna
@since 21/01/2020

/*/
//-------------------------------------------------------------------
User Function OIF910MN( oPanel )
	
	DEFINE FONT oFnt NAME "Arial" SIZE 11,20 
	@ 015, 010 SAY   "Totalizador" SIZE 050, 020 OF oPanel PIXEL FONT oFnt 

	@ 030, 010 SAY   "Arquivo" SIZE 050, 020 OF oPanel PIXEL FONT oFnt 
	@ 030, 100 MSGET __oValFIF VAR __nValFIF SIZE 150, 10  Of oPanel PIXEL When .F. PICTURE PesqPict("SE1", "E1_VALOR")

	@ 045, 010 SAY   "T�tulos" SIZE 050, 020 OF oPanel PIXEL FONT oFnt  
	@ 045, 100 MSGET __oValSE1 VAR __nValSE1 SIZE 150, 10  Of oPanel PIXEL When .F. PICTURE PesqPict("SE1", "E1_VALOR")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F910BTFC
Inclusao de Botao de confirma��o de fechamento

@author Thiago Berna
@since 21/01/2020

/*/
//-------------------------------------------------------------------
User Function F910BTFC( oPanel, nSheet, oView, lMsg )
	//Local oButton	As Object
	//Local oSay      As Object
	Local oModel	As Object
	//Local oView		As Object
	
	oModel		:= FWModelActive()
	oView 		:= FwViewActive()
	
	Default lMsg	:= .F.
	
	
	//@000, 075 BUTTON oButton PROMPT "Confirmar"  SIZE 070, 020 FONT oPanel:oFont ACTION Processa(	{|| OIF910FCOK(oView)},"Aguarde...","Executando o Fechamento...") OF oPanel PIXEL //OIF910Print(oView) OF oPanel PIXEL		//"Imprimir Browser"
	
	//@000, 150 BUTTON oButton PROMPT "Par�metros"  SIZE 070, 020 FONT oPanel:oFont ACTION Processa(	{|| fLoadFec(oView, 2), oView:Refresh("TOTFLD7"),__oRefer:Refresh(),__oDinhe:Refresh(),__oTotal:Refresh(),__oDebit:Refresh(),__oStatu:Refresh(),__oCredi:Refresh(),__oTaxas:Refresh()},"Aguarde...","Carregando...") OF oPanel PIXEL //OIF910Print(oView) OF oPanel PIXEL		//"Imprimir Browser"
	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OIF910FCOK
Executa o fechamento

@author Thiago Berna
@since 21/01/2020

/*/
//-------------------------------------------------------------------
Static Function OIF910FCOK( oPanel )

	Local oModel	As Object
	Local oView		As Object
	Local oSubZWX	As Object
	Local nLinZWX	As Numeric
	Local nCount	As Numeric
	Local nValTax	As Numeric
	Local nValAdm	As Numeric
	Local nValAnt	As Numeric
	Local cCodigo	As Character
	Local cQuery	As Character
	Local cAliasZWX	As Character
	Local cConAdm	As Character
	Local cCXLOJA	As Character
	Local cXBCCTP	As Character
	Local cLP		As Character
	Local lErro		As Logical
	Local aTitInd	As Array
	Local aTitABM	As Array
	Local aRecZWX	As Array
	Local dDataBkp	As Date

	Private lMsErroAuto As Logical

	oModel		:= FWModelActive()
	oView 		:= FwViewActive()
	oSubZWX 	:= oModel:GetModel("TOTFLD7")
	nLinZWX		:= 1
	nCount		:= 1
	nValTax		:= 0
	nValAdm		:= 0
	nValAnt		:= 0
	cQuery		:= ''
	cAliasZWX	:= GetNextAlias()
	cConAdm		:= SuperGetMv( "MV_XCONADM" , .T. , "000000;" )
	cCXLOJA		:= SuperGetMv( "MV_CXLOJA"  , .T. , "" )
	cXBCCTP		:= SuperGetMv( "MV_XBCCTP"  , .T. , "" )
	cLP			:= ""
	lErro		:= .F.
	aTitInd		:= {}
	aTitABM		:= {}
	aRecZWX		:= {}
	dDataBkp	:= CTOD('')

	If cStatu == "FECHADO"
		MsgInfo("Fechamento ja realizado! Opera��o Cancelada.","Aten��o!")
	Else
		
		If (__cUserId $ cConAdm .And. lNConc) .Or. !lNConc
		
			IF MsgYesNo("Confirma fechamento para o dia " + cRefer + " ?", "Confirma��o de Fechamento")

				//#TB20200207 Thiago Berna - AJuste para travar os registros do fechamento
				While !U_F910LckF(aFIFSeq)
					If !MsgYesNo("Controle de Concorr�ncia, Registros em uso por outra sess�o e n�o poder� ser selecionado. " + CRLF + "Deseja tentar novamente? ")
						
						//#TB20200813 - Fecha a tela quando confirma o fechamento 
						oView:lmodify := .F.
						oView:oOwner:End()

						//Unlock nos registros						
						FWMsgRun(, {|| U_F910ULkA() }, "Processo cancelado...", "Processo cancelado..." + " Aguarde... ")
						
						//Elimina oModel
						oModel := Nil

						//Refresh na tela principal
						oBrowseM:DeActivate()
						oBrowseM:Refresh()
						Return

					EndIf
				EndDo

				Begin Transaction

					ProcRegua(Len(aFIFSeq))
				
					For nLinZWX := 1 to Len(aFIFSeq)
					
						cCodigo := GetSX8Num("ZWX","ZWX_SEQ")

						//Verifica se existe problema com a numeracao do License Server para evitar log de erro.
						ZWX->(DbSetOrder(1))
						If ZWX->(DbSeek(xFilial('ZWX')+cCodigo))
							
							lErro := .T.
							MsgInfo("Processo cancelado devido a problema com o controle de numera��o no License Server[APCFC110]. Codigo gerado:" + cCodigo + " j� existente.","Aten��o!")

						Else
							
							//Gera tabela de fechamento
							ZWX->(RecLock("ZWX",.T.))
							ZWX->ZWX_FILIAL := xFilial("ZWX")
							ZWX->ZWX_SEQ	:= cCodigo
							ZWX->ZWX_DATA	:= CTOD(cRefer)
							ZWX->ZWX_TIPO	:= aFIFSeq[nLinZWX,1,2]
							ZWX->ZWX_TPADM	:= aFIFSeq[nLinZWX,1,6]
							ZWX->ZWX_REDE	:= aFIFSeq[nLinZWX,1,7]
							ZWX->ZWX_VALOR	:= aFIFSeq[nLinZWX,1,4]
							ZWX->ZWX_NCONC	:= aFIFSeq[nLinZWX,1,5]
							ZWX->ZWX_STATUS	:= 'A'
							ZWX->ZWX_CODUSR	:= __cUserID
							ZWX->ZWX_NOMUSR	:= UsrRetName(__cUserID)
							ZWX->ZWX_DATALT	:= dDataBase
							ZWX->(MsUnlock())

							//Armazena o recno da ZWX
							AAdd(aRecZWX,ZWX->(Recno()))

							//ConfirmSx8()

							//Marcar o campo E1_XSQFEFI dos registros conciliados
							If aFIFSeq[nLinZWX,2] == "FIF"							

								For nCount := 1 To Len(aFIFSeq[nLinZWX,3])

									DbSelectArea("FIF")
									FIF->(DbGoTo(aFIFSeq[nLinZWX,3,nCount,1]))

									DbSelectArea("SE1")
									SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
									If SE1->(DbSeek(xFilial("SE1")+FIF->(FIF_PREFIX+FIF_NUM+FIF_PARC))) 

										SE1->(RecLock("SE1",.F.))
										SE1->E1_XSQFEFI := cCodigo
										SE1->(MsUnlock())

									EndIf
								
								Next nCount
								
							EndIf

						EndIf
						
						
						If !lErro

							//Baixa Dinheiro
							If aFIFSeq[nLinZWX,1,2] == "R$"							

								For nCount := 1 To Len(aFIFSeq[nLinZWX,3])

									DbSelectArea("SE1")
									SE1->(DbGoTo(aFIFSeq[nLinZWX,3,nCount,1]))

									If Empty(SE1->E1_BAIXA)

										SE1->(RecLock("SE1",.F.))
										SE1->E1_XSQFEFI := cCodigo
										SE1->(MsUnlock())

										aTitInd	:=	{	{"E1_PREFIXO"		,SE1->E1_PREFIXO			,NiL},;
														{"E1_NUM"			,SE1->E1_NUM				,NiL},;
														{"E1_PARCELA"		,SE1->E1_PARCELA			,NiL},;
														{"E1_TIPO"			,SE1->E1_TIPO				,NiL},;
														{"E1_CLIENTE"		,SE1->E1_CLIENTE			,NiL},;
														{"E1_LOJA"			,SE1->E1_LOJA				,NiL},;
														{"AUTMOTBX"			,"NOR"						,Nil},;									
														{"AUTBANCO"			,PadR(StrTokArr(cCXLOJA,"/")[1],Len(SE8->E8_BANCO))		,Nil},;
														{"AUTAGENCIA"		,PadR(StrTokArr(cCXLOJA,"/")[2],Len(SE8->E8_AGENCIA))	,Nil},;
														{"AUTCONTA"			,PadR(StrTokArr(cCXLOJA,"/")[3],Len(SE8->E8_CONTA))		,Nil},;
														{"AUTDTBAIXA"		,SE1->E1_XDTCAIX			,Nil},;
														{"AUTDTCREDITO"		,SE1->E1_XDTCAIX			,Nil},;
														{"AUTHIST"			,"Conciliador SITEF"		,Nil},; //"Conciliador SITEF"
														{"AUTDESCONT"		,0							,Nil},; //Valores de desconto
														{"AUTACRESC"		,0							,Nil},; //Valores de acrescimo - deve estar cadastrado no titulo previamente
														{"AUTDECRESC"		,0							,Nil},; //Valore de decrescimo - deve estar cadastrado no titulo previamente
														{"AUTMULTA"			,0							,Nil},; //Valores de multa
														{"AUTJUROS"			,0							,Nil},; //Valores de Juros
														{"AUTVALREC"		,SE1->E1_VALOR				,Nil}}  //Valor recebido
											
										lMsErroAuto	:= .F.
					
										//Posiciona na SA1 e reserva
										//SA1->(DbSetOrder(1))
										//SA1->(DbSeek(xFilial('SA1') + SE1->E1_CLIENTE + SE1->E1_LOJA))
										//While !SA1->(DBRLock(Recno()))
										//EndDo
																						
										IncProc("Baixando Titulos R$...")
										MSExecAuto({|x, y| FINA070(x, y)}, aTitInd, 3)

										If lMsErroAuto
											lErro := .T.
											MostraErro()
											Exit
										EndIf
									EndiF

								Next nCount
								
							EndIf

						EndIf

						If !lErro
						
							//Baixa Cartao Madero
							If aFIFSeq[nLinZWX,1,2] == "CM"

								For nCount := 1 To Len(aFIFSeq[nLinZWX,3])

									DbSelectArea("SE1")
									SE1->(DbGoTo(aFIFSeq[nLinZWX,3,nCount,1]))

									If Empty(SE1->E1_BAIXA)
									
										SE1->(RecLock("SE1",.F.))
										SE1->E1_XSQFEFI := cCodigo
										SE1->(MsUnlock())

										aTitInd	:=	{	{"E1_PREFIXO"		,SE1->E1_PREFIXO			,NiL},;
														{"E1_NUM"			,SE1->E1_NUM				,NiL},;
														{"E1_PARCELA"		,SE1->E1_PARCELA			,NiL},;
														{"E1_TIPO"			,SE1->E1_TIPO				,NiL},;
														{"E1_CLIENTE"		,SE1->E1_CLIENTE			,NiL},;
														{"E1_LOJA"			,SE1->E1_LOJA				,NiL},;
														{"AUTMOTBX"			,"NOR"						,Nil},;
														{"AUTBANCO"			,PadR(StrTokArr(cXBCCTP,"/")[1],Len(SE8->E8_BANCO))		,Nil},;
														{"AUTAGENCIA"		,PadR(StrTokArr(cXBCCTP,"/")[2],Len(SE8->E8_AGENCIA))	,Nil},;
														{"AUTCONTA"			,PadR(StrTokArr(cXBCCTP,"/")[3],Len(SE8->E8_CONTA))		,Nil},;												
														{"AUTDTBAIXA"		,SE1->E1_XDTCAIX			,Nil},;
														{"AUTDTCREDITO"		,SE1->E1_XDTCAIX			,Nil},;
														{"AUTHIST"			,"Conciliador SITEF"		,Nil},; //"Conciliador SITEF"
														{"AUTDESCONT"		,0							,Nil},; //Valores de desconto
														{"AUTACRESC"		,0							,Nil},; //Valores de acrescimo - deve estar cadastrado no titulo previamente
														{"AUTDECRESC"		,0							,Nil},; //Valore de decrescimo - deve estar cadastrado no titulo previamente
														{"AUTMULTA"			,0							,Nil},; //Valores de multa
														{"AUTJUROS"			,0							,Nil},; //Valores de Juros
														{"AUTVALREC"		,SE1->E1_VALOR				,Nil}}  //Valor recebido
											
										lMsErroAuto	:= .F.

										//Posiciona na SA1 e reserva
										//SA1->(DbSetOrder(1))
										//SA1->(DbSeek(xFilial('SA1') + SE1->E1_CLIENTE + SE1->E1_LOJA))
										//While !SA1->(DBRLock(Recno()))
										//EndDo
					
										IncProc("Baixando Titulos Cart�o Madero...")
										MSExecAuto({|x, y| FINA070(x, y)}, aTitInd, 3)

										If lMsErroAuto
											lErro := .T.
											MostraErro()
											Exit
										EndIf

									EndIf

								Next nCount

							EndIf

						EndIf

						If !lErro

							//Gera titulos de taxa AB-
							//If aFIFSeq[nLinZWX,1,2] == "TX"
							If aFIFSeq[nLinZWX,1,2] == "TD" .Or. aFIFSeq[nLinZWX,1,2] == "TC" 
								
								For nCount := 1 To Len(aFIFSeq[nLinZWX,3])
								
									//Posiciona na tabela SE1
									DbSelectArea("SE1")
									SE1->(DbGoTo(aFIFSeq[nLinZWX,3,nCount,1]))

									//Posiciona na tabela FIF
									DbSelectArea("FIF")
									FIF->(DbGoTo(aFIFSeq[nLinZWX,3,nCount,2]))

									//Posiciona na tabela SAE
									DbSelectArea("SAE")
									SAE->(DbGoTo(aFIFSeq[nLinZWX,3,nCount,3]))

									nValAdm	:= Round(SE1->E1_VALOR * SAE->AE_TAXA / 100,2)
									nValAnt	:= Round(SE1->E1_VALOR * SAE->AE_XTAXANT / 100,2)
									nValTax := nValAdm + nValAnt
													
									aTitABM :={ 	{ "E1_PREFIXO"  , SE1->E1_PREFIXO					, NIL },;
													{ "E1_NUM"      , SE1->E1_NUM		         	  	, NIL },;
													{ "E1_PARCELA"  , SE1->E1_PARCELA					, NIL },;
													{ "E1_TIPO"     , "AB-"    							, NIL },;
													{ "E1_NATUREZ"  , SAE->AE_XNTXADM 					, NIL },;
													{ "E1_CLIENTE"  , SE1->E1_CLIENTE				   	, NIL },;
													{ "E1_LOJA"     , SE1->E1_LOJA          			, NIL },;
													{ "E1_EMISSAO"  , SE1->E1_EMISSAO					, NIL },;
													{ "E1_VENCTO"   , SE1->E1_VENCTO					, NIL },;
													{ "E1_VENCREA"  , SE1->E1_VENCREA					, NIL },;
													{ "E1_VALOR"    , nValTax						 	, NIL },;
													{ "E1_XNATADM"  , SAE->AE_XNTXADM 				 	, NIL },;
													{ "E1_XNATANT"  , SAE->AE_XNATANT 				 	, NIL },;
													{ "E1_XVLTXDM"  , nValAdm						 	, NIL },;
													{ "E1_XVLTXAN"  , nValAnt						 	, NIL }}
								
									lMsErroAuto := .F.
									
									//Ajusta data base para data de emissao para contabilizar corretamente
									dDataBkp := dDataBase
									dDataBase:= SE1->E1_XDTCAIX
									
									//Verifica se o titulo AB- ja foi criado
									DbSelectArea("SE1")
									SE1->(DbSetOrder(1))
									If !SE1->(DbSeek(SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA)+"AB-"))
									
										SetFunName("FINA040")
										IncProc("Gerando Titulos AB-...")

										//Posiciona na SA1 e reserva
										//SA1->(DbSetOrder(1))
										//SA1->(DbSeek(xFilial('SA1') + aTitABM[6,2] + aTitABM[7,2]))
										//While !SA1->(DBRLock(Recno()))
										//EndDo

										MsExecAuto({|x,y| FINA040(x,y)},aTitABM,3)
										
										SetFunName("OIFINA910")
										
										If lMsErroAuto
											lErro := .T.
											MostraErro()
											Exit							
										EndIf

									EndIf

									//Restaura database
									dDataBase := dDataBkp
														
								Next nCount

							EndIf	

						EndIf

						If !lErro
							ConfirmSx8()

							//Caso nao ocorra nenhum erro ajusta para Fechado
							ZWX->(RecLock("ZWX",.F.))						
							ZWX->ZWX_STATUS	:= 'F'
							ZWX->(MsUnlock())
							
							//Executa a contabilizacao online
							/*If lContab
									
								//Define o lan�amento padr�o
								If aFIFSeq[nLinZWX,1,2] == "CC"	
									cLP := "310" //Fechamento cart�o cr�dito
								ElseIf aFIFSeq[nLinZWX,1,2] == "CD"	
									cLP := "320" //Fechamento cart�o d�bito
								ElseIf aFIFSeq[nLinZWX,1,2] == "R$"	
									cLP := "330" //Fechamento Vendas Dinheiro
								ElseIf aFIFSeq[nLinZWX,1,2] == "TC"	
									cLP := "350" //Fechamento Vendas Taxas Credito
								ElseIf aFIFSeq[nLinZWX,1,2] == "TD"	
									cLP := "340" //Fechamento Vendas Taxas Debito
								ElseIf aFIFSeq[nLinZWX,1,2] == "CM"	
									cLP := "360" //Fechamento Cart�o Madero
								EndIf

								//Executa a contabiliza��o
								OIF910CONT(CTOD(cRefer),cLP )

							EndIf*/
						Else
							RollBackSX8()
							lErro := .T.
							Exit
						EndIf				
						
					Next nLinZWX

					If !lErro
						
						IncProc("Contabilizando...")
						
						//Contabilizacao
						For nLinZWX := 1 to Len(aRecZWX)
							//Posiciona no registro gerado na ZWX
							ZWX->(DbGoTo(aRecZWX[nLinZWX]))

							//Executa a contabilizacao online
							If lContab
									
								//Define o lan�amento padr�o
								If aFIFSeq[nLinZWX,1,2] == "CC"	
									cLP := "310" //Fechamento cart�o cr�dito
								ElseIf aFIFSeq[nLinZWX,1,2] == "CD"	
									cLP := "320" //Fechamento cart�o d�bito
								ElseIf aFIFSeq[nLinZWX,1,2] == "R$"	
									cLP := "330" //Fechamento Vendas Dinheiro
								ElseIf aFIFSeq[nLinZWX,1,2] == "TC"	
									cLP := "350" //Fechamento Vendas Taxas Credito
								ElseIf aFIFSeq[nLinZWX,1,2] == "TD"	
									cLP := "340" //Fechamento Vendas Taxas Debito
								ElseIf aFIFSeq[nLinZWX,1,2] == "CM"	
									cLP := "360" //Fechamento Cart�o Madero
								EndIf

								//Executa a contabiliza��o
								OIF910CONT(CTOD(cRefer),cLP )

							EndIf

						Next nLinZWX
						
						cStatu := "FECHADO"
						oView:Refresh("TOTFLD7")
						MsgInfo("Processo Conclu�do.","Aten��o!")
						
					Else
						//Desfaz registros do fechamento.
						DisarmTransaction()	

						//Estorna o fechamento
						/*For nLinZWX := 1 to Len(aRecZWX)
							//Posiciona no registro gerado na ZWX
							ZWX->(DbGoTo(aRecZWX[nLinZWX]))
							ZWX->(RecLock('ZWX',.F.))
							ZWX->(DbDelete())
							ZWX->(MsUnlock())

						Next nLinZWX*/
						
						MsgInfo("Processo cancelado devido a erros no processamento.","Aten��o!")
					EndIf

				End Transaction

				//Libera a SA1
				//SA1->(DBRUnlock())

			EndIf

		Else

			MsgInfo("Usu�rio sem permiss�o para realizar o fechamento com registros n�o conciliados. Verificar o par�metro MV_XCONADM.","Aten��o!")

		EndIf
	
	EndIf

	//#TB20200813 - Fecha a tela quando confirma o fechamento 
	oView:lmodify := .F.
	oView:oOwner:End()

	//Unlock nos registros
	U_F910ULkA()
	
	//Elimina oModel
	oModel := Nil

	//Refresh na tela principal
	oBrowseM:DeActivate()
	oBrowseM:Refresh()
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OIF910CONT
Executa a contabiliza��o

@author Thiago Berna
@since 23/01/2020

/*/
//-------------------------------------------------------------------
Static Function OIF910CONT(dData,cLP )

Local lLancOk		:= .F.
Private nHdlPrv		:= 0

Private cLote		:= SuperGetMv("MV_XLOTEFF",.T.,"009090")	// Lote cont�bil
Private cPadrao 	:= cLP 										// Lan�amento padr�o criado
private lPadrao 	:= VerPadrao(cPadrao) 						// Valida��o da exist�ncia do Lan�amento padr�o.
Private cProg 		:= "OIFINA910"								// Nome da rotina
Private cArquivo	:= "" 										// Nome do arquivo contra prova
Private lDigita 	:= .T. 										// Mostra o lan�amento na tela ou n�o.
Private lAglutina	:= .F.										// Aglutina o lan�amento ou n�o.
Private nTotal 		:= 0 										// Para o total da contabiliza��o.
Private nLinha		:= 1
Private dDataCont 	:= dData 									// Data para os lan�amentos.

If lPadrao
	//Cria Cabe�alho na contabiliza��o:
	//nHdlPrv := HeadProva(cLote,cProg,cUserName,@cArquivo)
	nHdlPrv := HeadProva(cLote,cProg,SubStr(cUsuario,7,6),@cArquivo )

	nTotal += DetProva(nHdlPrv,cPadrao,cProg,cLote)

	//Finaliza��o da contabiliza��o
	RodaProva(nHdlPrv,nTotal)

	//Gera os lan�amentos no CT2 na data "ddatacont"
	lLancOk := cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita, lAglutina,,dDataCont)
EndIf

Return lLancOk

//-------------------------------------------------------------------
/*/{Protheus.doc} fConcPOS
Executa a conciliacao POS

@author Thiago Berna
@since 29/01/2020

/*/
//-------------------------------------------------------------------
Static Function fConcPOS

Local cQuery	As Character
Local cAlias 	As Character
Local cAliasH	As Character
//Local cAliasH04 As Character
//Local cAliasH12	As Character
Local cAliasFIF As Character
//Local cEmissao	As Character
Local cHora		As Character
Local cHora12	As Character
Local cHora04	As Character
Local cMin010	As Character
Local cMin010i	As Character
Local cMin020	As Character
Local cMin035	As Character
Local cMin030	As Character
Local cMin040	As Character
Local cMin060	As Character
Local cMin120	As Character
Local cMin250	As Character
Local dData		As Date
//Local aFields   As Array

cQuery 		:= ""
cAlias 		:= GetNextAlias()
cAliasH 	:= GetNextAlias()
//cAliasH04	:= GetNextAlias()
//cAliasH12	:= GetNextAlias()
cAliasFIF	:= GetNextAlias()
cHora	:= ""
cHora04	:= ""
cHora12	:= ""
cMin010	:= ""
cMin010i:= ""
cMin020	:= ""
cMin035 := ""
cMin030	:= ""
cMin040	:= ""
cMin060	:= ""
cMin120	:= ""
cMin250	:= ""
dData	:= STOD("")

//If MsgYesNo("Conciliacao POS selecionada, confirma a operacao?")
	
	cQuery := "SELECT SE1.R_E_C_N_O_ FROM " + RetSqlTab("SE1") + CRLF
	cQuery += "WHERE E1_NSUTEF = '' AND " + CRLF
	
	cQuery += GetFilter(4, "SE1")

	cQuery := ChangeQuery(cQuery)

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	
	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAlias, .T., .T.)
	

	While (cAlias)->(!Eof())
	
		//posiciona no titulo
		SE1->(DbGoTo((cAlias)->(R_E_C_N_O_)))

		//SE1->E1_XDTCAIX - 12H
		cQuery := "SELECT TO_CHAR(TO_DATE('" + DTOC(SE1->E1_XDTCAIX) + ":" + SE1->E1_XHORAV + "','DD/MM/YYYY:HH24:MI:SS') - (12 /24), 'DD/MM/YYYY:HH24:MI:SS') DIA FROM DUAL "
		If Select(cAliasH) > 0
			(cAliasH)->(DbCloseArea())
		EndIf

		
		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasH, .T., .T.)
		

		cHora12 := (cAliasH)->DIA
		cHora12 := DTOS(CTOD(SubStr(cHora12,1,10))) + SubStr(cHora12,12,08) + ".000"
		
		//SE1->E1_XDTCAIX + 4H
		cQuery := "SELECT TO_CHAR(TO_DATE('" + DTOC(SE1->E1_XDTCAIX) + ":" + SE1->E1_XHORAV + "','DD/MM/YYYY:HH24:MI:SS') + (04 /24), 'DD/MM/YYYY:HH24:MI:SS') DIA FROM DUAL "
		If Select(cAliasH) > 0
			(cAliasH)->(DbCloseArea())
		EndIf

		
		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasH, .T., .T.)
		

		cHora04 := (cAliasH)->DIA
		cHora04 := DTOS(CTOD(SubStr(cHora04,1,10))) + SubStr(cHora04,12,08) + ".000"

		//SE1->E1_XDTCAIX
		cQuery := "SELECT TO_CHAR(TO_DATE('" + DTOC(SE1->E1_XDTCAIX) + ":" + SE1->E1_XHORAV + "','DD/MM/YYYY:HH24:MI:SS'), 'DD/MM/YYYY:HH24:MI:SS') DIA FROM DUAL "
		If Select(cAliasH) > 0
			(cAliasH)->(DbCloseArea())
		EndIf

		
		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasH, .T., .T.)
		

		cHora := (cAliasH)->DIA
		cHora := DTOS(CTOD(SubStr(cHora,1,10))) + SubStr(cHora,12,08) + ".000"

		//SE1->E1_XDTCAIX - 10MIN
		cQuery := "SELECT TO_CHAR(TO_DATE('" + DTOC(SE1->E1_XDTCAIX) + ":" + SE1->E1_XHORAV + "','DD/MM/YYYY:HH24:MI:SS') - (10/1440), 'DD/MM/YYYY:HH24:MI:SS') DIA FROM DUAL "
		If Select(cAliasH) > 0
			(cAliasH)->(DbCloseArea())
		EndIf

		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasH, .T., .T.)
		
		cMin010 := (cAliasH)->DIA
		cMin010 := DTOS(CTOD(SubStr(cMin010,1,10))) + SubStr(cMin010,12,08)

		
		//SE1->E1_XDTCAIX + 10MIN
		cQuery := "SELECT TO_CHAR(TO_DATE('" + DTOC(SE1->E1_XDTCAIX) + ":" + SE1->E1_XHORAV + "','DD/MM/YYYY:HH24:MI:SS') + (10/1440), 'DD/MM/YYYY:HH24:MI:SS') DIA FROM DUAL "
		If Select(cAliasH) > 0
			(cAliasH)->(DbCloseArea())
		EndIf

		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasH, .T., .T.)
		
		cMin010i := (cAliasH)->DIA
		cMin010i := DTOS(CTOD(SubStr(cMin010i,1,10))) + SubStr(cMin010i,12,08)


		//SE1->E1_XDTCAIX - 20MIN
		cQuery := "SELECT TO_CHAR(TO_DATE('" + DTOC(SE1->E1_XDTCAIX) + ":" + SE1->E1_XHORAV + "','DD/MM/YYYY:HH24:MI:SS') - (20/1440), 'DD/MM/YYYY:HH24:MI:SS') DIA FROM DUAL "
		If Select(cAliasH) > 0
			(cAliasH)->(DbCloseArea())
		EndIf

		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasH, .T., .T.)
		
		cMin020 := (cAliasH)->DIA
		cMin020 := DTOS(CTOD(SubStr(cMin020,1,10))) + SubStr(cMin020,12,08)

		//SE1->E1_XDTCAIX - 35MIN
		cQuery := "SELECT TO_CHAR(TO_DATE('" + DTOC(SE1->E1_XDTCAIX) + ":" + SE1->E1_XHORAV + "','DD/MM/YYYY:HH24:MI:SS') - (35/1440), 'DD/MM/YYYY:HH24:MI:SS') DIA FROM DUAL "
		If Select(cAliasH) > 0
			(cAliasH)->(DbCloseArea())
		EndIf

		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasH, .T., .T.)
		
		cMin035 := (cAliasH)->DIA
		cMin035 := DTOS(CTOD(SubStr(cMin035,1,10))) + SubStr(cMin035,12,08)

		//SE1->E1_XDTCAIX + 30MIN
		cQuery := "SELECT TO_CHAR(TO_DATE('" + DTOC(SE1->E1_XDTCAIX) + ":" + SE1->E1_XHORAV + "','DD/MM/YYYY:HH24:MI:SS') + (30/1440), 'DD/MM/YYYY:HH24:MI:SS') DIA FROM DUAL "
		If Select(cAliasH) > 0
			(cAliasH)->(DbCloseArea())
		EndIf

		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasH, .T., .T.)
		
		cMin030 := (cAliasH)->DIA
		cMin030 := DTOS(CTOD(SubStr(cMin030,1,10))) + SubStr(cMin030,12,08)


		//SE1->E1_XDTCAIX - 40MIN
		cQuery := "SELECT TO_CHAR(TO_DATE('" + DTOC(SE1->E1_XDTCAIX) + ":" + SE1->E1_XHORAV + "','DD/MM/YYYY:HH24:MI:SS') - (40/1440), 'DD/MM/YYYY:HH24:MI:SS') DIA FROM DUAL "
		If Select(cAliasH) > 0
			(cAliasH)->(DbCloseArea())
		EndIf
		
		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasH, .T., .T.)

		cMin040 := (cAliasH)->DIA
		cMin040 := DTOS(CTOD(SubStr(cMin040,1,10))) + SubStr(cMin040,12,08)


		//SE1->E1_XDTCAIX - 60MIN
		cQuery := "SELECT TO_CHAR(TO_DATE('" + DTOC(SE1->E1_XDTCAIX) + ":" + SE1->E1_XHORAV + "','DD/MM/YYYY:HH24:MI:SS') - (60/1440), 'DD/MM/YYYY:HH24:MI:SS') DIA FROM DUAL "
		If Select(cAliasH) > 0
			(cAliasH)->(DbCloseArea())
		EndIf
		
		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasH, .T., .T.)

		cMin060 := (cAliasH)->DIA
		cMin060 := DTOS(CTOD(SubStr(cMin060,1,10))) + SubStr(cMin060,12,08)


		//SE1->E1_XDTCAIX - 120MIN
		cQuery := "SELECT TO_CHAR(TO_DATE('" + DTOC(SE1->E1_XDTCAIX) + ":" + SE1->E1_XHORAV + "','DD/MM/YYYY:HH24:MI:SS') - (120/1440), 'DD/MM/YYYY:HH24:MI:SS') DIA FROM DUAL "
		If Select(cAliasH) > 0
			(cAliasH)->(DbCloseArea())
		EndIf
		
		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasH, .T., .T.)

		cMin120 := (cAliasH)->DIA
		cMin120 := DTOS(CTOD(SubStr(cMin120,1,10))) + SubStr(cMin120,12,08)


		//SE1->E1_XDTCAIX - 250MIN
		cQuery := "SELECT TO_CHAR(TO_DATE('" + DTOC(SE1->E1_XDTCAIX) + ":" + SE1->E1_XHORAV + "','DD/MM/YYYY:HH24:MI:SS') - (250/1440), 'DD/MM/YYYY:HH24:MI:SS') DIA FROM DUAL "
		If Select(cAliasH) > 0
			(cAliasH)->(DbCloseArea())
		EndIf
		
		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasH, .T., .T.)

		cMin250 := (cAliasH)->DIA
		cMin250 := DTOS(CTOD(SubStr(cMin250,1,10))) + SubStr(cMin250,12,08)


		cQuery := ' SELECT * FROM (SELECT ' + CRLF
		
		cQuery += " FIF.R_E_C_N_O_ AS TABLE_ID , " + CRLF
		
		cQuery += "(" + CRLF

		//data + hora
		cQuery += "CASE " + CRLF
		IF ! empty(retNum(SE1->E1_XHORAV))
			
			cQuery += " WHEN CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) >= '" + cMin010 + "' AND CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) <= '" + SubStr(cHora,1,Len(cHora) - 4)  + "' THEN 50 " + CRLF
			//cQuery += " WHEN CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) >= '" + cMin020 + "' AND CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) <= '" + SubStr(cHora,1,Len(cHora) - 4)  + "' THEN 30 " + CRLF
			cQuery += " WHEN CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) >= '" + cMin020 + "' AND CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) <= '" + SubStr(cHora,1,Len(cHora) - 4)  + "' THEN 45 " + CRLF
			cQuery += " WHEN CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) >= '" + cMin035 + "' AND CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) <= '" + SubStr(cHora,1,Len(cHora) - 4)  + "' THEN 40 " + CRLF
			
			cQuery += " WHEN CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) >= '" + cMin040 + "' AND CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) <= '" + SubStr(cHora,1,Len(cHora) - 4)  + "' THEN 15 " + CRLF
			cQuery += " WHEN CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) >= '" + cMin060 + "' AND CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) <= '" + SubStr(cHora,1,Len(cHora) - 4)  + "' THEN 10 " + CRLF
			cQuery += " WHEN CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) >= '" + cMin120 + "' AND CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) <= '" + SubStr(cHora,1,Len(cHora) - 4)  + "' THEN 5 "  + CRLF
			cQuery += " WHEN CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) >= '" + cMin250 + "' AND CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) <= '" + SubStr(cHora,1,Len(cHora) - 4)  + "' THEN 1 "  + CRLF
			//#TB20200409 Thiago Berna - Criado nova regra para pontuar quando o horario da SE1 for maior que o da FIF
			cQuery += " WHEN CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) >= '" + SubStr(cHora,1,Len(cHora) - 4) + "' AND CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) <= '" + cMin010i + "' THEN 50 " + CRLF
			cQuery += " WHEN CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) >= '" + SubStr(cHora,1,Len(cHora) - 4) + "' AND CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) <= '" + cMin030  + "' THEN 1 "  + CRLF
		Else
			//#TB20200130 Thiago Berna - Ajuste para considerar o campo concatenado
			//cQuery += " WHEN FIF.FIF_DTTEF = '" + cHora + "' THEN 20 "
			cQuery += " WHEN CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) = '" + cHora + "' THEN 20 " + CRLF
		EndIF
		cQuery += " ELSE - 1 END " + CRLF

		//valor
		cQuery += " + CASE WHEN FIF.FIF_VLBRUT = " + cValToChar(SE1->E1_SALDO) + " THEN 50 WHEN FIF.FIF_VLBRUT < " + cValToChar(SE1->E1_SALDO) + " THEN 15 ELSE -100 END " + CRLF

		//bandeira
		IF ! empty(SE1->E1_XADMIN)

			SAE->( DbSetOrder(1) )
			SAE->( MsSeek( xFilial("SAE") + SE1->E1_XADMIN ) )

			IF SAE->( Found() ) .And. ! Empty(SAE->AE_TCBAND)
				cQuery += " + CASE WHEN FIF.FIF_CODBAN = '" + SAE->AE_TCBAND + "' THEN 15 ELSE 0 END " + CRLF
			EndIF

		EndIF

		//modalidade
		cQuery += " + CASE WHEN FIF.FIF_TPPROD = '" + SubStr(SE1->E1_TIPO,2,1) + "' THEN 10 ELSE 0 END " + CRLF

		cQuery += ") * -1 AS MATCH " + CRLF
		
		cQuery += " FROM " + RetSqlTab("FIF") + CRLF
		cQuery += " WHERE" + CRLF
		cQuery += " FIF.FIF_CODFIL  = '" + SE1->E1_FILIAL + "'" + CRLF

		IF !Empty(RetNum(SE1->E1_XHORAV))
			//pagamentos at� 12 horas antes da venda
			cQuery += " AND CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) >= '" + cHora12 + "' " + CRLF
			//e at� 4 horas depois
			cQuery += " AND CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) <= '" + cHora04 + "' " + CRLF
		Else
			cQuery += " AND CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) >= '" + DTOS(DaySub(SE1->E1_XDTCAIX,1)) + SE1->E1_XHORAV + ".000" + "' " + CRLF
			cQuery += " AND CONCAT(FIF.FIF_DTTEF,FIF.FIF_HRTEF) <= '" + cHora + "' " + CRLF
		EndIF
		cQuery += " AND FIF.D_E_L_E_T_  <> '*' " + CRLF
		cQuery += " ) PAYMENTS WHERE PAYMENTS.MATCH <= 0 ORDER BY MATCH" + CRLF

		cQuery := ChangeQuery(cQuery)
		
		If Select(cAliasFIF) > 0
			(cAliasFIF)->(DbCloseArea())
		EndIf
		
		
		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasFIF, .T., .T.)
		

		IF (cAliasFIF)->MATCH <= MAGIC_VALUE

			//Posiciona na FIF
			FIF->(DbGoTo((cAliasFIF)->(TABLE_ID)))

			//Gravar NSU no registro da SE1
			SE1->(RecLock("SE1",.F.))
			SE1->E1_NSUTEF := FIF->FIF_NSUTEF
			SE1->E1_CARTAUT:= FIF->FIF_CODAUT
			SE1->E1_XNSUORI  := 'POS'
			//SE1->E1_VENCREA := FIF->FIF_DTCRED
			SE1->(MsUnlock())

			//Gravar Parcela da SE1 na FIF
			FIF->(RecLock("FIF",.F.))
			FIF->FIF_PARALF := SE1->E1_PARCELA
			FIF->(MsUnlock())

		EndIf

		(cAlias)->(DbSkip())
	EndDo

//EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F910LckA
Realiza lock de todos os registros em trabalho

@author Thiago Berna
@since 07/02/2020

/*/
//-------------------------------------------------------------------
User Function F910LckA()

Local lRet		As Logical
Local cFiltro	As Character
Local cAliasFIF	As Character
Local cAliasSE1	As Character

lRet		:= .T.
cFiltro		:= ""
cAliasFIF	:= GetNextAlias()
cAliasSE1	:= GetNextAlias()

//Lock FIF
cFiltro := "SELECT FIF.R_E_C_N_O_ FIF, SE1.R_E_C_N_O_ SE1 FROM " + RetSqlTab('FIF') + " " 

cFiltro += "FULL OUTER JOIN " + RetSqlTab("SE1") + " "
cFiltro += "ON SE1.E1_FILORIG = FIF.FIF_CODFIL "
cFiltro += "AND SE1.E1_NSUTEF = FIF.FIF_NSUTEF "
cFiltro += "AND SE1.E1_XDTCAIX = FIF.FIF_DTTEF "
cFiltro += "AND SE1.E1_VALOR = FIF.FIF_VLBRUT "
cFiltro += "AND SE1.D_E_L_E_T_ <> '*' "

If cSelFilial == 1
	If Len( __aSelFil ) <= 0
		cFiltro += "WHERE FIF.FIF_CODFIL = '" + xFilial("FIF", __cFilAnt)  + "' "
	Else
		If !__lTodFil
			cFiltro += "WHERE FIF.FIF_CODFIL " + GetRngFil( __aSelFil, 'FIF', .T.,, 20, .T. ) + " "
		EndIf
	EndIf	
Else
	cFiltro += "WHERE FIF.FIF_CODFIL = '" + xFilial("FIF", __cFilAnt)  + "' "
EndIf

cFiltro += " AND FIF.FIF_DTTEF >= '" + DtoS(dDataCredI) + "' "
cFiltro += "AND FIF.FIF_DTTEF <= '" + DtoS(dDataCredF) + "' "

If !__lProcDocTEF
	cFiltro += "AND FIF.FIF_NSUARQ >= '" + cNsuInicial + "' "
	cFiltro += "AND FIF.FIF_NSUARQ <= '" + cNsuFinal + "' "
ElseIf __lDocTef
	cFiltro += "AND FIF.FIF_DOCTEF >= '" + cNsuInicial + "' "
	cFiltro += "AND FIF.FIF_DOCTEF <= '" + cNsuFinal + "' "
EndIf
				
If cTipoPagam == 1
	cFiltro += "AND FIF.FIF_TPPROD IN ('D','V') "
ElseIf cTipoPagam == 2
	cFiltro += "AND FIF.FIF_TPPROD = 'C' "
Else
	cFiltro += "AND FIF.FIF_TPPROD IN ('D','V','C') "
EndIf

cFiltro += "AND FIF.D_E_L_E_T_ <> '*' "

cFiltro := ChangeQuery(cFiltro)

If Select(cAliasFIF) > 0
	(cAliasFIF)->(DbCloseArea())
EndIf


DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cFiltro), cAliasFIF, .T., .T.)



While !(cAliasFIF)->(Eof())

	DbSelectArea("FIF")
	If (cAliasFIF)->FIF > 0
		FIF->( dbGoTo( (cAliasFIF)->FIF ) )
		If FIF->( DbRLock( (cAliasFIF)->FIF ) )
			lRet := .T.
		Else
			lRet := .F.
			Exit
		EndIf
	EndIf

	DbSelectArea("SE1")
	If (cAliasFIF)->SE1 > 0
		SE1->( dbGoTo( (cAliasFIF)->SE1 ) )
		If SE1->( DbRLock( (cAliasFIF)->SE1 ) )
			lRet := .T.
		Else
			lRet := .F.
			Exit
		EndIf
	EndIf

	

	(cAliasFIF)->(DbSkip())
EndDo



//Lock SE1
cFiltro := "SELECT R_E_C_N_O_ FROM " + RetSqlName('SE1') 	
		
If cSelFilial == 1
	If Len( __aSelFil ) <= 0
		cFiltro += " WHERE E1_MSFIL = '" + xFilial("FIF", __cFilAnt)  + "' " 
	Else
		If !__lTodFil
			cFiltro += " WHERE E1_MSFIL " + GetRngFil( __aSelFil, 'FIF', .T.,, 20, .T. ) + " "
		EndIf
	EndIf	
Else
	cFiltro += " WHERE E1_MSFIL = '" + xFilial("FIF", __cFilAnt)  + "' "
EndIf

cFiltro += " AND E1_XDTCAIX >= '" + DtoS(dDataCredI) + "' "
cFiltro += "AND E1_XDTCAIX <= '" + DtoS(dDataCredF) + "' "

If cTipoPagam == 1  
	cFiltro += "AND E1_TIPO = 'CD' "
ElseIf cTipoPagam == 2
	cFiltro += "AND E1_TIPO = 'CC' "
Else
	cFiltro += "AND E1_TIPO IN ('CC','CD') "
EndIf	

If Select(cAliasSE1) > 0
	(cAliasSE1)->(DbCloseArea())
EndIf

DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cFiltro), cAliasSE1, .T., .T.)

While !(cAliasSE1)->(Eof())

	If SE1->( DbRLock( (cAliasSE1)->R_E_C_N_O_ ) )
		lRet := .T.
	Else
		lRet := .F.
		Exit
	EndIf

	(cAliasSE1)->(DbSkip())
EndDo
						
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F910ULkA
Realiza Unlock de todos os registros em trabalho

@author Thiago Berna
@since 07/02/2020

/*/
//-------------------------------------------------------------------
User Function F910ULkA()

	Local aSE1		As Array
	Local aFIF		As Array
	Local nCount 	As Numeric

	aSE1 := SE1->(DBRLockList())
	aFIF := FIF->(DBRLockList())

	For nCount := 1 to Len(aSE1)
		SE1->( DBRUnlock( aSE1[nCount] ) )
	Next nCount

	For nCount := 1 to Len(aFIF)
		FIF->( DBRUnlock( aFIF[nCount] ) )
	Next nCount
						
Return

/*User Function TESTE1

Local cretorno 	:= ""
Local oView 	:= FwViewActive()
Local aFolder := oView:GetFolderActive(OVIEW:AFOLDERS[1][1],2 )[1]

alert('1')

return cRetorno*/

//-------------------------------------------------------------------
/*/{Protheus.doc} OIF910OK
A��o do bot�o confirmar

@author Thiago Berna
@since 07/02/2020

/*/
//-------------------------------------------------------------------
User Function OIF910OK(oSubMod As Object)

Local oModel	As Object
Local oView		As Object
Local nSheet	As Numeric
	
	If !Empty(FWModelActive())
		oModel 	:= FWModelActive()	
	Else
		oModel	:= oSubMod
	EndIf

	oView		:= FwViewActive()
	
	If oView:GetFolderActive("FOLGRIDS", 2)[1] <= 5
		nSheet := oView:GetFolderActive("FOLGRIDS", 2)[1]
	ElseIf oView:GetFolderActive("FOLGRIDS", 2)[2] == "Pagamentos"
		nSheet := 8
	ElseIf oView:GetFolderActive("FOLGRIDS", 2)[2] == "Totais"
		nSheet := 6
	ElseIf oView:GetFolderActive("FOLGRIDS", 2)[2] == "Fechamento"
		nSheet := 7
	EndIf

	
	If nSheet == 7
		Processa(	{|| OIF910FCOK(oView)},"Aguarde...","Executando o Fechamento...") 
	Else
		Processa(	{|| U_OIF910Gv(nSheet,oModel,MV_PAR01,MV_PAR02),__nValFIF := 0,__nValSE1 := 0,oView:Refresh('FIFFLD1'),oView:Refresh('SE1FLD1'),oView:Refresh('FIFFLD5'),oView:Refresh('SE1FLD5'),U_F910LckA()},"Aguarde...","Executando...")
	EndIf

return

//-------------------------------------------------------------------
/*/{Protheus.doc} F910LckF
Realiza lock de todos os registros em trabalho no fechamento

@author Thiago Berna
@since 07/02/2020

/*/
//-------------------------------------------------------------------
User Function F910LckF(aFIFSeq)

	Local lRet		As Logical
	Local nCount	As Numeric
	Local nLinZWX	As Numeric
	Local nFIF		As Numeric
	Local nSE1		As Numeric

	lRet := .T.
	nFIF := 0
	nSE1 := 0

	For nLinZWX := 1 to Len(aFIFSeq)
						
		//Marcar o campo E1_XSQFEFI dos registros conciliados
		If aFIFSeq[nLinZWX,2] == "FIF"							

			For nCount := 1 To Len(aFIFSeq[nLinZWX,3])

				FIF->(DbGoTo(aFIFSeq[nLinZWX,3,nCount,1]))
				
				//Lock FIF
				If aScan(FIF->(DBRLockList()), {|x| x == FIF->( Recno() )}) == 0 
					If FIF->( DbRLock(Recno()) )
						lRet := .T.
						nFIF++
					Else
						lRet := .F.
						Exit
					EndIf
				EndIf

				SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				If SE1->(DbSeek(xFilial("SE1")+FIF->(FIF_PREFIX+FIF_NUM+FIF_PARC))) 
					
					//Lock SE1		
					If aScan(SE1->(DBRLockList()), {|x| x == SE1->( Recno() )}) == 0 
						If SE1->( DbRLock(Recno()) )
							lRet := .T.
							nSE1++
						Else
							lRet := .F.
							Exit
						EndIf
					EndIf

				EndIf
	
			Next nCount
								
		EndIf

		If lRet

			//Baixa Dinheiro
			If aFIFSeq[nLinZWX,1,2] == "R$"	

				For nCount := 1 To Len(aFIFSeq[nLinZWX,3])

					SE1->(DbGoTo(aFIFSeq[nLinZWX,3,nCount,1]))
						
						//Lock SE1		
						If aScan(SE1->(DBRLockList()), {|x| x == SE1->( Recno() )}) == 0 
							If SE1->( DbRLock(Recno()) )
								lRet := .T.
								nSE1++
							Else
								lRet := .F.
								Exit
							EndIf
						EndIf
										
				Next nCount
								
			EndIf

		EndIf

		If lRet
						
			//Baixa Cartao Madero
			If aFIFSeq[nLinZWX,1,2] == "CM"

				For nCount := 1 To Len(aFIFSeq[nLinZWX,3])

					DbSelectArea("SE1")
					SE1->(DbGoTo(aFIFSeq[nLinZWX,3,nCount,1]))
						
						//Lock SE1		
						If aScan(SE1->(DBRLockList()), {|x| x == SE1->( Recno() )}) == 0 
							If SE1->( DbRLock(Recno()) )
								lRet := .T.
								nSE1++
							Else
								lRet := .F.
								Exit
							EndIf
						EndIf

				Next nCount

			EndIf

		EndIf

		If lRet

			//Gera titulos de taxa AB-
			If aFIFSeq[nLinZWX,1,2] == "TD" .Or. aFIFSeq[nLinZWX,1,2] == "TC" 
								
				For nCount := 1 To Len(aFIFSeq[nLinZWX,3])
								
					//Posiciona na tabela SE1
					SE1->(DbGoTo(aFIFSeq[nLinZWX,3,nCount,1]))
					
					//Lock SE1		
					If aScan(SE1->(DBRLockList()), {|x| x == SE1->( Recno() )}) == 0 
						If SE1->( DbRLock(Recno()) )
							lRet := .T.
							nSE1++
						Else
							lRet := .F.
							Exit
						EndIf
					EndIf

					//Posiciona na tabela FIF
					FIF->(DbGoTo(aFIFSeq[nLinZWX,3,nCount,2]))
				
					//Lock FIF
					If aScan(FIF->(DBRLockList()), {|x| x == FIF->( Recno() )}) == 0 
						If FIF->( DbRLock(Recno()) )
							lRet := .T.
							nFIF++
						Else
							lRet := .F.
							Exit
						EndIf
					EndIf
																	
				Next nCount

			EndIf	

		EndIf
					
	Next nLinZWX
						
Return lRet