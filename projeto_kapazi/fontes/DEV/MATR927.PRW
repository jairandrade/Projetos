#INCLUDE "MATR927.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATR927   �Autor  �Mary C. Hergert     � Data � 28/09/2004  ���
�������������������������������������������������������������������������͹��
���Desc.     �Relatorio de PIS/COFINS com base na apropriacao de ativo    ���
���          �imobilizado.                                                ���
�������������������������������������������������������������������������͹��
���Uso       �Sigafis                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Matr927  
   
Local aArea		:= GetArea()
Local Titulo    := OemToAnsi(STR0014)  	// "Cr�dito de PIS/COFINS na Deprecia��o do Ativo Imobilizado"
Local cDesc1    := OemToAnsi(STR0002) 	// "Este programa ira emitir o relatorio de credito de PIS/COFINS"
Local cDesc2    := OemToAnsi(STR0003)  	// "com base nas depreciacoes do Ativo Imobilizado"
Local cDesc3    := OemToAnsi(STR0004)  	// "e parametros informados pelo usuario"
Local lDic    	:= .F. 					// Habilita/Desabilita Dicionario
Local lComp    	:= .F. 					// Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro  	:= .F. 					// Habilita/Desabilita o Filtro
Local wnrel     := "MATR927"  			// Nome do Arquivo utilizado no Spool
Local nomeprog  := "MATR927"  			// nome do programa
Local cString	:= "SN1"
Local aFilsCalc	:= {} 
Local lconsolida:=.F.

Private Tamanho := "M"					// P/M/G
Private Limite  := 132 					// 80/132/220
Private cPerg   := "MTR927"				// Pergunta do Relatorio
Private aReturn := {STR0005,1,STR0006,1,2,1,"",1}	//"Zebrado"###"Administracao"

Private lEnd    := .F.					// Controle de cancelamento do relatorio
Private m_pag   := 1  					// Contador de Paginas
Private nLastKey:= 0  					// Controla o cancelamento da SetPrint e SetDefault

//����������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                     �
//� mv_par01            // Data Inicial de aquisicao   		 �
//� mv_par02            // Data Final de aquisicao           �
//� mv_par03            // Codigo Ativo Inicial              �
//� mv_par04            // Codigo Ativo Final                �
//� mv_par05            // Data Inicial para impressao 		 �
//� mv_par06            // Data Final para impressao         �
//� mv_par07            // Seleciona Filiais                 �
//� mv_par08            // Tipo de Bens                      �
//������������������������������������������������������������

//���������������������������Ŀ
//�Ajusta o grupo de perguntas�
//�����������������������������
Pergunte(cPerg,.F.)

//������������������������������������������������������������������������Ŀ
//�Envia para a SetPrint                                                   �
//��������������������������������������������������������������������������
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,"",lComp,Tamanho,lFiltro,.F.)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif

lConsolida := (MV_PAR07 == 1 .and. MV_PAR10 == 1)

#IFDEF TOP
	aFilsCalc := MatFilCalc( MV_PAR07 == 1, , , lConsolida, , 3 )
#ELSE
	aFilsCalc := MatFilCalc( MV_PAR07 == 1 )
#ENDIF
If Empty( aFilsCalc )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	dbClearFilter()
	Return
Endif 

//���������������������������������������������Ŀ
//�Checa a existencia dos parametros necessarios�
//�����������������������������������������������
If GetNewPar("MV_TXPIS",0) == 0
	MsgStop(OemToAnsi(STR0009) + Chr(13) + Chr(10) + OemToAnsi(STR0010),OemToAnsi(STR0011))
	// "Parametro MV_TXPIS (aliquota de PIS) nao cadastrado." "Verifique o cadastro para a correta geracao do relatorio." "Parametro MV_TXPIS"
Endif
If GetNewPar("MV_TXCOFIN",0) == 0
	MsgStop(OemToAnsi(STR0012) + Chr(13) + Chr(10) + OemToAnsi(STR0010),OemToAnsi(STR0013))
	// "Parametro MV_TXCOFIN (aliquota de COFINS) nao cadastrado." "Verifique o cadastro para a correta geracao do relatorio." "Parametro MV_TXCOFIN"
Endif
 

//�������������������Ŀ
//�Imprime o relatorio�
//���������������������
RptStatus({|lEnd| ImpDet(@lEnd,wnRel,cString,nomeprog,Titulo,aFilsCalc)},Titulo)

