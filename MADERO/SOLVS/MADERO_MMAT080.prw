#include 'protheus.ch'
#include 'fwcommand.ch'

#define nSAY   1



static lSimple
static lLot



/*/{Protheus.doc} MMat080Simple
Chama wizard de copia simples do registros posicionado

@author Rafael Ricardo Vieceli
@since 03/2018
@version 1.0

@type function
/*/
user function MMat080Simple()

	wizard()

return


/*/{Protheus.doc} MMat080Lot
Chama wizard de copia em lote da filial do registro posicionado

@author Rafael Ricardo Vieceli
@since 03/2018
@version 1.0

@type function
/*/
user function MMat080Lot()

	wizard()

return




/*/{Protheus.doc} wizard
Wizard para cópia de TES

@author Rafael Ricardo Vieceli
@since 03/2018
@version 1.0

@type function
/*/
static function wizard()

	Local oWizard
	Local oStep

	//cria alias temporario com as empresas/filiais
	Local oTempEmps
	Local oBrowseEmps

	Local aDuplicates := {}

	Local aExceptions := {}

	Local oTempRegs
	Local oBrowseRegs

	lSimple := IsInCallStack('u_MMat080Simple')
	lLot    := IsInCallStack('u_MMat080Lot')

	oWizard := FWWizardControl():New()
	oWizard:setSize({600,800})
	oWizard:ActiveUISteps()

	oStep := oWizard:AddStep("1")
	oStep:SetStepDescription("Origem")
	oStep:SetConstruction({|panel| origin(panel)})
	oStep:SetNextAction({|| .T. })
	oStep:SetCancelAction({|| .T. })
	oStep:SetNextTitle("Confirmar")

	oStep := oWizard:AddStep("2")
	oStep:SetStepDescription("Destino")
	oStep:SetConstruction({|panel| destination(panel, oTempEmps := makeTempEmps(), oBrowseEmps := FWBrowse():New())})
	oStep:SetNextAction({|| validateAtLastOne(oBrowseEmps) })
	oStep:SetCancelAction({|| .T. })
	oStep:setPrevWhen({|| .F. })

	IF lSimple
		//descrição do proximo passo do passo anterior
		oStep:SetNextTitle("Validar")

		oStep := oWizard:AddStep("3")
		oStep:SetStepDescription("Duplicidades")
		oStep:SetConstruction({|panel| simpleConfirmation(panel, oTempEmps, @aDuplicates) })
		oStep:SetNextAction({|| .T. })
		oStep:SetCancelAction({|| .T. })
		oStep:setPrevWhen({|| .F. })
		oStep:SetNextTitle("Copiar")
	EndIF

	IF lLot
		//descrição do proximo passo do passo anterior
		oStep:SetNextTitle("Selecionar")

		oStep := oWizard:AddStep("3")
		oStep:SetStepDescription("Selecionar")
		oStep:SetConstruction({|panel| selectRegisters(panel, oTempRegs := makeTempRegs(), oBrowseRegs := FWBrowse():New()) })
		oStep:SetNextAction({|| validateAtLastOne(oBrowseRegs) })
		oStep:SetCancelAction({|| .T. })
		oStep:setPrevWhen({|| .F. })
		oStep:SetNextTitle("Copiar")
	EndIF

	oStep := oWizard:AddStep("4")
	oStep:SetStepDescription("Processamento")
	IF lSimple
		oStep:SetConstruction({|panel| simpleCopy(oTempEmps, @aDuplicates, @aExceptions), finish(panel, aExceptions) })
	EndIF
	IF lLot
		oStep:SetConstruction({|panel| lotCopy(oTempEmps, oTempRegs, @aExceptions), finish(panel, aExceptions) })
	EndIF
	oStep:SetNextAction({|| .T. })
	oStep:SetCancelWhen({|| .F. })
	oStep:setPrevWhen({|| .F. })

	oWizard:Activate()
	oWizard:Destroy()

	//exclui os arquivos temporarios do banco
	IF oTempEmps != Nil
		oTempEmps:Delete()
	EndIF
	IF oTempRegs != Nil
		oTempRegs:Delete()
	EndIF

return



/*/{Protheus.doc} lotCopy
Prepara o lote em cópia

@author Rafael Ricardo Vieceli
@since 03/2018
@version 1.0
@param oTempEmps, object, Arquivo temporario com as empresa/filiais
@param oTempRegs, object, Arquivo temporario com os registros
@param aExceptions, array, Exceções
@type function
/*/
static function lotCopy(oTempEmps, oTempRegs, aExceptions)

	Local lContinue := .T.
	Local aProcess := {}
	Local aStruct  := getAllStruct(oTempRegs)
	Local oRegua   := MdrPrc():new( {|process| prepareCopy(process, aProcess, oTempEmps, aStruct,{/*duplicates*/}, @aExceptions) })

	Local cAlias := MPSysOpenQuery( "select EMPRESA, MIN(FILIAL) as FILIAL, count(1) as REGUA  from " + oTempEmps:getRealName() + " where OK in ('T','1','S') group by EMPRESA" )

	While ! (cAlias)->( Eof() )

		//adiciona uma regua por empresa
		oRegua:add("EMPRESA " + FWEmpName((cAlias)->EMPRESA),  cValToChar((cAlias)->REGUA * len(aStruct)) + " registros.")

		//e adiciona na empresa para copia
		aAdd( aProcess, {;
			(cAlias)->EMPRESA,;
			(cAlias)->FILIAL,;
			(cAlias)->REGUA ;
		})

		(cAlias)->( dbSkip() )
	EndDO

	//fecha consulta
	(cAlias)->( dbCloseArea() )

	oRegua:run()

return


/*/{Protheus.doc} simpleCopy
Prepara a cópia simples

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@param oTemp, object, Arquivo temporario com as empresa/filiais
@param aDuplicates, array, Registros duplicados com novos códigos
@param aExceptions, array, Exceções
@type function
/*/
static function simpleCopy(oTemp, aDuplicates, aExceptions)

	Local lContinue := .T.
	Local aProcess := {}
	Local oRegua   := MdrPrc():new( {|process| prepareCopy(process, aProcess, oTemp, {getStruct()}, aDuplicates,@aExceptions) })

	Local cAlias := MPSysOpenQuery( "select EMPRESA, MIN(FILIAL) as FILIAL, count(1) as REGUA  from " + oTemp:getRealName() + " where OK in ('T','1','S') group by EMPRESA" )

	While ! (cAlias)->( Eof() )

		//adiciona uma regua por empresa
		oRegua:add("EMPRESA " + FWEmpName((cAlias)->EMPRESA), cValToChar((cAlias)->REGUA) + " registros.")

		//e adiciona na empresa para copia
		aAdd( aProcess, {;
			(cAlias)->EMPRESA,;
			(cAlias)->FILIAL,;
			(cAlias)->REGUA ;
		})

		(cAlias)->( dbSkip() )
	EndDO

	//fecha consulta
	(cAlias)->( dbCloseArea() )

	oRegua:run()

