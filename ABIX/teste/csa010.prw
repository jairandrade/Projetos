#INCLUDE "Protheus.ch"
#INCLUDE "CSA010.CH"  

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    � CSA010   � Autor � Eduardo Ju            � Data � 15.08.06   ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Relatorio de Aprovacao de Vagas (Quadro de Funcionario)      ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSA010(void)                                                 ���
���������������������������������������������������������������������������Ĵ��
���            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.            ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���Cecilia Car.�30/07/2014�TPZVV4�Incluido o fonte da 11 para a 12 e efetua-���
���            �          �      �da a limpeza.                             ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
User Function CSA010()

Local oReport
Local aArea := GetArea()

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("CS10AR",.F.)
oReport := ReportDef()
oReport:PrintDialog()	              

RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ReportDef() � Autor � Eduardo Ju          � Data � 15.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Definicao do Componente de Impressao do Relatorio           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local oSection1	
Local oSection2
Local oBreakFuncao
Local oBreakPer
Local oBreakCC
Local cAliasQry := GetNextAlias()
Local aOrd	  := {STR0004}  	//"Centro de Custo"

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������
oReport:=TReport():New("CSA010",STR0008,"CS10AR",{|oReport| PrintReport(oReport,cAliasQry)},STR0026,,,.F.)	// "Este Programa Emite Relatorio de Aprovacao de Vagas"
Pergunte("CS10AR",.F.)

//������������������������������������������������������������Ŀ
//� Criacao da Primeira Secao: "Quadro Funcionario Por Fun��o" �
//�������������������������������������������������������������� 
oSection1 := TRSection():New(oReport,STR0014,{"RBE"},aOrd,/*Campos do SX3*/,/*Campos do SIX*/)	//"Aprovacao de Vagas"
oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderBreak(.T.)   
TRCell():New(oSection1,"RBE_FILIAL","RBE")					//Filial 
TRCell():New(oSection1,"RBE_CC","RBE")						//Centro de Custo
TRCell():New(oSection1,"CTT_DESC01","CTT","")					//Descricao do Centro de Custo
TRCell():New(oSection1,"RBE_ANOMES","RBE")					//Ano/Mes

//����������������������������������������������Ŀ
//� Criacao da Segunda Secao: Aumento Programado �
//������������������������������������������������
oSection2 := TRSection():New(oSection1,STR0014 +" / " + STR0015,{"RBE","RBD"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)		//Aprovacao de Vagas / Quadro de Funcionario por Funcao
oSection2:SetTotalInLine(.F.)  
oSection2:SetHeaderBreak(.T.)
oSection2:SetLeftMargin(3)	//Identacao da Secao

TRCell():New(oSection2,"RBE_FUNCAO","RBE")				//Funcao
TRCell():New(oSection2,"RJ_DESC","SRJ","")				//Descricao da Funcao
TRCell():New(oSection2,"RBD_VLATUA","RBD",STR0016)		//Valor do Salario Atual
TRCell():New(oSection2,"RBD_VLPREV","RBD",STR0017)		//Valor do Salario Previsto
TRCell():New(oSection2,"RBE_VLAPRO","RBE") 				//Valor Aprovado
TRCell():New(oSection2,"RBD_QTATUA","RBD",STR0018)		//Nr. Funcionario Atual
TRCell():New(oSection2,"RBD_QTPREV","RBD",STR0019)		//Nr. Funcionario Previsto
TRCell():New(oSection2,"RBE_QTAPRO","RBE",STR0022)		//Nr. Funcionario Aprovado
TRCell():New(oSection2,"RBE_DTAPRO","RBE")				//Data da Aprovacao
TRCell():New(oSection2,"RBE_USUARI","RBE",STR0021)		//Nome do Usuario/Aprovador

Return oReport 

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 15.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do Relatorio                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function PrintReport(oReport,cAliasQry)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)  
Local cTitFun	 := ""
Local cTitCC	 := ""
Local cTitPer	 := ""
Local lQuery    := .F. 
Local cOrder	:= "" 
Local cSitQuery	:= ""

//�������������������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                                          �
//� mv_par01        //  Filial?                                                   �
//� mv_par02        //  Centro de Custo ?                                         �
//� mv_par03        //  Funcao ?                                                  �
//� mv_par04        //  Ano/Mes ?                                                 �
//� mv_par05        //  Imprime: 1-Analitico; 2-Sintetico?                        �
//� mv_par06        //  Totaliza Funcao ? 1-Sim; 2-Nao?                           �
//� mv_par07        //  Totaliza Periodo ? 1-Sim; 2-Nao?                          �
//��������������������������������������������������������������������������������� 

//����������������������������������������������Ŀ
//� Transforma parametros Range em expressao SQL �
//������������������������������������������������
MakeSqlExpr("CS10AR")    

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
lQuery := .T.         
	                                           
oReport:Section(1):BeginQuery()	

 	cOrder := "%RBE_FILIAL,RBE_CC%" 

