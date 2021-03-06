#include "PROTHEUS.CH"
#include "topconn.ch"

/*__________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    �  FA330BX   � Autor � Lucilene Mendes     � Data �20.06.14  ���
��+----------+------------------------------------------------------------���
���Descri��o �  PE chamado ao confirmar a compensa��o dos t�tulos sele-   ���
���          �  cionados, ap�s a baixa do t�tulo.                         ���
��+----------+------------------------------------------------------------���
���Uso       �  Gera��o de instru��o banc�ria.                            ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function FA330BX()
                                  
//Vari�veis de Instru��o Banc�ria
Local cBcoProt:= GetNewPar("TC_BCOINST","341")  //Banco com instru��o banc�ria configurada                 
Local cOcorren:= GetNewPar("TC_"+SE1->E1_PORTADO+"BAIX","02") //Ocorrencia de pedido de baixa
Local aArea:= GetArea("SE1")

//Posiciona no t�tulo principal
dbSelectArea("SE1")
//SE1->(dbSeek(xFilial("SE1")+cPrefixo+cNum+cParcela+cTipoTit+cCliente+cLoja)) 
SE1->(dbGoto(nRecVld))

//Identifica se o t�tulo foi enviado para o banco
If SE1->E1_PORTADO $ cBcoProt //.and. !Empty(SE1->E1_IDCNAB)
	
//	If 2 = Aviso("Instru��o de Cobran�a","Deseja cadastrar uma instru��o de cobran�a de PEDIDO DE BAIXA para o t�tulo "+SE1->E1_NUM+" para envio ao banco?",{"Sim","N�o"})
//     	Return                                        
//    Endif

	/*Identifica se o t�tulo foi enviado para o banco
	dbSelectArea("SEA")
    If dbSeek(xFilial("SEA")+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)//+SE1->E1_CLIENTE+SE1->E1_LOJA)
    	If SEA->EA_TRANSF = "S"
			lEnviado := .T.
		Endif
	Endif
	*/
	If  !Empty(cOcorren) //lEnviado .and.
		cChaveSE1 := SE1->E1_FILIAL+'1'+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA //+cOcorren+'2'
		dbSelectArea("FI2")    
		If dbSeek(cChaveSE1)
			//Apaga os registros existentes, caso existam
			While FI2->(!Eof())
				cChaveFI2 := FI2_FILIAL+FI2_CARTEI+FI2_NUMBOR+FI2_PREFIX+FI2_TITULO+FI2_PARCEL+FI2_TIPO+FI2_CODCLI+FI2_LOJCLI //+FI2_OCORR+FI2_GERADO
				If cChaveSE1 == cChaveFI2
					If FI2->FI2_GERADO = '2' //Se tiver ocorrencia de baixa ou de altera��o de valor, deleta
						If FI2->FI2_OCORR = cOcorren .or. FI2->FI2_OCORR = "06"
							Reclock("FI2",.F.)	
							dbDelete()
							FI2->(MsUnlock())
						Endif	
					Endif
				Endif
				FI2->(dbSkip())
			End		
		Endif
	Endif		
Endif			

//Gera a instru��o de pedido de baixa
Reclock("FI2",.T.)		
FI2->FI2_FILIAL := xFilial("SE1")
FI2->FI2_CARTEI := "1"
FI2->FI2_OCORR 	:= cOcorren
FI2->FI2_GERADO := "2"
FI2->FI2_NUMBOR := SE1->E1_NUMBOR
FI2->FI2_PREFIX	:= SE1->E1_PREFIXO
FI2->FI2_TITULO	:= SE1->E1_NUM
FI2->FI2_PARCEL	:= SE1->E1_PARCELA
FI2->FI2_TIPO  	:= SE1->E1_TIPO   
FI2->FI2_CODCLI	:= SE1->E1_CLIENTE
FI2->FI2_LOJCLI	:= SE1->E1_LOJA
FI2->FI2_DTOCOR	:= dDataBase                                                                                                                        
FI2->FI2_DESCOC := Posicione('SEB',1,xFilial('SEB')+SE1->E1_PORTADO+cOcorren+Replicate(" ",TamSX3("EB_REFBAN")[1]-Len(cOcorren))+"E","EB_DESCRI")    
FI2->(MsUnlock()) 
 
//Fim Instru��o Banc�ria

RestArea(aArea)
Return 