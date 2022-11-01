#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER023.CH"
#INCLUDE "TOPCONN.CH"

/*����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������Ŀ��
���Fun��o  �GPER023       � Autor   � Leandro Ripoll Saldanha         Data �    05/2013���
��			     Versao do Padrao	� Claudinei Soares                Data � 20/05/2016���
��������������������������������������������������������������������������������������Ĵ��
���Diego Tedeschi Franco - 11/08/2015 - Altera��es novo layout                         ���
#Tarefa 34474#                                                                         ���
���Descri��o    � Gera��o arquivo Transpar�ncia - Lei Federal 12.115                   ���
��������������������������������������������������������������������������������������Ĵ��
���Sintaxe   	� GPEM045()                                                   		   ���
��������������������������������������������������������������������������������������Ĵ��
��� Uso      	� Generico (DOS e Windows)                                   		   ���
��������������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.               		   ���
��������������������������������������������������������������������������������������Ĵ��
���Programador  � Data     � FNC			�  Motivo da Alteracao                     ���
��������������������������������������������������������������������������������������Ĵ��
���Claudinei S. �20/05/2016� TUSNZF         �Criacao do novo fonte, e ajustada a rotina���
���             �          �                �customizada para o padr�o, alterado o     ���
���             �          �                �leiaute conforme a legisla��o.            ���
���Claudinei S. �15/06/2016� TUSNZF         �Ajustada a query para buscar as verbas,   ���
���             �          �                �alterados os t�tulos de GF para FG e ajus-���
���             �          �                �tado o CPF para ser impresso integralmente���
���Claudinei S. �18/07/2016� TUSNZF         �Ajustada a query para buscar as verbas,   ���
���             �          �                �Ajustada a gera��o de zeros a esquerda na ���
���             �          �                �planilha e a leitura das verbas informadas���
���Paulo O.     �01/08/2016� TUSNZF         �Ajuste para o cabe�alho do arquivo somente���
���Inzonha      �          �                �Ocupar uma linha                          ���
���������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������*/

#define DMPAPER_A4 9
// A4 210 x 297 mm

