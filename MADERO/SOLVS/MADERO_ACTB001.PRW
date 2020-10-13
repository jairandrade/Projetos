#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TopConn.ch"

User Function ACTB001()

	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZA0")
	oBrowse:SetDescription("Filial X Centro de Custos")
	oBrowse:SetMenuDef("MADERO_ACTB001")
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aAdd(aRotina,{'Visualizar'	,'VIEWDEF.MADERO_ACTB001'	,0,2,0,NIL})
	aAdd(aRotina,{'Incluir'		,'U_ACTB01IN()'				,0,3,0,NIL})
	aAdd(aRotina,{'Alterar'		,'VIEWDEF.MADERO_ACTB001'	,0,4,0,NIL})
	aAdd(aRotina,{'Excluir'		,'VIEWDEF.MADERO_ACTB001'	,0,5,0,NIL})
	aAdd(aRotina,{'Imprimir' 	,'VIEWDEF.MADERO_ACTB001'	,0,8,0,NIL})

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Mario L. B. Faria

@since 19/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel
	Local oStr1:= FWFormStruct(1,'ZA0')
	
	oModel := MPFormModel():New('AGCT001_MAIN', , { |oModel| U_VALFILCC() } )
	oModel:SetDescription('Filial X CC')
	
	oStr1:AddTrigger( 'ZA0_FILCC', 'ZA0_NOMFIL'	, { || .T. }, {|oModel| PadR(FWFilialName(,FWFldGet("ZA0_FILCC")),TamSx3('ZA0_NOMFIL')[01])} )
	oStr1:AddTrigger( 'ZA0_CUSTO', 'ZA0_DESC'	, { || .T. }, {|oModel| Posicione("CTT",1,xFilial("CTT")+FWFldGet("ZA0_CUSTO"),"CTT_DESC01") } )	
	
	oModel:addFields('MODEL_ZA0',,oStr1)
	oModel:SetPrimaryKey({ 'ZA0_FILIAL', 'ZA0_FILCC', 'ZA0_CUSTO' })

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Mario L. B. Faria

@since 19/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStr1:= FWFormStruct(2, 'ZA0')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_ZA0' , oStr1,'MODEL_ZA0' ) 
	oView:CreateHorizontalBox( 'BOX_ZA0', 100)
	oView:SetOwnerView('VIEW_ZA0','BOX_ZA0')

Return oView

/*/{Protheus.doc} VALFILCC
//TODO Validação se ja existe Filial X CC cadastrada
@author Mario L. B. Faria
@since 19/03/2018
@version 1.0
@return lRet, Logico, .T. - valida e .F. - Não Valida
/*/
User Function VALFILCC()

	Local oModel 	:= FWModelActive()
	Local oView		:= FWViewActive()
	Local lRet		:= .T.
	Local cAliasIC	:= ""

	If oModel:GetOperation() != 5 
	
		cAliasIC := GetFilCC(FWFldGet("ZA0_FILCC"),FWFldGet("ZA0_CUSTO"))
		If !(cAliasIC)->(Eof())
			Help( ,, 'Filial x CC',, 'Já existe cadastro para esta Filial X CC', 1, 0 )
			lRet := .F.
		EndIf
		(cAliasIC)->(dbCloseArea())
		
	EndIf
	
Return lRet

/*/{Protheus.doc} ACTB01IN
//TODO Função para processar aopção de inclusão
@author Mario L. B. Faria
@since 23/03/2018
@version 1.0
/*/
User Function ACTB01IN()
	
	Local aArea		:= GetArea()
	Local aAreas	:= SaveArea1({"CTT","SM0","ZA0"})
	Local aFiliais	:= {}
	Local lCont		:= .F.
	Local nFil		:= 0
	Local aSM0		:= FWLoadSM0()

	Private cPerg := padr("ACTB001",10)

	While !lCont
		CriaSx1()
		if !Pergunte(cPerg,.T.)
			Return .F.
		EndIf
		If MV_PAR01 == 2 .Or. MV_PAR01 == 3
			lCont := U_ACTB01CB()
		Else
			lCont := .T.
		EndIf
	EndDo
	
	If MV_PAR01 == 1 .Or. MV_PAR01 == 2
		For nFil := 1 to Len(aSM0)
			If aSM0[nFil,SM0_GRPEMP] == FWGrpCompany()
				aAdd(aFiliais,{aSM0[nFil,SM0_CODFIL],aSM0[nFil,SM0_NOMRED]})
			EndIf
		Next nFil
	Else
		aAdd(aFiliais,{MV_PAR03,FWFilName(FWGrpCompany(),MV_PAR03)})
	EndIf
	
	Do Case
		Case MV_PAR01 == 1 
			FWMsgRun(,{|| U_ACTB01AU(MV_PAR01, aFiliais	, BscCC())}			,"Inserindo Todos CC's para todas as Filiais.","Aguarde...")
		Case MV_PAR01 == 2
			FWMsgRun(,{|| U_ACTB01AU(MV_PAR01, aFiliais	, BscCC(MV_PAR02))}	,"Inserindo um CC's para todas as Filiais.","Aguarde...")
		Case MV_PAR01 == 3 
			FWMsgRun(,{|| U_ACTB01AU(MV_PAR01, aFiliais	, BscCC())}			,"Inserindo todos CC's para uma Filial.","Aguarde...")
		Case MV_PAR01 == 4 
			FWExecView('Incluir','VIEWDEF.MADERO_ACTB001',3,,{|| .T.},,,,,,,)
	EndCase

	RestArea1(aAreas)
	RestArea(aArea)

