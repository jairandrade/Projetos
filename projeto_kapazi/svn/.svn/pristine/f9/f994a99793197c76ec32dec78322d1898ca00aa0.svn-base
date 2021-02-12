/*
Ponto de entradana exclusao do pedido de venda
Executado antes de deletar registro no SC5
*/

User Function MA410DEL()

	If ExistBlock("KFATR15")
		U_KFATR15("12",SC5->C5_NUM)
	Endif
	
Return