/*
+----------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+---------------------------------------------------------+
!Módulo            ! Estoque                                                 !
+------------------+---------------------------------------------------------+
!Nome              ! AEST008                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Ticket                                                  !
+------------------+---------------------------------------------------------+
!Autor             ! Marcos Vinícius Perusselo                               !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 15/02/2012                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
! Inclusão - chamada da funcão "Pesar"      !           ! Clederson !09/04/12!
!                                           !           ! Dotti     !        !
+-------------------------------------------+-----------+-----------+--------+
! Inclui o nome fantasia do cliente ao invés! Sylas     ! Clederson !19/04/12!
! da razão social                           ! Morgado   ! Dotti     !        ! 
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//#INCLUDE "DIRECTRY.CH"

User Function AEST008()
	Local aItens := {"E=Entrada","S=Saida"}
	Local aSItens := {"T=Ticket", "CA=Placa Carreta", "CV=Placa Cavalo", "V=Placa Vagão"}
	Local oCombo := nil
	Local oDlg := nil
	Local oBtConfirm1 := nil
	Local oBtConfirm2 := nil
	Local oBtConfirm3
	
	Private LMANUT  := .F. 
	// Handle utilizado pela função de balanca
	Private nBalHnd	:= 0
	Private INCLUI
	Private oGetVar
	Private oPanel1
	Private oPanel2
	//+-----------------------------------------------------+
	//! Variaveis da primeira tela de Tickets.              !
	//+-----------------------------------------------------+
	Private cGetCliCod := Space(06)
	Private cGetCliLoj := Space(04)
	Private cGetProd := Space(30)
	Private cGetCliPed := Space(10)
	Private cGetTick := Space(10)
	Private cTipoOp := "E"
	Private cTipoBusca := Space(02) 
	
	//Variavel que controla o numero da pesagem. (1 = 1ª Pesagem/2 = 2ª Pesagem).
	Private nNumPesag
	Private nRecNo
	
	//+-----------------------------------------------------+
	//! Instânciação dos objetos da primeira tela.          !
	//+-----------------------------------------------------+
	oDlg := MSDialog():New(100,100,430,700,"Ticket",,,,,CLR_BLACK,/*nClrBack*/,,,.T.,,,,,)
	oDlg:lEscClose := .T.
	oPanel1:= tPanel():New(015,005,"",oDlg,,,,CLR_BLACK,/*nClrBack*/,145,130,.F.,.T.)
	oPanel2:= tPanel():New(015,155,"",oDlg,,,,CLR_BLACK,/*nClrBack*/,143,130,.F.,.T.)
	
	@ 015,012 COMBOBOX oCombo VAR cTipoOp ITEMS aItens SIZE 070,060 OF oPanel1 ON CHANGE LimpaCpos() PIXEL
	@ 005,005 SAY "1ª Pesagem" 			OF oDlg PIXEL                                                        
	@ 005,155 SAY "2ª Pesagem" 			OF oDlg PIXEL
	@ 005,012 SAY "Tipo de Operacao" 	OF oPanel1 PIXEL
	@ 030,012 SAY "Cliente" 			OF oPanel1 PIXEL
	@ 040,012 MSGET cGetCliCod 			OF oPanel1 F3 "SA1" VALID FindCli() SIZE 040,010 PIXEL
	@ 030,072 SAY "Loja" 				OF oPanel1 PIXEL
	@ 040,072 MSGET cGetCliLoj 			OF oPanel1 SIZE 030,010 PIXEL
	@ 055,012 SAY "Produto" 			OF oPanel1 PIXEL
	@ 065,012 MSGET cGetProd 			OF oPanel1 When (cTipoOp == 'E') F3 "SB1" SIZE 090,010 PIXEL
	//@ 080,012 SAY "Pedido do Cliente" 	OF oPanel1 PIXEL
	//@ 090,012 MSGET cGetCliPed 			OF oPanel1 When (cTipoOp == 'S') SIZE 035,010 PIXEL

	//botao confirmar primeiro pesagem
	oBtConfirm1 := TButton():New(110, 095, "Confirmar"	,oPanel1,{|| AEST008A(nNumPesag := 1)}	,40,10,,,.F.,.T.,.F.,,.F.,,,.F.)

	@ 045,022 SAY "Busca por:" OF oPanel2 PIXEL
	@ 055,022 COMBOBOX oCombo VAR cTipoBusca ITEMS aSItens SIZE 070,060 OF oPanel2  ON CHANGE ChgPic() PIXEL
	@ 085,022 MSGET oGetVal VAR cGetTick OF oPanel2 PICTURE '' SIZE 100,010 PIXEL
	
	//botao confirmar segunda pesagem
 	oBtConfirm2 := TButton():New(110, 095, "Confirmar"	,oPanel2,{|| AEST008A(nNumPesag := 2)}	,40,10,,,.F.,.T.,.F.,,.F.,,,.F.)
 	oBtSair1    := TButton():New(150, 260, "Sair"    	,oDlg	,{|| oDlg:End()}				,30,10,,,.F.,.T.,.F.,,.F.,,,.F.)
    
	//+-----------------------------------------------------+
	//! Ativação da primeira tela de Tickets.               !
	//+-----------------------------------------------------+
	ACTIVATE DIALOG oDlg CENTERED
Return

Static Function FindCli()
	cGetCliLoj := IIF(!Empty(cGetCliCod), Posicione("SA1", 01, xFilial("SA1") + cGetCliCod, "A1_LOJA"), "")
Return

