#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 26/11/99

User Function Qdom700()     // incluido pelo assistente de conversao do AP5 IDE em 26/11/99

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CEDIT,CEDITOR,")

/*/
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun�ao    �QDOM700   � Autor � Newton R. Ghiraldelli � Data � 14/09/99 ���
��+----------+------------------------------------------------------------���
���Descri�ao �                                                            ���
��+----------+------------------------------------------------------------���
��� Uso      � 			                                                  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
// O valor do cEdit e montado pelo parametro MV_QDTIPED e devera
//	conter um dos parametros abaixo
//cEdit:=Alltrim( cEdit )
//If cEdit == "WORD95"
//	cEditor := "TMsOleWord95"
//Elseif cEdit == "WORD97"
cEditor := "TMsOleWord97"
//ElseIf cEdit == "..."
//   cEditor := "..."       
//   Aqui deve-se colocar os elseif necessarios para determinar
//   qual o editor de texto deve-se usar.  Em 14 Set 1999 estao
//   disponiveis apenas no Word7(Office95) e Word8(Office97).
//EndIf
Return Alltrim( cEditor )
