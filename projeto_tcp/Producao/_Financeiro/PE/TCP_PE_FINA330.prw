#Include 'Protheus.ch'

/*/{Protheus.doc} FA330SE1
PE na compensação de título para enviar a baixa.
@type function
@author luizf
/*/
//**********************************************************
//*** ESTE PROCESSAMWENTO FOI TRABFERIDO PARA O PE F330SE5
//**********************************************************
//User Function FA330SE1()
//
//	//+---------------------------------------------------------------------+
//	//| Valida se o titulo é de integracao.                                 |
//	//+---------------------------------------------------------------------+	
//	If SE1->(FIELDPOS("E1_XNUMOS")) == 0 .Or. Empty(SE1->E1_XNUMOS) .Or. AllTrim(SE1->E1_TIPO) == "RA"
//	  Return
//	EndIf
//	//Status: Aberto = 1,Baixado = 2,BaixadoParcialmente = 3,Protestado = 4
//	If !U_WGENFIN1(SE1->E1_NUM,iif(SE1->E1_SALDO>0,"3","2"),SE1->E1_SALDO,"FA330SE1.Compensacao")//cNumTit,cStatus,nSaldo,cRotina
//		Aviso("Erro Integração:WGENFIN1","Erro ao integrar Status do título, verifique com faturamento. Mais detalhes consultar LOG.",{"OK"})
//	EndIf
//
//Return

/*/{Protheus.doc} FA330EXC
Ponto de entrada para gravação de dados ao Excluir a compensação de títulos a Receber.
@type function
@author luizf
@since 29/06/2016
/*/
User Function FA330EXC()

	//+---------------------------------------------------------------------+
	//| Valida se o titulo é de integracao.                                 |
	//+---------------------------------------------------------------------+	
	If SE1->(FIELDPOS("E1_XNUMOS")) == 0 .Or. Empty(SE1->E1_XNUMOS) .Or. AllTrim(SE1->E1_TIPO) == "RA"
	  Return
	EndIf                                       
	//Status: Aberto = 1,Baixado = 2,BaixadoParcialmente = 3,Protestado = 4
	If !U_WGENFIN1(SE1->E1_NUM,iif(SE1->E1_SALDO==SE1->E1_VALOR,"1","3"),SE1->E1_SALDO,"FA330EXC.Compensacao")//cNumTit,cStatus,nSaldo,cRotina
		Aviso("Erro Integração:WGENFIN1","Erro ao integrar Status do título, verifique com faturamento. Mais detalhes consultar LOG.",{"OK"})
	EndIf

Return


/*/{Protheus.doc} F330SE5
//TODO Ponto de entrada disponivel para procedimentos do usuário
@author Mario L. B. Faria
@since 06/02/2018
@Link http://tdn.totvs.com/pages/viewpage.action?pageId=113803836
/*/
User Function F330SE5()
 
 	Local aArea		:= GetArea()
 	Local aAreaSE1	:= SE1->(GetArea())
	
	//Posiciona no titulo principal
	SE1->(dbGoTo(nRecNo))

 	//+---------------------------------------------------------------------+
	//| Valida se o titulo é de integracao.                                 |
	//+---------------------------------------------------------------------+		
	If SE1->(FIELDPOS("E1_XNUMOS")) == 0 .Or. Empty(SE1->E1_XNUMOS) .Or. AllTrim(SE1->E1_TIPO) == "RA"
	
	Else
		//Status: Aberto = 1,Baixado = 2,BaixadoParcialmente = 3,Protestado = 4
		If !U_WGENFIN1(SE1->E1_NUM,iif(SE1->E1_SALDO>0,"3","2"),SE1->E1_SALDO,"FA330SE1.Compensacao")//cNumTit,cStatus,nSaldo,cRotina
			Aviso("Erro Integração:WGENFIN1","Erro ao integrar Status do título, verifique com faturamento. Mais detalhes consultar LOG.",{"OK"})
		EndIf
		
	EndIf
		
	RestArea(aAreaSE1)
	RestArea(aArea)	
	
 Return
 
 
 
 
 
 
 
