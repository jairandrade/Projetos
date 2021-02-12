#INCLUDE "MATR820.CH"
#INCLUDE "FIVEWIN.CH"   
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

Static cAliasTop

//if(findfunction("U_KPFATC01"),u_KpFatC01(sc5->c5_num),"")                                             
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ORDPRO  ³ Autor ³ Rsac                  ³ Data ³ 18/07/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordens de Producao / Mapa de Producao  Laser               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Kapazi                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

user Function ORDPRO()
Private nRow := 0

If !ChkFile("SH8",.F.)
	Help(" ",1,"SH8EmUso")
	Return
Endif

MATR820R3()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR820  ³ Autor ³ Paulo Boschetti       ³ Data ³ 07.07.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordens de Producao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ MATR820(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
static Function MATR820R3()
Local titulo  := STR0039 //"Ordens de Producao"
Local cString := "SC2"
Local wnrel   := "MATR820"
Local cDesc   := STR0001	//"Este programa ira imprimir a Rela‡„o das Ordens de Produ‡„o"
Local aOrd    := {STR0002,STR0003,STR0004,STR0005}	//"Por Numero"###"Por Produto"###"Por Centro de Custo"###"Por Prazo de Entrega"
Local Tamanho := "M"

Private aReturn  := {STR0006,1,STR0007, 1, 2, 1, "",1 }	//"Zebrado"###"Administracao"
Private cPerg    :="MTR820"
Private nLastKey := 0
Private lItemNeg := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("MTR820",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // Da OP                                 ³
//³ mv_par02            // Ate a OP                              ³
//³ mv_par03            // Da data                               ³
//³ mv_par04            // Ate a data                            ³
//³ mv_par05            // Imprime roteiro de operacoes          ³
//³ mv_par06            // Imprime codigo de barras              ³
//³ mv_par07            // Imprime Nome Cientifico               ³
//³ mv_par08            // Imprime Op Encerrada                  ³
//³ mv_par09            // Impr. por Ordem de                    ³
//³ mv_par10            // Impr. OP's Firmes, Previstas ou Ambas ³
//³ mv_par11            // Impr. Item Negativo na Estrutura      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ChkFile("SH8",.F.)
	Help(" ",1,"SH8EmUso")
	Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc,"","",.F.,aOrd,.F.,Tamanho)

lItemNeg := GetMv("MV_NEGESTR") .And. mv_par11 == 1

If nLastKey == 27
	dbSelectArea("SH8")
	dbClearFilter()
	dbCloseArea()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retira o SH8 da variavel cFopened ref. a abertura no MNU     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ClosFile("SH8")
	dbSelectArea("SC2")
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	dbSelectArea("SH8")
	dbClearFilter()
	dbCloseArea()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retira o SH8 da variavel cFopened ref. a abertura no MNU     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ClosFile("SH8")
	dbSelectArea("SC2")
	Return
Endif

RptStatus({|lEnd| R820Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R820Imp  ³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 13.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relat¢rio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR820			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R820Imp(lEnd,wnRel,titulo,tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local CbCont,cabec1,cabec2
Local limite     := 80
Local nQuant     := 1
Local nomeprog   := "MATR820"
Local nTipo      := 18
Local cProduto   := SPACE(LEN(SC2->C2_PRODUTO))
Local cQtd,i,nBegin
Local cIndSC2    := CriaTrab(NIL,.F.), nIndSC2
Local lFlagMOD := .F.
Local aArea := GetArea()
local aAreaSb1 := {} 
local nTotBase := 0
local nTotTotal := 0


#IFDEF TOP
	Local bBlockFiltro := {|| .T.}
#ENDIF	

Private aArray   := {}
Private li       := 80

Private	oPrint		:= TMSPrinter():New(OemToAnsi('Ordem de Producao')),;
		oBrush		:= TBrush():New(,4),;
		cFileLogo	:= GetSrvProfString('Startpath','') + 'kapazi_logo' + '.BMP',;
		oFont07		:= TFont():New('Courier New',07,07,,.F.,,,,.T.,.F.),;
		oFont08		:= TFont():New('Courier New',08,08,,.F.,,,,.T.,.F.),;
		oFont09		:= TFont():New('Tahoma',09,09,,.F.,,,,.T.,.F.),;
		oFont10		:= TFont():New('Tahoma',10,10,,.F.,,,,.T.,.F.),;
		oFont10n	:= TFont():New('Courier New',10,10,,.T.,,,,.T.,.F.),;
		oFont11		:= TFont():New('Tahoma',11,11,,.F.,,,,.T.,.F.),;
		oFont12		:= TFont():New('Tahoma',12,12,,.T.,,,,.T.,.F.),;
		oFont12n	:= TFont():New('Tahoma',12,12,,.F.,,,,.T.,.F.),;
		oFont13		:= TFont():New('Tahoma',13,13,,.T.,,,,.T.,.F.),;
		oFont14		:= TFont():New('Tahoma',14,14,,.T.,,,,.T.,.F.),;
		oFont15		:= TFont():New('Courier New',15,15,,.T.,,,,.T.,.F.),;
		oFont18		:= TFont():New('Arial',18,18,,.T.,,,,.T.,.T.),;
		oFont16		:= TFont():New('Arial',16,16,,.T.,,,,.T.,.F.),;
		oFont20		:= TFont():New('Arial',20,20,,.F.,,,,.T.,.F.),;
		oFont22		:= TFont():New('Arial',22,22,,.T.,,,,.T.,.F.)


cAliasTop  := "SC2"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
m_pag    := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cabec1 := ""
cabec2 := ""

dbSelectArea("SC2")

#IFDEF TOP
	cAliasTop := GetNextAlias()
	cQuery := " SELECT SC2.C2_FILIAL, 
	cQuery += " 	     SC2.C2_NUM, 
	cQuery += " 	     SC2.C2_ITEM, 
	cQuery += " 	     SC2.C2_SEQUEN, 
	cQuery += " 	     SC2.C2_ITEMGRD, 
	cQuery += " 	     SC2.C2_DATPRF, 
	cQuery += " 	     SC2.C2_DATRF, 
	cQuery += " 	     SC2.C2_PRODUTO, 
	cQuery += " 	     SC2.C2_DESTINA, 
	cQuery += " 	     SC2.C2_PEDIDO, 
	cQuery += " 	     SC2.C2_ROTEIRO, 
	cQuery += " 	     SC2.C2_QUJE, 
	cQuery += " 	     SC2.C2_PERDA, 
	cQuery += " 	     SC2.C2_K_QTLOT, 
	cQuery += " 	     SC2.C2_QUANT, 
	cQuery += " 	     SC2.C2_DATPRI, 
	cQuery += " 	     SC2.C2_CC, 
	cQuery += " 	     SC2.C2_DATAJI, 
	cQuery += " 	     SC2.C2_DATAJF, 
	cQuery += " 	     SC2.C2_STATUS, 
	cQuery += " 	     SC2.C2_OBS, 
	cQuery += " 	     SC2.C2_TPOP, 
	cQuery += " 	     SC2.R_E_C_N_O_ SC2RECNO 
	cQuery += " 	FROM " + RetSqlName("SC2") + " SC2 
  cQuery += "  WHERE SC2.C2_FILIAL = '" + xFilial("SC2") + "' 
  cQuery += " 	 AND SC2.D_E_L_E_T_=' ' 
  cQuery += "    AND 
	
	If Upper(TcGetDb()) $ 'ORACLE,DB2,POSTGRES,INFORMIX'
		cQuery += "SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD >= '" + mv_par01 + "' AND "
		cQuery += "SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD <= '" + mv_par02 + "' AND "
	Endif
	
	cQuery += "SC2.C2_DATPRF BETWEEN '" + Dtos(mv_par03) + "' AND '" + Dtos(mv_par04) + "' "
	
	If mv_par08 == 2
		cQuery += "AND SC2.C2_DATRF = ' '"
	Endif	
	
	If aReturn[8] == 4
		cQuery += "ORDER BY SC2.C2_FILIAL + SC2.C2_DATPRF"
	Else
		cQuery += "ORDER BY " + SqlOrder(SC2->(IndexKey(aReturn[8])))
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
	aEval(SC2->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
	dbSelectArea(cAliasTop)

#ELSE
	If aReturn[8] == 4
		IndRegua("SC2",cIndSC2,"C2_FILIAL+DTOS(C2_DATPRF)",,,STR0008)	//"Selecionando Registros..."
	Else
		dbSetOrder(aReturn[8])
	EndIf
	dbSeek(xFilial("SC2"))
#ENDIF

If ! Empty(aReturn[7])
	bBlockFiltro := &("{|| " + aReturn[7] + "}")
Endif	

SetRegua(SC2->(LastRec()))

While !Eof()
	
	IF lEnd
		oPrint:Say(nRow,0100,STR0009,oFont11) //"CANCELADO PELO OPERADOR"
		//@ Prow()+1,001 PSay STR0009	//"CANCELADO PELO OPERADOR"
		Exit
	EndIF
	
	IncRegua()
	

	If C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD < xFilial('SC2')+mv_par01 .or. C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD > xFilial('SC2')+mv_par02
		dbSkip()
		Loop
	EndIf   
		
	#IFNDEF TOP		
		
		If  C2_DATPRF < mv_par03 .Or. C2_DATPRF > mv_par04
			dbSkip()
			Loop
		Endif
		
		If !(Empty(C2_DATRF)) .And. mv_par08 == 2
			dbSkip()
			Loop
		Endif
	#ENDIF

	If !Empty(aReturn[7])
		
		#IFDEF TOP
			SC2->(dbGoto((cAliasTop)->SC2RECNO))
		#ENDIF	

		If !(SC2->(Eval(bBlockFiltro)))
			(cAliasTop)->(dbSkip())
			Loop                 
		EndIf	
		
	Endif	

	//-- Valida se a OP deve ser Impressa ou n„o
	If !MtrAValOP(mv_par10,"SC2",cAliasTop)
		dbSkip()
		Loop
	EndIf
	
	cProduto  := C2_PRODUTO
	nQuant    := aSC2Sld(cAliasTop)
	
	dbSelectArea("SB1")
	dbSeek(xFilial()+cProduto)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona o primeiro elemento da estrutura , ou seja , o Pai  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AddAr820(nQuant)
	
	MontStruc((cAliasTop)->(C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD), nQuant)
	
	//If mv_par09 == 1
	aSort( aArray,2,, { |x, y| (x[1]+x[8]) < (y[1]+y[8]) } )
	//Else
	//	aSort( aArray,2,, { |x, y| (x[8]+x[1]) < (y[8]+y[1]) } )
	//ENDIF
	


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime cabecalho                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CabecOp(Tamanho) // 
	
		//nRow --> 0725 total de linhas

		nRow := nRow + 45

		oPrint:Line(nRow,100,nRow,2270)


               
	nTotBase := 0
	nTotTotal := 0                   
	lFlagMOD := .F.	
	For I := 2 TO Len(aArray)
	
		nRow := nRow + 45		     
		// verifica se mudou de insumo para MOD 
		if (substr(aArray[I][1], 1, 3) == "MOD") .and. (!lFlagMOD)
		oPrint:Line(nRow,100,nRow,2270)
		nRow := nRow + 45
		oPrint:Say(nRow,100,"                     MAO DE OBRA/MAQUINAS/BENEFICIAMENTO",oFont11) //"MAO DE OBRA/MAQUINAS/BENEFICIAMENTO"
		nRow := nRow + 45
		oPrint:Say(nRow,100,STR0012,oFont11) 
		nRow := nRow + 45
		oPrint:Line(nRow,100,nRow,2270)
		  lFlagMOD := .T.              
		nRow := nRow + 45		 		  
		endIf
     
    // localiza a quantidade base da estrutura
    aArea := GetArea()
    SG1->(DbSetOrder(1))
    SG1->(DbSeek(XFilial("SG1") + (cAliasTop)->C2_PRODUTO +  aArray[I][1]))
                   
    // posiciona o produto da estrutura
    aAreaSb1 := SB1->(GetArea())
    SB1->(DbSetOrder(1))
    SB1->(DbSeek(XFilial("SG1") + aArray[I][1]))
    
    // localiza o saldo atual
    SB2->(DbSetOrder(1))
    if SB2->(DbSeek(XFilial("SB2") + aArray[I][1] + SB1->B1_LOCPAD))
      nSaldoSb2 := SB2->B2_QATU - SB2->B2_QEMP
    else
      nSaldoSb2 := 0
    endIf 
      
    // imprime a linha de itens
		nRow := nRow + 45

		oPrint:Say(nRow,100,Substr(aArray[I][1], 1, 9),oFont11) // codigo do produto
		oPrint:Say(nRow,300,Substr(AllTrim(aArray[I][2]), 1, 40),oFont11) // descrição do produto
		oPrint:Say(nRow,700,Transform(SG1->G1_QUANT, "@E 9,999,999.9999"),oFont11) // quantidade base
		oPrint:Say(nRow,900,Transform((cAliasTop)->C2_K_QTLOT, "@E 9,999,999.9999"),oFont11) // quantidade lotes
		oPrint:Say(nRow,1200,SB1->B1_LOCPAD,oFont11) // Local Pad
		oPrint:Say(nRow,1500,Transform(nSaldoSb2, "@E 9,999.9999"),oFont11) // Saldo B2
		oPrint:Say(nRow,1800,Transform(aArray[I][5], "@E 9,999,999.9999"),oFont11) // quantidade base
		oPrint:Say(nRow,2100,aArray[I][4],oFont11) // unidade de medida



/*
		@ Li, 000 PSay Substr(aArray[I][1], 1, 9) // codigo do produto //
		@ li, 010 PSay Substr(AllTrim(aArray[I][2]), 1, 46) // descrição do produto //
		@	Li, 057 PSay Transform(SG1->G1_QUANT, "@E 999,999,999.9999") // quantidade base //
		@	Li, 074 PSay Transform((cAliasTop)->C2_K_QTLOT, "@E 999,999,999.9999") // quantidade lotes //
		@ Li, 091 PSay SB1->B1_LOCPAD //
		@ Li, 095 PSay Transform(nSaldoSb2, "@E 999,999.9999") //
		@	Li, 108 PSay Transform(aArray[I][5], "@E 999,999,999.9999") // quantidade base //
		@	Li, 125 PSay aArray[I][4]	// unidade de medida //
		Li++
*/

		  
		// acumula as variaveis
		nTotBase += SG1->G1_QUANT
		nTotTotal += aArray[I][5]
		
		// restaura a area
		RestArea(aAreaSb1)
		RestArea(aArea)
		   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao couber, salta para proxima folha                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                       
		IF nRow > 3500
			nRow := 0
			CabecOp(Tamanho)		// imprime cabecalho da OP
		EndIF
		
	Next I

  // linha de separacao
  // @li, 0 PSay __PrtThinLine() //    

   nRow := nRow + 45
   oPrint:Line(nRow,100,nRow,2270)
   nRow := nRow + 45
    
  // imprime os totais                           

	oPrint:Say(nRow,100,"TOTAIS",oFont11) // descrição do produto
	oPrint:Say(nRow,700,Transform(nTotBase, "@E 9,999,999.9999"),oFont11) // quantidade base
	oPrint:Say(nRow,1800,Transform(nTotTotal, "@E 9,999,999.9999"),oFont11) // descrição do produto


/*
	@ li, 010 PSay "TOTAIS" // descrição do produto
	@	Li, 057 PSay Transform(nTotBase, "@E 999,999,999.9999") // quantidade base
	@	Li, 108 PSay Transform(nTotTotal, "@E 999,999,999.9999") // quantidade base                       
*/


	//////ESPECIFICACAO DO PRODUTO
	nRow := nRow + 45
	nRow := nRow + 45
	oPrint:Line(nRow,100,nRow,0900)
	nRow := nRow + 45
	oPrint:Say(nRow,100,"ESPECIFICACAO DO PRODUTO",oFont11) //
	oPrint:Line(nRow,100,nRow,0900)
	nRow := nRow + 45
	oPrint:Say(nRow,100,"Dimencao........................:" + SB1->B1_DIMENSA,oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"Comprimento do Rolo.............:" + SB1->B1_COMPRIM,oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"Largura do Rolo.................:" + SB1->B1_LARGURA,oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"Peso do Rolo Ideal..............:" + SB1->B1_PIDEAL,oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"Peso do Rolo Maximo.............:" + SB1->B1_PMAX,oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"Peso do Rolo Minimo: " + SB1->B1_PMIN,oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"Peso da Trama :" + SB1->B1_PTRAMA,oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"Peso do Costado:" + SB1->B1_PCOSTAD ,oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"Peso da Cola:" + SB1->B1_PCOLA ,oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"Espessura do Tapete Ideal:" + SB1->B1_ESPTPID,oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"Espessura do Tapete Minima:" + SB1->B1_ESPTPMI,oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"Espessura do Tapete Maxima:" + SB1->B1_ESPTPMX,oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"Grossura da Trama:" + SB1->B1_GROTRAM,oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"Espessura da Trama:" + SB1->B1_ESPTRAM,oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"Composto:" + SB1->B1_COMPOST ,oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"Pigmento:" + SB1->B1_PIGMENT ,oFont11) //
	nRow := nRow + 45	
	oPrint:Line(nRow,100,nRow,0900)


	//////MATERIAL SEPARADO
	nRow := nRow + 45
	oPrint:Say(nRow,100,"MATERIAL SEPARADO",oFont11) //
	oPrint:Line(nRow,100,nRow,0900)
	nRow := nRow + 45
	oPrint:Say(nRow,100,"KARINA AB(1-A-IS)",oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"KARINA AA(1-J-IS)",oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"INTERNO 100 PARTES",oFont11) //
	nRow := nRow + 45
	oPrint:Say(nRow,100,"PIG. AGILCOR PRATA",oFont11) //
	nRow := nRow + 45
	oPrint:Line(nRow,100,nRow,0900)
	nRow := nRow + 45



	If mv_par05 == 1
		RotOper()   	// IMPRIME ROTEIRO DAS OPERACOES
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprimir Relacao de medidas para Cliente == HUNTER DOUGLAS.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("SMX")
	If Found() .And. (cAliasTop)->C2_DESTINA == "P"
		R820Medidas()
	EndIf

	m_pag++
//	Li := 0					// linha inicial - ejeta automatico
	nRow:= 0
	aArray:={}
	
	dbSelectArea(cAliasTop)
	dbSkip()
	
EndDO

dbSelectArea("SH8")
dbCloseArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retira o SH8 da variavel cFopened ref. a abertura no MNU     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ClosFile("SH8")

dbSelectArea("SC2")
#IFDEF TOP
	(cAliasTop)->(dbCloseArea())
#ELSE	
	If aReturn[8] == 4
		RetIndex("SC2")
		Ferase(cIndSC2+OrdBagExt())
	EndIf
#ENDIF
dbClearFilter()
dbSetOrder(1)

/*
If aReturn[5] = 1
	Set Printer TO
	dbCommitall()
	ourspool(wnrel)
Endif

MS_FLUSH()
*/

oPrint:EndPage() // Finaliza a página
oPrint:Preview()     //visualiza antes de imprimir
Return NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ AddAr820 ³ Autor ³ Paulo Boschetti       ³ Data ³ 07/07/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Adiciona um elemento ao Array                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ AddAr820(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Quantidade da estrutura                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR820                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function AddAr820(nQuantItem)
Local cDesc := SB1->B1_DESC
Local cRoteiro:=""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se imprime nome cientifico do produto. Se Sim    ³
//³ verifica se existe registro no SB5 e se nao esta vazio    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par07 == 1
	dbSelectArea("SB5")
	dbSeek(xFilial()+SB1->B1_COD)
	If Found() .and. !Empty(B5_CEME)
		cDesc := B5_CEME
	EndIf
ElseIf mv_par07 == 2
	cDesc := SB1->B1_DESC
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se imprime descricao digitada ped.venda, se sim  ³
	//³ verifica se existe registro no SC6 e se nao esta vazio    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasTop)->C2_DESTINA == "P"
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial()+(cAliasTop)->C2_PEDIDO+(cAliasTop)->C2_ITEM)
		If Found() .and. !Empty(C6_DESCRI) .and. C6_PRODUTO==SB1->B1_COD
			cDesc := C6_DESCRI
		ElseIf C6_PRODUTO # SB1->B1_COD
			dbSelectArea("SB5")
			dbSeek(xFilial()+SB1->B1_COD)
			If Found() .and. !Empty(B5_CEME)
				cDesc := B5_CEME
			EndIf
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se imprime ROTEIRO da OP ou PADRAO do produto    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty((cAliasTop)->C2_ROTEIRO)
	cRoteiro:=(cAliasTop)->C2_ROTEIRO
Else
	If !Empty(SB1->B1_OPERPAD)
		cRoteiro:=SB1->B1_OPERPAD
	Else
		dbSelectArea("SG2")
		If dbSeek(xFilial()+(cAliasTop)->C2_PRODUTO+"01")
			RecLock("SB1",.F.)
			Replace B1_OPERPAD With "01"
			MsUnLock()
			cRoteiro:="01"
		EndIf
	EndIf
EndIf

dbSelectArea("SB2")
dbSeek(xFilial()+SB1->B1_COD+SD4->D4_LOCAL)
dbSelectArea("SD4")
AADD(aArray, {SB1->B1_COD,cDesc,SB1->B1_TIPO,SB1->B1_UM,nQuantItem,D4_LOCAL,SB2->B2_LOCALIZ,D4_TRT,cRoteiro } )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ MontStruc³ Autor ³ Ary Medeiros          ³ Data ³ 19/10/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Monta um array com a estrutura do produto                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ MontStruc(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do produto a ser explodido                  ³±±
±±³          ³ ExpN1 = Quantidade base a ser explodida                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR820                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function MontStruc(cOp,nQuant)

dbSelectArea("SD4")
dbSetOrder(2)
dbSeek(xFilial()+cOp)

While !Eof() .And. D4_FILIAL+D4_OP == xFilial()+cOp
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no produto desejado                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB1")
	dbSeek(xFilial()+SD4->D4_COD)
	If SD4->D4_QUANT > 0 .Or. (lItemNeg .And. SD4->D4_QUANT < 0)
		AddAr820(SD4->D4_QUANT)
	EndIf
	dbSelectArea("SD4")
	dbSkip()
Enddo

dbSetOrder(1)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ CabecOp  ³ Autor ³ Valtenio Moura        ³ Data ³ 18/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Monta o cabecalho da Ordem de Producao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ CabecOp()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR820                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function CabecOp(Tamanho)
nRow := 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime o cabecalho da empresa. !³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPrint:SayBitmap(050,100,cFileLogo,0200,0100)
		oPrint:Say(050,1000,AllTrim(Upper(SM0->M0_NOMECOM)),oFont11)
		oPrint:Say(095,1000,"C A R T A  D E   P R O D U C A O ",oFont16)
		oPrint:Line(150,100,150,2270)

		oPrint:Say(185,100,"Maquina:",oFont12) //Falta colocar a maquina
		oPrint:Say(230,100,"Ordem de Producao N.:" + (cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN),oFont11)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Dados Produtos     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		 oPrint:Say(0275,100,"Produto: " + AllTrim(aArray[1][1]) + " - " + AllTrim(aArray[1][2]),oFont11) //"Produto: "
		 oPrint:Say(0320,100,"Emissao: " + DTOC(dDatabase),oFont11) //"Emissao:"
		 oPrint:Say(0365,100,STR0015 + TRANSFORM(m_pag, '999'),oFont11) //"Fol:"
		 oPrint:Say(0410,100,"Quantidade: " + AllTrim(Transform((cAliasTop)->C2_QUANT - (cAliasTop)->C2_QUJE, PesqPict("SC2", "C2_QUANT"))) + " " + aArray[1][4],oFont11)
		 oPrint:Say(0455,100,"Qtde. Lotes: " + AllTrim(Transform((cAliasTop)->C2_K_QTLOT, PesqPict("SC2", "C2_K_QTLOT"))),oFont11)
		 oPrint:Say(0455,500,STR0022+DTOC((cAliasTop)->C2_DATPRI),oFont11)//"Prev: "
		 oPrint:Say(0455,800,STR0022+DTOC((cAliasTop)->C2_DATPRF),oFont11)//"Prev: "

		 oPrint:Say(0500,100,STR0023+(cAliasTop)->C2_CC,oFont11) //"C.Custo: "
		 oPrint:Say(0500,500,STR0022+DTOC((cAliasTop)->C2_DATPRF),oFont11) //"Ajuste: "
		 oPrint:Say(0500,800,STR0022+DTOC((cAliasTop)->C2_DATPRF),oFont11) //"Ajuste: "


		If (cAliasTop)->C2_STATUS == "S"
		 oPrint:Say(0545,100,STR0025,oFont11) //"Status: OP Sacramentada"
		ElseIf (cAliasTop)->C2_STATUS == "U"
		 oPrint:Say(0545,100,STR0026,oFont11) //"Status: OP Suspensa"
		ElseIf (cAliasTop)->C2_STATUS $ " N"
		 oPrint:Say(0545,100,STR0027,oFont11) //"Status: OP Normal"
		EndIf

		 oPrint:Say(0545,500,STR0028,oFont11) //"Real  :   /  /      Real  :   /  / "

		/*
		If !(Empty((cAliasTop)->C2_OBS))
			oPrint:Say(0910,100,STR0029,oFont11) //"Observacao: "
			For nBegin := 1 To Len(Alltrim((cAliasTop)->C2_OBS)) Step 65
			oPrint:Say(0910,100,Substr((cAliasTop)->C2_OBS,nBegin,65),oFont11) //"Observacao: "
				
		li++
			Next nBegin
		EndIf
		

		oPrint:Line(0590,100,0950,2270)
		oPrint:Say(0635,100,cCabec2,oFont11) //cCabec2
		oPrint:Say(0680,100,cCabec3,oFont11) //cCabec3
		oPrint:Line(0725,100,1125,2270)
	*/
		nRow := 0725		

Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ RotOper  ³ Autor ³ Paulo Boschetti       ³ Data ³ 18/07/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Imprime Roteiro de Operacoes                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ RotOper()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR820                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function RotOper()

dbSelectArea("SG2")
If dbSeek(xFilial()+aArray[1][1]+aArray[1][9],.F.)
	
	cRotOper()
	
	While !Eof() .And. G2_FILIAL+G2_PRODUTO+G2_CODIGO = xFilial()+aArray[1][1]+aArray[1][9]
		
		dbSelectArea("SH4")
		dbSeek(xFilial()+SG2->G2_FERRAM)
		
		dbSelectArea("SH8")
		dbSetOrder(1)
		dbSeek(xFilial()+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+SG2->G2_OPERAC)
		lSH8 := IIf(Found(),.T.,.F.)
		
		If lSH8
			While !Eof() .And. SH8->H8_FILIAL+SH8->H8_OP+SH8->H8_OPER == xFilial()+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+SG2->G2_OPERAC
				ImpRot(lSH8)
				dbSelectArea("SH8")
				dbSkip()
			End
		Else
			ImpRot(lSH8)
		Endif
		
		dbSelectArea("SG2")
		dbSkip()
		
	EndDo
	
Endif

Return nRow

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ ImpRot   ³ Autor ³ Marcos Bregantim      ³ Data ³ 10/07/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Imprime Roteiro de Operacoes                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ ImpRot()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR820                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function ImpRot(lSH8)
Local nBegin

dbSelectArea("SH1")
dbSeek(xFilial()+IIf(lSH8,SH8->H8_RECURSO,SG2->G2_RECURSO))

Verilim()

   nRow := nRow + 45
oPrint:Say(nRow,100,IIF(lSH8,SH8->H8_RECURSO,SG2->G2_RECURSO)+" "+SUBS(SH1->H1_DESCRI,1,25),oFont11) 
oPrint:Say(nRow,300,SG2->G2_FERRAM+" "+SUBS(SH4->H4_DESCRI,1,20),oFont11)
oPrint:Say(nRow,600,SG2->G2_OPERAC,oFont11) 

/*
@Li,00 PSay IIF(lSH8,SH8->H8_RECURSO,SG2->G2_RECURSO)+" "+SUBS(SH1->H1_DESCRI,1,25)
@Li,33 PSay SG2->G2_FERRAM+" "+SUBS(SH4->H4_DESCRI,1,20)
@Li,61 PSay SG2->G2_OPERAC
*/

For nBegin := 1 To Len(Alltrim(SG2->G2_DESCRI)) Step 16
	oPrint:Say(nRow,300,Substr(SG2->G2_DESCRI,nBegin,16),oFont11) 
	//@li,064 PSay Substr(SG2->G2_DESCRI,nBegin,16)
	nRow := nRow + 45//li++

   IF nRow  > 3500
		nRow  := 1600
		cRotOper()
	EndIF
Next nBegin

nRow := nRow + 45 //Li+=1

oPrint:Say(nRow,100,STR0032+IIF(lSH8,DTOC(SH8->H8_DTINI),Space(8))+" "+IIF(lSH8,SH8->H8_HRINI,Space(5))+" "+STR0033+" ____/ ____/____ ___:___",oFont11)

nRow := nRow + 45
oPrint:Say(nRow,100,STR0034+IIF(lSH8,DTOC(SH8->H8_DTFIM),Space(8))+" "+IIF(lSH8,SH8->H8_HRFIM,Space(5))+" "+STR0035+" ____/ ____/____ ___:___",oFont11)

nRow := nRow + 45
oPrint:Say(nRow,100,STR0019,oFont11)
oPrint:Say(nRow,300,IIF(lSH8,SH8->H8_QUANT,aSC2Sld(cAliasTop)),oFont11)
oPrint:Say(nRow,600,STR0036,oFont11)
nRow := nRow + 45
oPrint:Line(nRow ,100,nRow ,2270)

/*

@Li,00 PSay STR0032+IIF(lSH8,DTOC(SH8->H8_DTINI),Space(8))+" "+IIF(lSH8,SH8->H8_HRINI,Space(5))+" "+STR0033+" ____/ ____/____ ___:___"	//"INICIO  ALOC.: "###" INICIO  REAL :"
Li++
@Li,00 PSay STR0034+IIF(lSH8,DTOC(SH8->H8_DTFIM),Space(8))+" "+IIF(lSH8,SH8->H8_HRFIM,Space(5))+" "+STR0035+" ____/ ____/____ ___:___"	//"TERMINO ALOC.: "###" TERMINO REAL :"
Li++
@Li,00 PSay STR0019	//"Quantidade :"[
@Li,13 PSay IIF(lSH8,SH8->H8_QUANT,aSC2Sld(cAliasTop)) PICTURE PesqPictQt("H8_QUANT",14)
@Li,28 PSay STR0036	//"Quantidade Produzida :               Perdas :"
Li++
@Li,00 PSay __PrtThinLine()
Li++
*/


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ RotOper  ³ Autor ³ Paulo Boschetti       ³ Data ³ 18/07/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Imprime Roteiro de Operacoes                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ RotOper()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR820                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function cRotOper()  //parei aqui

Local cCabec1 := SM0->M0_NOME+STR0030	//"              ROTEIRO DE OPERACOES              NRO :"
Local cCabec2 := STR0031					//"RECURSO                       FERRAMENTA               OPERACAO"


nRow := nRow + 45
oPrint:Line(nRow ,100,nRow ,2270)
nRow := nRow + 45
oPrint:Say(nRow,100,cCabec1,oFont11) 
oPrint:Say(nRow,300,(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD),oFont11)
oPrint:Line(nRow ,100,nRow ,2270)
nRow := nRow + 45
oPrint:Say(nRow,100,STR0013+aArray[1][1],oFont11) 
nRow := nRow + 45

/*
Li++
@Li,00 PSay __PrtFatLine()
Li++
@Li,00 PSay cCabec1
@Li,67 PSay (cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
Li++
@Li,00 PSay __PrtFatLine()
Li++
@Li,00 PSay STR0013+aArray[1][1]	//"Produto: 
*/

ImpDescr(aArray[1][2])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime a quantidade original quando a quantidade da    ³
//³ Op for diferente da quantidade ja entregue              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cAliasTop)->C2_QUJE + (cAliasTop)->C2_PERDA > 0

	oPrint:Say(nRow,100,STR0017,oFont11) 
	oPrint:Say(nRow,300,aSC2Sld(cAliasTop),oFont11)
	oPrint:Say(nRow,600,STR0018,oFont11) 
	oPrint:Say(nRow,900,(cAliasTop)->C2_QUANT,oFont11)

/*	@Li,00 PSay STR0017                 //"Qtde Prod.:"
	@Li,11 PSay aSC2Sld(cAliasTop)      PICTURE PesqPictQt("C2_QUANT",14)
	@Li,26 PSay STR0018                 //"Qtde Orig.:"
	@Li,37 PSay (cAliasTop)->C2_QUANT   PICTURE PesqPictQt("C2_QUANT",14)
*/
Else
	oPrint:Say(nRow,100,STR0019,oFont11) 
	oPrint:Say(nRow,300,aSC2Sld(cAliasTop),oFont11)
/*
	@Li,00 PSay STR0019            //"Quantidade :"
	@Li,15 PSay aSC2Sld(cAliasTop)	PICTURE PesqPictQt("C2_QUANT",14)
*/

Endif

nRow := nRow + 45
oPrint:Say(nRow,100,STR0023+(cAliasTop)->C2_CC,oFont11) 
nRow := nRow + 45
oPrint:Line(nRow ,100,nRow ,2270)
nRow := nRow + 45
oPrint:Say(nRow,100,cCabec2,oFont11) 
nRow := nRow + 45
oPrint:Line(nRow ,100,nRow ,2270)

/*
Li++
@Li,00 PSay STR0023+(cAliasTop)->C2_CC	//"C.Custo: "
Li++
@Li,00 PSay __PrtFatLine()
Li++
@Li,00 PSay cCabec2
Li++
@Li,00 PSay __PrtFatLine()
Li++
*/

Return nRow //Li

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ Verilim  ³ Autor ³ Paulo Boschetti       ³ Data ³ 18/07/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ Verilim()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 			                                          		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR820                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function Verilim()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a possibilidade de impressao da proxima operacao alocada na ³
//³ mesma folha.																			 ³
//³ 7 linhas por operacao => (total da folha) 66 - 7 = 59					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF nRow > 3500						// Li > 55
	nRow := 1600
	cRotOper(0)					// Imprime cabecalho roteiro de operacoes
Endif
Return nRow

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BARCODE  ³ Autor ³ Ricardo Dutra          ³ Data ³ 16/08/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para imprimir codigo de barras                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CodBar(ExpC1)								                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#define ESC	27
Static Function BarCode(cCodigo)
Local nLargura := 40	// largura de impressao do codigo
Local i, j, l, k, nCarac, cTexto, cEsc, cCode, nLimite, nImp, nBorda, nLin
Local aV0 := { Replicate(Chr(0),7), Chr(0) + Chr(0) + Chr(0) }
Local aV1 := { Replicate(Chr(127),6), Chr(127) + Chr(127) }
Local aImp [50]

nLin := 0							// imprime codigo comeco formulario
cEsc := Chr(ESC)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reseta a impressora na posicao atual - comeco formulario           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 0,0 PSay cEsc + "@"				// reseta a impressora nesta posicao

cTexto := cCodigo
cTexto := "*" + cTexto + "*"		// caracteres de inicio e fim

nImp := 1
aImp [nImp] := ""
nLimite := Len(cTexto)

FOR i := 1 TO nLimite
	nCarac := Asc (Substr (cTexto, i, 1))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atribui um codigo a cada caracter                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	IF nCarac == 42					// *
		cCode := "2122121222"
	ELSEIF nCarac == 32				// branco
		cCode := "2112221222"
	ELSEIF nCarac == 48				// 0
		cCode := "2221121222"
	ELSEIF nCarac == 49				// 1
		cCode := "1221222212"
	ELSEIF nCarac == 50				// 2
		cCode := "2211222212"
	ELSEIF nCarac == 51				// 3
		cCode := "1211222222"
	ELSEIF nCarac == 52				// 4
		cCode := "2221122212"
	ELSEIF nCarac == 53				// 5
		cCode := "1221122222"
	ELSEIF nCarac == 54				// 6
		cCode := "2211122222"
	ELSEIF nCarac == 55				// 7
		cCode := "2221221212"
	ELSEIF nCarac == 56				// 8
		cCode := "1221221222"
	ELSEIF nCarac == 57				// 9
		cCode := "2211221222"
	ELSEIF nCarac == 65				// A
		cCode := "1222212212"
	ELSEIF nCarac == 66				// B
		cCode := "2212212212"
	ELSEIF nCarac == 67				// C
		cCode := "1212212222"
	ELSEIF nCarac == 68				// D
		cCode := "2222112212"
	ELSEIF nCarac == 69				// E
		cCode := "1222112222"
	ELSEIF nCarac == 70				// F
		cCode := "2212112222"
	ELSEIF nCarac == 71				// G
		cCode := "2222211212"
	ELSEIF nCarac == 72				// H
		cCode := "1222211222"
	ELSEIF nCarac == 73				// I
		cCode := "2212211222"
	ELSEIF nCarac == 74				// J
		cCode := "2222111222"
	ELSEIF nCarac == 75				// K
		cCode := "1222222112"
	ELSEIF nCarac == 76				// L
		cCode := "2212222112"
	ELSEIF nCarac == 77				// M
		cCode := "1212222122"
	ELSEIF nCarac == 78				// N
		cCode := "2222122112"
	ELSEIF nCarac == 79				// O
		cCode := "1222122122"
	ELSEIF nCarac == 80				// P
		cCode := "2212122122"
	ELSEIF nCarac == 81				// Q
		cCode := "2222221112"
	ELSEIF nCarac == 82				// R
		cCode := "1222221122"
	ELSEIF nCarac == 83				// S
		cCode := "2212221122"
	ELSEIF nCarac == 84				// T
		cCode := "2222121122"
	ELSEIF nCarac == 85				// U
		cCode := "1122222212"
	ELSEIF nCarac == 86				// V
		cCode := "2112222212"
	ELSEIF nCarac == 87				// W
		cCode := "1112222222"
	ELSEIF nCarac == 88				// X
		cCode := "2122122212"
	ELSEIF nCarac == 89				// Y
		cCode := "1122122222"
	ELSEIF nCarac == 90				// Z
		cCode := "2112122222"
	ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona barras ou espacos ao array de impressao, sendo :     ³
	//³ - barra grossa  = 6 * Chr(127)                				      ³
	//³ - barra fina    = 2 * Chr(127)								         ³
	//³ - espaco grosso = 7 * Chr(0)                                  ³
	//³ - espaco fino   = 3 * Chr(0) 								         ³
	//³																               ³
	//³ As barras e espacos sao alocados de acordo com os caracteres  ³
	//³ de cCode, tomados 2 a 2, sendo que o primeiro designa as bar- ³
	//³ ras e o segundo, os espacos. 								         ³
	//³ Se o caracter for 1 => barra/espaco grosso					      ³
	//³ Se o caracter for 2 => barra/espaco fino					         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FOR j := 1 to 9 STEP 2
		aImp[nImp] := aImp[nImp] + aV1 [val(substr(cCode,j,1))] + ;
		aV0 [val(substr(cCode,j + 1,1))]
	NEXT
	
	l := len(aImp[nImp])
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se tamanho do string atual de impressao for maior que 120,				 ³
	//³copia o que ultrapassou para o proximo string								 ³
	//³Limita o string atual para 120 + caracteres de controle de imp grafica³
	//³Incrementa contador de strings													 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF l > 120
		aImp[nImp+1] := Right(aImp[nImp],l -120)
		aImp[nImp] := cEsc + "L" + Chr(120) + Chr(0) + Left(aImp[nImp],120)
		nImp++
	ENDIF
NEXT

j := Len(aImp[nImp])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Borda esquerda da etiqueta para centrar o codigo   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nBorda := (nLargura - (j + (nImp - 1) * 120 ) / Len(cTexto)) / 2

IF nBorda < 0
	return -2		// Codigo muito grande p/largura especificada
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Acrescenta caracteres de controle grafico ao ultimo string   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aImp[nImp] := cEsc + "L" + Chr(j)+Chr(0) + aImp[nImp] + cEsc + "3" + Chr(1)

FOR l := 1 to 4					// imprime quatro linhas
	FOR k := 1 to 3				// imprime tres vezes
		FOR i := 1 to nImp		// contador de strings
			@ nLin,nBorda+(i-1)*10 PSay aImp[i]
		NEXT
		nLin++
	NEXT
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seta tamanho de linha para posicionar para a proxima         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ nLin,1 PSay cEsc + "3" + Chr(18)
	nLin++
NEXT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta tamanho de linha p/ posicionar cursor proxima coluna de texto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nLin,1 PSay  cEsc + "3" + Chr(24)
nLin++

@ nLin,1 PSay cEsc + "2"			// cancela espacamentos de linha progrados

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime o numero da OP expandido e centralizado, embaixo do codigo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNumOp := Replicate(" ",3) + cTexto		// para centralizar
@ nLin,nBorda PSay Chr(14) + cNumOp	    // imprime expandido
nLin++
@ nLin,0 PSay Chr(20)					// volta ao normal

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpDescr ³ Autor ³ Marcos Bregantim      ³ Data ³ 31.08.93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprimir descricao do Produto.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpProd(Void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR820                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpDescr(cDescri)
Local nBegin

For nBegin := 1 To Len(Alltrim(cDescri)) Step 50
	oPrint:Say(nRow,100,Substr(cDescri,nBegin,50),oFont11)
	nRow := nRow + 45
	//@li,025 PSay Substr(cDescri,nBegin,50) //
	//li++
Next nBegin

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R820Medidas³ Autor ³ Jose Lucas           ³ Data ³ 25.01.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o registros referentes as medidas do Pedido Filho. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R820Medidas(Void)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR820                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R820Medidas()
Local aArrayPro := {}, lImpItem := .T.
Local nCntArray := 0,a01 := "",a02 := ""
Local nX:=0,nI:=0,nL:=0,nY:=0
Local cNum:="", cItem:="",lImpCab := .T.
Local nBegin, cProduto:="", cDesc, cDescri, cDescri1, cDescri2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Relacao de Medidas do cliente quando OP for gerada ³
//³ por pedidos de vendas.                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC5")
dbSetOrder(1)
If dbSeek(xFilial()+(cAliasTop)->C2_PEDIDO,.F.)
	cNum := (cAliasTop)->C2_NUM
	cItem := (cAliasTop)->C2_ITEM
	cProduto := (cAliasTop)->C2_PRODUTO
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprimir somente se houver Observacoes.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Comentado RSAC se houver necessidade tem que tirar o comentario e implementar em impressao Laser.
/*	
	IF !Empty(SC5->C5_OBSERVA)
		IF li > 53
			@ 03,001 PSay "HUNTER DOUGLAS DO BRASIL LTDA"
			@ 05,008 PSay "CONFIRMACAO DE PEDIDOS  -  "+IIF( SC5->C5_VENDA=="01","ASSESSORIA","DISTRIBUICAO")
			@ 05,055 PSay "No. RMP    : "+SC5->C5_NUM+"-"+SC5->C5_VENDA
			@ 06,055 PSay "DATA IMPRES: "+DTOC(dDataBase)
			li := 07
		EndIF
		li++
		@ li,001 PSay "--------------------------------------------------------------------------------"
		li++
		cDescri := SC5->C5_OBSERVA
		@ li,001 PSay " OBSERVACAO: "
		@ li,018 PSay SubStr(cDescri,1,60)
		For nBegin := 61 To Len(Trim(cDescri)) Step 60
			li++
			cDesc:=Substr(cDescri,nBegin,60)
			@ li,018 PSay cDesc
		Next nBegin
		li++
		cDescri1 := SC5->C5_OBSERV1
		@ li,018 PSay SubStr(cDescri1,1,60)
		For nBegin := 61 To Len(Trim(cDescri1)) Step 60
			li++
			cDesc:=Substr(cDescri1,nBegin,60)
			@ li,018 PSay cDesc
		Next nBegin
		Li++
		cDescri2 := SC5->C5_OBSERV2
		@ li,018 PSay SubStr(cDescri2,1,60)
		For nBegin := 61 To Len(Trim(cDescri2)) Step 60
			li++
			cDesc:=Substr(cDescri2,nBegin,60)
			@ li,018 PSay cDesc
		Next nBegin
		li++
		@ li,001 PSay "--------------------------------------------------------------------------------"
		li++
	EndIf
	*/
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carregar as medidas em array para impressao.                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SMX")
	dbSetOrder(2)
	dbSeek(xFilial()+cNum+cProduto)
	While !Eof() .And. M6_FILIAL+M6_NRREL+M6_PRODUTO == xFilial()+cNum+cProduto
		IF M6_ITEM == cItem
			AADD(aArrayPro,M6_ITEM+" - "+M6_PRODUTO)
			nCntArray++
			cCnt := StrZero(nCntArray,2)
			aArray&cCnt := {}
			While !Eof() .And. M6_FILIAL+M6_NRREL+M6_PRODUTO == xFilial()+cNum+cProduto
				If M6_ITEM == cItem
					AADD(aArray&cCnt,{ Str(M6_QUANT,9,2)," PECAS COM ",M6_COMPTO})
				EndIf
				dbSkip()
			End
		Else
			dbSkip()
		EndIF
	End
	cCnt := StrZero(nCntArray+1,2)
	aArray&cCnt := {}
	
	For nX := 1 TO Len(aArrayPro)
		If li > 58
			R820CabMed()
		EndIF
		@ li,009 PSay aArrayPro[nx]
		Li++
		Li++
		dbSelectArea("SMX")
		dbSetOrder(2)
		dbSeek( xFilial()+cNum+Subs(aArrayPro[nX],06,15) )
		While !Eof() .And. M6_FILIAL+M6_NRREL+M6_PRODUTO == xFilial()+cNum+Subs(aArrayPro[nX],06,15)
			If li > 58
				R820CabMed()
			EndIF
			IF M6_ITEM == Subs(aArrayPro[nX],1,2)
				@ li,002 PSay M6_QUANT
				@ li,013 PSay "PECAS COM"
				@ li,023 PSay M6_COMPTO
				@ li,035 PSay M6_OBS
				li ++
			EndIF
			dbSkip()
		End
		li++
	Next nX
	@ li,001 PSay "--------------------------------------------------------------------------------"
EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R820CabMed ³ Autor ³ Jose Lucas           ³ Data ³ 25.01.94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o cabecalho referentes as medidas do Pedido Filho. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R820CabMed(Void)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR820                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R820CabMed()
Local cCabec1 := SM0->M0_NOME+STR0037	//"               RELACAO DE MEDIDAS             NRO :"

Li := 0

Li++
@Li,00 PSay __PrtFatLine()
Li++
@Li,00 PSay cCabec1
@Li,67 PSay (cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
Li++
@Li,00 PSay __PrtFatLine()
Li++
Li++
Return Nil
