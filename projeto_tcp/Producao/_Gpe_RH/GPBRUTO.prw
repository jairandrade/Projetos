#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/09/00

User Function GPBRUTO()        // incluido pelo assistente de conversao do AP5 IDE em 25/09/00
Local T
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
���Fun��o    �GPBRUTO  � Autor � Rita Pimentel         � Data � 16.03.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �C�lculo VALOR BRUTO                                        ���
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
   dbSelectArea("SRV")
	dbSetOrder(1)

	_nVBr := 0
	T:=0
	_T1:=""
	For T:=1 to 999
	   _t1 := strzero(t,3)
		SRV->(dBGoTop())
		SRV->(dbSeek(xfilial("SRV")+_t1))
		If SRV->(!Eof())
			If SRV->RV_TIPOCOD == "1" 
				_nVBr := _nVBr + fBuscaPd(_T1,"V")
			ENDIF
		ENDIF
	NEXT		
	If _nVBr > 0
	   FgeraVerba("901",_nVBr,,,,,,,,,.t.)
	ENDIF	   
//endIf
Return
