/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! COM504                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Cadastro de produtos x fornecedores - MADERO                                  !
!                  !                                                                               !
!                  ! Contempla as funcionalidades de inclusão de mais de um fornecedor, fatores de !
!                  ! conversão e perações fiscais utilizadas pelo MADERO                           !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 17/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! AMATA060                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Cadastro de produtos x fornecedores - MADERO                                  !
!                  !                                                                               !
!                  ! Contempla as funcionalidades de inclusão de mais de um fornecedor, fatores de !
!                  ! conversão e perações fiscais utilizadas pelo MADERO                           !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Márcio Zaguetti                                                               !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 17/05/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function AMATA060(xRotAuto,nOpcAuto)
Local lMA060FIL	:= ExistBlock("MA060FIL")
Local cFiltraSA5:= ""
Local aIndexSA5	:= {}
Local bFiltraBrw:= Nil
Default nOpcAuto:= 3
Private aRotAuto := Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemtoAnsi("Atualizacao Produto x Fornecedor")  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha Area													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA5")
//DbCloseArea() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If xRotAuto <> Nil
	aRotAuto := xRotAuto
	MBrowseAuto(nOpcAuto,aRotAuto,"SA5", .F.)
Else
	If lMA060FIL
		cFiltraSA5 := ExecBlock("MA060FIL",.F.,.F.)
		bFiltraBrw := {|| FilBrowse("SA5",@aIndexSA5,@cFiltraSA5)}
		Eval(bFiltraBrw)
	EndIf
	
	mBrowse(6,1,22,75,"SA5")
	
	If lMA060FIL
		EndFilBrw("SA5",aIndexSA5)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha Area													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SA5")
DbCloseArea() 
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A060Manut³ Autor ³ Vera Lucia S. Simoes  ³ Data ³26/02/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclui e Altera uma amarracao Produto X Fornecedor         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Alias posicionado                                   ³±±
±±³          ³ ExpN1: Numero do registro posicionado                      ³±±
±±³          ³ ExpN2: Opcao do menu selecionada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AA060Man(cAlias,nReg,nOpc)

Local nOpca 			:= 0
Local lHistTab   		:= SuperGetMV("MV_HISTTAB", .F., .F.)
Local cFilialAIF 		:= xFilial("AIF")
Local cFilialSA5 		:= xFilial("SA5")
Local dDataAlt
Local nX				:= 0
Local cHoraAlt

Private aCpoAltSA5	:= {} // vetor usado na gravacao do historico de alteracoes
                                          
If nModulo == 21	// SIGAQIE
	cSitAnt := If(!INCLUI,A5_SITU,  Space(TamSX3("A5_SITU")[1]  )) //Situacao anterior
	cSklAnt := If(!INCLUI,A5_SKPLOT,Space(TamSX3("A5_SKPLOT")[1])) //Skip-Lote anterior
	cChvHis := If(!INCLUI,A5_CHAVE, Space(TamSX3("A5_CHAVE")[1] )) //Chave ligacao com as justificativas
EndIf
If nOpc == 3                       
	nOpcA:=AxInclui(cAlias,nReg,nOpc,/*aAcho*/,,/*aCpos*/,"u_A060Val() .And. u_MA060TUD().and.u_A060FABR()",/*lF3*/,/*cTransact*/,/*aButtons*/,/*aParam*/,aRotAuto,.T.)
Else
	nOpcA:=AxAltera(cAlias,nReg,nOpc,/*aAcho*/,/*aCpos*/,/*nColMens*/,/*cMensagem*/,"u_A060Val().and.u_MA060TUD()",/*cTransact*/,/*cFunc*/,/*aButtons*/,/*aParam*/,aRotAuto,.T.)
EndIf                        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava a chave do Historico utilizado na Inspecao de Entradas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == 1
	If (nModulo == 21) //SIGAQIE
		If Empty(SA5->A5_CHAVE)
			If Empty(cChvHis)
				cChvHis := u_A060Cha()
			EndIf
			RecLock("SA5",.F.)
			SA5->A5_CHAVE := cChvHis
			MsUnLock()
		EndIf	
	
		If cSitAnt <> SA5->A5_SITU .And. !Empty(cSitAnt)
			// Monta/Obtem a chave para o Historico/Justificativa
			If Empty(cChvHis)
				cChvHis := u_A060Cha()
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Digita a Justificativa e gera Historico da Situacao             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QA_JUST(OemToAnsi("Justificativa Situacao"),"MATA060T",cChvHis,.F.,cSitAnt) //"Justificativa Situa‡„o"
		EndIf	
   	
		If cSklAnt <> SA5->A5_SKPLOT .And. !Empty(cSklAnt)
			// Monta/Obtem a chave para o Historico/Justificativa
			If Empty(cChvHis)
				cChvHis := u_A060Cha()
			EndIf
		
			If Empty(SA5->A5_SKPLOT)	// Alter. automat. pelo sistema, ao alterar a Situacao
				RecLock("QA3",.T.)
				QA3->QA3_FILIAL := xFilial("QA3")
				QA3->QA3_ESPEC  := "MATA060L"
				QA3->QA3_CHAVE  := cChvHis
				QA3->QA3_TEXTO  := "Atualizado automaticamente pelo sistema."
				QA3->QA3_DATA   := dDataBase
				QA3->QA3_DATINV := Inverte(dDataBase)
				QA3->QA3_ANT    := cSklAnt
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Digita a Justificativa e gera Historico do Skip-Lote            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QA_JUST("Justificativa Skip-Lote","MATA060L",cChvHis,.F.,cSklAnt) //"Justificativa Skip-Lote"
			EndIf
		EndIf 
	EndIf  
	If ExistTemplate("MT060GRV")		
		ExecTemplate("MT060GRV",.F.,.F.)
	EndIf
	If ExistBlock("MT060GRV")		
		ExecBlock("MT060GRV",.F.,.F.)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aciona integração via mensagem única          				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	FwIntegDef( 'AMATA060' )
		
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravar o historico das alteracoes realizadas pelo usuario    ³
//³na tabela AIF usando o vetor aCpoAltSA5 que foi carregado na ³
//³funcao A060TudOk().                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lHistTab .And. Len(aCpoAltSA5) > 0
	dDataAlt := Date()
	cHoraAlt := Time()
	For nX := 1 To Len(aCpoAltSA5)
		MSGrvHist(cFilialAIF,;			// Filial de AIF
		cFilialSA5,;					// Filial da tabela SA5
		"SA5",;							// Tabela SA5
		SA5->A5_FORNECE,;				// Codigo do cliente
		SA5->A5_LOJA,;					// Loja do cliente
		aCpoAltSA5[nX][1],;				// Campo alterado
		aCpoAltSA5[nX][2],;				// Conteudo antes da alteracao
		dDataAlt,;						// Data da alteracao
		cHoraAlt,;						// Hora da alteracao
		SA5->A5_PRODUTO)				// Codigo do produto							
	Next nX
	aCpoAltSA5 := {} // limpar o vetor
