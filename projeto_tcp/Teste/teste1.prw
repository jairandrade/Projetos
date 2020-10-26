// No exemplo abaixo será apresentada uma mensagem, e enquanto esta não 
// for fechada a janela de processamento ficará ativa.
// Este comportamento acontecerá com qualquer bloco de código
// executado pela função MsgRun
MsgRun("MsgRun","Processando",{|| Alert("Processamento...") })
//Exemplo de Chamada
MsAguarde({|| fExemplo1()}, "Aguarde...", "Processando Registros...")
