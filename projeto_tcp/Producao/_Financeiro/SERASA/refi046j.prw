#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �REFI046J  � Autor � Kaique Sousa      � Data �  09/06/11   ���
�������������������������������������������������������������������������͹��
���Descricao �CADASTRO DE OCORRENCIAS DE RETORNO DO PEFIN SERASA.         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function REFI046J

Local _cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local _cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "ZP4"

dbSelectArea("ZP4")
dbSetOrder(1)

AxCadastro(cString,"Ocorr�ncias de Retorno do SERASA - PEFIN",_cVldExc,_cVldAlt)

Return( Nil )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MENUDEF   �Autor  �-Kaique Sousa-     � Data �  01/24/10   ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Private _aRotina := {	{ OemToAnsi('Pesquisar') ,'AxPesqui',0,1,0,Nil},;
								{ OemToAnsi('Visualizar'),'AxVisual',0,2,0,Nil},;
								{ OemToAnsi('Incluir')   ,'AxInclui',0,3,0,Nil},;
								{ OemToAnsi('Alterar')   ,'AxAltera',0,4,2,Nil},;
								{ OemToAnsi('Excluir')   ,'AxExclui',0,5,0,Nil}    }

Return( _aRotina )