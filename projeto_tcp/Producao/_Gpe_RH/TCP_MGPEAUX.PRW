/*---------------------------------------------------------------------------+
|                             FICHA TECNICA DO PROGRAMA                      |
+----------------------------------------------------------------------------+
|   DADOS DO PROGRAMA                                                        |
+------------------+---------------------------------------------------------+
|Tipo              | Customização                                            |
+------------------+---------------------------------------------------------+
|Modulo            | GPE                                                     |
+------------------+---------------------------------------------------------+
|Nome              | MGPE001                                                 |
+------------------+---------------------------------------------------------+
|Descricao         | GERAÇÃO DE HOLERITE EM LAYOUT 240 POSIÇÕES PARA O HSBC  |
|				   | INFORMAÇÕES GERADAS ATRAVÉS DO SISPAG.					 |
+------------------+---------------------------------------------------------+
|Autor             | Erivelton Ribeiro Pinto                    			 |
+------------------+---------------------------------------------------------+
|Data de Criacao   | 18/04/2013                                              |
+------------------+----------------------------------+-------------+--------+
| Alterações                                          | Responsavel | Data   |
+-----------------------------------------------------+-------------+--------+
|                                                     |             |        |
|                                                     |             |        |
+-----------------------------------------------------+-------------+--------+
|                                                     |             |        |
|                                                     |             |        |
+-----------------------------------------------------+-------------+-------*/
#INCLUDE "PROTHEUS.CH"

User Function MGPEAJU1()
	
	Local nOpca
	Local aSays		:= {}
	Local aButtons	:= {}
	Local aRegs     := {}
	PRIVATE cAlAuxRC := "RC021606" 
	Private cCadastro := OemToAnsi("Gera‡„o de HOLERITE em TXT")
	Private nSavRec   := RECNO()
	nOpca := 0

	//=========================================
	//³ Verifica as perguntas selecionadas    =
	//=========================================
	MGPE001Perg("MGPE001")  

	Pergunte("MGPE001",.F.)

	AADD(aSays,OemToAnsi("Geração do Holerite em arquivo TXT.") )	

	AADD(aButtons, { 5,.T.,{|| Pergunte("MGPE001",.T. ) } } )
	AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(gpconfOK(),FechaBatch(),nOpca:=0) }} )
	AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

	FormBatch( cCadastro, aSays, aButtons )

	//=========================================
	//³ Variaveis utilizadas para parametros  =
	//=========================================
	If nOpca == 1
		Processa({|lEnd| GPM450Processa(),"Gera‡„o de HOLERITE em TXT"})
	Endif

Return

