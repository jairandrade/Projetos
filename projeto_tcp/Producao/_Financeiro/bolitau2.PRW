
#INCLUDE "RWMAKE.CH"
#include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Itau     ³ Autor ³Rodrigo Slisinski      ³ Data ³ 18/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO BANCO Itaú COM CODIGO DE BARRAS        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function bolitau()

LOCAL	aPergs := {} 
Local ni
PRIVATE lExec    := .F.
PRIVATE cIndexName := ''
PRIVATE cIndexKey  := ''
PRIVATE cFilter    := ''

Tamanho  := "g"
titulo   := "Impressao de Boleto com Codigo de Barras"
cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
wnrel    := "BOLETO"
lEnd     := .F.
cPerg    :="BLTBAR    "
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
nLastKey := 0

dbSelectArea("SE1")

//cperg:=padr(cPerg,len(SX1->X1_GRUPO))

/*
Aadd(aPergs,{"De Prefixo","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Prefixo","","","mv_ch2","C",3,0,0,"G","","MV_PAR02","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Numero","","","mv_ch3","C",6,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Numero","","","mv_ch4","C",6,0,0,"G","","MV_PAR04","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Parcela","","","mv_ch5","C",1,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Parcela","","","mv_ch6","C",1,0,0,"G","","MV_PAR06","","","","Z","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Portador","","","mv_ch7","C",3,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","SA6","","","",""})
Aadd(aPergs,{"Ate Portador","","","mv_ch8","C",3,0,0,"G","","MV_PAR08","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","SA6","","","",""})
Aadd(aPergs,{"De Cliente","","","mv_ch9","C",6,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","SE1","","","",""})
Aadd(aPergs,{"Ate Cliente","","","mv_cha","C",6,0,0,"G","","MV_PAR10","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SE1","","","",""})
Aadd(aPergs,{"De Loja","","","mv_chb","C",2,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Loja","","","mv_chc","C",2,0,0,"G","","MV_PAR12","","","","ZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Emissao","","","mv_chd","D",8,0,0,"G","","MV_PAR13","","","","01/01/80","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Emissao","","","mv_che","D",8,0,0,"G","","MV_PAR14","","","","31/12/03","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Vencimento","","","mv_chf","D",8,0,0,"G","","MV_PAR15","","","","01/01/80","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Vencimento","","","mv_chg","D",8,0,0,"G","","MV_PAR16","","","","31/12/03","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Do Bordero","","","mv_chh","C",6,0,0,"G","","MV_PAR17","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Bordero","","","mv_chi","C",6,0,0,"G","","MV_PAR18","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
*/
//AjustaSx1("BLTBAR",aPergs)

Pergunte (cPerg,.F.)

Wnrel := SetPrint(cString,Wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,)

If nLastKey == 27
	Set Filter to
	Return
Endif

cIndexName	:= Criatrab(Nil,.F.)
cIndexKey	:= "E1_PORTADO+E1_CLIENTE+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)"
cFilter		:= "E1_FILIAL=='"+xFilial("SE1")+"'.And.E1_SALDO>0 .And."
cFilter		+= "E1_PREFIXO>='" + MV_PAR01 + "'.And.E1_PREFIXO<='" + MV_PAR02 + "' .And. " 
cFilter		+= "E1_NUM>='" + MV_PAR03 + "'.And.E1_NUM<='" + MV_PAR04 + "'.And."
cFilter		+= "E1_PARCELA>='" + MV_PAR05 + "'.And.E1_PARCELA<='" + MV_PAR06 + "' .And. "
//cFilter		+= "E1_PORTADO>='" + MV_PAR07 + "'.And.E1_PORTADO<='" + MV_PAR08 + "' .And. "
cFilter		+= "E1_CLIENTE>='" + MV_PAR09 + "'.And.E1_CLIENTE<='" + MV_PAR10 + "' .And. "
cFilter		+= "E1_LOJA>='" + MV_PAR11 + "'.And.E1_LOJA<='"+MV_PAR12+"'.And."
cFilter		+= "DTOS(E1_EMISSAO)>='"+DTOS(mv_par13)+"'.and.DTOS(E1_EMISSAO)<='"+DTOS(mv_par14)+"' .And. "
cFilter		+= 'DTOS(E1_VENCREA)>="'+DTOS(mv_par15)+'".and.DTOS(E1_VENCREA)<="'+DTOS(mv_par16)+'" .And. '
cFilter		+= "E1_NUMBOR>='" + MV_PAR17 + "'.And.E1_NUMBOR<='" + MV_PAR18 + "'.And."
cFilter		+= "!(E1_TIPO$MVABATIM) .And. "
cFilter		+= "E1_PORTADO=='341'"

IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
DbSelectArea("SE1")
#IFNDEF TOP
	DbSetIndex(cIndexName + OrdBagExt())
#ENDIF
dbGoTop()
@ 001,001 TO 400,700 DIALOG oDlg TITLE "Seleção de Titulos"
@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
@ 180,310 BMPBUTTON TYPE 01 ACTION (lExec := .T.,Close(oDlg))
@ 180,280 BMPBUTTON TYPE 02 ACTION (lExec := .F.,Close(oDlg))
ACTIVATE DIALOG oDlg CENTERED
	