dbSelectArea(cString)
dbClearFilter()
Set Device To Screen
Set Printer To

If (aReturn[5] = 1)
	dbCommitAll()
	OurSpool(wnrel)
Endif 
MS_FLUSH()

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpDet    �Autor  �Mary C. Hergert     � Data � 28/09/2004  ���
�������������������������������������������������������������������������͹��
���Desc.     �Imprime o detalhe do relatorio                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Matr927                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ImpDet( lEnd, wnRel, cString,nomeprog, Titulo, aFilsCalc )

Local lHouveMov	:= .F.

Local cBem		:= ""
Local cItem		:= ""   
Local cCabec1 	:= ""
Local cCabec2 	:= ""          

Local nMvTxPis	:= SuperGetMv("MV_TXPIS")
Local nMvTxCof	:= SuperGetMv("MV_TXCOFIN")
Local cMvAPCR927:= SuperGetMv("MV_APCR927",.F.,"3")    
Local nAliqPis	:= 0
Local nALiqCof 	:= 0 

Local aLay	    := RetLayOut()
Local aDetail	:= {}
Local aTemp		:= {}
Local aProcItem	:= {}
Local lNovoBem	:= .T.

Local nLinha     := 80
Local nTotPis    := 0
Local nTotCof    := 0
Local nTotBase   := 0
Local nGTotPis   := 0
Local nGTotCof   := 0
Local nGTotBase  := 0
Local nValPis    := 0
Local nValCof    := 0
Local nBase      := 0 
Local aNome		 := {"PIS E COFINS CALCULADOS COM BASE NO VALOR DA DEPRECIA��O","PIS E COFINS CALCULADOS COM BASE NO VALOR DA AQUISI��O"}
Local aTipExc	:= IIf (!Empty(MV_PAR08) .And. Type(MV_PAR08)== "A",&(MV_PAR08),{})
Local lAquisicao:= IIf((MV_PAR09) == 1,.T.,.F.) //PARA ESTABELECER DLIMITE --> .T. = DATA DE AQUISICAO / .F. = Considera DATA INICIO DEPRECIACAO (PADRAO)

// Variaveis de controle de multiplas filiais
Local cFilBack   := cFilAnt
Local nForFilial := 0 
Local nVlrApro	 := -1
Local lVlrApro	:= .T. 
Local cChave	:= ""
Local cChaveN1	:= ""
Local nValori	:= 0
Local nMescPis	:= 0  
Local dDtbxN3   := CToD ("//")

#IFDEF TOP
	Local lFirstFil	:= .T.
#ENDIF

