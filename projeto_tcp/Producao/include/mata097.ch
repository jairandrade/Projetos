#ifdef SPANISH
	#define STR0001 "Buscar"
	#define STR0002 "Consulta pedido"
	#define STR0003 "Visualizar"
	#define STR0004 "Aprobar"
	#define STR0005 "Superior"
	#define STR0006 "Aprobacion de PC"
	#define STR0007 "Diario"
	#define STR0008 "Semanal"
	#define STR0009 "Mensual"
	#define STR0010 "VISTO / LIBRE"
	#define STR0011 "Aprobacion de PC"
	#define STR0012 "Num.de Pedido "
	#define STR0013 "Emision "
	#define STR0014 "Proveedor "
	#define STR0015 "Aprobador "
	#define STR0016 "Fecha de ref. "
	#define STR0017 "Limite min.  "
	#define STR0018 "Limite max. "
	#define STR0019 "Limite  "
	#define STR0020 "Tipo lim."
	#define STR0021 "Saldo en la fecha "
	#define STR0022 "Total del pedido "
	#define STR0023 "Saldo disponible despues de aprobacion"
	#define STR0024 "Aprueba pedido"
	#define STR0025 "Anular"
	#define STR0026 "Bloquea pedido"
	#define STR0027 " Informe la clave para el siguiente usuario."
	#define STR0028 " Usuario "
	#define STR0029 "Nombre:"
	#define STR0030 "Clave :"
	#define STR0031 "&Ok"
	#define STR0032 "&Anular"
	#define STR0033 "Observaciones"
	#define STR0034 "Consulta saldos"
	#define STR0035 "Acceso restricto"
	#define STR0036 "El acceso y el uso de esta rutina se destina solo a usuarios vinculados al proceso de aprobacion de pedidos de compras definido por los grupos de aprobacion. Usuario sin permiso para utilizar esta rutina.  "
	#define STR0037 "Volver"
	#define STR0038 "�Atencion!"
	#define STR0039 "Este pedido ya fue liberado. Solamente los pedidos que estan esperando liberacion(color rojo en la ventana) podran liberarse."
	#define STR0040 "Saldo insuficiente"
	#define STR0041 "Saldo insuficiente en la fecha para efectuar la liberacion del pedido. Verifique el saldo disponible para aprobacion en la fecha y el valor total del pedido."
	#define STR0042 "Limite maximo insuficiente"
	#define STR0043 "El valor total del pedido sobrepaso el limite maximo de aprobacion por pedido y no puede ser liberado. Verifique el valor total del pedido y el limite maximo por aprobacion ."
	#define STR0044 "Superior no archivado"
	#define STR0045 "Aprobador superior no registrado para efectuar esta operacion. Verifique el archivo de aprobadores. "
	#define STR0046 "Diario"
	#define STR0047 "Semanal"
	#define STR0048 "Mensual"
	#define STR0049 "Clave no valida"
	#define STR0050 "Verifique la clave informada. Informe la clave correcta."
	#define STR0051 "Esta operacion revierte todos los niveles y aprobaciones anteriores y crea todo el proceso de aprobacion del pedido de compras nuevamente. Todas las aprobaciones efectuadas seran perdidas. �Confirma la reversion? "
	#define STR0052 "Anular"
	#define STR0053 "Confirma"
	#define STR0054 "Reversion"
	#define STR0055 "Transf. Superior"
	#define STR0056 "Transferir"
	#define STR0057 "Bloqueado (Esperando otros niveles)"
	#define STR0058 "Esperando aprobacion del usuario"
	#define STR0059 "Pedido liberado por el usuario"
	#define STR0060 "Pedido bloqueado por el usuario"
	#define STR0061 "Pedido liberado por otro usuario"
	#define STR0062 "Leyenda"
	#define STR0063 "Especifico"
	#define STR0064 "Anual"
	#define STR0065 "Divergencia"
	#define STR0066 "Cantidad"
	#define STR0067 "Ctd./Precio"
	#define STR0068 "Precio         "
	#define STR0069 "OK              "
	#define STR0070 "Sin Pedido"
	#define STR0071 "�Confirma la fecha de referencia MENOR que la fecha del pedido?"
	#define STR0072 "Si"
	#define STR0073 "No"
	#define STR0074 "Ausencia Tempor."
	#define STR0075 "Al confirmar este proceso todas las aprobaciones pendientes del aprobador se transferiran al aprobador superior. �Confirma la Transferencia? "
	#define STR0076 "Transferencia por Ausencia Temporal de Aprobadores"
	#define STR0077 "Aprobador Ausente "
	#define STR0078 "Aprobador Superior"
	#define STR0079 "Transferir"
	#define STR0080 "Anular  "
	#define STR0081 "Tranferido por Ausencia"
	#define STR0082 "Para utilizar esta opcion es necesario que exista como minimo un aprobador con un superior registrado"
	#define STR0083 "Esta operacion no podra realizarse pues este registro se encuentra bloqueado por el sistema (esperando otros niveles)"
	#define STR0084 "No existen registros para transferirse."
	#define STR0085 "Leyenda"
	#define STR0086 "Atencion: existe mas de un Aprobador Ausente para el Aprobador Superior"
	#define STR0087 "No se encontro el aprobador en el grupo de aprobacion de este documento, verifique y si fuera necesario, incluya nuevamente el aprobador en el grupo de aprobacion "
	#define STR0088 "Enviando aprobacion al portal..."
	#define STR0089 "CAAS"
	#define STR0090 "Verifique la configuracion del parametro: MV_OGPAPRV si no quiere hacer obligatoria la existencia del aprobador en el grupo de aprobacion."
	#define STR0091 "Total del documento, convertido en "
