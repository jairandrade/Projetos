
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AI130TM   �Autor  �Deosdete P. Silva   � Data �  11/22/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Ponto de entrada final da gra�avao do mivmento interno    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function AI130DGR()
//lMSErroAuto - PRIVATE

If !lMSErroAuto
	
	
	RecLock("SD3",.F.)
	SD3->D3_OP := ALLTRIM(SD3->D3_XOBS)
	SD3->(msUnlock())
	IF SUPERGETMV( 'TCP_MANUSI', .f., .F. ) .AND. !EMPTY(POSICIONE('SC2',1,SD3->D3_FILIAL+SD3->D3_OP,'C2_XNUMOM'))
	
		oManusis  := ClassIntManusis():newIntManusis()    
		oManusis:cFilZze    := xFilial('ZZE')
		oManusis:cChave     := ALLTRIM(STR(SD3->(RECNO())))
		oManusis:cTipo	    := 'E'
		oManusis:cStatus    := 'P'
		oManusis:cErro      := ''
		oManusis:cEntidade  := 'EXP'
		oManusis:cOperacao  := 'I'
		oManusis:cRotina    :=  FunName()

		IF oManusis:gravaLog()  
			U_MNSINT03(oManusis:cChaveZZE)              
		ELSE
			ALERT(oManusis:cErroValid)
		ENDIF 
	ENDIF
	VTALERT("Retorno processado com sucesso.","AVISO",.T.,3000) 
	VTKeyBoard(chr(20))
		  
	
EndIf


Return





