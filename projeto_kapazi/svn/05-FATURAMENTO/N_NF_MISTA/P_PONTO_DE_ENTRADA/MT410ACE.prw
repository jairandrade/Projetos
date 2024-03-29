#include 'protheus.ch'
#include 'parmtype.ch'

//==================================================================================================//
//	Programa: MT410ACE		|	Autor: Luis Paulo							|	Data: 06/01/2018	//
//==================================================================================================//
//	Descri��o: Este PE Est� em todas as rotinas de altera��o, inclus�o, exclus�o val. o acesso		//
//==================================================================================================//
User function MT410ACE()
Local aArea		:= GetArea()
Local nOpc  	:= PARAMIXB [1] // 1 - Excluir / 2 - Visualizar / Residuo / 3 - Copiar / 4 - Alterar
Local lRet		:= .T.
Local cParam	:= GetMv("KP_ALTPED",,"000000") //Verifica se a NF mista esta ativa
Local lSepVld	:= StaticCall(M521CART,TGetMv,"  ","KP_BLQPVSA","L",.T.,"MT410ACE - Ativar bloqueio de alteracao de pedido em separacao?")
Local cSepUsu	:= StaticCall(M521CART,TGetMv,"  ","KP_BLQPVSU","C","000000/000195/000167/000309/000118","MT410ACE - Usuarios que podem alterar pedido em separacao.")
Local aUsu		:= {}
Local cUsu		:= ""
Local cMsg		:= ""
Local nX		:= 0
Local cEmpBkp	:= cEmpAnt

// atribui novamente para o compilador nao reclamar
nOpc  	:= PARAMIXB [1] // 1 - Excluir / 2 - Visualizar / Residuo / 3 - Copiar / 4 - Alterar
cEmpBkp	:= cEmpAnt

If Type("l410Auto") == "U"
	l410Auto := .F.
Endif

If !(__CUserId $ cParam)

	If !Empty(SC5->C5_XIDVNFK) .And. Alltrim(SC5->C5_XTIPONF) == '2' .And. nOpc == 1 //Excluir - VAlidacao da exclusao da NFSE
		cMsg 	:= "Pedido de servi�o n�o pode ser exclu�do, voc� deve excluir o pedido de produto (ID-> "+SC5->C5_XIDVNFK+")!!!"
		lRet	:= .F.
	ElseIf !Empty(SC5->C5_XIDVNFK) .And. Alltrim(SC5->C5_XTIPONF) == '2' .And. !l410Auto .And. nOpc == 4 //Alteracao - Validacao da Alteracao da NFSE
		cMsg	:= "Pedido de servi�o n�o pode ser alterado, voc� deve excluir o pedido de produto (ID-> "+SC5->C5_XIDVNFK+")!!!"
		lRet	:= .F.
	ElseIf !Empty(SC5->C5_XIDVNFK) .And. IsInCallStack("A410PCopia") //Copiar - Validacao da Alteracao da NFSE
		cMsg	:= "Pedido que gerou servi�o n�o pode ser copiado!!!"
		lRet	:= .F.

	ElseIf !Empty(SC5->C5_XIDVNFK) .And. Alltrim(SC5->C5_XTIPONF) == '1' .And. !l410Auto .And. nOpc == 4 //Alteracao - Validacao da Alteracao da NFSE
		cMsg	:= "Pedido de servi�o n�o pode ser alterado, pois j� foi partido e gerou pedido de servi�o. Caso tenha alteracoes, estorne o pedido e exclua o mesmo (ID-> "+SC5->C5_XIDVNFK+")!!!"
		lRet	:= .F.

	EndIf

EndIf

If cEmpAnt == '04' .and. lRet
	If (SC5->C5_XPVSPC == 'S') .And. (SC5->C5_XSTSSPP != '9') .And. nOpc == 1 //Excluir
		cMsg	:= "Este pedido n�o pode ser exclu�do, pois encontra-se controlado pela supplier, favor informar o setor respons�vel para envio do cancelamento, ap�s o PV poder� ser cancelado"
		lRet	:= .F.
	EndIf
EndIf

// em separacao E (exclusao, alteracao, eliminar residuo ) 
If AllTrim(SC5->C5_XSITLIB) == "9" .and. (nOpc == 1 .or. nOpc == 4 .or. (nOpc == 2 .and. IsInCallStack("MA410RESID")) ) .and. lRet  .and. lSepVld
	lRet := __CUserId $ cSepUsu
	If !lRet
		aUsu := Separa(StrTran(StrTran(cSepUsu,"000000/",""),"000118",""),"/",.F.)
		For nX := 1 to Len(aUsu)
			if !Empty(AllTrim(cUsu))
				cUsu += ", "
			Endif
			cUsu += AllTrim(UsrFullName(aUsu[nX]))
		Next
		
		cMsg := "Somente os usu�rios "+cUsu+" podem alterar um pedido em separa��o. KP_BLQPVSU"
	Endif		
Endif

If !lRet
	MsgStop(cMsg)
Endif

RestArea(aArea)
Return(lRet)

