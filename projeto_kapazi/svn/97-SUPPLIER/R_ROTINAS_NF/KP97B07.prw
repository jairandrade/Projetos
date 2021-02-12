#include 'protheus.ch'
#include 'parmtype.ch'
#Include "FwMvcDef.ch"
#Include "topconn.ch"
//==================================================================================================//
//	Programa: KP97B07		|	Autor: Luis Paulo							|	Data: 02/09/2018	//
//==================================================================================================//
//	Descrição: FWMarkBrowse onde será marcado os pv ja recebidos pela supplier, devendo ser 		//
//	marcadas as nf para supplier																	//
//																									//
//==================================================================================================//
User Function KP97B07()
Local	cAlias		:= "SF2"
Local 	oMark
Local	bAfterMark	:=	{|| oMarK:CanMark(oMark:Mark(),MarcaId(oMark))}
Local	bMarkAll	:=  {||  AllMark(oMark)}
Local 	cMark
Local 	cData		:= ((Date())-365)		
Private cFilBrwK	:= "(F2_XPVSPP  == 'S')" //Recebido pela supplier
Private  cCRLF		:= CRLF

//1=ENVIADO;2=RECEBIDO;3=PRE_AUT;4=REN_PRE_AUT;5=FATURADO;9=CANCELADO
If cEmpAnt <> '04' 
	MsgInfo("Esta rotina funciona apenas para informações da empresa 04 (Industria)","KAPAZI - Notas Fiscais - SUPPLIER CARD")
	Return
EndIf

DbSelectArea("SF2")
DbSetOrder(3)


//Instância a classe
oMark := FWMarkBrowse():New()
oMark:SetAlias(cAlias)
oMark:SetFilterDefault(cFilBrwK)
oMark:SetFieldMark('F2_MARKSP') //Trocar para F2_MARKSP
oMark:SetDescription('Notas Fiscais Supplier')
oMark:SetAfterMark(bAfterMark)
oMark:SetAllMark(bMarkAll)
oMark:SetAmbiente(.F.)
oMark:SetWalkThru(.F.)
oMark:DisableDetails()
oMark:SetMark(oMark:Mark(),cAlias,"F2_MARKSP")

cMark		:= oMark:Mark()

oMark:Activate()
ClearOk(cMark)
Return()


Static Function MenuDef()
Local aMenu	:=	{}

Add Option aMenu Title 'Visualizar' 		Action 'ViewDef.KP97B07' 				Operation 2 Access 0  //
Add Option aMenu Title 'Integrar'  			Action 'U_KP97A13' 						Operation 4 Access 0

Return aMenu


Static Function ModelDef()
Local 	oModel 				// Modelo de dados que será construído

//Definindo o controller
oModel := MPFormModel():New("KP97B07C",/*Pre-Validacao*/,,/*Commit*/,/*Cancel*/)

//Definindo Estrutura
oStruct := FWFormStruct(1,"SF2",/*Definir se usa o campo(Ret t ou f)*/ )

//Adiciona um modelo de Formulario de Cadastro Similar à Enchoice ou Msmget
oModel:AddFields('Enchoice_SF2', /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//Definindo Chave Primaria do Master. Necessário quando não existe no X2_UNICO
oModel:SetPrimaryKey({ "F2_FILIAL","F2_DOC","F2_SERIE","F2_CLIENTE","F2_LOJA"}) //F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, R_E_C_D_E_L_

//Adiciona Descricao do Modelo de Dados
oModel:SetDescription( 'Modelo de Dados - Notas Fiscais Supplier' )

//Adiciona Descricao do Componente do Modelo de Dados
cTexto := 'Formulario - Notas Fiscais Supplier'
oModel:GetModel( 'Enchoice_SF2' ):SetDescription( cTexto )

Return(oModel)

Static Function ViewDef()
Local oStruct
Local oModel
Local oView

oStruct	:=	FWFormStruct(2,"SF2") 	//Retorna a Estrutura do Alias passado
oModel	:=	FwLoadModel('KP97B07')	//Retorna o Objeto do Modelo de Dados- nome do fonte de onde queremos obter o modelo de dados
oView	:=	FwFormView():New()      //Instancia do Objeto de Visualização

//Define o Modelo sobre qual a Visualizacao sera utilizada
oView:SetModel(oModel)

//Vincula o Objeto visual de Cadastro com o modelo
oView:AddField( 'VIEW_SF2', oStruct, 'Enchoice_SF2')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox("TELA",100)

//Colocando título do formulário
oView:EnableTitleView('VIEW_SF2', 'Notas Fiscais Supplier' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_SF2', 'TELA' )

//Força o fechamento da janela na confirmação
oView:SetCloseOnOk({||.T.})

Return(oView)

//Marcar todos os registros
Static Function AllMark(oMark)

Processa({||MarcaTD(oMark)} ,"Processando NF","Aguarde...") 

Return(.T.)

/*
+--------------------------------------------------------------------------+
! Função    ! ClearOk    ! Autor !                    ! Data ! 30/09/2017  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Limpa o campo F2_MARKSP.                                         !
+-----------+--------------------------------------------------------------+
*/
Static Function ClearOK(cMark)
Local cSql := ""

cSql += " UPDATE " + RetSqlName("SF2") "
cSql += " SET F2_MARKSP = ''"
cSql += " WHERE D_E_L_E_T_ <> '*' "
cSql += " AND F2_MARKSP 	= '"+cMark+"'"

If TcSqlExec(cSql) < 0
	Help( ,, 'Clear',, 'Não é possível limpar os registros!!!', 1, 0 )
	Conout("Nao limpouuu")
EndIf

Return(.T.)

Static Function MarcaId(oMark)
Local cAlias		:= oMark:Alias()

If (oMark:IsMark())
		RecLock((cAlias),.F.)
		(cAlias)->F2_MARKSP  := oMark:Mark()
		(cAlias)->(MsUnLock())
	Else
		RecLock(cAlias,.F.)
		(cAlias)->F2_MARKSP := ""
		(cAlias)->(MsUnLock())
EndIf

Return(.T.)

Static Function MarcaTD(oMark)
Local cAlias		:= oMark:Alias()
Local aAreaSF2   	:= SF2->(GetArea())
Local cCLiente		:= SF2->F2_CLIENTE
Local cLoja			:= SF2->F2_LOJA
Local dData			:= ((Date())-365)


//(cAlias)->(DbSeek(xFilial((cAlias))))
While (cAlias)->(!Eof()) //.And. (cAlias)->F2_FILIAL == xFilial(cAlias) 

	//If (cAlias)->F2_TIPO $ 'NF /FT ' .And. (cAlias)->F2_EMISSAO >= dData
		If (!oMark:IsMark())
			RecLock((cAlias),.F.)
			(cAlias)->F2_MARKSP  := oMark:Mark()
			(cAlias)->(MsUnLock())
		Else
			RecLock(cAlias,.F.)
			(cAlias)->F2_MARKSP  := ""
			(cAlias)->(MsUnLock())
		EndIf
	//EndIf
	
	(cAlias)->(DbSkip())
EndDo

RestArea(aAreaSF2)
oMark:Refresh()
//oMark:GoTop(.T.)
//oMark:SetFilterDefault( cFilBrwK )
Return(.T.)