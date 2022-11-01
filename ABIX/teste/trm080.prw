#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TRM080.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TRM080   � Autor � Eduardo Ju            � Data � 07/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Avaliacoes Realizadas                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TRM080                                                     ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�31/07/14�TPZWAO�AIncluido o fonte da 11 para a 12 e efetu-���
���            �        �      �da a limpeza.                             ���
���Isabel N.   �08/02/17�MRH-3233�Ajuste nos nomes dos campos RAI_RESULTA ���
���            �        �        �p/RAI_RESULT e RAI_QUESTAO p/RAI_QUESTA,���
���            �        �        �conforme cadastrados no Atusx.          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/  

User Function TRM080()

Local oReport
Local aArea := GetArea()

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
Pergunte("TR080R",.F.)
oReport := ReportDef()
oReport:PrintDialog()	

RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 07.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Definicao do Componente de Impressao do Relatorio           ���
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
Local oSection3
Local oSection4
Local oSection5
Local oSection6
Local oSection7
Local oSection8
Local oSection9
Local oSection10

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������
oReport:=TReport():New("TRM080",STR0003,"TR080R",{|oReport| PrintReport(oReport)},STR0001+" "+STR0002)	//"Avaliacoes Realizadas"#"Este programa tem como objetivo imprimir os testes realizados conforme parametros selecionados."
Pergunte("TR080R",.F.) 
                                             
