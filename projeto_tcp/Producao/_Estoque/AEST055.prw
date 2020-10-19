#include 'protheus.ch'
#include "fwmvcdef.ch"
#include "Totvs.ch"
#include "Rwmake.ch"
#INCLUDE "TOPCONN.CH"


static aLotesTot
//static cEnderecoFail

/*/{Protheus.doc} AEst055
Rotina para cadastro de Requisição de EPIs

@author Rafael Ricardo Vieceli
@since 29/12/2017
@version 1.0

@type function
/*/
user function AEST055()
	Local oBrowse
	private cEnderecoFail := ''
	IF ! valParams()
		return
	EndIF

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "ZDW" )
	oBrowse:SetDescription( "Requisição de Materiais" )

	oBrowse:SetMenuDef("AEST055")

	oBrowse:AddLegend("u_AEst55Leg(1)","BR_PRETO"   ,"Ordem de produção não gerada")
	oBrowse:AddLegend("u_AEst55Leg(2)","BR_VERDE"   ,"Ordem de produção Aberta")
	oBrowse:AddLegend("u_AEst55Leg(3)","BR_AMARELO" ,"Ordem de produção com Ordem de separação")
	oBrowse:AddLegend("u_AEst55Leg(4)","BR_VERMELHO","Ordem de produção Finalizada")

	oBrowse:Activate()

return


/*/{Protheus.doc} MenuDef
Definição do menu

@author Rafael Ricardo Vieceli
@since 29/12/2017
@version 1.0

@type function
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.AEST055' OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina Title "Incluir"    Action 'VIEWDEF.AEST055' OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina Title "Excluir"    Action 'VIEWDEF.AEST055' OPERATION MODEL_OPERATION_DELETE ACCESS 0
	If( FwIsAdmin() )
		ADD OPTION aRotina Title "Excluir em lote"    Action 'U_A055EXCLOT' OPERATION MODEL_OPERATION_DELETE ACCESS 0
	EndIf

Return aRotina

/*/{Protheus.doc} AEst55Leg
Legendas

@author Rafael Ricardo Vieceli
@since 29/12/2017
@version 1.0
@param nLegend, numeric, descricao
@type function
/*/
user function AEst55Leg(nLegend)
	do case
		//op não gerada
	case nLegend == 1
		return empty(ZDW->ZDW_OP)

		//op aberta
	case nLegend == 2
		//ordem de produção
		SC2->( dbSetOrder(1) )
		SC2->( dbSeek( xFilial("SC2",ZDW->ZDW_FILIAL) + ZDW->ZDW_OP ) )
		IF Empty(SC2->C2_DATRF)
			//ordem de separação
			CB7->( dbSetOrder(5) )
			CB7->( dbSeek( xFilial("CB7",ZDW->ZDW_FILIAL) + ZDW->ZDW_OP ) )
			return ! CB7->( Found() )
		EndIF

		//op com ordem de separação
	case nLegend == 3
		//ordem de produção
		SC2->( dbSetOrder(1) )
		SC2->( dbSeek( xFilial("SC2",ZDW->ZDW_FILIAL) + ZDW->ZDW_OP ) )
		IF Empty(SC2->C2_DATRF)
			//ordem de separação
			CB7->( dbSetOrder(5) )
			CB7->( dbSeek( xFilial("CB7",ZDW->ZDW_FILIAL) + ZDW->ZDW_OP ) )
			return CB7->( Found() )
		EndIF

		//op finalizada
	case nLegend == 4
		//ordem de produção
		SC2->( dbSetOrder(1) )
		SC2->( dbSeek( xFilial("SC2",ZDW->ZDW_FILIAL) + ZDW->ZDW_OP ) )
		return ! Empty(SC2->C2_DATRF)
	endCase

return .F.



/*/{Protheus.doc} ModelDef
Definição do modelo

@author Rafael Ricardo Vieceli
@since 29/12/2017
@version 1.0

@type function
/*/
static function ModelDef()

	Local oModel
	Local oStructCab  	:= FWFormStruct(1,'ZDW', {|campo| alltrim(campo) $ 'ZDW_FILIAL#ZDW_NUMERO#ZDW_DATA#ZDW_OBSERV#ZDW_OP#ZDW_REQUIS#ZDW_TIPO' } )
	Local oStructItens 	:= FWFormStruct(1,'ZDW' )
	Local oCommit    	:= AE055COMMIT():New()

	oStructItens:RemoveField( 'ZDW_FILIAL' )
	oStructItens:RemoveField( 'ZDW_NUMERO' )
	oStructItens:RemoveField( 'ZDW_OBSERV' )
	oStructItens:RemoveField( 'ZDW_DATA' )
	oStructItens:RemoveField( 'ZDW_OP' )
	oStructItens:RemoveField( 'ZDW_REQUIS' )
	oStructItens:RemoveField( 'ZDW_TIPO' )

	oModel := MPFormModel():New('AEST055M')
	oModel:SetDescription('Requisição')
	oModel:addFields('ZDW_CAB',,oStructCab)
	oModel:addGrid('ZDW_ITENS','ZDW_CAB',oStructItens,/*bPreValidacao*/,{|oModel| bPosValidacao(oModel)}, /*bCarga*/ )
	oModel:SetRelation('ZDW_ITENS', { { 'ZDW_FILIAL', 'xFilial("ZDW")' }, { 'ZDW_NUMERO', 'ZDW_NUMERO' }, { 'ZDW_OP', 'ZDW_OP' } }, ZDW->(IndexKey(1)) )
	oModel:GetModel( 'ZDW_ITENS' ):SetUniqueLine( { 'ZDW_EPI', 'ZDW_LOCAL' } )
	oModel:GetModel('ZDW_ITENS'):SetDescription('Itens da Requisição')

	oModel:SetPrimaryKey({})

	oModel:InstallEvent("AE055COMMIT", /*cOwner*/, oCommit)

