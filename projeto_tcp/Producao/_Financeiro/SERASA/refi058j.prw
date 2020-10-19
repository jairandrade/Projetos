#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³REFI058J  ºAutor  ³-Kaique Sousa-     º Data ³  01/25/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³CRIA AS PERGUNTAS NECESSARIAS PARA RODAR A ROTINA           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*User Function REFI058J(cPerg,cVersao)

Local _aArea		:= GetArea()
Local aRegs   		:= {}
Local aSeq			:= {'1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','X','Y','W','Z'}
Local nX				:= 0
Local nPergs		:= 0
Local aRegs			:= {}
Local aBasic		:= {}
Local nI			:= 1

Default cVersao 	:= 'P10'

If Upper(cVersao) == 'P10'
	cPerg := Substr(PadR(AllTrim(cPerg),10,Space(1)),1,10)
Else
	cPerg := Substr(PadR(AllTrim(cPerg),06,Space(1)),1,06)
EndIF

//Conta quantas perguntas existem atualmente.
DbSelectArea('SX1')
DbSetOrder(1)
SX1->(DbGoTop())
If SX1->(DbSeek(cPerg+'01'))
	While !SX1->(Eof()) .And. X1_GRUPO = cPerg
		nPergs++
		SX1->(DbSkip())
	EndDo
EndIf

//                1                      2  3   04  5  6   7  8  9  10 11  12  							  13
//              titulo                   tp tm   dc pr Ob  d1 d2 d3 d4 d5  f3  							  help
aAdd( aBasic, {"Convenio"   				,"C",006,00,00,"G","","","","","","ZP6"				  			,{"Selecione o Codigo do Convenio do","Pefin Serasa.                    ","                                 "}} )
//aAdd( aBasic, {"Filial de"					,"C",008,00,00,"G","","","","","",""					  			,{"Filial Inicial                   ","                                 ","                                 "}} )
//aAdd( aBasic, {"Filial Ate"				,"C",008,00,00,"G","","","","","",""					  			,{"Filial Final                     ","                                 ","                                 "}} )
aAdd( aBasic, {"Vendedor De"				,"C",006,00,00,"G","","","","","","SA3"				  			,{"Vendedor inicial                 ","                                 ","                                 "}} )
aAdd( aBasic, {"Vendedor Ate"				,"C",006,00,00,"G","","","","","","SA3"							,{"Vendedor Final                   ","                                 ","                                 "}} )
aAdd( aBasic, {"Cliente De" 				,"C",006,00,00,"G","","","","","","SA1"							,{"Cliente Inicial                  ","                                 ","                                 "}} )
aAdd( aBasic, {"Cliente Ate" 				,"C",006,00,00,"G","","","","","","SA1"  						,{"Cliente Final                    ","                                 ","                                 "}} )
aAdd( aBasic, {"Emitidos De"				,"D",008,00,00,"G","","","","","",""	  				  			,{"Emitidos de                      ","                                 ","                                 "}} )
aAdd( aBasic, {"Emitidos Ate"				,"D",008,00,00,"G","","","","","",""					  			,{"Emitidos ate                     ","                                 ","                                 "}} )
aAdd( aBasic, {"Vencidos De"				,"D",008,00,00,"G","","","","","",""	  				  			,{"Informe a partir de que data dese","ja que os titulos sejam seleciona","dos                              "}} )
aAdd( aBasic, {"Vencidos Ate"				,"D",008,00,00,"G","","","","","",""								,{"Informe ate que data deseja que  ","os titulos sejam selecionados    ","                                 "}} )
aAdd( aBasic, {"Excluir Tipos"			,"C",099,00,00,"G","","","","","","SPEF1"						,{"Informe os tipos que nao deseja  ","que sejam mostrados no Browse    ","                                 "}} )
aAdd( aBasic, {"Filtrar Somente Válidos?","N",001,00,00,"C","Sim","Não","","","",""						,{"Informe se deseja mostrar somente os válidos  ","para movimentação no Browse    ","                 "}} )

For nI := 1 To Len(aBasic)
	Aadd( aRegs , {cPerg ,StrZero(++Nx,2),aBasic[nI][1],"","","MV_CH"+aSeq[Nx],aBasic[nI][2],aBasic[nI][3],aBasic[nI][4],aBasic[nI][5],aBasic[nI][6],"","MV_PAR"+StrZero(nX,2),aBasic[nI][7],"","","","",aBasic[nI][8],"","","","",aBasic[nI][9],"","","","",aBasic[nI][10],"","","","",aBasic[nI][11],"","",aBasic[nI][12],"","S",aBasic[nI][13],{"","",""},{"","",""},"."+Substr(cPerg,1,6)+StrZero(nX,2)+"."})
Next nI

//Se quantidade de perguntas for diferente, apago todas
If nPergs <> Len(aRegs)
	SX1->(DbGoTop())
	For nX:=1 To nPergs
		If SX1->(DbSeek(cPerg+StrZero(nX,2)))
			If RecLock('SX1',.F.)
				SX1->(DbDelete()) 
				SX1->(MsUnlock())
			EndIF
		EndIF
	Next nX
EndIf

//ValidPerg(aRegs,cPerg,.T.)

RestArea(_aArea)

Return( Nil )

Static Function AjustaSX1(cPerg,aSX1)
	
	Local j,i	:= 1
	
	DbSelectArea('SX1')
	DbSetOrder(1)

	aEstrut:= { "X1_GRUPO",;
				"X1_ORDEM",;
				"X1_PERGUNT",;
				"X1_PERSPA",;
				"X1_PERENG" ,;
				"X1_VARIAVL",;
				"X1_TIPO" ,;
				"X1_TAMANHO",;
				"X1_DECIMAL",;
				"X1_PRESEL"	,;
                "X1_GSC"    ,;
				"X1_VALID",;
				"X1_VAR01"  ,;
				"X1_DEF01" ,;
				"X1_DEFSPA1",;
				"X1_DEFENG1",;
				"X1_CNT01",;
				"X1_VAR02"  ,;
				"X1_DEF02"  ,;
				"X1_DEFSPA2",;
                "X1_DEFENG2",;
				"X1_CNT02",;
				"X1_VAR03"  ,;
				"X1_DEF03" ,;
				"X1_DEFSPA3",;
				"X1_DEFENG3",;
				"X1_CNT03",;
				"X1_VAR04"  ,;
				"X1_DEF04"  ,;
				"X1_DEFSPA4"	,;
                "X1_DEFENG4",;
				"X1_CNT04",;
				"X1_VAR05"  ,;
				"X1_DEF05" ,;
				"X1_DEFSPA5",;
				"X1_DEFENG5",;
				"X1_CNT05",;
				"X1_F3"     ,;
				"X1_GRPSXG" ,;
				"X1_PYME",;
				"X1_HELP"}

	For i:= 1 To Len(aSX1)
        If !Empty(aSX1[i][1])
            If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
                lSX1 := .T.
                RecLock("SX1",.T.)
                
                For j:=1 To Len(aSX1[i])
                    If !Empty(FieldName(FieldPos(aEstrut[j])))
                        FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
                    EndIf
                Next j
                
                dbCommit()
                MsUnLock()
            EndIf
        EndIf
    Next i

Return( Nil )*/