For nForFilial := 1 to Len( aFilsCalc )

	If aFilsCalc[nForFilial][1]

		cFilAnt   := aFilsCalc[nForFilial][2] 
		#IFDEF TOP		
			If lFirstFil .or. MV_PAR10 == 2
		#ENDIF
        nLinha    := 80  // faz a quebra de pagina por filial 
       	titulo	:= STR0014 + Space(01) + STR0019 + cFilAnt //"Cr�dito de PIS/COFINS na Deprecia��o do Ativo Imobilizado" + " - Filial "
        lHouveMov := .F. 
		#IFDEF TOP
				lFirstFil	:= .F.
			EndIf
		#ENDIF
        
		//����������������������������������������������������������������Ŀ
		//�Carregando o array com os parametros para processamento por item�
		//������������������������������������������������������������������
		aAdd(aProcItem,mv_par03)
		aAdd(aProcItem,mv_par04)
		aAdd(aProcItem,mv_par01)
		aAdd(aProcItem,mv_par02)
		aAdd(aProcItem,"ATI")
		
		//����������������������������������������������Ŀ
		//�Quando o movimento e referente a apenas um mes�
		//������������������������������������������������
		#IFDEF TOP
			aTemp := _DeprecAtivo(mv_par05,mv_par06,.T.,.F.,aProcItem,.T.,,"10",,,aTipExc,,lAquisicao, IIf( (MV_PAR07 == 1 .AND. MV_PAR10 == 1) , aFilsCalc, NIL )  )
		#ELSE
			aTemp := _DeprecAtivo(mv_par05,mv_par06,.T.,.F.,aProcItem,.T.,,"10",,,aTipExc,,lAquisicao)	
		#ENDIF	
		//������������������������������������������������������
		//�Imprime as informacoes contidas na tabela temporaria�
		//������������������������������������������������������
		dbSelectArea("ATI")
		ATI->(dbSetOrder(1))
		ATI->(dbGoTop())
		SetRegua(ATI->(LastRec()))
		
		While ! ATI->(Eof())
		
			If ATI->BASE > 0   // Calculado por fra��o ser� exibido na segunda parte do relat�rio
				ATI->( DbSkip() )
				Loop
			EndIf   		
		
		    IncRegua()
		
			If Interrupcao(@lEnd)
			    Exit
		 	Endif
		
			Mtr927Cabec(@nLinha,Titulo,cCabec1,cCabec2,nomeprog,aNome[1])
			
			//���������������������������������������������Ŀ
			//�Quando mudar o bem, reinicia os totalizadores�
			//�����������������������������������������������
			If (cBem <> ATI->BEM .Or. cItem <> ATI->ITEM)
				// Totaliza o bem                      
				If lHouveMov
					FmtLin({},aLay[05],,,@nLinha)
			    	aDetail := {Transform(nTotBase,"@e 99,999,999,999.99"),;
								Transform(nTotPis,"@e 99,999,999,999.99"),;
								Transform(nTotCof,"@e 99,999,999,999.99")}				
					FmtLin(aDetail,aLay[06],,,@nLinha)
					FmtLin({},aLay[07],,,@nLinha)
				Endif
				lNovoBem 	:= .T.
				nTotPis 	:= 0
				nTotCof 	:= 0                         
				nTotBase	:= 0          
				cItem		:= ATI->ITEM
				cBem		:= ATI->BEM                         
				cDescr		:= Alltrim(ATI->BEM) + " - " + Alltrim(ATI->ITEM) + " - " + Left(Alltrim(Upper(ATI->DESCRI)),34)
			Endif
		
		    lHouveMov := .T.    
		    
		    //������������������������������������������������������������������������������Ŀ  
			//�19/10/2012 - FNC 00000025086/2012 - CHAMADO: TFWLHK                           �   		    
			//�Para considerar qual aliquota utilizar. Verifica parametro MV_APCR927         �   
			//� '1' - CONSIDERA DO CADASTRO DO BEM/MOVIMENTO -> ATI->ALIQPIS/ATI->ALIQCOFINS �   
			//� '2' - CONSIDERA DOS PARAMETROS MV_TXPIS / MV_TXCOFIN	                     �     
			//� '3' - * DEFAULT * - VERIFICA OS CAMPOS DA ATI. SE = ZERO, CONSID. PARAMETROS �
			//�������������������������������������������������������������������������������� 
			If cMvAPCR927$"1" 
				nAliqPis := ATI->ALIQPIS 
				nAliqCof := ATI->ALIQCOFINS
			ElseIf cMvAPCR927$"2"    
				nAliqPis := nMvTxPis // MV_TXPIS 
				nAliqCof := nMvTxCof // MV_TXCOFIN
			Else
			    nAliqPis := IIf(ATI->ALIQPIS>0,ATI->ALIQPIS,nMvTxPis)  
			    nAliqCof := Iif(ATI->ALIQCOFINS>0,ATI->ALIQCOFINS,nMvTxCof)      
			EndIf
		    
			// Calcula os valores de credito de PIS/COFINS
				nValPis	:= ATI->VRET * nAliqPis / 100
				nValCof	:= ATI->VRET * nAliqCof / 100
				nBase	:= ATI->VRET
	   	   		If lVlrApro     
	   	   			dbSelectArea("SN3") 
					dbSetOrder(1)
					cChave := xFilial("SN3")+ATI->BEM+ATI->ITEM
					dbSeek(cChave)
					While !Eof() .And. cChave = SN3->N3_FILIAL+SN3->N3_CBASE+SN3->N3_ITEM
					
						If Val(SN3->N3_BAIXA) == 0							
							dbSkip()
							Loop
						Endif 
						nValori := SN3->N3_VORIG1
						dDtbxN3 := SN3->N3_DTBAIXA  
						SN3->( dbSkip() )
					EndDo
		   	   		
		   	   		nVlrApro+= 1
			
					dbSelectArea("SN1")
					dbSetOrder(1)
					cChaveN1 := xFilial("SN1")+ATI->BEM+ATI->ITEM
					dbSeek(cChaveN1)     
					If ("SN1")->(dbSeek(cChaveN1))
						nMescPis := SN1->N1_MESCPIS		
					EndIf
						   	   		
		   	   	EndIf
	   	   		
			If lNovoBem == .T.
				lNovoBem := .F.
			    aDetail := {PadR(Alltrim(cDescr),59),;
			    			StrZero(Month(ATI->DTAPR),2),;
			    			StrZero(Year(ATI->DTAPR),4),;
			    			PadL(Alltrim(Transform(nBase,"@e 99,999,999,999.99")),14),;
							Transform(NAliqPis,"@e 99.99"),;
							Transform(nValPis,"@e 999,999.99"),;
							Transform(NAliqCof,"@e 99.99"),;							
							Transform(nValCof,"@e 999,999.99")}							
			Else                                    									
			
		   	  	If ATI->DTAPR > dDtbxN3	  		   			                                    
		   			//verifica a quantidade de apropria��es		   				 
			        nBase := (nValori)/(nMescPis - nVlrApro)                              
			        lVlrApro := .F.
			        //Em caso da base ficar zerada os campos de valor e aliquota devem estar zerados.
			        If nBase == 0
			        	NAliqPis 	:= 0
			        	nValPis 	:= 0
			        	NAliqCof	:= 0
			        	nValCof		:= 0
			        EndIf 
				EndIf  
			     
			    
			    aDetail := {"",;
			    			StrZero(Month(ATI->DTAPR),2),;
			    			StrZero(Year(ATI->DTAPR),4),;
							PadL(Alltrim(Transform(nBase,"@e 99,999,999,999.99")),14),;       
							Transform(NAliqPis,"@e 99.99"),;
							Transform(nValPis,"@e 999,999.99"),;
							Transform(NAliqCof,"@e 99.99"),;							
							Transform(nValCof,"@e 999,999.99")}				
			Endif
							
			FmtLin(aDetail,aLay[04],,,@nLinha)
		
			//������������������������������������������������������������������������Ŀ
			//�Acumula total                                                           �
			//��������������������������������������������������������������������������
			nTotPis  += nValPis
			nTotCof  += nValCof
			nTotBase += nBase
		    
			//������������������������������������������������������������������������Ŀ
			//�Acumula total Geral                                                     �
			//��������������������������������������������������������������������������
			nGTotPis  += nValPis
			nGTotCof  += nValCof
			nGTotBase += nBase
		
		    ATI->(dbSkip())  
				  
		EndDo	
		
		//������������������������������������������������������������������������Ŀ
		//�Imprime total                                                           �
		//��������������������������������������������������������������������������
		If lHouveMov                          
		
			If nLinha > 60
				lHouveMov := .F.
			Endif
			
			Mtr927Cabec(@nLinha,Titulo,cCabec1,cCabec2,nomeprog,aNome[1])
			
			If lHouveMov 
				FmtLin({},aLay[05],,,@nLinha)
			Endif
		
			// Total do ultimo bem impresso
		   	aDetail := {Transform(nTotBase,"@e 99,999,999,999.99"),;
						Transform(nTotPis,"@e 99,999,999,999.99"),;
						Transform(nTotCof,"@e 99,999,999,999.99")}				
			FmtLin(aDetail,aLay[06],,,@nLinha)
			FmtLin({},aLay[07],,,@nLinha)
			
			// Total Geral
		   	aDetail := {Transform(nGTotBase,"@e 99,999,999,999.99"),;
						Transform(nGTotPis,"@e 99,999,999,999.99"),;
						Transform(nGTotCof,"@e 99,999,999,999.99")}				
			FmtLin(aDetail,aLay[08],,,@nLinha)
			FmtLin({},aLay[09],,,@nLinha)
		Endif
			
		//�����������������������������������������������������Ŀ
		//�Reinicia os totalizadores para exibir a segunda parte�
		//�������������������������������������������������������	
		//caio
		nGTotPis  := 0
		nGTotCof  := 0
		nGTotBase := 0
		lHouveMov := .F.
		cBem		:= ""  
		cItem		:= ""
		
		nLinha := 80
	   //	Mtr927Cabec(@nLinha,Titulo,cCabec1,cCabec2,nomeprog,aNome[2])
		
		ATI->(DbGoTop())
		While ! ATI->(Eof())
		    
	 		If ATI->BASE == 0   // Calculado por deprecia��o j� foi exibido na primeira parte do relat�rio
				ATI->( DbSkip() )
				Loop
			EndIf 
		
		    IncRegua()
		
			If Interrupcao(@lEnd)
			    Exit
		 	Endif
		
			Mtr927Cabec(@nLinha,Titulo,cCabec1,cCabec2,nomeprog,aNome[2])
			
			//���������������������������������������������Ŀ
			//�Quando mudar o bem, reinicia os totalizadores�
			//�����������������������������������������������
			If (cBem <> ATI->BEM .Or. cItem <> ATI->ITEM)
				// Totaliza o bem                      
				If lHouveMov
					FmtLin({},aLay[05],,,@nLinha)
			    	aDetail := {Transform(nTotBase,"@e 99,999,999,999.99"),;
								Transform(nTotPis,"@e 99,999,999,999.99"),;
								Transform(nTotCof,"@e 99,999,999,999.99")}				
					FmtLin(aDetail,aLay[06],,,@nLinha)
					FmtLin({},aLay[07],,,@nLinha)
				Endif
				lNovoBem 	:= .T.
				nTotPis 	:= 0
				nTotCof 	:= 0                         
				nTotBase	:= 0          
				cItem		:= ATI->ITEM
				cBem		:= ATI->BEM                         
				cDescr		:= Alltrim(ATI->BEM) + " - " + Alltrim(ATI->ITEM) + " - " + Left(Alltrim(Upper(ATI->DESCRI)),34)
			Endif
		
		    lHouveMov := .T. 
		    
		    //������������������������������������������������������������������������������Ŀ  
			//�19/10/2012 - FNC 00000025086/2012 - CHAMADO: TFWLHK                           �   		    
			//�Para considerar qual aliquota utilizar. Verifica parametro MV_APCR927         �   
			//� '1' - CONSIDERA DO CADASTRO DO BEM/MOVIMENTO -> ATI->ALIQPIS/ATI->ALIQCOFINS �   
			//� '2' - CONSIDERA DOS PARAMETROS MV_TXPIS / MV_TXCOFIN	                     �     
			//� '3' - * DEFAULT * - VERIFICA OS CAMPOS DA ATI. SE = ZERO, CONSID. PARAMETROS �
			//�������������������������������������������������������������������������������� 
			If cMvAPCR927$"1" 
				nAliqPis := ATI->ALIQPIS 
				nAliqCof := ATI->ALIQCOFINS
			ElseIf cMvAPCR927$"2"    
				nAliqPis := nMvTxPis // MV_TXPIS 
				nAliqCof := nMvTxCof // MV_TXCOFIN
			Else
			    nAliqPis := IIf(ATI->ALIQPIS>0,ATI->ALIQPIS,nMvTxPis)  
			    nAliqCof := Iif(ATI->ALIQCOFINS>0,ATI->ALIQCOFINS,nMvTxCof)      
			EndIf
			
		    
			// Calcula os valores de credito de PIS/COFINS
			nValPis	:= ATI->BASE * nAliqPis / 100
			nValCof	:= ATI->BASE * nAliqCof / 100
			nBase	:= ATI->BASE
			
			If lNovoBem == .T.
				lNovoBem := .F.
			    aDetail := {PadR(Alltrim(cDescr), 59),;
			    			StrZero(Month(ATI->DTAPR),2),;
			    			StrZero(Year(ATI->DTAPR),4),;
							PadL(Alltrim(Transform(nBase,"@e 99,999,999,999.99")),14),;
							Transform(NAliqPis,"@e 99.99"),;
							Transform(nValPis,"@e 999,999.99"),;
							Transform(NAliqCof,"@e 99.99"),;							
							Transform(nValCof,"@e 999,999.99")}					
			Else
			    aDetail := {"",;
			    			StrZero(Month(ATI->DTAPR),2),;
			    			StrZero(Year(ATI->DTAPR),4),;
							PadL(Alltrim(Transform(nBase,"@e 99,999,999,999.99")),14),;
							Transform(NAliqPis,"@e 99.99"),;
							Transform(nValPis,"@e 999,999.99"),;
							Transform(NAliqCof,"@e 99.99"),;							
							Transform(nValCof,"@e 999,999.99")}					
			Endif
							
			FmtLin(aDetail,aLay[04],,,@nLinha)
		
			//������������������������������������������������������������������������Ŀ
			//�Acumula total                                                           �
			//��������������������������������������������������������������������������
			nTotPis  += nValPis
			nTotCof  += nValCof
			nTotBase += nBase
		    
			//������������������������������������������������������������������������Ŀ
			//�Acumula total Geral                                                     �
			//��������������������������������������������������������������������������
			nGTotPis  += nValPis
			nGTotCof  += nValCof
			nGTotBase += nBase
		
		    ATI->(dbSkip())  
				  
		EndDo	
		
		//������������������������������������������������������������������������Ŀ
		//�Imprime total                                                           �
		//��������������������������������������������������������������������������
		If lHouveMov                          
		
			If nLinha > 60
				lHouveMov := .F.
			Endif
			
			Mtr927Cabec(@nLinha,Titulo,cCabec1,cCabec2,nomeprog,aNome[2])
			
			If lHouveMov 
				FmtLin({},aLay[05],,,@nLinha)
			Endif
		
			// Total do ultimo bem impresso
		   	aDetail := {Transform(nTotBase,"@e 99,999,999,999.99"),;
						Transform(nTotPis,"@e 99,999,999,999.99"),;
						Transform(nTotCof,"@e 99,999,999,999.99")}				
			FmtLin(aDetail,aLay[06],,,@nLinha)
			FmtLin({},aLay[07],,,@nLinha)
			
			// Total Geral
		   	aDetail := {Transform(nGTotBase,"@e 99,999,999,999.99"),;
						Transform(nGTotPis,"@e 99,999,999,999.99"),;
						Transform(nGTotCof,"@e 99,999,999,999.99")}				
			FmtLin(aDetail,aLay[08],,,@nLinha)
			FmtLin({},aLay[09],,,@nLinha)
		Endif
			
		//������������������������������������������������Ŀ
		//�Quando mudar a filial, reinicia os totalizadores�
		//��������������������������������������������������	
		//nTotPis   := 0
		//nTotCof   := 0                         
		//nTotBase  := 0   
		nGTotPis  := 0
		nGTotCof  := 0
		nGTotBase := 0
		
		//���������������������������������������������������������������Ŀ
		//�Excluindo o arquivo temporario criado pela funcao DeprecAtivo()�
		//�����������������������������������������������������������������
		dbSelectArea(aTemp[1,2])
		dbCloseArea()
		Ferase(aTemp[1,1]+GetDBExtension())
		Ferase(aTemp[1,1]+OrdBagExt()) 

	EndIf

	#IFDEF TOP
		If MV_PAR10 == 1
			Exit
		EndIf    
	#ENDIF