return oModel


/*/{Protheus.doc} bPosValidacao
Validação da linha

@author Rafael Ricardo Vieceli
@since 29/12/2017
@version 1.0
@return lógic, se a linha é valida
@param oModel, object, Modelo do grid
@type function
/*/
static function bPosValidacao(oModel)

	Local lContinua := .T.

	Local oModelCab   		:= FWModelActive()
	Local cValTipo		:= oModelCab:GetValue("ZDW_CAB","ZDW_TIPO")

	Local cProduto	:= oModel:GetValue( 'ZDW_EPI' )
	Local cArmazem	:= oModel:GetValue( 'ZDW_LOCAL' )
	Local nQtdTotal	:= oModel:GetValue( 'ZDW_QTDE' )
	Local cCentro	:= oModel:GetValue( 'ZDW_CC' )
	Local cConta	:= oModel:GetValue( 'ZDW_CONTA' )
	Local cItem	 	:= oModel:GetValue( 'ZDW_ITEMCT' )
	Local nQtdEs
	Local cGrpTi    := GetMV("TCP_GRPINF")
	Local cUsersTi  := GetMV("TCP_USRINF")
	Local lObrEpiMdt:= GetMv("TCP_EPOBMD")
/*
Local oModelCab := oModel:GetModel("ZDW_CAB")
Local oModelItem := oModel:GetModel("ZDW_ITENS")
*/
	IF alltrim(cProduto) == GetMV("TCP_PRDEPI") .OR. alltrim(cProduto) == GetMV("TCP_PRDMAT",,"") .OR. alltrim(cProduto) == GetMV("TCP_PRDINF",,"")
		lContinua := .F.
		Help("",1,"TCPPRODIGUAL",,"Não pode requisitar o produto usado para abertura de OP.",4,1)
	EndIF

	IF EMPTY(cValTipo)
		lContinua := .F.
		Help("",1,"TIPOSOLICITACAO",,"Existem campos obrigatórios não preenchidos no cabeçalho.",4,1)
	ENDIF

	If lObrEpiMdt .And. cValTipo =='1' .And. !FwIsInCallStack("U_TCMD03KM")
		lContinua := .F.
		Help("",1,"TIPOSOLICITACAO",,'Solicitação de EPI deve ser feita no modulo EPI X FUNCIONÁRIO do modulo Medicina e segurança.',4,1)
	EndIf

	IF lContinua
		SB1->( dbSetOrder(1) )
		SB1->( dbSeek( xFilial("SB1") + cProduto ) )


		IF lContinua .AND. SB1->B1_MSBLQL == '1'
			lContinua := .F.
			Help("",1,"TCPPRODBLQ",,'Produto '+SB1->B1_COD+' bloqueado',4,1)
		endif

		IF  lContinua .AND. ((cValTipo =='1' .AND. ALLTRIM(SB1->B1_GRUPO) !='ES') .OR. (cValTipo !='1' .AND. ALLTRIM(SB1->B1_GRUPO) =='ES') )
			lContinua := .F.
			Help("",1,"TCPRODINVALIDO",,'Só é possível solicitar EPI em uma requisição de EPI.',4,1)
		ENDIF

		IF  lContinua .AND. ( (cValTipo =='3' .AND. !(SB1->B1_GRUPO $ cGrpTi)) .OR. (cValTipo !='3' .AND. SB1->B1_GRUPO $ cGrpTi) )
			lContinua := .F.
			Help("",1,"TCPRODINVALIDO",,'Só é possível solicitar material de informática em uma requisição de Informática.',4,1)
		ENDIF

		IF  lContinua .AND. (cValTipo =='2' .AND. SB1->B1_GRUPO $ 'ES|'+cGrpTi )
			lContinua := .F.
			Help("",1,"TCPRODINVALIDO",,'Só é possível solicitar Material em uma requisição de Material.',4,1)
		ENDIF

		IF ( lContinua .AND. cValTipo =='3' .OR. SB1->B1_GRUPO) $ cGrpTi .AND. !(__cUserId $ cUsersTi)
			lContinua := .F.
			Help("",1,"USUARIO",,'Usuário sem permissão para solicitar materiais de informática.',4,1)
		ENDIF

		IF  lContinua
			//valida para deixar apenas produtos grupo EPI
			IF (alltrim(SB1->B1_GRUPO) == "ES" .AND. cValTipo == '1')

				oModel:SetValue("ZDW_CC",GetMV("TCP_CCUSTO"))
				oModel:SetValue("ZDW_CONTA",GetMV("TCP_CONTA"))
				oModel:SetValue("ZDW_ITEMCT",GetMV("TCP_CONTAI"))

			elseif 	SB1->B1_GRUPO $ cGrpTi .AND. cValTipo == '3'
				oModel:SetValue("ZDW_CC",GetMV("TCP_CCTI"))
				oModel:SetValue("ZDW_ITEMCT",GetMV("TCP_CTDTI"))
			elseIF  cValTipo == '3' .AND. alltrim(SB1->B1_GRUPO) != "ES" .AND. !(SB1->B1_GRUPO $ cGrpTi)
				//lContinua := .F.
				//Help("",1,"TCPGRUPOES",,'Apenas produto com Grupo "ES" podem ser utilizados.',4,1)
				IF empty(cCentro)
					lContinua := .F.
					Help("",1,"CENTROCUSTO",,'Preencha o Centro de Custo.',4,1)
				else
					IF CTT->( dbSeek( xFilial("CTT") + alltrim(cCentro) ) )

						IF(CTT->CTT_BLOQ   == '1')
							lContinua := .F.
							Help("",1,"CENTROCUSTOBL",,'Centro de Custo encontra-se bloqueado para uso.',4,1)
						ENDIF
					ELSE
						lContinua := .F.
						Help("",1,"CENTROCUSTOBL",,'Centro de Custo inválido.',4,1)
					ENDIF
				endif

				IF !empty(cConta)

					IF  CT1->( dbSeek( xFilial("CT1") + alltrim(cConta) ) )

						IF(CT1->CT1_BLOQ  == '1')
							lContinua := .F.
							Help("",1,"CONTABLOQ",,'Conta Contábil encontra-se bloqueado para uso.',4,1)
						ENDIF
					ELSE
						lContinua := .F.
						Help("",1,"CONTABLOQ2",,'Conta Contábil inválido.',4,1)
					ENDIF
				endif

				IF empty(cItem)
					lContinua := .F.
					Help("",1,"ITEMCONTA",,'Preencha o Item Contábil.',4,1)
				Else
					IF  CTD->( dbSeek( xFilial("CTD") + alltrim(cItem) ) )

						IF(CTD->CTD_BLOQ == '1')
							lContinua := .F.
							Help("",1,"ITEMBLOQ",,'Item Conta encontra-se bloqueado para uso.',4,1)
						ENDIF
					ELSE
						lContinua := .F.
						Help("",1,"ITEMBLOQ2",,'Item Conta inválido.',4,1)
					ENDIF
				endif

			ELSE


			EndIF
		ENDIF

		SB2->( dbSetOrder(1) )
		SB2->( dbSeek( xFilial("SB2") + cProduto + cArmazem ) )

		//busca o saldo
		nQtdEst := SaldoSB2()

		IF QtdComp(nQtdEst) < QtdComp(nQtdTotal) .And. oModel:GetOperation() == MODEL_OPERATION_INSERT
			lContinua := .F.
			Help("",1,"TCPSEMSALDO",,"Não existe quantidade suficiente em estoque para atender esta requisição.",4,1)
		EndIF
	EndIF

