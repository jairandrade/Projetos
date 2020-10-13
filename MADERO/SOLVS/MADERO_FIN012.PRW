#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Cadastro de Bandeiras"

/*/{Protheus.doc} PCP010
Cadastro de Bandeiras (ZWY)
@author Thiago Berna
@since 03/Fevereiro/2020
@version 1.0
@return Nil, Função não tem retorno
/*/

User Function FIN012()

	Local aArea   	:= GetArea()
	Local oBrowse

	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro
	oBrowse:SetAlias("ZWY")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	//Setando O MENUDEF
	oBrowse:SetMenuDef('MADERO_FIN012')

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)

Return Nil

/*---------------------------------------------------------------------*
| Func:  MenuDef                                                      |
| Autor: Thiago Berna                                                 |
| Data:  03/Fevereiro/2020                                               |
| Desc:  Criação do menu MVC                                          |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function MenuDef()
	Local aRot 		:= {}
	
	//Adicionando opções	
	ADD OPTION aRot TITLE 'Incluir'    	ACTION 'VIEWDEF.MADERO_FIN012'	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    	ACTION 'VIEWDEF.MADERO_FIN012'	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Visualizar'	ACTION 'VIEWDEF.MADERO_FIN012'	OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Excluir'    	ACTION 'VIEWDEF.MADERO_FIN012'	OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

/*---------------------------------------------------------------------*
| Func:  ModelDef                                                     |
| Autor: Thiago Berna                                                 |
| Data:  03/Fevereiro/2020                                               |
| Desc:  Criação do modelo de dados MVC                               |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function ModelDef()
	//Criação do objeto do modelo de dados
	Local oModel := Nil

	//Criação da estrutura de dados utilizada na interface
	Local oStZWY := FWFormStruct(1, "ZWY")

	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("zFIN012",/*bVldPre*/,,/*bCommit*/,/*bCancel*/)

	//Atribuindo formulários para o modelo
	oModel:AddFields("FORMZWY",/*cOwner*/,oStZWY)

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({'ZWY_FILIAL','ZWY_COD'})

	//Adicionando descrição ao modelo
	oModel:SetDescription(cTitulo)

	//Setando a descrição do formulário
	oModel:GetModel("FORMZWY"):SetDescription(cTitulo)
Return oModel

/*---------------------------------------------------------------------*
| Func:  ViewDef                                                      |
| Autor: Thiago Berna                                                 |
| Data:  03/Fevereiro/2020                                               |
| Desc:  Criação da visão MVC                                         |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function ViewDef()

	//Criação do objeto do modelo de dados da Interface 
	Local oModel := ModelDef()//FWLoadModel("M_FIN012")

	//Criação da estrutura de dados utilizada na interface 
	Local oStZWY := FWFormStruct(2, "ZWY")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}

	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formulários para interface
	oView:AddField("VIEW_ZWY", oStZWY, "FORMZWY")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	//Colocando título do formulário
	oView:EnableTitleView('VIEW_ZWY', cTitulo )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZWY","TELA")

Return oView                       