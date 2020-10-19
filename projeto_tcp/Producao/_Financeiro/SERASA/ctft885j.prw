#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CTFT885J �Autor  � - Kaique Sousa -  � Data �  04/17/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � ROTINA DE JOB PARA INTEGRACAO COM SERASA EXPERIAN.         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CTFT885J(nFun)

	Prepare Environment Empresa "01" Filial "010110"
	//Conout(RegDt() + "Iniciando job...")

	//Conout(RegDt() + GetClientDir() )
	//U_RUNDLL(nFun)
	If File("..\bin_master\smartclient\smartclient.exe")
		//Conout(" Achei o SmartCliente... ")
//			   	    D:\Outsourcing\Clientes\NFKRF0\bin_master\smartclient
			//WaitRunSrv( "..\bin_master\smartclient\smartclient.exe -q -c=server10 -e=NFKRF0_TI01 -p=U_RUNDLL",.F.,"" )
			WaitRunSrv( "D:\Outsourcing\Clientes\NFKRF0\bin_master\smartclient\smartclient.exe -q -c=server10 -e=NFKRF0_TI01 -p=U_RUNDLL",.T.,"D:\Outsourcing\Clientes\NFKRF0\bin_master\smartclient" )
	Else
		//Conout(" Nao Achei o SmartCliente... ")		
	EndIf

	//Conout(RegDt() +"Finalizando job...")
	Reset Environment

Return( Nil )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � REGDT    �Autor  � - Kaique Sousa -  � Data �  02/29/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � FUNCAO AUXILIAR PARA REGISTRAR DATA E HORA DO //Conout       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RegDt

Local _cDate  := Substr(DtoC(Date()),4,2) + '/' + Substr(DtoC(Date()),1,2) + '/20' + Substr(DtoC(Date()),7,2)

Local _cRegDt := '[' + _cDate + ' ' + Time() + '] Dist. PDF - '

Return( _cRegDt )
