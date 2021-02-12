/**********************************************************************************************************************************/
/** WMS                                                                                                                          **/
/** Rotina para efetuar transfernecia de produtos                                                                                **/
/** RSAC Soluções Ltda.                                                                                                          **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

#Define ENTER chr(13)+chr(10)

/******************************************************************************************/
/** user function TRAIL03A  					 										 **/
/** Rotina para transferencia de produtos separados para o endereço de separados         **/
/******************************************************************************************/
User Function TRAIL03A(cCodEmp,cCodFil,cIdUser,aTransf,nOpc,cDoc)
	//aTransf[nX][ 1] cProdOrig
	//aTransf[nX][ 2] cProdDest
	//aTransf[nX][ 3] cArmOrig
	//aTransf[nX][ 4] cArmDest
	//aTransf[nX][ 5] nQuant
	//aTransf[nX][ 6] cLoteOri
	//aTransf[nX][ 7] cLoteDest
	//aTransf[nX][ 8] cEndOri
	//aTransf[nX][ 9] cEndDest
	//aTransf[nX][10] dDtVlOri
	//aTransf[nX][11] dDtVlDest
	//aTransf[nX][12] observacao

	Local	lEnv 		:= StaticCall(KAP_WF03,environmentActions,1,cCodEmp,cCodFil,,,"SIGAEST",{"SB1"})
	Local 	cRet  		:= ""  
	Local 	aAuto		:= {}
	Local 	aItem		:= {}
	Local 	lDoc		:= .F.
	Local 	lUnLock		:= .F. 
	Local 	cObserva	:= ""
	Local 	cProdOrig
	Local 	cProdDest
	Local 	cArmOrig
	Local 	cArmDest
	Local 	nQuant
	Local 	cLoteOri
	Local 	cLoteDest
	Local 	cEndOri
	Local 	cEndDest
	Local 	dDtVlOri
	Local 	dDtVlDest
	Local 	nI
	// saldo em estoque para o produto atual
	Local   nSaldo      := 0
	Local	aSemSld		:= {}
	Local	nX			:= 0
	Local 	cMsgErro	:= ""
	Local	lRet		:= .F.
	// considera saldo de terceiro em nosso poder
	//Local   lConsTerc   := .F.
	// considera saldo a distribuir
	//Local   lConsNPT    := .F.
	// subtrai empenho (usar padrao)
	//Local   lConsEmp    := nil
	// considerar saldo a distribuir
	//Local   lConsAdis   := .T.
	// data final a considerar empenho (nao informado)
	//Local   dDtFinal    := nil
	Private cMsgRet 	:= ""
	Private lMsErroAuto := .F.
	Default cIdUser		:= RetCodUsr()
	Default cDoc  		:= ""  

	If lEnv
		//carrega as variaveis de ambiente
		U_VarAmb(cIdUser,cCodEmp,cCodFil)
	Endif

	If Empty(cDoc)
		// proximo documento
		cDoc:= GetSxENum("SD3","D3_DOC",1)
	Endif

	// zera execauto
	aAuto := {}
	aItem := {}
	
	if nOpc == 3
		// cabecalo
		aadd(aAuto,{cDoc,Date() }) 		
	Endif
	
	For nI := 1 to Len(aTransf)
		// zera o item
		aItem 		:= {}
		// obtem dados da transferencia
		cProdOrig 	:= padr(aTransf[nI, 1],TamSx3("D3_COD" 		)[1])
		cProdDest 	:= padr(aTransf[nI, 2],TamSx3("D3_COD" 		)[1])
		cArmOrig  	:= padr(aTransf[nI, 3],TamSx3("D3_LOCAL"	)[1])
		cArmDest  	:= padr(aTransf[nI, 4],TamSx3("D3_LOCAL" 	)[1])
		nQuant    	:= aTransf[nI, 5]
		cLoteOri  	:= padr(aTransf[nI, 6],TamSx3("D3_LOTECTL" 	)[1])
		cLoteDest 	:= padr(aTransf[nI, 7],TamSx3("D3_LOTECTL" 	)[1])
		cEndOri   	:= padr(aTransf[nI, 8],TamSx3("D3_LOCALIZ" 	)[1])
		cEndDest  	:= padr(aTransf[nI, 9],TamSx3("D3_LOCALIZ" 	)[1])
		dDtVlOri  	:= aTransf[nI,10]
		dDtVlDest 	:= aTransf[nI,11]
		cObserva	:= iif(Len(aTransf[nI])>=12,aTransf[nI,12],CriaVar("D3_OBSERVA",.F.) )

		If Empty(AllTRim(cObserva))
			cObserva := "TR_TRANSF DOC="+cDoc+" "
		Endif

		// posiciona no produto
		If SB1->( DbSeek(xFilial("SB1")+cProdOrig) )
			// atualiza descricao
			cDescOri	:= cDescDes	:= SB1->B1_DESC        
			// unidade de medida
			cUMOri		:= cUMDes	:= SB1->B1_UM

			// se produto original difrente produto de destino
			If cProdOrig <> cProdDest
				// posiciona no produto destino
				If SB1->( DbSeek(xFilial("SB1")+cProdDest) )
					// atualiza descricao
					cDescDes	:= SB1->B1_DESC
					// unidade de medida        
					cUMDes		:= SB1->B1_UM
				Endif
			Endif

			If nOpc == 3
				// vai pro inicio da b2
				SB2->( DbSetOrder(1) )
				// procura o regsitro
				IF SB2->( MsSeek(xFilial("SB2")+cProdOrig+cArmOrig) )
					If lUnLock .and. IsInCallStack("U_TRAIL04A") .AND. SB2->B2_STATUS == "2"
						// exibe msg
						conout( DtoS(Date() ) +"-"+Time()+ "| TRAIL03A Transferencia: TRAIL04A - desbloqueio de saldo do armazem origem:"+ Alltrim(SB2->B2_COD)+" " + AllTrim(SB2->B2_LOCAL)+"." )
						RecLock("SB2",.F.)
							SB2->B2_STATUS := "1"
						MsUnLock("SB2")
					Endif

					//DbSelectArea("SB2")
					// obtem saldo do produto (informa nquant para nao cosiderar essa quantidade no empenho)
					//nSaldo := SaldoSB2(lConsAdis,lConsEmp,dDtFinal,lConsTerc,lConsNPT,nQuant)+SB2->B2_SALPEDI-SB2->B2_QEMPN+AvalQtdPre("SB2",2)
					nSaldo := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,Date()+1)[1] - SB2->B2_RESERVA
					
					Conout( DtoS(Date() ) +"-"+Time()+ "| TRAIL03A Transferencia: "+AllTrim(SB2->B2_COD) + " " + AllTrim(SB2->B2_LOCAL) +", Qatu: "+ cValToChar(SB2->B2_QATU) +", Qt: "+cValToChar(nQuant)+", Sl:"+cValToChar(nSaldo) +", Res PV(SC9):"+cValToChar(SB2->B2_RESERVA)  )

					// se o saldo nao atende a quantidade
					If nSaldo < nQuant
						aadd(aSemSld,{	AllTrim(SB2->B2_COD		),;
										AllTrim(SB2->B2_LOCAL	),;
										cValToChar(nSaldo		),;
										cValToChar(nQuant		) ;
										})
						// exibe msg
						conout( DtoS(Date() ) +"-"+Time()+ "| TRAIL03A Transferencia: produto sem saldo na origem para realizar a transferencia - "+AllTrim(SB2->B2_COD)+" " + AllTrim(SB2->B2_LOCAL)+" Saldo: "+cValToChar(nSaldo)+", Qtd a transferir: "+cValTochar(nQuant) )
						// marca transferencia com erro para nao executar 
						lMsErroAuto := .T.
					Endif
				Else
					aadd(aSemSld,{	AllTrim(cProdOrig	),;
									AllTrim(cArmOrig	),;
									cValToChar(nSaldo	),;
									cValToChar(nQuant	) ;
									})

					// exibe msg
					conout( DtoS(Date() ) +"-"+Time()+ "| TRAIL03A Transferencia: nao localizado no armazem de origem - "+AllTrim(cProdOrig)+" " + AllTrim(cArmOrig) )
					// marca transferencia com erro para nao executar 
					lMsErroAuto := .T.
				Endif

				// se deu erro
				If lMsErroAuto
					// nao chega a criar o item no array de transferencia
					Loop
				Endif

				// vai pro inicio da b2
				SB2->( DbSetOrder(1) )
				// procura o regsitro
				IF !SB2->( MsSeek(xFilial("SB2")+cProdDest+cArmDest) )
					// se nao achou cria saldo inicial
					CriaSB2(cProdDest,cArmDest)
				Endif
			Endif

			// se nao isa enderecamento
			If !Localiza(cProdOrig)
				// zera endereco de origem
				cEndOri	:= CriaVar("D3_LOCALIZ")
				// zera endereco de destino
				cEndDest:= CriaVar("D3_LOCALIZ")
			Endif

			// se produto armazem e endereco de destino sao iguais ao produto armazem e endereco de origem
			If AllTrim(cProdOrig)+ AllTrim(cArmOrig) + AllTrim(cEndOri) == AllTrim(cProdDest) + AllTrim(cArmDest) + AllTrim(cEndDest)
				// exibe msg
				conout( DtoS(Date() ) +"-"+Time()+ "| TRAIL03A Transferencia: Skip Produto+Armazem+Endereco de destino igual de origem: " + AllTrim(cProdDest) +" "+ AllTrim(cArmDest) +" "+ AllTrim(cEndDest) )
				// proximo registro
				Loop
			Endif

			If lUnLock .and. SB2->B2_STATUS == "2" .and. IsInCallStack("U_TRAIL04A")
				// exibe msg
				conout( DtoS(Date() ) +"-"+Time()+ "| TRAIL03A Transferencia: TRAIL04A - desbloqueio de saldo do armazem destino: "+AllTrim(SB2->B2_COD)+" " + AllTrim(SB2->B2_LOCAL)+"." )
				RecLock("SB2",.F.)
					SB2->B2_STATUS := "1"
				MsUnLock("SB2")
			Endif

			// qtd seg um
			nQtd2 := Round( QtdComp( ConvUm( cProdOrig,nQuant,0,2) ),TamSx3("D3_QUANT")[2] )

			// momnta o array do item da transferencia
			//Origem
			
			If nOpc == 3
				aadd(aItem,{"ITEM"		,'001'						,Nil})
			Else
				aadd(aItem,{"D3_DOC"	,cDoc						,nil})
			Endif

			aadd(aItem,{"D3_COD"	,cProdOrig						,Nil})	//D3_COD

			If nOpc == 3
				aadd(aItem,{"D3_DESCRI"	,cDescOri					,Nil}) 	//D3_DESCRI
				aadd(aItem,{"D3_UM"		,cUMOri						,Nil})	//D3_UM
				aadd(aItem,{"D3_LOCAL"	,cArmOrig					,Nil}) 	//D3_LOCAL
				aadd(aItem,{"D3_LOCALIZ",cEndOri					,Nil})	//D3_LOCALIZ
				//Destino
				aadd(aItem,{"D3_COD"	,cProdDest					,Nil})	//D3_COD
				aadd(aItem,{"D3_DESCRI"	,cDescDes					,Nil})	//D3_DESCRI
				aadd(aItem,{"D3_UM"		,cUMDes						,Nil})	//D3_UM
				aadd(aItem,{"D3_LOCAL"	,cArmDest					,Nil})	//D3_LOCAL
				aadd(aItem,{"D3_LOCALIZ",cEndDest 					,Nil})	//D3_LOCALIZ
				
				//Lote Origem
				aadd(aItem,{"D3_NUMSERI",CriaVar("D3_NUMSERI")		,Nil})	//D3_NUMSERI
				aadd(aItem,{"D3_LOTECTL",cLoteOri					,Nil}) 	//D3_LOTECTL
				aadd(aItem,{"D3_NUMLOTE",CriaVar("D3_NUMLOTE")		,Nil})	//D3_NUMLOTE
				aadd(aItem,{"D3_DTVALID",dDtVlOri					,Nil})	//D3_DTVALID
				aadd(aItem,{"D3_POTENCI",0							,Nil})	//D3_POTENCI
				aadd(aItem,{"D3_QUANT"	,nQuant						,Nil})	//D3_QUANT
				aadd(aItem,{"D3_QTSEGUM",nQtd2						,Nil})	//D3_QTSEGUM
				aadd(aItem,{"D3_ESTORNO",CriaVar("D3_ESTORNO")		,Nil})	//D3_ESTORNO
				aadd(aItem,{"D3_NUMSEQ"	,CriaVar("D3_NUMSEQ" )		,Nil})	//D3_NUMSEQ
				
				//Lote destino
				aadd(aItem,{"D3_LOTECTL",cLoteDest					,Nil})	//D3_LOTECTL
				aadd(aItem,{"D3_NUMLOTE", ""		, Nil})
				aadd(aItem,{"D3_DTVALID",dDtVlDest					,Nil})	//D3_DTVALID
				aadd(aItem,{"D3_ITEMGRD",CriaVar("D3_ITEMGRD",.F.)	,Nil})	//D3_ITEMGRD
				
				//aadd(aItem,{"D3_IDDCF"	,CriaVar("D3_IDDCF",.F.)	,Nil})	//D3_IDDCF
				aadd(aItem,{"D3_OBSERVA",cObserva					,Nil})	//D3_OBSERVA
				//aadd(aItem,{"D3_CODLAN"	,CriaVar("D3_CODLAN",.F.)	,Nil}) 	//D3_CODLAN
				//aadd(aItem,{"D3_CODLAN"	,CriaVar("D3_CODLAN",.F.)	,Nil}) 	//D3_CODLAN
			Endif

			// adiciona ao array da rotina
			aadd(aAuto,aItem)
		EndIf
	Next

	VarInfo("aAuto",aAuto,0,.f.,.T.) 

	// se deu erro na validacao do saldo 
	If lMsErroAuto 
		// zera variavel de erro
		MsgRetWMS := "" 
		// faz loop nos itens com problema
		For nX := 1 to Len(aSemSld) 
			// monta msg de erro (produto - armazem | saldo | quantidade )
			MsgRetWMS 	+= aSemSld[nX][1]+" - "+aSemSld[nX][2]+" | Sld "+aSemSld[nX][3]+ " | Qtd "+aSemSld[nX][4]+ENTER 
		Next
		// altera o retorno
		lParamOk 		:= .F.
		// monta msg de retorno trail
		cRet 			:= "Produtos sem saldo no armazem de origem: "+MsgRetWMS
		// tipo de retorno		
		cDadosRetTipo 	:= ""
		// dados do retorno
		cDadosRet 		:= ""

		// msg de retorno
		// cMsgRet 		:= u_GetRetWms(lParamOk,cRet,cDadosRetTipo,cDadosRet)
		// exibe no console
		conout( DtoS(Date() ) +"-"+Time()+ "| TRAIL03A Transferencia: Erro "+  cRet)

	Else
		If Len(aAuto) > 1
			// inicia transacao
			Begin Transaction

				If nOpc == 6
					SD3->( DbSetOrder(2) )
					cDoc := Padr(AllTrim(cDoc),TamSx3("D3_DOC")[1])
					For nX := 1 to Len(aAuto)
						if SD3->(MsSeek(xFilial("SD3")+cDoc+aAuto[nX][2][2]))
							While !SD3->( EOF() ) .and. xFilial("SD3") == SD3->D3_FILIAL .and. SD3->D3_DOC == cDoc .and. SD3->D3_COD == aAuto[nX][2][2] 
								If SD3->D3_ESTORNO <> "S"
									// zera erro
									lMsErroAuto := .F.
									// executa transferenncia
									MSExecAuto({|x,y| mata261(x,y)},aAuto[nX],nOpc)	
									if lMsErroAuto
										exit
									Endif
								Endif
								SD3->(DbSkip())
							Enddo
							if lMsErroAuto
								exit
							Endif
						Endif
					Next
				Else
					// zera erro
					lMsErroAuto := .F.
					// executa transferenncia
					MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpc)	
				Endif

				// se deu erro
				If lMsErroAuto

					/* caso ocorra erro de ocorrencia na 12.1.17, ou campo obrigatorio
					aplicar o patch 1774720_MMIL-2246_12.1.17_TTTP120
					AJUDA:OCORRENCIA
					A ocorrência informada não foi          encontrada no cadastro de ocorrências.
					Array aheader com inconsistencia de dados.Favor verificar o layout do array enviado
					O Campos necessarios sao:
					Titulo     Campo      Tipo Tamanho Decimal */

					// desfaz a transacao
					DisarmTransactions()
					// recupera o erro padrao
					cMsgErro 		:= mostraerro()
					
					Conout(cMsgErro)
					
					MsgRetWMS 		:= FwNoAccent(cMsgErro)//(mostraerro('\'))
					// altera o retorno
					lParamOk 		:= .F.
					// monta msg de retorno trail
					cRet 			:= "Erro na execucao da rotina automatica: "+MsgRetWMS
					// tipo de retorno		
					cDadosRetTipo 	:= ""
					// dados do retorno
					cDadosRet 		:= ""
					lRet 			:= .F.

					// msg de retorno
					// cMsgRet 		:= u_GetRetWms(lParamOk,cRet,cDadosRetTipo,cDadosRet)
					// exibe no console
					conout( DtoS(Date() ) +"-"+Time()+ "| TRAIL03A Transferencia: Erro "+  cRet)
					// se nao deu erro
				Else
					/*
					SD3->( DbSetOrder(2) )
					SD3->( DbGoTOp() )
					If SD3->( DbSeek(xFilial("SD3") + cDoc))
						conout( DtoS(Date() ) +"-"+Time()+ "| TRAIL03A Transferencia: D3_NUMSEQ: "+ SD3->D3_NUMSEQ)
					EndIf
					*/
					// documento do retorno
					cDadosRet 		:= SD3->D3_NUMSEQ 
									
					// retorna ok
					lParamOk 		:= .T.
					// texto do retorno
					cRet 			:= "Executado com sucesso."
					// tipo do retorno		
					cDadosRetTipo 	:= "C"
					
					// msg de retorno
					// cMsgRet 		:= u_GetRetWms(lParamOk,cRet,cDadosRetTipo,cDadosRet)
					lRet 			:= .T.
					// exibe no console
					conout( DtoS(Date() ) +"-"+Time()+ "| TRAIL03A Transferencia: Ok "+ cRet)

				EndIf

				// finaliza transacao
			End Transaction

			If lDoc
				PutMv( "TR_TRDOCU",(StrTran(cDoc,"T")) )
			EndIf

		Endif
	Endif

	IF lEnv
		StaticCall(KAP_WF03,environmentActions,2)
	Endif

	// retorna
