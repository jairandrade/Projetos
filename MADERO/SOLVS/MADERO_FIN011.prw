#include "protheus.ch"
#include "fwmvcdef.ch"

Static bLoadGrd := {}
Static aCampos  := {}
Static cNumero  := ""
Static _oFINA171
/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Customização                                            !
+------------------+---------------------------------------------------------+
!Modulo            ! FIN                                                     !
+------------------+---------------------------------------------------------+
!Nome              ! FIN011                                                	 !
+------------------+---------------------------------------------------------+
!Descricao         ! Emprestimo Financeiro                                   !
+------------------+---------------------------------------------------------+
!Autor             ! Valtenio Moura                                          !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 28/06/2018                                              !
+------------------+---------------------------------------------------------+
*/

User Function FIN011
	Private aRotina := MenuDef()
	Private cCadastro := "Atual.Aplicações/Emprést."

	SetKey(VK_F12, {|| Pergunte("AFI171", .T.)})
	Pergunte("AFI171", .F.)

	mBrowse(Nil, Nil, Nil, Nil, "SEH", Nil, Nil, Nil, Nil, Nil, Fa171Legenda())  

	SetKey(VK_F12 , Nil )
Return

Static Function MenuDef
Local aRot 		:= StaticCall(FINA171, MenuDef)
Local nInd 		:= 0
Local aVsuMnu 	:= {"Teste Visualizacao", "U_GeraEmpMnu", 0, 9} //Visusalizacao personalizada das parcelas

aAdd(aRot, aVsuMnu)
nInd := aScan(aRot, {|aBut| Upper(aBut[2]) == "A171INCLUI"})
If nInd > 0
	aRot[nInd][2] := "U_MadEmpInc"
EndIf
Return aRot


User Function MadEmpInc(cAlias, nReg)
Local nOpc := 9
Private cChvMad := CriaTrab(Nil, .F.)
FinA171(3)
If SEH->EH_APLEMP == "EMP"
	If SEH->EH_TAXA > 0
		If U_Chave171() .and. APMsgYesNo("Altera valores e vencimentos?", "ESCOLHA") //confirmou
			//AltParc()
			U_FIN010()
		EndIf
	Else
		if U_Chave171() .And. EmpFC171Par(SEH->EH_NUMERO,nOpc)
			FCGrvE2('TRB', SEH->EH_NUMERO)
			U_FIN010()
		endIf
	EndIf
Endif
Return



User Function GeraEmpMnu(cAlias, nReg, nOpc)

Local cTitulo    := ""
Local cPrograma  := 'MADERO_FIN011'
Local nOperation := MODEL_OPERATION_VIEW
Local lRet		   := .T.
Local nOpc		   := 9

//Apresenta uma tela demonstrando os valores do Contrato bem como o valor que deverá ser pago em cada parcela
If SEH->EH_TIPO == 'EMP' .And. !Empty(SEH->EH_AMORTIZ)

	cNumero := SEH->EH_NUMERO
	//Carrega as parcelas no arquivo temporario
	MsgRun("Aguarde, realizando o calculo das parcelas...",, { || lRet := EmpFC171Par(cNumero,nOpc) }  ) //"Aguarde, realizando o calculo das parcelas...
EndIf

If lRet
	// Chama a view da tabela SEH
	lRetorna := FWExecView(cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, /*oModel*/ )
EndIf

Return()

//------------------------------------------------------------------------------------------
/*/ {Protheus.doc} FC171Par
Realiza o calculo das parcelas para apresentacao em tela

@author    Ronaldo Tapia
@version   11.80
@since     24/06/2016
@protected
/*/
//------------------------------------------------------------------------------------------

Static Function EmpFC171Par(cNumero,nOpc)

Local lRet		 := .T.
Local aCalculo := {}
Local dDataVenc:= STOD("")
Local dPrimVenc:= STOD("")
Local lPriParc := .T.
Local nParcela := 1
Local nI		 := 1	
Local nValAmor := 0
Local nValCorr := 0
Local nValDeb  := 0
Local nValJuros:= 0
Local nValPrest:= 0
Local nTotJuros:= 0
Local nTotPrest:= 0
Local cAliasTab:= ""
Local i		 := 1
Local lCarencia:= .F.
Local lRetCar  := .T.
Local cTPCaren := SuperGetMV("MV_TPCAREN",.F.,"1")