User Function GPER023()

	Local cPerg    := "GPR023"
	Local aAreaSX1 := SX1->( Getarea("SX1") )
	Local oSX1
	Local lContinua := .F.

	Private aFldRot 	:= {'RA_NOME', 'RA_SEXO'}
	Private aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
	Private lOfuscaNom 	:= .F. 
	Private lOfuscaSexo	:= .F. 
	Private aFldOfusca	:= {}

	If aOfusca[2]
		aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
		IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
			lOfuscaNom := FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
		ENDIF
		IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_SEXO" } ) > 0
			lOfuscaSexo := FwProtectedDataUtil():IsFieldInList( "RA_SEXO" )
		ENDIF		
	ENDIF

	If GetApoInfo("MSLIB.PRW")[4] >= CTOD("04/09/2018")
		oSX1 := FWSX1Util():New()
	
		oSX1:AddGroup(cPerg)
		oSX1:SearchGroup()
	
		If Len(oSX1:aGrupo) > 0
			lContinua := .T.
		EndIf
	
		FreeObj(oSX1)
	Else
		DbSelectArea("SX1")
		DbSetorder(1)
	
		If SX1->( DbSeek(cPerg) )
			lContinua := .T.
		EndIf
	EndIf

	If lContinua
		//Abre Par�metros do relat�rio
		If Pergunte( cPerg , .T. , OemToAnsi(STR0001) ) //"Gera arquivo Lei Transpar�ncia"
			If MV_PAR01 == 2
				Processa( {|| fGeraRubri() }, OemToAnsi(STR0002), OemToAnsi(STR0003),.F. ) // "Aguarde...." "Gerando Arquivos... "
			Else
				Processa( {|| fGeraVincu() }, OemToAnsi(STR0002), OemToAnsi(STR0003),.F. )// "Aguarde...." "Gerando Arquivos..."
			EndIf
		Endif
	Else
		MsgInfo(OemToAnsi(STR0054),cPerg) //"Grupo de perguntas GPR023 n�o encontrado!"
	EndIf

	Restarea( aAreaSX1 )

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o  �fGeraVincu� Autor � Leandro Ripoll Saldanha � Data � 06/2013  ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function fGeraVincu()
	
	Local cData			:= ""
	Local cMsg			:= ""
	Local cCpf			:= ""
	Local cSituacao		:= ""
	Local cVerbaProv	:= ""
	Local cVerbaDesc	:= ""
	Local cVerbaIN		:= ""
	Local nHandle_CSV	:= 0
	Local nTotBruta		:= 0
	Local nVantEvent	:= 0
	Local nGratNatal	:= 0 
	Local nAbonoPerm	:= 0 
	Local nParcInd		:= 0
	Local nTcreditos	:= 0
	Local nDesclegal	:= 0
	Local nDescAutor	:= 0
	Local nTotDescon	:= 0
	Local nLiquido		:= 0
	Local ni			:= 0
	Local nj			:= 0
	Local nA			:= 0
	Local nColuna		:= 0
	Local nLargur		:= 0159
	Local nAltura    	:= 0050
	Local nLargur2 		:= 0430
	Local nLargur3   	:= 0250
	Local nLargur4   	:= 0120
	Local nLargur6		:= 0070
	Local nLargur7		:= 0100
	Local nLargur8		:= 0140
	Local nLargur9		:= 0030
	Local aItem 		:= {}
	Local aDadosTMP		:= {}
	Local cAliasQry		:= GetNextAlias()
	Local cAliasFil		:= GetNextAlias()
	
	Private aDados		:= {}
	Private aDados2		:= {}
	Private nLarg		:= 0
	Private nAlt		:= 0
	
	//Agrupa todas as verbas que foram informadas nos 4 perguntes
	//e monta o 'IN' com elas para a Query
	cVerbaProv := StrTran(Alltrim(MV_PAR06) + Alltrim(MV_PAR07), "*", "")
	cVerbaDesc := StrTran(Alltrim(MV_PAR08)	+ Alltrim(MV_PAR09), "*", "")
	
	If SRV->(ColumnPos("RV_TRANSPA")) > 0 
		If Empty(cVerbaProv + cVerbaDesc)
			cVerbaIN := "SELECT DISTINCT RV_COD FROM " + RetSqlName('SRV') + " WHERE RV_TIPOCOD IN ('1','2') AND RV_TRANSPA = '1' " 
		Else
			If Empty(cVerbaProv)
				cVerbaIN := "SELECT DISTINCT RV_COD FROM " + RetSqlName('SRV') + " WHERE (RV_TIPOCOD = '1' AND RV_TRANSPA = '1') " 
				cVerbaIN += "OR RV_COD IN (" + fSqlIN(cVerbaDesc, 3) + " )"
			Else
				cVerbaIN := "SELECT DISTINCT RV_COD FROM " + RetSqlName('SRV') + " WHERE (RV_TIPOCOD = '2' AND RV_TRANSPA = '1') " 
				cVerbaIN += "OR RV_COD IN (" + fSqlIN(cVerbaProv, 3) + " )"
			EndIf
		EndIf
		
	ElseIf !Empty(cVerbaProv + cVerbaDesc )
		cVerbaIN := fSqlIN( cVerbaProv + cVerbaDesc, 3 )
	Else 
		MsgAlert(STR0055, STR0006) // "Necess�rio informar as verbas para a gera��o do arquivo." # Aten��o
	EndIf
	
	cVerbaIN := "%(" + cVerbaIN + ")%"
	cData := Substr(MV_PAR02, 5, 2) + "/" + Substr(MV_PAR02, 1, 4)
	
	// Selecionando dados com Query
	
	BeginSql Alias cAliasFil
		SELECT DISTINCT RA_FILIAL 
		FROM %Table:SRA% SRA
		WHERE RA_FILIAL != '' AND 
		SRA.%NotDel%
	EndSQL
	
	While (cAliasFil)->(!EoF())
		
		BeginSql Alias cAliasQry
			COLUMN ADMISSAO AS DATE
			SELECT SRD.RD_MAT AS MAT, SRA.RA_NOME AS NOME, SQ3.Q3_DESCSUM AS CARGO, SRA.RA_SEXO AS SEXO, SRD.RD_PD AS VERBA, SRD.RD_VALOR AS VALOR, SRD.RD_DATARQ AS DATAARQ,
			SRA.RA_ADMISSA AS ADMISSAO, SRA.RA_CIC AS CPF, SRA.RA_HRSEMAN AS CARGA_HORARIA, SRA.RA_SITFOLH AS SITUACAO, SRA.RA_CODFUNC AS FUNCAO, SRV.RV_TIPOCOD AS TIPO
			FROM %Table:SRD% AS SRD 
			INNER JOIN %Table:SRA% AS SRA
			ON SRD.RD_FILIAL = SRA.RA_FILIAL
			AND SRD.RD_MAT = SRA.RA_MAT
			LEFT JOIN %Table:SQ3% AS SQ3
			ON SRA.RA_CARGO = SQ3.Q3_CARGO AND 
			(SRA.RA_CC = SQ3.Q3_CC OR SQ3.Q3_CC = '') 
			LEFT JOIN %Table:SRV% SRV
			ON SRV.RV_COD = SRD.RD_PD
			AND SRV.RV_FILIAL = %Exp:xFilial("SRV", (cAliasFil)->RA_FILIAL)% 
			WHERE SRA.RA_CATFUNC IN ('M', 'A') AND SRA.RA_SITFOLH IN (' ', 'A', 'F', 'D') AND SRD.RD_ROTEIR IN ('FOL','AUT','132') AND SRD.RD_DATARQ = %Exp:MV_PAR02%
			AND SRD.RD_PD IN %Exp:cVerbaIN% AND 
			SQ3.Q3_FILIAL = %Exp:xFilial("SQ3", (cAliasFil)->RA_FILIAL)% AND
			SRA.RA_FILIAL = %Exp:(cAliasFil)->RA_FILIAL%
			AND SRD.%NotDel% AND SRA.%NotDel% AND SQ3.%NotDel%
			ORDER BY SRA.RA_NOME
			
		EndSQL
		
		While (cAliasQry)->(!EOF())
			
			nTotBruta  := 0
			nVantEvent := 0
			nGratNatal := 0
			nAbonoPerm := 0
			nParcInd   := 0
			nTcreditos := 0
			nDesclegal := 0
			nDescAutor := 0
			nTotDescon := 0
			nLiquido   := 0
			
			aItem      := {}
			
			AADD(aItem, (cAliasQry)->DATAARQ)  														//01-AnoM�s
			AADD(aItem, If(MV_PAR04 == 3, "F�RIAS", If(MV_PAR04 == 2, "MENSAL", "CONSOLIDADO")))	//02-Tipo Folha
			AADD(aItem, MV_PAR05)																	//03-�rg�o
			AADD(aItem, If(lOfuscaNom, Replicate('*',15), Alltrim((cAliasQry)->NOME)))				//04-Nome do Servidor
			AADD(aItem, If(lOfuscaNom, '*', Alltrim((cAliasQry)->SEXO)))							//05-Sexo
			AADD(aItem, (cAliasQry)->MAT)															//06-Matr�cula
			AADD(aItem, Vinculo(Alltrim((cAliasQry)->CARGO), Alltrim((cAliasQry)->FUNCAO)))			//07-Tipo_Vinculo
			AADD(aItem, DTOC((cAliasQry)->ADMISSAO))												//08-Data Ingresso
			AADD(aItem, Alltrim((cAliasQry)->CARGO))												//09-Cargo
			AADD(aItem, "")																			//10-Referencia Cargo
			AADD(aItem, (cAliasQry)->CARGA_HORARIA)													//11-Carga Horaria Cargo
			AADD(aItem, Gf((cAliasQry)->FUNCAO))													//12-Fun��o
			AADD(aItem, "")																			//13-Refer�ncia da Fun��o
			AADD(aItem, Gf((cAliasQry)->FUNCAO))													//14-FG
			AADD(aItem, "")																			//15-Refer�ncia da FG
			AADD(aItem, "0")																		//16-Adicional
			AADD(aItem, "0")																		//17-Avan�o
			
			cSituacao	:= (cAliasQry)->SITUACAO
			cCpf		:= (cAliasQry)->CPF
			
			cMatricula := (cAliasQry)->MAT
			
			While cMatricula == (cAliasQry)->MAT
				
				If (cAliasQry)->TIPO $ '1*3'
					nTotBruta += (cAliasQry)->VALOR
				Else
					nDesclegal += (cAliasQry)->VALOR
				Endif
				
				(cAliasQry)->(dbSkip())
				
			EndDo
			
			nLiquido := nTotBruta - nDesclegal
			
			AADD(aItem, StrTran(cValToChar(nTotBruta), ".", ",")) 	//18
			AADD(aItem, StrTran(cValToChar(nDesclegal), ".", ","))	//19
			AADD(aItem, StrTran(cValToChar(nLiquido), ".", ","))  	//20
			AADD(aItem, Situacao(Alltrim(cSituacao)))           	//21
			AADD(aItem, cCpf)                                   	//22
			AADD(aItem, OemToAnsi(STR0004))	               		 	//23    // Porto Alegre
			
			AADD(aDados, aItem)
			
		EndDo
		
		(cAliasQry)->(dbCloseArea())
		
		(cAliasFil)->(dbSkip())
	EndDo
	
	(cAliasFil)->(dbCloseArea())
	
	//�����������������������������������������������������������Ŀ
	//�Cria o Arquivo CSV                                         �
	//�������������������������������������������������������������
	
	nHandle_CSV	:= FCREATE(MV_PAR03)
	IF Ferror() # 0 .AND. nHandle_CSV = -1
		cMsg := OemToAnsi(STR0005) + STR(FERROR(),2) //"Erro de abertura, codigo DOS:"
		Aviso( OemToAnsi(STR0006), cMsg, { OemToAnsi(STR0007) } ) //Aten��o  OK
	Return
	EndIF
	
	fWrite(nHandle_CSV,"AnoM�s;Tipo Folha;�rg�o;Nome do Servidor;Sexo;Matricula;Tipo_Vinculo;Data_Ingresso;Cargo;Referencia	Cargo;Carga_Horaria Cargo;Fun��o;Refer�ncia Fun��o;FG;Refer�ncia_FG;Adicional;Avan�o;Remunera��o Total Bruta;Descontos Legais;Total L�quido;Situa��o;CPF;Munic�pio" + CHR(13) + CHR(10) )
	
	aDados2 := aClone(aDados) 
	
	For ni = 1 To Len(aDados2)
		For nj = 1 to Len(aItem)
			If nj == 6 .Or. nj == 22
				aDados2[ni,nj] := '="'+aDados2[ni,nj]+'"'	
			Endif
			If nj = Len(aItem)
				fWrite(nHandle_CSV,CvalToChar(aDados2[ni,nj]) + CHR(13) + CHR(10) )
			Else
				fWrite(nHandle_CSV,CvalToChar(aDados2[ni,nj]) + ";" )
			Endif
		Next nj
	Next ni
	
	Fclose(nHandle_CSV)
	
	If(MsgYesNo(OemToAnsi(STR0011) + Alltrim(MV_PAR03) + OemToAnsi(STR0012),OemToAnsi(STR0013))) //"O arquivo " # " foi gerado! Clique em Sim para gerar o arquivo PDF.","Lei da Transpar�ncia"
	
		//�����������������������������������������������������������Ŀ
		//�Cria o Arquivo PDF                                         �
		//�������������������������������������������������������������
		
		oPrint := TMSPrinter():New()
		oPrint:SetLandscape()
		oPrint:Setup()
		
		nLarg := oPrint:nHorzRes()
		nAlt  := oPrint:nVertRes()
		
		//Fontes
		oCabecal  := TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)
		oTitulos  := TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)
		oDados    := TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)
		oDados2   := TFont():New("Arial",05,05,,.T.,,,,.T.,.F.)
		
		//Monta P�gina e Cabe�alho
		oPrint:StartPage()
		
		MCabecVinc(cData,oCabecal,oTitulos,nLargur,nAltura,nLargur)
		
		aDadosTMP	:= aDados
		aDados		:= {}
		
		//Monta novamente o array aDados sem o item 1
		For nA:= 1 to Len(aDadosTMP)
			AADD(aDados,{aDadosTMP[nA][2],aDadosTMP[nA][3],aDadosTMP[nA][4],aDadosTMP[nA][5],aDadosTMP[nA][6],;
				aDadosTMP[nA][7],aDadosTMP[nA][8],aDadosTMP[nA][9],aDadosTMP[nA][11],aDadosTMP[nA][12],;
				aDadosTMP[nA][13],aDadosTMP[nA][18],aDadosTMP[nA][19],aDadosTMP[nA][20],aDadosTMP[nA][21],;
				aDadosTMP[nA][22],aDadosTMP[nA][23]})
		Next nA
		
		//Preenche dados
		nLinha := 0555
		For ni = 1 To Len(aDados)
			nColuna := 0025
			For nj = 1 to Len(aDados[ni])
				If nj == 1
					oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados) // Tipo Folha
					nColuna += nLargur + nLargur9
				ElseIf nj == 2
					oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //�rg�o
					nColuna += nLargur6+nlargur9
				ElseIf nj == 3
					oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //Nome
					nColuna += nLargur2+nlargur9
				ElseIf nj == 4
					oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2)	//Sexo
					nColuna += nLargur6+nlargur9
				ElseIf nj == 5
					oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //Matricula
					nColuna += nLargur7+nlargur9
				ElseIf nj == 6
					oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) // Tipo Vinculo
					nColuna += nLargur7+nlargur9
				ElseIf nj == 7
					oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //Data Ingresso
					nColuna += nLargur8+nlargur9
				ElseIf nj == 8
					oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //Cargo
					nColuna += nLargur2+nlargur9
				ElseIf nj == 9
					oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //Carga Horaria Cargo
					nColuna += nLargur4+nlargur9
				ElseIf nj == 10
					oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //Fun��o
					nColuna += nLargur3+nLargur7//nLargur2 + nLargur9
				ElseIf nj == 14
					oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //Total L�quido
					nColuna += nLargur4 + nLargur9
				ElseIf nj == 15
					oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //Total L�quido
					nColuna += nLargur4
				ElseIf nj == 16
					oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2)
					nColuna += nLargur4 + nLargur9
				Else
					oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados)
					nColuna += nLargur+nlargur9
				Endif
			Next nj
			nLinha += nAltura
			
			//Salto de p�gina
			If nLinha >= nAlt - 55
				oPrint:EndPage()
				oPrint:StartPage()
				MCabecVinc(cData,oCabecal,oTitulos,nLargur,nAltura,nLargur)
				nLinha := 0555
			Endif
			
		Next ni
		
		oPrint:EndPage()
		//Mostra relat�rio na Tela
		oPrint:Preview()
	EndIf
	
Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o  �fGeraRubri� Autor � Leandro Ripoll Saldanha � Data � 06/2013  ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/