Return lRet


User Function Trail03B(	cCodEmp	,cCodFil,cIdUser,nOpc,cProdOrig,cProdDest,cArmOrig,cArmDest,nQuant,cLoteOri,cLoteDest,cEndOri,cEndDest,dDtVlOri,dDtVlDest 	)
	Local 	aTransf		:= {}
	Local	aItem		:= {}

	Default	nOpc		:= 3
	Default	cIdUser		:= "000001"
	Default	cProdOrig	:= CriaVar("D3_COD"		)
	Default	cProdDest	:= CriaVar("D3_COD"		)
	Default	cArmOrig	:= CriaVar("D3_LOCAL"	)
	Default	cArmDest	:= CriaVar("D3_LOCAL"	)
	Default	nQuant		:= 0
	Default	cLoteOri	:= CriaVar("D3_LOTECTL"	)
	Default	cLoteDest	:= CriaVar("D3_LOTECTL"	)
	Default	cEndOri		:= CriaVar("D3_LOCALIZ"	)
	Default	cEndDest	:= CriaVar("D3_LOCALIZ"	)
	Default	dDtVlOri	:= ""
	Default	dDtVlDest	:= ""

	aadd(aItem,AllTrim(cProdOrig)	)
	aadd(aItem,AllTrim(cProdDest)	)
	aadd(aItem,AllTrim(cArmOrig	)	)
	aadd(aItem,AllTrim(cArmDest	)	)
	aadd(aItem,nQuant 			)	//Val(nQuant)
	aadd(aItem,AllTrim(cLoteOri	)	)
	aadd(aItem,AllTrim(cLoteDest)	)
	aadd(aItem,AllTrim(cEndOri	)	)
	aadd(aItem,AllTrim(cEndDest	)	)
	aadd(aItem,Stod(dDtVlOri	)	)
	aadd(aItem,Stod(dDtVlDest	)	)
	aadd(aTransf,aItem		)

