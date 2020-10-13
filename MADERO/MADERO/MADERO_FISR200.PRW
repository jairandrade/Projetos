/*
+----------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Relatório                                               !
+------------------+---------------------------------------------------------+
!Módulo            ! Livros Fiscais                                          !
+------------------+---------------------------------------------------------+
!Nome              ! FISR200                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Relatório de Saldos e Valores                           !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                  		     !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 09/10/2018                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!PUTSX1 customizado							!           !           !        !
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

#include "totvs.ch"
#include "rwmake.ch"
#include "topconn.ch"

User Function FISR200()
//FWGrpEmp - Retorno de informações de empresa e filial ( cGrpID, lLayout ) --> aEmp
//FWFilialName()
Local oReport
Private cPerg := PadR("FISR200",10)

CriaPerg(cPerg)
Pergunte(cPerg,.F.)

oReport := ReportDef()
oReport:PrintDialog()

Return

Static Function ReportDef()

Local oReport
Local oSessao

oReport := TReport():New("FISR200", "Relatório de Apurações Fiscais", cPerg, {|oReport| ReportPrint(oReport)}, "Relatório de Apurações Fiscais")
oReport:SetLandscape(.T.)
oSessao := TRSection():New(oReport, "Relatório de Apurações Fiscais" )

// Colunas padrão
TRCell():New( oSessao, "FILIAL"      	, "","Filial"					,"@!"  							,10)
TRCell():New( oSessao, "DESCRICAO"      , "","Descrição"				,"@!"  							,40)
TRCell():New( oSessao, "CDH_DTINI"     , "",RetTitle("CDH_DTINI")		,PesqPict("CDH","CDH_DTINI")  	,TamSx3("CDH_DTINI")[1])
TRCell():New( oSessao, "CDH_DTFIM"     , "",RetTitle("CDH_DTFIM")		,PesqPict("CDH","CDH_DTFIM")  	,TamSx3("CDH_DTFIM")[1])
TRCell():New( oSessao, "ICMS"     		, "","ICMS"	   					,"@E 999,999,999.99"  			,13,,,"RIGHT",,"RIGHT")
TRCell():New( oSessao, "ICMS-ST"     	, "","ICMS-ST"					,"@E 999,999,999.99"  			,13,,,"RIGHT",,"RIGHT")
TRCell():New( oSessao, "DIFAL EC 87/2015", "","DIFAL EC 87/2015"		,"@E 999,999,999.99" 			,13,,,"RIGHT",,"RIGHT")
TRCell():New( oSessao, "FECP EC 87/2015", "","FECP EC 87/2015"			,"@E 999,999,999.99"  			,13,,,"RIGHT",,"RIGHT")
TRCell():New( oSessao, "IPI"     		, "","IPI"						,"@E 999,999,999.99"  			,13,,,"RIGHT",,"RIGHT")
TRCell():New( oSessao, "PIS"     		, "","PIS"						,"@E 999,999,999.99"  			,13,,,"RIGHT",,"RIGHT")
TRCell():New( oSessao, "COFINS"     	, "","COFINS"					,"@E 999,999,999.99"  			,13,,,"RIGHT",,"RIGHT")
TRCell():New( oSessao, "IRPJ"     		, "","IRPJ"						,"@E 999,999,999.99"  			,13,,,"RIGHT",,"RIGHT")
TRCell():New( oSessao, "CSLL"      		, "","CSLL"	   			   		,"@E 999,999,999.99"   			,13,,,"RIGHT",,"RIGHT")
TRCell():New( oSessao, "ISS"      		, "","ISS"	   			   		,"@E 999,999,999.99"   			,13,,,"RIGHT",,"RIGHT")

oSessao:lHeaderVisible:=.T.
//	Totalizacao
oSN3H := trBreak():New(oSessao,{||},"Total Geral",.F.)
//TRFUNCTION():New(oCell,cName,cFunction,oBreak,cTitle,cPicture,uFormula,lEndSection,lEndReport,lEndPage,oParent,bCondition,lDisable,bCanPrint)
TRFunction():New(oSessao:Cell("ICMS"),NIL,"SUM",oSN3H,,,,.F.,.F.)
TRFunction():New(oSessao:Cell("ICMS-ST"),NIL,"SUM",oSN3H,,,,.F.,.F.)
TRFunction():New(oSessao:Cell("DIFAL EC 87/2015"),NIL,"SUM",oSN3H,,,,.F.,.F.)
TRFunction():New(oSessao:Cell("FECP EC 87/2015"),NIL,"SUM",oSN3H,,,,.F.,.F.)
TRFunction():New(oSessao:Cell("IPI"),NIL,"SUM",oSN3H,,,,.F.,.F.)
TRFunction():New(oSessao:Cell("PIS"),NIL,"SUM",oSN3H,,,,.F.,.F.)
TRFunction():New(oSessao:Cell("COFINS"),NIL,"SUM",oSN3H,,,,.F.,.F.)
TRFunction():New(oSessao:Cell("IRPJ"),NIL,"SUM",oSN3H,,,,.F.,.F.)
TRFunction():New(oSessao:Cell("CSLL"),NIL,"SUM",oSN3H,,,,.F.,.F.)
TRFunction():New(oSessao:Cell("ISS"),NIL,"SUM",oSN3H,,,,.F.,.F.)

oReport:SetTotalInLine(.F.)

//oReport:HideParamPage()

Return (oReport)

Static Function ReportPrint(oReport)

Local oBreak
Local oSessao  := oReport:Section(1)
Local nTotICMS := 0
Local nTotICMT := 0
Local nTotDIFA := 0
Local nTotFECP := 0
Local nTotIPI  := 0
Local nTotPIS  := 0
Local nTotCOF  := 0
Local nTotIRPJ := 0
Local nIRPJTri := 0
Local nTotCSLL := 0
Local nTotISS  := 0
Local nQtdMeses:= 0
Local dData1
Local dData2

//valida qtd de meses selecionados atraves dos parametros MV_PAR03 e MV_PAR04
nQtdMeses 	:= DateDiffMonth(MV_PAR03,MV_PAR04)
dData1		:= MV_PAR03

oSessao:Init()
//Verificar as filiais selecionadas
DbSelectArea("SM0")
SM0->(DbGoTop())
While !SM0->(EoF())
	If SM0->M0_CODIGO == cEmpAnt  .and. (SM0->M0_CODFIL >= MV_PAR01 .AND. SM0->M0_CODFIL <=MV_PAR02)
		for ni:= 0 to nQtdMeses
			If ni == nQtdMeses
				dData2 := MV_PAR04
			Else
				dData2 := LastDate(dData1)
			EndIf
			//Se a filial for encontrado, segue as consultas por filial
			//1 - apuração do ICMS
			nTotICMS :=	fPesqICMS(SM0->M0_CODFIL,"IC",dData1,dData2)
			//2 - apuração do ICMS Subst. Tributária
			nTotICMT := fPesqICMS(SM0->M0_CODFIL,"ST",dData1,dData2)
			//3 - apuração do DIFAL EC 87/2015
			nTotDIFA := fPesqDifa(SM0->M0_CODFIL,1,dData1,dData2)
			//4 - apuração do FECP EC 87/2015
			nTotFECP := fPesqDifa(SM0->M0_CODFIL,2,dData1,dData2)
			//5 - apuração do IPI
			nTotIPI := fPesqIPI(SM0->M0_CODFIL,dData1,dData2)
			//6 - apuração do PIS
			nTotPIS := fPesqPIS(SM0->M0_CODFIL,"1",dData1,dData2)
			//7 - apuração do COFINS
			nTotCOF := fPesqPIS(SM0->M0_CODFIL,"2",dData1,dData2)
			//8 - apuração do IRPJ (Lucro Real ou Presumido)
			nTotIRPJ := fPesqIRPJ(SM0->M0_CODFIL,"000019",dData1,dData2)
			//9 - apuração do CSLL (Lucro Real ou Presumido)
			nTotCSLL := fPesqIRPJ(SM0->M0_CODFIL,"000018",dData1,dData2)
			//10 - apuração do ISS
			nTotISS :=fPesqISS(SM0->M0_CODFIL,dData1,dData2)
			
			If oReport:Cancel()
				//	Exit
			EndIf
			oReport:IncMeter()
			
			If (nTotICMS >0 .or. nTotICMT >0 .or. nTotDIFA >0 .or. nTotISS >0 .or. nTotFECP >0  .or. nTotIPI >0 .or. nTotPIS >0 .or. nTotCOF >0 .or. nTotIRPJ >0 .or. nTotCSLL >0)
				oSessao:Cell("FILIAL"):SetValue(FWCodFil())
				oSessao:Cell("DESCRICAO"):SetValue(FWFilialName(cEmpAnt,SM0->M0_CODFIL,1))
				oSessao:Cell("CDH_DTINI"):SetValue(dData1)
				oSessao:Cell("CDH_DTFIM"):SetValue(dData2)
				oSessao:Cell("ICMS"):SetValue(nTotICMS)
				oSessao:Cell("ICMS-ST"):SetValue(nTotICMT)
				oSessao:Cell("DIFAL EC 87/2015"):SetValue(nTotDIFA)
				oSessao:Cell("FECP EC 87/2015"):SetValue(nTotFECP)
				oSessao:Cell("IPI"):SetValue(nTotIPI)
				oSessao:Cell("PIS"):SetValue(nTotPIS)
				oSessao:Cell("COFINS"):SetValue(nTotCOF)
				oSessao:Cell("IRPJ"):SetValue(nTotIRPJ)
				oSessao:Cell("CSLL"):SetValue(nTotCSLL)
				oSessao:Cell("ISS"):SetValue(nTotISS)
				oSessao:PrintLine()
			EndIf
			//Calculo Trimestre IRPJ(Lucro Real ou Presumido)  insere 4 linhas a mais se nIRPJTri >0  (mes 3-março,6-junho,9-setembro,12-dezembro).
			If nQtdMeses>=2 .and. Month2Str(dData1)$"03,06,09,12"
				nIRPJTri := fPesqIRPJ(SM0->M0_CODFIL,"000019",MonthSub(dData1,2),LastDate(dData1))
			   	If nIRPJTri >0
					oSessao:Cell("FILIAL"):SetValue(FWCodFil())
					oSessao:Cell("DESCRICAO"):SetValue(FWFilialName(cEmpAnt,SM0->M0_CODFIL,1))
					oSessao:Cell("CDH_DTINI"):SetValue(MonthSub(dData1,2))
					oSessao:Cell("CDH_DTFIM"):SetValue(LastDate(dData1))
					oSessao:Cell("ICMS"):SetValue(0)
					oSessao:Cell("ICMS-ST"):SetValue(0)
					oSessao:Cell("DIFAL EC 87/2015"):SetValue(0)
					oSessao:Cell("FECP EC 87/2015"):SetValue(0)
					oSessao:Cell("IPI"):SetValue(0)
					oSessao:Cell("PIS"):SetValue(0)
					oSessao:Cell("COFINS"):SetValue(0)
					oSessao:Cell("IRPJ"):SetValue(nIRPJTri)
					oSessao:Cell("CSLL"):SetValue(0)
					oSessao:Cell("ISS"):SetValue(0)
					oSessao:PrintLine()
			  	EndIf
			EndIf
			dData1	:= MonthSum( dData1, 1 )        
		Next nI
		
	EndIf
	
	SM0->(DbSkip())
EndDo

oSessao:Finish()
oReport:SetTotalInLine(.F.)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CriaPerg
Função para criação das perguntas na SX1

@author Jair  Matos
@since 14/11/2017
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CriaPerg( cPerg )

/*/{Protheus.doc} CriaPerg
Função para criar Grupo de Perguntas
@author Jair Matos
@since 01/02/2018
@version 1.0
@type function
@param cGrupo,    characters, Grupo de Perguntas       (ex.: X_TESTE)
@param cOrdem,    characters, Ordem da Pergunta        (ex.: 01, 02, 03, ...)
@param cTexto,    characters, Texto da Pergunta        (ex.: Produto De, Produto Até, Data De, ...)
@param cMVPar,    characters, MV_PAR?? da Pergunta     (ex.: MV_PAR01, MV_PAR02, MV_PAR03, ...)
@param cVariavel, characters, Variável da Pergunta     (ex.: MV_CH0, MV_CH1, MV_CH2, ...)
@param cTipoCamp, characters, Tipo do Campo            (C = Caracter, N = Numérico, D = Data)
@param nTamanho,  numeric,    Tamanho da Pergunta      (Máximo de 60)
@param nDecimal,  numeric,    Tamanho de Decimais      (Máximo de 9)
@param cTipoPar,  characters, Tipo do Parâmetro        (G = Get, C = Combo, F = Escolha de Arquivos, K = Check Box)
@param cValid,    characters, Validação da Pergunta    (ex.: Positivo(), u_SuaFuncao(), ...)
@param cF3,       characters, Consulta F3 da Pergunta  (ex.: SB1, SA1, ...)
@param cPicture,  characters, Máscara do Parâmetro     (ex.: @!, @E 999.99, ...)
@param cDef01,    characters, Primeira opção do combo
@param cDef02,    characters, Segunda opção do combo
@param cDef03,    characters, Terceira opção do combo
@param cDef04,    characters, Quarta opção do combo
@param cDef05,    characters, Quinta opção do combo
@param cHelp,     characters, Texto de Help do parâmetro
@obs Função foi criada, pois a partir de algumas versões do Protheus 12, a função padrão PutSX1 não funciona (por medidas de segurança)
@example Abaixo um exemplo de como criar um grupo de perguntas
/*/

cValid   := ""
cF3      := ""
cPicture := ""
cDef01   := ""
cDef02   := ""
cDef03   := ""
cDef04   := ""
cDef05   := ""

U_XPutSX1(cPerg, "01", "Filial De?",       		"MV_PAR01", "MV_CH0", "C", 10, 	0, "G", cValid,     "SM0",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a filial inicial")
U_XPutSX1(cPerg, "02", "Filial Até?",      		"MV_PAR02", "MV_CH1", "C", 10,  0, "G", cValid,     "SM0",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a filial final")
U_XPutSX1(cPerg, "03", "Data Inicio?",  		"MV_PAR03", "MV_CH2", "D", 08,  0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a data inicial a ser considerada")
U_XPutSX1(cPerg, "04", "Data Fim?",  			"MV_PAR04", "MV_CH3", "D", 08,  0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a data final a ser considerada")

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fPesqICMS
Função para pesquisa da apuração do ICMS

@author Jair  Matos
@since 09/10/2018
@version P12
@return nValor
/*/
//---------------------------------------------------------------------
Static Function fPesqICMS(filcor,cTipoIp,data1,data2)
Local nValor :=0
Local cQuery := ""
cQuery += " SELECT CDH_LINHA LINHA,CDH1.CDH_VALOR VALOR FROM " + RetSqlName("CDH") + " CDH1 "
cQuery += " WHERE CDH1.CDH_FILIAL = '" +filcor+"' "
cQuery += " AND CDH1.CDH_DTINI >= '" +Dtos(data1)+"' "
cQuery += " AND  CDH1.CDH_DTFIM <= '" +Dtos(data2)+"' "
cQuery += " AND CDH1.CDH_TIPOIP  = '" +cTipoIp+"' "
If cTipoIp =='IC'
	cQuery += "	AND CDH1.CDH_LINHA IN('013','014') "
