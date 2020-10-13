#Include "Protheus.ch"
#Include "TopConn.CH"
#Include "rwmake.ch"
#Include "TBICONN.CH"
#Include "TryException.CH"

/*----------------+----------------------------------------------------------+
!Nome              ! EST100 - Cliente: Madero                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Execucao do MRP - unidades de negócio                   !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 30/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function EST100(aEmpresa)
Local cEmp     := aEmpresa[01] 
Local cFil     := aEmpresa[02] 
Local na       := 0
Local nAux     := 0
Local aParam   := {}
Local nRecL    := 0
Local lLock    := .T.
Local cAuxLog  := ""
Local cKeyLock := "MRP"+aEmpresa[01]+aEmpresa[02]
Local nDiasMx  := 0
Local nDiasMxF := 0
Local cUndMad  := ""
Local lRet	   := .T.
Local cUserProc:= ""
Private oEventL:=Nil  

	nAux:=ThreadId()
	ConOut("The process "+AllTrim(Str(nAux))+"has been started.")
	
	// -> Executa processo para todas as empresas
	Aadd(aParam,{cEmp,cFil})
	na:=1
	RPcSetType(3) 
	RpcSetEnv( aParam[na,1],aParam[na,2], , ,'EST' , GetEnvServer() )
    OpenSm0(aParam[na,1], .f.)
	SM0->(dbSetOrder(1))
	SM0->(dbSeek(aParam[na,1]+aParam[na,2]))
	nModulo := 4
	cEmpAnt := SM0->M0_CODIGO
	cFilAnt := SM0->M0_CODFIL
	    		   	
	// -> Verifica se o processo está em execução e, se tiver não executa o processo
	If LockByName(cKeyLock,.F.,.T.)
		ConOut("==>SEMAFORO: MRP em "+DtoC(Date()) + ": STARTED.")
	Else
		UnLockByName(cKeyLock,.F.,.T.)	
		RpcClearEnv()
		ConOut("==>SEMAFORO: MRP em "+DtoC(Date()) + ": RUNNING...")
		nAux:=ThreadId()
		ConOut("The MRP process "+AllTrim(Str(nAux))+" has been finished.")
		KillApp(.T.)
		Return("")
	EndIf

	// -> Posiciona nas eunidades de negócio : Unidade de negócio
	DbSelectArea("ADK")
	ADK->(DbOrderNickName("ADKXFILI"))
	ADK->(ADK->(DbSeek(xFilial("ADK")+cFilAnt)))
	   			   
	If !Empty(ADK->ADK_XNMPR)
	   	dDataBase:=ADK->ADK_XNMPR
	   	
		// -> inicializa o Log do Processo de MRP das unidades de negócio
		oEventL   :=EventLog():start("MRP - UNIDADES", dDataBase, "Iniciando processo de MRP das unidadades de negocio...","DEMPROJ", "SC4", "MRP | ")
	   	nRecL     :=oEventL:GetRecno()
		cFunNamAnt:= FunName()
		SetFunName("EST100")

		cAuxLog:="MRP | " + ": Executando processo de MRP..." 
		ConOut(cAuxLog)                              
		oEventL:SetAddInfo(cAuxLog,"")
			
		oEventL:setCountOk()
				
		// -> Verifica se pode executar o processo
		If  (Date() < ADK->ADK_XNMPR .or. Empty(ADK->ADK_XNMPR))
			cAuxLog:="MRP | " + "Ok: Aguardando proxima execucao: Data: " + DtoC(ADK->ADK_XNMPR)
			ConOut(cAuxLog)                              
			oEventL:SetAddInfo(cAuxLog,"")
			oEventL:Finish()
			SetFunName(cFunNamAnt)
			RpcClearEnv()
			ConOut("==>SEMAFORO: MRP em "+DtoC(Date()) + ": RUNNING...")
			nAux:=ThreadId()
			ConOut("The MRP process "+AllTrim(Str(nAux))+" has been finished.")
			KillApp(.T.)
			Return("")
		EndIf

		//#TB20200310 Thiago Berna - Solicitado que seja desconsiderado
		/*If ADK->ADK_XINVEN <> "S"
			cAuxLog:="MRP | " + "Ok: Aguardando inventario"
			ConOut(cAuxLog)                              
			oEventL:SetAddInfo(cAuxLog,"")
			oEventL:Finish()
			SetFunName(cFunNamAnt)
			RpcClearEnv()
			ConOut("==>SEMAFORO: MRP em "+DtoC(Date()) + ": RUNNING...")
			nAux:=ThreadId()
			ConOut("The process "+AllTrim(Str(nAux))+"has been finished.")
			KillApp(.T.)
			Return("")
	EndIf*/

		// -> Verifica o usuário utilizado no processo
		PswOrder(2)
	If !PswSeek("ressuprimento", .T. )
			cAuxLog:="MRP | " + "Usuario 'ressuprimento' nao encontrado. Favor criar usuario pelo configurador."
			ConOut(cAuxLog)                              
			oEventL:SetAddInfo(cAuxLog,"")
			oEventL:Finish()
			SetFunName(cFunNamAnt)
			RpcClearEnv()
			ConOut("==>SEMAFORO: MRP em "+DtoC(Date()) + ": RUNNING...")
			nAux:=ThreadId()
			ConOut("The MRP process "+AllTrim(Str(nAux))+" has been finished.")
			KillApp(.T.)
			Return("")
	Else
			cUserProc:=PswID()
	EndIf

		nDiasMx := ADK->ADK_XNDES
		nDiasMxF:= ADK->ADK_XNDESF
		cUndMad := ADK->ADK_XFILI
			
		lRet   :=.T.
		cAuxLog:="MRP | " + ": Verificando parametros..." 
		ConOut(cAuxLog)                              
		oEventL:SetAddInfo(cAuxLog,"")
				
		// -> Indica se deve quebrar as Solicitacoes de Compra em Lotes economicos, ou gerar uma unica  solicitacao. S = quebra, N = nao quebra
	If AllTrim(GetMv("MV_QUEBRSC",,"")) <> "N"
			cAuxLog:="MRP | " + "O parametro MV_QUEBRSC deverá estar preenchido com 'N'" 
			lRet   :=.F.
			ConOut(cAuxLog)                              
			oEventL:SetAddInfo(cAuxLog,"")
	EndIf

		// -> Indica se deve quebrar as Ordens  de  Producao  em Lotes Economicos, ou gerar uma unica Ordem de Producao.    S = quebra, N = nao quebra              
	If AllTrim(GetMv("MV_QUEBROP",,"")) <> "N"
			cAuxLog:="MRP | " + "O parametro MV_QUEBROP deverá estar preenchido com 'N'" 
			lRet   :=.F.
			ConOut(cAuxLog)                              
			oEventL:SetAddInfo(cAuxLog,"")
	EndIf

		// -> Indica se na explosao de neces. de mat. deve ser utilizada a qtd por embalagem/lote minimo como qtd valida antes de tentar o lote economico (S/N)     
	If AllTrim(GetMv("MV_USAQTEM",,"")) <> "N"
			cAuxLog:="MRP | " + "O parametro MV_USAQTEM deverá estar preenchido com 'N'" 
			lRet   :=.F.
			ConOut(cAuxLog)                              
			oEventL:SetAddInfo(cAuxLog,"")
	EndIf

		// -> Define os dias da semana a considerar no Prazo de Entrega. 0=(Default) Seg a Dom;1=Seg a Sab (inclusive) e 2=Seg a Sex 
	If GetMv("MV_CALCPRZ",,2) > 0
			cAuxLog:="MRP | " + "O parametro MV_CALCPRZ deverá estar preenchido com '0' (zero)" 
			lRet   :=.F.
			ConOut(cAuxLog)                              
			oEventL:SetAddInfo(cAuxLog,"")
	EndIf

		// -> Tipo de porcessamrnto do MRP 
	If AllTrim(GetMv("MV_A712PRC",,"")) <> "0"
			cAuxLog:="MRP | " + "O parametro MV_A712PRC deverá estar preenchido com '0' (zero)" 
			lRet   :=.F.
			ConOut(cAuxLog)                              
			oEventL:SetAddInfo(cAuxLog,"")
	EndIf

		// -> Permite definir a quantidade de threads a serem processadas simultaneamente na rotina de MRP para montagem do arquivo de trabalho  (1 a 20 threads).
	If GetMv("MV_A710THR",,99) > 10
			cAuxLog:="MRP | " + "O parametro MV_A710THR devera estar preenchido com valores entre 1 (um) e 10 (dez)" 
			lRet   :=.F.
			ConOut(cAuxLog)                              
			oEventL:SetAddInfo(cAuxLog,"")
	EndIf

		// -> Novo processo mrp
	If GetMv("MV_USANPRC",,.T.)
			cAuxLog:="MRP | " + "O parametro MV_USANPRC devera estar preenchido com .F. (falso)" 
			lRet   :=.F.
			ConOut(cAuxLog)                              
			oEventL:SetAddInfo(cAuxLog,"")
	EndIf
		
		// -> Filial da indústria
	If Empty(GetMv("MV_XFILIND",,""))
			cAuxLog:="MRP | " + "O parametro MV_XFILIND devera estar preenchido com o grupo e filial da industria no formato EE;FFFFFFFFFF" 
			lRet   :=.F.
			ConOut(cAuxLog)                              
			oEventL:SetAddInfo(cAuxLog,"")
	EndIf

		// -> Executa o procsso de importacao da previsão de vendas do Prophix
	If lRet
			cAuxLog:="MRP | " + ": Etapa 01 - Importacao das previsoes de vendas..." 
			ConOut(cAuxLog)                              
			oEventL:SetAddInfo(cAuxLog,"")
			lRet  :=U_EST100PV(oEventL)
			lErro1:=!lRet	   	
	EndIf

		// -> Processa o MRP
	If !lErro1
			cAuxLog:="MRP | " + ": Etapa 02 - Calculo das necessidades..." 
			ConOut(cAuxLog)                              
			oEventL:SetAddInfo(cAuxLog,"")
			lRet  :=u_xRunMRP(cUndMad, nDiasMx, oEventL, nDiasMxF)
			lErro1:=!lRet
	EndIf
			
		// -> Firma demandas
	If lRet
			cAuxLog:="MRP | " + ': Etapa 03 - Firmando necessidades de compras...'
			ConOut(cAuxLog)                              
			oEventL:SetAddInfo(cAuxLog,"")			
			// -> Aglutinacao de Solicitacoes de Compras 
			lRet  :=U_xESTFIR(cUndMad, oEventL, nDiasMxF)	
			lErro1:=!lRet							
	Endif

		// -> Gera pedidos de compras
	If !lErro1
			cAuxLog:="MRP | " + ": Etapa 04 - Geracao de pedidos..." 
			ConOut(cAuxLog)                              
			oEventL:SetAddInfo(cAuxLog,"")
			lRet  :=PutSC7(oEventL)		
			lErro1:=!lRet
	EndIf

		// -> Atualiza dados do processo para a unidade
	If !lErro1 .and. AllTrim(oEventL:GetStep()) == "04"
			cAuxLog:="MRP | " + ": Etapa 05 - Preparando o proximo calculo..." 
			ConOut(cAuxLog)                              
			// -> Atualizar a data da execucao 
		If RecLock("ADK",.f.)
				ADK->ADK_XBMPR :=ADK->ADK_XNMPR
				ADK->ADK_XNMPR :=ADK->ADK_XNMPR+7 
				ADK->ADK_XINVEN:="N"
				ADK->(MsUnlock())
				oEventL:SetStep("05")
		EndIf
			cAuxLog:="MRP | " + "Ok." 
			ConOut(cAuxLog)                              
	EndIf

		SetFunName(cFunNamAnt)
					
EndIf
				
	// -> Destava o semaforo
If oEventL <> Nil
		oEventL:finish()
EndIf
	UnLockByName(cKeyLock,.F.,.T.)	
	RpcClearEnv()
	ConOut("==>SEMAFORO: MRP em "+DtoC(Date()) + ": FINISHED...")
	nAux:=ThreadId()
	ConOut("The MRP process "+AllTrim(Str(nAux))+"has been finished.")
	KillApp(.T.)
	   
Return("")




