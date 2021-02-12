#include 'protheus.ch'
#include 'parmtype.ch'
#Include "FwMvcDef.ch"
#Include "topconn.ch"
//==================================================================================================//
//	Programa: KP97B03		|	Autor: Luis Paulo							|	Data: 19/08/2018	//
//==================================================================================================//
//	Descrição: FWMarkBrowse onde será marcado os pv que vão para supplier							//
//																									//
//==================================================================================================//
User Function KP97B03()
Local	cAlias		:= "SC5"
Local 	oMark
Local	bAfterMark	:=	{|| oMarK:CanMark(oMark:Mark(),MarcaId(oMark))}
Local	bMarkAll	:=  {||  AllMark(oMark)}
Local 	cMark
Local 	cData		:= ((Date())-365)		
//Private cFilBrwK		:= "C5_PREFIXO == '1  ' .AND. C5_TIPO == 'NF ' .AND. C5_SALDO == 0" //NOTAS BAIXADASC
Private cFilBrwK		:= "DTOS(C5_EMISSAO) >= '"+DTOS(cData)+"' .And. ( Empty(C5_NOTA)) .And. (C5_XPVSPC == 'S') .AND. (C5_XSTSSPP == ' ')" //NOTAS BAIXADASC
Private  cCRLF		:= CRLF

//Validar os ultimos 12meses(360)
If cEmpAnt <> '04' 
	MsgInfo("Esta rotina funciona apenas para informações da empresa 04 (Industria)","KAPAZI - Pedidos de Vendas SUPPLIER CARD")
	Return
EndIf

DbSelectArea("SC5")
DbSetOrder(3)

//Instância a classe
oMark := FWMarkBrowse():New()
oMark:SetAlias(cAlias)
oMark:SetFilterDefault(cFilBrwK)
oMark:SetFieldMark('C5_FLAGSP2') //Trocar para C5_FLAGSP2
oMark:SetDescription('CR - Pedidos de Vendas Supplier')
oMark:SetAfterMark(bAfterMark)
oMark:SetAllMark(bMarkAll)
oMark:SetAmbiente(.F.)
oMark:SetWalkThru(.F.)
oMark:DisableDetails()
oMark:SetMark(oMark:Mark(),cAlias,"C5_FLAGSP2")

///Legendas do Browse
oMark:AddLegend( "Empty(C5_NOTA)"	, "GREEN"	, "Em aberto" )
oMark:AddLegend( "!Empty(C5_NOTA)"	, "BLACK"	, "Gerou NF" )
//oMark:AddLegend( "C5_SALDO == C5_VALOR .And. C5_VALLIQ == 0 .And. C5_STATUS == 'A' "				, "GREEN"	, "Em aberto" )

cMark		:= oMark:Mark()

oMark:Activate()
ClearOk(cMark)
Return()


Static Function MenuDef()
Local aMenu	:=	{}

Add Option aMenu Title 'Visualizar' 		Action 'ViewDef.KP97B03' 				Operation 2 Access 0  //
Add Option aMenu Title 'Integrar'  			Action 'U_KP97A05' 						Operation 4 Access 0
//Add Option aMenu Title 'Pv Posse Supplier' 	Action 'U_KP97A07' 						Operation 4 Access 0

Return aMenu


Static Function ModelDef()
Local 	oModel 				// Modelo de dados que será construído

//Definindo o controller
oModel := MPFormModel():New("KP97B03C",/*Pre-Validacao*/,,/*Commit*/,/*Cancel*/)

//Definindo Estrutura
oStruct := FWFormStruct(1,"SC5",/*Definir se usa o campo(Ret t ou f)*/ )

