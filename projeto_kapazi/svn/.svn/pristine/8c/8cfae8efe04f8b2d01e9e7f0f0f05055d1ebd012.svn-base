#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: M415FSQL		|	Autor: Luis Paulo								|	Data: 24/05/2018//
//==================================================================================================//
//	Descrição: Pe Filtro de orçamentos																//
//																									//
//==================================================================================================//
User Function M415FSQL()
	Local aArea		:= GetArea()
	Local cRet		:= ""
	Local cVend		:= ""

	If !PodeVerTodosPedidos(RetCodUsr())  

		//pega o codigo do vendedor
		cVend := POSICIONE("SA3",7,xFilial("SA3") + RetCodUsr() ,"A3_COD") 

		// valida se o campo existe
		If SCJ->( FieldPos("CJ_XVENDED" ) ) > 0
			cRet := " CJ_XVENDED IN ('"+cVend+"','')"
		Endif

	EndIf

	RestArea(aArea)	
Return(cRet)	

Static Function PodeVerTodosPedidos(cUser)
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local cUsuarios	:= GetMV("KP_VENINTE",,"000000")
	Local lContinua	:= .T.
	Local cParam	:= ""
	Local nX		:= 2

	Default	cUser	:= RetCodUsr()

	If !FWIsAdmin(cUser)

		While lContinua
			lContinua	:= .F.
			If GetMv("KP_VENINT"+cValToChar(nX),.T.)
				cParam		:= GetMv("KP_VENINT"+cValToChar(nX))

				If ValType(cParam) == "C"
					If !Empty(AllTrim(cUsuarios))
						cUsuarios += ","
					Endif
					cUsuarios += cParam
					lContinua := .T.
				Endif
			Endif
			nX++
		Enddo

		lRet := cUser $ cUsuarios
	
	Endif

	RestArea(aArea)
Return lRet
