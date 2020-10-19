#Include 'Protheus.ch'
#INCLUDE "RPTDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RFAT001
Relatório de declaração de bens materiais.
Pode ser chamado via PE no final do faturamento, ou via menu

@author Thiago Henrique dos Santos
@version P11
@since 15/10/2015
@return nil
/*/
//-------------------------------------------------------------------
User Function RFAT005()

Local cPerg := "RFAT005"
Local cAlias := ""


AjustaSX1(cPerg)

If IsInCallStatc("U_M460FIM")

	MV_PAR01 := SF2->F2_SERIE
	MV_PAR02 := SF2->F2_DOC
	MV_PAR03 := SF2->F2_DOC
	
ElseIf !Pergunte(cPerg)

	Return

Endif

Processa({ || cAlias := MontaQuery()},"Aguarde...","Processando Consulta..")

(cAlias)->(DbGoTop())

If (cAlias)->(Eof())
	
	ShowHelpDlg("Atenção",{"Não há dados a serem impressos"},1,;
		{"verifique os parâmetros informados."},2)
		Return

Endif

Processa({||PrintRel(cAlias)},"Aguarde...","Imprimindo...")

Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} PrintRel
Rotina de Impressão
	
@author Thiago Henrique dos Santos
@param cAlias - Alias temporário
@since 16/10/2015
@version P11
/*/
//-------------------------------------------------------------------------------

Static Function PrintRel(cAlias)
Local nLinObs := 0
Local nLin := 0
Local cNumero := ""
Local cObs := ""
Local nI := 0
Local nTotal := 0
Local oFont10		:= TFont():New("Calibri",,10,,.F.,,,,.F.,.F.)
Local oFont11N		:= TFont():New("Calibri",,11,,.T.,,,,.F.,.F.)
Local oFont10N		:= TFont():New("Calibri",,10,,.T.,,,,.F.,.F.)
Local oFont14N		:= TFont():New("Calibri",,14,,.T.,,,,,.F.,.F.)
Local oPrinter
Local cFile := "DECLARACAO_BENS_"+Dtos(MSDate())+"_"+StrTran(Time(),":","")
Local nLinAnt := 0

ProcRegua(0) 
IncProc("Imprimindo...")

oPrinter 	:= FWMSPrinter():New(cFile, IMP_SPOOL,,,.T.)
oPrinter:SetPortrait()
oPrinter:SetPaperSize(DMPAPER_A4)
oPrinter:SetMargin(30,30,00,00)	    
oPrinter:Setup()

