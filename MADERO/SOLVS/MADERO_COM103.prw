#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "TryException.ch"
#Include "rwmake.ch"
#Include "TBICONN.CH"

/*-----------------+---------------------------------------------------------+
!Nome              ! COM103 - Cliente: Madero                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Gerar pedidos de venda na central                       !
+------------------+---------------------------------------------------------+
!Autor             ! Pedro A. de Souza                                       !
+------------------+---------------------------------------------------------!
!Data              ! 28/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function COM103(paramixb)
	// Parametros recebidos da rotina "pai"
	Local _cEmpresa := paramixb[1,01] // Empresa destino (da fábrica)
	Local _cFilial  := paramixb[1,02] // Filial destino (da fábrica)
	Local cGrupoEmp := paramixb[1,03] // Grupo de Empresas originais (de onde buscar os PCs - obtido a partir do cEmpAnt) 
	Local cFilOri   := paramixb[1,04] // Filial Original do Pedido
	Local cCNPJCli  := paramixb[1,05] // CNPJ do cliente do Pedido
	Local dDataInc  := paramixb[1,07] // Data de inclusao do pedido
	Local cUsrincl  := paramixb[1,08] // Usuario de inclusao do pedido
	Local cGRCDe	:= paramixb[1,09] // Filtro Grupo de Compras de
	Local cGRCAte	:= paramixb[1,10] // Filtro Grupo de Compras ate
	Local dDataDe	:= paramixb[1,11] // Filtro Data entrega de
	Local dDataAte	:= paramixb[1,12] // Filtro Data Entrega ate
	Local cNumPed   := "" 
	Local cAliTmp0  := GetNextAlias()
	Local cOpVdaUN  := ""
	Local cQuery    := ""
	Local cQrySA5   := ""
	Local aLinha    := {}
	Local aItens    := {}
	Local aCabec    := {}
	Local aRetCM103 := {}
	Local aDados	:= paramixb
	Local nDados	:= 0	
	Local cPathTmp  := "\temp\"
	Local cFileErr  := ""
	Local cTes      := ""
	Local nk        := 0 
	Local nY        := 0
	Local nPos      := 0
	Local cItemSC6  := "01"
	Local aQuery    := {}
	Local cNumPedAux:= ""
	Local cTpConv   := ""
	Local aTables   := {"SA1","SA2","SA3","SA4","SB1","SB2","SC2","SC3","SC4","SC6","SED","SE4","SX5","SBM"}
	Local lProx     := .F.
	Local dProxDat
	Local dDatAux
	Local cPedAux
	Local cQuerySBE	:= ''
	Local cAliasSBE	:= GetNextAlias()
	Local cLocaliz	:= ''
	Local cFilMad	:= ''
	Local cTesFil   := ''
	Private lMsErroAuto := .f. 

	//#TB20191120 Thiago Berna - Ajuste para considerar mais de uma filial
	For nDados := 1 to Len(aDados)

		_cEmpresa 	:= aDados[nDados,01] // Empresa destino (da fábrica)
		_cFilial  	:= aDados[nDados,02] // Filial destino (da fábrica)
		cGrupoEmp 	:= aDados[nDados,03] // Grupo de Empresas originais (de onde buscar os PCs - obtido a partir do cEmpAnt) 
		cFilOri   	:= aDados[nDados,04] // Filial Original do Pedido
		cCNPJCli  	:= aDados[nDados,05] // CNPJ do cliente do Pedido
		cNumPed 	:= aDados[nDados,06] // Pedidos
		dDataInc  	:= aDados[nDados,07] // Data de inclusao do pedido
		cUsrincl  	:= aDados[nDados,08] // Usuario de inclusao do pedido
		cGRCDe		:= aDados[nDados,09] // Filtro Grupo de Compras de
		cGRCAte		:= aDados[nDados,10] // Filtro Grupo de Compras ate
		dDataDe		:= aDados[nDados,11] // Filtro Data entrega de
		dDataAte	:= aDados[nDados,12] // Filtro Data Entrega ate

		// -> Agura numero de pedidos de compra
		AADD(aRetCM103,{})
		AADD(aRetCM103,{})

		If len(cGrupoEmp) = 2
			cGrupoEmp += "0"
		Endif
		ConOut(cGrupoEmp)
		RpcSetType( 3 )
		RpcSetEnv( _cEmpresa,_cFilial, , , "FAT", , aTables, , , ,  )
		// -> Verifica operação fiscal
		cOpVdaUN:=GetMv("MV_XOPVDUN",,"")
		If AllTrim(cOpVdaUN) == ""
			aadd(aRetCM103[1],{cFilOri,"TODOS","FIS","","Operacao fisval invalida. [MV_XOPVDUN = Vazio]",cFilOri+"TODOS"})
		EndIf

		// -> Posiciona no cliente
		SA1->(DbSetOrder(3))
		If !SA1->(DbSeek(xFilial("SA1")+cCNPJCli))
			aadd(aRetCM103[1],{cFilOri,"TODOS","SA1","","Cliente nao encontrado: [A1_CGC = " + cCNPJCli+"]",cFilOri+"TODOS"})
		Else
			// -> Posiciona na natureza
			SED->(DbSetOrder(1))
			If !SED->(DbSeek(xFilial("SED")+SA1->A1_NATUREZ))
				aadd(aRetCM103[1],{cFilOri,"TODOS","SA1",SA1->A1_COD+SA1->A1_LOJA,"Natureza nao encontrada na industria: [A1_NATUREZ = " + SA1->A1_NATUREZ+"]",cFilOri+"TODOS"})
			EndIf

			// -> Posiciona na condicao de pagamento
			SE4->(DbSetOrder(1))
			If !SE4->(DbSeek(xFilial("SE4")+SA1->A1_COND))
				aadd(aRetCM103[1],{cFilOri,"TODOS","SA1",SA1->A1_COD+SA1->A1_LOJA,"Condicao de pagamento nao encontrada na industria: [A1_COND = " + SA1->A1_COND+"]",cFilOri+"TODOS"})
			EndIf

			// -> Posiciona no vendedor
			SA3->(DbSetOrder(1))
			If !SA3->(DbSeek(xFilial("SA3")+SA1->A1_VEND))
				aadd(aRetCM103[1],{cFilOri,"TODOS","SA1",SA1->A1_COD+SA1->A1_LOJA,"Vendedor nao encontrado na industria: [A1_VEND = " + SA1->A1_VEND+"]",cFilOri+"TODOS"})
			EndIf

			// -> Posiciona na transportadora
			SA4->(DbSetOrder(1))
			If !SA4->(DbSeek(xFilial("SA4")+SA1->A1_TRANSP))
				aadd(aRetCM103[1],{cFilOri,"TODOS","SA1",SA1->A1_COD+SA1->A1_LOJA,"Transportadora nao encontrada na industria: [A1_TRANSP = " + SA1->A1_TRANSP+"]",cFilOri+"TODOS"})
			EndIf
		EndIf

		If Len(aRetCM103[1]) <= 0
			aQuery := STRTOKARR(cNumPed, ",")
			cNumPedAux := ""
			If Len(aQuery) <= 500
				//#TB20191121 Thiago Berna - Ajuste para considerar tyodos os numeros de pedidos corretamente quando ocorre a selecao de mais de uma filial
				/*For nk:=1 to Len(paramixb)
					cNumPedAux:=cNumPedAux+"'"+paramixb[nk,6]+"',"
				Next nk 
				cNumPedAux:=IIF(Empty(cNumPedAux),"'ZZZZZZ'",SubStr(cNumPedAux,1,Len(cNumPedAux)-1))*/
				cNumPedAux := cNumPed
				     
				cQuery  := "SELECT C7_FILIAL, C7_NUM, C7_ITEM, C7_PRODUTO, C7_XCODPRF, C7_DATPRF, C7_XOBS, C7_FORNECE, SUM(C7_QUANT) C7_QUANT, SUM(C7_PRECO)/COUNT(*) C7_PRECO, SUM(C7_XQTDPRF) C7_XQTDPRF " //A5_XTPCUNF, A5_XCVUNF"
				cQuery  += " FROM SC7" + cGrupoEmp + " SC7 "

				// --> Ajuste para considerar os filtros de grupo de compra e data de entrega
				cQuery += " INNER JOIN SB1" +cGrupoEmp + " SB1        "
				cQuery += "ON SB1.B1_FILIAL    = '" + cFilOri + "' AND " 
				cQuery += "     SB1.B1_COD     = SC7.C7_PRODUTO           AND "
				cQuery += "     SB1.D_E_L_E_T_ = ' '                          " 

				cQuery  += " WHERE SC7.C7_FILIAL  = '" + cFilOri + "' "
				cQuery  += "   AND SC7.C7_NUM    IN (" + cNumPedAux + ") "
				cQuery  += "   AND SC7.D_E_L_E_T_ = ' '  
				
				// --> Ajuste para considerar os filtros de grupo de compra e data de entrega
				cQuery += "    AND SB1.B1_GRUPCOM BETWEEN '" + cGRCDe 	     + "' AND '" + cGRCAte 		  + "' "
				cQuery += "    AND SC7.C7_DATPRF  BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' "
							
				cQuery  += " GROUP BY C7_FILIAL, C7_NUM, C7_ITEM, C7_PRODUTO, C7_XCODPRF, C7_DATPRF, C7_XOBS, C7_FORNECE"
				
				//#TB20191125 - Thiago Berna - Ajuste feito pelo Alexandre Contim
				cQuery  += " ORDER BY C7_FILIAL, C7_DATPRF "
			Else
				nPos        := 1
				cNumPedAux  := ""
				cQuery      := ""
				For nY:=1 to Len(aQuery)
					If nPos < 500 .And. nY < Len(aQuery)
						cNumPedAux:=cNumPedAux+aQuery[nY]+","
						nPos := nPos + 1
					Else
						If nY == Len(aQuery)
							cNumPedAux:=cNumPedAux+aQuery[nY]
						Else
							cNumPedAux:=SubStr(cNumPedAux,1,Len(cNumPedAux)-1)
						EndIf
						If nY <= 500
							cQuery  := "SELECT C7_FILIAL, C7_NUM, C7_ITEM, C7_PRODUTO, C7_XCODPRF, C7_DATPRF, C7_XOBS, C7_FORNECE, SUM(C7_QUANT) C7_QUANT, SUM(C7_PRECO)/COUNT(*) C7_PRECO, SUM(C7_XQTDPRF) C7_XQTDPRF " //A5_XTPCUNF, A5_XCVUNF"
							cQuery  += " FROM SC7" + cGrupoEmp + " SC7 "

							// --> Ajuste para considerar os filtros de grupo de compra e data de entrega
							cQuery += " INNER JOIN SB1" +cGrupoEmp + " SB1        "
							cQuery += "ON SB1.B1_FILIAL    = '" + cFilOri + "' AND " 
							cQuery += "     SB1.B1_COD     = SC7.C7_PRODUTO           AND "
							cQuery += "     SB1.D_E_L_E_T_ = ' '                          " 

							cQuery  += " WHERE SC7.C7_FILIAL  = '" + cFilOri + "' "
							cQuery  += "   AND SC7.C7_NUM    IN (" + cNumPedAux + ") "
							cQuery  += "   AND SC7.D_E_L_E_T_ = ' '               "

							// --> Ajuste para considerar os filtros de grupo de compra e data de entrega
							cQuery += "    AND SB1.B1_GRUPCOM BETWEEN '" + cGRCDe 	     + "' AND '" + cGRCAte 		  + "' "
							cQuery += "    AND SC7.C7_DATPRF  BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' "
				
							cQuery  += " GROUP BY C7_FILIAL, C7_NUM, C7_ITEM, C7_PRODUTO, C7_XCODPRF, C7_DATPRF, C7_XOBS, C7_FORNECE"
							
							//#TB20191125 - Thiago Berna - Ajuste feito pelo Alexandre Contim
							cQuery  += " ORDER BY C7_FILIAL, C7_DATPRF "
						Else
							cQuery  += " UNION ALL "
							cQuery  += "SELECT C7_FILIAL, C7_NUM, C7_ITEM, C7_PRODUTO, C7_XCODPRF, C7_DATPRF, C7_XOBS, C7_FORNECE, SUM(C7_QUANT) C7_QUANT, SUM(C7_PRECO)/COUNT(*) C7_PRECO, SUM(C7_XQTDPRF) C7_XQTDPRF " //A5_XTPCUNF, A5_XCVUNF"
							cQuery  += " FROM SC7" + cGrupoEmp + " SC7 "

							// --> Ajuste para considerar os filtros de grupo de compra e data de entrega
							cQuery += " INNER JOIN SB1" +cGrupoEmp + " SB1        "
							cQuery += "ON SB1.B1_FILIAL    = '" + cFilOri + "' AND " 
							cQuery += "     SB1.B1_COD     = SC7.C7_PRODUTO           AND "
							cQuery += "     SB1.D_E_L_E_T_ = ' '                          " 

							cQuery  += " WHERE SC7.C7_FILIAL  = '" + cFilOri + "' "
							cQuery  += "   AND SC7.C7_NUM    IN (" + cNumPedAux + ") "
							cQuery  += "   AND SC7.D_E_L_E_T_ = ' '               "

							// --> Ajuste para considerar os filtros de grupo de compra e data de entrega
							cQuery += "    AND SB1.B1_GRUPCOM BETWEEN '" + cGRCDe 	     + "' AND '" + cGRCAte 		  + "' "
							cQuery += "    AND SC7.C7_DATPRF  BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAte) + "' "

							cQuery  += " GROUP BY C7_FILIAL, C7_NUM, C7_ITEM, C7_PRODUTO, C7_XCODPRF, C7_DATPRF, C7_XOBS, C7_FORNECE"
							
							//#TB20191125 - Thiago Berna - Ajuste feito pelo Alexandre Contim
							cQuery  += " ORDER BY C7_FILIAL, C7_DATPRF "
						EndIf
						cNumPedAux := ""
						nPos := 1
					EndIf
				Next nY
			EndIf

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliTmp0,.T.,.T.)
			(cAliTmp0)->(dbGoTop())

			dDatAux := (cAliTmp0)->C7_DATPRF
			cPedAux := (cAliTmp0)->C7_NUM
			
			//#TB20191125 - Thiago Berna - Ajuste feito pelo Alexandre Contim
			cFilMad := (cAliTmp0)->C7_FILIAL

			While !(cAliTmp0)->(eof())
						
				aItens := {}
				aCabec := {}
				aAdd(aCabec, {"C5_TIPO"     , "N"                           , Nil})
				aAdd(aCabec, {"C5_CLIENTE"  , SA1->A1_COD                   , Nil})
				aAdd(aCabec, {"C5_LOJACLI"  , SA1->A1_LOJA                  , Nil})
				aAdd(aCabec, {"C5_TRANSP"   , SA4->A4_COD                   , Nil})
				aAdd(aCabec, {"C5_CONDPAG"  , SE4->E4_CODIGO                , Nil})
				aAdd(aCabec, {"C5_EMISSAO"  , dDataBase                     , Nil})
				aAdd(aCabec, {"C5_NATUREZ"  , SED->ED_CODIGO                , Nil})
				aAdd(aCabec, {"C5_TPFRETE"  , 'C'                           , Nil})
				aAdd(aCabec, {"C5_TRANSP"   , SA4->A4_COD                   , Nil})
				aAdd(aCabec, {"C5_TPCARGA"  , "1"                           , Nil})
				aAdd(aCabec, {"C5_XDTINC"   , dDataInc                      , Nil})
				aAdd(aCabec, {"C5_XUSERI"   , cUsrincl                      , Nil})
				cTes        :=""
				lOk         :=.T.
				cItemSC6    :="01"
				lProx       := .T.

				dDatAux := (cAliTmp0)->C7_DATPRF
				cPedAux := (cAliTmp0)->C7_NUM
				cFilMad := (cAliTmp0)->C7_FILIAL
				While (cAliTmp0)->C7_DATPRF == dDatAux .And. !(cAliTmp0)->(eof()) .And. cFilMad == (cAliTmp0)->C7_FILIAL

					// -> Inicia geração dos logs 
					nAux:=aScan(aRetCM103[1],{|x| Alltrim(x[3]) == "SB1" .and. AllTrim(x[4]) == AllTrim((cAliTmp0)->C7_XCODPRF)})               
					SB1->(dbSetOrder(1))                
					If !SB1->(dbSeek(xFilial("SB1")+(cAliTmp0)->C7_XCODPRF))
						aadd(aRetCM103[1],{cFilOri,(cAliTmp0)->C7_NUM,"SB1",(cAliTmp0)->C7_XCODPRF,"Produto nao encontrado no cadastro da industria.",cFilOri+(cAliTmp0)->C7_NUM})
						lOk:=.F.   
					Else
						// -> Pega a TES da operação
						cTes:=MaTESInt(2,cOpVdaUN,SA1->A1_COD,SA1->A1_LOJA,"C",SB1->B1_COD)
						
						SF4->(dbSetOrder(1))
						If !SF4->(dbSeek(xFilial("SF4")+cTes))
							aadd(aRetCM103[1],{cFilOri,(cAliTmp0)->C7_NUM,"SB1",(cAliTmp0)->C7_XCODPRF,"TES nao encontrada para o produto. [F4_CODIGO = "+cTes+"]",cFilOri+(cAliTmp0)->C7_NUM})
							lOk:=.F.
						EndIf
						// -> Verifica a quantidade do pedido de compra
						If (cAliTmp0)->C7_XQTDPRF <= 0
							aadd(aRetCM103[1],{cFilOri,(cAliTmp0)->C7_NUM,"SB1",(cAliTmp0)->C7_XCODPRF,"Quantidade do produto para o fornecedor invalida no pedido de compra. [C7_XQTDPRF = 0.0000]",cFilOri+(cAliTmp0)->C7_NUM})
							lOk:=.F.
						EndIf
					Endif
					
					// --> Ajuste para para executar o processo qquando nao ocorre erro.
					If lOk

						//#TB20191001 Thiago Berna - Incluso o campo de localizacao
						DbSelectArea('SB5')
						SB5->(DbSetOrder(1))
						If SB5->(DbSeek(xFilial('SB5')+(cAliTmp0)->C7_XCODPRF))
					
							cQuerySBE := "SELECT BE_LOCALIZ "
							cQuerySBE += "FROM " + RetSqlTab('SBE')
							cQuerySBE += "WHERE SBE.BE_FILIAL = '" + xFilial('SBE') + "' "
							cQuerySBE += "AND SBE.BE_LOCAL = '" + SB1->B1_LOCPAD + "' " 
							cQuerySBE += "AND SBE.BE_LOCALIZ LIKE '%" + AllTrim(SB5->B5_CODZON) + '999999' + "%' "
							cQuerySBE += "AND SBE.BE_STATUS IN ('1','2') "
							cQuerySBE += "AND SBE.D_E_L_E_T_ = ' ' "

							cQuerySBE := ChangeQuery(cQuerySBE)

							If Select(cAliasSBE) > 0
								(cAliasSBE)->(DbCloseArea())
							EndIf
															
							DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuerySBE),cAliasSBE, .F., .T.) 

							If (cAliasSBE)->(!Eof())
								cLocaliz := (cAliasSBE)->(BE_LOCALIZ)
								(cAliasSBE)->(DbCloseArea())
							Else
								AAdd(aRetCM103[1],{cFilOri,(cAliTmp0)->C7_NUM,"SBE",(cAliTmp0)->C7_XCODPRF,"Não encontrado endereço de expedição ou bloqueaqdo. [B1_COD=" + (cAliTmp0)->C7_XCODPRF + ",  B1_LOCPAD=" + SB1->B1_LOCPAD + ", B5_CODZON= " + SB5->B5_CODZON + "] ",cFilOri+(cAliTmp0)->C7_NUM})
								lOk:=.F.
							EndIf

						Else
							AAdd(aRetCM103[1],{cFilOri,(cAliTmp0)->C7_NUM,"SB5",(cAliTmp0)->C7_XCODPRF,"Complemento do produto não encontrado.",cFilOri+(cAliTmp0)->C7_NUM})
							lOk:=.F.				
						EndIf
					
						// -> Verifica se o endereço de expedição existe
						DbSelectArea("SBE")
						SBE->(DbSetOrder(9))
						SBE->(DbSeek(xFilial("SBE")+cLocaliz))
						If SBE->(Eof())
							AAdd(aRetCM103[1],{cFilOri,(cAliTmp0)->C7_NUM,"SBE",(cAliTmp0)->C7_XCODPRF,"Não encontrado endereço de expedição ou bloqueaqdo. [B1_COD=" + (cAliTmp0)->C7_XCODPRF + ",  B1_LOCPAD=" + SB1->B1_LOCPAD + ", B5_CODZON= " + SB5->B5_CODZON + "] ",cFilOri+(cAliTmp0)->C7_NUM})
							lOk:=.F.
						EndIf

						// -> Verifica se é operação MADERO
						If ((SubStr(SA1->A1_CGC,1,8) == SubStr(SM0->M0_CGC,1,8) .And. SF4->F4_XTRFMD != 'S' ) .Or.;
							(SubStr(SA1->A1_CGC,1,8) != SubStr(SM0->M0_CGC,1,8) .And. SF4->F4_XTRFMD == 'S' ))
							lOK:=.F.
							AAdd(aRetCM103[1],{cFilOri,SF4->F4_CODIGO,"SF4",SF4->F4_CODIGO,"A configuração da TES não corresponde a operação fiscal configurada. [F4_XTRFMD = " + SF4->F4_XTRFMD + "]",cFilOri+SF4->F4_CODIGO})
						EndIf

						// -> Se Ok, continua...
						If lOk

							cQrySA5 := "SELECT A5_XTPCUNF,A5_LOTEMUL,A5_XCVUNF  "
							cQrySA5 += " FROM SA5" + cGrupoEmp + "   "
							cQrySA5 += " WHERE A5_FILIAL = '" + cFilOri + "'  "
							cQrySA5 += " AND A5_PRODUTO = '"+(cAliTmp0)->C7_PRODUTO+"'  "
							cQrySA5 += " AND A5_FORNECE = '"+(cAliTmp0)->C7_FORNECE+"' "
							cQrySA5 += " AND D_E_L_E_T_ != '*' "

							cQrySA5 := ChangeQuery(cQrySA5)
							cAliSA5 := MPSysOpenQuery(cQrySA5)

							(cAliSA5)->(dbGoTop())
							cTpConv := (cAliSA5)->A5_XTPCUNF
							nFator:=IIF((cAliSA5)->A5_LOTEMUL>0,(cAliSA5)->A5_LOTEMUL,(cAliSA5)->A5_XCVUNF)

							If UPPER(cTpConv) == "M"
								nPrice := (cAliTmp0)->C7_PRECO * nFator
							ElseIf UPPER(cTpConv) == "D"
								nPrice := (cAliTmp0)->C7_PRECO / nFator
							EndIf
							aLinha := {}
							
							//#TB20191120 Thiago Berna - Grava somente se não existe
							DbSelectArea('SC6')
							SC6->(DbOrderNickName("PEDORI"))
							If SC6->(DbSeek(cFilOri + PadR((cAliTmp0)->C7_NUM,TamSx3("C6_NUMPCOM")[1]) + PadR((cAliTmp0)->C7_ITEM,TamSx3("C6_ITEMPC")[1]) ))

								aadd(aRetCM103[1],{cFilOri,(cAliTmp0)->C7_NUM,"SC6",(cAliTmp0)->C7_XCODPRF,"Pedido Original [" + AllTrim((cAliTmp0)->C7_NUM) + "] Item [" +  AllTrim((cAliTmp0)->C7_ITEM)  + "] Filial Original [" + AllTrim(cFilOri) + "] ja existente na industria.",cFilOri+(cAliTmp0)->C7_NUM})

							Else
								aAdd(aLinha, {"C6_ITEM"      , cItemSC6                     , Nil})
								aAdd(aLinha, {"C6_PRODUTO"   , SB1->B1_COD                  , Nil})
								aAdd(aLinha, {"C6_QTDVEN"    , (cAliTmp0)->C7_XQTDPRF       , Nil})
								aAdd(aLinha, {"C6_PRUNIT"    , nPrice                       , Nil})   
								aAdd(aLinha, {"C6_PRCVEN"    , nPrice                       , Nil})   
								aAdd(aLinha, {"C6_TES"       , cTes                         , Nil})
								
								// --> Ajuste para considerar a data de entrega com base nas tabelas DA7, DA8 e DA9
								//aAdd(aLinha, {"C6_ENTREG"    , stod((cAliTmp0)->C7_DATPRF)  , Nil})
								aAdd(aLinha, {"C6_ENTREG"    , U_COM103E(SA1->A1_CEP,STOD((cAliTmp0)->C7_DATPRF),@aCabec)       , Nil})
								
								aAdd(aLinha, {"C6_XFILORI"   , cFilOri                      , Nil})
								aAdd(aLinha, {"C6_NUMPCOM"   , (cAliTmp0)->C7_NUM           , Nil})
								aAdd(aLinha, {"C6_ITEMPC"    , (cAliTmp0)->C7_ITEM          , Nil})
								if !empty((cAliTmp0)->C7_XOBS)
									aAdd(aLinha, {"C6_XOBS"      , (cAliTmp0)->C7_XOBS      , Nil})
								Endif
								
								//#TB20191001 Thiago Berna - Incluso o campo de localizacao
								AAdd(aLinha, {"C6_LOCALIZ"	 , SBE->BE_LOCALIZ				, Nil})

								//#TB20191212 Thiago Berna - Adicionar Opcional
								If !Empty(SB1->B1_OPC)
									AAdd(aLinha, {"C6_OPC"	 , SB1->B1_OPC        				, Nil})
								EndIf
								
								cItemSC6:=Soma1(cItemSC6)
								aAdd(aItens, aLinha)
								
							EndIf
							// --> Ajuste para para executar o processo qquando nao ocorre erro.
							(cAliSA5)->(dbCloseArea()) 

						EndIf	

					EndIf 
					// --> Ajuste para para executar o processo qquando nao ocorre erro.
					(cAliTmp0)->(dbSkip())  
				EndDo 

				dDatAux := (cAliTmp0)->C7_DATPRF

				If lProx 
					If Len(aRetCM103[1]) <= 0 .and. len(aItens) > 0
						// -> Grava o Pedido de Venda
						VarInfo("Cabecalho -> ",aCabec)
						VarInfo("Itens -> ",aItens)
						MsExecAuto({|x, y, z| mata410(x, y, z)}, aCabec, aItens, 3)
						If lMsErroAuto
							cFileErr := "pv_"+cFilOri+"_SC5_"+strtran(time(),":","")
							MostraErro(cPathTmp, cFileErr)
							cFileErr := memoread(cPathTmp+cFileErr)
							aadd(aRetCM103[1],{cFilOri,"TODOS","SC5","","Erro ao gerar o pedido de venda na industria: "+ Chr(13) + Chr(10) + cFileErr,cFilOri+"TODOS"})
						Endif
					Endif
				EndIf
			EndDo
			(cAliTmp0)->(dbCloseArea())         
		EndIf

		//RESET ENVIRONMENT
		RpcClearEnv()

	Next nDados