/*-----------------+---------------------------------------------------------+
!Nome              ! RunMRP - Cliente: Madero                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Execucao do MRP                                         !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 22/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function xRunMRP(cUndMad, nDiasMx, oEventLog, nDiasMxF)
Local cMsgErr     	:= ""
Local cErrLinha   	:= "" 
Local cAliTmp0    	:= GetNextAlias()
Local cAliTmp2    	:= GetNextAlias()
Local cAliTmp3    	:= GetNextAlias()
Local lMRP        	:= .t.
Local nx, nk      	:= 0 
Local aParmMRP    	:= {}
Local lRet        	:= .T.
Local aArea       	:= GetArea()
Local cAuxF       	:= cFilAnt
Local cAuxE       	:= cEmpAnt
Local _xaEventLog 	:= {} 
Local lFound      	:= .T.
Local lFoundInd   	:= .F.
Local aDatasMRP	  	:= {}
Local dDataNec    	:= CtoD("  /  /  ")
Local cZ25GRPCOM  	:= ""
Local cZ25GRPPRO  	:= ""
Local nZ25XDIAES  	:= 0
Local cZ25CODFOR  	:= ""
Local cZ25CODLOJ  	:= ""
Local cZ25CODTAB  	:= ""
Local nZ25VALOR   	:= 0
Local cFonLojInd  	:= ""
Local cZ25CC      	:= ""
Local cZ25OP      	:= ""
Local cZ25TES     	:= ""
Local lErro       	:= .F.
Local aErroProc     := {}
Local cQuery      	:= "" 
Local aPerg711    	:= {}
Local aParEmpFil // Parametro de Empresa;Filial da Fabrica
Local cParEmpF   // Codigo da empresa da Fabrica
Local cParFilF   // Codigo da filial da Fabrica
Local aTmpQry
Local cDtCalc
Local dDtCalc   
Local oError
Local cFilialZ22	:= xFilial('Z22')
Local cFilialSB1	:= xFilial('SB1')
Local cFilialZ25	:= xFilial('Z25')
Local cFilialSAJ	:= xFilial('SAJ')
Local cFilialSA2	:= xFilial('SA2')
Local cFilialSF4	:= xFilial('SF4')
Local aErroSAJ      := {}
Local aErroSA5      := {}
Local aErroSB1      := {}
Local aErroSA2      := {}
Local cProdAnt		:= '' 
Local aDadosSA5     := {}
Local lAtuind       := .F.

//#TB20191129 Thiago Berna - Ajuste para receber retorno antes de encerrar a thread.
Local cThdId01		:= 'ID' + AllTrim(Str(ThreadId())) + CriaTrab(,.F.)
Local cThdId02		:= 'ID' + AllTrim(Str(ThreadId())) + CriaTrab(,.F.)
Local aErroGlb		:= {}
Local aEvenGlb		:= {}

Private aHeader   	:= {} 
Private aCols     	:= {}
Private n    	  	:= 1

//#TB20191129 Thiago Berna - Ajuste para receber retorno antes de encerrar a thread.
PutGlbVars(cThdId01,aErroGlb)
PutGlbVars(cThdId02,aEvenGlb)
	
	cAuxLog:="MRP | " + ': Verificando demandas calculadas...' 
	ConOut(cAuxLog)                              
	oEventLog :SetAddInfo(cAuxLog,"")
	aParEmpFil:=separa(GetMV("MV_XFILIND"), ";")	
	lAtuind   :=GetMV("MV_XATUIND",,.T.)		
	dDtCalc   := dDataBase+nDiasMxF
	cDtCalc   := dtos(dDtCalc)
	sDataBase := DtoS(dDataBase)
	
	BEGINSQL ALIAS cAliTmp0
		SELECT Z25_DATA, Z25_DTNECE
		FROM %table:Z25% Z25
		JOIN %table:SB1% SB1
			ON Z25.Z25_FILIAL  = SB1.B1_FILIAL AND 
			   Z25.Z25_PRODUT  = SB1.B1_COD    AND 
			   SB1.%notDel%
		WHERE Z25.Z25_FILIAL  = %exp:cUndMad%   AND 
		      Z25.Z25_DATA    = %exp:sDataBase% AND
		      Z25.Z25_PEDIDO <> ' '             AND 
		      Z25.%notDel% 
	ENDSQL
	aTmpQry := GetLastQuery()
	lMRP    := (cAliTmp0)->(eof())
	(cAliTmp0)->(dbCloseArea())

	If lMRP

		If AllTrim(oEventLog:GetStep()) $ "01"

			cAuxLog:="MRP | " + ': Excluindo demandas ja calculadas...'
			ConOut(cAuxLog)
			oEventLog:SetAddInfo(cAuxLog,"")

			cQuery := " DELETE FROM "+RetSQLName("Z25")            "
			cQuery += " WHERE Z25_FILIAL = '" + cFilialZ25 + "' "
			cQuery += " AND Z25_DATA >= '" + DtoS(dDataBase)  + "' "
			TCSqlExec(cQuery)

			cAuxLog:="MRP | " + 'Ok.'
			ConOut(cAuxLog)
			oEventLog:SetAddInfo(cAuxLog,"")

			cAuxLog:="MRP | " + ': Executando calculo do MRP...'
			ConOut(cAuxLog)
			oEventLog:SetAddInfo(cAuxLog,"")
			aParmMRP := {cEmpAnt, cFilAnt, cUndMad, nDiasMx,  oEventLog, cFilAnt, nDiasMxF, dDataBase}
			lRet     := U_XESTMRP(aParmMRP,@aPerg711)

			// -> Valida os produtos das solicitações de compras geradas com o cadastro de produtos x fornecedores
			If lRet

				cAuxLog:="MRP | " + ': Validando parametros da industria...'
				ConOut(cAuxLog)
				oEventLog:SetAddInfo(cAuxLog,"")

				// -> Verifica se os dados da filial 'indústria' estão ok.
				If (len(aParEmpFil) < 2 .or. empty(aParEmpFil[1]) .or. empty(aParEmpFil[2]))
					cParEmpF := GetMV("MV_XFILIND")
					cAuxLog  := "MRP | " + "Parametro MV_XFILIND [" + trim(cParEmpF) + "] incorreto. Esperado no formato EE;FFFFFFFFF (EE - Empresa, FFFFFFFFF - Unidade)"
					lRet     := .F.
					ConOut(cAuxLog)
					oEventLog:SetAddInfo(cAuxLog,"")
				Else
					// -> Captura o CNPJ da filial da indústria
					cAux:=cEmpAnt+cFilAnt
					SM0->(DbSetOrder(1))
					If !SM0->(DbSeek(aParEmpFil[1]+aParEmpFil[2]))
						cAuxLog  := "MRP | " + ": Empresa e filial nao encontrado no cadastro de empresas [M0_CODIGO = " + aParEmpFil[1] + " / M0_CODFIL = " + aParEmpFil[2] + "]"
						lRet     := .F.
						ConOut(cAuxLog)
						oEventLog:SetAddInfo(cAuxLog,"")
					Else
						aadd(aParEmpFil,SM0->M0_CGC)
						cAuxLog:="MRP | " + 'Ok.'
						ConOut(cAuxLog)
						oEventLog:SetAddInfo(cAuxLog,"")
					EndIf
					// -> Reposiciona na filial atual
					SM0->(DbSetOrder(1))
					SM0->(DbSeek(cAux))
				EndIf
			Else
				cAuxLog:="MRP | " + 'Erro.'
				ConOut(cAuxLog)
				oEventLog:SetAddInfo(cAuxLog,"")
			EndIf

			// -> Posiciona no fornecedor da indústria
			If lRet
				DbSelectArea("SA2")
				SA2->(DbSetOrder(3))
				SA2->(DbSeek(xFilial("SA2")+aParEmpFil[3]))
				If !SA2->(Found())
					cAuxLog:="MRP | " + ": Fornecedor 'industria' nao encontrado para o CNPJ " + aParEmpFil[3] + " na tabela SA2..."
					lRet   :=.F.
					ConOut(cAuxLog)
					oEventLog:SetAddInfo(cAuxLog,"")
				Else
					cFonLojInd:=SA2->A2_COD+SA2->A2_LOJA
				EndIf
			EndIf

			// -> Valida os produtos das solicitações de compras geradas com o cadastro de produtos x fornecedores
			If lRet

				// -> Conforme chamado 3597482, que trata o problema de performance, não será mais gerado as SCs e OPs e a necessidade
				//    será gravada em tabela temporária
				cAuxLog:="MRP | " + ': Processando demandas calculadas...'
				ConOut(cAuxLog)
				oEventLog:SetAddInfo(cAuxLog,"")

				BEGINSQL Alias cAliTmp3
				SELECT CZJ.CZJ_PROD, 
				   	SB1.B1_DESC,
				   	SB1.B1_XDIAES,
				   	SB1.B1_GRUPO,
				   	SB1.B1_GRUPCOM,				
				   	CZK.CZK_PERMRP, 
				   	CZK.CZK_QTNECE,
					CZK.CZK_QTSLES,   
					CZK.CZK_QTENTR,   
					CZK.CZK_QTSAID,   
					CZK.CZK_QTSEST,   
				   	CZI.CZI_NRRGAL,                
				   	CZI.CZI_DTOG, 
				   	CZI.CZI_QUANT   
				FROM %Table:CZJ% CZJ JOIN %Table:CZK% CZK ON CZK.%NotDel% AND
					CZK.CZK_FILIAL = %xFilial:CZK%  AND
					CZK.CZK_RGCZJ  = CZJ.R_E_C_N_O_  
				JOIN %Table:CZI% CZI ON CZI.%NotDel% AND
					CZI.CZI_FILIAL = %xFilial:CZI% AND
					CZI.CZI_NRMRP  = CZJ.CZJ_NRMRP AND
					CZI.CZI_ALIAS  = 'PAR'
				JOIN %Table:SB1% SB1 ON SB1.%NotDel% AND
					SB1.B1_FILIAL = %xFilial:SB1%  AND
					SB1.B1_COD    = CZJ.CZJ_PROD
				WHERE CZJ.%NotDel% AND
					CZJ.CZJ_FILIAL = %xFilial:CZJ% AND
					NOT EXISTS (SELECT 1 FROM %Table:SG1% SG1 
								WHERE SG1.%NotDel%                  AND 
									  SG1.G1_FILIAL = %xFilial:SG1% AND 
					                  SG1.G1_COD    = CZJ.CZJ_PROD)
				ORDER BY CZJ.CZJ_NRLV, CZJ.CZJ_FILIAL, CZJ.CZJ_PROD, CZK.CZK_PERMRP                 
				ENDSQL

				If (cAliTmp3)->(Eof())
					lRet:=.F.
					cAuxLog:="MRP | " + ': Nao ha necessidades de compras para o período...'
					ConOut(cAuxLog)
					oEventLog:SetAddInfo(cAuxLog,"")
				EndIf

				// -> Atualiza tabela de preço com os dados da indístria
				If lRet .and. lAtuind 

					cAuxLog:="MRP | " + ": Atualizando tabelas de preco da industria..."
					ConOut(cAuxLog)
					oEventLog:SetAddInfo(cAuxLog,"")

					cProdAnt:=""
					(cAliTmp3)->(DbGoTop())
					While !(cAliTmp3)->(Eof())

						// -> Variável utiliza em u_xSB1SC1
						aHeader:={{,"C1_PRODUTO"       }}
						aCols  :={{(cAliTmp3)->CZJ_PROD}}
						n      :=1

						// -> Executa o processo de alteração de preços por produto
						If cProdAnt != (cAliTmp3)->CZJ_PROD
							// -> Busca dados do produto x fornecedor
							If u_xSB1SC1("C1_PRODUTO", "F")
								// -> Verifica apenas se o fornecedor é 'industria'
								If cFonLojInd == SA5->A5_FORNECE+SA5->A5_LOJA
									Aadd(aDadosSA5,{SA5->A5_CODPRF,SA5->A5_XTPCUNF,SA5->A5_XCVUNF, SA5->A5_FORNECE, SA5->A5_LOJA,cEmpAnt,cFilAnt,SA5->A5_PRODUTO,dDataBase,Separa(GetMV("MV_XFILIND"),";"),SM0->M0_CGC})
								EndiF
							Else
								lRet   :=.T.
								If aScan(aErroSA5,(cAliTmp3)->CZJ_PROD+"FOUNDSA5") <= 0
									cAuxLog:="MRP | " + 'Produto nao encontrado no cadastro de produtos x fornecedor.[B1_COD='+(cAliTmp3)->CZJ_PROD+']'
									oEventLog:SetAddInfo(cAuxLog,"")
									ConOut(cAuxLog)
									Aadd(aErroSA5,(cAliTmp3)->CZJ_PROD+"FOUNDSA5")
								EndIf
							EndIf
							cProdAnt := (cAliTmp3)->CZJ_PROD
						EndIf

						(cAliTmp3)->(DbSkip())

					EndDo

					//#TB20191129 Thiago Berna - Ajuste para receber retorno antes de encerrar a thread.
					//aErroProc:=StartJob("U_EST100TB", GetEnvServer(), .T.,aDadosSA5)
					StartJob("U_EST100TB", GetEnvServer(), .T.,aDadosSA5,cThdId01)
					GetGlbVars(cThdId01,aErroProc)
					ClearGlbValue(cThdId01)

				EndIf

				// -> Verifica se deu erro
				lRet:=IIF(Len(aErroProc)>0,IIF(aErroProc[01],.F.,.T.),.T.)
				If lRet
					cAuxLog:="MRP | " + 'Ok.'
					oEventLog:SetAddInfo(cAuxLog,"")
					ConOut(cAuxLog)
				EndIf

				lErro:=IIF(lRet,.F.,.T.)

				BEGIN TRANSACTION

					// -> Grava necessidades calculadas
					If lRet

						cAuxLog:="MRP | " + ": Gravando necessidades..."
						ConOut(cAuxLog)
						oEventLog:SetAddInfo(cAuxLog,"")

						(cAliTmp3)->(DbGoTop())
						DbSelectArea("Z25")
						Z25->(DbSetorder(1))

						aDatasMRP := GetMRPPer((cAliTmp3)->CZI_NRRGAL,StoD((cAliTmp3)->CZI_DTOG),(cAliTmp3)->CZI_QUANT,aPerg711)
						cZ25GRPCOM:= ""
						cZ25GRPPRO:= ""
						nZ25XDIAES:= 0
						cZ25CODFOR:= ""
						cZ25CODLOJ:= ""
						cZ25CODTAB:= ""
						nZ25VALOR := 0
						cZ25CC    := ""
						cZ25OP    := ""
						cZ25TES   := ""
						lFound    := .T.
						lFoundInd := .F.
						lErro     := .F.
						aErroProc := {lErro,{}}

						While !(cAliTmp3)->(Eof())

							dDataNec := aDatasMRP[Val((cAliTmp3)->CZK_PERMRP)]
							lFound   :=.T.
							lFoundInd:=.F.

							// -> Verifica se existe a necessidade para a data e produto e, caso exista apenas soma a quantidade
							If !Z25->(DbSeek(cFilialZ25+Dtos(dDataBase)+DtoS(dDataNec)+(cAliTmp3)->CZJ_PROD))

								// Variável utiliza em u_xSB1SC1
								aHeader   :={{,"C1_PRODUTO"       }}
								aCols     :={{(cAliTmp3)->CZJ_PROD}}
								n    	  :=1
								cZ25GRPCOM:=(cAliTmp3)->B1_GRUPCOM
								cZ25GRPPRO:=(cAliTmp3)->B1_GRUPO
								nZ25XDIAES:=(cAliTmp3)->B1_XDIAES

								// -> Verifica grupo de compra e comprador
								If Empty(cZ25GRPCOM)
									// -> Verifica o grupo de compras e comprador
									SAJ->(DbSetOrder(1))
									If !SAJ->(MsSeek(cFilialSAJ+cZ25GRPCOM))
										lFound       :=.F.
										aErroProc[01]:=.T.
										If aScan(aErroSB1,(cAliTmp3)->CZJ_PROD+"FOUNDSAJ") <= 0
											cAuxLog:="MRP | " + 'Grupo de compras nao cadastrado. [B1_GRUPCOM='+cZ25GRPCOM+', B1_COD='+(cAliTmp3)->CZJ_PROD+']'
											ConOut(cAuxLog)
											Aadd(aErroProc[02],cAuxLog)
											Aadd(aErroSB1,(cAliTmp3)->CZJ_PROD+"FOUNDSAJ")
										EndIf
									Else
										If Empty(SAJ->AJ_USER)
											lFound       :=.F.
											aErroProc[01]:=.T.
											If aScan(aErroSB1,(cAliTmp3)->CZJ_PROD+"USERSAJ") <= 0
												cAuxLog:="MRP | " + 'Sem comprador para o grupo de compras. [AJ_GRCOM=' + SB1->B1_GRUPCOM + ' e AJ_USER = Vazio] '
												ConOut(cAuxLog)
												Aadd(aErroProc[02],cAuxLog)
												aADD(aErroSB1,(cAliTmp3)->CZJ_PROD+"USERSAJ")
											EndIf
										EndIf
									EndIf
								EndIf

								// -> Verifica se existe no cadastro de produtos x fornecedor
								If !u_xSB1SC1("C1_PRODUTO", "F")
									lFound       :=.F.
									aErroProc[01]:=.T.
									If aScan(aErroSA5,(cAliTmp3)->CZJ_PROD+"FOUNDSA5") <= 0
										cAuxLog:="MRP | " + 'Produto nao encontrado no cadastro de produtos x fornecedor.[B1_COD='+(cAliTmp3)->CZJ_PROD+']'
										ConOut(cAuxLog)
										Aadd(aErroProc[02],cAuxLog)
										Aadd(aErroSA5,(cAliTmp3)->CZJ_PROD+"FOUNDSA5")
									EndIf
									(cAliTmp3)->(DbSkip())
									Loop
								Else
									cZ25CODFOR:=SA5->A5_FORNECE
									cZ25CODLOJ:=SA5->A5_LOJA
									cZ25CODTAB:=SA5->A5_CODTAB
									nZ25VALOR :=u_xSB1SC1("C1_VUNIT"  , "G")
									cZ25CC    :=u_xSB1SC1("C1_CC"     , "G")
									cZ25OP    :=SA5->A5_XOPER

									// -> Processar somente os produtos que estão no ressuprimneto
									If SA5->A5_XRESSUP == "N"
										lFound       :=.F.
										aErroProc[01]:=.F.
										If aScan(aErroSB1,(cAliTmp3)->CZJ_PROD+"A5_XRESSUP") <= 0
											cAuxLog:="MRP | " + 'Nao havera ressuprimento do Produto [B1_COD= '+(cAliTmp3)->CZJ_PROD+' e A5_XRESSUP=N]'
											ConOut(cAuxLog)
											Aadd(aErroProc[02],cAuxLog)
											Aadd(aErroSB1,(cAliTmp3)->CZJ_PROD+"A5_XRESSUP")
										EndIf
										(cAliTmp3)->(DbSkip())
										Loop
									Endif

									// -> Posiciona no cadastro de produto
									SB1->(DbSetOrder(1))
									If !SB1->(MsSeek(cFilialSB1+SA5->A5_PRODUTO))
										lFound       :=.F.
										aErroProc[01]:=.T.
										If aScan(aErroSB1,SA5->A5_PRODUTO+"FOUNDSB1") <= 0
											cAuxLog:="MRP | " + 'Produto nao encontrado na tabela SB1.[B1_COD='+(cAliTmp3)->CZJ_PROD+']'
											ConOut(cAuxLog)
											Aadd(aErroProc[02],cAuxLog)
											Aadd(aErroSB1,SA5->A5_PRODUTO+"FOUNDSB1")
										EndIf
										(cAliTmp3)->(DbSkip())
										Loop
									EndIf
								EndIf

								// -> Verifica dados do fornecedor, se o produto foi encontrado no cadastro de produtos x fornecedor
								If lFound
									If Empty(cZ25CODFOR) .or. Empty(cZ25CODLOJ)
										lFound       :=.F.
										aErroProc[01]:=.T.
										If aScan(aErroSA5,(cAliTmp3)->CZJ_PROD+"SA5SA2") <= 0
											cAuxLog:="MRP | " + 'Sem codigo do fornecedor e loja para o produto x fornecedor. [B1_COD='+(cAliTmp3)->CZJ_PROD+']'
											ConOut(cAuxLog)
											Aadd(aErroProc[02],cAuxLog)
											Aadd(aErroSA5,(cAliTmp3)->CZJ_PROD+"SA5SA2")
										EndIf
									Else
										// -> Verifica se o Fornecedor é relacionado a indústria e valida o cadastro do produto na industria
										SA2->(DbSetOrder(1))
										If !SA2->(MsSeek(cFilialSA2+cZ25CODFOR+cZ25CODLOJ))
											lFound       :=.F.
											aErroProc[01]:=.T.
											If aScan(aErroSA5,(cAliTmp3)->CZJ_PROD+"SA5SA2") <= 0
												cAuxLog:="MRP | " + 'O fornecedor informado no cadastro de produtos x fornecedor nao foi encontrado na tabela SA2. [A5_FORNECE = '+SA5->A5_FORNECE+" / A5_LOJA = "+ SA5->A5_LOJA+"]"
												ConOut(cAuxLog)
												Aadd(aErroProc[02],cAuxLog)
												Aadd(aErroSA5,(cAliTmp3)->CZJ_PROD+"SA5SA2")
											EndIf
										Else
											// -> Verifica operação fiscal
											If Empty(cZ25OP)
												lFound       :=.F.
												aErroProc[01]:=.T.
												If aScan(aErroSA5,(cAliTmp3)->CZJ_PROD+"SA5SF4") <= 0
													cAuxLog:="MRP | " + "Sem informacao da operacao fiscal no cadastro de Produto x Fornecedor [A5_FORNECE = " + SA5->A5_FORNECE + " /  A5_LOJA = " + SA5->A5_LOJA + " / A5_PRODUTO = " + SA5->A5_PRODUTO + "]"
													ConOut(cAuxLog)
													Aadd(aErroProc[02],cAuxLog)
													Aadd(aErroSA5,(cAliTmp3)->CZJ_PROD+"SA5SF4")
												EndIf
											Else
												cZ25TES:=MaTESInt(1, SA5->A5_XOPER, SA2->A2_COD, SA2->A2_LOJA, "F", SA5->A5_PRODUTO)
												SF4->(dbSetOrder(1))
												If !SF4->(MsSeek(cFilialSF4+cZ25TES))
													lFound       :=.F.
													aErroProc[01]:=.T.
													If aScan(aErroSA5,(cAliTmp3)->CZJ_PROD+"SA5SF4") <= 0
														cAuxLog:="MRP | " + "TES nao encontrada para a operacao fiscal " + SA5->A5_XOPER + " informada no cadastro de Produtos x Fornecedor [A5_FORNECE = " + SA2->A2_COD + " /  A5_LOJA = " + SA2->A2_LOJA + " / A5_PRODUTO = " + SA5->A5_PRODUTO + "]"
														ConOut(cAuxLog)
														Aadd(aErroProc[02],cAuxLog)
														Aadd(aErroSA5,(cAliTmp3)->CZJ_PROD+"SA5SF4")
													EndIf
												Else
													If SF4->F4_DUPLIC = "S" .and. Empty(SA2->A2_COND)
														lFound       :=.F.
														aErroProc[01]:=.T.
														If aScan(aErroSA2,SA2->A2_COD+SA2->A2_LOJA+"CONDPGTO") <= 0
															cAuxLog:="MRP | " + "Condicao de pagamento invalida no cadastro do fornecedor [A5_FORNECE = " + SA2->A2_COD + " /  A5_LOJA = " + SA2->A2_LOJA + "]"
															ConOut(cAuxLog)
															Aadd(aErroProc[02],cAuxLog)
															Aadd(aErroSA2,SA2->A2_COD+SA2->A2_LOJA+"CONDPGTO")
														EndIf
													Else
														// -> Verifica se é indústria
														If AllTrim(SA2->A2_CGC) == AllTrim(aParEmpFil) .and. Alltrim(aParEmpFil) <> ""
															cQuery:="SELECT B1_COD "
															cQuery+="FROM SB1"+aParEmpFil[1]+" SB1                         "
															cQuery+="WHERE SB1.B1_FILIAL   = '" + aParEmpFil[2]   + "' AND "
															cQuery+="      SB1.B1_COD      = '" + SA5->A5_CODPRF  + "'     "
															cQuery+="      D_E_L_E_T_  <> '*'                              "
															dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTmp2,.T.,.T.)
															(cAliTmp2)->(dbGoTop())
															lFoundInd:=.F.
															While !(cAliTmp2)->(Eof())
																lFoundInd:=.T.
																Exit
																(cAliTmp2)->(DbSkip())
															EndDo
															(cAliTmp2)->(DbCloseArea())

															If !lFoundInd
																lFound       :=.F.
																aErroProc[01]:=.T.
																If aScan(aErroSB1,SA5->A5_CODPRF+"NOMRP")
																	cAuxLog:="MRP | " + 'Produto nao cadastrado na industria. [A5_PRODUTO = ' + SA5->A5_CODPRF + ']'
																	ConOut(cAuxLog)
																	Aadd(aErroProc[02],cAuxLog)
																	Aadd(aErroSB1,SA5->A5_CODPRF+"NOMRP")
																EndIf
															EndIf
														EndIf
													EndIf
												EndIf
											Endif
										EndIf
									EndIf

									// -> Verifica fator de conversão no fornecedor
									If SA5->A5_XCVUNF <= 0
										lFound       :=.F.
										aErroProc[01]:=.T.
										If aScan(aErroSA5,(cAliTmp3)->CZJ_PROD+"FATOR") <= 0
											cAuxLog:="MRP | " + "Sem fator de conversao no cadastro de produtos x fornecedor. [B1_COD="+(cAliTmp3)->CZJ_PROD+", A5_FORNECE="+SA2->A2_COD+", A5_LOJA="+SA2->A2_LOJA+" e A5_XCVUNF <= 0]"
											ConOut(cAuxLog)
											Aadd(aErroProc[02],cAuxLog)
											Aadd(aErroSA5,(cAliTmp3)->CZJ_PROD+"FATOR")
										EndIf
									EndIf

									// -> Verifica tipo do fator de conversão no fornecedor
									If Empty(SA5->A5_XTPCUNF)
										lFound       :=.F.
										aErroProc[01]:=.T.
										If aScan(aErroSA5,(cAliTmp3)->CZJ_PROD+"TIPOFATOR")	<= 0
											cAuxLog:="MRP | " + 'Sem tipo do fator de conversao no cadastro de produtos x fornecedor. [B1_COD='+(cAliTmp3)->CZJ_PROD+', A5_FORNECE='+SA2->A2_COD+', A5_LOJA='+SA2->A2_LOJA+' e A5_XTPCUNF = Vazio]'
											ConOut(cAuxLog)
											Aadd(aErroProc[02],cAuxLog)
											Aad(aErroSA5,(cAliTmp3)->CZJ_PROD+"TIPOFATOR")
										EndIf
									EndIf

									// -> Verifica operação fiscal no cadastro de produtos x fornecedor
									If Empty(SA5->A5_XOPER)
										lFound       :=.F.
										aErroProc[01]:=.T.
										If aScan(aErroSA5,(cAliTmp3)->CZJ_PROD+"OPERACAO") <= 0
											cAuxLog:="MRP | " + 'Sem operacao fiscal no cadastro de produtos x fornecedor. [B1_COD='+(cAliTmp3)->CZJ_PROD+', A5_FORNECE='+SA2->A2_COD+', A5_LOJA='+SA2->A2_LOJA+' e A5_XOPER = Vazio]'
											ConOut(cAuxLog)
											Aadd(aErroProc[02],cAuxLog)
											Aadd(aErroSA5,(cAliTmp3)->CZJ_PROD+"OPERACAO")
										EndIf
									EndIf

									// -> Verifica tabela de preço (AIA / AIB)
									If Empty(cZ25CODTAB) .or. nZ25VALOR <= 0
										lFound       :=.F.
										aErroProc[01]:=.T.
										If aScan(aErroSA5,(cAliTmp3)->CZJ_PROD+"TABPRECO") <= 0
											cAuxLog:="MRP | " + 'Sem tabela de preco no cadastro de produtos x fornecedor ou sem preco de compra. [B1_COD='+(cAliTmp3)->CZJ_PROD+', A5_FORNECE='+SA2->A2_COD+', A5_LOJA='+SA2->A2_LOJA+' e A5_CODTAB = Vazio]'
											ConOut(cAuxLog)
											Aadd(aErroProc[02],cAuxLog)
											Aadd(aErroSA5,(cAliTmp3)->CZJ_PROD+"TABPRECO")
										EndIf
									EndIf

									// -> Valida calendário de entrega
									Z22->(DbSetOrder(1))
									If !Z22->(MsSeek(cFilialZ22+cFilAnt+SA2->A2_COD+SA2->A2_LOJA+cZ25GRPCOM))
										lFound       :=.F.
										aErroProc[01]:=.T.
										If aScan(aErroSA5,(cAliTmp3)->CZJ_PROD+"CALENDARIO") <= 0
											cAuxLog:="MRP | " + 'Nao encotrado no calendario de entrega o grupo de compras relacionado ao produto. [A2_COD='+SA2->A2_COD+', A2_LOAJ='+SA2->A2_LOJA+' e B1_GRUPCOM = ' + cZ25GRPCOM + ']'
											ConOut(cAuxLog)
											Aadd(aErroProc[02],cAuxLog)
											Aadd(aErroSA5,(cAliTmp3)->CZJ_PROD+"CALENDARIO")
										EndIf
									Else
										// -> Verifica se existe data para próxima entrega e entrega anterior
										If Empty(Z22->Z22_DTNXEN) .or. Empty(Z22->Z22_DTULEN)
											lFound       :=.F.
											aErroProc[01]:=.T.
											If aScan(aErroSA5,(cAliTmp3)->CZJ_PROD+"DATAENTREGA") <= 0
												cAuxLog:="MRP | " + "Data da proxima e ultima entrega nao encontrada da para a unidade, fornecedor e grupo de compras. [Z22_CODUN="+cFilAnt+", Z22_FON="+SA2->A2_COD+", Z22_LOJA="+SA2->A2_LOJA+" e Z22_GRUPO="+cZ25GRPCOM+"]"
												ConOut(cAuxLog)
												Aadd(aErroProc[02],cAuxLog)
												Aadd(aErroSA5,(cAliTmp3)->CZJ_PROD+"DATAENTREGA")
											EndIf
										EndIf
									EndIf
								EndIf

								// -> Grava as necessidades calculadas, se não ocorreu nenhum erro
								If lFound
									If RecLock("Z25",.T.)
										Z25->Z25_FILIAL := cFilialZ25
										Z25->Z25_DATA   := dDataBase
										Z25->Z25_DTNECE := dDataNec
										Z25->Z25_PRODUT := (cAliTmp3)->CZJ_PROD
										Z25->Z25_DESCPR := (cAliTmp3)->B1_DESC
										Z25->Z25_GRPCOM := (cAliTmp3)->B1_GRUPCOM
										Z25->Z25_GRPPRO := (cAliTmp3)->B1_GRUPO
										Z25->Z25_XDIAES := (cAliTmp3)->B1_XDIAES
										Z25->Z25_CODFOR := SA2->A2_COD
										Z25->Z25_CODLOJ := SA2->A2_LOJA
										Z25->Z25_DESCFO := SA2->A2_NOME
										Z25->Z25_QUANT  := (cAliTmp3)->CZK_QTNECE
										Z25->Z25_XSLES	:= (cAliTmp3)->CZK_QTSLES
										Z25->Z25_XENTR	:= (cAliTmp3)->CZK_QTENTR
										Z25->Z25_XSAIDA	:= (cAliTmp3)->CZK_QTSAID
										Z25->Z25_XSEST	:= (cAliTmp3)->CZK_QTSEST
										Z25->Z25_CODTAB := cZ25CODTAB
										Z25->Z25_VALOR  := nZ25VALOR
										Z25->Z25_CC     := cZ25CC
										Z25->Z25_OP     := cZ25OP
										Z25->Z25_TES    := cZ25TES
										Z25->Z25_ORIGEM	:= '1'
										Z25->(MsUnlock())
									Else
										cAuxLog:="MRP | " + "Erro na inclusao da necessidade [Z25_FILIAL="+cFilialZ25+", Z25_DATA="+DtoC(dDataBase)+", Z25_PRODUTO="+(cAliTmp3)->CZJ_PROD+"]."
										lErro        :=.T.
										aErroProc[01]:=lErro
										AADD(aErroProc[02],cAuxLog)
										ConOut(cAuxLog)
									EndIf
								EndIf
							Else
								If RecLock("Z25",.F.)
									Z25->Z25_QUANT 	+= (cAliTmp3)->CZK_QTNECE
									Z25->Z25_XSLES	+= (cAliTmp3)->CZK_QTSLES
									Z25->Z25_XENTR	+= (cAliTmp3)->CZK_QTENTR
									Z25->Z25_XSAIDA	+= (cAliTmp3)->CZK_QTSAID
									Z25->Z25_XSEST	+= (cAliTmp3)->CZK_QTSEST
									Z25->(MsUnlock())
								Else
									cAuxLog:="MRP | " + "Erro na alteracao da necessidade [Z25_FILIAL="+cFilialZ25+", Z25_DATA="+DtoC(dDataBase)+", Z25_PRODUTO="+(cAliTmp3)->CZJ_PROD+"]."
									lErro        :=.T.
									aErroProc[01]:=lErro
									Aadd(aErroProc[02],cAuxLog)
									ConOut(cAuxLog)
								EndIf
							EndIf

							If lErro
								Exit
							EndIf

							(cAliTmp3)->(dbSkip())

						EndDo

						(cAliTmp3)->(DbCloseArea())

						// -> Verifica se houve problemas no cadastro e, se houver, aborta o processo
						If lErro
							DISARMTRANSACTION()
						EndIf

					EndIf

				END TRANSACTION

				// -> Verifica se houve problemas no cadastro e, se houver, grava dados no log
				If Len(aErroProc[02]) > 0
					cAuxLog:="MRP | " + ': Gravando log...'
					ConOut(cAuxLog)
					oEventLog:SetAddInfo(cAuxLog,"")
					For nk:=1 to Len(aErroProc[02])
						oEventLog:SetAddInfo(aErroProc[02,nk],"")
					Next nk

					cAuxLog:="MRP | " + 'Ok.'
					ConOut(cAuxLog)
					oEventLog:SetAddInfo(cAuxLog,"")

					oEventLog:SetAddInfo(cAuxLog,"")
					cAuxLog  :="MRP | " + "Corrija os erros de cadastro para que o processo continue."
					oEventLog:SetAddInfo(cAuxLog,"")
					lRet:=IIF(aErroProc[01],.F.,.T.)
				Else
					cAuxLog:="MRP | " + 'Ok.'
					ConOut(cAuxLog)
					oEventLog:SetAddInfo(cAuxLog,"")
				EndIf

			Else

				cAuxLog  :="MRP | " + "Erro."
				oEventLog:SetAddInfo(cAuxLog,"")
				lRet     :=.F.

			EndIf

			cAuxF:=cFilAnt
			cAuxE:=cEmpAnt
			aArea:=GetArea()

			// -> Gera demandas para indústria
			If lRet .and. lAtuind

				cAuxLog:="MRP | " + ': Executando calculo da demanda para industria...'
				ConOut(cAuxLog)
				oEventLog:SetAddInfo(cAuxLog,"")

				_xaEventLog:={}
				cParEmpF   := trim(aParEmpFil[1])
				cParFilF   := trim(aParEmpFil[2])
				aParmMRP   := {cParEmpF, cParFilF, cEmpAnt+"0", nDiasMx, oEventLog, cFilAnt, nDiasMxF, dDataBase}

				TRYEXCEPTION

					//#TB20191129 Thiago Berna - Ajuste para encerrar a thread.
					//_xaEventLog:=startJob("U_AEST102", GetEnvServer(), .T., aParmMRP)
					startJob("U_AEST102", GetEnvServer(), .T., aParmMRP, cThdId02)
					GetGlbVars(cThdId02,_xaEventLog)
					ClearGlbValue(cThdId02)

				CATCHEXCEPTION USING oError

					lRet   := .F.
					cAuxLog:="MRP | " + procname()+"("+cValToChar(procline())+")" + oError:Description
					Conout(cAuxLog + Chr(13) + Chr(10) + 'Detalhamento :'+varinfo('oError',oError))
					oEventLog:broken("Na execucao.", cAuxLog , .T.)

				ENDEXCEPTION 

				// -> Grava Log do processo de demanda da indústria
				lRet:=_xaEventLog[01]
				For nx:=1 to Len(_xaEventLog[02])
					oEventLog:SetAddInfo(_xaEventLog[02][nx],"")
				Next nx

			ElseIf lAtuind

				cAuxLog:="MRP | " + 'Erro.'
				ConOut(cAuxLog)
				oEventLog:SetAddInfo(cAuxLog,"")

			Endif

			RestArea(aArea)
			SM0->(dbSetOrder(1))
			SM0->(dbSeek(cAuxE+cAuxF))
			cEmpAnt := SM0->M0_CODIGO
			cFilAnt := SM0->M0_CODFIL

			// -> Se ocorreu tudo ok, libera para o passo seguinte
			If lRet
				oEventLog:SetStep("02")
			EndIf

		Else

			cAuxLog:="MRP | " + 'Ok.'
			ConOut(cAuxLog)
			oEventLog:SetAddInfo(cAuxLog,"")

		EndIf

	Else

		cAuxLog:="MRP | " + 'Ok. Ja existem pedidos de venda firmados para esta data.'
		ConOut(cAuxLog)
		oEventLog:SetAddInfo(cAuxLog,"")

	EndIf

return(lRet)




/*-----------------+---------------------------------------------------------+
!Nome              ! XESTMRP - Cliente: Madero                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Execução do processo de MRP                             !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 22/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function XESTMRP(paramixb,aPerg711)
Local cErrLinha := ""
Local oError
Local cCapital
Local PARAMIXB1 := .T.          //-- .T. se a rotina roda em batch, senão .F.
Local PARAMIXB2 := {}
Local cUndMad   := paramixb[3]
Local nxDiasEMx := paramixb[4]
Local oEventLog := paramixb[5]
Local aMRP      := GetArea()
Local cAuxLog   := ""
Local lErro     := .F.
Private lMsErroAuto := .F.

	cAuxLog:="MRP | " + ': Atualizando parametros do processo.....' 
	ConOut(cAuxLog)                              
	oEventLog:SetAddInfo(cAuxLog,"")

    aAdd(PARAMIXB2, 1)                            //-- Tipo de período 1=Diário; 2=Semanal; 3=Quinzenal; 4=Mensal; 5=Trimestral; 6=Semestral
    aAdd(PARAMIXB2, nxDiasEMx)                    //-- Quantidade de períodos
    aAdd(PARAMIXB2, .F.)                          //-- Considera Pedidos em Carteira
    aAdd(PARAMIXB2, {})                           //-- Array contendo Tipos de produtos a serem considerados (se Nil, assume padrão)
    aAdd(PARAMIXB2, {})                           //-- Array contendo Grupos de produtos a serem considerados (se Nil, assume padrão)
    aAdd(PARAMIXB2, .F.)                          //-- Gera/Nao Gera OPs e SCs depois do calculo da necessidade.
    aAdd(PARAMIXB2, .F.)                          //-- Indica se monta log do MRPaAdd(PARAMIXB2,"000001")
    aAdd(PARAMIXB2, Space(TamSx3("C2_NUM")[1]))   //-- numero inicial da op - conforme solicitado através do chamado 3034556
            
    // ****************************
    // * Monta a Tabela de Tipos  *
    // ****************************
    dbSelectArea("SX5")
    SX5->(dbSetOrder(1))
    SX5->(dbSeek(xFilial("SX5")+"ZC"))
	Do While (SX5->X5_FILIAL == xFilial("SX5")) .AND. (SX5->X5_TABELA == "ZC") .and. !SX5->(Eof())
        cCapital := OemToAnsi(Capital(X5Descri()))        
        AADD(PARAMIXB2[4],{.T.,SubStr(SX5->X5_chave,1,2)+" - "+cCapital})
        SX5->(dbSkip())
	EndDo
        
    // ****************************
    // * Monta a Tabela de Grupos *
    // ****************************
    dbSelectArea("SBM")
    SBM->(dbSetOrder(1))
    SBM->(dbSeek(xFilial("SBM")))
    AADD(PARAMIXB2[5],{.T.,Criavar("B1_GRUPO",.F.)+" - "+"Grupo em Branco"})
	Do While (SBM->BM_FILIAL == xFilial("SBM")) .AND. !SBM->(Eof())
        cCapital := OemToAnsi(Capital(SBM->BM_DESC))        
        AADD(PARAMIXB2[5],{.T.,SubStr(SBM->BM_GRUPO,1,4)+" - "+cCapital})
        SBM->(dbSkip())
	EndDo
    
    Pergunte("MTA712",.F.)
    u_zAtuPerg("MTA712", "MV_PAR04", 2)
    u_zAtuPerg("MTA712", "MV_PAR05", dDataBase)
    u_zAtuPerg("MTA712", "MV_PAR06", dDataBase + nxDiasEMx)
    u_zAtuPerg("MTA712", "MV_PAR08", "  ")
    u_zAtuPerg("MTA712", "MV_PAR09", "ZZ")
    u_zAtuPerg("MTA712", "MV_PAR10", 2)
    
    MV_PAR01 := 1  // Executa o MRP considerando a previsão de vendas
	MV_PAR02 := 1  // Gera SCs pela necessidade 
	MV_PAR03 := 1  // Gera OPs dos produtos intermediários por necessidade
	MV_PAR04 := 2  // Gera OPs e SCs utilizando o mesmo período (1 = Junto)
	MV_PAR05 := dDataBase // Data inicial da previsão de vendas 
	MV_PAR06 := dDataBase + nxDiasEMx  // Data final da previsão de vendas 
	MV_PAR07 := 2  // Incrementa OPs por número 
	MV_PAR08 := "  " // Armazém inicial 
	MV_PAR09 := "ZZ" // Armazém Final
	MV_PAR10 := 2  // Tipo da OP a ser gerada  (2 = Prevista)
	MV_PAR11 := 1  // Apaga ordens de produção previstas (1 = Sim)
	MV_PAR12 := 1  // Considera sábados e domingos(1 = Sim)
	MV_PAR13 := 1  // Considera OPs suspensas(1 = Sim) 
	MV_PAR14 := 1  // Considera OPs sacramentadas (1 = Sim)
	MV_PAR15 := 1  // Recalcula níveis das estruturas (1 = Sim)
	MV_PAR16 := 2  // Trata o produto intermediário normalmente (2 = Nao)
	MV_PAR17 := 2  // Não exclui pedidos de venda  (2 = Nao Subtrai)
	MV_PAR18 := 1  // Considera o saldo atual em estoque (1 = Saldo Atual) 
	MV_PAR19 := 1  // Se atingir o estoque máximo, considera a quantidade original(1 = Qtde Original)
	MV_PAR20 := 2  // Não considera saldo em poder de terceiros (2 = Ignora)
	MV_PAR21 := 2  // Não considera saldo de terceiros em nosso poder (2 = Ignora)
	MV_PAR22 := 2  // Não subtrai saldos rejeitados pelo CQ  (2 = Nao Subtrai Rej)
	MV_PAR23 := "         "   // Documento inicial 
	MV_PAR24 := "ZZZZZZZZZ"   // Documento Final
	MV_PAR25 := 2  //  Não subtrai saldos bloqueados por lote ("2" = Nao Subtrai )
	MV_PAR26 := 1  //  Considera estoque de segurança                        ( 1 = Sim )
	MV_PAR27 := 2  //  Não considera pedidos de vendas boleados por crédito  ( 2 = Não )
	MV_PAR28 := 2  //  Não resume dados                                      ( 2 = Não )
	MV_PAR29 := 2  //  Não detalha lotes vencidos                            ( 2 = Não )
	MV_PAR30 := 1  //  Pedidos de Venda  faturados ?                		 ( 2 = Nao Subtrai  )
	MV_PAR31 := 1  //  Considera Ponto de Pedido ?                           ( 1 = Sim )
	MV_PAR32 := 1  //  Gera base de dados com o cálculo da necessidade       ( 1 = Sim )
	MV_PAR33 := ""
	MV_PAR34 := ""
	MV_PAR35 := 1  // Exibe resultados em lista
	
	AADD(aPerg711,MV_PAR01)
	AADD(aPerg711,MV_PAR02)
	AADD(aPerg711,MV_PAR03)
	AADD(aPerg711,MV_PAR04)
	AADD(aPerg711,MV_PAR05)
	AADD(aPerg711,MV_PAR06)
	AADD(aPerg711,MV_PAR07)
	AADD(aPerg711,MV_PAR08)
	AADD(aPerg711,MV_PAR09)
	AADD(aPerg711,MV_PAR10)
	AADD(aPerg711,MV_PAR11)
	AADD(aPerg711,MV_PAR12)
	AADD(aPerg711,MV_PAR13)
	AADD(aPerg711,MV_PAR14)
	AADD(aPerg711,MV_PAR15)
	AADD(aPerg711,MV_PAR16)
	AADD(aPerg711,MV_PAR17)
	AADD(aPerg711,MV_PAR18)
	AADD(aPerg711,MV_PAR19)
	AADD(aPerg711,MV_PAR20)
	AADD(aPerg711,MV_PAR21)
	AADD(aPerg711,MV_PAR22)
	AADD(aPerg711,MV_PAR23)
	AADD(aPerg711,MV_PAR24)
	AADD(aPerg711,MV_PAR25)
	AADD(aPerg711,MV_PAR26)
	AADD(aPerg711,MV_PAR27)
	AADD(aPerg711,MV_PAR28)
	AADD(aPerg711,MV_PAR29)
	AADD(aPerg711,MV_PAR30)
	AADD(aPerg711,MV_PAR31)
	AADD(aPerg711,MV_PAR32)
	AADD(aPerg711,MV_PAR33)
	AADD(aPerg711,MV_PAR34)
	AADD(aPerg711,MV_PAR35)

	cAuxLog:="MRP | " + ': Executando MATA712...' 
	ConOut(cAuxLog)                              
	oEventLog:SetAddInfo(cAuxLog,"")
	
	TRYEXCEPTION

		MATA712(PARAMIXB1,PARAMIXB2)  
	
	CATCHEXCEPTION USING oError
	    lErro  :=.T.
		if valtype(oError) = 'O'
			cAuxLog:="MRP | " + procname()+"("+cValToChar(procline())+")" + oError:Description
			Conout(cAuxLog)     
			oEventLog:SetAddInfo(cAuxLog,"")
		Else
			cAuxLog:="MRP | " + procname()+"("+cValToChar(procline())+")" 
			Conout(cAuxLog)     		
			oEventLog:SetAddInfo(cAuxLog,"")
		EndIf
	
	ENDEXCEPTION
	
	If lErro
		oEventLog:broken("Execucao da rotina MATA712.", cAuxLog , .T.)
	Else
		cAuxLog:=IIF(lErro,"MRP | " + "Erro.","MRP | " + "Ok.") 
		ConOut(cAuxLog)
		oEventLog:SetAddInfo(cAuxLog,"")
	Endif
		                              
	RestArea(aMRP)

Return(!lErro)

/*-----------------+---------------------------------------------------------+
!Nome              ! AESTFIR - Cliente: Madero                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Firma SCs                                               !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 22/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function xESTFIR(cUndMad, oEventLog, nDiasMxF)
Local cAliTmp0  := GetNextAlias()
Local cAuxLog   := ""
Local lErro     := .F.                     
Local cDtCalcI  := DtoS(dDataBase) // Data inicio firme
Local cDataEnt	 := "" // data entrega 
Local cQuery    := ""
Local cTipoPC	:= "" 
Local cDtNext	:= "" 
Local n9		:= 0 
Local n1 		:= 0 
Local nu        := 0
Local nCoutFirm := 0
Local aAuxLog   := {}
Local c25_FILIAL := "" 
Local d25_DATA   := ctod("  /  /  ") 
Local d25_DTNECE := ctod("  /  /  ") 
Local c25_PRODUT := "" 
Local c25_DESCPR := "" 
Local c25_GRPCOM := "" 
Local c25_GRPPRO := "" 
Local n25_XDIAES := 0 
Local c25_CODFOR := "" 
Local c25_CODLOJ := "" 
Local c25_DESCFO := "" 
Local n25_QUANT  := 0   
Local n25_XSLES	 := 0 
Local n25_XENTR	 := 0 
Local n25_XSAIDA := 0 
Local n25_XSEST	 := 0  
Local c25_CODTAB := "" 
Local n25_VALOR  := 0 
Local c25_OP     := "" 
Local c25_TES    := "" 
Local aCalendar  := {}

	// -> Verifica se o processo de MRP (passo 02) foi executado, caso contrário, retorna erro
	If AllTrim(oEventLog:GetStep()) <> "02"
		cAuxLog:="MRP | " + "Ok."
		ConOut(cAuxLog)                         
		oEventLog:SetAddInfo(cAuxLog,"")
		Return(.T.)
	EndIf
	
	// -> Verificando datas de entregas, conforme calendário
	aCalendar:=u_EST100C(cUndMad)

	// -> Firma as necessidades calculadas conforme calendário de entregas
	BEGIN TRANSACTION
		
		cMsgErr  :=""
		nCoutFirm:=0
		aAuxLog:={}
		For n1:=1 to Len(aCalendar)
	
			DbSelectArea("Z22")
			Z22->(DbGoTo(aCalendar[n1,6]))
		
			If Len(aCalendar[n1][9]) <= 0
			    lErro :=.T.	
				cMsgErr:="MRP | " + "Erro no calendario da filial " + Z22->Z22_CODUN + ", fornecedor/loja " + Z22->Z22_FORN+"/"+Z22->Z22_LOJA + " e grupo " + Z22->Z22_GRUPO + "."
				ConOut(cMsgErr)
				AADD(aAuxLog,cMsgErr)	    			
			EndIf

			// -> Atualiza dados das necessidades conforme calendário de entrega
			If !lErro
				
				// -> Atualiza necessidades
				For n9:= 2 to Len(aCalendar[n1][9])-1
					
					// -> Carrega variáveis
					cTipoPC := subs(aCalendar[n1][9][n9],9,1)                   // Tipo do pedido 
					
					//#TB20200320 Thiago Berna + Ajuste para corrigir a data de entrega
					//cDataEnt:= subs(aCalendar[n1][9][n9],1,8)                   // Data entrega (pedido)
					If Len(StrToKarr(alltrim(Z22->Z22_DIA),",")) > 1
						If n9 == 2 .And. SubStr(aCalendar[n1][9][n9+1],9) == 'F'
							cDataEnt:= subs(aCalendar[n1][9][n9+1],1,8)                   // Data entrega (pedido)
						Else
							cDataEnt:= subs(aCalendar[n1][9][n9],1,8)                   // Data entrega (pedido)
						EndIf
					Else
						cDataEnt:= DTOS(Z22->Z22_DTNXEN)
					EndIf
					
					//#20200319 Thiago Berna - Ajuste da data inicial
					//cDtCalcI:= dtos(stod(subs(aCalendar[n1][9][n9],1,8)) + 1)   // Data de inicio do cálculo da necessidade
					cDtCalcI:= dtos(stod(subs(aCalendar[n1][9][n9],1,8)))   // Data de inicio do cálculo da necessidade
					
					cDtNext := subs(aCalendar[n1][9][n9+1],1,8)                 // Data da próxima necessidade

					cQuery:="SELECT * "
					cQuery+="FROM " + RetSQLName("Z25") + " Z25 "
					cQuery+="WHERE Z25.Z25_FILIAL    = '" + xFilial("Z25")  + "' AND "   
					cQuery+="	   Z25.Z25_CODFOR    = '" + Z22->Z22_FORN   + "' AND "
					cQuery+="	   Z25.Z25_CODLOJ    = '" + Z22->Z22_LOJA   + "' AND "
					cQuery+="	   Z25.Z25_GRPCOM    = '" + Z22->Z22_GRUPO  + "' AND " 
					cQuery+="      Z25.Z25_DTNECE   >= '" + cDtCalcI        + "' AND " 
					cQuery+="      Z25.Z25_ORIGEM    IN  ('1')                   AND "
					cQuery+="      Z25.Z25_DTNECE   <= TO_CHAR(TO_DATE("+cDtNext+", 'RRRRMMDD') + Z25.Z25_XDIAES,'RRRRMMDD') AND " 
					cQuery+="      Z25.D_E_L_E_T_ <> '*'                                                                          "
					cQuery+="ORDER BY Z25_FILIAL, Z25_CODFOR, Z25_CODLOJ, Z25_GRPCOM, Z25_PRODUT                                  "
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTmp0,.T.,.T.)
	    			(cAliTmp0)->(dbGoTop())
	    		
					While !(cAliTmp0)->(eof())

						nCoutFirm:=nCoutFirm+1
							
						DbSelectArea("Z25")
	    				Z25->(DbGoTo((cAliTmp0)->(R_E_C_N_O_)))

						// -> Atualiza dados da demanda geradas pelo calendário
						If !Empty(Z25->Z25_DTENTR)
							c25_FILIAL 	:= Z25->Z25_FILIAL 
							d25_DATA 	:= Z25->Z25_DATA   
   							d25_DTNECE 	:= Z25->Z25_DTNECE
							c25_PRODUT 	:= Z25->Z25_PRODUT
   							c25_DESCPR 	:= Z25->Z25_DESCPR
							c25_GRPCOM 	:= Z25->Z25_GRPCOM
		            		c25_GRPPRO 	:= Z25->Z25_GRPPRO
	        		    	n25_XDIAES 	:= Z25->Z25_XDIAES
    	            		c25_CODFOR 	:= Z25->Z25_CODFOR
		                	c25_CODLOJ 	:= Z25->Z25_CODLOJ
    			        	c25_DESCFO 	:= Z25->Z25_DESCFO
            				n25_QUANT  	:= Z25->Z25_QUANT 
							n25_XSLES 	:= Z25->Z25_XSLES
							n25_XENTR 	:= Z25->Z25_XENTR
							n25_XSAIDA 	:= Z25->Z25_XSAIDA	
							n25_XSEST 	:= Z25->Z25_XSEST	
    	    		        c25_CODTAB 	:= Z25->Z25_CODTAB 
        	        		n25_VALOR 	:= Z25->Z25_VALOR  
		    	            c25_CC 		:= Z25->Z25_CC     
        			        c25_OP 		:= Z25->Z25_OP     
                			c25_TES 	:= Z25->Z25_TES    

							// -> Inclui nova demanda conforme calendário
							If RecLock("Z25",.T.)
								Z25->Z25_FILIAL := c25_FILIAL
	  							Z25->Z25_DATA   := d25_DATA
   								Z25->Z25_DTNECE := d25_DTNECE
			   					Z25->Z25_PRODUT := c25_PRODUT
   								Z25->Z25_DESCPR := c25_DESCPR
								Z25->Z25_GRPCOM := c25_GRPCOM
                				Z25->Z25_GRPPRO := c25_GRPPRO
		                		Z25->Z25_XDIAES := n25_XDIAES
        		        		Z25->Z25_CODFOR := c25_CODFOR
                				Z25->Z25_CODLOJ := c25_CODLOJ
	            				Z25->Z25_DESCFO := c25_DESCFO
			            		Z25->Z25_QUANT  := n25_QUANT 
								Z25->Z25_XSLES	:= n25_XSLES
								Z25->Z25_XENTR	:= n25_XENTR
								Z25->Z25_XSAIDA	:= n25_XSAIDA
								Z25->Z25_XSEST	:= n25_XSEST
        		        		Z25->Z25_CODTAB := c25_CODTAB
            					Z25->Z25_VALOR  := n25_VALOR
	            				Z25->Z25_CC     := c25_CC
			            		Z25->Z25_OP     := c25_OP
        			    		Z25->Z25_TES    := c25_TES
								Z25->Z25_ORIGEM	:= '2'
                				Z25->Z25_DTENTR	:= stod(cDataEnt)
								Z25->Z25_TIPOPC	:= cTipoPC  
	    						Z25->(MsUnlock())        			
							Else
            					lErro  :=.T.	
								cMsgErr:="MRP | " + "Erro na inclusao das necesidades pelo calendario: [Z25_ORIGEM = '2']."
								ConOut(cMsgErr)
								Aadd(aAuxLog,cMsgErr)	    			
								Exit
							Endif
						Else
							// -> Atualiza data de entrega	
							If RecLock("Z25",.F.)
			    				Z25->Z25_DTENTR:= SToD(cDataEnt)
								Z25->Z25_TIPOPC:= cTipoPC  
	    						Z25->(MsUnlock())			
							Else
                				lErro :=.T.	
								cMsgErr:="MRP | " + "Erro na alteracao das necesidades pelo calendario: [Z25_ORIGEM = '1']."
								ConOut(cMsgErr)
								Aadd(aAuxLog,cMsgErr)	    			
								Exit
							EndIf
						Endif
							
						(cAliTmp0)->(dbSkip())
		
					EndDo
	    				
					(cAliTmp0)->(DbCloseArea())				 
					
					// -> Se ocorreu erro, sai do processamento do calendário
					If lErro
						Exit
					EndIf
				
				Next n9
	    				
				cDataEnt := "" // Limpa data de entrega 
				cTipoPC	 := "" // Limpa tipo do Pedido 

				// -> Se ocorreu erro, sai do processamento do calendário
				If lErro
					Exit
				EndIf
			
			EndIf
		
		Next n1
	    
		// -> Se ocorreu erro, desarma transação
		If lErro
			DisarmTransaction()
			Break
		EndIf
		
	END TRANSACTION
	    
	// -> Grava dados no log
	cAuxLog:="MRP | " + ": Atualizando log..."
	oEventLog:SetAddInfo(cAuxLog,"")
	ConOut(cAuxLog)
	For nu:=1 to Len(aAuxLog)
		cAuxLog:=aAuxLog[nu] 
		oEventLog:SetAddInfo(cAuxLog,"")
	Next nu
	cAuxLog:="MRP | " + "Ok."
	oEventLog:SetAddInfo(cAuxLog,"")
	ConOut(cAuxLog)
		    
	If lErro
		cAuxLog:="MRP | " + "Erro." 
		oEventLog:SetAddInfo(cAuxLog,"")
		ConOut(cAuxLog)
	Else
		cAuxLog:="MRP | " + AllTrim(Str(nCoutFirm)) + " item(ns) firmado(s)." 		
		ConOut(cAuxLog)                              
		oEventLog:SetAddInfo(cAuxLog,"")
		cAuxLog:="MRP | " + "Ok." 
		ConOut(cAuxLog)                              
		oEventLog:SetAddInfo(cAuxLog,"")
		oEventLog:SetStep("03")
	EndIf

Return(!lErro)





//Função que atualiza o conteúdo de uma pergunta no X1_CNT01 / SXK / Profile
User Function zAtuPerg(cPergAux, cParAux, xConteud)
    Local aArea      := GetArea()
    Local nPosPar    := 14
    Local nLinEncont := 0
    Local aPergAux   := {}
    Default xConteud := ''
     
    //Se não tiver pergunta, ou não tiver ordem
	If Empty(cPergAux) .Or. Empty(cParAux)
        Return
	EndIf
     
    //Chama a pergunta em memória
    Pergunte(cPergAux, .F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)
     
    //Procura a posição do MV_PAR
    nLinEncont := aScan(aPergAux, {|x| Upper(Alltrim(x[nPosPar])) == Upper(cParAux) })
     
    //Se encontrou o parâmetro
	If nLinEncont > 0
        //Caracter
		If ValType(xConteud) == 'C'
            &(cParAux+" := '"+xConteud+"'")
         
        //Data
		ElseIf ValType(xConteud) == 'D'
            &(cParAux+" := sToD('"+dToS(xConteud)+"')")
             
        //Numérico ou Lógico
		ElseIf ValType(xConteud) == 'N' .Or. ValType(xConteud) == 'L'
            &(cParAux+" := "+cValToChar(xConteud))
         
		EndIf
         
        //Chama a rotina para salvar os parâmetros
        __SaveParam(cPergAux, aPergAux)
	EndIf
     
    RestArea(aArea)
Return


/*-----------------+---------------------------------------------------------+
!Nome              ! GetMRPPer                                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Retornr os perídos conforme cálculo do MRP (MATA712)    !
+------------------+---------------------------------------------------------+
!Autor             ! TOTVS SP - Chamado 3597482                              !
+------------------+---------------------------------------------------------!
!Data              ! 31/08/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function GetMRPPer(nTipo,dInicio,nPeriodos,aPerg711)
Local aRetorno  := {}
Local cForAno 	:= ""
Local nPosAno 	:= 0
Local nTamAno 	:= 0
Local i 	:= 0
Local nY2T	:= If(__SetCentury(),2,0)

	If __SetCentury()
		nPosAno := 1
		nTamAno := 4
		cForAno := "ddmmyyyy"
	Else
		nPosAno := 3
		nTamAno := 2
		cForAno := "ddmmyy"
	Endif

	//Monta a data de inicio de acordo com os parametros                   
	If (nTipo == 2)                         // Semanal
		While Dow(dInicio)!=2
			dInicio--
		EndDo
	ElseIf (nTipo == 3) .or. (nTipo == 4)   // Quinzenal ou Mensal
		dInicio:= CtoD("01/"+Substr(DtoS(dInicio),5,2)+Substr(DtoC(dInicio),6,3+nY2T),cForAno)
	ElseIf (nTipo == 5)                     // Trimestral
		If Month(dInicio) < 4
			dInicio := CtoD("01/01/"+Substr(DtoC(dInicio),7+nY2T,2),cForAno)
		ElseIf (Month(dInicio) >= 4) .and. (Month(dInicio) < 7)
			dInicio := CtoD("01/04/"+Substr(DtoC(dInicio),7+nY2T,2),cForAno)
		ElseIf (Month(dInicio) >= 7) .and. (Month(dInicio) < 10)
			dInicio := CtoD("01/07/"+Substr(DtoC(dInicio),7+nY2T,2),cForAno)
		ElseIf (Month(dInicio) >=10)
			dInicio := CtoD("01/10/"+Substr(DtoC(dInicio),7+nY2T,2),cForAno)
		EndIf
	ElseIf (nTipo == 6)                     // Semestral
		If Month(dInicio) <= 6
			dInicio := CtoD("01/01/"+Substr(DtoC(dInicio),7+nY2T,2),cForAno)
		Else
			dInicio := CtoD("01/07/"+Substr(DtoC(dInicio),7+nY2T,2),cForAno)
		EndIf
	EndIf

	//Monta as datas de acordo com os parametros                   
	If nTipo != 7
		For i := 1 to nPeriodos
			dInicio := A712NextUtil(dInicio,aPerg711)
			AADD(aRetorno,dInicio)
			If nTipo == 1
				dInicio ++
			ElseIf nTipo == 2
				dInicio += 7
			ElseIf nTipo == 3
				dInicio := StoD(If(Substr(DtoS(dInicio),7,2)<"15",Substr(DtoS(dInicio),1,6)+"15",;
				If(Month(dInicio)+1<=12,Str(Year(dInicio),4)+StrZero(Month(dInicio)+1,2)+"01",;
								Str(Year(dInicio)+1,4)+"0101")),cForAno)
					ElseIf nTipo == 4
				dInicio := CtoD("01/"+If(Month(dInicio)+1<=12,StrZero(Month(dInicio)+1,2)+;
								"/"+Substr(Str(Year(dInicio),4),nPosAno,nTamAno),"01/"+Substr(Str(Year(dInicio)+1,4),nPosAno,nTamAno)),cForAno)
				ElseIf nTipo == 5
				dInicio := CtoD("01/"+If(Month(dInicio)+3<=12,StrZero(Month(dInicio)+3,2)+;
								"/"+Substr(Str(Year(dInicio),4),nPosAno,nTamAno),"01/"+Substr(Str(Year(dInicio)+1,4),nPosAno,nTamAno)),cForAno)
				ElseIf nTipo == 6
				dInicio := CtoD("01/"+If(Month(dInicio)+6<=12,StrZero(Month(dInicio)+6,2)+;
								"/"+Substr(Str(Year(dInicio),4),nPosAno,nTamAno),"01/"+Substr(Str(Year(dInicio)+1,4),nPosAno,nTamAno)),cForAno)
				EndIf
			Next i
		ElseIf nTipo == 7
			For i:=1 to Len(aDiversos)
			AADD(aRetorno, StoD(DtoS(CtoD(aDiversos[i])),cForAno) )
			Next
		Endif

	//Ponto de entrada customizacoes na atualizacoes de periodos   
		If ExistBlock("A710PERI")
		aRetorno := ExecBlock("A710PERI", .F., .F., aRetorno )
		EndIf

Return aRetorno                




/*-----------------+---------------------------------------------------------+
!Nome              ! EST100PV                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Importação das demandas restaurantes                    !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
// Espera-se que arquivos estejam na pasta \import\prophix do servidor
//   Nome do arquivo SC4_UUUUUUUUUU.csv onde UUUUUUUUUU -> identificador da unidade 
//   Campos do arquivo
//   02MDBG0003;20403905001800;01;868;705;683.0232449;20180630
//        |            |       |   |   |        |         +-> data da necessidade do produto no formato AAAAMMDD
//        |            |       |   |   |        +-> valor unitario do produto com separador decimal .   
//        |            |       |   |   +-> quantidade necessari   
//        |            |       |   +-> numero do documento???   
//        |            |       +-> local do produto   
//        |            +-> codigo do produto   
//        +-> codigo da unidade (igual ao que consta no nome do arquivo)   
User Function EST100PV(oEventL)
Local aFiles      := {}
Local nX	      := 0
Local cDirBase    := "\import\prophix\"
Local nArquivo    := 0
Local lErro       := .f.
Local cStartPath  := ""
Local c2StartPath := "\import\prophix\imp\'
Local cAuxLog     := ""      
Local cFile
Local cUndMad
Local lLock
Local oError

	cAuxLog:="MRP | " + ": Importando arquivos..." 
	ConOut(cAuxLog)                              
	oEventL:SetAddInfo(cAuxLog,"")

	// -> Verifica se pode executar o processo
	If AllTrim(oEventL:GetStep()) <> ""
		cAuxLog:="MRP | " + "Ok: Aguardando proxima execucao: " + oEventL:GetStep() 
		ConOut(cAuxLog)                              
		oEventL:SetAddInfo(cAuxLog,"")
		Return(.T.)	
	EndIf

	cStartPath 	:= cDirBase 
	c2StartPath	:= cDirBase+"imp\"

	//CRIA DIRETORIOS
    MkFullDir(cDirBase)
	MakeDir(Trim(cStartPath)) //CRIA DIRETORIO ENTRADA
	MakeDir(c2StartPath) //CRIA DIRETORIO ANO

	aFiles := Directory(cStartPath +"SC4"+cFilAnt+"*.CSV")
	nArquivo := 0
	dbSelectArea("ZWS")
	ZWS->(dbSetOrder(1))
	For nX := 1 To Len(aFiles)
		
		cAuxLog:="MRP | " + ": Lendo arquivo " +AllTrim(aFiles[nX,1]) + "..." 
		ConOut(cAuxLog)                              
		oEventL:SetAddInfo(cAuxLog,"")
				
		nArquivo++
		cFile   := aFiles[nX,1]
		cUndMad := substr(cFile, 4, at(".", cFile)-4)
		TRYEXCEPTION
	 		//Processa Arquivo
		  	xReadArq(cFile, cUndMad, cStartPath, c2StartPath, oEventL)
		CATCHEXCEPTION USING oError
		  	lErro  :=.T.
			cAuxLog:="MRP | " + procname()+"("+cValToChar(procline())+")" + oError:Description 
            oEventL:broken("Na execucao.", cAuxLog, .T.)
            Conout(cAuxLog + Chr(13) + Chr(10) + 'Detalhamento :'+varinfo('oError',oError))
		ENDEXCEPTION
		
	Next nX
	
	cAuxLog:="MRP | " + ": "+ AllTrim(Str(Len(aFiles))) + " arquivo(s) importando(s)." 
	ConOut(cAuxLog)                              
	oEventL:SetAddInfo(cAuxLog,"")
	
	// -> Atualiza etapa no log
	If !lErro .and. Len(aFiles) > 0
		oEventL:SetStep("01")
	Else
		oEventL:SetStep("  ")	
	EndIf

	lErro:=IIF(Len(aFiles) <= 0,.T.,lErro)
	cAuxLog:=IIF(lErro,"MRP | " + "Erro.","MRP | " + "Ok.") 
	ConOut(cAuxLog)                              
	oEventL:SetAddInfo(cAuxLog,"")

Return(!lErro)





/*-----------------+---------------------------------------------------------+
!Nome              ! ReadArq - Cliente: Madero                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Leitura do arquivo de demanda do Prophix                !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function xReadArq(cFile , cUndMad, cStartPath, c2StartPath, oEventL)
Local nHdl      := 0
Local nRecs     := 0
Local nRecsImp  := 0
Local lProces   := .t.
Local lErro     := .f.
Local nValor    := 0  
Local cDataPr   := 0
Local dDataPr   := 0
Local aSB1      := SB1->(GetArea())
Local aADK      := ADK->(GetArea())
Local nOpcao    := 3
Local cPathTmp  := "\temp\"
Local cAuxLog   := ""
Local dAuxData  := dDataBase
Local lExcluiu  := .F.
Local cLine
Local aLinha
Local cProd   
Local cLocal  
Local cDoc    
Local nQuant  
Local cArqTXT
Local cNomNovArq
Local oError
Local cQuery
Local cFilSB1:= xFilial("SB1")
Local cFilNNR:= xFilial("NNR")
Local cFilSC4:= xFilial("SC4") 
Local aLogAux:= {}
Local nx     := 0
Private lMsErroAuto:=.F.

	// -> Abre o arquivo
	nHdl := FT_FUSE(cStartPath+cFile)  //cStartPath //D:\TOTVS\microsiga\protheus12\ambientes\qa\import\prophix
	if nHdl < 0
		
		lErro  :=.T.
		cAuxLog:="MRP | " + "Erro ao abrir o arquivo." 
        oEventL:broken("No arquivo.", cAuxLog, .T.)
        Conout(cAuxLog)
	
	Else
		
		cAuxLog :="MRP | " + ": Excluindo demandas anteriores..." 
		ConOut(cAuxLog)                              
    	oEventL:SetAddInfo(cAuxLog)    						

		Begin Transaction
	        	
    		// -> Exclui as demandas atuais
			If !lExcluiu
				cQuery := " DELETE FROM "+RetSQLName("SC4")           "
				cQuery += " WHERE C4_FILIAL = '" + xFilial("SC4")+ "' "
				cQuery += " AND C4_DATA >= '" + dtos(dDataBase)  + "' "
				TCSqlExec(cQuery)
				lExcluiu:=.T.
			EndIf
			
			cAuxLog :="MRP | " + "Ok." 
			ConOut(cAuxLog)                              
			aadd(aLogAux,{cAuxLog,""})

			cAuxLog :="MRP | " + ": Carregando novas demandas..." 
			ConOut(cAuxLog)                              
    		aadd(aLogAux,{cAuxLog,""})

			// -> Processa arquivo de demanda
			nRecs := FT_FLastRec()
			FT_FGoTop()
			While !FT_FEOF()

				lErro := .F.
				cLine := FT_FReadLN()
				aLinha:= Separa( cLine, ";" )

				if len(aLinha) >= 6
					cProd   := aLinha[2]
					cLocal  := aLinha[3]
					cDoc    := aLinha[4]
					nQuant  := val(aLinha[5])
					cDataPr := aLinha[6]
					nRecsImp++
			
					// -> Pula a primeira linha
					If nRecsImp <=1
						FT_FSkip()
						Loop				
					EndIf
								
					DbSelectArea("SB1")
					SB1->(dbSetOrder(1))
					if !SB1->(msSeek(cFilSB1+cProd))
						cAuxLog := "MRP | " + "Produto "+cProd+" não encontrado no Protheus."
						ConOut(cAuxLog)                              
						aadd(aLogAux,{cAuxLog,""})
						lErro := .T.
					EndIf
					
					DbSelectArea("NNR")
					NNR->(dbSetOrder(1))
					if !NNR->(msSeek(cFilNNR+cLocal))
						cAuxLog := "MRP | " + "Local de estoque "+cLocal+" não encontrado no Protheus."
						ConOut(cAuxLog)                              
						aadd(aLogAux,{cAuxLog,""})
						lErro := .T.
					EndIf
								
					// -> Se não ocorreu erro, continua...
					If !lErro .and. nQuant > 0 .and. AllTrim(SB1->B1_COD) <> ""
	
						TRYEXCEPTION
							dDataPr := stod(cDataPr)
						CATCHEXCEPTION USING oError
							lErro    := .T.
							dDataBase:=dAuxData
							cAuxLog  := "MRP | " + "Data "+cDataPr+" inválida: " + cLine
							ConOut(cAuxLog)                              
							aadd(aLogAux,{cAuxLog,""})
							lProces:=.f.
						ENDEXCEPTION

						aDados   :={}
						cAuxLog  :=""
						dDataBase:=dDataPr
						aadd(aDados,{"C4_FILIAL" ,cFilSC4            									,Nil})
						aadd(aDados,{"C4_PRODUTO",SB1->B1_COD            									,Nil})
		            	aadd(aDados,{"C4_LOCAL"  ,cLocal													,Nil})
	        		    aadd(aDados,{"C4_DOC"    ,cDoc														,Nil})
			            aadd(aDados,{"C4_QUANT"  ,nQuant													,Nil})
			            aadd(aDados,{"C4_VALOR"	 ,nValor													,Nil})
		    	        aadd(aDados,{"C4_DATA"   ,dDataBase													,Nil})
		        	    aadd(aDados,{"C4_OBS"    ,"Demanda restaurantes."									,Nil})
						
						// -> Executa inclusão / alteração
						DbSelectArea("SC4")
						MATA700(aDados,nOpcao)
						If lMsErroAuto
							lErro   := .T.
							cAuxLog := "dmun_"+cFilAnt+"_"+SB1->B1_COD+"_"+strtran(time(),":","")
							MostraErro(cPathTmp, cAuxLog)
							cAuxLog:="MRP | " + "Erro na geracao da denada: Verifique o log em " + cPathTmp + cAuxLog
							ConOut(cAuxLog)   
							aadd(aLogAux,{cAuxLog,""})                               						
    						lProces  :=.f.    							
						EndIf
					EndIf

				EndIf

				FT_FSkip()
				
			Enddo
	
		End Transaction
					
	EndIF
	FT_FUSE()
	
	// -> Se ok, registra log
	If !lErro
		cAuxLog :="MRP | " + "Ok." 
		ConOut(cAuxLog)                              
    	oEventL:SetAddInfo(cAuxLog)    						
	EndIf

	// -> Gerando log do processo
	cAuxLog :="MRP | " + ": Atualizando log..." 
	ConOut(cAuxLog)                              
    oEventL:SetAddInfo(cAuxLog)    						
	For nx:=1 to Len(aLogAux)
		oEventL:SetAddInfo(aLogAux[nx,1])
	Next nx

	cAuxLog :="MRP | " + "Ok." 
	ConOut(cAuxLog)                              
    oEventL:SetAddInfo(cAuxLog)    						

	cAuxLog :="MRP | " + ": "+AllTrim(Str(nRecsImp-1))+" iten(s) processados." 
	ConOut(cAuxLog)                              
    oEventL:SetAddInfo(cAuxLog)    						
			
	// Se não ocorreu erro no procesamento, atualiza o arquivo
	If lProces
    	
    	// -> Move Arquivo Lido
	    cArqTXT := cStartPath+cFile
		cNomNovArq  := UPPER(c2StartPath+strtran(cFile,".","_"+dtos(date())+"."))
		
		// - > copia o arquivo antes da transacao
	    fErase(cNomNovArq)
		If __CopyFile(cArqTXT,cNomNovArq)
		   FErase(cStartPath+cFile)
		EndIf
	
	EndIf
	
	dDataBase:=dAuxData
	
    SB1->(RestArea(aSB1))
    ADK->(RestArea(aADK))

Return lProces




/*-----------------+---------------------------------------------------------+
!Nome              ! MkFullDir - Cliente: Madero                             !
+------------------+---------------------------------------------------------+
!Descrição         ! Criacao de estrutura completa de diretorio              !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 21/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function MkFullDir(cDir)
    local cBase := ""
    cDir := trim(cDir)
	if (left(cDir, 2) != "\\")
		while (!empty(cDir))
			if ("\" $ cDir)
                cBase += substr(cDir, 1, at("\", cDir)-1)
			Else
                cBase += cDir
			EndIf
			if !empty(cBase)
                MakeDir(cBase)
			Endif
            cBase += "\"
			if ("\" $ cDir)
                cDir := substr(cDir, at("\", cDir)+1)
			Else
                exit
			EndIf
		enddo
	EndIf
Return nil       





/*-----------------+---------------------------------------------------------+
!Nome              ! COM104 - Cliente: Madero                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Geração de pedidos de compras                           !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 23/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function PutSC7(oEventLog)
Local lErro104A:= .F.
Local lErro104 := .F.
Local cAuxLog  := ""
Local aErros   := {}
Local aAuxRet  := {}
Local aArea104 := GetArea()
Local aCOM105  := {}
Local oError
Local nx     
		
	If AllTrim(oEventLog:GetStep()) <> "03"
		cAuxLog:="MRP | " + "Ok: Aguardando proxima execucao: " + oEventLog:GetStep() 
		ConOut(cAuxLog)                              
		oEventLog:SetAddInfo(cAuxLog,"")
		Return(.T.)	
	EndIf
		
	// -> Gera os pedidos de compra
	AADD(aCOM105,dDataBase)
	AADD(aCOM105,cEmpAnt)
	AADD(aCOM105,cFilAnt)
	AADD(aCOM105,nModulo)
	//aAuxRet  :=startJob("U_COM105", GetEnvServer(), .T., aCOM105)
	aAuxRet  :=U_COM105(aCOM105)
	aErros   :=aAuxRet[1]
	lErro104A:=aAuxRet[2]
					
	// -> Se ocorreu erro, exibe e registra no log
	If lErro104A
		For nx:=1 to Len(aErros)
			// -> Verifica se teve erros
			If AllTrim(aErros[nx,2]) <> "" .or. AllTrim(aErros[nx,3]) <> "" .or. AllTrim(aErros[nx,4]) <> "" .or. AllTrim(aErros[nx,5]) <> ""
				lErro104:=.T.			
				If nx <= 1
					cAuxLog := "MRP | "+ aErros[nx,1]
					ConOut(cAuxLog)
					oEventLog:SetAddInfo(cAuxLog,"")
				EndIf
				// -> Exibe erro 1
				If AllTrim(aErros[nx,2]) <> ""
					cAuxLog := "MRP | "+aErros[nx,2]
					ConOut(cAuxLog)
					oEventLog:SetAddInfo(cAuxLog,"")
				EndIf
					// -> Exibe erro 2
				If AllTrim(aErros[nx,3]) <> ""
						cAuxLog := "MRP | "+ aErros[nx,3]
						ConOut(cAuxLog)
						oEventLog:SetAddInfo(cAuxLog,"")
				EndIf
					// -> Exibe erro 3
				If AllTrim(aErros[nx,4]) <> ""
						cAuxLog := "MRP | " + aErros[nx,4]
						ConOut(cAuxLog)
						oEventLog:SetAddInfo(cAuxLog,"")
				EndIf
					// -> Exibe erro 4
				If AllTrim(aErros[nx,5]) <> ""
						cAuxLog := "MRP | " + aErros[nx,5]
					ConOut(cAuxLog)
					oEventLog:SetAddInfo(cAuxLog,"")
				EndIf
			EndIf
		Next nx
	Else
		cAuxLog:="MRP | " + "Ok."
		ConOut(cAuxLog)                              
		oEventLog:SetAddInfo(cAuxLog,"")	
	EndIf
	
	// -> Verifica se ocorreu erro
	If lErro104
		oEventLog:broken("MRP | " + "Geracao do pedido de compra.",IIF(Len(aErros)<=0,cAuxLog,""),.T.)
	Else
		cAuxLog:=IIF(lErro104,"MRP | " + "Erro.","MRP | " + "Ok.") 
		ConOut(cAuxLog)
		oEventLog:SetAddInfo(cAuxLog,"")
		oEventLog:SetStep("04")		
	Endif

	RestArea(aArea104)
	
Return(!lErro104)

/*-----------------+---------------------------------------------------------+
!Nome              ! EST100TB - Cliente: Madero                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Copia de tabela de precos					             !
+------------------+---------------------------------------------------------+
!Autor             ! Thiago Berna - TSM                                      !
+------------------+---------------------------------------------------------!
!Data              ! 08/03/2019                                              !
+------------------+--------------------------------------------------------*/
//#TB20191129 Thiago Berna - Ajuste para receber retorno antes de encerrar a thread.
//User Function EST100TB(aDadosSA5)// cProdInd,cTipConv,nFatConv,cFornece,cLoja,cEmpAtu,cFilAtu,cProduto)
User Function EST100TB(aDadosSA5,cThdId01)// cProdInd,cTipConv,nFatConv,cFornece,cLoja,cEmpAtu,cFilAtu,cProduto)
Local cEmpAtu	  	:= ''
Local cFilAtu	  	:= ''
Local cQuery	  	:= ''
Local cPathTmp	  	:= "\temp\"
Local cArqTmp 	  	:= "AIA_AIB_i_"  + DToS( Date( ) ) + "_" + StrTran( Time( ), ":", "" ) + "_.txt"
Local cAliTmp4    	:= ''
Local cAliasAIB		:= ''
Local cAuxLog		:= ''
Local aDadAIA	  	:= {}
Local aDadAIAE	  	:= {}
Local aDadAIB	  	:= {}
Local aArea			:= GetArea()
Local nOpcX		  	:= 0
Local nPrcCom	  	:= 0
Local nCount		:= 0
Local lRet		  	:= .T.
Local aRet          := {}
Local aExecAuto     := {{},{}}
Local nx            := 0
Local cProdInd 	    := ''
Local cTipConv	    := ''
Local nFatConv	    := 0
Local cFornece	    := ''
Local cLoja		    := ''
Local cEmpAtu       := IIF(Len(aDadosSA5)>0,aDadosSA5[01,06],"")
Local cFilAtu       := IIF(Len(aDadosSA5)>0,aDadosSA5[01,07],"")
Local dDataProc     := IIF(Len(aDadosSA5)>0,aDadosSA5[01,09],Date())
Local aParEmpFil    := IIF(Len(aDadosSA5)>0,aDadosSA5[01,10],{})
Local cCnpjFil      := IIF(Len(aDadosSA5)>0,aDadosSA5[01,11],"")
Local cProduto	    := ''
Local lFindSA1      := .F.
Local lFindAIA      := .F.
Private lMsErroAuto := .F.

	////////////////////////////////////////////// INDUSTRIA ///////////////////////////////////////////////
	
	// -> Inicializacao da empresa
	lRet :=!Len(aParEmpFil) <= 1
	If lRet
		aRet    := {.F.,{}}
		cAuxLog :="MRP | " + ": Selecionado dados da origem [M0_CODIGO="+aParEmpFil[1]+" e M0_CODFIL="+aParEmpFil[2]+"]..."
		ConOut(cAuxLog) 
		AAdd(aRet[02],cAuxLog)                             

		RpcClearEnv()
		RPcSetType(3)
		RpcSetEnv(aParEmpFil[1],aParEmpFil[2], , ,'FAT' , GetEnvServer() )
		OpenSm0(aParEmpFil[1], .f.)
		nModulo  := 5
		dDataBase:=dDataProc
		SM0->(dbSetOrder(1))
		If SM0->(dbSeek(aParEmpFil[1]+aParEmpFil[2]))
			cEmpAnt := SM0->M0_CODIGO
			cFilAnt := SM0->M0_CODFIL
		Else
			lRet	:=.F.	
			aRet[01]:=!lRet
			cAuxLog :="MRP | " + "Empresa  e filial nao localizadas na tabela SM0. [M0_CODIGO=" + aParEmpFil[1] + " e M0_CODFIL=" + aParEmpFil[2] + "]"
			ConOut(cAuxLog) 
			AAdd(aRet[02],cAuxLog)                             
		EndIf
	Else
		lRet	:=.F.	
		aRet    := {!lRet,{}}
		cAuxLog :="MRP | " + "Erro nos dados do parametro de empresa e filial da industria MV_XFILIND. Verifique o conteudo do mesmo."
		ConOut(cAuxLog) 
		AAdd(aRet[02],cAuxLog)                             
	EndIf

	// -> Procura pelo cliente
	If lRet
		SA1->(DbSelectArea("SA1"))
		SA1->(DbSetOrder(3))
		SA1->(DbSeek(xFilial("SA1")+cCnpjFil))

		// -> Valida cliente da indústria
		lFindSA1:=.F.
		While !SA1->(Eof()) .and. SA1->A1_FILIAL == xFilial("SA1") .and. AllTrim(SA1->A1_CGC) == AllTrim(cCnpjFil) .and. !Empty(cCnpjFil)
			// -> Verifica se o cliente é diferente de 'consumidor final'
			If SA1->A1_TIPO <> "F"
			   lFindSA1:=.T.
			   Exit
			EndIf
			SA1->(DbSkip())
		EndDo

		If lFindSA1

			// -> Procura pela tabela de precos
			DbSelectArea("DA0")
			DbSetOrder(1)
			If DbSeek(xFilial("DA0")+SA1->A1_TABELA)

				//DA0->(dbGoTo((cAliTmp4)->RECNO_DA0))
				// -> Verifica a vigencia da tabela de precos
				If  Dtos(DA0->DA0_DATDE) <= DtoS(dDataBase) .and. (Empty(DA0->DA0_DATATE) .or. ( DtoS(DA0->DA0_DATATE) >= DtoS(dDataBase) ) )

					//-> Seleciona dados
					aDadAIA:={}
					aDadAIB:={}
					For nx:=1 to Len(aDadosSA5)

						cProdInd:=aDadosSA5[nx,01]
						cTipConv:=aDadosSA5[nx,02]
						nFatConv:=aDadosSA5[nx,03]
						cFornece:=aDadosSA5[nx,04]
						cLoja	:=aDadosSA5[nx,05]
						cProduto:=aDadosSA5[nx,08]
						cAliTmp4:= GetNextAlias()

						If Select(cAliTmp4) > 0
							DbSelectArea(cAliTmp4)
							DbCloseArea()
						EndIf

						cQuery := " SELECT DA0.R_E_C_N_O_ RECNO_DA0, DA1.R_E_C_N_O_ RECNO_DA1, DA1.DA1_CODPRO, "
						cQuery += " DA1.DA1_DATVIG, DA0.DA0_CODTAB, DA0.DA0_DATDE, DA0.DA0_DATATE, DA0.DA0_DESCRI, DA1.DA1_PRCVEN "
						cQuery += " FROM " + RetSqlName("DA0") + " DA0 " 
						cQuery += " INNER JOIN " + RetSqlName("DA1") + " DA1 ON " 
						cQuery += " DA1.DA1_FILIAL = DA0.DA0_FILIAL AND "
						cQuery += " DA1.DA1_CODTAB = DA0.DA0_CODTAB AND "
						cQuery += " DA1.D_E_L_E_T_ = DA0.D_E_L_E_T_ "
						cQuery += " WHERE DA0.DA0_FILIAL   = '" + xFilial("DA0")  + "' AND " 
						cQuery += "       DA0.DA0_CODTAB   = '" + SA1->A1_TABELA  + "' AND  " 
						cQuery += "       DA1.DA1_CODPRO   = '" + cProdInd        + "' AND  " 
						cQuery += "       DA0.D_E_L_E_T_   = '' "
						cQuery := ChangeQuery(cQuery)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTmp4,.T.,.T.)				
					
						(cAliTmp4)->(dbGoTop())
						If !(cAliTmp4)->(Eof())
						
							While !(cAliTmp4)->(Eof())

								// -> Posiciona nas tabelas DA0 e DA1
								DA1->(dbGoTo((cAliTmp4)->RECNO_DA1))

								// -> Verifica a vigência do item da tabela de preço do faturamento
								If DtoS(DA1->DA1_DATVIG) <= DtoS(dDataBase) .and. DA1->DA1_ATIVO == "1"

									// -> Converte o preco de compra
									If cTipConv == 'D'
										nPrcCom := (cAliTmp4)->DA1_PRCVEN * nFatConv
									ElseIf SA5->A5_XTPCUNF == 'M'
										nPrcCom := (cAliTmp4)->DA1_PRCVEN / nFatConv
									Else
										nPrcCom := 0
									EndIf

									//-> Alimenta array de itens para inclusao de tabela de preco
									AAdd(aDadAIB,{})	
									AAdd(aDadAIB[len(aDadAIB)],{"AIB_ITEM"	,'0001'							,})	
									AAdd(aDadAIB[len(aDadAIB)],{"AIB_CODPRO",/*(cAliTmp4)->DA1_CODPRO*/cProduto			,})								
									AAdd(aDadAIB[len(aDadAIB)],{"AIB_PRCCOM",nPrcCom 						,})	
									AAdd(aDadAIB[len(aDadAIB)],{"AIB_DATVIG",STOD((cAliTmp4)->(DA1_DATVIG))	,})

									//Alimenta array de cabecalho para inclusao de tabela de preco
									If Len(aDadAIA) == 0
										AAdd( aDadAIA, { "AIA_CODFOR"	, cFornece						, Nil } )
										AAdd( aDadAIA, { "AIA_LOJFOR"	, cLoja							, Nil } )
										AAdd( aDadAIA, { "AIA_CODTAB"	, (cAliTmp4)->(DA0_CODTAB)		, Nil } )
										AAdd( aDadAIA, { "AIA_DESCRI"	, (cAliTmp4)->(DA0_DESCRI)		, NIL } )	
										AAdd( aDadAIA, { "AIA_DATDE"	, STOD((cAliTmp4)->(DA0_DATDE))	, Nil } )	
										AAdd( aDadAIA, { "AIA_DATATE"	, STOD((cAliTmp4)->(DA0_DATATE)), Nil } )
										aExecAuto[01]:=aDadAIA
									EndIf

								Else

									lRet    := .F.
									aRet[01]:=!lRet
									cAuxLog := "MRP | " + "Produto fora de vigencia ou inativo na tabela de prco da industria. [AIB_CODPRO=" + AllTrim(cProdInd) + " e AIA_CODTAB=" + AllTrim(SA1->A1_TABELA) + "] ."
									ConOut(cAuxLog) 
									AAdd(aRet[02],cAuxLog)   

								EndIf
	
								(cAliTmp4)->(DbSkip())
					
							EndDo

							(cAliTmp4)->(DbCloseArea())						
							Aadd(aExecAuto[02],aDadAIB)

						Else
				
							lRet    := .F.
							aRet[01]:=!lRet
							cAuxLog := "MRP | " + "Produto nao encontrado na tabela de preco da industria. [AIB_CODPRO=" + AllTrim(cProdInd) + " e AIA_CODTAB=" + AllTrim(SA1->A1_TABELA) + "] ."
							ConOut(cAuxLog) 
							AAdd(aRet[02],cAuxLog)   
				
						EndIf

					Next nx

				Else
						
					lRet     := .F.						
					aRet[01] := !lRet
					cAuxLog  := "MRP | " + "Tabela de preco fora da vigencia. [AIA_CODTAB=" + AllTrim(DA0->DA0_CODTAB)+"]"
					ConOut(cAuxLog) 
					AAdd(aRet[02],cAuxLog)                             						
						
				EndIf

			Else
				
				lRet    := .F.
				aRet[01]:=!lRet
				cAuxLog := "MRP | " + "Tabela de Preco nao localizada no cadastro do cliente. [A1_COD="+SA1->A1_COD+", A1_LOJA="+SA1->A1_LOJA+" e A1_TABELA="+SA1->A1_TABELA+"]"
				ConOut(cAuxLog)  
				AAdd(aRet[02],cAuxLog)                            
			
			EndIf

		Else
		
			lRet    := .F.
			aRet[01]:=!lRet
			cAuxLog  := "MRP | " + "Cliente CNPJ nao localizado na tabela de empresas (SM0) [M0_CGC=" + SM0->M0_CGC + "]"
			ConOut(cAuxLog)     
			AAdd(aRet[02],cAuxLog)                         
	
		EndIf
	
	EndIf
	////////////////////////////////////////////// FIM INDUSTRIA ///////////////////////////////////////////////
	

	///////////////////////////////////////////// EMPRESA ORIGINAL /////////////////////////////////////////////
	// -> Verifica se precisa alterar a empresa
	If lRet
		
		// -> Verifica se há dados para atualizar
		If Len(aExecAuto) > 0
			
			// -> inicializa o ambiente de destino dos dados
			If  !Empty(cEmpAtu) .and. !Empty(cFilAtu)
		
				cAuxLog :="MRP | " + ": Incluindo dados no destino [M0_CODIGO="+cEmpAtu+" e M0_CODFIL="+cFilAtu+"]..."
				ConOut(cAuxLog) 
				AAdd(aRet[02],cAuxLog)                             

				// -> Se a filial da indústria for diferente do restaurante, inicializa ambiente
				If cEmpAtu != cEmpAnt .or. cFilAtu != cFilAnt
					RpcClearEnv()
					RPcSetType(3)
					RpcSetEnv(cEmpAtu,cFilAtu, , ,'COM' , GetEnvServer() )
					OpenSm0(cEmpAtu, .f.)
					nModulo  := 2
					dDataBase:=dDataProc
					SM0->(dbSetOrder(1))
					If SM0->(dbSeek(cEmpAtu+cFilAtu))
						cEmpAnt := SM0->M0_CODIGO
						cFilAnt := SM0->M0_CODFIL
					Else
						lRet	:= .F.
						aRet[01]:= !lRet
						cAuxLog := "MRP | " + "Filial nao localizada na SM0. [M0_CODIGO="+cEmpAtu+" e M0_CODFIL="+cFilAtu+"]"
						ConOut(cAuxLog)
						AAdd(aRet[02],cAuxLog)                              
					EndIf
				EndIf

				// -> Inicializa a gravação dos dados no destino
				Begin Transaction
						
					// -> Ajusta o X3_VALID dos campos AIA_CODFOR e AIA_LOJFOR
					AjustaSX3()

					// -> Verifica se a tabela ja existe
					lFindAIA:=.F.
					DbSelectArea("AIA")
					AIA->(DbSetOrder(1))
					AIA->(DbSeek(xFilial("AIA")+cFornece+cLoja))				
					While !AIA->(Eof()) .and. AIA->AIA_FILIAL == xFilial("AIA") .and. AIA->AIA_CODFOR == cFornece .and. AIA->AIA_LOJFOR == cLoja
						aExecAuto[01,aScan(aExecAuto[01],{|x| AllTrim(x[1]) == 'AIA_CODTAB'}),2]:= AIA->AIA_CODTAB
						lFindAIA:=.T.
						Exit
						AIA->(DbSkip())
					EndDo

					// -> Verifica se o produto existe na tabela e, caso existe, exclui
					aDadAIAE:={}
					If lFindAIA
						
						cAuxLog := "MRP | " + ": Excluindo tabela de preco " + AIA->AIA_CODTAB + " do fornecedor "+AIA->AIA_CODFOR+" loja "+AIA->AIA_LOJFOR+"..."
						ConOut(cAuxLog)
						AAdd(aRet[02],cAuxLog)                              
						
						AAdd(aDadAIAE,{"AIA_CODFOR",AIA->AIA_CODFOR,Nil})
						AAdd(aDadAIAE,{"AIA_LOJFOR",AIA->AIA_LOJFOR,Nil})
						AAdd(aDadAIAE,{"AIA_CODTAB",AIA->AIA_CODTAB,Nil})

						MSExecAuto({|x,y,z| COMA010( x, y, z ) }, 5, aDadAIAE, {} )
						If lMsErroAuto
							cAuxLog := "MRP | " + ": Erro na exclusão da tabela de preco " + AIA->AIA_CODTAB + " do fornecedor "+AIA->AIA_CODFOR+" loja "+AIA->AIA_LOJFOR+"..."
							ConOut(cAuxLog)
							AAdd(aRet[02],cAuxLog)    
							lRet    := .F.
							aRet[01]:= !lRet
							DisarmTransaction()
							Break
						Else
							cAuxLog := "MRP | " + "Ok."
							ConOut(cAuxLog)
							AAdd(aRet[02],cAuxLog)                              
						EndIf

					EndIf

					// -> Reposiciona na tabela de preço
					// AIA->(DbGoTop())
					// If AIA->(DbSeek(xFilial("AIA")+cFornece+cLoja+aExecAuto[01,aScan(aExecAuto[01],{|x| AllTrim(x[1]) == 'AIA_CODTAB'}),2]))				

					// 	// -> Verifica se o item ja existe na tabela
					// 	DbSelectArea("AIB")
					// 	AIB->(DbSetOrder(2))

					// 	For nCount := 1 to Len(aExecAuto[02])

					// 		If AIB->(DbSeek(xFilial("AIB")+AIA->AIA_CODFOR+AIA->AIA_LOJFOR+AIA->AIA_CODTAB+aExecAuto[02,02,nCount,aScan(aExecAuto[02,02,nCount],{|x| AllTrim(x[1]) == 'AIB_CODPRO'}),2]))	

					// 			aExecAuto[02,02,nCount,aScan(aExecAuto[02,02,nCount],{|x| AllTrim(x[1]) == 'AIB_ITEM'}),2] := AIB->AIB_ITEM

					// 		Else

					// 			// -> Verifica o proximo item da tabela de preco de compra
					// 			cAliasAIB:= GetNextAlias()

					// 			If Select(cAliasAIB) > 0
					// 				DbSelectArea(cAliasAIB)
					// 				DbCloseArea()
					// 			EndIf

					// 			cQuery   := " SELECT MAX(AIB.AIB_ITEM) AS AIB_ITEM FROM " + RetSqlTab('AIB')
					// 			cQuery   += " WHERE AIB.AIB_FILIAL = '" + xFilial("AIB") + "' "
					// 			cQuery   += "   AND AIB.AIB_CODTAB = '" + aExecAuto[01,aScan(aExecAuto[01],{|x| AllTrim(x[1]) == 'AIA_CODTAB'}),2] + "' "
					// 			cQuery   += "   AND AIB.AIB_CODFOR = '" + aExecAuto[01,aScan(aExecAuto[01],{|x| AllTrim(x[1]) == 'AIA_CODFOR'}),2] + "' "
					// 			cQuery   += "   AND AIB.AIB_LOJFOR = '" + aExecAuto[01,aScan(aExecAuto[01],{|x| AllTrim(x[1]) == 'AIA_LOJFOR'}),2] + "' "
					// 			cQuery   += "   AND AIB.D_E_L_E_T_ = '' "
					// 			cQuery   := ChangeQuery(cQuery)
					// 			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAliasAIB, .F., .T.)
					// 			If (cAliasAIB)->(!Eof())
					// 				cItem := Soma1((cAliasAIB)->(AIB_ITEM))
					// 			Else	
					// 				cItem := '0001'
					// 			EndIf

					// 			If Select(cAliasAIB) > 0
					// 				DbSelectArea(cAliasAIB)
					// 				DbCloseArea()
					// 			EndIf

					// 			aExecAuto[02,02,nCount,aScan(aExecAuto[02,02,nCount],{|x| AllTrim(x[1]) == 'AIB_ITEM'}),2] := cItem
								
					// 		EndIf

					// 	Next nCount

					// 	// -> Altera os itens se a tabela e o item ja existe
					// 	nOpcX := 4 //Alteracao
					// 	MSExecAuto({|x,y,z| COMA010( x, y, z ) }, nOpcX, aExecAuto[01], aExecAuto[02,02] )
					// 	If lMsErroAuto
					// 		fCriaDir( cPathTmp )
					// 		MostraErro( cPathTmp, cArqTmp )
					// 		cAuxLog := "MRP | " + "Erro na exclusao da tabela de preco, verifique o detalhamento da ocorrencia."
					// 		lRet    := .F.
					// 		aRet[01]:= lRet
					// 		ConOut(cAuxLog)
					// 		AAdd(aRet[02],cAuxLog)
					// 	EndIf							

					// Else	
							
					// -> Inclui uma nova tabela de preco se a tabela nao existe
					// -> Atualiza Variaveis para inclusao
					nOpcX := 3 // Inclusao
					MSExecAuto({|x,y,z| COMA010( x, y, z ) }, nOpcX, aExecAuto[01], aExecAuto[02,02] )
					If lMsErroAuto
						fCriaDir( cPathTmp )
						MostraErro( cPathTmp, cArqTmp )
						cAuxLog := "MRP | " + "Erro na inclusao da tabela de preco, verifique o detalhamento da ocorrencia."
						lRet    := .F.
						aRet[01]:= !lRet
						ConOut(cAuxLog)
						AAdd(aRet[02],cAuxLog)
					EndIf
						
					// EndIf

					// -> Se ocorreu erro, disarma a transação
					If !lRet
						DisarmTransaction()
						Break
					EndIf

				End Transaction
				
			Else

				lRet	:= .F.
				aRet[01]:= !lRet
				cAuxLog := "MRP | " + "Problema nos parametros de empresa e filial passados para a função. [M0_CODIGO=Vazio e/ou M0_CODFIL=Vazio]"
				ConOut(cAuxLog)
				AAdd(aRet[02],cAuxLog)                              

			EndIf

		Else

			lRet	:= .F.
			aRet[01]:= !lRet
			cAuxLog := "MRP | " + "Sem dados para incluir na tabel de precos de compras"
			ConOut(cAuxLog)
			AAdd(aRet[02],cAuxLog)                              

		EndIf

	EndIf

	RestArea(aArea)

	//#TB20191129 Thiago Berna - Ajuste para receber retorno antes de encerrar a thread.
	PutGlbVars(cThdId01,aRet)

	RpcClearEnv()

	//#TB20191129 Thiago Berna - Ajuste para encerrar a thread.
	KillApp(.T.)