Static Function fGeraRubri()
	
	Local cQuery		:= "" 
	Local cData			:= ""
	Local cMsg			:= ""
	Local cCpf			:= ""
	Local cSituacao		:= ""
	Local nHandle_CSV	:= 0
	Local nTotBruta		:= 0
	Local nVantEvent	:= 0
	Local nGratNatal	:= 0 
	Local nAbonoPerm	:= 0 
	Local nParcInd		:= 0
	Local nTcreditos	:= 0
	Local nDesclegal	:= 0
	Local nDescAutor	:= 0
	Local nTotDescon	:= 0
	Local nLiquido		:= 0
	Local ni			:= 0
	Local nj			:= 0
	Local nA			:= 0
	Local nColuna		:= 0
	Local nColuna2		:= 0
	Local nColuna3		:= 0
	Local nLargur		:= 0159
	Local nAltura    	:= 0050
	Local nLargur2 		:= 0430
	Local nLargur3   	:= 0250
	Local nLargur4   	:= 0120
	Local nLargur5		:= 0290
	Local nLargur6		:= 0070
	Local nLargur7		:= 0100
	Local nLargur8		:= 0140
	Local nLargur9		:= 0030
	Local aItem 		:= {}
	Local aDadosTMP		:= {}
	
	Private aDados		:= {}
	Private nLarg		:= 0
	Private nAlt		:= 0
	
	//������������������������������������Ŀ
	//� Selecionando dados com Query       �
	//��������������������������������������
	
	cQuery := "SELECT	a.RD_PERIODO AS AnoMes, a.RD_MAT AS MAT, a.RD_PD AS PD,a.RD_DATARQ AS DATAARQ," + chr(13)
	cQuery += "b.RV_DESC AS DESCPD, SUBSTRING(a.RD_PERIODO,1,4)+SUBSTRING(a.RD_PERIODO,5,6) AS COMPETE," + chr(13) 
	cQuery += "a.RD_VALOR AS VALOR, case when b.RV_TIPOCOD = '1' then 'VANTAGEM' else 'DESCONTO' end as TP_VAL," + chr(13)
	cQuery += " case when b.RV_TIPOCOD = '1' then 'VANTAGEM' else 'DESCONTO' end as TP_RUB" + chr(13)
	cQuery += " FROM " + RetSqlname('SRD') + " AS a INNER JOIN " + RetSqlName('SRV') + " AS b " + chr(13)
	cQuery += " ON a.RD_PD = b.RV_COD"  + chr(13)
	cQuery += " INNER JOIN " + RetSqlname('SRA') + " AS c" + chr(13)
	cQuery += " ON a.RD_MAT = c.RA_MAT" + chr(13)
	cQuery += " WHERE b.RV_TIPOCOD IN ('1','2') AND a.RD_PERIODO = '" + MV_PAR02 + "'" + chr(13)	
	cQuery += " AND a.D_E_L_E_T_ <> '*' AND b.D_E_L_E_T_ <> '*' AND c.D_E_L_E_T_ <> '*' " + chr(13)
	cQuery += " ORDER BY a.RD_MAT, a.RD_PD " + chr(13)
	
	//����������������������������������������Ŀ
	//� Cria alias conforme resultado da query �
	//������������������������������������������
	
	If Select("TEMP") >0
		dbSelectArea("TEMP")
		dbCloseArea()
	EndIf
	
	TCQUERY cQuery NEW ALIAS "TEMP"
	
	DBSelectArea("TEMP") //ABRE O ARQUIVO TEMPORARIO
	dbGoTop()          	// ALINHA NO PRIMEIRO REGISTRO
	
	cData := Substr(TEMP->DATAARQ,5,2) + "/" + Substr(TEMP->DATAARQ,1,4)
	
	While !TEMP->(EOF())
		
		aItem      := {}
		
		AADD(aItem,TEMP->DATAARQ)  																//01-AnoM�s
		AADD(aItem,If(MV_PAR04 == 4, "F�RIAS", If(MV_PAR04 == 2, "MENSAL", "CONSOLIDADO")))		//02-Tipo Folha
		AADD(aItem,MV_PAR05)																	//03-�rg�o
		AADD(aItem,TEMP->MAT)																	//04-Matr�cula
		AADD(aItem,TEMP->PD)																	//05-Rubrica de Pagamento
		AADD(aItem,TEMP->DESCPD)																//06-Descri��o da R�brica
		AADD(aItem,"Pagto.Integral")															//07-Hist�rico/Observa��o
		AADD(aItem,TEMP->COMPETE)																//08-Compet�ncia do Lan�amento
		AADD(aItem,"")																			//09-Tipo Lan�amento
		AADD(aItem,TEMP->VALOR)																	//10-Valor
		AADD(aItem,TEMP->TP_VAL)																//11-Tipo de Valor
		AADD(aItem,TEMP->TP_RUB)																//12-Tipo de Rubrica
		AADD(aItem,"SIM")																		//13-Exibir Rubrica Transpar�ncia
		
		AADD(aDados,aItem)
		
		TEMP->(dbSkip())	
	Enddo
	