Static Function ChgPic()
	Local cPict := IIF(cTipoBusca == "CA" .Or. cTipoBusca == "CV",PesqPict("Z0A", "Z0A_PLCCAR"),IIF(cTipoBusca == "T", PesqPict("Z0A", "Z0A_TICKET"),PesqPict("Z0A", "Z0A_PLCVAG")))
	Local cValor := Space(IIF(cTipoBusca == "CA" .Or. cTipoBusca == "CV",TamSX3("Z0A_PLCCAR")[1],IIF(cTipoBusca == "T", TamSX3("Z0A_TICKET")[1],TamSX3("Z0A_PLCVAG")[1])))
	
	oGetVal := Nil
	@ 085,022 MSGET oGetVal VAR cGetTick OF oPanel2 PICTURE cPict VALID IIF(cTipoBusca == "T", STRZERO(Val(cGetTick), 10),) SIZE 100,010 PIXEL
	cGetTick := cValor
	oGetVal:Refresh()

Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! AEST008A  ! Autor ! Marcos Perusselo   ! Data ! 29/02/2012	 !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Funcao faz a busca na tabela Z07 após o preenchimento			 !
! 			! e confirmação do usuário.										 !
!			!																 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function AEST008A()
	Local lConfirma := .F.
	Local lFoundTkt := .F.
	Local cAlias := GetNextAlias()
	Local nCont := 0
	// Programa de captura de imagens
	Private cCapPicExe := "AndaliCam.exe"
	Private cDirCapPic := ""
	Private lTemFoto  := .F.
	Private lVldImg := .F.
	// Parâmetro que informa se habilita a pesagem manual
	Private lHabPes := SuperGetMV("AN_HABPES", .F., .T.)
	Private cCodBal := ""
	Private cCadastro := ""
	Private cImgDir := ""
	Private cImgExt := ".jpg"
	Private cNmImgD := "ImgD"
	Private cNmImgT := "ImgT" 
	Private nPesPrev, nDiffPes1, nDiffPes2
	Private oTimer
	Private oTimerBal
	Private oBmp1,oBmp2
	Private oDlg
	Private oFld
	Private oTPanel1, oTPanel2, oTPanel3, oTPanel4
	Private oBtPesa1
	Private oBtFoto1
	Private oBtPesa2
	Private oBtFoto2
	Private oBtConf1
	Private aTELA := array(0,0)
	Private aGETS := array(0)
	Private aCpoEnc := {"NOUSER"}

	
	SX3->( dbSetOrder(1) )
	SX3->( dbSeek( "Z0A" ) )
	While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == "Z0A"
		If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And.;
			!( alltrim(SX3->X3_CAMPO) $ "Z0A_DATA1#Z0A_DATA2#Z0A_HORA1#Z0A_HORA2#Z0A_USER1#Z0A_USER2#Z0A_BALAN1#Z0A_BALAN2#Z0A_PESO1#Z0A_PESO2#Z0A_PEDIDO#Z0A_MSBLQL#Z0A_DOC#Z0A_SERIE" )
			IF ( cTipoOp == "S" ).And.alltrim(SX3->X3_CAMPO) $ "Z0A_OPER#Z0A_PRODUT#Z0A_PDDESC#Z0A_PROCED#Z0A_DESPRO"
				SX3->( dbSkip() )
				Loop
			EndIF
			aAdd(aCpoEnc,SX3->X3_CAMPO)
		EndIF
		SX3->( dbSkip() )
	EndDO
	
	
	// Verifica se a balança existe para o IP do cliente
	If !LocBalan()
		Aviso("ATENÇÃO", "Balança não cadastrada para o seu IP.", {"OK"}, 2)
		nNumPesag := 0	
	EndIf
	
	//Verifica se é a 1ª pesagem.
	If( nNumPesag == 1 )
		//Se a operação for E=Entrada
		If( cTipoOp == "E" )
			//Seleciona a área de cadastro de operações.
			dbSelectArea("Z07")
			dbSetOrder(8)
			//Faz a busca no dicionário de dados. (Posiciona no primeiro)
			//If( dbSeek(xFilial("Z0A")+cTipoOp+cGetCliCod+cGetCliLoj+cGetProd) )
			BeginSQL Alias cAlias
				SELECT 
					Z07.R_E_C_N_O_ AS Z07RECNO,
					Z07.Z07_PROCED,
					Z07.Z07_MSBLQL
				FROM
					%table:Z07% Z07
				WHERE
						Z07.Z07_FILIAL = %Exp:xFilial("Z07")%
					AND Z07.Z07_OPER = %Exp:cTipoOp%
					AND Z07.Z07_CLICOD = %Exp:cGetCliCod%
					AND Z07.Z07_CLILOJ = %Exp:cGetCliLoj%
					AND Z07.Z07_PRODUT = %Exp:cGetProd%
					AND Z07.Z07_MSBLQL <> '1'
					AND Z07.D_E_L_E_T_ <> '*'
					
			EndSQL				 
			// Conta o numero de registros
			(cAlias)->(dbEval({|| nCont++}))
			// Posiciona o registro selecionado
			(cAlias)->(dbGoTop())
			Z07->(dbGoTo((cAlias)->Z07RECNO))
			
			If nCont > 0
				// Se houver mais de uma operação para o mesmo cliente/produto
				If nCont > 1
					AjustaSX1("EST008SP")
					If !Pergunte("EST008SP")
						Return
					Else
						cAlias := GetNextAlias()
						BeginSQL Alias cAlias
							SELECT
								Z07.R_E_C_N_O_ AS Z07RECNO
							FROM
								%table:Z07% Z07
							WHERE
									Z07.Z07_FILIAL = %Exp:xFilial("Z07")%
								AND Z07.Z07_OPER   = %Exp:cTipoOp%
								AND Z07.Z07_CLICOD = %Exp:cGetCliCod%
								AND Z07.Z07_CLILOJ = %Exp:cGetCliLoj%
								AND Z07.Z07_PRODUT = %Exp:cGetProd%
								AND Z07.Z07_PROCED = %Exp:MV_PAR01%
								AND Z07.Z07_MSBLQL <> '1'
								AND Z07.D_E_L_E_T_ <> '*'
								
						EndSQL
						
						If (cAlias)->Z07RECNO <= 0
							//Aviso caso não exista registro.
							Aviso( 'ATENÇÃO', 'Registro não encontrado na base de dados.', { 'Ok' }, 2 )
							Return
						EndIf
					EndIf
				EndIf				
				
				dbSelectArea("Z07")
				Z07->(dbGoTo((cAlias)->Z07RECNO))
				//Verifica se o ticket está ativo e se gera ticket.
				If( Z07_MSBLQL != '1' .AND. Z07_TICKET == 'S' )
					//Seleciona a área dos tickets.
					dbSelectArea("Z0A")
					INCLUI := .T.
					//Carrega os campos para a memória.
					RegToMemory("Z0A", .T.)
					//Função para montagem da tela de pesagem.
					GeraTela()
					//Montagem dos campos da parte de cima da tela.
					EnChoice("Z0A", nil, 3, , , ,aCpoEnc /*aCpoEnc*/, {001,001,110,365}, /*aCpoEnc*/, 3,,,,oFld:aDialogs[1])
					//+-----------------------------------------------------+
					//! Atribuição dos valores aos campos carregados.       !
					//+-----------------------------------------------------+
					//M->Z0A_TICKET := GETSX8NUM("Z0A", "Z0A_TICKET")
					M->Z0A_OPER   := Z07->Z07_CODIGO
					M->Z0A_TIPO   := cTipoOp
					M->Z0A_CLICOD := Z07->Z07_CLICOD
					M->Z0A_CLILOJ := Z07->Z07_CLILOJ
					// Busca nome fantasia do cliente ao invés da razão social
					//M->Z0A_CLINOM := Z07->Z07_CLINOM
					M->Z0A_CLINOM := Posicione("SA1", 01, xFilial("SA1") + Z07->(Z07_CLICOD + Z07_CLILOJ), "A1_NREDUZ")
					M->Z0A_PRODUT := Z07->Z07_PRODUT
					M->Z0A_PDDESC := Z07->Z07_DESC
					M->Z0A_PEDIDO := Z07->Z07_PEDCLI
					M->Z0A_DATA1 := Date()
	   				M->Z0A_HORA1 := Time()
					M->Z0A_USER1 := cUserName
					
					//+-----------------------------------------------------+
					//! Ativação da janela de tickets.                      !
					//+-----------------------------------------------------+
					ACTIVATE DIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,{|| IIF(lConfirma:=Valida(),oDlg:End(), NIL), oTimerBal:Deactivate()},{||oDlg:End(),DelArq(),oTimerBal:Deactivate()},,))
				Else
					//Aviso caso não exista registro.
					Aviso( 'ATENÇÃO', 'Registro não encontrado na base de dados.', { 'Ok' }, 2 )
				EndIf
			Else
				//Aviso caso não exista registro.
				Aviso( 'ATENÇÃO', 'Registro não encontrado na base de dados.', { 'Ok' }, 2 )
			EndIf
		//Se a operação for S=Saída.
		ElseIf ( cTipoOp $ "S" )



			//Seleciona a área de cadastro de operações.
			//dbSelectArea("Z07")
			//dbSetOrder(7)
			//Faz a busca no dicionário de dados.
			//If( dbSeek(xFilial("Z0A")+cTipoOp+cGetCliCod+cGetCliLoj+cGetCliPed))
			
			
			//verifica o cliente
			SA1->( dbSetOrder(1) )
			SA1->( dbSeek( xFilial("SA1") + cGetCliCod+cGetCliLoj ) )

			IF SA1->( Found() )

				Z07->( dbSetOrder(7) )
				Z07->( dbSeek( xFilial("Z0A") + cTipoOp + cGetCliCod + cGetCliLoj ) )

				lContinua := .F.
				While !Z07->( Eof() )
					IF( Z07->Z07_MSBLQL != 'S' .AND. Z07->Z07_TICKET == 'S' )
						lContinua := .T.
					EndIF
					Z07->( dbSkip() )
				EndDO

				//Verifica se a operação está ativa e se utiliza ticket
				If lContinua
					INCLUI := .F.
					//Seleciona a área dos tickets.
					dbSelectArea("Z0A")
					//Carrega os campos para a memória.
					RegToMemory("Z0A", .T.)
					//Função para montagem da tela dos paineis.
					GeraTela()                                                           
					//Montagem dos campos da parte de cima da tela.
					EnChoice("Z0A", nil, 3, , , , aCpoEnc/*aCpoEnc*/, {001,001,110,365}, /*aCpoEnc*/, 3,,,,oFld:aDialogs[1])
					//+-----------------------------------------------------+
					//! Atribuição dos valores aos campos carregados.       !
					//+-----------------------------------------------------+
					//M->Z0A_TICKET := GETSX8NUM("Z0A", "Z0A_TICKET")
					//M->Z0A_OPER   := Z07->Z07_CODIGO
					M->Z0A_TIPO   := cTipoOp
					M->Z0A_CLICOD := SA1->A1_COD
					M->Z0A_CLILOJ := SA1->A1_LOJA
					// Busca nome fantasia do cliente ao invés da razão social
					//M->Z0A_CLINOM := Z07->Z07_CLINOM
					M->Z0A_CLINOM := SA1->A1_NREDUZ
					//M->Z0A_PRODUT := Z07->Z07_PRODUT
					//M->Z0A_PDDESC := Z07->Z07_DESC
					//M->Z0A_PEDIDO := Z07->Z07_PEDCLI
					//M->Z0A_EMBALA := Z07->Z07_EMBALA
					If ExistTrigger("Z0A_EMBALA")
						RunTrigger(1,Nil, Nil,, "Z0A_EMBALA")
					EndIf
					M->Z0A_DATA1 := Date()
	   				M->Z0A_HORA1 := Time()
					M->Z0A_USER1 := cUserName
					
					//+-----------------------------------------------------+
					//! Ativação da janela de tickets.                      !
					//+-----------------------------------------------------+	                
					ACTIVATE DIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,{|| IIF(lConfirma:=Valida(),oDlg:End(), NIL), oTimerBal:Deactivate()},{||oDlg:End(),DelArq(), oTimerBal:Deactivate()},,))
				Else
					//Aviso caso não exista registro.
					Aviso( 'ATENÇÃO', 'Este cliente não possui operação ou a operação de saída bloqueada.', { 'Ok' }, 2 )
				EndIf
			Else
				//Aviso caso não exista registro.
				Aviso( 'ATENÇÃO', 'Cliente não encontrado na base de dados.', { 'Ok' }, 2 )
			EndIf
		EndIf
	//Verifica se é a 2ª pesagem.
	ElseIf( nNumPesag == 2 )
		//Seleciona a área de cadastro de tickets.
		dbSelectArea("Z0A")
		If cTipoBusca == "T"
			Z0A->(dbSetOrder(01))
			Z0A->(dbGoTop())
			If Z0A->(dbSeek(xFilial("Z0A") + cGetTick))
				lFoundTkt := .T.
			EndIf
		ElseIf cTipoBusca == "CV"
			Z0A->(dbSetOrder(05))
			Z0A->(dbGoTop())
			// Se encontrou pela placa do cavalo (While necessário para buscar sempre a última placa)
			Z0A->(dbSeek(xFilial("Z0A") + cGetTick))
			While Z0A->Z0A_PLCCAV == cGetTick
				lFoundTkt := .T.
				Z0A->(dbSkip())
			EndDo
			// Ao passar pelo último registro, volta um para o registro correto
			Z0A->(dbSkip(-1))
		// Placa de cavalo/carreta
		ElseIf cTipoBusca == "CA"
			Z0A->(dbSetOrder(04))
			Z0A->(dbGoTop())
			// Se não encontrou pela placa da carreta (While necessário para buscar sempre a última placa)
			Z0A->(dbSeek(xFilial("Z0A") + cGetTick))
			While Z0A->Z0A_PLCCAR == cGetTick
				lFoundTkt := .T.
				Z0A->(dbSkip())
			EndDo
			// Ao passar pelo último registro, volta um para o registro correto
			Z0A->(dbSkip(-1))
		// Placa de vagão
		ElseIf cTipoBusca == "V"
			Z0A->(dbSetOrder(07))
			Z0A->(dbGoTop())
			// Se encontrou pela placa de vagão (While necessário para buscar sempre a última placa)
			Z0A->(dbSeek(xFilial("Z0A") + cGetTick))
			While Z0A->Z0A_PLCVAG == cGetTick
				lFoundTkt := .T.
				Z0A->(dbSkip())
			EndDo
			// Ao passar pelo último registro, volta um para o registro correto
			Z0A->(dbSkip(-1))
		EndIf

		// Se encontrou o ticket
		If lFoundTkt
			lOk := .T.
			//se ja houve uma segunda pesagem
			IF Z0A->Z0A_PESO2 != 0
				Aviso( 'ATENÇÃO', 'Este ticket ja possui segunda pesagem.', { 'Ok' }, 2 )
				lOk := .F.
			EndIf			

			Z07->( dbSetOrder(1) )
			Z07->( dbSeek( xFilial("Z07") + Z0A->Z0A_OPER ) )

			IF lOk .And. Z0A->Z0A_TIPO != "E"
				Z0E->( dbSetOrder( 01 ) )
				Z0E->( dbGoTop() )
				Z0E->( dbSeek( xFilial("Z0E") + Z0A->Z0A_TICKET ) )
				IF !Z0E->( Found() )
					//Aviso caso não exista registro.
					Aviso( 'ATENÇÃO', 'Ainda não foi gerado ordem de carregamento pra este ticket.', { 'Ok' }, 2 )
					lOk := .F.
				Else                                                 	
					dbSelectArea("Z0C")
					Z0C->(dbSetOrder(01))
					Z0C->(dbSeek(xFilial("Z0C") + Z0E->Z0E_OC))
				EndIF
			EndIF

			If lOk
			
				If Z0A->Z0A_TIPO == 'S'
					aCpoEnc := {"NOUSER"}
		
					SX3->( dbSetOrder(1) )
					SX3->( dbSeek( "Z0A" ) )
					While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == "Z0A"
						If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And.;
							!( alltrim(SX3->X3_CAMPO) $ "Z0A_DATA1#Z0A_DATA2#Z0A_HORA1#Z0A_HORA2#Z0A_USER1#Z0A_USER2#Z0A_BALAN1#Z0A_BALAN2#Z0A_PESO1#Z0A_PESO2#Z0A_PEDIDO" )
							IF alltrim(SX3->X3_CAMPO) $ "Z0A_OPER#Z0A_PRODUT#Z0A_PDDESC#Z0A_PROCED#Z0A_DESPRO#Z0A_MSBLQL"
								SX3->( dbSkip() )
								Loop
							EndIF
							aAdd(aCpoEnc,SX3->X3_CAMPO)
						EndIF
						SX3->( dbSkip() )
					EndDO
				EndIf

				//Carrega os campos para a memória.
				RegToMemory("Z0A", .F.)
				nRecNo := Z0A->(RecNo())
				
				// Na segunda pesagem já informa o campo embalagem a partir da ordem de carregamento
				If ValType(Z0C->Z0C_EMBALA) != "U"
					M->Z0A_EMBALA := Z0C->Z0C_EMBALA
					If ExistTrigger("Z0A_EMBALA")
						RunTrigger(1,Nil, Nil,, "Z0A_EMBALA")
					EndIf
				EndIf
				//+-----------------------------------------------------+
				//! Atribuição dos valores aos campos carregados.       !
				//+-----------------------------------------------------+
				M->Z0A_DATA2 := Date()
		   		M->Z0A_HORA2 := Time()
				M->Z0A_USER2 := cUserName
				
				//Função para montagem da tela de pesagem.
				GeraTela()
				//Montagem dos campos da parte de cima da tela.
				EnChoice("Z0A", nil, 4, , , , aCpoEnc/*aCpoEnc*/, {001,001,110,365}, /*aCpoEnc*/, 3,,,,oFld:aDialogs[1])

				
				ACTIVATE DIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,{|| IIF(lConfirma:=Valida(),oDlg:End(),NIL), oTimerBal:Deactivate()},{||oDlg:End(),DelArq(),oTimerBal:Deactivate()},,))

			EndIF
		Else
			//Aviso caso não exista registro.
			Aviso( 'ATENÇÃO', 'Registro não encontrado na base de dados.', { 'Ok' }, 2 )
		EndIf
	EndIf
	
	//Verifica se o usuário confirmou a inclusão do ticket.
	IF( lConfirma )
		//Se sim, executa a função para salvar os dados em memória para a base.
		AEST008B()
	ELSE
		//Se não, faz o rollback no sequêncial do ticket.
		Z0A->(ROLLBACKSX8())
	ENDIF
	
	U_CloseBal(@nBalHnd)
	
