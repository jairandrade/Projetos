#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Cadastros de Programador x Usu�rio"

/*/{Protheus.doc} APCP010
Cadastros de Programador x Usu�rio (Z58)
@author Thiago Berna
@since 09/Setembro/2019
@version 1.0
@return Nil, Fun��o n�o tem retorno
/*/

User Function APCP010()

	Local aArea   	:= GetArea()
	Local oBrowse

	//Inst�nciando FWMBrowse - Somente com dicion�rio de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro
	oBrowse:SetAlias("Z58")

	//Setando a descri��o da rotina
	oBrowse:SetDescription(cTitulo)

	//Setando O MENUDEF
	oBrowse:SetMenuDef('MADERO_APCP010')

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)

Return Nil

/*---------------------------------------------------------------------*
| Func:  MenuDef                                                      |
| Autor: Thiago Berna                                                 |
| Data:  09/Setembro/2019                                             |
| Desc:  Cria��o do menu MVC                                          |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function MenuDef()
	Local aRot 		:= {}
	
	//Adicionando op��es	
	ADD OPTION aRot TITLE 'Incluir'    	ACTION 'VIEWDEF.MADERO_APCP010'	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    	ACTION 'VIEWDEF.MADERO_APCP010'	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Visualizar'	ACTION 'VIEWDEF.MADERO_APCP010'	OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Excluir'    	ACTION 'VIEWDEF.MADERO_APCP010'	OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

/*---------------------------------------------------------------------*
| Func:  ModelDef                                                     |
| Autor: Thiago Berna                                                 |
| Data:  09/Setembro/2019                                             |
| Desc:  Cria��o do modelo de dados MVC                               |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function ModelDef()
	//Cria��o do objeto do modelo de dados
	Local oModel := Nil

	//Cria��o da estrutura de dados utilizada na interface
	Local oStZ58 := FWFormStruct(1, "Z58")

	//Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("zMVCZ58",/*bVldPre*/,,/*bCommit*/,/*bCancel*/)

	//Atribuindo formul�rios para o modelo
	oModel:AddFields("FORMZ58",/*cOwner*/,oStZ58)

	//Setando a chave prim�ria da rotina
	oModel:SetPrimaryKey({'Z58_FILIAL','Z58_COD'})

	//Adicionando descri��o ao modelo
	oModel:SetDescription(cTitulo)

	//Setando a descri��o do formul�rio
	oModel:GetModel("FORMZ58"):SetDescription(cTitulo)
Return oModel

/*---------------------------------------------------------------------*
| Func:  ViewDef                                                      |
| Autor: Thiago Berna                                                 |
| Data:  09/Setembro/2019                                             |
| Desc:  Cria��o da vis�o MVC                                         |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function ViewDef()

	//Cria��o do objeto do modelo de dados da Interface 
	Local oModel := ModelDef()//FWLoadModel("APCP010")

	//Cria��o da estrutura de dados utilizada na interface 
	Local oStZ58 := FWFormStruct(2, "Z58")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}

	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formul�rios para interface
	oView:AddField("VIEW_Z58", oStZ58, "FORMZ58")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	//Colocando t�tulo do formul�rio
	oView:EnableTitleView('VIEW_Z58', cTitulo )

	//For�a o fechamento da janela na confirma��o
	oView:SetCloseOnOk({||.T.})

	//O formul�rio da interface ser� colocado dentro do container
	oView:SetOwnerView("VIEW_Z58","TELA")

Return oView                       