//���������������������������������������Ŀ
//� Criacao da Primeira Secao: Calendario � 
//����������������������������������������� 
oSection1 := TRSection():New(oReport,STR0009 + " (" + STR0024 + ")",{"RAI"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//"Calendario"	
oSection1:SetTotalInLine(.F.)    
oSection1:SetHeaderBreak(.T.)

TRCell():New(oSection1,"RAI_CALEND","RAI")				//Calendario de Treinamento
TRCell():New(oSection1,"RA2_DESC","RA2","")			//Descricado do Calendario
TRCell():New(oSection1,"RAI_CURSO","RAI")				//Curso
TRCell():New(oSection1,"RA1_DESC","RA1","")			//Descricao do Curso  
TRCell():New(oSection1,"RA2_SINON","RA2",STR0018)		//Sinonimo do Curso
TRCell():New(oSection1,"RA9_DESCR","RA9","")			//Descricao do Sinonimo do Curso
TRCell():New(oSection1,"RAI_TURMA","RAI")				//Turma   

TRPosition():New(oSection1,"RA2",1,{|| xFilial("RA2",RAI->RAI_FILIAL)+ RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA})
TRPosition():New(oSection1,"RA1",1,{|| xFilial("RA1",RAI->RAI_FILIAL)+ RAI->RAI_CURSO})
TRPosition():New(oSection1,"RA9",2,{|| xFilial("RA9",RAI->RAI_FILIAL)+ RAI->RAI_CURSO})
TRPosition():New(oSection1,"RAI",1,{|| xFilial("RAI",RAI->RAI_FILIAL)+ RAI->RAI_CALEND + RAI->RAI_CURSO +RAI->RAI_TURMA +RAI->RAI_MAT+RAI->RAI_TESTE+RAI->RAI_QUESTA+RAI->RAI_ALTERN})

//����������������������������������������Ŀ
//� Criacao da Segunda Secao: Funcionario  �
//������������������������������������������ 
oSection2 := TRSection():New(oSection1,STR0020,{"RAI"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)		//Funcionario	
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderBreak(.T.)
oSection2:SetLeftMargin(1)	//Identacao da Secao  
  
TRCell():New(oSection2,"RAI_FILIAL","RAI")				//Filial do Funcionario    
TRCell():New(oSection2,"RAI_MAT","RAI")					//Matricula do Funcionario
TRCell():New(oSection2,"RA_NOME","SRA")					//Nome do Funcionario
TRCell():New(oSection2,"RAI_TESTE","RAI")				//Codigo da Avaliacao
TRCell():New(oSection2,"QQ_DESCRIC","SQQ","")			//Descricao da Avaliacao  

TRPosition():New(oSection2,"SRA",1,{|| xFilial("SRA",RAI->RAI_FILIAL)+ RAI->RAI_MAT})
TRPosition():New(oSection2,"SQQ",1,{|| xFilial("SQQ",RAI->RAI_FILIAL)+ Alltrim(RAI->RAI_TESTE)})

//����������������������������������������Ŀ
//� Criacao da Terceira Secao: Questoes    �
//������������������������������������������ 
oSection3:= TRSection():New(oSection2,STR0021,{"RAI"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//Questoes	
oSection3:SetTotalInLine(.F.)   
oSection3:SetHeaderBreak(.T.)
oSection3:SetLeftMargin(2)	//Identacao da Secao  

TRCell():New(oSection3,"RAI_QUESTA","RAI")				//Questao   
TRCell():New(oSection3,"RAI_ALTERN","RAI",,,,,{|| CHR(Val(RAI->RAI_ALTERN)+96)})	//Alternativa Selecionada   
TRCell():New(oSection3,"QP_PERCENT","SQP",STR0027,"@E 999.99",,,{|| SQP->QP_PERCENT}) //Percentual de cada alternativa da questao
TRCell():New(oSection3,"QO_PONTOS","SQO",STR0015,"@E 999.99",,,{|| SQO->QO_PONTOS * RAI->RAI_RESULT / 100 }) //Pontos de cada alternativa em rela��o aos pontos da questao (%)

TRPosition():New(oSection3,"SQO",1,{|| xFilial("SQO",RAI->RAI_FILIAL)+ RAI->RAI_QUESTA})

oSection3:SetTotalText({|| STR0012 }) //Total de Pontos 
TRFunction():New(oSection3:Cell("QO_PONTOS"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
 
//*** ANALITICO ***
//��������������������������������������Ŀ
//� Criacao da Quarta Secao: Calendario  � 
//���������������������������������������� 
oSection4 := TRSection():New(oReport,STR0009 + " (" + STR0025 + ")",{"RAI","RA2","RA1","RA9"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	
oSection4:SetTotalInLine(.F.) 
oSection4:SetHeaderBreak(.T.)

TRCell():New(oSection4,"RAI_CALEND","RAI")				//Calendario de Treinamento
TRCell():New(oSection4,"RA2_DESC","RA2","")			//Descricado do Calendario
TRCell():New(oSection4,"RAI_CURSO","RAI")				//Curso
TRCell():New(oSection4,"RA1_DESC","RA1","")			//Descricao do Curso  
TRCell():New(oSection4,"RA2_SINON","RA2",STR0018) 		//Sinonimo do Curso
TRCell():New(oSection4,"RA9_DESCR","RA9","")			//Descricao do Sinonimo do Curso
TRCell():New(oSection4,"RAI_TURMA","RAI")				//Turma        
TRPosition():New(oSection4,"RA2",1,{|| xFilial("RA2",RAI->RAI_FILIAL)+ RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA})
TRPosition():New(oSection4,"RA1",1,{|| xFilial("RA1",RAI->RAI_FILIAL)+ RAI->RAI_CURSO})
TRPosition():New(oSection4,"RA9",2,{|| xFilial("RA9",RAI->RAI_FILIAL)+ RAI->RAI_CURSO})

//���������������������������������������Ŀ
//� Criacao da Quinta Secao: Funcionario  �
//����������������������������������������� 
oSection5 := TRSection():New(oSection4,STR0020,{"RAI","SRA","SQQ"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	
oSection5:SetTotalInLine(.F.)  
oSection5:SetHeaderBreak(.T.)
oSection5:SetLeftMargin(1)	//Identacao da Secao  
oSection5:OnPrintLine({|| oReport:GetFunction("TOTAL1"):ResetSection(),oReport:GetFunction("TOTAL2"):ResetSection(),oReport:GetFunction("TOTAL3"):ResetSection(),.T.})

TRCell():New(oSection5,"RAI_FILIAL","RAI")				//Filial do Funcionario    
TRCell():New(oSection5,"RAI_MAT","RAI")					//Matricula do Funcionario
TRCell():New(oSection5,"RA_NOME","SRA")					//Nome do Funcionario
TRCell():New(oSection5,"RAI_TESTE","RAI")				//Codigo da Avaliacao
TRCell():New(oSection5,"QQ_DESCRIC","SQQ","")			//Descricao da Avaliacao  

TRPosition():New(oSection5,"SRA",1,{|| xFilial("SRA",RAI->RAI_FILIAL)+ RAI->RAI_MAT})
TRPosition():New(oSection5,"SQQ",1,{|| xFilial("SQQ",RAI->RAI_FILIAL)+ Alltrim(RAI->RAI_TESTE)})

//�������������������������������������Ŀ
//� Criacao da Sexta Secao: Questoes    �
//��������������������������������������� 
oSection6:= TRSection():New(oSection5,STR0021,{"RAI","SQO"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//Questoes	
oSection6:SetTotalInLine(.F.)   
oSection6:SetHeaderBreak(.T.)
oSection6:SetLeftMargin(2)	//Identacao da Secao  

TRCell():New(oSection6,"RAI_QUESTA","RAI")			//Questao     
TRCell():New(oSection6,"QO_QUEST","SQO","",,110)	//Descricao da Questao
TRCell():New(oSection6,"QO_DMEMO","SQO","",,,,{|| MSMM(SQO->QO_QUEST,,,,3)})		//Descricao da Questao (Memo)

TRPosition():New(oSection6,"SQO",1,{|| xFilial("SQO",RAI->RAI_FILIAL)+ RAI->RAI_QUESTA})

//������������������������������������������������������Ŀ
//� Criacao da Setima Secao: Resposta das Questoes (Pai) �
//�������������������������������������������������������� 
oSection7 := TRSection():New(oSection6,STR0022,{"RAI"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)		//Respostas
oSection7:SetTotalInLine(.F.)
oSection7:SetHeaderBreak(.T.)
oSection7:SetLeftMargin(3)	//Identacao da Secao    

//����������������������������������������������������������Ŀ
//� Criacao da Oitava Secao: Resposta Dissertativa (Filha 1) �
//������������������������������������������������������������
oSection8 := TRSection():New(oSection7,STR0023,{"RAI","SQO"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//"Resposta Dissertativa"	
oSection8:SetHeaderBreak(.T.)
oSection8:SetLeftMargin(3)	//Identacao da Secao  

TRCell():New(oSection8,"RAI_ALTERN","RAI",,,,,{|| CHR(Val(RAI->RAI_ALTERN)+96)})	//Alternativa Selecionada   
TRCell():New(oSection8,"RAI_MRESPO","RAI")	//Resposta da Questao
TRCell():New(oSection8,"RAI_MEMO1","RAI",Alltrim(STR0016),,150,,{|| MSMM(RAI->RAI_MRESPO,,,,3)})		//Descricao Resposta da Questao (Memo)
TRCell():New(oSection8,"QP_PERCENT","SQP",STR0027,"@E 999.99",,,{|| SQP->QP_PERCENT}) //Percentual de cada alternativa da questao
TRCell():New(oSection8,"QO_PONTOS","SQO",STR0015,"@E 999.99",6,,{|| SQO->QO_PONTOS * RAI->RAI_RESULT / 100 }) //Pontos de cada alternativa da questao


oObj := TRFunction():New(oSection8:Cell("QO_PONTOS"),"TOTAL1", "SUM",,,,,.F.,	.T.,.F.,,)
oObj:Disable()     

TRPosition():New(oSection8,"SQO",1,{|| xFilial("SQO",RAI->RAI_FILIAL)+ RAI->RAI_QUESTA})

//Nao imprime cod campo memo
oSection8:Cell("RAI_ALTERN"):Disable()  
oSection8:Cell("RAI_MRESPO"):Disable() 

//���������������������������������������������������������������Ŀ
//� Criacao da Nona Secao: Resposta por Selecao (Filha 2A) - RBL  �
//�����������������������������������������������������������������
oSection9 := TRSection():New(oSection7,STR0014 + " - " + STR0026,{"RBL", "SQO"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//Alternativas
oSection9:SetHeaderBreak(.T.)
oSection9:SetLeftMargin(3)	//Identacao da Secao  
	
TRCell():New(oSection9,"ALTSEL","   ","",,3,,{|| If ( RAI->RAI_ALTERN == RBL->RBL_ITEM,"(X)","( )" ) }) //Alternativa respondida
TRCell():New(oSection9,"RBL_ITEM","RBL",,,,,{|| CHR(Val(RBL->RBL_ITEM)+96)})	//Alternativa Selecionada 
TRCell():New(oSection9,"RBL_DESCRI","RBL",STR0014,,141)	//Alternativas
TRCell():New(oSection9,"QP_PERCENT","SQP",STR0027,"@E 999.99",,,{|| SQP->QP_PERCENT}) //Percentual de cada alternativa da questao
TRCell():New(oSection9,"QO_PONTOS","SQO",STR0015,"@E 999.99",6,,{|| If ( RAI->RAI_ALTERN == RBL->RBL_ITEM, SQO->QO_PONTOS * RAI->RAI_RESULT / 100, 0) }) //Pontos de cada alternativa da questao (%)


oObj := TRFunction():New(oSection9:Cell("QO_PONTOS"),"TOTAL2", "SUM",,,,,.F.,.T.,.F.,,)
oObj:Disable()

TRPosition():New(oSection9,"SQO",1,{|| xFilial("SQO",RAI->RAI_FILIAL)+ RAI->RAI_QUESTA})

//����������������������������������������������������������������Ŀ
//� Criacao da Decima Secao: Resposta por Selecao (Filha 2B) - SQP �
//������������������������������������������������������������������
oSection10 := TRSection():New(oSection7,STR0014,{"SQP", "SQO"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)		//Alternativas
oSection10:SetHeaderBreak(.T.)
oSection10:SetLeftMargin(3)	//Identacao da Secao  

TRCell():New(oSection10,"ALTSEL","   ","",,3,,{|| If ( RAI->RAI_ALTERN == SQP->QP_ALTERNA,"(X)","( )" ) }) //Alternativa respondida		
TRCell():New(oSection10,"QP_ALTERNA","SQP","",,,,{|| CHR(Val(SQP->QP_ALTERNA)+96)})	//Alternativa Selecionada 
TRCell():New(oSection10,"QP_DESCRIC","SQP",STR0014,,141)	//Alternativas
TRCell():New(oSection10,"QP_PERCENT","SQP",STR0027,"@E 999.99",,,{|| SQP->QP_PERCENT}) //Percentual de cada alternativa da questao 
TRCell():New(oSection10,"QO_PONTOS","SQO", STR0015,"@E 999.99",6,,{|| If ( RAI->RAI_ALTERN == SQP->QP_ALTERNA, SQO->QO_PONTOS * RAI->RAI_RESULT / 100,0) }) //Pontos de cada alternativa da questao (%)


oObj := TRFunction():New(oSection10:Cell("QO_PONTOS"),"TOTAL3","SUM",,,,,.F.,.F.,.F.,,)
oObj:Disable()

oSection5:SetTotalText({|| STR0012 })  //"Total de Pontos"
TRFunction():New(oSection10:Cell("QO_PONTOS"),"TOTAL3","ONPRINT",,,,{|| oReport:GetFunction("TOTAL1"):SectionValue()+oReport:GetFunction("TOTAL2"):SectionValue()+oReport:GetFunction("TOTAL3"):SectionValue()},.T.,.F.,.F.,oSection5,)

Return oReport   

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 07.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do Relatorio                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function PrintReport(oReport)

Local oSection1 := If ( MV_PAR10 = 1,(If(MV_PAR11 = 1, oReport:Section(2), oReport:Section(1))),oReport:Section(1) )
Local oSection2 := oSection1:Section(1) 
Local oSection3 := oSection2:Section(1)
Local oSection4 := oSection3:Section(1)
Local cFiltro 	:= ""

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� MV_PAR01        //  Filial                                   � 
//� MV_PAR02        //  Calendario                               � 
//� MV_PAR03        //  Curso                                    � 
//� MV_PAR04        //  Turma                                    � 
//� MV_PAR05        //  Matricula                                � 
//� MV_PAR06        //  Teste               					 � 
//� MV_PAR07        //  Nota De                                  � 
//� MV_PAR08        //  Nota Ate                                 � 
//� MV_PAR09        //  Tipo Avaliacao                           � 
//� MV_PAR10        //  Relatorio: Analitico / Sintetico         �
//� MV_PAR11        //  Imp.Todas Alternat.: Sim / Nao           �
//����������������������������������������������������������������
//������������������������������������������������������Ŀ
//� Transforma parametros Range em expressao (intervalo) �
//��������������������������������������������������������
MakeAdvplExpr("TR080R")	                                  

If !Empty(MV_PAR01)
	cFiltro:= MV_PAR01 
EndIf  
	
If !Empty(MV_PAR02)
	cFiltro += IIF(!Empty(cFiltro)," .And. ","")
	cFiltro += MV_PAR02 
EndIf  
	
If !Empty(MV_PAR03)
	cFiltro += IIF(!Empty(cFiltro)," .And. ","")
	cFiltro += MV_PAR03
EndIf  
	
If !Empty(MV_PAR04)
	cFiltro += IIF(!Empty(cFiltro)," .And. ","")
	cFiltro += MV_PAR04 
EndIf  	       
	
If !Empty(MV_PAR05)
	cFiltro += IIF(!Empty(cFiltro)," .And. ","") 
	cFiltro += MV_PAR05
EndIf   

If !Empty(MV_PAR06)
	cFiltro += IIF(!Empty(cFiltro)," .And. ","") 
	cFiltro += MV_PAR06 
EndIf  

If !Empty(MV_PAR09)
	cFiltro += IIF(!Empty(cFiltro)," .And. ","")
	cFiltro += MV_PAR09
EndIf  
	
oSection1:SetFilter(cFiltro)
	       
//���������������������������Ŀ
//� Condicao para Impressao   �
//�����������������������������
oSection2:SetParentFilter({|cParam| RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA == cParam},{|| RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA})
oSection3:SetParentFilter({|cParam| RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_MAT+RAI->RAI_TESTE == cParam},{|| RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_MAT+RAI->RAI_TESTE})

If MV_PAR10 == 1 .And. MV_PAR11 == 1	//Imprime Analitico e Todas as alternativas

	oSection4:SetParentFilter({|cParam| RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_MAT+RAI->RAI_TESTE+RAI->RAI_QUESTA == cParam},{|| RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_MAT+RAI->RAI_TESTE+RAI->RAI_QUESTA})
	oSection4:SetLineCondition({|| fCondResp(oSection3, oSection4) })	
EndIf 
             
If MV_PAR10 = 2 
	oSection3:Hide()
EndIf

oReport:SetMeter(RAI->(LastRec()))	
oSection1:Print() //Imprimir 

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fCondResp() � Autor � Eduardo Ju          � Data � 07.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Impressao da Resposta                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function fCondResp(oSection3,oSection4)
	
	//Tipo de Resposta
	If RAI->RAI_ALTERN == "00" .Or. Empty(RAI->RAI_ALTERN)	//Dissertativa 
		oSection4:Section(1):Enable()
		oSection4:Section(2):Disable()	//RBL
		oSection4:Section(3):Disable() //SQP
			
		oSection3:Cell("QO_QUEST"):SetLineBreak() //Impressao de campo Memo
		oSection3:Cell("QO_DMEMO"):SetLineBreak() //Impressao de campo Memo
	
		oSection4:Section(1):Cell("RAI_MEMO1"):SetLineBreak() //Impressao de campo Memo   	
		oSection4:Section(1):SetParentFilter({|cParam| RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_MAT+RAI->RAI_TESTE+RAI->RAI_QUESTA == cParam},{|| RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_MAT+RAI->RAI_TESTE+RAI->RAI_QUESTA})
	
	Else //Alternativa	
		oSection4:Section(1):Disable()	//Dissertativa
	
		If RBL->( dbSeek( xFilial("RBL", RAI->RAI_FILIAL) + SQO->QO_ESCALA ) )
			
			oSection4:Section(2):Enable()
			oSection4:Section(3):Disable()
			oSection4:Section(2):SetRelation({|| xFilial("RBL", RAI->RAI_FILIAL) + SQO->QO_ESCALA }, "RBL",1,.T.)
			oSection4:Section(2):SetParentFilter({|cParam| RBL->RBL_FILIAL + RBL->RBL_ESCALA == cParam},{|| xFilial("RBL",RAI->RAI_FILIAL) + SQO->QO_ESCALA})
	
		ElseIf SQP->(dbSeek( xFilial("SQP", RAI->RAI_FILIAL) + RAI->RAI_QUESTA ) )
		
			oSection4:Section(2):Disable()
			oSection4:Section(3):Enable()
			oSection4:Section(3):SetRelation({|| xFilial("SQP", RAI->RAI_FILIAL) + RAI->RAI_QUESTA}, "SQP",1,.T.)
			oSection4:Section(3):SetParentFilter({|cParam| SQP->QP_FILIAL + SQP->QP_QUESTAO == cParam}, {|| xFilial("SQP", RAI->RAI_FILIAL) + RAI->RAI_QUESTA})		
								
		EndIf		
		
	EndIf	

Return .T.