// Array com os campos utilizados na view
Local aCampos := {;
	{"PARCELA   ","N", 3,0},;
	{"DATAX     ","D", 8,0},;
	{"VALOR     ","N",14,2},;
	{"JUROS     ","N",14,2},;
	{"VCORRIGIDO","N",14,2},;
	{"AMORTIZA  ","N",14,2},;
	{"PRESTACAO ","N",14,2} }
	
Default cNumero := SEH->EH_NUMERO

//Limpa o codeblock bLoadGrd
If len(bLoadGrd) > 0
	aSize(bLoadGrd,0)
EndIf

// Verifica se já teve movimentação para o empréstimo e aborta visualização
If nOpc == 9
	dbSelectArea("SEI")
	SEI->(DbSetOrder(1))
	If SEI->(DbSeek(xFilial("SEI")+"EMP"+cNumero)) 
		//IW_MsgBox(STR0035,STR0017, "INFO" ) // //"Emprestimo Financeiro"
		Return .F.
	EndIf
EndIf

// Se o emprestimo não tem parcelas geradas não mostro a projeção das parcelas em tela.
If nOpc == 9
	dbSelectArea("SE2")
	SE2->(dbSetOrder(1))	//Prefixo+Numero+Parcela
	If !(SE2->(DbSeek(xFilial("SE2")+"EMP"+cNumero)))
		IW_MsgBox("Empréstimo não possui parcelas.", "INFO" ) // //"Emprestimos não possui parcelas."
		Return .F.
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria arquivo de Trabalho   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If(_oFINA171 <> NIL)
			_oFINA171:Delete()
			_oFINA171 := NIL
		EndIf

		_oFINA171 := FwTemporaryTable():New("TRB")
		_oFINA171:SetFields(aCampos)
		_oFINA171:AddIndex("1",{"PARCELA"})
		_oFINA171:Create()


		While !SE2->( Eof() ) .And. SE2->E2_FILIAL == xFilial("SE2") .And. Alltrim(SE2->E2_PREFIXO) == "EMP" .And. AllTrim(SE2->E2_NUM) == cNumero
			nParcela 	:= SE2->E2_PARCELA
			dDataVenc	:= SE2->E2_VENCTO
			nValDeb		:= SE2->E2_SALDO - SE2->E2_JUROS
			nValJuros	:= SE2->E2_JUROS
			nValCorr	:= SE2->E2_SALDO
			nValAmor	:= SE2->E2_SALDO - SE2->E2_JUROS
			nValPrest	:= SE2->E2_SALDO
			RecLock( "TRB", .T. )
				REPLACE PARCELA		WITH	val(nParcela)
				REPLACE DATAX      	WITH	dDataVenc
				REPLACE VALOR		WITH	nValDeb
				REPLACE JUROS		WITH	nValJuros
				REPLACE VCORRIGIDO	WITH	nValCorr
				REPLACE AMORTIZA	WITH	nValAmor
				REPLACE PRESTACAO	WITH	nValPrest
			msUnlock()

			nTotJuros += nValJuros
			nTotPrest += nValPrest
			SE2->(DbSkip())
		EndDo
		// Grava o total do emprestimo/financiamento no temporario
		RecLock( "TRB", .T. )
		REPLACE PARCELA		WITH	999
		REPLACE VALOR			WITH	0
		REPLACE JUROS			WITH	nTotJuros
		REPLACE VCORRIGIDO	WITH	0
		REPLACE AMORTIZA		WITH	SEH->EH_SALDO
		REPLACE PRESTACAO		WITH	nTotPrest
		msUnlock()	
	Endif
Endif

/******************************************************/
/*Grava os valores do temporario no codeblock bLoadGrd*/
/******************************************************/
TRB->(dbGoTop())
While !TRB->(eof())
	aAdd(bLoadGrd,{0,{TRB->PARCELA, TRB->DATAX, TRB->VALOR, TRB->JUROS,TRB->VCORRIGIDO ,TRB->AMORTIZA ,TRB->PRESTACAO}})
	TRB->(dbSkip())
Enddo


If nOpc <> 3
	// Fecha o arquivo temporario
	If(_oFINA171 <> NIL)
		_oFINA171:Delete()
		_oFINA171 := NIL
	EndIf
EndIf

Return lRet  //Static Function FC171Par

//------------------------------------------------------------------------------------------
/* {Protheus.doc} ModelDef
Monta a tela demonstrando os valores do Contrato bem como o valor que deverá ser pago
em cada parcela (ou amortizado a cada mês).
@author    Ronaldo Tapia
@version   11.80
@since     24/06/2016
@protected
*/
//------------------------------------------------------------------------------------------

