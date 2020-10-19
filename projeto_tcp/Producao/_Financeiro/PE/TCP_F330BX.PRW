#include "PROTHEUS.CH"
#include "topconn.ch"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦  FA330BX   ¦ Autor ¦ Lucilene Mendes     ¦ Data ¦20.06.14  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  PE chamado ao confirmar a compensação dos títulos sele-   ¦¦¦
¦¦¦          ¦  cionados, após a baixa do título.                         ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦  Geração de instrução bancária.                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function FA330BX()
                                  
//Variáveis de Instrução Bancária
Local cBcoProt:= GetNewPar("TC_BCOINST","341")  //Banco com instrução bancária configurada                 
Local cOcorren:= GetNewPar("TC_"+SE1->E1_PORTADO+"BAIX","02") //Ocorrencia de pedido de baixa
Local aArea:= GetArea("SE1")

//Posiciona no título principal
dbSelectArea("SE1")
//SE1->(dbSeek(xFilial("SE1")+cPrefixo+cNum+cParcela+cTipoTit+cCliente+cLoja)) 
SE1->(dbGoto(nRecVld))

//Identifica se o título foi enviado para o banco
If SE1->E1_PORTADO $ cBcoProt //.and. !Empty(SE1->E1_IDCNAB)
	
//	If 2 = Aviso("Instrução de Cobrança","Deseja cadastrar uma instrução de cobrança de PEDIDO DE BAIXA para o título "+SE1->E1_NUM+" para envio ao banco?",{"Sim","Não"})
//     	Return                                        
//    Endif

	/*Identifica se o título foi enviado para o banco
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
					If FI2->FI2_GERADO = '2' //Se tiver ocorrencia de baixa ou de alteração de valor, deleta
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

//Gera a instrução de pedido de baixa
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
 
//Fim Instrução Bancária

RestArea(aArea)
Return 