return lContinue



/*/{Protheus.doc} prepareCopy
função que chama os JOB de cópia por empresa, e controle da regua

@author Rafael Ricardo Vieceli
@since 03/2018
@version 1.0
@param oProcess, object, Objeto da regua
@param aProcess, array, Processos por empresa
@param oTemp, object, Arquivo temporario com as empresa/filiais
@param aStruct, array, Estrutura dos registros para copia
@param aDuplicates, array, Lista de registros duplicados (apenas para Simples)
@param aExceptions, array, Exceçoes
@type function
/*/
static function prepareCopy(oProcess, aProcess, oTemp, aStruct, aDuplicates, aExceptions)

	Local nProcess
	Local cGlobalMeterName
	Local nDiff
	Local cGlobalValue
	Local aEnds := {}


	PutGlbVars("M080"+cValtoChar(ThreadID())+"EXCEP",aExceptions)

	For nProcess := 1 to len(aProcess)
		//seta o tamanho da regua
		oProcess:setMeter(nProcess, aProcess[nProcess][3] * len(aStruct))

		cGlobalMeterName := "M080"+cValtoChar(ThreadID())+"P"+cValtoChar(nProcess)
		PutGlbValue(cGlobalMeterName, "0")
		GlbUnLock()

		//e inicia JOB para copia
		StartJob("u_M080Copy", GetEnvServer(), .F., ;
			{aProcess[nProcess][1], aProcess[nProcess][2], RetCodUsr()/*sem usuario*/}, ;
			{cGlobalMeterName, "M080"+cValtoChar(ThreadID())+"EXCEP"}, ;
			getMarkedFils(oTemp,aProcess[nProcess][1]), ;
			aStruct, aDuplicates)
	Next nProcess

	While .T.

		IF len(aEnds) == len(aProcess)
			exit
		EndIF

		//limpas as variaveis globais
		For nProcess := 1 to len(aProcess)

			//se ja encerrou, pula
			IF aScan(aEnds,{|nEnd| nEnd == nProcess})
				Loop
			EndIF

			//pega a variavel global
			cGlobalMeterName := "M080"+cValtoChar(ThreadID())+"P"+cValtoChar(nProcess)
			//e o conteudo
			cGlobalValue := GetGlbValue(cGlobalMeterName)

			//verifica se acabou
			IF cGlobalValue $ "END|ERROR" .Or. val(cGlobalValue) == aProcess[nProcess][3]
				cGlobalValue := cValtoChar(aProcess[nProcess][3])
				aAdd(aEnds,nProcess)
			EndIF

			nDiff :=  val(cGlobalValue) - oProcess:getMeter(nProcess)

			While nDiff > 0
				oProcess:incMeter(nProcess)
				nDiff --
			EndDO

		Next nProcess

		//status a cada 1 segundo
		Sleep(1000)
	EndDO

	//recupera os erros
	GetGlbVars("M080"+cValtoChar(ThreadID())+"EXCEP", @aExceptions)

	//limpas as variaveis globais
	ClearGlbValue("M080"+cValtoChar(ThreadID())+"EXCEP")
	For nProcess := 1 to len(aProcess)
		ClearGlbValue("M080"+cValtoChar(ThreadID())+"P"+cValtoChar(nProcess))
	Next nProcess

return



/*/{Protheus.doc} getMarkedFils
Função pega os registros marcados filtrando a empresa

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return array, lista de marcados
@param oTemp, object, Arquivo temporario com as empresa/filiais
@param cEmpresa, characters, codigo da empresa
@type function
/*/
static function getMarkedFils(oTemp, cEmpresa)

	Local aMarkeds := {}

	//pega todas as filiais da empresa para
	Local cAlias := MPSysOpenQuery( "select FILIAL from " + oTemp:getRealName() + " where EMPRESA = '" + cEmpresa + "' and OK in ('T','1','S') order by FILIAL" )

	(cAlias)->( dbEval({|| aAdd(aMarkeds,  FILIAL) },, { || ! Eof() }))
	(cAlias)->( dbCloseArea() )

return aMarkeds


/*/{Protheus.doc} M080Copy
Função chamada via JOB para preparar a copia das TES

@author Rafael Ricardo Vieceli
@since 03/2018
@version 1.0
@param aConection, array, Dados para conexao
@param aGlobals, array, Variaveis globais para controle da regua
@param aFils, array, lista de filiais para copia
@param aTES, array, lista de TES com estrutura para copia
@param aDuplicates, array, Lista de registros duplicados
@type function
/*/
user function M080Copy(aConection, aGlobals, aFils, aTES, aDuplicates)

	Local aReturn
	Local nFil

	Local nTES

	IF aConection != Nil
		ConOut("[Copy]copy_tes_connect_to " + aConection[1] + ' ' + aConection[2])
		//Seta job para nao consumir licensas
		RPCSetType(3)
		//Seta job para empresa filial desejada
		RPCSetEnv(aConection[1],aConection[2],aConection[3],,"FIS",,{"SF4"})
	EndIF

	//ignora o controle de erro padrão e seta ERROR, para encerrar o processo
	ErrorBlock({|e| PutGlbValue(aGlobals[1],"ERROR"), 	GlbUnLock() })

	//controle de erro
	Begin Sequence

		//pega todas as filiais da empresa para
		For nFil := 1 to len(aFils)

			//altera para filial destino
			cFilAnt := aFils[nFil]

			For nTES := 1 to len(aTES)
				//incrementa a regua
				IF ! empty(aGlobals[1])
					PutGlbValue(aGlobals[1],cValToChar(val(GetGlbValue(aGlobals[1]))+1))
					GlbUnLock()
				EndIF

				//e faz a cópia
				copyTES(aTES[nTES], aDuplicates, aGlobals[2])
			Next nTES

		Next nFil

		//define que terminou o processamento
		PutGlbValue(aGlobals[1],"END")
		GlbUnLock()

	End Sequence

	IF aConection != Nil
		RpcClearEnv()
	EndIF

return



/*/{Protheus.doc} getCodigo
Função para buscar o código, quando estiver duplicado

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return characters, Codigo da TES
@param cTES, characters, Codigo da TES copia
@param aDuplicates, array, Lista de arquivos duplicados
@type function
/*/
static function getCodigo(cTES, aDuplicates)

	Local nDuplicated := aScan(aDuplicates,{|duplicated| duplicated[1] == cEmpAnt .And. duplicated[2] == cFilAnt })

	IF nDuplicated != 0 .and. ! empty(aDuplicates[nDuplicated][4])
		cTES := aDuplicates[nDuplicated][4]
	EndIF

return cTES