Static Function ModelDef()

// Cria as estruturas a serem usadas no Modelo de Dados
Local oStruSEH  := FWFormStruct(1, 'SEH')
Local oStruFLY1 := MontaSCab()
Local oModel    

// Posiciona no arquivo correto
dbSelectArea("SEH")
SEH->(MsSeek(xFilial("SEH")+cNumero))

// Code block com as parcelas do financiamento/emprestimo
bLoad := {|oGridModel, lCopy| bLoadGrd}

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('MADERO_FIN011')
//oModel := MPFormModel():New( 'FINA171', ,{ |oModel| FCTeste( oModel ) } )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'SEHMASTER', /*cOwner*/, oStruSEH )
	
//Adiciona ao modelo um componente de grid
oModel:AddGrid( 'FLYDETAIL', 'SEHMASTER', oStruFLY1,,,,,bLoad)
	
//Criação de relação entre as entidades do modelo (SetRelation)
oModel:SetRelation( 'FLYDETAIL', { { 'EH_FILIAL', 'xFilial( "SEH" )' }, { 'EH_NUMERO' , 'EH_NUMERO'  } } , SEH->( IndexKey( 1 ) )  )
	
// Adiciona a descrição do Modelo de Dados
oModel:SetDescription("Detalhe do valor do contrato e suas parcelas") //"Detalhe do valor do contrato e suas parcelas"

// Adiciona a descrição dos Componentes do Modelo de Dados
oModel:GetModel( 'SEHMASTER' ):SetDescription("Detalhe do Emprestimo/Financiamento") //"Detalhe do Emprestimo/Financiamento"
oModel:GetModel( 'FLYDETAIL' ):SetDescription("Projeção de valor das parcelas do contrato") //"Projeção de valor das parcelas do contrato"
	
//Define uma chave primaria (obrigatorio mesmo que vazia)	
oModel:SetPrimaryKey( {} )

Return oModel

//------------------------------------------------------------------------------------------
/* {Protheus.doc} ViewDef
Visualiza a tela demonstrando os valores do Contrato

@author    Ronaldo Tapia
@version   11.80
@since     24/06/2016
@protected
*/
//------------------------------------------------------------------------------------------

Static Function ViewDef()

// Cria as estruturas a serem usadas na View
Local oStruSEH  := FWFormStruct(2, 'SEH')
Local oStruFLY1 := MontaSView()
Local cConsSEH  := "EH_VALOR;EH_ENTRADA;EH_FINANC;EH_PRAZO;EH_CARENCI;EH_AMORTIZ,EH_NUMERO;EH_NBANCO;EH_TAXA;EH_TXEFETI;EH_VLAMORP"
Local aStruSEH  := SEH->(DbStruct())
Local nAtual    := 0

// Interface de visualização construída
Local oView  

//Percorre a estrutura da SEH para remover os campos que não irão aparecer na cabecalho
For nAtual := 1 To Len(aStruSEH)
	//Se o campo atual não estiver nos que forem considerados
	If ! Alltrim(aStruSEH[nAtual][01]) $ cConsSEH
		oStruSEH:RemoveField(aStruSEH[nAtual][01])
	EndIf
Next

// Cria o objeto de View
oView := FWFormView():New()

// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
oModel := FWLoadModel( 'MADERO_FIN011' )

// Adiciona botões
oView:AddUserButton("Definir Fornecedor", 'FORNECE', {|oView| FC171Fornece(oView) } )	//"Definir Fornecedor"

// Define qual Modelo de dados será utilizado
oView:SetModel( oModel )
		
// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
oView:AddField( 'VIEW_SEH', oStruSEH, 'SEHMASTER' )
	
//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'VIEW_FLY', oStruFLY1, 'FLYDETAIL' )
	
// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 33 )
oView:CreateHorizontalBox( 'INFERIOR', 67 )
		
// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_SEH', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_FLY', 'INFERIOR' )
	
// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_SEH' )
oView:EnableTitleView( 'VIEW_FLY' )

// Nao exibe a mensagem de atualizacao
oView:ShowUpdateMsg(.F.)		

Return oView