return lContinua



/*/{Protheus.doc} ViewDef
Definição da VIEW

@author Rafael Ricardo Vieceli
@since 29/12/2017
@version 1.0
@return object, view

@type function
/*/
static function ViewDef()

	Local oView
	Local oModel := ModelDef()

	Local oStructCab  := FWFormStruct(2,'ZDW', {|campo| alltrim(campo) $ 'ZDW_FILIAL#ZDW_NUMERO#ZDW_OBSERV#ZDW_DATA#ZDW_OP#ZDW_REQUIS#ZDW_TIPO' } )
	Local oStructItens := FWFormStruct(2,'ZDW' )

	oStructItens:RemoveField( 'ZDW_FILIAL' )
	oStructItens:RemoveField( 'ZDW_NUMERO' )
	oStructItens:RemoveField( 'ZDW_OBSERV' )
	oStructItens:RemoveField( 'ZDW_DATA' )
	oStructItens:RemoveField( 'ZDW_OP' )
	oStructItens:RemoveField( 'ZDW_REQUIS' )
	oStructItens:RemoveField( 'ZDW_TIPO' )
	oStructItens:RemoveField( 'ZDW_CONTA' )
	oStructItens:RemoveField( 'ZDW_DCONTA' )

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('VIEW_CAB'    , oStructCab   ,'ZDW_CAB' )
	oView:AddGrid ('VIEW_ITENS'  , oStructItens ,'ZDW_ITENS')

	oView:CreateHorizontalBox( 'BOX_CAB'  , 20)
	oView:CreateHorizontalBox( 'BOX_ITENS', 80)

	oView:SetOwnerView('VIEW_CAB'   ,'BOX_CAB')
	oView:SetOwnerView('VIEW_ITENS' ,'BOX_ITENS')

	oView:EnableTitleView('VIEW_ITENS'  , 'Itens da Requisição')

Return oView



/*/{Protheus.doc} CriaOP
Função para criação da ordem de produto via execAuto

@author Rafael Ricardo Vieceli
@since 29/12/2017
@version 1.0
@return lógic, se criou a OP
@param oModel, object, Modelo o cabeçalho
@type function
/*/
static function CriaOP(oModel)

	Local aMata650    := {}

	Local oModelAtv   := FWModelActive()