Return aRetCM103

/*-----------------+---------------------------------------------------------+
!Nome              ! COM103E - Cliente: Madero                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Verificar data de Entrega com base nas  rotas           !
+------------------+---------------------------------------------------------+
!Autor             ! Thiago Berna                                            !
+------------------+---------------------------------------------------------!
!Data              ! 20/02/2019                                              !
+------------------+--------------------------------------------------------*/
User Function COM103E(cCep,dDataEnt,aCabec)

	Local cQuery	:= ''
	Local cAliasDA7	:= GetNextAlias()
	Local cAliasDA8	:= GetNextAlias()
	Local cAliasDA9	:= GetNextAlias()
	Local cChave	:= ''
	Local cChaveAnt	:= ''
	Local cCliente 	:= ''
	Local cLoja		:= ''
	Local cTempo	:= '00:00'
	Local cTempoAnt	:= '00:00'

	Default cCep	:= ''
	Default dDataEnt:= STOD('')
	Default aCabec	:= {}

	If Len(aCabec) > 0
		cCliente 	:= aCabec[aScan(aCabec,{|x| AllTrim(x[1]) == "C5_CLIENTE"}),2]
		cLoja		:= aCabec[aScan(aCabec,{|x| AllTrim(x[1]) == "C5_LOJACLI"}),2]
	EndIf

	cQuery := " SELECT * FROM " + RetSqlTab('DA7')
	cQuery += " WHERE DA7.DA7_FILIAL = '" + xFilial('DA7') + "' "
	cQuery += " AND DA7.DA7_CEPDE <= '" + cCep + "' "
	cQuery += " AND DA7.DA7_CEPATE >= '" + cCep + "' "
	
	cQuery += " AND (DA7.DA7_CLIENT = '' "
	cQuery += " OR (DA7.DA7_CLIENT = '" + cCliente + "' "
	cQuery += " AND DA7.DA7_LOJA = '" + cLoja + "')) "
	
	cQuery += " AND DA7.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
											
	If Select(cAliasDA7) > 0
		DbSelectArea(cAliasDA7)
		DbCloseArea()
	EndIf

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAliasDA7, .F., .T.)

	While (cAliasDA7)->(!Eof())
		
		If cChave != cChaveAnt
			If cTempo > cTempoAnt
				cTempoAnt 	:= cTempo
			EndIf
			cTempo 		:= '00:00'
		EndIf
		
		cQuery := " SELECT * FROM " + RetSqlTab('DA9')
		cQuery += " WHERE DA9.DA9_FILIAL = '" + xFilial('DA9') + "' "
		cQuery += " AND DA9.DA9_PERCUR = '" + (cAliasDA7)->(DA7_PERCUR) + "' "
		cQuery += " AND DA9.DA9_ROTA = '" + (cAliasDA7)->(DA7_ROTA) + "' "
		cQuery += " AND DA9.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
												
		If Select(cAliasDA9) > 0
			DbSelectArea(cAliasDA9)
			DbCloseArea()
		EndIf

		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAliasDA9, .F., .T.)

		While (cAliasDA9)->(!Eof())

			cQuery := " SELECT * FROM " + RetSqlTab('DA8')
			cQuery += " WHERE DA8.DA8_FILIAL = '" + xFilial('DA8') + "' "
			cQuery += " AND DA8.DA8_COD = '" + (cAliasDA9)->(DA9_ROTEIR) + "' "
			cQuery += " AND DA8.DA8_ATIVO = '1' "
			cQuery += " AND DA8.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
													
			If Select(cAliasDA8) > 0
				DbSelectArea(cAliasDA8)
				DbCloseArea()
			EndIf

			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAliasDA8, .F., .T.)

			While (cAliasDA8)->(!Eof())

				cTempo := AllTrim(Str(SomaHoras( cTempo, (cAliasDA8)->(DA8_TEMPO) )))

				(cAliasDA8)->(DbSkip())
			EndDo

			(cAliasDA9)->(DbSkip())
		EndDo
		
		cChaveAnt 	:= (cAliasDA7)->(DA7_PERCUR + DA7_ROTA)
		(cAliasDA7)->(DbSkip())
		cChave 		:= (cAliasDA7)->(DA7_PERCUR + DA7_ROTA)

	EndDo

	If Select(cAliasDA7) > 0
		DbSelectArea(cAliasDA7)
		DbCloseArea()
	EndIf
	
	If Select(cAliasDA8) > 0
		DbSelectArea(cAliasDA8)
		DbCloseArea()
	EndIf

	If Select(cAliasDA9) > 0
		DbSelectArea(cAliasDA9)
		DbCloseArea()
	EndIf

	// Calcula a data de entrega
	dDataEnt := (dDataEnt - Ceiling(HoraToInt(cTempo)/24))

	//Corrige a data de emissao do pedido caso a data de entrega seja menor que a data de emissao.
	If dDataEnt < aCabec[AScan(aCabec,{|x| AllTrim(x[1]) == "C5_EMISSAO"}),2] 
		aCabec[aScan(aCabec,{|x| AllTrim(x[1]) == "C5_EMISSAO"}),2]  := dDataEnt
	EndIf

Return dDataEnt