Else
	cQuery += "	AND CDH1.CDH_LINHA IN('015','016') "
EndIf
cQuery += " AND CDH1.D_E_L_E_T_ = ' ' "
cQuery += " AND CDH1.CDH_SEQUEN  = (SELECT max(CDH2.CDH_SEQUEN) FROM " + RetSqlName("CDH") + " CDH2 "
cQuery += " WHERE CDH2.D_E_L_E_T_ = ' ' AND CDH2.CDH_TIPOIP  = CDH1.CDH_TIPOIP AND CDH2.CDH_FILIAL = CDH1.CDH_FILIAL )"
Memowrite("c:\temp\fPesqICMS.txt",CQuery) 

If Select("cAl") > 0
	Dbselectarea("cAl")
	cAl->(DbClosearea())
EndIf

TCQuery cQuery new Alias "cAl"
cAl->(DbGoTop())
While !cAl->(Eof())
	If cAl->VALOR > 0
		If cAl->LINHA$"013,015"
			//	nValor := cAl->VALOR * -1  RETIRADO o valor negativo por jeferson
			nValor := cAl->VALOR
			Exit
		Else
			nValor := cAl->VALOR
			Exit
		EndIf
	EndIf
	cAl->(dbSkip())
Enddo

Return nValor
//---------------------------------------------------------------------
/*/{Protheus.doc} fPesqDifa
Função para pesquisa da apuração do DIFAL EC 87/2015

@author Jair  Matos
@since 09/10/2018
@version P12
@return nValor
/*/
//---------------------------------------------------------------------
Static Function fPesqDifa(filcor,nOpc,data1,data2)
Local nValor :=0
Local cQuery := ""
If nOpc ==1
	cQuery += " SELECT F0I.F0I_DIFREC REC,F0I.F0I_SPDIF SALDO FROM " + RetSqlName("F0I") + " F0I "
