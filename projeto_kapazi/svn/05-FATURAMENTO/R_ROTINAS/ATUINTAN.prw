#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
#Include "tbiconn.ch"

//==================================================================================================//
//	Programa: ATUINTAN 	|	Autor: Luis/Rsac																|	Data: 28/01/2018				//
//==================================================================================================//
//	Descrição: Rotina de sincronizacao forcada de pedidos																						//
//																																																	//
//==================================================================================================//
User Function ATUINTAN()
Private oDlg		:= nil
Private cFil_Int	:= Space(2)
Private oFil_Int	:= nil
Private cPV_Int		:= Space(6)
Private oPV_Int		:= nil
Private nBtoOk		:= 0
Private cPrompt		:= "Informe a filial e o numero do pedido de venda"
	

DEFINE MSDIALOG oDlg TITLE "[Sincronizacao de pedidos de venda]" From 001,001 to 220,500 Pixel

nLinha := 32
@ nLinha, 02  group obroup to 100,210 PIXEL prompt cPrompt oF oDlg
nLinha += 20

@ nLinha, 005 SAY  "Filial?" SIZE 040, 007 OF oDlg  PIXEL
@ nLinha, 055 MSGET oFil_Int VAR cFil_Int SIZE 50, 010 WHEN .T. OF oDlg COLORS 0, 16777215 PIXEL

nLinha += 20

@ nLinha, 005 SAY  "Pedido de venda?" SIZE 050, 007 OF oDlg  PIXEL
@ nLinha, 055 MSGET oPV_Int VAR cPV_Int SIZE 50, 010 WHEN .T. OF oDlg COLORS 0, 16777215 PIXEL


nLinha += 20

ACTIVATE MSDIALOG oDlg CENTERED ON INIT ENCHOICEBAR( oDlg,{ || nBtoOk := 1, oDlg:End() },{ || nBtoOk := 0, oDlg:End() } )

If nBtoOk == 0
		Help( ,, 'Atualizacao de pedidos',, 'Cancelado pelo usuário!!!!!!!', 1, 0 )
		cFil_Int	:= Space(2)
		cPV_Int		:= Space(6)
		
	Else
		If !Empty(cFil_Int) .And. !Empty(cPV_Int)
				AtempInd()
			Else
				MsgInfo("Preencha a filial e o numero do pedido!!")
		EndIf
EndIf 


	
	
Return()


Static Function AtempInd()
Local cRet		:= ""
Local cQry		:= ""
Local cAliasC5
Local nRegs 	:= 0
Local lRet		:= .T.

If Select("cAliasC5") <> 0
	DBSelectArea("cAliasC5")
	cAliasC5->(DBCloseArea())
Endif

cAliasC5		:= GetNextAlias()

/*
cQry	+= " SELECT *
cQry	+= " FROM 
cQry	+= " (SELECT EMPRESA = '04',SC5.C5_FILIAL,SC5.C5_NUM,ISNULL(SC52.C5_NUM,'') AS PED2
cQry	+= " FROM SC5040 SC5
cQry	+= " LEFT JOIN SC5030 AS SC52 ON SUBSTRING(SC52.C5_K_PO ,3 ,2) = SC5.C5_FILIAL AND SUBSTRING (SC52.C5_K_PO ,5 ,6) = SC5.C5_NUM AND SC52.D_E_L_E_T_ = '' AND SC52.C5_K_PO <> '' AND SC52.C5_EMISSAO = '20180126'
cQry	+= " WHERE SC5.C5_EMISSAO >= '20180101'
cQry	+= "		AND SC5.C5_EMISSAO <= '20180122'
cQry	+= "		AND SC5.D_E_L_E_T_ = ''
cQry	+= "		AND SC5.C5_K_INTAN > 0
cQry	+= "		AND SC5.C5_PVINTAN IN (' ', 'S')
cQry	+= "		AND SC5.R_E_C_N_O_ > 252515
cQry	+= "		AND SC5.C5_NUM IN (	'191091','191122','006214','191176','006222','022668','012440','191346','191444','191461','006253','191495','191510','191593',
cQry	+= "		'191602','012473','012475','191682','017554','191799','191897','191898','012490','012497','191977','192001','022795','012508','012511','192236','012513',
cQry	+= "		'192282','192307','022822','006325','006328')
cQry	+= "		)AS SA61
cQry	+= " WHERE PED2 = ''
*/

