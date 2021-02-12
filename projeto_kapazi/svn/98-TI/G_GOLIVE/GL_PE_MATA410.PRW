
//Este ponto de entrada é chamado antes da abertura da tela de inclusão do pedido de vendas com o objetivo de permitir a validação do usuário.
User Function M410INIC()
Local aArea		:= GetArea()

If EXISTBLOCK("M050203")
	U_M050203()
Endif

RestArea(aArea)
Return()
