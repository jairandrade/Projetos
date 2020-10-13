#Include "Protheus.ch"                                     
#Include "TopConn.CH"
#Include "TBICONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! COM105 - Cliente: Madero                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Geracao de Pedidos de Compra nos Restaurantes           !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 23/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function COM105(paramixb)
Local cAliTmp0  :=GetNextAlias()
Local cAliTmp1  :=GetNextAlias()
Local aRecSC7   := {}
Local aCabecSC7 := {}
Local aItensSC7 := {}
Local cPathTmp  := "\temp\"
Local cAuxLog   := ""
Local aAuxErro  := {}
Local nx		:= 0
Local ny        := 0
Local nAux      := 0  
Local aRetSA5   := {}
Local dDtCalc   := paramixb[1]
Local cEmpresa  := paramixb[2]
Local cUndMad   := paramixb[3]
Local cForm  	:= ""
Local cLoj  	:= ""
Local cGrpCom   := ""
Local sDtEnt	:= ""
Local cProd     := ""
Local cCodtab   := ""
Local cCCusto   := ""
Local aRetAux   := {}
Local aCalendFor:= {}
Local aCalend   := {}
Local cxUser    := "MRP"
Local nAuxMod   := paramixb[4]
Local cAuxFun   := FunName()
Local cNumPed   := "" 
Local cChave 
Local cItem
Local aPedidos  := {}
Local lErro     := .F.
Private lMsErroAuto := .F.	
Private cxNUserSC7  := "ressuprimento"

	cAuxLog:="MRP | " + ": Posiciona no usuario do processo..." 
	ConOut(cAuxLog)
	nModulo  :=2
	SetFunName("MATA120")

	cAuxLog:="MRP | " + ": Selecionando necessidades de compras..." 
	ConOut(cAuxLog)

	// -> Fecha Alias da query
	If Select(cAliTmp0) > 0
		DbSelectArea(cAliTmp0)
		DbCloseArea()
	EndIf

	cQuery:="SELECT   Z25_FILIAL, Z25_DATA, Z25_DTENTR, Z25_DTNXEN, Z25_CODFOR, Z25_CODLOJ, Z25_GRPCOM, Z25_PRODUT, Z25_CODTAB, Z25_CC, Z25_TES, SUM(Z25_QUANT) Z25_QUANT, (SUM(Z25_VALOR)/COUNT(*)) Z25_VALOR "
	cQuery+="FROM " + RetSQLName("Z25") + " Z25 "
	cQuery+="WHERE Z25.Z25_FILIAL   = '" + cUndMad       + "' AND " 
	cQuery+="      Z25.Z25_DATA     = '" + DToS(dDtCalc) + "' AND " 
	cQuery+="      Z25.Z25_PEDIDO   = ' '                     AND " 
	cQuery+="      Z25.Z25_DTENTR  <> ' '                     AND " 
	cQuery+="      Z25.Z25_TIPOPC   = 'F'                     AND " 
	cQuery+="      Z25.Z25_QUANT    > 0                       AND "	

	//#TB20200414 Thiago Berna - Ajuste para considerar somente os registros com origem 1 - MRP
	cQuery+="      Z25.Z25_ORIGEM    IN  ('1')                AND "

	cQuery+="      Z25.D_E_L_E_T_  <> '*'                         "
	cQuery+="GROUP BY Z25_FILIAL, Z25_DATA, Z25_DTENTR, Z25_DTNXEN, Z25_CODFOR, Z25_CODLOJ, Z25_GRPCOM, Z25_PRODUT, Z25_CODTAB, Z25_CC, Z25_TES "
	cQuery+="ORDER BY Z25_FILIAL, Z25_DATA, Z25_DTENTR, Z25_DTNXEN, Z25_CODFOR, Z25_CODLOJ, Z25_GRPCOM                                          "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTmp0,.T.,.T.)				
	(cAliTmp0)->(DbGoTop())

	dDataBase:=dDtCalc
	cAuxLog  :="MRP | " + "Ok." 
	ConOut(cAuxLog)
		
	Begin Transaction
	
		aCalend := {}
		lErro   := .F.
		While !(cAliTmp0)->(eof())
			
			// -> Inicializa dados do pedido de compra
			cFilEnt  := (cAliTmp0)->Z25_FILIAL
			sDtEnt	 := (cAliTmp0)->Z25_DTENTR
			cForm  	 := (cAliTmp0)->Z25_CODFOR
			cLoj  	 := (cAliTmp0)->Z25_CODLOJ
			cGrpCom  := (cAliTmp0)->Z25_GRPCOM
			cProd    := (cAliTmp0)->Z25_PRODUT
			cCodtab  := (cAliTmp0)->Z25_CODTAB
			cCCusto  := (cAliTmp0)->Z25_CC
			cItem 	 := '0001'
			aCabecSC7:= {}
			aItensSC7:= {}
			lErro    := .F.
			cChave   := cFilEnt+cForm+cLoj+cGrpCom
			
			// -> Atualizar data de proxima entrega
			nAux:=aScan(aCalend,{|xpz| xpz[1] == xFilial("Z22")+cFilEnt+cForm+cLoj+cGrpCom})
			If nAux <=0 
				AADD(aCalend,{xFilial("Z22")+cFilEnt+cForm+cLoj+cGrpCom,StoD((cAliTmp0)->Z25_DTENTR),"",StoD((cAliTmp0)->Z25_DTNXEN)})
			EndIf
			
			// -> Atualiza calendário do fornecedor
			nAux:=aScan(aCalendFor,{|xpx| xpx[1] == xFilial("Z22")+cFilEnt+cForm+cLoj})
			If nAux <=0 
				AADD(aCalendFor,{xFilial("Z22")+cFilEnt+cForm+cLoj})
			EndIf
		
			// -> Gera numero do pedido de compra
			cNumPed:=GetSXENum("SC7","C7_NUM")
			
			// -> Posiciona no Fornecedor
			DbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			SA2->(dbSeek(xFilial("SA2")+cForm+cLoj))			

			// -> Posiciona na tabela de preco
			DbSelectArea("SE4")
			SE4->(dbSetOrder(1))
			SE4->(dbSeek(xFilial("SE4")+SA2->A2_COND))			

			aadd(aCabecSC7,{"C7_NUM"     , cNumPed       ,Nil})
			aadd(aCabecSC7,{"C7_EMISSAO" , dDataBase     ,Nil})
			aadd(aCabecSC7,{"C7_FORNECE" , SA2->A2_COD   ,Nil})
			aadd(aCabecSC7,{"C7_LOJA"    , SA2->A2_LOJA  ,Nil})
			aadd(aCabecSC7,{"C7_COND"    , SE4->E4_CODIGO,Nil})
			aadd(aCabecSC7,{"C7_FILENT"  , cFilAnt       ,Nil})
			aadd(aCabecSC7,{"C7_CONTATO" , " "           ,Nil})
			aadd(aCabecSC7,{"C7_MOEDA"    , 01           ,Nil})

			cAuxLog:="MRP | " + ":"+DtoC(StoD(sDtEnt))+":"+cForm+cLoj+":"+cGrpCom+": Gerando pedido "+cNumPed+"..." 
			ConOut(cAuxLog)

			While !(cAliTmp0)->(eof()) .and. (cAliTmp0)->Z25_FILIAL == cFilEnt .and. (cAliTmp0)->Z25_DATA == DToS(dDtCalc) .and. (cAliTmp0)->Z25_DTENTR == sDtEnt .and. (cAliTmp0)->Z25_CODFOR == cForm .and. (cAliTmp0)->Z25_CODLOJ == cLoj .and. (cAliTmp0)->Z25_GRPCOM == cGrpCom

				aRecSC7:={} 
				aAdd(aPedidos,{(cAliTmp0)->Z25_FILIAL,(cAliTmp0)->Z25_DATA,(cAliTmp0)->Z25_DTENTR,(cAliTmp0)->Z25_CODFOR,(cAliTmp0)->Z25_CODLOJ,(cAliTmp0)->Z25_GRPCOM,""})

				// -> Posiciona no cadastro de produtos
				DbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+(cAliTmp0)->Z25_PRODUT))  					
  					
				// -> Posiciona no cadastro de grupos de compras
				DbSelectArea("SAJ")
				SAJ->(DbSetOrder(1))
				SAJ->(DbSeek(xFilial("SAJ")+(cAliTmp0)->Z25_GRPCOM))
										
				// -> Calcula a quantidade a ser enviada para o fornecedor, conforme dados da tabela SA5
				aRetSA5:=u_C104PRF((cAliTmp0)->Z25_QUANT,(cAliTmp0)->Z25_CODFOR,(cAliTmp0)->Z25_CODLOJ,(cAliTmp0)->Z25_PRODUT,.F.,.F.,cUndMad)
				If aRetSA5[1] <= 0
					lErro:=.T.
					Aadd(aAuxErro,{"Execucao","MRP | Erro: Verifique cadastro de produtos x fornecedor. Retornou uma quantidade zerada para o item "+(cAliTmp0)->Z25_PRODUT,"","","","",""})					
				EndIf	

				aadd(aRecSC7,{"C7_ITEM"			, cItem,	        		Nil})
				aadd(aRecSC7,{"C7_PRODUTO"		, (cAliTmp0)->Z25_PRODUT,	Nil})					
				If aRetSA5[2] > 0 
					aadd(aRecSC7,{"C7_XUNPRF"	, aRetSA5[3],				Nil})
					aadd(aRecSC7,{"C7_XQTDPRF"	, aRetSA5[1],				Nil})
					aadd(aRecSC7,{"C7_UM"		, SB1->B1_UM,				Nil})
					aadd(aRecSC7,{"C7_QUANT"	, aRetSA5[2],				Nil})													
				Else
					aadd(aRecSC7,{"C7_XUNPRF"	, SB1->B1_UM,				Nil})
					aadd(aRecSC7,{"C7_XQTDPRF"	, aRetSA5[1],				Nil})
					aadd(aRecSC7,{"C7_UM"		, SB1->B1_UM,				Nil})
					aadd(aRecSC7,{"C7_QUANT"	, aRetSA5[1],				Nil})													
				EndIf	
				aadd(aRecSC7,{"C7_PRECO"		, (cAliTmp0)->Z25_VALOR,	Nil})
				aadd(aRecSC7,{"C7_CC"		    , (cAliTmp0)->Z25_CC,		Nil})
				aadd(aRecSC7,{"C7_CODTAB"	    , (cAliTmp0)->Z25_CODTAB,	Nil})
				aadd(aRecSC7,{"C7_LOCAL"		, SB1->B1_LOCPAD,    		Nil}) 
				aadd(aRecSC7,{"C7_TES"			, (cAliTmp0)->Z25_TES,		Nil})
				aadd(aRecSC7,{"C7_XENVCR"   	, "P",              		Nil})
				aadd(aRecSC7,{"C7_XEMAIL"   	, " ",              		Nil})
				aadd(aRecSC7,{"C7_DATPRF"		, StoD(sDtEnt),	            Nil})
				aadd(aRecSC7,{"C7_XDTINC"   	, dDataBase, 				Nil})
				aadd(aRecSC7,{"C7_XGRMRP"   	, (cAliTmp0)->Z25_GRPCOM,   Nil})
				aadd(aRecSC7,{"C7_XDTALT"   	, ctod(""), 				Nil})
				aadd(aRecSC7,{"C7_ACCPROC"  	, "2", 						Nil})
				aadd(aRecSC7,{"C7_XUSERI"   	, cxNUserSC7, 	    		Nil})
				aadd(aRecSC7,{"C7_XDTEXPV"  	, ctod(""), 				Nil})
				aadd(aRecSC7,{"C7_XUSEREX"  	, "", 						Nil})
				cItem := Soma1(cItem)
				aadd(aItensSC7, aRecSC7)

				(cAliTmp0)->(DbSkip())
				
			EndDo
			
			cFilEnt  := (cAliTmp0)->Z25_FILIAL		
			sDtEnt	 := (cAliTmp0)->Z25_DTENTR
			cForm  	 := (cAliTmp0)->Z25_CODFOR
			cLoj  	 := (cAliTmp0)->Z25_CODLOJ
			cGrpCom  := (cAliTmp0)->Z25_GRPCOM			
			
			// -> Grava pedido de compra
			If Len(aItensSC7) >0 .and. Len(aCabecSC7) > 0 .and. !lErro
				DbSelectArea("SC7")
				SC7->(DbSetOrder(1))
				lMsErroAuto := .F.
				MATA120(1,aCabecSC7,aItensSC7,3)
				If lMsErroAuto
					lErro   := .T.
					cAuxLog := "pc_"+cUndMad+"_"+AllTrim(cChave)+"_"+strtran(time(),":","")
					lErro   := .T.
					MostraErro(cPathTmp, cAuxLog)
					ConOut("MRP | " + "Erro: Verifique aquivo "+cPathTmp+cAuxLog)
					Aadd(aAuxErro,{"Execucao","MRP | Erro: Verifique aquivo "+cPathTmp+cAuxLog,"","","","",""})					
					DisarmTransaction()
					Break
				Else
					nAux:=aScan(aCalend,{|xpz| xpz[1] == xFilial("Z22")+SC7->C7_FILENT+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_XGRMRP})
					If nAux > 0 
						aCalend[nAux,03]:=SC7->C7_NUM
					EndIf
					// -> Atualiza tabela Z25 com os pedidos gerados
					For ny:=1 to Len(aPedidos)

						If Empty(aPedidos[ny,07])
							aPedidos[ny,07]:=SC7->C7_NUM
						EndIf

					Next ny
										
					Aadd(aAuxErro,{"Execucao","MRP | " + "Ok.","","","","",""})					
					ConOut("MRP | " + "Ok.")
				Endif								 				
			EndIf
			
		EndDo

		// -> Atualiza dados na tabela de necessidades
		For ny:=1 to Len(aPedidos) 

			// -> Fecha Alias da query
			If Select(cAliTmp1) > 0
				DbSelectArea(cAliTmp1)
				DbCloseArea()
			EndIf

			cQuery:="SELECT R_E_C_N_O_ REC "
			cQuery+="FROM " + RetSQLName("Z25") + " Z25 "
			cQuery+="WHERE Z25.Z25_FILIAL   = '" + aPedidos[ny,01] + "' AND " 
			cQuery+="      Z25.Z25_DATA     = '" + aPedidos[ny,02] + "' AND " 
			cQuery+="      Z25.Z25_DTENTR   = '" + aPedidos[ny,03] + "' AND " 
			cQuery+="      Z25.Z25_CODFOR   = '" + aPedidos[ny,04] + "' AND " 
			cQuery+="      Z25.Z25_CODLOJ   = '" + aPedidos[ny,05] + "' AND " 
			cQuery+="      Z25.Z25_GRPCOM   = '" + aPedidos[ny,06] + "' AND " 
			cQuery+="      Z25.Z25_DTENTR  <> ' '                       AND " 
			cQuery+="      Z25.Z25_TIPOPC   = 'F'                       AND " 
			cQuery+="      Z25.Z25_QUANT    > 0                         AND "	
			cQuery+="      Z25.D_E_L_E_T_  <> '*'                           "
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTmp1,.T.,.T.)				
	
			(cAliTmp1)->(DbGoTop())
			While !(cAliTmp1)->(Eof())

				Z25->(DbGoTo((cAliTmp1)->REC))					
				RecLock("Z25",.F.)
				Z25->Z25_PEDIDO:=aPedidos[ny,07]
				Z25->(MsUnlock())

				(cAliTmp1)->(DbSkip())

			EndDo

		Next ny	

		// -> Aualiza calendário de entrega
		If !lErro
			Aadd(aAuxErro,{"Calendario de entrega:","MRP | " + "Atualizando calendario de entrega...","","","","",""})					
			aRetAux:=atuZ22(aCalend,u_EST100C(cUndMad))
			lErro  :=aRetAux[2]
			aadd(aAuxErro,aRetAux[1])
		EndIf	

		If lErro
			Aadd(aAuxErro,{"Execucao","MRP | " + "Erro.","","","","",""})					
			ConOut("MRP | " + "Erro.")
			DisarmTransaction()
		EndIf	

	End Transaction
	
	(cAliTmp0)->(DbCloseArea())
		
		
	nModulo:=nAuxMod
	SetFunName(cAuxFun)
			
			