cQry	+= " SELECT SC5.R_E_C_N_O_ AS RECOSC5 ,C5_EMISSAO,C5_K_PO,C5_EMPDEST,C5_K_INTAN,C5_PVINTAN,*
cQry	+= " FROM "+ RetSQLName("SC5") +" SC5
cQry	+= " WHERE  D_E_L_E_T_ = ''
cQry	+= "			AND C5_EMISSAO >= '20180101'
//cQry	+= "		AND C5_EMISSAO <= '20180122'
cQry	+= "		AND C5_K_INTAN > 0
cQry	+= "		AND C5_PVINTAN IN (' ', 'S')
cQry	+= "		AND C5_FILIAL = '"+cFil_Int+"'
cQry	+= "		AND C5_NUM = '"+cPV_Int+"'
//cQry	+= "		AND SC5.R_E_C_N_O_ > 252516
cQry	+= " ORDER BY SC5.R_E_C_N_O_ "


TcQuery cQry new Alias "cAliasC5"
Count to nRegs
cAliasC5->(DbGoTop())

If nRegs == 0
	MsgAlert("Pedido nao existente para esta filial!!!")
EndIf

If Alltrim(cAliasC5->C5_K_OPER) == '08' .OR. Alltrim(cAliasC5->C5_K_OPER) == '14'
	MsgAlert("Pedido de bonificacao nao e utilizado na regra de intangiveis!!!")
	lRet		:= .F.
EndIf

While !cAliasC5->(EOF()) .And. lRet
		
		If cFilant != cAliasC5->C5_FILIAL
			
			cFilant		:= 	cAliasC5->C5_FILIAL			//Seta a filial correta
			SM0->(DbSeek( cEmpAnt + cAliasC5->C5_FILIAL ) )//Seta SM0 correta
			If !RpcSetEnv(SM0->M0_CODIGO, SM0->M0_CODFIL)
				MsgAlert("Empresa nao localizada")
			EndIf
		
		EndIf
		
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1))
		SC5->(DbGoTop())
		If SC5->(DbSeek(cAliasC5->C5_FILIAL + cAliasC5->C5_NUM)) 
			
			//Logar na Filial antes
			//Conout("Data Pedido + " + Dtoc(dDatabase))
			GeraIntang(SC5->C5_EMPDEST,"01",dDatabase)  //FIXO "01" Sempre filial 01 Matriz
			Conout("Processou pedido("+cAliasC5->C5_NUM+") original de recno = "+ cValTochar(cAliasC5->RECOSC5))
			Alert("Processamento Finalizado!!")
		EndIf
		
		cAliasC5->(DbSkip())
EndDo

cAliasC5->(DbCloseArea())
Return()

Static Function GeraIntang(cEmpNew, cFilNew,dDtAtu )
Local 	nX					:= 0																		//Contador
Local 	nY					:= 0																		//Contador
Local 	aSC5 				:= {}																		//Array de dados da SC5
Local 	aSC6 				:= {}																		//Array de dados da SC6
Local 	aItens			:= {}																		//Linha
Local 	cEmpbkp			:= cFilAnt 															//Empresa atual
Local 	cFilbkp			:= cEmpAnt 															//Filial atual
//EM 02/06/2016
//Local 	cFilNew			:= Substr(GetMv("MV_EMPINT"), 3, 2)     //Nova filial
//Local 	cEmpNew			:= Substr(GetMv("MV_EMPINT"), 1, 2)     //Nova Empresa

