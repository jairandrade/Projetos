#Include "Protheus.ch"
#Include "TopConn.ch"
/*
+----------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Relatório                                               !
+------------------+---------------------------------------------------------+ 
!Módulo            ! Estoque / Custos                                        !
+------------------+---------------------------------------------------------+
!Nome              ! ESTR016                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Relatório Movimentação de Estoque   	                 !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                  		     !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 11/01/2019                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!PUTSX1 customizado							!           !           !        !
!modificado d1_total -> d1_custo!           ! Isabela   !  Jair     !14/04/20!
!modificado d1_emissao -> d1_dtit!          ! Isabela   !  Jair     !14/04/20!
!modificado aDados qtde ->valor             ! Isabela   !  Jair     !14/04/20!
+-------------------------------------------+-----------+-----------+--------+
*/
//Constantes
#Define STR_PULA    Chr(13)+Chr(10)

User Function ESTR016()
	Local aAreaM0 := SM0->(GetArea())
	Local oReport := nil
	Private cPerg := PadR("ESTR016",10)

	CriaSX1(cPerg)
	Pergunte(cPerg,.F.)


	oReport := RptDef(cPerg)
	oReport:PrintDialog()
	RestArea(aAreaM0)
Return

Static Function RptDef(cNome)
	Local oReport := Nil
	Local oSection1:= Nil
	Local oSection2:= Nil
	Local oSection3:= Nil
	Local oBreak1

	/*Sintaxe: TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao)*/
	oReport := TReport():New(cNome,"Relatório de Movimentação de Estoque",cNome,{|oReport| ReportPrint(oReport)},"Movimentação de Estoque")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)

	//Monstando a primeira seção
	oSection1:= TRSection():New(oReport, "Movimentação de Estoque",{"TRBNCM"})
	TRCell():New(oSection1,"FILIAL"		,"TRBNCM","FILIAL" 		,"@!",10)
	TRCell():New(oSection1,"DESCFIL"  ,"TRBNCM","DESCRICAO"	,"@!",40)

	//Segunda seção, será apresentado os produtos
	oSection2:= TRSection():New(oReport, "Produtos", "TRBNCM")
	TRCell():New(oSection2,"PRODUTO"   	,"TRBNCM","Produto"		,"@!",30)
	TRCell():New(oSection2,"DESCRICAO" 	,"TRBNCM","Descrição"	,"@!",50)

	//Terceira Secao - Detalhes
	oSection3:= TRSection():New(oReport, "Detalhes", "TRBNCM")
	TRCell():New(oSection3,"EMISSAO"	,"TRBNCM","Data do Lançamento"	,PesqPict("SB1","B1_DATREF"), 12)
	TRCell():New(oSection3,"GRUPO" 		,"TRBNCM","Tipo de Movimentação"		,"@!",16)
	TRCell():New(oSection3,"DESCGRP"	,"TRBNCM","Descrição"	,"@!",40)
	TRCell():New(oSection3,"POSINI"		,"TRBNCM","Qtd. Movimentada"	,"@E 9999999.9999",12)
	TRCell():New(oSection3,"PRMEDINI"	,"TRBNCM","Custo Lançamento"	,"@E 9,999,999,999.9999",12)
	TRCell():New(oSection3,"POSINIVL"	,"TRBNCM","Quantidade Estoque","@E 9999999.9999",12)
	TRCell():New(oSection3,"DIFERENCA"	,"TRBNCM","Custo Total Estoque","@E 9,999,999,999.9999",12)
	TRCell():New(oSection3,"ESTOQUE"	,"TRBNCM","Saldo do Estoque","@E 9,999,999,999.9999",12)
	TRCell():New(oSection3,"CMEDIO"		,"TRBNCM","Custo Medio Estoque","@E 9,999,999,999.9999",12)

	oBreak1 := TRBreak():New(oSection2,oSection2:Cell("PRODUTO"),"Subtotal por Produto")

Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local cQuery        := ""
	Local cFilialE  := ""
	Local cProd 	:= ""
	Local cLocal := ""
	Local nQtdMov := 0
	Local nEsti_un := 0
	Local nVi_cm1  := 0
	Local nVifim := 0
	Local nSldEst := 0
	Local aRetorno := {}
	Local nCont := 0
	Local cData :=""
	Local cGrupo :=""
	Local cDescri :=""
	Local soma := 0
	Local nOrdem := 0
	Local aDados :={}
	Local aDados1 :={}
	Local cFilBk  := cFilAnt
	Local lTrFil := .F.//troca filial
	Local nCusTot := 0
	Local cTexto := ""
	Local nI := 0
	Local cTipo := ""
	Local cTipoTM :=""
	Local nQtdMov := 0
	Private oSection3 := oReport:Section(3)
	//Monto minha consulta conforme parametros passado SD1 / SD2 / SD3
	//Pegando os dados
	cQuery := " SELECT 
	cQuery += " D3_FILIAL AS FILIAL,B1_GRUPO AS GRUPO, D3_LOCAL,D3_EMISSAO AS EMISSAO,D3_COD AS PRODUTO,B1_DESC AS DESCRICAO, "
	cQuery += " D3_TM,D3_CF, D3_NUMSEQ AS NUMSEQ, F5_TEXTO,'' AS F4_TPCTB,1 AS ORDEM , (D3_QUANT) AS D3_QUANT,  (D3_CUSTO1)AS D3_CUSTO1,D3_DOC "
	cQuery += " FROM " + RetSqlName("SD3") + " SD3 "
	cQuery += " LEFT JOIN " + RetSqlName("SF5") + " SF5 ON SF5.F5_CODIGO = SD3.D3_TM AND SF5.D_E_L_E_T_ <> '*'
	cQuery += " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = SD3.D3_FILIAL AND SB1.B1_COD = SD3.D3_COD AND SB1.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE SD3.D_E_L_E_T_ <> '*' "
	cQuery += " AND D3_FILIAL between '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQuery += " AND D3_EMISSAO between '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
	cQuery += " AND B1_GRUPO between  '"+MV_PAR05+"' AND  '"+MV_PAR06+"' "
	cQuery += " AND D3_COD between  '"+MV_PAR07+"' AND  '"+MV_PAR08+"' "
	cQuery += " UNION "//compras
	cQuery += " SELECT D1_FILIAL AS FILIAL,B1_GRUPO,'',D1_DTDIGIT AS EMISSAO,"//TROCADO DE D1_TOTAL -> D1_CUSTO PARA TRAZER IMPOSTOS
	cQuery += " D1_COD AS PRODUTO,B1_DESC,'','DE0',D1_NUMSEQ AS NUMSEQ,F4_TEXTO,F4_TPCTB,2 AS ORDEM ,(D1_QUANT) AS D3_QUANT, (D1_CUSTO)AS D3_CUSTO1,
	cQuery += " D1_DOC as D3_DOC "
	cQuery += " FROM " + RetSQLName("SD1") + " SD1 "
	cQuery += " INNER JOIN " + RetSQLName("SF4") + " SF4 ON D1_FILIAL = F4_FILIAL AND D1_TES = F4_CODIGO "
	cQuery += " AND SF4.D_E_L_E_T_ <> '*' AND F4_ESTOQUE = 'S' "
	cQuery += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_FILIAL = SD1.D1_FILIAL AND SB1.B1_COD = SD1.D1_COD AND SB1.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE SD1.D_E_L_E_T_ <> '*'
	cQuery += " AND D1_FILIAL between '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQuery += " AND D1_DTDIGIT between '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
	cQuery += " AND D1_COD between '"+MV_PAR07+"' AND  '"+MV_PAR08+"' "
	cQuery += " UNION "//vendas
	cQuery += " SELECT D2_FILIAL AS FILIAL,B1_GRUPO,'',D2_EMISSAO AS EMISSAO,"
	cQuery += " D2_COD AS PRODUTO,B1_DESC,'','RE0',D2_NUMSEQ AS NUMSEQ,F4_TEXTO,F4_TPCTB,3 AS ORDEM , (D2_QUANT) AS D3_QUANT, (D2_CUSTO1) AS D3_CUSTO1,
	cQuery += " D2_DOC as D3_DOC "
	cQuery += " FROM " + RetSQLName("SD2") + " SD2 "
	cQuery += " INNER JOIN " + RetSQLName("SF4") + " SF4 ON D2_FILIAL = F4_FILIAL AND D2_TES = F4_CODIGO "
	cQuery += " AND SF4.D_E_L_E_T_ <> '*' AND F4_ESTOQUE = 'S' "
	cQuery += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_FILIAL = SD2.D2_FILIAL AND SB1.B1_COD = SD2.D2_COD AND SB1.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE SD2.D_E_L_E_T_ <> '*'
	cQuery += " AND D2_FILIAL between '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQuery += " AND D2_EMISSAO between '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "
	cQuery += " AND D2_COD between '"+MV_PAR07+"' AND  '"+MV_PAR08+"' "
	cQuery += " ORDER BY FILIAL,PRODUTO,NUMSEQ  "

	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	IF Select("TRBNCM") <> 0
		DbSelectArea("TRBNCM")
		DbCloseArea()
	ENDIF

	//crio o novo alias
	TCQUERY cQuery NEW ALIAS "TRBNCM"
	//Memowrite("c:\temp\ESTR016.txt",CQuery)
	dbSelectArea("TRBNCM")
	TRBNCM->(dbGoTop())

	oReport:SetMeter(TRBNCM->(LastRec()))

	//Irei percorrer todos os meus registros
	While !Eof()

		If oReport:Cancel()
			Exit
		EndIf

		//inicializo a primeira seção
		oSection1:Init()

		oReport:IncMeter()

		IncProc("Imprimindo "+alltrim(TRBNCM->FILIAL))

		If cFilialE != TRBNCM->FILIAL
			cFilialE := TRBNCM->FILIAL
			cFilAnt :=cFilialE
			//imprimo a primeira seção
			oSection1:Cell("FILIAL"):SetValue(TRBNCM->FILIAL)
			oSection1:Cell("DESCFIL"):SetValue(FWFilialName(cEmpAnt,TRBNCM->FILIAL,1))
			oSection1:Printline()
			lTrFil := .T.
		EndIf

		//inicializo a segunda seção
		oSection2:init()

		If cProd != TRBNCM->PRODUTO
			//imprimo a segunda seção
			cProd 	:= TRBNCM->PRODUTO
			aDados :={}
			aDados1 :={}
			cDescri := ""
			soma := 0
			nOrdem := 1
			cLocal := GetAdvFVal("SB2","B2_LOCAL",TRBNCM->FILIAL+TRBNCM->PRODUTO,1,"Erro")
			aRetorno := CalcEst(TRBNCM->PRODUTO,cLocal,STOD(TRBNCM->EMISSAO))
			nEsti_un := aRetorno[1]//Quantidade inicial em estoque na data
			nVi_cm1  := aRetorno[2]/aRetorno[1] //preco medio
			nVifim	 := aRetorno[2]
			oSection2:Cell("PRODUTO"):SetValue(TRBNCM->PRODUTO)
			oSection2:Cell("DESCRICAO"):SetValue(TRBNCM->DESCRICAO)
			oSection2:Printline()
		ElseIf	lTrFil
			//imprimo a segunda seção
			oSection2:Cell("PRODUTO"):SetValue(TRBNCM->PRODUTO)
			oSection2:Cell("DESCRICAO"):SetValue(TRBNCM->DESCRICAO)
			oSection2:Printline()
		EndIf

		//inicializo a terceira seção
		oSection3:init()
		//verifico se o codigo d é mesmo, se sim, imprimo o produto
		While TRBNCM->FILIAL == cFilialE .and. TRBNCM->PRODUTO == cProd
			oReport:IncMeter()
			cTipo := 	SUBSTR(ALLTRIM(TRBNCM->D3_CF),1,2)
			cTipoTM := 	TRBNCM->D3_TM
			cData := 	TRBNCM->EMISSAO
			nCusTot := 0
			nQtdMov := 0 
			//nSldEst := 0
			cGrupo := ""
			//   inicio
			nCont++

			If nCont ==1  //imprime estoque inicial somente 01 vez independente de data.
				oSection3:Cell("EMISSAO"):SetValue(STOD(cData))
				oSection3:Cell("GRUPO"):SetValue("Estoque Inicial")
				oSection3:Cell("DESCGRP"):SetValue("")
				oSection3:Cell("POSINI"):SetValue(nQtdMov)
				oSection3:Cell("PRMEDINI"):SetValue(nVi_cm1)//Custo Lançamento
				oSection3:Cell("POSINIVL"):SetValue(nEsti_un)//Quantidade Estoque
				oSection3:Cell("DIFERENCA"):SetValue(nQtdMov*nVi_cm1)//Custo Total Estoque
				oSection3:Cell("ESTOQUE"):SetValue(nVifim) //Saldo do Estoque
				oSection3:Cell("CMEDIO"):SetValue(nVifim/nEsti_un)//Custo Medio Estoque
				oSection3:Printline()
				nSldEst += nEsti_un
				aAdd(aDados, {"Estoque Inicial",nVifim,1})//nSldEst->nVifim 14-04-2020
			EndIf

			While SUBSTR(ALLTRIM(TRBNCM->D3_CF),1,2) == cTipo .and. TRBNCM->EMISSAO ==cData .and. TRBNCM->FILIAL == cFilialE .and. TRBNCM->PRODUTO == cProd .AND. cTipoTM = TRBNCM->D3_TM

				If SUBSTR(ALLTRIM(TRBNCM->D3_CF),1,2)=="RE"
					nCusTot	 += TRBNCM->D3_CUSTO1
					nSldEst -= TRBNCM->D3_QUANT
					nVifim  -= TRBNCM->D3_CUSTO1  
					cGrupo := "Saida"
					nQtdMov += TRBNCM->D3_QUANT
					If TRBNCM->D3_TM = '999' 
						If SUBSTR(ALLTRIM(TRBNCM->D3_CF),1,3)=="DE0"
							cTexto := "Ajuste de Inventário"
						Else
							cTexto := "Venda"
						EndIf
					Else
						//cTexto := "Venda"	F5_FILIAL+F5_CODIGO
						cTexto :=  Alltrim(Posicione("SF5", 01, xFilial("SF5") + TRBNCM->D3_TM, "F5_TEXTO"))	//13-03-2020)		
					EndIf
				Else
					nSldEst += TRBNCM->D3_QUANT 
					nCusTot	 += TRBNCM->D3_CUSTO1
					nVifim  += TRBNCM->D3_CUSTO1    
					cGrupo := "Entrada"
					nQtdMov += TRBNCM->D3_QUANT
					If TRBNCM->D3_TM = '499' 
						If SUBSTR(ALLTRIM(TRBNCM->D3_CF),1,3)=="DE0"
							cTexto := "Ajuste de Inventário"
						Else
							cTexto := "Compra"
						EndIf			
					EndIf
				EndIf

				If (TRBNCM->F4_TPCTB = '50' .OR. TRBNCM->F4_TPCTB = '53')//Verifica Tipo contabil na tabela SF4
					cTexto := "COMPRA"
				ElseIf TRBNCM->F4_TPCTB = '52'//Verifica Tipo contabil na tabela SF4
					cTexto := "FRETE"
				ElseIf (TRBNCM->F4_TPCTB = '58' .OR. TRBNCM->F4_TPCTB = '60')//Verifica Tipo contabil na tabela SF4
					cTexto := "TRANSFERENCIA"
				ElseIf (TRBNCM->F4_TPCTB = '62' .OR. TRBNCM->F4_TPCTB = '10')//Verifica Tipo contabil na tabela SF4
					cTexto := "DEVOLUCAO"
				ElseIf (TRBNCM->F4_TPCTB = '63' .OR. TRBNCM->F4_TPCTB = '07')//Verifica Tipo contabil na tabela SF4
					cTexto := "BONIFICAÇÃO"
				ElseIf (TRBNCM->F4_TPCTB = '61' .OR. TRBNCM->F4_TPCTB = '66')//Verifica Tipo contabil na tabela SF4
					cTexto := "OUTRAS ENTRADAS"
				ElseIf TRBNCM->F4_TPCTB = '50'//Verifica Tipo contabil na tabela SF4
					cTexto := "COMPRA"
				ElseIf (TRBNCM->F4_TPCTB = '01' .OR. TRBNCM->F4_TPCTB = '03')//Verifica Tipo contabil na tabela SF4
					cTexto := "TRANSFERENCIA"
				ElseIf TRBNCM->F4_TPCTB = '05'//Verifica Tipo contabil na tabela SF4
					cTexto := "VENDA"
				ElseIf TRBNCM->F4_TPCTB = '11'//Verifica Tipo contabil na tabela SF4
					cTexto := "OUTRAS SAÍDAS"
				Else
					If Empty(cTexto)
						cTexto := Alltrim(TRBNCM->F5_TEXTO)
					EndIf
				EndIf	
				TRBNCM->(dbSkip())//loop secao 3
			EndDo
			
			oSection3:Cell("EMISSAO"):SetValue(STOD(cData))
			oSection3:Cell("GRUPO"):SetValue(cGrupo)
			oSection3:Cell("DESCGRP"):SetValue(cTexto)
			oSection3:Cell("POSINI"):SetValue(nQtdMov)//qtde movimentada
			oSection3:Cell("PRMEDINI"):SetValue(nCusTot/nQtdMov)//Custo Lançamento
			//oSection3:Cell("PRMEDINI"):SetValue(nVifim/nSldEst)//Custo Lançamento COMENTADO PARA TESTAR LINHA ACIMA DESTA
			oSection3:Cell("POSINIVL"):SetValue(nSldEst)  //Quantidade Estoque
			oSection3:Cell("DIFERENCA"):SetValue(nCusTot)//Custo Total Estoque
			oSection3:Cell("ESTOQUE"):SetValue(nVifim) //Saldo do Estoque
			oSection3:Cell("CMEDIO"):SetValue(nVifim/nSldEst)//Custo Medio Estoque
			oSection3:Printline()

			aAdd(aDados, {Alltrim(cTexto),nCusTot,nOrdem++})//nSldEst->nCusTot 14-04-2020

			//cData  := TRBNCM->EMISSAO
			//cGrupo := TRBNCM->GRUPO
			//TRBNCM->(dbSkip())//loop secao 3
		EndDo

		//imprime Estoque Final
		oSection3:Cell("EMISSAO"):SetValue(STOD(cData))
		oSection3:Cell("GRUPO"):SetValue("Estoque Final")
		oSection3:Cell("DESCGRP"):SetValue("")
		oSection3:Cell("POSINI"):SetValue(0)//qtde movimentada
		oSection3:Cell("PRMEDINI"):SetValue(0)//Custo Lançamento
		oSection3:Cell("POSINIVL"):SetValue(nSldEst)
		oSection3:Cell("DIFERENCA"):SetValue(nQtdMov*0)//Custo Total Estoque
		oSection3:Cell("ESTOQUE"):SetValue(nVifim) //Saldo do Estoque
		oSection3:Cell("CMEDIO"):SetValue(nVifim/nSldEst)//Custo Medio Estoque
		oSection3:Printline()
		aAdd(aDados, {"Estoque Final",nVifim,nOrdem++})//nSldEst->nVifim 14-04-2020
		
		nCont := 0
		nSldEst := 0
		//finalizo a terceira seção para que seja reiniciada para o proximo produto
		oSection3:Finish()
		//imprimo uma linha para separar um PRODUTO de outro
		oReport:ThinLine()
		//finalizo a segunda seção para que seja reiniciada para o proximo registro
		oSection2:Finish()
		ASORT(aDados, , , { | x,y | x[1] < y[1] } )
		cDescri:=aDados[1][1]
		nOrdem := aDados[1][3]
		For nI := 1 TO LEN(aDados)
			If cDescri == aDados[nI][1]
				soma+= aDados[ni,2]
			Else
				AADD(aDados1, {cDescri, soma,nOrdem})
				cDescri:= aDados[nI][1]
				soma   := aDados[nI][2]
				nOrdem := aDados[nI][3]
			EndIf
		Next nI
		AADD(aDados1,{cDescri,soma,nOrdem})//add os dados do ultimo
		ASORT(aDados1, , , { | x,y | x[3] < y[3] } )
		oReport:PrintText("")
		for ni:=1 to len(aDados1)
			oReport:PrintText(UPPER(aDados1[nI][1])+SPACE(49-LEN(aDados1[nI][1]))+PadL(Alltrim(Transform(aDados1[nI][2], "@E 999,999,999.9999")),16))
		next
		aDados :={}
		aDados1 :={}
		cDescri := ""
		soma := 0
		nOrdem := 0	//finalizo a primeira seção
		oSection1:Finish()
		lTrFil := .F.
	Enddo
	//Voltando backups
	cFilAnt := cFilBk
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CriaSX1
Função para criação das perguntas na SX1

