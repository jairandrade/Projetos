#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "TryException.ch"
#Include "rwmake.ch"
#Include "FwCommand.ch"
#Include 'FWMVCDef.ch'

/*-----------------+---------------------------------------------------------+
!Nome              ! COM102 - Cliente: Madero                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Interface para confirmar pedidos de compras             !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 28/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function COM102()
Local oWizard:= FWWizardControl( ):New( )
Local oStep
Local oBrowse
Local oTmpBrowse
Private cAliasQry:= GetNextAlias( )
Private cAliasAux:= ""
Private cFilDe	 := Space(TamSx3("C7_FILIAL")[1] )
Private cFilAte	 := Space(TamSx3("C7_FILIAL")[1] )
Private dDataDe	 := CtoD("  /  /  ")
Private dDataAte := CtoD("  /  /  ")
Private cUFDe	 := Space(TamSx3("A2_EST")[1])
Private cUFAte 	 := Space(TamSx3("A2_EST")[1])
Private cCEPDe	 := Space(TamSx3("A2_CEP")[1])
Private cCEPAte	 := Space(TamSx3("A2_CEP")[1])
Private cGRCDe	 := Space(TamSx3("B1_GRUPCOM")[1])
Private cGRCAte	 := Space(TamSx3("B1_GRUPCOM")[1])
Private cFornDe	 := Space(TamSx3("C7_FORNECE")[1])
Private cFornAte := Space(TamSx3("C7_FORNECE")[1])
Private cGprUser := Space(255)
Private oRegua   :=MsNewProcess():New({||COM102PV(oRegua,"Liberando pedidos") },"Aguarde...")
Private aRetPC   := {}

oWizard:SetSize( { 600, 800 } )
oWizard:ActiveUISteps()
oStep:=oWizard:AddStep("1")
oStep:SetStepDescription("Parâmetros")
oStep:SetConstruction({|oPanel| fStep01(oPanel)})
oStep:SetNextAction({ || COM102GR()})
oStep:SetPrevAction({ || Alert("Opção inválida."),.F.})
oStep:SetCancelAction( {||.T.})
oStep:SetNextTitle( "Avançar..." )

oStep:=oWizard:AddStep("2")
oStep:SetStepDescription("Processar pedidos")
oStep:SetConstruction({|oPanel| oTmpBrowse:=fStep02(oPanel, oBrowse:=FWBrowse():New())})
oStep:SetNextAction( { || IIF(fChkMarca(oTmpBrowse:GetAlias()),oRegua:Activate(),.F.),.T. } )
oStep:SetPrevAction( { || Alert("Opção inválida."), .F. } )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Confirmar..." )

oStep:=oWizard:AddStep("3")
oStep:SetStepDescription("Resultado do processamento")
oStep:SetConstruction({|oPanel| fStep03(oPanel,aRetPC) })
oStep:SetNextAction( { || .T. } )
oStep:SetPrevAction( { || Alert("Opção inválida."), .F. } )
oStep:SetCancelAction( {|| .T. } )
oStep:SetNextTitle( "Fim" )

oWizard:Activate( )
oWizard:Destroy( )

If Select( cAliasQry ) > 0
	( cAliasQry )->( dbCloseArea( ) )
EndIf

If oTmpBrowse != Nil
	oTmpBrowse:Delete( )
EndIf

Return 



/*-----------------+---------------------------------------------------------+
!Nome              ! FStep01                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Parâmetros                                              !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 28/05/2018                                              !
+------------------+--------------------------------------------------------*/

Static Function FStep01(oPanel)
Local nLinha := 10

