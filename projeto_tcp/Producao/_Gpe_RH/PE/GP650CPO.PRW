#Include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

User Function GP650CPO()

	Local cQuery := ""
	Local cParc	 := ""
	Local nX	 := 0
	Local nLoop	 := 0

	cQuery := " SELECT MAX(RC1_PARC) PARC "
	cQuery += " FROM " + RetSQLName("RC1") + " RC1 "
	cQuery += " WHERE RC1.D_E_L_E_T_ <> '*' "
	cQuery += "   AND RC1.RC1_PREFIX = '"+SubStr(RC1->RC1_COMPET,5,2)+" "+"' "
	cQuery += "   AND RC1.RC1_NUMTIT = '"+StrZero(Val(Posicione("RC0",1,xFilial("RC0")+RC1->RC1_CODTIT+"01","RC0_NATURE")),9,0)+"' "

	TcQuery cQuery new Alias "QRY"

	DbSelectArea("QRY")
	DbGoTop()
	If !Empty(QRY->PARC)
		cParc := Soma1(QRY->PARC) //Val(QRY->PARC)+1
	Else
		DbSelectArea("QRY")
		DbCloseArea()
		cQuery := " SELECT MAX(E2_PARCELA) PARC "
		cQuery += " FROM " + RetSQLName("SE2") + " SE2 "
		cQuery += " WHERE SE2.D_E_L_E_T_ <> '*' "
		cQuery += "   AND SE2.E2_PREFIXO = '"+SubStr(RC1->RC1_COMPET,5,2)+" "+"' "
		cQuery += "   AND SE2.E2_NUM = '"+StrZero(Val(Posicione("RC0",1,xFilial("RC0")+RC1->RC1_CODTIT+"01","RC0_NATURE")),9,0)+"' "

		TcQuery cQuery new Alias "QRY"

		DbSelectArea("QRY")
		DbGoTop()
		If !Empty(QRY->PARC)
			cParc := Soma1(QRY->PARC) //Val(QRY->PARC)+1
		Else
			cParc := "01"
		EndIf
	EndIf

	DbSelectArea("QRY")
	DbCloseArea()

	aTotFunc := {}

	For nLoop := 1 to Len(aAliasFields)
		cFil := aAliasFields[nLoop][1]
		cMat := aAliasFields[nLoop][2]
		if aScan(aTotFunc,{|x| x[1]+x[2]==cFil+cMat}) == 0
			aAdd(aTotFunc,{cFil,cMat})
		endif
	Next nLoop

	RecLock("RC1",.f.)
//	RC1->RC1_PREFIX	:= SubStr(Strzero(Year(dDataBase),4,0),3,2)
	RC1->RC1_PREFIX	:= SubStr(RC1->RC1_COMPET,5,2)
	RC1->RC1_NUMTIT	:= StrZero(Val(Posicione("RC0",1,xFilial("RC0")+RC1->RC1_CODTIT+"01","RC0_NATURE")),9,0)
	RC1->RC1_ARELIN	:= AllTrim(Str(Len(aTotFunc)))
	RC1->RC1_PARC	:= cParc
	MsUnLock()

	If RC1->RC1_CODTIT $ "001|002|003"
		For nX := 1 to Len(aAliasFields)
			DbSelectArea("ZZG")
			DbSetOrder(1)
			DbSeek(xFilial("ZZG") + RC1->RC1_PREFIX + RC1->RC1_NUMTIT + RC1->RC1_PARC + aAliasFields[nX,3])
			If Found()
				RecLock("ZZG",.f.)
				ZZG->ZZG_VALOR	:= ZZG->ZZG_VALOR + aAliasFields[nX,5]
				ZZG->ZZG_QTDE	:= ZZG->ZZG_QTDE + 1
				MsUnLock()
			Else
				RecLock("ZZG",.t.)
				ZZG->ZZG_FILIAL := RC1->RC1_FILTIT
				ZZG->ZZG_PREFIX := RC1->RC1_PREFIX
				ZZG->ZZG_NUMTIT := RC1->RC1_NUMTIT
				ZZG->ZZG_PARC   := RC1->RC1_PARC
				ZZG->ZZG_CC		:= aAliasFields[nX,3]
				ZZG->ZZG_VALOR	:= aAliasFields[nX,5]
				ZZG->ZZG_QTDE	:= 1
				MsUnLock()
			EndIf
		Next nX
	EndIf

Return