Return(aRet)

/*-----------------+---------------------------------------------------------+
!Nome              ! fCriaDir - Cliente: Madero                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Cria pasta              					             !
+------------------+---------------------------------------------------------+
!Autor             ! Thiago Berna - TSM                                      !
+------------------+---------------------------------------------------------!
!Data              ! 08/03/2019                                              !
+------------------+--------------------------------------------------------*/
Static Function fCriaDir(cPatch, cBarra)
	
Local lRet   := .T.
Local aDirs  := {}
Local nPasta := 1
Local cPasta := ""
Default cBarra	:= "\"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criando diretório de configurações de usuários.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDirs := Separa(cPatch, cBarra)
	For nPasta := 1 to Len(aDirs)
		If !Empty (aDirs[nPasta])
		cPasta += cBarra + aDirs[nPasta]
			If !ExistDir (cPasta) .And. MakeDir(cPasta) != 0
			lRet := .F.
			Exit
			EndIf
		EndIf
	Next nPasta
	
Return lRet

/*-----------------+---------------------------------------------------------+
!Nome              ! AjustaSX3 - Cliente: Madero                             !
+------------------+---------------------------------------------------------+
!Descrição         ! Ajusta SX3               					             !
+------------------+---------------------------------------------------------+
!Autor             ! Thiago Berna - TSM                                      !
+------------------+---------------------------------------------------------!
!Data              ! 08/03/2019                                              !
+------------------+--------------------------------------------------------*/
Static Function AjustaSX3()
	Local aAreaAnt := GetArea()
	Local aAreaSX3 := SX3->(GetArea())

	dbSelectArea("SX3")
	dbsetOrder(2)
	If dbSeek("AIA_CODFOR")
		If AllTrim(SX3->X3_VALID) <> 'IIF(!ISBLIND(),ExistCpo("SA2",M->AIA_CODFOR+AllTrim(M->AIA_LOJFOR)).And.Com010Pk(),.T.)'
			Reclock("SX3",.F.)
			SX3->X3_VALID := 'IIF(!ISBLIND(),ExistCpo("SA2",M->AIA_CODFOR+AllTrim(M->AIA_LOJFOR)).And.Com010Pk(),.T.)'
			MsUnlock()
		Endif
	Endif

	If dbSeek("AIA_LOJFOR")
		If AllTrim(SX3->X3_VALID) <> 'IIF(!ISBLIND(),ExistCpo("SA2",M->AIA_CODFOR+M->AIA_LOJFOR).And.Com010Pk(),.T.)'
			Reclock("SX3",.F.)
			SX3->X3_VALID := 'IIF(!ISBLIND(),ExistCpo("SA2",M->AIA_CODFOR+M->AIA_LOJFOR).And.Com010Pk(),.T.)'
			MsUnlock()
		Endif
	Endif

	RestArea(aAreaSX3)
	RestArea(aAreaAnt)