EndIf

dbSelectArea(cAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A060Valid³ Autor ³ Vera Lucia S. Simoes  ³ Data ³26/02/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da inclusao/alteracao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Nome do campo                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function A060Val()
Local aAreaSA5 	  := SA5->(GetArea())
Local cSeekSA5    := ""
Local nRec        := SA5->(RecNo())
Local lRet        := .T.
Local lRetPE      := .T.
Local nEndereco   := 0
Local lReferencia := .F.
Local lGrade	  := MaGrade()
Local oModel	  := FWModelActive()
Local lIsInMVC	  := ValType(oModel) <> "U" .And. oModel:GetId() == "u_AMATA061"
Local oField  	  := If(lIsInMVC,oModel:GetModel("MdFieldSA5"),NIL)
Local oGrid		  := If(lIsInMVC,oModel:GetModel("MdGridSA5"),NIL)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para e-Commerce      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lECommerce  := SuperGetMV("MV_LJECOMM",.F.,.F.)
Local lPrForFab	  := SuperGetMV('MV_PRFOFAB',.F.,.F.)
Local cQuery      := ""
Local cAliasQry   := ""
Local nAuxFab     := 0

cNomeCampo := READVAR()
cNomeCampo := If(Left(cNomeCampo,3)="M->",Subs(cNomeCampo,4),cNomeCampo)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atenção: A validação da amarração Produto X Fornecedor tem comportamento      |
//³ diferente quando é efetuada através do módulo de Compras/outros módulos       |
//³ do que quando é efetuada através do módulo SigaEIC.							  |		 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


// -> Veifica a chave do fabricante na inclusão
If Inclui
	cQuery:="SELECT MAX(A5_FALOJA) COUNT " 
	cQuery+="FROM " + RetSQLName( "SA5" ) + " SA5 " 
	cQuery+="WHERE A5_FILIAL  = '" + xFilial("SA5") + "' AND " 
	cQuery+="      A5_FORNECE = '" + M->A5_FORNECE  + "' AND " 
	cQuery+="      A5_LOJA    = '" + M->A5_LOJA     + "' AND " 
	cQuery+="      A5_PRODUTO = '" + M->A5_PRODUTO  + "' AND " 
	cQuery+="      A5_FABR    = '" + M->A5_FORNECE  + "' AND " 
//	cQuery+="      A5_CODPRF  = '" + M->A5_CODPRF   + "' AND " 
//	cQuery+="      A5_FALOJA  = '" + M->A5_FALOJA   + "' AND " 
	cQuery+="      D_E_L_E_T_ <> '*'                         "
	cAliasQry :=MPSysOpenQuery(cQuery)
	If (cAliasQry)->(!Eof())
		nAuxFab:=VAL((cAliasQry)->COUNT)+1
	Else
		nAuxFab:=1
	EndIf
	(cAliasQry)->(DbCloseArea())
	M->A5_FABR  :=M->A5_FORNECE
	M->A5_FALOJA:=StrZero(nAuxFab,TamSx3("A5_FALOJA")[1])
EndIf



If cNomeCampo == 'A5_FABR'
	If Empty(If(lIsInMVC,oGrid:GetValue("A5_FABR"),M->A5_FABR))
		Help(" ",1,"A060FABR")
		lRet := .F.
	ElseIf !SA2->(dbSeek(xFilial("SA2")+If(lIsInMVC,oGrid:GetValue("A5_FABR"),M->A5_FABR)))
		Help(" ",1,"REGNOIS")
		lRet := .F.
	ElseIf LEFT(SA2->A2_ID_FBFN,1) = '2'
		Help(" ",1,"A060FABRNO")
		lRet := .F.
	ElseIf Inclui
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Preenche a loja corretamente                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		/*If (nModulo <> 17 .Or. EicLoja())
	    	If lIsInMVC
				oGrid:LoadValue("A5_FALOJA",SA2->A2_LOJA)
			Else
				M->A5_FALOJA := SA2->A2_LOJA
				nEndereco := Ascan(aGets,{ |x| Subs(x,9,9) == "A5_FALOJA" } )
				If nEndereco > 0
					aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := SA2->A2_LOJA
				EndIf
			EndIf
		EndIf*/
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a chave para pesquisa                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SA5->(DbOrderNickName("A5CODPRF"))
		If StrTran(SA5->(IndexKey())," ","") == "A5_FORNECE+A5_LOJA+A5_PRODUTO+A5_CODPRF"
			If lIsInMVC
				cSeekSA5 := xFilial("SA5")+oField:GetValue("A5_FORNECE")+oGrid:GetValue("A5_LOJA")+oGrid:GetValue("A5_PRODUTO")+oGrid:GetValue("A5_CODPRF")
			Else
				cSeekSA5 := xFilial("SA5")+M->A5_FORNECE+M->A5_LOJA+M->A5_PRODUTO+M->A5_CODPRF
			EndIf
		Else
			If lIsInMVC
				cSeekSA5 := xFilial("SA5")+oField:GetValue("A5_PRODUTO")+oGrid:GetValue("A5_FABR")+oGrid:GetValue("A5_FORNECE")
			Else
				cSeekSA5 := xFilial("SA5")+M->A5_PRODUTO+M->A5_FABR+M->A5_FORNECE
			EndIf
		EndIf
		
		If SA5->(DbSeek(cSeekSA5))
			If ((nModulo == 17 .Or. nModulo == 29) .And. EicLoja()) .Or. (nModulo == 2 .Or. nModulo == 4) 			
            	While SA5->(!EOF()) .And. SA5->A5_FILIAL  == xFilial("SA5")						.And.;
            	      SA5->A5_PRODUTO == If(lIsInMVC,oField:GetValue("A5_PRODUTO"),M->A5_PRODUTO)	.And.;
            	      SA5->A5_FABR    == If(lIsInMVC,oGrid:GetValue("A5_FABR"),M->A5_FABR)   		.And.;
            	      SA5->A5_FORNECE == If(lIsInMVC,oGrid:GetValue("A5_FORNECE"),M->A5_FORNECE)

	                If SA5->(A5_LOJA+A5_FALOJA) == If(lIsInMVC,oGrid:GetValue("A5_LOJA")+oGrid:GetValue("A5_FALOJA"),M->A5_LOJA+M->A5_FALOJA)
                		lRet := .F.
                    	Exit
            		EndIf   
					SA5->(DBSkip())
				End
				If !lRet
					SA5->(DbSetOrder(1))
					SA5->(DbGoTo(nRec))
					Help(" ",1,"A060EXISTE")
				EndIf
			Else
				SA5->(DbSetOrder(1))
				SA5->(DbGoTo(nRec))
				Help(" ",1,"A060EXISTE")
				lRet := .F.
			EndIf
		EndIf
	ElseIf If (lIsInMVC, !oGrid:IsInserted(), .T.) .And. SA5->A5_FABR # If(lIsInMVC,oGrid:GetValue("A5_FABR"),M->A5_FABR) ;
			.And. !Empty(SA5->A5_FABR)
		Help(" ",1,"A060FABREX")
		lRet := .F.
	EndIf
	SA5->(DbSetOrder(1))
	SA5->(DbGoTo(nRec))
Else
	If cNomeCampo == 'A5_FORNECE' .OR. cNomeCampo == 'A5_LOJA' .OR. cNomeCampo == 'A5_PRODUTO'.OR. cNomeCampo == 'A5_REFGRD'
		If cNomeCampo=='A5_REFGRD'
			cProdRef := &(ReadVar())
			If !Empty(cProdRef)
				If lGrade // utilização de grade ativa
					lReferencia := MatGrdPrrf(@cProdRef)
					If !lReferencia //
						Help(" ",1,"REFGRADE")
						lRet :=.F.
					Else
						If nModulo # 17 .and. nModulo # 29  // SIGAEIC
							If lIsInMVC
								lRet := (ExistChav("SA5",oGrid:GetValue("A5_FORNECE")+oGrid:GetValue("A5_LOJA")+oField:GetValue("A5_REFGRD"),9) .And. u_A060ProF())
							Else
								lRet := (ExistChav("SA5",M->A5_FORNECE+M->A5_LOJA+M->A5_REFGRD,9) .And. A060ProFor())
							EndIf
						EndIf            
					Endif
				Else
					Help(" ",1,"NOGRADE")  
					If lIsInMVC
						oField:LoadValue("A5_REFGRD",SPACE(14))
					Else
						M->A5_REFGRD := SPACE(14)
					EndIf
					lRet := .F.
				EndIf
			EndIf
		EndIf
		
		If nModulo # 17 .and. nModulo # 29 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tratamento quando no modulo SIGACOM                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If cNomeCampo =='A5_PRODUTO' 
		    	SA5->(DbSetOrder(2))
				If SA5->(dbSeek(xFilial("SA5")+Iif(lIsInMVC,oField:GetValue("A5_PRODUTO"),M->A5_PRODUTO+M->A5_FORNECE+M->A5_LOJA)))					    
					lRet := .F.				
					Help('',1,'MATA060PRDJE')															  
				EndIf
			ElseIf cNomeCampo == 'A5_REFGRD'
				SA5->(DbSetOrder(10))
				If SA5->(DbSeek(xFilial("SA5")+IIF(lIsInMVC,oField:GetValue("A5_REFGRD"),M->A5_REFGRD)))
					lRet := .F.
					Help('',1,'MATA060REFJE')
				EndIf
			EndIf	
			
           If lGrade
				If lRet				
				    If !cNomeCampo =='A5_PRODUTO' 
						SA5->(DbSetOrder(11))
						If StrTran(SA5->(IndexKey())," ","") == "A5_FILIAL+A5_REFGRD+A5_FABR+A5_FALOJA+A5_FORNECE+A5_LOJA"
							If lIsInMVC
								cSeekSA5 := xFilial("SA5")+oField:GetValue("A5_REFGRD")+oGrid:GetValue("A5_FABR")+oGrid:GetValue("A5_FALOJA")+oGrid:GetValue("A5_FORNECE")
							Else
								cSeekSA5 := xFilial("SA5")+M->A5_REFGRD+M->A5_FABR+M->A5_FALOJA+M->A5_FORNECE
							EndIf
						Else
							If lIsInMVC
								cSeekSA5 := xFilial("SA5")+oField:GetValue("A5_REFGRD")+oGrid:GetValue("A5_FABR")+oGrid:GetValue("A5_FORNECE")
							Else
								cSeekSA5 := xFilial("SA5")+M->A5_REFGRD+M->A5_FABR+M->A5_FORNECE
							EndIf
						EndIf
						
						If SA5->(DbSeek( cSeekSA5 ) ) .AND. nRec#SA5->(RecNo()).And. !Empty(SA5->A5_REFGRD)
							SA5->(DbSetOrder(1))
							SA5->(DbGoTo(nRec))
							Help(" ",1,"A060EXISTE")
							lRet := .F.
						EndIf
				    Else                    
					    If !Empty(If(lIsInMVC,oField:GetValue("A5_PRODUTO"),M->A5_PRODUTO))
					    	If lIsInMVC
						    	lRet := (ExistChav("SA5",oGrid:GetValue("A5_FORNECE")+oGrid:GetValue("A5_LOJA")+oField:GetValue("A5_PRODUTO")) .And. u_A060ProF())
						    Else
							    lRet := (ExistChav("SA5",M->A5_FORNECE+M->A5_LOJA+M->A5_PRODUTO) .And. u_A060ProF())
						    EndIf
						EndIf
				    EndIf 

				EndIf
            Else        
				If !Empty(If(lIsInMVC,oField:GetValue("A5_PRODUTO"),M->A5_PRODUTO))
					If lPrForFab
						If lIsInMVC
							lRet := (ExistChav("SA5",oGrid:GetValue("A5_FORNECE")+oGrid:GetValue("A5_LOJA")+oField:GetValue("A5_PRODUTO")) .And. u_A060ProF())
						Else
							lRet := (ExistChav("SA5",M->A5_FORNECE+M->A5_LOJA+M->A5_PRODUTO) .And. u_A060ProF())
						EndIf
					Else
						SA5->(dbsetorder(1))
						If lIsInMVC
							SA5->(dbseek(xFilial("SA5")+oGrid:GetValue("A5_FORNECE")+oGrid:GetValue("A5_LOJA")+oField:GetValue("A5_PRODUTO")))
						Else
							SA5->(dbseek(xFilial("SA5")+M->A5_FORNECE+M->A5_LOJA+M->A5_PRODUTO))
						EndIf
						While SA5->(A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO) = xFilial("SA5")+If(lIsInMVC,;
								oGrid:GetValue("A5_FORNECE")+oGrid:GetValue("A5_LOJA")+oField:GetValue("A5_PRODUTO"),;
								M->A5_FORNECE+M->A5_LOJA+M->A5_PRODUTO)
						    If Empty(SA5->A5_FABR)
						    	If lIsInMVC
						    		lRet := ExistChav("SA5",oGrid:GetValue("A5_FORNECE")+oGrid:GetValue("A5_LOJA")+oField:GetValue("A5_PRODUTO")) .And. u_A060ProF()
						    	Else
		   							lRet := ExistChav("SA5",M->A5_FORNECE+M->A5_LOJA+M->A5_PRODUTO) .And. u_A060ProF()
		   						EndIf
								Exit
							Endif
							SA5->(dbSkip())
						EndDo
					EndIf
				EndIf
            EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tratamento quando nos modulos Average SIGAEIC                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cNomeCampo == 'A5_FORNECE' .Or. cNomeCampo == 'A5_LOJA'
				If !SA2->(dbSeek(xFilial("SA2")+If(lIsInMVC,oGrid:GetValue("A5_FORNECE"),M->A5_FORNECE)+If(EicLoja() .And. !EICEmptyLJ("M", "A5_LOJA"), EICRetLoja("M", "A5_LOJA"), "")))
					Help(" ",1,"REGNOIS")
					lRet := .F.
				ElseIf LEFT(SA2->A2_ID_FBFN,1) = '1'
					Help(" ",1,"A060FORNNO")
					lRet := .F.
				EndIf
			EndIf
			If lRet
			    If !Empty(If(lIsInMVC,oGrid:GetValue("A5_FABR"),M->A5_FABR))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica a chave para pesquisa                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SA5->(DbSetOrder(3))
					If StrTran(SA5->(IndexKey())," ","") == "A5_FILIAL+A5_PRODUTO+A5_FABR+A5_FALOJA+A5_FORNECE+A5_LOJA"
						If lIsInMVC
							cSeekSA5 := xFilial("SA5")+oField:GetValue("A5_PRODUTO")+oGrid:GetValue("A5_FABR")+oGrid:GetValue("A5_FALOJA")+oGrid:GetValue("A5_FORNECE")
						Else
							cSeekSA5 := xFilial("SA5")+M->A5_PRODUTO+M->A5_FABR+M->A5_FALOJA+M->A5_FORNECE
						EndIf						
					Else
						If lIsInMVC
							cSeekSA5 := xFilial("SA5")+oField:GetValue("A5_PRODUTO")+oGrid:GetValue("A5_FABR")+oGrid:GetValue("A5_FORNECE")
						Else
							cSeekSA5 := xFilial("SA5")+M->A5_PRODUTO+M->A5_FABR+M->A5_FORNECE
						EndIf
					EndIf
					
					If SA5->(dbSeek(cSeekSA5)) .And. EicLoja()
		            	While SA5->(!Eof()) .And. SA5->A5_FILIAL  == xFilial("SA5")						.And.;
           	    			  SA5->A5_PRODUTO == If(lIsInMVC,oField:GetValue("A5_PRODUTO"),M->A5_PRODUTO)	.And.;
	            		      SA5->A5_FABR    == If(lIsInMVC,oGrid:GetValue("A5_FABR"),M->A5_FABR) 		.And.;
       		    	    	  SA5->A5_FORNECE == If(lIsInMVC,oGrid:GetValue("A5_FORNECE"),M->A5_FORNECE)
							  SA5->(dbSkip())
						End
					EndIf
			    EndIf
			EndIf
			SA5->(DbSetOrder(1))
			SA5->(DbGoTo(nRec))
		EndIf
	EndIf
EndIf


/**************
 Módulos Trade-Easy
 **********************/

If cNomeCampo == 'A5_FALOJA' .And. (nModulo == 17 .Or. nModulo == 29) .And. EicLoja()
	If !SA2->(DBSeek(xFilial() +If(lIsInMVC,oGrid:GetValue("A5_FABR"),M->A5_FABR) + If(!EICEmptyLJ("M", "A5_LOJA"), EICRetLoja("M", "A5_FALOJA"), "")))
		Help(" ",1,"REGNOIS")
		lRet := .F.  
	ElseIf Left(SA2->A2_ID_FBFN, 1) == '2'
		Help(" ",1,"A060FABRNO")
		lRet := .F.
	Else
		If lIsInMVC
			oGrid:LoadValue("A5_FABRRED",SA2->A2_NREDUZ)
		Else
			M->A5_FABRRED := SA2->A2_NREDUZ
		EndIf
	EndIf
EndIf
/////////////////////

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se os dados referentes ao RIAI estao preenchidos    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. !(	(Empty(If(lIsInMVC,oGrid:GetValue("A5_RIAI"),M->A5_RIAI)) .And.;
					Empty(If(lIsInMVC,oGrid:GetValue("A5_DTRIAI"),M->A5_DTRIAI)) .And.;
					Empty(If(lIsInMVC,oGrid:GetValue("A5_VALRIAI"),M->A5_VALRIAI))) .Or.;
					(!Empty(If(lIsInMVC,oGrid:GetValue("A5_RIAI"),M->A5_RIAI)) .And.;
					!Empty(If(lIsInMVC,oGrid:GetValue("A5_DTRIAI"),M->A5_DTRIAI)) .And.;
					!Empty(If(lIsInMVC,oGrid:GetValue("A5_VALRIAI"),M->A5_VALRIAI))))
	Help(" ",1,"A100RIAOBR")	// Data do RIAI e de sua validade sao obrigatorias
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para e-Commerce      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. lECommerce
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao permitir alteracao do codigo do produto para produto ecommerce³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ALTERA .And. cNomeCampo =='A5_PRODUTO' .And. SA5->A5_PRODUTO # If(lIsInMVC,oField:GetValue("A5_PRODUTO"),M->A5_PRODUTO)
	    If !Empty(Posicione("SB5",1,xFilial("SB5")+SA5->A5_PRODUTO,"B5_ECFLAG"))
	        Help("",1,'HELP',,"Não pode alterar o produto desta amarração pois é um produto do e-commerce!",1,0)  //"Não pode alterar o produto desta amarração pois é um produto do e-commerce!"
	        If lIsInMVC
	        	oField:LoadValue("A5_PRODUTO",SA5->A5_PRODUTO)
	        Else
	        	M->A5_PRODUTO := SA5->A5_PRODUTO
	        EndIf
	        lRet := .F.
	    EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao permitir mais de uma amarracao e-commerce para fornecedor diferente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cNomeCampo == 'A5_ECFLAG' .And.	!Empty(If(lIsInMVC,oGrid:GetValue("A5_ECFLAG"),M->A5_ECFLAG)) .And.;
										!Empty(If(lIsInMVC,oField:GetValue("A5_PRODUTO"),M->A5_PRODUTO)) .And.;
										!Empty(If(lIsInMVC,oGrid:GetValue("A5_FORNECE"),M->A5_FORNECE))
        SA5->(dbSetOrder(2))  //A5_FILIAL+A5_PRODUTO+A5_FORNECE+A5_LOJA
        SA5->(dbSeek(xFilial("SA5")+If(lIsInMVC,oField:GetValue("A5_PRODUTO"),M->A5_PRODUTO)))
        While SA5->(!EOF() .And. A5_FILIAL+A5_PRODUTO == xFilial("SA5")+If(lIsInMVC,oField:GetValue("A5_PRODUTO"),M->A5_PRODUTO))
            If SA5->A5_FORNECE # If(lIsInMVC,oGrid:GetValue("A5_FORNECE"),M->A5_FORNECE) .And. !Empty(SA5->A5_ECFLAG)
                Help(,,'HELP',,"Amarracao e-commerce já configurado com o fornecedor: " + SA5->A5_FORNECE,1,0)  //"Amarracao e-commerce já configurado com o fornecedor: "
                lRet := .F.
                Exit
            EndIf
                
        	SA5->(dbSkip())
        End
		SA5->(DbSetOrder(1))
		SA5->(DbGoTo(nRec))
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Execblock MT060VLD ap¢s valid.da InclusÆo - O Ret.pode ser L¢gico ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lIsInMVC
	If ExistTemplate('MT060VLD')
		lRet := If(ValType(lRetPE := ExecTemplate('MT060VLD', .F., .F.))=='L', lRetPE, lRet)
	EndIf
	If ExistBlock('MT060VLD')
		lRet := If(ValType(lRetPE := ExecBlock('MT060VLD', .F., .F.))=='L', lRetPE, lRet)
	EndIf
EndIf


SA5->(RestArea(aAreaSA5))
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A060FABR  ³ Autor ³ Julio C.Guerato       ³ Data ³ 25/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se o Campo Fabricante está preenchido               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function A060FABR()
Local lRet := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetuada consistência a fim de verificar se o Fabricante está sendo digitado  |
//³ quando o cadastro for efetuado através do SigaEIC. Quando está posicionado em |
//³ em outro campo por exemplo, a validação passa como verdadeira e sem rotina    |		 
//³ abaixo gera error log.													      |		 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nModulo # 17 .and. nModulo # 29  // SIGAEIC
ElseIF !GETMV("MV_EIC_EAI",,.F.)
   If Empty(M->A5_FABR) // AWF - 29/04/2014 - Nao validar quando vir da integrcao da Logix
      Help(" ",1,"A060FABR")
      lRet := .F.
  EndIf
EndIf
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MA060Delet³ Autor ³ Jorge Queiroz         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Amarracao Produto x Fornecedor  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void MA060Delet(ExpC1,ExpN1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MA060Del(cAlias,nReg,nOpc)

Local nOpcA	:= 0
Local lRet 	:= .T.
Local aArea	:= GetArea()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para e-Commerce      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lECommerce := SuperGetMV("MV_LJECOMM",.F.,.F.)

Begin Transaction 

	nOpcA := AxDeleta(cAlias,nReg,nOpc,,,,,aRotAuto)
	lRet:= (lRet .AND. nOpcA == 2)

	If lRet .AND. GetMv("MV_EASY") = "S" 
		lRet := u_A060DELE()
	EndIf		         
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as amarracoes referentes ao Quality	  			      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet 
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+SA5->A5_PRODUTO))
			If RetFldProd(SB1->B1_COD,"B1_TIPOCQ") == 'Q'	
			   //verifica se existem entradas cadastradas	
			   QEK->(dbSetOrder(1))
			   If QEK->(dbSeek(xFilial("QEK")+SA5->A5_FORNECE+SA5->A5_LOJA+SA5->A5_PRODUTO))
				   Help(" ",1,"QEXISTENTR")
				   lRet := .F.			
			   EndIf
		
			   //Verifica se existem Planos de Amostragens por Ensaios associados ao Fornecedor			   
			   If lRet
				   QF4->(dbSetOrder(1)) 
				   If QF4->(dbSeek(xFilial("QF4")+SA5->A5_FORNECE+SA5->A5_LOJA+SA5->A5_PRODUTO))
				   		Help(" ",1,"QEXISTPLAM") 
			  			lRet := .F.			
				   EndIf
				EndIf				   
			EndIf
			If lRet .AND. SB1->B1_MONO=='S' .AND. (SB1->B1_PROC == SA5->A5_FORNECE)
			   Help(" ",1,"EXISTFDC")
			   lRet := .F.
			EndIf	
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa o campo para a exportacao da exclusao para o e-commerce.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. lECommerce
	    RecLock("SA5",.F.)
	    SA5->A5_ECDTEX := " "
	    MsUnLock()
	EndIf
	
	If lRet .AND. ExistBlock("MT060DEL") 
		nOpcA := ExecBlock("MT060DEL",.F.,.F.,nOpcA)
		If ValType(nOpcA) == "N" .AND. nOpcA == 1
			lRet := .F.
		EndIf
	EndIf
	
    If !lRet
    	DisarmTransaction()
    EndIf	
    
