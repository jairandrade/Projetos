
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³KAPAZI_PE01NFESEFAZºAutor  ³Rodrigo Slisisnski          º Data ³  13/02/15    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Ponto de entrada para customizacoes no xml da nota fiscal eletronica       º±±
±±º          ³                                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#Include "topconn.ch"
#Include "tbiconn.ch"
#Include "totvs.ch"

User Function PE01NFESEFAZ()
Local cProdx		:= ''
Local cCodEmp		:= ""
Local aInfItem		:= PARAMIXB[6]
Private aRet 		:= paramixb
Private cmenscli	:=" "

//cProdx := posicione("SA7",1,xFilial("SA7")+SC5->C5_CONDPAG,"E4_DESCRI")  --retirado por Rodrigo Slisinski pois amarracao esta errada sa7 x se4
/*
cTipo := If(aRet[5, 4] = “1”, “S”, “E”) //Tipo de Nota: 1 – Saída, 2 – Entrada
cDoc := aRet[5, 2] //Número da Nota
cSerie := aRet[5, 1] //Série da Nota
*/

If Alltrim((paramixb[5][4])) == '1'
	
	DbSelectArea("SC5")
	DbSetOrder(1)
	DbGoTop()
	If DbSeek(xFilial("SC5")+aInfItem[1,1])
		
		If Alltrim(SC5->C5_K_OPER) == '31' .And. Alltrim(SC5->C5_CLIENTE) == '039138' .And. Alltrim(SC5->C5_LOJACLI) == '01' //Madeira madeira - NF simbolica
				If cEmpAnt	== "04"
						aRet[2] := ""
						aRet[2]	+= RetCHVCl("04")
						Conout("NF Madeira Madeira empresa 04")
					
					ElseIf cEmpAnt	== "01"
						aRet[2] := ""
						aRet[2]	+= RetCHVCl("01")
						Conout("NF Madeira Madeira empresa 01")
					
					Else	
						Conout("NF Madeira Madeira empresa nao localizada")
						aRet[2] := ""
				EndIf
		EndIf	
		
	EndIf
	 
	aPrd:=paramixb[1]
	aD2 :=paramixb[6]
	cmenscli:=paramixb[2]
	
	For XI := 1 TO Len(aPrd)
		
		DbSelectArea('SC5')
		DBSetOrder(1)
		DbSeek(xFilial('SC5')+aD2[xi][1])
		
		nmoeda:=SC5->C5_MOEDA
		
		
		cMenAux:=" PV:"+SC5->C5_NUM
		if !(Alltrim(cMenAux) $ aRet[2])
			aRet[2] := cMenAux + ' ' + aRet[2]
		EndIF
		
		cmen := SC5->C5_MSGNOTA
		nTam := MlCount(cmen,80)
		cmenscli+=" "
		cMensAux:=''
		
		for _nI := 1 to nTam
			cMensAux+=MemoLine(cmen, 81, _nI, 3)   //antes 117
		next _nI
		
		if !(Alltrim(cMensAux) $ aRet[2])
			//	cmenscli+=cMensAux
			aRet[2] += alltrim(cMensAux)
		EndIF
		
		
		dbSelectArea('SC6')
		DBSetOrder(1)
		DbSeek(xFilial('SC6')+aD2[xi][1]+aD2[xi][2]+aPrd[xi][2])
	
		/*ALTERADO POR RODRIGO PARA BUSCAR CODIGO E DESCRICAO DO PRODUTO X CLIENTE*/
		//A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_PRODUTO
		
		dbselectArea('SA7')
		DBSetOrder(1)
		if DBSeek(xFilial('SA7')+SC6->C6_CLI+SC6->C6_LOJA+SC6->C6_PRODUTO)
			IF !Empty(SA7->A7_CODCLI)
				cProdCli:= SA7->A7_CODCLI
				aPrd[XI][2]:=cProdCli
			EndIF
			IF !Empty(SA7->A7_DESCCLI)
				cDesCli:= SA7->A7_DESCCLI
				aPrd[XI][4]:=cDesCli
			EndIF
			
		EndIF
		DBSetOrder(1)
		dbselectArea('SB1')
		DBSetOrder(1)
		//dbSeek(xFilial('SB1')+cProdx)
		dbSeek(xFilial('SB1')+SC6->C6_PRODUTO) //- EDITADO 09/10/2015
		
		
		If (Alltrim(SF2->F2_EST) <> "EX")    //INCLUIDO EM 07/07/2017 - TRATAMENTO DE UNIDADE DE MEDIDA PARA EXPORTACAO DIFERENTE DO NACIONAL - MARCOS SULIVAN -- Atualizado 08.02.2018 - Andre/rsac
			
			If !(Alltrim(SD2->D2_CF) $ "5501/6501")//5501-6501 - Trata a exporta indireta
				
				cUm := SB1->B1_UM
				cSegUm := SB1->B1_SEGUM
				cTpConv := SB1->B1_TIPCONV
				nConv := SB1->B1_CONV
				nQtd := 0
				nValTot := 0
				nValUnit := 0
					
				dbSelectArea('SD2')
				dbSetOrder(3)
				dbSeek(xFilial('SD2')+paramixb[5][2]+paramixb[5][1]+SC5->C5_CLIENTE+SC5->C5_LOJACLI+aPrd[xi][2]+aD2[xi][4])
					
				if SC6->C6_K_TPFAT == "2" //.and. ALLTRIM(SC6->C6_UM) != "M2"
				
						IF SB1->B1_TIPCONV == "M"
							If nConv == 1
									nQtd := SC6->C6_XQTDPC
								
								ElseIf ALLTRIM(cSegUm) <> "PC"
									nQtd := Round(SD2->D2_QUANT * nConv, 4)
								
								ElseIf ALLTRIM(cSegUm) == "PC"
									//Conforme solicitado pelo Aluisio foi adicionada esta tratativa, pois em casos especiais onde a seg und med é PC
									 //sera alterada a qtd multiplicando pela qtd. ( LUIS 22-02-2018 09:35 )
									If Alltrim(SB1->B1_XMUNDMK) == "S"
											nQtd := Round(SD2->D2_QUANT * nConv, 4)
										Else
											nQtd := SC6->C6_XQTDPC
									EndIf
							EndIF
							
							nValUnit := Round((SD2->D2_TOTAL+SD2->D2_DESCON+SD2->D2_DESCZFR) / nQtd, 4)
							cUm := cSegUm
							nValTot := nQtd*nValUnit
							
						Else
							if nConv==1
								nQtd := SC6->C6_XQTDPC
							ElseIf ALLTRIM(cSegUm) <> "PC"
								nQtd := Round(SC6->C6_QTDVEN / nConv, 4)
							ElseIf ALLTRIM(cSegUm) == "PC"
								
								nQtd := SC6->C6_XQTDPC
								
							EndIF
							
							nValTot := SD2->D2_TOTAL+SD2->D2_DESCON+SD2->D2_DESCZFR
							nValUnit := Round((SD2->D2_TOTAL+SD2->D2_DESCON+SD2->D2_DESCZFR)/ nQtd, 4)
							cUm := cSegUm
						EndIf
				
					Else
						nQtd 			:=  aPrd[XI][9]       
						nValTot 		:= 	aPrd[XI][10]
						nVAlUnit 		:=  aPrd[XI][10]/aPrd[XI][9]///aPrd[XI][16] //SC6->C6_PRCVEN
						cUm 			:= 	SB1->B1_UM
				EndIF
				
				aPrd[XI][8]:=cUm
				aPrd[XI][9]:=nQtd
				aPrd[XI][10]:=nValTot
				aPrd[XI][11]:=cUm
				aPrd[XI][12]:=nQtd
				aPrd[XI][16]:=nValUnit
			
			EndIf //Trata a exportacao indireta
			
		EndIf // MARCOS SULIVAN
		
	Next
	
	aRet[1]:=aPrd
	
	aRet[2] += " Os itens desta nota deverao ser conferidos no recebimento e qualquer divergencia fazer a "
	aRet[2] += " ressalva no conhecimento da transportadora e comunicar imediatamente o sac "
	aRet[2] += " 41 2106 0907. Os vencimentos dos boletos deverao ser acompanhados atraves da nota fiscal,"
	aRet[2] += " no caso do nao recebimento dos boletos, favor direcionar-se ao nosso "
	aRet[2] += " site WWW.KAPAZI.COM.BR 2 VIA DE BOLETO ou pelos telefones 41 2106 0948 /0996 /0933 /0964"
	
	aRet[2]	:= FwNoAccent(aRet[2])
	