Return

Static Function Valida()
    Local lRet := .T.
    Local cTipoMT := ""
    Local nOpcAviso
    
    cTipoMT := Posicione("Z09", 01, xFilial("Z09") + M->Z0A_TIPOMT, "Z09_TIPOMT")
    
    If !Obrigatorio(aGets,aTela)
		lRet := .F.
    ElseIf Empty(M->&("Z0A_BALAN" + cValToChar(nNumPesag)))
		Aviso("ATENÇÃO", "Balança não encontrada.", {"OK"}, 2)
		lRet := .F.
	// Verifica se foi informado o peso corretamente
	ElseIf M->&("Z0A_PESO" + cValToChar(nNumPesag)) <= 0.0
		Aviso("ATENÇÃO", "O peso não foi informado.", {"OK"}, 2)
		lRet := .F.
	// Verifica se deve validar a foto e se o ticket possui ao menos UMA foto
	ElseIf lVldImg .And. !lTemFoto
		Aviso("ATENÇÃO", "Nenhuma foto foi encontrada para o ticket.", {"OK"}, 2)
		lRet := .F.
	// Se for caminhão, verifica as placas
	ElseIf cTipoMT == "C" .And. (Empty(strtran(M->Z0A_PLCCAR,"-","")) .Or. (Empty(strtran(M->Z0A_PLCCAV,"-",""))) .Or. Empty(M->Z0A_UFPCAV))
		Aviso("ATENÇÃO", "Alguma placa do caminhão não foi informada.", {"OK"}, 2)
		lRet := .F.
	ElseIf cTipoMT == "C" .And. Empty(M->Z0A_MOTORI)
		Aviso("ATENÇÃO", "O nome do motorista não foi informado.", {"OK"}, 2)
		lRet := .F.		
	ElseIf cTipoMT == "C" .And. Len(AllTrim(M->Z0A_CELMOT)) <= 3
		Aviso("ATENÇÃO", "O celular do motorista não foi informado.", {"OK"}, 2)
		lRet := .F.
	// Se for trem, verifica a placa específica
	ElseIf cTipoMT == "T" .And. Empty(strtran(M->Z0A_PLCVAG,"-",""))
			Aviso("ATENÇÃO", "A placa do vagão não foi informada.", {"OK"}, 2)
			lRet := .F.
			
	//deixar esta ELSE sem por ultimo
	Else
		IF M->Z0A_TIPO == "E"
			//somente na segunda pesagem
			IF nNumPesag == 1 .And. Z07->Z07_QBTRAN != 0
				nDiff := u_NumDiff(M->Z0A_PESO1, M->Z0A_PBORI)
				If nDiff > ( M->Z0A_PBORI / 100 * Z07->Z07_QBTRAN )
					//Aviso("Atenção","Há diferença entre a pesagem de origem e a pesagem atual(Peso Bruto x % Quebra em transito).", {"Ok"}, 2)
					nOpcAviso := Aviso("Atenção", "Há diferença entre a pesagem de origem e a pesagem atual(Peso Bruto x % Quebra em transito). Deseja continuar?",;
								{"Sim", "Não"}, 1, , , , , , 2) 
					// Se a opção for Não
					If nOpcAviso != 1
						lRet := .F.
					EndIf
					//lRet := .F.
				EndIf
			EndIF
		// Os campos Depósito, Box e Embalagem são obrigatórios na segunda pesagem da saída
		ElseIf M->Z0A_TIPO == "S" .And. nNumPesag == 2
			If Empty(M->Z0A_DEPOSI) .Or. Empty(M->Z0A_BOX) .Or. Empty(M->Z0A_EMBALA)
				Aviso("Atenção","Os campos Depósito, Box e Embalagem são obrigatórios.", {"Ok"}, 2)
				lRet := .F.
			ElseIf cTipoMT == "T" .And. Empty(M->Z0A_ORDCAR)
				Aviso("Atenção","O campo Ordem de Carregamento.", {"Ok"}, 2)
				lRet := .F.
			EndIf
		// O campo Ordem de carregamento
		ElseIf M->Z0A_TIPO == "S" .And. nNumPesag == 1 .And. cTipoMT == "T"
			If Empty(M->Z0A_ORDCAR)
				Aviso("Atenção","O campo Ordem de Carregamento é obrigatórios.", {"Ok"}, 2)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	// Se o tipo de transporte for trem, a ordem de carregamento é obrigatória
	If cTipoMT == "T" .And. M->Z0A_TIPO == 'S'
		If Empty(M->Z0A_ORDCAR)
			Aviso("Atenção","Não foi informada nenhuma ordem de carregamento.", {"Ok"}, 2)
			lRet := .F.
		EndIf
	EndIf

	IF cTipoMT == "C"
		M->Z0A_PLCVAG := Space(TamSX3("Z0A_PLCVAG")[1])
	ElseIF cTipoMT == "T"
		M->Z0A_PLCCAR := Space(TamSX3("Z0A_PLCCAR")[1])
		M->Z0A_PLCCAV := Space(TamSX3("Z0A_PLCCAV")[1])
		M->Z0A_UFPCAV := Space(TamSX3("Z0A_UFPCAV")[1])
	EndIF
	
	// So valida a seguir se as outras validacoes estao OK
	If lRet
		// Se o tipo do ticket for entrada, valida se esta entrada ultrapassa a quantidade informada na ordem
		If M->Z0A_TIPO == "E"
			// Calcula o saldo da operação
			nSaldoOP := U_CalTktOP(M->Z0A_OPER, M->Z0A_PLORI)
			If nSaldoOP < 0
				Aviso("Atenção","O peso informado para o ticket ultrapassou o limite da operação em: " + cValToChar(ABS(nSaldoOP)) + " TL.", {"Ok"}, 2)
				lRet := .F.
			EndIf
		Else
			// Se for um ticket de vagao, ja existem as OCs, entao eh possivel validar
			// Senao, só é possível validar na segunda pesagem pois na primeira não haverá OCs para este ticket (Caminhão->OC sempre vem depois do ticket)
			If cTipoMT == "T" .Or. nNumPesag == 2
						          // Se for primeira pesagem, informa o peso previsto, senão informa o peso líquido
				nSaldoOC := U_CalTktOC(IIF(cTipoMT == "T", M->Z0A_ORDCAR, ""), IIF(nNumPesag == 1, M->Z0A_PESPRE, M->Z0A_PESO2 - M->Z0A_PESO1))
				// Código comentado após definição junto ao usuário Sylas Morgado 
				// de que DIFICILMENTE a segunda pesagem poderá ser validada com base na soma das OC's pois o valor pesado
				// não eh rigorosamente igual ao valor previsto pelas OC's
				
				/*
				If nSaldoOC < 0
					Aviso("Atenção","O peso informado para o ticket é superior ao saldo disponível da ordem de carregamento em: " + cValToChar(ABS(nSaldoOC)) + " TL.", {"Ok"}, 2)
					lRet := .F.
				EndIf
				*/
			EndIf
		EndIf
	EndIf