//-------------------------------------------------------------------
/*/{Protheus.doc} MontaSCab()
Retorna estrutura do tipo FWformModelStruct.

@author Ronaldo Tapia

@since 27/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------

Static function MontaSCab()

Local aArea    := GetArea()
Local oStruct := FWFormModelStruct():New()

// Tabela
oStruct:AddTable('SEH',{'PARCELA','DATAX','VALOR','JUROS','VCORRIGIDO','AMORTIZA','PRESTACAO'},"Cabeçalho do TRB")// Campos do cabeçalho do TRB

// Campos
oStruct:AddField(	"Parcela"					,; 	// [01] C Titulo do campo
					"Parcela"					,; 	// [02] C ToolTip do campo
					"PARCELA"	 				,; 	// [03] C identificador (ID) do Field
					"N" 						,; 	// [04] C Tipo do campo
					3							,; 	// [05] N Tamanho do campo
					0 							,; 	// [06] N Decimal do campo
					Nil 						,; 	// [07] B Code-block de validação do campo
					Nil							,; 	// [08] B Code-block de validação When do campo
					Nil 						,; 	// [09] A Lista de valores permitido do campo
			      	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
					Nil							,; 	// [11] B Code-block de inicializacao do campo
					Nil 						,;	// [12] L Indica se trata de um campo chave
					.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
					.F. )  	            		// [14] L Indica se o campo é virtual
					
oStruct:AddField(	"Vencimento"						,; 	// [01] C Titulo do campo
					"Vencimento"						,; 	// [02] C ToolTip do campo
					"DATA" 					,; 	// [03] C identificador (ID) do Field
					"D" 						,; 	// [04] C Tipo do campo
					8							,; 	// [05] N Tamanho do campo
					0 							,; 	// [06] N Decimal do campo
					Nil 						,; 	// [07] B Code-block de validação do campo
					Nil							,; 	// [08] B Code-block de validação When do campo
					Nil 						,; 	// [09] A Lista de valores permitido do campo
			      	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
					Nil							,; 	// [11] B Code-block de inicializacao do campo
					Nil 						,;	// [12] L Indica se trata de um campo chave
					.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
					.F. )  	            		// [14] L Indica se o campo é virtual	
					
oStruct:AddField(	"Valor do Debito"			,; 	// [01] C Titulo do campo
					"Valor do Debito"			,; 	// [02] C ToolTip do campo
					"VALOR" 					,; 	// [03] C identificador (ID) do Field
					"N" 						,; 	// [04] C Tipo do campo
					14							,; 	// [05] N Tamanho do campo
					2							,; 	// [06] N Decimal do campo
					Nil 						,; 	// [07] B Code-block de validação do campo
					Nil							,; 	// [08] B Code-block de validação When do campo
					Nil 						,; 	// [09] A Lista de valores permitido do campo
			      	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
					Nil							,; 	// [11] B Code-block de inicializacao do campo
					Nil 						,;	// [12] L Indica se trata de um campo chave
					.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
					.F. )  	            		// [14] L Indica se o campo é virtual	
					
oStruct:AddField(	"Juros"					,; 	// [01] C Titulo do campo
					"Juros"					,; 	// [02] C ToolTip do campo
					"JUROS" 					,; 	// [03] C identificador (ID) do Field
					"N" 						,; 	// [04] C Tipo do campo
					14							,; 	// [05] N Tamanho do campo
					2							,; 	// [06] N Decimal do campo
					Nil 						,; 	// [07] B Code-block de validação do campo
					Nil							,; 	// [08] B Code-block de validação When do campo
					Nil 						,; 	// [09] A Lista de valores permitido do campo
			      	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
					Nil							,; 	// [11] B Code-block de inicializacao do campo
					Nil 						,;	// [12] L Indica se trata de um campo chave
					.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
					.F. )  	            		// [14] L Indica se o campo é virtual	
	
oStruct:AddField(	"Valor Corrigido"			,; 	// [01] C Titulo do campo
					"Valor Corrigido"			,; 	// [02] C ToolTip do campo
					"VCORRIGIDO"				,; 	// [03] C identificador (ID) do Field
					"N" 						,; 	// [04] C Tipo do campo
					14							,; 	// [05] N Tamanho do campo
					2							,; 	// [06] N Decimal do campo
					Nil 						,; 	// [07] B Code-block de validação do campo
					Nil							,; 	// [08] B Code-block de validação When do campo
					Nil 						,; 	// [09] A Lista de valores permitido do campo
			      	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
					Nil							,; 	// [11] B Code-block de inicializacao do campo
					Nil 						,;	// [12] L Indica se trata de um campo chave
					.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
					.F. )  	            		// [14] L Indica se o campo é virtual	

oStruct:AddField(	"Amortização"					,; 	// [01] C Titulo do campo
					"Amortização"					,; 	// [02] C ToolTip do campo
					"AMORTIZA" 				,; 	// [03] C identificador (ID) do Field
					"N" 						,; 	// [04] C Tipo do campo
					14							,; 	// [05] N Tamanho do campo
					2 							,; 	// [06] N Decimal do campo
					Nil 						,; 	// [07] B Code-block de validação do campo
					Nil							,; 	// [08] B Code-block de validação When do campo
					Nil 						,; 	// [09] A Lista de valores permitido do campo
			      	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
					Nil							,; 	// [11] B Code-block de inicializacao do campo
					Nil 						,;	// [12] L Indica se trata de um campo chave
					.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
					.F. )  	            		// [14] L Indica se o campo é virtual	
	
oStruct:AddField(	"Prestação"				,; 	// [01] C Titulo do campo
					"Prestação"				,; 	// [02] C ToolTip do campo
					"PRESTACAO"				,; 	// [03] C identificador (ID) do Field
					"N" 						,; 	// [04] C Tipo do campo
					14							,; 	// [05] N Tamanho do campo
					2							,; 	// [06] N Decimal do campo
					Nil 						,; 	// [07] B Code-block de validação do campo
					Nil							,; 	// [08] B Code-block de validação When do campo
					Nil 						,; 	// [09] A Lista de valores permitido do campo
			      	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigatório
					Nil							,; 	// [11] B Code-block de inicializacao do campo
					Nil 						,;	// [12] L Indica se trata de um campo chave
					.T.		 					,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
					.F. )  	            		// [14] L Indica se o campo é virtual		
					
// Indices
oStruct:AddIndex( 	1	      						, ;     // [01] Ordem do indice
					"01"   							, ;     // [02] ID
					"PARCELA"				  		    , ; 	 // [03] Chave do indice
					"Indice 1" + " + " + "Parcela"	, ;     // [04] Descrição do indice
					""       							, ;   	 // [05] Expressão de lookUp dos campos de indice (SIX_F3)
					"" 									, ;   	 // [06] Nickname do indice
					.T. )      								 // [07] Indica se o indice pode ser utilizado pela interface
					
oStruct:AddIndex( 	2	      						, ;     // [01] Ordem do indice
					"02"   							, ;     // [02] ID
					"DATAX"				  		    , ; 	 // [03] Chave do indice
					"Indice 2" + " + " + "Data"		, ;     // [04] Descrição do indice
					""       							, ;     // [05] Expressão de lookUp dos campos de indice (SIX_F3)
					"" 									, ;     // [06] Nickname do indice
					.T. )    

RestArea( aArea )

Return oStruct   

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaSView()
Retorna estrutura do tipo FWFormViewStruct.

@author Ronaldo Tapia

@since 27/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------

Static function MontaSView()
Local oStruct   := FWFormViewStruct():New()

		/* Estutura para a criação de campos na view	
		
			[01] C Nome do Campo
			[02] C Ordem
			[03] C Titulo do campo  
			[04] C Descrição do campo  
			[05] A Array com Help
			[06] C Tipo do campo
			[07] C Picture
			[08] B Bloco de Picture Var
			[09] C Consulta F3
			[10] L Indica se o campo é editável
			[11] C Pasta do campo
			[12] C Agrupamento do campo
			[13] A Lista de valores permitido do campo (Combo)
			[14] N Tamanho Maximo da maior opção do combo
			[15] C Inicializador de Browse
			[16] L Indica se o campo é virtual
			[17] C Picture Variável
	
		*/

