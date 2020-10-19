#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �REFI063J  �Autor  � Kaique Sousa      � Data �  07/05/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � ROTINA PARA VALIDAR A POSITIVACAO OU NEGATIVACAO DE UM     ���
���          � TITULO.                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
			aAdd( _aDet , {&(cTitul),'T�tulo n�o Negativado !','N�O POSITIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN = 'N' .AND. SE1->E1_STPEFIN = ' '
			aAdd( _aDet , {&(cTitul),'Estava marcado para Negativa��o','POSITIVADO'})
			_lResult	:= .T.
		Case SE1->E1_ACPEFIN $ 'AN' .AND. SE1->E1_STPEFIN = '1'
			aAdd( _aDet , {&(cTitul),'Aguardando Retorno de Negativa��o','N�O POSITIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN = 'O' .AND. SE1->E1_STPEFIN $ '2' .AND. SE1->E1_SALDO > 0
			aAdd( _aDet , {&(cTitul),'Ainda n�o foi pago','POSITIVADO'})
			_lResult	:= .T.
		Case SE1->E1_ACPEFIN = 'O' .AND. SE1->E1_STPEFIN $ '2' .AND. SE1->E1_SALDO <= 0
			aAdd( _aDet , {&(cTitul),'T�tulo j� Pago, ser� enviado automaticamente !','N�O POSITIVADO'})
			_lResult	:= .T.
		Case SE1->E1_ACPEFIN = 'O' .AND. SE1->E1_STPEFIN $ '3'
			aAdd( _aDet , {&(cTitul),'Aguardando Retorno de Positiva��o','N�O POSITIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN = 'I' .AND. SE1->E1_STPEFIN $ '4'
			aAdd( _aDet , {&(cTitul),'T�tulo j� Positivado','N�O POSITIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN + SE1->E1_STPEFIN $ 'I1/I2/N2/O1/O4'
			aAdd( _aDet , {&(cTitul),'Situa��o n�o reconhecida !','N�O POSITIVADO'})
			_lResult	:= .F.
		OtherWise
			aAdd( _aDet , {&(cTitul),'N�o necessita Positiva��o','N�O POSITIVADO'})
	EndCase
ElseIf _cAcao = 'I'       			//Inclusao - Negativacao
	Do Case
		Case SE1->E1_ACPEFIN $ ' I' .AND. SE1->E1_STPEFIN = ' '
			aAdd( _aDet , {&(cTitul),'T�tulo em Aberto Vencido !','NEGATIVADO'})
			_lResult	:= .T.
		Case SE1->E1_ACPEFIN = 'N' .AND. SE1->E1_STPEFIN = ' '
			aAdd( _aDet , {&(cTitul),'J� marcado para Negativa��o','N�O NEGATIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN $ 'AN' .AND. SE1->E1_STPEFIN = '1'
			aAdd( _aDet , {&(cTitul),'Aguardando Retorno de Negativa��o','N�O NEGATIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN = 'O' .AND. SE1->E1_STPEFIN $ '2' .AND. SE1->E1_SALDO > 0
			aAdd( _aDet , {&(cTitul),'j� Negativado','N�O NEGATIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN = 'O' .AND. SE1->E1_STPEFIN $ '2' .AND. SE1->E1_SALDO <= 0
			aAdd( _aDet , {&(cTitul),'T�tulo j� Pago','N�O NEGATIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN = 'O' .AND. SE1->E1_STPEFIN $ '3'
			aAdd( _aDet , {&(cTitul),'Aguardando Retorno de Positiva��o','N�O NEGATIVADO'})
			_lResult	:= .F.
		Case SE1->E1_ACPEFIN = 'I' .AND. SE1->E1_STPEFIN $ '4'
			aAdd( _aDet , {&(cTitul),'T�tulo j� Positivado','NEGATIVADO'})
			_lResult	:= .T.
		Case SE1->E1_ACPEFIN + SE1->E1_STPEFIN $ 'I1/I2/N2/O1/O4'
			aAdd( _aDet , {&(cTitul),'Situa��o n�o reconhecida !','N�O NEGATIVADO'})
			_lResult	:= .F.
		OtherWise
			aAdd( _aDet , {&(cTitul),'N�o necessita Negativa��o','N�O NEGATIVADO'})
	EndCase
EndIf

Return( _lResult )