Return(lRet)


// Função que localiza a impressora           
Static Function LocBalan()
	Local lRet := .F.
     
	dbSelectArea("Z0B")
	Z0B->(dbSetOrder(03))
	Z0B->(dbSeek(xFilial("Z0B") + AllTrim(GetClientIP()) ) )
	
	// Se encontrou a balança configura os campos
	If Z0B->(FOUND())
		cCodBal := Z0B->Z0B_CODIGO
		cImgDir := AllTrim(Z0B->Z0B_PTHIMG) + "\"
		lVldImg := IIF(Z0B->Z0B_VLDIMG == "S", .T., .F.)
		// Caminho absoluto do programa de captura
		cDirCapPic := cImgDir + cCapPicExe
		lRet := .T.
	Else
		//Aviso("ATENÇÃO", "Balança não encontrada para o IP: " + GetClientIP(), {"OK"}, 2)
		cCodBal := "    "
		cImgDir := ""
		cDirCapPic := ""
		lVldImg := .F.
	EndIf

Return(lRet)

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! GeraTela  ! Autor ! Marcos Perusselo   ! Data ! 29/02/2012	 !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Função que cria a tela e monta os paineis e seus               !
! 			! campos na tela dos tickets.                                    !
!			!                                                                !
! 			!                                                                !
+----------------------------------------------------------------------------*/
Static Function GeraTela()

	M->&("Z0A_BALAN" + cValToChar(nNumPesag)) := cCodBal
	
	oDlg := MSDialog():New(030,050,470,800,"Pesagem",,,,,CLR_BLACK,/*nClrBack*/,,,.T.,,,,,)
	oDlg:lEscClose := .T.
	
	aFld := {"Pesagem", "Foto"}
	oFld := TFolder():New(015,005,aFld,,oDlg,,,,.T.,,370,200)
	oFld:bSetOption := {|nOpt| IIF(nOpt == 2 .And. !lTemFoto, WinExec(cDirCapPic), NIL)}
	
	@ 114,005 SAY "1ª Pesagem"		OF oFld:aDialogs[1] PIXEL
	@ 114,215 SAY "2ª Pesagem"		OF oFld:aDialogs[1] PIXEL                                           
	//+-----------------------------------------------------+
	//! Itens do painel referente a primeira pesagem.       !
	//+-----------------------------------------------------+
	oTPanel1 := TPanel():New(125,005,"",oFld:aDialogs[1],,,,CLR_BLACK,/*nClrBack*/,150,060,.F.,.T.)
	@ 005,005 SAY "Data:" 			OF oTPanel1 PIXEL
	@ 005,075 SAY "Hora:" 			OF oTPanel1 PIXEL
	@ 025,005 SAY "Usuário:" 		OF oTPanel1 PIXEL
	@ 025,075 SAY "Balança:" 		OF oTPanel1 PIXEL
	@ 045,005 SAY "Peso:" 			OF oTPanel1 PIXEL
	@ 003,028 MSGET M->Z0A_DATA1 	OF oTPanel1 When .F. SIZE 040,010 PIXEL
	@ 003,098 MSGET M->Z0A_HORA1 	OF oTPanel1 When .F. SIZE 030,010 PIXEL
	@ 022,028 MSGET M->Z0A_USER1	OF oTPanel1 When .F. SIZE 040,010 PIXEL
	@ 022,098 MSGET M->Z0A_BALAN1 	OF oTPanel1 When IIF(nNumPesag == 2 .Or. !Empty(M->Z0A_BALAN1), .F., .T.) SIZE 040,010 F3 "Z0BIP" PIXEL
	@ 043,028 MSGET M->Z0A_PESO1 	OF oTPanel1 When IIF(nNumPesag == 1 .And. lHabPes, .T., .F.) PICTURE "@E 999,999,999.999" SIZE 040,010 ON CHANGE ChkDiff() PIXEL	
	oBtPesa1 := TButton():New(043, 098, "Pesar", oTPanel1,{|| M->Z0A_PESO1 := U_BALANCA(M->Z0A_BALAN1, @nBalHnd), U_VLDPESOT() },30,10,,,.F.,.T.,.F.,,.F.,{|| nNumPesag == 1},,.F.)
	//oBtPesa1 := TButton():New(043, 098, "Pesar", oTPanel1,{|| IF(oTimerBal:lActive, oTimerBal:Deactivate(), oTimerBal:Activate()) },30,10,,,.F.,.T.,.F.,,.F.,{|| nNumPesag == 1},,.F.)
	
	//+-----------------------------------------------------+
	//! Itens do painel referente a segunda pesagem.        !
	//+-----------------------------------------------------+
	oTPanel2 := TPanel():New(125,215,"",oFld:aDialogs[1],,,,CLR_BLACK,/*nClrBack*/,150,060,.F.,.T.)
	@ 005,005 SAY "Data:" 			OF oTPanel2 PIXEL
	@ 005,075 SAY "Hora:" 			OF oTPanel2 PIXEL
	@ 025,005 SAY "Usuário:" 		OF oTPanel2 PIXEL
	@ 025,075 SAY "Balança:" 		OF oTPanel2 PIXEL
	@ 045,005 SAY "Peso:" 			OF oTPanel2 PIXEL
	@ 003,028 MSGET M->Z0A_DATA2 	OF oTPanel2 When .F. SIZE 040,010 PIXEL
	@ 003,098 MSGET M->Z0A_HORA2 	OF oTPanel2 When .F. SIZE 030,010 PIXEL
	@ 022,028 MSGET M->Z0A_USER2 	OF oTPanel2 When .F. SIZE 040,010 PIXEL
	@ 022,098 MSGET M->Z0A_BALAN2 	OF oTPanel2 When IIF(nNumPesag == 1 .Or. !Empty(M->Z0A_BALAN2), .F., .T.) F3 "Z0BIP" SIZE 040,010 PIXEL
	@ 043,028 MSGET M->Z0A_PESO2 	OF oTPanel2 When IIF(nNumPesag == 2 .And. lHabPes, .T., .F.) PICTURE "@E 999,999,999.999" SIZE 040,010 ON CHANGE ChkDiff() PIXEL
	oBtPesa2 := TButton():New(043, 098, "Pesar",oTPanel2,{|| M->Z0A_PESO2 := U_BALANCA(M->Z0A_BALAN2, @nBalHnd), U_VLDPESOT() },30,10,,,.F.,.T.,.F.,,.F.,{|| nNumPesag == 2},,.F.) 	
	//oBtPesa2 := TButton():New(043, 098, "Pesar",oTPanel2,{|| IF(oTimerBal:lActive, oTimerBal:Deactivate(), oTimerBal:Activate()) },30,10,,,.F.,.T.,.F.,,.F.,{|| nNumPesag == 2},,.F.) 	
	//+-----------------------------------------------------+
	//! Itens do painel referente às diferenças             !
	//+-----------------------------------------------------+
	oTPanel4 := TPanel():New(112,160,"",oFld:aDialogs[1],,,,CLR_BLACK,,050,075,.F.,.T.)
	@ 001,005 SAY IIF(M->Z0A_TIPO == 'E', "Líq. Origem", "Previsto") OF oTPanel4 PIXEL
	@ 011,005 MSGET IIF(M->Z0A_TIPO == 'E', M->Z0A_PLORI, M->Z0A_PESPRE) When .F. OF oTPanel4 SIZE 040,010 PIXEL
	@ 026,005 SAY "Líquido"		 	OF oTPanel4 PIXEL
	@ 036,005 MSGET nDiffPes1 		OF oTPanel4 When .F. PICTURE "@E 999,999,999.99" SIZE 040,010 PIXEL
	@ 051,005 SAY "Diferença" 		OF oTPanel4 PIXEL
	@ 061,005 MSGET nDiffPes2		OF oTPanel4 When .F. PICTURE "@E 999,999,999.99" SIZE 040,010 PIXEL

	//nPesPrev := IIF(M->Z0A_TIPO == 'E', M->Z0A_PLORI, M->Z0A_PESPRE)
	
 	// Aba "Foto"
 	oTPanel3 := TPanel():New(001,001,"",oFld:aDialogs[2],,,,CLR_BLACK,/*nClrBack*/,370,200,.F.,.F.)
	@ 005,005 SAY "Foto Dianteira:"			OF oTPanel3 PIXEL
	@ 005,200 SAY "Foto Traseira :"			OF oTPanel3 PIXEL
	//oBmp1    := TBitmap():New(000,000, 320, 240,,"",.F., oTPanel2,,,.F.,.F.,,,,,.F.)
	oBtFoto := TButton():New(165, 310, "Capturar",oTPanel3,{|| WinExec(cDirCapPic), oTimer:Activate()},30,10,,,.F.,.T.,.F.,,.F.,,,.F.)
	// Timer de 2 segundos para verificação de imagens no diretório
	oTimer := TTimer():New(4000, {|| lTemFoto := UpdImgDir()}, oDlg)
	oTimer:Activate()
	
	// Timer da balanca
	oTimerBal := TTimer():New(500, {|| M->&("Z0A_PESO"+cValToChar(nNumPesag)) := U_BALANCA(M->&("Z0A_BALAN"+cValToChar(nNumPesag)), @nBalHnd), U_VLDPESOT() }, oDlg)
	//oTimerBal:Activate()

