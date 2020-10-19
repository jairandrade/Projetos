#ifdef SPANISH
	#define STR0001 "Lista de los Movimientos"
	#define STR0002 "   - Tipo de Saldo: "
	#define STR0003 "* Total de la Cuenta Presupuestaria *"
	#define STR0004 "* Total de la Fecha *"
	#define STR0005 "* Total de la Clase *"
	#define STR0006 "* Total Operacion *"
	#define STR0007 "* Total de la Clase Presupuestaria *"
	#define STR0008 "Cuenta Presupuestaria"
	#define STR0009 " - Período de: "
	#define STR0010 " a "
	#define STR0011 "Fch.Movim."
	#define STR0012 "Clase"
	#define STR0013 "Operacion"
	#define STR0014 "Historial"
	#define STR0015 "Proc."
	#define STR0016 "Valor"
	#define STR0017 "Este informe imprimira la Lista de Movimientos de acuerdo con los parametros solicitados por el usuario. Para mas informaciones sobre este informe consulte el Help del Programa ( F1 )."
	#define STR0018 "C.P.+Fecha"
	#define STR0019 "C.P.+Clase+Operacion"
	#define STR0020 "Clase+Operacion"
	#define STR0021 "Operacion"
	#define STR0022 "Fecha+C.P.+Clase+Operacion"
	#define STR0023 "Atencion"
	#define STR0024 "No existen datos para los parametros especificados."
	#define STR0025 "Movim. por "
	#define STR0026 "Tipo de Saldo no Informado. Verifique."
	#define STR0027 "Orden no informada. Verifique."
#else
	#ifdef ENGLISH
		#define STR0001 "List of Movements     "
		#define STR0002 "   -Balance type:   "
		#define STR0003 "* Budgetary Account Total     *"
		#define STR0004 "* Date total   *"
		#define STR0005 "* Class total     *"
		#define STR0006 "* Operation total*"
		#define STR0007 "* Budgetary Class Total        *"
		#define STR0008 "Budgetary Account "
		#define STR0009 " - Period from:"
		#define STR0010 " to"
		#define STR0011 "Movem.Dt."
		#define STR0012 "Class "
		#define STR0013 "Operation"
		#define STR0014 "History  "
		#define STR0015 "Proc."
		#define STR0016 "Value"
		#define STR0017 "This report will print the list of movements according to the parameters requested by the user. For more information about this report, query the Program Help (F1).                    "
		#define STR0018 "B.Ac+Date"
		#define STR0019 "B.Ac+Class+Operation"
		#define STR0020 "Class+Operation"
		#define STR0021 "Operat. "
		#define STR0022 "Date+B.Ac+Class+Operation"
		#define STR0023 "Attn.  "
		#define STR0024 "No data for the parameters entered. "
		#define STR0025 "Movements by"
		#define STR0026 "Balance type not informed. Check it."
		#define STR0027 "Order not informed. Check it out!"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Relação Dos Movimentos", "Relação dos Movimentos" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "   - tipo de saldo: ", "   - Tipo de Saldo: " )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "* total da conta orçamentária *", "* Total da Conta Orçamentária *" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "* total da data *", "* Total da Data *" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "* total da classe *", "* Total da Classe *" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "* total operação *", "* Total Operação *" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "* total da classe orçamentária *", "* Total da Classe Orçamentária *" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Conta Orçamental", "Conta Orçamentária" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", " – período de: ", " - Período de: " )
		#define STR0010 " a "
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Dt.movim.", "Dt.Movim." )
		#define STR0012 "Classe"
		#define STR0013 "Operação"
		#define STR0014 "Histórico"
		#define STR0015 "Proc."
		#define STR0016 "Valor"
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Este relatório ira imprimir a Relação de Movimentos de acordo com os parâmetros solicitados pelo usuário. Para mais informações sobre este relatorio consulte o Help do Programa ( F1 ).", "Este relatório irá imprimir a Relação de Movimentos de acordo com os parâmetros solicitados pelo usuário. Para mais informações sobre este relatório consulte o Help do Programa ( F1 )." )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "C.o.+data", "C.O.+Data" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "C.o.+classe+operação", "C.O.+Classe+Operação" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Classe+operação", "Classe+Operação" )
		#define STR0021 "Operação"
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Data+c.o.+classe+operação", "Data+C.O.+Classe+Operação" )
		#define STR0023 "Atenção"
		#define STR0024 "Não existem dados para os parâmetros especificados."
		#define STR0025 "Movimentos por "
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Tipo de saldo não informado. Verifique.", "Tipo de Saldo nao Informado. Verifique." )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Ordem não informada. Verifique!", "Ordem nao informada. Verifique!" )
	#endif
#endif
