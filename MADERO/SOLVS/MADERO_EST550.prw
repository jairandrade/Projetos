#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TopConn.CH"

/*  
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EST550                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Rotina para Cadastro de Inventários                                           !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 19/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Revisões         ! Márcio A. Zaguetti                                                            !
+------------------+-------------------------------------------------------------------------------+
! Informações      ! Foram realizados ajustes no fonte para correção de problemas de implementacao !
! Adicionais       ! e boas práticas de implementação                                              !
+------------------+-------------------------------------------------------------------------------+
*/         
User Function EST550()
	
	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("Z23")
	oBrowse:SetDescription("Inventário")
	oBrowse:SetMenuDef("MADERO_EST550")
	oBrowse:Activate()

Return




/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! MenuDef                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Implementacao do menu da rotina                                               !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 19/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/         
Static Function MenuDef()
Local aRotina := {}

	aAdd(aRotina,{'Visualizar'	,'VIEWDEF.MADERO_EST550'	,0,2,0,NIL})
	aAdd(aRotina,{'Excluir'		,'VIEWDEF.MADERO_EST550'	,0,5,0,NIL})

Return( aRotina )



/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ModelDef                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Implementação do modelo                                                       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 19/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/         
Static Function ModelDef()

	Local oModel
	Local oStr1	:= FWFormStruct(1,'Z23')
	
	oModel:=MPFormModel():New('EST550_MAIN', ,{ |oModel| EST550E( oModel ) } )
	oModel:SetDescription('Inventário')
	oModel:addFields('MODEL_Z23',,oStr1)
	oModel:SetPrimaryKey({ 'Z23_FILIAL', 'Z23_ID' })
	oModel:getModel('MODEL_Z23'):SetDescription('Inventário')
	
Return oModel


/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ViewDef                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Implementação da interface                                                    !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 19/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/         
Static Function ViewDef()
Local oView
Local oModel	:= ModelDef()
Local oStr1		:= FWFormStruct(2, 'Z23')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_Z23' , oStr1,'MODEL_Z23' ) 
	oView:CreateHorizontalBox( 'BOX_Z23', 100)
	oView:SetOwnerView('VIEW_Z23','BOX_Z23')

Return oView