/*/{Protheus.doc} copyTES
Função qua chama a rotina automatica para criar uma nova TES

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return logical, se criou
@param aTES, array, Estrutura da TES
@param aDuplicates, array, Lista de arquivos duplicados
@param cGlobalExcep, characters, variavel global de exceções
@type function
/*/
static function copyTES(aTES, aDuplicates, cGlobalExcep)

	Local aMata080 := {}
	Local nField, nAdd

	Local cError := ''

	Local cTES    := getCodigo(aTES[1],aDuplicates)
	Local aStruct := aTES[2]


	SF4->( dbSetOrder(1) )
	SF4->( dbSeek( xFilial("SF4") + cTES ) )

	IF SF4->( Found() )
		return .T.
	EndIF

	//variaveis para o ExecAuto
	Private lMsErroAuto := .F., lMsHelpAuto := lAutoErrNoFile := .T.

	aAdd(aMata080, { 'F4_CODIGO', cTES, Nil})

	For nField := 1 to len(aStruct)
		aAdd(aMata080, { aStruct[nField][1], aStruct[nField][2], nil })
	Next nField

	//chama inclusão
	MSExecAuto({ |fields,option| MATA080(fields,option)}, aMata080, 3)

	ConOut("coping " + cTES + ' to ' + cEmpAnt + ' ' + cFilAnt)

	IF lMsErroAuto
		//pega o erro e colocar numero variavel
		aEval(GetAutoGRLog(), {|lineError| cError += alltrim(lineError) + CRLF })

		setErro(cTES, cGlobalExcep, 'Validação na rotina automatica <duplo clique para mais detalhes>', cError)
	Else

		//verifica se é usado na filial
		IF GetMV("MV_GERIMPV")=="S"
			storeChild("SFC",{"FC_TES",cTES},aTES[3])
		EndIF
		storeChild("CC7",{"CC7_TES",cTES},aTES[4])
		IF AliasIndic("F09") .AND. !Empty(Alltrim(GetNewPar("MV_UFIPM",'')))
			storeChild("F09",{"F09_TES",cTES}, aTES[5])
		EndIF
	EndIF

return ! lMsErroAuto


/*/{Protheus.doc} storeChild
Grava arquivos filhos via reclock, pois não há rotina automatica

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@param cAlias, characters, Alias da tabela
@param aChave, array, chave com o codigo da TES
@param aStruct, array, Estrutura do filho
@type function
/*/
static function storeChild(cAlias, aChave, aStruct)

	Local nReg
	Local nField
	Local nPos

	For nReg := 1 to len(aStruct)

		Reclock((cAlias),.T.)
		//filial
		(cAlias)->&(PrefixoCPO(cAlias)+"_FILIAL") := xFilial(cAlias)
		//chave com a TES
		(cAlias)->&(aChave[1]) := aChave[2]

		//restante dos campos
		For nField := 1 to len(aStruct[nReg])
			IF (nPos := (cAlias)->( FieldPOS(aStruct[nReg][nField][1]) )) > 0
				(cAlias)->(FieldPUT(nPos, aStruct[nReg][nField][2]))
			EndIF
		Next nField

		(cAlias)->( MsUnlock() )

	Next nReg

return


/*/{Protheus.doc} setErro
Salva o erro na variavel Global

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@param cTES, characters, codigo da TES
@param cGlobalVar, characters, variavel global
@param cDetalhe, characters, Detalhe do erro
@param cError, characters, Erro detalhado
@type function
/*/
static function setErro(cTES, cGlobalVar, cDetalhe,cError)

	Local aException

	GetGlbVars(cGlobalVar,@aException)
	aAdd(aException,{cEmpAnt, cFilAnt, cTES, cDetalhe, cError})
	PutGlbVars(cGlobalVar,aException)
	GlbUnLock()

return


/*/{Protheus.doc} getAllStruct
Montagem da estrutura de todas as TES marcadas (somente para LOTE)

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return array, Estruturas
@param oTemp, object, Arquivo temporario com as TES
@type function
/*/
static function getAllStruct(oTemp)

	Local aStructs := {}

	(oTemp:GetAlias())->(dbGoTop())

	While ! (oTemp:GetAlias())->( Eof() )

		IF (oTemp:GetAlias())->OK

			SF4->( dbSetOrder(1) )
			SF4->( dbSeek( xFilial("SF4") + (oTemp:GetAlias())->TES ) )

			IF SF4->( Found() )
				aAdd( aStructs, getStruct() )
			EndIF

		EndIF

		(oTemp:GetAlias())->(dbSkip())
	EndDO

return aStructs



/*/{Protheus.doc} getStruct
Montagem da estrutura por TES

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return array, Estrutura da TES

@type function
/*/
static function getStruct()

	Local aStruct := {SF4->F4_CODIGO,{/*SF4*/},{/*SFC*/},{/*CC7*/},{/*F09*/}}

	Local aNoCopy := noCopy()

	//strutura da TES
	aStruct[2] := getStruByAlias("SF4",aNoCopy)

	//Amarração Tes x Impostos
	IF AliasInDic("SFC")
		SFC->( dbSetOrder(1) )
		SFC->( dbSeek( xFilial("SFC") + SF4->F4_CODIGO ) )

		While ! SFC->( Eof() ) .And. SFC->(FC_FILIAL+FC_TES) == xFilial("SFC") + SF4->F4_CODIGO
			aAdd(aStruct[3], getStruByAlias("SFC", {'FC_FILIAL','FC_TES'}) )
			SFC->(dbSkip())
		EndDO
	EndIF

	//AMARRACAO TES X LANC. APUR.
	IF AliasInDic("CC7")
		CC7->( dbSetOrder(1) )
		CC7->( dbSeek( xFilial("CC7") + SF4->F4_CODIGO ) )

		While ! CC7->( Eof() ) .And. CC7->(CC7_FILIAL+CC7_TES) == xFilial("CC7") + SF4->F4_CODIGO
			aAdd(aStruct[4], getStruByAlias("CC7", {'CC7_FILIAL', 'CC7_TES'}) )
			CC7->(dbSkip())
		EndDO
	EndIF

	//Relacionamento TES x IPM
	IF AliasInDic("F09")
		F09->( dbSetOrder(1) )
		F09->( dbSeek( xFilial("F09") + SF4->F4_CODIGO ) )

		While ! F09->( Eof() ) .And. F09->(F09_FILIAL+F09_TES) == xFilial("F09") + SF4->F4_CODIGO
			aAdd(aStruct[5], getStruByAlias("F09", {'F09_FILIAL','F09_TES'}) )
			F09->(dbSkip())
		EndDO
	EndIF


return aStruct



/*/{Protheus.doc} getStruByAlias
Montagem da estrutura por Alias

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return array, Estrutura por Alias
@param cAlias, characters, Alias
@param aNoCopy, array, Campos que não seram copiados
@type function
/*/
static function getStruByAlias(cAlias, aNoCopy)

	Local nField
	Local aStruct := {}

	default aNoCopy := {}

	For nField := 1 to (cAlias)->( FCount() )

		//verifica lista de campos para não copiar
		IF aScan(aNoCopy, {|field| field == (cAlias)->( FieldName(nField) )}) != 0
			Loop
		EndIF

		//se o campo estiver vazio, nao faz copia
		IF empty((cAlias)->( FieldGet(nField) ))
			loop
		EndIF

		aAdd( aStruct, {;
			(cAlias)->( FieldName(nField) ) ,; //nome do campo
			(cAlias)->( FieldGet(nField) ) ; //valor do campo
		})

	Next nField