Return



/*-----------------+---------------------------------------------------------+
!Nome              ! AjustaSX3 - Cliente: Madero                             !
+------------------+---------------------------------------------------------+
!Descrição         ! Ajusta SX3               					             !
+------------------+---------------------------------------------------------+
!Autor             ! Thiago Berna - TSM                                      !
+------------------+---------------------------------------------------------!
!Data              ! 08/03/2019                                              !
+------------------+--------------------------------------------------------*/
User Function EST100C(cUndMad)
Local aCalendar := {}
Local nu        := 0
Local ny        := 0
Local nAux      := 0
Local cDias     := Space(0)
Local aAuxDias  := {}
Local dAuxIni   := dDataBase // data que foi executado o MRP 
Local dAux      := dDataBase
Local dDataNova := CtoD("  /  /  ") 
Local aDataProx := {} //CtoD("  /  /  ") // modificado para tratar varias datas de entrega 
Local dDataProx := CtoD("  /  /  ") // modificado para tratar varias datas de entrega 
Local dDtProxP 	:= CtoD("  /  /  ") // proxima data prevista 

	// -> Monta datas de entrega conforme calendário
	Z22->(dbSetOrder(1))
	Z22->(dbSeek(xFilial("Z22")+cUndMad))	
	While !Z22->(Eof()) .and. AllTrim(Z22->Z22_FILIAL) == AllTrim(xFilial("Z22")) .and. AllTrim(Z22->Z22_CODUN) == AllTrim(cUndMad)
		aAuxDias:=StrToKarr(alltrim(Z22->Z22_DIA),",")
		cDias   :=Z22->Z22_DIA
		// -> Calcula datas dos calendários
		If Z22->Z22_TIPO $ "S/Q/M"
			nAux   :=aScan(aCalendar,{|xbc| xbc[1] == Z22->Z22_FILIAL+Z22->Z22_CODUN+Z22->Z22_FORN+Z22->Z22_LOJA+Z22->Z22_GRUPO,Z22->Z22_TIPO})
			
			If nAux <= 0 // calendario nao existe no aCalendar
				
				//#TB20200306 Thiago Berna - Ajuste paraq considerar a Data Base do sistema
				//dAuxIni:=Z22->Z22_DTULEN
				dAuxIni:=dDataBase
			
				// -> Calcula nova data de entrega - quando houver uma entrega por semana
				If Len(aAuxDias) <= 1
				
					AADD(aDataProx,dtos(dAuxIni) + "A")

					//#TB20200319 Thiago Berna - Ajuste Calendário
					/*dDataNova:= Iif(Z22->Z22_TIPO == "S",(dAuxIni   +7),Iif(Z22->Z22_TIPO == "Q",(dAuxIni  +14),MonthSum(dAuxIni,1)))
					AADD(aDataProx,dtos(dDataNova) + "F") 
					dDataProx:= Iif(Z22->Z22_TIPOes == "S",(dDataNova +7),Iif(Z22->Z22_TIPO == "Q",(dDataNova+14),MonthSum(dDataNova,1)))  
					AADD(aDataProx,dtos(dDataProx) + "P") 
					dDataProx := Iif(Z22->Z22_TIPO == "S",(dDataProx+7),Iif(Z22->Z22_TIPO == "Q",(dDataProx+14),MonthSum(dDataProx,1)))  
					AADD(aDataProx,dtos(dDataProx) + "P")
					dDataProx := Iif(Z22->Z22_TIPO == "S",(dDataProx+7),Iif(Z22->Z22_TIPO == "Q",(dDataProx+14),MonthSum(dDataProx,1)))  
					AADD(aDataProx,dtos(dDataProx) + "P")*/

					If Z22->Z22_TIPO == "S"
						
						dDataNova:= dAuxIni
						AADD(aDataProx,dtos(dDataNova) + "F") 
						
						//#TB20200518 - Thiago Berna - Nova formula passada pelo fernando "dDatabase até Z22->Z22_DTNXEN + 14 + b1_Xdiaes"
						//dDataProx:= dDataNova + 7
						//AADD(aDataProx,dtos(dDataProx) + "P") 
						dDataProx:= Z22->Z22_DTNXEN
						AADD(aDataProx,dtos(dDataProx) + "F") 
						
						dDataProx := dDataProx + 7
						AADD(aDataProx,dtos(dDataProx) + "P")
						
						dDataProx := dDataProx + 7
						AADD(aDataProx,dtos(dDataProx) + "P")

						dDataProx := dDataProx + 7
						AADD(aDataProx,dtos(dDataProx) + "P")
					
					ElseIf Z22->Z22_TIPO == "Q"

						If dAuxIni + 14 >= Z22->Z22_DTNXEN
							
							dDataNova:= dAuxIni
							AADD(aDataProx,dtos(dDataNova) + "F")
							
							//#TB20200518 - Thiago Berna - Nova formula passada pelo fernando "dDatabase até Z22->Z22_DTNXEN + 14 + b1_Xdiaes"
							//dDataProx:= dDataNova + 14
							//AADD(aDataProx,dtos(dDataProx) + "P") 
							dDataProx:= Z22->Z22_DTNXEN
							AADD(aDataProx,dtos(dDataProx) + "F") 

							dDataProx:= dDataProx + 14
							AADD(aDataProx,dtos(dDataProx) + "P") 

						EndIf
					
					Else

						If MonthSum(dAuxIni,1) >= Z22->Z22_DTNXEN
							
							dDataNova:= dAuxIni
							AADD(aDataProx,dtos(dDataNova) + "F")

							//#TB20200518 - Thiago Berna - Nova formula passada pelo fernando "dDatabase até Z22->Z22_DTNXEN + 14 + b1_Xdiaes"
							dDataNova:= Z22->Z22_DTNXEN 
							AADD(aDataProx,dtos(dDataNova) + "F")
							
							dDataProx:= MonthSum(dDataNova,1)
							AADD(aDataProx,dtos(dDataProx) + "P") 

						EndIf

					EndIf
				
				Else  // -> So quanto for semanal e várias entregas
				
					If Z22->Z22_TIPO == "S"
						
						// -> Data de Entrega
						dAux:=dAuxIni
						AADD(aDataProx,dtos(dAuxIni)+"A" )

						//#TB20200409 Thiago Berna - Ajuste para firmar os registros a partir da data inicial
						AADD(aDataProx,dtos(dAuxIni)+"F" )

						//#TB20200413 Thiago Berna - Ajuste para considerar a data a partir da proxima entrega.
						dAux := Z22->Z22_DTNXEN
						
						// -> Pega datas de entregas Firmes
						For nu:=1 to Len(aAuxDias)
							While StrZero(Dow(dAux),2) <> StrZero(Val(aAuxDias[nu]),2)
								dAux:=dAux+1
							EndDo
							AADD(aDataProx,dtos(dAux)   +"F" )
						Next nu

						// -> Pega datas de entregas previstas 01
						dAux:=StoD(SubStr(aDataProx[Len(aDataProx)],1,8))
						For nu:=1 to Len(aAuxDias)
							While StrZero(Dow(dAux),2) <> StrZero(Val(aAuxDias[nu]),2)
								dAux:=dAux+1
							EndDo
							AADD(aDataProx,dtos(dAux)   +"P" )
						Next nu

						// -> Pega datas de entregas previstas 02
						dAux:=StoD(SubStr(aDataProx[Len(aDataProx)],1,8))
						For nu:=1 to Len(aAuxDias)
							While StrZero(Dow(dAux),2) <> StrZero(Val(aAuxDias[nu]),2)
								dAux:=dAux+1
							EndDo
							AADD(aDataProx,dtos(dAux)   +"P" )
						Next nu

						// -> Pega datas de entregas previstas 03
						dAux:=StoD(SubStr(aDataProx[Len(aDataProx)],1,8))
						For nu:=1 to Len(aAuxDias)
							While StrZero(Dow(dAux),2) <> StrZero(Val(aAuxDias[nu]),2)
								dAux:=dAux+1
							EndDo
							AADD(aDataProx,dtos(dAux)   +"P" )
						Next nu

					EndIf
				
				EndIf

				//#TB20200320 Thiago Berna - Identifica de há calendario F(Firme) ou P(Previsto)
				If Len(aDataProx) > 1
					dDataNova:= StoD(SubStr(aDataProx[Len(aDataProx)-1],1,8)) 
					AADD(aCalendar,{ Z22->Z22_FILIAL+Z22->Z22_CODUN+Z22->Z22_FORN+Z22->Z22_LOJA+Z22->Z22_GRUPO , Z22->Z22_TIPO , cDias , dAuxIni , dDataNova , Z22->(Recno()) , dDataProx , dDtProxP , aDataProx })
				EndIf
				aDataProx 	:= {} // limpa o array para o proxima data no acalendar 

			Endif

		EndIf

		Z22->(DbSkip())

	EndDo

Return(aCalendar)