// Campos
oStruct:AddField("PARCELA","01","Parcela","Parcela",{},"N","@E 999",/*bPictVar*/,/*cLookUp*/,.T.) 
oStruct:AddField("DATA","03","Vencimento","Vencimento",{},"D","@!",/*bPictVar*/,/*cLookUp*/,.T.) 
oStruct:AddField("VALOR","03","Valor do Debito","Valor",{},"N","@E 999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) 
oStruct:AddField("JUROS","04","Juros","Juros",{},"N","@E 999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) 
oStruct:AddField("VCORRIGIDO","05","Valor Corrigido","Valor Corrigido",{},"N","@E 999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) 
oStruct:AddField("AMORTIZA","06","Amortização","Amortização",{},"N","@E 999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) 
oStruct:AddField("PRESTACAO","07","Prestação","Prestação",{},"N","@E 999,999,999.99",/*bPictVar*/,/*cLookUp*/,.T.) 

Return oStruct

//------------------------------------------------------------------------------------------
/* {Protheus.doc} FCGrvE2
Função para gravação das parcelas no contas a pagar (SE2)

@author    Ronaldo Tapia
@version   11.80
@since     04/07/2016
@protected
*/
//------------------------------------------------------------------------------------------

Static Function FCGrvE2(cArqTmp,cNumero)

Local aArray	:= {}
Local cParcela	:= ""
Local dData		:= STOD("")
Local nValor	:= 0
Local nJuros	:= 0
Local aArea		:= GetArea()
Local nTamFor	:= TamSX3("E2_FORNECE")[1]
Local cForPar	:= PadR(SuperGetMV("MV_FOREMPR",.F.,"000001"),nTamFor)
Local nNumReg	:= Len(bLoadGrd)
Local nTotVal	:= 0
Local cForLj 	:= SA2->A2_LOJA
Local cCodFor 	:= SA2->A2_COD
Local dDataVenc:= STOD("")
Local dPrimVenc:= STOD("")
Local lPriParc := .T.
 
Private lMsErroAuto := .F.

dPrimVenc := DaySum(SEH->EH_DATA,30)
dDataVenc := DaySum(SEH->EH_DATA,30)

(cArqTmp)->(dbGoTop())
While (cArqTmp)->(!EOF()) 

	BEGIN TRANSACTION
	
	// Alimenta barra de progresso
   IncProc("Gravando Parcela:"+cParcela) //"Gravando Parcela: "                 

	cParcela	:= cValtoChar((cArqTmp)->PARCELA)
	dData		:= (cArqTmp)->DATAX
	nValor		:= (cArqTmp)->PRESTACAO
	nJuros		:= (cArqTmp)->JUROS
	
	// Tratamento para parcelas com carência, grava somente o valor dos juros
	If (cArqTmp)->AMORTIZA == 0 .And. (cArqTmp)->JUROS > 0
		nValor := 0.01
	EndIf
 
 	// Ajusta valor da última parcela
 	If cParcela == cValtoChar(nNumReg - 1)
 		If nTotVal + (cArqTmp)->AMORTIZA < SEH->EH_FINANC
 			nValor := Round(SEH->EH_FINANC - nTotVal,2) + (cArqTmp)->JUROS
 		EndIf
 	EndIf

	aArray := {	{ "E2_PREFIXO"  , "EMP"             , NIL },;
					{ "E2_NUM"      , SEH->EH_NUMERO    , NIL },;
					{ "E2_PARCELA"  , cParcela          , NIL },;
					{ "E2_TIPO"     , "PR"              , NIL },;
					{ "E2_NATUREZ"  , SEH->EH_NATUREZA  , NIL },;
            		{ "E2_FORNECE"  , cCodFor           , NIL },;
            		{ "E2_LOJA"		, cForLj           , NIL },;
            		{ "E2_EMISSAO"  , SEH->EH_DATA		, NIL },;
            		{ "E2_VENCTO"   , dData				, NIL },;
            		{ "E2_VENCREA"  , dData				, NIL },;
            		{ "E2_JUROS"    , nJuros			, NIL },;
            		{ "E2_VALOR"    , nValor			, NIL },;
					{ "E2_ORIGEM"   , "FINA171"			, NIL } }
	
	nTotVal += (cArqTmp)->AMORTIZA
     
	// Só grava a parcela se for diferente de 999 e maior que zero
	If cParcela <> "999" .And. nValor > 0    
		// Grava os valores no SE2
		MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
		If lMsErroAuto
    		MostraErro()
			DisarmTransaction()
		Endif
	EndIf
		
	END TRANSACTION

	If lMsErroAuto
		Exit
	Endif

	(cArqTmp)->(dbSkip())
EndDo
 
// Mostra erro
If !lMsErroAuto
	// IW_MsgBox(STR0031,STR0017, "INFO" ) //"Parcelas incluídas com sucesso!" //"Emprestimo Financeiro"
Endif

// Fecha o arquivo temporario
If(_oFINA171 <> NIL)
	_oFINA171:Delete()
	_oFINA171 := NIL
EndIf

RestArea(aArea)


Return	
