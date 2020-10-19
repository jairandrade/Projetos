#ifdef SPANISH
	#define STR0001 " SOLICITUD DE SEGURO - DESEMPLEO - S. D.  "
	#define STR0002 "Solicitud de Seguro - Desempleo - S. D."
	#define STR0003 "Sera impresa de acuerdo con los parametros solicitados por"
	#define STR0004 "el usuario."
	#define STR0005 "Matricula"
	#define STR0006 "Centro de Costo"
	#define STR0007 "A Rayas"
	#define STR0008 "Administracion"
	#define STR0009 "ANULADO POR EL OPERADOR . . . "
#else
	#ifdef ENGLISH
		#define STR0001 " UNEMPLOYMENT INSURANCE REQUEST - U.I. "
		#define STR0002 "Unemployment Insurance Request - U.I."
		#define STR0003 "It will be printed according to the parameters requested by"
		#define STR0004 "the user."
		#define STR0005 "Registration"
		#define STR0006 "Cost Center"
		#define STR0007 "Z.Form"
		#define STR0008 "Administration"
		#define STR0009 " CANCELLED BY THE OPERATOR . . . "
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", " requerimento de seguro-desemprego - s.d. ", " REQUERIMENTO DE SEGURO-DESEMPREGO - S.D. " )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Requerimento De Seguro-desemprego - S.d.", "Requerimento de Seguro-Desemprego - S.D." )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Sera impresso de acordo com os parâmetro s solicitados pelo", "Será impresso de acordo com os parametros solicitados pelo" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Utilizador.", "usuario." )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Matrícula", "Matricula" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Centro De Custo", "Centro de Custo" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Código de barras", "Zebrado" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Administração", "Administraçäo" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", " cancelado pelo operador . . . ", " CANCELADO PELO OPERADOR . . . " )
	#endif
#endif