Else
	cQuery += " SELECT F0I.F0I_FCPREC REC,F0I.F0I_SPFCP SALDO FROM " + RetSqlName("F0I") + " F0I "
EndIf
cQuery += " WHERE F0I.F0I_FILIAL = '" +filcor+"' "
cQuery += " AND F0I.F0I_PER BETWEEN '"+dtos(data1)+"' AND '"+dtos(data2)+"'"
cQuery += " AND F0I.D_E_L_E_T_ = ' ' "

Memowrite("c:\temp\fPesqDifa.txt",CQuery)

If Select("cAl") > 0
	Dbselectarea("cAl")
	cAl->(DbClosearea())
EndIf

TCQuery cQuery new Alias "cAl"
cAl->(DbGoTop())
While !cAl->(Eof())
	If cAl->REC > 0
		nValor := cAl->REC  // *-1 RETIRADO o valor negativo por jeferson
	Else
		nValor := cAl->SALDO
	EndIf
	cAl->(dbSkip())
Enddo

Return nValor
//---------------------------------------------------------------------
/*/{Protheus.doc} fPesqIPI
Função para pesquisa da apuração do IPI

@author Jair  Matos
@since 09/10/2018
@version P12
@return nValor
/*/
//---------------------------------------------------------------------
Static Function	fPesqIPI(filcor,data1,data2)
Local nValor :=0
Local cQuery := ""
cQuery += " SELECT CDP.CDP_LINHA LINHA,CDP.CDP_VALOR VALOR FROM " + RetSqlName("CDP") + " CDP "
cQuery += " WHERE CDP.CDP_FILIAL = '" +filcor+"' "
cQuery += " AND CDP.CDP_DTINI >= '" +Dtos(data1)+"' "
cQuery += " AND CDP.CDP_DTFIM <= '" +Dtos(data2)+"' "
cQuery += " AND CDP.CDP_TIPOIP = 'IP' "
cQuery += " AND CDP.D_E_L_E_T_ = ' ' "
cQuery += "	AND CDP.CDP_LINHA IN('016','017') "
cQuery += " AND CDP.CDP_SEQUEN  = (SELECT max(CDP1.CDP_SEQUEN) FROM " + RetSqlName("CDP") + " CDP1 "
cQuery += " WHERE CDP1.D_E_L_E_T_ = ' ' AND CDP1.CDP_TIPOIP = CDP.CDP_TIPOIP AND CDP1.CDP_FILIAL = CDP.CDP_FILIAL )
Memowrite("c:\temp\fPesqIPI.txt",CQuery)

