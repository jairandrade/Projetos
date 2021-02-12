/*/{Protheus.doc} Kapazi
Cria tabelas para integrar o ORCAMENTO com o fluig
@type function

@author Leandro Favero
@since 01/07/2019
@version 1.0
/*/

#Include "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#define enter chr(13) + chr(10)
#define cMailTo "sac@cooperkap.com.br"

/*--------------------------------------------------------------------------+
|  KAPInstall - Cria campos para integrar com o Fluig                       |
----------------------------------------------------------------------------*/
Static function KAPInstall()
	CriaZA1()      //Protheus vs Fluig
Return

/*--------------------------------------------------------------------------+
|  KapMonitor - Tela de monitoramento da integração com o Fluig             |
----------------------------------------------------------------------------*/
User Function KapMonitor()
	Private oBrowse
	Private aRotina
	Private cModo:=''

	KAPInstall() //Instala a customização

	aRotina := MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZA1')
	oBrowse:SetDescription('Monitor de Integração Fluig')

	//Tipo
	oBrowse:AddStatusColumns( { || GetIcon(Alltrim(ZA1_TIPO))} )

	oBrowse:AddLegend("ZA1_STATUS=='1'", "YELLOW", "Aguardando")
	oBrowse:AddLegend("ZA1_STATUS=='2'", "GREEN" , "Integrado")
	oBrowse:AddLegend("ZA1_STATUS=='E'", "RED"   , "Erro")

	oBrowse:Activate()
Return

/*--------------------------------------------------------------------------+
|  GetIcon - Retorna o ícone de cada rotina                                 |
----------------------------------------------------------------------------*/
Static Function GetIcon(cTipo)
	Local cRet
	DO CASE
		CASE cTipo=='PEDIDO'
		cRet:='CLIENTE'
		CASE cTipo=='ORCAMENTO'
		cRet:='BUDGET'
		CASE cTipo=='BLOQUEIO'
		cRet:='AUTOM'
		CASE cTipo=='LIB CREDITO'
		cRet:='CARGA'
		CASE cTipo=='LIB ESTOQUE'
		cRet:='ESTOMOVI'
		CASE cTipo=='TRANSMITE NF'
		cRet:='AVIAO'
	ENDCASE
return cRet

/*--------------------------------------------------------------------------+
|  KAPREFRE - Executa Refresh na tela                                       |
----------------------------------------------------------------------------*/
User Function KAPREFRE()
	oBrowse:Refresh()
return

/*--------------------------------------------------------------------------+
|  MenuDef - Definição do menu da loja                                      |
----------------------------------------------------------------------------*/
Static Function MenuDef()
	Local aRotina := { { "Atualizar" ,"U_KAPREFRE" ,0,3},;
	{ "Visualizar" ,"VIEWDEF.KAPAZI_ORCFLUIG" ,0,2},;
	{ "Reprocessar","U_KAPREPRO" ,0,4},;
	{ "Reprocessar TODOS","U_KAPRETOT" ,0,4}}
Return aRotina

/*--------------------------------------------------------------------------+
|  ModelDef -                                                               |
----------------------------------------------------------------------------*/
Static Function ModelDef()
	Local cAlias    := 'ZA1'
	Local oModel 	:= NIL
	Local oStruMan 	:= FWFormStruct(1,cAlias, {|cCampo| !(AllTrim(cCampo) $ cAlias+"_FILIAL")})

	oModel := MPFormModel():New('_MonFluig', /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

	oModel:AddFields( 'MdFieldMan',/*cOwner*/,oStruMan, /*bLinePre*/,/*bLinePost*/, /*bPreVal*/, /*bPosVal*/)

	oModel:SetDescription("Protheus Vs Fluig")

	oModel:SetPrimaryKey( { cAlias+"_FILIAL", cAlias+"_TIPO", cAlias+"_NUM" } )

Return oModel

/*--------------------------------------------------------------------------+
|  ViewDef -                                                                |
----------------------------------------------------------------------------*/
Static Function ViewDef()
	Local cAlias    := 'ZA1'
	Local oView		:= NIL
	Local oModel  	:= ModelDef()
	Local oStruMan	:= FWFormStruct(2,cAlias, {|cCampo| !(AllTRim(cCampo) $ cAlias+"_FILIAL")})

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField('VIEW_'+cAlias, oStruMan, 'MdFieldMan')

	oView:CreateHorizontalBox("MAIN",100)

	oView:SetOwnerView('VIEW_'+cAlias,'MAIN')

	oView:EnableControlBar(.T.)

Return oView

/*--------------------------------------------------------------------------+
|  KAPREPRO - Reprocessa a integração                                       |
----------------------------------------------------------------------------*/
User function KAPREPRO()
	Local cMsg
	if ZA1->ZA1_STATUS=='2' //Não estiver integrado
		cMsg:='Esse documento já foi integrado ao Fluig. '
		if !Empty(ZA1->ZA1_FLUIG)
			cMsg+='O código no Fluig é '+Alltrim(ZA1->ZA1_FLUIG)
		endif
		alert(cMsg)
	else
		if ZA1->ZA1_DTCRIA==Date() .AND. ELAPTIME(ZA1->ZA1_HRCRIA, TIME())<'00:02:00'
			alert('Trabalhando de forma automática, aguarde mais 3 minutos antes de tentar de forma manual...')
		else
			cModo:='ONE' //Modo um somente
			Processa( {|| Send(ZA1->ZA1_TIPO, ZA1->ZA1_NUM) }, "Enviando ao fluig...", "Iniciando...",.F.)
		endif
	endif
return

/*--------------------------------------------------------------------------+
|  KAPRETOT - Reprocessa TODOS os não integrados                            |
----------------------------------------------------------------------------*/
User function KAPRETOT()
	cModo:='ALL' //Modo TODOS
	Processa( {|| SendAll()}, "Enviando ao fluig...", "Iniciando...",.F.)
return

/*--------------------------------------------------------------------------+
|  KAPREPRO - Reprocessa TODOS os não integrados                            |
----------------------------------------------------------------------------*/
Static function SendAll()
	Local aArea:=GetArea()
	Local cAlQry:=GetNextAlias()
	Local cQry

	cQry:= "Select ZA1_TIPO,ZA1_NUM,ZA1_HRCRIA,ZA1_DTCRIA FROM "+RetSQLName('ZA1')
	cQry+= " where D_E_L_E_T_='' AND ZA1_STATUS<>'2'" //Não estiver integrado
	cQry:= ChangeQuery(cQry)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlQry,.T.,.T.)

	while !(cAlQry)->(EOF())
		if !(ZA1->ZA1_DTCRIA==Date() .AND. ELAPTIME(ZA1->ZA1_HRCRIA, TIME())<'00:02:00')
			incProc("Enviando ao fluig ("+Alltrim((cAlQry)->ZA1_NUM)+")...")
			Send((cAlQry)->ZA1_TIPO,(cAlQry)->ZA1_NUM ) //Envia o documento ao Fluig
		endif
		(cAlQry)->(DBSkip())
	enddo

	RestArea(aArea)
return

/*--------------------------------------------------------------------------+
|  KapJob - Job que irá enviar ao fluig o ORCAMENTO                         |
----------------------------------------------------------------------------*/
User function KapJob(cTipo, cNum, cEmpJob, cFilJob)
	conout(Time() + ' - Kapazi: Iniciando Job...')
	RPCSetType(3)  //Não consome licenças
	RpcSetEnv(cEmpJob, cFilJob,,,,GetEnvServer()) //Abertura do ambiente em rotinas automáticas
	conout(Time() + ' - Kapazi: Iniciando com fluig...')
	
	Send(cTipo,cNum) //Envia o documento ao Fluig
    U_LibPedSched()  //Envia status de Liberação
    
	RpcClearEnv()

	conout(Time() + ' - Kapazi: Job Finalizado!')
Return

/*--------------------------------------------------------------------------+
| ProcPed -                                                                 |
----------------------------------------------------------------------------*/
User Function ProcPed(cTipo, cNum)
	Send(cTipo,cNum) //Envia o documento ao Fluig
Return