Return

Static Function ChkDiff() 
	If !Empty(M->Z0A_PESO1) .And. !Empty(M->Z0A_PESO2)
		nDiffPes1 := ABS(M->Z0A_PESO1 - M->Z0A_PESO2)
		
		If M->Z0A_TIPO == 'E'
			nDiffPes2 := M->Z0A_PLORI - nDiffPes1
		Else
			nDiffPes2 := nDiffPes1 - M->Z0A_PESPRE
		EndIf
		
	EndIf
Return

// Valida o peso da balança contra o peso bruto
User Function VLDPESOT()
	Local lRet := .T. 
	// Parâmetro que informa o valor (em porcentagem) que deve considerar na na diferenca
	Local nValDif := SuperGetMV("ES_DIFPES", .F., 0.5)
	
	// Se os pesos forem diferentes de zero e diferentes entre si
	If M->Z0A_PESO1 > 0 .And. M->Z0A_PBORI > 0 .And. (M->Z0A_PESO1 / M->Z0A_PBORI) != 1
		// Se a diferença entre pesos for maior que o valor do parâmetro
		If ABS(1 - (M->Z0A_PESO1 / M->Z0A_PBORI)) > (nValDif/100)
			Alert("A diferença entre o peso bruto e valor da balança é maior que " + cValToChar(nValDif) + "%.")
			lRet := .F.
		EndIf 
	EndIf
	
	// Tira foto no momento da pesagem
	lTemFoto := UpdImgDir()
	/*
	// Atualiza data e hora no momento da pesagem
	M->&("Z0A_DATA" + cValToChar(nNumPesag)) := Date()
	M->&("Z0A_HORA" + cValToChar(nNumPesag)) := Time()
	*/