/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EST550I                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Funlção de inclusão de inventário                                             !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/         
User Function EST550I(cFunName, cFilInv, cUsrName, dDtaInv, aGrpInv, nOpc, cArqCSV)
Local nX		:= 0
Local cGrpInv	:= ""
Local cRet		:= ""
Local oModel	:= FWLoadModel("MADERO_EST550")
Default cArqCSV := ""	
			
	For nX := 1 to Len(aGrpInv)
		cGrpInv += aGrpInv[nX] + "," 
	Next nX
	cGrpInv := SubStr(cGrpInv,1,Len(cGrpInv)-1)
	
	oModel:SetOperation(nOpc)
	oModel:Activate()
	
	If nOpc == 3
		oModel:SetValue("MODEL_Z23", "Z23_FILIAL"	, cFilInv)
		oModel:SetValue("MODEL_Z23", "Z23_DATA"		, dDtaInv)
		oModel:SetValue("MODEL_Z23", "Z23_GRUPOS"	, cGrpInv)
		oModel:SetValue("MODEL_Z23", "Z23_DTINC"	, Date())
		oModel:SetValue("MODEL_Z23", "Z23_HRINC"	, Time())
		oModel:SetValue("MODEL_Z23", "Z23_USERI"	, cUsrName)
	ElseIf nOpc == 4
		oModel:SetValue("MODEL_Z23", "Z23_FILIAL"	, Z23->Z23_FILIAL)
		oModel:SetValue("MODEL_Z23", "Z23_ID"		, Z23->Z23_ID)
		oModel:SetValue("MODEL_Z23", "Z23_DTINV"	, Date())
		oModel:SetValue("MODEL_Z23", "Z23_HRINV"	, Time())
		oModel:SetValue("MODEL_Z23", "Z23_ARQINV"	, cArqCSV)
	EndIf

	If oModel:VldData()
		oModel:CommitData()
	Else
	
		aErro := oModel:GetErrorMessage()
		
		AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1] ) + ']' )
		AutoGrLog( "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' )
		AutoGrLog( "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + ']' )
		AutoGrLog( "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' )
		AutoGrLog( "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' )
		AutoGrLog( "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' )
		AutoGrLog( "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' )
		AutoGrLog( "Valor atribuído: " + ' [' + AllToChar( aErro[8] ) + ']' )
		AutoGrLog( "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']' )
		
		cRet := RetErro()
		
	EndIf
	
	oModel:DeActivate()

Return({cRet,Z23->Z23_ID,Z23->Z23_USERI,Z23->Z23_DATA})



/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EST550G                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Gera itens a inventariar                                                      !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 25/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/         
User Function EST550G(cFunName, cGrpInv, cFilInv, cIdInv, cEmpTek, cFilTek, cMailUnid, dDataInv)
Local cQuery	:= ""
Local cAlQry	:= ""	
Local cPath		:= ""
Local cArqCSV	:= "INV" + cIdInv + ".CSV"	
Local nRetAux	:= 0
Local cMsg		:= ""
	
	cGrpInv := AllTrim(StrTran(cGrpInv,",","','"))
	cQuery := "	SELECT  " + CRLF 
	cQuery += "	    SB1.B1_COD		B1COD,     " + CRLF 
	cQuery += "	    SB1.B1_DESC		B1DESC,    " + CRLF 
	cQuery += "	    SB1.B1_GRUPO	B1GRUPO,   " + CRLF 
	cQuery += "	    SB1.B1_UM		B1UM,      " + CRLF 
	cQuery += "	    SB1.B1_XCODEXT  CDCODEXT,  " + CRLF 
	cQuery += "	    SB1.B1_CODBAR   B1CODBAR   " + CRLF 
	cQuery += "	    FROM "+ RETSQLNAME("SB1") +" SB1  " + CRLF 
	cQuery += "	WHERE " + CRLF
	cQuery += "	    SB1.B1_FILIAL = '" + cFilInv + "' " + CRLF
	cQuery += "	    AND SB1.B1_GRUPO IN ('" + cGrpInv + "') " + CRLF
	cQuery += "	    AND SB1.B1_MSBLQL <> '1' " + CRLF
	cQuery += "	    AND SB1.D_E_L_E_T_ = ' '  " + CRLF

	cQuery := ChangeQuery(cQuery)
	cAlQry := MPSysOpenQuery(cQuery)

	//-> verifica se possui as pastas do inventario no server
	cPath := U_EST550PT(cFilTek)
	
	If !File(cPath + cArqCSV)	//Se não existe o arquivo prossegue
		GeraCSV(cAlQry, cPath , cArqCSV)
	Else	//-> caso o arquivo exista gera erro
		cMsg := "Nao foi possivel gerar o arquivo " + cArqCSV + ".csv no diretório " + cPath
	EndIf
	
	If Empty(cMsg)
		//-> Atualiza Z23
		U_EST550I(FunName(),xFilial("Z23"),RetCodUsr(),dDataInv,{},4,cArqCSV)
	EndIf
	
	(cAlQry)->(dbCloseArea())

Return {cMsg,cArqCSV}




/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EST550E                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Valida a Exclusão do inventário                                               !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 25/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/    
Static Function EST550E(oModel)
Local lRet		:= .T.
Local cPath		:= ""
Local aArquivos	:= {}
Local cArqCSV	:= AllTrim(FWFldGet("Z23_ARQINV"))
Local cFilTek	:= ""
	
	// -> Valida somente a Exclusão
	If oModel:GetOperation() == 5
		
		// -> valida inventario ja processado
		If Empty(FWFldGet("Z23_DTPROC")) 
		
			Begin Transaction
		
				// -> Verifica se possui itens processados na SB7
				If STATSB7(oModel)
				
					// -> Exclui itens SB7
					If EXCLSB7(oModel)
					
						// -> busca pelo indice customizado
						dbSelectArea("ADK")
						 ADK->( dbOrderNickName("ADKXFILI") )    
						 ADK->( dbGoTop() )
						 If ADK->( dbSeek(xFilial("ADK") + cFilAnt) )
						 	cFilTek := ADK->ADK_XFIL
						 EndIf
						
						// -> verifica se possui as pastas do inventario no server
						cPath := U_EST550PT(cFilTek)
						
						aArquivos := Directory(cPath + cArqCSV)
						If Len(aArquivos) > 0
							
							// -> Se nçao conseguiu deletar o arquivo interrompe o processo
							If fErase(cPath + cArqCSV) == -1
								DisarmTransaction()	
								lRet	:= .F.	
								Help("",1,"Exclusao",,"Erro na exclusão do inventário. Não foi possivel excluir o arquivo CSV. " + cPath + cArqCSV ,4,1)
							EndIf		
						EndIf				
					
					Else
						DisarmTransaction()	
						lRet	:= .F.		
						Help("",1,"Exclusao SB7",,"Erro ao excluir a digitacao do inventatio (tabela SB7)."+Chr(13)+cHR(10)+"Verifique o error log ocorrido.")
					EndIf
				
				Else
					DisarmTransaction()	
					lRet	:= .F.
					Help("",1,"Exclusao",,"Erro na exclusão do inventário. Existem itens processados para o inventário INV" + FWFldGet("Z23_ID") + " de " + DtoC(FWFldGet("Z23_DATA")) ,4,1)
				EndIf
			 
			End Transaction
		
		Else
			Help("",1,"Exclusao",,"Erro na exclusão do inventário. Inventário Já processado. [Z23_DTPROC =" + DtoC(FWFldGet("Z23_DTPROC")) + "]",4,1)
			lRet	:= .F.
		EndIf
		
	EndIf

Return lRet




/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! STATSB7                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Verifica se possui SB7 processada                                             !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 25/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/    
Static Function STATSB7(oModel)
Local lRet		:= .T.
Local cQuery	:= ""
Local cAlQry	:= ""
	
	cQuery := "	SELECT R_E_C_N_O_ B7_REGNO " + CRLF 
	cQuery += "	FROM " + RetSqlName("SB7") + " " + CRLF 
	cQuery += "	WHERE " + CRLF 
	cQuery += "	    B7_FILIAL = '" + xFilial("SB7") + "' " + CRLF 
	cQuery += "	AND B7_DOC = 'INV' || '" + FWFldGet("Z23_ID") + "' " + CRLF 
	cQuery += "	AND B7_DATA = '" + DtoS(FWFldGet("Z23_DATA")) + "' " + CRLF 
	cQuery += "	AND B7_STATUS = '2' " + CRLF 
	cQuery += "	AND D_E_L_E_T_ = ' ' " + CRLF 	

	cQuery := ChangeQuery(cQuery)
	cAlQry := MPSysOpenQuery(cQuery)
	
	If !(cAlQry)->(Eof())
		lRet := .F.
	EndIf
	
	(cAlQry)->(dbCloseArea())

Return lRet



/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EXCLSB7                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para excluir SB7                                                       !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 25/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/    
Static Function EXCLSB7(oModel)
Local lRet		:= .T.
Local cQuery	:= ""
Local cAlQry	:= ""
Local aMata270	:= {}
Local nModAux	:= nModulo
Local cFilAux	:= cFilAnt
Local dDatAux	:= dDataBase
Local cPergunta := "MTA270"
Private lMsErroAuto := .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .T.
	
	cQuery := "	SELECT R_E_C_N_O_ B7_REGNO " + CRLF 
	cQuery += "	FROM " + RetSqlName("SB7") + " " + CRLF 
	cQuery += "	WHERE " + CRLF 
	cQuery += "	    B7_FILIAL  = '" + xFilial("SB7") + "' " + CRLF 
	cQuery += "	AND B7_DOC     = 'INV' || '" + FWFldGet("Z23_ID") + "' " + CRLF 
	cQuery += "	AND B7_DATA    = '" + DtoS(FWFldGet("Z23_DATA")) + "' " + CRLF 
	cQuery += "	AND D_E_L_E_T_ = ' ' " + CRLF 	
	cQuery := ChangeQuery(cQuery)
	cAlQry := MPSysOpenQuery(cQuery)
	dbSelectArea("SB7")
	
	Pergunte(cPergunta,.F.)
	mv_par01 := 1
	mv_par02 := 1
	mv_par03 := dDataBase
	mv_par04 := 1
	mv_par05 := dDataBase
	mv_par06 := "001"
	
	While !(cAlQry)->(Eof())
	
		SB7->(dbGoTo((cAlQry)->B7_REGNO))
		
		nModulo	 := 4
		dDataBase:= SB7->B7_DATA
		cFilAnt	 := SB7->B7_FILIAL
	
		aMata270 := {}
		aAdd( aMata270, { "B7_DOC"    , SB7->B7_DOC    , Nil })
		aAdd( aMata270, { "B7_COD"    , SB7->B7_COD    , Nil })
		aAdd( aMata270, { "B7_LOCAL"  , SB7->B7_LOCAL  , Nil })
		//tem que setar o indice 3, porque no indice 1 e 2 não tem documento
		//e busca registros diferentes por não ter o documento na chave
		aAdd( aMata270, { "INDEX"     , 3 , Nil })
				        
		lMsErroAuto := .F.              
		MSExecAuto({|x,y,z| mata270(x,y,z)},aMata270,.T.,5)
		
		If lMsErroAuto
		    MostraErro()
		    lRet := .F.
		    Exit
		EndIf		
		
		(cAlQry)->(dbSkip())
	
	EndDo
	
	(cAlQry)->(dbCloseArea())

	cFilAnt  := cFilAux
	nModulo  := nModAux
	dDataBase:= dDatAux

Return lRet


/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GeraCSV                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para gerar arquivo CSV                                                 !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 25/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/    
Static Function GeraCSV(cAlQry, cPath, cArqCSV)
Local nArq		:= ""
Local cLinha	:= ""
Local cA5UNID   := ""
Local cA5XTPCUNF:= ""
Local cA5XCVUNF := 0
Local cA5CODBAR := ""
//Local cCodArv   := ""

//#TB20200305 Thiago Berna - Ajuste para retornar o campo A5_XCODARV
Local cA5CODARV	:= ""

	DbSelectArea("SA5")
	DbSelectArea("Z13")

	// -> Grava Cabeçalho
	nArq   := fCreate(cPath + cArqCSV)
	
	//#TB20200305 Thiago Berna - Ajuste para alterar o nome de a5codbar para cdcodarv
	//cLinha := "b1cod;b1desc;b1grupo;bmdesc;b1um;a5unid;a5xtpcunf;a5xcvunf;a5codbar;codarv;" + CRLF
	cLinha := "b1cod;b1desc;b1grupo;bmdesc;b1um;a5unid;a5xtpcunf;a5xcvunf;cdcodarv;codarv;" + CRLF

	fSeek(nArq,0,2)
	fWrite(nArq,cLinha)	

	// -> Grava linhas
	While !(cAlQry)->(Eof())

		// -> Verifica se o produto possui movimentação
		SB2->(DbSetOrder(1))
		SB2->(dbSeek(xFilial("SB2")+(cAlQry)->B1COD))
		If SB2->(Found())
		
			ConOut("-->"  + PadR((cAlQry)->B1COD,TamSx3("B1_COD")[01]) + " - " + AllTrim((cAlQry)->B1DESC))		
			cA5UNID   := ""
			cA5XTPCUNF:= ""
			cA5XCVUNF := 0
			cA5CODBAR := ""

			//#TB20200305 Thiago Berna - Ajuste para retornar o campo A5_XCODARV
			cA5CODARV	:= ""
			
			SA5->(DbSetOrder(2))
			SA5->(DbSeek(xFilial("SA5")+(cAlQry)->B1COD))
			// -> Se encontrou, retorna os dados do produto x fornecedor
			If !SA5->(Eof())
				While !SA5->(Eof()) .and. SA5->A5_FILIAL == xFilial("SA5") .and. SA5->A5_PRODUTO == (cAlQry)->B1COD
					cA5UNID   := SA5->A5_UNID
					cA5XTPCUNF:= SA5->A5_XTPCUNF
					cA5XCVUNF := SA5->A5_XCVUNF
					
					//#TB20200305 Thiago Berna - Ajuste para retornar o campo A5_XCODARV
					//cA5CODBAR := SA5->A5_CODBAR
					cA5CODARV := SA5->A5_XCODARV

					//#TB20200305 Thiago Berna - Ajuste para retornar o campo A5_XCODARV
					/*cLinha := ""
					cLinha +=  AllTrim((cAlQry)->B1COD)     + ";"
					cLinha +=  AllTrim((cAlQry)->B1DESC)    + ";"
					cLinha +=  AllTrim((cAlQry)->B1GRUPO)   + ";"
					cLinha +=  AllTrim(Posicione("SBM",1,xFilial("SBM")+(cAlQry)->B1GRUPO,"BM_DESC")) + ";"
					cLinha +=  AllTrim((cAlQry)->B1UM)      + ";"
					cLinha +=  AllTrim(cA5UNID)             + ";"
					cLinha +=  AllTrim(cA5XTPCUNF)          + ";"
					cLinha +=  cValToChar(cA5XCVUNF)        + ";"
					cLinha +=  AllTrim(cA5CODBAR)           + ";"
					cLinha +=  AllTrim((cAlQry)->CDCODEXT) 	+ ";"
					cLinha += CRLF*/
					
					cLinha := ""
					cLinha +=  AllTrim((cAlQry)->B1COD)     + ";"
					cLinha +=  AllTrim((cAlQry)->B1DESC)    + ";"
					cLinha +=  AllTrim((cAlQry)->B1GRUPO)   + ";"
					cLinha +=  AllTrim(Posicione("SBM",1,xFilial("SBM")+(cAlQry)->B1GRUPO,"BM_DESC")) + ";"
					cLinha +=  AllTrim((cAlQry)->B1UM)      + ";"
					cLinha +=  AllTrim(cA5UNID)             + ";"
					cLinha +=  AllTrim(cA5XTPCUNF)          + ";"
					cLinha +=  cValToChar(cA5XCVUNF)        + ";"
					cLinha +=  AllTrim(cA5CODARV)           + ";"
					cLinha +=  AllTrim((cAlQry)->CDCODEXT) 	+ ";"
					cLinha += CRLF

					fSeek(nArq,0,2)
					fWrite(nArq,cLinha)	

					SA5->(DbSkip())
				EndDo
			
			Else	

				cA5UNID   := IIF(Empty(cA5UNID)   ,(cAlQry)->B1UM    ,cA5UNID)
				cA5XTPCUNF:= IIF(Empty(cA5XTPCUNF),"M"               ,cA5XTPCUNF)
				cA5XCVUNF := IIF(cA5XCVUNF<=0     ,1                 ,cA5XCVUNF)
				
				//#TB20200305 Thiago Berna - Ajuste para retornar o campo A5_XCODARV
				//cA5CODBAR := IIF(Empty(cA5CODBAR) ,(cAlQry)->B1CODBAR,cA5CODBAR)

				//#TB20200305 Thiago Berna - Ajuste para retornar o campo A5_XCODARV
				/*cLinha := ""
				cLinha +=  AllTrim((cAlQry)->B1COD)     + ";"
				cLinha +=  AllTrim((cAlQry)->B1DESC)    + ";"
				cLinha +=  AllTrim((cAlQry)->B1GRUPO)   + ";"
				cLinha +=  AllTrim(Posicione("SBM",1,xFilial("SBM")+(cAlQry)->B1GRUPO,"BM_DESC")) + ";"
				cLinha +=  AllTrim((cAlQry)->B1UM)      + ";"
				cLinha +=  AllTrim(cA5UNID)             + ";"
				cLinha +=  AllTrim(cA5XTPCUNF)          + ";"
				cLinha +=  cValToChar(cA5XCVUNF)        + ";"
				cLinha +=  AllTrim(cA5CODBAR)           + ";"
				cLinha +=  AllTrim((cAlQry)->CDCODEXT) 	+ ";"
				cLinha += CRLF*/
				
				cLinha := ""
				cLinha +=  AllTrim((cAlQry)->B1COD)     + ";"
				cLinha +=  AllTrim((cAlQry)->B1DESC)    + ";"
				cLinha +=  AllTrim((cAlQry)->B1GRUPO)   + ";"
				cLinha +=  AllTrim(Posicione("SBM",1,xFilial("SBM")+(cAlQry)->B1GRUPO,"BM_DESC")) + ";"
				cLinha +=  AllTrim((cAlQry)->B1UM)      + ";"
				cLinha +=  AllTrim(cA5UNID)             + ";"
				cLinha +=  AllTrim(cA5XTPCUNF)          + ";"
				cLinha +=  cValToChar(cA5XCVUNF)        + ";"
				cLinha +=  AllTrim(cA5CODARV)           + ";"
				cLinha +=  AllTrim((cAlQry)->CDCODEXT) 	+ ";"
				cLinha += CRLF

				fSeek(nArq,0,2)
				fWrite(nArq,cLinha)	
			
			EndIf	

		EndIf	
				
		(cAlQry)->(dbSkip())

	EndDo
	
	fClose(nArq)

Return


/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! EST550PT                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para verifica se pastas de gravação existem no servidor                !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 25/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/    
User Function EST550PT(cFilInv)
Local cPathImp	:= "\IMPORT"
Local cPathInv	:= "\INV" 
Local cPathFil	:= "\" + cFilInv + ""	
Local cPath		:= cPathImp + cPathInv + cPathFil + "\"

	If !ExistDir(cPathImp)
		MakeDir(cPathImp)
	EndIf   
	
	If !ExistDir(cPathImp + cPathInv)
		MakeDir(cPathImp + cPathInv)
	EndIf 
	
	If !ExistDir(cPathImp + cPathInv + cPathFil)
		MakeDir(cPathImp + cPathInv + cPathFil)
	EndIf 

Return cPath



/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! RetErro                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Formata erro                                                                  !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/    
Static Function RetErro()

	Local nX     := 0
	Local cErro  := ""
	Local aLog	 := GetAutoGRLog()

	For nX := 1 To Len(aLog)
		cErro += aLog[nX] + CRLF
	Next nX

Return cErro