End Transaction

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aciona integração via mensagem única          				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
FwIntegDef( 'AMATA060' )

RestArea(aArea)
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A060ProFor³ Autor ³ Jose Lucas            ³ Data ³ 22/06/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibir e inicializar a Descricao do Produto/Fornecedor.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ A060ProFor()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ A5_PRODUTO,A5_FORNECE                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function A060ProF()
Local lRet		:=.T.
Local nReg		:= 0
Local cCampo 	:= ReadVar()
Local cConteudo := &(ReadVar())
Local nNomeProd := 0
Local nNomeFor	:= 0
Local oModel	:= FWModelActive()
Local lIsInMVC	:= ValType(oModel) <> "U" .And. oModel:GetID() == "u_AMATA061"
Local oField	:= If(lIsInMVC,oModel:GetModel("MdFieldSA5"),NIL)
Local oGrid		:= If(lIsInMVC,oModel:GetModel("MdGridSA5"),NIL)

If Alltrim(cCampo) == "M->A5_PRODUTO"
	dbSelectArea("SB1")
	dbSetOrder(1) 				// Forca ordem principal
	If Altera
		dbSeek(cFilial+SA5->A5_PRODUTO)
		If (B1_MONO=="S") .and. (B1_PROC == If(lIsInMVC,oGrid:GetValue("A5_FORNECE"),M->A5_FORNECE))
			Help("",1,"A06003")
			lRet:=.F.
		Endif
	EndIf
	dbSeek(cFilial+cConteudo)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Produto tem Forn. de Dominio do Canal.                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (B1_MONO == "S") .And. (B1_PROC != If(lIsInMVC,oGrid:GetValue("A5_FORNECE"),M->A5_FORNECE))
		Help(" ",1,"A06002")
		lRet:=.F.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Produto esta cadastrado nas Especificacoes do SIGAQIE  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If RetFldProd(SB1->B1_COD,"B1_TIPOCQ") == "Q" // Quality Celerina
		lRet:= u_A060VldQ()
	EndIf	
	
	If lRet .And. Found()  
		If !Altera
			If lIsInMVC
				oField:LoadValue("A5_NOMPROD",SB1->B1_DESC)
			Else
				M->A5_NOMPROD := SB1->B1_DESC
				nNomeProd := Ascan(aGets,{ |x| Subs(x,9,10) == "A5_NOMPROD" } )
				If nNomeProd > 0
					aTela[Val(Subs(aGets[nNomeProd],1,2))][Val(Subs(aGets[nNomeProd],3,1))*2] := M->A5_NOMPROD
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf Alltrim(cCampo) == "M->A5_FORNECE"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a consistencia entre o Produto e o Fornecedo de Dominio de canal³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(If(lIsInMVC,oField:GetValue("A5_PRODUTO"),M->A5_PRODUTO)) .And. !Empty(cConteudo)
		SB1->(dbSeek(xFilial("SB1")+If(lIsInMVC,oField:GetValue("A5_PRODUTO"),M->A5_PRODUTO)))
		If (SB1->B1_MONO=="S") .And. (SB1->B1_PROC != cConteudo) 
			Help(" ",1,"A06002")
			lRet:=.F.
		Endif
	Endif
	If lRet
		dbSelectArea("SA2")
		If dbSeek(cFilial+cConteudo+SA2->A2_LOJA)
			If lIsInMVC
				oGrid:LoadValue("A5_NOMEFOR",SA2->A2_NOME)
			Else
				M->A5_NOMEFOR := SA2->A2_NOME
				nNomeFor := Ascan(aGets,{ |x| Subs(x,9,10) == "A5_NOMEFOR" } )
				If nNomeFor > 0
					aTela[Val(Subs(aGets[nNomeFor],1,2))][Val(Subs(aGets[nNomeFor],3,1))*2] := M->A5_NOMEFOR
				EndIf
			EndIf
		EndIf	
	EndIf
