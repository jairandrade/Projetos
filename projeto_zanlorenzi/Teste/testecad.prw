User Function TesteCad()
	Local aRotAdic :={}
	Local bPre := {||MsgAlert('Chamada antes da fun��o')}
	Local bOK  := {||MsgAlert('Chamada ao clicar em OK'), .T.}
	Local bTTS  := {||MsgAlert('Chamada durante transacao')}
	Local bNoTTS  := {||MsgAlert('Chamada ap�s transacao')}
	Local aButtons := {}//adiciona bot�es na tela de inclus�o, altera��o, visualiza��o e exclusao
	aadd(aButtons,{ "PRODUTO", {|| MsgAlert("Teste")}, "Teste", "Bot�o Teste" }  ) //adiciona chamada no aRotina
	aadd(aRotAdic,{ "Adicional","U_Adic", 0 , 6 })
	AxCadastro("ZA0", "Clientes", "U_DelOk()", "U_COK()", aRotAdic, bPre, bOK, bTTS, bNoTTS, , , aButtons, , )
Return(.T.)
User Function DelOk()
	MsgAlert("Chamada antes do delete")
Return
User Function COK()
	MsgAlert("Clicou botao OK")
Return .t.
User Function Adic()
	MsgAlert("Rotina adicional")
Return