If Select("TEMP") >0
	dbSelectArea("TEMP")
	dbCloseArea()
EndIf

//�����������������������������������������������������������Ŀ
//�Cria o Arquivo CSV                                         �
//�������������������������������������������������������������

nHandle_CSV	:= FCREATE(MV_PAR03)
IF Ferror() # 0 .AND. nHandle_CSV = -1
	cMsg := OemToAnsi(STR0005) + STR(FERROR(),2) //"Erro de abertura, codigo DOS:"
	Aviso( OemToAnsi(STR0006), cMsg, { OemToAnsi(STR0007) } ) //Aten��o  OK
Return
EndIF

fWrite(nHandle_CSV,"AnoM�s;Tipo Folha;�rg�o;Matricula	;Rubrica de Pagamento;Descri��o da Rubrica ;Hist�rico/Observa��o ;Compet�ncia do Lan�amento;Tipo Lan�amento;Valor;Tipo de Valor;Tipo de Rubrica;Exibir Rubrica Transpar�ncia" + CHR(13) + CHR(10) )

For ni = 1 To Len(aDados)
	For nj = 1 to Len(aItem)
		If nj = Len(aItem)
			fWrite(nHandle_CSV,CvalToChar(aDados[ni,nj]) + CHR(13) + CHR(10) )
		Else
			fWrite(nHandle_CSV,CvalToChar(aDados[ni,nj]) + ";" )
		Endif
	Next nj
