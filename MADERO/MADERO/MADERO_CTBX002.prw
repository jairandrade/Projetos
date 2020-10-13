//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "topconn.ch"
#include "fileio.ch"

//Variáveis Estáticas
Static cTitulo := "Lancamento Contabil - Cadastro de Lote"
//teste
/*/{Protheus.doc} CTBX002
Função para cadastro de Lote - Lancamento Contabil - CTBA500, exemplo de Modelo 3 em MVC
@author Jair Matos
@since 13/05/2019
@version 1.0
@return Nil, Função não tem retorno
@example
u_CTBX002()
@obs Não se pode executar função MVC dentro do fórmulas
exemplo AESP002
alteração 25-05-2020 - invertido ordenacao ZJC_EBDEB, ZJC_EBCRE ln. 245,246
/*/
User Function CTBX002()
	Local aArea   := GetArea()
	Local oBrowse 
	Private aRotina := MenuDef()

	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro do Cabeçalho do Cadastro de Lote
	oBrowse:SetAlias("ZJB")
	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	//Legendas
	oBrowse:AddLegend( "ZJB->ZJB_STATUS == '1'", "GREEN",	"Importado" )
	oBrowse:AddLegend( "ZJB->ZJB_STATUS == '0'", "RED",	"Não Importado" )
	//oBrowse:AddLegend( "ZJB->ZJB_STATUS == '2'", "YELLOW",	"Sem arquivo" )
	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)
Return Nil
/*/{Protheus.doc} MenuDef
Criação do menu MVC
@author Jair Matos
@since 14/05/2019 
@version 1.0
@return Nil 
/*/
Static Function MenuDef()
	Local aRot := {}

	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.MADERO_CTBX002' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_Ctbx02Leg'     OPERATION 6                      		ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Gerar Txt'  ACTION 'u_Ctbx02Txt'     OPERATION 7                      		ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Importar'   ACTION 'u_ImportCSV'     OPERATION 8                      		ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.MADERO_CTBX002' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.MADERO_CTBX002' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.MADERO_CTBX002' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot
