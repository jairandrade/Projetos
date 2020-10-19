#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'

#DEFINE   CR   Chr(13)+Chr(10)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �REFI061J  �Autor  � Kaique Sousa      � Data �  06/03/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �PROCESSA A MARCACAO DO TITULO PARA NEGATIVAR.               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function REFI061J(_cMarca)

Local _aArea		:= GetArea()
Local _nAviso		:= 1
Local _aDet			:= {}

If Aviso('Aten��o','.',{'N�o','Sim'},,'Confirma Negativa��o ?') = 2

	Processa({|| S061JPROC(@_aDet)},'Negativar Titulos','Marcando registros...',.F.)

	While _nAviso = 1
		_nAviso := 0
		_nAviso := Aviso('Aten��o','Opera��o realizada com sucesso !',{'Log','OK'},,'Negativa��o Realizada')
  		If _nAviso = 1
			U_REFI045J(_aDet,"Log da Negativa��o")
		EndIf
	EndDo

EndIf

RestArea(_aArea)

Return( Nil )  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �061JPROC  �Autor  � Kaique Sousa      � Data �  06/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �PROCESSA OS REGISTROS MARCANDO PARA NEGATIVACAO.            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function S061JPROC(_aDet)

Local _cMsgi		:= '' 
Local _nReg		:= 0
Local _nProc		:= 0
Local _lNegat		:= .F.

Default _aDet		:= {}

DbSelectArea(_cArqTrb)
DbGoTop()

ProcRegua(0)

_aDet  := {{'T�tulo','Status','A��o'}}

While !Eof()
	If IsMark('E1_OK',_cMarca,.F.)

		SE1->(DbGoTo((_cArqTrb)->E1_RECNO))
		_nProc++
		_lNegat := U_REFI063J((_cArqTrb)->E1_RECNO,'I',@_aDet)

		If _lNegat
			Begin Transaction
				U_REFI060J((_cArqTrb)->E1_RECNO,'I!')
			End Transaction 		
			If lMsErroAuto
				DisarmTransaction()
			EndIf
		EndIf

	EndIf

	_nReg++
	IncProc('Negativando... [Processados/Marcados]  ' + cValToChar(_nReg)+'/'+cValToChar(_nProc) )
	DbSkip()

EndDo

If Len(_aDet) = 1
	_aDet := {}
EndIf

Return( Nil )      


