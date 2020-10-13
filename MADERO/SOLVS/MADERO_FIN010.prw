#include "TopConn.ch"
#include "protheus.ch"
#define CRLF chr(13) + chr(10)

/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Customização                                            !
+------------------+---------------------------------------------------------+
!Modulo            ! FIN                                                     !
+------------------+---------------------------------------------------------+
!Nome              ! FIN010                                                !
+------------------+---------------------------------------------------------+
!Descricao         ! Emprestimo Financeiro                                   !
+------------------+---------------------------------------------------------+
!Autor             ! Valtenio Moura                                          !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 28/06/2018                                              !
+------------------+---------------------------------------------------------+
*/

User Function FIN010
Local aAreaSEH := GetArea("SEH")
Local oButton1
Local oButton2
Local oSay1
Local lOk := .F.
Private nValJrs := 0
Private nValAmr := 0
Private oFolder1
Private oMSNewGe2
Private aRotina := {}
Private aSE2 := {}
Private oSay2
Private oSay3
Private oSay4
Private oSay5
Private oSay6

aAdd(aRotina, {"Pesquisar" , "AxPesqui", 0, 1})
aAdd(aRotina, {"Visualizar", "AxVisual", 0, 2})
aAdd(aRotina, {"Incluir"   , "AxInclui", 0, 3})
aAdd(aRotina, {"Alterar"   , "AxAltera", 0, 4})
aAdd(aRotina, {"Excluir"   , "AxDeleta", 0, 5})

DEFINE MSDIALOG oFolder1 TITLE "Ajuste Emprestimo Financeiro" FROM 000, 000  TO 500, 700 COLORS 0, 16777215 PIXEL

fMSNewGe2()
@ 016, 297 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF oFolder1 ACTION If(nValJrs == 0 .And. nValAmr == 0,If(oMSNewGe2:TudoOk(), GravaSE2(), Nil),MSGALERT("Divergência nos valores de juros e/ou amortização","Erro na gravação")) PIXEL
@ 016, 243 BUTTON oButton2 PROMPT "Cancelar"  SIZE 037, 012 OF oFolder1 ACTION oFolder1:End() PIXEL
@ 017, 053 SAY oSay1 PROMPT "Ajuste de valores e vencimentos de emprestimo financeiro" SIZE 116, 007 OF oFolder1 COLORS 0, 16777215 PIXEL

@ 242,130 SAY oSay2 PROMPT "Total Juros"  SIZE 040,012 OF oFolder1 PIXEL
@ 242,170 SAY oSay3 PROMPT "0,00"  SIZE 040,012 OF oFolder1 PIXEL
@ 242,230 SAY oSay4 PROMPT "Total Amortização"  SIZE 70,012 OF oFolder1 PIXEL
@ 242,300 SAY oSay5 PROMPT "0,00"  SIZE 040,012 OF oFolder1 PIXEL //Total
ACTIVATE MSDIALOG oFolder1 CENTERED

RestArea(aAreaSEH)
Return


//------------------------------------------------
Static Function fMSNewGe2()
//------------------------------------------------

Local nX
Local aHeaderEx := {}
Local aColsEx := {}
Local aFieldFill := {}
Local aAlterFields := {"E2_PARCELA","E2_VENCTO","E2_JUROS","VALORAMRT", "VLRCORR", "E2_VALOR", "E2_HIST"}
Local aLin := {}
Local cQuery := ""
Local cNumero := SEH->EH_NUMERO
Local cCodFor := SE2->E2_FORNECE //SuperGetMV("MV_FOREMPR", .F., "000001") 
Local cSE2 := ""
Local cSEH := ""
Local nOpc := 4
Local TpCmp := ".T."
Local lVldOp := .F.
Local ValDeb := 0
Local ValDebAux := 0
Local ValCrg := 0
Local cQry := ""
Local cAlSEH