Next ni

Fclose(nHandle_CSV)

If(MsgYesNo(OemToAnsi(STR0011) + Alltrim(MV_PAR03) + OemToAnsi(STR0012),OemToAnsi(STR0013))) //"O arquivo " # " foi gerado! Clique em Sim para gerar o arquivo PDF.","Lei da Transpar�ncia"

	//�����������������������������������������������������������Ŀ
	//�Cria o Arquivo PDF                                         �
	//�������������������������������������������������������������

	oPrint := TMSPrinter():New()
	oPrint:SetPortrait()
	//oPrint:SetLandscape()
	oPrint:Setup()

	nLarg := oPrint:nHorzRes()
	nAlt  := oPrint:nVertRes()

	//Fontes
	oCabecal  := TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)
	oTitulos  := TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)
	oDados    := TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)
	oDados2   := TFont():New("Arial",05,05,,.T.,,,,.T.,.F.)

	//Monta P�gina e Cabe�alho
	oPrint:StartPage()

	MCabecRubr(cData,oCabecal,oTitulos,nLargur,nAltura,nLargur)

	aDadosTMP	:= aDados
	aDados		:= {}
	
	//Monta novamente o array aDados sem o item 1
	For nA:= 1 to Len(aDadosTMP)
		AADD(aDados,{aDadosTMP[nA][2],aDadosTMP[nA][3],aDadosTMP[nA][4],aDadosTMP[nA][5],aDadosTMP[nA][6],;
					 aDadosTMP[nA][7],aDadosTMP[nA][8],aDadosTMP[nA][9],aDadosTMP[nA][10],aDadosTMP[nA][11],;
					 aDadosTMP[nA][12],aDadosTMP[nA][13]})
	Next nA

	//Preenche dados
	nLinha := 0555
	For ni = 1 To Len(aDados)
		nColuna := 0025
		For nj = 1 to Len(aDados[ni])
			If nj == 1
				oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados) // Tipo Folha
				nColuna += nLargur + nLargur9
			ElseIf nj == 2
				oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //�rg�o
				nColuna += nLargur6+nlargur9
			ElseIf nj == 3
				oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //Matr�cula
				nColuna += nLargur7+nlargur9
			ElseIf nj == 4
				oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2)	//Rubrica de Pagamento
				nColuna += nLargur4+nlargur9
			ElseIf nj == 5
				oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //Descri��o da R�brica
				nColuna += nLargur2
			ElseIf nj == 6
				oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) // Hist�rico/Observa��o
				nColuna += nLargur3
			ElseIf nj == 7
				oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //Compet�ncia do Lan�amento
				nColuna += nLargur8+nlargur9
			ElseIf nj == 8
				oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //Tipo Lan�amento
				nColuna += nLargur4+nlargur8
			ElseIf nj == 9
				oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //Valor
				nColuna += nLargur4
			ElseIf nj == 10
				oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //Tipo do Valor
				nColuna += nLargur4 + nLargur6
			ElseIf nj == 11
				oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //Tipo de R�brica
				nColuna += nLargur8 + nLargur6
			ElseIf nj == 12
				oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados2) //Exibir R�brica de Pagamento
				nColuna += nLargur7 + nLargur4				
			Else
				oPrint:Say(nLinha, ncoluna, CvalToChar(aDados[ni,nj]), oDados)
				nColuna += nLargur+nlargur9
			Endif
			
		Next nj
		nLinha += nAltura
		
		//Salto de p�gina
		If nLinha >= nAlt - 55
			oPrint:EndPage()
			oPrint:StartPage()
			MCabecRubr(cData,oCabecal,oTitulos,nLargur,nAltura,nLargur)
			nLinha := 0555
		Endif
		
	Next ni
	
	oPrint:EndPage()
	//Mostra relat�rio na Tela
	oPrint:Preview()