dbGoTop()
If lExec
   aStruct := SE1->(DbStruct())
   //cArqSE1 := CriaTrab(aStruct,.T.)
   //DbUseArea(.T.,,cArqSE1,"AGLSE1",.F.)                              
   	oTempTable := FWTemporaryTable():New( "AGLSE1" )
	oTemptable:SetFields( aStruct )
	oTempTable:Create()
	cArqSE1 := oTempTable:GetRealName()
   nPos := aScan(aStruct,{|x| Alltrim(x[1]) == "E1_PREFIXO"} )
   
   DbSelectArea("AGLSE1")     
   cNomeInd  := "INDTMP"
   IndexSE1  :="E1_NUM+E1_CLIENTE+E1_LOJA"
   IndRegua("AGLSE1",cNomeInd,IndexSE1,,,"Criando Indice por Numero de Titulo..." )
   
   DbSelectArea("SE1")
   dbGoTop()
   ProcRegua(RecCount())
   Do While !SE1->(Eof())
	  If Marked("E1_OK") // Tratamento para aglutinar titulos com Numero Igual 02/05/06 - Solic. Paulo Neves por Christian Piske
	     AGLSE1->(DbSeek(SE1->E1_NUM+SE1->E1_CLIENTE+SE1->E1_LOJA))
	     If !AGLSE1->(Found())
	        RecLock("AGLSE1",.T.)
	        For ni := 1 To Len(aStruct) 
	            If ni <> nPos
                   FieldPut(ni,SE1->(FieldGet(ni)))	        
                Endif   
            Next    
	        MsUnLock("AGLSE1")
	     Else 
	        RecLock("AGLSE1",.F.)
	        AGLSE1->E1_VALOR   := AGLSE1->E1_VALOR   + SE1->E1_VALOR
	        AGLSE1->E1_VLCRUZ  := AGLSE1->E1_VLCRUZ  + SE1->E1_VLCRUZ
	        AGLSE1->E1_SALDO   := AGLSE1->E1_SALDO   + SE1->E1_SALDO
	        AGLSE1->E1_ACRESC  := AGLSE1->E1_ACRESC  + SE1->E1_ACRESC
	        AGLSE1->E1_DECRESC := AGLSE1->E1_DECRESC + SE1->E1_DECRESC
	        MsUnLock("AGLSE1")  
	     Endif     
	  Endif
	  SE1->(dbSkip())
	  IncProc()
   End
   
   Processa({|lEnd|MontaRel()})
Endif

           
DbSelectArea("SE1")
//RetIndex("SE1")
//Ferase(cIndexName+OrdBagExt())

If lExec 
   AGLSE1->(DbCloseArea())   
   
   SE1->(DBCLoseArea())
   DBSelectArea('SE1')
   //Ferase(cNomeInd+OrdBagExt())
Endif

freeObj(oTempTable)
oTemptable := nil

Return Nil

