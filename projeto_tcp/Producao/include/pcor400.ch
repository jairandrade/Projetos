#ifdef SPANISH
	#define STR0001 "Lista de los Movimientos"
	#define STR0002 "   - Tipo de Saldo: "
	#define STR0003 "* Total de la Cuenta Presupuestaria *"
	#define STR0004 "* Total de la Fecha *"
	#define STR0005 "* Total de la Clase *"
	#define STR0006 "* Total Operacion *"
	#define STR0007 "* Total de la Clase Presupuestaria *"
	#define STR0008 "Cuenta Presupuestaria"
	#define STR0009 " - Per�odo de: "
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
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Rela��o Dos Movimentos", "Rela��o dos Movimentos" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "   - tipo de saldo: ", "   - Tipo de Saldo: " )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "* total da conta or�ament�ria *", "* Total da Conta Or�ament�ria *" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "* total da data *", "* Total da Data *" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "* total da classe *", "* Total da Classe *" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "* total opera��o *", "* Total Opera��o *" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "* total da classe or�ament�ria *", "* Total da Classe Or�ament�ria *" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Conta Or�amental", "Conta Or�ament�ria" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", " � per�odo de: ", " - Per�odo de: " )
		#define STR0010 " a "
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Dt.movim.", "Dt.Movim." )
		#define STR0012 "Classe"
		#define STR0013 "Opera��o"
		#define STR0014 "Hist�rico"
		#define STR0015 "Proc."
		#define STR0016 "Valor"
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Este relat�rio ira imprimir a Rela��o de Movimentos de acordo com os par�metros solicitados pelo usu�rio. Para mais informa��es sobre este relatorio consulte o Help do Programa ( F1 ).", "Este relat�rio ir� imprimir a Rela��o de Movimentos de acordo com os par�metros solicitados pelo usu�rio. Para mais informa��es sobre este relat�rio consulte o Help do Programa ( F1 )." )
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "C.o.+data", "C.O.+Data" )
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "C.o.+classe+opera��o", "C.O.+Classe+Opera��o" )
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "Classe+opera��o", "Classe+Opera��o" )
		#define STR0021 "Opera��o"
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Data+c.o.+classe+opera��o", "Data+C.O.+Classe+Opera��o" )
		#define STR0023 "Aten��o"
		#define STR0024 "N�o existem dados para os par�metros especificados."
		#define STR0025 "Movimentos por "
		#define STR0026 If( cPaisLoc $ "ANG|PTG", "Tipo de saldo n�o informado. Verifique.", "Tipo de Saldo nao Informado. Verifique." )
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Ordem n�o informada. Verifique!", "Ordem nao informada. Verifique!" )
	#endif
#endif