#else
	#ifdef ENGLISH
		#define STR0001 "Search"
		#define STR0002 "View Order"
		#define STR0003 "View"
		#define STR0004 "Approve"
		#define STR0005 "Superior"
		#define STR0006 "PO Release"
		#define STR0007 "Daily"
		#define STR0008 "Weekly"
		#define STR0009 "Monthly"
		#define STR0010 "VISA/RELEASED"
		#define STR0011 "Release of document"
		#define STR0012 "Document number"
		#define STR0013 "Issue"
		#define STR0014 "Vendor"
		#define STR0015 "Approver "
		#define STR0016 "Reference Date"
		#define STR0017 "Min. Limit "
		#define STR0018 "Max. Limit "
		#define STR0019 "Limit   "
		#define STR0020 "Limit Type"
		#define STR0021 "Balance in Date"
		#define STR0022 "Total of Order"
		#define STR0023 "Available Balance after Approval"
		#define STR0024 "Approve Order"
		#define STR0025 "Cancel  "
		#define STR0026 "Block Order    "
		#define STR0027 " Enter a password to the following User. "
		#define STR0028 " User    "
		#define STR0029 "Name :"
		#define STR0030 "Password:"
		#define STR0031 "&OK"
		#define STR0032 "&Cancel "
		#define STR0033 "Notes"
		#define STR0034 "Search Balances"
		#define STR0035 "Restrict Access"
		#define STR0036 "Access/Utilization of this routine allowed only to users involved in Purchase Orders approving process, defined by approval groups. User has no permission to use this routine.  "
		#define STR0037 "Back"
		#define STR0038 "Warning!"
		#define STR0039 "This order has been already released. Only awaiting orders (highlighted in red into Browse) can be released."
		#define STR0040 "Insufficient Balance"
		#define STR0041 "Insufficient balance on this date to execute the order release. Please check the available balance for this date and total order value."
		#define STR0042 "Insufficient Maximum Limit"
		#define STR0043 "Total order value has exceeded the approval`s Maximum Limit per order and can not be released. Please check the total order and the Maximum Limit by approval."
		#define STR0044 "Superior not registered"
		#define STR0045 "Superior Approver not registered. Please check the Approvers File. "
		#define STR0046 "Daily"
		#define STR0047 "Weekly"
		#define STR0048 "Monthly"
		#define STR0049 "Invalid Password"
		#define STR0050 "Please check if the entered password is correct."
		#define STR0051 "This operation reverses all previous approval levels and recreate the whole Purchase Order approving process. All approbations will be lost. OK to reverse ? "
		#define STR0052 "Cancel"
		#define STR0053 "Confirm"
		#define STR0054 "Reverse"
		#define STR0055 "Transf. Superior"
		#define STR0056 "Transfer"
		#define STR0057 "Blocked (Waiting for other levels)"
		#define STR0058 "Waiting for user release"
		#define STR0059 "Order released by the user"
		#define STR0060 "Order Blocked by the user"
		#define STR0061 "Order Released by another user"
		#define STR0062 "Caption"
		#define STR0063 "Specific  "
		#define STR0064 "Yearly"
		#define STR0065 "Diverg�nce "
		#define STR0066 "Quantity  "
		#define STR0067 "Qtty/Price"
		#define STR0068 "Price         "
		#define STR0069 "OK              "
		#define STR0070 "No order  "
		#define STR0071 "Confirm reference date LOWER than order date? "
		#define STR0072 "Yes"
		#define STR0073 "No "
		#define STR0074 "Temporary Absence"
		#define STR0075 "When confirming this process, all the approver's pending approvals will be transferred to the higher approver. Confirm Transfer? "
		#define STR0076 "Transfer due to Approvers' Temporary Absence "
		#define STR0077 "Approver Absent "
		#define STR0078 "Higher Approver "
		#define STR0079 "Transfer  "
		#define STR0080 "Cancel  "
		#define STR0081 "Tranferred due to absence"
		#define STR0082 "To use this option, there must be at least one approver with a superior registered "
		#define STR0083 "This operation cannot be completed because this record is blocked by the system (waiting for other levels) "
		#define STR0084 "No records to be transferred. "

		#define STR0085 "Caption"
		#define STR0086 "Attention: there is more than one Absent Approver for the Superior Approver"
		#define STR0087 "Approver was not found in approval group of this document. Check it and, if necessary, include the approver again in the approval group "
		#define STR0088 "Sending approval to portal"
		#define STR0089 "CAAS"
		#define STR0090 "Check the configuration of the parameter: MV_OGPAPRV if you do not want to make approver existence mandatory in approval group."
		#define STR0091 "Total of the document, converted into"
	#else
		#define STR0001  "Pesquisar"
		Static STR0002 := "Consulta docto"
		#define STR0003  "Visualizar"
		Static STR0004 := "Liberar"
		#define STR0005  "Superior"
		Static STR0006 := "Liberac�o do Documento"
		Static STR0007 := "Diario"
		#define STR0008  "Semanal"
		#define STR0009  "Mensal"
		Static STR0010 := "VISTO / LIVRE"
		Static STR0011 := "Liberac�o do Docto"
		Static STR0012 := "Numero do Docto"
		Static STR0013 := "Emiss�o "
		Static STR0014 := "Fonecedor "
		Static STR0015 := "Aprovador "
		#define STR0016  "Data de ref.  "
		Static STR0017 := "Limite min.  "
		Static STR0018 := "Limite max. "
		#define STR0019  "Limite  "
		Static STR0020 := "Tipo lim."
		#define STR0021  "Saldo na data  "
		#define STR0022  "Total do documento  "
		Static STR0023 := "Saldo disponivel apos liberac�o  "
		Static STR0024 := "Libera Docto"
		#define STR0025  "Cancelar"
		Static STR0026 := "Bloqueia Docto"
		Static STR0027 := " Digite a senha para o usuario a seguir."
		Static STR0028 := " Usuario "
		#define STR0029  "Nome :"
		Static STR0030 := "Senha :"
		Static STR0031 := "&Ok"
		Static STR0032 := "&Cancela"
		Static STR0033 := "Observacoes"
		Static STR0034 := "cOnsulta Saldos"
		#define STR0035  "Acesso Restrito"
		Static STR0036 := "O  acesso  e  a utilizac�o desta rotina e destinada apenas aos usuarios envolvidos no processo de aprovacao de Documentos de Compras definido pelos grupos de aprovac�o. Usuario sem permiss�o para utilizar esta rotina.  "
		Static STR0037 := "Voltar"
		Static STR0038 := "Atenc�o!"
		Static STR0039 := "Este documento ja foi liberado anteriormente. Somente os documentos que estao aguardando liberacao (destacado em vermelho no Browse) poderao ser liberados."
		#define STR0040  "Saldo Insuficiente"
		Static STR0041 := "Saldo na data insuficiente para efetuar a liberac�o do documento. Verifique o saldo disponivel para aprovac�o na data e o valor total do documento."
		Static STR0042 := "Limite Maximo Insuficiente"
		Static STR0043 := "O valor total do documento ultrapassou o Limite Maximo de aprovac�o por documento e n�o pode ser liberado. Verifique o valor total do documento e o Limite Maximo por aprovac�o ."
		Static STR0044 := "Superior n�o cadastrado"
		Static STR0045 := "Aprovador Superior n�o cadastrado para efetuar esta operac�o. Verifique o cadastro de aprovadores. "
		Static STR0046 := "Diario"
		#define STR0047  "Semanal"
		#define STR0048  "Mensal"
		Static STR0049 := "Senha Invalida"
		Static STR0050 := "Verifique a senha digitada. Digite a senha correta."
		Static STR0051 := "Esta operac�o estorna todos os niveis e aprovac�es anteriores e cria todo o processo de aprovac�o do documento de compras novamente. Todas as Aprovacoes efetuadas ser�o perdidas. Confirma o estorno ? "
		#define STR0052  "Cancelar"
		#define STR0053  "Confirma"
		#define STR0054  "Estornar"
		#define STR0055  "Transf. Superior"
		#define STR0056  "Transferir"
		Static STR0057 := "Bloqueado (Aguardando outros niveis)"
		Static STR0058 := "Aguardando Liberac�o do usuario"
		Static STR0059 := "Documento Liberado pelo usuario"
		Static STR0060 := "Documento Bloqueado pelo usuario"
		Static STR0061 := "Documento Liberado por outro usuario"
		Static STR0062 := "Le&genda"
		#define STR0063  "Especifico"
		#define STR0064  "Anual"
		#define STR0065  "Diverg�ncia"
		#define STR0066  "Quantidade"
		Static STR0067 := "Qtde/Pre�o"
		Static STR0068 := "Pre�o         "
		Static STR0069 := "OK              "
		#define STR0070  "Sem Pedido"
		Static STR0071 := "Confirma a data de refer�ncia MENOR que a data do pedido?"
		#define STR0072  "Sim"
		#define STR0073  "N�o"
		Static STR0074 := "Ausencia Tempor."
		Static STR0075 := "Ao confirmar este processo todas aprova��es pendentes do aprovador ser�o transferidas ao aprovador superior. Confirma a Transfer�ncia ? "
		Static STR0076 := "Transferencia por Ausencia Temporaria de Aprovadores"
		Static STR0077 := "Aprovador Ausente "
		Static STR0078 := "Aprovador Superior"
		#define STR0079  "Transferir"
		#define STR0080  "Cancelar  "
		Static STR0081 := "Transferido por Ausencia"
		Static STR0082 := "Para utilizar esta op��o � necessario que exista no minimo um aprovador com um superior cadastrado"
		Static STR0083 := "Esta opera��o n�o poder� ser realizada pois este registro se encontra bloqueado pelo sistema (aguardando outros niveis)"
		Static STR0084 := "N�o existem registros para serem transferidos."
		Static STR0085 := "Legenda"
		Static STR0086 := "Atencao: existe mais de um Aprovador Ausente para o Aprovador Superior"
		Static STR0087 := "O aprovador n�o foi encontrado no grupo de aprova��o deste documento, verifique e se necess�rio inclua novamente o aprovador no grupo de aprova��o "
		Static STR0088 := "Aguarde, comunicando aprova��o ao portal..."
		Static STR0089 := "Portal ACC"
		#define STR0090  "Verifique a configura��o do par�metro: MV_OGPAPRV caso n�o queira tornar obrigat�rio a exist�ncia do aprovador no grupo de aprova��o."
		#define STR0091  "Total do documento, convertido em "
	#endif
