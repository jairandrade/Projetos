#Include 'Protheus.ch'

/*/{Protheus.doc} F040ALTR
Ponto de entrada ao final da alteração do título a receber antes de sair do AxAltera.
Status: Aberto = 1,Baixado = 2,BaixadoParcialmente = 3,Protestado = 4
@type function
@author luizf
@since 24/05/2016
/*/
User Function F040ALTR()

LOCAL cStatus := ""
//+---------------------------------------------------------------------+
//| Valida se o titulo é de integracao, integra status de pagamento.    |
//+---------------------------------------------------------------------+	
If SE1->(FIELDPOS("E1_XNUMOS")) == 0 .Or. Empty(SE1->E1_XNUMOS) .Or. AllTrim(SE1->E1_TIPO) == "RA"
  Return
EndIf

cStatus := iif(SE1->(E1_SALDO==E1_VALOR),"1","2")
If SE1->E1_SITUACA == "F"//Titulo protestado.
	cStatus:= "4" 
EndIf

U_WGENFIN1(SE1->E1_NUM,cStatus,SE1->E1_SALDO,"F040ALTR")//cNumTit,cStatus,nSaldo,cRotina

Return

/*/{Protheus.doc} FA040FIN
Ponto de entrada ao final da Inclusão do título a receber.
@type function
@author luizf
@since 24/05/2016

User Function FA040FIN()

//+---------------------------------------------------------------------+
//| Valida se o titulo é de integracao.                                 |
//+---------------------------------------------------------------------+	
If Empty(SE1->E1_XNUMOS)
  Return
EndIf


Return
/*/

