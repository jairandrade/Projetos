#ifdef SPANISH
	#define STR0001 "Informe para abono"
	#define STR0002 "Se imprimira de acuerdo con los parametros solicitados por"
	#define STR0003 "el usuario."
	#define STR0004 "Matricula"
	#define STR0005 "Centro de costo"
	#define STR0006 "Nombre"
	#define STR0007 "Turno"
	#define STR0008 "A Rayas"
	#define STR0009 "Administracion"
	#define STR0011 "Cod Descripcion            Horas  Justificacion                Visto"
	#define STR0012 "Placa"
	#define STR0013 "Matr."
	#define STR0014 "Empleado"
	#define STR0015 "C.C: "
	#define STR0017 "Sucursal: "
	#define STR0018 "   Turno: "
	#define STR0019 "     C.C: "
	#define STR0020 "C.Costo+Nombre"
	#define STR0021 "Placa: "
	#define STR0022 "Matr.: "
	#define STR0023 "Empleado: "
	#define STR0024 "Previsto"
	#define STR0025 "Realizado"
	#define STR0026 "Fecha"
	#define STR0027 "Seleccione la opcion de impresion:"
	#define STR0028 "Por Periodo"
	#define STR0029 "Por Fechas"
	#define STR0030 "Proceso: "
	#define STR0031 "Periodo: "
	#define STR0032 "Procedim.: "
	#define STR0033 "Num. Pago: "
	#define STR0034 "Departamento"
	#define STR0035 "Depto: "
	#define STR0036 "Compensado"
	#define STR0037 "D.S.R"
	#define STR0038 "No trabajado"
#else
	#ifdef ENGLISH
		#define STR0001 "Report for Premium"
		#define STR0002 "It will be printed according to the parameters selected by"
		#define STR0003 "the User."
		#define STR0004 "Registration"
		#define STR0005 "Cost Center"
		#define STR0006 "Name"
		#define STR0007 "Shift"
		#define STR0008 "Z.Form"
		#define STR0009 "Management"
		#define STR0011 "Descript.Code            Hours Justification                 Checked"
		#define STR0012 "Reg. Nr."
		#define STR0013 "Reg."
		#define STR0014 "Employee"
		#define STR0015 "C.C: "
		#define STR0017 "Branch: "
		#define STR0018 " Shift: "
		#define STR0019 "    C.C: "
		#define STR0020 "C.Center+Name"
		#define STR0021 "Reg. Nr.: "
		#define STR0022 "Reg.: "
		#define STR0023 "Employee: "
		#define STR0024 "Estimated"
		#define STR0025 "Accomplished"
		#define STR0026 "Date"
		#define STR0027 "Select the printing option: "
		#define STR0028 "By Period"
		#define STR0029 "By Dates"
		#define STR0030 "Process: "
		#define STR0031 "Period: "
		#define STR0032 "Procedure: "
		#define STR0033 "Paym. Nbr.: "
		#define STR0034 "Department"
		#define STR0035 "Dep.: "
		#define STR0036 "Compensated"
		#define STR0037 "D.S.R"
		#define STR0038 "Not worked"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Relatório Para Autorizações", "Relatorio para Autorizacoes" )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "Será impresso de acordo com os parâmetros solicitados pelo", "Será impresso de acordo com os parametros solicitados pelo" )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Utilizador.", "usuario." )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Registo", "Matricula" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Centro De Custo", "Centro de Custo" )
		#define STR0006 "Nome"
		#define STR0007 "Turno"
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Código de barras", "Zebrado" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Administração", "Administracao" )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Cód. Descrição           Horas    Razão                      Visto", "Cod Descricao            Horas  Justificativa                Visto" )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Cartão Reg.", "Chapa" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Reg.", "Matr." )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Empregado", "Funcionario" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "C. C.:", "C.C: " )
		#define STR0017 "Filial: "
		#define STR0018 If( cPaisLoc $ "ANG|PTG", "Turno:", " Turno: " )
		#define STR0019 "    C.C: "
		#define STR0020 If( cPaisLoc $ "ANG|PTG", "C. Custo+ Nome", "C.Custo+Nome" )
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Número: ", "Chapa: " )
		#define STR0022 If( cPaisLoc $ "ANG|PTG", "Reg.:", "Matr.: " )
		#define STR0023 If( cPaisLoc $ "ANG|PTG", "Empregado:   ", "Funcionario: " )
		#define STR0024 "Previsto"
		#define STR0025 "Realizado"
		#define STR0026 "Data"
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Seleccionar a opção  de impressao: ", "Selecione a opção de impressão: " )
		#define STR0028 "Por Período"
		#define STR0029 "Por Datas"
		#define STR0030 "Processo: "
		#define STR0031 "Período: "
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Mapa: ", "Roteiro: " )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", "Num. pgt: ", "Num. Pagto: " )
		#define STR0034 "Departamento"
		#define STR0035 "Depto: "
		#define STR0036 "Compensado"
		#define STR0037 "D.S.R"
		#define STR0038 "Não trabalhado"
	#endif
#endif