/*/{Protheus.doc} ModelDef
Criação do modelo de dados MVC
@author Jair Matos
@since 14/05/2019 
@version 1.0
@return Nil 
/*/
Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStPai 		:= FWFormStruct(1, 'ZJB')
	Local oStFilho 		:= FWFormStruct(1, 'ZJC')
	Local aZJCRel		:= {}

	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New( 'CTBX002M', ,{ |oModel| CTBX02POS( oModel ) } )
	oModel:AddFields('ZJBMASTER',/*cOwner*/,oStPai)
	oModel:AddGrid( 'ZJCDETAIL', 'ZJBMASTER', oStFilho,  ,{ |oModelGrid| ValLinha(oModelGrid) })//quinto parametro pos

	//Fazendo o relacionamento entre o Pai e Filho
	aAdd(aZJCRel, {'ZJC_FILIAL',	'ZJB_FILIAL'} )
	aAdd(aZJCRel, {'ZJC_COD',	'ZJB_COD'})

	//----------------------------------------------------------GATILHOS--------------------------------------------------------------------------
	oStFilho:AddTrigger	("ZJC_FILIT",	"ZJC_CCDEB",  {|| .T.},{ || "" } )        // gatilho filial X Centro de Custo Debito
	oStFilho:AddTrigger	("ZJC_FILIT",	"ZJC_CCCRE",  {|| .T.},{ || "" } )        //  gatilho filial X Centro de Custo Credito
	oStFilho:AddTrigger	("ZJC_FILIT",	"ZJC_ITEMDE",  {|| .T.},{ || "" } )      //  gatilho filial X Item Debito
	oStFilho:AddTrigger	("ZJC_FILIT",	"ZJC_ITEMCR",  {|| .T.},{ || "" } )      //  gatilho filial X Item Credito
	oStFilho:AddTrigger	("ZJC_FILIT",	"ZJC_EBDEB",  {|| .T.},{ || "" } )        //  gatilho filial X Entidade Debito
	oStFilho:AddTrigger	("ZJC_FILIT",	"ZJC_EBCRE",  {|| .T.},{ || "" } )       // gatilho filial X Entidade Credito
	oStFilho:AddTrigger	("ZJC_FILIT",	"ZJC_CVDEB",  {|| .T.},{ || "" } )    	// gatilho filial X Classe Valor Debito
	oStFilho:AddTrigger	("ZJC_FILIT",	"ZJC_CVCRE",  {|| .T.},{ || "" } )     	 // gatilho filial X Classe Valor Credito
	oStFilho:AddTrigger	("ZJC_NUM"	,	"ZJC_CTADEB",  {|| .T.},{ || "" } )    						// gatilho LP X Cta Debito
	oStFilho:AddTrigger	("ZJC_NUM"	,	"ZJC_CTACRE",  {|| .T.},{ || "" } )    						// gatilho LP X Cta Credito
	oStFilho:AddTrigger	("ZJC_CTADEB",	"ZJC_CCCRE",  {|| .T.},{ || "" } )    	    // gatilho LP X Centro de Custo Debito	
	oStFilho:AddTrigger	("ZJC_CTADEB",	"ZJC_ITEMCR",  {|| .T.},{ || "" } )    	  // gatilho LP X Item Debito
	oStFilho:AddTrigger	("ZJC_CTADEB",	"ZJC_EBCRE", {|| .T.},{ || "" } )    	    // gatilho LP X Entidade Bancaria Debito
	oStFilho:AddTrigger	("ZJC_CTADEB",	"ZJC_CVCRE",  {|| .T.},{ || "" } )    	 // gatilho LP X Classe Valor Debito
	oStFilho:AddTrigger	("ZJC_CTADEB",	"ZJC_CCDEB",  {|| .T.},{||ValZ0C(oModel,"ZJC_CCDEB",1) } )    // gatilho LP X Centro de Custo Debito	
	oStFilho:AddTrigger	("ZJC_CTADEB",	"ZJC_ITEMDE",  {|| .T.},{||ValZ0C(oModel,"ZJC_ITEMDE",1) } )  // gatilho LP X Item Debito
	oStFilho:AddTrigger	("ZJC_CTADEB",	"ZJC_EBDEB",  {|| .T.},{||ValZ0C(oModel,"ZJC_EBDEB",1) } )    // gatilho LP X Entidade Bancaria Debito
	oStFilho:AddTrigger	("ZJC_CTADEB",	"ZJC_CVDEB",  {|| .T.},{||ValZ0C(oModel,"ZJC_CVDEB",1) } )  // gatilho LP X Classe Valor Debito
	oStFilho:AddTrigger	("ZJC_CTACRE",	"ZJC_CCCRE",  {|| .T.},{||ValZ0C(oModel,"ZJC_CCCRE",2) } )    // gatilho LP X Centro de Custo Credito
	oStFilho:AddTrigger	("ZJC_CTACRE",	"ZJC_ITEMCR",  {|| .T.},{||ValZ0C(oModel,"ZJC_ITEMCR",2) } )  // gatilho LP X Item Credito
	oStFilho:AddTrigger	("ZJC_CTACRE",	"ZJC_EBCRE",  {|| .T.},{||ValZ0C(oModel,"ZJC_EBCRE",2) } )    // gatilho LP X Entidade Bancaria Credito
	oStFilho:AddTrigger	("ZJC_CTACRE",	"ZJC_CVCRE",  {|| .T.},{||ValZ0C(oModel,"ZJC_CVCRE",2) } )  // gatilho LP X Classe Valor Credito
	oStFilho:AddTrigger	("ZJC_CTACRE",	"ZJC_CCDEB", {|| .T.},{ || "" } )    // gatilho LP X Centro de Custo Credito
	oStFilho:AddTrigger	("ZJC_CTACRE",	"ZJC_ITEMDE", {|| .T.},{ || "" } )    // gatilho LP X Item Credito
	oStFilho:AddTrigger	("ZJC_CTACRE",	"ZJC_EBDEB", {|| .T.},{ || "" } )     // gatilho LP X Entidade Bancaria Credito
	oStFilho:AddTrigger	("ZJC_CTACRE",	"ZJC_CVDEB",  {|| .T.},{ || "" } )     // gatilho LP X Classe Valor Credito


	oStFilho:SetProperty( 'ZJC_CCDEB',     MODEL_FIELD_WHEN,  {|| .F.} ) 
	oStFilho:SetProperty( 'ZJC_CCCRE',     MODEL_FIELD_WHEN,  {|| .F.} ) 
	oStFilho:SetProperty( 'ZJC_ITEMDE',    MODEL_FIELD_WHEN,  {|| .F.} ) 
	oStFilho:SetProperty( 'ZJC_ITEMCR',    MODEL_FIELD_WHEN,  {|| .F.} ) 

	oModel:SetRelation('ZJCDETAIL', aZJCRel, ZJC->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:SetPrimaryKey({})

	//Setando as descrições
	oModel:SetDescription("Itens de Lotes")
	oModel:GetModel('ZJBMASTER'):SetDescription('Cabeçalho Lote')
	oModel:GetModel('ZJCDETAIL'):SetDescription('Itens Lote')

Return oModel
/*/{Protheus.doc} ViewDef
Criação da visão MVC
@author Jair Matos
@since 14/05/2019 
@version 1.0
@return Nil 
/*/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel		:= FWLoadModel('MADERO_CTBX002')
	Local oStPai		:= FWFormStruct(2, 'ZJB')
	Local oStFilho		:= FWFormStruct(2, 'ZJC')

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_ZJB',oStPai,'ZJBMASTER')
	oView:AddGrid('VIEW_ZJC',oStFilho,'ZJCDETAIL')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',30)
	oView:CreateHorizontalBox('GRID',70)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_ZJB','CABEC')
	oView:SetOwnerView('VIEW_ZJC','GRID')

	//Habilitando título
	oView:EnableTitleView('VIEW_ZJB','Cabeçalho Lote')
	oView:EnableTitleView('VIEW_ZJC','Itens Lote')
Return oView
/*/{Protheus.doc} Ctbx02Leg
Legenda
@author Jair Matos
@since 14/05/2019 
@version 1.0
@return Nil 
/*/
User Function Ctbx02Leg()
	Local aLegenda := {}

	AADD(aLegenda,{"BR_VERMELHO","Não Importado"})
	AADD(aLegenda,{"BR_VERDE" 	,"Importado"})
	//AADD(aLegenda,{"BR_AMARELO" ,"Sem arquivo associado" })
	BrwLegenda("Cadastro de Lotes", "Legenda", aLegenda)
Return Nil
/*/{Protheus.doc} Ctbx02Txt
Função que chama a rotina de criação de arquivo TXT
@author Jair Matos
@since 14/05/2019 
@version 1.0
@return Nil 
/*/
User Function Ctbx02Txt()

	SetPrvt("cArqCPag,nHdlArq,cTexto,nContad")

	If MsgYesNo("Confirma geração de arquivo para o Lançamento Contábil?","Confirma?")
		Processa({|lEnd| GeraArquivo()},"Geração de Arquivo para o Lancamento Contábil")
	Endif

Return
/*/{Protheus.doc} GeraArquivo
Função para criação de arquivo TXT
@author Jair Matos
@since 28/05/2019 
@version 1.0
@return Nil 
/*/
Static Function GeraArquivo()
	Local targetDir :=""
	Local cValor := ""
	Local nTotal := 0
	Local cAliasGER := GetNextAlias() // da um nome pro arquivo temporario
	Static DBI_EOF          :=  27

	targetDir:= cGetFile( '*.txt|*.txt' , "Selecione o arquivo...", 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
	If Empty(targetDir)
		Return	
	EndIf

	cArqCPag := targetDir+ALLTRIM(ZJB->ZJB_ARQ)

	nHdlArq  := FCREATE(cArqCPag, 0)

	If FERROR() <> 0
		Msgalert("Arquivo Texto não pode ser criado!","ATENÇÃO")
		Return
	Else
		IncProc("Gerando arquivo "+cArqCPag)
	Endif

	PRIVATE cQuery 
	cQuery := " SELECT ZJC_FILIT,ZJC_NUM,ZJC_CTADEB,ZJC_CTACRE,ZJC_VALOR,ZJC_CCDEB,ZJC_CCCRE,ZJC_EBCRE, "
	cQuery += " ZJC_EBDEB,ZJC_CVCRE,ZJC_CVDEB,ZJC_ITEMDE,ZJC_ITEMCR,ZJC_HISTO "
	cQuery += " FROM " +RetSqlName("ZJB")+" ZJB "
	cQuery += " JOIN " +RetSqlName("ZJC")+" ZJC ON ZJC.D_E_L_E_T_ <> '*' AND  ZJC_COD = ZJB_COD "
	cQuery += " WHERE "
	cQuery += " ZJB.D_E_L_E_T_ <> '*' AND "
	cQuery += " ZJB_COD = '" + ZJB->ZJB_COD + "'" 

	TCQUERY cQuery NEW ALIAS &cAliasGER
	Count To nTotal
	nContad := 0
	DbGotop()

	While !Eof()
		cValor := alltrim(STR((cAliasGER)->ZJC_VALOR*100))
		cTexto := (cAliasGER)->ZJC_FILIT+ SPACE(2)											//FILIAL 					10 caracteres + 2 espacos
		cTexto += SUBSTR(ALLTRIM((cAliasGER)->ZJC_NUM),1,3)+SPACE(4)						//Lancamento padrao 		03 caracteres + 5 espacos 15
		cTexto += SUBSTR(((cAliasGER)->ZJC_CTADEB),1,11)+SPACE(1)    						// Conta debito 			11 Caracteres + 2 espaco 
		cTexto += SUBSTR(((cAliasGER)->ZJC_CTACRE),1,11)+SPACE(1)                    		// Conta Credito     		11 Caracteres + 2 espaco
		cTexto += cValor+SPACE(16-LEN(cValor))+SPACE(1)										// VALOR	16 Caracteres 44
		cTexto += SUBSTR((cAliasGER)->ZJC_CCDEB,1,6)+SPACE(1)                    			// Centro Custo Debito      06 Caracteres + 2 espaco
		cTexto += SUBSTR((cAliasGER)->ZJC_CCCRE,1,6)+SPACE(1)                   			// Centro Custo Debito      06 Caracteres + 2 espaco
		cTexto += SUBSTR(((cAliasGER)->ZJC_EBCRE),1,18)+SPACE(1)                   			// Entidade credito         18 Caracteres + 2 espacos
		cTexto += SUBSTR(((cAliasGER)->ZJC_EBDEB),1,18)+SPACE(1)                   			// Entidade Debito          18 Caracteres + 2 espacos
		cTexto += SUBSTR(((cAliasGER)->ZJC_CVDEB),1,9)+SPACE(1)                 			// Classe Valor Debito      09 Caracteres + 2 espacos
		cTexto += SUBSTR(((cAliasGER)->ZJC_CVCRE),1,9)+SPACE(1)                   			// Classe Valor Credito     09 Caracteres + 2 espacos
		cTexto += SUBSTR(((cAliasGER)->ZJC_ITEMDE),1,6)+SPACE(1)                   			// Item Debito      		06 Caracteres + 2 espacos
		cTexto += SUBSTR(((cAliasGER)->ZJC_ITEMCR),1,6)+SPACE(1)                    		// Item Credito      		06 Caracteres + 2 espacos
		cTexto += (cAliasGER)->ZJC_HISTO                 									// Historico      			40 Caracteres
		nContad++
		If nTotal == nContad
			FWrite(nHdlArq,cTexto)	
		Else
			FWrite(nHdlArq,cTexto+Chr(13) + Chr(10))
		EndIf	   

		DbSkip()
	Enddo

	(cAliasGER)->(dbCloseArea())
	FClose(nHdlArq)

	If nContad = 0
		MsgAlert("Não há dados. Favor vertificar os Parâmetros.","Atenção")
		FErase(cArqCPag)
	Else
		Msgalert("Arquivo gerado na pasta "+Alltrim(cArqCPag),"ATENÇÃO")
	Endif

	Return
	/*/{Protheus.doc} ValLinha(oModelGrid) 
	Rotina que valida linha a linha - Antiga LINOK
	@author Jair Matos
	@since 21/02/2019
	@version P12
	@type function
	@return cCampoRet
	/*/
Static Function ValLinha(oModelGrid) 
	Local lRet := .T. 
	Local cTipoConta := Posicione("CT5", 01, xFilial("CT5") + oModelGrid:GetValue("ZJC_NUM"), "CT5_DC")
	Local cContaSel := ""
	Local cItobrg,cCCobrg,cBancOBR,cCLVLOBR :=""
	If oModelGrid:GetOperation() == 3 .or. oModelGrid:GetOperation() == 4


		IF cTipoConta=="1"
			cContaSel :="ZJC_CTADEB"
		ElseIf cTipoConta=="2"
			cContaSel :="ZJC_CTACRE"
		EndIf

		//Validar os dados na tabela CT1 - Plano de Contas. Nesta tabela é verificado se os campos são obrigatorios.
		DbSelectArea("CT1")
		CT1->(DbSetOrder(1))// CT1_FILIAL+CT1_CONTA
		If CT1->(DbSeek(xFilial("CT1")+oModelGrid:GetValue(cContaSel)))  
			cItobrg :=CT1->CT1_ITOBRG //Item obrigatorio
			cCCobrg :=CT1->CT1_CCOBRG //ccusto obrigatorio
			cBancOBR:=CT1->CT1_05OBRG //entidade bancaria obrigatorio
			cCLVLOBR:=CT1->CT1_CLOBRG //Classe Valor obrigatorio
		EndIf

		If Empty(oModelGrid:GetValue("ZJC_CTADEB")) .and. cTipoConta=="1" // Conta debito
			lRet := .F. 
			HELP(' ',1,'Atenção!',,"Campo ZJC_CTADEB - Conta Debito deve ser preenchido.",1,0)
		ElseIf Empty(oModelGrid:GetValue("ZJC_CTACRE")) .and. cTipoConta=="2" // Conta credito
			lRet := .F. 
			HELP(' ',1,'Atenção!',,"Campo ZJC_CTACRE - Conta Credito deve ser preenchido.",1,0)
		ElseIf Empty(oModelGrid:GetValue("ZJC_CCDEB")) .and. cTipoConta=="1" .and. cCCobrg=="1"// Centro de Custo debito
			lRet := .F. 
			HELP(' ',1,'Atenção!',,"Campo ZJC_CCDEB - Centro Custo Debito deve ser preenchido.",1,0, NIL, NIL, NIL, NIL, NIL, {"Amarração Cad.Filial X Centro de Custo"})
		ElseIf Empty(oModelGrid:GetValue("ZJC_CCCRE")) .and. cTipoConta=="2" .and. cCCobrg=="1"// Centro de Custo credito
			lRet := .F. 
			HELP(' ',1,'Atenção!',,"Campo ZJC_CCCRE - Centro Custo Credito deve ser preenchido.",1,0, NIL, NIL, NIL, NIL, NIL, {"Amarração Cad.Filial X Centro de Custo"})
		ElseIf Empty(oModelGrid:GetValue("ZJC_EBDEB")) .and. cTipoConta=="1" .and. cBancOBR=="1" // Entidade BAcnaria debito
			lRet := .F. 
			HELP(' ',1,'Atenção!',,"Campo ZJC_EBDEB - Entidade Bancaria Debito deve ser preenchido.",1,0)
		ElseIf Empty(oModelGrid:GetValue("ZJC_EBCRE")) .and. cTipoConta=="2" .and. cBancOBR=="1"//Entidade BAncaria credito
			lRet := .F. 
			HELP(' ',1,'Atenção!',,"Campo ZJC_EBCRE - Entidade Bancaria Credito deve ser preenchido.",1,0)
		ElseIf Empty(oModelGrid:GetValue("ZJC_CVDEB")) .and. cTipoConta=="1" .and. cCLVLOBR=="1"// Classe Valor debito
			lRet := .F. 
			HELP(' ',1,'Atenção!',,"Campo ZJC_CVDEB - Classe Valor Debito deve ser preenchido.",1,0)
		ElseIf Empty(oModelGrid:GetValue("ZJC_CVCRE")) .and. cTipoConta=="2" .and. cCLVLOBR=="1"// Classe Valor credito
			lRet := .F. 
			HELP(' ',1,'Atenção!',,"Campo ZJC_CVCRE - Classe Valor Credito deve ser preenchido.",1,0)
		ElseIf Empty(oModelGrid:GetValue("ZJC_ITEMDE")) .and. cTipoConta=="1" .and. cItobrg=="1"// Item debito
			lRet := .F. 
			HELP(' ',1,'Atenção!',,"Campo ZJC_ITEMDE - Item Debito deve ser preenchido.",1,0, NIL, NIL, NIL, NIL, NIL, {"Amarração Cad.Filial X Item"})
		ElseIf Empty(oModelGrid:GetValue("ZJC_ITEMCR")) .and. cTipoConta=="2" .and. cItobrg=="1"// ItemCredito
			lRet := .F. 
			HELP(' ',1,'Atenção!',,"Campo ZJC_ITEMCR - Item Credito deve ser preenchido.",1,0, NIL, NIL, NIL, NIL, NIL, {"Amarração Cad.Filial X Item"})
		EndIf
	EndIf

	Return lRet 
	/*/{Protheus.doc} ValZ0C(oModel,cCampo)
	Retorna valor de campo passado como parametro de acordo com a Filial logada .Funcao para carregar TRIGGER

	@author Jair Matos
	@since 21/02/2019
	@version P12
	@type function
	@return cCampoRet
	/*/
Static Function ValZ0C(oModel,cCampo,nOpc)
	Local cRetorno 	:= Space(TamSX3(cCampo)[1])
	Local cConta 	:= ""
	Local cAcust,cAcitem := ""

	If Empty(oModel:GetValue('ZJCDETAIL','ZJC_FILIT'))	.or. Empty(oModel:GetValue('ZJCDETAIL','ZJC_NUM'))
		Return cRetorno
	Else
		cConta :=Posicione("CT5", 01, xFilial("CT5") + oModel:GetValue('ZJCDETAIL','ZJC_NUM'), "CT5_DC")
		If nOpc ==1 //CONTA DEBITO
			If !Empty(oModel:GetValue('ZJCDETAIL','ZJC_CTADEB'))
				DbSelectArea("CT1")
				CT1->(DbSetOrder(1))// CT1_FILIAL+CT1_CONTA
				If CT1->(DbSeek(xFilial("CT1")+oModel:GetValue('ZJCDETAIL','ZJC_CTADEB')))  
					cAcitem :=CT1->CT1_ACITEM //Aceita Item
					cAcust  :=CT1->CT1_ACCUST //aceita ccusto
				EndIf
			EndIf
			If cCampo=="ZJC_CCDEB"//centro custo debito
				If cAcust=="1" 
					cRetorno := Posicione("ZA0",1, xFilial("ZA0") + oModel:GetValue('ZJCDETAIL','ZJC_FILIT') , "ZA0_CUSTO")
				Else
					cRetorno :=""
				EndIf
			ElseIf cCampo=="ZJC_ITEMDE"//Item Contabil debito 
				If cAcitem=="1"
					cRetorno := Posicione("ZJA", 1, xFilial("ZJA") + oModel:GetValue('ZJCDETAIL','ZJC_FILIT'), "ZJA_ITEM")
				EndIf
			Else
				cRetorno :=""
			EndIf
		ElseIf nOpc ==2 //cONTA CREDITO
			If !Empty(oModel:GetValue('ZJCDETAIL','ZJC_CTACRE'))
				DbSelectArea("CT1")
				CT1->(DbSetOrder(1))// CT1_FILIAL+CT1_CONTA
				If CT1->(DbSeek(xFilial("CT1")+oModel:GetValue('ZJCDETAIL','ZJC_CTACRE')))  
					cAcitem :=CT1->CT1_ACITEM //Aceita Item
					cAcust  :=CT1->CT1_ACCUST //aceita ccusto
				EndIf
			EndIf
			If cCampo=="ZJC_CCCRE"//centro custo debito
				If cAcust=="1" 
					cRetorno := Posicione("ZA0", 1, xFilial("ZA0") + oModel:GetValue('ZJCDETAIL','ZJC_FILIT'), "ZA0_CUSTO")
				Else
					cRetorno :=""
				EndIf
			ElseIf cCampo=="ZJC_ITEMCR"//Item Contabil debito 
				If cAcitem=="1"
					cRetorno := Posicione("ZJA", 1, xFilial("ZJA") + oModel:GetValue('ZJCDETAIL','ZJC_FILIT'), "ZJA_ITEM")
				EndIf
			Else
				cRetorno :=""
			EndIf
		Endif

	EndIf

	Return cRetorno
	/*/{Protheus.doc} CTBX02POS(oModel)
	Rotina de Validação do botão CONFIRMA - TudoOK
	@author Jair Matos
	@since 17/05/2019
	@version P12
	@type function
	@return lRet
	/*/
Static Function CTBX02POS(oModel)
	Local lRet := .T.
	Local oModelxDet := oModel:GetModel('ZJCDETAIL') //Carregando grid de dados a partir o ID que foi instanciado no fonte.
	Local nX :=0
	Local nVlr100 := 0
	Local nVlr101 := 0
	If oModelxDet:GetOperation() == 3 .or. oModelxDet:GetOperation() == 4
		FOR nX := 1 TO oModelxDet:Length() 
			oModelxDet:GoLine( nX )
			IF !oModelxDet:IsDeleted() // Linha não deletada 
				If oModelxDet:GetValue("ZJC_NUM") =="100"
					nVlr100 += oModelxDet:GetValue("ZJC_VALOR")
				EndIf
				If oModelxDet:GetValue("ZJC_NUM") =="101"
					nVlr101 += oModelxDet:GetValue("ZJC_VALOR")
				EndIf
			EndIf
		NEXT nX
		If nVlr100 <> nVlr101
			lRet := .F. 
			HELP(' ',1,'Atenção!',,"Valores de Débitos e Créditos devem ser iguais.",1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no campo VALOR."})
		EndIf
		//+-------------------------------------------------------------------------------------+
		//! Se for uma exclusão, realiza a verificação de tabelas aqui                          !
		//+-------------------------------------------------------------------------------------+
	ElseIf oModelxDet:GetOperation() == MODEL_OPERATION_DELETE
		If ZJB->ZJB_STATUS=="1"
			lRet := .F. 
			HELP(' ',1,'Registro usado',,'Este registro não pode ser excluído, pois possui vinculo com outro(s) cadastro(s).',1,0)
		EndIf
	EndIf

	Return lRet
	/*/{Protheus.doc}  CTBX02V()
	Rotina de Validação dos campos ZJC_CTADEB e ZJC_CTACRE. Função criada no campo de Edição no Configurador.
	@author Jair Matos
	@since 20/05/2019
	@version P12
	@type function
	@return lRet
	/*/
User Function CTBX02V(cOpc)
	Local lRet := .F.
	Local oModelx := FWModelActive()
	Local oModelxDet := oModelx:GetModel('ZJCDETAIL') //Carregando grid de dados a partir o ID que foi instanciado no fonte.
	If !Empty(oModelxDet:GetValue("ZJC_NUM")) // verifica se campo de Lancamento padrao esta preenchido.
		If cOpc =="1" .and. (Posicione("CT5", 01, oModelxDet:GetValue("ZJC_FILIAL") + oModelxDet:GetValue("ZJC_NUM"), "CT5_DC")=="1")
			lRet := .T.
		ElseIf cOpc =="2" .and. (Posicione("CT5", 01, oModelxDet:GetValue("ZJC_FILIAL") + oModelxDet:GetValue("ZJC_NUM"), "CT5_DC")=="2")
			lRet := .T.
		EndIf
	EndIf
Return lRet  
/*/{Protheus.doc} ImportCSV
Função de importação de arquivo TXT
@author Jair Matos
@since 28/05/2019 
@version 1.0
@return Nil 
/*/
User Function ImportCSV()
	Local targetDir :=""
	Local cLinha := ""  
	Local nLinhas := 0
	Local aDados := {}
	Local nTamLinha := 0
	Local nTamArq:= 0
	Local cProxCod := ""
	Local lContinua := .T.
	Local nVlr100 := 0
	Local cVlr100 :=""
	Local i := 0

	targetDir 	:= cGetFile("*.csv |*.csv|*.txt|*.txt|","Selecione o arquivo...",0,'C:\',.T.,GETF_LOCALHARD+GETF_OVERWRITEPROMPT)

	//Valida arquivo
	If !file(targetDir)
		Aviso("Arquivo","Arquivo não selecionado ou invalido.",{"Sair"},1)
		Return
	Else     
		//+---------------------------------------------------------------------+
		//| Abertura do arquivo texto                                           |
		//+---------------------------------------------------------------------+
		nHdl := fOpen(targetDir)

		If nHdl == -1 
			IF FERROR()== 516 
				ALERT("Feche a planilha que gerou o arquivo.")
			EndIF
		EndIf

		//+---------------------------------------------------------------------+
		//| Verifica se foi possível abrir o arquivo                            |
		//+---------------------------------------------------------------------+
		If nHdl == -1
			cMsg := "O arquivo de nome "+targetDir+" nao pode ser aberto! Verifique os parametros."
			MsgAlert(cMsg,"Atencao!")
			Return
		Endif

		//+---------------------------------------------------------------------+
		//| Posiciona no Inicio do Arquivo                                      |
		//+---------------------------------------------------------------------+
		FSEEK(nHdl,0,0)

		//+---------------------------------------------------------------------+
		//| Traz o Tamanho do Arquivo TXT                                       |
		//+---------------------------------------------------------------------+
		nTamArq:=FSEEK(nHdl,0,2)

		//+---------------------------------------------------------------------+
		//| Posicona novamemte no Inicio                                        |
		//+---------------------------------------------------------------------+
		FSEEK(nHdl,0,0)

		//+---------------------------------------------------------------------+
		//| Fecha o Arquivo                                                     |
		//+---------------------------------------------------------------------+
		fClose(nHdl)
		FT_FUse(targetDir)  //abre o arquivo 
		FT_FGOTOP()         //posiciona na primeira linha do arquivo      
		nTamLinha := Len(FT_FREADLN()) //Ve o tamanho da linha
		FT_FGOTOP()

		//+---------------------------------------------------------------------+
		//| Verifica quantas linhas tem o arquivo                               |
		//+---------------------------------------------------------------------+
		nLinhas := nTamArq/nTamLinha

		ProcRegua(nLinhas)

		aDados:={}  
		While !FT_FEOF() //Ler todo o arquivo enquanto não for o final dele

			IncProc('Importando Linha: ' + Alltrim(Str(nLinhas)) )

			clinha := FT_FREADLN() 

			aadd(aDados,Separa(cLinha,";",.T.))

			FT_FSKIP()
		EndDo

		FT_FUse()
		fClose(nHdl)
	EndIf
	//Rotina para validação de todo o arquivo importado. caso haja erros em alguma linha, retorna FAlse e aborta a importação
	lContinua := ValArq(aDados)

	If lContinua
		ProcRegua(len(aDados)) 
		cProxCod := GetSXENum( "ZJB", "ZJB_COD" )
		//Grava novo registro Cabeçalho
		Reclock("ZJB",.T.)
		ZJB_COD := cProxCod//Codigo
		ZJB_DESC 	:= RetFileName(targetdir)  // identifica o nome do arquivo sem extensao
		ZJB_STATUS 	:= "0"//Status
		ZJB_ARQ		:= DTOS(DATE())+STRTRAN(TIME(),":")+".TXT" //nome do arquivo
		ZJB_DTINC	:= DDATABASE//data de inclusao 
		ZJB->(MsUnlock())
		For i := 2 to len(aDados)
			//Grava novo registro Item
			cVlr100:= StrTran( aDados[i,5],".", "" )//retira ponto
			cVlr100:= StrTran( cVlr100,",", "." )//retira virgula
			nVlr100:= Val(cVlr100)
			Reclock("ZJC",.T.)
			ZJC_COD := cProxCod
			ZJC_FILIT 	:= aDados[i,1]//Filial
			ZJC_NUM 	:= aDados[i,2]//Lancamento Padrão
			ZJC_CTADEB	:= aDados[i,3]//Conta Debito
			ZJC_CTACRE	:= aDados[i,4]//Conta Credito
			ZJC_VALOR	:= nVlr100//Valor
			ZJC_CCDEB	:= aDados[i,6]//Centro de Custo Debito
			ZJC_CCCRE	:= aDados[i,7]//Centro de Custo Credito
			ZJC_EBDEB	:= aDados[i,8]//Entidade Bancaria Debito
			ZJC_EBCRE	:= aDados[i,9]//Entidade Bancaria Credito
			ZJC_CVDEB	:= aDados[i,10]//Classe VAlor Debito
			ZJC_CVCRE	:= aDados[i,11]//Classe VAlor Credito
			ZJC_ITEMDE	:= aDados[i,12]//Item Contabil Debito
			ZJC_ITEMCR	:= aDados[i,13]//Item Contabil Credito
			ZJC_HISTO	:= aDados[i,14]//Historico
			ZJC->(MsUnlock())
		Next
		ConfirmSx8()
		Aviso("Atenção","Importação com exito!",{"Ok"},1)
	EndIf
	Return
	/*/{Protheus.doc} ValArq(aDados)
	Função de validação do arquivo TXT 
	@author Jair Matos
	@since 29/05/2019 
	@version 1.0
	@return lContinua 
	/*/
Static Function ValArq(aDados)
	Local lContinua		:= .T.
	Local cItobrg 		:= "" //Item obrigatorio
	Local cCCobrg 		:= "" //ccusto obrigatorio
	Local cBancOBR		:= "" //entidade bancaria obrigatorio
	Local cCLVLOBR		:= "" //Classe Valor obrigatorio
	Local cTipoConta 	:= ""
	Local nVlr100 := 0
	Local nVlr101 := 0
	Local cVlr100 :=""
	Local cVlr101 :=""
	Local i := 0

	//Valida todo o arquivo. Caso haja inconsistencia, o arquivo será rejeitado
	For i := 2 to len(aDados)
		cItobrg :=""
		cCCobrg :=""
		cBancOBR:=""
		cCLVLOBR:=""
		cTipoConta := ""
		If Empty(aDados[i,1]) .or. Empty(aDados[i,2]) .or. Empty(aDados[i,14])
			lContinua := .F.
			HELP(' ',1,'Atenção!',,"Filial / Lançamento padrão / Histórico não preenchidos na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
			Exit
		EndIf
		DbSelectArea("ADK")
		ADK->(DbSetOrder(1))
		If ADK->(DbSeek(xFilial("ADK")+aDados[i,1])) 
			lContinua := .F.
			HELP(' ',1,'Atenção!',,"Filial inválida na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
			Exit
		EndIf
		DbSelectArea("CT5")
		CT5->(DbSetOrder(1))
		If CT5->(DbSeek(xFilial("CT5")+aDados[i,2]))  
			cTipoConta := CT5->CT5_DC
		EndIf

		If Empty(cTipoConta)
			lContinua := .F.
			HELP(' ',1,'Atenção!',,"Lançamento Padrão inválido na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
			Exit
		EndIf		

		If cTipoConta =="1"//Debito
			If Empty(aDados[i,3])
				lContinua := .F.
				HELP(' ',1,'Atenção!',,"Conta Debito não preenchida na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
				Exit
			Else
				DbSelectArea("CT1")
				CT1->(DbSetOrder(1))// CT1_FILIAL+CT1_CONTA
				If CT1->(DbSeek(xFilial("CT1")+aDados[i,3]))  
					cItobrg :=CT1->CT1_ITOBRG //Item obrigatorio
					cCCobrg :=CT1->CT1_CCOBRG //ccusto obrigatorio
					cBancOBR:=CT1->CT1_05OBRG //entidade bancaria obrigatorio
					cCLVLOBR:=CT1->CT1_CLOBRG //Classe Valor obrigatorio
				Else
					lContinua := .F.
					HELP(' ',1,'Atenção!',,"Conta Debito inválida na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
					Exit
				EndIf
			EndIf
			If cCCobrg=="1" 
				If	Empty(aDados[i,6])//centro custo debito
					lContinua := .F.
					HELP(' ',1,'Atenção!',,"Centro de Custo Debito não preenchido na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
					Exit
				Else
					DbSelectArea("ZA0")
					ZA0->(DbSetOrder(1))
					If !ZA0->(DbSeek(xFilial("ZA0")+aDados[i,1]+aDados[i,6]))  
						lContinua := .F.
						HELP(' ',1,'Atenção!',,"Centro de Custo Debito invalido na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
						Exit	
					EndIf
				EndIf
			EndIf
			If cItobrg=="1" 
				If Empty(aDados[i,12])//Item Contabil debito 
					lContinua := .F.
					HELP(' ',1,'Atenção!',,"Item Contabil Debito não preenchido na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
					Exit
				Else
					DbSelectArea("ZJA")
					ZJA->(DbSetOrder(1))
					If !ZJA->(DbSeek(xFilial("ZJA")+aDados[i,1]+aDados[i,12]))  
						lContinua := .F.
						HELP(' ',1,'Atenção!',,"Item Contabil Debito invalido na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
						Exit	
					EndIf
				EndIf
			EndIf
			If cBancOBR=="1" 
				If Empty(aDados[i,8])//Entidade bancaria debito 
					lContinua := .F.
					HELP(' ',1,'Atenção!',,"Entidade bancaria Debito não preenchido na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
					Exit
				Else
					DbSelectArea("CV0")
					CV0->(DbSetOrder(1))//CV0_FILIAL+CV0_PLANO+CV0_CODIGO
					If !CV0->(DbSeek(xFilial("CV0")+"05"+aDados[i,8]))  
						lContinua := .F.
						HELP(' ',1,'Atenção!',,"Entidade Bancaria Debito invalida na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
						Exit	
					EndIf
				EndIf
			EndIf
			If cCLVLOBR=="1" 
				If Empty(aDados[i,10])//Classe Valor debito 
					lContinua := .F.
					HELP(' ',1,'Atenção!',,"Classe Valor Debito não preenchido na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
					Exit
				Else
					DbSelectArea("CTH")
					CTH->(DbSetOrder(1))//CV0_FILIAL+CV0_PLANO+CV0_CODIGO
					If !CTH->(DbSeek(xFilial("CTH")+aDados[i,10]))  
						lContinua := .F.
						HELP(' ',1,'Atenção!',,"Classe Valor Debito invalida na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
						Exit	
					EndIf
				EndIf
			EndIf
			cVlr100:= StrTran( aDados[i,5],",", "" )//retira virgula
			cVlr100:= StrTran( cVlr100,".", "" )//retira ponto
			nVlr100+= Val(cVlr100)
		ElseIf cTipoConta =="2"//Credito		
			If Empty(aDados[i,4])
				lContinua := .F.
				HELP(' ',1,'Atenção!',,"Conta Credito não preenchido na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
				Exit
			Else
				DbSelectArea("CT1")
				CT1->(DbSetOrder(1))// CT1_FILIAL+CT1_CONTA
				If CT1->(DbSeek(xFilial("CT1")+aDados[i,4]))  
					cItobrg :=CT1->CT1_ITOBRG //Item obrigatorio
					cCCobrg :=CT1->CT1_CCOBRG //ccusto obrigatorio
					cBancOBR:=CT1->CT1_05OBRG //entidade bancaria obrigatorio
					cCLVLOBR:=CT1->CT1_CLOBRG //Classe Valor obrigatorio
				Else
					lContinua := .F.
					HELP(' ',1,'Atenção!',,"Conta Credito inválida na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
					Exit
				EndIf
			EndIf
			If cCCobrg=="1" 
				If Empty(aDados[i,7])//centro custo credito
					lContinua := .F.
					HELP(' ',1,'Atenção!',,"Centro de Custo Credito não preenchido na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
					Exit
				Else
					DbSelectArea("ZA0")
					ZA0->(DbSetOrder(1))
					If !ZA0->(DbSeek(xFilial("ZA0")+aDados[i,1]+aDados[i,7]))  
						lContinua := .F.
						HELP(' ',1,'Atenção!',,"Centro de Custo Credito invalido na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
						Exit	
					EndIf
				EndIf
			EndIf
			If cItobrg=="1" 
				If Empty(aDados[i,13])//Item Contabil credito 
					lContinua := .F.
					HELP(' ',1,'Atenção!',,"Item Contabil Credito não preenchido na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
					Exit
				Else
					DbSelectArea("ZJA")
					ZJA->(DbSetOrder(1))
					If !ZJA->(DbSeek(xFilial("ZJA")+aDados[i,1]+aDados[i,13]))  
						lContinua := .F.
						HELP(' ',1,'Atenção!',,"Item Contabil Credito invalido na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
						Exit	
					EndIf
				EndIf
			EndIf
			If cBancOBR=="1" 
				If Empty(aDados[i,9])//Entidade bancaria credito 
					lContinua := .F.
					HELP(' ',1,'Atenção!',,"Entidade bancaria Credito não preenchido na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
					Exit
				Else
					DbSelectArea("CV0")
					CV0->(DbSetOrder(1))//CV0_FILIAL+CV0_PLANO+CV0_CODIGO
					If !CV0->(DbSeek(xFilial("CV0")+"05"+aDados[i,9]))  
						lContinua := .F.
						HELP(' ',1,'Atenção!',,"Entidade Bancaria Credito invalida na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
						Exit	
					EndIf
				EndIf
			EndIf
			If cCLVLOBR=="1" 
				If Empty(aDados[i,11])//Classe Valor credito 
					lContinua := .F.
					HELP(' ',1,'Atenção!',,"Classe Valor Credito não preenchido na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
					Exit
				Else
					DbSelectArea("CTH")
					CTH->(DbSetOrder(1))//CV0_FILIAL+CV0_PLANO+CV0_CODIGO
					If !CTH->(DbSeek(xFilial("CTH")+aDados[i,11]))  
						lContinua := .F.
						HELP(' ',1,'Atenção!',,"Classe Valor Credito invalida na linha "+Alltrim(Str(i)),1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no arquivo de importação."})
						Exit	
					EndIf
				EndIf
			EndIf
			cVlr101:= StrTran( aDados[i,5],",", "" )//retira virgula
			cVlr101:= StrTran( cVlr101,".", "" )//retira ponto
			nVlr101+= Val(cVlr101)
		EndIf
	Next
	If nVlr100 <> nVlr101 .AND. lContinua
		lContinua := .F.
		HELP(' ',1,'Atenção!',,"Valores de Débitos e Créditos devem ser iguais.",1,0, NIL, NIL, NIL, NIL, NIL, {"Proceda a correção no campo VALOR."})
	EndIf
Return lContinua