ElseIf Alltrim(cCampo) == "M->A5_LOJA"	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a consistencia entre o Produto e o Fornecedo de Dominio de canal³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(If(lIsInMVC,oField:GetValue("A5_PRODUTO"),M->A5_PRODUTO)) .And. !Empty(cConteudo)
		SB1->(dbSeek(xFilial("SB1")+If(lIsInMVC,oField:GetValue("A5_PRODUTO"),M->A5_PRODUTO)))
		If (SB1->B1_MONO=="S") .And. (SB1->B1_PROC != cConteudo) 
			Help(" ",1,"A06002")
			lRet:=.F.
		EndIf
	EndIf
	If lRet
		dbSelectArea("SA2")
		If dbSeek(cFilial+SA2->A2_COD+cConteudo)
			If lIsInMVC
				oGrid:LoadValue("A5_NOMEFOR",SA2->A2_NOME)
			Else
				M->A5_NOMEFOR := SA2->A2_NOME			
				nNomeFor := Ascan(aGets,{ |x| Subs(x,9,10) == "A5_NOMEFOR" } )
				If nNomeFor > 0
					aTela[Val(Subs(aGets[nNomeFor],1,2))][Val(Subs(aGets[nNomeFor],3,1))*2] := M->A5_NOMEFOR
				EndIf
			EndIf
		EndIf	
	EndIf