#endif

#ifndef SPANISH
#ifndef ENGLISH
	STATIC uInit := __InitFun()

	Static Function __InitFun()
	uInit := Nil
	If Type('cPaisLoc') == 'C'

		If cPaisLoc == "ANG"
			STR0002 := "Consulta documento"
			STR0004 := "Autorizar "
			STR0006 := "Autoriza��o do Documento"
			STR0007 := "Di�rio"
			STR0010 := "Visto / Livre"
			STR0011 := "Autor. do Docto"
			STR0012 := "N�mero Do Documento"
			STR0013 := "Emiss�o "
			STR0014 := "Fornecedor "
			STR0015 := "Administrador "
			STR0017 := "Limite m�n.  "
			STR0018 := "Limite m�x. "
			STR0020 := "Tipo de lim."
			STR0023 := "Saldo dispon�vel ap�s aut.  "
			STR0024 := "Autor. Docto"
			STR0026 := "Bloqueia Documento"
			STR0027 := " digite a senha para o utilizador a seguir."
			STR0028 := " utilizador "
			STR0030 := "Palavra-passe :"
			STR0031 := "&ok"
			STR0032 := "&cancelar"
			STR0033 := "Observa��es"
			STR0034 := "Consulta De Saldos"
			STR0036 := "O  acesso  e  a utiliza��o deste procedimento � destinada apenas aos utilizadors envolvidos no processo de aprova��o de documentos de compras definido pelos grupos de aprova��o. o utilizador n�o tem permiss�o para utilizar este procedimento.  "
			STR0037 := "Voltar atr�s"
			STR0038 := "Aten��o!"
			STR0039 := "Este documento j� foi autorizado anteriormente. s� os documentos que est�o a aguardar libera��o (destacado em vermelho no browse) poder�o ser autorizados."
			STR0041 := "O saldo na data actual � insuficiente para efectuar a libera��o do documento. verifique o saldo dispon�vel para aprova��o na data e o valor total do documento."
			STR0042 := "Limite M�ximo Insuficiente"
			STR0043 := "O valor total do documento ultrapassou o limite m�ximo de aprova��o por documento e n�o pode ser autorizado. verifique o valor total do documento e o limite m�ximo por aprova��o ."
			STR0044 := "Superior n�o registado"
			STR0045 := "O administrador superior n�o est� registado para efectuar esta opera��o. verifique o registo de aprovadores. "
			STR0046 := "Di�rio"
			STR0049 := "Senha Inv�lida"
			STR0050 := "Verifique a senha digitada. digite a senha correcta."
			STR0051 := 'ESta opera��o estorna todos os n�veis e aprova��es anteriores e cria todo o processo de aprova��o do documento de compras novamente. Todas as Aprova��es efectuadas ser�o perdidas. Confirma o estorno ?'
			STR0057 := "Bloqueado (a aguardar outros n�veis)"
			STR0058 := "A aguardar autoriza��o do utilizador"
			STR0059 := "Documento autorizado pelo utilizador"
			STR0060 := "Documento bloqueado pelo utilizador"
			STR0061 := "Documento autorizado por outro utilizador"
			STR0062 := "Legenda"
			STR0067 := "Qtde/preco"
			STR0068 := "Preco         "
			STR0069 := "Ok              "
			STR0071 := "Confirmar a data de refer�ncia menor que a data do pedido?"
			STR0074 := "Aus�ncia Tempor."
			STR0075 := "Ao confirmar este processo todas as aprova��es pendentes do quem autoriza ser�o transferidas ao quem autoriza superior. confirmar a transfer�ncia ? "
			STR0076 := "Transfer�ncia Por Aus�ncia Tempor�ria De Quem Autorizaes"
			STR0077 := "Quem autoriza ausente "
			STR0078 := "Quem Autoriza Superior"
			STR0081 := "Tranferido Por Aus�ncia"
			STR0082 := "Para utilizar esta op��o � necess�rio que exista no m�nimo um quem autoriza com um superior registado"
			STR0083 := "Esta opera��o n�o poder� ser realizada pois este registo se encontra bloqueado pelo sistema (aguardando outros n�veis)"
			STR0084 := 'N�o existem registos para serem transferidos.'
			STR0085 := "legenda"
			STR0086 := "Aten��o: existe mais de um Aprovador Ausente para o Aprovador Superior"
			STR0087 := "O autorizador n�o foi encontrado no grupo de aprova��o deste documento, verifique e se necess�rio incluir novamente o autorizador no grupo de aprova��o "
			STR0088 := "A enviae aprova��o ao portal..."
			STR0089 := "CAAS"
		ElseIf cPaisLoc == "PTG"
			STR0002 := "Consulta documento"
			STR0004 := "Autorizar "
			STR0006 := "Autoriza��o do Documento"
			STR0007 := "Di�rio"
			STR0010 := "Visto / Livre"
			STR0011 := "Autor. do Docto"
			STR0012 := "N�mero Do Documento"
			STR0013 := "Emiss�o "
			STR0014 := "Fornecedor "
			STR0015 := "Administrador "
			STR0017 := "Limite m�n.  "
			STR0018 := "Limite m�x. "
			STR0020 := "Tipo de lim."
			STR0023 := "Saldo dispon�vel ap�s aut.  "
			STR0024 := "Autor. Docto"
			STR0026 := "Bloqueia Documento"
			STR0027 := " digite a senha para o utilizador a seguir."
			STR0028 := " utilizador "
			STR0030 := "Palavra-passe :"
			STR0031 := "&ok"
			STR0032 := "&cancelar"
			STR0033 := "Observa��es"
			STR0034 := "Consulta De Saldos"
			STR0036 := "O  acesso  e  a utiliza��o deste procedimento � destinada apenas aos utilizadors envolvidos no processo de aprova��o de documentos de compras definido pelos grupos de aprova��o. o utilizador n�o tem permiss�o para utilizar este procedimento.  "
			STR0037 := "Voltar atr�s"
			STR0038 := "Aten��o!"
			STR0039 := "Este documento j� foi autorizado anteriormente. s� os documentos que est�o a aguardar libera��o (destacado em vermelho no browse) poder�o ser autorizados."
			STR0041 := "O saldo na data actual � insuficiente para efectuar a libera��o do documento. verifique o saldo dispon�vel para aprova��o na data e o valor total do documento."
			STR0042 := "Limite M�ximo Insuficiente"
			STR0043 := "O valor total do documento ultrapassou o limite m�ximo de aprova��o por documento e n�o pode ser autorizado. verifique o valor total do documento e o limite m�ximo por aprova��o ."
			STR0044 := "Superior n�o registado"
			STR0045 := "O administrador superior n�o est� registado para efectuar esta opera��o. verifique o registo de aprovadores. "
			STR0046 := "Di�rio"
			STR0049 := "Senha Inv�lida"
			STR0050 := "Verifique a senha digitada. digite a senha correcta."
			STR0051 := 'ESta opera��o estorna todos os n�veis e aprova��es anteriores e cria todo o processo de aprova��o do documento de compras novamente. Todas as Aprova��es efectuadas ser�o perdidas. Confirma o estorno ?'
			STR0057 := "Bloqueado (a aguardar outros n�veis)"
			STR0058 := "A aguardar autoriza��o do utilizador"
			STR0059 := "Documento autorizado pelo utilizador"
			STR0060 := "Documento bloqueado pelo utilizador"
			STR0061 := "Documento autorizado por outro utilizador"
			STR0062 := "Legenda"
			STR0067 := "Qtde/preco"
			STR0068 := "Preco         "
			STR0069 := "Ok              "
			STR0071 := "Confirmar a data de refer�ncia menor que a data do pedido?"
			STR0074 := "Aus�ncia Tempor."
			STR0075 := "Ao confirmar este processo todas as aprova��es pendentes do quem autoriza ser�o transferidas ao quem autoriza superior. confirmar a transfer�ncia ? "
			STR0076 := "Transfer�ncia Por Aus�ncia Tempor�ria De Quem Autorizaes"
			STR0077 := "Quem autoriza ausente "
			STR0078 := "Quem Autoriza Superior"
			STR0081 := "Tranferido Por Aus�ncia"
			STR0082 := "Para utilizar esta op��o � necess�rio que exista no m�nimo um quem autoriza com um superior registado"
			STR0083 := "Esta opera��o n�o poder� ser realizada pois este registo se encontra bloqueado pelo sistema (aguardando outros n�veis)"
			STR0084 := 'N�o existem registos para serem transferidos.'
			STR0085 := "legenda"
			STR0086 := "Aten��o: existe mais de um Aprovador Ausente para o Aprovador Superior"
			STR0087 := "O autorizador n�o foi encontrado no grupo de aprova��o deste documento, verifique e se necess�rio incluir novamente o autorizador no grupo de aprova��o "
			STR0088 := "A enviae aprova��o ao portal..."
			STR0089 := "CAAS"
		EndIf
		EndIf
	Return Nil
#ENDIF
#ENDIF
