#INCLUDE 'RWMAKE.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GETPROX  �Autor  � Kaique Sousa       � Data �  03/26/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � OBTEM A SEQUENCIA A PARTIR DE UMA CHAVE CONCATENADA        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function GetProx(cTabela,cChave,cCpoInd,nIndice,cCampo)

Local aArea	:= GetArea(cTabela) 
Local cRet	:= ''

DbSelectArea(cTabela)
DbSetOrder(nIndice)
If DbSeek(cChave)
	While !Eof() .And. (cTabela)->(&(cCpoInd)) = cChave
		cRet := (cTabela)->(&(cCampo))
		(cTabela)->(DbSkip())
	EndDo
	cRet := Soma1(Alltrim(cRet))
Else
	cRet := StrZero(1,TamSX3(cCampo)[1])
EndIf

RestArea(aArea)

Return( cRet )