Return

/*/{Protheus.doc} ACTB01AU
//TODO Função para gravar
@author Mario L. B. Faria
@since 23/03/2018
@version 1.0
@param nOpcGrv, numeric, Opção de gravação
@param aSM0, array, Lista de filiais
@param aCC, array, List de CC's
@type function
/*/
User Function ACTB01AU(nOpcGrv,aSM0,aCC)

	Local oModel	:= FWLoadModel( 'MADERO_ACTB001' ) 
	Local oModelZA0	:= oModel:GetModel( 'MODEL_ZA0' )
	Local nFil		:= 0
	Local nCC		:= 0
	Local nRegno	:= 0 
	Local nOper		:= 0
	Local aErro		:= {}
	Local lCont		:= .T.
	Local cMsg		:= ""
	
	Do Case
		Case nOpcGrv == 1
			cMsg := "Confirma a gravação de todos os Centros de Custo para todas as Filiais?"
		Case nOpcGrv == 2
			cMsg := "Confirma a gravação de UM Centro de Custo para todas as Filiais?"
		Case nOpcGrv == 3
			cMsg := "Confirma a gravação de todos os Centros de Custo para UMA Filial?"
	EndCase

	If Aviso("",cMsg,{"Sim","Não"},2) == 2
		lCont := .F.
	EndIf
	
	If lCont
	
		For nFil := 1 to Len(aSM0) 
		
			For nCC := 1 to Len(aCC)

				//Verifica se existe
				nRegno := BscReg(aSM0[nFil,01],aCC[nCC,01])
				If nRegno == 0
					nOper := MODEL_OPERATION_INSERT
				Else
					nOper := MODEL_OPERATION_UPDATE
					ZA0->(dbGoTo(nRegno))
				EndIf
				
				oModel:SetOperation(nOper)
				oModel:Activate() 

				oModel:GetModel( 'MODEL_ZA0' ):LoadValue('ZA0_FILCC'	,aSM0[nFil][01] )
				oModel:GetModel( 'MODEL_ZA0' ):LoadValue('ZA0_NOMFIL'	,SubStr(aSM0[nFil][02],1,TamSx3("ZA0_NOMFIL")[01]) )
				oModel:GetModel( 'MODEL_ZA0' ):LoadValue('ZA0_CUSTO'	,aCC[nCC][01] )
				oModel:GetModel( 'MODEL_ZA0' ):LoadValue('ZA0_DESC'		,SubStr(aCC[nCC][02],1,TamSx3("ZA0_DESC")[01]) )
				
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
			
			Next nCC

		Next nFil
	
	EndIf

Return

/*/{Protheus.doc} BscCC
//TODO Busca cenrtors de Custo
@since 23/03/2018
@version 1.0
@return aRet, Array, lista de CC's
/*/
Static Function BscCC(cCC)

	Local cQuery	:= ""
	Local cAliasIC	:= ""
	Local aRet		:= {}

	Default cCC := ""

	cQuery += "	SELECT CTT_CUSTO, CTT_DESC01 " + CRLF 
	cQuery += "	FROM " + RetSqlName("CTT") + " " + CRLF
	cQuery += "	WHERE " + CRLF
	cQuery += "			CTT_FILIAL = '" + xFilial("CTT") + "' " + CRLF
	If !Empty(cCC)
		cQuery += "		AND CTT_CUSTO = '" + cCC + "' " + CRLF
	EndIf
	cQuery += "		AND D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	ORDER BY CTT_CUSTO " + CRLF
	
	MemoWrite("C:\TEMP\ACTB001_02.SQL",cQuery)

	cQuery := ChangeQuery(cQuery)
	cAliasIC := MPSysOpenQuery(cQuery)

	While !(cAliasIC)->(Eof())
	
		aAdd(aRet,{(cAliasIC)->CTT_CUSTO,(cAliasIC)->CTT_DESC01})
		(cAliasIC)->(dbSkip())
	
	EndDo
	
	(cAliasIC)->(dbCloseArea())

