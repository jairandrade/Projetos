//#include "protheus.ch"
#include "totvs.ch"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Empresa   � Capricornio S/A                                            ���
�������������������������������������������������������������������������Ĵ��
���Funcao    � FINP0007  � Autor � Tiago Beraldi        � Data � 07/03/16 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � ATUALIZA A TAXA DE DOLAR                                   ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Data      � Programador   � Manutencao efetuada                        ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � FINP0007()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Capricornio S/A                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
User Function FINP0007

	//���������������������������������������������������������������������Ŀ
	//� Declaracao de Variaveis                                             �
	//�����������������������������������������������������������������������
	Local	nPass
	Local 	cFile
	Local	cTexto
	Local 	nLinhas
	Local	cLinha
	Local	cData
	Local	cVenda
	Local	j
	Local	dDataRef
	Local 	dData
	Local	nValCHF		:= 0	
	Local	nValEUR		:= 0
	Local	nValUSD		:= 0
	Local	nValBRL		:= 1    
	Local 	aArea 		:= GetArea()    
	Local 	lAuto       := .F.
	Local 	nTimeOut	:= 120
	Local	aHeadOut 	:= {}
	Local 	cHeadRet 	:= "" 

	aAdd( aHeadOut, 'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')' )

	//���������������������������������������������������������������������Ŀ
	//� Schedule                                                            �
	//�����������������������������������������������������������������������
	If Select("SX2") == 0
		RPCSetType( 3 )
		RpcSetEnv("01","03",,,,GetEnvServer(),{"SM2"})  
		ConOut("Dollar - Atualizacao de Moedas... " + Dtoc(Date()) + " - " + Time())
		lAuto := .T.
	EndIf

	dbSelectArea("SM2")						
	dbSetorder(1)

	For nPass := 30 To 0 Step -1  //Refaz os ultimos 30 dias. 

		//���������������������������������������������������������������������Ŀ
		//� Obtem arquivo do Banco Central                                      �
		//�����������������������������������������������������������������������
		dDataRef := dDataBase - nPass

		If	Dow(dDataRef) == 1			  			//Se for domingo
			cFile := Dtos(dDataRef - 2) + ".csv"
		ElseIf	Dow(dDataRef) == 7  				//Se for sabado
			cFile := Dtos(dDataRef - 1) + ".csv"
		Else						 				//Se for dia normal
			cFile := Dtos(dDataRef) + ".csv"	
		EndIf
		cTexto := HttpsGet("https://www4.bcb.gov.br/Download/fechamento/" + cFile, "capricornio.pem", "", "123456", "WSDL", nTimeOut, aHeadOut, @cHeadRet)

		//���������������������������������������������������������������������Ŀ
		//� Procura valor do cambio                                             �
		//�����������������������������������������������������������������������
		If !Empty(cTexto)

			nLinhas := MLCount(cTexto, 81)
		
			For j := 1 to nLinhas
				cLinha	:= Memoline(cTexto, 81, j)
				cData  	:= Subs(cLinha, 1, 10)
				cVenda  := StrTran(Subs(cLinha, 22, 10), ",", ".")

				If	Subs(cLinha, 12, 3) == "220" 
					dData		:= DataValida(CtoD(cData) + 1, .T.)
					nValUSD		:= Val(cVenda) 
				EndIf

				If	Subs(cLinha, 12, 3) == "425" 
					dData		:= DataValida(CtoD(cData) + 1, .T.)
					nValCHF		:= Val(cVenda) 
				EndIf

				If	Subs(cLinha, 12, 3) == "978" 
					dData		:= DataValida(CtoD(cData) + 1, .T.)
					nValEUR		:= Val(cVenda) 
				EndIf

			Next j

			//���������������������������������������������������������������������Ŀ
			//� Grava as cotacoes                                                   �
			//�����������������������������������������������������������������������
			dbSelectArea("SM2")						
			dbSetorder(1)

			If dData != Nil

				If SM2->(dbSeek(DtoS(dData)))
					Reclock("SM2", .F.)
				Else
					Reclock("SM2", .T.)
					SM2->M2_DATA	:= dData
				EndIf
				SM2->M2_MOEDA1	:= nValBRL
				SM2->M2_MOEDA2	:= nValUSD
				SM2->M2_MOEDA3  := 1.0641
				SM2->M2_MOEDA6  := nValEUR
				SM2->M2_MOEDA7  := nValCHF
				SM2->M2_INFORM	:= "S"
				MsUnLock("SM2")

				dbSelectArea("CTP")					
				CTP->(dbSetOrder(1))

				If CTP->(dbSeek(xFilial("CTP") + DtoS(dData) + "01"))	//Real
					RecLock("CTP", .F.)
				Else
					RecLock("CTP", .T.)
					CTP->CTP_FILIAL	:= xFilial("CTP")
					CTP->CTP_DATA	:= dData
				EndIf
				CTP->CTP_MOEDA	:= "01"
				CTP->CTP_TAXA	:= nValBRL
				CTP->CTP_BLOQ	:= "2"
				MsUnLock("CTP")

				If CTP->(dbSeek(xFilial("CTP") + DtoS(dData) + "02"))	//Dolar
					RecLock("CTP",.F.)
				Else
					RecLock("CTP",.T.)
					CTP->CTP_FILIAL	:= xFilial("CTP")
					CTP->CTP_DATA	:= dData
				EndIf
				CTP->CTP_MOEDA	:= "02"
				CTP->CTP_TAXA	:= nValUSD
				CTP->CTP_BLOQ	:= "2"
				MsUnLock("CTP")

				If CTP->(dbSeek(xFilial("CTP") + DtoS(dData) + "06"))	//Euro
					RecLock("CTP",.F.)
				Else
					RecLock("CTP",.T.)
					CTP->CTP_FILIAL	:= xFilial("CTP")
					CTP->CTP_DATA	:= dData
				EndIf
				CTP->CTP_MOEDA	:= "06"
				CTP->CTP_TAXA	:= nValEUR
				CTP->CTP_BLOQ	:= "2"
				MsUnLock("CTP")


				If CTP->(dbSeek(xFilial("CTP") + DtoS(dData) + "07"))	//Franco Suico
					RecLock("CTP",.F.)
				Else
					RecLock("CTP",.T.)
					CTP->CTP_FILIAL	:= xFilial("CTP")
					CTP->CTP_DATA	:= dData
				EndIf
				CTP->CTP_MOEDA	:= "07"
				CTP->CTP_TAXA	:= nValCHF
				CTP->CTP_BLOQ	:= "2"
				MsUnLock("CTP")

			EndIf
		EndIf

	Next  

	If lAuto
		RpcClearEnv() // Libera o Environment
		ConOut("Dollar - Moedas Atualizadas. " + DtoC(Date()) + " - " + Time())
	EndIf

	RestArea(aArea)

Return
