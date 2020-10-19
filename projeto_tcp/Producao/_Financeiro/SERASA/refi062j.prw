#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'

#DEFINE   CR   Chr(13)+Chr(10)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �REFI062J  �Autor  � Kaique Sousa      � Data �  06/03/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �MARCA O REGISTRO PARA EXCLUSAO (POSITIVACAO).               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function REFI062J(_cMarca)

Local _aArea		:= GetArea()
Local _lSele		:= .F.
Local _nSele		:= 0
Local _nAviso		:= 1
Local _aDet			:= {}
Local _cMotivo		:= ''

While !_lSele
	
	If ConPad1(,,,'ZP2',,,.F.)
		
		_cMotivo 	:= ZP2->ZP2_COD
		_nSele 		:= Aviso('Aten��o','Motivo '+ _cMotivo + '-' + Posicione('ZP2',1,xFilial('ZP2')+_cMotivo+'001','ZP2_DESCRI'),{'Mot.','N�o','Sim'},,'Confirma Positiva��o ?')
		
		If _nSele = 3
			Processa({|| S062JPROC(_cMotivo,@_aDet)},'Positivar Titulos','Marcando registros...',.F.)
			While _nAviso = 1
				_nAviso := 0
				_nAviso := Aviso('Aten��o','Opera��o realizada com sucesso !',{'Log','OK'},,'Positiva��o Realizada')
				If _nAviso = 1
					U_REFI045J(_aDet,"Log da Positiva��o")
				EndIf
			EndDo
			_lSele := .T.
		ElseIf _nSele = 2
			_lSele := .T.
		EndIf
	Else
		_lSele := .T.
	EndIf
	
EndDo

RestArea(_aArea)

Return( Nil )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �062JPROC  �Autor  � Kaique Sousa      � Data �  06/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �PROCESSA OS REGISTROS MARCANDO PARA POSITIVACAO.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function S062JPROC(_cMotivo,_aDet)

Local _cMsgi		:= ''
Local _nReg			:= 0
Local _nProc		:= 0
Local _lPosit		:= .F.

Default _aDet		:= {}

DbSelectArea(_cArqTrb)
DbGoTop()

ProcRegua(0)

_aDet  := {{'T�tulo','Status','A��o'}}

While !Eof()
	If IsMark('E1_OK',_cMarca,.F.)
		
		SE1->(DbGoTo((_cArqTrb)->E1_RECNO))
		_nProc++
		_lPosit	:= U_REFI063J((_cArqTrb)->E1_RECNO,'E',@_aDet)
		
		If _lPosit
			Begin Transaction
			U_REFI060J((_cArqTrb)->E1_RECNO,'E!',,,,,_cMotivo)
			End Transaction
			If lMsErroAuto
				DisarmTransaction()
			EndIf
		EndIf
		
	EndIf
	
	_nReg++
	IncProc('Positivando... [Processados/Marcados]  ' + cValToChar(_nReg)+'/'+cValToChar(_nProc) )
	DbSkip()
	
EndDo

If Len(_aDet) = 1
	_aDet := {}
EndIf

Return( Nil )  