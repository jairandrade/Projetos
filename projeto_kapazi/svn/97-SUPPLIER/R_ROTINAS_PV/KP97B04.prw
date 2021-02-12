#include 'protheus.ch'
#include 'parmtype.ch'
#Include "FwMvcDef.ch"
#Include "topconn.ch"
//==================================================================================================//
//	Programa: KP97B04		|	Autor: Luis Paulo							|	Data: 19/08/2018	//
//==================================================================================================//
//	Descrição: FWMarkBrowse onde será marcado os pv que vão para supplier							//
//																									//
//==================================================================================================//
User Function KP97B04()
Local	cAlias		:= "SA1"
Local 	oMark
Local	bAfterMark	:=	{|| oMarK:CanMark(oMark:Mark(),MarcaId(oMark))}
Local	bMarkAll	:=  {||  AllMark(oMark)}
Local 	cMark
Local 	cData		:= ((Date())-365)		
//Private cFilBrwK		:= "C5_PREFIXO == '1  ' .AND. C5_TIPO == 'NF ' .AND. C5_SALDO == 0" //NOTAS BAIXADASC
Private cFilBrwK		:= "A1_FLAGSPC == 'S'" //NOTAS BAIXADASC
Private  cCRLF		:= CRLF

//Validar os ultimos 12meses(360)
If cEmpAnt <> '04' 
	MsgInfo("Esta rotina funciona apenas para informações da empresa 04 (Industria)","KAPAZI - Clientes SUPPLIER CARD")
	Return
EndIf

//Instância a classe
oMark := FWMarkBrowse():New()
oMark:SetAlias(cAlias)
oMark:SetFilterDefault(cFilBrwK)
oMark:SetFieldMark('A1_FLAGSP2') //Trocar para A1_FLAGSP2
oMark:SetDescription('Clientes Supplier')
oMark:SetAfterMark(bAfterMark)
oMark:SetAllMark(bMarkAll)
oMark:SetAmbiente(.F.)
oMark:SetWalkThru(.F.)
oMark:DisableDetails()
oMark:SetMark(oMark:Mark(),cAlias,"A1_FLAGSP2")

///Legendas do Browse
oMark:AddLegend( "A1_FLAGSPC == 'S'"	, "GREEN"	, "Clientes Supplier" )
oMark:AddLegend( "A1_FLAGSPC != 'S'"	, "BLACK"	, "Clientes somente Kapazi" )

cMark		:= oMark:Mark()

oMark:Activate()
ClearOk(cMark)
Return()


Static Function MenuDef()
Local aMenu	:=	{}

Add Option aMenu Title 'Visualizar' 		Action 'ViewDef.KP97B04' 				Operation 2 Access 0  //
Add Option aMenu Title 'Integrar'  			Action 'U_KP97A08' 						Operation 4 Access 0

Return aMenu


Static Function ModelDef()
Local 	oModel 				// Modelo de dados que será construído

//Definindo o controller
oModel := MPFormModel():New("KP97B04C",/*Pre-Validacao*/,,/*Commit*/,/*Cancel*/)

//Definindo Estrutura
oStruct := FWFormStruct(1,"SA1",/*Definir se usa o campo(Ret t ou f)*/ )