/*--------------------------------------------------------------------------+
|  ProcLog -                                                               |
----------------------------------------------------------------------------*/
User Function ProcLog(TIPO, PEDIDO, STATUS, NUMFLUIG )
	Local lOperacao

	DBSelectArea('ZA1')  //Integração Protheus vs Fluig
	ZA1->(DBSetOrder(1)) //ZA1_FILIAL+ZA1_TIPO+ZA1_NUM
	IF ZA1->(DBSeek(xFilial('ZA1')+PADR(TIPO,TamSX3('ZA1_TIPO')[1])+PEDIDO))
		lOperacao := .F.
	ELSE
		lOperacao := .T.
	ENDIF

	Reclock('ZA1',lOperacao)
	ZA1->ZA1_FILIAL:=xFilial('ZA1')
	ZA1->ZA1_TIPO  :=TIPO
	ZA1->ZA1_NUM   :=PEDIDO
	ZA1->ZA1_STATUS:=STATUS
	ZA1->ZA1_DTCRIA:=Date()
	ZA1->ZA1_HRCRIA:=Time()
	ZA1->ZA1_FLUIG :=NUMFLUIG
	MsUnlock()
Return

/*--------------------------------------------------------------------------+
|  Send - Integra com o Fluig                                               |
----------------------------------------------------------------------------*/
Static function Send(cTipo,cNum)
	cTipo=Alltrim(cTipo)
	DO CASE
		CASE cTipo=='ORCAMENTO'
		SendOrcamento(cNum)  //Envia o ORCAMENTO
		CASE cTipo=='PEDIDO'
		SendPedido(cNum)     //Envia o Pedido de vendas
		CASE cTipo=='BLOQUEIO'
		u_LibPedido(cNum)    //Envia a Liberação do Pedido		
		CASE cTipo=='LIB CREDITO'
		SendLibCre(cNum)     //Envia Liberação de Crédito do Pedido
		CASE cTipo=='LIB ESTOQUE'
		SendLibEst(cNum)     //Envia a liberação do estoque
		CASE cTipo=='TRANSMITE NF'
		SendNF(cNum)         //Envia a Nota Fiscal
	ENDCASE
return

