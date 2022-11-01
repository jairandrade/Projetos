#Include 'PROTHEUS.ch'
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Rs150ML       � Autor �RH                � Data � 01/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Envia e-mail de Agenda para Candidatos.                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Rs150ML()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TRMA150                                                    ���
��������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�06/08/14�TQENRX�Incluido o fonte da 11 para a 12 e efetua-���
���            �        �      �da a limpeza.                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function Rs150ML()

Local nTipo   	:= ParamIxb[1]
Local aSaveArea := GetArea()
Local aSvCols	:= Aclone(aCols)
Local cAssunto	:= "Agenda de Processo Seletivo" 
Local cMensagem	:= ""
Local cEmail	:= ""

Local nx		:= 0
Local ny		:= 0 
Local nErro		:= 0
Local nTamGetD 	:= Iif( nQual == 3, 1, Len(aSvGetD) )
Local nPosProc	:= GdFieldPos("QD_TPPROCE")
Local nPosData	:= GdFieldPos("QD_DATA")
Local nPosHora	:= GdFieldPos("QD_HORA")

If nTipo == 1
	If !MsgYesNo( OemToAnsi("Confirma o envio de e-mail de agenda para os candidatos ?" ))	
		Return Nil           
	Else
		lEnviaMail := .F.
	EndIf
EndIf

ProcRegua(nTamGetD)

For ny := 1 To nTamGetD //Numero de Candidatos
	
	IncProc()


	dbSelectArea("SQG")
	dbSetOrder(1)
	dbSeek(aSvGetd[ny][1])
	cEmail	:= SQG->QG_EMAIL
		
	If (nQual == 6 .Or. nQual == 7)
		Loop
	EndIf
	
	If nQual != 3 //Candidato
		aCols 	:= aClone(aSvGetd[ny][2])
	EndIf
    

	//Lay-out do e-mail
		cMensagem := '<html><title>'+cAssunto+'</title><body>'
		cMensagem += '<table borderColor="#0099cc" height="29" cellSpacing="1" width="645" borderColorLight="#0099cc" border=1>'
		cMensagem += '<tr><td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="606"'
		cMensagem += 'borderColorDark=v bgColor="#0099cc" height="1">'
		cMensagem += '<p align="center"><FONT face="Arial" color="#ffffff" size="4">'
		cMensagem += '<b>'+OemToAnsi(cAssunto)+'</b></font></p></td></tr>'
		cMensagem += '<tr><td align="left" width="606" height="32"><b><FONT face="Arial" color="#0099cc" size="2">Candidato:&nbsp;</FONT></b><FONT face="Arial" color="#666666" size="2">' + SQG->QG_NOME + '</FONT><br></td>'
	   
		cMensagem += '<tr><td>'
		cMensagem += '<table width="100%"  border="1" cellspacing="2" cellpadding="2">'
		cMensagem += '<tr>'
		cMensagem += '<td><b><FONT face="Arial" color="#0099cc" size="2">Item do Processo</FONT></b></td>'
		cMensagem += '<td><b><FONT face="Arial" color="#0099cc" size="2">Data</FONT></b></td>'
		cMensagem += '<td><b><FONT face="Arial" color="#0099cc" size="2">Hora</FONT></b></td>'
		cMensagem += '</tr>'
				
		For nx := 1 To Len(aCols)
			cMensagem += '<tr>'							   
			cMensagem += '<td><FONT face="Arial" color="#666666" size="2">&nbsp;' + FDesc("SX5", "R9"+aCols[nx][nPosProc], "X5_DESCRI") + '</FONT></td>'
			cMensagem += '<td><FONT face="Arial" color="#666666" size="2">&nbsp;' + Dtoc(aCols[nx][nPosData]) + '</FONT></td>'
			cMensagem += '<td><FONT face="Arial" color="#666666" size="2">&nbsp;' + aCols[nx][nPosHora] + '</FONT></td>'						
			cMensagem += '</tr>'
		Next nx  
	   
		cMensagem += '</table></td></tr>'
		cMensagem += +'</table></body></html>'	
    //---
    
	MsgRun( OemToAnsi("Aguarde. Enviando Email..."),"",;
			{||nErro := Rh_Email(cEmail,,cAssunto,cMensagem)})
	RH_ErroMail(nErro,SQG->QG_NOME )
	
Next ny

If nQual != 3 //Candidato
	aCols := Aclone(aSvCols)
EndIf

RestArea(aSaveArea)

Return Nil