// No exemplo abaixo ser� apresentada uma mensagem, e enquanto esta n�o 
// for fechada a janela de processamento ficar� ativa.
// Este comportamento acontecer� com qualquer bloco de c�digo
// executado pela fun��o MsgRun
MsgRun("MsgRun","Processando",{|| Alert("Processamento...") })
//Exemplo de Chamada
MsAguarde({|| fExemplo1()}, "Aguarde...", "Processando Registros...")
