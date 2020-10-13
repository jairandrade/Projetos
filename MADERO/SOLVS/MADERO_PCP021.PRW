#INCLUDE 'TOTVS.CH'
#INCLUDE "FWBROWSE.CH"
#Include 'Protheus.ch'
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "TBICONN.CH"

User Function PCP021

Local oSize
Local cCadastro := 'Titulo'
Local cPerg		:= 'PCP021'
Local cFabrica	:= ''
Local cZona		:= ''
Local cLinha	:= ''
Local cDescLin	:= ''
Local nMs       := 50000
Local oDlg

If Pergunte(cPerg)

	cLinha 		:= MV_PAR01
	cDescLin 	:= AllTrim(Posicione('Z55',1,xFilial('Z55')+ cLinha ,'Z55_DESC'))
	cFabrica  	:= Posicione('Z55',1,xFilial('Z55')+ cLinha ,'Z55_CODIND')
	cZona	  	:= Posicione('Z55',1,xFilial('Z55')+ cLinha ,'Z55_CODZON')

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Controle e definicoes do tamanho da tela                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize := FwDefSize():New( .T. ,,,)
	oSize:AddObject( "MSPANEL"  , 100, 100, .T. , .T. )
	oSize:lProp := .T.
	oSize:Process()

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a tela                           					                	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDlg    := TDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],cCadastro,,,,,,,,oMainWnd,.T.)

    Tela01(nMs,cFabrica,cLinha,cDescLin,cZona)
    
    oDlg:Activate(,,,,,,)

EndIf

Return