//Adiciona um modelo de Formulario de Cadastro Similar à Enchoice ou Msmget
oModel:AddFields('Enchoice_SC5', /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//Definindo Chave Primaria do Master. Necessário quando não existe no X2_UNICO
oModel:SetPrimaryKey({ "C5_FILIAL","C5_NUM"}) //C5_FILIAL, C5_PREFIXO, C5_NUM, C5_PARCELA, C5_TIPO, R_E_C_D_E_L_

//Adiciona Descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados PV - Pedidos de Vendas' )

//Adiciona Descricao do Componente do Modelo de Dados
cTexto := 'Formulario PV - Pedidos de Vendas'
oModel:GetModel( 'Enchoice_SC5' ):SetDescription( cTexto )

Return(oModel)

Static Function ViewDef()
Local oStruct
Local oModel
Local oView

oStruct	:=	FWFormStruct(2,"SC5") 	//Retorna a Estrutura do Alias passado
oModel	:=	FwLoadModel('KP97B03')	//Retorna o Objeto do Modelo de Dados- nome do fonte de onde queremos obter o modelo de dados
oView	:=	FwFormView():New()      //Instancia do Objeto de Visualização

//Define o Modelo sobre qual a Visualizacao sera utilizada
oView:SetModel(oModel)

//Vincula o Objeto visual de Cadastro com o modelo
oView:AddField( 'VIEW_SC5', oStruct, 'Enchoice_SC5')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox("TELA",100)

//Colocando título do formulário
oView:EnableTitleView('VIEW_SC5', 'Pedidos de Vendas' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_SC5', 'TELA' )

//Força o fechamento da janela na confirmação
oView:SetCloseOnOk({||.T.})

Return(oView)


Static Function FWMARK1P()
Local aArea	 :=	GetArea()
Local cMarca := oMark:Mark()
Local cTmp	 := GetNextAlias()
Local nQtd	 := 0

BeginSql Alias cTmp
	Select Count(*) QTD
	From %Table:SC5%	SC5
	Where SC5.%NotDel%	And
		  SC5.C5_FLAGSP2	= %Exp:cMarca%
EndSql

MsgInfo('Foram marcados ' + cValToChar((cTmp)->QTD) + ' registro','Marcados')

(cTmp)->(dbCloseArea())

RestArea(aArea)
Return(.T.)

//Marcar todos os registros
Static Function AllMark(oMark)

Processa({||MarcaTD(oMark)} ,"Processando Pedidos de Vendas","Aguarde...") 

Return(.T.)

/*
+--------------------------------------------------------------------------+
! Função    ! ClearOk    ! Autor !                    ! Data ! 30/09/2017  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Limpa o campo C5_FLAGSP2.                                         !
+-----------+--------------------------------------------------------------+
*/
Static Function ClearOK(cMark)
Local cSql := ""

cSql += " UPDATE " + RetSqlName("SC5") "
cSql += " SET C5_FLAGSP2 = ''"
cSql += " WHERE D_E_L_E_T_ <> '*' "
cSql += " AND C5_FLAGSP2 	= '"+cMark+"'"

If TcSqlExec(cSql) < 0
	Help( ,, 'Clear',, 'Não é possível limpar os registros!!!', 1, 0 )
	Conout("Nao limpouuu")
EndIf

Return(.T.)

Static Function MarcaId(oMark)
Local cAlias		:= oMark:Alias()

If (oMark:IsMark())
		RecLock((cAlias),.F.)
		(cAlias)->C5_FLAGSP2  := oMark:Mark()
		(cAlias)->(MsUnLock())
	Else
		RecLock(cAlias,.F.)
		(cAlias)->C5_FLAGSP2 := ""
		(cAlias)->(MsUnLock())
EndIf

Return(.T.)

//Valida se tem mais de um cliente selecionado
Static Function ValMuCli(cMarkKP)
Local cQr 		:= ""
Local cAliasV1	:= GetNextAlias()
Local lRet		:= .T.
Local nRegs		:= 0
Local cCLiente	:= SC5->C5_CLIENTE
Local cLoja		:= SC5->C5_LOJACLI

If Select("cAliasV1")<>0
	DbSelectArea("cAliasV1")
	DbCloseArea()
Endif

cQr += " SELECT DISTINCT C5_CLIENTE+C5_LOJACLI
cQr += " FROM "+ RetSqlName("SC5") +" SC5 " 
cQr += " WHERE SC5.D_E_L_E_T_ = ''
cQr += "	AND	SC5.C5_FLAGSP2 = '"+cMarkKP+"'
cQr += " ORDER BY C5_CLIENTE+C5_LOJACLI

// abre a query
TcQuery cQr new alias "cAliasV1"
Count To nRegs

If nRegs > 1
	lRet		:= .F.
	MsgInfo("Existe mais de um cliente selecionado, favor verificar!!!","KAPAZI - ALT LIMITES SUPPLIER CARD")
EndIf

cAliasV1->(DbCloseArea())
Return(lRet)


Static Function MarcaTD(oMark)
Local cAlias		:= oMark:Alias()
Local aAreaSC5   	:= SC5->(GetArea())
Local cCLiente		:= SC5->C5_CLIENTE
Local cLoja			:= SC5->C5_LOJACLI
Local dData			:= ((Date())-365)

If ValMuCli(oMark:Mark()) //Valida se tem mais de um cliente selecionado
	
	(cAlias)->(DbSeek(xFilial((cAlias))))
	While (cAlias)->(!Eof()) .And. (cAlias)->C5_FILIAL == xFilial(cAlias) 
		//If (cAlias)->C5_TIPO $ 'NF /FT ' .And. (cAlias)->C5_EMISSAO >= dData
			If (!oMark:IsMark())
				RecLock((cAlias),.F.)
				(cAlias)->C5_FLAGSP2  := oMark:Mark()
				(cAlias)->(MsUnLock())
			Else
				RecLock(cAlias,.F.)
				(cAlias)->C5_FLAGSP2  := ""
				(cAlias)->(MsUnLock())
			EndIf
		//EndIf
		
		(cAlias)->(DbSkip())
	EndDo
EndIf


RestArea(aAreaSC5)
oMark:Refresh()
//oMark:GoTop(.T.)
//oMark:SetFilterDefault( cFilBrwK )
Return(.T.)