ElseIf Alltrim(cCampo) =="M->A5_REFGRD"
	
	dbSelectArea("SB1")
	dbSetOrder(1) 				// Forca ordem principal
	If Altera
		dbSeek(xFilial("SB1")+SA5->A5_REFGRD,.T.)
		While !Eof().And.xFilial("SB1")==SB1->B1_FILIAL.And.Alltrim(SA5->A5_REFGRD)==Left(SB1->B1_COD,LEN(Alltrim(SA5->A5_REFGRD)))
			If (B1_MONO=="S") .and. (B1_PROC == If(lIsInMVC,oGrid:GetValue("A5_FORNECE"),M->A5_FORNECE))
				Help("",1,"A06003")
				Return .F.
			EndIf
			SB1->(Dbskip())
		EndDo
		
	EndIf
	dbSeek(xFilial()+cConteudo,.T.)
	While !Eof().And.xFilial()==SB1->B1_FILIAL.And.Alltrim(cConteudo)==Left(SB1->B1_COD,LEN(Alltrim(cConteudo)))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Produto tem Forn. de Dominio do Canal.                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (B1_MONO == "S") .And. (B1_PROC != If(lIsInMVC,oGrid:GetValue("A5_FORNECE"),M->A5_FORNECE))
			Help(" ",1,"A06004",,SB1->B1_COD,1,11)
			Return .F.
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Produto esta cadastrado nas Especificacoes do SIGAQIE  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If RetFldProd(SB1->B1_COD,"B1_TIPOCQ") == "Q" // Quality Celerina
			lRet:= u_A060VldQ(.T.)
		EndIf
		SB1->(Dbskip())
	EndDo
	
	If lRet 
		If lIsInMVC
			oField:GetValue("A5_DESREF") := DescPrRf(cConteudo)
		Else
			M->A5_DESREF := DescPrRf(cConteudo)
			nNomeProd := Ascan(aGets,{ |x| Subs(x,9,10) == "A5_DESREF" } )
			If nNomeProd > 0
				aTela[Val(Subs(aGets[nNomeProd],1,2))][Val(Subs(aGets[nNomeProd],3,1))*2] := M->A5_DESREF
			EndIf
		EndIf
	EndIf