Static Function Tela01(nMs,cFabrica,cLinha,cDescLin,cZona)

	Local aDados 	:= {}
	Local aPosPanA	:= {}
	Local aPosPanB	:= {}
	Local oTimer
	Local oRefresh
	Local oBrowse
	Local oDlg
	Local oSize
	Local oTFont 	:= TFont():New("Arial",,40,.T.)
	Local oPanelA	
	Local oPanelB
	Local oSayTop
	Local cCadastro := 'TELA 01'
	Local cQuery	:= ''
	Local cAlias	:= GetNextAlias()
	Local nRefresh	:= 1000

    cQuery := "SELECT C2_NUM||C2_ITEM||C2_SEQUEN C2_NUM, C2_EMISSAO, B1_COD, B1_DESC, C2_DATPRI, C2_DATPRF, C2_QUANT, C2_QUJE "
	cQuery += "FROM " + RetSqlTab("SC2")
	cQuery += "INNER JOIN " + RetSqlTab("SB1")
	cQuery += "ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' " 
   	cQuery += "AND SB1.B1_COD = SC2.C2_PRODUTO "
   	cQuery += "AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE SC2.C2_FILIAL = '" + xFilial('SC2') + "' "
    cQuery += "AND SC2.C2_TPOP = 'F' "
    cQuery += "AND C2_FILIAL||C2_NUM||C2_ITEM||C2_SEQUEN NOT IN "
    cQuery += "(SELECT D3_FILIAL||D3_OP FROM " + RetSqlTab('SD3') + " WHERE D3_PARCTOT = 'T' AND D3_ESTORNO = ' ' AND D_E_L_E_T_ <> '*') " 
    cQuery += "AND SC2.C2_XLINHA = '" + MV_PAR01 + "' "          
 	cQuery += "AND SC2.C2_XLOCALI LIKE '" + cFabrica+cZona + "%' "
	
	//#TB20200130 Thiago Berna - Ajuste para considerar somente OPS firmadas na database do sistema
	cQuery += "AND SC2.C2_XDTFIR <= '" + DTOS(dDatabase) + "' "
	cQuery += "AND SC2.C2_DATRF = '' "

    cQuery += "AND SC2.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY C2_EMISSAO, C2_NUM||C2_ITEM||C2_SEQUEN "  

	cQuery := ChangeQuery(cQuery)

    If Select(cAlias) > 0
        DbSelectArea(cAlias)
        DbCloseArea()
    EndIf
                                    
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.) 

	While (cAlias)->(!EOF())
		AAdd(aDados,{(cAlias)->C2_NUM ,(cAlias)->B1_DESC,STOD((cAlias)->C2_DATPRI),STOD((cAlias)->C2_DATPRF),(cAlias)->C2_QUANT	,(cAlias)->C2_QUJE})		
		(cAlias)->(DbSkip())
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Controle e definicoes do tamanho da tela                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize := FwDefSize():New( .F. ,,,)
	oSize:AddObject( "MSPANELA"  , 100, 005, .T. , .T. )
	oSize:AddObject( "MSPANELB"  , 100, 075, .T. , .T. )
	oSize:lProp := .T.
	oSize:Process()

	aPosPanA := { oSize:GetDimension("MSPANELA","LININI"), oSize:GetDimension("MSPANELA","COLINI"), oSize:GetDimension("MSPANELA","LINEND"),;
	oSize:GetDimension("MSPANELA","COLEND") }
	
	aPosPanB := { oSize:GetDimension("MSPANELB","LININI"), oSize:GetDimension("MSPANELB","COLINI"), oSize:GetDimension("MSPANELB","LINEND"),; 
	oSize:GetDimension("MSPANELB","COLEND") }

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a tela                           					                	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDlg    := TDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],cCadastro,,,,,,,,oMainWnd,.T.)

	oPanelA := tPanel():New(aPosPanA[1],aPosPanA[2]  	,,oDlg,oTFont,.T.,,,,aPosPanA[4]     	,aPosPanA[3]  		,.F.)
	oPanelB := tPanel():New(aPosPanB[1],aPosPanB[2]  	,,oDlg,oTFont,.T.,,,,aPosPanB[4]     	,aPosPanB[3]  		,.F.)

  	/* Array de Exemplo
	AAdd(aDados,{"00000101001" ,'PRODUTO A',dDataBase,dDataBase,0	,100})
	AAdd(aDados,{"00000101002" ,'PRODUTO B',dDataBase,dDataBase,100	,200})
	AAdd(aDados,{"00000101003" ,'PRODUTO C',dDataBase,dDataBase,0	,300})
	AAdd(aDados,{"00000201001" ,'PRODUTO A',dDataBase,dDataBase,450	,500})
	AAdd(aDados,{"00000301001" ,'PRODUTO D',dDataBase,dDataBase,100	,400})*/

	//#TB20200312 Thiago Berna - Ajuste para aumentar o tamanho da fonte
	//@ @ 00, 00 SAY "Fabrica: " + cFabrica + Space(50) + "Linha :  " + cLinha + " - " + cDescLin + Space(50) + "DATA: " + DTOC(dDataBase) SIZE 1000,15  OF oPanelA PIXEL
	oSayTop	:= TSay():New( 00, 00, { || "Fabrica: " + cFabrica + Space(50) + "Linha :  " + cLinha + " - " + cDescLin + Space(50) + "DATA: " + DTOC(dDataBase) }, oPanelA,, oTFont,,,, .T.,,,1000,15)
	
    oBrowse := FWBrowse():New()
	oBrowse:SetOwner( oPanelB )
	oBrowse:SetDataArray()
	oBrowse:SetArray(aDados)
	oBrowse:DisableConfig()
	oBrowse:DisableReport()
	
	oBrowse:SetColumns( {{ "Número"			, 	{ || aDados[oBrowse:nAt][1] 										},"C",,3,/*nTamanho*/25,0,.F.,,.F.,}})
	oBrowse:SetColumns( {{ "Produto"		, 	{ || aDados[oBrowse:nAt][2] 										},"C",,1,/*nTamanho*/50,0,.F.,,.F.,}})
	oBrowse:SetColumns( {{ "Início"     	, 	{ || aDados[oBrowse:nAt][3]											},"D",,3,/*nTamanho*/20,0,.F.,,.F.,}})
	oBrowse:SetColumns( {{ "Fim"     		, 	{ || aDados[oBrowse:nAt][4]											},"D",,3,/*nTamanho*/20,0,.F.,,.F.,}})
	oBrowse:SetColumns( {{ "Qtde " 	 		, 	{ || Transform(aDados[oBrowse:nAt][5]	,PesqPict("SC2","C2_QUANT"))},"N",,2,/*nTamanho*/25,2,.F.,,.F.,}})
	oBrowse:SetColumns( {{ "Qtde Apontada"  , 	{ || Transform(aDados[oBrowse:nAt][6]	,PesqPict("SC2","C2_QUANT"))},"N",,2,/*nTamanho*/25,2,.F.,,.F.,}})
    
	oBrowse:SetFontBrowse(oTFont)
	oBrowse:SetLineHeight (80)

    oTimer:= TTimer():New(nMs,{|| oDlg:End(), Tela02(nMs,cFabrica,cLinha,cDescLin,cZona) },oDlg)
	oTimer:Activate()

	//Atualiza a tela para evitar encerramento via timeout
	oRefresh:= TTimer():New(nMs,{|| oRefresh:Deactivate() , oBrowse:Refresh(), oRefresh:Activate() },oDlg)
	oRefresh:Activate()

	oBrowse:Activate()

    oDlg:Activate(,,,,,,)