Return({aAuxErro,lErro})


/*-----------------+---------------------------------------------------------+
!Nome              ! atuZ22 - Cliente: Madero                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Atualizacao da data e Compra do Fornecedor X Grupo Prod !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 28/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function atuZ22(aCalend,aCalendFor)
Local aAreaZ22  := GetArea()
Local aEntregas := {}
Local dUltEmt   := CToD("  /  /  ") 
Local dProxEmt  := CToD("  /  /  ")
Local lErro     := .F.
Local aErro     := {}
Local cAuxLog   := ""
Local cPed      := ""
Local nAuxZ22   := 0
Local nk,nu     := 0
Local aAuxDias  := {}
Local nAuxDias  := 0

	// -> Atualiza calendário
	For nk:=1 to Len(aCalendFor)
		// -> Posiciona no calendário
		DbSelectArea("Z22")
		Z22->(DbGoTo(aCalendFor[nk,6]))

		cAuxLog:= "MRP | " + ":"+Z22->Z22_CODUN+":"+Z22->Z22_FORN+":"+Z22->Z22_LOJA+": Atualizando calendario de entregas."
		Aadd(aErro,{"Calendario de entrega:",cAuxLog,"","","","",""})
		ConOut(cAuxLog)

		// -> Pega a últimaentrega firme e a próxima revista
		aEntregas:=aCalendFor[NK][09]
		aAuxDias :=StrToKarr(alltrim(Z22->Z22_DIA),",")
		nAuxDias :=Len(aAuxDias)
		For nu:=1 to Len(aEntregas)
			If SubStr(aEntregas[nu],9,1) == "F"
				nAuxDias:=nAuxDias-1
				dUltEmt :=SToD(SubStr(aEntregas[nu],1,8))
				dProxEmt:=SToD(SubStr(aEntregas[nu+1],1,8))
			EndIf	
		Next nu

		cPed   :="SEMPEDIDO"
		nAuxZ22:=aScan(aCalend,{|xp1| xp1[1] == xFilial("Z22")+Z22->Z22_CODUN+Z22->Z22_FORN+Z22->Z22_LOJA+Z22->Z22_GRUPO})
		If nAuxZ22 > 0 
			cPed:=aCalend[nAuxZ22,3]
		EndIf
		
		//#TB20200310 Thiago Berna - Ajuste para considerar corretamente as datatas quando ocorre quebra quinzenal
		If (IIF(Z22->Z22_TIPO == "Q",dUltEmt + 14,IIF(Z22->Z22_TIPO == "S",dUltEmt+7,MonthSum(dUltEmt,1))) >= Z22->Z22_DTNXEN) .Or. Z22->Z22_TIPO == "S"
			
			// -> Atualiza o calendário
			/*Z22->(RecLock("Z22",.F.))
			Z22->Z22_DTULEN:=dUltEmt
			Z22->Z22_DTNXEN:=dProxEmt		
			Z22->Z22_NUMPC :=cPed
			Z22->(MsUnlock())*/

			If Z22->Z22_TIPO == "Q"
				// -> Atualiza o calendário Quinzenal
				Z22->(RecLock("Z22",.F.))
				Z22->Z22_DTULEN:=Z22->Z22_DTNXEN
				Z22->Z22_DTNXEN:=Z22->Z22_DTNXEN + 14		
				Z22->Z22_NUMPC :=cPed
				Z22->(MsUnlock())
			ElseIf Z22->Z22_TIPO == "S"
				// -> Atualiza o calendário Semanal
				Z22->(RecLock("Z22",.F.))
				Z22->Z22_DTULEN:=Z22->Z22_DTNXEN
				Z22->Z22_DTNXEN:=Z22->Z22_DTNXEN + 7		
				Z22->Z22_NUMPC :=cPed
				Z22->(MsUnlock())
			Else
				// -> Atualiza o calendário Mensal
				Z22->(RecLock("Z22",.F.))
				Z22->Z22_DTULEN:=Z22->Z22_DTNXEN
				Z22->Z22_DTNXEN:=MonthSum(Z22->Z22_DTNXEN,1)	
				Z22->Z22_NUMPC :=cPed
				Z22->(MsUnlock())
			EndIf
		EndIf
	Next nk
	
	RestArea(aAreaZ22)

return({aErro,lErro})