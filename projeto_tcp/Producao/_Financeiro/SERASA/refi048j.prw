#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �REFI048J  � Autor � Kaique Sousa      � Data �  24/01/10   ���
�������������������������������������������������������������������������͹��
���Descricao �CADASTRO DE MOTIVOS DE BAIXA DO PEFIN.                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function REFI048J

Local _cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local _cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "ZP2"

dbSelectArea("ZP2")
dbSetOrder(1)

AxCadastro(cString,"Motivos de Baixa do SERASA - PEFIN",_cVldExc,_cVldAlt)

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