Return

Static Function Tela02(nMs,cFabrica,cLinha,cDescLin,cZona)

Local aDados 	:= {}
Local aDadosIn 	:= {}
Local aPosPanA	:= {}
Local aPosPanB	:= {}
Local aPosPanC	:= {}
Local oTimer
Local oRefresh
Local oBrowse
Local oDlg
Local oSize
Local oTFont 	:= TFont():New("Arial",,40,.T.)
Local oPanelA	
Local oPanelB
Local oPanelC
Local oSayTop
Local oSayBot
Local cCadastro := 'TELA 02'
Local cQuery	:= ''
Local cAlias	:= GetNextAlias()
Local nCount	:= 0
Local nTotal	:= 0
Local nA		:= 0
Local lFoundXB	:= .F.

    
	cQuery := "SELECT SB1.B1_COD COD_PROD_OP, SB1.B1_DESC DESC_PROD_OP, SUM(SD4.D4_QUANT) QUANTIDADE, SD4.D4_LOCAL ARMAZEM_EMPENHO, SD4.D4_OP COD_OP, SC2.C2_EMISSAO DATA_OP, SC2.C2_XLOCALI END_OP, SB1EMP.B1_COD COD_PROD_EMP, SB1EMP.B1_DESC DESC_PROD_EMP "
	
	cQuery += "FROM " + RetSqlTab('SC2')
	
	cQuery += "INNER JOIN " + RetSqlTab('SD4')
	cQuery += "ON SD4.D4_FILIAL = SC2.C2_FILIAL "
   	cQuery += "AND SD4.D4_OP = SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN "
	cQuery += "AND SD4.D_E_L_E_T_ = ' ' "    
 	
	
	cQuery += "INNER JOIN " + RetSqlTab('SB1')
	cQuery += "ON SB1.B1_FILIAL = SC2.C2_FILIAL "
   	cQuery += "AND SB1.B1_COD = SC2.C2_PRODUTO "
   	cQuery += "AND SB1.D_E_L_E_T_ = ' ' "

	cQuery += "INNER JOIN " + AllTrim(RetSqlTab('SB1')) + "EMP "
	cQuery += "ON SB1EMP.B1_FILIAL = SD4.D4_FILIAL "
   	cQuery += "AND SB1EMP.B1_COD = SD4.D4_COD "
   	cQuery += "AND SB1EMP.D_E_L_E_T_ = ' ' "

	cQuery += "WHERE SC2.C2_FILIAL = '" + xFilial('SD4') + "' " 
    cQuery += "AND SD4.D4_QUANT	> 0 "
    cQuery += "AND SD4.D4_LOCAL <> '" + AllTrim(GetMv("MV_LOCPROC",,"01")) + "' " 

	//TB20191125 Thiago Berna - Ajuste para corrigir o valor
	cQuery += "AND SD4.D4_LOTECTL = '' "

	cQuery += "AND SC2.C2_XLINHA    = '" + cLinha + "' "
 	cQuery += "AND SC2.C2_XLOCALI LIKE '" + cFabrica+cZona + "%' "

	 //#TB20200130 Thiago Berna - Ajuste para considerar somente OPS firmadas na database do sistema
	cQuery += "AND SC2.C2_XDTFIR <= '" + DTOS(dDatabase) + "' "
	cQuery += "AND SC2.C2_DATRF = '' "

   	cQuery += "AND SC2.D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY SB1.B1_COD, SB1.B1_DESC, SD4.D4_LOCAL, SD4.D4_OP, SC2.C2_EMISSAO, SC2.C2_XLOCALI, SB1EMP.B1_COD, SB1EMP.B1_DESC "
	cQuery += "ORDER BY C2_EMISSAO, SD4.D4_OP "

	cQuery := ChangeQuery(cQuery)

    If Select(cAlias) > 0
        DbSelectArea(cAlias)
        DbCloseArea()
    EndIf
                                    
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlias, .F., .T.) 

	While (cAlias)->(!Eof()) 
		lFoudXB:=.F.
		aAdd(aDadosIn,{(cAlias)->COD_PROD_EMP,(cAlias)->DESC_PROD_EMP,(cAlias)->QUANTIDADE,(cAlias)->ARMAZEM_EMPENHO,(cAlias)->END_OP,(cAlias)->COD_OP,(cAlias)->COD_PROD_OP,(cAlias)->DESC_PROD_OP})
							

		// -> Verifica se o produto possui desmontagem
		SG2->(DbSetOrder(1))
		SG2->(DbSeek(xFilial('SG2')+(cAlias)->COD_PROD_EMP))
		While SG2->(!Eof())
			If AllTrim(SG2->G2_OPERAC) == 'XB'
				lFoundXB := .T.
				Exit
			EndIf
			SG2->(DbSkip())
		EndDo

		// -> Se Existe desmontagem
		If lFoundXB
			// -> Pesquisa a MP na estrutura de produto
			SG1->(DbSetOrder(2))
			SG1->(DbSeek(xFilial('SG1')+(cAlias)->COD_PROD_EMP))
			If SG1->(!Found())
				aDadosIn[Len(aDadosIn),02] := 'NAO ENCONTRADO DESMONTAGEM PARA O PRODUTO'
				aDadosIn[Len(aDadosIn),03] := 0
			Else
				// -> Posiciona no produto
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial('SB1')+SG1->G1_COD))
				If SB1->(!Found())
					aDadosIn[Len(aDadosIn),01] := SG1->G1_COD
					aDadosIn[Len(aDadosIn),02] := 'PRODUTO NÃO ENCONTRADO NA SB1'
					aDadosIn[Len(aDadosIn),03] := 0
				Else
					aDadosIn[Len(aDadosIn),01]:= SB1->B1_COD
					aDadosIn[Len(aDadosIn),02]:= SB1->B1_DESC
					//TB20191125 Thiago Berna - Ajuste para corrigir o valor
					//aDadosIn[Len(aDadosIn),03]:= (cAlias)->QUANTIDADE * SG1->G1_QUANT
					aDadosIn[Len(aDadosIn),03]:= (cAlias)->QUANTIDADE
				EndIf	
			EndIf
		EndIf
		(cAlias)->(DbSkip())
	EndDo

	For nA := 1 to Len(aDadosIn)
		AAdd(aDados,{aDadosIn[nA,2] ,aDadosIn[nA,3],aDadosIn[nA,4],aDadosIn[nA,6]})		
	Next nA

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Controle e definicoes do tamanho da tela                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize := FwDefSize():New( .F. ,,,)
	oSize:AddObject( "MSPANELA"  , 100, 005, .T. , .T. )
	oSize:AddObject( "MSPANELB"  , 100, 065, .T. , .T. )
	oSize:AddObject( "MSPANELC"  , 100, 010, .T. , .T. )
	oSize:lProp := .T.
	oSize:Process()

	aPosPanA := { oSize:GetDimension("MSPANELA","LININI"), oSize:GetDimension("MSPANELA","COLINI"), oSize:GetDimension("MSPANELA","LINEND"),;
	oSize:GetDimension("MSPANELA","COLEND") }
	
	aPosPanB := { oSize:GetDimension("MSPANELB","LININI"), oSize:GetDimension("MSPANELB","COLINI"), oSize:GetDimension("MSPANELB","LINEND"),; 
	oSize:GetDimension("MSPANELB","COLEND") }

	aPosPanC := { oSize:GetDimension("MSPANELC","LININI"), oSize:GetDimension("MSPANELC","COLINI"), oSize:GetDimension("MSPANELC","LINEND"),; 
	oSize:GetDimension("MSPANELC","COLEND") }

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a tela                           					                	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDlg    := TDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],cCadastro,,,,,,,,oMainWnd,.T.)

	oPanelA := tPanel():New(aPosPanA[1],aPosPanA[2]  	,,oDlg,oTFont,.T.,,,,aPosPanA[4]     	,aPosPanA[3]  		,.F.)
	oPanelB := tPanel():New(aPosPanB[1],aPosPanB[2]  	,,oDlg,oTFont,.T.,,,,aPosPanB[4]     	,aPosPanB[3]  		,.F.)
	oPanelC := tPanel():New(aPosPanC[1],aPosPanC[2]  	,,oDlg,oTFont,.T.,,,,aPosPanC[4]     	,aPosPanC[3]  		,.F.)

  	/* Array de Exemplo
	AAdd(aDados,{"10102080000100 - CARNE RESF SUINA S/OSSO S/ PELE (BARRIGA) - KG" ,700,'50 - 00000101','00000101002 - PRODUTO B'})
	AAdd(aDados,{"10102080000100 - CARNE RESF SUINA S/OSSO S/ PELE (BARRIGA) - KG" ,300,'50 - 00000101','00000101002 - PRODUTO B'})*/
	
	For nCount := 1 to Len(aDados)
		nTotal += aDados[nCount,2]
	Next nCount

	//#TB20200312 Thiago Berna - Ajuste para aumentar o tamanho da fonte
	//@ @ 00, 00 SAY "Fabrica: " + cFabrica + Space(50) + "Linha :  " + cLinha + " - " + cDescLin + Space(50) + "DATA: " + DTOC(dDataBase) SIZE 1000,15  OF oPanelA PIXEL
	//@ @ 15, 00 SAY "Total: " + Transform(nTotal	,PesqPict("SC2","C2_QUANT")) SIZE 800,15  OF oPanelC PIXEL
	oSayTop	:= TSay():New( 00, 00, { || "Fabrica: " + cFabrica + Space(50) + "Linha :  " + cLinha + " - " + cDescLin + Space(50) + "DATA: " + DTOC(dDataBase) }, oPanelA,, oTFont,,,, .T.,,,1000,15)
	oSayBot	:= TSay():New( 15, 00, { || "Total: " + Transform(nTotal	,PesqPict("SC2","C2_QUANT")) }, oPanelC,, oTFont,,,,.T.,,,800,15)

    oBrowse := FWBrowse():New()
	oBrowse:SetOwner( oPanelB )
	oBrowse:SetDataArray()
	oBrowse:SetArray(aDados)
	oBrowse:DisableConfig()
	oBrowse:DisableReport()
	
	oBrowse:SetColumns( {{ "Num. OP"  			, 	{ || aDados[oBrowse:nAt][4]                                         },"C",,3,/*nTamanho*/20,2,.F.,,.F.,}})
	oBrowse:SetColumns( {{ "Materia Prima"		, 	{ || aDados[oBrowse:nAt][1] 										},"C",,1,/*nTamanho*/50,0,.F.,,.F.,}})
	oBrowse:SetColumns( {{ "Arm. -End. OP"     	, 	{ || aDados[oBrowse:nAt][3]											},"C",,3,/*nTamanho*/20,0,.F.,,.F.,}})
	oBrowse:SetColumns( {{ "Saldo a Transferir" , 	{ || Transform(aDados[oBrowse:nAt][2]	,PesqPict("SC2","C2_QUANT"))},"N",,2,/*nTamanho*/20,0,.F.,,.F.,}})
	
	oBrowse:SetFontBrowse(oTFont)
	oBrowse:SetLineHeight (80)

    oTimer:= TTimer():New(nMs,{|| oDlg:End(), Tela01(nMs,cFabrica,cLinha,cDescLin,cZona) },oDlg)
	oTimer:Activate()

	//Atualiza a tela para evitar encerramento via timeout
	oRefresh:= TTimer():New(nMs,{|| oRefresh:Deactivate() , oBrowse:Refresh(), oRefresh:Activate() },oDlg)
	oRefresh:Activate()

	oBrowse:Activate()

    oDlg:Activate(,,,,,,)

Return

