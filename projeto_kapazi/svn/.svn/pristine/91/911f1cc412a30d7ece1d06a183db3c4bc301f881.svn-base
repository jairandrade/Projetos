#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
#Include "tbiconn.ch"

//Funcao responsavel por clonar a condicao de pagamento, gerando uma condição supplier
User Function CriaCPSP(cCondOri)
Local aArea		:= GetArea()
Local nI		:= 0
Local cMacro	:= ""
Local aCampos	:= {}
Local cNwCondS	:= cValTochar(RetCodCP())
Local aParcelas	:= {}
Private cUmx	:= "28"
Private cDoisx	:= "28,56"
Private cTresx	:= "28,56,84"
Private cQuatrx	:= "28,56,84,112"
Private cCincox	:= "28,56,84,112,140"
Private cSeisx	:= "28,56,84,112,140,168"
Private cCondF	:= ""

DbSelectArea("SE4")
SE4->(DbSetOrder(1))
SE4->(DbGoTOP())
If SE4->(DbSeek(xFilial("SE4") + cCondOri))

	aParcelas := Condicao(1000,cCondOri,,dDataBase)
	
	If Len(aParcelas) == 1
			cCondF 	:= cUmx
			cCondPM := cUmx
		
		ElseIf Len(aParcelas) == 2
			cCondF 	:= cDoisx
			cCondPM := "42"
				
		ElseIf Len(aParcelas) == 3
			cCondF 	:= cTresx
			cCondPM := "56"
			
		ElseIf Len(aParcelas) == 4
			cCondF := cQuatrx
			cCondPM := "70"
			
		ElseIf Len(aParcelas) == 5
			cCondF := cCincox
			cCondPM := "84"
			
		ElseIf Len(aParcelas) == 6
			cCondF := cSeisx
			cCondPM := "98"
	EndIf
	
	For nI	:= 1 To SE4->(FCount())
		
		If  Alltrim(SE4->(Field(nI))) == "E4_CODIGO"
				aAdd(aCampos,{  "SE4->" + SE4->(Field(nI)), cNwCondS } )
				
			ElseIf Alltrim(SE4->(Field(nI))) == "E4_DESCRI"
				//Adiciona as informacoes para clonagem para posteriormente gerar a condicao de pgto supplier
				aAdd(aCampos,{ "SE4->" + SE4->(Field(nI)), "("+SE4->E4_CODIGO+") " +Alltrim(&(SE4->(Field(nI)))) + " - SUPPLIER" })
			
			ElseIf Alltrim(SE4->(Field(nI))) == "E4_COND" 
				aAdd(aCampos,{ "SE4->" + SE4->(Field(nI)), cCondF })
								
			ElseIf Alltrim(SE4->(Field(nI))) == "E4_XCONDSP"
				//Adiciona as informacoes para clonagem para posteriormente gerar a condicao de pgto supplier
				aAdd(aCampos,{ "SE4->" + SE4->(Field(nI)), "S" })
				
			ElseIf Alltrim(SE4->(Field(nI))) == "E4_XCONDKA" 
				//Adiciona as informacoes para clonagem para posteriormente gerar a condicao de pgto supplier
				aAdd(aCampos,{ "SE4->" + SE4->(Field(nI)), cCondOri })
			
			ElseIf 	Alltrim(SE4->(Field(nI))) == "E4_XPRZMED"
				aAdd(aCampos,{ "SE4->" + SE4->(Field(nI)), Val(cCondPM) })
				
			Else
				aAdd(aCampos,{ "SE4->" + SE4->(Field(nI)), &(SE4->(Field(nI))) })
		EndIf
		
		/*
		cMacro := (SE4) + "->" + (SE4)->(Field(nI))
		cMacro += " := SINC->" + (cAlias)->(Field(nI))
		&(cMacro)
	
		cMacro := cAlias + "->" + (cAlias)->(Field(nI))
		cMacro += " := SINC->" + (cAlias)->(Field(nI))
		&(cMacro)
		*/
	
	Next
	
	RecLock("SE4",.T.)
	
	For nI	:= 1 To SE4->(FCount())
	
		&(aCampos[nI][1]) := aCampos[nI][2]
		/*
		cMacro := (aCampos[nI][1])
		cMacro += " := " + (aCampos[nI][2])
		&(cMacro)
		*/
	Next
	SE4->(MsUnLock())

EndIf

//Grava a condicao de pagamento supplier na cond original
DbSelectArea("SE4")
SE4->(DbSetOrder(1))
SE4->(DbGoTOP())
If SE4->(DbSeek(xFilial("SE4") + cCondOri))
	RecLock("SE4",.F.)
	SE4->E4_XCODSPP := cNwCondS
	SE4->(MSUnlock())
EndIf

cCondSPP	:=  cNwCondS //cCondSPP VARIAVEL Private na rotina origem

RestArea(aArea)	
Return()

//Retorna a proxima condicao de pagamento supplier
Static Function RetCodCP()
Local aArea		:= GetArea()
Local cQry 		:= ""
Local cAlias 	:= GetNextAlias()
Local cRetorno	:= ""

//If DbSelectArea((cAlias)) <> 0
	//(cAlias)->(DbCloseArea())
//EndIf

cQry 	+= " SELECT (ISNULL(MAX(E4_CODIGO),'799'))+1 AS CONDICAO
cQry 	+= " FROM SE4010
cQry 	+= " WHERE D_E_L_E_T_ = ''
cQry 	+= " AND E4_CODIGO >= '800'
cQry 	+= " AND E4_CODIGO < '900'

TcQuery cQry New Alias (cAlias)

cRetorno := (cAlias)->CONDICAO

(cAlias)->(DbCloseArea())

RestArea(aArea)
Return(cRetorno)


/*User Function MyMata360()
//DEFININDO variáveis 
Local aItemAux := {} //Array auxiliar para inserção dos itens
Local aCabecalho := {} //Array do cabeçalho (SE4)
Local aItens := {} //Array que irá conter os itens (SEC)
Private lMsErroAuto := .F. //Indicador do status pós chamada
//Populando Cabeçalho
aAdd(aCabecalho, {“E4_CODIGO” , “811”, Nil})
aAdd(aCabecalho, {“E4_TIPO”, “B”, Nil} )
aAdd(aCabecalho, {“E4_COND”, “16”, Nil} )
aAdd(aCabecalho, {“E4_DESCRI”, “Descricao”, Nil} )
//Populando Item auxiliar
aAdd(aItemAux, {“EC_ITEM”, “01”, Nil} )
aAdd(aItemAux, {“EC_TIPO”, “2”, Nil} )
aAdd(aItemAux, {“EC_COND”, “3”, Nil} )
aAdd(aItemAux, {“EC_IPI”, “N”, Nil} )
aAdd(aItemAux, {“EC_DDD”, “D”, Nil} )
aAdd(aItemAux, {“EC_SOLID”, “N”, Nil} )
aAdd(aItemAux, {“EC_RATEIO”, 100.00, Nil} )
aAdd(aItens, aItemAux)
//Chamando rotina automática de inclusão
MSExecAuto({|x,y,z|mata360(x,y,z)},aDados,aItens, 3)
//Verificando status da rotina executada
If !lMsErroAuto
ConOut(“Incluido com sucesso”)
Else
ConOut(“Erro na inclusão”)
EndIf
Return
*/