BeginSql Alias cAliasQry	
	SELECT RBE_FILIAL,RBE_CC,CTT_DESC01,RBE_ANOMES,RBE_FUNCAO,RJ_DESC,RBD_VLATUA,RBD_VLPREV,RBE_VLAPRO,RBD_QTATUA,RBD_QTPREV,RBE_QTAPRO,RBE_DTAPRO,RBE_USUARI
	FROM 	%table:RBE% RBE 
	LEFT JOIN %table:CTT% CTT
		ON CTT_FILIAL = %xFilial:CTT%
		AND CTT_CUSTO = RBE_CC
		AND CTT.%NotDel%
	LEFT JOIN %table:SRJ% SRJ
		ON RJ_FILIAL = %xFilial:SRJ%
		AND RJ_FUNCAO = RBE_FUNCAO
		AND SRJ.%NotDel%
	LEFT JOIN %table:RBD% RBD
		ON RBD_FILIAL = %xFilial:RBD%
		AND RBD_CC = RBE_CC
		AND RBD_ANOMES = RBE_ANOMES
		AND RBD_FUNCAO = RBE_FUNCAO
		AND RBD.%NotDel%								
	WHERE RBE_FILIAL = %xFilial:RBE% AND
		RBE.%NotDel%   													
	ORDER BY %Exp:cOrder%                 				
EndSql

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�ExpA1 : Array com os parametros do tipo Range                           �
//��������������������������������������������������������������������������
oReport:Section(1):EndQuery({mv_par01,mv_par02,mv_par03,mv_par04})	/*Array com os parametros do tipo Range*/
	
//�������������������������Ŀ
//� Utiliza a query do Pai  �
//���������������������������
oSection2:SetParentQuery()                                

//�������������������������������������������Ŀ
//� Inicio da impressao do fluxo do relat�rio �
//���������������������������������������������     
oSection2:SetParentFilter({|cParam| (cAliasQry)->RBE_CC + (cAliasQry)->RBE_ANOMES == cParam},{|| (cAliasQry)->RBE_CC + (cAliasQry)->RBE_ANOMES})
oReport:SetMeter(RBE->(LastRec()))

//�������������������������������������������������������������Ŀ
//�Desabilita a impressao das celulas do Arquivo Secundario RBD �
//���������������������������������������������������������������
If mv_par05 <> 2 //Analitico
	oSection2:Cell("RBD_VLATUA"):Hide()
	oSection2:Cell("RBD_VLPREV"):Hide()
	oSection2:Cell("RBD_QTATUA"):Hide()
	oSection2:Cell("RBD_QTPREV"):Hide()
EndIf	

//������������������������Ŀ
//� Totalizacao por Funcao �
//��������������������������
If mv_par06 == 1 .And. mv_par05 <> 2
	
	oBreakFuncao := TRBreak():New(oSection2,oSection2:Cell("RBE_FUNCAO"),STR0023) // "Total por Fun��o" 
	oBreakFuncao:OnBreak({|x,y|cTitFun:=OemToAnsi(STR0023)+x}) 
    	oBreakFuncao:SetTotalText({||cTitFun})
                                                             
	TRFunction():New(oSection2:Cell("RBD_VLATUA"),/*cId*/,"SUM",oBreakFuncao,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("RBD_VLPREV"),/*cId*/,"SUM",oBreakFuncao,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("RBE_VLAPRO"),/*cId*/,"SUM",oBreakFuncao,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
	
	TRFunction():New(oSection2:Cell("RBD_QTATUA"),/*cId*/,"SUM",oBreakFuncao,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("RBD_QTPREV"),/*cId*/,"SUM",oBreakFuncao,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("RBE_QTAPRO"),/*cId*/,"SUM",oBreakFuncao,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

EndIf

//�������������������������Ŀ
//� Totalizacao por Periodo �
//���������������������������
If mv_par07 == 1 .And. mv_par05 <> 2 
	
	oBreakPer := TRBreak():New(oSection2,oSection1:Cell("RBE_ANOMES"),STR0024) // "Total por Periodo
	oBreakPer:OnBreak({|x,y|cTitPer:=OemToAnsi(STR0024)+x}) 
    	oBreakPer:SetTotalText({||cTitPer})
                                                                 
	TRFunction():New(oSection2:Cell("RBD_VLATUA"),/*cId*/,"SUM",oBreakPer,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("RBD_VLPREV"),/*cId*/,"SUM",oBreakPer,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("RBE_VLAPRO"),/*cId*/,"SUM",oBreakPer,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
	
	TRFunction():New(oSection2:Cell("RBD_QTATUA"),/*cId*/,"SUM",oBreakPer,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("RBD_QTPREV"),/*cId*/,"SUM",oBreakPer,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("RBE_QTAPRO"),/*cId*/,"SUM",oBreakPer,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)	

EndIf      

//������������������������Ŀ
//� Totalizacao por Funcao �
//��������������������������
If mv_par05 <> 2
	oBreakCC := TRBreak():New(oReport,oSection1:Cell("RBE_CC"),STR0025) // "Total por C.Custo" 
	oBreakCC:OnBreak({|x,y|cTitCC:=OemToAnsi(STR0025)+x}) 
    	oBreakCC:SetTotalText({||cTitCC})
	                                                             
	TRFunction():New(oSection2:Cell("RBD_VLATUA"),/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("RBD_VLPREV"),/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("RBE_VLAPRO"),/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("RBD_QTATUA"),/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("RBD_QTPREV"),/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("RBE_QTAPRO"),/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
EndIf

oSection1:Print() //Imprimir 	

Return Nil