Return(lRet .And. lTemFoto)                                                                            


// Função que verifica a existência de fotos no diretório informado no cadastro da balança
// Ao encontrar a foto, 
Static Function UpdImgDir()
	Local lRet := .F.
	
	If ValType(oBmp1) == "O"
		oBmp1:SetEmpty()
		oBmp1 := NIL
	EndIf
	If ValType(oBmp2) == "O"
		oBmp2:SetEmpty()
		oBmp2 := NIL
	EndIf
	
	// Foto da imagem dianteira
	If (File(cImgDir + cNmImgD + cImgExt))
		// Copia arquivos do cliente (Remote) para o servidor compactando antes de transmitir
		//CpyT2S( cImgDir + cNmImgD + cImgExt,cImgServ, .T. )
		// Exibe a imagem na tela
		oBmp1 := TBitmap():New(015,005,320,240,,cImgDir + cNmImgD + cImgExt,.T., oTPanel3,,,.F.,.T.,,,,,.T.)
		lRet := .T.
	EndIf
	
	If (File(cImgDir + cNmImgT + cImgExt))
		// Copia arquivos do cliente (Remote) para o servidor compactando antes de transmitir
		//CpyT2S( cImgDir + cNmImgD + cImgExt,cImgServ, .T. )
		// Exibe a imagem na tela
		oBmp2 := TBitmap():New(015,200,320,240,,cImgDir + cNmImgT + cImgExt,.T., oTPanel3,,,.F.,.T.,,,,,.T.)
		lRet := .T.
	EndIf
	
	// Se encontrou alguma foto, busca o peso da balança e pára o timer
	If lRet
		M->&("Z0A_PESO" + cValToChar(nNumPesag)) := U_BALANCA(M->&("Z0A_BALAN" + cValToChar(nNumPesag)), @nBalHnd)
		oTimer:DeActivate()
	EndIf
	
Return(lRet) 

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! LimpaCpos ! Autor ! Marcos Perusselo   ! Data ! 29/02/2012	 !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Funcao auxiliar para limpar os campos quando alterado          !
! 			! o tipo da operação.                                            !
!			!																 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function LimpaCpos()
	cGetCliCod 	:= Space(06)
	cGetCliLoj 	:= Space(04)
	cGetProd 	:= Space(30)
	cGetCliPed 	:= Space(10)
Return

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! MenuDef  	! Autor ! Marcos Perusselo   ! Data ! 29/02/2012	 !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Monta os botoes do menu.                						 !
! 			!                                                                !
!			!																 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE 'Pesquisar' 					 ACTION 'VIEWDEF.ANDALI_AEST008'	OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar'  					 ACTION 'VIEWDEF.ANDALI_AEST008'	OPERATION 2 ACCESS 0
	//ADD OPTION aRotina TITLE 'Banco de Conhecimento (Fotos)' ACTION '' 							OPERATION 8 ACCESS 0
Return (aRotina)