If Select("cAl") > 0
	Dbselectarea("cAl")
	cAl->(DbClosearea())
EndIf

TCQuery cQuery new Alias "cAl"
cAl->(DbGoTop())
While !cAl->(Eof())
	If cAl->LINHA$"016"
		nValor := cAl->VALOR //* -1 RETIRADO o valor negativo por jeferson
		Exit
	Else
		nValor := cAl->VALOR
		Exit
	EndIf
	cAl->(dbSkip())
Enddo

Return nValor
//---------------------------------------------------------------------
/*/{Protheus.doc} fPesqPIS
Função para pesquisa da apuração do PIS

@author Jair  Matos
@since 09/10/2018
@version P12
@return nValor
/*/
//---------------------------------------------------------------------
Static Function	fPesqPIS(filcor,cTrib,data1,data2)
Local nValor :=0
Local cQuery := ""

cQuery += " SELECT 'CKR' TAB,CKR_NCREC+CKR_CREC VALOR FROM " + RetSqlName("CKR") + " CKR "
cQuery += " WHERE CKR.CKR_FILIAL = '" +filcor+"' "
cQuery += " AND CKR.CKR_PER BETWEEN '"+dtos(data1)+"' AND '"+dtos(data2)+"'"
cQuery += " AND CKR.CKR_TRIB = '" +cTrib+"' "
cQuery += " AND CKR.D_E_L_E_T_ = ' ' "
cQuery += " UNION "
cQuery += " SELECT 'CL8' TAB,CL8_CRDFUT VALOR FROM " + RetSqlName("CL8") + " CL8 "
cQuery += " WHERE CL8.CL8_FILIAL = '" +filcor+"' "
cQuery += " AND CL8.CL8_PER BETWEEN '"+dtos(data1)+"' AND '"+dtos(data2)+"'"
cQuery += " AND CL8.CL8_TRIB = '" +cTrib+"' "
cQuery += " AND CL8.CL8_CODBCC = '10' "
cQuery += " AND CL8.D_E_L_E_T_ = ' ' "
Memowrite("c:\temp\fPesqPIS.txt",CQuery)

