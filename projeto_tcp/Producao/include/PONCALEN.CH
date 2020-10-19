#IFNDEF _PONCALEN_CH

	#DEFINE _PONCALEN_CH

	/*
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁBegin Constantes Manifestas para o Calendario de Marcacoes   Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
		#DEFINE ELEMENTOS_ATABCALEND		55	//Numero de Elementos do Calendario de Marcacoes
		
		#DEFINE CALEND_POS_DATA				01	// Data
		#DEFINE CALEND_POS_ORDEM			02	// Ordem
		#DEFINE CALEND_POS_HORA				03	// Hora
		#DEFINE CALEND_POS_TIPO_MARC		04	// Tipo Marc
		#DEFINE CALEND_POS_NUM_MARC			05	// No Marc.
		#DEFINE CALEND_POS_TIPO_DIA			06	// Tipo Dia
		#DEFINE CALEND_POS_HRS_TRABA		07	// Horas Trabalhada no Periodo
		#DEFINE CALEND_POS_SEQ_TURNO		08	// Sequ┬ncia de Turno
		#DEFINE CALEND_POS_HRS_INTER		09	// Horas de Intervalo
		#DEFINE CALEND_POS_EXCECAO			10	// Excecao ( E-Excecao, # E - nao e excecao )
		#DEFINE CALEND_POS_MOT_EXECAO		11	// Motivo da Excecao
		#DEFINE CALEND_POS_TIPO_HE_NOR		12	// Tipo de hora extra normal
		#DEFINE CALEND_POS_TIPO_HE_NOT		13	// Tipo de hora extra noturna
		#DEFINE CALEND_POS_TURNO			14	// Turno de Trabalho
		#DEFINE CALEND_POS_CC				15	// Centro de Custo do Periodo 
		#DEFINE CALEND_POS_PG_NONA_HORA		16	// Pagamento de Nona Hora
		#DEFINE CALEND_POS_LIM_MARCACAO		17	// Limite de Marcacao Inicial/Final
		#DEFINE CALEND_POS_COD_REFEICAO		18	// Codigo da Refeicao
		#DEFINE CALEND_POS_FERIADO			19	// Dia e Feriado
		#DEFINE CALEND_POS_TP_HE_FER_NR		20	// Tipo de Hora Extra Feriado Normal
		#DEFINE CALEND_POS_TP_HE_FER_NT		21	// Tipo de Hora Extra Feriado Noturna
		#DEFINE CALEND_POS_DESC_FERIADO 	22	// Descricao do Feriado
		#DEFINE CALEND_POS_REGRA			23	// Regra de Apontamento
		#DEFINE CALEND_POS_AFAST			24	// Funcionario Afastado
		#DEFINE CALEND_POS_TIP_AFAST		25	// Tipo do Afastamento
		#DEFINE CALEND_POS_INI_AFAST		26	// Data Inicial do Afastamento
		#DEFINE CALEND_POS_FIM_AFAST		27	// Data Final   do Afastamento
		#DEFINE CALEND_POS_INI_H_NOT		28	// Inicio do Horario Noturno
		#DEFINE CALEND_POS_FIM_H_NOT		29	// Final do Horario Noturno
		#DEFINE CALEND_POS_MIN_H_NOT		30	// Minutos da Hora Noturna
		#DEFINE CALEND_POS_TRAB_FERIADO		31	// Se funcionario Trabalha em Dias Feriados
		#DEFINE CALEND_POS_APON_FERIAS		32	// Se Aponta Quando Afastamento em Ferias
		#DEFINE CALEND_POS_TP_HE_NR_FER		33	// Tipo de hora extra normal (Ferias)
		#DEFINE CALEND_POS_TP_HE_NT_FER		34	// Tipo de hora extra noturna (Ferias)
		#DEFINE CALEND_POS_PAGINT			35	// Tipos de Intervalos Que sao Pagos conforme Regra
		#DEFINE CALEND_POS_TIPO_ORIG_DIA	36	// Tipo Original do Dia conforme excecao mas sem considerar a regra e/ou afastamentos
		#DEFINE CALEND_POS_HE_AUTO_FER		37	// Se H.Extras sЦo autorizadas para funcionario em ferias
		#DEFINE CALEND_POS_CODFUNC			38  // Codigo da Funcao do funcionario
		#DEFINE CALEND_POS_DEPTO			39  // Codigo de Depto. do funcionario
		#DEFINE CALEND_POS_POSTO			40  // Codigo do Posto do funcionario
		#DEFINE CALEND_POS_PERIODO			41	// Periodo
		#DEFINE CALEND_POS_ROTEIRO			42	// Roterio
		#DEFINE CALEND_POS_PROCESSO			43	// Processo
		#DEFINE CALEND_POS_NUM_PAGTO		44	// Num. de Pagamento
		#DEFINE CALEND_POS_JORN				45  // Cod. da Jornada
		#DEFINE CALEND_POS_P2ID				46	// Lote da excecao
		#DEFINE CALEND_POS_R8ID				47	// Identificacao afastamento
		#DEFINE CALEND_POS_DATA_APO			48  // Data de apontamento
		#DEFINE CALEND_POS_JND_CON			49  // Jornada continua
		#DEFINE CALEND_POS_LIE				50  // Limite inferior da primeira entrada
		#DEFINE CALEND_POS_LSE				51  // Limite superior da primeira entrada	
		#DEFINE CALEND_POS_LIS				52  // Limite inferior da primeira saida
		#DEFINE CALEND_POS_LSS				53  // Limite superior da primeira saida
		#DEFINE CALEND_POS_TPEXCE			54	// Tipo de Excecao 'F' = Funcionario / 'P' = Periodo
		#DEFINE CALEND_POS_INTSREP			55	// Intervalo para Geracao do ACJEF
	/*
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	ЁEnd Constantes Manifestas para o Calendario de Marcacoes     Ё
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

	#INCLUDE "AABONOS.CH"
	#INCLUDE "AMARC.CH"
	#INCLUDE "ARESULT.CH"
	#INCLUDE "ATOTAIS.CH"
	#INCLUDE "CALENBMP.CH"
	#INCLUDE "FILDFLT.CH"
	#INCLUDE "HEADERGD.CH"
	#INCLUDE "SCOPECNT.CH"

#ENDIF