/*----------+-----------+-------+--------------------+------+----------------+
! Programa 	! AEST008C  ! Autor ! Marcos Perusselo   ! Data ! 29/02/2012	 !
+-----------+-----------+-------+--------------------+------+----------------+
! Descricao ! Função para salvar o ticket após confirmação de                !
! 			! inclusão pelo usuario.                                         !
!			!																 !
! 			! 																 !
+----------------------------------------------------------------------------*/
Static Function AEST008B()
	//Seleciona a área de tickets.
	dbSelectArea("Z0A")
	
	//Verifica se é a primeira pesagem.
	If( nNumPesag = 1 )
		//Trava a tabela de tickets para uma inclusão.
		RecLock("Z0A",.T.)		
		
		Z0A->Z0A_FILIAL := xFilial("Z0A")
		/*
		Z0A->Z0A_TICKET := M->Z0A_TICKET
		Z0A->Z0A_DOC    := M->Z0A_DOC
		Z0A->Z0A_SERIE  := M->Z0A_SERIE   
		Z0A->Z0A_OPER   := M->Z0A_OPER   
		Z0A->Z0A_TIPO	:= M->Z0A_TIPO
		Z0A->Z0A_CLICOD := M->Z0A_CLICOD
		Z0A->Z0A_CLILOJ := M->Z0A_CLILOJ
		Z0A->Z0A_CLINOM := M->Z0A_CLINOM
		Z0A->Z0A_PRODUT := M->Z0A_PRODUT
		Z0A->Z0A_PDDESC := M->Z0A_PDDESC
		Z0A->Z0A_PEDIDO := M->Z0A_PEDIDO
		Z0A->Z0A_ARMAZE := M->Z0A_ARMAZE
		Z0A->Z0A_ARDESC := M->Z0A_ARDESC
		Z0A->Z0A_DEPOSI := M->Z0A_DEPOSI
		Z0A->Z0A_DPDESC := M->Z0A_DPDESC
		Z0A->Z0A_BOX    := M->Z0A_BOX   
		Z0A->Z0A_EMBALA := M->Z0A_EMBALA
		Z0A->Z0A_EBDESC := M->Z0A_EBDESC
		Z0A->Z0A_TRANSP := M->Z0A_TRANSP
		Z0A->Z0A_TRDESC := M->Z0A_TRDESC
		Z0A->Z0A_MOTORI := M->Z0A_MOTORI
		Z0A->Z0A_CELMOT := M->Z0A_CELMOT
		Z0A->Z0A_TIPOMT := M->Z0A_TIPOMT
		Z0A->Z0A_PLCCAR := M->Z0A_PLCCAR
		Z0A->Z0A_PLCCAV := M->Z0A_PLCCAV
		Z0A->Z0A_PLCVAG := M->Z0A_PLCVAG
		Z0A->Z0A_PBORI  := M->Z0A_PBORI 
		Z0A->Z0A_PLORI  := M->Z0A_PLORI 
		Z0A->Z0A_EMINUT := M->Z0A_EMINUT
		Z0A->Z0A_PROCED := M->Z0A_PROCED
		Z0A->Z0A_DESPRO := M->Z0A_DESPRO
		*/
		For nC := 1 to len( aCpoEnc )
			IF u_TemCPO( "Z0A", aCpoEnc[nC])
				Z0A->&(aCpoEnc[nC]) := M->&(aCpoEnc[nC])
			EndIF
		Next(nC)
				
		// Campos relativos à pesagem 1
		Z0A->Z0A_PESO1  := M->Z0A_PESO1 
		Z0A->Z0A_USER1  := M->Z0A_USER1 
		Z0A->Z0A_DATA1  := M->Z0A_DATA1 
		Z0A->Z0A_HORA1  := M->Z0A_HORA1 
		Z0A->Z0A_BALAN1 := M->Z0A_BALAN1
		
		//Após a inclusão destrava a tabela de tickets.
		MSUnlock("Z0A")
		
		If U_GETTPMT(M->Z0A_TIPOMT) == "T" .And. !Empty(M->Z0A_ORDCAR)
			// Insere o registro da tabela Z0E
			RecLock("Z0E", .T.) 
			Z0E->Z0E_FILIAL := xFilial("Z0A")
			Z0E->Z0E_OC := M->Z0A_ORDCAR
			Z0E->Z0E_TICKET := M->Z0A_TICKET
			MsUnlock("Z0E")
		EndIf
		//Confirma o sequencial reservado para aquele ticket.
		ConfirmSX8()
		// Se não incluiu nenhuma imagem no banco de conhecimento, exclui as imagens do diretório
		If !GrvBcoCon() 
			DelArq()
		EndIf
		//Mostra uma mensagem de sucesso ao usuário.
		Aviso( 'SUCESSO', 'Ticket ' + M->Z0A_TICKET + ' incluído com sucesso.', { 'Ok' }, 2 )
		
		cGetCliCod := Space(06)
		cGetCliLoj := Space(04)
		cGetProd := Space(30)
		cGetCliPed := Space(10)
		cGetTick := Space(10)
		
	//Verifica se é a segunda pesagem e posiciona a tabela no ticket que será alterado.
	ElseIf( nNumPesag == 2 )
		Z0A->(dbGoTo(nRecNo))
		//Trava a tabela de tickets para uma alteração.
		RecLock("Z0A",.F.)
		
		// Atualiza Doc, Serie e itens da pesagem 2
 		/*
 		Z0A->Z0A_DOC    := M->Z0A_DOC
		Z0A->Z0A_SERIE  := M->Z0A_SERIE
		*/
		For nC := 1 to len( aCpoEnc )
			IF u_TemCPO( "Z0A", aCpoEnc[nC])
				Z0A->&(aCpoEnc[nC]) := M->&(aCpoEnc[nC])
			EndIF
		Next(nC)
		
		// Campos relativos à pesagem 2
		Z0A->Z0A_PESO2  := M->Z0A_PESO2 
		Z0A->Z0A_USER2  := M->Z0A_USER2 
		Z0A->Z0A_DATA2  := M->Z0A_DATA2 
		Z0A->Z0A_HORA2  := M->Z0A_HORA2 
		Z0A->Z0A_BALAN2 := M->Z0A_BALAN2
		
		//Após a inclusão destrava a tabela de tickets.
		MSUnlock("Z0A")
		// Se não incluiu nenhuma imagem no banco de conhecimento, exclui as imagens do diretório
		If !GrvBcoCon() 
			DelArq()
		EndIf
		//Mostra uma mensagem de sucesso ao usuário.
		Aviso( 'SUCESSO', 'Ticket ' + M->Z0A_TICKET +' atualizado com sucesso.', { 'Ok' }, 2 )
		
		cGetCliCod := Space(06)
		cGetCliLoj := Space(04)
		cGetProd   := Space(30)
		cGetCliPed := Space(10)
		cGetTick   := Space(10)
	EndIf
	
Return

Static Function GrvBcoCon()
	Local lRet	   := .F.
	Local cNewName := ""
	Local cAbsFile := ""
	Local cFile	   := ""
	Local cExten   := ""
	
	cAbsFile := cImgDir + cNmImgD + cImgExt
	// Novo nome de arquivo ( Núm. ticket + NumPesag + "D" + Extensao do arquivo) 
	cNewName := M->Z0A_TICKET + "_" + cValToChar(nNumPesag) + "_" + "D" + cImgExt
	// Renomeia o arquivo 
	FRename(cAbsFile, cImgDir + cNewName) 
	cAbsFile := cImgDir + cNewName
	If File(cAbsFile)
		// Copia a imagem dianteira para o BC
		lRet := Ft340CpyObj( cAbsFile )
		If lRet
			SplitPath( cAbsFile,,, @cFile, @cExten )
			dbSelectArea("ACB")
			RecLock("ACB", .T.)
			ACB->ACB_FILIAL := xFilial("ACB")
			ACB->ACB_CODOBJ := GetSX8Num( "ACB", "ACB_CODOBJ" )
			ACB->ACB_OBJETO := Left(Upper( cFile + cExten ), TamSX3("ACB_OBJETO")[1])
			ACB->ACB_DESCRI := "Foto " + cValToChar(nNumPesag) + "a Pesagem - Dianteira - Ticket " + M->Z0A_TICKET
			MsUnlock()
			ConfirmSx8()
			
			dbSelectArea("AC9")
			RecLock( "AC9", .T. )
			AC9->AC9_FILIAL  := xFilial("AC9")
			AC9->AC9_ENTIDA  := "Z0A"
			AC9->AC9_FILENT  := xFilial("Z0A")
			AC9->AC9_CODENT  := M->Z0A_TICKET
			AC9->AC9_CODOBJ  := ACB->ACB_CODOBJ
			AC9->(MsUnlock())    
		EndIf
		// Apaga o arquivo do diretório
		FErase(cAbsFile)
	EndIf
	
	cAbsFile := cImgDir + cNmImgT + cImgExt
	// Novo nome de arquivo ( Núm. ticket + NumPesag + "T" + Extensao do arquivo) 
	cNewName := M->Z0A_TICKET + "_" + cValToChar(nNumPesag) + "_" + "T" + cImgExt
	// Renomeia o arquivo 
	FRename(cAbsFile, cImgDir + cNewName)
	cAbsFile := cImgDir + cNewName
	If File(cAbsFile)
		// Copia a imagem dianteira para o BC
		lRet := Ft340CpyObj( cAbsFile )
		If lRet
			SplitPath( cAbsFile,,, @cFile, @cExten )
			dbSelectArea("ACB")
			RecLock("ACB", .T.)
			ACB->ACB_FILIAL := xFilial("ACB")
			ACB->ACB_CODOBJ := GetSXENum( "ACB", "ACB_CODOBJ" )
			ACB->ACB_OBJETO := Left(Upper( cFile + cExten ), TamSX3("ACB_OBJETO")[1])
			ACB->ACB_DESCRI := "Foto " + cValToChar(nNumPesag) + "a Pesagem - Traseira - Ticket " + M->Z0A_TICKET
			MsUnlock()
			ConfirmSx8()
			
			dbSelectArea("AC9")
			RecLock( "AC9", .T. )
			AC9->AC9_FILIAL  := xFilial("AC9")
			AC9->AC9_ENTIDA  := "Z0A"
			AC9->AC9_FILENT  := xFilial("Z0A")
			AC9->AC9_CODENT  := M->Z0A_TICKET
			AC9->AC9_CODOBJ  := ACB->ACB_CODOBJ
			AC9->(MsUnlock())    
		EndIf
		// Apaga o arquivo do diretório
		FErase(cAbsFile)
	EndIf
	
Return(lRet)
                         