Local 	cNum				:= ""																		//Numero do Pedido
Local 	cNumOrig		:= ""																		//Número original do pedido
Local 	nPosFil			:= 0																		//Posição filial
Local 	nPosNum			:= 0																		//Posição numero do pedido
Local 	lConec			:= .F.																	//Conectou no novo ambinete
Private lMsErroAuto := .F.                                  //Erro


//Verifica a houve intagíveis no pedido
If (SC5->C5_K_INTAN > 0) .and. SC5->C5_PVINTAN $ ' S'
	
	//Ordena SX3
	SX3->(DbSetOrder(1))
	
	//Posiciona na tabela de cabeçalho do pedido
	If SX3->(DbSeek("SC5"))
		
		//Loop na SX3
		While (!SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "SC5")
			
			//Verifica se o campo é real
			If (SX3->X3_CONTEXT != "V")
				
				//Verifica se existe conteúdo
				If (!Empty(SC5->&(SX3->X3_CAMPO)) .OR. Alltrim(SX3->X3_CAMPO) == "C5_K_PO")
					
					//Verifica os campos
					Do Case
						
						//Nota|Série|Numero do pedido
						//						Case (Alltrim(SX3->X3_CAMPO) $ "C5_NUM")
						
						//Adiciona o dado ao array do cabeçalho
						//							Aadd(aSC5, {SX3->X3_CAMPO, Space(06), Nil})
						
						//Valores
						Case (Alltrim(SX3->X3_CAMPO) == "C5_XTOTMER")
							
							//Adiciona o valor
							Aadd(aSC5, {SX3->X3_CAMPO, (SC5->&(SX3->X3_CAMPO) * (100 - SC5->C5_K_INTAN) / SC5->C5_K_INTAN), Nil})
							
							//Percentual do pedido
						Case (Alltrim(SX3->X3_CAMPO) == "C5_K_INTAN")
							
							//Adiciona o valor
							Aadd(aSC5, {SX3->X3_CAMPO, 100 - SC5->&(SX3->X3_CAMPO), Nil})
							
							//Percentual do pedido
						Case (Alltrim(SX3->X3_CAMPO) == "C5_K_PO")
							
							//Adiciona o valor
							//alterado em 16/07/14 - grava a filial origem junto com o pedido original
							//alterado em 16/03/16 - grava a empresa/filial origem junto com o pedido original
							//Aadd(aSC5, {SX3->X3_CAMPO, SC5->C5_NUM, Nil})
							Aadd(aSC5, {SX3->X3_CAMPO, cEmpAnt+SC5->C5_FILIAL+SC5->C5_NUM, Nil})

							//EM 06/06/2017
							//Tipode operacao
						Case (Alltrim(SX3->X3_CAMPO) == "C5_K_OPER")
							
							//Adiciona o valor
							Aadd(aSC5, {SX3->X3_CAMPO, ALLTRIM(GetMv("MV_OPERINT")), Nil})
							//ATE AQUI - EM 06/06/2017
							
							//Nota|Série|Numero do pedido
						Case (Alltrim(SX3->X3_CAMPO) $ "C5_TIPO|C5_CLIENTE|C5_CLIENT|C5_LOJAENT|C5_LOJACLI|C5_CGCCLI|C5_TRANSP|C5_TPFRETE|C5_TIPOCLI|C5_CONDPAG|C5_TABELA|C5_VEND1|C5_COMIS1|C5_MENNOTA|C5_USER|C5_MSGNOTA|C5_MSGCLI")
							
							//Adiciona o dado ao array do cabeçalho
							Aadd(aSC5, {SX3->X3_CAMPO, SC5->&(SX3->X3_CAMPO), Nil})
							
					EndCase
					
				EndIf
				
			EndIf
			
			//Próximo registro
			SX3->(DbSkip())
			
		EndDo
		
	EndIf
	
	//Ordena a tabela
	SC6->(DbSetOrder(1))
	
	//Posiciona do pedido
	If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))
		
		//Faz loop nos ítens do pedido
		While (!SC6->(Eof()) .AND. SC6->C6_NUM == SC5->C5_NUM)
			//Limpa o array
			aSC6 := {}
			
			//em 22/01/2015
			If SC6->C6_K_INTAN <> 0
				
				//Ordena SX3
				SX3->(DbSetOrder(1))
				
				//Posiciona na tabela de cabeçalho do pedido
				If SX3->(DbSeek("SC6"))
					
					//Loop na SX3
					While (!SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "SC6")
						
						//Verifica se o campo é real
						If (SX3->X3_CONTEXT != "V")
							
							//Verifica as opções
							Do Case
								
								//Valores
								Case (Alltrim(SX3->X3_CAMPO) $ "C6_PRCVEN|C6_PRUNIT|C6_XPRECPC|C6_X_PRCVE")
									
									//Adiciona o valor
									Aadd(aSC6, {SX3->X3_CAMPO, (SC6->&(SX3->X3_CAMPO) * (100 - SC5->C5_K_INTAN) / SC5->C5_K_INTAN), Nil})
									
									//Tes
								Case (Alltrim(SX3->X3_CAMPO) == "C6_TES")
									
									//Adiciona o valor
									Aadd(aSC6, {SX3->X3_CAMPO, GetMv("MV_TESINT"), Nil})

									//em 06/06/2017
									//Tipo de operacao
								Case (Alltrim(SX3->X3_CAMPO) == "C6_OPER")
									
									//Adiciona o valor

									Aadd(aSC6, {SX3->X3_CAMPO, ALLTRIM(GetMv("MV_OPERINT")), Nil})
									//Ate aqui - em 06/06/2017
																		
									//Nota fiscal|Série|Número do Pedido|Data do Faturamento
									//								Case (Alltrim(SX3->X3_CAMPO) $ "C6_NUM")
									
									//Adiciona o valor
									//									Aadd(aSC6, {SX3->X3_CAMPO, CriaVar(SX3->X3_CAMPO), Nil})
									
									//Quantidade de venda
								Case (Alltrim(SX3->X3_CAMPO) $ "C6_QTDVEN")
									
									//Grava a quantidade
									nQtdVen	 := SC6->&(SX3->X3_CAMPO)
									
									//Adiciona o dado ao array dos itens do pedido
									Aadd(aSC6, {SX3->X3_CAMPO, SC6->&(SX3->X3_CAMPO), Nil})
									
									//Quantidade liberada
								Case (Alltrim(SX3->X3_CAMPO) $ "C6_QTDLIB")
									
									//Adiciona o dado ao array dos itens do pedido
									Aadd(aSC6, {SX3->X3_CAMPO, nQtdVen, Nil})
									
									//Demais campos
								Case (Alltrim(SX3->X3_CAMPO) $ "C6_PRODUTO|C6_XLARG|C6_XCOMPRI|C6_XQTDPC|C6_ITEM")
									
									//Adiciona o dado ao array dos itens do pedido
									Aadd(aSC6, {SX3->X3_CAMPO, SC6->&(SX3->X3_CAMPO), Nil})
									
							EndCase
							
						EndIf
						
						//Próximo registro na SX3
						SX3->(DbSkip())
						
					EndDo
					
				EndIf
			EndIf
			If Len(aSC6) > 0
				Aadd(aItens, aSC6)
			EndIf
			
			//Próximo refistro SC6
			SC6->(DbSkip())
			
		EndDo
		
	EndIf
	
EndIf

If Len(aSC5) > 0
	conout("INICIO - intangiveis")
	conout(varinfo("aSC5",aSC5))
	//Executa um job
	//MATA410(aSC5,aItens,3)
	
	StartJob("U_KFATA001", GetEnvServer(), .T., aSC5, aItens, cEmpNew, cFilNew)
	
	If lMsErroAuto
		
		//Mostra mensagem de erro
		MostraErro()
		
		CONOUT("ERRO: " + MostraErro())
		
	endif
endif


Return Nil