//variaveis para o ExecAuto
	Private lMsErroAuto := .F.

	SB1->( dbSetOrder(1) )
	IF oModel:GetValue("ZDW_TIPO") == '2'
		SB1->( dbSeek( xFilial("SB1") + GetMV("TCP_PRDMAT") ) )
	ElseIF oModel:GetValue("ZDW_TIPO") =='1'
		SB1->( dbSeek( xFilial("SB1") + GetMV("TCP_PRDEPI") ) )
	ELSE
		SB1->( dbSeek( xFilial("SB1") + GetMV("TCP_PRDINF") ) )
	ENDIF

	aAdd( aMata650, {'C2_PRODUTO', SB1->B1_COD    , nil })
	aAdd( aMata650, {'C2_LOCAL'  , SB1->B1_LOCPAD , nil })
	aAdd( aMata650, {'C2_QUANT'  , 1              , nil })
	aAdd( aMata650, {'C2_EMISSAO', dDataBase      , nil })
	aAdd( aMata650, {'C2_DATPRI' , oModel:GetValue("ZDW_DATA"), nil })
	aAdd( aMata650, {'C2_DATPRF' , oModel:GetValue("ZDW_DATA"), nil })
	aAdd( aMata650, {'AUTEXPLODE', 'S' , Nil })

	aAdd( aMata650, {'C2_ITEMCTA',oModelAtv:GetValue("ZDW_ITENS","ZDW_ITEMCT"), nil })
	aAdd( aMata650, {'C2_CC'	 ,oModelAtv:GetValue("ZDW_ITENS","ZDW_CC") , nil })
	aAdd( aMata650, {'C2_XCONTA' ,oModelAtv:GetValue("ZDW_ITENS","ZDW_CONTA") , nil })

	cEnderecoFail := ''

	dbSelectArea("SC2")
	msExecAuto({|x,Y| Mata650(x,Y)}, aMata650, 3)

//se ouve erro na rotina automatica
	IF lMsErroAuto 
		If !IsBlind()
			MostraErro()
		Else
			cErro := MostraErro("/dirdoc", "error.log")
			//conout(cErro)
		EndIf
		//se ouve erro no saldo
	ElseIF ! Empty(cEnderecoFail)
		DisarmTransaction()
		If !IsBlind()
			Aviso('Sem Saldo',cEnderecoFail,{'Sair'},3)
		EndIf
	Else
		//salva a op
		ZDW->ZDW_OP := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)
	EndIF

retur( !lMsErroAuto .And. empty(cEnderecoFail) )


/*/{Protheus.doc} ExcluiOP
Função para excluir a ordem de produção

@author Rafael Ricardo Vieceli
@since 29/12/2017
@version 1.0
@return lógic, se excluiu a OP
@param oModel, object, modelo do cabeçalho
@type function
/*/
static function ExcluiOP(oModel)

	Local aMata650 := {}

//variaveis para o ExecAuto
	Private lMsErroAuto := .F.

	SC2->( dbSetOrder(1) )
	SC2->( dbSeek( xFilial("SC2") + oModel:GetValue("ZDW_OP") ) )

	IF SC2->( Found() )

		aAdd(aMata650,{"C2_NUM"	  , SC2->C2_NUM	  , Nil})
		aAdd(aMata650,{"C2_ITEM"  , SC2->C2_ITEM  , Nil})
		aAdd(aMata650,{"C2_SEQUEN", SC2->C2_SEQUEN, Nil})

		dbSelectArea("SC2")
		msExecAuto({|x,Y| Mata650(x,Y)},aMata650,5)

		IF lMsErroAuto
			MostraErro()
		EndIF

	EndIF

return ! lMsErroAuto




/*/{Protheus.doc} EMP650
Ponto de entrada para alterar os empenhos

@author Rafael Ricardo Vieceli
@since 29/12/2017
@version 1.0

@type function
/*/
user function EMP650()

//CONOUT((ALLTRIM(FunName())))

//só executa na rotina de EPI
	if Alltrim(FunName()) == "AEST055" .OR. Alltrim(FunName()) == 'MDTA695' .OR. ALLTRIM(FunName()) == "RPC"

		if (ALLTRIM(FunName()) == "RPC" ) .And. Type('aLotesEmp') <> "U"
			aLotesTot := aLotesEmp
		endif

		if Alltrim(FunName()) == 'MDTA695' .Or. ( ALLTRIM(FunName()) == "RPC" .AND. Type("aLotesTot") == 'U' .And. FwIsInCallStack("U_TCMD03KM") )
			//Conout("EMP650--> ")
			IF Type("aLotesTot") == 'U'
				aLotesTot := {}
				cQuery := " SELECT * "
				cQuery += " FROM " + RetSqlName("ZDW") + " ZDW "
				cQuery += " WHERE ZDW_FILIAL = '" + xFilial('ZDW') + "'"
				cQuery += "   AND ZDW_NUMERO = '" + ZDW->ZDW_NUMERO + "'"
				cQuery += "   AND D_E_L_E_T_ <> '*' "

				If Select("QRY") > 0
					QRY->(dbCloseArea())
				EndIf

				TCQUERY cQuery New Alias ("QRY")

				While QRY->(!Eof())
					//conout('4444')
					aAdd( aLotesTot, { ;
						QRY->ZDW_EPI,;
						QRY->ZDW_QTDE,;
						ConvUM(QRY->ZDW_EPI,QRY->ZDW_QTDE,0,2),;
						QRY->ZDW_LOCAL,;
						NIL,0})
					QRY->(dbSkip())
				EndDo
			ENDIF
		endif

		preencheEmpenhos()
	EndIF

return