If Select("cAl") > 0
	Dbselectarea("cAl")
	cAl->(DbClosearea())
EndIf

TCQuery cQuery new Alias "cAl"
cAl->(DbGoTop())
While !cAl->(Eof())
	If cAl->TAB =="CKR" .AND. cAl->VALOR >0
		//nValor := cAl->VALOR * -1 RETIRADO o valor negativo por jeferson
		nValor := cAl->VALOR
		Exit
	Else
		nValor := cAl->VALOR
		Exit
	EndIf
	cAl->(dbSkip())
Enddo

Return nValor
//---------------------------------------------------------------------
/*/{Protheus.doc} fPesqIRPJ
Função para pesquisa da apuração do IRPJ (Lucro Real ou Presumido)

@author Jair  Matos
@since 09/10/2018
@version P12
@return nValor
/*/
//---------------------------------------------------------------------
Static Function	fPesqIRPJ(filcor,cTrib,data1,data2)
Local nValor :=0
Local cQuery := ""

cQuery += " SELECT CWV_APAGAR IRPJ FROM " + RetSqlName("CWV") + " CWV "
cQuery += " JOIN " + RetSqlName("T0J") + " T0J ON CWV.CWV_IDTRIB = T0J.T0J_ID AND T0J_TPTRIB =  '" +cTrib+"' AND T0J.D_E_L_E_T_ = ' ' "
cQuery += " WHERE CWV.CWV_FILIAL = '" +filcor+"' "
cQuery += " AND CWV.CWV_INIPER >= '" +Dtos(data1)+"' "
cQuery += " AND CWV.CWV_FIMPER <= '" +Dtos(data2)+"' "
cQuery += " AND CWV.CWV_STATUS = '2' "
cQuery += " AND CWV.D_E_L_E_T_ = ' ' "

