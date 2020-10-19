
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ACD100EMP �Autor  �Deosdete P. Silva   � Data �  12/07/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para validar o empenho do endere�o na     ���
���          � gera�ao da Ord Sep                                         ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ACD100EMP() 
Local lRet    := .T. 
Local aArea   := getArea()
Local nSldSep := 0
Local aAreaSDC := SDC->(GetArea())

//������������������������������������������������������Ŀ
//�Verificar se a soma do empenho nos endere�os do saldo �
//�a atender esta correto                                �
//��������������������������������������������������������
nSldSep := SD4->D4_QUANT

DbSelectArea("SDC") 
DbSetOrder(2)   //DC_FILIAL, DC_PRODUTO, DC_LOCAL, DC_OP, DC_TRT, DC_LOTECTL, DC_NUMLOTE, DC_LOCALIZ, DC_NUMSERI, R_E_C_N_O_, D_E_L_E_T_
SDC->(DbSeek(xFilial("SDC")+SD4->(D4_COD+D4_LOCAL+D4_OP)))   

While !SDC->(Eof()) .AND. SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP) == xFilial("SDC")+SD4->(D4_COD+D4_LOCAL+D4_OP)

    nSldSep -= SDC->DC_QUANT
	SDC->(DbSkip())

EndDo

//�������������������������Ŀ
//�Chamar rotina de empenho �
//���������������������������
If nSldSep > 0
	Aviso(ProcName() + "-Sem empenho no endere�o!!!","Op/Produto "+SD4->D4_OP+"/"+SD4->D4_COD + ". Falta empenho de endere�o para o saldo de " + AllTrim(Str(nSldSep)) + ". Fa�a o endere�amento do empenho ",{"Ok"})
    lRet := .F.
EndIf

RestArea(aArea)
RestArea(aAreaSDC)

Return lRet