EndIf //Fim do If se é NF de saída

aRet[2]	:= cRetKAP(aRet[2])

// ---------------------------------------------------
// INTREGRACAOO MADEIRAMADEIRA -- golive
// ---------------------------------------------------
If ExistBlock("M050202")
	cAutXml := U_M050202(SF2->F2_DOC,SF2->F2_SERIE)
Endif

Return aRet


//Retorna as informações da chave do cliente - NF de Remessa
//Devendo essa chave ser vinculada a chave simbolica da madeira madeira
Static Function RetCHVCl(cEmpAtK)
Local cRet		:= ""
Local cQry		:= ""
Local cAliasZM
Local nRegs 	:= 0

If Select("cAliasZM") <> 0
	DBSelectArea("cAliasZM")
	cAliasZM->(DBCloseArea())
Endif

cAliasZM		:= GetNextAlias()

cQry	+= " SELECT Z00_NUMPV AS PVMADEIR,Z00_NUMPV2 AS PVCLIENT,SC5.C5_NUM,SC5.C5_NOTA,SC5.C5_SERIE,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_CHVNFE

If cEmpAtK == "04"
		cQry	+= " FROM Z00040 Z00
		cQry	+= " INNER JOIN SC5040 AS SC5 ON Z00.Z00_FILIAL  = SC5.C5_FILIAL AND Z00.Z00_NUMPV2 = SC5.C5_NUM AND SC5.D_E_L_E_T_ = ''
		cQry	+= " INNER JOIN SF2040 AS SF2 ON Z00.Z00_FILIAL  = SF2.F2_FILIAL AND SF2.F2_DOC = SC5.C5_NOTA AND SF2.F2_SERIE = SC5.C5_SERIE AND SF2.D_E_L_E_T_=''
	
	ElseIf cEmpAtK == "01"
		cQry	+= " FROM Z00010 Z00
		cQry	+= " INNER JOIN SC5010 AS SC5 ON Z00.Z00_FILIAL  = SC5.C5_FILIAL AND Z00.Z00_NUMPV2 = SC5.C5_NUM AND SC5.D_E_L_E_T_ = ''
		cQry	+= " INNER JOIN SF2010 AS SF2 ON Z00.Z00_FILIAL  = SF2.F2_FILIAL AND SF2.F2_DOC = SC5.C5_NOTA AND SF2.F2_SERIE = SC5.C5_SERIE AND SF2.D_E_L_E_T_=''
		
