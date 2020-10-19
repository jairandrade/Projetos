#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/09/00

User Function GPHEXTRA()        // incluido pelo assistente de conversao do AP5 IDE em 25/09/00

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("_nVHE,_nHE,")

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GPHEXTRA  � Autor � Rita Pimentel         � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �C�lculo HORAS EXTRAS                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Roteiro de Calculo -> FOLXXX - Calculo da Folha             ���
�������������������������������������������������������������������������Ĵ��
���Observa��o�.    ���
���          �. 
�������������������������������������������������������������������������Ĵ��
���Manuten��o�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
//If sra->ra_sitfolh != "D"
	_nVHE := 0
	_nVHE := fBuscaPd("106","V")+fBuscaPd("107","V")+fBuscaPd("108","V")
	_nVHE := _nVHE + fBuscaPd("109","V")+fBuscaPd("110","V")+fBuscaPd("111","V")
	_nVHE := _nVHE + fBuscaPd("112","V")+fBuscaPd("113","V")+fBuscaPd("114","V")
	_nVHE := _nVHE + fBuscaPd("115","V")+fBuscaPd("116","V")+fBuscaPd("223","V")
	_nHE := 0
	_nHE := fBuscaPd("106","H")+fBuscaPd("107","H")+fBuscaPd("108","H")
	_nHE := _nHE + fBuscaPd("109","H")+fBuscaPd("110","H")+fBuscaPd("111","H")
	_nHE := _nHE + fBuscaPd("112","H")+fBuscaPd("113","H")+fBuscaPd("114","H")
	_nHE := _nHE + fBuscaPd("115","H")+fBuscaPd("116","H")
   If _nHE > 0  
	   FgeraVerba("900",_nVHE,_nHE,,,"H",,,,,.t.)
   ENDIF	   
//endIf
Return