return aStruct



/*/{Protheus.doc} finish
Montagem do Passo4 para montar detalhes de erros, caso ocorrão.

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@param oPanel, object, Painel
@param aExceptions, array, Excecoes
@type function
/*/
static function finish(oPanel, aExceptions)

	Local oBrowse, oHeader, oPanelBrowse

	IF len(aExceptions) > 0

	    oHeader       := tPanel():New(01,01,,oPanel,,,,,,100,20)
	    oHeader:Align := CONTROL_ALIGN_TOP

		TSay():New(5,5,{|| "<b>Houve "+cValToChar(len(aExceptions))+" erros de inclusão nas empresas e filiais</b>"},oHeader,,TFont():New(,,-14),,,,.T.,,,240,9,,,,,,.T.)

	    oPanelBrowse       := tPanel():New(01,01,,oPanel,,,,,,100,20)
	    oPanelBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		oBrowse := FWBrowse():New()
		oBrowse:SetDescription("")
		oBrowse:setOwner(oPanelBrowse)
		oBrowse:setDataArray()
		oBrowse:setArray(aExceptions)
		oBrowse:setColumns({;
			addColumn({|| aExceptions[oBrowse:At()][1] },"Empresa",2,,"C") ,;
			addColumn({|| aExceptions[oBrowse:At()][2] },"Filial",FWSizeFilial(),,"C") ,;
			addColumn({|| aExceptions[oBrowse:At()][4] },"Erro",3,,"C") ;
		})
		oBrowse:SetDoubleClick({||  showDetails(aExceptions[oBrowse:At()]) })
		oBrowse:disableReport()
		oBrowse:disableConfig()
		oBrowse:disableFilter()
		oBrowse:activate()

	Else
		TSay():New(10,20,{|| "<b>Não houveram erros na cópia dos registros!</b>"},oPanel,,TFont():New(,,-14),,,,.T.,,,240,9,,,,,,.T.)
	EndIF

return


/*/{Protheus.doc} showDetails
Mostra o erro detalhado do passo4

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@param aException, array, Exceção
@type function
/*/
static function showDetails(aException)

	Local oModal
	Local oGet

	IF empty(aException[5])
		return
	EndIF

	oModal	:= FWDialogModal():New()
	oModal:SetEscClose(.T.)
	oModal:setTitle("Detalhes")
	oModal:setSize(200, 300)
	oModal:enableFormBar(.T.)
	oModal:createDialog()

	oGet := tMultiget():new( 01, 01, bSetGet(aException[5]), oModal:getPanelMain(),190,175,,.T.,,,,.T.)
	oGet:EnableVScroll(.T.)
	oGet:EnableHScroll(.T.)
	oGet:Align := CONTROL_ALIGN_ALLCLIENT
	oGet:oFont := TFont():New( 'Courier New', 6, 16 )
	oGet:lWordWrap := .F.

	oModal:addCloseButton()
	oModal:Activate()

return



/*/{Protheus.doc} simpleConfirmation
Montagem do Passo3 para copia simples

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@param oPanel, object, painel
@param oTemp, object, Arquivo temporario com as TES
@param aDuplicates, array, Lista de duplicidades
@type function
/*/
static function simpleConfirmation(oPanel, oTemp, aDuplicates)

	Local oBrowse, oHeader, oPanelBrowse

	FwMsgRun(, {|| aDuplicates := validateDuplicated(oTemp, SF4->F4_CODIGO) }, "Buscando...", "Buscando informações de duplicidade nos destinos.")

	IF len(aDuplicates) > 0

	    oHeader       := tPanel():New(01,01,,oPanel,,,,,,100,20)
	    oHeader:Align := CONTROL_ALIGN_TOP

		TSay():New(5,5,{|| "<b>Existem "+cValToChar(len(aDuplicates))+" registros com este código em outras empresas e filiais</b>"},oHeader,,TFont():New(,,-14),,,,.T.,,,240,9,,,,,,.T.)

	    oPanelBrowse       := tPanel():New(01,01,,oPanel,,,,,,100,20)
	    oPanelBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		oBrowse := FWBrowse():New()
		oBrowse:SetDescription("")
		oBrowse:setOwner(oPanelBrowse)
		oBrowse:setDataArray()
		oBrowse:setArray(aDuplicates)
		oBrowse:addStatusColumns({ || IIF( empty(aDuplicates[oBrowse:At()][4]), "DISABLE", "ENABLE")  }, { ||  })
		oBrowse:setColumns({;
			addColumn({|| aDuplicates[oBrowse:At()][1] },"Empresa",2,,"C") ,;
			addColumn({|| aDuplicates[oBrowse:At()][2] },"Filial",FWSizeFilial(),,"C") ,;
			addColumn({|| aDuplicates[oBrowse:At()][3] },"Texto da TES",40,,"C") ,;
			addColumn({|| aDuplicates[oBrowse:At()][4] },"Novo Código",3,,"C") ;
		})
		oBrowse:SetDoubleClick({||  changeCode(@aDuplicates[oBrowse:At()]) })
		oBrowse:disableReport()
		oBrowse:disableConfig()
		oBrowse:disableFilter()
		oBrowse:activate()

	Else
		TSay():New(10,20,{|| "<b>Não existem registros duplicados com o código "+SF4->F4_CODIGO+" em outras empresas e filiais</b>"},oPanel,,TFont():New(,,-14),,,,.T.,,,240,9,,,,,,.T.)
	EndIF

return


/*/{Protheus.doc} changeCode
Tela para alterar codigo duplicado

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return logical, se alterou
@param aDuplicated, array, Registro Duplicados
@type function
/*/
static function changeCode(aDuplicated)

	Local oModal, oPanel

	Local cNewCod
	Local lContinue := .F.

	oModal	:= FWDialogModal():New()
	oModal:SetEscClose(.T.)
	oModal:setTitle("Alterar Código")
	oModal:setSize(80, 200)
	oModal:enableFormBar(.T.)
	oModal:createDialog()

	oPanel := oModal:getPanelMain()

	//pega o novo código alterado
	cNewCod := aDuplicated[4]

    TGet():New(10,20, bSetGet(SF4->F4_CODIGO),oPanel, 30, 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,'Código Original',1,oPanel:oFont)
	TGet():New(10,70, bSetGet(cNewCod)       ,oPanel, 30, 12 , "@S200",{|| .T. },,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,'cNewCod',,,,,,,'Novo Código',1,oPanel:oFont)

	oModal:addButtons({{"", "Alterar", {|| IIF( lContinue := validChange(cNewCod, aDuplicated), oModal:Deactivate(), ) }, "Clique aqui para Enviar",,.T.,.T.}})
	oModal:addButtons({{"", "Fechar", {|| lContinue := .F., oModal:Deactivate() }, "Clique aqui para Enviar",,.T.,.T.}})

	oModal:Activate()

	IF lContinue
		aDuplicated[4] := cNewCod
	EndIF