EndIf
cQry	+= " WHERE	Z00.D_E_L_E_T_=''
cQry	+= "		AND Z00.Z00_NUMPV = '"+SC5->C5_NUM+"' 

Conout("")
Conout(cQry)
Conout("")

TcQuery cQry new Alias "cAliasZM"
Count to nRegs
cAliasZM->(DbGoTop())

If nRegs > 0
	cRet		+= "NF Remessa: "+cAliasZM->F2_CHVNFE + " - "
EndIf

cAliasZM->(DbCloseArea())
Return(cRet)


/*
aProd 		:= PARAMIXB[1]
cMensCli 	:= PARAMIXB[2]
cMensFis 	:= PARAMIXB[3]
aDest 		:= PARAMIXB[4]
aNota 		:= PARAMIXB[5]
aInfoItem := PARAMIXB[6]
aDupl 		:= PARAMIXB[7]
aTransp 	:= PARAMIXB[8]
aEntrega 	:= PARAMIXB[9]
aRetirada := PARAMIXB[10]
aVeiculo 	:= PARAMIXB[11]
aReboque 	:= PARAMIXB[12]
aNfVincRur:= PARAMIXB[13]
aEspVol 	:= PARAMIXB[14]
aNfVinc 	:= PARAMIXB[15]
AdetPag 	:= PARAMIXB[16]
*/


Static Function cRetKAP(cObjecto)
Local cStrKAPA	:= cObjecto

cStrKAPA := StrTran(cStrKAPA, 'nº', 'n')
cStrKAPA := StrTran(cStrKAPA, 'º', '')
cStrKAPA := StrTran(cStrKAPA, 'ª', '')
cStrKAPA := StrTran(cStrKAPA, '–', ' ')//-
//cStrProa := StrTran(cStrProa, '-', '')

Return(cStrKAPA)