/* /                                                                                   

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  MontaRel³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER DO Itau COM CODIGO DE BARRAS     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontaRel()

LOCAL oPrint
LOCAL nX := 0
Local cNroDoc :=  " "
LOCAL aDadosEmp    := {	SM0->M0_NOMECOM                                    ,; //[1]Nome da Empresa
								SM0->M0_ENDCOB                                     ,; //[2]Endereço
								AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
								"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
								"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
								Subs("12919786000124",1,2)+"."+Subs("12919786000124",3,3)+"."+          ; //[6]
								Subs("12919786000124",6,3)+"/"+Subs("12919786000124",9,4)+"-"+                       ; //[6]
								Subs("12919786000124",13,2)                                                    ,; //[6]CGC
								"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
								Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        }  //[7]I.E

LOCAL aDadosTit
LOCAL aDadosBanco
LOCAL aDatSacado
LOCAL aBolText     := {"Após o vencimento cobrar multa de R$ "                ,;
								"Mora Diaria de R$ "                                   ,;
								"Sujeito a Protesto apos 05 (cinco) dias do vencimento"}

LOCAL nI           := 1
LOCAL aCB_RN_NN    := {}
LOCAL nVlrAbat		:= 0
Private aRec:={}

oPrint:= TMSPrinter():New( "Boleto Laser" )
oPrint:SetPortrait() // ou SetLandscape()  
oPrint:Setup()
oPrint:StartPage()   // Inicia uma nova página
nBol:=1
DbSelectArea("AGLSE1")
dbGoTop()
ProcRegua(RecCount())
Do While !AGLSE1->(EOF())
	//Posiciona o SA6 (Bancos)
	DbSelectArea("SA6")
	DbSetOrder(1)
	DbSeek(xFilial("SA6")+AGLSE1->E1_PORTADO+AGLSE1->E1_AGEDEP+AGLSE1->E1_CONTA,.T.)
	
	//Posiciona na Arq de Parametros CNAB
	
   
		//Posiciona o SA1 (Cliente)
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial()+AGLSE1->E1_CLIENTE+AGLSE1->E1_LOJA,.T.)
	
	DbSelectArea("AGLSE1")
	aDadosBanco  := {'341'   	,; 							// [1]Numero do Banco
                      'ITAU'    ,; 	// [2]Nome do Banco
	                  '2938'    ,; 		// [3]Agência
                      '09346'   ,; 	// [4]Conta Corrente
                      '1'       ,; 	// [5]Dígito da conta corrente
                      "175"                                              		}		// [6]Codigo da Carteira

	If Empty(SA1->A1_ENDCOB)
		aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;      	// [1]Razão Social
		AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;      	// [2]Código
		AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO),;      	// [3]Endereço
		AllTrim(SA1->A1_MUN )                            ,;  			// [4]Cidade
		SA1->A1_EST                                      ,;     		// [5]Estado
		SA1->A1_CEP                                      ,;      	// [6]CEP
		SA1->A1_CGC										          ,;  			// [7]CGC
		SA1->A1_PESSOA										}       				// [8]PESSOA
	Else
		aDatSacado   := {AllTrim(SA1->A1_NOME)            	 ,;   	// [1]Razão Social
		AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA              ,;   	// [2]Código
		AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;   	// [3]Endereço
		AllTrim(SA1->A1_MUNC)	                             ,;   	// [4]Cidade
		SA1->A1_ESTC	                                     ,;   	// [5]Estado
		SA1->A1_CEPC                                        ,;   	// [6]CEP
		SA1->A1_CGC												 		 ,;		// [7]CGC
		SA1->A1_PESSOA												 }				// [8]PESSOA
	Endif
	
	nVlrAbat   :=  SomaAbat(AGLSE1->E1_PREFIXO,AGLSE1->E1_NUM,AGLSE1->E1_PARCELA,"R",1,,AGLSE1->E1_CLIENTE,AGLSE1->E1_LOJA)

	//Aqui defino parte do nosso numero. 
		//Posiciona na Arq de Parametros CNAB
	IF  eMPTY(AGLSE1->E1_IDCNAB)
		SEE->(DbSelectArea("SEE"))
		SEE->(DbSetOrder(1))
		SEE->(DbSeek("01341 2938    09346-1  1" ,.T.))
		nFaixatu:=VAL(SEE->EE_FAXATU)+1
		RecLock("SEE",.f.)
		 SEE->EE_FAXATU :=STRZERO(nFaixatu,8)
		MsUnlock()
		cNroDoc	:= StrZero(nFaixatu,8)
	 eLSE 
	 	cNroDoc	:= alltrim(AGLSE1->E1_IDCNAB)
	 	nFaixatu:= alltrim(AGLSE1->E1_IDCNAB)
	 endif
	//Monta codigo de barras
	aCB_RN_NN    := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],cNroDoc,(AGLSE1->E1_VALOR-nVlrAbat),AGLSE1->E1_VENCTO)
	
	aDadosTit	:= {AllTrim(AGLSE1->E1_NUM)+AllTrim(AGLSE1->E1_PARCELA)+" / "+AllTrim(AGLSE1->E1_NFELETR)		,;  // [1] Número do título  // Incluido NFELETR
						AGLSE1->E1_EMISSAO                              	,;  // [2] Data da emissão do título
						dDataBase                    					,;  // [3] Data da emissão do boleto
						AGLSE1->E1_VENCTO                               	,;  // [4] Data do vencimento
						(AGLSE1->E1_SALDO - nVlrAbat)                  	,;  // [5] Valor do título
						aCB_RN_NN[3]                             	,;  // [6] Nosso número (Ver fórmula para calculo)
						AGLSE1->E1_PREFIXO                               	,;  // [7] Prefixo da NF
						AGLSE1->E1_TIPO	                           		}   // [8] Tipo do Titulo
	
	If Marked("E1_OK")
		Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
		nX := nX + 1
	EndIf                       
	
	AGLSE1->(dbSkip())
	IncProc()
	nI := nI + 1
EndDo                    
  
oPrint:EndPage() // Finaliza a página
oPrint:Preview()     // Visualiza antes de imprimir

Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Impress ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASERDO Itau COM CODIGO DE BARRAS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
LOCAL oFont8
LOCAL oFont11c
LOCAL oFont10
LOCAL oFont14
LOCAL oFont16n
LOCAL oFont15
LOCAL oFont14n
LOCAL oFont24
LOCAL nI := 0

//Parametros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFont8   := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
oFont8n   := TFont():New("Arial",9,8,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:StartPage()   // Inicia uma nova página

/******************/
/* PRIMEIRA PARTE */
/******************/

        
IF nBol==1
   nRow2 := -620 
else
   nRow2 := 1050
endif   

//Pontilhado sepa	rador  
//oPrint:SayBitmap(765,0001,'tesoura.bmp',184,122) 

if nBol==2
	For nI := 100 to 2300 step 50
		oPrint:Line(nRow2+0639, nI,nRow2+0639, nI+30)
	Next nI