@author Jair  Matos
@since 16/10/2018
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CriaSX1(cPerg)
	cValid   := ""
	cF3      := ""
	cPicture := ""
	cDef01   := ""
	cDef02   := ""
	cDef03   := ""
	cDef04   := ""
	cDef05   := ""
	U_XPutSX1(cPerg, "01", "Filial De?"			,"MV_PAR01", "MV_CH1", "C", 10,	0, "G", cValid,     "SM0",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a Filial inicial")
	U_XPutSX1(cPerg, "02", "Filial Até?"		,"MV_PAR02", "MV_CH2", "C", 10, 0, "G", cValid,     "SM0",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a Filial final")
	U_XPutSX1(cPerg, "03", "Emissao De?"		,"MV_PAR03", "MV_CH3", "D", 08,	0, "G", cValid,     cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a Data inicial")
	U_XPutSX1(cPerg, "04", "Emissao Até?"  		,"MV_PAR04", "MV_CH4", "D", 08, 0, "G", cValid,     cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a Data final")
	U_XPutSX1(cPerg, "05", "Grupo De?"	   		,"MV_PAR05", "MV_CH5", "C", 04,	0, "G", cValid,     "SBM",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o Grupo inicial")
	U_XPutSX1(cPerg, "06", "Grupo Até?"	   		,"MV_PAR06", "MV_CH6", "C", 04, 0, "G", cValid,     "SBM",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o Grupo final")
	U_XPutSX1(cPerg, "07", "Produto De?"		,"MV_PAR07", "MV_CH7", "C", 15,	0, "G", cValid,     "SB1",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o Produto inicial")
	U_XPutSX1(cPerg, "08", "Produto Até?"		,"MV_PAR08", "MV_CH8", "C", 15, 0, "G", cValid,     "SB1",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o Produto final")

Return