endif

Return()


//����������������������������������������������������Ŀ
//� Fun��o para montar p�gina e cabe�alho dos v�nculos �
//������������������������������������������������������
Static Function MCabecVinc(cData,oCabecal,oTitulos,nLargur,nAltura,nLargur)

	Local nLinhaINI		:= 0045
	Local nLinhaFIM		:= nAlt - nLinhaINI
	Local nColunaINI	:= 0010
	Local nGridINI		:= 0440
	Local nLinhaCabec	:= 0270
	Local nColunaQ		:= 0
	Local nCont			:= 1
	Local nLargur2		:= 0430
	Local nLargur3   	:= 0250
	Local nLargur4   	:= 0120
	Local nLargur5		:= 0290
	Local nLargur6		:= 0070
	Local nLargur7		:= 0100
	Local nLargur8		:= 0140
	Local nLargur9		:= 0030

	//Monta Contorno e Linhas
	oPrint:Box(nLinhaINI,nColunaINI,nAlt-nLinhaINI,nLarg-nColunaINI)
	nLinhaGrid := nGridINI
	While nLinhaGrid < nLinhaFIM //(nLinhaFIM - nAltura)
		oPrint:Line(nLinhaGrid, nColunaINI, nLinhaGrid, nLarg-nColunaINI)
		If nLinhaGrid == nGridINI
			nLinhaGrid += (2 * nAltura)
		Else
			nLinhaGrid += nAltura
		Endif
	End

	//Monta/Desenha as Colunas
	nColuna := nColunaINI + nLargur + nLargur9
	While nColuna < (nLarg-nColunaINI) .AND. nCont <= 17

		If (nCont == 0 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Tipo Folha
			nColuna += 0

		ElseIf(nCont == 1 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) // �rg�o
			nColuna += nLargur6 + nLargur9

		ElseIf(nCont == 2 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Nome
			nColuna += nLargur2 + nLargur9

		ElseIf(nCont == 3 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Sexo
			nColuna += nLargur6 + nLargur9
			
		ElseIf(nCont == 4 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Matr�cula
			nColuna += nLargur7 + nLargur9

		ElseIf(nCont == 5 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Tipo Vinculo
			nColuna += nLargur7 + nLargur9

		ElseIf(nCont == 6 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Data Ingresso
			nColuna += nLargur8 + nLargur9

		ElseIf(nCont == 7 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Cargo
			nColuna += nLargur2 + nLargur9
		
		ElseIf(nCont == 8 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Carga Horaria Cargo
			nColuna += nLargur4 + nLargur9

		ElseIf(nCont == 9 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Fun��o
			nColuna += nLargur3 + nLargur6
			
		ElseIf(nCont == 10 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Refer�ncia Fun��o
			nColuna += nLargur8 + nLargur9
	
		ElseIf(nCont == 14 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Situa��o
			nColuna += nLargur4

		ElseIf(nCont == 15 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //CPF
			nColuna += nLargur4 + nLargur9
		ElseIf(nCont == 16 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //CPF
			nColuna += nLargur6		
		ElseIf(nCont == 11 .Or. nCont == 12 .Or. nCont == 13)
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna)
			nColuna += nLargur + nLargur9
		Endif

		nCont++
	End

	//Logo - Posi��o fixa
	oPrint:SayBitmap(0080,0175,"lgrl01.bmp",0480,0195)


	//Cabecalho
	nLinha     := nLinhaCabec
	nColuna    := (nColunaINI + 0030)

	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0008), oCabecal) //"PODER EXECUTIVO DO ESTADO DO RIO GRANDE DO SUL"
	nLinha += nAltura
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0009), oCabecal) //"BADESUL DESENVOLVIMENTO S/A AG�NCIA DE FOMENTO RS"
	nLinha += nAltura
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0010) + cData, oCabecal) //"Detalhamento da Folha de Pagamento de Pessoal - "
	nLinha += nAltura
	oPrint:Say(nLinha, nColuna, " ", oCabecal)


	//T�tulos das colunas - Primeira linha
	nLinha  := nGridINI + 0010
	nColuna := nColunaINI + 0010

	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0014), oTitulos) //"Tipo Folha"
	nColuna += nLargur + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0015), oTitulos) //"�rg�o"
	nColuna += nLargur6 + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0016), oTitulos) //"Nome"
	nColuna += nLargur2 + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0017), oTitulos) //"Sexo"
	nColuna += nLargur6 + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0018), oTitulos) //"Matr�cula"
	nColuna += nLargur7 + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0019), oTitulos) //"Tipo Vinc."
	nColuna += nLargur7 + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0020), oTitulos) //"Data Ingresso"
	nColuna += nLargur8 + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0021), oTitulos) //"Cargo"
	nColuna += nLargur2 + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0022), oTitulos) //"Carga Hor."
	nColuna2 := nColuna
	nColuna += nLargur4 + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0023), oTitulos) //"Fun��o"
	nColuna += nLargur3 + nLargur6
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0024), oTitulos) //"Refer�ncia"
	nColuna3 := nColuna
	nColuna += nLargur8 + nLargur9
	
	nColunaQ := nColuna
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0025), oTitulos) //"Remunera��o"
	nColuna += nLargur + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0026), oTitulos) //"Descontos"
	nColuna += nLargur + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0027), oTitulos) //"Total"
	nColuna += nLargur + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0028), oTitulos) //"Situa��o"
	nColuna += nLargur4
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0029), oTitulos) //"CPF"
	nColuna += nlargur4 + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0030), oTitulos) //"Munic�pio"
	
	//T�tulos das colunas - Segunda linha
	nLinha += nAltura
	nColuna := nColunaINI + 0010
	oPrint:Say(nLinha, nColuna, "     ", oTitulos)

	oPrint:Say(nLinha, nColuna2, OemToAnsi(STR0021), oTitulos) //"Cargo"
	oPrint:Say(nLinha, nColuna3, OemToAnsi(STR0023), oTitulos) //"Fun��o"
	
	nColuna := nColunaQ

	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0031), oTitulos) //"Total Bruta"
	nColuna += nLargur + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0032), oTitulos) //"Legais"
	nColuna += nLargur + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0033), oTitulos) //"L�quido"
	nColuna += nLargur + nLargur9

	oPrint:Say(nLinha, nColuna, "     ", oTitulos)
	nColuna += nLargur4

