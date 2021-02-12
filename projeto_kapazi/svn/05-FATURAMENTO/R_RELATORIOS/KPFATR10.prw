/**********************************************************************************************************************************/
/** Faturamento                                                                                                                      **/
/** Pedido de Venda                                                                                                          **/
/** Envio de email para representante e cliente                               **/
/** RSAC Soluções Ltda.                                                                                                          **/
/** Kapazi                                                                                                                    **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/
/** 15/02/2015| Marcos Sulivan          | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#include "rwmake.ch"
#include "topconn.ch"
#include "ap5mail.ch"
#include "tbiconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/**********************************************************************************************************************************/
/** user function KPFATR10()                 cStatus, "cPedido, cCli, cLj)                                                                                    **/
/**********************************************************************************************************************************/
user function KPFATR10(cPedVend) 

Local cMailVend := ""
Local cNomeFrom := ""
Local cMailDest := ""	
Local cMailVend := ""
Local cAssunto  := ""
Local cPedido		:= cPedVend
//Local nStatus		:= nStatus
Local cTrandp		:= "" 
Local cPagto		:= ""
Local cRepr			:= ""
Local cMailRep	:= ""
Local nItem	  	:= 0
Local nQtd	   	:= 0
Local nTotal  	:= 0  
Local nTotIPI		:= 0 
Local cProd			:= ""	//Descricao produto
Local nTotIPI 	:= 0
Local nValtot		:= 0
Local nGeral		:= 0 
Local cSegUm		:= ""
Local cUm				:= ""
Local cTpConv		:= ""
Local nConv			:= ""   
Local aArea  	 := GetArea()    