While (cAlias)->(!Eof())

	IncProc("Imprimindo...")	
	If cNumero <> (cAlias)->(F2_DOC)
	
		//finalizapagina
		If !Empty(cNumero)
		
			
		
			nLin += 50
			oPrinter:Say(nLin,1340,"VALOR TOTAL DA DECLARAÇÃO",oFont10N)
			oPrinter:Say(nLin,1810,Transform(nTotal,"@E 99,999,999,999.99"),oFont10N)
			
			//box principal
			oPrinter:Line(nLinAnt - 30 , 020, nLin + 10, 020)
			oPrinter:Line(nLinAnt - 30 , 020, nLinAnt - 30, 2080)
			oPrinter:Line(nLin + 10, 020, nLin + 10 , 2080)
			oPrinter:Line(nLinAnt - 30 , 2080, nLin + 10, 2080)
			
			//linha cabeçalho
			oPrinter:Line(nLinAnt + 10 , 020, nLinAnt + 10, 2080)
			
			//linha qtD / UM
			oPrinter:Line(nLinAnt - 30 , 250, nLin + 10, 250)
			
			//linha UM / DESC
			oPrinter:Line(nLinAnt - 30 , 400, nLin + 10, 400)
			
			//linha desc / valor
			oPrinter:Line(nLinAnt - 30 , 1300, nLin + 10, 1300)
			oPrinter:Line(nLin - 30 , 1300, nLin - 30, 2080)
			
			//linha val unitario / total
			oPrinter:Line(nLinAnt - 30 , 1750, nLin - 30, 1750)

			nLin += 50
			oPrinter:Say(nLin,030,"OBS:",oFont10N)

			nLinObs := MlCount(cObs,130, 0,.T.)

			For nI := 1 to nLinObs

				oPrinter:Say(nLin,100,MemoLine(cObs, 130, nI, 0, .T.),oFont10)
				nLin += 30	

			Next nI
			
			
			
			nLin += 100
			oPrinter:Say(nLin,0030,"ASSINATURA TCP: ",oFont10)
			oPrinter:Say(nLin,0450,Replicate("_",60),oFont10)
			oPrinter:Say(nLin,1000,"ASSINATURA TRANSPORTADORA: ",oFont10)
			oPrinter:Say(nLin,1450,Replicate("_",60),oFont10)
            nLin += 60
			oPrinter:Say(nLin,0450,"NOME: ",oFont10)
			oPrinter:Say(nLin,1450,"NOME: ",oFont10)
            nLin += 60
			oPrinter:Say(nLin,0450,"SETOR: ",oFont10)
			oPrinter:Say(nLin,1450,"RG: ",oFont10)
            nLin += 60
			oPrinter:Say(nLin,1450,"CPF: ",oFont10)
            
			nLin += 100
			
			oPrinter:EndPage()
		
		
		Endif
		
		oPrinter:StartPage()
		
		cNumero := (cAlias)->(F2_DOC)
		nTotal := 0
		cObs := Alltrim((cAlias)->(C5_MENNOTA))
		
		
		oPrinter:Box( 020, 020, 230, 2290, "-8")
		oPrinter:SayBitmap( 030, 040,  "\sigaadv\lgrl01.bmp", 340, 120)
		nLin := 050
		oPrinter:Say(nLin,410,Alltrim(SM0->M0_NOMECOM),oFont11N)
		nLin += 40
		oPrinter:Say(nLin,410,Alltrim(SM0->M0_ENDENT)+"Tel/Fax: (41) 3420-3300",oFont10)
		nLin += 30
		oPrinter:Say(nLin,410,"Caixa Postal 169 - CEP: "+Transform(SM0->M0_CEPENT,PesqPict("SA2","A2_CEP")),oFont10)
		nLin += 30
		oPrinter:Say(nLin,410,"Cidade: "+Alltrim(SM0->M0_CIDENT) + " - Estado:" + SM0->M0_ESTENT+" - Brasil" ,oFont10)
		nLin += 30
		oPrinter:Say(nLin,410,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") ,oFont10)
		nLin += 30
		oPrinter:Say(nLin,410,"Inscrição Municipal: "+Alltrim(SM0->M0_INSCM) ,oFont10)
		nLin += 80
		
			
		oPrinter:Say(nLin,700,"DECLARAÇÃO DE BENS MATERIAIS" ,oFont14N)
		nLin += 100
		oPrinter:Say(nLin,030,"Número: "+cNumero,oFont10)
		oPrinter:Say(nLin,1500,"Data: "+dToC(SToD((cAlias)->F2_EMISSAO)),oFont10)
		nLin += 30
		oPrinter:Say(nLin,030,"Destinatário: "+Alltrim((cAlias)->A2_NOME),oFont10)
		nLin += 30
		oPrinter:Say(nLin,030,"Endereço: "+Alltrim((cAlias)->A2_END) + IIf(!Empty((cAlias)->A2_BAIRRO)," - "+;
										Alltrim((cAlias)->A2_BAIRRO),""),oFont10)
		nLin += 30
		oPrinter:Say(nLin,030,"Município: "+Alltrim((cAlias)->A2_MUN),oFont10)
		oPrinter:Say(nLin,900,"Estado: "+Alltrim((cAlias)->A2_EST),oFont10)
		nLin += 30
		oPrinter:Say(nLin,030,"CNPJ: "+Transform((cAlias)->A2_CGC,"@R 99.999.999/9999-99"),oFont10)
		oPrinter:Say(nLin,900,"Inscrição Municipal: "+Alltrim((cAlias)->A2_INSCR),oFont10)
		nLin += 30
		oPrinter:Say(nLin,030,"Transportador: "+Alltrim((cAlias)->A4_NOME),oFont10)
		nLin += 30
		oPrinter:Say(nLin,030,"Data da Saída: "+dToC(SToD((cAlias)->F2_EMISSAO)),oFont10)
		oPrinter:Say(nLin,1500,"Volume: "+cValToChar((cAlias)->F2_VOLUME1),oFont10)
		nLin += 50
		oPrinter:Say(nLin,030,Alltrim(SM0->M0_NOMECOM)+", não contribuinte do ICMS, portanto desobrigada da emissão de Notas",oFont11N)
		nLin += 30
		oPrinter:Say(nLin,030,"Fiscais, envia por meio desta os bens abaixo relacionados:",oFont11N)

		nLin += 100
		nLinAnt := nLin
		oPrinter:Say(nLin,180,"QTD.",oFont10N)
		oPrinter:Say(nLin,300,"U.M.",oFont10N)
		oPrinter:Say(nLin,450,"DESCRIÇÃO DOS MATERIAIS",oFont10N)
		oPrinter:Say(nLin,1500,"VALOR UNITÁRIO",oFont10N)
		oPrinter:Say(nLin,1900,"VALOR TOTAL",oFont10N)
		
	Endif	
	
	nLin += 30
	oPrinter:Say(nLin,030,Transform((cAlias)->D2_QUANT,"@E 99,999,999.99"),oFont10)
	oPrinter:Say(nLin,300,Alltrim((cAlias)->D2_UM),oFont10)

	cNSer := Posicione('SC6',1,xFilial('SC6')+(cAlias)->D2_PEDIDO+(cAlias)->D2_ITEMPV,"C6_XNUMSER")
	If !Empty(Alltrim(cNSer))
		cNSer := " - NS:"+cNSer
	EndIf
	
	oPrinter:Say(nLin,450,Substr((cAlias)->B1_DESC,1,30)+cNSer,oFont10)
	oPrinter:Say(nLin,1460,Transform((cAlias)->D2_PRCVEN,"@E 99,999,999,999.99"),oFont10)
	oPrinter:Say(nLin,1810,Transform((cAlias)->D2_TOTAL,"@E 99,999,999,999.99"),oFont10)
	
	nTotal += (cAlias)->D2_TOTAL
	
	
	
	(cAlias)->(DbSkip())
Enddo

oPrinter:Line(nLinAnt - 10 , 020, nLin, 020)

nLin += 50
oPrinter:Say(nLin,1340,"VALOR TOTAL DA DECLARAÇÃO",oFont10N)
oPrinter:Say(nLin,1810,Transform(nTotal,"@E 99,999,999,999.99"),oFont10N)

//box principal
oPrinter:Line(nLinAnt - 30 , 020, nLin + 10, 020)
oPrinter:Line(nLinAnt - 30 , 020, nLinAnt - 30, 2080)
oPrinter:Line(nLin + 10, 020, nLin + 10 , 2080)
oPrinter:Line(nLinAnt - 30 , 2080, nLin + 10, 2080)
			
//linha cabeçalho
oPrinter:Line(nLinAnt + 10 , 020, nLinAnt + 10, 2080)
			
//linha qtD / UM
oPrinter:Line(nLinAnt - 30 , 250, nLin + 10, 250)
			
//linha UM / DESC
oPrinter:Line(nLinAnt - 30 , 400, nLin + 10, 400)
			
//linha desc / valor
oPrinter:Line(nLinAnt - 30 , 1300, nLin + 10, 1300)
oPrinter:Line(nLin - 30 , 1300, nLin - 30, 2080)
			
//linha val unitario / total
oPrinter:Line(nLinAnt - 30 , 1750, nLin - 30, 1750)

nLin += 50
oPrinter:Say(nLin,030,"OBS:",oFont10N)
nLinObs := MlCount(cObs,130, 0,.T.)

For nI := 1 to nLinObs

	oPrinter:Say(nLin,100,MemoLine(cObs, 130, nI, 0, .T.),oFont10)
	nLin += 30	

Next nI


nLin += 100
oPrinter:Say(nLin,0030,"ASSINATURA TCP: ",oFont10)
oPrinter:Say(nLin,0300,Replicate("_",45),oFont10)

oPrinter:Say(nLin,1100,"TRANSPORTADORA: ",oFont10)
oPrinter:Say(nLin,1350,Replicate("_",45),oFont10)
nLin += 60
oPrinter:Say(nLin,0300,"NOME: ",oFont10)
oPrinter:Say(nLin,1350,"NOME: ",oFont10)
nLin += 60
oPrinter:Say(nLin,0300,"SETOR: ",oFont10)
oPrinter:Say(nLin,1350,"RG: ",oFont10)
nLin += 60
oPrinter:Say(nLin,1350,"CPF: ",oFont10)

nLin += 100



oPrinter:EndPage()
oPrinter:Preview()


Return


//-------------------------------------------------------------------------------
/*/{Protheus.doc} MontaQuery
Cria alias temporário
	
@author Thiago Henrique dos Santos
@param cPerg - Pergunta a ser criada
@since 16/10/2015
@version P11
@return cAlias - Nome do Alias
/*/
//-------------------------------------------------------------------------------
Static Function MontaQuery()
Local cAlias := GetNextAlias()
Local cTipo := "B"

ProcRegua(0) 
IncProc("Processando Consulta...")
IncProc("Processando Consulta...")

BeginSql Alias cAlias

	SELECT F2_DOC, F2_EMISSAO, A2_NOME, A2_END, A2_MUN, A2_EST, A2_BAIRRO, A2_CGC, A2_INSCR, A4_NOME,			
			(CASE F2_VOLUME1 WHEN 0 THEN 1 ELSE F2_VOLUME1 END) F2_VOLUME1,		
			D2_UM, D2_QUANT, D2_PRCVEN, D2_TOTAL, B1_DESC, C5_MENNOTA, D2_PEDIDO, D2_ITEMPV
	
	FROM %table:SD2% SD2
	
	INNER JOIN %table:SF2% SF2	
	ON F2_FILIAL = D2_FILIAL AND
		F2_SERIE = D2_SERIE AND
		F2_DOC = D2_DOC AND
		SF2.%NotDel%
		
	INNER JOIN %table:SA2% SA2
	ON A2_FILIAL =  %xFilial:SA2% AND
		A2_COD = F2_CLIENTE AND
		A2_LOJA = F2_LOJA AND
		SA2.%NotDel%
		
	LEFT JOIN %table:SA4% SA4
	ON A4_FILIAL =  %xFilial:SA4% AND
		A4_COD = F2_TRANSP AND
		SA4.%NotDel%
		
	INNER JOIN %table:SB1% SB1
	ON B1_FILIAL =  %xFilial:SB1% AND
		B1_COD = D2_COD AND
		SB1.%NotDel%
		
	INNER JOIN %table:SC5% SC5
	ON C5_FILIAL = D2_FILIAL AND
		C5_NUM = D2_PEDIDO AND
		C5_TIPO = %Exp:cTipo% AND
		SD2.%NotDel%
		
	WHERE D2_FILIAL = %xFilial:SD2% AND
		D2_DOC BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR03% AND
		D2_SERIE = %Exp:MV_PAR01% AND
		SD2.%NotDel% 
		
EndSql


Return cAlias

//-------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria a pergunta do relatório
	
@author Thiago Henrique dos Santos
@param cPerg - Pergunta a ser criada
@since 16/10/2015
@version P11
@return nil
/*/
//-------------------------------------------------------------------------------
Static Function AjustaSX1(cPerg)
																					
	Local aHelpPerg  := {}
		
	aAdd(aHelpPerg,{"Digite a série do documento."})
					
	aAdd(aHelpPerg,{"Digite o número do documento inicial",;
					"que deseja imprimir."})

	aAdd(aHelpPerg,{"Digite o número do documento final",;
					"que deseja imprimir."})	
					
	//PutSx1(cPerg,"01","Série?"  ,"","","mv_ch1","C",TamSx3("F2_SERIE")[1],0, ,"G","","","","","mv_par01",""       ,;
//		"","","",""           ,"","",""        ,"","",""     ,"","","","","",aHelpPerg[1] ,{},{})
//		
//	//PutSx1(cPerg,"02","De Documento?"  ,"","","mv_ch2","C",TamSx3("F2_DOC")[1],0, ,"G","","SF2","018","","mv_par02",""       ,;
//		"","","",""           ,"","",""        ,"","",""     ,"","","","","",aHelpPerg[2] ,{},{})
//		
//	//PutSx1(cPerg,"03","Até DocumeNto?"  ,"","","mv_ch3","C",TamSx3("F2_DOC")[1],0, ,"G","","SF2","018","","mv_par03",""       ,;
//		"","","",""           ,"","",""        ,"","",""     ,"","","","","",aHelpPerg[3] ,{},{})
		
	
Return