dbSelectArea("SX3")
dbsetorder(2)
For nX := 1 To Len(aAlterFields)
	lVldOp := dbSeek(aAlterFields[nX])
	If lVldOp
		If Alltrim(X3_CAMPO)=="E2_JUROS"
			TpCmp := "U_RecValJuro()"
		Else
			TpCmp := ".T."
		EndIf
		aAdd(aHeaderEx, {X3_TITULO,X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,TpCmp,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT})
	ElseIf 	aAlterFields[nX] $ "VALORAMRT/VLRCORR"
			If aAlterFields[nX]=="VALORAMRT"
				aAdd(aHeaderEx, {"Amortizacao"					,; 	// [01] C Titulo do campo
								 "VALORAMRT"					,; 	// [02] C ToolTip do campo
								 "@E 99,999,999,999.99 "		,; 	// [03] C identificador (ID) do Field
								 14 							,; 	// [04] C Tipo do campo
								 2								,; 	// [05] N Tamanho do campo
								 "U_RecValAmor()"				,; 	// [06] N Decimal do campo
								 "€€€€€€€€€€€€€€ " 				,; 	// [07] B Code-block de validação do campo
								 "N"							,; 	// [08] B Code-block de validação When do campo
								 "      " 						,; 	// [09] A Lista de valores permitido do campo
			      				 " "})
			ElseIf aAlterFields[nX]=="VLRCORR"
				aAdd(aHeaderEx, {"Valor Corrigido"				,; 	// [01] C Titulo do campo
								 "VLRCORR"						,; 	// [02] C ToolTip do campo
								 "@E 99,999,999,999.99 "		,; 	// [03] C identificador (ID) do Field
								 14 							,; 	// [04] C Tipo do campo
								 2								,; 	// [05] N Tamanho do campo
								 ".T." 							,; 	// [06] N Decimal do campo
								 "€€€€€€€€€€€€€€ " 				,; 	// [07] B Code-block de validação do campo
								 "N"							,; 	// [08] B Code-block de validação When do campo
								 "      " 						,; 	// [09] A Lista de valores permitido do campo
			      				 " "})
			EndIf
	EndIf
Next

aEval(aAlterFields, {|cCpo| If(cCpo != "VALORAMRT" .And. cCpo != "VLRCORR", cQuery += cCpo + ",", "")})
cQuery := "%" + cQuery + "%"

cSE2 := GetNextAlias()
BeginSQL Alias cSE2
	SELECT E2_NUM, %exp:cQuery% SE2.R_E_C_N_O_ AS E2_RECNO
	FROM %table:SE2% SE2
	WHERE SE2.%notdel%
	AND E2_FILIAL = %xfilial:SE2%
	AND E2_NUM = %exp:cNumero%
	AND E2_TIPO = 'PR'
	AND E2_FORNECE = %exp:cCodFor%
	AND E2_SALDO > 0
	ORDER BY E2_VENCREA
EndSQL
TCSetField(cSE2, "E2_VENCTO", "D", 8, 0)
TCSetField(cSE2, "E2_PARCELA", "C", 3, 0)

	cQry += "	SELECT EH_VALOR" + CRLF
	cQry += "	FROM " + RetSqlName("SEH") + " SEH " + CRLF 
	cQry += "	WHERE " + CRLF 
	cQry += "		SEH.EH_NUMERO = '" + E2_NUM + "' " + CRLF
	cQry += "		AND SEH.D_E_L_E_T_ = ' ' " + CRLF 
	cQry := ChangeQuery(cQry)
	cAlSEH := MPSysOpenQuery(cQry)

	ValDeb := (cAlSEH)->EH_VALOR

While !Eof()
	aLin := {}
	For nX := 1 To FCount()
		If nX == 1
			aAdd(aLin, E2_PARCELA) 			// Campo Parcela
		ElseIf nX == 2
			aAdd(aLin, E2_VENCTO) 			// Campo Vencimento
		ElseIf nX == 3
			aAdd(aLin, E2_JUROS) 			// Campo Juros
		ElseIf nX == 4
			aAdd(aLin, E2_VALOR - E2_JUROS) // Campo Amortização
		ElseIf nX == 5
			aAdd(aLin, ValDeb + E2_JUROS) 	// Campo Valor Corrigido
		ElseIf nX == 6
			aAdd(aLin, E2_VALOR) 			// Campo Valor Parcela
		Else
			aAdd(aLin, FieldGet(nX+1)) 		// Outros campos
		EndIf
	Next
	aAdd(aLin, .F.)
	aAdd(aColsEx, aClone(aLin))
	aAdd(aSE2, E2_RECNO)
	dbSelectArea(cSE2)
	dbSkip()
	ValDeb 		:= ValDeb - E2_VALOR