endif	

oPrint:Line (nRow2+0710,100,nRow2+0710,2300)
oPrint:Line (nRow2+0710,500,nRow2+0630, 500)
oPrint:Line (nRow2+0710,710,nRow2+0630, 710)

oPrint:Say  (nRow2+0644,100,'Itaú',oFont14 )		// [2]Nome do Banco
oPrint:Say  (nRow2+0644,513,aDadosBanco[1]+"-0",oFont14 )	// [1]Numero do Banco
oPrint:Say  (nRow2+0644,1800,"Recibo do Sacado",oFont10)

oPrint:Line (nRow2+0810,100,nRow2+0810,2300 )
oPrint:Line (nRow2+0910,100,nRow2+0910,2300 )

//oPrint:Line (nRow2+0910,500,nRow2+1050,500) vertical

oPrint:Say  (nRow2+0710,100 ,"Cedente",oFont8)
oPrint:Say  (nRow2+0740,100 ,"TERMINAL DE CONTEINERES DE PARANAGUA S/A",oFont10)				//Nome + CNPJ

oPrint:Say  (nRow2+0710,1060,"Agência/Código Cedente",oFont8)
oPrint:Say  (nRow2+0740,1060,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10)

oPrint:Say  (nRow2+0710,1510,"Data Documento",oFont8)
oPrint:Say  (nRow2+0740,1510,StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4),oFont10) 

oPrint:Say  (nRow2+0710,1810,"Vencimento"                                     ,oFont8)
cString	:= StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol    := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0740,nCol,cString,oFont10)

oPrint:Say  (nRow2+0810,100 ,"Sacado"       ,oFont8)
oPrint:Say  (nRow2+0810,400 ,TRANSFORM(aDatSacado[7],iif(aDatSacado[8]="J","@R 99.999.999/9999-99","@R 999.999.999-99")),oFont10) // CNPJ ou CPF
oPrint:Say  (nRow2+0870,100 ,aDatSacado[1]	,oFont10) 

oPrint:Say  (nRow2+0810,1060,"Nosso Número"                         ,oFont8)
oPrint:Say  (nRow2+0840,1060,Alltrim(aDadosTit[6]),oFont10)

oPrint:Say  (nRow2+0810,1510 ,"No. Documento"                        ,oFont8)
oPrint:Say  (nRow2+0840,1510 ,aDadosTit[7]+aDadosTit[1]				,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow2+0810,1810,"Valor do Documento"                          	,oFont8)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0840,nCol,cString ,oFont10)

oPrint:Say  (nRow2+920,100 ,"Instruções (Texto de responsabilidade do cedente)",oFont8)
oPrint:Say  (nRow2+960,100 ,aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99")) +'       '+ aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99"))+'       '+aBolText[3] ,oFont8)

oPrint:Say  (nRow2+1005,1500,"Autenticação Mecânica",oFont8)

oPrint:Line (nRow2+1000,100 ,nRow2+1000,2300 )

/*****************/
/* SEGUNDA PARTE */
/*****************/

IF nBol==1
   nRow3 := -1470
else
   nRow3 := 360 
endif   

//Pontilhado separador  
//oPrint:SayBitmap(650,0001,'tesoura.bmp',184,122) 
For nI := 100 to 2300 step 50
	oPrint:Line(nRow3+1920, nI, nRow3+1920, nI+30)
Next nI
//nRow3:=nRow3//+150
oPrint:Line (nRow3+2000,100,nRow3+2000,2300)
oPrint:Line (nRow3+2000,500,nRow3+1920, 500)
oPrint:Line (nRow3+2000,710,nRow3+1920, 710)

oPrint:Say  (nRow3+1934,100,'Itaú',oFont14 )		// 	[2]Nome do Banco
oPrint:Say  (nRow3+1934,513,aDadosBanco[1]+"-0",oFont14 )	// 	[1]Numero do Banco
oPrint:Say  (nRow3+1934,755,aCB_RN_NN[2],oFont14)			//	Linha Digitavel do Codigo de Barras

oPrint:Line (nRow3+2100,100,nRow3+2100,2300 )
oPrint:Line (nRow3+2200,100,nRow3+2200,2300 )
oPrint:Line (nRow3+2270,100,nRow3+2270,2300 )
oPrint:Line (nRow3+2340,100,nRow3+2340,2300 )

oPrint:Line (nRow3+2200,500 ,nRow3+2340,500 )
oPrint:Line (nRow3+2270,750 ,nRow3+2340,750 )
oPrint:Line (nRow3+2100,1000,nRow3+2340,1000)
oPrint:Line (nRow3+2200,1300,nRow3+2270,1300)
oPrint:Line (nRow3+2200,1480,nRow3+2340,1480)

oPrint:Say  (nRow3+2000,100 ,"Local de Pagamento",oFont8)
oPrint:Say  (nRow3+2030,100 ,"Até o vencimento, preferencialmente no Itaú. Após o vencimento, somente no Itaú",oFont8)
//oPrint:Say  (nRow3+2060,100 ,"Sistema de Cobrança.",oFont8)
           
