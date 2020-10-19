#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �REFI070J  �Autor  � Kaique Sousa      � Data �  05/30/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �RETORNA O DESCRITIVO DE UM COMBOBOX                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function REFI070J(_cCpoCbo,_cValor,_nDim)

Local _aCBox	:= {}
Local _nCBox	:= 0
Local _cVar		:= ""

Default _nDim	:= 3

_aCbox := RetSx3Box(X3CBox(Posicione('SX3',2,_cCpoCbo,'X3_CBOX')),,,1)

If !Empty(_aCBox) .And. !Empty(_nCbox := aScan(_aCbox,{|x| x[2]==AllTrim(_cValor)}))
	_cVar := AllTrim(_aCbox[_nCBox,_nDim])
Else
	_cVar := " "
EndIf

Return( _cVar )