EndIf
dbSelectArea("SA5")
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A060DELE  ³ Autor ³ Average               ³ Data ³28/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica a existentia do produtoXfornecedor no SW3          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³True ou False                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Mata060.PRX (Amarracao ProdXForn)                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function A060dele()

Local nTotalReg := 0

SetPrvt("COLDORDER,LACHOU,")
cOldOrder:=SW3->(INDEXORD())
lAchou   :=.F.

//Verifica vinculação do módulo SIGAEIC
SW3->(dbSetOrder(3))
If SW3->(dbSeek(XFILIAL("SW3")+SA5->A5_PRODUTO))

   Do While SW3->(!EOF()) .AND. SW3->W3_FILIAL == XFILIAL("SW3") .AND.;
            SW3->W3_COD_I == SA5->A5_PRODUTO

      If SW3->W3_COD_I == SA5->A5_PRODUTO .AND.;
         SW3->W3_FORN  == SA5->A5_FORNECE .AND.;
         SW3->W3_FABR  == SA5->A5_FABR
         lAchou:=.T.
         Exit
      EndIf

      SW3->(dbSkip())

   EndDo
   
EndIf

//Verifica vinculação do módulo SIGAEEC
If Select("TOTALREG") > 0
   TOTALREG->( dbCloseArea() )