EndDo
dbCloseArea()

oMSNewGe2 := MsNewGetDados():New( 039, 011, 240, 343, GD_UPDATE,"AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aAlterFields,Nil, 999, "AllwaysTrue", "", "AllwaysTrue", oFolder1, aHeaderEx, aColsEx)
//oMSNewGe2 := MsNewGetDados():New( 039, 011, 240, 343, GD_INSERT+GD_DELETE+GD_UPDATE,"AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aAlterFields,Nil, 999, "AllwaysTrue", "", "AllwaysTrue", oFolder1, aHeaderEx, aColsEx)
return

Static Function GravaSE2
Local cQuery:= ""
Local nPar := 0
Local aTitSE2 := {}
Local nTotal:= 0
Local nJuros := 0   
Local n
Local nElem := 0

Private aHeader := oMSNewGe2:aHeader
Private aCols := oMSNewGe2:aCols


SE2->(dbGoTo(aSE2[1]))
aAdd(aTitSE2, {"E2_PREFIXO", SE2->E2_PREFIXO, Nil}) //  1
aAdd(aTitSE2, {"E2_NUM"    , SE2->E2_NUM    , Nil}) //  2
aAdd(aTitSE2, {"E2_PARCELA", ""             , Nil}) //  3
aAdd(aTitSE2, {"E2_TIPO"   , "PR "          , Nil}) //  4
aAdd(aTitSE2, {"E2_FORNECE", SE2->E2_FORNECE, Nil}) //  5
aAdd(aTitSE2, {"E2_LOJA"   , SE2->E2_LOJA   , Nil}) //  6
aAdd(aTitSE2, {"E2_NATUREZ", SE2->E2_NATUREZ, Nil}) //  7
aAdd(aTitSE2, {"E2_EMISSAO", SE2->E2_EMISSAO, Nil}) //  8
aAdd(aTitSE2, {"E2_VENCTO" , SToD("")       , Nil}) //  9
aAdd(aTitSE2, {"E2_VALOR"  , 0              , Nil}) // 10
aAdd(aTitSE2, {"E2_HIST"   , ""             , Nil}) // 11
aAdd(aTitSE2, {"E2_SALDO"  , SE2->E2_SALDO  , Nil}) // 12
aAdd(aTitSE2, {"E2_VLCRUZ" , 0              , Nil}) // 13  
aAdd(aTitSE2, {"E2_VENCORI" , SToD("")      , Nil}) // 14 
aAdd(aTitSE2, {"E2_BASEPIS" , 0             , Nil}) // 15 
aAdd(aTitSE2, {"E2_BASECSL" , 0             , Nil}) // 16     
aAdd(aTitSE2, {"E2_BASEISS" , 0             , Nil}) // 17 
aAdd(aTitSE2, {"E2_BASEIRF" , 0             , Nil}) // 18 
aAdd(aTitSE2, {"E2_BASECOF" , 0             , Nil}) // 19 
aAdd(aTitSE2, {"E2_BASEINS" , 0             , Nil}) // 20
aAdd(aTitSE2, {"E2_JUROS"   , SE2->E2_JUROS , Nil}) // 21 

For n := 1 To Len(aCols)
	If n > Len(aSE2) // registro novo
		If !aTail(aCols[n])
			nPar++
			aTitSE2[ 3][2] := StrZero(nPar, Len(SE2->E2_PARCELA)) 
			aTitSE2[ 9][2] := GDFieldGet("E2_VENCTO") 
			aTitSE2[10][2] := GDFieldGet("E2_VALOR") 
			aTitSE2[11][2] := GDFieldGet("E2_HIST") 
			aTitSE2[12][2] := GDFieldGet("E2_VALOR")			
			aTitSE2[13][2] := GDFieldGet("E2_VALOR")
			aTitSE2[14][2] := GDFieldGet("E2_VENCTO")
			aTitSE2[15][2] := GDFieldGet("E2_VALOR")									
			aTitSE2[16][2] := GDFieldGet("E2_VALOR")
			aTitSE2[17][2] := GDFieldGet("E2_VALOR")
			aTitSE2[18][2] := GDFieldGet("E2_VALOR")									
			aTitSE2[19][2] := GDFieldGet("E2_VALOR")									
			aTitSE2[20][2] := GDFieldGet("E2_VALOR")	
			aTitSE2[21][2] := GDFieldGet("E2_JUROS")
			IncSE2(aTitSE2) 
		EndIf
	Else
		SE2->(dbGoTo(aSE2[n]))
		RecLock("SE2", .F.)
		If aTail(aCols[n])
			dbDelete()
		Else
			nPar++
			FOR nElem := 1 To Len(aHeader)
				If aHeader[nElem][2] != "VALORAMRT" .And. aHeader[nElem][2] != "VLRCORR"
					&("SE2->" + aHeader[nElem][2]) := GDFieldGet(aHeader[nElem][2], n)
				EndIf
			NEXT nElem
			
			//aEval(aHeader, {|aCol| If(aCol[2] != "VALORAMRT" .And. aCol[2] != "VLRCORR", &("SE2->" + aCol[2]) := GDFieldGet(aCol[2]), "")})
			
			E2_PARCELA := StrZero(nPar, Len(E2_PARCELA))
			E2_VENCREA :=  DataValida(E2_VENCTO)    
			E2_SALDO   :=  E2_VALOR
			E2_VLCRUZ  :=  E2_VALOR
			E2_VENCORI :=  DataValida(E2_VENCTO)    
			E2_BASEPIS :=  E2_VALOR
			E2_BASECSL :=  E2_VALOR
			E2_BASEISS :=  E2_VALOR
			E2_BASEIRF :=  E2_VALOR
			E2_BASECOF :=  E2_VALOR
			E2_BASEINS :=  E2_VALOR
			E2_JUROS   :=  E2_JUROS
			
			nTotal:= nTotal + E2_VLCRUZ 
			nJuros:= nJuros + E2_JUROS
		EndIf
		msUnlock()
	EndIf
Next

// If nTotal == (SEH->EH_VLCRUZ + nJuros)
// 	oFolder1:End()
// Else
// 	Alert("O valor das Parcelas "+Str(nTotal)+" lançado não está de acordo com o valor do emprestimo + juros R$" + STR(SEH->EH_VLCRUZ + nJuros)+ "Diferença de: " +Str(nTotal - (SEH->EH_VLCRUZ + nJuros)) )
// 	oFolder1:Refresh()
// Endif

	oFolder1:End()

// If SEH->EH_XMOVBC == "2"
// 	cQuery := " UPDATE "
// 	cQuery += RetSqlName("SE5")
// 	cQuery += " SET D_E_L_E_T_ = '*' "
// 	cQuery += " WHERE "
// 	cQuery += " E5_FILIAL = '"+xFilial("SE5")+"' AND "  
// 	cQuery += " E5_RECPAG = 'R' AND "
// 	cQuery += " E5_VALOR = '"+STR(SEH->EH_VLCRUZ)+"' AND "
// 	cQuery += " E5_DATA = '"+DTOS(SEH->EH_DATA)+"' "
// 	TcSqlExec(cQuery)
// EndIf


Return

Static Function IncSE2(aSE2)
Local lOk  := .F.
Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

MsExecAuto({|x, y| Fina050(x, Nil, y)}, aSE2, 3)
If lMsErroAuto
	MostraErro()
Else
	lOk := .T.
EndIf
Return lOk

User Function RecValJuro()
Local lRet := .T.
Local nValJur  	:= aCols[n,3]
Local nValAmor 	:= aCols[n,4]
Local nValpar  	:= aCols[n,6]
Local _nJUROS  	:= &(ReadVar())
Local nO		:= 0

	nValJrs := nValJrs + (nValJur - _nJUROS)

	GDFieldPut("E2_VALOR", nValAmor + _NJUROS)

	oSay3:setText(Chr(3)+TRANSFORM(nValJrs, "@E 999,999.99"))

Return(lRet)

User Function RecValAmor()
Local lRet := .T.
Local nValJur  	:= aCols[n,3]
Local nValAmor 	:= aCols[n,4]
Local nValpar  	:= aCols[n,6]
Local _nAMORT  	:= &(ReadVar())
Local nO		:= 0

	nValAmr := nValAmr + (nValAmor - _nAMORT)

	GDFieldPut("E2_VALOR", _nAMORT + nValJur)

	oSay5:setText(Chr(3)+TRANSFORM(nValAmr, "@E 999,999.99"))

Return(lRet)