Static Function DelArq()
	Local lRet	   := .F.
	Local cNewName := ""
	Local cAbsFile := ""
	Local cFile	   := ""
	Local cExten   := ""
	
	cAbsFile := cImgDir + cNmImgD + cImgExt
	// Novo nome de arquivo ( Núm. ticket + NumPesag + "D" + Extensao do arquivo) 
	//cNewName := M->Z0A_TICKET + "_" + cValToChar(nNumPesag) + "_" + "D" + cImgExt
	// Renomeia o arquivo 
	//FRename(cAbsFile, cImgDir + cNewName) 
	//cAbsFile := cImgDir + cNewName
	If File(cAbsFile)
		// Apaga o arquivo do diretório
		FErase(cAbsFile)
	EndIf
	
	cAbsFile := cImgDir + cNmImgT + cImgExt
	// Novo nome de arquivo ( Núm. ticket + NumPesag + "T" + Extensao do arquivo) 
	//cNewName := M->Z0A_TICKET + "_" + cValToChar(nNumPesag) + "_" + "T" + cImgExt
	// Renomeia o arquivo 
	//FRename(cAbsFile, cImgDir + cNewName)
	cAbsFile := cImgDir + cNewName
	If File(cAbsFile)
		// Apaga o arquivo do diretório
		FErase(cAbsFile)
	EndIf
	
Return

// Função para validar o saldo da ordem de carregamento com a quantidade a ser utilizada pelo ticket
User Function CalTktOC(cCodOrdem, nCarga)
	Local aZ0A := GetArea("Z0A")
	Local aZ0C := GetArea("Z0C")
	Local cAl  := GetNextAlias()
	Local nSaldo := 0
	Local nQtdUtil := 0
	Local nQtdDisp := 0
	Local lRet := .T.

    // Se o codigo da OC nao foi preenchido, sao multiplas OCs para este ticket
	If Empty(cCodOrdem)
		// Seleciona a soma das OC's para este ticket
		BeginSQL Alias cAl
			SELECT
				SUM(Z0C_QUANT) Z0C_QUANT
			FROM
			    %TABLE:Z0E% Z0E INNER JOIN %TABLE:Z0C% Z0C ON (
			    Z0E.Z0E_FILIAL 	= Z0C.Z0C_FILIAL
			AND	Z0E.Z0E_OC		= Z0C.Z0C_CODIGO
			)
			WHERE
				Z0E.Z0E_FILIAL	= %Exp:xFilial("Z0E")%
			AND	Z0E.Z0E_TICKET	= %Exp:M->Z0A_TICKET% 
			GROUP BY
				Z0E.Z0E_FILIAL,
				Z0E.Z0E_TICKET
		EndSQL
		
		// Atualiza a quantidade indicadas para carregamento nas OCs
		nQtdDisp := (cAl)->Z0C_QUANT		
		(cAl)->(dbCloseArea())
		
		cAl := GetNextAlias()
		// Seleciona a soma das quantidades ja utilizadas por outros tickets para as OCs listadas
		BeginSQL Alias cAl
			SELECT
				SUM(CASE Z0A_PESO2 WHEN 0 THEN Z0A_PESPRE ELSE Z0A_PESO2 - Z0A_PESO1 END) Z0A_QUANT
			FROM
			    %TABLE:Z0E% Z0E INNER JOIN %TABLE:Z0A% Z0A ON (
			    Z0E.Z0E_FILIAL 	= Z0A.Z0A_FILIAL
			AND	Z0E.Z0E_TICKET	= Z0A.Z0A_TICKET
			)
			WHERE
				Z0E.Z0E_FILIAL	= %Exp:xFilial("Z0E")%
			AND Z0E.Z0E_TICKET <> %Exp:M->Z0A_TICKET%
			AND	Z0E.Z0E_OC IN (
				SELECT
					Z0E_OC
				FROM
					%TABLE:Z0E% Z0E
				WHERE
					Z0E_FILIAL = %Exp:xFilial("Z0E")%
				AND Z0E_TICKET = %Exp:M->Z0A_TICKET%
			)
			GROUP BY
				Z0E.Z0E_FILIAL,
				Z0E.Z0E_TICKET
		EndSQL
		
		// Atualiza a quantidade indicadas para carregamento nas OCs
		nQtdUtil := (cAl)->Z0A_QUANT		
		(cAl)->(dbCloseArea())
	Else                      
		// Se nao, calcula a quantidade utilizada com base na OC informada
		dbSelectArea("Z0C")
		Z0C->(dbSetOrder(01))
		Z0C->(dbGoTop())
		// Posiciona na ordem de carregamento informada
		Z0C->(dbSeek(xFilial("Z0C") + cCodOrdem))

		nQtdDisp := Z0C->Z0C_QUANT
		
		dbSelectArea("Z0A")
		Z0A->(dbSetOrder(08))
		Z0A->(dbGoTop())
		Z0A->(dbSeek(xFilial("Z0A") + cCodOrdem))
		While !Z0A->(EOF()) .And. Z0A->Z0A_FILIAL == xFilial("Z0A") .And. Z0A->Z0A_ORDCAR == cCodOrdem 
			If Z0A->Z0A_TICKET != M->Z0A_TICKET .And. Z0A->Z0A_MSBLQL != '1'
				// Se já possuir segunda pesagem considera o peso líquido do ticket
				If !Empty(Z0A->Z0A_PESO2)
					nQtdUtil += Z0A->Z0A_PESO2 - Z0A->Z0A_PESO1
				// Senão considera o peso previsto
				Else
					nQtdUtil += Z0A->Z0A_PESPRE
				End
			EndIf
			Z0A->(dbSkip())
		EndDo
	EndIf
	
	
	nSaldo := nQtdDisp - (nQtdUtil + nCarga)
	// Se a quantidade utilizada mais o peso do ticket atual for maior que a quantidade da ordem, falso
	If nSaldo < 0
		lRet := .F.
	EndIf
	
	RestArea(aZ0A)
	RestArea(aZ0C)
	
Return(nSaldo)

// Função para validar o saldo da operação de entrada com a quantidade a ser utilizada pelo ticket
User Function CalTktOP(cCodOper, nCarga)
	Local aZ0A := GetArea("Z0A")
	Local aZ07 := GetArea("Z07")
	Local nSaldo := 0
	Local nQtdUtil := 0
	Local lRet := .T.

	dbSelectArea("Z07")
	Z07->(dbSetOrder(01))
	Z07->(dbGoTop())
	// Posiciona na operação informada
	Z07->(dbSeek(xFilial("Z07") + cCodOper))
	
	dbSelectArea("Z0A")
	Z0A->(dbSetOrder(03))
	Z0A->(dbGoTop())
	Z0A->(dbSeek(xFilial("Z0A") + cCodOper))
	While !Z0A->(EOF()) .And. Z0A->Z0A_FILIAL == xFilial("Z0A") .And. Z0A->Z0A_OPER == cCodOper
		// Considera o peso líquido origem
		If Z0A->Z0A_TICKET != M->Z0A_TICKET .And. Z0A->Z0A_MSBLQL != '1'
			nQtdUtil += Z0A->Z0A_PLORI
		EndIf
		Z0A->(dbSkip())
	EndDo
	
	nSaldo := Z07->Z07_QUANT - (nQtdUtil + nCarga)
	// Se a quantidade utilizada mais o peso do ticket atual for maior que a quantidade da ordem, falso
	If nSaldo < 0
		lRet := .F.
	EndIf
	
	RestArea(aZ0A)
	RestArea(aZ07)
	
Return(nSaldo)

User Function GETTPMT(cTipoMT)      	
	Local cTipo := ""
	
	If Empty(cTipoMT)
		Return("")
	EndIf
	
	dbSelectArea("Z09")
	dbsetorder(01)
	If dbSeek(xFilial("Z09") + cTipoMT)
		cTipo := Z09->Z09_TIPOMT
	Else
		MsgAlert("Nao encontrado")
	EndIF
Return(cTipo)

Static Function AjustaSX1(cPerg)
	PutSX1(cPerg, "01", "Procedência ?" , "", "", "mv_ch1", "C",TamSX3("Z01_CODIGO")[1],0, 0, "G", "", "Z01OPE", "", "", "mv_par01")
Return


User Function OPERCLI()
Local lRet := Z07->Z07_OPER=='S'

IF lRet
	lRet := IIF(Alltrim(Upper(FunName()))=="AEST011",(Z07->Z07_CLICOD==Z0A->Z0A_CLICOD .and. Z07->Z07_CLILOJ==Z0A->Z0A_CLILOJ .And. Z07->Z07_TICKET == "S"), .T.)
EndIF

RETURN(lRet)