Endif

BeginSql Alias "TOTALREG"
      
   SELECT COUNT(*) AS TOTAL
   FROM %table:EE8% 
   WHERE  EE8_COD_I  = %Exp:SA5->A5_PRODUTO% AND 
          EE8_FORN   = %Exp:SA5->A5_FORNECE% AND
          EE8_FABR   = %Exp:SA5->A5_FABR% AND
          D_E_L_E_T_ <> '*'

EndSql

nTotalReg := TOTALREG->TOTAL

If nTotalReg > 0
   lAchou := .T.
EndIf

TOTALREG->( dbCloseArea() )

DBSELECTAREA("EE8")

If lAchou
   Help(" ",1,"E_DELFOFA2")
EndIf

SW3->(ORDSETFOCUS(cOldOrder))

Return(!lAchou) 
              
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A060Chave ³ Autor ³ Paulo Emidio de Barros³ Data ³13/05/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera a chave de ligacao utilizada na Amarracao Produto x   ³±±
±±³			 ³ Fornecedor.						 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nulo			                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA060.PRX (Amarracao Produto x Fornecedor)                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function A060Cha()
Local aAreaSA5 := SA5->(GetArea()) 
Local nSaveSx8 := GetSx8Len()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera a chave de ligacao									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ          
dbSelectArea("SA5")
dbSetOrder(6)
cChave := GetSxeNum("SA5","A5_CHAVE")
While dbSeek(xFilial("SA5")+cChave)
  	While ( GetSx8Len() > nSaveSX8 )
     	ConfirmSX8()
    End
    cChave := GetSxeNum("SA5","A5_CHAVE")
End

SA5->(RestArea(aAreaSA5))
Return(cChave)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A060VldQIE³ Autor ³ Eduardo de Souza      ³ Data ³ 28/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica a existencia do produto no cadastro de especifica-³±±
±±³			 ³ coes / ensaios.          		 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA060.PRX (Amarracao Produto x Fornecedor)                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function A060VldQ(lReferencia)

Local nTam  	:= 0
Local cMvUtSk25	:= GetMV("MV_QUTSK25")
Local oModel	:= FWModelActive()
Local lIsInMVC	:= ValType(oModel) <> "U" .And. oModel:GetID() == "u_AMATA061"
Local oField	:= If(lIsInMVC,oModel:GetModel("MdFieldSA5"),NIL)
Local oGrid 	:= If(lIsInMVC,oModel:GetModel("MdGridSA5"),NIL)

Default lReferencia :=.F.

If lReferencia
	If !QE6->(dbSeek(xFilial("QE6")+SB1->B1_COD))
		Help(" ",1,"A06005",,SB1->B1_COD,1,11)	// "Produto n„o cadastrado pelo SIGAQIE"
		Return(.F.)
	EndIf
	
	If !QE7->(dbSeek(xFilial("QE7")+SB1->B1_COD))
		If !QE8->(dbSeek(xFilial("QE8")+SB1->B1_COD))
			Help(" ",1,"A06006",,SB1->B1_COD,1,11)	// "Produto n„o tem Ensaios associados."
			Return(.F.)
		EndIf
	EndIf

Else
	If !QE6->(dbSeek(xFilial("QE6")+If(lIsInMVC,oField:GetValue("A5_PRODUTO"),M->A5_PRODUTO)))
		Help(" ",1,"Q_060PRNAO")	// "Produto n„o cadastrado pelo SIGAQIE"
		Return(.F.)
	EndIf

	If !QE7->(dbSeek(xFilial("QE7")+If(lIsInMVC,oField:GetValue("A5_PRODUTO"),M->A5_PRODUTO)))
		If !QE8->(dbSeek(xFilial("QE8")+If(lIsInMVC,oField:GetValue("A5_PRODUTO"),M->A5_PRODUTO)))
			Help(" ",1,"Q_060ENNAO")	// "Produto n„o tem Ensaios associados."
			Return(.F.)
		EndIf
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Skip-Lote foi especificado                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QEG->(dbSeek(xFilial("QEG")+If(lIsInMVC,oGrid:GetValue("A5_SITU"),M->A5_SITU)))
If QEG->QEG_CATEG $ "1.2"
	If Empty(If(lIsInMVC,oGrid:GetValue("A5_SKPLOT"),M->A5_SKPLOT))
		Help(" ",1,"A100SKPOBR")	// Skip-Lote ‚ obrigatorio
		Return(.F.)
	EndIf
