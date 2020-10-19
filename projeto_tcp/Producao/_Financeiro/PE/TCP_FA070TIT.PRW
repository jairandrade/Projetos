#INCLUDE "RWMAKE.CH"
#include 'protheus.ch'
#include 'parmtype.ch'

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦  FA070TIT	¦ Autor ¦ Lucilene Mendes    ¦ Data ¦21.06.18 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Ponto de entrada na gravação da baixa ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FA070TIT()
Local cBcoProt:= GetNewPar("TC_BCOINST","341")  //Banco com instrução bancária configurada                 
Local cOcorren:= GetNewPar("TC_"+SE1->E1_PORTADO+"BAIX","02") //Ocorrencia de pedido de baixa
Local lEnvia := .T.
IF !Empty(cOcorren) 

	IF IsInCallStack("U_MFIN004")
		IF cEnvBaixa != '2'
			lEnvia := .F.
		ENDIF
	ELSE
		If 2 = Aviso("Instrução de Cobrança","Deseja cadastrar uma instrução de cobrança de PEDIDO DE BAIXA para envio ao banco?",{"Sim","Não"})
			lEnvia := .F.
	    Endif
	ENDIF    
	
	IF lEnvia
		cChaveSE1 := SE1->E1_FILIAL+'1'+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA//+cOcorren+'2'
		dbSelectArea("FI2")    
		If FI2->(dbSeek(cChaveSE1))
			//Apaga os registros existentes não enviados ao banco, caso existam, para enviar apenas o pedido de baixa 
			While FI2->(!Eof())
				cChaveFI2 := FI2_FILIAL+FI2_CARTEI+FI2_NUMBOR+FI2_PREFIX+FI2_TITULO+FI2_PARCEL+FI2_TIPO+FI2_CODCLI+FI2_LOJCLI//+FI2_OCORR+FI2_GERADO
				If cChaveSE1 == cChaveFI2
					If FI2->FI2_GERADO = '2' //A ocorrencia de baixa substitui as demais, pois encerra o processo de cobrança.
						Reclock("FI2",.F.)	
						dbDelete()	
						FI2->(MsUnlock())
					Endif	
				Endif
				FI2->(dbSkip())
			End 
		Endif
			
		//Grava a instrução de baixa
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
			FI2->FI2_CAMPO  := "E1_BAIXA"   
			FI2->FI2_TIPCPO:= "D"   
		FI2->(MsUnlock())
	ENDIF
ENDIF

Return .T.