#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: MA416FIL		|	Autor: Luis Paulo								|	Data: 24/05/2018//
//==================================================================================================//
//	Descrição: Pe Filtro de orçamentos na aprovacao													//
//																									//
//==================================================================================================//
User Function MA416FIL()
	Local aArea	:= GetArea()
	Local cRet		:= ""
	Local cVend		:= ""
	// Local cIdU		:= __cUserID
	// Local cParaKP1	:= SuperGetMV("KP_VENINTE",.F.,"000000")
	// Local cParaKP2	:= SuperGetMV("KP_VENINT2",.F.,"000000")
	// Local cVendVTd	:= cParaKP1 + "," + cParaKP2 + ',000000'

	// If !(__cUserID $ cVendVTd)
	If !StaticCall(M415FSQL,PodeVerTodosPedidos)
		
		cVend := POSICIONE("SA3",7,xFilial("SA3") + RetCodUsr() ,"A3_COD") //pega o codigo do vendedor

		If !Empty(cVend)
			// valida se o campo existe
			If SCJ->( FieldPos("CJ_XVENDED" ) ) > 0
				cRet	:= " CJ_XVENDED $ '"+cVend+",      ' "
			Endif
		Else
			cRet	:= " CJ_XVENDED  == '      ' "
		EndIf
	EndIf

	RestArea(aArea)	
Return(cRet)