/*/{Protheus.doc} preencheEmpenhos
Função para preencher os empenhos

@author Rafael Ricardo Vieceli
@since 29/12/2017
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
static function preencheEmpenhos()

	Local n1, n2
	Local aRetorno := {}
	Local nQtyStok := 0
	Local nSldSBF  := 0

	Local nQuantItem
	Local nQtd2UM
	Local nAux := 1
	Local _ExistPos := Type("nPosOper") == "N"
	Pergunte("MTA650",.F.)

	IF Type("cEnderecoFail") == "U"
//	STATIC cEnderecoFail := ''
	ENDIF

	For n1 := 1 to len(aLotesTot)

		//Verifica o Saldo Disponivel no SB2 antes de verificar o Saldo dos Lotes
		nQtyStok := 0
		aRetorno := {}

		SB1->( dbSetOrder(1) )
		SB1->( MsSeek( xFilial("SB1") + aLotesTot[n1][1] ) )
		SB2->( dbSetOrder(1) )
		SB2->( MsSeek( xFilial("SB2") + aLotesTot[n1][1] + aLotesTot[n1][4] ) )

		IF SB2->( Found() )
			nQtyStok += SaldoSB2() //.T.,,,(mv_par15!=1),(aSav650[14]==1),,,) + SB2->B2_SALPEDI-SB2->B2_QEMPN+AvalQtdPre("SB2",2)
		EndIF

		//se tiver saldo
		IF QtdComp(nQtyStok) > QtdComp(0)

			aRetorno := SldPorLote(;
				aLotesTot[n1][1], ; //cCodPro
			aLotesTot[n1][4], ; //cLocal
			aLotesTot[n1][2], ; //nQtd
			aLotesTot[n1][3], ; //nQtd2UM
			NIL,; //cLoteCtl
			NIL,; //cNumLote
			NIL,; //cLocaliza
			NIL,; //cNumSer
			NIL,; //aTravas
			.T.,; //lBaixaEmp
			NIL,; //cLocalAte
			NIL,; //lConsVenc
			NIL,; //aLotesFil
			NIL,; //lEmpPrevistox
			dDataBase) //dDataRef

			For n2 := 1 To Len(aRetorno)
				//³ Verifica se o endereco possui quantidade suficiente para atender o empenho.
				nSldSBF := SaldoSBF(aLotesTot[n1][4], aRetorno[n2][3], aLotesTot[n1][1])

				aRetorno[n2][5] := Min(aRetorno[n2][5],If(QtdComp(nQtyStok)<QtdComp(0),0,IIf(nSldSBF < nQtyStok, nQtyStok, nSldSBF)))
				aRetorno[n2][6] := ConvUM(aLotesTot[n1][1],aRetorno[n2][5],0,2)
				nQtyStok -= aRetorno[n2][5]

			Next n2

		EndIF

		aLotesTot[n1][5] := aClone(aRetorno)

		nQuantItem := aLotesTot[n1][2]
		nQtd2UM	   := aLotesTot[n1][3]


		SB1->( dbSetOrder(1) )
		SB1->( dbSeek( xFilial("SB1") + aLotesTot[n1][1] ) )

		IF QtdComp(aLotesTot[n1][2],.T.) <= QtdComp(0)
			cTRT := Space(Len(SD4->D4_TRT)-Len(Alltrim(Str(nAux))))+Alltrim(Str(nAux))

			aAdd(aCols,ARRAY(Len(aHeader)+1))

			aCols[Len(aCols)][nPosCod    ] := aLotesTot[n1][1]
			aCols[Len(aCols)][nPosQuant  ] := aLotesTot[n1][2]
			aCols[Len(aCols)][nPosLocal  ] := aLotesTot[n1][4]
			aCols[Len(aCols)][nPosTRT    ] := cTRT //CriaVar("G1_TRT")
			aCols[Len(aCols)][nPosLote   ] := CriaVar("D4_NUMLOTE")
			aCols[Len(aCols)][nPosLotCtl ] := CriaVar("D4_LOTECTL")
			aCols[Len(aCols)][nPosdValid ] := CriaVar("D4_DTVALID")
			aCols[Len(aCols)][nPosPotenc ] := CriaVar("D4_POTENCI")
			aCols[Len(aCols)][nPosLocLz  ] := CriaVar("DC_LOCALIZ")
			aCols[Len(aCols)][nPosnSerie ] := CriaVar("DC_NUMSERI")
			aCols[Len(aCols)][nPosUM     ] := SB1->B1_UM
			aCols[Len(aCols)][nPosQtSegum] := aLotesTot[n1][3]
			aCols[Len(aCols)][nPos2UM    ] := SB1->B1_SEGUM
			aCols[Len(aCols)][nPosDescr  ] := SB1->B1_DESC
			IF _ExistPos  .And. nPosOper > 0
				aCols[Len(aCols),nPosOper] := Criavar("D4_OPERAC",.f.)
			EndIF
			aCols[Len(aCols),Len(aHeader)+1]:= .F.

		Else

			// Verifica se usa Rastro ou Localizacao Fisica
			// e se deve sugerir os lotes e localizacoes do empenho
			IF (Rastro(aLotesTot[n1][1]) .Or. Localiza(aLotesTot[n1][1]))

				For n2:=1 to Len(aRetorno)

					IF QtdComp(aRetorno[n2][5]) > QtdComp(0)
						cTRT := Space(Len(SD4->D4_TRT)-Len(Alltrim(Str(nAux))))+Alltrim(Str(nAux))

						aAdd(aCols,ARRAY(Len(aHeader)+1))

						aCols[Len(aCols)][nPosCod   ] := aLotesTot[n1][1]
						aCols[Len(aCols),nPosQuant  ] := Min(aRetorno[n2][5],nQuantItem)
						aCols[Len(aCols),nPosQtSegum] := Min(aRetorno[n2][6],nQtd2UM)
						aCols[Len(aCols),nPosLocal  ] := aRetorno[n2][11]
						aCols[Len(aCols)][nPosTRT   ] := cTRT //CriaVar("G1_TRT")
						aCols[Len(aCols),nPosLote   ] := aRetorno[n2][2]
						aCols[Len(aCols),nPosLotCtl ] := aRetorno[n2][1]
						aCols[Len(aCols),nPosdValid ] := aRetorno[n2][7]
						aCols[Len(aCols),nPosPotenc ] := aRetorno[n2][12]
						aCols[Len(aCols),nPosLocLz  ] := aRetorno[n2][3]
						aCols[Len(aCols),nPosnSerie ] := aRetorno[n2][4]
						aCols[Len(aCols),nPosUM     ] := SB1->B1_UM
						aCols[Len(aCols),nPos2UM    ] := SB1->B1_SEGUM
						aCols[Len(aCols),nPosDescr  ] := SB1->B1_DESC
						IF _ExistPos .And. nPosOper > 0
							aCols[Len(aCols),nPosOper] := Criavar("D4_OPERAC",.f.)
						EndIF
						aCols[Len(aCols),Len(aHeader)+1]:= .F.

						nQuantItem -= aCols[Len(aCols),nPosQuant]
						nQtd2UM    -= aCols[Len(aCols),nPosQtSegum]
						aRetorno[n2][5] -= aCols[Len(aCols),nPosQuant]
						aRetorno[n2][6] -= aCols[Len(aCols),nPosQtSegum]
						aLotesTot[n1][5] := aClone(aRetorno)

					EndIf
					IF QtdComp(nQuantItem,.t.) <= QtdComp(0,.t.)
						Exit
					EndIF
				Next n2

				IF nQuantItem > 0
					cEnderecoFail +=  "O produto " +alltrim(aLotesTot[n1][1])+ " não possui saldo endereçado."
				EndIF

			Else
				cTRT := Space(Len(SD4->D4_TRT)-Len(Alltrim(Str(nAux))))+Alltrim(Str(nAux))
				aAdd(aCols,ARRAY(Len(aHeader)+1))
				aCols[Len(aCols)][nPosCod   ] := aLotesTot[n1][1]
				aCols[Len(aCols)][nPosQuant ] := aLotesTot[n1][2]
				aCols[Len(aCols)][nPosLocal ] := aLotesTot[n1][4]
				aCols[Len(aCols)][nPosTRT   ] := cTRT //CriaVar("G1_TRT")
				aCols[Len(aCols),nPosLote   ] := CriaVar("D4_NUMLOTE")
				aCols[Len(aCols),nPosLotCtl ] := CriaVar("D4_LOTECTL")
				aCols[Len(aCols),nPosdValid ] := CriaVar("D4_DTVALID")
				aCols[Len(aCols),nPosPotenc ] := CriaVar("D4_POTENCI")
				aCols[Len(aCols),nPosLocLz  ] := CriaVar("DC_LOCALIZ")
				aCols[Len(aCols),nPosnSerie ] := CriaVar("DC_NUMSERI")
				aCols[Len(aCols),nPosUM     ] := SB1->B1_UM
				aCols[Len(aCols),nPosQtSegum] := aLotesTot[n1][3]
				aCols[Len(aCols),nPos2UM    ] := SB1->B1_SEGUM
				aCols[Len(aCols),nPosDescr  ] := SB1->B1_DESC
				IF _ExistPos .And. nPosOper > 0
					aCols[Len(aCols),nPosOper] := Criavar("D4_OPERAC",.f.)
				EndIF
				aCols[Len(aCols),Len(aHeader)+1]:= .F.

			EndIF
		EndIF
		nAux ++
	Next n1

	IF LEN(aCols) <  LEN(aLotesTot)
		cEnderecoFail +=  "Produto controla endereço, porém não possui saldo em nenhum endereço."
	ELSE

		For n1 := 1 to len(aCols)
			//se controla endereço e não for preeenchido retorna erro
			IF Localiza(aCols[n1][nPosCod]) .and. empty(aCols[n1][nPosLocLz])
				cEnderecoFail +=  "O produto " +alltrim(aLotesTot[n1][1])+ " não possui saldo suficiente endereçado."
			EndIF

		Next n1
	ENDIF
return


/*/{Protheus.doc} valParams
Valida se os parametro foram informados