return lContinue


/*/{Protheus.doc} validChange
Validação do novo código

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return logical, se não esta duplicado
@param cTES, characters, Codigo
@param aDuplicated, array, Lista de duplicidades
@type function
/*/
static function validChange(cTES, aDuplicated)

	Local nLoop
	Local cDigito
	Local nAscDig

	Local lContinue := .T.

	IF empty(cTES)
		return lContinue
	EndIF

	For nLoop := 1 to len(cTES)

		cDigito := subStr(cTES, nLoop, 1)
		nAscDig := asc(cDigito)

		IF nLoop == 1
			lContinue := ( nAscDig >= 48 .And. nAscDig <= 57 )
		Else
			lContinue := ( ( nAscDig >= 48 .And. nAscDig <= 57 ) .Or. ( nAscDig >= 65 .And. nAscDig <= 90 ) )
		EndIF

		IF ! lContinue
			Aviso( "Atencao", "No primeiro digito, permite apenas numeros, nos demais digitos, permite apenas numeros e letras maiusculas", { "Ok" },1)
			Exit
		EndIF

	Next nLoop

	IF lContinue
		//nova TES é entrada, mas a original é saida
		IF cTES <= "500" .And. SF4->F4_CODIGO >= "501"
			lContinue := .F.
			Aviso( "Atencao", "A TES copiada é de Entrada, e o novo código informado é de Saída.", { "Ok" },1)
		EndIF
		//nova TES é saida, mas a original é entrada
		IF cTES >= "501" .And. SF4->F4_CODIGO <= "500"
			lContinue := .F.
			Aviso( "Atencao", "A TES copiada é de Saída, e o novo código informado é de Entrada.", { "Ok" },1)
		EndIF
	EndIF

	IF lContinue
		lContinue := u_M080Validate(cTES, {aDuplicated[1], aDuplicated[2]})
	EndIF

return lContinue



/*/{Protheus.doc} origin
Confirmação da origem da copia

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@param oPanel, object, Painel
@type function
/*/
static function origin(oPanel)

	Local nLinha := 10

	TGet():New(nLinha    ,20, bSetGet(cEmpAnt),oPanel, 10, 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,'Empresa ',1,oPanel:oFont)
	TGet():New(nLinha+7.5,40, bSetGet(FWEmpName(cEmpAnt)),oPanel, 150, 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,)

	nLinha += 25
	TGet():New(nLinha    ,20, bSetGet(cFilAnt),oPanel, (FWSizeFilial()*5), 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,'Filial',1,oPanel:oFont)
	TGet():New(nLinha+7.5,30+((FWSizeFilial()*5)), bSetGet(FWFilialName()),oPanel, 150, 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,)


	//nao copia simples
	IF lSimple

		//também montar os dados do registro
		nLinha += 40
		TGet():New(nLinha    ,20, bSetGet(SF4->F4_CODIGO),oPanel, 20, 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,'Código',1,oPanel:oFont)
		nLinha += 25
		TGet():New(nLinha    ,20, bSetGet(IIF(SF4->F4_TIPO=="S","Saída","Entrada")),oPanel, 50, 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,'Tipo',1,oPanel:oFont)
		nLinha += 25
		TGet():New(nLinha    ,20, bSetGet(SF4->F4_TEXTO),oPanel, 100, 12 , "@X",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,/*cReadVar*/,,,,,,,'Texto',1,oPanel:oFont)

	EndIF

return


/*/{Protheus.doc} selectRegisters
Monta painel com markBrowse para selecão dos registros a serem copiados (somente LOTE)

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@param oPanel, object, Painel
@param oTemp, object, Arquivo temporario com as TES
@param oBrowse, object, FWBrowse
@type function
/*/
static function selectRegisters(oPanel, oTemp, oBrowse)

	oBrowse:SetDescription("")
	oBrowse:setOwner(oPanel)
	oBrowse:setDataTable(.T.)
	oBrowse:setAlias( oTemp:GetAlias() )
	oBrowse:AddMarkColumns( ;
		{|| IIF( (oTemp:getAlias())->OK , "LBOK", "LBNO" ) },;
		{||  (oTemp:getAlias())->OK :=  ! (oTemp:getAlias())->OK } ,;
		{|| markAll(oBrowse) } )
	oBrowse:setColumns({;
		addColumn({|| (oTemp:getAlias())->TES },"Empresa",2,,"C") ,;
		addColumn({|| IIF((oTemp:getAlias())->TIPO=="E","Entrada","Saída") },"Filial",FWSizeFilial(),,"C") ,;
		addColumn({|| (oTemp:getAlias())->TEXTO },"Nome",60,,"C") ;
	})
	oBrowse:SetDoubleClick({||  (oTemp:getAlias())->OK :=  ! (oTemp:getAlias())->OK })

	oBrowse:disableReport()
	oBrowse:disableConfig()
	oBrowse:disableFilter()
	oBrowse:activate()

return


/*/{Protheus.doc} destination
Monta painel com markBrowse para selecão das empresas e filiais destino

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@param oPanel, object, Painel
@param oTemp, object, Arquivo temporario com as TES
@param oBrowse, object, FWBrowse
@type function
/*/
static function destination(oPanel, oTemp, oBrowse)

	oBrowse:SetDescription("")
	oBrowse:setOwner(oPanel)
	oBrowse:setDataTable(.T.)
	oBrowse:setAlias( oTemp:GetAlias() )
	oBrowse:AddMarkColumns( ;
		{|| IIF( (oTemp:getAlias())->OK , "LBOK", "LBNO" ) },;
		{||  (oTemp:getAlias())->OK :=  ! (oTemp:getAlias())->OK } ,;
		{|| markAll(oBrowse) } )
	oBrowse:setColumns({;
		addColumn({|| (oTemp:getAlias())->EMPRESA },"Empresa",2,,"C") ,;
		addColumn({|| (oTemp:getAlias())->FILIAL },"Filial",FWSizeFilial(),,"C") ,;
		addColumn({|| (oTemp:getAlias())->NOME },"Nome",60,,"C") ;
	})
	oBrowse:SetDoubleClick({||  (oTemp:getAlias())->OK :=  ! (oTemp:getAlias())->OK })

	oBrowse:disableReport()
	oBrowse:disableConfig()
	oBrowse:disableFilter()
	oBrowse:activate()

return