//Adiciona um modelo de Formulario de Cadastro Similar à Enchoice ou Msmget
oModel:AddFields('Enchoice_SA1', /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//Definindo Chave Primaria do Master. Necessário quando não existe no X2_UNICO
oModel:SetPrimaryKey({ "A1_FILIAL","A1_COD","A1_LOJA"}) //C5_FILIAL, C5_PREFIXO, C5_NUM, C5_PARCELA, C5_TIPO, R_E_C_D_E_L_

//Adiciona Descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados - Clientes' )

//Adiciona Descricao do Componente do Modelo de Dados
cTexto := 'Formulario - Clientes'
oModel:GetModel( 'Enchoice_SA1' ):SetDescription( cTexto )

Return(oModel)

Static Function ViewDef()
Local oStruct
Local oModel
Local oView

oStruct	:=	FWFormStruct(2,"SA1") 	//Retorna a Estrutura do Alias passado
oModel	:=	FwLoadModel('KP97B04')	//Retorna o Objeto do Modelo de Dados- nome do fonte de onde queremos obter o modelo de dados
oView	:=	FwFormView():New()      //Instancia do Objeto de Visualização

//Define o Modelo sobre qual a Visualizacao sera utilizada
oView:SetModel(oModel)

//Vincula o Objeto visual de Cadastro com o modelo
oView:AddField( 'VIEW_SA1', oStruct, 'Enchoice_SA1')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox("TELA",100)

//Colocando título do formulário
oView:EnableTitleView('VIEW_SA1', 'Clientes' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_SA1', 'TELA' )

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
	From %Table:SA1%	SA1
	Where SA1.%NotDel%	And
		  SA1.A1_FLAGSP2	= %Exp:cMarca%
EndSql

MsgInfo('Foram marcados ' + cValToChar((cTmp)->QTD) + ' registro','Marcados')

(cTmp)->(dbCloseArea())

RestArea(aArea)
Return(.T.)

//Marcar todos os registros
Static Function AllMark(oMark)

Processa({||MarcaTD(oMark)} ,"Processando Clientes","Aguarde...") 

Return(.T.)

/*
+--------------------------------------------------------------------------+
! Função    ! ClearOk    ! Autor !                    ! Data ! 30/09/2017  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Limpa o campo A1_FLAGSP2.                                         !
+-----------+--------------------------------------------------------------+
*/
Static Function ClearOK(cMark)
Local cSql := ""

cSql += " UPDATE " + RetSqlName("SA1") "
cSql += " SET A1_FLAGSP2 = ''"
cSql += " WHERE D_E_L_E_T_ <> '*' "
cSql += " AND A1_FLAGSP2 	= '"+cMark+"'"

If TcSqlExec(cSql) < 0
	Help( ,, 'Clear',, 'Não é possível limpar os registros!!!', 1, 0 )
	Conout("Nao limpouuu")
EndIf

Return(.T.)

Static Function MarcaId(oMark)
Local cAlias		:= oMark:Alias()

If (oMark:IsMark())
		RecLock((cAlias),.F.)
		(cAlias)->A1_FLAGSP2  := oMark:Mark()
		(cAlias)->(MsUnLock())
	Else
		RecLock(cAlias,.F.)
		(cAlias)->A1_FLAGSP2 := ""
		(cAlias)->(MsUnLock())
EndIf

Return(.T.)

Static Function MarcaTD(oMark)
Local cAlias		:= oMark:Alias()
Local aAreaSA1   	:= SA1->(GetArea())
Local cCLiente		:= SA1->C5_CLIENTE
Local cLoja			:= SA1->C5_LOJACLI
Local dData			:= ((Date())-365)


(cAlias)->(DbSeek(xFilial((cAlias))))
While (cAlias)->(!Eof()) .And. (cAlias)->C5_FILIAL == xFilial(cAlias) 
	//If (cAlias)->C5_TIPO $ 'NF /FT ' .And. (cAlias)->C5_EMISSAO >= dData
		If (!oMark:IsMark())
			RecLock((cAlias),.F.)
			(cAlias)->A1_FLAGSP2  := oMark:Mark()
			(cAlias)->(MsUnLock())
		Else
			RecLock(cAlias,.F.)
			(cAlias)->A1_FLAGSP2  := ""
			(cAlias)->(MsUnLock())
		EndIf
	//EndIf
	
	(cAlias)->(DbSkip())
EndDo

RestArea(aAreaSA1)
oMark:Refresh()
//oMark:GoTop(.T.)
//oMark:SetFilterDefault( cFilBrwK )
Return(.T.)