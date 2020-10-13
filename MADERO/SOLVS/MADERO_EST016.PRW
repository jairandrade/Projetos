#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cTitulo := "Produtos Separados"

/*/{Protheus.doc} EST016
Produtos Separados (CB9)
@author Thiago Berna
@since 06/Setembro/2020
@version 1.0
@return Nil, Função não tem retorno
/*/

User Function EST016()

	Local aArea   	:= GetArea()
	Local oBrowse

	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro
	oBrowse:SetAlias("CB9")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	//Setando O MENUDEF
	oBrowse:SetMenuDef('MADERO_EST016')

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)

Return Nil

/*---------------------------------------------------------------------*
| Func:  MenuDef                                                      |
| Autor: Thiago Berna                                                 |
| Data:  06/Setembro/2020                                               |
| Desc:  Criação do menu MVC                                          |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function MenuDef()
	Local aRot 		:= {}
	
	//Adicionando opções	
	//ADD OPTION aRot TITLE 'Incluir'    	ACTION 'VIEWDEF.MADERO_EST016'	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	//ADD OPTION aRot TITLE 'Estornar Embarque'   ACTION 'StaticCall(EST016,Estorna)' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Visualizar'	        ACTION 'VIEWDEF.MADERO_EST016'	    OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	//ADD OPTION aRot TITLE 'Excluir'    	ACTION 'VIEWDEF.MADERO_EST016'	OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot

/*---------------------------------------------------------------------*
| Func:  ModelDef                                                     |
| Autor: Thiago Berna                                                 |
| Data:  06/Setembro/2020                                               |
| Desc:  Criação do modelo de dados MVC                               |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function ModelDef()
	//Criação do objeto do modelo de dados
	Local oModel := Nil

	//Criação da estrutura de dados utilizada na interface
	Local oStCB9 := FWFormStruct(1, "CB9")

	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("zEST016",/*bVldPre*/,,/*bCommit*/,/*bCancel*/)

	//Atribuindo formulários para o modelo
	oModel:AddFields("FORMCB9",/*cOwner*/,oStCB9)

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({'CB9_FILIAL','CB9_ORDSEP'})

	//Adicionando descrição ao modelo
	oModel:SetDescription(cTitulo)

	//Setando a descrição do formulário
	oModel:GetModel("FORMCB9"):SetDescription(cTitulo)
Return oModel

/*---------------------------------------------------------------------*
| Func:  ViewDef                                                      |
| Autor: Thiago Berna                                                 |
| Data:  06/Setembro/2020                                               |
| Desc:  Criação da visão MVC                                         |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function ViewDef()

	//Criação do objeto do modelo de dados da Interface 
	Local oModel := ModelDef()//FWLoadModel("M_EST016")

	//Criação da estrutura de dados utilizada na interface 
	Local oStCB9 := FWFormStruct(2, "CB9")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}

	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formulários para interface
	oView:AddField("VIEW_CB9", oStCB9, "FORMCB9")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	//Colocando título do formulário
	oView:EnableTitleView('VIEW_CB9', cTitulo )

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_CB9","TELA")

Return oView    

/*/{Protheus.doc} Estorna
Estorna Embarque do item
@type function
@version 
@author Thiago Berna
@since 06/09/2020
@return Nil
/*/
Static Function Estorna

    If MsgNoYes('Deseja estornar o embarque do item ' + AllTrim(CB9->CB9_PROD) + ' ?','Atencao')
        //Aguardando Definicao
        /*CB9->(RecLock('CB9',.F.))
        CB9->   := ''
        CB9->(MsUnlock())*/
    EndIf

Return