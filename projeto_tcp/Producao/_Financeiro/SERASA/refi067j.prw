#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � REFI067J �Autor  � - Kaique Sousa -  � Data �  28/09/2012 ���
�������������������������������������������������������������������������͹��
���Desc.     � Consulta Espeficica para selecionar os Tipos de Titulo     ���
���          � Utilizacao nas perguntas do Serasa/Pefin.                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION REFI067J()

Local _cQuery 	:= ''

_cQuery := " SELECT X5_CHAVE LLCODI ,X5_DESCRI LLDESC "
_cQuery += " FROM "+RetSqlName("SX5")
_cQuery += " WHERE X5_FILIAL= '"+xFilial("SX5")+"'"
_cQuery += " AND D_E_L_E_T_=' ' "
_cQuery += " AND X5_TABELA = '05' "
_cQuery += " ORDER BY 1 "   

Return( U_CTCF121X({_cQuery},.T.,'Selecione os Tipos a Excluir') )