Return aRet

/*/{Protheus.doc} BscReg
//TODO Busca Recno
@author Mario L. B. Faria
@since 23/03/2018
@version 1.0
@return nRet, NUmerico, R_E_C_N_O_
@param cFilAux, characters, Filial
@param cCCAux, characters, CC
/*/
Static Function BscReg(cFilAux,cCCAux)

	Local nRet		:= 0
	Local cAliasIC	:= ""

	cAliasIC := GetFilCC(cFilAux,cCCAux)
	If !(cAliasIC)->(Eof())
		nRet := (cAliasIC)->REGNO
	EndIf
	(cAliasIC)->(dbCloseArea())

Return nRet


/*/{Protheus.doc} GetFilCC
//TODO COnsulta Filial e CC
@author Mario L. B. Faria
@since 23/03/2018
@version 1.0
@return cQuery, reultado da consulta
@param cFilAux, characters, Filial
@param cCCAux, characters, CC
/*/
Static Function GetFilCC(cFilAux,cCCAux)

	Local cQuery	:= ""

	cQuery += " SELECT R_E_C_N_O_ REGNO " + CRLF
	cQuery += " FROM " + RetSqlName("ZA0") + " " + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += " 		ZA0_FILIAL = '" + xFilial("ZA0") + "' " + CRLF
	cQuery += " 	AND ZA0_FILCC = '" + cFilAux + "' " + CRLF
	cQuery += " 	AND ZA0_CUSTO = '" + cCCAux + "' " + CRLF
	cQuery += " 	AND D_E_L_E_T_ = ' ' " + CRLF

	MemoWrite("C:\TEMP\ACTB001_01.SQL",cQuery)

	cQuery := ChangeQuery(cQuery)

Return MPSysOpenQuery(cQuery)

/*/{Protheus.doc} ACTB01CB
//TODO Validação
@author Mario L. B. Faria
@since 23/03/2018
@version 1.0
@return lRet, Lógico, validação
/*/
User Function ACTB01CB()
	
	Local lRet 	:= .T.
	
	If MV_PAR01 == 2
		IF Empty(MV_PAR02)
			Help( ,, 'Filial x CC',, 'Por favor informe o Centro de Custo', 1, 0 )
			lRet := .F.		
		EndIf
	ElseIf MV_PAR01 == 3
		If Empty(MV_PAR03)
			Help( ,, 'Filial x CC',, 'Por favor informe a Filial', 1, 0 )
			lRet := .F.		
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} CriaSx1
//TODO Cria perguntas
@author Mario L. B. Faria
@since 23/03/2018
@version 1.0
/*/
Static Function CriaSx1()

	CheckSX1(cPerg,"01","Tipo de Inclusão?" ,""	,"" ,"mv_ch1" ,"N" ,01 ,0 ,0 ,"C" ,/*"U_ACTB01CB()"*/ 	,"" 	,"" ,"" ,"mv_par01" ,;
				   "TD CC's - TD Filiais"	,"TD CC's - TD Filiais"		,"TD CC's - TD Filiais","",;
				   "1 CC - TD Filiais"		,"1 CC - TD Filiais"		,"1 CC - TD Filiais",;
				   "TD CC's - 1 Filial"		,"TD CC's - 1 Filial"		,"TD CC's - 1 Filial",;
				   "1 CC - 1 Filial"		,"1 CC - 1 Filial"			,"1 CC - 1 Filial")
	CheckSX1(cPerg,"02","Centro de Custo?" 	,""	,"" ,"mv_ch2" ,"C" ,TamSx3("CTT_CUSTO")[01]  ,0 ,0 ,"C" ,"Vazio() .Or. ExistCpo('CTT',MV_PAR02)" 	,"CTT"	,"" ,"" ,"mv_par02" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"")
	CheckSX1(cPerg,"03","Filial?" 			,""	,"" ,"mv_ch3" ,"C" ,TamSx3("CTT_FILIAL")[01] ,0 ,0 ,"C" ,"Vazio() .Or. FWFilExist(,MV_PAR03)"		,"SM0"	,"" ,"" ,"mv_par03" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"" ,"")				   
			   
Return



