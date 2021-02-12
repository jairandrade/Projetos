/*
Este ponto de Entrada serve para preencher ou não com as variaveis (cBanco/cAgencia/cConta) os campos SE1->E1_PORTADO / SE1->E1_AGEDEP / SE1->E1_CONTA, caso eles sejam vazios.
Se for passado False (.F.) no ponto de Entrada ele não verificará se esses campos são vazios.

/**PONTO DE ENTRADA PARA USAR O BANCO DE DO ARQUIVO DE RETORNO CNAB CONTAS A RECEBER */
User Function F200PORT()
Local lRet	:= .f.



Return(lRet)
