#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TopConn.ch"
/*
+----------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Rotina                                                  !
+------------------+---------------------------------------------------------+
!Modulo            ! Contabilidade Gerencial                                 !
+------------------+---------------------------------------------------------+
!Nome              ! ACTB002				                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Amarração de Filial x Itens Contabeis.			    	 !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos de Andrade		                             !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 19/02/2019                                              !
+------------------+---------------------------------------------------------+
!   Descricao detalhada da atualizacao      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
! 											!           !           !		 !
! 			                                !   	    !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/
User Function ACTB002()

Local oBrowse := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("ZJA")
oBrowse:SetDescription("Filial X Itens Contabeis")
oBrowse:SetMenuDef("MADERO_ACTB002")
oBrowse:Activate()

Return

Static Function MenuDef()

Local aRotina := {}

aAdd(aRotina,{'Visualizar'	,'VIEWDEF.MADERO_ACTB002'	,0,2,0,NIL})
aAdd(aRotina,{'Incluir'		,'U_ACTB02IN()'				,0,3,0,NIL})
aAdd(aRotina,{'Alterar'		,'VIEWDEF.MADERO_ACTB002'	,0,4,0,NIL})
aAdd(aRotina,{'Excluir'		,'VIEWDEF.MADERO_ACTB002'	,0,5,0,NIL})
aAdd(aRotina,{'Imprimir' 	,'VIEWDEF.MADERO_ACTB002'	,0,8,0,NIL})

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Jair Matos
@since 19/02/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStr1:= FWFormStruct(1,'ZJA')

oModel := MPFormModel():New('ACTB002_MAIN', , { |oModel| U_VALFILIT() } )
oModel:SetDescription('Filial X Item')

oStr1:AddTrigger( 'ZJA_FILIT', 'ZJA_NOMFIL'	, { || .T. }, {|oModel| PadR(FWFilialName(,FWFldGet("ZJA_FILIT")),TamSx3('ZJA_NOMFIL')[01])} )
oStr1:AddTrigger( 'ZJA_ITEM', 'ZJA_DESC'	, { || .T. }, {|oModel| Posicione("CTD",1,xFilial("CTD")+FWFldGet("ZJA_ITEM"),"CTD_DESC01") } )

oModel:addFields('MODEL_ZJA',,oStr1)
oModel:SetPrimaryKey({ 'ZJA_FILIAL', 'ZJA_FILIT', 'ZJA_ITEM' })

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Jair Matos
@since 19/02/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel := ModelDef()
Local oStr1:= FWFormStruct(2, 'ZJA')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_ZJA' , oStr1,'MODEL_ZJA' )
oView:CreateHorizontalBox( 'BOX_ZJA', 100)
oView:SetOwnerView('VIEW_ZJA','BOX_ZJA')

Return oView

/*/{Protheus.doc} VALFILIT
//TODO Validação se ja existe Filial X ITEM cadastrada
@author Jair Matos
@since 19/02/2019
@version P12
@return lRet, Logico, .T. - valida e .F. - Não Valida
/*/
User Function VALFILIT()

Local oModel 	:= FWModelActive()
Local oView		:= FWViewActive()
Local lRet		:= .T.
Local cAliasIC	:= ""

If oModel:GetOperation() == 3
	
	cAliasIC := GetFilIT(FWFldGet("ZJA_FILIT"),FWFldGet("ZJA_ITEM"))
	If !(cAliasIC)->(Eof())
		Help( ,, 'Filial x Item',, 'Já existe cadastro para esta Filial X Item', 1, 0 )
		lRet := .F.
	EndIf
	(cAliasIC)->(dbCloseArea())
	
EndIf

Return lRet

/*/{Protheus.doc} ACTB02IN
//TODO Função para processar aopção de inclusão
@author Jair Matos
@since 19/02/2019
@version P12
/*/
User Function ACTB02IN()

Local aArea		:= GetArea()
Local aAreas	:= SaveArea1({"CTD","SM0","ZJA"})
Local aFiliais	:= {}
Local lCont		:= .F.
Local nFil		:= 0
Local aSM0		:= FWLoadSM0()

Private cPerg := padr("ACTB002",10)

While !lCont
	CriaPerg(cPerg)
	if !Pergunte(cPerg,.T.)
		Return .F.
	EndIf
	If MV_PAR01 == 2 .Or. MV_PAR01 == 3
		lCont := U_ACTB02CB()
	Else
		lCont := .T.
	EndIf
EndDo

If MV_PAR01 == 1 .Or. MV_PAR01 == 2
	For nFil := 1 to Len(aSM0)
		aAdd(aFiliais,{aSM0[nFil,SM0_CODFIL],aSM0[nFil,SM0_NOMRED]})
	Next nFil
Else
	aAdd(aFiliais,{MV_PAR03,FWFilName(cEmpAnt,MV_PAR03)})
EndIf

Do Case
	Case MV_PAR01 == 1
		FWMsgRun(,{|| U_ACTB02AU(MV_PAR01, aFiliais	, BscIT())}			,"Inserindo Todos IT's para todas as Filiais.","Aguarde...")
	Case MV_PAR01 == 2
		FWMsgRun(,{|| U_ACTB02AU(MV_PAR01, aFiliais	, BscIT(MV_PAR02))}	,"Inserindo um IT's para todas as Filiais.","Aguarde...")
	Case MV_PAR01 == 3
		FWMsgRun(,{|| U_ACTB02AU(MV_PAR01, aFiliais	, BscIT())}			,"Inserindo todos IT's para uma Filial.","Aguarde...")
	Case MV_PAR01 == 4
		FWExecView('Incluir','VIEWDEF.MADERO_ACTB002',3,,{|| .T.},,,,,,,)
EndCase

RestArea1(aAreas)
RestArea(aArea)

Return

/*/{Protheus.doc} ACTB02AU
//TODO Função para gravar
@author Jair Matos
@since 19/02/2019
@version P12
@param nOpcGrv, numeric, Opção de gravação
@param aSM0, array, Lista de filiais
@param aIT, array, List de IT's
@type function
/*/
User Function ACTB02AU(nOpcGrv,aSM0,aIT)

Local oModel	:= FWLoadModel( 'MADERO_ACTB002' )
Local oModelZJA	:= oModel:GetModel( 'MODEL_ZJA' )
Local nFil		:= 0
Local nIT		:= 0
Local nRegno	:= 0
Local nOper		:= 0
Local aErro		:= {}
Local lCont		:= .T.
Local cMsg		:= ""

Do Case
	Case nOpcGrv == 1
		cMsg := "Confirma a gravação de todos os Itens Contabeis para todas as Filiais?"
	Case nOpcGrv == 2
		cMsg := "Confirma a gravação de UM Item contabil para todas as Filiais?"
	Case nOpcGrv == 3
		cMsg := "Confirma a gravação de todos os Itens Contabeis para UMA Filial?"
EndCase

If Aviso("",cMsg,{"Sim","Não"},2) == 2
	lCont := .F.
EndIf

If lCont
	
	For nFil := 1 to Len(aSM0)
		
		For nIT := 1 to Len(aIT)
			
			//Verifica se existe
			nRegno := BscReg(aSM0[nFil,01],aIT[nIT,01])
			If nRegno == 0
				nOper := MODEL_OPERATION_INSERT
			Else
				nOper := MODEL_OPERATION_UPDATE                                            
				ZJA->(dbGoTo(nRegno))
			EndIf
			
			oModel:SetOperation(nOper)
			oModel:Activate()
			
			oModel:GetModel( 'MODEL_ZJA' ):LoadValue('ZJA_FILIT'	,aSM0[nFil][01] )
			oModel:GetModel( 'MODEL_ZJA' ):LoadValue('ZJA_NOMFIL'	,SubStr(aSM0[nFil][02],1,TamSx3("ZJA_NOMFIL")[01]) )
			oModel:GetModel( 'MODEL_ZJA' ):LoadValue('ZJA_ITEM'		,aIT[nIT][01] )
			oModel:GetModel( 'MODEL_ZJA' ):LoadValue('ZJA_DESC'		,SubStr(aIT[nIT][02],1,TamSx3("ZJA_DESC")[01]) )
			oModel:GetModel( 'MODEL_ZJA' ):LoadValue('ZJA_NDIAS'	,MV_PAR04)
			
			If oModel:VldData()
				oModel:CommitData()
			Else
				aErro := oModel:GetErrorMessage()
				
				AutoGrLog( "Id do formulário de origem:	" + ' [' + AllToChar( aErro[1] ) + ']' )
				AutoGrLog( "Id do campo de origem:		" + ' [' + AllToChar( aErro[2] ) + ']' )
				AutoGrLog( "Id do formulário de erro:	" + ' [' + AllToChar( aErro[3] ) + ']' )
				AutoGrLog( "Id do campo de erro:		" + ' [' + AllToChar( aErro[4] ) + ']' )
				AutoGrLog( "Id do erro:					" + ' [' + AllToChar( aErro[5] ) + ']' )
				AutoGrLog( "Mensagem do erro:			" + ' [' + AllToChar( aErro[6] ) + ']' )
				AutoGrLog( "Mensagem da solução:		" + ' [' + AllToChar( aErro[7] ) + ']' )
				AutoGrLog( "Valor atribuído:			" + ' [' + AllToChar( aErro[8] ) + ']' )
				AutoGrLog( "Valor anterior:				" + ' [' + AllToChar( aErro[9] ) + ']' )
				MostraErro()
			EndIf
			
			oModel:DeActivate()
			
		Next nIT
		
	Next nFil
	
EndIf

Return

/*/{Protheus.doc} BscIT
//TODO Busca Item Contabil
@since 23/03/2018
@author Jair Matos
@version P12
@return aRet, Array, lista de IT's
/*/
Static Function BscIT(cIT)

Local cQuery	:= ""
Local cAliasIC	:= ""
Local aRet		:= {}

Default cIT := ""

cQuery += "	SELECT CTD_ITEM, CTD_DESC01 " + CRLF
cQuery += "	FROM " + RetSqlName("CTD") + " " + CRLF
cQuery += "	WHERE " + CRLF
cQuery += "	CTD_FILIAL = '" + xFilial("CTD") + "' " + CRLF
If !Empty(cIT)
	cQuery += "	AND CTD_ITEM = '" + cIT + "' " + CRLF
EndIf
cQuery += "	AND D_E_L_E_T_ = ' ' " + CRLF
cQuery += "	ORDER BY CTD_ITEM " + CRLF

//MemoWrite("C:\TEMP\ACTB002_02.SQL",cQuery)

cQuery := ChangeQuery(cQuery)
cAliasIC := MPSysOpenQuery(cQuery)

While !(cAliasIC)->(Eof())
	
	aAdd(aRet,{(cAliasIC)->CTD_ITEM,(cAliasIC)->CTD_DESC01})
	(cAliasIC)->(dbSkip())
	
EndDo

(cAliasIC)->(dbCloseArea())

Return aRet

/*/{Protheus.doc} BscReg
//TODO Busca Recno
@author Jair Matos
@since 19/02/2019
@version P12
@return nRet, NUmerico, R_E_C_N_O_
@param cFilAux, characters, Filial
@param cITAux, characters, CC
/*/
Static Function BscReg(cFilAux,cITAux)

Local nRet		:= 0
Local cAliasIC	:= ""

cAliasIC := GetFilIT(cFilAux,cITAux)
If !(cAliasIC)->(Eof())
	nRet := (cAliasIC)->REGNO
EndIf
(cAliasIC)->(dbCloseArea())

Return nRet


/*/{Protheus.doc} GetFilIT
//TODO COnsulta Filial e IT
@author Jair Matos
@since 19/02/2019
@version P12
@return cQuery, reultado da consulta
@param cFilAux, characters, Filial
@param cITAux, characters, CC
/*/
Static Function GetFilIT(cFilAux,cITAux)

Local cQuery	:= ""

cQuery += " SELECT R_E_C_N_O_ REGNO " + CRLF
cQuery += " FROM " + RetSqlName("ZJA") + " " + CRLF
cQuery += " WHERE " + CRLF
cQuery += " 		ZJA_FILIAL = '" + xFilial("ZJA") + "' " + CRLF
cQuery += " 	AND ZJA_FILIT = '" + cFilAux + "' " + CRLF
cQuery += " 	AND ZJA_ITEM = '" + cITAux + "' " + CRLF
cQuery += " 	AND D_E_L_E_T_ = ' ' " + CRLF

//MemoWrite("C:\TEMP\ACTB002_01.txt",cQuery)

cQuery := ChangeQuery(cQuery)

Return MPSysOpenQuery(cQuery)

/*/{Protheus.doc} ACTB02CB
//TODO Validação
@author Jair Matos
@since 19/02/2019
@version P12
@return lRet, Lógico, validação
/*/
User Function ACTB02CB()

Local lRet 	:= .T.

If MV_PAR01 == 2
	IF Empty(MV_PAR02)
		Help( ,, 'Filial x ITEM',, 'Por favor informe o Item Contabil', 1, 0 )
		lRet := .F.
	EndIf
ElseIf MV_PAR01 == 3
	If Empty(MV_PAR03)
		Help( ,, 'Filial x ITEM',, 'Por favor informe a Filial', 1, 0 )
		lRet := .F.
	EndIf
EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} CriaPerg
Função para criação das perguntas na SX1

@author Jair  Matos
@since 11/12/2018
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CriaPerg( cPerg )

/*/{Protheus.doc} CriaPerg
Função para criar Grupo de Perguntas
@author Jair Matos
@since 11/12/2018
@version P12
@type function
@param cGrupo,    characters, Grupo de Perguntas       (ex.: X_TESTE)
@param cOrdem,    characters, Ordem da Pergunta        (ex.: 01, 02, 03, ...)
@param cTexto,    characters, Texto da Pergunta        (ex.: Produto De, Produto Até, Data De, ...)
@param cMVPar,    characters, MV_PAR?? da Pergunta     (ex.: MV_PAR01, MV_PAR02, MV_PAR03, ...)
@param cVariavel, characters, Variável da Pergunta     (ex.: MV_CH0, MV_CH1, MV_CH2, ...)
@param cTipoCamp, characters, Tipo do Campo            (C = Caracter, N = Numérico, D = Data)
@param nTamanho,  numeric,    Tamanho da Pergunta      (Máximo de 60)
@param nDecimal,  numeric,    Tamanho de Decimais      (Máximo de 9)
@param cTipoPar,  characters, Tipo do Parâmetro        (G = Get, C = Combo, F = Escolha de Arquivos, K = Check Box)
@param cValid,    characters, Validação da Pergunta    (ex.: Positivo(), u_SuaFuncao(), ...)
@param cF3,       characters, Consulta F3 da Pergunta  (ex.: SB1, SA1, ...)
@param cPicture,  characters, Máscara do Parâmetro     (ex.: @!, @E 999.99, ...)
@param cDef01,    characters, Primeira opção do combo
@param cDef02,    characters, Segunda opção do combo
@param cDef03,    characters, Terceira opção do combo
@param cDef04,    characters, Quarta opção do combo
@param cDef05,    characters, Quinta opção do combo
@param cHelp,     characters, Texto de Help do parâmetro
@obs Função foi criada, pois a partir de algumas versões do Protheus 12, a função padrão PutSX1 não funciona (por medidas de segurança)
@example Abaixo um exemplo de como criar um grupo de perguntas
/*/

cValid   := ""
cF3      := ""
cPicture := ""
cDef01   := ""
cDef02   := ""
cDef03   := ""
cDef04   := ""
cDef05   := ""

U_XPutSX1(cPerg, "01", "Tipo de Inclusão?",    	"MV_PAR01", "MV_CH1", "N", 01,  0, "C", cValid,       cF3,   cPicture,         "TD IT's - TD Filiais",   "1 IT - TD Filiais",         "TD IT's - 1 Filial",       "1 IT - 1 Filial",    cDef05, "Informe o Tipo de Inclusão")
U_XPutSX1(cPerg, "02", "Item Contabil?",      	"MV_PAR02", "MV_CH2", "C", TamSx3("CTD_ITEM")[01] ,  0, "G", cValid,     "CTD",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe O Item Contábil")
U_XPutSX1(cPerg, "03", "Filial?",  		    	"MV_PAR03", "MV_CH3", "C", TamSx3("CTD_FILIAL")[01] ,  0, "G", cValid,       "SM0",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a Filial")
U_XPutSX1(cPerg, "04", "Num.Dias?",  			"MV_PAR04", "MV_CH4", "N", 03,  0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o número de dias a ser considerado")

Return Nil