Memowrite("c:\temp\fPesqIRPJ.txt",CQuery)

If Select("cAl") > 0
	Dbselectarea("cAl")
	cAl->(DbClosearea())
EndIf

TCQuery cQuery new Alias "cAl"
cAl->(DbGoTop())
While !cAl->(Eof())
	If cAl->IRPJ >0
		nValor := (cAl->VALOR) //* -1RETIRADO o valor negativo por jeferson
		Exit
	EndIf
	cAl->(dbSkip())
Enddo

Return nValor
//---------------------------------------------------------------------
/*/{Protheus.doc} fPesqISS
Função para pesquisa da apuração do ISS

@author Jair  Matos
@since 09/10/2018
@version P12
@return nValor
/*/
//---------------------------------------------------------------------
Static Function	fPesqISS(filcor,data1,data2)
Local nValor :=0
Local cQuery := ""
cQuery += " SELECT E2_VALOR VALOR FROM " + RetSqlName("SE2") + " SE2 "
cQuery += " WHERE SE2.E2_FILIAL = '" +filcor+"' "
cQuery += " AND SE2.E2_EMISSAO BETWEEN '"+dtos(data1)+"' AND '"+dtos(data2)+"'"
cQuery += " AND SE2.E2_TIPO = 'TX' "
cQuery += " AND SE2.E2_NATUREZ = 'ISS' "
cQuery += " AND SE2.D_E_L_E_T_ = ' ' "

Memowrite("c:\temp\fPesqISS.txt",CQuery)

If Select("cAl") > 0
	Dbselectarea("cAl")
	cAl->(DbClosearea())
EndIf

TCQuery cQuery new Alias "cAl"
cAl->(DbGoTop())
While !cAl->(Eof())
	If cAl->VALOR > 0
		nValor := cAl->VALOR //* -1 RETIRADO o valor negativo por jeferson
		Exit
	EndIf
	cAl->(dbSkip())
Enddo

Return nValor