/*--------------------------------------------------------------------------+
|  SendPedido - Integra o PEDIDO com o Fluig                                |
----------------------------------------------------------------------------*/
Static function SendPedido(cNum)
	Local aArea := GetArea()
	Local lRet 				 := .T.
	Local cUser				 := SuperGetMV('MV_X_DIREC',.F., 'protheus')// login do usuário.
	Local cPassword			 := SuperGetMV('MV_X_PASS',.F., '1') 		// senha do usuário.
	Local nCompanyId		 := VAL(SuperGetMV('MV_X_COMP',.F., '01')) 	// código da empresa.
	Local nProcessInstanceId  							// número da solicitação.
	Local nChoosedState 	 := 113                     // número da atividade. FLUIG
	Local cColleagueIds		 							// usuário que receberá a tarefa.
	Local cComments		 	 := "Movimentado via WS"	// comentários.
	Local cUserId			 := SuperGetMV('MV_X_DIREC',.F., 'protheus')// matrícula do usuário que vai executar a tarefa.
	Local lCompleteTask		 := .T.										// indica se deve completar a tarefa (true) ou somente salvar (false).
	Local oAttachments		 := "" 		// anexos da solicitação.
	Local oCardData			 := {} 		// dados do registro de formulário.
	Local oAppointment 		 := ""		// apontamentos da tarefa.
	Local lManagerMode		 := .T.		// indica se usuário esta executando a tarefa como gestor do processo.
	Local nThreadSequence	 := 0 		// Indica se existe atividade paralela no processo. Se não existir o valor é 0 (zero), caso exista, este valor pode ser de 1 a infinito dependendo da quantidade de atividade paralelas existentes no processo.
	Local oSvc
	Local nCardId, cOrc
	Local cMsg

	DBSelectArea('ZA1')  //Integração Protheus vs Fluig
	ZA1->(DBSetOrder(1)) //ZA1_FILIAL+ZA1_TIPO+ZA1_NUM
	ZA1->(DBSeek(xFilial('ZA1')+PADR('PEDIDO',TamSX3('ZA1_TIPO')[1])+cNum))

	if ZA1->ZA1_STATUS!='2' //Se Não estiver integrado

		DBSelectArea('SC5')  //Pedido

		SC5->(DBSetOrder(1)) //C5_FILIAL+C5_NUM

		if SC5->(DBSeek(xFilial('SC5')+Padr(ZA1->ZA1_NUM,TamSX3('C5_NUM')[1])))

			DBSelectArea('SC6')  //Itens do Pedido
			SC6->(DBSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM
			SC6->(DBSeek(xFilial('SC6')+SC5->C5_NUM))
			cOrc:=Padr(SC6->C6_NUMORC,TamSX3('CJ_NUM')[1])

			DBSelectArea('SCJ')  //ORCAMENTO
			SCJ->(DBSetOrder(1)) //CJ_FILIAL+CJ_NUM
			SCJ->(DBSeek(xFilial('SCJ')+cOrc))

			nProcessInstanceId 	:= VAL(SCJ->CJ_XNUMFLU)
			cColleagueIds		:= SCJ->CJ_XUSRFLU

			If Alltrim(cEmpAnt) == "04"

				oSvc := WSECMWorkflowEngineServiceService():New()
				oCardData := { "fdPedido",SC5->C5_NUM }

				/*********************************/

				IF oSvc:getAttachments(cUser, cPassword, nCompanyId, cUserId, nProcessInstanceId)

					nCardId := oSvc:OWSGETATTACHMENTSATTACHMENTS:OWSITEM[1]:NDOCUMENTID

					//Chamo funcao para atualizar campo no fluig
					IncProc('Atualizando campo no  fluig...')

					IF U_UPDCARDTA(nCompanyId, cUser, cPassword, nCardId, oCardData)
						//Chama funcao que Movimenta solicitação para próxima atividade no Fluig
						IncProc('Salvando Task...')

						if U_saveSTask(cUser, cPassword, nCompanyId, nProcessInstanceId, nChoosedState, cColleagueIds, cComments, cUserId, lCompleteTask, oAttachments, oCardData, oAppointment, lManagerMode, nThreadSequence)
							RecLock('ZA1', .F.)
							ZA1->ZA1_STATUS:='2' //Processado
							ZA1->ZA1_LOG:='Integrado com sucesso'
							ZA1->ZA1_DATA:=Date()
							ZA1->ZA1_HORA:=Time()
							//ZA1->ZA1_FLUIG :=SCJ->CJ_XNUMFLU
							MsUnlock()
						else
							RecLock('ZA1', .F.)
							ZA1->ZA1_STATUS:='E' //Erro
							ZA1->ZA1_LOG:='Erro na integração Não foi atualizar a tarefa. (KAPAZI_ORCFLUIG) (SENDPEDIDO)'
							ZA1->ZA1_DATA:=Date()
							ZA1->ZA1_HORA:=Time()
							//ZA1->ZA1_FLUIG :=SCJ->CJ_XNUMFLU
							MsUnlock()
						endif

					else
						RecLock('ZA1', .F.)
						ZA1->ZA1_STATUS:='E' //Erro
						ZA1->ZA1_LOG:='Erro na integração. Não foi possivel atualizar inforações do card. (KAPAZI_ORCFLUIG) (SENDPEDIDO)'
						ZA1->ZA1_DATA:=Date()
						ZA1->ZA1_HORA:=Time()
						//ZA1->ZA1_FLUIG :=SCJ->CJ_XNUMFLU
						MsUnlock()
					endIf

				else
					RecLock('ZA1', .F.)
					ZA1->ZA1_STATUS:='E' //Erro
					ZA1->ZA1_LOG:='Erro na integração. Não foi possivel adquirir DOCUMENTID (KAPAZI_ORCFLUIG) (SENDPEDIDO)'
					ZA1->ZA1_DATA:=Date()
					ZA1->ZA1_HORA:=Time()
					//ZA1->ZA1_FLUIG :=SCJ->CJ_XNUMFLU
					MsUnlock()
				endIf
			endIf
		endif
	endif

	RestArea(aArea)

return

/*--------------------------------------------------------------------------+
|  SendLibCre - Integra com o Fluig                                         |
----------------------------------------------------------------------------*/
Static function SendLibCre(cNum)
	Local lRet 	:= .T.
	Local i
	Local cUser				 := SuperGetMV('MV_X_DIREC',.F., 'protheus')//login do usuário.
	Local cPassword			 := SuperGetMV('MV_X_PASS',.F., '1') 		// senha do usuário.
	Local nCompanyId		 := VAL(SuperGetMV('MV_X_COMP',.F., '01')) 	// código da empresa.
	Local nProcessInstanceId 					 						// número da solicitação.
	Local nChoosedState 	 := 141                                     // numero da atividade
	Local cColleagueIds		 											// usuário que receberá a tarefa.
	Local cComments		 	 := "Movimentado via WS"					// comentários.
	Local cUserId			 := SuperGetMV('MV_X_DIREC',.F., 'protheus')// matrícula do usuário que vai executar a tarefa.
	Local lCompleteTask		 := .T.										// indica se deve completar a tarefa (true) ou somente salvar (false).
	Local oAttachments		 := "" 										// anexos da solicitação.
	Local oCardData 		 := {"tipoAvaliacao","A","fdPedido",SC5->C5_NUM}	// dados do registro de formulário.
	Local oAppointment 		 := ""		// apontamentos da tarefa.
	Local lManagerMode		 := .T.		// indica se usuário esta executando a tarefa como gestor do processo.
	Local nThreadSequence	 := 0 		// Indica se existe atividade paralela no processo. Se não existir o valor é 0 (zero)...
	Local nCardId
	Local oSvc
	Local cMsg:=''

	DBSelectArea('ZA1')  //Integração Protheus vs Fluig
	ZA1->(DBSetOrder(1)) //ZA1_FILIAL+ZA1_TIPO+ZA1_NUM
	ZA1->(DBSeek(xFilial('ZA1')+PADR('LIB CREDITO',TamSX3('ZA1_TIPO')[1])+cNum))

	if ZA1->ZA1_STATUS!='2' //Se Não estiver integrado
		DBSelectArea('SC5')  //Pedido
		SC5->(DBSetOrder(1)) //C5_FILIAL+C5_NUM
		if SC5->(DBSeek(xFilial('SC5')+Padr(ZA1->ZA1_NUM,TamSX3('C5_NUM')[1])))
			DBSelectArea('SC6')  //Itens do Pedido
			SC6->(DBSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM
			SC6->(DBSeek(xFilial('SC6')+SC5->C5_NUM))

			If Empty(SC5->C5_XLIBFLU) .or. SC5->C5_XLIBFLU == 'N' .And. !Empty(SC6->C6_NUMORC)
				IncProc('Chamando Workflow...')
				oSvc := WSECMWorkflowEngineServiceService():New()

				dbSelectArea("SCJ")
				SCJ->(DbSetOrder(1))

				dbSelectArea("SC6")
				SC6->(dbSetOrder(1))
				if SC6->(dbSeek(xFilial("SC6") + SC5->C5_NUM))
					If SCJ->(DbSeek(xFilial("SCJ") + SUBSTR(SC6->C6_NUMORC,1,6),.T. ))
						nProcessInstanceId  := VAL(SCJ->CJ_XNUMFLU)
						cColleagueIds		:= SCJ->CJ_XUSRFLU
					EndIF
				EndIF

				//Invoco o metodo abaixo para pegar o numero do documentoID
				IF oSvc:getAttachments(cUser, cPassword, nCompanyId, cUserId, nProcessInstanceId)
					nCardId := oSvc:OWSGETATTACHMENTSATTACHMENTS:OWSITEM[1]:NDOCUMENTID

					//Chamo funcao para atualizar campo no fluig
					IncProc('Atualizando campo...')

					//Invoco o metodo abaixo para pegar o numero do documentoID
					IF oSvc:getAttachments(cUser, cPassword, nCompanyId, cUserId, nProcessInstanceId)
						nCardId := oSvc:OWSGETATTACHMENTSATTACHMENTS:OWSITEM[1]:NDOCUMENTID

						//Chamo funcao para atualizar campo no fluig
						IncProc('Salvando Task...')
						oWs 	:= WSECMWorkflowEngineServiceService():New()

						if oWs:saveAndSendTask(cUser, cPassword, nCompanyId, nProcessInstanceId, nChoosedState, , cComments, cUserId, lCompleteTask, , , , lManagerMode, nThreadSequence)

							For i := 1 to LEN(oWs:oWssaveAndSendTaskResult:oWsItem)
								IF "ERROR" $ oWs:oWssaveAndSendTaskResult:oWsItem[i]:cItem[1]
									cMsg += enter + oWs:oWssaveAndSendTaskResult:oWsItem[i]:cItem[2]
									lRet := .F.
									nRet := 16 //erro

									//MessageBox(cMsg,"",nRet)

								ElseIF "WDNrDocto" $ oWs:oWssaveAndSendTaskResult:oWsItem[i]:cItem[1]
									cMsg += "Atividade movimentada no Fluig: "+ oWs:oWssaveAndSendTaskResult:oWsItem[i]:cItem[2]
								EndIf
							next i
						else
							cMsg := "Erro na criacao do processo :" + getWSCError()
							lRet := .F.
							nRet := 16 //erro
						endIf
						
						if lRet
							RecLock("SC5",.F.)
							SC5->C5_XLIBFLU := 'S'
							SC5->(MsUnlock())

							RecLock('ZA1', .F.)
							ZA1->ZA1_STATUS:='2' //Processado
							ZA1->ZA1_LOG:='Integrado com sucesso'
							ZA1->ZA1_DATA:=Date()
							ZA1->ZA1_HORA:=Time()
							MsUnlock()
						Else
							RecLock('ZA1', .F.)
							ZA1->ZA1_STATUS:='E' //Erro
							ZA1->ZA1_LOG:='Erro na integração:'+cMsg
							ZA1->ZA1_DATA:=Date()
							ZA1->ZA1_HORA:=Time()
							MsUnlock()
							lRet := .F.
						EndIf
					Else
						RecLock('ZA1', .F.)
						ZA1->ZA1_STATUS:='E' //Erro
						ZA1->ZA1_LOG:='Erro na integração:'+GetWSCError()
						ZA1->ZA1_DATA:=Date()
						ZA1->ZA1_HORA:=Time()
						MsUnlock()
						lRet := .F.
					EndIf

				Else
					RecLock('ZA1', .F.)
						ZA1->ZA1_STATUS:='E' //Erro
						ZA1->ZA1_LOG:='Erro na integração:'+GetWSCError()
						ZA1->ZA1_DATA:=Date()
						ZA1->ZA1_HORA:=Time()
					MsUnlock()
					lRet := .F.
				EndIf
			endif
		EndIf
	endif

Return(lRet)


/*--------------------------------------------------------------------------+
|  SendLibEst - Envia ao Fluig Liberação do Estoque                         |
----------------------------------------------------------------------------*/
Static function SendLibEst(cNum)
    Local i
	Local cMsg:=''
	Local lRet:=.T.
	Local cUser				 := SuperGetMV('MV_X_DIREC',.F., 'protheus')// login do usuário.
	Local cPassword			 := SuperGetMV('MV_X_PASS',.F., '1') 		// senha do usuário.
	Local nCompanyId		 := VAL(SuperGetMV('MV_X_COMP',.F., '01')) 	// código da empresa.
	Local nProcessInstanceId 					 						// número da solicitação.
	Local nChoosedState 	 := 144				                        // número da atividade.
	Local cColleagueIds		 := ALLTRIM(SuperGetMV('MV_X_DIREC',.F., 'protheus'))// usuário que receberá a tarefa.
	Local cComments		 	 := "Movimentado via WS"					// comentários.
	Local cUserId			 := SuperGetMV('MV_X_DIREC',.F., 'protheus')// matrícula do usuário que vai executar a tarefa.
	Local lCompleteTask		 := .T.										// indica se deve completar a tarefa (true) ou somente salvar (false).
	Local oAttachments		 := "" 		// anexos da solicitação.
	Local oCardData			 := {} 		// dados do registro de formulário.
	Local oAppointment 		 := ""		// apontamentos da tarefa.
	Local lManagerMode		 := .T.		// indica se usuário esta executando a tarefa como gestor do processo.
	Local nThreadSequence	 := 0 		// Indica se existe atividade paralela no processo. Se não existir o valor é 0 (zero), caso exista, este valor pode ser de 1 a infinito dependendo da quantidade de atividade paralelas existentes no processo.

    DBSelectArea('ZA1')  //Integração Protheus vs Fluig
	ZA1->(DBSetOrder(1)) //ZA1_FILIAL+ZA1_TIPO+ZA1_NUM
	ZA1->(DBSeek(xFilial('ZA1')+PADR('LIB ESTOQUE',TamSX3('ZA1_TIPO')[1])+cNum))

	If ZA1->ZA1_STATUS!='2' //Se Não estiver integrado
	
		DbSelectArea("SC6")  //Itens do Pedido de Vendas
		SC6->(dbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM
		IF SC6->(dbSeek(xFilial("SC6") + Padr(cNum,TamSX3('C6_NUM')[1])))
	
			DbSelectArea("SCJ")  //ORCAMENTO
			SCJ->(DbSetOrder(1))
	
			If SCJ->(DbSeek(xFilial("SCJ") + Padr(SC6->C6_NUMORC,TamSX3('CJ_NUM')[1]),.T. ))
				nProcessInstanceId  := VAL(SCJ->CJ_XNUMFLU)
				oCardData := {"NOTA",''}
			EndIf
	
	        //Chamo funcao para atualizar campo no fluig
	     	IncProc('Salvando Task...')
			oWs 	:= WSECMWorkflowEngineServiceService():New()
	
			if oWs:saveAndSendTask(cUser, cPassword, nCompanyId, nProcessInstanceId, nChoosedState, , cComments, cUserId, lCompleteTask, , , , lManagerMode, nThreadSequence)
				For i := 1 to LEN(oWs:oWssaveAndSendTaskResult:oWsItem)
					IF "ERROR" $ oWs:oWssaveAndSendTaskResult:oWsItem[i]:cItem[1]
						cMsg += enter + oWs:oWssaveAndSendTaskResult:oWsItem[i]:cItem[2]
						lRet := .F.
					ElseIF "WDNrDocto" $ oWs:oWssaveAndSendTaskResult:oWsItem[i]:cItem[1]
						cMsg += "Atividade movimentada no Fluig: "+ oWs:oWssaveAndSendTaskResult:oWsItem[i]:cItem[2]
					EndIf
				next i
			else
				cMsg := "Erro na criacao do processo :" + getWSCError()
				lRet := .F.
			endIf
						
			if lRet
				RecLock('ZA1', .F.)
				ZA1->ZA1_STATUS:='2' //Integrado
				ZA1->ZA1_LOG:='Integrado com sucesso!'
				ZA1->ZA1_DATA:=Date()
				ZA1->ZA1_HORA:=Time()
				MsUnlock()
			else
				RecLock('ZA1', .F.)
				ZA1->ZA1_STATUS:='E' //Erro
				ZA1->ZA1_LOG:="Erro ao enviar informação para o fluig do pedido "+cNum+enter+cMsg
				ZA1->ZA1_DATA:=Date()
				ZA1->ZA1_HORA:=Time()
				MsUnlock()
				return
			EndIf
	
		EndIf
	endif

return

/*--------------------------------------------------------------------------+
|  SendNF - Integra a Nota Fiscal com o Fluig                               |
----------------------------------------------------------------------------*/
Static function SendNF(cNum)
	Local oSvc
	Local nCardId

	Local cUser				 := SuperGetMV('MV_X_DIREC',.F., 'protheus')//login do usuário.
	Local cPassword			 := SuperGetMV('MV_X_PASS',.F., '1') 		// senha do usuário.
	Local nCompanyId		 := VAL(SuperGetMV('MV_X_COMP',.F., '01')) 	// código da empresa.
	Local nProcessInstanceId 					 						// número da solicitação.
	Local nChoosedState 	 := 70				                        // número da atividade.
	Local cColleagueIds		 := SuperGetMV('MV_X_DIREC',.F., 'protheus')// usuário que receberá a tarefa.
	Local cComments		 	 := "Movimentado via WS"					// comentários.
	Local cUserId			 := SuperGetMV('MV_X_DIREC',.F., 'protheus')// matrícula do usuário que vai executar a tarefa.
	Local lCompleteTask		 := .T.										// indica se deve completar a tarefa (true) ou somente salvar (false).
	Local oAttachments		 := "" 		// anexos da solicitação.
	Local oCardData			 := {} 		// dados do registro de formulário.
	Local oAppointment 		 := ""		// apontamentos da tarefa.
	Local lManagerMode		 := .T.		// indica se usuário esta executando a tarefa como gestor do processo.
	Local nThreadSequence	 := 0 		// Indica se existe atividade paralela no processo. Se não existir o valor é 0 (zero), caso exista, este valor pode ser de 1 a infinito dependendo da quantidade de atividade paralelas existentes no processo.
	Local nNFTam             := TamSX3('C6_NOTA')[1]
	Local cNota              := Substr(cNum,1,nNFTam)
	Local cSerieNF           := Substr(cNum,nNFTam+1)

	DbSelectArea("SC6")
	SC6->(dbSetOrder(4)) //C6_FILIAL+C6_NOTA+C6_SERIE
	IF SC6->(dbSeek(xFilial("SC6") + cNum)) //cNota + cSerieNF
		oSvc 	:= WSECMWorkflowEngineServiceService():New()

		DBSelectArea('SF2')   //Nota Fiscal
		SF2->(DBSetOrder(1))  //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		SF2->(DBSeek(xFilial('SF2')+cNum))
	
		//Somente se foi autorizada pelo SEFAZ
		if !Empty(SF2->F2_DAUTNFE)

			DbSelectArea("SCJ")
			SCJ->(DbSetOrder(1))
			If SCJ->(DbSeek(xFilial("SCJ") + SUBSTR(SC6->C6_NUMORC,1,6),.T. ))
				nProcessInstanceId  := VAL(SCJ->CJ_XNUMFLU)
				oCardData := {"NOTA",cNota , "SERIE",cSerieNF, "EMISSAO", DTOC(SF2->F2_EMISSAO)+SF2->F2_HORA,"fdNumeroNF_Expedicao", cNota, "fdSerieNF_Expedicao", cSerieNF }
			EndIf
		
			If !Empty(SC6->C6_NUMORC)
			
				//Chamo funcao para atualizar campo no fluig
				IncProc('Atualizando campo no  fluig...')
				IF oSvc:getAttachments(cUser, cPassword, nCompanyId, cUserId, nProcessInstanceId)

					nCardId := oSvc:OWSGETATTACHMENTSATTACHMENTS:OWSITEM[1]:NDOCUMENTID
		
					IF U_UPDCARDTA(nCompanyId, cUser, cPassword, nCardId, oCardData)
						//Chama funcao que Movimenta solicitação para próxima atividade no Fluig
						IncProc('Salvando Task...')
		
						//Chama função para realizar a integração com o Fluig
						if U_saveSTask(cUser, cPassword, nCompanyId, nProcessInstanceId, nChoosedState, cColleagueIds, cComments, cUserId, lCompleteTask, oAttachments, oCardData, oAppointment, lManagerMode, nThreadSequence)
							RecLock('ZA1', .F.)
							ZA1->ZA1_STATUS:='2' //Processado
							ZA1->ZA1_LOG:='Integrado com sucesso'
							ZA1->ZA1_DATA:=Date()
							ZA1->ZA1_HORA:=Time()
							//ZA1->ZA1_FLUIG :=SCJ->CJ_XNUMFLU
							MsUnlock()
						else
							RecLock('ZA1', .F.)
							ZA1->ZA1_STATUS:='E' //Erro
							ZA1->ZA1_LOG:='Erro na integração ' + getWSCError()
							ZA1->ZA1_DATA:=Date()
							ZA1->ZA1_HORA:=Time()
							//ZA1->ZA1_FLUIG :=SCJ->CJ_XNUMFLU
							MsUnlock()
						endif
		
					else
						RecLock('ZA1', .F.)
						ZA1->ZA1_STATUS:='E' //Erro
						ZA1->ZA1_LOG:='Erro na integração. Não foi possivel adquirir DOCUMENTID (KAPAZI_ORCFLUIG) (SENDPEDIDO)'
						ZA1->ZA1_DATA:=Date()
						ZA1->ZA1_HORA:=Time()
						//ZA1->ZA1_FLUIG :=SCJ->CJ_XNUMFLU
						MsUnlock()
					endif
				else
					RecLock('ZA1', .F.)
					ZA1->ZA1_STATUS:='E' //Erro
					ZA1->ZA1_LOG:='Erro na integração. Não foi possivel adquirir DOCUMENTID (KAPAZI_ORCFLUIG) (SENDPEDIDO)'
					ZA1->ZA1_DATA:=Date()
					ZA1->ZA1_HORA:=Time()
					//ZA1->ZA1_FLUIG :=SCJ->CJ_XNUMFLU
					MsUnlock()
				ENDIF
			EndIf
		Endif
	EndIf

return

/*--------------------------------------------------------------------------+
|  SendOrcamento - Envia o ORCAMENTO ao Fluig                               |
----------------------------------------------------------------------------*/
Static function SendOrcamento(cNum)
	Local aArea 	:= getArea()
	Local i
	Local lRet := .T.
	Local nChoosedState:= 5  //número da atividade.
	Local cUsername		:= SuperGetMV('MV_X_USER',.F., 'protheus')		//login do usuário do fluig
	//"Para um Papel" ou "Para um Grupo", o parâmetro colleagueIds deve ser
	//informado da seguinte forma: Papel: Pool:Role:Nome_do_papel
	Local aDados	 	:= {} 											//dados do registro de formulário

	Local oWs   	:= wsECMWorkflowEngineServiceService():new()
	Local nX 		:= 0
	Local nRet 		:= 0
	Local cMsg		:= ""
	Local nPos, cJSON
	Local msgErroFluig:=""
	conout(Time() + ' - Kapazi: Enviando orcamento:'+cNum+'...')

	ProcRegua(3) //São 3 passos de envio - Coleta, Envio, Gravação

	IncProc('Coletando os dados...') //Passo 1
	DBSelectArea('ZA1')  //Integração Protheus vs Fluig
	ZA1->(DBSetOrder(1)) //ZA1_FILIAL+ZA1_TIPO+ZA1_NUM
	ZA1->(DBSeek(xFilial('ZA1')+PADR('ORCAMENTO',TamSX3('ZA1_TIPO')[1])+cNum))
	if ZA1->ZA1_STATUS!='2' //Não estiver integrado

		DBSelectArea('SCJ')  //ORCAMENTO
		SCJ->(DBSetOrder(1)) //CJ_FILIAL+CJ_NUM
		if SCJ->(DBSeek(xFilial('SCJ')+Padr(ZA1->ZA1_NUM,TamSX3('CJ_NUM')[1])))
			AADD(aDados,{"EMPRESA",CEMPANT})
			AADD(aDados,{"FILIAL",CFILANT})
			AADD(aDados,{"CJ_NUM",SCJ->CJ_NUM})
			AADD(aDados,{"CLIENTE",SCJ->CJ_CLIENTE})
			AADD(aDados,{"LOJA",SCJ->CJ_LOJA})
			AADD(aDados,{"CJ_CLIENTE",POSICIONE("SA1",1,XFILIAL("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,"A1_NOME")})
			AADD(aDados,{"CJ_EMISSAO",DTOC(SCJ->CJ_EMISSAO)})
			AADD(aDados,{"CJ_CONDPAG",SCJ->CJ_CONDPAG})
			AADD(aDados,{"CJ_XSTATUS",IIF(ALLTRIM(SCJ->CJ_XSTATUS) == '1','ABERTO','PRODUCAO')})
			AADD(aDados,{"CJ_XREFERE",ALLTRIM(SCJ->CJ_XREFERE)})
			AADD(aDados,{"CJ_XPERSON",IIF(ALLTRIM(SCJ->CJ_XPERSON) == '1','SIM','NAO')})
			AADD(aDados,{"CJ_XUSRFLU",ALLTRIM(SCJ->CJ_XUSRFLU)})

			oWs:cUsername        					:= cUsername 		//"protheus"
			oWs:cPassword        					:= SuperGetMV('MV_X_PASS',.F., '1') 	  //senha do usuário do fluig
			oWs:nCompanyId          				:= VAL(SuperGetMV('MV_X_COMP',.F., '01')) //código da empresa
			oWs:cProcessId          				:= "GestaoCooperkap" 					  //código do processo
			oWs:nChoosedState          				:= nChoosedState   								      //número da atividade.
			oWs:owsStartProcessColleagueIds:cItem   := {SuperGetMV('MV_X_PROX',.F., 'financeiro')} 	//usuário que receberá a tarefa. Caso a solicitação esteja sendo atribuída
			oWs:cComments        					:= "Importado via WS"
			oWs:cUserId        						:= SuperGetMV('MV_X_USER',.F., 'protheus') 		//matrícula do usuário que vai iniciar a solicitação"
			oWs:lCompleteTask          				:= .T.              //indica se deve completar a tarefa (true) ou somente salvar (false).
			oWs:lManagerMode          				:= .F.

			For nX := 1 To LEN(aDados)
				aAdd(oWs:oWsStartProcessCardData:oWsItem, ECMWorkflowEngineServiceService_stringArray():new())
				oWs:oWsStartProcessCardData:oWsItem[nX]:cItem := {aDados[nX][1], aDados[nX][2]}
			Next nX

			IncProc('Enviando...') //Passo 2
			if oWs:startProcess()
				IncProc('Gravando retorno...') //Passo 3
				lRet := .F.
				For i := 1 to LEN(oWs:oWsStartProcessResult:oWsItem)

					IF "ERROR" $ OWS:OWSSTARTPROCESSRESULT:OWSITEM[i]:CITEM[1]
						cMsg += enter + OWS:OWSSTARTPROCESSRESULT:OWSITEM[1]:CITEM[2]
						msgErroFluig += enter + OWS:OWSSTARTPROCESSRESULT:OWSITEM[1]:CITEM[2]

						//Fluig pode devolver um JSON como erro
						cJSON:=cMsg
						nPos:= At('{',cJSON)
						if nPos!=0
							cJSON:=SUBSTR(cJSON,nPos)
							oJson:=JsonObject():New()
							oJson:fromJSON(cJSON)

							if oJson['code']=='EXISTS'
								Begin Transaction
									RecLock('SCJ', .F.)
									SCJ->CJ_XNUMFLU := oJson['key']
									MsUnlock()

									RecLock('ZA1', .F.)
									ZA1->ZA1_STATUS:= '2' //Processado
									ZA1->ZA1_LOG   := 'Foi reprocessado'
									ZA1->ZA1_TIPO  := 'ORCAMENTO'
									ZA1->ZA1_DATA  := Date()
									ZA1->ZA1_HORA  := Time()
									ZA1->ZA1_FLUIG := oJson['key']
									MsUnlock()

									cMsg := "Foi iniciado o processo de aprovação de número: "+ oJson['key'] + " no Fluig."

								End Transaction
							else
								lRet := .F.
								nRet := 16 //erro
							endif
						else
							lRet := .F.
							nRet := 16 //erro
							RecLock('ZA1', .F.)
							ZA1->ZA1_STATUS:='E' //ERRO
							ZA1->ZA1_TIPO  := 'ORCAMENTO'
							ZA1->ZA1_LOG:=cMsg+' - '+msgErroFluig
							ZA1->ZA1_DATA:=Date()
							ZA1->ZA1_HORA:=Time()
							MsUnlock()

							EnvMail(cMsg,msgErroFluig,aDados)
						endif
					ElseIF "iProcess" $ oWs:oWsStartProcessResult:oWsItem[i]:cItem[1]
						cMsg += "Foi iniciado o processo de aprovação de número: "+ oWs:oWsStartProcessResult:oWsItem[i]:cItem[2] + " no Fluig."

						ConOut("Retorno Número Fluig - " + cValtoChar(oWs:oWsStartProcessResult:oWsItem[i]:cItem[2]))
						Begin Transaction
							RecLock('SCJ', .F.)
							SCJ->CJ_XNUMFLU := oWs:oWsStartProcessResult:oWsItem[i]:cItem[2]
							MsUnlock()

							RecLock('ZA1', .F.)
							ZA1->ZA1_STATUS:= '2' //Integrado
							ZA1->ZA1_TIPO  := 'ORCAMENTO'
							ZA1->ZA1_LOG   := 'Integrado com sucesso'
							ZA1->ZA1_DATA  := Date()
							ZA1->ZA1_HORA  := Time()
							ZA1->ZA1_FLUIG := oWs:oWsStartProcessResult:oWsItem[i]:cItem[2]
							MsUnlock()
						End Transaction

						ConOut(Time()+" - Kapazi: Alteração no Protheus realizada")
						lRet := .T.
					EndIf
				next i
			else
				IncProc('Analisando erro...') //Passo 3
				cMsg := enter+ "Erro na criacao do processo :" + getWSCError()
				lRet := .F.
				nRet := 16 //erro

				RecLock('ZA1', .F.)
				ZA1->ZA1_STATUS:='E' //ERRO
				ZA1->ZA1_TIPO  := 'ORCAMENTO'
				ZA1->ZA1_LOG   :=cMsg+' - '+msgErroFluig
				ZA1->ZA1_DATA  :=Date()
				ZA1->ZA1_HORA  :=Time()
				MsUnlock()

				EnvMail(cMsg,msgErroFluig,aDados)
			endIf

			ConOut(Time()+" - Kapazi: Mensagem final - " + cMsg)
			if !IsBlind() .AND. cModo='ONE'
				MessageBox(cMsg,"",nRet)
			endif
		endif
	endif

	RestArea(aArea)

return lRet

/*--------------------------------------------------------------------------+
|  KPLibEst - Gera  marcação para a Liberação do Estoque                    |
----------------------------------------------------------------------------*/
User function KPLibEst(cNum)
	Local aArea:=GetArea()

	DBSelectArea('ZA1')
	ZA1->(DBSetOrder(1)) 
	
	IF !ZA1->(DBSeek(xFilial('ZA1')+PADR('LIB ESTOQUE',TamSX3('ZA1_TIPO')[1])+cNum))
		dbSelectArea("SC6")
		SC6->(dbSetOrder(1))
		if SC6->(dbSeek(xFilial("SC6") + cNum))
			If !Empty(SC6->C6_NUMORC)
				dbSelectArea("SCJ") //ORCAMENTO
				SCJ->(DbSetOrder(1))
	
				SCJ->(DbSeek(xFilial("SCJ") + Padr(SC6->C6_NUMORC, TamSX3('CJ_NUM')[1])))
	
				//Verifica se é orcamento do fluig
				If !Empty(SCJ->CJ_XNUMFLU)
					Reclock('ZA1',.T.)
					ZA1->ZA1_FILIAL:=xFilial('ZA1')
					ZA1->ZA1_TIPO  :='LIB ESTOQUE'
					ZA1->ZA1_NUM   :=cNum
					ZA1->ZA1_STATUS:='1' //Aguardando
					ZA1->ZA1_DTCRIA:=Date()
					ZA1->ZA1_HRCRIA:=Time()
					ZA1->ZA1_FLUIG :=SCJ->CJ_XNUMFLU
					MsUnlock()
					
					//Inicia o JOB que irá integrar com o Fluig
					//Dessa forma, libera o APP mais rapidamente e evita o  TimeOut
					StartJob('U_KAPJOB',GetEnvServer(),.F., 'LIB ESTOQUE', cNum, CEMPANT, CFILANT)
				EndIF
			EndIF
		EndIF
	ENDIF
	
	RestArea(aArea)
return

/*--------------------------------------------------------------------------+
|  LibPedido - Libera e envia ao FLUIG                                      |
----------------------------------------------------------------------------*/
User Function LibPedido(PEDIDO)
	Local aArea := GetArea()
	Local nLiberado:=0

	DbSelectArea("SC5")
	SC5->(DBSetOrder(1))//C5_FILIAL+C5_NUM

	//Posicionando no registro
	if SC5->(DbSeek(xFilial("SC5") + ALLTRIM(PEDIDO),.T. ))
		IF SC5->C5_LIBEROK!='S'  //Se não estiver liberado
			dbSelectArea("SC6")  //Itens do Pedido
			dbSelectArea("ZA1")  //Integração
			ZA1->(DBSetOrder(1)) //ZA1_FILIAL+ZA1_TIPO+ZA1_NUM+ZA1_STATUS
	
			SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM
			SC6->(dbSeek(xFilial("SC6") + SC5->C5_NUM))
	
			Conout('KAPAZI - Liberando pedido '+ALLTRIM(PEDIDO)+'...')
			Begin Transaction
				While !SC6->(Eof()) .And. SC5->C5_NUM==SC6->C6_NUM
		
					/*	 Retorno   |ExpN1: Quantidade Liberada                                                            
						 Parametros|ExpN1: Registro do SC6                                      
						           |ExpN2: Quantidade a Liberar                                 
						           |ExpL3: Bloqueio de Credito                                  
						           |ExpL4: Bloqueio de Estoque                                  
						           |ExpL5: Avaliacao de Credito                                 
						           |ExpL6: Avaliacao de Estoque                                 
						           |ExpL7: Permite Liberacao Parcial                            
						           |ExpL8: Transfere Locais automaticamente                      
						           |ExpA9: Empenhos ( Caso seja informado nao efetua a gravacao apenas avalia ).                                    
						           |ExpbA: CodBlock a ser avaliado na gravacao do SC9           
						           |ExpAB: Array com Empenhos previamente escolhidos (impede selecao dos empenhos pelas rotinas)          
						           |ExpLC: Indica se apenas esta trocando lotes do SC9          
						           |ExpND: Valor a ser adicionado ao limite de credito          
						           |ExpNE: Quantidade a Liberar - segunda UM                    
					*/		
					
					//Libera Pedido			
					nLiberado += MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,.T./*bloq cred*/,.T./*bloq est*/,.T./*aval cred*/,.T./*aval est*/,.F./*lib parcial*/,.T./*transf locais*/)
					
					Conout('KAPAZI - Item: '+ALLTRIM(SC6->C6_ITEM)+', Quantidade: '+cValToChar(nLiberado))
					SC6->(dbSkip())
				EndDo
			End Transaction
			
			If ExistBlock("M440STTS")
			    // apontar ordem de producao de pedido personalizado
	            MV_PAR01:= SC5->C5_NUM  
	            MV_PAR02:= SC5->C5_NUM     
	            MV_PAR03:= SC5->C5_CLIENTE     
	            MV_PAR04:= SC5->C5_CLIENTE     
	            MV_PAR05:= STod('20000101')     
	            MV_PAR06:= STod('20301230')     
				ExecBlock("M440STTS",.f.,.f.)			
			Endif
			
			IF ZA1->(DBSeek(xFilial('ZA1')+PADR('BLOQUEIO',TamSX3('ZA1_TIPO')[1])+SC5->C5_NUM))
				if nLiberado > 0
					RecLock("SC5")
					SC5->C5_LIBEROK := "S"
					SC5->(MsUnlock())
				
					RecLock('ZA1', .F.)
					ZA1->ZA1_STATUS:='1' //Erro
					ZA1->ZA1_LOG +=enter + Dtoc(date()) + ' - ' + Time() + ' - Liberado com sucesso.'
					MsUnlock()
					SendBloq(Alltrim(PEDIDO))					
				else
					RecLock('ZA1', .F.)
					ZA1->ZA1_STATUS:='E' //Erro
					ZA1->ZA1_LOG:='Erro na integração: Erro liberação MaLibDoFat.'
					ZA1->ZA1_DATA:=Date()
					ZA1->ZA1_HORA:=Time()
					MsUnlock()
				endIf
			ENDIF	
		ENDIF			
	EndIf

	RestArea(aArea)

Return


/*--------------------------------------------------------------------------+
|  SendBloq - Envio informações sobre o bloqueio para o Fluig               |
----------------------------------------------------------------------------*/
Static function SendBloq(cNum)
    Local i
	Local aArea		:= GetArea()
	Local cMsg := ''
	Local cAliasSC9	:= GetNextAlias()
	Local cQuery 	:= ""
	Local lLibPv	:= .F.
	Local lBlqEst	:= .F.
	Local lBlqCre	:= .F.
	Local oSvc
	Local lRet 				 := .T.
	Local cUser				 := SuperGetMV('MV_X_DIREC',.F., 'protheus')//login do usuário.
	Local cPassword			 := SuperGetMV('MV_X_PASS',.F., '1') 		// senha do usuário.
	Local nCompanyId		 := VAL(SuperGetMV('MV_X_COMP',.F., '01')) 	// código da empresa.
	Local nProcessInstanceId 					 						// número da solicitação.
	Local nChoosedState 	 := 93							// número da atividade.
	Local cColleagueIds		 											// usuário que receberá a tarefa.
	Local cComments		 	 := "Movimentado via WS"					// comentários.
	Local cUserId			 := SuperGetMV('MV_X_DIREC',.F., 'protheus')// matrícula do usuário que vai executar a tarefa.
	Local lCompleteTask		 := .T.										// indica se deve completar a tarefa (true) ou somente salvar (false).
	Local oAttachments		 := "" 		// anexos da solicitação.
	Local oCardData			  			// dados do registro de formulário.
	Local oAppointment 		 := ""		// apontamentos da tarefa.
	Local lManagerMode		 := .F.		// indica se usuário esta executando a tarefa como gestor do processo.
	Local nThreadSequence	 := 0 		// Indica se existe atividade paralela no processo. Se não existir o valor é 0 (zero)...
    Local oSvc 				
	Local nCardId

	DBSelectArea('ZA1')  //Integração Protheus vs Fluig
	ZA1->(DBSetOrder(1)) //ZA1_FILIAL+ZA1_TIPO+ZA1_NUM
	ZA1->(DBSeek(xFilial('ZA1')+PADR('BLOQUEIO',TamSX3('ZA1_TIPO')[1])+cNum))

	If ZA1->ZA1_STATUS!='2' //Se Não estiver integrado
	    Conout('KAPAZI - Enviando informação de bloqueio do Pedido: '+cNum+'...')
		// seta ordem
		dbSelectArea("SCJ")
		SCJ->(DbSetOrder(1))

		dbSelectArea("SC6")
		SC6->(dbSetOrder(1))
		if SC6->(dbSeek(xFilial("SC6") + Padr(cNum,TamSX3('C6_NUM')[1])))
			If SCJ->(DbSeek(xFilial("SCJ") + SUBSTR(SC6->C6_NUMORC,1,6),.T. ))
				nProcessInstanceId  := VAL(SCJ->CJ_XNUMFLU)
				cColleagueIds		:= SCJ->CJ_XUSRFLU
			EndIF
		EndIF

		//Verifica se houve bloqueio de Crédito
		cQuery := "	SELECT C9_ITEM, C9_BLCRED, C9_BLEST "
		cQuery += "	FROM " + RetSqlName("SC9")
		cQuery += "	WHERE "
		cQuery += "	C9_FILIAL = '" + xFilial("SC9")+"'"
		cQuery += "	AND C9_PEDIDO = '" +cNum+"'"
		cQuery += "	AND C9_NFISCAL = '' "
		cQuery += "	AND D_E_L_E_T_ = '' "
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.T.,.T.)
		
		//Varre o SC9
		While !(cAliasSC9)->(Eof())
			lLibPv := .T.
			If !Empty((cAliasSC9)->C9_BLCRED)
				lBlqCre := .T.
				Exit
			EndIf
			If !Empty((cAliasSC9)->C9_BLEST)
				lBlqEst := .T.
				Exit
			EndIf
			(cAliasSC9)->(dbSkip())
		EndDo
		(cAliasSC9)->(DBCloseArea())

		//Possui bloqueio de crédito
		If lBlqCre
			oCardData := {"tipoAvaliacao","M", "fdPedido",SC6->C6_NUM }
			Conout('KAPAZI - Bloqueio de Credito')
		endIf

		//Possui bloqueio de Estoque
		If lBlqEst
			oCardData := {"tipoAvaliacao","E", "fdPedido",SC6->C6_NUM }
			Conout('KAPAZI - Bloqueio de Estoque')
		endIf

		if !lBlqCre .and. !lBlqEst
			oCardData := {"tipoAvaliacao","F", "fdPedido",SC6->C6_NUM }
			Conout('KAPAZI - Sem bloqueio, pronto para faturar')
		endIf

		IncProc('Chamando Workflow...')
		oSvc := WSECMWorkflowEngineServiceService():New()

		IF oSvc:getAttachments(cUser, cPassword, nCompanyId, cUserId, nProcessInstanceId)

			nCardId := oSvc:OWSGETATTACHMENTSATTACHMENTS:OWSITEM[1]:NDOCUMENTID

			//Chamo funcao para atualizar campo no fluig
			IncProc('Atualizando campo...')

			IF U_UPDCARDTA(nCompanyId, cUser, cPassword, nCardId, oCardData)

				//Chamo funcao para atualizar campo no fluig
				IncProc('Salvando Task...')
				oWs 	:= WSECMWorkflowEngineServiceService():New()

				if oWs:saveAndSendTask(cUser, cPassword, nCompanyId, nProcessInstanceId, nChoosedState, , cComments, cUserId, lCompleteTask, , , , lManagerMode, nThreadSequence)

					For i := 1 to LEN(oWs:oWssaveAndSendTaskResult:oWsItem)
						IF "ERROR" $ oWs:oWssaveAndSendTaskResult:oWsItem[i]:cItem[1]
							cMsg += enter + oWs:oWssaveAndSendTaskResult:oWsItem[i]:cItem[2]
							lRet := .F.
						ElseIF "WDNrDocto" $ oWs:oWssaveAndSendTaskResult:oWsItem[i]:cItem[1]
							cMsg += "Atividade movimentada no Fluig: "+ oWs:oWssaveAndSendTaskResult:oWsItem[i]:cItem[2]
						EndIf
					next i
				else
					cMsg := enter+ "Erro na criacao do processo :" + getWSCError()
					lRet := .F.
				endIf
				
				if lRet
				/*	RecLock("SC5",.F.)
					SC5->C5_XLIBFLU := 'S'
					MsUnlock() */

					RecLock('ZA1', .F.)
					ZA1->ZA1_STATUS:='2' //Processado
					ZA1->ZA1_LOG+=enter + 'Integrado com sucesso'
					ZA1->ZA1_DATA:=Date()
					ZA1->ZA1_HORA:=Time()
					MsUnlock()
				Else
					RecLock('ZA1', .F.)
					ZA1->ZA1_STATUS:='E' //Erro
					ZA1->ZA1_LOG:='Erro na integração:'+cMsg
					ZA1->ZA1_DATA:=Date()
					ZA1->ZA1_HORA:=Time()
					MsUnlock()
					lRet := .F.
				EndIf
			Else
				alert('Erro de Execução : '+GetWSCError())
			EndIf

		else
			RecLock('ZA1', .F.)
			ZA1->ZA1_STATUS:='E' //Erro
			ZA1->ZA1_LOG:="Erro ao enviar informação para o fluig do pedido "+cNum
			ZA1->ZA1_DATA:=Date()
			ZA1->ZA1_HORA:=Time()
			MsUnlock()
			RestArea(aArea)
			return
		EndIf

	endIf
	
	RestArea(aArea)

return

/*--------------------------------------------------------------------------+
|  JobLibPed - Job para Liberar Crédito e Estoque automaticamente           |
----------------------------------------------------------------------------*/
User Function JobLibPed(cEmpJob, cFilJob)
	
	conout(Time() + ' - Iniciando Integração Fluig para a Empresa:'+cEmpJob+'/'+cFilJob+'...')
	PREPARE ENVIRONMENT EMPRESA cEmpJob FILIAL cFilJob
	
	U_LibPedSched()
	TransNF()
	
	RESET ENVIRONMENT 
	
	conout(Time() + ' - Finalizado Integração Fluig!')

Return


/*--------------------------------------------------------------------------+
|  TransNF - Envia NF que foram autorizadas mais tarde pelo SEFAZ           |
----------------------------------------------------------------------------*/
Static Function TransNF()
	Local cQuery
	Local cAliasZA1
	Local aArea

	aArea := GetArea()
	
	cAliasZA1	:= GetNextAlias()

	cQuery := "	SELECT ZA1_NUM "
	cQuery += "	FROM ZA1040 " //Somente empresa 04
	cQuery += "	WHERE ZA1_TIPO = 'TRANSMITE NF'"
	cQuery += "	AND ZA1_STATUS = '1' AND D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery) 

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZA1,.T.,.T.)

	While !(cAliasZA1)->(Eof())
		Conout("---------------------------------------------------------------------------------------")
		Conout('Nota Fiscal: ' + (cAliasZA1)->ZA1_NUM)
	    SendNF(ALLTRIM((cAliasZA1)->ZA1_NUM))
		Conout("---------------------------------------------------------------------------------------")		
		(cAliasZA1)->(dbSkip())
	EndDo
	(cAliasZA1)->(DBCloseArea())

	RestArea(aArea)
	
RETURN

/*--------------------------------------------------------------------------+
|  LibPedSched - Libera Crédito e Estoque automaticamente                   |
----------------------------------------------------------------------------*/
User Function LibPedSched()
	Local cQuery
	Local cAliasZA1
	Local aArea

	aArea := GetArea()
	
	cAliasZA1	:= GetNextAlias()

	cQuery := "	SELECT ZA1_NUM "
	cQuery += "	FROM ZA1040 "
	cQuery += "	WHERE ZA1_TIPO = 'BLOQUEIO'"
	cQuery += "	AND ZA1_STATUS = '1' AND D_E_L_E_T_ = ''"

	cQuery := ChangeQuery(cQuery) 

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZA1,.T.,.T.)

	While !(cAliasZA1)->(Eof())
		Conout("---------------------------------------------------------------------------------------")
		Conout('Pedido: ' + (cAliasZA1)->ZA1_NUM)
		u_LibPedido(ALLTRIM((cAliasZA1)->ZA1_NUM))
		Conout("---------------------------------------------------------------------------------------")		
		(cAliasZA1)->(dbSkip())
	EndDo
	(cAliasZA1)->(DBCloseArea())

	RestArea(aArea)
	
RETURN

/*--------------------------------------------------------------------------+
|  EnvMail - Envia E-mail                                                   |
----------------------------------------------------------------------------*/
Static Function EnvMail(cMsg, msgErroFluig,aDados)
	local aArea		:= GetArea()
	Local cUser, cPass, cSendSrv
	Local nSendPort
	Local xRet
	Local oServer, oMessage

	cUser    := GetMV('KP_MBOLUSR', .f., 'kapazi') //define the e-mail account username
	cPass    := GetMV('KP_MBOLPWD', .f., 'laertes77') //define the e-mail account password
	cSendSrv := GetMV('KP_MBOLADD', .f., 'smtplw.com.br') //define the send server

	oServer := TMailManager():New()

	// oServer:SetUseSSL( GetMV('MOB_MSGSSL') )
	// oServer:SetUseTLS( GetMV('MOB_MSGTLS') )

	nSendPort := GetMV('KP_MBOLPRT', .f., 587)

	// once it will only send messages, the receiver server will be passed as ""
	// and the receive port number won't be passed, once it is optional
	xRet := oServer:Init( "", cSendSrv, cUser, cPass, , nSendPort )
	if xRet != 0
		cMsg := "Could not initialize SMTP server: " + oServer:GetErrorString( xRet )
		conout( 'Kapazi: '+cMsg )
		return
	endif

	// the method set the timout for the SMTP server
	xRet := oServer:SetSMTPTimeout( 60 )
	if xRet != 0
		cMsg := "Could not set SMTP timeout to " + cValToChar( 60 )
		conout( 'Kapazi: '+cMsg )
	endif

	// estabilish the connection with the SMTP server
	xRet := oServer:SMTPConnect()
	if xRet <> 0
		cMsg := "Could not connect on SMTP server: " + oServer:GetErrorString( xRet )
		conout( 'Kapazi: '+cMsg )
		return
	endif

	// authenticate on the SMTP server (if needed)
	xRet := oServer:SmtpAuth( cUser, cPass )
	if xRet <> 0
		cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
		conout( 'Kapazi: '+cMsg )
		oServer:SMTPDisconnect()
		return
	endif

	oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:cDate    := cValToChar( Date() )
	oMessage:cFrom    := GetMV('KP_MBOLMFR', .f., 'boleto@kapazi.com.br')
	oMessage:cTo      := cMailTo
	oMessage:cSubject := "Kapazi - Erro na integração com o Fluig"
	oMessage:cBody    := cMsg + enter +msgErroFluig+enter+varinfo("aDados",aDados)+enter+"Mensagem automatica enviada pelo Protheus - Não responder"

	xRet := oMessage:Send( oServer )
	if xRet <> 0
		cMsg := "Could not send message: " + oServer:GetErrorString( xRet )
		conout( 'Kapazi: '+cMsg )
	endif

	xRet := oServer:SMTPDisconnect()
	if xRet <> 0
		cMsg := "Could not disconnect from SMTP server: " + oServer:GetErrorString( xRet )
		conout( 'Kapazi: '+cMsg )
	endif

	RestArea(aArea)
return

//+--------------------------------------------------------------+
//¦ CriaZA1 - ORCAMENTO vs Fluig                                 ¦
//+--------------------------------------------------------------+
Static Function CriaZA1()
	Local nNumTam
	Private aField

	if !(SX2->(DBSeek('ZA1')))

		nNumTam:=TamSX3('F2_DOC')[1]+TamSX3('F2_SERIE')[1]

		//Campo      , Tipo, Tamanho             , Decimal, F3, Usado, Titulo, Descrição, Pasta, Obrigatório
		aField:={{ "ZA1_FILIAL", "C" ,TamSX3('CJ_FILIAL')[1] , 0, '   ','N', 'Filial'   , 'Filial'          ,'','N' },;
		{ "ZA1_TIPO"  , "C" ,30                     , 0, '   ','S', 'Tipo'     , 'Tipo de Integração' ,'','S' },;
		{ "ZA1_NUM"   , "C" ,nNumTam                , 0, '   ','S', 'Número'   , 'Número Documento','','S' },;
		{ "ZA1_STATUS", "C" ,1                      , 0, '   ','S', 'Status'   , 'Status Integração' ,'','S' },;
		{ "ZA1_DTCRIA", "D" ,8                      , 0, '   ','S', 'Dt Criado', 'Data Criação'  ,'','S' },;
		{ "ZA1_HRCRIA", "C" ,8                      , 0, '   ','S', 'Hr Criado', 'Hora Criação'  ,'','S' },;
		{ "ZA1_DATA"  , "D" ,8                      , 0, '   ','S', 'Data'     , 'Data Integração'  ,'','S' },;
		{ "ZA1_HORA"  , "C" ,5                      , 0, '   ','S', 'Hora'     , 'Hora Integração'  ,'','S' },;
		{ "ZA1_FLUIG" , "C" ,TamSX3('CJ_XNUMFLU')[1], 0, '   ','S', 'Fluig'    , 'Número Fluig'    ,'','S' },;
		{ "ZA1_LOG"   , "M" ,10                     , 0, '   ','S', 'Log'      , 'Log'             ,'','S' }}

		//Tabelas e Campos
		DBSelectArea('SX3')
		SX3->(DBSetOrder(2)) //X3_CAMPO
		CriaCampos(aField)

		SX3->(DBSetOrder(2)) //X3_CAMPO
		SX3->(DBSeek('ZA1_STATUS'))
		RecLock('SX3',.F.)
		SX3->X3_CBOX    := '1=Aguardando;2=Integrado;E=Erro'
		SX3->X3_CBOXSPA := '1=Aguardando;2=Integrado;E=Erro'
		SX3->X3_CBOXENG := '1=Waiting;2=Integrated;E=Error'
		MsUnlock('SX3')

		//Indices
		RecLock('SIX',.T.)
		SIX->INDICE   := 'ZA1'
		SIX->ORDEM    := '1'
		SIX->CHAVE    := 'ZA1_FILIAL+ZA1_TIPO+ZA1_NUM+ZA1_STATUS'
		SIX->DESCRICAO:= 'Tipo + Número + Status'
		SIX->DESCSPA  := 'Tipo + Numero + Status'
		SIX->DESCENG  := 'Type + Number + Status'
		SIX->PROPRI   := 'U'
		SIX->SHOWPESQ := 'S'
		MsUnlock()
		
		RecLock('SIX',.T.)
		SIX->INDICE   := 'ZA1'
		SIX->ORDEM    := '2'
		SIX->CHAVE    := 'ZA1_FILIAL+ZA1_FLUIG+ZA1_TIPO'
		SIX->DESCRICAO:= 'Fluig + Tipo'
		SIX->DESCSPA  := 'Fluig + Tipo'
		SIX->DESCENG  := 'Fluig + Type'
		SIX->PROPRI   := 'U'
		SIX->SHOWPESQ := 'S'
		MsUnlock()		

		//Arquivos
		RecLock('SX2',.T.)
		SX2->X2_CHAVE  := 'ZA1'
		SX2->X2_ARQUIVO:= 'ZA1'+FWGrpCompany()+'0'
		SX2->X2_NOME   := 'Kapazi - Protheus Vs Fluig'
		SX2->X2_NOMESPA:= 'Kapazi - Protheus Vs Fluig'
		SX2->X2_NOMEENG:= 'Kapazi - Protheus Vs Fluig'
		SX2->X2_MODO   := 'E'
		SX2->X2_MODOUN := 'E'
		SX2->X2_MODOEMP:= 'E'
		SX2->X2_UNICO  := 'ZA1_FILIAL+ZA1_TIPO+ZA1_NUM'
		MsUnlock()

	endif
	DBSelectArea('ZA1')
Return

//+--------------------------------------------------------------+
//¦ CriaCampos                                                   ¦
//+--------------------------------------------------------------+
Static Function CriaCampos(aFieldList)
	local nCnt
	local cOrdem:='00'

	for nCnt:=1 to len(aFieldList)
		cOrdem:=Soma1(cOrdem)
		RecLock('SX3',.T.)
		SX3->X3_ARQUIVO:= SubStr(aFieldList[nCnt,1],1,3)
		SX3->X3_ORDEM  := cOrdem
		SX3->X3_CAMPO  := aFieldList[nCnt,1]
		SX3->X3_TIPO   := aFieldList[nCnt,2]
		SX3->X3_TAMANHO:= aFieldList[nCnt,3]
		SX3->X3_DECIMAL:= aFieldList[nCnt,4]
		SX3->X3_F3     := aFieldList[nCnt,5]
		SX3->X3_TITULO := aFieldList[nCnt,7]
		SX3->X3_TITSPA := aFieldList[nCnt,7]
		SX3->X3_TITENG := aFieldList[nCnt,7]
		SX3->X3_DESCRIC:= aFieldList[nCnt,8]
		SX3->X3_DESCSPA:= aFieldList[nCnt,8]
		SX3->X3_DESCENG:= aFieldList[nCnt,8]
		if (aFieldList[nCnt,6]=='S')
			SX3->X3_USADO := 'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     '
		endif

		SX3->X3_RESERV := 'xxxxxx x        '
		SX3->X3_CONTEXT:= 'R' //Real
		SX3->X3_VISUAL := 'A' //Altera
		SX3->X3_BROWSE := 'S' //Mostrar no Browser
		SX3->X3_PROPRI := 'U' //Campo customizado pelo usuário
		SX3->X3_FOLDER := aFieldList[nCnt,9]

		if aFieldList[nCnt,10]=='S'
			SX3->X3_OBRIGAT := 'x       '
		endif
		MsUnlock()
	Next
return