/*/{Protheus.doc} validateAtLastOne
Valida para que no minimo um registro esteja marcado

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return logical, se marcou algum
@param oBrowse, object, FWBrowse
@type function
/*/
static function validateAtLastOne(oBrowse)

	Local lValidade := .F.

	(oBrowse:getAlias())->( dbGoTop() )
	(oBrowse:getAlias())->( dbEval({|| lValidade := OK },, { || ! Eof() .And. ! lValidade }))
	(oBrowse:getAlias())->( dbGoTop() )

	oBrowse:Refresh(.T.)

return lValidade



/*/{Protheus.doc} markAll
Função para marcar tudo

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@param oBrowse, object, FWBrowse
@type function
/*/
static function markAll(oBrowse)

	(oBrowse:getAlias())->( dbGotop() )
	(oBrowse:getAlias())->( dbEval({|| OK := !OK },, { || ! Eof() }))
	(oBrowse:getAlias())->( dbGotop() )

	oBrowse:Refresh(.T.)

return


/*/{Protheus.doc} makeTempRegs
Montagem de arquivo temporario com as TES (somente LOTE)

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return object, FWTemporaryTable

@type function
/*/
static function makeTempRegs()

	//instancia classe
	Local oTemp := FWTemporaryTable():New()
	Local cAlias := MPSysOpenQuery( "select F4_CODIGO, F4_TIPO, F4_TEXTO from " + retSqlName("SF4") + " where F4_FILIAL = '"+cFilAnt+"' and D_E_L_E_T_ = ' '" )

	//determina os campos
	oTemp:SetFields({ ;
		{"OK", "L", 1, 0},;
		{"TES", "C", 3, 0},;
		{"TIPO", "C", 1, 0},;
		{"TEXTO", "C", TamSX3("F4_TEXTO")[1], 0};
	})

	//cria um indice
	oTemp:AddIndex("01", {"TES"} )
	//cria a tabela temporaria
	oTemp:Create()

	While ! (cAlias)->( Eof() )

		Reclock(oTemp:getAlias(),.T.)
		(oTemp:getAlias())->OK    := .F.
		(oTemp:getAlias())->TES   := (cAlias)->F4_CODIGO
		(oTemp:getAlias())->TIPO  := (cAlias)->F4_TIPO
		(oTemp:getAlias())->TEXTO := (cAlias)->F4_TEXTO
		(oTemp:getAlias())->( MsUnlock() )

		(cAlias)->(dbSkip())
	EndDO

	(cAlias)->( dbCloseArea() )

return oTemp


/*/{Protheus.doc} makeTempEmps
Montagem de arquivo temporario com as empresas/filiais destino

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return object, FWTemporaryTable
@param lMarked, logical, Traz macado
@param aFilter, array, Filtra empresa/filial
@type function
/*/
static function makeTempEmps(lMarked, aFilter)

	Local aSM0 := FWLoadSM0()
	Local nI

	//instancia classe
	Local oTemp := FWTemporaryTable():New()

	default lMarked := .F.

	//determina os campos
	oTemp:SetFields({ ;
		{"OK", "L", 1, 0},;
		{"EMPRESA", "C", 2, 0},;
		{"FILIAL", "C", FWSizeFilial(), 0},;
		{"NOME", "C", 60, 0};
	})
	//cria um indice
	oTemp:AddIndex("01", {"EMPRESA", "FILIAL"} )
	//cria a tabela temporaria
	oTemp:Create()

	For nI := 1 to len(aSM0)

		IF valtype(aFilter) == "A"
			IF !( aFilter[1] == aSM0[nI][SM0_GRPEMP] .And. aFilter[2] == aSM0[nI][SM0_CODFIL] )
				Loop
			EndIF
		EndIF

		//ignora a filial atual
		IF cEmpAnt == aSM0[nI][SM0_GRPEMP] .And. cFilAnt == aSM0[nI][SM0_CODFIL]
			Loop
		EndIF

		//se o usuario não tem acesso, não pode copiar
		IF ! aSM0[nI][SM0_USEROK]
			Loop
		EndIF

		Reclock(oTemp:getAlias(),.T.)
		(oTemp:getAlias())->OK      := lMarked
		(oTemp:getAlias())->EMPRESA := aSM0[nI][SM0_GRPEMP]
		(oTemp:getAlias())->FILIAL  := aSM0[nI][SM0_CODFIL]
		(oTemp:getAlias())->NOME    := aSM0[nI][SM0_NOMRED]
		(oTemp:getAlias())->( MsUnlock() )

	Next nI

return oTemp


/*/{Protheus.doc} addColumn
Função generica para adicionar objeto de coluna

@author Rafael Ricardo Vieceli
@since 04/01/2017
@version undefined
@param bData, block, Codeblock da coluna
@param cTitulo, characters, Titulo da coluna
@param nTamanho, numeric, Tamanho da coluna
@param cTipo, characters, Tipo de coluna
@type function
/*/
Static Function addColumn(bData,cTitulo,nTamanho,nDecimal,cTipo,cPicture)

	Local oColumn

	oColumn := FWBrwColumn():New()
	oColumn:SetData( bData )
	oColumn:SetTitle(cTitulo)
	oColumn:SetSize(nTamanho)
	IF nDecimal != Nil
		oColumn:SetDecimal(nDecimal)
	EndIF
	oColumn:SetType(cTipo)
	IF cPicture != Nil
		oColumn:SetPicture(cPicture)
	EndIF

Return oColumn



/*/{Protheus.doc} validateDuplicated
Validação de codigo duplicado

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return array, Lista de registros duplicados com as filiais
@param oTemp, object, Arquivo temporario com as FILIAIS
@param cTES, characters, codigo da TES
@type function
/*/
static function validateDuplicated(oTemp, cTES)

	Local aDuplicates := {}
	Local xJobReturn := {}
	Local nI
	Local cAlias := MPSysOpenQuery( "select EMPRESA, MIN(FILIAL) as FILIAL from " + oTemp:getRealName() + " where OK in ('T','1','S') group by EMPRESA" )


	While ! (cAlias)->( Eof() )
		//se for a mesma empresa
		IF (cAlias)->EMPRESA == cEmpAnt
			//busca os registro direto
			xJobReturn := getRegs(oTemp:getRealName(), cTES)
		Else
			//se for outra empresa... inicia um JOB para carregar o dicionarios da outra empresa
			xJobReturn := StartJob("u_M080GetRegs", GetEnvServer(), .T., {(cAlias)->EMPRESA, (cAlias)->FILIAL, RetCodUsr()/*sem usuario*/}, getMarkedFils(oTemp,(cAlias)->EMPRESA), cTES)
		EndIF

		IF valtype(xJobReturn) == "A"
			For nI := 1 to len(xJobReturn)
				aAdd(aDuplicates, aClone(xJobReturn[nI]) )
			Next nI
		EndIF

		IF valtype(xJobReturn) == "C" .And. xJobReturn == "DEFAULTERRORPROC"
			Alert('Erro no Job de validação de duplicidades.')
		EndIF

		(cAlias)->(dbSkip())
	EndDO

return aDuplicates