Next nForFilial

cFilAnt := cFilBack 
		
Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �Mtr927Cabec�Autor  �Mary C. Hergert     � Data � 28/09/2004  ���
��������������������������������������������������������������������������͹��
���Desc.     �Cabecalho do relatorio                                       ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Matr927                                                      ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function Mtr927Cabec(nLinha,Titulo,cCabec1,cCabec2,nomeprog,cNome)

Local aLay	:= RetLayOut()
	
If nLinha > 60
	If nLinha < 70                                                  
		FmtLin({},aLay[09],,,@nLinha)
	Endif
	nLinha := Cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,15)

	nLinha += 1
	FmtLin({},aLay[01],,,@nLinha)
	FmtLin({PadC(cNome,130)},aLay[10],,,@nLinha)
	FmtLin({},aLay[01],,,@nLinha)                              
	FmtLin({},aLay[02],,,@nLinha)                              
	FmtLin({},aLay[03],,,@nLinha)                              
Endif

Return .T.
	
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �RetLayOut | Autor � Mary C. Hergert       � Data � 13.07.04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o LayOut a ser impresso                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Array com o LayOut                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RetLayOut()

Local aLay := Array(11)      

aLay[10] :=            "|##################################################################################################################################|"
aLay[01] :=            "+----------------------------------------------------------------------------------------------------------------------------------+"
aLay[02] := STR0015 // "|                     Bem do Ativo Imobilizado                |Mes| Ano| Base Credito |Alq.PIS|   Val.PIS   |Alq.COF|   Val.COF    |"
aLay[03] :=            "+-------------------------------------------------------------+---+----+--------------+-------+-------------+-------+--------------+"
aLay[04] :=            "| ########################################################### | ##|####|##############| ##### |#############| ##### |##############|"
aLay[05] :=            "|-------------------------------------------------------------+---+----+--------------+-------+-------------+-------+--------------|"
aLay[06] := STR0016 // "|                            Total do Ativo                       |  #################| ####################| #####################|"
aLay[07] :=            "|-----------------------------------------------------------------+-------------------+---------------------+----------------------|"
aLay[08] := STR0017 // "|                             TOTAL GERAL                         |  #################| ####################| #####################|"
aLay[09] :=            "+-----------------------------------------------------------------+-------------------+---------------------+----------------------+"

Return(aLay)
