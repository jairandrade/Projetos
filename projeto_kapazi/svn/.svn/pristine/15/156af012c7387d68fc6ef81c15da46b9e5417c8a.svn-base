#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function AATF001() //Programa utilizado para geracao do codigo do bem através do gatilho no campo N1_GRUPO

aArea := GetArea()

Private cCodigo := ""

cQuery := "SELECT MAX(N1_CBASE) AS CODIGO "
cQuery += "FROM " + RetSQLName("SN1") + " SN1 "
cQuery += "WHERE D_E_L_E_T_ != '*' "
cQuery += "AND N1_FILIAL = '" + xFilial("SN1") + "' "
cQuery += "AND N1_CBASE LIKE '"+M->N1_GRUPO+"%'"

cQuery := ChangeQuery(cQuery)

TcQuery cQuery New Alias "TMP"

If TMP->(!Eof())
	cCodigo := Substr(CODIGO,1,4)+Strzero(Val(Substr(CODIGO,5,6))+1,6)
	If Substr(cCodigo,1,4) != Alltrim(M->N1_GRUPO)
		cCodigo := M->N1_GRUPO+Strzero(Val(Alltrim(CODIGO))+1,6)
	Else
		cCodigo := Substr(CODIGO,1,4)+Strzero(Val(Substr(CODIGO,5,6))+1,6)
	Endif
Else
	MsgInfo("Codigo Incorreto... Verifique","....")
Endif

dbCloseArea("TMP")

RestArea(aArea)
Return(cCodigo)