/*/{Protheus.doc} M080GetRegs
Função via JOB para verificar duplicidade

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return array, Lista de duplicidades
@param aConection, array, Dados da Conexao
@param aFiliais, array, lista de Filiais para busca
@param cTES, characters, Codigo da TES
@type function
/*/
user function M080GetRegs(aConection, aFiliais, cTES)

	Local aReturn := {}

	varInfo('aConection',aConection)

	IF aConection != Nil
		ConOut("[GetRegs] copy_tes_connect_to " + aConection[1] + ' ' + aConection[2])
		//Seta job para nao consumir licensas
		RPCSetType(3)
		//Seta job para empresa filial desejada
		RPCSetEnv(aConection[1],aConection[2],aConection[3],,"FIS",,{"SF4"})
	EndIF

	Begin Sequence
		aReturn := getRegs(aFiliais, cTES)
	End Sequence

	IF aConection != Nil
		RpcClearEnv()
	EndIF

return aReturn


/*/{Protheus.doc} getRegs
Função para buscar os registros duplicados

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return array, lista de arquivos duplicados
@param xFiliais, , Lista de Filiais
@param cTES, characters, TES
@type function
/*/
static function getRegs(xFiliais, cTES)

	Local aRegs := {}
	Local cAlias

	//garatimos que a tabela exista
	dbSelectArea("SF4")

	IF valtype(xFiliais) == "C"
		cAlias := MPSysOpenQuery(makeSqlRegs(xFiliais, cTES))
		(cAlias)->( dbEval({|| aAdd(aRegs, { cEmpAnt, F4_FILIAL, F4_TEXTO, "   " }) },, { || ! Eof() }))
		(cAlias)->( dbCloseArea() )
	EndIF

	IF valType(xFiliais) == "A"
		aRegs := makeSeekRegs(xFiliais,cTES)
	EndIF

return aRegs


/*/{Protheus.doc} makeSqlRegs
Quando não for via JOB monta consulta SQL relacionando SF4 com arquivo temporario

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return characters, consulta SQL
@param cTempTable, characters, Tabela temporaria
@param cTES, characters, Codigo da TES
@type function
/*/
static function makeSqlRegs(cTempTable, cTES)

	Local cQuery

	cQuery := " select F4_FILIAL, F4_TEXTO "
	cQuery += " from " + retSqlName("SF4") + " SF4 "
	cQuery += " where"
	cQuery += "     SF4.F4_FILIAL in ( select FILIAL from " + cTempTable + "  where EMPRESA = '" + cEmpAnt + "'  AND OK in ('T','1','S'))"
	cQuery += " AND SF4.F4_CODIGO  = '"+cTES+"'"
	cQuery += " AND SF4.D_E_L_E_T_ = ' '"

return cQuery


/*/{Protheus.doc} makeSeekRegs
Quando for via JOB, recebe uma lista de filiais para busca

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return array, Lista de arquivos duplicados
@param aFiliais, array, lista de filiais
@param cTES, characters, codigo da TES
@type function
/*/
static function makeSeekRegs(aFiliais, cTES)

	Local nFil
	Local aRegs := {}

	For nFil := 1 to len(aFiliais)
		SF4->( dbSetOrder(1) )
		SF4->( dbSeek( aFiliais[nFil] + cTES ) )

		IF SF4->( Found() )
			aAdd(aRegs, { cEmpAnt, SF4->F4_FILIAL, SF4->F4_TEXTO, "   " })
		EndIF
	Next nFil

return aRegs


/*/{Protheus.doc} M080Validate
Função para validação de duplicidade de codigo entre Empresas e Filiais

 - na validação do campo não trava;
 - na validação da copia simples trava


@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return logical, se tem duplicados
@param cTES, characters, Codigo da TES
@param aFilter, array, Filtro quando copia simples
@type function
/*/
user function M080Validate(cTES, aFilter)

	Local lContinue      := .T.
	Local aDuplicates := {}

	//monta arquivo temporario com todas as empresas e filiais
	Local oTemp

	//se passar filtro de uma filial, não tem opção de permitir
	Local lOptional := valType(aFilter) != "A"

	IF ! isBlind() .And. ! ( type("l080Auto") == "L" .And. l080Auto )

		//cria o arquivo temporario populado
		oTemp := makeTempEmps(.T., aFilter)

		//busca os registros duplicados
		FwMsgRun(, {|| aDuplicates := validateDuplicated(oTemp, cTES) }, "Validando...", "Validando duplicidade em outras empresas/filiais.")

		IF len(aDuplicates) == 1
			IF lOptional
				lContinue := Aviso('Duplicidade', 'O código '+cTES+' já existe na Empresa ' + aDuplicates[1][1] + ' Filial ' + aDuplicates[1][2] + ' com texto "'+alltrim(aDuplicates[1][3])+'". Deseja continuar?', {'Sim','Não'}) == 1
			Else
				lContinue := .T.
				Aviso('Duplicidade', 'O código '+cTES+' já existe na Empresa ' + aDuplicates[1][1] + ' Filial ' + aDuplicates[1][2] + ' com texto "'+alltrim(aDuplicates[1][3])+'".', {'Ok'})
			EndIF
		ElseIF len(aDuplicates) > 1
			//aqui vai montar um grid sobre array para mostrar
			lContinue := showDuplicates(aDuplicates, lOptional)
		EndIF

		//exclui o arquivo temporario
		oTemp:Delete()

	EndIF

return lContinue



/*/{Protheus.doc} showDuplicates
Se for mais de um registro duplicado, mostra grid com lista

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return logical, se continua
@param aDuplicates, array, Lista de duplicidades
@param lOptional, logical, se deixa passar
@type function
/*/
static function showDuplicates(aDuplicates, lOptional)

	Local lContinue := .F.

	Local oModal
	Local oHeader
	Local oPanel

	Local oBrowse

	Local cReadVar := ReadVar()

	oModal	:= FWDialogModal():New()
	oModal:SetEscClose(.T.)
	oModal:setTitle("Código duplicados")
	oModal:setSize(200, 280)
	oModal:enableFormBar(.T.)
	oModal:createDialog()

    oHeader       := tPanel():New(01,01,,oModal:getPanelMain(),,,,,,100,20)
    oHeader:Align := CONTROL_ALIGN_TOP

	TSay():New(5,5,{|| "<b>Existem "+cValToChar(len(aDuplicates))+" registros com este código em outras empresas e filiais</b>"},oHeader,,TFont():New(,,-14),,,,.T.,,,240,9,,,,,,.T.)

    oPanel       := tPanel():New(01,01,,oModal:getPanelMain(),,,,,,100,20)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT

    oBrowse := FWBrowse():New()
	oBrowse:SetDescription("")
	oBrowse:setOwner(oPanel)
	oBrowse:setDataArray()
	oBrowse:setArray(aDuplicates)
	oBrowse:setColumns({;
		addColumn({|| aDuplicates[oBrowse:At()][1] },"Empresa",2,,"C") ,;
		addColumn({|| aDuplicates[oBrowse:At()][2] },"Filial",FWSizeFilial(),,"C") ,;
		addColumn({|| aDuplicates[oBrowse:At()][3] },"Texto da TES",40,,"C") ;
	})
	//oBrowse:SetDoubleClick({||  (oTemp:getAlias())->OK :=  ! (oTemp:getAlias())->OK })
	oBrowse:setFilterDefault("OK='T'")
	oBrowse:disableReport()
	oBrowse:disableConfig()
	oBrowse:disableFilter()
	oBrowse:activate()

	IF lOptional
		oModal:addButtons({{"", "Continuar", {|| lContinue := .T., oModal:Deactivate() }, "Clique aqui para Enviar",,.T.,.T.}})
	EndIF
	oModal:addButtons({{"", "Fechar", {|| lContinue := .F., oModal:Deactivate() }, "Clique aqui para Enviar",,.T.,.T.}})

	oModal:activate()

	//a tela tira o foco do readvar original
	__ReadVar := cReadVar