//	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0034), oTitulos) //"678"
//	nColuna += nLargur

	nLinha += nAltura

Return

//����������������������������������������������������Ŀ
//� Fun��o para montar p�gina e cabe�alho das R�bricas �
//������������������������������������������������������
Static Function MCabecRubr(cData,oCabecal,oTitulos,nLargur,nAltura,nLargur)

	Local nLinhaINI		:= 0045
	Local nLinhaFIM		:= nAlt - nLinhaINI
	Local nColunaINI	:= 0010
	Local nGridINI		:= 0440
	Local nLinhaCabec	:= 0270
	Local nColunaQ		:= 0
	Local nCont			:= 1
	Local nLargur2		:= 0430
	Local nLargur3   	:= 0250
	Local nLargur4   	:= 0120
	Local nLargur5		:= 0290
	Local nLargur6		:= 0070
	Local nLargur7		:= 0100
	Local nLargur8		:= 0140
	Local nLargur9		:= 0030

	//Monta Contorno e Linhas
	oPrint:Box(nLinhaINI,nColunaINI,nAlt-nLinhaINI,nLarg-nColunaINI)
	nLinhaGrid := nGridINI
	While nLinhaGrid < nLinhaFIM
		oPrint:Line(nLinhaGrid, nColunaINI, nLinhaGrid, nLarg-nColunaINI)
		If nLinhaGrid == nGridINI
			nLinhaGrid += (2 * nAltura)
		Else
			nLinhaGrid += nAltura
		Endif
	End

	//Monta/Desenha as Colunas
	nColuna := nColunaINI + nLargur + nLargur9
	While nColuna < (nLarg-nColunaINI) .AND. nCont <= 12

		If (nCont == 0 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Tipo Folha
			nColuna += 0

		ElseIf(nCont == 1 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) // �rg�o
			nColuna += nLargur6 + nLargur9

		ElseIf(nCont == 2 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Matr�cula
			nColuna += nLargur7 + nLargur9

		ElseIf(nCont == 3 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Rubrica de Pagamento
			nColuna += nLargur8
			
		ElseIf(nCont == 4 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Descri��o da R�brica
			nColuna += nLargur2

		ElseIf(nCont == 5 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Hist�rico/Observa��o
			nColuna += nLargur3

		ElseIf(nCont == 6 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Compet�ncia do Lan�amento
			nColuna += nLargur8 + nLargur6

		ElseIf(nCont == 7 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Tipo Lan�amento
			nColuna += nLargur4 + nLargur7
		
		ElseIf(nCont == 8 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Valor
			nColuna += nLargur7 + nLargur9

		ElseIf(nCont == 9 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Tipo do Valor
			nColuna += nLargur6 + nLargur4
			
		ElseIf(nCont == 10 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Tipo de Rubrica
			nColuna += nLargur8 + nLargur6
		
		ElseIf(nCont == 11 )
			oPrint:Line(nGridINI, nColuna, nAlt-nLinhaINI, nColuna) //Exibir R�brica da Pagamento 
			nColuna += nLargur8
		Endif

		nCont++
	End

	//Logo - Posi��o fixa
	oPrint:SayBitmap(0080,0175,"lgrl01.bmp",0480,0195)


	//Cabecalho
	nLinha     := nLinhaCabec
	nColuna    := (nColunaINI + 0030)

	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0008), oCabecal) 			//"PODER EXECUTIVO DO ESTADO DO RIO GRANDE DO SUL"
	nLinha += nAltura
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0009), oCabecal) 			//"BADESUL DESENVOLVIMENTO S/A AG�NCIA DE FOMENTO RS"
	nLinha += nAltura
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0010) + cData, oCabecal) //"Detalhamento da Folha de Pagamento de Pessoal - "
	nLinha += nAltura
	oPrint:Say(nLinha, nColuna, " ", oCabecal)

	//T�tulos das colunas - primeira linha
	nLinha  := nGridINI + 0010
	nColuna := nColunaINI + 0010

	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0014), oTitulos)	//"Tipo Folha"
	nColuna += nLargur + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0015), oTitulos)	//"�rg�o"
	nColuna += nLargur6 + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0018), oTitulos)	//"Matricula"
	nColuna += nLargur7 + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0035), oTitulos)	//"Rubrica de"
	nColuna2 := nColuna
	nColuna += nLargur4 + nLargur9
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0036), oTitulos)	//"Descri��o da R�brica"
	nColuna += nLargur5 + nLargur8
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0037), oTitulos) 	//"Hist�rico/Observa��o"
	nColuna += nLargur3
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0038), oTitulos)	//"Compet�ncia"
	nColuna3 := nColuna
	nColuna += nLargur8 + nLargur6
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0039), oTitulos)	//"Tipo Lan�amento"
	nColuna += nLargur4 + nLargur7
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0040), oTitulos)	//"Valor"
	nColuna += nLargur4
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0041), oTitulos)	//"Tipo do Valor"
	nColuna += nLargur4 + nLargur6
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0042), oTitulos)	//"Tipo de Rubrica"
	nColuna += nLargur8 + nLargur6
	oPrint:Say(nLinha, nColuna, OemToAnsi(STR0043), oTitulos)	//"Exibir Rubrica"
	nColuna4 := nColuna

	//T�tulos das colunas - Segunda linha	
	nLinha += nAltura
	oPrint:Say(nLinha, nColuna2, OemToAnsi(STR0044), oTitulos)	//"Pagamento"
	oPrint:Say(nLinha, nColuna3, OemToAnsi(STR0045), oTitulos)	//"do Lan�amento"
	oPrint:Say(nLinha, nColuna4, OemToAnsi(STR0046), oTitulos)	//"Transpar�ncia"