oPrint:Say  (nRow3+2000,1810,"Vencimento",oFont8)
cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol	:= 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2040,nCol,cString,oFont15n)

oPrint:Say  (nRow3+2100,100 ,"Cedente",oFont8)
oPrint:Say  (nRow3+2140,100 ,"TERMINAL DE CONTEINERES DE PARANAGUA S/A",oFont10) //Nome + CNPJ

oPrint:Say  (nRow3+2100,1005 ,"Endereço Cedente",oFont8)
oPrint:Say  (nRow3+2140,1005 ,"AV. PORTUARIA, S/N D. PEDRO II, PARANAGUA, PR",oFont8n) //Nome + CNPJ

oPrint:Say  (nRow3+2100,1810,"Agência/Código Cedente",oFont8)
cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5])

nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2140,nCol,cString ,oFont11c)


oPrint:Say  (nRow3+2200,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say (nRow3+2230,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)


oPrint:Say  (nRow3+2200,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say  (nRow3+2230,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow3+2200,1005,"Espécie Doc."                                   ,oFont8)
oPrint:Say  (nRow3+2230,1005,"Duplicata mercan"							,oFont10) //Tipo do Titulo
//oPrint:Say  (nRow3+2230,1050,aDadosTit[8]										,oFont10) //Tipo do Titulo

oPrint:Say  (nRow3+2200,1305,"Aceite"                                         ,oFont8)
oPrint:Say  (nRow3+2230,1400,"N"                                             ,oFont10)

oPrint:Say  (nRow3+2200,1485,"Data do Processamento"                          ,oFont8)
oPrint:Say  (nRow3+2230,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) // Data impressao


oPrint:Say  (nRow3+2200,1810,"Nosso Número"                                   ,oFont8)
cString := Alltrim(Substr(aDadosTit[6],1,3)+"/"+Substr(aDadosTit[6],4))
nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2230,nCol,cString,oFont11c)


oPrint:Say  (nRow3+2270,100 ,"CNPJ do Cedente"                                   ,oFont8)
oPrint:Say  (nRow3+2300,100 ,aDadosEmp[6]                                  	,oFont10)

oPrint:Say  (nRow3+2270,505 ,"Carteira"                                       ,oFont8)
oPrint:Say  (nRow3+2300,555 ,aDadosBanco[6]                                  	,oFont10)

oPrint:Say  (nRow3+2270,755 ,"Espécie"                                        ,oFont8)
oPrint:Say  (nRow3+2300,805 ,"Real"                                             ,oFont10)

oPrint:Say  (nRow3+2270,1005,"Quantidade"                                     ,oFont8)
oPrint:Say  (nRow3+2270,1485,"Valor"                                          ,oFont8)

oPrint:Say  (nRow3+2270,1810,"Valor do Documento"                          	,oFont8)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2300,nCol,cString,oFont11c)

