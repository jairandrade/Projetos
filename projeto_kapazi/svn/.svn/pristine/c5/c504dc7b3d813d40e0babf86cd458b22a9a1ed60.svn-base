#include 'protheus.ch'
#include 'parmtype.ch'
#Include "FwMvcDef.ch"
#Include "topconn.ch"
//==================================================================================================//
//	Programa: KP97B02		|	Autor: Luis Paulo							|	Data: 11/07/2018	//
//==================================================================================================//
//	Descrição: FWMarkBrowse onde será marcado os título que vão para supplier Alt Limites.			//
//																									//
//==================================================================================================//
User Function KP97B02()
Local	cAlias		:= "SE1"
Local 	oMark
Local	bAfterMark	:=	{|| oMarK:CanMark(oMark:Mark(),MarcaId(oMark))}
Local	bMarkAll	:=  {||  AllMark(oMark)}
Local 	cMark
Local 	cData		:= ((Date())-365)		
//Private cFilBrwK		:= "E1_PREFIXO == '1  ' .AND. E1_TIPO == 'NF ' .AND. E1_SALDO == 0" //NOTAS BAIXADASC
Private cFilBrwK		:= "DTOS(E1_EMISSAO) >= '"+DTOS(cData)+"' .And. ( ( ALLTRIM(E1_TIPO) == 'NF'  .And. Empty(E1_XIDVNFK)) .OR. (ALLTRIM(E1_TIPO) == 'FT' .And. !Empty(E1_XIDVNFK)) )  " //NOTAS BAIXADASC
Private  cCRLF		:= CRLF

//Validar os ultimos 12meses(360)
If cEmpAnt <> '04' 
	MsgInfo("Esta rotina funciona apenas para informações da empresa 04 (Industria)","KAPAZI - ALT LIMITES SUPPLIER CARD")
	Return
EndIf

DbSelectArea("SE1")
DbSetOrder(2)


//Instância a classe
oMark := FWMarkBrowse():New()
oMark:SetAlias(cAlias)
oMark:SetFilterDefault(cFilBrwK)
oMark:SetFieldMark('E1_FLAGSP2') //Trocar para E1_FLAGSP2
oMark:SetDescription('CR - Alteracao de Limites Supplier')
oMark:SetAfterMark(bAfterMark)
oMark:SetAllMark(bMarkAll)
oMark:SetAmbiente(.F.)
oMark:SetWalkThru(.F.)
oMark:DisableDetails()
oMark:SetMark(oMark:Mark(),cAlias,"E1_FLAGSP2")

///Legendas do Browse
oMark:AddLegend( "E1_SALDO == 0	.And. E1_STATUS == 'B'"												, "RED"		, "Baixado" )
oMark:AddLegend( "E1_SALDO > 0	.And. E1_VALLIQ != E1_VALOR .And. E1_SALDO != E1_VALOR"				, "BLUE"	, "Baixado Parcialmente" )
oMark:AddLegend( "E1_SALDO == E1_VALOR .And. E1_VALLIQ == 0 .And. E1_STATUS == 'A' "				, "GREEN"	, "Em aberto" )

cMark		:= oMark:Mark()

oMark:Activate()
ClearOk(cMark)
Return()


Static Function MenuDef()
Local aMenu	:=	{}

Add Option aMenu Title 'Visualizar' 		Action 'ViewDef.KP97B02' 				Operation 2 Access 0  //
Add Option aMenu Title 'Integrar'  			Action 'U_KP97A03' 						Operation 4 Access 0

Return aMenu


Static Function ModelDef()
Local 	oModel 				// Modelo de dados que será construído

//Definindo o controller
oModel := MPFormModel():New("KP97B02C",/*Pre-Validacao*/,,/*Commit*/,/*Cancel*/)

//Definindo Estrutura
oStruct := FWFormStruct(1,"SE1",/*Definir se usa o campo(Ret t ou f)*/ )