Return

Static Function Situacao(cSitua)
	Local cDescSitua	:= ""

	Do Case
	Case (cSitua == '' .OR. cSitua == 'F')
		cDescSitua := OemToAnsi(STR0047) //Ativo
	case (cSitua == 'A')
		cDescSitua := OemToAnsi(STR0048) //Inativo
	case (cSitua == 'D')
		cDescSitua := OemToAnsi(STR0049) //Desligado
	EndCase

Return(cDescSitua)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o  �cGf� Autor � Diego Tedeschi Franco   �    Data � 08/2015 �     ��
�� Verifica fun��o	#Tarefa 34474#			    						   ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/

Static Function Gf(cFuncao)
	Local cGf	:= ""
	
	if(cFuncao $ '00015/00776/00821/92016/92012/00772/00605/00030/92015/00750/00003/00020/00012/00011/00013/00001/00315/00801/00751/00748/92017/92001/92011/92002/92003/92010/92009/92008/92006/92005/92004/92007/00778/00800/00747/00059/91999/92000/92018/92019/92020/92021/92022/92023/92025/92026/92027/92024/92029/92028/962  ')
		cGf :=	POSICIONE("SRJ",1,XFILIAL("SRJ") + ALLTRIM(cFuncao),"RJ_DESC")
	endif
Return(cGf)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o  �Vinculo� Autor � Diego Tedeschi Franco   �    Data � 08/2015  ���
�� Gera os tipos de vinculos  #Tarefa 34474#  							  ���
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/

Static Function Vinculo(cCargo,cFuncao)
	Local cVinculo 	:= ""

	If(cCargo $ "ADIDO/ADIDO BANRISUL" )
		cVinculo	:= OemToAnsi(STR0050)	//"ADIDO"
	ElseIf (cCargo == "DIRETOR")
		cVinculo	:= OemToAnsi(STR0051)	//"DIRIGENTE"
	ElseIf (cFuncao == "92000")
		cVinculo	:= OemToAnsi(STR0052)	//"CONSELHEIRO"
	Else
		cVinculo	:= OemToAnsi(STR0053)	//"CELETISTA"
	EndIf

Return(cVinculo)