Else
	//Limpa o Skip-Lote
	nTam := TamSX3("A5_SKPLOT")[1]
	If lIsInMVC
		oGrid:LoadValue("A5_SKPLOT",Space(nTam))
	Else
		M->A5_SKPLOT := Space(nTam)
	EndIf
EndIf

If !Empty(If(lIsInMVC,oGrid:GetValue("A5_SKPLOT"),M->A5_SKPLOT))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a categoria Situacao ‚ Skip-Lote 25%             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QEG->QEG_CATEG == "2"
		QEF->(dbSeek(xFilial("QEF")+If(lIsInMVC,oField:GetValue("A5_SKPLOT"),M->A5_SKPLOT)))
		If QEF->QEF_UNSKLT == "E"	// Skip-Lote por entregas
			If cMvUtSk25 == "S"
				If QEF->QEF_QTDE > 4
					Help(" ",1,"A100SKLINV")	// "Skip-Lote n„o permitido para a Situa‡„o"
					Return(.F.)
				EndIf
			EndIf
		ElseIf QEF->QEF_UNSKLT <> "L"	// Skip-Lote por Documento Entrada
			Help(" ",1,"A100SKLINV")	// "Skip-Lote n„o permitido para a Situa‡„o"
			Return(.F.)
		EndIf
	EndIf
EndIf

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA060TudokºAutor  ³Patricia D. Aguiar  º Data ³  06/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Não permitir a gravação de registro sem referencia de gradeº±±
±±º          ³ ou codigo do produto em branco                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ .T. verdadeiro ou .F. falso                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MA060TUD()

Local lRet 		:= .T.
Local lHistTab	:= SuperGetMV("MV_HISTTAB", .F., .F.)
Local bCampoSA5	:= { |x| SA5->(Field(x)) }
Local nX			:= 0
Local aOrdSA5		:= SaveOrd({"SA5"})   //TRP - 01/04/2013
Static nRecno		:= 0

If Empty(M->A5_PRODUTO).And. Empty(M->A5_REFGRD)
	Help(" ",1,"A060OBRIGA")
	lRet := .F.
Endif

If Altera 
	If nModulo == 17 .And. EicLoja()
	DbSelectArea("SA5")	
		nRecno := Recno()
		SA5->(DbSetOrder(3))
		If SA5->(MsSeek(xFilial("SA5")+M->A5_PRODUTO+M->A5_FABR+M->A5_FORNECE )) .And. SA5->(Recno()) <> nRecno
			lRet := .F.
			Help(" ",1,"A060FORNEC")
		EndIf 
	Else
		DbSelectArea("SA5")	
		nRecno := Recno()
		SA5->(DbOrderNickName("A5CODPRF"))
		//If !SA5->(MsSeek(xFilial("SA5")+M->A5_FORNECE+M->A5_LOJA+PADR(M->A5_PRODUTO,TAMSX3("A5_PRODUTO")[1])+PADR(M->A5_CODPRF,TAMSX3("A5_CODPRF")[1]) )) //.And. SA5->(Recno()) <> nRecno
		If SA5->(MsSeek(xFilial("SA5")+M->A5_FORNECE+M->A5_LOJA+PADR(M->A5_PRODUTO,TAMSX3("A5_PRODUTO")[1])+PADR(M->A5_CODPRF,TAMSX3("A5_CODPRF")[1]) )) .And. SA5->(Recno()) <> nRecno
			lRet := .F.
			Help(" ",1,"A060FORNEC")
		EndIf 
	EndIf     
EndIf    

//TRP - 10/01/2013 - Valida se o registro já existe na base de dados. 
If nModulo == 17  .And. EicLoja() .AND. Inclui
   SA5->(DbSetOrder(3))
   
   If SA5->(DbSeek(xFilial("SA5")+M->A5_PRODUTO+M->A5_FABR+M->A5_FORNECE ))                                                                                                                         
      While SA5->(!Eof()) .And.;
         SA5->A5_FILIAL  == xFilial("SA5") .And.;
         SA5->A5_PRODUTO == M->A5_PRODUTO .And.;
         SA5->A5_FABR    == M->A5_FABR .And.;
         SA5->A5_FORNECE == M->A5_FORNECE

         If M->A5_LOJA == SA5->A5_LOJA .AND. M->A5_FALOJA == SA5->A5_FALOJA
            lRet := .F.
            Help(" ",1,"A060EXISTE")
            Exit
         EndIf   
         SA5->(DBSkip())
      EndDo  

      RestOrd(aOrdSA5,.T.)
   Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carregar o vetor aCpoAltSA5 com os campos que sofreram  ³
//³alguma alteracao. Somente serao gravados na tabela AIF  ³
//³apos a validacao completa da rotina.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. !Inclui .And. lHistTab
	aCpoAltSA5 := {}   
	DbSelectArea("SA5")
	For nX := 1 to FCount()
		If !(M->&( eVal( bCampoSA5, nX) ) == &( eVal( bCampoSA5, nX) ))
			aAdd( aCpoAltSA5, { eVal( bCampoSA5, nX), &( eVal( bCampoSA5, nX) ) } )
		EndIf
	Next nX
EndIf

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³03/10/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Static Function MenuDef() 

Private aRotina := { { "Pesquisar" ,"AxPesqui"	,0,1,0,.F.},;	 //"Pesquisar"
                     { "Visualizar","AxVisual"	,0,2,0,Nil},;	 //"Visualizar"
                     { "Incluir"   ,"u_AA060Man",0,3,0,Nil},;    //"Incluir"
                     { "Alterar"   ,"u_AA060Man",0,4,0,Nil},;	 //"Alterar"
                     { "Excluir"   ,"u_MA060Del",0,5,3,Nil},;    //"Excluir" 
                     { "Replicar"  ,"u_COM001"  ,0,2,0,Nil},;	 //"Replicar"         
					 { "Importar"  ,"u_IMPORT06",0,3,0,Nil} }	 //"Atualizar"            
Return (aRotina)