#ifdef SPANISH
	#define STR0001 "Doctos. del Cliente para Transporte"
#else
	#ifdef ENGLISH
		#define STR0001 "Customer documents for transportation"
	#else
		Static STR0001 := "Doctos. do Cliente para Transporte"
		#define STR0002  "Pesquisar"
		#define STR0003  "Visualizar"
		#define STR0004  "Incluir"
		#define STR0005  "Alterar"
		#define STR0006  "Estornar"
		Static STR0007 := "&Servicos"
		Static STR0008 := "&Documentos"
		Static STR0009 := "ATEN��O"
		Static STR0010 := "A somatoria dos valores de volume, peso ou valor do documento est�o diferentes dos valores informados na cota��o de Frete"
		#define STR0011  "Recalcular"
		#define STR0012  "Cancelar"
		Static STR0013 := "Escolha a Cotacao de Frete"
		#define STR0014  "Produto"
		Static STR0015 := "Peso Cubado"
		Static STR0016 := "Nota Fiscal"
		Static STR0017 := "Observacao"
		Static STR0018 := "Peso Cubado - <F4> "
		Static STR0019 := "Enderecamento - <F5> "
		#define STR0020  "Linha : "
		#define STR0021  "Qtd. Volumes"
		Static STR0022 := "Enderecamento"
		Static STR0023 := "O Cliente Remetente e Destinario estao Iguais ... Confirma ? "
		#define STR0024  "Sim"
		Static STR0025 := "Nao"
		Static STR0026 := "Observacao do Cliente"
		Static STR0027 := "Escolha a Inscricao"
		Static STR0028 := "Sequencia"
		Static STR0029 := "Inscricao"
		Static STR0030 := "Documentos do EDI de Cliente: "
		#define STR0031  "Copiar"
		#define STR0032  "Confirmar"
		Static STR0033 := "Solicitacao de Coleta"
		#define STR0034  "Peso Cub."
		#define STR0035  "Documento"
		#define STR0036  "Docum."
		Static STR0037 := "Ender."
		Static STR0038 := "Valor Informado - <F6>"
		Static STR0039 := "Val.Inf."
		Static STR0040 := "Tipos de Ve�culo - <F7>"
		Static STR0041 := "Tip.Vei."
		Static STR0042 := "Cota��es Realizadas - <F9>"
		Static STR0043 := "Cot.Real."
		Static STR0044 := "O Produto"
		Static STR0045 := "da Cota��o de Frete"
		Static STR0046 := ", n�o foi informado neste documento. Continua ?"
		Static STR0047 := "A somatoria dos valores de volume, peso ou valor do documento est�o diferentes dos valores informados na cota��o de Frete"
		#define STR0048  "Confirma"
		#define STR0049  "Redigita"
		Static STR0050 := "O total de volumes do peso cubado est� diferente da qtde. de volumes informada no documento. Confirma ?"
		#define STR0051  "Servi�os: "
		Static STR0052 := "Existe valor informado para o documento, deseja limpar o valor informado na mudan�a do servi�o ?"
		Static STR0053 := "O Local/Endere�o informado n�o est� cadastrado. Deseja Cadastrar ?"
		#define STR0054  "Visual."
		#define STR0055  "Pesq."
		#define STR0056  "Pesquisa"
		Static STR0057 := "Produtos da Cota��o de Frete No.: "
		Static STR0058 := "Produtos x Cliente Remetente: "
		#define STR0059  "C�digo"
		#define STR0060  "Descri��o"
		Static STR0061 := "Cota��es de Frete Aprovadas"
		Static STR0062 := "Tabela de Parceiros"
		#define STR0063  "Alian�a"
		Static STR0064 := "A entrada do documento do cliente se refere a uma devolu��o parcial ?"
		#define STR0065  "Tipos de ve�culo do documento"
		Static STR0066 := "Manuten��o de Documentos - Visualizar"
		Static STR0067 := "Tabela de Frete n�o localizada, deseja apresentar todos componentes do tipo valor informado ?"
		Static STR0068 := "Marca todos destinatarios iguais"
		Static STR0069 := "Selecione a Ocorr�ncia"
		Static STR0070 := "Cod. Ocorrencia"
		Static STR0071 := "Filial Origem: "
		#define STR0072  "Lote: "
		Static STR0073 := "Existem ve�culos associados a solicita��o de coleta que n�o foram confirmados na digita��o do documento do cliente para transporte. Continua?"
		#define STR0074  "Informe o Incoterm..."
		#define STR0075  "Informe a Rota..."
		#define STR0076  "Rota inv�lida para o servi�o e ou tipo de transporte informado"
		#define STR0077  "No transporte internacional n�o � poss�vel informar documentos com remetentes, destinat�rios, devedores e moedas diferentes!"
		#define STR0078  "N�o � permitido utilizar o devedor outros para este tipo de transporte"
		#define STR0079  "Contribuinte"
		#define STR0080  "N�o Contribuinte"
		Static STR0081 := "A sele��o de origem est� diferente da cota��o de frete. Confirma ?"
		#define STR0082  "Poder� ocorrer diverg�ncias de valores entre cota��o e c�lculo de frete !"
		Static STR0083 := "TMSA050 e TMSXFUNA incompatives. Atualize o fonte TMSXFUNA!"
		Static STR0084 := "Veiculo / Motorista diferente da Viagem Planejada de Coleta"
		#define STR0085  "Deseja cancelar a viagem ?"
		#define STR0086  "Executar novamente o Update TMS10R140!"
		#define STR0087  "A viagem "
		Static STR0088 := ", na qual a solicita��o de coleta informada na entrada da Nota Fiscal de Cliente est� amarrada, ser� cancelada, pois a viagem encontra-se em aberto. "
		Static STR0089 := "Este lote possui valor de Frete Informado. A altera��o deste lote ir� implicar no cancelamento da cota��o de frete, deseja continuar?"
		Static STR0090 := "NF x Class. ONU - <F10>"
		Static STR0091 := "NF x Class. ONU"
		Static STR0092 := "ONU X NF"
		#define STR0093  "Fechar lote"
		#define STR0094  "Calcular"
		#define STR0095  "Estornar"
		#define STR0096  "Recalculo"
		#define STR0097  "Cons.Doc"
		#define STR0098  "Refaturar"
		#define STR0099  "Impressao"
		#define STR0100  "legenda"
		#define STR0101  "Ct-e"
		#define STR0102  "CRT"
		#define STR0103  "DACTE"
		#define STR0104  "LOG REJ"
		#define STR0105  "Lote em aberto"
		#define STR0106  "Efetua o fechamento do lote: "
		#define STR0107  "Calculo frete"
		#define STR0108  "Frete informado - <F10>"
		#define STR0109  "Visualiza Frete - <F11>" 
		#define STR0110  "Vis.Frete"
		#define STR0111  "Frete Inf." 
		#define STR0112  "Valor do frete zerado" 
		#define STR0113  "Falha na linha totalizadora da composicao do frete" 
		#define STR0114  "Selecionar Lotes"
		#define STR0115  "Leitura do Codigo de Barras"
		#define STR0116  "Informe o c�digo de barras" 
		#define STR0117  " N�o � permitido estornar o lote com documento preenchido."
		#define STR0118  " Serie: "
		#define STR0119  "N�o � permitido a inclus�o para Remententes e Destinatarios diferentes. Informe o mesmo remetente e destinat�rio do documento anterior."
		#define STR0120  "Numero de Documento n�o encontrado ou j� digitado."
	#endif
#endif