//Adiciona um modelo de Formulario de Cadastro Similar à Enchoice ou Msmget
oModel:AddFields('Enchoice_SE1', /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//Definindo Chave Primaria do Master. Necessário quando não existe no X2_UNICO
oModel:SetPrimaryKey({ "E1_FILIAL","E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO" }) //E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_D_E_L_

//Adiciona Descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados CR - Alteracao de Limites' )

//Adiciona Descricao do Componente do Modelo de Dados
cTexto := 'Formulario CR - Alteracao de Limites'
oModel:GetModel( 'Enchoice_SE1' ):SetDescription( cTexto )

Return(oModel)

Static Function ViewDef()
Local oStruct
Local oModel
Local oView

oStruct	:=	FWFormStruct(2,"SE1") 	//Retorna a Estrutura do Alias passado
oModel	:=	FwLoadModel('KP97B02')	//Retorna o Objeto do Modelo de Dados- nome do fonte de onde queremos obter o modelo de dados
oView	:=	FwFormView():New()      //Instancia do Objeto de Visualização

//Define o Modelo sobre qual a Visualizacao sera utilizada
oView:SetModel(oModel)

//Vincula o Objeto visual de Cadastro com o modelo
oView:AddField( 'VIEW_SE1', oStruct, 'Enchoice_SE1')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox("TELA",100)

//Colocando título do formulário
oView:EnableTitleView('VIEW_SE1', 'CR - Alteracao de Limites' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_SE1', 'TELA' )

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
	From %Table:SE1%	SE1
	Where SE1.%NotDel%	And
		  SE1.E1_FLAGSP2	= %Exp:cMarca%
EndSql

MsgInfo('Foram marcados ' + cValToChar((cTmp)->QTD) + ' registro','Marcados')

(cTmp)->(dbCloseArea())

RestArea(aArea)
Return(.T.)

//Marcar todos os registros
Static Function AllMark(oMark)

Processa({||MarcaTD(oMark)} ,"Processando Titulos","Aguarde...") 

Return(.T.)

/*
+--------------------------------------------------------------------------+
! Função    ! ClearOk    ! Autor !                    ! Data ! 30/09/2017  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Limpa o campo E1_FLAGSP2.                                         !
+-----------+--------------------------------------------------------------+
*/
Static Function ClearOK(cMark)
Local cSql := ""

cSql += " UPDATE " + RetSqlName("SE1") "
cSql += " SET E1_FLAGSP2 = ''"
cSql += " WHERE D_E_L_E_T_ <> '*' "
cSql += " AND E1_FLAGSP2 	= '"+cMark+"'"

If TcSqlExec(cSql) < 0
	Help( ,, 'Clear',, 'Não é possível limpar os registros!!!', 1, 0 )
	Conout("Nao limpouuu")
EndIf

Return(.T.)

Static Function MarcaId(oMark)
Local cAlias		:= oMark:Alias()

If (oMark:IsMark())
		RecLock((cAlias),.F.)
		(cAlias)->E1_FLAGSP2  := oMark:Mark()
		(cAlias)->(MsUnLock())
	Else
		RecLock(cAlias,.F.)
		(cAlias)->E1_FLAGSP2 := ""
		(cAlias)->(MsUnLock())
EndIf

Return(.T.)

//Valida se tem mais de um cliente selecionado
Static Function ValMuCli(cMarkKP)
Local cQr 		:= ""
Local cAliasV1	:= GetNextAlias()
Local lRet		:= .T.
Local nRegs		:= 0
Local cCLiente	:= SE1->E1_CLIENTE
Local cLoja		:= SE1->E1_LOJA

If Select("cAliasV1")<>0
	DbSelectArea("cAliasV1")
	DbCloseArea()
Endif

cQr += " SELECT DISTINCT E1_CLIENTE+E1_LOJA
cQr += " FROM "+ RetSqlName("SE1") +" SE1 " 
cQr += " WHERE SE1.D_E_L_E_T_ = ''
cQr += "	AND	SE1.E1_FLAGSP2 = '"+cMarkKP+"'
cQr += " ORDER BY E1_CLIENTE+E1_LOJA

// abre a query
TcQuery cQr new alias "cAliasV1"
Count To nRegs

If nRegs > 1
	lRet		:= .F.
	MsgInfo("Existe mais de um cliente selecionado, favor verificar!!!","KAPAZI - ALT LIMITES SUPPLIER CARD")
	ClearOk(cMarkKP)
EndIf

cAliasV1->(DbCloseArea())
Return(lRet)


Static Function MarcaTD(oMark)
Local cAlias		:= oMark:Alias()
Local aAreaSE1   	:= SE1->(GetArea())
Local cCLiente		:= SE1->E1_CLIENTE
Local cLoja			:= SE1->E1_LOJA
Local dData			:= ((Date())-365)

If ValMuCli(oMark:Mark()) //Valida se tem mais de um cliente selecionado
	
	//(cAlias)->(DbSeek(xFilial((cAlias))))
	While (cAlias)->(!Eof()) //.And. (cAlias)->E1_FILIAL == xFilial(cAlias) 
		//If (cAlias)->E1_TIPO $ 'NF /FT ' .And. (cAlias)->E1_EMISSAO >= dData
			If (!oMark:IsMark())
				RecLock((cAlias),.F.)
				(cAlias)->E1_FLAGSP2  := oMark:Mark()
				(cAlias)->(MsUnLock())
			Else
				RecLock(cAlias,.F.)
				(cAlias)->E1_FLAGSP2  := ""
				(cAlias)->(MsUnLock())
			EndIf
		//EndIf
		
		(cAlias)->(DbSkip())
	EndDo
EndIf


RestArea(aAreaSE1)
oMark:Refresh()
//oMark:GoTop(.T.)
//oMark:SetFilterDefault( cFilBrwK )
Return(.T.)