oPrint:Say  (nRow3+2340,100 ,"Instruções (Texto de responsabilidade do cedente)",oFont8)
oPrint:Say  (nRow3+2440,100 ,aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99"))      ,oFont10)
oPrint:Say  (nRow3+2490,100 ,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99"))  ,oFont10)
oPrint:Say  (nRow3+2540,100 ,aBolText[3]                                        ,oFont10)

oPrint:Say  (nRow3+2340,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say  (nRow3+2410,1810,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (nRow3+2480,1810,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (nRow3+2550,1810,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say  (nRow3+2620,1810,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (nRow3+2690,100 ,"Sacado"                                         ,oFont8)
oPrint:Say  (nRow3+2690,1750,""                     ,oFont8)
oPrint:Say  (nRow3+2700,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)

if aDatSacado[8] = "J"
	oPrint:Say  (nRow3+2700,1300,TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CNPJ
Else
	oPrint:Say  (nRow3+2700,1300,TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
EndIf

oPrint:Say  (nRow3+2753,400 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (nRow3+2806,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

oPrint:Say  (nRow3+2855,100 ,"Ficha de Compensação"                         ,oFont14)
oPrint:Say  (nRow3+2855,1750,"Autenticação Mecânica"                        ,oFont8)

oPrint:Line (nRow3+2000,1800,nRow3+2690,1800 )
oPrint:Line (nRow3+2410,1800,nRow3+2410,2300 )
oPrint:Line (nRow3+2480,1800,nRow3+2480,2300 )
oPrint:Line (nRow3+2550,1800,nRow3+2550,2300 )
oPrint:Line (nRow3+2620,1800,nRow3+2620,2300 )
oPrint:Line (nRow3+2690,100 ,nRow3+2690,2300 )

oPrint:Line (nRow3+2850,100,nRow3+2850,2300  )


/*****************/
/* terceira PARTE */
/*****************/
/*

nRow3 := 150

//Pontilhado separador  
//oPrint:SayBitmap(650,0001,'tesoura.bmp',184,122) 
For nI := 100 to 2300 step 50
	oPrint:Line(nRow3+1920, nI, nRow3+1920, nI+30)
Next nI

nRow3+=250

oPrint:Line (nRow3+2000,100,nRow3+2000,2300)
oPrint:Line (nRow3+2000,500,nRow3+1920, 500)
oPrint:Line (nRow3+2000,710,nRow3+1920, 710)

oPrint:Say  (nRow3+1934,100,'Itaú',oFont14 )		// 	[2]Nome do Banco
oPrint:Say  (nRow3+1934,513,aDadosBanco[1]+"-0",oFont14 )	// 	[1]Numero do Banco
oPrint:Say  (nRow3+1934,755,aCB_RN_NN[2],oFont14)			//	Linha Digitavel do Codigo de Barras

oPrint:Line (nRow3+2100,100,nRow3+2100,2300 )
oPrint:Line (nRow3+2200,100,nRow3+2200,2300 )
oPrint:Line (nRow3+2270,100,nRow3+2270,2300 )
oPrint:Line (nRow3+2340,100,nRow3+2340,2300 )

oPrint:Line (nRow3+2200,500 ,nRow3+2340,500 )
oPrint:Line (nRow3+2270,750 ,nRow3+2340,750 )
oPrint:Line (nRow3+2100,1000,nRow3+2340,1000)
oPrint:Line (nRow3+2200,1300,nRow3+2270,1300)
oPrint:Line (nRow3+2200,1480,nRow3+2340,1480)

oPrint:Say  (nRow3+2000,100 ,"Local de Pagamento",oFont8)
oPrint:Say  (nRow3+2030,100 ,"Até o vencimento, preferencialmente no Itaú. Após o vencimento, somente no Itaú",oFont8)
//oPrint:Say  (nRow3+2060,100 ,"Sistema de Cobrança.",oFont8)
           
oPrint:Say  (nRow3+2000,1810,"Vencimento",oFont8)
cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol	:= 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2040,nCol,cString,oFont15n)

oPrint:Say  (nRow3+2100,100 ,"Cedente",oFont8)
oPrint:Say  (nRow3+2140,100 ,"TERMINAL DE CONTEINERES DE PARANAGUA S/A",oFont10) //Nome + CNPJ

oPrint:Say  (nRow3+2100,1005 ,"Endereço Cedente",oFont8)
oPrint:Say  (nRow3+2140,1005 ,"AV. PORTUARIA, S/N D. PEDRO II, PARANAGUA, PR",oFont8n) //Nome + CNPJ

oPrint:Say  (nRow3+2100,1810,"Agência/Código Cedente",oFont8)
cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5])

nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2140,nCol,cString ,oFont11c)


oPrint:Say  (nRow3+2200,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say (nRow3+2230,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)


oPrint:Say  (nRow3+2200,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say  (nRow3+2230,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow3+2200,1005,"Espécie Doc."                                   ,oFont8)
oPrint:Say  (nRow3+2230,1005,"Duplicata mercan"							,oFont10) //Tipo do Titulo
//oPrint:Say  (nRow3+2230,1050,aDadosTit[8]										,oFont10) //Tipo do Titulo

oPrint:Say  (nRow3+2200,1305,"Aceite"                                         ,oFont8)
oPrint:Say  (nRow3+2230,1400,"N"                                             ,oFont10)

oPrint:Say  (nRow3+2200,1485,"Data do Processamento"                          ,oFont8)
oPrint:Say  (nRow3+2230,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) // Data impressao


oPrint:Say  (nRow3+2200,1810,"Nosso Número"                                   ,oFont8)
cString := Alltrim(Substr(aDadosTit[6],1,3)+"/"+Substr(aDadosTit[6],4))
nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2230,nCol,cString,oFont11c)


oPrint:Say  (nRow3+2270,100 ,"CNPJ do Cedente"                                   ,oFont8)
oPrint:Say  (nRow3+2300,100 ,aDadosEmp[6]                                  	,oFont10)

oPrint:Say  (nRow3+2270,505 ,"Carteira"                                       ,oFont8)
oPrint:Say  (nRow3+2300,555 ,aDadosBanco[6]                                  	,oFont10)

oPrint:Say  (nRow3+2270,755 ,"Espécie"                                        ,oFont8)
oPrint:Say  (nRow3+2300,805 ,"Real"                                             ,oFont10)

oPrint:Say  (nRow3+2270,1005,"Quantidade"                                     ,oFont8)
oPrint:Say  (nRow3+2270,1485,"Valor"                                          ,oFont8)

oPrint:Say  (nRow3+2270,1810,"Valor do Documento"                          	,oFont8)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2300,nCol,cString,oFont11c)

oPrint:Say  (nRow3+2340,100 ,"Instruções (Texto de responsabilidade do cedente)",oFont8)
oPrint:Say  (nRow3+2440,100 ,aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99"))      ,oFont10)
oPrint:Say  (nRow3+2490,100 ,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99"))  ,oFont10)
oPrint:Say  (nRow3+2540,100 ,aBolText[3]                                        ,oFont10)

oPrint:Say  (nRow3+2340,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say  (nRow3+2410,1810,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (nRow3+2480,1810,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (nRow3+2550,1810,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say  (nRow3+2620,1810,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (nRow3+2690,100 ,"Sacado"                                         ,oFont8)
oPrint:Say  (nRow3+2690,1750,""                     ,oFont8)
oPrint:Say  (nRow3+2700,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)

if aDatSacado[8] = "J"
	oPrint:Say  (nRow3+2700,1300,TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CNPJ
Else
	oPrint:Say  (nRow3+2700,1300,TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
EndIf

oPrint:Say  (nRow3+2753,400 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (nRow3+2806,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

oPrint:Say  (nRow3+2855,100 ,"Ficha de Compensação"                         ,oFont14)
oPrint:Say  (nRow3+2855,1750,"Autenticação Mecânica"                        ,oFont8)

oPrint:Line (nRow3+2000,1800,nRow3+2690,1800 )
oPrint:Line (nRow3+2410,1800,nRow3+2410,2300 )
oPrint:Line (nRow3+2480,1800,nRow3+2480,2300 )
oPrint:Line (nRow3+2550,1800,nRow3+2550,2300 )
oPrint:Line (nRow3+2620,1800,nRow3+2620,2300 )
oPrint:Line (nRow3+2690,100 ,nRow3+2690,2300 )

oPrint:Line (nRow3+2850,100,nRow3+2850,2300  )

 */                             

 
IF nBol==1
	MsBar("INT25"  ,12.6,1,aCB_RN_NN[1]  ,oPrint,.F.,,,0.028,1.2,,,,.F.) 
//else
else
    MsBar("INT25"  ,28.2,0.9,aCB_RN_NN[1]  ,oPrint,.F.,,,0.028,1.2,,,,.F.) 
endif
 //   MsBar("INT25"  ,28.2,0.9,aCB_RN_NN[1ad]  ,oPrint,.F.,,,0.028,1.2,,,,.F.) 
//endif	
PEGASE1(AGLSE1->E1_NUM,AGLSE1->E1_CLIENTE,AGLSE1->E1_LOJA)
wHILE !TRB->(EOF())
    SE1->(DBSELECTaREA("SE1"))
    SE1->(DBCloseaREA("SE1")) 
    SE1->(DBSELECTaREA("SE1"))
    SE1->(DBSETORDER(1))
    SE1->(DBGOTOP())   
    SE1->(DBSEEK(xFilial("SE1")+TRB->E1_PREFIXO+TRB->E1_NUM+TRB->E1_PARCELA))
	if Empty(SE1->E1_IDCNAB)
		If SE1->(Found())
		   RecLock("SE1",.f.)
		   SE1->E1_IDCNAB 	:=	STRZERO(nFaixatu,8)   // Nosso número (Ver fórmula para calculo)
		   MsUnlock()
		Endif   
	  EndIF

	TRB->(DBsKIP())
ENd

oPrint:EndPage() // Finaliza a página
nBol:=1

/*	              
if nBol==1
   nBol++
else
   oPrint:EndPage() // Finaliza a página
   nBol:=1
endif   
*/
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo10 ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE DO Itau COM CODIGO DE BARRAS  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo10(cData)
LOCAL L,D,P := 0
LOCAL B     := .F.
L := Len(cData)
B := .T.
D := 0
While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		End
	End
	D := D + P
	L := L - 1
	B := !B
End
D := 10 - (Mod(D,10))
If D = 10
	D := 0
End
Return(D)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo11 ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER DO Itaú COM CODIGO DE BARRAS     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo11(cData)
LOCAL L, D, P := 0
L := Len(cdata)
D := 0
P := 1
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	End
	L := L - 1
End
D := 11 - (mod(D,11))
If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
	D := 1
End
Return(D)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ret_cBarra³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE DO Itaú COM CODIGO DE BARRAS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto)                                          

LOCAL cValorFinal := strzero(int(nValor*100),10)
LOCAL nDvnn			:= 0
LOCAL nDvcb			:= 0
LOCAL nDv			:= 0
LOCAL cNN			:= ''
LOCAL cRN			:= ''
LOCAL cCB			:= ''
LOCAL cS				:= ''
LOCAL cFator      := strzero(dVencto - ctod("07/10/97"),4)
LOCAL cCVT			:= "5"
LOCAL cCar			:="175"
//-----------------------------
// Definicao do NOSSO NUMERO
// ----------------------------


cS    := cAgencia+cConta+cCar+cNroDoc //
nDvnn :=modulo10(cS)//nossoNum(cCar,cConta,cAgencia,cNroDoc)// modulo11(cS) // digito verifIcador Nosso Num   
cNossoNum:=cNroDoc + AllTrim(Str(nDvnn))
cNN   := cCar+cNroDoc + '-' + AllTrim(Str(nDvnn))

//----------------------------------
//	 Definicao do CODIGO DE BARRAS
//----------------------------------                                                
cS:= cBanco + cFator +  strzero(val(cValorFinal),10) +cCar+cNossoNum +cAgencia+ cConta+cDacCC +'000'
nDvcb := modulo11(cS)
cCB   := SubStr(cS, 1, 4) + AllTrim(Str(nDvcb)) + SubStr(cS,5)
//alert(str(len(cCB)))
//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
//AAABC.DDDDX		DDDDD.DDFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV

// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	  B = Codigo da moeda, sempre 9
//	  C = Codigo da Transacao - FIXO 5
// DDDD = primeiros algarismos do código do cliente
//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS    := cBanco + cCar + substr(cNossoNum,1,2)
nDv   := modulo10(cS)
cRN   := SubStr(cS, 1, 5) + '.' + SubStr(cS, 6, 4) + AllTrim(Str(nDv)) + '  '      

// 	CAMPO 2:  
//11 A 13 – do 5º ao 7º algarismo do código do cliente no CÓDIGO DE BARRAS (Informado pelo Banco)
//14 a 15 – vago. Usar 00
//16 a 20 – 5 primeiros algarismos do número de referência do cliente (Nosso Número)
//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS :=  substr(cNossoNum,3,7)+ SUBSTR(cAgencia, 1, 3)
nDv:= modulo10(cS)
cRN += substr(cS,1,5)+'.'+substr(cS,6)+alltrim(Str(nDv))    //'77000.10217'+Alltrim(Str(nDv))+ ' '  //Subs(cBanco,1,3) + "9" + Subs(cCVT,1,1)+'.'+ Subs(cCart,2,3) + Subs(cNN,4,2) + SubStr(cRN,11,1)+ ' '+  Subs(cNN,6,5) +'.'+ Subs(cNN,11,1) + Alltrim(Str(nDvnn))+ Subs(cAgencia,1,3) +Alltrim(Str(nDv)) + ' ' 

// 	CAMPO 3:
//22 a 31 – do 6º ao 15º algarismo do número de referência do cliente (Nosso Número) 
//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
'
cS    := SUBSTR(cAgencia, 4, 1)+ cConta + cDacCC + '000' //substr(cNroDoc,5,3)+substr(cConta,1,6)+'0'
nDv   := modulo10(cS)
cRN   += " "+substr(cs,1,5)+'.'+substr(cs,6,5)+Alltrim(Str(nDv))

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cRN   := cRN + ' ' + AllTrim(Str(nDvcb)) + '  '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cRN   := cRN + cFator + StrZero(Int(nValor * 100),14-Len(cFator))

Return({cCB,cRN,cNN})


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSx1    ³ Autor ³ Microsiga            	³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica/cria SX1 a partir de matriz para verificacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                    	  		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*Static Function AjustaSX1(cPerg, aPergs)

Local _sAlias	:= Alias()
Local aCposSX1	:= {}
Local nX 		:= 0
Local lAltera	:= .F.
Local nCondicao
Local cKey		:= ""
Local nJ			:= 0

cPerg:= padr(cPerg,len(SX1->X1_GRUPO))

	aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
				"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
				"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
				"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
				"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
				"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
				"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
				"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	For nX:=1 to Len(aPergs)
		lAltera := .F.
		If MsSeek(cPerg+Right(aPergs[nX][11], 2))
			If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
				 Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
				aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
				lAltera := .T.
			Endif
		Endif
		
		If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]	
	 		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
	 	Endif	
		
		If ! Found() .Or. lAltera
			RecLock("SX1",If(lAltera, .F., .T.))
			Replace X1_GRUPO with cPerg
			Replace X1_ORDEM with Right(aPergs[nX][11], 2)
			For nj:=1 to Len(aCposSX1)
				If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
					FieldPos(AllTrim(aCposSX1[nJ])) > 0
					Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
				Endif
			Next nj
			MsUnlock()
			cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."
	
			If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
				aHelpSpa := aPergs[nx][Len(aPergs[nx])]
			Else
				aHelpSpa := {}
			Endif
			
			If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
				aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
			Else
				aHelpEng := {}
			Endif
	
			If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
				aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
			Else
				aHelpPor := {}
			Endif
	
			//PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
		Endif
	Next
Return*/



User function Static Function nossonumero(cData)
LOCAL L,D,P := 0
LOCAL B     := .F.
L := Len(cData)
B := .T.
D := 0
While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		End
	End
	D := D + P
	L := L - 1
	B := !B
End
D := 10 - (Mod(D,10))
If D = 10
	D := 0
End
Return(cData+str(d))



Static Function pegase1(cNum,cCli,CLoja)	

IF sELECT("TRB")<>0
	DBSELECtarea("TRB")
	DBcLOSEAREA()
eNDif
cQry:=" select E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA from "+RetSqlname("SE1")
cQry+=" where E1_NUM = '"+cNum+"' "
cQry+=" AND E1_CLIENTE= '"+cCli+"' "
cQry+=" AND E1_LOJA = '"+CLoja+"' "
cQry+=" AND E1_FILIAL = '"+XfILIAL("SE1")+"' "
cQry+=" and D_E_L_E_T_<>'*'  "

tcQuery cQry new Alias "TRB"

rETURN