return lContinue


/*/{Protheus.doc} noCopy
Lista de campos da TES que não serão copiados

@author Rafael Ricardo Vieceli
@since 22/03/2018
@version 1.0
@return array, lista de campos

@type function
/*/
static function noCopy()

	Local aNoCopy := {}

	aAdd( aNoCopy, "F4_FILIAL")
	aAdd( aNoCopy, "F4_CODIGO")

return aNoCopy



/*/{Protheus.doc} MdrPrc
Classe para montar varias reguas conforme necessidade.

@author Rafael Ricardo Vieceli
@since 21/03/2018
@version 1.0

@type class
/*/
class MdrPrc

	data oDlg
	data bAction
	data aMeters
	data nWidth

	method new(bAction)
	method add(cTitle)
	method run()
	method setMeter(nIndice,nSet)
	method incMeter(nIndice,nMeter)
	method getMeter(nIndice)

endclass



/*/{Protheus.doc} new
Contrutor da classe

@author Rafael Ricardo Vieceli
@since 21/03/2018
@version 1.0
@return self, instancia do objeto
@param bAction, block, Ação do processamento
@param nWidth, numeric, Largura da janela, altura é dimensionavel conforme numero de reguas
@type function
/*/
method new(bAction, nWidth) class MdrPrc

	default nWidth := 700

	::bAction := bAction
	::aMeters := {}

	::nWidth := nWidth

return self



/*/{Protheus.doc} add
Função para adicionar uma regua, apenas com titulo

@author Rafael Ricardo Vieceli
@since 21/03/2018
@version 1.0
@return self, instancia do objeto
@param cTitle, characters, descricao
@type function
/*/
method add(cTitle, cSubTitle) class MdrPrc

	default cTitle := ''
	default cSubTitle := ''

	aAdd(::aMeters,{{ , cTitle, cSubTitle  }, { , 0 }})

return self



/*/{Protheus.doc} run
Metodo para ativação da classe

@author Rafael Ricardo Vieceli
@since 21/03/2018
@version 1.0

@type function
/*/
method run() class MdrPrc

	Local nIndice
	Local nLine := 5
	Local nMETER := 2

	define msdialog ::oDlg from 0,0 to (55*len(::aMeters)),::nWidth title "" style nOR(WS_VISIBLE,WS_POPUP) status pixel

	For nIndice := 1 to len(::aMeters)

		::aMeters[nIndice][nSAY][1]   := TSay():New( nLine, 10, {|| "" }, ::oDlg, /*cPict*/, /*oFont*/, /*lCenter*/, /*lRight*/, /*lBorder*/,.T., /*nClrText*/, /*nClrBack*/, ::nWidth/2.1, 10, /*lDesign*/, /*lUpdate*/, /*lShaded*/, /*lBox*/, /*lRaised*/, .T./*lHtml*/ )
		::aMeters[nIndice][nSAY][1]:SetText('<b>' + ::aMeters[nIndice][nSAY][2] + '</b>       ' + ::aMeters[nIndice][nSAY][3] )

		// ::aMeters[nIndice][nMETER][1] := TMeter():New( nLine+11, 10, {|| ::aMeters[nIndice][nMETER][2] }, 10/*nTotal*/, ::oDlg, ::nWidth/2.1, 10, /*lUpdate*/,.T., /*oFont*/, /*cPrompt*/, /*lNoPercentage*/,/*nClrPane*/, /*nClrText*/,/*nClrBar*/, /*nClrBText*/, /*lDesign*/ )
		::aMeters[nIndice][nMETER][1] := TMeter():New( nLine+11, 10, , 10/*nTotal*/, ::oDlg, ::nWidth/2.1, 10, /*lUpdate*/,.T., /*oFont*/, /*cPrompt*/, /*lNoPercentage*/,/*nClrPane*/, /*nClrText*/,/*nClrBar*/, /*nClrBText*/, /*lDesign*/ )
		::aMeters[nIndice][nMETER][1]:setFastMode(.T.)

		nLine += 25
	Next nIndice	

	::oDlg:bStart := {|| Eval(self:bAction, @Self), self:oDlg:End()}

	activate msdialog ::oDlg centered

return



/*/{Protheus.doc} setMeter
Metodo para setar o tamanho (iterações) da regua

@author Rafael Ricardo Vieceli
@since 21/03/2018
@version 1.0
@return self, instancia do objeto
@param nIndice, numeric, indice da regua
@param nSet, numeric, tamanho
@type function
/*/
method setMeter(nIndice,nSet) class MdrPrc
	Local nMETER := 2

	default nSet := 10

	::aMeters[nIndice][nMETER][1]:Set(0)
	::aMeters[nIndice][nMETER][1]:SetTotal(nSet-1)
	::aMeters[nIndice][nMETER][1]:Refresh()

	SysRefresh()

return self


/*/{Protheus.doc} incMeter
incrementa a regua

@author Rafael Ricardo Vieceli
@since 21/03/2018
@version 1.0
@return self, instancia do objeto
@param nIndice, numeric, indice da regua
@type function
/*/
method incMeter(nIndice) class MdrPrc
	Local nMETER := 2

	::aMeters[nIndice][nMETER][1]:Set( ::aMeters[nIndice][nMETER][2] ++ )
	::aMeters[nIndice][nMETER][1]:Refresh()

	::aMeters[nIndice][nSAY][1]:SetText('<b>' + ::aMeters[nIndice][nSAY][2] + '</b>       '+cValToChar(::aMeters[nIndice][nMETER][2])+' de ' + ::aMeters[nIndice][nSAY][3] )

	SysRefresh()

return self


/*/{Protheus.doc} getMeter
Return o tamanho incrementado até o momento

@author Rafael Ricardo Vieceli
@since 21/03/2018
@version 1.0
@return self, instancia do objeto
@param nIndice, numeric, indice da regua
@type function
/*/
method getMeter(nIndice) class MdrPrc
	Local nMETER := 2
return ::aMeters[nIndice][nMETER][2]