Return u_Trail03A(	cCodEmp		;
					,cCodFil	;
					,cIdUser	;
					,aTransf	;
					,nOpc	) //Val(nOpc)


User Function Trail03T()
	Local cCodEmp 	:= "04"
	Local cCodFil	:= "01"
	Local cIdUser	:= "000000"
	Local nOpc		:= 3
	Local cProdOrig	:= "01010101       "//"01010101"
	Local cProdDest	:= "01010101       "//"01010101"
	Local cArmOrig	:= "04"
	Local cArmDest	:= "01"
	Local nQuant	:= 5
	Local cLoteOri	:= "0000000001"//"0000000001"//"0000000001"//"000000000000000001" 
	Local cLoteDest	:= "0000000002"//"0000000001"//"0000000001"//"000000000000000001"
	Local cEndOri	:= "EXPEDICAO      "
	Local cEndDest	:= "ESPERA         "
	Local dDtVlOri	:= ""
	Local dDtVlDest := ""

	If Select('SX2') == 0
		RPCSetType( 3 )
		conout(dtoc(date())+'|'+time()+'|'+"Preparando ambiente utilizando empresa " + cCodEmp + " filial " + cCodFil)
		RpcSetEnv(cCodEmp,cCodFil,,,,GetEnvServer(),{ "SM2" })
	EndIf

	dDtVlOri 	:= "" //"20181207"//""
	dDtVlDest 	:= "" //"20181231"//""

	U_Trail03B(cCodEmp,cCodFil,cIdUser,nOpc,cProdOrig,cProdDest,cArmOrig,cArmDest,nQuant,cLoteOri,cLoteDest,cEndOri,cEndDest,dDtVlOri,dDtVlDest)

Return()