*-------------------------------*
Static Function Gpm450processa()
*-------------------------------*
	//======================================
	//³ Define Variaveis Locais (Programa) =
	//======================================
	Local nExtra
	Local aCodFol:={}
	Local aValBenef := {}
	Local aBenefCop := {}
	Local nCntP
	Local lHeader:=.F.,lFirst:=.F.,lGrava:=.F.
	Local cLocaBco := cLocaPro := ""
	Local lPontoVal:=ExistBlock("GP450VAL")
	Local cAux			:= ""
	Local cStartPath	:= GetSrvProfString("StartPath","")
	Local cNomArq		:= ""
	Local cNomDir		:= ""
	Local cPath 		:= GETTEMPPATH()
	Local cNewArq		:= ""
	Local nCont			:= 1
	Local nAt			:= 0
	Local nX			:= 0
	Local lCpyS2T		:= .F.

	Local nS		:= 0
	Local aStruSRA	:= {}
	Local cAliasSRA := "SRA" 	//Alias da Query
	Local cSitQuery := ""
	Local cCatQuery := ""
	Local cSRCExist := ""
	Local cSRIExist := ""
	Local cSRHExist := ""
	Local cSR1Exist := ""
	Local cSRGExist := ""
	Local lDtItens	:= .F.
	//Variaveis para identificacao do arquivo de movimento (apenas para TOP)
	Local cRCName
	Local cRIName

	//--Arquivo meses Anteriores
	Local cMesArqRef 	:= ""
	Local cAliasMov	 	:= ""
	Local cArqMov	 	:= ""
	Local aOrdBag	 	:= {}
	Local cAliasRI	 	:= ""
	Local cArqMovRI	 	:= ""
	Local aOrdBagRI	 	:= {}
	Local cCompetencia 	:= "201606"//SuperGetMv( "MV_FOLMES",,Space(06) ) 

	Local nArq 		:= ""
	Local cDiretorio:= ""
	Local cNomeArq  := ""
	Local lGp450Des := ExistBlock("GP450DES")
	Private cTXT    := ""
	Private cTXTaux := ""
	Private cSequA	:= "00001"
	Private nSequC	:= 0

	Private cNome,cBanco,cConta,cCPF

	//===================================
	//³ Variaveis de Acesso do Usuario  =
	//===================================
	Private cAcessaSR1	:= &( " { || " + ChkRH( "GPER280" , "SR1" , "2" ) + " } " )
	Private cAcessaSRA	:= &( " { || " + ChkRH( "GPER280" , "SRA" , "2" ) + " } " )
	Private cAcessaSRC	:= &( " { || " + ChkRH( "GPER280" , "SRC" , "2" ) + " } " )
	Private cAcessaSRG	:= &( " { || " + ChkRH( "GPER280" , "SRG" , "2" ) + " } " )
	Private cAcessaSRH	:= &( " { || " + ChkRH( "GPER280" , "SRH" , "2" ) + " } " )
	Private cAcessaSRI	:= &( " { || " + ChkRH( "GPER280" , "SRI" , "2" ) + " } " )
	Private cAcessaSRR	:= &( " { || " + ChkRH( "GPER280" , "SRR" , "2" ) + " } " )

	//=================================================
	//³ Variaveis Usadas no Arquivo de Cadastramento  =
	//=================================================
	Private nSeq      := 0
	Private nValor    := 0
	Private nTotal    := 0
	Private nTotFunc  := 0

	Private nHdlBco :=0,nHdlSaida:=0
	Private xConteudo 

	//============================================================
	//³ Carregando variaveis mv_par?? para Variaveis do Sistema. =
	//============================================================
	lAdianta  := If(mv_par01 == 1,.T.,.F.)
	lFolha    := If(mv_par02 == 1,.T.,.F.)
	lPrimeira := If(mv_par03 == 1,.T.,.F.)
	lSegunda  := If(mv_par04 == 1,.T.,.F.)           
	lFerias   := If(mv_par05 == 1,.T.,.F.)
	lExtras   := If(mv_par06 == 1,.T.,.F.)
	Semana    := mv_par07
	cFilDe    := mv_par08
	cFilAte   := mv_par09
	cCcDe     := mv_par10
	cCcate    := mv_par11
	cBcoDe    := mv_par12
	cBcoAte   := mv_par13
	cMatDe    := mv_par14
	cMatAte   := mv_par15
	cNomDe    := mv_par16
	cNomAte   := mv_par17
	cCtaDe    := mv_par18
	cCtaAte   := mv_par19
	cSituacao := mv_par20
	cArqSaida := mv_par21
	dDataPgto := mv_par22
	dDataDe   := mv_par23
	dDataAte  := mv_par24
	cCategoria:= mv_par25
	lRescisao := If(mv_par26 == 1,.T.,.F.)
	nFunBenAmb:= mv_par27  // 1-Funcionarios  2-Beneficiarias  3-Ambos
	dDataRef  := If (Empty(mv_par28), dDataBase,mv_par28)
	cBancoEnv := mv_par29
	cAgEnv    := mv_par30
	cContaEnv := mv_par31 

	DbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	If !DbSeek(xFilial("SA6")+cBancoEnv+cAgEnv+cContaEnv) 
		Alert("Banco, Agencia ou Conta não encontrado no Cadastro de Bancos")
		Return
	EndIf 
	
	DbSelectArea("SEE")
	SEE->(DbSetOrder(1))
	If !DbSeek(xFilial("SEE")+cBancoEnv+cAgEnv+cContaEnv) 
		Alert("Parametro de Banco não encontrado")
		Return
	EndIf
	
	// Abertura de Arquivo de outros meses
	//==============
	//³ Abre o SRC =
	//==============
	If !Empty( cCompetencia )
		If !Empty( cCompetencia ) .And. MesAno( dDataRef ) > cCompetencia
			Aviso( "Atenção", "Não existe arquivo" + ": "+Subs(MesAno(dDataRef),5,2)+"/"+Subs(MesAno(ddataref),1,4), { "OK" } )
			Return .F.
		Endif
	Endif

	cMesArqRef := StrZero(Month(dDataRef),2) + StrZero(Year(dDataRef),4)

	If !OpenSrc( cMesArqRef, @cAliasMov, @aOrdBag, @cArqMov, dDataRef )
		Return .F.
	Endif

	//==============
	//³ Abre o SRI =
	//==============
	If lSegunda
		If !OpenSrc( "13" + Substr(cMesArqRef,3,4), @cAliasRI, @aOrdBagRI, @cArqMovRI, dDataRef )
			Return .F.
		EndIf
	EndIf

	If lFerias .and. ("F" $ cSituacao .and. !("A"$cSituacao) )
		cSituacao += "A"
	EndIf

	#IFDEF TOP
		//-- Modifica variaveis para a Query
		For nS:=1 to Len(cSituacao)
			cSitQuery += "'"+Subs(cSituacao,nS,1)+"'"
			If ( nS+1) <= Len(cSituacao)
				cSitQuery += ","
				Endif
		Next nS
	
		For nS:=1 to Len(cCategoria)
			cCatQuery += "'"+Subs(cCategoria,nS,1)+"'"
			If ( nS+1) <= Len(cCategoria)
				cCatQuery += ","
			Endif
		Next nS
		
		If lFerias
			//============================================
			//³ Verifica existencia do campo RH_DTITENS  =
			//============================================
			dbSelectArea( "SRH" )
			lDtItens := SRH->(FieldPos( "RH_DTITENS" )) # 0
		EndIf
		
		cRCName :="RC021606" //If( Empty(cAliasMov), RetSqlName("SRC"), cArqMov )
		cRIName := If( Empty(cAliasRI), RetSqlName("SRI"), cArqMovRI )
	#ENDIF

	//================================================================
	//³ Define se devera ser impresso Funcionarios ou Beneficiarios  =
	//================================================================
	dbSelectArea( "SRQ" )
	lImprFunci  := ( nFunBenAmb # 2 )
	lImprBenef  := ( nFunBenAmb # 1 .And. FieldPos( "RQ_BCDEPBE" ) # 0 .And. FieldPos( "RQ_CTDEPBE" ) # 0 )

	//=================================================================
	//³ Informa a nao existencia dos campos de bco/age/conta corrente =
	//=================================================================
	If nFunBenAmb # 1 .And. !lImprBenef
		fAvisoBC()
		Return .F.
	Endif 
	
	//========================================================================
	//Verifica se o usuario definiu um diretorio local para gravacao do arq. =
	//de saida, pois nesse caso efetua a geracao do arquivo no servidor e ao =
	//fim da geracao copia para o diretorio local e apaga do servidor.       =
	//========================================================================
	If Substr( cArqSaida, 2, 1 ) == ":"
	
		//?-Checa o SO do Remote (1=Windows, 2=Linux)
		If GetRemoteType() == 2
			nAt := RAt( "/", cArqSaida )
		Else
			nAt := RAt( "\", cArqSaida )
		EndIf
		cNewArq := cArqSaida
		If ( cAux := Substr( cArqSaida, Len(cArqSaida), 1 ) ) == " "
			While cAux == " "
				cNewArq	:= Substr( cArqSaida, 1, Len(cArqSaida) - nCont )
				cAux	:= Substr( cNewArq, Len(cNewArq), 1 )
				nCont++
			EndDo
		EndIf
	
		cNomArq		:= Right( cNewArq, Len(cNewArq) - nAt )
		cNomDir		:= Left( cNewArq, nAt )
	
		cArqSaida	:= cStartPath + cNomArq
		lCpyS2T		:= .T.
	Endif

	//=====================================
	//³ Desenha cursor para movimentacao  =
	//=====================================
	ProcRegua(SRA->(RecCount()))

	//==============================================================
	//³ Analisa o tipo de bordero e define quais headers,traillers =
	//³ e detalhes de lote que ser„o utilizados.                   =
	//³Identificadores                                             =
	//³ A - Header Arquivo                                         =
	//³ B - Header  Lote 1   Header Lote Cheque/OP/DOC/Cred.CC     =
	//³ D - Trailer Lote 1   Trailler Lote Cheque/OP/DOC/Cred.CC   =
	//³ F - Trailer Arquivo                                        =
	//³ G - Segmento A       Cheque/OP/DOC/Cred.CC                 =
	//³ H - Segmento B       Informacoes Complemntares             =
	//==============================================================
	cHeadArq  := "A"
	cTraiArq  := "F"
	cHeadLote := "B"
	cTraiLote := "D"
	cDetaG    := "G"
	cDetaH    := "H"

	//=========================================
	//INDICA ONDE VAI SER SALVO O ARQUIVO TXT =
	//=========================================
	nArq := ""
	cDiretorio:= "C:\TEMP\"
	cNomeArq  := cArqSaida
	cTXT      := ""
	nArq     := FCreate( cDiretorio+cNomeArq , 0 )
	//===================================================
	//FIM DA INDICAÇÃO ONDE VAI SER SALVO O ARQUIVO TXT =
	//===================================================
	
	nSeq:= 1            
	//======================================================================================
	//					   INICIO SEÇÃO: REGISTRO HEADER DE ARQUIVO                        =
	//======================================================================================
	cTXT+= "399"	   											//DE 1  ATE 3 -> 3
	cTXT+= "0000"       										//DE 4  ATE 7 -> 4
	cTXT+= "0"          										//DE 8  ATE 8 -> 1 
	cTXT+= SPACE(9)	    										//DE 9  ATE 17-> 9
	cTXT+= "2"          										//DE 18 ATE 18-> 1
	cTXT+= SUBSTR(SM0->M0_CGC,1,14)      						//DE 19 ATE 32 -> 14
	cTXT+= PADL(ALLTRIM(SEE->EE_CODEMP),6,"0")					//DE 33 ATE 38 -> 6
	cTXT+= SPACE(14) 											//DE 39 ATE 52 -> 14
	cTXT+= STRZERO(VAL(SA6->A6_AGENCIA),5)						//DE 53 ATE 57 -> 5
	cTXT+= SPACE(1)												//DE 58 ATE 58 -> 1
	cTXT+= STRZERO(VAL(SA6->A6_NUMCON),12)	        			//DE 59 ATE 70 -> 12
	cTXT+= STRZERO(VAL(SUBSTR(ALLTRIM(SA6->A6_NUMCON),7,1)),1)	//DE 71 ATE 71 -> 1
	cTXT+= SPACE(1)	                        	  				//DE 72 ATE 72 -> 1
	cTXT+= UPPER(SUBS(SM0->M0_NOMECOM,1,30))					//DE 73 ATE 102-> 30
	cTXT+= UPPER(PADR("HSBC Bank Brasil S.A.",30))				//DE 103 ATE 132 -> 30
	cTXT+= SPACE(10) 											//DE 133 ATE 142 -> 10
	cTXT+= "1" 													//DE 143 ATE 143 -> 1
	cTXT+= GravaData(Date(),.F.,5) 								//DE 144 ATE 151 -> 8 DDMMAAAA
	cTXT+= SUBS(TIME(),1,2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)	//DE 152 ATE 157 -> 6
	cTXT+= "000001"          									//DE 158 ATE 163 -> 6
	cTXT+= "010" 												//DE 164 ATE 166 -> 3
	cTXT+= "01600"          									//DE 167 ATE 171 -> 5
	cTXT+= "PAY"												//DE 172 ATE 174 -> 3
	cTXT+= "Y2K"												//DE 175 ATE 177 -> 3
	cTXT+= SPACE(3)												//DE 178 ATE 180 -> 3
	cTXT+= SPACE(11)											//DE 181 ATE 191 -> 11
	cTXT+= SPACE(49)											//DE 192 ATE 240 -> 49
	cTXT+= CHR(13)+CHR(10)	                                    //PULA LINHA
	FWrite( nArq , cTXT )										//GRAVA REGISTRO DE HEADER DE ARQUIVO
	//======================================================================================
	//						FIM SEÇÃO: REGISTRO HEADER DE ARQUIVO                          =
	//======================================================================================

	//==========================================================
	//VERIFICA QUAIS INFORMAÇÕES FORAM SOLICITADAS NA PERGUNTA =
	//==========================================================
	lAdianta  := If(mv_par01 == 1,.T.,.F.)
	lFolha    := If(mv_par02 == 1,.T.,.F.)
	lPrimeira := If(mv_par03 == 1,.T.,.F.)
	lSegunda  := If(mv_par04 == 1,.T.,.F.)
	lFerias   := If(mv_par05 == 1,.T.,.F.)
	lExtras   := If(mv_par06 == 1,.T.,.F.)
 
	ctpServico := "  "

	if lFolha
		ctpServico := "01"
	endif	
	if lPrimeira .OR. lSegunda
		ctpServico := "02"
	endif
	if lAdianta
		ctpServico := "03"
	endif 
	if lExtras
		ctpServico := "04"
	endif 
	if lFerias
		ctpServico := "06"
	endif
	//=======================================================================
	//FIM DA VERIFICAÇÃO DE QUAIS INFORMAÇÕES FORAM SOLICITADAS NA PERGUNTA =
	//=======================================================================
	
	//======================================================================================
	//					    INICIO SEÇÃO: REGISTRO HEADER DE LOTE                          =
	//======================================================================================
	cTXT:= "399"										//DE 1 ATE 9 -> 3
	cTXT+= "0001"										//DE 4 ATE 7 -> 4
	cTXT+= "1"											//DE 8 ATE 8 -> 1
	cTXT+= "E"											//DE 9 ATE 9 -> 1
	cTXT+= ctpServico									//DE 10 ATE 11 -> 2
	cTXT+= SPACE(2)										//DE 12 ATE 13 -> 2
	cTXT+= "010"										//DE 14 ATE 16 -> 3
	cTXT+= "H"											//DE 17 ATE 17 -> 1
	cTXT+= "2"											//DE 18 ATE 18 -> 1
	cTXT+= SUBST(SM0->M0_CGC,1,14)						//DE 19 ATE 32 -> 14
	cTXT+= PADL(ALLTRIM(SEE->EE_CODEMP),6,"0")			//DE 33 ATE 38 -> 6
	cTXT+= SPACE(14)									//DE 39 ATE 52 -> 14
	cTXT+= STRZERO(VAL(SA6->A6_AGENCIA),5)				//DE 53 ATE 57 -> 5
	cTXT+= SPACE(1)										//DE 58 ATE 58 -> 1
	cTXT+= STRZERO(VAL(SA6->A6_NUMCON),12)				//DE 59 ATE 70 -> 12
	cTXT+= STRZERO(VAL(SUBSTR(ALLTRIM(SA6->A6_NUMCON),7,1)),1)//DE 71 ATE 71 -> 1
	cTXT+= SPACE(1)										//DE 72 ATE 72 -> 1
	cTXT+= UPPER(SUBS(SM0->M0_NOMECOM,1,30))			//DE 73 ATE 102 -> 30
	cTXT+= GravaData(Date(),.F.,5)                  	//DE 103 ATE 110-> 8
	cTXT+= SPACE(32)									//DE 111 ATE 142-> 32
	cTXT+= SUBSTR(SM0->M0_ENDCOB,1,30)					//DE 143 ATE 172-> 30
	cTXT+= "00000"										//DE 173 ATE 177-> 5
	cTXT+= SPACE(15)									//DE 178 ATE 192-> 15
	cTXT+= SUBSTR(SM0->M0_CIDCOB,1,20)					//DE 193 ATE 212-> 20
	cTXT+= SUBS(SM0->M0_CEPCOB,1,5 ) 					//DE 213 ATE 217-> 5
	cTXT+= SUBSTR(SM0->M0_CEPCOB,6,8)					//DE 218 ATE 220-> 3
	cTXT+= SUBSTR(SM0->M0_ESTCOB,1,2)					//DE 221 ATE 222-> 2
	cTXT+= SPACE(1)										//DE 223 ATE 223-> 1
	cTXT+= SPACE(17)									//DE 224 ATE 240-> 17
	cTXT+= CHR(13)+CHR(10)								//PULA LINHA
	FWrite( nArq , cTXT )								//GRAVA REGISTRO DE HEADER DE LOTE
	//======================================================================================
	//						FIM SEÇÃO: REGISTRO HEADER DE LOTE                             =
	//====================================================================================== 
	
	cFilialAnt := Replicate("!", FWGETTAMFILIAL)
	
	// Posiciona no Primeiro Selecionado no De/Ate
	dbSelectArea( "SRA" )

	#IFDEF TOP
		If TcSrvType() != "AS/400"
			cQuery := "SELECT COUNT(*) TOTAL "
			cQuery += "FROM " + RetSqlName("SRA")	+ " QSRA "
			cQuery += "WHERE RA_FILIAL	BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' "
			cQuery += "AND RA_MAT     	BETWEEN '" + cMatDe + "' AND '" + cMatAte + "' "
			cQuery += "AND RA_NOME    	BETWEEN '" + cNomDe + "' AND '" + cNomAte + "' "
			cQuery += "AND RA_CC      	BETWEEN '" + cCcDe  + "' AND '" + cCcate  + "' "
		
			If nFunBenAmb == 1
				cQuery += "AND RA_BCDEPSA	BETWEEN '" + cBcoDe	+ "' AND '" + cBcoAte	+ "' "
				cQuery += "AND RA_CTDEPSA	BETWEEN '" + cCtaDe	+ "' AND '" + cCtaAte	+ "' "
			EndIf
		
			cQuery += "AND RA_CATFUNC 	IN (" + Upper(cCatQuery) + ") "
			cQuery += "AND RA_SITFOLH 	IN (" + Upper(cSitQuery) + ") "
			cQuery += "AND QSRA.D_E_L_E_T_ = ' ' "
		
			If lAdianta .Or. lFolha .Or. ( lPrimeira .And. !(cPaisLoc $ "URU|ARG") )
				cSRCExist += "( EXISTS ( SELECT RC_FILIAL, RC_MAT, RC_PD, RC_VALOR, RC_DATA "
				cSRCExist += "FROM " + cRCName + " QSRC "
				cSRCExist += "WHERE RC_FILIAL = RA_FILIAL "
				cSRCExist += "AND RC_MAT = RA_MAT "
				cSRCExist += "AND RC_DATA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
			
				If lAdianta .Or. lPrimeira
					cSRCExist += "AND RC_SEMANA	= '" + Semana + "' "
				EndIf
			
				cSRCExist += "AND QSRC.D_E_L_E_T_= ' ' ) ) "
			EndIf
		
			If lSegunda .or. If(cPaisLoc $ "URU|ARG",lPrimeira,.F.)
				If !Empty(cSRCExist)
					cSRIExist += "OR "
				EndIf
			
				cSRIExist += "( EXISTS ( SELECT RI_FILIAL, RI_MAT, RI_PD, RI_VALOR, RI_DATA "
				cSRIExist += "FROM " + cRIName + " QSRI "
				cSRIExist += "WHERE RI_FILIAL = RA_FILIAL "
				cSRIExist += "AND RI_MAT = RA_MAT "
				cSRIExist += "AND RI_DATA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
				cSRIExist += "AND QSRI.D_E_L_E_T_= ' ' ) ) "
			EndIf
		
			If lFerias
			
				fDtItens(.F.) //Retirar em futuras versoes
			
				If !Empty(cSRCExist) .Or. !Empty(cSRIExist)
					cSRHExist += "OR "
				EndIf
			
				cSRHExist += "( EXISTS ( SELECT SRR1.RR_FILIAL, SRR1.RR_MAT, SRR1.RR_PD, SRR1.RR_VALOR, SRR1.RR_DATA, QSRH.RH_DTRECIB "
				cSRHExist += "FROM "+ RetSqlName("SRR") + " SRR1 "
				cSRHExist += "INNER JOIN "+ RetSqlName("SRH") + " QSRH "
				cSRHExist += "ON ( SRR1.RR_FILIAL = RH_FILIAL "
				cSRHExist += "AND SRR1.RR_MAT = RH_MAT "
			
				If lDtItens
					cSRHExist 		+= "AND SRR1.RR_DATA = RH_DTITENS "
				Else
					cSRHExist 		+= "AND SRR1.RR_DATA = RH_DTRECIB "
				EndIf
				
				cSRHExist += "AND SRR1.D_E_L_E_T_ = QSRH.D_E_L_E_T_) "
				cSRHExist += "WHERE RH_FILIAL = RA_FILIAL "
				cSRHExist += "AND RH_MAT = RA_MAT "
				cSRHExist += "AND RH_DTRECIB BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
				cSRHExist += "AND QSRH.D_E_L_E_T_= ' ' ) ) "
			EndIf
			
			If lExtras
				If !Empty(cSRCExist) .Or. !Empty(cSRIExist) .Or. !Empty(cSRHExist)
					cSR1Exist += "OR "
				EndIf
				
				cSR1Exist += "( EXISTS ( SELECT R1_FILIAL, R1_MAT, R1_PD, R1_VALOR, R1_DATA "
				cSR1Exist += "FROM " + RetSqlName("SR1") + " QSR1 "
				cSR1Exist += "WHERE R1_FILIAL = RA_FILIAL "
				cSR1Exist += "AND R1_MAT = RA_MAT "
				cSR1Exist += "AND R1_DATA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
				cSR1Exist += "AND R1_SEMANA	= '" + Semana + "' "
				cSR1Exist += "AND QSR1.D_E_L_E_T_= ' ' ) ) "
			EndIf
		
			If lRescisao
				If !Empty(cSRCExist) .Or. !Empty(cSRIExist) .Or. !Empty(cSRHExist) .Or. !Empty(cSR1Exist)
					cSRGExist += "OR "
				EndIf
			
				cSRGExist += "( EXISTS ( SELECT SRR2.RR_FILIAL, SRR2.RR_MAT, SRR2.RR_PD, SRR2.RR_VALOR, SRR2.RR_DATA, RG_DATAHOM "
				cSRGExist += "FROM "+ RetSqlName("SRR") + " SRR2 "
				cSRGExist += "INNER JOIN "+ RetSqlName("SRG") + " QSRG "
				cSRGExist += "ON ( SRR2.RR_FILIAL = RG_FILIAL "
				cSRGExist += "AND SRR2.RR_MAT = RG_MAT "
				cSRGExist += "AND SRR2.RR_DATAPAG = RG_DATAHOM "
				cSRGExist += "AND SRR2.D_E_L_E_T_ = QSRG.D_E_L_E_T_) "
				cSRGExist += "WHERE RG_FILIAL = RA_FILIAL "
				cSRGExist += "AND RG_MAT = RA_MAT "
				cSRGExist += "AND RG_DATAHOM BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
				cSRGExist += "AND QSRG.D_E_L_E_T_= ' ' ) ) "
			EndIf
		
			If !Empty(cSRCExist) .Or. !Empty(cSRIExist) .Or. !Empty(cSRHExist) .Or. !Empty(cSR1Exist) .Or. !Empty(cSRGExist)
					cQuery += "AND (" + cSRCExist + cSRIExist + cSRHExist + cSR1Exist + cSRGExist +")"
				EndIf
			Else
				cQuery := "SELECT COUNT(*) TOTAL "
				cQuery += "FROM "+	RetSqlName("SRA") + " "
				cQuery += "WHERE RA_FILIAL	>= '" + cFilDe + "' AND RA_FILIAL  <= '" + cFilAte + "' "
				cQuery += "AND RA_MAT     	>= '" + cMatDe + "' AND RA_MAT     <= '" + cMatAte + "' "
				cQuery += "AND RA_NOME    	>= '" + cNomDe + "' AND RA_NOME    <= '" + cNomAte + "' "
				cQuery += "AND RA_CC      	>= '" + cCcDe  + "' AND RA_CC      <= '" + cCcate  + "' "
			
				If nFunBenAmb == 1
					cQuery += "AND RA_BCDEPSA	>= '" + cBcoDe + "' AND RA_BCDEPSA <= '" + cBcoAte + "' "
					cQuery += "AND RA_CTDEPSA	>= '" + cCtaDe + "' AND RA_CTDEPSA <= '" + cCtaAte + "' "
				EndIf
			
				cQuery += "AND @DELETED@ = ' ' "
			Endif
		
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QUERY', .F., .T.)
			dbSelectArea("QUERY")
			nTotalQ := QUERY->TOTAL
			ProcRegua(nTotalQ)		// Total de Elementos da regua
			Query->( dbCloseArea() )
			dbSelectArea("SRA")
			
			cSRCExist := cSRIExist := cSRHExist := cSR1Exist := cSRGExist := ""
			
			If TcSrvType() != "AS/400"
				cQuery := "SELECT * "
				cQuery += "FROM " + RetSqlName("SRA") + " QSRA "
				cQuery += "WHERE RA_FILIAL	BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' "
				cQuery += "AND RA_MAT     	BETWEEN '" + cMatDe + "' AND '" + cMatAte + "' "
				cQuery += "AND RA_NOME    	BETWEEN '" + cNomDe + "' AND '" + cNomAte + "' "
				cQuery += "AND RA_CC      	BETWEEN '" + cCcDe  + "' AND '" + cCcate  + "' "
				
				If nFunBenAmb == 1
					cQuery += "AND RA_BCDEPSA	BETWEEN '" + cBcoDe	+ "' AND '" + cBcoAte	+ "' "
					cQuery += "AND RA_CTDEPSA	BETWEEN '" + cCtaDe	+ "' AND '" + cCtaAte	+ "' "
				EndIf
			
				cQuery += "AND RA_CATFUNC 	IN (" + Upper(cCatQuery) + ") "
				cQuery += "AND RA_SITFOLH 	IN (" + Upper(cSitQuery) + ") "
				cQuery += "AND QSRA.D_E_L_E_T_ = ' ' "
			
			If lAdianta .Or. lFolha .Or. ( lPrimeira .And. !(cPaisLoc $ "URU|ARG") )
				cSRCExist += "( EXISTS ( SELECT RC_FILIAL, RC_MAT, RC_PD, RC_VALOR, RC_DATA "
				cSRCExist += "FROM " + cRCName + " QSRC "
				cSRCExist += "WHERE RC_FILIAL = RA_FILIAL "
				cSRCExist += "AND RC_MAT = RA_MAT "
				cSRCExist += "AND RC_DATA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
				
				If lAdianta .Or. lPrimeira
					cSRCExist += "AND RC_SEMANA	= '" + Semana + "' "
				EndIf
			
				cSRCExist += "AND QSRC.D_E_L_E_T_= ' ' ) ) "
			EndIf
		
			If lSegunda .or. If(cPaisLoc $ "URU|ARG",lPrimeira,.F.)
				If !Empty(cSRCExist)
					cSRIExist += "OR "
				EndIf
			
				cSRIExist += "( EXISTS ( SELECT RI_FILIAL, RI_MAT, RI_PD, RI_VALOR, RI_DATA "
				cSRIExist += "FROM " + cRIName + " QSRI "
				cSRIExist += "WHERE RI_FILIAL = RA_FILIAL "
				cSRIExist += "AND RI_MAT = RA_MAT "
				cSRIExist += "AND RI_DATA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
				cSRIExist += "AND QSRI.D_E_L_E_T_= ' ' ) ) "
			EndIf
		
			If lFerias
				
				fDtItens(.F.) //Retirar em futuras versoes
				
				If !Empty(cSRCExist) .Or. !Empty(cSRIExist)
					cSRHExist += "OR "
				EndIf
				
				cSRHExist += "( EXISTS ( SELECT SRR1.RR_FILIAL, SRR1.RR_MAT, SRR1.RR_PD, SRR1.RR_VALOR, SRR1.RR_DATA, QSRH.RH_DTRECIB "
				cSRHExist += "FROM "+ RetSqlName("SRR") + " SRR1 "
				cSRHExist += "INNER JOIN "+ RetSqlName("SRH") + " QSRH "
				cSRHExist += "ON ( SRR1.RR_FILIAL = RH_FILIAL "
				cSRHExist += "AND SRR1.RR_MAT = RH_MAT "
			
				If lDtItens
					cSRHExist 		+= "AND SRR1.RR_DATA = RH_DTITENS "
				Else
					cSRHExist 		+= "AND SRR1.RR_DATA = RH_DTRECIB "
				EndIf
			
				cSRHExist += "AND SRR1.D_E_L_E_T_ = QSRH.D_E_L_E_T_) "
				cSRHExist += "WHERE RH_FILIAL = RA_FILIAL "
				cSRHExist += "AND RH_MAT = RA_MAT "
				cSRHExist += "AND RH_DTRECIB BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
				cSRHExist += "AND QSRH.D_E_L_E_T_= ' ' ) ) "
			EndIf
			
			If lExtras
				If !Empty(cSRCExist) .Or. !Empty(cSRIExist) .Or. !Empty(cSRHExist)
					cSR1Exist += "OR "
				EndIf
			
				cSR1Exist += "( EXISTS ( SELECT R1_FILIAL, R1_MAT, R1_PD, R1_VALOR, R1_DATA "
				cSR1Exist += "FROM " + RetSqlName("SR1") + " QSR1 "
				cSR1Exist += "WHERE R1_FILIAL = RA_FILIAL "
				cSR1Exist += "AND R1_MAT = RA_MAT "
				cSR1Exist += "AND R1_DATA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
				cSR1Exist += "AND R1_SEMANA	= '" + Semana + "' "
				cSR1Exist += "AND QSR1.D_E_L_E_T_= ' ' ) ) "
			EndIf
			
			If lRescisao
				If !Empty(cSRCExist) .Or. !Empty(cSRIExist) .Or. !Empty(cSRHExist) .Or. !Empty(cSR1Exist)
					cSRGExist += "OR "
				EndIf
				
				cSRGExist += "( EXISTS ( SELECT SRR2.RR_FILIAL, SRR2.RR_MAT, SRR2.RR_PD, SRR2.RR_VALOR, SRR2.RR_DATA, RG_DATAHOM "
				cSRGExist += "FROM "+ RetSqlName("SRR") + " SRR2 "
				cSRGExist += "INNER JOIN "+ RetSqlName("SRG") + " QSRG "
				cSRGExist += "ON ( SRR2.RR_FILIAL = RG_FILIAL "
				cSRGExist += "AND SRR2.RR_MAT = RG_MAT "
				cSRGExist += "AND SRR2.RR_DATAPAG = RG_DATAHOM "
				cSRGExist += "AND SRR2.D_E_L_E_T_ = QSRG.D_E_L_E_T_) "
				cSRGExist += "WHERE RG_FILIAL = RA_FILIAL "
				cSRGExist += "AND RG_MAT = RA_MAT "
				cSRGExist += "AND RG_DATAHOM BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "
				cSRGExist += "AND QSRG.D_E_L_E_T_= ' ' ) ) "
			EndIf
			
			If !Empty(cSRCExist) .Or. !Empty(cSRIExist) .Or. !Empty(cSRHExist) .Or. !Empty(cSR1Exist) .Or. !Empty(cSRGExist)
				cQuery += "AND (" + cSRCExist + cSRIExist + cSRHExist + cSR1Exist + cSRGExist +")"
			EndIf
		Else
			cQuery := "SELECT * "
			cQuery += "FROM "+	RetSqlName("SRA") + " "
			cQuery += "WHERE RA_FILIAL	>= '" + cFilDe + "' AND RA_FILIAL  <= '" + cFilAte + "' "
			cQuery += "AND RA_MAT     	>= '" + cMatDe + "' AND RA_MAT     <= '" + cMatAte + "' "
			cQuery += "AND RA_NOME    	>= '" + cNomDe + "' AND RA_NOME    <= '" + cNomAte + "' "
			cQuery += "AND RA_CC      	>= '" + cCcDe  + "' AND RA_CC      <= '" + cCcate  + "' "
		
			If nFunBenAmb == 1
				cQuery += "AND RA_BCDEPSA	>= '" + cBcoDe + "' AND RA_BCDEPSA <= '" + cBcoAte + "' "
				cQuery += "AND RA_CTDEPSA	>= '" + cCtaDe + "' AND RA_CTDEPSA <= '" + cCtaAte + "' "
			EndIf
		
			cQuery += "AND @DELETED@ = ' ' "
		Endif
	
		cQuery   += " ORDER BY RA_FILIAL, RA_MAT"
		
		aStruSRA := SRA->(dbStruct())
		SRA->( dbCloseArea() )
		
		cQuery	:= ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSRA, .F., .T.)

		For nX := 1 To Len(aStruSRA)
			If ( aStruSRA[nX][2] <> "C" )
				TcSetField(cAliasSRA,aStruSRA[nX][1],aStruSRA[nX][2],aStruSRA[nX][3],aStruSRA[nX][4])
			EndIf
		Next nX
	#ELSE
		dbSetOrder(1)
		dbSeek( cFilDe + cMatDe , .T. )
	#ENDIF

	While !SRA->( Eof() ) .And. SRA->RA_FILIAL + SRA->RA_MAT <= cFilAte + cMatAte
		//======================
		//³ Movimenta Cursor   =
		//======================
		IncProc("Liquido em Disquete")
		
		nValor    := 0
		aValBenef := {}
	
		If SRA->RA_FILIAL # cFilialAnt
			If !Fp_CodFol(@aCodFol,SRA->RA_FILIAL)
				Exit
			Endif
			cFilialAnt := SRA->RA_FILIAL
		Endif
	
		#IFNDEF TOP
			//================================================================
			//³ Consiste Parametrizacao do Intervalo de Impressao            =
			//================================================================
			If  (SRA->RA_NOME    < cNomDe) .Or. (SRA->RA_NOME    > cNomAte) .Or. ;
				(SRA->RA_MAT     < cMatDe) .Or. (SRA->RA_MAT     > cMatAte) .Or. ;
				(SRA->RA_CC      < cCcDe)  .Or. (SRA->RA_CC      > cCcate)
				SRA->(dbSkip(1))
				Loop
			EndIf
		#ENDIF
	
		//================================================================
		//³ Busca os valores de Liquido e Pensao                         =
		//================================================================
		fBuscaLiq(@nValor,@aValBenef,aCodFol,,,dDataRef, cRCName, cRIName)
	
	
		//================================================================
		//³ Ponto de Entrada para despresar funcionario caso retorne .F. =
		//================================================================
		If lGp450Des
			If !(ExecBlock("GP450DES",.F.,.F.))
				dbSelectArea( "SRA" )
				SRA->(dbSkip(1))
				Loop
			EndIf
		EndIf
	
		#IFDEF TOP
			If nFunBenAmb # 1
				//================================================================
				//³ Consiste parametros de banco e conta do funcionario			 =
				//================================================================
				If (SRA->RA_BCDEPSA < cBcoDe) .Or. (SRA->RA_BCDEPSA > cBcoAte) .Or.;
					(SRA->RA_CTDEPSA < cCtaDe) .Or. (SRA->RA_CTDEPSA > cCtaAte)
					nValor := 0
				EndIf
			EndIf
		#ELSE
			//================================================================
			//³ Consiste parametros de banco e conta do funcionario			 =
			//================================================================
			If (SRA->RA_BCDEPSA < cBcoDe) .Or. (SRA->RA_BCDEPSA > cBcoAte) .Or.;
				(SRA->RA_CTDEPSA < cCtaDe) .Or. (SRA->RA_CTDEPSA > cCtaAte)
				nValor := 0
			EndIf
		#ENDIF
	
		//================================================================
		//³ Consiste parametros de banco e conta do beneficiario 		 =
		//³ aValBenef: 1-Nome  2-Banco  3-Conta  4-Verba  5-Valor  6-CPF =
		//================================================================
		If Len(aValBenef) > 0
			aBenefCop  := ACLONE(aValBenef)
			aValBenef  := {}
			Aeval(aBenefCop, { |X| If( ( X[2] >= cBcoDe .And. X[2] <= cBcoAte) .And.;
			( X[3] >= cCtaDe .And. X[3] <= cCtaAte),;
			AADD(aValBenef, X), "" ) })
		EndIf
	
		//================================================================
		//³ Testa Situacao do Funcionario na Folha                       =
		//³ Testa Categoria do Funcionario na Folha                      =
		//³ Testa se Valor == 0                                          =
		//================================================================
		If !( SRA->RA_SITFOLH $ cSituacao ) .Or. !(SRA->RA_CATFUNC $ cCategoria) .Or.;
			( nValor == 0 .And. Len(aValBenef) == 0 )
			dbSelectArea( "SRA" )
			dbSkip()
			Loop
		Endif
		
		//================================================================
		//³ Inclui o funcionario no array para inclusao no arquivo		 =
		//================================================================
		If lImprFunci
			Aadd(aValBenef, {  SRA->RA_NOME, SRA->RA_BCDEPSA, SRA->RA_CTDEPSA, "", nValor,SRA->RA_CIC } )
		EndIf
		
		For nCntP := 1 To Len(aValBenef)
			cNome  := aValBenef[nCntP,1]
			cBanco := aValBenef[nCntP,2]
			cConta := aValBenef[nCntP,3]
			cCPF   := aValBenef[nCntP,6]
			//================================================================
			//³ Verifica valor e banco/agencia dos beneficiarios			 =
			//================================================================
			If aValBenef[nCntP,5] == 0 .Or. Empty(cBanco) .Or. cBanco < cBcoDe .Or. cBanco > cBcoAte
				Loop
			EndIf
			
			//================================================================
			//³ Iguala nas Variaveis Usadas do arquivo de cadastramento      =
			//================================================================
			nValor := NoRound(aValBenef[nCntP,5] * 100,0)
		
			//================================================================
			//³ Ponto de Entrada para alterar dados caso necessario          =
			//================================================================
			If lPontoVal
				if !(ExecBlock("GP450VAL",.F.,.F.))
					Loop
				endif
			EndIf
			
			nTotal += nValor
			nTotFunc ++
			nSeq++
			
		Next nCntP
		
		
		//======================================================================================
		//				INICIO SEÇÃO: REGISTRO DETALHE DE LOTE  (SEGMENTO "A")                 =
		//======================================================================================
		cTXT:= "399"										//DE 1 ATE 3 -> 3 
		cTXT+= "0003"										//DE 4 ATE 7 -> 4
		cTXT+= "3"											//DE 8 ATE 8 -> 1
		cTXT+= cSequA										//DE 9 ATE 13-> 5
		cTXT+= "A"											//DE 14 ATE 14 -> 1
		cTXT+= "0"											//DE 15 ATE 15 -> 1
		cTXT+= "00"											//DE 16 ATE 17 -> 2
		cTXT+= "H"											//DE 18 ATE 18 -> 1
		cTXTaux:= ALLTRIM(SUBSTR(SRA->RA_BCDEPSA,4))		//variavel auxiliar para comparar o tamanho da agencia de destino a ser depositada.
		IF Len(cTXTaux)<5
			cTXTaux:= AllTRIM("0" + SUBSTR(SRA->RA_BCDEPSA,4))//DE 19 ATE 23 -> 5
		ENDIF
		cTXT+= ALLTRIM(cTXTaux)								//DE 19 ATE 23 -> 5
		cTXT+= ALLTRIM(PADR(SRA->RA_CTDEPSA,6))				//DE 24 ATE 35 -> 12
		cTXT+= SUBSTR(SRA->RA_CTDEPSA,6)					//DE 36 ATE 36 -> 1
		cTXT+= SPACE(1)										//DE 37 ATE 37 -> 1
		cTXT+= LEFT(SRA->RA_NOME,30)						//DE 38 ATE 67 -> 30
		cTXT+= Replicate("0",16)							//DE 68 ATE 83 -> 16
		cTXT+= STRZERO(VAL(SRA->RA_MAT),10)					//DE 84 ATE 93 -> 10
		cTXT+= PADR(Posicione("SRJ",01,xFilial("SRJ")+SRA->RA_CODFUNC,"RJ_DESC"), 20)//DE 94 ATE 113 -> 20
		cTXT+= "1"											//DE 114 ATE 114 -> 1
		cTXT+= STRZERO(Val(SRA->RA_CIC),11)					//DE 115 ATE 125 -> 11
		cTXT+= GravaData(dDataDe,.F.,5)						//DE 126 ATE 133 -> 8 DDMMAAAA
		cTXT+= GravaData(dDataAte,.F.,5)					//DE 134 ATE 141 -> 8
		cTXT+= SPACE(2)										//DE 142 ATE 143 -> 2
		cTXT+= PADR(FDESC('SQB',SRA->RA_DEPTO,'QB_DESCRIC'),25)//DE 144 ATE 168 -> 20
		cTXT+= SPACE(36)									//DE 169 ATE 204 -> 36
		cTXT+= SPACE(36)									//DE 205 ATE 240 -> 36
		cTXT+= CHR(13)+CHR(10)								//PULA LINHA
		FWrite( nArq , cTXT )								//GRAVA SEGMENTO "A"
		//======================================================================================
		//	          FIM SEÇÃO: REGISTRO DETALHE DE LOTE  (SEGMENTO "A")    	               =
		//======================================================================================
	    
	
		//========================================================================================
		// SELECT PARA TRAZER AS CONTAS DE PROVENTOS(PAGAMENTOS) E DESCONTOS PARA O SEGMENTO "C" =
		//========================================================================================
		cQuery:= " SELECT * FROM "+cAlAuxRC+" SRC, "+RetSQLName("SRV")+" SRV "
		cQuery+= " WHERE "
		cQuery+= " RC_FILIAL = '"+SRA->RA_FILIAL+"' AND "
		cQuery+= " RC_MAT = '"+SRA->RA_MAT+"' AND "
		cQuery+= " RV_FILIAL = '"+xFilial("SRV")+"' AND "
		cQuery+= " RC_PD = RV_COD AND  "
		cQuery+= " RV_TIPOCOD IN ('1') AND  " //SOMENTE PROVENTO
		cQuery+= " SRV.D_E_L_E_T_ <> '*' AND "
		cQuery+= " SRC.D_E_L_E_T_ <> '*' "
		If Select("TRBSRC") <> 0
			DBSelectArea("TRBSRC")
			DBCloseArea()
		EndIf
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBSRC", .F., .T.)
		//===============================================================================================
		// FIM DO SELECT PARA TRAZER AS CONTAS DE PROVENTOS(PAGAMENTOS) E DESCONTOS PARA O SEGMENTO "C" =
		//===============================================================================================
			
		//======================================================================================
		//				 INICIO SEÇÃO: REGISTRO DETALHE DE LOTE (SEGMENTO "C")  	       	   =
		//======================================================================================
		nSequC := 00002											//INICIA CONTADOR DO SEGMENTO "C" COM '00002' E INCREMENTA POSIÇÃO 9 ATÉ 13
		Do While !TRBSRC->(Eof()) 
			cTXT:= "399"										//DE 1 ATE 3 -> 3
			cTXT+= "0003"										//DE 4 ATE 7 -> 4
			cTXT+= "3"											//DE 8 ATE 8 -> 1
			cTXT+= ALLTRIM(PADL(cValToChar(nSequC),5,"0"))		//DE 9 ATE 13-> 5
			cTXT+= "C"											//DE 14 ATE 14 -> 1
			cTXT+= "0"											//DE 15 ATE 15 -> 1
			cTXT+= "00"											//DE 16 ATE 17 -> 2
			cTXT+= "H"											//DE 18 ATE 18 -> 1
			//Primeiro Vencimento 
			If !TRBSRC->(Eof())                          
				cTXT+= PADR(AllTrim(TRBSRC->RV_DESC),29, " ")	//DE 19 ATE 47 -> 29
				cTXT+= "R$"										//DE 48 ATE 49 -> 2
				cTXT+= 	StrZero((TRBSRC->RC_VALOR*100),8)		//DE 50 ATE 57 -> 6
				TRBSRC->(DBSkip())
			Else
				cTXT+= Space(29)								//DE 19 ATE 47 -> 29
				cTXT+= "R$"                                 	//DE 48 ATE 49 -> 2
				cTXT+= StrZero(0,8)				                //DE 50 ATE 57 -> 6
			EndIf              
			//Segundo Vencimento                            
			If !TRBSRC->(Eof())
				cTXT+= PADR(AllTrim(TRBSRC->RV_DESC),29, " ")	//DE 58 ATE 86 -> 29
				cTXT+= "R$"										//DE 87 ATE 88 -> 2
				cTXT+= 	StrZero((TRBSRC->RC_VALOR*100),8)	 	//DE 89 ATE 96 -> 6
				TRBSRC->(DBSkip())							
			Else                                            
				cTXT+= Space(29)								//DE 58 ATE 86 -> 29
				cTXT+= "R$"										//DE 87 ATE 88 -> 2
				cTXT+= StrZero(0,8)	    						//DE 89 ATE 96 -> 6
			EndIf                                           
			//Terceiro Vencimento 							
			If !TRBSRC->(Eof())								
				cTXT+= PADR(AllTrim(TRBSRC->RV_DESC),29, " ")	//DE 97 ATE 125 -> 29
				cTXT+= "R$"										//DE 126 ATE 127 -> 2
				cTXT+= 	StrZero((TRBSRC->RC_VALOR*100),8)	 	//DE 128 ATE 135 -> 6
				TRBSRC->(DBSkip())                          
			Else                                            
				cTXT+= Space(29)								//DE 97 ATE 125 -> 29
				cTXT+= "R$"										//DE 126 ATE 127 -> 2
				cTXT+= 	StrZero(0,8)						 	//DE 128 ATE 135 -> 6
			EndIf    										
			//Quarto Vencimento								
			If !TRBSRC->(Eof())                             
				cTXT+= PADR(AllTrim(TRBSRC->RV_DESC),29, " ")	//DE 136 ATE 164 -> 29
				cTXT+= "R$"										//DE 165 ATE 166 -> 2
				cTXT+= 	StrZero((TRBSRC->RC_VALOR*100),8)	 	//DE 167 ATE 174 -> 6
				TRBSRC->(DBSkip())							 
			Else                                             
				cTXT+= Space(29)								//DE 136 ATE 164 -> 29
				cTXT+= "R$"										//DE 165 ATE 166 -> 2
				cTXT+= 	StrZero(0,8)							//DE 167 ATE 174 -> 6
			EndIf											 
			//Quinto Vencimento								 
			If !TRBSRC->(Eof())								 
				cTXT+= PADR(AllTrim(TRBSRC->RV_DESC),29, " ")	//DE 175 ATE 203 -> 29
				cTXT+= "R$"										//DE 204 ATE 205 -> 1
				cTXT+= 	StrZero((TRBSRC->RC_VALOR*100),8)	 	//DE 206 ATE 213 -> 8
				TRBSRC->(DBSkip())
			Else
				cTXT+= Space(29)								//DE 175 ATE 203 -> 29
				cTXT+= "R$"										//DE 204 ATE 205 -> 1
				cTXT+= 	StrZero(0,8)							//DE 206 ATE 213 -> 8
			EndIf
			cTXT+=SPACE(27)										//DE 214 ATE 240 -> 27
			cTXT+= CHR(13)+CHR(10)								//PULA LINHA
			FWrite( nArq , cTXT )								//GRAVA REGISTRO DE DETALHE SEGMENTO "C"
			nSeq++												//CONTADOR PARA CONTROLE DE LINHA
		   	If  TRBSRC->(Eof())
				TRBSRC->(DBSkip())
			EndIf
			++nSequC											//INCREMENTA O INDICE NA POSIÇÃO 9 ATÉ 13
		EndDo
		//======================================================================================
		//				 FIM SEÇÃO: REGISTRO DETALHE DE LOTE (SEGMENTO "C")                    =
		//======================================================================================
		
		
		//========================================================================================
		// 					SELECT PARA TRAZER OS DESCONTOS PARA O SEGMENTO "D" 				 =
		//========================================================================================
		cQuery:= " SELECT * FROM "+cAlAuxRC+" SRC, "+RetSQLName("SRV")+" SRV "
		cQuery+= " WHERE "
		cQuery+= " RC_FILIAL = '"+SRA->RA_FILIAL+"' AND "
		cQuery+= " RC_MAT = '"+SRA->RA_MAT+"' AND "
		cQuery+= " RV_FILIAL = '"+xFilial("SRV")+"' AND "
		cQuery+= " RC_PD = RV_COD AND  "
		cQuery+= " RV_TIPOCOD IN ('2') AND  " //SOMENTE DESCONTO
		cQuery+= " SRV.D_E_L_E_T_ <> '*' AND "
		cQuery+= " SRC.D_E_L_E_T_ <> '*' "
		If Select("TRBSRD") <> 0
			DBSelectArea("TRBSRD")
			DBCloseArea()
		EndIf
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBSRD", .F., .T.)
		//===============================================================================================
		// 					FIM DO SELECT PARA TRAZER OS DESCONTOS PARA O SEGMENTO "D" 					=
		//===============================================================================================
					
		//===========================================================================================
		//				 INICIO SEÇÃO: REGISTRO DETALHE DE LOTE (SEGMENTO "D")						=
		//SEGMENTO NÃO OBRIGATÓRIO CONFORME LAYOUT PASSADO PELO HSBC, INCLUÍDO A PEDIDO DO CLIENTE	=
		//===========================================================================================
		Do While !TRBSRD->(Eof()) 
			cTXT:= "399"										//DE 1 ATE 3 -> 3
			cTXT+= "0003"										//DE 4 ATE 7 -> 4
			cTXT+= "3"											//DE 8 ATE 8 -> 1
			cTXT+= ALLTRIM(PADL(cValToChar(nSequC),5,"0"))		//DE 9 ATE 13-> 5
			cTXT+= "D"											//DE 14 ATE 14 -> 1
			cTXT+= "0"											//DE 15 ATE 15 -> 1
			cTXT+= "00"											//DE 16 ATE 17 -> 2
			cTXT+= "H"		 									//DE 18 ATE 18 -> 1
			//Primeiro Desconto 
			If !TRBSRD->(EOF())                          
				cTXT+= PADR(AllTrim(TRBSRD->RV_DESC),29, " ")	//DE 19 ATE 47 -> 29
				cTXT+= "R$"										//DE 48 ATE 49 -> 2
				cTXT+= 	StrZero((TRBSRD->RC_VALOR*100),8)		//DE 50 ATE 57 -> 6
				TRBSRD->(DBSkip())
			Else
				cTXT+= Space(29)								//DE 19 ATE 47 -> 29
				cTXT+= "R$"                                     //DE 48 ATE 49 -> 2
				cTXT+= StrZero(0,8)                             //DE 50 ATE 57 -> 6
			EndIf
			//Segundo Desconto                            
			If !TRBSRD->(Eof())
				cTXT+= PADR(AllTrim(TRBSRD->RV_DESC),29, " ")	//DE 58 ATE 86 -> 29
				cTXT+= "R$"										//DE 87 ATE 88 -> 2
				cTXT+= 	StrZero((TRBSRD->RC_VALOR*100),8)	 	//DE 89 ATE 96 -> 6
				TRBSRD->(DBSkip())							
			Else                                            
				cTXT+= Space(29)								//DE 58 ATE 86 -> 29
				cTXT+= "R$"										//DE 87 ATE 88 -> 2
				cTXT+= 	StrZero(0,8)							//DE 89 ATE 96 -> 6
			EndIf                                           
			//Terceiro Desconto 							
			If !TRBSRD->(Eof())								
				cTXT+= PADR(AllTrim(TRBSRD->RV_DESC),29, " ")	//DE 97 ATE 125 -> 29
				cTXT+= "R$"										//DE 126 ATE 127 -> 2
				cTXT+= 	StrZero((TRBSRD->RC_VALOR*100),8)	 	//DE 128 ATE 135 -> 6
				TRBSRD->(DBSkip())                          
			Else                                            
				cTXT+= Space(29)								//DE 97 ATE 125 -> 29
				cTXT+= "R$"										//DE 126 ATE 127 -> 2
				cTXT+= 	StrZero(0,8)						 	//DE 128 ATE 135 -> 6
			EndIf    										
			//Quarto Desconto								
			If !TRBSRD->(Eof())                             
				cTXT+= PADR(AllTrim(TRBSRD->RV_DESC),29, " ")	//DE 136 ATE 164 -> 29
				cTXT+= "R$"										//DE 165 ATE 166 -> 2
				cTXT+= 	StrZero((TRBSRD->RC_VALOR*100),8)	 	//DE 167 ATE 174 -> 6
				TRBSRD->(DBSkip())							 
			Else                                             
				cTXT+= Space(29)								//DE 136 ATE 164 -> 29
				cTXT+= "R$"										//DE 165 ATE 166 -> 2
				cTXT+= 	StrZero(0,8)							//DE 167 ATE 174 -> 6
			EndIf											 
			//Quinto Desconto								 
			If !TRBSRD->(Eof())								 
				cTXT+= PADR(AllTrim(TRBSRD->RV_DESC),29, " ")	//DE 175 ATE 203 -> 29
				cTXT+= "R$"										//DE 204 ATE 205 -> 1
				cTXT+= 	StrZero((TRBSRD->RC_VALOR*100),8)	 	//DE 206 ATE 213 -> 8
				TRBSRD->(DBSkip())
			Else
				cTXT+= Space(29)								//DE 175 ATE 203 -> 29
				cTXT+= "R$"										//DE 204 ATE 205 -> 1
				cTXT+= 	StrZero(0,8)							//DE 206 ATE 213 -> 8
			EndIf
			cTXT+=SPACE(27)										//DE 214 ATE 240 -> 27
			cTXT+= CHR(13)+CHR(10)								//PULA LINHA
			FWrite( nArq , cTXT )								//GRAVA REGISTRO DE DETALHE SEGMENTO "C"
			nSeq++												//CONTADOR PARA CONTROLE DE LINHA
			If  TRBSRD->(Eof())
				TRBSRD->(DBSkip())
			EndIf
			++nSequC											//INCREMENTA O INDICE NA POSIÇÃO 9 ATÉ 13
		EndDo
		//===========================================================================================
		//				  FIM SEÇÃO: REGISTRO DETALHE DE LOTE (SEGMENTO "D")						=
		//SEGMENTO NÃO OBRIGATÓRIO CONFORME LAYOUT PASSADO PELO HSBC, INCLUÍDO A PEDIDO DO CLIENTE	=
		//===========================================================================================
        
        
		//============================================================
		// SELECT PARA TRAZER AS CONTAS DE BASE PARA O SEGMENTO "O"  =
		//============================================================
		cQuery:= " SELECT * FROM "+RetSQLName("SRV")+" SRV INNER JOIN "+cAlAuxRC+" SRC"
		cQuery+= " ON (SRC. RC_PD = SRV.RV_COD)"
		cQuery+= " WHERE"
		cQuery+= " RC_FILIAL ='" +xFilial("SRC")+"'AND "
		cQuery+= " RV_FILIAL=' " +xFilial("SRV")+"'AND"
		cQuery+= " RC_MAT = '"+SRA->RA_MAT+"' AND "
		cQuery+= " RV_TIPOCOD = '3' AND"  //SOMENTE BASE.
		cQuery+= " RV_COD IN (" + GetNewPar("MV_GPE001H") + ") AND"  //PARAMETRO CADASTRADO NO SIGACFG.
		cQuery+= " SRV.D_E_L_E_T_ <> '*' AND "
		cQuery+= " SRC.D_E_L_E_T_ <> '*' "
		If Select("TRBSRO") <> 0
			DBSelectArea("TRBSRO")
			DBCloseArea()
		EndIf
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBSRO", .F., .T.)
		//==================================================================
		// FIM DO SELECT PARA TRAZER AS CONTAS DE BASE PARA O SEGMENTO "O" =
		//==================================================================
        
        //===========================================================================================
		//				 INICIO SEÇÃO: REGISTRO DETALHE DE LOTE (SEGMENTO "O")						=
		//SEGMENTO NÃO OBRIGATÓRIO CONFORME LAYOUT PASSADO PELO HSBC, INCLUÍDO A PEDIDO DO CLIENTE	=
		//===========================================================================================
		Do While !TRBSRO->(Eof()) 
			cTXT:= "399"										//DE 1 ATE 3 -> 3
			cTXT+= "0003"										//DE 4 ATE 7 -> 4
			cTXT+= "3"											//DE 8 ATE 8 -> 1
			cTXT+= ALLTRIM(PADL(cValToChar(nSequC),5,"0"))		//DE 9 ATE 13-> 5
			cTXT+= "O"											//DE 14 ATE 14 -> 1
			cTXT+= "0"											//DE 15 ATE 15 -> 1
			cTXT+= "00"											//DE 16 ATE 17 -> 2
			cTXT+= "H"											//DE 18 ATE 18 -> 1
			//Primeiro Vencimento da BASE 
			If !TRBSRO->(EOF())                  	
				cTXT+= PADR(AllTrim(TRBSRO->RV_DESC) + " R$ " + Alltrim(Transform(TRBSRO->RC_VALOR, "@E 999,999.99")),40," ")  //DE 19 ATE 58 -> 40
				cTXT+= SPACE(1)         							//DE 59 ATE 59 -> 1
				TRBSRO->(DBSkip())
			Else
				cTXT+= Space(40)								//DE 19 ATE 58 -> 40 
				cTXT+= Space(1)                                 //DE 59 ATE 59 -> 1
			EndIf                            
			//Segundo Vencimento                            
			If !TRBSRO->(Eof())
				cTXT+= PADR(AllTrim(TRBSRO->RV_DESC) + " R$ " + Alltrim(Transform(TRBSRO->RC_VALOR, "@E 999,999.99")),40," ")   //DE 60 ATE 99 -> 40
				cTXT+= space(1)
				TRBSRO->(DBSkip())  						
			Else                                            
				cTXT+= Space(40)								//DE 60 ATE 99 -> 40
				cTXT+= Space(1)									//DE 100 ATE 100 -> 1
			EndIf                                           
			//Terceiro Vencimento 							
			If !TRBSRO->(Eof())								
				cTXT+= PADR(AllTrim(TRBSRO->RV_DESC) + " R$ " + Alltrim(Transform(TRBSRO->RC_VALOR, "@E 999,999.99")),40," ")   //DE 101 ATE 140 -> 40
				cTXT+= Space(1)
				TRBSRO->(DBSkip())                          
			Else                                             
				cTXT+= Space(40)   							 	//DE 100 ATE 140 -> 40
				cTXT+= space(1)								 	//DE 141 ATE 141 -> 1
			EndIf    										 
			//Quarto Vencimento								 
			If !TRBSRO->(Eof())                              
				cTXT+= PADR(AllTrim(TRBSRO->RV_DESC) + " R$ " + Alltrim(Transform(TRBSRO->RC_VALOR, "@E 999,999.99")),40," ")   //DE 142 ATE 181 -> 40
				cTXT+= Space(1)								 	//DE 182 ATE 182 -> 1
				TRBSRC->(DBSkip())							 
			Else                                             
				cTXT+= Space(40)								//DE 142 ATE 181 -> 40
				cTXT+= Space(1)								 	//DE 182 ATE 182 -> 1
			EndIf											 
			//Quinto Vencimento								 
			If !TRBSRO->(Eof())								 
				cTXT+= PADR(AllTrim(TRBSRO->RV_DESC) + " R$ " + Alltrim(Transform(TRBSRO->RC_VALOR, "@E 999,999.99")),40," ")   //DE 183 ATE 222 -> 40
				cTXT+= Space(1)									//DE 123 ATE 223 -> 1
				TRBSRO->(DBSkip())
			Else
				cTXT+= Space(40)							 	//DE 183 ATE 222 -> 40
				cTXT+= Space(1)								 	//DE 223 ATE 223 -> 1
			EndIf
			cTXT+=SPACE(17)									 	//DE 224 ATE 240 -> 17
			cTXT+= CHR(13)+CHR(10)								//PULA LINHA
			FWrite( nArq , cTXT )								//GRAVA REGISTRO DE DETALHE SEGMENTO "O"
			nSeq++												//CONTADOR PARA CONTROLE DE LINHA
			If  !TRBSRO->(Eof())
				TRBSRO->(DBSkip())
			EndIf
			++nSequC											
		EndDo
		//===========================================================================================
		//				 INICIO SEÇÃO: REGISTRO DETALHE DE LOTE (SEGMENTO "O")						=
		//SEGMENTO NÃO OBRIGATÓRIO CONFORME LAYOUT PASSADO PELO HSBC, INCLUÍDO A PEDIDO DO CLIENTE	=
		//===========================================================================================
		dbSelectArea( "SRA" )
		dbSkip()
	Enddo
	  
	nSeq++
	//======================================================================================
	//				 	INICIO SEÇÃO: REGISTRO TRAILLER DE LOTE                            =
	//======================================================================================
	cTXT:= "399"										//DE 1 ATE 3 -> 3
	cTXT+= "0005"										//DE 4 ATE 7 -> 4
	cTXT+= "5"											//DE 8 ATE 8 -> 1
	cTXT+= SPACE(9)										//DE 9 ATE 17 -> 9  
	cTXT+= Strzero(nSeq,6) 								//DE 18 ATE 23 -> 6
	cTXT+= SPACE(3)										//DE 24 ATE 26 -> 3
	cTXT+= SPACE(13)									//DE 27 ATE 41 -> 13
	cTXT+= SPACE(201)									//DE 42 ATE 240 -> 199 
	cTXT+= CHR(13)+CHR(10)								//PULA LINHA
	FWrite( nArq , cTXT )								//GRAVA REGISTRO DE LOTE
	//======================================================================================
	//				       FIM SEÇÃO: REGISTRO TRAILLER DE LOTE                            =
	//======================================================================================
	nSeq++
	//======================================================================================
	//				 INICIO SEÇÃO: REGISTRO TRAILLER DE ARQUIVO                            =
	//======================================================================================
	cTXT:= "399"										//DE 1 ATE 3 -> 3
	cTXT+= "9999"										//DE 4 ATE 7 -> 4
	cTXT+= "9"											//DE 8 ATE 8 -> 1
	cTXT+= SPACE(9)										//DE 9 ATE 17 -> 9 
	cTXT+= strzero(1,6)									//DE 18 ATE 23 -> 6
	cTXT+= strzero(nSeq+1,6)							//DE 24 ATE 29 -> 6
	cTXT+= SPACE(211)									//DE 30 ATE 240 -> 211	
	cTXT+= CHR(13)+CHR(10)								//PULA LINHA
	FWrite( nArq , cTXT )								//GRAVA REGISTRO DE TRAILLER
	//======================================================================================
	//				      FIM SEÇÃO: REGISTRO TRAILLER DE ARQUIVO                          =
	//======================================================================================
	FClose( nArq )
Return

//=====================================================
//GRUPO DE PERGUNTAS PARA GERAÇÃO DO HOLERITE EM TXT. =
//=====================================================
Static Function MGPE001Perg(cPerg)

	//PutSX1(cPerg, "01", "Adiantamento?"          , "", "", "mv_par01", "N", 01,  0, 0, "C", "", ""      , "", "", "mv_par01", "SIM","","","","NÃO","","","","","","","","","","","")
	//PutSX1(cPerg, "02", "Folha?"            	 , "", "", "mv_par02", "N", 01,  0, 0, "C", "", ""      , "", "", "mv_par02", "SIM","","","","NÃO","","","","","","","","","","","")
	//PutSX1(cPerg, "03", "1ªParc. 13º Salario?"   , "", "", "mv_par03", "N", 01,  0, 0, "C", "", "" 	    , "", "", "mv_par03", "SIM","","","","NÃO","","","","","","","","","","","")
	//PutSX1(cPerg, "04", "2ªParc. 13º Salario?"   , "", "", "mv_par04", "N", 01,  0, 0, "C", "", ""	    , "", "", "mv_par04", "SIM","","","","NÃO","","","","","","","","","","","")
	//PutSX1(cPerg, "05", "Ferias?"             	 , "", "", "mv_par05", "N", 01,  0, 0, "C", "", ""	    , "", "", "mv_par05", "SIM","","","","NÃO","","","","","","","","","","","")
	//PutSX1(cPerg, "06", "Extras?"            	 , "", "", "mv_par06", "N", 01,  0, 0, "C", "", ""      , "", "", "mv_par06", "SIM","","","","NÃO","","","","","","","","","","","")
	//PutSX1(cPerg, "07", "Numero Semana?"         , "", "", "mv_par07", "C", 02,  0, 0, "G", "", ""	    , "", "", "mv_par07", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "08", "Filial De?"             , "", "", "mv_par08", "C", 02,  0, 0, "G", "", "XM0"   , "", "", "mv_par08", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "09", "Filial Ate?"            , "", "", "mv_par09", "C", 02,  0, 0, "G", "", "XM0"   , "", "", "mv_par09", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "10", "Centro de Custo De?"    , "", "", "mv_par10", "C", 09,  0, 0, "G", "", "CTT"   , "", "", "mv_par10", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "11", "Centro de Custo Ate?"   , "", "", "mv_par11", "C", 09,  0, 0, "G", "", "CTT"   , "", "", "mv_par11", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "12", "Banco/ Agencia De?"     , "", "", "mv_par12", "C", 08,  0, 0, "G", "", "BA1"   , "", "", "mv_par12", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "13", "Banco/ Agencia Ate? "   , "", "", "mv_par13", "C", 08,  0, 0, "G", "", "BA1"   , "", "", "mv_par13", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "14", "Matricula De?"          , "", "", "mv_par14", "C", 06,  0, 0, "G", "", "SRA"   , "", "", "mv_par14", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "15", "Matricula Ate?"         , "", "", "mv_par15", "C", 06,  0, 0, "G", "", "SRA"   , "", "", "mv_par15", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "16", "Nome De?"          	 , "", "", "mv_par16", "C", 30,  0, 0, "G", "", ""      , "", "", "mv_par16", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "17", "Nome Ate?"           	 , "", "", "mv_par17", "C", 30,  0, 0, "G", "", ""      , "", "", "mv_par17", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "18", "Conta  Corrente De?"    , "", "", "mv_par18", "C", 12,  0, 0, "G", "", ""      , "", "", "mv_par18", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "19", "Conta  Corrente Ate?"   , "", "", "mv_par19", "C", 12,  0, 0, "G", "", ""      , "", "", "mv_par19", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "20", "Situacoes"          	 , "", "", "mv_par20", "C", 05,  0, 0, "G", "fSituacao" , ""    , "", "", "mv_par20", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "21", "Arquivo de Saida?"    	 , "", "", "mv_par21", "C", 30,  0, 0, "G", "", ""      , "", "", "mv_par21", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "22", "Data de Crédito?"       , "", "", "mv_par22", "D", 08,  0, 0, "G", "", ""      , "", "", "mv_par22", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "23", "Data de Pagamento De?"  , "", "", "mv_par23", "D", 08,  0, 0, "G", "", ""      , "", "", "mv_par23", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "24", "Data de Pagamento Ate?" , "", "", "mv_par24", "D", 08,  0, 0, "G", "", ""      , "", "", "mv_par24", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "25", "Categorias?"            , "", "", "mv_par25", "C", 15,  0, 0, "G", "fCategoria", ""    , "", "", "mv_par25", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "26", "Recisao?"          	 , "", "", "mv_par26", "N", 01,  0, 0, "C", "", ""      , "", "", "mv_par26", "SIM","","","","NÃO","","","","","","","","","","","")
	//PutSX1(cPerg, "27", "Gerar?"           	 	 , "", "", "mv_par27", "N", 01,  0, 0, "C", "", ""      , "", "", "mv_par27", "Funcionários","","","","Beneficiários","","","Ambos","","","","","","","","")
	//PutSX1(cPerg, "28", "Data de Referencia?"    , "", "", "mv_par28", "D", 08,  0, 0, "G", "", ""      , "", "", "mv_par28", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "29", "Banco Envio?"    		 , "", "", "mv_par29", "C", 03,  0, 0, "G", "", "SA6"   , "", "", "mv_par29", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "30", "Agencia Envio?"    	 , "", "", "mv_par30", "C", 05,  0, 0, "G", "", ""      , "", "", "mv_par30", "","","","","","","","","","","","","","","","")
	//PutSX1(cPerg, "31", "Conta Envio?"    		 , "", "", "mv_par31", "C", 10,  0, 0, "G", "", ""      , "", "", "mv_par31", "","","","","","","","","","","","","","","","")

Return

