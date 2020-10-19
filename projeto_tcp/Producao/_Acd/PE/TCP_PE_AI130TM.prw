
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AI130TM   �Autor  �Deosdete P. Silva   � Data �  11/22/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Ponto de entrada para fixar o tipo de movimentacao para   ���
���          �  retorno de OS em substituicao ao tratamento do estoque    ���
���          �  na rotina Retorno de OS padrao do Mnt Ativo pois nao      ���
���          �  aderiu ao processo da TCP o tratamento da devol de insumos���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function AI130TM()
Local cTitulo := PARAMIXB
Local cTM     := SuperGetMV("TCP_AI130TM",.F.,"111")   //Tipo de Movimentacao especifica para retorno de OS com vinculo OS/OP

VTALERT("Tipo Mov:" + cTM + " - Este movimento requer numero da Ordem de Manuten��o.","Retorno OS TCP",.T.,1000) 
VTKeyBoard(chr(20))

Return cTM


