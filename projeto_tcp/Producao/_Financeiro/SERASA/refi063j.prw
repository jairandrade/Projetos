#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³REFI063J  ºAutor  ³ Kaique Sousa      º Data ³  07/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ ROTINA PARA VALIDAR A POSITIVACAO OU NEGATIVACAO DE UM     º±±
±±º          ³ TITULO.                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function REFI063J(_nReg,_cAcao,_aDet)

Local _lResult		:= .F.
Local cTitul		:= "'[' + SE1->E1_FILIAL + '] ' + SE1->E1_PREFIXO + '/' + SE1->E1_NUM + '/' + SE1->E1_PARCELA + '/' + SE1->E1_TIPO + ' Cli: ' + SE1->E1_CLIENTE + '/' + SE1->E1_LOJA"

Default _cAcao		:= 'E'
Default _aDet		:= {}

//Posiciona o registro caso nao esteja.
If SE1->(Recno()) <> _nReg
	SE1->(DbGoTo(_nReg))
EndIf

If _cAcao = 'E'  		//Exclusao - Positivacao
	Do Case
		Case SE1->E1_ACPEFIN $ ' I' .AND. SE1->E1_STPEFIN = ' '
			aAdd( _aDet , {&(cTitul),'Título não Negativado !','NÃO POSITIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN = 'N' .AND. SE1->E1_STPEFIN = ' '
			aAdd( _aDet , {&(cTitul),'Estava marcado para Negativação','POSITIVADO'})
			_lResult	:= .T.
		Case SE1->E1_ACPEFIN $ 'AN' .AND. SE1->E1_STPEFIN = '1'
			aAdd( _aDet , {&(cTitul),'Aguardando Retorno de Negativação','NÃO POSITIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN = 'O' .AND. SE1->E1_STPEFIN $ '2' .AND. SE1->E1_SALDO > 0
			aAdd( _aDet , {&(cTitul),'Ainda não foi pago','POSITIVADO'})
			_lResult	:= .T.
		Case SE1->E1_ACPEFIN = 'O' .AND. SE1->E1_STPEFIN $ '2' .AND. SE1->E1_SALDO <= 0
			aAdd( _aDet , {&(cTitul),'Título já Pago, será enviado automaticamente !','NÃO POSITIVADO'})
			_lResult	:= .T.
		Case SE1->E1_ACPEFIN = 'O' .AND. SE1->E1_STPEFIN $ '3'
			aAdd( _aDet , {&(cTitul),'Aguardando Retorno de Positivação','NÃO POSITIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN = 'I' .AND. SE1->E1_STPEFIN $ '4'
			aAdd( _aDet , {&(cTitul),'Título já Positivado','NÃO POSITIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN + SE1->E1_STPEFIN $ 'I1/I2/N2/O1/O4'
			aAdd( _aDet , {&(cTitul),'Situação não reconhecida !','NÃO POSITIVADO'})
			_lResult	:= .F.
		OtherWise
			aAdd( _aDet , {&(cTitul),'Não necessita Positivação','NÃO POSITIVADO'})
	EndCase
ElseIf _cAcao = 'I'       			//Inclusao - Negativacao
	Do Case
		Case SE1->E1_ACPEFIN $ ' I' .AND. SE1->E1_STPEFIN = ' '
			aAdd( _aDet , {&(cTitul),'Título em Aberto Vencido !','NEGATIVADO'})
			_lResult	:= .T.
		Case SE1->E1_ACPEFIN = 'N' .AND. SE1->E1_STPEFIN = ' '
			aAdd( _aDet , {&(cTitul),'Já marcado para Negativação','NÃO NEGATIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN $ 'AN' .AND. SE1->E1_STPEFIN = '1'
			aAdd( _aDet , {&(cTitul),'Aguardando Retorno de Negativação','NÃO NEGATIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN = 'O' .AND. SE1->E1_STPEFIN $ '2' .AND. SE1->E1_SALDO > 0
			aAdd( _aDet , {&(cTitul),'jÁ Negativado','NÃO NEGATIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN = 'O' .AND. SE1->E1_STPEFIN $ '2' .AND. SE1->E1_SALDO <= 0
			aAdd( _aDet , {&(cTitul),'Título já Pago','NÃO NEGATIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN = 'O' .AND. SE1->E1_STPEFIN $ '3'
			aAdd( _aDet , {&(cTitul),'Aguardando Retorno de Positivação','NÃO NEGATIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN = 'I' .AND. SE1->E1_STPEFIN $ '4'
			aAdd( _aDet , {&(cTitul),'Título já Positivado','NEGATIVADO'})
			_lResult	:= .T.
		Case SE1->E1_ACPEFIN + SE1->E1_STPEFIN $ 'I1/I2/N2/O1/O4'
			aAdd( _aDet , {&(cTitul),'Situação não reconhecida !','NÃO NEGATIVADO'})
			_lResult	:= .F.
		OtherWise
			aAdd( _aDet , {&(cTitul),'Não necessita Negativação','NÃO NEGATIVADO'})
	EndCase
EndIf

Return( _lResult )