Private nposentr   := aScan( aHeader, { |x| Alltrim(x[2])=="C6_ENTREG"  } )
Private npositem   := aScan( aHeader, { |x| Alltrim(x[2])=="C6_ITEM"  } )
Private nposprod   := aScan( aHeader, { |x| Alltrim(x[2])=="C6_PRODUTO"  } )
Private nposdesc   := aScan( aHeader, { |x| Alltrim(x[2])=="C6_DESCRI"  } )  
Private nposqtve   := aScan( aHeader, { |x| Alltrim(x[2])=="C6_QTDVEN"  } )
Private nposvlor   := aScan( aHeader, { |x| Alltrim(x[2])=="C6_VALOR"  } )
Private nposprve   := aScan( aHeader, { |x| Alltrim(x[2])=="C6_PRCVEN"  } )


	//Recebe o email do remetente
	cMailVend := "relatorios@kapazi.com.br"
	
	//Email do remetente
	cNomeFrom := "relatorios@kapazi.com.br"
		
	//Email de destino
	//cMailDest := "sulivan@rsacsolucoes.com.br"
	
	//Inicia o processo do workflow
  oWfProc   := TWfProcess():New( "000002", "RELATORIOS", NIL )
  
	//Layout  
  cWfTaskId := oWfProc:NewTask( "RELATORIOS",  "\workflow\kapazi2.html" )     
  oWfHtml   := oWfProc:oHtml     
  
  //selecione tabela de cabeçalho de pedido
  //dbSelectArea("SC5")
  
  //posiona no pedido
	//dbSeek(xFilial("SC5")+ alltrim(cPedido) )
  
  //Seleciona cliente
  dbSelectArea("SA1")
  
  //popsiciona no cliente e loja
	dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI) 
                                                                         

  	//Dispara o processo para o usuario
  oWfProc:ClientName(cUserName)
	
	oWfHtml   := oWfProc:oHtml
	
	//Dados do Pedido (Cabeçalho)
	oWfHtml:ValByName("NOMECOM", 	 		SM0->M0_NOMECOM)
	oWfHtml:ValByName("ENDCOB", 			alltrim(SM0->M0_ENDCOB))
	oWfHtml:ValByName("BAIRROCOB", 		alltrim(SM0->M0_BAIRCOB))
	oWfHtml:ValByName("CEPCOB", 			TRANSFORM(SM0->M0_CEPCOB,"@R 99999-999")	)                 
	oWfHtml:ValByName("CIDCOB",				SM0->M0_CIDCOB 	)
	oWfHtml:ValByName("ESTCOB", 			SM0->M0_ESTCOB	)
	oWfHtml:ValByName("CNPJCOB",			TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99" ) 	)
	//oWfHtml:ValByName("STATUS", 			IF(nStatus== 3,'INCLUIDO',IF(nStatus==4,'ALTERADO',''))	)
	
	//CLIENTE 
	oWfHtml:ValByName("CLIENTE",			alltrim(SA1->A1_NOME))
	oWfHtml:ValByName("CODCLI",				M->C5_CLIENTE)
	oWfHtml:ValByName("CODLOJ",				M->C5_LOJACLI)
	oWfHtml:ValByName("ENDCLI",				alltrim(SA1->A1_END)	)
	oWfHtml:ValByName("BAIRROCLI",		alltrim(SA1->A1_BAIRRO))
	oWfHtml:ValByName("CEPCLI",			  TRANSFORM(SA1->A1_CEP,"@R 99999-999")	 	)
	oWfHtml:ValByName("CIDCLI",  			ALLTRIM(SA1->A1_MUN)	)
	oWfHtml:ValByName("ESTCLI",				SA1->A1_EST 	)
	oWfHtml:ValByName("CNPJCLI",			TRANSFORM(SA1->A1_CGC,"@R 99.999.999/9999-99"  ))
	oWfHtml:ValByName("IECLI",				ALLTRIM(SA1->A1_INSCR)	)
	oWfHtml:ValByName("EMAILCLI",			SA1->A1_EMAIL 	)
	oWfHtml:ValByName("FONECLI", 			"("+SA1->A1_DDD+")"+TRANSFORM(SA1->A1_TEL,"@R 99999-9999"))
	oWfHtml:ValByName("EMISSAO", 			dTOc(M->C5_EMISSAO))
	oWfHtml:ValByName("PEDIDO",				M->C5_NUM 	) 
	
	//transportadira
	cTrandp			:=	posicione("SA4",1,xFilial("SA4")+M->C5_TRANSP,"A4_NOME")
	oWfHtml:ValByName("TRANSP", M->C5_TRANSP +" - " +cTrandp)
	
	//forma de pagamento
	cPagto			:= posicione("SE4",1,xFilial("SE4")+M->C5_CONDPAG,"E4_DESCRI")
	oWfHtml:ValByName("FPG",					ALLTRIM(cPagto) 	)
	
	//representante
	cRepr				:= posicione("SA3",1,xFilial("SA3")+M->C5_VEND1,"A3_NOME")
	oWfHtml:ValByName("REPRE",				ALLTRIM(cRepr)	)
	
	//dados representante
	cMailRep		:= 			posicione("SA3",1,xFilial("SA3")+M->C5_VEND1,"A3_EMAIL")
	oWfHtml:ValByName("EMAILREP",				ALLTRIM(cMailRep)	) 
	    	
	//ITENS DO PEDIDO DE VENDA
	//SC6->(dbSelectArea("SC6"))
	//SC6->(DBSeek(xFilial("SC6")+SC5->C5_NUM))
	//While !SC6->(eof()) .AND. SC6->C6_NUM == SC5->C5_NUM .and. SC6->C6_FILIAL == XFilial("SC6")
	
	For nI:= 1 To Len (aCols)
	
		cUm := Posicione('SB1', 1, XFilial('SB1') + aCols[nI][nposprod], 'B1_UM')
		cSegUm := Posicione('SB1', 1, XFilial('SB1') + aCols[nI][nposprod], 'B1_SEGUM')
		cTpConv := Posicione('SB1', 1,XFilial('SB1') + aCols[nI][nposprod], 'B1_TIPCONV')
		nConv := Posicione('SB1', 1, XFilial('SB1') + aCols[nI][nposprod], 'B1_CONV')                                                                         
	
		// fatura pela 1ª UM
		nQtd1 := 	aCols[nI][nposqtve]
		nQtd += 	aCols[nI][nposqtve]
		nValTot := aCols[nI][nposvlor]
		nValUnit := aCols[nI][nposprve] 
		nTotal += nValTot
 
	 	//contagens de itens 
		nItem++
		
		//IPI
		nTotIPI += nValTot * (Posicione('SBZ',1,xFilial('SBZ')+aCols[nI][nposprod],'BZ_IPI')/100) 
    		
		Aadd(oWfHtml:ValByName("IT.IT"), 				aCols[nI][npositem])
		Aadd(oWfHtml:ValByName("IT.CODP"),			aCols[nI][nposprod])
		Aadd(oWfHtml:ValByName("IT.DESCPROD")		,	ALLTRIM(aCols[nI][nposdesc]))
		Aadd(oWfHtml:ValByName("IT.UN"),				cUm)
		Aadd(oWfHtml:ValByName("IT.QTD"),				TRANSFORM(nQtd1,"@E 999,999,999.99"))
		Aadd(oWfHtml:ValByName("IT.VLUN"),			TRANSFORM(nValUnit,"@E 999,999,999.99"))
		Aadd(oWfHtml:ValByName("IT.VLTOT"),			TRANSFORM(nValTot,"@E 999,999,999.99"))
		Aadd(oWfHtml:ValByName("IT.IPI"),				TRANSFORM(Posicione('SBZ',1,xFilial('SBZ')+aCols[nI][nposprod],'BZ_IPI'),"@E 99.99"))
		Aadd(oWfHtml:ValByName("IT.DTENTR"),		DTOC(aCols[nI][nposentr]))	
	Next
	
	nGeral:= ntotal+M->C5_FRETE+M->C5_SEGURO+M->C5_DESPESA + nTotIPI 
	
	oWfHtml:ValByName("TOIT",			CVALTOCHAR(nItem)	)
	oWfHtml:ValByName("TOPEC",		CVALTOCHAR(nQtd)	)
	oWfHtml:ValByName("TOTPROD",	TRANSFORM(ntotal,"@E 999,999,999.99")	)
	oWfHtml:ValByName("VLTOTAL",	TRANSFORM(ntotal,"@E 999,999,999.99")	)
	oWfHtml:ValByName("IPITOTAL",	TRANSFORM(nTotIPI,"@E 999,999,999.99")	)
	oWfHtml:ValByName("TOTALG",		TRANSFORM(ngeral,"@E 999,999,999.99")	)
	oWfHtml:ValByName("TPFRETE",	IF(M->C5_TPFRETE=='C','CIF',IF(M->C5_TPFRETE=='F','FOB',''))	)
	oWfHtml:ValByName("OBS",			M->C5_MSGCLI)
	 
  //Define as propriedades de envio do e-mail
  oWfProc:cFromAddr := 'pv@e-kapazi.com.br'
  oWfProc:cFromName := cNomeFrom  
  oWfProc:cTo       := ALLTRIM(SA1->A1_EMAIL)+";"+ ALLTRIM(cMailRep)
  oWfProc:cCC       := "pv@e-kapazi.com.br"
  oWfProc:cSubject  := "Pedido de Compras nº " + Alltrim(	M->C5_NUM)
  oWfProc:bReturn   := Nil 
  
   
  //Inicia o processo
  oWfProc:Start()     
      
  //Chama o workflow para enviar os e-mails
  WfSendMail()


RestArea(aArea)
  
Return NIL