Local cCNPJFabrica  // CNPJ da Fabrica
Local cCNPJRestau   // CNPJ do Restaurante
Local cParEmpF		// Codigo da empresa da fabrica
Local cParFilF		// Codigo da filial da fabrica 
Local aParEmpFil	// Array do parametro MV_XFILIND
Local aSM0
Local cMsgErr	:= ""// Mensagem de erro
Local cEmpFil   := cEmpAnt+cFilAnt  

	// -> Determinar os dados da fabrica
	cCNPJFabrica:= ""
	aParEmpFil  := separa(GetMV("MV_XFILIND"), ";")
	If len(aParEmpFil) < 2 .or. empty(aParEmpFil[1]) .or. empty(aParEmpFil[2])
		cParEmpF:=GetMV("MV_XFILIND")
		cMsgErr :="Parâmetro MV_XFILIND [" + trim(cParEmpF) + "] incorreto. Esperado no formato EE;FFFFFFFFF (EE - Empresa, FFFFFFFFF - Unidade)"
		MsgAlert(cMsgErr)
		Return(.f.)
	Else
		aSM0:=SM0->(GetArea())
		SM0->(dbSetOrder(1))
		cCNPJRestau:=SM0->M0_CGC
		cParEmpF   :=trim(aParEmpFil[1])
		cParFilF   :=trim(aParEmpFil[2])
		If SM0->(dbseek(cParEmpF+cParFilF))
		   cCNPJFabrica:=SM0->M0_CGC
		   cEmpInd     :=SM0->M0_CODIGO
		Else
			SM0->(dbSetOrder(1))
			SM0->(dbseek(cEmpFil))
			SM0->(RestArea(aSM0))			
			cMsgErr :="Empresa relacionada a indústria não encontrada no ERP. [M0_CODIGO = "+cParEmpF+" / M0_CODFIL ="+cParFilF+"]"
			MsgAlert(cMsgErr)
			Return(.f.)
		EndIf
		SM0->(dbSetOrder(1))
		SM0->(dbseek(cEmpFil))		
		SM0->(RestArea(aSM0))
	EndIf
	
	cFornDe  := Posicione('SA2',3,xFilial('SA2')+cCNPJFabrica,'A2_COD')
	cFornAte := cFornDe

	TGet():New(nLinha    ,020, bSetGet(cFilDe)  ,oPanel, 070,  12 , "@!"			,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SM0","cFilDe"  ,,,,,,,'Filial de'     	,1,oPanel:oFont)
	TGet():New(nLinha    ,200, bSetGet(cCEPDe)  ,oPanel, 070,  12 , "@R 99999-999"	,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,     ,"cCEPDe"  ,,,,,,,'CEP de'        	,1,oPanel:oFont)
	nLinha += 23
	TGet():New(nLinha    ,020, bSetGet(cFilAte) ,oPanel, 070,  12 , "@!"			,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SM0","cFilAte" ,,,,,,,'Filial até'    	,1,oPanel:oFont)
	TGet():New(nLinha    ,200, bSetGet(cCEPAte) ,oPanel, 070,  12 , "@R 99999-999"	,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,     ,"cCEPAte" ,,,,,,,'CEP até'       	,1,oPanel:oFont)
	nLinha += 23
	TGet():New(nLinha    ,020, bSetGet(dDataDe) ,oPanel, 070,  12 , "@D"			,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,     ,"dDataDe" ,,,,,,,'Entrega de'    	,1,oPanel:oFont)
	TGet():New(nLinha    ,200, bSetGet(cGRCDe)  ,oPanel, 070,  12 , "@!"			,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,'SAJ',"cGRCDe"  ,,,,,,,'Grupo Compra de'	,1,oPanel:oFont)
	nLinha += 23 
	TGet():New(nLinha    ,020, bSetGet(dDataAte),oPanel, 070,  12 , "@D"			,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,     ,"dDataAte",,,,,,,'Entrega ate'   	,1,oPanel:oFont)
	TGet():New(nLinha    ,200, bSetGet(cGRCAte) ,oPanel, 070,  12 , "@!"			,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,'SAJ',"cGRCAte" ,,,,,,,'Grupo Compra até'	,1,oPanel:oFont)
	nLinha += 23
	TGet():New(nLinha    ,020, bSetGet(cUFDe)   ,oPanel, 120,  12 , "@!"			,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,'12' ,"cUFDe"   ,,,,,,,'UF de'         	,1,oPanel:oFont)
	nLinha += 23
	TGet():New(nLinha    ,020, bSetGet(cUFAte)  ,oPanel, 120,  12 , "@!"			,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,'12' ,"cUFAte"  ,,,,,,,'UF ate'        	,1,oPanel:oFont)
	nLinha += 23
	TGet():New(nLinha    ,020, bSetGet(cFornDe) ,oPanel, 120,  12 , "@!"			,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SA2","cFornDe" ,,,,,,,'Fornecedor de' 	,1,oPanel:oFont)
	nLinha += 23
	TGet():New(nLinha    ,020, bSetGet(cFornAte),oPanel, 120,  12 , "@!"			,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SA2","cFornAte",,,,,,,'Fornecedor ate'	,1,oPanel:oFont)
	nLinha += 23
	TGet():New(nLinha    ,020, bSetGet(cGprUser),oPanel, 120,  12 , "@!"			,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,     ,"cGprUser",,,,,,,'Usuários para agrupar',1,oPanel:oFont)

Return 




/*-----------------+---------------------------------------------------------+
!Nome              ! COM102GR                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Pesquisa pedidos de compra                              !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 28/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function COM102GR()
Local cQuery:=""
Local lRet	:=.F.
	
    cQuery := "SELECT DISTINCT C7_FILIAL, C7_NUM, C7_FORNECE, C7_LOJA, A2_NOME, C7_DATPRF, C7_EMISSAO " + CRLF 
	cQuery += "FROM " + RetSQLName( "SC7" ) + " SC7 INNER JOIN " + RetSQLName( "SA2" ) + " SA2        " + CRLF
	cQuery += "ON SA2.A2_FILIAL    = '" + xFilial("SA2") + "' AND " + CRLF
	cQuery += "     SA2.A2_COD     = SC7.C7_FORNECE           AND " + CRLF
	cQuery += "     SA2.A2_LOJA    = SC7.C7_LOJA              AND " + CRLF
	cQuery += "     SA2.D_E_L_E_T_ = ' '                          " + CRLF

	cQuery += " INNER JOIN " + RetSQLName( "SB1" ) + " SB1        " + CRLF
	cQuery += "ON SB1.B1_FILIAL    = '" + xFilial("SB1") + "' AND " + CRLF
	cQuery += "     SB1.B1_COD     = SC7.C7_PRODUTO           AND " + CRLF
	cQuery += "     SB1.D_E_L_E_T_ = ' '                          " + CRLF
	
	cQuery += "INNER JOIN " + RetSQLName( "ADK" ) + " ADK         " + CRLF
	cQuery += "ON ADK.ADK_FILIAL = '" + xFilial("ADK") + "'   AND " + CRLF
	cQuery += "	    ADK.ADK_XFILI  = SC7.C7_FILIAL                " + CRLF 	
	
	cQuery += "WHERE   SC7.C7_FILIAL BETWEEN '" + cFilDe     	 + "' AND '" + cFilAte 		  + "' AND " + CRLF
	cQuery += "        SA2.A2_EST BETWEEN '" + cUFDe 			 + "' AND '" + cUFAte 		  + "' AND " + CRLF
	cQuery += "        SB1.B1_GRUPCOM BETWEEN '" + cGRCDe 	     + "' AND '" + cGRCAte 		  + "' AND " + CRLF
	
	cQuery += "        SC7.C7_DATPRF  BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' AND " + CRLF
	cQuery += "        SC7.C7_FORNECE BETWEEN '" + cFornDe       + "' AND '" + cFornAte       + "' AND " + CRLF
	cQuery += "        SC7.C7_XENVCR       <> 'L'                                                  AND " + CRLF
	cQuery += "        SC7.C7_CONAPRO      <> 'B'                                                  AND " + CRLF
	cQuery += "        SC7.D_E_L_E_T_ = ' '                                                            " + CRLF
	cQuery += "ORDER BY C7_FILIAL, C7_NUM, C7_DATPRF "                                                   + CRLF
	cAliasQry :=MPSysOpenQuery(cQuery)
	lRet      :=(cAliasQry )->(!Eof())
	(cAliasQry)->(DbGoTop())
	
	If !lRet
		Alert( "Não foram encontrados registros para processamento." )
	EndIf

Return lRet



/*-----------------+---------------------------------------------------------+
!Nome              ! fStep02                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Exibe pedidos de compra                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 28/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function fStep02(oPanel,oBrowse)
Local oMark 	:= FWTemporaryTable():New()
Local aStruct 	:= (cAliasQry)->(dbStruct())

	// -> Acrescenta o campo de mark
	AAdd( aStruct, { } )
	AIns( aStruct, 1 )
	aStruct[01]:={"OK", "L", 1, 0 }
	oMark:SetFields( aStruct )

	// -> Definindo indice
	oMark:AddIndex("01", { "C7_FILIAL", "C7_NUM", "C7_FORNECE", "C7_LOJA" } ) 
	oMark:Create()
	cAliasAux:=oMark:GetAlias( )

	While (cAliasQry)->(!Eof())
		RecLock(cAliasAux,.T.)
			(cAliasAux)->OK 		:= .F.
			(cAliasAux)->C7_FILIAL 	:= (cAliasQry)->C7_FILIAL
			(cAliasAux)->C7_NUM		:= (cAliasQry)->C7_NUM
			(cAliasAux)->C7_FORNECE	:= (cAliasQry)->C7_FORNECE
			(cAliasAux)->C7_LOJA	:= (cAliasQry)->C7_LOJA
			(cAliasAux)->A2_NOME	:= (cAliasQry)->A2_NOME
			(cAliasAux)->C7_DATPRF	:= (cAliasQry)->C7_DATPRF
			(cAliasAux)->C7_EMISSAO	:= (cAliasQry)->C7_EMISSAO
			(cAliasAux)->(MsUnlock())
			(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	oBrowse:SetDescription("Liberação de Pedidos - MRP")
	oBrowse:SetOwner( oPanel )
	oBrowse:SetDataTable( .T. )
	oBrowse:SetAlias( cAliasAux )
	oBrowse:AddMarkColumns( ;
	{|| If( ( cAliasAux )->OK , "LBOK", "LBNO" ) },;
	{||  ( cAliasAux )->OK :=  ! ( cAliasAux )->OK } ,;
	{|| MarkAll( oBrowse ) } )	
	oBrowse:SetColumns({;
		AddColumn({|| ( cAliasAux )->C7_FILIAL 	},"Filial"		 , TamSX3("C7_FILIAL")[1]  , , "C") ,;
		AddColumn({|| ( cAliasAux )->C7_NUM     },"Num. Pedido"	 , TamSX3("C7_NUM")[1]     , , "C") ,;
		AddColumn({|| ( cAliasAux )->C7_EMISSAO },"Emissão"	     , 08                      , , "D") ,;
		AddColumn({|| ( cAliasAux )->C7_FORNECE },"Fornecedor"   , TamSX3("C7_FORNECE")[1] , , "C") ,;
		AddColumn({|| ( cAliasAux )->C7_LOJA 	},"Loja"		 , TamSX3("C7_LOJA"   )[1] , , "C") ,;
		AddColumn({|| ( cAliasAux )->A2_NOME 	},"Nome"		 , TamSX3("A2_NOME")[1]    , , "C") ,;
		AddColumn({|| ( cAliasAux )->C7_DATPRF 	},"Prev. Entrega", TamSX3("C7_DATPRF")[1]  , , "C")  ;
	})
	oBrowse:SetDoubleClick({|| ( cAliasAux )->OK := !( cAliasAux )->OK })

	oBrowse:DisableReport()
	oBrowse:DisableConfig()
	oBrowse:DisableFilter()
	oBrowse:Activate()

Return oMark



/*-----------------+---------------------------------------------------------+
!Nome              ! fChkMarca                                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Verifica marcção dos pedidos                            !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 29/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function fChkMarca(cAliasAtu)
Local lRet := .F.
Local aArea:= (cAliasAtu)->(GetArea())

	(cAliasAtu)->(dbGoTop())
	While (cAliasAtu )->(!Eof())
		If (cAliasAtu)->OK
			lRet:=.T.
			Exit
		EndIf
		(cAliasAtu)->(dbSkip())
	EndDo 

	If !lRet
		Alert( "Nenhum registro foi selecionado." )
	EndIf

RestArea( aArea )

Return lRet 




/*-----------------+---------------------------------------------------------+
!Nome              ! MarkAll                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Funcao para marcar / desmarcar os dados                 !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 29/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static function MarkAll(oBrowse)

	(oBrowse:GetAlias())->( dbGotop() )
	(oBrowse:GetAlias())->( dbEval({|| OK := !OK },, { || ! Eof() }))
	(oBrowse:GetAlias())->( dbGotop() )
	oBrowse:Refresh(.T.)

Return



/*-----------------+---------------------------------------------------------+
!Nome              ! AddColumn                                               !
+------------------+---------------------------------------------------------+
!Descrição         ! monta coluna do mBrowse                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 29/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function AddColumn(bData,cTitulo,nTamanho,nDecimal,cTipo,cPicture)
Local oColumn

	oColumn := FWBrwColumn():New()
	oColumn:SetData( bData )
	oColumn:SetTitle(cTitulo)
	oColumn:SetSize(nTamanho)
	If nDecimal != Nil
		oColumn:SetDecimal(nDecimal)
	EndIF
	oColumn:SetType(cTipo)
	If cPicture != Nil
		oColumn:SetPicture(cPicture)
	EndIf

Return oColumn


/*-----------------+---------------------------------------------------------+
!Nome              ! COM102PV                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Libera os pedidos de compra para a fabrica              !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 29/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function COM102PV()
Local nRegistros:= 0
Local lOk    	:= .T.
Local aMarcados	:= {}
Local cQry      := "" 
Local cAQry     := GetNextAlias( )
Local cEmpInd   := ""
Local aErros    := {}    
Local aErroAux  := {}    
Local cMsgErr	:= ""// Mensagem de erro
Local cEmpFil   := cEmpAnt+cFilAnt  
Local lAux      := .F.
Local nInd
Local nxz   
Local aParm			// Array de parametros para ACOM103
Local cCNPJFabrica  // CNPJ da Fabrica
Local cCNPJRestau   // CNPJ do Restaurante
Local cParEmpF		// Codigo da empresa da fabrica
Local cParFilF		// Codigo da filial da fabrica 
Local aParEmpFil	// Array do parametro MV_XFILIND
Local aSM0


	// -> Varrendo marcados da tabela temporaria
	DbSelectArea(cAliasAux)
	(cAliasAux)->(dbGoTop())
	While !(cAliasAux)->(Eof())
		If (cAliasAux)->OK 
			aadd(aMarcados,{(cAliasAux)->C7_FILIAL,(cAliasAux)->C7_NUM,""})
			nRegistros++		
		EndIf
		(cAliasAux)->(dbSkip())
	Enddo

	// -> Determinar os dados da fabrica
	cCNPJFabrica:= ""
	aParEmpFil  := separa(GetMV("MV_XFILIND"), ";")
	If len(aParEmpFil) < 2 .or. empty(aParEmpFil[1]) .or. empty(aParEmpFil[2])
		cParEmpF:=GetMV("MV_XFILIND")
		cMsgErr :="Parâmetro MV_XFILIND [" + trim(cParEmpF) + "] incorreto. Esperado no formato EE;FFFFFFFFF (EE - Empresa, FFFFFFFFF - Unidade)"
		MsgAlert(cMsgErr)
		Return(.f.)
	Else
		aSM0:=SM0->(GetArea())
		SM0->(dbSetOrder(1))
		cCNPJRestau:=SM0->M0_CGC
		cParEmpF   :=trim(aParEmpFil[1])
		cParFilF   :=trim(aParEmpFil[2])
		If SM0->(dbseek(cParEmpF+cParFilF))
		   cCNPJFabrica:=SM0->M0_CGC
		   cEmpInd     :=SM0->M0_CODIGO
		Else
			SM0->(dbSetOrder(1))
			SM0->(dbseek(cEmpFil))
			SM0->(RestArea(aSM0))			
			cMsgErr :="Empresa relacionada a indústria não encontrada no ERP. [M0_CODIGO = "+cParEmpF+" / M0_CODFIL ="+cParFilF+"]"
			MsgAlert(cMsgErr)
			Return(.f.)
		EndIf
		SM0->(dbSetOrder(1))
		SM0->(dbseek(cEmpFil))		
		SM0->(RestArea(aSM0))
	EndIf
	
	// -> Verifica se os clientes relacionados aos restaurante estão cadastrados na indústria
	For nInd := 1 to len(aMarcados)
		cAux   :="Restaurante(s) nao encontrados no cadastro de cliente da indústria:"+Chr(13)+Chr(10)
		cMsgErr:=""
		
		// -> Posiciona no pedido de compra
		SC7->(dbSetOrder(1))
		SC7->(dbSeek(aMarcados[nInd,1]+aMarcados[nInd,2]))
		
		// -> Posiciona no fornecedor
		SA2->(dbSetOrder(1))
		SA2->(dbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA))
		aErros:={}
		// -> Verifica se o pedido é da fábrica
		If AllTrim(cCNPJFabrica) == AllTrim(SA2->A2_CGC) 
		
			// -> Posiciona na unidade de negócio
			MsgErr:=""
			ADK->(DbOrderNickName("ADKXFILI"))
			If ADK->(DbSeek(xFilial("ADK")+aMarcados[nInd,1]))
			   	// -> Verifica se o cliente existe na indústria
			   	cQry := "SELECT A1_COD, A1_LOJA, A1_NOME, A1_COND, A1_VEND, A1_NATUREZ, A1_TRANSP " 
				cQry += "FROM SA1"+cEmpInd+"0                          " 
			   	cQry += "  WHERE D_E_L_E_T_ <> '*'                 AND " 
				cQry += "        A1_CGC      = '" + ADK->ADK_CNPJ + "' "
			   	cAQry :=MPSysOpenQuery(cQry)
				// -> Verifica se encontrou o cliente cadastrado
				If (cAQry)->(Eof())
					cMsgErr:="Restaurante(s) nao encontrados no cadastro de cliente da indústria:"+Chr(13)+Chr(10)
				   	cMsgErr+=IIF(Len(cMsgErr)<=0,cAux+ADK->ADK_CNPJ + " - " + ADk->ADK_NOME + Chr(13)+Chr(10),ADK->ADK_CNPJ + " - " + ADk->ADK_NOME + Chr(13)+Chr(10))
				Else
					(cAQry)->(DbGoTop())
					// -> Verifica a transportadora
					If AllTrim((cAQry)->A1_TRANSP) == ""
						MsgErr+="Transportadora invalida para o cliente: "+(cAQry)->A1_COD+"/"+(cAQry)->A1_LOJA+Chr(13)+Chr(10)
					EndIf			
					// -> Verifica a condição de pagamento
					If AllTrim((cAQry)->A1_COND) == ""
						MsgErr+="Condicao de pagamento invalida para o cliente: "+(cAQry)->A1_COD+"/"+(cAQry)->A1_LOJA+Chr(13)+Chr(10)
					EndIf			
					// -> Verifica natureza
					If AllTrim((cAQry)->A1_NATUREZ) == ""
						MsgErr+="Natureza invalida para o cliente: "+(cAQry)->A1_COD+"/"+(cAQry)->A1_LOJA+Chr(13)+Chr(10)
					EndIf			
					// -> Verifica vendedor
					If AllTrim((cAQry)->A1_VEND) == ""
						MsgErr+="Vendedor invalido para o cliente: "+(cAQry)->A1_COD+"/"+(cAQry)->A1_LOJA+Chr(13)+Chr(10)
					EndIf			
				EndIf
				(cAQry)->(DbCloseArea())
			EndIf
			
		EndIf	
		
	Next nInd
	
	// -> Verifica se houve erro
	If !EmpTy(cMsgErr)
		MsgAlert(cMsgErr)
		Return(.f.)
	EndIf
		
	// -> Se não ocorreu erro, continua
	If empty(cMsgErr)
		oRegua:SetRegua1(1)
		oRegua:SetRegua2(len(aMarcados))
		oRegua:IncRegua2('Gerando pedidos de vendas na industria...')
		
		// -> Incluindo pedidos na industria		
		aParm:={}
		For nInd := 1 to len(aMarcados)
			// -> Posiciona no pedido de compra
			SC7->(dbSetOrder(1))
			SC7->(dbSeek(aMarcados[nInd,1]+aMarcados[nInd,2]))
			// -> Posiciona no fonecedor
			SA2->(dbSetOrder(1))
			SA2->(dbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA))
			// -> Se o pedido for da fábrica, adiciona no array 
			If AllTrim(cCNPJFabrica) = AllTrim(SA2->A2_CGC)
				aSM0:=SM0->(GetArea())
				SM0->(dbSetOrder(1))
				SM0->(dbseek(cEmpAnt+SC7->C7_FILIAL))
				cCNPJRestau := SM0->M0_CGC
				SM0->(dbSetOrder(1))
				SM0->(dbseek(cEmpFil))				
				SM0->(RestArea(aSM0))
				
				// Posicao 1 = Empresa destino (da fábrica)
				// Posicao 2 = Filial destino (da fábrica)
				// Posicao 3 = Grupo de Empresas originais (de onde buscar os PCs - obtido a partir do cEmpAnt)
				// Posicao 4 = Filial Original do Pedido
				// Posicao 5 = CNPJ do cliente do Pedido
				// Posicao 6 = Numero do Pedido Original
				// Posicao 7 = Data de inclusao do pedido
				// Posicao 8 = Usuario de inclusao do pedido
				//aadd(aParm, {cParEmpF,  cParFilF, cEmpAnt, SC7->C7_FILIAL, cCNPJRestau, SC7->C7_NUM, dDataBase, UsrRetName(RetCodUsr())})
				
				//#TB20191120 Thiago Berna - Ajuste para nao duplicar parametros
				If aScan(aParm,  {|x| x[4] == SC7->C7_FILIAL}) == 0
					//aadd(aParm, {cParEmpF,  cParFilF, cEmpAnt, SC7->C7_FILIAL, cCNPJRestau, SC7->C7_NUM, dDataBase, UsrRetName(RetCodUsr()),cGRCDe,cGRCAte,dDataDe,dDataAte})
					aadd(aParm, {cParEmpF,  cParFilF, cEmpAnt, SC7->C7_FILIAL, cCNPJRestau, "'" + AllTrim(SC7->C7_NUM) + "'", dDataBase, UsrRetName(RetCodUsr()),cGRCDe,cGRCAte,dDataDe,dDataAte})
				Else
					aParm[aScan(aParm,  {|x| x[4] == SC7->C7_FILIAL})][6] += ",'" + AllTrim(SC7->C7_NUM) + "'"
				EndIf
				aMarcados[nInd,3]:=SC7->C7_FILIAL+SC7->C7_NUM
			Endif
		Next nInd
		
		// -> Gera pedidos na Indústria
		If Len(aParm) > 0
			
			aErros  :=startJob("U_COM103", GetEnvServer(), .T., aParm)
			aErroAux:=aErros
			VarInfo("aErros",aErros)
			If !ValType(aErros) == "A"
				//MsgAlert('A variável aErros não parece ser do tipo Array...','MADERO_COM102')
				aErros := {}
				aErrosAux	:= {}
			EndIf
			
			// -> Verifica erros
			cMsgErr:=""
			//#TB20191009 Thiago Berna - Ajuste para verificar se aErros possui registros antes de validar
			If Len(aErros) > 0
				If ValType(aErros[1]) == "A"
					For nxz:=1 to Len(aErros[1])
						aadd(aRetPC,{aErros[1][nxz,1],aErros[1][nxz,2],AllTrim(cMsgErr),"",aErros[1],{}})
						lOk:=.F.					
					Next nxz
				Else
					aadd(aRetPC,{"","","","","",{}})
				EndIf
			EndIf

		//#TB20200528 Thiago Berna - Ajuste para que seja considerado o envio de email para todos os casos
		EndIf
			
			// -> Envia e-mail e processa erros
			lAux  :=.F.
			aErros:={}
			For nInd := 1 to len(aMarcados)
				
				lAux:=.F.
				// -> Posiciona no pedido de compra
				SC7->(dbSetOrder(1))
				SC7->(dbSeek(aMarcados[nInd,1]+aMarcados[nInd,2]))
				
				// -> Posiciona no fonecedor
				SA2->(dbSetOrder(1))
				SA2->(dbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA))
				
				oRegua:IncRegua2('Atualizando pedido '+SC7->C7_NUM)	
				cMsgErr:=""
				
				//#TB20200323 Thiago Berna - Ajuste para identificar corretamente quando ocorreu um erro
				//If !Empty(aMarcados[nInd,3]) //.and. Len(aErroAux[1]) > 0 
				If !Empty(aMarcados[nInd,3]) .and. Len(aErroAux[1]) > 0 
					lAux:=.F.
				Else
					lAux:=.T.
				EndIf	
				
				// -> Se o pedido foi processado sem erro, atualiza
				If lAux 

					// -> Atualiza pedido de compra
					SC7->(dbSetOrder(1))
					SC7->(dbSeek(aMarcados[nInd,1]+aMarcados[nInd,2]))
				
					//#TB20191120 Thiago Berna - Ajuste para comparar corretamente o campo filial.
					//While !SC7->(Eof()) .and. xFilial("SC7") == aMarcados[nInd,1] .and. SC7->C7_NUM == aMarcados[nInd,2]
					While !SC7->(Eof()) .and. SC7->C7_FILIAL == aMarcados[nInd,1] .and. SC7->C7_NUM == aMarcados[nInd,2]
				
						RecLock("SC7", .f.)
						SC7->C7_XENVCR := "L" 
						SC7->(MsUnlock())
						SC7->(DbSkip())
					EndDo	
					
					// -> Reposiciona no pedido de compra
					SC7->(dbSetOrder(1))
					SC7->(dbSeek(aMarcados[nInd,1]+aMarcados[nInd,2]))
					aadd(aRetPC,{aMarcados[nInd,1],aMarcados[nInd,2],"Liberado.","",{},{}})

					aErros := U_COM101E()
					If Len(aErros) <= 0
						// -> Atualiza pedido de compra
						SC7->(dbSetOrder(1))
						SC7->(dbSeek(aMarcados[nInd,1]+aMarcados[nInd,2]))
						//#TB20191120 Thiago Berna - Ajuste para comparar corretamente o campo filial.
						//While !SC7->(Eof()) .and. xFilial("SC7") == aMarcados[nInd,1] .and. SC7->C7_NUM == aMarcados[nInd,2]
						While !SC7->(Eof()) .and. SC7->C7_FILIAL == aMarcados[nInd,1] .and. SC7->C7_NUM == aMarcados[nInd,2]
							RecLock("SC7", .f.)
							SC7->C7_XEMAIL := "E"  
							SC7->(MsUnlock())
							SC7->(DbSkip())
						EndDo	
						// -> Reposiciona no pedido de compra
						SC7->(dbSetOrder(1))
						SC7->(dbSeek(aMarcados[nInd,1]+aMarcados[nInd,2]))
						aRetPC[Len(aRetPC),3]:="Enviado e-mail."
						aRetPC[Len(aRetPC),6]:={}
					Else
						aRetPC[Len(aRetPC),3]:="e-mail nao enviado."
						aRetPC[Len(aRetPC),6]:=aErros
						lOk:=.F.					
					Endif
				Endif
			Next nInd
			
			oRegua:IncRegua1("Processado.")	
		
		//#TB20200528 Thiago Berna - Ajuste para que seja considerado o envio de email para todos os casos
		//EndIf

	EndIf
	

Return(.T.)


/*-----------------+---------------------------------------------------------+
!Nome              ! fShowErro                                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Exibe os erros                                          !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 28/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function fStep03(oPanel,aErro)
Local cErro		:= ""
Local nj,nb:=0
Local cFil


	// -> Formata dados a serem exibidos
	cFil :=""
	cErro:=""
	For nj:=1 to Len(aErro)
		// -> Posiciona na filial do Log
		ADK->(DbOrderNickName("ADKXFILI"))
		ADK->(DbSeek(xFilial("ADK")+aErro[nj,1]))
		If AllTrim(cFil) <> AllTrim(aErro[nj,1])
			cErro+="======================================================================================================================" + Chr(13) + Chr(10)
			cErro+="Filial: "+ ADK->ADK_XFILI + " - " + ADK->ADK_NOME                                                                       + Chr(13) + Chr(10)
		EndIf
		cErro+="-> Pedido: "+aErro[nj,2]+" :"+IIF(Len(aErro[nj,5])<=0,"Pedido Ok. :","Erro na geração do Pedido. :")                        + Chr(13) + Chr(10) 	
		// -> Exibe erro no Pedido
		If Len(aErro[nj,5]) > 0
			For nb:=1 to Len(aErro[nj,5])
				cErro+=":"+aErro[nj,5,nb,3]+":"+aErro[nj,5,nb,4]+":"+aErro[nj,5,nb,5] + Chr(13) + Chr(10)	   
			Next nb
		EndIf			   
		// -> Exibe erro no envio do e-mail do Pedido
		If Len(aErro[nj,6]) > 0
			cErro+=": e-mail nao enviado ao fornecedor. " + Chr(13) + Chr(10)
			//For nb:=1 to Len(aErro[nj,6])
			//	cErro+=":"+aErro[nj,6,nb,3]+":"+aErro[nj,6,nb,4]+":"+aErro[nj,6,nb,5] + Chr(13) + Chr(10)	   
			//Next nb
		ElseIf Len(aErro[nj,5]) <= 0
			cErro+=": e-mail enviado ao fornecedor. " + Chr(13) + Chr(10)
		EndIf			   
		cFil:=aErro[nj,1]
	Next nj

	//#TB20191118 Thiago Berna - String tem limite maximo de 1048575
	If Len(cErro) > 1000000
		If MSGYESNO('O arquivo de LOG completo não pode ser exibido na tela. Deseja salvar ele em arquivo?', 'LOG de Erros' )
			fSalvArq(cErro, 'MADERO_COM102')
		EndIf
		cErro := SubStr(cErro,1,1000000)
	EndIf

	oTMultiget1:=tMultiget():new( 01, 01, {| u | if( pCount() > 0, cErro := u, cErro ) }, oPanel, 400, 200, , , , , ,.T., , , , , ,.F., , , , , , , , , )
  	oTMultiget1:EnableVScroll( .T. )

	
      
Return(.T.)

/*---------------------------------------------------------------------*
| Func:  SalvaLog                                                     |
| Autor: Thiago Berna                                                 |
| Data:  12/Setembro/2019                                             |
| Desc:  Salva Log Gerado                                             |
| Obs.:  Especifico Madero                                            |
*---------------------------------------------------------------------*/

Static Function fSalvArq(cMsg, cTitulo)
	Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".txt"
	Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
	Local lOk      := .T.
	Local cTexto   := ""

	//Pegando o caminho do arquivo
	cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,'',.T., GETF_LOCALHARD)

	//Se o nome não estiver em branco    
	If !Empty(cFileNom)
		//Teste de existência do diretório
		If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
			Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
			Return
		EndIf

		//Montando a mensagem
		cTexto := "Função   - "+ FunName()       + CRLF
		cTexto += "Usuário  - "+ cUserName       + CRLF
		cTexto += "Data     - "+ dToC(dDataBase) + CRLF
		cTexto += "Hora     - "+ Time()          + CRLF
		cTexto += "Mensagem - "+ cTitulo + cQuebra  + cMsg + cQuebra

		//Testando se o arquivo já existe
		If File(cFileNom)
			lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
		EndIf

		If lOk
			MemoWrite(cFileNom, cTexto)
			MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atenção")
		EndIf
	EndIf
Return
