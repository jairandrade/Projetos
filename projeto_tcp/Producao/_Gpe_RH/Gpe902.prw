#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/09/00

User Function Gpe902()        // incluido pelo assistente de conversao do AP5 IDE em 25/09/00

//���������������������������������������������������������������������Ŀ
//�����������������������������������������������������������������������

SetPrvt("_nVHE,_nHE,")

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPHEXTRA  � Autor � Rita Pimentel         � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Calculo HORAS EXTRAS      -REGINALDO 25/03/2010             ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Roteiro de Calculo -> FOLXXX - Calculo da Folha             ���
�������������������������������������������������������������������������Ĵ��
���Altera��o:
���Considerar todas as verbas de horas extras com exce��o da verba "110"   �. 
�������������������������������������������������������������������������Ĵ��
���Manuten��o�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
//If sra->ra_sitfolh != "D"
	_nVHE := 0
	_nVHE := fBuscaPd("106","V")+fBuscaPd("107","V")+fBuscaPd("108","V")
	_nVHE := _nVHE + fBuscaPd("109","V")+fBuscaPd("111","V")
	_nVHE := _nVHE + fBuscaPd("112","V")+fBuscaPd("113","V")+fBuscaPd("114","V")
	_nVHE := _nVHE + fBuscaPd("115","V")+fBuscaPd("116","V")+fBuscaPd("223","V")
	_nHE := 0
	_nHE := fBuscaPd("106","H")+fBuscaPd("107","H")+fBuscaPd("108","H")
	_nHE := _nHE + fBuscaPd("109","H")+fBuscaPd("111","H")
	_nHE := _nHE + fBuscaPd("112","H")+fBuscaPd("113","H")+fBuscaPd("114","H")
	_nHE := _nHE + fBuscaPd("115","H")+fBuscaPd("116","H")
   If _nHE > 0  
	   FgeraVerba("902",_nVHE,_nHE,,,"H",,,,,.t.)
   ENDIF	   
//endIf
Return