@author Rafael Ricardo Vieceli
@since 29/12/2017
@version 1.0

@type function
/*/
static function valParams()

	IF empty(GetMV("TCP_PRDEPI",,""))
		Aviso("PARAMETRO", "O parametro TCP_PRDEPI não foi informado, deve ser preenchido com o produto para apontamento de EPI, assim como o produto Manutenção para OS.", {"Sair"}, 2)
		return .F.
	EndIF

	IF empty(GetMV("TCP_PRDMAT",,""))
		Aviso("PARAMETRO", "O parametro TCP_PRDMAT não foi informado, deve ser preenchido com o produto para apontamento de Material, assim como o produto Manutenção para OS.", {"Sair"}, 2)
		return .F.
	EndIF

	IF empty(GetMV("TCP_PRDINF",,""))
		Aviso("PARAMETRO", "O parametro TCP_PRDINF não foi informado, deve ser preenchido com o produto para apontamento de Informatica, assim como o produto Informatica para OS.", {"Sair"}, 2)
		return .F.
	EndIF

	SB1->( dbSetOrder(1) )
	IF !SB1->( dbSeek( xFilial("SB1") + GetMV("TCP_PRDINF") ) )
		Aviso("PARAMETRO", "O produto TCP_PRDINF não foi cadsatrado, deve ser preenchido com o produto para apontamento de Informatica, assim como o produto Informatica para OS.", {"Sair"}, 2)
		return .F.
	ENDIF
	IF !SB1->( dbSeek( xFilial("SB1") + GetMV("TCP_PRDMAT") ) )
		Aviso("PARAMETRO", "O parametro TCP_PRDMAT não foi informado, deve ser preenchido com o produto para apontamento de Informatica, assim como o produto Informatica para OS.", {"Sair"}, 2)
		return .F.
	ENDIF
	IF !SB1->( dbSeek( xFilial("SB1") + GetMV("TCP_PRDEPI") ) )
		Aviso("PARAMETRO", "O parametro TCP_PRDEPI não foi informado, deve ser preenchido com o produto para apontamento de Informatica, assim como o produto Informatica para OS.", {"Sair"}, 2)
		return .F.
	ENDIF

	IF empty(GetMV("TCP_TPPRD",,""))
		Aviso("PARAMETRO", "O parametro TCP_TPPRD não foi informado, deve ser preenchido com o Tipo de Movimentação para apontamento de produção para o produto EPI.", {"Sair"}, 2)
		return .F.
	EndIF

	IF empty(GetMV("TCP_TPREQ",,""))
		Aviso("PARAMETRO", "O parametro TCP_TPREQ não foi informado, deve ser preenchido com o Tipo de Movimentação para requisição do produto EPI para zerar o apontamento.", {"Sair"}, 2)
		return .F.
	EndIF

	IF empty(GetMV("TCP_CONTA",,""))
		Aviso("PARAMETRO", "O parametro TCP_CONTA não foi informado, deve ser preenchido com a Conta Contabil para apontamento do Produto EPI.", {"Sair"}, 2)
		return .F.
	EndIF

	IF empty(GetMV("TCP_CONTAI",,""))
		Aviso("PARAMETRO", "O parametro TCP_CONTAI não foi informado, deve ser preenchido com o Item Contabil para apontamento do Produto EPI.", {"Sair"}, 2)
		return .F.
	EndIF

return .T.


Static Function nStat
	local lfound := .t.
	SC2->( dbSetOrder(1) )
	SC2->( dbSeek( xFilial("SC2",ZDW->ZDW_FILIAL) + ZDW->ZDW_OP ) )
	CB7->( dbSetOrder(5) )
	lfound := CB7->( dbSeek( xFilial("CB7",ZDW->ZDW_FILIAL) + ZDW->ZDW_OP ) )

	IF empty(ZDW->ZDW_OP)
		return 1
	EndIf
	if Empty(SC2->C2_DATRF) .and. !lfound
		return 2
	endif

//op com ordem de separação

//ordem de produção
	if Empty(SC2->C2_DATRF)  .and. lFound
		return 3
	endif

//op finalizada

//ordem de produção
	if !Empty(SC2->C2_DATRF)
		return 4
	endif

return 3

Static Function valMdt()
	local lMdt := .F.

	cAliaAux2 := getNextAlias()

	BeginSQL Alias cAliaAux2
	SELECT TNF_YNUMRE
	FROM %TABLE:TNF% TNF
	WHERE TNF.%NotDel%  AND TNF_YNUMRE = %EXP:ZDW->ZDW_NUMERO%

	EndSQL

	IF !(cAliaAux2)->(Eof())
		lMdt := .T.
	ENDIF

	(cAliaAux2)->(dbCloseArea())

return lMdt

Class AE055COMMIT FROM FWModelEvent
	Method New() CONSTRUCTOR
	Method InTTS()
End Class

Method New() Class AE055COMMIT
Return

Method InTTS(oModel,cModelId) Class AE055COMMIT

	Local lGravou := .F.
	Local oItems  := oModel:GetModel("ZDW_ITENS")
	Local nItem

	Local lObrEpiMdt:= GetMv("TCP_EPOBMD")

	Begin Transaction

		aLotesTot := {}

		For nItem := 1 to oItems:Length()
			//posiciona na linha
			oItems:GoLine( nItem )
			//se não estiver deletado
			IF ! oItems:IsDeleted()

				//itens para empenho
				aAdd( aLotesTot, { ;
					oItems:GetValue("ZDW_EPI"),;
					oItems:GetValue("ZDW_QTDE"),;
					ConvUM(oItems:GetValue("ZDW_EPI"),oItems:GetValue("ZDW_QTDE"),0,2),;
					oItems:GetValue("ZDW_LOCAL"),;
					NIL,0})

			EndIF
		Next nItem

		IF oModel:GetOperation() == MODEL_OPERATION_INSERT
			//cria a ordem de produto
			//os empenhos também serão criado, através do PE EMP650
			lGravou :=  CriaOP(oModel:GetModel("ZDW_CAB"))
		ElseIF oModel:GetOperation() == MODEL_OPERATION_DELETE
			//exclui a OP
			nstat := nStat()
			lMdt := valMdt()
			IF(lObrEpiMdt .AND. lMdt .And. !FwIsInCallStack("U_TCMD03KM") )
				lGravou := .F.
				Help("",1,"TCPEXCORD",,"Exclusão de material EPI somente pelo módulo de medicina e segurança.",4,1)
			elseif nstat > 2
				lGravou := .F.
				Help("",1,"TCPEXCORD",,"Não é possivel excluir solicitação que contenha Ordem de separação.",4,1)
			else
				lGravou :=  ExcluiOP(oModel:GetModel("ZDW_CAB"))
			endIf
		EndIF

		//se não gravou algo
		IF !lGravou
			//disarma a transação
			DisarmTransaction()
		EndIF

	End Transaction
	
Return

/*/{Protheus.doc} A055EXCLOT
Realiza a exclusão das requisições de materiais em lote.
@type user function
@version 
@author Kaique Mathias
@since 6/13/2020
@return Nil, Nil
/*/

user function A055EXCLOT()

	DEFINE MSDIALOG oDlg FROM  96,9 TO 320,612 TITLE OemToAnsi("Exclusão de Req. Materiais em Lote") PIXEL	//"Rec lculo do Custo M‚dio"
	@ 11,6 TO 90,287 LABEL "" OF oDlg  PIXEL
	@ 16, 15 SAY OemToAnsi("Este programa permite que seja excluido as requisições de materiais indevidas que sejam oriundos do Medicina" ) SIZE 268, 8 OF oDlg PIXEL					//"Este programa permite que o custo m‚dio seja recalculado de trˆs formas diferentes, atendendo"
	@ 26, 15 SAY OemToAnsi("e segurança do trabalho e que não estejam em processo de separação.") SIZE 268, 8 OF oDlg PIXEL					
	
	DEFINE SBUTTON FROM 93, 223 TYPE 1  ACTION (Processa({|lEnd| fDelete() },OemToAnsi("Excluindo Requisições de Materiais..."),OemToAnsi("Aguarde..."),.F.),oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 93, 253 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED

Return( Nil )

/*/{Protheus.doc} fDelete
Realiza a exclusão das requisições de materiais em lote.
@type user function
@version 
@author Kaique Mathias
@since 6/13/2020
@return Nil, Nil
/*/

Static Function fDelete()

	Local cQuery := ""

	cQuery := "SELECT ZDW.R_E_C_N_O_ XRECNO "
	cQuery += "FROM " + RetSqlName("ZDW") + " ZDW "
	cQuery += "LEFT JOIN " + RetSqlName("TNF") + " TNF ON TNF.TNF_FILIAL=ZDW.ZDW_FILIAL AND TNF.TNF_YNUMRE=ZDW.ZDW_NUMERO AND TNF.TNF_CODEPI=ZDW.ZDW_EPI AND TNF.TNF_MAT=ZDW.ZDW_REQUIS AND TNF.D_E_L_E_T_='' "
	cQuery += "LEFT JOIN " + RetSqlName("CB7") + " CB7 ON CB7.CB7_FILIAL=ZDW.ZDW_FILIAL AND CB7.CB7_OP=ZDW.ZDW_OP AND CB7.D_E_L_E_T_='' "
	cQuery += "INNER JOIN " + RetSqlName("SC2") + " SC2 ON SC2.C2_FILIAL=ZDW.ZDW_FILIAL AND SC2.C2_NUM=SUBSTRING(ZDW.ZDW_OP,1,6) AND SC2.C2_DATRF='' AND SC2.D_E_L_E_T_='' "
	cQuery += "WHERE  TNF_YNUMRE IS NULL AND "
	cQuery += "		  CB7.CB7_OP IS NULL AND "	
	cQuery += "		  ZDW_CONTA = '' AND "
	cQuery += "		  ZDW_TIPO='1' AND "
	cQuery += "		  ZDW.D_E_L_E_T_='' "

	If SELECT("TMPZDW") > 0
		TMPZDW->(dbCloseArea())
	EndIf
	
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TMPZDW",.T.,.F.)	
	
	DbSelectArea('TMPZDW')
	TMPZDW->( dbGotop() )
	Begin Transaction
	If !TMPZDW->( Eof() )
		While !( TMPZDW->( Eof() ) )
			dbSelectArea("ZDW")
			ZDW->( dbGoto(TMPZDW->XRECNO) )
			oModel := FWLoadModel('AEST055')
			oModel:SetOperation(5)
			oModel:Activate()
			If( oModel:VldData() )
				oModel:CommitData()
				AutoGrLog("Requisição Material: " + ZDW->ZDW_NUMERO + " | Status: Excluido com sucesso" )
			else
				AutoGrLog("Requisição Material: " + ZDW->ZDW_NUMERO + " | Status: Erro ao excluir" )
			EndIf
			TMPZDW->( dbSkip() )
		EndDo
		If( MsgYesNo('Processamento finalizado. Deseja visualizar o LOG ?') )
			MostraErro()
		EndIf
	EndIf
	End Transaction

Return( Nil )
