#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
#Include "tbiconn.ch"

//Cria a condicao de prazo medio supplier
User Function CriaCPPM(cCondOri)
Local aArea		:= GetArea()
Local cQtdDM	:= 0
Local cPrzMed	:= 0
Local cCondSP	:= ""

DbSelectArea("SE4")
SE4->(DbSetOrder(1))
SE4->(DbGoTOP())
If SE4->(DbSeek(xFilial("SE4") + cCondOri))
	cCondSP := SE4->E4_XCODSPP
EndIf

DbSelectArea("SE4")
SE4->(DbSetOrder(1))
SE4->(DbGoTOP())
If SE4->(DbSeek(xFilial("SE4") + cCondSP))
	cPrzMed := SE4->E4_XPRZMED
	CriaCPM(cPrzMed)
EndIf

RestArea(aArea)	
Return()


//Funcao para criar a condicao de pagamento de prazo médio supplier.
Static Function CriaCPM(cPrzMed)
Local aArea		:= GetArea()
Local cProxCP	:= cValTochar(RetCodCP())

DbSelectArea("SE4")
SE4->(DbSetOrder(1))

RecLock("SE4",.T.)
SE4->E4_FILIAL	:= xFilial("SE4")
SE4->E4_CODIGO	:= cProxCP
SE4->E4_TIPO	:= "1"
SE4->E4_COND	:= cValTochar(cPrzMed)
SE4->E4_DESCRI	:= "SUPPLIER PRZ MEDIO ("+cValTochar(cPrzMed)+") DIAS"
SE4->E4_IPI		:= ""
SE4->E4_DDD		:= ""
SE4->E4_DESCFIN	:= 0
SE4->E4_DIADESC	:= 0
SE4->E4_FORMA	:= ""
SE4->E4_ACRSFIN	:= 0
SE4->E4_SOLID	:= "N"
SE4->E4_ACRES	:= "N"
SE4->E4_PERCOM	:= 0
SE4->E4_SUPER	:= 0
SE4->E4_INFER	:= 0
SE4->E4_FATOR	:= 0
SE4->E4_PLANO	:= ""
SE4->E4_JURCART	:= ""
SE4->E4_CTRADT	:= ""
SE4->E4_AGRACRS	:= ""
SE4->E4_LIMACRS	:= 0
SE4->E4_CCORREN	:= ""
SE4->E4_MSBLQL	:= "2"
SE4->E4_XPRZMED	:= 0
SE4->E4_XLIBPV	:= ""
SE4->E4_XCONDSP	:= ""
SE4->E4_XCODSPP	:= ""
SE4->E4_XCONDKA	:= ""

SE4->(MsUnLock())

//Na Condicao Supplier grava a condicao de prazo medio para liquidacao
DbSelectArea("SE4")
SE4->(DbSetOrder(1))
SE4->(DbGoTOP())
If SE4->(DbSeek(xFilial("SE4") + cCondSPP))
	RecLock("SE4",.F.)
	SE4->E4_XCONDPM := cProxCP
	SE4->(MsUnLock())
EndIf

RestArea(aArea)
Return()

//Retorna a proxima condicao de pagamento supplier
Static Function RetCodCP()
Local aArea		:= GetArea()
Local cQry 		:= ""
Local cAlias 	:= GetNextAlias()
Local cRetorno	:= ""

//If DbSelectArea((cAlias)) <> 0
//	(cAlias)->(DbCloseArea())
//EndIf

cQry 	+= " SELECT (ISNULL(MAX(E4_CODIGO),'899'))+1 AS CONDICAO
cQry 	+= " FROM SE4010
cQry 	+= " WHERE D_E_L_E_T_ = ''
cQry 	+= " AND E4_CODIGO >= '900'

TcQuery cQry New Alias (cAlias)

cRetorno := (cAlias)->CONDICAO

(cAlias)->(DbCloseArea())

RestArea(aArea)
Return(cRetorno)