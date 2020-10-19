#Include 'Protheus.ch'

/*/{Protheus.doc} 
Ponto de entrada ao final da baixa dos títulos a receber.
O ponto de entrada F70GRSE1 é chamado após a baixa do título a receber. Neste momento o SE1 
está posicionado e recebe como primeiro parâmetro o código da ocorrência, caso, 
seja uma baixa proveniente do CNAB.
@type User function
@author luizf
@since 24/05/2016
/*/
User Function F70GRSE1()

//+---------------------------------------------------------------------+
//| Valida se o titulo é de integracao.                                 |
//+---------------------------------------------------------------------+	
If SE1->(FIELDPOS("E1_XNUMOS")) == 0 .Or. Empty(SE1->E1_XNUMOS) .Or. AllTrim(SE1->E1_TIPO) == "RA"
  Return
EndIf
//Status: Aberto = 1,Baixado = 2,BaixadoParcialmente = 3,Protestado = 4
If !U_WGENFIN1(SE1->E1_NUM,iif(SE1->E1_SALDO>0,"3","2"),SE1->E1_SALDO,"F70GRSE1")//cNumTit,cStatus,nSaldo,cRotina
	Aviso("Erro Integração:WGENFIN1","Erro ao integrar Status do título, verifique com faturamento. Mais detalhes consultar LOG.",{"OK"})
EndIf

Return


/*/{Protheus.doc} FA070CA2
Ponto de entrada após o cancelamento de baixa.
Envia Status para integração.
@type function
@author luizf
@since 21/06/2016
/*/
User Function FA070CA2

LOCAL nOpCan := PARAMIXB[1] //5=cancelamento 6=exclusao

//+---------------------------------------------------------------------+
//| Valida se o titulo é de integracao.                                 |
//+---------------------------------------------------------------------+	
If SE1->(FIELDPOS("E1_XNUMOS")) == 0 .Or. Empty(SE1->E1_XNUMOS) .Or. AllTrim(SE1->E1_TIPO) == "RA"
  Return
EndIf
//Status: Aberto = 1,Baixado = 2,BaixadoParcialmente = 3,Protestado = 4
If !U_WGENFIN1(SE1->E1_NUM,iif(SE1->E1_SALDO==SE1->E1_VALOR,"1","3"),SE1->E1_SALDO,"FA070CA2"+"."+Iif(nOpCan==5,"Cancelamento","Exclusao"))//cNumTit,cStatus,nSaldo,cRotina
	Aviso("Erro Integração:WGENFIN1","Erro ao integrar Status do título, verifique com faturamento. Mais detalhes consultar LOG.",{"OK"})
EndIf

Return

